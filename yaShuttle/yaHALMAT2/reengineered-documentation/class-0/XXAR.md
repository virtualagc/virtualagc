# XXAR

**Mnemonic:** XXAR

**Opcode:** 0x027

**Confidence:** High

## Behavioral Description

Argument-list entry. Specifies one variable in the argument list of a
`READ`/`READALL`/`WRITE` statement, **or** — confirmed this session — a
`CALL`/function invocation's input or assign argument list. One XXAR per
argument, between the [XXST](XXST.md) header and the corresponding
instruction ([READ](READ.md)/[RDAL](RDAL.md)/[WRIT](WRIT.md)/
[PCAL](PCAL.md)/[FCAL](FCAL.md)). Single operand: `DATA`=the argument
variable's (or, for an I/O control specifier's parenthesized expression,
a literal/symbol/VAC reference to that expression's value) symbol- or
literal-table index, ordinarily `QUAL`=1=SYT; `TAG1` carries a type code.
Now fully enumerated for the six "HAL variable types" — confirmed by
compiling `READ(5) B1/V1/M1/I1/S1/C1;` for each type in turn: `1`=BIT,
`2`=CHARACTER, `3`=MATRIX, `4`=VECTOR, `5`=SCALAR, `6`=INTEGER — **exactly
matching HALMAT's own CLASS numbering** (Class 1=bit, 2=char, 3=matrix,
4=vector, 5=scalar, 6=integer; see [HALMAT.md](../HALMAT.md#instruction-classes)),
i.e. `TAG1` is literally the argument's HALMAT class number. A structure
argument is a distinct case: `QUAL`=4=XPT instead of 1=SYT (an "extended
pointer" reference, per [EXTN](EXTN.md)) and `TAG1`=`10`, confirmed by
compiling `READ(5) T1;` for a `RIGID` structure variable — `10` doesn't
fit the class-number pattern above (structures have no HALMAT class of
their own; their class-0 operations are `TASN`/`TEQU`/`TNEQ`).

The trailing `TAG2` field's meaning is
**context-dependent** on the surrounding construct: for a procedure/
function call's argument list it distinguishes an input argument (`0`)
from an assign argument (`1`) — see [XXST](XXST.md) for the `CALL
TWO(I1) ASSIGN(I1);` trace. For a `READ`/`READALL`/`WRITE` argument list
— **confirmed this session, resolving a long-standing open question** —
the same field instead carries an **I/O control-specifier kind code**:
`0`=plain variable/expression argument, `1`=`TAB(n)`, `2`=`COLUMN(n)`,
`3`=`SKIP(n)`, `4`=`LINE(n)`, `5`=`PAGE(n)`. This is exactly HAL
1971's five separate `FCLM`/`FLIN`/`FPGE`/`FSKP`/`FTAB` I/O-specifier
opcodes ([MSC-01847] §2.11), folded into this one field's value on an
otherwise-ordinary XXAR entry rather than surviving as distinct HAL/S
opcodes — the same consolidation pattern already documented for
`LIST`/`LSTE`/`CASS` (see [XXST](XXST.md) and `STATUS.md`).

## Usage Context

See [XXST](XXST.md) for the full bracketing construct and worked traces
of both the I/O and procedure/function-call cases. One XXAR per
argument, in source order; an I/O control specifier (`TAB`/`COLUMN`/
`SKIP`/`LINE`/`PAGE`) occupies its own XXAR slot in source position,
exactly like an ordinary argument, distinguished only by `TAG2`.

Confirmed by compiling `READ(5) TAB(2), I1;` / `READ(5) COLUMN(3), I1;` /
`READ(5) SKIP(1), I1;` / `READ(5) LINE(4), I1;` / `READ(5) PAGE(1), I1;`
and `READALL(5) PAGE(1), COLUMN(2), C1;` (`C1` a `CHARACTER(10)`) with
`HALSFC --parms="LISTING2,LSTALL"`, cross-checked directly against the
compiled binary with `unHALMAT.py`. `READ(5) TAB(2), I1;` — note the
device number `5` is READ's own operand, not XXST's (see
[XXST](XXST.md)/[READ](READ.md) for this correction):

```
HALMAT: 025(1),0,0        <- XXST: op 0=READ (its only operand)
HALMAT: 027(1),0,0        <- XXAR: the TAB(2) specifier
          3(5),6,1          <- op: literal-table index 3 (value 2), QUAL=5=LIT,
                                TAG1=6 (INTEGER, the type of "2"), TAG2=1=TAB
                                 -> object code: LFXI 5,4 / SCAL 0,#QTAB
HALMAT: 027(1),0,0        <- XXAR: I1
          2(1),6,0           <- op: I1, symbol index 2, QUAL=1=SYT,
                                TAG1=6 (INTEGER), TAG2=0=plain argument
                                 -> object code: LA 2,I1 / SCAL 0,#QHIN
HALMAT: 01F(1),0,0        <- READ header: op device=5 (its own operand)
HALMAT: 026(0),0,0        <- XXND
```

`READALL(5) PAGE(1), COLUMN(2), C1;` (confirms `TAG2`=5 for `PAGE` and
=2 for `COLUMN`, and that `READALL` uses this identical mechanism):

```
HALMAT: 025(1),0,0        <- XXST: op 1=READALL (its only operand)
HALMAT: 027(1),0,0        <- XXAR: PAGE(1)
          3(5),6,5           <- TAG2=5=PAGE -> object code: SCAL 0,#QPAGE
HALMAT: 027(1),0,0        <- XXAR: COLUMN(2)
          4(5),6,2           <- TAG2=2=COLUMN -> object code: SCAL 0,#QCOLUMN
HALMAT: 027(1),0,0        <- XXAR: C1
          2(1),2,0           <- TAG1=2 (CHARACTER), TAG2=0=plain
                                 -> object code: LA 2,C1 / SCAL 0,#QCIN
HALMAT: 020(1),0,0        <- RDAL header: op device=5 (its own operand)
HALMAT: 026(0),0,0        <- XXND
```

Each `TAG2` value drives a distinct PASS2-generated runtime call —
`#QTAB`/`#QCOLUMN`/`#QSKIP`/`#QLINE`/`#QPAGE` respectively for the five
I/O-control kinds, versus a plain-argument call whose name depends on
the transferred variable's type and I/O direction instead (`#QHIN` for
integer-in, `#QCIN` for character-in, `#QEOUT` for scalar-out observed
here) — independent confirmation that `TAG2`'s value, not `TAG1` or the
runtime-call name, is what selects the I/O-control behavior.

**`TAG1` type-code enumeration**, confirmed by compiling separate `READ`
statements for each type (`B1` a `BIT(16)`, `V1` a `VECTOR(3)`, `M1` a
`MATRIX(2,2)`):

```
READ(5) B1;   ->  2(1), 1,0    <- TAG1=1=BIT
READ(5) V1;   ->  3(1), 4,0    <- TAG1=4=VECTOR
READ(5) M1;   ->  4(1), 3,0    <- TAG1=3=MATRIX
```

— together with the INTEGER/SCALAR/CHARACTER values already shown above,
this fully enumerates the six HAL variable types (BIT=1, CHARACTER=2,
MATRIX=3, VECTOR=4, SCALAR=5, INTEGER=6 — HALMAT's own CLASS numbers).

**Structure argument**, confirmed by compiling a `RIGID` structure
variable `T1`:

```
READ(5) T1;
HALMAT: 027(1),0,0        <- XXAR: T1
         13(4),10,0          <- op: DATA=13, QUAL=4=XPT (not 1=SYT!),
                                TAG1=10, TAG2=0=plain argument
```

Unlike every scalar-typed case above, a structure argument's operand is
`QUAL`=4=XPT (an "extended pointer" reference — see [EXTN](EXTN.md)) with
`TAG1`=`10`, a value outside the class-number sequence (structures have
no HALMAT class of their own — their class-0 operations are
[TASN](TASN.md)/[TEQU](TEQU.md)/[TNEQ](TNEQ.md)).

**Whole VECTOR/MATRIX/ARRAY argument** (`WRITE(6) V;`/`WRITE(6) M;`,
`V` a `VECTOR(3)`, `M` a `MATRIX(2,2)`) — resolved this session,
answering the "arrayed argument" question below: `QUAL` stays `1`=`SYT`
and `TAG1` stays the ordinary class number (`4`=`VECTOR`, `3`=`MATRIX`),
exactly like an unarrayed scalar argument. Confirmed by compiling
`WRITE(6) X;` (`X` a `VECTOR(3)`) and `WRITE(6) N;` (`N` a `MATRIX(2,2)`)
with `HALSFC --parms="LISTING2,LSTALL"`:

```
HALMAT: 025(1),0,0        <- XXST: op 2=WRITE
HALMAT: 027(1),0,0        <- XXAR: X
          2(1),4,0           <- op: DATA=2 (symbol X), QUAL=1=SYT, TAG1=4=VECTOR
HALMAT: 021(1),0,0        <- WRIT: op device=6
HALMAT: 026(0),0,0        <- XXND
```

Critically, **this is not wrapped in an `ADLP`/`DLPE` per-element
replay** the way a whole plain (or `BIT`/`CHARACTER`) `ARRAY` WRITE
argument is (confirmed separately, compiling `WRITE(6) C;` for a
`CHARACTER ARRAY C` — see [ADLP](ADLP.md)/[DLPE](DLPE.md)): a
`VECTOR`/`MATRIX` argument's single `XXAR` entry stands alone, with the
whole element list expected to be written out by whatever consumes it
(yaHALMAT2's `OP_XXAR`/`flush_write`, per [USA00309]/USA003087 Sec.
12.2's data-field layout rules) — there is no per-element replay
mechanism to lean on the way `ARRAY` gets one. A `MATRIX` row/column
partition select (`M$(1,*)`/`M$(*,2)`) instead arrives as a
`QUAL`=3=`VAC` operand referencing a prior [DSUB](DSUB.md) asterisk-
subscript result, not a direct `SYT` reference — see DSUB.md's own
confirmation of that shape.

**The identical shape is used for a `PCAL`/`FCAL` procedure/function-call
argument, not just `WRITE`** — confirmed this session by a second user
report (`CALL some_procedure(a_whole_matrix);` failing with the same
"outside an arrayed-paragraph replay" message): `QUAL`=1=`SYT`,
`TAG1`=the class number, no replay, exactly as above. yaHALMAT2 now
copies such an argument's elements into the callee's own parameter
storage by value (USA003087 Sec. 11.4's "assignment... to its
corresponding input parameter" transmission model, shape-conformance-
checked per Sec. 11.2/11.4's "rows and columns... must be the same"
rule) rather than expanding it into data fields — see
[PCAL](PCAL.md)/[FCAL](FCAL.md) for the call-side details.

## Unresolved Questions

- ~~Whether an *arrayed* argument of any type (not just a structure)
  also switches `QUAL` away from `SYT`/uses extra operand words is
  unconfirmed — only unarrayed variables of each type were tested.~~
  **Resolved this session** for `VECTOR`/`MATRIX`/`ARRAY` — see the
  "Whole VECTOR/MATRIX/ARRAY argument" note above. Still unconfirmed
  for an arrayed *structure* argument specifically (e.g. a
  `DECLARE T(3) ...` "copiness" structure passed whole to `READ`/
  `WRITE`) — not tested either this session or previously.
- ~~HAL 1971's `FASN`~~ ("file assignment", [MSC-01847] §2.12, listed
  alongside `FILE`) **resolved this session**: it has no HAL/S
  counterpart anywhere, and now there's a documented reason why.
  [USA00309]'s (HAL/S-FC User's Manual) §6.1.4 "JCL Considerations"
  states device numbers 2–9 map to a **fixed** DD name, `CHANNELn` (e.g.
  device 5 → DD name `CHANNEL5`) — the channel-to-dataset association is
  entirely a JCL-level convention, resolved once per job by the DD cards
  supplied outside the HAL/S program, not something any HAL/S statement
  (and therefore no HALMAT instruction) ever expresses. HAL-1971's
  physical channel/dataset-assignment role was superseded by this fixed
  naming convention in HAL/S-FC, not dropped from a working feature or
  hidden in an existing opcode.

## Source Analysis & Reliability

Opcode (0x027) confirmed primary-source: `XXXAR BIT(16) INITIAL("027")`
in `PASS1.PROCS/##DRIVER.xpl` — see [##DRIVER.xpl] in `STATUS.md`. Not
present in [MSC-01847] under this name, though its I/O-control-kind use
of `TAG2` directly replaces that document's `FCLM`/`FLIN`/`FPGE`/`FSKP`/
`FTAB` (§2.11). Behavioral description and operand-word structure
directly confirmed against real compiled HALMAT this session — see
[XXST](XXST.md) for the general trace and this file's Usage Context for
the I/O-control-specific traces. The `TAG2`-as-IO-control-kind mechanism
was located by reading `PASS1.PROCS/SYNTHESI.xpl`'s `<IO CONTROL>`
grammar rules (`TAB`/`COLUMN`/`SKIP`/`LINE`/`PAGE`, each setting a
distinct `TEMP` value 1–5 before falling through to the shared
`<READ ARG>`/`<WRITE ARG>` emission code) and
`PASS1.PROCS/HALMATF3.xpl`'s `HALMAT_FIX_PIPTAGS` procedure (which
writes its `TAG1`/`TAG2` parameters into an XXAR operand word's `TAG1`/
`TAG2` bit positions, confirming the field is physically the same one
used for the CALL-argument input/assign flag), then confirmed
empirically as shown above.
