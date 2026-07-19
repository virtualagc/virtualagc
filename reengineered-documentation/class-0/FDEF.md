# FDEF

**Mnemonic:** FDEF

**Opcode:** 0x02C

**Confidence:** High

## Behavioral Description

Function definition header. FDEF is the first significant instruction of
the HALMAT text for a HAL/S *function* compilation unit, matched by a
closing `CLOS` operator (opcode 0x030, not yet documented — see
[STATUS.md](../STATUS.md)) at the end of the text.

```
 31         24 23         16 15      12 11         4  3    1 0
+------------+------------+---------+------------+------+---+
| (unused)   |     1      |   02C   |     0      |  0   | 0 |
+------------+------------+---------+------------+------+---+
```

One operand word follows:

- **DATA (operand)** — points to the function name in the symbol table.
- **QUAL** — SYL (symbol-table pointer).

## Usage Context

Appears once, at the start of a function compilation's HALMAT text. See
also the sibling definition headers for the other three compilation-unit
kinds: [MDEF](MDEF.md) (program), [TDEF](TDEF.md) (task), [PDEF](PDEF.md)
(procedure).

## Unresolved Questions

- None outstanding for the base format.

## Source Analysis & Reliability

Primary-sourced from [IR-60-5] p. A-8 (operator- and operand-word diagrams
and prose). [Halmat.pdf] corroborates the opcode and role.
