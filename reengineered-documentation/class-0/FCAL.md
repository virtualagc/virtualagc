# FCAL

**Mnemonic:** FCAL

**Opcode:** 0x01E

**Confidence:** High

## Behavioral Description

(User) function call header. Believed, by behavioral analogy with the
predecessor language's FUNC instruction, to specify invocation of a
user-defined function. In HAL 1971, FUNC alone specifies invocations of
*both* user functions and built-in functions (with the operand's sign
distinguishing a "shaping function" from an ordinary function name lookup
— see [SFST](SFST.md)/Appendix E). HAL/S appears to have split this into
two opcodes: FCAL for user-defined function calls, and [BFNC](BFNC.md)
(0x04A, "built-in function") for built-ins — [BFNC](BFNC.md) is now
directly confirmed (both the Optimizer-HALMAT-era `SINCOS` special case
and, empirically this session, the `PRIO` built-in function), but the
FCAL/BFNC *split* itself, and FCAL's own operand-word layout, remain an
inference not confirmed by a direct HAL/S source describing FCAL's role.

## Usage Context

Confirmed this session: like [PCAL](PCAL.md), FCAL sits inside the
[XXST](XXST.md)/[XXAR](XXAR.md)/[XXND](XXND.md) bracketing construct
(the same one used for `READ`/`WRITE`) — the opening [XXST](XXST.md)'s
trailing header flag distinguishes a function invocation (`1`) from a
procedure call (`0`). The function's return value is subsequently
referenced by a `VAC`-qualified operand pointing at FCAL's own stream
position, same as any other value-producing instruction.

## Operand-Word Format (confirmed empirically)

One operand: `DATA`=symbol-table index of the invoked function,
`QUAL`=1=SYT (matching the index also carried by the opening
[XXST](XXST.md)). Confirmed by compiling `S1 = S1 + FUNC1(S1);` (FUNC1 a
`FUNCTION(X) SCALAR;`) with `HALSFC --parms="LSTALL"` — see
[XXST](XXST.md) for the full worked trace.

## Unresolved Questions

- The FCAL/[BFNC](BFNC.md) split inference (that HAL 1971's combined
  FUNC instruction became two separate HAL/S opcodes, one for
  user-defined and one for built-in functions) remains unconfirmed by a
  direct primary source describing FCAL's own role, though both halves
  of the split are now independently confirmed to behave sensibly.
- How the arguments accumulated by the [XXAR](XXAR.md) list actually
  bind to the callee's formal parameters is not documented anywhere in
  the HALMAT stream itself — there is no separate "parameter
  declaration" opcode, and bare (uninitialized) `DECLARE`s like a
  parameter's don't emit an `IINT`-family instruction either, so nothing
  in the callee's own HALMAT text marks a given symbol as a parameter.

**Phase 3 finding**: the binding is by symbol-table position, not
anything encoded in HALMAT. Compiling two probes (`FUNCTION(N)` and
`FUNCTION(A, B)`, the latter with an extra non-parameter local declared
after the parameters) shows the parameters always occupy the SYT slots
**immediately following the function's own symbol, contiguously, in
source declaration order** — e.g. function symbol at SYT 4 with two
parameters gives `A`=SYT 5, `B`=SYT 6, with any further (non-parameter)
locals starting at SYT 7. Cross-checked against the compiler's own
symbol table (`COMMON0.out`'s `SYM_FLAGS` field): the parameters carry
the `0x00000400` ("INPUT") bit, while the trailing non-parameter local
carries `0x00000200` ("STATIC") instead — confirming the positional
pattern isn't coincidental. So: for a call with `k` arguments to a
function/procedure whose own symbol is at SYT index `f`, argument `i`
(0-indexed) binds to SYT slot `f + 1 + i`. Not yet tested against a
function with an explicit `ASSIGN`/output parameter (see [PCAL](PCAL.md)
for the procedure case, which has both input and assign arguments) or
one with array/structure-typed parameters, where this simple
contiguous-slot pattern may not hold.

## Source Analysis & Reliability

Opcode (0x01E) and mnemonic FCAL are primary-sourced from [IR-60-5] A.2
(p. A-103) and independently confirmed by `XFCAL BIT(16) INITIAL("01E")`
in the HAL/S-FC compiler source itself (`PASS1.PROCS/##DRIVER.xpl` — see
[##DRIVER.xpl] in `STATUS.md`), which settles what was, earlier in this
project, treated as an unverified reading of the IR-60-5 index. No page
content for FCAL's own HAL/S behavioral description (target p. 61) is
present in the available partial copy.

The behavioral description is drawn from [MSC-01847] p. 2-15's
description of FUNC (HAL 1971 opcode 0x028) — this part remains a
cross-language behavioral inference, not a primary-sourced HAL/S
description; treat the *behavior* (not the opcode/mnemonic) with the same
caution as other HAL-1971-sourced entries.
