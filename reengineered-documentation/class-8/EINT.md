# EINT

**Mnemonic:** EINT

**Opcode:** 0x8E3

**Confidence:** High

## Behavioral Description

`EQUATE EXTERNAL` statement. Implements HAL/S's `EQUATE EXTERNAL
<identifier> TO <variable>;` declaration — undocumented in [USA003087]'s
body text, but directly confirmed by [CourseSlides.pdf] (PDF pp. 486–487,
"DATA CSECTS (CONTINUED)"): it creates a linker-visible entry point,
letting **non-HAL/S modules** access a HAL/S-declared data item under an
externally-chosen name:

> "ENTRY POINTS CAN BE CREATED BY THE USER (VIA THE EQUATE EXTERNAL
> FACILITY) WHICH ALLOW NON-HAL MODULES TO ACCESS COMPOOL DATA... AN
> EQUATE EXTERNAL TAKES UP NO SPACE... WHAT IT DOES IS TO GENERATE AN ESD
> RECORD IN THE OBJECT DECK WHICH MARKS THE SPECIFIED VARIABLE AS AN
> ENTRY POINT (NAMED BY EXTNAME) OF THE CSECT IN WHICH THE VARIABLE IS
> LOCATED. THE EQUATE EXTERNAL IS DESIGNED FOR EXTERNAL (NON-HAL) USE
> ONLY. IT IS ALSO NOT RESTRICTED TO COMPOOL DATA, BUT MAY BE USED WITH
> ANY DECLARED (STATIC) DATA. THE EQUATE MAY POINT TO ANY PREVIOUSLY
> DEFINED HAL VARIABLE AND COMPLEX SUBSCRIPTING IS ALLOWED PROVIDED ALL
> SUBSCRIPTING CAN BE EVALUATED AT COMPILE TIME."

i.e. it is IBM-BAL/AP-101S linker terminology, not a HAL/S-level alias:
an ESD (External Symbol Dictionary) record naming an *entry point* into
the CSECT already generated for the target variable — analogous to a
FORTRAN `ENTRY` statement or a linker `ALIAS`/`PUBLIC` directive, letting
assembly-language or other non-HAL/S-compiled code address a HAL/S data
item by a name convenient to the external caller, without HAL/S itself
ever using that name in an expression:

```
POOL:
COMPOOL;
   DECLARE X SCALAR;
   EQUATE EXTERNAL Y TO X;
CLOSE POOL;
```

This confirms and supersedes the prior "inferred" purpose in this file:
`Y`'s symbol-table entry is entered as a distinct `EQUATE_LABEL`-typed
entry, flagged `INACTIVE` immediately by the scanner/identifier stage
(`PASS1.PROCS/IDENTIFY.xpl`, case "EQUATE": `SYT_FLAGS(I) =
INACTIVE_FLAG; /* WILL BE LEFT IN HASH TABLE FOREVER SINCE IT APPEARS TO
BE ALREADY DISCONNECTED */`) — it is not usable as an ordinary HAL/S
identifier in subsequent expressions (confirmed: referencing `Y` later
produced `UNDECLARED IDENTIFIER Y`), exactly as expected for a
linker-only entry-point name. `Y` shows up as its own `LD` entry at `X`'s
address in the PASS2 symbol-table dump — the compiled-object-level
manifestation of the ESD entry point described above.

Also confirmed empirically: `EQUATE EXTERNAL` is **not** restricted to
`COMPOOL` blocks, matching the course material's "not restricted to
compool data, but may be used with any declared (STATIC) data" — compiling
it directly inside a plain `PROGRAM` block (`DECLARE ARR SCALAR; EQUATE
EXTERNAL EXTNAME TO ARR;`, no compool at all) succeeds and emits the same
`8E3` instruction. The subscripted-target form (`EQUATE EXTERNAL EXTNAME
TO ARR(4);`, per the slides' own worked example) is source-confirmed by
[CourseSlides.pdf] but was not successfully compiled this session (see
Unresolved Questions) — the compile-time-evaluable-subscript restriction
matches this project's established general pattern for subscript
handling elsewhere (e.g. [SINT](SINT.md)'s OFFSET-addressed form).

## Usage Context

A `<DECLARE ELEMENT>` alternative (`PASS1.PROCS/SYNTHESI.xpl`: `<DECLARE
ELEMENT> ::= EQUATE EXTERNAL <IDENTIFIER> TO <VARIABLE> ;`), usable
anywhere an ordinary `DECLARE` statement is (confirmed in both `COMPOOL`
and plain `PROGRAM` blocks), but constrained: the target `<VARIABLE>`
must be declared in the *same* lexical block as the `EQUATE EXTERNAL`
statement itself (`SYT_SCOPE(I) ^= SYT_SCOPE(J)` triggers error `DU7`,
confirmed: `EQUATE EXTERNAL Z TO X;` in a `PROGRAM` block referencing `X`
from a separate, earlier `EXTERNAL COMPOOL` block failed with `"THE
VARIABLE X REFERENCED IN AN EQUATE STATEMENT IS DEFINED OUTSIDE THE
CURRENT BLOCK"` — consistent with the course material's "may point to any
*previously defined* HAL variable," i.e. within the same compilation
unit); the target's type must be an ordinary data type (`SYT_TYPE(J) >
MAJ_STRUC` is rejected, error `DU8`); and several other attribute
combinations (precision-modified/`SUBBIT`/`NAME(.)`-form targets) are
explicitly rejected (errors `DU9`–`DU14`). Confirmed **not** to emit any
HALMAT at all when used inside an `EXTERNAL COMPOOL;` *template* block
(consistent with [CDEF](../class-0/CDEF.md)'s documented finding that
template blocks generate no HALMAT whatsoever); requires a real
(non-template) block to observe the emitted instruction.

## Operand-Word Format (confirmed empirically)

Two operands: operand 1 = the new equate name's own symbol-table entry
(`Y` above), `DATA`=its symbol-table index, `QUAL`=1=SYT; operand 2 = the
target variable (`X` above), `DATA`=its symbol-table index, `QUAL`=1=SYT
(`PSEUDO_FORM(TEMP)`, observed `1`=SYT for a plain unsubscripted scalar
target — may vary for other target forms, untested). The operator word's
trailing tag carries the target's `PSEUDO_TYPE` (observed `5` for a
`SCALAR` target). Confirmed by compiling the example above with
`HALSFC --parms="LSTALL"`:

```
HALMAT: 8E3(2),5,0             <- EINT, trailing tag 5 = PSEUDO_TYPE(X) (SCALAR)
          3(1),0,0                 <- Y, symbol index 3, QUAL=1=SYT (the new equate name)
          2(1),0,0                 <- X, symbol index 2, QUAL=1=SYT (the target variable)
