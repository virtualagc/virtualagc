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

### [2026-09-04] Target: problems.md
- **THE FULL OI340700 BUILD SUCCEEDS, COMPILE AND ASSEMBLY.**  Run 9, the first
  in this series without --no-assemble: 1218 compiled and 761 assembled, 0
  aborted, 0 exit-code failures, 0 skipped, 0 uncompiled due to dependence.
  All 761 assembly sources -- 272 SSSRC, 205 RUNASM, 284 ZCONASM -- assembled
  on the first attempt against the new tombstone set.
- THE COUNTS RECONCILE EXACTLY, which is the check worth doing rather than
  trusting the totals: 1958 live sources, 1979 objects, and NO live source
  without an object.  The 21-object excess is entirely _stub*.obj from the
  cycle-breaking seeds, and every stub has its real object alongside it, so
  none is a stale artefact of a now-tombstoned file -- which is what would
  quietly corrupt a link.
- Four "ERROR" hits in the log are the filenames VXEERROR.hal and VBFERROR.hal.
  Both compiled successfully.  Grep for a word, get a word.
- COMMITTED: PFS 70e65182 (122 files -- 17 reconstructions, 103 tombstones,
  dass-ixgen.py, BUILD.md), virtualagc 5b5e52bc2 (the pending log queue).
  Deliberately NOT committed to PFS: __pycache__/ and
  OI340600/g9-all.fcmcmp.repro.json, since no repro.json is tracked there.
- NEXT: linking.  The object stage is complete, so CON80 and lnk101 are what
  stands between this and a memory image.

### [2026-09-04] Target: problems.md
- **WE CAN FORM RUN AND ZCON OURSELVES, and now have.**  They are not a special
  artefact of Don's: each is simply a DIRECTORY OF .obj FILES (his also carry
  .asmg.json and .stamp build metadata, which the linker does not need).  RUN
  holds 205 objects and ZCON 284 -- exactly our RUNASM and ZCONASM source
  counts, and the NAME SETS ARE IDENTICAL, 0 differences either way.  Built to
  build/lib/runtime/{RUN,ZCON} in the scratch tree, mirroring his layout.
- HOW OURS COMPARE, canonicalised with ASM101S/objcanon.py to remove the known
  set-ordering noise:
      ZCON   284 of 284 IDENTICAL
      RUN     89 of 205 identical, 116 differ
  Every one of the 116 reduces to two causes we already knew about and chose:
  72 fill byte only, 22 END record only, 21 both, and 1 (IOINIT) whose
  "unexplained" residue turned out to be fill as well -- Don ZERO-fills the
  #LIOINIT block where we write c6c6, which the classifier missed because it
  only knew to look for c9fb.  The fill difference is deliberate: c6c6 was
  chosen for tape building, c9fb is what the dump shows.  NOTHING here suggests
  our objects are wrong.
- SO THE LINK STAGE IS NOT BLOCKED ON DON.  lnk101 remains his, legitimately --
  we have no equivalent -- but its two runtime libraries are ours now, built
  from our own assembler out of sources in the Virtual AGC tree.

### [2026-09-04] Target: problems.md
- **YES, OI340700 NEEDS ITS OWN CON80/, BUT ONLY 10 DECKS OF 194.**  The decks
  name CSECTs, 1134 distinct ones across 1340 INSERT statements.  Taking each
  tombstoned file's CSECT from OI340600's OWN OBJECT LIBRARY (an SD record,
  not a guess from the filename -- that guess is what removed the MM_UTILITY
  compools wrongly), the 106 tombstones remove 106 CSECTs, 28 of which are
  INSERTed somewhere:
      CS4PX    3   OFTMP     5   PHASE22  1   SM2DISP  3   SM4      5
      SM4DISP  3   SM4DISPS  5   SM4IXPLB 7   SSW      1   TEXTGPH  1
  The pattern is almost entirely SM4/CS4 -- #PCS4PX2, #PCS4IX2..7, #PCS4PDT,
  #PCS4IPT, #PCP4GXT -- so OI340700 appears to drop that payload
  configuration outright.  #PCVMS8C is the other recurring one, in OFTMP, SSW
  and TEXTGPH.
- NO NEW INSERTS ARE NEEDED FOR THE RECONSTRUCTIONS.  Every one keeps its
  OI340600 CSECT name and 13 of 17 are already INSERTed; the four that are not
  (CS2PCT, CS2IFT, CS2PAT, SSPEXEC) were not INSERTed in OI340600 either, so
  nothing changed for them.
