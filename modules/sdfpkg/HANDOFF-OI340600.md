================================================================================
HANDOFF -- OI340600: ASSEMBLE, LINK, COMPARE TO THE DASS DUMPS  (2026-08-12)
================================================================================
Written so a fresh session can start from this file alone.  Open the
conversation at the virtualagc root: the assembler, the harnesses and the
sources are in three different trees.

THE GOAL.  Every assembly-language file in OI340600 is to assemble correctly.
OI340600 HAS NO ASSEMBLY LISTINGS, so correctness cannot be checked module by
module the way OI301700's was.  Instead the object files are LINKED with
`lnk101` and the resulting AP-101S memory image is compared against the DASS
memory dumps.

    THAT CHANGES THE UNIT OF EVIDENCE, and it is worth being clear about it
    before any measurement is taken.  A listing pins one module's bytes at
    known addresses.  A linked image pins the WHOLE LOAD, so a discrepancy
    names a place in memory rather than a card, and attributing it back to a
    module is the first step of every investigation rather than a given.

    IT ALSO REMOVES THE PER-MODULE SAFETY NET.  A module that assembles
    quietly and wrongly is invisible until the image is compared.  Expect to
    build the attribution machinery early, and expect it to be most of the
    work.

WHAT IS ALREADY TRUE, and is the reason this phase can start at all: ASM101S
assembles the ENTIRE OI301700 corpus byte-for-byte against its contemporary
listings, and the whole AP-101S runtime library likewise.  Nothing in that
result is in doubt, and both harnesses still run.  If either of them breaks
while OI340600 is being worked on, THE CHANGE IS WRONG -- not the harness.

