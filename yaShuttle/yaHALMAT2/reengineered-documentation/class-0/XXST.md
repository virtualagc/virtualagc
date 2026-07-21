# XXST

**Mnemonic:** XXST

**Opcode:** 0x025

**Confidence:** High

## Behavioral Description

Argument-list statement start. A general-purpose bracketing construct,
not specific to I/O: begins the HALMAT construct for a `READ`,
`READALL`, or `WRITE` statement (immediately preceding the
[READ](READ.md)/[RDAL](RDAL.md)/[WRIT](WRIT.md) header), **and also** —
confirmed this session — a `CALL` (procedure invocation) or function
invocation, immediately preceding [PCAL](PCAL.md)/[FCAL](FCAL.md).

**Corrected this session** (via an independent cross-check against real
compiled HALMAT binaries using `unHALMAT.py`, not just the PASS2
`LSTALL` text report): for the I/O case, XXST carries **only one**
`IMD`-qualified operand — the I/O-statement-kind code (`0`=READ,
`1`=READALL, `2`=WRITE). The logical device number is **not** on XXST at
all; it's carried by the corresponding [READ](READ.md)/[RDAL](RDAL.md)/
[WRIT](WRIT.md) header instruction's own operand instead (see those
files, also corrected this session). The earlier "two operands on XXST"
claim was a misreading of the PASS2 text report — see Usage Context
below for how the error happened and how it was caught. For the
procedure/function-call case, XXST carries a single `SYT`-qualified
operand referencing the called block's own symbol, with a trailing
header flag distinguishing procedure-call (`0`) from function-invocation
(`1`) — see the second worked example below; this half was already
correct.

## Usage Context

Always the first instruction of a `READ`/`READALL`/`WRITE`/`CALL`/
function-invocation construct, followed by one [XXAR](XXAR.md) per
argument, then the corresponding header instruction
([READ](READ.md)/[RDAL](RDAL.md)/[WRIT](WRIT.md)/[PCAL](PCAL.md)/
[FCAL](FCAL.md)), then a closing [XXND](XXND.md). Confirmed by compiling
`READ(5) I1; WRITE(6) S1;` with `HALSFC --parms="LISTING2,LSTALL"` and
cross-checking both the `pass2.rpt` text report and a direct
`unHALMAT.py halmat.bin` read of the same compiled binary:

```
HALMAT #14 (0x025, XXST)  op: DATA=0 (READ), QUAL=6=IMD        <- XXST's only operand
HALMAT #16 (0x027, XXAR)  op: I1, symbol index 2, QUAL=1=SYT
HALMAT #18 (0x01F, READ)  op: DATA=5 (device number), QUAL=6=IMD  <- READ's own operand
HALMAT #20 (0x026, XXND)
```

