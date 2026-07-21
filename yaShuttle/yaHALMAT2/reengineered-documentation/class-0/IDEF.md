# IDEF

**Mnemonic:** IDEF

**Opcode:** 0x051

**Confidence:** High

## Behavioral Description

Inline function definition header. Marks the start of an inline function
block ([USA003087] §29.5) — a parameterless `FUNCTION` block with no
label, whose definition doubles as its sole invocation point (e.g. `X =
X + FUNCTION SCALAR; RETURN X; CLOSE; **2;`). The compiler assigns the
block an internal generated name (observed `$FUNCTION1`) and compiles it
essentially as a nested subroutine, invoked in place via branch-and-link
right where it's written.

## Usage Context

Begins the HALMAT construct for every inline function block, immediately
followed by an [IMRK](IMRK.md) (inline-function statement marker)
bracketing each statement inside the block body, an [EDCL](EDCL.md) for
the block's own declarations-to-executable boundary, the block's
statements (typically ending in a [RTRN](RTRN.md)), and a closing
[ICLS](ICLS.md).

## Operand-Word Format (confirmed empirically)

One operand: `DATA`=symbol-table index of the compiler-generated internal
name for the inline function block, `QUAL`=1=SYT. Confirmed by compiling
`S1 = S1 + FUNCTION SCALAR; RETURN S1; CLOSE; **2;` with
`HALSFC --parms="LSTALL"`:

```
HALMAT: 031(0),1,0            <- EDCL (outer block's declarations boundary)
HALMAT: 051(1),1,0            <- IDEF
          3(1),0,0               <- $FUNCTION1's own symbol index, QUAL=1=SYT
BAL 4,A1SWEEPK                  <- branch-and-link, invoking the inline block in place
HALMAT: 003(1),0,0            <- IMRK (brackets the RETURN statement below)
HALMAT: 031(0),0,0            <- EDCL (inline block's OWN declarations boundary)
HALMAT: 032(1),0,0            <- RTRN (the inline function's RETURN S1;)
          2(1),5,0
HALMAT: 003(1),0,0            <- IMRK
HALMAT: 052(1),1,0            <- ICLS (see ICLS.md)
BCRE 7,4                        <- returns control to the enclosing expression
HALMAT: 003(1),0,0            <- IMRK (brackets the resumed **2; continuation)
HALMAT: 572(2),0,0            <- SPEX (the **2 exponentiation)
HALMAT: 5AB(2),0,0            <- SADD (S1 + <inline function result>)
HALMAT: 501(2),0,0            <- SASN (final assignment to S1)
```

This also confirms [IMRK](IMRK.md)'s documented role (previously
inferred, not empirically confirmed) — it genuinely brackets each
statement inside an inline-function context, appearing three times here:
around the block's own body statement, around the [ICLS](ICLS.md)
closing, and around the resumed outer-expression continuation.

## Unresolved Questions

- Inline functions with local data declarations (rather than just a bare
  `RETURN`) were not tested.
- Whether a `CHARACTER`-result or other non-`SCALAR` inline function
  changes IDEF's own encoding was not tested.

## Source Analysis & Reliability

Opcode (0x051) confirmed primary-source: `XIDEF BIT(16) INITIAL("051")`
in `PASS1.PROCS/##DRIVER.xpl` — see [##DRIVER.xpl] in `STATUS.md`; not
present in [IR-60-5]'s partial index. No [MSC-01847] (HAL-1971) analog
identified (inline functions postdate HAL 1971). Statement syntax
primary-sourced from [USA003087] §29.5 (PDF p. 397ff). Full behavioral
description and operand-word structure confirmed directly against real
compiled HALMAT this session, as part of a systematic sweep of
USA003087 syntax patterns against previously-untested HALMAT opcodes
(direct user suggestion) — confirms a speculative cross-reference
already present in [FCAL](FCAL.md)'s write-up.
