# PMAR

**Mnemonic:** PMAR
**Opcode:** 0x05A
**Confidence:** High

## Behavioral Description

"Percent-macro argument." Specifies one argument in a `%macro`
invocation's argument list ([USA003087] §31.1) — one PMAR per argument,
between the opening [PMHD](PMHD.md) and closing [PMIN](PMIN.md).

## Usage Context

See [PMHD](PMHD.md) for the full bracketing construct and a worked
trace. One PMAR per argument, in source order.

## Operand-Word Format (confirmed empirically)

One operand: the argument's value. Confirmed by compiling `%SVC(5);`
with `HALSFC --parms="LSTALL"`, which produced `HALMAT: 05A(1),0,0`
followed by operand `1(5),6,0` — `DATA`=1 (literal-table index for the
value `5`), `QUAL`=5=LIT.

## Unresolved Questions

- Whether a non-literal (variable or expression) argument produces a
  `SYT`- or `VAC`-qualified operand instead was not tested — only a
  literal argument was compiled.
- The trailing sub-field (`6` in the trace above) is not decoded.

## Source Analysis & Reliability

Opcode (0x05A) confirmed primary-source: `XPMAR BIT(16) INITIAL("05A")`
in `PASS1.PROCS/##DRIVER.xpl` — see [##DRIVER.xpl] in `STATUS.md`. No
[MSC-01847] (HAL-1971) analog identified. Full behavioral description
and operand-word structure confirmed directly against real compiled
HALMAT this session — see [PMHD](PMHD.md)'s Source Analysis for the
context of this investigation.
