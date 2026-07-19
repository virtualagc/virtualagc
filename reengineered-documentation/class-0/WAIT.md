# WAIT

**Mnemonic:** WAIT
**Opcode:** 0x034
**Confidence:** High

## Behavioral Description

`WAIT` statement — a real-time programming statement ([USA003087] §13.5,
PDF p. 168) that places the executing process into a waiting state until
some condition is met. Three forms exist, distinguished by WAIT's own
operand count and a trailing header flag:

- `WAIT interval;` — wait for a duration (interval in seconds).
- `WAIT UNTIL time;` — wait until a specified real time.
- `WAIT FOR DEPENDENT;` — wait until all dependent processes have
  terminated.

## Usage Context

Emitted wherever a `WAIT` statement occurs, typically inside a `TASK`
block (though presumably legal in any process body, per §13.3's
treatment of programs and tasks as symmetric real-time processes).

## Operand-Word Format (confirmed empirically)

All three forms compile to a single WAIT instruction plus a runtime
supervisor call (`SVC`), distinguished as follows:

- **`WAIT interval;`**: one operand, `QUAL`=3=VAC (the stream position of
  the instruction producing `interval`'s value), opcode-line trailing
  field `1`.
- **`WAIT UNTIL time;`**: one operand, `QUAL`=3=VAC (producing `time`'s
  value), opcode-line trailing field `2`.
- **`WAIT FOR DEPENDENT;`**: no operands, opcode-line trailing field `0`.

Confirmed by compiling all three forms with `HALSFC --parms="LSTALL"`:

```
WAIT 5.0;
HALMAT: 5C1(1),0,0          <- scalar-literal load (prepares 5.0)
          1(5),0,0
HALMAT: 034(1),1,0          <- WAIT, trailing field 1 = interval form
         16(3),0,0            <- VAC ref to the 5C1 instruction
LED 0,=5.0
SVC 0,6(0,9)

WAIT UNTIL 10.0;
HALMAT: 5C1(1),0,0
          2(5),0,0
HALMAT: 034(1),2,0          <- WAIT, trailing field 2 = UNTIL form
         22(3),0,0
LED 0,=10.0
SVC 0,8(0,9)

WAIT FOR DEPENDENT;
HALMAT: 034(0),0,0          <- WAIT, no operands, trailing field 0
SVC 0,10(0,9)
```

## Unresolved Questions

- The exact `SVC` call-number-to-form mapping (6, 8, 10 in the trace
  above) is presumably runtime-library convention, not decoded further.

## Source Analysis & Reliability

Opcode (0x034) confirmed primary-source: `XWAIT BIT(16) INITIAL("034")`
in `PASS1.PROCS/##DRIVER.xpl` — see [##DRIVER.xpl] in `STATUS.md`. No
[MSC-01847] (HAL-1971) analog expected (multitasking postdates HAL 1971).
Statement syntax primary-sourced from [USA003087] §13.5 (PDF p. 168).
Full behavioral description, operand-word structure, and the three-form
encoding confirmed directly against real compiled HALMAT this session,
prompted by direct user suggestion that this opcode relates to HAL/S's
real-time programming statements.
