There is a more-extensive test possible of the integration of `sdfpkg` into `HAL_S_FC.py`, and we should look into it before considering any attempt at a C port and integration.  

In the directory ~/workspace/PFS/OI340600/ you'll find the entire source code for version OI34.06 of the Space Shuttle primary flight software (PASS).  The subdirectories APPLSRC/, SSSRC/, and INCL80/ in particular contain HAL/S source-code files.  The Python script `compilePASS`, which is in the PATH, but whose source code is in ../../yaShuttle/"Source Code"/PASS.REL32V0/ should there be a need to examine it, is used to compile all of the HAL/S files in OI340600.  The instructions for doing so are covered at anchor `#compilePASS` in the already-mentioned file HAL.html.  The files are compiled in an order which should insure that SDFs are created before they are needed.

The reason importing SDF's is important to me at the present time is not the improved speed of compilation I mentioned earlier &mdash; that was the <i>original</i> developers' presumed motivation &mdash;, but rather that after importing SDF's became common practice, many of the HAL/S files in PASS could no longer compile from TEMPLATEs alone.  The reason for that is presumably that the order in which TEMPLATEs are included is significant, whereas the order in which SDFs are included is not, and developers no longer took the proper care to have `D INCLUDE TEMPLATE` directives appear within the HAL/S files in a correct order. Duplicated `STRUCTURE` definition statements also became commonplace.  The sign of these things is that compilation of PASS source-code often fails with error codes of type DI11 and PM2, which I <i>hope</i> will disappear once SDF's are imported in place of TEMPLATEs.

One proviso: Before I understood that SDFs were expected to be included rather than TEMPLATEs, I managed to create a workaround that eliminated DI11 errors.  In this workaround, a preprocessor was created that could rearrange `D INCLUDE TEMPLATE` directives.  In order to properly test whether SDF inclusion eliminates DI11 errors, it's necessary to run `compilePASS` with its `--no-preprocess` switch.  If SDF inclusion is adequate for that, then `--no-preprocess` should be made the default in `compilePASS`.

The file OI340600/compilePASS.log captured the output messages from the last run `compilePASS` I made before moving on to other matters, and in it you can see which files had PM2 errors at that time.  Because the `--no-preprocess` switch was <i>not</i> used on that run, there were no files with DI11 errors.

One point to note: If `HAL_S_FC.py` is including SDFs but `HALSFC` is not, then the comparison by `HALSFC --test` of the PASS1 reports for the two will fail (because messages about included SDFs will differ), and this might cause the compilation to fail.  If so, `HALSFC` may need to be modified to change the way in which pass1.rpt is converted to pass1A.rpt and pass1p.rpt is converted to pass1pA.rpt.

# Findings

## The preprocessor was the wrong answer, and is now off by default

The proviso in the brief is settled: SDF inclusion is adequate, `--no-preprocess`
is now the default, and `--preprocess` is the opt-in.  This was supposed to have
been dropped when SDF import landed and simply never was.

`preprocessHALSFC`'s own header states the two premises it was built on — that a
template included by a template is not thereby included (DI11), and that "there
is no mechanism provided by the HAL/S compiler for dealing with multiple
inclusions of the same template" (PM2).  Both are true of the template path and
**false of the SDF path**.  `INCSDF`'s `DUPLICATE_NAME`/`SET_DUPL_FLAG` is
precisely the missing mechanism, and `ENTER_COMPOOL_VARS` entering the whole
declare chain — carrying symbols the COMPOOL itself got from its own includes —
is precisely transitive inclusion.  So the SDF path importing "too much" is not a
defect; it is the mechanism working.

Two related things were looked for and do not exist.  `EMIT_EXTERNAL` generates a
template by echoing tokens as they are scanned, with no suspension during an
include (checked at every `EXTERNALIZE` assignment), so a COMPOOL's template
necessarily carries its included text — there is no re-export filter to find, by
design.  And `IDENTIFY.xpl:610300`'s `IF I < PROCMARK THEN GO TO NOT_FOUND` is
what makes a match in an outer scope not a duplicate, which is what lets a
program re-include STRPDT inside a PROCEDURE after including COMPOOLs at outer
level.

