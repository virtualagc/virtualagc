# BAND

**Mnemonic:** BAND

**Opcode:** 0x102

**Confidence:** High

## Behavioral Description

Bit-string AND. Computes the bitwise logical AND of two bit-string
operands, producing a bit-string result (referenced by later instructions
as a VAC — see [HALMAT.md](../HALMAT.md#word-format)).

## Usage Context

Emitted for HAL/S expressions using the bit-string AND operator.

## `yaHALMAT2` Implementation Notes

A "Programming in HAL/S" corpus sweep (`239-STARTUP.hal`, `250-BITS.hal`,
`262-TEST7.hal`) found `BAND`'s (and sibling `BOR`/`BEQU`/`BNEQ`/
`NEQU`/`NNEQ`'s) runtime operand type-checking too strict: real compiled
HALMAT legitimately feeds these instructions operands whose static type
tag doesn't match a naive expectation (e.g. an `EVENT` symbol read as
part of a compound event-expression, or a `NAME`-typed comparison
operand), previously rejected outright. Fixed by broadening each
instruction's accepted operand kinds to match what the compiler actually
emits, confirmed against each corpus file's own real HALMAT trace rather
than guessed. See task #41 in this project's own tracking for the full
per-opcode breakdown; `class-0/SCHD.md`/`class-0/WAIT.md` describe the
related, larger feature this unblocked (compound `BAND`/`BOR`/`BNOT`
event-expressions in `SCHEDULE ON`/`STOPPING WHILE`/`UNTIL` and
`WAIT FOR`).

A `BAND`-producing instruction is also now a recognized recursion case
in `reevaluate_live_bit_operand()` (`interp.c`): `SCHEDULE ON`/
`STOPPING WHILE`/`UNTIL` and `WAIT FOR` no longer just read a one-time
snapshot of a compound event-expression's value — a `QUAL_VAC` operand
referencing a `BAND` instruction is re-evaluated live (both of `BAND`'s
own operands recursively re-read, then ANDed) every time the expression
is consulted, so `E1 AND E2` correctly waits until *both* events are
independently true rather than latching whatever was true at
schedule-time. Fixtures: `test_sched_on_compound.hal`,
`test_wait_for_compound.hal`.

## Unresolved Questions

- HAL/S operand-word format is unconfirmed; see [STRI](../class-8/STRI.md).
- Whether bit-strings of unequal length are padded/truncated at this
  instruction or handled earlier in expression compilation is unconfirmed.

## Source Analysis & Reliability

Opcode (0x102) confirmed primary-source: `XBAND BIT(16) INITIAL("0102")`
in `PASS1.PROCS/##DRIVER.xpl` — see [##DRIVER.xpl] in `STATUS.md`. Matches
[MSC-01847]'s HAL-1971 BAND opcode (0x102) exactly.

Behavioral description is a straightforward reading of "bit-string and"
corroborated by [MSC-01847] §2.16; no verbatim operand-word prose
transcribed yet.
