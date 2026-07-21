# DFOR

**Mnemonic:** DFOR

**Opcode:** 0x010

**Confidence:** High

## Behavioral Description

"Do for" — header for a `DO FOR var = initial TO final BY increment;`
range-form loop ([USA003087] §10.2). Establishes the control variable,
its initial/final/increment values, and generates the initial "skip the
first re-test" branch straight into the loop body (since the range form
always executes at least its first in-range cycle without a separate
pre-test). Also used, in a reduced form, for the header of the
alternate/list form `DO FOR var = exp1, exp2, ...expn;` — see
[AFOR](AFOR.md), which carries the per-value data for that form.

## Usage Context

Emitted for the opening of any `DO FOR` group, in both its range and list
forms (the two forms are distinguished by DFOR's own operand count/shape
and by whether [AFOR](AFOR.md) instructions follow — see Operand-Word
Format). Closed by [EFOR](EFOR.md). If the statement carries a
supplementary `WHILE`/`UNTIL` clause, [CFOR](CFOR.md) appears once per
cycle, immediately before the loop body, consuming that clause's
condition.

## Operand-Word Format (confirmed empirically)

**Corrected this session**: operand order was previously misread from
`pass2.rpt`'s `LSTALL` text report, which (as with [READ](READ.md)'s
device-number bug — see [XXST](XXST.md)) doesn't reliably reflect true
stream order for multi-operand instructions. Cross-checking the same
constructs with a direct `unHALMAT.py` binary read (compiled with
`HALSFC --parms="LISTING2,LSTALL"`) gives the corrected, and
semantically much more sensible, order: **construct id first, control
variable second, then the range/list literals in left-to-right source
order** (`initial`, `final`, `[increment]`) — reading naturally as
"(loop-id, var, from, to, [by])" against the `DO FOR var = initial TO
final BY increment;` source syntax.

**Range form, default increment** (`DO FOR I1 = 1 TO 10;`) — `NUMOP`-ish
field `(4)`, 4 real operands:
```
HALMAT #100 (0x010, DFOR), numop-ish field 1
  op 1: construct id (bookkeeping label #19), QUAL=2=INL
  op 2: I1, QUAL=1=SYT (control variable)
  op 3: literal 1.0, QUAL=5=LIT (initial value)
  op 4: literal 10.0, QUAL=5=LIT (final value)
```

**Range form, explicit `BY`** (`DO FOR I1 = 1 TO 10 BY 2;`) — `NUMOP`-ish
field `(5)`, 5 real operands (an extra literal for the increment):
```
HALMAT #121 (0x010, DFOR), numop-ish field 2
  op 1: construct id (bookkeeping label #24), QUAL=2=INL
  op 2: I1, QUAL=1=SYT (control variable)
  op 3: literal 1.0, QUAL=5=LIT (initial value)
  op 4: literal 10.0, QUAL=5=LIT (final value)
  op 5: literal 2.0, QUAL=5=LIT (increment)
```
(the trailing header field changes `1`→`2`, plausibly a count of extra
literal operands beyond the implicit-increment case, rather than a simple
flag — this part of the previous reading still holds).

**List form** (`DO FOR I1 = 1, 2, 3;`) — `NUMOP`-ish field `(2)`, only 2
operands, no literal operands at all (each value is carried separately by
its own [AFOR](AFOR.md) instruction):
```
HALMAT #14 (0x010, DFOR), numop-ish field 0
  op 1: construct id (bookkeeping label #1), QUAL=2=INL
  op 2: I1, QUAL=1=SYT (control variable)
```

(`unHALMAT.py` instruction/label numbers shown above are from the actual
verification runs, not renumbered for presentation — see Source Analysis
for the exact test programs.)

## Unresolved Questions

- The exact meaning of the trailing header field's numeric value (`1,0`
  vs. `2,0` vs. `0,0` across the three variants above) is not decoded at
  the bit level — treated as an opaque count/flag matching observed
  shape.
- Negative increments (`BY -2`) were tested and produced the same DFOR/
  EFOR shape as the positive-`BY` case (not separately itemized above) —
  no distinct encoding found for the sign.
- The `WHILE`/`UNTIL` control-variable-type rounding rules ([USA003087]
  §10.2, "rounding occurs during assignment... if the control variable is
  integer and the range expressions are scalar") were not tested — only
  an all-INTEGER case was compiled.

## Source Analysis & Reliability

Opcode (0x010) confirmed primary-source: `XDFOR BIT(16) INITIAL("010")`
in `PASS1.PROCS/##DRIVER.xpl` — see [##DRIVER.xpl] in `STATUS.md`. No
[MSC-01847] (HAL-1971) analog identified under this name. Statement
syntax primary-sourced from [USA003087] §10.2 (PDF pp. 113–121). Full
behavioral description and machine-code correlation confirmed directly
against real compiled HALMAT in an earlier session; the operand
*order* was corrected in a later session after cross-checking the same
constructs with `unHALMAT.py`'s direct binary read (see Operand-Word
Format above) — `pass2.rpt`'s text report is not reliable for
multi-operand instruction ordering, the same lesson learned for
[READ](READ.md)/[XXST](XXST.md).
