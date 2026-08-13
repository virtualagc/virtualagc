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

WHAT IS OPEN.  Measured on 2026-08-12 with all six fixes above in the tree.

    NO ASSEMBLY FAILURES REMAIN IN SSW.  All 176 in-scope modules assemble --
    149 from SSSRC and 27 from RUNASM -- where 47 of them did not at the start
    of the day.  Six defects account for the difference and every one is
    described above.  THAT IS NOT THE SAME AS BEING RIGHT: assembling only
    means ASM101S had nothing to say, and the bytes are settled by the link and
    the comparison, which is where the open work now is.

    WHERE THE COMPARISON STANDS, SSW, all 176 modules, with the exceptions file
    and the literal-recovered image in use:

        PASS                                        51
        FAIL, links cleanly but halfwords differ    30
        FAIL via a forced link                      95

    ALL 27 RUNASM MODULES PASS, and every failure is in SSSRC.  That is worth
    keeping in view: the runtime library was finished in the previous phase and
    it still is, so a change that breaks one of those 27 is wrong.

    THE 30 THAT LINK CLEANLY AND STILL DIFFER ARE THE INFORMATIVE GROUP, and
    they are where to start.  The bookkeeping is already accounted for in them
    -- post-build patches via --exceptions, MAFGEN's own literal annotations via
    --memory -- so a difference there is ours.

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

