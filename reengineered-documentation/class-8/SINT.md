# SINT

**Mnemonic:** SINT

**Opcode:** 0xA1

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

**OFFSET-addressed form**: also confirmed, this time via array element-
by-element initialization rather than matrix/vector. Operand 1 =
`DATA`=0, `QUAL`=A=OFF (observed always `0` — offset appears to be
*relative*/sequential, implicit in emission order, rather than an
explicit absolute index); operand 2 = same literal-table-index/`LIT`
form as above. Confirmed by compiling `DECLARE S1 ARRAY(1000) SCALAR
INITIAL(1000#1.5);` with `HALSFC --parms="LSTALL"` — see
[SLRI](SLRI.md) for the full worked trace (one OFFSET-addressed SINT per
array element, bracketed by [SLRI](SLRI.md)/[ELRI](ELRI.md)/
[ETRI](ETRI.md)).

## Unresolved Questions

- ~~Whether the OFFSET operand is ever non-zero~~ **Mechanism now
  understood** (found while investigating [TINT](TINT.md)'s equivalent
  form): `PASS1.PROCS/ICQOUTPU.xpl`'s `ICQ_OUTPUT` procedure coalesces
  consecutive initial-constant values into a single instruction whenever
  the literal-table pointer *and* the OFFSET/slot value both increment by
  exactly 1 per value — writing the resulting run-length count into the
  emitted instruction's literal operand via `HALMAT_FIX_PIPTAGS`. This is
  presumably why the OFFSET operand was observed always `0` in the
  uniform-`n#value` case tested here: not because offset is inherently
  always zero, but because that test's coalescing always started counting
  from slot 0 for each separately-emitted SINT. Whether the OFFSET
  operand for a *later*, non-coalesced run ever shows non-zero (as would
  be needed if a repeated pattern's initial values aren't fully
  contiguous in the literal table) was not directly tested — see
  [TINT](TINT.md)'s Unresolved Questions for the general mechanism and a
  suggested follow-up test.
- The sign bit for negated literals, mentioned in the predecessor
  description, is not yet confirmed for HAL/S specifically.

## Source Analysis & Reliability

Opcode (0xA1) and mnemonic are primary-sourced from [IR-60-5] A.2 (p.
A-109); no page content for SINT's own HAL/S description (target p. 87) is
present in the available partial copy. Base two-operand form (symbol +
literal) independently confirmed against real compiled HALMAT this
session.

Behavioral description drawn from [MSC-01847] pp. 2-40–2-41, describing the
identically-numbered-within-its-scheme predecessor-language instruction
(HAL 1971 opcode 0x8A1). See [STRI](STRI.md)'s Source Analysis section for
the general basis of this cross-language inference.
