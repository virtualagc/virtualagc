# CLAUDE_LOG.md

(Cleared 2026-09-04 by Full Documentation Sync.  Four entries applied, all to
`problems.md` (8432 → 8612).  They were one continuous story — the OI340700
source reconstructions — so they were told as such rather than filed as four
dated notes, and the first entry's "NOT ATTEMPTED: writing those
reconstructions" is superseded by the three that follow it rather than
preserved alongside them.

- **`problems.md` §8.38**, four new subsections.  **The conditional the source
  already contained**: `CPUSLS` and `CPTOSV` are fixed by four characters each,
  all in column 1, because the `F`-card conditionals are comments in those
  modules and the source already ships both branches — with the dump's eight
  null pointers agreeing rather than merely permitting.  **Reading the payload
  indexes out of the dump**: the three-step method for `CS2IX2`–`CS2IX7` and
  `CS2IXP`, and the three traps in it (the `_FDA`/`_LIM` exclusion, `0000`
  being a real null rather than `CSAS_PDT_DUMMY`, and the grouping comments
  being unrecoverable).  **Two further shapes**: `CS2PX2` and `CS2PCT`, why
  eleven "unresolved" pointers were never broken, and the 191-of-196 identical
  reproduction that validates the whole method.  **`dass-ixgen.py`**: where the
  tool lives and the three self-checks built into it.  The existing "residue is
  one root cause" subsection was updated to say which eleven files are now
  done, which four remain, and — explicitly — not to quote its "22 missing"
  figure as though it accounted for the new work.

- **`problems.md` §8.10**, two method failures.  `pgrep -f` matching the
  shell that runs it, and the worse compounding error of reading the process
  table instead of the log the job had already written; and displaying "the
  first match" as though it were the match the analysis actually found.)

### [2026-09-04] Target: problems.md
- RUN 2 RESULT: ten of the eleven reconstructions compile.  CPUSLS CPTOSV
  CS2IX2..7 CS2IXP CS2PX2 all "Compilation successful".  CS2PCT fails, but NOT
  on its own account -- XI10 "REL3 SDF ##CSAPCT NOT FOUND IN SDF LIBRARY" on
  its "D INCLUDE SDF CSA_PCT:" card, with the three XU1s after it merely the
  stranded D STRUCTURE cards.  It was waiting on CSAPCT, which did not exist
  yet.  Corpus-wide: unrecognized failures 16 -> 11, IR1/DI11/PM2/ZO3 skips
  541 -> 12, successful 667 -> 1204.  THE 541 -> 12 IS THE REAL RESULT: those
  roots were gating a large dependent set.
- FOUR MORE DONE -- CS2PX3, CS2PXT, CSAPCT, and CS2PCT unblocked.  Fifteen
  files now exist in PFS/OI340700/APPLSRC/.  CS2PX3 437 -> 253, CS2PXT
  440 -> 257, CSAPCT 536 -> 382 (63 info, 242 sol, 74 pgt, 3 pad).
- FOUR DEFECTS THE WORK EXPOSED, all in the generator, none in the dump.
  (1) **A COUNT DECLARED OUTSIDE THE GENERATED BODY WAS SILENTLY CARRIED OVER.**
  CS2PXT holds "DECLARE  CSAS_PXT_NUM_ENTRIES INTEGER INITIAL(1316)" -- two
  spaces after DECLARE, so it never matched the declare pattern and was copied
  from OI340600 untouched.  The dump says 766.  It would have compiled
  perfectly and been wrong.  The tool now reads the value from the dump and
  rewrites it.  ANY constant outside the replaced region is suspect this way.
  (2) A COPY marker carries no CSECT name, so the last structure of a CSECT
  collected a marker from elsewhere in the file -- "pad is 5 in OI340600 but 83
  in the dump".  Bound it by the structure's own address range.
  (3) MAFGEN PAGINATES INSIDE STRUCTURES.  A page break between an ARRAY member
  and its two continuation lines put the banner where the values should be:
  INITIAL(1M,A,F,G,E,N,REL,26.020,...).  Furniture is now stripped once at
  load, for every parser.
  (4) A pointer need not aim at a payload at all.  CSAPCT's SOL_BLOCKs point
  into the CS2_IPT compool and OI340600 writes them the same way,
  NAME(CSAS_IPT_920601.CSAS_IPT_STATUS).  The resolver now falls back to the
  innermost structure covering the address, whatever compool it belongs to.
- REGRESSION-CHECKED: after all four fixes, the eleven previously generated
  files regenerate BYTE-IDENTICAL.  Only CSAPCT, CS2PX3 and CS2PXT are new.
- CS2PXT IS A STRICT ORDER-PRESERVING SUBSET of OI340600's -- 257 of 440
  entries kept, all 257 byte-identical, none altered.  CS2PX3 shares only ONE
  entry with OI340600 and it matches.  CSAPCT shares 58 and only 3 match, which
  is NOT a warning sign: its 368 packed-halfword reassembly checks all pass, so
  the values are right by construction, and the group layout simply changed.
- A HYPOTHESIS TESTED AND DROPPED: six sampled CSAPCT entries had GROUP_INDEX
  equal to the number in the declare's own name, which looked like an
  invariant worth verifying against.  Measured across the whole file it holds
  in 36 of 63 (and 14 of 70 in OI340600), so it is a coincidence, not a rule.
  Six samples are not a pattern.
- ALSO A CHECKING SCRIPT THAT WAS WRONG, not the file: a first pass reported
  only 8 of CSAPCT's 74 CSAS_PGT declares agreeing with their DMST_POS target.
  66 of them point at NULL, which the script counted as disagreement.  Measured
  properly: 66 NULL, 8 pointing somewhere, all 8 agreeing, 0 anomalies.

### [2026-09-04] Target: problems.md
- **A GENERATED FILE SILENTLY LOST TWO CARDS, AND IT COMPILED ANYWAY.**  The
  OI340700 CSAPCT dropped both its "F END" and "  DECLARE DUMMY_INTEGER INTEGER
  INITIAL(0);", and HALSFC reported "Compilation successful".  Cause: build_pct
  found the end of the region it was replacing by walking BACKWARDS from the
  end of the file for a line containing "INITIAL".  That walk stepped over the
  F END and landed on DUMMY_INTEGER -- whose card begins with TWO spaces, so it
  was never part of the generated set -- and everything from there back was
  replaced.  Fixed to end at the closing ");" of the last generated declare,
  which is how build_pxt already did it.
- HOW IT WAS FOUND, AND THE GENERAL RULE.  Not by the build, which passed.  The
  dump lists every terminal of a CSECT, so the sound check is: enumerate the
  scalars lying OUTSIDE every structure of the CSECT and confirm each one is
  present in the reconstruction with the dump's value.  Doing that gives
      CS2IX2..7 CS2IXP CS2PX2 CS2PX3 CS2PCT   0 standalone scalars -- no exposure
      CS2PXT                                  CSAS_PXT_NUM_ENTRIES = 02FE (766)
      CSAPCT                                  DUMMY_INTEGER = 0000  <- was MISSING
      CPUSLS 12, CPTOSV 4                     all present, all agreeing
  CPUSLS's and CPTOSV's twelve and four are worth noting separately: those two
  are hand column-1 edits, so every value in them is OI340600's, and this is the
  first check that covers them beyond the eight pointers.  All sixteen agree
  with the dump.
- A FAILED SWEEP BEFORE THE GOOD ONE.  The first attempt scanned the generated
  files for carried-over numeric initialisers and reported two, MISSING the
  known CSAS_PXT_NUM_ENTRIES case because that declare spans an intervening
  "F GEN" card.  A sweep that misses the example you already have is not
  evidence of anything; ask the dump what should be there rather than asking
  the file what is.
- pkill -f BIT AGAIN, one level removed: `pkill -f 'compileP[A]SS'` stopped the
  build as intended AND killed the Monitor task watching it (exit 144), whose
  own command line was close enough to match.  Bracketing the pattern protects
  the invoking shell, not other watchers.  Capture the PID at launch and kill
  that instead -- run4 records it in run4.pid.
- Run 3 was abandoned: sources were restaged mid-run, so files compiled before
  the restage used the old CSAPCT and files after used the new one.  A run whose
  inputs changed underneath it cannot be quoted.

### [2026-09-04] Target: problems.md
- RUN 4: ALL FIFTEEN RECONSTRUCTIONS COMPILE.  1208 successful; IR1/DI11/PM2/ZO3
  skips 541 -> 8; unrecognized failures 16 -> 7.
- THE @@PTOSVS TRACE ANSWERED THE OPPOSITE OF WHAT WAS SUSPECTED.  The guess was
  an over-aggressive tombstone.  It is a MISSING one.  PTVOSV asks for
  "INCLUDE TEMPLATE PTO_SVSIO", which descores to PTOSVS; PTO_SVSIO: PROGRAM is
  defined by PTOSVSIO.hal, which IS tombstoned -- correctly, since no CSECT in
  any of the eight dumps descores to PTOSVS.  But PTV_OSVS is absent from all
  eight dumps TOO, and PTVOSV.hal is still live.  The whole OSVS subsystem is
  gone from OI340700 and only half of it was removed.
- SO FIVE OF THE SEVEN FAILURES ARE ONE TOMBSTONE PLUS ONE SMALL EDIT.
  PTVOSV tombstoned; SSPEXEC then needs its two references dropped -- line 40
  "D INCLUDE TEMPLATE PTV_OSVS;" and line 357 "CALL PTV_OSVS;" -- after which
  SGCKIP, SM2OPS and SCOSPE should cascade-resolve (@@SSPEXE <- SSPEXEC,
  @@SGCKIP <- SGCKIP).  The dependency surface is tiny: PTV_OSVS is referenced
  only by SSPEXEC, and CPTOSV's apparent references are comments plus the
  unrelated CPTV_OSVS_* symbols.
- THE SHAPE OF THE SSPEXEC EDIT IS DECIDED BY THE MACRO.  CGEDIS.hal defines
  REPLACE CASE_START(NO) BY "CASE_`NO`: DO", so a case is a LABELLED block
  reached by label, not by position.  Deleting CASE_START(33)/CASE_END(33)
  outright would break the dispatch; the minimal safe edit keeps the label and
  empties the body.  Whether OI340700 kept an empty case or removed it and
  renumbered is NOT established -- that is a code-reconstruction judgement, not
  a data transcription, and it is the first of these that touches executable
  code rather than a table.
- A SWEEP, AND WHY ITS RESULT IS A LEAD AND NOT A VERDICT.  Collecting every
  compilation-unit name the eight dumps mention (1165 of them) and checking
  every live source against it gives 45 files whose unit appears in NO dump,
  PTVOSV among them.  ABSENCE FROM EIGHT DUMPS IS NOT ABSENCE FROM OI340700:
  the dumps cover eight GPC configurations, so a unit belonging to an undumped
  configuration looks exactly like a deleted one.  PTVOSV is safe to act on
  because it has independent corroboration -- the other half of its own
  subsystem is already tombstoned on the same evidence.  The other 44 are
  candidates to check, not files to delete.
- COUNTS, MEASURED NOT RECALLED: 41 tombstones exist, and they exist ONLY in
  the scratch build tree.  PFS/OI340700 contains ZERO.  Earlier notes quoting
  105 are stale.
- TWO SUBSTRING FALSE POSITIVES IN ONE SESSION, both mine.  "PTV_OSVS" matched
  inside "CPTV_OSVS_INPUT_CMD", making an absent procedure look present in 1 of
  8 dumps; the earlier CS2IFT case matched an unrelated first line.  Grep for a
  name in a dump must anchor on how the dump NAMES a unit -- the "| NAME" field
  of a CSECT header -- not on the bare string.

### [2026-09-04] Target: problems.md
- **SMN_CLN IS CASE 33.**  The user's suggestion, and it is right: replacing
  SSP_EXEC's "CALL PTV_OSVS" with "CALL SMN_CLN" (and its template include to
  match) compiles, and SGCKIP, SM2OPS and SCOSPE cascade-resolve behind it.
  Four failures cleared by two cards.
