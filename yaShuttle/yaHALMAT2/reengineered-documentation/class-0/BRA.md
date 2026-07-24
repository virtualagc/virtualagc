# BRA

**Mnemonic:** BRA

**Opcode:** 0x009

**Confidence:** High

## Behavioral Description

Unconditional branch. Specifies an unconditional branch to either a
[LBL](LBL.md) instruction carrying the same operand, or — in a special
usage restricted to the HALMAT 'DO FOR' construct — directly to the
HALMAT instruction indexed by the operand, when the operand's qualifier
indicates an absolute (rather than symbolic) label.

## Usage Context

Used both for simple unconditional branches (e.g. branching around a
false/true part of an IF statement, or looping back to the top of a DO
WHILE) and, in its "absolute label" form, for the increment-and-loop-back
edge of a compiled DO FOR statement group.

## Operand-Word Format (confirmed empirically)

One operand: `DATA`=an internal branch-target/label identifier (matching
the target [LBL](LBL.md)'s own operand), `QUAL`=2=GLI/INL. Confirmed by
compiling `IF I1 > 0 THEN S1 = 1.0; ELSE S1 = 2.0;` with
`HALSFC --parms="LSTALL"`, where BRA implements the true part's closing
"skip the ELSE part" branch — see [IFHD](IFHD.md) for the full worked
trace.

## Unresolved Questions

- HAL/S's opcode for BRA (0x009) differs from the HAL-1971 predecessor's
  (0x010); no significance to this particular renumbering has been
  identified.
- The "absolute label" form (used for `DO FOR`'s increment/loop-back
  edge, per earlier analysis) was not directly re-examined against the
  simple-target form confirmed this session — the two may differ in
  `QUAL`.

## Confirmed Runtime Behavior

**`EXIT loop-label;` also compiles to a plain BRA, found in a later
session via a user report.** Its target operand carries the exact same
INL bookkeeping-label number the enclosing `DO WHILE`/`UNTIL`'s
[DTST](DTST.md)/[ETST](ETST.md) pair both carry as their own sole
operand — confirmed by compiling `037-ROOTS.hal`'s `EXIT ROOTLOOP;`
(inside `ROOTLOOP: DO WHILE TRUE; ... END;`). This previously always
failed at runtime ("branch to undefined label N"): `precompute_labels()`
(`interp.c`) only registered targets from [LBL](LBL.md) instructions,
and DTST/ETST aren't LBL, so that shared bookkeeping-label number was
never registered anywhere BRA's own runtime lookup could find — despite
`precompute_loop_targets()` already fully understanding DTST/ETST
pairing, since it indexes exclusively by instruction *position*, never
by this label *number*. Fixed by having `precompute_labels()` also scan
for `ETST` and register its own label number, pointing to *ETST's
position + 1* (not ETST's own position, unlike the ordinary LBL case) —
see [ETST](ETST.md)'s own note on why. `src/tests/hal/test_exit_loop.hal`
is the regression fixture; see `STATUS.md`'s Class 0 section for the
fuller trace.

**Bare `REPEAT;` also compiles to a plain BRA, found in a later session
via a user report against `095-TAN_SUMS.hal`.** Unlike `EXIT` above,
its target is *not* the enclosing loop's own DTST/ETST label number —
it's that number **plus one**, traced to
`PASS1.PROCS/SYNTHESI.xpl`'s own `REPEAT` synthesis (`REPEATING:`),
which emits `DO_LOC(TEMP)+1` versus `EXIT`'s plain `DO_LOC(TEMP)`. No
[LBL](LBL.md) (or any other instruction) ever materializes this "+1"
value in the HALMAT stream; it's meant to be resolved structurally by
Pass 2's real code generator. Fixed the same way as `EXIT` above:
`precompute_labels()` now also registers `label+1` (alongside the plain
`label` it already registers for `ETST`), pointing it at
`etst_back_target[i]` — the loop's own per-cycle retest position
(`dtst_pos+1`), exactly matching `REPEAT`'s "abandon this cycle, retest
for the next one" semantics. See [ETST](ETST.md)'s own note for the
fuller account; `src/tests/hal/test_repeat.hal` is the regression
fixture.

## Source Analysis & Reliability

Opcode (0x009) and mnemonic are primary-sourced from [IR-60-5] A.2 (p.
A-103) and independently confirmed by `XBRA BIT(16) INITIAL("009")` in
the compiler source (`PASS1.PROCS/##DRIVER.xpl` — see [##DRIVER.xpl] in
`STATUS.md`). No page content for BRA's own HAL/S description (target p.
50) is present in the available partial copy. Operand-word format
confirmed directly against real compiled HALMAT this session.

Behavioral description drawn from [MSC-01847] p. 2-3 ("2.3 BRANCHES"),
describing the identically-named predecessor-language instruction (HAL
1971 opcode 0x010, differing from HAL/S's 0x009). See
[STRI](../class-8/STRI.md)'s Source Analysis section for the general basis
of this cross-language inference.
