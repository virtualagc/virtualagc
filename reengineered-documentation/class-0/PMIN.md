# PMIN

**Mnemonic:** PMIN

**Opcode:** 0x05B

**Confidence:** High

## Behavioral Description

"Percent-macro instruction end." Closes the `%macro` invocation opened
by [PMHD](PMHD.md) ([USA003087] §31.1), following its [PMAR](PMAR.md)
argument list (if any).

## Usage Context

Always the last instruction of a `%macro` invocation.

## Operand-Word Format (confirmed empirically)

No operands; the opcode line's own trailing header field repeats the
same macro-table-index value carried by the opening [PMHD](PMHD.md)
(`2` for `%SVC`, matching [PMHD](PMHD.md)'s own trace) — the same
"shared construct identifier" pattern seen elsewhere (e.g.
[DCAS](DCAS.md)/[CLBL](CLBL.md)/[ECAS](ECAS.md) for `DO CASE`). Confirmed
by compiling `%SVC(5);` with `HALSFC --parms="LSTALL"` — see
[PMHD](PMHD.md) for the full worked trace.

## Unresolved Questions

- None for the base case tested.

## Source Analysis & Reliability

Opcode (0x05B) confirmed primary-source: `XPMIN BIT(16) INITIAL("05B")`
in `PASS1.PROCS/##DRIVER.xpl` — see [##DRIVER.xpl] in `STATUS.md`. No
[MSC-01847] (HAL-1971) analog identified. Full behavioral description
and operand-word structure confirmed directly against real compiled
HALMAT this session — see [PMHD](PMHD.md)'s Source Analysis for the
context of this investigation.
