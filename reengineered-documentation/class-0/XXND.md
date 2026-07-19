# XXND

**Mnemonic:** XXND
**Opcode:** 0x026
**Confidence:** High

## Behavioral Description

Argument-list statement end. Closes the HALMAT construct opened by
[XXST](XXST.md), following the header instruction
([READ](READ.md)/[RDAL](RDAL.md)/[WRIT](WRIT.md)/[PCAL](PCAL.md)/
[FCAL](FCAL.md)) and its [XXAR](XXAR.md) argument list. Fixed-format, no
operands (`NUMOP`=0) — confirmed for both the I/O and procedure/
function-call cases this session.

## Usage Context

Always the last instruction of a `READ`/`READALL`/`WRITE`/`CALL`/
function-invocation construct — see [XXST](XXST.md) for the full
bracketing pattern and worked traces of both cases.

## Unresolved Questions

- None beyond the general caveats noted for [XXST](XXST.md)/[XXAR](XXAR.md).

## Source Analysis & Reliability

Opcode (0x026) confirmed primary-source: `XXXND BIT(16) INITIAL("026")`
in `PASS1.PROCS/##DRIVER.xpl` — see [##DRIVER.xpl] in `STATUS.md`. Not
present in [MSC-01847]. Confirmed against real compiled HALMAT this
session — see [XXST](XXST.md) for the full trace.
