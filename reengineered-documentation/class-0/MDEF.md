# MDEF

**Mnemonic:** MDEF
**Opcode:** 0x02B
**Confidence:** High

## Behavioral Description

Program definition header. MDEF is the first significant instruction of
the HALMAT text for a HAL/S *program* compilation unit, matched by a
closing `CLOS` operator (opcode 0x030, not yet documented — see
[STATUS.md](../STATUS.md)) at the end of the text.

```
 31         24 23         16 15      12 11         4  3    1 0
+------------+------------+---------+------------+------+---+
| (unused)   |     1      |   02B   |     0      |  0   | 0 |
+------------+------------+---------+------------+------+---+
```

One operand word follows:

- **DATA (operand)** — points to the program name in the symbol table.
- **QUAL** — SYL (symbol-table pointer).

## Usage Context

Appears once, at the start of a program compilation's HALMAT text. See also
the sibling definition headers for the other three compilation-unit kinds:
[TDEF](TDEF.md) (task), [PDEF](PDEF.md) (procedure), [FDEF](FDEF.md)
(function).

## Unresolved Questions

- None outstanding for the base format; the closing CLOS operator and the
  full structure of a program's HALMAT text are not yet documented.

## Source Analysis & Reliability

Primary-sourced from [IR-60-5] p. A-8 (operator- and operand-word diagrams,
and the one-line prose "'Operand' points to the program name in the symbol
table"). [Halmat.pdf] corroborates the opcode and role.
