# TDEF

**Mnemonic:** TDEF

**Opcode:** 0x02A

**Confidence:** High

## Behavioral Description

Task definition header. TDEF is the first significant instruction of the
HALMAT text for a HAL/S *task* compilation unit, matched by a closing
[CLOS](CLOS.md) operator (opcode 0x030) at the end of the text.

```
 31         24 23         16 15      12 11         4  3    1 0
+------------+------------+---------+------------+------+---+
| (unused)   |     1      |   02A   |     0      |  0   | 0 |
+------------+------------+---------+------------+------+---+
```

One operand word follows:

- **DATA (operand)** — points to the task name in the symbol table.
- **QUAL** — SYL (symbol-table pointer).

## Usage Context

Appears once, at the start of a task compilation's HALMAT text. See also
the sibling definition headers for the other three compilation-unit kinds:
[MDEF](MDEF.md) (program), [PDEF](PDEF.md) (procedure), [FDEF](FDEF.md)
(function).

## Unresolved Questions

- None outstanding for the base format.

## Source Analysis & Reliability

Primary-sourced from [IR-60-5] p. A-8 (operator- and operand-word diagrams
and prose). [Halmat.pdf] corroborates the opcode and role.