(`unHALMAT.py` instruction numbers shown; the `WRITE(6)` case is
identical in shape, kind code `2`, device number `6` on the `WRIT`
header.) **How the earlier "two operands on XXST" reading happened**:
`pass2.rpt`'s `LSTALL` text report prints each operand word directly
below the instruction line it *visually* follows, but its own `:0.N`
stream-position tag is the only reliable indicator of which instruction
an operand actually belongs to — READ's device-number operand (tagged
`:0.19` in this trace) was printed directly under XXST's block, right
after XXST's own operand (tagged `:0.15`), creating the appearance of
two consecutive operands on XXST when the true stream order is
XXST(14)→op(15)→XXAR(16)→op(17)→READ(18)→op(19)→XXND(20). This is the
same category of report-ordering artifact already known for `SMRK` (see
`STATUS.md`'s Phase 2 Resources notes) — cross-checking against
`unHALMAT.py`'s direct binary read (which has no such ambiguity) caught
it. See [READ](READ.md) for the corrected per-instruction account.

**Procedure/function call case**, confirmed by compiling `CALL
TWO(I1) ASSIGN(I1);` (TWO a `PROCEDURE(A) ASSIGN(C);`) and `S1 = S1 +
FUNC1(S1);` (FUNC1 a `FUNCTION(X) SCALAR;`):

```
CALL TWO(I1) ASSIGN(I1);
HALMAT: 025(1),0,0        <- XXST, trailing field 0 = procedure call
          4(1),0,0           <- op: TWO, symbol index 4, QUAL=1=SYT
HALMAT: 027(1),0,0        <- XXAR: I1 as input argument
          2(1),6,0           <- I1, symbol index 2, QUAL=1=SYT
HALMAT: 027(1),0,0        <- XXAR: I1 as assign argument (trailing sub-flag 1, vs 0 for input)
          2(1),6,1
HALMAT: 01D(1),0,0        <- PCAL (procedure call header), operand: TWO, symbol index 4
HALMAT: 026(0),0,0        <- XXND (end)

S1 = S1 + FUNC1(S1);
HALMAT: 025(1),1,0        <- XXST, trailing field 1 = function invocation
          7(1),0,0           <- op: FUNC1, symbol index 7, QUAL=1=SYT
HALMAT: 027(1),1,0        <- XXAR: S1 as input argument
          3(1),5,0
HALMAT: 01E(1),1,0        <- FCAL (function call header), operand: FUNC1, symbol index 7
HALMAT: 026(0),1,0        <- XXND (end)
                             <- (the function's return value is then referenced by a
                                VAC operand pointing at FCAL's own stream position)
```

This confirms `XXST`/`XXAR`/`XXND` is a genuinely general "bracketed
argument list" construct used for I/O statements and block invocations
alike, not an I/O-specific mechanism — and rules out an earlier
hypothesis that a separate opcode family (`PMHD`/`PMAR`/`PMIN`) might be
involved in argument passing; see [PMHD](PMHD.md).

## Unresolved Questions

- ~~The exact enumeration of the I/O-statement-kind code~~ **Resolved**:
  0=READ, 1=READALL, 2=WRITE, confirmed by compiling
  `READALL(5) PAGE(1), COLUMN(2), C1;` (see [XXAR](XXAR.md)'s Usage
  Context for the full trace). The procedure/function-call trailing-field
  values (0=CALL, 1=function invocation) are a separate, non-overlapping
  use of the same field position.
- Whether `FILE` statements/pseudo-variable use this same XXST/XXAR/XXND
  construct, or something else, is resolved — **they don't**; see
  [FILE](FILE.md), which uses an entirely different, non-bracketed
  encoding.
- **Resolved this session**: HAL 1971's I/O column/line/page/skip/tab
  control specifiers (`FCLM`/`FLIN`/`FPGE`/`FSKP`/`FTAB`) turned out not
  to need any change to XXST/XXND at all — each specifier is just an
  ordinary [XXAR](XXAR.md) entry in the bracketed argument list,
  distinguished from a plain variable argument only by that XXAR's own
  `TAG2` field. See [XXAR](XXAR.md) for the full mechanism and worked
  traces.

## Source Analysis & Reliability

Opcode (0x025) confirmed primary-source: `XXXST BIT(16) INITIAL("025")`
in `PASS1.PROCS/##DRIVER.xpl` — see [##DRIVER.xpl] in `STATUS.md`. Not
present in [MSC-01847] under this name. [MSC-01847]'s HAL-1971
predecessor instructions carry the device number directly on
READ/RDAL/WRIT/FILE — **now confirmed this session to be exactly what
HAL/S also does** (the device number sits on READ/RDAL/WRIT itself, not
on XXST), reversing an earlier, incorrect "XXST carries it" conclusion.
Full behavioral description and operand-word structure directly
confirmed against real compiled HALMAT this session, cross-checked via
both `pass2.rpt`'s `LSTALL` report and a direct `unHALMAT.py` binary
read (see Usage Context for how the two methods disagreed and why
`unHALMAT.py`'s reading is authoritative).
