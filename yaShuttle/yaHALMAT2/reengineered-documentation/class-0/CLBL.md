# CLBL

**Mnemonic:** CLBL

**Opcode:** 0x00D

**Confidence:** High

## Behavioral Description

Computed-branch label. Indicates one destination of a computed branch
specified by a companion instruction — confirmed this session to be
[DCAS](DCAS.md) (`DO CASE`'s header instruction; in the predecessor
language HAL, the analogous originating instruction was CBRA). Each
CLBL marks one case's entry point; the whole construct is closed by
[ECAS](ECAS.md).

## Usage Context

Appears once per case/alternate at each possible destination of a
[DCAS](DCAS.md) computed branch — one per statement in the `DO CASE`
group, in source order — plus, in the (no-`ELSE`) case tested, one final
CLBL immediately before the closing [ECAS](ECAS.md), distinguished from
the ordinary ones only by its trailing header field (see Operand-Word
Format — this final CLBL is not actually a distinct one-operand form,
see below). **Resolved in the Maintenance phase**: this final CLBL is
not a runtime-error trap — [DCAS](DCAS.md) never jumps to it via the
selector at all (an out-of-range selector simply doesn't branch); it's
reached only by ordinary sequential fall-through when no `ELSE` clause
is present, at which point it acts as any other CLBL would if fallen
into rather than jumped to — an immediate implicit branch to
[ECAS](ECAS.md), i.e. a no-op. See [DCAS](DCAS.md)'s own Unresolved
Questions for the full account, including the `ELSE`-clause case (which
compiles as plain in-line code before case 1's CLBL, not as a CLBL at
all).

## Operand-Word Format (confirmed empirically)

Two operands, always — including the "final" CLBL described below.
Operand 1 = `DATA`=the enclosing `DO CASE` construct's identifier
(matching [DCAS](DCAS.md)'s own first operand), `QUAL`=2=GLI/INL;
operand 2 = `DATA`=an internal assembler branch-label number (rendered
as `L#<n>` in the generated code — this is the actual computed-branch
target address), also `QUAL`=2=GLI/INL.

Confirmed by compiling the `DO CASE` construct documented in
[DCAS](DCAS.md):

```
HALMAT: 00D(2),0,0        <- CLBL, case 1
          1(2),0,0          <- op 1: construct id 1 (matches DCAS), QUAL=2=GLI/INL
          5(2),0,0          <- op 2: label number 5, QUAL=2=GLI/INL
000011:L#5 EQU *            <- case 1's entry point

HALMAT: 00D(2),0,0        <- CLBL, case 2
          1(2),0,0          <- op 1: construct id 1
GOT STAK 1
000013:  BC   7,L#1          <- (end of case 1's body: branch to ECAS's join point)
          7(2),0,0          <- op 2: label number 7
000015:L#7 EQU *            <- case 2's entry point
```

...and so on for cases 3–5 (label numbers 9, 11, 13). The last CLBL
before [ECAS](ECAS.md), corresponding to the closing `END;` rather than
a numbered case, has a nonzero trailing header field (`00D(2),1,0` vs.
`00D(2),0,0` for the ordinary cases) but **the same two-operand shape** —
`DATA`=construct id, then `DATA`=its own label number, exactly like every
other CLBL.

**Corrected this session**: an earlier session's reading (from
`pass2.rpt`'s `LSTALL` text report) had concluded this final CLBL was an
atypical *single*-operand form, missing its own label operand — the same
kind of report print-ordering artifact already identified and corrected
for [READ](READ.md)/[DFOR](DFOR.md) (see [XXST](XXST.md) for the general
account). Cross-checking a fresh compile of a 3-case `DO CASE` construct
directly with `unHALMAT.py` (`HALSFC --parms="LISTING2,LSTALL"`) shows
the operator word itself declares `CLBL(2)` (`NUMOP`=2, read straight
from the binary — unambiguous) for all four CLBLs in that test,
including the trailing one, each followed by exactly two operand lines.

## Unresolved Questions

- ~~The final CLBL's *purpose* is still not fully understood~~
  **Resolved (Maintenance phase)** — see Usage Context above and
  [DCAS](DCAS.md)'s Unresolved Questions for the full account.
- Whether CLBL is used for any other kind of computed branch besides
  `DO CASE` is unconfirmed — no other DCAS-like header instruction is
  currently known.

## Source Analysis & Reliability

Opcode (0x00D) and mnemonic are primary-sourced from [IR-60-5] A.2 (p.
A-103); no page content for CLBL's own HAL/S description (target p. 51) is
present in the available partial copy. Companion instruction identified
as [DCAS](DCAS.md) this session (opcode confirmed via [##DRIVER.xpl]),
prompted by direct user suggestion that DCAS/ECAS relate to `DO CASE`.
Operand-word format and machine-code correlation confirmed directly
against real compiled HALMAT in an earlier session; the final CLBL's
true two-operand shape confirmed in a later session via a direct
`unHALMAT.py` binary read, correcting the earlier single-operand
misreading (see Operand-Word Format above).

Original behavioral description drawn from [MSC-01847] p. 2-2, describing
the identically-named predecessor-language instruction (HAL 1971 opcode
0x009, differing from HAL/S's 0x00D), and p. 3-11's worked DO CASE
example; now superseded/confirmed by direct HAL/S empirical testing.
