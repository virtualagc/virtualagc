# CLAUDE_LOG.md

(Cleared 2026-09-02 by Full Documentation Sync.  Fifteen entries were applied
to `problems.md`, `HANDOFF-FCMBOOT.md`, and the cross-project issue database.
They are two continuous stories — closing out the CRT2 display work, and the
whole arc of the refused OPS transition — so they were told as such rather than
filed as fifteen dated notes.

- **`problems.md`** (7365 → 7619 lines).  A new **§8.29**, "Why `OPS 901 PRO`
  did nothing — a major function nobody could see": how to read `DMZ_LOG`, the
  four wrong answers in the order they were believed, the GRT lookup keyed on
  the requesting major function, the DEU model's switch that was never
  assigned, the three-run confirmation, the measured answer to "does PASS ever
  try the tape" (no), and the next blocker, `CZ2V_MC$(GPC) = 0`.  In **§8.28**,
  the clock-only and flashing screens are rewritten as one SOLVED fault —
  packet loss at MEDS2's socket, per-datagram cost, the two-part fix — and the
  confirmed `ADJ.vecY = 0.50` is recorded with how the user measured it.  Six
  new method failures in **§8.10**: the uniform-result rule not applied to a
  set of three, a retry that is input on another screen, editing a running
  shell script, a diagnostic that fails silently on a malformed argument, and a
  backgrounded subshell that does not inherit its sibling's `cd`.
- **`HANDOFF-FCMBOOT.md`** (1212 → 1342 lines).  §2's state paragraph now says
  OPS transitions are accepted and the front has moved to the memory
  configuration; "What is actually still open" loses the two screen faults and
  gains the memory configuration, the unexplained second clock-only capture,
  and the non-persistent `net.core.rmem_max`.  A new subsection, "The MAJOR
  FUNCTION switch — where it lives and why it matters", carries the `CZ1COM`
  encoding, all three ways to set it, and `DMMMCD` forging its own keystrokes;
  the DPS UTILITY background note joins the display-formats subsection.  §3
  documents the rig's `GPC_ID` / `DEUMF` / `DEUKEYS` / `SNAPSHOT` / `PORT_BASE`
  knobs and parallel runs; §4 gains `YAGPC_EAWATCH`, `YAGPC_DEUMF` and
  multi-batch `YAGPC_DEUKEYS`; §5 gains traps 23–28.
- **`yaShuttle/yagpc2-yahalmat2-issues.db`** — one row,
  `deumodel_major_func_never_assigned`, fixed, high.  The log entry named
  "problems-yaHALMAT2 (issue DB)" and described the MEDS2 usability change; the
  MEDS2 half is documentation and went to the handoff and to §8.29, while what
  actually belongs in a `found_in` tracker is the yaGPC2 defect underneath it.
  Filed that way rather than forcing a miscategorised row.

Claims were checked against the tree rather than copied from the log.  Verified
present: `YAGPC_EAWATCH` in `src/cpu.c`, `YAGPC_DEUMF` in `src/deumodel.c`,
`tools/opsdiag.py`; `DEUMF`/`SNAPSHOT` forwarding and the single-panel teardown
in `pass-run/headless-gpcmem.sh`; `MDU_SCALE` and the `rmem_max` check in
`retest-crt2.sh`; `showMajorFunc` and the `!@#$` binding in MEDS2's
`mdu.coffee`/`kybd.coffee`; `NSTS_BUS_RCVBUF` in `com/bus.civet`;
`NSTS_MDU_POS` in `main.civet`; `NSTS_PANEL_GEOMETRY` in `discretePanel.py`;
`CDLK_G1` in `DM6OPS.hal` and `CZ2V_MC$(ARC_GPC_ID` in `ARCGPC.hal`.

Withdrawn claims were filed as the withdrawals they are, not as findings.  "Our
ITEM entries to PASS do nothing" was retracted in the log and is recorded in
§8.10 as a contaminated measurement.  "Both GPC sets are empty, so nothing can
be a target" and the GPC-4 prediction are recorded in §8.29 as the wrong
answers they were, with what each one actually cost.

Carried forward as still unresolved: how the DEU distinguishes the two
coordinate conventions, and the one clock-only capture where no menu went out
on the wire at all.)
