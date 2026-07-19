# EFOR

**Mnemonic:** EFOR

**Opcode:** 0x011

**Confidence:** High

## Behavioral Description

"End for" — closes a `DO FOR` statement group opened by [DFOR](DFOR.md),
in both its range and list forms. Generates the per-cycle
increment/re-test/branch-back logic (range form) or the computed-return
dispatch back into [AFOR](AFOR.md)'s saved return address (list form).

## Usage Context

Emitted for the closing `END;` of any `DO FOR` group.

## Operand-Word Format (confirmed empirically)

One operand: `DATA`=the same construct identifier used by the
originating [DFOR](DFOR.md), `QUAL`=2=GLI/INL. Confirmed by compiling
both forms with `HALSFC --parms="LSTALL"`:

**Range form** (`DO FOR I1 = 1 TO 10; ... END;`):
```
HALMAT: 011(1),0,0
          8(2),0,0               <- construct id 8 (matches DFOR), QUAL=2=GLI/INL
LFXI 7,3                          <- reload the increment constant (implicit +1 here)
AH   7,I1                         <- R7 (increment) + memory I1 -> R7 (new control-var value)
L#10 EQU *                        <- loop-top label (target of DFOR's initial skip-branch)
STH  7,I1                         <- store the new value back to I1
CHI  7,10                         <- compare against the final value
BC   6,L#10                       <- branch back to loop top if still in range
L#8 EQU *                         <- loop-exit label
```

**List form** (`DO FOR I1 = 1, 2, 3; ... END;`):
```
HALMAT: 011(1),0,0
         13(2),0,0               <- construct id 13 (matches DFOR), QUAL=2=GLI/INL
LH  4,18(0,0)                     <- reload the saved return address (see AFOR.md)
BCR 7,4                           <- branch to it: continues the loop (next AFOR)
                                      or falls through to exit, per which value was last
L#13 EQU *                        <- loop-exit label
```

## Unresolved Questions

- None for the base cases tested.

## Source Analysis & Reliability

Opcode (0x011) confirmed primary-source: `XEFOR BIT(16) INITIAL("011")`
in `PASS1.PROCS/##DRIVER.xpl` — see [##DRIVER.xpl] in `STATUS.md`. No
[MSC-01847] (HAL-1971) analog identified under this name. Full behavioral
description confirmed this session via direct empirical testing — see
[DFOR](DFOR.md)'s Source Analysis for the context of this investigation.