- WHAT CORROBORATES IT INDEPENDENTLY OF THE BUILD.  SMN_CLN: PROCEDURE is in
  the OI340700 dump as #CSMNCLN, in the same DASS_S2 as SSP_EXEC; SMNCLN.hal is
  live and compiles; it takes no arguments, so it substitutes directly for a
  callee that took none.  The telling part is that NOTHING ELSE IN THE TREE
  CALLS IT.  A procedure the release builds but no source invokes is what a
  dispatch case that lost its callee looks like from the other end -- so the
  two halves fit rather than merely not conflicting.
- THE CASE LABEL IS DELIBERATELY UNTOUCHED.  CGEDIS.hal defines
  REPLACE CASE_START(NO) BY "CASE_`NO`: DO", so a case is reached BY LABEL, not
  by position.  Deleting CASE_START(33)/CASE_END(33) would break the dispatch;
  only the body changes.
- PROGRESSION, all three runs measured from their own logs:
      run    successful   IR1/DI11/PM2/ZO3 skips   unrecognized failures
      run2      1204              12                      11
      run4      1208               8                       7
      run5      1213               3                       2
  Only CS2IFT and CS2PAT remain.  CS2IFT needs the structural removal of
  DECLARE CSAS_IFT_920313 (absent from #PCS2IFT, which runs ...920109, 920315,
  920318...), and CS2PAT references CSAS_PGT_ entries -- CSAS_PGT_450445_1_3
  and CSAS_PGT_9010114_2001_1 -- that OI340700's CSAPCT and CS2PCT do not
  carry.
