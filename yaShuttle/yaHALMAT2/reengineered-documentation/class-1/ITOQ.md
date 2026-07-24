# ITOQ

**Mnemonic:** ITOQ

**Opcode:** 0x1C2

**Confidence:** High

## Behavioral Description

`SUBBIT` pseudo-conversion, integer argument. Implements HAL/S's `SUBBIT`
pseudo-conversion function ([USA003087] §21.5) for an `INTEGER` argument:
`SUBBITsubscript(argument)` — a way of transferring a value between data
types *without* conversion, treating the argument's raw bit pattern as a
bit string ("old type → bit string → new type"). Used in **both**
reference context (`SUBBIT` reads the argument as if it were a bit
string) and assignment context (`SUBBIT` writes into the argument as if
it were a bit string) — HAL/S's controlled way of circumventing ordinary
type-compatibility rules.

One of a 4-member family sharing the `XBTOQ` array alongside
[BTOQ](BTOQ.md) (bit string), [CTOQ](CTOQ.md) (character), and
[STOQ](STOQ.md) (scalar) — see those files. Classed under Class 1 (bit)
because, like the parallel `XBTOB`/"convert to bit" family, HALMAT groups
this family by its bit-string intermediary, not by argument type.

## Usage Context

In **reference context** (`SUBBIT(I1)` used as a value, e.g. on an
assignment's right-hand side), ITOQ's operand is the argument being
read, and its result (via a following [BASN](BASN.md)/etc. consuming a
`VAC` reference) supplies the *source* value. In **assignment context**
(`SUBBIT(I1) = ...;`), ITOQ's operand is the argument being written into,
and its result instead supplies the *receiver* of the following assign
instruction — the two roles are distinguished by a trailing header flag
(see Operand-Word Format).

## Operand-Word Format (confirmed empirically)

One operand: `DATA`=symbol-table index of the argument, `QUAL`=1=SYT.
The opcode line's trailing header field is `0` for reference context,
`1` for assignment context. Confirmed by compiling both forms with
`HALSFC --parms="LSTALL"`:

```
B1 = SUBBIT(I1);               <- reference context
HALMAT: 1C2(1),0,0
          2(1),0,0               <- I1, symbol index 2, QUAL=1=SYT
HALMAT: 101(2),0,0            <- BASN: B1 = <ITOQ's VAC result>
LH 5,I1 / STH 5,B1               <- I1's raw bit pattern copied directly into B1

SUBBIT(I1) = BIN'1111000011110000';   <- assignment context
HALMAT: 1C2(1),1,0
          2(1),0,0               <- I1, symbol index 2, QUAL=1=SYT
HALMAT: 101(2),0,0            <- BASN: <ITOQ's VAC result> = the literal
LHI 5,-3856 / STH 5,I1           <- the literal's bit pattern copied directly into I1
```

## Confirmed Runtime Behavior

**Assignment context (`TAG`=1) implemented (Maintenance phase).**
Reference context (`TAG`=0) already worked; `SUBBIT(x) = ...;` itself
previously failed loudly with no runtime implementation at all. The
compiled trace above already showed the full shape needed: the `xTOQ`
opcode's own `VAC` result supplies the *receiver* for a following
[BASN](BASN.md), not a value — since `SUBBIT` always routes its actual
write through a bit-string intermediary, `BASN` is the only assign
opcode it ever chains into, regardless of the receiver's real
underlying type. Implemented with a new `is_subbit_ref`/
`subbit_target_syt` field pair on the `VAC` slot (`halmat_vac_slot_t`,
`state.h`), set by the `TAG`=1 branch and consumed by
`write_destination`'s `QUAL_VAC` case: the assigned bit pattern is
written directly into the target's own storage, reinterpreted per its
*declared* type. Only `SYT_TYPE_INTEGER` and `SYT_TYPE_BIT` have a
confirmed, lossless raw-bit mapping in this interpreter (`BIT`
trivially; `INTEGER` via the same reinterpret-cast the reference-
context branch already uses in the opposite direction) — `SCALAR`/
`CHARACTER` targets still fail loudly, no hardware byte-layout modeled
for them. One wrinkle found empirically: `SUBBIT` deliberately bypasses
the ordinary "first write infers the type" mechanism this interpreter
otherwise uses for an untyped `SYT` entry (it's writing bits into an
*already, if only declaratively, typed* variable's storage, not a value
whose kind should dictate the type) — so a target never written before
reaching `SUBBIT` needs its real declared type pulled from the symbol
table (`hal_class`) instead. Fixture: `src/tests/hal/test_subbit_assign.hal`
(the exact `SUBBIT(I1) = BIN'1111000011110000';` case from the trace
above, on a never-written `INTEGER`, plus a `BIT`-target case).

## Unresolved Questions

- The subscripted forms (`SUBBITn TO m(argument)`, selecting a bit
  window narrower than the full argument) were not tested — only the
  no-subscript (full-width) form.
- Whether a `DOUBLE`-precision `INTEGER` argument changes the encoding
  (per §21.5's N=32-vs-16 distinction by precision) was not tested —
  only `SINGLE` was compiled.

## Source Analysis & Reliability

Opcode (0x1C2) confirmed primary-source: `XBTOQ(5)` array element 5 in
`PASS1.PROCS/##DRIVER.xpl` — see [##DRIVER.xpl] in `STATUS.md`. No
[MSC-01847] (HAL-1971) analog identified. Resolved this session by
grepping the full `PASS.REL32V0` compiler source tree for every site
referencing `XBTOQ`, which led to `PASS1.PROCS/ENDSUBBI.xpl`'s
`END_SUBBIT_FCN` procedure — its name directly identifying the `SUBBIT`
construct, confirmed against [USA003087] §21.5 (PDF pp. 265–267).
Statement syntax and full behavioral description (both reference and
assignment context) confirmed directly against real compiled HALMAT
this session — this was the fourth hypothesis tried for this opcode
family across two sessions (after bit-in-conditional-context, subscripted
`BIT(...)` conversion results, and — implicitly — general boolean
coercion had all been disproven).
