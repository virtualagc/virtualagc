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

THE ITERATION COUNT IS FIXED, and it changed nothing.  `optimizeScratch` now
runs until a pass shortens nothing rather than once per control section.
Measured three ways: once gives 242 and breaks DMOD and DSNCS; once per
control section gives 243; to a fixed point gives 243 with no module changing
a single byte.  So the repetition was load-bearing but its count was arbitrary,
and the count is now a property of the algorithm.  8964ece53.

WHICH LEAVES A MUCH MORE USEFUL CONCLUSION, arrived at from the observation
that a deterministic scheme ought to exist.  It does, and it is not directional:
start with EVERY ambiguous branch short and repeatedly lengthen only those that
do not fit.  Lengthening pushes targets further apart and never brings them
closer, so a branch forced long never becomes short again; the iteration is
monotonic, terminates, and reaches a UNIQUE least fixed point whatever order it
visits things in.  That is the minimum-size layout.

We do the opposite -- start long, shrink -- which is order-dependent and can
stop at any of several fixed points.

AND THAT IS THE POINT: at DCICYC line 646 OUR code is SMALLER than the original
build's, and ours is a valid assembly.  If the original had been minimizing,
no smaller valid layout could exist, and one demonstrably does.  THE ORIGINAL
BUILD WAS NOT MINIMIZING CODE SIZE.

So the goal is not a better minimizer.  Every instinct to improve the
optimization is pointed the wrong way; what is wanted is to reproduce a
procedure that stopped short of the minimum, and to find where it stopped.
Note also that "shorten only when the shortening is not self-justifying" -- when
the short form fits ONLY because taking it pulled the target closer -- describes
the difference at line 646 exactly, and is a rule about the ORDER of approach
rather than a threshold.  It is the next thing to try, and it is cheap: refuse a
shortening whose displacement is within the amount that shortening itself
removes, and measure.  It is expected to cost some of the 55s measured in the
entry above, which is precisely what the sweep will show.

THE CHEAP SOURCE SWEEP IS CLEAN.  The two detectors that found DCICYC's defects
-- a macro invocation whose operation names the macro stamped into the next
card's columns 73-80, and a card whose operation field begins with '=' -- were
run over every .asm in OI301700, OI340600 and BFS.SRC.  Zero vestigial
invocations anywhere; the ten literal-pool hits are all `.*` macro-comment
cards reading "=8 (FULLWORD, = 4 (HALFWORD)" and the detector should exclude
that form.  MLIB80 was the last of the residue.

AND A CORRECTION TO THE ENTRY ABOVE.  "The original left no margin, forward
displacements reach 55" measured the wrong quantity: the displacement
`optimizeScratch` sees when it DECIDES, which is not the displacement finally
encoded.  DCICYC's line 646 decides on 48 and encodes 55.

MEASURED PROPERLY, off the as-received listings and depending on nothing in our
assembler -- a two-byte encoding of a branch mnemonic is the SRS form and its
displacement is byte1 >> 2 -- across 803 such encodings in the 243 byte-exact
modules:

    45:3  46:2  47:2  49:2  50:2  51:1  52:1  53:1  54:0  55:0

THE ORIGINAL NEVER ENCODED 54 OR 55.  The margin is real.  The tail is thin, so
the two zeroes are suggestive rather than conclusive on their own, but they
agree with DCICYC, where the original refuses the short form and our layout
encodes exactly 55.

IMPLEMENTING IT AS A DECISION THRESHOLD DOES NOT WORK, and this is the useful
negative.  `srsCeiling = 54` leaves the corpus at 243 with no module changing
classification, breaks DMOD in RUNASM, and makes DCICYC WORSE -- 1983 mismatched
bytes to 4756.  The reason is the same one that invalidated the first
measurement: the number the decision tests is not the number that gets encoded,
so tightening the test refuses shortenings that were correct while still
permitting the one that is wrong.

WHY THEY DIFFER, which is where the next attempt should start.
`optimizeScratch` runs at the END OF PASS 1 and nowhere else, and the positions
in `scratch` were recorded DURING pass 1.  The advance over a literal pool
happens only on the compile passes -- it is in the `elif` arm of the LTORG
handler, deliberately, see 9446fdc5f -- so the layout the decision is taken
against is missing every pool's bytes and is systematically too compact.  In
DCICYC that is three pools.  The decision is not wrong by a threshold; it is
taken against the wrong addresses.

So the fix is not a number.  Either the ambiguity resolution has to run on a
pass whose addresses are real, or the collect pass has to advance over pools
using the previous pass's sizes so that its addresses are.  Both are structural
and neither should be attempted without both harnesses and someone watching:
243 byte-exact modules currently depend on the present behaviour.

IT WORKED, and the entry above was right about where it had to go.

`srsBranchCeiling = 54`, applied where the instruction is ENCODED rather than
where `optimizeScratch` decides.  FCMBMAN goes from 157 mismatched bytes to
zero, the corpus goes 243 to 244, RUNASM stays 205 of 205, and DCICYC's
`BC 07-1,#@LB260` at DCICYC.asm line 646 finally assembles as C6F7 0037
reaching 00670 -- the original's bytes exactly.

    MATCH       244      MATCH?       3
    DIFFERS      22      NOCOMPARE    3

THE SAFETY ARGUMENT, which is why this was worth trying rather than agonising
over: the 243 modules that already matched ARE the original's bytes, so every
SRS branch displacement in them is 53 or less, and a limit that only bites at
54 cannot fire in any of them.  The sweep bears it out -- exactly one module
changes and it changes to MATCH.

TWO ATTEMPTS PLACED THE LIMIT IN THE WRONG ARM AND CHANGED NOTHING AT ALL.  The
obvious home is the `# Is SRS.` arm of the big if-chain, and a print there shows
it is never reached for this instruction.  A forward `BC` is caught earlier by
a special case of its own --

    elif operation == "BC" and d >= 0 and d < 0b111000:
        data = generateSRS(properties, "BCF", r1, d & 0b111111, 0b00)
        done = True

-- which carries its own copy of the limit as a literal and sets `done`,
bypassing the chain.  Instrumenting `generateSRS` itself, and printing the
caller from `traceback.extract_stack()`, is what found it in one run after two
readings of the chain had failed.  THERE MAY BE MORE COPIES OF THAT CONSTANT:
`0b111000` and `0x38` both appear as SRS limits elsewhere, and anything else
that changes the SRS rule should grep for both before assuming one edit covers
it.

DCICYC IS NOT FIXED and rose slightly, 1983 mismatched bytes to 2067.  Its line
646 is now correct, so what remains is something further on that the old layout
was masking.  It is still the largest single DIFFERS and still the best target;
re-run the aligner in the entry above to find where its addresses first part
company now.

248 of 272.  FCMBOOT, FCMCBLKS, FIOMDPPG and FPMSDERR go byte-exact, RUNASM
stays 205 of 205, nothing moves the other way.  6c89c6b6e.

    MATCH       248      MATCH?       3
    DIFFERS      18      NOCOMPARE    3

A CORRECTION THAT MATTERS MORE THAN THE COUNT.  An earlier entry recorded
FIOMDPPG's six bytes as an ORIGINAL-BUILD ANOMALY -- the magnitude of a
negative offset in an unsigned field -- and said two samples was not enough to
write a rule from.  That was wrong.  It was our defect, and the reasoning that
declined to fix it was sound only because the evidence was thin; six more
samples in FCMCBLKS made it legible.  The lesson is not "guess sooner" but
that a deferred finding is worth re-opening when a second module joins it.

THE MECHANISM.  A hashcode is `random << 36`, so a bare EXTRN has nothing below
bit 36 and `FIOBRE-2` is `((random-1) << 36) + (2**36 - 2)`.  The borrow comes
out of the HASHCODE ITSELF, not out of the four-bit buffer above the offset
that exists to catch exactly this, so `unhash` returns None,None and the whole
relocation branch is skipped; the raw low bits reach the object module.  The
symbol is recoverable because its hashcode is one greater than the masked
value.  Anything else that adds to or subtracts from a hashed symbol has this
same trap under it.

OST, LPS AND SSM reach backward with the AM=1 form and the `i` bit exactly as
branches do -- there is nothing branch-specific about that encoding -- BUT ONLY
FOR A LOCAL TARGET.  Adding them unguarded broke FIOPDHF, whose `OST
R2,FIOBCES1+2` names an EXTRN and keeps the absolute form with its relocation.
The guard needed a new test, because `extrnD2` is `d2 in rextrns` and `rextrns`
is keyed by the bare hashcode, so an EXTRN carrying a displacement is absent
from it.  `extrnBase` allows for the offset.  EXPECT THAT DISTINCTION AGAIN:
several places test for an external operand and most of them test the bare form
only.

AND A NOTE ON THE HARNESS.  An intermediate `extrnBase` crashed on a None
operand and the sweep reported FIOSVC and FPMIHPC2 as CRASH rather than
NOCOMPARE.  That the classification changed at all is why the crash was noticed
within one run; a harness that had lumped both under "failed" would have hidden
it.

TRIED AND REVERTED.  The proper fix for the borrow described above is not to
recover the symbol afterwards but to stop the borrow happening: give a hashed
symbol a non-zero value below bit 36 so subtraction has somewhere to borrow
from.  The four-bit buffer field between the offset and the hashcode exists for
exactly that and is simply never primed.

The minimal form was tried -- `hashcodeBias = 1 << 32`, added by `getHashcode`
and understood by `unhash`, which then reports a NEGATIVE offset (buffer
borrowed to zero) instead of returning None,None.  The bias sits above every
mask that reads an offset and below `hashcodeMask`, so positive offsets read
correctly everywhere and the lookup key is unchanged.  Three `rextrns` lookups
that mask the bias off needed it added back; the two point fixes above
collapsed into one-line magnitude rules, which is the tidiness the change was
for.

It works for the modules it was aimed at -- FCMCBLKS, FIOMDPPG, FIOPDIPG and
FIOPDHF all byte-exact -- AND IT BREAKS 51 OF THE 205 RUNASM MODULES, most with
a signature of a few mismatched bytes and three missing.  So the representation
is assumed in more places than the twenty masks that read it: `bceField`, for
one, already resolves a hash and hands back a signed displacement, so code
downstream of it sees a plain number and the ADDRESS layout had to test
`first < 0` rather than unhash again.  There will be more of that shape.

WORTH DOING PROPERLY, NOT WORTH BOLTING ON.  The payoff is latent-bug
prevention across every arithmetic on a hashed symbol, and the corpus cannot
show a gain because both symptoms are already fixed at 6c89c6b6e -- the only
experimental outcomes available are "unchanged" and "regression", which is a
poor position to iterate from.  Anyone taking it up should expect to chase the
51 rather than to land it in one pass, and should start by asking which callers
receive a hashed value and which receive an already-resolved one, because the
code does not distinguish them by type and that is the actual defect underneath.

The tree is clean at 248 of 272; nothing of this was kept.

253 of 272.  FCMDSCRM, FCMMGPOV, FCMSVC, FIOMGCV and FPMTMENQ go byte-exact and
FIOCGR loses all 43 of its mismatches.  RUNASM 205 of 205.  1516690d8.

    MATCH       253      MATCH?       3
    DIFFERS      13      NOCOMPARE    3

THE DEFECT IS ANOTHER CONSEQUENCE OF PRE-EXPANSION, and the third distinct kind
found this way -- after the vestigial invocations and the stray literal-pool
cards, both of which were fixed in the SOURCE.  This one had to be fixed in the
ASSEMBLER, because the residue is not a spurious card but a MISSING one: a
continuation marker pointing at a card the splice displaced.

    103  LR    R2,R7    GET LOCAL/REMOTE I/O DATA BUFFER    X007100AA
    104        CHI      R6,2                                 03-POPIN

