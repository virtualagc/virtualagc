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

### [2026-09-02] Target: problems.md
- **HYPOTHESIS CONFIRMED BY EXPERIMENT: the IPL SOURCE switch was blocking every
  post-IPL mass-memory I/O.**  With `SOURCE_RUN=OFF` deselecting it at t=252 s,
  eight seconds before RUN, the tape is finally used:
      13 mass-memory commands after t=300 s, where every previous run had 0
      -- BITE STATUS, POSITION, EXTENDED BLOCK, READ, repeatedly
      **483 blocks read, 247,367 words out**
  So PASS performed the OPS 9 overlay load.  That is the first time any run
  here has read the tape for anything but the IPL.
- The mechanism is the one `FIOMGSNC` states: it dispatches a mass-memory
  transaction only if the MMU is NOT IPL-selected or the switch is masked in
  software (`CZ2B_MMU_IPL_SW_MASK`, `INITIAL(HEX'0000')`).  Leave the switch on
  MM1 and every transaction returns transaction-status-word bit 7, "MM SELECTED
  FOR IPL".  **Two switches, the same trap**: the user's `CRT none` finding and
  this one are the same shape -- a discrete left in its IPL position that the
  flight software correctly refuses to work around.
- **NEW FAILURE, further along than anything before it.**  About 0.4 s after
  the last tape command the GPC enters a **masked wait state** and the run
  stops: `NIA=0x4071d`, `t=391.328 s`, `R4=0x0009` (the OPS number).  The
  address names itself through the phase link maps as **`$0DCICYC`**, which is
  resident -- it appears at the same address in every `PHASEnn.sym.json`.  The
  display never advances: still `0001 /` at 0x19ef, so the transition did not
  complete.
- Technique worth keeping: **name a traced address by looking it up in the
  phase link maps.**  `~/ipl-demo/phases/PHASE*/PHASE*.sym.json` covers every
  phase, so any address can be attributed to a CSECT without disassembly --
  that is how `FIOERRLC`, `FIOMGSNC` and now `$0DCICYC` were identified.  A
  CSECT appearing at one address in ALL the maps is resident rather than
  overlaid, which is itself useful.
- Note against an earlier statement: the tape gap (GMAGNC91, VMAPL91 absent)
  did NOT stop the read -- 483 blocks came off it successfully.  What is on the
  tape and what the overlay needs is now a question that can be asked with
  measurements instead of assumed.

### [2026-09-02] Target: problems.md
- **THE IPL-SOURCE FIX IS REAL AND ISOLATED.**  Control run: source deselected
  before RUN, NO injected tables -- runs clean to 617.9 s and stops only on the
  script's own SIGINT.  So deselecting the IPL source is safe by itself, and
  the masked-wait halt belongs to the injected phase tables, not to the fix.
- **THE HALT IS SELF-INFLICTED BY THE INJECTION.**  With `YAGPC_LOADBIN`
  stamping `#PFCMGPT`, the overlay writes blocks 1-3 into low memory (0x01f6,
  0x0654 -- PSA/CVT space, confirmed by a 385-vs-390 s snapshot diff), then
  fails, leaving FCOS partially overlaid.  About 0.4 s later the machine takes
  a masked wait.  Without the injection, none of this happens.
- **BOTH TABLES ARE LOCATABLE ON THE TAPE BY THEIR OWN SENTINELS**, which makes
  a real tape-stamping tool buildable:
      #PFCMGPT  tape halfword 616158  1093 x 0000   (found by the 4-halfword
                prefix signature f628 4000 0800 0800 -- ONE occurrence)
      #PCDCPHA  tape halfword 633964    57 x ffff   (ONE run of exactly 57
                in 1,544,072 halfwords)
  Enclosing load blocks, found by the checksum property: (612956, 5961) and
  (633736, 802).  The second implies a load address of exactly 0x30000, which
  corroborates it.  The load-block convention is `[content L-2][0][checksum]`
  with **checksum == sum(content) & 0xffff** -- from `tools/stamp_ssl_checksum.py`,
  which already finds a block this way.
