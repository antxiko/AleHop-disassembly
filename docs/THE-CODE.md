# Inside the code

The 42645 bytes of the game block break down like this:

| | bytes | |
|---|---|---|
| Traced code | 4588 | 10.8 % |
| Identified data | 38057 | 89.2 % |
| **Unexplained** | **0** | |

Only 10.8 % being code doesn't mean there's disassembly left to do: it means
*Ale Hop!* is mostly graphics. An MSX game of this era fits in very few
instructions; what takes up room is the artwork.

## Five listings, not one

The loader relocates three chunks before starting the game, so tape addresses
and runtime addresses don't line up. To have the listing read with the **real**
addresses and still reassemble to the original binary, the game is split into
five modules:

| listing | runs at | on the tape at | bytes |
|---|---|---|---|
| `alehop_game_datos.asm` | 0x0000 | 0x00000 | 35393 |
| `alehop_game_sonido.asm` | 0xB000 | 0x08A41 | 2201 |
| `alehop_game_nucleo.asm` | 0xBD00 | 0x092DA | 2112 |
| `alehop_game_extra.asm` | 0xD000 | 0x09B1A | 2938 |
| `alehop_game_cola.asm` | 0xA694 | 0x0A694 | 1 |

Concatenated in that order they come to exactly 42645 bytes.
`tools/split_trace.py` does the splitting and a test checks the result.

## Living with the ROM

The game starts at 0xC000, and the first thing it does after setting the stack
is configure memory through three calls into a slot switcher the loader left at
0xF000:

```
ld sp,0xF37F
ld (0xC52E),a      ; 0 = normal boot, non-zero = returning from a finished game
call 0xF000        ; page 0 -> BIOS ROM
call 0xF014        ; page 1 -> RAM
call 0xF019        ; page 2 -> RAM
```

That switcher has **six entry points** doing the same job with different
parameters: three put a page into the BASIC configuration and three into the
all-RAM one, covering pages 0, 1 and 2.

The practical consequence, worth keeping in mind while reading the listing:
**any address below 0x4000 appearing in a `CALL` or `JP` is the BIOS**, not game
data. The 35 KB of graphics sitting underneath are only visible inside the level
loader.

## The frame routine

The engine has no conventional main loop. Instead there's a 16-bit **task mask**
at 0xDB69. The frame routine waits for the vertical blank and then checks it bit
by bit:

```
ld ix,0xDB69
halt
bit 7,(ix+0) / call nz,BLIT_MAP
bit 6,(ix+0) / call nz,BLIT_BACKGROUND
bit 5,(ix+0) / call nz,ANIMATE_TILES
bit 4,(ix+0) / call nz,APPLY_SPEED
bit 3,(ix+0) / call nz,ADVANCE_CAMERA
bit 2,(ix+0) / call nz,APPLY_HEIGHT
bit 1,(ix+0) / call nz,FRAME_PATTERN
bit 0,(ix+0) / call nz,DRAW_PLAYER
bit 7,(ix+1) / call nz,COLLISION
bit 6,(ix+1) / call nz,JUMP
bit 5,(ix+1) / call nz,COUNTDOWN
```

Change the mask and you change the game's state without touching the flow:
0xE0FF during normal play, smaller values while the player is dying or the stage
is ending. The main loop puts it back every time round:

```
MAIN_LOOP:
    ld sp,0xF37F        ; the stack is reset: collision handlers jump without unwinding
    call FRAME
    ld hl,0xE0FF
    ld (0xDB69),hl
    jr MAIN_LOOP
```

## The fast interrupt

The game hooks itself into **H.TIMI** (0xFD9F), the hook the BIOS calls on every
video interrupt. But it doesn't return the way it should:

```
in a,(0x99)         ; acknowledge the VDP interrupt
pop hl              ; THROW AWAY the return address into the BIOS handler
di
ld hl,0xDB75
inc (hl)            ; frame counter
call SOUND_FRAME
pop ix / pop iy / pop af / pop bc / pop de / pop hl
ex af,af' / exx
pop af / pop bc / pop de / pop hl
ei
ret
```

It discards the way back into the BIOS and unwinds by hand the registers the
BIOS had just pushed, skipping the rest of the system interrupt routine. In a
game this tight on time, that's a lot. There are three copies of this same
skeleton in the binary: the title screen's, the gameplay one, and a third that
never runs.

## Sound

Each of the PSG's three channels gets a **46-byte** state block — the code says
so itself: `ld de,0x002E` — holding its melody pointer twice over (one advances,
the other is there to loop), the remaining note duration, volume, period, and
offsets that get added every frame to produce vibrato.

A melody is a byte stream: values under 0x80 are notes, 0x80 and above are
commands dispatched through a **12-entry** jump table at 0xB486.

All three channels write into an 11-byte shadow buffer at 0xB4A0, laid out in
the chip's own register order, and a single routine flushes the lot at the end
of the frame.

The player doesn't look like code written for this game so much as a library
dropped into it. The tell is in the binary: it comes with **its own interrupt
handler**, ready to hook into the system — and the game never uses it, because
it has its own.

## Graphics

Compressed with a **16-bit token RLE**:

```
0xFFFF        end of block
bit 15 set    repeat the next byte (n & 0x7FFF) times
bit 15 clear  copy n literal bytes
```

Eleven blocks, each decompressing to exactly 2048 bytes — one screen third of
patterns or colours, or the sprite patterns — chaining without a single spare
byte from 0x4800 to 0x884D.

There are **two graphics sets**, one for gameplay and one for the title screen,
sharing the third screen band and the sprites. Their tables live at 0xDB17 and
0xDB35 and are lists of (compressed source, VRAM destination) pairs terminated
by 0x0000.
