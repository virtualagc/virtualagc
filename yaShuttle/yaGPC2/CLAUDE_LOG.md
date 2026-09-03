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
  So it is UNKNOWN whether disp can move, whether a phase can grow past its
  current descriptor count, and whether y is constrained.  problems.md 8.35 and
  the handoff's "two hard constraints" have been rewritten as retractions.
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
