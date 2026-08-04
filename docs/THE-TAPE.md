# The tape

*Ale Hop!* shipped on cassette. The preserved file is a **TSX**, an MSX-oriented
format that stores the tape's blocks already demodulated rather than as audio:
the bytes come out exactly, with no conversion guesswork.

60680 bytes in 12 blocks. Three are metadata, one is the catalogue entry, and
the remaining eight hold the game.

## What's on it

| block | what | size |
|---|---|---|
| 4-5 | `ALEHOP` — the BASIC loader, as text | 256 B |
| 6-7 | `TOPO` — the Topo Soft logo | 4254 B |
| 8-9 | `SLOTS` — RAM finder and turbo loader | 753 B |
| 10 | Turbo block 1: the loading screen | 12388 B |
| 11 | Turbo block 2: **the entire game** | 42645 B |

The first three files travel in **KCS** blocks, the MSX standard: slow, with
headers. The last two are **turbo blocks**, and that's where Topo Soft went off
the beaten path.

## The turbo format

A turbo block is trivial once you know it:

```
[0x00] [ ......... data ......... ] [checksum]
```

A zero sync byte, the data, and a checksum byte chosen so that the **XOR of the
whole block comes to zero**. Verified on both blocks, and one of the project's
tests.

What makes it fast isn't the format but how it's read: the SLOTS loader doesn't
use the BIOS cassette routine at all. It times the pulse widths by hand, reading
bit 7 of port 0xA2, which lets it push the tape speed far past what the BIOS
allows.

## The loading chain

Typing `RUN"CAS:"` kicks off a five-stage sequence. Verified in the emulator with
a breakpoint at each stage: all of them are hit, in order, in 435 seconds of
emulated time — the seven-odd minutes anyone who played this in 1988 will
remember.

```
0x9470  TOPO      The Topo Soft logo, shown while the rest loads
0xC58F  SLOTS     Hunts for RAM in every slot, then relocates itself
0x88B8  turbo 1   Loads the cover screen and runs it: dumps to VRAM, returns
0x0000  turbo 2   Loads the whole game... into page 0
        Moves three chunks to high RAM and patches six vectors
0xC000  The game starts
```

## The odd part: loading on top of the ROM

A 64 KB MSX doesn't have 64 KB within reach. Memory is seen through 16 KB
windows called pages, and the bottom one — page 0, from 0x0000 to 0x3FFF — is
normally occupied by the BIOS ROM. There is RAM underneath, but it's covered.

The usual thing for a tape game is not to bother and load from 0x4000 up.
*Ale Hop!* does the opposite: it puts all 42645 bytes **into page 0**, on top of
where the BIOS sits. To pull that off it first has to find that RAM and know how
to switch it in, which is exactly what the SLOTS finder is for: it walks 4
primary by 4 secondary slots writing and reading back, and records **two** memory
configurations — the normal one and the all-RAM one — so it can alternate
between them during play.

Once loaded, it moves three chunks with `LDIR`:

| from (load) | to (runtime) | bytes | what |
|---|---|---|---|
| 0x8A41 | 0xB000 | 2201 | The sound player |
| 0x92DA | 0xBD00 | 2112 | The core and title screen |
| 0x9B1A | 0xD000 | 2938 | The game engine |

And what stays down below — 35393 bytes of graphics and maps — **gets covered by
the ROM again**. The game runs with the BIOS mapped in so it can call it, and
only uncovers the RAM underneath for a moment each time it loads a level,
between a `call 0xF00F` and a `call 0xF000`.

That's why the disassembly is five listings rather than one: each chunk is
assembled at the address where it actually runs, and concatenating them in tape
order reproduces the original block byte for byte.

## The round trip

The format is understood completely, and there are two proofs:

1. `tools/tsx_parse.py` and `tools/tsx_build.py` take the TSX apart and put it
   back together with the **same sha256**. Not one byte of the container is left
   uninterpreted.
2. `tools/build_tape.py` assembles the commented `.asm` files, rebuilds the
   blocks with their headers and checksums, and produces a tape **identical to
   the original** (`499d74c7...`). That tape loads in openMSX and the game runs.

The second one is what makes the disassembly useful: change something in the
code and you can still get back to a tape that boots.
