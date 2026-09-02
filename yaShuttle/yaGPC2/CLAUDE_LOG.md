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

### [2026-09-02] Target: problems.md
- **The link map DOES exist, and my "no `PHASEnn.sym.json` anywhere on this
  machine" was wrong.**  It is at `~/ipl-demo/phases/PHASE02/PHASE02.sym.json`,
  2.4 MB, 437 sections; `~/ipl-demo/phases/` is the con80build output root with
  all the `PHASEnn.lib` files.  I searched the wrong roots and then treated the
  result as a hard blocker for two sessions.  It also cross-checks the
  measurement exactly: the map gives `#PFCMGPT` at 0x1ccf2 (1093 hw) and
  `#PCDCPHA` at 0x300e4 (57 hw), which is what the running machine gave via a
  fullword-indirect pointer and a content search, by wholly independent routes.
- **Stamping the two tables WORKS at the level it was meant to.**  Generated
  with `mmbstamp.generate('~/ipl-demo/phases', OI340600/CON80)` and injected
  with `YAGPC_LOADBIN` at t=258 s, the ARC table lookup that used to fetch 0
  now fetches the right address -- measured in the trace, `LH 4,@@X'0010'(5,1)`
  leaves **R4 = 0x1bc0 = 7104**, phase 3's mass-memory address, and both
  `ARC_MMU1POS.DBLOCK` and `ARC_MMU2POS.DBLOCK` get it.
- **But the OPS transition still fails, and the failure has MOVED.**  The two
  DIOs go out (`SVC X'014f'`, `SVC X'0066'`), the `WAIT` (`SVC X'0156'`)
  returns, and `ARC_PP1_TSW$(1)` = **0x2100** with `ARC_PP2_TSW$(1)` = **0x2200**
  -- both non-zero, so still BAD PRE-POSITION.  Where before the address was
  zero, now the address is right and the I/O itself is refused.  **The
  emulator logs no bus command at all at that instant**, so FCOS rejected the
  request internally rather than issuing it.  That is the next thread, and it
  is a different one: an I/O-path question, not a table question.
- **Do NOT stamp `FCMG3DAT` at its `sym.json` address.**  Stamping all three
  tables killed the machine 8.6 ms after injection -- `invalid instruction
  0xc99c at 0x000a`, simulated 258.0086 s against an injection at 258.000 s.
  The other two targets held their documented sentinels (1093 zeros, 57 FFFF),
  but 0x0320e held `aaaa` fill, zeros, and **ten copies of `325e`** -- pointers
  into its own region, i.e. a live structure.  `PHASE02.sym.json` reports
  `residue: None` for it, but that map describes phase 2 alone and something
  else owns that address in the fully composed image.  `mmbstamp.stamp()`
  checks only `residue`, so **any stamping path needs to verify the target
  actually holds its sentinel before overwriting**.  An unstamped table is
  self-announcing (0, -1, FFFF all mean "never built"); a wrongly stamped one
  is silent, which makes being wrong here quieter than being absent.
- `YAGPC_LOADBIN` now takes several images
  (`t:addr:path;t:addr:path;...`, up to 8).  One was not enough: the ground
  build stamps the phase tables as a SET, and standing in for part of a set
  only moves the failure.

### [2026-09-02] Target: problems.md
- **TWO CORRECTIONS to numbers already written into §8.29, both from trusting
  truncated tool output or an unchecked convention.**
  1. "92 mass-memory trace lines, every one from the IPL at t=10.3 s" is wrong.
     There are **91**, and they run through the SSL load to `READY -> 1` at
     **t=105.35 s**.  I read a `tail` that the output filter had truncated and
     took the visible last line as the last line.  The conclusion survives --
     nothing after 300 s, so the pre-position I/O still never reached the
     device -- but the supporting number did not.
  2. **`nia=` in the WATCH/EAWATCH hooks is the NEXT instruction, not the one
     that acted.**  Both call `psw_get_nia()` after the PC has advanced.
     Proved on one pair: `RT 413b5 ZH X'0051'(1)` stores to 0x0b0f and
     `WATCHHW addr=00b0f` reports `nia=413b7`.  So every address quoted from a
     watch is one instruction late -- the `XERR <- 1` store is at **0x416b1**,
     not 0x416b2, and `DM6OPS`'s search sits just before 0x455f6/0x455fc.  The
     RANGETRACE `RT` lines are unaffected: those print the instruction being
     executed.  `EAWATCH`'s own comment claims it says "which instruction
     touched this address", which is a shade misleading and should say which
     instruction FOLLOWS it.
- **The I/O refusal is inside FCOS's generic I/O dispatcher, and FCOS resolves
  the device correctly before refusing.**  Measured at the failing call:
      R3 = 0x90b2      the DIO parameter list (ARC_MMU1POS)
      LH 5,X'000c'(3)  R5 = 0x000b = 11 = MMUDEV  (INCL80/IOMACS.hal)
      R1 = 0x0012 = 18 = BCE 18, which is MM1's bus in our own model
      TB X'002f'(0),X'4000'  -> bit CLEAR, and the branch goes to the failure
      L 5,X'8d88' ; STH 5,X'0000'(0)   status 0x2100 into ARC_PP1_TSW
  So the device number and the bus are both right, and FCOS still declines
  without issuing anything.  It fails a bit test on a table reached through the
  parameter list's flags halfword.
