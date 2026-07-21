# IFHD

**Mnemonic:** IFHD

**Opcode:** 0x007

**Confidence:** High

## Behavioral Description

`IF` statement header. Marks the start of an `IF exp THEN statement;`
(optionally `ELSE else-statement;`) conditional statement ([USA003087]
§9.1). Carries no operands and generates no code of its own — purely a
structural marker, immediately preceding the code evaluating `exp`.

## Usage Context

Always the first instruction of a compiled `IF` statement. The comparison
evaluating `exp` follows directly, then an [FBRA](FBRA.md) conditional
branch consuming its result. If an `ELSE` clause is present, the true
part ends with an unconditional [BRA](BRA.md) skipping over it, and
[LBL](LBL.md) instructions mark the `ELSE` entry point and the
post-statement join point.

## Operand-Word Format (confirmed empirically)

No operands. Confirmed by compiling `IF I1 > 0 THEN S1 = 1.0; ELSE S1 =
2.0;` with `HALSFC --parms="LSTALL"`:

```
IF I1 > 0 THEN S1 = 1.0;      <- "true part"
ELSE S1 = 2.0;                <- "false part"

HALMAT: 007(0),0,0            <- IFHD, no operands
HALMAT: 7C8(2),1,0            <- IGT comparison: I1 > 0
          2(1),0,0              <- I1, symbol index 2, QUAL=1=SYT
          7(5),0,0              <- literal 0, QUAL=5=LIT
HALMAT: 00A(2),0,0            <- FBRA (see FBRA.md)
         35(3),0,0              <- VAC ref to the IGT comparison
          1(2),0,0              <- branch-target id 1, QUAL=2=GLI/INL
BC 6,L#1                        <- branch to ELSE entry point if false
                                 <- (true part: S1 = 1.0; via SASN/IASN)
HALMAT: 009(1),1,0            <- BRA (see BRA.md)
          2(2),0,0               <- branch-target id 2, QUAL=2=GLI/INL
BC 7,L#2                        <- unconditional: skip the ELSE part
HALMAT: 008(1),0,0            <- LBL (see LBL.md): ELSE entry point
          1(2),0,0               <- id 1 (matches FBRA's target)
L#1 EQU *
                                 <- (false part: S1 = 2.0; via SASN/IASN)
HALMAT: 008(1),1,0            <- LBL: post-IF/ELSE join point
          2(2),0,0               <- id 2 (matches BRA's target)
L#2 EQU *
```

## Unresolved Questions

- The simple form (`IF exp THEN statement;` with no `ELSE`) was not
  separately tested — expected to omit the closing [BRA](BRA.md) and the
  `ELSE`-entry [LBL](LBL.md), with [FBRA](FBRA.md) branching directly to
  the post-statement join point, but unconfirmed.
- Nested `IF` statements (`IF B THEN IF C THEN ...;`) and compound
  true/false parts (`IF...THEN DO; ... END;`) were not tested.

## Source Analysis & Reliability

Opcode (0x007) confirmed primary-source: `XIFHD BIT(16) INITIAL("007")`
in `PASS1.PROCS/##DRIVER.xpl` — see [##DRIVER.xpl] in `STATUS.md`. No
[MSC-01847] (HAL-1971) analog identified under this name (that
predecessor's IF-statement compilation, per its own documentation, uses
comparison + branch directly without a distinct header marker). Statement
syntax primary-sourced from [USA003087] §9.1 (PDF pp. 95–98). Full
behavioral description and operand-word structure confirmed directly
against real compiled HALMAT this session, as part of a systematic sweep
of USA003087 syntax patterns against previously-untested HALMAT opcodes
(direct user suggestion).
