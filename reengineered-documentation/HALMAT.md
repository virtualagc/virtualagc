# HALMAT

HALMAT is the binary intermediate language used internally by the HAL/S-FC
compiler for the HAL/S programming language. PASS1 (the parser) emits
HALMAT; OPT (the machine-independent optimizer) reads, transforms, and
re-emits it; PASS2 (the code generator) consumes optimized HALMAT and emits
AP-101S object code. There is no textual "source" form of HALMAT — it is a
binary stream of 32-bit words, organized into records and, within records,
into paragraphs corresponding to individual HAL/S source statements.

This documentation is a reverse-engineering effort. See `Plan.md` at the
repository root for the roadmap and editorial rules governing this material.

## Source Documents

References elsewhere in this documentation use the following abbreviations:

| Abbreviation | Document |
|---|---|
| [IR-60-5] | Document IR-60-5, "HAL/S-360 Compiler System Specification," Appendix A (1977). Primary source. The available copy is a partial reprint containing only pages revised from the prior edition — confirmed present are (at least) pages A-3 through A-8, A-93 through A-94, A-103 through A-104, A-109, and A-110 through A-118; other pages of Appendix A are not available. |
| [MSC-01847] | Document MSC-01847, "HALMAT: An Intermediate Language of the First HAL Compiler" (1971). Primary source, but describes the intermediate language for HAL/S's predecessor language, HAL, which differs from HAL/S HALMAT in some details. |
| [Halmat.pdf] | "HALMAT Instruction Set Reference" (2026), a secondary/speculative reconstruction produced by parsing the XPL source of the HAL/S-FC compiler (630 files, all seven passes) and cross-checking against disassembled regression-test binaries. Cited only where explicitly identified as speculation or analysis, not as primary-source material. |
| [GENCLASn] | HAL/S-FC compiler source files `GENCLAS0.xpl` through `GENCLAS8.xpl` (part of PASS2), which implement per-class code generation dispatch. Referenced via the virtualagc project's mirror of the HAL/S-FC source tree. |
| [USA00309] | Document USA00309, "HAL/S-FC User's Manual" (2005). Primary source. §8.2 ("Runtime Characteristics") and §6.1.2–6.1.3 ("Input/Output Data Formats") reviewed in full — the authoritative source for datatype precision representation and every pairwise BIT/CHARACTER/SCALAR/INTEGER conversion. |
| [USA003087] | Document USA003087, "HAL/S Programmer's Guide" (2005). Primary source, also covering datatype conversions (Appendix A) and I/O statement formatting (§12.2). Only §12.2 reviewed so far. |
| [CourseSlides.pdf] | "Basic HAL/S Programming Course" (undated), a slide-deck training document distinct in kind from the reference-manual sources above (informal, scanned-OCR text with layout artifacts). Primary source where cited — e.g. confirming [EINT](class-8/EINT.md)'s `EQUATE EXTERNAL`/ESD-entry-point purpose (pp. 486–487, "DATA CSECTS (CONTINUED)"). Only the page range directly cited per-instruction has been reviewed; see `STATUS.md`'s "Source material reviewed so far" table for extent and source URL. |

## Instruction Classes

HALMAT instructions fall into 9 classes, numbered 0 through 8, confirmed by
the class-dispatch structure of the compiler source files `GENCLAS0.xpl`
through `GENCLAS8.xpl`[^classes]. [IR-60-5] section A.2 provides a primary-source
index (mnemonic, opcode, and page number) for Class 0 and Class 8; no
primary-source index for Classes 1–7 has yet been located in the available
material.

| Class | Subject |
|---|---|
| 0 | Program structure and control flow |
| 1 | Bit operations |
| 2 | Character operations |
| 3 | Matrix arithmetic |
| 4 | Vector arithmetic |
| 5 | Scalar arithmetic |
| 6 | Integer arithmetic |
| 7 | Conditional and comparison operations |
| 8 | Initialization |

[^classes]: Class subjects for 1–8 per [Halmat.pdf]'s reconstruction from `GENCLASn.xpl`. Class 0 and Class 8 subjects are corroborated by the section headings in [IR-60-5] A.2 ("Class 8: Initialization"). The full 1–8 breakdown is further corroborated by [MSC-01847] (predecessor-language primary source): its own opcode space groups instructions by leading hex digit — 1xx=bit, 2xx=char, 3xx=matrix, 4xx=vector, 5xx=scalar, 6xx=integer, 7xx=conditional, 8xx=initialization — matching this table exactly. See `STATUS.md` for the full cross-language opcode comparison.

## Word Format

HALMAT operates on a sequence of 32-bit words. The low-order bit of a word
distinguishes an **operator word** (bit 0 = 0) from an **operand word**
(bit 0 = 1); an operator word is followed by however many operand words its
`NUMOP` field specifies.

### Operator Word (bit 0 = 0)

```
 31         24 23         16 15      12 11         4  3    1 0
+------------+------------+---------+------------+------+---+
|    TAG     |   NUMOP    |  CLASS  |   OPCODE   | COPT | 0 |
+------------+------------+---------+------------+------+---+
    8 bit         8 bit     4 bit       8 bit      3 bit  1 bit
```

- **TAG** — operator-specific tag field; meaning depends on the operator.
- **NUMOP** — number of operand words following this operator.
- **CLASS:OPCODE** — together, a 12-bit operation code, conventionally
  written as 3 hex digits. CLASS (the high 4 bits) selects the instruction
  class (0–8, see above); OPCODE (the low 8 bits) selects the specific
  operation within that class.
- **COPT** — a 3-bit field used by the optimizer pass; see "Optimizer
  HALMAT" below for its post-OPT meaning.

[IR-60-5] presents CLASS and OPCODE together as a single 12-bit field shown
in instruction diagrams as 3 hex digits (e.g. the field is drawn as `000`
for NOP, `002` for XREC). [Halmat.pdf] independently corroborates this
layout, splitting the same 12 bits into an explicit 4-bit CLASS and 8-bit
OPCODE.[^wordformat]

[^wordformat]: [IR-60-5] pp. A-6–A-8 (instruction diagrams for NOP, XREC, IMRK, SMRK, PXRC, MDEF, TDEF, PDEF, FDEF) and p. A-93 (DSUB diagram, showing the same operator-word layout). [Halmat.pdf] "Word Format" section corroborates the split of the 12-bit field into 4-bit CLASS / 8-bit OPCODE, and is the source for the field name "CLASS" (not used verbatim in the [IR-60-5] fragments available).

### Operand Word (bit 0 = 1)

```
 31              16 15       8 7      4 3    1 0
+-----------------+---------+--------+------+---+
|      DATA       |  TAG1   |  QUAL  | TAG2 | 1 |
+-----------------+---------+--------+------+---+
      16 bit          8 bit    4 bit   3 bit  1 bit
```

[IR-60-5] p. A-93 draws this same layout using the field names `operand`
(=DATA), `α` (=TAG1), `qual` (=QUAL), and `β` (=TAG2); those Greek-letter
names appear to be generic placeholders used specifically in the
subscripting (DSUB) discussion, rather than official field names. This
documentation uses DATA/TAG1/QUAL/TAG2, following [Halmat.pdf], since no
other primary-source name for the general-purpose operand-word fields has
been found.

- **DATA** — 16-bit operand value; interpretation depends on QUAL.
- **TAG1** — operand-specific tag (e.g., precision or data-type modifier).
- **QUAL** — 4-bit qualifier selecting the operand's type; see table below.
- **TAG2** — operand-specific tag.

#### Operand Qualifier (QUAL) Values

This table is primary-sourced from [IR-60-5] p. A-3.

| QUAL (hex) | Mnemonic | Meaning |
|---|---|---|
| 0 | — | Empty, or reserved for a special purpose |
| 1 | SYT (or SYL) | Symbol table pointer |
| 2 | GLI (or INL) | Internal flow number reference |
| 3 | VAC | "Virtual accumulator" — a back-pointer to the result of a previous HALMAT instruction |
| 4 | XPT | Extended pointer |
| 5 | LIT | Pointer into the literal table |
| 6 | IMD | An immediate numerical value |
| 7 | AST | Asterisk pointer |
| 8 | CSZ | Component size |
| 9 | ASZ | Array or copy size |
| A | OFF | Offset value |

