# VSHP

**Mnemonic:** VSHP

**Opcode:** 0x041

**Confidence:** High

## Behavioral Description

Vector shaping-function marker. Identifies the "vector-result" case of the
general shaping-function bracketing mechanism ([SFST](SFST.md)/
[SFAR](SFAR.md)/[SFND](SFND.md)) — emitted for a `VECTOR(exp1, exp2,
...)` conversion function invocation ([USA003087] §21.1). Its own
operand carries the resulting vector's length (dimension).

## Usage Context

Appears once per `VECTOR(...)` shaping-function call, positioned between
the last [SFAR](SFAR.md) (one per argument expression) and the closing
[SFND](SFND.md). One of a 4-member family sharing the `XMSHP` array
alongside [MSHP](MSHP.md) (matrix), [SSHP](SSHP.md) (scalar), and
[ISHP](ISHP.md) (integer) — see those files.

## Operand-Word Format (confirmed empirically)

One operand: `DATA`=the resulting vector's length (a literal integer,
not a data reference), `QUAL`=6=IMD. Confirmed by compiling `V1 =
VECTOR(S1, S2, S1);` (`V1` a `VECTOR(3)`) with
`HALSFC --parms="LSTALL"`:

```
HALMAT: 031(0),1,0            <- EDCL
HALMAT: 045(0),1,0            <- SFST
HALMAT: 047(1),1,0            <- SFAR: S1 (argument 1)
          3(1),5,0
HALMAT: 047(1),1,0            <- SFAR: S2 (argument 2)
          4(1),5,0
HALMAT: 047(1),1,0            <- SFAR: S1 again (argument 3)
          3(1),5,0
HALMAT: 041(1),1,0            <- VSHP
          3(6),0,0               <- literal 3 (result vector length), QUAL=6=IMD
HALMAT: 046(0),1,0            <- SFND
```

## Unresolved Questions

- Whether the dimension operand is ever `VAC`-qualified (a computed
  expression rather than a literal) was not tested — [USA003087] §21.1
  doesn't appear to allow a non-literal dimension for the *implicit*
  form used here (dimension is always inferred from the L-value or the
  argument count), so this may not be a real gap.

## Source Analysis & Reliability

Opcode (0x041) confirmed primary-source: `XMSHP` array element 1 in
`PASS1.PROCS/##DRIVER.xpl` — see [##DRIVER.xpl] in `STATUS.md`. No
[MSC-01847] (HAL-1971) analog identified under this name. Statement
syntax primary-sourced from [USA003087] §21.1 (PDF p. 255ff). Full
behavioral description and operand-word structure confirmed directly
against real compiled HALMAT this session, as part of a systematic
sweep of USA003087 syntax patterns against previously-untested HALMAT
opcodes (direct user suggestion).