- **A REAL DISCREPANCY, MEASURED: `mmbstamp` overstates phase-3 load block 4 by
  16 halfwords.**  At tape offset 2560, length 6982 (generated) fails the
  checksum and length **6966** passes; at the generated length's tail there is
  `c6c6` fill.  Blocks 1-3 match the tape EXACTLY (98 @0, 12 @512, 1354 @1024,
  all checksum OK), so the generation does correspond to this volume.
- **BUT THAT DISCREPANCY IS NOT THE CAUSE OF THE HALT.**  Patching the length
  to 6966 and re-running changed nothing: the same two 26-block reads from
  3/3/6/0 and the same masked wait at 391.7 s.  Hypothesis falsified by
  experiment.  The read is a single contiguous 26-block transfer, so PASS is
  not reading per-load-block, and a per-block length is probably not what
  decides it.  The 16-halfword error is real and worth fixing on its own
  account; it is not this failure.
- **RETRACTED: the "wrong build" worry.**  I suspected `~/ipl-demo/phases` was
  not the build behind `pass-ipl.mmv`, on the strength of `#PCZ2COM` sitting at
  0x014ac in the map but holding `c6c6` there in memory while the live compool
  is at 0x23f4.  Phase-3 load blocks 1-3 matching the tape exactly settles it
  the other way: it IS the right build.  288 of 309 phase-2 sections have
  content at their mapped addresses; `#PCZ2COM` is one of 21 exceptions and
  remains unexplained, but it is not evidence of a mismatch.
- Two suspects eliminated by reading source rather than guessing: `FCMSSYNC`
  treats an all-zero Discrete Input A as IN sync (its ring loops are timer
  delays), and `FPMDSABL`'s `ZB TPCTPSW+2,X'5F00'` can only clear 0x5F,
  preserving PC1 (0x80) and the Instruction Monitor (0x20), so it cannot
  produce the observed zero mask.  Our `exec_ZB` is correct.

### [2026-09-02] Target: problems.md
- **THE OVERLAY-LOAD FAILURE IS A LOAD-BLOCK LENGTH DEFECT, AND IT IS FIXED.**
  `mmbstamp` gets seven of phase 3's ten lengths right and three wrong; the
  tape disagrees with all three, and the flight software believes the tape:
      block  4:  6982 -> 6966   (-16)
      block  9:   122 ->  160   (+38)
      block 10:  5604 -> 5654   (+50)
  Verified independently of the tool that made the change: against
  `pass-ipl-cflm.mmv`, the generated table has **7 of 10** load blocks
  checksumming and the corrected table has **10 of 10**.
- WHY A WRONG LENGTH IS NOT COSMETIC: the reader sums the block, compares it
  with the tail, rejects it, re-reads the identical blocks and gives up --
  leaving the overlay PARTIALLY applied.  Phase 3's first blocks land at
  0x01f6 and 0x0654, in PSA/CVT space, so a half-applied overlay is a
  corrupted FCOS, and the machine takes an unwakeable masked wait about 0.4 s
  later.  The 26-block read stops at exactly 13312, where block 10 begins, so
  the rejected transfer is the one containing block 9 -- which is why
  correcting block 4 alone changed nothing.
- `tools/fix_phase_table_lengths.py` does the correction and is the deliverable:
  the tape is the authority and can be read directly, since a load block is
  `[content L-2][0][checksum]` with `checksum == sum(content)`, so for a known
  start essentially one length verifies.  It walks each phase's blocks from its
  mass-memory address, block-aligned, and takes the length the tape agrees
  with.  A block that verifies at NO length is reported, never invented:
  that is a tape-content problem, and choosing a length silently would turn a
  detectable fault into an undetectable one.
- **THREE OF MY OWN BUGS IN THAT TOOL, all of which produced confident wrong
  output before being caught:**
  (1) it aligned in ABSOLUTE volume coordinates, but a phase's base need not be
  a multiple of 512 (phase 3 starts at volume halfword 158088) -- alignment is
  relative to the phase's own first block, and getting it wrong reported 9 of
  10 blocks as unconfirmable;
  (2) a `MIN_LB_HW` guard meant to reject noise also rejected phase 3's block 7,
  which really is 6 halfwords -- the minimum now guards only the blind search,
  never the generated length;
  (3) a search span of 5632 reported "no length verifies" for block 10, whose
  true length is 5654 -- I had recorded that block as an unfixable tape-content
  problem on the strength of exactly that bug.
