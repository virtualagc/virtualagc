# IMRK

**Mnemonic:** IMRK

**Opcode:** 0x003

**Confidence:** High

## Behavioral Description

Statement marker for source statements that lie within an inline function
block. IMRK follows the generated HALMAT code for each such HAL/S source
statement, playing the same structural role that [SMRK](SMRK.md) plays for
statements outside inline function blocks.

```
 31         24 23         16 15      12 11         4  3    1 0
+------------+------------+---------+------------+------+---+
| error tag  |     1      |   003   |     N      |  0   | 0 |
+------------+------------+---------+------------+------+---+
```

- **TAG (error tag)** — maximum statement error severity; 0 if no errors.
- **NUMOP** — 1.
- **OPCODE** — 0x003.
- **N** (low bit of the COPT-position field) — 0 for statements with no
  HALMAT code, 1 otherwise (per [Halmat.pdf]; [IR-60-5] draws this bit
  without naming it explicitly).

One operand word follows:

```
 31              16 15       8 7      4 3    1 0
+-----------------+---------+--------+------+---+
| statement number|  DEBUG  |(unused)|  0   | 1 |
+-----------------+---------+--------+------+---+
```

- **DATA (statement number)** — the source statement number, generated in
  Phase 1 (PASS1); presumed sequential in encounter order, not confirmed.
- **TAG1 (DEBUG)** — a number used for compiler testing; normally 0.
- **QUAL** — 0 (don't care).

## Usage Context

Appears once per HAL/S source statement inside an inline function block,
immediately after that statement's generated HALMAT code. Outside inline
function blocks, [SMRK](SMRK.md) is used instead. Empirically confirmed
this session by compiling an inline function (`FUNCTION SCALAR; RETURN
S1; CLOSE; **2;`, [USA003087] §29.5) with `HALSFC --parms="LSTALL"` —
IMRK appeared three times, bracketing the block's `RETURN` statement,
the [ICLS](ICLS.md) closing instruction, and the resumed outer-expression
continuation after the inline function's invocation point — see
[IDEF](IDEF.md) for the full worked trace.

## Unresolved Questions

- The exact meaning/purpose of the "N"/"C" bit distinguishing statements
  with vs. without HALMAT code is not fully explained in the available
  source material.

## Source Analysis & Reliability

Primary-sourced from [IR-60-5] p. A-7 (operator- and operand-word diagrams,
field widths, and the two prose notes on error tag and statement number).
[Halmat.pdf] corroborates the format and adds the "N=C bit" and "DEBUG"
field names, plus compiler-source excerpts (`EMITSMRK.xpl`) — those two
field names and the compiler-source cross-references are secondary and not
independently confirmed.
