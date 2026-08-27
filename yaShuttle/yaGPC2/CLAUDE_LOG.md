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
