# SGT

**Mnemonic:** SGT
**Opcode:** 0x7A8
**Confidence:** High

## Behavioral Description

Scalar greater than. Computes whether one scalar operand is greater than
another, producing a logical (TRUE/FALSE) result.

## Usage Context

Emitted for HAL/S expressions using the `>` comparison operator between
two SCALAR operands — this specific opcode appears in the worked IF-
statement example in [MSC-01847] §3.3.1 (as `SLT`, the complementary
less-than form — see [SLT](SLT.md)).

## Operand-Word Format (confirmed empirically)

Two operands, in left-to-right source order: operand 1 = `DATA`=
symbol-table index of the left-hand operand, `QUAL`=1=SYT; operand 2 =
likewise for the right-hand operand. Confirmed by compiling
`IF S1 > S2 THEN ...;` with `HALSFC --parms="LISTING2,LSTALL"`,
cross-checked directly with `unHALMAT.py`:

```
HALMAT: 7A8(2),0,0        <- SGT
          2(1),0,0          <- op 1: S1, symbol index 2, QUAL=1=SYT (left operand)
          3(1),0,0          <- op 2: S2, symbol index 3, QUAL=1=SYT (right operand)
```

Unlike the `xASN` assign family (see [SASN](../class-5/SASN.md)), whose
documented operand order was found reversed relative to source syntax,
comparison operators read left-to-right exactly as written — no
correction needed here, this was resolved directly.

## Unresolved Questions

- Operand-word format for a literal or expression operand (rather than
  two plain variables) is untested.

## Source Analysis & Reliability

Opcode (0x7A8) confirmed primary-source: `XSEQU(5)` array element 3
(`XSGT`) in `PASS1.PROCS/##DRIVER.xpl` — see [##DRIVER.xpl] in
`STATUS.md`. Matches [MSC-01847]'s HAL-1971 SGT opcode (0x7A8) exactly.
Operand-word structure confirmed directly against real compiled HALMAT
this session via a direct `unHALMAT.py` binary read.

Behavioral description is a straightforward reading of "scalar greater
than" corroborated by [MSC-01847] §2.22; no verbatim operand-word prose
transcribed yet.
