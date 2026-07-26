# LFNC

**Mnemonic:** LFNC

**Opcode:** 0x04B

**Confidence:** High

## Behavioral Description

"List function" built-in call — the five built-in functions that reduce
an *array* argument to a single value: `MAX(α)`/`MIN(α)`/`SUM(α)`/
`PROD(α)` ([USA003087] Appendix B, "ARRAY FUNCTIONS") and `SIZE(α)`
(Appendix B, "SIZE FUNCTION" — returns the array's element count rather
than folding its values, but shares this exact same dispatch mechanism).
Distinguished in the compiler source (`PASS1.PROCS/ENDANYFC.xpl`,
`END_ANY_FCN` procedure) as a fourth, separate built-in-function dispatch
category — `/* L-FUNC BUILT-INS */` — alongside ordinary built-ins
([BFNC](BFNC.md), which handles the other ~46 confirmed built-in
functions), the `VECTOR`/`MATRIX`/`INTEGER`/`SCALAR` shaping functions
([MSHP](MSHP.md)/[VSHP](VSHP.md)/[SSHP](SSHP.md)/[ISHP](ISHP.md)), and
the `BIT`/`CHARACTER` shaping functions ([BTOB](../class-1/BTOB.md)/
[CTOB](../class-1/CTOB.md) etc.).

## Usage Context

Wrapped in the general shaping-function bracket
([SFST](SFST.md)/[SFAR](SFAR.md)/[SFND](SFND.md)), same as
[MSHP](MSHP.md)/[VSHP](VSHP.md)/etc. — with an [ADLP](ADLP.md)/
[DLPE](DLPE.md) array-loop bracket nested *inside* the shaping-function
bracket, since each of these five functions' argument is itself an array
needing arrayness handling before the reduction call (or, for `SIZE`,
before reading off the resulting element count).

## Operand-Word Format (confirmed empirically)

One operand: `DATA`=a per-function selector code, `QUAL`=6=IMD — the
exact same numeric value as that function's position in [BFNC](BFNC.md)'s
own `BI_NAME`-position selector table, just dispatched through this
separate opcode instead of `BFNC`. Confirmed by compiling
`S2 = MAX(SA1); S2 = MIN(SA1);` (`SA1` an `ARRAY(3) SCALAR`) with
`HALSFC --parms="LSTALL"`:

```
S2 = MAX(SA1);
HALMAT: 045(0),1,0            <- SFST
HALMAT: 017(1),1,0            <- ADLP: arrayness of SA1
          3(6),0,0               <- literal 3 (element count), QUAL=6=IMD
HALMAT: 047(1),1,0            <- SFAR: the SA1 argument
         10(1),5,0               <- SA1, symbol index 10, QUAL=1=SYT
HALMAT: 018(0),1,0            <- DLPE (closes the ADLP loop)
HALMAT: 04B(1),1,0            <- LFNC
          7(6),5,0               <- literal 7 (MAX selector), QUAL=6=IMD
LA 2,SA1 / LFXI 5,5 / BAL 4,#QEMAX  <- runtime call to #QEMAX
HALMAT: 046(0),1,0            <- SFND

S2 = MIN(SA1);                  <- identical shape, selector 8, calls #QEMIN
```

`SUM`(14)/`PROD`(20) confirmed the same way in a later "batch" session,
via `--disasm` of `S2 = SUM(SA1); S2 = PROD(SA1);` compiled through this
project's own `yaHALMAT2 --disasm` rather than a fresh `HALSFC
--parms="LSTALL"` trace:

```
#23     0x04B LFNC  numop=1 tag=0x01 copt=0x0
        [0] data=0x000E(14) qual=IMD tag1=0x05 tag2=0x0   <- SUM selector
...
#37     0x04B LFNC  numop=1 tag=0x01 copt=0x0
        [0] data=0x0014(20) qual=IMD tag1=0x05 tag2=0x0   <- PROD selector
