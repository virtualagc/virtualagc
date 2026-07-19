# XREC

**Mnemonic:** XREC
**Opcode:** 0x002
**Confidence:** High

## Behavioral Description

Marks the end of a HALMAT record (block). Every HALMAT record ends with
exactly one XREC operator, immediately following that record's last
paragraph.

```
 31         24 23         16 15      12 11         4  3    1 0
+------------+------------+---------+------------+------+---+
|    tag     |     0      |   002   |     ---    |  0   | 0 |
+------------+------------+---------+------------+------+---+
```

- **TAG** — 0 for every HALMAT record except the last in a compilation; 1
  for the last record.
- **NUMOP** — 0.
- **OPCODE** — 0x002.

Under Optimizer HALMAT, the operator word's CSE bit, when set on an XREC,
takes on a special meaning: it indicates the next HALMAT record is a
logical continuation of the current one, with cross-record references
possible (see "Optimizer HALMAT" in [HALMAT.md](../HALMAT.md)).

## Usage Context

Always the last operator in its record; see [PXRC](PXRC.md), the operator
that always begins a record, and [Block Structure](../HALMAT.md#block-record-structure)
for the surrounding record layout.

## Unresolved Questions

- None outstanding for the base (pre-optimizer) format.

## Source Analysis & Reliability

Primary-sourced from [IR-60-5] p. A-6 (operator-word diagram and TAG
semantics) and p. A-4/A-5 (record layout and the "Layout of HALMAT Files"
diagram, showing XREC as the terminal word of each record). The
Optimizer-HALMAT CSE reinterpretation is from [IR-60-5] p. A-110 (section
A.3.1). [Halmat.pdf] corroborates all of the above independently.
