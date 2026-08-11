================================================================================
HANDOFF -- ASSEMBLING THE AP-101S SOURCES WITH ASM101S  (2026-08-08)
================================================================================
Written so a fresh session can start from this file alone.  The work is in
virtualagc/ASM101S/ and ~/workspace/PFS; open the conversation at the virtualagc
root, since the assembler and this handoff are in different subtrees.

*** THIS FILE IS GENERATED.  DO NOT EDIT IT BY HAND. ***  The source is
modules/sdfpkg/dass-handoff.db and modules/sdfpkg/dass-handoff.py is how it
changes -- `list`, `show`, `search`, `set ID`, `add --after=ID`, `check`.  It
resolves its own paths, so it runs from anywhere in the tree.  Every command
that changes an entry regenerates this file; a hand edit here is invisible to
the database and the next command silently overwrites it.

THE OTHER PHASES ARE IN modules/sdfpkg/HANDOFF.md, which is four times the size
and about different work -- the PASS corpus and the DASS comparison.  You should
not need it.  The one place they touch is that document's section 12, step 1.

THE GOAL.  Advance ASM101S until it assembles the entirety of our stock of
AP-101S assembly language, correctly.  This section is the starting line: what
the stock actually is, what already works, what does not, and where the first
work is.  It was written on 2026-08-08 with the measurements below taken that
day, so they can be re-run and compared rather than believed.

THE DECISION BEHIND IT, taken by the user on 2026-08-08.  There will be TWO
assemblers, ours (virtualagc/ASM101S) and Don Schmidt's (asm101, in
nsts-sdl-dps/src/asm101), and we will use whichever proves better.  This is
deliberate and is not a fork to be reconciled: there is room for two, and the
comparison is itself informative.  The user intends to discuss it with Don and
may revise it afterwards, so treat it as the current decision rather than a
settled one.

WHAT CHANGED TO PROMPT THAT, since the previous section still says the .asm
phase is "blocked on ASM101S changes under way elsewhere".  IT IS NOT BLOCKED,
and that description was wrong in a specific way worth recording so nobody waits
on it again.  Don is not making ASM101S changes.  His last commit to
virtualagc/ASM101S is 3734237af, 2026-04-29, and he has 11 there in total, all
between February and April 2026.  He has been active in virtualagc since --
XCOM-I and HAL/S-FC as recently as 2026-08-04 -- just not in ASM101S.  There was
never a held-back patch series to wait for.

WHAT DON'S asm101 IS, so the comparison is not made from scratch again.  It is a
declared derivative of ASM101S that has been rewritten.  Every file carries
attribution -- assemble.py names ASM101S.py with its GitHub URL, and
model101tables.py says outright that it was "significantly refactored for
asm101, most of the encoding moving to instrdefs.py/instrset.py which reads
instruction descriptors from instr_defs.json".  Provenance is not in question.

At the line level almost nothing is shared.  The two totals are nearly equal --
9814 lines for ASM101S against 9755 for asm101 -- and entirely redistributed:

    parser        tatsu (PEG)          lark, with an asm.lark grammar and an AST
    CLI           argparse             typer
    layout        flat modules         a package, relative imports
    encoding      in code              data, instr_defs.json, 1613 lines
    model101.py   2362 lines           3422 lines

On a crude sorted-unique-line comparison model101.py shares about 51 lines
against roughly 1875 and 2848 unique to each side.

WHY THERE IS NO PULL REQUEST TO WAIT FOR, and why this is structural rather than
reluctance.  asm101 imports ap101Utils -- addr, addrcon, objModule, codepages,
ibmhex -- a sibling package of 10286 lines in his repository, which also holds
sdf.py, halorder.py and cards.py.  asm101 cannot be lifted into virtualagc
without it.  His most recent assembler commit makes the point better than the
import list: 5638d2e touches ap101Utils/sdf.py, ap101Utils/halorder.py,
asm101/assemble.py and asm101/model101.py in ONE commit, to make the assembler
emit .asmg.json sidecars feeding SDF generation.  That is not an assembler
improvement, it is build-pipeline integration.  The assembler has become a
component of his system rather than a standalone tool, and "merge it back" would
mean importing his infrastructure or him un-picking the assembler from it.

WHAT IS WORTH TAKING FROM IT ANYWAY.  Not the rewrite -- a handful of citable
semantic findings buried in it, which port even though the patches do not:

  - 74fb403, a null &SYSLIST(k) coerces to zero in arithmetic context, citing
    GC26-3758-3 p.19 and SC26-4940 Table 58.  It ships with tests.  This is
    language semantics and applies to any correct AP-101 assembler.
  - d983348, Z(code,data,flags) names a second target: the linkage editor
    patches the data subfield's sector into HW1's DSR through a DSR-only RLD
    (0x40) at the ZCON's position.

Both are verifiable against the IBM manuals rather than against his code, which
is the only reason they are worth having.  d983348's implementation is written
in terms of his lark front-end and does not transfer.

ONE THING asm101 IS NOT: a drop-in replacement for our RTL work.  It contains no
&ASM101S at all and only two mentions of GBLB, so the conditional-assembly idiom
every one of our gated RTL fixes depends on is absent.  Do not assume adopting
it would be a shortcut.

THE STOCK, counted on 2026-08-08.  It is in TWO places, and the second is the
one that matters.

In virtualagc, under yaShuttle/Source Code/PASS.REL32V0/ -- the RUNTIME LIBRARY:

    RUNASM/     205 .asm    the AP-101S runtime library
    ZCONASM/    284 .asm    ZCON stubs, 48-56 bytes each
    RUNMAC/      20 .asm    the macro library for those
    RUNLST/     206 .txt    contemporary listings, the reference for RUNASM

In ~/workspace/PFS, per PASS version -- FCOS, THE FLIGHT SOFTWARE ITSELF:

    OI340600/SSSRC/    225 .asm    (also 134 .hal and 17 .dfg)
    OI301700/SSSRC/    272 .asm    (also 151 .hal)
    BFS.SRC/SSSRC/       1 .asm
    <VER>/MLIB80/      278 files   the macro library these need

ZCONASM is not the work it appears to be.  Every file is four lines of the same
shape and they are mechanically generated:

    #QACOS   CSECT
     DC Z(ACOS,,X'E')
     EXTRN ACOS
     END

There are no ZCON listings anywhere, so ZCONASM can be assembled but not checked
against a contemporary reference.  Treat those 284 as volume, not difficulty.

MONITOR.ASM/ (19 files) and SDFPKG.ASM/ (7) are NOT part of this.  They are .bal
-- IBM 360 Basic Assembler Language for the HAL/S-FC compiler itself -- a
different target and a different assembler.

THE .dfg FILES SIT IN SSSRC TOO, 17 of them in OI340600.  They are the other
phase, still blocked for want of a preprocessor; do not be surprised to meet
them here.

HOW TO MEASURE WHERE YOU ARE.  ASM101S/regressionASM101S.sh assembles all 205
RUNASM files and compares each against its RUNLST listing.  It takes minutes,
not hours, and is the loop to work in:

    cd ASM101S && ./regressionASM101S.sh              # our fixes ON, the default
    cd ASM101S && ./regressionASM101S.sh --no-rtl-fixes
    cd ASM101S && ./regressionASM101S.sh --copy       # keep each listing as .lst

It prints each module name, and prints the last line of the assembly only when
that line is NOT "0 bytes mismatched and 0 bytes missing".  So a run where every
name appears and nothing else does is a clean run, and any other text is a
finding.  Redirect through `sed 's/\x1b\[[0-9;]*m//g'` to strip its colours.

*** READ THE RESULT WITH --no-rtl-fixes IN MIND. ***  RUNLST is HISTORICAL, and
our RTL fixes deliberately depart from it.  They live behind &ASM101S gates in
the .asm sources, &ASM101S is true by default, and cb63663cd added
--no-rtl-fixes to force it false so a build can reproduce the historical image
including its bugs.  A file carrying a gated fix therefore MUST differ from its
listing on a default run.  Comparing the two runs is what separates "our fix"
from "our defect": --no-rtl-fixes measures the assembler alone, the default run
measures the assembler plus our intentional deviations.

A single file, which is how you will actually iterate:

    cd "yaShuttle/Source Code/PASS.REL32V0/RUNASM"
    ASM101S --library --tolerable=4 --compare=../RUNLST/NAME.txt NAME.asm

ASM101S is a two-line wrapper on $PATH at ASM101S/ASM101S and runs ASM101S.py.
--library loads the default macro library (RUNMAC); without it no macros are
loaded at all and nothing in RUNASM will assemble.  --tolerable=4 accepts MNOTE
severities up to 4, which the sources use for information messages.

To deploy a hand-assembled object into Don's build tree, which is a separate
matter and covered in the memory on &ASM101S-gated fixes, add --object=NAME.obj
and copy the result; do NOT run `make runtime` there expecting it to preserve
gated fixes, because asm101 does not implement them.

HOW TO ASSEMBLE FCOS, which is not the same command as the runtime library.  Run
it from the VERSION directory, not from SSSRC, and point --library at MLIB80
rather than the default RUNMAC:

    cd ~/workspace/PFS/OI340600
    ASM101S --library=MLIB80 --force-d SSSRC/FPMSWTCH.asm

*** --object= MUST END IN .obj. ***  ASM101S rejects any other name before it
assembles a line, and it says so in one line on stderr.  A sweep that hands it
mktemp names therefore fails on every module identically, with empty output and
a uniform exit status -- which looks exactly like a real measurement of a
thoroughly broken assembler.  That happened on 2026-08-08 and produced a
confident 497-of-497 failure table that meant nothing.  If a sweep reports every
module failing the same way, suspect the harness before the assembler.

USE --trace.  It was added for precisely this problem and prints each macro
invocation as it is entered, with its &SYSLIST, indented by nesting depth:

    Trace:  AMAIN []
    Trace:      WORKAREA []
    Trace:  INPUT ['F0']

That is how the root cause below was found, and it is the only practical way to
see what a nested expansion is actually receiving.

ASM101S WRITES NAME.obj BESIDE THE SOURCE WHETHER OR NOT --object IS GIVEN, so
every hand run of a module drops a file into somebody else's repository.  Eight
of them accumulated in ~/workspace/PFS/OI301700/SSSRC in one afternoon before
anybody noticed, and `git status` there is how they were noticed rather than
anything going wrong.

THE RULE: copy the module into a scratch directory and assemble it there.  The
library and the listing are given by absolute path, so nothing else needs to
move:

    cp "$PFS/OI301700/SSSRC/NAME.asm" "$SCRATCH" && cd "$SCRATCH"
    ASM101S --library="$PFS/OI301700/MLIB80" --tolerable=4 \
            --compare="$PFS/OI301700 as received/SSSRC/NAME" NAME.asm

