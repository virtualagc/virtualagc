# ADLP

**Mnemonic:** ADLP

**Opcode:** 0x017

**Confidence:** High

## Behavioral Description

Arrayness (and, confirmed this session, **structureness**) specifier. A
HAL/S statement may specify arithmetic or conditional operations to be
carried out on arrayed variables — such a statement is said to have
"free arrayness." ADLP specifies one dimension of the (possibly
multidimensional) free arrayness of the statement whose HALMAT is being
generated. Because free arrayness may be multidimensional, a statement
may be preceded by more than one ADLP, terminated by a single
[DLPE](DLPE.md). The same opcode also serves the structurally-analogous
role for multi-copy structure operations (role 3 below), matching
[MSC-01847]'s own section title for the HAL-1971 predecessor instruction,
"ARRAYNESS and STRUCTURENESS SPECIFIERS" — the two concepts were never
split into separate opcodes in either language version.

There are (at least, in the predecessor language) two forms: in one, the
operand directly specifies a variable whose runtime value gives the
arrayness; in the other, the arrayness is given as the Nth array dimension
of a specific symbol-table variable, with N carried in the instruction
alongside the variable reference.

## Usage Context

Confirmed this session in two distinct roles:

1. **General arrayed-expression loop bracketing** — appears immediately
   before the paragraph of HALMAT it modifies (an assignment or
   conditional operator over arrayed operands), unconditionally,
   regardless of the operands' `STATIC`/`AUTOMATIC` attribute. Confirmed
   for 1-D and 2-D array arithmetic, arrayed structure-terminal access,
   and `COMPOOL`-declared arrays — always ADLP, never [IDLP](IDLP.md), in
   every case tested. Always terminated by a single [DLPE](DLPE.md), even
   for multi-dimensional arrayness (the compiler flattens multi-dimensional
   array operations into one loop over the total element count, rather
   than nesting one nested loop per dimension). Also confirmed, in a later
   session, to cover a case the HAL-1971 predecessor needed a dedicated
   opcode for: an arrayed *expression* (not a plain symbol-table variable)
   passed as a procedure argument (`CALL P((S1 + S2));`) is bracketed by
   an ordinary role-1 `ADLP`/`DLPE` pair around the [XXAR](XXAR.md)
   operand, exactly like any other array-valued expression — see
   `STATUS.md`'s "ZDLP/PFST/PFND addendum" note for the full context.
2. **Uniform single-value array initialization** — via the compiler's
   `ICQ_ARRAYNESS_OUTPUT` routine (`PASS1.PROCS/ICQARRA2.xpl`), for a
   HAL/S `INITIAL(v)`/`CONSTANT(v)` specification giving one value to
   fill every element of a multi-element array (no `n#` repetition-factor
   prefix — see [USA003087] §4.3; contrast the `n#value` form, which uses
   [STRI](../class-8/STRI.md)/[SLRI](../class-8/SLRI.md)/
   [ELRI](../class-8/ELRI.md)/[ETRI](../class-8/ETRI.md) instead). Here
   ADLP and [IDLP](IDLP.md) are **mutually exclusive alternatives**,
   chosen by the target array's `AUTOMATIC`/`STATIC` declaration
   attribute — see [IDLP](IDLP.md) for the full mechanism and worked
   trace of both cases.
3. **Structureness specifier** — **confirmed this session, resolving the
   long-standing "does HAL/S have a distinct structureness-specifier
   opcode" open question** (see `STATUS.md`): a whole-structure
   copy-to-copy assignment between two multi-copy structures (e.g.
   `ZQ4 = ZQ3;`, both `Q-STRUCTURE(3)`) is followed by an `ADLP`/`DLPE`
   pair whose operand is the structure's **copy count**, not an array
   element count — the same opcode, the same operand shape, doing for
   structure copies exactly what role 1 does for array elements. This
   matches [MSC-01847]'s own section title for the HAL-1971 analog,
   "ARRAYNESS and STRUCTURENESS SPECIFIERS" (§2.4) — the predecessor
   already treated these as one concept, and HAL/S evidently kept that
   unification rather than splitting it into a separate opcode (ruling
   out the "undiscovered separate opcode" and "incomplete index" branches
   of the open question in favor of "folded into ADLP itself"). Unlike
   role 1, the `ADLP`/`DLPE` pair here comes **after** the [TASN](TASN.md)
   it modifies, not before, and brackets no HALMAT "loop body" at all
   (`DLPE` follows immediately, with no intervening instructions) —
   consistent with the copy-loop being fully delegated to the `#QCSTRUC`
   runtime routine TASN already calls, with `ADLP`/`DLPE` here serving
   purely as after-the-fact copy-count metadata for PASS2/the optimizer
   rather than a real bracket around repeated HALMAT.

