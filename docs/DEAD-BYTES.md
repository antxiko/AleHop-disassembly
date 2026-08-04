# The 135 bytes that never execute

Inside the game block there are four stretches that disassemble as perfectly
coherent Z80 and that **no path reaches**: no `CALL`, no `JP`, no pointer in any
table. 135 bytes out of 42645.

They were hunted down one at a time: for each address, its pointer (the two
bytes, little-endian) was searched across the **whole** binary — all three code
regions, the engine's tables, and the 35 KB of page-0 data — and it doesn't
appear. The search was done over the real disassembly, not by scanning bytes: a
naive scan mistakes operands for opcodes and produces false positives. The first
four candidates found that way collapsed on inspection.

They're deliberately marked as data in the listing. **Something disassembling
cleanly doesn't prove it runs**, and taking that for granted is the easiest way
for a disassembly to end up lying: the bytes come out identical when reassembled
— they haven't changed, only their interpretation has — so a reproducibility
check notices nothing.

They're still worth something, though: they say things about the game that the
live code doesn't.

---

## 1. The colour effect that was left out — 43 bytes at 0xC38E

The most interesting of the four. It walks the 0x1830 bytes of the VRAM colour
table and applies the routine at 0xC3A7 to each byte **twice**:

```
0xC3A7:  rlc a / rlc a / rlc a / rlc a   ; swap the two nibbles
         ld d,a
         and 0x0F                        ; look at the result's low nibble
         xor 0x01                        ; is it 1?
         ld a,d
         ret nz                          ; if not, return the rotated value
         and 0xF0                        ; if so, zero it
         ret
```

Applied twice the nibbles end up back where they started, and the net effect is
a one-line rule: **every nibble equal to 1 becomes 0**. Tested across all 256
possible combinations: 31 change.

On the TMS9918, colour 1 is **black** and colour 0 is **transparent**, and
transparent shows the backdrop colour from register R7. So this routine turns
every black on screen into "whatever the backdrop says".

On the actual title screen it changes **3673 of the 6144 colour bytes**, 60 % of
the display. With the black backdrop the game uses (R7 = 0x01) you'd see
nothing: it only makes sense alongside a change to R7. In other words, it was
half of a full-screen fade or flash.

Here's how it would look with a blue backdrop:

![The colour effect that was never used](efecto-muerto.png)

---

## 2. A title-screen loop from another version — 26 bytes at 0xC264

```
ld hl,0xC532 / ld a,(0xC52F) / add a,(hl) / ld (hl),a
call 0xC17A / push af / call 0xC134
ld bc,0x7C05 / call 0xC245 / pop af
ret z / halt / jr 0xC264
```

It calls three routines that are very much alive (0xC17A, 0xC134 and 0xC245) and
touches a variable that's in use (0xC532), so this is code from this game, not
some other one. What gives it away is **0xC52F**: not a single live instruction
reads or writes that variable. It's a title animation loop that was replaced by
another, leaving an orphaned variable behind.

---

## 3. The sound library's interrupt handler — 21 bytes at 0xB000

```
di / pop hl / call 0xB036 / pop ix / pop iy / pop af / pop bc / pop de / pop hl
ex af,af' / exx / pop af / pop bc / pop de / pop hl / ei / ret
```

This is the classic "fast interrupt": `pop hl` throws away the return address
into the BIOS handler and the registers the BIOS had just saved are unwound by
hand, skipping the rest of the system interrupt routine.

It sits immediately before the music player and calls its frame routine
(0xB036), which makes it the **library's standard entry point** — the one you'd
hook into H.TIMI if all you wanted was music. *Ale Hop!* doesn't use it because
it has its own handlers, at 0xC105 for the title screen and 0xD345 during play,
which do the same thing plus keep a frame counter. All three are the same
skeleton byte for byte.

It's the best evidence that the sound player arrived as a **reusable library**
rather than as code written for this game: it travels with its own interrupt
handler even though the game integrating it never calls it.

---

## 4. A loader from another build — 45 bytes at 0x8850

This one isn't among the code but at the end of the data, right behind the last
block of compressed graphics.

```
in a,(0xA8) / and 0xC0 / ld c,a / ld b,3
[srl c / srl c / or c / djnz]      ; replicate page 3's slot across all four
ld (0xA87D),a
and 0xFC / di / out (0xA8),a       ; page 0 -> ROM, pages 1,2,3 -> RAM
ld hl,0x9000 / ld de,0x7000 / ld bc,0x184D / ldir
ld a,(0xA87D) / and 0xF0 / out (0xA8),a   ; pages 0 and 1 -> ROM, 2 and 3 -> RAM
ei / xor a / jp 0xC000
```

It ends by jumping to 0xC000, the same entry point the real game uses. But **the
memory layout it leaves behind is different**: ROM in pages 0 *and* 1
(0x0000-0x7FFF), RAM only in the top two. The shipped version puts ROM in page 0
only and RAM in the other three.

In that version, then, the game lived in the top 32 KB and hid its data under
the **BASIC ROM** in page 1, rather than under the BIOS as the shipped one does.
It moves 0x184D bytes (6221) to 0x7000, and the arithmetic lands exactly on
0x884D — which happens to be where the compressed graphics end in the shipped
version.

One more thing places it outside this build: it uses a variable at 0xA87D, and
the game block ends at 0xA694. That address doesn't exist here.

---

## Summary

| where | bytes | what |
|---|---|---|
| 0x8850 | 45 | Loader from a build with a different memory layout |
| 0xC38E | 43 | Full-screen colour effect, never invoked |
| 0xC264 | 26 | Title-screen loop replaced by another |
| 0xB000 | 21 | The sound library's interrupt handler, unused |
| | **135** | |