The X continues onto what used to be a comment card.  The expansion now stands
there and was eaten as the continuation, so `CHI R6,2` never assembled and every
later address ran four bytes low.  Note how it PRESENTED: 43 scattered
mismatches spread through the module, not "an instruction is missing".  A
uniform shift downstream of one dropped statement looks like widespread
corruption, and the aligner is what turns it back into a single cause.

THE RULE.  Columns 73-80 read `nn-NAME` on a generated card and a sequence
number on a typed one, so a generated card cannot be the continuation of a
typed card -- it was not in the deck when that column 72 was punched.

THREE GATES CONSUME A CONTINUATION and a spliced card has to clear all of them.
Two attempts changed NOTHING MEASURABLE because each fixed one gate and the
next still dropped the card:

  - `joinOperand` in fieldParser.py reads column 72 off the card itself.  It
    already declined to APPEND a comment continuation to the operand but
    consumed it regardless; it needed its own guard because it never consults
    the flag.
  - the caller of `parseLine` discards a card whose predecessor continues.
  - `generateObjectCode` keeps its own `continuation` flag and skips likewise.

The last two read `properties["continues"]`, so correcting that flag where it is
COMPUTED fixes both; that is the edit worth copying if this comes up again.
When a change to continuation handling appears to do nothing, suspect a second
gate before suspecting the rule.

256 of 272.  FCMINSSL, FIOMGDSP and FIOMM128 went byte-exact on the ZCON fix.
3316a769b.

    MATCH       256      MATCH?       3
    DIFFERS      10      NOCOMPARE    3

THE ZCON DEFECT was that `Z(,sym+n,flags)` had only its leading IDENTIFIER
taken -- to hang the relocation on -- and the expression itself thrown away, so
the address field went out as zero.  `Z(sym+n,...)` already resolved properly
and the two now share a path.  A LOCAL symbol is the clean demonstration:
FIOMM128's `Z(,FIOMACNS+36,8)` is 00F4 in the original against our 00D0, and
FIOMACNS alone is 00D0.

TWO THINGS EXAMINED AND NOT FIXED, both left with the evidence so the next
session starts from the finding rather than the symptom.

DCI#DATA, 2 bytes.  Our symbol table records DCIDOUT at 0000A6 while the
statement that defines it is placed at 000A4 -- the label takes a value two
halfwords past its own statement, which is exactly the width of the two Y
constants opening it.  The consequences are inconsistent and that is the
interesting part: statement 19's `DC Y(DCIDOUT)` emits 00A6, two high, but the
`Y(DCIDOUT+2)` inside the defining statement emits 00A6, which is correct for a
base of 00A4, while `Y(DCIDOUT+508)` emits 02A1 against the original's 02A0,
one high.  Three different effective bases in one module.  Start by finding
where a DC's label value is recorded relative to its subfield emission.

FCMTRACE, 47 bytes, and FCMTSYNC beside it.  `BL$ FCMWRAP(R3)` assembles as the
two-byte DA54, a short forward branch, where the original has the four-byte
C2F3 form.  In the SRS BRANCH encoding the two-bit field is the FORM selector
-- BCF 00, BVCF 01, BCB 10, BCTB 11 -- not a base register, so the short form
has nowhere to put R3 and shortening discards it; the branch reaches the right
address anyway, by luck of the displacement, which is why it shows up as a
length difference rather than a wrong target.

GUARDING IT ON `specifiedB2` DOES NOT WORK and was tried and reverted: the
`(R3)` never reaches that flag, so it is being parsed as an INDEX rather than a
base register.  Establish which of `X2` and `B2` the grammar puts it in before
writing any condition on it.  The site that actually emits this is the
`elif operation in branchAliases:` arm, found by instrumenting `generateSRS`
and printing its caller -- and it carries the THIRD copy of the SRS limit as
its own `0b111000`, the others being in the forward-`BC` special case and in
the main SRS arm.

260 of 272, from 223 at the start of the day.

    MATCH       260      MATCH?       4
    DIFFERS       5      NOCOMPARE    3

THE `$` SUFFIX WAS THREE SEPARATE DEFECTS and all three fell out of two
sentences already recorded in `ap101s-notes.py` -- which is the lesson worth
carrying: that database exists for undocumented corners of the language, the
`$` entry was written on 2026-08-09 from the original binaries, and an hour was
spent re-deriving it from listings before anybody looked.  SEARCH IT FIRST.

    it forces the LONG form ..... `forceRS` is set through argsRSonly and every
                                  shortening path honoured it except the
                                  `elif operation in branchAliases` arm
    it names a BASE register ..... `droppedBase` reclassified it as an index
    it clears the ADDRESSING bits  so AM=0 and the displacement is absolute,
                                  not PC-relative

FCMTRACE, FCMTSYNC, FCMCSYNC and FCMISYNC came from those.  EACH FIX ALONE
LOOKS LIKE A REGRESSION -- suppressing `droppedBase` without honouring
`forceRS` took FCMTRACE from 5 mismatched bytes back to 47, because with `x2`
unset the shortener ran again.

AND A REGISTER IS AN INDEX ONLY IF SOMETHING ELSE IS THE BASE.  `@` and `#`
select MSC and BCE addressing, which the code read as "the register in
parentheses is an index"; it moved the register to `x2` and left `b2` alone
when `unUsing` found no replacement, putting the same register in both fields.
FCMTRACE's `ST@# R4,0(R2)` was 34F6 5800 against 34F6 1800.

FCMSSYNC'S REMAINING 2 BYTES ARE NOT WHAT THEY LOOK LIKE, and two hypotheses
were tested and killed before the real shape appeared.  Its `CNOP 2` is at an
even halfword address, so the original pads nothing and the 77E7 there is the
`XR R7,R7` that follows; we show D800.

  NOT a CNOP parity bug.  Instrumenting the fill loop on the compile pass
  prints `pass=3 pos1=40 halfword=20 target=0` -- even address, target 0, the
  loop does not run.  Nothing is emitted.

  NOT stale SECTION memory, though that is real and worth knowing: `memory` is
  allocated once as `bytearray(defaultChunk)` and never cleared between passes,
  so any byte a pass writes survives wherever a later pass does not write over
  it.  Clearing it every pass was tried and changed NOTHING here.

  IT IS STALE PER-STATEMENT BYTES.  The listing prints `00020 D800` for the
  CNOP and `00020 77E7` for the XR -- the same address twice -- and the
  comparison counts the assembled bytes recorded on each STATEMENT, not the
  section image.  The CNOP is carrying object code from a pass on which it did
  pad, and nothing clears it when a later pass emits nothing.  Look for where a
  statement's assembled bytes are stored and make a pass that emits nothing
  clear them.

262 of 272.  FCMSSYNC byte-exact and FCMISYNC from MATCH? to MATCH, both from
one fix.  c4e961fc7.

    MATCH       262      MATCH?       3
    DIFFERS       4      NOCOMPARE    3

A STATEMENT THAT EMITS NOTHING KEPT THE BYTES IT EMITTED LAST TIME.
`toMemory` accumulates into `properties["assembled"]` and restarts the run when
the pass changes -- but a statement that emits nothing on a later pass never
calls `toMemory` at all, so the restart never happens.  FCMSSYNC's `CNOP 2`
showed D800 from a pass on which it did pad, printed at 00020 where the
`XR R7,R7` that follows also printed: THE SAME ADDRESS TWICE IN ONE LISTING,
which is the signature to look for.  Cleared per statement per pass.

That also accounted for one of the MATCH? results, which is worth knowing: a
stale run looks from outside exactly like "bytes at an address the listing
shows nothing for", because that is what it is.

MENU12 NEEDS A DECISION AND IS NOT AN ASSEMBLER DEFECT.  Its 1128 mismatches
are one halfword of shift, present from the very first statement: the original
has `MENU DS 0H` at 00001 and we have it at 00000.  The two bytes before it are
in a region the original listing SUPPRESSED with `PRINT OFF`, and the statement
numbers prove the deck had ~250 statements there that OI301700's extracted
source does not:  the three PRINT cards are numbered 4, 19 and 257 in the
listing, and the source jumps from SRN 000400AB straight to 001900AB.

OI340600 HAS THE MISSING RANGE -- an `ENTRY MENU,MENUA`, a change log, and
`MENUA DC Y(PAGE2-#VAR)`, which is exactly one halfword.  It is the obvious
candidate and I did NOT insert it, because MENUA appears NOWHERE in OI301700's
listing and nothing in OI301700's source references it, and that listing has no
symbol table to settle it either way.  Copying a card from another release into
a gap the listing cannot show is a judgement about what this release contained,
not a repair.  Ask before doing it.

FCMBMASK IS A THIRD THING AGAIN.  Its 702 mismatches are also one halfword of
shift, from 00038, where `LH R4,TBMPVAR` is the two-byte 9C04 in the original
-- base 0, displacement 1 -- and the four-byte 9CF0 0001 here.  Same base, same
displacement, long form.  So we FAIL to shorten where the original does, which
is the opposite of every length defect fixed today.

The arm of `optimizeScratch` that should have shortened it cannot: TBMPVAR
resolves into the unnamed DSECT `*DSECT*` while the only active USING names
section FCMBMASK, so its `section == u[1]` test never matches.  The DSECT is
evidently mapped over the CSECT and the assembler does not know it.

AND THAT ARM IS MALFORMED IN TWO WAYS, which is worth recording even though
correcting it did not help:  it puts `u[1]`, the section NAME, where a register
number belongs, so `b` is only ever tested for being non-None; and it compares
the USING's OWN address against `srsCeiling` instead of the displacement from
it to the symbol.  Correcting both -- displacement `value - u[2]`, `b` the
register index, ties to the higher register -- changes FCMBMASK not at all and
BREAKS FOUR RUNASM MODULES: DSNCS, DSQRT, SNCS and SQRT.  The broken test is
load-bearing; it suppresses shortenings that would otherwise be wrong.  Reverted.
Anything done here has to fix the DSECT mapping FIRST and the arm second.

265 of 272 and NOTHING IS LEFT IN DIFFERS.  77d9fa883 and the commits before
it.

    MATCH       265      MATCH?       4
    DIFFERS       0      NOCOMPARE    3

The three NOCOMPAREs are not assembler defects -- FIOSVC and FPMIHPC2 have
truncated sources, BILDNEW5 is oversized -- and the four MATCH? have no
mismatched bytes, only bytes at addresses their listings do not cover.

DCICYC WAS THREE DEFECTS, none of them the SRS/RS fixed point that earlier
entries spent so long on.  That framing was WRONG and is corrected here: it
said the two encodings were both valid and the question was which fixed point
the iteration lands on.  One of them was not valid.

  A FORWARD SHORT BRANCH CANNOT HOLD A NEGATIVE DISPLACEMENT.  Only BCB and
  BCTB take one, and they negate it first.  The range check tested
  `d >= srsCeiling` and never the low end, so a negative value passed and
  `generateSRS` masked it into six bits: `BC 6,#@LB259` is 65 halfwords BACK
  and assembled DEFC, a forward branch of 63.  A branch to the wrong address,
  not an alternative encoding.
    THE GUARD MUST NAME THE FORWARD BRANCH FORMS.  That arm covers everything
    `optimizeScratch` shortened, not only branches, and written broadly it cost
    DSNCS 3 bytes.

  ELEVEN BITS, NOT TEN.  `generateRS1` packs bits 10-8 into data[2], and the
  backward-branch call masked with 0x3FF, dropping bit 10 of any magnitude of
  1024 or more.

  A ROUNDING CARRY OUT OF AN IBM FLOAT'S FRACTION.  A value normalising to just
  under twoTo56 rounds up to exactly twoTo56, and `f >> 32` then carries into
  the EXPONENT.  `DC D'0.232830643653869628E-9'` is a decimal approximation of
  2**-32 landing just below it, so normalisation takes one step too many; the
  exponent comes out right BY ACCIDENT and the fraction comes out zero.

