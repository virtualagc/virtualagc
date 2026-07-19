# EXTN

**Mnemonic:** EXTN
**Opcode:** 0x001
**Confidence:** High

## Behavioral Description

"Extended pointer" — resolves a (possibly qualified) structure-variable
reference into a chain of symbol-table entries, one per level of
qualification. Confirmed primary-source: `PASS1.PROCS/SYNTHESI.xpl`'s
grammar rule `<STRUCTURE VAR> ::= <QUAL STRUCT> <SUBSCRIPT>` — EXTN is
emitted (`CALL HALMAT_TUPLE(XEXTN,0,MP,0,0)`) whenever a structure
variable is referenced, immediately followed by a `DO WHILE TEMP_SYN^=0`
loop that emits one further operand word (`CALL HALMAT_PIP(TEMP3,XSYT,
0,0)`) per symbol-table level, walking the structure's qualification
chain. In terms of runtime execution it behaves like a NOP (see
[NOP](NOP.md)) — it carries no computational effect of its own; its sole
purpose is to pre-resolve a structure reference into the symbol table so
that a following instruction ([TEQU](TEQU.md)/[TNEQ](TNEQ.md)/
[TASN](TASN.md)/etc.) can refer back to it via an `XPT` (stream-position)
operand rather than re-resolving the qualification chain itself.

## Usage Context

Emitted immediately before any instruction that consumes a whole
structure operand — confirmed usage sites in this project's own prior
compiled traces: [TEQU](TEQU.md)/[TNEQ](TNEQ.md) (`IF ZQ1 = ZQ2 THEN
...;`), [TASN](TASN.md) (`ZQ2 = ZQ1;`), and, confirmed this session, a
qualified single-field reference (`ZQ1.QI = 1;`), each preceded by one
EXTN per structure operand. The consuming instruction's own operands are
`XPT` (`QUAL`=4)-qualified references giving the *stream position* of
the corresponding EXTN instruction, not a symbol-table index directly —
this is the "extended pointer" indirection the mnemonic refers to.

## Operand-Word Format (confirmed empirically)

Two operand words, both `DATA`=a symbol-table index, `QUAL`=1=SYT.
**Now directly confirmed via a fresh `unHALMAT.py` binary read**
(`HALSFC --parms="LISTING2,LSTALL"`), superseding an earlier
reconstruction of the same shape from `pass2.rpt`'s out-of-order
printing (see Source Analysis for why that reconstruction, though it
turned out correct, is no longer the basis for this claim):

**Qualified reference** (`ZQ1.QI`, `ZQ1.QS`): operand 1 = the base
structure variable's own symbol (`ZQ1`); operand 2 = the referenced
field's own symbol (`QI`/`QS`) — i.e. base-then-qualifier, matching
left-to-right source order:

```
HALMAT: 001(2),0,0            <- EXTN, resolves ZQ1.QI
          5(1),0,0                <- op 1: ZQ1 (the structure), QUAL=1=SYT
          3(1),0,1                <- op 2: QI (the field), QUAL=1=SYT
```

**Unqualified reference** (`ZQ2`, `ZQ1`, no `.` levels — from `ZQ2 =
ZQ1;`, a [TASN](TASN.md) source): still resolves to two operand words,
not one, confirming the earlier hypothesis exactly — operand 1 = the
structure variable's own symbol; operand 2 = the structure's
**`TEMPLATE` symbol** (confirmed directly this time, not merely
guessed at):

```
HALMAT: 001(2),0,0            <- EXTN, resolves ZQ2 (bare reference)
          6(1),0,1                <- op 1: ZQ2 (the structure variable), QUAL=1=SYT
          2(1),0,1                <- op 2: Q (the TEMPLATE's own symbol), QUAL=1=SYT
```

## Unresolved Questions

- Whether a genuinely multi-level qualified reference (`A.B.C`) produces
  three or more operand words (one per `.`-level, per the `DO WHILE
  TEMP_SYN^=0` loop's general shape) was not tested — only single-level
  qualification (`ZQ1.QI`) and the bare/unqualified case are confirmed.
- The trailing tag `1` seen on some but not all operands above (e.g. on
  `QI`'s and the template's own operand, but not on the structure
  variable's) is not decoded.
- `PASS1.PROCS/ICQOUTPU.xpl`'s separate `EXTN` use site
  (`CALL HALMAT_POP(XEXTN,2,0,0)`, hardcoded `NUMOP`=2, called during
  initial-constant-list processing rather than expression synthesis) was
  not investigated — whether it represents the same or a different
  triggering construct is unconfirmed.

## Source Analysis & Reliability

The opcode (0x001) confirmed doubly: `XEXTN BIT(16) INITIAL("001")` in
`PASS1.PROCS/##DRIVER.xpl` (see [##DRIVER.xpl] in `STATUS.md`), and
[IR-60-5] A.2 (p. A-103), which lists EXTN as Class 0 operator 1. Found
by grepping the full `PASS.REL32V0` compiler source tree for every site
referencing `XEXTN`, confirming (rather than merely reproducing from the
secondary source [Halmat.pdf]) the four compiler-source sites
(`ICQOUTPU.xpl`, `SYNTHESI.xpl`, `GENERATE.xpl`, `RELOCAT2.xpl`) and, new
this session, the exact grammar rule (`<STRUCTURE VAR> ::= <QUAL STRUCT>
<SUBSCRIPT>`) and operand-emission loop directly from `SYNTHESI.xpl`
itself. The operand-word format was originally recovered (in an earlier session)
by re-reading this project's own already-compiled `pass2.rpt` output from
the [TNEQ](TNEQ.md) confirmation test, whose raw text already contained
EXTN's operand words (previously overlooked because the report tool
prints them out of textual order, after the consuming instruction) — a
reconstruction, not a direct reading. **Superseded this session**: a
fresh `unHALMAT.py` binary read (of the already-compiled
[TASN](TASN.md) test, which includes both a qualified-reference and a
bare-reference case) directly confirms the same shape the earlier
reconstruction guessed at, and additionally identifies operand 2's exact
identity in both cases (the field's own symbol for a qualified
reference; the structure's `TEMPLATE` symbol for a bare one) — seeing
firsthand how a `pass2.rpt`-based reconstruction can independently arrive
at a correct answer despite the tool's general unreliability for operand
ordering (see [XXST](XXST.md) for cases where the same kind of
reconstruction went wrong instead).
