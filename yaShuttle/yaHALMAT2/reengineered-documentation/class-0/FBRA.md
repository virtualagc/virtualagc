# FBRA

**Mnemonic:** FBRA

**Opcode:** 0x00A

**Confidence:** High

## Behavioral Description

False branch on condition. Specifies a conditional branch to either a
[LBL](LBL.md) instruction carrying the same operand, or — in the same
"absolute label" special usage described for [BRA](BRA.md) — directly to
the HALMAT instruction it indexes. The branch is taken if the logical
(comparison-result) operand it references evaluates to FALSE.

## Usage Context

Used to implement the "skip the true part" edge of compiled IF statements
and the loop-exit test of DO WHILE / conditional DO FOR statements — see
the worked examples for simple and complex IF statements and DO WHILE in
the predecessor-language documentation, which (allowing for opcode
renumbering) are expected to carry over structurally to HAL/S.

## Operand-Word Format (confirmed empirically)

Two operands: operand 1 = `DATA`=stream position of the instruction
producing the logical/comparison result, `QUAL`=3=VAC; operand 2 =
`DATA`=an internal branch-target/label identifier (matching the target
[LBL](LBL.md)'s own operand), `QUAL`=2=GLI/INL. Confirmed by compiling
`IF I1 > 0 THEN S1 = 1.0; ELSE S1 = 2.0;` with `HALSFC --parms="LSTALL"`
— see [IFHD](IFHD.md) for the full worked trace.

## Unresolved Questions

- None remaining for the base `IF...THEN...ELSE` case.

## Source Analysis & Reliability

Opcode (0x00A) and mnemonic are primary-sourced from [IR-60-5] A.2 (p.
A-103) and independently confirmed by `XFBRA BIT(16) INITIAL("00A")` in
the compiler source (`PASS1.PROCS/##DRIVER.xpl` — see [##DRIVER.xpl] in
`STATUS.md`). No page content for FBRA's own HAL/S description (target p.
50) is present in the available partial copy. Operand-word format
confirmed directly against real compiled HALMAT this session.

Behavioral description drawn from [MSC-01847] p. 2-3, describing the
identically-named predecessor-language instruction (HAL 1971 opcode 0x012,
differing from HAL/S's 0x00A). See [STRI](../class-8/STRI.md)'s Source
Analysis section for the general basis of this cross-language inference.
