# RTRN

**Mnemonic:** RTRN

**Opcode:** 0x032

**Confidence:** High

## Behavioral Description

Subprogram return. Specifies a return from a subprogram. In the
predecessor language HAL, this instruction has two forms: one used for
tasks and procedures (no return value), and one used for functions (which
carries the returned operand, of any type, as its `a` field). Both forms'
`b` field points to the name of the enclosing subprogram in the symbol
table.

Per [MSC-01847] §3.5.1's worked example, the close of a procedure or
function always generates a RTRN instruction, even when the last
executable statement in the body was itself an explicit RETURN — i.e.
every subprogram body is HALMAT-terminated by RTRN regardless of how many
explicit `RETURN;` statements the source contained.

## Usage Context

Appears once per explicit `RETURN` statement in a subprogram body, and
again (redundantly, as an error/fallthrough exit) at the CLOS-equivalent
end of the subprogram body. See [PDEF](PDEF.md)/[FDEF](FDEF.md)/
[TDEF](TDEF.md)/[MDEF](MDEF.md) for the corresponding definition headers.

## Unresolved Questions

- HAL/S operand-word format is unconfirmed; see [STRI](../class-8/STRI.md).
- Whether HAL/S retains the two-version (task/procedure vs. function)
  structure is unconfirmed.

## Source Analysis & Reliability

Opcode (0x032) and mnemonic are primary-sourced from [IR-60-5] A.2 (p.
A-103); no page content for RTRN's own HAL/S description (target p. 11) is
present in the available partial copy.

Behavioral description drawn from [MSC-01847] p. 2-16 and the worked
example at p. 3-19, describing the identically-named predecessor-language
instruction (HAL 1971 opcode 0x030, differing from HAL/S's 0x032). See
[STRI](../class-8/STRI.md)'s Source Analysis section for the general basis
of this cross-language inference.
