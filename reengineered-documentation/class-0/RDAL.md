# RDAL

**Mnemonic:** RDAL

**Opcode:** 0x020

**Confidence:** High

## Behavioral Description

Read-all header. Marks the point, inside a `READALL` statement's HALMAT
construct, where the actual read operation is performed — structurally
identical to [READ](READ.md), differing only in the statement it
represents. `NUMOP`=1: a single `IMD`-qualified operand giving the
statement's device number. **Corrected this session** (a previous
version of this file, from the same session that first investigated I/O
control specifiers, claimed RDAL carries no operand at all — that was
based on a misreading of `pass2.rpt`'s text report, which visually
prints an operand under the wrong instruction; see [XXST](XXST.md) and
[READ](READ.md) for the full account and how a direct `unHALMAT.py`
binary read caught it).

## Usage Context

Begins the HALMAT construct for a READALL statement; see [READ](READ.md)
for the general pattern and [XXST](XXST.md)/[XXAR](XXAR.md) for the full
bracketing construct. Confirmed by compiling
`READALL(5) PAGE(1), COLUMN(2), C1;` (`C1` a `CHARACTER(10)`) with
`HALSFC --parms="LISTING2,LSTALL"` and reading the compiled binary
directly with `unHALMAT.py`:

```
HALMAT #9  (0x025, XXST)   op: DATA=1 (READALL), QUAL=6=IMD   <- XXST's only operand: the kind code
HALMAT #11 (0x027, XXAR)   op: PAGE(1)'s literal
HALMAT #13 (0x027, XXAR)   op: COLUMN(2)'s literal
HALMAT #15 (0x027, XXAR)   op: C1, symbol index 2, QUAL=1=SYT
HALMAT #17 (0x020, RDAL)   op: DATA=5, QUAL=6=IMD             <- RDAL's own operand: the device number
HALMAT #19 (0x026, XXND)
```

See [XXAR](XXAR.md)'s Usage Context for the full operand-level trace of
the `PAGE`/`COLUMN` entries (unaffected by this correction — only the
device-number attribution changed), including confirmation that READALL
is XXST's I/O-statement-kind code `1` (vs. 0=READ, 2=WRITE).

## Unresolved Questions

- None remaining specific to this instruction.

## Source Analysis & Reliability

Opcode (0x020) and mnemonic are primary-sourced from [IR-60-5] A.2 (p.
A-103); no page content for RDAL's own HAL/S description (target p. 62) is
present in the available partial copy.

Behavioral description drawn from [MSC-01847] p. 2-13, describing the
identically-named predecessor-language instruction (HAL 1971 opcode 0x02F,
differing from HAL/S's 0x020) — which also carries the device number on
its own operand, consistent with HAL/S's behavior confirmed here. See
[STRI](../class-8/STRI.md)'s Source Analysis section for the general
basis of this cross-language inference. Operand-word structure directly
confirmed against real compiled HALMAT this session via both `pass2.rpt`
(position-tag-verified) and an independent `unHALMAT.py` binary read —
see [XXST](XXST.md) for the full account of the earlier misreading.
