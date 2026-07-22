# SINT

**Mnemonic:** SINT

**Opcode:** 0x8A1

**Confidence:** High

## Behavioral Description

Scalar initialize. Initializes the specified scalar operand with a literal
value.

In the predecessor language HAL (1971), the analogous instruction (there
opcode 0x8A1) has two forms parallel to [BINT](BINT.md) (direct
symbol-table variable, or OFFSET), each taking a literal-table pointer and
a sign bit. Per the predecessor documentation, SINT is also the instruction
used when matrices or vectors need to be initialized element-by-element
(rather than uniformly via [MINT](MINT.md)/[VINT](VINT.md)) — i.e. one
SINT per element, addressed via OFFSET.

## Usage Context

Appears within a "static bypass block" alongside the other initialization
operators; see [BINT](BINT.md) for the general pattern.

## Operand-Word Format (confirmed empirically)

**Direct symbol-table form**: two operands — operand 1 = target variable,
`DATA`=its symbol-table index, `QUAL`=1=SYT; operand 2 = initializing
value, `DATA`=literal-table index, `QUAL`=5=LIT. Confirmed by compiling
`DECLARE SCALAR, S1 INITIAL(2.0), ...` with `HALSFC --parms="LSTALL"`,
which produced operands `2(1),0,0` (S1, symbol index 2) and `1(5),0,0`
(literal-table index 1, i.e. the value 2.0) — see `STATUS.md`'s
"Empirical Verification" section.

**OFFSET-addressed form**: two operands — operand 1 = `DATA`=the target
*run*'s starting element offset within the array/vector/matrix named by
the most recently executed [STRI](STRI.md), `QUAL`=A=OFF; operand 2 =
same literal-table-index/`LIT` form as above, `DATA`=the run's starting
literal-table index, plus (see "Run-length mechanism" below) the
operand's own `TAG1` byte carries the run's length. Used by two distinct
`INITIAL(...)` forms that share this same instruction shape:

- The `n#value` uniform-repetition form (`DECLARE S1 ARRAY(1000) SCALAR
  INITIAL(1000#1.5);`, [USA003087] §16.2) — OFFSET's `DATA` is always
  `0` here and `TAG1` is always `1`; the repeated-write behavior instead
  comes from [SLRI](SLRI.md)'s own count driving the *whole* SINT/ELRI
  unit to be replayed multiple times at runtime (see [SLRI](SLRI.md) for
  the full worked trace).
- The **explicit-literal-list form** (`DECLARE V VECTOR
  INITIAL(10,11,12);`) — confirmed this session: this compiles to a bare
  `STRI`/`SINT`/[ETRI](ETRI.md) group with **no SLRI/ELRI at all**. One
  SINT is emitted per *coalesced run* of consecutive literal-table
  entries feeding consecutive target elements (the same `ICQ_OUTPUT`
  coalescing [TINT](TINT.md) uses for whole-structure lists — see
  "Run-length mechanism" below). Confirmed by compiling `DECLARE V
  VECTOR INITIAL(10, 11, 12);`:
  ```
  HALMAT: 801(1),0,0            <- STRI: V, symbol index 2
  HALMAT: 8A1(2),6,0            <- SINT
            0(10),0,0              <- OFF, DATA=0 (run starts at element 0)
            1(5),0,0               <- LIT, DATA=1 (literal #1 = 10.0), TAG1=3 (3-element run)
  HALMAT: 804(0),0,0            <- ETRI
  ```
  and confirmed further with `DECLARE V VECTOR INITIAL(1, -5, 3);`,
  where the compile-time `-5` expression's own "5" operand literal
  (stored in the literal table but never referenced by any SINT) breaks
  the coalesced run in two, producing a *second*, non-zero OFFSET:
  ```
  HALMAT: 801(1),0,0            <- STRI: V, symbol index 2
  HALMAT: 8A1(2),6,0            <- SINT
            0(10),0,0              <- OFF, DATA=0
            1(5),1,0               <- LIT, DATA=1 (literal #1 = 1.0), TAG1=1
  HALMAT: 8A1(2),6,0            <- SINT
            1(10),0,0              <- OFF, DATA=1 (second run starts at element 1)
            3(5),2,0               <- LIT, DATA=3 (literal #3 = -5.0; literal #2=5.0 unused), TAG1=2 (covers -5.0, 3.0)
  HALMAT: 804(0),0,0            <- ETRI
  ```
  i.e. each SINT is fully self-contained (absolute starting element
  offset, absolute starting literal index, explicit run length) — no
  persistent "current literal" pointer is needed at runtime, since a
  skipped/unused literal (like the "5" above) simply isn't referenced by
  any SINT's `DATA`/`TAG1` pair.

### Run-length mechanism

`PASS1.PROCS/ICQOUTPU.xpl`'s `ICQ_OUTPUT` procedure coalesces consecutive
initial-constant values into a single instruction whenever the
literal-table pointer *and* the OFFSET/slot value both increment by
exactly 1 per value, writing the resulting run-length count into the
emitted instruction's literal operand's `TAG1` byte via
`HALMAT_FIX_PIPTAGS` — the same mechanism [TINT](TINT.md) uses for
whole-structure `INITIAL(...)` lists, confirmed here to also apply to
SINT's OFFSET-addressed form. `TAG1` defaults to (i.e. is observed as) 1
when a run isn't coalesced with its neighbors.

## Unresolved Questions

- The sign bit for negated literals, mentioned in the predecessor
  description, is not yet confirmed for HAL/S specifically — though note
  that in practice a negated literal like `-5` in an `INITIAL(...)` list
  is realized as an ordinary *positive-valued* literal-table entry (the
  already-negated `-5.0`), not a separate sign bit — see the
  `INITIAL(1, -5, 3)` trace above.

## Source Analysis & Reliability

Opcode (0x8A1) and mnemonic are primary-sourced from [IR-60-5] A.2 (p.
A-109); no page content for SINT's own HAL/S description (target p. 87) is
present in the available partial copy. Base two-operand form (symbol +
literal) independently confirmed against real compiled HALMAT this
session. The OFFSET-addressed form's run-length mechanism and its
explicit-literal-list use case (as opposed to the `n#value` case) are
newly confirmed this session, empirically, against fresh `HAL_S_FC.py`
compiles decoded via `unHALMAT.py`/`unLitfile.py` — prompted by a
yaHALMAT2 runtime bug report (`source-documentation/BAD_INITIAL.md`)
showing this form was previously unhandled.

Behavioral description drawn from [MSC-01847] pp. 2-40–2-41, describing the
identically-numbered-within-its-scheme predecessor-language instruction
(HAL 1971 opcode 0x8A1). See [STRI](STRI.md)'s Source Analysis section for
the general basis of this cross-language inference.
