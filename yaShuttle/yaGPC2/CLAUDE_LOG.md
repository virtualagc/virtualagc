# CLAUDE_LOG.md

(Cleared 2026-09-03 by Full Documentation Sync.  Twenty-six entries were applied
to `problems.md` and `HANDOFF-FCMBOOT.md`.  They are one continuous story — the
whole arc from "`OPS 901 PRO` did nothing" to an OPS 9 overlay that loads off
the tape, and the phase-8 descriptors that still block the transition — so they
were told as such rather than filed as twenty-six dated notes.

- **`problems.md`** (7619 → 8069 lines).  Three in-place corrections to
  **§8.29**, each of which had a wrong claim standing in the document: the
  `CZ2V_REC_XERR = 1` attribution (it is `ARC_OPS_TRANS` via
  `ARC_TRANS_COND = 2`, not `ARC_OPS_ZERO`'s MC test); "Does PASS ever try to
  read the tape? No" (it does — two POSITION commands carrying block address 0,
  and the supporting "92 trace lines from the IPL" was really 91 running to
  t=105.35 s); and `EAWATCH`'s `nia=`, which is the instruction AFTER the one
  that acted, making every watch-derived address in the document one late.

  Then five new sections carrying the rest: **§8.30** the phase tables were
  never stamped, one cause and five symptoms, plus the `FCMG3DAT` warning;
  **§8.31** the IPL SOURCE switch refusing every post-IPL mass-memory I/O, with
  the transaction-status-word decode and the `CRT none` finding as the same
  shape of trap; **§8.32** where the compool really is (0x23f4, because the tape
  puts it there) and why a table generated from a link map that does not
  describe this tape destroyed the GRT; **§8.33** the overlay loading, and why
  the enclosing load block must come from the table and not from a checksum
  search; **§8.34** what the DASS dumps can and cannot settle — the three
  corrections needed before any comparison meant anything, of which the
  post-build patch summary was the user's find and the decisive one; and
  **§8.35** the four controlled experiments on phase 8, including the one that
  invalidated a whole evening's tapes.

  Five new method failures in **§8.10**: an address is not self-describing;
  decoding what the software concluded is not evidence for why; check the fill
  convention and the reference build before scoring a comparison; isolate one
  variable even when the change looks too mechanical to matter; and a log line
  is not a symptom until it is diffed against a passing run.

- **`HANDOFF-FCMBOOT.md`** (1342 → 1500 lines).  "WHERE IT STANDS RIGHT NOW"
  rewritten — the overlay loads, the front of the work is phase 8 — with the
  volume inventory, since several tapes were built and only `pass-stamped.mmv`
  is good.  "What is actually still open" replaced its two stale bullets with
  the phase-8 state, the two hard constraints (`y` is not free; `disp` cannot be
  relocated), the open `do_read` question, and why a 100%-correct tape needs
  approach #2.  A new reference subsection under "Addresses you will need"
  gives `#PFCMGPT`'s layout from `FCMGPT.hal` and the rules that took
  experiments to establish.  Four new tools in §4, `YAGPC_WAITTRACE` and the
  multi-image `YAGPC_LOADBIN` in the instrumentation list, and traps 29–32.

Two things deliberately carried into the documents as OPEN rather than settled,
because both would be easy to "fix" wrongly: whether `mmumodel.c:do_read` is too
strict in capping a transfer at the 256-block unit — the flight software plainly
builds multi-track transfers — and why relocating the descriptor block breaks
the transition at all.)

### [2026-09-03] Target: [HANDOFF-FCMBOOT.md]
- **RETRACTED BEFORE IT WAS EVER SYNCED: the "no disp may change" entry that
  stood here.**  All nine runs behind it left the IPL SOURCE switch at MM1,
  which blocks every post-IPL mass-memory I/O (problems.md 8.31), so none of
  them could read an overlay whatever the tape said.  Control: the KNOWN-GOOD
  pass-stamped.mmv, unmodified, fails identically under that invocation.
      pass-stamped.mmv, SOURCE OFF  -> overlay read
      pass-stamped.mmv, SOURCE MM1  -> NO overlay read
      all nine experimental tapes, SOURCE MM1 -> NO overlay read
  problems.md 8.35 and the handoff's "two hard constraints" have been rewritten
  as retractions.
- **AND THE RE-RUN REVERSES THE CONCLUSION: `disp` CAN MOVE.**  pass-after8.mmv
  (phase 8 held at disp=313, phases 9-18 moved +3, all descriptors identical),
  re-run with SOURCE_RUN=OFF RUN_AT=130:
      read  26 block(s) from 3/3/6/0   t=242.7s    phase 3, MF overlay
      read 110 block(s) from 2/5/4/0   t=244.1s    phase 8, program overlay
  which is the known-good behaviour.  So shifting later phases is harmless and
  GROWING PHASE 8 IS VIABLE.  Whether `y` is constrained is still unmeasured --
  those runs were blocked too and have not been repeated.
