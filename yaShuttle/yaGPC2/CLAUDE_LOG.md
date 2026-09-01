# CLAUDE_LOG.md

(Cleared 2026-09-01 by Full Documentation Sync.  Twenty-six entries, all
naming `problems.md` and `HANDOFF-FCMBOOT.md`, were applied.  They are one
continuous story — making CRT2 draw GPC MEMORY — so they were told as one
section rather than filed as twenty-six dated notes.

- **`problems.md`** (7103 → 7365 lines) — a new **§8.28**, "Making CRT2 draw
  GPC MEMORY": the empty critical-format buffer and the three omissions that
  left it empty, the `HWDS=` load-block length, the unit PASS drives never
  being IPLed, the `_KYBD` routing, the two renderer defects and why a DFG
  display needs two passes, the two coordinate conventions with the evidence
  that BOTH are historical, and the `cpu_g_ea` sector-expansion defect traced
  end to end with its three eliminated candidates.  Also **eight new method
  failures in §8.10**, several of them mine from this week: a relative path
  writing into another repository, a fit anchored on a constant I had myself
  changed, an offline model treated as an oracle, a knob that could only be
  wrong in ways that looked like progress, changing more than one thing per
  round, a symptom reported three times against a wrong model, a "fix" verified
  against a single oracle, and acting on an inference before reading the
  primary source.
- **`HANDOFF-FCMBOOT.md`** (1086 → 1210 lines) — §2's state paragraph now says
  GPC MEMORY draws with correct data; "What is actually still open" gains four
  items at the top (the clock-only GPCIPL screen with its one-shot-write
  explanation, the flashing variant, the unexplained coordinate conventions,
  and the CRT hand-over); §3 gains the headless `pass-run/headless-gpcmem.sh`
  rig with the three things that failed silently first, the CRT2 crew sequence
  and the MEDS2 stopgap; §4 gains `YAGPC_DEUDUMP`, `YAGPC_RANGETRACE` and
  `YAGPC_INDTRACE`; §5 gains traps 17-22.

Claims were checked against the tree rather than copied from the log.  Verified
present: `YAGPC_RANGETRACE` in `src/run.c`, `YAGPC_INDTRACE` in `src/cpu.c`,
`YAGPC_DEUDUMP` in `src/deumodel.c`; `NSTS_DEU_LOG` in MEDS2's `idp.coffee` and
in `retest-crt2.sh`; `headless-gpcmem.sh` present and executable; MEDS2's
`pushurl = DISABLED-never-push-MEDS2-upstream`.

One claim was WRONG in the draft and was corrected rather than filed: "Shift+V
is gone".  It is still bound in `kybd.coffee` as a manual override — what
changed is that it is no longer *needed*, because the geometry is chosen from
the list.

Two things the log asserted are carried forward as UNRESOLVED rather than as
findings, because this session's own retractions are what made them so.  How
the DEU distinguishes the two coordinate conventions is unknown; the earlier
"MEDS's frame is the DEU's and DFG's is format-relative", the "one constant"
before it, and the "±512 is a legality rule" after it were all withdrawn, the
last of them by `OI301700/SSSRC/XD0001.hal`.  And the clock-only GPCIPL failure
is instrumented, not diagnosed.)