FIOCGR'S FOUR BYTES OF INTER-SECTION PADDING remain unexplained, and three
hypotheses have now been tested against the corpus rather than argued about:

    blanket doubleword alignment   REFUTED.  127 of 132 inter-CSECT boundaries
                                   land on a byte that is 4 mod 8 -- a
                                   fullword, not a doubleword.
    CSECT following a DSECT        REFUTED.  Implemented, it breaks 20 RUNASM
                                   modules, which have exactly that shape at
                                   non-zero addresses and are not aligned.
    a reserved checksum fullword   UNREFUTED but unimplementable: the linked
                                   map PFS/mafgen/DASS_G16.ASC shows a CHECKSUM
                                   fullword ahead of #ZFIOCGR, but nothing in
                                   FIOCGR's source could tell the ASSEMBLER one
                                   was coming, and the gap is in the assembly
                                   listing.
    first ZCON aligned, rest packed  UNREFUTED, n=1.  What is implemented.

The corpus has exactly four CSECTs following a DSECT and three sit at address
zero, so only FIOCGR is informative -- which is why RUNASM, not the corpus,
is what killed the DSECT rule.  RUN BOTH HARNESSES ON ANY SECTION-PLACEMENT
CHANGE; the corpus alone would have accepted it.

FPMIHPC2 IS NO LONGER NOCOMPARE.  It assembles with NO diagnostics and compares
at 1843 mismatched and 4 missing bytes, from 146 intolerable lines.  Nothing is
installed; this entry is the recipe, which regenerates the candidate from the
as-received listing deterministically.

THE CAUSE IS `unprint.py` AND THE LISTING TOGETHER, exactly as for FIOSVC.  A
copied member is bracketed by "START OF COPY MEMBER" and "END OF COPY MEMBER"
banners; unprint.py diverts its output to the member's buffer on the first and
switches back on the second.  FPMIHPC2's listing carries TWO STARTs with no
matching ENDs -- FIOSGEVT at line 1640 and FICCEQUS at 1769 -- so everything
after the first was diverted and thrown away.  Run unprint.py on an untouched
copy and it reproduces the committed 1356-card file exactly.

THE RECIPE, all on a COPY of the listing in scratch, never the original:

  1. Insert an "END OF COPY MEMBER FIOSGEVT" banner after line 1659.  Its last
     card is 1659 (01-EVTEQ) and the outer module resumes at 1660, SRN 053000BO.
     Model it on the END banner the same listing carries at line 433.
  2. Insert an "END OF COPY MEMBER FICCEQUS" banner after line 1863.  Its last
     card is 1863, `EXTRN CZ2VIF1`, SRN 007900AO; the outer module resumes at
     1865 with `GENERATE COPY=(TFPSA,TFPCT,TFTQE,TFPDE,TFGST,TFIOQ)`, SRN
     101800BZ.  Model it on line 1162.
  3. Re-extract:  unprint.py --file=FPMIHPC2, from a directory with ../MLIB80
     present or it dies on a FileNotFoundError.  Yields 1888 cards ending with
     `END` at SRN 110800CC.
  4. Comment out two vestigial invocations, `*` in column 1:  the `IF` at card
     246 (SRN 012000BO) and the `GENERATE COPY=(...)` at card 1449 (101800BZ),
     each standing beside its own expansion.
  5. Renumber every `#@LBn` to `#@LB(n+2000)`, definitions and references
     alike, preserving columns.  123 distinct labels, range 1..211.

GET THE FICCEQUS BOUNDARY WRONG AND IT LOOKS LIKE A DIFFERENT BUG.  Placing
that END at 2315 instead of 1863 swallows ~450 of the OUTER MODULE's cards --
the GENERATE and the TFIOS/TFICC invocations among them -- and the module then
reports undefined TFICC, TFIOQ, TFGST and their fellows.  I concluded from that
that MLIB80/FICCEQUS.asm was itself truncated.  IT IS NOT.  The user spotted it
from the listing: TFICC is invoked at SRN 102600BZ, which is the outer module's
own numbering, so its expansion had to be in FPMIHPC2 and I had discarded it.

WHY THE LABELS MUST MOVE.  The `#@LBn` are generated sequentially, and the
outer module's text is PRE-EXPANDED while FIOSGEVT and FICCEQUS are COPY'd from
MLIB80 and expand LIVE at assembly time.  Their macros number from 1 and
collide with the retained expansions, giving `Already defined: #@LB1`.  The
labels are local and need not be sequential, so any unused range serves.

WHAT REMAINS is a single missing halfword, not 1843 problems.  Every mismatch
is a displacement one too small -- DE vs DF, C7 vs C8, D7 vs D8 -- against
targets around 014B, so something ahead of them is one halfword short.  That is
the same signature that resolved DCICYC and FCMBMASK.  Chase it with the
address aligner, BUT teach it to ignore `#@LBn` differences first or it reports
the renumbering as divergence and hides the real one.

AND DECIDE ABOUT THE RENUMBERING BEFORE COMMITTING.  It is safe within the
file, but FPMIHPC2's labels would no longer match its listing's text, which is
true of no other module in the corpus.

267 of 272.  FPMIHPC2 byte-exact, 072bdf2f in PFS; only BILDNEW5 remains.

    MATCH       267      MATCH?       4
    DIFFERS       0      NOCOMPARE    1

FPMIHPC2 WAS THREE EXTRACTION FAULTS, not one, and the recipe is in its commit.
The last of them is worth carrying: card 059400BO is marked continued and its
continuations 059500BO/059600BO are absent from the listing, so unprint.py
swallowed the next genuine instruction -- `SR R4,R7` -- in their place, and
every later address ran one halfword short.  ONE DROPPED INSTRUCTION WAS THE
WHOLE OF A 1843-BYTE DISCREPANCY.  FIOSVC has the identical fault at its SRN
006204.  Expect it wherever a listing's SRNs skip.

AND A RAW RE-EXTRACTION REINTRODUCES THE ENGINEERS' NAMES.  The listings carry
none of the `^xx` tags the committed sources use -- 69 of them in FPMIHPC2 --
so a whole-file replacement silently undoes the anonymisation.  Restore them by
matching SRNs against the previous version, and CHECK before committing.

BILDNEW5 IS NOT AN EXTRACTION PROBLEM.  Its source is 605 cards of which 25 are
COPY and 32 are anything else.  The first intolerable diagnostic falls in the
THIRD copy, HISAM, and is `@DLY is an MSC instruction whose encoding has not
been established` -- 460 of those, where ASM101S emits four zero bytes and says
so rather than guessing.

But the bulk is one macro.  Of 7930 intolerable lines:

    7779  Branch to (&N).ONELIST,.TWOLIST,.THREEL,.FOURL,.FIVEL,.SIXL in CHAR
    5229  ANALOG CONTROL BITS NOT GATED FOR CHARACTERS
    2679  OPERAND MISSING - CHAR SET TO BLANK
     630  undefined symbols, and Cannot evaluate Y-type constant
     460  @DLY

The first is a COMPUTED AGO -- a branch to one of six sequence symbols selected
by an index -- inside a macro named CHAR, and the next two are that macro's own
MNOTEs firing once the branch has gone wrong.  So BILDNEW5 is blocked on
conditional-assembly machinery, and `@DLY` is a smaller separate matter.

Don Schmidt reports he can build BILDNEW5, so his assembler resolves that AGO;
his sources are the place to look before implementing one.

BILDNEW5 now assembles and COMPARES.  It has been the one module that could not
be measured at all; it is now the one that measures badly, which is a different
and much better problem.

    MATCH       267      MATCH?       4
    DIFFERS       1      NOCOMPARE    0

    BILDNEW5: 30782 bytes mismatched and 3223 bytes missing,
              2642 bytes past the end of the listing

Nothing else moved.  267 MATCH and 4 MATCH? are unchanged across all three
sweeps of the night, and RUNASM stayed 205/205.

WHAT IT TOOK WAS SEVEN THINGS, and only the first three were the assembler's
conditional-assembly machinery -- the rest were the SOURCES.

    7906  intolerable lines at the start
      61  after the computed AGO, list-valued SET and T'-of-null
      23  after the $POF/$PON cards were put back
      12  after the vestigial invocations were commented out
       0  after @STP, the DC packing rule and the AM=1 fix

THE COMPUTED AGO, LIST-VALUED SET AND T' OF A NULL SET SYMBOL are in ASM101S at
75a76b6d3 and in ap101s-notes.db.  Between them they make CHAR work, which was
7779 + 2679 of the diagnostics.  CHAR now returns the documented code for every
class of operand -- A 65, 0 48, _ 22, CR 13, BLK 32, BKSP 8, COMMA 44, LPAREN
40, RPAREN 41.

THE SOURCES WERE MISSING 35 CARDS, and the reason is worth carrying because it
will recur.  $POF and $PON wrap their generated `DS 0H` in PRINT NOGEN, so the
DS never reached the listing; the extraction, which keeps expansions and drops
invocations, therefore had nothing to keep and dropped the call as well.  The
original build has 57 $POF/$PON pairs and ours had 41 and 38.  TESTING.asm
carries the pre-expanded unprotect table naming $POF001 through $POF057, so
sixteen of its entries pointed at labels that were never defined -- 630 of the
intolerable lines, every one of them "Cannot evaluate Y-type constant".

    ANY MACRO THAT SUPPRESSES ITS OWN OUTPUT IS INVISIBLE TO THE EXTRACTION.
    In this library that is $POF, $PON, FTBP and MSGBUFER, and no others.

AND 5287 CARDS WERE VESTIGIAL INVOCATIONS -- calls whose expansion is already in
the file, so expanding them again emits the code twice.  This is the fault
5c35b774 fixed by hand in ten SSSRC modules; the MLIB80 members BILDNEW5 copies
have it at fourteen times the scale.  DCHAR 5229 of them, in GENLINES alone.

    RECOGNISE THEM BY THE CARD THAT FOLLOWS, not by the call itself.  A first
    attempt asked whether the INVOCATION carried an `nn-MACRO` stamp, which is
    true of the 5276 DCHAR/XPOS/YPOS calls the original build generated in
    turn -- but CHRESET's ten calls are ordinary source cards with ordinary
    SRNs and their expansions are there just the same.  Asking instead whether
    the next card carries a stamp DEEPER than this one's finds all of them.

    SKIP `PRINT` CARDS WHEN LOOKING AHEAD.  A PRINT emits nothing, and the one
    place it turns up as the card after a call is where it belongs to a
    DIFFERENT call whose output was suppressed -- PSA.asm has `PSA EX4`, then
    the dropped `$POF`, then $POF's PRINT NOGEN/GEN pair with the DS gone from
    between them.  Reading that pair as PSA's expansion commented out a call
    the original build really did make.

Both repairs are scripted, in modules/sdfpkg: restore-pofpon.py and
comment-vestigial.py.  Run restore FIRST -- it anchors on unique (SRN, text)
pairs and commenting changes the text.

THE LAST THREE WERE ENCODINGS.  @STP's operand is the OPX field in the second
nibble, not a count; a DC operand without a bit-length modifier is not part of
the packing beside ones that have it; and a mnemonic carrying `@` or `#` cannot
take the AM=0 form, because those two bits exist only in AM=1.  All three are
in ap101s-notes.db with the listing evidence.

