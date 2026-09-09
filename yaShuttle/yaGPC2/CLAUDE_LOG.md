# CLAUDE_LOG.md

(Cleared 2026-09-09 by Full Documentation Sync.  Four entries applied to
`HANDOFF-OPS9.md`: the v27 result and the run that verifies it, the csect-table
sizing rule and the `STACK` cards as build steps, the refreshed block counts and
comparison table, and a "What is still open" section.  In the same sync, 36
notes were applied to `modules/sdfpkg/HANDOFF-OI340600.md` as entries #304-#321
via `dass-handoff.py`, and marked applied with `dass-notes.py done`.)

Append new entries below this line.

### [2026-09-09] Target: HANDOFF-OI340600.md
- NO TAPE COMPLETES AN OPS TRANSITION IN THIS ENVIRONMENT, INCLUDING THE
  REFERENCE, AND OURS GETS FURTHEST.  The control that #316 said had never
  been run was finally run: pass-ipl-cflm.mmv given the same
  `@120s:ITEM,1,EXEC;@430s:OPS,9,0,1,PRO`.  It reaches GPC MEMORY, takes both
  keystrokes, runs 360,758,813 steps without halting -- and requests NO
  overlay phase at all, while taking 485 store-protect faults at 1EA76
  (FIOPDSRB).  v35 on the same sequence runs GRT slot 1 (phase 3 re-read, 26
  blocks) and slot 2 (phase 8, 122+115 = 237 of its 243) and takes ONE
  store-protect, at 080D6 = FPMSVCEP+8.  So "phase 18 is never requested" is
  NOT established as a defect of our build; the user's own finding that
  OPS 201 PRO and OPS 301 PRO fail identically -- neither needs phase 18 --
  says the same thing from the other side.  Every comparison against "the tape
  that works" made before this control is worth re-reading with that in mind.
- YAGPC_ISPB_ALIGN=1 IS REFUTED AND MUST STAY OFF.  The hypothesis was that
  the fullword ISPB "clear protect" forms, issued with an odd EA 60 times per
  IPL and all 60 mis-targeted, leave a location protected so the next
  legitimate store faults -- which would explain both tapes failing on a
  store-protect in resident FCOS.  Measured: the REFERENCE tape with the flag
  set does not even IPL (bootstrap and phase 10 only, 0 keystrokes delivered,
  wait-state timeout at 2.6M steps), and v35 gains new faults at 10002, 7FF5E
  and 91 of them at 7FFFE.  cpu_instr.c's own comment was right that the EA in
  that path is off by one and `fwAddr = ea` papers over it; the papering is
  load-bearing.  Settle the EA before touching the flag again.

### [2026-09-09] Target: HANDOFF-OI340600.md
- FOUR TOOL DEFECTS IN con80build/lnk101, ALL PATCHED ON THE COPY AT
  /tmp/claude-1000/c80src AND ALL FOR DON.  (1) runtime_csect_index() built
  its map ONLY from *.asmg.json sidecars and this tree has NONE -- 0 beside
  SYSLIBL1's 4277 objects, RUN's 205 and ZCON's 284 -- so the index was always
  empty, inserted_runtime_objects() always returned zero, and EVERY CON80
  INSERT of a resident-library csect was silently dropped from every build we
  have ever made.  Phase 2 carried none of the HAL/S runtime, so
  `MAP 2,LIBZERO,LIBRESD,LIBRESC` reserved nothing and the overlay phases
  placed content on the library's addresses.  Fixed by reading each object's
  own ESD.  (2) The same fix's duplicate check compared PATHS, not csect
  names, and the same object reaches the link from the worklist AND from the
  minimal library -- the LE keeps the first definition and deletes the later
  one, which left #DDSPSPC, #DDPDSPC, #DDXCCCS and #DDXRDMM (the display data)
  as EMPTY pinned sections and the machine sat at POLL IDLE.  (3)
  generateStackSections() ignored the --external-syms pin, so generated stacks
  were placed by sequential allocation and landed INSIDE live data: @0DMPMMM
  at 0A638 inside #DDMPMMM's 0A52E..0A6A4, 100 halfwords of DMPMMMSG's own
  data overwritten by its own stack.  (4) It also SIZED them from a
  longest-call-chain estimate, which moves when the graph moves: linking the
  resident library took @0ARBIDL from 214 halfwords to 76 and @0DMCSUP -- the
  display manager's -- from 206 to 192.  Both address and size now come from
  the csect table, which states what the flight machine allocated.
