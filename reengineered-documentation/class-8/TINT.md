# TINT

**Mnemonic:** TINT

**Opcode:** 0xE2

**Confidence:** High

## Behavioral Description

Structure-terminal initialize. Emitted once for each terminal node of a
`STRUCTURE`-templated data item that is initialized as a whole via an
`INITIAL(...)` specification on the *structure* declaration itself
([USA003087] §19.6, "INITIALIZATION OF STRUCTURES"):

```
STRUCTURE Q:
    1 QI INTEGER,
    1 QS SCALAR;
DECLARE Z Q-STRUCTURE INITIAL(5,4.3);
```

Here the literal list `(5,4.3)` supplies one value per structure terminal,
in template declaration order (`QI` then `QS`), and each terminal's own
initialization is compiled as a separate TINT instruction — the direct
class-8 analog of [SINT](SINT.md)/[IINT](IINT.md)/etc. for whole-structure
initialization, distinguished from those by being selected specifically
when the item being initialized has `SYT_TYPE = MAJ_STRUC` (a major
structure), per `PASS1.PROCS/ICQCHECK.xpl`'s `ICQ_CHECK_TYPE` dispatch —
see Source Analysis.

## Usage Context

Appears within a "static bypass block" (see [BINT](BINT.md) for the
general pattern), bracketed by [STRI](STRI.md) (opens the repeated/
structured initialization) and [ETRI](ETRI.md) (closes it) — the same
STRI/ETRI bracket family used for uniform array-value initialization (see
[SLRI](SLRI.md)/[ELRI](ELRI.md)/[ETRI](ETRI.md)), here applied to a
structure's terminals instead of an array's elements.