- The `mmbstamp` side is diagnosed but NOT fixed: `_extend_mc_bank_tails` and
  `_open_bank_tails` both reshape a block's length from inferred MMB rules, and
  one of them is where the three errors come from.  That is Don's repository,
  so it is left read-only and reported rather than edited.

### [2026-09-02] Target: problems.md
- **CORRECTION to the commit above (`d7781ac24`): the load-block length defect
  is REAL but it is NOT the cause of the masked wait.**  With all ten lengths
  corrected and verified 10/10 against the tape, the machine still does the
  same two 26-block reads from 3/3/6/0 and still halts at ~391 s.  The commit
  message presents the length fix as the explanation of the halt; it is not,
  and only the offline 7/10 -> 10/10 result should be relied on.
- **AND THE OVERLAY APPLIES CORRECTLY.**  Load block 1 lands at 0x01f6 and
  **96 of 96 content halfwords match the tape exactly**, against different
  contents before the load.  So "a failed load corrupts FCOS" -- which is what
  I had reasoned the halt was -- is wrong twice over: the load is faithful, and
  fixing the lengths does not change the outcome.
- WHAT IS ACTUALLY WRONG IS THE EXTENT.  The reader asks for **26 blocks**
  (`EXTENDED BLOCK 598019`, 0x19 = 25, so 26) where the phase descriptor says
  the phase spans `ncont = 37`.  26 blocks is 13312 halfwords, which is exactly
  where load block 10 begins -- so blocks 1 through 9 are transferred and block
  10 never is.  The second read is the same 26 blocks at the same address.
  Where the 26 comes from, and why it is not 37, is the open question.
- Still unexplained, and worth stating separately: nothing yet accounts for the
  masked wait itself.  `FPMDSABL` cannot produce a zero interrupt mask, our
  `ZB` is correct, `FCMSSYNC` reads as in-sync, and the overlay content is
  faithful.  The halt follows a correctly-applied but INCOMPLETE overlay, which
  is a coherent thing to be next -- PASS overlaying phase 3 and then finding
  something absent, plausibly the program overlay (phase 8, mm 10880 = 5/2/4/0)
  which is never read at all.

### [2026-09-02] Target: problems.md
- **THE MASKED WAIT IS FULLY EXPLAINED, AND IT IS PASS BEHAVING CORRECTLY.**
  The chain, every link measured:
    1. `YAGPC_WAITTRACE` (new) catches the exact instruction: **`FPMDISP`+59**,
       the FCOS process dispatcher's `LPS@`, loading a PCT whose PSW is a
       deliberate halt -- `psw2=0x00020000`, wait set, mask 00, machine-check
       mask off.  The contrast proves it is deliberate: the NORMAL idle waits
       in the same run are `by=01df6` with mask **ff**, fully unmasked.
    2. The GRT row for GNC OPS 9 needs MF overlay phase **3** and program
       overlay phase **8**.
    3. **Phase 8's tape area (5/2/4/0) is BLANK.**  So is every other phase in
       file 5 -- 4, 5, 6, 7, 8, 18 -- and phase 12.  Written: 3, 9, 15, 16.
    4. So ARC pre-positions for phase 3 (`OVERLAY_NOT_AVAILABLE(1)` ON, the
       `;1` branch -- which is exactly what the register trace showed, R6=3),
       reads 26 blocks of it, and PASS then has no program overlay to run.
    5. FCOS dispatches the halt PSW.
  It is not an emulator defect, not a table defect, and not corruption.  PASS
  is refusing to enter an OPS it cannot load, which is what it should do.
- The overlay's write target is legitimate too, contrary to what I assumed for
  several rounds: 0x01f6 is phase 3's **ZCON pool** (`#QASIN`, `#QDATAN`,
  `#QDCOS` ... -- PHASE03's map places them there), so rewriting it is exactly
  what an overlay does, not PSA corruption.
