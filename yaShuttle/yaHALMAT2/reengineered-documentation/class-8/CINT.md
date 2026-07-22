# CINT

**Mnemonic:** CINT

**Opcode:** 0x841

**Confidence:** High

## Behavioral Description

Character initialize. Initializes the specified character operand with a
literal value.

In the predecessor language HAL (1971), the analogous instruction (there
opcode 0x841 in that language's own opcode space) has two forms, exactly
parallel to [BINT](BINT.md): the target operand is given either directly
as a symbol-table variable, or as an OFFSET from a related [STRI](STRI.md)-
specified variable. Both forms take a literal-table pointer as the
initializing value.

## Usage Context

Appears within a "static bypass block" alongside the other initialization
operators; see [BINT](BINT.md) for the general pattern.

## Operand-Word Format (confirmed empirically)

Direct symbol-table form: two operands — operand 1 = target variable,
`DATA`=its symbol-table index, `QUAL`=1=SYT; operand 2 = initializing
value, `DATA`=literal-table index, `QUAL`=5=LIT — same target-first,
value-second order as [SINT](SINT.md)/[BINT](BINT.md)/[IINT](IINT.md)/
[NINT](NINT.md)/[EINT](EINT.md). Confirmed by compiling
`DECLARE CHARACTER(10), C1 INITIAL('HELLO');` with
`HALSFC --parms="LISTING2,LSTALL"`, cross-checked directly with
`unHALMAT.py`:

```
HALMAT: 841(2),2,0            <- CINT
          3(1),0,0               <- op 1: C1, symbol index 3, QUAL=1=SYT (target)
          3(5),0,0               <- op 2: literal-table index 3 (value 'HELLO'), QUAL=5=LIT
```

## Unresolved Questions

- ~~The OFFSET-addressed form (used inside a [STRI](STRI.md) repeat loop)
  was not tested — only the direct symbol-table form.~~ **Resolved in a
  later session**: confirmed by compiling `DECLARE C ARRAY(3)
  CHARACTER(4) INITIAL('AB','CD','EF');` — a bare STRI/CINT/ETRI group
  (no [SLRI](SLRI.md)), one CINT with OFFSET.DATA=0 and the LIT
  operand's own `TAG1`=3 ([SINT](SINT.md)'s coalesced-run-length
  mechanism, here for CHARACTER ARRAY elements). A real yaHALMAT2 gap
  was found and fixed here: CHARACTER ARRAY element storage didn't
  exist in the interpreter at all before this session (only numeric
  ARRAY/MATRIX/VECTOR did) — see `state.h`'s `char_elements`.

## Source Analysis & Reliability

Opcode (0x841) and mnemonic are primary-sourced from [IR-60-5] A.2 (p.
A-109); no page content for CINT's own HAL/S description (target p. 87) is
present in the available partial copy. Operand-word structure confirmed
directly against real compiled HALMAT this session via a direct
`unHALMAT.py` binary read.

Behavioral description drawn from [MSC-01847] p. 2-39, describing the
identically-numbered-within-its-scheme predecessor-language instruction
(HAL 1971 opcode 0x841). See [STRI](STRI.md)'s Source Analysis section for
the general basis of this cross-language inference.
