### [2026-08-03] Target: sdfpkg-rationale.md
- PASS3->PASS4 heap abend fixed: the text COMMON ":" header now carries
  freelimit as a second field, applied after all records are read so that
  record processing cannot overwrite it.  One-field form still accepted.
  `HALSFC ... --parms=...,TABLST` on _CDR06D.hal now exits 0 and emits a real
  TABLST report; it abended before.

### [2026-08-03] Target: compilePASS.md
- Corpus OI340600 after the MONITOR2 + provider-deps + PASS4-in-chain changes:
  966 attempts / 939 successful / 38 not-in-PASS / 0 differences / 0 SPACELIB.
  25 failures in 4 classes: 20 DQ7+PM1, 3 XI3, 1 PL2 (CS2PAT), 1 M1 (GKFHOR).
  The 34-file ZO3 class is gone entirely (MONITOR2), XI3 fell from 11 to 3.
- DQ7 root cause settled, and it is issue #1281.  STRPDT's R cards are
  `DECLARE X NAME X-STRUCTURE`, a NAME variable whose name equals its own
  template's name.  That is exactly what CHECK_STRUCTURE (HALINCL/CHECKSTR.xpl
  :60) tests before setting SYT_PTR, and SYT_PTR is the gate on
  SET_DUPL_FLAG's DQ7 (HALINCL/SETDUPLF.xpl).  A unit including two COMPOOLs
  that both include STRPDT sees its nodes twice.  All 20 DQ7 failures name the
  same CSAS_PDT_* symbols, so it is one cause, reached transitively.
  Which units suppressed the R cards is settled by primary evidence, not
  inference.  The OI30.17 "output-writer" reports in
  PFS/"OI301700 as received"/APPLSRC/ are real listings from the original
  build and carry the resolved card type per line.  The alias lines are marked
  C, with no statement number, in CSAPDT, CS2PDT, CS4PDT and PGSCRU; marked M
  with statement numbers in SCKPNT, STCCYCL, STMTAB and SULUPLIN.  So the
  historical build did compile STRPDT both ways -- which is why the cards are
  type R at all.  The other seven includers say "INCLUDE STRPDT NOLIST", so
  their listings show nothing; all seven compile clean at the default R=M and
  are left there.  An earlier guess that the rule was "COMPOOLs get R=C" was
  wrong: PGSCRU is a program and is C, CPGPCD is a COMPOOL and compiles fine
  at R=M.  Only read the markers.
- Control case that rules out "duplication alone is fatal": CGEIPA and CGCFL1
  each declare their own STRUCTURE QUAT (textually different, semantically the
  same), 43 units include both templates, and 36 of them compiled fine.  The
  trigger is the NAME-alias form, not duplication.
- Second, independent defect in compilePASS: the dependency scanner classified
  a card by the literal character in column 1, but the compiler classifies it
  through CARDTYPE pairs.  CPTOSV line 40 begins with B and CPTOSV's BD pair
  makes it a directive, so `D INCLUDE TEMPLATE CS4_PDT` was invisible; CS4PDT
  was in nothing's dependency list, never compiled, and CPTOSV then failed
  XI3 for want of its template.  Scanner now applies the same map.  Measured
  over all 1167 source files: no include lost, 5 gained (CS4PDT for CPTOSV and
  CPUSLS, CPSSLD for VVCSLDRI/VVDSLREA/VVESLWRI), and two halnames corrected --
  GKDASC, GKGMNV and GKRORB are conditional variants of one source and were all
  three read as GKD_ASC_MNV_RKIP, two silently overwriting the third.
- CARDTYPE for the GK family is documented in INCL80/GKPMNV.hal lines 42-49,
  which is where the three existing GK entries came from.

