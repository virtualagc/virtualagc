# SASN

**Mnemonic:** SASN

**Opcode:** 0x501

**Confidence:** High

## Behavioral Description

Scalar assign. Assigns the scalar (floating-point) operand specified by
one operand to the scalar variable specified by another, following the
general two-operand assign pattern shared by every type's `xASN` operator
(compare [BASN](../class-1/BASN.md), [CASN](../class-2/CASN.md),
[MASN](../class-3/MASN.md), [VASN](../class-4/VASN.md),
[IASN](../class-6/IASN.md)).

## Usage Context

Emitted for HAL/S assignment statements whose receiver is a SCALAR
variable — the single most common assignment type in typical HAL/S code.

## Operand-Word Format (confirmed empirically)

Two operands: operand 1 = **source value**, typically `QUAL`=3=VAC
(`DATA`=the stream position of the instruction that produced the value
being assigned) when the right-hand side is itself an expression, or
`QUAL`=6=IMD / 5=LIT for a direct literal; operand 2 = **receiver**,
`DATA`=its symbol-table index, `QUAL`=1=SYT. **Order corrected in a
later session**: an earlier reading (from `pass2.rpt`'s `LSTALL` text
report) had this backwards (receiver first, source second) — the same
report print-ordering artifact already found for [READ](../class-0/READ.md)/
[DFOR](../class-0/DFOR.md)/[SCHD](../class-0/SCHD.md) (see
[XXST](../class-0/XXST.md)). A direct `unHALMAT.py` binary read of
`S3 = S1 + S2` (compiled with `HALSFC --parms="LISTING2,LSTALL"`) settles
it unambiguously: the VAC operand referencing the producing `SADD`
instruction comes first, `S3`'s `SYT` operand second.

## Unresolved Questions

- None remaining for the base scalar-assign case, **except**: a SCALAR
  receiver assigned a literal whose *numeric value* is a whole number
  (e.g. `S1 = 4;` **or** `S1 = 1.0;` — the presence/absence of a decimal
  point in the source text turns out not to matter) does **not** produce
  SASN — it produces [IASN](../class-6/IASN.md) (0x601) instead, even
  though the generated machine code correctly stores the value as a
  float (`LFLI`/`STE`). Confirmed across two separate test sessions:
  `S1 = 4;` and `S1 = 1.0;`/`S1 = 2.0;`/(multiple-assignment) `S1, S2 =
  5.0;` all → 0x601, while `S1 = 4.5;` and `S1 = S2;` → 0x501 as
  expected. This means the assign-opcode class is apparently selected by
  whether the literal's *value* is integral, not by the receiver's
  declared type or the literal's written form — presumably PASS1 folds
  whole-valued literals into a shared integer-literal representation
  before the type-specific assign opcode is chosen, and that shared
  representation's own type leaks through as IASN regardless of the
  receiver. See [IASN](../class-6/IASN.md)'s Unresolved Questions for
  the same note from the other side.

## Confirmed Runtime Behavior

**Whole SCALAR ARRAY receiver, source a shaping-function result, fixed
in a later session.** `ARRAY` has no dedicated whole-container assign
opcode the way `VECTOR`/`MATRIX` get `VASN`/`MASN` — assigning e.g.
`SA = SCALAR(S1, S2);` (`SA` a `SCALAR ARRAY(2)`) instead emits the
*ordinary* single-value SASN, wrapped in an
[ADLP](../class-0/ADLP.md)/[DLPE](../class-0/DLPE.md) pair that
re-executes that same instruction once per array element (confirmed via
a debug trace: two real `write_destination` calls for the same
destination SYT, `arrayed_index` correctly cycling 0,1 each time — see
[ADLP](../class-0/ADLP.md)'s own note on why this looks like an *empty*
bracket in a linear HALMAT listing, not a real one). The bug wasn't in
this replay mechanism, which already worked correctly, but on the read
side: `resolve_operand`'s `QUAL_VAC` case (`interp.c`) never checked for
a whole-container VAC slot, silently defaulting a shaping-function
result read this way to zero instead of indexing it by `arrayed_index`
— user-reported (`SA` ended up all zeros instead of the real values, no
error). Fixed by adding that `is_container` branch, mirroring
`resolve_operand`'s own whole-array-during-replay handling of a plain
`QUAL_SYT` reference. The identical fix applies to the INTEGER-receiver
case — see [IASN](../class-6/IASN.md), whose own "Confirmed Runtime
Behavior" section has the fuller writeup (both opcodes share the exact
same `resolve_operand` code path). `src/tests/hal/test_sshp_ishp.hal` is
the regression fixture.

**Precision normalization to the destination's declared SINGLE/DOUBLE,
fixed in a later session.** User-reported (`GOOGLE-PARALLAX.hal`):
`DISTANCE`, a `SCALAR DOUBLE`, printed with single-precision `WRITE`
formatting. Root cause had two independent halves — this file covers the
second: even via an *ordinary* SASN (a non-whole-valued literal, e.g.
`ANGULAR_SHIFT = 0.5;`, which correctly compiles to SASN per this file's
own Unresolved Questions above, not the IASN quirk), the literal's own
litfile-encoded precision (always single — `literal.c` has no
per-context double form) was never widened to match a DOUBLE-declared
receiver; assignment performed no automatic precision conversion at all,
so a `SCALAR DOUBLE` variable assigned a plain literal stayed single-
precision-tagged indefinitely. (Once a value *is* correctly tagged
double, arithmetic itself already propagates precision correctly —
`halmat_scalar_add`/etc.'s `dbl = a.double_precision || b.double_precision`
— so this was purely an assignment-time gap, not an arithmetic one; see
[IASN](../class-6/IASN.md)'s own "Confirmed Runtime Behavior" for the
first half of the same bug, the whole-valued-literal type leak.) Fixed
together with that first half: `OP_IASN`/`OP_SASN` now looks up the
destination's declared class/precision via the symbol table
(`HALMAT_SYM_FLAG_SINGLE`/`_DOUBLE`, `scale_precision()` — the same
technique [TINT](../class-8/TINT.md) and `bind_call_argument` already
use) and normalizes the resolved value's precision to the declared one
on *every* write to a plain (`QUAL_SYT`) SCALAR destination, not just
the first. Regression fixture: `src/tests/hal/test_scalar_double.hal`;
confirmed to fail on pre-fix code (`ANGULAR_SHIFT` single-precision-
formatted despite its DOUBLE declaration) and confirmed against a real
`GOOGLE-PARALLAX.hal` run (the computed `DISTANCE` value itself also
shifts slightly in its low digits versus the old single-precision-
computed result, as expected once the whole chain is genuinely computed
in double).

## Source Analysis & Reliability

Opcode (0x501) confirmed primary-source: base of the `XSASN`/array
declaration group in `PASS1.PROCS/##DRIVER.xpl` — see [##DRIVER.xpl] in
`STATUS.md`. Matches [MSC-01847]'s HAL-1971 SASN opcode (0x501) exactly.
Operand-word format independently confirmed against real compiled HALMAT
in an earlier session; operand *order* corrected in a later session via
a direct `unHALMAT.py` binary read (see Operand-Word Format above).

Behavioral description is a straightforward reading of "scalar assign"
corroborated by [MSC-01847] §2.20 (Scalar Operations); no verbatim
operand-word prose transcribed yet.
