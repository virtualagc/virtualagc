# ELRI

**Mnemonic:** ELRI

**Opcode:** 0x03

**Confidence:** High

## Behavioral Description

End (one unit of a) loop, repeated initialize. Closes one repeated unit
within the sequence opened by [SLRI](SLRI.md) — one ELRI follows each
[SINT](SINT.md) (or other class-8 `xINT` instruction) emitted for a
single element of a `n#value` repeated `INITIAL(...)` specification
([USA003087] §16.2). Carries no operands; purely a per-unit delimiter.

## Usage Context

Appears once per repeated element, immediately after that element's
initialization instruction, for the full unrolled length of the
repetition (e.g. 1000 times for a 1000-element uniformly-repeated
array). The final one is followed by the sequence-closing
[ETRI](ETRI.md) instead of another element.

## Operand-Word Format (confirmed empirically)

No operands. Confirmed by compiling `DECLARE S1 ARRAY(1000) SCALAR
INITIAL(1000#1.5);` with `HALSFC --parms="LSTALL"` — see
[SLRI](SLRI.md) for the full worked trace, in which `HALMAT: 803(0),1,0`
appears with no following operand line, once per repeated element.

## Unresolved Questions

- None for the base case tested.

## Source Analysis & Reliability

Opcode (0x03) doubly confirmed (`XELRI`) in `PASS1.PROCS/##DRIVER.xpl` —
see [##DRIVER.xpl] in `STATUS.md`. Slot matches HAL-1971's DLEI
("initialize loop end"); the mnemonic itself differs, so this remains a
plausibly-renamed version of the same concept rather than a confirmed
cross-language match. Full behavioral description and operand-word
structure confirmed directly against real compiled HALMAT this session
— see [SLRI](SLRI.md)'s Source Analysis for the context.
