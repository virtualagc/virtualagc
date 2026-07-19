# SFAR

**Mnemonic:** SFAR
**Opcode:** 0x047
**Confidence:** High

## Behavioral Description

Shaping function argument separator. Separates the HALMAT text
corresponding to each argument of a shaping-function invocation (see
[SFST](SFST.md)). Carries the current function-nesting level and the
internal flow number shared with the related invocation instruction.

## Usage Context

Appears between successive arguments of a multi-argument shaping-function
invocation, bracketed overall by [SFST](SFST.md)/[SFND](SFND.md). Per
[MSC-01847]'s worked examples, even a single-argument shaping function
invocation leaves a "vestigial" SFAR-equivalent when built from a
general-purpose code path that always emits argument separators.

## Operand-Word Format (confirmed empirically)

One operand: `DATA`=the argument expression's value reference (`SYT` for
a plain variable, or other qualifiers for a literal/computed
expression), matching whichever qualifier the argument itself requires.
Confirmed via [MSHP](MSHP.md)'s and [VSHP](VSHP.md)'s worked traces (one
SFAR per shaping-function argument, in source order, each carrying that
argument's own single operand) — cross-checked directly against compiled
binaries with `unHALMAT.py`, confirming each SFAR's operand is correctly
its own (no misattachment to a neighboring SFAR/SFST/shaping-result
instruction).

## Unresolved Questions

- The "vestigial" single-argument case (per [MSC-01847]'s worked
  examples) was not independently re-verified for HAL/S specifically.

## Source Analysis & Reliability

Opcode (0x047) and mnemonic are primary-sourced from [IR-60-5] A.2 (p.
A-103); no page content for SFAR's own HAL/S description (target p. 60) is
present in the available partial copy.

Behavioral description drawn from [MSC-01847] p. 2-17, describing the
identically-named predecessor-language instruction (HAL 1971 opcode 0x04B,
differing from HAL/S's 0x047). See [STRI](../class-8/STRI.md)'s Source
Analysis section for the general basis of this cross-language inference.