- **THE REMAINING FIX IS A TAPE BUILD, AND THE WRITER DOES NOT EXIST.**
  `PHASE08.lib` is present and 147 KB, so the software is built; the volume
  simply never had it written.  `mmubuild` is analysis-only -- `--tree`,
  `--alloc`, `--systems`, `--loadmods`, `--directories`, `--image`, `--json` --
  and emits no volume, which settles the standing question.  MEDS2's
  `mmu put` can lay halfwords onto a tape, so what is missing is the piece
  between a `PHASEnn.lib` and the tape: load-block derivation, 512-halfword
  alignment, and the `[content][0][checksum]` tails.  That is the Mass Memory
  Build's phase writer, and writing it is a project rather than a patch.
- `YAGPC_WAITTRACE=1` is the new instrument and earned its place: a wait-state
  stop said WHERE the machine parked, the NIA ring said HOW IT GOT THERE, and
  neither said WHICH instruction parked it or with what mask -- which for an
  unwakeable wait is the whole question.
- Also fixed, a defect I introduced: `fix_phase_table_lengths.py` corrected the
  ten lengths but left `NUM_CONT_MM_BLKS` at 37 when the corrected blocks span
  38, so its "10 of 10" table was internally inconsistent.  It now corrects
  `ncont` too, preserving the multi-track flag.

### [2026-09-02] Target: problems.md
- **RETRACTION of commit `899e22eb6`: "phase 8 is blank on the tape" is WRONG,
  and so is the conclusion built on it.**  The `mmu` tool and `mmu2mmv`'s
  report address blocks as **track/file**/subfile/block; I read the CON80
  `ADDR=FTSBB` packing as file/track and dumped `5/2/4/0` when phase 8 is at
  `2/5/4/0`.  Re-censused with the right ordering, **every phase 3-18 is
  written on the tape** except 11 and 17, which are unassigned placeholders at
  0/0/0/0.  So the masked wait is NOT PASS refusing an absent overlay, and the
  "remaining fix is a tape build" conclusion goes with it.
- `mmu2mmv` DOES build a volume (17 of 52 phases; the rest are "not built"
  because their libraries are absent from the con80build root, not because the
  tool cannot write them).  That corrects the older note that no volume writer
  exists -- `mmubuild` has none, `mmu2mmv` is the writer, and it lives in
  `nsts-sdl-dps/src/tools/`.
- **The load-block length corrections still stand and are still real**: 6982
  and 122 verify at NO start anywhere near their blocks, while 6966 at rel 2560
  and 160 at rel 12800 verify uniquely, and 5654 at rel 13312 verifies uniquely
  where 5604 does not.  Those three are measured against the volume itself.
- **BUT the `ncont` correction is now in doubt.**  `mmu2mmv`'s own report gives
  phase 3 as **37 blocks**, which is what `mmbstamp` generated and what I
  "corrected" to 38.  With the corrected lengths and 512-halfword alignment the
  blocks span 18966 halfwords = 38 blocks, and rel 18944 -- the 37-block
  boundary -- holds `c6c6` fill.  Either the alignment is not uniform for the
  last block or the report and the tape disagree; unresolved, and the tool
  should not be trusted on `ncont` until it is.
- Standing lesson, the second time this session an ordering assumption has cost
  hours: **an address is not self-describing.**  `3/3/6/0` for phase 3 is
  symmetric in track and file and so confirmed nothing, and I carried the wrong
  ordering through every subsequent check until a phase with unequal track and
  file exposed it.

### [2026-09-02] Target: problems.md
- **THE MASKED WAIT IS TRACKED DOWN AND THE FAILURE MODE IS FIXED.**  The
  overlay's load block 3 (0x2662..0x2bab, sector 0) writes straight over the
  LIVE CZ2 compool.  Measured across the 385 s / 390 s snapshots:
      CZ2B_GRT_GPC_SET @0x026fc  f000 c000 f000 1400 ... -> 0000 0000 0000 0000
      CZ2V_GRT_TAB     @0x028ad  0001 0004 0003 0002 ... -> 0000 0000 0000 0000
  That is the GPC reconfiguration table the OPS transition is in the middle of
  reading.  Zero it and FCOS halts -- which is exactly the deliberate halt PSW
  `FPMDISP` was seen to dispatch.
