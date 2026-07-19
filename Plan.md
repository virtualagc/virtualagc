# Plan for HALMAT Reverse Engineering project

## Background

HALMAT is an "intermediate language" used by the compiler for the HAL/S programming language.  The HAL/S compiler (HAL/S-FC) consists of a set of "passes", which are each stand-alone programs (PASS1, OPT, PASS2), executed sequentially.  PASS1 parses HAL/S source code and outputs HALMAT code.  OPT inputs the HALMAT code, optimizes it, and outputs the optimized HALMAT.  PASS2 inputs optimized HALMAT and generates object code for the AP-101S CPU.

The HALMAT language is binary only.  There is no "source code" form of the language.  However, each numeric "instruction" or "opcode" does have a mnemonic label assigned to it.

Surviving documentation for HALMAT is not adequate.  Reverse engineering is required to provide more-correct, more-complete documentation.

## Roadmap for Development

Development will proceed in 3 phases, which (generally speaking) will be carried out in sequence, although work carried out in any given phase may result in corrections to items generated in preceding phases. Separate sections of this document will describe each phase in more detail.

The intention is that all initial development is performed by Claude in conformance with this plan, with non-Claude changes occurring only after all three phases have been completed.

# Phase 1

In Phase 1, surviving HALMAT documentation is evaluated to create more-satisfactory new documentation. Below is a list of the resources available for this phase, in descending order of preference.

> **Note**: While URL's listed below are for online copies of the document, check the source-documentation/ subdirectory first to see if a local copy is provided.

> **Note**: If text that is too questionable due to poor OCR is detected during evaluation, feedback should be provided as to specific passages of the source documentation for which corrected text is needed.

