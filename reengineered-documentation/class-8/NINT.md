# NINT

**Mnemonic:** NINT

**Opcode:** 0x8E1

**Confidence:** High

## Behavioral Description

NAME (pointer) initialize. Initializes a `NAME` data item with a pointer
value in a "static bypass block" ([USA003087] §28.6, `DECLARE NS1 NAME
SCALAR INITIAL(NAME(S1))`, or `INITIAL(NULL)`), the class-8 counterpart
of [SINT](SINT.md)/[IINT](IINT.md)/etc. for pointer-typed data.

## Usage Context

Appears within a "static bypass block" alongside the other initialization
operators for every `NAME` data item declared with an `INITIAL(...)`
specification; see [BINT](BINT.md) for the general pattern.

## Operand-Word Format (confirmed empirically)

Two operands: operand 1 = the `NAME` data item being initialized,
`DATA`=its symbol-table index, `QUAL`=1=SYT; operand 2 = the initial
pointer value, either `DATA`=symbol-table index of the target,
`QUAL`=1=SYT (real pointer) or `DATA`=0, `QUAL`=6=IMD (`NULL`). Both
forms carry an unusual, consistent non-zero trailing header field
(`133`) not seen on any other tested opcode — presumably a bit pattern
flagging NAME/pointer semantics generally (it also appears on the
pointer-argument form of [XXAR](../class-0/XXAR.md), see that file's
Behavioral Description).

Confirmed by compiling `DECLARE NS1 NAME SCALAR INITIAL(NAME(S1)), NS2
NAME SCALAR INITIAL(NULL);` with `HALSFC --parms="LSTALL"`:

```
HALMAT: 8E1(2),133,0          <- NINT: NS1 initialized to point at S1
          5(1),0,0               <- NS1, symbol index 5, QUAL=1=SYT
          2(1),0,0               <- S1, symbol index 2, QUAL=1=SYT

HALMAT: 8E1(2),133,0          <- NINT: NS2 initialized to NULL
          6(1),0,0               <- NS2, symbol index 6, QUAL=1=SYT
          0(6),0,0               <- literal 0, QUAL=6=IMD (the null-pointer sentinel)
```

## Unresolved Questions

- The exact meaning of the recurring `133` trailing header value is not
  decoded at the bit level.
- Initialization of `NAME` structure terminals, and `NAME PROGRAM`/`NAME
  TASK` pointer variables, were not tested.

## Source Analysis & Reliability

Opcode (0x8E1) confirmed primary-source: `XNINT BIT(16) INITIAL("8E1")`
in `PASS1.PROCS/##DRIVER.xpl` — see [##DRIVER.xpl] in `STATUS.md`; no
HAL-1971 analog (opcode range 0xE1–0xE3 unused in HAL 1971's Class 8,
since the `NAME` facility postdates that language). Statement syntax
primary-sourced from [USA003087] §28.6 (PDF p. 375ff). Full behavioral
description and operand-word structure confirmed directly against real
compiled HALMAT this session, as part of a systematic sweep of
USA003087 syntax patterns against previously-untested HALMAT opcodes
(direct user suggestion).
