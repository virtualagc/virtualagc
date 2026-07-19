# IDLP

**Mnemonic:** IDLP
**Opcode:** 0x01A
**Confidence:** High

## Behavioral Description

Arrayness specifier — `STATIC`/default counterpart of [ADLP](ADLP.md).
Both are emitted by the compiler's `ICQ_ARRAYNESS_OUTPUT` routine
(`PASS1.PROCS/ICQARRA2.xpl`) to describe the shape of a multi-element
array being initialized with a **single uniform value** (`INITIAL(v)`/
`CONSTANT(v)` applied to `ARRAY(n)`, filling every element with `v`,
[USA003087] §4.3 — no `n#` repetition-factor prefix; contrast the
`n#value` form, which uses [STRI](../class-8/STRI.md)/
[SLRI](../class-8/SLRI.md)/[ELRI](../class-8/ELRI.md)/
[ETRI](../class-8/ETRI.md) instead). The choice between the two is a
direct `IF`/`ELSE` in the compiler source:

```
IF (SYT_FLAGS(ID_LOC) & AUTO_FLAG) ^= 0 THEN I = XADLP;
ELSE I = XIDLP;
```

`AUTO_FLAG` is set on a symbol specifically by the HAL/S `AUTOMATIC`
declaration attribute ([USA003087] §16.4) — confirmed by direct source
inspection of the declaration-attribute grammar in `SYNTHESI.xpl`. So:
**`AUTOMATIC`-declared arrays use [ADLP](ADLP.md); `STATIC` (the
default) arrays use IDLP.**

## Usage Context

Appears once per uniform-single-value array initialization of a
`STATIC`/default array, immediately before the per-element
[SINT](../class-8/SINT.md) (or other `xINT`) instructions, one per array
element, each followed by its own closing [DLPE](DLPE.md) — unlike the
`n#value` mechanism, where a single [ETRI](../class-8/ETRI.md) closes
the *whole* sequence, here [DLPE](DLPE.md) recurs once per element (no
separate whole-sequence closer was observed).

## Operand-Word Format (confirmed empirically)

One operand: `DATA`=the array's total element count, `QUAL`=6=IMD.
Confirmed by compiling `DECLARE ARRAY(6) SCALAR, V1 INITIAL(4.0);`
(default/`STATIC`) with `HALSFC --parms="LSTALL"`:

```
HALMAT: 01A(1),0,0            <- IDLP
          6(6),0,0               <- literal 6 (element count), QUAL=6=IMD
HALMAT: 8A1(2),6,0            <- SINT, element 1
          2(1),0,0               <- V1, symbol index 2, QUAL=1=SYT
          2(5),0,0               <- literal-table index 2 (the value 4.0), QUAL=5=LIT
HALMAT: 018(0),0,0            <- DLPE (closes this element)
HALMAT: 8A1(2),6,0            <- SINT, element 2 (identical operands)
          2(1),0,0
          2(5),0,0
HALMAT: 018(0),0,0            <- DLPE
... (repeated 4 more times, for elements 3–6, all byte-identical)
```

Recompiling with `AUTOMATIC` added to the declaration (`DECLARE
ARRAY(6) SCALAR AUTOMATIC, V1 INITIAL(4.0);`) produced the identical
shape with [ADLP](ADLP.md) (0x017) in place of IDLP — directly
confirming the `AUTOMATIC`/`STATIC` discriminant.

## Unresolved Questions

- Every `SINT` in the repeated sequence carries the *same* `SYT`
  operand (`V1`'s own base symbol, not an incrementing `OFFSET`) —
  unlike the `n#value`/[SLRI](../class-8/SLRI.md) mechanism, which uses
  `OFFSET`-qualified (`QUAL`=A) operands. How PASS2 resolves each
  repeated `SINT` to a *different* array element (presumably purely by
  position in the stream) is not decoded at the bit level.
- Whether a multi-dimensional array's element count is expressed as a
  single flattened total (as tested) or as one `IDLP` per dimension
  (paralleling how [ADLP](ADLP.md)'s general-loop role was found to
  flatten multi-dimensional arrayness into one loop) was not separately
  tested for the initialization role.

## Source Analysis & Reliability

Opcode (0x01A) confirmed primary-source: `XIDLP BIT(16) INITIAL("01A")`
in `PASS1.PROCS/##DRIVER.xpl` — see [##DRIVER.xpl] in `STATUS.md`.
Resolved this session by directly inspecting the compiler source
(`PASS1.PROCS/ICQARRA2.xpl`'s `ICQ_ARRAYNESS_OUTPUT` procedure, found by
searching the full `PASS.REL32V0` tree for every site referencing
`XIDLP`, not just its declaration) after four HAL/S-syntax hypotheses
had been tested and disproven across two sessions: single-copy structure
subscripting, range-of-copies structure assignment (with and without an
arrayed terminal), 2-D array arithmetic (a nested-loop hypothesis for
[ADLP](ADLP.md)/[DLPE](DLPE.md)), and direct arithmetic on an arrayed
structure terminal — all of which used [ADLP](ADLP.md) unconditionally
via the *other*, general-purpose arrayed-loop code path, not this
narrower initialization-specific one. Once the exact trigger condition
(`AUTOMATIC` vs. `STATIC` on a uniform-single-value array initializer)
was identified from the source, both forms were directly confirmed
against real compiled HALMAT. No [MSC-01847] (HAL-1971) analog
identified under this name.