By the end the preprocessor was doing harm.  CS2PAT's PL2 was a duplicate include
that `preprocessHALSFC` inserted, because it records only the
`D INCLUDE TEMPLATE X` form and is blind to CS2PAT's own `D INCLUDE SDF CSA_PDT:`
— the same blind spot that had to be fixed in the dependency scanner below.

One usability defect in it, if it is ever run again: it needs APPLSRC, SSSRC and
INCL80 all present, and with SSSRC missing it prints "Selected file … does not
exist" and calls `os._exit(1)`, which skips the stdout flush.  On a pipe the
message is lost and it looks like a silent failure producing an empty output
file.  Worth a flush.

## DQ7, which was the largest failure class, is issue #1281

STRPDT's R cards are `DECLARE X NAME X-STRUCTURE`: a NAME variable whose name
equals its own template's name.  That is exactly what `CHECK_STRUCTURE`
(`HALINCL/CHECKSTR.xpl:60`) tests before setting `SYT_PTR`, and `SYT_PTR` is the
gate on `SET_DUPL_FLAG`'s DQ7 (`HALINCL/SETDUPLF.xpl`).  A unit including two
COMPOOLs that both include STRPDT sees its nodes twice.  All 20 DQ7 failures
named the same `CSAS_PDT_*` symbols, so it was one cause reached transitively.

Which units suppressed the R cards is settled by primary evidence rather than
inference.  The OI-30.17 output-writer reports in
`PFS/"OI301700 as received"/APPLSRC/` are real listings from the original build
and carry the resolved card type per line.  The alias lines are marked C, with no
statement number, in CSAPDT, CS2PDT, CS4PDT and PGSCRU; and marked M with
statement numbers in SCKPNT, STCCYCL, STMTAB and SULUPLIN.  So the historical
build did compile STRPDT both ways — which is why the cards are type R at all.
The other seven includers say `INCLUDE STRPDT NOLIST`, so their listings show
nothing; all seven compile clean at the default R=M and are left there.

An earlier guess that the rule was "COMPOOLs get R=C" was wrong: PGSCRU is a
program and is C, CPGPCD is a COMPOOL and compiles fine at R=M.  **Only read the
markers.**

A control case rules out "duplication alone is fatal": CGEIPA and CGCFL1 each
declare their own `STRUCTURE QUAT` (textually different, semantically the same),
43 units include both templates, and 36 of them compiled fine.  The trigger is
the NAME-alias form, not duplication.

## The dependency scanner has to apply CARDTYPE

A second, independent defect: the scanner classified a card by the literal
character in column 1, but the compiler classifies it through CARDTYPE pairs.
CPTOSV line 40 begins with `B`, and CPTOSV's `BD` pair makes it a directive, so
`D INCLUDE TEMPLATE CS4_PDT` was invisible; CS4PDT was in nothing's dependency
list, was never compiled, and CPTOSV then failed XI3 for want of its template.

The scanner now applies the same map.  Measured over all 1167 source files: no
include lost, 5 gained (CS4PDT for CPTOSV and CPUSLS; CPSSLD for VVCSLDRI,
VVDSLREA and VVESLWRI), and two halnames corrected — GKDASC, GKGMNV and GKRORB
are conditional variants of one source and were all three read as
`GKD_ASC_MNV_RKIP`, two silently overwriting the third.  CARDTYPE for the GK
family is documented in `INCL80/GKPMNV.hal` lines 42-49, which is where the three
existing GK entries came from.

## GKFHOR's T cards

