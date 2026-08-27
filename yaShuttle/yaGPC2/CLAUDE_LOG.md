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

### [2026-08-26] Target: [problems.md]
- CS2000 (APCU STATUS) RECOVERED AND ROUND-TRIP EXACT -- all 282 halfwords of
  the dumped #PCS2000, from a deck reconstructed out of nothing but the dump.
  First of the wholly-different displays.
- THE ENCODING WAS LEARNED, NOT GUESSED, and that is the whole method.  DFG
  annotates its generated .hal with the deck statement that produced each run
  of halfwords, so running dfg over OI340600's 133 decks yields 31,517
  labelled statement instances -- every statement kind's opcode and length,
  and for 65% of a display's statements an exact sequence lookup.
- Hand-decoded from the corpus where lookup did not reach: HEADER=nnnnS is
  0xC000|n (C7D0 -> 2000S, checked against 0620S/1000S/2011S/2021S), and
  VCORDA's FIRST point is x = fcw-0x8400 or -0x7E00, y = 0x916E-fcw or
  0x976E-fcw, in raster units -- validated on all 352 corpus instances.  Its
  SECOND point is NOT a signed delta: sign-magnitude on bit 11 gets 162 of
  352 and fails on horizontal vectors, so it is left uninverted rather than
  shipped half-right.
- TWO TRAPS THAT COST TIME: 3400 is the opcode of BOTH SBC and a display-list
  preamble FCW (told apart by the preamble's null operand), and PAD=n's F000
  terminator ends the statement stream -- without handling it the DDT decodes
  as spurious statements and F000 itself reads as a character.
- AND ONE THAT NEARLY LOOKED LIKE A GRAMMAR PROBLEM: a deck line is read only
  to COLUMN 72.  My first CS2000 deck had 83-character VPARM lines, so dfg
  saw truncated statements and failed to parse.  The corpus wraps them.
- TOOL MOVED AND RENAMED at the user's request: ~/workspace/PFS/decompileDFG.py,
  self-contained (its own DEU charset, cursor geometry and corpus reader) so
  it does not reach into virtualagc.  RTC/TEST/BLT/MDT are inverted from the
  encoding nsts-sdl-dps documents in src/dfg/resolve.py; bitpos is
  (-n)%16 + (bit-1) and the tool assumes n=16, which the corpus says recovers
  BLT 692/722, TEST 927/973, RTC 1965/2297 -- the rest are narrower fields and
  surface as differing halfwords in the round trip.
- TEN ANONYMIZATION TAGS CORRECTED IN OI301700 (CG0500, CS0870, CS2000), each
  a display label rather than a name: ^G -> RN, ^U -> MG, ^vk -> SRM.  Proved
  from the files themselves -- they are original build artifacts, so
  anonymizing the source left the compiled FCWs beside it intact and each file
  states its own original text a few lines below the tag.  Found only because
  the user asked whether OI301700 had the same error: my earlier sweep looked
  for BACKSLASH sequences only, and CV1130's was a caret.  Both corpora are
  now clean of tags inside CHAR=( ).
- CS2050 IS DECOMPILED BUT BLOCKED ON ANOTHER COMPOOL.  The deck comes out
  with only 5 VCORDA and 5 other statements uninverted and 3 unresolved
  names, but dfg refuses it: "12 PADR pointer(s) have no SDF-resolvable
  referent type".  Its MDT statements reference CS2_MDT, whose OI340700
  version we do not have.  CS2_MDT is 755 halfwords, 134 S99Xnnn structures
  each holding a NAME pointer into CSA_PDT and an index, with an FFFF
  terminator -- a mechanical recovery of the same kind as CSA_PDT, and the
  next concrete step.  CS0780 is blocked on the same compool.

### [2026-08-26] Target: [problems.md]
- CS2_MDT IS 192 OF 227 POINTERS RECOVERED, and stuck on the last 35.  The
  compool is 755 halfwords holding TWO kinds of structure, which is what made
  the first attempts wrong:
    * 42 S99Xnnn / S99Znnn entries, a NAME pointer plus an index, each
      followed by an FFFF terminator.  S99X puts the pointer first and S99Z
      puts the INDEX first -- reversed members, same shape.
    * 92 CSDK_n_FCW entries, CSM_MD_TEXT_TABLE, two FCW halfwords of text.
      CSDK_1..4 decode to '    ', '*   ', 'OFF ', 'B   ', matching
      OI340600's CSDMDT.hal exactly, so the table itself is unchanged; the
      numbering is not -- the dump starts at CSDK_1 where OI340600's CS2MDT
      starts at CSDK_37.
  S99Z's pointers are SELF-REFERENCES into this same compool, of the form
  CSDK_n_FCW.CSMK_FCWS$(1:).
- PARSER BUGS FOUND, both silent: an ARRAY member's values sit on their own
  line with no name, so the name column holds the first hex value and the
  line reads as a phantom member; and the second value is past the raw-hex
  column, in the remainder.
- THE BLOCKER IS #PCRATE.  35 pointers target it and the DASS report has NO
  member-level listing for that CSECT -- zero "#PCRATE+" lines -- so the
  names cannot be read off the dump.  They are not in OI340600's CS2MDT
  either: that file's only non-PDT, non-CSDK reference is CPSB_SL_COMM_FLAG1,
  from CPS_SLD.  These are new references.
- BUT THE INFORMATION EXISTS.  #PCRATE MATCHES THE DUMP EXACTLY -- 1396
  halfwords, 0 diffs, membership 'match' -- so OI340600's CRATE.hal IS
  OI340700's, and the member at any offset is determined.  What is missing is
  a way to READ the offsets: the link .json carries only the section symbol,
  and HALSFC's pass2 listing emits the compool as bare DC directives with no
  labels.  The remaining route is the SDF, which dfg already parses.
- SO THE CHAIN IS: CS2050 and CS0780 need CS2_MDT, CS2_MDT needs 35 names
  from CRATE, and CRATE needs an offset-to-name table out of its SDF.

### [2026-08-26] Target: [problems.md]
- ALL TWELVE DIFFERING .dfg DECKS ARE NOW ACCOUNTED FOR.  Exact and
  round-trip verified: CS0780 (1100/1100), CS2000 (282/282), CS2110
  (144/144), CS0790, CDAP15.  Needing NO source change at all, once the
  compools were recovered: CS0620 in both S2 and G9, CS0940, CS2011, CS2021.
  CV1130 was never an OI340700 difference -- an anonymization error in our
  own source.  CS2120 is at 882 of 884 and CS2050 at 733 of 734.
- FIVE COMPOOLS RECOVERED EXACTLY: CSA_PDT 5640/5640, CS2_MDT 755/755,
  CS2_PDT 260/260, CSD_RTC 197/197, CSP_CLB 60/60.
- SPCHAR WAS THE LAST BIG DECODE, and it took two wrong rules.  Only
  0x20..0x5B is writable inside CHAR=( ); everything else is addressed by
  index, c<=0x1E as c+11 and c>=0x5C as c-45.  But the CODE does not decide:
  0x16 is packed with its neighbours in CS2120 and stands alone as SPCHAR=33
  elsewhere, so a code-only rule fixed CS0780 and broke CS2120 by 623
  halfwords.  Nor does the PACKING decide alone: 0x08 has no printable glyph
  and must be SPCHAR even as an odd-length tail, which a packing-only rule
  got wrong in seven places.  The rule is both: no printable glyph -> always
  SPCHAR; otherwise alone-in-a-halfword MID-run -> SPCHAR, same shape at the
  end -> an ordinary tail.
- THE THREE REMAINING HALFWORDS ARE dfg's, NOT OURS.  Word 1 of a RATE entry
  is the group's worst-case FCW draw, which dfg computes rather than reads.
  Tracing its own _content_draw over CS2050's group gives every directive's
  budget and EVERY ONE is a function of the emitted words alone -- 83 from
  the content directives plus 34 from thirteen IMMED groups, 117, where the
  dump has 118.  CS2120's two groups come to 207 and 77 against 213 and 78.
  The emitted words match the dump everywhere else, so the original DFG
  budgeted more for byte-identical content: a gap in dfg's model of the
  original's allowances.  ddt.py itself says the original's budgets sometimes
  exceed the runtime draw and lists the allowances it models; none of these
  groups uses one.  WORTH REPORTING TO DON -- not filed, per the rule that
  outward-facing text is shown first.
- RULED OUT BY EXPERIMENT, NOT ARGUMENT: all ten corpus spellings of the
  ambiguous VPARM format 1412/4018; raising each of the three TEST and three
  BR operands (all make it worse, by changing the emitted displacement); the
  CONV=S-versus-CONV=I ambiguity, which cannot apply since all three VPARMs
  carry sign code 7; and dfg's HEX model, since CS0710 uses 15 HEX directives
  and matches the dump exactly.

### [2026-08-26] Target: [problems.md]
- CORRECTION, USER-PROMPTED.  I said the DASS comparison's database holds a
  "match" that is not one, citing #PCSDRTC as verdict 'ok' with 0 differing
  halfwords against a direct rebuild showing 75.  THE DATABASE IS RIGHT AND I
  MISREAD IT.  The same row's `detail` column says
  "[75 ignored] [43 no reference data]" -- it recorded exactly what happened.
  I read n_diffs and verdict and did not read the field beside them, in a row
  I had already printed.
- THE REAL FINDING IS ONE LEVEL OUT, and it is about the exceptions lists
  rather than the database.  Those 75 were excluded by an exceptions file,
  whose stated purpose is "locations changed after the build (I-LOADs,
  patches, checksums), which no compilation or link can reproduce".  The run
  used exceptions-S2-full.txt, which holds 197 entries inside #PCSDRTC's
  range -- and that CSECT has exactly 197 halfwords with stated values, so
  essentially the whole compool is declared unreproducible.