- PFS NOW HAS ITS FIRST TOMBSTONE.  PTVOSV.hal, zero length, alongside a new
  SSPEXEC.hal reconstruction.  The other 40 tombstones still exist ONLY in the
  scratch build tree; whether that whole set belongs in PFS is an open question
  for the user, not something to decide by drifting into it one file at a time.

### [2026-09-04] Target: problems.md
- THE TOMBSTONES ARE IN PFS: 103 of them, 94 in OI340700/APPLSRC and 9 in
  OI340700/SSSRC.  Not 41 -- that earlier count used `-name '*.hal'` and
  silently excluded 64 .dfg tombstones.  Count the set you mean, not a
  convenient subset of it.
- **THREE WERE WRONG, AND THE DERIVATION EXPLAINS WHY.**  CSAMMU.hal,
  CVIMMUTI.hal and CVQMMUTI.hal were tombstoned, but CSA_MM_UTILITY,
  CVI_MM_UTILITY and CVQ_MM_UTILITY all appear as unit names in the OI340700
  dumps -- CSA in S2, CVQ in G9, CVI in S2.  The tombstone derivation had
  identified each file's CSECT BY FILENAME:
      #PCSAMMU 0 occurrences    #PCVIMMU 0    #PCVQMMU 0
      #PCVNMMU 65               #PCDIMMU 84
  Those four compools share TWO CSECT slots, one per GPC configuration, so
  three of the four have a CSECT named after a different member of the family.
  The filename guess found nothing and removed them.  They are excluded from
  PFS and restored in the build tree.