- **WHY: the generated table's ADDRESSES do not match the running image.**
  Every `PHASEnn.sym.json` places `#PCZ2COM` at 0x14ac, and that address holds
  `C6C6` -- never loaded -- while the compool PASS actually reads is at 0x23f4.
  Load blocks computed against the map therefore land in the middle of live
  compool data.  It is systemic, not a phase-3 quirk: **7 blocks across phases
  3, 9, 10, 13, 14, 15 and 16** overlap it.
- `fix_phase_table_lengths.py --check-image SNAPSHOT` now locates the live
  compool BY CONTENT (CZ2COMMO's own `CZ2B_GRT_GPC_SET` initialiser is a
  ten-halfword signature), checks every load-block destination against it, and
  **refuses to emit a table that would corrupt live data**, exiting 2.  The
  failure mode was: inject a table, silently destroy PASS's own state, and get
  an unexplained masked wait several seconds later with nothing in the trace
  connecting the two.  It is now a detected, explained refusal.
- NOT resolved, and stated as such: WHY the image's compool placement differs
  from every phase map.  That is a build-provenance question -- the tape's
  phase-3 load-block lengths match `~/ipl-demo/phases` exactly, yet the loaded
  image's compool does not sit where those maps say.  Until it is settled, a
  table generated from those maps cannot be applied to this image, and the
  check is what makes that safe rather than silent.

### [2026-09-02] Target: problems.md
- **SETTLED: the image's compool sits at 0x23f4 because THE TAPE PUTS IT THERE,
  and the tape was built from a link whose map is not on this machine.**
  Proven directly, not inferred:
    * The stamped IPL phase table, read off the tape at FCMBOOT halfword 894
      (`FCMPTAD1`), gives phase 2 as 31 load blocks; block 6 is 15826 halfwords
      loading tape offset 2560 -> memory 0x00676.
    * `CZ2B_GRT_GPC_SET`'s ten-halfword initialiser signature sits at tape
      offset **10886** in phase 2, which through that block is memory
      **0x026fc** -- compool base **0x023f4**, exactly the live address.
    * The map's 0x14ac would put the signature at tape offset 6974.  It is not
      there; 10886 is the only occurrence.
  So there is no relocation, no SSL trickery and no emulator defect.  The map
  simply does not describe the phase 2 on this tape.
- **NO SURVIVING BUILD MATCHES.**  Every `PHASE02.sym.json` on the machine:
      0x014ac  ipl-demo/phases            (the one mmbstamp was run against)
      0x0231a  ipl-demo/dfg2/oursbuild
      0x02320  ipl-demo/dfg2/build
  none is 0x023f4.  `pass-ipl.mmv` is dated 2026-08-29; those libraries are
  2026-08-22.  The tape's own build root is gone.
- **THAT IS WHY THE OVERLAY CORRUPTED THE GRT.**  `mmbstamp` derived phase 3's
  load-block destinations from the 0x14ac build, where 0x2662 is free; on this
  tape 0x2662 is the middle of the live compool.  A table that is internally
  consistent and correct for its own build still destroys PASS's state when
  applied to a different one -- which is exactly what the new `--check-image`
  guard now refuses to do.
- **CONSTRUCTIVE, AND THE WAY FORWARD:** the tape carries AUTHORITATIVE
  load-block descriptors for the IPL phases in its own stamped IPL phase table
  -- phases 10, 2, 13 and 3, with main-memory address, prot/BSR/DSR flags and
  length for each, read directly with no link map involved.  For phase 3 that
  is precisely the data `#PFCMGPT` needs.  Deriving the table from the TAPE
  rather than from a `.lib` sidesteps the missing build entirely, and is the
  only route that cannot disagree with the volume it will be read from.

