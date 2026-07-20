# yaHALMAT (reference emulator) — Bugs Found During Phase 3

Found while implementing `yaHALMAT2` (this project's independent HALMAT
emulator, `src/`) and cross-checking its output against the existing
reference emulator, `yaHALMAT` (`../Halmat/emu/`, upstream:
https://github.com/Zaneham/Halmat). Per `Plan.md`, that repo has proven
impossible to push corrections to directly, so bugs found this way are
recorded here instead, for eventual manual reporting to its author.

Each item below was independently verified against a primary source
and/or a hand-derived expected result before being listed — not just
flagged because `yaHALMAT2` disagreed with it.

## 1. `DCAS` (`DO CASE`) selector is 0-indexed; should be 1-indexed

**File**: `emu/halmat_class0.c`, `POP_DCAS` case (~line 427).

The selector-to-case matching loop initializes `case_idx = 0` and walks
forward through `CLBL` entries comparing `case_idx == case_val` — i.e.
a selector value of `0` matches the *first* case, `1` the second, and
so on.

The primary source, `USA003087` ("HAL/S Programmer's Guide") §10.3,
states explicitly (rule 2): *"If its value is k (after rounding if
necessary), then the **kth** statement of the group is selected for
execution"* — and gives a fully worked example removing any ambiguity:

> `I = 3; DO CASE I; X=4; X=3; DO X=7; Y=3; END; X=1; X=0; END;`
> "Execution results in the **third** statement being scheduled for
> execution" (i.e. the `DO X=7; Y=3; END;` compound statement — X≡7,
> Y≡3 given).

Selection is 1-based: `k=3` selects the third statement, not the fourth.

**Repro**: compile
```
DECLARE INTEGER, SEL INITIAL(2), RESULT;
DO CASE SEL;
     RESULT = 10;
     RESULT = 20;
     RESULT = 30;
END;
```
(`Halmat/data/test_case.hal`). Per the primary source above, `SEL=2`
must select the *second* case (`RESULT=20`). `yaHALMAT` produces
`RESULT=30` (the third case, i.e. `case_idx` 2 under 0-based indexing);
`yaHALMAT2` produces `RESULT=20`, matching the spec.

**Collateral effect**: `Halmat/README.md`'s own documented "expected"
output for this fixture (`RESULT= 30`) was evidently captured from this
buggy emulator rather than derived from the language spec, so it isn't
usable as an independent check either — see this project's
`reengineered-documentation/class-0/DCAS.md` for the full writeup.

## 2. Range-form `DO FOR` produces wrong iteration counts when nested

**File**: `emu/halmat_class0.c`, `POP_DFOR`/`POP_EFOR` cases (~lines
222–380).

For a `DO WHILE` loop containing a range-form `DO FOR` in its body:
```
DECLARE INTEGER, I, J INITIAL(0), K INITIAL(0);
DO WHILE J < 100;
   DO FOR I = 1 TO 10;
      IF I > 5 THEN K = K + 1; ELSE K = K + 2;
   END;
   J = J + 10;
END;
WRITE(6) 'K=', K;
```
(`Halmat/data/test_nested.hal`), a correct execution has 10 outer-loop
passes (`J`=0,10,…,90, all `<100`) × 10 inner-loop cycles each (5 with
`K+=2`, 5 with `K+=1`) = `K = 10 × 15 = 150`.

`yaHALMAT` produces `K=40`. Running it with `--trace` shows only 30
total `DFOR`/`EFOR` events for the whole program — far fewer than the
~110 a correct 10-outer × 11-inner (1 `DFOR` + 10 `EFOR` per pass)
nesting would produce, indicating the inner loop is exiting early on
most outer-loop passes. `yaHALMAT2` produces `K=150`, matching the
hand-derived expected value (no interpretive ambiguity is involved here
— unlike finding 1, this is a plain arithmetic check).

**Not fully root-caused** — a `lv->declared`/`SYM_FLAGS`-based hypothesis
(that the loop variable's declared-type bookkeeping is wrong without an
explicit `--symtab` file) was tested and ruled out (`--symtab COMMON0.out`
made no difference). Left for the reference implementation's author to
diagnose further; see `reengineered-documentation/class-0/EFOR.md` for
this project's own notes.

## 3. `CTOI`/`CTOS` (CHARACTER→INTEGER/SCALAR conversion) are unconditional stubs

**File**: `emu/halmat_class6.c`, `POP_CTOI` case (~line 138);
`emu/halmat_class5.c`, `POP_CTOS` case (~line 183).

