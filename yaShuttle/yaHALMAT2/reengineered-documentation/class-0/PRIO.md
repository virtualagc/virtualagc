# PRIO

**Mnemonic:** PRIO

**Opcode:** 0x038

**Confidence:** High

## Behavioral Description

`UPDATE PRIORITY` statement — a real-time programming statement
([USA003087] §13.5, PDF pp. 169–170) that changes the priority of an
active process. Its HAL/S form is `UPDATE PRIORITY [label] TO α;` (`label`
optional, defaulting to the executing process itself; `α` an integer
expression giving the new priority).

**Naming note**: despite the mnemonic (from `##DRIVER.xpl`'s `XPRIO`),
this opcode is *not* used for the `PRIO` built-in function (which returns
the invoking process's own priority as an integer, per §13.5's "Real
Time Built-In Functions" table) — that instead compiles through the
general built-in-function-call opcode, [BFNC](BFNC.md) (0x04A). See that
file's Source Analysis for the confirming trace.

## Usage Context

Emitted wherever an `UPDATE PRIORITY` statement occurs. Only the named-
process form was tested — see Unresolved Questions for the unlabeled
(self) form.

## Operand-Word Format (confirmed empirically)

Two operands: operand 1 = `DATA`=literal-table index of the new priority
value, `QUAL`=5=LIT; operand 2 = `DATA`=symbol-table index of the named
process, `QUAL`=1=SYT. Confirmed by compiling `UPDATE PRIORITY MYTASK TO
16;` with `HALSFC --parms="LSTALL"`:

```
HALMAT: 038(2),1,0          <- PRIO (UPDATE PRIORITY statement)
          4(5),0,0            <- literal idx 4 (value 16), QUAL=5=LIT
          4(1),0,0            <- MYTASK, symbol index 4, QUAL=1=SYT
SVC 0,23(0,9)                 <- runtime priority-update routine
```

## Unresolved Questions

- The unlabeled/self form (`UPDATE PRIORITY TO α;`, no process name) was
  not tested — presumably drops the second operand (paralleling
  [CANC](CANC.md)'s self- vs. named-process distinction), but unconfirmed.
- Whether `α` may be a general integer expression (rather than the
  literal tested here) changes the first operand's `QUAL` to `VAC` (as
  seen elsewhere for expression results) is a reasonable but untested
  assumption.

## Source Analysis & Reliability

Opcode (0x038) confirmed primary-source: `XPRIO BIT(16) INITIAL("038")`
in `PASS1.PROCS/##DRIVER.xpl` — see [##DRIVER.xpl] in `STATUS.md`. No
[MSC-01847] (HAL-1971) analog expected (multitasking postdates HAL 1971).
Statement syntax primary-sourced from [USA003087] §13.5 (PDF pp.
169–170). Full behavioral description and operand-word structure
confirmed directly against real compiled HALMAT this session, prompted
by direct user suggestion that this opcode relates to HAL/S's real-time
programming statements (`PRIORITY`/`PRIO`) — the distinction from the
`PRIO` built-in function (which turned out to use a different opcode,
[BFNC](BFNC.md)) was a byproduct discovery of the same test.
