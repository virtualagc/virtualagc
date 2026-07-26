# NASN

**Mnemonic:** NASN

**Opcode:** 0x057

**Confidence:** High

## Behavioral Description

NAME (pointer) assign. Assigns a pointer value to a `NAME` data item —
the HAL/S `NAME` assignment statement ([USA003087] §28.7): `NAME(L) =
NAME(R);` (or `NAME(L) = NULL;`), where `L` is a `NAME` pseudo-function
in assignment context and `R` is a `NAME` pseudo-function in reference
context (or the null-pointer specification).

## Usage Context

Emitted for every `NAME` assignment statement. Follows the general
two-operand `xASN` pattern shared by every type (compare
[SASN](../class-5/SASN.md), [IASN](../class-6/IASN.md), etc.), but
unlike those, both operands are ordinary data-item references (the
pointer's *target*, not the pointer variable's value) — the pointer
semantics are entirely implicit in NASN's identity as an opcode, not
carried by any qualifier on the operands themselves.

## Operand-Word Format (confirmed empirically)

Two operands: operand 1 = source, `DATA`=symbol-table index of the data
item being pointed to, `QUAL`=1=SYT; operand 2 = receiver, `DATA`=
symbol-table index of the `NAME` data item, `QUAL`=1=SYT. Confirmed by
compiling `NAME(NS2) = NAME(S2);` (`NS2` a `NAME SCALAR`, `S2` an
ordinary `SCALAR`) with `HALSFC --parms="LSTALL"`:

```
HALMAT: 057(2),0,0
          3(1),0,0       <- S2, symbol index 3, QUAL=1=SYT (source)
          5(1),0,0       <- NS2, symbol index 5, QUAL=1=SYT (receiver)
LA 4,S2 / STH 4,NS2       <- loads S2's ADDRESS (not value) and stores it into NS2
```

## Investigated and deferred: `264-INITIALIZE.hal`'s `NASN` failure

User-reported: `264-INITIALIZE.hal` hit "NASN: receiver must be SYT."
Investigating turned up that this corpus file doesn't actually compile
at all under the current `HALSFC` build — it needs a multi-file
`INCLUDE TEMPLATE`/COMPOOL prerequisite the installed tooling has no
working `--templib` mechanism for (confirmed via `--help`), so no real
compiled HALMAT for this file's own `NASN` failure could ever be
produced to verify a fix against. A speculative fix (accepting a
`QUAL`=`XPT` receiver operand, on the hypothesis that a bare
`NAME`-typed structure reference might compile that way) was
implemented, then reverted — `interp.c`'s `OP_NASN` still requires
`QUAL`=`SYT` for the receiver, unchanged from this file's own confirmed
encoding above. Left as a documented non-fix rather than shipping code
that can't be checked against ground truth.

## Unresolved Questions

- Multiple NAME assignment (`NAME(L1), NAME(L2),... = R;`, per
  [USA003087] §28.7) was not tested — presumably follows the same
  extended-operand-count pattern confirmed for ordinary multiple
  assignment (see [IASN](../class-6/IASN.md)'s "Usage Context (multiple
  assignment)" section), but unconfirmed for NASN specifically.
- Whether assigning `NULL` (rather than a real pointer) changes the
  source operand's `QUAL` (e.g. to `IMD`, as confirmed for
  [NINT](../class-8/NINT.md)'s NULL-initialization case) is untested —
  only a real-pointer assignment was compiled.

## Source Analysis & Reliability

Opcode (0x057) confirmed primary-source: `XNASN BIT(16) INITIAL("057")`
in `PASS1.PROCS/##DRIVER.xpl` — see [##DRIVER.xpl] in `STATUS.md`. No
[MSC-01847] (HAL-1971) analog identified (the `NAME` facility postdates
HAL 1971). Statement syntax primary-sourced from [USA003087] §28.7 (PDF p. 377ff). Full behavioral description and operand-word structure
confirmed directly against real compiled HALMAT this session, as part of
a systematic sweep of USA003087 syntax patterns against previously-
untested HALMAT opcodes (direct user suggestion).