- HOW THE OTHERS WERE CLEARED, and it is the check to reuse: collect every
  compilation-unit name the eight dumps mention (the "| NAME" field of a CSECT
  header, 1165 names) and require each tombstone's unit to be ABSENT from it.
  64 of 64 .dfg and 39 of 42 .hal pass.  A .dfg's stem IS its unit name
  (CS2011 -> #PCS2011), so the same test covers both kinds.
- A STRAY EMPTY FILE IS NOT A TOMBSTONE.  RUNASM/test.log is zero length and
  was in the enumeration; it is build litter and was excluded.  "Zero bytes"
  is not the definition of a tombstone -- "zero bytes AND an OI340600 original
  exists" is.
- Both trees now agree exactly: 103 tombstones each, same set.

### [2026-09-04] Target: problems.md
- CS2IFT AND CS2PAT ARE BUILT, the last two.  CS2IFT 43 -> 45 declares (27
  CSAS_IFT, 17 CSAS_IFT_DIS, 1 pad) -- it GAINS entries, adding 726040, 726042
  and 726044 while dropping CSAS_IFT_920313.  CS2PAT is two declares.
  **ALL 42 ENTRIES CS2IFT SHARES WITH OI340600 CAME OUT BYTE-IDENTICAL.**
- CS2IFT NEEDED TWO TARGET KINDS NOTHING ELSE USES.  A pointer may aim at an
  ARRAY ELEMENT -- the dump gives the array's extent, so the index is the
  offset from its start -- or at a PLAIN VARIABLE inside no structure at all,
  written NAME(CSAS_DUMMY_STAT) with no qualification.
- THE TEMPLATE IS NOT IN THE DUMP BUT IS DERIVABLE.  CSAS_IFT, CSAS_IFT_INT,
  CSAS_IFT_DIS and CSAS_IFT_DIS_3 have IDENTICAL member names and differ only
  in the type of CSAS_IFT_PARM_VAL, so the type of what that pointer POINTS AT
  names the template.  The census gives 27 SCALAR and 17 BIT(16) and NO BIT(3)
  -- and CSAS_IFT_920313 was OI340600's sole DIS_3 entry.  The template count
  and the missing entry corroborate each other.
- FIVE DEFECTS IN ONE BUILDER, every one caught by comparing against OI340600
  rather than by the build:
  (1) ARRAY ELEMENT SIZE.  Index is (ptr-lo)/width+1, not ptr-lo+1.  A SCALAR
      array is 2 halfwords per element, so $(2:) came out as $(3:).  SCALAR
      arrays print NO value line, so the width has to come from the type.
  (2) THREE SUBSCRIPT STYLES, not one: $n, $(n) and $(n:).  The declarations
      are identical (ARRAY(3) SCALAR, ARRAY(4) SCALAR), so the difference is
      the source's own style; it is now preserved per array from OI340600.
  (3) A ")?" in the style regex swallowed NAME's OWN closing paren, rendering
      NAME(X$1)).
  (4) CSAS_IFT_NUM_ENTRIES was inside the replaced region and got DROPPED --
      the same defect as CSAPCT's DUMMY_INTEGER.  It is also a COUNT THAT
      CHANGED: OI340600 says 42, the dump says 44.
  (5) The fix for (4) landed in build_pct instead of build_ift, because both
      functions END WITH AN IDENTICAL RETURN LINE and replace(...,1) took the
      first.  It then failed SILENTLY, because the missing value made `want`
      None and the whole block was skipped without error.
