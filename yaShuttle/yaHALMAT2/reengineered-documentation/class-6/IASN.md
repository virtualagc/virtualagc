# IASN

**Mnemonic:** IASN

**Opcode:** 0x601

**Confidence:** High

## Behavioral Description

Integer assign. Assigns the integer operand specified by one operand to
the integer variable specified by another, following the general
two-operand assign pattern shared by every type's `xASN` operator
(compare [BASN](../class-1/BASN.md), [CASN](../class-2/CASN.md),
[MASN](../class-3/MASN.md), [VASN](../class-4/VASN.md),
[SASN](../class-5/SASN.md)).

## Usage Context

Emitted for HAL/S assignment statements whose receiver is an INTEGER
variable, and for loop-index updates in `DO FOR` constructs.

## Operand-Word Format (confirmed empirically)

Two operands: operand 1 = **source value**, `QUAL`=3=VAC (`DATA`=stream
position of the producing instruction) when the right-hand side is an
expression; operand 2 = **receiver**, `DATA`=its symbol-table index,
`QUAL`=1=SYT. **Order corrected in a later session** via a direct
`unHALMAT.py` binary read of `I3 = I1 + I2` (compiled with
`HALSFC --parms="LISTING2,LSTALL"`) — an earlier reading had receiver
first, source second; same pattern as [SASN](../class-5/SASN.md), see
that file for the general account of this correction.

## Usage Context (multiple assignment)

Also confirmed to serve HAL/S multiple-assignment statements
(`L1,L2,...Ln = R;`, [USA003087] §8.5) — no separate opcode exists for
this construct; it's the same `xASN` opcode for the receivers' shared
type, with `NUMOP` extended to `n+1` (the shared source-value operand,
then one operand per receiver, `QUAL`=1=SYT each — **order corrected in
a later session**, matching the base-case fix above). Confirmed by
compiling `S1, S2 = 5.0;` (both SCALAR receivers, whole-valued literal —
see below) and cross-checking with `unHALMAT.py`, which produced
`HALMAT: 601(3),0,0` with three operands, in true stream order:
`10(5),0,0` (the literal 5.0, source, first), `4(1),0,0` (S2), `3(1),0,0`
(S1) — source first, then receivers in reverse declaration order. This
rules out an earlier hypothesis that the still-unresolved
`PMHD`/`PMAR`/`PMIN` opcode family might relate to multiple assignment —
they don't; see those files for the current best guess (procedure/
function argument passing instead).

## Unresolved Questions

- None remaining for the base integer-assign case (INTEGER receiver from
  an expression or a literal both confirmed). **However**: IASN also
  fires for a SCALAR receiver assigned a literal whose *numeric value* is
  a whole number — not just integer-looking literals like `S1 = 4;`, but
  also decimal-point literals like `S1 = 1.0;` (confirmed in a follow-up
  test). See [SASN](../class-5/SASN.md)'s Unresolved Questions for the
  full detail. The generated machine code in that case still stores the
  value as a float (`LFLI`/`STE`), so this looks like PASS1 folding
  whole-valued literals into a shared representation whose type leaks
  through as IASN regardless of the receiver's actual declared type —
  **the compiler-side "why" is still not fully explained at the bit
  level, but the interpreter-side consequence (a SCALAR/SCALAR DOUBLE
  destination silently mistyped INTEGER when hit this way) is now
  corrected** — see "Confirmed Runtime Behavior" below.

## Confirmed Runtime Behavior

