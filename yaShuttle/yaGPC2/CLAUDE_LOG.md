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