- **ALWAYS PASS `SOURCE_RUN=OFF` (and the baseline also used `RUN_AT=130`).**
  headless-gpcmem.sh defaults SOURCE_RUN=MM1, which is the value that BLOCKS
  mass-memory I/O, so the default invocation cannot perform an OPS transition at
  all and fails silently and identically no matter what is on the tape.  Worth
  considering whether that default should change, or whether the rig should
  refuse to run an OPS-transition scenario with the source made.
- The durable result, independent of any run: **y is NOT sum(ceil(len/512))** --
  that reproduces only 8 of 16 phases (phase 3 gives 38 against the real 37,
  phase 15 115 against 90).  It is right for phase 8, which is exactly why an
  identity test on phase 8 alone hid it.
- New tool `tools/rewrite_phase_descriptors.py` stands on its own: rewrites a
  phase's descriptors in place, shifts later phases, repairs the enclosing
  checksum; `--verify-identity` reproduces the volume byte for byte on phases
  3, 4, 7, 8, 12 and 15.  Nothing in it depended on the broken runs.
- Descriptor content, best available and unaffected: lengths unambiguous for 87
  of 110 MM blocks (35 blocks, zero ambiguity, stalls at tape 44544);
  destinations credible for ~28 of 35 once each block is scored over its OWN
  length against the as-built image -- the three ZCON blocks then place at 100%.

### [2026-09-03] Target: [problems.md]
- **discretePanel's focus fix was never broken; the rig started calling it a
  dozen times a day.**  `--script` built the full Tk GUI exactly like
  interactive mode, and `_dont_steal_focus()` hands the keyboard back ~400 ms
  AFTER mapping, so every scripted run opened a gap in which the user's
  keystrokes were swallowed by the panel's `<Key>` binding rather than
  delivered to whatever they were typing into -- plus a window that sat on the
  desktop for the 8-9 minutes of each run.  Fixed in `bd270a6b5`: with
  `--script` the root stays withdrawn and is never mapped, which is the only
  reliable answer; Tk runs `_run_script`'s `after()` timers fine while
  withdrawn.  Interactive use unchanged.  `headless-gpcmem.sh` has always
  printed "discretePanel (scripted, headless)" and it was not headless until
  now.

### [2026-09-03] Target: [problems.md]
- **THE LOAD-BLOCK RULE, and it removes the need for any grouping heuristic: a
  load block is a MAXIMAL CONTIGUOUS RUN of memory the phase writes.**  Every
  one of phase 3's nine block boundaries has a large gap behind it -- 938 to
  99,026 halfwords, measured from the tape's own IPL table.  There is no
  grouping rule to reverse-engineer; the blocks fall out of the footprint.
  That locates mmbstamp's defect: `_open_bank_tails` and `_extend_mc_bank_tails`
  reshape lengths from inferred MMB rules, i.e. they solve a problem that does
  not exist, and they are where its three wrong phase-3 lengths come from.
