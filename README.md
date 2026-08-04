# Ale Hop! — a commented disassembly

Complete, commented Z80 source for **Ale Hop!** (Topo Soft, MSX, 1988),
reconstructed from the original cassette.

This is not an approximation or a reimplementation: **all four modules reassemble
to the original binary byte for byte**, and the tape rebuilt from these sources
is identical to the TSX we started from, same sha256. Every one of the 42645
bytes of the game block is accounted for: 4588 of code and 38057 of data, none
unexplained.

*[Léeme en castellano](README.es.md)*

![The loading screen](docs/portada.png)

## What's here

| | |
|---|---|
| `src/*.asm` | The commented listings. Readable without building anything |
| `src/*.notes` | The comments, anchored to addresses so they survive a re-trace |
| `tools/` | Tape parser, code tracer, listing generator, emulator harness |
| `tests/` | 36 tests that check this documentation's claims against the binary |
| `docs/` | The write-up, with the game's screens drawn from its own data |

## Getting started

```sh
make            # extract, trace, generate the listings, verify everything
make imagenes   # draw the six levels from the game's data
```

You'll need `pasmo`, `z80dasm`, `python3`, and `openmsx` for the emulator parts.
The `.tsx` tape image is **not** distributed here.

More: [docs/GETTING-STARTED.md](docs/GETTING-STARTED.md).

## The game

An obstacle race. You steer a grinning ball down six horizontally scrolling
tracks, jumping whatever gets in the way, against the clock. The credits, read
out of the binary itself:

> **PROGRAMA:** ALBERTO L. NAVARRO · **GRÁFICOS:** LUIGILOPEZ · TOPO SOFT 1988

![The title screen](docs/presentacion.png)

And this is level 1: parallax background on top, the track in the middle, the
scoreboard at the bottom. The three bands use different thirds of the screen,
each with its own pattern and colour tables.

![Level 1](docs/niveles/pantalla_nivel1.png)

More: [docs/THE-GAME.md](docs/THE-GAME.md).

## The interesting parts

**The game loads on top of the ROM.** All 42645 bytes go into page 0, where the
MSX BIOS lives, and the loader then moves three chunks up into high RAM. The
35 KB of graphics and maps stay hidden underneath the ROM, and the game only
uncovers them for an instant each time it loads a level. That one decision
shapes everything else — it's why this disassembly is five listings, not one.

**There's a message almost nobody read.** Clear the sixth level and a text
scrolls past. The screen framing it is empty: the text is drawn at runtime, one
letter at a time.

![The ending message](docs/mensaje-final.png)

**135 bytes never execute**, and they have stories: a full-screen colour effect
that was left out, the sound library's own interrupt handler sitting unused, and
a loader from a different build with a different memory layout. All of it in
[docs/DEAD-BYTES.md](docs/DEAD-BYTES.md).

**And there's room for two levels that don't exist:** 1024 bytes of filler
exactly where the backgrounds for levels 7 and 8 would go.

Everything found: [docs/FINDINGS.md](docs/FINDINGS.md).

## Reading it

- [Getting started](docs/GETTING-STARTED.md) — where to begin, how to rebuild it
- [The game](docs/THE-GAME.md) — levels, controls, how the screen is put together
- [The tape](docs/THE-TAPE.md) — the TSX format, the turbo loader, the loading chain
- [The code](docs/THE-CODE.md) — paging, the frame routine, sound, graphics
- [Findings](docs/FINDINGS.md) — what turned up along the way
- [Dead bytes](docs/DEAD-BYTES.md) — the 135 bytes that never run

## Notice

This is documentation and preservation work on a game from 1988. The code and
artwork belong to their authors and to Topo Soft. The tape image is not
distributed. See [AVISO-LEGAL.md](AVISO-LEGAL.md).
