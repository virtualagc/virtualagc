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
