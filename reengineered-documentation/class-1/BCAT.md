# BCAT

**Mnemonic:** BCAT

**Opcode:** 0x105

**Confidence:** High

## Behavioral Description

Bit-string catenate. Concatenates two bit-string operands into a single,
longer bit-string result.

## Usage Context

Emitted for HAL/S expressions using the bit-string concatenation operator
(`||` applied to BIT operands).

## Operand-Word Format (confirmed empirically)

Two operands, `QUAL`=1=SYT each: `DATA`=the first (more-significant)
bit-string's SYT index, then `DATA`=the second (less-significant)
bit-string's SYT index. Neither operand carries a width of its own
(`tag1`=0 on both) — the result is `(op1 << width(op2)) | op2`, where
`width(op2)` comes entirely from the symbol table's declared `BIT(n)`
length (confirmed via `SYM_LENGTH`, same convention as `VECTOR`'s
dimension — see `symtab.h`). Confirmed by compiling `DECLARE BIT(4), B1,
B2; DECLARE BIT(8), B3; B3 = B1 || B2;`:

```
HALMAT: 105(2),0,0            <- BCAT
          2(1),0,0                <- B1, symbol index 2, QUAL=1=SYT
          3(1),0,0                <- B2, symbol index 3, QUAL=1=SYT
HALMAT: 101(2),0,0            <- BASN (see BASN.md)
          ?(1),0,0                <- BCAT's own VAC slot (source)
          4(1),0,0                <- B3, symbol index 4, QUAL=1=SYT (destination)
```
Consumed by a following `BASN` via BCAT's own VAC slot, the general
"no destination operand" pattern this project has confirmed for several
other opcode families (`MADD`, `VADD`, etc.). Numerically confirmed with
`B1=BIT(10)` (`0b1010`), `B2=BIT(5)` (`0b0101`): `B3` = `0b10100101` =
`165`, i.e. `B1` shifted left by `B2`'s declared width (4) and OR'd with
`B2` — matches `(10 << 4) | 5`.

## Unresolved Questions

- The catenation direction (which operand becomes the high-order bits)
  was inferred from the natural left-to-right reading of `B1 || B2` and
  confirmed numerically above, but no primary-source text was found
  spelling this out explicitly.
- Non-`BIT`-typed operands (`||` applied to `CHARACTER`, per
  [USA003087]) were not tested — `BCAT` is confirmed for `BIT` only.

## Source Analysis & Reliability

Opcode (0x105) confirmed primary-source: `XBCAT BIT(16) INITIAL("0105")`
in `PASS1.PROCS/##DRIVER.xpl` — see [##DRIVER.xpl] in `STATUS.md`. Matches
[MSC-01847]'s HAL-1971 BCAT opcode (0x105) exactly.

Behavioral description is a straightforward reading of "bit-string
catenate" corroborated by [MSC-01847] §2.16. Operand-word format and
declared-width mechanism confirmed directly against real compiled HALMAT
in a later session (see above), resolving the prior "unconfirmed"
state.