Both handlers ignore their operand entirely and always store a zero
result (`r.v.integer = 0;` / `r.v.scalar = 0.0;`), regardless of the
CHARACTER string's actual content:

```
DECLARE CHARACTER(20), C4 INITIAL('123');
DECLARE INTEGER, I2;
I2 = INTEGER(C4);
WRITE(6) 'I2=', I2;
```
(`src/tests/hal/test_char_conv.hal`). Per `USA00309` §6.1.2/§8.2 rule 16
(cited directly in this project's `class-6/CTOI.md`/`class-5/CTOS.md`),
a CHARACTER string in a standard input format (decimal digits, optional
sign, optional `E`/`B`/`H` exponent) converts to its parsed numeric
value. `yaHALMAT` produces `I2=0` for every input regardless of content;
`yaHALMAT2` produces `I2=123`, parsing the string as documented.

## 4. `STOC` (SCALAR→CHARACTER conversion) uses `%g`, not the documented fixed-width format

**File**: `emu/halmat_class2.c`, `POP_STOC` case (~line 60).

Uses `snprintf(..., "%g", a.v.scalar)` — a compact, variable-width C
`%g` rendering (e.g. `3.5`). `USA00309` §6.1.3 (cited by `class-2/
STOC.md`, and by `class-5/CTOS.md`'s sibling `SCALAR`-format rules)
specifies a fixed-width right-aligned scientific-notation field instead
(`sd.ddddddddE±dd`, single precision), the same format this project's
own `halmat_scalar_format()` already implements and cross-verified for
`WRITE` output (see the `SADD`/`SSUB` commit). `yaHALMAT2` reuses that
same formatter for `STOC`, producing `" 3.5000000E+00"` for the input
above rather than `yaHALMAT`'s `"3.5"`.

## 5. `BAND`/`BOR`/`BNOT`/`ITOB`/`BTOI` produce all-zero results for a real BIT program

**File**: `emu/halmat_class1.c` (`POP_BAND`/`POP_BOR`/`POP_BNOT`/
`POP_ITOB`), `emu/halmat_class6.c` (`POP_BTOI`).

```
DECLARE BIT(8), B1, B2, B3, B4;
DECLARE INTEGER, I1, I2, I3;
B1 = BIT(12);
B2 = BIT(10);
B3 = B1 AND B2;
B4 = B1 OR B2;
I1 = INTEGER(B3);
I2 = INTEGER(B4);
I3 = INTEGER(NOT B1);
```
(`src/tests/hal/test_bit.hal`). Hand-derived expected values: `12 AND
10` = `0b1100 & 0b1010` = `0b1000` = `8`; `12 OR 10` = `0b1110` = `14`;
`NOT 12` (32-bit one's complement) = `-13`. `yaHALMAT2` produces exactly
`I1=8 I2=14 I3=-13`. `yaHALMAT` produces `I1=0 I2=0 I3=-1` for the same
compiled binary.

**Not root-caused** — a source read of the four opcodes' handlers in
`halmat_class1.c`/`halmat_class6.c` shows correct-looking `&`/`|`/`~`
logic operating on `.v.bits`, so the defect is presumably in
`halmat_resolve_operand`'s handling of a `BASN`-assigned SYT entry's BIT
type/union tag rather than in the bitwise ops themselves, but this
wasn't traced further. Left for the reference implementation's author to
diagnose, per this project's stated approach to `yaHALMAT` bugs (see
finding 2's identical disposition).

## 6. `MADD`/`MMPR` (and likely the rest of Class 3/4) produce all-zero results even with `--symtab` supplied

**File**: `emu/halmat_class34.c`, `POP_MADD`/`POP_MSUB` case (~line 27)
and onward (the whole Class 3/4 arithmetic family shares the same
`a.rows`/`a.cols`/`v.matrix[]` shape dependency).

```
DECLARE A MATRIX(2, 2);
DECLARE B MATRIX(2, 2);
DECLARE C MATRIX(2, 2);
A(1,1)=1.0; A(1,2)=2.0; A(2,1)=3.0; A(2,2)=4.0;
B(1,1)=5.0; B(1,2)=6.0; B(2,1)=7.0; B(2,2)=8.0;
C = A + B;
C = A B;   -- matrix product, juxtaposition
```
(`src/tests/hal/test_matvec.hal`). Hand-derived expected values: `A+B`
= `[6,8,10,12]` (row-major); `A*B` = `[19,22,43,50]`. `yaHALMAT2`
produces exactly these values (verified against both `+` and
juxtaposition-multiply). `yaHALMAT --symtab COMMON0.out halmat.bin`
produces all zeros for every element of both results, even with the
compiler's own symbol table supplied via `--symtab` (which is where a
MATRIX's declared row/column counts live -- HALMAT itself carries no
size info on `MADD`/`MMPR`'s own operand words, confirmed empirically
this session).

**Not fully root-caused** — a source read of `POP_MADD` shows
`r.rows`/`r.cols` derived from the *resolved operands'* own `a.rows`/
`b.rows` fields (`r.rows = a.rows > b.rows ? a.rows : b.rows`), with the
elementwise loop bounded by `n = r.rows * r.cols`; if `halmat_resolve_
operand` (or the `--symtab`-driven SYT initialization feeding it) never
actually populates a SYT-backed MATRIX's `rows`/`cols` fields, `n` stays
`0` and the loop never executes, silently leaving `r` at its zero-
initialized default -- consistent with every observed symptom here, but
not traced into `halmat_resolve_operand` itself to confirm. Left for
the reference implementation's author to diagnose further, per this
project's established disposition for not-fully-root-caused findings
(see finding 2).

## 7. A broad swath of Class 0 opcodes are unconditional no-ops

**File**: `emu/halmat_class0.c`, the `case POP_SFST: case POP_SFND: ...`
block (~line 643) and the `case 0x034: /* WAIT */ ...` block immediately
after it (~line 655).

Roughly two dozen opcodes share a single `ADVANCE(); return HALMAT_OK;`
body -- they're recognized (don't hit the "unknown popcode" default)
but have no effect whatsoever: `SFST`/`SFND`/`SFAR`/`BFNC`/`LFNC`/
`TNEQ`/`TEQU`/`TASN`/`NASN` in the first block; `WAIT`/`SGNL`/`CANC`/
`TERM`/`PRIO`/`SCHD`/`ERON`/`ERSE`/`MSHP`/`VSHP`/`SSHP`/`ISHP`/`PMHD`/
`PMAR`/`PMIN`/`NNEQ`/`NEQU` in the second. Confirmed for `BFNC`:
```
R = SQRT(2.0);   -- expect 1.4142135...
```
(`src/tests/hal/test_bfnc.hal`, also exercising `ABS`/`SIGN`/`ROUND`/
`ABVAL`). `yaHALMAT2` produces the correct value for all five; `yaHALMAT`
produces `0.0` for every one of them (the no-op leaves the destination's
zero-initialized default in place). This isn't a single bug so much as
a documented scope boundary in the reference tool -- its real-time
task model (`WAIT`/`SCHD`/etc., already known absent per Plan.md's
original gap list) and its shaping-function/built-in-function/structure
machinery were apparently never implemented at all, rather than
implemented incorrectly. Listed here for completeness (this project's
independent `WAIT`/`SCHD`/`VSHP`/`BFNC` implementations were all
verified by hand-calculation rather than against this reference, for
exactly this reason) rather than as a narrow, fixable defect.

---

## 8. `STRI`/`SLRI`/`ELRI`/`ETRI` (repeated-`INITIAL()` group) are unconditional no-ops

**File**: `emu/halmat_class8.c`, the `case POP_STRI: case POP_SLRI: case
POP_ELRI: case POP_ETRI: break;` block (~line 90).

The whole repeated-initialize group for HAL/S's `n#value` `INITIAL()`
repetition-factor form (`class-8/STRI.md`, `SLRI.md`, `ELRI.md`,
`ETRI.md`) is recognized (doesn't hit the "unknown popcode" default) but
has no effect at all — the array element(s) it's meant to populate are
left at their zero-initialized default. Confirmed for:
```
DECLARE A ARRAY(3) SCALAR INITIAL(3#1.5);
```
(`src/tests/hal/test_stri.hal`). `yaHALMAT2` produces `1.5` for all
three elements; `yaHALMAT` produces `0.0` for all three. Same class of
gap as finding #7 (a real feature never implemented, not implemented
incorrectly) but in a different source file (`halmat_class8.c`, not
`halmat_class0.c`), so listed separately.

---

All eight findings were cross-checked against a primary source or
independent hand-calculation, not merely against `yaHALMAT2`'s own
output, consistent with this project's general sourcing discipline (see
`Plan.md`, `STATUS.md`).
