# CLAUDE_LOG.md

(Cleared 2026-09-05 by Full Documentation Sync.  Twelve entries applied to two
targets.  Ten went to `problems.md` (9244 → 9788 lines) as new §8.48-§8.58: the
scorer understatement and the two `printed()` bugs; re-adds, `KNOWN` and the
phase split; `CDQANNUN` regenerated; the `GSIABT`/`FIOGPSPG` removals; the six
symbol-resolution rules and the invariance discriminator; the three mass-memory
compools and their CHANGE cards; Don's PR traffic, the PR #38 rebase and
`CS2120`; `GPXSRB` reconstructed from the dump; the opcode-stream method and its
four traps; `PGPPLD`/`PGGPCF` as R=C units and `DCDDG9`'s fourteen restored
statements; and where the 8288/8292 residue stands.  Five earlier conclusions
are explicitly retracted there.  Two went to `HANDOFF-OI340600.md` as database
entry #291 via `dass-handoff.py`, since that file is generated; `check` passes
on all three handoffs.)

### [2026-09-05] Target: problems.md
- **The phase idea works, and §8.58's "next thing to test" is now tested.**  Not
  phase MEMBERSHIP of the defining module, which is refuted -- `CGBOBF` and
  `CRBMCI` are in all eight configurations' phase sets including the ones that
  zero their symbols.  What decides it is WHICH PHASE LINKS THE REFERENCING
  TABLE, read straight out of `phase/PHASE*.sym.json`: those links already ran
  with the real `--map-lib` chains, so nothing has to model MAP semantics.
  `PHASE08` maps MAP2+MAP3 and `PHASE09` maps MAP2 alone, and `FIOHFE89` is
  linked in phase 8 for G9 and phase 9 for P9 -- which is why the dump holds two
  forms of it.
- **Two restrictions make it safe.**  Only symbols that are NOT CSECT names (a
  CSECT address is a system-wide constant, handled by the existing rule; zeroing
  one breaks the invariant tables reaching `FIOMDPPG`), and only where the
  referencing table is non-invariant counting a single placement as no evidence.
  Unrestricted it fires on whatever our phase decks omit and costs 77 CSECTs --
  phase 8's table holds 1502 entries where the system has tens of thousands.
- **8288 -> 8289, and G9 and P9 are now exact** (1041/1041, 567/567); six
  configurations at 100%.  `FIOCDATS` and `FIOHFE89` in P9 are byte-identical.
  `FCMBMTG9` loses its `TFIVMCI1`, though its other halfword (`TFIVPF12`) is
  excused by the post-build exception list rather than fixed.
- **Two went the other way and the cause is known**: SSW's `FIOHFEPG` wants
  `TFIVH251` and S2's `FIOCDATS` wants `TFIVPMST`, both defined in phase 2 and
  reached through a MAP2 our phase links model too permissively -- we hand phase
  9 the whole of `PHASE02.lib` where the original mapped only part.  `CGBIH2`
  and `CS2INB` appear in NO phase objlist at all, the same incompleteness seen
  from the other side.  Repairing deck coverage would likely take all five.
- **A measurement hazard now automated away.**  The phase tables were a day
  stale, predating every source fix of the session, and the first measurement of
  this rule was wrong in BOTH directions -- it reported 8288 -> 8287 where
  refreshing them gives 8288 -> 8289.  `dass-resolve.py` now exits with an error
  if any `phase/PHASE*.sym.json` is older than `objects/`.

### [2026-09-05] Target: problems.md
- **8290 -> 8291 of 8292.  Seven configurations exact; the only CSECT left in
  the whole corpus is `#PCS2120`, Don's `dfg` budget defect on PR #46.**
- **The CS2INB coverage gap was a CHANGE card.**  `SM2TAB` has `CHANGE
  #PCSAINB(#PCS2INB)` immediately above `INCLUDE SYSLIBL1(#ESAFACQ)`, and a
  CHANGE applies to the INCLUDE that FOLLOWS it.  Phase 15 loaded SAFACQ,
  renamed the reference, and then reported "Undefined COMPOOL: #PCS2INB" --
  lnk101's library search is on demand and never goes looking for the name it
  has just renamed TO.  Same deadlock `change_includes()` breaks one level up.
  `dass-phaselists.py` now collects CHANGE targets; S2 gains `FIOCDATS`.
- **CGBIH2 needed no repair at all.**  No deck names `#PCGBIH2` and no index
  places it; it reaches phase 2 only by library search.  The defect there was
  the ATTRIBUTION, not the coverage.
- **Deck order does not say which phase produced the copy a dump holds.**  SSW's
  `FIOHFEPG` is linked by phases 2 and 3 and the dump holds phase 2's -- 70
  halfwords of 1144 differ against phase 3's 1099 -- so "last phase in deck
  order" blamed a link that never produced it and zeroed `TFIVH251`.  Comparing
  the phase copies against the dump settles it directly and settles it hard:
  P9's `FIOCDATS` matches its phase-9 copy in ALL 580 halfwords.  All six known
  cases come out right, where deck order got two wrong in each direction.
  SSW rejoins the exact set.
