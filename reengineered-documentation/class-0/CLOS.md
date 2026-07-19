# CLOS

**Mnemonic:** CLOS
**Opcode:** 0x030
**Confidence:** High

## Behavioral Description

Close statement. Emitted for a HAL/S `CLOSE <name>;` statement, closing the
named `PROGRAM`, `PROCEDURE`, `FUNCTION`, or `TASK` block. Carries one
operand, `SYT`-qualified, referencing the symbol-table entry of the block
being closed.

## Usage Context

Appears at the point in the HALMAT stream where the corresponding `CLOSE`
statement occurs (the last statement of a compilation unit in the simple
case). At the machine-code level it compiles to `SVC 0,=H'21'` (a
supervisor call, presumably the runtime's block-closing/cleanup service).

## Operand-Word Format (confirmed empirically)

One operand: `DATA`=symbol-table index of the block being closed,
`QUAL`=1=SYT. Confirmed by compiling `CLOSE FTEST;` (closing a `PROGRAM`
named `FTEST`, symbol-table index 1) with `HALSFC --parms="LSTALL"`,
which produced `HALMAT: 030(1),0,0` followed by operand `1(1),0,0` —
`DATA`=1 matching FTEST's own declaration index (`DCL 1 FTEST PROGRAM`
in `pass1.rpt`'s symbol table listing).

## Unresolved Questions

- Behavior when closing a `PROCEDURE`/`FUNCTION`/`TASK` rather than a
  `PROGRAM` is not yet tested — presumably identical (just a different
  symbol-table entry), but unconfirmed.

## Source Analysis & Reliability

Opcode (0x030) confirmed primary-source: `XCLOS BIT(16) INITIAL("030")` in
`PASS1.PROCS/##DRIVER.xpl` — see [##DRIVER.xpl] in `STATUS.md`. No
distinct HAL-1971 analog identified in [MSC-01847] — HAL 1971's `RTRN`
(0x030 in that scheme's own numbering) appears to serve the closing role
instead; see [RTRN](RTRN.md). Operand-word format and machine-code
correlation confirmed directly against real compiled HALMAT this session
(also previously glimpsed, unattributed, in an earlier session's
`CLOSE ARITH;` trace — see `STATUS.md`'s "Empirical Verification"
section).
