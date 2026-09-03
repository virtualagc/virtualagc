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
