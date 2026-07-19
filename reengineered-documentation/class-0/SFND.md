# SFND

**Mnemonic:** SFND

**Opcode:** 0x046

**Confidence:** High

## Behavioral Description

End of shaping function specification. Marks the end of the HALMAT text
specifying a shaping-function invocation (see [SFST](SFST.md)). Carries
the current function-nesting level and the internal flow number shared
with the related invocation instruction.

## Usage Context

Closes the HALMAT text opened by [SFST](SFST.md), after all arguments
(separated by [SFAR](SFAR.md)) have been specified.

## Unresolved Questions

- HAL/S operand-word format is unconfirmed; see [STRI](../class-8/STRI.md).

## Source Analysis & Reliability

Opcode (0x046) and mnemonic are primary-sourced from [IR-60-5] A.2 (p.
A-103); no page content for SFND's own HAL/S description (target p. 60) is
present in the available partial copy.

Behavioral description drawn from [MSC-01847] p. 2-18, describing the
identically-named predecessor-language instruction (HAL 1971 opcode 0x04C,
differing from HAL/S's 0x046). See [STRI](../class-8/STRI.md)'s Source
Analysis section for the general basis of this cross-language inference.
