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
- **NO `disp` IN #PFCMGPT MAY CHANGE AT ALL.  This freezes every phase's
  descriptor COUNT and blocks the phase-8 fix.**  Three tests, each on an
  otherwise byte-identical copy of pass-stamped.mmv with the enclosing checksum
  repaired and verified:
      phase 8 disp 313 -> 775, phases 9-18 untouched     -> FAILS
      phases 8-18 disp all +3, descriptors identical     -> FAILS
      phases 9-18 disp +3, phase 8 left at 313           -> FAILS
      (baseline)                                         -> works
  The third is the operative one: `disp` is the START of a phase's descriptors,
  so GROWING phase 8 leaves its own disp at 313 and moves only the phases after
  it -- which is exactly what that tape did.  A raw diff confirms it carried
  nothing else: ten changed disp fields, a clean +3 shift of the load-block
  region 394..777, phase 8's descriptors untouched.  Phases 9-12 and 14-17 are
  not even in GNC OPS 9's configuration (3, 8, 18 are) and moving them still
  breaks it.
- Ruled out, so nobody re-checks them: the load-block tail (GPT offsets
  775..1092) is genuinely all zeros in the known-good tape, so zeroing it is a
  no-op; and the original stamping changed only four regions -- #PFCMGPT
  0..774, #PCDCPHA, and the two enclosing block checksums (623713, 634537) --
  so there is no fifth thing the rewrite tool fails to update.
- Mechanism UNKNOWN.  FCMMGBOV:186-196 reads disp as a plain index off the
  FIOMGPTZ base (`R4=(phase-3)*4 / R5=table[R4] / STH R5,TDBGPTIX`), nothing
  constrains its value, and AIBGPCLO:895 writes only FCMMGPT_STARTING_MM_ADD,
  never disp.  Six modules reference FIOMGPTZ -- FCMMGBOV, FCMMGPOV, FCMUPLOD,
  FCMZCONS, FIOMGCV, FIOMGDSP -- and only the first two have been read.  Start
  there.
- **Consequence for phase 8**: its descriptors can be rewritten in place, but
  there must be exactly 27 of them.  The tape's phase 8 does not appear to fit
  in 27 -- the checksum walk finds 35 unambiguous blocks in just the first 87
  of its 110 MM blocks, and phase 3 establishes the rule (10 descriptors, 10
  checksummed blocks, 10/10 verified) that one descriptor means one block.
- New tool: `tools/rewrite_phase_descriptors.py`, rewrites a phase's
  descriptors in place, shifts later phases, repairs the enclosing checksum.
  `--verify-identity` rebuilds from what is already present and requires a
  byte-identical result; it passes on phases 3, 4, 7, 8, 12 and 15.  **That
  test caught a real bug**: `y` is NOT sum(ceil(len/512)) -- that reproduces
  only 8 of 16 phases (phase 3 gives 38 against the real 37, phase 15 115
  against 90).  It is right for phase 8, which is exactly why testing phase 8
  alone hid it.  The tool now preserves y unless `--y` is given.
- Descriptor content, best available: lengths are unambiguous for 87 of the 110
  MM blocks (35 blocks, zero ambiguity, stalls at tape 44544); destinations are
  credible for about 28 of 35 once each block is scored over its OWN length
  against the as-built image rather than over a fixed 512-halfword window --
  the three ZCON blocks then place at 100%.  Forcing the remainder through a
  non-overlap constraint makes it worse, not better: block 10 (4540 halfwords)
  goes from 48.6% to 3.6%.  Not stamped, deliberately.

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