**Corrected this session, and a genuinely new finding underneath it.**
Re-compiling the confirming example (`DECLARE Z Q-STRUCTURE
INITIAL(5,4.3);`) with `HALSFC --parms="LISTING2,LSTALL"` and reading the
binary directly with `unHALMAT.py` shows **only one `TINT` instruction
in the real stream**, not two — the original "two TINT instances" reading
was `pass2.rpt` printing the *same* instruction twice (both copies
identically tagged at stream position `:0.13` in the text report, a
duplication artifact the original session had already flagged as
suspicious but couldn't resolve without a binary read). But the deeper
finding is what this reveals: `QI`'s value (`5`) is the *only* one
actually wired to a `TINT`. `QS`'s literal (`4.3`) **is** created in the
compiled literal table (confirmed via `unLitfile.py` — it's a real,
separate literal-table entry) but is never referenced by any HALMAT
instruction anywhere in the compiled program — `Z.QS` is not actually
initialized by this construct in this compiler build, at least as
tested. Whether this is a genuine compiler limitation (multi-value
structure `INITIAL` lists silently init only the first terminal), a
narrower rule in [USA003087] §19.6 not fully captured by this project's
reading of it, or a subtlety of this specific test case, is not yet
determined — flagged as a real open question below, not a minor
decoding detail. Multiple-copy structures (`Q-STRUCTURE(n)` with a full
or per-copy initial list, per [USA003087] §19.6) were not tested but are
expected to repeat the same STRI/TINT.../ETRI group once per copy, by
analogy with the array case.

## Operand-Word Format (confirmed empirically)

Two operands, following the same shape as [SINT](SINT.md)'s
OFFSET-addressed form: operand 1 = `DATA`=0, `QUAL`=A=OFF (the terminal's
position is implicit/sequential in emission order, not an explicit
index); operand 2 = `DATA`=literal-table index, `QUAL`=5=LIT (the
*first* coalesced terminal's initial value), with a trailing tag on this
operand giving the **coalesced run count** — how many consecutive
initial values (starting at this literal-table index) this one
instruction represents (see Usage Context/Unresolved Questions for the
`ICQ_OUTPUT` coalescing mechanism; observed `2` here since both
structure terminals coalesced into one instruction). A non-zero trailing
field (`6`) also appears on the TINT operator word itself, not yet
decoded. **Corrected this session**:
confirmed by compiling the example above with
`HALSFC --parms="LISTING2,LSTALL"` and reading the binary directly with
`unHALMAT.py` — there is exactly **one** TINT in the real stream (for
`QI`'s value), not two; see Usage Context for the report-duplication
artifact this corrects and the deeper anomaly (`QS`'s value never gets
its own TINT) it uncovered:

```
HALMAT: 001(2),0,0            <- EXTN, resolves Z
HALMAT: 801(1),0,0            <- STRI (opens the structure-initialize group)
HALMAT: 8E2(2),6,0            <- TINT: QI's initializer (the only one emitted)
          0(10),0,0              <- OFFSET-addressed (implicit position), QUAL=10=OFF
          3(5),2,0               <- literal-table index 3 (value 5), QUAL=5=LIT, tag=2
HALMAT: 804(0),0,0            <- ETRI (closes the group)
```

## Unresolved Questions

- ~~Why does `QS`'s literal never get referenced~~ **Resolved**: it does
  — via the same `TINT` as `QI`'s. Tracing `PASS1.PROCS/ICQOUTPU.xpl`'s
  `ICQ_OUTPUT` procedure (the general routine walking the "Initial
  Constant Queue" for *any* static-initialized item, structure or not)
  shows a **run-coalescing optimization**: consecutive initial-constant
  values are folded into a single `XINT`-family instruction (here,
  `TINT`) whenever two conditions both hold for the next queue entry —
  its literal-table pointer equals the previous entry's plus the running
  count (`IC_LOC(K) = CT_LITPTR + CT_LIT`), and its `OFF`-qualified
  "slot" value equals the previous entry's plus the running count
  (`IC_VAL(K) = CT_OFFPTR + CT_LIT`). When both hold, PASS1 skips
  emitting a second instruction and instead bumps the running count
  (`CT_LIT`), eventually writing it into the **already-emitted**
  instruction's literal operand via `HALMAT_FIX_PIPTAGS(NEXT_ATOM#-1,
  CT_LIT, 0)` — this is exactly the previously-undecoded trailing tag
  `2` on `TINT`'s literal operand in the worked trace below: it means
  "this one instruction covers **2** consecutive initial values," not
  merely a per-terminal type/precision flag. `QI`'s literal (index 3,
  value `5`) and `QS`'s literal (index 4, value `4.3`) are indeed
  sequential in the compiled literal table (confirmed via
  `unLitfile.py`), and their queue-slot positions are sequential too (0
  then 1), so the coalescing condition fires and only one `TINT` is
  emitted for both. PASS2/the static-data generator is expected to
  expand the single instruction back into two stored values at
  compile/link time using the base literal pointer plus the `TAG1` run
  count — not independently verified at the object-code level this
  session, but the triggering logic itself is now fully traced to
  primary source, not just inferred. This also retroactively explains
  [SINT](SINT.md)'s OFFSET-addressed-form note that "offset appears to
  be relative/sequential, implicit in emission order" — same mechanism,
  same `ICQ_OUTPUT` routine, applying uniformly across the whole
  `XINT`-family (`SINT`/`IINT`/`CINT`/`BINT`/`NINT`/`TINT`) since
  `ICQ_CHECK_TYPE` just dispatches which opcode to use per item type.
- The trailing `6` on the operator word itself is still not decoded at
  the bit level.
- Multiple-copy structures (`Q-STRUCTURE(n)`), structures initialized via
  a `CONSTANT` attribute rather than `INITIAL`, and nested/multi-level
  structure templates were not tested. A structure whose terminals'
  initial values do *not* coalesce (e.g. non-sequential literal
  placement, forced by an intervening declaration) would be a good
  follow-up test to directly observe two separate `TINT`s.

## Source Analysis & Reliability

Opcode (0xE2) confirmed primary-source: `XTINT BIT(16) INITIAL("8E2")` in
`PASS1.PROCS/##DRIVER.xpl` (grouped with [NINT](NINT.md)'s `XNINT` and
[EINT](EINT.md)'s `XEINT`) — see [##DRIVER.xpl] in `STATUS.md`. Found by
grepping the full `PASS.REL32V0` compiler source tree for every site
referencing `XTINT`, which led to `PASS1.PROCS/ICQCHECK.xpl`'s
`ICQ_CHECK_TYPE` procedure: `IF SYT_TYPE(ID_LOC)=MAJ_STRUC THEN RETURN
XTINT;` — directly identifying the "structure being initialized" case
among several dispatched by that procedure (`NAME`→[NINT](NINT.md),
`CHARACTER`/`BIT`/`EVENT`→[BINT](BINT.md) family,
`MATRIX`/`VECTOR`/`SCALAR`/`INTEGER`→the same family by type offset).
Statement syntax primary-sourced from [USA003087] §19.6 (PDF p. 8925 of
the `pdftotext -layout` extraction). Full behavioral description and
operand-word structure confirmed directly against real compiled HALMAT
in an earlier session, resolving a previously "Not started" opcode; the
instruction *count* (one TINT, not two) corrected in a later session via
a direct `unHALMAT.py` binary read plus a `unLitfile.py` literal-table
check. The resulting mystery (where did `QS`'s value go?) was then
resolved by tracing `PASS1.PROCS/ICQOUTPU.xpl`'s `ICQ_OUTPUT`
procedure directly — a genuine, primary-sourced compiler optimization
(consecutive-initial-value coalescing), not a gap or bug — see Usage
Context/Unresolved Questions above.