--object=/dev/null DOES NOT WORK; ASM101S rejects any object filename that
does not end in .obj, which is worth knowing before reaching for it as the
obvious fix.  It was written into this entry as the rule and had to be
corrected an hour later.

verify-sweep.sh is not the problem -- it passes a `mktemp` path and deletes
it.  Ad-hoc runs are.  If some do get left behind,
`find OI301700/SSSRC -name '*.obj' -newermt YYYY-MM-DD` picks out the ones
from a given day without touching anything older that may be somebody else's.

WHY IT MATTERS MORE THAN IT LOOKS.  PFS is a git repository that is managed
elsewhere, and untracked droppings there are indistinguishable from work in
progress to whoever looks next.

2026-08-10.  FPMIHPC2 and FIOSVC are the only two modules whose OI301700
sources have lost cards.  Both end on an unnumbered `COPY` card -- blank in
columns 73-80 where every other card carries a sequence number -- and their
listings run on past it to an END:

    FIOSVC     236 cards, ends `COPY FIOSTEVT`   listing runs to statement  701
    FPMIHPC2  1380 cards, ends `COPY FIOSGEVT`   listing runs to statement 2284

TWO CHEAP TESTS FIND THEM, and they agree.  The first is which sources have no
END card at all:

    for f in *.asm; do cut -c1-71 "$f" | grep -qE '^ +END *$' || echo "$f"; done

Exactly two of 272 answer.  The second is the SRN comparison below, run over the
whole corpus, which flags the same two and nothing else above the noise.

THE DAMAGE IS NOT ONLY AT THE END, which an earlier version of this entry got
wrong.  FPMIHPC2 loses about 51 cards and FIOSVC about 33, scattered rather than
terminal -- FPMIHPC2 is missing `FPMSWTCC` invocations from the middle of the
module as well as its whole tail.

COMPARING BY SRN IS HOW TO SEE IT.  Card text cannot be aligned between a
listing and one of these sources, because the sources are PRE-EXPANDED: they
hold the generated cards and not the invocations that produced them.  Aligning
text with difflib silently matches unrelated cards and reported one tidy
contiguous gap that does not exist.  The sequence number in columns 73-78 is a
stable card identity and is what to compare.

    across all 272 modules, listing cards absent from the source:
        11091 total
         5889  macro invocations      -- absent BY DESIGN, pre-expansion
         2498  COPY member content    -- absent BY DESIGN, the COPY card remains
          103  everything else        -- of which FPMIHPC2 51, FIOSVC 33,
                                         BILDNEW5 11, and 1-2 each in seven
                                         others

CALIBRATE THE TEST AGAINST THE MODULES THAT MATCH.  A module whose bytes are
identical to the original build cannot be missing anything that matters, so any
"loss" it reports is a false positive and sets the noise floor.  Three of the
188 MATCH modules report exactly one card each, so ONE is the floor and only
FPMIHPC2, FIOSVC and BILDNEW5 stand above it.  BILDNEW5 is confounded: it is
the one module in the corpus that is NOT pre-expanded, so the classifier has no
expansion tags to learn its macros from.

THE COLUMN LAYOUT, because getting it wrong produced three confidently wrong
answers in a row.  Detect the carriage-control shift as readListing.py does --
try offsets 0 to 3, keep whichever yields the most lines matching
`[0-9A-F]{5} `.  Then the card image begins at column 36 and the SRN is at the
column where `\d{6}[A-Z0-9]{2}` most often appears, which is 108 for these
listings but should be MEASURED, not assumed.  DO NOT look for the statement
number at a fixed column: a card with two object-code fields pushes it right,
and a window at [28:35] skips those lines entirely -- 78 of them in FPMIHPC2,
whose source counterparts then look like additions.  The SRN column is the only
anchor in these listings that does not move.

WHAT IT COSTS FPMIHPC2.  Its missing tail contains
`GENERATE COPY=(TFPSA,TFPCT,TFTQE,TFPDE,TFGST,TFIOQ)`, whose expansion is the
DSECT maps.  So TFGST, TFPCT, TFICC and the rest are never defined, every
`USING TFGST,R2` fails, and the 146 diagnostics are almost all consequences of
that one absent card.  Do not go looking for a symbol resolution bug.

2026-08-10, measured rather than argued.  Appending an END card alone changes
NOTHING -- still 146 diagnostics -- because the DSECT maps are what is missing
and END cannot conjure them.  But the four cards the listing actually shows at
the end of the module, now that OI301700/MLIB80 HAS the macros, take it from
146 diagnostics to 22:

         GENERATE COPY=(TFPSA,TFPCT,TFTQE,TFPDE,TFGST,TFIOQ)
         TFIOS
         TFICC
    .END     ANOP
         END

ASM101S expands them into the DSECT maps itself, so nothing has to be spliced
out of the listing to define TFGST, TFPCT, TFICC and the rest.

ADDING THE DECLARATION CARDS takes 22 to 6.  Statements 1613-1833 of the
listing hold about fifty unmarked EQU, DC and EXTRN cards -- FPMSIPFL,
FPMSETDS, FPMTQERT, TMPINDIC, EXTRN CZ2VIF1 and so on -- and being unmarked
cards with no expansion behind them they splice in safely.

DROPPING THE TRAILING `COPY FIOSGEVT` takes 6 to 5, and the reason is worth
keeping.  A PRE-EXPANDED COPY MEMBER CAN ONLY BE INCLUDED ONCE.  The original
build copied FIOSGEVT twice and the macro counter gave each expansion its own
labels; our FIOSGEVT.asm holds one expansion with `#@LB1` frozen into it, so a
second inclusion is a duplicate definition.  The module's first inclusion is
already inlined in its own cards, so the surviving COPY card is the redundant
one.

THE LAST FIVE CANNOT BE FIXED THIS WAY.  They are `BAL R6,FPMACCM1`,
`BAL R5,FPMSWCM` and the like -- branches to three subroutines, FPMACCM1,
FPMSWCM and FIOICCCK, whose bodies are in the truncated tail at statements
1636-1719.  Splicing those 63 cards by the same rule makes matters WORSE, not
better:

    Severity 255  Unrecognized operation '&IIND1(0)'
    Severity 255  Index of &IIND4(0) out of range
    Severity 8    NEGATIVE INSTRUCTION STACK PTR. EXPANSION INVALID.
    Severity 8    IF MACRO AT SAME LEVEL AS DO TERMINATOR.

because those bodies contain IF, ELSE and DO, and PRINT NOGEN suppressed some
of their expansions.  The kept invocations then run against an instruction
stack that the inlined expansions never pushed.  Declarations can be spliced
from a listing; CONTROL STRUCTURES CANNOT.

SO IT IS LEFT UNAPPLIED.  Taking the module from 146 diagnostics to 5 does not
make it assemble, so it does not move the sweep, and it would put hand-built
cards into an archival source in exchange for nothing measurable.  If the three
subroutine bodies are ever recovered -- OI340600's FPMIHPC2 has them, though it
is a different release -- apply the whole thing at once and let the byte
comparison judge.  The candidate as far as it goes is reproducible from this
entry in about ten minutes.

FIOSVC IS THE SAME DEFECT AND FOUR TIMES SMALLER, 236 cards against 1380, and
is the better place to prove any of this out.

2026-08-10.  The corpus is at 209/3/32/27 MATCH/MATCH?/DIFFERS/NOCOMPARE, from
187/3/48/34 at the start of the day, with RUNASM at 205 of 205 throughout.

TWO DEFECTS ACCOUNTED FOR TWENTY-ONE OF THOSE, and both were structural rather
than matters of degree.  `DC A(expression)` never emitted its value at all, and
a USING-derived base register 3 was being mistaken for the sentinel meaning "no
base register".  Neither showed up as a plausible-looking wrong answer; one
emitted nothing and the other emitted a masked negative number.  Both are in
the commits that fixed them.

HOW TO WORK THE REST.  Rank the DIFFERS by bytes mismatched and take the
cheapest first, because the small ones are decodable by hand and the same root
cause usually explains a dozen modules.  Sort with

    awk -F'\t' '$3=="DIFFERS"{ m=$4; sub(/.*: /,"",m); split(m,a," ");
                               print a[1], $1 }' SWEEP.tsv | sort -n

and note that a module with ZERO mismatched and some missing is not a wrong
answer at all -- it is output that never happened, which is a different and
usually easier kind of bug.  Fourteen such modules led straight to the A
constant.

THE THREE LEADS THAT REMAIN, from decoding the cheapest cases:
[ALL THREE ARE NOW RESOLVED; kept because two of them show how the reasoning
 went wrong.  See the entry below for where the DIFFERS actually stand.]

  1. FLOATING-POINT ROUNDING.  FIXED.  toFloatIBM builds a 56-bit fraction and
     a short E constant keeps only its top 24 bits; dropping the rest truncated
     where the original rounds.  `DC E'0.015'` gave 3F3D70A3 for 3F3D70A4.

  2. AN OFF-BY-FIVE DISPLACEMENT THAT IS NOT UNDERSTOOD.  THIS DIAGNOSIS WAS
     WRONG.  It read FPMZSYNC's `9DF6 0041` as a two-byte SRS instruction whose
     six-bit displacement could not hold TICCXMTR's offset of 65, and built a
     puzzle on that.  It is a FOUR-byte RS instruction; its displacement 0x0041
     is correct in both builds; and the single wrong bit is 0b100, the AM=1
     marker.  COUNT THE BYTES IN THE OBJECT-CODE FIELD BEFORE THEORISING --
     two hexadecimal groups are four bytes, not two.

  3. FPMCANCL AND FPMTMHAL, missing bytes inside DSECTs.  FIXED, and it was the
     comparison at fault rather than the assembler: a listing prints the
     literal pool after the last DSECT with no CSECT card to close it, so
     readListing filed the pool's bytes under the dummy section.  The bytes
     were right all along.

AND THE ALGORITHM ITSELF MAY BE DUE FOR SIMPLIFICATION.  Ron notes that the
SRS/RS selection was devised empirically without knowing what USING was.  Half
the problem it solves is documented and already coded: GC28-6514-8 page 21
gives the base-and-displacement rule, smallest displacement and highest
register on a tie, and findB2D2 implements exactly that.  What is genuinely
undocumented for the AP-101S is only the choice of instruction FORM, and the
original assembler's habit of not always minimising it.  A rewrite that lets
USING decide base and displacement, and keeps empiricism for form alone, would
be a good deal smaller -- and lead 2 above may well dissolve in it.

2026-08-10.  217 of 272 byte-exact, from 187 that morning, RUNASM 205 of 205
throughout.  Twenty-four DIFFERS remain, ALL of them pure value disagreements:
not one has a missing byte any more.

