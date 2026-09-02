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

### [2026-09-01] Target: [problems.md]
- CONFIRMED by the user: `ADJ.vecY` = **0.50** is right.  Drawn lines on
  `GPC/BUS STATUS` look correct and no other screen regressed.  The number came
  from their measurement -- 8 px between one row's bottom strokes and the next
  row's top strokes at 1024x1024, so the ink fills 0.70 of a row and the gap
  0.30, and centring a rule in that gap is 4 px = 0.15 row off the old 0.65.
  My own attempt at 0 was wrong by more than twice the whole gap: the deck
  (CD0060, `VCORDA=(28,95,815,95)`) gives a ROW offset, and converting it to a
  SCREEN offset needs where glyph ink sits inside its cell, which the deck does
  not say.

### [2026-09-01] Target: [HANDOFF-FCMBOOT.md]
- WINDOW PLACEMENT, and a real trap in it: **Electron and Tk do not mean the
  same thing by a coordinate.**  Electron takes device-INDEPENDENT pixels and
  this desktop scales by 2, so an MDU asked for at 528x542 occupies 1056x1084
  on screen (measured off a screenshot's own dimensions); Tk's `geometry` is in
  real screen pixels and does not scale.  Placing the panel "just below" the
  MDUs with an Electron-sized number put it halfway up CRT1.  `retest-crt2.sh`
  now derives both from `MEDS_SIZE`/`NSTS_MDU_CHROME` with `MDU_SCALE`
  (default 2) applied only to the Tk one: CRT1 `0,0`, CRT2 `560,0`, panel
  `+0+1124`.  `NSTS_MDU_POS=<x>,<y>` (MEDS2) and `--geometry` /
  `NSTS_PANEL_GEOMETRY` (discretePanel) are the underlying knobs.
- Poll-reply logging is armed but has NOT yet caught a failing run.

### [2026-09-01] Target: [problems.md]
- **THE FLASHING AND CLOCK-ONLY GPCIPL SCREENS ARE ONE FAULT, AND IT IS PACKET
  LOSS AT MEDS'S SOCKET.**  Proven with two observers on the same multicast
  group: dksniff saw GPCIPL's 509-halfword menu fill at 0x19ee arrive complete
  (452/509 non-zero) while MEDS received 423 of 509 and discarded the partial
  transfer -- `transfer abandoned, 86 halfwords short`, three abandons in that
  run (54, 30, 86).  With the menu body gone the walk from DISPLAY_HEADER
  starts on a stray `FCW1 3900`, blink on with nothing after to clear it, so
  318 of 319 glyphs land in the blink group and the whole screen flashes.
  Where the loss falls differently you get the clock-only variant instead.
- FIXED, and confirmed by the user: **0 abandoned transfers across 137 fills**,
  against 3 before.  Two parts.  `com/bus.civet` now asks for a 4 MB receive
  buffer (`NSTS_BUS_RCVBUF`) and LOGS what it was granted; and
  `net.core.rmem_max` had to be raised from 212992, which is a root action --
  `sysctl -w` does NOT persist, so `retest-crt2.sh` now checks it at startup
  and prints both the temporary and the permanent fix.
- WHY SO SMALL A PAYLOAD OVERRAN SO LARGE A BUFFER: the cost is per DATAGRAM,
  not per byte.  A 509-halfword fill is about a kilobyte of data spread over
  hundreds of bus messages, each charged its own skb overhead, so a burst of
  seven fills is nearer 400 KB than 7 KB.  dksniff survives it by doing nothing
  but drain the socket; Electron is rendering when the burst lands.
- The earlier clock-only capture that showed NO abandons and no menu on the
  wire at all remains a SECOND, distinct failure -- there the GPC never sent
  it.  Not explained by this.

### [2026-09-01] Target: [HANDOFF-FCMBOOT.md]
- MAJOR FUNCTION SWITCH: the encoding is in the flight software, `SSSRC/CZ1COM`
  on `CZ1B_D_DIT_MSG_HEADR` bits 9-10 -- **MF VALUE(0=PL, 1=GNC, 2=SM,
  3=ILLEGAL)**.  MEDS2 and Don's MEDS both hardcode `@majorFunc = o.majorFunc ?
  0`, so every run either of us has made has told PASS the switch is in
  **PAYLOAD**.  That is a candidate for OPS 1 / OPS 9 being declined, and for
  Don's video landing on P9 (PL OPS 9).  `NSTS_MAJOR_FUNC=<0..3>` sets it at
  launch; a LIVE switch needs an MDU -> IDP bus message, since the MDU holds
  only `@priPortIDP` as a number and cannot reach the IDP's DEUUnit.
- A major function CHANGE is what PASS acts on, and it forges the keystrokes
  itself -- `SSSRC/DMMMCD` queues two, HEX'000F' and HEX'0002', and calls
  `ARY_MF_BUS_CHG` for a new bus commander.  That is why a display can change
  with no scratch-pad echo, which is what the user observed in Don's video.
- DPS UTILITY's background is MEDS's, not the GPC's, as of
  `CR93220A 01/23/08 OI3404 MOVE DPS UTILITY BACKGROUND TO MEDS` (SSSRC/CD0010,
  the only deck in OI340600 that says it).  PASS sends 155 halfwords of pure
  variable data for that page.  The background is recoverable from OI301700,
  which predates the change: `SSSRC/CD0010.hal`, 738 halfwords, decodes to the
  full page.  Wiring it up needs to know WHICH page is up, and the only channel
  that could carry that is `MEDS_XFER` -- 100 halfwords, ~1300 per run, stored
  in `@medsDK` and read by nothing.  Now logged on change.

### [2026-09-01] Target: [problems.md]
- **PASS IS NOT FAILING SILENTLY ON THE OPS REQUEST**, which is what the user
  doubted and was right to.  `SSSRC/DM6OPS` enumerates nine refusal reasons in
  `DM6V_ERR_TYPE` -- 0 none, 1 NO TARGETS IN RUN (fault message, not ILLEGAL
  ENTRY), 2 no target GPCs from GRT, 3 not overlay initiator and not in main
  memory, 4 mode recall from application, 5 mode-to-mode illegal, 6 from
  keyboard and not requested to target GPC/RS, 7 from application and not in
  main memory, 8 illegal transition, and an UNDOCUMENTED 9 set when
  `DM6_T_VALIDITY` fails -- writes it to the log with `DMZ_LOG`, and calls
  `FMPT_UI_OPERR` (ILLEGAL ENTRY) for anything above 1.  We had simply never
  looked.
- AND IT NEVER READS THE TAPE.  So "the OPS software is not on the tape" is NOT
  the operative cause: the request is refused before anything looks.  The tape
  gap is real -- GMAGNC91 (384 blocks) and VMAPL91 (216) are absent, SYS2 and
  SYS3 entirely so -- but it is downstream of whatever refuses.
- FOUND IN MEMORY: `0x38058: d609 0001` -- `D600|9` and mode 1, DM6OPS's own
  "LOG ON OPS/MODE" entry for our `OPS 901 PRO`.  So the request reaches the
  OPS processor.  The following entry is `d6f1 0001`, which is NOT the
  `[d609, ERR_TYPE]` the second `DMZ_LOG` call should write, so the log
  framing is not yet decoded and **the error type is still unknown**.
- REPRODUCED UNATTENDED, which is the real gain: `YAGPC_DEUKEYS` now takes
  several batches at their own poll counts
  (`@150:ITEM,1,EXEC;@480:OPS,9,0,1,PRO`), so the whole sequence -- IPL, load,
  OPS request -- runs headless with a memory snapshot at the end.
- THREE OF MY OWN MEASUREMENTS WERE WRONG TODAY and each cost runs.  (1) A
  leaked yaGPC2 from a previous run held the port base and blocked the next;
  the rig now escalates SIGINT to SIGKILL.  (2) `YAGPC_MMUTRACE` was never set
  in the headless rig, so my "reads" grep matched only the bootstrap line and I
  concluded PASS had not loaded when the display proved it had; MMUTRACE is now
  on.  (3) An SSW-vs-DASS comparison reported "69.5% matching" that was C6C6
  fill matching C6C6 fill with PASS not loaded.
- EXPERIMENT FLAW TO FIX NEXT TIME: the ITEM 1 EXEC retries land on PASS's own
  GPC MEMORY page once the load has taken, and `ITEM 1 EXEC` is not valid
  there -- so the ILLEGAL ENTRY on screen may be from a retry rather than from
  the OPS request.  Send the ITEM batch once, or space the OPS request far
  enough to tell them apart.

### [2026-09-01] Target: [problems.md]
- **ROOT CAUSE OF THE REFUSED OPS TRANSITION: `DM6V_ERR_TYPE = 1`, "NO TARGETS
  IN RUN".**  Read out of PASS's own log, not inferred.
- HOW.  `SSSRC/DMZLOG` is a 150-entry circular log of 2-halfword sets, filled
  `FFFF`, with `DMZB_LOG_ALIGNMENT INITIAL(HEX'0C5C')` beside it as a findable
  marker and `DMZV_SET_NBR` as the next slot.  In the snapshot the marker sits
  at 0x38025 with `SET_NBR = 27`, and the array FOLLOWS it (declaration order
  is not layout order) at base 0x38028, so entry 26 ends exactly where the
  `FFFF` fill begins.  The two entries our request wrote:

        entry 25  0x38058  d609 0001   LOG ON OPS/MODE  -> OPS 9, mode 1
        entry 26  0x3805a  d6f1 0001   LOG TYPE/STATUS  -> D6F1 = "NON MODE
                                       RECALL" (DM6OPS:352), ERR_TYPE = 1

- WHAT IT MEANS: target GPCs exist for the transition but NONE IS IN RUN
  (`RUN_GPC = RUN_GPC AND TARGET_GPC; IF RUN_GPC = HEX'0000' THEN
  FMPT_UI_FAULT(CDLK_G1); DM6V_ERR_TYPE = 1`).  The request passes the
  transition table -- ERR_TYPE 9 would say otherwise -- reaches the target
  check and stops, which is why it never touches the tape.
- SO EVERY EARLIER SUSPECT IS OFF THE PATH: the major function switch, the GPC
  ID, the transition table, and the missing GNC9/PL9 tape overlays.  The tape
  gap is real but downstream of this.
- AND THE `ILLEGAL ENTRY` WAS SELF-INFLICTED: ERR_TYPE 1 raises a GPC CONFIG
  FAULT message, not `FMPT_UI_OPERR`, so the ILLEGAL ENTRY on screen came from
  the `ITEM 1 EXEC` retries landing on PASS's GPC MEMORY page.  The flaw I
  flagged before reading the log, now confirmed.
- NEXT: `CZ2B_GRT_GPC_SET` is indexed by memory configuration and is what
  designates targets.  Find what populates it, and what makes a GPC "in RUN"
  for that purpose -- our GPC is in RUN by the mode discrete, so the two
  notions differ.

### [2026-09-01] Target: [problems.md]
- **THE CHAIN IS COMPLETE, AND IT IS A GPC-SET PROBLEM, NOT A TAPE PROBLEM.**
  Read out of memory with the SDF's own offsets, not inferred:

        CZ2B_GRT_GPC_SET  0x026fc (offset 776 in #PCZ2COM at 0x23f4), 10 x 16b
          [1] f000 GPCs 1,2,3,4   [6] 4400 GPC 2
          [2] c000 GPCs 1,2       [7] 8400 GPC 1
          [3] f000 GPCs 1,2,3,4   [8] c000 GPCs 1,2
        CZ2B_RS (redundant set) 0x02407 = 0000
        CZ2B_CS (common set)    0x02406 = 0000

  The GRT targets ARE populated -- which is why DM6OPS gives ERR_TYPE 1 and not
  2 -- but `RUN_GPC = ((GPCs in OPS0) AND CS_MASK) OR RS_ALL` is zero because
  BOTH GPC SETS ARE EMPTY, so `AND TARGET_GPC` leaves nothing and the answer is
  "NO TARGETS IN RUN".  The GPC CONFIG fault message means exactly that.
- SO THE MISSING STEP IS ESTABLISHING A GPC SET / MEMORY CONFIGURATION, not
  anything to do with the missing GNC9 overlay.  `CZ2V_MC_REQ` (0x026f8, the
  memory-configuration request, and the same variable the DCI#CON work watched)
  is 0, and `ICC_CZ2V_MC_REQ` is what DM6OPS signals when a transition is
  accepted.  CANDIDATE and UNTESTED: GPC MEMORY's own `STORE MC=` block --
  `45 CONFIG`, `46 GPC`, `STORE 47` -- is the crew's way of assigning a memory
  configuration to a GPC, which is what would populate the set.
- HOW TO READ ANY OF THIS AGAIN: `ap101Utils.sdf.SdfLibrary` over
  `PFS/OI340600/SDFLIB`, `unit('CZ2COM').symbols()`, `.address` is the compool
  offset.  Names in the SDF are EBCDIC and TRUNCATED TO 8 CHARACTERS, so a
  plain grep for `CZ2B_GRT_GPC_SET` finds nothing -- search `CZ2B_GRT`.

### [2026-09-01] Target: [problems.md]
- **DON HITS THE SAME WALL WE DO.**  User's observation of his video: a flashing
  `GPC CONF 2 00:00:46( 3)` appears IMMEDIATELY after `OPS 901 PRO`, and
  nothing else happens.  `GPC CONF` is `FMPT_UI_FAULT(CDLK_G1)`, which DM6OPS
  raises for exactly the ERR_TYPE 1 we measured.  So we are NOT behind him on
  the OPS transition; we are at the same place, and his `9011/` `MC=09` screen
  later in the video arrives by some route that is not that keystroke.
- WHY OUR SCREEN DID NOT SHOW IT: the ILLEGAL ENTRY from my own `ITEM 1 EXEC`
  retries landed on PASS's GPC MEMORY page and replaced it.  The fault line
  works -- `BCE STRG 1` and `I/O ERROR CRT2` reach it.
- HYPOTHESIS TESTED AND DEAD: assigning a memory configuration first, via GPC
  MEMORY's `45 CONFIG` / `46 GPC` / `STORE 47`.  Keyed headless
  (`ITEM,4,5,PLUS,9,EXEC` etc.); `CZ2V_MC_REQ` stayed 0000, both GPC sets
  stayed 0000, and the OPS request reproduced ERR_TYPE 1 exactly.  MC 9 is the
  right number for GNC OPS 9 (`GMAG9R1 PHASE,PH=18,MC=9`), so it is the route
  that is wrong, not the value.
- **THE MECHANISM, and it narrows the fault to one comparison.**  `DMCSUP`
  runs on every MCDS event, unconditionally, before dispatching to
  DM1_KEYBOARD:

        CDMB_RS,CDMB_RSALL = CZ2B_RS$(TFCMID;);               /* 0000 */
        CDMB_RSALL = CDMB_RSALL OR CDMB_RSCS_MSK$(TFCMID:*);  /* OR SELF */

  so `DM6B_RS_ALL` is NOT empty -- it holds self.  `RUN_GPC` therefore reduces
  to `SELF AND TARGET_GPC`, and ERR_TYPE 1 means **self is not in the target
  set the GRT selected**, not that the sets are unpopulated.  My earlier "both
  GPC sets are empty, so nothing can be a target" reading was half right: CS is
  empty, but RS_ALL carries self and that is the term that matters.
- GRT SETS DECODED BY GPC BIT (bits 1-5 from the MSB; bit 6 is some other
  flag): [1] 1,2,3,4  [2] 1,2  [3] 1,2,3,4  [4] 4  [5] 4  [6] 2  [7] 1
  [8] 1,2  [9] 1,2,3,4  [10] none.  We have failed as GPC 1 (headless default)
  and as GPC 2 (user's run), which rules out indexes 7 and 6 and every set
  containing 1 or 2 -- pointing at an index that names **GPC 4**.  Running as
  GPC 4 is the falsifiable test; `headless-gpcmem.sh` now takes `GPC_ID`.

### [2026-09-01] Target: [problems.md]
- **GPC 4 PREDICTION FALSIFIED.**  Run as GPC 4, `OPS 901 PRO` gives the same
  `d609 0001` / `d6f1 0001` -- ERR_TYPE 1.  So GPC 1, 2 AND 4 all fail
  identically, and the refusal does not depend on which GPC we are.  Since
  `RUN_GPC` reduces to `SELF AND TARGET_GPC` and the GRT sets between them name
  1, 2 and 4, SELF is not reaching the comparison at all: either
  `CDMB_RSCS_MSK$(TFCMID:*)` is zero or **TFCMID itself is wrong**.
- BLOCKED THERE, and the blocker is tooling: `TFCMID` has `addr=0` in every SDF
  unit that names it, i.e. it is resolved at LINK time, and there is no
  `PHASEnn.sym.json` for the PASS load anywhere on this machine.  Same for the
  CDM compool's base, which is what reading `CDMB_RSCS_MSK` needs.  Getting a
  link map for the tape's PASS build is the enabler for the next step.
- FOUND ANYWAY, by content search: `DM6V_TR_TAB` is at **0x2c38**, 4 halfwords
  per entry (entry 1 mask `81403F00` at 0x2c38, entry 8 `81C04000` at 0x2c54,
  entry 19 `C0002000` at 0x2c80).  A watch or trace anchored on that address
  would give DM6OPS's code address without a symbol map, which is the other way
  in.
- **MM AREA, and where it comes from.**  User: Don's GPC MEMORY reads
  `PL 52 1 / GNC 53 1 / SM 54 1` from the moment the page appears, ours reads 0.
  The items drive `CDJV_MM_AREA$(1..3:)` (`SSSRC/CD0001`, `VPARM=(NAME=...)`,
  CDJRWD offset 110), and `SSSRC/AIBGPCLO:441` initialises it during PASS
  start-up:

        IF CDJV_MM_AREA$(1:) = 0 THEN
           DO FOR TEMPORARY I = 1 TO 3;
              IF FCMMGPT_STARTING_MM_ADD$(1;) = CDCV_PHASES$(1,I:) THEN
                 CDJV_MM_AREA$(1 TO 3:) = I;

  It matches where PASS was ACTUALLY loaded from against the per-area phase
  table.  Ours stays 0, so that match fails -- either the tape puts PASS
  somewhere `CDCV_PHASES` does not name, or `CDCV_PHASES` is not populated.
  That is a concrete, checkable difference from Don's state and it is
  tape-build shaped, like DEUCFLM and MMDIR before it.

### [2026-09-01] Target: [problems.md]
- **OUR ITEM ENTRIES TO PASS APPEAR TO DO NOTHING, and that is a separate,
  more tractable defect than the OPS one.**  Two independent attempts, keyed
  headless and each verified delivered: `ITEM 45 +9 / ITEM 46 +2 / ITEM 47`
  left `CZ2V_MC_REQ` at 0000, and `ITEM 53 +1` produced no 0->1 transition
  anywhere with the three-consecutive shape `CDJV_MM_AREA$(1..3)` would have.
  `ITEM 1 EXEC` on GPCIPL's own menu DOES work -- it loads PASS -- so the
  keystroke path is fine as far as GPCIPL.  Whether PASS receives item entries
  at all is now the first thing to establish, and it is testable without any
  link map: key an item with a visible field (MM AREA is ideal, it is on
  screen) and read the DEU image.
- A DIFFERENTIAL TECHNIQUE THAT WORKS WITHOUT SYMBOLS, worth keeping: run the
  same scenario as two different GPCs and diff the snapshots.  GPC 1 vs GPC 4
  at the same snapshot time gives 22 halfwords holding the GPC ID (1 vs 4) and
  15 holding a per-GPC bit mask (0x0010 vs 0x0002, i.e. bits 12 and 15 -- the
  `TARGET_GPC$(12 TO 16)` numbering).  So SELF's mask IS computed correctly,
  which makes the ERR_TYPE 1 harder to explain, not easier: with RS_ALL
  carrying that bit and the GRT sets containing it, `RUN_GPC` should be
  non-zero.  Something between those two facts is still missing.
- TWO WAYS IN FROM HERE, both real: (a) get a `PHASEnn.sym.json` link map for
  the tape's PASS build, which resolves `TFCMID` and the CDM compool base
  directly; or (b) anchor on `DM6V_TR_TAB` at 0x2c38 -- located by content
  search, no symbols needed -- to find DM6OPS's code and `YAGPC_RANGETRACE` the
  comparison itself, which is how the DCI#CON defect was finally cornered.

### [2026-09-01] Target: [problems.md]
- **CORRECTION, same session: "our ITEM entries to PASS do nothing" is WITHDRAWN.**
  With the `ITEM 1 EXEC` retry removed, a clean run of
  `@150:ITEM,1,EXEC;@430:ITEM,5,3,PLUS,1,EXEC` leaves the message line showing
  only the standing `BCE STRG 1 NSP 1 00:00:03( 1)` and **no ILLEGAL ENTRY**.
  So `ITEM 53 +1 EXEC` was ACCEPTED and PASS item entries work.  Every ILLEGAL
  ENTRY seen today was the retry landing on PASS's own GPC MEMORY page, where
  `ITEM 1` is not valid -- the experiment flaw I flagged, and it went on to
  contaminate two conclusions before I removed it.  **Retries that are harmless
  on one screen are input on another; do not leave them in a measurement.**
- So the OPS refusal stands alone: ERR_TYPE 1, NO TARGETS IN RUN, with SELF's
  bit mask demonstrably correct and the GRT target sets demonstrably
  populated.  The gap between those two facts is the whole remaining question.
