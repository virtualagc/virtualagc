# BFNC

**Mnemonic:** BFNC

**Opcode:** 0x04A

**Confidence:** High

## Behavioral Description

Built-in function call. The general-purpose opcode invoking most of
HAL/S's built-in/library functions ([USA003087] §7.6) — confirmed this
session for the real-time `PRIO` function and 14 of the arithmetic/
algebraic/vector-matrix/character functions from §7.6 (see the selector
table below) — with a trailing header field on the instruction selecting
*which* function. Two built-ins, `MAX`/`MIN`, use a separate opcode
instead — see [LFNC](LFNC.md). Speculated in this project (before this
session) to be HAL/S's split-off of HAL 1971's combined `FUNC`
instruction (which handled both user-defined and built-in function
invocation together) — see [FCAL](FCAL.md) for the user-defined-function
counterpart, now kept separate in HAL/S.

Previously known only from an Optimizer-HALMAT-era special case: when
BFNC's `TAG` field is `0x39` or `0x3A`, it represents a combined sine/
cosine computation (`SINCOS`) — see `HALMAT.md`'s Optimizer HALMAT
section.

## Usage Context

Emitted for any built-in-function call other than `MAX`/`MIN`. Confirmed
across two sessions for `PRIO` (no arguments) and 14 single-argument
functions (arguments passed directly as BFNC's own operand — no
[SFST](SFST.md)/[SFAR](SFAR.md)/[SFND](SFND.md) bracket is used, unlike
[LFNC](LFNC.md)/[MSHP](MSHP.md)/etc.).

## Operand-Word Format (confirmed empirically)

**No-argument form** (e.g. `PRIO`): no operands; the opcode line's
trailing header field alone carries the selector value.

**Single-argument form**: one operand — the argument, `QUAL`=1=SYT (a
plain variable) or presumably `QUAL`=3=VAC (an expression result, not
directly tested) — with the selector still on the opcode line's trailing
header field. The call's result is consumed by the following instruction
via a `VAC`-qualified reference to BFNC's own stream position, same as
any other value-producing instruction.

Confirmed by compiling `I1 = PRIO;` and, separately, each of 15 built-in
functions applied to a plain `SCALAR`/`VECTOR`/`CHARACTER` argument, with
`HALSFC --parms="LSTALL"`:

```
I1 = PRIO;
HALMAT: 04A(0),19,0         <- BFNC, selector 19 = PRIO, no operands
SVC 0,=H'791'                 <- runtime call retrieving the process's own priority

S2 = ROUND(S1);
HALMAT: 04A(1),33,0         <- BFNC, selector 33 = ROUND
          2(1),5,0             <- S1, symbol index 2, QUAL=1=SYT
BAL 4,ROUND                    <- runtime call to a routine literally named ROUND
```

Confirmed selector table (all Class 0 opcode-line trailing-field values):

| Selector | Function | Selector | Function | Selector | Function |
|---|---|---|---|---|---|
| 1 | `ABS` | 15 | `TAN` | 28 | `ABVAL` |
| 2 | `COS` | 19 | `PRIO` | 33 | `ROUND` |
| 5 | `EXP` | 21 | `SIGN` | 40 | `LENGTH` |
| 6 | `LOG` | 24 | `SQRT` | 49 | `INVERSE` |
| 13 | `SIN` | 26 | `TRIM` | 27 | `UNIT` |

(`0x39`/`0x3A` = `SINCOS`, an Optimizer-HALMAT-era special case not
re-confirmed this session — see `HALMAT.md`'s Optimizer HALMAT section.)

## Unresolved Questions

- The full selector-value table is still not exhaustive — untested
  built-ins include `DIV` (2 arguments), `ODD`, `DATE`, `RANDOMG`, and
  the "Additional" functions in [USA003087] Appendix B not covered by
  §7.6's summary list.
- Whether a `VAC`-qualified (expression-result) argument is handled
  identically to the `SYT`-qualified (plain-variable) case tested is
  presumed but not directly confirmed.

## Source Analysis & Reliability

Opcode (0x04A) confirmed primary-source: `XBFNC BIT(16) INITIAL("04A")`
in `PASS1.PROCS/##DRIVER.xpl` — see [##DRIVER.xpl] in `STATUS.md`.
Optimizer-HALMAT-era `SINCOS` special case primary-sourced from
[IR-60-5] A-112 (documented in an earlier session). `PRIO` case
confirmed directly against real compiled HALMAT in an earlier session
(a byproduct of investigating [PRIO](PRIO.md), 0x038). The 14-function
selector table confirmed this session by testing every single-argument
built-in function listed in [USA003087] §7.6 against real compiled
HALMAT, prompted by a search for [LFNC](LFNC.md)'s trigger condition
(which turned out to be the two functions, `MAX`/`MIN`, that this sweep
found *not* using BFNC).