- IT IS REPRODUCIBLE.  The recovered OI340700 CSDRTCCM.hal compiles to match
  all 197.  A post-build patch is by definition not reproducible from source;
  these are.  So the -full list masks a genuine OI340700 SOURCE difference as
  a build-time artifact, which is the kind of exclusion that hides work.
- TWO LOOSE THREADS, not chased: exceptions-S2.txt (1265 lines) has ZERO
  entries in that range where exceptions-S2-full.txt (46393 lines) has 197,
  yet both carry the identical header claiming to be the locations MAFGEN
  marks with '*' -- they cannot both be that.  And dass-literals.py has no
  --full option, so how the -full variants were produced is not accounted for
  by the tool that claims to produce them.
- LESSON: a results row's summary fields are not the row.  Read the detail
  column before calling a recorded result wrong -- especially when the tool
  that wrote it is one of ours and has been reliable.

### [2026-08-26] Target: [problems.md]
- THE EXCEPTIONS CHAIN, run down after the user recalled its shape correctly.
  dass-literals.py writes the base exceptions-XXX.txt -- the locations MAFGEN
  marks with '*', changed after the build.  dass-versions.py then APPENDS the
  differences attributable to our source being an older release, taking
  --exceptions=BASE.txt and emitting the -full variant: 1262 entries become
  46385, the extra ones carrying value -1 and a REASON in the name field
  ("DCDDG9-revised-CM-to-CN").  The plain file is a strict subset.
- THE SYMS/FIELDS PAIR IS THE OTHER HALF OF THE USER'S RECOLLECTION, and it
  augments the CSECT INDEX rather than the exceptions file: dass-syms.py
  recovers a COMPOOL's CSECT address into augmented-XXX.json, and
  dass-fields.py -- "dass-syms.py's problem one level finer" -- adds the
  addresses of FIELDS INSIDE those compools.  dass-versions.py consumes the
  latter via --fields, precisely because "a reference from an ASSEMBLY module
  into a revised COMPOOL is invisible" without field-level symbols.
- AND THE OVER-BROAD EXCLUSION IS PINNED.  In exceptions-S2-full.txt the
  reason "CSAPCT-revised-BX-to-BY" covers 1210 addresses spanning
  00C6BC..00CC1E.  #PCSAPCT is 00C6BC..00CB56 and #PCSDRTC is
  00CB5A..00CC37, adjacent.  1013 of those addresses are inside CSAPCT and
  legitimately excused; 197 are inside CSDRTC -- the whole of its stated
  halfwords -- and are not.  The marking starts at CSAPCT's own base and runs
  past its end into the next CSECT.
- IT IS DEMONSTRABLY WRONG, not merely suspect: the recovered OI340700
  CSDRTCCM.hal compiles to match all 197.  A difference attributable to a
  revised OTHER compool is not something our own source can reproduce; these
  are reproducible, so they are CSD_RTC's own source difference and the
  exclusion is mis-attributing them.
- LIKELY CAUSE, stated as a hypothesis and not chased: the marking is
  per-reference, not a span (89 separate runs), so references computed from
  OUR layout land past the dump's CSECT end where our compool is larger --
  the same our-layout-versus-the-dump's error that ran through the whole
  .dfg phase.  Testable by re-running dass-versions.py with the recovered
  compools in the fields table.

### [2026-08-26] Target: [problems.md]
- RE-RAN dass-versions.py FOR S2 WITH THE FIELDS TABLE.  THE OVER-RUN DOES NOT
  REPRODUCE.  With --config=S2 --link-dir=work --exceptions=exceptions-S2.txt
  --fields=augmented-S2-fields.json the output has ZERO entries in #PCSDRTC's
  range and ZERO "CSAPCT-revised-BX-to-BY" entries at all -- against 197 and
  1210 in the shipped exceptions-S2-full.txt.
- SO THE SHIPPED FILE WAS MADE WITH INPUTS I DO NOT HAVE.  It carries 46385
  entries where this run produces 17336, and the option I did not supply is
  --asm-link, a FULL-CONFIGURATION link whose .fcm must sit beside it; no such
  file is on disk.  I CANNOT ATTRIBUTE THE OVER-RUN TO A CODE PATH: my reading
  of the self-revised branch was consistent with the arithmetic (the marked
  span CC1E-C6BC+1 = 1379 exactly matches an unclamped walk of a 1379-halfword
  section) but consistency is not reproduction, and the run does not show it.
- AND THE FIX I INFERRED FROM THAT READING WAS WRONG.  Requiring
  owner(address) == section name in the self-revised branch discarded 13418
  legitimate entries across 11 units -- CVNMMUTI 7150, DMPMMMSG 3691, DCDDS2
  1904 -- because A COMPOOL WHOSE STORAGE IS OWNED BY AN ASSEMBLY MODULE HAS
  NO CSECT OF ITS OWN, so owner() returns the enclosing assembly CSECT and the
  clamp rejects every address the compool legitimately claims.  That is the
  very case dass-syms.py exists to handle, and the docstring of owner() says
  so.  REVERTED; dass-versions.py is unchanged from its committed state.
- WHAT STANDS, and it is the part that matters: the shipped
  exceptions-S2-full.txt DOES excuse all 197 of #PCSDRTC's stated halfwords as
  CSAPCT's revision, and the recovered OI340700 CSDRTCCM.hal reproduces those
  197 from source.  A difference caused by another unit's revision is not
  something our own source can reproduce, so the exclusion is wrong whatever
  produced it.  The file is either stale or was generated from inputs that no
  longer exist.
- NEXT STEP IF PURSUED: find or rebuild the --asm-link full-configuration link
  and regenerate the -full files from it, then diff against the shipped ones.
  Until then the -full exceptions lists should be treated as unverified: at
  least one of their entries is demonstrably wrong and cannot be regenerated.
- LESSON, twice in one investigation: an explanation that fits the arithmetic
  is not a reproduction.  I had the span arithmetic land exactly and still had
  the wrong code path, and the "fix" it implied broke eleven units.

### [2026-08-26] Target: [HANDOFF-FCMBOOT.md]
- NO-FCM BOOT IMPLEMENTED.  `gpc run` no longer requires an fcm-file: omit
  it and the GPC IPL pushbutton reads FCMBOOT off the mass memory, exactly
  as Table 2-2 step 10 has the firmware do, and the HALT->STBY release runs
  it.  Needs --mmu-model and --discretes; with an fcm-file nothing changes.
