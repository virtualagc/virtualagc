# ISHP

**Mnemonic:** ISHP
**Opcode:** 0x043
**Confidence:** High

## Behavioral Description

Integer shaping-function marker. Identifies the "integer-array-result"
list-form case of the general shaping-function bracketing mechanism
([SFST](SFST.md)/[SFAR](SFAR.md)/[SFND](SFND.md)) — emitted for an
`INTEGER(exp1, exp2, ...)` conversion function invocation in its
multi-argument list form ([USA003087] §21.2; the single-argument simple
form instead compiles through [BTOI](../class-6/BTOI.md)/
[CTOI](../class-6/CTOI.md)/[STOI](../class-6/STOI.md)). Its own operand
carries the resulting array's length.

## Usage Context

Appears once per list-form `INTEGER(...)` shaping-function call,
positioned between the last [SFAR](SFAR.md) and the closing
[SFND](SFND.md). One of a 4-member family sharing the `XMSHP` array
alongside [MSHP](MSHP.md) (matrix), [VSHP](VSHP.md) (vector), and
[SSHP](SSHP.md) (scalar) — see those files.

## Operand-Word Format (confirmed empirically)

One operand: `DATA`=the resulting array's length (a literal integer),
`QUAL`=6=IMD. Confirmed by compiling `IA1 = INTEGER(I1, I2);` (`IA1` an
`ARRAY(2) INTEGER`) with `HALSFC --parms="LSTALL"`:

```
HALMAT: 045(0),1,0            <- SFST
HALMAT: 047(1),1,0            <- SFAR: I1
          5(1),6,0
HALMAT: 047(1),1,0            <- SFAR: I2
          6(1),6,0
HALMAT: 043(1),1,0            <- ISHP
          2(6),0,0               <- literal 2 (result array length), QUAL=6=IMD
HALMAT: 046(0),1,0            <- SFND
```

## Unresolved Questions

- The `@SINGLE`/`@DOUBLE` precision-forcing forms ([USA003087] §21.2)
  were not tested.

## Source Analysis & Reliability

Opcode (0x043) confirmed primary-source: `XMSHP` array element 3 in
`PASS1.PROCS/##DRIVER.xpl` — see [##DRIVER.xpl] in `STATUS.md`. No
[MSC-01847] (HAL-1971) analog identified under this name. Statement
syntax primary-sourced from [USA003087] §21.2 (PDF p. 256ff). Full
behavioral description and operand-word structure confirmed directly
against real compiled HALMAT this session, as part of a systematic
sweep of USA003087 syntax patterns against previously-untested HALMAT
opcodes (direct user suggestion).
