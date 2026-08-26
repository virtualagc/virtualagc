# CLAUDE_LOG.md

(Cleared 2026-08-26 by Full Documentation Sync. 132 entries spanning
2026-08-17 to 2026-08-26 were applied to the seven files they named:

- **`problems.md`** (111 entries) — a new **Section 8**, "Real flight
  software: GPCIPL, the peripheral bus, and the OI340600/OI340700 corpora",
  covering the `--bce-network` UDP bridge, the emulator defects that running
  GPCIPL exposed (trace agreement 20,917 → all 3,987,845 instructions with
  zero phase slips), the blind fixture suites and their full triage, the
  display IPL's receive floor, our own flight image, the OI340600 rebuild
  and the LDM/STDM decode bug it found, the DASS `.dfg` phase, `dfgmap.py`,
  and the OI340700 source recoveries — plus its own method-failures
  subsection.  One further entry became a follow-up paragraph in the
  existing §7.15, on the embedding contract's `startEpochSeconds` gap.
- **`HANDOFF-FCMBOOT.md`** (10 entries, plus the 4 below) — the on-tape
  format from FCMBOOT's own header, the retracted "the DCP went into the
  display unit" claim and what actually renders, the display-format survey,
  the READY-discrete proxy caveat, and two more traps.
- **`ASM101S/ASM101Sa-notes.md`** (3 entries) — a new section on the
  `asm101` `B disp(reg)` bug that this assembler does not have: why the
  byte-verified corpora could never catch it, why it stopped GPCIPL booting,
  and its independent fix upstream.
- **`modules/sdfpkg/HANDOFF-OI340600.md`** (1 entry) — added through
  `dass-handoff.py` as entry 288, since that file is generated; recorded as
  resolved rather than open, because a later entry showed the 20,773
  divergence was the mis-assembled image and not a real fork.
- **`tools.md`** (2 entries) — a new subsection documenting `--time-scale`,
  `--pacing` and `--date-time-epoch`.
- **`README.md`** (1 entry) — the deliberate, narrow exception to the
  "dropped as impractical" note about matching yaHALMAT2's option surface.

`HANDOFF-yaGPC2-MEDS.md` (4 entries) was **not** created.  It never existed;
`HANDOFF-FCMBOOT.md` was created the next day under a different name covering
exactly that subject ("FCMBOOT → GPCIPL → MEDS"), confirmed from git history,
so its entries were applied there rather than fragmenting the same material
across two handoffs.

Claims were checked against the tree before being written down rather than
copied from the log: every flag, symbol and section reference the entries
named was verified present; the four `B 1(B2)` sites, the 194/40/178-vs-0/0/0
CON80/PDTIN/PSFIN counts, and all seven missing OI301700 counterparts were
re-measured.  Two log claims were corrected in the process — the `.dfg` count
is 133 as 116 `APPLSRC` + 17 `SSSRC`, and only three of the four BUMP returns
carry the "OTHERWISE, GET OUT OF TOWN" comment.  `HANDOFF-FCMBOOT.md`'s
pointers at this log were rewritten, since the material has moved here into
the documents themselves.)

### [2026-08-26] Target: [problems.md]
- COMMENTS IN RECOVERED SOURCE MUST STAY OUT OF THE SRN AREA, columns 73-80.
  User caught both recovered OI340700 files spilling into it: CS2PDT.hal had
  16 lines over 72 and CS2110.dfg 5 over.  Reflowed; both now clean.
- THE .dfg LIMIT IS 70, NOT 72.  A deck comment is re-commented into the
  generated HAL/S under the "**** DFG INPUT ****" banner with a "C " prefix
  -- TWO characters, measured, not one -- so a 71-character deck line becomes
  a 73-character HAL/S comment.  Verified against OI340600's own CS2110.dfg
  and its dfg output.
- PRESERVE EXISTING INTER-WORD SPACING when reflowing.  textwrap's
  fix_sentence_endings rewrote the standard Virtual AGC header's
  "None. Believed" into "None.  Believed", which would have made that block
  differ from every other file carrying it.  Replaced with a greedy wrapper
  that splits on runs of spaces and keeps each run intact.
- Reflow scope: prose paragraphs only.  Tables (the BLT halfword listing),
  code samples (the w0 formula) and separators are indented deeper than the
  text column and are left exactly as they were.
- Bug worth noting because it was silent: my first paragraph-continuation
  test treated ANY "word:" as a new label, so a colon in running prose
  ("human readability:", "on a long one:") ended the paragraph early and left
  the rest unwrapped.  The label test has to require the text start at the
  label column, not merely match the pattern.
- VERIFIED, not assumed: comment text is word-for-word identical (558 and 840
  words), code and deck statements are byte-identical, and both still build
  -- CS2PDT 376-halfword CSECT with 260/260 stated halfwords matching the
  dump, CS2110 144/144.  The only object difference is the SYM record's
  compile TIMEstamp.