WHAT FELL WAS ALL ONE SHAPE:  a generator that never wrote its value.
`DC A(expression)` emitted nothing at all; `DC B'...'` was a stub that emitted
nothing AND reserved no space; `DC Z(sym,...)` wrote zeros into its address
field; and the literal pool's bytes were written but filed under whichever
DSECT happened to be open.  Twelve, one, one and three modules.  The audit that
finds this class takes two minutes:  assemble one constant of each type the
grammar accepts and look at whether bytes appear.  DO IT AGAINST A NON-ZERO
TARGET -- the first attempt put the label at address 0, so A, Y and Z emitting
zeros looked correct.  S and V were checked and need nothing: neither appears
in either version and the grammar does not accept them.

A LABEL THAT MOVES NOW ASKS FOR ANOTHER PASS, which fixed the short-branch
cluster (FIOG9ADB, FIOPDHF, FPMEVENQ).  The check for it existed but was dead:
guarded by "preliminary" not being in the symbol table entry, and nothing ever
removed that flag.  Its response was also wrong -- a diagnostic rather than a
repeat -- which left every instruction already assembled on that pass pointing
at a stale address.  The pass loop is now bounded, which it was not.

THE LEAD THAT REMAINS IS THE AM BIT, and it is worth care because the obvious
fix is WRONG and was tried.

FPMIHIM, FPMZSYNC, FPMEVDEQ and others differ from the original by exactly one
bit, 0b100 in the second byte -- the AM=1 marker that `generateRS1` sets and
`generateRS0` does not.  `L R3,TPSAIMOP` assembles 1BF6 here and 1BF2 there.
THE DISPLACEMENT IS CORRECT IN EVERY ONE OF THESE; only the form differs.

The plain-RS branch requires `"B2" in ast`, so a base register that came from a
USING rather than from the operand text is treated as no base at all and the
operand falls through to the indexed form.  That is verbatim the misconception
behind the `ib2 == 3` bug fixed earlier the same day, so widening the test to
`("B2" in ast or usingB2)` looks obviously right.

IT IS NOT.  Measured: FPMZSYNC goes to byte-exact, and FPMIHIM goes from 2
wrong bytes to 56, FPMEVDEQ from 3 to 147, FPMDISP from 3 to 39.  A USING base
does not by itself imply AM=0; the original assembler is choosing on something
further that is not yet identified.  The change was reverted.  Whoever picks
this up should find the discriminator FIRST -- compare the AM=0 and AM=1 cases
across all of these modules and look for what separates them -- and not reach
for the one-line widening, which has already been tried and costs more than it
gains.

A CORRECTION TO THE PREVIOUS VERSION OF THIS ENTRY.  It described FPMZSYNC as
an off-by-one SRS displacement whose arithmetic was not understood, noting that
TICCXMTR's offset of 65 does not fit a six-bit field.  That was wrong, and
wrong in an avoidable way: `9DF6 0041` is a FOUR-byte RS instruction, not a
two-byte SRS one, its displacement 0x0041 is correct in both builds, and only
the AM bit differs.  A puzzle was built on a misread instruction length.  When
a listing line shows two hexadecimal groups, count the bytes before theorising.

2026-08-10.  223 of 272 byte-exact, from 187 that morning, with RUNASM at 205
of 205 throughout and NOCOMPARE down from 34 to 3.

    MATCH       223      MATCH?       3
    DIFFERS      43      NOCOMPARE    3

THE PATTERN THAT PAID BEST was asking, of each generator, whether it actually
writes a value -- not whether the value is right.  Four defects of that shape:
`DC A(expression)` emitted nothing, `DC B'...'` was a stub emitting nothing and
reserving nothing, `DC Z(sym,...)` left its address field zero, and the literal
pool's bytes were filed under whichever DSECT happened to be open.  Don Schmidt
found the first two independently in June and fixed them the same way; his
AS037F1_COMPARISON.md is worth reading before starting anything here.

THE SECOND PATTERN was the premature diagnostic:  a collecting-pass failure
treated as fatal when it only means "not resolved yet".  EIGHT sites now.  The
seventh was a whole class -- sixteen value-range checks testing numbers
computed from symbols that were not yet placed.  Find that kind mechanically:
assemble every failing module, keep each diagnostic with its pass number, and
report those whose highest pass is below 3, because a real error recurs on the
compile pass and a premature one does not.

THE EIGHTH DID NOT ANSWER TO THAT METHOD, and the reason is worth keeping.
`optimizeScratch` runs in one place only, at the end of pass 1, and the literal
pool it consults is built during that same pass; "Literal not in literal pool"
was therefore raised at severity 255 on a condition that is expected there.
Having no reachable pass but the collecting one, it looks exactly like a
genuine pass-1 error and always will.  The sweep cannot see it.  What exposed
it was removing the noise around it, and that is the transferable part: fix the
loud faults first and read what survives.

DCICYC IS DONE, and it was not three faults but one source defect and one
assembler defect.  Commit 5c35b774 commented out 374 cards where a macro
invocation survived beside its own expansion -- AND IT SWEPT SSSRC ONLY.  The
COPY members in MLIB80 were never looked at, which is exactly why this stayed
hidden: the bad cards are not in the module that fails, they are in what it
copies.  DCI#CON carried four ELSE/ENDIF invocations beside their expansions
(the assembler said NEGATIVE NEST STACK POINTER, CHECK NUMBER OF ENDS, which is
literally what an ELSE with no IF does), and DCI#FMT carried five uncommented
literal-pool dump cards.  226 diagnostics fell to 64, then to 34, then to none
that stop the assembly.  PFS 1092c9ea, ASM101S 2749ac816.

TWO THINGS THIS ENTRY USED TO SAY ARE WRONG, and were disproved by measurement:
the run that would not converge before pass 20, and the 36 "Could not evaluate
D2 subfield" that recurred through it, were NOT independent faults.  Both were
consequences of the corrupted macro nesting stack and both vanished with it.
And the literal-pool failure was not a pool-indexing bug -- the provisional
zero-valued slot changed nothing because it was fixing the wrong half.  Two
successive theories about this module were wrong before the third was right;
the thing that worked was comparing OI301700's copy against OI340600's
unexpanded one, which is what showed the expansions were the anomaly.

THE THREE THAT REMAIN are not assembler defects.  FIOSVC and FPMIHPC2 have
TRUNCATED SOURCES; see the entry above for how far each can be taken and what
it costs.  BILDNEW5 is oversized -- 7932 intolerable lines -- and Don reports he
can build it, so his git log is the place to start.

THE REGRESSION HARNESS READS AS A FAILURE AND IS NOT.  `regressionASM101S.sh`
with no arguments reports six mismatches -- CINDEX, MM14SN, MM6SN, MV6SN,
VV6S3, VX6S3 -- and reports them at every commit, before any change as well as
after.  The RUNASM sources carry &ASM101S-gated corrections and the listings
predate them.  Pass `--no-rtl-fixes` and all 205 are byte-exact.  That flag is
the measurement, not an option; a bare run has been mistaken for a regression
here at least twice.

AND THE MEASUREMENT HAS A BLIND SPOT worth stating plainly:  the sweep compares
assembled bytes against listings, so anything that does not alter a listed byte
is invisible to it.  A missing RLD entry hid behind a green result today.  When
a fix touches the object module, measure the object module -- and note that it
is EBCDIC, so a card-type test against ASCII b'RLD' reports zero of everything.

2026-08-10, later the same day.  243 of 272 byte-exact, from 223, with no
module moving the other way at any point and RUNASM at 205 of 205 throughout.

    MATCH       243      MATCH?       3
    DIFFERS      23      NOCOMPARE    3

Twenty modules gained and DCICYC moved from NOCOMPARE to DIFFERS.  Six defects,
all in the addressing logic, the constant generators or the literal pool, and
every one found the same way: sort the DIFFERS by mismatched-byte count, take
the smallest, and print each "Comparison mismatch" beside the statement it was
raised on.  Modules with one to four bad bytes are single-instruction defects
and they CLUSTER -- eight of the first nine shared one bit.

  THE AM BIT, nine modules.  RS AM=1 exists to supply an index register, a
  negative displacement, or `@`/`#` addressing, and the test that chose it had a
  fourth clause asking for none of those: any displacement that fit eleven bits.
  A symbol already resolved through a USING to a real base register took the
  indexed form anyway.  Guarded with `not usingB2`.  2cf2e3615.

  BCT MISSING FROM THE BACKWARD-BRANCH LIST, five modules.  BC, BIX and BAL
  reached the negative form and BCT did not.  `*+2` goes with it: the original
  writes a zero displacement as the negative form too, so the test is
  `d1 <= 0`.  a1012c56a.

  LA DISCARDING ITS BASE REGISTER, two modules.  An `LA`-only branch tests
  `d2 > -2048 and d2 < 2048`, but by then `d2` has been REPLACED by the offset
  from the base register findB2D2 supplied, so a USING-relative symbol matches
  and the branch then addresses it PC-relative instead.  3a091286d.

  DC F MULTIPLYING BY THE FIELD WIDTH, one module.  Scale a value only when it
  IS a fraction, which is what the literal path always did.  3a091286d.

  LITERAL POOL ALIGNMENT, two modules.  A pool begins on a fullword whatever it
  holds; the alignment was derived from the contents and seeded at 2.
  e84380552.

  NOTHING ADVANCED THE LOCATION COUNTER OVER A POOL, one module and much of
  DCICYC.  `LTORG` aligned and did not advance, so whatever followed a pool was
  assembled on top of it.  Invisible in 242 of 272 because their LTORG is the
  last thing occupying space.  DCICYC fell from 4479 mismatched bytes to 1983.
  9446fdc5f.

THREE OF THE SIX WERE WRONG ON THE FIRST TRY and a harness caught all three.
"Unscaled F means integer" broke CTOI, ETOC, ITOC and KTOC, which write
`DC F'0.625'` and expect 50000000 -- magnitude decides, not the presence of an
S.  Moving `used` with `pos1` at an LTORG broke eight RUNASM modules, because
the between-passes bookkeeping adds `pool[4]` back for a TRAILING pool and that
then counts twice.  And the AM-bit fix had been tried once before and reverted,
because it was written into `forceAM0`, which suppresses AM=1 even where an
index register requires it.

RUN BOTH HARNESSES ON ANYTHING THAT TOUCHES THE ENCODER OR THE POOL.  The
corpus sweep alone would have passed the F-constant error, because no OI301700
module writes a fractional F constant and four RUNASM modules do; the RUNASM
run alone would have passed nothing that matters in FIOLGERR.  And
`regressionASM101S.sh` NEEDS `--no-rtl-fixes` -- without it six modules mismatch
at every commit and it reads as a regression.

