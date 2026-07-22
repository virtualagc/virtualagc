# STRI

**Mnemonic:** STRI

**Opcode:** 0x801

**Confidence:** High

## Behavioral Description

Repeated-initialize specifier. STRI indicates that the symbol-table operand
it specifies is to be initialized element-by-element via a following
sequence of "loop" instructions, rather than by a single literal.

In the predecessor language HAL (1971), the analogous construct is a
three-instruction group: STRI (opcode 0x801 in that language's own,
differently-organized opcode space) names the variable being repeat-
initialized and the number of initialize loops that follow; DLPI
("initialize loop header") opens each loop, giving the loop count and
increment; DLEI ("initialize loop end") closes it. Concretely, STRI's
first operand identifies the symbol-table variable; a second operand gives
an internal integer variable shared with the following DLPI/DLEI pair; a
third value gives the number of initialize loops following the
instruction.

## Usage Context

Appears within a "static bypass block" (see [ENTS](../STATUS.md)/[EXTS](../STATUS.md),
not yet documented) surrounding a group of variable initializations, in
place of a plain initialize instruction ([SINT](SINT.md), [VINT](VINT.md),
[MINT](MINT.md), etc.) when the initializing values must be produced by a
repeat loop rather than listed as a flat sequence of literals (e.g.
initializing every element of an array with the same value, or
initializing successive elements from a repeating literal pattern).

Confirmed this session to also bracket two further, distinct kinds of
group, for a total of three:

- Whole-structure `INITIAL(...)` lists ([USA003087] §19.6), where STRI
  opens a sequence of one [TINT](TINT.md) per structure terminal (rather
  than one [SINT](SINT.md) per array element), closed the same way by
  [ETRI](ETRI.md). See [TINT](TINT.md) for the confirming worked example.
- Explicit-literal-list VECTOR/MATRIX/ARRAY `INITIAL(v1, v2, ...)` lists
  (as opposed to the `n#value` uniform-repetition form below) — STRI
  opens a bare sequence of one or more [SINT](SINT.md)s (one per
  *coalesced run* of consecutive literal values, per [SINT](SINT.md)'s
  own run-length mechanism), with **no [SLRI](SLRI.md)/[ELRI](ELRI.md)
  at all**, closed by [ETRI](ETRI.md). See [SINT](SINT.md) for the
  confirming worked example (this was the case a real yaHALMAT2 bug
  report, `source-documentation/BAD_INITIAL.md`, turned up as unhandled).

I.e. STRI/ETRI is a general "repeated/structured initialization group"
bracket reused across all three cases ([SLRI](SLRI.md)/[ELRI](ELRI.md)
appear only in the `n#value` case, not the other two).

## Operand-Word Format (confirmed empirically)

One operand: `DATA`=the SYT index of the variable being repeat-
initialized, `QUAL`=SYT. Unlike the HAL-1971 predecessor's three-operand
form (variable, shared internal loop counter, loop count), HAL/S's STRI
carries only the target symbol — the repetition count instead lives on
the following [SLRI](SLRI.md)'s own first operand. Confirmed by
compiling `DECLARE A ARRAY(3) SCALAR INITIAL(3#1.5);`:
```
HALMAT: 801(1),0,0            <- STRI: A, symbol index 2
```
See [SLRI](SLRI.md) for the full worked trace including the following
SLRI/SINT/ELRI/ETRI sequence.

## Unresolved Questions

- Whether HAL/S retains the same three-instruction STRI/DLPI/DLEI grouping
  structure as the 1971 predecessor, or restructures it: **resolved** —
  it does not; see Operand-Word Format above. HAL/S's STRI carries only
  the target symbol, one operand.
- ~~The relationship (if any) between STRI and the separately-opcoded
  HAL/S instructions at 0x02 and 0x03... is speculative.~~ **Resolved**:
  0x802/0x803 are [SLRI](SLRI.md)/[ELRI](ELRI.md), HAL/S's renamed
  successors to HAL-1971's DLPI/DLEI, empirically confirmed — see Usage
  Context above.

## Source Analysis & Reliability

The opcode (0x801) and mnemonic STRI are primary-sourced from [IR-60-5] A.2
(the Class 8 operator index, p. A-109); no page content for STRI's own
HAL/S description (target p. 85) is present in the available partial copy.

The behavioral description here is drawn from [MSC-01847] pp. 2-41–2-42,
which documents STRI (there under a different, HAL-1971-specific opcode,
0x801) for the *predecessor* language HAL. [MSC-01847] uses a physically
different instruction encoding (fixed 4-halfword records) from HAL/S's
variable-length operator+operand-word scheme, so none of its bit-level
diagrams are transferable; only the semantic/behavioral description is
used here, at Medium confidence, on the strength of the opcode-scheme
correspondence documented in [HALMAT.md](../HALMAT.md#instruction-classes)
(HAL 1971's flat hundreds-digit opcode grouping corresponds directly to
HAL/S's CLASS field, and Class 8's individual opcode assignments match
almost exactly between the two language versions — see
[STATUS.md](../STATUS.md) for the full comparison table).
