# PXRC

**Mnemonic:** PXRC

**Opcode:** 0x005

**Confidence:** High

## Behavioral Description

Pointer to XREC — always the first HALMAT operator in a record (block). Its
operand points to the index, within the record, of that record's closing
[XREC](XREC.md).

```
 31         24 23         16 15      12 11         4  3    1 0
+------------+------------+---------+------------+------+---+
| (unused)   |     1      |   005   |     0      |  0   | 0 |
+------------+------------+---------+------------+------+---+
```

- **TAG** — don't-care.
- **NUMOP** — 1.
- **OPCODE** — 0x005.

One operand word follows:

- **DATA** — pointer to the index of the record's XREC operator.
- **TAG1, QUAL, TAG2** — don't-care.

## Usage Context

Always the first word (after the record's metadata word 0) in a HALMAT
record; see [Block Structure](../HALMAT.md#block-record-structure) and
[XREC](XREC.md).

## Unresolved Questions

- None outstanding.

## Source Analysis & Reliability

Primary-sourced from [IR-60-5] p. A-7 (operator- and operand-word diagrams)
and p. A-4/A-5 ("A PXRC operator is always the first operator in a
RECORD..." and the "Layout of HALMAT Files" diagram). [Halmat.pdf]
corroborates the format and role independently.
