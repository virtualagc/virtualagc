# IINT

**Mnemonic:** IINT
**Opcode:** 0xC1
**Confidence:** High

## Behavioral Description

Integer initialize. Initializes the specified integer operand with a
literal value.

In the predecessor language HAL (1971), the analogous instruction (there
opcode 0x8C1) has two forms parallel to [BINT](BINT.md) (direct
symbol-table variable, or OFFSET), each taking a literal-table pointer and
a sign bit indicating negation.

## Usage Context

Appears within a "static bypass block" alongside the other initialization
operators; see [BINT](BINT.md) for the general pattern.

## Operand-Word Format (confirmed empirically)

Direct symbol-table form: two operands — operand 1 = target variable,
`DATA`=its symbol-table index, `QUAL`=1=SYT; operand 2 = initializing
value, `DATA`=literal-table index, `QUAL`=5=LIT — same target-first,
value-second order as [SINT](SINT.md)/[BINT](BINT.md)/[NINT](NINT.md)/
[EINT](EINT.md) (see [SASN](../class-5/SASN.md) for why this
"INT" family's order differs from the runtime `xASN` assign family's).
Confirmed by compiling `DECLARE INTEGER, I1 INITIAL(7);` with
`HALSFC --parms="LISTING2,LSTALL"`, cross-checked directly with
`unHALMAT.py`:

```
HALMAT: 8C1(2),6,0            <- IINT
          2(1),0,0               <- op 1: I1, symbol index 2, QUAL=1=SYT (target)
          1(5),0,0               <- op 2: literal-table index 1 (value 7), QUAL=5=LIT
```

## Unresolved Questions

- The OFFSET-addressed form and the sign-bit-negation form (per the
  HAL-1971 analog's two forms) were not tested — only the direct
  symbol-table, positive-literal form.

## Source Analysis & Reliability

Opcode (0xC1) and mnemonic are primary-sourced from [IR-60-5] A.2 (p.
A-109); no page content for IINT's own HAL/S description (target p. 87) is
present in the available partial copy. Operand-word structure confirmed
directly against real compiled HALMAT this session via a direct
`unHALMAT.py` binary read.

Behavioral description drawn from [MSC-01847] p. 2-40, describing the
identically-numbered-within-its-scheme predecessor-language instruction
(HAL 1971 opcode 0x8C1). See [STRI](STRI.md)'s Source Analysis section for
the general basis of this cross-language inference.
