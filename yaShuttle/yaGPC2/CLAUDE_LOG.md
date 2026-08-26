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
