# CLAUDE_LOG.md

(Cleared 2026-09-06 by Full Documentation Sync.  Seventeen entries applied, all
to `problems.md` (9788 → 10298 lines) as new §8.59-§8.71: the phase rule that
works and the membership form that does not; `CS2INB`'s CHANGE card and why deck
order lies about provenance; HALSTAT as a source-level oracle and its trailing
source-record number; `CZ3COM`, `F GEN` and eleven reconstructed units; the
retracted "build tree does not reproduce itself", which was a missing `SDL`;
exceptions 138322 → 884; `unlinkMAFGEN2.py` extracting the as-built image; the
`1.0E-6` constant and the three wrong explanations before `10**(-6)` turned out
to be folded by `MONITOR(9)`'s `EXPON` in truncating S/360 hex float; the
compiler 26 days stale behind Don's fix; 8292 of 8292; the generated exceptions
class eliminated; one home for the tooling and four stale-copy failures in a
day; and the CLC sweep repointed from OI340600 to OI340700.  Six earlier
conclusions are explicitly retracted there -- the `-2` "the dump is wrong" class,
"compiler rounding, unfixable", "a source difference in the `GO*` family",
"`#DSSMANT` is an unattributable 9-ULP constant", "the build tree does not
reproduce itself", and "`csects-*.json` is 1077 CSECTs stale".)

### [2026-09-06] Target: problems.md
- **A TRAP THAT COST A FULL RELINK: editing `INCL80/` does nothing until
  `INCLIB` is rebuilt.**  `D INCLUDE` reads the include LIBRARY, not the
  directory -- HALSFC's command line says so (`--pdsi=8,INCLIB,E`).  After
  zeroing FLEXTBL's `F GEN` block the recompiled object was byte-identical
  outside its date fields and still held the FLX values, and the relink and
  rescore that followed measured nothing.  `prepareINCLIB --clear
  --include=INCL80` first; the documented full-build sequence has it for this
  reason, and a targeted recompile that skips it silently builds the old
  source.  Verified safe before running: 279 INCLIB entries against 279 INCL80
  files, nothing present in one and not the other.
- **A second self-inflicted one**: a relink script called `dass-resolve.py` and
  `dass-score.py` by bare relative path from PFS, where they no longer live
  after the consolidation, with stderr sent to `/dev/null`.  All eight resolves
  failed invisibly and the score printed was the previous one.  Do not silence
  stderr on a step whose output is the measurement.
- **`#PCVKSAC` fixed, 160 halfwords across all eight configurations.**
  `CVAV_FLEX_TBL-STRUCTURE(10) INITIAL()` at `#PCVKSAC` offset 000116, source
  record `000440+6` via `D INCLUDE FLEXTBL`.  Six populated `F GEN` entries
  where every dump holds zero; the block's own change history reads "ADD F
  GEN/F END PAIRS".  Zeroed with the SRN column and line count preserved.
  Whole-image real differences 76967 -> 76807, each configuration by exactly
  20.  CSECT score unchanged at 8292/8292, which is the point: the CSECT
  columns cannot see this class at all.

### [2026-09-06] Target: problems.md
- **RETRACTION: "the `CDCDD*` family is 87% of the contested differences" was
  an artefact of my own code.**  I built an address->CSECT map with
  `owner[i]=n`, so for OVERLAPPING ranges the last writer won and every
  difference in a shared region was pinned to an arbitrary one of the
  candidates.  `#CDCDDG9` has ZERO real differences in G9, where it is
  genuinely loaded; its apparent 20345 came from G16 (6001), G3 (5645) and S2
  (8591), which are exactly the configurations where its range overlaps
  something else.  Attribution by name is meaningless for contested regions --
  not knowing which CSECT owns the address IS the problem.
- **The honest shape: 75914 halfwords in 8500 contiguous runs**, fragmented
  rather than concentrated.  Largest: S2 `030AC2-031875` (3508,
  `#PCSASAT` vs `#CDCDDG9`), S2 `031EEC-032B6B` (3200, `#PCPCCLT` vs
  `#CDCDDG9`), SSW `01E075-01EA30` (2492, four `FIO*` candidates), G3/G16
  `0303AA-030CCA` (2337, `#PCGN13R` vs `#CDCDDG9`).
- **The mechanism, on the largest run.**  S2 loads phases 10,2,13,3,14,15.
  `PHASE02` places `#CDCDDG9`; `PHASE14` and `PHASE15` place `#PCSASAT` and
  `#PCPCCLT` OVER it, so the later phase is resident -- which is what the dump
  holds (`4110 0000`, the float 1.0, is CSASAT's EU table).  Our whole-config
  link places all three at their index addresses and `#CDCDDG9` wins, so we
  write a G9 module over S2's real content.  **Placement order within the one
  link is the defect**, and the objlist's ORDER is the lever: later entries
  overwrite earlier ones.
- **Worse: `#PCSASAT` is `module: '<external-syms>'`** -- address-only, no
  content supplied at all.  `objects/CSASAT.obj` exists and defines
  `#PCSASAT`, and it IS in `objlist-S2-all.txt`, but it is dropped before
  `objlist-S2-resolved.txt`.  So even ordering correctly would leave the region
  empty; the module has to be kept as well.  Same family as §8.60's `CS2INB`
  and `CGBIH2`: reaches the configuration by a route the deck model does not
  see.  This also retracts §8.62's "`#PCSASAT` is address-only in every link so
  nothing compared depends on it" -- 3508 halfwords depend on it.
- **Phase-order COMPOSITION does not work** and was measured, not assumed:
  composing S2's image from the phase images in load order gives 41950
  identical against the current link's 212892.  The phase links use their own
  layout -- `PHASE15` puts `#PCSASAT` at `0314AA` where the index says
  `030AC2` -- so they cannot supply content at index addresses.  The fix is
  inclusion and ordering within the single whole-configuration link.

### [2026-09-06] Target: problems.md
- **Whole-image identity 97.09% -> 97.98%** over three fixes, CSECT score held
  at 8292/8292 throughout: `FLEXTBL`'s `F GEN` block zeroed (160 halfwords),
  the phase-order overlay rule (-22110), and `CSASAT`'s table 513 -> 451
  copies (-1194).  Real differences 76967 -> 53503.
- **THE OVERLAY RULE, and where the load order actually comes from.**  A phase
  deck states its own base ("MAJOR FUNCTION BASE IS PHASE THREE") and its
  `OVERLAY` region; phases 3, 9 and 14 overlay `Z2` and are the major-function
  bases, 4-8 base on 3, 12 on 9, 15/16 on 14, all overlaying `Z3`; and the GRT
  rows are exactly (base, overlay) pairs.  So a configuration loads phases in a
  known order and a later phase overwrites an earlier one.  `dass-link.sh` now
  drops the phase-order LOSER of each overlapping group and orders the
  contested owners so the later phase links last.  Ordering the whole list
  reaches 52838 but costs a CSECT and regresses 47 others; restricting the
  reorder to contested owners keeps 8292.
- **`CSASAT` retraction and the mechanism behind it.**  §8.62 said `#PCSASAT`
  is address-only in every link so nothing compared depends on it.  Wrong: the
  62 surplus table entries made the section 3756 halfwords against the index's
  3508, the 248-halfword overrun tripped `dass-link`'s overrun filter, the
  module was dropped from the link, `#PCSASAT` became an `<external-syms>`
  placeholder with NO content, and `DCDDG9` covered the region.  HALSTAT states
  `CSAS_SAT_ANA_SCALING-STRUCTURE(451)`, `SIZE 00070C(1804)` at `PHASE 14 ADDR
  03116A` -- the largest difference run exactly.  Size is settled; WHICH 62
  entries were dropped is NOT -- only 248 of 1804 halfwords match, so the
  removed ones are not the tail.  My truncation is provisional and marked so.
- **THE NEXT LEAD, and it is specific.**  Of 16822 isolated single-halfword
  differences, **6530 share one delta: ours = (dump + 0x30DE) mod 0x10000**,
  a wrapped 16-bit ADCON.  Every SECTION is placed exactly at its index address
  in all eight configurations, so this is not section placement -- it is symbol
  resolution putting a referenced address 12510 halfwords too high.  It spans
  many CSECTs and every configuration.  One cause, 6530 halfwords.
- **Two dead ends, measured not assumed.**  Filling uncovered gaps with `C6C6`
  is net WORSE (+10): it gains 60 in SSW and loses more elsewhere, because fill
  follows section ORIGIN, not address, as dass-link.sh's 2345-gap measurement
  already said.  And only 6% of the residue sits at an unresolved relocation,
  so that is not the bulk either.
- **Shape of what remains**: 53503 halfwords -- 4599 starred post-build or
  recomputed checksums (recovery artefact), 2946 at unresolved relocations,
  360 inter-section fill, 5 uncontested, and 48905 spread over 19581 runs with
  only 10050 of it in runs of 100 halfwords or more.
- **The 0x30DE class is NOT a separate defect -- retracting my own lead.**  All
  6530 halfwords of it lie inside CONTESTED regions, none in an uncontested
  CSECT and none outside any CSECT.  So it is the overlay-placement problem
  seen from another angle -- we place a different module than the dump holds,
  and the two candidates' contents are laid out relative to bases a constant
  apart -- and it is already inside the 49731 contested halfwords, not
  additional to them.  Three attributions were tried and all failed: a symbol
  address differing between links (no 0x30DE class exists among them), a
  repeated-constant artefact (2501 distinct value pairs share the delta, so
  no), and `#PCDWDOW`, which sits at exactly 0x30DE in every configuration but
  is not referenced by the affected modules -- an address coincidence I
  reported as a finding before testing it.
- **Dead ends, all measured, so they are not retried**: pure phase-copy
  substitution (-572965 halfwords, 3697 sections worse against 125 better);
  phase-order COMPOSITION from phase images (41950 identical against the
  current link's 212892 in S2); blanket `C6C6` gap fill (+10 net, because fill
  follows section ORIGIN not address); unresolved relocations (only 6% of the
  residue); `#PCDWDOW`.
- **A measurement error worth remembering**: I scored the phase-copy rule with
  `max(current, rule)`, which consults the answer, and reported +13020.  The
  pure rule is -572965.  Any rule that selects by fit against the dump is not a
  rule; check the expression, not just the number.