### [2026-08-26] Target: [problems.md]
- THE "REMAINING 14 .dfg FILES" IS 12 DECKS, NOT 14, AND MOST OF THEM DID NOT
  NEED RECOVERING AT ALL.  Measured from dass-compare.db: 13 differing .dfg
  sections over 12 distinct decks, not the 15/13 of a few days ago, because
  the user's CV1000.dfg fix removed one deck (two sections).
- THE DIFF TABLE CAPS AT TEN ROWS PER SECTION -- compileLinkCompare hardcodes
  `--max-hw-diffs 10` -- so classifying from it undercounts.  Re-ran each deck
  and re-compared with the cap raised: of 3855 differing halfwords, 944 are
  RELOCATION TARGETS, i.e. pointers into a compool whose internal layout
  changed.  Those decks are not wrong; the compool is.
- CSA_PDT RECOVERED EXACTLY, and it was the single highest-value item: 2059
  structures, CSECT 5756 halfwords (the dump's own size), 5640 of 5640 stated
  halfwords match, no offset applied.  Same method as CS2_PDT.  Two parser
  bugs had to be fixed first:
    * the raw-hex field must be taken by FIXED COLUMN ([65:88], decimal
      [88:113]).  A greedy hex regex swallows a decimal that happens to be
      four digits ("6400"), leaving nothing to parse, and the member silently
      renders as zero -- 180 integers were wrong that way.
    * an array of copies ("+++ COPY 1 OF 2 +++") must be matched on ONE copy
      and re-emitted as -STRUCTURE(n).  66 structures failed to match without
      it, all of them _LIM.
  INDEPENDENT CHECK: structure spacing equals the matched template's computed
  size at all 2058 boundaries, 0 mismatched, and the last structure ends at
  +5640, exactly where the pad begins.
- CSP_CLB RECOVERED: OI340600's file plus one change.  Three GCIL command
  masks are wrapped in structures whose first member is a 2-halfword SCALAR
  dummy -- presumably how the "MUST BE ON FULLWORD BOUNDARY" its own comment
  demands was finally guaranteed rather than asserted.  Three structures, two
  halfwords each, is the six-halfword displacement that made CS0620's
  pointers into #PCSPCLB wrong by 6.  140 halfwords, 60/60.
- SIX DECK/CONFIG PAIRS NEEDED NO SOURCE CHANGE AT ALL.  Linked against the
  recovered compools, CS0620/S2, CS0620/G9, CS0940, CS2011 and CS2021 go from
  51/51/44/27/52 differing halfwords to ZERO.  Their OI340600 decks already
  ARE the OI340700 decks.
- TWO DECKS RECOVERED AND ROUND-TRIP VERIFIED:
    CS0790  three display fields moved from the CSS_DDT arrays to CSA_PDT
            parameter entries.  The deck's OWN comments already named the
            three parameters (726040/726042/726044), so it is a change of
            data source for the same three measurements.
    CDAP15  four checkpoint-capable SPECs (200, 205, 211, 212) where OI340600
            has eleven; 200 and 205 do not appear in OI340600 at all.
- CV1130 IS NOT AN OI340700 DIFFERENCE AT ALL: it is an ANONYMIZATION ERROR
  in OUR source.  CV1130.dfg reads CHAR=(R/^x RFG/FRT 36) where OI301700's
  CV1130.hal -- an original-build artifact embedding its own DFG input --
  reads R/SB, and the line two above it already reads R/SB MAT 35.  With
  R/SB the deck matches the G9 dump with 0 differing halfwords.  Fixed in
  OI340600, same class as CV1000's \br.
- A "0 diffs" I NEARLY BELIEVED WAS A COMPILE FAILURE.  My sweep grepped for
  "N halfwords differ" and printed 0 when the line was absent -- which is
  also what a failed compile looks like.  CS2000 and CS2110 both showed
  "0 diffs" while actually failing to compile.  Grep for PASS/FAIL
  explicitly, never for the absence of a failure line.
- STILL OPEN, and each is a full deck reconstruction rather than an edit:
    CS2050  the dump is ISS MCS MODING, 734 halfwords against our 394;
            renders legibly end to end, so the material is all there
    CS2000  APCU STATUS, 282 halfwords, all 29 of our PDT params absent
    CS2120  OIU, 884 halfwords
    CS0780  SM SYS SUMM 1, a revision: 4 of its params changed template
            (ANA_ENTRY -> EU_ENTRY, applied, and it compiles now) but it also
            points into #PCS2MDT where ours points into #PCSDMDT, and dfg
            cannot resolve 6 PADR referents after a naive INCLUDE swap.
            NOT COMMITTED -- it does not round-trip and unverified work does
            not go in.
- TOOLING: /tmp/claude-1000/pdtrecover.py generalises the compool recovery
  (any CSECT, any of the nine templates, arrays of copies, scalars from raw
  hex).  Worth a permanent home beside dfgmap.py if more compools come up.
