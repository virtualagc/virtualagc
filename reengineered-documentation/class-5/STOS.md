# STOS

**Mnemonic:** STOS

**Opcode:** 0x5A1

**Confidence:** High

## Behavioral Description

Scalar precision scale. The scalar member of the same precision-scaling
family as [MTOM](../class-3/MTOM.md) — see that file for the full
mechanism. Also structurally the "self" slot of the `XBTOS` "convert to
scalar" family (alongside [BTOS](BTOS.md), [CTOS](CTOS.md),
[ITOS](ITOS.md)) — for scalar specifically, "convert to scalar" and
"scale scalar precision" are the same operation, since converting a
scalar to itself can only change its precision, not its fundamental
type. This opcode genuinely serves both conceptual roles.

Confirmed trigger: HAL/S's postfix precision-qualifier syntax,
`exp$(@SINGLE)`/`exp$(@DOUBLE)` (`PASS1.PROCS/SYNTHESI.xpl`'s grammar
rule `<QUALIFIER> ::= <$> ( @ <PREC SPEC> )`) — an explicit request to
force an expression's result to a specific precision, distinct from
plain assignment (which does *not* trigger STOS — see the prior negative
result below, still valid).

## Usage Context

Emitted for `exp$(@DOUBLE)`/`exp$(@SINGLE)` applied to a `SCALAR`
expression — confirmed by compiling `S2 = S1$(@DOUBLE);` (`S1` a `SINGLE`
`SCALAR`, `S2` `DOUBLE`). An earlier empirical test this session (`S2 =
S1;` between two scalars of different precision, no qualifier) did
**not** trigger STOS; the simple-assignment precision widening was
instead handled by the generated object code directly (`SER`/`STED`
instructions), with a plain [SASN](SASN.md) in the HALMAT — STOS is
reserved specifically for the explicit qualifier form, not implicit
assignment-driven conversion.

## Operand-Word Format (confirmed empirically)

One operand: `DATA`=symbol-table index of the source `SCALAR` expression,
`QUAL`=1=SYT. The operator word's `TAG` field carries the requested
precision as a bit flag (confirmed `2` for `@DOUBLE`) rather than a
generic 4-bit mask of narrow/widen rules as previously hypothesized —
this is `PASS1.PROCS/PRECSCAL.xpl`'s `PREC_SCALE` procedure's own
`DOUBLE_FLAG` constant, passed straight through as `TAG`. Confirmed
trace:

```
HALMAT: 5A1(1),2,0            <- STOS, TAG=2=DOUBLE_FLAG
          2(1),0,0                <- S1, symbol index 2, QUAL=1=SYT
LE 0,S1 / SER 1,1                 <- widens S1's single-precision value into place
```

## Confirmed Bit-Level Mechanics

[USA00309] §8.2 gives the exact rules for scalar precision conversion at
the runtime-representation level (single = 32-bit AP-101 float, 1 sign +
7 exponent + 24 mantissa bits; double = 64-bit, 1 sign + 7 exponent + 56
mantissa bits — rules 3–4):

- **Rule 7 (narrowing, double→single)**: truncate the right-most 32 bits
  of the double-precision mantissa.
- **Rule 12 (widening, single→double)**: pad 32 zero bits to the right of
  the single-precision mantissa.

These are presumably what the `TAG` flag selects between (a `SINGLE_FLAG`
counterpart to the confirmed `DOUBLE_FLAG`=2 was not independently tested
this session, but is expected by direct analogy — see
[USA003087]'s `SINGLE_FLAG`/`DOUBLE_FLAG` constants referenced in
`PRECSCAL.xpl`'s grammar-rule source).

## Unresolved Questions

- Whether `TAG` ever carries additional bits beyond the single/double
  flag (the original 4-bit-mask hypothesis) is not ruled out, just not
  observed in this simple case.

## Confirmed later: `SINGLE_FLAG` = 1

Compiling `S2 = S1$(@SINGLE);` (`S1` `DOUBLE`, `S2` `SINGLE`) confirms
`TAG`=1 for `@SINGLE`, cross-checked identically for
[MTOM](../class-3/MTOM.md)/[VTOV](../class-4/VTOV.md). Also noted this
session: `DECLARE DOUBLE SCALAR x;` (precision keyword *before* the type
name) reliably produces a "SCALAR syntactically illegal" compile error,
while `DECLARE SCALAR DOUBLE, x;` (precision keyword *after*, matching
`MATRIX(r,c) DOUBLE`/`VECTOR(n) DOUBLE`'s confirmed working order)
compiles cleanly — a HAL/S declaration-syntax gotcha, not a HALMAT-level
finding, but worth recording since it wasted real debugging time.

## Source Analysis & Reliability

Opcode (0x5A1) confirmed primary-source: doubly — element 4 of the
`XBTOS(5)` "convert to scalar" array, and element 2 of the `XMTOM(3)`
precision-scale array, both in `PASS1.PROCS/##DRIVER.xpl` — see
[##DRIVER.xpl] in `STATUS.md`. Not present in [MSC-01847]. Behavioral
role primary-sourced from `PASS1.PROCS/PRECSCAL.xpl`'s `PREC_SCALE`
procedure; the trigger construct (`$(@SINGLE)`/`$(@DOUBLE)`) was found by
tracing `PREC_SCALE`'s callers (`SYNTHESI.xpl` line 1648, `<PRIMARY> ::=
<PRE PRIMARY> <QUALIFIER>`) back to the `<QUALIFIER> ::= <$> ( @ <PREC
SPEC> )` grammar rule and its `<PREC SPEC> ::= SINGLE | DOUBLE`
alternatives. Full behavioral description and operand-word structure now
confirmed directly against real compiled HALMAT (resolving the prior
session's negative-only result into a positive confirmation). Bit-level
mechanics primary-sourced from [USA00309] §8.2 rules 7 and 12.
