# BINT

**Mnemonic:** BINT

**Opcode:** 0x21

**Confidence:** High

## Behavioral Description

Bit-string initialize. Initializes the specified bit-string operand with a
literal value.

In the predecessor language HAL (1971), the analogous instruction (there
opcode 0x821 in that language's own opcode space, following the same
hundreds-digit-per-class convention — see [HALMAT.md](../HALMAT.md#instruction-classes))
has two forms: one where the target operand is given directly as a
symbol-table variable, and one where it is given as an OFFSET (a
compile-time-computed byte/bit displacement from a related STRI-specified
variable, used inside a repeated-initialize loop — see [STRI](STRI.md)).
Both forms take a literal-table pointer as the value to initialize with.

## Usage Context

Appears within a "static bypass block" alongside other initialization
operators ([CINT](CINT.md), [MINT](MINT.md), [VINT](VINT.md),
[SINT](SINT.md), [IINT](IINT.md)), one per initialized variable (or, inside
a [STRI](STRI.md) repeat loop, one per initializing literal).

## Operand-Word Format (confirmed empirically)

Direct symbol-table form: two operands — operand 1 = target variable,
`DATA`=its symbol-table index, `QUAL`=1=SYT; operand 2 = initializing
value, `DATA`=literal-table index, `QUAL`=5=LIT — the same target-first,
value-second order as [SINT](SINT.md)/[NINT](NINT.md)/[EINT](EINT.md)
(this "INT" static-initialization family is unaffected by the
source-before-receiver reversal found in the runtime `xASN` assign
family — see [SASN](../class-5/SASN.md) — since it's built by a
different codegen path). Confirmed by compiling
`DECLARE BIT(16), B1 INITIAL(BIN'1010101010101010');` with
`HALSFC --parms="LISTING2,LSTALL"`, cross-checked directly with
`unHALMAT.py`:

```
HALMAT: 821(2),1,0            <- BINT
          6(1),0,0               <- op 1: B1, symbol index 6, QUAL=1=SYT (target)
          6(5),0,0               <- op 2: literal-table index 6, QUAL=5=LIT (initializing value)
```

## Unresolved Questions

- The OFFSET-addressed form (used inside a [STRI](STRI.md) repeat loop,
  by analogy with [SINT](SINT.md)'s OFFSET-addressed form) was not tested
  — only the direct symbol-table form.
- Whether HAL/S BINT retains both the "direct variable" and "OFFSET" forms
  described for the 1971 predecessor is otherwise unconfirmed.

## Source Analysis & Reliability

Opcode (0x21) and mnemonic are primary-sourced from [IR-60-5] A.2 (p.
A-109); no page content for BINT's own HAL/S description (target p. 87) is
present in the available partial copy. Operand-word structure confirmed
directly against real compiled HALMAT this session via a direct
`unHALMAT.py` binary read.

Behavioral description drawn from [MSC-01847] p. 2-39, describing the
identically-numbered-within-its-scheme predecessor-language instruction
(HAL 1971 opcode 0x821). See [STRI](STRI.md)'s Source Analysis section for
the general basis of this cross-language inference and its confidence
rationale.