- THE STANDING LESSON FROM ALL FOUR: where the flight machine's value is
  known, TAKE IT, do not compute it.  Every regression in this sequence was a
  DERIVED quantity moving when its inputs changed -- the DEU poll rate, the
  stack sizes, the phase layout, the duplicate-suppression key.

### [2026-09-09] Target: HANDOFF-OI340600.md
- EACH PHASE NEEDS THE CSECT TABLE OF THE CONFIGURATION IT BELONGS TO.  A
  phase linked with no table is laid out by sequential allocation and scatters:
  phase 12's own INSERTs landed at 0x50912 where P9 has them at 0x20022, and
  its record was 321 blocks against a 216 allocation; with the P9 table it is
  216, EXACTLY the original's.  The configuration was chosen per phase by
  counting how many of the phase's linked csects each of the eight dumps
  contains, and the answer was unambiguous every time: 2 SSW, 3 G9, 4 G16
  (1689 of 1689), 5 G2 (1291 of 1291), 6 G3, 7 G8, 8 G9, 9 P9, 12 P9 (606 of
  607), 14 S2, 15 S2, 18 G9.  Phases 1 and 10 take NO table.
- THE RESULT, v35: 8 of 14 phases match the original's block count EXACTLY --
  2 (228), 3 (38), 4 (414), 6 (385), 8 (243), 10 (55), 13 (7), 18 (34) -- with
  no oversize phase, no new holes, and all 30 stacks at the exact flight
  address AND size.  This closes the oldest open item in this work: phases 4,
  5, 6, 7, 8 and 15 had been a third to a half short since the beginning.

### [2026-09-09] Target: HANDOFF-OI340600.md
- HALSTAT.ASC IS NOT STALE, AND IT COVERS THREE CONFIGURATIONS THE DASS CORPUS
  DOES NOT.  The user offered it with the caveat that it is out of date with
  respect to DASS.  Measured, it is not: across the eight configurations that
  have both, it agrees on 9,931 of 9,935 csect addresses -- SSW 660/660, GNC1
  (=G16) 1819/1819, GNC3 1629/1629, GNC9 1272/1272, SM2 1226/1226, GNC2
  1415/1416, GNC8 1225/1227, PL9 685/686.  It is also a SUPERSET: 7 to 21
  csects each dump lacks, against 0 or 1 the other way.  Its eleven maps
  include BOOT (9 csects), SSLS (431) and SM4 (1234) -- phase 1, phase 10 and
  PHASE 16, none of which has a DASS dump.  Phase 16 is the one phase that
  still will not link, and "the corpus has no SM4 dump" was the stated blind
  spot in the SPEC-4 exclusion analysis; it is no longer blind.  Parsed to
  /tmp/claude-1000/halstat-maps.json.

### [2026-09-09] Target: HANDOFF-OPS9.md
- A POLL COUNT IS A BAD CLOCK AND YAGPC_DEUKEYS NOW TAKES SECONDS.  "@180s:"
  gates on the wall clock, "@150:" still on a poll count.  The poll rate is a
  function of the build under test -- about 1.6 s/poll on a tape that reaches
  GPC MEMORY, 9.3 on one that does not -- so a gate chosen from one build
  silently fails to fire on the next and the run looks like a transition that
  did nothing rather than a keystroke that was never sent.  ALWAYS CHECK
  `grep -c 'DEUKEYS delivered'` equals the number of batches before drawing any
  conclusion; it caught two invalid runs.
- AND ITEM 1 EXEC MUST FIRE BEFORE RUN_AT-8.  The panel deselects the IPL
  source at RUN_AT-8, and FCMINSSL is the IPL loader: with the source already
  off it takes the wait at FCMINSSL.asm:273, "NEITHER MMU 1/2 SELECTED FOR
  IPL", PSW2=000A0000, and PASS never loads at all.  That is a DIFFERENT wait
  from the three-checksum-errors one at FCMSSLEX and it looks exactly like a
  broken tape.  Post-IPL the rule inverts -- FIOMGSNC will not dispatch
  mass-memory I/O for a still-IPL-selected MMU, which is why SOURCE_RUN=OFF
  exists.

