# UDEF

**Mnemonic:** UDEF

**Opcode:** 0x02E

**Confidence:** High

## Behavioral Description

Update block definition header. Indicates the start of an "update block."
If the update block is named, the operand points to the name in the
symbol table; if unnamed, the operand field is empty.

## Usage Context

Begins the HALMAT text for an update block (`label: UPDATE;`), closed by
the same generic [CLOS](CLOS.md) (0x030) instruction used for
`PROGRAM`/`PROCEDURE`/`FUNCTION`/`TASK` — **confirmed empirically this
session**, resolving the question below. See also
[MDEF](MDEF.md)/[TDEF](TDEF.md)/[PDEF](PDEF.md)/[FDEF](FDEF.md), the
other compilation-unit definition headers.

Confirmed by compiling:

```
UPB: UPDATE;
   S1 = S1 + 1.0;
CLOSE UPB;
```

with `HALSFC --parms="LISTING2,LSTALL"`, cross-checked directly with
`unHALMAT.py`:

```
HALMAT: 02E(1),0,0        <- UDEF: opens the UPDATE block
          3(1),0,0           <- op: UPB, symbol index 3, QUAL=1=SYT
...
HALMAT: 030(1),0,0        <- CLOS: closes it (same opcode as CLOSE PROGRAM;)
          3(1),0,0           <- op: UPB, symbol index 3, QUAL=1=SYT
```

## Operand-Word Format (confirmed empirically)

One operand: `DATA`=symbol-table index of the update block's own label
(a `STATEMENT LABEL`-classed symbol, per `pass1.rpt`'s symbol table),
`QUAL`=1=SYT.

## Unresolved Questions

- ~~Whether HAL/S has a distinct UEND-equivalent closing opcode~~
  **Resolved**: no — HAL/S has **no `UEND` opcode anywhere in the
  compiler source** (confirmed by grepping all seven compiler passes,
  including shared includes, for `XUEND`: zero matches). It reuses
  [CLOS](CLOS.md) for update blocks, exactly as this file's own earlier
  hypothesis suggested.
- Whether an unnamed `UPDATE;` block (per this file's own Behavioral
  Description, "if unnamed, the operand field is empty") compiles with
  `NUMOP`=0 rather than a null/placeholder operand was not tested — only
  the named form (`UPB: UPDATE;`) was compiled.

## Source Analysis & Reliability

Opcode (0x02E) and mnemonic are primary-sourced from [IR-60-5] A.2 (p.
A-103); no page content for UDEF's own HAL/S description (target p. 9) is
present in the available partial copy.

Behavioral description drawn from [MSC-01847] p. 2-16, describing the
identically-named predecessor-language instruction (HAL 1971 opcode 0x033,
differing from HAL/S's 0x02E). See [STRI](../class-8/STRI.md)'s Source
Analysis section for the general basis of this cross-language inference.
Operand-word format and the CLOS-closing behavior confirmed directly
against real compiled HALMAT this session via a direct `unHALMAT.py`
binary read.
