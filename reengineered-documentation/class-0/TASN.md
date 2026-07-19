# TASN

**Mnemonic:** TASN
**Opcode:** 0x04F
**Confidence:** High

## Behavioral Description

Structure assign. Implements the HAL/S structure assignment statement
([USA003087] §19.8): `L = R;` where `L`, `R` are tree-equivalent
structure data items (or structure functions). Follows the general
`xASN` pattern shared by every type, but with `XPT`-qualified operands
(referencing the resolved structure-pointer computed by a preceding
[EXTN](EXTN.md) instruction) rather than plain `SYT` symbol references,
since structure operands generally require pointer/offset resolution
first.

## Usage Context

Emitted for every structure assignment, single-copy or multi-copy,
possibly with structure-copy subscripting on either side (see
[TSUB](TSUB.md)).

## Operand-Word Format (confirmed empirically)

Two operands, both `XPT`-qualified (`QUAL`=4): operand 1 = `DATA`=stream
position of the [EXTN](EXTN.md) instruction that resolved the **source**
structure's pointer; operand 2 = likewise for the **receiver** —
source-first, receiver-second, the same order confirmed for the rest of
the `xASN` family (see [SASN](../class-5/SASN.md) for the general
account). **Order corrected in a later session**: an earlier reading (via
`pass2.rpt`) had this backwards. Confirmed by compiling `ZQ2 = ZQ1;`
(both plain `Q-STRUCTURE`, single copy) with
`HALSFC --parms="LISTING2,LSTALL"` and cross-checking directly with
`unHALMAT.py`:

```
HALMAT: 001(2),0,0        <- EXTN, resolves ZQ2 (receiver)
HALMAT: 001(2),0,0        <- EXTN, resolves ZQ1 (source)
HALMAT: 04F(2),0,0        <- TASN
         37(4),0,0          <- op 1: XPT ref to the EXTN resolving ZQ1 (source)
         34(4),0,0          <- op 2: XPT ref to the EXTN resolving ZQ2 (receiver)
L 6,ZQ1 / ST 6,ZQ2 / LH 6,ZQ1+2 / STH 6,ZQ2+2   <- copies each structure terminal in turn
```

(Note the two `EXTN`s themselves compile in receiver-then-source source
order — `ZQ2 = ZQ1;` resolves `ZQ2`'s pointer first — but TASN's own
operands still reference them source-first, receiver-second.)

Also confirmed for a structure-copy-subscripted receiver (`ZQ3(copy 2) =
ZQ1;`, per [TSUB](TSUB.md)'s worked trace) — same TASN shape, with one
`XPT` operand instead resolved from an [EXTN](EXTN.md) that itself
consumed [TSUB](TSUB.md)'s subscripted-copy result.

## Unresolved Questions

- Multiple structure assignment (`L1,L2,...Ln = R;`, [USA003087] §19.8)
  was not tested — presumably follows the extended-operand-count pattern
  confirmed for ordinary types (see [IASN](../class-6/IASN.md)), but
  unconfirmed for TASN.
- Assignment from a structure *function* result (rather than a plain
  structure data item) was not tested.

## Source Analysis & Reliability

Opcode (0x04F) confirmed primary-source: `XXASN` array element 9
(alongside the BASN/CASN/MASN/VASN/SASN/IASN family) in
`PASS1.PROCS/##DRIVER.xpl` — see [##DRIVER.xpl] in `STATUS.md`. Matches
[MSC-01847]'s HAL-1971 "structure assign" concept (there at opcode
0x038, differing from HAL/S's 0x04F). Statement syntax primary-sourced
from [USA003087] §19.8 (PDF p. 228ff). Full behavioral description
confirmed directly against real compiled HALMAT in an earlier session,
as part of a systematic sweep of USA003087 syntax patterns against
previously-untested HALMAT opcodes (direct user suggestion); operand
order corrected in a later session via a direct `unHALMAT.py` binary
read (see Operand-Word Format above).
