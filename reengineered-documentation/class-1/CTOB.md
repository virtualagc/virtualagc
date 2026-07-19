# CTOB

**Mnemonic:** CTOB
**Opcode:** 0x141
**Confidence:** High

## Behavioral Description

Character to bit string conversion. Converts a character-string operand
to its bit-string representation ([USA003087] §21.3, the "simple form"
of the `BIT(...)` conversion function applied to a CHARACTER argument).
Classed under Class 1 (bit) because HALMAT classes conversion operators
by their *result* type.

## Usage Context

Emitted for the HAL/S built-in shaping function `BIT(...)` applied to a
CHARACTER argument. Also handles the *subscripted* result form
(`BITsubscript(exp)`, [USA003087] §21.3 rule 4 — component subscripting
on the conversion's own result) directly on itself, with two extra
operands, rather than routing through a separate opcode — this was
tested directly this session while investigating the still-unresolved
[BTOQ](../class-1/BTOQ.md) family (one hypothesis was that a subscripted
conversion-result might trigger `BTOQ`; it doesn't).

## Operand-Word Format (confirmed empirically)

**Unsubscripted** (`BIT(C1)`): one operand, `DATA`=symbol-table index of
the character source, `QUAL`=1=SYT.

**Subscripted** (`BIT9 TO 16(C1)`): three operands — the same source
operand, followed by two `IMD`-qualified operands for the subscript
range's start and end. Confirmed by compiling both forms with
`HALSFC --parms="LSTALL"`:

```
B1 = BIT(C1);
HALMAT: 141(1),0,0
          2(1),0,0             <- C1, symbol index 2, QUAL=1=SYT

B1 = BIT9 TO 16(C1);
HALMAT: 141(3),0,0
          2(1),0,0             <- C1, symbol index 2, QUAL=1=SYT
          9(6),2,1              <- literal 9 (subscript start), QUAL=6=IMD
         16(6),2,0              <- literal 16 (subscript end), QUAL=6=IMD
LA 2,C1 / SCAL 0,#QCTOB          <- both forms call the runtime routine #QCTOB
```

## Unresolved Questions

- None remaining for the base cases (unsubscripted and subscripted).

## Source Analysis & Reliability

Opcode (0x141) confirmed primary-source: element 1 of the `XBTOB(5)`
array in `PASS1.PROCS/##DRIVER.xpl` — see [##DRIVER.xpl] in `STATUS.md`.
Not present in [MSC-01847]. Statement syntax primary-sourced from
[USA003087] §21.3 (PDF p. 261ff). Both operand-word forms confirmed
directly against real compiled HALMAT this session.
