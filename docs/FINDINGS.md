# Findings

What the other pages don't cover: two things the binary has and the game never uses.
## There's room for two levels that don't exist

Background maps are located with `0x3000 + level * 0x200`. There's space for
eight, but only six have data: the 1024 bytes that levels 7 and 8 would occupy
are **0xFF filler**, and the loader stops at the sixth with a
`cp 6 / jp z,0xC000`.

## 135 bytes that never execute

Four stretches of perfectly coherent Z80 that no path reaches. Among them, a
**full-screen colour effect** that turns every black into transparent — 3673 of
the screen's 6144 colour bytes — and which only makes sense paired with a change
of backdrop colour. Half a fade that got left out.

![The effect that was never used](efecto-muerto.png)

The full story of all four is in [DEAD-BYTES.md](DEAD-BYTES.md).