### [2026-09-09] Target: HANDOFF-OI340600.md
- THE ARCGPC RANGE TRACE, RUN ON v35, AND WHAT IT SETTLES.  YAGPC_TRACEWIN over
  simulated 405-425 s, 13,327,289 instructions, filtered to ARCGPC's
  40F34..419EF (which our per-phase csect tables place IDENTICALLY to the range
  #299 used).  The GRT-index code at 4156C and the overlay request SVC X'015D'
  at 4157B each execute EXACTLY TWICE -- t=410.3275/410.3277 for slot 1 and
  411.5240/411.5243 for slot 2 -- and ARCGPC is NEVER ENTERED AGAIN: 0 visits
  from 411.5243 through the end of the window at 425.0.  So the loop does not
  return from slot 2; it is not exiting early.
- AND PHASE 18 IS DEFINITELY EXPECTED.  CZ2V_GRT_PHASES is at relative
  halfword 1348 of #PCZ2COM (0x023F4, the same address in our build and in
  every dump), so 0x02938; read out of a live snapshot its rows are
  0:(3,4) 1:(3,5) 2:(3,6) 3:(14,15) 4:(14,16) 5:(9,12) 7:(3,7) and
  ROW 8 = (3, 8, 18) -- the G9 row, GRT index 9.  It is INTACT at t=400, 445,
  480 and 560, and CZ2V_REC_GRT_INDEX reads 0009 after the request.  The
  request is understood, the table is right, the loop issues two of three.
