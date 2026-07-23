# SPEX

**Mnemonic:** SPEX

**Opcode:** 0x572

**Confidence:** High

## Behavioral Description

Scalar exponentiation by positive integer. Raises a scalar operand to a
power given by an integer operand statically known to be positive. See
[SEXP](SEXP.md) for the general exponentiation-opcode-selection pattern —
this is presumably the cheapest of the three variants to implement
(simple repeated multiplication, no sign or type check needed at
runtime).

## Usage Context

Emitted for HAL/S expressions using the `**` operator where the exponent
is a positive integer literal or is otherwise statically known to be a
positive integer.

## Unresolved Questions

- ~~HAL/S operand-word format is unconfirmed~~ **Resolved**: two operands,
  base (`SYT`) then exponent (`LIT`); see [IPEX](../class-6/IPEX.md)'s
  Usage Context for a worked trace (`S1 = S2 ** 3;`), which also confirms
  SPEX compiles to inline repeated multiplication rather than a runtime
  call.
- The exact compile-time criteria for choosing SPEX over SIEX (literal
  only, or any provably-positive integer expression) is unconfirmed —
  though for the INTEGER-base sibling [IPEX](../class-6/IPEX.md), tracing
  `SYNTHESI.xpl` showed it's specifically "exponent is a bare integer
  literal" (`PSEUDO_FORM=XLIT`), not any provably-positive expression;
  SPEX is presumed identical by direct analogy but not independently
  re-derived from source.

## Confirmed Runtime Behavior

[USA003090] Appendix C error 4 ("exponentiation of zero to a power <=
0"): a `0**0` (base zero, literal exponent zero — the only `B<=0` case
reachable here, since SPEX's own exponent is always non-negative) gives
a result of zero, not the ordinary `0**0=1` convention the opcode's
repeated-multiplication loop would otherwise produce for a zero-count
loop. Implemented in a later session; see `STATUS.md`'s Class 0 section.

## Source Analysis & Reliability

Opcode (0x572) confirmed primary-source: `XSPEX(1)` array element 0 in
`PASS1.PROCS/##DRIVER.xpl` — see [##DRIVER.xpl] in `STATUS.md`. Matches
[MSC-01847]'s HAL-1971 SPEX opcode (0x572) exactly. The same array's
element 1 (`XIPEX`, value `"06D2"`) is the INTEGER-base counterpart —
**now resolved**, see [IPEX](../class-6/IPEX.md).

Behavioral description is a straightforward reading of "scalar
exponentiation by positive integer" corroborated by [MSC-01847] §2.20; no
verbatim operand-word prose transcribed yet.
