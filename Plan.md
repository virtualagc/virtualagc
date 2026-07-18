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

Phase 2 development should not begin until explicitly instructed, hence details about what this phase entails remain TBD for now.

# Phase 3

In this phase, a complete, accurate, cross-platform emulator that can execute HALMAT code directly is developed. There is an existing HALMAT emulator, [yaHALMAT](https://github.com/Zaneham/Halmat), but it is regarded as inadequate principally because it has proven impossible to push changes to it. However, it is a good start, and can serve as a base for a future emulator.

Phase 3 development should not begin until explicitly instructed, hence details about what this phase entails remain TBD for now.
