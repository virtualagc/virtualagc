# CNOT

**Mnemonic:** CNOT

**Opcode:** 0x7E4

**Confidence:** High

## Behavioral Description

Logical NOT. Computes the logical complement of a single logical
(TRUE/FALSE) operand. Unary. Distinct from
[BNOT](../class-1/BNOT.md) (bitwise complement of a bit-string, Class 1).

## Usage Context

Emitted for HAL/S expressions using logical negation (`NOT`) on a
condition.

## Operand-Word Format (confirmed empirically)

One operand: `QUAL`=3=VAC, `DATA`=stream position of the producing
comparison instruction. Confirmed by compiling `IF NOT (X>1) THEN ...;`
with `HALSFC --parms="LISTING2,LSTALL"`, cross-checked directly with
`unHALMAT.py`:

```
HALMAT: 7C8(2),0,0        <- IGT: X > 1
HALMAT: 7E4(1),0,0        <- CNOT
          82(3),0,0          <- op: VAC ref to the IGT result
```

## Unresolved Questions

- None remaining for the base case.

## Source Analysis & Reliability

Opcode (0x7E4) confirmed primary-source: `XCNOT BIT(16) INITIAL("07E4")`
in `PASS1.PROCS/##DRIVER.xpl` — see [##DRIVER.xpl] in `STATUS.md`. Matches
[MSC-01847]'s HAL-1971 CNOT opcode (0x7E4) exactly. Operand-word
structure confirmed directly against real compiled HALMAT this session
via a direct `unHALMAT.py` binary read.

Behavioral description is a straightforward reading of "logical not"
corroborated by [MSC-01847] §2.22.
