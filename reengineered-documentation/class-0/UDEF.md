# UDEF

**Mnemonic:** UDEF
**Opcode:** 0x02E
**Confidence:** High

## Behavioral Description

Update block definition header. Indicates the start of an "update block."
If the update block is named, the operand points to the name in the
symbol table; if unnamed, the operand field is empty.

## Usage Context

Begins the HALMAT text for an update block, presumably matched by a
closing instruction analogous to the predecessor language's UEND ("update
block end"), which has not yet been confirmed to have a HAL/S opcode. See
also [MDEF](MDEF.md)/[TDEF](TDEF.md)/[PDEF](PDEF.md)/[FDEF](FDEF.md), the
other compilation-unit definition headers.

## Unresolved Questions

- HAL/S operand-word format is unconfirmed; see [STRI](../class-8/STRI.md).
- Whether HAL/S has a distinct UEND-equivalent closing opcode, or reuses
  [CLOS](../STATUS.md) (opcode 0x030, not yet documented) for update
  blocks as well, is unconfirmed.

## Source Analysis & Reliability

Opcode (0x02E) and mnemonic are primary-sourced from [IR-60-5] A.2 (p.
A-103); no page content for UDEF's own HAL/S description (target p. 9) is
present in the available partial copy.

Behavioral description drawn from [MSC-01847] p. 2-16, describing the
identically-named predecessor-language instruction (HAL 1971 opcode 0x033,
differing from HAL/S's 0x02E). See [STRI](../class-8/STRI.md)'s Source
Analysis section for the general basis of this cross-language inference.
