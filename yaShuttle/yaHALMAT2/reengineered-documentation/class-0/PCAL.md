# PCAL

**Mnemonic:** PCAL

**Opcode:** 0x01D

**Confidence:** High

## Behavioral Description

Procedure call header. Believed, by behavioral analogy with the
predecessor language's CALL instruction, to work as follows: operand
points to the procedure name in the symbol table; a count gives the
number of input arguments specified by following LIST-equivalent
instructions. HAL 1971's CALL additionally has a second form invoking a
runtime error-handling package (operand is an integer distinguishing the
error case) — whether HAL/S's PCAL retains this second form is unconfirmed.

## Usage Context

Confirmed this session: HAL/S does **not** use LIST/LSTE-equivalent
instructions or a CASS-equivalent marker for arguments — instead the
whole call, including its argument list, is bracketed by
[XXST](XXST.md)/[XXAR](XXAR.md)/[XXND](XXND.md), the same construct used
for `READ`/`WRITE` statements. PCAL itself sits where the header
instruction goes in that bracket: after the argument [XXAR](XXAR.md)s,
before the closing [XXND](XXND.md).

## Operand-Word Format (confirmed empirically)

One operand: `DATA`=symbol-table index of the called procedure,
`QUAL`=1=SYT (matching the index also carried by the opening
[XXST](XXST.md)). Confirmed by compiling `CALL TWO(I1) ASSIGN(I1);` with
`HALSFC --parms="LSTALL"` — see [XXST](XXST.md) for the full worked
trace.

**`MATRIX`/`VECTOR` parameters** (USA003087 Sec. 11.2, pp. 128/130,
"`DECLARE ARG1 MATRIX(4,4);`" as a procedure parameter; Sec. 11.4-11.5,
pp. 131-134, the transmission/conformance rules) — confirmed this
session by a user-reported bug (`CALL some_procedure(a_whole_matrix);`
previously failed with "SYT index N is a whole ARRAY/VECTOR/MATRIX
referenced outside an arrayed-paragraph replay"): a whole-`MATRIX`
argument's own [XXAR](XXAR.md) entry has exactly the same shape as
[WRIT](WRIT.md)'s whole-container `WRITE` argument (`QUAL`=1=SYT,
`TAG1`=the ordinary class number, not wrapped in any replay) — PCAL
itself carries nothing special for it. Per Sec. 11.4's transmission
model ("may be viewed as the assignment of the value of each
expression... to its corresponding input parameter"), yaHALMAT2 copies
the argument's elements into the parameter's own storage by value
(shape-conformance-checked against the parameter's declared
dimensions), not by reference — see [FCAL](FCAL.md)'s "Phase 3 finding"
for the confirmation that this doesn't disturb the ordinary contiguous-
SYT-slot parameter-binding pattern. **Precision conversion** (same
section: "precision conversion is allowed") is also implemented — a
SINGLE argument passed to a DOUBLE parameter (or vice versa) is
converted element-by-element to the *parameter's* own declared
precision, via the same exact bit-level rule already used for
STOS/MTOM/VTOV (USA00309 Sec. 8.2), confirmed both directions against a
real compile.

## Unresolved Questions

- Whether HAL 1971's second CALL form (invoking a runtime error-handling
  package) has any HAL/S analog is still unconfirmed — not exercised by
  the simple procedure-call case tested.
- Input vs. assign argument counts aren't carried on PCAL itself — they're
  implicit in the number and sub-flags of the preceding [XXAR](XXAR.md)
  instructions.

## Source Analysis & Reliability

Opcode (0x01D) and mnemonic PCAL are primary-sourced from [IR-60-5] A.2
(p. A-103) and independently confirmed by `XPCAL BIT(16) INITIAL("01D")`
in the HAL/S-FC compiler source itself (`PASS1.PROCS/##DRIVER.xpl` — see
[##DRIVER.xpl] in `STATUS.md`), which settles what was, earlier in this
project, treated as an unverified reading of the IR-60-5 index. No page
content for PCAL's own HAL/S behavioral description (target p. 61) is
present in the available partial copy.

The behavioral description is drawn from [MSC-01847] p. 2-14's
description of CALL (HAL 1971 opcode 0x029) — this part remains a
cross-language behavioral inference, not a primary-sourced HAL/S
description, so treat the *behavior* (not the opcode/mnemonic) with the
same caution as other HAL-1971-sourced entries.
