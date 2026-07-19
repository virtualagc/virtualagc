# DLPE

**Mnemonic:** DLPE

**Opcode:** 0x018

**Confidence:** High

## Behavioral Description

End of array- and structureness-specification. A fixed-format terminator
instruction (no meaningful operands) used to close a sequence of one or
more [ADLP](ADLP.md) (arrayness) and/or SDLP (structureness, not yet
documented for HAL/S — see [STATUS.md](../STATUS.md)) instructions.

## Usage Context

Confirmed this session in two roles, paralleling [ADLP](ADLP.md)'s own
two roles: (1) the last instruction of an [ADLP](ADLP.md) run, preceding
the paragraph of HALMAT (an assignment or conditional operator) that the
arrayness specifier modifies — the whole-loop-closing role; and (2) in
[ADLP](ADLP.md)/[IDLP](IDLP.md)'s uniform-single-value array
initialization role, recurring **once per array element**, each closing
that one element's [SINT](../class-8/SINT.md) rather than the sequence
as a whole — see [IDLP](IDLP.md) for the full worked trace (no separate
whole-sequence closer was observed in that role, unlike
[ETRI](../class-8/ETRI.md) in the `n#value` repetition mechanism).

## Unresolved Questions

- None specific to DLPE beyond the general caveats noted for
  [ADLP](ADLP.md)/[IDLP](IDLP.md).

## Source Analysis & Reliability

Opcode (0x018) and mnemonic are primary-sourced from [IR-60-5] A.2 (p.
A-103); no page content for DLPE's own HAL/S description (target p. 90) is
present in the available partial copy. Its role in Optimizer-era HALMAT is
documented in [HALMAT.md](../HALMAT.md#optimizer-halmat) from [IR-60-5]
A-113.

Behavioral description drawn from [MSC-01847] p. 2-4, describing the
identically-named predecessor-language instruction (HAL 1971 opcode 0x00E,
differing from HAL/S's 0x018). See [STRI](../class-8/STRI.md)'s Source
Analysis section for the general basis of this cross-language inference.
