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
gives, against 1384 before.  The halfwords that still differ are our 0000
against a pointer a single-object forced link cannot resolve.

    CORRECTED BY 245.  This paragraph used to say 12 halfwords differ, one of
    them TFIVMCI1 in reverse -- the dump holding 0000 where we held a pointer.
    NEITHER SURVIVES RE-MEASUREMENT: the figure is 116 for a single-object
    link, the two are not comparable across the relocation work of 2026-08-13,
    and the TFIVMCI1 site AGREES.  The rest of this entry stands; see 245
    before spending any time on TFIVMCI1.

Recovered file: ~/workspace/PFS/OI340700/MLIB80/FIOMDPVU.asm (PFS c1e5932d),
together with the recovered FCMBMTMC.  Both are needed; neither alone gives
1334.

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

MENU12 IS A PASS-ORDERING PROBLEM.  PROVED, not inferred.

THE DECISIVE TEST is three lines -- COPY MACROS, POS (P2,P25), END -- assembled
with --tolerable=255 so the Severity 255 does not abort the run and the symbol
table is actually printed:

    102 P-symbols defined, P2X = FFFFFE38 = -456, P25Y = FFFFFEC9
    and BOTH L' diagnostics still raised, at Pass -1

-456 is exactly what OI301700's expanded listing carries, 'P2X EQU -456,310'.
So the symbols ARE defined, with correct values, and POS still cannot see them.
L' is evaluated during macro expansion, at Pass -1; the EQUs that define these
symbols are processed by the assembly proper, later.  THE FIX IS ABOUT WHEN L'
IS EVALUATED -- deferring it to a pass that has a symbol table -- NOT about L',
which is implemented correctly, nor about POS, MACROS, PDEF or the source.

FOUR WRONG DIAGNOSES PRECEDED THIS, all stated too confidently, all killed by
measurement:
  - 'the position symbols are missing from OI340600'.  MACROS.asm defines
    1-50 and 52; MENU12 needs a subset, all present.  MACSMITH is a red
    herring and nothing need copy it.
  - 'PDEF expands unsubstituted'.  Those listing lines are the macro
    DEFINITION.  'P1 PDEF -475,337' alone defines P1X = -475.
  - 'it is the C'' or the COPY'.  A file containing only COPY MACROS defines
    102 P-symbols correctly; the three-operand EQU with C'@' is fine.
  - 'MENU12 defines zero P-symbols'.  An ARTEFACT: the assembly aborts, so no
    symbol table is printed.

THE TRAP THAT PRODUCED TWO OF THOSE: COUNTING SYMBOLS IN A FAILED LISTING
MEASURES NOTHING.  An abort suppresses the symbol table and the generated-code
listing both.  Raise --tolerable until the assembly completes, THEN look.

WHY.  The entry above called this a source gap.  It is not.  The definitions are in
OI340600, generated by a macro from a member nothing expands, which is a
tool-side problem of exactly the kind FPMSWTCC turned out to be.

THE PASS MODEL.  svGlobals['_passCount'] starts at -1 while the source is READ,
and ALL MACRO EXPANSION HAPPENS DURING THAT READ.  Pass 0 begins afterwards in
model101.py (around line 1509), followed by 'while passCount < 3 or (repeatPass
and passCount < 20)'.  So at expansion time no pass has run and there is no
symbol table at all.  That is why POS cannot see P2X: not a bug in L', in POS,
in PDEF, in MACROS or in the source, all four of which were checked and are
fine.

DEFERRING L' ALONE DOES NOT WORK.  L'&#-1025 is the operand of a SETA.  Its
value feeds &L, which drives conditional assembly and the operands POS
generates.  Deferring the value means deferring everything downstream of it,
through the whole expansion.  It is not a local change.

A PRE-SCAN DOES NOT WORK EITHER, AND FAILS CIRCULARLY.  The natural alternative
-- sweep the source for EQUs and record their length attributes before
expanding -- cannot find P1X, BECAUSE P1X IS ITSELF MACRO-GENERATED.  PDEF
produces it.  To know P1X exists you must already have expanded PDEF, which is
the thing you are trying to run first.

WHAT WOULD FIX IT is interleaving expansion with symbol definition, so
statements are processed in order and PDEF's generated EQUs enter the symbol
table before POS is expanded later in the same file.  That is how a real
assembler behaves.  It means macro expansion stops being a wholesale phase
during the read and becomes part of ordered statement processing -- a
restructure of readSourceFile and its relationship to model101.py's pass loop.

SCOPE IT BEFORE STARTING.  It is the largest change contemplated in this phase,
it touches every module rather than one, and the corpus currently assembles 223
of 224.  A kept-baseline sweep is mandatory, and the bar is that all 223 keep
their classification, not merely that MENU12 improves.

WHY.  The obvious two fixes both fail for reasons that are not obvious, and the second
fails circularly.  Anyone picking this up will try them in this order; the
reasons are recorded so they are tried on paper instead of in code.

MENU12 ASSEMBLES.  The OI340600 corpus is 177 OK and 47 OK-EARLY, with no
failures of any class, and the ONLY classification change across 224 modules
is MENU12 ERRORS -> OK.  OI301700 is unmoved at 267 MATCH, 5 MATCH?, 0
DIFFERS -- 0 bytes mismatched and 0 missing in all 272 -- which matters
because three of the four fixes affect every module, not just this one.
Commits 40d2414a3 and 17d569396.

NO RESTRUCTURE WAS NEEDED.  242 proposed interleaving macro expansion with
symbol definition, a rebuild of `readSourceFile` against model101.py's pass
loop.  What actually works is far smaller: `readSourceFile` RECORDS an EQU's
length and type attributes as it generates them, into a table that L' and T'
consult only as a FALLBACK.  A definition is visible to whatever expands
after it and to nothing before it -- the ordering a real assembler gives
them -- and once `symtab` exists the real entry always wins.  Most EQUs still
cannot be evaluated during the read (`FOO EQU BAR+4` names a symbol no pass
has defined) and that is normal; the evaluation is done quietly, saving and
restoring `errorCount` and `maxSeverity`, because `maxSeverity` decides the
exit status and a speculative failure would otherwise fail the assembly.

FOUR DEFECTS, EACH HIDDEN BEHIND THE ONE AHEAD OF IT.

  1. THE COMPILED PARSER WAS STALE.  The grammar lives as text in
     fieldParser.py but the parser is IMPORTED from parser_asm.py, which
     `fieldParser.py --generate-only` writes.  626198a1a edited the grammar
     and did not regenerate it, so the unary-sign fix was INERT -- and the
     sweep that followed was clean because the change did nothing.  A grammar
     edit is not in effect until parser_asm.py is regenerated and committed
     with it, and NOTHING CHECKS THIS.

  2. SUBSTITUTING AN ARITHMETIC VALUE IS UNSIGNED.  A negative SETA value
     substituted as -456, so POS's `XPOS -&L` produced `--456`, which no DC
     can parse.  The value converts to an UNSIGNED decimal and the macro
     supplies its own sign, which is precisely why POS tests the sign:

                  AIF   (&L GE 0).GENPOSX
         &N       XPOS  -&L

     OI301700 settles it -- that source came from listings with the macros
     already expanded, and it holds `FL.11'-456'`, ONE minus, generated from
     this same line.

  3. THE TYPE OF A THREE-OPERAND EQU WAS ALWAYS 'C'.  `joinTokens` rebuilds
     the whole term, `C'#'`, so `tc[:1]` answered 'C'.  In model101.py the
     self-defining test was applied to `C'C'#''`, which fails, so the
     attribute was never recorded AT ALL -- a defect sitting in the pass
     code, not only in the read.  `characterTermValue` takes the character
     from inside the quotes, and both places now use it.

  4. T' OF A SET SYMBOL FOLLOWS ITS VALUE.  A SETC holding a self-defining
     term is 'N', not 'C'.  The library asks this fifteen times; answering
     'C' sent `VR 285,-27` into #SPLIT's INVALID FORMAT IN EXPRESSION arm.
     The test sits below the symbol lookup and above the 'C' fallback, so
     the only two 'C' comparisons in the library -- both asked of a symbol
     NAME, never of a literal -- do not move.

THE PROOF IS NOT THAT IT WENT QUIET.  MENU12's 48 generated position
constants are the SAME 28 DISTINCT VALUES the original assembler emitted in
OI301700's expanded MENU12; compared as sets they are identical.  A module
that had merely stopped complaining would not do that.

AN ABORTED ASSEMBLY PRINTS NO LISTING, so a run that crashed showed ZERO
diagnostics and looked like success.  That is the trap recorded in 240, met
again from the other direction: check the exit status and grep for Traceback
before believing a clean listing.

WHY.  242 said the restructure was the largest change contemplated in this phase.  It turned out not to need a restructure at all -- recording attributes as the read generates them is a fallback, not a reordering -- and the reason the phase looked blocked was that three FURTHER defects sat behind the first one, each only reachable once the one ahead of it was fixed.  Anyone who reads 242 alone will start the wrong job.

S2 IS FULLY ACCOUNTED FOR.  FCMBMTS2 links to 368 halfwords, the length the
CSECT table gives, and the two RTWDTAB delay counts before FCMRESTR now match
the dump.  32 halfwords still differ and EVERY ONE is our 0000 against a
pointer a single-object link cannot resolve -- lnk101 names them, TFIVPF24,
TFIVPS12 and TFIVPS22.  Nothing else in the section disagrees.  Recovered
file: ~/workspace/PFS/OI340700/MLIB80/FIOMDPS2.asm (PFS 15205c37).

    &LPF1CNT(2)  6 -> 7      &LPF2CNT(2)  0 -> 7
                             &LPF2CNT(4)  0 -> 2

236 ARGUED FROM THE LISTENER TABLE AND THE ARGUMENT IS EMPTY FOR S2.  It said
the LPFnCNT values had to be right because no listener count disagreed with
the dump.  BMTENT reads

        AIF   ('&PASSOPS' EQ 'S2').CFDISP        COMMANDER ONLY
        AIF   ('&PASSOPS' EQ 'S4').CFDISP        COMMANDER ONLY
        AGO   .LSTNR                             COMMANDER/LISTENER

for a PLCMDLST entry, so under S2 NO PAYLOAD ELEMENT REGISTERS A LISTENER AT
ALL, and the row itself is written `DC Y(&NUM)` with the count dropped.  An
LPFnCNT therefore appears NOWHERE in the module except the two delay counts.
There was never a listener count that could have disagreed, and S2's eleven
listener rows all come from CMDRLST entries, which is why they matched
throughout.

    THE GENERAL FORM: "X agrees, therefore Y is right" is only worth
    anything once you have checked that Y REACHES X.  Here it did not, for a
    reason visible in four lines of the macro.

THE TWO HALFWORDS ARE THE WHOLE OF THE EVIDENCE AND THEY ARE ENOUGH.
FCMBMTMC builds each as

    &RWDLYCT SETA &OVHD*(REL)+2*(RWD+REL+1)+&ODEL

and S2 takes the .SMOH arm, &OVHD 10 and &ODEL 4, so the halfword is
12*REL+2*RWD+6.  The element counts REL were already right, so each halfword
pins RWD outright:

    BCE 10 (LPF1, FIOBYRAC)   dump 74, was 72   REL 3   RWD 16, was 15
    BCE 11 (LPF2, FIOBYRBC)   dump 72, was 54   REL 4   RWD  9, was  0

RWD accumulates 9 for the KU-band radar plus LPF1CNT(2)+(3) on BCE 10, and
LPF2CNT(2)+(3)+(4) on BCE 11, so the required sums are 7 and 9.