```

The PASS2 symbol-table dump additionally shows `Y` as a distinct `LD`
entry at `X`'s own address (`000000`), confirming `Y` is emitted purely as
an alternate linkage-table name rather than a separate data cell.

## Unresolved Questions

- The exact meaning/encoding of the operator word's trailing `PSEUDO_TYPE`
  tag is inferred (matches [ICQCHECK.xpl](../STATUS.md)'s type-dispatch
  scheme by analogy with [TINT](TINT.md)/[NINT](NINT.md)) but not
  independently decoded bit-by-bit.
- The subscripted-target form (`EQUATE EXTERNAL EXTNAME TO ARR(4);`, per
  [CourseSlides.pdf]'s own worked example) was attempted but not
  successfully compiled this session — inline `(4)` was rejected as
  syntactically illegal, and moving the subscript to its own S-line (the
  trick that worked for subscripted `ERROR` specifications, see
  [ERON](../class-0/ERON.md)) instead produced a different parse error;
  the correct card-column form for a subscripted `<VARIABLE>` in this
  position wasn't found. The unsubscripted form is fully confirmed.
- What the generated ESD entry-point record actually looks like at the
  object-code level (i.e. independently verifying [CourseSlides.pdf]'s
  claim by inspecting `auxmat.bin`/the assembled object deck rather than
  just the PASS2 text-report symbol dump) was not investigated.

## Source Analysis & Reliability

Opcode (0x8E3) confirmed primary-source: `XEINT BIT(16) INITIAL("8E3")` in
`PASS1.PROCS/##DRIVER.xpl` (grouped with [NINT](NINT.md)'s `XNINT` and
[TINT](TINT.md)'s `XTINT`) — see [##DRIVER.xpl] in `STATUS.md`. Found by
grepping the full `PASS.REL32V0` compiler source tree for every site
referencing `XEINT`, which led directly to `PASS1.PROCS/SYNTHESI.xpl`'s
grammar-rule comment `/* <DECLARE ELEMENT> ::= EQUATE EXTERNAL
<IDENTIFIER> TO <VARIABLE> ; */` and its emitting code (`CALL
HALMAT_POP(XEINT, 2, 0, PSEUDO_TYPE(TEMP));`). The `EQUATE` keyword itself
was independently confirmed as a genuine HAL/S reserved word via
`PASS1.PROCS/SCAN.xpl`/`IDENTIFY.xpl` and via [USA003087]'s own
reserved-word appendix (PDF p. 18479 of the `pdftotext -layout`
extraction), even though the statement's semantics are undocumented in
that guide's body text.

**Real-world purpose confirmed by a second, independent primary source**:
[CourseSlides.pdf] ("Basic HAL/S Programming Course," `Courses/Basic
HAL-S Programming Course/CourseSlides.pdf`), PDF pp. 486–487 ("DATA
CSECTS (CONTINUED)"), directly documents `EQUATE EXTERNAL` in prose (with
a worked example closely matching this file's own independently-derived
test case) as generating an ESD entry-point record for non-HAL/S linkage
— confirming, rather than merely being consistent with, this file's
compiler-source-derived inference about the construct's purpose. This is
the first case in this project where a primary source was found *after*
an opcode's behavior was already inferred purely from compiler source
code, and it validates that inference exactly.

Full behavioral description and operand-word structure confirmed directly
against real compiled HALMAT this session, resolving a previously "Not
started" opcode; purpose subsequently upgraded from inferred to
source-confirmed in a follow-up session after the user supplied the
[CourseSlides.pdf] reference.
