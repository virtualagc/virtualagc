# TERM

**Mnemonic:** TERM

**Opcode:** 0x037

**Confidence:** High

## Behavioral Description

Terminate program execution. A fixed-format instruction (no operands)
indicating the termination of execution of a program — the HAL/S analog of
a HAL `TERMINATE` statement.

## Usage Context

Appears wherever a program's source text specifies termination of
execution — confirmed this session for the self-terminating form of the
real-time `TERMINATE;` statement ([USA003087] §13.5, PDF p. 168).

## Operand-Word Format (confirmed empirically, all forms)

**Self form** (`TERMINATE;`): no operands, opcode-line trailing field
`0`. Confirmed by compiling `TERMINATE;` (no label — self-termination)
as the last statement of a `TASK` block, which produced `HALMAT:
037(0),0,0` with no operand line, compiling to a single `SVC`
(supervisor call).

**Named/list forms** (`TERMINATE label;` / `TERMINATE label1, label2,
...;`, per [USA003087] §13.5) — **confirmed this session**: one `SYT`
operand per named process, opcode-line trailing field `1` (same
self-vs-named discriminant pattern as [CANC](CANC.md)). Confirmed by
compiling `TERMINATE TASKA;` and `TERMINATE TASKA, TASKB;` with
`HALSFC --parms="LISTING2,LSTALL"`, cross-checked directly with
`unHALMAT.py`:

```
TERMINATE TASKA;
HALMAT: 037(1),1,0        <- TERM, trailing field 1 = named form
          2(1),0,0           <- op: TASKA, symbol index 2, QUAL=1=SYT

TERMINATE TASKA, TASKB;
HALMAT: 037(2),1,0        <- TERM, NUMOP extended by one per name
          2(1),0,0           <- op 1: TASKA, symbol index 2, QUAL=1=SYT
          3(1),0,0           <- op 2: TASKB, symbol index 3, QUAL=1=SYT
```

## Unresolved Questions

- None remaining for this instruction — self, single-named, and
  multi-name list forms are all confirmed.

## Source Analysis & Reliability

Opcode (0x037) and mnemonic are primary-sourced from [IR-60-5] A.2 (p.
A-103); no page content for TERM's own HAL/S description (target p. 82) is
present in the available partial copy. Statement syntax primary-sourced
from [USA003087] §13.5 (PDF p. 168). Self-form operand-word structure
confirmed directly against real compiled HALMAT in an earlier session, as
part of a broader real-time-programming opcode sweep prompted by direct
user suggestion (`WAIT`/`SGNL`/`CANC`/`PRIO`/`SCHD`/`ERON`/`ERSE` relating
to HAL/S's real-time programming statements). Named/list forms confirmed
in a later session via a direct `unHALMAT.py` binary read.

Behavioral description drawn from [MSC-01847] p. 2-16, describing the
identically-named predecessor-language instruction (HAL 1971 opcode 0x032,
differing from HAL/S's 0x037). See [STRI](../class-8/STRI.md)'s Source
Analysis section for the general basis of this cross-language inference.
