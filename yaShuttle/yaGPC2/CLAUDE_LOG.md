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

### [2026-09-02] Target: problems.md
- **The CRT2 dance is unnecessary: leave CRT 1 selected for the IPL and select
  `none` just before RUN.**  The user's suggestion, and it works.  The
  mechanism was always "GPCIPL loads the unit on the BFC-SELECTED CRT, and PASS
  then masks exactly that bus" -- so with **no** CRT selected at RUN there is
  nothing for PASS to mask and it drives the unit that was actually loaded.
  One display unit, no flip, no second window.
- VERIFIED headless, not reasoned: with `crt 1` through the IPL and `crt 0`
  before RUN, bus 6 (the IPLed unit) carries PASS's live GPC MEMORY page --
  `0001 /` at 0x19ef, the message line at 0x19c2, the GPC number at 0x1a03 --
  while bus 7 stays 8188 zeros, never IPLed and never needed.  `DMZ_LOG` reads
  `d6f1 0000`, so the OPS request is still accepted; nothing downstream changed.
- `headless-gpcmem.sh` now takes `CRT_IPL` (default 1) and `CRT_RUN` (default
  0), the older CRT2 dance being `CRT_IPL=2 CRT_RUN=1`.  `retest-crt2.sh`'s
  crew sequence is rewritten to match.
- **Two stale instructions came out of `retest-crt2.sh` with it.**  Step 9 told
  the user to press Shift+V, which the automatic geometry chooser retired; and
  `NSTS_SIM_CONFIG=meds-unipled.json` is now belt-and-braces rather than
  required, since MEDS already gets `idp1` right and only `idp1` is in play on
  this route.  A launcher that tells you to do something unnecessary is how a
  retired workaround gets treated as a live requirement.

### [2026-09-02] Target: problems.md
- **CORRECTION, and it must be applied: §8.29 attributes `CZ2V_REC_XERR = 1`
  to `ARC_OPS_ZERO`'s `IF CZ2V_MC$(ARC_GPC_ID;)=0` test.  That is WRONG.**  A
  store watch on the variable (`YAGPC_WATCHHW=288e`) gives the real sequence:
      nia=454d5  XERR <- 5   DM6_PRE_POSIT_PARMS, "PRE POSITION REQUEST"
      nia=416b2  XERR <- 1   ARC_OPS_TRANS, because ARC_TRANS_COND = 2
      nia=416d4  XERR <- 1   + ARC_XERR_PAD (0)
  `CZ2V_MC = 0` is still true and still blanks the `MC=` field, but it is not
  what produced this error.  I also misread the ELSE-chain nesting: XERR=5 is a
  fully handled entry reason ("PREPOSITION MM AND NOTIFY DM2_APP",
  `ARCGPC.hal:350`), not "ARC entered without cause".
- **ROOT CAUSE, and it is ONE cause for FOUR symptoms: the phase tables were
  never stamped into the tape.**  Every link measured, none inferred:
    1. `CDCV_PHASES` (`CDCPHA.hal`, `ARRAY(19,3) INITIAL(-1)`) is at **0x300e4**
       and is **57 halfwords of FFFF** -- found by content search as the only
       run of exactly 57 in the whole image.  Never stamped.
    2. `FCMGPT`, the MM/GTG in-core phase table (`FCMGPT.hal`,
       `INITIAL(16#(4#0))`), is reached through a fullword-indirect pointer at
       0x0ace = `ccee0003`; with the sector expansion (DSV=3, high bit set)
       that is **0x1ccee**, and the whole table is zeros.  `AIBGPCLO:895` fills
       it from `CDCV_PHASES`, so it can only ever be zeros.
    3. `AIBGPCLO:470` cannot match `FCMMGPT_STARTING_MM_ADD$(1;)` against
       `CDCV_PHASES$(1,I:)`, so `CDJV_MM_AREA` stays 0 -- the `MM AREA` fields
       that read 1/1/1 in Don's video and 0/0/0 in ours.
    4. `ARC_GPC_RECONFIG`'s pre-position then loads phase 3's address and gets
       **0**.  Straight off the trace, registers and all:
           LH 6,X'0257'(7,2)   R6 = 3     phase 3, GRT row 9's MF overlay
           SLL 6,2 / AHI 5,-6  R5 = 6     FCMMGPT element 1, STARTING_MM_ADD
           LH 4,@@X'0010'(5,1) R4 = 0     <- the mass-memory address is ZERO
           STH 4,X'0065'(1)               ARC_MMU1POS.DBLOCK = 0
       Both `DIO`s go out to block 0 (`SVC X'014f'`, `SVC X'0066'`), the
       `WAIT` (`SVC X'0156'`) returns, `ARC_PP1_TSW` and `ARC_PP2_TSW` are both
       non-zero, and `ARC_TRANS_COND = 2` -- BAD PRE-POSITION, `ARCGPC:051900`,
       matched instruction for instruction against the source.
    5. `CZ2V_MC` never updates because `ARC_UPDATE_MC` runs only after a
       successful overlay, so `STORE MC=` stays blank.
- **So "PASS never tries to read the tape" needs qualifying.**  It DOES issue
  two mass-memory POSITION commands here.  They carry block address 0, which is
  why our MMU model logs nothing: the I/O fails before any tape access.  The
  earlier statement was right about the observable and wrong about the cause.
- **The fix has a name.**  `mmu2fcm --stamp-phase-tables` stamps exactly
  `#PFCMGPT`, `#PCDCPHA` and `FCMG3DAT`, via `ap101Utils.mmbstamp.generate()`
  and `.stamp()`.  Our tape was not built with it: `rebuild-tape.sh` only adds
  the DEU critical formats to `pass-ipl.mmv`, and `pass-ipl.mmv` itself carries
  unstamped tables.  `mmbstamp.stamp(image, sym, tables)` needs `sym`, the link
  map -- the same `PHASEnn.sym.json` blocker as before, but now with a specific
  purpose and two known runtime addresses (0x1ccee and 0x300e4) to check any
  stamping against.
- This is the third thing to come out "tape-build shaped", after DEUCFLM and
  MMDIR, and the pattern is now worth stating: **a table the flight software
  only ever READS is a table the ground build was supposed to WRITE.**  Both of
  these declare a sentinel (`0` and `-1`) that means "never built".
