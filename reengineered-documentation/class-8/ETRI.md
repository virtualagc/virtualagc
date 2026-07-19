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

Appears exactly once per repetition group, immediately after the last
element's [SINT](SINT.md)/[ELRI](ELRI.md) pair, closing out the sequence
opened by [STRI](STRI.md)/[SLRI](SLRI.md).

## Operand-Word Format (confirmed empirically)

No operands. Confirmed by compiling `DECLARE S1 ARRAY(1000) SCALAR
INITIAL(1000#1.5);` with `HALSFC --parms="LSTALL"` — see
[SLRI](SLRI.md) for the full worked trace; `HALMAT: 804(0),0,0` appears
exactly once, right after the 1000th (last) [ELRI](ELRI.md).

## Unresolved Questions

- None for the base case tested.

## Source Analysis & Reliability

Opcode (0x804) doubly confirmed (`XETRI`) in `PASS1.PROCS/##DRIVER.xpl` —
see [##DRIVER.xpl] in `STATUS.md`; no HAL-1971 analog identified at this
slot. Full behavioral description and operand-word structure confirmed
directly against real compiled HALMAT this session — see
[SLRI](SLRI.md)'s Source Analysis for the context.