- The macro layout that makes this readable is `INCL80/MMUMACS.hal`'s `MMUPOS`
  -- `DSVCNO, flags, DMFID, DDEV, DOPCODE, DPRIO, DWDCT, DLOC, DEVNT, DBLOCK`
  -- with `INCL80/IOMACS.hal` giving `IOSVC=24`, `MMUDEV=11`, `MMUPRI=0` and
  `MMUMACS` giving `MMPOSCD=8`.  Both `ARC_MMU1POS` and `ARC_MMU2POS` name the
  SAME device; the unit is selected by the `HEX'3000'` bits of
  `CZ2B_MM_MF$(ARC_MF)`, which ARC toggles between the two DIOs
  (`ARC_B = 0x2000` for MMU1, `XOR 0x3000 = 0x1000` for MMU2).
- **NOT ESTABLISHED, and worth flagging as such:** the same dispatcher writes
  0x6000 for device 6 on other calls, so it is not yet proven that a non-zero
  task status word means failure in general rather than "this is the completion
  code".  ARC clears both TSWs to 0 before the DIOs and only tests after the
  WAIT, so its own reading is self-consistent -- but what a SUCCESSFUL FCOS
  mass-memory I/O leaves in the TSW has not been observed, because PASS has
  never done one here.  That is the thing to measure next, and until it is
  measured "0x2100 is an error code" is an assumption.

### [2026-09-02] Target: problems.md
- **The failing code has a name and a source file, and I had not looked.**  I
  called it "FCOS's generic I/O dispatcher", which was an inference from
  behaviour.  `PHASE02.sym.json` names it outright: the status store at
  0x19ab4+1450 is **`FIOERRLC`** and its caller at 0x1a54c+208 is
  **`FIOMGSNC`** -- both present as `SSSRC/FIOERRLC.asm` (130 KB) and
  `SSSRC/FIOMGSNC.asm` (27 KB).  Looking up a traced address in the link map is
  the cheap move I should have made first, and it is general: any address in
  phase 2 can be named this way.
- They are not a dispatcher.  `FIOERRLC` is the **I/O ERROR HANDLER, LEVEL C**;
  `FIOMGSNC` is the **MM/GTG ERROR AND/OR SYNC PROCESSOR**, whose stated output
  is "an updated user supplied transaction status word if an error was
  detected".  So reaching that code means an error was already decided, and the
  earlier open question -- whether a non-zero TSW really means failure -- is
  answered yes.
- **The status word decodes exactly** (`FIOERRLC.asm`, "FORMAT OF THE
  TRANSACTION STATUS WORD"):
      bit 0 FIOENTRF 8000  ENTIRE TRANSACTION FAILED. NO GOOD DATA EXISTS
      bit 1 FIOHARDF 4000  FAILURE SOMEWHERE IN TRANSACTION
      bit 2 FIOSELFE 2000  SELF HAD ERROR
      bit 3 FIOMSCTF 1000  MSC TIMEOUT HAS OCCURRED
      bit 4 FIOPSTOF 0800  PSUEDO TIMEOUT HAS OCCURRED
      bit 6 FIOMMFPW 0200  FAILED OR POWERED DOWN MM   (formerly EGC 506)
      bit 7          0100  MM SELECTED FOR IPL         (formerly EGC 507)
  so **0x2100 = SELF HAD ERROR + MM SELECTED FOR IPL** and **0x2200 = SELF HAD
  ERROR + FAILED OR POWERED DOWN MM**.  `PROC FIOMMERR` builds it as
  `error_code OR FIOSELFE`.  MMU2's reading independently validates the decode:
  our rig has no MM2, so "failed or powered down" is simply true.
- **HYPOTHESIS, NOT YET TESTED** -- the run that would settle it was stopped
  before it finished.  `FIOMGSNC` dispatches a transaction only if the MMU is
  NOT IPL-selected (`CZ2BDIA` AND the BCE monitor mask, shifted by `FIOMMIPB`)
  OR the switch is masked in software (`CZ2BMIPL` = `CZ2B_MMU_IPL_SW_MASK`,
  `INITIAL(HEX'0000')`, so unmasked; only `ARXRSBUS` and a crew item in
  `ASMAUX` ever set it).  Our panel holds `source MM1` for the whole run and
  nothing masks it.  That would explain the refusal AND why the real vehicle is
  not broken by it, but it is reasoning from source, not a measurement.
  `headless-gpcmem.sh` now takes `SOURCE_RUN` (default `MM1`, so existing runs
  are unchanged); `SOURCE_RUN=OFF` runs the test.
- Method note: I asserted this cause once already off the back of the status
  decode alone, before checking any of the above, and the user was right to say
  it told me nothing.  Decoding what the software CONCLUDED is not evidence for
  WHY it concluded it.
