# Halmat.pdf — Content Errors Checklist

Found while cross-checking Zane Hambly's *HALMAT Instruction Set
Reference* (`Halmat.pdf`, Feb 2026, 114 pages, 180 opcodes claimed)
against this project's independently-built, empirically-verified
documentation (`reengineered-documentation/`). Scope: content errors and
omissions only — not spelling/grammar. Each item was checked against the
HAL/S-FC compiler source (`PASS.REL32V0`) and/or real compiled HALMAT
before being listed here; several apparent conflicts turned out to be
*our* errors instead and were fixed in this project rather than listed
below.

## 1. MDET (0x371) and MIDN (0x373) are not real HALMAT opcodes — p. 62

Both entries cite only "Other References: `GENCLAS0.xpl:4538`" /
`GENCLAS3.xpl:106` — no "Emission (PASS1)" section, unlike every genuine
opcode in the document. `PASS1.PROCS/##DRIVER.xpl` (the compiler's own
authoritative HALMAT-opcode table) has no `XMDET`/`XMIDN` entries
anywhere; the neighboring Class 3 opcodes (`XMTRA`=0x329, `XMMPR`=0x368,
`XMINV`=0x3CA) leave no room for them. The `XMDET("11")`/`XMIDN("13")`
constants live in `PASS2.PROCS/##DRIVER.xpl` under a comment "`/* 5-BIT
OPCODES */`" — an unrelated PASS2-internal dispatch table, not HALMAT
opcode values, and the numbers don't map to 0x371/0x373 by any simple
transform. `GENCLAS0.xpl:4538` is a PASS2 code-gen dispatch check
(`IF OPCODE = XMDET THEN DO;`), not a HALMAT emission site. Matrix
determinant/identity are more likely reached via `BFNC`'s built-in
function selector (as in the predecessor language, where `DET` is
invoked via `FUNC`) than a dedicated opcode.

## 2. VSDV (0x4A6) is missing entirely — should be near p. 66

The document jumps from `VSPR` (0x4A5) straight to the Class 5 header,
skipping `VSDV` (vector divide-by-scalar). It's a real, primary-source
opcode: `XVSDV BIT(16) INITIAL("04A6")` in `PASS1.PROCS/##DRIVER.xpl`,
declared in the very same statement as `XMSDV`/`XSSDV` (`MSDV`, which
the document *does* list correctly at 0x3A6).

## 3. SFST/SFND/SFAR (0x045/0x046/0x047) mislabeled "Subscript range" — pp. 44–47

These are actually the **Shaping Function** call bracket (start/end/
argument), not a subscript-range mechanism. [MSC-01847] §2.14's own
section title for the predecessor-language analog is "Auxiliary SHAPING
FUNCTION SPECIFIERS." The document's own cited emission sites contradict
its label too: `STARTNOR.xpl`, `ENDANYFC.xpl` ("end any function call"),
`SETUPCAL.xpl` ("setup call") are all function-call-argument setup code,
nothing subscript-related.

## 4. "IGE"/"ILE" are not real mnemonics — p. 96, Condition Expressions table

The IF/ELSE pattern's "Condition Expressions" table lists `IF A >= B` →
`IGE` and `IF A <= B` → `ILE`. Neither mnemonic appears anywhere else in
the document, including its own 180-opcode inventory. The real HAL/S
mnemonics are `INLT` (0x7C9, "integer not less than," i.e. `>=`) and
`INGT` (0x7C7, "integer not greater than," i.e. `<=`) — both already
correctly documented elsewhere in the same document (pp. 81–82).

## 5. XXST's operand is not an "argument count" — pp. 105–107, I/O Groups

Stated as "op1: IMD(n) — the number n is the count of XXAR operators in
this group." The document's own worked example
(`WRITE(6) I, MY_NAME, ' IS A FRIEND OF MINE';`, HELLO.hal) contradicts
this: it shows **3** XXAR entries but XXST's operand is `IMD(2)`, not
`IMD(3)`. The document even notes the mismatch (p. 107) but rationalizes
it away rather than reconsidering the interpretation. The correct
reading (confirmed by direct binary decode against real compiled HALMAT
in this project): XXST's sole operand is the I/O-statement-kind code —
0=READ, 1=READALL, 2=WRITE — which matches the example exactly
(2=WRITE). This is the same pass2.rpt/LSTALL text-report
visual-misattribution trap (an operand printing directly below the
instruction it visually follows rather than the one it belongs to) that
this project independently hit and fixed for the same instruction.

---

## Bonus finding this comparison surfaced (not a Halmat.pdf error)

`Halmat.pdf`'s `MATRIX(3,3)` subscripting examples (pp. 111–113) show
`DSUB`'s per-operand `TAG1` ("α") value as `1` for the "index" subscript
kind, where our own documentation had it as `5` — established only from
`ARRAY` subscripting tests. A follow-up sweep (asterisk/index/
to-partition/at-partition, on both `VECTOR(3)` and `MATRIX(3,3)`)
resolved this fully: `VECTOR`/`MATRIX` element subscripting doesn't use
a separate scheme at all — it reuses the primary source's existing
"component" α column (0/1/2/3), the same one previously confirmed only
for `CHARACTER` structure-terminal access. The real axis the primary
source's table draws is "`ARRAY`-dimension subscripting" (α=4–7) vs.
"everything else" (α=0–3), not "array vs. component" read literally.
Now fully documented in `class-0/DSUB.md`.