A CRASH HIDES BEHIND AN ABORTED ASSEMBLY.  With the intolerable errors gone,
BILDNEW5 reached the real listing printer for the first time and died there on
`&C EQU` -- a card inside a macro DEFINITION, echoed but never expanded, whose
name is still a variable symbol.  An aborted assembly prints the error listing
instead and never comes near that code.  Expect more of these as modules stop
aborting.

WHERE TO START NEXT.  The first divergence is at FAILEXEC's SRN 011800AB:

    original   00235 E8F7 0237  046E    FAILEXEC LA  B0,FAILDATA
    ours       00235 E8F7 0257  048E    FAILEXEC LA  B0,FAILDATA

FAILDATA is 32 halfwords later in our build than in the original, and every
address after it is shifted.  The `TH UNPRTFLG` on the next card then differs
for a second, dependent reason -- the original takes the 2-byte SRS form
(A30C) and we take the 4-byte RS (A3F0 0003).  Fix the layout first; the
length choice may follow from it.

BILDNEW5 is 4482 of 6979 cards byte-identical -- 64% -- and the rest divide
cleanly into two piles, one of which causes most of the other.

    identical                 4482
    same length, wrong value  1782
    DIFFERENT LENGTH           715

714 OF THE 715 ARE OURS LONGER: we emit the four-byte RS form where the
original emitted the two-byte SRS.  One card goes the other way.  By mnemonic:
STH 204, LH 163, L 66, ZH 50, ST 46, TH 41, SHW 22, LA 21, C 17, CH 16, N 15,
TD 15.  Since each one adds two bytes, everything after it shifts, which is
where the 1782 wrong VALUES come from -- the first of those,
`AMCPTEST DC Y(AMCPLIST)`, is 50FA in the original and 53DA here, and 0x2E0 is
just accumulated drift.

THE DECISION INPUTS ARE RIGHT AND THE LENGTH IS STALE.  Instrumenting the first
of them, `TH UNPRTFLG` at FAILEXEC's SRN 011600AB, where the original has A30C
and we have A3F0 0003:

    d=3  dSRS=-565  uUnhashed=3  dUnitizer=1  b2=0  usingB2=True
    forceRS=False  forceAM0=False  forbiddenSRS=False  srsCeiling=56
    len(data)=4

Displacement 3, well under the ceiling of 56, nothing forcing the long form --
and the SRS arm never gets to look, because its first condition is
`len(data) == 2` and the length was fixed at 4 several passes earlier.
model101.py says so itself, in the comment above `if operation in
argsSRSorRS`, which ends `***FIXME***`:

    if collect and not asis:
        dataSize = 4
    else:
        dataSize = properties["length"]

    "We often cannot determine the size of the instruction without already
     knowing the size of the instruction."

A MINIMAL REPRODUCTION DOES NOT REPRODUCE.  The same instruction, the same
`USING FAILDATA,B0`, the same displacement of 3 in a five-statement module
assembles A300 -- two bytes, correct.  So the rule is not simply "a USING base
defeats SRS"; something about BILDNEW5's passes leaves `properties["length"]`
at 4 where a small module's converge to 2.  That is the thread to pull.  The
base register is not the discriminator either: of the 714, our second byte is
F1 410 times, F0 242, F2 54 and F3 6, so every base is affected.

This is the same problem sections 129 through 135 circled for DCICYC, reached
from the other side.  Whatever is tried, RUN BOTH HARNESSES: the corpus alone
accepted a wrong rule here more than once.

The arm that should shorten those 714 is the last one in `optimizeScratch`, and
it does not look at the operand at all:

    b = None
    d = 10000000
    for u in entry["using"]:
        if u != None and section == u[1]:
            if u[2] < d:
                d = u[2]
                b = u[1]
    if b != None and d >= srsFloor and d < srsCeiling:
        adjust(scratch, properties, i)

`using[r]` is `(hashedBase, section, address)`, so `u[2]` is where the USING
was established.  `value`, computed a few lines above from `unhash(d2)`, is
where the OPERAND is -- and is never used.  What the ceiling test therefore
asks is whether the BASE sits in the first 56 halfwords of its section.  It
also takes the base with the smallest address rather than the one nearest the
operand, and puts the SECTION in `b`, which every other use of that name
treats as a register.

BUT `value - u[2]` IS NOT THE FIX.  Measured, not reasoned about -- the arm
instrumented and BILDNEW5 assembled, against the one card in question:

    ###U### op=TH sect=GPCIPL section=GPCIPL value=1200
            using=[(..., 'GPCIPL', 544)] -> d=544 ambiguous=True len=4

The true displacement is 3.  `u[2]` is 544 and `value` is 1200, so the
"corrected" difference is 656 -- as useless as the 544 it replaces.  THE TWO
NUMBERS ARE FROM DIFFERENT MOMENTS: `u[2]` was captured when the USING card
was walked, and `value` is re-evaluated at the end of pass 1 out of a symbol
table that has moved since.  Neither is the pass-1 distance between the two
symbols, let alone the final one.

    FAILEXEC.asm, the member BILDNEW5 copies, holds all four cards:

        011400AB  line 128         USING  FAILDATA,B0
        011600AB  line 129         TH    UNPRTFLG
        086000AB  line 786  FAILDATA DS    0F
        086800AB  line 796  UNPRTFLG DC    H'0'

    The USING names a symbol defined 657 cards later in the same member, so it
    is a forward reference and 544 is not FAILDATA's address at all.  The
    original assembles the TH as A30C, two bytes; we emit A3F0 0003, four.

AND THE OLD CODE IS RIGHT ONLY BY ACCIDENT.  A five-statement reproduction of
the same instruction, base and displacement gets `u[2]` = 0, because there the
USING's forward reference is still wholly unresolved when it is captured; 0
passes the ceiling test, `adjust` fires, and the instruction is correctly
shortened for a reason that has nothing to do with its displacement.  Put
`value - u[2]` in and that module, right today, becomes wrong.  Using the
hashed base, `d2 - u[0]` as findB2D2 does, has the same defect: the offset is
in the low bits and those are the bits that are stale.

    SO THE ARM SHORTENS WHEN THE BASE HAPPENS TO CAPTURE SMALL AND NOT WHEN
    THE DISPLACEMENT HAPPENS TO BE SMALL.  BILDNEW5 captures 544 and gets
    nothing; the reproduction captures 0 and gets everything.

Which makes this the same fault as the unnamed-DSECT one already recorded
above `if operation == "DSECT"` in the preliminary pass -- FCMBMASK's
`USING TFBMP,R0` resolving one way on pass 1 and another way afterwards.  The
comment there ends "optimizeScratch runs at the END of pass 1 against the
pass-1 snapshot, so the arm that would have shortened `LH R4,TBMPVAR` could
never match its section."  It is the same arm and the same cause.

SO THE FIX IS NOT IN THE ARM, and it is not a better formula either.  Both
operands of the subtraction have to be read from ONE settled layout: either
the shortening runs again after a pass in which the USING bases are resolved,
or `entry["using"]` is re-resolved from symtab at the moment the arm reads it.
Neither should be attempted without running BOTH harnesses -- this arm is load
bearing for modules that are byte-exact today, and the accidental behaviour is
what makes them so.

Done, and it is committed.  The USING's own base EXPRESSION is now carried
along in the snapshot and re-evaluated inside `optimizeScratch`, which works
precisely because that runs at the END of the pass, when the forward reference
has been placed.

    using[r] = (h, section, address, properties, k)

`properties` is the USING statement's, so `properties["ast"]["r"][0]` is the
base expression; `k` is the register's place in the USING's list, because
`address` advanced by 4096 for each one.  The arm evaluates that expression
against the current symtab and takes `value - (base + 4096*k)`.

ADDED AS A SECOND CHANCE, NOT A REPLACEMENT.  The old test stays exactly as it
was and the two are joined by `or`.  Where a base is still wholly unresolved
it captures 0, passes, and shortens correctly for the wrong reason -- and
modules that are byte-exact today depend on that, so an `or` can only shorten
more, never less.  Replacing the test outright was tried and it breaks a
five-statement reproduction that is right today.

BILDNEW5:

                            before   after
        byte-identical        4482    5403
        wrong value           1782    1508
        WRONG LENGTH           715      70
        past end of listing   2642     224
        missing                3223     678

645 of the 715 length errors gone and 921 more cards byte-identical.  The
module's SIZE is now nearly right, which is what the last two rows say: 2642
bytes fell past the end of the listing before and 224 do now.

VERIFIED BOTH WAYS.  The corpus is 267 MATCH, 4 MATCH?, 1 DIFFERS with no
module changing class against the sweep before the change, and RUNASM is
205/205 with --no-rtl-fixes over the identical module set.

WHAT IS LEFT IS A DIFFERENT SHAPE.  The 66 still long are led by ST 26, L 19
and C 5, where the 714 were led by STH 204 and LH 163 -- so this is not the
same fault in a smaller quantity, and it wants its own measurement rather than
another turn of the same handle.  1508 wrong values remain and most were
always downstream of the lengths, so re-measure them before reading anything
into the count.

The 66 that survived the USING re-resolution were one thing, and it is now
fixed too.  FOR A FULLWORD OPERATION THE SRS DISPLACEMENT COUNTS FULLWORDS,
which doubles the field's reach, and the arm was comparing raw halfwords
against the ceiling.  `ST R6,FAILENV2+4` is 36B4 in the original -- 0xB4 >> 2
is 45 -- against a halfword distance of 90.  L 47, LE 6, N 30, ST 33: every
one exactly half the halfword figure.  63 of the 66.

The unitizer is derived here the same way the encoder derives it, from bits 0
and 9 of the opcode, and a distance that is not a whole number of units is
refused outright, which is the test `forbiddenSRS` already makes downstream.

BILDNEW5 across the three states -- and note that only the first column is a
different assembler, the other two are one arm of one function:

                            v2      v3      v4
        byte-identical    4482    5403    5563
        wrong value       1782    1508    1402
        TOO LONG           714      66      12
        too short            1       4       4
        past end of list  2642     224      36
        missing           3223     678     348

Corpus 267 MATCH, 4 MATCH?, 1 DIFFERS with no module changing class at either
step, and RUNASM 205/205 over an identical module set both times.

WHAT IS LEFT, AND THE FOUR ARE MORE INTERESTING THAN THE TWELVE.

Twelve too long: LE 3, L 2, ST 1, BVC 1, AE 1, SE 1 and a tail of singles.  No
shape yet; too few to generalise from and worth reading individually.

FOUR TOO SHORT -- ours shortening where the original did not, which the twelve
cannot explain away and which no amount of further shortening will fix:

    042100AB  BNC STMMAIN1     orig CEF7 0816   ours DE56
    053500AB  BZ  POLL94       orig C4F7 0036   ours DCD8
    181000AB  B   PURGSAVF     orig C7F7 0036   ours DFD8
    176300AC  STH R2,SECOND##  orig BAF1 0037   ours BADD

Three are branches and all three of those originals carry F7 in the second
byte -- AM=1, base 3.  ONE OF THE FOUR PREDATES ALL OF THIS WORK and three
arrived with the USING re-resolution, so that arm is now over-shortening in a
small way as well as under-shortening in a large one.  That is the honest
accounting: the net is 714 -> 12 and 4482 -> 5563 identical, but it is not a
pure win and the three should be understood before the twelve.

Tested, because 148 asserted it without testing: the USING arm was excluded
from every branch operation -- `operation in branchAliases or operation in
srsBranchOperations` -- and BILDNEW5 came out BYTE FOR BYTE THE SAME.

    identical 5563  wrong value 1402  too long 12  too short 4

