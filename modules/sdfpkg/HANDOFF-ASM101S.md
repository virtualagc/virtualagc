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

THE ROOT CAUSE IS ALREADY DIAGNOSED, in virtualagc issue #1331, "Many bugs in
ASM101S macro processing".  READ IT BEFORE TOUCHING ANYTHING.  It is open, it is
the user's own analysis, and it goes considerably further than the traceback it
opens with.

MACRO KEYWORD PARAMETERS ARE BEING LOST.  A macro can take both positional and
keyword parameters; the positional ones survive and the keyword ones do not.
The trace for ACOS.asm shows AMAIN entered with an empty &SYSLIST when the
source says

    ACOS     AMAIN   ACALL=YES

and FPMSWTCH's PROGRAM is entered with [None] against a source line reading
PROGRAM TITLE='PROCESS SWITCH ROUTINE'.  Parameters spread over CONTINUATION
LINES are lost as well -- FPMSWTCH's IFPROC passes &P1 through &P50 across five
continuation cards, and they do not arrive.

THE CRASHES ARE DOWNSTREAM OF THAT, which is why there are so few distinct
signatures for so many files.  A macro that did not receive its arguments then
evaluates a conditional against whatever it did receive:

    AIF (&SYSLIST(1) LE 0 OR &SYSLIST(1) GE 07).INVALCC

where &SYSLIST(1) has become ',' -- a string, incomparable to a number -- and
expressions.py line 521 raises TypeError.  Do not fix line 521 by coercing the
comparison.  It is reporting a real defect upstream of itself, and making it
compare cleanly would convert a loud failure into a wrong assembly.

THE OTHER OPEN ONE IS #1333, a feature request for the ORG pseudo-op, from an
outside user assembling compiler-generated code.  It also carries a second,
separable defect: "ST#1 EQU *" crashes with KeyError None at model101.py:1237.
The remaining ASM101S issues -- 1317, 1320, 1324 through 1329, 1332, 1271 -- are
all CLOSED and are useful mainly as worked examples of how such a defect gets
pinned down.

THE BASELINE, measured 2026-08-08.  It has two halves and they are nothing alike.

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

FCOS IS WHERE THE WORK IS.  Of OI340600's 225 modules, assembled against MLIB80:

    OK        21     assembles, exit 0
    ERRORS    34     diagnosed errors, severity 255, no crash
    CRASH    170     a Python traceback
    HANG       1     FIOADCNS, 99.9% CPU, still going when killed at 120s

The 170 crashes carry only EIGHT distinct signatures, which is the encouraging
part -- this is a handful of defects seen many times, not 170 problems:

     91  TypeError: '<=' not supported, str and int   expressions.py:521
     39  KeyError: 'ast'                              model101.py:2207
     16  NameError: name 'expression' is not defined  expressions.py:570
     14  IndexError: bytearray index out of range     model101.py:1527
      5  TypeError: argument of type 'NoneType'       model101.py:1735
      3  TypeError: unsupported operand &, float/int
      1  KeyError: 'preliminaryOffset'                model101.py:1243
      1  KeyError: 'ICCLGTH'

OI301700 COULD NOT BE MEASURED AT ALL, and the reason is not the assembler.  Its
MLIB80 holds 41 files against OI340600's 278, and NOT ONE of them is a macro
definition -- every core macro the sources use, PROGRAM, IF, DO, PROC, EQUATE,
IFPROC among 237 others, is simply absent.  It also has no MACROFILES.txt, so
ASM101S stops immediately with "Cannot open ../MLIB80/MACROFILES.txt".  The user
confirmed on the day that OI301700 needs files borrowed from OI340600 and that
this has never yet been done.  Until it is, every OI301700 number is vacuous.

DO NOT "FIX" THIS BY GENERATING MACROFILES.txt THERE.  It was tried on the day.
makeMACROFILES.py runs happily and produces an index naming ZERO macro files,
because there are none to name, and ASM101S then loads no macros at all and
buries you in errors instead of stopping with one clear message.  The generated
file was deleted again for exactly that reason.  Borrow the macros first.

NEXT STEPS, in order.

  1. FIX MACRO KEYWORD-PARAMETER HANDLING, issue #1331.  This is the whole job in
     one item.  91 of the 170 crashes are the single TypeError it describes, and
     the KeyError 'ast' and NameError families sitting behind it are the same
     story a few frames later: a macro that never received its arguments.  Read
     the issue first, reproduce with --trace on ACOS.asm, where AMAIN is entered
     with an empty &SYSLIST against a source line reading AMAIN ACALL=YES, and
     the defect is visible in one screen.  Fix the loss, not the comparison at
     expressions.py:521 -- coercing that would turn a loud failure into a wrong
     assembly.  Continuation lines are part of the same item: FPMSWTCH's IFPROC
     passes &P1 through &P50 across five cards and they do not arrive.

  2. RE-RUN THE SWEEP AND SEE WHAT IS LEFT.  modules/sdfpkg/fcos-sweep.sh does
     all 225 in a few minutes and classifies each as OK/ERRORS/CRASH.  The
     numbers above are its output for 2026-08-08 and are the thing to beat.
     Expect the remaining signatures to re-sort themselves substantially once
     step 1 lands, so do not plan past this point in detail.

  3. BORROW OI301700'S MACRO LIBRARY FROM OI340600, ~237 files, then sweep it.
     The user has never done this, so treat it as unexplored: the two versions
     are years apart and a macro that merely has the same name may not have the
     same definition.  Diff a few that DO exist in both before assuming the rest
     can be copied wholesale, and expect to justify the choice later, since the
     corpus goal covers both PASS versions.

  4. FIOADCNS HANGS.  One module, 99.9% CPU, no output, still running at 120s.
     It is worth a look on its own because a hang is the one failure a sweep
     cannot survive -- this one blocked the whole run until it was killed, and
     the run reported DONE with 496 of 497 rows and no indication anything was
     missing.  Any sweep of this corpus needs a timeout.

  5. THE SMALLER, SEPARABLE ONES.  ORG is unimplemented and is a standing
     feature request from an outside user (#1333), which also carries a
     KeyError-None crash on "ST#1 EQU *" at model101.py:1237.  DC cannot parse a
     hex literal with comma-separated groups, as in
     DC X'A92F0A3C,A2DFA000,0000A35B,A35DA5B2' -- that alone is all 328 of
     FAZ2's diagnosed errors.  And ASM101S.py:1144 raises IndexError when
     generated code runs past the end of a --compare listing, instead of
     reporting it; that is what makes the six intentional RUNASM deviations look
     like crashes.

WHAT NOT TO DO.  Do not adopt asm101 to skip this: it has no &ASM101S and only
two mentions of GBLB, so all six of our gated RTL fixes would be lost, and
RUNASM's verified 205 of 205 would be traded for an unmeasured number.

