# SMRK

**Mnemonic:** SMRK
**Opcode:** 0x004
**Confidence:** High

## Behavioral Description

General statement marker. SMRK follows the generated HALMAT code for each
HAL/S source statement that is *not* contained in an inline function block.
Compare [IMRK](IMRK.md), which plays the same role for statements that
*are* inside an inline function block.

```
 31         24 23         16 15      12 11         4  3    1 0
+------------+------------+---------+------------+------+---+
| error tag  |     1      |   004   |     N      |  0   | 0 |
+------------+------------+---------+------------+------+---+
```

- **TAG (error tag)** — maximum statement error severity; 0 if no errors.
- **NUMOP** — 1.
- **OPCODE** — 0x004.

One operand word follows, with the same layout as [IMRK](IMRK.md)'s:
statement number (DATA), a DEBUG tag (TAG1, normally 0), and QUAL=0.

## Usage Context

Appears once per HAL/S source statement outside inline function blocks,
immediately after that statement's generated HALMAT code. Each HAL/S
statement compiles to a "paragraph" of HALMAT that always ends in either
SMRK or IMRK (see [Block Structure](../HALMAT.md#block-record-structure)).
If a statement generates no HALMAT code of its own, its paragraph consists
of the SMRK (or IMRK) alone.

## Unresolved Questions

- Same open question as IMRK regarding the exact meaning of the "N"/"C"
  bit.

## Source Analysis & Reliability

Primary-sourced from [IR-60-5] p. A-6 (operator-word diagram and field
widths; the operand-word layout is not redrawn on this page but is
identical to IMRK's per the shared "statement number / DEBUG" prose used
for both) and p. A-4 ("As many whole PARAGRAPHS... derived from the source
text followed by a SMRK instruction..."). [Halmat.pdf] corroborates the
format.