### [2026-08-03] Target: compilePASS.md
- CORRECTION to what follows: the SDF path importing "too much" is not a
  defect at all, it is the transitive-include mechanism, and the preprocessor
  is what should go.  preprocessHALSFC's own header states the two premises it
  was built on -- that a template included by a template is not thereby
  included (DI11), and that "there is no mechanism provided by the HAL/S
  compiler for dealing with multiple inclusions of the same template" (PM2).
  Both are true of the template path and false of the SDF path.  INCSDF's
  DUPLICATE_NAME/SET_DUPL_FLAG is precisely the missing mechanism, and
  ENTER_COMPOOL_VARS entering the whole declare chain -- carrying symbols the
  COMPOOL itself got from its own includes -- is precisely transitive
  inclusion.  Also relevant: EMIT_EXTERNAL generates a template by echoing
  tokens as they are scanned, with no suspension during an include (checked
  every EXTERNALIZE assignment), so a COMPOOL's template necessarily carries
  its included text; there is no re-export filter to find, by design.  And
  IDENTIFY.xpl:610300's "IF I < PROCMARK THEN GO TO NOT_FOUND" makes a match
  in an outer scope not a duplicate, which is what lets a program re-include
  STRPDT inside a PROCEDURE after including COMPOOLs at outer level.
  The preprocessor is now doing harm: CS2PAT's PL2 is a duplicate include that
  preprocessHALSFC inserted, because it records only the
  "D INCLUDE TEMPLATE X" form and is blind to CS2PAT's own
  "D INCLUDE SDF CSA_PDT:" -- the same blind spot fixed in compilePASS's
  dependency scanner.  Next test is a full corpus run with --no-preprocess;
  CS2IXP already compiles clean unpreprocessed through the SDF path.  It is
  still invoked at compilePASS:589, which produces every _*.hal; the other
  call site at 492 is dead code ("if False and preprocess:").

- Superseded, kept for the mechanism only.  PGSCRU and PGPPLD survive R=C only to fail with
  DQ8, "STRUCTURE ... CANNOT BE UNQUALIFIED - STRUCTURE TEMPLATE CONTAINS AT
  LEAST ONE NAME NOT UNIQUE TO THE NAME SCOPE".  R=C suppresses STRPDT's NAME
  aliases but not its STRUCTURE declarations, which sit on ordinary space
  cards.  PGSCRU's own historical report settles what should happen: STRUCTURE
  CSAS_PDT_PAR_ENTRY appears exactly once in it, from PGSCRU's own
  "D INCLUDE STRPDT" at statement 28, so the "D INCLUDE TEMPLATE CPG_PCD
  REMOTE" at statement 6 did not bring STRPDT's structures with it.  Our SDF
  for CPGPCD does.  Compiling the same unit with --no-sdfi yields PM2 rather
  than DQ7/DQ8, so the SDF path and the template path genuinely disagree; the
  historical build used templates.  Suspect the REMOTE keyword and/or what
  INCSDF re-exports.  DUPLICATE_NAME's "IF I < PROCMARK THEN RETURN FALSE"
  (HALINCL/INCSDF.xpl:236) is the obvious place to start.
- OI301700 cannot be fixed by CARDTYPE at all.  Its source was extracted from
  these same output-writer reports, so column 1 was already resolved: the
  extracted INCL80/STRPDT.hal has 354 C and 40 space cards and *no* R cards,
  the aliases being live.  R=C is therefore a no-op there and the corpus run
  shows the DQ7s persisting.  Repairing it means restoring the R markers in
  OI301700's STRPDT, which the reports support mechanically -- the lines
  listed as C in CSAPDT/CS2PDT/CS4PDT/PGSCRU and as M in SCKPNT/STCCYCL/
  STMTAB/SULUPLIN are exactly the R cards.  That is a change to extracted
  source in the user's workspace, so it needs the user's say-so.  The same
  caution applies to every other OI301700 file with conditional compilation:
  only one resolution was extracted.

### [2026-08-03] Target: compilePASS.md
- GKFHOR (the M1 failure) is unresolved and needs a decision.  Its 5 M1
  "ILLEGAL CARD TYPE" errors are exactly its 5 `T` cards; S is legal, matching
  the standard set (space, C, D, E, M, S).  The T cards wrap an IF/THEN/ELSE
  around a self-balancing block, so both readings parse and both compile clean.
  Measured against the flight image: csects-G16 gives #CGKFHOR span 833, and
  calibration on two units (GVRQUA span 29 -> 0x3C, GAEASC span 34 -> 0x46)
  establishes bytes = 2*(span+1), so the target is 1668 bytes.  T=C yields
  0x067A = 1658, T=M yields 0x06A4 = 1700.  Neither matches; T=C is 10 bytes
  short and T=M 32 bytes over.  So a second small difference is also in play
  and the choice cannot yet be made on this evidence.