- **Still true and worth keeping**: `FCMBMTG9`'s second halfword (`TFIVPF12`,
  the `CVAS_INB` ARRAY(44)-vs-26 subscript question) is excused by the
  post-build exception list rather than fixed, so G9's 100% rests on it.

### [2026-09-05] Target: problems.md
- **`TFIVPF12` is `CVAS_INB` element 1, not 33, and the G9 dump says so
  outright.**  `FCMBMTG9+018E` is its relocation site and holds `F921`, which is
  `CVAS_INB`'s own base; `$(33:)` gives `F941`.  `CVAS_INB` spans only
  `0xF921-0xF93A` (26 elements) with `FCMBMTG9` at `0xF93C`, so element 33
  cannot exist there.  The same measurement independently CONFIRMS the four
  aliases reconstructed earlier -- `TFIVPF13`, `TFIVPF22`, `TFIVPF23`,
  `TFIVPF24` at elements 9, 10, 18, 19, exactly as written.
- **`FCMBMTG9` and `FIOMVUPG` are now byte-identical** (0 of 1334 and 0 of 276).
  Both had been passing only through the post-build exception list, so G9's
  100% no longer rests on an excuse: raw exact 906 -> 908.  Corpus stays
  8291/8292; the change is in the raw column, which is the honest one.
- **Six now-stale entries in `~/ForClaude/OI340600-clc/exceptions-G9-full.txt`**:
  `0F948`-`0F94C` "CVHPLD-revised-BY-to-BZ" and `0FACA`
  "FCMBMTG9-references-TFIVPF12-in-CVHPLD-revised-BY-to-BZ".  All six now match
  the dump.  NOT removed -- that file holds 22051 hand-curated `-1` entries and
  pruning someone else's curation was not the task -- but they mask a
  regression if left, so they are worth a deliberate pass.
- **Still open for want of evidence**: `TFIVSF22` and `TFIVSF23` remain `$(30:)`
  and `$(32:)`, equally impossible in a 26-element array, and `CVAS_INB` is
  still declared `ARRAY(44)` where the dump shows 26.  No scored CSECT
  references either alias in any of the eight dumps.

### [2026-09-05] Target: problems.md
- **The six stale exceptions are removed** from
  `~/ForClaude/OI340600-clc/exceptions-G9-full.txt` (24636 -> 24630 lines,
  22051 -> 22045 `-1` entries): `0F948`-`0F94C` "CVHPLD-revised-BY-to-BZ" and
  `0FACA` "FCMBMTG9-references-TFIVPF12-in-CVHPLD-revised-BY-to-BZ".  The score
  is byte-for-byte unchanged afterwards -- 8291/8292, G9 908 raw -- which
  proves empirically that they were inert.  Backup at
  `/tmp/exceptions-G9-full.txt.bak`.
- **That file is GENERATED by `dass-versions.py`, not hand-maintained**, so a
  hand edit would normally be the handoff trap.  It is safe here because the
  generator emits a `-1` only where our image and the dump actually differ
  (`if a == b: continue`, near line 583), so with `TFIVPF12` fixed it would not
  re-emit these six: the surgical deletion produces exactly what a regeneration
  would.  Its three sections are all derived -- the scraped MAFGEN `*` marks,
  the `-1` version block, and a runtime-overlay block from
  `mafgen/runtime-overlay.txt` -- with `mafgen/defects.txt` the only curated
  input.
