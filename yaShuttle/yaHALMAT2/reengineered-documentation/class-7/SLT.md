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
in [Control Flow Patterns](../HALMAT.md#control-flow-patterns).

## Operand-Word Format (confirmed empirically)

Two operands, in left-to-right source order (same shape as
[SGT](SGT.md)): operand 1 = `DATA`=symbol-table index of the left-hand
operand, `QUAL`=1=SYT; operand 2 = likewise for the right-hand operand.
Confirmed by compiling `IF S1 < S2 THEN ...;` with
`HALSFC --parms="LISTING2,LSTALL"`, cross-checked directly with
`unHALMAT.py`:

```
HALMAT: 7AA(2),0,0        <- SLT
          2(1),0,0           <- op 1: S1, symbol index 2, QUAL=1=SYT (left operand)
          3(1),0,0           <- op 2: S2, symbol index 3, QUAL=1=SYT (right operand)
```

## Unresolved Questions

- Operand-word format for a literal or expression operand (rather than
  two plain variables) is untested.

## Source Analysis & Reliability

Opcode (0x7AA) confirmed primary-source: `XSEQU(5)` array element 4
(`XSLT`) in `PASS1.PROCS/##DRIVER.xpl` — see [##DRIVER.xpl] in
`STATUS.md`. Matches [MSC-01847]'s HAL-1971 SLT opcode (0x7AA) exactly.
Operand-word structure confirmed directly against real compiled HALMAT
this session via a direct `unHALMAT.py` binary read.

Behavioral description is a straightforward reading of "scalar less than"
corroborated by [MSC-01847] §2.22 and the §3.3.1 worked example.
