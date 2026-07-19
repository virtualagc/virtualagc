# ICLS

**Mnemonic:** ICLS
**Opcode:** 0x052
**Confidence:** High

## Behavioral Description

Inline function close. Closes the inline function block opened by
[IDEF](IDEF.md) ([USA003087] §29.5's implicit `CLOSE;`). Generates the
return-to-enclosing-expression code (`BCRE`, a computed/register-based
return distinct from the plain unconditional branches used elsewhere),
since control must resume exactly where the inline function was embedded
within its surrounding expression.

## Usage Context

Always the last instruction of an inline function block, following its
body statements (typically ending in [RTRN](RTRN.md)) and bracketed, like
every inline-function statement, by [IMRK](IMRK.md).

## Operand-Word Format (confirmed empirically)

No operands (despite an opaque `(1)` label on the opcode line, consistent
with this project's established observation that this field isn't a
reliable `NUMOP` indicator elsewhere either). Confirmed by compiling `S1
= S1 + FUNCTION SCALAR; RETURN S1; CLOSE; **2;` with
`HALSFC --parms="LSTALL"` — see [IDEF](IDEF.md) for the full worked
trace; `HALMAT: 052(1),1,0` appears with no following operand line,
immediately generating `BCRE 7,4`.

## Unresolved Questions

- None for the base case tested.

## Source Analysis & Reliability

Opcode (0x052) confirmed primary-source: `XICLS BIT(16) INITIAL("052")`
in `PASS1.PROCS/##DRIVER.xpl` — see [##DRIVER.xpl] in `STATUS.md`; noted
there as appearing immediately after [IDEF](IDEF.md), now confirmed as
its closing counterpart (compare [MDEF](MDEF.md)/[CLOS](CLOS.md)). No
[MSC-01847] (HAL-1971) analog identified. Full behavioral description
and operand-word structure confirmed directly against real compiled
HALMAT this session, as part of a systematic sweep of USA003087 syntax
patterns against previously-untested HALMAT opcodes (direct user
suggestion).
