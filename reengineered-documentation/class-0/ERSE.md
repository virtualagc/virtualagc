# ERSE

**Mnemonic:** ERSE

**Opcode:** 0x03D

**Confidence:** High

## Behavioral Description

`SEND ERROR` statement ("ERror SEnd"). Simulates a system-defined error
or signals a user-defined error, per its error-group:member code
([USA003087] §25.3, PDF p. 325): `SEND ERROR m:n;`. The recovery action
that follows is exactly as if the corresponding run-time error had
genuinely occurred — if a prior `ON ERROR` modification is in force for
that error code, its recovery action (branch, `IGNORE`, event
modification, etc.) is taken.

This is a genuinely different HAL/S statement from `ON ERROR`/
`OFF ERROR` — not a variant of either — which is why exhaustive testing
of every `ON`/`OFF ERROR` form (11 variations across two sessions, all
routing through [ERON](ERON.md)) never turned it up.

## Usage Context

Emitted for every `SEND ERROR` statement. Like [ERON](ERON.md), the
error specification always takes the `m:n` (group:member) form here —
[USA003087] §25.3 rule 1 states both `m` and `n` are always required
(unlike `ON`/`OFF ERROR`'s specification, which permits omitting either
for a wildcard).

## Operand-Word Format (confirmed empirically)

One operand: `DATA`=error group number, `QUAL`=6=IMD, trailing sub-field
= error member number — the identical packed group/member encoding
confirmed for [ERON](ERON.md)'s specification operand. Confirmed by
compiling `SEND ERROR 5:2;` with `HALSFC --parms="LSTALL"`:

```
HALMAT: 03D(1),0,0
          5(6),2,0               <- DATA=5 (group 5), QUAL=6=IMD, sub-field 2 (member 2)
SVC 0,=F'1312002'                 <- runtime supervisor call, packed error code as immediate operand
```

## Unresolved Questions

- The exact packing of the `SVC` immediate constant (`1312002` for
  group 5, member 2) is not decoded bit-for-bit.
- Whether `SEND ERROR` ever omits `m` or `n` in practice (despite
  §25.3 rule 1 implying both are mandatory) was not tested.

## Source Analysis & Reliability

Opcode (0x03D) confirmed primary-source: `XERSE BIT(16) INITIAL("03D")`
in `PASS1.PROCS/##DRIVER.xpl` — see [##DRIVER.xpl] in `STATUS.md`. No
[MSC-01847] (HAL-1971) analog identified. Statement syntax primary-
sourced from [USA003087] §25.3 (PDF p. 325) — located directly after
exhaustively ruling out every `ON ERROR`/`OFF ERROR` variation (see
[ERON](ERON.md)'s Source Analysis for that history) prompted a search
for a genuinely distinct error-related statement, which turned up
`SEND ERROR`. Full behavioral description and operand-word structure
confirmed directly against real compiled HALMAT this session.
