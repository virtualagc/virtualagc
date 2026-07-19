# STRI

**Mnemonic:** STRI
**Opcode:** 0x01
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

Confirmed this session to also bracket a second, distinct kind of group:
whole-structure `INITIAL(...)` lists ([USA003087] §19.6), where STRI opens
a sequence of one [TINT](TINT.md) per structure terminal (rather than one
[SINT](SINT.md) per array element), closed the same way by
[ETRI](ETRI.md) — i.e. STRI/ETRI is a general "repeated/structured
initialization group" bracket reused for both the array-uniform-value case
([SLRI](SLRI.md)/[ELRI](ELRI.md) appear only in that case, not the
structure case) and the structure-terminal case. See [TINT](TINT.md) for
the confirming worked example.

## Unresolved Questions

- The HAL/S operand-word format (DATA/TAG1/QUAL/TAG2 layout, per
  [HALMAT.md](../HALMAT.md#operand-word-bit-0--1)) for STRI's operands is
  unconfirmed; only the opcode number is primary-sourced.
- Whether HAL/S retains the same three-instruction STRI/DLPI/DLEI grouping
  structure as the 1971 predecessor, or restructures it, is unconfirmed.
- The relationship (if any) between STRI and the separately-opcoded
  HAL/S instructions at 0x02 and 0x03 (see [STATUS.md](../STATUS.md);
  possibly renamed/restructured successors to DLPI/DLEI) is speculative.

## Source Analysis & Reliability

The opcode (0x01) and mnemonic STRI are primary-sourced from [IR-60-5] A.2
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
