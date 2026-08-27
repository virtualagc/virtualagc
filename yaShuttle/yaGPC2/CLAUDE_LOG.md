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