### [2026-09-02] Target: problems.md
- **THE OPS 9 OVERLAY LOAD WORKS, FROM THE TAPE, WITH NO RUNTIME INJECTION.**
      STOPPED ... reason: interrupted (SIGINT)      -- normal end of run
      mmu1: read  26 block(s) from 3/3/6/0          phase  3, MF overlay
      mmu1: read 110 block(s) from 2/5/4/0          phase  8, program overlay
      CZ2V_REC_OPS = 9, CZ2V_REC_XERR = 0           no error
      CZ2V_MF_OVLY = 3                              was 0
  Both overlays load and the reconfiguration reports success.  Every earlier
  attempt either never reached the tape or corrupted the GRT and halted.
- **HOW: `#PFCMGPT` and `#PCDCPHA` are STAMPED ONTO THE VOLUME**
  (`pass-stamped.mmv`, a copy; the original is untouched), with the phase
  descriptors taken from the tape's OWN IPL phase table rather than from a
  `mmbstamp` reconstruction.  `tools/stamp_phase_table_on_tape.py` builds the
  table; the rig takes `TAPE=` to select a volume.
- **THE ENCLOSING LOAD BLOCK MUST COME FROM THE TABLE, NOT FROM A SEARCH.**
  My first attempt located it by scanning for a start/length whose checksum
  verified, found `(612956, 5961)`, and "fixed" that -- corrupting phase 2's
  REAL block 18, `(615304, 8410)`.  PASS then failed to load at all and halted
  earlier than before.  A checksum match is cheap to hit by accident; the IPL
  phase table gives the true extents:
      #PFCMGPT  volume 616158  inside phase 2 block 18  (615304, 8410)
      #PCDCPHA  volume 633964  inside phase 2 block 23  (633736,  802)
  Both verified BEFORE stamping -- which is what proves the right block was
  found -- and again after, on an independent re-read.
