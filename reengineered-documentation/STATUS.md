# Documentation Status

Cross-session progress tracker for Phase 1 (see `Plan.md`). Update this file
whenever an instruction is documented, its inventory status changes, or new
source material is reviewed.

## Alternate source locations

Per direct guidance: if a needed primary-source PDF isn't in
`source-documentation/`, check these locations before asking again —
almost everything shows up in one of them:

- `../../Desktop/sandroid.org/public_html/apollo/Shuttle/` — PDFs
- `../virtualagc-web/` — HTML and PDFs
- `../Halmat/` — PDFs (the [Halmat.pdf] / yaHALMAT repo clone)

**Deduplication policy**: to avoid unnecessary duplication, files already
present (byte-identical, confirmed by matching file size) in one of the
above are removed from `source-documentation/` once found. Removed this
session: `HALMAT - An Intermediate Language.pdf` ([MSC-01847], now only
in `sandroid.org/.../Shuttle/`), `HAL_S-360 Compiler System Specification
4 Feb 1977.pdf` ([IR-60-5], same location), `HAL_S-FC User's Manual Nov
2005.pdf` ([USA00309], same location), `HAL_S Programmers Guide Nov
2005.pdf` ([USA003087], same location), and `Halmat.pdf` (duplicated in
*both* `../virtualagc-web/` and `../Halmat/`). The derived
`MSC-01847.part{1,2,3}.pdf` split files remain in `source-documentation/`
since they're this project's own artifacts, not duplicates of anything
found elsewhere.

## Source material reviewed so far