- preprocessHALSFC needs APPLSRC, SSSRC and INCL80 all present.  With SSSRC
  missing it prints "Selected file ... does not exist" and calls os._exit(1),
  which skips the stdout flush, so on a pipe the message is lost and it looks
  like a silent failure producing an empty output file.  Worth a flush.

### [2026-08-03] Target: compilePASS.md
- preprocessHALSFC is no longer run by default; --no-preprocess is the default
  and --preprocess is the opt-in.  Rationale as in the entry above: the SDF
  path supplies both things the preprocessor was written to work around, and
  the preprocessor actively causes CS2PAT's PL2 by hoisting a duplicate of an
  include it cannot see.  The user's note is worth recording: this was
  supposed to have been dropped when SDF import landed, and simply never was.
- OI301700's INCL80/STRPDT.hal has had its 13 R cards restored (lines 383-395,
  SRNs 000052-000066), with a .bak-precardtype alongside; columns 2 onward are
  byte-identical.  The positions were not taken from OI340600 on faith: the
  last 15 "+C|" lines of CSAPDT in the OI301700 reports are exactly those
  declarations, and SCKPNT lists the same lines "+M|" with statement numbers.
- A sweep of all 1115 OI301700 reports for included lines appearing under two
  different card types found only 7: the three single-line STRPDT declarations
  and four decorative comment lines (".", "*", "* *") that are C in one unit
  and E in another.  So STRPDT was the only file with recoverable markers.
  The limit of the method is that it sees conditionality only where the same
  included text was compiled under two different CARDTYPEs; a conditional line
  in a unit's own source, extracted in one resolution, cannot be recovered
  this way.

