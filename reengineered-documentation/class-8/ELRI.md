# ELRI

**Mnemonic:** ELRI

**Opcode:** 0x803

**Confidence:** High

## Behavioral Description

End (one unit of a) loop, repeated initialize. Closes one repeated unit
within the sequence opened by [SLRI](SLRI.md) — one ELRI follows each
[SINT](SINT.md) (or other class-8 `xINT` instruction) emitted for a
single element of a `n#value` repeated `INITIAL(...)` specification
([USA003087] §16.2). Carries no operands; purely a per-unit delimiter.

## Usage Context

**Correction (later session):** appears exactly once per `SLRI`/`ETRI`
group, not once per repeated element — see [SLRI](SLRI.md)'s corrected
Usage Context. The compiler emits a single [SINT](SINT.md)/`ELRI` unit
regardless of repetition count; the runtime consumer replays that single
unit (SLRI's own repetition-count operand driving the replay), so ELRI
closes the one emitted unit, not "one of N" unrolled copies.

## Operand-Word Format (confirmed empirically)

No operands. Confirmed by compiling `DECLARE A ARRAY(3) SCALAR
INITIAL(3#1.5);` — see [SLRI](SLRI.md) for the full worked trace, in
which `HALMAT: 803(0),1,0` appears with no following operand line.

## Unresolved Questions

- None for the base case tested.

## Source Analysis & Reliability

Opcode (0x803) doubly confirmed (`XELRI`) in `PASS1.PROCS/##DRIVER.xpl` —
see [##DRIVER.xpl] in `STATUS.md`. Slot matches HAL-1971's DLEI
("initialize loop end"); the mnemonic itself differs, so this remains a
plausibly-renamed version of the same concept rather than a confirmed
cross-language match. Full behavioral description and operand-word
structure confirmed directly against real compiled HALMAT this session
— see [SLRI](SLRI.md)'s Source Analysis for the context.