```

`SIZE`(23) confirmed the same session, but discovered rather than
deliberately probed: `141-VSUM.hal` (a real corpus program, `DO FOR
TEMPORARY N = 1 TO SIZE(V);`) unexpectedly hit "LFNC: unknown selector
23 (expected 7=MAX or 8=MIN)" — the interpreter's own pre-batch LFNC
handler only recognized 7/8 at the time. `SIZE` differs behaviorally
from the other four: it doesn't fold the array's *values* down to one
result, it just reports the count of elements the enclosing
[ADLP](ADLP.md)/[SFAR](SFAR.md) bracket already captured — so unlike
`MAX`/`MIN`/`SUM`/`PROD`, no reduction loop over the array's contents is
needed at all.

## yaHALMAT2 Implementation Notes (Maintenance phase)

- `SIZE`'s selector handler (`interp.c`) originally returned the flat
  scalar element count for *any* array argument, regardless of shape.
  This is correct for a plain flat `ARRAY` of `SCALAR`/`INTEGER`, but
  wrong for an array-of-`VECTOR`/`MATRIX` argument: [USA003087] Appendix
  B's own SIZE FUNCTION table specifies the "length of array" (the
  number of `VECTOR`/`MATRIX` elements), not the total count of
  underlying numbers. Surfaced by a real corpus program, `141-VSUM.hal`
  (`DO FOR TEMPORARY N = 1 TO SIZE(V);`, `V` an `ARRAY(3) VECTOR(3)`):
  `SIZE(V)` returned 9 (3 vectors × 3 components each) instead of 3,
  inflating the loop bound 3x and silently re-summing the same 3 vectors
  three times over. Fixed by having `SIZE` report `rows` (from
  `resolve_container`'s own `rows`/`cols` output) instead of the flat
  count whenever a 2-dimensional shape (`rows>0 && cols>0`) is reported —
  unambiguous in practice, since a genuinely 2-dimensional `ARRAY(r,c)`
  of plain `SCALAR` shares that same `rows`/`cols` encoding but isn't
  "one-dimensional," so calling `SIZE()` on one isn't valid HAL/S to
  begin with. A plain flat `ARRAY` (not array-of-`VECTOR`/`MATRIX`) is
  unaffected. `MAX`/`MIN`/`SUM`/`PROD` were reviewed for the same class
  of bug and found clean, since [USA003087] restricts those four to
  `INTEGER`/`SCALAR` array arguments only — no array-of-`VECTOR`/
  `MATRIX` case can reach them. Fixture: `test_vsum.hal`.

## Unresolved Questions

- The 2-argument forms of `MAX`/`MIN` (if any — [USA003087] Appendix B
  shows only the single-array-argument form for every function this
  opcode handles) were not tested.
- Whether any *further* built-in function beyond this file's five
  (`MAX`/`MIN`/`SUM`/`PROD`/`SIZE`) shares this "L-FUNC" dispatch
  category remains formally untested, though unlikely — Appendix B's
  "ARRAY FUNCTIONS"/"SIZE FUNCTION" sections list exactly these five as
  the complete set of array-argument-reducing built-ins, and every
  *other* built-in function in Appendix B (arithmetic/algebraic/vector-
  matrix/character/bit/miscellaneous) has now been confirmed to use
  [BFNC](BFNC.md) instead (see that file's own selector table, ~46
  entries across two sessions).

## Source Analysis & Reliability

Opcode (0x04B) confirmed primary-source: `XLFNC BIT(16) INITIAL("04B")`
in `PASS1.PROCS/##DRIVER.xpl` — see [##DRIVER.xpl] in `STATUS.md`; not
present in [IR-60-5]'s partial index. No [MSC-01847] (HAL-1971) analog
identified. Resolved in an earlier session by abandoning syntax-guessing
(a `NONHAL`-linkage hypothesis had been tested and disproven before
that) in favor of grepping the full `PASS.REL32V0` compiler source tree
for every site referencing `XLFNC`, which led directly to
`ENDANYFC.xpl`'s `/* L-FUNC BUILT-INS */` branch — a documented,
explicitly-named category in the compiler's own source comments. Testing
every single-argument built-in function listed in [USA003087] §7.6
against real compiled HALMAT identified `MAX`/`MIN` as the two functions
using this opcode at that time; a later "batch" session (prompted by a
real corpus program, `141-VSUM.hal`, unexpectedly hitting this opcode's
own "unknown selector" fail path for `SIZE`) found `SUM`/`PROD`/`SIZE`
belong here too, via two further direct `HALSFC` compile+`--disasm`
probes.