- **BLOCKS WITHIN A PHASE ARE STRICTLY ASCENDING AND NON-OVERLAPPING.**
  Verified on ALL 48 ground-truth blocks across phases 10, 2, 13 and 3 (the
  tape's own IPL table).  This was asserted early, then RETRACTED on the
  strength of phase-8 window placements that were unreliable -- wrong
  boundaries, no fill or relocation credit, and produced alongside the blocked
  harness.  **The retraction was the error.**  Dropping the constraint is what
  made phase-8 destinations look like 35 independent guesses; they are a
  monotone assignment, which is enormously more constrained.
- Consequence for AUTOMATION: those two together mean the load blocks are fully
  determined by ONE input -- the set of addresses each phase writes.  No
  heuristics, no relocation model.  Build order is footprint -> maximal runs ->
  blocks -> checksums, padding, table.  For a from-source build that input is
  PHASEnn.lib and the problem is solved.
- **Phase membership is NOT in the DASS maps.**  Checked `type`, `initial` and
  `invariant` on the section inside vs just before each of phase 3's ten blocks:
  nothing separates them.  But it IS approximately recoverable by DIFFING
  CONFIGURATIONS -- halfwords where all five GNC dumps agree and both S2 and P9
  differ, merged across gaps of ~1024, recover 6-7 of phase 3's 10 blocks.  A
  genuinely independent signal, never used before, worth sharpening.
- The tape does NOT describe itself.  Decoded the on-tape IPL table's header at
  halfword 684294: 4 x (idx, nblks, mmaddr) -- phase 10 (5, 0x2260), 2 (31,
  0x2300), 13 (2, 0x1b00), 3 (10, 0x1bc0) -- three redundant copies 256
  halfwords apart.  Only the four IPL phases; no complete table exists on the
  volume.
- Phase 8 under the monotone solve: **27 of 35 blocks placed**, every one at a
  section start, ascending and non-overlapping by construction, scores 70-100%
  against the as-built image.  The constraint ELIMINATES bad placements rather
  than inventing them -- the greedy non-overlap version had forced block 10
  (4538 halfwords) to a 3.6% address; the monotone solve drops it instead.
- **A conflict the law exposes and scoring cannot**: in the stalled region,
  windows 90-95 (0x232aa..0x23caa) and windows 99-104 (0x12af0, 0x21f30) both
  score 93-97% and are mutually exclusive under ascending order.  The likely
  cause is visible in the names -- $0VB2LEV, A4VB2LEV, A6VB2LEV, B0VB2LEV are
  numbered variants of one routine, so a fingerprint matches the wrong copy at
  high confidence.  Raw scoring cannot detect that; the ordering constraint can.

### [2026-09-03] Target: [problems.md]
- **MEASURING THE LOAD'S EFFECT, INSTEAD OF INFERRING IT.**  Snapshotted main
  storage either side of the transition (YAGPC_SNAPSHOT=235,250 with
  SOURCE_RUN=OFF RUN_AT=130) and asked what the overlay actually did.  Three
  facts, all measured:
    1. The loader WORKS.  26 of mmbstamp's 27 phase-8 blocks are written to
       memory at their declared addresses, at 85-100% of their halfwords.
    2. The CONTENT IS WRONG.  Mean agreement with the OI340700 as-built image
       across those 27 regions goes 68.7% BEFORE the load to 24.8% AFTER.  The
       overlay degrades memory that was already correct -- blocks 4, 5, 7, 8,
       16, 17, 18, 22, 23, 24, 26 and 27 were at ~100% and were wrecked.
    3. ARC exits its phase loop after ONE iteration.  MC 9 loaded phases 3 and
       8 then stopped before 18; MC 6 loaded phase 9 then stopped before 12.
  So the descriptors are wrong -- which was the original conclusion -- but the
  evidence used for it ("only 1 of 27 blocks checksum") was never testing the
  descriptors.  It was testing MY packing model of where each block sits on the
  tape, and that model is what is wrong.
- **THE MULTI-GPC HYPOTHESIS IS REFUTED.**  ARCGPC.hal:979-1001 ORs
  ARC_OVL_TSW$(2:12 TO 16) -- five bits, one per GPC -- into ARC_OVL_ERR, clears
  bits only for GPCs that are neither source nor destination ("IGNORE IDLER
  ERRORS"), exits the phase loop on any survivor and zeroes ARC_MF_PG_PH.  MC 9
  targets GPCs 1-4 and the rig has one, so the missing three looked like the
  cause.  They are not: MF PL OPS 9 is GRT index 6, set 4400 = GPC 2 ALONE, and
  run as GPC_ID=2 DEUMF=0 it fails the SAME way -- phase 9 loads (23 blocks from
  3/3/4/0), phase 12 never does.  ARC_OVL_ERR is being set for SELF.
- Also checked and CLEAN, so nobody re-checks them: the GRT is intact across the
  transition (CZ2B_GRT_GPC_SET and CZ2V_GRT_TAB identical before and after);
  phase 18 IS allocated (35 contiguous blocks from index 11776, y=11 fits);
  CZ2V_GRT_MC_PHASES correctly reads MC 9 = 3, 8, 18; REC_XERR = 0 at the
  DM2APP level; and wordsLost=720 is CONSTANT across every run including the
  known-good baseline and a control that performs no overlay at all, so it is
  the deliberate "clear the MIA buffer" reads and not an error.
- **THE REAL GAIN IS A NON-INFERENTIAL ORACLE.**  Any candidate descriptor set
  can now be SCORED by running it: mean agreement with the as-built image over
  the written regions, before versus after.  mmbstamp scores 68.7 -> 24.8, i.e.
  actively harmful.  A correct set must score upward.  Every previous method
  tried to prove a descriptor set correct offline; none ever measured whether a
  load helped or hurt, and that measurement takes one run.
- METHOD NOTE: every earlier approach -- checksum walks, bgrep anchoring, sparse
  fingerprints, as-built scoring, section-start filtering, monotone DP -- was
  the same move, inferring blocks by matching tape bytes against a dump, each
  round making the matching cleverer.  None asked the running machine what it
  did.  Both instruments used here (snapshot subtraction, and reading ARC's own
  logic against its recorded state) were available the whole time.


### [2026-09-03] Target: [problems.md]
- **FIRST DESCRIPTOR SET THAT IMPROVES MEMORY, AND A MEASURED CEILING.**
  Scoring = mean agreement with the OI340700 as-built image over the regions a
  load writes, snapshotted before and after (YAGPC_SNAPSHOT=235,255,
  SOURCE_RUN=OFF RUN_AT=130):
      candidate, 35 descriptors, checksum lengths + monotone dests
                                            53.3% -> 68.2%   IMPROVES
      mmbstamp, 27 descriptors              68.7% -> 24.8%   DESTROYS
      phase 3, KNOWN-GOOD descriptors       94.3% -> 94.2%   <- THE CEILING
  **The ceiling is ~94%, not 100%**, because the tape is OI340600-derived and
  the reference is OI340700.  Phase 3 scores flat because it is already
  resident, so reloading writes identical values -- which is the correct
  behaviour, not a null result.  Without this measurement the obvious mistake is
  to tune phase 8 toward a 100% that does not exist.
- 68.2% against a 94% ceiling means about a quarter of the achievable gap is
  still error, but it is now a NUMBER THAT RESPONDS TO CHANGES, one run apiece.
- **`y` IS NOT THE TRANSFER LENGTH.**  It stayed at 110 while the machine read
  **86** blocks -- matching the 35 descriptors' own consumption (87), not the
  header.  So the read length is derived from the descriptor list and `y` is at
  most an upper bound.  This retires the remaining "y is constrained" reasoning.
- **The candidate causes a RETRY; mmbstamp's does not.**  FCMMGPOV retries an
  unsuccessful overlay exactly once and the trace shows two identical 86-block
  reads.  So the flight software DETECTS a fault with the candidate, where
  mmbstamp's set passes validation and silently writes wrong data.  Likely cause
  of the fault: 35 descriptors consume 87 MM blocks but only 86 were read, which
  truncates the final block and fails its checksum.  Data is still written on
  the failed attempt -- memory improved anyway.
- The machine did NOT halt on the candidate tape (SIGINT at t=268, normal end),
  unlike several earlier attempts.
- Tapes: pass-cand.mmv is the candidate; pass-stamped.mmv remains the reference.

### [2026-09-03] Target: [problems.md]
- **THE ORACLE IS PER-DESCRIPTOR, WHICH MAKES THE PROBLEM CONVERGENT.**  Scoring
  each block's destination separately (agreement with the as-built image over
  that block's own extent, before vs after the load) turns a single pass/fail
  into 35 independent verdicts:
      19 blocks improved by >5 points, 5 degraded by >5, 10 roughly neutral
  Biggest gains +43 to +59 (blk 5 -> 0x005a2, blk 9 -> 0x04754, blk 12 ->
  0x0a22e, and the whole #DV* family).  So MOST destinations are already right
  and a handful are wrong -- identified by measurement, not argument.
- **The worst offender proves the truncation independently.**  Block 35
  (tape 43520, len 1018 -> 0x101f8, #CASLTMC) was the HIGHEST-confidence
  placement in the set, 100% content match over 1015 halfwords, and writing it
  scored 100.0% -> 1.0%.  The only way that happens is that the data written
  there is not block 35's content -- which is what a truncated transfer
  predicts, since it is the last block and the read came up one MM block short.
- **WHY THE TRANSFER TRUNCATES**: the EXTENDED BLOCK command carries (count-1) --
  mmbstamp 0x6d=109 -> reads 110, candidate 0x55=85 -> reads 86 -- and
  FCMBKTRK is initialised to -1 (FCMMGBOV, "INIT # OF BLOCKS PER TRACK TO -1").
  A final load block that STRADDLES an MM-block boundary comes up one short.
  mmbstamp's last block sits inside a single MM block (tape 55808, len 22) and
  its transfer is accepted -- with wrong data.  The candidate's last block spans
  two (tape 43520, len 1020) and its transfer is refused and retried.
  NOT YET CONFIRMED -- the 34-descriptor test (last block dropped, list ending
  inside one MM block) is what settles it.
- Other blocks measured WRONG and worth re-placing: 11 (0x0ebbc, -53.7),
  32 (0x0e4e2, -27.5), 31 (0x0e48e, -18.8), 33 (0x0f158, -17.8).

### [2026-09-03] Target: [problems.md]
- **THE DESYNC IS FIXED, AND THE METHOD THAT FOUND IT IS THE POINT.**  Take what
  the loader actually WROTE at each destination (from the after-snapshot) and
  search for that content on the tape.  That gives the tape offset the loader
  really used for each descriptor, measured:
      blk 28  declared 35840 -> found at 35840   ok
      blk 30  declared 36864 -> found at 36352   OFF BY -512
      blk 31, 32, 35 ...                          OFF BY -512
  Everything through block 28 correct; from block 30 the loader is one MM block
  behind.  One block of consumption was lost at BLOCK 29 and every descriptor
  after it received its neighbour's data.
- **CAUSE: block 29's destination was in the wrong SECTOR.**  Its descriptor was
  addr=0x8365 flags=0x0690 -- sector 9, destination 0x48365 -- from the weakest
  fingerprint in the set (33.3%), while every neighbour is sector 1.  The
  ascending law confines a block between blk 28 (0x0e410, 40 hw) and blk 30
  (0x0e460) to 0x0e44e..0x0e45f, and that window holds exactly three 6-halfword
  sections for a 6-halfword block.  #DVM1BFD at 0x0e454 scores 66.7% vs 33.3%.
  Changing only that one field:
      read 87 blocks (was 86) -- matches consumption exactly, desync gone
      score 51.4% -> 76.7% (was 70.3%)
      24 of 34 blocks improved; degraded blocks 5 -> 3
  So a single mis-sectored 6-halfword descriptor was costing an entire MM block
  of transfer alignment.  Presumably FCMMGBOV's BCE-segment/DSR handling.
- Scoring history: mmbstamp 68.7->24.8 (destroys); 35 desc 53.3->68.2;
  34 desc 51.9->70.3; block-29 fix 51.4->76.7.  Ceiling 94.2 (phase 3).
- **REFUTED ALONG THE WAY**: (a) that the shortfall was a final block STRADDLING
  an MM-block boundary -- the 34-descriptor set ended inside one block and still
  ran short; (b) that a sacrificial tail descriptor would absorb it -- it
  changed nothing, correctly, since the loss is in the middle not the end.
- STILL OPEN: the transfer is still RETRIED (two identical 87-block reads), so
  the I/O is still reported unsuccessful and ARC will not credit the overlay.
  And blocks 11 (0x0ebbc, -42.9) and 32 (0x0e4e2, -13.8) remain measurably
  mis-placed.

### [2026-09-03] Target: [problems.md]
- **WHY THE OVERLAY I/O IS STILL REJECTED: eliminations, all measured.**  After
  the block-29 fix the transfer is structurally sound -- 87 blocks read, ALL 35
  descriptors' checksums verify at their implied tape offsets, data lands at
  76.7% -- and FCMMGPOV still retries it.  Ruled out one run apiece:
      y matched to consumption (y=110 -> 87)      still retried
      26 descriptors instead of 35                still retried
      final block not straddling an MM boundary   still retried
      a sacrificial tail descriptor               changed nothing
      every descriptor's checksum                 0 of 35 fail
  So it is NOT y, NOT the descriptor count, NOT the checksums, and NOT the
  block structure.
- **REC_XERR = 101 now appears** where every earlier run reported 0.  ARCGPC
  sets ARC_XERR_PAD=100, so that is error code 1 plus the pad: ARC now REACHES
  its overlay-error path and records the failure, where with mmbstamp's
  descriptors it failed silently.  Better observability, not yet a better
  outcome -- and I cannot yet distinguish "my transfer is worse in a new way"
  from "the machine now gets far enough to notice".
- The MMU side is clean throughout: BITE STATUS, POSITION, EXTENDED BLOCK, READ,
  87 blocks, READY toggling, no faults.  The rejection is recorded on the GPC
  side.  SVCTRACE shows the SVC after the ACCEPTED phase-3 read and after the
  REJECTED phase-8 read are identical except for the base register
  (08820882 vs 08822f3c), so the status is not visible at that level.
- **The one structural difference left is COVERAGE.**  mmbstamp's accepted set
  consumes exactly 110 MM blocks -- the phase's full allocated extent -- and
  every set of mine consumes less (69, 85, 87).  Under test with the right
  control: mmbstamp's OWN descriptors with only the last one dropped, so no
  content of mine is involved.  If that retries, coverage is the criterion, and
  the 23 MM blocks past the checksum walk's stall are REQUIRED rather than
  optional -- which would make recovering them the critical path.

### [2026-09-03] Target: problems.md
- BISECTION LOCATED THE PHASE-8 OVERLAY REJECTION.  Hybrid descriptor sets
  (mmbstamp's below a shared tape offset, mine above) flip acceptance, so the
  offending descriptor can be found without a theory of WHY.  Steps: switch at
  tape 2560 -> REJECTED; at 11776 -> ACCEPTED; so the fault lies in my blocks
  6-10 (tape 2560..11776).  Isolating block 6 alone -> ACCEPTED, so block 6 is
  innocent and the fault is in blocks 7-10.
- THE LOADER DOES NOT VERIFY LOAD-BLOCK CHECKSUMS.  mmbstamp's descriptors fail
  the checksum at their implied tape offsets and are accepted anyway; a hybrid
  padded with FABRICATED filler descriptors (arbitrary content, wrong checksum)
  is also accepted.  This retires an assumption used earlier to argue that a
  wrong block length would be rejected -- it would not be.
- BLOCK COUNT IS NOT THE DISCRIMINATOR.  headless-hy (RETRIED) and headless-hy2
  (ACCEPTED) both read 87 blocks.  Across all runs, accepted reads are 87, 109
  and 110, so the read count tracks the descriptor walk length, not `y` (which
  stayed 110 throughout).
- MY DESTINATIONS ARE LESS INVASIVE THAN MMBSTAMP'S, so "rejected because of
  what it overwrote" is not a general explanation: mine put 0 blocks in the CZ2
  compool against mmbstamp's 3, and 2 in low core against 1.

### [2026-09-03] Target: problems.md
- BLOCK 10'S DESTINATION IS WRONG, AND IS THE PRIME SUSPECT.  Of blocks 7-10 it
  is the only one overlapping an I/O control CSECT: it starts at 26420, which is
  32 halfwords INSIDE FIOCDATG (26388..26530), the FIO data CSECT on the GTG /
  mass-memory path, then runs 4540 halfwords over it.  Overwriting the control
  data of the transfer in progress would abort and retry it, which fits the
  observed inverse correlation between correctness and acceptance.  Blocks 7, 8
  and 9 touch only display/data CSECTs.
- The +32 is the tell: a load block starts on a CSECT boundary, so the true
  destination is likely 26388 (0x06714), not 26420.  Same class of error as
  block 29's sector desync.  Block 10 also has the worst measured agreement of
  the set (48.6%) and was the one destination that is not a section start.
- Block 6 sits exactly on the $X080001 patch area (1538..1617), confirming the
  guessed destination that placement could not measure.

### [2026-09-03] Target: problems.md
- RETRACTION of the "+32 is the tell" note logged earlier today.  Block 10's
  destination is NOT off by 32.  Scanning every destination in a +/-64 halfword
  window against the as-built image, 26420 (0x06734) is the BEST at 47.4%, and
  the FIOCDATG boundary 26388 does not place in the top eight.  Moving the block
  to the CSECT boundary makes agreement WORSE.  The reasoning ("a load block
  starts on a CSECT boundary, so the +32 must be an error") was sound in general
  and simply wrong here; it was written before it was measured.
- WHAT THE PROFILE ACTUALLY SHOWS.  Agreement along block 10 oscillates --
  100% at +512, 7% at +2944, 100% again at +4096.  A wrong start address gives
  uniformly bad agreement, so this is not a misplacement of one block; it is one
  descriptor SPANNING SEVERAL TRUE LOAD BLOCKS, with the agreeing stretches
  being where the tape data happens to land correctly.
- WHY IT WAS BUILT WRONG.  Across the nine 512-halfword windows block 10 covers
  (windows 14-22), every per-window placement is low confidence (11%-64%) and
  the implied destinations are mutually inconsistent (deltas of -42710, +9698,
  +532 between adjacent windows).  The DP solver had no real signal in this
  region and merged the windows anyway.  Block 10 is likely wrong in BOTH length
  and destination, and low per-window confidence should be treated as a signal
  to SPLIT rather than to merge.

### [2026-09-03] Target: problems.md
- THREE TAPE WINDOWS OF PHASE 8 HAVE NO HOME IN MEMORY.  Windows 14-16 of the
  phase-8 data stream are ~94% fill (28, 28 and 33 non-fill halfwords of 512).
  Treating the non-fill halfwords as a fingerprint and searching the ENTIRE
  as-built image (330394 halfwords, all 10 sectors), the best match anywhere is
  3/28, 3/28 and 8/33 -- noise.  This is NOT the OI340600/OI340700 version gap:
  a version difference would still leave a strong partial match somewhere.
  Whatever those windows are, the as-built G9 memory does not contain them.
- A CONCRETE MECHANISM FOR THE OVERLAY REJECTION.  My block 10 starts at
  0x06734, so its first window -- one of the unplaceable, fill-dominated ones --
  is written over 0x06734..0x06933.  FIOCDATG occupies 0x06714..0x067a2, inside
  that range.  So the block writes junk over the FIO data on the GTG /
  mass-memory path WHILE THAT PATH IS EXECUTING THE TRANSFER, which would abort
  and retry it.  mmbstamp's descriptors do not write there, which is why the
  wrong-but-harmless set is accepted and the mostly-right one is not.  This
  finally explains the inverse correlation between correctness and acceptance.
- CAUTION: the mechanism is inferred, not yet proven.  The isolation run putting
  my block 10 alone into an otherwise-accepted set is what tests it.

### [2026-09-03] Target: HANDOFF-FCMBOOT.md
- METHOD THAT WORKED WHERE THEORY DID NOT.  After many failed theory-driven
  hypotheses, the rejection was localised by BISECTION over descriptor sets:
  build hybrids that take mmbstamp's descriptors below a tape offset shared by
  both walks and mine above it, and see which half flips acceptance.  Because
  the loader ignores load-block checksums, FABRICATED FILLER descriptors can pad
  a walk to the next shared offset, which turns the coarse split into
  single-block isolation.  Blocks 1-5 and block 6 were cleared this way.
- Content matching cannot place fill-dominated windows: maximising percentage
  agreement makes three different windows all "best-place" at one address
  (0x013bc, 94%) because fill matches fill.  Require the non-fill halfwords to
  match as a fingerprint instead, and the false placement disappears.

### [2026-09-03] Target: problems.md
- RETRACTION, SAME DAY, of the FIOCDATG mechanism logged immediately above.
  Isolating my block 10 into an otherwise-accepted descriptor set gives ONE read
  of 88 blocks -- ACCEPTED.  Block 10 does write unplaceable fill over
  0x06734..0x06933, which contains FIOCDATG (0x06714..0x067a2), and the transfer
  succeeds regardless.  So the flight software TOLERATES having the FIO data on
  the GTG/mass-memory path overwritten during the transfer, and "the load
  clobbers the I/O control structures" is not the explanation for the rejection.
  The hypothesis was logged before it was tested, and the test refuted it.
- Blocks 1-5, 6 and 10 are all now cleared individually.  The fault is in block
  7 (tape 3072, len 242, dest 0x03fe0), block 8 (tape 3584, len 1660, dest
  0x040d4) or block 9 (tape 5632, len 1300, dest 0x04754).  Their destinations
  are display/data CSECTs (#PCDAP08, #DASCTIM, @0-tables), nothing on an I/O
  path -- so whatever the mechanism is, it is not the one just retracted.
- STILL TRUE AND STILL UNEXPLAINED: windows 14-16 match nothing in the as-built
  image.  That finding is independent of the retracted mechanism.

### [2026-09-03] Target: problems.md
- NO SINGLE DESCRIPTOR CAUSES THE PHASE-8 REJECTION.  Isolated into an otherwise
  accepted set, EVERY candidate is accepted: blocks 1-5, block 6, blocks 7+8,
  block 9 and block 10 each give one read.  Yet blocks 6-35 together are
  rejected while 11-35 together are accepted.  The fault is therefore a
  COMBINATION within blocks 6-10, not a property of any one of them.
- CORRECTION: "block 9 is the fault", inferred when blocks 7+8 came back
  accepted, was unsound and is withdrawn.  Elimination across a set is only
  valid if the property is additive over its members, and this one is not --
  block 9 alone is accepted.  The direct group control (my 6-10 with mmbstamp
  elsewhere) is the test that should have been run instead of inferring.
- This revives the "destructive write" family of explanations, which the block-10
  result had appeared to kill: a single block's damage may be survivable where
  the accumulated damage of five is not.

### [2026-09-03] Target: problems.md
- A CHECKSUM-DRIVEN BLOCK WALK RECOVERS PHASE 3 BUT DOES NOT GENERALISE.  Walking
  the tape and ending each block at the first L where hw[L-2]==0 and
  hw[L-1]==sum(content)&0xffff recovers 9 of phase 3's 10 known blocks exactly,
  offset AND length.  On phase 4 it gets 1 of 17.  ONE PHASE IS NOT A
  VALIDATION; do not promote this to a general method on the strength of phase 3.
- Phase 4's data region on this tape is 88% c6c6 (7239 of the first 8192
  halfwords), so that phase may simply not be populated here and may not be a
  fair test -- but phase 3 alone cannot establish the method either way.
- THE "MAJORITY c6c6 => BLOCK END" RULE IS UNSAFE ON PHASE 8.  It holds on phase
  3 (every padding-dominated window is a block's last window, 0 mid-block), but
  phase 8 windows 12-16 are majority c6c6 as REAL CONTENT: their non-c6c6
  halfwords come in runs of exactly 6, and every #E* CSECT in the map is exactly
  6 halfwords, so these are 6-halfword entries with genuine c6c6 between them.
  Boundaries the rule derives there (6144..8192) may be false.
- Still standing: my blocks 8, 9, 10 and 32 each span a boundary the rule
  derived, and block 32 was independently measured as a bad destination.

### [2026-09-03] Target: problems.md
- BLOCK 10 IS NECESSARY BUT NOT SUFFICIENT for the phase-8 rejection.  Group
  control {6,7,8,9,10} REJECTED (two reads of 110); {6,7,8,9} with block 10
  dropped ACCEPTED (one read of 110); block 10 alone ACCEPTED.  So the failure
  needs block 10 PLUS at least one partner among 6,7,8,9.
- WHAT BLOCK 10 DESTROYS.  It is the only block in the group writing to a
  control-path CSECT: it overwrites 111 of FIOCDATG's 143 halfwords, from offset
  32 on.  The first 32 halfwords (FIOHFDEL, FIOTMSRT, FIOHFDIV, FIOHFDZ1/2,
  FIONMDZ1/2, FIOHFORM, FIOTMIOC, FIOHFCY2, FIOHFECY, FIOFCNDX) SURVIVE; the
  clobbered part is FIOHFECF, FIOADBST, TIOQP001, TIOQP002, TIOQP014, TIOQP015,
  FIOCF305, FIOCF102, FIOCFSAV.
- TIOQP001 IS A PREINITIALISED IOQE, not inert data: FPMIHPC2.asm:710 does
  "LA R0,TIOQP001  GET PREINIT IOQE ADDR FOR HFE INPT".  So the block destroys
  preinitialised I/O queue elements that other paths hand out by address.  That
  is survivable alone and evidently not once something else is also damaged.
- mmbstamp's writes over the same tape range are ENTIRELY DISJOINT from mine
  (7824 halfwords written by mine, 0 shared), and FIOCDATG is the only
  control-path CSECT mine hits that mmbstamp's does not.

### [2026-09-03] Target: HANDOFF-FCMBOOT.md
- STRATEGIC: BISECTION IS NOW CHASING A SYMPTOM.  Every descriptor is accepted
  alone and the group is not, and the damage in question is wrong DESTINATIONS
  in aggregate.  Isolating the exact offending pair still leaves the fix as
  "move that destination", which is the open problem for all 35 blocks.
- The root limitation is the placement method: matching tape content against the
  as-built image fights two handicaps bisection cannot remove -- the tape is
  OI340600 while the reference image is OI340700, and much of phase 8 is
  c6c6-dominated, where content matching is provably degenerate (three separate
  windows "best-place" at one address at 94%).
- The structural fix is to take destinations FROM THE BUILD (the phase's memory
  footprint from the OI340600 link) instead of inferring them from a dump.  That
  converts 35 uncertain placements into a derived list.

### [2026-09-03] Target: HANDOFF-FCMBOOT.md
- THE BUILD RECORDS PHASE MEMBERSHIP; EARLIER CLAIM RETRACTED.  I had concluded
  that nothing in the build says which CSECTs belong to a phase, and that
  deriving destinations from the build was closed off.  Wrong -- I was reading
  only derived artifacts.  `OI340600/CON80` is the linkage-editor control deck
  library: `OFTMP` is the master deck (ONE link over the whole overlay tree) and
  states membership directly ("PHASE 8,18" / "INCLUDE CONCARDS(PHASE08)").
  PHASE08 expands to MAP2, MAP3, OVERLAY Z3, PATCH08, GNC9, leaves are INSERT.
- CON80 also holds the MMU build: MMLOAD says "IPL,PH=(10,2,13,3),SYSID=SYS1,
  MMDIR=44000;", identical to the on-tape IPL phase table reconstructed by hand,
  which corroborates that these decks are the real build inputs.
- `con80build` ALREADY DOES THIS and is documented in RUNBOOK-IPL-MEDS.md A.1:
  "reads the CON80 card deck, works out which modules belong to a phase,
  assembles/compiles them and links a load module", `--master OFTMP` default.
  tools/phase_from_condeck.py duplicates part of its front end; prefer
  con80build for building, and keep the new tool only for deriving TAPE
  DESCRIPTORS, which con80build does not produce.

### [2026-09-03] Target: problems.md
- DERIVING DESCRIPTORS FROM THE DECK REPRODUCES PHASE 3 EXACTLY: 10 of 10
  destinations and 10 of 10 lengths against the tape's ground-truth IPL table,
  0 spurious.  Three corrections were needed and each was forced by validation:
  (a) INSERT cards are not the whole phase -- OFTMP's "LIBRARY ZCONLIB(ZCON)"
  autocalls members that never appear on a card, so INSERT names must be
  resolved to OBJECT FILES via the .obj ESD records and every CSECT that object
  defines taken (one HAL/S compilation emits #C/#D/#Z/#X/#E under one object);
  (b) the run-merge tolerance is 32 halfwords, not 2 (within-block CSECT gaps
  reach 4, between-block gaps are 938+); (c) block lengths are even.
- A GREEDY WALK CANNOT DO IT.  Accepting a spurious run consumes the next real
  block's length and desyncs everything after; a tolerance tight enough to
  reject it also rejects real blocks whose autocalled tail runs far past the
  deck's hint (phase 8's 0x005a2 hints 36 where the block is ~148).  A search
  that maximises the number of runs placed at checksum-valid lengths does both.
- PHASE 8 DOES NOT COME OUT CLEANLY YET: 98 INSERT names expand to 162 CSECTs
  and 45 runs (phase 3: 105 -> 130 -> 11), of which the search places only 19,
  some at implausible lengths (0x30322 hint 136 -> 6538).  Only 9 of 45 deck
  destinations coincide with the content-matched set -- and those 9 are exactly
  the low-address blocks derived most reliably (0x001f8, 0x00242, 0x005a2,
  0x03fe0, 0x040d4, 0x04754, 0x0a3ee, 0x0a70c, 0x101f8).  Since the method is
  exact on phase 3, the likely reading is that the CONTENT-MATCHED SET IS WRONG
  beyond its first few blocks, consistent with blocks 8/9/10 spanning real
  boundaries and 11 and 32 measuring bad.  Not yet proven either way.
