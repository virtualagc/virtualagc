# DCAS

**Mnemonic:** DCAS

**Opcode:** 0x00B

**Confidence:** High

## Behavioral Description

`DO CASE` statement header. Emitted for a HAL/S `DO CASE exp;` statement
([USA003087] §10.3): `exp` (an integer or scalar expression, rounded if
necessary) selects the `k`-th statement of the following statement group
for execution. This is HAL/S's own mnemonic for the "originating computed
branch" instruction anticipated (but unidentified) in [CLBL](CLBL.md)'s
existing write-up — DCAS is the computed-branch source, and each case
alternative's entry point is marked by a companion [CLBL](CLBL.md)
instruction.

At the machine-code level, DCAS compiles to a genuine computed (indexed)
branch: the selector expression's value is used as an index into a
per-statement jump table, and control transfers directly to the selected
case's [CLBL](CLBL.md)-marked entry point.

## Usage Context

Always the first instruction of a `DO CASE` construct, followed by one
case-body per legal index value, each headed by a [CLBL](CLBL.md)
instruction sharing DCAS's own "group" identifier (see Operand-Word
Format). The construct is closed by an [ECAS](ECAS.md) instruction at the
join point where every case body's end-of-case branch converges.

## Operand-Word Format (confirmed empirically)

Two operands: operand 1 = `DATA`=an internal identifier for this
particular `DO CASE` construct (shared with its [CLBL](CLBL.md)s and its
closing [ECAS](ECAS.md), presumably to disambiguate multiple `DO CASE`
constructs within one compilation unit), `QUAL`=2=GLI/INL; operand 2 =
`DATA`=symbol-table index of the selector variable/expression,
`QUAL`=1=SYT.

Confirmed by compiling:

```
I1 = 3;
DO CASE I1;
     S1 = 4;   <- case 1
     S1 = 3;   <- case 2
     S1 = 7;   <- case 3
     S1 = 1;   <- case 4
     S1 = 0;   <- case 5
END;
```

with `HALSFC --parms="LSTALL"`, which produced:

```
HALMAT: 00B(2),0,0        <- DCAS
          1(2),0,0          <- op 1: construct id 1, QUAL=2=GLI/INL
          2(1),0,0          <- op 2: I1, symbol index 2, QUAL=1=SYT
000...:  AHI  5,I1           <- compute address of I1's value
000...:  LH   6,0(5,1)       <- load jump-table entry indexed by I1's value
000...:  BCR  7,6             <- branch (unconditional) to computed target
```

The following [CLBL](CLBL.md) instructions (one per case) all carry the
same construct id (`1`) as their own first operand — see
[CLBL](CLBL.md) for the full worked trace including case bodies and the
closing [ECAS](ECAS.md).

## Unresolved Questions

- The exact runtime mechanics of the jump-table lookup (`AHI`/`LH`/`BCR`
  sequence) — e.g. where the table itself is emitted/addressed — are not
  traced in detail.
- Behavior when the selector value is out of range (per [USA003087]
  §10.3 rule 3, a runtime error, or branches to an `ELSE` clause if
  present) was not tested — the test program had no `ELSE` clause. A
  final [CLBL](CLBL.md), distinguished from the ordinary per-case ones
  only by its trailing header field (not by operand count — see
  [CLBL](CLBL.md), corrected this session), appears immediately before
  [ECAS](ECAS.md) in the no-`ELSE` case; it's a plausible guess that this
  marks a runtime-error trap or the implicit fallthrough point for
  out-of-range indices, but this is untested — see [CLBL](CLBL.md)'s
  Unresolved Questions.
- Whether a SCALAR selector (as opposed to the INTEGER one tested)
  changes the encoding (e.g. requires an explicit rounding/STOI-style
  conversion beforehand) is untested.

## Source Analysis & Reliability

Opcode (0x00B) confirmed primary-source: `XDCAS BIT(16) INITIAL("00B")`
in `PASS1.PROCS/##DRIVER.xpl` — see [##DRIVER.xpl] in `STATUS.md`. No
[MSC-01847] (HAL-1971) analog identified under this name. Statement
syntax primary-sourced from [USA003087] §10.3 (PDF pp. 120–121). Full
behavioral description, operand-word structure, and machine-code
correlation confirmed directly against real compiled HALMAT this
session — mnemonic identification prompted by direct user suggestion
that DCAS/ECAS relate to `DO CASE`, given the naming pattern.
