# Open questions

All 42,645 bytes of the game block are accounted for, the modules reassemble byte
for byte and the rebuilt tape has the same sha256. What is left open is little,
and it goes here.

## Which build the loader at 0x8850 comes from

At the end of the data, behind the last block of compressed graphics, there is a
45-byte loader nothing runs. It jumps to 0xC000 like the real game, but **it
leaves a different memory map**: ROM in pages 0 *and* 1 and RAM only in the top
two, so in that version the data lived under the BASIC ROM rather than under the
BIOS. It also uses variable 0xA87D, which does not exist in this version: the
game block ends at 0xA694.

So it is a leftover of **another build** of Ale Hop!. Which one it was, and
whether it ever came out, is not known. The details are in
[the dead bytes](DEAD-BYTES.html).

## The 66 bytes at 0x88DA

In the title-screen piece, between the `ret` at 0x88D9 —which hands control back
to the loader— and the image's pattern table, which starts at 0x891C, there are
66 bytes left. The listing gives them as leftover that never runs, and marks that
as a guess: what they were has not been worked out.