## Operand-Word Format (confirmed empirically, roles 2 and 3)

**Role 2**: one operand: `DATA`=the array's total element count,
`QUAL`=6=IMD. Confirmed by compiling `DECLARE ARRAY(6) SCALAR AUTOMATIC,
V1 INITIAL(4.0);` with `HALSFC --parms="LSTALL"`, which produced
`HALMAT: 017(1),0,0` followed by operand `6(6),0,0` — identical shape to
[IDLP](IDLP.md)'s confirmed trace for the `STATIC` (default) case, see
that file.

**Role 3**: same shape, `DATA`=the structure's copy count instead of an
array element count, `QUAL`=6=IMD. Confirmed by compiling `ZQ4 = ZQ3;`
(both `Q-STRUCTURE(3)`) with `HALSFC --parms="LISTING2,LSTALL"`,
cross-checked directly with `unHALMAT.py`:

```
HALMAT: 04F(2),0,0        <- TASN: ZQ4 = ZQ3 (whole-structure copy)
          ...                 <- (two XPT operands, see TASN.md)
HALMAT: 017(1),0,0        <- ADLP: role 3, structureness specifier
          3(6),0,0           <- op: DATA=3 (the copy count), QUAL=6=IMD
HALMAT: 018(0),0,0        <- DLPE: closes immediately, no loop body
```

Role 1's operand-word format (general arrayed-loop bracketing) was not
specifically decoded this session.

## Unresolved Questions

- Role 1's own operand-word format (what exactly ADLP's operand encodes
  for a general arrayed-expression loop — a symbol reference, a
  dimension count, or something else) remains unconfirmed; only roles 2
  and 3's formats were decoded.
- Whether a *multi-dimensional* structureness case exists (e.g. nested
  multi-copy structures) that would need more than one role-3 `ADLP`
  before a single `DLPE`, mirroring role 1's multi-dimensional-array
  handling, was not tested — only a single-level `Q-STRUCTURE(n)` was
  compiled.
- The predecessor-language documentation describes a further special case
  where ADLP's operand indirectly references a companion ATSB/AASB
  subscript-specifier instruction; HAL/S appears to have consolidated
  ATSB/AASB-equivalent functionality into [DSUB](DSUB.md) (see that file's
  Source Analysis section), so this special case may not transfer
  unchanged to HAL/S — left unresolved.

## Source Analysis & Reliability

Opcode (0x017) and mnemonic are primary-sourced from [IR-60-5] A.2 (p.
A-103); no page content for ADLP's own HAL/S description (target p. 89) is
present in the available partial copy. Its role in Optimizer-era HALMAT
(gaining CSE/arrayness-specifier bits when involved in inline vector/matrix
loops) is documented in [HALMAT.md](../HALMAT.md#optimizer-halmat) from
[IR-60-5] A-113. Role 2 (the `AUTOMATIC`/`STATIC`-driven choice against
[IDLP](IDLP.md)) is directly confirmed both from `ICQARRA2.xpl`'s source
code and empirically against real compiled HALMAT this session — see
[IDLP](IDLP.md)'s Source Analysis for the full account of how this was
found (after four unrelated hypotheses for IDLP were tested and
disproven).

The base (pre-optimizer) behavioral description here is drawn from
[MSC-01847] pp. 2-3–2-4 ("2.4 ARRAYNESS and STRUCTURENESS SPECIFIERS"),
describing the identically-named predecessor-language instruction (HAL
1971 opcode 0x00D, differing from HAL/S's 0x017). See
[STRI](../class-8/STRI.md)'s Source Analysis section for the general basis
of this cross-language inference. Role 3 (structureness) confirmed
directly against real compiled HALMAT this session via a direct
`unHALMAT.py` binary read of `ZQ4 = ZQ3;` — resolving `STATUS.md`'s open
question about whether HAL/S retained a distinct structureness-specifier
opcode (it didn't need one: [MSC-01847]'s own section title already
named both concepts together, and that unification carried over to
HAL/S's `ADLP`/`DLPE` unchanged).