GKFHOR's five M1 "ILLEGAL CARD TYPE" errors were exactly its five `T` cards; `S`
is legal, matching the standard set (space, C, D, E, M, S).  The T cards wrap an
IF/THEN/ELSE around a self-balancing block, so both readings parse and both
compile clean, and the flight image did not settle it: csects-G16 gives
`#CGKFHOR` span 833, and calibration on two units (GVRQUA span 29 → 0x3C, GAEASC
span 34 → 0x46) establishes bytes = 2*(span+1), so the target is 1668 bytes.
T=C yields 0x067A = 1658 and T=M yields 0x06A4 = 1700 — 10 short and 32 over
respectively, so a second small difference is also in play.  Resolved by
compiling the T cards as live code.

## OI301700 needed its source repaired, not its CARDTYPE

OI-30.17 cannot be fixed by CARDTYPE at all.  Its source was extracted from these
same output-writer reports, so column 1 was **already resolved**: the extracted
`INCL80/STRPDT.hal` had 354 C and 40 space cards and *no* R cards, the aliases
being live.  R=C is therefore a no-op there.

STRPDT's 13 R cards have been restored (lines 383-395, SRNs 000052-000066), with
a `.bak-precardtype` alongside; columns 2 onward are byte-identical.  The
positions were not taken from OI340600 on faith — the last 15 `+C|` lines of
CSAPDT in the OI301700 reports are exactly those declarations, and SCKPNT lists
the same lines `+M|` with statement numbers.

A sweep of all 1115 OI301700 reports for included lines appearing under two
different card types found only 7: the three single-line STRPDT declarations and
four decorative comment lines (".", "*", "* *") that are C in one unit and E in
another.  So STRPDT was the only file with recoverable markers.  The limit of the
method is that it sees conditionality only where the same included text was
compiled under two different CARDTYPEs; a conditional line in a unit's own
source, extracted in one resolution, cannot be recovered this way.  That is why
the column-1 letters in GKPMNV, GKDASC, GKGMNV and GKRORB had to be restored by
hand from OI-34.06, and why the extracted tree must not be regenerated.

## Reading the listings

Facts about the output-writer notation, needed by anything that parses it:

- **Card ordering** is zero or more E cards, then exactly one M card, then zero
  or more S cards.  Exponents above, subscripts below.  So an E card never lies
  between an M card and its S cards, and every S card has an M card above it.
- **A subscript on an S card is valid only where every position it occupies is
  blank on every line above it, up to and including the M card.**  Anything
  failing that test is comment overflow, not a subscript.  The `/` test is a
  sound cross-check — `/` is not legal in a subscript, and 0 of 33768 S cards use
  it as one — but it is redundant given the blank test, and must truncate rather
  than discard, since 37 cards carry a subscript followed by a comment tail.
- The listing prints the **DO-nesting level** just after the bar, and it is not
  source.
- Error markers are `+ ___` underline cards, and they are PASS1 output.  A
  listing therefore *cannot* show a PASS2 error, and its silence about one proves
  nothing.

The extraction artifacts these caused in OI-30.17 — subscripts glued to what
follows, nesting levels left in the code, nested subscripts rendered `**` — were
all traced to bugs in the extractor itself and fixed at that root.  The
reconstruction harness once built to repair them downstream is obsolete; it was
measuring the output of a broken extractor.  See the handoff.

Method note worth keeping: for any OI301700 oddity, check whether the same file
exists in OI340600 and compare.  That settled the `**` question in one step after
much fruitless reasoning about HAL/S subscript syntax.  Any edit keeps every line
exactly 80 characters with its SRN undisturbed, taking the needed column from
trailing padding or, failing that, from the leading indentation, which HAL/S
ignores.

## Where the corpus stands

Both versions compile completely: OI340600 1011/1011 and OI301700 1105/1105, zero
failures, zero cross-comparison differences.  The progression was 907 attempts /
843 successful, then 966/939 after the MONITOR2, provider-dependency and
PASS4-in-chain changes (25 failures in 4 classes: 20 DQ7+PM1, 3 XI3, 1 PL2, 1
M1), then complete.  The 34-file ZO3 class disappeared entirely with MONITOR2 and
XI3 fell from 11 to 3 to none.

Check `grep -c 'Done\.'` before believing any of those numbers: a run that stops
early still prints a summary.
