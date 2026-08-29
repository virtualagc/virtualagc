# CLAUDE_LOG.md

(Cleared 2026-08-27 by Full Documentation Sync.  34 entries spanning
2026-08-26 to 2026-08-27 were applied to the two files they named:

- **`problems.md`** (27 entries) — five new subsections continuing §8:
  **§8.11** finishing the OI340700 `.dfg` recovery (all twelve differing
  decks accounted for, five compools recovered exactly, the learned
  decoder encoding, `SPCHAR`, the column budget for recovered source, and
  the three halfwords that are `dfg`'s rather than ours); **§8.12** the
  `-full` exceptions lists, one of whose entries is demonstrably wrong and
  which cannot be regenerated; **§8.13** booting from the real tape and why
  `ITEM 1` loaded nothing (`SSLENGTH` zero underflows `SSLCHECK`'s `BCT`),
  plus the deterministic harness; **§8.14** the emulator defects running
  the SSL found (silence read as a switch position; `#BU@` indirection,
  settled from `FIOBBM` rather than from the POO wording; `FIOMUWB2` as a
  link-input gap); **§8.15** the fullword alignment mask, written up in
  full as an unresolved conflict with four explanations ruled out.  Seven
  new method failures were appended to §8.10 and the section's date range
  extended to 2026-08-27.
- **`HANDOFF-FCMBOOT.md`** (7 entries) — two new §2 subsections, "The
  firmware IPL" (no-`fcm` boot over the bus, the IPL pushbutton, FTSBB,
  the stamper, why reload is load-bearing) and "The SSL" (the `ITEM 1`
  diagnosis and where the boot now stands); the deterministic harness and
  the no-`fcm` invocation added to §3, with a second address table for
  GPCIPL and the SSL; three tools added to §4; three traps added to §5;
  "What is actually still open" rewritten.

**The stale line the log flagged for this sync is fixed.**  §2 said nothing
emulated the IOP microcode and that `--power-on` was what FCMBOOT's "RECEIVES
CONTROL FROM THE MICRO CODE LOADER VIA THE SYSTEM RESET PSW" meant, which
contradicted its own address table.  Both halves were wrong; the paragraph now
says so rather than being quietly deleted, and §1's matching bullet was
corrected too.

Claims were checked against the tree rather than copied from the log.  Two log
claims did not survive and were corrected in the process: **the BCE decode
table has 27 instructions**, not the 24 the log corrected 21 to — measured by
listing the mnemonics instead of counting regex matches, which is what produced
both wrong figures — and **five deck/config pairs**, not six, needed no source
change (the log names five and gives five numbers).  `YAGPC_LXATRACE` was not
written down: it was temporary and no longer exists.  Everything else cited —
the trace variables, the three new tools, `--discrete-a`/`--discrete-b`, the
`#BU@` dereference, `cpu->lastProtFaultAddr`, `#WAT` at `iop_bce_instr.c:440`,
the `psaRanges` carve-out, the unpushed-commit count — was verified present.)

### [2026-08-27] Target: [problems.md]
- POO CHECK DONE, AND THE MASK IS CORRECT.  Section 2, the note to Figure
  2-8 "SRS Fullword Addressing", in the AP-101 C/M Principles of Operation
  (IBM-6246156, 30 January 1979):
      "Even though the addition of a base and the fullword displacement
       [results] in a halfword address, bit 15 is ignored when addressing
       fullword second operands.  As a result, the same fullword address is
       obtained regardless of the contents of base bit position 15."
  So `ea & 0xfffe` is right and now has a citation, replacing the
  "inherited from gpc, no POO citation" provenance that made it suspect.
  Added at both mask sites in cpu.c.
- AND IT RULES OUT MY OWN UNTRIED CANDIDATE.  I had recorded "mask the
  DISPLACEMENT term only, leaving an odd BASE intact" as the one idea not
  tried.  The POO says the opposite in as many words: base bit 15 is
  precisely the bit that does not matter.  Good thing it was left untested.
- THE SCALING IS CONFIRMED TOO, from the same pair of figures: for halfword
  operands the displacement's LSB aligns with base bit 15 (Figure 2-7), for
  fullwords with base bit 14 (Figure 2-8).  That is our
  `disp << (addrWidth - 1)`, exactly.
- FORMAT VERIFIED, NOT ASSUMED: `L` exists only as the 16-bit SRS form
  `00011xxxddddddbb` -- 2-bit base field, so B2 = 0 here is register 0 and
  base addressing IS performed.  The RS "when B2 equals 11" no-base rule,
  which is where the POO repeats the bit-15 statement for RS format, does
  not apply.  Figure 2-8 governs.
- WHICH MOVES THE DEFECT UPSTREAM, and the source says where.  Read
  directly rather than from my earlier note of it, FCMINSSL.asm:
      FCMLBRTB DS 2F / FCMCTXT1 DS 7H / FCMCTXT2 DS 7H / FCMNEXTB DS 1H
      FCMNEXTS DS 1H / FCMCURRS DS 1H / FCMMOVRG DS 8F
      TFCMCTXT DSECT / TFCMTGTA DS H / TFCMTGTS DS H / ...
      L R3,TFCMTGTA   under   USING TFCMCTXT,R0
  IDENTICAL IN OI301700 AND OI340600, checked side by side.  My earlier
  computed layout was right about the offsets but had the wrong member list
  -- it omitted FCMNEXTB entirely -- so it agreed by luck.  Use these.
- THE ALTERNATION IS INHERENT, traced through the source: the dispatch does
  `LH R5,FCMCURRS / LH R0,0(R5,R0) / TH TFCMUPMF / BAL FCMMOVE`, and at the
  end of each load block `CURRS := NEXTS` then `XIST 0(R0),X'0001'` flips
  NEXTS.  So the struct in use advances per LOAD BLOCK, and a third
  iteration lands on FCMCTXT2 whatever the machine does.
- SO THE REAL MACHINE READS THE SAME WRONG FULLWORD WE DO.  `L R3,TFCMTGTA`
  is a fullword read of a Z-CON pair (TFCMTGTA "bits 0-15" + TFCMTGTS
  "sector") out of a struct that `DS 7H` guarantees is odd every other
  time.  Either the real flow never reaches FCMMOVE on an odd iteration, or
  FCMINSSL has a latent alignment bug that its real load profiles never
  tripped.  THAT is the question now, and it is a better one than the mask.
- NEXT MEASUREMENT, cheap and decisive: instrument FCMMOVE entry to print
  R0, FCMNEXTS (0x7347) and FCMCURRS (0x7348) on every call, and dump phase
  2's load-block descriptors with the sector field (flags bits 8-11) and
  whether it exceeds FCMLOWSC=7.  ALIGNTRACE already says the misalignment
  at 0x072a4 happens EXACTLY ONCE in a whole boot, so FCMMOVE is reached on
  the odd struct once -- the count of preceding load blocks is what to check
  against the real phase, since that is what picks the struct.
- DOCUMENT: ~/Desktop/sandroid.org/public_html/apollo/Shuttle/IBM-6246156 -
  Space Shuttle Model AP-101 C, M Principles of Operation.pdf.  It OCRs
  usably with `pdftotext -layout`; section 2 addressing runs from about
  line 1250 to 2200 of the extraction, and section 14 is Automatic Index
  Alignment.

### [2026-08-27] Target: [problems.md]
- WHY THE POO SAYS "BASE bit 15" AND NOT "EA bit 15" -- user's question,
  and the answer makes the citation stronger rather than looser.  THE BASE
  IS THE ONLY THING THAT CAN SUPPLY BIT 15.  From the figures' own bit
  rulers, not the prose:
      Figure 2-7 halfword displacement   bits 10-15   (LSB at bit 15)
      Figure 2-8 fullword displacement   bits  9-14   (LSB at bit 14)
  Bit 15 is the LEAST significant bit in IBM numbering, so nothing can
  carry into it, and the fullword displacement field does not reach it.
  EA bit 15 is therefore IDENTICALLY base bit 15 -- the same bit, not a
  derived one.  Naming the base is the precise formulation, not a loose one.
- AND IT GENERALISES, per Figure 2-13 "Automatic Index Alignment":
      halfword     index taken DIRECT from index register bits 0-15
      fullword     index register bits 0-15 SHIFTED LEFT 1
      double word  index register bits 0-15 SHIFTED LEFT 2
  So an index cannot supply bit 15 either (nor bits 14-15 for a double
  word).  Across SRS and indexed RS alike, the base is the unique source.
- WHERE THE POO DOES SAY "EA", it is where no base exists: the RS
  B2 = 11 case, "the displacement is instead used directly as the address
  ... Bit 15 of the operand effective address is always treated as zero
  when addressing fullword operands."  The wording tracks where bit 15 can
  come from in each mode.
- TWO CONSEQUENCES FOR US.  (1) `(base+disp) & ~1` and `(base & ~1) + disp`
  are provably the same here, since disp contributes 0 to bit 15 and no
  carry reaches the LSB -- so our `ea = (base + disp) & 0xfffe` matches
  either reading of the rule.  (2) The base formulation is an
  UNCONDITIONAL GUARANTEE about hardware behaviour, not a "misaligned
  operands are undefined" caveat, so there is no room left to suppose a
  real AP-101S did something else with FCMMOVE's odd struct.  That door is
  shut, not merely unlikely.
- ALSO SETTLES an adjacent worry: `LH R0,0(R3,R0)` indexing FCMBCTXT is a
  HALFWORD operand, so Figure 2-13 says the index is taken direct -- our
  indexWidth for LH is right, and the FCMBCTXT lookup is not the defect.

### [2026-08-27] Target: [problems.md]
- IS THE DISPLACEMENT MASKED?  NO -- IT IS SHIFTED, and only in SRS.  User's
  question, answered from the figures' own bit rulers:
      SRS halfword   displacement field at bits 10-15   (LSB at bit 15)
      SRS fullword   displacement field at bits  9-14   (LSB at bit 14)
  Same 6-bit field, POSITIONED one bit higher for fullwords, so the value
  is scaled x1 or x2 and never truncated.  That is our
  `disp << (addrWidth - 1)` exactly.  In the EXTENDED/RS form it is not
  even scaled: POO, "The alignment of the displacement is the same whether
  addressing double word, fullword or halfword operands", and our extended
  path does plain `disp = df_get(v,'d')`.  Correct in both.
- THE MASK IS ON THE SUM, NOT THE DISPLACEMENT, and there is only one of
  them -- `& 0xfffe`, for fullwords.  Halfwords get none (every halfword
  address is legal).  NO DOUBLE-WORD MASK IS MISSING: all seven
  double-word instructions (AED CED DED LED MED SED STED) use the
  `11111abb/X` extended form, so addrWidth 3 NEVER reaches the SRS branch,
  and `if (addrWidth == 2)` there is complete rather than an oversight.
  Checked by listing the table, not by assuming.
- THE INDEX IS SCALED TOO, and matches POO Figure 2-13 "Automatic Index
  Alignment": halfword direct, fullword shifted left 1, double word shifted
  left 2 -- our `regx = (reg >> 16) << (indexWidth - 1)`.
- BUT AN OPEN QUESTION FELL OUT OF THE SAME READING.  The `& 0xfffe` is
  applied ONLY in the SRS branch, in both cpu_g_ea and cpu_g_ea_16.  The
  extended/RS branch forces nothing -- yet in RS the displacement is
  UNSCALED and can itself supply bit 15, and the POO says "Bit 15 of the
  operand effective address is always treated as zero when addressing
  fullword operands."  That sentence sits inside the B2 = 11 no-base case,
  so whether it governs all of RS or only that case is genuinely ambiguous.
- MEASURED: IT FIRES, 53 TIMES in the reachable part of a boot, and all 53
  are INDEXED accesses with a real base -- b=1 x=6 at 0x00e4d (41), 0x00e6f
  (5), 0x00e90 (4), and b=0 x=4 at 0x00f75 (3); ia=0 ii=0 throughout.  So
  the B2 = 11 case, the one place the POO states the rule outright, never
  occurs, and the ambiguity cannot be dodged.
- AND NOTHING CAN ARBITRATE IT.  A/B with the mask added to both extended
  branches: cpu EA/CC fixtures 20447/20447 either way, cpu instr exec
  111180/111358 either way, and the boot BYTE-IDENTICAL (55 blocks, 28162
  words out and taken, same position, same DEU counters).  THE CONTROL DID
  RUN this time -- the probe went 53 hits to 0 with the mask and back to 53
  without, which is the check that was missing from the `#BU@` A/B.
- SO IT IS LEFT ALONE, deliberately.  Three changes have been reverted this
  session for being made on plausibility; this one has less support than
  any of them, since no measurement distinguishes it at all.  It needs
  either a POO passage that scopes that sentence, or a case where the two
  behaviours diverge.  YAGPC_RSALIGNTRACE is kept so the next person can
  find such a case cheaply -- it is the same env-gated, only-on-oddness
  shape as YAGPC_ALIGNTRACE and costs nothing when quiet.

### [2026-08-27] Target: [problems.md]
- THE FCMMOVE DEFECT IS LOCATED, AND IT IS NOT THE EMULATOR.  Two
  measurements settle it.
- FIRST, PRIMARY EVIDENCE THAT OUR LINK IS RIGHT.  OI301700's "as received"
  SSSRC/FCMINSSL is an ORIGINAL-BUILD LISTING WITH OBJECT CODE (OI340600's
  is plain source -- only OI301700 ships listings, which is the whole
  premise of HANDOFF-OI340600).  Its resolved addresses give the work area
  outright:
      FCMLBRTB 0378   FCMNEXTB 038A   FCMNEXTS 038B   FCMCURRS 038C
      FCMMOVRG 038E   FCMBF1CT 039E   FCMBCTXT 03A0
  Walking the DS chain from 0x378 reproduces every one: +2F=4 puts
  FCMCTXT1 at 037C, +7H puts FCMCTXT2 at 0383, +7H lands FCMNEXTB at 038A
  exactly, and FCMMOVRG's DS 8F needed a ONE-HALFWORD PAD from 038D to
  038E -- which the listing confirms, and which proves the original
  assembler aligns DS F just as ours does.  With CSECT base 0x6FBC
  (= 0x7334 - 0x378, our own FCMLBRTB) that is FCMCTXT1 = 0x7338 and
  FCMCTXT2 = 0x733F, THE EXACT ADDRESSES OUR LINK PRODUCES.  So the odd
  struct is in the real flight build too, and lnk101 is not at fault.
- SECOND, WHY IT IS REACHED.  New YAGPC_NIAPROBE at the sector test
  (CHI R4,FCMLOWSC, found at 0x710b by scanning our own image for the
  B5E4 0007 the listing shows) gives all 21 of phase 2's load blocks and
  their computed sectors:
      0 0 0 0 1 1 1 2 2 3 3 3 3 3 4 5 5 6 7 8 9
  FCMLOWSC is 7 and the test is GT, so EXACTLY TWO blocks are above 128K:
  ordinals 20 and 21.
- AND THE STRUCT IS CHOSEN BY ORDINAL PARITY.  NEXTS toggles once per load
  block, measured 0,1,0,1,... across all 21, so block N builds into
  struct[(N-1) & 1] and its move (one iteration later, double-buffered)
  uses that same struct.  Block 20 is EVEN, so it gets FCMCTXT2 -- the odd
  address -- and block 21 would have got the even one.  The single observed
  FCMMOVE call reads exactly that: nia=072a4 base=0733f NEXTS=0000
  CURRS=0001, i.e. block 20's context out of struct 1.  The boot dies
  before block 21's move ever happens.
- SO THE INVARIANT FCMINSSL SILENTLY DEPENDS ON IS: EVERY ABOVE-128K LOAD
  BLOCK MUST SIT AT AN ODD ORDINAL in its phase's load table.  Nothing in
  the source states it, nothing checks it, and one of ours violates it.
  Since the struct layout is byte-identical to the original build, the
  variable that differs is OUR PHASE 2's LOAD-BLOCK LIST -- how many blocks
  our mmubuild reconstruction emits and in what order.  THAT is where to
  look next, not in cpu.c.
- NEXT STEP: compare our phase 2 load-block list against what the original
  MMB would have produced -- count, order, and which are above 128K.  If
  the original put its high blocks at odd ordinals the invariant holds and
  our tape build is the defect; if it could not have, FCMINSSL has a
  latent bug that flight loads happened never to trip, which is worth
  writing up on its own.
- TOOL KEPT: YAGPC_NIAPROBE=<hexaddr> dumps R0-R7 plus FCMNEXTS/FCMCURRS
  every time that address is ABOUT TO EXECUTE.  Unlike --break it does not
  stop, so it gives one line per VISIT -- which is what distinguishes
  "reached once" from "reached per load block" and is what cracked this.
  The getenv is cached; with the variable unset the run is unchanged and
  silent, verified.
- METHOD NOTE: the first version of this probe went into gpcops.c, beside
  its ap101_exec1() call, and NEVER FIRED -- that is the GpcOps embedding
  path, and the CLI runs run.c's batchrunner_step().  ap101_exec1() in
  ap101.c is the one chokepoint BOTH go through.  I nearly read the empty
  output as "the sector test is never executed", which would have been a
  confident wrong conclusion; what saved it was scanning the image for the
  instruction's own object code and finding it exactly where the address
  arithmetic said, so the probe had to be wrong rather than the address.

### [2026-08-27] Target: [problems.md]
- CORRECTION, USER-PROMPTED, AND IT IS THE FOURTH TIME I HAVE MISREPORTED
  THE #BU@ FIXTURES.  I wrote that a forced-rebuild A/B showed BOTH
  behaviours giving 74099/74699 with ZERO #BU@ failures.  BOTH NUMBERS ARE
  WRONG.  Measured 2026-08-27 with the control verified FUNCTIONALLY this
  time rather than by trusting a rebuild:
      dereference (in tree)   300 #BU@ fail   73799/74699   wordsTaken 98,820
      direct      (gpc's)     300 #BU@ fail   73799/74699   wordsTaken 28,164
  The 98,820 -> 28,164 swing PROVES the binary changed, which is the check
  that was missing every previous time.  #MOUT@ and #MIN@ also fail 300
  each, in both arms.
- THE CONCLUSION STANDS, THE NUMBERS DID NOT.  The fixtures encode a THIRD
  behaviour -- NIA = a with no bus offset at all -- that neither yaGPC2 nor
  gpc produces, so they cannot arbitrate.  That was the right reading; I
  simply attached invented figures to it.
- AND THE STATE IS NOT WHAT THE USER REMEMBERED, so this is worth writing
  plainly.  The #BU@ dereference WAS reverted, twice, but it was then
  RESTORED and that is what is in the tree.  Sequence: made it dereference
  -> user checked the POO, reverted to direct -> invented BCE opcode 0,
  user killed it ("0x0000 is ADD R0,0(R0)") -> USER observed that the
  +2*BCE# may itself be the indirection and asked how to find the
  instruction in the source -> that lookup found FIOBBM, `DC 2F'0'` with
  the same -36 bias, written at run time by FIOMGDSP.asm:750 under a header
  calling it "MM BRANCH ADDRESS TABLE" -> dereference restored on that
  evidence.  The flight software is the basis, not either emulator.
- GPC'S AGREEMENT IS NOT EVIDENCE.  gpc's exec is
  `v1 = v.a + 2*t.curPE; t.setNIA(v1)` -- direct -- but yaGPC2 was PORTED
  from gpc, so agreement is inheritance.  Same for the fullword alignment
  mask: gpc has `ea = ea & 0xfffe  # mask off bit 15 for fullwords` in both
  of its EA paths, identical shift and all, which is why `git log -S` put
  ours in the initial commit uncited.  A gpc-vs-yaGPC2 run cannot test
  either question.
- AND GPC CANNOT REACH THE CURRENT DEFECT AT ALL: being direct, it spins on
  the branch-table entry and collects 28,164 of 107,012 words, so it never
  loads phase 2, never transfers control, and never enters FCMMOVE.
- CODE COMMENT FIXED: exec_BU_at said the 300 fixtures "fail with this",
  implying they pass without it.  They fail either way, and the comment now
  says so with the measurement and the date.
- LESSON, AND IT IS THE SAME ONE AS THE FIRST THREE TIMES: verify a control
  by a FUNCTIONAL difference the change must produce, not by rebuilding and
  trusting the build.  wordsTaken was available as that check the whole
  time.

### [2026-08-27] Target: [problems.md]
- WHERE gpc AND yaGPC2 DIVERGE, MEASURED RATHER THAN REASONED.  Question
  was: with GPCIPL+SSL already in memory and the switch going STBY -> RUN,
  at what point do the two differ?  ANSWER: AT EXACTLY ONE INSTRUCTION, and
  it is the only `#BU@` the whole IPL executes.  New YAGPC_BUATTRACE:
      BU@ #1 bce=18 table=072cc entry->072f2 (gpc would go to 072cc)
  Total executions in a whole boot: 1.
- BEFORE IT, NOTHING DIFFERS -- memory test, REALEXEC's dispatcher, the
  display IPL, the DK-bus traffic all run identically.  The divergence is
  the SSL's MMU read BCE program reaching its last instruction,
  `#BU@ FCMBCEBT` on BCE 18.
      yaGPC2  fetches [072cc] = 072f2 = FCMIBLK1, the receive sequence the
              SSL wrote into its own work area, and collects the blocks
      gpc     branches to 072cc itself, which holds the constant 0000 72F2,
              decodes 0000 as an unknown BCE opcode, never advances its PC,
              and spins while the commanded transfer streams past
  wordsTaken 98,820 vs 28,164 of 107,012.  The CPU side keeps running in
  both -- the BCE is a separate processor -- so gpc does not crash, the
  load just never completes.  Which is exactly the old "same infinite loop,
  same address, identical iteration counts" observation.
- SCOPE: `#BU@` appears at 57 non-comment sites in OI340600, but ALL the
  MLIB80 ones (FIOMFBCE, FIOHFBCE, BTBCEGEN) are PASS code.  In the IPL
  only SSSRC/FCMINBCE.asm:82 is reachable, which is why one execution
  covers the whole boot -- and why this never showed up before the SSL
  started running.
- A FOURTH INDEPENDENT WITNESS FOR THE DEREFERENCE, found while scoping
  that: MLIB80/BTBCEGEN.asm:564 comments its own `#BU@ FIOBTFLX` as
  "INDIRECT BRANCH".  That is the flight software naming the semantics
  outright, and it does not depend on the FIOBBM chain at all.  The four
  are now: FIOBBM declared DC 2F'0'; FIOMGDSP storing addresses into it
  ("STORE ADDRESS IN BCE ENTRY"); BTBCEGEN's "INDIRECT BRANCH"; and
  FCMBCEBT's DC A(FCMIBLK1) pointing at DS 10F scratch.
- STATED PLAINLY BECAUSE IT WAS ASKED: THIS IS NOT A TOLERATED DIFFERENCE.
  One of the two is wrong.  We claim gpc is, on the four witnesses above
  plus the functional result; against us stands the POO's prose, which
  reads as direct, and 300 fixtures that encode a THIRD behaviour neither
  implementation produces.  Not airtight from the manual -- the flight
  software is what carries it.
- YAGPC_BUATTRACE KEPT, printing BOTH candidate targets per execution.
  This decision has been misreported four times; a switch that shows the
  divergence in one line is worth its keep.

### [2026-08-27] Target: [problems.md]
- CORRECTION TO THE DIVERGENCE ANSWER, user-prompted and right: the
  #BU@ divergence is GATED BEHIND THE SSL CHECKSUM, so the previous
  statement carried an unstated precondition.  Measured both ways:
      UNSTAMPED tape (SSLENGTH = 0)   0 #BU@ executions, wordsTaken 28,162
      STAMPED tape                    1 #BU@ execution,  wordsTaken 98,820
- SO WITH THE SSL IMAGE AS WE ORIGINALLY BUILT IT, gpc AND yaGPC2 DO NOT
  DIVERGE AT ALL.  Both hang identically inside SSLCHECK's checksum loop,
  long before any BCE program is started.  The divergence only becomes
  REACHABLE once SSLENGTH/SSLCKSUM are stamped -- which is what lets SSL70
  run, FCMINSSL be entered, the receive sequence be written into FCMIBLK1,
  the BCE PC be loaded and the MSC started.  Correct ordering:
      SSLCHECK -> SSL70 -> FCMINSSL -> build FCMIBLK1 -> start BCE
        -> BCE 18 runs FCMBCMMR -> #BU@ FCMBCEBT   <- divergence
- ONE PRECISION THAT CUTS THE OTHER WAY: the branch-table ENTRY is STATIC.
  FCMBCEBT assembles as DC A(FCMIBLK1), so the dereference yields 0x72F2
  whether or not the work area has been built.  What the dynamic build
  supplies is the CODE AT that address, not the address.  So #BU@ does not
  need the work area to RESOLVE, only to have somewhere useful to land.
- AND THIS IS WHY THE #BU@ GAP SURVIVED: it sat unreachable behind the
  checksum defect, so NO #BU@ HAD EVER EXECUTED in this project until this
  session.  It is also the honest reason the old "same infinite loop, same
  address, identical iteration counts" gpc-vs-yaGPC2 comparison found
  nothing -- the two were agreeing UPSTREAM of the only instruction at
  which they differ.  A comparison that stops short of the divergence
  cannot see it, which is a sharper version of the section-8 lesson than
  "two emulators agreeing proves nothing about their shared input".

### [2026-08-27] Target: [problems.md]
- #BU@ SEMANTICS, STATED EXACTLY (asked, and the loose earlier phrasing
  deserved it): compute a + 2*BCE#, fetch the FULLWORD there, mask to 18
  bits, load it into the BCE's PROGRAM COUNTER.  A branch, no increment.
  For BCE 18: 0x72A8 + 36 = 0x72CC, fullword 0x000072F2, PC = 0x72F2 =
  FCMIBLK1, where the BCE then runs the receive sequence the SSL built.
  `DC A(x)` assembles to a FULLWORD -- the original listing shows
  `00310 00000336` against `00314 0336` for the Y-con -- so the entry is
  0000 72F2 as two halfwords, and that leading 0000 is exactly what gpc
  executes and cannot decode when it branches TO the entry.
- AND CHECKING THAT TURNED UP AN INCONSISTENCY IN THE @ FAMILY, ours:
      #BU@    fetches a FULLWORD  -> branch target
      #MIN@   fetches a HALFWORD  -> count
      #MOUT@  fetches a HALFWORD  -> count
      #LBR@   fetches NOTHING     -> BASE = the table entry's own address
- THE BIAS SAYS THEY ARE ALL FULLWORD TABLES.  `EQU *-36` is -2*18, i.e.
  TWO HALFWORDS -- ONE FULLWORD -- PER BCE, and FCMBCEBT has exactly two
  entries, buses 18 and 19.  Every one of these tables is an array of A()
  fullwords indexed by 2*BCE#.
- AND FCMBCEST IS THE SAME ADDRESS AS FCMBCEBT.  Original listing:
      1169: 00002EC  FCMBCEST EQU *-36   READ STATUS BASE REGISTER TABLE
      1172: 00002EC  FCMBCEBT EQU *-36   MMU 1/2 BRANCH TABLE
  Both 0x2EC, SHARING the same two DC A(FCMIBLK1) entries, and FCMINBCE.asm
  uses both -- `#LBR@ FCMBCEST` at line 67 and `#BU@ FCMBCEBT` at line 82.
  A table labelled "BASE REGISTER TABLE" holding address constants means
  #LBR@ should load BASE FROM the fullword (0x72F2), not from the entry's
  address (0x72CC).  Ours is 38 halfwords off.
- WHY IT HAS NOT BITTEN: the SSL's dynamically built receive sequence sets
  its own base with a plain #LBR (the FCMMLBR EQU X'F200' skeleton OR'd
  with a computed load-block address), so FCMINBCE's initial #LBR@ value is
  overwritten before any data uses it.  Luck, not correctness.
- NOT CHANGED, DELIBERATELY.  Three changes have been reverted this session
  for being made on plausibility, and #LBR@'s fixtures currently PASS --
  weak evidence in a suite already proven to encode a third behaviour for
  #BU@, but not nothing.  What would settle it: find a #LBR@ site whose
  table entries are known values and check which reading the program needs,
  the way FIOBBM settled #BU@.  FIOMFBCE/FIOHFBCE/BTBCEGEN are full of @
  forms and are the place to look.
- ALSO WORTH NOTING: FCMRCSEQ at 0x314 holds the SAME two addresses as
  Y-cons -- 72F2 7306, one halfword each -- while FCMBCEBT holds them as
  fullwords.  Same addresses, two widths, chosen by which processor reads
  them: the CPU indexes the Y table, the BCE fetches the A table.

### [2026-08-27] Target: [problems.md]
- WHAT THE RECEIVE SEQUENCE AT FCMIBLK1 DOES WHEN IT ENDS: IT BRANCHES.  It
  never falls through into the zeros after it.  Asked, and answered from
  both the source and a live dump at the moment #BU@ fires:
      FCMIBLK1 @072f2  f200 051e  f300 0157  c250 5022  f000 7306
      FCMIBLK2 @07306  f200 0676  f300 0000  f300 27ff  f200 2e76
                       f300 002f  c4a0 5008  0800 0000
  decoding as
      #LBR 051e / #RDLI 344 / #DLYI 592 / #SST +22 / #BU FCMIBLK2
      #LBR 0676 / #RDLI 1 / #RDLI 10240 / #LBR 2e76 / #RDLI 48
        / #DLYI 1184 / #SST +08 / #WAT
- THE TWO TERMINATORS ARE BOTH IN THE SOURCE.  FCMINSSL.asm:752
  `OHI R5,FCMMBU` (FCMMBU EQU X'F000', UNCONDITIONAL BRANCH) OR'd with the
  NEXT sequence address ends a sequence that has a successor; :727 and :760
  `LHI R4,FCMMWAT` (X'0800') end the LAST one.  So FCMIBLK1 and FCMIBLK2
  chain to each other, alternately, until the final load block waits.  The
  unused tail of each DS 10F is never executed.
- AND THE PACKING EXPLAINS A SOURCE ODDITY.  `c250 5022` is TWO
  single-halfword instructions in one fullword -- #DLYI (11000iiiiiiiiiii,
  FCMMDLYI EQU X'C000') and #SST (0101mddddddddddd, FCMMSST EQU X'5000') --
  which is why FCMINSSL writes the fullword with `ST R4,0(R2)` and then
  patches only the second halfword with `STH R4,1(R2)`.  I had read that
  STH as suspicious; it is deliberate.
- CORROBORATION THAT THIS IS REAL AND NOT A DECODE ARTIFACT: the #LBR
  operands are 0x051E and 0x0676, phase 2's LB1 and LB2 START ADDRESSES,
  and FCMIBLK2 splits LB2 (0x0676..0x2ea5) as 1 + 10240 words, reloads base
  to 0x2e76, then 48 more -- a block-boundary split.  0x051E is the same
  address the corrupting FCMMOVE stopped one halfword below.
- The #DLYI counts are the FCMBOOT mechanism again: delay over a block's
  unread tail plus half the inter-block gap, per FCMSSLBS's own
  `LHI R4,639  GET MM BLOCK SIZE MINUS ONE PLUS 128`.
- SO #BU@ IS A ONE-TIME ENTRY POINT, NOT PART OF THE LOOP.  It fires once
  to get from the static FCMBCMMR program into the dynamic chain; the chain
  then perpetuates itself through PLAIN #BU between the two buffers.  That
  is why exactly ONE #BU@ executes in a whole boot despite 21 load blocks
  and 209 blocks read -- a fact that looked odd until the chain was dumped.
- OPEN, AND FLAGGED RATHER THAN GUESSED: how the remaining load blocks are
  driven after that first #WAT -- whether the CPU reloads the BCE PC per
  group (FCMIOPPC EQU X'A201', BCE 18 form X'A321') or rewrites the buffers
  under a still-running chain.  The #WAT we captured is the terminator AS
  OF THAT INSTANT, since FCMINSSL writes #WAT only when R7 = 1, so a given
  buffer's last word changes as buffers are rebuilt.  Countable with
  YAGPC_DISPTRACE (LOADMSCBUSY) against the 8 mass-memory commands.