1. Online at [Document IR-60-5, "HAL/S-360 Compiler System Specification", Appendix A, (1977)](https://www.ibiblio.org/apollo/Shuttle/HAL_S-360%20Compiler%20System%20Specification%204%20Feb%201977.pdf#page=114).  This document is believed to be accurate documentation for HALMAT, but the available copy only contains pages changed from the previous revision of the document, and is thought to be less than 20% complete.  Full copies of this document or its predecessors or successors (IR-60-4, IR-60-6) have not been found.
2. Online at [Document MSC-01847, "HALMAT: An Intermediate Language of the First HAL Compiler" (1971)](https://www.ibiblio.org/apollo/Shuttle/HALMAT%20-%20An%20Intermediate%20Language.pdf). This document is believed to be a full description of HALMAT, but only in a version for the language HAL (predecessor to HAL/S) that differs in details from how HALMAT was eventually implemented in HAL/S.
3. Online at ["HALMAT Instruction Set Reference" (2026)](https://github.com/Zaneham/Halmat/blob/main/Halmat.pdf). This is an earlier attempt at reconstructing the HALMAT documentation, which may serve as a guide but is known not to be perfect. Notably, this document provides references (albeit not direct links) to relevant source code in the HAL/S compiler, as well as other insights, that may be useful in development Phase 2, though not relevant in Phase 1. Note: This document, Halmat.pdf, is regarded as inadequate primarily because it has proven impossible to push corrections to it.

Note that HALMAT instructions have been observed to fall into 9 classes, numbered 0 through 8. (These classes are present in the source code for the HAL/S compiler. [See the files GENCLAS0.xpl through GENCLAS8.xpl](https://github.com/virtualagc/virtualagc/tree/master/yaShuttle/Source%20Code/PASS.REL32V0/HALINCL) as used by compiler PASS2. IR-60-5 section A.2 provides a partial index of Class 0 and Class 8 instructions.)

The newly-produced documentation should include both generic information about HALMAT (for example, instruction- and operator-word formats, block structure, large-scale organization, and so on) as well as documentation specific to each instruction. All of this documentation should be:

- In the form of markdown files suitable for use in GitHub.
- Stored in a subdirectory hierarchy underneath the reengineered-documentation/ top-level directory. A file called HALMAT.md should be at the top level of reengineered-documentation/. Also at the top level should be subdirectories class-0/, class-1/, ..., class-8/. The markdown files for the individual instructions should be stored in the appropriate class-<i>N</i>/ subdirectories, and should be named according to their mnemonics whenever possible.  For example, class-0/EXTN.md, class-0/XREC.md, class-3/MASN.md, and so on. If no mnemonic is apparent from the documentation, then the numeric opcode, 0x<i>NNN</i>, should be used instead (see the opcode format described below).
- Create also reengineered-documentation/STATUS.md to serve as a cross-session progress tracker. The format of this file is left for Claude to decide.
- Each instruction file should list its mnemonic, such as "Mnemonic: SMRK", and its numeric opcode, in 3-digit hexadecimal, such as "Opcode: 0x123", at the top of its associated file.
- If feasible, each instruction file should have an item such as "Confidence: High | Medium | Low" as to the reliability of new documentation.
- Useful headings within instruction markdown files, where possible: "Behavioral Description", "Usage Context" (i.e., what instructions precede/follow it, its operands), "Unresolved Questions" (bullet points).  If a section on "Source Analysis & Reliability" is included, it may obviate the need for many footnotes.
- The items just mentioned (Mnemonic, Opcode, Confidence, Behavioral Description, etc.) should appear in exactly the order listed above.
- The top-level file, HALMAT.md, should include lists with links to the markdown files for the instructions.  There should be several separate lists:  In alphabetical mnemonic order, in numeric opcode order, and in class+alphabetical order.
- When reverse-engineered info that differs from document IR-60-5 is presented, or if IR-60-5 is silent, there should be documentation via a markdown footnote as to how the information was derived, unless there's already a "Source Analysis & Reliability" description covering that information. 
- In text and in footnotes, references to individuals by name (such as "Burkey" or "Ron Burkey") should be avoided where possible, and where feasible, references should instead be to specific documents, by title, and if possible, by page number. References to documents may be simplified if (in HALMAT.md) a list of document numbers or abbreviations is given, and then references can just use those document numbers or abbreviations.
- References to supporting documentation should not generally be made to Halmat.pdf, since that is a secondary source that cannot be regarded as authoritative. References should instead be made to the primary sources from 1977 and 1971 wherever possible. References can be made to Halmat.pdf when it is made clear that speculation or analysis is being provided rather than primary source material.

# Phase 2

In Phase 2, reverse engineering is performed using such resources as HAL/S compiler source code and true HALMAT files to correct and complete the documentation developed in Phase 1.

Phase 2 development should not begin until explicitly instructed. The remainder of this section is a draft of what Phase 2 entails, prepared in advance so that work can start promptly once instructed; it may be incomplete or revised before Phase 2 actually begins.

## Resources

- **HAL/S-FC compiler source (XPL/I)**: `../virtualagc/yaShuttle/Source Code/PASS.REL32V0/` (note the space in "Source Code"). PASS1 lives in `PASS1.PROCS/`, OPT in `OPT.PROCS/`, PASS2 in `PASS2.PROCS/` (also present: `PASS3.PROCS/`, `PASS4.PROCS/`, `AUX_PROCS/`, `FLO.PROCS/` — seven passes/phases total). Each such directory's top-level file is `##DRIVER.xpl`, which assembles the rest of that pass's source via `/**MERGE basename ...*/` directives (include `basename.xpl` from the same directory). All passes additionally depend on shared include files in `PASS.REL32V0/HALINCL/`, pulled in via `/* INCLUDE ...comment... $%basename */` directives.
- **Language**: the source is **XPL/I**, not PL/I — an extended dialect of the dead language XPL (itself a PL/I-like language IBM designed in 1964, documented in only one book with no known machine-readable copy). Do not assume PL/I semantics apply directly. The XPL BNF grammar is available locally at `../virtualagc/yaShuttle/Source Code/XPL-TWS-1969-03/XPL.bnf`. XPL and XPL/I have IBM System/360-specific peculiarities (documented at https://www.ibiblio.org/apollo/XPL-I.html#xpli) that should be read before writing any parsing or extraction code, to avoid naive mistakes.
- **XCOM-I.py** (`../virtualagc/XCOM-I/XCOM-I.py`): a working, locally-installed XPL/I-to-C translator, proven capable of compiling the entire HAL/S-FC source. Worth studying as a working reference for XPL/I syntax even where its own code isn't reused directly.
- **HALSFC** (e.g. `PASS.REL32V0/HALSFC-PASS1`, `-OPT`, `-PASS2`, etc., both `debug-build/` and `production-build/` variants): the "modern" HAL/S-FC compiler, i.e. the C code produced by XCOM-I from the XPL/I source, compiled and runnable locally. Running its PASS1 produces `halmat.bin`, `litfilea.bin`, and `COMMON-PASS1.out`.
- **HAL_S_FC.py** (`../virtualagc/yaShuttle/ported/PASS1.PROCS/HAL_S_FC.py`): a pure-Python port of PASS1 only. Lighter-weight than running full HALSFC, but produces differently-named output: `FILE1.bin` (≙ `halmat.bin`), `FILE2.bin` (≙ `litfile0.bin`, presumed equivalent of `litfilea.bin`), and `LIT_CHAR.bin` (used the way `COMMON-PASS1.out` is, for literal-file processing — no direct filename equivalent).
- **unLitfile.py** (`PASS.REL32V0/unLitfile.py`): decodes a literal-file pair (either `litfile0.bin`+`COMMON-PASS1.out` or `FILE2.bin`+`LIT_CHAR.bin`) into a human-readable form.
- **unHALMAT.py** (`PASS.REL32V0/unHALMAT.py`): an existing, already-installed tool that converts a HALMAT binary file into human-readable form. Originally written from documentation but tweaked over time to stay functional — i.e. it may already embed corrections/assumptions not written down anywhere, so it's a valuable practical shortcut, but its output should still be cross-checked against other evidence rather than treated as ground truth on its own.
- **Compiler report output**: PASS1, OPT, and PASS2 are all capable of printing the HALMAT they process in their own output reports, given the proper compiler switches (not yet catalogued — an early Phase 2 task). PASS2 in particular can interleave this printed HALMAT with the AP-101S assembly language it generates and the original HAL/S source statements, when the proper switches are used. This gives a source-statement ↔ HALMAT ↔ object-code correlation without necessarily needing to parse compiler source or write a disassembler first. **Caveat**: these reports take liberties with instruction order — notably, `SMRK` instructions print at a different position in the report than they actually occupy in the HALMAT file — so report order should not be assumed to equal true stream order without checking against an actual binary.
- **Test HAL/S source files**: many local files like `HELLO.hal` already exist for compiling test cases (not necessarily identical to the same-named file in the Halmat.pdf repo, below).
- **[Halmat.pdf] / yaHALMAT repository**, cloned locally at `../Halmat/`: contains Zane's actual OCaml parser/disassembler source, generated opcode/cross-reference tables, HAL/S test fixtures and their compiled HALMAT binaries (`data/out_*/halmat.bin`), and the yaHALMAT emulator. Per this document's existing sourcing rules, this remains a secondary/comparative resource, not primary evidence — but it's a useful independent check, and its test fixtures may save time versus generating everything from scratch.

## Proposed methodology

0. Catalogue the compiler switches that make PASS1/OPT/PASS2 print HALMAT in their reports, and (for PASS2) interleave it with AP-101S assembly and original HAL/S source — likely the fastest path to seeing real, source-correlated HALMAT without writing any new tooling first.
1. Extract the opcode table (mnemonic, class, opcode) from the `BIT(16) INITIAL(...)`-style constant declarations in `##DRIVER.xpl` and `HALINCL/`, across PASS1/OPT/PASS2 (and PASS3/PASS4/AUX/FLO as relevant).
2. Resolve each pass's `MERGE`/`INCLUDE` directives to assemble its full source text, enabling whole-pass search.
3. Cross-reference opcode symbol usage across passes (emission, consumption, optimization sites) to inform each instruction's "Usage Context" and behavioral description.
4. Compile targeted HAL/S test programs — prioritizing constructs/instructions Phase 1 left undocumented — using HAL_S_FC.py where PASS1-only behavior suffices (fast turnaround), falling back to full HALSFC where OPT/PASS2-stage behavior needs verification.
5. Decode the resulting binaries into readable form — via `unHALMAT.py` for a quick first look, and/or a purpose-built disassembler informed by Phase 1's already-documented word/operand formats where independent verification of unHALMAT.py's output is warranted — cross-referenced with literal files decoded via `unLitfile.py`, to verify claims empirically against real compiled output. Where finer-grained source-statement ↔ HALMAT ↔ AP-101S correlation is needed, use PASS2's report-interleaving capability instead of or alongside binary disassembly (remembering the SMRK-ordering caveat above).
6. Where `../Halmat/`'s own data or claims overlap, use them as an independent cross-check, but verify against the compiler source and real binaries directly rather than adopting its claims as-is, consistent with this document's existing sourcing precedence (primary source > predecessor-language primary source > this secondary reconstruction).
7. Update `reengineered-documentation/` instruction files and `STATUS.md` as each opcode's HAL/S-specific behavior and format is confirmed, upgrading Confidence ratings and replacing HAL-1971-cross-reference-only entries with primary-sourced ones.

## Tooling approach

Prefer lightweight, targeted Python text extraction (regex/line-based) over building a full XPL/I grammar-driven parser, since the declarations needed for opcode-table extraction and cross-referencing are structurally regular; reserve a fuller parser for cases where targeted extraction proves insufficient. Prioritize the empirical verification loop (steps 4–5 above — compiling real test programs and disassembling real binary output) over static inference from source structure alone, since it's independently checkable ground truth rather than an interpretation of the source.

# Phase 3

In this phase, a complete, accurate, cross-platform emulator that can execute HALMAT code directly is developed. There is an existing HALMAT emulator, [yaHALMAT](https://github.com/Zaneham/Halmat), but it is regarded as inadequate principally because it has proven impossible to push changes to it. However, it is a good start, and can serve as a base for a future emulator.

Phase 3 development should not begin until explicitly instructed, hence details about what this phase entails remain TBD for now. Two things already identified as relevant when this phase begins:

- PASS2's ability to interleave printed HALMAT with its generated AP-101S assembly and the original HAL/S source (see Phase 2's Resources section above) — correlating each HALMAT instruction with the real object code it produces is a direct way to determine instruction behavior for emulator purposes, independent of however Phase 2's own documentation effort turns out.
- The emulator program should be named **yaHALMAT2**. Per document USA003087 ("HAL/S Programmer's Guide") §12.2, items in a HAL/S `WRITE` statement's output are separated by an implementation-dependent number of blank spaces; for HAL/S-FC specifically, that number is 5. yaHALMAT2 should default to 5 blank spaces between `WRITE`-statement output items, but this should be configurable via a command-line option rather than hardcoded.
