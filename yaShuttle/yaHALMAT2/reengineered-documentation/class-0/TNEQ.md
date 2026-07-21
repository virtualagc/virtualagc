# TNEQ

**Mnemonic:** TNEQ

**Opcode:** 0x04D

**Confidence:** High

## Behavioral Description

Structure not-equal comparison. Implements the `¬=`/`NOT=` operator for
tree-equivalent structure operands ([USA003087] §19.9) — the negated
counterpart of [TEQU](TEQU.md). Delegates to the same runtime comparison
routine (`#QCSTRUC`) as `TEQU`; the negation is expressed purely by
swapping the two branch-condition codes consuming the result (`BC
3,<target>` / `BC 7,<fallthrough>` for `TEQU` vs. `BC 3,<fallthrough>` /
`BC 7,<target>` for `TNEQ`, confirmed below), not by any difference in
`TNEQ`'s own operand encoding or in `#QCSTRUC` itself.

## Usage Context

Emitted for the `¬=`/`NOT=` form of a structure comparison, used the same
way as [TEQU](TEQU.md) (e.g. as an `IF` condition).

## Operand-Word Format (confirmed empirically)

Two operands, both `XPT`-qualified (`QUAL`=4): `DATA`=stream position of
the [EXTN](../class-0/EXTN.md) instruction that resolved each structure
operand's pointer — identical in shape to [TEQU](TEQU.md)'s. Confirmed by
compiling `IF ZQ1 ¬= ZQ2 THEN B1 = TRUE; ELSE B1 = FALSE;` with
`HALSFC --parms="LSTALL"`:

```
HALMAT: 007(0),0,0            <- IFHD
HALMAT: 001(2),0,0            <- EXTN, resolves ZQ1
HALMAT: 001(2),0,0            <- EXTN, resolves ZQ2
HALMAT: 04D(2),0,0            <- TNEQ
         44(4),0,0
         47(4),0,0
LA 3,ZQ2 / LA 2,ZQ1 / ST 2,18(0,0) / ST 3,20(0,0) / LFXI 5,5
BAL 4,#QCSTRUC                  <- same runtime structure-comparison routine as TEQU
BC 3,P#4 / BC 7,P#3             <- condition codes swapped relative to TEQU's trace
HALMAT: 00A(2),0,0            <- FBRA, consumes TNEQ's result
```

## Unresolved Questions

- The exact meaning of the `LFXI 5,5` constant passed to `#QCSTRUC` is
  still not decoded (see [TEQU](TEQU.md)'s identical open question).

## Source Analysis & Reliability

Opcode (0x04D) confirmed primary-source: `XTEQU` array element 1 in
`PASS1.PROCS/##DRIVER.xpl` — see [##DRIVER.xpl] in `STATUS.md`.
[MSC-01847] describes an identically-named "structure not equal"
instruction, but at HAL-1971 opcode 0x044 (mnemonic and behavior match,
opcode differs). Statement syntax primary-sourced from [USA003087] §19.9
(PDF p. 231ff). Full behavioral description and operand-word structure
now confirmed directly against real compiled HALMAT (a quick follow-up
compile test, using the same `¬=` UTF-8 character already confirmed to
work for [NNEQ](NNEQ.md)'s equivalent test).