### [2026-08-03] Target: compilePASS.md
- OI301700's extraction artifacts are a distinct class from anything wrong
  with the compiler, and all of them come from folding the reports'
  two-dimensional notation flat.  OI340600's source was not extracted this way
  and is therefore the authoritative reference for the correct 1-D form.
  Three kinds found so far, all fixed or characterised:
  1. Subscript glued to what follows.  HAL/S listings carry subscripts on an S
     card beneath the M card; folding one in consumed the separating space, so
     "CGCV_GDQ_SLOPE$INDX TEMP_MACH" (an implicit multiply) became the
     undeclared identifier INDXTEMP_MACH.  73 fixed over 17 files.  Detector:
     "$NAME" where NAME occurs nowhere else in the file but splits into two
     names that each do; every hit then checked against its report.
  2. Listing nesting-level indicator left in the code.  One instance, GSFABT
     SRN 138700, where the extractor wrapped a long statement at column 72 and
     appended the report's continuation line complete with its level number,
     giving "(GSF_NZ_INHIBIT = ON) 10 THEN DO;".  Other continuation lines
     beginning with an integer were checked and are all legitimate -- their
     preceding line ends in a comparison operator.
  3. Nested subscripts rendered with "**".  Where a subscript is itself
     subscripted the listing brackets the outer name and introduces the inner
     with "**": "[JET_ARRAY]**I:" means "JET_ARRAY$(I):".  OI340600 contains no
     "**" inside a subscript anywhere; OI301700 has 203 across 39 files, so all
     are artifacts.  The 22 matching "$(NAME**INDEX)" or "$(NAME**INDEX:)" are
     fixed and verified against OI340600's own GPSASC.  **181 remain**, in
     shapes where the inner subscript's end is not simply the closing paren --
     "$(CPCS_DIT_STAT_PTR**(PCK_INDEX;)", "$(CGMV_SEQ**(N,1:)" and the like.
     Settling those needs each case's S card read individually; that is the
     largest single remaining OI301700 blocker.
     IMPORTANT, and the reason no blanket rewrite is possible: "**" in the
     extracted source has **two different origins**.
       (a) The S card really does contain it.  GPSASC's reads "[JET_ARRAY]**I:",
           where "**" is the listing's own notation for "the bracketed name is
           itself subscripted by what follows".  The extractor dropped the
           brackets and kept the "**".  Correct form "$(JET_ARRAY$(I):)",
           confirmed against OI340600.  These are the 22 already fixed.
       (b) The S card contains no "**" whatsoever, and the extractor inserted
           one as a separator because it merged two *different* variables'
           subscripts into a single subscript.  PGGPCF SRN 313900 is the
           example: the M card is
             CPGB_S71_LAST_OP                             = CPGB_LAST_OP    ;
           and the S card beneath it
                            CPGV_DISP_INDEX            ;      PGG_PL_INDEX;
           so the truth is "CPGB_S71_LAST_OP$(CPGV_DISP_INDEX;) =
           CPGB_LAST_OP$(PGG_PL_INDEX;)" -- two subscripts, one per variable --
           but the extraction reads "CPGB_S71_LAST_OP$(CPGV_DISP_INDEX**
           PGG_PL_INDEX;)".
     Class (b) cannot be repaired by a textual rule; it needs the subscripts
     re-associated with their variables by column position, i.e. redoing the
     extraction for those lines from the M/S card pair.  The way to make that
     safe is to write the reconstructor and first validate it on the many
     thousands of subscripted lines that came out *right*, requiring it to
     reproduce them byte for byte, before letting it touch a "**" line.
     That validation was attempted 2026-08-04 and **nothing was applied**,
     because neither candidate model survives it.  Recording both so the next
     attempt does not repeat them.  The reconstruction works from a report M
     card and the S card beneath it, whose columns align (find the first "|"
     in each; the text after it shares a column origin), and compares against
     the extracted source with whitespace and parentheses ignored -- the
     extractor writes "$X" in some places and "$(X)" in others, so exact
     comparison is too strict.  Note the source must be joined from columns
     1-72 only; including the SRN columns breaks contiguity and makes
     everything look like a mismatch.
       Model 1, subscript = each whitespace-delimited run of the S card,
       inserted at its own column: 2296 of 2297 pairs reproduced over the
       first 120 APPLSRC files, but only 28% corpus-wide.  It is wrong for
       subscripts containing spaces -- "$(6 TO 10)" comes out as
       "$6 $TO $10".
       Model 2, subscript = whatever the S card holds within each maximal
       blank gap of the M card, which handles "6 TO 10": worse overall, 28%.
       It over-applies, forcing parentheses everywhere and injecting "$(...)"
       into comment text.
     The real obstacle underneath both is that M/S pair detection is too
     loose: lines inside comment blocks are being taken for S cards, e.g.
     CDHMMUTI yields "/*$(E)GND$(N)MESSAGE$(T)PARAMETER LIST".  So an unknown
     fraction of the reported mismatches are bogus pairings rather than model
     failures, and no score is meaningful until pairing is tightened.  Fix
     pairing first, then re-score both models, and only then consider
     applying one.
     Pairing fixed and both models re-scored, same day.  Two harness faults
     accounted for nearly all the apparent failure, neither in the models:
       - An S card can carry a *comment overflow* rather than a subscript:
         CDHMMUTI's inline comment runs off the M card and resumes on the S
         card as "/*ESPONSE LENGTH */".  Skip S cards whose text begins "/*",
         and mask any part of the M card inside /* */.
       - The listing prints the **DO-nesting level** just after the bar, and
         it is not source.  Treating it as source put a stray leading digit on
         every reconstruction, which is exactly why the first 120 files scored
         100% (mostly level blank) and everything after them 18%.  Blank the
         field in place so the S card's column alignment survives.
     Scores over all 27896 genuine pairs, whitespace and parentheses ignored:
         model 1 (whitespace-delimited runs of the S card):    82%
         model 2 (S card content per blank gap of the M card): 90%
     Model 2 is the one to build on, as predicted -- it is the only one that
     can express a subscript containing spaces.  Comment masking makes no
     further difference to its score.
     Still not safe to apply.  2640 pairs remain unreproduced and the samples
     look *correct* by eye, CVUNDT's "NAME(CPSB_SL_COMM_FLAG1$(1:))" among
     them, which points at further harness artifacts rather than model error
     -- most likely statements spanning several M cards, where the extractor's
     own line-breaking differs from the reconstruction's.  Account for those
     before editing anything.
- Method note worth keeping: for any OI301700 oddity, check whether the same
  file exists in OI340600 and compare.  That is what settled the "**" question
  in one step after much fruitless reasoning about HAL/S subscript syntax.
- All edits keep every line exactly 80 characters with its SRN undisturbed,
  taking the needed column from trailing padding or, failing that, from the
  leading indentation, which HAL/S ignores.