AND INSTRUMENT RATHER THAN READ when the base-register logic is involved.  Two
careful readings said `findB2D2` was failing to match DCICYC's `USING
CDDLOCAL,R1`; one print at its call site showed it returning b2=1 and the right
offset, with the fault three hundred lines away in a branch that had looked
irrelevant.  That chain has too many arms to follow by eye.

WHAT IS LEFT, by size:

    DCI#DATA 2   FIOMDPPG 6   FCMBOOT 9   FCMCBLKS 12  FPMSDERR 12
    then a gap to FIOCGR 43 and seventeen more up to MENU12 1128 and
    DCICYC 1983.

  DCICYC's remaining 1983 are ONE defect repeated: the SRS/RS choice.  Its
  layout matches the original byte for byte as far as 00637, where
  `BC 07-1,#@LB260` is assembled as the two-byte SRS `DEDC` and the original
  emits the four-byte RS `C6F7 0037`.  Both reach their own target and the
  module is self-consistent either way; only one matches.  Two bytes are lost
  there and two more at the third LTORG, and every later address is short by
  four.  Whatever rule the original used to keep the long form here it did NOT
  use six halfwords later at 0063A, where it emits the short `DED4` for the same
  mnemonic -- so it is not simply "forward references get the long form".  That
  is the question to answer, and it is worth answering because it is the last
  thing between DCICYC and a match.

  FIOMDPPG's six bytes are an ORIGINAL-BUILD ANOMALY, not our defect, and were
  left alone deliberately.  `#LBR@ FIOBRE-2` with FIOBRE an EXTRN assembles to
  FA000002 in the original -- the MAGNITUDE of the -2 -- where we emit FA00FFFE,
  the two's complement, which is what a linker adding the symbol's address would
  need.  The POO gives the field as an 18-bit unsigned address, in which a
  negative constant cannot be represented at all.  The corpus has exactly two
  negative cases, both in this module and both -2, against dozens of positive
  ones in FIOPDIPG which already match.  Two samples is not enough to write a
  rule from, and "emit the absolute value" is a guess.

DCICYC'S LAST DEFECT, characterised but NOT fixed, because the fix is global
and I was working unattended.  Read this before touching `optimizeScratch`.

The module is byte-exact against the listing as far as 00637.  There:

    original   00637  C6F7 0037   BC 07-1,#@LB260    four bytes, RS
    ours       00637  DEDC        BC 07-1,#@LB260    two bytes, SRS

and six halfwords later, for the same mnemonic, BOTH emit the short form:

    original   0063A  DED4        BC 07-1,#@LB262
    ours       00639  DED4        BC 07-1,#@LB262

Two bytes are lost there, two more at the third LTORG, and every address after
is short by four.  That single choice is the whole of the remaining 1983.

WHAT IT IS NOT.  Not the displacement limit: `srsCeiling` is 56 and both fit
under it, ours at 55 and the second at 53.  Not "forward references keep the
long form", because #@LB260 and #@LB262 sit at the SAME address, 00670, and are
both forward from their branches -- the original shortens the second.  Not the
macro, because both are generated by IFPROC and the generated card is textually
identical; the difference is the assembler's alone.  Each encoding is a
self-consistent fixed point: shorten it and the label lands at 0066F, which a
55-halfword SRS reaches; leave it long and the label lands at 00670.  Both are
correct assemblies.  Only one is the one that was built.

WHAT IT PROBABLY IS.  A classic two-pass assembler settles every length on pass
1, with each ambiguous instruction ASSUMED LONG, and never revisits.  Under
that assumption the pass-1 distance from 00637 is inflated past 55 by whatever
lies between it and 00670 that later shrinks, so it stays long; 0063A's, three
halfwords nearer, still fits and goes short.  `optimizeScratch` instead iterates
to a fixed point and shortens both.

WHY I DID NOT ACT ON IT.  Making the choice once, from long-form addresses,
changes the length decision for every ambiguous instruction in all 272 modules,
243 of which are byte-exact under the present behaviour.  That is a change to
measure carefully with someone watching, not to land on a hypothesis at the end
of an unattended run.  The cheap first experiment is to confirm the mechanism
before changing anything: instrument `optimizeScratch` to log, for every
instruction it shortens, the displacement it would have had under pass-1
long-form addresses, and check that in DCICYC the 00637 branch exceeds 55 there
and the 0063A branch does not.  If that holds, the rule is confirmed and worth
implementing; if it does not, the hypothesis is dead and nothing was risked.

THE EXPERIMENT PROPOSED IN THE ENTRY ABOVE WAS RUN, and it kills the
"decide once from long-form addresses" hypothesis while replacing it with
something sharper.  Instrumenting the forward-branch arm of `optimizeScratch`
to print its decision for DCICYC's two branches gives:

    run 1   #@LB260  pos1/2=606  value=64D  d=70  keep long
    run 1   #@LB262  pos1/2=609  value=64C  d=66  keep long
    run 2   #@LB260  pos1/2=605  value=636  d=48  SHORTEN
    run 2   #@LB262  pos1/2=607  value=635  d=45  SHORTEN

Deciding once, on the first look, would leave BOTH long.  Iterating to a fixed
point, which is what we do, shortens BOTH.  The original does neither: it keeps
#@LB260 long and shortens #@LB262.

WHY THE ORIGINAL'S ANSWER IS THE SELF-CONSISTENT ONE, and this is the useful
part.  In the original's converged layout #@LB260 and #@LB262 both sit at 00670.
Shortening the branch at 00637 would put its SRS displacement at
0x670 - 0x638 = 56, and `srsCeiling` is 56 exclusive, so it does NOT fit and the
long form is forced.  The branch at 0063A gets 0x670 - 0x63B = 53, which fits.
Each decision is correct GIVEN the layout it produces.

Ours is equally self-consistent and equally correct as an assembly: shortening
the first branch pulls the labels back to 0066F, whereupon its displacement is
55 and does fit.  TWO FIXED POINTS EXIST and the question is only which one the
original build settled on -- the conservative one, reached from above.

So the rule to look for is not "when is the decision made" but "which direction
is it approached from".  A shortening that is only valid BECAUSE it was taken is
the thing to refuse; the original refuses it and we accept it.

AND NOTE, unrelated but found on the way:  `optimizeScratch` is invoked as

    for sect in sects:
        optimizeScratch()

and the function takes no argument and does not use `sect`.  It therefore runs
once per control section over the whole source, which is why the trace above has
two runs with different answers.  Whether that repetition is deliberate -- a
crude way of iterating toward convergence -- or accidental is not established,
but the number of iterations is currently the number of CSECTs and DSECTs in the
module, which cannot be what anyone intended.  Anything done about the fixed
point should settle this first, because the iteration count is the mechanism.

Nothing was changed.  The instrumentation was removed and the tree is clean at
this entry; 243 of 272 stands.

DID THE ORIGINAL ASSEMBLER LEAVE ITSELF A MARGIN?  Asked because it is the
natural engineering choice -- given a two-byte form that might just barely
reach and a four-byte form guaranteed to, and a case that arises rarely, take
the four-byte form -- and because it would have dissolved the fixed-point
problem entirely: refuse the marginal shortenings and the shortcut that makes
itself legal is never taken.

MEASURED, AND THE ANSWER IS NO.  `optimizeScratch` was instrumented to log the
displacement of every shortening it accepts, all 272 modules were assembled,
and the 2951 shortenings that occur inside the 243 BYTE-EXACT modules were
separated out.  Those are shortenings the ORIGINAL assembler necessarily took
too, since the object code agrees with its listing.  By decision arm:

    forward branch    n=1452   max 55
    backward branch   n=155    max 54
    absolute D2       n=369    max 48
    via USING         n=975    max 4

The forward arm reaches 55, which is the largest value the six-bit field can
hold with `srsCeiling` at 56.  Four separate byte-exact modules do it --
FCMBCEMD, FCMNINIT, FIOERRLC and FPMOPSCN -- and FCMSFAIL shortens at 54.  So
the original used the full range and left no margin at all, and any threshold
below 56 breaks at least five modules that match today.

WHAT THIS RULES OUT, which is the value of it.  A whole class of candidate
fixes is now dead: there is no "shorten only if d < 54" or similar to be tuned,
and the DCICYC branch at line 646 is not being refused for being close to the
limit.  Our 55 there is legal by exactly the rule the original applied
elsewhere.

WHAT IT LEAVES.  The difference must be the layout the decision is taken
against, not the threshold applied to it.  In the original's layout the target
sits at 00670 and the short form would need 56, which does not fit, so the long
form is forced; in ours the target sits at 0066F and 55 fits.  Neither
assembler is applying a different rule -- they are applying the same rule to
different intermediate layouts, and the layouts differ only because of this
instruction.  So the question really is which fixed point the iteration lands
on, and the `for sect in sects: optimizeScratch()` iteration count noted in the
entry above is the mechanism that decides it.  Settle that first.

The instrumentation was removed; nothing in the assembler changed and 243 of
272 stands.

Item 6 of the list above -- "VERIFY, WHICH IS STILL THE REAL GAP" -- is open,
2026-08-09.  modules/sdfpkg/verify-sweep.sh assembles every OI301700 module
and compares it against its own contemporary listing.  Read that script's
header before running it; the setup matters more than the script does.

    MATCH        127        bytes identical to the original build
    NOCOMPARE    126        never reached a comparison
    DIFFERS       19
    CRASH          0

THE DENOMINATOR IS 262, NOT 272 AND NOT 133.  213 of the 214 macros
OI340600 defines are absent from OI301700's library, but only SIXTEEN of them
are ever invoked, by TEN modules:

                   buildable    blocked by the archive
        MATCH            127                         0
        DIFFERS           19                         0
        NOCOMPARE        116                        10

So 127 of 262, and the actionable remainder is 135 modules.

IT WAS FIRST REPORTED AS 102 OF 133, WHICH WAS WRONG, and the mistake is more
useful than the number.  "Which modules invoke a missing macro" was measured
by taking the second word of every line, which counts COMMENT CARDS -- and
these sources carry long comment blocks spelling out the very macro syntax
being searched for.  FPMIDLE has a block listing "WAIT UNTIL", "SCHEDULE AT",
"REPEAT AFTER" and the rest, not one line of it code, and it was scored as
needing four missing macros.  That inflated the blocked set from 10 modules to
139 and shrank the denominator from 262 to 133, which made the assembler look
about nine times better than it is.  MEASURE OPERATION FIELDS ONLY: skip cards
beginning with `*` or `.*`, and skip the card after any card with a non-blank
column 72, which is a continuation and has no operation field.

That is the third measurement of this kind to go wrong here in one day -- the
others being R0-R7 counted in RUNASM comments and MACRO statements sought with
an end-of-line anchor.  When counting anything in these sources, decide first
which COLUMNS carry the thing being counted.

