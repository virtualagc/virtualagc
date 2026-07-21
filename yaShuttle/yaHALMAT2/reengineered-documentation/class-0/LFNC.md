# LFNC

**Mnemonic:** LFNC

**Opcode:** 0x04B

**Confidence:** High

## Behavioral Description

"List function" built-in call — specifically the `MAX(α)`/`MIN(α)` built-in
functions ([USA003087] §7.6, "Miscellaneous Functions"), which reduce an
*array* argument to a single maximum/minimum value. Distinguished in the
compiler source (`PASS1.PROCS/ENDANYFC.xpl`, `END_ANY_FCN` procedure) as
a fourth, separate built-in-function dispatch category — `/* L-FUNC
BUILT-INS */` — alongside ordinary built-ins ([BFNC](BFNC.md), which
handles `SIN`/`COS`/`SQRT`/`ABS`/`ROUND`/`SIGN`/`EXP`/`LOG`/`TAN`/
`ABVAL`/`UNIT`/`LENGTH`/`TRIM`/`INVERSE`, confirmed this session), the
`VECTOR`/`MATRIX`/`INTEGER`/`SCALAR` shaping functions ([MSHP](MSHP.md)/
[VSHP](VSHP.md)/[SSHP](SSHP.md)/[ISHP](ISHP.md)), and the `BIT`/
`CHARACTER` shaping functions ([BTOB](../class-1/BTOB.md)/
[CTOB](../class-1/CTOB.md) etc.).

## Usage Context

Wrapped in the general shaping-function bracket
([SFST](SFST.md)/[SFAR](SFAR.md)/[SFND](SFND.md)), same as
[MSHP](MSHP.md)/[VSHP](VSHP.md)/etc. — with an [ADLP](ADLP.md)/
[DLPE](DLPE.md) array-loop bracket nested *inside* the shaping-function
bracket, since `MAX`/`MIN`'s argument is itself an array needing
arrayness handling before the reduction call.

## Operand-Word Format (confirmed empirically)

One operand: `DATA`=a per-function selector code, `QUAL`=6=IMD (`7` for
`MAX`, `8` for `MIN`, immediately consecutive — compare
[BFNC](BFNC.md)'s own, larger selector table). Confirmed by compiling
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

## Unresolved Questions

- Whether any other built-in function shares this "L-FUNC" dispatch
  category besides `MAX`/`MIN` was not exhaustively tested — every other
  single-argument built-in tried this session (12 functions across two
  test batches) used [BFNC](BFNC.md) instead; `MAX`/`MIN` were the only
  two found to differ, consistent with them being the only built-ins
  whose argument is a full array reduced to one value rather than an
  elementwise or whole-value operation.
- The 2-argument forms of `MAX`/`MIN` (if any — [USA003087] §7.6 shows
  only the single-array-argument form) were not tested.

## Source Analysis & Reliability

Opcode (0x04B) confirmed primary-source: `XLFNC BIT(16) INITIAL("04B")`
in `PASS1.PROCS/##DRIVER.xpl` — see [##DRIVER.xpl] in `STATUS.md`; not
present in [IR-60-5]'s partial index. No [MSC-01847] (HAL-1971) analog
identified. Resolved this session by abandoning syntax-guessing (a
`NONHAL`-linkage hypothesis had been tested and disproven in an earlier
session) in favor of grepping the full `PASS.REL32V0` compiler source
tree for every site referencing `XLFNC`, which led directly to
`ENDANYFC.xpl`'s `/* L-FUNC BUILT-INS */` branch — a documented,
explicitly-named category in the compiler's own source comments. Testing
every single-argument built-in function listed in [USA003087] §7.6
against real compiled HALMAT identified `MAX`/`MIN` as the two functions
using this opcode.