- WHAT IS LEFT.  Phase 8's DATA arrives in full (reads at t=412.1 and 417.7,
  122+115 = 237 blocks) but the COMPLETION is never posted, so ARC_OVL_EVT
  never fires.  That is #300's chain, but NOT #300's cause: no load block
  covers the completion chain at 0x8168-0x8180 and the chain is intact in live
  memory.  The one anomaly inside the window is a single store-protect at
  080D6 = FPMSVCEP+8 (the SVC BRANCH VECTOR TABLE, deliberately protected by
  the deck's `OVERLAY FCOS1SET ------- PROTECTED BANK 1 THINGS`), from
  FIOSVC+13 -- and FIOSVC is IN the completion chain (#300: FIOSVC.asm:263
  reads TIOSEVNT and copies the address into the IOQE).  It is an SRS
  (base-register-relative) instruction, `A11D`, so the address is not baked in
  and the base register is what is wrong; FIOSVC's own FI$SVC references are
  CORRECT (its first instruction, BFF3 92CE, stores to FI$SVC+14 = 0x092CE,
  and FI$SVC resolves to FCMSAVE at 0x092C0 exactly as in the dump).  The
  loaded image matches the linked image, so the tape is not corrupt.
- TWO HYPOTHESES KILLED BY MEASUREMENT ON THE WAY, both recorded so they are
  not re-run: (a) AIG_DEU_LOADER stuck at `WAIT FOR NOT CZ2E_SHRD_EVT` -- the
  event is at #PCZ2COM+1272 = 0x028EC and reads 8A93 (a waiter queued) at
  t=400 and 0000 at 445/480/560, so it clears normally; (b) a branch into
  overlaid data at 0x20241 -- at t=411.9 phase 8 has not loaded yet, 0x20241
  still holds SSW's $0AIGDEU code, and those interrupts are on PSA vector 0068
  with a `code` field that is not a program-check code, unlike the store
  protect's 0048/0007.  $0AIGDEU being absent from every GNC configuration
  (present only in SSW, P9, S2) remains true and still explains why OPS 201,
  301 and 901 behave alike, but it is not the mechanism.

### [2026-09-09] Target: HANDOFF-OI340600.md
- THE OPS 901/201/301 BLOCKER, MEASURED FAR MORE PRECISELY THAN BEFORE -- AND
  MY CANDIDATE CAUSE IS DISPROVEN.  What is established, all from an
  instruction trace (YAGPC_TRACEWIN over simulated 405-425 s, 13.3M
  instructions) and live snapshots, on v35:
    * The request is understood.  CZ2V_REC_GRT_INDEX reads 9 and the G9 row of
      CZ2V_GRT_PHASES (#PCZ2COM+1348 = 0x02938) reads 3, 8, 18 and stays
      intact at t=400, 445, 480 and 560.  Phase 18 IS expected.
    * ARCGPC executes the GRT-index code at 4156C and the overlay request
      SVC X'015D' at 4157B EXACTLY TWICE (410.3275/410.3277 and
      411.5240/411.5243) and is NEVER ENTERED AGAIN through 425.0.  It does
      not exit the loop early; it does not return from slot 2.
    * Phase 8's DATA arrives in full (122+115 = 237 blocks of its 243) but
      FIOMGCMP -- which posts the completion -- is not entered once after
      second 411, while FIOMGMTR keeps polling 15/s.  FIOMGMTR's first test is
      the MM READY discrete: `LH R5,CZ2BDIA; L R3,TIOQMNTM; SLL R3,FIOMMRDB
      (=12); NR R3,R5; BC 07-4,#@LB13`, and it takes the not-ready branch every
      time, skipping both `SB TIOQFLG1,TIOQIOCM` sites, so #@LB4's test of
      TIOQIOCM fails and the FIOMGCMP call is jumped over.  Measured: the
      IOQE at 090B2 holds TIOQFLG1=0C00 (LTMM set, IOCM never) at 411, 412.5,
      413.5, 414.5 and 415.2.
    * ENTRY #300 IS WRONG THAT "the MMU READY discrete appears NOWHERE in the
      path".  It is FIOMGMTR's first and controlling test.
    * #300's own root cause is GONE: no load block covers the completion chain
      at 0x8168-0x8180 and the chain is intact in live memory.  Our FIOCBLKS
      is byte-identical to the flight machine's, including the odd last free
      -pool link 09262 -> 080CE.
    * The store-protect at 080D6 (FPMSVCEP+8) is a CONSEQUENCE: completions
      stop at 412, the 25-entry IOQE pool then drains (TCVTIOFP 090E8 ->
      0910C -> 091D2 -> 0922C -> 080CE) and FIOSVC allocates the terminator.
- THE CANDIDATE CAUSE, AND ITS REFUTATION.  From second 412 the dispatcher
  runs 4300-4900 times a second, every dispatch entering $0AIGDEU and
  executing ONLY offset 0x21F -- 0x20241, which phase 8's LB23 (2009C..210A7)
  has just overwritten.  AIG_DEU_LOADER is a LIVE cyclic process (13-14
  dispatches/s, 130 distinct offsets) that never completes its DEU load:
  AIGV_DEUIPL_ERR_CODE = 2, "INVALID DEU BITE STATUS RESPONSE", on DEU 2.
  The REFERENCE TAPE behaves identically (13-14/s, same 130 offsets), so this
  is not a build defect.  It looked like the whole story.  IT IS NOT: with
  YAGPC_DEUPRELOADED=1, so AIG_DEU_LOADER has nothing to do and closes, the
  transition STILL runs only slots 1 and 2, phase 18 is still not requested,
  and the 080D6 store-protect goes from 1 to 4.  The thrash is real and is
  NOT the blocker.
- THREE FIX ATTEMPTS, ALL FAILED, RECORDED SO THEY ARE NOT REPEATED.  (a)
  Always setting BITE1 bit 0x4000: no effect, because the word deu_bite1()
  returns is not the word AIGDEU reads.  (b) Dropping the second DEU: no
  effect -- PASS's DEU load table lists DEU 2 whether or not a model answers.
  (c) Putting the message header first in deu_bite_response(), which IS
  justified -- AIGDEU.hal:252 aims the transfer at CZ1B_D_DEU_MSG_HDR and
  ##CZ1COM.sdf places CZ1B_D_BITE_STAT immediately after it at relative
  halfword 5 against the header's 4 -- and which DID take AIGDEU past error 2
  for the first time and removed the 080D6 fault; but AIGDEU then looped on
  the DCP mass-memory read instead (454 reads of 17 blocks from 4/4/0/7) and
  starved the transition of MM service entirely, so slots 1 and 2 did not run
  at all.  A regression, so src/deumodel.c was REVERTED to HEAD; the attempt
  is kept at /tmp/claude-1000/deumodel-bitefix.c.
- WHERE TO GO NEXT.  The chain from "FIOMGMTR never sees READY" to "no slot 3"
  is solid; what is NOT established is why the completion never posts once the
  transfer ends and READY returns.  The transfer is ~3.6 s of model time for
  122 blocks, which is the right order for the real hardware, so slowness is
  not obviously the fault.  Instrument FIOMGMTR's not-ready branch and the
  moment READY re-asserts, rather than the dispatcher.