THE SPLIT IS NOT FREE, AND THE CORROBORATION IS INDEPENDENT.  Two halfwords
pin two sums, not five values.  FIOMDPVU was recovered from G9 -- which is
neither S2 nor S4 and therefore DOES register payload listeners, so its
counts are pinned by G9's listener rows -- and it holds 7 and 0 for LPF1 and
7, 0 and 2 for LPF2.  Those sum to exactly the 7 and 9 required here.
Neither measurement was derived from the other, and two vehicle-unique files
describing one flight agreeing on the payload's return words is what makes
the split more than a guess.

HOW TO REPRODUCE, because the counts in 236 were measured a different way and
do not match this run.  A scratch library of SYMLINKS to OI340600/MLIB80 with
a REAL copy of the recovered FIOMDPS2 and a REAL MACROFILES.txt (never
symlink that one -- it has been truncated through a symlink twice), then

    dass-literals.py --config=S2 --out=S2-lit.fcm --exceptions=exceptions-S2.txt
    cd ~/workspace/PFS/OI340600
    compileLinkCompare --config=S2 --library=SCRATCHLIB \
        --filename=SSSRC/FCMBMTS2.asm --out-dir=OUT \
        --memory=S2-lit.fcm --exceptions=exceptions-S2.txt

compileLinkCompare passes `--max-hw-diffs 10` to fcmcmp, so the report TRUNCATES
at ten differences and the two that matter are the LAST two.  Re-run fcmcmp by
hand with `--max-hw-diffs 100` to see them at all.

THE LISTING'S ADDRESS COLUMN IS IN HALFWORDS, not bytes.  Reading it as bytes
puts you 175 halfwords into the wrong part of the section and lands on
plausible-looking comfault masks, which is a wrong answer that looks right.
0D9CD - 0D91E = 0xAF is the listing's own 000AF, directly.

WHY.  236 left these two halfwords open and gave a reason for skipping them that was wrong -- that the listener table vouched for the counts.  Anyone resuming would have believed it and looked somewhere else.  The reason it is wrong is four lines of BMTENT, and the same shape of mistake is easy to repeat: check that the thing you are arguing from actually reaches the thing you are arguing about.

G9'S TFIVMCI1 IS NOT A DEFECT AND NOT A SEPARATE PROBLEM.  Measured
2026-08-13 with both recovered files in a scratch library, the literal-
recovered image, the exceptions file and a disambiguated CSECT index:
FCMBMTG9 links to 1334 halfwords, the length the CSECT table gives, and the
TFIVMCI1 site AGREES WITH THE DUMP.  Its whole BMT row agrees, read straight
out of both images:

    0FAB6  Y(TFIVMCI1)          0000  0000   the site 229 called a mismatch
    0FAB7  Y(CMDRLST+DISP64)    10BD  10BD
    0FAB8  Y(FIOBYMCR)          E608  E608
    0FAB9  Y(91*256+MCIU)       5B52  5B52
    0FABA  annunciator/error    5420  5420

229 RECORDED THE REVERSE -- the dump holding 0000 where we held a pointer --
and that does not reproduce.  We hold 0000 there now.

BUT THE AGREEMENT IS NOT EVIDENCE THAT WE WOULD GET IT RIGHT, and this is the
part worth keeping.  Our 0000 is produced by the same mechanism that produces
116 WRONG zeros in the same section: a single-object forced link leaves an
unresolvable external unpatched.  All 116 differing halfwords are `DC
Y(symbol)` sites and every one is an external the CSECT index does not carry:

    TFIVMI 20   TFIVH 15   FIOBY 15   TFOVH 8   TFIVAN 7   TFIVPF 6
    TFIVNC 4    TFCMMTU 3  TFIVIM 3   TFIVIU 3  TFIVGPS 3  TFIVSRL 2  ...

TFIVMCI1 is one of those sites.  It agrees only because the ORIGINAL build
also left it 0000, so our systematic failure coincides with the dump in this
one place.  TFIVPS12, the very next halfword at 0FABB, is the same kind of
symbol and the dump holds A838 there -- the original resolved that one and we
cannot.

    SO TFIVMCI1 BECOMES A REAL TEST ONLY LATER.  Once the index carries these
    COMPOOL field addresses and we start patching them, if we then write a
    pointer where the dump has 0000, THAT is a discrepancy worth the name.
    Chasing it before then is chasing a property of the link setup.

NEITHER OF 229'S COUNTS REPRODUCES, and 221 already says why: these totals are
not comparable across the relocation work of 2026-08-13 (4ee9d409d, 22e061b67,
13ee3616f among them), which turned links that had silently succeeded with the
halfword left as assembled into links that name what they cannot resolve.  229
said 12 halfwords differ; the honest figure for a single-object link now is
116.  Do not treat 229's 12, or 236's 7 for S2, as baselines.

WHAT IS ACTUALLY LEFT FOR G9 is therefore not a module question at all.  It is
221's known gap -- addresses for symbols the CSECT index does not record at
FIELD granularity, COMPOOL members among them -- and fixing that fixes all 116
at once, here and in every other forced link.  dass-syms.py recovers COMPOOL
CSECTs from HALSTAT; this is one level finer than that.

    MAFGEN CANNOT ARBITRATE IT BY NAME.  TFIVMCI1, TFIVPS12 and TFIVMI01 each
    occur ZERO times in DASS_G9.ASC -- the disassembly does not carry these
    field names at all, only the CSECT-level ones like TFIVR100.  So the dump's
    VALUES are the only evidence about which of them the original resolved, and
    a recovery pass has to work from the values rather than from a symbol list.

WHY.  229 left TFIVMCI1 as the one open item on an otherwise closed module, which makes it look like a small specific defect worth an afternoon.  It is not: it is one site of the general unresolved-COMPOOL-field problem, it currently agrees, and the agreement is luck rather than correctness.  Recording that stops the next session spending the afternoon, and says what would make it evidence again.

THE FIELD-GRANULARITY GAP IS CLOSED, AND HALSTAT CLOSES IT.  221 identified
the remaining problem as addresses for symbols the CSECT index does not record
at FIELD granularity, and named dass-syms.py's recovery as the model.  The tool
is modules/sdfpkg/dass-fields.py (virtualagc 4436cb501).

    dass-fields.py --config=XXX [--base=F.json] --out=F.json
                   [--verify=LINK.json:IMAGE.fcm]