WHERE EVERYTHING IS.  Measured on 2026-08-12, not remembered.

    ~/git/virtualagc/ASM101S/            the assembler
        ASM101S.py                       driver, listing writer, `--compare`
        model101.py                      generateObjectCode -- the passes,
                                         the addressing decisions, DC/DS
        model101tables.py                opcode tables, generateSRS/RS0/RS1,
                                         branchAliases, bvcfAliases, rsMnemonic
        AP-101S-instruction-set.txt      grep this before calling an operation
                                         an unknown macro; check
                                         model101tables.py too
        regressionASM101S.sh             the RUNASM harness

    ~/git/virtualagc/yaShuttle/Source Code/PASS.REL32V0/
        RUNASM/*.asm    205 runtime-library modules
        RUNLST/*.txt    their contemporary listings

    ~/workspace/PFS/                     ITS OWN GIT REPOSITORY, managed
                                         elsewhere -- see the rules below
        OI301700/SSSRC/*.asm             272 modules, all byte-exact
        OI301700/{MLIB80,INCL80,INCLIB}  the macro library, spread over three
        "OI301700 as received"/SSSRC/    the LISTINGS: addresses, object code
        OI340600/SSSRC/*.asm             225 modules -- THIS PHASE
        OI340600/{MLIB80,INCL80,INCLIB}  its own macro library
        "OI340600 as received"/SSSRC/    SOURCE CARD IMAGES, NOT LISTINGS.
                                         Checked: no addresses, no object
                                         code.  There is nothing to compare a
                                         module against, which is the whole
                                         reason for linking.
        mafgen/DASS_*.ASC                the DASS memory dumps, 8 of them
                                         (G2 G3 G8 G9 G16 P9 S2 SSW_(PostIPL))
        mafgenComparison.md              how that comparison is driven
        dass-*.py                        its runnable tooling -- these must
                                         stay current THERE, or that document
                                         is not executable

    ~/donschmidt/nsts-sdl-dps/build/bin/lnk101      THE LINKER.  Also somebody
                                         else's repository, and it holds the
                                         AP-101S emulator as well.

    ~/git/virtualagc/modules/sdfpkg/     the harnesses and the handoffs
        assemble-one.sh                  assemble ONE module of either release
        verify-sweep.sh                  the OI301700 sweep
        classes.py                       classify second-byte mismatches
        dass-handoff.py / dass-handoff.db   THESE handoffs; see below
        dass-notes.py / dass-notes.db    notes staged for OTHER documents

    ~/Desktop/sandroid.org/public_html/apollo/   a local mirror of
                                         ibiblio.org/apollo.  Look here before
                                         fetching any such URL.

THE TWO HARNESSES, AND THE STATE THEY WERE LEFT IN ON 2026-08-12.

    cd ~/git/virtualagc/ASM101S && ./regressionASM101S.sh --no-rtl-fixes
        205 RUNASM modules against their listings.  About 12 minutes.
        Prints PASS/FAIL and exits non-zero if anything differs.
            LEFT AT:  all 205 modules assemble byte-for-byte.

    cd ~/git/virtualagc/modules/sdfpkg && ./verify-sweep.sh OUTFILE
        272 OI301700 modules.  About 25 minutes.  REQUIRES the OUTFILE
        argument and exits on usage without it, which has been misread as a
        run more than once.  Summarise with
            awk -F'\t' '{print $3}' OUTFILE | sort | uniq -c
            LEFT AT:  267 MATCH, 5 MATCH?, 0 DIFFERS.

    OUTDIR=/some/scratch ./assemble-one.sh MODULE [RELEASE] [ASM101S args...]
        One module.  RELEASE defaults to OI301700 and compares against its
        listing; for OI340600 it detects that there is no listing and says so
        rather than comparing against nothing.  Writes MODULE.lst and
        MODULE.obj.

    RUN BOTH BEFORE COMMITTING ANY ASSEMBLER CHANGE, and RUNASM is the one
    that matters most.  181 is the precedent: a change passed the sweep
    cleanly and broke four RUNASM modules, because BILDNEW5 was the only
    module in the whole OI301700 corpus with two control sections and the
    sweep therefore barely exercised the section arithmetic that all 205
    RUNASM modules go through.

WHAT `--compare` REPORTS, and the four categories are not the same thing:

    mismatched   we and the listing both have a byte and they differ.
    missing      the listing has a byte at an address we never wrote.
    uncovered    WE have a byte where the listing shows no object code.  Not
                 wrong -- unverified.  Where it falls in an interior gap the
                 listing brackets on both sides, the gap pins the COUNT even
                 though the values are not shown.  The five MATCH? modules are
                 exactly this, and BILDNEW5's 88 are the `PSA` macro's new-PSW
                 words, which its own `PRINT NOGEN` kept out of the listing.
    beyond       we emit past the end of the listing.  A real discrepancy.

    THE COMPARISON WALKS CARDS IN SOURCE ORDER and checks each against the
    last card that writes each address (`finalWriter`), which is what makes an
    `ORG` that sends the location counter backward compare correctly.

HOW ASM101S IS PUT TOGETHER.  This is what an assembler change has to be
reasoned against, and it is not obvious from the code.

    A PRELIMINARY PASS parses every card and creates "preliminary" symbol
    table entries, so that a forward reference in `USING symbol,register` has
    something to resolve against.  Then

        while passCount < 3 or (repeatPass and passCount < 20):
            collect = passCount in [1, 2]
            asis    = passCount == 2
            compile = passCount >= 3

    PASS 1 collects: it records a "scratch" entry per card and, AT ITS END,
    runs `optimizeScratch()` to a fixed point (up to 20 rounds).  That
    function ONLY EVER SHORTENS -- it rewrites an entry's `length` to 2 -- and
    the number of rounds is not cosmetic: running it once rather than to a
    fixed point costs two byte-exact modules.

    PASS 2 is `asis`.  It CLEARS `sects` entirely and re-assembles with the
    lengths pass 1 settled on.  Anything computed at the end of pass 1 and
    stored in `sects` is therefore DISCARDED -- which is worth knowing before
    spending four entries measuring it, as 199 through 206 did.

    PASSES 3+ compile.  Lengths can still GROW here, which is what
    `repeatPass` exists for: a label that moves, or an inter-section offset
    that changes, asks for another pass, because every instruction already
    assembled on this pass used the old value.

    SECTION LAYOUT.  `sects[s]["used"]` is the high-water mark of `pos1`,
    accumulated naturally by `toMemory` as bytes are laid down.
    `sects[s]["offset"]` places each CSECT after the last, and is recomputed
    on EVERY compile pass -- freezing it at pass 2 was the largest single
    defect of the OI301700 phase.  `symtab[s]["value"]` is the section's
    HASHCODE, not an address.

    ADDRESSES IN LISTINGS ARE HALFWORDS.  `pos1` is a byte offset, so the
    printed address is `pos1 // 2`, and a doubleword is four halfwords.

    HASHCODES.  An expression's value carries the symbol it is relative to in
    bits 36 and up (`hashcodeMask`).  `unhash(v)` returns (section, offset) --
    section None for a pure number -- and NAMES THE SECTION THE REFERENCE
    OCCURS IN, not where the symbol is defined.  `unUsing(using, v)` turns a
    hashed value into (base register, displacement).  An absolute value has no
    hashcode bits, so it cannot match a USING by accident.

THE ENCODING FACTS THAT COST THE MOST TO ESTABLISH.  Every one of these was
measured off the original builds; none is from a manual.

    TWO LENGTHS.  SRS is two bytes, RS four.  The RS second byte is

        (opcode & 0b11111) << 3   |   0b100 if AM=1   |   base register

    -- so for the branch/LA family, whose low five opcode bits are 0b11110,
    AM=0 reads F0..F3 and AM=1 reads F4..F7; for a family whose low five are
    0b11111 the same two forms read F8..FB and FC..FF.  IT IS NOT A FIXED
    TABLE OF BYTE VALUES, and reading it as one wastes time.

    `ib2 == 3` IS BOTH "base register 3" AND THE "no base register" SENTINEL.

    THE SRS SECOND BYTE is `(displacement << 2) | b2`, and for a BRANCH those
    two bits are the FORM SELECTOR, not a base register:

        BCF 00 forward    BVCF 01 forward    BCB 10 backward    BCTB 11

    A backward branch holds its distance as a MAGNITUDE, so the byte is
    4*|d| + 2.  `BNC`, `BOV` and `BOC` test the overflow/carry register rather
    than the condition register and take BVCF's 01 -- SO THEY HAVE NO
    BACKWARD SHORT FORM, since 11 is already BCTB (`bvcfAliases`).  In the
    LONG form the same distinction is bit 3 of byte 0: `rsMnemonic` maps them
    to `BVC`, giving CE for mask 6 where `BC` gives C6.

    THREE CEILINGS, and they are different numbers: srsFloor 0, srsCeiling 55,
    srsBranchCeiling 54.  A literal 56 hid in one of the three decision sites
    for a long time.  THE SAME SHORT-OR-LONG DECISION IS TAKEN IN THREE
    PLACES -- `optimizeScratch`, the branch-alias path and the SRS arm -- and
    they must agree.

    `$` IN A MNEMONIC forces the long form, AM=0, and an ABSOLUTE
    displacement (`forceAM0 = ("$" in operation)`); `@` and `#` set the `ia`
    and `i` bits.  None of them changes which condition is tested.

    A HEXADECIMAL CONSTANT OCCUPIES WHOLE HALFWORDS, right-justified: `DC X'8'`
    is 0008, not 08.  No constant of 5 to 7 digits exists in either corpus, so
    nothing distinguishes rounding up from a halfword minimum; the code
    rounds and says so.

    `LHI` IS AN ALIAS FOR `LA`, so a relocatable operand reaches through a
    USING like any other memory reference.  901 of the corpus's 902 `LHI`
    cards take absolute operands and the 902nd does not.

    A LITERAL POOL BEGINS ON A FULLWORD BOUNDARY whatever it holds, and does
    not count toward its section's `used`.

HOW TO WORK HERE.  These are not style preferences; each one is a mistake
that has already been made and paid for.

    COMPARE HALFWORDS, NOT BYTES.  Byte-exactness is the goal, but BYTE
    granularity is the wrong REPORTING unit and it actively misled the
    OI301700 phase.  `EDF3 1580` against `EDF1 00A6` is one wrong halfword
    pair, not three wrong bytes; `DC X'8'` written as one byte instead of a
    halfword read as "eight wrong values" when it was one wrong LENGTH;
    "8 bytes missing" was the low halves of eight halfwords whose high halves
    happened to agree.  BUILD THE OI340600 COMPARISON TO REPORT HALFWORDS
    FROM THE START, and say how many halfwords differ, not how many bytes.
    User's instruction, 2026-08-12.

    MEASURE, DO NOT RECALL.  Establish a set by grepping for it rather than
    remembering which files were in it, and re-run a measurement rather than
    quoting an old one.  Both failure modes have produced confident wrong
    numbers here.

    TWO DERIVATIONS OF ONE QUANTITY WILL DISAGREE.  This was the cause of
    EVERY defect fixed on 2026-08-12 -- five of them -- and of most before
    that.  When something is computed in two places, the bug is the
    disagreement, not either computation.  When a trap is needed, PRINT THE
    VALUE THAT IS CONSUMED, not only the value that is computed; one trap
    showing both side by side would have saved four entries.

    A UNIFORM RESULT ACROSS A WHOLE CORPUS MEANS THE HARNESS IS BROKEN.  A
    clean zero is the signature of a filter that discarded the evidence.

    ANY SWEEP NEEDS A TIMEOUT, or one hung module blocks the run and it
    reports success with a row missing.  PIPED OUTPUT IS LOST WHEN A COMMAND
    IS KILLED -- all of it, not the tail -- so use `python3 -u` or
    PYTHONUNBUFFERED for anything slow whose output is to be read.

    READ THE ORIGINAL CARD, NOT ONLY THE DIFF.  Three of the five defects
    looked like arithmetic and were length, placement and harness defects; in
    each case the listing text said so immediately and the diff did not.

    OTHER PEOPLE'S REPOSITORIES -- ~/workspace/PFS and
    ~/donschmidt/nsts-sdl-dps -- are managed elsewhere.  PULL IMMEDIATELY
    BEFORE CHANGING ANYTHING, prefer read-only, and say what was touched.
    A directory of symlinks into one of them WRITES THROUGH; check `git
    status` there afterwards.

    COMMIT FINISHED, VERIFIED WORK as part of finishing it, without being
    asked -- and do not commit work that has not been checked.  SHOW
    OUTWARD-FACING TEXT before it is sent.

WHAT WAS FIXED ON 2026-08-12, AND HOW EACH WAS FOUND.  Five defects, four in
ASM101S and one in the source.  Every one was invisible to the OI301700 phase.

    AN `ENTRY` NAMED AFTER ITS OWN CSECT STOLE THE SECTION'S ESD ID.
    `esdIdMap` in objectWriter.py is keyed by name and held sections, label
    definitions and external references in ONE namespace, so `ENTRY X` inside
    `X CSECT` overwrote the SD's id with the LD's.  The TXT card, the RLD
    `posId` and the END entry point all then received the id of a label.
    lnk101 discards an RLD whose posId does not name a section, so EVERY
    RELOCATION IN SUCH A MODULE WAS THROWN AWAY and the halfwords it should
    have patched were left as assembled.

        NO LISTING COMPARISON CAN CATCH THIS, and that is the single most
        important thing on this page.  A listing prints 0000 for an unresolved
        external exactly as a broken object file does, so the whole OI301700
        corpus can be byte-for-byte correct with every relocation in it
        discarded.  Linking is the only thing that reads those records.  This
        phase's evidence is therefore STRONGER than the last phase's, not
        weaker, and a defect class of this shape should be expected wherever
        the object file rather than the listing is what matters.

    A SUBLIST ENTRY MAY CARRY A PARENTHESISED SUFFIX.  `listItem` in
    fieldParser.py matched a nested `(list)` or a bare token and nothing else,
    so `0(R0)`, `0(R3,R2)` and `TPCTFLGS-TPCTSTRT(R2)` ended the list at the
    `(`; `replacement` fell through to its empty-string alternative and every
    real alternative of `operandInvocation0` failed.  That was all 24 SSW
    modules invoking the IF/ELSE/DO/CASE macros -- a family OI301700's library
    does not define at all, so nothing in that phase exercised the rule.

        A TEST THAT OMITS THE TRAILING COMMENT CONFIRMS THE WRONG THING.
        `operandInvocation0` ends in a catch-all, `/[^ ]+/ / */ $`, which
        accepts any single non-blank run at end of input.  So
        `(TB,0(R0),FPMUSED,NZ)` parses and `(TB,0(R0),FPMUSED,NZ) THEN` does
        not, and every real card has a comment after the operand.  The correct
        hypothesis was nearly discarded on the strength of a test that left the
        comment off.  The minimal case is `(A,B(C)) X`.

    TWO DEFECTS IN ONE SETC VALUE.  A doubled quote inside a quoted string is
    ONE quote character, and evalCharacterExpression joined the pieces around
    each `''` and dropped the quote, so `&RESERVE SETC 'H''0'''` gave `H0` and
    `&X 4&RESERVE` arrived as the unparseable `DC 4H0`.  Separately, `value[:8]`
    imposed ASSEMBLER F's length limit on an ASSEMBLER H library: it did not
    reject an over-long value, it TRUNCATED one, so a generated card was cut
    off mid-symbol and surfaced as an operand naming a symbol that does not
    exist -- `DC Y(FCMTRA`, every such operand exactly eight characters wide,
    which is what gives it away.  TFPSA builds a whole PSW pair in one SETC.
    Neither fix alone repairs a module: with only the quote repaired FCMPSA
    goes from 128 intolerable lines to 55, all of them the truncation.

    TWO ADJACENT VARIABLE REFERENCES LOST THE FIRST ONE.  svReplace walked its
    matches in REVERSE and re-sliced `text` after each replacement, on the
    reasoning that later replacements cannot disturb earlier indexes -- true of
    the indexes, false of the text.  A variable whose right-hand neighbour had
    already been replaced was re-parsed against that REPLACEMENT: in
    `X&OPS&CNT` with &OPS=TB and &CNT=0, `&CNT` became `0`, `text[start:]` was
    then `&OPS0`, and `nameSet0` read all of that as the variable name `&OPS0`,
    `0` being a legal character in a name.  No such variable existing, the
    occurrence was left alone.  Each reference is resolved against the ORIGINAL
    text now and the result built forward, which cannot fail this way because
    nothing is ever parsed out of a replacement.  An explicit `.` join hid the
    defect, so `Y&OPS.&CNT` was always right and `X&OPS&CNT` never was.

    FPMSWTCC WAS AN ASSEMBLY MACRO CARRYING A .hal EXTENSION.  A source defect,
    fixed in PFS (OI340600/MLIB80, commit 332b831b): MACRO / FPMSWTCC /
    IF-CALL-ENDIF / MEND, with a `Language: HAL/S` header and C/ comment
    markers.  It failed two independent gates -- makeMACROFILES.py considers
    only .asm and .bal and read the 25-line C/ header as code outside the
    macro, and loadLibraryMacro tries only NAME and NAME.asm, so a .hal member
    is unreachable whatever the index says.  Five modules invoke it and none
    would assemble.  It is the only such member: no other file in MLIB80
    outside .asm/.bal contains an assembly MACRO card.

    A CONTINUED OPERAND'S PADDING WAS JOINED INTO THE OPERAND.
    `operandFieldEnd` tracks parenthesis depth and a blank at depth > 0 does not
    end the operand field, so when a card ends with a sublist's outer `(` still
    open it returns len(text) and the padding out to column 71 survived the join.
    DOPROC's `STKINS (&WHILE(1),...,&WHILE(4),` continued by `&WHILE(5),&LIND(&LI))`
    joined as `...&WHILE(4),      &WHILE(5)...` and substituted to
    `(CH,R2,NE,FIELD,      ,#@LB2)`.  A `listItem` cannot match a blank, so the
    sublist parse died and STKINS was invoked with an EMPTY &P1 -- which sent it
    down its .NOTSUBL/.SGLOPR path, stacking no comparison and leaving &CCVAL
    unset.  A DO WHILE therefore emitted its forward branch and its loop top but
    never the test the branch was aimed at, so `#@LB2` was never defined.  Inside
    a character literal those blanks are DATA, so the strip is guarded by
    `insideQuote`.  Eight modules, and the last assembly failure in SSW.

        TWO METHOD NOTES, because this one resisted the longest.  FIVE synthetic
        reproductions of the failing card all PASSED, including its two cards
        copied verbatim -- which was not evidence the cards were sound but that
        the harness did not reproduce the context.  What settled it was trapping
        the value CONSUMED inside the assembler, which is the rule this file
        already states and which was reached late.  And two rounds of macro
        instrumentation reported a FALSE cause because the instrumentation was
        itself broken: once an MNOTE whose own string was mangled, once an edit
        that shifted a card 8 columns and pushed its `X` out of column 72,
        destroying the very continuation under test.  ASSERT THAT NO EXISTING
        CARD MOVED before believing a trace of a macro library.

EVERY ONE was verified against BOTH harnesses before committing -- RUNASM 205
of 205 byte-for-byte, and verify-sweep.sh identical module for module at 267
MATCH, 5 MATCH?, 0 DIFFERS.  Neither harness can FAIL because of an
objectWriter change, since both compare listings; run them anyway, because that
is how you learn the change did not reach further than intended.

[why] Five defects in one day, four in ASM101S and one in the source, all found by LINKING rather than by any listing.  Recorded per defect because each carries a method lesson that generalises, and because the SSW numbers are meaningless without knowing which fixes were in the tree when they were taken.

WHY.  Five defects in one day, four in ASM101S and one in the source, all found by LINKING rather than by any listing.  Recorded per defect because each carries a method lesson that generalises, and because the SSW numbers are meaningless without knowing which fixes were in the tree when they were taken.

THE MODULES THAT LINKED CLEANLY AND STILL DIFFERED are now none.  There were
30 of them on 2026-08-12; four causes account for all 30, and after them SSW
stands at 63 modules PASSing, 113 forced links, and ZERO differing silently.

    AN AM=0 DISPLACEMENT NAMING THIS SECTION WAS NOT RELOCATED.  An AM=0
    displacement is the whole effective address, so where it names a location
    in the module the linker has to fill it in; nothing was emitted and the
    field kept the section-relative offset.  `b2 == 3` IS THE "NO BASE
    REGISTER" SENTINEL HOWEVER IT GOT THERE -- from the fallback meaning "no
    USING matched but the target is in this section", or written on the card as
    `FCMWRAP(R3)` -- and only a USING-supplied base must be left alone.  A
    DSECT target must not be relocated either: `LH R3,TPSATENT` is base 3 and
    AM=0 too, but TPSATENT is a PSA location at absolute 8.  FCMTRACE is the
    whole defect in two cards, its only two `$` forms.

    A TAKEN BRANCH LEFT THE CONTINUATION SKIP ARMED.  `parseLine` returns how
    many continuation cards a statement consumed and the top of the expansion
    loop skips that many; a taken AIF or AGO sets the line to its target and
    the count was still the BRANCHING statement's, so a CONTINUED branch
    SILENTLY ATE ITS OWN TARGET CARD.  No diagnostic of any kind.  STKINS's
    `.NOTSUBL` AIF is continued and branches to `.SGLOPR GETCC &P1(1)`, so
    GETCC never ran and &CCVAL kept the PREVIOUS condition's value: a bare
    `IF (LT)` after an `IF (...EQ...)` assembled with the EQ mask.  THIS HAD
    THE WIDEST REACH of the four -- 25 modules outside the 30 improved as well.

    DUPLICATE NAMES IN THE CSECT INDEX RESOLVED TO A PRIVATE LABEL.  Not our
    defect and not lnk101's: augmented-CONFIG.json records the symbols MAFGEN
    recovered inside each CSECT without marking which were ENTRY points, so
    where a name occurs twice there is nothing to choose on.  FPMDISP declares
    `EXTRN FPMAREGS`, FCMCBLKS declares `ENTRY FPMAREGS`, and FPMSDERR happens
    to have a private one; lnk101 took the private one.  csect-disambig.py
    rebuilds the index from the sources' own ENTRY declarations.

    BCE AND MSC ADDRESS WORDS CARRIED NO RELOCATION, and the field is wider
    than a halfword and narrower than a fullword -- 24 bits for the BCE
    ADDRESS layout, 18 for the MSC long form -- while the format has only YCON
    at 2 bytes and ACON at 4 (ap101Utils/addrcon.py).  AN ACON OVER THE WHOLE
    WORD IS THE WAY THROUGH, because a relocation ADDS rather than replaces:
    lnk101 computes `existing + target` and masks to the length, so the opcode
    already sitting in the top byte survives and the address fills in beneath
    it.  FA000000 + 8BC6, F0000000 + 1CB4C and F3080000 + 199CE are all
    exactly what the dump has.  It needs the addend plus the target not to
    carry out of the address field, which nothing here approaches.

WHAT NONE OF THIS COULD HAVE BEEN FOUND BY.  All four are invisible to a
listing: a listing shows the same bytes whether or not an RLD accompanies them,
and shows nothing at all about the index a linker resolves against.  Both
listing harnesses stayed green through every one of these commits, and were run
each time not to test the fix but to show it moved nothing else.  THE
COMPARISON AGAINST THE DUMP IS THE ONLY TEST THESE CHANGES HAVE, which is the
argument for this phase's method in its strongest form.

AND ONE CHANGE WAS REVERTED FOR MEASURING NOTHING.  Checking `rextrns` before
`unhash` can bail out is plausibly more correct -- an external names no section
of ours -- but the object's relocation count was 354 either way, so it fixed
nothing real and was backed out rather than committed behind a message
implying otherwise.

WHY.  Every one of these is a RELOCATION defect or a CSECT-index defect, and not one could have been found from a listing.  Recorded per cause because each generalises well beyond the module that exposed it.

FCMBMT16's five differing chunks in G16 -- and the same signature in G2, G3
and G8 -- come from ONE line of MLIB80/FCMBMTMC.asm:

    &GPSFF1  SETA  0   DEFINE GPS FF1 NOT AVAILABLE FOR BYPASS/RESTORE  010912BI
    &GPSFF3  SETA  0   DEFINE GPS FF3 NOT AVAILABLE FOR BYPASS/RESTORE  010913BI

The contributed OI340600 source switches the GPS FF1/FF3 entries out of the
bypass/restore tables; the dumps hold them.  Both flags are 1 in the build the
dumps came from.  ASM101S is not at fault -- nothing is dropped, the macro
expands correctly, and the OI301700 conclusion that FCMBMTMC assembles right
still stands.

HOW IT WAS FOUND, because the method generalises and the arithmetic does not.
Offset arithmetic on the differing chunks gave three mutually inconsistent
answers in a row: the BMT rows are a regular arithmetic sequence, so a shifted
table matches itself at many alignments and every one of them looks like a
find.  What settled it was aligning the two ENTRY SEQUENCES BY SYMBOL --
resolve each row's first halfword through the CSECT table to its TFIV/TFOV
buffer name, and compare the name sequences.  That is immune to the repetition.
It showed our build displaced by 5 halfwords from TFIVMI51 onward and by 10
from TFIVMI71 onward: precisely the entries following .BCEG1 and .BCEG3, the
labels the two flags branch to.

THE ROW ENCODING, verified against FCMBMTPG, which matches its dump exactly:

    DC Y(&BUFFER)                        DC Y(TFIVMI13)
    DC Y(&FLAG+DISP&LSTCNT)              DC Y(CMDRLST+DISP3)
    DC Y(FIOBY&LMNT)                     DC Y(FIOBY04C)
    DC Y(&DLAYCNT*256+&NUM)              DC Y(25*256+MF1TACAN)
    DC XL.8'&ANNUN',YL.8(&ERTBL-FIOERRTB)

DISP is 3*(listener index - 1), so a row names its own listener slot.  Rows are
five halfwords EXCEPT the RTWD form (BMTENT ... ,RTWD,,...) which is shorter --
assuming a uniform stride is what produced two of the three wrong answers.

RESULT.  With both flags 1, all 49 locatable G16 entries fall at the dump's
addresses (7 of 47 before), the size mismatch goes, and 7 halfwords still
differ -- all of them 0000 against a pointer into the interior of FIOHFE16,
which no single-object forced link can resolve.  That is the ceiling of this
method, not a defect.

THE RECONSTRUCTION lives in ~/workspace/PFS/OI340700/MLIB80/FCMBMTMC.asm (PFS
6c773bd6): the OI340600 file with those two values changed, headers and history
saying it is recovered rather than contributed, and the derivation inline above
the changed lines.  Only non-empty directories are created.  CONFIRMATION IS
NOT AVAILABLE YET and will not be soon: the linker currently forces every CSECT
to the dump's address, so a full unforced link needs the whole of OI340700
reconstructed first, and the object ordering for lnk101 is itself unsolved.

WHY.  FCMBMT16 was called a source change on 2026-08-12 on the strength of a
symbol FCMBMTMC never mentions.  That was right about the conclusion and wrong
about the reasoning, and the wrong reasoning nearly sent the next session
disassembling halfwords to invent source that already existed.

Measured 2026-08-13, every FCMBMT module in its own configuration, both flag
states, identical options (so these numbers are comparable to each other and
NOT to the sweep's, which resolves more externals):

  G16  FCMBMT16   1036 vs 1076 (-40)  ->  exact, 7 halfwords differ
  G2   FCMBMT02    896 vs  936 (-40)  ->  exact, 3 halfwords differ
  G3   FCMBMT38    944 vs  984 (-40)  ->  exact, 7 halfwords differ
  G8   FCMBMT38    944 vs  984 (-40)  ->  exact, 7 halfwords differ
  G9   FCMBMTG9   1344 vs 1334 (+10)  ->  1384 vs 1334 (+50), WORSE
  P9   FCMBMT89   PASS                ->  PASS, no regression
  S2   FCMBMTS2   ASMFAIL             ->  ASMFAIL, a separate defect
  SSW  FCMBMTPG   9 halfwords differ  ->  9, untouched by the flag

The flag adds 40 halfwords in every configuration.  Four are short by exactly
40 and become exact.  EVERY halfword still differing in those four is our 0000
against a real pointer -- externals a single-object forced link cannot resolve,
which is this method's ceiling and not a content error.

G9 IS THE ONE TO WORK NEXT.  It is 10 halfwords LONG before the change, so our
source emits two BMT rows the dump lacks -- the opposite defect -- and the
flags take it to +50.  Because the two SETAs are unconditional, an
unconditional 1 would put GPS rows into G9's tables and G9's dump has none.  So
1 is right for the four and cannot be the whole story: either the original
gated these flags on &OPS, or G9's surplus masks the real arrangement.  Settle
G9's +10 first; it is two rows, and the symbol-sequence alignment will name
them.

A MEASUREMENT TRAP worth knowing: when a section differs in SIZE, fcmcmp
compares only the overlap and prints no halfword verdict, so a script counting
'@' lines reports a number that means nothing.  Read the 'N halfwords differ'
line, and read the '(+N)' size line beside it.

WHY.  The entry above was written from G16 alone.  Measured across the family the
next hour, four configurations confirm it and one contradicts it, and a
reconstruction believed settled is worse than one known to be open.

CORRECTION to the entry above.  The G9 dump DOES hold the GPS rows.  The
halfwords at FCMBMTG9+04E and +111 decode as

    630A 1024 DD32 4461 68A4   TFIVGPS1, FIOBY1GC, &DLAYCNT=68, num=97
    6352 1087 DD52 4463 6AAC   TFIVGPS3, FIOBY3GC, &DLAYCNT=68, num=99

which is exactly what the gated invocations at FCMBMTMC lines 455 and 762
generate, and our build emits only TFIVGPS2, which no flag gates.  Setting the
flags cuts G9's differing halfwords from 1157 to 893.  So an unconditional 1 is
supported by G9 as well, and the flags need no &OPS gating.

WHAT IS ACTUALLY WRONG WITH G9 is a surplus of its own: 1344 against an
expected 1334 before the change, 1384 after.  Roughly 50 halfwords this source
emits that the dump does not hold, somewhere not yet identified, and while it
stands the module is misaligned end to end -- which is the whole reason its
halfword counts are in the hundreds in both states.  G16 read 914 differing
before its own size was fixed and 7 after; a size shift cascades, and a large
count is a symptom of that, not a measure of how wrong the content is.

TWO TRAPS THIS COST.  A size mismatch makes fcmcmp compare only the overlap and
print no halfword verdict, so counting '@' lines yields a meaningless number --
read 'N halfwords differ' and the '(+N)' beside it.  And the symbol-sequence
alignment that settled G16 is NOT reliable on G9: only 54 of its dump rows
resolve to a name, against 93 in our build, so difflib reports most of the
RTWD rows as deleted when they are merely unresolvable.  Its INSERT results are
still trustworthy -- that is how the GPS rows above were found -- but its
deletes are not.

WHY.  The entry above read G9's size as contradicting the flags.  That was wrong,
and left standing it would have sent the next session hunting a conditional
that does not exist instead of the surplus that does.

FCMBMTG9's 50 surplus halfwords come from MLIB80/FIOMDPVU.asm ('VU' = vehicle
unique), which populates the flex-MDM element arrays:

    &FLX1ELM(15) SETA 105     &FLX2ELM(15) SETA 109
    &FLX1ELM(1)  SETA 106     &FLX2ELM(1)  SETA 110
    &FLX1ELM(2)  SETA 107     &FLX2ELM(2)  SETA 111
    &FLX1ELM(3)  SETA 108     &FLX2ELM(3)  SETA 112

FCMBMTMC emits each payload element only when its slot is non-zero --
AIF (&FLX1ELM(n) EQ 0).ASFLX34 -- and the surplus halfwords carry those exact
numbers: Y((12+2*(1+1))*256+107), Y((12+2*(0+1))*256+108) and
Y((12+2*(0+1))*256+112).  Our source enables elements the dump's build had
zeroed.  Each costs a BMT row plus its listener, return-word and NUM/FCMRST
companions, which is why the surplus arrives in five regions of 15, 5, 6, 12
and 12 rather than as one block.

THIS IS FLIGHT DATA, NOT CODE.  Payload MDM assignments change per flight, so
FIOMDPVU is expected to differ between the source we hold and a 2010 dump.  It
is the same class of difference as the GPS flags and equally not an ASM101S
defect.  WHICH slots were zero is NOT yet pinned -- the five regions account
for the 50 halfwords but their boundaries are approximate, and elements 106
and 111 sit close enough to the edges that the exact set needs the row-level
decode before any FIOMDPVU reconstruction is written.

THE METHOD THAT FOUND IT, for the next module whose rows will not align by
symbol.  Take the LINKED image and its rldanalyze .json, treat every halfword
NOT named in 'relocations'/'unresolvedRelocations' as an anchor (513 of 1384
here), then segment greedily: walk the anchors, and at the first mismatch try
every shift and take the one with the longest forward run of agreement.  That
gave 0 -> -15 -> -20 -> -26 -> -38 -> -50 with runs of 9, 71, 5, 6 and 9, and
90 percent of all anchors agreeing under the resulting piecewise map against
17 percent flat.  Windowed voting was tried first and put the boundaries in
the wrong places; the greedy run-length version is the one to use.

WHY.  The surplus was assumed to be more of the same file.  It is a different file
entirely, and a class of difference -- per-flight configuration data -- that
will recur across the corpus and should be recognised on sight.

PINNED.  All eight &FLX1ELM/&FLX2ELM element slots were 0 in the build the
dumps came from.  Recovered file: ~/workspace/PFS/OI340700/MLIB80/FIOMDPVU.asm
(PFS db6f5bdb), eight lines changed, sequence numbers intact.

THE TEST, and why this one rather than an alignment.  Every payload flex row
ends in a halfword whose high byte is the annunciator: 5C on the six element
rows, 5D on the two return-word rows.  Scanning both module images for high
byte 5C or 5D needs NO shift map at all: ours holds exactly eight, the G9 dump
holds NONE, anywhere.  Corroboration: zeroing the slots lifts non-relocated
halfword agreement from 90 to 98 percent, and removes 82 halfwords (1384 ->
1302).  G9 is the ONLY configuration that reaches this block -- G16, G2, G3,
G8, P9 and SSW have no 5C/5D halfword in either image -- so nothing else can
corroborate, and payload MDM assignments are per-flight data anyway.

&FLX1CNT/&FLX2CNT are deliberately left at their contributed values.  With the
element slots zero nothing reads them, so the dump cannot show what they held;
changing them would be invention.

WHAT REMAINS.  With the slots zeroed FCMBMTG9 is 1302 against 1334 expected --
32 halfwords SHORT.  Segmenting the anchors gives four clean regions of 5, 15,
3 and 9 halfwords, which is four BMT rows and four listener rows the dump holds
and this source does not.  Cause unknown and NOT in FIOMDPVU.

A WARNING FOR WHOEVER DECODES THEM.  I tried decoding those four rows by
assuming where each began and got flag=0x5000 and listener #1254 -- readings
that are not possible, because the row phase was guessed wrong.  A decode whose
&FLAG is not 0x1000 or 0x0000 and whose listener index exceeds the table is
mis-phased, not a discovery.  Establish the row boundary from a neighbouring
row that our own listing names before reading any field.

WHY.  Pinning them needed a test that does not depend on address alignment, because
every alignment-based attempt on G9 so far has produced a confident wrong
answer.  The test that worked is worth having written down.

THE PREVIOUS ENTRY IS WRONG.  Scanning for annunciator 5C/5D found none in the
G9 dump and I concluded the payload flex slots were zero.  The elements ARE
there; they carry a DIFFERENT annunciator.  Listing every payload row by its
element number, no alignment assumed:

    ours  85 86 87 88 89 90 94 113
    dump  85 86 87 88 89 90 94 105 106 107 108 109

105-109 are &FLX1ELM(15),(1),(2),(3) and &FLX2ELM(15).  In our build they come
out of the SINGLE FLEX block with ANNUN 5C/5D and &AERRLBL=FIO52N10.  In the
dump they come out of the LPF block with ANNUN 5E/5F and FIO52M10/FIO52M11 --
a different array family, &LPF1ELM/&LPF2ELM, declared beside the FLX arrays in
FIOGLBL and set in the same vehicle-unique file.

READ BY GROUP, the dump interleaves them exactly where LPF slots would fall:

    5E group   ours 113 85 86 87        dump 105 106 85 86 87
    5F group   ours  94 88 89 90        dump  94 107 108 109 88 89 90

So 113 is replaced by 105 and 106 in LPF1, and 107, 108, 109 are added to LPF2.
Our FIOMDPVU sets only &LPF1ELM(2)=113, &LPF1CNT(2)=6 on that side.

THE HYPOTHESIS TO TEST, fully pinned including the counts.  The invocations
read ...,&LPFnELM(k),&LPFnCNT(k),1,LSTNR,xxL,&LPFnCNT(k),5E/5F,&AERRLBL, so
&DLAYFLG=1 and the delay high byte is 12+2*(cnt+1).  The dump's high bytes give
the counts directly:

    105 hi=28 -> cnt=7      106 hi=14 -> cnt=0
    107 hi=28 -> cnt=7      108 hi=14 -> cnt=0      109 hi=18 -> cnt=2

so FIOMDPVU should read &LPF1ELM=105 cnt 7 and 106 cnt 0, &LPF2ELM=107 cnt 7,
108 cnt 0, 109 cnt 2, no 113, and all eight &FLX1ELM/&FLX2ELM slots 0.  WHICH
SLOT INDICES those occupy is NOT pinned -- the group ordering says LPF1 takes
the two lowest and LPF2 the next three, but the block must be read to confirm.
One build settles it: FCMBMTG9 should come out at 1334 halfwords exactly.

THE LESSON, which cost two wrong conclusions on this module.  An
alignment-independent test is only as good as its question.  'No 5C/5D rows
exist' was true and meant nothing, because the rows had moved annunciator.
Enumerate the ELEMENTS present on both sides and diff those sets; the element
number survives every re-gating, re-labelling and relocation, and it is the
only field here that does.

WHY.  The previous entry pinned the slots at zero on a test that asked the wrong
question, and a reconstruction was committed on it.  The file has been
withdrawn (PFS aaeed393).  The corrected reading is testable in one build.

FCMBMTG9 NOW LINKS TO 1334 HALFWORDS, exactly the length the CSECT table
gives, against 1384 before.  12 halfwords differ: 11 are our 0000 against a
pointer a single-object forced link cannot resolve, and one, TFIVMCI1, is the
reverse -- the dump holds 0000 where we hold a pointer.  Recovered file:
~/workspace/PFS/OI340700/MLIB80/FIOMDPVU.asm (PFS c1e5932d), together with the
recovered FCMBMTMC.  Both are needed; neither alone gives 1334.

THE SLOT INDICES, read from the element codes rather than inferred from
position.  FCMBMTMC ties each slot to a fixed element code -- LPF1ELM(2) to
LAC, (3) to LBC, LPF2ELM(2) to LOC, (3) to LPC, (4) to LQC -- and the dump's
five added rows point at FIOBYLAC, FIOBYLBC, FIOBYLOC, FIOBYLPC and FIOBYLQC in
that order.  The counts fall out of the delay halfword, whose high byte is
12+2*(count+1) because those invocations pass a delay flag of 1:

    LPF1ELM(2)=105 CNT 7        LPF2ELM(2)=107 CNT 7
    LPF1ELM(3)=106 CNT 0        LPF2ELM(3)=108 CNT 0
                                LPF2ELM(4)=109 CNT 2

Both chains terminate on the first zero slot -- the AIF branches past all
higher slots, it does not gate them individually -- so LPF1ELM(4) and
LPF2ELM(5) staying unset is what ends them.  All eight FLX slots go to 0, and
113 disappears.

A TRAP THAT COSTS 16 HALFWORDS SILENTLY.  A comment line in these members must
end by column 71.  At 72 or beyond the assembler sees a non-blank in the
continuation column and swallows the following statement.  My recovery note had
75-column separator rules; the module built clean, reported no diagnostic, and
came out 16 halfwords short.  It was caught only because the length stopped
matching 1334.  NOTHING WARNS YOU.  Check comment width after editing any of
these files, and be aware the contributed source itself has a 72-column line
that is harmless only because of where it sits.

HOW THE SEARCH ACTUALLY WENT, since three of its steps were wrong.  Offset
arithmetic gave inconsistent boundaries; a symbol-sequence diff mis-reported
unresolvable rows as deleted; and an 'alignment-independent' scan for
annunciator 5C/5D found none and produced a confidently wrong conclusion that
the flex slots were zero, which reached a committed file before it was caught.
What finally worked was enumerating the ELEMENT NUMBERS present on each side
and diffing those sets.  The element number is the only field that survives
re-gating, re-labelling, relocation and re-ordering.  Reach for it first.

WHY.  This closes the module, and the 71-column trap it exposed will bite anyone
adding a comment to any of these files.  Both belong where the next session
reads them, not in a commit message.

A NON-BLANK in column 72 of a comment line continues it, and the continuation
swallows the statement that follows.  A SPACE in column 72 does not: the
standard Virtual AGC anonymization boilerplate reaches 72 columns via two
trailing spaces and sits in 277 files of MLIB80 doing no harm.  That
boilerplate line is the ONLY comment past column 71 in any contributed file
touched here.

DEMONSTRATED, not inferred.  Taking the recovered FIOMDPVU and changing NOTHING
but the width of two rule-off lines, from 71 columns to 75 so a dash lands in
column 72, takes FCMBMTG9 from 1334 halfwords to 1318.  Restoring the width
restores 1334.  No diagnostic is issued in either case.

THE RULE-OFF LINES ARE NOT HISTORICAL.  Neither OI340600's nor OI301700's
FCMBMTMC contains a line of dashes anywhere; they exist only inside the
recovery notes written for OI340700, which is to say I introduced them.  Any
statement below about their behaviour is a statement about those added lines,
not about contributed source.

THE CASE THE RULE DOES NOT EXPLAIN.  The recovery note added to FCMBMTMC
carried 75-column rule-offs immediately before its GPS SETA statements for a
whole session, and FCMBMT16 still built exact at 1076 halfwords with 7
differing.  Same shape as FIOMDPVU, no loss.  A plausible difference is that
FIOMDPVU is open code while FCMBMTMC's note sits inside a macro definition, so
comment continuation may be handled differently in the two contexts -- BUT THAT
IS UNTESTED and is written here as a lead, not a fact.  If it matters to
something you are doing, test it; do not rely on it.

PRACTICAL RULE: keep every added comment inside column 71 in all of these
files.  It costs nothing, and the failure it avoids is silent -- the module
assembles clean, reports nothing, and comes out short.

WHY.  The rule was first written down from a guess that happened to be right, and
half of the guess was wrong.  Both halves are recorded here so nobody has to
rediscover which is which.

Measured 2026-08-13 with BOTH ~/workspace/PFS/OI340700/MLIB80/FCMBMTMC.asm and
FIOMDPVU.asm in place, every FCMBMT module in its own configuration:

  G16  FCMBMT16   1076 halfwords, size exact,   7 differ
  G2   FCMBMT02    936 halfwords, size exact,   3 differ
  G3   FCMBMT38    984 halfwords, size exact,   7 differ
  G8   FCMBMT38    984 halfwords, size exact,   7 differ
  G9   FCMBMTG9   1334 halfwords, size exact,  12 differ
  P9   FCMBMT89   PASS
  S2   FCMBMTS2   ASMFAIL, 81 intolerable errors
  SSW  FCMBMTPG   1172 halfwords, size exact,   9 differ

NOT ONE SIZE MISMATCH REMAINS in the family.  Before the recovery, G16, G2, G3
and G8 were each short by exactly 40 and G9 was long by 10, and a size shift
misaligns a module end to end, so those five reported differences in the
hundreds.  They now report single digits, and every one of those is our 0000
against a pointer a single-object forced link cannot resolve, except G9's
TFIVMCI1 which is the reverse.

NO REGRESSION.  P9 passed before and passes now.  SSW was 9 before and is 9
now, untouched by either change.  S2 fails to assemble with 81 intolerable
errors, the SAME 81 as at baseline -- checked, not assumed -- and is a separate
defect that predates all of this work.

WHY.  A recovery that fixes one configuration and quietly breaks another is worse
than none, and neither recovered file is configuration-specific: FCMBMTMC
builds every FCMBMT module and FIOMDPVU is read by all of them.

FIXED (virtualagc 75fd39842, ASM101S/expressions.py).  svSet already declared
an undeclared SCALAR SET symbol on first assignment.  Its own comment gives the
reason: the System/360 manual requires a declaration, but AP-101S assembly
language is expected to have a convenience feature supplying one.  The
SUBSCRIPTED form was never extended the same way and fell through to 'Symbolic
variable undeclared'.

FCMBMTMC needs it.  It assigns four payload high-rate comfault mask tables --
APLHRM, APLHRNM, BPLHRM, BPLHRNM -- with no LCLC or GBLC anywhere; the entire
file declares only HWORD0/1/3 and PASSOPS.  Only one OPS reaches that block, so
FCMBMTS2 alone failed: 81 intolerable errors, 64 of them those four names at 16
uses each, and 4 more DC operands unparsable because the substitution had not
happened.  The remaining 11 diagnostics are Pass 1 Severity 0 undefined
symbols, which are forward references and normal.

ON PROVENANCE, because it decides whether this is a fix or a licence.  The rule
being relaxed can only have come from System/360 documentation -- there is no
AP-101S macro-language manual -- and this dialect is already known to extend
System/360.  The evidence for the extension is the flight software: these decks
were assembled successfully at the time, and this one has no declaration.  An
implicitly declared array takes its dimension from the highest subscript
assigned, so it grows.  ONE DECLARED WITH LCLC OR GBLC STILL ERRORS on an index
past its stated dimension, and that must stay: there the out-of-range index is
a real defect.

NO REGRESSION, measured rather than argued.  Every configuration is unchanged
after the fix: G16 1076/7, G2 936/3, G3 984/7, G8 984/7, G9 1334/12, SSW
1172/9, P9 PASS.

WHAT S2 NEEDS NEXT.  FCMBMTS2 now links, at 516 halfwords against 368 expected
-- LONG BY 148, by far the largest surplus in the family, and 434 halfwords
differ.  That is a fresh problem and almost certainly a source difference of
the kind already seen twice here.  Start with the element-set enumeration that
settled G9; do not start with an alignment.

WHY.  This is the first defect of the phase that was genuinely ASM101S's rather than
a source difference, and the reasoning that justifies it is the same reasoning
already written into the code for the scalar case.

WHERE S2 STANDS.  FCMBMTS2 assembles clean since virtualagc 75fd39842 and
links at 516 halfwords against 368 expected, LONG BY 148.  My two recovered
OI340700 files make no difference to it at all -- measured both ways, 516 and
434 differing either way -- so nothing here is a regression from them.

THE SURPLUS IS ALL PAYLOAD.  Comparing label offsets rather than halfwords
localises it exactly: FCMBPASS is 130 halfwords in the table and 255 in our
build (26 rows against 51), and the gap between the listener table and
FCMRESTR is 14 against 37.  The listener table is IDENTICAL, 11 rows in both,
so the 25 extra BMT rows register no listeners.  By annunciator, the extras are
17 of 5C, 4 of 5D, and one each of 5B, 5E and two of 5F -- 25 exactly.

S2'S DUMP HOLDS THE SAME PAYLOAD SET AS G9'S, element for element:
85 86 87 88 89 90 94 105 106 107 108 109, with 105/106 under annunciator 5E and
107/108/109 under 5F.  Ours holds 105 plus 107-135 spread across 5B, 5C, 5D,
5E and 5F.

BOTH VEHICLE-UNIQUE FILES ARE READ FOR S2.  FIOMDPS2 assigns LPF 110-115 and
FLX 116-135; FIOMDPVU assigns FLX 105-112 and LPF1ELM(2)=113.  Zeroing only
FIOMDPS2's element slots left 388 (+20), because FIOMDPVU's arrays were still
supplying rows.  Zeroing FIOMDPS2's slots entirely AND using the recovered
FIOMDPVU gives 362 -- SIX SHORT of 368, from +148.

THE LAST SIX HALFWORDS, and they are not noise.  One row is missing outright,
element 106, which the dump has under 5E.  Three more elements are emitted
under the WRONG annunciator: 105 comes out under 5B where the dump has 5E, 108
under 5E where the dump has 5F, and 109 under 5C where the dump has 5F.  The
ELEMENT SET is therefore right and the BLOCK that emits each is not, so the
remaining question is which array slot feeds which block for OPS S2 -- not
which elements the flight carried.  Note the LPF invocations hardcode their
annunciator, so a row appearing under 5B or 5C did NOT come from the LPF block.

DO NOT GUESS THE SLOTS.  Read the block for OPS S2 the way the G9 slots were
read: each invocation ties a slot to a fixed element code, and the dump's rows
point at those codes.  Nothing about S2 has been committed.

WHY.  S2 stops at a point worth resuming from rather than a dead end, and the last
six halfwords say something specific about which block emits an element.
Written down while the measurements are fresh; nothing here is committed.

THE QUESTION WAS WRONG.  Neither file is read second, because FIOMDPVU IS NOT
READ FOR S2 AT ALL.  SSSRC/FCMBMTS2.asm copies exactly two members:

         COPY FIOGLBL                                              000600
         COPY FIOMDPS2                                             000700

and FCMBMTMC states the scheme in its own commentary at line 231: FIOMDPS2 is
copied in FCMBMTS2, FIOMDPS4 in FCMBMTS4, FIOMDPVU in the others.  The MDP
members are also commented OUT of MLIB80/MACROFILES.txt, so none of them is
read as open code either; only the COPY brings one in.  One vehicle-unique
file per module, chosen by the module.

MY EVIDENCE FOR 'BOTH ARE READ' WAS AN ARTEFACT.  The two runs I compared
differed in BOTH files, so a change caused by FIOMDPS2 was attributed to
FIOMDPVU.  The clean single-variable test had already been run and says the
opposite: contributed versus recovered FIOMDPVU, with FIOMDPS2 untouched, gives
516 halfwords and 434 differing BOTH TIMES.  FIOMDPVU does not affect S2.

WHAT THAT MEANS FOR THE MEASUREMENTS.  Only FIOMDPS2 varies, so they reduce to:

    FIOMDPS2 contributed                        516   (+148)
    LPF 105-109, FLX 0, DUL 0                   382    (+14)
    everything 0 except DUL1ELM(1)=105          362     (-6)
    everything 0                                358    (-10)

target 368.

AND THE 'THIRD SOURCE' IS NOT ONE.  With every element slot in FIOMDPS2 zeroed
the module still emits rows carrying 107, 108 and 109.  No other file assigns
these arrays -- FIOGLBL declares them but assigns nothing, and FCMBMTMC assigns
none.  So those rows are NOT array-driven: they come from invocations that pass
a literal &NUM whose symbol happens to have that value.  MY ELEMENT-SET METHOD
CONFLATES THE TWO.  It worked on G9 because the added rows were array-driven;
on S2 it silently mixes array rows with hardcoded ones, which is why the counts
would not reconcile.

SO THE NEXT STEP IS TO SEPARATE THEM.  Take the rows by ANNUNCIATOR, which
names the array family, and within a family match the invocation rather than
the element number: 5E is LPF1ELM(k) k=2..9 as TFIVPF12..PF19 with codes LAC
LBC LCC LDC LEC LFC LGC LHC, 5F is LPF2ELM(k) on the B side, 5B is DUL1ELM and
DUL3ELM, 5C and 5D are the FLX families.  Only the rows whose invocation reads
an array tell you anything about FIOMDPS2.

WHY.  I went on testing combinations of the two vehicle-unique files instead of
reading the OPS-S2 path, which is exactly what the entry above says not to do.
The map below is the part that was worth having; the four measurements are
recorded so nobody repeats them.

PINNED, by resolving each dump row's FIOBY pointer to its element code, which
names the invocation and therefore the slot:

    LPF1ELM(2) = 105    code LAC     LPF2ELM(2) = 107    code LOC
    LPF1ELM(3) = 106    code LBC     LPF2ELM(3) = 108    code LPC
                                     LPF2ELM(4) = 109    code LQC

Everything else in FIOMDPS2 -- every FLX slot, every DUL slot, LPF2ELM(5) --
is 0.  That is the same arrangement the recovered FIOMDPVU carries, which is
what one would expect of two vehicle-unique files describing the same flight.

ONLY THE DUMP'S ROWS CAN BE RESOLVED THIS WAY.  In a forced single-object link
our own FIOBY pointers are unresolved externals reading 0000, so they all
resolve to FCMPSA+0 and tell you nothing.  Resolve the DUMP and match by
invocation; do not try to resolve our side.

RESULT: with those five values the payload rows reproduce the dump exactly and
in order -- annunciator 5E gives 105 106 85 86 87 and 5F gives 94 107 108 109
88 89 90, both identical to the dump -- against 516 halfwords and rows spread
over 5B, 5C, 5D, 5E and 5F before.

WHAT IS LEFT: 382 halfwords against 368, THREE extra rows, appended after the
correct ones -- element 108 under annunciator 5E, 107 under 5F, and 109 under
5C.  They cannot come from the slots above: LPF1ELM(4) and LPF2ELM(5) are 0, so
both chains terminate, and every FLX and DUL slot is 0.  The 5E and 5F families
have 13 invocations each while LPF1ELM(2..9) and LPF2ELM(2..9) account for only
eight, SO OTHER INVOCATIONS SHARE THOSE ANNUNCIATORS and read some other array.
Find those five invocations per family and see which array each reads; that is
a question about FCMBMTMC, not about FIOMDPS2, and nothing further should be
changed in FIOMDPS2 until it is answered.

NOTHING ABOUT S2 IS COMMITTED; the working copy is verified back to
contributed source.

WHY.  The slots are read from element codes, the same evidence that settled G9, and
the payload rows now reproduce the dump's exactly.  The three rows left over
are a different question and should not be confused with the slots.

FCMBMTS2 LINKS TO 368 HALFWORDS, exactly the length the CSECT table gives,
against 516 before.  Seven halfwords differ, five of them our 0000 against a
pointer a single-object link cannot resolve.  All eleven listener rows match
the dump exactly, counts included.  Recovered file:
~/workspace/PFS/OI340700/MLIB80/FIOMDPS2.asm (PFS 730afbf2).

THE CONTRIBUTED SOURCE SPREADS THIS FLIGHT'S PAYLOAD ELEMENTS OVER FOUR ARRAY
FAMILIES -- LPF 110-115, FLX 116-135, DUL1ELM(1)=105, and HPL 107/108/109.  The
dump holds ONE: 105 106 under annunciator 5E and 107 108 109 under 5F, which is
the LPF block and nothing else.  Recovered values:

    LPF1ELM(2) = 105  code LAC      LPF2ELM(2) = 107  code LOC
    LPF1ELM(3) = 106  code LBC      LPF2ELM(3) = 108  code LPC
                                    LPF2ELM(4) = 109  code LQC

every FLX, DUL and HPL element slot 0.  Identical in shape to the recovered
FIOMDPVU, as two vehicle-unique files describing one flight should be.  The
LPFnCNT values are already right: no listener count disagrees.

THE HPL FAMILY IS THE TRAP.  HPL1ELM(1)=108, HPL1ELM(15)=109 and HPL2ELM(1)=107
emit three further rows carrying THE SAME ELEMENT NUMBERS as the LPF ones, and
their annunciator is a VARIABLE, HPL1ANN(k), so they appeared under 5E, 5C and
5F and did not look like one family at all.  Two earlier passes stalled at
'three rows unaccounted' because of this.  GROUPING BY ANNUNCIATOR IS ONLY
SAFE WHERE THE ANNUNCIATOR IS A LITERAL.  Where it is a variable, only the
element code -- FIOBYxxC, resolved from the dump -- identifies the invocation.
That is the general rule for this table and it is what finally worked.

STILL OPEN, and small: two halfwords just before FCMRESTR, 74 and 72 in the
dump against 72 and 54 here.  They are accumulated word counts, not element
data, and nothing in the listener rows disagrees, so whatever feeds them is not
among the slots above.

WHY.  The HPL family is the trap here and it will recur: rows whose annunciator is a
VARIABLE cannot be grouped by annunciator at all, which is what defeated two
earlier attempts on this module.

SWEEP of all 225 OI340600 modules against pristine PFS source, 2026-08-13,
about 22 minutes wall clock with one straggler:

    OK          176
    OK-EARLY     47
    HANG          1   BILDNEW5, exceeded 1800s -- known, out of scope
    ERRORS        1   MENU12, 61 intolerable lines

223 OF 225 ASSEMBLE.  MENU12's commonest diagnostic is 48 of '(Pass -1,
Severity 255) Unable to evaluate data expression L''&#-1025' -- a LENGTH
ATTRIBUTE of a symbolic variable, which is a DIFFERENT defect from the one
fixed today and is the next assembler question worth taking up.

WHAT THE FIX REACHED, bounded statically because no pre-fix sweep was kept and
re-running one costs another 22 minutes.  Scanning every MLIB80 member for a
SUBSCRIPTED SETx whose target is declared by no GBLA/GBLB/GBLC/LCLA/LCLB/LCLC
anywhere in the library gives FOUR members:

    CHAR.asm      CCODE6, CMTX6
    CHAR0.asm     CCODE6, CMTX6
    EVNTEXP.asm   VALUE
    FCMBMTMC.asm  APLHRM, APLHRNM, BPLHRM, BPLHRNM

so the fix can only ever have affected modules invoking those four macros.  The
one measured case is FCMBMTS2, which went from 81 intolerable errors to zero.
CAVEAT ON THE BOUND: it counts a symbol as declared if ANY member declares it,
even one never COPYed into the module in question, so it is an upper bound on
safety and could understate the reach.  It is a bound, not a measurement.

IF AN EXACT FIGURE IS EVER WANTED, keep a pre-change sweep before touching the
assembler again.  That is the cheap habit this run lacked.

WHY.  The sweep answers 'where does the corpus stand' but NOT 'what did the fix
clear', because no pre-fix sweep was kept.  The static bound below answers the
second question without a second 22-minute run, and its limits are stated.

TWO ASM101S DEFECTS FIXED, AND MENU12 STILL FAILS FOR A THIRD REASON.

L' OF A SYMBOLIC VARIABLE (virtualagc 6f659ccf8, corrected by a2207684d).
evalArithmeticExpression handled N' and K' and fell through to 'Not yet
implemented' for L'.  POS and VECTOR build a symbol name into a SETC and then
take its length attribute:

    &#       SETC  '&P#.X'
    &L       SETA  L'&#-1025

so the operand is the symbol &# names, not &# itself.  &# is a real variable:
POS declares LCLC &P#,&#,&N#.  An undefined symbol is DIAGNOSED, not defaulted
to 1 -- defaulting was tried and withdrawn; see the entry below for why it is
actively wrong here.

A UNARY SIGN IN FRONT OF A VARIABLE (virtualagc 626198a1a).  The grammar was

    arithmeticExpression = term { ( '+' | '-' ) term } ;
    factor = /[NKLSI]'/ variable | constant | identifier | variable | ... ;

with no leading unary sign anywhere, and 'constant' supplying one only for a
numeric literal, its regex being /[-+]?[0-9]+/ with the sign folded into the
token.  RSB: that shape came from HAL/S, where integer literals are never
negative, there being no AP-101S grammar to model.  So a sign before a VARIABLE
had no production.  NINE MLIB80 MEMBERS NEED IT -- DCHAR, POS, MAJOR, MINOR,
RETURN1, SCHAR, VECTOR, XPOS, YPOS -- in 15 places written -&P#, -&#MAJ, -&T#.

    factor gains  ( '+' | '-' ) factor  AFTER 'constant', so numeric literals
    keep their parse; evalArithmeticExpression gains a matching branch BEFORE
    the binary-chain branch, which would otherwise read the sign as a left
    operand and the operand as a list of (operator, operand) pairs.

VERIFIED AGAINST A KEPT BASELINE, which the earlier fix lacked: a full
224-module sweep classifies every module exactly as before -- 176 OK, 47
OK-EARLY, 1 ERRORS -- nothing changing in either direction.  For a change to
'factor', through which every arithmetic expression passes, that is the
measurement that matters, and keeping the pre-change sweep is the habit to
repeat.

MENU12 IS STILL THE ONE ERRORS ROW, and correctly so: its position symbols are
generated by PDEF invocations in MACSMITH, which nothing expands.  See the next
entry.

WHY.  The grammar's shape here was inherited from HAL/S rather than from any AP-101S
document, which is the fact that makes the next change safe to reason about.
RSB supplied it and it belongs beside the defect.

CORRECTION.  P2X, P25Y, P37X and the rest are NOT missing from OI340600.
MLIB80/MACSMITH.asm holds one hundred invocations of the form

    P1       PDEF    -475,337              C1,L1
    P2       PDEF    -456,310              C2,L2

and PDEF generates the symbols from them.  OI301700's copy shows the RESULT
because that release was pulled from assembly listings in which all macros were
already expanded (RSB):

    P1X      EQU   -475,-475+1025,C'@'      01-PDEF
    P1Y      EQU   337,337+1025,C'@'        01-PDEF

A THREE-OPERAND EQU whose SECOND operand is the length attribute.  So
L'P1X = -475+1025 = 550, and POS's L'&#-1025 recovers -475 exactly.  THE 1025
BIAS EXISTS BECAUSE A LENGTH ATTRIBUTE CANNOT BE NEGATIVE.  That also settles
why defaulting an undefined symbol to 1 was wrong: it gives 1-1025 = -1024 for
every coordinate on the display.

WHY MENU12 NEVER SEES THEM: MACROFILES.txt has MACSMITH COMMENTED OUT --
'; MACSMITH.asm' at line 155 -- so it is not read as open code, while PDEF.asm
at line 168 IS, leaving the macro available and never invoked.  Only
SSSRC/BILDNEW5.asm copies MACSMITH, and MENU12 copies MACROS, which does not.

SO THE QUESTION IS WHETHER MACSMITH SHOULD BE OPEN CODE.  It is not a macro
definition; it is a deck of invocations and EQUs.  makeMACROFILES.py excluded
it, and that is the same class of decision that made FPMSWTCC unreachable and
cost five modules until it was found.  READ makeMACROFILES.py'S CRITERIA before
changing anything -- do not just uncomment the line -- and note that making it
open code defines these symbols for EVERY module, so it needs a full sweep
either way.

WHY.  The entry above called this a source gap.  It is not.  The definitions are in
OI340600, generated by a macro from a member nothing expands, which is a
tool-side problem of exactly the kind FPMSWTCC turned out to be.

WHAT IS OPEN.  Measured on 2026-08-12 with all six fixes above in the tree.

    NO ASSEMBLY FAILURES REMAIN IN SSW.  All 176 in-scope modules assemble --
    149 from SSSRC and 27 from RUNASM -- where 47 of them did not at the start
    of the day.  Six defects account for the difference and every one is
    described above.  THAT IS NOT THE SAME AS BEING RIGHT: assembling only
    means ASM101S had nothing to say, and the bytes are settled by the link and
    the comparison, which is where the open work now is.

    WHERE THE COMPARISON STANDS, SSW, all 176 modules, with the exceptions file
    and the literal-recovered image in use:

        PASS                                        62
        PASS via a forced link                       1
        FAIL, links cleanly but halfwords differ     0
        FAIL via a forced link                     113

    113 of 245 sections differ, 5359 halfwords in all.  NOTHING DIFFERS
    SILENTLY ANY MORE: every remaining discrepancy is a link that FAILED,
    naming the symbol it could not resolve.  That is the whole of the change
    on 2026-08-13 and it is worth more than the count of passes, because a
    forced link says what is wrong and a clean link that differs does not.  Those totals are NOT
    comparable with an earlier run's: fixing an assembly failure RAISES them,
    because the module joins the comparison and brings its differences with it.
    Only per-module deltas mean anything, which is why clc-sweep.py keeps every
    report and can reclassify them with --from-reports instead of re-measuring.

    ALL 27 RUNASM MODULES PASS, and every failure is in SSSRC.  That is worth
    keeping in view: the runtime library was finished in the previous phase and
    it still is, so a change that breaks one of those 27 is wrong.

    THE 30 THAT LINKED CLEANLY AND DIFFERED ARE DONE.  Four causes, all of them
    relocation or CSECT-index defects and none findable from a listing; see the
    entry above.  11 of the 30 now PASS and the other 19 became forced links,
    which is not a regression but the point: a missing relocation let a link
    SUCCEED with the halfword left as assembled, and emitting the relocation
    turns that silence into lnk101 naming the symbol it cannot resolve.

    SO THE WORK IS NOW ONE PROBLEM AND NOT MANY.  113 forced links, and what
    they are short of is addresses for symbols the CSECT index does not record
    at FIELD granularity -- TFCMLI11, FIOSICCM and their kind, labels inside
    COMPOOLs and inside assembly CSECTs whose containing CSECT the index knows
    and whose own offset it does not.  dass-syms.py recovers COMPOOL CSECTs
    from HALSTAT; this is one level finer.  The evidence for a recovery pass is
    the dump's own value at each reference site -- FIOLDBPG's `#LBR TFCMLI11`
    reads 30CE there, which is #PCDVS9C+0xE -- and every such site now carries
    a relocation pointing at it, which is what makes the recovery mechanical
    rather than a search.

    THE 95 FORCED LINKS ARE A DIFFERENT PROBLEM and mostly not an assembler
    one.  A forced link means lnk101 could not resolve a symbol, and the
    evidence so far says those divide three ways.  Of FCMBMTPG's 119 unresolved
    relocations at G16: 46 sit at addresses where the dump holds C6C6 or C9FB,
    so the dump never stated a value and there is nothing to compare; 43 point
    at C9FB or 0000 fill, consistent with the user's account of pointers off
    into nowhere that are probably hooks for patches applied after load; and 30
    land INSIDE a CSECT the table already knows -- `TFIVMI71` at 0xDD43 inside
    #PCGGD01, and so on -- which are ordinary references to fields inside HAL/S
    COMPOOLs that augmented-CONFIG.json indexes only at CSECT granularity.
    Those 30 are recoverable as CSECT start plus field offset and are the
    tractable part; dass-syms.py is the existing tool for that recovery.

    A SYMBOL ABSENT FROM THE CSECT TABLE IS THEREFORE NOT AUTOMATICALLY A
    DEFECT.  Establish which of the three kinds it is before chasing it.

    ONLY SSW HAS BEEN SWEPT.  The other seven configurations are untouched,
    though their exceptions files and literal-recovered images are built and
    self-check clean: G16 7955 patched locations, G3 7757, G2 3093, G8 2827,
    G9 2568, S2 1262, SSW 1199, P9 1128.  G16 is both the largest configuration
    and much the most patched, so SSW remaining the development target is
    still the right order.

    THE VERSION QUESTION IS SETTLED AND NEEDS NO MECHANISM.  All eight dumps
    say `AT RELEASE 034    VERSION 070` and the source is OI-34.06, but the
    HAL/S half of OI340600 already matches these dumps, and all 27 in-scope
    RUNASM modules match SSW exactly.  A per-module drift analysis of the kind
    dass-versions.py does for HAL/S is IMPOSSIBLE for assembly anyway --
    HALSTAT records a revision level for 1209 HAL/S units and not one assembly
    module, the DASS listing gives a NONHAL CSECT only its address, name and
    size, and there is no OI340700 source to diff against.  Treat an assembly
    difference as ours until shown otherwise; inventing version exceptions for
    assembly would be the silencing mechanism dass-versions.py is careful to
    avoid.  (Do not repeat this inference: HALSTAT's source-library column
    contains no OI340700 entry, which looks like evidence that nothing changed
    at 34.07 and is not -- HALSTAT is a different, earlier build, R1 of
    16 DEC 09, against the dumps' C2 of 13 DEC 10.)

ALSO STILL OPEN, and unchanged: the 88 uncovered bytes in BILDNEW5, which is
out of scope for this phase anyway, and the duplicated PRINT NOGEN/PRINT GEN
trio in the restored sources.

[why] The DO WHILE defect is the only remaining assembly failure and it cost hours to localise; the trace and the authoritative reference expansion are recorded so the next session resumes at the point reached rather than repeating the search.

[why] The DO WHILE defect is the only remaining assembly failure and it cost hours to localise; the trace and the authoritative reference expansion are recorded so the next session resumes at the point reached rather than repeating the search.

WHY.  The DO WHILE defect is the only remaining assembly failure and it cost hours to localise; the trace and the authoritative reference expansion are recorded so the next session resumes at the point reached rather than repeating the search.

WHAT IS DELIBERATELY NOT IN THIS FILE, and where it is instead.  This handoff
was cut down on purpose; the material below is still true and still wanted,
but reading it costs more than it is worth until it is needed.

    THE DASS COMPARISON, mafgen, and the linked memory maps are in
    HANDOFF.md, whose preamble routes by phase.  THAT FILE IS THE ONE TO READ
    NEXT, because the second half of this phase is its subject.  Two things
    from it are worth knowing before starting, since they bear on the first
    measurement taken:

        DASS-*.fcm COMPARISONS NEED `--no-rtl-fixes`.  The dumps are
        original-build artifacts, bugs included, and a default build differs
        by design.
        DASS_G16.ASC AND ITS SIBLINGS ARE THE DASS BUILD'S MAPS.  They do not
        contain every module -- GPCIPL, LINES, ERRMSGS, SSLCKSUM and BILDNEW5
        appear ZERO times in G16 -- so absence from a map is not evidence
        about a module.

    THE OI301700 INVESTIGATION ITSELF is HANDOFF-ASM101S.md, entries 106
    onward, ending at 212 where the corpus reached 272 of 272.  Consult it for
    WHY a particular piece of the assembler is the way it is -- every fix
    carries the evidence that produced it -- but do not read it through.

    THE RELEASES REALLY DO DIFFER, which is the one OI340600 fact worth
    carrying forward from 184: 35 of the 276 shared MLIB80 members differ in
    their SRN-bearing cards, 3970 card lines in all.  A card lifted from one
    release into the other silently imports another release's code.  OI340600
    also has NO conditional-assembly (column 1) information that OI301700
    lacks: across 12864 SRNs present uniquely in both, there are ZERO cards
    where OI301700's column 1 is blank and OI340600's is not.

    THE HANDOFFS ARE GENERATED.  The source is
    modules/sdfpkg/dass-handoff.db and `dass-handoff.py` is how they change --
    `list`, `show ID`, `search TEXT`, `set ID`, `add --after=ID`, `docs`,
    `check`.  A hand edit to any of the .md files is invisible to the
    database and the next command silently overwrites it.  `check` proves
    they match and exits 1 if they have drifted.  Notes staged for OTHER
    documents go in dass-notes.db via `dass-notes.py`.

    STILL OPEN IN THE OI301700 PHASE, and neither is a byte:  the 88
    uncovered bytes described above, and a duplicated `PRINT NOGEN/PRINT GEN`
    trio in the restored sources -- a restored `$POF` expands afresh beside
    the vestigial pair the extraction kept.  It emits nothing and costs no
    space.

