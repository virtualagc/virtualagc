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
~~one with array/structure-typed parameters, where this simple
contiguous-slot pattern may not hold~~ **confirmed this session for
`MATRIX` parameters** (procedure case; see [PCAL](PCAL.md)): the same
contiguous-slot pattern holds unchanged — a whole-`MATRIX` argument is
still just one ordinary [XXAR](XXAR.md) entry occupying one slot, only
its own operand shape differs (`QUAL`=1=SYT with `TAG1`=the class
number, same as [WRIT](WRIT.md)'s whole-container argument, rather than
a plain scalar/integer value) — confirmed by compiling `CALL
some_procedure(a_whole_matrix);` (USA003087 Sec. 11.2's documented
`PROCEDURE(ARG1)` with `DECLARE ARG1 MATRIX(4,4);` form, pp. 128, 130,
134) with `HALSFC --parms="LISTING2,LSTALL"`. Structure-typed parameters
remain untested.

**A call operand's own symbol is not always the callee's real PDEF/FDEF-
defining symbol** — a second, deeper user-reported bug (`CALL
some_procedure(...)` failing "call to undefined procedure" even though
HALSFC accepted the source and USA003087 p. 22ff's block-name scoping
rules explicitly allow it): when the call site is lexically nested in a
*different* block than the callee's own definition (e.g. one `PROCEDURE`
calling a sibling `PROCEDURE`, both nested directly in the same
enclosing `PROGRAM`/`TASK`), the compiler emits a *separate*, alias-only
symbol-table entry for the callee at the call site — `SYM_TYPE`=`0x45`
("IND CALL LABEL" in `unHALMAT.py`'s own `dataTypes` table), not the
real definition's `0x47` ("PROCEDURE LABEL") symbol. Confirmed via a real
compile of exactly this shape (`PRINT_MATRIX_5D2` calling its sibling
`PRINT_MATRIX_5D`, both nested in the enclosing `PROGRAM`): the real
definition's own symbol (say, SYT 3) is untouched, but the *call site's*
`XXST`/`PCAL` operands both reference a *different* symbol (SYT 8) whose
own `COMMON*.out` record has `SYM_TYPE`=`45` and `SYM_PTR`=`3` — the
alias's `SYM_PTR` field points straight back at the real definition (see
`symtab.h`'s `sym_ptr` field comment). Since `state->symbol_def_pos[]`
(interp.c) is only ever populated for a real `PDEF`/`FDEF`'s own symbol,
looking it up for the *alias* symbol (8) always comes back `NO_TARGET`,
failing loudly as "undefined" even though the compiler accepted the
call. Fixed by `resolve_call_target()` (interp.c), which follows this
`SYM_PTR` redirect (when `state->symtab` is available — this indirection
has no HALMAT-level marker of its own, so without a symbol table it
can't be detected at all) before treating a `PCAL`/`FCAL` operand's
symbol as a callable target; used by both opcodes' handlers and by
`interp_is_external_call` (the debugger's step-into detection). The
identical alias shape was confirmed to be emitted for a call from inside
a `TASK` block too, not just `PROCEDURE`/`FUNCTION` — the fix, being
purely symbol-table-driven rather than tied to any particular kind of
enclosing block, covers that the same way. Whether the *unarrayed*/
same-block case (a procedure calling one defined in the exact same
lexical block, not a sibling) ever also uses this alias mechanism, or
only cross-block references do, is not separately confirmed — every
compile tried so far already needed the alias.

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