HALSTAT gives every EQUATEd label its CSECT and its offset inside it:

     31879  TFIVMI12          EQUATE  LABEL   C O M P O O L   CGB_IM1_...
                (EQUATED TO: CGBV_MFF_SEG1   UNIT/BLOCK: CGB_IM1_...)
                (CSECT: #PCGBIM1 OFFSET: 00002A) PHASE 2 ADDR: 003C50 ...

An EQUATE LABEL is precisely how a HAL/S COMPOOL field acquires an eight-
character name that an assembly EXTRN can reference, so this is the right
record and not an approximation of one.  The field's address is the CSECT's
start IN THIS CONFIGURATION plus the offset.

NO PHASE LABEL IS CONSULTED.  HALSTAT prints a per-phase ADDR too, and
dass-syms.py's header explains why the phase-to-configuration mapping is only
approximate.  None of it is needed: the CSECT's start in this configuration is
already in the index, so the arithmetic stays inside the configuration being
built.  A CSECT absent from the configuration means the COMPOOL is not in this
build and the field is skipped, which is correct rather than a shortfall.

DO NOT RECOVER THESE FROM THE DUMP, and this is the part to hold on to.  The
obvious alternative is to read the value the original build left at each
reference site and call that the address.  It is mechanical, every site now
carries a relocation pointing at it, and IT IS CIRCULAR -- the site then
matches by construction, and a comparison meant to be evidence has been fitted
to its own answer.  It was tried first here and abandoned for that reason.
HALSTAT is a compiler artifact and owes the dump nothing, which is what makes
the agreement below mean something:

    G9  FCMBMTG9    80 of 80 predict the dump's own value exactly, 0 disagree
    S2  FCMBMTS2    24 of 24 predict the dump's own value exactly, 0 disagree

Two configurations, different CSECT addresses, 104 predictions and not one
wrong.  Re-linking with the augmented index:

    FCMBMTG9   116 differing halfwords -> 36      (index gained 321 fields)
    FCMBMTS2    32 differing halfwords ->  8      (index gained 264 fields)

A NAME EQUATED IN SEVERAL COMPILATIONS IS RESOLVED BY THE CONFIGURATION, not
by the last record read.  TFIVAN11-14 and TFIVPF12 are of that kind; at most
one of the COMPOOLs such a name points at is in a given build, so the build
chooses.  Taking the last would have been right only by luck.  All 15 resolve
and none is left ambiguous.  Where two live candidates give the SAME address --
a COMPOOL indexed under two names -- that is accepted; anything genuinely
ambiguous is skipped and reported, never guessed.

WHAT IS LEFT IS NOT AN INDEX GAP AT ALL.  Every remaining unresolved symbol in
both modules is FIOBY*, and HALSTAT carries no FIOBY symbol anywhere -- rightly,
because they are not COMPOOL fields.  They are ENTRY points that BTBCEGEN
generates inside a SIBLING ASSEMBLY MODULE:

        ENTRY FIOBYRAC
    FIOBYRAC #BU   FIORW1A          BYPASS ENTRY POINT

in FIOHFE02, FIOMFEG9 and their family.  A single-object link cannot see them
and a full-configuration link would not need to.  So they are an artifact of
how the comparison is driven, not something to recover, and chasing them
through HALSTAT will find nothing because nothing is there.

    WHICH GIVES A COMPLETE ACCOUNT OF FCMBMTG9'S 117 UNRESOLVED REFERENCES:
    80 COMPOOL fields, now closed; 36 FIOBY sibling-module entry points; and
    one, TFIVMCI1, whose CSECT is not in this configuration and which the
    ORIGINAL build did not resolve either -- its dump value is 0000.  See 245.

MEASURED ACROSS G9, both arms of a clc-sweep over all 153 in-scope modules,
the only difference between them being which --ext-syms file was used:

                        baseline    with fields
    PASS                      34             52
    PASS-FORCED                2              2
    FAIL                       2              7
    FAIL-FORCED              112             89
    SIZE-FORCED                3              3
    halfwords differing     3487           2631

    18 modules FAIL-FORCED -> PASS, byte-perfect against the dump
     5 modules FAIL-FORCED -> FAIL
     0 regressions: nothing moved to a worse class

FAIL-FORCED -> FAIL IS AN IMPROVEMENT AND NOT A REGRESSION, which is why FAIL
rises from 2 to 7.  A forced link means lnk101 could not resolve something and
the halfword was left as assembled; a plain FAIL means it resolved everything
and the bytes still disagree, which is a real finding that can be worked.
Their differences shrank as they moved -- FCMNINIT 18 halfwords to 1, FCMCBLKS
22 to 6, FIOGPSPG 17 to 8 -- so those five are now small, sharp questions
rather than silence.

FIOLDBPG IS THE ONE TO NOTICE.  221 used it as the worked example of this very
gap: its `#LBR TFCMLI11` reads 30CE in the dump, which is #PCDVS9C+0xE.  It now
PASSES, byte for byte.

The sweep writes its per-module products to WORK/clc-CONFIG, which is inside
PFS; that directory was moved to ~/ForClaude/OI340600-clc-G9 afterwards and PFS
holds none of it.  The reports are elsewhere and take --reports=DIR.

WHY.  221 named this as the one problem the phase had left, and the obvious way to solve it -- read the address the original build wrote at each reference site -- is circular and would have produced a comparison fitted to its own answer.  The independent source exists and agrees 104 times out of 104.  Recording which source was used, and why the other was refused, is the part that stops it being redone the wrong way.

MOST OF WHAT WAS LEFT WAS THE HARNESS, NOT THE CODE.  After the field recovery
G9 still had 92 forced links.  Of the 505 distinct symbols they could not
resolve -- 1230 reference sites -- 384 SYMBOLS AND 1077 SITES, 88 PER CENT,
ARE EXPORTED BY ANOTHER OI340600 MODULE WE ALREADY BUILD.  FC$ASYNC is in
FCMSAVE, the FIOBY family in FIOHFE02 and its siblings, and so on.  Nothing
about them was missing; compileLinkCompare links ONE OBJECT AT A TIME and the
linker was never shown the others.

LINKING THE WHOLE CONFIGURATION AT ONCE IS THE FIX, and it works today:

    cd ~/workspace/PFS/OI340600
    lnk101 -f DIR/*.obj -o g9-all.fcm --json-symbols g9-all.json \
           --external-syms augmented-G9-fields.json
    fcmcmp --exceptions exceptions-G9.txt --no-data C9FB,C6C6 \
           --csect-table augmented-G9-fields.json \
           g9-all.json g9-all.fcm G9-lit.fcm

using the .obj files clc-sweep has already produced.  --external-syms still
pins each CSECT at the address the table gives, so this is not yet a link that
lays out memory by itself.

    ALL THREE ARMS, G9, 153 in-scope modules, same objects, same dump:

                                        matching   halfwords differing
        single-object, baseline           34/153            3487
        single-object, + field recovery   52/153            2631
        FULL MULTI-OBJECT LINK           123/153            1543

123 OF 153 SECTIONS NOW MATCH THE G9 DUMP BYTE FOR BYTE.  The field recovery is
still carried in that link and is still worth what it was; the point is that it
was never going to be the whole of it, because most of the remainder was never
a recovery question at all.

WHAT IS ACTUALLY LEFT IS SMALL AND SHARP.  30 sections differ, the median by
TWO halfwords and 18 of the 30 by four or fewer.  The exceptions are worth
naming: FIOCBLKS 55, FIOPDISP 23, FIOMGDSP 10, FIOMDPPG 12, and FIOMVUPG which
is one of three sections whose SIZE disagrees with the CSECT table (352
halfwords against 276) and accounts for 204 differences on its own.  A section
that is the wrong LENGTH is a different kind of problem from one that is the
right length with wrong halfwords, and the three should be separated before
either is worked.

CAVEATS, because this is a forced link.  127 symbols are still undefined and
`-f` leaves their sites unpatched; 121 of the 505 are exported by nothing we
build, which is the archive gap and not a defect.  So 1543 is an upper bound on
the disagreement and some of it is still the harness rather than the code.

    THE COMPARISON IS ALSO NOT PERFECTLY LIKE FOR LIKE.  The single-object rows
    come from clc-sweep's per-MODULE classification and the full-link row from
    fcmcmp's per-SECTION verdict.  The two agree on what a section is here --
    fcmcmp reports 30/153 differing against clc-sweep's 153 modules -- but the
    numbers are not interchangeable in general and should not be quoted as a
    single series without this note.

WHY.  The phase has been comparing one object at a time and attributing what that could not resolve to recovery gaps.  88 per cent of the remainder was sibling modules the linker was never shown, and a multi-object link -- which needs no new tooling and works today -- more than doubles the sections that match.  Anyone continuing should start here rather than recovering more symbols.

THE THREE SIZE MISMATCHES ARE THREE DIFFERENT THINGS.  G9's full link reported
three sections whose length disagrees with the CSECT table.  Two are now
closed and the third is an ASM101S defect with a four-line reproduction.

    FCMBMTG9   1344 vs 1334 expected   the OI340700 recovery, already known
    FIOMVUPG    352 vs  276 expected   CLOSED -- now matches byte for byte
    FIOLGERR    136 vs  140 expected   ASM101S: content after an LTORG is not
                                       counted in the section length

FCMBMTG9 IS NOT A DEFECT.  clc-sweep assembles against the contributed
OI340600 MLIB80, and 1334 needs the recovered OI340700 FIOMDPVU and FCMBMTMC.
Point --library at a scratch library carrying those two and it is 1334 exactly.
The sweep cannot do that for the whole corpus without a library that mixes
releases, so expect this row to stay until the OI340700 reconstruction is
complete.

FIOMVUPG IS CLOSED, AND IT FOUND A REAL ERROR IN THE FIOMDPVU RECOVERY.  That
file's note said no CMD was supplied for the slots the payload elements moved
into, and that LPF1CMD(2) was left at its contributed value, because "nothing
in the emitted rows reads them".  THAT WAS CHECKED AGAINST FCMBMTG9 ALONE.
FIOMVUPG COPYs the same file and BTBCEGEN emits

        #MINC FIOPF1AD,X'&LPF1CMD(&ELE-1)'

for every element in the chain, so the unsupplied CMDs reached the assembler as
X'' and FIOMVUPG WOULD NOT ASSEMBLE AT ALL -- four intolerable lines, which is
why it never showed up as anything but a size mismatch.

    THE SAME MISTAKE AS 244'S, TWICE IN ONE PHASE: "nothing reads it, so the
    dump cannot show it" is a claim about EVERY reader, and both times it was
    made after looking at one.  Enumerate the readers.

The dump does show them, in FIOMVUPG's section.  #MINC emits the port base
ORed with the command's high byte and then its low halfword -- FIOPF1AD 0050,
FIOPF2AD 0060 -- so each command reads straight out of the image:

    LPF1CMD(2)  024407   the contributed source has 024406, so it was WRONG
    LPF1CMD(3)  025840
    LPF2CMD(2)  024407
    LPF2CMD(3)  025840
    LPF2CMD(4)  026C02

With those, FIOMVUPG links to 276 halfwords -- exactly the table's length,
against 352 -- and MATCHES THE G9 DUMP BYTE FOR BYTE.  FCMBMTG9 is unchanged at
1334 with its same 36 FIOBY differences.  PFS 4065fddf.

FIOLGERR IS AN ASM101S DEFECT, AND 250 FIXES IT.  Anything a section emits
AFTER an LTORG is left out of the section's length.  Four lines reproduce it:

    ZT4      CSECT
             EXTRN FOO
             L     R1,=X'000007FF'
             LTORG
             DC    H'7'
             END

The L occupies bytes 0-3, the pool 4-7 and the DC 8-9, so the section is 10
bytes; the ESD says 8.  After assembly `sects['ZT4']` holds pos1 10 and used 8
-- the location counter advanced over the DC and the high-water mark did not.
A ZCON behaves the same way and is not special: ZT3, identical but with
`DC Z(,FOO,0)`, is 12 bytes and reports 8.

    WHERE IT IS.  model101.py's LTORG arm advances `pos1` past the pool and
    deliberately does NOT touch `used`, with a comment explaining that forcing
    it there makes a TRAILING pool count twice -- CTOE's #LCTOE moved by
    exactly its pool's 40 bytes and eight RUNASM modules broke.  That reasoning
    is sound.  What is wrong is the sentence after it, which says `used` "still
    grows by itself for an INTERIOR pool, because the statements after the
    LTORG advance past it and carry used with them".  IT DOES NOT, and ZT4 is
    four lines of proof.

    DO NOT JUST FORCE `used` IN THE LTORG ARM.  That is the change the comment
    already records as having broken eight RUNASM modules.  The trailing-pool
    accounting -- the between-passes code that adds pool[4] back to `used` to
    get a section's true length -- has to stay consistent with whatever is
    done, so interior and trailing pools must end up counted exactly once
    each.  This wants RUNASM, verify-sweep and the OI340600 sweep before it is
    believed, which is why it was diagnosed and left rather than patched.
    All three were run, in both arms, and 250 has them.  250 also records
    that the WHERE above is wrong:  the fix is in neither the LTORG arm nor
    the trailing-pool accounting, and both are correct as they stand.

WHY.  Each of the three had a different cause and only one was an assembler fault, so treating them as one class would have wasted the other two.  The FIOMVUPG one also caught a real error in a committed recovery, made by exactly the reasoning 244 had already been burned by.  And the LTORG defect has a known wrong fix that broke eight modules last time, which is worth saying before anyone reaches for it.

SAVED, 2026-08-13, in ~/ForClaude/OI340600-artifacts/ -- the inputs every
measurement in 243 to 248 was taken with:

    augmented-G9-fields.json    G9 index + 321 recovered COMPOOL fields
    augmented-G9-disambig.json  the same index BEFORE dass-fields.py, the
                                baseline arm of the G9 sweep
    augmented-S2-fields.json    S2 index + 264 recovered fields
    exceptions-G9.txt           dass-literals.py, 2571 locations
    exceptions-S2.txt           dass-literals.py, 1262 locations
    G9-lit.fcm, S2-lit.fcm      literal-recovered images
    g9-base.tsv, g9-fields.tsv  the two sweep arms, per-module rows
    mlib-g9/, mlib-s2/          ONLY the recovered members, not a library

    ~/ForClaude/OI340600-clc-G9/    the G9 sweep's objects and link JSONs,
                                    from the FIELD arm (the baseline arm's
                                    were overwritten -- outDir is fixed)

A SCRATCH LIBRARY IS NOT SAVED AND MUST BE REBUILT, because it is mostly
symlinks and a stale one is worse than none.  Rebuild it as 244 describes:
symlink every OI340600/MLIB80 member, copy MACROFILES.txt as a REAL file --
never symlink that one, it has been truncated through a symlink twice -- then
copy the recovered members from ~/ForClaude/OI340600-artifacts/mlib-g9 or
mlib-s2 over the top.

REGENERATE RATHER THAN TRUST, for anything after an assembler change.  The
.tsv rows, the objects and the link JSONs are all downstream of ASM101S, so a
change to the assembler invalidates every one of them; the indices and the
exceptions files are not, and are cheap to keep.  dass-fields.py --verify is
the check that says whether an index is still good.

WHY.  Every measurement in 243-248 depends on files that took about forty minutes of sweeps to build and that lived in a session scratch directory.  They are now somewhere durable, and the ones that are NOT are named so nobody assumes a stale file is current.

THE LTORG SECTION-LENGTH DEFECT OF 248 IS FIXED, AND NOT WHERE IT WAS LOOKED
FOR.  248 pointed at the LTORG arm and at the trailing-pool accounting around
it.  Both are correct as they stand and neither was changed.  The bug is the
LAST LINE of `generateObjectCode`, in the loop that appends each literal pool
to its section:

    sects[pool[0]]["used"] = desiredLength      # desiredLength = pool[1]+pool[4]

`used` is a HIGH-WATER MARK, and this threw the mark away and replaced it with
wherever the pool happened to end.  For a pool that IS the last thing in its
section those are the same number and nothing showed.  For an INTERIOR pool
the section was truncated back to the end of the pool -- and `used` is both
what the ESD card reports as the section's length AND what the TXT card is
sliced to, so ZT4's `DC H'7'` was not merely uncounted, it was not in the
object at all.

248'S ONE WRONG SENTENCE WAS RIGHT ALL ALONG.  It said `used` "still grows by
itself for an INTERIOR pool, because the statements after the LTORG advance
past it and carry used with them", and 248 called that false on the evidence
of ZT4.  IT IS TRUE.  The statements do carry `used` past the pool, exactly as
written; three thousand lines later this assignment put it back.  Which is
also why forcing `used` in the LTORG arm fixed nothing and broke eight
modules: the value was already right when it was made, and the arm is not
where it was lost.

    THREE PLACES, ALL THE SAME SHAPE -- a pool EXTENDS its section, it does
    not DEFINE the end of it:

      the assignment above becomes a high-water update, `if desiredLength >
      used`, a no-op for a trailing pool because there the pool's end IS the
      section's end;

      the inter-CSECT `offset` loop takes max(used, pool end) rather than the
      pool's end outright, and no longer stops at a section's FIRST pool --
      DCICYC has two and the interior one comes first;

      `preliminaryOffset` adds pool[4] only for a pool ending PAST the
      high-water mark.  An interior pool is already inside `used`, and adding
      it again is precisely the double-count that moved CTOE's #LCTOE by its
      pool's own 40 bytes.

MEASURED IN BOTH ARMS, EVERY NUMBER RE-RUN AGAINST A PRISTINE COPY OF THE
ASSEMBLER RATHER THAN QUOTED FROM 215:

    RUNASM --no-rtl-fixes    205/205 byte-for-byte           unchanged
    verify-sweep             267 MATCH  5 MATCH?  0 DIFFERS  unchanged, and
                             no module changed class
    oi340600-sweep           177 OK  47 OK-EARLY  0 failures unchanged, and
                             no module changed class

    THE OBJECTS THEMSELVES, all 224 of OI340600 assembled both ways:  223
    BYTE-IDENTICAL, one differing, and the one is FIOLGERR.  That is the
    check worth having -- the sweeps establish that nothing broke, this
    establishes that nothing else so much as moved.

    ZT4 8 -> 10 bytes; ZT3, the ZCON form, 8 -> 12; ZT5, the same module with
    nothing after the LTORG and therefore the control, 8 and 8.

    FIOLGERR 272 -> 280 bytes, which is 136 -> 140 HALFWORDS, and 140 is what
    the CSECT table says.  That closes the third of 248's three size
    mismatches.

ASM101S IS NOT DETERMINISTIC BETWEEN RUNS, which is a separate finding and was
very nearly read here as a regression.  The first before-and-after comparison
of the corpus's objects showed 177 of 224 DIFFERING -- and then two runs of
the PRISTINE assembler on FCMASYNC differed in the same 400 bytes.
`PYTHONHASHSEED=0` makes it repeatable, so it is set iteration order reaching
the ESD or RLD ordering.  The bytes are equivalent rather than wrong, but

    A BEFORE-AND-AFTER COMPARISON OF OBJECT FILES MEANS NOTHING UNLESS
    PYTHONHASHSEED IS PINNED IN BOTH ARMS.

With it pinned the comparison is exact, and it is what settles this change.

THE ARTIFACTS 249 SAVED ARE NOW STALE, as 249 said they would be the moment
the assembler changed: g9-base.tsv, g9-fields.tsv and every object and link
JSON under ~/ForClaude/OI340600-clc-G9 were produced by the old assembler.
The indices and the exceptions files are not downstream of it and are still
good.

WHY.  248 named the LTORG arm and the trailing-pool accounting, and both are sound; the bug was a plain assignment three thousand lines away that undid what they had got right.  Recording where it actually was, and that 248's one sentence flagged as false was true, is what stops the next attempt going back to the arm and breaking the eight modules again.

THE HAL/S OBJECTS ALREADY EXIST, AND 247'S "FULL MULTI-OBJECT LINK" WAS THE
ASSEMBLY THIRD OF THE CONFIGURATION.  247 linked the 153 assembly objects and
called that linking the whole configuration at once.  It is not.  Of the 1318
CSECTs in the G9 index only 130 are NONHAL:

    DATA 305   PROCEDURE 229   ZCON 131   NONHAL 130   PROGRAM 80   PDE 80
    STACK 80   HAL_LIBRARY_ZCON 68   HAL_LIBRARY_CODE 68   HALSTAT 46
    PATCH 33   HAL_LIBRARY_DATA 25   BCE 24   EXCLUSIVE 11   MSC 8

Everything but the NONHAL and BCE rows is compiler output, and the compiled
objects were on disk the whole time:

    ~/ForClaude/OI340600-clc/G9work3/    306 .obj, HAL/S, disjoint from the
                                         153 assembly modules
    (G9work1 and G9work2 are earlier runs of the same set and differ from
    work3 in a few bytes per object; use work3.)

    $0AIBGPC  A1AIBGPC  A2AIBGPC  #EAIBGPC  #DAIBGPC -- AIBGPCLO.obj's five
    sections, which is what compiler output looks like and is nothing an
    assembly module produces.

    lnk101 -f G9work3/*.obj ASMDIR/*.obj -o g9-all.fcm \
           --json-symbols g9-all.json --external-syms augmented-G9-fields.json

459 objects, and the comparison then covers 1126 SECTIONS rather than 153.

    DO NOT SET THE TWO SIDE BY SIDE.  247's 30-of-153 and this link's
    89-of-1126 count different things over different populations, and quoting
    them as a series would say the disagreement had tripled when the
    population grew sevenfold.

WHAT IT BUYS IS REAL RESOLUTION INSTEAD OF ASSERTED ADDRESSES.  --external-syms
pins every CSECT at the table's address, so an assembly-only link resolves a
reference INTO HAL/S from the index -- which is the same table the comparison
is being scored against.  With the compiled objects present the linker
resolves it from the object that actually defines it.  FIOLGERR is the case in
point: the two ZCONs after its LTORG, the very halfwords 250's defect was
dropping, are

    FIOELZCN DC    Z(,CZ2VIOER,0)      CZ2VIOER  <- CZ2COMMO.obj, HAL/S
    FIODLZCN DC    Z(,FIODLERR,0)      FIODLERR  <- FIOCBLKS.obj, assembly

and both now come from a real LD rather than from the index.

MEASURED, G9, BOTH ARMS OF THE 250 FIX, SAME 306 HAL/S OBJECTS IN EACH:

                                   before      after
        sections compared            1126       1126
        sections differing             89         89
        FAIL sections                  89         89    none new, none lost
        halfwords differing         12203      12203
        SECTIONS DIFFERING IN SIZE     10          9

    THE FAIL COUNT IS 89 AND fcmcmp SAYS SO ITSELF, on the line "FAIL:
    89/1126 section(s) differ".  An earlier draft of this entry said 80,
    which came from grepping the FAIL rows with a character class that
    silently dropped twelve of them -- the twelve carrying an annotation
    such as `[85 no reference data]` between the size and the dash.  The
    conclusion did not change, both arms being identical section for section
    and halfword for halfword, but the number was wrong.  READ THE SUMMARY
    LINE THE TOOL PRINTS RATHER THAN RE-COUNTING ITS ROWS.

    The size row that disappears is FIOLGERR's, and it is the only change:

        before   OK:  FIOLGERR @ 1A05E (136 halfwords vs 140 expected)
        after    OK:  FIOLGERR @ 1A05E (140 halfwords)

    IT READS "OK" IN BOTH, and the OK is only the CONTENT verdict, taken over
    the overlap:  before the fix it declared 136 halfwords equal and asserted
    nothing about the other four.  What changed is that the four now exist,
    and match.

    THE "OK" DOES NOT HIDE ANYTHING, and an earlier draft of this entry said
    it did.  nsts-sdl-dps PR 32 -- "fcmcmp: report sections whose size
    disagrees with the CSECT table", merged 2026-08-08 -- put the size on the
    row itself as `vs 140 expected`, listed it under "N section(s) differ in
    size from the CSECT table", and made it a HARD FAILURE.  Its second
    commit is titled "a size mismatch always fails; drop --strict-sizes":
    THERE IS NO --strict-sizes OPTION ANY MORE, the behaviour is
    unconditional, and passing the flag is now an error.  Both arms of the
    link above exited 1 on the size list alone.

    SO THE READING IS THE OTHER WAY ROUND:  fcmcmp is what FOUND this defect.
    247's SIZE-FORCED rows and 248's opening sentence -- three sections whose
    length disagrees with the CSECT table -- are that report.  Read the size
    list beside the pass/fail column, not instead of it.

    AND THE TOOLS ARE CURRENT, which was worth checking rather than assuming:
    build/bin/fcmcmp and build/bin/lnk101 are CMake-generated shell wrappers
    around an EDITABLE venv install, so they run
    ~/donschmidt/nsts-sdl-dps/src/... live and their own mtimes say nothing
    about their age.  PRs 26 through 33 are ancestors of the local HEAD and
    34 and 35's changes are present as the fork branch upstream merged.

WHAT IS STILL NOT A REAL LINK.  177 symbols remain undefined and `-f` leaves
their sites unpatched, and --external-syms still pins the layout rather than
letting the linker compute it.  So the count remains an upper bound.  But the
HAL/S half is no longer being asserted from the index, and anyone continuing
should start from the 459-object link rather than rebuild the 153.

WHY.  The HAL/S objects were on disk and 247 did not use them, so every reference from assembly into HAL/S was being resolved out of the same index the comparison is scored against.  Naming where they are, and that fcmcmp's OK row says nothing about a section that is the wrong length, are the two things that would have found 250's defect a phase earlier.

WHAT IT WAS FOR.  MLIB80 stores macro definitions and COPY decks together, and
ASM101S once read every macro definition ahead of the module.  It needed to
know which members were which so it would never preload a COPY deck.
makeMACROFILES.py produced that list.

THE PRELOAD IS GONE.  ASM101S.py has preReadLibraries = False and
readMacroLibrary returns before the preload loop.  Its own comment says the
index is now 'the list of members ELIGIBLE to be fetched when something invokes
them'.

BUT THE INDEX IS STILL LOad-BEARING, and an earlier draft of this entry said
otherwise and was WRONG.  The gate at ASM101S.py line 1070 guards
loadLibraryMacro, and that function does not merely scan a member for a MACRO
definition -- it calls

    readSourceFile(path, svGlobalLocals, {}, copy=False, printable=False, ...)

reading the member AS OPEN CODE.  The comment on the gate states the
consequence: 'a COPY fragment read as open code is what puts a DS outside any
control section.'  So a wrong entry is damaging in BOTH directions, not one.

THE DISTINCTION THAT MATTERS IS OPEN CODE, not the macro/COPY label.  RSB's
point: a COPY member holding only macro definitions would be harmless to fetch,
and would not fail.  The harm comes from a member with open code -- MACSMITH,
a deck of EQUs and PDEF invocations, is exactly that.  So the index is a proxy
for 'does this member contain open code', and it is that property a replacement
would have to test.

SO DO NOT SIMPLY DROP THE GATE.  The safe change is the diagnostic one: keep
it, and make a miss emit a message naming the member and the index, so an index
error announces itself instead of impersonating a missing macro -- which is
what FPMSWTCC did, costing five modules before it was found.  A corpus-wide
change either way, needing a kept-baseline sweep.

WHY.  RSB asked whether it is still needed.  The answer is in the code and is worth
recording, because the failure mode it now produces is the one that cost five
modules with FPMSWTCC and would look like a missing macro next time.

SUPERSEDED IN ITS NUMBERS BY 253, AND IN ITS CONCLUSION.  Every figure
below was measured on a link that included nineteen objects belonging to
OTHER configurations, whose HALSTAT sections were pinned over live memory.
Without them the residue is 321 halfwords rather than 2603, and the BCE
finding at the foot of this entry is wrong outright:  19 of the 24 BCE
sections match byte for byte and FIOPDIPG's 247 differing halfwords are 0.
The entry is kept for the method -- the decomposition is still the right
way to read the number -- and as the record of how the wrong conclusion
was reached.

WHAT THE FULL G9 LINK ACTUALLY LEAVES, decomposed.  251 established the
459-object link and reported one number, 89 sections and 12203 halfwords.
That number is mostly two sections, and the workable residue is a quarter of
its size and sits in one place.

    89 FAILING SECTIONS, 12203 HALFWORDS

      5 are ALSO THE WRONG SIZE            9600 hw   and all five are HAL/S
          #CDCDDG9  6583 hw   10098 vs 10178 (-80)
          #PCDQANN  1981 hw    2010 vs 2695 (-685)
          #DDCDDG9   976 hw    1370 vs 1372 (-2)
          #PCSPCLB    32 hw     134 vs 140  (-6)
          #PCVNMMU    28 hw   16393 vs 4105 (+12288)
      84 are THE RIGHT SIZE                2603 hw
          median 9 halfwords, 32 of the 84 differ by four or fewer

    A SECTION OF THE WRONG LENGTH IS COMPARED ONLY OVER ITS OVERLAP, so its
    halfword count is an artefact of the misalignment rather than a count of
    real disagreements, and two sections carry 8564 of the 12203 on their
    own.  Quote the 2603 as the size of the problem, and the five separately.

BY WHERE THE OBJECT CAME FROM, which is the split that says whose problem it
is -- the assembler's or the compiler's:

                     sections   halfwords
        assembly           39        1291
        HAL/S              45        1312
                                          (of the same-size 84)

    They are the same size as each other, which is worth knowing before
    anyone assumes the remainder is assembler work.

THE 177 UNDEFINED SYMBOLS EXPLAIN A SIXTH OF IT AND NO MORE.  `-f` leaves an
unresolved site as assembled, so the obvious reading is that the residue IS
those sites.  Measured against the link's own `unresolvedRelocations`, over
all 2603 differences and not fcmcmp's 32-per-section sample:

        at an unresolved relocation site      428   16%
        at a site the linker DID resolve     2175   83%

    -- 249 and 1042 on the assembly side, 179 and 1133 on the HAL/S side.  So
    the archive gap is a caveat on the number, not the explanation of it.

AND THE 177 ARE ACCOUNTED FOR, which closes a question rather than opening
one:

        56 symbols, 1069 of the 1213 sites, are #PC COMPOOL CSECTS ABSENT
        FROM THIS CONFIGURATION'S INDEX.  246's TFIVMCI1 is the precedent:
        the original build did not resolve those either.
        76 symbols, 88 sites, are FIO* -- the sibling-module BCE entry
        points of 246.
        37 symbols, 45 sites, ARE exported by an OI340600 module we build,
        and 14 modules would supply them -- FIOSMFPG alone closing 19.
        NONE OF THOSE 14 IS IN THE G9 CSECT INDEX.  The index is the
        configuration's manifest, so they are not in this build and adding
        them would be forcing a symbol to resolve against a module the
        original link never saw.  DO NOT ADD THEM.

WHERE THE ASSEMBLY-SIDE RESIDUE IS: IT IS THE BCE SECTIONS.  Of the 1291
halfwords, 1063 are in 14 sections of index type BCE -- out of only 24 BCE
sections in the whole configuration.  The four worst assembly sections are
BCE and the fifth is beside them:

        FIOPDIPG  247 of 276 halfwords differ    BCE
        FIOPMUPG  201                            BCE
        FIOIMUPG  135                            BCE
        FIOG9ADB  120                            NONHAL
        FIOSRBPG   82                            BCE

    EVERY ONE IS PLACED AND SIZED EXACTLY AS THE INDEX SAYS -- FIOPDIPG at
    124452 for 276 halfwords, which is the index's start and its length to
    the halfword.  So this is not layout.  Nearly the whole CONTENT of these
    sections disagrees, and ours is a table of relocated addresses where the
    dump holds what looks like a command stream:

        @ 1E624  2C97 vs F200    FIOPDRBC, RLD TFIVPD16 -> 2C9745F0
        @ 1E625  45F0 vs D7A4    RLD #PCGBOBF (@0VAASEQ+1C) -> 06E4C
        @ 1E626  21BC vs C000    RLD #PCDWDOW (FIODBF2P+4) -> 021BC

    NOT THE UNENCODABLE BCE INSTRUCTIONS, which was the first guess and is
    wrong.  model101.py emits four zero bytes and a diagnostic for a BCE
    operation whose encoding was never established, so the theory was that
    these sections were full of them.  The diagnostic fires in NONE of the
    153 G9 modules -- grep the assembly reports for "BCE instruction whose
    encoding has not been established" and there are no hits at all.
    Something else produces these sections and it has not been identified.

    That is the head of the queue for the assembly side.  The HAL/S side's
    1312 halfwords are a separate question and are not the assembler's.

WHY.  251 left the phase with one aggregate number, and an aggregate is where work goes to hide: two sections carry seventy per cent of it, the undefined-symbol caveat explains a sixth rather than most, and the assembly-side remainder turns out to be concentrated in fourteen BCE sections rather than spread across thirty-nine.  Recording the decomposition, and that the obvious BCE explanation is already refuted, is what makes the next session's first hour useful instead of repeated.

NINETEEN OF 252'S TWENTY-SIX HUNDRED HALFWORDS WERE THE HARNESS.  252 said the
assembly-side residue was concentrated in the BCE sections and named FIOPDIPG,
247 halfwords differing out of 276, as the worst.  IT IS NOW ZERO.  So are
FIOPMUPG's 201, FIOSRBPG's 82, FIOIMUPG's 135 and FIONWSPG's 29.  Nothing in
the assembler changed; nineteen object files came out of the link.

    THE LINK WAS BEING GIVEN MODULES FROM OTHER CONFIGURATIONS.  G9work3
    holds 306 HAL/S objects and nineteen of them are not G9's:

        DCDDG1  DCDDG2  DCDDG3  DCDDG8  DCDDS2  DCDDS4  DCDDS8
        DKFCM1  DKFCM2  DKFCM3  DKFCM4  DKFCM5  DKFCM6  DKFCM8
        DPDSPC  DPLLIGHT  DSPSPC  DXCCCSPE  DXRDMM

    -- the G1, G2, G3, G8, S2, S4 and S8 variants of sections G9 has its own
    version of.  Each contributes one ZCON and TWO SECTIONS THE INDEX TYPES
    AS `HALSTAT`, and a HALSTAT record is the compiler's statistics block,
    not loadable memory.  --external-syms pins every CSECT at the address the
    table gives, so those 46 HALSTAT sections were laid into the image at
    addresses that are not load addresses at all, 22280 halfwords of them,
    ON TOP OF 68 REAL SECTIONS and 15783 halfwords of live content.

HOW IT PRESENTED, and why it read as an assembler fault.  FIONWSPG is 34
halfwords and 29 of them differed.  Its own object is RIGHT -- byte for byte
against the dump at 30 of the 34 -- and the four that are not are exactly its
four `#LBR@ FIOBRE` operand slots, which hold 0000 before relocation and 8BC6
after, 8BC6 being FIOBRE's address of 35782.  The link then overwrote nearly
the whole section:

        halfword   object   linked   dump
        1DE6E      FA00     3496     FA00      the object already matched
        1DE70      C000     F0DE     C000      the object already matched
        1DE74      0052     3C78     0052      the object already matched

    46 relocations are recorded inside those 34 halfwords and FIONWSPG's
    object declares FOUR.  The other 42 belong to #CDCDDG1, #CDCDDG2,
    #CDCDDG3 and #CDCDDG8, three of which are pinned at 122316 and one at
    122466, each two to three thousand halfwords long, and FIONWSPG lives at
    122478 inside all four.

    COMPARE THE OBJECT AGAINST THE DUMP BEFORE BLAMING THE ASSEMBLER.  One
    hexdump of FIONWSPG.obj would have settled this immediately, and instead
    a whole entry was written about BCE encodings on the strength of the
    LINKED image.  The object is the assembler's output; the image is the
    harness's.

MEASURED, G9, the same 153 assembly objects, only the HAL/S list changing:

                                 306 objects   287 objects
        sections compared               1126          1095
        OK                              1037          1045
        FAIL                              89            50
        N/A, not in configuration         32             0
        differing halfwords            12203          9881
        SAME-SIZE RESIDUE               2603           321
             of it, assembly            1291           167
             of it, HAL/S               1312           154
        BCE sections matching          10/24         19/24

    THE N/A GROUP GOES TO ZERO, which is the confirmation that this is the
    right cut rather than a lucky one:  the 32 sections fcmcmp was reporting
    as "not in this configuration" ARE the alternate-configuration sections,
    and once their objects are not linked there is nothing left to report.

WHAT REMAINS IS 321 HALFWORDS OVER 46 SECTIONS, near-evenly assembly and
HAL/S, plus four sections whose SIZE is wrong and which therefore contribute
a further 9560 that measures misalignment rather than disagreement:

        #CDCDDG9  6583      #PCDQANN  1981      #DDCDDG9  964
        FIOCBLKS    55      #PCVAMMD    44      #PCSPCLB   32
        FIOPDISP    23      FIOMGDSP    10      FIOADCNS    8

250'S RESULT IS UNCHANGED ON THE BETTER BASIS, which is the point of
re-running both arms rather than only the good one:  50 failing sections in
each, the same 50, 9881 halfwords in each, and the only difference between
them is that FIOLGERR's size mismatch is present in the before arm and absent
in the after.  Size-mismatched sections 7 -> 6.

    THE OBJECT LIST IS PART OF THE MEASUREMENT.  247 introduced the
    multi-object link and nobody asked what was in the directory; the answer
    was 94 per cent right, and the other 6 per cent was most of the number
    the phase has been trying to reduce ever since.

WHY.  252 blamed the assembler for content the linker had overwritten, on the strength of the linked image rather than the object file.  The object was right at 30 of FIONWSPG's 34 halfwords all along.  Recording the object-versus-image check, and that the directory's contents are part of the measurement, is what keeps the next reduction honest.

A MODULE WAS CARRYING EXTERNAL REFERENCES TO ITS OWN LABELS.  `DC Z(sym,...)`
where `sym` is defined in the same module emitted BOTH the symbol's own offset
into the address field AND an RLD naming the symbol, so the linker added its
resolved address on top of its own offset.  FIOMGCV is the case to hold on to:

    FIOMMCHK DS    0H                              at section offset 24
    ...
    FIOMMZCN DC    Z(FIOMMCHK,FIOCBLKS,15)         the field holds 0024

    linked   1A17C        = 1A158 + 24, the offset counted twice
    dump     1A158        = FIOMMCHK

    THE ADDRESS FIELD IS CORRECT AND IS MEANT TO BE.  A note in that code
    already records why -- FCMG3INT's `Z(FCG3INL1,FCMCBLKS,X'D')` names a
    label of its own and the original build assembles its address, which
    ASM101S used to emit as 0000.  What was missing is that a field holding
    the offset must relocate against the SECTION, so the linker adds the
    section's BASE, and not against the symbol, whose address already
    contains the offset.

    IT WAS ALSO DECLARED EXTRN.  FIOMGCV's object carried ER cards for
    FIOMMCHK, FIOMGPCV and FIOMGCVR -- three labels it defines itself.  Under
    --external-syms the table supplied them and the double-count followed;
    in a link WITHOUT that table they are simply undefined and the ZCON keeps
    the bare offset.  Wrong either way, and only visible as the former.

THE FIX, in model101.py's `DC Z` arm: if the named symbol resolves to a
non-DSECT section of this module, the RLD names THAT SECTION, the symbol is
not added to `extrns`, and the emitted address drops the inter-CSECT offset
so it is section-relative -- a no-op for a single-CSECT module, where the
first section's offset is 0, and correct for one with several.

MEASURED, and the reach is exactly what it should be:

    RUNASM --no-rtl-fixes   205/205 byte-for-byte           unchanged
    verify-sweep            267 MATCH  5 MATCH?  0 DIFFERS  unchanged, no
                            module changed class
    oi340600-sweep          177 OK  47 OK-EARLY  0 failures unchanged, no
                            module changed class

    OF 45 OI340600 MODULES ASSEMBLED BOTH WAYS with PYTHONHASHSEED PINNED,
    SIX DIFFER, AND ALL SIX USE `DC Z(`:  FCMG3INT, FCMMGPOV, FIOCGR,
    FIOMGCV, FIOMM128, FPMFCLOS.  The other 39 are byte-identical.

    G9, the alternate-free 287+153 link of 253, all 153 reassembled:

        same-size residue      321 -> 316 halfwords
        failing sections        50 -> 50, the same 50, none new, none lost
        sections differing in size   6 -> 6

        FIOMGCV   7 halfwords differing -> 4
        FCMMGPOV  3 -> 2
        FPMFCLOS  2 -> 1

    ONLY THREE OF THE SIX ARE IN G9 AT ALL.  FCMG3INT, FIOCGR and FIOMM128
    are not in this configuration's object set, so their objects change and
    this link cannot show it either way.  Whether they improve is a question
    for the configuration that does contain them.

WHAT IS UNDERNEATH IT IS THE ZCON'S SECOND OPERAND, and that is the next
thing.  The halfwords still differing are the ZCON's SECOND word and they are
all the same shape -- the low nibble:

        FIOMGCV    ours 0F30   dump 0F31
        FCMPSA     ours 0F30   dump 0F33
        FCMZCONS   ours 0800   dump 0803

    `Z(FIOMMCHK,FIOCBLKS,15)` has THREE fields and only the first and third
    are used:  the entry, and the flags that become byte 2.  The SECOND names
    the BASE SECTION -- FIOCBLKS -- and its sector belongs in the DSR nibble
    that is coming out 0.  Fixing it needs a SECOND relocation per ZCON,
    naming the base section with the DSR rldFlags (0x20/0x40/0x50, as the
    note in the same arm already describes), which changes what one `DC Z`
    puts in the RLD and is why it was not done in the same pass as this.

    THE THIRD FIELD IS NOT THE SECTOR.  `15` is 0xF and lands in byte 2,
    where both images agree; the disagreement is entirely in byte 3, which
    the assembler emits as zero and the linker patches.  Do not conflate
    them.

WHY.  An object with ER cards for its own labels is wrong in a way --external-syms hides: the table supplies the symbol, the linker adds it to the offset already in the field, and the result is only ever visible as a wrong address rather than as a link error.  Recording the shape of it, and that the ZCON's second operand is still unused, is what the next pass needs.

THE ZCON'S SECOND OPERAND IS THE DATA BASE, AND IT NOW REACHES THE OBJECT.
254 left this as the next thing: `DC Z(entry,base,flags)` has three fields and
ASM101S used only the first and the third, so the DSR nibble came out 0.

    HW1 OF A ZCON IS  XC C CB CD BSR(7-4) DSR(3-0).  The `flags` operand is
    its HIGH byte -- 15 is 0x0F and both images agree on it.  The low byte is
    two sector registers and the assembler emits it as zero for the linker to
    patch.  BSR comes from the ENTRY's sector via the address relocation.  DSR
    comes from the BASE, and nothing was telling the linker what the base was.

        FIOMGCV   `Z(FIOMMCHK,FIOCBLKS,15)`   0F30 against the dump's 0F31
        FCMMGPOV  `Z(FCMMGOVP,FCMCBLKS,15)`   0F30 against 0F31
        FPMFCLOS  `Z(FPMSVCL+2,FPMSVC21,8)`   0830 against 0831

    -- and FIOCBLKS is at 35782, FCMCBLKS at 33050, FPMSVC21 at 33094, all in
    SECTOR 1, which is the nibble in every case.  The sector is the halfword
    address shifted right 15.

THE FORMAT ALREADY HAS THE MECHANISM AND IT IS DOCUMENTED IN THE LINKER.
lnk101's ap101Utils/addrcon.py, ZCon's docstring, says three RLD entries may
point at one ZCON:

    address   0x04 / 0x10 / 0x50   writes HW0, and patches BSR (or DSR, 0x50)
    BSR-only  0x20                 patches BSR in HW1 alone
    DSR-only  0x40                 patches DSR in HW1 alone

So the fix is a SECOND relocation per code ZCON, rldFlags 0x40, naming the
base.  It is read from the grammar's `A1` field, which is the second operand
when `z` or `zx` is present and is otherwise the address expression -- which
is why it was being ignored: the only code that read A1 was the branch for
`Z(,expr,flags)`, where there IS no base.

    ONLY THE CODE FORM GETS IT.  `Z(,expr,flags)` has no base operand; its
    DSR is patched by the 0x50 address relocation from the target's own
    sector, which already worked.  Do not add a second RLD there.

    THE BASE IS RESOLVED THE WAY 254 RESOLVES THE ENTRY -- a section of this
    module is named as that SECTION, anything else is declared EXTRN -- so a
    module does not acquire an ER for a base it defines itself.

MEASURED, G9, the alternate-free link with all 153 reassembled:

        FPMFCLOS   1 halfword differing -> 0, the section now MATCHES
        FIOMGCV    4 -> 1
        FCMMGPOV   2 -> 1
        failing sections        50 -> 49
        same-size residue      316 -> 311 halfwords

    RUNASM --no-rtl-fixes   205/205 byte-for-byte           unchanged
    verify-sweep            267 MATCH  5 MATCH?  0 DIFFERS  unchanged
    oi340600-sweep          177 OK  47 OK-EARLY  0 failures unchanged

WHAT IS LEFT IN THOSE TWO IS NOT A ZCON PROBLEM, and saying so is the point:

        FIOMGCV   @1A17F  0000 vs DD22
        FCMMGPOV  @193DE  8000 vs CBEA

    The first is an unresolved site -- we hold 0000 because the linker could
    not resolve the symbol, which is the archive gap and not an assembler
    fault.  The second is neither 0000 nor an address the table knows, and is
    the one worth looking at next.

    THE THREE ZCON DEFECTS WERE THREE DIFFERENT THINGS, in one operand each:
    250's was the LTORG accounting underneath the constant, 254's was
    relocating the FIRST operand against itself, and this is the SECOND
    operand never being emitted.  Finding one did not suggest the others; each
    came from reading the halfwords that were still wrong after the last.

WHY.  254 named the second operand as the next thing and this is it, but the useful part is that the format already had the mechanism -- three RLDs may point at one ZCON and the linker documents all three.  The fix was reading the tool that consumes the object, not inventing an encoding.

A NEGATIVE DISPLACEMENT NEEDS THE SIGN BIT, AND HALF THE CONVENTION WAS
ALREADY IMPLEMENTED.  `DC Y(SYM-1)` emits the MAGNITUDE, 0001, and the note in
that arm records why -- the original does the same, eight instances, six at -1
in FCMCBLKS.  What it did not do is tell the linker that the magnitude is
negative, so the linker ADDED it and every one came out two halfwords high:

    DC    Y(CZ2VNOMB-1)     ours 271B   dump 2719
    DC    Y(CZ2BMODE-1)          26E4        26E2
    DC    Y(CZ2BGRTS-1)          26FD        26FB
    DC    Y(TFCMDEUC-1)          9D67        9D65
    DC    Y(CZ2VMETM-1)          26D7        26D5
    DC    Y(CZ2VTSIP-1)          26D1        26CF

THE FLAG BYTE'S BIT 7 IS THE SIGN, from OBJECTGE.xpl, and lnk101 implements it
-- ap101Utils/addrcon.py: "V (sign) is the sign of the YCON in the text record
-- V=1 means existing is the absolute value of a negative", and then
`signed_existing = -existing if self.sign else existing`.  The object was
being punched with flags 0x00 for every YCON.  It is now 0x80 when the
displacement is negative, which is the one bit that was missing.

    ASM101S ALREADY KNEW THE DISPLACEMENT WAS NEGATIVE.  A negative offset
    from an EXTRN borrows out of the hashcode, so `unhash` returns None and
    the Y arm recovers the symbol by adding 1<<36 back and taking
    `abs(_yLow - (1 << 36))`.  That `abs` is where the sign was discarded; the
    branch that computes it now sets the flag as well.

    FCMCBLKS goes from six differing halfwords to a MATCH.

THE SAME CONVENTION ON THE MSC PATH IS NOT FIXED, and it is the next thing.
FIOMDPPG writes

        #LBR@  FIOBRE-2
        #MOUT@ FIOWCE-2

and its object holds FA00 0002 and FD00 0002 -- the magnitude again -- WITH NO
RELOCATION AT ALL.  `mscLongField` calls `unhash` and returns the raw value
when it gets None, which is exactly the hashcode borrow the Y arm learned to
recover from; the relocation is simply never appended, so the site keeps the
bare displacement.  Two halfwords, 8BC4 and 8C92 in the dump.

    IT NEEDS BOTH HALVES:  the same +1<<36 recovery in `mscLongField`, and the
    ACON's signed flag byte, which addrcon.py names as 0x9C -- ACON|sign --
    rather than the 0x1C the writer punches for every A-type relocation now.

    FOUR MODULES USE A NEGATIVE DISPLACEMENT AT ALL, which is why so little of
    the corpus moves:  FCMCBLKS, FIOCBLKS and FIOCDATG in `DC Y(...)`, and
    FIOMDPPG in the `@` form.  FIOCBLKS's and FIOCDATG's sites name symbols
    that are unresolved in a G9 link, so they show nothing either way here and
    are not evidence that the fix did not reach them.

MEASURED, G9, with 255's DSR relocation also in place:

        FCMCBLKS  6 halfwords differing -> 0, the section MATCHES
        failing sections       49 -> 48
        same-size residue     311 -> 305 halfwords

WHY.  The assembler already emitted the magnitude and said so in a comment; only the sign bit was missing, so the defect was half-implemented rather than absent.  Recording that the SAME convention is unfixed on the MSC path, where the relocation is not emitted at all, is what keeps the pair together.

`#LBR@ SYM-n` CANNOT BE LINKED CORRECTLY BY lnk101 AS IT STANDS, and the
assembler is not the thing to change.  256 named this as the next fix and it
was attempted; the attempt is recorded here because BOTH of the obvious
encodings are wrong and the evidence pinning them is worth not re-deriving.

    THE CONTEMPORARY LISTING FIXES THE OBJECT BYTES.  OI301700's FIOMDPPG is
    one of the 272 modules with a real assembly listing, and it says:

        00006 FA00 0002      0002    33    #LBR@ FIOBRE-2
        00008 FD00 0002      0002    34    #MOUT@ FIOWCE-2

    -- the MAGNITUDE, opcode intact.  That is what ASM101S emits and it is
    right to.  The note in the BCE ADDRESS arm saying "the original writes the
    magnitude" is evidence-based and should not be second-guessed:  it comes
    from this listing, not from the dump.

    THE DUMP FIXES THE LINKED VALUE.  G9 has FA00 8BC4, and FIOBRE is 8BC6,
    so the linked address field is FIOBRE-2 with the opcode untouched.

    SO THE RELOCATION MUST SUBTRACT THE MAGNITUDE FROM THE ADDRESS FIELD AND
    LEAVE THE OPCODE ALONE.  Neither flag byte does that:

        0x1C, plain ACON   adds        FA000002 + 8BC6 = FA008BC8, +4 wrong
        0x9C, ACON|sign    negates the WHOLE existing fullword -- addrcon.py's
                           `signed_existing = -existing if self.sign else
                           existing` -- giving 0600 8BC4:  address right,
                           opcode destroyed.  Measured, not predicted.

    AND THERE IS NO THIRD OPTION IN THE FORMAT AS IMPLEMENTED.  addrcon.py
    gives YCON two bytes and ACON four and nothing between, so a relocation
    covering the 24-bit address field alone cannot be expressed.  A YCON at +2
    would cover the low halfword only and cannot carry a target at or above
    0x10000, which the arm's own note already explains for FCMSFCAM.

WHAT WOULD FIX IT IS IN lnk101, NOT HERE:  a signed ACON should negate the
DISPLACEMENT the field carries, not the whole fullword that has an opcode in
its top byte.  That is somebody else's repository -- see the standing rule --
so it is written down rather than done.

    ASM101S ALSO EMITS NO RELOCATION AT ALL FOR THIS SITE, which is a second
    and smaller thing.  `bceField` returns the raw hashed value when `unhash`
    reports the hashcode borrow and never sets `bceRelocSymbol`, so the site
    keeps its assembled bytes.  Recording the symbol there is a two-line
    change and was tested; it is NOT committed, because on its own it makes
    the halfwords worse rather than better -- with 0x1C the address goes from
    2 wrong to 4 wrong.  It should land WITH the linker change and not before.

THE COST OF GETTING THIS WRONG WAS ONE SWEEP, and it is the reason the
OI301700 corpus is in the bar at all.  The two's-complement encoding was
tried first, on the arithmetic alone:  FA008BC4 - 8BC6 = F9FFFFFE, so put
that in the field and let a plain ACON add.  It works -- FIOMDPPG MATCHES the
G9 dump and the failing sections go 48 to 47 -- AND IT IS WRONG, because the
listing says the object holds FA000002.  verify-sweep caught it as the one
regression in 272 modules, FIOMDPPG MATCH -> DIFFERS.

    A CHANGE THAT IMPROVES THE LINKED IMAGE CAN STILL BE WRONG ABOUT THE
    OBJECT.  The dump constrains what comes OUT of the linker; only a listing
    constrains what goes IN.  Where both exist they have to agree, and where
    they disagree the listing is the one describing the assembler.

WHY.  The change worked against the dump and was still wrong, and only the OI301700 listing said so.  Recording both encodings with the measurement that kills each, and that the remaining fix is in lnk101 rather than the assembler, is what stops the next attempt repeating a sweep to learn it.

257'S DEAD END IS OPEN, AND IT TOOK A CHANGE ON BOTH SIDES.  257 established
that `#LBR@ SYM-n` could not be linked correctly and that the missing piece
was in lnk101 rather than the assembler.  It is now fixed in both, and neither
half works alone.

    THE LINKER, nsts-sdl-dps PR #36, `lnk101: a signed ACON negates its
    address field, not its opcode byte`.  `AddrCon.apply` negated the whole
    existing value for V=1, which is right for a YCON -- the entire two-byte
    field is the constant -- and wrong for a four-byte ACON carrying a BCE
    long-format instruction, whose top byte is the OPCODE.  It now negates the
    low 24 bits and leaves the rest of the word standing.  `reverse` mirrors
    it.  Five tests added; the existing 18 pass unchanged.

    THE ASSEMBLER, here, virtualagc 3de3533eb.  `bceField` returned the raw
    hashed value when
    `unhash` reported the hashcode borrow and never set `bceRelocSymbol`, so
    NO relocation was emitted; it now records the symbol and marks the
    displacement negative, and objectWriter punches 0x9C instead of 0x1C for
    it.  THE ASSEMBLED BYTES DO NOT CHANGE:  the field keeps the magnitude the
    contemporary listing shows.

BOTH CONSTRAINTS ARE NOW SATISFIED AT ONCE, which is the whole point and is
what 257 could not do:

    object    FA00 0002 FD00 0002   byte-identical to OI301700's listing
    linked    FA00 8BC4 FD00 8C92   byte-identical to the G9 dump

    verify-sweep   267 MATCH  5 MATCH?  0 DIFFERS, FIOMDPPG back to MATCH
    RUNASM         205/205 byte-for-byte
    oi340600-sweep 177 OK  47 OK-EARLY  0 failures
    G9             FIOMDPPG MATCHES; failing sections 48 -> 47

    THE REGRESSION 257 RECORDS IS THE PROOF THE PAIRING IS RIGHT.  The
    two's-complement encoding matched the dump and broke the listing.  This
    matches BOTH, because the sign moved out of the data and into the
    relocation, which is where the format puts it.

    NEITHER HALF IS COMMITTABLE ALONE.  Without the linker change, 0x9C
    negates the opcode and the halfwords get worse, 2 wrong to 4.  Without the
    assembler change, nothing in the corpus emits 0x9C at all and the linker
    path is unreachable.  A bisect that lands between them will show a
    regression in one direction or dead code in the other; that is expected
    and is not a defect in either.

IT WAS COMMITTED AND PUSHED AHEAD OF ITS SWEEP FINISHING, deliberately:  the
PR quotes the assembler side, and without it upstream the change cannot be
assessed at all.  RUNASM and verify-sweep were already clean when it went;
the OI340600 sweep confirmed afterwards.  Worth recording as the reason,
because the commit message is `Updates to ASM101S.` and says none of this.

THE ASM101S SIDE NEEDS lnk101 AT PR #36 OR LATER.  Anyone building against an
older nsts-sdl-dps will see FIOMDPPG's two halfwords go from wrong to
differently wrong.  It is two halfwords in one module of 224, so it is not
worth gating the build on, but it is worth knowing before it is diagnosed
twice.

WHY.  Neither half of this is committable alone -- the assembler change makes the halfwords worse without the linker one, and the linker path is unreachable without the assembler one -- so a bisect landing between them looks like a regression or like dead code.  Saying which commit and which PR, and that both corpora now agree, is what makes that legible later.

THE ASSEMBLY-SIDE RESIDUE IS 23 HALFWORDS AND ELEVEN OF THEM ARE NOT DEFECTS.
With 258's pair in place the G9 link leaves 149 differing halfwords on the
assembly side, 126 of them at unresolved relocation fields -- the archive gap,
where we hold 0000 and the dump holds an address.  The other 23 are the real
question, and two findings account for eleven:

    FIOGPSPG      8      the BCE bypass, and it is RUNTIME STATE
    FCMBMTG9 1 + FIOMVUPG 2   TFIVPF12, and it is a HAL/S object
    the other 12  listed below, still open

FIOGPSPG'S EIGHT ARE THE BYPASS OVERLAY AND THE SOURCE SAYS SO.  Four sites,
two halfwords each:

    FIOBY1GC #DLYI 68              OVERLAID BY BCE BYPASS CODE

    ours  C044 C000     the #DLYI 68 the assembler is asked for
    dump  F001 DD36     a long-form branch

and DD36 is FIOEL1GC, the element-exit label four halfwords on.  All four
agree:  FIOBY1GC -> FIOEL1GC, FIOBY3GC -> FIOEL3GC, FIOBY1GL -> FIOEL1GL,
FIOBY3GL -> FIOEL3GL.  The assembler is right and the dump holds something no
assembly produces.

    ELEMENTS 1 AND 3 ARE BYPASSED AND ELEMENT 2 IS NOT.  FIOBY2GC and FIOBY2GL
    are ENTRY points of the same kind, in the same section, and they MATCH.  A
    build-time overlay would have patched all six the same way; a per-element
    difference is the running software's own state at the moment the dump was
    taken.  These belong with the I-LOADs and patches of the exceptions file,
    not with anything an assembler could emit.

    SO A BCE BYPASS SLOT IS EVIDENCE ABOUT THE DUMP, NOT ABOUT THE BUILD, and
    a future sweep that "fixes" one has fitted the assembler to a runtime
    accident.  FIOSRBPG carries twelve such ENTRY points and matches entirely,
    which is the control:  its elements were not bypassed.

TFIVPF12 IS A HAL/S OBJECT DISAGREEING WITH HALSTAT AND WITH THE DUMP.  Three
halfwords, all reading F941 against the dump's F921 -- 32 halfwords high:

    HALSTAT / the index   #PCVHPLD + 17  = F921    agrees with the dump
    the link              CVHPLD.obj     = F941    63809
    #PCVHPLD              63760..63802, length 43

63809 IS PAST THE END OF ITS OWN SECTION.  The compiled object declares the
symbol 49 halfwords into a section 43 long, the linker prefers an object's
definition to the table's, and the three sites follow it.  246's independent
source is the one that matches the dump here.

    DO NOT FIX THIS BY PREFERRING THE INDEX.  It would close three halfwords
    and it is the circular move 246 refused for a different reason:  the index
    is what the comparison is scored against.  What is wrong is either that
    object or the compilation it came from, and that is where to look.

THE TWELVE STILL OPEN, for whoever takes them:

    FCMPSA   @D      0F30 vs 0F33     ZCON DSR nibble, target unresolved
    FCMZCONS @8BB9   0800 vs 0803     same shape; its target is FIOHFEPG,
                                      which is not in this configuration
    FIOCBLKS @8D71   00C6 vs 0000     we write, the original leaves zero
    FIOCBLKS @8F39   0400 vs 0E00
    FIOADCCL @99F9   96D8 vs 96D6     +2, the negative-displacement signature,
                                      but FIOIPR is in no index and appears in
                                      no source -- it comes from a macro
    FIOPBYG9 @9E65   0500 vs 0000
    FIOMVUDT @A1DB   0146 vs 00FC
    FCMNINIT @18B4F  0010 vs 0001
    FIOMGDSP @1A499  0000 vs 0003
    FIOMGDSP @1A49B  0000 vs 0003
    FIOPDSPG @1E4B3  05C0 vs 0000
    FIOPDSPG @1E4BF  05C4 vs 0000

    FOUR OF THEM ARE "WE WRITE SOMETHING, THE ORIGINAL LEFT ZERO", which is
    the shape a patch area has.  Check that before checking the assembler.

THE HAL/S SIDE IS NOW THE LARGER HALF -- 130 unexplained halfwords against the
assembly side's 23 -- plus four sections whose SIZE disagrees with the table
and which therefore contribute a further 9560 that measures misalignment
rather than disagreement.  None of that is the assembler's.

WHY.  Eleven of the twenty-three remaining halfwords turn out not to be assembler defects at all -- four bypass slots holding runtime state and one HAL/S object contradicting HALSTAT -- and both are the kind a sweep would happily 'fix' by fitting the assembler to the dump.  Naming them, with the controls that prove them (FIOBY2* matching, FIOSRBPG matching entirely), is what stops that.

THREE OF 259'S FOUR "PATCH-SHAPED" SITES ARE ACCOUNTED FOR, AND THE FOURTH IS
NOT PATCH-SHAPED AT ALL.  259 grouped four differences by their shape -- we
write a value, the original left zero -- and guessed patch areas.  Two are a
harness leak, one is runtime state, and the last is an ordinary assembler
question that the grouping obscured.  The shape was a weak signal and is worth
distrusting.

TWO ARE THE INDEX OFFERING FIELDS OF A COMPOOL IT KNOWS IS NOT IN THE BUILD.

    FIOPF1DW #LBR TFCMPFD1     ours 05C0    dump 0000
    FIOPF2DW #LBR TFCMPFD2     ours 05C4    dump 0000

TFCMPFD1 and TFCMPFD2 are fields of #DDPLLIG, and the index's own entry for it
reads

    {'start': 1442, 'end': 1483, 'type': 'HALSTAT',
     'inConfig': False, 'spanOwner': '#DDG9LIG'}

-- `inConfig: False`.  The index ALREADY RECORDS that the section is not in
this configuration, and --external-syms pins it anyway and hands out addresses
for its two fields.  The original build did not resolve them, which is why the
dump holds 0000; this is 246's TFIVMCI1 exactly, and 246 said so: "A CSECT
absent from the configuration means the COMPOOL is not in this build and the
field is skipped, which is correct rather than a shortfall."

    IT IS A DEFECT IN NEITHER TOOL, and an earlier draft of this entry framed
    it as a choice between fixing lnk101 and fixing dass-fields.py.  That was
    a false choice in both directions, and fcmcmp.py settles it -- its
    `load_not_in_config` docstring is where the design is written down:

        "The linker needs their addresses: a configuration can hold a
        module's ZCON without holding the module, and the ZCON must point at
        the address that code has in the configuration where the overlay IS
        loaded.  So the section gets placed..."

        "...`inConfig: false` is weak evidence.  A configuration can hold
        both the ZCON and the module, so a section marked absent may be
        present after all.  Measured across eight PASS configurations, 79
        marked sections MATCH the reference image."

    So dass-fields.py MUST emit the entry -- spanOwner depends on it -- and
    lnk101 MUST place it.  Making either "honour the flag" would break the
    ZCON-into-overlay case both were built for, and the 79 matching sections
    say the flag cannot carry that weight on its own.

    WHAT IS ACTUALLY WRONG IS NARROWER AND IS NOT CODE.  --external-syms does
    two jobs at once:  it PLACES sections, which is needed, and it DEFINES
    symbols, which stands in for a real link.  It cannot tell "resolve this
    deliberately into an unloaded overlay" from "this symbol was undefined in
    the original link".  Here nothing but the table defines TFCMPFD1 and
    TFCMPFD2 -- DPLLIGHT is not linked and DG9LIGHT is -- so the original G9
    linker had no definition and left 0000, and ours manufactures one.

    THESE TWO HALFWORDS ARE THEREFORE A HARNESS ARTIFACT OF THE SAME FAMILY
    AS THE ARCHIVE GAP, bounded and known:  40 index entries carry the flag, 3
    are still placed, and 2 fields resolve from them.  Nothing else in the
    corpus is touched.  Do not "fix" it in either tool.

ONE IS THE PERMANENT BYPASS TABLE, WRITTEN TO AFTER LOAD.

    FIOPBYG9 is `FIOPBYMC G9`, "PERMANENT BYPASS TABLE OPS GNC 9", twelve
    halfwords.  The macro says

        GPS      EQU   X'0500'             WORD 0-L
        ...
        WORD0SL  EQU   GPS

    so 0500 is what the source asks for and what we assemble.  The dump holds
    0000.  A table the software reads to decide what to bypass, differing from
    its assembled value, was written to after load -- the same subsystem as
    259's FIOGPSPG overlay and the same category of evidence.

    NOTE THAT IT POINTS THE OTHER WAY FROM 259's FINDING, and that is not a
    contradiction to be smoothed over:  259 has GPS elements 1 and 3 BYPASSED
    in the BCE programs, and here the permanent-bypass word for GPS reads
    CLEAR.  Whatever the relationship between the table and the programs it
    drives, the dump is a snapshot of a running system and both are its state,
    not the build's.

THE FOURTH IS NOT A PATCH AREA AND IS THE ONLY REAL ASSEMBLER QUESTION OF THE
FOUR.

    FIODLCMW DS    0F
             DC    AL.8(FIOPZERO),AL.5(FIOPGNDA),AL.4(FIOPCMDC)

    ours 00C6, dump 0000, in the second halfword.  All three symbols are LOCAL
    EQUs with definite values -- FIOPZERO 0, FIOPGNDA X'11', FIOPCMDC 0 -- so
    the original build computed a definite constant here too and got a
    different one.  These are BIT-LENGTH address constants, 8 + 5 + 4 = 17
    bits, and how they pack and pad is the question.  It is one halfword and
    it is genuinely ours.

    IT WAS FILED UNDER "PATCH AREA" BECAUSE IT LOOKED LIKE THE OTHER THREE.
    Zero in the dump means "the original wrote nothing here" only when
    something could have stopped it writing; with three local EQUs nothing
    could.  Group by MECHANISM, not by the shape of the difference.

WHY.  259 grouped four differences by their shape and called them patch areas; three had three different mechanisms and the fourth was an ordinary assembler question.  Recording that the shape was a weak signal, with the measurement bounding the index leak to exactly two halfwords, is what stops the next pass reaching for a linker change over it.

A BIT-LENGTH CONSTANT GROUP PADS TO A HALFWORD, NOT TO A BYTE, and 260's last
open site was that and not a patch area.  `DC AL.8(a),AL.5(b),AL.4(c)` is 17
bits; ASM101S padded to 24 and the original pads to 32.

    THE LISTINGS DETERMINE THE RULE OUTRIGHT.  Every bit-length group in the
    OI301700 corpus, with the bytes its listing says it generated:

        15 bits -> 2 bytes        16 bits -> 2 bytes
        17 bits -> 4 bytes        32 bits -> 4 bytes

    Byte padding predicts THREE for the 17-bit group.  Fullword padding
    predicts FOUR for the 15-bit one.  Halfword padding is the only rule that
    fits all four, and the 17-bit group is the single case in the corpus that
    separates them -- FIOCBLKS'

        FIODLCMW DS    0F
                 DC    AL.8(FIOPZERO),AL.5(FIOPGNDA),AL.4(FIOPCMDC)

    which its listing assembles to 00880000.

THE BYTE HAS TO COME FROM THE CONSTANT AND NOT FROM THE FILL, which is the
part worth keeping.  Under byte padding the group was three bytes and the
fourth was ALIGNMENT padding for the `DS 0F` that follows -- and alignment
padding takes the fill pattern.  So:

    --fill=0000   0088 0000    right by accident
    --fill=C6C6   0088 00C6    wrong, and this is what the G9 link compares

    THE SECTION LENGTH IS THE SAME EITHER WAY, 3420 bytes, because the DS 0F
    absorbs the difference.  Only the byte's VALUE changes.  That is why
    nothing but a fill-pattern comparison could ever have seen it.

    SO THE OI301700 CORPUS IS BLIND TO THIS ENTIRE CLASS.  verify-sweep runs
    at the default fill of 0000, where an unwritten byte and a zero byte are
    indistinguishable, and FIOCBLKS MATCHED throughout.  272 modules compared
    against contemporary listings, and the defect sat in one of them the whole
    time.  A byte that is zero in the reference proves nothing unless the fill
    is something else.

    THE OI340600 PATH PASSES --fill=C6C6 BECAUSE compileLinkCompare DOES, and
    that is the only reason this surfaced.  Worth remembering as a technique:
    a non-zero fill turns "we never wrote here" into a visible statement.

MEASURED:

    RUNASM --no-rtl-fixes   205/205 byte-for-byte           unchanged
    verify-sweep            267 MATCH  5 MATCH?  0 DIFFERS  unchanged, no
                            module changed class
    FIOCBLKS  FIODLCMW 0088 00C6 -> 0088 0000 at --fill=C6C6, and unchanged
              at --fill=0000; SD length 3420 both ways

WHY.  The rule is determined by exactly one group in the corpus -- the 17-bit one -- and the byte it adds is invisible at the default fill, so the OI301700 sweep matched throughout while the defect sat in it.  Recording both, and that a non-zero fill is what makes an unwritten byte visible, is the transferable part.

DONE (virtualagc 9d25cd771).  loadLibraryMacro still skips any member the
library's MACROFILES.txt does not list, and must: it reads a fetched member as
OPEN CODE, so pulling in a COPY fragment puts a DS outside any control section.

When the member is ACTUALLY PRESENT in the library and simply not indexed, it
now says so, once per member, on stderr:

    Warning: MACSMITH.asm exists in MLIB80 but is not listed in its
    MACROFILES.txt, so it cannot be fetched as a macro; re-run
    makeMACROFILES.py if that is wrong

Only that case is reported.  Most misses are ordinary -- the name is simply not
a macro -- and warning on those would bury the signal.

MEASURED, NOT ASSUMED.  A full 224-module sweep emits the warning ZERO times
and classifies every module exactly as the kept baseline: 176 OK, 47 OK-EARLY,
1 ERRORS, nothing moving.  So it is silent in normal operation and speaks only
when an index is actually wrong, which is what a guard-rail should do.

THE SWEEP NOW KEEPS STDERR (virtualagc, oi340600-sweep.sh).  It used to go to a
mktemp deleted at the end of each module, which would have made this
measurement impossible -- and would have thrown away any traceback too.  It is
$OBJDIR/$m.err now.  The corpus is quiet there: 224 files, 224 lines, one
'Output obj:' status line each.

WHY.  The gate stays because it is load-bearing; what it lacked was a voice.  The
silent version of this failure cost five modules once already.

THE FLAT SYMBOL TABLE IS A STAND-IN FOR A MECHANISM lnk101 ALREADY HAS --
`--external-syms` against `--concard` -- and
that is the answer to 260's question of where the TFCMPFD1 fault lies.  It
lies in neither tool and it is not inherent in the archive either.

    THE TABLE CANNOT DISTINGUISH TWO THINGS THAT LOOK ALIKE:

        a ZCON in a loaded module pointing at code in an overlay that is NOT
        loaded now -- which must resolve, to the address that code has in the
        configuration where the overlay IS loaded; fcmcmp.py's
        `load_not_in_config` docstring is where that is written down

        a reference to a symbol no module in this build defines -- which must
        NOT resolve, because the original linker had no definition either and
        left the field 0000

    A name-to-address map has one address per name and no notion of who owns
    it, so it answers both the same way.  That is the whole of the defect and
    it is a property of the substitution, not of lnk101's code.

lnk101 HAS THE MACHINERY THAT TELLS THEM APART.  Not a proposal -- it is in
the options and in linker.py today:

    --concard DIR         CON80 deck directory, placing csects from its
                          BANK / OVERLAY / INSERT layout
    --concard-root NAME   default OFTMP
    --map-lib N=PHASE0N.lib   earlier-phase load modules for MAP cards
    --autocall FILE       modules pulled by automatic library call, exempt
                          from later-phase deferral
    --link-order FILE     ZCON pool and autocall wave orderings
    --Wunresolved-phases  per symbol left for CROSS-PHASE RESOLUTION

    linker.py speaks of symbols "left for cross-phase resolution" and of
    "phaseresolve patches them against the earlier phase's lib".  A mechanism
    that knows which PHASE owns a csect can defer a reference into an unloaded
    overlay and leave a genuinely undefined one alone.  The flat table cannot,
    because it has thrown that structure away.

AND THE DATA IS IN THE ARCHIVE.  ~/workspace/PFS/OI340600/CON80 holds 194
decks, 91 of them carrying BANK, OVERLAY or INSERT cards, including the OFTMP
root that --concard-root defaults to.  Its header is the configuration-control
history of the real link:

    *@ PCR=51777; OI0502  GNC2 DUAL PHASE
    *@ PCR=58631; OI7C10  RESTRUCTURE ALL LINKEDIT CONCARDS
    *@ CR=089926; OI8F02 AND OI2001 INCREASE ADDRMAX TO 128K

    So the principled path is to drive lnk101 from the decks rather than from
    the flat table.  That is a HARNESS change and a large one, and it is
    likely to subsume 253's alternate-configuration problem as well -- the 19
    objects excluded there are exactly what deferral and autocall exemption
    exist to decide.

WHAT IS VERIFIED AND WHAT IS NOT, because the difference matters before anyone
starts.  VERIFIED: the options above exist, linker.py implements cross-phase
resolution, the CON80 directory holds those decks, OFTMP is present and is the
documented default root.  NOT VERIFIED: that a CON80-driven G9 link runs
today, or how the deck names map to the configurations -- the ones in there
are G9DLCOM, GNC1, GNC1DISP, GNC1STUB, GNC2 and their kin, and which of those
is "G9" has not been established.

    DO NOT TREAT 260'S TWO HALFWORDS AS THE REASON TO DO THIS.  They are two
    halfwords and the flat table is otherwise serving well.  The reason to do
    it, if there is one, is that the phase structure is the thing the original
    build actually had, and every question of the form "why does the dump have
    something here that no link of ours produces" runs into its absence.

IT IS NOT A DROP-IN SWAP, AND IT CHANGES WHAT THE COMPARISON PROVES.  247
recorded that --external-syms "still pins each CSECT at the address the table
gives, so this is not yet a link that lays out memory by itself".  --concard
lays it out from the cards, so the test stops being "given these addresses, do
the bytes match" and becomes "does our layout reproduce theirs".  That is
strictly stronger where it matches and much harder to read where it does not,
and the first run should be expected to look worse.  The CSECT table does not
go away either:  fcmcmp --csect-table still wants it for annotation and for
the size check.

    NOR IS --external-syms LEGACY.  It is the SINGLE-MODULE mode, which is
    what 247 moved away from when it started linking whole configurations.
    It is the wrong tool for the mode we are now in, which is a different
    criticism from its being obsolete.

OI301700 NEEDS NONE OF THIS.  Its CON80 directory exists and is EMPTY, and
there are no memory dumps for it -- the eight DASS files are OI340600's, G2 G3
G8 G9 G16 P9 S2 and SSW.  With no dump there is no CSECT table, so nothing
pins anything and nothing needs to; verify-sweep does not link at all, it
compares the assembler's own output against contemporary listings.

WHY.  260 asked where the --external-syms fault lies and the answer is neither tool: lnk101 already has cross-phase resolution and the CON80 decks are in the archive.  Recording what is verified, what is not, and that --concard changes what the comparison proves keeps the next person from starting a large harness change on an assumption.

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

