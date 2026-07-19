# ADLP

**Mnemonic:** ADLP

**Opcode:** 0x017

**Confidence:** High

## Behavioral Description

Arrayness specifier. A HAL/S statement may specify arithmetic or
conditional operations to be carried out on arrayed variables — such a
statement is said to have "free arrayness." ADLP specifies one dimension
of the (possibly multidimensional) free arrayness of the statement whose
HALMAT is being generated. Because free arrayness may be multidimensional,
a statement may be preceded by more than one ADLP, terminated by a single
[DLPE](DLPE.md).

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
   than nesting one nested loop per dimension).
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

## Operand-Word Format (confirmed empirically, role 2)

One operand: `DATA`=the array's total element count, `QUAL`=6=IMD.
Confirmed by compiling `DECLARE ARRAY(6) SCALAR AUTOMATIC, V1
INITIAL(4.0);` with `HALSFC --parms="LSTALL"`, which produced `HALMAT:
017(1),0,0` followed by operand `6(6),0,0` — identical shape to
[IDLP](IDLP.md)'s confirmed trace for the `STATIC` (default) case, see
that file. Role 1's operand-word format (general arrayed-loop
bracketing) was not specifically decoded this session.

## Unresolved Questions

- Role 1's own operand-word format (what exactly ADLP's operand encodes
  for a general arrayed-expression loop — a symbol reference, a
  dimension count, or something else) remains unconfirmed; only role 2's
  format was decoded.
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
of this cross-language inference.