**Empirically confirmed** (Phase 2): compiling test HAL/S programs with
`HALSFC --parms="LSTALL"` and reading the resulting `pass2.rpt` (see
`STATUS.md`'s "Compiler report switches" entry for the mechanism) shows
each operand printed as `DATA(QUAL),TAG1,TAG2` — directly matching this
field layout and, independently, [IR-60-5]'s primary-sourced QUAL table
below. E.g. an `SADD` (scalar add) instruction's two operands were printed
as `2(1),0,0` and `3(1),0,0` — `DATA`=2 and 3 being the symbol-table
indices of the two scalar operands, `QUAL`=1=SYT for both. The following
`SASN` (assign) instruction's second operand was printed as `67(3),0,0` —
`QUAL`=3=VAC, and `DATA`=67 was *literally the line-position of the SADD
instruction itself* within the compiled HALMAT stream (`SADD` was printed
tagged `:0.67`) — a direct, concrete confirmation of VAC's documented
semantics ("a back-pointer to the result of a previous HALMAT
instruction", by stream position). See `STATUS.md` for further examples
and the source test program.

[IR-60-5] also defines the following generic composite mnemonics, used
where a HALMAT operand may take any of several qualifier values:

| Mnemonic | May be any of |
|---|---|
| EXV | SYT, LIT, VAC, XPT |
| EEV | SYT, LIT, VAC, XPT, IMD |
| ESV | SYT, XPT |
| EVV | SYT, XPT, VAC |

## Block (Record) Structure

HALMAT is written to disk as a sequence of fixed-size **records** (also
called "blocks"), each 7200 bytes (1800 32-bit words) long.[^blocksize]
Within a record:

- **Word 0** is block metadata.
- **PXRC** is always the first HALMAT operator in a record; its operand
  points to the index of that record's closing `XREC`.
- HAL/S source statements are compiled into **paragraphs** of HALMAT
  instructions. As many whole paragraphs as possible are packed into each
  record; paragraphs are never split across records, so a record typically
  ends with an unused gap.
- Each paragraph ends with `SMRK` (statement marker), or with `IMRK`
  instead when the paragraph lies within an inline function block.
- **XREC** immediately follows the last paragraph in a record, marking its
  end. XREC's `TAG` field is 1 for the final record of a compilation and 0
  for every preceding record.

A compilation's HALMAT begins with a program-, task-, procedure-, or
function-definition header operator (`MDEF`, `TDEF`, `PDEF`, or `FDEF`) and
ends with a matching `CLOS` operator.

[^blocksize]: [IR-60-5] p. A-4 ("Both Phase I and Phase II of the HAL/S compiler use a disk file block size of 7200 bytes") and the "Layout of HALMAT Files" diagram on p. A-5. [Halmat.pdf] independently corroborates the 1800-word/7200-byte record size and PXRC/XREC bracketing.

## Optimizer HALMAT

The HALMAT produced by OPT (the optimizer) differs from PASS1's output:
several previously-reserved bit positions are given meaning, to convey
information PASS2 needs for code generation. Code generators not prepared
to handle these augmented formats are expected to disable optimization.[^optnote]

**First empirically confirmed this session** (previously sourced solely
from [IR-60-5], never independently compiled): `HALSFC`'s compile results
directory contains *both* `halmat.bin` (PASS1's pre-optimization output)
and `optmat.bin` (OPT's output, what PASS2 actually consumes) — reading
both with `unHALMAT.py` and diffing them directly shows exactly what OPT
changes. This is the first project session to compare the two files;
every earlier empirical trace in this project's history used only
`halmat.bin` (or `pass2.rpt`, which reflects `optmat.bin`'s content but
without printing the COPT field at all — see below), so this comparison
technique is a genuinely new verification tool worth reusing.

**COPT's pre-optimization meaning, traced to primary source**: PASS1
itself already writes non-zero values into the COPT bit position on
emission — not the CSE/Cross-Block/Cross-Loop semantics described below
(those don't exist yet), but one of two "text-optimizer tag" constants,
`XCO_N` (`"01"`) or `XCO_D` (`"02"`), declared in `PASS1.PROCS/##DRIVER.xpl`
and passed as the `TAG`-position argument to `HALMAT_POP`/`HALMAT_TUPLE`
at dozens of emission sites across PASS1 (e.g. `EMITSMRK.xpl`'s `CALL
HALMAT_POP(XSMRK,1,XCO_N,STATEMENT_SEVERITY)` — confirmed empirically:
every `SMRK` in `halmat.bin` carries COPT=1=`XCO_N`, matching exactly).
OPT's job includes clearing this placeholder value to 0 for instructions
where none of the three named bits below apply — confirmed by diffing a
control-flow-heavy test program's `halmat.bin` against its `optmat.bin`:
`SMRK`/`EDCL`/`CLBL`/`DFOR`/`DTST` (none of which produce a
VAC-referenced value) uniformly show COPT=1 pre-optimization and COPT=0
post-optimization.

- **Operator word** — of the 3 bits previously described as COPT, three are
  now individually named: **CSE** (result of this operator is referenced
  more than once; if this operator is XREC, indicates the next HALMAT
  record is a continuation of the current one, with possible cross-record
  references), **Cross Block** (result is referenced in the next HALMAT
  record — also used for subscript common expressions), and **Cross Loop**
  (inside an array loop, result is referenced from a different array loop).
  A separate TAG reuse applies to vector/matrix operations inside
  vector/matrix loops: TAG = 1 indicates the result is referenced outside
  the loop. **CSE bit empirically confirmed this session** (value `4` in
  `unHALMAT.py`'s field ordering — the first primary-source-independent
  confirmation of this bit's value/position): compiling
  `S3 = (X + Y) + (X + Y); S4 = X + Y;` shows OPT performing genuine
  **cross-statement** common-subexpression elimination — all three
  syntactic occurrences of `X + Y` (two within the first statement, one
  in the wholly separate second statement) collapse to a *single* `SADD`
  instruction in `optmat.bin`, referenced by VAC three times over (by the
  doubling addition, by the first statement's final assign... actually by
  the second `SADD` and by `S4`'s `SASN`). That one surviving `SADD`
  carries COPT=`4` post-optimization, versus COPT=0 for the ordinary,
  singly-referenced `SADD` immediately after it — direct confirmation
  that a nonzero COPT value flags a multiply-referenced result, matching
  CSE's documented meaning exactly. (Bit-position note: observed values
  so far are only `0`, `1`=`XCO_N` pre-optimization, and `4`
  post-optimization for a confirmed CSE case — consistent with CSE being
  the bit-2 sub-position of the 3-bit field, but Cross-Block/Cross-Loop's
  own bit positions remain unconfirmed pending a triggering test case.)
  **Cross Loop bit empirically confirmed in a later session**, extending
  the same technique to *array*-valued expressions: compiling
  `C = (A + B) + (A + B); I1 = 99; D = A + B;` (`A`/`B`/`C`/`D` all
  `ARRAY(5) SCALAR`, with the intervening scalar statement blocking loop
  fusion between the `C=` and `D=` array-valued statements — otherwise
  OPT fuses adjacent same-trip-count array loops into one, observed as a
  separate finding below) shows the shared `A + B` `SADD` — referenced
  *twice* inside its own array loop (`C`'s doubling addition, matching
  the CSE pattern above) *and once more* from the wholly separate `D=`
  array loop — carrying COPT=`5` (`4`+`1`), not just `4`. That extra `+1`
  over the pure-CSE value is the first independent confirmation of a
  *second* nonzero COPT bit, and its trigger condition (a same-loop reuse
  *plus* a reference from a genuinely different, unfused array loop)
  matches Cross Loop's documented meaning exactly — while the ordinary
  singly-referenced `SADD` immediately after it (inside the ordinary,
  unfused `D=` loop) carries COPT=`0` as expected. The referencing VAC
  operand *inside* `D=`'s loop (the genuinely cross-loop reference) shows
  no extra operand-level tag beyond the ordinary default — consistent
  with Cross Loop being purely an *operator*-word bit (unlike CSE, which
  also has an operand-word-level bit — see below). This also pins down
  the 3-bit field's ordering: CSE = bit 2 (value `4`), Cross Loop = bit 0
  (value `1`); Cross Block's own bit position (presumably bit 1, value
  `2`, by elimination) remains untriggered.
  **Loop fusion discovered as a related, distinct OPT behavior**: chaining
  two same-trip-count array-valued statements with a genuine data
  dependency and no intervening barrier (`S2 = S1 + 1; S3 = S2 + 1;`, both
  `ARRAY(5)`) causes OPT to merge their *separate* `ADLP`/`DLPE` loop
  brackets into a *single* combined loop — the second statement's `ADLP`
  and the first statement's `DLPE` both become `NOP`, and both statements'
  bodies execute per iteration inside the one surviving loop. This is why
  the Cross Loop test above needed a fusion-blocking intervening scalar
  statement: without it, the two array statements are fused into one loop
  and the shared subexpression becomes an ordinary same-loop CSE case
  (COPT=`4`) rather than a genuine Cross Loop case. Loop fusion does not
  always happen for adjacent same-trip-count array loops, though — a
  `DSUB` partition-copy loop (`S3 = S2(1 TO 3);`) immediately followed by
  an ordinary arithmetic loop of the same trip count (`S3 = S3 + 1;`) was
  *not* fused, suggesting fusion is restricted to structurally-similar
  loop bodies (or is blocked by the write-then-read dependency through a
  named symbol, unlike the register/VAC-mediated dependency in the fused
  case) — not yet fully characterized.
- **Operand word** — gains a **CSE** bit (1 if QUAL is VAC and the operator
  is referenced by inter-VAC operands), a **Cross Block** bit (1 if PTR
  refers to the previous HALMAT record), and a **MAT/VEC op** bit (1 if the
  operand, inside a vector/matrix loop, possesses vector/matrix arrayness).
  **CSE bit empirically confirmed this session**, same test as above: the
  VAC operand referencing the CSE-flagged `SADD` from *within* the same
  statement (the doubling addition's second `X + Y` reference) carries an
  extra nonzero tag not present on an ordinary VAC operand — consistent
  with this bit. The *cross-statement* reference (`S4`'s `SASN` reusing
  the same `SADD`) did not show the same extra tag, suggesting this
  operand-level bit specifically flags **same-record** (not cross-record)
  CSE reuse, complementing the Cross-Block bit's cross-record role — not
  fully isolated bit-by-bit, but the qualitative behavior (some VAC
  operands referencing a CSE'd result are tagged, others aren't,
  correlating with record locality) is confirmed.
- **Class 7 comparison operators** (`0x725` `BNEQ` through `0x7CA` `ILT`)
  gain two register-environment tag bits, T1 (1 if this is the only
  comparison operator in the statement) and T2 (1 if the register
  environment can be preserved to the next comparison operator).
  **T1 empirically confirmed this session**: comparing `halmat.bin` vs.
  `optmat.bin` for `DO WHILE I1 > 0; ... END;` (a single, standalone
  comparison per statement) shows the comparison operator's own `TAG`
  byte going from `0` pre-optimization to `1` post-optimization —
  matching T1's documented meaning exactly, since each tested comparison
  genuinely is the sole comparison in its statement.
  **T2 empirically confirmed in a later session**: compiling
  `IF I1 > 0 AND I2 > 0 THEN ...` (`I1`/`I2` `INTEGER`, a `CAND` of two
  `IGT` comparisons) shows *both* `IGT` operators' `TAG` byte going from
  `0` pre-optimization to `2` post-optimization — not `1` (T1), since
  neither is the sole comparison in the statement, and not `3` (both
  bits), confirming T2 occupies bit position 1 (value `2`), distinct from
  T1's bit position 0 (value `1`). Both comparisons in the chain carry
  T2=1 here (not just the first), which is compatible with the documented
  "register environment can be preserved to the next comparison operator"
  meaning read as a chain-membership flag rather than strictly "has a
  following comparison" — the exact operational distinction (why the
  *last* comparison in the chain, with no comparison after it, still sets
  T2) is not fully pinned down.
- **SINCOS** — the `BFNC` (0x04A) operator, when its TAG field is `0x39` or
  `0x3A`, represents a combined sine/cosine computation: VACs point to the
  operator word for one of {SIN, COS} and the operand word for the other,
  with TAG selecting which is which. **Empirically confirmed in a later
  session**: compiling `S1 = SIN(X); C1 = COS(X);` (`X`/`S1`/`C1` all
  `SCALAR`) shows OPT collapsing the separate pre-optimization `SIN`
  (`BFNC` TAG=`0x0D`) and `COS` (`BFNC` TAG=`0x02`) calls into a single
  post-optimization `BFNC` with TAG=`0x39`, out of `unHALMAT.py`'s
  `bfncTypes` table range (confirming this is genuinely a SINCOS-specific
  tag value, not an ordinary built-in-function code) — matching the
  documented `0x39`/`0x3A` values exactly. The original second `BFNC`
  (`COS`) becomes a `NOP`. `S1`'s `SASN` (statement 3, `SIN`, compiled
  first) references the *operator* word (the combined `BFNC` itself);
  `C1`'s `SASN` (statement 4, `COS`) references what was the *operand*
  word (`X`'s symbol reference, repurposed as the second result's VAC
  target) — confirming the documented "operator word for one of
  {SIN, COS}, operand word for the other" split, with TAG=`0x39`
  specifically meaning "operator word = SIN, operand word = COS" (the
  `0x3A` case, presumably the reverse assignment, was not triggered by
  this test's statement order). The combined operator's own COPT value
  is `4` (the CSE bit — its result is referenced twice, once per
  original function call), reinforcing that SINCOS is implemented as a
  form of common-subexpression sharing between the two trig calls rather
  than a wholly separate mechanism.
- **Subscript common expressions** — `DSUB` may gain a final operand
  (α=5, β=1) giving a quantity to be added to the subscript computation
  before type/alignment shifting.
- **Integer product** — the Integer-Integer-Product operator's opcode
  changes to `0x6CD` (mnemonic likely `IIPR`, per [Halmat.pdf]), with TAG=1
  if the optimizer generated it as part of a subscript computation.
- **Inline vector/matrix loops** — `ADLP` (0x017) and `DLPE` (0x018), which
  bracket array-processing loops, gain arrayness-specifier and CSE bits
  when the loop involves vector/matrix arrayness. This applies to operator
  pairs `MASN`/`VASN`/`IASN`, `MNEG`/`VNEG`, `MADD`/`VADD`, `MSUB`/`VSUB`,
  `MSPR`/`VSPR`, and `MSDV`/`VSDV` — presumably Class 3 (matrix) and Class 4
  (vector) assign/negate/add/subtract/scalar-product/scalar-divide
  operators, though their opcodes have not yet been confirmed against
  primary source.

[^optnote]: [IR-60-5] pp. A-110–A-113 (sections A.3.1 through A.3.6). CSE
    (operator- and operand-word), Class 7 T1, Class 7 T2, Cross Loop, and
    SINCOS all empirically confirmed against real compiled HALMAT
    (`halmat.bin` vs. `optmat.bin` diffing), across two sessions — see the
    confirmations inline above. Remaining bullets (Cross Block, MAT/VEC op,
    subscript common expressions, integer-product subscript TAG, inline
    vector/matrix loop bits) remain [IR-60-5]-only, not yet independently
    triggered.

## Auxiliary HALMAT (AUXMAT)

AUXMAT is a companion binary stream, distinct from HALMAT itself, produced
by a compiler phase called AUXMATER that runs between OPT and PASS2. It
conveys machine-independent information (such as "next use" data for HAL
variables and VACs) useful for machine-dependent optimizations during code
generation. AUXMAT consists of 32-bit AUXRATOR/AUXRAND pairs, structurally
parallel to HALMAT's operator/operand words, and is synchronized to HALMAT
record boundaries via matching XREC-synchronization pairs rather than being
divided into paragraphs itself. Because AUXMAT is not part of the HALMAT
instruction stream proper, it is not documented instruction-by-instruction
here; see [IR-60-5] pp. A-114–A-118 for the full specification.[^auxmat]

[^auxmat]: [IR-60-5] section A.4, "Auxiliary HALMAT."

## Instructions

See `STATUS.md` for the current documentation-progress tracker across all
9 classes.

Instruction files that exist so far, indexed three ways:

### By Class, then Mnemonic

**Class 0:**

- [ADLP](class-0/ADLP.md) — 0x017 — Arrayness specifier, brackets array loops
- [AFOR](class-0/AFOR.md) — 0x015 — Per-value instruction for list-form DO FOR
- [BFNC](class-0/BFNC.md) — 0x04A — Built-in function call (e.g. PRIO, SINCOS)
- [BRA](class-0/BRA.md) — 0x009 — Unconditional branch
- [CANC](class-0/CANC.md) — 0x036 — CANCEL statement, self or named process
- [CDEF](class-0/CDEF.md) — 0x02F — Compool definition header
- [CFOR](class-0/CFOR.md) — 0x012 — DO FOR supplementary WHILE/UNTIL condition test
- [CLBL](class-0/CLBL.md) — 0x00D — Computed-branch (DO CASE) destination label
- [CLOS](class-0/CLOS.md) — 0x030 — CLOSE statement, closes a program/procedure/function/task
- [CTST](class-0/CTST.md) — 0x016 — DO WHILE/UNTIL per-cycle condition test
- [DCAS](class-0/DCAS.md) — 0x00B — DO CASE statement header, computed branch
- [DFOR](class-0/DFOR.md) — 0x010 — DO FOR statement header
- [DLPE](class-0/DLPE.md) — 0x018 — End of array/structure specification
- [DSMP](class-0/DSMP.md) — 0x013 — Plain DO; ... END; group header
- [DSUB](class-0/DSUB.md) — 0x019 — Array/component subscript specifier
- [DTST](class-0/DTST.md) — 0x00E — DO WHILE/UNTIL loop header
- [ECAS](class-0/ECAS.md) — 0x00C — DO CASE statement end / join point
- [EDCL](class-0/EDCL.md) — 0x031 — End-of-declarations marker
- [EFOR](class-0/EFOR.md) — 0x011 — DO FOR statement end
- [ERON](class-0/ERON.md) — 0x03C — ON ERROR / OFF ERROR statement (all forms)
- [ERSE](class-0/ERSE.md) — 0x03D — SEND ERROR statement (error simulation/signaling)
- [ESMP](class-0/ESMP.md) — 0x014 — Plain DO; ... END; group end
- [ETST](class-0/ETST.md) — 0x00F — DO WHILE/UNTIL loop end
- [EXTN](class-0/EXTN.md) — 0x001 — Extended (qualified-name) pointer
- [FBRA](class-0/FBRA.md) — 0x00A — Conditional (false) branch
- [FCAL](class-0/FCAL.md) — 0x01E — Function call header
- [FDEF](class-0/FDEF.md) — 0x02C — Function definition header
- [FILE](class-0/FILE.md) — 0x022 — File I/O specifier
- [ICLS](class-0/ICLS.md) — 0x052 — Inline function close
- [IDEF](class-0/IDEF.md) — 0x051 — Inline function definition header
- [IDLP](class-0/IDLP.md) — 0x01A — STATIC-array counterpart of ADLP (uniform-value init)
- [IFHD](class-0/IFHD.md) — 0x007 — IF statement header
- [IMRK](class-0/IMRK.md) — 0x003 — Inline-function statement marker
- [ISHP](class-0/ISHP.md) — 0x043 — List-form INTEGER(...) shaping function
- [LBL](class-0/LBL.md) — 0x008 — Branch destination label
- [LFNC](class-0/LFNC.md) — 0x04B — MAX/MIN built-in functions ("L-FUNC" category)
- [MDEF](class-0/MDEF.md) — 0x02B — Program definition header
- [MSHP](class-0/MSHP.md) — 0x040 — MATRIX(...) shaping function
- [NASN](class-0/NASN.md) — 0x057 — NAME (pointer) assign
- [NEQU](class-0/NEQU.md) — 0x056 — NAME (pointer) equal comparison
- [NNEQ](class-0/NNEQ.md) — 0x055 — NAME (pointer) not-equal comparison
- [NOP](class-0/NOP.md) — 0x000 — No operation
- [PCAL](class-0/PCAL.md) — 0x01D — Procedure call header
- [PDEF](class-0/PDEF.md) — 0x02D — Procedure definition header
- [PMAR](class-0/PMAR.md) — 0x05A — %macro invocation argument
- [PMHD](class-0/PMHD.md) — 0x059 — %macro invocation header
- [PMIN](class-0/PMIN.md) — 0x05B — %macro invocation end
- [PRIO](class-0/PRIO.md) — 0x038 — UPDATE PRIORITY statement
- [PXRC](class-0/PXRC.md) — 0x005 — Record header, points to closing XREC
- [RDAL](class-0/RDAL.md) — 0x020 — READALL statement header
- [READ](class-0/READ.md) — 0x01F — READ statement header
- [RTRN](class-0/RTRN.md) — 0x032 — Subprogram return
- [SCHD](class-0/SCHD.md) — 0x039 — SCHEDULE statement
- [SFAR](class-0/SFAR.md) — 0x047 — Shaping-function argument separator
- [SFND](class-0/SFND.md) — 0x046 — End of shaping-function specification
- [SFST](class-0/SFST.md) — 0x045 — Start of shaping-function specification
- [SGNL](class-0/SGNL.md) — 0x035 — SIGNAL statement
- [SMRK](class-0/SMRK.md) — 0x004 — Statement marker
- [SSHP](class-0/SSHP.md) — 0x042 — List-form SCALAR(...) shaping function
- [TASN](class-0/TASN.md) — 0x04F — Structure assign
- [TDCL](class-0/TDCL.md) — 0x033 — TEMPORARY data-item declaration
- [TDEF](class-0/TDEF.md) — 0x02A — Task definition header
- [TEQU](class-0/TEQU.md) — 0x04E — Structure equal comparison
- [TERM](class-0/TERM.md) — 0x037 — Terminate program execution
- [TNEQ](class-0/TNEQ.md) — 0x04D — Structure not-equal comparison
- [TSUB](class-0/TSUB.md) — 0x01B — Structure (copy) subscript specifier
- [UDEF](class-0/UDEF.md) — 0x02E — Update block header
- [VSHP](class-0/VSHP.md) — 0x041 — VECTOR(...) shaping function
- [WAIT](class-0/WAIT.md) — 0x034 — WAIT statement (interval/UNTIL/FOR DEPENDENT)
- [WRIT](class-0/WRIT.md) — 0x021 — WRITE statement header
- [XREC](class-0/XREC.md) — 0x002 — End-of-record marker
- [XXAR](class-0/XXAR.md) — 0x027 — I/O statement argument
- [XXND](class-0/XXND.md) — 0x026 — I/O statement end
- [XXST](class-0/XXST.md) — 0x025 — I/O statement start, carries I/O-kind code

**Class 1:**

- [BAND](class-1/BAND.md) — 0x102 — Bit-string AND
- [BASN](class-1/BASN.md) — 0x101 — Bit-string assign
- [BCAT](class-1/BCAT.md) — 0x105 — Bit-string catenate
- [BNOT](class-1/BNOT.md) — 0x104 — Bit-string complement
- [BOR](class-1/BOR.md) — 0x103 — Bit-string OR
- [BTOB](class-1/BTOB.md) — 0x121 — Bit-string length conversion
- [BTOQ](class-1/BTOQ.md) — 0x122 — SUBBIT pseudo-conversion, bit-string argument
- [CTOB](class-1/CTOB.md) — 0x141 — Character to bit conversion
- [CTOQ](class-1/CTOQ.md) — 0x142 — SUBBIT pseudo-conversion, character argument
- [ITOB](class-1/ITOB.md) — 0x1C1 — Integer to bit conversion
- [ITOQ](class-1/ITOQ.md) — 0x1C2 — SUBBIT pseudo-conversion, integer argument
- [STOB](class-1/STOB.md) — 0x1A1 — Scalar to bit conversion
- [STOQ](class-1/STOQ.md) — 0x1A2 — SUBBIT pseudo-conversion, scalar argument

**Class 2:**

- [BTOC](class-2/BTOC.md) — 0x221 — Bit to character conversion
- [CASN](class-2/CASN.md) — 0x201 — Character assign
- [CCAT](class-2/CCAT.md) — 0x202 — Character catenate
- [CTOC](class-2/CTOC.md) — 0x241 — Character-length conversion
- [ITOC](class-2/ITOC.md) — 0x2C1 — Integer to character conversion
- [STOC](class-2/STOC.md) — 0x2A1 — Scalar to character conversion

**Class 3:**

- [MADD](class-3/MADD.md) — 0x362 — Matrix add
- [MASN](class-3/MASN.md) — 0x301 — Matrix assign
- [MINV](class-3/MINV.md) — 0x3CA — Matrix invert
- [MMPR](class-3/MMPR.md) — 0x368 — Matrix-matrix product
- [MNEG](class-3/MNEG.md) — 0x344 — Matrix negate
- [MSDV](class-3/MSDV.md) — 0x3A6 — Matrix divide by scalar
- [MSPR](class-3/MSPR.md) — 0x3A5 — Matrix multiply by scalar
- [MSUB](class-3/MSUB.md) — 0x363 — Matrix subtract
- [MTOM](class-3/MTOM.md) — 0x341 — Matrix precision scale
- [MTRA](class-3/MTRA.md) — 0x329 — Matrix transpose
- [VVPR](class-3/VVPR.md) — 0x387 — Vector outer product, matrix result

**Class 4:**

- [MVPR](class-4/MVPR.md) — 0x46C — Matrix-vector product
- [VADD](class-4/VADD.md) — 0x482 — Vector add
- [VASN](class-4/VASN.md) — 0x401 — Vector assign
- [VCRS](class-4/VCRS.md) — 0x48B — Vector cross product
- [VMPR](class-4/VMPR.md) — 0x46D — Vector-matrix product
- [VNEG](class-4/VNEG.md) — 0x444 — Vector negate
- [VSDV](class-4/VSDV.md) — 0x4A6 — Vector divide by scalar
- [VSPR](class-4/VSPR.md) — 0x4A5 — Vector multiply by scalar
- [VSUB](class-4/VSUB.md) — 0x483 — Vector subtract
- [VTOV](class-4/VTOV.md) — 0x441 — Vector precision scale

**Class 5:**

- [BTOS](class-5/BTOS.md) — 0x521 — Bit string to scalar conversion
- [CTOS](class-5/CTOS.md) — 0x541 — Character to scalar conversion
- [ITOS](class-5/ITOS.md) — 0x5C1 — Integer to scalar conversion
- [SADD](class-5/SADD.md) — 0x5AB — Scalar add
- [SASN](class-5/SASN.md) — 0x501 — Scalar assign
- [SEXP](class-5/SEXP.md) — 0x5AF — Scalar exponentiation by scalar
- [SIEX](class-5/SIEX.md) — 0x571 — Scalar exponentiation by integer
- [SNEG](class-5/SNEG.md) — 0x5B0 — Scalar negate
- [SPEX](class-5/SPEX.md) — 0x572 — Scalar exponentiation by positive integer
- [SSDV](class-5/SSDV.md) — 0x5AE — Scalar divide
- [SSPR](class-5/SSPR.md) — 0x5AD — Scalar multiply
- [SSUB](class-5/SSUB.md) — 0x5AC — Scalar subtract
- [STOS](class-5/STOS.md) — 0x5A1 — Scalar precision scale
- [VDOT](class-5/VDOT.md) — 0x58E — Vector dot product, scalar result

**Class 6:**

- [BTOI](class-6/BTOI.md) — 0x621 — Bit to integer conversion
- [CTOI](class-6/CTOI.md) — 0x641 — Character to integer conversion
- [IADD](class-6/IADD.md) — 0x6CB — Integer add
- [IASN](class-6/IASN.md) — 0x601 — Integer assign
- [IIPR](class-6/IIPR.md) — 0x6CD — Integer multiply
- [INEG](class-6/INEG.md) — 0x6D0 — Integer negate
- [IPEX](class-6/IPEX.md) — 0x6D2 — Integer exponentiation by positive integer
- [ISUB](class-6/ISUB.md) — 0x6CC — Integer subtract
- [ITOI](class-6/ITOI.md) — 0x6C1 — Integer precision scale
- [STOI](class-6/STOI.md) — 0x6A1 — Scalar to integer conversion

**Class 7:**

- [BEQU](class-7/BEQU.md) — 0x726 — Bit string equal
- [BNEQ](class-7/BNEQ.md) — 0x725 — Bit string not equal
- [BTRU](class-7/BTRU.md) — 0x720 — Bit-is-true test (conditional context)
- [CAND](class-7/CAND.md) — 0x7E2 — Logical AND
- [CEQU](class-7/CEQU.md) — 0x746 — Character equal
- [CGT](class-7/CGT.md) — 0x748 — Character greater than
- [CLT](class-7/CLT.md) — 0x74A — Character less than
- [CNEQ](class-7/CNEQ.md) — 0x745 — Character not equal
- [CNGT](class-7/CNGT.md) — 0x747 — Character not greater than
- [CNLT](class-7/CNLT.md) — 0x749 — Character not less than
- [CNOT](class-7/CNOT.md) — 0x7E4 — Logical NOT
- [COR](class-7/COR.md) — 0x7E3 — Logical OR
- [IEQU](class-7/IEQU.md) — 0x7C6 — Integer equal
- [IGT](class-7/IGT.md) — 0x7C8 — Integer greater than
- [ILT](class-7/ILT.md) — 0x7CA — Integer less than
- [INEQ](class-7/INEQ.md) — 0x7C5 — Integer not equal
- [INGT](class-7/INGT.md) — 0x7C7 — Integer not greater than
- [INLT](class-7/INLT.md) — 0x7C9 — Integer not less than
- [MEQU](class-7/MEQU.md) — 0x766 — Matrix equal
- [MNEQ](class-7/MNEQ.md) — 0x765 — Matrix not equal
- [SEQU](class-7/SEQU.md) — 0x7A6 — Scalar equal
- [SGT](class-7/SGT.md) — 0x7A8 — Scalar greater than
- [SLT](class-7/SLT.md) — 0x7AA — Scalar less than
- [SNEQ](class-7/SNEQ.md) — 0x7A5 — Scalar not equal
- [SNGT](class-7/SNGT.md) — 0x7A7 — Scalar not greater than
- [SNLT](class-7/SNLT.md) — 0x7A9 — Scalar not less than
- [VEQU](class-7/VEQU.md) — 0x786 — Vector equal
- [VNEQ](class-7/VNEQ.md) — 0x785 — Vector not equal

**Class 8:**

- [BINT](class-8/BINT.md) — 0x21 — Bit-string initialize
- [CINT](class-8/CINT.md) — 0x41 — Character initialize
- [EINT](class-8/EINT.md) — 0xE3 — EQUATE EXTERNAL statement
- [ELRI](class-8/ELRI.md) — 0x03 — End (one unit of a) repeated-initialize loop
- [ETRI](class-8/ETRI.md) — 0x04 — End repeated-initialize loop
- [IINT](class-8/IINT.md) — 0xC1 — Integer initialize
- [MINT](class-8/MINT.md) — 0x61 — Matrix initialize
- [NINT](class-8/NINT.md) — 0xE1 — NAME (pointer) initialize
- [SINT](class-8/SINT.md) — 0xA1 — Scalar initialize
- [SLRI](class-8/SLRI.md) — 0x02 — Start repeated-initialize loop
- [STRI](class-8/STRI.md) — 0x01 — Repeated-initialize specifier
- [TINT](class-8/TINT.md) — 0xE2 — Structure-terminal initialize
- [VINT](class-8/VINT.md) — 0x81 — Vector initialize

### By Mnemonic (alphabetical)

- [ADLP](class-0/ADLP.md) (class 0, 0x017) — Arrayness specifier, brackets array loops
- [AFOR](class-0/AFOR.md) (class 0, 0x015) — Per-value instruction for list-form DO FOR
- [BAND](class-1/BAND.md) (class 1, 0x102) — Bit-string AND
- [BASN](class-1/BASN.md) (class 1, 0x101) — Bit-string assign
- [BCAT](class-1/BCAT.md) (class 1, 0x105) — Bit-string catenate
- [BEQU](class-7/BEQU.md) (class 7, 0x726) — Bit string equal
- [BFNC](class-0/BFNC.md) (class 0, 0x04A) — Built-in function call (e.g. PRIO, SINCOS)
- [BINT](class-8/BINT.md) (class 8, 0x21) — Bit-string initialize
- [BNEQ](class-7/BNEQ.md) (class 7, 0x725) — Bit string not equal
- [BNOT](class-1/BNOT.md) (class 1, 0x104) — Bit-string complement
- [BOR](class-1/BOR.md) (class 1, 0x103) — Bit-string OR
- [BRA](class-0/BRA.md) (class 0, 0x009) — Unconditional branch
- [BTOB](class-1/BTOB.md) (class 1, 0x121) — Bit-string length conversion
- [BTOC](class-2/BTOC.md) (class 2, 0x221) — Bit to character conversion
- [BTOI](class-6/BTOI.md) (class 6, 0x621) — Bit to integer conversion
- [BTOQ](class-1/BTOQ.md) (class 1, 0x122) — SUBBIT pseudo-conversion, bit-string argument
- [BTOS](class-5/BTOS.md) (class 5, 0x521) — Bit string to scalar conversion
- [BTRU](class-7/BTRU.md) (class 7, 0x720) — Bit-is-true test (conditional context)
- [CANC](class-0/CANC.md) (class 0, 0x036) — CANCEL statement, self or named process
- [CAND](class-7/CAND.md) (class 7, 0x7E2) — Logical AND
- [CASN](class-2/CASN.md) (class 2, 0x201) — Character assign
- [CCAT](class-2/CCAT.md) (class 2, 0x202) — Character catenate
- [CDEF](class-0/CDEF.md) (class 0, 0x02F) — Compool definition header
- [CEQU](class-7/CEQU.md) (class 7, 0x746) — Character equal
- [CFOR](class-0/CFOR.md) (class 0, 0x012) — DO FOR supplementary WHILE/UNTIL condition test
- [CGT](class-7/CGT.md) (class 7, 0x748) — Character greater than
- [CINT](class-8/CINT.md) (class 8, 0x41) — Character initialize
- [CLBL](class-0/CLBL.md) (class 0, 0x00D) — Computed-branch (DO CASE) destination label
- [CLOS](class-0/CLOS.md) (class 0, 0x030) — CLOSE statement, closes a program/procedure/function/task
- [CLT](class-7/CLT.md) (class 7, 0x74A) — Character less than
- [CNEQ](class-7/CNEQ.md) (class 7, 0x745) — Character not equal
- [CNGT](class-7/CNGT.md) (class 7, 0x747) — Character not greater than
- [CNLT](class-7/CNLT.md) (class 7, 0x749) — Character not less than
- [CNOT](class-7/CNOT.md) (class 7, 0x7E4) — Logical NOT
- [COR](class-7/COR.md) (class 7, 0x7E3) — Logical OR
- [CTOB](class-1/CTOB.md) (class 1, 0x141) — Character to bit conversion
- [CTOC](class-2/CTOC.md) (class 2, 0x241) — Character-length conversion
- [CTOI](class-6/CTOI.md) (class 6, 0x641) — Character to integer conversion
- [CTOQ](class-1/CTOQ.md) (class 1, 0x142) — SUBBIT pseudo-conversion, character argument
- [CTOS](class-5/CTOS.md) (class 5, 0x541) — Character to scalar conversion
- [CTST](class-0/CTST.md) (class 0, 0x016) — DO WHILE/UNTIL per-cycle condition test
- [DCAS](class-0/DCAS.md) (class 0, 0x00B) — DO CASE statement header, computed branch
- [DFOR](class-0/DFOR.md) (class 0, 0x010) — DO FOR statement header
- [DLPE](class-0/DLPE.md) (class 0, 0x018) — End of array/structure specification
- [DSMP](class-0/DSMP.md) (class 0, 0x013) — Plain DO; ... END; group header
- [DSUB](class-0/DSUB.md) (class 0, 0x019) — Array/component subscript specifier
- [DTST](class-0/DTST.md) (class 0, 0x00E) — DO WHILE/UNTIL loop header
- [ECAS](class-0/ECAS.md) (class 0, 0x00C) — DO CASE statement end / join point
- [EDCL](class-0/EDCL.md) (class 0, 0x031) — End-of-declarations marker
- [EFOR](class-0/EFOR.md) (class 0, 0x011) — DO FOR statement end
- [EINT](class-8/EINT.md) (class 8, 0xE3) — EQUATE EXTERNAL statement
- [ELRI](class-8/ELRI.md) (class 8, 0x03) — End (one unit of a) repeated-initialize loop
- [ERON](class-0/ERON.md) (class 0, 0x03C) — ON ERROR / OFF ERROR statement (all forms)
- [ERSE](class-0/ERSE.md) (class 0, 0x03D) — SEND ERROR statement (error simulation/signaling)
- [ESMP](class-0/ESMP.md) (class 0, 0x014) — Plain DO; ... END; group end
- [ETRI](class-8/ETRI.md) (class 8, 0x04) — End repeated-initialize loop
- [ETST](class-0/ETST.md) (class 0, 0x00F) — DO WHILE/UNTIL loop end
- [EXTN](class-0/EXTN.md) (class 0, 0x001) — Extended (qualified-name) pointer
- [FBRA](class-0/FBRA.md) (class 0, 0x00A) — Conditional (false) branch
- [FCAL](class-0/FCAL.md) (class 0, 0x01E) — Function call header
- [FDEF](class-0/FDEF.md) (class 0, 0x02C) — Function definition header
- [FILE](class-0/FILE.md) (class 0, 0x022) — File I/O specifier
- [IADD](class-6/IADD.md) (class 6, 0x6CB) — Integer add
- [IASN](class-6/IASN.md) (class 6, 0x601) — Integer assign
- [ICLS](class-0/ICLS.md) (class 0, 0x052) — Inline function close
- [IDEF](class-0/IDEF.md) (class 0, 0x051) — Inline function definition header
- [IDLP](class-0/IDLP.md) (class 0, 0x01A) — STATIC-array counterpart of ADLP (uniform-value init)
- [IEQU](class-7/IEQU.md) (class 7, 0x7C6) — Integer equal
- [IFHD](class-0/IFHD.md) (class 0, 0x007) — IF statement header
- [IGT](class-7/IGT.md) (class 7, 0x7C8) — Integer greater than
- [IINT](class-8/IINT.md) (class 8, 0xC1) — Integer initialize
- [IIPR](class-6/IIPR.md) (class 6, 0x6CD) — Integer multiply
- [ILT](class-7/ILT.md) (class 7, 0x7CA) — Integer less than
- [IMRK](class-0/IMRK.md) (class 0, 0x003) — Inline-function statement marker
- [INEG](class-6/INEG.md) (class 6, 0x6D0) — Integer negate
- [INEQ](class-7/INEQ.md) (class 7, 0x7C5) — Integer not equal
- [INGT](class-7/INGT.md) (class 7, 0x7C7) — Integer not greater than
- [INLT](class-7/INLT.md) (class 7, 0x7C9) — Integer not less than
- [IPEX](class-6/IPEX.md) (class 6, 0x6D2) — Integer exponentiation by positive integer
- [ISHP](class-0/ISHP.md) (class 0, 0x043) — List-form INTEGER(...) shaping function
- [ISUB](class-6/ISUB.md) (class 6, 0x6CC) — Integer subtract
- [ITOB](class-1/ITOB.md) (class 1, 0x1C1) — Integer to bit conversion
- [ITOC](class-2/ITOC.md) (class 2, 0x2C1) — Integer to character conversion
- [ITOI](class-6/ITOI.md) (class 6, 0x6C1) — Integer precision scale
- [ITOQ](class-1/ITOQ.md) (class 1, 0x1C2) — SUBBIT pseudo-conversion, integer argument
- [ITOS](class-5/ITOS.md) (class 5, 0x5C1) — Integer to scalar conversion
- [LBL](class-0/LBL.md) (class 0, 0x008) — Branch destination label
- [LFNC](class-0/LFNC.md) (class 0, 0x04B) — MAX/MIN built-in functions ("L-FUNC" category)
- [MADD](class-3/MADD.md) (class 3, 0x362) — Matrix add
- [MASN](class-3/MASN.md) (class 3, 0x301) — Matrix assign
- [MDEF](class-0/MDEF.md) (class 0, 0x02B) — Program definition header
- [MEQU](class-7/MEQU.md) (class 7, 0x766) — Matrix equal
- [MINT](class-8/MINT.md) (class 8, 0x61) — Matrix initialize
- [MINV](class-3/MINV.md) (class 3, 0x3CA) — Matrix invert
- [MMPR](class-3/MMPR.md) (class 3, 0x368) — Matrix-matrix product
- [MNEG](class-3/MNEG.md) (class 3, 0x344) — Matrix negate
- [MNEQ](class-7/MNEQ.md) (class 7, 0x765) — Matrix not equal
- [MSDV](class-3/MSDV.md) (class 3, 0x3A6) — Matrix divide by scalar
- [MSHP](class-0/MSHP.md) (class 0, 0x040) — MATRIX(...) shaping function
- [MSPR](class-3/MSPR.md) (class 3, 0x3A5) — Matrix multiply by scalar
- [MSUB](class-3/MSUB.md) (class 3, 0x363) — Matrix subtract
- [MTOM](class-3/MTOM.md) (class 3, 0x341) — Matrix precision scale
- [MTRA](class-3/MTRA.md) (class 3, 0x329) — Matrix transpose
- [MVPR](class-4/MVPR.md) (class 4, 0x46C) — Matrix-vector product
- [NASN](class-0/NASN.md) (class 0, 0x057) — NAME (pointer) assign
- [NEQU](class-0/NEQU.md) (class 0, 0x056) — NAME (pointer) equal comparison
- [NINT](class-8/NINT.md) (class 8, 0xE1) — NAME (pointer) initialize
- [NNEQ](class-0/NNEQ.md) (class 0, 0x055) — NAME (pointer) not-equal comparison
- [NOP](class-0/NOP.md) (class 0, 0x000) — No operation
- [PCAL](class-0/PCAL.md) (class 0, 0x01D) — Procedure call header
- [PDEF](class-0/PDEF.md) (class 0, 0x02D) — Procedure definition header
- [PMAR](class-0/PMAR.md) (class 0, 0x05A) — %macro invocation argument
- [PMHD](class-0/PMHD.md) (class 0, 0x059) — %macro invocation header
- [PMIN](class-0/PMIN.md) (class 0, 0x05B) — %macro invocation end
- [PRIO](class-0/PRIO.md) (class 0, 0x038) — UPDATE PRIORITY statement
- [PXRC](class-0/PXRC.md) (class 0, 0x005) — Record header, points to closing XREC
- [RDAL](class-0/RDAL.md) (class 0, 0x020) — READALL statement header
- [READ](class-0/READ.md) (class 0, 0x01F) — READ statement header
- [RTRN](class-0/RTRN.md) (class 0, 0x032) — Subprogram return
- [SADD](class-5/SADD.md) (class 5, 0x5AB) — Scalar add
- [SASN](class-5/SASN.md) (class 5, 0x501) — Scalar assign
- [SCHD](class-0/SCHD.md) (class 0, 0x039) — SCHEDULE statement
- [SEQU](class-7/SEQU.md) (class 7, 0x7A6) — Scalar equal
- [SEXP](class-5/SEXP.md) (class 5, 0x5AF) — Scalar exponentiation by scalar
- [SFAR](class-0/SFAR.md) (class 0, 0x047) — Shaping-function argument separator
- [SFND](class-0/SFND.md) (class 0, 0x046) — End of shaping-function specification
- [SFST](class-0/SFST.md) (class 0, 0x045) — Start of shaping-function specification
- [SGNL](class-0/SGNL.md) (class 0, 0x035) — SIGNAL statement
- [SGT](class-7/SGT.md) (class 7, 0x7A8) — Scalar greater than
- [SIEX](class-5/SIEX.md) (class 5, 0x571) — Scalar exponentiation by integer
- [SINT](class-8/SINT.md) (class 8, 0xA1) — Scalar initialize
- [SLRI](class-8/SLRI.md) (class 8, 0x02) — Start repeated-initialize loop
- [SLT](class-7/SLT.md) (class 7, 0x7AA) — Scalar less than
- [SMRK](class-0/SMRK.md) (class 0, 0x004) — Statement marker
- [SNEG](class-5/SNEG.md) (class 5, 0x5B0) — Scalar negate
- [SNEQ](class-7/SNEQ.md) (class 7, 0x7A5) — Scalar not equal
- [SNGT](class-7/SNGT.md) (class 7, 0x7A7) — Scalar not greater than
- [SNLT](class-7/SNLT.md) (class 7, 0x7A9) — Scalar not less than
- [SPEX](class-5/SPEX.md) (class 5, 0x572) — Scalar exponentiation by positive integer
- [SSDV](class-5/SSDV.md) (class 5, 0x5AE) — Scalar divide
- [SSHP](class-0/SSHP.md) (class 0, 0x042) — List-form SCALAR(...) shaping function
- [SSPR](class-5/SSPR.md) (class 5, 0x5AD) — Scalar multiply
- [SSUB](class-5/SSUB.md) (class 5, 0x5AC) — Scalar subtract
- [STOB](class-1/STOB.md) (class 1, 0x1A1) — Scalar to bit conversion
- [STOC](class-2/STOC.md) (class 2, 0x2A1) — Scalar to character conversion
- [STOI](class-6/STOI.md) (class 6, 0x6A1) — Scalar to integer conversion
- [STOQ](class-1/STOQ.md) (class 1, 0x1A2) — SUBBIT pseudo-conversion, scalar argument
- [STOS](class-5/STOS.md) (class 5, 0x5A1) — Scalar precision scale
- [STRI](class-8/STRI.md) (class 8, 0x01) — Repeated-initialize specifier
- [TASN](class-0/TASN.md) (class 0, 0x04F) — Structure assign
- [TDCL](class-0/TDCL.md) (class 0, 0x033) — TEMPORARY data-item declaration
- [TDEF](class-0/TDEF.md) (class 0, 0x02A) — Task definition header
- [TEQU](class-0/TEQU.md) (class 0, 0x04E) — Structure equal comparison
- [TERM](class-0/TERM.md) (class 0, 0x037) — Terminate program execution
- [TINT](class-8/TINT.md) (class 8, 0xE2) — Structure-terminal initialize
- [TNEQ](class-0/TNEQ.md) (class 0, 0x04D) — Structure not-equal comparison
- [TSUB](class-0/TSUB.md) (class 0, 0x01B) — Structure (copy) subscript specifier
- [UDEF](class-0/UDEF.md) (class 0, 0x02E) — Update block header
- [VADD](class-4/VADD.md) (class 4, 0x482) — Vector add
- [VASN](class-4/VASN.md) (class 4, 0x401) — Vector assign
- [VCRS](class-4/VCRS.md) (class 4, 0x48B) — Vector cross product
- [VDOT](class-5/VDOT.md) (class 5, 0x58E) — Vector dot product, scalar result
- [VEQU](class-7/VEQU.md) (class 7, 0x786) — Vector equal
- [VINT](class-8/VINT.md) (class 8, 0x81) — Vector initialize
- [VMPR](class-4/VMPR.md) (class 4, 0x46D) — Vector-matrix product
- [VNEG](class-4/VNEG.md) (class 4, 0x444) — Vector negate
- [VNEQ](class-7/VNEQ.md) (class 7, 0x785) — Vector not equal
- [VSDV](class-4/VSDV.md) (class 4, 0x4A6) — Vector divide by scalar
- [VSHP](class-0/VSHP.md) (class 0, 0x041) — VECTOR(...) shaping function
- [VSPR](class-4/VSPR.md) (class 4, 0x4A5) — Vector multiply by scalar
- [VSUB](class-4/VSUB.md) (class 4, 0x483) — Vector subtract
- [VTOV](class-4/VTOV.md) (class 4, 0x441) — Vector precision scale
- [VVPR](class-3/VVPR.md) (class 3, 0x387) — Vector outer product, matrix result
- [WAIT](class-0/WAIT.md) (class 0, 0x034) — WAIT statement (interval/UNTIL/FOR DEPENDENT)
- [WRIT](class-0/WRIT.md) (class 0, 0x021) — WRITE statement header
- [XREC](class-0/XREC.md) (class 0, 0x002) — End-of-record marker
- [XXAR](class-0/XXAR.md) (class 0, 0x027) — I/O statement argument
- [XXND](class-0/XXND.md) (class 0, 0x026) — I/O statement end
- [XXST](class-0/XXST.md) (class 0, 0x025) — I/O statement start, carries I/O-kind code

### By Opcode (numeric)

Note: Class 0 and Class 8 opcodes overlap numerically (each class's OPCODE
byte is independent); sorted here by class first, then opcode.

**Class 0:**

- 0x000 — [NOP](class-0/NOP.md) — No operation
- 0x001 — [EXTN](class-0/EXTN.md) — Extended (qualified-name) pointer
- 0x002 — [XREC](class-0/XREC.md) — End-of-record marker
- 0x003 — [IMRK](class-0/IMRK.md) — Inline-function statement marker
- 0x004 — [SMRK](class-0/SMRK.md) — Statement marker
- 0x005 — [PXRC](class-0/PXRC.md) — Record header, points to closing XREC
- 0x007 — [IFHD](class-0/IFHD.md) — IF statement header
- 0x008 — [LBL](class-0/LBL.md) — Branch destination label
- 0x009 — [BRA](class-0/BRA.md) — Unconditional branch
- 0x00A — [FBRA](class-0/FBRA.md) — Conditional (false) branch
- 0x00B — [DCAS](class-0/DCAS.md) — DO CASE statement header, computed branch
- 0x00C — [ECAS](class-0/ECAS.md) — DO CASE statement end / join point
- 0x00D — [CLBL](class-0/CLBL.md) — Computed-branch (DO CASE) destination label
- 0x00E — [DTST](class-0/DTST.md) — DO WHILE/UNTIL loop header
- 0x00F — [ETST](class-0/ETST.md) — DO WHILE/UNTIL loop end
- 0x010 — [DFOR](class-0/DFOR.md) — DO FOR statement header
- 0x011 — [EFOR](class-0/EFOR.md) — DO FOR statement end
- 0x012 — [CFOR](class-0/CFOR.md) — DO FOR supplementary WHILE/UNTIL condition test
- 0x013 — [DSMP](class-0/DSMP.md) — Plain DO; ... END; group header
- 0x014 — [ESMP](class-0/ESMP.md) — Plain DO; ... END; group end
- 0x015 — [AFOR](class-0/AFOR.md) — Per-value instruction for list-form DO FOR
- 0x016 — [CTST](class-0/CTST.md) — DO WHILE/UNTIL per-cycle condition test
- 0x017 — [ADLP](class-0/ADLP.md) — Arrayness specifier, brackets array loops
- 0x018 — [DLPE](class-0/DLPE.md) — End of array/structure specification
- 0x019 — [DSUB](class-0/DSUB.md) — Array/component subscript specifier
- 0x01A — [IDLP](class-0/IDLP.md) — STATIC-array counterpart of ADLP (uniform-value init)
- 0x01B — [TSUB](class-0/TSUB.md) — Structure (copy) subscript specifier
- 0x01D — [PCAL](class-0/PCAL.md) — Procedure call header
- 0x01E — [FCAL](class-0/FCAL.md) — Function call header
- 0x01F — [READ](class-0/READ.md) — READ statement header
- 0x020 — [RDAL](class-0/RDAL.md) — READALL statement header
- 0x021 — [WRIT](class-0/WRIT.md) — WRITE statement header
- 0x022 — [FILE](class-0/FILE.md) — File I/O specifier
- 0x025 — [XXST](class-0/XXST.md) — I/O statement start, carries I/O-kind code
- 0x026 — [XXND](class-0/XXND.md) — I/O statement end
- 0x027 — [XXAR](class-0/XXAR.md) — I/O statement argument
- 0x02A — [TDEF](class-0/TDEF.md) — Task definition header
- 0x02B — [MDEF](class-0/MDEF.md) — Program definition header
- 0x02C — [FDEF](class-0/FDEF.md) — Function definition header
- 0x02D — [PDEF](class-0/PDEF.md) — Procedure definition header
- 0x02E — [UDEF](class-0/UDEF.md) — Update block header
- 0x02F — [CDEF](class-0/CDEF.md) — Compool definition header
- 0x030 — [CLOS](class-0/CLOS.md) — CLOSE statement, closes a program/procedure/function/task
- 0x031 — [EDCL](class-0/EDCL.md) — End-of-declarations marker
- 0x032 — [RTRN](class-0/RTRN.md) — Subprogram return
- 0x033 — [TDCL](class-0/TDCL.md) — TEMPORARY data-item declaration
- 0x034 — [WAIT](class-0/WAIT.md) — WAIT statement (interval/UNTIL/FOR DEPENDENT)
- 0x035 — [SGNL](class-0/SGNL.md) — SIGNAL statement
- 0x036 — [CANC](class-0/CANC.md) — CANCEL statement, self or named process
- 0x037 — [TERM](class-0/TERM.md) — Terminate program execution
- 0x038 — [PRIO](class-0/PRIO.md) — UPDATE PRIORITY statement
- 0x039 — [SCHD](class-0/SCHD.md) — SCHEDULE statement
- 0x03C — [ERON](class-0/ERON.md) — ON ERROR / OFF ERROR statement (all forms)
- 0x03D — [ERSE](class-0/ERSE.md) — SEND ERROR statement (error simulation/signaling)
- 0x040 — [MSHP](class-0/MSHP.md) — MATRIX(...) shaping function
- 0x041 — [VSHP](class-0/VSHP.md) — VECTOR(...) shaping function
- 0x042 — [SSHP](class-0/SSHP.md) — List-form SCALAR(...) shaping function
- 0x043 — [ISHP](class-0/ISHP.md) — List-form INTEGER(...) shaping function
- 0x045 — [SFST](class-0/SFST.md) — Start of shaping-function specification
- 0x046 — [SFND](class-0/SFND.md) — End of shaping-function specification
- 0x047 — [SFAR](class-0/SFAR.md) — Shaping-function argument separator
- 0x04A — [BFNC](class-0/BFNC.md) — Built-in function call (e.g. PRIO, SINCOS)
- 0x04B — [LFNC](class-0/LFNC.md) — MAX/MIN built-in functions ("L-FUNC" category)
- 0x04D — [TNEQ](class-0/TNEQ.md) — Structure not-equal comparison
- 0x04E — [TEQU](class-0/TEQU.md) — Structure equal comparison
- 0x04F — [TASN](class-0/TASN.md) — Structure assign
- 0x051 — [IDEF](class-0/IDEF.md) — Inline function definition header
- 0x052 — [ICLS](class-0/ICLS.md) — Inline function close
- 0x055 — [NNEQ](class-0/NNEQ.md) — NAME (pointer) not-equal comparison
- 0x056 — [NEQU](class-0/NEQU.md) — NAME (pointer) equal comparison
- 0x057 — [NASN](class-0/NASN.md) — NAME (pointer) assign
- 0x059 — [PMHD](class-0/PMHD.md) — %macro invocation header
- 0x05A — [PMAR](class-0/PMAR.md) — %macro invocation argument
- 0x05B — [PMIN](class-0/PMIN.md) — %macro invocation end

**Class 1:**

- 0x101 — [BASN](class-1/BASN.md) — Bit-string assign
- 0x102 — [BAND](class-1/BAND.md) — Bit-string AND
- 0x103 — [BOR](class-1/BOR.md) — Bit-string OR
- 0x104 — [BNOT](class-1/BNOT.md) — Bit-string complement
- 0x105 — [BCAT](class-1/BCAT.md) — Bit-string catenate
- 0x121 — [BTOB](class-1/BTOB.md) — Bit-string length conversion
- 0x122 — [BTOQ](class-1/BTOQ.md) — SUBBIT pseudo-conversion, bit-string argument
- 0x141 — [CTOB](class-1/CTOB.md) — Character to bit conversion
- 0x142 — [CTOQ](class-1/CTOQ.md) — SUBBIT pseudo-conversion, character argument
- 0x1A1 — [STOB](class-1/STOB.md) — Scalar to bit conversion
- 0x1A2 — [STOQ](class-1/STOQ.md) — SUBBIT pseudo-conversion, scalar argument
- 0x1C1 — [ITOB](class-1/ITOB.md) — Integer to bit conversion
- 0x1C2 — [ITOQ](class-1/ITOQ.md) — SUBBIT pseudo-conversion, integer argument

**Class 2:**

- 0x201 — [CASN](class-2/CASN.md) — Character assign
- 0x202 — [CCAT](class-2/CCAT.md) — Character catenate
- 0x221 — [BTOC](class-2/BTOC.md) — Bit to character conversion
- 0x241 — [CTOC](class-2/CTOC.md) — Character-length conversion
- 0x2A1 — [STOC](class-2/STOC.md) — Scalar to character conversion
- 0x2C1 — [ITOC](class-2/ITOC.md) — Integer to character conversion

**Class 3:**

- 0x301 — [MASN](class-3/MASN.md) — Matrix assign
- 0x329 — [MTRA](class-3/MTRA.md) — Matrix transpose
- 0x341 — [MTOM](class-3/MTOM.md) — Matrix precision scale
- 0x344 — [MNEG](class-3/MNEG.md) — Matrix negate
- 0x362 — [MADD](class-3/MADD.md) — Matrix add
- 0x363 — [MSUB](class-3/MSUB.md) — Matrix subtract
- 0x368 — [MMPR](class-3/MMPR.md) — Matrix-matrix product
- 0x387 — [VVPR](class-3/VVPR.md) — Vector outer product, matrix result
- 0x3A5 — [MSPR](class-3/MSPR.md) — Matrix multiply by scalar
- 0x3A6 — [MSDV](class-3/MSDV.md) — Matrix divide by scalar
- 0x3CA — [MINV](class-3/MINV.md) — Matrix invert

**Class 4:**

- 0x401 — [VASN](class-4/VASN.md) — Vector assign
- 0x441 — [VTOV](class-4/VTOV.md) — Vector precision scale
- 0x444 — [VNEG](class-4/VNEG.md) — Vector negate
- 0x46C — [MVPR](class-4/MVPR.md) — Matrix-vector product
- 0x46D — [VMPR](class-4/VMPR.md) — Vector-matrix product
- 0x482 — [VADD](class-4/VADD.md) — Vector add
- 0x483 — [VSUB](class-4/VSUB.md) — Vector subtract
- 0x48B — [VCRS](class-4/VCRS.md) — Vector cross product
- 0x4A5 — [VSPR](class-4/VSPR.md) — Vector multiply by scalar
- 0x4A6 — [VSDV](class-4/VSDV.md) — Vector divide by scalar

**Class 5:**

- 0x501 — [SASN](class-5/SASN.md) — Scalar assign
- 0x521 — [BTOS](class-5/BTOS.md) — Bit string to scalar conversion
- 0x541 — [CTOS](class-5/CTOS.md) — Character to scalar conversion
- 0x571 — [SIEX](class-5/SIEX.md) — Scalar exponentiation by integer
- 0x572 — [SPEX](class-5/SPEX.md) — Scalar exponentiation by positive integer
- 0x58E — [VDOT](class-5/VDOT.md) — Vector dot product, scalar result
- 0x5A1 — [STOS](class-5/STOS.md) — Scalar precision scale
- 0x5AB — [SADD](class-5/SADD.md) — Scalar add
- 0x5AC — [SSUB](class-5/SSUB.md) — Scalar subtract
- 0x5AD — [SSPR](class-5/SSPR.md) — Scalar multiply
- 0x5AE — [SSDV](class-5/SSDV.md) — Scalar divide
- 0x5AF — [SEXP](class-5/SEXP.md) — Scalar exponentiation by scalar
- 0x5B0 — [SNEG](class-5/SNEG.md) — Scalar negate
- 0x5C1 — [ITOS](class-5/ITOS.md) — Integer to scalar conversion

**Class 6:**

- 0x601 — [IASN](class-6/IASN.md) — Integer assign
- 0x621 — [BTOI](class-6/BTOI.md) — Bit to integer conversion
- 0x641 — [CTOI](class-6/CTOI.md) — Character to integer conversion
- 0x6A1 — [STOI](class-6/STOI.md) — Scalar to integer conversion
- 0x6C1 — [ITOI](class-6/ITOI.md) — Integer precision scale
- 0x6CB — [IADD](class-6/IADD.md) — Integer add
- 0x6CC — [ISUB](class-6/ISUB.md) — Integer subtract
- 0x6CD — [IIPR](class-6/IIPR.md) — Integer multiply
- 0x6D0 — [INEG](class-6/INEG.md) — Integer negate
- 0x6D2 — [IPEX](class-6/IPEX.md) — Integer exponentiation by positive integer

**Class 7:**

- 0x720 — [BTRU](class-7/BTRU.md) — Bit-is-true test (conditional context)
- 0x725 — [BNEQ](class-7/BNEQ.md) — Bit string not equal
- 0x726 — [BEQU](class-7/BEQU.md) — Bit string equal
- 0x745 — [CNEQ](class-7/CNEQ.md) — Character not equal
- 0x746 — [CEQU](class-7/CEQU.md) — Character equal
- 0x747 — [CNGT](class-7/CNGT.md) — Character not greater than
- 0x748 — [CGT](class-7/CGT.md) — Character greater than
- 0x749 — [CNLT](class-7/CNLT.md) — Character not less than
- 0x74A — [CLT](class-7/CLT.md) — Character less than
- 0x765 — [MNEQ](class-7/MNEQ.md) — Matrix not equal
- 0x766 — [MEQU](class-7/MEQU.md) — Matrix equal
- 0x785 — [VNEQ](class-7/VNEQ.md) — Vector not equal
- 0x786 — [VEQU](class-7/VEQU.md) — Vector equal
- 0x7A5 — [SNEQ](class-7/SNEQ.md) — Scalar not equal
- 0x7A6 — [SEQU](class-7/SEQU.md) — Scalar equal
- 0x7A7 — [SNGT](class-7/SNGT.md) — Scalar not greater than
- 0x7A8 — [SGT](class-7/SGT.md) — Scalar greater than
- 0x7A9 — [SNLT](class-7/SNLT.md) — Scalar not less than
- 0x7AA — [SLT](class-7/SLT.md) — Scalar less than
- 0x7C5 — [INEQ](class-7/INEQ.md) — Integer not equal
- 0x7C6 — [IEQU](class-7/IEQU.md) — Integer equal
- 0x7C7 — [INGT](class-7/INGT.md) — Integer not greater than
- 0x7C8 — [IGT](class-7/IGT.md) — Integer greater than
- 0x7C9 — [INLT](class-7/INLT.md) — Integer not less than
- 0x7CA — [ILT](class-7/ILT.md) — Integer less than
- 0x7E2 — [CAND](class-7/CAND.md) — Logical AND
- 0x7E3 — [COR](class-7/COR.md) — Logical OR
- 0x7E4 — [CNOT](class-7/CNOT.md) — Logical NOT

**Class 8:**

- 0x01 — [STRI](class-8/STRI.md) — Repeated-initialize specifier
- 0x02 — [SLRI](class-8/SLRI.md) — Start repeated-initialize loop
- 0x03 — [ELRI](class-8/ELRI.md) — End (one unit of a) repeated-initialize loop
- 0x04 — [ETRI](class-8/ETRI.md) — End repeated-initialize loop
- 0x21 — [BINT](class-8/BINT.md) — Bit-string initialize
- 0x41 — [CINT](class-8/CINT.md) — Character initialize
- 0x61 — [MINT](class-8/MINT.md) — Matrix initialize
- 0x81 — [VINT](class-8/VINT.md) — Vector initialize
- 0xA1 — [SINT](class-8/SINT.md) — Scalar initialize
- 0xC1 — [IINT](class-8/IINT.md) — Integer initialize
- 0xE1 — [NINT](class-8/NINT.md) — NAME (pointer) initialize
- 0xE2 — [TINT](class-8/TINT.md) — Structure-terminal initialize
- 0xE3 — [EINT](class-8/EINT.md) — EQUATE EXTERNAL statement

These lists will be regenerated/expanded as more instruction files are
added; see `STATUS.md` for the full known inventory, including opcodes
confirmed but not yet documented.