**Whole VECTOR/MATRIX receiver assigned literal 0 ("null matrix"/"null
vector"), fixed in a later session.** IASN's own whole-number-literal
leak (this file's Unresolved Questions above) turns out not to be
confined to SCALAR receivers: PASS1 folds a literal `0` assigned to a
whole `VECTOR`/`MATRIX` variable into a plain IASN too, with the
receiver's own SYT as IASN's second operand — no `VASN`/`MASN` and no
`ADLP`/`DLPE` wrapping. Confirmed via real compiled HALMAT (039-CORNERS.hal's
`AB = 0;`, `AB` a `VECTOR(2)`): `HALMAT #60 IASN`, operand 2 = Symbol AB
(VECTOR) directly. Previously fatal — `write_destination`'s whole-array
`QUAL_SYT` branch (`interp.c`) unconditionally required an active
arrayed-paragraph replay (`arrayed_index >= 0`), which this shape never
has. [USA003087] §8.2 rule 3 (MATRIX)/rule 3 (VECTOR): "The only
condition under which the R-type is integer is if it is the literal
value zero. The assignment then creates a null matrix" (VECTOR:
"...null vector") — any other integer/scalar value assigned this way is
illegal HAL/S rejected by the real compiler already (confirmed: `M3 =
1;` fails to compile), so it's never expected to reach the interpreter.
Fixed with a `syt_is_vector_or_matrix_shaped()` helper (deliberately
excludes `ARRAY`, which has no documented equivalent idiom) gating a
zero-fill loop ahead of the existing arrayed-paragraph-replay fail path.
`src/tests/hal/test_vecmat_null_assign.hal` is the regression fixture;
confirmed against a real `039-CORNERS.hal` run.

**Whole SCALAR/INTEGER ARRAY receiver, source a shaping-function
result, fixed in a later session.** `ARRAY` has no dedicated
whole-container assign opcode the way `VECTOR`/`MATRIX` get
`VASN`/`MASN` — assigning e.g. `SA = SCALAR(S1, S2);` (`SA` a `SCALAR
ARRAY(2)`) instead emits the *ordinary* single-value IASN/SASN, wrapped
in an [ADLP](../class-0/ADLP.md)/[DLPE](../class-0/DLPE.md) pair that
re-executes that same instruction once per array element (confirmed via
a debug trace: two real `write_destination` calls for the same
destination SYT, `arrayed_index` correctly cycling 0,1 each time — see
[ADLP](../class-0/ADLP.md)'s own note on why this looks like an *empty*
bracket in a linear HALMAT listing). The bug wasn't in this replay
mechanism, which already worked correctly, but on the read side:
`resolve_operand`'s `QUAL_VAC` case (`interp.c`) never checked
`slot->is_container` at all, so reading a shaping-function's VAC result
this way fell through to a stale-zero default instead of indexing the
container by `arrayed_index` — user-reported (`SA`/`IA` silently ended
up all zeros, no error). Fixed by adding that `is_container` branch,
mirroring `resolve_operand`'s own whole-array-during-replay handling of
a plain `QUAL_SYT` reference. `src/tests/hal/test_sshp_ishp.hal` is the
regression fixture.

**Whole-valued-literal leak into a SCALAR/SCALAR DOUBLE receiver,
corrected at the interpreter level.** User-reported
(`GOOGLE-PARALLAX.hal`): `DISTANCE`, a `SCALAR DOUBLE`, printed with
single-precision `WRITE` formatting instead of double, traced back to
`EOR = 93000000.0;` — a whole-valued literal assigned to a plain
`SCALAR DOUBLE` `EOR`, which this file's own Unresolved Questions above
already documented compiles to `IASN`, not `SASN`. `OP_IASN`'s handler
(`interp.c`) previously forced the resolved value to `RV_INTEGER`
unconditionally before the write, and `write_syt_entry`'s first-write
type inference trusted that blindly — so the destination got silently
mistyped `SYT_TYPE_INTEGER`, discarding its SCALAR-ness (and, for a
DOUBLE receiver, its precision) for the rest of the program. Fixed by
having `OP_IASN`/`OP_SASN` consult the symbol table for the destination's
*declared* class when it's a plain (`QUAL_SYT`) reference — the same
established technique as [TINT](../class-8/TINT.md)'s identical
per-field class correction and `bind_call_argument`'s parameter-
precision conversion — and letting the declared class override the
opcode's nominal one whenever they disagree (i.e. whenever this exact
IASN-into-SCALAR quirk fires). The same symbol-table lookup also
normalizes the resolved value's precision to the destination's declared
`SINGLE`/`DOUBLE` on *every* write, not just the first — needed because
neither a literal (always single-precision-encoded in the litfile) nor
an expression result is otherwise tagged to the *receiver's* declared
precision anywhere upstream (see [SASN](../class-5/SASN.md)'s own
"Confirmed Runtime Behavior" for that second, independent half of the
bug). Regression fixture: `src/tests/hal/test_scalar_double.hal`
(mirrors `EOR`/`ANGULAR_SHIFT`/`DISTANCE` from the real program);
confirmed to fail on pre-fix code reproducing the exact symptom (`EOR`
printed as a bare integer) and confirmed against a real
`GOOGLE-PARALLAX.hal` run (`DISTANCE` now prints with full double-
precision formatting).

## Source Analysis & Reliability

Opcode (0x601) confirmed primary-source: base of the `XXASN` array
(element 6) in `PASS1.PROCS/##DRIVER.xpl` — see [##DRIVER.xpl] in
`STATUS.md`. Matches [MSC-01847]'s HAL-1971 IASN opcode (0x601) exactly.
Operand-word format independently confirmed against real compiled HALMAT
in an earlier session; operand *order* (both base and multiple-assignment
cases) corrected in a later session via a direct `unHALMAT.py` binary
read (see Operand-Word Format above).

Behavioral description is a straightforward reading of "integer assign"
corroborated by [MSC-01847] §2.21 (Integer Operations); no verbatim
operand-word prose transcribed yet.
