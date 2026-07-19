# NOP

**Mnemonic:** NOP
**Opcode:** 0x000
**Confidence:** High

## Behavioral Description

No operation. Executing a NOP operator has no effect on program state.

```
 31         24 23         16 15      12 11         4  3    1 0
+------------+------------+---------+------------+------+---+
|  (unused)  |     n      |   000   |     ---    |  0   | 0 |
+------------+------------+---------+------------+------+---+
```

- **TAG** — don't-care; not used.
- **NUMOP (n)** — not necessarily 0. A NOP may carry any number of operand
  words; per [Halmat.pdf]'s reading of the compiler source, this occurs
  when an operator is stripped down to a NOP in place (rather than removed
  outright) during optimization, leaving its former operands attached but
  functionally inert.
- **OPCODE** — 0x000.
- **COPT** — 0.

## Usage Context

No operands are semantically required. Where operand words are present,
they have no operational effect.

## Unresolved Questions

- Whether NUMOP is ever actually nonzero in HALMAT emitted directly by
  PASS1 (as opposed to appearing only as a byproduct of OPT rewriting some
  other operator into a NOP in place) is not confirmed from primary
  source.

## Source Analysis & Reliability

The opcode value and operator-word field layout are primary-sourced from
[IR-60-5] p. A-6. [IR-60-5] gives no operand-word diagram for NOP (implying
none is normally present) and no behavioral prose beyond what is captured
above.

[Halmat.pdf] additionally reproduces XPL source excerpts (from
`INSERTHA.xpl`, `PREPAREH.xpl`, `PUSHHALM.xpl`) suggesting that OPT
generates NOPs in place of instructions it removes, and that the removal
does not always zero NUMOP. That claim is plausible but has not been
independently verified against the compiler source in this session, hence
the Medium-leaning caveat on the NUMOP note above (the overall Confidence
rating stays High because the core opcode/format claim is primary-sourced;
only the NUMOP usage detail is secondary).