- **`mmbstamp` IS NOT FIXED, and the framing "two tools disagree" is wrong.**
  There is ONE derivation: `tools/stamp_ipl_phase_table.py` (ours) calls
  `mmbstamp.phase_load_blocks()` (Don's), so the tape's table and today's
  output come from the same code and differ only by INPUT.  Neither surviving
  build root reproduces the tape: `~/ipl-demo/phases` has all ten phase-3
  extents but gives block 1 at 0x1f6 where the tape says 0x24a;
  `dfg2/build` gives 0x24a but lacks the 0x654 extent entirely and yields nine
  blocks, not ten.  `mmbstamp.py` and `mmu2mmv.py` also carry uncommitted local
  changes dated 2026-08-28/29 against a tape dated 2026-08-29, so the code that
  built it may not be the code on disk.
- The real MMB relocates some blocks and `mmbstamp` does not model it: five of
  phase 3's ten addresses match the lib extents exactly and five differ, by
  0x54, 0x190, 0x1092, 0x1434 and 0x193a -- no common factor.  Five deltas is
  not enough to infer a placement rule, and guessing one is what produced four
  wrong answers today.  The tape's IPL table also covers phases 2, 10 and 13,
  giving about fifty known-correct (lib extent -> tape address) pairs; that is
  the input a real fix needs.

### [2026-09-02] Target: problems.md
- **WHY THE TRANSITION DOES NOT COMPLETE: the PROGRAM overlay (phase 8) fails,
  and ARC records that failure as a zero.**  The chain is in `ARCGPC`:
      ARC_MF_PG_PH$(ARC_K) = 0                  when ARC_OVL_ERR$(self) is ON
      CZ2V_MF_OVLY   = ARC_MF_PG_PH$(1)         (ARCGPC:1005)
      CZ2V_PROG_OVLY = ARC_MF_PG_PH$(2)         (ARCGPC:1006)
  and `ARC_UPDATE_MC` sets `CZ2V_MC` only if BOTH match the GRT's phases.
  Measured after the run: **MF_OVLY = 3** (phase 3 loaded fine) and
  **PROG_OVLY = 0** (phase 8 errored), so `CZ2V_MC` stays 0, and
  `CZ2V_CURRENT_OPS` stays [0,0,0] -- the display never leaves `0001`.
- **WHY PHASE 8 FAILS: its load-block descriptors are wrong.**  Only **1 of
  27** checksum against the tape.  Phase 3's came from the tape's own IPL
  phase table; phase 8's are still `mmbstamp`'s, and the IPL table covers only
  phases 10, 2, 13 and 3.
- **AND THEY CANNOT BE RECOVERED THE WAY PHASE 3'S WERE.**  The checksum walk
  assumes each block starts at the next 512-halfword boundary after the last,
  which holds only while the lengths are mostly right: it self-corrects three
  wrong ones out of ten (phase 3) and drifts hopelessly when twenty-six of
  twenty-seven are wrong (phase 8), where it "recovered" a 110-block phase as
  70.  `fix_phase_table_lengths.py` now REFUSES when the recovered `NUM_CONT`
  moves too far, rather than writing a table that looks authoritative.
- Two real fixes to that tool on the way here, both mine, both of which had
  produced confident wrong output first: the blind length search now requires
  a candidate to be **followed by C6C6 fill to the block boundary** (without it
  some short prefix almost always sums to the next halfword, and phase 8's
  lengths "corrected" to 8, 13 and 14); and that fill test computes the
  boundary **relative to the phase base**, not absolutely -- phase 3 starts at
  volume halfword 158088, which is 392 into a block.  That is the third
  absolute-vs-relative alignment error of the session.
- Validation that matters: with both fixed, phase 3 reproduces the tape's own
  IPL table exactly -- 6966, 160, 5654 -- with zero blocks unconfirmed.  The
  oracle and the recovery agree.

### [2026-09-02] Target: problems.md
- **THE DASS DUMPS ARE THE RIGHT DATA SOURCE, and `mafgen/` supplies both
  halves.**  Eight `.fcm` memory images (flat, loaded at address 0 --
  `ageharness.c:load_fcm` does `membus_load16(ram, 0, ...)`) plus
  `augmented-*.json` CSECT maps of `{start, end, type, contents}`.  They map
  onto the GRT's memory configurations: SSW=OPS 0, G16=MC1, G2=MC2, G3=MC3,
  S2=MC4, P9=MC6, G8=MC8, **G9=MC9**, so G9 is a real GPC image in the exact
  configuration our OPS 901 targets.  Only MC5 (SM OPS 4, program overlay
  phase 16) has no dump -- and per the user that configuration does not exist
  for these flights.
- OI340700 source = the OI340600 tree with `OI340700/`'s files copied over it
  (its README says so), so the build cards come from OI340600 and approach #2
  is not blocked for want of a CON80.  I had been about to report otherwise.
- **PHASE 8'S REAL BLOCK STRUCTURE IS RECOVERABLE FROM THE TAPE, and mmbstamp's
  is wrong in a specific way: it MERGES tiny blocks that are really separate.**
  The tape begins phase 8 with 4-halfword load blocks carrying one ZCON each:
      rel   0:  80f8 0e20 0000 8f18     0x80f8 + 0x0e20 = 0x8f18
      rel 512:  81f8 0e20 0000 9018     0x81f8 + 0x0e20 = 0x9018
  each on its own 512-halfword tape block.  I dismissed these as noise twice
  before checking the arithmetic.  A walk using the checksum plus the
  "followed by C6C6 fill to the boundary" rule recovers **35 blocks with ZERO
  ambiguity** -- every one had exactly one verifying length -- against
  `mmbstamp`'s 27.
- **IT STALLS AT TAPE BLOCK 87 OF 110.**  From rel 44544 there are 11,776
  halfwords, 11,763 of them non-fill, and NO length checksums there under any
  phase extent, aligned or packed.  So the last ~23 blocks are not in the
  `[content][0][checksum]` form the first 35 are.  Unresolved.
- Naive grouping does not substitute: the 440 CSECTs unique to G9 (666 minus
  the 176 shared with G16/G2/G3/G8, which are phase 3's MF overlay) form 80
  contiguous runs, not 35 blocks, and only 5 verify.  The MMB's grouping is
  its own rule and the tape is the only witness to it.
