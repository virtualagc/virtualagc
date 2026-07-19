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

## Operand-Word Format (confirmed empirically)

No operands, for the self form. Confirmed by compiling `TERMINATE;`
(no label — self-termination) as the last statement of a `TASK` block
with `HALSFC --parms="LSTALL"`, which produced `HALMAT: 037(0),0,0` with
no operand line, compiling to a single `SVC` (supervisor call).

## Unresolved Questions

- The named/dependent forms (`TERMINATE label;` and the multi-name list
  form `TERMINATE A,B,C;`, per [USA003087] §13.5) were not tested — only
  self-termination. Whether these add a `SYT` operand (as seen with
  [CANC](CANC.md)'s analogous self- vs. named-process distinction) is a
  reasonable guess but unconfirmed.

## Source Analysis & Reliability

Opcode (0x037) and mnemonic are primary-sourced from [IR-60-5] A.2 (p.
A-103); no page content for TERM's own HAL/S description (target p. 82) is
present in the available partial copy. Statement syntax primary-sourced
from [USA003087] §13.5 (PDF p. 168). Self-form operand-word structure
confirmed directly against real compiled HALMAT this session, as part of
a broader real-time-programming opcode sweep prompted by direct user
suggestion (`WAIT`/`SGNL`/`CANC`/`PRIO`/`SCHD`/`ERON`/`ERSE` relating to
HAL/S's real-time programming statements).

Behavioral description drawn from [MSC-01847] p. 2-16, describing the
identically-named predecessor-language instruction (HAL 1971 opcode 0x032,
differing from HAL/S's 0x037). See [STRI](../class-8/STRI.md)'s Source
Analysis section for the general basis of this cross-language inference.