- AN OPEN QUESTION THE CHECK TURNED UP, and it is a link-stage one.  Our build
  gives CSAMMU, CVIMMUTI and CVQMMUTI the CSECTs #PCSAMMU, #PCVIMMU and
  #PCVQMMU -- named after their own compools -- and NONE of those three is
  INSERTed anywhere.  The dumps show why: #PCVNMMU is a single CSECT SLOT
  occupied by CSA_MM_UTILITY, CVN_MM_UTILITY or CVQ_MM_UTILITY depending on
  configuration, and #PCDIMMU likewise by CDI_MM_UTILITY or CVI_MM_UTILITY,
  with "INCLUDE REMOTE" marking the owner.  So the release puts several
  compools into one CSECT, and our objects do not name that CSECT.  How that
  slot assignment happens -- a compiler option, a CON80 mechanism, or
  something else -- is NOT established, and it has to be before those three
  can link.  It does not affect the compile, which is why run 8 and run 9 were
  clean.

### [2026-09-04] Target: problems.md
- **THE LINK WORKS, END TO END, WITH ONLY lnk101.**  con80build is not needed:
  lnk101 takes --concard <deck dir> and --concard-root itself.  Recipe, from
  the build tree:
      lnk101 objects/*.obj (minus _stub*) -L lib/runtime/RUN -L lib/runtime/ZCON
             --concard CON80 --concard-root SM2 --allow-undefined
             -o link/SM2.fcm --lib link/SM2.lib --json-symbols link/SM2-symbols.json
  Result: 2113 modules, 966288 halfwords, 92 undefined.  TWO THINGS THAT MUST
  BE RIGHT: the _stub*.obj cycle seeds MUST be excluded (they duplicate every
  symbol of the real unit), and --allow-undefined is required because THE REAL
  IMAGE HAS UNRESOLVED REFERENCES TOO -- FIOCWWRP, FIODD3PC and #CPUSSLS are
  referenced by objects and absent from the S2 image itself.
- ONLY ONE CON80 DECK NEEDED CHANGING FOR SM2.  SM2 reaches 15 decks and just
  SM2DISP is among the 10 with dead INSERTs.  Its three, #PCS2100 #PCS2130
  #PCS2140, are absent from the real S2 image -- so the image itself confirms
  the tombstones behind them.  PFS/OI340700/CON80/SM2DISP holds the edit.
- **I COMPARED AGAINST THE WRONG GROUND TRUTH FIRST, and it inverted the
  result.**  latest.unlinkS2.results/signature.json looked authoritative -- 1164
  CSECTs, per-CSECT halfwords -- and I used it without checking it against the
  DASS dump.  IT DISAGREES WITH DASS_S2 ON 358 OF 1160 CSECT SIZES, and where
  they disagree the dump matches OUR build: #CAIDDEU signature 40, dump 61,
  ours 61; #CARDCSB signature 391, dump 556, ours 556.  On that reference I had
  concluded "712 real content differences" and was investigating our compiler
  for emitting oversized code.  Against the RIGHT reference -- the DASS_S2 dump
  and mafgen/S2.fcm -- 1141 of 1223 CSECT sizes MATCH and only 82 differ.
  Check a new oracle against a known one before trusting it.
- WHERE THE CONTENT COMPARISON STANDS, same-size CSECTs against mafgen/S2.fcm:
      byte-identical                    157
      differ only at relocation sites    353
      differ only in fill                65
      relocation + fill                  69
      other                             497
  644 of 1141 are fully accounted for by placement and fill.  Our single-shot
  SM2 link lays memory out differently from the real phased build (966288
  halfwords against 330394), so every address constant differs by construction;
  that is why relocation dominates.  The 497 are not yet characterised and must
  not be called defects until the layout matches.
- SO THE PTV_OSVS vs SMN_CLN QUESTION IS STILL OPEN.  It needs a layout-matched
  link -- phases in OFTMP order with --map-lib -- before $0SSPEXE's 189
  halfwords can be compared meaningfully.

### [2026-09-04] Target: problems.md
- **compilePASS WAS COMPILING NOSDL, AND THAT IS WRONG FOR THIS COMPARISON.**
  monitor13.parms records the options actually used.  The reference build that
  matches the dumps says
      SDL,SREF,LIST,LISTING2,SRN,TEMPLATE,NOLFXI,REGOPT,LITSTRINGS=3000,CARDTYPE=...
  ours said
      SREF,SRN,TEMPLATE,NOLFXI,REGOPT,LITSTRINGS=3000,CARDTYPE=...
  LIST and LISTING2 are report-only, so SDL was the one substantive difference.
  Without it the compiler emits, for EVERY PROGRAM, a START CSECT, an
  "LHI R0,<stack>" prologue and linkage-editor STACK cards that the flight
  images do not have -- mechanism 1 in the comparison database, "makes 27 of 29
  PROGRAM CSECTs byte-identical".  It explains the 6696 "Symbol 'START' defined
  in both" warnings my link emitted and $0SSPEXE coming out 191 halfwords
  against the real 189.  halsParms has always had DEFAULT_SDL=False and an
  sdl= parameter that NOTHING passed; compileLinkCompare compiles with SDL by
  default, compilePASS never did.  Added --sdl to compilePASS.
- **A BUG THAT MADE --extra-parms SILENTLY INEFFECTIVE.**  compilePASS calls
  getParms TWICE: once for dependency ordering, which passed extraParms, and
  once to build the PARM field actually used for the compilation, which did
  NOT.  So --extra-parms=SDL appeared to work and changed nothing.  The
  symptom is invisible unless you read monitor13.parms in the results
  directory, which is the file that settles what the compiler was really told.
  Both call sites now pass extraParms and sdl.
- --concard IS NOT THE WAY TO GET THE LAYOUT.  The established method is
  per-module: link ONE object with --external-syms=mafgen/augmented-XXX.json,
  which places it at the address the real image has, then fcmcmp against
  mafgen/XXX.fcm.  That is what compileLinkCompare and dass-run.py do, and it
  makes the whole-image layout problem disappear.  My whole-image --concard
  link is why relocation dominated the comparison.
- WHAT THE COMPARISON DATABASE SAYS ABOUT MY 497 "content differences":
  ALL 497 are in it, and 446 have verdict ok -- our own tools already
  reproduced them byte-for-byte against this same DASS S2 dump from OI340600
  sources.  So they were never tool defects.  The other 51 were never compared
  (47 'other' origin, 2 library, 2 hal).  ZERO of the 497 carry an attribution
  to any known mechanism, because a matching section has nothing to attribute.
- THE DATABASE ALSO HOLDS THE CATALOGUE OF KNOWN CAUSES, eleven of them, with
  status: program-prologue-sdl, pde-stack-address-fill, zcon-negative-
  displacement and post-build-patched-locations are 'fixed';
  source-version-oi3406-vs-oi3407 and reconfiguration-data-differs are
  'understood'.  Read mechanism before investigating a difference.

### [2026-09-04] Target: problems.md
- **THE --fill QUESTION IS ANSWERED, AND IT IS PER-TOOLCHAIN, NOT PER-CSECT.**
  Measured from the dumps themselves, with no build involved.  Every DASS
  configuration contains BOTH values -- S2 has 234 C6C6 and 37 C9FB at
  alignment gaps, and the same split appears in all eight -- so neither is "the"
  fill.  But of S2's 124 CSECTs that have alignment gaps, EVERY ONE USES A
  SINGLE VALUE THROUGHOUT; not one mixes.  Joining them to the comparison
  database's csect.origin:
      hal    origin -> C6C6   94 CSECTs, all of them
      other  origin -> C9FB   29 CSECTs   (plus one 0000)
  So C6C6 is the COMPILER's fill and C9FB is the ASSEMBLER's.
- WE HAD IT WRONG FOR ASSEMBLY.  compilePASS passed --fill=C6C6 to ASM101S.
  HALSFC takes no --fill option at all -- it emits C6C6 inherently -- so the
  compiler's value had been copied to the assembler, where the original build
  used C9FB.  Corroborated independently: 93 of Don's RUN objects, which are
  assembly and pre-link, hold C9FB in exactly the halfwords ours held C6C6.
  Changed assemblyFill to C9FB, with the measurement recorded beside it.
- CONSEQUENCE FOR run 12: it loaded the old value at start, so its 761
  assembly objects are still C6C6 and will need re-assembling before any DASS
  comparison of an assembly CSECT means anything.  Its HAL objects, which is
  what run 12 was for, are unaffected.
- SDL IS NOT A BUG FIX, IT IS A TARGET SELECTION.  A flight build does NOT use
  SDL; NOSDL is correct for compilePASS's normal purpose and remains the
  default.  --sdl is opt-in and exists only because the DASS images we compare
  against are SDL builds.  The same split applies to fill: a DASS-matching run
  wants --sdl and C9FB assemblies together.  The only genuine BUG in this area
  was --extra-parms being dropped at the compile call site.

### [2026-09-04] Target: problems.md
- **PTV_OSVS vs SMN_CLN IS SETTLED BY THE BINARY: KEEP PTV_OSVS.**  With SDL
  compilation, C9FB assemblies and --external-syms placement, $0SSPEXE comes
  out 189 halfwords -- the dump's own figure -- and differs from the real S2
  image in EXACTLY SEVEN.  The relocations at those seven sites are #ZPDSSEQ,
  #ZPDLIUS, #ZPMGGNC, #ZPMRSLR, #ZPMWSLW, #ZPMTSLG and #ZPTVOSV: precisely the
  seven-module CHANGE list in SM2MSPS.  The real image holds the SAME address
  (3A98) at all seven; ours holds seven distinct ones, because the link was
  given --external-syms without --concard and so never applied CHANGE.  The
  source is therefore correct as it stands -- SSPEXEC keeps CALL PTV_OSVS and
  PTVOSV.hal stays untombstoned.  Editing the source to call SMN_CLN would have
  produced a $0SSPEXE differing from DASS in a DIFFERENT seven places.
- WHAT MADE THE COMPARISON POSSIBLE, all three needed together:
      --sdl                          $0SSPEXE 191 -> 189 halfwords
      assemblyFill C9FB              assembly CSECTs stop differing on fill
      --external-syms augmented-S2   1243 of 1243 sections at the REAL address
  Whole-image result: 862 of 1207 same-size sections BYTE-IDENTICAL, up from
  157 before these three.  The remaining differences are dominated by CHANGE
  sites, which --concard would supply and --external-syms does not.
- A QUALIFICATION ON THE FILL RULE.  "One fill per CSECT, C6C6 for HAL and
  C9FB for assembly" was measured over ALIGNMENT GAPS and holds there (2012 of
  2012 HAL gaps are C6C6).  It does NOT hold inside a section: the real
  #DSSPEXE, a HAL data section, has C6C6 at +5 and C9FB at +A and +B.  Literal
  pools and gaps are filled differently.
- The theoretical 0x20000 address cutoff does not work in practice, as the user
  said: measured over 2345 gaps in all eight configurations, origin predicts
  the fill 98.6% and an address split at 0x20000 only 85.8%, with plain
  counterexamples on both sides (DAIESIP C6C6 at 0008BD, $0DCICYC C9FB at
  04233D).

### [2026-09-04] Target: problems.md
- **THE LINK IS DONE PROPERLY NOW: 976 of 1260 sections MATCH the DASS S2
  image**, against 157 when the comparison started.  The recipe is
  PFS/dass-link.sh, which carries its own reasoning; `dass-link.sh <tree> S2`
  reproduces 976 OK / 284 FAIL / 40 SKIP.
- FIVE THINGS HAD TO BE RIGHT, and each was found by measurement rather than
  from documentation:
  1. **SDL** on the HAL/S compile.  Worth every PROGRAM CSECT.  $0SSPEXE 191 ->
     189 halfwords, matching the dump exactly.
  2. **--fill=C9FB** on the assembly.  C6C6 is the COMPILER's fill; passing it
     to the assembler conflated the two.
  3. **--external-syms AND --concard together.**  external-syms places 1243 of
     1243 sections at the real address, which NO deck layout reproduces --
     con80build's own scores 0 of 327.  concard is still needed for the deck's
     CHANGE cards.  Neither alone is enough: 862 identical with external-syms
     only, 834 with concard only over it, 976 with both plus the rest.
  4. **The object list must be the configuration's own.**  Feeding all 1960
     objects left 1545 sections beyond the end of the real image; scoping to
     modules with a CSECT in augmented-S2.json took failures 1752 -> 290.
  5. **STACK cards removed from this release's decks.**  Under SDL a CON80
     STACK card is the ONLY trigger for generating an @-stack, and a generated
     stack is placed by deck layout rather than at its real address -- ALL 28
     misplaced sections were stacks and nothing else.  Removing the cards lets
     external-syms resolve the PDE's stack-address halfword instead, and 20 PDE
     sections come right.  The @-stacks are then absent from our image; they
     are pure fill in the dumps, so only coverage is lost.
- AND USE fcmcmp, NOT A HAND-ROLLED COMPARATOR.  It annotates each differing
  halfword with the RLD that owns it, honours an exceptions file for post-build
  patches and I-LOADs (exceptions-S2.txt, 1265 lines, worth 6 sections), and
  knows about no-reference-data cases.  My own comparator had none of that and
  its "content difference" counts were misleading throughout.
- THE CEILING IS A SOURCE-VERSION LIMIT, NOT A LINK ONE.  Mechanism 10 in the
  comparison database measured it over SSW: files at the SAME revision as the
  OI-34.07 build never differ, and 5.2% of revision bumps are visible.  Our 284
  residue is dominated by size mismatches -- #CPGGPCF is 6504 halfwords in the
  image and 10057 in ours -- which are OI340700 source differences we have not
  reconstructed, not link defects.
- KEY SECTIONS ALL PASS: $0SSPEXE, #DSSPEXE, #CSMNCLN, #ZSMNCLN, #EASCTIM,
  #EPGDATA.  53 of 70 PDE sections match.
