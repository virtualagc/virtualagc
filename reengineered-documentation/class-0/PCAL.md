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
