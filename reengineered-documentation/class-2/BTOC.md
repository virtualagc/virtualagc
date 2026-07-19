# BTOC

**Mnemonic:** BTOC
**Opcode:** 0x221
**Confidence:** High

## Behavioral Description

Bit string to character conversion. Converts a bit-string operand to its
character-string representation. Classed under Class 2 (character)
because HALMAT classes conversion operators by their *result* type.
Emitted for HAL/S's `CHARACTER(exp)` shaping/conversion function
([USA003087] §21.2, the character-result counterpart of the `BIT(...)`
family documented at [BTOB](../class-1/BTOB.md)) applied to a `BIT`
argument — compiles to a runtime-library call (`#QBTOC`).

## Usage Context

Emitted for the `CHARACTER(...)` shaping-function call when the argument
is `BIT`-typed. Selected via `PASS1.PROCS/ENDANYFC.xpl`'s "STRING
SHAPERS" dispatch: `ARG#=XBTOC(PSEUDO_TYPE(MAXPTR)-BIT_TYPE)`, where the
`BIT_TYPE` offset selects this case (element 0 of the array) — the exact
structural counterpart of [BTOB](../class-1/BTOB.md)'s dispatch, just
selecting the `XBTOC` array instead of `XBTOB` (i.e. `CHARACTER(...)`
vs. `BIT(...)` is selected earlier, by `FCN_LOC(FCN_LV)` case 0 vs. case
1 in the same `DO CASE`).

## Operand-Word Format (confirmed empirically)

One operand: `DATA`=symbol-table index of the source `BIT` argument,
`QUAL`=1=SYT. Confirmed by compiling `C1 = CHARACTER(B0);` (`B0` a
`BIT(16)`, `C1` a `CHARACTER(20)`) with `HALSFC --parms="LSTALL"`:

```
HALMAT: 221(1),0,0            <- BTOC
          2(1),0,0                <- B0, symbol index 2, QUAL=1=SYT
SRL 5,16 / LA 2,18(0,0) / LHI 6,16 / BAL 4,#QBTOC   <- runtime routine #QBTOC
                                                        performs the conversion
```

## Unresolved Questions

- Exact formatting rules (radix, field width, leading-zero/space padding)
  produced by `#QBTOC` are not decoded — would require either reading the
  runtime library source or observing the actual character output at
  runtime.

## Source Analysis & Reliability

Opcode (0x221) confirmed primary-source: element 0 of the `XBTOC(5)`
array in `PASS1.PROCS/##DRIVER.xpl` — see [##DRIVER.xpl] in `STATUS.md`.
Not present in [MSC-01847]. Found by grepping the full `PASS.REL32V0`
compiler source tree for every site referencing `XBTOC`, which led to
`PASS1.PROCS/ENDANYFC.xpl`'s `END_ANY_FCN` procedure's "STRING SHAPERS"
dispatch case, directly identifying the `CHARACTER(...)` shaping-function
construct ([USA003087] §21.2) as `BIT(...)`'s character-result
counterpart. Full behavioral description and operand-word structure
confirmed directly against real compiled HALMAT this session.
