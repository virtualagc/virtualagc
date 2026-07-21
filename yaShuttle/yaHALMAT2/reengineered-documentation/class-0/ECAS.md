# ECAS

**Mnemonic:** ECAS

**Opcode:** 0x00C

**Confidence:** High

## Behavioral Description

`DO CASE` statement end / join point. Closes the construct opened by
[DCAS](DCAS.md) ([USA003087] §10.3). Marks the position in the HALMAT
(and generated machine code) stream where every case body's own
end-of-case unconditional branch converges — i.e. after any one case
executes, control jumps forward to precisely where ECAS sits, whichever
case was originally selected.

## Usage Context

Appears once per `DO CASE` construct, at the end of the statement group
(the `END;` that closes it). Immediately preceded, in the tested case, by
a final [CLBL](CLBL.md) instruction with an atypical single-operand form
(see [DCAS](DCAS.md)'s and [CLBL](CLBL.md)'s Unresolved Questions —
possibly a runtime-error trap for out-of-range selector values, since no
`ELSE` clause was present in the tested construct).

## Operand-Word Format (confirmed empirically)

One operand: `DATA`=the same construct identifier used by the
originating [DCAS](DCAS.md) and every [CLBL](CLBL.md) in between,
`QUAL`=2=GLI/INL.

Confirmed by compiling the `DO CASE` construct documented in
[DCAS](DCAS.md), whose closing `END;` produced:

```
HALMAT: 00C(1),0,0        <- ECAS
          1(2),0,0          <- op 1: construct id 1 (matches DCAS), QUAL=2=GLI/INL
000025:L#1 EQU *            <- ECAS's own position becomes the join-point label
```

Every case body ends with an unconditional branch (`BC 7,L#1`) to
exactly this label, confirming ECAS marks the convergence point.

## Unresolved Questions

- Whether an `ELSE` clause (per [USA003087] §10.3, executed when the
  selector is out of range) changes ECAS's own encoding, or only affects
  the preceding [CLBL](CLBL.md)/branch-table structure, is untested.

## Source Analysis & Reliability

Opcode (0x00C) confirmed primary-source: `XECAS BIT(16) INITIAL("00C")`
in `PASS1.PROCS/##DRIVER.xpl` — see [##DRIVER.xpl] in `STATUS.md`. No
[MSC-01847] (HAL-1971) analog identified under this name. Statement
syntax primary-sourced from [USA003087] §10.3 (PDF pp. 120–121). Full
behavioral description, operand-word structure, and machine-code
correlation confirmed directly against real compiled HALMAT this
session — mnemonic identification prompted by direct user suggestion
that DCAS/ECAS relate to `DO CASE`, given the naming pattern.