- CS2PAT IS A CROSS-CHECK, not just a reconstruction.  Its two declares point
  at the FIRST entry of each precondition table, and all six targets --
  CSAS_PCT_1_3, CSAS_PCT_SOL_1_3_1_11, CSAS_PGT_451100_1_3 and the CS2PCT
  three -- exist in the CSAPCT and CS2PCT reconstructions, which were built
  separately.  Counts changed too: 70 -> 63 and 29 -> 4.
- RUN 6 WAS ABANDONED for the same reason as run 3: CS2IFT was staged into the
  build tree while the run was in progress.  Stage, then launch; never during.

### [2026-09-04] Target: problems.md
- TWO RUNS THROWN AWAY BY ONE MISTAKE, and the mistake was mine twice over.
  `kill -- -PID` on run 6 DID NOT WORK -- the run went on to finish, 1213
  successful -- and run 7 was launched seconds later into the same tree.  They
  collided immediately: run 7's very FIRST file failed with "Aborted after AUX
  / Unable to open COMMON input file", and it then wedged in HALSFC-PASS2 for
  50 minutes on file 8.  compilePASS has no per-file timeout, so a hung module
  stops the sweep dead and the log simply stops growing.  VERIFY THE TREE IS
  QUIET BEFORE LAUNCHING, by scanning /proc for processes whose cwd is the
  build directory -- `kill` returning success proves nothing.
- A FALSE REGRESSION I ALMOST REPORTED.  Run 6 listed five NEW failures --
  V02TCSSA GH6ABR CVJFDECP GKDASC GEEADM -- all of which had compiled in run 5.
  The obvious reading was that restoring the three MM_UTILITY compools broke
  them.  IT WAS NOT.  Their results directories are timestamped 12-08-32,
  12-08-33, 12-08-33, 12-08-35, 12-08-35 -- a three-second window centred on my
  kill and the file copy that followed it -- and GKDASC's failure is "Aborted
  after FLO", a compilation cut off mid-phase.  Timestamps on the artefacts
  settled it; the failure list alone would have argued for re-tombstoning three
  files that are correctly present.
- WHAT RUN 6 DOES ESTABLISH: CSAMMU, CVIMMUTI and CVQMMUTI all compile.  So
  excluding them from the tombstone set was right, and there is no symbol
  clash with CVNMMUTI, which was the obvious worry given they share CSECT
  slots.

### [2026-09-04] Target: problems.md
- **THE OI340700 COMPILE IS COMPLETE.**  Run 8, on a tree verified quiet and
  consistent before launch: 1218 successful, 0 aborted, 0 exit-code failures,
  0 skipped for IR1/DI11/PM2/ZO3, 0 uncompiled due to dependence, and no
  "failed in a way compilePASS does not recognize" line at all.  1979 object
  files.  Every HAL/S and display source in the release compiles.
- The progression across the four runs whose inputs were stable end to end
  (runs 3, 6 and 7 are excluded -- 3 and 6 had sources restaged mid-run, 7
  collided with 6 and wedged):
      run    successful   skips   unrecognized   aborted
      run2      1204        12         11          24
      run4      1208         8          7          16
      run5      1213         3          2           9
      run8      1218         0          0           0
- WHAT CLOSED THE LAST TWO: CS2IFT and CS2PAT, both compiling.  And the three
  MM_UTILITY compools restored from the wrong tombstones compile too, which is
  the independent confirmation that excluding them was right.
- STILL OUTSTANDING: every run so far used --no-assemble, so the AP-101S
  assembly sources in SSSRC/, APPLSRC/, RUNASM/ and ZCONASM/ have NOT been
  assembled in this series.  A full build does both, and that is the next step
  before anything can be linked.
