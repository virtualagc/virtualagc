# SLT

**Mnemonic:** SLT

**Opcode:** 0x7AA

**Confidence:** High

## Behavioral Description

Scalar less than. Computes whether one scalar operand is less than
another, producing a logical (TRUE/FALSE) result.

## Usage Context

Emitted for HAL/S expressions using the `<` comparison operator between
two SCALAR operands. Appears explicitly in [MSC-01847]'s worked simple-IF-
statement example (§3.3.1, `IF X<0.5 THEN ...`), where SLT is shown as the
comparison instruction immediately preceding a false-branch instruction —
directly corroborating the general IF-statement HALMAT pattern described
in [STATUS.md](../STATUS.md)'s "Control Flow Patterns" TODO.

## Unresolved Questions

- HAL/S operand-word format is unconfirmed; see [STRI](../class-8/STRI.md).

## Source Analysis & Reliability

Opcode (0x7AA) confirmed primary-source: `XSEQU(5)` array element 4
(`XSLT`) in `PASS1.PROCS/##DRIVER.xpl` — see [##DRIVER.xpl] in
`STATUS.md`. Matches [MSC-01847]'s HAL-1971 SLT opcode (0x7AA) exactly.

Behavioral description is a straightforward reading of "scalar less than"
corroborated by [MSC-01847] §2.22 and the §3.3.1 worked example; no
verbatim operand-word prose transcribed yet.