The same four cards, unchanged.  So the arm is not deciding those branches at
all; the two PC-relative arms above it are, as they always were.  The change
was reverted rather than kept, since a guard that alters nothing is dead
weight carrying a wrong explanation.

WHAT ACTUALLY HAPPENED IS INDIRECT.  Shortening 700 other instructions MOVED
EVERYTHING, and three branches that were out of PC-relative range in the old
layout are now within it.  The branch arms then shorten them -- correctly by
their own rule, and wrongly against the original build, which left all three
long at CEF7 0816, C4F7 0036 and C7F7 0036.

    So this is not a fault in the new arm.  It is the branch rule's MARGIN,
    seen for the first time in a layout close enough to the original for the
    question to arise, and it belongs with sections 129 through 134 -- the
    srsBranchCeiling of 54 and "the original shortened right up to 55".

The fourth, `STH R2,SECOND##` at 176300AC, is not a branch and predates all of
this work, so it is a separate question again.

READ THIS BEFORE TOUCHING THE TWELVE.  Two of the four rows in 148's table --
the count arriving at 4 and the claim that three of them are the arm's fault
-- were inference.  The count is right; the attribution was not.

With the lengths nearly right the wrong-VALUE pile can finally be read, and it
is mostly not a pile of wrong values.

Comparing the ADDRESS of every same-length card, ours against the original:

        +12   5302 cards        +1    128
         +2    870              +6     20
        +11    351             +13     19
         +0    239             +10     11

So most of the module sits TWELVE HALFWORDS LATE and the values that differ
are overwhelmingly addresses carrying that drift.  ONLY 42 OF THE 1402 SIT AT
ADDRESSES THAT AGREE, and those 42 are the only ones that can be a genuine
encoding fault rather than a consequence.

    AMCPTEST DC Y(AMCPLIST)   orig 50FA  ours 5106     -- 12
    AREAPTR  DC Y(MSG132+10)  orig 471B  ours 4727     -- 12

EVERY STEP IN THE DRIFT IS ACCOUNTED FOR, and the card before each step is the
cause.  The twelve still-too-long instructions supply +1 each:

     +0 -> +1  044000AB  L R7,FAILBRTN     orig 1F0C  ours 1FF00006
     +1 -> +2  069300AB  L R7,FRTRNXEC     orig 1F10  ours 1FF00008
     +2 -> +3  023300AB  ST R7,KFINDIRW    orig 3710  ours 37F00008
     +3 -> +4  024800AB  BVC 6,STM1270     orig DE09  ours CEF0006B
     +4 -> +5  026900AB  LE F7,KFCON1+2    orig 7F18  ours 7FF0000C
     +6 -> +7  027700AB  LE F7,KFCON2      orig 7F1C  ours 7FF0000E
     +7 -> +8  028700AB  LE F2,KFCON3      orig 7A20  ours 7AF00010
     +8 -> +9  028800AB  AE F2,KFCON4      orig 5224  ours 52F00012
     +9 ->+10  029000AB  SE F5,KFCON5      orig 5D28  ours 5DF00014
    +10 ->+11  031700AB  ME F6,KFCON9      orig 6640  ours 66F00020
    +12 ->+13  035500AB  C R7,KFCON16      orig 1778  ours 17F0003C
    +12 ->+13  048500AD  BCB B'000',*      orig D806  ours D80001E6

and the four too-short give a halfword back each.  THE CNOP STEPS ARE
CONSEQUENCES, NOT CAUSES -- `CNOP 1` at 027200AB and 035300AB emit a D800 pad
here and none in the original, and `CNOP 2` at 040100AB the reverse, purely
because the drift has changed what is already aligned.  Do not chase them.

    EVERY ONE OF THE TWELVE HAS F0 OR F3 IN ITS SECOND BYTE and a displacement
    that fits: L 6 halfwords = 3 fullwords against an original 0x0C >> 2 = 3,
    LE 12 = 6 against 0x18 >> 2 = 6, ME 32 = 16 against 0x40 >> 2 = 16.  So
    the unit arithmetic is right and something else is refusing them; the arm
    should have caught every one.  That is the next thing to instrument.

Note the drift returns to +0 before the end, at `PATCH2 DC 50X'C6C6'` and then
at a Y-constant, so the module's total length already agrees; it is the
interior that is displaced.

WHAT THIS MEANS FOR PRIORITIES.  Fixing the twelve should collapse most of the
1402 as well, because they are the same fault seen twice -- once as a length
and once as every address after it.  The 42 are the only independent value
defects and should be read individually AFTER the drift is gone, not before.

Instrumented, over every refusal the arm makes across all its iterations:

    362   a USING covers it AND re-resolution found a base
          -- so the DISPLACEMENT was judged too far, or not a whole unit
    218   a USING covers it but RE-RESOLUTION FOUND NO BASE
    196   no USING covers the operand at all

THE 218 ARE THE ARM'S OWN DEFECT.  `entry["using"]` holds a base for the right
section and the re-evaluation still comes back with nothing, so it is failing
inside the new code rather than deciding against the operand.  The two
candidates, in order of suspicion:

  - the hashcode argument is passed as None.  `evalArithmeticExpression(...,
    symtab, None, severity=0)` is fine for a plain symbol and wrong for any
    USING whose operand mentions `*`, which cannot resolve without a location.
    `USING *,B3` and `USING *+2,B0` both occur.
  - the section test `s2 != section` rejects a base whose hashcode resolves to
    a different section name than the operand's, which is the FCMBMASK
    unnamed-DSECT trap all over again.

Both are cheap to distinguish: print `h2` and `s2` beside `section` in the
same arm.  Whichever it is, these 218 are where the remaining twelve
too-long instructions live -- `L R7,FAILBRTN` prints `uBase=None` with a
non-empty using list and `oldd=544`.

The 362 are a different question and may be correct refusals; do not assume
they are all wrong.  The 196 have no base to reach through and are not this
arm's business at all.

151 predicted that the twelve remaining too-long instructions lived among the
218 re-resolution failures, and named the likelier of its two causes.  Half of
that was right and the conclusion was wrong.

THE CAUSE WAS AS PREDICTED.  Instrumented, all 200 of the failures that could
be attributed report `evaluated to None`, and every one is a `USING *,...`:
the hashcode argument was passed as None and `*` cannot resolve without a
location.  The section-mismatch theory is dead.

THE FIX FOR IT CHANGED NOTHING.  Handing back the USING's own `pos1` --
`symtab[u[1]]["value"] + u[3]["pos1"] // 2`, which `adjust` keeps current as
it slides statements -- makes those 200 resolve, and BILDNEW5 comes out BYTE
FOR BYTE IDENTICAL:

        identical 5563  wrong value 1402  too long 12  too short 4

and no module in the corpus changes class.  So the change was reverted rather
than kept, on the same grounds as the branch guard in 149: code that alters
nothing is dead weight, and its comment would have claimed an effect it does
not have.

    WHAT THIS NARROWS.  The twelve are therefore in one of the other two
    buckets -- the 362 where a base WAS found and the displacement was judged
    too far, or the 196 where no USING covers the operand at all.  The 362 is
    the one to look at first, because `L R7,FAILBRTN` has a real displacement
    of 3 fullwords and something is still calling that out of range.

Instrumenting inside this arm is expensive: a print in the inner loop runs
tens of millions of times across the twenty iterations and takes the module
from five minutes to over forty.  Guard any trap on the operation or the SRN
before the loop, not inside it.

WHY.  One caveat on the arithmetic: the classification counted 218 re-resolution failures and the reason trap attributed 200 of them, all of them a USING whose operand is star. The other 18 were never attributed, so "the other two buckets" is 362 plus 196 plus those 18, not just the two. Small, but do not let the phrasing send you past them.

152 concluded that the twelve remaining too-long instructions must be in the
362 bucket, and its own caveat said 18 of the 218 re-resolution failures had
never been attributed.  The caveat was the answer.

