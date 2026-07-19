# TEQU

**Mnemonic:** TEQU
**Opcode:** 0x04E
**Confidence:** High

## Behavioral Description

Structure equal comparison. Implements the `=` operator for tree-
equivalent structure operands ([USA003087] §19.9): TRUE if all
corresponding terminals have equal values. Unlike scalar/integer
comparisons, the actual comparison logic is delegated to a runtime
library routine (`#QCSTRUC`) rather than compiled inline, since it must
loop over every structure terminal.

## Usage Context

Emitted for the `=` form of a structure comparison, used the same way
any other comparison operator is (e.g. as the condition of an `IF`). See
[TNEQ](TNEQ.md) for the `¬=`/`NOT=` counterpart.

## Operand-Word Format (confirmed empirically)

Two operands, both `XPT`-qualified (`QUAL`=4): `DATA`=stream position of
the [EXTN](EXTN.md) instruction that resolved each structure operand's
pointer — same pattern as [TASN](TASN.md). Confirmed by compiling `IF
ZQ1 = ZQ2 THEN ...;` with `HALSFC --parms="LSTALL"`:

```
HALMAT: 007(0),0,0        <- IFHD
HALMAT: 001(2),0,0        <- EXTN, resolves ZQ1
HALMAT: 001(2),0,0        <- EXTN, resolves ZQ2
HALMAT: 04E(2),0,0        <- TEQU
         44(4),0,0
         47(4),0,0
LA 3,ZQ2 / LA 2,ZQ1 / ST 2,18(0,0) / ST 3,20(0,0) / LFXI 5,5
BAL 4,#QCSTRUC              <- runtime structure-comparison routine
BC 3,P#3 / BC 7,P#4 / ...
HALMAT: 00A(2),0,0        <- FBRA, consumes TEQU's result
```

## Unresolved Questions

- The exact meaning of the `LFXI 5,5` constant passed to `#QCSTRUC`
  (plausibly the number of terminals, or the structure's byte size) is
  not decoded.

## Source Analysis & Reliability

Opcode (0x04E) confirmed primary-source: `XTEQU` array element 0 in
`PASS1.PROCS/##DRIVER.xpl` — see [##DRIVER.xpl] in `STATUS.md`. Matches
[MSC-01847]'s HAL-1971 "structure equal" concept (there at opcode
0x045, differing from HAL/S's 0x04E). Statement syntax primary-sourced
from [USA003087] §19.9 (PDF p. 231ff). Full behavioral description and
operand-word structure confirmed directly against real compiled HALMAT
this session, as part of a systematic sweep of USA003087 syntax
patterns against previously-untested HALMAT opcodes (direct user
suggestion).
