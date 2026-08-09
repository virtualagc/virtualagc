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
factor and no multi-valued DC anywhere.  Assembly-time division was returning a
Python float for years without moving the score either.  All six can be
completely broken while it stays at 205 of 205.  Run
ASM101S/macroTests/regressionMacros.sh as well; it takes seconds and it is the
only check that covers the conditional-assembly language itself.

FCOS IS WHERE THE WORK IS.  Of OI340600's 225 modules, assembled against MLIB80,
before this stretch of work began and now:

                    before   after
    OK                  21      51
    ERRORS              33     161
    CRASH              170      13
    HANG                 1       0

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

NEXT STEPS, in order.  The previous list's first item -- read the diagnostics
in bulk -- was done on 2026-08-09 and is written up above; it moved OK from 25
to 51.  What follows is what it left.

  1. GIVE "Eval error type 3" A REAL MESSAGE, then fix what it turns out to be.
     It is the top of the list at 62 modules and 3455 occurrences, and it says
     nothing whatever about what failed to evaluate.  This is the same shape as
     "Unrecognized line", which hid 35 distinct causes until it was made to
     name the operation and then resolved in a single run.  Do the message
     first; do not try to guess the defect from the call site.

  2. IMPLEMENT THE IOP/MSC INSTRUCTION SET, which is where 60 of the 225
     modules are stuck and which was MISDIAGNOSED HERE as a corpus gap of
     missing macros until the user corrected it on 2026-08-09.  The
     '#'-prefixed operations -- #MIN, #MOUT, #BU, #WAT, #LBR, #DLYI, #CMDI,
     #RDS and the rest -- are INSTRUCTIONS in the AP-101S instruction set, not
     macros, and ASM101S already knows all 96 of them by name in
     model101tables.py's argsMSC and argsBCE.

WHAT IS MISSING IS THEIR ENCODING.  model101tables.py comments that an
     opcode of -1 marks "a special case in terms of how the code is
     generated", which reads as though a function elsewhere does the work.
     For these two families no such function was ever written, and the two
     families fail in DIFFERENT ways.

     THE '@' FAMILY IS SILENTLY WRONG.  model101.py reaches argsMSC, calls
     commonProcessing(2) and then emits bytearray(4) -- four zero bytes,
     with no opcode consulted.  "@BU X" and "@L X" are different instructions
     and both assemble to 0000 0000.  Five modules currently counted OK use
     them -- FCMINMSC, FCMSFCAM, FCMSVOTE, FIOCDATS, FIOMMMSC -- so the OK
     column overstates what is correct by at least that many.

     THE '#' FAMILY NEVER GETS THAT FAR, for a separate reason worth fixing on
     its own:  model101tables.py:213 says
     "instructionsWithoutOperands = argsBCE", so all 35 have their operand
     field DISCARDED before parsing.
     The document plainly gives them operands -- #MIN and #MOUT take
     "Displacement, Transfer Count", #MINC and #MOUTC take "IUA, Command" --
     so that declaration is simply wrong.  With no operand there is no AST,
     and they fall through to "Unrecognized operation".  This is why no OK
     module uses one:  they always fail loudly.

     THE DECISIVE POINT, if anyone doubts that these are unimplemented rather
     than handled somewhere else:  THE OPCODE VALUES ARE NOWHERE IN ASM101S.
     All 96 table entries are -1, no mnemonic is special-cased by name in
     model101.py, and model390.py is an explicit placeholder for speculative
     System/390 support.  The information needed to encode them is not in the
     program, so it cannot be generating correct code for them by any route.

     They are defined in Appendix A, "IOP MSC Instruction Repertoire", of the
     Shuttle GPC Software Model AP-101S document.  Its text is extracted to
     ASM101S/AP-101S-instruction-set.txt -- grep that rather than the 95 MB
     PDF.  mscAll is also too narrow: it rejects two-operand forms such
     as `0,0` and `IUA,IMMED` that bceAll accepts.  Do NOT widen it on its
     own, since that only converts a loud failure into silent zeros.

     CNOP is a genuine unimplemented pseudo-op and is separable and small.  A
     handful of '$'-suffixed names -- LA$, B$, IAL$, L$, BAL$, ST$, BC$,
     STH$, LH$ -- are still unaccounted for: they are not in the instruction
     tables and not in MLIB80, and nobody has yet established what they are.

  3. RE-READ THE DIAGNOSTICS after step 1, and expect the ordering to have
     changed completely, as it did this time.  Separate the modules that report
     undefined operations from those that do not before drawing conclusions:
     the 60 blocked ones generate diagnostics that say more about the missing
     macros than about the assembler, and mixing them in distorts everything.
     fcos-diagnostics.py has no flag for that yet; it was done by copying the
     unblocked .diag files into their own directory.

  4. BORROW OI301700'S MACRO LIBRARY FROM OI340600, ~237 files, then sweep it.
     The user has never done this, so treat it as unexplored: the two versions
     are years apart and a macro that merely has the same name may not have the
     same definition.  Diff a few that DO exist in both before assuming the rest
     can be copied wholesale.  Check the result against the listings in
     ~/workspace/PFS/"OI301700 as received"/, which are primary evidence of what
     the original build actually produced.

  5. NOTHING IN FCOS IS VERIFIED, only assembled, and this is the gap that
     matters most for the phase goal.  51 modules now exit 0, which means the
     assembler did not complain; it does not mean the bytes are right.  RUNASM
     is verified because RUNLST exists to check it against.  The OI301700
     listings named above are the first primary evidence that could put FCOS on
     the same footing, and until something like that is in place the OK column
     is a much weaker claim than it looks.

  6. THE REMAINING 13 CRASHES, which are now a long tail: 7 of KeyError
     'preliminaryOffset' at model101.py:1287 with 2 of KeyError None at the
     same line, and four singletons including an AttributeError raised inside
     tatsu itself.  Worth doing to get the count to zero, but no longer the
     best use of a session.

  7. ASM101S IS SLOW.  DCICYC takes 861s and FIOPDISP 307s, dominated by
     re-parsing every line through tatsu on every pass.  It is what makes a
     sweep or a diagnostics run the better part of an hour.

  8. THE SMALLER, SEPARABLE ONES.  ORG is unimplemented and is a standing
     feature request from an outside user (#1333), which also carries a
     KeyError-None crash on "ST#1 EQU *".  DC cannot parse a hex literal with
     comma-separated groups, as in DC X'A92F0A3C,A2DFA000,0000A35B,A35DA5B2' --
     all 328 of FAZ2's diagnosed errors, and the same shape as the multi-valued
     DC defect already fixed, so look there first.  ASM101S.py raises IndexError
     when generated code runs past the end of a --compare listing instead of
     reporting it, which is what makes the six intentional RUNASM deviations
     look like crashes on a default regression run.  Created variable symbols,
     `&(SRC&UPDDSN&NAME)`, are the last AIF operands that still do not parse.

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