Trapped on the twelve by name -- FAILBRTN, FRTRNXEC, KFINDIRW, KFCON1 through
KFCON16 -- guarded once per scratch entry rather than inside the register
loop, every one of the 44 prints reads:

    L    value=1157  oldd=544   uDisp=10000000  uBase=None  using=[('GPCIPL'..
    LE   value=2868  oldd=3160  uDisp=10000000  uBase=None  using=[('GPCIPL'..
    ME   value=2888  oldd=3160  uDisp=10000000  uBase=None  using=[('GPCIPL'..

    44 of 44 have uBase=None WITH A USING PRESENT.

So they are re-resolution failures after all, and NOT the `USING *` kind --
resolving those changed nothing, as 152 records.  They are the 18 the reason
trap never attributed.  The displacement was never judged too far; the arm
never got a base to judge it from.

WHAT TO LOOK AT.  The re-resolution needs `u[3]["ast"]["r"][0]`, and the
remaining ways it can come back empty are that the USING statement's
properties carry no `ast` at all, or an `ast` without an `r` list.  Print
`u[3].get("ast") is None` and `"r" in (u[3].get("ast") or {})` beside the
existing reason, guarded the same cheap way.  The three distinct bases -- 544,
3160 and 3356 -- are worth identifying too; the first is FAILEXEC's
`USING FAILDATA,B0` and the other two are unidentified.

    AND NOTE WHAT THIS SAYS ABOUT THE 362.  Nothing here has established that
    any of them is wrong.  152 sent the next reader at that bucket on an
    inference that has now failed; do not repeat it.

COST NOTE, CONFIRMED.  Guarding the trap once per entry instead of once per
register still roughly triples the run -- ten minutes to about thirty -- so
the name test is not free either.  Guard on the SRN and bail before touching
`properties` if this needs doing again.

153 said the twelve are re-resolution failures and "NOT the USING-star kind".
The first half stands and the second is an invalid inference, because THE TRAP
RAN ON THE REVERTED CODE.  With the star fix backed out, a USING whose operand
is star produces uBase=None by construction; observing it proves nothing about
whether that is the cause.

WHAT THE SOURCE SAYS.  STM1.asm line 178, SRN 018000AB, is

         USING *,0              AND TELL ASSEMBLER

and KFCON1 through KFCON16 are in STM1, so nine of the twelve are governed by
exactly the star form -- and `*,0` is verbatim what the reason trap printed as
its example.  The other three, FAILBRTN, FRTRNXEC and KFINDIRW, sit under
FAILEXEC's `USING FAILDATA,B0`, a plain symbol, and those showed uBase=None
too, which the star bug does NOT explain.

SO THE STATE IS THIS, AND NO FURTHER:

  - the twelve fail with no base, measured, on the code as committed;
  - nine of them are under a star USING and three are not;
  - WITH the star fix applied, BILDNEW5 was byte for byte identical, so the
    nine still did not shorten even once their USING could resolve.

That last point is the one to chase, and it has two readings that the runs so
far cannot separate: either the star fix did not actually resolve them --
`u[3]["pos1"]` may be None, leaving usingHash None after all -- or it did and
the displacement was then rejected.  ONE RUN DISTINGUISHES THEM: re-apply the
star fix and trap the twelve by name at the same site.  Do that before
anything else here.

I have now stated five conclusions in this section that measurement
contradicted.  The tables and traces are sound; treat every sentence joining
them as a hypothesis until it has its own run.

The run 154 asked for, with the star fix re-applied AND the twelve trapped at
the same site.  Every USING entry reports the same thing:

    L   value=1177  uDisp=10000000  uBase=None
        pos1=[('GPCIPL', 544, None), ('GPCIPL', 8812, None)]   | R7,FAILBRTN
    LE  value=2868  uDisp=10000000  uBase=None
        pos1=[('GPCIPL', 3160, None), ('GPCIPL', 3356, None)]  | F7,KFCON1+2

THE THIRD ELEMENT IS `u[3].get("pos1")` AND IT IS None, EVERY TIME.  The star
fix guarded on exactly that:

    if u[1] in symtab and u[3].get("pos1") != None:
        usingHash = symtab[u[1]]["value"] + u[3]["pos1"] // 2

so `usingHash` stayed None in every case and the fix NEVER RAN.  That is why
BILDNEW5 came out byte for byte identical with it applied, and it means the
second of 154's two readings was never tested: nothing yet says whether the
displacement would be accepted once a base is found.

    A USING STATEMENT CARRIES NO `pos1` IN ITS PROPERTIES.  It generates no
    object code, so whatever sets that field for code-generating statements
    never sets it here.  This is the thing to fix, and it is upstream of the
    arm entirely.

TWO WAYS, AND THEY ARE NOT EQUIVALENT.  `properties["using"] = address` is
already set where the USING is processed, so `u[3].get("using")` is available
today -- but it is a snapshot taken at that moment and stale in exactly the
way `u[2]` is, so it buys nothing.  Giving the USING statement a real `pos1`
is the one worth having, because `adjust` updates
`entry2["properties"]["pos1"]` as it slides statements, so a USING that had
one would track the layout instead of freezing at pass 1.

Note also that both bases are listed for each card -- 544 and 8812 for the
FAILEXEC three, 3160 and 3356 for the STM1 nine -- so the arm is seeing two
candidate registers and failing on both, not picking the wrong one.

155 said that giving a USING statement a real `pos1` is "the one worth having,
because `adjust` updates `entry2["properties"]["pos1"]` as it slides".  Checked
in the source rather than assumed, and it is wrong.

`scratch` is appended to in ONE place, inside the code-emitting path:

    sects[sect]["scratch"].append(newScratch)
    properties["scratch"] = newScratch

A USING emits nothing and never reaches it, so it has no scratch entry, and
`adjust` -- which walks `scratch` -- never touches its properties.  A `pos1`
set at the USING handler would be a pass-1 snapshot that never moves again:
exactly as stale as the `u[2]` it was meant to replace, and worth nothing.

    SO BOTH OF 155's TWO WAYS ARE DEAD.  `properties["using"]` is stale, and a
    `pos1` on a statement outside `scratch` would be stale the same way.

WHAT WOULD ACTUALLY WORK is to put USING statements INTO the sliding -- a
zero-length scratch entry per USING, so `adjust` moves them with everything
else and their location stays true as instructions shrink around them.  That
is a design change to the collect pass, not a line, and it wants deciding
rather than trying: zero-length entries would appear in a structure whose
other consumers all assume a length, and `optimizeScratch` itself iterates
over it.

    Which may be why the arm was written the way it was.  Reading `u[2]` and
    hoping is what you do when there is no live location to read, and the real
    defect may be that the shortening runs at the end of pass 1 at all rather
    than after a pass in which everything has settled -- which is where 146
    came out, three corrections ago.

This is the sixth conclusion in this section that measurement or a source read
contradicted.  Every number in 144 through 155 came from a run and can be
relied on; every sentence explaining one should be re-derived before it is
acted on.

Build this first, before investigating anything in BILDNEW5.  Everything below
in this section was found in minutes with it and would have taken hours
without.

BILDNEW5 IS NOTHING BUT `COPY` CARDS, so dropping all but the first few from a
COPY of the source gives a module that reaches the code you care about and
assembles in seconds:

    KEEP={"MACSMITH","PSA","HISAM","FAILEXEC"}          # 10 seconds
    KEEP={... ,"STM0","STPMEM","INTHNDLR","STM1"}       # 15 seconds
    for line in open("BILDNEW5.asm"):
        f=line[:71].split()
        if f[:1]==["COPY"] and f[1] not in KEEP: continue
        keep.append(line.rstrip("\n"))

against ten to forty minutes for the whole module.  Assemble it with
`--tolerable=255` and no `--compare`.

THE CAVEAT, AND IT IS A REAL ONE.  The cut-down module has 2068 UNDEFINED
SYMBOLS -- everything the dropped members would have defined.  The object code
as a whole is meaningless and this is not a way to assemble members standalone.

    What survives is exactly the question this section keeps asking: whether a
    given instruction takes the short or the long form.  That decision depends
    on the operand's distance from its base, and for the cards in question both
    ends are defined WITHIN the members kept -- KFINDIRW and its `USING *,0`
    are both in STM1, FAILBRTN and FAILDATA both in FAILEXEC.  Check that
    before trusting it for a new card: if the operand or the base comes from a
    dropped member, the rig will tell you nothing.

VERIFY AGAINST THE REAL MODULE BEFORE COMMITTING, always.  The rig is for
iterating; BILDNEW5 itself plus both harnesses is what decides.  Every fix in
157 and 158 was found in the rig and confirmed the long way.

Both found in the cut-down module of 157 and confirmed against the real one.

ROUNDING, not refusing an odd distance.  `L R7,FAILBRTN` at FAILEXEC's SRN
044000AB measures SEVEN halfwords from its base when `optimizeScratch` runs
and SIX in the finished layout -- FAILBRTN follows a `DS 0F` whose padding
depends on what precedes it, and that changes as instructions ahead of it
shorten.  Seven is not a whole number of fullwords, so the unit test rejected
an instruction the original assembles short, 1F0C.  The encoder itself rounds
up -- `dSRS = (dSRSa + dUnitizer - 1) // dUnitizer` -- and this pass only
decides REACHABILITY; `forbiddenSRS` still refuses a genuinely unaligned
displacement later, with settled numbers.

A LIVE LOCATION FOR `USING *`.  `*` is a place, not a symbol, so it cannot be
re-evaluated; the snapshot beside it is stale by however far the layout has
moved.  STM1's is captured at 3160 where the compile pass puts it near 2936,
so `ST R7,KFINDIRW` measured a NEGATIVE displacement from its own base and was
skipped -- eight instructions hung on that, KFCON1 through KFCON16.

    A USING EMITS NOTHING, so the next scratch entry appended in its section
    begins at exactly the USING's own address, and `adjust` keeps that entry's
    `pos1` current.  Recording the index at capture gives the arm a live
    location without putting USINGs into `scratch` -- which 156 wanted and
    which would have been the larger change.

    So 156's conclusion held: a `pos1` on the USING itself would have frozen.
    The way round it was to borrow someone else's.

BILDNEW5 across the three states:

                            v4      +round   +live
        byte-identical    5563      5655     5665
        wrong value       1402      1312     1311
        TOO LONG            12        10        2
        too short            4         4        4
        past end            36        28        4
        missing            348       308      107

SIX CARDS LEFT, five of them branches:

    024800AB  BVC 6,STM1270    orig DE09      ours CEF0006A   too long
    048500AD  BCB B'000',*     orig D806      ours D80001E6   too long
    042100AB  BNC STMMAIN1     orig CEF70816  ours DE56       too short
    053500AB  BZ  POLL94       orig C4F70036  ours DCD8       too short
    181000AB  B   PURGSAVF     orig C7F70036  ours DFD8       too short
    176300AC  STH R2,SECOND##  orig BAF10037  ours BADD       too short

Branches are decided by the two PC-relative arms, not by the USING one.  An
observation to check rather than act on: BVC and BCB are in
`srsBranchOperations`, but both of those arms test `branchAliases or "BC"`,
which excludes them.

Measured in the cut-down module, not reasoned about.  Recorded because the
obvious next move does NOT work and someone will otherwise try it.

WHAT BVC LOOKS LIKE.  `BVC 6,STM1270` at SRN 024800AB, in the original at
00B8C reaching STM1270 at 00B8F -- three halfwords, nothing like out of range
-- and assembled DE09.  Our long form spans the same distance as displacement
0x6B from a base.  Note the SHORT form's first byte is DE against our CE, so
the two forms do not share an opcode; this is the FORM selector, not a
displacement change.

REFUTED: adding `srsBranchOperations` to the two PC-relative arms.  Both test
`branchAliases or "BC"` and neither admits BVC or BCB, which looks like the
whole story and is not.  With both arms widened to include them, the rig
produces CEF0 006B -- BYTE FOR BYTE UNCHANGED.  Do not spend time on it again.

WHAT IS MEASURED ABOUT IT:

    op=BVC  ambiguous=True  section='GPCIPL'  value=3045  pos1=6082

so the entry IS marked ambiguous, the target resolves to halfword 3045, and
the card sits at 6082 bytes = 3041 halfwords.  The forward arm's own formula,
`value - pos1//2 - 1`, gives 3 -- inside srsFloor..srsCeiling by a mile.  So
the arm would accept it if it ran.

TWO POSSIBILITIES REMAIN and the runs so far do not separate them:

  - the arm is not reached, something earlier in the chain taking the entry
    first.  `if "B2" in ast: ... if b2 in [4,5,6,7]: ambiguous=False; continue`
    is the suspicious one, because `6,STM1270` could read as B2=6 -- but the
    trap above sits AFTER that test and still printed, so it did not fire
    THIS time;
  - or the arm runs, `adjust` shortens the entry, and the ENCODER still picks
    RS.  optimizeScratch shortening is necessary, not sufficient.

    Distinguish them by printing inside `adjust` for this SRN.  One rig run.

AND BCB IS A DIFFERENT MATTER AGAIN.  It is not in `argsSRSandRS` at all --

    BVC  argsSRSandRS=True   BCB  argsSRSandRS=False

-- so it is never marked ambiguous and `optimizeScratch` skips it at the top
of the loop, whatever the arms say.  Whether it BELONGS in that table is a
question about the instruction, not about this pass, and wants the POO.

THE FOUR TOO-SHORT ONES are untouched by any of this and remain what 148 and
149 describe: ours shortening where the original did not, three of them
branches carrying F7 in the original, and one -- STH at 176300AC -- not a
branch and predating all of today's work.

WHY.  SETTLED, and it is the second possibility.  With both arms widened and a trap in the forward one, the rig prints "forward arm REACHED op=BVC d=3 inrange=True len=4" and then "adjust() CALLED" -- so the arm runs, the displacement is 3, and the entry IS shortened to two bytes.  The output is still CEF0 006B, so THE ENCODER DECLINES IT DOWNSTREAM.  optimizeScratch shortening is necessary and not sufficient, and BVC work belongs in the encoder SRS arm rather than in this pass.  Note that arm names BVC explicitly -- "operation not in (BC, BCF, BVC, BVCF)" -- and applies srsBranchCeiling 54 to it, so what to look at is what d comes out as THERE, not here.

`BVC 6,STM1270` assembles DE09 now.  159 recorded two candidates as REFUTED --
widening the shortening arms, and correcting the encoder -- and both records
were honest and both were wrong in the same way: each is necessary and neither
is sufficient.  Testing them one at a time is what hid it.

THE ENCODER MEASURES TO THE WRONG THING.  By the SRS decision, `d2` has been
replaced by its offset from the USING's base, so `uUnhashedValue` is the
distance to that base -- 107 halfwords here, from `USING *,0`.  A branch's
short form is PC-RELATIVE, and the original's DE09 is (2 << 2) | 01: a
displacement of TWO from the instruction counter, with 01 the form selector
for BVCF.  `originalD2` still holds the address before the base register was
substituted, so measure from `icSRS` as the non-USING path already does.

AND THE SHORTENING PASS MUST ADMIT THE OPERATION.  Both PC-relative arms test
`branchAliases or "BC"`; BVC, BCF, BCB and BCTB are in `srsBranchOperations`
instead, so the entry stays four bytes and the encoder's SRS arm -- which
requires `len(data) == 2` -- cannot fire however right its arithmetic is.

    A NOTE ON 107 AND 108.  It was asked whether 107 being almost 2 x 54 is a
    coincidence, srsBranchCeiling being 54.  It is: 107 is 3045 - 2938,
    target minus USING base, both fixed by the source.  It would NOT have been
    a coincidence if this branch's offset were in fullwords, since (107+1)//2
    is exactly 54 and would sit precisely on the ceiling -- but the original's
    own encoding settles the unit.  DE09 means displacement 2 with the card at
    0B8C and the label at 0B8F, and 2 halfwords is the distance; 2 fullwords
    would put the target at 2961 rather than 2959.  Halfwords, so dUnitizer 1,
    so the near-miss is inert.  Worth remembering if a branch ever fails at
    exactly the boundary.

BILDNEW5:

                            before   after
        byte-identical        5665    6443
        wrong value           1311     535
        TOO LONG                 2       0
        too short                4       4
        addresses agreeing    1249    6629   of 6982
        past end of listing      4       0
        missing                107      30

95% of cards now sit where the original put them, and no instruction is the
wrong length except the four that are too SHORT.

VERIFIED WIDELY, because this is the broadest change of the series: admitting
four more operations to the shortening arms affects every module.  Corpus
267 MATCH, 4 MATCH?, 1 DIFFERS with no module changing class; RUNASM 205/205
over an identical module set.

WHAT IS LEFT is the four too-short cards of 148 and 149.  No amount of further
shortening reaches them -- they are already shorter than the original -- so
they are a different question from everything solved in 157 through 160.

First look at the wrong-value pile since the layout came right.  Until 160 it
was mostly drift and unreadable; now 501 OF THE 535 SIT AT ADDRESSES THAT
AGREE, so they are real.

    LA   127     BAL  49     ZH   18     TH   16
    STH   70     L    23     B    18     ST   15
    LH    58     ISPB 22     BZ   13     IAL   9

    AB   454     AC   78     AF    2     AD    1

and they look like this:

    020700AB  LA R4,STMWAIT    orig ECF0 1988   ours ECF3 1DF6
    022700AB  LA B1,COMSVC     orig E9F0 3254   ours E9F3 36C2
    027100AB  LH R4,SVCO       orig 9CF7 0A49   ours 9CF3 0058
    044200AB  L  R6,BUMPWRDN   orig 1EF0 17C2   ours 1EF3 1C30
    048800AB  L  R7,SVCN+2     orig 1FF7 0AF0   ours 1FF3 005E

THE OPCODE AND THE REGISTER ARE RIGHT EVERY TIME; the second byte differs.
That byte is 0xF0 | addressing | base, so what is wrong is WHICH BASE REGISTER
and WHICH ADDRESSING MODE, not the arithmetic of the displacement.  We reach
these through base 3 with the addressing bits clear where the original uses
base 0, or base 3 with AM set.

    This is a different question from everything in 144 through 160, all of
    which was about the LENGTH of an instruction and the distance to its
    operand.  Nothing here is a length: every one of the 535 is the right
    size.

    `LA B1,COMSVC` appears four times in the first dozen with identical
    object code each time -- E9F0 3254 against our E9F336C2 -- so a single
    wrong decision is being repeated, not 535 separate ones.  Start there and
    with the member concentration: 454 of the 535 are in one member.

Note 34 of the 535 are NOT at agreeing addresses and are downstream of the
four too-short cards; do not read those until those four are settled.

`findB2D2` capped a candidate register's displacement at 4096:

    d = d2 - e[0]
    if d >= 0 and d < 4096:

so any symbol further than that from every active USING found NO base and fell
back to addressing relative to the section with B3.  Raised to 0x10000, which
is the width the AM=0 form's second halfword actually has.

    LA R4,STMWAIT    orig ECF0 1988 -> 1DF6      ours ECF3 1DF6
    LA B1,COMSVC     orig E9F0 3254 -> 36C2      ours E9F3 36C2
    L  R6,BUMPWRDN   orig 1EF0 17C2 -> 1C30      ours 1EF3 1C30

THE TARGET IS IDENTICAL IN EVERY CASE and only the encoding differs, which is
what made this hard to see as a fault at all.  What gives it away is that
1DF6-1988, 36C2-3254 and 1C30-17C2 are all exactly 046E -- FAILDATA, the base
FAILEXEC's `USING FAILDATA,B0` establishes.  The displacements the original
uses are 6082, 12884 and 6082: past 4096, inside 16 bits.

    AND IT IS NOT COSMETIC.  Nothing guarantees B3 holds the section origin at
    run time.  Same argument as FIOCGR's -- the linker will not move anything
    to make our assumption true.

BILDNEW5 6443 byte-identical to 6540, wrong values 535 to 438.  Corpus and
RUNASM unchanged, which matters more here than usual: `findB2D2` is on the
path of every instruction that names a symbol.

THE RIG HAD TO GROW, and the way it failed first is the useful part.  Run
against 157's FAILEXEC cut-down, `LA B1,COMSVC` assembled to ZEROES -- COMSVC
lives in COMDATA and STMWAIT in REALEXEC, both dropped, so the rig was being
asked about symbols it did not have.  157 warns about exactly this and it
still nearly went unnoticed, because zeroes look like an answer.

    CHECK THAT THE TARGET IS DEFINED before believing the rig.  Keeping
    everything through REALEXEC plus COMDATA reproduces this fault in 23
    seconds.

WHAT REMAINS is 438 wrong values, still led by LA 98, STH 54, BAL 48, ISPB 44.
The same shape of question -- which base, which addressing mode -- but not the
same answer, since these all had a base within 4096 and still came out wrong.

The 438 that remain after 162 are 395 whose SECOND BYTE differs and nothing
else, and 345 of those differ in ONE BIT:

    orig F7 -> ours F3   296        orig FF -> ours FB    49

Same base register, different addressing bit.  Decoded on `LH R4,SVCO` at
0029F: the original is 9CF7 0A49, and 0x0A49 is 0x800 | 0x249.  0x249 is 585,
`icRS` is 0x29F + 2 = 673, and 673 - 585 is 88, which is SVCO.  So the original
takes the RS AM=1 form with a BACKWARD PC-relative displacement, the 0x800 bit
being the sign.  We emit AM=0 with the absolute address instead.

THE ARM THAT WOULD DO IT IS GUARDED BY AN OPERATION LIST:

    elif (operation in ["BC", "BIX", "BAL", "BCT"] or
          (operation in ["OST", "LPS", "SSM"] and not extrnBase)) and
            x2 in [None, 0] and d1 > -2048 and d1 <= 0:

and the comment above it already generalises -- "Nothing about this encoding
is peculiar to branches: a section-relative reference to a lower address is
written AM=1 with the `i` bit and the magnitude, whatever the operation."

    THAT GENERALISATION IS WRONG, AND THE LIST IS LOAD BEARING.  Dropping it
    -- keeping only `not extrnBase` -- fixes the BILDNEW5 cards and BREAKS TEN
    MODULES that are byte-exact today: DCICYC by 186 bytes, FCMBOOT, FCMCSYNC,
    FCMISYNC, FCMNINIT, FCMLINIT, FCMSSYNC, FCMTRACE, FCMTSYNC, FIOSVCP by
    three to nine each.  Reverted.

AND IT IS NOT THE OPERATION THAT DECIDES.  The same mnemonic goes both ways:

    BILDNEW5  L R7,SVCN+2    orig 1FF7 0AF0   AM=1, backward
    FCMTRACE  L R3,TPSATENT  orig 1BF3 ....   AM=0, absolute

so no list of mnemonics can be right, however long.  Something about the
OPERAND or its section decides, and that is what to find.  TPSATENT sits at
offset 0 of its section, which is worth checking first -- a displacement of
exactly 0 may be the discriminator, since `d1 <= 0` admits it and the sign bit
cannot express "minus zero" distinctly.

WHAT THE EXPERIMENT WAS WORTH.  BILDNEW5 went 12330 to 12078 bytes mismatched
with it, so the direction is right and only the condition is wrong.  Both
numbers are with everything else of 160 through 162 in place.

163 claimed the same mnemonic goes both ways, citing FCMTRACE's
`L R3,TPSATENT` as an AM=0 case against BILDNEW5's AM=1 `L R7,SVCN+2`, and
concluded that no list of mnemonics could ever be right.  THE CITATION IS
WRONG.

    ###X### op=L  extrnBase=True  extrnD2=True  d1=-32
    ###X### op=LH extrnBase=True  extrnD2=True  d1=-2

`extrnBase` is TRUE for every TPSATENT card -- TPSATENT is on FCMTRACE's
`EXTRN` list at line 120 -- so the guard sees it and the widened condition
excluded it just as the narrow one did.  Those cards cannot have changed.

WHAT WENT WRONG WAS READING THE LISTING.  A mismatch is printed BEFORE the
card it belongs to, as AMCPTEST shows back in 150, and the diagnosis used
`grep -B3`, which shows the three lines PRECEDING each mismatch -- that is,
the cards it does NOT belong to.  So the `F7 vs F3` was attributed to
`L R3,TPSATENT` when it belongs to a card further down that was never
identified.

    SO THE COUNTEREXAMPLE IS WITHDRAWN and with it the conclusion that no
    mnemonic list can work.  That may still be true; nothing here shows it
    either way.

WHAT STANDS FROM 163: the ten modules really do break -- that came from the
sweep, not from the listing -- and the direction is right, BILDNEW5 going
12330 to 12078.  What is unknown again is WHICH cards break in those ten and
why, and `grep -A` rather than `-B` is how to find out.

    Whoever picks this up: re-read those ten with the mismatch attached to the
    card AFTER it.  DCICYC at 186 bytes is the loudest and the best place to
    start.

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

Doing what 164 said to do.  The convention first, established from the bytes
rather than assumed: OURS is printed first in a mismatch and the card FOLLOWS
its mismatches.  DCICYC line 1941 reads `C7F7 0BB5` and the three lines above
it are `F7 vs F3`, `0B vs 01`, `B5 vs 63` -- our bytes, in order, against the
original's.  So `grep -A`, and 163's counterexample was indeed a misread.

DCICYC'S FIRST THREE NAME THE CULPRIT:

    00516  ours C7F7 0BB5   orig C7F3 0163    BC$  07,#@LB76
    00518  ours C7F7 0B7F   orig C7F3 019B    BC$  07,#@LB87
    0051A  ours C7F7 0B4E   orig C7F3 01CE    BC$  07,#@LB95

`BC$`.  THE `$` SUFFIX MEANS AM=0 WITH AN ABSOLUTE DISPLACEMENT -- it is the
whole point of the suffix, and `forceAM0` is set from it -- so the backward
AM=1 form contradicts the mnemonic.  The old operation list excluded it by
ACCIDENT: `BC` is in the list and `BC$` is a different string.

    Which is why the list looked load bearing in 163 and is not, quite.  What
    is load bearing is `forceAM0`, and the list was standing in for it.

FCMTRACE's last byte is a second, unrelated case: `ST@# R4,0(R2)` came out
34F6 0800 against 34F6 1800, losing the indirect bit, because the arm calls
`generateRS1(..., 0, 1, ...)` with ia and i HARDCODED and overwrites what the
suffixes asked for.

So the guard is `not forceAM0 and not ia and not i` -- a statement about the
instruction, not a list of mnemonics -- and all ten modules return to 0 bytes
mismatched.  BILDNEW5 6540 to 6574 byte-identical, 438 to 404 wrong values.

    A CORRECTION TO 163 WHILE HERE.  It said no list of mnemonics could ever
    be right because the same one goes both ways.  164 withdrew the evidence;
    this entry supplies the real reason, which is different: a mnemonic list
    CAN express this, but only by enumerating every suffixed spelling, which
    is what `forceAM0` already does properly.

WHAT REMAINS: 404, still led by LA 97, BAL 48, STH 47, ISPB 28.  Only 34 of
the 438 were this arm, so the bulk of the F7-vs-F3 population has a different
cause and has not been diagnosed at all.

Diagnosed, not fixed.  280 of the 404 are `orig F7 -> ours F3` and another 32
are `FF -> FB`, and they are all one thing.

THE ORIGINAL USES A FORWARD PC-RELATIVE AM=1 DISPLACEMENT where we emit AM=0
with the absolute address.  Arithmetic on three of them, `icRS` being the
instruction's address plus two:

    LA R0,STM4      orig E8F7 07B4    0D26 + 07B4 = 14DA
    C  R0,SHIFTDAT  orig 10F7 0764    0F98 + 0764 = 16FC
    LA R5,ERRPLA    orig EDF7 0004    1007 + 0004 = 100B

so the second halfword is the distance from the updated instruction counter,
and every one of them fits the eleven bits the form has.

WHY WE DECLINE IT, instrumented at the AM decision:

    ###A### forceAM0=True usingB2=False ib2=3 b2=None unhash=5554 icRS=6780
            d1=-1226 len=4

`forceAM0` is TRUE, and it is set here:

    b2, newd2 = findB2D2(d2)
    if b2 == None:
        if newd2 == None:
            newd2 = d2 - symtab[sect]["value"]
            if newd2 >= 0 and newd2 < 4096 and newd2 < sects[sect]["used"] // 2:
                b2 = 3
                d2 = newd2
            else:
                section, offset = unhash(d2)
                if section != None:
                    forceAM0 = True

    A SECOND 4096 CAP, and a different one from the one 162 raised.  When no
    USING covers the operand AND its offset within its own section is 4096 or
    more, the section-relative fallback is abandoned and AM=0 is FORCED -- so
    the PC-relative arm below never gets to look, however well the distance
    would fit.  `unhash` says 5554 for this card, past the cap; the PC-relative
    distance is 1226.

WHAT MAKES THIS DIFFERENT FROM 162.  That cap was on the distance from a USING
BASE and the fix was simply that the field is wider than assumed.  This one is
on the offset within the SECTION, and raising it is not obviously right --
`newd2 < sects[sect]["used"] // 2` beside it suggests the intent was "is this
target inside the section we have built so far", which is a different question
from "does it fit the field".

    DO NOT JUST RAISE IT.  The right change is probably to let the PC-relative
    arm run instead of forcing AM=0, which is a reordering rather than a
    widening -- and 163 is the cautionary tale for changing this area without
    checking all ten of the modules that broke there.

The remaining 92 are not this: FB->F8 18, F3->F0 13, F8->F8 12, F3->F7 8,
FC->FC 8, F3->F1 6.  The F8->F8 and FC->FC pairs have the RIGHT second byte
and a wrong displacement, so they are a different fault again and worth
separating before either is chased.

Attempted, verified, REVERTED.  Recorded in full because the fix is most of
the way right and because the way it nearly slipped through matters more than
the fix does.

THE CHANGE.  166 identified `forceAM0 = True` being set when no USING covers
the operand and its offset within its own section reaches 4096, which stops
the PC-relative arm from ever looking.  Clearing that flag outright makes the
card assemble to ZEROES -- it is steering, not merely gating, and without it
nothing downstream claims the statement.  What does work is a second flag:

    sectionOverflowAM0 = (section == sect)     # set beside forceAM0
    elif (not forceAM0 or sectionOverflowAM0) and (x2 != None or ia or i or
          (not usingB2 and d1 >= 0 and d1 < 2048)):

so the PC-relative arm gets first refusal and AM=0 still catches everything it
declines.  `LA R0,STM4` assembles E8F7 07B4, the original's bytes, and a
sibling whose distance is 3558 correctly stays AM=0.

    BILDNEW5: 6574 byte-identical to 6789, wrong values 404 to 189.
    Corpus:   267 MATCH, 4 MATCH?, 1 DIFFERS -- NO MODULE CHANGED CLASS.

AND RUNASM BREAKS: 57 MODULES REPORT MISMATCHES, two to six bytes each --
ACOS, ACOSH, ATANH, CASPV, CASRPV, VV5SN and fifty-one more.  The previous run
reports none.  So the two harnesses DISAGREE about this change, which is the
whole reason both exist, and the corpus alone would have blessed it.

    HOW IT NEARLY PASSED.  The failure check used through most of this
    session is `grep -ciE "error|fail|traceback"`, and RUNASM does not use any
    of those words -- it prints "N bytes mismatched".  It returned 0 while 57
    modules were broken.  What caught it was the word count: a clean run is
    EXACTLY 205 words, module names and nothing else, and this one was 832.

    USE `grep -c "bytes mismatched"` ON THE RUNASM OUTPUT, and check the word
    count is 205.  Every earlier "205/205, failures 0" in 144 through 165 was
    confirmed by the word count as well, so those stand -- but the grep alone
    proves nothing and should not be trusted again.

WHAT TO DO WITH IT.  The direction is right and the corpus evidence is strong;
something about the RUNASM modules distinguishes them and has not been looked
at.  ACOS at two bytes is one instruction and is the place to start, with the
mismatch attached to the card AFTER it per 165.

167 recorded the fix as breaking RUNASM.  ACOS at two bytes, read forward,
gives the discriminator and it is not about the operation at all.

    ACOS      SVC AERROR1   orig C9FB 0074   ours C9FF 0022
    BILDNEW5  LA  R0,STM4   orig E8F7 07B4   ours E8F3 14DA

opposite ways round.  THE FALLBACK HAS THREE TESTS AND TWO MEANINGS:

    if newd2 >= 0 and newd2 < 4096 and newd2 < sects[sect]["used"] // 2:

  - failing the 4096 means the target is too far into its section to be
    addressed that way, and PC-relative IS the right answer.  BILDNEW5's
    target is at 5554; icRS + 07B4 lands exactly on 14DA.
  - failing the `used` test means we have not BUILT the section that far yet
    -- an ordinary forward reference -- and the original keeps AM=0.  ACOS's
    target is at 116, nowhere near 4096.

Both landed in the same `else` and both got `forceAM0`.  Gate the PC-relative
retry on `newd2 >= 4096` and each goes its own way.

    BILDNEW5: 6574 byte-identical to 6789, wrong values 404 to 189.
    RUNASM 205 words, 0 mismatches.  Corpus 267 MATCH, no class change.

WHAT REMAINS: 189, led by LA 37, ISPB 24, STH 24, BAL 14, and the four
too-short of 148.  Down from 1402 when the wrong-value pile was first readable
at 160.

    AND THE HARNESS LESSON, WHICH IS THE DURABLE PART.  The corpus said this
    change was free at BOTH stages -- 267 MATCH, no module changing class --
    while RUNASM said 57 modules were broken at the first.  Neither harness
    alone would have got this right, and it is the first time in this section
    they have actually disagreed rather than agreed.

166 lumped the wrong-value pile together and it was right to at the time; it
no longer is.  166 of the 189 sit at agreeing addresses, and they divide:

    115   the second byte, base or addressing mode
     40   the DISPLACEMENT ONLY, and always by exactly one
     21   the FIRST byte, which is opcode and R1
     13   two-byte cards

TAKE THEM SEPARATELY.  Three have a named cause already.

(1) OFF BY ONE, 40 cards -- 31 of them ours one LOW, 9 ours one HIGH, never
    any other amount:

        SSM STOPMASK   orig 88FF 0657   ours 88FF 0656
        B   RETRNJOB   orig C7F7 0501   ours C7F7 0500
        LA  R2,JOBADDR orig EAF7 003F   ours EAF7 0040

    All AM=1, so all PC-relative, and the two directions split by which way
    the branch goes -- the backward ones read one low and the forward one
    reads one high.  That is an `icRS` convention, `icRS - d2` against
    `d2 - icRS`, disagreeing by a halfword about where the instruction counter
    stands.  Should be the cheapest of the four.

(2) R1 IS BEING DROPPED, 21 cards, and it is LDM and STDM every time:

        LDM  R3,EXTDATA3   orig 6BF8 0140   ours 68F8 0140
        LDM  R1,EXTDATA1   orig 69F8 013C   ours 68F8 013C
        STDM R1,EXTTEMP    orig 91F8 0148   ours 90F8 0148

    The low nibble of the first byte is R1 and we emit zero.  Both are in
    `impliedR1`, which exists for mnemonics that supply R1 THEMSELVES -- and
    the original plainly encodes the register the source names.  So either
    they do not belong in that table, or a written register must override the
    implied value.  Check the POO before deciding which.

(3) `BCB B'000',1` ASSEMBLES D8FE FOR D806, 13 cards, all the same statement.
    The byte is (displacement << 2) | form, form 10 for BCB, so the original
    is displacement 1 and ours is 63.  The operand is a LITERAL 1, not a
    label, so this is the backward negation being applied to a number that was
    never an address -- `0x3F & -d` on a 1 gives 63.

(4) THE SECOND-BYTE 115 are not one thing either.  F7->F3 47 and FF->FB 9 are
    the same shape 166 described.  But F3->F7 is EIGHTEEN CARDS THE OTHER WAY,
    ours choosing PC-relative where the original is absolute:

        LA G4,MCHO   orig ECF3 0040   ours ECF7 0888

    MCHO is at 0x40, a fixed machine location rather than anything
    section-relative, so 168's fix over-applies to symbols that are absolute
    by nature.  Eighteen cards is the price of the 215 it fixed, but it is a
    price and it is not recorded anywhere else.

    FB->F8 18 and F3->F0 13 are a base-register difference with the
    addressing bits agreeing, and `ISPB 0,MSG257A` -- orig E8FB 504D, ours
    E8F8 3B73 -- reaches into GENLINES from outside, so those are likely
    cross-section and want looking at with the section in mind.

169 called the 40 off-by-one cards "an `icRS` convention... the cheapest of
the four".  It is not a convention and it is not an encoding fault at all.

THE ARITHMETIC IS RIGHT EVERYWHERE.  The rule is `d = target - (address + 2)`
and the original obeys it on all three sampled cards:

    SSM STOPMASK    1E80 - 1829 = 0657
    B   RETRNJOB    1E7B - 197A = 0501
    LA  R2,JOBADDR  1EB6 - 1E77 = 003F

and so do we.  What differs is the ADDRESSES, which the resolved column shows
plainly:

    SSM STOPMASK    ours resolves 1E7F, original 1E80   -- target one early
    B   RETRNJOB    ours resolves 1E7A, original 1E7B   -- target one early
    LA  R2,JOBADDR  ours AT 01E74, original 01E75       -- instruction ditto

    ONE MISSING HALFWORD, SEEN FROM BOTH SIDES.  Where the TARGET has moved
    early the displacement reads one low; where the INSTRUCTION has moved
    early it reads one high.  That is the whole of the 31-versus-9 split, and
    nothing in the encoder needs changing.

WHERE IT COMES FROM is the four too-short cards of 148 and 149 -- we emit two
bytes where the original emits four -- and JOBADDR resolving to 1EB6 in BOTH
builds says a halfword is regained before it, so the drift opens and closes
rather than accumulating.

    SO THE 40 ARE NOT A FAULT TO FIX.  They will disappear when the four
    too-short cards are settled, and any effort spent on them before that is
    spent twice.  169's ordering was wrong: this is not the cheapest of the
    four, it is not one of the four.

THAT LEAVES THREE, and 169's other three stand -- LDM/STDM dropping R1 (21),
`BCB B'000',1` negating a literal (13), and the second-byte 115 of which 18
are 168 over-applying.  The R1 one is now the cheapest and the best documented.

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

