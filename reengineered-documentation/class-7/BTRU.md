# BTRU

**Mnemonic:** BTRU
**Opcode:** 0x720
**Confidence:** High

## Behavioral Description

Bit-is-true test. The universal mechanism for converting any bit-string-
typed value into the branch-testable condition consumed by
[FBRA](../class-0/FBRA.md) (and presumably other conditional constructs).
Covers every case where HAL/S allows a bit-string-derived value to serve
as a Boolean condition ([USA003087] §17.6, "Bit Strings in Conditional
Constructs" — a bit string subscripted down to one bit; §24.7, "Events in
Boolean Context" — an `EVENT` data item, or a combined bit expression
involving one, used directly).

Not part of any of HALMAT's usual "convert to X" arrays (`XBTOI`,
`XBTOS`, etc.) — declared as a single, standalone constant in the
compiler source, reflecting its role as a generic "make this bit value
branch-testable" operator rather than a type-conversion function proper.

## Usage Context

Appears immediately before an [FBRA](../class-0/FBRA.md) (or presumably
[BRA](../class-0/BRA.md)/[DTST](../class-0/DTST.md)/[CTST](../class-0/CTST.md)
in other conditional contexts, untested), consuming whatever bit-typed
value the condition ultimately reduces to — either directly (a single
`EVENT` or already-subscripted-to-one-bit `BIT` variable) or via a `VAC`
reference to a preceding bit-combining instruction (e.g.
[BOR](../class-1/BOR.md) for `EV1|EV2`).

## Operand-Word Format (confirmed empirically)

One operand, whose `QUAL` depends on what's being tested:

- `QUAL`=1=SYT, `DATA`=symbol-table index, when the condition is a single
  data item used directly (e.g. a plain `EVENT` variable: `IF EV1 THEN
  ...;`).
- `QUAL`=3=VAC, `DATA`=stream position of the producing instruction, when
  the condition is itself a computed bit expression (e.g. a
  [DSUB](../class-0/DSUB.md)-subscripted bit, or a
  [BOR](../class-1/BOR.md)-combined pair of events).

Confirmed by compiling three cases with `HALSFC --parms="LSTALL"`:

```
IF B1                                  <- B1 a 4-bit BIT STRING
S             2
THEN X1 = 0; ELSE X1 = 1;

HALMAT: 019(2),1,0            <- DSUB: B1 subscripted to bit 2
          2(1),0,0
          2(6),1,0
HALMAT: 720(1),0,0            <- BTRU
         15(3),0,0               <- VAC ref to the DSUB instruction
TB B1,4                         <- "Test Bit" machine instruction

IF EV1 THEN B1 = FALSE; ELSE B1 = TRUE;   <- EV1 a plain EVENT

HALMAT: 720(1),0,0            <- BTRU
          3(1),0,0               <- EV1, symbol index 3, QUAL=1=SYT (direct)
TB EV1,1

IF EV1|EV2 THEN ...;            <- EV1, EV2 both EVENT

HALMAT: 103(2),0,0            <- BOR: EV1 | EV2
          3(1),0,0
          4(1),0,0
LH 5,EV1 / NHI 5,1 / LH 6,EV2 / NHI 6,1 / OR 5,6
HALMAT: 720(1),0,0            <- BTRU
         36(3),0,0               <- VAC ref to the BOR instruction
```

## Unresolved Questions

- Whether BTRU is also used for `DO WHILE`/`DO UNTIL` conditions
  involving bit expressions (as opposed to the `IF` statement cases
  tested) is unconfirmed.
- Whether a process name used as a Boolean ("process events," §24.8,
  `IF ALPHA THEN ...;`) also routes through BTRU was not tested, though
  it seems overwhelmingly likely given the identical "bit-backed value
  used as a Boolean" pattern.

## Source Analysis & Reliability

Opcode (0x720) confirmed primary-source: `XBTRU BIT(16) INITIAL("720")`
in `PASS1.PROCS/##DRIVER.xpl` — see [##DRIVER.xpl] in `STATUS.md`; a
previously-undocumented opcode, discovered this session while
investigating the [BTOQ](../class-1/BTOQ.md) family (BTRU turned out to
be the real mechanism for bit-in-conditional-context, not BTOQ). No
[MSC-01847] (HAL-1971) analog identified. Statement syntax primary-
sourced from [USA003087] §17.6 (PDF p. 195ff) and §24.7 (PDF p. 311ff).
Full behavioral description and operand-word structure confirmed
directly against real compiled HALMAT this session.
