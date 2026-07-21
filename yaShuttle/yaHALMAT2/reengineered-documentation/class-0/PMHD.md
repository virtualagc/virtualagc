# PMHD

**Mnemonic:** PMHD

**Opcode:** 0x059

**Confidence:** High

## Behavioral Description

"Percent-macro header." Marks the start of a HAL/S `%macro` invocation
([USA003087] §31.1, "typeless `%macro`s") — a small, fixed set of
compiler-predefined utility macros (confirmed in the compiler source,
`PASS1.PROCS/##DRIVER.xpl`'s `PCNAME` table, as `%NAMEBIAS`, `%SVC`,
`%NAMECOPY`, `%COPY`, `%SVCI`, `%NAMEADD` for this build) invoked as
`%macro-name;` or `%macro-name(arg1, arg2, ...);`. Distinct from ordinary
`REPLACE` macros (§5, §29.1 — pure compile-time text substitution) —
`%macro`s instead compile to their own dedicated HALMAT construct.

## Usage Context

Always the first instruction of a `%macro` invocation, followed by one
[PMAR](PMAR.md) per argument (if any), then a closing [PMIN](PMIN.md).

## Operand-Word Format (confirmed empirically)

No operands; the opcode line's own trailing header field carries the
invoked macro's index into the compiler's internal `PCNAME` table (`2`
for `%SVC`, in the trace below). Confirmed by compiling `%SVC(5);` with
`HALSFC --parms="LSTALL"`:

```
HALMAT: 059(0),2,0            <- PMHD, trailing field 2 = %SVC's table index
HALMAT: 05A(1),0,0            <- PMAR (see PMAR.md): the argument
          1(5),6,0
HALMAT: 05B(0),2,0            <- PMIN (see PMIN.md), trailing field 2 (matches PMHD)
LFXI 5,7 / STH 5,18(0,0) / SVC 0,18(0,0)   <- %SVC literally emits a raw SVC machine instruction
```

## Unresolved Questions

- The full table-index-to-macro-name mapping (only `2`=`%SVC` confirmed)
  is not mapped for the other five predefined names.
- The no-argument form (`%macro-name;`, e.g. a hypothetical 0-argument
  macro) was not tested — all six predefined names in this build take
  1–3 arguments per the `PCARG#` table, so a true no-argument invocation
  may not be constructible with the currently-known macro set.

## Source Analysis & Reliability

Opcode (0x059) confirmed primary-source: `XPMHD BIT(16) INITIAL("059")`
in `PASS1.PROCS/##DRIVER.xpl` — see [##DRIVER.xpl] in `STATUS.md`; not
present in [IR-60-5]'s partial index. No [MSC-01847] (HAL-1971) analog
identified. Resolved this session by grepping the full `PASS.REL32V0`
compiler source tree for every site referencing `XPMHD`, which led
directly to `SYNTHESI.xpl`'s grammar-rule comments (`<% MACRO HEAD> ::=
<% MACRO NAME> (`, etc.) — the exact `%macro`-call construct, and to
`##DRIVER.xpl`'s `PCNAME` table giving the concrete predefined names
available to test. Full behavioral description and operand-word
structure confirmed directly against real compiled HALMAT this session.
