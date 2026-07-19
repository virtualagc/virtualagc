# CDEF

**Mnemonic:** CDEF

**Opcode:** 0x02F

**Confidence:** High

## Behavioral Description

Compool definition header. Marks the opening of a `COMPOOL` block
([USA003087] §15.2): `label: COMPOOL; ... CLOSE label;` — a block of
externally-shared data declarations, structurally parallel to
[MDEF](MDEF.md) (`PROGRAM`), [TDEF](TDEF.md) (`TASK`),
[PDEF](PDEF.md) (`PROCEDURE`), and [FDEF](FDEF.md) (`FUNCTION`).

## Usage Context

Always the first instruction of a compiled `COMPOOL` block (following
the standard [PXRC](PXRC.md) record header). Closed, like the other
block types, by [CLOS](CLOS.md). The `EXTERNAL COMPOOL;` template form
([USA003087] §15.4), used to declare an external compool's shape to a
different compilation unit, generates **no** HALMAT at all — confirmed
this session; templates are pure compile-time metadata with no
executable-block representation of their own.

## Operand-Word Format (confirmed empirically)

One operand: `DATA`=symbol-table index of the compool block itself,
`QUAL`=1=SYT — same pattern as [MDEF](MDEF.md)/[TDEF](TDEF.md).
Confirmed by compiling:

```
POOL:
COMPOOL;
   DECLARE VZERO VECTOR INITIAL(0);
   DECLARE INTEGER DOUBLE, I, J, K;
   DECLARE CC CHARACTER(10);
CLOSE POOL;
```

with `HALSFC --parms="LSTALL"`, which produced `HALMAT: 02F(1),0,0`
followed by operand `1(1),0,0` (`POOL`'s own symbol index 1), and closed
by `HALMAT: 030(1),0,0` (`CLOS`) referencing the same index.

## Unresolved Questions

- None for the base case; the block compiled and closed exactly like an
  ordinary `PROGRAM`/`TASK` block, just with no executable statements of
  its own (only declarations).

## Source Analysis & Reliability

Opcode (0x02F) confirmed primary-source: `XCDEF BIT(16) INITIAL("02F")`
in `PASS1.PROCS/##DRIVER.xpl` — see [##DRIVER.xpl] in `STATUS.md`. No
[MSC-01847] (HAL-1971) analog identified under this name. Statement
syntax primary-sourced from [USA003087] §15.2 (PDF p. 178ff). Full
behavioral description and operand-word structure confirmed directly
against real compiled HALMAT this session, as part of a systematic
sweep of USA003087 syntax patterns against previously-untested HALMAT
opcodes (direct user suggestion).