- **A structural mismatch worth naming**: the exceptions files were derived from
  an OI34.06-versus-dump comparison ("Differences attributable to the source
  being OI-34.06 where the dump is OI-34.07") and are being used to score an
  OI34.07 build.  Every source reconstruction we land makes more of the `-1`
  block stale, and nothing detects it -- these six were only noticed because
  `FCMBMTG9` moved from failing to excused.  Re-deriving the block against the
  OI340700 build, or at least auditing `-1` entries whose address now matches,
  would stop the list quietly flattering the score.

### [2026-09-05] Target: problems.md
- **HALSTAT is a source-level oracle we have barely used, and it answers the
  CVAS_INB question outright.**  Symbol 29246: `ARRAY(26) INTEGER INITIAL()
  ('EQUATED')`, `(CSECT: #PCVHPLD OFFSET: 000011) SIZE: 00001A(26) BIAS:
  000001(1)`, at source record **016352** -- exactly where OI34.06 declares
  `ARRAY(44)`.  So the DASS listing's 26 is neither MAFGEN truncation nor an
  intentional overrun into the `FCMBMTG9` table that follows in memory.
- **The trailing number on a HALSTAT symbol is its SOURCE RECORD**, which makes
  it far more than a size oracle.  CVAS_INB's five EQUATEs sit at 016354,
  016356, 016358, 016360, 016362 (statements 14-18) and are `TFIVPF12`,
  `TFIVPF13`, `TFIVPF22`, `TFIVPF23`, `TFIVPF24` at elements 1, 9, 10, 18, 19.
  Those are the SAME records where OI34.06 has `TFIVSF11`/`SF12`/`SF13`/`SF21`/
  `SF22`, and **no `TFIVSF` name occurs anywhere in HALSTAT**.  The block was
  replaced in place, not appended to -- which is why `$(30:)`, `$(32:)` and
  `$(33:)` looked impossible: they belong to the 44-element version.
- **This independently confirms both earlier reconstructions** (the four
  aliases derived from the disassembly, and the `TFIVPF12` subscript derived
  from the `FCMBMTG9` ACON) and supplies their source records.  `#PCVHPLD` is
  now 43 halfwords and abuts `FCMBMTG9` exactly, where `ARRAY(44)` overlapped
  the table by seventeen.  Score unchanged at 8291/8292, as it must be.
- **A retraction**: "no scored CSECT references them, so there is nothing to
  derive the new subscripts from" was wrong.  There was -- HALSTAT.  I had been
  treating it as a revision-level and extent table (which is all
  `dass-versions.py` uses it for) and never looked at its symbol dictionary.
- **The same defect is still live in `CS2INB`.**  `FCMBMTS2` differs from the
  S2 dump in 13 halfwords, ALL of them `TFIV*` alias sites -- `TFIVAN11-14`,
  `TFIVAN21-23`, `TFIVPF12`, `TFIVPF13`, `TFIVPF21-24` -- and it currently
  scores only because the exception list excuses them, exactly as `FCMBMTG9`
  did.  HALSTAT gives every offset (`TFIVPF12` at `#PCS2INB` OFFSET 000099 ->
  007871, and so on).  Not done; it is the obvious next piece.

### [2026-09-05] Target: problems.md
- **`CZ3COM` reconstructed: eight CSECTs from one include.**  `#PCZ3COM`
  differs from all eight dumps in the same nine halfwords, all of them ours
  holding data where the dump holds `0000`, over `+002C..+0036`.  HALSTAT names
  the run exactly -- `CZ3_FLEX_MDM_TABLE` at offset `00002C` size `00000A(10)`,
  `CZ3V_SM4_STAT` at `000036` -- and shows both keeping their declarations
  (`STRUCTURE(5) INITIAL()`, `INTEGER INITIAL()`), so only the VALUES changed.
- **HALSTAT distinguishes an absent INITIAL from an empty one**: beside them
  `CZ3V_FLEX_DEVICE_ID` renders as a bare `INTEGER RIGID`.  That is what makes
  `INITIAL()` readable as "clause present, value not rendered" rather than "no
  clause".
- **The sub-counter fixes the source layout, not just the file.**  The values
  live in `INCL80/FLEXDATA.hal`, reached from `CZ3COM`'s `D INCLUDE FLEXDATA` at
  record 001500, which is why HALSTAT writes `001500+1` and `001500+7`.  The
  status declare being the SEVENTH record means the table's declare must keep
  occupying records one to six -- it cannot be collapsed to `INITIAL(10#(0))`.
  Zeroed the five FLX pairs in place; `INITIAL(5)` became `INITIAL(0)`.
- **Honest score 8267 -> 8275 of 8292**, and SSW and P9 now have nothing
  outstanding even with the version block withdrawn.  Headline 8291 unmoved,
  since this was one of the 24 CSECTs that block was excusing.  Raw exact 7232
  -> 7240.
- **Worklist remaining (17 CSECTs, honest scoring)**: G16 2, G2 1, G3 1, G9 2,
  S2 11.  The S2 concentration is mostly `CS2INB` aliases (`FCMBMTS2`,
  `FIOMS2PG`, 13 halfwords each), which HALSTAT can answer the same way.

### [2026-09-05] Target: problems.md
- **Goal-directed pass on the version-block worklist: honest score 8275 -> 8284
  of 8292.**  Seven reconstructions, each verified byte-identical: `CZ3COM`
  (FLEXDATA, 8 CSECTs), `CS2INB` (2), `CVAMMDIR` (2), `GDRENT` (2), `CSPCON`,
  `CPASSI`, `CS2PX3`.  Headline stays 8291/8292 throughout, since all of these
  were CSECTs the version block was already excusing -- the raw exact column is
  the one that moved, 7232 -> 7250.
- **`F GEN`/`F END` marks per-flight generated data**, and that is the single
  most productive pattern so far.  `CSPCON`, `CPASSI` and `FLEXDATA` all turned
  out to be blocks of flight-specific values that STS-134 leaves at defaults or
  zeros; in each case the entries OUTSIDE the block already matched, which is
  what confirms the block boundary is the right edit.
- **`BIN(3)'1'` is a REPETITION, not a width.**  It means '1' three times =
  111, which is what our compiler correctly emits and what the neighbouring
  `BIN(3)'0'` -> 000 confirms.  `CS2PX3`'s 27 PXT entries want `BIN'001'`.
  Worth checking wherever a `BIN(n)'...'` literal is narrower than the field.
- **HALSTAT's sub-counter constrains card LAYOUT, not just values.**
  `CVAV_TDIR_NUM_FMT` at include record `001300+25` proves VTLMMDIR has twenty
  separate value cards and no `3#(0,HEX'0000')` filler; `CSAS_INB-STRUCTURE(176)`
  proves the 21 aliases beyond copy 176 are absent, because compiling at 176
  rejects them outright.  In both cases two independent HALSTAT facts agree.
- **Left, with reasons**: `#DSSMANT` has ONE real difference, a literal-pool
  constant 9 ULP from ours (dump 44A8CF7C, ours 44A8CF85) -- not a named
  variable and not attributable, plausibly constant folding.  `#CGPXSRB`,
  `#DGO2ORB`, `$0DGRGSE`, `#CPGVVAL`, `#DPGVVAL` and `#PCZ4COM` are all
  references into revised compools (`#PCGBOBF`, `#PCGNREM`, `#PCDHMMU`,
  `#PCPGPCD`, `#PCSASAT`) whose field offsets moved; each needs its own HALSTAT
  layout comparison.

### [2026-09-05] Target: problems.md
- **`CPGPCD` is a fourth R=C unit, and its output-channel table is five
  generated entries, not thirty.**  `#DPGVVAL`'s ACONs into `#PCPGPCD` were 9
  and 59 halfwords late.  Nine is STRPDT's R-gated NAME pointers again; fifty
  is `CPGK_SCREEN_INDEX` = `CPGV_OUTPUT_CLASS1_INDEX`(16) +
  `CPGV_OUTPUT_CHAN_INDEX`, an `F GEN` value of 30 giving 46 two-halfword
  copies where HALSTAT leaves room for 21.  With the index at 5 our SDF reports
  97, 98 and 142 -- HALSTAT to the halfword -- and the dump independently shows
  the sixteen entries that sit OUTSIDE the `F GEN` block followed by five zero
  pairs.  `#CPGVVAL` and `#DPGVVAL` both match.
- **THE BUILD HAS STALE OBJECTS, and that is a finding in its own right.**
  Recompiling the modules that include `CPG_PCD` also picked up `PGGPCF`'s
  template, changed earlier when PGGPCF became R=C.  `$0PGMMMR` then came out
  612 halfwords against the index's 610 -- a real discrepancy the build was
  hiding behind an object compiled against an older SDF, NOT a regression
  introduced by the change.  Kept visible rather than papered over by retaining
  the old object.  27 modules include a compool changed this session and are
  being rebuilt for consistency.
- **Honest score 8275 -> 8285 of 8292 over this goal-directed pass**; headline
  unchanged at 8291 throughout, raw exact 7232 -> 7251.

### [2026-09-05] Target: problems.md
- **THE BUILD TREE DOES NOT REPRODUCE ITSELF, and this is the most important
  finding of the pass.**  27 modules include a compool changed this session.
  Recompiling all 27 from `~/pass-build/OI340700`'s own sources, with no source
  edit of their own, regressed the corpus from 8285 to **8234** of 8292 -- 51
  CSECTs.  `#DASMAUX` and `#DDUPNSP` broke in ALL EIGHT configurations, and
  nine more code CSECTs changed SIZE (`$0AIBGPC`, `$0ASMAUX`, `$0DUPNSP`,
  `$0SFLFOR`, `$0VAASEQ`, `$0PGDATA`, `$0SAFACQ`, `$0SPSPSP`, `$0SULUPL`).
- **The old objects matched the dump and the freshly-compiled ones do not**, so
  `objects/` and `APPLSRC/`+`SSSRC/` are not in correspondence: some objects
  were built from source states that no longer exist in the tree.  `cb/obj/`
  holds the pre-session objects (dated 09-04) and 20 were restored from it to
  recover.  Verified back at 8285, then 8286 after also restoring `PGMMMR`.
- **This undermines any measurement taken from this tree** until resolved, and
  it has to be settled BEFORE the exceptions/FCM staging plan, not after: at
  the scale that plan works at (422 CSECTs hanging on one or two halfwords), a
  stale object is indistinguishable from a real discrepancy.  The obvious test
  is a full `compilePASS` rebuild and a diff of every object against `cb/obj/`.
- **Net for the pass**: honest 8275 -> **8286** of 8292, headline held at
  8291/8292 (only `#PCS2120`, Don's).  Eleven CSECTs recovered across `CZ3COM`,
  `CS2INB`, `CVAMMDIR`, `GDRENT`, `CSPCON`, `CPASSI`, `CS2PX3` and `CPGPCD`.
- **Remaining, all characterised**: `#CGPXSRB`(4) and `#DGO2ORB`(3) reference
  `#PCGBOBF`/`#PCGNREM`; `$0DGRGSE`(1) and `#PCZ4COM`(1) reference
  `#PCDHMMU`/`#PCSASAT`; `#DSSMANT` has ONE real difference, a literal-pool
  constant 9 ULP from ours; `#PCS2120` is Don's.

### [2026-09-05] Target: problems.md
- **Honest score 8275 -> 8288 of 8292 over the goal pass; headline 8291/8292.**
  Eleven units reconstructed and verified byte-identical: `CZ3COM`(8 CSECTs),
  `CS2INB`(2), `CVAMMDIR`(2), `GDRENT`(2), `CPGPCD`(2), `CSPCON`, `CPASSI`,
  `CS2PX3`, `CSASAT`, `GPXSRB`.
- **`GPXSRB`'s ET-camera block was wrong and is corrected**: it writes
  `CGBB_OUT12_HFA_DSCRT7/8$(3;2:8)`, not `$(4;...)`.  The dump's ACONs read
  3E89/3E85 = `#PCGBOBF`+283/+279, and at 114 halfwords a copy that is copy 3.
  The original reconstruction derived the copy from the listing's annotation of
  OUR value instead of the dump's own ACON, and said so honestly ("zero
  differing halfwords OUTSIDE relocations") -- the four relocations it set aside
  were the wrong ones, and the -1 block then hid them for weeks.
- **`CSASAT`: the EU scaling table is 165 entries, not 162.**  Three facts
  agree -- the dump's `CSAS_SAT_EU_NUM_ENTRIES` is 165, the declared 167 needs
  170 for 165 real plus five spares, and the dump's entries 163-165 carry the
  same pattern our 161-162 do.  `CSAS_SAT_ANA_NUM_ENTRIES` corrected 508 -> 446.
  Its table is LEFT at 513 copies (the dump implies 451): which 62 entries were
  dropped cannot be recovered without matching 446 floats, and `#PCSASAT` is
  address-only in every link so nothing compared depends on it.
- **THE LAST TWO VALUE DIFFERENCES ARE FLOAT CONVERSION, NOT SOURCE.**
  `#DGO2ORB`'s single real halfword is the double for `CGIK_G_ZRO 1.0E-6`
  (GO2ORB:645): OURS IS THE CORRECTLY-ROUNDED VALUE and the dump's is one ULP
  low.  `#DSSMANT`'s is a folded literal 43215.484375 against our
  43215.5195312, about 13 ULP.  Neither can be fixed in source without
  falsifying a literal to compensate for a toolchain difference, so both are
  left.  This is a NEW blocker class, distinct from the nsts-sdl-dps ones.
- **`$0DGRGSE` is characterised but not attributable**: the dump's `LA R4` takes
  `#PCRILVC`+925 where our `%COPY(CDHV_LDB_BUFR$1,...)` gives `#PCDHMMU`+265.
  Offset 925 lands mid-element inside `CRIS_SEL_PL_NONZERO_CMD_OFF
  ARRAY(6,6,2) SCALAR` at 912, so the evidence does not say what OI34.07
  references there.
- **Remaining four, all blocked**: `#DGO2ORB` and `#DSSMANT` (float
  conversion), `$0DGRGSE` (unattributable), `#PCS2120` (Don's dfg defect).

### [2026-09-05] Target: problems.md
- **RETRACTION: the build tree is NOT broken, and "objects/ and the sources are
  not in correspondence" was WRONG.**  The 8285 -> 8234 regression was
  self-inflicted: every ad-hoc `HALSFC` invocation this session omitted the
  `SDL` compiler option.  `compilePASS` adds it via its `--sdl` switch and
  documents exactly why -- "the DASS memory dumps we compare against are SDL
  builds, and NOSDL, the default, emits a START CSECT and an `LHI R0,<stack>`
  prologue for every PROGRAM that those images do not have."  `getParms()` does
  NOT include it, so calling `getParms` and invoking HALSFC directly silently
  builds the wrong thing.
- **Proof**: `ASMAUX` and `PGDATA` each grew by exactly 480 bytes = six 80-byte
  object records, and a record-type census showed the extra content is one more
  ESD/TXT/RLD/END/SYM plus a STA record for a CSECT named `START`.  Recompiled
  WITH `SDL`, `ASMAUX` is the same 6400 bytes as `cb/obj/` and differs in ten
  bytes -- the embedded date and time.
- **A second correction that made the first one look worse than it was:
  HALSFC objects are NOT byte-stable.**  Two identical compiles of `CDQANNUN`
  differ in four bytes at offsets 115-118, EBCDIC digits of a timestamp.  So
  `cmp` on objects is the wrong test; compare SIZE first, and treat
  same-size differences as noise until shown otherwise.  This is the same trap
  as the SDF non-stability recorded earlier, and I walked into it again.
- **Operational rule worth automating**: anything that compiles a PASS module
  outside `compilePASS` must prefix `SDL,` to `getParms()`'s result, or it is
  building a different program from the one the corpus is measured against.

### [2026-09-05] Target: problems.md
- **The build tree REPRODUCES.  Twelve of twelve modules recompiled with the
  correct parms come out the same size, including all nine that appeared to
  regress** (`PGDATA`, `ASMAUX`, `AIBGPCLO`, `DUPNSP`, `SFLFOR`, `VAASEQUE`,
  `SAFACQ`, `SPSPSP`, `SULUPLIN`), differing only in the embedded timestamp.
  The "objects/ and the sources are not in correspondence" claim is withdrawn.
- **`halsParms.getParmsForCompare()` added** so this cannot recur: it is
  `getParms(..., sdl=True)`, and it carries the reason.  `DEFAULT_SDL` is
  correctly False for `compilePASS` and `compileLinkRun`; a
  compileLinkCompare tree is an SDL build because the PFS/mafgen images are.
  Anything measured against the DASS images must come through it.
- **All nineteen modules touched this session were recompiled with SDL** and
  the corpus is unchanged at headline 8291/8292, honest 8288/8292 -- which also
  confirms the reconstructions were sound, since a compool's object does not
  depend on SDL and only PROGRAM units did.
- **Final state of the goal pass**: honest 8275 -> 8288 of 8292; headline
  8291/8292.  Four remain, all blocked and all characterised: `#DGO2ORB` and
  `#DSSMANT` are decimal-to-AP-101S float conversion differences (ours is the
  CORRECTLY-rounded double for `1.0E-6`; the dump's is one ULP low), `$0DGRGSE`
  is unattributable from the available evidence, and `#PCS2120` is the reported
  `dfg` defect in nsts-sdl-dps.

### [2026-09-05] Target: problems.md
- **EXCEPTIONS REDUCED 138322 -> 33492 lines (75.8%), with both scores provably
  unchanged**: headline 8291/8292 and honest 8288/8292 before and after, and the
  `+patches` column identical at 7331.  Backup of all sixteen files in
  `/tmp/exc-backup/`.
- **The criterion is the generator's own, made explicit.**  `dass-versions.py`
  emits a `-1` only where our image and the dump actually differ (`if a == b:
  continue`), so an entry whose address we now match is dead by the generator's
  own rule.  Extended to what the SCORE can see: an entry is load-bearing only
  if its address lies in a scored CSECT -- not contested, under 50% synthetic
  fill, placement matching -- AND still differs AND is not already excused by
  the never-printed fill rule.  That is 16750 addresses of the 138322 entries
  present, 12%.
- **The version block is effectively gone**: of 16749 distinct addresses that
  remain, exactly THREE carry the `-1` marker, against 82725 before.  What is
  left is almost entirely the patch-summary class -- locations the DASS reports
  mark as changed after the build -- which is legitimate and permanent until the
  MM -> LM rewrite of the FCMs.
- **Step 2 of the staging plan is validated but NOT executed.**  The patch
  summary parses cleanly in all eight (zero unparsed rows), the `.fcm` holds MM
  at ~100%, the scrape is a strict superset of it on membership, the columns are
  provably not transposed (`ours == MM` in 0 of 2486 rows in the worst CSECT),
  and our build already produces LM in 97.8-100% depending on configuration.
  Writing it changes what `<cfg>.fcm` MEANS -- as dumped becomes as built -- so
  it should produce a separate file, and `printed()` plus its whole-corpus
  validation must be re-run immediately afterwards because the fill test reads
  those very bytes.

### [2026-09-06] Target: problems.md
- **`unlinkMAFGEN2.py` now extracts the AS-BUILT image** (Ron's design: fix the
  extractor, not the artefact, so filenames and their meaning are unchanged and
  future users get the right thing).  It reads the PATCH SUMMARY in the same
  pass -- the loop runs to EOF and merely stops appending, so `asc` is unchanged
  and piped input still works -- and writes the LM values over the MM ones
  before emitting `memory.json` and `memory.fcm`.
- **Verified on all eight**: same size; differences confined to the patch
  addresses and no others; new image holds LM at every one and the old held MM
  at every one; `csectTable.json` byte-identical to the committed
  `csects-*.json`.  Zero rows match the row pattern between the scan marker and
  the summary, so nothing extraneous is picked up.  `printed()`'s whole-corpus
  validation still holds, and only ONE address in all eight has an LM that is
  itself a fill pattern.
- **`dass-literals.py` had to change with it**: it GENERATES
  `exceptions-<cfg>.txt` from the starred locations and self-checks them against
  the `.fcm`, which would now fail everywhere.  It omits any starred location
  the PATCH SUMMARY covers and checks against LM where one exists.  That class
  falls 27789 -> 877, the 877 being starred locations with no LM.
- **EXCEPTIONS: 138322 -> 884 lines** (877 generated base + 7 in the `-full`
  files).  Only EIGHT addresses corpus-wide are still load-bearing.
- **The real measure moved.**  Byte-for-byte agreement with NO exceptions at all
  (the `exact` column) goes 7252 -> **7328** of 8292, and exceptions now change
  the outcome for THREE CSECTs instead of 209.  For G16, G2, G3, G9 and P9 the
  exception lists do nothing at all.  Headline 8291/8292, honest 8288/8292.
- **Method notes.**  The extractions CAN run concurrently -- every write goes to
  the per-config `--results` directory, inputs are read-only and distinct, no
  chdir or temp files.  I serialised them by reflex, carrying over HALSFC's
  fixed-name-workfile constraint, which does not apply.  Also: `ps | grep`
  through the `rtk` proxy returned filtered output and had me believing a
  running extraction was dead; read `/proc/*/cmdline` for process checks.

### [2026-09-06] Target: problems.md
- **The 877 remaining base exceptions are 876 CHECKSUM words plus one other.**
  MAFGEN stars a checksum because patching a module forces it to be
  recomputed -- a consequence of a patch, not a patch, which is why the PATCH
  SUMMARY rightly gives no load-module value for it.  They sit in unnamed
  two-halfword blocks outside any CSECT, so they are inert for scoring: only
  ONE of the 877 is load-bearing.
- **The eight load-bearing addresses, corpus-wide, are now fully identified**:
  SSW `#DDCDDOW`+0052; G16/G2/G3/G8 `#DGO1ASC`/`#DGO2ORB`/`#DGO3ENT`/`#DGO8ORB`
  (all the same constant); S2 `#DSSMANT`, `#PCS2120` and `$0DGRGSE`.
- **MISSION_ID is a RUNTIME value, not a source one -- tried and refuted.**
  SSW's exception is `38266 001D MISSION_ID`, and `DCDDOW.hal` declares it
  `BIT(8) INITIAL(HEX'00')`.  Setting it to `HEX'1D'` fixed SSW and BROKE THE
  OTHER SEVEN, which all hold 0000 there: SSW is the post-IPL listing and the
  running system wrote the mission ID into memory.  Reverted.  The exception is
  correctly classified as "changed after the build" and is permanent.
  The lesson generalises: check a candidate against ALL EIGHT dumps before
  believing it, because a value present in one and absent in seven is runtime,
  not build.
- **The 1.0E-6 difference is NOT compiler rounding, which retracts yesterday's
  conclusion.**  The dumps contain BOTH forms of the double 3C10C6F7A0B5xxxx --
  ED8C at 4 sites and ED8D at 19 -- so the original compiler produced the
  round-to-nearest value nineteen times.  The four low sites are exactly the
  `GO*` family, where matching modules like `GEIORB`/`GEAASC` write
  `SCALAR$(@DOUBLE)(...) 1.0E-6` and the `GO*` ones write
  `SCALAR$(@SINGLE)(...) CGIK_G_ZRO 1.0E-6`.  Nor is it the literal's spelling:
  `.000001`, `1.0E-06` and `1E-6` all compile to ED8D.  So it is a source
  difference in the `GO*` family that I have not identified -- worth 4 CSECTs.
- **State**: headline 8291/8292 (only `#PCS2120`, Don's), `exact` 7328/8292
  with NO exceptions at all, exceptions 884 lines / 8 load-bearing.

### [2026-09-06] Target: problems.md
- **The `GO*` family `1.0E-6` difference is identified, and it is NOT a source
  difference.**  `INCL80/GOQCOD.hal:37` -- included by `GO1ASC`, `GO2ORB`,
  `GO3ENT`, `GO8ORB` and nothing else -- reads
  `(SCALAR$(@DOUBLE)(TFCMLTQH)  10**(-6))`, with `... 1800 )` on the line above
  supplying the `4370800000000000` that sits beside it in the literal pool.
  The constant is therefore FOLDED, not parsed, which is why no decimal
  spelling (`1.0E-6`, `1.0E-06`, `1E-6`, `.000001`) ever reproduced the dump.
- **How HAL/S-FC folds.**  `ARITH_LITERAL` only loads the operands; the
  arithmetic is `MONITOR(9,op)`, whose `EXPON` routine
  (`MONITOR.ASM/MONITOR.bal` cards 00289400-00293000) does LSB-first binary
  square-and-multiply in S/360 hex floating point, patching `MDR` to `DDR` for
  a negative exponent.  So `10**(-6)` = `(1.0 DDR 100) DDR 10000` with the
  divide TRUNCATING at each step.  Simulating that exactly reproduces the
  dump's `3C10C6F7A0B5ED8C`; every other model tried (truncating or rounding
  `1/1e6`, `(0.1)^6` either association, IEEE round-trips) does not.
- **The defect is in our port and the fix already existed.**  Don Schmidt
  committed it to XCOM-I on 2026-08-11 (`8310a61db`), naming
  `X'3C10C6F7A0B5ED8C'` and saying it also fixes `SSMANTMG` and `GTBUPL`.  Our
  compiler binaries were built 2026-08-07, four days early, so every build
  since has used the unfixed compiler.  Rebuilt all eleven passes; the literal
  pool now folds `10**(-6)` to `ED8C` while `1.0E-6` still parses to `ED8D`,
  which is exactly the split the eight dumps show.
- **`xplBuiltins.py` needed the same fix** and did not have it -- its
  `MONITOR(9)` op 5 was IEEE `pow()`.  `compilePASS` cross-checks the C PASS1
  against this Python PASS1, so without it every folded `**` would have been
  reported as a disagreement.  Added `ibm_dp_expon()` as a direct port of the
  same `EXPON` algorithm; verified `10**(-6)` -> `3C10C6F7A0B5ED8C`,
  `10**(-5)` -> `3CA7C5AC471B4780`, `2**10` -> 1024, non-integer exponent
  falls back.
- **`#DSSMANT` is the same defect, not an unattributable constant.**  S2
  `05D63` is `#DSSMANT+0157`, dump `3CC2B65E44A8CF7C` vs ours
  `...CF85` -- that decodes to 1.1605762E-5, i.e. `SSMANTMG.hal:1149`'s
  `(1.1605762 10**(-5))`.  The 9-ULP gap is the 8-ULP error in `10**(-5)`
  scaled by 1.1605762.  My earlier note calling this constant "43215.484375"
  was a decoding slip and is withdrawn.
- **Exception bookkeeping to correct once re-measured**: the four
  `.000001-literal-in-#DGO*` exceptions assert "dump-ED8C, correct-is-ED8D".
  That is backwards -- the dump is right and we were wrong.  G2's line
  `0BC13` is one of these four, currently mislabelled
  `GO2ORB-references-CGCFL2-revised-BU-to-BV`; `00BADC+0137 = 0x00BC13`.
- **MISSION_ID stays.**  `HEX'1D'` fixed SSW and broke the other seven, which
  all hold `0000`; SSW is the post-IPL listing, so the value is written at
  runtime.  Reverted.  Lesson: check a candidate against ALL EIGHT dumps
  before believing it.
- **MEASURED RESULT of the compiler rebuild** (2026-09-06).  Corpus rebuilt
  (1222 modules, 0 compilation failures, and only 2 files skipped for
  IR1/DI11/PM2/ZO3 against 28 in the previous build), phases rebuilt, all eight
  configurations re-resolved and re-scored.  `exact` 7328 -> **7329**,
  `+patches` 7331, `+unknown` 8291, all of 8292.  Image-level blast radius,
  measured against `link.prefix-backup`: **16 halfwords across 12 CSECTs in the
  whole corpus -- 5 moved onto the dump, 11 sit at addresses MAFGEN never
  printed, 0 moved away.**  The five: `#DGO1ASC`, `#DGO2ORB`, `#DGO3ENT`,
  `#DGO8ORB`, `#DSSMANT`.  Only `#DGO8ORB` reaches `exact`, because the other
  four still carry C9FB synthetic fill that `exact` does not excuse.
- **Exceptions: five removed at zero cost.**  `exceptions-G16/G2/G3/G8-full`
  are now empty of entries and `exceptions-S2-full` holds one.  Across all
  eight configurations only TWO load-bearing exceptions remain: SSW `38266`
  MISSION_ID (runtime value, permanent) and S2 `43C45` `$0DGRGSE`.  Re-scored
  after removal: identical, 7329/7331/8291.  The false class header "Probable
  floating-point bug in original compiler" was removed with them.
- **`mafgen/defects.txt` rewritten as a retraction.**  The `-2` class is empty
  and its only ever member is withdrawn.  The file's own standing rule --
  nothing may be entered that our toolchain has not first been shown to get
  right -- is what was broken, and the entry stood for a month.
- **PROCESS DEFECT, still open**: nothing rebuilds HAL/S-FC when XCOM-I or the
  compiler sources change, so a fix can sit unused indefinitely.  This one sat
  26 days.  Only Don's EXPON commit was actually missing -- `4a4324b32`
  (ibmFloat) landed 18:57:26 and the old binaries were built 19:03:23, six
  minutes later -- but that was luck, not process.