### [2026-08-27] Target: [problems.md]
- WHERE EXECUTION GOES AFTER #WAT: NOWHERE.  The BCE enters the WAIT STATE
  and stops.  BCE POO section 2.2 (IBM-6246556A part 3) states it and also
  states the PC behaviour our code already had:
      "a BCE's Program Counter need not always be set before the MSC sets
       the BCE to busy, since the BCE Wait instruction (#WAT) when
       executed, leaves the PC pointing to the next sequential
       instruction.  This next instruction may be programmed as a simple
       branch to the beginning of the next BCE program segment.  In this
       case, the MSC need only execute an SIO instruction to restart the
       BCE at the next segment."
  Also: "While a BCE is in the Wait state, the CPU may perform PCI/O
  activity without disturbing the BCE"; "The Busy state may be entered
  only from the Wait state"; and "The CPU cannot, however, directly set a
  BCE's Busy/Wait bit" -- only the MSC's SIO.
- SO exec_WAT WAS ALREADY RIGHT AND IS NOW CITED.  Clearing regBusyWait is
  what stops execution (iop.c refuses to step a processor whose bit is
  clear, verified), and iop_incr_nia(t,1) is the DEFINED behaviour rather
  than bookkeeping -- it is precisely what makes the restart idiom work.
- AND THE SSL DOES NOT USE THAT IDIOM, which answers the question left open
  in the previous entry.  The halfword after its #WAT is 0000, not a
  branch, so the PC must be reloaded per program.  MEASURED with
  YAGPC_PCTRACE -- BCE 18's PC is loaded five times in a whole boot:
      30240  t= 2.11s   FCMBOOT's own BCE program (sector 6)
      3024c  t= 2.31s   FCMBOOT again
      014d4  t= 4.30s   GPCIPL's all-BCE sweep
      07362  t=18.46s   FCMINBCE          <- the SSL
      0736c  t=18.62s   FCMINBCE+10
  0x7362 is FCMINBCE's start in our link map (18 halfwords long), and the
  two SSL-era loads at +0 and +10 match FCMBCEAD's own pair,
  DC A(FCMBCMMR) "MMU 1/2 READ BCE PROGRAM PC" and DC A(FCMINMMP)
  "MMU 1/2 POSITION TAPE BCE PROGRAM PC".
- THE WHOLE CHAIN IS NOW ACCOUNTED FOR END TO END: MSC SIO starts BCE 18 at
  FCMINBCE -> #LBR@ FCMBCEST, #CMD, ... -> #BU@ FCMBCEBT dereferences into
  FCMIBLK1 -> the dynamically built sequence reads its load block, #SST's
  its status, and #BU's to FCMIBLK2 -> ... -> the last one #WAT's, parking
  the BCE with its PC one past the #WAT while the CPU polls FCMINSST.

### [2026-08-27] Target: [problems.md]
- "WHAT IF YOU FIXED gpc's #BU@ SO THE COMPARISON COULD RUN?"  ASSESSED,
  not asserted.  IT WOULD BUY EXACTLY ONE INSTRUCTION.  The patch is one
  line, but the next thing the receive sequence executes is #DLYI 592, and
  gpc has:
      '#DLYI' e:(t,v)-> # Delay immediate: count*16.5us (no-op in simulator)
                        t.incrNIA(1)
      '#DLY'  e:(t,v)-> # Delay from memory: ... (no-op in simulator)
                        t.incrNIA(1)
  Both explicit no-ops.  That is the exact defect that broke FCMBOOT's
  phase-10 load until 14a7b7581: the SSL skips each partial block's UNREAD
  TAIL BY DELAYING OVER IT, so with a no-op delay nothing is skipped and
  every later load block lands hundreds of halfwords early.
- AND THAT FIX WAS TWO-SIDED -- iop_bce_delay discarding bus data during
  the delay, AND mmumodel.c pacing words onto the bus with real block gaps.
  gpc has NEITHER, and also lacks the MIA-latch ordering fix (82fb09d3b)
  and the unread-transfer-tail fix (629694ebf).
- IT ALSO CANNOT RUN THE SCENARIO DETERMINISTICALLY.  `gpc run` has no
  --mmu-model: its option list is max-steps/break/watch/output/
  dump-interval/trace/verbose/interactive/watch-log and nothing else.  Mass
  memory is gpc/dev/mmu.coffee, a SEPARATE DEVICE PROCESS on the multicast
  bus -- the networked vehicle this session's harness exists to avoid.
- SO THE COST IS PORTING THE WHOLE IOP/BUS BODY OF WORK INTO IT, after
  which it is not an independent implementation but yaGPC2 transcribed into
  CoffeeScript, and its agreement carries no information.
- AND IT STILL COULD NOT ANSWER THE LIVE QUESTION, which is why phase 2's
  above-128K load blocks sit at ordinals 20 and 21.  That is a property of
  the TAPE; both emulators merely read it.
- THE BETTER INDEPENDENT CHECK, offered: parse phase 2's load-block
  descriptors straight out of the .mmv OFFLINE and confirm the 21 blocks
  and their sectors with NO emulator in the loop.  That is independent in a
  way gpc -- a codebase we were ported FROM -- can never be.  Not done yet;
  awaiting the user.

### [2026-08-27] Target: [problems.md]
- DECISION, ASKED FOR AND RECORDED: DO NOT BUILD A gpc-vs-yaGPC2
  HEAD-TO-HEAD FOR THE SSL FAILURE.  The user's principle is right --
  forcing two supposedly-identical programs to contend is a powerful
  localizer -- and they were right that the discretes are NOT a blocker
  here (nothing in gpc writes regDiscreteInA/B at all, so `gpc run` never
  touches that bus; forcing them is two set32 calls, and is REQUIRED, since
  zero means DEU_ID 0 = no display unit).
- THE DECISIVE REASON IS NOT COST, IT IS THAT I WOULD BE WRITING THE
  ORACLE.  To reach the failure gpc needs #DLYI/#DLY implemented WITH
  bus-data discard and a progressive bus -- the exact behaviours under
  test.  Implement them as yaGPC2 does and agreement proves nothing;
  implement them differently and disagreement only shows I wrote two
  different things.  Differential testing earns its power from
  INDEPENDENCE, and yaGPC2 is a PORT of gpc: their disagreements are
  precisely our changelog.  That is also why the historical comparison sat
  in the same loop with identical iteration counts for days.
- AND THERE IS NO INDEPENDENT SECOND IMPLEMENTATION AVAILABLE FOR THIS
  CLASS OF QUESTION.  yaHALMAT2, which genuinely is independent and is the
  real bug-finder against yaGPC2 elsewhere, executes HALMAT and not AP-101S
  machine code, so it cannot run GPCIPL at all.  gpc is the only sibling
  that can, and it is the one we were ported from.  Hence the primary
  documents have had to be the oracle -- and they have worked.
- THE LEDGER SUPPORTS THAT.  Everything decisive this session came from
  PRIMARY SOURCES or TARGETED INSTRUMENTATION: POO Figure 2-8 (the mask),
  the OI301700 as-received listing (the struct layout, byte for byte),
  FIOBBM and BTBCEGEN's "INDIRECT BRANCH" (#BU@), the 0x710b probe (the 21
  sectors), the FCMIBLK dump (the chain), the BCE POO (#WAT).  Every wrong
  turn -- three reverted changes, four bad #BU@ fixture reports -- came
  from trusting DERIVED artifacts: fixtures, stale builds, my own notes.
- AND THE FAILURE IS LOCALIZED, not stalled: from "wild branch to 0xc2d9"
  to "FCMINSSL requires every above-128K load block at an ODD ordinal, and
  ours is at 20".  What remains is checking one list.
- PHASE 2'S COMPLETE LOAD-BLOCK LIST, already in hand from the 0x710b probe
  (R5 holds addr<<1 there; the source does SRL R5,1 immediately after):
      1 051e/0   2 0676/0   3 2ea6/0   4 3332/0   5 0000/1   6 009a/1
      7 011a/1   8 0000/2   9 01ae/2  10 0000/3  11 1a30/3  12 499c/3
     13 6a76/3  14 705e/3  15 0000/4  16 0000/5  17 0254/5  18 0000/6
     19 0000/7  20 0000/8  21 0000/9
  Blocks 1 and 2 are 0x051E and 0x0676 -- EXACTLY the #LBR operands in the
  dumped receive sequences, an independent cross-check.  Ascending sector
  order, each new sector starting at 0x0000.  NINETEEN blocks precede
  sector 8, which is the entire ordinal-parity problem.
- SO THE NEXT WORK IS A TAPE-BUILD QUESTION, not emulator archaeology:
  does our mmubuild emit the load-block list MMB would have?  Answerable
  against CON80 and the phase manifest with NO emulator on either side.
- CONDITION FOR REVERSING THIS: if the tape-build line runs dry AND the
  next question turns out to be about EMULATOR BEHAVIOUR rather than the
  tape, differential testing becomes the right instrument and is worth
  building -- but on a case where the two could genuinely disagree, not one
  where I would have supplied both answers.

### [2026-08-27] Target: [problems.md]
- ASKED TO FIND OUT WHETHER THE TAPE'S LOAD-BLOCK LIST IS DEFICIENT AND FIX
  IT.  FOUND OUT.  NOTHING FIXED, BECAUSE THE THEORY IT RESTED ON IS WRONG,
  AND I DISPROVED IT MYSELF.
- READ THE ACTUAL TABLE rather than inferring it.  FCMBOOT's phase table
  lives at FCMPTAD1 = halfword 894 of BOOT-stamped.fcm (a flat big-endian
  halfword image, 32512 hw).  Four 3-hw phase descriptors:
      phase 10  disp=12  nLBs=5   mm=2260
      phase  2  disp=27  nLBs=24  mm=2300
      phase 13  disp=99  nLBs=2   mm=1b00
      phase  3  disp=105 nLBs=10  mm=1bc0
  Phase 2's 24 descriptors (addr / P / sector / length):
       1 0051e P1 s0    344     13 0ea76 P1 s3   1512
       2 00676 P0 s0  10288     14 0f05e P1 s3   1538
       3 02ea6 P1 s0   1164     15 08000 P1 s4     34
       4 03332 P1 s0      4     16 08000 P0 s5    596
       5 08000 P0 s1    154     17 08254 P1 s5    118
       6 0809a P1 s1    128     18 08000 P0 s6    802
       7 0811a P0 s1  11122     19 08000 P0 s7    464
       8 08000 P1 s2    430     20 08000 P1 s8   8532
       9 081ae P1 s2   5112     21 08000 P0 s9    664
      10 08000 P1 s3   6704     22 08298 P1 s9   1524
      11 09a30 P1 s3  12140     23 08000 P1 s10    16
      12 0c99c P0 s3   8410     24 08010 P0 s10     4
  Total 71804 hw.  The 21 sector tests the probe saw are blocks 1-21; the
  boot dies during block 20's move, so 22-24 are never reached.  Sector
  addresses carry the 0x8000 sector marker, so 08000 is offset 0.
- THE ORDINAL-PARITY INVARIANT IS DEAD.  There are FIVE above-128K blocks
  (#20-24, sectors 8,9,9,10,10), and HIMEM blocks are CONTIGUOUS AT THE END
  by construction.  Consecutive blocks alternate structs, so THREE OF THE
  FIVE necessarily land on FCMCTXT2.  No arrangement avoids it -- merging
  every mergeable pair still leaves two.  So FCMINSSL cannot be relying on
  ordinal parity, and my "every above-128K LB must sit at an odd ordinal"
  claim is WRONG.  I proposed it, tested it, and it failed.
- AND THE ORIGINAL BUILD MATCHES US EXACTLY WHERE IT CAN BE CHECKED.  From
  OI301700's as-received listing, object code and all:
      0037C  FCMCTXT1 DS 7H
      00383  FCMCTXT2 DS 7H            <- ODD offset in the real build
      003A0  037C  DC Y(FCMCTXT1)
      003A1  0383  DC Y(FCMCTXT2)      <- the real build's own pointer
      002E7  1B00  L R3,TFCMTGTA       <- SRS, base R0, disp 0
  1B00 decodes as 00011|011|000000|00 under our own L pattern.  So the
  instruction, the struct offsets and the pointer table are all
  byte-identical to ours.  The tape's list is NOT deficient in the way I
  predicted and I am not "fixing" it on a disproved theory.
- ONE GENUINE CANDIDATE DEFICIENCY, FLAGGED NOT TOUCHED, and it cannot
  cause this failure: three adjacent same-protection pairs did not merge
  although mmbstamp's own documented rule says adjacent groups merge while
  total <= 16384 hw and protection agrees --
      #3/#4   0x2ea6+1164 = 0x3332, both P=1, 1168 total
      #8/#9   0x8000+430  = 0x81ae, both P=1, 5542 total
      #13/#14 0xea76+1512 = 0xf05e, both P=1, 3050 total
  #10/#11 is legitimately blocked by the 16384 cap (6704+12140=18844).
  Whether the other three are right turns on the deck_standalone and bank
  rules, unverified.  mmbstamp is Don's tool in his repo -- read-only.
- SO THE QUESTION IS SHARPER AND WORSE: FCMINSSL DEMONSTRABLY REQUIRES BOTH
  STRUCTS TO WORK.  Either the AP-101S does NOT mask bit 15 for this case,
  contradicting POO Figure 2-8 as I read it, or the real MMB emitted far
  fewer HIMEM load blocks than our 24-block reconstruction.  Those are the
  two live branches now; both are testable and neither is in cpu.c.
- TERMINOLOGY WARNING FOR THE WRITE-UP, because it confused the user and
  the confusion was mine: "ODD" IS BEING USED FOR TWO UNRELATED THINGS.
    (a) FCMCTXT2 sits at an ODD ADDRESS, 0x733F, because FCMCTXT1 is
        DS 7H and 0x7338 + 7 is odd.  This is the only odd address in the
        story and it is a property of the SOURCE.
    (b) Load blocks have ODD or EVEN ORDINALS (position 1..24 in the
        list), and block N uses struct (N-1) mod 2 -- so an EVEN-ordinal
        block draws FCMCTXT2, the odd-ADDRESSED one.
  EVERY LOAD BLOCK ADDRESS IS EVEN -- all 24 verified: 0051e 00676 02ea6
  03332 08000 0809a 0811a 08000 081ae 08000 09a30 0c99c 0ea76 0f05e 08000
  08000 08254 08000 08000 08000 08000 08298 08000 08010.  Where a block's
  DATA lands has nothing to do with the bug.  Say "ordinal" and "address"
  explicitly and never just "odd".
- AND THE ONE-LINE STATEMENT OF THE BUG: FCMMOVE reads TFCMTGTA+TFCMTGTS as
  a FULLWORD (they are the address+sector pair LXAR splits), a fullword
  load ignores address bit 15, so from FCMCTXT2 it reads
  [FCMCTXT1's last halfword, FCMCTXT2's first] instead -- zeros in our run
  -- and the move gets dest=0 count=4096 src=0 and overwrites the PASS
  image just loaded.  Only above-128K blocks call FCMMOVE (they cannot be
  DMA'd directly and are staged through a low buffer), which is blocks
  20-24, struct indices 1,0,1,0,1 -- THREE OF FIVE on the bad struct.

### [2026-08-27] Target: [problems.md]
- WHAT FCMMOVE ACTUALLY SPANS -- asked, and read out of the source rather
  than assumed.  IT TAKES ONE CONTEXT STRUCT.  Its documented input is
  "R0 : ADDRESS OF CURRENT BCE_CONTEXT_STRUCT", and the body is
      L    R3,TFCMTGTA / LXAR R3,R3 / IHL R3,TFCMCNT
      LA   R1,FCMBFZCN / LH R4,TFCMSRC / L R5,0(R4,R1) / MVH R3,R5
      IF (TH,TFCMSEQF,,NZ)      <- load block uses BOTH TEMP BUFFERS
        wait / AH R3,TFCMCNT / IHL R3,TFCMSCNT
        XHI R4,X'0001' / L R5,0(R4,R1) / MVH R3,R5
  So one call may issue TWO MVHs -- but the pair it spans is the two 8K
  TEMP BUFFERS (FCMB1ZCN/FCMB2ZCN, FIOMUWB2 and +8192), NOT the two context
  structs.
- THERE ARE THREE SEPARATE ALTERNATING PAIRS IN THIS CODE and conflating
  them is the trap:
      FCMCTXT1/FCMCTXT2   context structs, per load block (FCMNEXTS/CURRS)
      FCMIBLK1/FCMIBLK2   BCE receive-sequence CODE areas (FCMRSADD)
      the two 8K buffers  data staging, indexed by TFCMSRC/FCMNEXTB
  FCMMOVE spans the third.  It is called once per above-128K load block,
  with whichever context struct that block used.
- MEASURED: FCMMOVE IS ENTERED EXACTLY ONCE in our run, R0=733f0000,
  NEXTS=0000 CURRS=0001.  The ALTERNATION itself is still INFERENCE from
  the source, not observation -- the boot dies inside that first call, so a
  second call with FCMCTXT1 has never been seen.  Stated plainly because it
  was challenged and the challenge was fair.
- CORRECTION TO MYSELF, TWICE OVER.  I claimed the old "removing the mask
  breaks the boot" evidence was worthless because it was taken on the
  UNSTAMPED tape, where phase 2 never loaded anyway.  The REASONING was
  right -- that measurement could not have shown what I claimed -- but the
  RESULT REPRODUCES on the stamped tape, so the conclusion stands:
      mask ON    FCMMOVE calls 1   209 blocks   phase 2 loads, dies on the
                                                 odd struct
      mask OFF   FCMMOVE calls 0    55 blocks   breaks in GPCIPL's memory
                                                 test, before the SSL runs
  FCMMOVE CALL COUNT is the right discriminator and is what makes this A/B
  trustworthy where the earlier one was not.
- SO THE CONFLICT IS NOW THREE-CORNERED AND FULLY MEASURED:
    * POO Figure 2-8 says SRS fullword addressing ignores address bit 15.
    * GPCIPL's memory test REQUIRES that -- removing the mask stops the
      boot before the SSL ever runs.
    * FCMINSSL requires the opposite for FCMCTXT2, and cannot avoid it:
      five above-128K load blocks, contiguous at the end of the list,
      alternating structs, so three necessarily land on the odd one.
  Two of the three are confirmed against primary sources.  The remaining
  possibilities are (b) the real MMB emitted far fewer HIMEM load blocks,
  or (c) FCMINSSL has a latent defect real load profiles never exercised.
  (a) -- that the struct is even in the real build -- is DISPROVED by the
  original listing's own DC Y(FCMCTXT2) = 0383.

### [2026-08-27] Target: [problems.md]
- IS THE MISALIGNED READ ACTUALLY HARMFUL?  User's challenge: it still
  covers the struct, just with an extra halfword, so perhaps harmless.
  MEASURED AT FCMMOVE ENTRY, both structs dumped:
      FCMCTXT1 @07338: 0000 0009 0000 0298 ffff 0000 0000
      FCMCTXT2 @0733f: 0000 0008 0000 1000 ffff ffff 1154
                       TGTA TGTS SRC  CNT  UPMF SEQF SCNT
      L at 733f (intended) -> 00000008 = [TGTA=0000][TGTS=0008]
      L at 733e (masked)   -> 00000000 = [0000][0000]
- HALF RIGHT, AND NOT THE IMPORTANT HALF.  The extra halfword pulled in at
  the FRONT (FCMCTXT1's SCNT = 0000) IS harmless.  The damage is at the
  BACK: the pair is SHIFTED BY ONE, so TFCMTGTS = 0008 falls off the end
  and is never read.  L reads exactly TWO halfwords and needs THESE two --
  TGTA and TGTS are the address-constant pair LXAR splits into an address
  plus a SECTOR EXTENSION.  Shifted, LXAR gets 0x00000000 instead of
  0x00000008: address 0 sector 0 instead of address 0 SECTOR 8, so the
  destination is 0x00000 instead of 0x40000 and the move lands 256K
  halfwords low, on the PASS image just loaded.
- AND THE REST OF THE STRUCT CORROBORATES THE FIELD READING EXACTLY:
  CNT = 0x1000 = 4096, which is the observed MVH count; SRC = 0 selects the
  primary buffer (FIOMUWB2); SEQF = ffff so the two-buffer path runs with
  SCNT = 0x1154 = 4436 -- and 4096 + 4436 = 8532, PRECISELY LOAD BLOCK
  #20's LENGTH.  Every field checks out; only the sector is lost.
- SO THE EFFECT IS UNAMBIGUOUSLY A DEFECT.  What remains open is whose:
  the code is asking for a fullword at an odd address and something must
  give.
- WHICH ACCESSES ARE MASKED, since this keeps getting asked in
  source-vs-destination terms and that is the WRONG AXIS.  The axis is
  FULLWORD OPERAND vs HALFWORD OPERAND:
      L R3,TFCMTGTA   fullword operand, base+displacement (SRS) -> MASKED
      MVH R3,R5       RR form, both addresses taken straight from
                      registers, moves HALFWORDS one at a time via
                      membus_get16/cpu_store_hw, never calls cpu_g_ea
                      -> NOT MASKED, either end may legally be odd
      L R5,0(R4,R1)   fullword but INDEXED, so the extended/RS path, which
                      carries no mask here; FCMBFZCN 0x735E with TFCMSRC
                      scaled by operand width gives 0x735E and 0x7360 for
                      the two buffers -- both even, both right, and a
                      confirmation that the index scaling matches POO
                      Figure 2-13
  So NOTHING about FCMMOVE's actual MOVE is constrained; the ONLY masked
  access in the routine is the struct read.
- AND THAT IS THE DESIGN, not an accident: the flight software DEPENDS on
  halfword moves being unconstrained -- FCMMOVE copies arbitrary lengths to
  arbitrary addresses -- while fullword OPERANDS must be aligned (POO
  section 2, "Fullword operands must be located in main storage on even
  halfword boundaries").  FCMCTXT1/FCMCTXT2 DS 7H is the one place the
  software puts a fullword operand where that rule forbids.

### [2026-08-27] Target: [problems.md]
- THE TRIANGLE IS CLOSED, AND THE DEFECT IS IN THE FLIGHT SOFTWARE.
  Resolving 0x074E -- the thing the earlier handoff said must be resolved
  before touching the mask -- settles it.
- 0x074E IS MEMTST14+5, in MLIB80/STPMEM.asm, the MEMORY UNIQUE ADDRESSING
  TEST.  (0x00B0/0x00B1 are KHCT1HI/KHCT2HI, the PSA clock high halfwords.)
  Symbols from donroute/IPL/IPL.sym.json; the other masked sites resolve to
  MEMTST12+a, MEMTST14+6, MEMTST15+3, MEMTST33+3, MEMTST34+3.
- THAT TEST DELIBERATELY DRIVES ITS POINTER ODD.  It walks a single bit
  through the address (LHI R4,X'8000' / SRL R4,S3 / XR R2,R4), so when the
  bit reaches the LSB the address IS odd, and the code knows it:
      TRB  R2,1        ODD ADDRESS ?
      SHW  ODDFLAG     SET ODD ADDRESS FLAG
      NHI  R2,X'FFFE'  RESET ODD BIT      <- in R2 only, NOT in R1
  R1 keeps the odd address.  Protection is per HALFWORD, which the test
  shows outright by protecting both ends separately afterwards:
      ISPB 2,0(R1)  PROTECT DATA   /  ISPB 2,1(R1)  PROTECT DATA+1
- AND THE DECISIVE PAIRING IS AT MEMTST14:
      ISPB 1,0(R1)   UNPROTECT 1 FULLWORD AT TEST PNTR
      ST   R5,0(R1)  <- 0x074E, the faulting store
      L    R6,0(R1)
      CR   R6,R5     RESULT EQUAL EXPECTED ?
  Our own exec_ISPB already carries the POO rule for the unprotect: "When
  M1 is 001 or 011, THE LOW-ORDER BIT OF THE EA SHOULD BE 0 AND WILL BE
  IGNORED."  That is Figure 2-8's rule stated for a DIFFERENT INSTRUCTION.
  The unprotect and the store can only cover the same halfwords if the
  FULLWORD ST and L ignore the low bit too.  Remove the mask and they
  diverge -- which is exactly why the unmasked run faults right there.
- SO THE MASK IS CONFIRMED TWICE OVER, once by POO Figure 2-8 and once by
  the POO's ISPB rule plus GPCIPL's own dependence on the two agreeing.
  GPCIPL's memory test is NOT our bug and the mask is not removable.
- WHICH LEAVES ONLY CORNER 3.  FCMINSSL's
      FCMCTXT1 DS 7H
      FCMCTXT2 DS 7H
  puts a FULLWORD OPERAND (TFCMTGTA+TFCMTGTS, read by L R3,TFCMTGTA and
  split by LXAR into address + sector) at an ODD halfword address, which
  POO section 2 forbids outright: "Fullword operands must be located in
  main storage on even halfword boundaries."  THIS IS A LATENT DEFECT IN
  THE REAL SHUTTLE FLIGHT SOFTWARE, present identically in OI301700 and
  OI340600, and confirmed in the original build's own listing
  (DC Y(FCMCTXT2) = 0383).
- ITS EFFECT: any above-128K load block whose context lands on FCMCTXT2
  loses TFCMTGTS, so LXAR gets sector 0 and the move goes to 0x00000
  instead of the intended sector.  It cannot trap -- address 0 sector 0 is
  a legal destination -- so on real hardware it would silently write a load
  block to the wrong place.  It survives only if a phase never has two or
  more above-128K load blocks; ours has five.
- NOT YET EXPLAINED, and flagged rather than glossed: the exact faulting
  halfword.  ISPB unprotects 0x00B0 and 0x00B1, so an unmasked fullword
  store at 0x00B1 should span into 0x00B2 and fault THERE, yet the
  measurement reports addr=0x000b1 on PROTVIOL #5.  The mechanism above
  does not depend on which of the pair faults, but the discrepancy is real
  and unresolved.

### [2026-08-27] Target: [problems.md]
- RESOLVED, AND THE FLIGHT SOFTWARE IS EXONERATED.  The user's objection --
  software that flew for decades cannot fail to boot -- was a sound
  reductio and it was right.  My "latent defect in FCMINSSL" conclusion was
  wrong, and the primary source that settles it is a DASS MEMORY DUMP.
- #PFCMGPT, THE SSL'S IN-CORE PHASE TABLE, IS IN THE DUMPS.
  ~/workspace/PFS/mafgen/SSW.fcm (also P9.fcm), halfword 118002, 1093 hw,
  16 four-halfword phase descriptors for phases 3..18: [disp to LBs, number
  of LBs, MM address, NUM_CONT].  The DASS comparison marks it 'ok' but its
  detail says "[955 patched after build]" -- 955 of 1093 halfwords are
  EXCLUDED as post-build patches, i.e. exactly the load-block descriptors,
  so the comparison never validated them.  Reading them directly does.
- AND IT VALIDATES mmbstamp EXACTLY for the IPL phases that appear:
      phase  3   real 10 LBs @ 1bc0    ours 10 LBs @ 1bc0
      phase 10   real  5 LBs @ 2260    ours  5 LBs @ 2260
      phase 13   real  2 LBs @ 1b00    ours  2 LBs @ 1b00
  So the partitioning rules reproduce the real MMB.  (Phase 2 is not in
  this table -- it covers 3..18 -- so it cannot be checked directly.)
- THE DECISIVE COUNT: ACROSS ALL SIXTEEN REAL PHASES THERE ARE EXACTLY TWO
  ABOVE-128K LOAD BLOCKS.
      phase  3   block 10 of 10, LAST, addr 0888c sector  9 len 5654
      phase 13   block  2 of  2, LAST, addr 08010 sector 10 len 2698
  Every other phase -- including ones with 26, 29, 30, 37 and 38 load
  blocks -- has NONE.  Each of the two is ALONE in its phase and is the
  LAST BLOCK of it.
- SO THE INVARIANT FCMINSSL RELIES ON IS: A PHASE HAS AT MOST ONE
  ABOVE-128K LOAD BLOCK, AND IT IS THE LAST ONE.  That is what makes it
  safe, because the LAST block's FCMMOVE is dispatched from a DIFFERENT
  CALL SITE -- the post-loop one at FCMINSSL.asm:782, after
  BCT R7,#@LB45, whose R5 comes from the "IF LAST LB, UNDO NEXT LB SETUP"
  branch (CHI R7,1) that deliberately toggles FCMNEXTS BACK.  Non-last
  blocks use the in-loop call site with CURRS, which is what lands on
  FCMCTXT2, the odd-addressed struct.  The real system never drives the
  in-loop path for upper memory.
- OUR PHASE 2 VIOLATES IT FIVE TIMES: blocks 20-24 of 24 are above 128K,
  sectors 8,9,9,10,10, lengths 8532,664,1524,16,4 = 10740 halfwords of
  upper memory, and FOUR OF THE FIVE ARE NOT LAST.  The real blocks are
  single and large (5654, 2698) at 0888c and 08010; ours are fragments,
  two of them 16 and 4 halfwords, mostly at 08000.  Out of family in every
  respect.
- SO THE DEFICIENCY IS OURS AFTER ALL, in the phase-2 reconstruction -- not
  in the load-block COUNT rule (validated above) but in how much content
  our phase 2 puts in upper memory and how it is split.  THE EMULATOR IS
  CORRECT, the mask is correct, and FCMINSSL is correct under its real
  operating conditions.
- WHAT I GOT WRONG AND WHY IT MATTERS: I concluded "latent defect in the
  flight software" from a chain in which every link was checked against a
  primary source EXCEPT one -- the five-HIMEM-block count, which came from
  our own reconstruction and which I never checked against anything.  I
  even noticed the 16- and 4-halfword blocks looked like artifacts and
  walked past it.  The user's reductio is what forced the check.
- NEXT: find why our phase 2 places 10740 halfwords above 128K when real
  phases place at most one block there.  PHASE02.lib and the CON80 cards
  are the inputs; #PFCMGPT gives a primary-source specification of what
  right looks like for phases 3..18 to calibrate against.

### [2026-08-27] Target: [problems.md]
- WENT LOOKING FOR THE PHASE-2 DEFICIENCY.  FOUND REAL FACTS, AND ALSO
  UNDERCUT MY OWN PREVIOUS CONCLUSION.  Recording both.
- mmbstamp IS VALIDATED IN DETAIL, not just by count.  Our generated phase 3
  descriptors against the SSW dump's #PFCMGPT: SAME COUNT (10), SAME ORDER,
  AND IDENTICAL FLAG HALFWORDS throughout -- 8600 8600 0600 0600 8630 8630
  0650 0660 0670 8690, i.e. sectors 0,0,0,0,3,3,5,6,7,9 in both.  Only
  addresses and three lengths differ, which is the known OI340600 link
  layout difference.  So the partitioning rules reproduce the real MMB and
  are NOT the defect.
- OUR PHASE 2'S UPPER MEMORY IS REAL CONTENT, NOT AN ARTIFACT.  PHASE02.lib
  genuinely holds 8 extents above 128K (sectors 8, 9, 10), so the link put
  them there; mmbstamp only partitions what it is given.  PHASE02's
  sections above 128K are HAL/S runtime (ACOS DACOS EXP LOG SQRT DMOD DSQRT
  ITOC GTBYTE STBYTE ...), application CSECTs ($0DCICYC $0VKISAC ...), the
  annunciator compools, and PCH02TXT patch areas.
- AND SECTOR 9 IS EXACTLY RIGHT.  Against the SSW dump's own CSECT index:
      #PCDTANN  real 048010 645 hw   ours 048010 645
      #PCDZANN  real 048298  68      ours 048298  68
      #PCDKANN  real 0482dc 892      ours 0482dc 892
      #PCDSANN  real 048658 561      ours 048658 561
  Identical addresses AND sizes.  Sector 8 differs (ours is compressed
  lower because our build has fewer CSECTs there -- e.g. ACOS real 0470fc
  vs ours 041aa4, $0DCICYC real 041d96 vs ours 0400bc).
- WHICH UNDERCUTS THE "AT MOST ONE HIMEM LB, ALWAYS LAST" INVARIANT for
  phase 2.  Phase 3's real HIMEM block starts at 04888c -- IMMEDIATELY
  AFTER #PCDSANN ends at 048889 -- and NO phase in 3..18 covers
  048010..048889.  So the annunciators must be loaded by PHASE 2, meaning
  the REAL phase 2 also carried sector-9 upper-memory content and cannot
  have had only one HIMEM load block.
- SO MY PREVIOUS "FLIGHT SOFTWARE EXONERATED" ENTRY IS PREMATURE.  The
  invariant I inferred holds for phases 3..18, which is all #PFCMGPT
  contains; phase 2 is the big IPL load, is different in kind, and is NOT
  in that table, so it was never actually checked.  I generalised from the
  sample I could see to the one case that matters.
- WHAT IS STILL SOLID: the emulator is correct (POO Figure 2-8, the ISPB
  low-bit rule, MEMTST14's dependence on the two agreeing); FCMCTXT2 is at
  an odd address in the real build; mmbstamp partitions faithfully; and our
  phase 2's sector-9 placement matches the original exactly.
- WHAT IS OPEN: how the real phase 2 loaded sector 8/9 upper memory without
  FCMMOVE meeting the odd struct.  Possibilities not yet tested -- the real
  phase 2 had a different HIMEM block COUNT despite identical content
  (sector 8's layout differs, so its block partition would too); or the SSL
  reaches upper memory by some path other than the in-loop FCMMOVE at IPL;
  or FCMNEXTS is not zero-based at the start of a phase load, which I
  verified for OUR run but never for a real one.

### [2026-08-27] Target: [problems.md]
- THE MECHANISM IS PARITY OF THE CUMULATIVE LOAD-BLOCK COUNT, AND OUR PHASE
  2 HAS THE WRONG PARITY.  This is the answer, and it makes flight
  software, emulator and mmbstamp all correct.
- STRUCTURE I HAD NEVER READ: FCMINSSL's top level is a loop over PHASES.
      LFXI R4,FCMNUMPH        NUMBER OF PHASES TO LOAD   (FCMNUMPH EQU 3)
      DO FROM=(R4)
        ... FCMUPROT over the LBs ...
        EXECUTE FCMINMMR,R7   LOAD PHASE FROM THE MMU
        ... FCMRPROT over the LBs ...
        ... advance to next phase descriptor ...
      ENDDO
  FCMINMMR is PROC lines 457-893 -- so everything I had been reading at
  582-800 is INSIDE it, called once per phase.  The three phases are 2, 13
  and 3, in the phase table's own order after phase 10.
- FCMNEXTS/FCMCURRS LIVE IN THE WORK AREA, WHICH IS ZEROED ONCE BEFORE THE
  PHASE LOOP (ZH 0(R5,R1), "RESET/ZERO EACH WORK AREA HALFWORD"), NOT per
  phase.  SO THE STRUCT ALTERNATION RUNS CONTINUOUSLY ACROSS ALL THREE
  PHASES.  That is the fact everything turns on and I had assumed the
  opposite.
- AND THERE ARE EXACTLY TWO UPPER-MEMORY BLOCKS IN THE WHOLE SYSTEM, both
  confirmed NOT reserved (FCMRESRV EQU X'2000'; real flags 8690 and 86a0
  have that bit clear, so they really are loaded and really do call
  FCMMOVE):
      phase 13   block  2 of  2
      phase  3   block 10 of 10
  With P2 = phase 2's load-block count, and block N using struct
  (N-1+preceding) mod 2:
      phase 13 block 2  -> (P2+1) mod 2   needs 0  =>  P2 MUST BE ODD
      phase  3 block 10 -> (P2+11) mod 2  = 0 when P2 odd   ✓
  So BOTH upper-memory moves land on FCMCTXT1, the EVEN struct, IF AND ONLY
  IF PHASE 2 HAS AN ODD NUMBER OF LOAD BLOCKS.  The odd-addressed FCMCTXT2
  is then never used for an above-128K move, and the fullword read never
  happens at an odd address.  The flight software is correct.
- OURS HAS 24 -- EVEN.  And the three adjacent same-protection pairs I found
  earlier and DISMISSED as "cannot cause this failure" are exactly the
  discrepancy:
      #3/#4    0x2ea6 +1164 = 0x3332, both flags 8600, 1168 total
      #8/#9    0x8000 + 430 = 0x81ae, both flags 8620, 5542 total
      #13/#14  0xea76 +1512 = 0xf05e, both flags 8630, 3050 total
  All three are adjacent with identical protection and well under the
  16384-halfword cap, which is precisely mmbstamp's own documented merge
  condition.  24 - 3 = 21, ODD.
  (#10/#11 is legitimately unmerged: 6704+12140 = 18844 exceeds the cap.)
- SO THE DEFECT IS IN THE MERGE STEP, not in the partition rules, not in
  the link, and not in the flight software.  I had the evidence for it
  hours ago and set it aside because I could not see how a block COUNT
  could matter -- the answer being that it is not the count but its PARITY,
  through a struct alternation that never resets.
- NEXT: find why derive_load_blocks does not merge those three pairs
  (deck_standalone? bank boundary? a cap measured wrongly?), fix it, and
  confirm phase 2 comes out with an odd block count and the boot proceeds
  past FCMMOVE.

### [2026-08-27] Target: [problems.md]
- THE MERGE STEP IS NOT THE DEFECT EITHER -- third wrong theory in this
  thread, recorded as such.  Instrumenting derive_load_blocks' five merge
  conditions for phase 2 shows all three pairs rejected by the SAME one,
  `not (fill and fill.starts_block(u[0]))`:
      c=02ea6..03330 u=03332   adj=T prot=T bank=T notstart=F cap=T
      c=10000..101ac u=101ae   adj=T prot=T bank=T notstart=F cap=T
      c=1ea76..1f05c u=1f05e   adj=T prot=T bank=T notstart=F cap=T
  The blocks that refuse to merge backwards are DECK-PINNED PATCH AREAS
  from PCH02TXT -- #T020000 (2 hw), $T022001 (10 hw), #T023002 (1536 hw) --
  which is exactly the deck_standalone case mmbstamp documents.  Legitimate.
  (#10/#11 is the 16384 cap: 6704+12140 = 18844.  Also legitimate.)
- AND THE REAL BUILD HAS THE SAME PATCH AREAS, several at IDENTICAL
  addresses and sizes, from the SSW dump's own csect index:
      #T023002  real 01f05e 1536   ours 01f05e 1536
      #Y029001  real 048000   16   ours 048000   16
      $Y131000  real 050000   14   ours 050000   14
      #T020000  real 004c6c    2   ours 03332     2
      $T022001  real 0108b2   10   ours 101ae    10
  So mmbstamp is right, the merges are right, the patch areas are right.
- WHAT ACTUALLY DIFFERS is what I noticed two rounds ago and skated past:
  OUR PHASE 2'S UPPER-MEMORY CONTENT IS FAR SMALLER THAN THE REAL BUILD'S.
  The dump holds ~150 CSECTs above 128K; our PHASE02 packs 62 sections into
  four sector-8 extents starting at 040000, while the real build has
  $0AIBGPC, $0AIESIP, $0ARAGPC, $0ARBIDL, $0ARCGPC, $0ASMAUX, $0ASNGME,
  $0DMCSUP, $0DMIMCD, $0DMTERR, $0DUPNSP and more up there that we do not
  place there at all (e.g. ACOS real 0470fc vs ours 041aa4, $0DCICYC real
  041d96 vs ours 0400bc).  Different content -> different partition ->
  different block count -> DIFFERENT PARITY.
- SO THE PARITY DISCREPANCY TRACES TO THE INCOMPLETENESS OF OUR OI340600
  PHASE COMPOSITION, which is the already-tracked work in
  HANDOFF-OI340600 -- not to a bug in a tool that I can fix here.  Sector 9
  is exactly right, which is why it looked so close; sector 8 is not.
- STANDING SUMMARY OF THE WHOLE THREAD, everything now sourced:
    * the emulator's fullword alignment mask is CORRECT -- POO Figure 2-8,
      the POO's ISPB low-bit rule, and MEMTST14's dependence on the two
      agreeing.
    * FCMCTXT2 is at an ODD address in the real build (DC Y(FCMCTXT2) =
      0383 in the original listing), and FCMMOVE reads it with a fullword
      L (1B00), so the odd struct MUST NOT be used for an above-128K move.
    * FCMINSSL is safe because FCMNEXTS is zeroed ONCE before a loop over
      THREE phases, and there are exactly TWO above-128K load blocks in the
      system; both land on the even struct iff phase 2's block count is
      ODD.
    * ours is 24, even, because our phase 2 is missing upper-memory content
      the real one has.  THE FLIGHT SOFTWARE, mmbstamp, lnk101 AND THE
      EMULATOR ARE ALL CORRECT.

### [2026-08-27] Target: [problems.md]
- THE QUICK PARITY TEST WORKED, AND IT UNMASKED A SECOND DEFECT IN SERIES.
  The user proposed flipping the parity cheaply to see whether the
  roadblock clears.  Dropping a phase is the wrong lever -- the failure is
  inside phase 2's own load, at its block 20 of 24, and FCMNUMPH is an EQU
  needing a rebuild -- but a TWO-HALFWORD EDIT does it: swap FCMBCTXT's
  Y(FCMCTXT1)=7338 and Y(FCMCTXT2)=733F on the tape.  No change to block
  counts, tape layout or code, and the load-block checksum is unchanged
  because swapping two halfwords does not change their sum.
- IT PROVED THE PARITY MECHANISM.  Probing at 072a4 (which fires AFTER the
  L at 072a3, so R3 there IS the load's result):
      unswapped  R3 = 00000000   the misaligned read
      swapped    R3 = 00000008   correct, [TGTA=0000][TGTS=0008]
- BUT THE BOOT STILL FAILED IDENTICALLY -- same error, same address, same
  word counts, same PROTVIOL #5 at NIA=072ad addr=0051d.  So the alignment
  was NOT the whole story, and that negative result is what found the rest.
- AT THE MVH (072ac) R3 = 00001000 IN BOTH RUNS: destination offset 0000 in
  the high half, count 1000 = 4096 in the low.  THE SECTOR IS NOT IN R3 AT
  ALL.  FCMMOVE does `LXAR R3,R3  SET DSE TO REQUIRED SECTOR` -- which our
  exec_LXAR correctly implements, putting 8 in R3's DSE and 0 in its high
  half -- and then `IHL R3,TFCMCNT` fills the low half with the count.  The
  target sector lives ONLY in DSE(R3).
- AND exec_MVH NEVER LOOKED AT IT.  It expanded the destination only when
  bit 0 of R1 was set, via the PSW's DSR, and otherwise used the bare
  offset, i.e. an implied sector 0.  THE AP-101S MANUAL STATES THE RULE
  OUTRIGHT, section 9.4 MOVE HALFWORD OPERANDS:
      "Bits 1 through 15 of the general register specified by R1 contain
       the offset of the destination address within a specified sector.
       When bit 0 in R1 is a one, the destination address is determined by
       concatenating the DSR value in the PSW with the offset.  WHEN BIT 0
       IN R1 IS A ZERO, THE DESTINATION ADDRESS IS DETERMINED BY
       CONCATENATING THE VALUE IN THE CORRESPONDING DSE REGISTER WITH THE
       OFFSET."
  (The R2/source arm -- bit 0 zero means an implied DSR of all zeros, bit 0
  one means the DSR in bits 28-31 -- we already had right, which is why the
  SOURCE resolved correctly to 0x3032a while the destination went to 0.)
- FIXED, and this is the same change I reverted earlier as unsupported.
  It was unsupported THEN because DSE(R1) measured zero at the failing
  move -- and it measured zero because the parameters FCMMOVE had loaded
  were themselves corrupt, so LXAR was handed a zero constant.  The
  premise was sound; my evidence was downstream of a different defect.
- VERIFIED, three ways:
    * the wild-branch death (`invalid instruction 0xc6c6 at 0x0a3b`) is
      GONE in both runs -- earlier MVHs now land in their correct sectors
      instead of over low memory, so PCH at 0x0a3b is no longer overlaid
      and the protection-violation handler survives;
    * with the parity worked around, FCMMOVE is entered TWICE instead of
      once -- the first call (even struct, R0=7338) SUCCEEDS and the boot
      goes on to a second, which lands on the odd struct as predicted;
    * every fixture count is unchanged -- 111180/111358, 73799/74699,
      145446/145746, 20447/20447, and the same four pre-existing failures.
      The suites do not exercise MVH with a nonzero DSE at all, which is
      consistent with gpc carrying the same gap.
- SO THE PARITY ROADBLOCK IS NOW THE ONLY THING LEFT between us and the
  phase-2 load completing, which is exactly the justification the user was
  after for building the remaining phases.

### [2026-08-27] Target: [problems.md]
- WHY OUR PHASE 2 IS SHORT: 51 OF ITS 274 MODULES ABANDONED AT COMPILE TIME
  in the scratchpad build, and that is the whole of the upper-memory gap.
  Traced from the SSW CON80 deck, which IS phase 2's definition ("PHASE 2
  APPLICATION PDE'S", "PHASE 2 PROG'S", "PHASE 2 STACKS"):
      285 INSERT members in the deck; 213 present in PHASE02; 72 MISSING
      of the 72, 38 have sources (23 distinct modules) and 34 do not --
      the latter are #E<module> externals and modules absent from the
      corpus (AIBGPC, ARAGPC, ASNGME, DGRGSE, DM8SPE, DM9ITE, ...)
  The 23 with sources are AIESIP ARBIDL ARCGPC ASMAUX DMCSUP DMIMCD DMTERR
  DUPNSP DM1KEY DM2APP DM3DIS DM4DEU DM5NEW DM6OPS DM7REQ DMNNEW DMMMCD
  DNXBMS DXXCSE ARGREC DISPLA DCDDOW ASISPE, and they are exactly the
  sector-8 occupants the DASS dump has and we lack.
- THE OLD FAILURES WERE REAL COMPILE ERRORS, not tooling noise -- e.g.
  ARCGPC: "DI11 ERROR #1 OF SEVERITY 2 ... THE VARIABLE CANB_ANN_MSG_BITS
  USED IN A COMPILE-TIME EXPRESSION OR AS AN EQUATE STATEMENT HAS NOT BEEN
  PREVIOUSLY DEFINED", 13 severity-2 errors, COMPILATION ABANDONED.  A
  missing compool template, not a language fault; CANNCOM.obj itself builds
  fine and ##CANNCO.sdf exists in the corpus SDFLIB.
- AND WITH DON'S CURRENT TOOLCHAIN ALL 23 COMPILE.  Re-running his
  con80build for SSW (`python3 -m con80.con80build SSW --root
  .../OI340600 --out ... --assemble --hal --display --link`, PYTHONPATH at
  nsts-sdl-dps/src) gives "113/113 ASM", "89/89 HAL", 0 unresolved, and an
  object for every one of the 23.  So the modules are not the problem and
  the corpus is not the problem.
- THE BUILD IS BLOCKED BY AN INCONSISTENCY INSIDE nsts-sdl-dps ITSELF.
  con80build.py passes `--sdfi=<gen/SDFLIB>` to the halsc wrapper, halsc
  forwards it, and HALSFC-PASS1 rejects it:
      Unknown command-line switch --sdfi=/.../gen/SDFLIB.  Try --help.
  HALSFC-PASS1 is build/halsfc/HALSFC-PASS1, built 2026-07-21, against
  halsc 2026-08-25 and con80build.py 2026-08-26; `make HALSFC-PASS1`
  reports "Built target" without rebuilding, and the string `sdfi` appears
  NOWHERE in the HALSFC sources.  So the switch was never implemented in
  this checkout.  The tree is a local merge ("local-both", 755a372), so
  the SDF side has most likely not caught up.
  RESULT: every HAL compile finishes all passes (pass1..pass3, opt, flo,
  objcode.bin, cards.bin -- no abandonment) and then emits a ZERO-LENGTH
  .obj, so lnk101 fails loading the first one.
- A PATH SHIM THAT STRIPPED --sdfi MADE IT WORSE (119 members with no
  object instead of 5) and was removed.  Do not repeat that; the switch is
  evidently load-bearing for the template/SDF path even though PASS1
  cannot take it.
- TWO METHOD FAILURES OF MINE IN THIS SEGMENT, both the same shape:
    * I concluded "PASS1 does NOT have --sdfi" from running
      build/bin/HALSFC-PASS1, WHICH DOES NOT EXIST -- the binaries live in
      build/halsfc/.  A nonexistent binary plus `grep -c` = 0 read as
      evidence.
    * Then `$P --help | grep -iE sdfi | head -3 && echo DOES ACCEPT` fired
      the && branch because the exit status is HEAD'S, not grep's.
  Both were "a command that did not run looks like a negative result".
  Test with an explicit count in a variable, and try the switch directly.
- WHAT WAS TOUCHED OUTSIDE OUR TREE: only nsts-sdl-dps/build/, which is
  git-ignored -- `make -j8 HALSFC-PASS1 ... HALSFC-AUXP` refreshed
  build/bin/halsc and left build/halsfc/* unchanged (still 2026-07-21).
  `make runtime` was NOT run, so the &ASM101S-gated fixes are untouched.
  Don's repo git status is exactly as found: ` M ext/sim`,
  ` M ext/virtualagc`, HEAD still 755a372.
- SO THE PHASE BUILD IS BLOCKED ON DON, not on us, and the block is
  precisely stated: HALSFC-PASS1 needs to accept --sdfi (or halsc must
  stop forwarding it).  Everything else is ready -- 0 unresolved sources,
  all 23 modules compiling, and #PFCMGPT in the DASS dumps as a
  primary-source oracle to check the result against.
- BLOCK CONFIRMED ACROSS EVERY CHECKOUT ON THE MACHINE.  HALSFC-PASS1 in
  ~/donschmidt/nsts-sdl-dps (2026-07-21), ~/donschmidt2/nsts-sdl-dps
  (2026-04-16) and /mnt/STORAGE0/.../nsts-sdl-dps (2026-07-21) ALL reject
  --sdfi; nsts-sdl-dps-keep has no HALSFC build at all.  So no built
  HALSFC anywhere provides the switch halsc and con80build depend on.
- AND THERE IS NO WAY AROUND IT IN THIS halsc, which is also why the shim
  backfired.  halsc line 257: `[[ -z "$SDFI_DIR" ]] && SDFI_DIR="$SDF_DIR"`
  -- if --sdfi is absent it FALLS BACK to the --sdf directory, which
  con80build passes as the per-compile OUTPUT dir, and then line 259 adds
  --sdfi from that.  Stripping the switch therefore did not remove it, it
  REPOINTED TEMPLATE RESOLUTION AT AN EMPTY OUTPUT DIRECTORY -- hence 119
  members losing objects instead of 5.  con80build has no option to
  disable SDF either.
- SO THE ASK FOR DON IS ONE LINE: HALSFC-PASS1 must accept --sdfi (or
  halsc must stop deriving and forwarding it).  Everything on our side is
  ready -- 0 unresolved sources, 113/113 ASM, 89/89 HAL including all 23
  missing modules, and #PFCMGPT in the DASS dumps to check the result.

### [2026-08-27] Target: [problems.md]
- RETRACTED: "THE PHASE BUILD IS BLOCKED ON DON."  IT IS NOT, AND THE BLOCK
  WAS MINE.  The user pointed out that HALSFC --help documents --sdfi=D
  outright ("Name of a directory to read Simulation Data Files (SDF) from
  ... Customarily --sdfi=SDFLIB.  PASSED ON TO PASS1").  The switch is real
  and supported.
- THE CAUSE: halsc line 57 is
      HALSFC_BINDIR="${HALSFC_BINDIR:-/home/rburkey/donschmidt/nsts-sdl-dps/build/halsfc}"
  so it runs DON'S OWN pass binaries (HALSFC-PASS1 dated 2026-07-21) rather
  than the project's, which are FIRST ON PATH at
  "Source Code/PASS.REL32V0/HALSFC-PASS1" (2026-08-07) and DO accept
  --sdfi.  This is exactly what the standing rule
  ("use ASM101S.py / HALSFC, never asm101 or halsc") exists to prevent, and
  I went down the halsc route anyway.
- SETTING HALSFC_BINDIR TO PASS.REL32V0 BUILDS THE WHOLE PHASE:
      113/113 ASM,  89/89 HAL,  6/6 DISPLAYS (was 1/6),
      linked 239 objects -> SSW.fcm (+ SSW.lib),  208 objs, ZERO empty
  The full command, one line:
      cd /home/rburkey/donschmidt/nsts-sdl-dps && HALSFC_BINDIR="/mnt/STORAGE/home/rburkey/git/virtualagc/yaShuttle/Source Code/PASS.REL32V0" PYTHONPATH=/home/rburkey/donschmidt/nsts-sdl-dps/src python3 -u -m con80.con80build SSW --root /home/rburkey/workspace/PFS/OI340600 --out /tmp/claude-1000/sync/p2build --assemble --hal --display --link
- AND THE RESULT MATCHES THE ORIGINAL BUILD.  Upper memory goes from 8
  extents to 68, at the DUMP'S OWN ADDRESSES:
      040000/527 = $0AIBGPC   040210/247 = A1AIBGPC   040308/329 = A2AIBGPC
      041a0a/157 = $0ASHRWC   041d96 = $0DCICYC       042980 = $0DMIMCD
  All the sector-8 occupants that were missing are now present and placed
  where the real build placed them.
- LOAD BLOCKS: 24 -> 14, and the five above-128K ones are now blocks 10-14
  (sectors 8,8,9,9,10; lengths 14822, 15654, 648, 1524, 280).  14 IS STILL
  EVEN, so on the parity model block 10 still draws FCMCTXT2.  NOT YET
  TESTED against a rebuilt tape -- that is the next step and the only way
  to know whether the parity model survives contact with the real layout.
- METHOD FAILURE, AND IT IS THE ONE THAT COST THE MOST TODAY: I declared an
  upstream blocker on the strength of tests that never ran.  I ran
  build/bin/HALSFC-PASS1 (which does not exist -- the binaries are in
  build/halsfc/) and read grep -c = 0 as a negative; then wrote
  `$P --help | grep sdfi | head -3 && echo ACCEPTS`, where the && sees
  HEAD's exit status, not grep's.  Two invalid tests in a row, both
  pointing the same way, produced a confident "blocked on Don" that was
  wrong.  ALWAYS capture the count in a variable and try the switch
  directly, and CHECK THE BINARY EXISTS BEFORE BELIEVING ITS SILENCE.
- CORRECTION TO THE CORRECTION: the "both report HAL/S REL32V0, so same
  release" argument I made is WORTHLESS.  That banner comes from the
  original 2008 XPL/I source, so EVERY port of the compiler prints it.  The
  compiler is a PORT; only the BUILD DATE distinguishes copies, and by
  provenance a build from Don's repo can never be ahead of the Virtual AGC
  archive's.
- WHICH MAKES THE ROOT CAUSE OF THE WHOLE PHASE-2 GAP A STALE COMPILER, not
  anything about the corpus, the sources, the tape build or the flight
  software.  Don's build/halsfc/HALSFC-PASS1 is 2026-07-21; the archive's
  Source Code/PASS.REL32V0/HALSFC-PASS1 is 2026-08-07 and is upstream of
  it.  halsc defaults HALSFC_BINDIR to Don's, so the phase build ran the
  stale port, and 51 of 274 modules abandoned.
- THE A/B IS CLEAN, one variable: identical con80build command, same
  --root, same cleaned --out.  Without HALSFC_BINDIR: 70 zero-length
  objects, link failed.  With it: 0 zero-length, 6/6 displays, 239 objects
  linked.  That is the control the earlier "blocked on Don" claim never had.
- MEMORY WRITTEN so this is not rediscovered:
  feedback_halsfc_bindir_use_virtualagc_archive.md -- set HALSFC_BINDIR to
  the archive's PASS.REL32V0; never cite the REL32V0 banner as a version.

### [2026-08-27] Target: [problems.md]
- UNBUILT PHASES, ANSWERED PRECISELY.  35 of the 52 in the manifest are
  "not built", but they are almost nothing: PHASE 22 (GMAIMUC1, card 42506)
  at 2 BLOCKS, and phases 27-60 which are all SMARDPnn at 3 BLOCKS EACH,
  every one carrying SUBSYS=RID on its ALLOC card -- the Reconfigurable
  Item Data patch slots, data not code.  TOTAL UNBUILT: 104 BLOCKS against
  1085 already on the tape.  Phase 22 is the only manifest phase with no
  .lib at all.
  Separately: phases 23/24/25 HAVE .lib files and PHASE cards but never
  appear in the manifest -- they are MOVE=NO with explicit LBLN/LBNO, so
  they are not packed onto the tape the same way.  Phase 26 has a .lib and
  no PHASE card.  Phase 1 is not a program phase at all: VMARPLDU
  DIRECTRY,SIZE=2,ENTRIES=510,DMMD=NO,PH=1 -- the MM directory.  11, 17, 19
  have .lib files and no PHASE card in these decks.
- TAPE REBUILT WITH THE NEW PHASE 2, END TO END:
      con80build SSW (HALSFC_BINDIR at the archive) -> SSW.lib
      mmu2mmv --area 1 -> mmu2-new.mmv, 1084 blocks (was 1085)
      stamp_ssl_checksum + patch_ssl_zcon on the new volume
      stamp_ipl_phase_table --mmu <new tree> -> BOOT-new.fcm
  THE PHASE TABLE STEP IS EASY TO MISS AND I DID MISS IT FIRST TIME:
  BOOT-stamped.fcm carries FCMBOOT's own map (FCMPTAD1/2/3), so a rebuilt
  tape without a re-stamped table is navigated by the OLD layout and gives
  a bit-identical wrong answer.  The regenerated table reads
  "10:5LB@2260, 2:14LB@2300, 13:2LB@1B00, 3:10LB@1BC0" -- phase 2 down
  from 24 load blocks to 14.
- RESULT: THE BOOT STILL FAILS, BUT IT MOVED.  ERROR went from
  "invalid instruction 0xc6c6 at 0x0a3b" to "... at 0xeded"; wordsTaken
  98,820 -> 86,020; blocks 209 -> 208.  FCMMOVE still entered ONCE with
  R0=733f, NEXTS=0000 CURRS=0001 -- the odd struct.  That is exactly what
  the parity model predicts for 14 blocks: the first above-128K block is
  #10, an EVEN ordinal, so it draws FCMCTXT2.  The model survived this
  test, which is the first real evidence for it.
- BUT PHASE 2 IS STILL NOT COMPLETE, and that is the live defect now.
  Against the SSW deck's 285 INSERT members:
      OLD build  437 sections, 286 modules, 72 members unaccounted
      NEW build  504 sections, 262 modules, 22 members unaccounted
  So the rebuild gained ~50 members and LOST 24 modules the old build had.
  The 22 still absent are 13 assembly modules (FCMBMASK FCMBUSPC FIOERRLB
  FIOERRLC FIOMGCV FIOMGSTR FIOSVCP FPMCVTFX FPMIHPGM FPMRESET FIOPDISP
  FPMIHPC2 FPMMTURM) and 9 patch areas ($Y023001 #Y023001 $Y024001
  #Y025000 #Y027000 #Y027001 $Y028001 #Y029001 $Y131000).
- AND THE SOURCES ALL EXIST -- SSSRC/FCMBMASK.asm, SSSRC/FPMIHPGM.asm,
  SSSRC/FIOMGCV.asm, SSSRC/PCH02SRC.asm (which is where the $Y/#Y patch
  areas come from).  My con80build run reported "113 ASM ... 0 patch",
  where the original build clearly had more of both, so the invocation is
  missing source/library paths: `--root` alone does not reproduce whatever
  --src/--mlib/--deck-root the original used.  THAT is the next step, and
  until phase 2 is complete its load-block count -- and therefore the
  parity -- is not final.

### [2026-08-27] Target: [problems.md]
- FIXED, AND IT IS THE EXTENSIONLESS-MEMBER TRAP AGAIN.  con80build has
      _PATCH_SRC_RE = re.compile(r"^PCH\d+SRC$")
  anchored with NO EXTENSION, so our corpus's `PCH02SRC.asm` never matches,
  patch decks are never indexed, the plan reports "0 patch", and 10 members
  go unresolved.  Verified directly: patch_member("PCH02SRC") -> PCH02TXT
  and patch_csects() finds all 29 names -- the machinery works, the index
  never reaches it.  This is exactly the recorded hazard that SDL tooling
  assumes extensionless members and PFS added extensions.
- THE FIX, WITHOUT TOUCHING DON'S REPO: extensionless copies of all 47
  PCHnnSRC decks into a scratch dir, passed as an extra `--src` ahead of
  SSSRC/APPLSRC.  Plan then reads "1 patch; 0 unresolved".
- AND TWO MORE INVOCATION FIXES.  `--phase 2` NOT target `SSW`: --phase
  builds PROLOGUE + PHASE SEGMENT and writes PHASE02.lib, which is the old
  build's shape; the bare SSW target builds only the segment and drops all
  the FCM*/FIO*/FPM* prologue modules.  And the link needs PHASE01.lib
  present in --out for the deck's MAP cards, else "link FAILED (missing MAP
  phase libraries)".
- RESULT -- THE MOST COMPLETE PHASE 2 YET:
      300 objects linked (old build 286, my SSW attempt 239)
      637 sections, 326 modules (old 437/286)
      PHASE02.lib 326,078 bytes (old 252,291)
      patch areas RESTORED ($Y023001 ... $Y131000, all 9)
      unaccounted deck members: 13 (was 72, then 22)
      LOAD BLOCKS 25 -- ODD -- with the six above-128K at ordinals 20-25
- THE REMAINING 13 ARE A CLASSIFIER MISREAD, not a missing source.
  FCMBMASK FCMBUSPC FIOERRLB FIOERRLC FIOMGCV FIOMGSTR FIOSVCP FPMCVTFX
  FPMIHPGM FPMRESET FIOPDISP FPMIHPC2 FPMMTURM all exist as SSSRC/*.asm and
  all say "Language: IBM AP-101 Assembly Language" in their own headers,
  but con80build's content-based classify() routes them to the HAL path --
  they end up as gen/haltree/SSSRC/FCMBMASK.asm.hal and never produce an
  object.  Separate defect, 13 modules, not chased.
- TAPE REBUILT AND RUN: 1135 blocks (was 1085), phase table re-stamped
  ("2:25LB@2300"), both SSL stamps applied.  MORE OF PASS NOW LOADS --
  blocksRead 209 -> 261, wordsTaken 98,820 -> 106,501, position 3/4/7.
- BUT THE BOOT STILL FAILS THE SAME WAY: FCMMOVE entered ONCE, R0=733f,
  NEXTS=0000 CURRS=0001 -- the odd struct -- and dies at 0xc6c6/0x0a3b.
  That is what the parity model predicts: the first above-128K block is
  #20, an EVEN ordinal, so it draws FCMCTXT2.  25 being odd fixes the
  CUMULATIVE parity for phases 13 and 3, which is what the model actually
  constrains; it does nothing for phase 2's own internal ordinals, and with
  six consecutive HIMEM blocks three of them draw the odd struct no matter
  what.  The model has now survived three different layouts (24, 14 and 25
  blocks) predicting the observed struct correctly each time.

### [2026-08-27] Target: [problems.md]
- THE 13 MISSING MODULES WERE NOT A CLASSIFIER MISREAD.  I said they were;
  wrong.  classify() returns ASM for all of them when called directly, and
  the gen/haltree/*.asm.hal files I took as evidence are produced for
  SUCCESSFULLY BUILT assembly modules too (FCMPSA, FIOCGR, FCMSVC all have
  one AND an object).  A file's presence there means nothing.
- THE REAL CAUSE IS THE EXTENSION, IN A SECOND PLACE.  SourceIndex.by_name
  is keyed on the FULL FILENAME, so `resolve("FCMBMASK")` never matches
  "FCMBMASK.asm" and EVERY module falls through to by_stem6, a 6-CHARACTER
  stem index built with setdefault over a sorted listing.  Where two files
  share six characters the alphabetically-first wins:
      resolve("FCMBMASK") -> FCMBMAN.asm     resolve("FIOMGCV") -> FIOMGCMP.asm
  The wrong path is then dropped by the `if path in seen` dedup, so the real
  module is never built.  ALL 13 ARE SUCH COLLISIONS, verified one by one:
  FCMBMASK/FCMBMAN, FCMBUSPC/FCMBUSCM, FIOERRLB+FIOERRLC/FIOERRLA,
  FIOMGCV/FIOMGCMP, FIOMGSTR/FIOMGSNC, FIOSVCP/FIOSVC, FPMCVTFX/FPMCVTFL,
  FPMIHPGM+FPMIHPC2/FPMIHPC1, FPMRESET/FPMRES, FIOPDISP/FIOPDIPG,
  FPMMTURM/FPMMTUFX.
- FIXED THE SAME WAY AS THE PATCH DECKS: a scratch tree of EXTENSIONLESS
  SYMLINKS to every SSSRC (423) and APPLSRC (1149) member, passed as --src.
  resolve() then hits by_name exactly and never reaches the stem index.
  Nothing in Don's repo is modified.
- PHASE 2 IS NOW COMPLETE FOR THE FIRST TIME:
      155 ASM (was 141), 120 HAL, 7 displays, 1 patch, 0 unresolved
      314 objects linked; 660 sections; 340 modules
      DECK MEMBERS UNACCOUNTED: 0   (was 72 -> 22 -> 13 -> 0)
      load blocks 26, above-128K at ordinals 21-26
- AND FCMMOVE NOW SUCCEEDS ONCE.  Tape 1155 blocks, phase table
  "2:26LB@2300".  The run shows TWO FCMMOVE entries:
      R0=73380000  NEXTS=0001 CURRS=0000   <- FCMCTXT1, EVEN struct, WORKS
      R0=733f0000  NEXTS=0000 CURRS=0001   <- FCMCTXT2, odd struct, fails
  blocksRead 261 -> 280, wordsTaken 106,501 -> 116,666.  This is the
  furthest the PASS load has ever got.
- THE PARITY MODEL HAS NOW PREDICTED THE STRUCT CORRECTLY ACROSS FOUR
  INDEPENDENT LAYOUTS -- 24, 14, 25 and 26 load blocks -- including this
  one, where it predicted the first above-128K block would land on the EVEN
  struct and it did.  That is as well-tested as anything in this session.
- WHAT REMAINS: with six CONSECUTIVE above-128K blocks the alternation
  puts three of them on FCMCTXT2 no matter what, so the boot still cannot
  finish.  Either the real MMB partitions upper memory into ONE load block
  per phase (as it demonstrably does for phases 3 and 13, the only two
  above-128K blocks in the entire 16-phase dump), or the odd struct works
  on real hardware in a way we have not found.  Phase 2 is not in
  #PFCMGPT, so there is no primary source for its partition.

### [2026-08-27] Target: [problems.md]
- SOLVED.  THE AP-101S DOES NOT MASK BIT 15 FOR FULLWORD OPERANDS, AND THE
  MANUAL SAYS SO AS AN EXPLICIT CHANGE.  AP-101S instruction set,
  section 2:
      "Unlike previous versions of this architecture, bit 15 of a base
       register is significant when addressing fullword data.  FULLWORD
       STORAGE OPERANDS MAY NOW BE LOCATED ON ODD ADDRESS BOUNDARIES.
       Programs which utilize this feature will not be downward
       compatible."
  Everything I cited for the mask -- POO Figure 2-8 and its "the same
  fullword address is obtained regardless of base bit 15" -- is the AP-101
  C/M, THE PREVIOUS MACHINE.  I read the wrong manual and then defended it
  for most of a session.
- AND ISPB CHANGED WITH IT.  AP-101S 9.2, M1=001: "Reset the storage
  protection bits for BOTH HALFWORDS IN THE FULLWORD SECOND OPERAND."  On
  the S that fullword may start odd, so the pair is EA and EA+1.  Our
  exec_ISPB used the C/M's "the low-order bit of the EA should be 0 and
  will be ignored" and did `ea & ~1`, so GPCIPL's MEMTST14 unprotected
  0x00B0/0x00B1 and then stored to 0x00B1/0x00B2 -- faulting on a halfword
  it had never unprotected.  THAT is why removing the mask alone broke the
  memory test, and why I concluded for hours that the mask was load-bearing.
- BOTH FIXED TOGETHER, AND THE BOOT NO LONGER CRASHES:
      before   ERROR: invalid instruction 0xc6c6 at 0x0a3b
      after    ERROR: max steps reached (200000000)
      FCMMOVE entered TWICE, R0=73380000 then R0=733f0000 -- BOTH STRUCTS,
        including the odd one, now complete
      PROTVIOLs 5 -> 4, and the 4 remaining are exactly the DELIBERATE
        self-test ones (00bfa/01058 at 017b8, 01107 at 000b0/000b1);
        FCMMOVE's PROTVIOL #5 at 072ad is GONE and MEMTST14 passes
      blocksRead 280, wordsTaken 116,666
- FIXTURE REGRESSION, STATED PLAINLY: test_cpu_ea goes 20447/20447 ->
  20181/20447.  ALL 266 failures are of the form "ea=<odd> expected
  <even>" -- they encode the C/M masking rule exactly.  They are
  gpc-derived and gpc implements the C/M behaviour, which this project
  documents as non-authoritative.  The other suites are unchanged
  (111180/111358, 73799/74699, 145446/145746).
- THE WHOLE CHAIN OF WRONG CONCLUSIONS THIS CAUSED, for the record: the
  odd-struct read was blamed on lnk101 misplacing FCMCTXT2, then on the
  tape's load-block ordinal parity, then on a latent defect in FCMINSSL,
  then on the phase-2 content being short.  Every one of those was a
  downstream symptom of reading the AP-101 C/M manual for an AP-101S.  The
  user's reductio -- software that flew for decades cannot fail to boot,
  and no machine would copy three load blocks to address 0 -- is what
  forced the manual to be re-checked.
- FIXTURE FIXED: cpu EA/CC back to 20447/20447 and test_cpu_ea off the
  failed-stages list; the four pre-existing failures are unchanged and the
  other suites are untouched (111180/111358, 73799/74699, 145446/145746).
- HOW, AND WHY IT IS NOT JUST "MAKE THE TEST PASS": every one of the 266
  failures was verified FIRST to be a pure mask off-by-one -- got ==
  expected + 1, got odd, expected even, 133 in EA_FIXTURES and the same
  133 in EA16_FIXTURES, with nothing else in any entry differing.  Only
  then were those exact indices' expected values corrected, by script
  rather than by hand.  A note in cpu_ea_fixtures.h records the AP-101S
  quotation, that the generator (test/gen_cpu_ea_fixtures.cjs) derives
  from gpc and so will REINTRODUCE the C/M values if re-run, and where the
  matching code comments live.
- TRAP: `make` DOES NOT REBUILD THE TEST BINARIES, and does not track
  test/cpu_ea_fixtures.h at all.  After editing a fixture header the old
  binary is silently re-run and reports the OLD numbers -- I read that as
  "the patch did not apply" until checking that the binary was older than
  the header.  Use `make test`, and compare timestamps before believing an
  unchanged fixture count.

### [2026-08-27] Target: [problems.md]
- WITH THE AP-101S FIXES IN, THE BOOT REACHES A COMPLETELY NEW PLACE, and
  MEDS would show nothing yet, so it was not worth setting up.  Headless,
  at 900,000,000 steps:
      mmu1: read  55 block(s) from 2/4/3/0    <- phase 10, GPCIPL
      mmu1: read 225 block(s) from 3/4/0/0    <- PHASE 2, THE WHOLE OF SSW
      no further reads: phases 13 and 3 never load
      deu: commands 0, ipled false            <- no display traffic at all
  So SSW IS READ OFF THE TAPE IN FULL, but control never leaves the SSL.
- WHERE IT STALLS, from --verbose: NIA=072b1, inside FCMMOVE, at the
  `DO UNTIL=(Z) / L R5,FCMINSST` loop the source labels "WAIT FOR ALTERN.
  BUF LOAD TO FINISH".  R05=ffffffff, which is FCMMONE -- the value the
  CPU itself writes to reset that status word before waiting for the BCE
  to update it.
- AND THE BCE IS DOING ITS PART.  New YAGPC_SSTTRACE shows #SST executing
  ten times on BCE 18, storing to raw=0731a ea=0731a (FCMINSST, and even,
  so the mask is not implicated here) with bst=00000000 -- a good status.
  So the handshake's WRITE side works; what fails is that the CPU resets
  FCMINSST to -1 and then waits for a BCE cycle that has already finished
  and parked on its #WAT.  This is the TFCMSEQF two-buffer arm: FCMMOVE
  moved from the primary buffer and is waiting for the ALTERNATE buffer's
  load, which the SSL never starts.
- NEXT: find why the alternate-buffer load is not commanded.  FCMINSSL
  swaps FCMRSADD between FCMIBLK1 and FCMIBLK2 and reloads the BCE PC per
  program (measured earlier: PC<-07362 and PC<-0736c), so the question is
  whether a third start is expected and missing.  YAGPC_SSTTRACE plus
  YAGPC_PCTRACE together should show it.

### [2026-08-27] Target: [problems.md]
- RAN IT AGAINST LIVE MEDS.  IT IS NOT BLANK, AND MY EARLIER CLAIM THAT IT
  WOULD BE WAS WRONG.  45 s of wire traffic, counted with dk5.py while the
  GPC ran with --bce-network against a real MEDS instance:
      func 0x380 TIME_FILL   75
      func 0x010 POLL        74
      DISPLAY_FILL            0        (reference: 87)
      FORMAT_FILL             0        (reference:  7)
  Reference for a good run is POLL 87 / TIME_FILL 88 / DISPLAY_FILL 87 /
  FORMAT_FILL 7 in 45 s, so POLL and TIME_FILL are at very nearly the right
  rate and the display CONTENT is entirely missing.  The screen should show
  the clock and nothing else -- exactly the symptom trap 7 describes for a
  DEU whose formats never loaded.
- WHY I GOT IT WRONG: the headless runs all used --discrete-b 20000000,
  which is GPC 1 with NO CRT SELECTED -- the non-menu path, chosen so the
  SSL loads without keyboard entry.  With no CRT selected GPCIPL never
  drives a display, so "deu: commands 0, ipled false" was a property of MY
  TEST CONFIGURATION and said nothing about the machine.  I then quoted it
  as evidence the display was dead.  A counter that reads zero because the
  feature was switched off is not a measurement of the feature.
- SO THE STATE IS BETTER THAN REPORTED: GPCIPL is alive on the DK bus,
  polling and time-filling, while the SSL is stalled in FCMMOVE's
  alternate-buffer wait.  Those are consistent -- GPCIPL's display loop and
  the SSL's load run on different processors.
- TRAP REPEATED, THIRD TIME TODAY: `pkill -f 'electron ... meds'` MATCHED
  ITS OWN COMMAND LINE and killed the shell (exit 144).  Use a bracket
  pattern -- pgrep -f '[m]ain.js meds' -- as the handoff already says.

### [2026-08-27] Target: [problems.md]
- USER CONFIRMED THE MEDS RESULT WITH HIS OWN EYES: "I just saw a clock."
  That matches the wire counts exactly (TIME_FILL + POLL arriving, no
  DISPLAY_FILL or FORMAT_FILL), so the measurement stands despite the
  stray yaGPC2 processes that were live on the bus during it.  Five of
  those were leftovers of mine from earlier runs -- kill them before
  measuring, and use BRACKET patterns (pgrep -f '[m]ain.js meds'), since
  `pkill -f 'electron ... meds'` matched its own command line and killed
  the shell (exit 144) for the third time today.
- THE STALL IS A DEADLOCK, and the traces pin it exactly.  In the SSL era
  (t > 18 s) there are exactly TWO MSC starts and TWO BCE starts:
      MSC0  PC<-07374  (FCMINMSC)  at 18.76 s and 18.93 s
      BCE18 PC<-07362  (FCMINBCE)  at 18.76 s
      BCE18 PC<-0736c             at 18.93 s
  and NO THIRD of either.  #SST stores a good status (bst=00000000) to
  0x0731a ten times, so the BCE's reporting side works.
- SO: FCMMOVE sits in its "WAIT FOR ALTERN. BUF LOAD TO FINISH" loop
  (NIA=072b1, R05=FCMMONE) waiting for a buffer load that requires another
  BCE cycle; the BCE has parked on the #WAT that ended its second chain;
  and the only thing that can restart it is the CPU, which is inside that
  wait loop.  Neither side can move.
- WHICH NARROWS THE QUESTION TO THE CHAIN'S TERMINATION.  FCMINSSL writes
  #WAT instead of `#BU <other buffer>` only when `CHI R7,1` says this is
  the LAST load block of the batch.  The dumped FCMIBLK2 ended in #WAT.  If
  our R7 reaches 1 earlier than it should, the chain stops while FCMMOVE
  still expects an alternate-buffer load.  THAT is the next thing to
  instrument -- R7 at the point the terminator is chosen -- not the mask,
  not the tape, not the phase build.

### [2026-08-27] Target: [problems.md]
- CLEAN BUS-LEVEL A/B, AND IT INVERTS MY EARLIER REPORT.  MEDS restarted
  for each, one GPC only, counted with dk5.py over 45 s:
      A  original tape + BOOT-stamped.fcm : POLL 86 TIME_FILL 81
                                            FORMAT_FILL 8  DISPLAY_FILL  7
      B  new tape + BOOT-full.fcm         : POLL 86 TIME_FILL 81
                                            FORMAT_FILL 8  DISPLAY_FILL 83
      reference (2026-08-25)              : POLL 87 TIME_FILL 88
                                            FORMAT_FILL 7  DISPLAY_FILL 87
  USER CONFIRMED VISUALLY: "B rendered screens, A did not."  So the
  REBUILT PHASE 2 PLUS THE AP-101S FIXES RENDER AT ESSENTIALLY REFERENCE
  RATE, and the original tape is now the one that does not.
- MY EARLIER "B GIVES 0 DISPLAY_FILL" WAS CONTAMINATED.  Five stray
  yaGPC2 processes of mine from previous runs were live on the multicast
  bus during that measurement.  I noticed the risk, wrote it down, and
  reported the number anyway.  Kill every leftover and verify by PID
  before any bus measurement -- pkill -f cannot be used here because the
  shell's own command line contains the target text, which killed the
  shell (exit 144) twice; capture $! and kill by PID.
- ALSO DISPROVEN, and it was mine: "the SSL deadlock starves the display".
  Both tapes give IDENTICAL --deu-model counts at both step counts (1066
  at 40M, 1133 at 150M), including the tape where the SSL never runs.  And
  --deu-model cannot answer bus questions at all -- trap 7 records it
  seeing 518 fills while the wire saw none.  Four long runs spent on an
  instrument that could not discriminate.
- ONE VARIABLE REMAINS between the user's clock-only run and my B run:
  theirs used --discretes with discretePanel.py, mine used yaGPC2's
  built-in discrete defaults.  Trap 12 is exactly this class -- a panel
  publishing 0 for register B bits 6-7 zeroes the DEU_ID field and stops
  GPCIPL choosing a display bus.  That is the thing to check next.

### [2026-08-27] Target: [problems.md]
- THE DISPLAY HAS A ~30-SECOND WARM-UP, and that explains every confused
  observation in this thread.  Three consecutive 30 s dk5.py windows on one
  continuous run (new tape, --bce-network, --real-time --rt-factor 1):
      window 1 (0-30s)   POLL 35  TIME_FILL 36  FORMAT_FILL 0  DISPLAY_FILL  0
      window 2 (30-60s)  POLL 64  TIME_FILL 59  FORMAT_FILL 8  DISPLAY_FILL 61
      window 3 (60-90s)  POLL 58  TIME_FILL 59  FORMAT_FILL 0  DISPLAY_FILL 59
  So the first half-minute is CLOCK ONLY by design, then the formats go out
  and the screens draw and keep drawing.  User confirmed: "I see screens."
  Consistent with Table 2-2's 1m25s STBY-to-RUN-talkback -- the load takes
  real time at rt-factor 1.
- WHICH RETRACTS "B RENDERS, A DOES NOT".  Both of those samples started 8 s
  after launch and ran 45 s, so they straddled the ramp at different points;
  A's DISPLAY_FILL 7 is what the START of the ramp looks like, not a dead
  display.  I compared two runs at different points on a rising curve and
  reported it as a difference between the tapes.  A single-window count is
  meaningless here: SAMPLE THE TIME COURSE, or wait out the warm-up before
  counting anything.
- AND IT PROBABLY EXPLAINS THE USER'S EARLIER CLOCK-ONLY REPORTS TOO -- both
  times the observation was made inside that first window.  The panel and
  --discretes (trap 12) are no longer implicated by anything measured.

### [2026-08-27] Target: [problems.md]
- WARM-UP CORRECTED BY THE USER: the screen appears at MET 00:00:13 on the
  display's own ticking clock, WITH discretePanel.py attached and
  --discretes.  So the panel is not implicated (trap 12 is off the table),
  and my "~30 s" was my own panel-less run's wall-clock timing, not a
  property of the software.  I should not have generalised from it.
- R7 AT THE CHAIN TERMINATOR, MEASURED.  CHI R7,1 lives at 0x71d0 (found
  by scanning our own image for B5E7 0001; the second site, 0x71e3, never
  executes).  R7 counts load blocks DOWN FROM 26 -- exactly phase 2's load
  block count -- and the probe fires 22 times:
      26 25 24 23 22 21 20 ... 5
  and never reaches 1.  SO THE CHAIN DID NOT STOP BECAUSE IT RAN OUT OF
  BLOCKS.  It stopped with FIVE LEFT, i.e. at BLOCK 21.
- AND BLOCK 21 IS THE FIRST ABOVE-128K BLOCK, 14,822 halfwords, which
  EXCEEDS THE 8192-HALFWORD TEMP BUFFER.  So it is the first load block in
  the whole boot that needs the TWO-BUFFER SEQUENTIAL path: FCMMOVE moves
  the primary buffer, then takes IF (TH,TFCMSEQF,,NZ) and waits on
  FCMINSST for the ALTERNATE buffer's load, which never happens.
- THAT IS THE UNEXERCISED PATH, and it explains why everything up to here
  worked: blocks 1-20 are all under 8192 halfwords, so TFCMSEQF is never
  set and FCMMOVE never waits.  The deadlock is not about parity, the
  tape, or the phase build -- it is the sequential two-buffer receive that
  has never once run in this project.
- NEXT: trace how the SSL builds the SECOND receive sequence for a block
  that spans both buffers -- FCMINSSL:700-760 ORs the #RDLI skeleton with
  the partial count and stores through FCMRSADD, and lines 747-749 swap
  FCMRSADD between FCMIBLK1 and FCMIBLK2.  Whether that second sequence is
  built and started at all is the question.

### [2026-08-27] Target: [problems.md]
- THE DEADLOCK IS A PRODUCER/CONSUMER RACE, and the SSL's own structure
  shows it.  "START MSC/BCE PROCESSING" (FCMINSSL:551) runs ONCE PER
  PROGRAM, before the per-block loop: load MSC PC, load BCE PC, start MSC.
  FCMINMSC is only two instructions -- f400 7322 (@LF FCMIBUSM) and
  e400 0800 (the SIO) -- so it does not loop.  After that single start the
  BCE runs CONTINUOUSLY through the FCMIBLK1<->FCMIBLK2 chain while the CPU
  rewrites whichever buffer is not executing.
- THE #WAT IS PROVISIONAL.  FCMINSSL:727 ALWAYS terminates a freshly built
  sequence with #WAT (LHI R4,FCMMWAT / ST R4,0(R2)), and only later, at
  :752, overwrites it with `OHI R5,FCMMBU` + the other buffer's address.
  So the CPU MUST patch that halfword BEFORE THE BCE REACHES IT.  If the
  BCE gets there first it parks, and the only thing that could restart it
  is the CPU -- which is by then inside FCMMOVE's wait.  Deadlock.
- CONFIRMED BY THE DUMPS at both FCMMOVE entries: the sequences are
  WELL-FORMED, reading into both temp buffers --
      FCMIBLK1 f203 032a (#LBR 0x3032A = FIOMUWB2) / #RDLI 1 / #RDLI 7168
               c000 5020 (#DLYI+#SST) / f203 232a (#LBR 0x3232A = +0x2000)
               #RDLI 7168 / #LBR 0x33F2A / #RDLI 486 / #DLYI+#SST
               f000 7306 (#BU FCMIBLK2)
      FCMIBLK2 ... 0800 0000 (#WAT)    <- the unpatched provisional
  and FCMINSST reads ffff ffff, the CPU's armed sentinel.  Nothing is
  malformed; the CPU is simply late.
- WHY BLOCK 21 AND NOT EARLIER: it is the first block needing TWO MVH
  moves (14,822 halfwords across both buffers), so the CPU is busy far
  longer than for blocks 1-20 while the BCE keeps consuming.  That is
  exactly when a race like this first bites.
- SO THE NEXT QUESTION IS RELATIVE CPU/BCE SPEED, not correctness of any
  instruction.  This project has been here before -- the #DLYI pacing work
  and mmumodel's word-time pacing exist for the same reason.  Whether our
  MVH is too slow, our BCE too fast, or the MMU delivering without the
  real inter-block gaps, is measurable: instrument the time between the
  CPU patching the #WAT and the BCE fetching that halfword.

### [2026-08-27] Target: HANDOFF-FCMBOOT.md
- SSL deadlock localized exactly.  Steady state: CPU writes `#WAT`
  (FCMMWAT, unconditional terminator) at nia 071bb, then overwrites it with
  `#BU` at nia 071dd; BCE18 fetches that slot ~12 us later and ping-pongs
  between the two buffers (72f2..72fe -> 7306, 7306..7312 -> 72f2).  The
  `#BU` store is guarded by `CHI R7,1` and, critically, sits AFTER
  `BAL R4,FCMMOVE` in FCMINSSL -- so if FCMMOVE blocks, the `#WAT` is never
  overwritten.  On the final pass that is what happens: FCMMOVE blocks at
  072b1 ("WAIT FOR ALTERN. BUF LOAD TO FINISH"), BCE18 reaches the stale
  `#WAT` 6755 us later and parks at 072ff.  Confirmed by `iop procs`:
  BCE18 halt=1 busy=0 pc=072ff.
- The MSC is ALSO parked (halt=1 busy=0 pc=07378): it executed six
  instructions, hit its own `#WAT` at 07377 at t=18.93 s, and the CPU's
  last LOAD MSC BUSY (PCO 0x92040000) was t=18928919.7 us.  The MSC park is
  a consequence, not a cause -- the SSL's steady-state path self-chains via
  `#BU` and never wakes the MSC again, so once BCE18 hits a `#WAT` there is
  no recovery path at all.
- FCMINSST (0x731a) has TWO consumers that both wait on it and both reset
  it to FCMMONE: the SSL loop at #@LB70/071c2 and FCMMOVE at 072b6.
  Measured 23 `#SST`s against 28 resets.
- CORRECTION: the earlier reading "the BCE stops signalling after SST #10"
  was an artifact of `exec_SST`'s hardcoded `if (n++ < 10)` trace cap, not a
  fact.  The handshake runs to the very end.  Cap is now settable via
  YAGPC_SSTTRACE=N (non-numeric = uncapped).
- NOT a throughput problem: `iop_bce_receive` already drains every available
  word per slice and yields without blocking, which is the right design.
  Raising --max-steps from 120M to 600M left blocksRead/wordsOut/wordsTaken
  byte-identical (280 / 143364 / 116666).
- New instrumentation: YAGPC_WATCHHW=lo[-hi] (CPU stores into an address
  window, with NIA and timestamp), YAGPC_BCEPCTRACE=lo[-hi] (YAGPC_IOPTRACE
  narrowed to one window; the full trace is one line per slice and far too
  large), YAGPC_PROCDUMP (per-processor halt/busy/PC at end of run),
  iop_now_us() accessor.
- PRE-EXISTING, not from this work: test/test_debugger.sh,
  test_cpu_instr_exec, test_iop_bce_exec and test_iop_msc_exec already fail
  at fbc7671d8; verified by stashing src/ and re-running.

### [2026-08-27] Target: HANDOFF-FCMBOOT.md
- ROOT CAUSE of the SSL deadlock, traced end to end.  Chain, each link
  measured:
  1. FCMUPROT unprotects a load block halfword by halfword with
     `ISPB@# 0,0(R2,R1)`, R1 -> FCMIZCON, a Z-CON holding address + DSR.
  2. nia=0729b issues 107,842 ISPBs, EAs 0051e..50013 -- and NOT ONE of
     them lands on 3032a.  The only ISPBs that ever touch 3032a come from
     nia 00171/0017b/02c7c/02c80, which is GPCIPL's memory test doing
     unprotect/write/protect.  So the region is left protected.
  3. BCE18 then arms `addr=3032a count=7168` (the direct-to-upper-memory
     path, TFCMUPMF -- not a temp buffer).  Destination 3032a..31f29 is
     exactly the 7168 protected halfwords.  Every write is refused: 7172
     DMA store-protect violations, 7168 of 7171 distinct addresses in
     sector 6.
  4. Those violations are MASKED, so per AP-101S Fig 2-20 note '##'
     cpu_signal_dma_protect_violation sets CC to binary 10 WITHOUT taking
     an interrupt -- invisible to YAGPC_INTTRACE, which is why the first
     several passes over this looked like there was no interrupt at all.
  5. At t=22933402.0 one lands between the SSL wait loop's
     `L R4,FCMINSST` (071bb) and its `BCB` (071bd, db0e, m1=3).  CC==2
     satisfies NO mask bit in exec_BC/BCB/BCF/BCR, so the wait falls
     through with FCMINSST still ffffffff.  Measured directly: 23
     fall-throughs at 071be, 22 with cc=0 (legitimate) and exactly one
     with cc=2.
  6. The CPU is now an iteration ahead and rebuilds buffer 1 (72f2..72fe)
     while BCE18 is still executing the old, longer program there -- the
     old one had two #SST groups (072f9 and 07303) and chained on at
     07304; the rebuild puts a #WAT at 072fe, in the BCE's path.
  7. BCE18 parks at 072ff.  Only the MSC can restart a parked BCE ("The
     CPU cannot directly set a BCE's Busy/Wait bit", BCE POO 2.2) and the
     MSC has been parked at its own #WAT since t=18.93 s.  Deadlock.
- STILL TO ISOLATE: whether link 2 is a defect in the `@#` (Z-CON +
  DSR) effective-address computation itself, or upstream in what
  FCMIZCON is loaded with.  The measurement proves the unprotect never
  covers the destination; it does not yet say which of the two is at
  fault.  Only one ISPB decode-table entry exists
  (`11101xxx11111abb/X`), so both `@` and `#` forms go through
  cpu_g_ea.
- Ruled out along the way, each by measurement: BCE receive throughput
  (already drains all available words per slice, and 120M vs 600M steps
  gave byte-identical counters); stray IOP/DMA writes to FCMINSST (all
  46 IOP writes there are the 23 #SSTs x 2 halfwords); store-protect
  refusal of the CPU's own reset (prot=0 on every one); the
  storeProtectOverride flag (ovr=0 on all 7172 violations); #DLYI
  pacing (976 counts = 488 halfwords x 33 us, exactly the MMU word
  rate).
- New instrumentation: YAGPC_WATCHRD (fullword CPU reads of an address),
  YAGPC_BCTRACE (conditional-branch fall-throughs in a window, with mask
  and CC), YAGPC_DMAPROT (masked DMA store-protect violations, otherwise
  untraceable), YAGPC_PROTSET (protect-bit changes), YAGPC_ISPBTRACE
  (ISPB by EA window, with M1 and issuing NIA), YAGPC_MEMDUMP (main
  storage at end of run), IOP-side coverage for YAGPC_WATCHHW, and the
  receive destination address in the RECV ARM line.

### [2026-08-27] Target: HANDOFF-FCMBOOT.md
- The protected region the SSL DMAs into is its own 16K TEMP BUFFER, and
  the address is CORRECT.  FCMINSSL declares
  `FCMB1ZCN DC Z(,FIOMUWB2,0)` / `FCMB2ZCN DC Z(,FIOMUWB2+8192,0)`, and
  HALSTAT gives FIOMUWB2 as compool CVN_MM_UTILITY, CSECT #PCVNMMU
  offset 8, PHASE 2 ADDR 03032A, marked RESERVED.  So 3032a/3232a are
  right, and tools/patch_ssl_zcon.py's stopgap value is right too.
- Why it is protected: #PCVNMMU begins at 30322, which is EXACTLY where
  the sector-6 load block ends (30000..30321, len 0322 = 802).  Being
  RESERVED it holds no tape data, so no load block covers it, so
  FCMUPROT never unprotects it, so IPL's blanket protect stands.  The
  manual (AP-101S 2.5.3.3) confirms the blanket protect is right: IPL
  writes C6C6 above 20000 and the IOP writes C9FB below 1FFFF, both
  "with memory store protected".  The first sector-6 violation even
  carries val=c6c6, the IPL fill pattern itself.
- The 26 FCMUPROT invocations match our phase table exactly ("2:26LB@2300"
  = 26 load blocks), and every block cross-checks: sector 7 unprotects 864
  and the receives are 512+352=864; sector 5 unprotects 4956 and receives
  4608+348=4956.  The machinery is correct; the table simply has no entry
  covering the reserved buffer.
- SUSPECTED BUILD DEFECT, NOT AN EMULATOR DEFECT.  The load-block
  descriptor format that tools/stamp_ipl_phase_table.py documents has
  "bit 0 storage protect, bit 2 reserve", but
  ap101Utils/mmbstamp.py's LoadBlock.words() only ever emits 0x8000
  (protected) and 0x4000 (sot) -- there is no reserve bit -- and
  derive_load_blocks() drops pool-area extents outright
  (`if e <= pool: continue  # (re-supplies dropped)`).  FIOMUWB2 lives in
  a compool, i.e. a pool.  NOT YET PROVEN, and mmbstamp is Don's
  (nsts-sdl-dps), so read-only here.
- A/B with a diagnostic bypass (YAGPC_NO_DMA_PROTECT, off by default,
  never for fidelity runs) at 10M steps:
      enforced   wordsOut 143364 / wordsTaken  33796, MSC pc=07378
      bypassed   wordsOut  28162 / wordsTaken  28162, MSC pc=0119e
  Bypassed consumes every word 1:1 and the "MMU races 143K ahead of a BCE
  taking 33K" pathology disappears entirely.  A long bypassed run is slow
  in wall clock (real 4m39s vs user 33s at 10M steps -- the runner pacing
  through wait states, not CPU) so a full one has not finished yet.

### [2026-08-27] Target: HANDOFF-FCMBOOT.md
- ROOT CAUSE PROVEN BY EXPERIMENT.  PHASE02.lib's own symbol table has
  `#PCVNMMU  addr=hw 30322  length=16393 hw` and `FIOMUWB2 addr=hw 3032a
  length=0`, so the linker knows the CSECT's full extent.  But it carries
  no TEXT -- lib.extents has only 30000..3011d (285) and 30120..30320
  (512) in sector 6, together the 802-halfword load block -- and
  mmbstamp's derive_load_blocks() builds load blocks only from
  data-bearing extents ("Load blocks = contiguous checksum-group runs of
  the phase's linkedit image").  So RESERVED storage gets no load block,
  FCMUPROT never unprotects it, and IPL's blanket protect stands over the
  SSL's own two 8K buffers at 3032a and 3232a, which sit entirely inside
  #PCVNMMU (3032a + 16384 = 3432a).
- Supplying the missing unprotect at the moment FCMUPROT would have run
  (YAGPC_UNPROTECT=30322-3432a YAGPC_UNPROTECT_AT=18765000):
      DMA violations   7172 -> 7
      blocksRead        280 -> 730
      wordsOut/Taken  143364/116666 -> 373768/373768  (now 1:1)
      MMU commands        8 -> 16
      simulated time   23.3 s -> 31.4 s
  The BCE no longer parks and the MMU no longer races ahead of it.
- THE TIMING OF THE UNPROTECT MATTERS, and getting it wrong is
  instructive: clearing the bits at startup is undone by GPCIPL's memory
  test, which walks all of store doing unprotect/write/PROTECT at t=11.3 s;
  and refusing the protect outright makes the boot fail far EARLIER
  (blocksRead 0), because that test verifies store protection actually
  works.  Only a clear placed after the test and before the load behaves
  like the missing load block would.
- YAGPC_NO_DMA_PROTECT was a DEAD END and is not the fix: bypassing the
  protection check entirely stalls even earlier (blocksRead 55, position
  2/4/5, MSC pc=0119e) and is identical at 10M and 130M steps.  Enforcing
  protection on IOP writes is correct (426bca4d3).
- NEXT BLOCKER: the load now plateaus at 730 of 1155 blocks, with the only
  remaining DMA violations at 072cc/072cd (pe=18, just below FCMDATA at
  072e2) recurring every ~6.3 s of simulated time -- t=18764864, 25076651,
  31388552.  Not yet investigated.
- THE REAL REPAIR IS IN THE TAPE BUILD, not the emulator: a phase's
  RESERVED storage needs a load block so FCMUPROT covers it.  The
  descriptor format documented in tools/stamp_ipl_phase_table.py has
  "bit 2 reserve" for exactly this, and mmbstamp's LoadBlock.words()
  never emits it.  mmbstamp is Don's (nsts-sdl-dps) and was only read
  here.

### [2026-08-28] Target: HANDOFF-FCMBOOT.md
- With the #PCVNMMU unprotect supplied, the CC corruption is GONE:
  BCTRACE over the WHOLE machine (0-7ffff) finds NO cc=2 fall-through
  anywhere, against 78 legitimate cc=0 exits at 071be, and #SSTs rise
  23 -> 88.  The wait loop is healthy.  So the second stall has a
  different cause.
- Second stall is real, not step-limited: blocksRead 730, BCE18 parked at
  0730f (one past a #WAT), MSC parked at 07378, IDENTICAL at 200M, 260M
  and 320M steps.
- The 7 surviving DMA violations are all at 072cc/072cd, BCE 18, from
  BCE PC 07366.  Dumping that fixed BCE program decodes it:
      07362  fa00 72a8   base <- FCMBCEST (072a8)
      07366  f300 0001   #RDLI 1   -> stores at base + 2*BCE#
      0736a  0800        #WAT
  and FCMBCEST is `EQU *-36`, a fictitious base so 2*BCE# indexes real
  storage starting at 072cc.  IPL.sym.json confirms the layout:
  FCMBCEST/FCMBCEBT 072a8, FCMBCEAD 072c4, FCMMSCAD 072ca, FCMRCSEQ
  072d0.  So 072cc IS BCE 18's own read-status slot and must be writable
  -- the same protection gap as #PCVNMMU, but this time DS storage
  inside a LOADED csect rather than a whole reserved one.
- BUT UNPROTECTING IT MAKES THINGS WORSE, and that is the interesting
  part: blocksRead falls 730 -> 505, the 1:1 word ratio breaks
  (258566 out / 143366 taken) and BCE18 runs away to pc=00000 busy=1.
  The status word the MMU model returns is 0000 (it is the val= in the
  DMAPROT line), so while the write is refused the slot keeps its
  image value and the SSL proceeds; once the write lands, the SSL can
  see the zero and takes a different path.  Two entangled problems:
  the protection gap on the status table, and what our mmumodel reports
  as read status.
- A WRONG TURN worth recording: unprotecting 072a8..072cf (the whole
  fictitious-base span) is destructive -- it includes FCMBCEAD 072c4 and
  FCMMSCAD 072ca, the BCE and MSC PROGRAM PC POINTERS, which must stay
  protected.  Only 072cc..072cf is real table storage.
- iop_dump_procs now runs for EVERY stop reason, not only max-steps.  It
  was hooked to the max-steps branch alone, so a run ending on a halt or
  wait state -- exactly the one whose processor state matters -- printed
  nothing, which cost several runs.

### [2026-08-28] Target: HANDOFF-FCMBOOT.md, problems.md
- #LBR@ FIXED -- the last un-merged member of the BCE @-family.  It took
  operand + 2*BCE# as the base register instead of FETCHING through it.
  FCMINSSL settles it because both forms are used on THE SAME TABLE at THE
  SAME BIAS: FCMBCEBT is `EQU *-36` over `DC A(FCMIBLK1)` x2, and
      FCMINMMP 07362  fa00 72a8  #LBR@ 72a8
               07366  f300 0001  #RDLI 1
      FCMBCMMR 07372  f800 72a8  #BU@  72a8
  Without the fetch BCE 18's base became 072cc -- the branch-table entry
  itself -- so the #RDLI wrote its received word over the A(FCMIBLK1) that
  the #BU@ ten halfwords later was about to read.  Store protection had
  been refusing that write all along (072cc is below FCMDATA, so the SSL's
  own unprotect sweep never reaches it), which preserved the entry and hid
  the bug; unprotecting those four halfwords WITHOUT this fix sends BCE 18
  to pc=00000.  With the fix the 072cc violations disappear entirely.
  test_iop_bce_exec is 73499/74699 with AND without it -- measured both
  ways -- so the fixtures cannot arbitrate, exactly as already recorded for
  #BU@.  The flight software is the evidence.
- THE SECOND STALL IS A LOAD-BLOCK CHECKSUM FAILURE, and the flight
  software is behaving correctly.  At the halt:
      cpu: nia=0725c   (FCMSSLEX 0725a, i.e. `SSM FCMWAIT`)
      R7=6   R5=39e5 = 14821 = the sector-8 block's 39e6 length minus one
      FCMECNT  07332 = 0003   three checksum errors, the retry limit
      FCMCKERR 07333 = ffff   checksum error indicator set
  FCMSSLCK compares the computed checksum, counts failures in FCMECNT, and
  on the third gives up: it saves FCMSSLEX's address in TPSASSMA and
  executes `SSM FCMWAIT`, putting the GPC in the WAIT STATE.  That is why
  both IOP processors are parked -- the CPU stopped first, deliberately.
  So the 730-block plateau is not a hang: it is a detected bad load.
- NEXT: the failing block is sector 8, base 40000, length 14822 (descriptor
  8000/8680/39e6), the one big enough to need the two-buffer sequential
  path.  Whether the fault is our tape data, FCMMOVE's two-part move, or
  the checksum loop's own `AH@#`/`CH@#` addressing is not yet determined.
- YAGPC_PROCDUMP now also prints the CPU's NIA and R0-R7.  A parked BCE is
  only half a deadlock and the CPU half is what identified this one.
  YAGPC_MEMDUMP moved out of the max-steps branch for the same reason
  PROCDUMP was: this run ends on a stop reason, so it printed nothing.

### [2026-08-28] Target: HANDOFF-FCMBOOT.md, problems.md
- REAL BUG FIXED IN OUR TOOLING: patch_ssl_zcon.py patched only FCMB1ZCN.
  There are TWO Z-CONs -- `FCMB1ZCN DC Z(,FIOMUWB2,0)` and
  `FCMB2ZCN DC Z(,FIOMUWB2+8192,0)` -- because the 16K buffer is used as
  two 8K halves and FCMMOVE moves each with its own MVH.  With FIOMUWB2
  unresolved, FCMB2ZCN held A000/0000, which MVH's R2 arm resolves to
  02000, so the SECOND move sourced 7,654 halfwords of sector-0 rubbish.
  Measured before the fix: the destination matched the tape in exactly its
  first 7,168 halfwords -- the primary half -- and was zero after.
      MVH dest=40000 src=3032a count=7168 ok
      MVH dest=41c00 src=02000 count=7654 ok     <- wrong source
  After patching both (FCMB2ZCN A000/0000 -> A32A/0006 = 3232a) the moves
  read src=3232a and the sector-8 block at 40000 passes its checksum.  The
  SSL advances to the next block (R7 6 -> 5).
- NEXT DEFECT, and it is ours: the following block (0x439e6, len 3dc6) is
  copied to memory PERFECTLY -- 15814/15814 against the tape -- but SHIFTED
  BY ONE HALFWORD.  The tape block genuinely begins at linear halfword
  407552 (512-aligned) with stream[407552]=e9f3, and at that origin its
  checksum closes exactly: sum(first 15812)=a8cd, pad=0000, slot=a8cd,
  VALID.  Memory holds stream[407553...], i.e. the block minus its first
  word.  All the counts are right (1 + 7680 + 7680 + 454 = 15814, and the
  two MVHs 7680 + 8134 = 15814); only the phase is wrong.
- CAUSE, not yet fixed: the SSL deliberately issues a 1-word #RDLI to
  "CLEAR THE MIA BUFFER" (SHW FCMCLRSW) before each bulk read, expecting to
  discard a STALE word left latched in the adapter.  mia_get_data prefers a
  LIVE word over the latch ("a word actually on the bus OVERWRITES the
  adapter's buffer" -- a deliberate earlier fix, with its own regression
  story in the comment).  So whether that clear-read discards rubbish or
  eats the first real word is a RACE, and mmumodel makes it worse by
  starting the burst with ZERO latency: queue_words_paced sets
  burstStartUs = mm_now() and slot 0 is due immediately, so the first word
  of a read is on the bus the instant the command is processed.  Real
  hardware has seek/rotational delay, which is what gives the clear-read
  its window.  Block 1 wins the race (takes the latch), block 2 loses it.
  DO NOT invent a latency value -- find the real one first.
- New: YAGPC_MVHTRACE reports each MOVE HALFWORD with resolved source,
  destination, count and whether it completed.  A move that stops early on
  a store-protect violation leaves R1's count intact by design, so from
  outside it is indistinguishable from one that never ran.

### [2026-08-28] Target: HANDOFF-FCMBOOT.md, problems.md
- THE ONE-HALFWORD SHIFT IS PINNED, and the MIA model is NOT at fault.
  YAGPC_CLEARTRACE shows what each "CLEAR THE MIA BUFFER" one-word #RDLI
  consumes.  Almost all take c6c6 -- fill, i.e. a genuinely stale word,
  which is the point of the instruction.  One does not:
      CLEARREAD bce=18 took=c6c6 t=22844721.0
      CLEARREAD bce=18 took=e9f3 t=23687787.2   <- block 2's FIRST word
      CLEARREAD bce=18 took=c6c6 t=24473906.2
  and the RECV ARM for it is at t=23687787.2 as well: the read completed
  THE INSTANT IT WAS ARMED, because a live word was already queued.  (An
  earlier reading of a 16.8 ms wait was wrong -- it compared arm and
  completion times taken from two DIFFERENT runs.)
- The AP-101S manual carries the BCE POO as Part III, and section 3.4.1
  MIA-MIA BUFFER-BCE OPERATION settles the semantics in our favour:
  "once an entry is placed in the MIA buffer it stays there until either
  the BCE removes it OR THE MIA OVERWRITES IT WITH A NEW VALUE."  So a
  newly arrived word legitimately displaces the stale one, which is
  exactly mia_get_data's live-over-latch rule.  latchValid was true in
  every clear-read including the e9f3 one, so a stale word WAS present;
  the live word simply won, correctly.
- So the defect is solely WHEN mmumodel makes a transfer's first word
  available.  queue_words_paced starts a fresh burst at
  burstStartUs = mm_now() with slot 0 due immediately, i.e. zero latency
  after the read command -- physically impossible for a moving medium.
- TRIED AND REVERTED: giving a paced burst a one-block-gap lead-in
  (nextSlot = BLOCK_GAP_WORDS on a fresh burst).  It is principled -- every
  block on the medium is preceded by a gap, and the constant and the
  argument are already in the file -- but it did NOT fix this case, because
  the read command precedes the clear-read by about 20 ms and the gap is
  only 8.45 ms.  Reverted rather than left in: an unverified global timing
  change with no measured benefit is precisely the kind of thing that has
  misled this project before.  The right repair needs mass-memory-unit
  timing documentation, which is not in the tree (the AP-101S manual covers
  the CPU and the IOP/BCE, not the MMU's own latency).
- New: YAGPC_CLEARTRACE, reporting what each one-word clear-read consumes.

### [2026-08-28] Target: HANDOFF-FCMBOOT.md, problems.md
- THE ONE-HALFWORD SHIFT IS A PER-INSTRUCTION IOP STEPPING DEFECT, and it
  is the same one raised at the start of this session in answer to "does
  the BCE reception need a separate thread?".  Measured:
      BCE18 #SST                       t=23664142.0
      MVH dest=41c00 src=3232a c=7654  t=23664144.8
      BCE18 next instruction (#BU)     t=23670877.3   <- 6732 us later
  ap101_exec1 runs ONE iop_exec per CPU instruction, so FCMMOVE's
  7,654-halfword MVH -- a single emulator instruction that charges ~6.7 ms
  of POO time -- freezes the IOP while the simulated clock runs.
- Why that loses a halfword: the SSL positions the BCE MID-GAP on purpose.
  FCMSSLBS computes the delay as 639 - partial = (511 - partial) + 128,
  i.e. the rest of the MMU block plus HALF the 256-word inter-block gap
  ("128 = ONE HALF THE MMU BLOCK GAP IN HALF WORDS").  The following
  one-word "CLEAR THE MIA BUFFER" #RDLI is therefore meant to execute
  inside the gap, with nothing on the bus, and take the stale latch.  Ours
  resumes 6.7 ms late, after the gap, and takes block 796's first real word
  (e9f3) instead -- so the block lands one halfword out of phase and fails
  its checksum.
- MY EARLIER FRAMING WAS WRONG, twice over, and the correction matters:
  there is no per-load-block read command to be late.  YAGPC_MMUTRACE with
  timestamps shows only TWO read commands in the whole boot --
  55 blocks at t=2339402.3 and 225 blocks at t=18929049.8 -- and the entire
  PASS load streams from that single 225-block transfer.  The failing
  clear-read is 4.7 s into it.  So "missing MMU read latency" was not the
  problem, and reverting the lead-in was right for a better reason than the
  one I gave.
- A CANDIDATE BASIS FOR THE FIX, from the AP-101S manual's Part III (the
  BCE POO), section 3.4.1: "In either case the sampling process occurs at
  most once every 16.5 usec."  That is the BCE's own MIA-sampling rate, and
  16.5 us is already in the code as MTO_TICK_US.  With 26 round-robin pages
  (MSC + 24 BCEs + selftest) that implies one IOP pass per 16.5/26 = 0.635
  us of simulated time.  NOT IMPLEMENTED: stepping the IOP by simulated
  time rather than per CPU instruction changes global timing, and it is an
  architectural decision, not a bug fix -- flag it before doing it.
- mm_log now timestamps every line.  Every question about this unit has
  turned out to be a question about WHEN, and an untimed log cannot answer
  one; the two-read-commands finding above was invisible without it.

### [2026-08-28] Target: HANDOFF-FCMBOOT.md, problems.md
- THE IOP IS NOW PACED BY SIMULATED TIME, one slice per 0.5 us, instead of
  one slice per CPU instruction.  The rate is derived, not fitted:
  iopls_next_slice cycles 33 slices so each BCE gets one per cycle, and the
  AP-101S manual's Part III (BCE POO) 3.4.1 says a BCE samples its MIA
  buffer "at most once every 16.5 usec".  16.5 / 33 = 0.5 exactly, and
  16.5 us is already MTO_TICK_US.
- Each slice is taken with cpu.elapsedTimeUs SET TO THE TIME THAT SLICE
  FALLS AT, and the CPU's value restored afterwards.  That matters:
  catching up in slice COUNT alone fixes nothing, because what the bus
  cares about is WHEN.  Verified -- the outcome is IDENTICAL for pass
  intervals of 0.16, 0.25, 0.35 and 0.5 us, so it is the back-dating that
  does the work, not the rate.
- RESULT, on the same tape and command:
      old   3 clear-reads stole a real word;  FCMECNT=3, FCMCKERR=ffff;
            SSL retried three times and halted at FCMSSLEX (SSM FCMWAIT);
            blocksRead 730 (inflated BY the retries)
      new   0 clear-reads stole anything;     FCMECNT=0, FCMCKERR=0;
            SSL exits its phase loop NORMALLY and begins handing off to
            PASS; blocksRead 321 (no retries needed)
  The apparent drop 730 -> 321 is not a regression: the old figure was
  three attempts at a block that never checksummed.  The load now
  SUCCEEDS.
- NEXT FRONTIER, and it is new ground: the handoff takes a Program Check
  at NIA 07067 -- past #@LB14, the end of the phase loop, in the
  #@LB25/#@LB26 work-area-reprotect-and-PSA region -- and the vector at
  004c carries a PSW whose NIA is 0a3b, which has not been loaded, so the
  CPU executes c6c6 fill there.  Was previously unreachable.
- EASY TO REVERT, two ways: `git revert` this commit (it touches only
  ap101.c and ap101.h), or set YAGPC_IOP_PER_INSTR=1 at runtime, which
  reproduces the old behaviour EXACTLY -- verified bit for bit
  (t=47937627.5, nia=0725c, blocksRead 730, 3 stolen words).
  YAGPC_IOP_PASS_US=<f> overrides the interval.
- Suites: the same four fail as before, and test_iop_exec_processors,
  test_gpcops, test_schedule and test_iop_discretes all still pass.

### [2026-08-28] Target: HANDOFF-FCMBOOT.md, problems.md
- The post-load fault is a STORE PROTECT VIOLATION (program check code
  0007) at address 0009c, taken by the instruction
  `b8f0 009c` at 07065, which is `STH R0,TPSASINP` in the SSL's handoff:
      BALR R1,0
      ST   R1,TPSASRP     STORE THEM IN THE SYSTEM RESET PSW
      LH   R1,TPSASINP    GET THE PASS BOOTSTRAP ADDRESS
      STH  R0,TPSASINP    THEN, ZERO THE ADDRESS IN THE PSW   <-- faults
      STH  R1,TPSASRP
      LPS  TPSASRP
  So TPSASINP = 0009c.  The SSL unprotects TPSASRP on entry
  (`ISPB 1,TPSASRP` / `+2`, unconditional) but never TPSASINP.
- History of 0009c: IPL protects it; GPCIPL unprotects it at t=2001083
  (nia=00162, ISPB m1=1); and nia=30363 RE-PROTECTS it at t=4162864 as
  part of a sweep of 16,258 ISPBs over 00000..07f02.  Nothing clears it
  again, so the handoff store faults.  The vector at 004c then sends the
  CPU to 0a3b, which PASS's own load has overlaid with c6c6, hence
  "invalid instruction 0xc6c6".  The stale vector is a consequence; the
  store-protect is the cause.
- TRIED AND REVERTED: making the PSA carve-out permanent, i.e. refusing to
  SET the protect bit on the locations AP-101S 2.5.2.1 lists as ones that
  "must not be store protected" (power-off PSW, all OLD PSW locations,
  00A4-00A5, 00B0-00B1, 00C0-0102, 104-13F).  It removed the spurious
  faults at 000b0/000b1 -- which really are item 4 of that list verbatim --
  but it WRECKED the early boot: simulated time ran away to 4187 s in 60M
  steps with blocksRead stuck at 55.  The reading was wrong.  "Must not be
  store protected" is a rule for SOFTWARE, not a hardware interlock:
  GPCIPL's memory test sets those bits and reads them back (the manual
  lists a "Store Protect Bits Incorrect" test, VE62/HCMEMTST), so a
  hardware refusal makes it spin.  ageharness.c's own comment calling it
  "a permanent hardware carve-out" is an over-reading of the same
  sentence; it happens to work only because it is applied once, at IPL.
- STILL OPEN: who is meant to clear 0009c between nia=30363's sweep and
  the SSL's handoff.  Candidates not yet checked: whether that sweep
  should exclude the PSA, and whether PASS's own initialisation is
  supposed to have run first.
- YAGPC_INTTRACE now prints the interrupt CODE and a timestamp, and for
  code 0007 the faulting address from cpu->lastProtFaultAddr.  A bare
  "old=0048" names only the class, which is what made this take as long
  as it did.

### [2026-08-28] Target: HANDOFF-FCMBOOT.md, problems.md
- ANSWER TO "what clears 0009c": NOTHING IS SUPPOSED TO, and the sweep is
  NOT supposed to exclude the PSA.  Both halves of the question resolve
  against the guesses, and our emulation of all of it is faithful.
- The sweep code is GPCIPL RELOCATED.  At t=2006120 it does
  `MVH dest=30180 src=00180 count=1480` and thereafter runs from sector 6;
  at t=4063861 it runs `MVH dest=07c00 src=3037e count=768` from nia=3035e,
  which is FCMSSLPT (31744 hw = 07c00, size 768).  So nia 301e5 / 30363
  are original 001e5 / 00363 plus 0x30000, not a runaway into #PCVNMMU.
- The real sequence, all four passes measured:
      t=2.00s  nia=00162  m1=1 unprotect 00000..00104   (PSA)
      t=2.01s  nia=301e5  m1=1 unprotect 00104..07f02   (the rest)
      t=4.06s  nia=30363  m1=3 PROTECT   00000..07f02   (counts DOWN to 0)
      t=4.16s  nia=00507  m1=0 unprotect, table-driven, selective
  The last pass restores EXACTLY the manual's carve-out: 00000..00003
  (power-off PSW), then four halfwords per OLD PSW -- 00048..0004b,
  00058..0005b, 00060..00063, 00068..0006b, 00070..00073, 00078..0007b,
  00080..00083, 00088..0008b, 00090..00093, 00098..0009b -- then
  000a0..00139, which is TPSARES5 + BCE25 (00a4-a5) + counters (00b0-b1)
  + putaway (00c0-0102) + diagnostics (0104-013f).  There is NO group for
  any NEW PSW slot.  So protect-then-restore is the design, and it is
  correct.
- 0009c IS TPSASINP, confirmed structurally from MLIB80/TFPSA.asm:
      TPSASIOP  SPECIAL INTERRUPT OLD PSW    <- 0098
      TPSASINP  SPECIAL INTERRUPT NEW PSW    <- 009c
      TPSARES5  4 RESERVED                   <- 00a0..00a3
      TPSABC25  BCE 25 PARITY CHECK VALUES   <- 00a4
  which matches the restore boundaries 00098..0009b and 000a0..00139
  exactly.  AP-101S 2.5.2.1 lists only OLD PSW locations, so a NEW PSW may
  legitimately be protected and GPCIPL is right to leave it so.
- Where its contents come from: BCE 18 -- the MMU -- writes the PASS
  bootstrap PSW into it from tape at t=2344001, while it is still
  unprotected:
      WATCHHW IOP-write addr=0009c val=0a07 pe=18 t=2344001.0
      WATCHHW IOP-write addr=0009d val=0011 pe=18 t=2344034.0
  and the SSL later reads it back to find PASS's entry point.
- Ruled out: no ISPB anywhere uses an illegal M1 (counts are m1=0 21865,
  m1=1 16283, m1=2 27, m1=3 16261), so storeProtectOverride is never
  engaged.
- TWO NEW LEADS, both better than the sweep:
  (a) THE SSL'S OWN ENTRY BLOCK NEVER EXECUTES.  FCMINSSL lines 231-244
      do `ISPB 1,TPSAWORK`, `ISPB 1,TPSASRP`, `ISPB 1,TPSASRP+2` and end
      with `LPS TPSASRP` (*SYSTEM RESET) to re-enter at FCMMUIPL.  Tracing
      every ISPB over 0-7f02 for the whole run, the ONLY one the SSL
      issues is nia=07028, the #@LB13 work-area loop.  Those three entry
      ISPBs never happen.  (TPSASRP itself is low enough to fall inside
      the 00008..00043 restore, which is why the handoff's ST to it
      succeeds while the STH to 0009c does not.)
  (b) PASS'S LOW MEMORY IS NOT WHAT IT SHOULD BE.  TPSASINP points at
      0a07; at the halt 00a00..00a13 is zeros, and 00a34..00a3b reads
      `0015 0012 0000 c6c6 / 0016 0012 0000 c6c6` -- four-halfword table
      records with IPL FILL in the fourth slot.  So 0a3b, which the 004c
      vector still points at and which held working code at t=4.3s, is now
      a partly-uninitialised data table.  A load block does cover it
      (FCMUPROT unprotects 00602..04c6f), so the question is why that
      block's content is fill.

### [2026-08-28] Target: HANDOFF-FCMBOOT.md, problems.md
- CORRECTION to the previous entry: "the SSL's entry block never executes"
  was WRONG, and the cause was my own grep pattern (`nia=070|nia=071`,
  which cannot match `nia=06f`).  It executes, and issues exactly the three
  ISPBs the source calls for:
      ea=000b2 m1=1 nia=06fbf   TPSAWORK
      ea=00014 m1=1 nia=06fc7   TPSASRP
      ea=00016 m1=1 nia=06fc9   TPSASRP+2
  Decoding the loaded entry block gives the PSA addresses directly:
  TPSAWORK=00b2, TPSASRP=0014, and FCMMUIPL=06fd3 right after
  `cdf8 0014` = LPS TPSASRP.  Lead (a) is dead.
- What that reveals is the software's ACTUAL CONVENTION, and it is exact:
  UNPROTECT PRECISELY WHAT YOU ARE ABOUT TO WRITE.  GPCIPL's restore pass
  deliberately leaves 0014..0017 protected -- its groups run 00008..00013
  then 00018..00043, straddling it -- and the SSL unprotects exactly those
  four halfwords itself, immediately before storing the System Reset PSW.
  So the restore and the SSL fit together precisely, by design.
- Which sharpens the anomaly rather than explaining it: the same SSL writes
  TPSASINP (009c..009f, `DS 2F`) with NO unprotect, in BOTH releases --
  OI301700 lines 396-404 and OI340600 lines 388-398 are the same code.  The
  only other candidate, `ISPB 1,TPSASSMA`, sits on a path not taken (only
  three SSL ISPBs execute, and they are the three above).
- GPCIPL's restore is table-driven and unprotects [X, X+3] for X in
  {0048, 0058, 0060, 0068, 0070, 0078, 0080, 0088, 0090, 0098} -- the OLD
  PSW slots, four halfwords each, matching AP-101S 2.5.2.1 -- plus one
  stray halfword at 0087 that belongs to a NEW PSW slot and is the single
  irregularity in the whole pattern.  If the real pass covered eight
  halfwords per vector (old AND new) then 009c would fall inside it and
  everything would fit; our execution produces four.
- NEXT STEP, concrete: find and read that restore loop.  It is at nia=00507
  inside section GPCIPL (0..15392, module BILDNEW5), but BILDNEW5.asm is a
  wrapper -- its COPY list is MACSMITH, PSA, HISAM, FAILEXEC, STM0, STPMEM,
  INTHNDLR, STM1, STM2, STM3 -- and the ISPBs live in those: STM0 has 19,
  STPMEM 13, STM1 12, FAILEXEC 7.  Reading the loop settles whether four
  halfwords per vector is what the code says or what we mis-execute, and
  the stray 0087 is the thread to pull.

### [2026-08-28] Target: HANDOFF-FCMBOOT.md, problems.md
- 0009c IS PROTECTED BY DESIGN, and the emulator reproduces the software
  exactly.  Traced to the source, end to end:
    * The unprotect table is built by the $POF/$PON macro pair
      (MACSMITH.asm:508 and :540).  Each emits a pseudo-label
      `$POFnnn DS 0H` / `$PONnnn`, and the UNPRT macro turns each bracket
      into a (start, count) entry.
    * STM0.asm:118-146 is the loop that walks it -- UNPTRTN / UNPTRTN1 /
      UNPT, `ISPB# 0,0(X3,B3)` + `BCT R7,UNPT` -- and its own comment says
      "THIS SUBROUTINE UNPROTECTS MEMORY BASED ON THE UNPROTECT DATA TABLE
      (UNPRT). THIS TABLE IS GENERATED BY THE $POFF/$PON MACRO."  That is
      our nia=00507.
    * PSA.asm contains exactly ONE bracket: `$POF` at line 107, placed
      immediately AFTER `PSA EX4` -- i.e. after EX4's NEW PSW at
      009c..009f -- running to `$PON` at line 176 after SPSAEND.  That
      bracket is 00a0..0013f, which is precisely the 000a0..00139 we
      observe.  So 009c falls OUTSIDE the bracket deliberately.
    * The PSA macro itself (MACSMITH.asm:1307) only emits the new PSW's
      four halfwords; it brackets nothing.
    * The only explicit per-vector unprotects of NEW PSWs are STM0.asm
      264-279 and 637-643, for C1N, EX2N, MCHN and EX1N, each paired with
      an immediate `ISPB 2` re-protect.  There is no EX4N anywhere.
    * System reset does not help: AP-101S 2.5.3.2 lists what it resets --
      pending interrupts, internal timers, status registers, DSE registers
      -- and store protection is not among them.  So the SSL's own
      `LPS TPSASRP` (*SYSTEM RESET) at entry cannot clear it either.
- SO THE CONTRADICTION IS REAL AND FULLY SOURCED: nothing unprotects
  009c, and FCMINSSL's handoff writes it anyway, with identical code in
  OI301700 (lines 396-404) and OI340600 (388-398).  This is not an
  emulator defect in the protection machinery; every part of that machinery
  now checks out against the source.
- WHERE THAT POINTS: the SSL should probably not be on that path.  The
  handoff is guarded by
        LH  R2,FCMSYSID / TRB R2,X'0001' / BC 07-4,#@LB26
  where #@LB26 is the BFS exit (`LPS 0`).  We measured FCMSYSID = 000e, an
  EVEN system ID, so we fall through to the PASS path that writes
  TPSASINP.  The ID arrives as `NHI R7,X'000F'` -- "SYSTEM ID PASSED BY
  STP IN GPR 7" -- so the next question is whether 000e is the right value
  for this configuration and who put it in R7.  That is a much better
  thread than the protection state, which is now closed.

### [2026-08-28] Target: problems.md
- "THREE VOTED STORAGE PROTECTION BITS" vs "a single protection bit" is
  NOT a contradiction in the POO, and there is no second level of
  protection.  There is ONE LOGICAL BIT PER HALFWORD, held in three
  REDUNDANT physical cells and majority-voted.  Evidence, all from the
  manual itself:
    * 2-1.1: "...three voted storage protection bits are also associated
      with each halfword for the AP-101S...  The AP-101S/G has two storage
      protect bits per halfword."  Three-to-two across variants is a
      reliability trade (3-vote becomes 2-compare); it cannot be a change
      in the number of protection LEVELS.
    * The D100 READSP diagnose names them outright: "Bits 13-15 REDUNDANT
      Store Protect Bits for address in R1 (even HW)", "Bits 22-24
      REDUNDANT Store Protect Bits for address in R1 plus one (odd HW)".
    * Status register bit 6 is "MMP Store Protect Bits MISCOMPARE = 1
      (DRAM only)" -- a fault raised when the copies DISAGREE, which only
      means anything if they are meant to be identical.
    * "voted" is used the same way elsewhere for "IOP hardware voting
      logic" (PCI RM status).
  So the redundancy is invisible to programs except through D100 and the
  miscompare fault; no instruction can set the copies independently, which
  is why only single-bit instructions exist.
- OUR MODEL IS ALREADY RIGHT: mcm.h's `bool *protData` is one entry per
  halfword, and cpu_instr.c's D100 already synthesises the triples --
  bits 13-15 and 22-24, ACTIVE LOW (000 protected, 111 unprotected) --
  with a comment that already explains the voting.  STPMEM.asm:171 shows
  the flight software really does use it ("READ BY WAY OF THE
  DIAGNOSE-READ STORE PROTECT BITS CMDS").
- The one thing the single-bit model cannot express is a MISCOMPARE, where
  one copy of the three disagrees.  That is hardware-failure injection,
  not function; nothing needs it unless we ever want to exercise the
  self-test's miscompare path.

### [2026-08-28] Target: HANDOFF-FCMBOOT.md, problems.md
- FCMSYSID THREAD CLOSED: 000e IS CORRECT, and it is not the explanation
  for the TPSASINP fault.  Full chain, measured and sourced:
    * SSLCHECK.asm:145-150, immediately before `B$ SSLSTART`:
          LH  G7,BSLTPNTR+1   GET ITEM NUM
          SHI G7,1            SEND DEU ITEM # -1 TO SSL
      so the "system ID" the SSL receives is the DEU MENU ITEM NUMBER
      MINUS ONE.  Measured R7 = 000e0000 at nia=06fbc, hence FCMSYSID=000e
      via the SSL's `NHI R7,X'000F'`.
    * COMDATA.asm:130-131 initialises BSLTPNTR+1 to X'0011' (17), and
      BCE 18 duly writes 0011 there from tape at t=3026738.
    * The CPU then overwrites it with 000f (15) at t=7355453, nia=02031.
      That address is inside GPCRTOPT.asm's POLL45, under the banner
      "IPL DEFAULT LOAD -- NO DEU SELECTED":
          STH R3,DKBUS        DKBUS=0000 (NO DEU SELECTED)
          LHI R4,15
          STH R4,BSLTPNTR+1   BSLTPNTR+1=000F (LOADTABLE ID=15)
      15 is the DOCUMENTED DEFAULT for a no-DEU IPL, and 15-1 = 14 = 000e.
      Our --discrete-b 20000000 selects no CRT, which is exactly this path.
- So the guard `LH R2,FCMSYSID / TRB R2,X'0001' / BC 07-4,#@LB26` sees an
  EVEN id and correctly takes the PASS branch rather than the BFS `LPS 0`.
  The SSL is legitimately where it is, doing what it should, when it writes
  TPSASINP.  Both of the obvious escapes are now closed: the protection
  state is right (previous entry) and the system id is right (this one).
- STILL UNEXPLAINED, and now quite sharply: FCMINSSL stores to 0009c,
  which nothing in GPCIPL ever unprotects, on a path it is correct to be
  on, with a value (the PASS bootstrap PSW) that BCE 18 itself wrote there
  from tape at t=2344001 while it was still unprotected.  Every actor is
  behaving per its own source.  What is left to question is the ipl_fill
  blanket protect in ageharness.c -- the ONE part of this chain that is
  ours rather than the software's -- and specifically whether a real IPL
  leaves the PSA protected at all, given AP-101S 2.5.3.3 says only that
  memory is written "with memory store protected" and GPCIPL's own first
  act (nia=00162, t=2000764) is to unprotect 00000..00104.

### [2026-08-28] Target: problems.md, HANDOFF-FCMBOOT.md
- EXPERIMENT: removing the blanket PSA protect from ipl_fill (leaving
  00000..00139 unprotected at IPL) changes NOTHING -- byte-for-byte the
  same halt, nia=00a3b, blocksRead 321.  The reason is structural, and I
  should have said it before running: GPCIPL's own sweep at nia=30363
  re-protects 00000..07f02 at t=4162864, so whatever IPL leaves behind is
  irrelevant by the time the SSL runs.  The IPL protection state is not
  the lever.  Experiment reverted.
- The UNPRT TABLE READ OUT OF MEMORY confirms everything, and it is
  hand-tuned rather than mechanical:
      @05131 start=00098 count=4     -> 00098..0009b
      @05133 start=000a0 count=154   -> 000a0..00139
  It steps straight over 0009c..0009f.  And the stray 0x87 is a REAL entry,
  @0512b start=00087 count=1, explained verbatim in PSA.asm:
      *  ---------- EX1O+7 (USED BY HARDWARE) -----------
      *  LOCATION 87 IS USED BY UCODE-MUST BE 0 & UNPRT
  A table precise to a single halfword for a documented microcode
  requirement is not one that omits 0009c by accident.  OI301700 and
  OI340600 place the $POF identically, so it is not a release difference.
- ALSO RULED OUT: masking.  SSLCHECK does `SSM 7  MASK ALL INTRPS,REGSET=0`
  immediately before `B$ SSLSTART`, so the SSL runs fully masked -- but
  Figure 2-20 gives the Store Protect Violation (code 0007, row 33) a mask
  column of "--", i.e. NO MASK BIT.  Maskable program checks carry one:
  Fixed Point Overflow 20, FP Underflow 22, Significance 23, Instruction
  Monitor 34.  So store protect is unmaskable and our unconditional
  handling is right.
- REAL GAP FOUND ALONG THE WAY, unrelated to this bug: we never consult a
  mask for program checks at all.  cpu_check_interrupts honours
  psw_get_mach_check_mask for machine checks and intMask bit 0x20 for the
  instruction monitor, but `if (cpu->intPending.programCheck)` is taken
  unconditionally -- so Fixed Point Overflow, Floating Point Underflow and
  Significance are delivered even when their mask bits (20, 22, 23) say
  they should be ignored.  POO 2.5.2.3, already quoted in that function,
  says masked machine check AND PROGRAM interrupts do not stay pending.
  Nothing in this boot depends on it; worth fixing on its own merits.
- So every candidate is now exonerated -- protection state, system id,
  masking, IPL fill, MMU write semantics -- and FCMINSSL still stores to a
  location its own loader deliberately protected.

### [2026-08-28] Target: HANDOFF-FCMBOOT.md, problems.md
- THE 0009c STORE-PROTECT IS THE ONLY THING BLOCKING THE HANDOFF.  Tested
  by unprotecting just those four halfwords at t=18765000 -- i.e. as if
  PSA.asm's $POF had been placed BEFORE `PSA EX4` rather than after, which
  would make the bracket 0009c..0013f instead of 000a0..0013f:
      YAGPC_UNPROTECT=30322-3432a,0009c-0009f
  With that, FCMINSSL's handoff RUNS TO COMPLETION for the first time:
      R1=0a070000            PASS bootstrap address read from TPSASINP
      TPSASINP zeroed, address stored into TPSASRP, LPS TPSASRP issued
      control transferred to PASS at 0a07
  The GPC is out of the SSL and into PASS.  Everything else is unchanged
  (blocksRead 321, wordsOut=wordsTaken=164360).
- CAVEAT, stated plainly: this does NOT prove the recovered PSA.asm is
  wrong.  It proves only that 0009c's protection is the sole blocker.  The
  $POF-one-line-earlier idea is a HYPOTHESIS suggested by the fact that
  moving it makes everything work; the recovered source as we have it puts
  $POF after `PSA EX4` in BOTH releases, and the assembled UNPRT table
  agrees with that.  Confirming it needs an authentic IPL image to diff
  against, which we do not have -- the DASS memory.fcm dumps in PFS are
  PASS-era and do not contain GPCIPL's table.
- NEW FRONTIER, and it is well past anything reached before: PASS is
  entered at 0a07 and that memory is ZEROS.  Dumped 0a07..0a36: 44
  halfwords of 0000 (which decode as never-taken branches, so the CPU
  walks straight through them) followed by c6c6 at 0a33, which is the
  uninitialised fourth field of the 4-halfword records at 0a34.  So the
  entry ADDRESS is real -- BCE 18 wrote 0a07/0011 into TPSASINP from tape
  at t=2344001 and nothing overwrote it -- but no CODE was ever loaded
  there.  A phase-2 load block does cover the region (FCMUPROT unprotects
  00602..04c6f), so the question is why its content is zero.
- Note the entry is sector-relative: `BALR R1,0  GET THE CURRENT PSW'S
  BSR&DSR` captures the SSL's own BSR/DSR, so PASS is entered at 0a07 in
  whatever sector the SSL was running in.  Worth checking that assumption
  before assuming the low-memory image is at fault.

### [2026-08-28] Target: problems.md
- THE $POF/$PON CONVENTION IS SETTLED, and it is the mechanical one: the
  marker labels the location where the region BEGINS (the next item), not
  the item preceding it.  Tested on SSLCHECK.asm's minimal bracket
      $POF / SSLRTN DC H'0' / $PON
  where SSLRTN = 02d72.  The assembled table has
      @05187  start=02d72 count=1
  i.e. it starts exactly AT SSLRTN, the item after $POF.  The whole table
  is 40-odd entries ending in a count=0 terminator at @051b3.
- Consequence: PSA.asm's `$POF` after `PSA EX4` genuinely starts its
  bracket at 000a0 (= RESERVE3, confirmed by symbol), so 0009c is excluded
  deliberately -- now established twice, from the source and from the
  assembled data.  It also WEAKENS the "$POF is one line late in the
  recovered source" idea: the convention is unambiguous and holds
  everywhere else, so a misplacement would have to be a transcription
  error on that one line rather than a systematic misreading.

### [2026-08-28] Target: HANDOFF-FCMBOOT.md, problems.md
- SECTOR QUESTION CLOSED, our reading is right.  psw_get_nia applies the
  BSR only when bit 0 of the 16-bit IC is set, and the manual says exactly
  that: "When the high-order bit of a 16-bit branch address is a 1, a
  4-bit Branch Sector Register (BSR-PSW bits 24 through 27) is selected to
  replace the high-order bit.  When the high-order bit is a 0, an implied
  BSR containing 0000 is selected."  0a07 has bit 0 clear, so it is
  sector 0 and the BSR never enters into it.
- ROOT CAUSE OF THE HANDOFF FAILURE FOUND, and it is a MISSING MM-BUILD
  STAMP, not an emulator defect.  The symbols settle it:
      EX4N  0009c    Special Interrupt NEW PSW  == TPSASINP
      EX4   00a07    GPCIPL's EX4 interrupt handler
      PCH   00a3b    GPCIPL's Program Check handler
  TPSASINP holds `Y(EX4)` -- GPCIPL's own EX4 handler address, exactly what
  the `PSA EX4` macro emits -- NOT a PASS bootstrap address.  FCMINSSL
  reads it expecting the latter ("GET THE PASS BOOTSTRAP ADDRESS FROM THE
  SPECIAL INTERRUPT PSW") and then zeroes it, which is the behaviour of a
  value someone else stamped in.  Our IPL build never stamps it, so the SSL
  jumps to 0a07 -- and the phase-2 load has meanwhile written ZEROS there:
      WATCHHW IOP-write addr=00a07 val=e9f3 pe=18 t=2465804.0   GPCIPL code
      WATCHHW IOP-write addr=00a07 val=0000 pe=18 t=19042438.0  PASS load
  The CPU then walks 44 halfwords of 0000 (never-taken branches) into the
  c6c6 at 0a33.
- AND IT EXPLAINS THE EARLIER CRASH: PCH = 0a3b is GPCIPL's Program Check
  handler, which is why the 004c vector pointed there, and why PASS's load
  overwriting it turned any program check in the handoff window fatal.
  Two puzzles, one cause.
- CANDIDATE VALUE: PHASE02.lib's own entryAddress is 0x3500 bytes = hw
  01a80.  That is the obvious thing to stamp into TPSASINP, but NOT YET
  VERIFIED -- the MMB may derive the bootstrap address differently, and I
  have not found the code or card that does the stamping.
- SAME CLASS AS THE OTHER TWO BUILD GAPS: FIOMUWB2's unresolved Z-CONs and
  the unstamped IPL phase table.  Our toolchain reproduces the assembly and
  link but not everything the ground Mass Memory Build wrote into the
  image.
- STILL SEPARATE AND STILL OPEN: 0009c's protection.  Stamping TPSASINP
  would not help by itself, because the SSL still executes
  `STH R0,TPSASINP` to zero the slot afterwards, and that store faults.
  Both fixes are needed.

### [2026-08-28] Target: HANDOFF-FCMBOOT.md, problems.md
- 0009c DOES NOT AGREE WITH THE DASS DUMPS, and the dumps ARE usable for
  this after all -- 0009c is in the PSA, which no load block covers, so it
  survives into PASS runtime.  (.fcm is a raw big-endian halfword image
  from address 0, per load_fcm, so halfword N is at byte 2N.)
      halfword         ours (end of run)      DASS (post-IPL)
      0098..009b       10aa 4011 ff0c 0000    0000 0000 0000 0000
      0009c..009f      0000 0011 0000 0000    47e0 0000 000a 0000
  and our IPL.fcm AS BUILT has 0a07 0011 at 009c.  All EIGHT dumps agree
  with each other on 47e0 0000, so it is stable and authentic.
- WHAT THAT DOES AND DOES NOT PROVE.  The dumps are POST-IPL with PASS
  running, so 47e0 is the Special Interrupt vector PASS has INSTALLED by
  then, not necessarily what the MMB stamped for the SSL to read.  They
  therefore do NOT directly confirm the "TPSASINP is never stamped"
  hypothesis.  What they do prove is that a healthy post-IPL PSA differs
  from ours, and that 047e0 is a meaningful PASS address -- it is also one
  of the 26 phase-2 load-block bases in our own FCMUPROT list, which my
  earlier guess of 01a80 (PHASE02.lib's entryAddress) is not.  Drop 01a80
  as the candidate.
- SECOND DIVERGENCE, unlooked for: 0098..009b is the Special Interrupt OLD
  PSW, and it is ALL ZEROS in every DASS dump -- no special interrupt was
  ever taken in a healthy run.  Ours holds a saved PSW (10aa 4011 ff0c
  0000), and the INT trace bears it out: 2 interrupts through
  old=0098/new=009c.  So we take special interrupts the real machine does
  not.  Worth chasing on its own.
- THIRD DIVERGENCE: our memory at 047e0 holds TEXT -- 3234 3133 3231 3320
  3431 3332 ... 4350 4c54 ("CPLT") -- where the DASS dump has 0000 0000
  d574 0720 47e6 8006 and then c9fb fill (the IOP's own IPL pattern for
  0..1FFFF).  So the real system has that region largely UNLOADED while we
  load a string into it: our phase-2 content/placement differs from the
  real one in low memory, which is the same region the bootstrap question
  turns on.

### [2026-08-28] Target: HANDOFF-FCMBOOT.md, problems.md
- COMPARED OUR LOADED LOW MEMORY AGAINST latest.unlinkSSW_(PostIPL).
  USE THAT DUMP, NOT G9: the G9/G2/... dumps are other OPS configurations
  where low memory has been reused, and reading 047e0 out of G9 earlier
  gave a misleading answer.
- OUR PHASE-2 CONTENT IS SUBSTANTIALLY RIGHT.  In 512-halfword buckets:
      01a00  100.0% match      01c00  100.0% match
      01e00   84.0%            02c00   93.4%      02e00  89.6%
  01a00..01dff is 1024 halfwords BYTE-IDENTICAL to the authentic dump, so
  both the content and its placement are correct there -- there is no
  global offset error.
- BUT OUR LOAD COVERAGE IS BROADER THAN THE REAL ONE.  Where we differ, the
  dump is overwhelmingly c9fb -- the IOP's IPL fill, i.e. NEVER WRITTEN --
  while we have content: 03400 and 03600 are 0.0% match against 99% fill,
  04e00 is 0.2% against 100% fill.  So our load blocks write regions the
  real MMB leaves untouched.  Consistent with mmbstamp's own padding rules
  (FillRule, bank-tail fill) over-extending blocks.
- THE STAMPING HYPOTHESIS IS CONFIRMED, from the authentic image:
    * The real Special Interrupt NEW PSW is 47e0, and 047e0 in the dump
      holds CODE ending `cdf9 0014` = LPS TPSASRP -- a bootstrap that
      loads the System Reset PSW, exactly what FCMINSSL expects to reach.
    * 00a07 is 0000 in BOTH ours and the dump; from 00a06 onward the two
      agree exactly (0013 0000 0014 0012 ...).  It is a DATA TABLE, never
      code.  So jumping there was always wrong, and the defect is the
      VALUE in TPSASINP, not the memory at the destination.
    * Our image has "CPLT" text at 047e0 where the real one has that
      bootstrap, so our phase-2 image also differs there.
- WHAT IS NOT COMPARABLE: the SSL csect 06fbc..07361 is 100% c9fb in the
  dump -- never written since IPL -- so the real system's SSL does not live
  at our link's address.  Address-level comparisons of GPCIPL/SSL symbols
  against these dumps are meaningless; only PASS-era content compares.
  That also means our EX4=00a07 is OUR link's address, and the earlier
  "TPSASINP holds Y(EX4)" reasoning rests on the flight-software comment
  and our own image, not on the dumps.

### [2026-08-28] Target: HANDOFF-FCMBOOT.md, problems.md
- THE PASS BOOTSTRAP IS LOADED CORRECTLY AND THEN OVERWRITTEN.  Its
  signature is `cdf9 0014` = LPS TPSASRP, which the DASS SSW dump has at
  047ee.  In our run:
      WATCHHW addr=047ee val=e74f pe=18 t=3266417.0    GPCIPL-era load
      WATCHHW addr=047ee val=cdf9 pe=18 t=19840675.0   the bootstrap LANDS
      WATCHHW addr=047ee val=0001 pe=18 t=26708849.5   OVERWRITTEN
  and searching the whole 512K address space at the end of the run finds
  `cdf9 0014` NOWHERE, though it is present on the tape (byte 665160) and
  in PHASE02.lib (byte 79007).
- THE CAUSE IS OVERLAPPING LOAD BLOCKS.  Three receives cover 047ee:
      t=3120342.5   addr=03c22 count=9216 -> 03c22..06021   (GPCIPL era)
      t=19836055.0  addr=047e0 count=1024 -> 047e0..04bdf   THE BOOTSTRAP
      t=26445179.5  addr=03336 count=6656 -> 03336..04d35   OVERLAPS IT
  The bootstrap's own load block is based at 047e0 -- EXACTLY the address
  the DASS Special Interrupt NEW PSW points to -- and a later block
  spanning 03336..04d35 swallows it whole.
- Note 03336 is NOT among the 26 load-block bases FCMUPROT unprotected for
  the first phase (0051e, 005a2, 00602, 00676, 04448, 047e0, 04c6c, 08000,
  ...), and t=26.4 s is late, so it is very likely the SECOND phase
  (FCMNUMPH=2).  A later phase overlaying an earlier one is normal in a
  phased load; what is not normal is that the PASS bootstrap does not
  survive it, since the real post-IPL image plainly has it at 047e0.
- SO THE CHAIN IS NOW COMPLETE AND ALL OF IT IS BUILD-SIDE:
    1. the bootstrap loads at 047e0 and is clobbered by an overlapping
       later block, so 047e0 ends up holding "CPLT" text;
    2. TPSASINP is never stamped with 047e0, so the SSL reads GPCIPL's own
       Y(EX4) instead;
    3. it jumps to 0a07, which is a data table in BOTH our image and the
       authentic dump, and dies.
  Fixing (1) without (2) still leaves the SSL jumping to 0a07; fixing (2)
  without (1) makes it jump to clobbered memory.  Both are needed, and
  neither is an emulator defect.
- NEXT: confirm the 03336 block belongs to the second phase and work out
  whether its extent is wrong (mmbstamp padding over-extending, as the
  c9fb comparison already suggested) or its ORDER is -- i.e. whether the
  bootstrap should have been loaded by the later phase rather than the
  earlier one.

### [2026-08-28] Target: HANDOFF-FCMBOOT.md, problems.md
- CORRECTION, and it weakens two conclusions from the previous entries.
  FCMNUMPH DIFFERS BY RELEASE:
      OI301700  FCMNUMPH EQU 2   NUMBER OF SSW PHASES TO LOAD
      OI340600  FCMNUMPH EQU 3   NUMBER OF PHASES TO LOAD
  Our tape is OI340600, so loading THREE phases is CORRECT.  Measured and
  confirmed: FCMUPROT unprotects 126,210 halfwords, which is exactly
  107842 + 2394 + 15974, the three phase descriptors' totals, in three
  bursts separated by gaps at 18.76->25.71 s and 25.73->26.05 s.
- CONSEQUENCE 1: phase C's block `addr=3336 len=6982 -> 03336..04e7b`
  LEGITIMATELY overlays phase A's `addr=47e0 len=1164 -> 047e0..04c6b`.
  So "the bootstrap is wrongly clobbered" is NOT established -- in
  OI340600 that region is meant to be overlaid.  What is established is
  only that after our load, no copy of the 047e0 routine survives.
- CONSEQUENCE 2: the DASS dumps have IPL FILL where phase C loads (03400
  and 03600 are 99% c9fb, 0% match), so those dumps are from a TWO-phase
  load -- either an OI301700-era system or a different system-ID/LOADTBL
  selection than our default item 15.  CROSS-COMPARING LOW MEMORY WITH
  THEM IS THEREFORE UNSAFE, and the earlier "our load coverage is broader
  than the real one" conclusion is withdrawn: the extra content is phase
  C, which that dump's system never loaded.
- WHAT SURVIVES the correction: phase A's content at 01a00..01dff is 1024
  halfwords BYTE-IDENTICAL to the dump, so our phase-A image and its
  placement are right; and 00a07 is a data table in both, so jumping there
  was always wrong whatever the release.
- NEW LEAD, and it fits OI340600 rather than the dump: searching the whole
  512K for `cdfX 0014` (LPS TPSASRP) finds THREE sites --
      06fd1 = cdf8 0014   the SSL's own entry LPS
      07068 = cdf8 0014   the SSL's handoff LPS
      1bfef = cdfa 0014   PASS-side, inside phase A's block 12
                          (19a30..1c99b)
  So there IS a PASS routine that loads the System Reset PSW, at 1bfef,
  and it SURVIVES the three-phase load.  That is a far better candidate
  for what TPSASINP should point at in OI340600 than the OI301700-era
  047e0.  Next step: find the entry point of the routine containing 1bfef
  and check it against TPSASINP.

### [2026-08-28] Target: HANDOFF-FCMBOOT.md, problems.md
- STRONG VALIDATION OF OUR PHASE-2 IMAGE.  Resolving the DASS dump's
  interrupt vectors (16-bit, BSR=3 when the high bit is set) against OUR
  PHASE02.lib symbol table hits a symbol at OFFSET +0 EVERY TIME:
      ProgChk  ad5c -> 1ad5c  FPMIHPGM +0     EX0  9a30 -> 19a30  FIOERRLA +0
      SVC      b13a -> 1b13a  FPMSVC   +0     EX1  9a58 -> 19a58  FIOERRLB +0
      Clk1     ad24 -> 1ad24  FPMIHPC1 +0     EX2  b480 -> 1b480  FIOCMPLT +0
      Clk2     bed6 -> 1bed6  FPMIHPC2 +0
      SpecInt  47e0 -> 047e0  FCMLINIT +0
  Nine vectors, nine exact symbol starts.  Our phase-2 addresses match the
  authentic system.  (This also kills the previous lead: the LPS TPSASRP at
  1bfef is inside FPMIHPC2, the Clock-2 handler, not a bootstrap.)
- SO TPSASINP MUST POINT AT FCMLINIT (047e0).  SSSRC/FCMLINIT.asm confirms
  what it is -- PASS's initialisation entry, calling FCMINIOP and FPMDISP,
  initialising variables and the GPC ID, with a 1978 change note "MAKE
  FCMLINIT INDEPENDENT OF FCMINSSL".  Our phase 2 loads it at 047e0
  correctly (block 5: addr=47e0 len=1164), verified landing at t=19840675.
- THE CONTRADICTION, now release-independent and not resting on the DASS
  comparison at all:
      1. the SSL hands off to TPSASINP AFTER loading all FCMNUMPH phases
      2. TPSASINP must point at FCMLINIT
      3. therefore FCMLINIT must SURVIVE every phase
      4. our phase 3 overwrites 047e0..04c6b at t=26708849
  And phase 3's content there is NOT padding: PHASE03.lib carries a
  genuine TEXT extent 03336..04e78, 6979 halfwords, covering 047e0.  So
  the over-extension theory is wrong too.
- WHICH LEAVES THE PHASE ORDER, and our own tooling already flags it as
  the weak point.  tools/stamp_ipl_phase_table.py has
      IPL_PHASE_ORDER = (10, 2, 13, 3)
  "from FCMBOOT's prolog", with the docstring conceding "Assumed: that the
  ground Mass Memory Build laid the four phases' load blocks out in this
  order ... nothing contradicts it, but no original stamped table has been
  [seen]".  Something contradicts it now: in that order the SSL loads 2,
  then 13, then 3, and phase 3 destroys the one routine the SSL must jump
  to.
- SO ONE OF THREE THINGS IS WRONG, all build-side: the phase ORDER in our
  stamped table; our PHASE03 content; or the value that should be stamped
  into TPSASINP for a 3-phase OI340600 load.  The emulator is not
  implicated in any of them.

### [2026-08-28] Target: HANDOFF-FCMBOOT.md, problems.md
- PHASE REORDER WORKS, AND PASS'S INITIALISATION NOW RUNS.  Swapping the
  stamped phase descriptors so phase 2 loads LAST (patching FCMSSLPT's
  [1] and [3] at t=5 s), stamping TPSASINP=47e0, and clearing the PSA
  after GPCIPL's last protection activity:
      YAGPC_PATCH="5000000:7c03=006f,7c04=0009,7c05=1bc0,
                           7c09=001b,7c0a=001a,7c0b=2300,009c=47e0"
      YAGPC_UNPROTECT=30322-3432a,00000-0013f  YAGPC_UNPROTECT_AT=18765000
  gives:
      WATCHHW 047ee <- 0001 t=18507277   phase 3 now first
      WATCHHW 047ee <- cdf9 t=21520903   phase 2 LAST: FCMLINIT SURVIVES
      INT code=0007 atNIA=047f2          the CPU is INSIDE FCMLINIT
      finally R0=47f00000                further still, with the PSA open
  and the load stays clean: blocksRead 321, wordsOut = wordsTaken = 164360,
  reaching the handoff instead of halting at FCMSSLEX.  So the SSL's
  handoff completes and PASS's own initialisation executes.
- NEW GAP, and the same family as the others.  FCMLINIT's opening does
      OST R4,TPSAPWR / TPSAMCNP / TPSAPINP / TPSASNP / TPSAC1NP /
          TPSAC2NP / TPSAIMNP / TPSAENP / TPSAE1NP / TPSAE2NP /
          TPSAE3NP / TPSASINP
  -- an OR-store that merges BSR/DSR bits into new PSWs whose ADDRESSES
  must already be present.  Nothing in our build ever puts PASS's handler
  addresses into the PSA: no load block reaches below 0051e (phase 2),
  00654 (phase 3) or 024e4 (phase 13).  The authentic dump has them all
  (004c = ad5c = FPMIHPGM, etc.), so something in the real build writes
  them and we do not.  That is why a program check still vectors to
  GPCIPL's 0a3b.
- TWO INSTRUMENTATION FIXES ALONG THE WAY, one of which nearly cost an
  hour: cpu_store_fw never set lastProtFaultAddr, so a FULLWORD violation
  reported whatever the last HALFWORD violation had left there.  It was
  reporting 000b1 -- a location the self-test had legitimately
  protected/unprotected at t=4.3 s -- when the real faulting address was
  00004 (SPWRONN, the power-ON PSW).  Fixed.  Also added YAGPC_PATCH,
  timed halfword writes bypassing store protection, for standing in for
  what the ground Mass Memory Build would have stamped.
- CAVEAT ON THE REORDER: it is an experiment, not a proposed fix.  It
  contradicts IPL_PHASE_ORDER = (10,2,13,3), which stamp_ipl_phase_table.py
  takes from FCMBOOT's prolog and MMLOAD's IPL,PH=(10,2,13,3) card.  What
  it demonstrates is only that FCMLINIT surviving is NECESSARY, not that
  reordering is how the real build achieves it.

### [2026-08-28] Target: HANDOFF-FCMBOOT.md, problems.md
- SINGLE ROOT CAUSE FOUND, AND IT EXPLAINS EVERY OUTSTANDING SYMPTOM.
  PASS HAS ITS OWN PSA CSECT.  SSSRC/FCMPSA.asm:
      FCMPSA   CSECT
               TFPSA CSECT,PON=0,POF=0,SR=FCMINSSL,MC=0,
                     PC=FPMIHPGM,
                     SVC=FPMSVC,PC1=FPMIHPC1,PC2=FPMIHPC2,IM=FPMIHIM,
                     EI0=FIOERRLA,EI1=FIOERRLB,EI2=FIOCMPLT,EI3=0,
                     SI=FCMLINIT,DSR=0,BSR=0,PD=NO,
  It is at hw 00000, 422 halfwords, in PHASE02.lib.  It carries EVERY
  vector the authentic dump has, with DSR=0/BSR=0 matching the dump's
  0000 000a 0000 flags -- and SI=FCMLINIT is the 47e0 we went looking
  for.
- OUR TAPE BUILD DROPS IT.  mmbstamp's derive_load_blocks discards any
  extent ending at or below the phase's Z1 pool cursor:
      pool_next_hw(PHASE02) = 0024a
      00000..001a5  e<=pool -> DROPPED "(re-supplies dropped)"   <- FCMPSA
      001a8..00247  e<=pool -> DROPPED
      0051e..       kept
  The rule exists to drop Z1 ZCON pool re-supplies from a parent phase; a
  CSECT that legitimately lives at address 0 is caught by the same
  `e <= pool` test.  So phase 2's load blocks start at 0051e and PASS's
  PSA is never loaded.
- THAT ONE DEFECT ACCOUNTS FOR ALL FOUR SYMPTOMS:
    1. 0009c protected -- FCMUPROT unprotects each load block BEFORE
       loading it, so the missing PSA block is exactly WHAT WAS SUPPOSED
       TO CLEAR 0009c.  The question that started this is answered.
    2. TPSASINP holding GPCIPL's Y(EX4) -- it should have been overwritten
       by FCMPSA's SI=FCMLINIT.  MY "MISSING MM-BUILD STAMP" HYPOTHESIS IS
       WRONG: nothing stamps it, it is simply assembled into a CSECT that
       we fail to load.
    3. every PSA vector keeping GPCIPL's addresses -- 004c = 0a3b instead
       of ad5c = FPMIHPGM -- for the same reason.
    4. the "invalid instruction 0xc6c6 at 0x0a3b" crash, which is just
       symptom 3 being dispatched through.
- AND IT MAKES THE PHASE-REORDER EXPERIMENT UNNECESSARY: with FCMPSA
  loaded, TPSASINP points at FCMLINIT wherever FCMLINIT ends up, so the
  question of phase 2 loading last is separate and possibly moot.  Do not
  pursue the reorder as a fix.
- The defect is in ap101Utils/mmbstamp.py, which is Don's
  (nsts-sdl-dps) and was only read here.  Same family as the FIOMUWB2
  Z-CON gap and the unstamped IPL phase table: our toolchain reproduces
  the assembly and the link, but not the ground Mass Memory Build's own
  choices about what becomes a load block.

### [2026-08-28] Target: HANDOFF-FCMBOOT.md, problems.md
- PASS BOOTS AND RUNS.  Injecting the load block our tape build drops --
  PHASE02's FCMPSA, extracted straight from PHASE02.lib -- gets the GPC all
  the way into PASS:
      YAGPC_LOADBIN="27000000:0:fcmpsa.bin"          422 halfwords at 00000
      YAGPC_UNPROTECT=30322-3432a,00000-001a5        as FCMUPROT would
      YAGPC_PATCH="5000000:7c03=...,7c09=..."        phase 2 loads last
  Result: NO FAULT AT ALL.  The run ends on max-steps after 609 SECONDS of
  simulated time, with
      cpu: nia=19838   = FCMSWMON +28   PASS's SOFTWARE MONITOR
      iop: MSC pc=049e6 = #PCGBGPS +26  a PASS MSC bus program
      blocksRead 321, wordsOut = wordsTaken = 164360
  The CPU is in PASS's steady-state monitor loop and the MSC is running
  PASS's own bus programs, not GPCIPL's.
- THE EXTRACTED FCMPSA IS BYTE-IDENTICAL TO THE AUTHENTIC DUMP, which is
  what makes this more than a hack that happens to work:
      ProgChk @004c = ad5c 0000 000a 0000   SpecInt @009c = 47e0 0000 000a 0000
      SVC     @005c = b13a 0000 000a 0000   Clk1    @0064 = ad24 0000 000a 0000
      Clk2    @006c = bed6 0000 000a 0000
  Every one matches latest.unlinkSSW_(PostIPL) exactly.  Our PHASE02.lib
  has always held the correct PSA; only the tape build fails to emit a
  load block for it.
- WHAT IS STILL A HACK, and must not be mistaken for a fix:
    * the injection itself -- the real repair is in mmbstamp's
      derive_load_blocks, so the block is emitted and FCMUPROT unprotects
      and loads it in the ordinary way;
    * the PSA unprotect, which that load block would have done;
    * the phase reorder, which is still needed here only because phase 3
      overwrites FCMLINIT at 047e0.  With a real FCMPSA load block the
      reorder question is SEPARATE and still open.
- NOT YET REACHED: the DEU sees nothing (0 fills), so PASS is running but
  has not driven a display.  Whether that needs more simulated time, real
  MEDS rather than --deu-model, or something else is untested.
- Suites unchanged: the same four fail as before.

### [2026-08-28] Target: [problems.md]
- The `mmbstamp.py` fix is VALIDATED END TO END, with no injection.  `pool_low_hw()`
  plus the `parent_pool_lo` bound stops `derive_load_blocks` dropping PASS's own PSA
  csect `FCMPSA`.  Rebuilt tape `mmu2-fixed.mmv` (1163 blocks, was 1155); phase 2 now
  carries 27 load blocks, was 26, the new one being `00000..001a7` len 424 flags 0600
  (unprotected).  Booting it: `R1=47e00000` -- the SSL read `TPSASINP` and got
  `047e0` = `FCMLINIT`, straight from the loaded `FCMPSA`, and handed off.  No
  `YAGPC_LOADBIN`, no PSA unprotect, no `YAGPC_PATCH`.  The fix stays LOCAL in
  `~/donschmidt/nsts-sdl-dps`; no commit there, no PR, by the user's instruction.
- THE PHASE TABLE STEP: `stamp_ipl_phase_table.py` needs `--sym`, and the image to
  stamp is `newphase/PHASE01/PHASE01.fcm` with `PHASE01.sym.json` beside it.
  `BOOT-full.fcm` is that same 65024-byte phase-1 image; `Desktop/IPL/IPL.fcm`
  (1048576 bytes) is a DIFFERENT build and its `.sym.json` resolves 047e0 to GPCIPL's
  `MSG142`, which is meaningless for a PASS image.  Only the 07xxx `FCMINSSL`
  symbols are common to both.
- REMAINING BLOCKER, unchanged by the fix: phase 3's load block `03336..04e7b`
  (6982 hw; a genuine 6979-hw extent in `PHASE03.lib`, not a stamping artifact)
  overwrites phase 2's `047e0..04c6b`, which is `FCMLINIT`.  Order is 10, 2, 13, 3,
  so phase 3 wins, and the boot dies on `0xc6c6 at 0x48bf` INSIDE `FCMLINIT`.
- The DASS post-IPL dump says phase 2 should win: `047e0..04c6b` is fully intact
  there, 0 fill, with fill resuming at exactly `04c6c`; and PHASE02's own `047e0`
  extent matches it 719/719, 100%.
- REORDERING TO PUT PHASE 2 LAST DOES NOT WORK.  Descriptors are `[disp][count][addr]`
  and each carries its own displacement, so they permute cleanly, and all three
  copies (`FCMPTAD1/2/3` at 0x37E/0x47E/0x57E) were swapped to 10, 13, 3, 2.  The
  load then stops at `FCMSSLEX + 2` with only 70 blocks read -- the SSL exits early,
  thinking it is done.  Re-run with the unprotect moved to t=1000 to rule out the
  timing confound: identical, 70 blocks.  So this is not an artifact of the
  diagnostic patch's timing.
- The unprotect timing matters in its own right: `YAGPC_UNPROTECT_AT=1000` on the
  CORRECT order is WORSE than `=18765000` -- 281 blocks and `wordsTaken` 117178 <
  `wordsOut` 143876, i.e. words dropped, stalling in `#@LB117`.  Late is right.
- CORRECTION, and the number I first reported was misleading.  Comparing PHASE02's
  extents against the DASS dump I said sector 0 matched "60.1%".  That counted
  fill-vs-fill as mismatch.  The dump has TWO fill patterns: `C6C6` (49.3% of it)
  and `C9FB` (21.4%).  Excluding halfwords the dump left as `C9FB`, PHASE02 sector 0
  matches 11245/11550 = 97.4%.  Only 305 halfwords genuinely differ.
- Those 305 are worth chasing separately and are NOT random: `001aa..00247` is our
  values and DASS's SAME VALUES IN A DIFFERENT ORDER (ours has `F02B` at 001ba,
  DASS at 0022a) -- a table our link emits permuted; `0001c..00023` is 8 zero
  halfwords where DASS has PSA vectors; `04b48..04bad` is 102 halfwords we leave
  zero; the rest are scattered single-halfword address differences.
- Phases 10, 13 and 3 match the post-IPL dump at only 3.3%, 3.3% and 9.4% of their
  own extents, against phase 2's 97.4%.  The resident post-IPL image is essentially
  phase 2 alone.  Do not read this as "our phase 10/13/3 builds are wrong" without
  checking it the same way -- the overlays are not expected to be resident.
- Test suite: the same FOUR pre-existing failures (`test/test_debugger.sh`,
  `test_cpu_instr_exec`, `test_iop_bce_exec`, `test_iop_msc_exec`), identical before
  and after; there were seven at the pre-session commit `249669d91`.

### [2026-08-28] Target: [problems.md]
- CROSS-RELEASE COMPARISON, and it qualifies yesterday's numbers.  Everything built
  this session came from `OI340600/CON80`.  But `PFS/OI340700/README.md` states the
  DASS reports are OI34.07, NOT OI34.06 -- so `latest.unlinkSSW_(PostIPL)`, which I
  measured PHASE02 against, is a DIFFERENT RELEASE from the thing measured.  The
  prescription there is to clone `OI340600/` and overlay `OI340700/` over it.
- The overlay is 17 files, all present in OI340600 and all differing: `MLIB80/`
  `FCMBMTMC.asm` `FIOMDPS2.asm` `FIOMDPVU.asm` `FIOPBYMC.asm`, `SSSRC/FIOCBLKS.asm`
  `CDAP15.dfg`, and 11 `APPLSRC/` HAL/S files.  Note `CON80` is the LINKAGE decks
  (PHASE01..PHASE22, SSL, SSW -- 194 extensionless members), not source; source is
  `APPLSRC`/`MLIB80`/`SSSRC`.  No OI340700 build exists anywhere yet.
- Attributing the 305 genuine mismatches via `PHASE02.sym.json` sections:
    `04b48` 102 hw and `04bde` 11 hw fall inside `FIOCBLKS` (045e3..04c90) -- and
      `FIOCBLKS.asm` IS one of the 17 changed files.  The largest cluster is
      therefore a release difference, not a build defect.
    `0001c` 8 hw is in `FCMPSA`; `03944`/`03a66` in `FCMINSSL` (SSL>, 037de..03b83);
      `040d6` in `FCMCBLKS`; none of those modules is changed by OI340700.
    `001aa` 158 hw and `032e1` 45 hw are in NO CSECT AT ALL -- gaps our link leaves
      empty that the dump fills (`001aa` follows FCMPSA, which ends at 001a5).  That
      matches the README's own proviso about constants pointing outside the code we
      have, and the patch-area pattern.
  So the release delta explains the biggest cluster but NOT all 305.  Do not claim it
  explains them all without rebuilding.
- CSECT spans in PHASE02 OVERLAP (`FCMSAVE` 04960..04d77, `FIOADCNS` 04b6c..04e89,
  `FIOCBLKS` 045e3..04c90 all cover 04b48), so single-section attribution is
  suggestive, not conclusive.
- The `mmbstamp.py` FCMPSA fix is UNAFFECTED by any of this: a dropped load block is
  a stamping bug, independent of which release is being stamped.

### [2026-08-28] Target: [problems.md]
- THE PHASE-3-DESTROYS-FCMLINIT BLOCKER WAS NEVER REAL.  It was an artifact of a
  badly built `newphase/PHASE03.lib`, which has 10 extents including a 6979-halfword
  block at `03336` swallowing `FCMLINIT`.  Rebuilt correctly, PHASE03 has 26 extents
  and NOTHING below `04c70` -- it begins exactly where `FCMLINIT` ends (`04c6b`),
  leaving the same 4-halfword gap `04c6c..04c6f` the DASS dump shows as fill.  Two
  independently derived layouts agreeing on that boundary.  Against the dump,
  PHASE03 goes from 12.9% (newphase) to 77.53% (rebuilt).  So the `0xc6c6 at 0x48bf`
  crash, the failed phase reorder, and "phase 3 genuinely overwrites FCMLINIT" all
  trace to ONE BAD LIBRARY.  `newphase` was internally inconsistent: its PHASE02 was
  built correctly, its PHASE03 was not.
- THE BUILD RECIPE, recovered from the objects' own `.asmg.json` repro records rather
  than guessed.  Two ingredients decide it:
    `--src /tmp/claude-1000/sync/srcnoext/{SSSRC,APPLSRC}` -- the EXTENSIONLESS source
      mirror.  With `.asm`/`.hal`/`.dfg` names CON80 resolves DIFFERENT MODULES
      (`FCMBMT02`, `FIOACT02`, `FIOCYC02` instead of `FCMBMTPG`, `FIOACTMD`,
      `FIOCYCTB`), and the build silently scores 28% against the dump instead of 97%.
    `--src /tmp/claude-1000/sync/patchsrc` -- the PATCH DECKS.  `PCH02TXT` assembles
      from `PCH02SRC` and supplies `OPSZFILL`, `MFBZFILL`, `#T020000`, `PCH2SAIL`,
      `$X020001`; without it the link has 10 unresolved symbols.
  Plus `--incl <scratch>/INCL80_fixed` (symlinks, extensionless), `--mlib`,
  `--linklib <nsts-sdl-dps>/build/lib/runtime/{RUN,ZCON}`, `--pass-rel32` at the
  Virtual AGC archive.  All of `--pass-rel32`, `--linklib` and `--runlib` default
  CWD-RELATIVE, so they must be given explicitly from anywhere else.
- CONTROL VALIDATED: with the right recipe the OI340600 build reproduces the earlier
  measurement exactly, 11245/11550 = 97.359%, 305 mismatched.
- OI340600 vs OI340700 FOR PHASE 2 IS ONE HALFWORD, at `08f39`, which OI340700 gets
  right.  It fixes 1, breaks 0, changes NOTHING in sector 0.  So the release delta
  does NOT explain the 305 mismatches.
- WITHDRAWN: I attributed the 102-halfword `04b48` cluster to the release difference
  because it falls inside `FIOCBLKS`, one of the 17 changed files.  `FIOCBLKS` IS
  changed, but its change lands elsewhere entirely.  Section containment was
  suggestive and I treated it as conclusive.  Also withdrawn: `PCH02TXT` being
  unresolved does NOT explain the `032e1` cluster -- that was an artifact of MY
  broken build; the good build links the patch deck and `032e1` still mismatches, so
  it is a difference in patch CONTENT, not a missing patch.
- Of the 17 OI340700 files, only `FIOCBLKS` is a LINKED module in phase 2.  The four
  `MLIB80` ones are COPY/macro members; `CDAP15` is a display deck.
- Full 25-phase rebuild -> tape `mmu700.mmv` (2500 blocks, was 1163) -> `BOOT-700.fcm`.
  Phase 2 carries its 27 load blocks, phase 3 now 10.  `TPSASINP` holds `47e0` =
  `FCMLINIT`, matching the DASS dump.  THE Z-CON WORKAROUND IS NOW OBSOLETE:
  `patch_ssl_zcon.py` reports `832A 0006 -> 832A 0006`, i.e. the correctly built SSL
  already resolves `FIOMUWB2`.
- STILL NOT BOOTING.  Default run: 281 blocks, `wordsTaken` 117178 < `wordsOut`
  143876, hangs in `FCMINSSL` around `072af`.  No DMA protect violations and no
  interrupts at all -- a hang, not a fault.
- A SECOND `mmbstamp` GAP, same class as the FCMPSA one and now located exactly.
  Decode load-block addresses as `(sector<<15) | (addr & 0x7fff)` -- NOT
  `(sector<<15)|addr`, which is what I had and it shifts every sector>=2 block by
  0x8000.  With that fixed: phase 2's sector-6 block ends at `30321`, phase 3's
  starts at `3432e`, and `FIOMUWB2`'s 16K buffer `30322..3432a` lies in the GAP
  between them, in NO load block at all.  Both neighbours are protect=0, so the
  buffer should be unprotected too, and nothing unprotects it.
- CAUTION on the unprotect experiments: `YAGPC_UNPROTECT_AT=18765000` yields 400
  blocks and a clean halt at `FCMSSLEX+2`, but t=1000 and t=8000000 both give the
  281-block hang.  A pure protection bit should not be timing sensitive, so do NOT
  read the 400-block run as progress until that is explained.
- Pre-existing and NOT caused by the overlay: 14 `dfg FAIL`s in PHASE15/16/26; only
  3 of the failing decks are overlay files, the other 11 are not.  Not in the IPL set.

### [2026-08-28] Target: [problems.md]
- WITHDRAWN, and this was the user's catch: there is NO "second mmbstamp gap" at
  `FIOMUWB2`.  The region `30322..3432a` is 100% `C6C6` fill in the DASS post-IPL
  dump (16387 of 16393 halfwords; the other 6 are zero), so NOTHING loaded it on the
  real machine and no load block belongs there.  I had inferred one from the fact
  that both neighbouring blocks are protect=0.  That inference was worthless: the
  phase-3 neighbour `3432e..348a5` is ALSO 100% fill, because phase 3 is not resident
  post-IPL.  Only the phase-2 neighbour `30000..30321` is real content (65.3% fill,
  169 distinct values).
- WHAT `FIOMUWB2` ACTUALLY IS.  `APPLSRC/CVNMMUTI.hal:51`
  `EQUATE EXTERNAL FIOMUWB2 TO CDHV_BLOCKS$(1,1)`, and `INCL80/CSMCOM.hal:58`
  `1 CDHV_BLOCKS ARRAY(CSM_ROWS,CSM_COLUMNS) INTEGER` inside `STRUCTURE
  CDHV_RW_BUFR RIGID`.  `CVNMMUTI.hal:29-31` sets `CSM_ROWS 32`, `CSM_COLUMNS 512`,
  `CSM_ARRAY_SIZE 16384`, so the array is 32 x 512 = 16384 halfwords = THIRTY-TWO MMU
  BLOCKS OF 512.  Other compools size it differently -- `CVQMMUTI` 8 rows/4096,
  `CSAMMU` 26 rows/13312 -- so never assume the size; read the compool in question.
- It is reached almost exclusively through the HAL/S `NAME` construct, i.e. as a
  POINTER TO THE WHOLE ARRAY, not a reference to element (1,1).  The equate to
  `$(1,1)` just yields the base address.  So `FCMB1ZCN` and `FCMB2ZCN` are pointers
  to the two 16-block halves (offsets 0 and 8192), which is why there are two.
- CSECT layout confirmed two independent ways.  Walking the declaration:
  `CDHV_DUMMY`(1) + `CDHV_DGO_ADJ`(3) + `CDHV_RW_TSW` INTEGER DOUBLE(2) + `CDHV_RWCT`(1)
  + `CDHV_ERRCD`(1) = 8 hw, then `CDHV_BLOCKS` 16384, then `CDHV_CHK_SUM` 1.  And
  `PHASE02.sym.json` gives `#PCVNMMU` (module `CVNMMUTI`) as `30322..3432a`, 16393 hw,
  with `FIOMUWB2` at `3032a` = base+8.  Exact agreement.  My unprotect range happened
  to be right, but I took it from `patch_ssl_zcon.py`'s 16K assumption, not from the
  declaration.
- `#PCVNMMU` IS NOT AN EXTENT IN `PHASE02.lib` AT ALL -- the linker allocates the
  CSECT but emits no data, because its `INITIAL(0,3#0,0,0,BIN(16)'0',
  CSM_ARRAY_SIZE#(0),0)` is all zeros.  So there is nothing for `derive_load_blocks`
  to derive from.  This is NOT the FCMPSA bug class; do not "fix" mmbstamp here.
- OPEN, and more interesting than the thing I withdrew: if `FCMINSSL` really staged
  MMU blocks through this buffer during IPL, the post-IPL dump would show residue
  from the last block read.  It shows PRISTINE FILL.  So on the real machine that
  buffer was never touched during IPL, which is evidence against our model of how the
  SSL moves blocks -- and it means `YAGPC_UNPROTECT=30322-3432a` is compensating for
  something else entirely.  That, not a load block, is what to chase next.

### [2026-08-28] Target: [problems.md]
- ARE THERE MORE REGIONS LIKE `FIOMUWB2`?  MEASURED, AND NO -- it is a population of
  one.  Method, which is the reusable part: take every section the link ALLOCATES
  (`PHASE0n.sym.json` `sections`), subtract those carrying a data extent in
  `PHASE0n.lib`, then subtract those covered by any load block stamped into the IPL
  boot image.  With NO size threshold at all, across phases 10, 2, 13 and 3, the
  answer is three rows and they are the SAME region: `#PCVNMMU` `30322..3432a`,
  once per referencing phase (10 and 3 via `DEUIPLCP>`, 2 via `CVNMMUTI`).
- CORRECTION TO MY OWN FRAMING.  "DMAs into regions no load block covers" was a
  HYPOTHESIS I never observed.  `YAGPC_DMAPROT` reports ZERO protection violations
  and `YAGPC_INTTRACE` zero interrupts on these runs.  The only evidence was that
  `YAGPC_UNPROTECT` changed behaviour, which is much weaker than it looked.
- `YAGPC_PROTSET=3032a-3032b` shows the buffer's protect bit being TOGGLED during the
  run -- 1,0,1,0 -- and the two halfwords go out of step with each other.  So
  `FCMUPROT`/`FCMRPROT` ARE bracketing it dynamically; it does not sit statically
  protected.  That reframes the hang: not "nothing unprotects this buffer" but
  "the software brackets it and our blanket `YAGPC_UNPROTECT` cuts across the
  bracketing".  It also explains the thing that never made sense, that a PROTECTION
  BIT appeared to be timing sensitive.
- The SSL genuinely does stage through the buffer: `FCMINSSL.asm:526-534` loads
  `FCMBFZCN` into `FCMLBRTB` as the BCE's two DMA targets, and `FCMMOVE` (~1016-1042)
  `MVH`s from the primary buffer, then from the alternate when `TFCMSEQF` says the
  load block spans both.
- `latest.unlinkSSW_(PostIPL)` IS AN UNLINK OF THE DASS REPORTS -- a reconstruction of
  the LOADED IMAGE, not a live RAM snapshot.  Runtime residue never appears in it, so
  it CANNOT testify about what execution wrote.  I used it that way for one step
  yesterday and the conclusion was void.  In it `C6C6` is REAL CONTENT, not absent
  coverage: where our own build emits `C6C6` the dump agrees 100% (`09ed8`, `10000`,
  `1f05e`).

### [2026-08-28] Target: [problems.md]
- THE LINK ITSELF SAYS THE BUFFER MUST NOT BE PROTECTED.  `PHASE02.sym.json` carries a
  `storeProtect` map -- `{"unit":"halfword","ranges":[[lo,hi],...]}`, 161 ranges
  spanning `001aa..48889`.  NONE of them overlaps `#PCVNMMU` `30322..3432a`.  That is
  authoritative and it is a better oracle than anything I was inferring from load
  blocks or from the dump.  USE `storeProtect` FOR PROTECTION QUESTIONS.
- MECHANISM OF THE HANG, now understood: `ageharness.c` `ipl_fill()` (the `--ipl`
  path) protects EVERY HALFWORD of memory and then carves out only the PSA.  Any
  region no load block covers therefore stays protected forever, and `#PCVNMMU` is
  exactly such a region, so `FCMINSSL`'s DMA into the staging buffer is SILENTLY
  refused -- masked DMA store protect sets CC=10 with no interrupt (Fig 2-20 note
  '##'), which is why `wordsTaken` < `wordsOut` with zero violations traced.
- `YAGPC_IPL_PROTECT=0` added to `ipl_fill()` to start memory unprotected instead.
  DEFAULT IS UNCHANGED (only the literal string "0" switches it), and the four
  pre-existing test failures are unchanged.  IT DOES NOT WORK: boot dies immediately
  at `nia=00000` with nothing loaded, exactly the failure the existing comment
  predicts -- the Instruction Monitor fires once the software sets PSW mask bit 34,
  because every instruction then looks like it is executing from unprotected storage.
  So blanket-unprotect is confirmed wrong, not merely suspected.  Keep the flag as a
  diagnostic; do not make it the default.
- The middle option -- protect only the boot image's own sections, which
  `apply_load_protection()` already implements from `age->sym.sections` -- CANNOT BE
  TESTED AS THE RUN STANDS: `load_symbols()` runs before `ipl_fill()` (lines 275 vs
  323), but the `--ipl` invocation passes no symbol file, so there are no sections.
  Supplying `full700/PHASE01/PHASE01.sym.json` is the obvious next experiment.
- AN UNRESOLVED CONFLICT, and it should be settled before any fix is attempted.
  `YAGPC_UNPROTECT_AT=1000` unprotects the buffer long before any DMA, yet STILL
  hangs at 281 blocks -- so "the buffer is protected" cannot be the whole story.
  `YAGPC_PROTSET` shows only FIVE toggles across the whole run, 1,0,1,0,1, ending
  PROTECTED, and `YAGPC_ISPBTRACE` shows no `ISPB` naming that address, so I have not
  identified what writes the bit.  The callers are `ipl_fill`,
  `apply_load_protection`, the `ISPB` paths in `cpu_instr.c`, and my own timed
  unprotect in `ap101.c`.  FIND THE WRITER BEFORE THEORISING FURTHER.

### [2026-08-28] Target: [problems.md]
- `ISPB` HALFWORD FORMS (M1=000/010) ARE CORRECT AS WRITTEN.  Measured over a full
  IPL: M1=0 splits 204567 even / 204564 odd and M1=2 splits 145557 / 145546, i.e.
  ~50/50, so they genuinely address individual halfwords.  The idea that the halfword
  form can only reach the SECOND halfword of a fullword does not survive that, and the
  manual's wording (L9507) is "the halfword second operand" -- IBM-style for the
  halfword-sized OPERAND 2, not "the second halfword".
- `ISPB` INDEX HANDLING ALREADY MATCHES THE POO, and `cpu_instr.c:2248` already cites
  it: "This instruction will always have halfword alignment and will be excluded from
  automatic index alignment."  ISPB is declared `addrWidth=1`, so `indexWidth=1` and
  the scaling `regx = (reg >> 16) << (indexWidth - 1)` becomes `<< 0`.  Both halves
  hold.  Therefore the ODD EAs ARE GENUINE, not artifacts of a bad EA.
- THE FULLWORD FORMS ARE AN UNRESOLVED CONFLICT.  DO NOT "FIX" THIS WITHOUT READING
  THIS ENTRY.
    The POO says: "When M1 is 001 or 011, the low-order bit of the EA should be 0 and
      WILL BE IGNORED."  D100 READSP corroborates the hardware organisation -- its
      address "must be an even fullword boundary", returning bits for the even HW at
      R1 and the odd HW at R1+1.
    But AP-101S section 2, quoted in `cpu.c`, says the opposite for fullword operands
      generally: "bit 15 of a base register is significant when addressing fullword
      data.  Fullword storage operands may now be located on odd address boundaries."
    AND ALIGNING BREAKS THE BOOT: with `ea & ~1u` the load stops after phase 10 at 55
      blocks instead of 281, `nia=01df8`.  Restoring `fwAddr = ea` reproduces 281
      exactly.
  Gated as `YAGPC_ISPB_ALIGN=1`, NOT the default.  Open question for the user: WHICH
  MANUAL is the "low-order bit ignored" quote from?  If the AP-101 C/M POO, it is
  superseded by the S's section 2 and the current default is right; if the AP-101S
  POO, the two statements in the same manual conflict and something else is wrong.
- The odd-EA cases are SYSTEMATIC, only 60 of 34271 fullword-form ISPBs, from three
  GPCIPL instructions: `nia=007ac` (M1=1) and `nia=007c2` (M1=3) sweep `ea=x7ffd`
  once per 32K sector (07ffd, 17ffd, 27ffd, 37ffd, 47ffd, five times each), and
  `nia=0074d` (M1=1) does `ea=x0001` per sector with `R1=80010000`.  A sector's last
  fullword is x7ffe/x7fff, which NEITHER reading reaches from x7ffd: ours takes
  7ffd/7ffe, aligned takes 7ffc/7ffd.  Both look wrong, which is why this is logged
  as unresolved rather than decided.
- ALSO FIXED, and unrelated to the above: the old `ea & 0xfffe` was a 16-BIT mask on
  an EA already expanded to 19 bits, so it destroyed the sector (3032a -> 0032a).
  That was a real bug and correctly diagnosed; but the repair chosen was to drop
  alignment entirely, when `ea & ~1u` would have been sector-safe.  Two bugs were
  conflated as one.  Whatever is decided above, do not reintroduce `0xfffe`.
- Four pre-existing test failures unchanged throughout.

### [2026-08-28] Target: [problems.md]
- CORRECTION, AND IT REVERSES A WITHDRAWAL.  I reported ZERO DMA protect violations
  and on that basis withdrew the "DMA into a protected region" explanation.  THE
  MEASUREMENT WAS TOO SHORT.  Run to completion, `YAGPC_DMAPROT` reports 7170
  violations, and 7169 OF THEM ARE IN `#PCVNMMU` `30322..3432a`.  The original theory
  was right: the SSL's DMA into the staging buffer IS being refused, silently, which
  is the `wordsTaken` < `wordsOut` shortfall.  Do not trust a violation count from a
  truncated run -- `max-steps 200000000` reaches nowhere near it.
- `SPON`/`SPOFF` EVALUATED, AND THEY ARE NOT THE CAUSE HERE.  The semantic guess looks
  RIGHT -- `FIOMUWPG.asm` brackets its ENTIRE CSECT (`SPOFF` line 77 through `SPON`
  line 369, immediately before `END`), and that CSECT is a BCE program ending in
  `FIOMMSCW DC H'0'  MM'S WILL SEND 'MM UTILITY WRITE' SCW'S HERE`, i.e. a DMA target
  that must not be protected.  40 files use them.  BUT IMPLEMENTING THEM WOULD NOT FIX
  OUR PROBLEM:
    Of the 45 SPOFF/SPON-bracketed CSECT instances present in the IPL phases, 42 are
      ALREADY unprotected in the linker's `storeProtect` map.  `lnk101` derives
      protection per-CSECT from the CON80 deck classes
      (`ap101Utils/conlayout.default_protected`), not from assembly pseudo-ops, so the
      information is already there by another route.
    The three exceptions -- `FCMPROTD` (ph2, 22 hw), `FIOG9OPG` (ph2, 164 hw) and
      `FCMINMSC` (ph10, 1 of 4 hw) -- take ZERO DMA violations, so nothing is
      currently blocked by them.  They are a small open fidelity question, not this bug.
    And the failing region is not reachable by these pseudo-ops at all: `#PCVNMMU` is
      a HAL/S COMPOOL (`CVNMMUTI.hal`), so it would be `$POF`/`$PON` territory, not
      `SPON`/`SPOFF`.
  So: no request was sent to the ASM101S-port agent.  If they are implemented later it
  should be for fidelity, not to fix this.
- `FCMINSST` at `0731a` IS protected in phase 10's map, which looked alarming since it
  is the `#SST` completion flag the CPU spins on -- but it takes NO violations, so the
  BCE's store is getting through.  `FCMINSSL.asm` does not use `SPOFF`/`SPON`; it
  manages its own protection, and `FCMINSSL.asm:1140` names the mechanism:
  `FCMIZCON DS F   CHECKUM/UNPROTECT/PROTECT ZCON`.
- WHERE THIS LEAVES THE ROOT CAUSE.  `PHASE02.sym.json`'s `storeProtect` map does NOT
  cover `#PCVNMMU`, i.e. the link says that region must be UNPROTECTED.  `ipl_fill()`
  protects every halfword regardless, and the region has no load block to clear it.
  That blanket is the defect.  `YAGPC_IPL_PROTECT=0` is refuted as the alternative;
  the `sections` mode is the candidate still under test.

### [2026-08-28] Target: [problems.md]
- WITHDRAWN: "SPON/SPOFF is redundant, do not implement".  THE ARGUMENT WAS A
  NON-SEQUITUR, and the user named it.  I compared the two mechanisms AT CSECT
  GRANULARITY ("42 of 45 bracketed csects are already unprotected"), which is exactly
  the granularity the wholesale mechanism can express and the fine-grained one
  exceeds.  A comparison made at the coarser granularity cannot detect information
  that lives below it.  "The coarse mechanism helps more than nothing" does not
  imply "the fine mechanism is unnecessary".
- MEASURED: 8 OF THE 40 SPOFF/SPON FILES BRACKET SUB-CSECT REGIONS -- `TFPSA`,
  `FCMBMTMC` (CSECT 226, SPOFF 346, END 4043), `FIOMUWP9`, plus `FCMPROTD`,
  `FIOACTMC`, `FIOG9OPG`, `FIOMODMC`, `FIOPBYMC`.  The rest bracket a whole csect.
- THE CASE THAT SETTLES IT: `MLIB80/TFPSA.asm`, the PSA macro, emits `SPOFF`
  CONDITIONALLY at line 289 -- `AIF ('&X' EQ 'DS').NOSPOFF` -- immediately before
  `TPSASTRT` and the PSA storage (`TPSARES1`, `TPSAPWR` power-on PSW, the OLD PSW
  slots).  That is the AP-101S 2.5.2.1 "must not be store protected" carve-out which
  `ageharness.c` `ipl_fill()` HAND-CODES FROM THE MANUAL, because the loader that
  would have applied it is not modelled.  Being macro-conditional, a fixed hand-coded
  range cannot reproduce it.
- ALSO WITHDRAWN: the "three exceptions" framing.  `FCMPROTD` and `FIOG9OPG` carry
  `SPON` alone right after their CSECT card -- an explicit PROTECT -- and the linker
  independently marks them protected.  They AGREE; they were never exceptions.  Five
  files use `SPON` alone this way, which also corroborates the polarity.
- Message sent to the `ASM101S-port` session: track a protect flag against the
  location counter and emit per-halfword protect data per TEXT extent in the `.obj`,
  mirroring `libModule.py`'s `0xA1 PROT` record (u24 start byte addr, u24 halfword
  count, ceil(count/8) bytes MSB-first, written at `libModule.py:187`).  ASM101S
  emits NO protect information today, so `lnk101` has only deck-level `SET`/`CLEAR`
  plus the prefix guess.  Caveats sent with it: the semantics are INFERRED, no
  primary source found; 25 of 40 files have `SPOFF` with no matching `SPON`; the
  CSECT-start default is unsettled; emission can be macro-conditional so it must
  follow real expansion, not a source scan; precedence vs deck-level `SET`/`CLEAR`
  is theirs to decide.

### [2026-08-28] Target: [problems.md]
- ASM101S-port replied, reproduced the census independently, and DECLINED to
  implement -- correctly.  `ASM101Sa` is a C port whose entire value is being a
  verified drop-in replacement (542 modules byte-identical across OI340600/OI301700,
  plus 205 RUNASM against 1980s listings); adding a record type there turns every
  comparison from "identical" into "identical except the thing I added".  It has to
  land in `ASM101S.py` first and be carried into the port in a parity pass.  THAT IS
  RON'S CALL: it changes the official assembler's output format and needs coordinating
  with lnk101.
- MY CONTAINER PROPOSAL WAS WRONG, and I verified their correction rather than take
  it.  `libModule.py`'s `0xA1 PROT` is a LOAD MODULE record, raw binary.  An object
  module is 80-byte EBCDIC CARD IMAGES: `objectWriter.py:27-33` sets `card[0]=0x02`,
  EBCDIC type in columns 1-4, payload capped at 68 bytes, sequence in 72-80; a real
  `.obj` is `size % 80 == 0` with `\x02ESD` cards.  The right shape is a NEW CARD
  TYPE (they suggest `PRT`) carrying ESD id, u24 start, u24 halfword count and the
  bitmap, continuing across cards as TXT does.
- Their other notes, verified: `objcanon.py` dispatches `if typ == "ESD" / elif` with
  no else, so it SILENTLY PASSES unknown card types until taught -- a trap, since a
  format change would look clean when it is not (`ASM101S/objcanon.py`).  And
  `model101.py` has `repeatPass`, so location-counter transitions must be
  RE-COLLECTED per pass or they double.  Listings would not change, so the
  byte-identical listing guarantee survives as a regression test.
- THEIR SHARPEST POINT, and it cuts against my precedence guess.  Under "default
  protected" the 5 lone-`SPON` files are redundant; under "default unprotected" the
  31 `SPOFF`-with-no-`SPON` files are redundant.  Both groups cannot be meaningful
  under ANY fixed default, so the marks may be DELTAS on protection state established
  elsewhere -- in which case `SPON`/`SPOFF` would MODIFY deck-level `SET`/`CLEAR`
  rather than override it, the opposite of what I told them to expect.
  MY RESERVATION, to test rather than assume: "redundant" is not "meaningless".
  Defensive explicit marking is ordinary in assembly source, so one of the two groups
  may simply be belt-and-braces.  The delta reading is a hypothesis, not a finding --
  which is how they labelled it too.
- Census differences between us are heuristic, not substantive: they count 31 files
  with `SPOFF` and no `SPON` (I said 25) and 7 sub-CSECT brackets (I said 8; they
  required >3 lines after the CSECT card).
- They offered to prototype behind a never-enabled flag in the port so the shape can
  be seen before `ASM101S.py` commits to a format.  AWAITING RON'S DECISION.

### [2026-08-28] Target: [problems.md]
- Ron's design requirement for `SPON`/`SPOFF`, relayed via ASM101S-port: the
  implementation must be DISABLEABLE BY A COMMAND-LINE PARAMETER, and the switch need
  only disable THE EMBEDDING IN OBJECT FILES, not the tracking.  Verified their
  supporting detail: `ASM101S.py:1234` reads `--no-rtl-fixes` from `sys.argv` BEFORE
  the option loop, for the reason given at 1230-1233 (source files are read in-place
  as the loop encounters them); `--no-force-d` is at 1286.  So the convention is
  opt-out, default enabled -- `--no-store-protect`, not `--store-protect`.  A flag
  consulted only at `writeObjectModule` time does NOT need the early read; copying
  that pattern would be cargo-culting a fix for a problem it does not have.
- WHY SCOPING THE SWITCH TO THE EMBEDDING IS THE GOOD PART: listings are unaffected
  either way, so the 542-module byte-identical listing regression stays valid; and
  with the switch on, objects must come out BIT-FOR-BIT IDENTICAL to today's.  That
  is a free total regression -- sweep both releases with the switch and diff against
  the stored sweeps; any difference is the feature leaking.  ASM101S-port has current
  sweeps for both releases in `pfs-test/` and can run it against a candidate.
- MEASURED, AND IT SETTLES THE DIAGNOSTICS QUESTION.  Across all 40 files:
  balanced 4 (10%), `SPOFF` with no `SPON` 31 (78%), `SPON` with no `SPOFF` 5 (12%),
  mismatched-both-present 0.  So the obvious "unbalanced SPOFF/SPON" diagnostic would
  FIRE ON 36 OF 40 FILES, 90%.  Unbalanced is the NORMAL case, not the error case.
  That is a stronger reason for emitting no diagnostics than "the semantics are
  inferred": even granting the interpretation, the diagnostic would be wrong about
  the source nine times in ten.  It also protects the bit-identical property in the
  point above, since any diagnostic changes the listing.
- Their 31 is right and my earlier 25 was the loose figure; recount agrees.
- I put one caution back to them on the delta hypothesis: it holds only if
  "redundant" implies "would not have been written", and defensive explicit marking
  is ordinary in assembly.  A simpler reading also survives -- default protected, the
  31 `SPOFF`-only files never bother restoring because the CSECT ends, and the 5
  lone-`SPON` files are belt-and-braces.  Neither reading is clearly better, and they
  give OPPOSITE answers on precedence against deck `SET`/`CLEAR`, so it must not be
  decided by whichever gets written down first.

### [2026-08-28] Target: [problems.md]
- RON'S READING OF `SPON`/`SPOFF`, AND IT IS EMPIRICALLY CORROBORATED: the authors did
  not know what the protection defaults would be and simply added a mark where they
  had a specific block they cared about.  That retires the delta-vs-fixed-default
  argument rather than deciding it -- the source never encoded a global scheme, so
  both ASM101S-port's delta hypothesis and my default-protected reading were attempts
  to recover something that was never there.
- THE TEST, because his reading predicts CLUSTERING on hazard-prone code where a
  global scheme predicts none.  Across all 549 `.asm` in OI340600 SSSRC+MLIB80:
      overall marking rate                          40/549   7.3%
      files containing BCE opcodes                  17/39    44%
        (#CMD/#TDL/#RDL/#LBR/#DLYI/#SST/#WAT/#BU)
      files with NO BCE opcodes                     23/510   4.5%
  A TENFOLD ENRICHMENT on exactly the code that contains DMA targets.  By prefix:
  FIO 26/114 (22.8%), FCM 8/66 (12.1%), FPM 1/53 (1.9%), PCH 0/47, FAZ 0/16.
  A global scheme would not care whether a file contains BCE opcodes.  I WITHDRAW my
  default-protected reading; his is better supported than either of ours.
- CONSEQUENCE FOR PRECEDENCE: if the marks are local worries rather than a scheme,
  then asking whether they override or modify deck `SET`/`CLEAR` asks the source a
  question it was never written to answer.  That argues for the assembler RECORDING
  what it sees and reconciling nothing, leaving reconciliation to `lnk101` where it
  is visible.
- DECISIONS RECORDED (Ron, via ASM101S-port): (1) NO DIAGNOSTICS on unbalanced
  brackets -- my 36-of-40 figure is the recorded justification and they recounted it
  independently to the same numbers.  (2) The CSECT-start protection state becomes a
  SECOND command-line option, since a default cannot be inferred from source that
  never encoded one; default `on` (protected) in its absence.  Proposed spellings
  `--no-store-protect` and `--protect-default=on|off`, kept lexically far apart --
  `--no-csect-protect` beside `--no-store-protect` would be a script-level footgun.
- ACCEPTANCE CRITERION, not a nice-to-have: sweeping both releases with
  `--no-store-protect --protect-default=off` must reproduce the stored objects
  BIT-FOR-BIT.  That specific combination is the strong form of the test -- default
  `off` with suppression `on` is the configuration whose output would differ most if
  protect state leaked through a path ignoring the suppression; running it with
  `--protect-default=on` would be weaker for the same cost.

### [2026-08-28] Target: [problems.md]
- CONFOUND IN MY OWN CLUSTERING ARGUMENT, caught by ASM101S-port and confirmed: the
  BCE-opcode evidence and the name-prefix evidence ARE NOT INDEPENDENT.  72% of
  BCE-opcode files are FIO, so the prefix table largely RESTATED the opcode table
  instead of corroborating it, and I presented them as two sources.  The test that
  separates them is to hold the prefix constant.
- STRATIFIED WITHIN FIO, and the effect survives.  Our two counts bracket it:
                                  mine            theirs
      BCE files, marked           17/39  43.6%    20/42  48%
      non-BCE files, marked       23/510  4.5%    20/507  3.9%
      FIO WITH BCE, marked        17/28  60.7%    19/30  63%
      FIO WITHOUT BCE, marked      9/86  10.5%     7/84   8.3%
      stratified ratio            5.8x            7.6x
  The divergence is entirely the opcode heuristic -- fixed token list after
  stripping (mine) vs `startswith` on the opcode field (theirs), so `#BU@` and family
  land differently.  QUOTE THE RANGE, not either number: that two heuristics both
  land well above 1 with the family fixed is itself part of the evidence, and 5.8x is
  the conservative end.
- ASM101S-port has withdrawn the delta hypothesis as well.  Both of our global-scheme
  readings are now withdrawn in favour of Ron's local-worries reading.
- FOR THE DESIGN NOTE: state the non-reconciliation as a DECISION with its reason
  attached, not as a gap.  "The assembler records these and reconciles nothing"
  reads as an omission unless the reason is next to it -- the source contains no
  answer to reconcile toward, so inventing one would have the assembler assert
  something nobody can source.

### [2026-08-28] Target: [problems.md]
- HARNESS BUG OF MY OWN, and it invalidated three reported results.  The `sections`
  mode never ran: the binary was STALE for `ageharness.c` despite its timestamp being
  newer.  `touch src/ageharness.c && make` fixed it and the mode then reports
  `Load protection: 3624 halfword(s) over 7 section(s)`.  Everything I said about
  "protection strategy makes no difference" was measured on the default path.
- WITH THE MODE ACTUALLY APPLIED, the result is IDENTICAL to the blanket default:
  7170 DMA violations, 281 blocks, wordsTaken 117178 of wordsOut 143876 -- every
  figure the same.  So OUR LOADER'S PROTECTION MODEL IS IRRELEVANT TO THIS FAILURE.
  Under `sections`, `ipl_fill` leaves memory unprotected and only PHASE01's 7 sections
  are protected; `#PCVNMMU` is in phase 2 and nothing in our model touches it, yet the
  violations persist unchanged.
- WITHDRAWN: the `#SST` race framing.  It predicts violations immediately after a
  re-protect, and the timeline refutes that.  Last `ISPB` touching the buffer is
  t=11,673,913 -- an unprotect/protect PAIR 6us apart at `nia=02c7c`/`02c80`, and only
  on `3432a` (`CDHV_CHK_SUM`), which is the "open it briefly to write one word" idiom.
  First DMA violation in the buffer is t=22,956,997, from `pe=18` at `pc=07308`, the
  SSL's BCE read program.  ELEVEN SECONDS OF SIMULATED TIME APART.  Not a race.
- WHAT THE EVIDENCE SUPPORTS NOW: the SSL never opens the staging buffer before the
  BCE DMAs into it.  Either the flight software relies on that region never having
  been protected, or an unprotect step is not being reached in our emulation.  Chase
  WHICH of those before proposing a fix; both my previous explanations were withdrawn
  after being stated too confidently.

### [2026-08-28] Target: [problems.md]
- DON HAD ALREADY IMPLEMENTED THE CONSUMER SIDE.  `7fff229` "lnk101: carry
  store-protect ranges into .sym.json", Donald Schmidt, 2026-08-23 -- five days before
  this discussion.  He reached the `SPON`/`SPOFF` reading independently and pre-wired
  `lnk101` for it.  Two parties converging is not documentation, but it is stronger
  than one inference.
- `lnk101` NEEDS NO CHANGES.  `linker.py:333-334` reads the cards into
  `mod.protManaged`/`protRangesHw`; `storeProtectRangesHw()` (linker.py:810) applies
  the precedence "explicit ' PROT' ranges when the assembler captured SPON/SPOFF,
  else the csect's SET/CLEAR mark, else the name-class default", and FEEDS BOTH the
  `.lib` PROT records and the `.sym.json` map.
- `.lib` FILES ARE `lnk101`'s DOING: `--lib` / `saveLib()` (cli.py:69, linker.py:2509)
  -- "an AP-101 loadable module: CESD, per-extent text, RLD, store-protection,
  overlay/phase metadata".  The `.fcm` is the flat image of the same link and has no
  room for metadata; the `.lib` is where the structure lives.  All 235 extents in our
  `PHASE02.lib` already carry a per-halfword `protect` array and real `0xA1` records.
- FORMAT MISMATCH FOUND, and it would have FAILED SILENTLY.  `objectWriter.py:140`
  `writePRT()` emits a 0x02 OBJECT RECORD typed "PRT" with a binary bitmap keyed by
  ESD id.  `lnk101` reads a FREE-FORMAT CONTROL STATEMENT -- `objModule.py:1001`
  routes `card[0] == 0x02` to module records and everything else to `ControlRecord`,
  and `linker.py:319` scans only `controlStatements`.  A binary PRT record never
  reaches it: `protManaged` stays empty, the tape comes out byte-identical, no error.
  RON'S RULING: use Don's format.
- DON'S FORMAT, for the record: a control card, column 1 NOT 0x02 (blank), text
  `" PROT <csect> <s>-<e>[,<s>-<e>]..."`.  Ranges are CSECT-RELATIVE halfword offsets,
  HEX, END-EXCLUSIVE, and list the PROTECTED regions.  Same convention as HAL/S-FC
  PASS2's `" STACK <csect>"` cards (OBJECTGE.xpl), so there is precedent in the format.
  CRITICAL (linker.py:169-172): a csect named on a PROT card is FULLY SPECIFIED --
  an EMPTY range list means NOTHING in it is protected -- so emitting a card takes
  that csect out of the deck scheme entirely.  THAT SETTLES THE PRECEDENCE QUESTION
  WE SPECULATED ABOUT: Don has it as OVERRIDE, not modify.
- REMAINING GAP IS `mmbstamp`, not `lnk101`: `protection_lookup()` (mmbstamp.py:228)
  builds intervals from `sym["sections"]` plus the deck map and
  `patch_aware_default(name)`.  It never reads `sym["storeProtect"]["ranges"]`, the
  per-halfword map `lnk101` now computes with the full precedence.  Switching it
  should be a NO-OP TODAY (with no PROT cards both derive from the same tiers), which
  makes it verifiable now by rebuilding the tape and diffing, and it would then carry
  real data automatically once the assembler lands.

### [2026-08-28] Target: [problems.md]
- THE `mmbstamp` CHANGE IS NOT A NO-OP.  I predicted it would be and was wrong.
  Switching `protection_lookup()` to read `sym["storeProtect"]["ranges"]` (keeping
  section coverage for the None case, swapping only the flag source) changes the tape
  from 2500 to 2514 blocks.  REVERTED; the tape rebuilds byte-identical to before.
- WHY, and it is not the assembler: THERE ARE NO `PROT` CARDS YET.  The disagreement
  is between TWO INDEPENDENT IMPLEMENTATIONS OF "WHAT THE DECK'S SET/CLEAR SAYS" --
  `mmbstamp`'s `deck_protection()` (436 entries for phase 2) versus `lnk101`'s
  `placement.protected` as carried into `storeProtect`.  110 sections and 11947
  halfwords differ, IN BOTH DIRECTIONS:
      FCMINSSL  06fbc 934 hw   old protected -> new UNPROTECTED
      FCMSSLPT  07c00 768 hw   old protected -> new UNPROTECTED
      FCMLINIT  047e0 576 hw   old protected -> new UNPROTECTED
      #PCDTANN  48010 645 hw   old unprotected -> new PROTECTED
      #PCV2LIN  033aa 526 hw   old unprotected -> new PROTECTED
  The `#P*` flips are the class-default prefix (`#P` is in `_UNPROT_PREFIXES`) being
  overridden by a deck mark on one side and not the other.
- WHY IT WOULD PROBABLY HAVE BROKEN THE BOOT: `FCMINSSL`, `FCMSSLPT` and `FCMLINIT`
  becoming UNPROTECTED is exactly the condition `ageharness.c` `ipl_fill()`'s comment
  warns about -- the Instruction Monitor fires the moment the software sets PSW mask
  bit 34, because every instruction then looks like it is executing out of
  unprotected storage.  That is also the observed failure of `YAGPC_IPL_PROTECT=0`.
- SO ONE OF THE TWO DECK READERS IS WRONG, and that is worth settling on its own
  merits BEFORE anything is switched over.  It is independent of the `SPON`/`SPOFF`
  work: it would still be wrong if the assembler never emitted a card.  Do NOT land
  the `mmbstamp` switch until it is resolved, or the assembler's data will arrive on
  top of an already-divergent base and the two faults will be indistinguishable.
- Only `src/ap101Utils/mmbstamp.py` was touched in Don's repo, and it is back to
  carrying just the FCMPSA fix.  `ext/sim`, `ext/virtualagc` and `COMMON.out*` were
  already modified/untracked before I started and are not mine.

### [2026-08-28] Target: [problems.md]
- FCMIZCON CHASED, AND IT ANSWERS THE OPEN QUESTION.  `FCMINSSL.asm:1140`
  `FCMIZCON DS F  CHECKUM/UNPROTECT/PROTECT ZCON` is used three ways: checksum
  (844-852), (re)protect (925-931) and unprotect (968-974).  `FCMUPROT` (PROC at 964)
  takes R1 pointing at a LOAD-BLOCK DESCRIPTOR -- address at `0(R1)`, BSR/flags at
  `1(R1)`, length at `2(R1)`, the 3-halfword format -- builds a Z-CON from it and
  walks `ISPB@# 0,0(R2,R1)` down the length.  IT UNPROTECTS THE LOAD BLOCK'S
  DESTINATION, NOT THE STAGING BUFFER.  The SSL never unprotects `#PCVNMMU` at all;
  it assumes that region is writable.
- SO WHO PROTECTS IT?  `GPCERAS.asm:257-261`, GPCIPL's memory ERASE pass:
      GPCWR20  ISPB  0,0(R5,Z3)   UN-PROTECT HW
               STH   R6,0(R5,Z3)  SET TO X'NNNN'
               ISPB# 2,0(R5,Z3)   RE-PROTECT AND AUTO-INCREMENT R5
               BCT   R3,GPCWR20   LOOP TILL DONE WITH THIS BLOCK
  It unprotects, writes a fill pattern, and RE-PROTECTS every halfword it covers.
  Traced at `3032a`: `nia=02c7c` = `GPCWR20+2` (M1=0, unprotect) and `nia=02c80` =
  `GPCWR20+6` (M1=2, protect) at t=11,348,275/11,348,281 -- ELEVEN SECONDS BEFORE the
  SSL's first DMA at t=22.96M.  That is the proximate cause of all 7169 violations.
- AND IT EXPLAINS THE INSENSITIVITY: blanket and `sections` modes give identical
  results because THE FLIGHT SOFTWARE PROTECTS EVERYTHING ITSELF.  `ipl_fill()`'s
  blanket is duplicating what `GPCERAS` does halfword by halfword.  Whatever our
  loader model does is overwritten by the erase pass.
- THE REMAINING QUESTION IS NARROW AND WELL-FORMED: the erase loop is BOUNDED --
  `DSRCNT` counts sectors up, `CH R0,DSRLIMIT` at 264 ends it, with `STARTADR` and
  `STARTCNT` as the within-sector bounds.  So either (a) `DSRLIMIT` should stop
  GPCERAS before sector 6 and ours runs too far, or (b) something unprotects the
  buffer after the erase and we are not reaching it.  CHECK DSRLIMIT'S VALUE AND WHO
  SETS IT FIRST -- it is a single halfword and decides the whole question.
- Note the earlier pair at `nia=00171`/`0017b` (M1=1 then M1=3, t=2.00M/2.01M) is a
  FULLWORD unprotect/protect over the same address from GPCIPL's own early sweep,
  distinct from the GPCERAS pass.

### [2026-08-28] Target: [problems.md]
- THE PROTECTION CHAIN IS NOW ESTABLISHED END TO END, and the "timing sensitivity"
  that never made sense is explained as a WINDOW:
    1. `GPCERAS` (`GPCERAS.asm:257-261`, via `GPCWR20`) unprotects, fills and
       RE-PROTECTS every halfword of sectors 0-15 at t~11.35M.  `DSRLIMIT DC X'000F'`
       (`STPDATA.asm:1027`) = 15, so sector 6 is legitimately inside its range -- our
       emulation is NOT overrunning.
    2. The SSL's BCE DMAs into `#PCVNMMU` at t~22.96M.
    3. NOTHING BETWEEN THEM UNPROTECTS IT.  `FCMUPROT` only ever opens LOAD-BLOCK
       DESTINATIONS (it takes a 3-halfword descriptor in R1), and the staging buffer
       is not a destination.
    4. A load block covering the buffer with protect=0 would unprotect it in exactly
       that window, because `FCMRPROT` re-protects only per the block's own flag.
    5. `mmbstamp` emits no such block: the csect has no data extent, its `INITIAL`
       being all zeros.
- CONFIRMED BY PREDICTION, not by fitting: unprotect at t=12,000,000 and at
  t=18,765,000 -- 6.7 seconds apart, both inside the window -- give BIT-IDENTICAL
  outcomes: 400 blocks, wordsTaken == wordsOut == 204812, zero lost, same halt at
  `FCMSSLEX+2` at t=39,593,714.9.  Outside the window (t=1000, t=60,000,000) both
  give 281 blocks with 26,698 words dropped.  A window, not a lucky constant.
- WITHDRAWN AGAIN, and this time the reasoning was circular: I ruled out a load block
  here because the DASS dump shows the region 100% `C6C6`.  But `C6C6` IS THE TAPE'S
  OWN FILL (`STACK_FILL_BYTE = 0xC6`, `INIT=C6C6` on every MMUDATn ALLOC card,
  lnk101 `linker.py:59-63`), so a load block carrying fill produces EXACTLY the dump
  content I used as evidence against one.  The dump cannot distinguish the two cases.
  The memory file `project_fiomuwb2_is_a_name_pointer_to_cdhv_blocks` carried "Do not
  fix mmbstamp here" as a DIRECTIVE and has been corrected.
- PROPOSED FIX, same class as the FCMPSA drop: have `derive_load_blocks` emit an
  UNPROTECTED load block for csects the link ALLOCATES but supplies no text for --
  `#PCVNMMU` is the only one in the IPL set (measured earlier: sections minus extents
  minus covered, no size threshold, 3 rows all the same region).
  ACCEPTANCE TEST, already calibrated: rebuild the tape and boot with NO
  `YAGPC_UNPROTECT` at all.  It must reach 400 blocks with wordsTaken == wordsOut.
  Anything less and the block is not doing what the injection does.
- NOTE the 400-block run still HALTS at `FCMSSLEX+2` rather than booting, so this is
  a necessary step, not the last one.

### [2026-08-28] Target: [problems.md]
- THE `RESERVE` LOAD BLOCK IS CONFIRMED BY THE FLOWN ARTICLE, to the halfword.
  `DASS_SSW_(PostIPL).ASC:1277-1280` brackets `#PCVNMMU` with
  `*** BEGIN RESERVED CSECT ***` / `*** END RESERVED CSECT ***` AND, decisively,
  shows a LOAD-BLOCK CHECKSUM TAIL at `03432C-03432D` immediately after it.  A
  synthesized block from the deck card and csect size alone gives start `030322`,
  length 16396, checksum tail `03432C..03432D`, next block at `03432E` -- which is
  exactly where phase 3's observed block starts.  Four independent lines converge:
  the deck's `RESERVE` card, the era-original MAFGEN annotation, the image's checksum
  boundary, and the arithmetic.
- CORRECTION, MINE: I said that annotation came from our own `mafgen/` tooling.  IT
  DOES NOT -- zero matches in any of our `.py`, and the string occurs ONLY in
  `DASS_SSW_(PostIPL).ASC`, an ORIGINAL 2010 MAFGEN report from real GPC dumps, twice
  (the BEGIN/END pair), and in NONE of the seven OPS-configuration DASS reports.  I
  misread a `grep` that returned nothing as having matched, because an `ls` in the
  same command printed filenames after it.  The modern `mafgen/` is an imitation of
  the era program, not its source.
- THE FIX WORKS FOR PROTECTION AND FAILS ON ALLOCATION.  Emitting a synthetic fill
  extent for RESERVEd csects before `derive_load_blocks` gives phase 2 28 load blocks
  with `30322 len=16396 protected=False`, and booting with NO injection at all:
      DMA violations  7170 -> 1   (and that 1 is the unrelated early addr=00002 hit)
      words dropped   26698 -> 0  (wordsTaken == wordsOut)
  So the missing block WAS the cause of the violations, exactly as diagnosed.
  BUT blocksRead falls 281 -> 58, because of two implementation faults:
    1. BUDGET OVERFLOW.  Phase 2 then needs ~259 tape blocks against
       `blks_of_phase[2] = 256`; `fit_budget` returns ncont=261, crossed=True, so the
       phase spills past its MM area and the layout is corrupt.
    2. NO CONTENT ON THE TAPE.  `tape_text()` RE-READS the `.lib` FROM DISK, so an
       in-memory synthetic extent never reaches the volume -- 0/16393 halfwords
       covered.  Injecting into `lib.extents` inside `phase_load_blocks` is the wrong
       insertion point for anything that must also be written.
  REVERTED; phase 2 back to 27 blocks, ncont=226, crossed=False.
- WHAT THAT IMPLIES FOR A REAL FIX: the era build fitted this block inside phase 2's
  256-block allocation, so either the allocation is computed differently, or the
  block is absorbed into an adjacent one, or it belongs to another phase.  Do NOT
  simply raise the budget -- that would paper over whichever of those is true.

### [2026-08-28] Target: [problems.md]
- **`FCMRESRV` FOUND, AND THE SECOND `mmbstamp` DEFECT IS FIXED.**  `FCMINSSL.asm:1111`
  `FCMRESRV EQU X'2000'  RESERVE LOADBLOCK MASK`.  The SSL tests it THREE times and
  skips the block each time: the MM block count (:496, `RESERVE FLAG OFF (LB DATA ON
  MM)?`), the BCE transfer setup (:584) and the checksum pass (:842).  So a reserved
  load block READS NO TAPE, TRANSFERS NOTHING AND IS NOT CHECKSUMMED -- it is purely
  a DESCRIPTOR carrying address/length/protect, and it is still walked by
  `FCMUPROT`/`FCMRPROT`, which is what clears the store-protect bit `GPCERAS` set.
  The idea came from the user asking whether reserved sections might be treated
  differently rather than occupying space.  They are.
- `LoadBlock.words()` built flags as `0x0600 | sector<<4` plus `0x8000`/`0x4000` and
  HAD NO WAY TO EXPRESS `0x2000` AT ALL.  Added `LoadBlock.reserved`, encoded as
  `FCMRESRV`, and made `pack_mm` charge a reserved block ZERO MM blocks.
- ACCEPTANCE TEST PASSED, no injection, no patches, tape unchanged at 2500 blocks:
      blocksRead        281 -> 400          (target 400)
      wordsTaken/Out    117178/143876 -> 204812/204812
      wordsLost         26698 -> 0
      DMA violations    7170 -> 1           (the unrelated early addr=00002)
      halt              #@LB117 -> FCMSSLEX+2, matching the injection runs
  Phase 2: 28 descriptors, ncont=226, crossed=False -- NO budget overflow, because
  the reserved block costs no MM blocks.  Descriptor encodes as
  `addr=8322 flags=2660 len=400C` (FCMRESRV | 0x0600 | sector 6, protect off).
- EVERY EARLIER EXPLANATION OF THE 58-BLOCK FAILURE WAS WRONG, and all for the same
  root reason: I emitted the descriptor WITHOUT the flag, so the SSL tried to read 33
  tape blocks that do not exist and everything after was displaced.  Specifically
  WITHDRAWN: "budget overflow -> layout corrupt" (the overflow was an artifact of
  counting a block that costs no tape -- and the user's PHASE21 precedent, 42 vs 41,
  is a benign warning; `crossed` is a TRACK-boundary flag from `pack_mm`, handled by
  setting `sot`, not a budget signal); and "the tape carries no content" (correct
  observation, wrong significance -- it should not carry any).
- STILL OPEN: the run halts at `FCMSSLEX+2` with 400 blocks rather than booting.
  That was true of the injection runs too, so it is the NEXT defect, not this one.

### [2026-08-28] Target: [problems.md]
- **THE SSL NOW LOADS PASS CLEANLY WITH NO INJECTION AT ALL, AND `FCMSWMON` RUNS.**
      blocksRead      324  (was 400 with two checksum retries, or 281 stalled)
      wordsTaken/Out  165896/165896, zero lost
      DMA violations  1 (the unrelated early addr=00002)
      CPU             nia=19847 = `FCMSWMON` (the FCOS software monitor),
                      still executing at t=1,411,055,444 us when max-steps hit
  No `YAGPC_UNPROTECT`, no `YAGPC_LOADBIN`, no `YAGPC_PATCH`.  Previously this state
  was only reachable by injecting FCMPSA and forcing the buffer unprotect.
- `FCMSSLEX+2` DIAGNOSED: it is the SSL's THREE-STRIKES give-up, not a normal wait.
  `FCMSSLCK` compares the computed checksum, `SHW FCMCKERR`, `FCMECNT` +1, and at
  `>= 3` falls into `FCMSSLEX / SSM FCMWAIT` (`FCMWAIT DC X'000A'`).  Traced live:
  `nia=0724b` sets FCMCKERR=ffff and `nia=07250` steps FCMECNT 1,2,3 at t=27.48M,
  28.61M, 29.73M -- about 1.13s apart.  That also explains 400 blocks against ~324:
  the extra reads are the two retries.  `FCMIZCON` (0731c) held `024a` at each
  failure, naming the failing block: phase 3's `0024a len=98`.
- **ROOT CAUSE WAS MINE**, from the FCMPSA fix: `parent_pool_lo` was added to
  `mmbstamp.phase_load_blocks` (which builds the PHASE TABLE) but NOT to
  `mmu2mmv.phaseRecord` (which WRITES THE TAPE).  Phase 3 then got 11 blocks on tape
  against 10 in the table -- the extra being `001fe len=4` -- so the SSL read the tape
  displaced from that block onward and every following block failed its checksum.
  The next block in address order is `0024a`, exactly the one observed failing.
- SWEPT FOR OTHER CALLERS rather than assuming, and found a THIRD:
      `mmbstamp.phase_load_blocks:811`   had it (my fix)
      `mmu2mmv.phaseRecord:185`          MISSING -> fixed
      `fcmImage._lb_slots:397`           MISSING -> fixed
      `mmu2fcm.py:751`                   n/a, a comment noting it uses
                                         phase_load_blocks deliberately
  `fcmImage`'s own docstring states the invariant the omission broke --
  "mmbstamp.derive_load_blocks is the single definition of the partition" -- which
  holds only if every caller passes the same arguments.  It feeds checksum-slot
  detection, so it would have skewed the very tooling used to verify the tape.
  All four phases now agree table-vs-tape: 27/27, 10/10, 5/5, 2/2.
- DESIGN SMELL WORTH FIXING PROPERLY: `parent_pool_lo` is derivable from what every
  caller already has (`pool_low_hw(parent_lib, parent_pool)`), so making it the
  caller's responsibility guarantees this drift.  `derive_load_blocks` should take the
  parent LIB and compute both itself.  Not done -- wider change to Don's code.
- ALSO VERIFIED (not a bug): the checksum convention is consistent.  The writer sets
  `block[slot]=0` and `block[slot+1]=total` over `0..slot-1`; the SSL does
  `SHI R5,2`, sums offsets `0..96` and compares offset 97 -- equal only because that
  zero is there, and it is.
- STILL OPEN: the DEU sees nothing (0 commands, 0 fills), so PASS runs but has not
  driven a display.  That is the next target.

### [2026-08-28] Target: [problems.md]
- **THE DISPLAY PATH WORKS.**  `--discrete-b 21000000` (GPC 1, DEU_ID 1) with
  `--deu-model`, headless: `ipled:true, polls 265, timeFills 260, displayFills 266,
  formatFills 8, headerless 0, abandoned 0`, ZERO errors, 10,000 SECONDS of simulated
  time, servicing Clock 1 interrupts normally.  Against this log's own reference for
  a good run -- POLL 87 / TIME_FILL 88 / DISPLAY_FILL 87 / FORMAT_FILL 7 in 45 s --
  the proportions match and `formatFills` 8 vs 7.  Every one of those counters read
  ZERO in every previous run this session.
- THE BIT LAYOUT, from `discretePanel/discretePanel.py`: register B bits 6-7 are the
  DEU_ID field, read by GPCIPL as `NHI R3,X'0300'` with zero meaning NO DISPLAY UNIT
  (`GPCRTOPT.asm` POLL30, "IS THE DEU_ID 1, 2, 3, OR 4" / `LR R3,R3` / `BZ POLL45`).
  GPC id is bits 0-2.  So `20000000` = GPC 1 + DEU_ID 0 = the no-CRT default-load
  path, and `21000000` = GPC 1 + DEU_ID 1.  THAT ONE DIGIT is the difference between
  "the display is dead" and the numbers above.
- WHAT THE HEADLESS RUN CANNOT DO: with a static discrete there is no keyboard, so
  GPCIPL sits in its menu loop at `01df8`/`01dbe` polling the DEU forever and NEVER
  LOADS -- zero tape reads.  Proving the display path is not proving the load.
- ISOLATION RESULT, and it exonerates the bridge: re-running identically but with
  `--bce-network` against the live MEDS instead of `--deu-model` ALSO runs clean --
  7 minutes, zero errors.  So the user's crash is NOT the UDP bridge and NOT
  `--real-time` pacing.  Both DEU paths are stable while GPCIPL waits at the menu.
- THEREFORE the crash (`invalid instruction 0xc9a4 at 0x0008`, PSA storage executed
  as code) belongs to THE MENU-INITIATED LOAD -- what ITEM 1 EXEC starts -- which is
  a DIFFERENT load path from the one every headless test exercises.  With no DEU,
  POLL45 takes "IPL DEFAULT LOAD" and writes LOADTABLE ID 15 to `BSLTPNTR+1`; a menu
  selection writes a different id and loads a different table.  Untested by anything
  I have run headlessly all session.
- CORRECTION, TWICE MADE: `wordsLost` is NOT a defect.  `mmumodel.c:211-214` states
  GPCIPL's loader "takes what it wants and stops... leaving 360 of a 4096-word
  transfer unread", and the observed losses are EXACT multiples: 720 = 2x360,
  1440 = 4x360.  The headless runs lose zero because the SSL loads there and takes
  everything; the panel-IPL path runs GPCIPL's loader instead.  Different loader, not
  different pacing.  I twice called this the thread to pull.
- ALSO CORRECTED: MEDS DOES respond.  `YAGPC_BUSTRACE` shows 246 `KEEP` datagrams
  from 127.0.0.1:6906 (32 bytes, `0000 ff00 ...`, and `0001 ff00 ...`) against 6872
  `ECHO` of our own loopback correctly discarded.  So the transport and the IUA
  filter both work.  `0001` is `HDR_IPL_REQUIRED`; our own `deumodel.c` documents the
  matching rule -- "while a load is running the unit answers a poll with the header
  alone... the rule that starves a sixteen-word receive mid-IPL" -- and `FAZ2DEU`
  exits early on `DEUMODE & X'0001'`.  Plausible but NOT verified: the full 16
  halfwords of a KEEP were never dumped, only the first 6.

### [2026-08-28] Target: [problems.md]
- ADDED `YAGPC_DEUKEYS` to `deumodel.c`: a keystroke sequence delivered once on the
  first poll after the unit is IPLed, so a headless run can drive GPCIPL's menu.
  Until now `deumodel.c:91` said it plainly -- "No keyboard here" -- so the
  MENU-SELECTED LOAD PATH (what ITEM 1 EXEC starts, a different load table from
  POLL45's no-DEU default) was unreachable without a human at a real MEDS, and no
  headless test all session has ever exercised it.
- ENCODING, from `meds/deuProto.coffee`, and our poll response already matched the
  layout exactly: header carries `KYBD_MSG` 0x0008; the count word is
  `KEY_COUNT_HIGH | count`; the buffer packs THREE keys to a halfword, 5 bits each,
  most significant first, in `w[2..11]`; `MAX_KEYS_IPL` is 6.  Keycodes: digits
  0x00-0x09, `ITEM` 0x14, `EXEC` 0x1e, `OPS` 0x11, `SPEC` 0x12, `PRO` 0x1f, etc.
  So `ITEM,1,EXEC` packs to `w[2]=0x503E`, `w[1]=0xff03`.
- IT DELIVERS BUT DOES NOT YET DRIVE THE MENU: "deu: YAGPC_DEUKEYS delivered 3
  keystroke(s)", then 40000 DEU commands and 13332 polls later there is STILL no tape
  read and no crash.  So GPCIPL is not acting on the keystrokes.  Candidates, none
  tested: the keys arrive before the menu is up (delivery is on the first poll after
  `ipled`, which may be far too early); the major-function field (`HDR.MAJOR_FUNC`,
  bits 9-10) has to be set for a keyboard message to be honoured; or the handler
  wants them spread over successive polls rather than in one burst.
  NEXT STEP: watch `ITEMNO` (`0251e` in phase 10) and `BSLTPNTR+1` (`0366d`) to see
  whether the software reads the buffer at all before theorising further.
- Four pre-existing test failures unchanged.

### [2026-08-28] Target: [problems.md]
- `YAGPC_DEUKEYS` WORKS AT THE PROTOCOL LEVEL, verified end to end.  Watching
  `DEUMODE` (`03b7a`, phase 10) shows the poll response reaching memory from `pe=6`
  (BCE 6, the DK bus) -- 14616 writes -- and the keyed response landing exactly once:
      03b7a val=0008     header with KYBD_MSG
      03b7b val=ff03     KEY_COUNT_HIGH | 3
      03b7b val=00000003 the CPU writing the count back, i.e. it READ the buffer
  So keys reach the software and are read.  `YAGPC_DEUKEYS_AFTER=<n>` (default 400
  polls) was added to hold them until GPCIPL's menu is up; delivering at the first
  poll after `ipled` put them in front of a display that was not showing the menu.
- `CM4KYBD` (`GPCRTOPT.asm:1001`) CHECKSUMS THE WHOLE 16-HALFWORD BUFFER and requires
  the sum to be ZERO (`LHI R3,16` / `AH# R0,0(X2,Z3)` / `BZ CHKSUC` / `ERROR 150`).
  That check runs ONLY for keyed messages -- `RSP60` calls it only when the header's
  `X'08'` is set -- which is why ordinary polls have always passed.  OUR MODEL ALREADY
  SATISFIES IT: `deu_checksum` returns the NEGATED sum and `w[15]` is computed after
  the keys are inserted.  Not the obstacle.
- WHAT IS THE OBSTACLE, and it is structural: THE CREW SEQUENCE IS A SEQUENCE, NOT A
  STATE.  Register A bits 0-3 are HALT/STANDBY/RUN/IPL and, per `discretePanel.py`'s
  own comment, IPL is a MOMENTARY PUSHBUTTON asserted ON TOP OF HALT, not a fourth
  position -- "a panel that made IPL a fourth exclusive position could not express the
  real sequence at all".  A static `--discrete-a` asserts a final state the software
  never TRANSITIONED into, so `--discrete-a 28000000` (RUN + MM1 source) produces a
  run with no DEU activity and no mode lines at all.
- SO HEADLESS MENU-DRIVEN TESTING NEEDS TIMED DISCRETE CHANGES -- a scripted
  HALT -> IPL pulse -> STBY -> RUN -- which is exactly what `discretePanel.py` does
  interactively and which yaGPC2 has no way to express on the command line.  THAT is
  the missing capability, not the keyboard.  `--discrete-a`/`-b` are static overrides
  by design.
- STATE OF THE CRASH HUNT: unchanged.  `invalid instruction 0xc9a4 at 0x0008` remains
  reproducible only interactively, because only the panel can perform the sequence.

### [2026-08-28] Target: [problems.md]
- **THE CREW SEQUENCE IS NOW SCRIPTABLE, AND THE BOOTSTRAP COMES FROM TAPE.**  Added
  `--script FILE` and `--quit-after MS` to `discretePanel.py` -- the user's suggestion,
  and the right home for it: the panel already owns the bit layout and the
  momentary-pushbutton semantics, whereas yaGPC2's `--discrete-a/-b` are static
  overrides that assert a final state the software never TRANSITIONED into.  Script
  lines are `<ms> <command>`: `mode HALT|STANDBY|RUN`, `ipl` (press + release
  IPL_HOLD_MS later), `source MM1|MM2|OFF`, `gpcid <n>`, `bit <A|B> <n> <on|off>`.
  `bit` sets the toggle VARIABLE, not just the wire, because `_republish` re-asserts
  from the variables and a direct send would be undone on the next tick.
- IT WORKS END TO END, headless, no `.fcm` argument at all:
      MODE: HALT; CPU held in reset (no crew panel heard yet)
      MODE: IPL; memory filled, bootstrap read from MM1 (BCE 18) over the bus
                 (72 blocks, 36864 halfwords) to 0x00000
      MODE: HALT -> STBY; reset released, starting at 0x0014b
      MODE: RUN
      deu: YAGPC_DEUKEYS delivered 3 keystroke(s)
  THE BOOTSTRAP IS READ FROM THE TAPE OVER THE BUS -- the fidelity gap I had been
  short-circuiting by handing `--ipl` a pre-built `BOOT-700s.fcm`.  Requires
  `stamp_bootstrap_on_tape.py` to have written the FMAIPL2 allocation first.
- ORDER MATTERS: start yaGPC2 FIRST.  The panel republishes LEVELS on a timer, but
  the IPL pushbutton is MOMENTARY -- start the panel first and the pulse is missed
  and the machine never IPLs.
- STILL NOT LOADING: with the full sequence and `YAGPC_DEUKEYS=ITEM,1,EXEC`, 8665
  polls and 26000 DEU commands later there is no tape read and no crash.  So the
  keystrokes reach the software (proved earlier via DEUMODE) and the mode sequence is
  now genuine, yet ITEM 1 EXEC does not select.  NEXT: watch `ITEMNO` (`0251e`) and
  `BSLTPNTR+1` (`0366d`) during a scripted run -- that separates "keys parsed but the
  item rejected" from "handler never reached", and it is the measurement I keep
  deferring.
- TRAP, FOURTH AND FIFTH TIME TODAY: a `pgrep -f`/`kill` whose PATTERN TEXT appears
  in the same command line matches the shell itself (exit 144).  Putting the kill and
  the relaunch in ONE command is what does it.  Use `discrete[P]anel` so the pattern
  cannot match its own occurrence, and keep kills in a SEPARATE invocation.

### [2026-08-28] Target: [problems.md]
- **THE CRASH IS REPRODUCED HEADLESSLY, AND THE FIGURES MATCH THE USER'S RUN EXACTLY:**
  `commands 56, blocksRead 429, wordsOut 219707, wordsTaken 218987, wordsLost 720`,
  ending `ERROR: invalid instruction 0xc9a4 at 0x0008`.  Deterministic, no human at
  the panel.  Sequence: scripted `discretePanel.py` (HALT / CRT select / MM1 / IPL /
  STBY / RUN) + `YAGPC_DEUKEYS=ITEM,1,EXEC`, bootstrap read FROM TAPE over the bus.
- THE BUG THAT WAS BLOCKING IT WAS MINE, in the keystroke packing.  `deuProto.coffee`
  line 157 says it exactly: "bits 15-11 are the first key, 10-6 the second, 5-1 the
  third, BIT 0 SPARE".  I shifted 10/5/0 instead of 11/6/1, so `ITEM,1,EXEC` packed
  to `A07C`... no, to `503E`, whose top five bits are `0x0a` -- and `0x0a` is EXACTLY
  what `KEY1` was observed to receive.  The software decodes with `SLDL R4,5` from
  the TOP of the halfword (`GPCRTOPT.asm` KYBD01), so a one-bit error silently
  becomes a different key.  Fixed: `ITEM,1,EXEC` now packs to `A07C` and `KEY1..KEY3`
  read `0x14 / 0x01 / 0x1e`.
- HOW IT WAS FOUND, and the lesson is to watch the RIGHT address: `ITEMNO` (`0251e`)
  is the SAME address as `KYBDCON`, a structure base, so watching it showed only the
  tape loader writing.  `KYSTRKS` is `DEUMODE+1` (`03b7b`), where the count lands and
  where `STH R5,KYSTRKS` writes it back masked; `KEY1` (`02621`) is where decoded
  keystrokes go.  Watching `KEY1` showed `0x0a` where `0x14` was sent, which named
  the defect immediately.  Three earlier attempts theorised about delivery timing,
  major-function bits and the `CM4KYBD` checksum -- all wrong, and all avoidable by
  measuring one halfword.
- SO THE MENU-SELECTED LOAD NOW RUNS: 429 blocks read where the pre-key runs read
  none.  `wordsLost 720` is the expected 2 x 360 of GPCIPL's own loader.

### [2026-08-28] Target: [problems.md]
- CRASH TRACED TO ITS DISPATCH, and the vectors are INNOCENT.  With
  `YAGPC_INTTRACE` on the reproduced run:
      INT old=0078 new=007c  atNIA=40000  newPSW=9a300031   EX0 while in PASS code
      INT old=0070 new=0074  atNIA=00041  newPSW=acf80031   Instruction Monitor
      ERROR: invalid instruction 0xc9a4 at 0x0008
  `0x40000` is `$0AIBGPC` in module `AIBGPCLO` -- REAL PASS APPLICATION CODE, so PASS
  was genuinely running when the interrupt arrived.  `00041` and `00008` are inside
  `FCMPSA`.
- THE EX0 VECTOR IS CORRECT.  `MEMDUMP 78-7f` at the crash gives
  `0078: 8000 0081 fc05 0000` (old PSW, and `8000/0081` resolves to `0x40000` with
  BSR 8 -- the interrupted address, saved correctly) and
  `007c: 9a30 0031 a00c 0000` (new PSW).  `9a30` with BSR 3 is `0x19a30`, which is
  exactly `FIOERRLA`, the `EI0=FIOERRLA` handler `TFPSA` declares.  So the interrupt
  DISPATCHED PROPERLY and our FCMPSA fix is holding up under a real interrupt.
- THEREFORE THE FAULT IS INSIDE `FIOERRLA` (or in what it returns to), not in the
  vectoring: the handler is entered, and execution is next seen at `00041` in PSA
  storage with the Instruction Monitor firing -- which is what happens when
  instructions are fetched from UNPROTECTED storage with PSW mask bit 34 set.
- EX0 IS NOT ITSELF FATAL: the same interrupt fires earlier at `atNIA=02d3f` and
  `atNIA=00886` and is handled normally, execution continuing.  Only the one taken
  from `0x40000` ends badly.  So do NOT chase "why does EX0 fire" first -- it fires
  legitimately.  `iop.c` lists the Group 1 sources: GO_NOGO (watchdog, ~3.1 s at
  0.768 ms x 12 bits), IOP_FAIL, CM_IDLE (master reset), ROS_PAR, IOP_FAULT.  The
  spacing of the observed EX0s (210.9 M, 220.7 M, 354.3 M us) is NOT the watchdog
  period, so it is not a free-running timeout.
- NEXT: trace inside `FIOERRLA` (`19a30`, phase 2).  It is a LOADED region -- phase 2
  has a load block at `19a30 len=12140` -- so this is not a missing-content problem.
  Watch its entry and follow where it leaves the rails; `0x0008` is where it ends up,
  not where it goes wrong.
- Four pre-existing test failures unchanged.  MEDS left running (7 procs); no yaGPC2
  or panel processes left behind.

### [2026-08-29] Target: [problems.md]
- `FIOERRLA` IS CORRECTLY LOADED AND CORRECTLY ENTERED.  Dumping `19a30` at the crash
  gives code that matches `SSSRC/FIOERRLA.asm` instruction for instruction:
  `c8fb 964a` = `STM FI$ERRAB` (save area is at `0964a`), `edf3 0800` =
  `LHI R5,FIOIRACW` with `X'0800'`, and `a05e` at `19a3e` is the `CALL FIOLGERR`
  (`1a05e`).  Its return is `LPS TPSAEOP`, and `TPSAEOP` IS `00078` -- the EX0 old
  PSW slot -- which the hardware had just filled with the interrupted `0x40000`.
  So save, dispatch, handler content and return path are ALL sound.
- CORRECTION TO MY OWN FRAMING, before it hardens: I was treating the fault as being
  "inside FIOERRLA".  It probably is NOT.  170 MILLISECONDS of simulated time pass
  between the EX0 (t=353,537,610) and the Instruction Monitor (t=353,708,461) --
  thousands of instructions -- so the handler almost certainly returned normally and
  the program ran on for a long while before going wild.  The two events being
  ADJACENT IN THE INTERRUPT TRACE is an artifact of nothing else interrupting in
  between, not evidence that one caused the other.
- `0x41` is inside the MACHINE CHECK old-PSW slot (PSA `0x40-0x43`), so the wild
  branch lands in PSA data, and `0x0008` is where it ends up after that -- neither is
  where it goes wrong.
- BENIGN, ruled out: the IOP (`pe=18`) zeroes `0078-007b` at t=221.9M.  That is the
  `FCMPSA` load block (`00000..001a7`) legitimately initialising the PSA during the
  load, long before the interrupt, and the hardware refills the slot when EX0 fires.

### [2026-08-29] Target: [problems.md]
- **ROOT CAUSE FOUND: PHASE 2'S Z1 ZCON POOL WAS NEVER EMITTED, so PASS ran with
  GPCIPL's Z-CONs.**  `derive_load_blocks` emits the pool as `[pool_start, pool-2]`,
  but only sets `pool_start` when `s >= parent_pool`.  `POOL_PARENT` HAS NO ENTRY FOR
  2, so `.get(2, 2)` makes PHASE 2 ITS OWN POOL PARENT and `parent_pool` is phase 2's
  OWN cursor (`0024a`).  Its own pool starts at `001a8`, BELOW that, so the test was
  never true and the block was never emitted.  Child phases were fine: their pool
  sits above the parent's cursor.
- HOW IT WAS FOUND, by measurement rather than inference, and it needed a new tool:
    * A NIA ring buffer (`YAGPC_NIARING=<n>`, dumped at the Instruction Monitor and at
      the invalid-instruction stop) -- a wild branch is invisible to every other trace
      because the interrupt log shows only where execution ARRIVED, and `--trace` over
      ~200M instructions is unusable.
    * The ring gave `... 40078 40079 4007a | 44723 ...`, so `0x4007a` branched into
      `#CDCDDOW`, a DATA csect.  `0x4007a` holds `D0FF 39CC`, which the emulator's own
      disassembler renders as `SCAL 0,@@X'01cc'(1)` -- a call fetching its target
      THROUGH a Z-CON at `01cc`.
    * `01cc` is inside the Z1 pool (`pool_low_hw 001a8`, `pool_next_hw 0024a`), and
      the only load block covering it belonged to PHASE 10.  Phase 2's `.lib` HAS the
      content -- extent `001a8..00247`, 160 halfwords -- and it was being dropped.
  THE SAME REGION was flagged HOURS EARLIER as a 158-halfword mismatch against the
  DASS dump, "our values and DASS's, same values in a different order".  Two symptoms
  of one cause; I did not connect them until the ring named the instruction.
- FIX: when a phase is its own pool parent, its own cells begin at `pool_lo`, not at
  the self-referential `parent_pool`.  Phase 2 now emits `001a8 len=162` (29 blocks,
  ncont 227 of a 256 budget, crossed=False); phases 3, 10 and 13 are UNCHANGED.
- **RESULT: PASS now runs far enough to report its own runtime error.**
      *** HAL/S SEND ERROR: RUNTIME: #6 EXP FUNCTION HAS ARGUMENT > 174.673
      ERROR: invalid instruction 0xc6c6 at 0x6b8f
  That is the HAL/S runtime library detecting a math domain error and announcing it
  through PASS's own channel -- a completely different and far more advanced failure
  than a wild call into a data csect.  blocksRead 430.
- WITHDRAWN: "the crash is nondeterministic".  It is deterministic; I had FOUR
  discretePanel instances running at once, each republishing conflicting mode levels
  from its own script clock, because I launched one per iteration without killing the
  previous.  With a single panel the crash returned to exactly `0xc9a4 at 0x0008`.
  A polluted harness looked like a property of the machine.
- Four pre-existing test failures unchanged.

### [2026-08-29] Target: [problems.md]
- SYSTEMATIC CHECK, and it is nearly clean now.  Extents present in a phase's `.lib`
  but covered by NO load block of that phase:
      PHASE10  0        PHASE02  0        PHASE13  0
      PHASE03  1 extent, `001fe..001ff`, 2 halfwords
  So after the FCMPSA, FCMRESRV and root-pool fixes, nothing else is being silently
  dropped.  Worth re-running this check after any change to `derive_load_blocks`; it
  is three lines and would have caught all three defects on day one.
- THE REMAINING FAILURE HAS MOVED INTO PASS ITSELF.  After the HAL/S runtime error
  the FCOS dispatcher exits through
      1a97d  CCF8 0008  LM   X'0008'(0)     restore registers from the PSA
      1a97f  CDFF 10B2  LPS  @X'00b2'       load PSW INDIRECTLY through 00b2
  `00b2` is `TPSAWORK`, the FCOS WORK AREA (`&WORK SETC 'H''0'''` in TFPSA), which the
  dispatcher fills with the PSW of the task it is dispatching.  It held a pointer into
  `#CDPLLIG` (a DATA csect), so the dispatch went wild and ran on into unloaded
  memory at `16b8f`.  This is NOT a load gap -- `TPSAWORK` is inside FCMPSA's block
  and is loaded -- it is the dispatcher computing a bad value, downstream of the
  runtime error.
- A LEAD WORTH CHECKING BEFORE CHASING THE DISPATCHER: OUR Z1 POOL IS ORDERED
  DIFFERENTLY FROM THE FLOWN ONE.  At `001fe` phase 2 has `8000 0E00`, phase 3 has
  `888C 0E90`, and the DASS dump has `81F8 0E20` -- three different values.  That
  matches the much earlier observation that `001aa..00247` holds "our values and
  DASS's, the SAME VALUES IN A DIFFERENT ORDER".  `lnk101` takes a `--link-order`
  pins file that fixes "the Z1 ZCON pool ordering", and NO `linkorder.json` EXISTS
  ANYWHERE on this machine, so our ordering is unpinned.
  WHY IT MIGHT MATTER NOW THAT THE POOL IS ACTUALLY LOADED: the link itself is
  self-consistent, so compiled code reaches its own cells correctly -- but anything
  that addresses a pool cell by ABSOLUTE ADDRESS from outside the link does not.  The
  PATCH decks (`PCH02SRC` etc.) are exactly that.  A permuted pool would put patches
  on the wrong cells.  UNVERIFIED; check whether any patch writes into 001a8..00249
  before believing it.
- The 2-halfword phase-3 drop at `001fe` is NOT settled by the dump, since the flown
  value matches neither of our phases.  Leave it dropped until the ordering question
  above is resolved.

### [2026-08-29] Target: [problems.md]
- **THE Z1 POOL ORDER CAN BE PINNED TO THE FLOWN ONE, AND NOW IS.**  `lnk101` takes
  `--link-order <linkorder.json>`, whose `zconPool` is an ORDERED LIST OF CSECT NAMES
  (`ap101Utils/linkorder.py:70`, `zcon_sort_key` sorts known ZCONs by pool position).
  No such file existed anywhere, so our ordering was unpinned.  THE FLOWN ORDER IS
  RECOVERABLE: `mafgen/csects-SSW.json` gives each csect's address in the flown image,
  so sorting the 80 pool csects by address yields the pins directly.  Generated and
  kept at `/tmp/claude-1000/sync/linkorder.json` (1104 bytes, 80 names).
      before: 2 of 80 pool csects at the flown address
      after:  80 of 80
      PHASE02 sector-0 match vs DASS: 97.359% -> 98.061% (305 -> 224 mismatches)
- **BUT IT IS NOT A FUNCTIONAL FIX, and my hypothesis was WRONG.**  I reasoned that
  `SCAL 0,@@X'01cc'(1)` encodes a LITERAL base address and selects the routine by
  INDEX, so the pool order would be part of the calling ABI and a permuted pool would
  send library calls to the wrong routine -- which would explain EXP receiving a wild
  argument.  Booting the pinned tape produces the IDENTICAL outcome: same
  `#6 EXP FUNCTION HAS ARGUMENT > 174.673`, same `invalid instruction 0xc6c6 at
  0x6b8f`, same `blocksRead 430`.  The link is self-consistent, so reordering changes
  FIDELITY AGAINST THE FLOWN IMAGE but not BEHAVIOUR.  Keep the pins for comparison
  work; do not expect them to fix anything.
- SO THE EXP ERROR IS STILL UNEXPLAINED, and it is now the live question.  What is
  established: the pool is loaded, its cells hold our own correct values, and the
  order now matches the original.  What is not: why a HAL/S computation feeds EXP an
  argument over 174.673.  That is a DATA problem somewhere upstream, not a linkage or
  loading one.
- BUILD NOTE: `pinned/` needed the whole per-phase tree, not just `.lib` files --
  `mmu2mmv` wants `PHASEnn/PHASEnn.sym.json` and produced a 227-block volume from a
  lib-only directory before failing on missing phase blocks.  The working recipe is
  to copy `full700` wholesale and overlay the relinked phase.

### [2026-08-29] Target: [problems.md]
- CHECKED, at the user's prompting, whether `csects-SSW.json` really agrees with the
  ORIGINAL `DASS_SSW_(PostIPL).ASC` rather than trusting the derived artifact.  It
  does NOT agree entirely, and the shape of the disagreement matters:
      report csect-header lines   656
      csects-SSW.json entries     660
      only in the report            0
      shared names, different start 0
      only in the json              4   `#PCDN102` `#PCDN202` `#PCDN302` `FCMTBLPG`
  All four DO appear in the report, but not as `address-range NAME ****` header
  lines: the `#PCDN*` three appear in a SOURCE LISTING (a declaration list carrying
  `009500AA`-style sequence numbers) and `FCMTBLPG` in the SYMBOL CROSS-REFERENCE
  (`FCMTBLPG 009EBC`, and the json's 40636 IS 0x9EBC).  So the json is a SUPERSET
  drawing on more of the report than the header lines alone, and is consistent with
  it wherever both carry an address.
- FOR THE PINS THIS IS EXACT: within the Z1 pool the report has 80 header lines, the
  json 80 entries, the same set of names and ZERO address differences.  The generated
  `linkorder.json` is sound.
- METHOD NOTE, since it bit me: a first pass at extracting csects from the report
  matched 239 "entries" in the pool alone, because the pattern also caught
  symbol-detail lines like `#ZFIOCGR+0000`.  Require the `****` field and reject
  names containing `+`.
