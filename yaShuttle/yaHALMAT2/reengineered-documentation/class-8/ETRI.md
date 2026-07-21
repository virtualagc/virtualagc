# ETRI

**Mnemonic:** ETRI

**Opcode:** 0x804

**Confidence:** High

## Behavioral Description

End loop, repeated initialize. Closes the entire repeated-initial-value
sequence opened by [SLRI](SLRI.md) — the counterpart to
[ELRI](ELRI.md) (which closes one element/unit at a time), but for the
whole `n#value` repetition group ([USA003087] §16.2). Carries no
operands.

## Usage Context

Appears exactly once per repetition group, immediately after the
[SINT](SINT.md)/[ELRI](ELRI.md) pair, closing out the sequence opened by
[STRI](STRI.md)/[SLRI](SLRI.md). **Correction (later session):** the
compiler emits only a single SINT/ELRI unit regardless of repetition
count (not one per element — see [SLRI](SLRI.md)'s corrected Usage
Context), so ETRI immediately follows that one unit, not "the last of N"
elements.

## Operand-Word Format (confirmed empirically)

No operands. Confirmed by compiling `DECLARE A ARRAY(3) SCALAR
INITIAL(3#1.5);` — see [SLRI](SLRI.md) for the full worked trace;
`HALMAT: 804(0),0,0` appears exactly once, right after the single
[ELRI](ELRI.md).

## Unresolved Questions

- None for the base case tested.

## Source Analysis & Reliability

Opcode (0x804) doubly confirmed (`XETRI`) in `PASS1.PROCS/##DRIVER.xpl` —
see [##DRIVER.xpl] in `STATUS.md`; no HAL-1971 analog identified at this
slot. Full behavioral description and operand-word structure confirmed
directly against real compiled HALMAT this session — see
[SLRI](SLRI.md)'s Source Analysis for the context.