THE VESTIGIAL INVOCATIONS ARE COMMENTED OUT, 2026-08-09, 374 cards across the
ten modules, in ~/workspace/PFS (uncommitted there; a patch is in this
session's scratchpad).  Each was verified to be followed by its own expansion
before being touched, none was a continuation, and none had anything in column
71, so a '*' went in column 1 and columns 72-80 were left alone.  PCH10SRC
went straight to 0 mismatched and 0 missing.  The score is 128 of 272.

Do not expect the other nine to follow.  Commenting the invocations only
cleared the noise; underneath, FCMBOOT has 14 intolerable lines, FIOERRLC 10,
FIOPDISP 7, FPMRES 3, FPMMTURM 2, FPMREL 6, FPMUPMTU 21, FPMIHPC2 148 and
MENU12 726.  Those are real work.

COLUMN 72 IS THE CONTINUATION COLUMN AFTER ALL, and the reasoning that said
otherwise is worth reading as a warning.  It looked like a revision flag: of
OI301700's 382 marked cards, 350 do not even reach column 71, 378 are complete
statements, and none is followed by anything resembling a continuation.  Every
one of those observations is true and the conclusion drawn from them was
wrong.

The OI340600 "as received" directory holds genuine CARD DECKS rather than
listings, and there the question answers itself: 688 marked cards, 688 of them
followed by a continuation card, no exceptions, across every marker -- X, *,
+, D and C alike.  OI340600's PREPARED sources keep all 688 too.  OI301700's
prepared sources keep 18 of 382.  THE EXTRACTION DROPPED 364 CONTINUATION
CARDS, which is why the markers there point at nothing and why they looked
like flags.

THEY ARE RESTORED, PFS commit 705e56e4: 425 cards covering 349 of the 364.
221 were matched in the module's own OI340600 deck on card text AND the
sequence number in columns 73-80; 122 in the OI340600 macro member named by
the card's own 'nn-MACRO' identifier, on text; 6 in that member on the LABEL,
for cards whose text differs from the model because a macro variable was
substituted.  Some statements need more than one continuation card, hence 425
for 349.

The 15 not restored are all in FCMPSA, all from TFPSA, and nothing exists to
restore -- those model cards have a BLANK column 72, so the macro never
emitted a continuation.  Whatever put an 'X' in column 72 of the generated
card, it was not the macro.

THE BINARIES CONFIRMED IT.  128 matches to 134, every transition forward, and
NO module lost a byte-exact match -- which is the check that mattered, since a
wrongly chosen card would have turned a match into a difference.

TWO MORE ARTIFACTS OF THE SAME FAMILY were then found and cleared, PFS commit
80c5489a, taking the score to 145.  After an LTORG the listing prints the pool
it generated, and 35 of those entries were captured as source cards -- `=Z(..)`
and `=X'..'`, recognisable by a BLANK sequence field in columns 73-80, which no
real card has; DCICYC alone held 23.  And FCMPSA's 15 leftover column-72 marks,
the ones with no continuation to restore, were cleared: their TFPSA model cards
have a blank column 72 so the macro never emitted one, and the listing prints
TPSAPWR and TPSATENT as consecutive statements 39 and 40, so the original
assembler consumed nothing there either.

A WARNING ABOUT ONE TEST THAT DOES NOT WORK.  It is tempting to ask whether the
listing's STATEMENT NUMBERS jump across a card, on the theory that a consumed
continuation would take a number.  IT DOES NOT.  Continuation cards are neither
printed nor numbered; a gap means something else was unprinted, usually a
SPACE.  That test was run here and confidently declared 128 correct
restorations wrong, and then 126 more, before the flaw was spotted.  The only
instrument that settles a restoration is the byte comparison.

FOUR CARDS LOST ACTUAL OPERAND TEXT and are recovered, PFS commit ec601001:
FCMINSSL 1073/1075/1077 `AL.15(FCMMZE` -> `AL.15(FCMMZERO)`, and FIOMGDSP 1041
`AL.4(FIOM` -> `AL.4(FIOMWBLC)`.  Both were confirmed verbatim afterwards
against OI340600's card decks, which still hold the continuation cards `RO)`
and `WBLC)`.

THE MISSING MACROS DO NOT NEED BORROWING, AND MUST NOT BE.  Not for the
reason first given here, which was wrong: "of the 40 members in both versions,
zero are identical" is a fact about the members OI301700 HAS, and those are
never the ones anybody would borrow.  It was no evidence at all about the ones
it lacks, which have no counterpart to differ from.

The real reason is better.  THE PREPARED OI301700 SOURCES ARE ALREADY
MACRO-EXPANDED.  Whoever built them kept the generated cards -- the ones the
listing marks with `+` after the statement number -- so the .asm holds the
expansion as ordinary source.  DFLDCU's listing has 51 generated cards, all 51
appear verbatim in its .asm, and it matches byte for byte.  That is why the
library has almost no macros in it: nothing needs them.

Where an invocation ALSO survived, it sits beside its own expansion, and
supplying the macro would expand it a SECOND time.  PCH10SRC proves both
halves in four lines: given OI340600's `IS` it fails outright, and with `IS`
simply undefined and the leftover card ignored it is 0 bytes mismatched and 0
bytes missing.

So the open question is not which macros to fetch.  It is what ASM101S should
do with a vestigial invocation of an undefined macro, which today is an
intolerable error.  Sixteen macros are invoked this way -- DCHAR, XPOS, YPOS,
CASE, VR, LVC, IF, PROGRAM, ELSE, EXIT, IS, ENDPROC, EXECUTE, DO, ENDDO, PROC
-- across ten modules: FCMBOOT, FIOERRLC, FIOPDISP, FPMIHPC2, FPMMTURM,
FPMREL, FPMRES, FPMUPMTU, MENU12, PCH10SRC.

Do not expect the other nine to fall out as PCH10SRC did.  Tolerating
everything and comparing anyway gives them hundreds or thousands of mismatched
bytes, so they have real faults underneath, and three of them reach fresh
crashes that way -- KeyError 'using' in FPMIHPC2 and FPMREL, KeyError
'FPMUGTQE' in FPMUPMTU, KeyError '#CYCNT' in MENU12.  Those are worth having
whatever is decided about the invocations.

TWO MEASUREMENT TRAPS, both of which produced confident wrong answers here
within an hour of each other.

Judging "is this member a macro definition" with a regexp anchored at
end-of-line finds NOTHING.  The cards carry sequence numbers in columns 73-80,
so a MACRO statement never ends its line.  CUT TO COLUMNS 1-71 FIRST.  Believed
for a while, and written into a commit message, that neither library contained
a single macro; OI340600 has 214.

And listing OI301700's one real macro member in MACROFILES.txt turned 127
matches into 272 failures.  MACSMITH is a symbolic-equates member with a macro
block inside it, nothing invokes it, and pre-reading it gives every module 153
intolerable lines.  A uniform result across a whole corpus means the harness is
broken -- that rule paid for itself twice in one afternoon.

WHAT THE COMPARISON FOUND that the OK/ERRORS sweep never could.  Every one of
these was invisible to a sweep that only asks whether ASM101S complains:

  - DC ignored its duplication factor for HEXADECIMAL constants, and only for
    those.  `DC 594X'C6C6'` generated one halfword instead of 594.  Sixteen
    patch-space modules are a single such statement and were each short by
    1186 bytes, silently.  Beside it, the odd-digit rounding was `count % 1`,
    zero for every integer there is.
  - The 1024-byte DC buffer was treated as a language limit rather than a
    working area.  It grows now.
  - Nine modules died on KeyError from three places that assume a symbol is in
    the table, including readListing, which sets the current section from a
    DSECT without creating its entry.  Two TypeErrors surfaced behind them.
  - IUACOMMAND in the long BCE format was WRONG for years.  See the ASM101S
    commit and ap101s-notes.db; the short version is that the instance offered
    as proof was never evaluated, and LOOKING THE SYMBOL UP disproves it.

`DS A` LABELS KEPT A PLACEHOLDER VALUE, which was worth more than it looked.

The preliminary symbol pass gives every labelled statement a provisional value
of four bytes times its position in the section, and `commonProcessing` is
what later replaces that with the real one.  The A-type branch called
commonProcessing for `DC A` and for anything with a length modifier, and for
`DS A` called it NEITHER way -- so every `DS A` label kept the placeholder for
good.  TCVTIOQ came out as 220, being the 56th label in TFCVT, where it
belongs at 78.  The listing printed it at 0x4E throughout; only the symbol
table was wrong.

What that cost was invisible until traced.  Instructions referring to such a
symbol got a displacement out of range of the short form and were assembled
LONG, which shifts every address after them.  `ST R0,TCVTIOQ` came out as
30F5 00DC where the original build has 309D, and that one extra halfword put
FCMNINIT 544 bytes out.  With the value right it is 309D, byte for byte, and
FCMNINIT falls to 57.  `DS A` was also missing the fullword alignment an
A-type constant is due.

AND THE SRS/RS MACHINERY WAS INNOCENT.  The short form's displacement is
scaled by the operand size -- fullword instructions count fullwords, halfword
instructions halfwords, so a symbol 78 halfwords in is displacement 39 to a
`ST` and 78 to a `STH` -- and ASM101S implements that correctly.  It only
looked broken because it was being handed a wrong symbol value.  An earlier
version of this entry said the rule was unimplemented and the FIXME in
model101.py should be replaced by it; that was wrong on both counts.  BEFORE
TOUCHING THAT ALGORITHM, check whether the symbol values reaching it are
right.

THE DIFFERS MODULES ARE DOWN TO 136 WRONG BYTES, from 1488, on six fixes.  In
order of what they were worth:

  - `DS A` labels kept a preliminary placeholder value, because the A-type
    branch called commonProcessing for `DC A` and for a length modifier and
    for `DS A` neither way.  FCMNINIT 544 -> 57.
  - A forward `BC` has a short form and only the backward one was written.
    The two-bit field carries direction as well as kind -- BCF 00, BVCF 01,
    BCB 10, BCTB 11 -- so there is a short forward BC but no short forward
    BCT.  FIOPDHF 542 -> 22.
  - Label positions were recorded only on the COLLECTING passes, while
    instruction lengths go on settling through the compile passes.  A label
    after an instruction that grew kept its earlier position.  FCMNINIT
    57 -> 7.
  - A parenthesised register with no active USING, on a relocatable symbol, is
    an INDEX rather than a base, and an indexed operand has no short form.
    ASM101S had this as `b2 > 3`, which misses the low registers.  FPMEVENQ
    28 -> 5.
  - `BC` took its displacement from `currentHash()` where the alias path uses
    the statement's own pos1.  FIOPDHF 22 -> 2.
  - The literal pool was placed at a stale address, over the top of two
    constants.  FCMNINIT's pool 001CA -> 001D2.

What is left is 27 modules and 136 bytes: FPMSDERR 17, FIOMS4DT 16, FIOMS2DT
16, FCMBCEMD 11, FIOCDATS 10, FCMNINIT 7, FIOMDPPG 6, then a tail of fives and
fours.  FIOMS4DT and FIOMS2DT being equal is a hint they share a cause.

THE METHOD IS WORTH REUSING, and is most of why these went quickly.  Assemble
with --compare, align our listing against the "as received" one on statement
text, and watch where the ADDRESS DELTA changes: that names the single
instruction whose LENGTH is wrong, and everything after it is consequence
rather than cause.  Fix that one and the module often collapses from hundreds
of wrong bytes to a handful.  Once the delta is flat the rest is pure
encoding, and `whichbytes.py` in this session's scratchpad pairs each
"Comparison mismatch" with the statement it belongs to.

AND THE ARBITER IS ALWAYS THE SWEEP.  Three of the six are heuristics about
ambiguous syntax that mimic the original assembler rather than follow from
anything, and the original did not always choose the shorter form.  For each,
the evidence that it is right is that RUNASM stays 205 of 205 byte-exact, no
module lost a match, and the corpus total fell.  Do not accept such a change
on one module's improvement alone.

WHERE TO GO NEXT, in order.

  1. THE 8 BUILDABLE DIFFERS.  Several are one to three bytes.  FPMIDLE is a
     single byte: `LH R3,TTQEFLGS` under `USING TFTQE,R3` assembles to 9BD7
     where the listing has 9B17, and ASM101S emits a second address field
     FFF5 where the listing has none.  IT IS DECODED ALREADY:  generateSRS
     builds byte 1 as `(d2 << 2) | b2`, so 0x17 is displacement 5 with base
     register 3 and 0xD7 is displacement 53 with base register 3.  THE BASE
     REGISTER IS RIGHT AND ONLY THE DISPLACEMENT IS WRONG, 53 against 5, with
     the symbol itself resolved correctly -- both runs print adr1 as 0005.  So
     look at the USING/DSECT displacement arithmetic, not at symbol
     resolution and not at base-register selection.  One defect probably
     accounts for most of the eight.  A one-byte difference in a whole module
     is the cheapest bug report this project will ever get; do not waste it.
  2. THE 23 BUILDABLE NOCOMPARE.  Rank their diagnostics FIRST -- the leaders
     over a 40-module sample were "Undefined symbol", "Could not parse
     operands", "Cannot evaluate the expression" and "Could not evaluate
     duplication factor", but that sample was dominated by modules that are
     unbuildable anyway, so re-rank over the buildable 23 alone.
  3. LITERALS.  `=X'...'`, `=F'...'`, `=Y(...)` and `=Z(...)` appear as
     "Unrecognized operation", and "Literal not in literal pool" appears 27
     times.  ASM101S seems to be feeding its own literal-pool lines back
     through the parser.  Unexamined.
  4. PERFORMANCE, which now costs real time: the sweep is over an hour, and
     several modules take two minutes each.  Note that ASM101S reads the
     ENTIRE macro library as open code before every module, 278 members for
     OI340600, which is a large part of it.

2026-08-10.  Three things in the entry above are now wrong, and each was wrong
in a way worth keeping.

THE ARCHIVE GAP DOES NOT EXIST.  DCHAR, XPOS, ENDIF and ELSE are all in
OI340600/MLIB80.  They were not missing from the archive; verify-sweep.sh was
withholding them, on the stated grounds that an invocation surviving beside
its own expansion would expand twice.  That was true when it was written and
stopped being true at 5c35b774, which commented out all 374 such cards --
PCH10SRC's `IS`, the case the old note cites, among them.  The denominator is
272, not 262.

COPYING MEMBERS INTO THE LIBRARY DOES NOTHING BY ITSELF.  `readMacroLibrary`
opens only what MACROFILES.txt names, so the first attempt at borrowing
changed not one module in the whole corpus.

DO NOT HAND-ROLL MACROFILES.txt.  ASM101S/makeMACROFILES.py maintains it and
is meant to be re-run whenever a library gains members.  Its rule -- a member
qualifies only if it defines macros AND has no code outside them -- is the one
that matters.  Two hand-written approximations were tried here and both
admitted a member whose open code does something.  The second, MACROS.asm,
took the corpus to 272 of 272 NOCOMPARE; the rule in CLAUDE.md about uniform
results across a corpus earned its place again.  The tool also classifies none
of OI301700's own 40 members as definitions, MACSMITH included, so it needs no
special case to reproduce the empty index it replaced.

THE LIBRARY IS NO LONGER READ AHEAD OF THE MODULE.  Item 4 of the old "where
to go next" called that a performance problem.  It is a CORRECTNESS problem:

  - Sequence symbols are file-level.  A pre-read member's `.END` or `.FIOMTU`
    is visible to the module's own open code.  FIOPDISP has no COPY statement
    and invokes no library macro, and its `AGO .FIOMTU` -- target on the very
    next card -- still began failing as "Target out of this macro".  asm101
    has the same scar: a leaked `.END` made FPMIHPC2's open-code `AGO .END`
    resolve into the wrong file and no-op, so its deferred block re-ran until
    ACTR tripped.  FPMIHPC2 is NOCOMPARE here too, and that is where to look.
  - A member's open code runs.  MACROS.asm is a COPY member -- a TITLE, 51
    open-code PDEF invocations, one MACRO/MEND -- and reading it defined P1
    through P51 ahead of every module.  Moving those PDEFs into a macro is NOT
    the fix: OI340600's MENU12 does `COPY MACROS` and needs them as open code,
    and they would then be defined twice over.

Members are now fetched when named, OS/360 SYSLIB style, member name = macro
name, each with its own sequence-symbol namespace, misses cached.
MACROFILES.txt keeps its meaning and now says which members are ELIGIBLE
rather than which are pre-read.  `preReadLibraries` in ASM101S.py restores the
old behaviour.  Load BEFORE the name field is registered, not at expansion:
the block that declines to register the name of a macro invocation asks
whether the operation is a known macro, so loading later made `ASIN AENTRY
...` register ASIN and then expand a macro defining it.

WHERE THE CORPUS STANDS, 2026-08-10:

    MATCH        188        bytes identical to the original build
    MATCH?         3
    DIFFERS       53
    NOCOMPARE     27
    HANG           1        BILDNEW5, over 1800s

RUNASM stays 205 of 205 byte-exact under --no-rtl-fixes throughout.

WHAT FELL THIS ROUND, all measured the same way.  The six undocumented branch
aliases the listings name -- BZR, BNZR, BNER, BHR, BOV, BOC -- read off their
object code, there being no AP-101S manual; a sweep for mnemonics carrying
object code that appear in no table now returns nothing.  The blank-named
DSECT.  Negative bit-length constants.  EQU's three-operand form, which GIVES
a symbol its L' and T' -- that is how PDEF builds position symbols.  L'
itself, which is GC28-6514-8's definition rebased on halfwords because the
AP-101S is halfword-addressed.  And `=Y(...)`, which had never worked in four
independent ways at once, the last being that the literal pool identified an
entry by its whole attribute dictionary, value included -- fine while every
literal is absolute, wrong for the first relocatable type the grammar admits.

NEXT.  DCICYC still reports "Literal not in literal pool"; FPMIHPC2 is the
sequence-symbol case named above; and item 1 of the old list, FPMIDLE's single
wrong displacement, is untouched and still the cheapest bug report here.

THE MACRO-PROCESSING ROOT CAUSE IS FIXED, issue #1331, in commit 0f5ab2939 on
2026-08-08.  The issue itself is worth reading anyway -- it is the user's own
analysis plus two outside contributors, and it is where the semantics below are
justified from the manuals.  What follows is what the fix established, so that
nobody re-derives it.

A MACRO ARGUMENT IS A CHARACTER STRING, except where the source wrapped it in
parentheses, in which case it is a SUBLIST passed through verbatim and
subscriptable to any depth:

    RON 1,(10,(100,200,300),30),3

    &SYSLIST(2)      (10,(100,200,300),30)     the source text, parens and all
    &SYSLIST(2,2)    (100,200,300)
    &SYSLIST(2,2,3)  300
    &SYSLIST(2,9)    null                      past the end is not an error
    &SYSLIST(1,1)    1                         a non-sublist is a sublist of one

ASM101S flattened one level and never recursed, so the second operand arrived as
the unusable (10,((,(100,((,,200),(,,300))),)),30), and &SYSLIST(n,m) did not
exist at all.  MLIB80 uses multilevel subscripts heavily -- 16 of &SYSLIST(&I,2)
alone, and &SYSLIST(&I,2,&J) at three levels -- which is why most of FCOS could
not assemble.  RUNMAC uses NONE of it, which is why RUNASM's 205 of 205 never
noticed.

MULTILEVEL SUBLISTS ARE PERIOD-CORRECT and not an AP-101S invention.  They are
an Assembler H feature, GC26-3758-3 (January 1974) p.13; the Assembler F manual
of 1967 describes a different assembler and has nothing to say about them, which
is why looking there came up empty.  The same rules survive as Tables 48 and 49
of the HLASM Language Reference, SC26-4940.

COUNTING.  N' is the number of entries, and an omitted entry still counts, so
N'(A,,C) and N'(A,B,) are both 3.  N'() is 1, the null string being its single
entry, and N' of a non-sublist is 1.  K' is the width of the argument's text.

ARITHMETIC CONTEXT HAS EXACTLY THREE CASES, GC26-3758-3 p.19 and SC26-4940
Table 58: null is zero, a valid self-defining term is its value, and anything
else -- a sublist, a symbol -- is a program error to DIAGNOSE.  It is not
coerced.  The old TypeError at expressions.py:521 was reporting a real defect
upstream of itself; making that comparison succeed would have converted a loud
failure into a wrong assembly, and the fix went upstream instead.

COLLATION was already right and is worth not re-opening: character relations
compare in EBCDIC, and of two values of unequal length the shorter is always the
lesser (SC26-4940 p.388).  macroTests/sublists.asm pins both down with two
comparisons that invert under ASCII.

A SEPARATE DEFECT WAS FIXED IN THE SAME COMMIT because the first fix made it
reachable.  A SETA/SETB/SETC whose operand carried a trailing comment --

    &MSGCNT  SETA  &MSGCNT+1        ARRAY INDEX=INDEX+1

-- failed to parse, and svSet then returned WITHOUT ASSIGNING, so the variable
silently kept its old value.  In MACSMITH's RTURNTBL that left the loop bound
&STOP at zero while &A counted up from 1, and the assembly never terminated.
These operands now end at the first blank outside a quoted string, as the
instruction grammars already did.  This is the shape to watch for: a silently
skipped assignment shows up much later as a non-terminating loop.

THE OTHER OPEN ISSUE IS #1333, a feature request for the ORG pseudo-op, from an
outside user assembling compiler-generated code.  It also carries a second,
separable defect: "ST#1 EQU *" crashes with KeyError None at model101.py:1237.
The remaining ASM101S issues -- 1317, 1320, 1324 through 1329, 1332, 1271 -- are
all CLOSED and are useful mainly as worked examples of how such a defect gets
pinned down.

WHY ASSEMBLIES USED TO RUN FOR EVER, fixed 2026-08-08 in commit 91af304f0.
Three separate things, none of them a macro-argument defect; they only became
reachable once issue #1331's fix let modules run far enough to meet them.

ACTR IS NOW IMPLEMENTED.  It had been listed in `pseudoOps` and never acted on.
It is the assembler's own guard against a runaway AIF/AGO loop and the sources
rely on it -- five files in OI340600's MLIB80 set it explicitly, ENDCASE with
`ACTR 30000`.  The counter is decremented on every AIF or AGO branch ACTUALLY
TAKEN, so a false AIF does not count; it defaults to 4096 when no ACTR appears;
and when it goes negative the expansion is abandoned with a diagnostic naming
the macro.  Each macro expansion needs its own counter, which falls out of
`readSourceFile` recursing once per expansion, so a plain local is right.

A BLANK AFTER '(' OR BEFORE ')' MADE AN AIF UNPARSABLE.  Blanks must be allowed
inside the parentheses, since AND, OR and NOT are written surrounded by them,
and the grammar allowed them everywhere except those two positions.  The
consequence was out of all proportion to the cause: a failed AIF parse is
reported and then execution CONTINUES WITHOUT BRANCHING, so an AIF that is a
loop's only exit makes the assembly run for ever.  BTBCEGEN's

    AIF   ( &ELE  EQ 15).BT106

is why FIOMVUPG, FIOMS2PG and FIOMS4PG never terminated; they now finish in
under ten seconds.  Measured across MLIB80 and RUNMAC, 79 of 2486 AIF operands
failed to parse before the fix and 26 after.  The remainder are two features
that are genuinely absent rather than mis-parsed: created variable symbols,
`&(SRC&UPDDSN&NAME)`, and the T' and D' attributes applied to a SUBSCRIPTED
variable, as in `T'&SYSLIST(1,2)` and `D'&SYSLIST(&I,3)`.  Both are worth
having; neither is hard now that multilevel subscripts exist.

THE `ASM101S` WRAPPER DID NOT `exec`, and this one is a measurement hazard
rather than an assembler defect.  The wrapper was `ASM101S.py "\$@"`, leaving
the shell as the parent, so its PID was what `timeout` and `kill` saw.  They
killed the wrapper and left the assembler itself running, orphaned.  A sweep
would therefore record a module as HANG while it quietly went on consuming a
core, and the orphans accumulated across runs -- twenty-one of them at one
point on the day, which is how it was noticed.  The wrapper now `exec`s.  If
you ever see a sweep's timeouts "working" while the load average says
otherwise, check this first.

A COMMENT LINE THAT REACHES COLUMN 72 SWALLOWS THE STATEMENT BELOW IT.  This is
correct assembler behaviour -- column 72 is the continuation column and it
applies to comment statements too -- but it is invisible in an editor that does
not rule at 72, and it produces no diagnostic whatever.  The statement simply
does not appear in the listing, generates nothing, and the location counter
does not advance.

IT WAS BRIEFLY WRITTEN UP HERE AS AN ASM101S DEFECT, in MACRO/MEND block
tracking, on the strength of a hand-written test file whose header comments ran
to 74 columns and therefore ate the `MACRO` statement that followed them.  There
is no such defect and that item has been removed.  The same cause later ate a
`DC F'-1'` from the middle of a constants test.  Recorded because it wasted an
afternoon twice, in two different disguises.

    *  a comment reaching column 72 ...........................  X
    B7       DC    F'-1'          <- swallowed, silently

ASM101S/macroTests/regressionMacros.sh now fails any test source with a comment
line past column 71, so at least the test corpus cannot fall into it again.  A
STATEMENT line may of course reach column 72; that is how a real continuation
is written, and macroTests/sublists.asm has one.

WHAT IS ACTUALLY WORTH FIXING HERE is small: when a continued comment runs off
the end of the source, ASM101S dies with AttributeError on a None operand rather
than reporting an unterminated continuation.  That is the only genuine defect in
the area.

THE BASELINE, measured 2026-08-09.  It has two halves and they are nothing alike.

THE RUNTIME LIBRARY IS FINISHED.  ASM101S assembles all of it, and RUNASM is
verified rather than merely error-free:

    RUNASM    205 of 205   assemble AND match their contemporary listings byte
                           for byte under --no-rtl-fixes: "0 bytes mismatched
                           and 0 bytes missing", every module
    ZCONASM   284 of 284   assemble.  No listings exist, so this is the weaker
                           claim of the two

On a default run exactly six RUNASM files fail, and those six are precisely the
six containing &ASM101S -- CINDEX, MM14SN, MM6SN, MV6SN, VV6S3 and VX6S3.  Their
gated fixes change the generated code and the historical listing does not have
it, so the comparison must fail.  None of that is an assembler defect.  Establish
that set with `grep -l ASM101S RUNASM/*.asm`, not from memory: a first pass on
the day recalled five of them and wrote CINDEX up as an unexplained sixth.

RUNASM IS A WEAK GUARD ON MOST OF WHAT MATTERS NOW, which is easy to mistake for
a strong one.  RUNMAC uses no multilevel sublists and no ACTR at all, it
never exercises the numeric branch of T', and RUNASM contains no DC duplication
factor, no multi-valued DC, no length modifier and no `DC C'...'` anywhere.
Assembly-time division returned a Python float for years without moving the
score, character constants generated nothing whatever, a branch to an
unmatched sequence symbol silently discarded the rest of a file, and a boolean
expression of more than two terms could not be evaluated at all.  Ten separate
things have now been found broken while it stayed at 205 of 205.  Treat that
score as necessary and nowhere near sufficient.  Run
ASM101S/macroTests/regressionMacros.sh as well; it takes seconds and it is the
only check that covers the conditional-assembly language itself.

FCOS IS WHERE THE WORK IS.  Of OI340600's 225 modules, assembled against MLIB80,
before this stretch of work began and now:

                    before   after
    OK                  21      64
    ERRORS              33     143
    CRASH              170      16
    HANG                 1       2

THE OK COLUMN IS NOW HONEST, WHICH COST IT SIX.  It stood at 70 until the MSC
instructions were made to admit that they are not encoded; six modules using
them dropped to ERRORS, having contained wrong object code all along.  Read a
fall in OK for that reason as the column becoming truthful rather than the
assembler getting worse.

NOTHING HANGS, and CRASH has fallen by more than nine tenths.  Read the ERRORS column as
the real measure of progress: a module there has been assembled far enough to
produce a diagnosis, which is what the next defect gets found from.  The four
crash families that dominated -- 92 of `TypeError: NoneType is not iterable`,
42 of `KeyError: 'ast'`, 23 of `IndexError: bytearray index out of range` and
14 of a float reaching a bitwise AND -- are gone outright.  What is left is a
long tail, and no single item in it is now worth calling the next job:

      7  KeyError: 'preliminaryOffset'                model101.py:1287
      2  KeyError: None                               model101.py:1287
      1  TypeError: int() with explicit base           model101.py:1524
      1  KeyError: 'ICCLGTH'
      1  KeyError: 'FCMBMVLT'
      1  AttributeError: Buffer has no attribute _pos (inside tatsu)

DO NOT CLASSIFY A LOOP BY WATCHING &SYSNDX.  This was asserted earlier and it is
WRONG, so it is recorded here to stop it being re-derived.  &SYSNDX advances only
when a new macro is INVOKED, so a long AIF/AGO loop inside a single expansion
shows a frozen &SYSNDX with the trace still scrolling -- identical to an infinite
loop.  FIOPDISP was called LOOPING on exactly that evidence and in fact
terminates in 307s.  The reliable discriminator is ACTR: it fires on a genuinely
unbounded loop and stays silent on a merely slow one.

OI301700 COULD NOT BE MEASURED AT ALL, and the reason is not the assembler.  Its
MLIB80 holds 41 files against OI340600's 278, and NOT ONE of them is a macro
definition -- every core macro the sources use, PROGRAM, IF, DO, PROC, EQUATE,
IFPROC among 237 others, is simply absent.  It also has no MACROFILES.txt, so
ASM101S stops immediately with "Cannot open ../MLIB80/MACROFILES.txt".  The user
confirmed that OI301700 needs files borrowed from OI340600 and that this has
never yet been done.  Until it is, every OI301700 number is vacuous.

DO NOT "FIX" THIS BY GENERATING MACROFILES.txt THERE.  It was tried.
makeMACROFILES.py runs happily and produces an index naming ZERO macro files,
because there are none to name, and ASM101S then loads no macros at all and
buries you in errors instead of stopping with one clear message.  Borrow the
macros first.

THERE IS A SECOND SOURCE FOR OI301700, pointed out by the user on 2026-08-08:
~/workspace/PFS/"OI301700 as received"/ holds the FCOS assembly-language files
as assembly LISTINGS, showing the assembled form rather than the source as such.
That is original-build primary evidence, so it is the reference to check a
borrowed macro library against, in the same way RUNLST is the reference for
RUNASM.  It has not been used yet.

THE SWEEP'S CLASSIFICATION IS THE WRONG INSTRUMENT NOW, and this is the single
most useful thing to understand about the state of the work.  fcos-sweep.sh
sorts modules by exit status, which was right while most of the corpus was
crashing.  It cannot see a module that assembles two hundred lines wrongly and
says nothing, and it cannot tell a module with two diagnostics from one with
three hundred.

USE modules/sdfpkg/fcos-diagnostics.sh AND .py.  The first collects every
diagnostic over the corpus, one file per module; the second counts them.

    ./fcos-diagnostics.sh DIR OI340600      # ~40 minutes, FCOS_TIMEOUT=900
    ./fcos-diagnostics.py DIR --top=20
    ./fcos-diagnostics.py DIR --message=TEXT   # drill into one finding

COUNT BY BREADTH, NOT BY VOLUME.  Breadth is how many modules produce a
message; volume is total occurrences.  They point in completely different
directions and breadth is the one that matters, because a severity-255 message
appearing twice in each of forty modules FAILS FORTY MODULES, while ten
thousand occurrences of one message in one module fails one.  The first bulk
read had "Could not evaluate length modifier" at 2758 occurrences from 10
modules and "In LCLx, is not a symbolic variable" at 77 from 42; the second was
worth an order of magnitude more and volume ordering buries it.  The tool
prints both, breadth first, deliberately.

WHAT THE FIRST READ FOUND, on 2026-08-09, in one pass:

  - Continuation cards were not being joined at all except for macro
    prototypes and invocations, so a declaration continued onto a second card
    silently lost every variable on that card.  Fixing it moved 26 modules
    straight from ERRORS to OK -- the largest single gain of the whole effort,
    and invisible to the sweep because the modules had been failing on two
    diagnostics apiece.
  - COPY and EJECT were leaking into the code generator, 2332 diagnostics in
    five modules alone.
  - "Unrecognized line", the commonest message in the corpus at 16720
    occurrences across 166 modules, did not say WHAT it had failed to
    recognise.  Naming the operation resolved the entire family in one run.

THE LESSON WORTH KEEPING is that a diagnostic which does not identify its
subject is nearly worthless in bulk, and that fixing the message is often the
cheapest way to find the defect.  "Unrecognized line" hid 35 distinct causes;
"Eval error type 3", still the top of the list at 62 modules, is the same
problem and should probably be given the same treatment before anyone tries to
fix what it is reporting.

NEXT STEPS, in order.  Everything above item 1 in the previous list is done:
the runaway loops, the continued-macro-invocation defect behind them, and the
EXTRN-with-displacement defect.  Counts below were re-measured after the first
two; the EXTRN fix landed afterwards and will have moved them again, so
RE-MEASURE BEFORE CHOOSING.

  1. RE-READ THE DIAGNOSTICS FIRST.  Total occurrences at severity 8 or above
     fell from 33739 to 9372 over the last two fixes, and the EXTRN fix then
     took OK from 57 to 70 without being measured for diagnostics at all.  The
     ordering has been redrawn by every single round so far, twice by defects
     that were invisible until something else was fixed.  Use
     modules/sdfpkg/fcos-diagnostics.sh and .py with --min-severity=8, and
     SPLIT ANY LARGE FAMILY BY MODULE before believing its size.

  2. ENCODE THE '@' MSC INSTRUCTIONS.  They no longer fail silently -- that
     was done on 2026-08-09 and cost the OK column six modules that had been
     wrong all along -- but they are still not encoded, and 40-odd modules
     cannot be correct until they are.  Everything needed is in
     ASM101S/ap101s-notes.db under "MSC instruction set": 47 of the 61 appear
     in the original build with their real encodings, in three regular groups,
     with the branch mapping already matched against the POO's condition-code
     table.  The 14 with no observed encoding will need the POO.  Verify each
     one against the listings as the BCE long forms were, which matched byte
     for byte.

  3. THE TWO-BYTE BCE INSTRUCTIONS, 40 modules and 2845 occurrences, which is
     ASM101S saying honestly that it does not know their encoding.  Needs the
     POO, the listings being dominated by zero operands.

  4. "Cannot parse macro-invocation operands" (33 modules) and "Could not parse
     operands" (31).  Both name nothing.  Give them the operand they choked on
     before trying to guess the defect; that has been the cheapest way in four
     times running.

  5. BORROW OI301700'S MACRO LIBRARY FROM OI340600, ~237 files, then sweep it.
     Unexplored; the two versions are years apart, so diff a few macros that
     exist in both before assuming the rest can be copied wholesale.

  6. VERIFY, WHICH IS STILL THE REAL GAP.  70 modules exit 0, which means the
     assembler did not complain, not that the bytes are right.  The "as
     received" listings are the evidence and --compare needs to learn about
     their carriage-control column before it can be pointed at them.  Every
     encoding derived from those listings so far has matched byte for byte,
     so the method works; nobody has yet applied it to a whole module.

  7. THE CRASHES, 16 of them, led by KeyError 'preliminaryOffset'.  Several
     are latent faults newly reached as modules get further, which has
     happened after almost every fix this week; expect a couple more each
     time.

  8. ASM101S IS SLOW.  A sweep or a diagnostics run is the better part of an
     hour, dominated by re-parsing every line through tatsu on every pass.

  9. THE SMALLER, SEPARABLE ONES.  ORG is unimplemented and is issue #1333,
     which the user has asked to have incorporated; it also carries a
     KeyError-None crash on "ST#1 EQU *".  DC cannot parse a hex literal with
     comma-separated groups.  ASM101S.py raises IndexError when generated code
     runs past the end of a --compare listing.  Created variable symbols,
     `&(SRC&UPDDSN&NAME)`, are the last AIF operands that do not parse.  A bit
     length modifier that is not a whole number of bytes is diagnosed rather
     than implemented, and accounts for 1758 occurrences in 3 modules.  And
     #CNOP's padding instruction is still unknown.

Item 2 of the list above is done for the short forms, 2026-08-09.  Three
formats, 31 of the 61 mnemonics, in ASM101S/model101tables.py as mscMemory,
mscBranch and mscImmediate:

  memory reference   OP(4) M(1) DISP(11)   @L 4 @A 5 @N 6 @X 7 @ST 8 @TSZ 9
  branch             OP(4)=0010 M(1) CC(3) DISP(8)
  immediate          OP(8) VALUE(8)        @LI EF @LXI EB @TXI EA and six more

Both PC-relative forms count in HALFWORDS from the UPDATED PC, the halfword
after the instruction.  M is the index-mode flag and is 1 exactly when the
operand carries an index, `@L TSTMASK(1)`; it is also the only thing that
separates @BXNN (0x2D) from @BNN (0x25).

THE BRANCH FORMAT IS DOCUMENTED and the earlier note that it was not is wrong.
The POO's @BC and @BXC pages, manual II-38 and II-39, give the layout, say the
displacement is added to the updated MSC program counter, and tabulate all
eight condition codes against both the accumulator and the index mnemonics.
Beware the opposite error too: the POO's "Short format 1 ... OP M DISP"
passage is in its BCE section and does NOT describe the MSC memory references,
which are in no manual and were read off the original build.

HOW IT WAS VERIFIED, which is the part worth copying.  Every MSC instruction
in ~/workspace/PFS/"OI301700 as received"/SSSRC whose operand symbol is
defined in the same listing was re-encoded from scratch -- displacement
recomputed from that listing's own label addresses -- and compared against the
listing's object code.  318 instructions, 21 mnemonics, ZERO mismatches.  That
is the standard for the rest, and it is cheap: the listings carry both the
symbol definitions and the answer.

WHAT IS DELIBERATELY LEFT UNENCODED, and why it must stay that way.  The long
forms F0 to FD.  @DLY, @INT, @RAW and @STP, whose HIGH BYTE VARIES (@DLY
C0/C8, @INT 30/38/3B, @RAW D0/D8, @STP 10/12), so byte 0 carries a modifier
the simple split does not explain.  And @LMS @NIX @RBI @RFD @SFD @SIO @TAX
@XAX @WAT, which appear only ever with a ZERO operand -- their high byte is
constant but a zero operand fits any layout, so the evidence does not
constrain the boundary.  All of these still announce themselves.  A wrong
halfword that assembles quietly is worse than four zero bytes and an error.

THREE MNEMONICS ASM101S DID NOT KNOW turned up on the way, all in argsMSC.
@BP was simply absent.  @BXC and @CALL were lost to a MISSING COMMA -- the
table read "@BXC" "@CALL": -1, which Python concatenates into the single
nonexistent key @BXC@CALL, so two real mnemonics vanished and an impossible
one stood in for them.  Worth grepping the other tables for the same shape.

MEASUREMENTS.  RUNASM stays 205 of 205 byte-exact under --no-rtl-fixes.  The
FCOS sweep is UNMOVED at OK 64 / ERRORS 143 / CRASH 16 / HANG 2, and that is
the expected result rather than a disappointment: what changed is the
correctness of the bytes, which the sweep does not measure.  118 of the 284
MSC uses in the OI340600 sources now assemble instead of diagnosing; the
remainder are led by @LBP 37, @LF 17, @BU 15, @STH 12, @STF 10, all long
forms, so the long forms are where the next MSC effort pays.

A TIMEOUT TRAP, since it cost a wrong reading here.  At FCOS_TIMEOUT=120 the
sweep reported CRASH 14 / HANG 6, and the six were the MSC-heavy modules,
which looks exactly like a new runaway loop.  It was not.  FIOCMPLT takes 113
seconds and ends in the known KeyError 'preliminaryOffset'.  Modules that now
generate code take longer than modules that bailed out early, so a fix that
makes progress can manufacture HANGs out of nothing.  Re-run at 600 before
believing a HANG, and note that a sweep run concurrently with the regression
inflates every time on the machine.

THE "AS RECEIVED" LISTINGS ARE THE PRIMARY EVIDENCE FCOS HAS BEEN LACKING.
~/workspace/PFS/"OI301700 as received"/SSSRC holds, for each module, a listing
that gives the OBJECT CODE THE ORIGINAL BUILD GENERATED for every statement,
before relocation by the linker.  That is to FCOS what RUNLST is to RUNASM,
and until 2026-08-09 nobody had used it.  The format is

    00C14 C7F2 0000      0000      6526 STM1392  BC$   7,0(R2)   comment

    address    object code    resolved effective address    line number

with the address and the effective address in halfwords.

IT ALREADY PAID FOR ITSELF.  The '$'-suffixed mnemonics -- LA$, B$, BC$, L$,
ST$ and nine more -- appear nowhere in the AP-101S POO and had been written up
here as unidentified.  Comparing their assembled binaries against ASM101S's
output for the same instruction settled what they are in a few minutes: '$'
forces the LONG (RS) form of an instruction that would otherwise be assembled
short.  Twelve forms now match the original build byte for byte, including a
negative displacement (LH$ -> 9FF3 FFF5) and BAL$ -> E7F2 0000.

TO USE IT WITH --compare THERE IS ONE OBSTACLE, pointed out by the user.
These listings carry an ANSI CARRIAGE-CONTROL CHARACTER IN COLUMN 1 and RUNLST
does not, so every field is one column further right than --compare expects.
Measured on BILDNEW5: column 1 is blank on 31937 lines and '1' -- page eject --
on 550, and the content begins in column 2.  RUNLST has no such column; its
text begins in column 1.  So --compare needs to know which convention a
listing follows.  Do not "fix" it by stripping the first character of every
line unconditionally, because that would corrupt RUNLST; detect it, or give
--compare an option.

WHY THIS MATTERS MORE THAN THE OK COLUMN.  A module that exits 0 has been
assembled without complaint, which is not the same as assembled correctly --
and the '@'-family instructions assembling to four zero bytes proves the
difference is real.  Comparing against these listings is the only thing that
turns "assembles" into "verified", which is what the phase goal actually asks
for.  It also covers OI301700 rather than OI340600, so it bears directly on
the item about borrowing that version's macro library.