| Document | Pages/extent reviewed | Notes |
|---|---|---|
| [CourseSlides.pdf] | PDF pages 483–489 (of 657) | "Basic HAL/S Programming Course" — a slide-deck training document, distinct in kind from the reference-manual sources above (informal, scanned-OCR text with layout artifacts). User-supplied pointer to pp. 486–487 ("DATA CSECTS (CONTINUED)"), which directly documents `EQUATE EXTERNAL` in prose — confirming [EINT](class-8/EINT.md)'s purpose (an ESD entry-point/linker-alias mechanism for non-HAL/S access to HAL/S data) exactly as previously inferred from compiler source alone. Available locally at `../../Desktop/sandroid.org/public_html/apollo/Shuttle/Courses/Basic HAL-S Programming Course/CourseSlides.pdf` (same mirror as other sources — see "Alternate source locations" above) as well as the source URL `https://www.ibiblio.org/apollo/Shuttle/Courses/Basic%20HAL-S%20Programming%20Course/CourseSlides.pdf`. Only the EQUATE EXTERNAL-relevant page range has been reviewed so far; the remaining 650 pages are an unreviewed, potentially valuable source of further primary-source confirmations (likely covers much of the same ground as [USA003087] but in worked-example/course-note form, plus implementation-level detail like CSECT/ESD/linkage internals not found in the Programmer's Guide at all) — worth a broader read in a future session. |
| [IR-60-5] | PDF pages 108–134 (of 134) | Covers (at least) printed pages A-3–A-8, A-93–A-94, A-103–A-104, A-109, A-110–A-118. This is believed to be the entirety of the HALMAT-relevant material in this partial copy; pages 1–107 were not reviewed (front matter / unrelated compiler chapters, per the document's own page numbering and the source URL's `#page=114` anchor) and should be spot-checked in a future session before being ruled out entirely. |
| [Halmat.pdf] | PDF pages 1–15 (of 114) | Covers title page, foreword, Word Format, Block Structure/Large-Scale Organisation summary, and Class 0 entries NOP through BRA (partial — BRA's own detail page not yet read). Pages 16–114 (remainder of Class 0, and all of Classes 1–8) not yet reviewed. |
| [MSC-01847] | Nearly all of it: part1 pp. 1–42 (all), part2 pp. 1–40 (of 42), part3 pp. 1–40 (of 41) | The original file (105 MB) exceeds the Read tool's 100 MB text-extraction limit. Fixed by splitting with `pdftk`: `source-documentation/MSC-01847.part1.pdf` (pp. 1–42), `.part2.pdf` (pp. 43–84), `.part3.pdf` (pp. 85–125) — each well under the cap and directly readable. These split files are untracked/gitignored (under `source-documentation/`). The original 105 MB file (`HALMAT - An Intermediate Language.pdf`) was removed from `source-documentation/` as a duplicate — it's available at `../../Desktop/sandroid.org/public_html/apollo/Shuttle/HALMAT - An Intermediate Language.pdf` (see the "Alternate source locations" note below); if the split files are ever missing, regenerate from that path with `pdftk ".../HALMAT - An Intermediate Language.pdf" cat 1-42 output MSC-01847.part1.pdf` (and similarly 43-84 → part2, 85-125 → part3). Covers: front matter/foreword/TOC; **Chapter 1** (§1.1–1.8: symbolic/physical instruction format, notation — see "Notation reference" below); Chapter 2 (§2.1–2.9, §2.16–2.24: Code Markers, Labels, Branches, Arrayness/Structureness Specifiers, Subscript Allocators, Terminal/Array/Structure Subscript Specifiers, Precision Conversion, [gap: §2.10–2.15 — see below], Bit String, Character, Matrix, Vector, Scalar, Integer, Conditional, Initialization Operations, DO FOR Specifiers) with full instruction-level bit diagrams and prose in the predecessor language's own physical format; Chapter 3 (§3.1–3.8: worked HALMAT-construct examples for arithmetic, flow-control, I/O, procedure, function, and initialization statements); Appendix A (symbol/literal table layout); **Appendix B** (complete alphabetical mnemonic→opcode→one-line-description table for the full HAL 1971 instruction set, ~150 entries); **Appendix C** (the same data as a full opcode→mnemonic lookup table, cross-confirming B); Appendix D (numeric codes for qualifier/optimization/operand-type subfields); Appendix E (shaping-function numeric codes). **Gap closed.** `part1.pdf` pp. 26–35 (printed pp. 2-10 to 2-19) were re-read and recovered §2.10 (Static Initialization Flow Specifiers: ENDS/ENTS/EXTS), §2.11 (Argument List Specifiers: FCLM/FLIN/FPGE/FSKP/FTAB/LIST/LSTE), §2.12 (I/O Specifiers: FASN/FILE/RDAL/READ/WRIT), §2.13 (Subprogram Specifiers: CALL/CASS/FDEF/FUNC/MDEF/PDEF/RTRN/TDEF/TERM/UDEF/UEND/ZRFN), §2.14 (Auxiliary Shaping Function Specifiers: ASIZ/SFAR/SFND/SFST/TSIZ), and §2.15 (Structure Operations: TASN/TEQU/TNEQ), ending exactly where the original wide-range read's visible content picked back up (§2.16, Bit String Operations) — confirming there was no further gap beyond p. 35. [MSC-01847]'s Chapters 1–3 and Appendices A–E are now considered fully reviewed for this project's purposes (only part2 pp. 41–42 and part3 p. 41 remain unread, likely just closing material, low priority). Not yet reviewed at all: part2 pp. 41–42, part3 p. 41 (tail end of document, likely just closing appendix material). This document describes the *predecessor* language HAL (1971), not HAL/S (1977) — see the cross-reference notes throughout this file for how it's being used. Diagnostic note: an independent `pdftotext -layout` dump of a page range is a cheap way to check what's actually on those pages before spending a Read call — used successfully this session to confirm real content existed at pp. 6–20 before re-reading it. |
| [##DRIVER.xpl] | `PASS1.PROCS/##DRIVER.xpl` lines ~2052–2258 | **Phase 2 primary source.** `../virtualagc/yaShuttle/Source Code/PASS.REL32V0/PASS1.PROCS/##DRIVER.xpl` declares every HALMAT opcode as a named XPL/I constant (`X`-prefixed, e.g. `XSMRK BIT(16) INITIAL("004")`), for direct use by the compiler itself — the single most authoritative source available for HAL/S opcode numbers, since it's what the real compiler actually uses. Also declares the operand-qualifier constants (`XSYT`=1, `XINL`=2, `XVAC`=3, `XXPT`=4, `XLIT`=5, `XIMD`=6, `XAST`=7, `XCSZ`=8, `XASZ`=9, `XOFF`=10 — an exact match to the QUAL table already in [HALMAT.md](HALMAT.md), now primary-source-confirmed for HAL/S itself rather than only via [IR-60-5]) and the two Optimizer-HALMAT code-optimizer tag bits (`XCO_N`="01", `XCO_D`="02"). Confirms essentially every opcode already in this file's Class 0 and Class 8 tables, corrects a couple of values inferred from [MSC-01847] (see Class 4/5 notes below), and gives confirmed opcodes for many previously-undocumented Class 0/1/2/3/4/5/6/7 entries. Not yet exhaustively cross-referenced against emission/consumption sites elsewhere in the source (that's a good next step — see "Next steps" below) — what's recorded here so far is the opcode table itself, read directly, not yet validated against actual compiled HALMAT binaries. Some array-valued declarations (e.g. `XBTOI(5)`) use a comment convention where only the first element has a real variable name and subsequent elements' conceptual names are given in trailing comments (`/* INDEXED OFF OF XCTOI */`); those are recorded below with the same care but flagged where the convention made attribution ambiguous. |
| Compiler report switches | Tested empirically (see below) | Confirmed: PASS1's compile-time option `HALMAT` (abbreviated `HM`, bit `0x00040000` in `OPTIONS_CODE`, declared in `MONITOR.ASM/COMPOPT.bal`) makes `pass1.rpt` print each HALMAT instruction (`HALMAT LINE N: <opcode>(<numop>),<tag>,<extra>` plus its operand(s)) interleaved with the original HAL/S source listing — verified by compiling `PASS.REL32V0/regression/HELLO.hal` locally with `HALSFC --parms="HALMAT,LIST,LISTING2" HELLO.hal`. The report is very noisy (a full scanner/parser production trace prints regardless of the `TRACE` option and regardless of debug- vs. production-build; cause not yet identified — worth investigating further, or just filtering with `grep`). **PASS2**: per a secondary source (https://www.ibiblio.org/apollo/HAL.html#moron, the historical HAL/S option reference), the compile-time option `LSTALL` makes PASS2's report include HALMAT, generated AP-101S object code, and HAL/S source statements together — statements are identified there only by *statement number*, so cross-referencing back to source text requires consulting the PASS1 report (which does show statement numbers against source lines) as well.

**The full mechanism has now been traced precisely** (per a pointer to `PASS2.PROCS/INITIALI.xpl` line 1134): HAL/S-FC runs atop an IBM BAL (Basic Assembly Language) monitor program (source in `MONITOR.ASM/`), which parses compile-time options and sets/resets flag bits in an integer variable named `OPTIONS_CODE` (PASS1's name for it) / `OPTION_BITS` (PASS2's name) — both are `LITERALLY 'COMM(7)'`, i.e. the *same* shared-COMMON storage location, so a bit PASS1 sets from the PARM field genuinely propagates through the COMMON-file chain (`COMMON0.out` → ... → `COMMON3.out`, read by PASS2) to PASS2 without needing its own `--parm` argument. `MONITOR.ASM/COMPOPT.bal` assigns LSTALL bit `0x00020000` (confirming the two-flavor note below). `PASS2.PROCS/INITIALI.xpl` line 1134 checks exactly that bit: `IF (OPTION_BITS & "20000") ^= 0 THEN DO; ... TOGGLE = TOGGLE | "70"; END;` — setting three TOGGLE bits at once, which lines 1150–1153 decode as `DIAGNOSTICS` (0x10), `ASSEMBLER_CODE` (0x20), and `HALMAT_REQUESTED` (0x40). `HALMAT_REQUESTED` in turn gates real, functioning print code: `PASS2.PROCS/GENERATE.xpl` line 1344, inside the `DECODEPIP` ("decode HALMAT operand") procedure, has `IF HALMAT_REQUESTED THEN DO; ... OUTPUT = ...; END;`. **Note the important two-flavor split**: HAL/S-FC has "PFS" and "BFS" builds, and `PASS2.PROCS/INITIALI.xpl`'s code around line 1134 is conditionally compiled per flavor (`/?P ... ?/` for PFS, `/?B ... ?/` for BFS) — the bit-check and variable names above are for the PFS flavor (`CODE_LISTING_REQUESTED`), which is also `HALSFC`'s default (non-`--bfs`) build; BFS uses `CODE_LISTING` instead but the same bits.

**Root cause found, and `LSTALL` is now confirmed fully working.** The first empirical tests (above) used `PASS.REL32V0/regression/HELLO.hal`, whose own first line is a pre-existing debug directive `DEBUG ¢0¢3¢4¢5¢6¢8¢9¢C¢D¢E¢F H(202)`. Since `DEBUG ¢n` codes are *toggles*, not sets, and (per direct guidance) `LSTALL` itself apparently toggles ¢5/¢6, having both `LSTALL` and a source file that already has ¢5/¢6 on **turns those specific bits back off** — self-cancelling. Confirmed by two follow-up tests: (1) stripping `¢5`/`¢6` from `HELLO.hal`'s debug line and recompiling with `LSTALL` — still no change; (2) switching to a different test file, `yaShuttle/ported/PASS1.PROCS/SIMPLE.hal`, whose debug line is only `` DEBUG `E`F `` (no 5/6 at all) — compiling *that* with `HALSFC --parms="LSTALL" SIMPLE.hal` produced a `pass2.rpt` of **944 lines versus 41 without `LSTALL`**, containing exactly the expected interleaved listing: `*** HAL/S STATEMENT N` markers, `HALMAT: <opcode>(<numop>),<tag>,<extra>:<line>.<sub>` lines with their operand(s) on the following line(s), and real generated AP-101S assembly (`LHI`, `STH`, `IAL`, `LA`, etc.) with addresses — i.e. exactly the HALMAT/object-code/statement interleaving the secondary source described. (Test (1) not fully explaining the continued failure on `HELLO.hal` is presumably because that file's debug line also carries `H(202)`, a separate/different debug parameter, and/or other retained ¢-codes still interact somehow — not fully isolated, but moot now that a clean working example exists.)

As a bonus, this real compiled output directly **cross-validates already-documented opcodes**: the combined 12-bit CLASS:OPCODE hex values seen include `005` ([PXRC](class-0/PXRC.md)), `02B` ([MDEF](class-0/MDEF.md)), `004` ([SMRK](class-0/SMRK.md)), `8A1` ([SINT](class-8/SINT.md), i.e. class 8 opcode 0xA1), and `8C1` ([IINT](class-8/IINT.md), class 8 opcode 0xC1) — all matching exactly. `801` also appears, presumably [STRI](class-8/STRI.md) (class 8 opcode 0x01), consistent with the file's `INTEGER INITIAL(1)` declaration.

**Recommended invocation for future sessions**: use a test `.hal` file with no pre-existing `¢5`/`¢6` debug codes (or none at all), and compile with `HALSFC --parms="LSTALL" file.hal`; read the resulting `pass2.rpt`. This is now a confirmed, working, high-value verification tool — real compiled HALMAT with statement and object-code correlation, on demand, for any test program. **Even better**: per direct guidance, `¢n` debug codes support explicit `¢n+` (turn on) / `¢n-` (turn off) forms, not just the bare toggling `¢n` form — using `+`/`-` avoids the toggle-cancellation trap entirely, so a future session can safely combine `LSTALL` with any hand-written `DEBUG` line by using `¢5+¢6+` (or whatever codes are needed) rather than relying on a file having no conflicting codes. **OPT**: the same secondary source (https://www.ibiblio.org/apollo/HAL.html#debuggingAids) states that inserting a source line of the form `DEBUG H(6)` (column 1) activates a "debugging aid" that inserts HALMAT into the OPT report, and `DEBUG H(7)` ("blab" mode) inserts more. This lines up with the `PRINT_SENTENCE`/`WATCH`-gated routine found earlier via static reading (`OPT.PROCS/PRINTSEN.xpl` — see below). **Empirical test**: inserting a plain `DEBUG H(6)` line into a copy of `HELLO.hal` (which already carries a pre-existing debug directive of the form `DEBUG ¢0¢3¢4¢5¢6¢8¢9¢C¢D¢E¢F H(202)` — note the `¢`-delimited code list, likely an EBCDIC-charset artifact) did not change `opt.rpt`'s content (still just header/footer, no HALMAT). Compilation itself succeeded normally (same "43 HALMAT OPERATORS CONVERTED" as other runs), so the insertion wasn't rejected outright, but it also wasn't recognized as intended — most likely the debug-code list needs the same special delimiter character as the pre-existing line, which a plain ASCII `DEBUG H(6)` doesn't supply. **Both of these are flagged as open for a future session** — the secondary source is credible and specific enough to be worth pursuing further (try matching the exact `¢`-delimited syntax, or merging into the existing DEBUG line rather than adding a new one), but neither is empirically confirmed working yet. Doesn't block opcode-table work, which comes from `##DRIVER.xpl` directly instead. OPT's `PRINT_SENTENCE` routine (`OPT.PROCS/PRINTSEN.xpl`) dumps raw HALMAT hex during optimization, gated by a `WATCH` flag (`OPT.PROCS/##DRIVER.xpl`) whose trigger wasn't independently located via static reading either; `--rsb-trace=1` (a `HALSFC` option) caused OPT to fail outright on the test file rather than enabling it. **Clarification received**: `DEBUG H(n)` options only take effect starting at the next [SMRK](class-0/SMRK.md) instruction encountered in the source, so if multiple `H(n)` directives occur between two SMRKs, only the last one applies — relevant if the `¢`-delimited syntax is investigated further, since placement relative to statement boundaries matters, not just the code list itself. That said, **OPT-report HALMAT printing has been deprioritized** — per direct guidance, it "doesn't seem that useful anyway," so this thread is considered closed rather than merely open; PASS1's `HALMAT` option (confirmed working) and `##DRIVER.xpl` (the opcode table) remain the productive tools for this project. |

### Notation reference for [MSC-01847] citations

[MSC-01847] describes each HAL-1971 instruction "symbolically" using a
fixed notation (Chapter 1) that this file's and the instruction files'
cross-reference notes rely on:

- Every instruction has two **OPERAND FIELDS** `a`/`b`, an **OPERATOR
  FIELD** `r`, and an **EXTENSION FIELD** `e`. `C{x}` means "the contents
  of field/subfield x." `r` splits into `r_op` (operation code) and `r_co`
  (text-optimizer tag). Each operand field `x` (`a` or `b`) splits into
  `x_op` (the operand itself, or a pointer to it), `x_t` (a
  qualifier with no fixed meaning — explained per-instruction in Chapter
  2), and `x_q` (a qualifier *mnemonic* selecting which of several forms
  `x_op` takes) — see Table 1.3.1 below. `e` and the `a_t`/`b_t` pair are
  physically the same bits (mutually exclusive).
- **Table 1.3.1** (VARIABLE OPERAND qualifier mnemonics, values of
  `x_q`): `SYT` = symbol-table pointer, `VAC` = "virtual accumulator"
  (indexes a previous HALMAT instruction whose result is used), `LIT` =
  literal-table pointer, `IMD` = immediate numeric value, `GLI` = internal
  flow number (or zero). Generic/composite forms: `EXV` = any of
  SYT/LIT/VAC; `EEV` = any of SYT/LIT/VAC/IMD; `VAR` = any of
  SYT/LIT/VAC/IMD/GLI.
- **Table 1.3.2** (LABEL OPERAND qualifier mnemonics): `INL` = internal
  flow number, `SYL` = symbol-table pointer, `ABL` = indexes a subsequent
  HALMAT instruction directly. Generic forms: `EXL` = INL or SYL; `LAB` =
  any of INL/SYL/ABL.
- **Table 1.4.1** (`r_co`, TEXT OPTIMIZER TAG mnemonics — these are the
  single/double-letter codes shown in the small box next to each
  instruction's mnemonic in Chapter 2's diagrams): `E` = end-of-expression
  marker, `IW`/`Il` = automatic/static initialization instruction, `Il`
  (also written `II`) = instruction relocation marker, `F`/`FE` = function
  specification (+ end-of-expression), `A`/`AE` = subscript allocation (+
  end-of-expression), `D` = arrayness/structureness specification, `M` =
  instruction relocation marker, `S`/`SE` = subscript specification (+
  end-of-expression), `N`/`L` = instruction relocation markers. In Chapter
  2 diagrams, `K` in this position means "depends on the surrounding
  construct."
- **Table 1.5.1** (OPERAND TYPE mnemonics, shown as a small `t` field with
  no physical counterpart, used only in the documentation): `B`=bit,
  `C`=character, `M`=matrix, `V`=vector, `S`=scalar, `I`=integer (these six
  are "HAL variable types"), `L`=logical (compare-instruction result
  type), `T`=structure, `Z`=any of the above.
- **Physical format** (§1.7, Figure 1.7.1): each HAL-1971 HALMAT
  instruction occupies exactly **four 16-bit IBM/360 halfwords**: `a_op`
  (16 bits), `b_op` (16 bits), a third halfword split into `a_t`(5)/
  `a_q`(3)/`b_t`(5)/`b_q`(3) bits (or, when not empty, `e` occupying the
  same bits as `a_t`), and a fourth halfword split into `r_co`(4)/`r_op`
  (12) bits. **This is fundamentally different from HAL/S's variable-length
  operator-word-plus-N-operand-words scheme** (see
  [HALMAT.md](HALMAT.md#word-format)) — none of these physical bit
  positions transfer to HAL/S; only the symbolic-level operand kinds
  (SYT/VAC/LIT/IMD/GLI/etc.) and behavioral descriptions are used as
  cross-language evidence in this project.
- HALMAT text between PHASE I and PHASE II is stored in **PAGES** (one per
  disk block), each holding up to 898 **LINES** (one instruction per
  line) across four parallel 16-bit-wide columns — a different scheme from
  HAL/S's RECORD/PXRC/XREC structure described in
  [HALMAT.md](HALMAT.md#block-record-structure), though conceptually
  analogous (both are fixed-size-block packing schemes for a variable
  amount of instruction text).
| [MSC-01847] class scheme | — | Confirmed structurally: HAL 1971's opcodes are grouped by leading hex digit exactly matching HAL/S's CLASS field (1xx=bit, 2xx=char, 3xx=matrix, 4xx=vector, 5xx=scalar, 6xx=integer, 7xx=conditional, 8xx=initialization; 0xx=program structure/control flow), corroborating the Class overview table in [HALMAT.md](HALMAT.md#instruction-classes) with primary source for the first time (previously [Halmat.pdf]-only). Class 7's numeric span also matches closely: [IR-60-5] states HAL/S Class 7 runs 0x725 (BNEQ) to 0x7CA (ILT); HAL 1971 has BNEQ=0x721 and ILT=0x7CA — the upper bound matches exactly. |

## Class 0 — Program Structure & Control Flow

Mnemonic/opcode inventory below is now cross-confirmed by **two independent
primary sources**: [IR-60-5] A.2 (the Class 0 operator index, pp.
A-103–A-104) and, as of this session, [##DRIVER.xpl] (the actual compiler's
own opcode constant table — see the "Source material" entry above). Every
opcode the two sources both cover matches exactly, which is a strong
validation of both. [##DRIVER.xpl] also adds 11 Class 0 mnemonics not
present in the (partial) [IR-60-5] index at all. Page numbers in the
"IR-60-5 pg." column are the *target* pages cited by [IR-60-5]'s index for
each instruction's own description — most are not present in the available
partial copy, so "Documented" only where behavioral content was actually
found (from [MSC-01847] cross-reference or better).

| Opcode | Mnemonic | Status | Confidence | IR-60-5 pg. | Notes |
|---|---|---|---|---|---|
| 0x000 | NOP | Documented | High | 6 | |
| 0x001 | EXTN | Documented | High | 91 | Opcode confirmed primary-source ([##DRIVER.xpl] `XEXTN`); "extended pointer" resolving qualified structure-variable references, grammar rule and operand-word format confirmed directly from `SYNTHESI.xpl`; see [EXTN](class-0/EXTN.md) |
| 0x002 | XREC | Documented | High | 6 | |
| 0x003 | IMRK | Documented | High | 7 | |
| 0x004 | SMRK | Documented | High | 6 | |
| 0x005 | PXRC | Documented | High | 7 | |
| 0x007 | IFHD | Documented | High | 49 | Opcode confirmed ([##DRIVER.xpl] `XIFHD`). `IF` statement header, empirically confirmed this session |
| 0x008 | LBL | Documented | High | 49 | Opcode confirmed ([##DRIVER.xpl] `XLBL`); page not in available copy. [MSC-01847] confirms an identically-named, identically-opcoded (0x008) instruction "label" in HAL 1971 |
| 0x009 | BRA | Documented | High | 50 | Opcode confirmed ([##DRIVER.xpl] `XBRA`); page not in available copy. [MSC-01847] has "BRA"/"unconditional branch" but at a different opcode (0x010) in HAL 1971 |
| 0x00A | FBRA | Documented | High | 50 | Opcode confirmed ([##DRIVER.xpl] `XFBRA`); page not in available copy. [MSC-01847] has "FBRA"/"false branch on condition" at HAL-1971 opcode 0x012 |
| 0x00B | DCAS | Documented | High | 51 | Opcode confirmed ([##DRIVER.xpl] `XDCAS`). `DO CASE` statement header — HAL/S's own computed-branch-origin instruction (fills the "CBRA analog" gap noted below), empirically confirmed this session |
| 0x00C | ECAS | Documented | High | 52 | Opcode confirmed ([##DRIVER.xpl] `XECAS`). `DO CASE` end/join-point marker, empirically confirmed this session |
| 0x00D | CLBL | Documented | High | 51 | Opcode confirmed ([##DRIVER.xpl] `XCLBL`). Companion instruction confirmed to be [DCAS](class-0/DCAS.md), not a separately-named CBRA analog. [MSC-01847] has "CLBL"/"computed-branch label" at HAL-1971 opcode 0x009; used with HAL-1971's CBRA (0x011, "computed branch") |
| 0x00E | DTST | Documented | High | 52 | Opcode confirmed ([##DRIVER.xpl] `XDTST`). `DO WHILE`/`DO UNTIL` loop header, empirically confirmed this session including the WHILE/UNTIL polarity encoding |
| 0x00F | ETST | Documented | High | 53 | Opcode confirmed ([##DRIVER.xpl] `XETST`). `DO WHILE`/`DO UNTIL` loop end, empirically confirmed this session |
| 0x010 | DFOR | Documented | High | 54–55 | Opcode confirmed ([##DRIVER.xpl] `XDFOR`). `DO FOR` loop header (both range and list forms), empirically confirmed this session |
| 0x011 | EFOR | Documented | High | 57 | Opcode confirmed ([##DRIVER.xpl] `XEFOR`). `DO FOR` loop end, empirically confirmed this session |
| 0x012 | CFOR | Documented | High | 56 | Opcode confirmed ([##DRIVER.xpl] `XCFOR`). `DO FOR`'s supplementary `WHILE`/`UNTIL` clause test, empirically confirmed this session |
| 0x013 | DSMP | Documented | High | 57 | Opcode confirmed ([##DRIVER.xpl] `XDSMP`). Plain `DO; ... END;` group header, empirically confirmed this session |
| 0x014 | ESMP | Documented | High | 57 | Opcode confirmed ([##DRIVER.xpl] `XESMP`). Plain `DO; ... END;` group end, empirically confirmed this session |
| 0x015 | AFOR | Documented | High | 56 | Opcode confirmed ([##DRIVER.xpl] `XAFOR`). Per-value instruction for list-form `DO FOR`, empirically confirmed this session |
| 0x016 | CTST | Documented | High | 53 | Opcode confirmed ([##DRIVER.xpl] `XCTST`). `DO WHILE`/`DO UNTIL` per-cycle condition test, empirically confirmed this session |
| 0x017 | ADLP | Documented | High | 89 | Opcode confirmed ([##DRIVER.xpl] `XADLP`); Optimizer-HALMAT-era arrayness-specifier changes documented from IR-60-5 A-113. [MSC-01847] confirms the concept ("arrayness specifier", bracketing array-processing loops with a closing DLPE) at HAL-1971 opcode 0x00D |
| 0x018 | DLPE | Documented | High | 90 | Opcode confirmed ([##DRIVER.xpl] `XDLPE`); [MSC-01847] "DLPE"/"end of array- and structureness specification" at HAL-1971 opcode 0x00E |
| 0x019 | DSUB | Documented | High | 93/101 | Opcode confirmed ([##DRIVER.xpl] `XDSUB`); consolidates 9 separate HAL-1971 subscript-specifier instructions (ALC/ALCE/RALC + TASB/TIDX/TTSB + AASB/AIDX/ATSB + SASB/SIDX/STSB) into one opcode — see DSUB.md's Source Analysis. Array-dimension "index"/"asterisk" subscript kinds now empirically confirmed too (previously primary-source-only) |
| 0x01A | IDLP | Documented | High | 90 | Opcode confirmed ([##DRIVER.xpl] `XIDLP`). `STATIC`/default counterpart of [ADLP](class-0/ADLP.md) — both describe a multi-element array's shape during uniform-single-value initialization, chosen by the array's `AUTOMATIC`/`STATIC` attribute; found via direct compiler-source inspection (`ICQARRA2.xpl`) after 4 syntax hypotheses failed, then empirically confirmed — see [IDLP](class-0/IDLP.md) |
| 0x01B | TSUB | Documented | High | 92/100 | Opcode confirmed ([##DRIVER.xpl] `XTSUB`). Structure-copy subscript specifier (both single-copy and range forms), empirically confirmed this session |
| 0x01D | PCAL | Documented | High | 61 | **Opcode now confirmed primary-source** ([##DRIVER.xpl] `XPCAL`) — this was previously a Low-confidence speculative mnemonic mapping (see PCAL.md); now verified exactly right. Behavioral description still drawn from HAL-1971's CALL (0x029) |
| 0x01E | FCAL | Documented | High | 61 | **Opcode now confirmed primary-source** ([##DRIVER.xpl] `XFCAL`) — same upgrade as PCAL; see FCAL.md |
| 0x01F | READ | Documented | High | 62 | Opcode confirmed ([##DRIVER.xpl] `XREAD`, array-indexed together with RDAL/WRIT — see note below). [MSC-01847] "READ"/"read header" at HAL-1971 opcode 0x02A. **Corrected this session**: carries the device number as its own `IMD` operand (previously misattributed to [XXST](class-0/XXST.md); see [READ](class-0/READ.md)) |
| 0x020 | RDAL | Documented | High | 62 | Opcode confirmed ([##DRIVER.xpl] `XREAD` array element 1). [MSC-01847] "RDAL"/"read-all header" at HAL-1971 opcode 0x02F. **Corrected this session**: carries the device number as its own `IMD` operand; see [RDAL](class-0/RDAL.md) |
| 0x021 | WRIT | Documented | High | 63 | Opcode confirmed ([##DRIVER.xpl] `XREAD` array element 2). [MSC-01847] "WRIT"/"write header" at HAL-1971 opcode 0x02B. **Corrected this session**: carries the device number as its own `IMD` operand; see [WRIT](class-0/WRIT.md) |
| 0x022 | FILE | Documented | High | 63 | Opcode confirmed ([##DRIVER.xpl] `XFILE`). Statement syntax confirmed [USA003087] §22.2; device/channel encoding empirically confirmed (does not use XXST/XXAR/XXND). [MSC-01847] "FILE"/"file i/o specifier" at HAL-1971 opcode 0x034, mechanism differs |
| 0x025 | XXST | Documented | High | 58 | I/O statement start; carries the I/O-statement-kind code (0=READ/1=READALL/2=WRITE) as its only `IMD` operand — see [XXST](class-0/XXST.md). **Corrected this session**: the device number is on READ/RDAL/WRIT itself, not here (see below) |
| 0x026 | XXND | Documented | High | 59 | I/O statement end — see [XXND](class-0/XXND.md), empirically confirmed |
| 0x027 | XXAR | Documented | High | 58/100 | I/O statement argument — see [XXAR](class-0/XXAR.md), empirically confirmed. Its trailing tag field also carries HAL-1971's `FCLM`/`FLIN`/`FPGE`/`FSKP`/`FTAB` I/O-control-specifier kind, for READ/READALL/WRITE argument lists |
| 0x02A | TDEF | Documented | High | 8 | Opcode confirmed ([##DRIVER.xpl] `XTDEF`). [MSC-01847] "TDEF" at HAL-1971 opcode 0x035 corroborates the role |
| 0x02B | MDEF | Documented | High | 8 | Opcode confirmed ([##DRIVER.xpl] `XMDEF`). [MSC-01847] "MDEF" at HAL-1971 opcode 0x036 corroborates the role |
| 0x02C | FDEF | Documented | High | 8 | Opcode confirmed ([##DRIVER.xpl] `XFDEF`). [MSC-01847] "FDEF" is at the *same* opcode in HAL 1971 — a rare exact match |
| 0x02D | PDEF | Documented | High | 8 | Opcode confirmed ([##DRIVER.xpl] `XPDEF`). HAL 1971 has no distinct PDEF; see PDEF.md |
| 0x02E | UDEF | Documented | High | 9 | Opcode confirmed ([##DRIVER.xpl] `XUDEF`). [MSC-01847] "UDEF" at HAL-1971 opcode 0x033, paired with "UEND" (HAL-1971 0x037, no confirmed HAL/S opcode) |
| 0x02F | CDEF | Documented | High | 9 | Opcode confirmed ([##DRIVER.xpl] `XCDEF`). `COMPOOL` block definition header, empirically confirmed this session |
| 0x030 | CLOS | Documented | High | 9 | Opcode confirmed ([##DRIVER.xpl] `XCLOS`); empirically confirmed (`CLOSE FTEST;`), one SYT operand referencing the closed block. No distinct HAL-1971 analog identified — HAL 1971's RTRN (0x030 in that scheme) appears to serve the closing role instead |
| 0x031 | EDCL | Documented | High | 9 | Opcode confirmed ([##DRIVER.xpl] `XEDCL`); "end of declarations" marker, mnemonic reading and trailing-tag meaning confirmed directly from `SYNTHESI.xpl`'s `<BLOCK BODY>` grammar rule — see [EDCL](class-0/EDCL.md) |
| 0x032 | RTRN | Documented | High | 11 | Opcode confirmed ([##DRIVER.xpl] `XRTRN`). [MSC-01847] "RTRN" at HAL-1971 opcode 0x030; per §3.5.1, "the close of a procedure always generates a RTRN instruction, even though the last executable statement in the procedure body was a return" |
| 0x033 | TDCL | Documented | High | 10 | Opcode confirmed ([##DRIVER.xpl] `XTDCL`). `TEMPORARY` data-item declaration (§26.3) — identified directly by the user after structures/COMPOOL/templates were ruled out; empirically confirmed this session |
| 0x034 | WAIT | Documented | High | 81 | Opcode confirmed ([##DRIVER.xpl] `XWAIT`); `WAIT` statement (all 3 forms), empirically confirmed this session |
| 0x035 | SGNL | Documented | High | 81 | Opcode confirmed ([##DRIVER.xpl] `XSGNL`); `SIGNAL` statement, empirically confirmed this session |
| 0x036 | CANC | Documented | High | 82 | Opcode confirmed ([##DRIVER.xpl] `XCANC`); `CANCEL` statement (self and named forms), empirically confirmed this session |
| 0x037 | TERM | Documented | High | 82 | Opcode confirmed ([##DRIVER.xpl] `XTERM`). [MSC-01847] "TERM" at HAL-1971 opcode 0x032 |
| 0x038 | PRIO | Documented | High | 83 | Opcode confirmed ([##DRIVER.xpl] `XPRIO`); **is the `UPDATE PRIORITY` statement, not the `PRIO` built-in function** (which uses [BFNC](class-0/BFNC.md) instead) — empirically confirmed this session |
| 0x039 | SCHD | Documented | High | 83/84 | Opcode confirmed ([##DRIVER.xpl] `XSCHD`); `SCHEDULE` statement, empirically confirmed for the base form, and the trailing-tag bitmask fully decoded from `SYNTHESI.xpl`'s `<SCHEDULE HEAD>`/`<SCHEDULE PHRASE>`/`<SCHEDULE CONTROL>` grammar rules — see [SCHD](class-0/SCHD.md) |
| 0x03C | ERON | Documented | High | 80 | Opcode confirmed ([##DRIVER.xpl] `XERON`); handles **all** `ON ERROR`/`OFF ERROR` forms (SYSTEM/IGNORE/user-statement/OFF), empirically confirmed this session |
| 0x03D | ERSE | Documented | High | 80 | Opcode confirmed ([##DRIVER.xpl] `XERSE`). `SEND ERROR` statement (§25.3, error simulation/signaling) — a genuinely distinct statement from `ON ERROR`/`OFF ERROR`, found only after exhaustively ruling out 11 variations of the latter; empirically confirmed this session |
| 0x040 | MSHP | Documented | High | 76 | Opcode confirmed ([##DRIVER.xpl] `XMSHP` array element 0); `MATRIX(vec1,vec2,...)` shaping function (row-vector argument form, found via the compiler's own regression-test corpus), empirically confirmed — see [MSHP](class-0/MSHP.md) |
| 0x041 | VSHP | Documented | High | 76 | Opcode confirmed ([##DRIVER.xpl] `XMSHP` array element 1). `VECTOR(...)` shaping function, empirically confirmed this session |
| 0x042 | SSHP | Documented | High | 74 | Opcode confirmed ([##DRIVER.xpl] `XMSHP` array element 2). List-form `SCALAR(...)` shaping function, empirically confirmed this session |
| 0x043 | ISHP | Documented | High | 75 | Opcode confirmed ([##DRIVER.xpl] `XMSHP` array element 3). List-form `INTEGER(...)` shaping function, empirically confirmed this session |
| 0x045 | SFST | Documented | High | 59 | Opcode confirmed ([##DRIVER.xpl] `XSFST`). [MSC-01847] "SFST" at HAL-1971 opcode 0x04A — brackets type-conversion "shaping function" invocations like BIT(...), CHAR(...), VECTOR(...), MATRIX(...) |
| 0x046 | SFND | Documented | High | 60 | Opcode confirmed ([##DRIVER.xpl] `XSFND`). [MSC-01847] "SFND" at HAL-1971 opcode 0x04C |
| 0x047 | SFAR | Documented | High | 60 | Opcode confirmed ([##DRIVER.xpl] `XSFAR`). [MSC-01847] "SFAR" at HAL-1971 opcode 0x04B |
| 0x04A | BFNC | Documented | High | 64 | Opcode confirmed ([##DRIVER.xpl] `XBFNC`); Optimizer-HALMAT-era SINCOS special case documented from IR-60-5 A-112, now also empirically confirmed this session for the `PRIO` built-in function. Confirms HAL/S's split-off of HAL 1971's FUNC (which handled both user and built-in function invocation together) — see [FCAL](class-0/FCAL.md) |
| 0x04B | LFNC | Documented | High | — | **New** — not in [IR-60-5]'s partial index. Opcode confirmed ([##DRIVER.xpl] `XLFNC`). The `MAX`/`MIN` built-in functions specifically (a separate "L-FUNC" dispatch category from [BFNC](class-0/BFNC.md), found by grepping the compiler source tree for `XLFNC` usage) — see [LFNC](class-0/LFNC.md) |
| 0x04D | TNEQ | Documented | High | — | Opcode confirmed ([##DRIVER.xpl] `XTEQU` array element 1). Structure `¬=` comparison, empirically confirmed this session (delegates to the same runtime routine `#QCSTRUC` as TEQU). [MSC-01847] describes an identically-named "structure not equal" instruction, but at HAL-1971 opcode 0x044 |
| 0x04E | TEQU | Documented | High | — | Opcode confirmed ([##DRIVER.xpl] `XTEQU` array element 0). Structure `=` comparison, empirically confirmed this session (delegates to runtime routine `#QCSTRUC`). [MSC-01847] "structure equal" at HAL-1971 opcode 0x045 |
| 0x04F | TASN | Documented | High | — | Opcode confirmed ([##DRIVER.xpl] `XXASN` array element 9, alongside the BASN/CASN/MASN/VASN/SASN/IASN family below). Structure assign, empirically confirmed this session. [MSC-01847] "structure assign" at HAL-1971 opcode 0x038 |
| 0x051 | IDEF | Documented | High | — | **New** — not in [IR-60-5]'s partial index. Opcode confirmed ([##DRIVER.xpl] `XIDEF`). Inline function definition header ([USA003087] §29.5), empirically confirmed this session — see [IDEF](class-0/IDEF.md) |
| 0x052 | ICLS | Documented | High | — | **New.** Opcode confirmed ([##DRIVER.xpl] `XICLS`), immediately after IDEF — confirmed as its closing counterpart (compare MDEF/CLOS), empirically confirmed this session — see [ICLS](class-0/ICLS.md) |
| 0x055 | NNEQ | Documented | High | — | Opcode confirmed ([##DRIVER.xpl] `XNEQU` array element 1). "N" confirmed to mean `NAME` (pointer) — `¬=` comparison of `NAME` pseudo-functions, empirically confirmed this session |
| 0x056 | NEQU | Documented | High | — | Opcode confirmed ([##DRIVER.xpl] `XNEQU` array element 0). `NAME` (pointer) `=` comparison, empirically confirmed this session; see [NNEQ](class-0/NNEQ.md) |
| 0x057 | NASN | Documented | High | — | Opcode confirmed ([##DRIVER.xpl] `XNASN`). `NAME` (pointer) assign, empirically confirmed this session |
| 0x059 | PMHD | Documented | High | — | **New** — not in [IR-60-5]'s partial index. Opcode confirmed ([##DRIVER.xpl] `XPMHD`). `%macro` invocation header (`%SVC(...)` etc., [USA003087] §31.1) — found by grepping the compiler source tree for `XPMHD` usage, leading to the exact grammar rule in `SYNTHESI.xpl` — see [PMHD](class-0/PMHD.md) |
| 0x05A | PMAR | Documented | High | — | Opcode confirmed ([##DRIVER.xpl] `XPMAR`). `%macro` invocation argument; see [PMHD](class-0/PMHD.md) |
| 0x05B | PMIN | Documented | High | — | Opcode confirmed ([##DRIVER.xpl] `XPMIN`). `%macro` invocation end; see [PMHD](class-0/PMHD.md) |

74 known Class 0 opcodes now inventoried (62 from [IR-60-5]'s index + 12 new
from [##DRIVER.xpl]: LFNC, TNEQ, TEQU, TASN, IDEF, ICLS, NNEQ, NEQU, NASN,
PMHD, PMAR, PMIN); **all 74 have files, and — as of this session — all 74
are behaviorally resolved** (see `class-0/`). The last four holdouts
(`IDLP`, `PMHD`/`PMAR`/`PMIN`, `LFNC`) were each cracked by abandoning
syntax-guessing in favor of grepping the full compiler source tree for
every site referencing the opcode's `X`-prefixed constant — a
consistently higher-yield technique than testing HAL/S constructs blind,
across every opcode it was tried on this session. Every opcode is now
primary-source confirmed via [##DRIVER.xpl] except the handful that were
only ever known from [IR-60-5]'s index and haven't been independently
cross-checked yet — in practice this means essentially all Class 0 opcodes
above are now High confidence *for the opcode number itself*, and (as of
this session) all 74 also carry a confirmed behavioral description; no
"Not started" rows remain anywhere in Class 0 or Class 8.

**LIST, LSTE, and CASS resolved — not missing opcodes at all.** A
targeted grep for `XLSTE`/`XCASS`/`XZRFN`/`XASIZ`/`XTSIZ`/`XFASN`/`XUEND`
across the full `PASS.REL32V0` tree found none of them declared under
those names anywhere. But [XXST](class-0/XXST.md)/[XXAR](class-0/XXAR.md)/
[XXND](class-0/XXND.md) — already fully documented in an earlier
session as a "generic bracketed argument list" construct covering both
I/O statements (`READ`/`RDAL`/`WRIT`) and procedure/function calls — turn
out to also cover `CALL ... ASSIGN(...)`'s assign-parameter list, per
[XXST](class-0/XXST.md)'s own worked trace (`XXAR` with a trailing
sub-flag `0`=input vs. `1`=assign argument, no separate header opcode).
This means HAL-1971's `LIST`/`LSTE`/`CASS` were folded into HAL/S's
`XXST`/`XXAR`/`XXND` family under new names, not left unopcoded — the
gap in this project's inventory was a cross-referencing gap, not a
missing primary-source fact.

**Instructions found in [MSC-01847] §2.10–2.15 still with no confirmed
HAL/S opcode:** ENDS, ENTS, EXTS (static bypass block markers —
referenced from [STRI](class-8/STRI.md)); FCLM, FLIN, FPGE, FSKP, FTAB
(I/O column/line/page/skip/tab control specifiers); FASN (file-assignment,
companion to [FILE](class-0/FILE.md)); UEND (update-block end, companion
to [UDEF](class-0/UDEF.md)); ZRFN (receiver/pseudo-variable function
invocation); ASIZ, TSIZ (shaping function arrayness/terminal-size
specifiers). Confirmed this session: none of these are declared under
their own name (`XENDS`/`XENTS`/`XEXTS`/`XFCLM`/`XFLIN`/`XFPGE`/`XFSKP`/
`XFTAB`/`XFASN`/`XUEND`/`XZRFN`/`XASIZ`/`XTSIZ`) anywhere in the
`PASS.REL32V0` tree, nor hiding as an unnamed array element near a
conceptually-related opcode (checked `XFILE`, `XUDEF`, `XSFST`/`XSFAR`/
`XSFND`). Also found: unexplained numeric gaps at 0x023/0x024 (between
`XFILE`=0x022 and `XXXST`=0x025) and 0x03A/0x03B (between `XSCHD`=0x039
and `XERON`=0x03C) in Class 0's opcode space — plausibly where some of
these would sit if HAL/S ever used them, but no declared constant fills
either gap in this compiler build, so this remains inconclusive rather
than a positive identification (all three `##DRIVER.xpl` copies — PASS1,
OPT, PASS2 — were checked this session; none declare anything at these
opcodes or under the `X`-prefixed names below).

**`FCLM`/`FLIN`/`FPGE`/`FSKP`/`FTAB` resolved this session — hypothesis
(2) confirmed.** They're folded into [XXAR](class-0/XXAR.md)'s existing
trailing tag field (`TAG2`), the same field already known to distinguish
a CALL argument's input/assign role — for a `READ`/`READALL`/`WRITE`
argument list, that field instead carries an I/O-control-specifier kind
code (`0`=plain argument, `1`=`TAB`, `2`=`COLUMN`, `3`=`SKIP`, `4`=`LINE`,
`5`=`PAGE`), found by reading `SYNTHESI.xpl`'s `<IO CONTROL>` grammar
rule and `HALMATF3.xpl`'s `HALMAT_FIX_PIPTAGS` procedure, then confirmed
by compiling `READ`/`READALL`/`WRITE` statements using all five
specifiers — each drives a distinct PASS2 runtime call (`#QTAB`/
`#QCOLUMN`/`#QSKIP`/`#QLINE`/`#QPAGE`). No change to
[XXST](class-0/XXST.md)/[XXND](class-0/XXND.md)/[READ](class-0/READ.md)/
[RDAL](class-0/RDAL.md)/[WRIT](class-0/WRIT.md) was needed — they still
carry the same operand structure documented previously, confirmed to
hold even with I/O control specifiers present. This is the same
consolidation pattern as `LIST`/`LSTE`/`CASS`→XXST/XXAR/XXND. See
[XXAR](class-0/XXAR.md) for the full mechanism and worked traces.

**`FASN` (file assignment, HAL 1971's companion to `FILE`) now resolved,
with a documented reason for its absence.** Not a declared `##DRIVER.xpl`
opcode under any pass, not hiding in XXAR's `TAG2` the way the five
specifiers above were, and `SYNTHESI.xpl`'s grammar defines only
[FILE](class-0/FILE.md)'s two `FILE(n,addr)=exp` / `var=FILE(n,addr)`
forms — no `FILE ... ASSIGN` construct exists in HAL/S's grammar at all.
[USA00309]'s (HAL/S-FC User's Manual) §6.1.4 "JCL Considerations"
confirms why: device numbers 2–9 (also used by plain `READ`/`WRITE`, not
just `FILE`) map to a **fixed** JCL DD name, `CHANNELn`, resolved once
per job by DD cards supplied outside the HAL/S program — the
channel-to-dataset association was never a per-statement HAL/S-level
concept in HAL/S-FC, so no HALMAT instruction (FASN's role or otherwise)
was ever needed for it. Consistent with [FILE](class-0/FILE.md)'s
existing finding that HAL/S-FC's own runtime doesn't support `FILE` I/O.

**Open question:** HAL/S's structureness-specifier instruction (the
counterpart to [ADLP](class-0/ADLP.md) for multiple-copy structure
terminals, analogous to HAL-1971's SDLP) does not appear in [IR-60-5]'s
62-entry Class 0 index at all. Either HAL/S folded structureness handling
into ADLP itself (i.e. ADLP handles both arrayness and structureness
dimensions, distinguished by an operand qualifier), or a Class 0 opcode
already in the index (not yet identified) serves this role, or the index
itself is incomplete.

## Classes 1–7 — general note

As of this session, HAL/S opcodes for Classes 1–7 are **primary-source
confirmed** via [##DRIVER.xpl] (the compiler's own opcode-constant table),
superseding the previous approach of using [MSC-01847]'s HAL-1971 opcodes
as a stand-in. Tables below show the confirmed HAL/S opcode first, with
the HAL-1971 opcode from [MSC-01847] alongside for comparison — many
match exactly, some don't (noted per class). Behavioral descriptions
still lean on [MSC-01847]'s predecessor-language prose (Medium confidence
for behavior) except where a HAL/S-specific detail was found directly.
None of these are written up as instruction files yet (see "Next steps").
[Halmat.pdf] separately claims a full HAL/S reconstruction for all of
Classes 1–8; still not reviewed or cross-checked against the tables below.

## Class 1 — Bit Operations

13 of 13 known opcodes now have files (see `class-1/`): the 5 core bit
operators, the full `XBTOB` "convert to bit" family (`BTOB`/`CTOB`/
`STOB`/`ITOB`), and the parallel `XBTOQ` family (`BTOQ`/`CTOQ`/`STOQ`/
`ITOQ`) — resolved as the `SUBBIT` pseudo-conversion function
([USA003087] §21.5), found by grepping the compiler source tree for
`XBTOQ` usage; `STOQ`/`ITOQ` empirically confirmed, `BTOQ`/`CTOQ`
inferred by strong analogy (see [BTOQ](class-1/BTOQ.md)).

| HAL/S opcode | Mnemonic | HAL-1971 opcode | Status | Notes |
|---|---|---|---|---|
| 0x101 | BASN | 0x101 (match) | Documented (High) | bit-string assign |
| 0x102 | BAND | 0x102 (match) | Documented (High) | bit-string and |
| 0x103 | BOR | 0x103 (match) | Documented (High) | bit-string or |
| 0x104 | BNOT | 0x104 (match) | Documented (High) | bit-string complement |
| 0x105 | BCAT | 0x105 (match) | Documented (High) | bit-string catenate |
| 0x121 | BTOB | — (new) | Documented (High) | Bit-length conversion (self slot of the `XBTOB` "convert to bit" family), triggered by `BIT(...)` shaping function, empirically confirmed; see [BTOB](class-1/BTOB.md) |
| 0x141 | CTOB | — (new) | Documented (High) | Character to bit conversion, incl. subscripted-result form; see [CTOB](class-1/CTOB.md) |
| 0x1A1 | STOB | — (new) | Documented (High) | Scalar to bit conversion, `BIT(...)` shaping function, empirically confirmed; see [STOB](class-1/STOB.md) |
| 0x1C1 | ITOB | — (new) | Documented (High) | Integer to bit conversion, `BIT(...)` shaping function, empirically confirmed; see [ITOB](class-1/ITOB.md) |
| 0x122 | BTOQ | — (new) | Documented (High) | `XBTOQ` array element 0. `SUBBIT` pseudo-conversion (§21.5) for a BIT STRING argument, empirically confirmed this session; see [BTOQ](class-1/BTOQ.md) |
| 0x142 | CTOQ | — (new) | Documented (High) | `XBTOQ` array element 1. `SUBBIT` pseudo-conversion for a CHARACTER argument, empirically confirmed this session; see [CTOQ](class-1/CTOQ.md) |
| 0x1A2 | STOQ | — (new) | Documented (High) | `XBTOQ` array element 4. `SUBBIT` pseudo-conversion for a SCALAR argument, empirically confirmed this session; see [STOQ](class-1/STOQ.md) |
| 0x1C2 | ITOQ | — (new) | Documented (High) | `XBTOQ` array element 5. `SUBBIT` pseudo-conversion for an INTEGER argument, empirically confirmed this session in both reference and assignment context; see [ITOQ](class-1/ITOQ.md) |

All 5 core bit-class opcodes match HAL-1971 exactly. Related, classed
elsewhere: BTOI (0x621, class 6), BTOS (0x521, class 5), BEQU/BNEQ (0x726/
0x725, class 7 — **differs** from HAL-1971's 0x722/0x721), BINT (0x821,
class 8 — see [BINT](class-8/BINT.md)), BBRA (0x013, class 0). This
cross-class placement-by-result-type pattern (a conversion or comparison
operator is classed by its *result* type, not its operand type) is
confirmed throughout Classes 1–7.

## Class 2 — Character Operations

**All 6 known opcodes now documented** (see `class-2/`), including
[BTOC](class-2/BTOC.md) and [CTOC](class-2/CTOC.md), resolved in a
follow-up session (see "Unknown-behavior opcodes" below).

| HAL/S opcode | Mnemonic | HAL-1971 opcode | Status | Notes |
|---|---|---|---|---|
| 0x201 | CASN | 0x201 (match) | Documented (High) | character assign |
| 0x202 | CCAT | 0x202 (match) | Documented (High) | character catenate |
| 0x221 | BTOC | — (new) | Documented (High) | Bit to character conversion, `CHARACTER(...)` shaping function, empirically confirmed; see [BTOC](class-2/BTOC.md) |
| 0x241 | CTOC | — (new) | Documented (High) | Character-length conversion (self slot), `CHARACTER(...)` shaping function, empirically confirmed; see [CTOC](class-2/CTOC.md) |
| 0x2A1 | STOC | 0x2A1 (match) | Documented (High) | scalar to character conversion |
| 0x2C1 | ITOC | 0x2C1 (match) | Documented (High) | integer to character conversion |

Related, classed elsewhere: CEQU/CNEQ/CGT/CNGT/CLT/CNLT (0x746/0x745/
0x748/0x747/0x74A/0x749, class 7 — **differs** from HAL-1971's 0x742/
0x741/0x744/0x743/0x746/0x745), CINT (0x841, class 8 — see
[CINT](class-8/CINT.md)).

## Class 3 — Matrix Arithmetic

**All 11 known opcodes now documented** (see `class-3/`): MASN, MTRA,
MNEG, MADD, MSUB, MMPR, VVPR, MSPR, MSDV, MINV — High confidence, behavior
drawn from [MSC-01847]; plus [MTOM](class-3/MTOM.md) — now High
confidence, empirically confirmed.

| HAL/S opcode | Mnemonic | HAL-1971 opcode | Notes |
|---|---|---|---|
| 0x301 | MASN | 0x301 (match) | matrix assign |
| 0x329 | MTRA | 0x329 (match) | matrix transpose |
| 0x341 | MTOM | — (new) | Matrix precision scale, triggered by `exp$(@SINGLE/DOUBLE)` qualifier — Documented (High), empirically confirmed this session; see [MTOM](class-3/MTOM.md) |
| 0x344 | MNEG | 0x344 (match) | matrix negate |
| 0x362 | MADD | 0x362 (match) | matrix add |
| 0x363 | MSUB | 0x363 (match) | matrix subtract |
| 0x368 | MMPR | 0x368 (match) | matrix-matrix product |
| 0x387 | VVPR | 0x387 (match) | vector outer product (result is a matrix, hence classed here despite the "V" mnemonic prefix) |
| 0x3A5 | MSPR | 0x3A5 (match) | matrix multiply-by-scalar |
| 0x3A6 | MSDV | 0x3A6 (match) | matrix divide-by-scalar |
| 0x3CA | MINV | 0x3CA (match) | matrix invert |

Every core matrix-arithmetic opcode matches HAL-1971 exactly (cross-checks
[IR-60-5] A-113's mnemonic list too). Related, classed elsewhere: MEQU/
MNEQ (0x766/0x765, class 7 — **differs** from HAL-1971's 0x762/0x761),
MINT (0x861, class 8 — see [MINT](class-8/MINT.md)).

## Class 4 — Vector Arithmetic

**All 10 known opcodes now documented** (see `class-4/`): VASN, VNEG,
MVPR, VMPR, VADD, VSUB, VCRS, VSPR, VSDV — High confidence, behavior
drawn from [MSC-01847]; plus [VTOV](class-4/VTOV.md) — now High
confidence, empirically confirmed.

| HAL/S opcode | Mnemonic | HAL-1971 opcode | Notes |
|---|---|---|---|
| 0x401 | VASN | 0x401 (match) | vector assign |
| 0x441 | VTOV | — (new) | Vector precision scale, `exp$(@SINGLE/DOUBLE)` qualifier — Documented (High), empirically confirmed this session; see [VTOV](class-4/VTOV.md) |
| 0x444 | VNEG | 0x444 (match) | vector negate |
| 0x46C | MVPR | 0x46C (match) | matrix-vector product (result is a vector, hence classed here despite the "M" mnemonic prefix) |
| 0x46D | VMPR | — | **Correction**: previously inferred as 0x4CD from [MSC-01847]'s HAL-1971 value; [##DRIVER.xpl] confirms HAL/S's actual opcode is 0x46D (`XVMPR`), immediately after MVPR (`XMVPR`=0x46C) — HAL-1971's VMPR was at a different, non-adjacent opcode (0x4CD) |
| 0x482 | VADD | 0x482 (match) | vector add |
| 0x483 | VSUB | 0x483 (match) | vector subtract |
| 0x48B | VCRS | 0x48B (match) | vector cross product |
| 0x4A5 | VSPR | 0x4A5 (match) | vector multiply-by-scalar |
| 0x4A6 | VSDV | 0x4A6 (match) | vector divide-by-scalar |

Related, classed elsewhere: VEQU/VNEQ (0x786/0x785, class 7 — **differs**
from HAL-1971's 0x782/0x781), VINT (0x881, class 8 — see
[VINT](class-8/VINT.md)), VDOT (0x58E, class 5 — see below, also
corrected from an earlier guess).

## Class 5 — Scalar Arithmetic

**All 14 known opcodes now documented** (see `class-5/`): SASN, BTOS,
SIEX, SPEX, VDOT, SADD, SSUB, SSPR, SSDV, SEXP, SNEG, ITOS — High
confidence, behavior drawn from [MSC-01847]; plus
[CTOS](class-5/CTOS.md) and [STOS](class-5/STOS.md) — both now High
confidence, empirically confirmed.

| HAL/S opcode | Mnemonic | HAL-1971 opcode | Notes |
|---|---|---|---|
| 0x501 | SASN | 0x501 (match) | scalar assign |
| 0x521 | BTOS | 0x521 (match) | bit string to scalar conversion |
| 0x541 | CTOS | — (new) | Character to scalar conversion — Documented (High, empirically confirmed); see [CTOS](class-5/CTOS.md) |
| 0x571 | SIEX | 0x571 (match) | scalar exponentiation by integer |
| 0x572 | SPEX | 0x572 (match) | scalar exponentiation by positive integer |
| 0x58E | VDOT | — | **Correction**: previously inferred as 0x581 from [MSC-01847]'s HAL-1971 value; [##DRIVER.xpl] confirms HAL/S's actual opcode is 0x58E (`XVDOT`). Vector dot product, result is scalar, hence classed here |
| 0x5A1 | STOS | — (new) | Scalar precision scale, `exp$(@SINGLE/DOUBLE)` qualifier — Documented (High), empirically confirmed this session; see [STOS](class-5/STOS.md) |
| 0x5AB | SADD | 0x5AB (match) | scalar add |
| 0x5AC | SSUB | 0x5AC (match) | scalar subtract |
| 0x5AD | SSPR | 0x5AD (match) | scalar-scalar multiply |
| 0x5AE | SSDV | 0x5AE (match) | scalar divide |
| 0x5AF | SEXP | 0x5AF (match) | scalar exponentiation-by-scalar |
| 0x5B0 | SNEG | 0x5B0 (match) | scalar negate |
| 0x5C1 | ITOS | 0x5C1 (match) | integer to scalar conversion |

Related, classed elsewhere: SEQU/SNEQ/SGT/SNGT/SLT/SNLT (0x7A6/0x7A5/
0x7A8/0x7A7/0x7AA/0x7A9, class 7 — **matches HAL-1971 exactly**, unlike
most other Class 7 sub-families), SINT (0x8A1, class 8 — see
[SINT](class-8/SINT.md)).

## Class 6 — Integer Arithmetic

**All 10 known opcodes now documented** (see `class-6/`): IASN, INEG,
IADD, ISUB, IIPR, BTOI, STOI — High confidence, behavior drawn from
[MSC-01847]; plus [CTOI](class-6/CTOI.md) (High, empirically confirmed),
[ITOI](class-6/ITOI.md), and [IPEX](class-6/IPEX.md) — all now High
confidence, empirically confirmed.

| HAL/S opcode | Mnemonic | HAL-1971 opcode | Notes |
|---|---|---|---|
| 0x601 | IASN | 0x601 (match) | integer assign |
| 0x621 | BTOI | 0x621 (match) | bit to integer conversion |
| 0x641 | CTOI | — (new) | Character to integer conversion — Documented (High, empirically confirmed); see [CTOI](class-6/CTOI.md) |
| 0x6A1 | STOI | 0x6A1 (match) | scalar to integer conversion |
| 0x6C1 | ITOI | — (new) | Integer precision scale, `exp$(@SINGLE/DOUBLE)` qualifier — Documented (High), empirically confirmed this session; see [ITOI](class-6/ITOI.md) |
| 0x6CB | IADD | 0x6CB (match) | integer add |
| 0x6CC | ISUB | 0x6CC (match) | integer subtract |
| 0x6CD | IIPR | 0x6CD (match) | integer multiply — cross-checks [IR-60-5] A-112's Optimizer-HALMAT note (opcode 0x6CD for "Integer Integer Product"), now triple-confirmed |
| 0x6D0 | INEG | 0x6D0 (match) | integer negate |
| 0x6D2 | IPEX | — (new) | Integer exponentiation by a non-negative integer literal (paired with SPEX at 0x572, per `XSPEX(1)` array) — Documented (High), empirically confirmed this session; see [IPEX](class-6/IPEX.md) |

**Resolved this session**: [MSC-01847] lists a HAL-1971 "IEXP" (integer
exponentiation) at opcode 0x6CF; no `XIEXP`-named constant exists in any
pass's `##DRIVER.xpl`. Tracing `SYNTHESI.xpl`'s `**`-operator synthesis
code directly shows why: HAL/S has **no general integer-base
exponentiation opcode at all**. [IPEX](class-6/IPEX.md) covers only the
narrow base=INTEGER/exponent=non-negative-literal case; every other
INTEGER-base exponentiation (non-literal or negative-literal exponent, or
a SCALAR exponent) is implicitly coerced to SCALAR via
[ITOS](class-5/ITOS.md) and falls through to SIEX/SEXP instead. So
IEXP's role wasn't "absorbed into IPEX" as previously guessed — it was
eliminated by coercion to the existing SCALAR-family opcodes. Related,
classed elsewhere: IEQU/INEQ/IGT/INGT/ILT/
INLT (0x7C6/0x7C5/0x7C8/0x7C7/0x7CA/0x7C9, class 7 — **matches HAL-1971
exactly**), IINT (0x8C1, class 8 — see [IINT](class-8/IINT.md)).

## Class 7 — Conditional and Comparison

**All 28 known opcodes now documented** (see `class-7/`) — High confidence
for opcode, behavior drawn from [MSC-01847] except [BTRU](class-7/BTRU.md)
(a HAL/S-only addition, no HAL-1971 analog — see below the table).

| HAL/S opcode | Mnemonic | HAL-1971 opcode | Notes |
|---|---|---|---|
| 0x720 | BTRU | — (new) | Bit-is-true test (universal bit-string/`EVENT`-in-conditional-context mechanism) — see [BTRU](class-7/BTRU.md) |
| 0x725 | BNEQ | 0x721 (differs) | bit string not equal |
| 0x726 | BEQU | 0x722 (differs) | bit string equal |
| 0x745 | CNEQ | 0x741 (differs) | character not equal |
| 0x746 | CEQU | 0x742 (differs) | character equal |
| 0x747 | CNGT | 0x743 (differs) | character not greater than |
| 0x748 | CGT | 0x744 (differs) | character greater than |
| 0x749 | CNLT | 0x745 (differs) | character not less than |
| 0x74A | CLT | 0x746 (differs) | character less than |
| 0x765 | MNEQ | 0x761 (differs) | matrix not equal |
| 0x766 | MEQU | 0x762 (differs) | matrix equal |
| 0x785 | VNEQ | 0x781 (differs) | vector not equal |
| 0x786 | VEQU | 0x782 (differs) | vector equal |
| 0x7A5 | SNEQ | 0x7A5 (match) | scalar not equal |
| 0x7A6 | SEQU | 0x7A6 (match) | scalar equal |
| 0x7A7 | SNGT | 0x7A7 (match) | scalar not greater than |
| 0x7A8 | SGT | 0x7A8 (match) | scalar greater than |
| 0x7A9 | SNLT | 0x7A9 (match) | scalar not less than |
| 0x7AA | SLT | 0x7AA (match) | scalar less than |
| 0x7C5 | INEQ | 0x7C5 (match) | integer not equal |
| 0x7C6 | IEQU | 0x7C6 (match) | integer equal |
| 0x7C7 | INGT | 0x7C7 (match) | integer not greater than |
| 0x7C8 | IGT | 0x7C8 (match) | integer greater than |
| 0x7C9 | INLT | 0x7C9 (match) | integer not less than |
| 0x7CA | ILT | 0x7CA (match) | integer less than |
| 0x7E2 | CAND | 0x7E2 (match) | logical and |
| 0x7E3 | COR | 0x7E3 (match) | logical or |
| 0x7E4 | CNOT | 0x7E4 (match) | logical not |

All 28 opcodes now primary-source confirmed for HAL/S via [##DRIVER.xpl].
[IR-60-5] A-111's claim that Class 7 spans 0x725 (BNEQ) to 0x7CA (ILT)
covers the HAL-1971-derived core exactly at both ends (previously only
the upper bound matched when compared against HAL-1971's BNEQ);
[BTRU](class-7/BTRU.md) at 0x720 sits just below that range and has no
HAL-1971 counterpart, so it's not a discrepancy with the [IR-60-5] claim,
just an addition outside its scope. Interesting pattern:
bit/character/matrix/vector compares were renumbered between HAL-1971 and
HAL/S, but scalar/integer/logical compares were not — no explanation
found yet for why only those families were left alone.

## Class 8 — Initialization

Full mnemonic/opcode inventory below is doubly primary-source confirmed:
[IR-60-5] A.2 (the Class 8 operator index, p. A-109) and [##DRIVER.xpl]
(`XSTRI`/`XSLRI`/`XELRI`/`XETRI`/`XBINT`-family constants) agree on every
opcode. None of the HAL/S individual instruction description pages
(85–99) have been reviewed yet; most rows marked "Documented" were
originally written from [MSC-01847]'s description of the analogous
HAL-1971 instruction, though `SLRI`/`ELRI`/`ETRI` and `NINT` are now also
independently confirmed directly against real compiled HALMAT (see each
file's Source Analysis section).

**This is the strongest cross-language match found in the project so
far:** HAL-1971's Class-8 opcodes agree with HAL/S's *exactly* for every
data-type-initialize instruction — 0x01, 0x21, 0x41, 0x61, 0x81, 0xA1,
0xC1 all match, now confirmed via both [IR-60-5] and [##DRIVER.xpl]
independently. Only opcodes 0x02/0x03 have different mnemonics between the
two versions (HAL/S SLRI/ELRI vs. HAL-1971 DLPI/DLEI) despite matching
slots and closely related concepts ("loop" initializer forms of the STRI
mechanism); HAL/S's NINT/TINT/EINT (0xE1–0xE3) have no HAL-1971
counterpart at all, consistent with HAL/S having added data types/features
beyond the 1971 language.

| Opcode | Mnemonic | Status | Confidence | IR-60-5 pg. | Notes |
|---|---|---|---|---|---|
| 0x01 | STRI | Documented | High | 85 | Opcode doubly confirmed ([IR-60-5] + [##DRIVER.xpl] `XSTRI`). [MSC-01847] "STRI"/"repeated initialize specifier" at the *same* opcode in HAL 1971 |
| 0x02 | SLRI | Documented | High | 86 | Opcode doubly confirmed (`XSLRI`). Start of a repeated-initialize sequence (`n#value` in `INITIAL(...)`, §16.2), empirically confirmed this session (fully unrolled for `STATIC` data — 1000 SINT/ELRI pairs for a 1000-element test array). Slot matches HAL-1971's DLPI ("initialize loop header") |
| 0x03 | ELRI | Documented | High | 86 | Opcode doubly confirmed (`XELRI`). Per-element close of a repeated-initialize sequence, empirically confirmed this session. Slot matches HAL-1971's DLEI ("initialize loop end") |
| 0x04 | ETRI | Documented | High | 85 | Opcode doubly confirmed (`XETRI`). Close of the whole repeated-initialize sequence, empirically confirmed this session; no HAL-1971 analog identified at this slot |
| 0x21 | BINT | Documented | High | 87 | Opcode doubly confirmed (`XBINT` array element 0). [MSC-01847] "BINT" at the *same* opcode |
| 0x41 | CINT | Documented | High | 87 | Opcode doubly confirmed (`XBINT` array element 1). [MSC-01847] "CINT" at the *same* opcode |
| 0x61 | MINT | Documented | High | 87 | Opcode doubly confirmed (`XBINT` array element 2). [MSC-01847] "MINT" at the *same* opcode |
| 0x81 | VINT | Documented | High | 87 | Opcode doubly confirmed (`XBINT` array element 3). [MSC-01847] "VINT" at the *same* opcode |
| 0xA1 | SINT | Documented | High | 87 | Opcode doubly confirmed (`XBINT` array element 4). [MSC-01847] "SINT" at the *same* opcode |
| 0xC1 | IINT | Documented | High | 87 | Opcode doubly confirmed (`XBINT` array element 5). [MSC-01847] "IINT" at the *same* opcode |
| 0xE1 | NINT | Documented | High | 98/99 | Opcode doubly confirmed (`XNINT`). `NAME` (pointer) initialize, empirically confirmed this session (both real-pointer and `NULL` forms); no HAL-1971 analog (opcode range 0xE1-0xE3 unused in HAL 1971's Class 8) |
| 0xE2 | TINT | Documented | High | 87 | Opcode doubly confirmed (`XTINT`). Structure-terminal initialize for a whole-structure `INITIAL(...)` list ([USA003087] §19.6), bracketed by [STRI](class-8/STRI.md)/[ETRI](class-8/ETRI.md); found by grepping the compiler source tree for `XTINT`, leading to `ICQCHECK.xpl`'s `ICQ_CHECK_TYPE` dispatch. No HAL-1971 analog. **Note**: a `unHALMAT.py` cross-check found only *one* TINT emitted for a 2-terminal/2-value test case; traced to `ICQOUTPU.xpl`'s `ICQ_OUTPUT` procedure, which coalesces consecutive initial-constant values (whose literal-table and slot positions are both sequential) into a single instruction, encoding the run count in the literal operand's tag — a genuine optimization, not a gap. See [TINT](class-8/TINT.md) |
| 0xE3 | EINT | Documented | High | 87 | Opcode doubly confirmed (`XEINT`). `EQUATE EXTERNAL <id> TO <variable>;` statement — an undocumented-in-prose HAL/S declaration (only its reserved word appears in [USA003087]'s index) that aliases a new local name to a same-block variable, apparently for external/linker naming purposes; empirically confirmed this session by grepping the compiler source tree for `XEINT`, leading to `SYNTHESI.xpl`'s `<DECLARE ELEMENT> ::= EQUATE EXTERNAL <IDENTIFIER> TO <VARIABLE> ;` grammar rule. No HAL-1971 analog |

13 of 13 known Class 8 opcodes inventoried; **all 13 now documented**
(all at High confidence for the opcode itself; `SLRI`/`ELRI`/`ETRI`/
`NINT`/`TINT`/`EINT` all empirically confirmed behaviorally this
session's sweep, the last two via the compiler-source-tree-grep
technique).

## HAL/S I/O device numbers — READ/WRITE and FILE both resolved

A question about how logical device numbers (e.g. the `6` in `WRITE(6)
...`) get encoded in HALMAT was investigated empirically across two
sessions by compiling `READ(5) I1; WRITE(6) S1;` with
`HALSFC --parms="LSTALL"`. This produced two opcodes previously
undocumented — [XXST](class-0/XXST.md) (0x025) and [XXAR](class-0/XXAR.md)
(0x027) — and confirmed the general bracketed-argument-list construct
(`XXST` → one `XXAR` per argument → the READ/RDAL/WRIT header →
[XXND](class-0/XXND.md), 0x026).

**Where exactly the device number lives was gotten wrong in an
intermediate session, then corrected.** The first pass concluded the
device number sits on XXST as a second `IMD` operand, alongside an
I/O-statement-kind code (0=READ, 2=WRITE) — this matched what
`pass2.rpt`'s `LSTALL` text report visually appeared to show. A later
session, cross-checking the same compiled binary directly with
`unHALMAT.py` (run with `HALSFC --parms="LISTING2,LSTALL"`, from inside
the results directory containing `halmat.bin`, per direct guidance on
how to get source/symbol-annotated output from that tool), found this
wrong: **XXST carries only the kind code**; the device number is on
READ/RDAL/WRIT's *own* operand. The `pass2.rpt` report prints each
operand directly below the instruction it visually follows, not
necessarily the one it belongs to — only the operand's own `:0.N`
stream-position tag (which the intermediate session didn't check
closely enough) reveals the true owner, and in this case READ's
device-number operand was tagged with a position number *after* READ's
own header line, not XXST's. This is the same category of report
print-ordering artifact already known for `SMRK` (see "Compiler report
switches" above) — caught this time by cross-referencing an independent
tool (`unHALMAT.py`) reading the raw binary directly, which has no such
ambiguity. XXST/READ/RDAL/WRIT/XXAR were all corrected accordingly; see
those files' Source Analysis sections for the full account. **Lesson for
future sessions**: when `pass2.rpt` shows an operand line following an
instruction, verify its `:0.N` position tag against the *next*
instruction's own position before attributing it — or better, cross-check
against `unHALMAT.py` directly, which doesn't have this ambiguity.

**`FILE`'s device-number space is now resolved too.** The correct
statement syntax was located this session via direct guidance to
[USA003087] §22.2 (PDF pp. 275–279): `FILE(n, address) = exp;` (write
mode) and `var = FILE(n, address);` (read mode), where `n` is a
random-access "channel" code (0–9) and `address` an integer record
address — a completely separate concept from READ/WRITE's sequential
device numbers, confirmed at both the language level (§22.2) and the
HALMAT level. Compiling `FILE(3, 7) = S1;` / `I1 = FILE(4, 8);` with
`HALSFC --parms="LSTALL"` showed that **FILE does not route through
XXST/XXAR/XXND at all**. **Fully resolved in a later session** (via a
direct `unHALMAT.py` binary read cross-checked against `unLitfile.py`'s
literal-table decode): FILE's own two operands are a literal-table
reference — confirmed to be the record address itself, not an
unidentified type/format descriptor as first guessed — and a
symbol-table reference to the transferred variable; the channel code
turned out to be the operator word's own `TAG` field, not a
separate operand at all. Both values are *also* independently baked
into the generated object code as immediate constants passed to runtime
routines `#QFILEOUT`/`#QFILEIN` (PASS2 choosing immediate-constant
codegen for compile-time-known values rather than a runtime lookup) —
see [FILE](class-0/FILE.md) for the full account. The write-mode FILE statement in the test
program happened to be preceded by a previously-undocumented no-operand
instruction, now named [EDCL](class-0/EDCL.md) (0x031) — this initially
looked FILE-specific but a follow-up test (see "DO CASE construct" below)
showed it's actually a general end-of-declarations marker, unrelated to
`FILE`. As a byproduct of the FILE test, [CLOS](class-0/CLOS.md) (0x030,
from `CLOSE FTEST;`) was also confirmed and written up (its opcode/
machine-code correlation had been glimpsed once before, unattributed, in
an earlier session's `ARITH.hal` trace — see "Empirical Verification"
below).

## DO CASE construct — DCAS/CLBL/ECAS resolved

Per direct user suggestion (opcode-name pattern-matching: "DCAS"/"ECAS"
sound like `DO CASE` begin/end), the syntax was located at [USA003087]
§10.3 (PDF pp. 120–121) and confirmed empirically by compiling:

```
I1 = 3;
DO CASE I1;
     S1 = 4;   S1 = 3;   S1 = 7;   S1 = 1;   S1 = 0;
END;
```

with `HALSFC --parms="LSTALL"`. Findings, all now written up in full:

- **[DCAS](class-0/DCAS.md)** (0x00B) is the `DO CASE` header — a genuine
  computed (indexed) branch, confirmed at the machine-code level
  (`AHI`/`LH`/`BCR`). Fills the gap [CLBL](class-0/CLBL.md)'s own
  write-up had long flagged: HAL/S's own name for the "originating
  computed branch instruction" companion to CLBL (HAL-1971: CBRA).
- **[CLBL](class-0/CLBL.md)** (0x00D, already documented from the
  HAL-1971 predecessor, now confirmed and extended for HAL/S) marks each
  case's entry point, one per statement in the group, each carrying an
  internal branch-label number that becomes the generated `L#<n>` label.
- **[ECAS](class-0/ECAS.md)** (0x00C) closes the construct, marking the
  join point where every case body's end-of-case branch converges.
- **Byproduct discovery**: a plain `S1 = 4;` (SCALAR receiver, integer-
  *looking* literal with no decimal point) does not produce
  [SASN](class-5/SASN.md) (0x501) as expected — it produces
  [IASN](class-6/IASN.md) (0x601) instead, even though the generated code
  correctly stores a float. Confirmed this isn't a `DO CASE` artifact by
  testing the same assignment standalone. `S1 = 4.5;` and `S1 = S2;` both
  correctly produce SASN. See [SASN](class-5/SASN.md)/
  [IASN](class-6/IASN.md)'s Unresolved Questions — the assign-opcode
  class appears to be selected by the literal's own written form
  (integer-looking vs. not), not solely by the receiver's declared type.
- **This is also what revealed EDCL's true role** (see above): it
  appeared before `I1 = 3;` here too, with nothing FILE-related about it,
  which is what prompted correcting [EDCL](class-0/EDCL.md)'s write-up
  from "precedes FILE writes" to "marks end of declarations."

## DO FOR/WHILE/UNTIL loop family — 9 opcodes resolved

Per direct user suggestion, this opcode cluster (0x00E–0x016) relates to
HAL/S's repetitive-execution statements, [USA003087] §10.2 (PDF pp.
113–121). Confirmed empirically by compiling every variant — plain
`DO;...END;`, `DO WHILE`, `DO UNTIL`, range-form `DO FOR` (default and
explicit `BY` increment, including negative), list-form `DO FOR`, and
`DO FOR...WHILE` (the supplementary-condition clause):

- **[DSMP](class-0/DSMP.md)** (0x013) / **[ESMP](class-0/ESMP.md)**
  (0x014) — plain unconditional `DO; ... END;` group, bracketing only,
  no generated code.
- **[DTST](class-0/DTST.md)** (0x00E) / **[CTST](class-0/CTST.md)**
  (0x016) / **[ETST](class-0/ETST.md)** (0x00F) — `DO WHILE`/`DO UNTIL`.
  A trailing header flag on DTST/CTST (0=WHILE, 1=UNTIL) encodes the
  polarity; UNTIL additionally emits an unconditional branch skipping the
  very first test, since UNTIL always executes at least once.
- **[DFOR](class-0/DFOR.md)** (0x010) / **[EFOR](class-0/EFOR.md)**
  (0x011) — range-form `DO FOR var = initial TO final BY increment;`.
  DFOR's operand count/shape differs between the default-increment and
  explicit-`BY` cases (extra literal operand for the increment).
- **[CFOR](class-0/CFOR.md)** (0x012) — the supplementary `WHILE`/`UNTIL`
  clause on a `DO FOR` (only appears when one is present); the `DFOR`
  analog of `CTST`.
- **[AFOR](class-0/AFOR.md)** (0x015) — list-form `DO FOR var = exp1,
  exp2, ...expn;`; one AFOR per value, using a call-and-computed-return
  mechanism (rather than range-form's increment/re-test loop) to dispatch
  into the loop body and back out again after the last value.

## Real-time programming statements — WAIT/SGNL/CANC/PRIO/SCHD/ERON resolved

Per direct user suggestion (with specific [USA003087] page references),
tested by compiling a `PROGRAM` containing a nested `TASK` block
exercising `WAIT` (all 3 forms), `SIGNAL`, `CANCEL` (self and named),
`TERMINATE` (self), `SCHEDULE`, `UPDATE PRIORITY`, the `PRIO` built-in
function, and `ON ERROR`/`OFF ERROR` (multiple forms):

- **[WAIT](class-0/WAIT.md)** (0x034) — all 3 forms (`WAIT interval;` /
  `WAIT UNTIL time;` / `WAIT FOR DEPENDENT;`) confirmed, discriminated by
  operand count and a trailing header flag.
- **[SGNL](class-0/SGNL.md)** (0x035) — `SIGNAL var;`, one `SYT` operand.
- **[CANC](class-0/CANC.md)** (0x036) — `CANCEL;`/`CANCEL label;`, self
  vs. named forms distinguished by operand count.
- **[PRIO](class-0/PRIO.md)** (0x038) — turns out to be the `UPDATE
  PRIORITY` statement, **not** the `PRIO` built-in function (a naming
  trap in `##DRIVER.xpl`'s `XPRIO` constant name). The actual `PRIO`
  built-in call instead goes through the general built-in-function-call
  opcode, **[BFNC](class-0/BFNC.md)** (0x04A) — a bonus resolution of an
  opcode previously known only from an Optimizer-HALMAT `SINCOS` special
  case, now confirmed as the general mechanism and cross-linked from
  [FCAL](class-0/FCAL.md).
- **[SCHD](class-0/SCHD.md)** (0x039) — `SCHEDULE label PRIORITY(α)
  DEPENDENT;` confirmed for the simplest (immediate-initiation) form;
  the trailing header bitmask is now fully decoded directly from the
  `<SCHEDULE HEAD>`/`<SCHEDULE PHRASE>`/`<SCHEDULE CONTROL>` grammar
  rules (High confidence) — delayed/cyclic forms still not independently
  compiled, but their operand/tag contributions are known from source.
- **[ERON](class-0/ERON.md)** (0x03C) — handles **all** tested `ON
  ERROR`/`OFF ERROR` forms (`SYSTEM`, `IGNORE`, `IGNORE AND SET var`, the
  user-supplied-statement form, and `OFF ERROR`), a single opcode with a
  4-way trailing-flag discriminant plus an packed group/member operand
  for the error specification.
- **[ERSE](class-0/ERSE.md)** (0x03D) — **resolved in a follow-up
  session**, after `ERON` was independently confirmed to cover all 11
  `ON`/`OFF ERROR` variations (adding `RESET`/`SIGNAL` clauses and both
  subscripted `ERRORm`/`ERRORm:n` specification forms to the 5 above —
  see [ERON](class-0/ERON.md)'s updated Operand-Word Format). With every
  `ON`/`OFF ERROR` form ruled out, a search for a genuinely distinct
  error-related statement turned up `SEND ERROR` ([USA003087] §25.3,
  error simulation/signaling) — ERSE ("ERror SEnd") confirmed directly.
- **[TERM](class-0/TERM.md)** (0x037, already documented) — self form
  (`TERMINATE;`) confirmed empirically as a byproduct; named/list forms
  still untested.

## New primary sources: now available and reviewed

Two additional primary sources, first identified via a secondhand summary
(`source-documentation/Conversions.txt`), are now available locally and
have been read directly (found in `../../Desktop/sandroid.org/public_html/apollo/Shuttle/`
— see "Alternate source locations" above):

- **[USA00309]**, "HAL/S-FC User's Manual" (2005). §8.2 "Runtime
  Characteristics" (18 numbered rules covering integer/scalar precision
  representation and every pairwise conversion between BIT/CHARACTER/
  SCALAR/INTEGER) and §6.1.2/§6.1.3 ("Input Data Formats"/"Output Data
  Formats," governing character↔numeric conversion and `WRITE`-statement
  formatting) reviewed in full. §6.2 ("File I/O") also reviewed: FILE I/O
  is not supported by the HAL/S-FC *runtime* library — it compiles but
  fails at link time with unresolved external references.
- **[USA003087]**, "HAL/S Programmer's Guide" (2005). §12.2 referenced
  (WRITE-statement item separator, 5 blank spaces for HAL/S-FC — see
  Plan.md's Phase 3 section) but not otherwise reviewed yet.

**The original ambiguity is resolved.** The secondhand summary's `" 0.0"`
description turned out to be a shorthand paraphrase of [USA00309] §6.1.3's
general scalar-output rule, not a real special case for zero:
scalar-to-character output is a **fixed-width field**
(`sd.ddddddddE±dd`, 14 chars single-precision / 23 chars double,
17 vs. 8 fractional digits) where `s` is simply blank for any
non-negative value (including 0.0) or `-` for negative — no zero-specific
padding logic exists. Full detail and citations now in
[STOC](class-2/STOC.md). Separately, [USA00309] §8.2 rule 10 clarified
that scalar→integer conversion isn't a formatting question at all — it's
an **ERROR CONDITION** if the scalar can't be represented as an integer;
see [STOI](class-6/STOI.md). Both files, plus [ITOC](class-2/ITOC.md),
[ITOS](class-5/ITOS.md), [CTOI](class-6/CTOI.md), [CTOS](class-5/CTOS.md),
[STOS](class-5/STOS.md), and [ITOI](class-6/ITOI.md), were updated this
session with the confirmed rules (exact output field formats, input
parsing formats, and — for the precision-scale family — the exact
bit-level truncate/pad/sign-extend mechanics: §8.2 rules 7, 8, 11, 12).

## Optimizer HALMAT — first empirical confirmation

Previously entirely [IR-60-5]-sourced (see [HALMAT.md](HALMAT.md#optimizer-halmat)),
with zero independent compilation despite this project's extensive
empirical-verification work elsewhere — every prior session's tests read
either `pass2.rpt` or `halmat.bin` via `unHALMAT.py`, neither of which
shows OPT's actual output. **New technique this session**: `HALSFC`'s
compile results directory contains both `halmat.bin` (PASS1's
pre-optimization output) and `optmat.bin` (OPT's output, what PASS2
actually consumes) — reading both with `unHALMAT.py` and diffing them
directly shows exactly what OPT changes, bit for bit.

Findings (full detail and worked traces in
[HALMAT.md](HALMAT.md#optimizer-halmat)):

- **COPT's pre-optimization role, traced to primary source**: PASS1
  itself writes one of two "text-optimizer tag" constants (`XCO_N`=`"01"`,
  `XCO_D`=`"02"`, declared in `##DRIVER.xpl`) into the COPT bit position
  at emission time, confirmed via `EMITSMRK.xpl` and cross-checked
  against real compiled `halmat.bin` output. OPT clears this placeholder
  to 0 for instructions where none of the named CSE/Cross-Block/
  Cross-Loop bits apply.
- **CSE bit (operator word) confirmed**: a genuine cross-statement
  common-subexpression-elimination case (`S3 = (X+Y)+(X+Y); S4 = X+Y;`)
  collapses all three syntactic `X+Y` occurrences to one `SADD`
  instruction in `optmat.bin`, which carries a nonzero COPT value
  distinguishing it from an ordinary, singly-referenced instruction.
- **CSE bit (operand word) partially confirmed**: same test shows a
  same-record VAC reference to the CSE'd result tagged differently than
  a cross-record one, consistent with the documented CSE-vs-Cross-Block
  operand-bit split, though not fully isolated bit-by-bit.
- **Class 7 T1 confirmed**: a standalone comparison (`DO WHILE I1 > 0;`)
  gains `TAG`=1 post-optimization, matching T1's documented "only
  comparison operator in the statement" meaning exactly.

Still [IR-60-5]-only, not yet independently triggered: Cross Block,
Cross Loop, and MAT/VEC-op bits; T2; SINCOS; DSUB's subscript-common-
expression operand; the integer-product subscript TAG; and the
ADLP/DLPE inline-vector/matrix-loop bits. Good candidates for a future
session using the same `halmat.bin`-vs-`optmat.bin` diffing technique:
a `SIN(X)`/`COS(X)` pair (SINCOS), an array reference inside a loop
whose value is also used outside it (Cross Loop), and a two-comparison
`CAND`/`COR` expression (T2).

## Empirical Verification (Phase 2)

A first verification pass against real compiled HALMAT, using the
`LSTALL` mechanism confirmed above. Test program (`ARITH.hal`):

```
 ARITH:
 PROGRAM;
    DECLARE SCALAR,
            S1 INITIAL(2.0),
            S2 INITIAL(3.0),
            S3;
    DECLARE INTEGER,
            I1 INITIAL(4),
            I2 INITIAL(5),
            I3;
    DECLARE VECTOR(3),
            V1 INITIAL(1,2,3),
            V2 INITIAL(4,5,6),
            V3;
    DECLARE MATRIX(2,2),
            M1 INITIAL(1,2,3,4),
            M2 INITIAL(5,6,7,8),
            M3;
    S3 = S1 + S2;
    S3 = S1 - S2;
    S3 = S1 S2;
    S3 = S1 / S2;
    I3 = I1 + I2;
    I3 = I1 - I2;
    I3 = I1 I2;
    V3 = V1 + V2;
    V3 = V1 - V2;
    M3 = M1 + M2;
    M3 = M1 - M2;
    M3 = M1 M2;
 CLOSE ARITH;
```

Compiled with `HALSFC --parms="LSTALL" ARITH.hal`.

**Two HAL/S syntax gotchas discovered while writing this** (neither
previously documented in this project, both worth remembering for future
test programs):

1. **Column 1 must be blank** for ordinary statement lines — this is a
   fixed-column source format inherited from card-image conventions. A
   line starting in column 1 (e.g. `ARITH: PROGRAM;` with no leading
   space) is misparsed; the existing test files (`HELLO.hal`,
   `SIMPLE.hal`) already follow this convention, which is easy to miss
   when writing a new file from scratch.
2. **`*` is reserved for vector cross product** (and, per the error
   message, similar vector/matrix-specific operations) — it is *not* the
   general multiplication operator. Plain scalar multiplication and
   matrix-matrix multiplication both use **juxtaposition** (adjacency
   with a space, e.g. `S1 S2`, `M1 M2`), matching the pattern already
   seen in [MSC-01847]'s worked examples (`5 PI`) and in
   `Programming in HAL-S/095-TAN_SUMS.hal` (`X RAD_PER_DEGREE`). Using
   `*` between two scalars, or between two matrices, produces error `E4`
   ("DOT OR CROSS PRODUCT SYMBOL (. OR *) USED IN A PRODUCT NOT INVOLVING
   VECTORS").

### Opcode confirmations

Every opcode below was read directly from `pass2.rpt`'s `HALMAT:
<opcode>(<numop>),<tag>,<extra>:<line>.<sub>` lines and matches this
project's already-documented value exactly — a 100% match rate on
everything tested:

| Statement | Opcode observed | Mnemonic | File |
|---|---|---|---|
| `S3 = S1 + S2` | 0x5AB | SADD | [SADD](class-5/SADD.md) |
| `S3 = S1 - S2` | 0x5AC | SSUB | [SSUB](class-5/SSUB.md) |
| `S3 = S1 S2` | 0x5AD | SSPR | [SSPR](class-5/SSPR.md) |
| `S3 = S1 / S2` | 0x5AE | SSDV | [SSDV](class-5/SSDV.md) |
| `I3 = I1 + I2` | 0x6CB | IADD | [IADD](class-6/IADD.md) |
| `I3 = I1 - I2` | 0x6CC | ISUB | [ISUB](class-6/ISUB.md) |
| `I3 = I1 I2` | 0x6CD | IIPR | [IIPR](class-6/IIPR.md) |
| `V3 = V1 + V2` | 0x482 | VADD | [VADD](class-4/VADD.md) |
| `V3 = V1 - V2` | 0x483 | VSUB | [VSUB](class-4/VSUB.md) |
| `M3 = M1 + M2` | 0x362 | MADD | [MADD](class-3/MADD.md) |
| `M3 = M1 - M2` | 0x363 | MSUB | [MSUB](class-3/MSUB.md) |
| `M3 = M1 M2` | 0x368 | MMPR | [MMPR](class-3/MMPR.md) |
| every `=` assignment (scalar) | 0x501 | SASN | [SASN](class-5/SASN.md) |
| every `=` assignment (integer) | 0x601 | IASN | [IASN](class-6/IASN.md) |
| every `=` assignment (vector) | 0x401 | VASN | [VASN](class-4/VASN.md) |
| every `=` assignment (matrix) | 0x301 | MASN | [MASN](class-3/MASN.md) |
| `S1 INITIAL(2.0)` | 0x8A1 | SINT | [SINT](class-8/SINT.md) |
| `PROGRAM;` header | 0x02B | MDEF | [MDEF](class-0/MDEF.md) |
| record start | 0x005 | PXRC | [PXRC](class-0/PXRC.md) |
| every statement boundary | 0x004 | SMRK | [SMRK](class-0/SMRK.md) |
| `CLOSE ARITH;` / `CLOSE FTEST;` | 0x030 / 0x002 | CLOS / XREC | [CLOS](class-0/CLOS.md) / [XREC](class-0/XREC.md) |
| `FILE(3,7) = S1;` | 0x031 / 0x022 | EDCL / FILE | [EDCL](class-0/EDCL.md) / [FILE](class-0/FILE.md) |
| `I1 = FILE(4,8);` | 0x022 | FILE | [FILE](class-0/FILE.md) |
| `DO CASE I1; ... END;` | 0x00B / 0x00D / 0x00C | DCAS / CLBL / ECAS | [DCAS](class-0/DCAS.md) / [CLBL](class-0/CLBL.md) / [ECAS](class-0/ECAS.md) |
| `S1 = 4;` (int-looking literal!) | 0x601 (not 0x501) | IASN (not SASN) | see [SASN](class-5/SASN.md)/[IASN](class-6/IASN.md) Unresolved Questions |
| `DO;...END;` / `DO WHILE`/`UNTIL` / `DO FOR` (range+list+`WHILE`) | 0x00E/0x00F/0x010/0x011/0x012/0x013/0x014/0x015/0x016 | DTST/ETST/DFOR/EFOR/CFOR/DSMP/ESMP/AFOR/CTST | see "DO FOR/WHILE/UNTIL loop family" above |
| `WAIT`/`SIGNAL`/`CANCEL`/`TERMINATE`/`SCHEDULE`/`UPDATE PRIORITY`/`PRIO`/`ON`&`OFF ERROR` | 0x034/0x035/0x036/0x037/0x038/0x039/0x03C/0x04A | WAIT/SGNL/CANC/TERM/PRIO/SCHD/ERON/BFNC | see "Real-time programming statements" above |

### Operand-word format: confirmed (order corrected in a later session)

The `pass2.rpt` print format for each operand is `DATA(QUAL),TAG1,TAG2`,
directly matching the documented DATA/TAG1/QUAL/TAG2 layout in
[HALMAT.md](HALMAT.md#word-format). Traced example (statement `S3 = S1 +
S2`, immediately followed by the implicit `S3 = <result>` assignment):

```
HALMAT: 5AB(  2),  0,0:0.67        <- SADD, numop=2, at stream position 67
          2( 1),  0,0              <- operand: DATA=2 (S1's symbol index), QUAL=1=SYT
          3( 1),  0,0              <- operand: DATA=3 (S2's symbol index), QUAL=1=SYT
HALMAT: 501(  2),  0,0:0.70        <- SASN, numop=2
         67( 3),  0,0              <- operand 1: DATA=67, QUAL=3=VAC (source value)
          4( 1),  0,0              <- operand 2: DATA=4 (S3's symbol index), QUAL=1=SYT (receiver)
```

This directly and concretely confirms VAC's documented semantics: `DATA`
for a VAC-qualified operand is **the stream position (line number) of the
producing instruction** — here, 67, exactly matching SADD's own `:0.67`
position tag.

**The `xASN` operand order shown above was originally read backwards**
(receiver first, source second) and stood that way — cited from here as
the flagship confirmation — until a later session's systematic
`unHALMAT.py` cross-check caught it: `unHALMAT.py`'s direct binary read
numbers HALMAT words in true stream order as it walks the file linearly,
with no possibility of the visual-vs-actual-position ambiguity that
affects `pass2.rpt`'s text report (see [XXST](class-0/XXST.md) for the
first instance of this class of bug, found via `READ`'s device number).
Applying the same cross-check here across `SASN`/`IASN`/`VASN`/`MASN`/
`BASN`/`CASN`/`TASN` (six type families plus the structure-assign
opcode) showed **every one** had the same reversed order in this
project's docs — true order is **source value first, receiver second**
— except [NASN](class-0/NASN.md), which had already documented this
correctly. All seven affected files were corrected; see each file's
Operand-Word Format section. **Lesson reinforced**: `pass2.rpt`'s visual
operand order cannot be trusted at all for multi-operand instructions,
independent of the separate misattribution-across-instructions bug found
earlier for XXST/READ — always cross-check against a direct
`unHALMAT.py` binary read (`HALSFC --parms="LISTING2,LSTALL"`, `unHALMAT.py`
run from inside the results directory) before trusting any multi-operand
ordering claim sourced only from `pass2.rpt`.

### Unknown-behavior opcodes: resolved (mostly)

Follow-up session targeting the "new" opcodes with no [MSC-01847]
behavioral analog (`MTOM`, `VTOV`, `CTOS`/`STOS`, `CTOI`/`ITOI`, `BTOB`/
`BTOQ`-family, `BTOC`/`CTOC`, `IPEX`). Two techniques used:

1. **Re-reading `##DRIVER.xpl` precisely** revealed these opcodes fall
   into two clean, complete families, not scattered one-offs:
   - **"Convert to X" arrays**, one per destination type, each indexed
     identically (bit=0, char=1, unused=2/3, scalar=4, integer=5):
     `XBTOI` (→integer: BTOI✓, CTOI, unused, unused, STOI✓, ITOI),
     `XBTOS` (→scalar: BTOS✓, CTOS, unused, unused, STOS, ITOS✓),
     `XBTOC` (→character: BTOC, CTOC, unused, unused, STOC✓, ITOC✓),
     `XBTOB` (→bit: BTOB, CTOB, unused, unused, STOB, ITOB) — ✓ marks
     the members already confirmed via [MSC-01847] or empirically.
   - **A precision-scale array**, `XMTOM` (4 elements: matrix, vector,
     scalar, integer) — `MTOM`, `VTOV`, `STOS`, `ITOI`. Note `STOS` and
     `ITOI` are shared members of *both* families: for a value's own
     type, "convert X to X" and "scale X's precision" are the same
     operation, so the compiler reuses one opcode for both roles.
2. **Static source tracing**: `XMTOM` is referenced in exactly one file,
   `PASS1.PROCS/PRECSCAL.xpl` (`PREC_SCALE` procedure, called from
   `SETUP_NO_ARG_FCN` and `SYNTHESIZE`) — this is a primary-source
   confirmation that the whole `XMTOM` family is a **precision-scaling**
   mechanism: a variable's "pseudo form" is tested against a 4-bit mask,
   and if set, an `XMTOM`-family instruction is emitted with that mask as
   its `TAG`, targeting whichever type the operand is.
3. **Empirical testing**: compiled `I1 = INTEGER(C1); S1 = SCALAR(C1);`
   (C1 a CHARACTER variable) with `HALSFC --parms="LSTALL"` —
   **confirmed `CTOI` (0x641) and `CTOS` (0x541) fire exactly as
   expected**. Also compiled a scalar-precision-mismatch assignment
   (`DECLARE SCALAR, S1; DECLARE SCALAR DOUBLE, S2; ... S2 = S1;`) —
   this did **not** trigger `STOS`; the precision widening was instead
   handled implicitly by the generated object code (`SER`/`STED`
   instructions), with a plain `SASN` in the HALMAT. This tells us
   `STOS`/`MTOM`-family instructions are reserved for some other
   precision-forcing context (per `PRECSCAL.xpl`'s caller list — likely
   function-argument matching or literal/constant synthesis), not
   ordinary assignment — a real, useful negative result.

**Now documented** (12 files from that session, all subsequently raised
to High confidence in a later follow-up): [CTOI](class-6/CTOI.md) and
[CTOS](class-5/CTOS.md) (empirical); [MTOM](class-3/MTOM.md),
[VTOV](class-4/VTOV.md), [STOS](class-5/STOS.md), [ITOI](class-6/ITOI.md)
(triggering construct — `exp$(@SINGLE/DOUBLE)` — found and empirically
confirmed); [BTOC](class-2/BTOC.md), [CTOC](class-2/CTOC.md),
[BTOB](class-1/BTOB.md), [CTOB](class-1/CTOB.md), [STOB](class-1/STOB.md),
[ITOB](class-1/ITOB.md) (triggering construct — `BIT(...)`/`CHARACTER(...)`
shaping functions — found and empirically confirmed).

**`XBTRU` resolved.** A follow-up session directly tested the
truth/logical-test hypothesis above for `XBTRU` (0x720) and confirmed it:
[BTRU](class-7/BTRU.md) ("bit is true") is the universal mechanism
converting any bit-string-typed value into a branch-testable condition,
confirmed for a subscripted-single-bit `BIT` condition ([USA003087]
§17.6), a plain `EVENT` condition, and a `BOR`-combined pair of events
(§24.7). `XBTOQ` (`BTOQ`=0x122, `CTOQ`=0x142, `STOQ`=0x1A2, `ITOQ`=0x1C2)
was initially a red herring for that same hypothesis — none of the three
bit-in-conditional-context cases that triggered `BTRU` involved `BTOQ` —
but was independently resolved in a later session as the `SUBBIT`
pseudo-conversion function ([USA003087] §21.5); all four family members
are now High confidence, empirically confirmed in both reference and
assignment context (`BTOQ`/`CTOQ`'s assignment-context form specifically
closed out this session — see [BTOQ](class-1/BTOQ.md)/[CTOQ](class-1/CTOQ.md)).
`IPEX` (0x6D2) is also now resolved — see the Class 6 section above and
[IPEX](class-6/IPEX.md).

Class 0 control-flow instructions (IFHD/DFOR/WAIT family) and Class 1/2/7
are also no longer outstanding — see those classes' sections above, all
marked empirically confirmed.

## Next steps (suggested)

1. A systematic sweep of USA003087 syntax patterns against previously-
   untested HALMAT opcodes (prompted directly by the user), across three
   sessions, resolved almost everything in scope: IFHD, TSUB, CDEF, TASN,
   TEQU, TNEQ, NASN, NEQU, NNEQ, NINT (Class 8), VSHP, SSHP, ISHP, MSHP
   (inferred), IDEF, ICLS, TDCL (identified directly by the user —
   `TEMPORARY` declarations, [USA003087] §26.3 — after structures/
   COMPOOL/templates had been ruled out), SLRI/ELRI/ETRI (Class 8 —
   confirmed via a genuinely large `1000#value` repeated array, which
   fully unrolls for `STATIC` data rather than generating a runtime
   loop), ERSE (`SEND ERROR`, §25.3 — found only after exhaustively
   ruling out 11 `ON`/`OFF ERROR` variations, see [ERON](class-0/ERON.md)),
   and a bonus previously-unknown opcode, [BTRU](class-7/BTRU.md)
   (0x720, "bit is true" — the real mechanism behind bit-string/`EVENT`-
   in-conditional-context, found while chasing the `BTOQ` hypothesis).

   **A second technique then closed out every remaining holdout.** After
   exhausting HAL/S-syntax guessing for [IDLP](class-0/IDLP.md), grepping
   the full `PASS.REL32V0` compiler source tree for every site
   referencing its `X`-prefixed constant (`XIDLP`) — not just its opcode
   declaration — led straight to the deciding logic in `ICQARRA2.xpl`
   (the `AUTOMATIC`/`STATIC` discriminant against [ADLP](class-0/ADLP.md)
   for uniform-single-value array initialization). The same technique,
   applied directly (on user suggestion) to every other remaining
   unresolved opcode, resolved all of them: [PMHD](class-0/PMHD.md)/
   [PMAR](class-0/PMAR.md)/[PMIN](class-0/PMIN.md) (the `%macro`
   invocation construct, [USA003087] §31.1 — found via `SYNTHESI.xpl`'s
   grammar-rule comments, then tested using the compiler's own predefined
   `%SVC` macro found in `##DRIVER.xpl`'s `PCNAME` table);
   [LFNC](class-0/LFNC.md) (the `MAX`/`MIN` built-in functions
   specifically — a separate "L-FUNC" dispatch category found via
   `ENDANYFC.xpl`'s explicit `/* L-FUNC BUILT-INS */` source comment,
   distinct from ordinary built-ins via [BFNC](class-0/BFNC.md), whose
   own selector table was also substantially filled in as a byproduct —
   see that file); and the `XBTOQ` family
   ([BTOQ](class-1/BTOQ.md)/[CTOQ](class-1/CTOQ.md)/
   [STOQ](class-1/STOQ.md)/[ITOQ](class-1/ITOQ.md) — the `SUBBIT`
   pseudo-conversion function, [USA003087] §21.5, found via
   `ENDSUBBI.xpl`'s `END_SUBBIT_FCN` procedure name; all four members —
   `STOQ`/`ITOQ`/`BTOQ`/`CTOQ` — are now empirically confirmed in both
   reference and assignment context). **Every opcode identified this
   project has now been assigned a behavioral description** — none
   remain in the "not started" or purely negative-result state.
2. Read [Halmat.pdf] pages 16–114 to get its full reconstructed HAL/S
   inventory for Classes 1–8, and cross-check it against the HAL-1971
   tables now in this file's Class 1–7 sections — agreement between
   [Halmat.pdf] (an independent HAL/S-source-derived reconstruction) and
   [MSC-01847] (the HAL-1971 primary source) on a given mnemonic/opcode
   would be meaningfully stronger evidence than either alone. This is the
   highest-value remaining source-review task for Phase 1 — **but per
   direct user instruction, comparison with [Halmat.pdf] should be the
   very last task undertaken in Phase 2** (empirical verification), to
   avoid anchoring on a secondary reconstruction before independent
   compiler-source/real-HALMAT verification is as complete as possible.
   A future session should not start this task while any other Phase 2
   empirical-verification work (see "Next steps" items below, and
   `HALMAT.md`'s "Optimizer HALMAT" section) remains open.
3. Read the remaining unreviewed tail of [MSC-01847] (part2 pp. 41–42,
   part3 p. 41) — likely just closing appendix material, low priority.
4. Write the "Control Flow Patterns" cross-reference material that IFHD,
   BRA, FBRA and related entries reference, now that BRA/FBRA/LBL/CLBL are
   documented.
5. ~~Consider whether SLRI/ELRI are safe to document~~ — resolved: both,
   plus ETRI, TINT, and EINT, are now empirically confirmed at High
   confidence (see Class 8 table above; **all 13 Class 8 opcodes are now
   documented**). TINT (structure-terminal initialize, [USA003087] §19.6)
   and EINT (`EQUATE EXTERNAL` statement, undocumented in [USA003087]'s
   prose — subsequently corroborated by a second primary source,
   [CourseSlides.pdf] pp. 486-487) were resolved via the
   compiler-source-tree-grep technique. In a further follow-up,
   [BTOQ](class-1/BTOQ.md)/[CTOQ](class-1/CTOQ.md) were also directly
   compiled and confirmed (no longer analogy-only), closing out **every**
   Medium/Medium-High-confidence opcode in the project. As of this
   session (with [IPEX](class-6/IPEX.md) added), all 179 documented
   opcodes are High confidence — reconfirmed by direct grep, no
   Medium/Low-confidence files remain anywhere in `class-*/`.
6. Investigate the open question above about HAL/S's structureness
   specifier (no confirmed Class 0 opcode, unlike ADLP).
7. ~~Investigate the remaining mnemonics listed above~~ — **narrowed**:
   `FCLM`/`FLIN`/`FPGE`/`FSKP`/`FTAB` (folded into [XXAR](class-0/XXAR.md)'s
   `TAG2` field) and `FASN` (superseded by the JCL `CHANNELn` DD-name
   convention, [USA00309] §6.1.4) are now resolved — see
   [XXAR](class-0/XXAR.md)'s Unresolved Questions and the "HAL/S I/O
   device numbers" section above. `LIST`/`LSTE`/`CASS` were already
   resolved in an earlier session (folded into `XXST`/`XXAR`/`XXND`).
   Genuinely still unaccounted for: `ENDS`/`ENTS`/`EXTS`, `UEND`, `ZRFN`,
   `ASIZ`/`TSIZ` — investigate against the unlisted-gap opcodes in
   [IR-60-5]'s Class 0 index if a fuller copy of that index or its target
   pages ever turns up. (`TASN`/`TEQU`/`TNEQ` were resolved in an earlier
   session — see above.)