### [2026-08-03] Target: sdfpkg-rationale.md
- Parallel corpora now work.  HAL_S_FC.py refreshed its private copies of
  xplBuiltins.py and HALINCL/ by rmtree+copytree into a fixed shared path, so
  a second concurrent compilation could see the tree missing or half-rebuilt
  (ModuleNotFoundError: HALINCL.COMMON; FileExistsError from copytree).  Now
  each file is copied only when it differs from the master, through a temp name
  renamed into place, and nothing is deleted.  Verified with a two-process
  smoke test and then with OI340600 and OI301700 running concurrently.
- Genuine port bug found on the way: D_TOKEN called PRINT_COMMENT with one
  argument where two are needed, killing any compilation whose directive
  continued onto a second card (reached via `D INCLUDE SDF`).  PRINT_COMMENT
  declares no I of its own, so the I it uses is STREAM's -- the scope it is
  textually included into -- and STREAM's frame is what to pass, as every other
  call site already does.  D_TOKEN's own I and J are a different variable.

### [2026-08-04] Target: compilePASS.md
- The governing rule for reconstructing a subscript, from the user, and it
  supersedes the ad-hoc comment tests: a subscript on an S card is valid only
  where every position it occupies is **blank** on every line above it up to
  and including the M card.  Anything failing that is comment overflow.  This
  is why comment masking made no difference to model 2's score -- model 2 only
  inserts into blank gaps of the M card, so it was already enforcing the rule
  implicitly.  The '/' test is still a sound cross-check ('/' is not legal in
  a subscript: 0 of 33768 S cards use it as one) but is redundant given the
  blank test, and must truncate rather than discard, since 37 cards carry
  subscripts followed by a comment tail.
- Card ordering, also from the user: zero or more E cards, then exactly one M
  card, then zero or more S cards.  Exponents above, subscripts below.  So an
  E card never lies between an M and its S cards, and every S card must have
  an M card above it.
- Two harness gaps remain, and they are the whole of the unexplained 10%:
  1. Multiple S cards per M card -- 491 M cards have 2, 22 have 3, 7 have 4.
     That is a subscript of a subscript.  Only the first is being read, and
     the blank test for the second must run against the first S card as well
     as the M card.
  2. The walk upward from an S card halts on lines the bar regex cannot parse,
     chiefly the "+   ______" error-position underline cards.  It must skip
     them and keep going.  Every S card has an M card above it, so any
     "no M above" result is this bug and nothing else.
- Nothing has been edited on the strength of any of this.  Fix both gaps,
  re-score, and only consider applying model 2 if it reaches ~100%.

### [2026-08-04] Target: [HANDOFF.md]
- Open item A is closed at its root.  The OI-30.17 extraction artifacts are
  four bugs in ~/workspace/PFS/unprint.py, not something to patch downstream:
  collapseES() dropped its S flag when recursing (every nested subscript became
  "**"); E/S lines were padded use columns for an absent card but use-1 for a
  present one, shifting every card after the first (truncated subscripts, stray
  re-attached tails); startGap() ignored the caller's left boundary (subscripts
  emitted twice); and collapsing a subscript ate the blank that separated two
  identifiers (glued implicit multiplies).  Also the DO-nesting-level test
  missed two-digit levels and outdented labels.  PFS c2a8fa9, 5efb99e.
- The reconstruction harness described in HANDOFF §7 is obsolete -- it was
  measuring the output of a broken extractor.  Delete §7's scoring history when
  the handoff is next revised; keep the governing rule about blank columns, it
  is what the separator fix implements.
- Validation method worth keeping: extract the whole report set with both the
  old and the new unprint.py, then compare each against the master at token
  level, three ways.  It separates "the fix changed this" from "the master was
  repaired by hand here" without any judgement calls.
- Open item B: D15 is now severity 0, not a passFailed() special case.  PASS1
  puts a statement's highest severity in its SMRK and PASS2's OPTIMISE.xpl:144
  raises B100 for any nonzero tag, so severity 1 still abandons the conversion.
  virtualagc 3b78ef4e8.
- prepareSource.py needs the ahocorapy package, which is not installed here.  A
  60-line Aho-Corasick stand-in reproduces master bodies byte-for-byte from the
  old extraction, so the anonymizer is entirely deterministic given its .anon
  databases.  Note it appends to collisions.anon as a side effect.
- GX4DIS, PMCCYC and PMOSTA masters carry blocks no extraction has ever
  produced -- macro expansions, most likely.  Do not regenerate them blindly.