- WHICH VECTOR: always the SYSTEM RESET PSW at 0x14, first release and
  every later one.  FCMBOOT.asm:38 says so outright ("RECEIVES CONTROL FROM
  THE MICRO CODE LOADER VIA THE SYSTEM RESET PSW"), and the image agrees --
  0x0004 is `0000 0000 0002 0000`, address 0 with the WAIT bit, a
  deliberate park; 0x0014 is `014B 0066 0008 0000`, FCMBMOVR in sector 6
  with register set 1.  Measured on BOOT-stamped.fcm itself.
- THE HANDOFF'S LINE 140 IS STALE and contradicts its own address table at
  line 293: it says --power-on takes the system-reset PSW, which stopped
  being true when cpu_power_on() was split out to take 0x04.  Line 293 is
  right ("--power-on is wrong for FCMBOOT, use --ipl").  Fix on next sync.
- IPL IS NOT A MODE-SWITCH POSITION -- user corrected me mid-implementation.
  It is a separate momentary pushbutton (register A bit 3) live ONLY while
  HALT stands, so its bit rides ON TOP of HALT's rather than excluding it.
  discretePanel.py had it as a fourth radio position and could not express
  the real sequence; it now has a real pushbutton, disabled out of HALT.
- THE TAPE DID NOT CARRY THE BOOTSTRAP, which is why this could not simply
  be written.  CON80's MMUDAT1 allocates it -- `FMAIPL2 ALLOC,ADDR=44500,
  BLKS=72` -- and a CON80 card address is TFSBB, so 44500 is file 4 / track
  4 / subfile 5 / block 0.  Our volumes are built from the PASS phase
  manifest, which has no bootstrap in it.  tools/stamp_bootstrap_on_tape.py
  writes one there; the emulator reads only as many blocks as the volume
  actually recorded, so a short image cannot overwrite the memory fill
  behind it with the rest of its own 72-block reservation.
- VERIFIED END TO END.  No fcm-file, panel HALT -> HALT+IPL -> STBY: "IPL;
  memory filled, bootstrap read from MM1 (64 blocks, 32768 halfwords)" then
  "HALT -> STBY; reset released, starting at 0x0014b" -- FCMBMOVR.  The
  distinct SVC NIAs reached (1b57, 1cda, 1f35, 2122, 29a6) are IDENTICAL to
  the canonical `--ipl BOOT-stamped.fcm` run, so the tape-loaded boot and
  the file-loaded one behave the same.  A SECOND IPL reloads and re-runs;
  IPL pressed in STBY is refused.  Pre-existing test failures unchanged
  (test_debugger.sh, test_cpu_instr_exec, test_iop_bce_exec,
  test_iop_msc_exec all fail identically on a clean tree).
- WHY RELOAD IS LOAD-BEARING, not housekeeping: FCMBOOT's External Zero
  handler does `OST R5,FCMBSYRS+2`, setting the WAIT bit in its own system
  reset PSW.  An already-booted in-memory FCMBOOT therefore PARKS on the
  next release; re-execution works only because a fresh IPL puts a pristine
  copy back.  That is what makes keeping step 10 and step 11 apart matter.
- NOT DONE: the GUI panel change is untested -- no display here.  Its logic
  parses and _build() precedes _republish(), so the widget exists before
  the first publish, but somebody should actually press the button.

### [2026-08-26] Target: [HANDOFF-FCMBOOT.md]
- THE FIRMWARE IPL NOW GOES OVER THE BUS, and through the INSTALLED
  SERVICER rather than any particular mass memory.  Two user corrections,
  both right: reading the volume directly models a wire that does not
  exist (the MMU is a separate box; the bus is the only path to it), and
  calling mmumodel_service() directly would have worked with exactly one
  MMU -- ours -- when Don's lives on the far end of --bce-network.  It now
  issues POSITION / EXTENDED BLOCK / READ and drains the reply queue
  through iop.servicer, with the bus picked by the panel's IPL-source bits
  (MM1 = BCE 18, MM2 = BCE 19).  --mmu-model is no longer required when no
  fcm-file is given: --bce-network will do instead.
- WHICH ALSO FIXED THE READY INDICATOR, the symptom that exposed the first
  problem.  Bypassing the bus left MM READY undisturbed, so a load gave the
  crew panel no sign of itself.  Draining the real queue makes READY fall
  and rise on its own, because it is derived from that queue.  A synthetic
  busy-timer written for this is gone again -- it was treating the symptom.
- AND THE TRANSFER IS PACED TO REAL TIME, a block at a time.  Drained flat
  out it dropped READY for ~20 ms against a panel that republishes every
  250 ms, i.e. invisibly.  Now 1.80 s, measured on the wire (READY low
  3.44 -> 5.23 s), matching 72*512 + 71*256 = 55040 word times at 33 us.
  --time-scale still shortens it.
- THE STAMPER NOW WRITES THE WHOLE 72-BLOCK ALLOCATION, padding past the
  image with the C6C6 the FMAIPL2 ALLOC's own INIT= names.  A bus reader
  asks for a fixed block count and cannot be told which blocks were ever
  recorded -- an unrecorded one simply reads back as zeros -- so the
  earlier "stop at the first unrecorded block" trick was only possible
  through the back door that has now been removed.
- VERIFIED.  An isolated test issuing that exact command sequence against
  the model collects all 36864 halfwords and matches BOOT-stamped.fcm
  BYTE FOR BYTE over its 32512, with C6C6 in the tail.  End to end: "read
  from MM1 (BCE 18) over the bus (72 blocks, 36864 halfwords)" then
  release at 0x0014b; second IPL reloads and re-runs; IPL in STBY refused.
  Same four pre-existing test failures, unchanged.
- ~/ipl-demo/mmu2-boot.mmv is the tape, re-stamped to the full allocation
  (1157 blocks).  mmu2.mmv there is untouched and carries no bootstrap.

### [2026-08-26] Target: [problems.md]
- CON80 CARD ADDRESSES ARE FTSBB -- file, track, subfile, two-digit block.
  I had written TFSBB in the bootstrap tool and in run.c.  The phase
  manifest settles it: card 43000 is address 3/4/0/0, and the manifest's
  address string is track/file/subfile/block -- the ONLY reading under
  which all 1085 blocks of a built volume are accounted for, checked over
  all 24 permutations.  So the first card digit is the FILE.  The
  bootstrap's own 44500 is unaffected, file and track both being 4, but
  the comments were wrong and are fixed.
- RETRACTED, before it misleads: "the tape's phase 2 is truncated, 114 of
  154 blocks".  It is not.  That was the wrong decoding above.  The
  manifest claims 1085 blocks and the volume holds exactly 1085; every
  block described is present.  The check that caught it was arithmetic
  the wrong answer could not survive -- count what the manifest claims and
  count what the file holds -- and it is the check to run FIRST next time,
  before reading anything into which blocks appear missing.
- STEP 12/13 (select system, then RUN -> OPS 0) IS NOT DIAGNOSED.  What is
  established: the DIA bit map in FCMDSCRM.asm is the flight software's own
  and confirms HALT/STBY/RUN/IPL as bits 0/1/2/3, matching yaGPC2, Don's
  gpc and discretePanel; RUN is DI02 = bit 2, a discrete the SOFTWARE
  reads, and iop_discrete_overlay lets a published bit win, so the
  plumbing is right; run.c does nothing on STBY->RUN, which is correct
  because RUN is not a reset action.  Keyboard entry is not the suspect
  either -- ITEM 18/19/27+n/28 already match Don's video.
- WHAT TO CHECK NEXT: whether GPCIPL/SSL actually completes the phase 2
  load and transfers, versus never seeing the RUN discrete.  The two are
  distinguishable without MEDS: per Table 2-2 step 11, WITHOUT step 6 (BFC
  CRT display switch ON) there is no menu at all -- SSL loads PASS area 1
  phase 2 by itself and goes straight to step 13.  So a run with no BFC
  CRT discrete asserted should reach TB-RUN unaided, and moving to RUN
  should enter OPS 0, with no keyboard entry anywhere in it.  That isolates
  the discrete from the menu path.

### [2026-08-26] Target: [problems.md]
- HOW THE SSL ACTUALLY LOADS A PHASE, which is the thing to instrument for
  the "no MMU activity after ITEM 1" report.  FCMINSSL.asm (SYSTEM SOFTWARE
  LOADER, "CALLED BY THE GPCIPL") does not command the mass memory from the
  CPU at all.  It names FCMBCMMR "MMU 1/2 READ BCE PROGRAM" and FCMINMMP
  "MMU 1/2 POSITION TAPE BCE PROGRAM" and FCMINMSC "SSL MSC PROGRAM", and
  at "START MSC/BCE PROCESSING" it does exactly three processor commands:
  load the MSC PC, load the BCE PC, then start the MSC.
      FCMIOPPC EQU X'A201'   BCE/MSC PROGRAM PC LOAD
      FCMSCBSY EQU X'9204'   MSC BUSY
- BOTH ARE IMPLEMENTED.  I first concluded A201 was not -- there is no
  `case 0xa201...` in iop.c's PCO switch -- and that was WRONG: it decodes
  to devSelect 0x08, the Local Store path, dataSelect 0x002 = region 0,
  bank 0, word 2, which iop.c's own comment identifies as the MSC's program
  counter.  The BCE 18 form (X'A201' | 18<<4 = X'A321') decodes to region
  18, word 2, that BCE's PC.  Checking the switch alone would have produced
  a confident wrong answer; the decode is what settles it.
- SO THE FAILURE SPLITS CLEANLY IN TWO, and there is an env var for each:
  YAGPC_DISPTRACE=1 prints "DISP LOADMSCBUSY" every time the CPU starts the
  MSC, and YAGPC_MMUTRACE=1 prints every MMU command.  After ITEM 1 EXEC:
  no LOADMSCBUSY means the SSL never got as far as starting its loader;
  LOADMSCBUSY but no MMU lines means the MSC/BCE program was started and
  did not reach the tape, which is ours; both present means the read
  happened and the fault is later.

### [2026-08-26] Target: [problems.md]
- TWO CAUSES OF "MODE FLIPPING", one mine in the worst sense and one a
  real emulator bug.  User reported RUN and STBY alternating in the yaGPC2
  terminal while the switch sat on STBY, and GPCIPL never running.
- FIRST: MY OWN TEST PANELS WERE PUBLISHING INTO THE USER'S SESSION.  The
  discretes bus is machine-wide multicast, and several of my scripts end
  with long RUN phases -- nomenu.py holds RUN for 300 s, ops0test.py for
  240 s.  A stray one drives RUN into every emulator on the machine,
  including one the user is running.  With the strays killed and the stale
  window waited out, the emulator alone reports ZERO mode changes.  A
  sender socket is not bound to 6980, so `ss` cannot see a publisher --
  only `ps` can, and it must be checked BEFORE concluding anything about
  discretes.  Every test script must be short-lived or explicitly killed.
- SECOND, AND REAL: SILENCE WAS BEING READ AS A SWITCH POSITION.  run.c
  substituted MODE_HALT whenever nothing was published and then ran the
  edge tests against it, so one lost datagram -- or a Tk panel falling
  behind DISCRETES_STALE_SEC once -- read as HALT, and the panel's return
  read as a HALT->STBY release, which calls cpu_reset().  Repeatedly.  A
  machine reset every second or two never gets anywhere, which is exactly
  "GPCIPL does not run".  Edges are now taken only between positions the
  panel actually published; a gap leaves the last one standing.  Measured:
  4 deliberate 2.5 s dropouts, 1 release (was 1 per dropout).
- ALSO: the no-position instant between "clear the old bit" and "set the
  new one" was being reported as a mode change, which is where pairs of
  MODE lines for a switch nobody touched came from.  Now held, not
  reported.  Same test: 5 MODE lines total, no flapping.
- I DISMISSED THIS OSCILLATION TWICE as a test-harness artifact, in my own
  logs, before the user reported it from the GUI.  It was in front of me
  both times.
- YAGPC_MODETRACE=1 prints driven/value/mode/prev on every mode change;
  that is what separated the two causes and is worth keeping.

### [2026-08-26] Target: [HANDOFF-FCMBOOT.md]
- WHY ITEM 1 MAY LOAD NOTHING.  The chain for "select system to be loaded"
  is CM4KYBD (items 1-17) -> LOADCHCK (minor cycle 1) -> SSLCHECK (minor
  cycles 2-11, 24) -> the SSL.  LOADCHCK's own description states the
  precondition:
      IF THE DEU IS NOT SELECTED OR THE DEU FORMATS HAVE NOT BEEN SENT
      THEN SCHEDULE 'CM4FMAT' TO SEND THE OFT CRITICAL FORMATS (MM AREA 1)
      TO THE DEU AND EXIT.
  So an ITEM 1 with formats not yet sent does NOT load PASS: it sends
  formats and exits.  Table 2-2 step 9, "DEU LOAD - Push, then release
  (Menu IPL only)", is what normally sends them -- and nothing here models
  a DEU LOAD pushbutton.
- WHICH MEETS A CLAIM THIS PROJECT ALREADY RETRACTED: "the Display Control
  Program came off our tape and went into the display unit" was withdrawn
  because DCPLDFL is only a flag BSL1 sets when its transaction finishes,
  with real data or without.  If the formats never actually reached the
  DEU, LOADCHCK takes the CM4FMAT branch EVERY time and ITEM 1 can never
  reach the load, however often it is pressed.  That fits the report
  exactly: item accepted, nothing loads, GPCIPL carries on.
- CHEAP TEST FOR THE USER: press ITEM 1 EXEC TWICE.  If the first press
  only sends formats, the second should reach SSLCHECK and the tape.  If
  neither does anything, the formats are not arriving and the DEU side is
  where to look, not the mass memory.
- NOTE the CM4FMAT path reads MM AREA 1, so it is itself MMU activity.
  "No MMU activity at all" therefore argues the CM4FMAT branch is not
  completing either, rather than merely being taken.

### [2026-08-26] Target: [HANDOFF-FCMBOOT.md]
- ADDRESSES FOR BISECTING "ITEM 1 DOES NOTHING", from
  donroute/IPL/IPL.sym.json, whose sections are at absolute addresses:
      CM4KYBD  0x21cc   keyboard handler for items 1-17
      LOADCHK  0x2c8b   schedules the load (minor cycle 1)
      CM4FMAT  0x271f   the "formats not sent -> send them and EXIT" branch
      SSLCHECK 0x2d10   checksums the SSL (minor cycles 2-11, 24)
      FCMINSSL 0x6fbc   the loader itself
  The chain is CM4KYBD -> LOADCHK -> (CM4FMAT | SSLCHECK) -> FCMINSSL, so
  --break at each says where it stops.  CM4KYBD doubles as the control: if
  it does not hit when ITEM 1 is pressed, the tape-booted GPCIPL is not at
  these addresses and nothing further can be concluded from them.
- USER REPORTS THE ITEM IS ACCEPTED -- an asterisk appears beside it on the
  display when it takes, and it took.  So CM4KYBD ran and the failure is
  downstream of the keyboard.  Pressing twice changed nothing.
- A SIDE QUEST THAT WENT WRONG AND IS REVERTED.  I tried making --symbols
  work on a tape boot (it is silently ignored, since the no-fcm path
  returns before symbols load).  It segfaulted; I chased it through
  halucp_init_from_symbols and print_section_map and added NULL-name
  guards, writing in the comment that IPL.sym.json "includes entries whose
  name is null".  IT DOES NOT -- 0 of 13 sections and 0 of 2982 symbols
  have a null name.  The real cause was my own patch loading the table a
  second time on top of the existing load.  Guards and patch both reverted;
  nothing of it is committed.  --break by ADDRESS needs no symbols and
  works on a tape boot, which is what the bisect above uses.

### [2026-08-26] Target: [HANDOFF-FCMBOOT.md]
- WHY ITEM 1 LOADS NOTHING: SSLCHECK's checksum fails, so SSL70 -- the path
  that master-resets and passes control to the loader -- is never taken and
  FCMINSSL is never entered.  Established by breakpoint: LOADCHK 0x2c8b HIT,
  SSLCHECK 0x2d10 HIT, CM4FMAT 0x271f NOT hit, FCMINSSL 0x6fbc NOT hit.  And
  by trace: the last mass-memory command of a whole run is at t=13.7 s while
  the keypress is at t=97.2 s -- 99 seconds of silence after ITEM 1.
- THE CHECKSUM IS A BUILD PRODUCT, and the user said so before I found it.
  FCMCKSUM.asm: "FCMCKSUM WILL CONTAIN THE LENGTH OF THE SSL AND ITS
  ASSOCIATED CHECKSUM.  THE CHECKSUM WILL BE GENERATED BY THE MASS MEMORY
  BUILD PROGRAM.  ALSO, THIS DATA CSECT MUST BE THE LAST CSECT IN PHASE
  ONE."  Declared `DC H'0'` and filled in when the phase is written to tape.
  I had concluded nothing anywhere stamps them.  Wrong.
- AND OUR TAPE CARRIES IT.  0x2958 sits at 0x739D, and that is EXACTLY the
  low 16 bits of the sum of the 988 halfwords from SSLSTART (0x6FBC up to
  FCMCKSUM) -- a 1-in-65536 coincidence otherwise.  So the MM build ran, the
  algorithm is a plain 16-bit sum, and the span is SSLSTART..FCMCKSUM.
- THE DEFECT IS PLACEMENT, NOT ABSENCE.  Our link map:
      6FBC 934 FCMINSSL   7362 18 FCMINBCE   7374 4 FCMINMSC
      7378  32 LOADTBLE   7398  4 FCMCKSUM
  FCMCKSUM therefore ends at 0x739B, but LB4 runs to 0x739D and the checksum
  is in its last halfword.  For SSLCKSUM to land on 0x739D, FCMCKSUM would
  have to start at 0x739A -- two halfwords later than we place it.
- CORROBORATION, though not proof: LOADTBL.asm's own comments carry the
  original addresses, ITEM1 at 726A through ITEM16 at 7279.  We place
  LOADTBLE at 7378, 270 halfwords later, so our SSL-region layout does not
  match the build those comments came from.  They may be from an older
  release -- the module's update record spans 1978-1988 -- so this is
  suggestive of a layout difference, not yet a measurement of one.

### [2026-08-26] Target: [HANDOFF-FCMBOOT.md]
- RETRACTED, AGAIN: "the checksum is present at 0x739D and SSLCKSUM is two
  halfwords early, so lnk101 misplaces FCMCKSUM."  Wrong.  mmbstamp.py's own
  docstring says every load block carries a 2-hw checksum tail that the
  block INCLUDES -- "lb_len = roundup_fullword(extent_end) + pad - start + 2"
  -- so LB4's 994 is 992 content plus that tail, and 0x2958 is the LOAD
  BLOCK's checksum, not the SSL's.  Verified: LB4 content 992 hw sums to
  0x2958 and its tail slot reads 0000 2958.  lnk101's placement of FCMCKSUM
  at 0x7398..0x739B is correct.
- SO THE ORIGINAL READING STANDS: SSLENGTH and SSLCKSUM are genuinely zero
  because nothing stamps them.  FCMCKSUM.asm says the MASS MEMORY BUILD
  PROGRAM should; our reconstruction writes per-load-block checksums but not
  this one.
- CH/AH PUT HALFWORDS IN THE HIGH HALF (exec_AH/exec_CH: `<< 16`), so the
  sum accumulates in R4's top 16 bits with carries falling off and
  `CH R4,SSLCKSUM` reduces to (sum mod 2^16) == SSLCKSUM.  A plain 16-bit
  sum is what is wanted; an earlier worry that no 16-bit value could match
  came from assuming sign extension into the low half.
- tools/stamp_ssl_checksum.py WRITTEN, and it does not fix ITEM 1.  Tried
  two spans: SSLSTART..FCMCKSUM (988 hw, cksum 0x2958) and SSLSTART..SSLEND
  using the link's own SSLEND equ at 0x72E2 (806 hw, cksum 0xCB2C).  Neither
  produces a phase-2 read.  The tape is restored to its unstamped state; the
  tool and the backup .prestamp remain.
- METHOD WARNING FOR WHOEVER PICKS THIS UP: these runs are NOT
  deterministic.  --real-time plus an external gpcmd process means a single
  breakpoint hit-or-miss is weak evidence, and I treated several as strong.
  SSLCHECK 0x2d10 hit on one run and not on a later identical one.  Repeat
  each observation before building on it.
- USEFUL ADDRESSES, all absolute, from IPL.sym.json:
      SSLCHECK 2d10  SSL20 2d18  SSL30 2d23  SSL60 2d26  SSL62 2d2b
      SSL70    2d38  SSL75 2d46  SSLXIT 2d70  SSLRTN 2d72  STERROR 180c
      LOADCHK  2c8b  CM4KYBD 21cc  CM4FMAT 271f  RTNEX0 14e4
      SSLSTART 6fbc  SSLEND 72e2  SSLENGTH 7398  SSLCKSUM 739b

### [2026-08-26] Target: [HANDOFF-FCMBOOT.md]
- ROOT CAUSE FOUND AND FIXED, and the earlier retraction was itself wrong to
  give up on: SSLENGTH really is the defect.  With it zero, SSLCHECK's
  `BCT R3,SSL30` decrements BEFORE testing, so a count of 0 underflows and
  the checksum loop never ends.  Measured deterministically: SSL30 HIT,
  SSL60 (the instruction after the BCT) NEVER.  It is not that the checksum
  mismatches -- the comparison is never reached at all.
- WITH SSLENGTH AND SSLCKSUM STAMPED the whole chain completes:
      SSL30 HIT   SSL60 HIT   SSL70 HIT   SSL62 not hit   FCMINSSL HIT
  and the load actually happens:
      BITE STATUS / POSITION 3/4/0 / EXTENDED BLOCK / READ
      mmu1: read 154 block(s) from 3/4/0/0     <- PASS area 1 phase 2
  That is the read that never occurred, on any earlier run, ever.
- THE SPAN IS SSLSTART..SSLEND, 806 halfwords, from the link's own SSLEND
  equ at 0x72E2 -- NOT SSLSTART..FCMCKSUM (988), which I tried first.
  CAUTION FOR ANYONE REVISITING: the checksum cannot validate the span,
  because the value is computed FROM the span, so any choice is
  self-consistent and will pass.  SSLEND is the principled basis, not the
  passing test.  A real MMB-built tape would settle it.
- WHY EARLIER STAMPING "DID NOT WORK": it was tested on the networked,
  real-time, gpcmd-driven vehicle, which is NONDETERMINISTIC.  The same
  breakpoint hit on one run and missed on the next.  Every conclusion
  before the deterministic harness existed should be treated as unproven.
- THE DETERMINISTIC HARNESS, which is the reusable part:
      ./yaGPC2 run --ipl --deu-model --mmu-model TAPE --discrete-b 20000000 \
          --max-steps N [--break=ADDR] BOOT-stamped.fcm
  No crew panel, no gpcmd, no --real-time: two runs are byte-identical.
  --discrete-b 20000000 is new (GPC 1, NO CRT selected) and is what makes
  the NON-MENU path reachable -- SSL loads by itself, no keyboard needed,
  so the whole question can be studied without MEDS.
- NEXT DEFECT, ALREADY VISIBLE: the read is commanded but not collected.
  wordsOut 107012 against wordsTaken 28164 -- and 28164 is essentially just
  the 55-block GPCIPL read (28160).  So phase 2's 78848 words stream past
  and the bus program takes almost none of them.  That is the next thing to
  chase, and it is ours, not the tape's.

### [2026-08-26] Target: [problems.md]
- SECOND DEFECT, AND THIS ONE IS OURS: `#BU@` was not indirecting.
  exec_BU_at computed `a + 2*curPE` -- the right per-bus TABLE ENTRY
  address -- and then branched TO it instead of THROUGH it.  The SSL's MMU
  read program ends with `#BU@ FCMBCEBT`, which is how it chains to the
  receive sequence that collects the tape data, so BCE 18 landed on the
  table itself at 0x72CC, decoded its 0000 as an unknown instruction, never
  advanced, and spun there for the rest of the run.
- THE FLIGHT SOFTWARE SAYS WHAT THE TABLE IS.  FCMINSSL.asm:
      FCMBCEBT EQU   *-36                MMU 1/2 BRANCH TABLE
               DC    A(FCMIBLK1)                          BUS 18
               DC    A(FCMIBLK1)                          BUS 19
  -36 is 2*18, so the bias is exactly what makes `2*busnum` index it, and
  the entries are A() ADDRESS CONSTANTS.  exec_CMD already reads its own
  per-bus table the same way -- `addr = a + 2*curPE` then iop_g_eaf --
  so the addressing family was already right there in the file.
- EFFECT, measured on the deterministic harness:
      unknown-instruction lines  3,369,393 -> 0
      wordsTaken                 28,164    -> 98,820   (of 107,012)
      log size                   3.37M lines -> 18
  The PASS phase-2 data is now actually collected instead of streaming past.
- 300 #BU@ FIXTURES DISAGREE WITH ME, and I am flagging that rather than
  burying it.  test_iop_bce_exec expects NIA = a, with no bus offset and no
  indirection -- a third behaviour that neither the old code nor the new one
  produces.  They were ALREADY failing before this change: 300 failures and
  73799/74699 both with and without it, verified by stashing.  So nothing
  regressed, but something is unresolved.  Two reasons to doubt the
  fixtures rather than the change: their memory image is only 4096
  halfwords, so an indirect fetch to 0x15F17 cannot be represented at all
  -- they cannot exercise a dereference even in principle -- and gpc, the
  likely oracle, is documented here as non-authoritative.  Whoever settles
  this should do it against the POO, not against either implementation.
- NEXT FRONTIER, newly reachable: the boot now completes the phase-2 load,
  transfers control, and dies at
      ERROR: invalid instruction 0xc2d9 at 0x8a2d
  which is further than this has ever run.

### [2026-08-26] Target: [problems.md]
- WHERE THE BOOT NOW DIES, which is new ground.  With both fixes in, phase 2
  loads, its data is collected, control transfers into it, and then:
      [22762631] 0072ac FCMINSSL+02f0: 6bed  MVH 3,5
      [22762632] 000a3b        +0a3b: c7f3 8a2d  BC 7,X'8a2d'
      [22762633] 008a2d              : c2d9  ??? (invalid)
  0xc2d9 matches no pattern in the decode table, so this is a wild branch,
  not a missing opcode.
- 0x0a3b IS PASS CODE, not GPCIPL.  It falls inside phase 2's LB2
  (0x00676..0x02ea5), so it was overlaid by the load that just completed;
  the trace labels it "GPCIPL+0a3b" only because the symbols loaded are
  GPCIPL's.  Do not be misled by that label -- after a phase-2 load the
  low-memory symbol names are stale.
- THE LEAD, and it is only a lead: phase 2's LB7 covers 0x1811a..0x1ac8b in
  SECTOR 1, which contains 0x18a2d.  The branch went to 0x008a2d.  The PSW
  low halfword reads 0011 across the transition, and FCMBOOT's own PSA uses
  X'0066' for "BSR & DSR := SECTOR 6", so 0011 reads as BSR 1 / DSR 1 --
  which would make the intended target 0x18a2d, squarely inside loaded PASS
  code, and 0x008a2d an unsectored version of it.  That points at the base
  sector register not being applied to a branch target.
  AGAINST that reading: the instructions immediately before resolve at
  sector-0 addresses (0071bb etc.) with the same 0011 in the PSW, and they
  are correct there.  So either the field is not BSR/DSR in this display, or
  it applies to some fetches and not others.  RESOLVE THAT BEFORE ACTING --
  it is exactly the kind of half-fitting explanation that has cost several
  wrong turns today.

### [2026-08-27] Target: [problems.md]
- CORRECTED: #BU@ IS DIRECT, AND I WAS WRONG TO MAKE IT DEREFERENCE.  The
  user checked the POO: "the next instruction is found at the address
  specified by the operand, plus twice the BCE number."  That is exactly
  what the code already did.  Reverted.
- THE REAL GAP IS OPCODE 0, and the user reached it independently: the `@`
  IS the +2*BCE# table indexing, so ADDRESS names the start of a table and
  what sits at ADDRESS+2*BCE# must itself be a branching instruction.  It
  is: opcode zero is a BRANCH whose encoding is exactly an address
  constant -- fourteen zero opcode bits then the same 18-bit address field
  #BU uses.  That is why `DC A(FCMIBLK1)` works as a jump-table entry, and
  why FCMINSSL can call the thing a BRANCH TABLE.  Decoding the entry at
  0x72CC gives a branch to 0x72F2 = FCMIBLK1, the receive sequence the
  read program has to chain to.
- MEASURED, same as the wrong fix achieved but now consistent with the POO:
  unknown-instruction spins 1,551,211 -> 0, wordsTaken 28,164 -> 98,820 of
  107,012, wordsLost 0.  gpc does not implement opcode 0 either and its BCE
  opcode set is otherwise identical to ours, which is what let the gap
  survive.
- ONE TEST NOW FAILS, and the reason is exact: test_iop_exec_processors'
  bce_unknown writes 0x0000 as "a BCE opcode word that matches no entry in
  the dispatch table" and asserts the PC parks.  0x0000 is now a branch to
  0, so the PC goes to 0.  The test's PREMISE is what the change
  invalidates, not its intent.
  NOT RESOLVED: substituting 0x4000 (which matches no pattern) did not
  restore it -- the BCE never reported an unknown instruction at all, so it
  never fetched the marker, which points at the harness rather than the
  marker.  I stopped rather than keep guessing, and left the test exactly
  as it was.  Whoever picks this up should find why the marker is not
  fetched BEFORE editing the test.
- STILL UNCONFIRMED, and it is the one question worth putting to the POO:
  is opcode 0 a defined BCE instruction, and is it a branch?  Everything
  above is forced by the flight software's own table construction, not read
  from the manual.

### [2026-08-27] Target: [problems.md]
- BACKED OUT the invented BCE opcode 0.  User: "0x0000 is `ADD R0,0(R0)`."
  Verified in our own CPU table -- pattern 00000xxxddddddbb, so 0x0000 is
  A R0,0(R0).  My basis for calling opcode 0 a branch was inference from
  the branch table's contents, not the manual, and it is contradicted.
- AND A MEASUREMENT I GOT WRONG, which matters more than the change.  I
  told the user the 300 #BU@ fixtures "were already failing, 300 with and
  without the change, verified by stashing."  THEY WERE NOT.  With #BU@
  direct -- the POO's behaviour, and what the code has always done -- all
  300 PASS: the suite is 74099/74699, and the only BCE failures are 300
  #MOUT@ and 300 #MIN@.  My dereference broke them and I reported the
  opposite.  The stash comparison produced identical numbers because the
  rebuild between the two halves did not take, so I measured one binary
  twice and called it a control.  A control that agrees to the digit with
  the thing it is controlling for is a control that did not run.
- SO THE PUZZLE IS OPEN AGAIN, and it is worth stating exactly:
    * The POO says #BU@ resumes at operand + 2*BCE#.  Direct.
    * FCMINSSL points it at FCMBCEBT, whose entries are `DC A(FCMIBLK1)`.
    * For BCE 18 that lands on 0x72CC, holding 0000 72F2.
    * The BCE decoder has 21 opcodes and none matches 0000, so it parks
      there and the transfer it just commanded is never collected.
  One of those four must be wrong.  The entry is an address constant, not
  a BCE instruction; either the BCE does something with 0000 that is not
  in our table (and not the CPU's ADD, a different decoder), or #BU@ does
  reach through it after all, or our table address is not the one the real
  build would produce.
- BOTH CANDIDATE FIXES PRODUCED IDENTICAL CORRECT BEHAVIOUR -- dereference
  at #BU@, or opcode 0 as a branch -- which is why neither can be chosen on
  the evidence of the boot working.  Only the POO can separate them.

### [2026-08-27] Target: [problems.md]
- SETTLED, FROM THE FLIGHT SOFTWARE: a BCE branch-table entry holds an
  ADDRESS, so #BU@ takes the word at operand+2*BCE# as its target.  The
  user asked how to find the instruction; looking it up produced the proof.
      FCMINBCE.asm:82   #BU@ FCMBCEBT    (last instr of FCMBCMMR, line 77)
      FIOMUWP9.asm:92   #BU@ FIOBBM      "EXECUTE CORRECT NO. OF TDL SEQUENCES"
  FIOBBM is the decisive one.  FIOCBLKS.asm:537 declares it
      ENTRY FIOBBM / DS 0F / FIOBBM EQU *-36 / DC 2F'0'
  -- two fullwords of ZERO, same -36 bias -- so an entry cannot be a static
  instruction.  And FIOMGDSP.asm:750 fills it in:
      LA R2,FIOBBM+2    GET MM BRANCH TABLE ADDRESS
      ST R7,0(R3,R2)    STORE ADDRESS IN BCE ENTRY
  with the module header calling FIOBBM a "MM BRANCH ADDRESS TABLE".
  Entries are computed addresses, written at run time.  FCMBCEBT is the
  same construct with addresses known at assembly time, hence DC A(...).
- WHICH MEANS THE POO WORDING IS THE INDIRECTION, read as "the next
  instruction is found at the address [held at] operand + 2*BCE#".  No new
  opcode is needed and opcode 0 stays undefined, consistent with the user's
  "0x0000 is ADD R0,0(R0)".
- I REPORTED THE #BU@ FIXTURES THREE DIFFERENT WAYS, ALL WRONG.  First
  "300 disagree with the change"; then "they pass with direct, my change
  broke them"; the verified answer, from a forced-rebuild A/B, is that
  BOTH behaviours give 74099/74699 with ZERO #BU@ failures -- the fixtures
  do not discriminate, because their memory image is 4096 halfwords and the
  addresses involved sit far above it.  Every wrong version came from
  measuring a binary that had not been rebuilt.  `touch` the source, or
  check the timestamp, before believing an A/B in this tree.
- STATE: dereference restored on the evidence above; boot spins 0, phase 2
  read, wordsTaken 98,820 of 107,012; `make test` at its four pre-existing
  failed stages.

### [2026-08-27] Target: [problems.md]
- HOW FCMIBLK1 GETS FILLED IN -- the open question, answered.  THE SSL
  WRITES THE BCE PROGRAM AT RUN TIME, instruction by instruction, into the
  work area.  FCMINSSL.asm:616-624:
      OHI  R5,FCMMLBR      ADD IN SKELETON #LBR INSTRUCTION
      LH   R2,FCMRSADD     GET 1ST/NXT RECEIVE SEQUENCE ADDRESS
      ST   R5,0(R2)        STORE INSTRUCTION IN BCE PROGRAM
      LA   R2,2(R2)        BUMP BCE PROGRAM ADDRESS TWO
      LHI  R4,FCMMRDLI     YES, GET SKELETON #RDLI INSTRUCTION
      ST   R4,0(R2)        STORE IT IN BCE PROGRAM
  The "skeletons" are bare opcodes -- FCMMLBR EQU X'F200' (#LBR), FCMMRDLI
  EQU X'F300' (#RDLI), FCMMWAT EQU X'0800' (#WAT) -- OR'd with computed
  operands (a load block's base address, its 512-halfword block count) and
  stored through FCMRSADD, which points at FCMIBLK1 then FCMIBLK2
  alternately (lines 747-749 swap them, so the two areas double-buffer).
  So the receive sequence is generated per load block, not static.
- THAT MAKES THE WHOLE PICTURE CONSISTENT:
    * FCMIBLK1 is `DS 10F` in the DYNAMIC WORK AREA -- scratch, all zero
      until the SSL writes code into it.
    * The branch table therefore has to hold its ADDRESS, which is why
      #BU@ dereferences.
    * And the checksum span stops at SSLEND, which IS FCMDATA -- the same
      address, 0x72E2 -- so the sum covers code and constants and excludes
      the work area.  SSLENGTH = SSLEND - SSLSTART = 806 was right for that
      reason, not just because it was the available symbol.
- TWO OF MY OWN COUNTS WERE WRONG, both from a regex that excluded '_':
  the BCE has 24 instructions, not 21 -- #RIB, #SIB and #WAT were missed --
  and I briefly claimed #WAT was undecoded when it is right there at
  iop_bce_instr.c:440, "00001___________".  0x0000 really is undecoded,
  which the runtime already showed.

### [2026-08-27] Target: [problems.md]
- THE 0x8a2d "WILD BRANCH" IS A SYMPTOM, NOT THE FAULT.  Full-width trace:
      0072ac FCMINSSL+02f0: 6bed MVH 3,5
             R00..R07 ALL change, PSW1: 72acc011->0a3b0011, PSW2 cleared
  Every register changing at once with a new PSW is an INTERRUPT WITH A
  REGISTER-SET SWITCH, not a move.  MVH faulted, the trap dispatched
  through a PSA vector, and landed at 0x0a3b -- which PASS phase 2 has
  OVERLAID -- so the "handler" is now PASS data, which promptly executes
  `BC 7,X'8a2d'` into the error-env stack and dies on 0xc2d9.  Chasing
  0x8a2d or 0xc2d9 as a missing opcode is chasing the wrong end; 0xc2d9 is
  genuinely undecoded but it is data, and memory there was legitimately
  written by the SSL's own move loop (watchpoint: c9fb -> c2d9 by NIA
  0x071bd).
- WHY MVH FAULTED: it was handed dest=0, count=4096, src=0 -- a 4096
  halfword move from 0 to 0, straight into store-protected low memory.
  R3 = 0x00001000 and R5 = 0x80000000 at the call.
- AND WHY THOSE OPERANDS: FCMMOVE (0x72a1) reads them from a BCE context
  struct via R0, and the trace shows `L 3,X'0000'(0)` leaving R3 UNCHANGED
  AT ZERO -- so the struct is all zeros.  FCMINSSL only populates it
  conditionally:
      IF (CHI,R4,GT,FCMLOWSC)  IF SECTOR > 7 (ABOVE 128K ADDR) ?
      STH R4,TFCMTGTS / SRL R5,1 / STH R5,TFCMTGTA
  so FCMMOVE is for load blocks ABOVE 128K only, and the struct stays zero
  for low ones.  Either FCMMOVE is being reached for a low block when it
  should not be, or the struct pointer is wrong.
- NEXT SUSPECT, and it is a known family here: the struct is selected by
      LA R0,FCMBCTXT / LH R3,FCMNEXTS / LH R0,0(R3,R0)
  an INDEXED load.  problems.md already records one POO 14.1 index-scaling
  defect (LM/STM/LPS take a halfword index despite fullword operands).  A
  wrong index here would fetch the wrong struct address and give exactly
  the all-zero struct observed.  CHECK THE SCALING OF `LH` WITH AN INDEX
  BEFORE ASSUMING THE FLIGHT SOFTWARE IS AT FAULT.
- ALSO CORRECTED: sectors are 32K, not 64K.  psw_get_nia does
  `(BSR << 15) | (nia16 & 0x7FFF)` when bit 15 of the address is set, so my
  earlier decode of the load-block descriptors as `sector << 16` was wrong.
  Under <<15, phase 2's LB7 (addr 0x811a, sector 1, len 11122) covers
  0x811a..0xac8b, which is why 0x8a2d had real data in it.

### [2026-08-27] Target: [problems.md]
- ROOT CAUSE OF THE POST-LOAD DEATH, and it is a LINK GAP, not an emulator
  bug.  IPL.map ends with:
      UNDEFINED SYMBOLS
        FIOMUWB2          referenced by: FCMINSSL.obj(FCMINSSL)
  FCMINSSL declares its temp-buffer address as a Z-CON over that symbol:
      FCMBFZCN DS 0F                 SOURCE ADDRESSES Z-CON ARRAY
      FCMB1ZCN DC Z(,FIOMUWB2,0)     BUFFER 1 ADDRESS Z-CON
  Undefined resolves to zero, so the buffer address is 0.  The chain from
  there is exact and fully traced:
      FCMLBRTB elem#1 = 0, elem#2 = 0 + FCMBF1CT(8192) = 0x2000
        (watchpoint: only ONE write into 0x7334..0x7337, 0x7337 <- 0x2000)
      -> FCMMOVE gets src = 0, dest = 0, count = 4096
        (MVH trace: "x=3 dest=00000 count=4096 src=00000"; the three
         PRECEDING moves are all sane -- 08180/1480, 07c00/768, 00106/52)
      -> MVH stores into protected low memory
        (PROTVIOL #5 at NIA=072ad)
      -> trap through PSA 0x0048/0x004c, newPSW=0a3b0011
      -> 0x0a3b is inside phase 2's LB2 (0x676..0x2ea5), which the load
         just OVERLAID, so the handler is now PASS data
      -> it executes `BC 7,X'8a2d'` into the error-env stack and dies on
         0xc2d9.
  FIOMUWB2 is "16K MM I/O BUFFER", referenced by FCMINSSL and FIOMM128 and
  DEFINED IN NEITHER -- nor anywhere else in SSSRC.  Finding where the real
  build gets it is the next task.
- TWO SPECULATIVE FIXES TRIED AND REVERTED on the way, neither kept:
  making MVH's destination honour the destination register's DSE (LXAR sets
  one, so it looked compelling) -- measured dse=0 at the failing move, so
  the premise was false; and reading the fault as a missing 0xc2d9 opcode
  -- it is data, legitimately written by the SSL's own move loop.
- USEFUL SWITCHES FOUND: YAGPC_INTTRACE prints every interrupt with its PSA
  slots and new PSW, YAGPC_PROTTRACE prints protection violations with the
  NIA.  Those two together turned a "wild branch" into a one-line diagnosis
  and should be the first thing reached for next time.

### [2026-08-27] Target: [problems.md]
- FIOMUWB2 IS A HAL/S EQUATE, and the user found where.
  APPLSRC/CVNMMUTI.hal:44:
      EQUATE EXTERNAL FIOMUWB2 TO CDHV_BLOCKS$(1,1);
  and HALSTAT.ASC:384169 confirms it:
      FIOMUWB2 EQUATE LABEL  C O M P O O L  CVN_MM_UTILITY
      (EQUATED TO: CDHV_BLOCKS  UNIT/BLOCK: CVN_MM_UTILITY) RESERVED
      (CSECT: #PCVNMMU OFFSET: 000008)  PHASE 2 ADDR: 03032A
  So it is the address of element (1,1) of a compool array, exported for
  the assembly side to EXTRN.
- OUR TOOLCHAIN DOES EMIT IT -- this is NOT a compiler gap.
  PHASE03.sym.json has `FIOMUWB2 = 0x3032a, code global`, which matches
  HALSTAT's PHASE 2 ADDR exactly.  The defect is only that the IPL link
  does not have the defining compool among its inputs, so IPL.map lists
  FIOMUWB2 as its one undefined symbol and the Z-CON resolves to zero.
  FIXING THE LINK INPUTS IS THE REAL REPAIR.
- tools/patch_ssl_zcon.py writes the value the link should have produced,
  as a stopgap so the rest of the boot can be exercised.  The Z-CON format
  was derived from the code that consumes it and then CHECKED: halfword 0
  = 0x8000|(addr&0x7FFF), halfword 1 = addr>>15, and running FCMINSSL's own
  LH/SLL/LH/SRL/SRDL sequence over 832A/0006 reconstructs 0x0003032A.
  Before the patch FCMB1ZCN read `8000 0000` -- address zero with the
  marker bit -- which is exactly the 0x80000000 the failing MVH had in R5.
- EFFECT: the SSL's move now gets the right SOURCE (MVH trace: src=3032a,
  was 00000).  It is not yet enough: dest is still 00000 with the
  destination register's DSE reading 0, so the move still stores into
  protected low memory and the same five PROTVIOLs occur.  The crash moved
  from `0xc2d9 at 0x8a2d` to `0xc6c6 at 0x0a3b` -- 0xc6c6 being the SSL's
  own fill pattern -- so the handler address is unchanged and only what
  sits there differs.
- STILL OPEN: why DSE(R3) is 0 at that MVH.  FCMMOVE does
  `L 3,X'0000'(0)` / `LXAR 3,3` / `IHL 3,X'0003'(0)`, and LXAR's whole
  purpose is to split an address constant into a register plus a DSE --
  with TFCMTGTS = 8 in the struct, DSE(R3) should be 8 and the destination
  0x40000, not 0.  I measured dseX=0 and did NOT determine why; an earlier
  attempt to make MVH honour that DSE was reverted because the premise was
  unverified.  Note also YAGPC_DSETRACE shows NO DSE applied at the load
  itself (nia 072a3), so the load's EA is plainly 0x733f and it should read
  the 0x00000008 that is there.

### [2026-08-27] Target: [problems.md]
- WHY DSE(R3) IS ZERO AT FCMMOVE'S MVH -- traced to the instruction before.
  YAGPC_LXATRACE shows `LXAR nia=072a5 x=3 y=3 const=00000000`, so LXAR is
  handed zero and correctly derives a zero DSE from it.  The fault is the
  preceding `L 3,X'0000'(0)`: the trace shows CC 1->0 (a zero result) where
  memory plainly holds 0x00000008.
- THE MECHANISM IS AN ALIGNMENT MASK.  cpu.c's SRS path does
      ea = base + disp;
      if (v->addrWidth == 2) ea = ea & 0xfffe;
  R0 holds 0x733f -- FCMCTXT2 -- so the fullword load is forced down to
  0x733e and reads FCMCTXT1's last halfword joined to FCMCTXT2's first,
  which is 0x00000000.  Exactly the observed value.
- AND FCMCTXT2 IS AT AN ODD ADDRESS BY CONSTRUCTION:
      FCMCTXT1 DS 7H / FCMCTXT2 DS 7H
  with no alignment between them, so whichever build you do, one of the two
  structs starts odd -- and FCMBCTXT holds Y() HALFWORD pointers to both,
  which FCMMOVE dereferences with a FULLWORD load.
- THE MASK IS SUSPECT BUT LOAD-BEARING.  `git log -S` puts it in "Initial
  yaGPC2 commit, only at yaGPC level" -- inherited from gpc, no POO
  citation, the same provenance the DSE rule carries.  BUT REMOVING IT IS
  WORSE, measured: the boot then reads only 55 blocks and never loads
  phase 2 at all.  And it changes NOTHING in the fixtures -- 111180/111358
  with and without -- so test_cpu_instr_exec does not exercise it either
  way and cannot arbitrate.
- SO THE QUESTION FOR THE POO IS NARROW: in SRS format with a fullword
  operand, does the AP-101S force the effective address even, and if it
  does, how is FCMMOVE meant to read a context struct that begins at an odd
  halfword?  One of those two must give.  I did NOT resolve it and have
  left the mask in place.

### [2026-08-27] Target: [problems.md]
- CC CONFIRMS THE LOAD READ ZERO, independently of the register display:
  `L 3,X'0000'(0)` sets CC 1->0, and a load of 0x00000008 would set CC=1.
  So the fullword really is being fetched from the wrong place.
- WHAT THE FULLWORD LOAD IS FOR, which makes the conflict sharp: FCMMOVE's
  `L 3,X'0000'(0)` deliberately grabs struct offsets 0 AND 1 together --
  TFCMTGTA (address) and TFCMTGTS (sector) -- because that pair IS the
  address-constant format LXAR then splits into a register plus a DSE.  So
  the load MUST read the struct's own first two halfwords, wherever the
  struct sits, and FCMCTXT2 sits at an odd halfword by construction.
- BUT THE MASK CANNOT SIMPLY GO.  Removing it in both places, and then in
  the data path alone, both stop the boot EARLIER: only 55 blocks read,
  phase 2 never loaded.  With the data mask removed, PROTVIOL #5 moves from
  NIA=072ad (FCMMOVE's MVH) to NIA=0074E.  So something at 0x074E either
  depends on the alignment or is computing a base one halfword off with the
  mask hiding it -- two defects cancelling.  test_cpu_instr_exec cannot
  arbitrate: 111180/111358 with and without, identical.
- HANDOFF: the next person should start at NIA=0x074E with the data-path
  mask removed and find why that access needs aligning.  If it turns out to
  be a genuine odd-base access that the real machine aligns, then the POO
  question stands and FCMMOVE's struct-2 path must work some other way.  If
  it turns out to be an address computed one halfword short, fixing THAT
  may let the mask go and FCMMOVE work.  Do not remove the mask without
  resolving 0x074E first.

### [2026-08-27] Target: [problems.md]
- CC IS NOT BROKEN and needed no fix.  exec_L does
  cpu_compute_cc_arith(t, val, 0) on whatever it loaded; it loaded zero, so
  CC=0 was correct.  That is exactly what made the user's CC check useful --
  it confirmed the VALUE was wrong independently of the register display.
  The defect is one line earlier, in forming the address.
- HOW THIS SURVIVED SO LONG, measured rather than asserted.  Instrumented,
  the alignment mask changes an address only 185 TIMES IN A WHOLE BOOT of
  ~22.7 million instructions, and they cluster:
      40 each at 0x07b8, 0x07b9, 0x07c0
      16 each at 0x0072e, 0x0074e, 0x0074f, 0x00756
       1     at 0x072a4   <- FCMMOVE's load, the one that matters
  It takes a deliberately odd-sized structure -- DS 7H twice -- to put a
  fullword operand on an odd base.  Everything else in the flight software
  is naturally aligned, so nothing ever noticed.
- AND THE CLUSTER IS GPCIPL'S MEMORY TEST: every one of the 176 resolves
  inside MEMTST12/14/15/33/34 (BILDNEW5).  A memory test walks odd
  addresses on purpose and provokes protection violations on purpose --
  this project already records GPCIPL's self test storing an instruction
  over itself and its "artificial barrage of store-protect program checks".
  So THE MASK IS PROBABLY CORRECT and the self test depends on it.  That
  reverses the question.
- THE QUESTION IS NOW: why does FCMMOVE run against the ODD struct at all?
  FCMNEXTS/FCMCURRS toggle 0<->1 normally (XIST X'0000'(0),X'0001'), and
  FCMBCTXT holds Y(FCMCTXT1)=0x7338 and Y(FCMCTXT2)=0x733F, so every other
  above-128K sequence lands on the odd one.  If the machine really aligns,
  the flight software would break there too -- which it plainly did not.
  So either the real build places those structs differently, or in the real
  flow FCMMOVE is only ever reached with the even struct current, and our
  sequence count differs by one.  THAT is the thing to chase next, not the
  mask.
- YAGPC_ALIGNTRACE added: prints every address the fullword alignment mask
  actually changes.  185 lines for a whole boot, so it is cheap to leave on.

### [2026-08-27] Target: [problems.md]
- DOES yaGPC2 HANDLE THE SELF-TEST'S DELIBERATE STORE-PROTECT CHECKS?  YES,
  and it is worth writing down because it was asked and is now measured.
  All five violations in a boot dispatch identically and correctly:
      old PSW -> 0x0048   FCMBPCO, program check OLD
      new PSW <- 0x004C   FCMBPCN, program check NEW
      newPSW  =  0a3b0011
  and 0x0a3b resolves to PCH in BILDNEW5 -- GPCIPL's own program check
  handler.  The store is suppressed as well (exec_MVH aborts on
  !cpu_store_hw, the POO's forced ENDOP), and the CC/carry side effects
  were fixed earlier (problems.md 8.2).
- THE FOUR DELIBERATE ONES ALL RECOVER.  They sit at SVC076, SVC194 and
  CLCK2000+0xA -- self-test routines -- and the boot continues past every
  one of them.  So the interrupt path is exercised, repeatedly, and works.
- THE FIFTH IS FATAL FOR AN UNRELATED REASON: by the time it happens, phase
  2's LB2 (0x676..0x2ea5) has OVERLAID PCH itself, so the handler is gone.
  The trap is not mishandled; the trap should not be occurring, and its
  handler no longer exists.  Both of those follow from the FCMMOVE
  odd-struct problem, not from interrupt handling.
- WORTH NOTING FOR LATER: MLIB80/MOVEPSA.asm exists, so the real flow
  presumably installs a new PSA once PASS is in memory -- FCMPSA has
  PC=FPMIHPGM rather than GPCIPL's PCH.  A run that got further would stop
  depending on the overlaid vector.

### [2026-08-27] Target: [problems.md]
- ARE THE FOUR DELIBERATE VIOLATIONS RECOVERING THE RIGHT WAY, or just not
  killing the boot?  THE RIGHT WAY, and the flight software proves it
  rather than merely tolerating it.  The full cycle, traced:
      000bf5  LA  3,X'00db'(0)   R3 = 0x0c01     plant a resume address
      000bf7  STH 3,X'0005'(1)                   store it at [R1+5]
      000bf8  STH 5,X'02de'(1)                   DELIBERATE VIOLATION
      000a3b  PCH ... 18 instructions ...
      000a3d  LH  6,X'0005'(1)   R6 = 0x0c01     handler reads the plant back
      000a43  STH 6,X'0048'                      patch the OLD PSW's address
      000a47  NST 4,X'0048'      &= 0xffffefff   clear a flag in it
      000a58  LH  4,X'004b'      R4 = 7          the PROGRAM CHECK CODE
      000a5a  STH 4,X'000f'(1)                   stash it for the test
      000aaa  LPS X'0048'                        return via the patched PSW
      000c01  LH  7,X'000f'(1)                   resumes EXACTLY at the plant
      000c02  CHI 7,X'0007'      CC 1->0         code == 7, EQUAL
  So the self test plants a resume address, faults on purpose, and then
  CHECKS THAT THE PROGRAM CHECK CODE WAS 7.  Our old-PSW save, the code we
  report, and the resume address all satisfy it.  That is the flight
  software validating this emulator's interrupt behaviour, four times over.
- WHICH SETTLES THE EARLIER CLAIM PROPERLY.  "The boot continued past them"
  was weak evidence and the user was right to push on it; this is the
  strong version.

### [2026-08-27] Target: [problems.md]
- HYPOTHESIS TESTED: is the MMU load happening BEFORE a self test that
  should precede it?  Table 2-2 step 11 does make STP a precondition --
  "STP executes one cycle; if successful, GPCIPL gives control to SSL" --
  so it was worth checking.  IT IS NOT WHAT IS HAPPENING.  Ordering,
  measured:
      step  6,521,569   STP cycle ends, STPCYCNT 0 -> 1 (STH 7,X'3ba0'
                        at NIA=00835, just past STPEND)
      step  6,522,288   REALTIME (0x36c9) set 0 -> ffff (SHW at NIA=01cf8)
      step 22,762,631   FCMMOVE's failing MVH
  So a full STP cycle completes, and the machine transitions to REALTIME,
  about 16 million instructions before anything goes wrong.
- STPCYCNT IS A COUNT, NOT A VERDICT.  The cycle-end code increments it
  unconditionally (LH 7,X'3ba0' / AHI 7,1 / STH 7,X'3ba0').  What gates the
  path is `TH X'36c9'` -- REALTIME -- tested at 0x824 and again at 0x83d.
- AND THE 1m25s IS A DURATION, NOT A WAIT.  Table 2-2 gives it as the time
  from STBY to RUN TALKBACK for a default load, i.e. how long the whole
  load takes, not a delay before starting one.  Our run reaches the phase-2
  read at 18.6 s of emulated time and dies there, so it never approaches
  85 s; there is no evidence of racing ahead of a timed wait.
- (Also of note from the same trace: STP issues PCO 0x8804 -- LOAD GO/NO-GO
  TIMER -- at cycle end, which our IOP does implement.)
