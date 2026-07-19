# CANC

**Mnemonic:** CANC

**Opcode:** 0x036

**Confidence:** High

## Behavioral Description

`CANCEL` statement — a real-time programming statement ([USA003087]
§23.6, PDF p. 292) that gracefully cancels a cyclic (or, with no effect
unless not-yet-initiated, non-cyclic) process. Two forms: self-
cancellation (`CANCEL;`, no name) and named-process cancellation
(`CANCEL label;`), distinguished by operand count.

## Usage Context

Emitted wherever a `CANCEL` statement occurs. The multi-name list form
(`CANCEL A,B,C;`) was not tested this session — see Unresolved Questions.

## Operand-Word Format (confirmed empirically)

- **Self form** (`CANCEL;`): no operands, opcode-line trailing field `0`.
- **Named form** (`CANCEL label;`): one operand, `DATA`=symbol-table
  index of the named process (task), `QUAL`=1=SYT, opcode-line trailing
  field `1`.

Confirmed by compiling both forms with `HALSFC --parms="LSTALL"`:

```
CANCEL;                       <- self form, inside the MYTASK block
HALMAT: 036(0),0,0
SVC 0,14(0,9)

CANCEL MYTASK;                <- named form
HALMAT: 036(1),1,0
          4(1),0,0              <- MYTASK, symbol index 4, QUAL=1=SYT
SVC 0,21(0,9)
```

## Unresolved Questions

- The multi-name list form (`CANCEL ALPHA,BETA,GAMMA;`) was not tested —
  presumably one operand per name, or repeated CANC instructions, but
  unconfirmed.

## Source Analysis & Reliability

Opcode (0x036) confirmed primary-source: `XCANC BIT(16) INITIAL("036")`
in `PASS1.PROCS/##DRIVER.xpl` — see [##DRIVER.xpl] in `STATUS.md`. No
[MSC-01847] (HAL-1971) analog expected (multitasking postdates HAL 1971).
Statement syntax primary-sourced from [USA003087] §23.6 (PDF p. 292).
Full behavioral description and both forms' operand-word structure
confirmed directly against real compiled HALMAT this session, prompted
by direct user suggestion that this opcode relates to HAL/S's real-time
programming statements.
