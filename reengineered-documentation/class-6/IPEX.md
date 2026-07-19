# IPEX

**Mnemonic:** IPEX
**Opcode:** 0x6D2
**Confidence:** High

## Behavioral Description

Integer exponentiation by positive integer. Raises an INTEGER operand to
a power given by a non-negative INTEGER literal exponent, known at
compile time — the INTEGER-base counterpart of [SPEX](../class-5/SPEX.md)
(SCALAR base). Unlike SPEX, which compiles to inline repeated
multiplication, IPEX compiles to a runtime-library call (`#QHPWRH`) —
see the worked trace below.

**Resolves a previously-open question** (see `STATUS.md`'s Class 6
section): [MSC-01847] lists a HAL-1971 "IEXP" (integer exponentiation) at
opcode 0x6CF, with no HAL/S equivalent found under that name. Tracing
`PASS1.PROCS/SYNTHESI.xpl`'s exponentiation synthesis code (the `**`
operator's `<SIMPLE EXP>` handling, around line 1465) shows there is no
general "integer-base, any-integer-exponent" opcode at all: IPEX covers
*only* the base=INTEGER, exponent=non-negative-integer-literal case.
Every other INTEGER-base exponentiation (a negative literal exponent, a
non-literal/variable integer exponent, or a SCALAR exponent) is instead
implicitly coerced to SCALAR — the base is converted via
[ITOS](../class-5/ITOS.md) (0x5C1) and the expression falls through to
[SIEX](../class-5/SIEX.md) or [SEXP](../class-5/SEXP.md) — so HAL-1971's
IEXP genuinely has no HAL/S opcode; its role was **not** absorbed into
IPEX (a much narrower opcode) but effectively eliminated by coercing to
the existing SCALAR-family exponentiation opcodes instead.

## Usage Context

Emitted for HAL/S expressions using the `**` operator where the base is
INTEGER-typed and the exponent is a literal statically known to be a
non-negative integer. Confirmed by compiling `I1 = I2 ** 3;` (`I1`, `I2`
both `INTEGER`) with `HALSFC --parms="LSTALL"`:

```
HALMAT: 6D2(2),0,0        <- IPEX, numop=2
          3(1),0,0           <- op 1: I2, symbol index 3, QUAL=1=SYT (the base)
          3(5),0,0           <- op 2: literal-table index 3 (value 3), QUAL=5=LIT (the exponent)
                                 -> object code: LH 5,I2 / SCAL 0,#QHPWRH
HALMAT: 601(2),0,0        <- IASN: I1 = <IPEX's VAC result>
```

Compare the SCALAR-base sibling in the same test program,
`S1 = S2 ** 3;`, which instead compiles to **inline** repeated
multiplication with no runtime call at all:

```
HALMAT: 572(2),0,0        <- SPEX, numop=2
          5(1),0,0           <- op 1: S2, symbol index 5, QUAL=1=SYT (the base)
          4(5),0,0           <- op 2: literal-table index 4 (value 3), QUAL=5=LIT (the exponent)
                                 -> object code: LE 7,S2 / LER 5,7 / MER 7,7 / MER 5,7  (S2*S2*S2)
HALMAT: 501(2),0,0        <- SASN: S1 = <SPEX's VAC result>
```

**Confirmed non-literal/negative-exponent coercion**: compiling
`I1 = I2 ** I3;` (`I3` a non-literal `INTEGER` variable) produces no IPEX
or any integer-exponent opcode at all — instead `I2` is converted via
[ITOS](../class-5/ITOS.md) (`5C1(1),0,0`), then `571(2),0,0` ([SIEX](../class-5/SIEX.md))
computes the SCALAR-typed power (runtime call `#QEPWRH`), and the result
is assigned back to the INTEGER receiver `I1` via a plain `501(2),0,0`
(SASN) whose *generated object code* — not a separate HALMAT opcode —
does the scalar-to-integer truncation (`BAL 4,ETOH` before the final
`STH`). This confirms HAL/S has no "general integer exponentiation"
opcode family whatsoever; IPEX is strictly the positive-literal-exponent
special case.

## Operand-Word Format (confirmed empirically)

Two operands: operand 1 = `DATA`=symbol-table index of the INTEGER base,
`QUAL`=1=SYT; operand 2 = `DATA`=literal-table index of the non-negative
integer exponent, `QUAL`=5=LIT. Same shape as [SPEX](../class-5/SPEX.md).

## Unresolved Questions

- Whether IPEX's exponent operand can ever be non-literal (e.g. a
  compile-time-provably-non-negative integer expression, not just a bare
  literal) is unconfirmed — `SYNTHESI.xpl`'s logic as read only reaches
  the IPEX/SPEX branch for a literal exponent (`PSEUDO_FORM(I)=XLIT`
  checked explicitly).
- The runtime routine name `#QHPWRH` (vs. SPEX's inline codegen) suggests
  a table-driven or iterative power routine — its algorithm isn't
  independently confirmed here.

## Source Analysis & Reliability

Opcode (0x6D2) confirmed primary-source: `XSPEX(1)` array element 1
(named `XIPEX` in a trailing comment) in `PASS1.PROCS/##DRIVER.xpl` — see
[##DRIVER.xpl] in `STATUS.md`. Not present in [MSC-01847] under any name;
HAL-1971's closest analog, "IEXP" (0x6CF), has no HAL/S counterpart at
all (see Behavioral Description above). Triggering construct located by
reading `PASS1.PROCS/SYNTHESI.xpl`'s `**`-operator synthesis code
directly (the `TEMP2=XSPEX(TEMP-SCALAR_TYPE)` selection and the
surrounding literal/sign checks), then confirmed empirically against
real compiled HALMAT this session.
