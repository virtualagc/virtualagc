### [2026-08-05] Target: [compileLinkCompare.md]
- SSW baseline established.  145 source files make up SSW (138 .hal, 7 .dfg, which
  compileLinkCompare cannot process); 401 HAL/S CSECTs.  Result: 69 files match
  exactly, 67 differ, 2 error, 7 skipped.  Of 535 sections linked, 470 are really in
  SSW and 131 of those differ.
- The CSECT-to-source join in the document works and is unambiguous: strip the
  two-character prefix, match six characters against the descored source stem.  Over
  all eight configurations it maps every HAL/S CSECT to a file with no collisions and
  nothing left over.  Distinguish HAL/S from assembly and runtime by the presence of
  unlinkMAFGEN2's "hal" field, not by the name.
- The per-configuration counts in the document's table do not match what the index
  says.  Document: SSW = 387 HAL/S, 154 assembly, 119 runtime.  Counting by type:
  401 HAL/S (those carrying a "hal" block name, all of which match a source file we
  have), 72 HAL_LIBRARY_*, 187 other.  Worth reconciling; the totals agree at 660.
- The code/data split the document asked about does NOT hold.  Both differ, and the
  worst class is neither: PDE (#E) fails 29 of 29.  PROCEDURE 100 ok / 20 differ,
  DATA 83 / 35, ZCON 38 / 18, PROGRAM 0 / 29, and every HAL_LIBRARY_* section matches,
  110 of 110, as the document predicted.
- Root causes, not halfwords, exactly as the document warns.  131 differing sections
  reduce to three mechanisms, recorded in dass-compare.db's mechanism table:
  (1) pde-stack-address -- 67 sections, over half.  We leave PDE+4 (the stack
      address) zero and load R0 with an extra LHI at program entry; the original puts
      the address in the PDE, sets bit 15 of PDE+5, and emits no instruction.
      Emission is HALINCL/GENCLAS0.xpl:1790-1801.  No PASS2 code anywhere writes a
      stack address into the PDE, so this is absent rather than switched off.
  (2) compool-in-assembly-storage -- a COMPOOL whose storage is owned by an assembly
      CSECT (#PCDHMMU inside FCMBMTPG) has no CSECT of its own in the MAFGEN listing,
      so lnk101 links it at 0 and every reference comes out a bare offset.
  (3) csects-absent-from-config -- 65 of 535 sections are not in SSW at all and were
      being compared against unrelated memory.  Excluded now.

### [2026-08-05] Target: [HANDOFF.md]
- compileLinkCompare never passed --sdfi, so it read no SDFs and satisfied every
  "D INCLUDE TEMPLATE" from the template library alone -- a path compilePASS never
  exercises.  SSSRC/ARDCSBUS.hal found it: "REL3 SDF ##CDLANN NOT FOUND" and seven
  errors of severity 2.  The default now lives in halsParms.py as DEFAULT_SDFI, with
  --sdfi=D and --no-sdfi to override.  This did not skew comparisons, it removed
  files from them.
- compileLinkRun's cleanup block deleted nothing: its last three clauses read
  "symfile = f'...'" instead of "os.remove(...)".  That is the source of the
  BASENAME*.* residue in PFS/OI340600.  Fixed, and both scripts now take --out-dir=D.
- Both scripts ended their failure paths in os._exit(), which skips interpreter
  shutdown and discards stdout's buffer, so a failed compile printed its diagnostic
  and then exited with no output at all whenever stdout was a pipe.  Replaced with a
  flushing die().
- compileLinkCompare's rldanalyze fallback named "../{config}.fcm" and a literal
  "../csects-{config}.json" (missing f prefix); compileLinkRun's copy of it referred
  to `config`, which does not exist in that script, so a link failure raised
  NameError from inside the handler.  Fixed and removed respectively.
- Work directory is ~/ForClaude/OI340600-clc, seeded from PFS/OI340600's libraries.
  ~113 MB, and it keeps HALSFC's archive.results out of the PFS IDE project.

### [2026-08-05] Target: [README.md]
- New: dass-db.py (schema and CSECT/source mapping for all eight configurations) and
  dass-run.py (drives compileLinkCompare, parses fcmcmp, records runs/sections/diffs).
  dass-run.py --reparse rebuilds the database from saved logs without recompiling,
  which is what makes improving the parser cheap -- the first SSW survey had to be
  re-read twice, once for fcmcmp's em-dash and once for its shift analysis.
- The whole SSW sweep is 11 minutes at ~3s per file, so the document's advice to
  triage before building a driver costs almost nothing to disregard here.

### [2026-08-05] Target: [compileLinkCompare.md]
- Compiler version is NOT a suspect and options are closed as a lead.  HALSTAT
  (PFS/HALSTAT.ASC) records COMPILER and FLAGS per unit: all 1201 units are FC-32.0
  with FLAGS "SRN,ADDRS" (129 also DATA REMOTE).  FC-32.0 is REL32V0, the compiler we
  have.  Sweeping options over four sensitive files: baseline and +ADDRS are
  identical and best; dropping REGOPT or NOLFXI is strictly worse (ARFDPSCO goes from
  1 differing halfword to 1167 and 1027 respectively).  ADDRS is code-neutral -- it
  affects SDF content only -- so it is free to add and improves SDF fidelity.
- HALSTAT is a much better source than its size suggests: per unit it gives the
  compiler, flags, compilation parameters with high-water marks, and the full
  COMPILATION LAYOUT naming every external COMPOOL and the variables drawn from it.
  Our SDF's usage figures for AIB_GPC_LOCATOR match it exactly -- SYMBOLS 2700,
  MACROSIZE 19845, XREFSIZE 3452 -- which is independent evidence PASS1 is doing the
  same work as the original.
- The SDF flags field records only SRN, ADDRS, COMPOOL, FC, DIRECTORY_OVERFLOW,
  NON_MONOTONIC_SRNS, NON_UNIQUE_SRNS, NOTRACE, DATA_REMOTE, HIGHOPT, HALMAT, FCDATA,
  SDL and BITMASK (PASS4/DUMPSDF.xpl:993-1029).  REGOPT and LFXI are not among them,
  so "SRN,ADDRS" says nothing about either.
- Mechanism 1 renamed program-prologue-sdl and now understood.  USA003090 section 8.9
  (page 8-19, stamped 32.0/17.0) says that without SDL the compiler emits a START
  CSECT per PROGRAM and issues linkage-editor STACK cards "for stand-alone
  operation".  No configuration's CSECT index contains a START -- checked all eight --
  so the flight build had SDL.  Measured: SDL fixes 35 sections and breaks none;
  matching in-index sections go 339/470 to 373/469, and 27 of 29 PROGRAM CSECTs
  become byte-identical.  Against it: the SDF should record SDL and the original's
  does not, through the same bit at every stage.
- Mechanism 4 added, pde-stack-address-fill, and it is for lnk101's developer.  All 29
  PDEs differ in exactly two halfwords -- the stack CSECT's address and bit 15 above
  it.  Under SDL the compiler has no stack ESD at all, so it cannot be a compiler
  matter; MONITOR.ASM/HALLINK.bal's three-stage link through a STACKOBJ dataset is
  where the original filled it in.
- The CSECT-to-source join is now confirmed from the compiler source rather than
  inferred: PASS2/PROGNAME.xpl strips underscores and truncates to six characters, and
  its NAMETYPE table is $0 #C @0 #P #D #T #F A0 #Z #E #X #R.  USA003090 section 8.9
  gives the same list with #Q for library ZCONs and #L for library data.

### [2026-08-05] Target: [README.md]
- Extracted modules/sdfpkg/refs/HAL_S-FC-Users-Manual-2005.txt from USA003090 (the
  Nov 2005 HAL/S-FC User's Manual PDF), so it can be grepped rather than re-opened.
- HANDOFF.md section 3's warning about two compilations sharing a directory is not
  only about killed runs: two *live* sweeps in one work directory destroy each other
  the same way, through halmat.bin, litfile.bin and COMMON*.out.  Cost one option
  sweep and one SDL sweep, both restarted.  dass-run.py's --jobs-root exists for this.

### [2026-08-05] Target: [compileLinkCompare.md]
- SDL adopted for compileLinkCompare only, via halsParms.DEFAULT_SDL (a per-caller
  parameter, not a DEFAULT_OPTIONS entry).  compilePASS only populates libraries and
  compileLinkRun runs programs stand-alone, which is the case ^SDL is documented to
  serve; only compileLinkCompare is matching flight memory.  --no-sdl overrides.
  New SSW baseline: matching in-index sections 339/470 -> 374/470, PROGRAM CSECTs
  0/29 -> 27/29, DATA 83 -> 91.  96 sections still differ, 2 files still fail to link.
- SDL does NOT require SDFLIB to be regenerated -- the question worth asking, and the
  answer is measured, not assumed.  Same file compiled both ways, SDFs compared byte
  for byte: a COMPOOL's and a COMSUB's differ only in the recorded flag bit and the
  compile timestamp; a PROGRAM's differs additionally in one header count, 7 -> 6,
  which is the stack ESD that is no longer emitted.  Then the test that actually
  matters: AIBGPCLO includes the PROGRAM template AIE_SIP, so compile it against both
  versions of AIESIP's SDF -- the object modules differ in 4 bytes, all inside a SYM
  card's "T" timestamp, and a control compiling twice against the SAME SDF differs in
  the same bytes.  Content-identical.
- This also retroactively validates the SDL measurement itself, which ran against an
  SDFLIB left in a mixed state by the preceding baseline sweep.
- ADDRS deliberately NOT adopted, and recorded as such.  It is code-neutral, so it
  buys the comparison nothing; but it adds ~23 bytes of real content to a PROGRAM's
  SDF (26 differing bytes against a COMPOOL's 3), so putting it in DEFAULT_OPTIONS
  would make every SDF in SDFLIB stale pending a full compilePASS, with unmeasured
  effect on dependent compiles.  Revisit when the SDFs are the subject.
- CGBOBF.hal's failure under SDL was NOT an SDL defect.  It was stale intermediates
  from two sweeps that had shared a work directory; it compiles clean in isolation and
  in the re-measured baseline.  HALSFC's unguarded shutil.copy("litfile.bin", ...) at
  line 447 reported that leftover state as a bare Python traceback, which is what made
  it look like a defect in the option under test.  Guarded now.
- Where SSW stands: PDE 0/29 (the linker mechanism), ZCON 38/18, PROCEDURE 100/20,
  DATA 91/27, PROGRAM 27/2, and every HAL_LIBRARY_* section matching, 110 of 110.

### [2026-08-05] Target: [compileLinkCompare.md]
- CORRECTION to the SDL entry above, from the user: SDL generates code for the
  Software Development Lab, a ground facility; NOSDL generates flight code.  I had it
  backwards.  The measurement is unaffected -- the dumps match SDL-compiled code
  either way -- but the reason is better: a DASS disassembly and a HALSTAT statistics
  report are debugging material, of no use in flight, so PFS/mafgen's images are of an
  SDL build and reproducing them means compiling as the SDL did.  The option's effects
  read the other way at first glance, since NOSDL is what emits the START CSECT and
  static stacks the manual calls "stand-alone operation".  Wording fixed in
  halsParms.py and compileLinkCompare.
- pde-stack-address-fill is now fully specified and verified, and it is a LINK-time
  fixup.  For PDE slot k of #E<name>: halfword +4 := address of stack CSECT
  @<k><name>, halfword +5 := its existing value with bit 15 set.  Nothing else.
  Verified over all eight dumps: 361 PDE slots, rule holds 361, no violations, every
  slot has a matching stack CSECT.  Multi-task PDEs included -- G9 has 80 slots.
- That it is link-time rather than load-time was worth settling, since a value written
  at process creation could never be matched by a static image.  All 30 SSW stack
  CSECTs are pure C9FB fill over their whole extent, so the dump is a stored load
  image, not a running snapshot -- yet the PDEs already carry the addresses.
- The compiler cannot do it: under SDL, SETUP_STACKS returns before entering any stack
  ESD (PASS2/INITIALI.xpl:431), so PASS2 never learns the address.  lnk101 can: the
  @<k><name> STACK entries with their addresses are already in the csects-XXX.json it
  receives as --external-syms, so this is a lookup and not an allocation.
- Demonstrated by patching our linked image by the rule and re-running fcmcmp:
  APPLSRC/GI1GPS.hal goes from "FAIL: 1/3 sections differ" to "PASS: all 3 sections
  match".  Ready to package for lnk101's developer when you want it sent.

### [2026-08-05] Target: [compileLinkCompare.md]
- EVERY CODE CSECT IN SSW NOW MATCHES.  PROCEDURE 120/120 and PROGRAM 29/29, plus all
  110 HAL_LIBRARY_* sections.  In-index sections matching went 339/470 (start of the
  session) to 400/470.  What remains is 70 sections and none of it is code: PDE 29,
  DATA 23, ZCON 18.
- compool-in-assembly-storage is fixed, and it was a gap in csects-XXX.json rather
  than a defect of ours.  A COMPOOL whose storage an assembly module owns has no CSECT
  of its own in the MAFGEN listing -- the memory is attributed to the containing
  assembly CSECT -- so lnk101 had nothing to resolve it to and linked it at zero.  90
  external symbols were unresolved in SSW this way.
- PFS/HALSTAT.ASC supplies the missing addresses.  Per compilation unit it carries a
  "CSECT INFORMATION" block giving each CSECT's address and size in each memory phase.
  A phase is NOT a configuration: phase 2 is the resident portion shared by all eight
  (358/358 agreeing with csects-SSW.json), and each configuration adds overlays --
  G16 phase 4, G2 5, G3 6, G8 7, G9 8, P9 12, S2 14+15.
- The discriminator, so this is not fitting a number to the answer: lnk101 reports
  every unresolved relocation with its site and addend, so the dump at that site minus
  the addend gives the base the original must have used -- one equation per reference.
  An address is accepted only where the dump-derived base and a HALSTAT candidate
  agree independently.  #PCDHMMU: 170 of 184 references agree on 0xABB8, exactly
  HALSTAT's phase-12 figure.  #PCVWMMU: 12 of 12 on 0x6C32.
- An address above 64K is stored in the low halfword with bit 15 set -- the same paged
  form sdf.py's mode5 handles.  #PCDIMMU proves it: HALSTAT 0x2065E, dump-derived
  0x865E = (0x2065E | 0x8000) & 0xFFFF.  Adding that comparison recovered a tenth
  symbol my hand pass had rejected.
- 10 of 90 symbols recovered; they fix 26 CSECTs and break none.  Conservatism is the
  point: most of the other 80 are compools of other configurations, referenced by an
  SSW module but pointing into memory SSW does not contain, and their dump-derived
  bases do not converge (ratios like 1/57), which is the signal that there is nothing
  to find.

### [2026-08-05] Target: [README.md]
- New: dass-syms.py, which parses HALSTAT's CSECT INFORMATION, cross-validates each
  candidate against the memory dump via lnk101's unresolved relocations, and emits an
  augmented external-symbol table.  It needs a sweep's link outputs (--out-dir kept) to
  know which symbols went unresolved and where.  csects-SSW-augmented.json is the
  result for SSW; pass it to compileLinkCompare as --ext-syms.

### [2026-08-06] Target: [compileLinkCompare.md]
- pde-stack-address-fill is FIXED, in lnk101 itself.  Linker.completeProcessDirectoryEntries()
  in ~/donschmidt/nsts-sdl-dps/src/LNK101/lnk101/linker.py, called from link() after
  applyRelocations() -- after because it writes into the placed image, separately
  because under SDL there is no relocation to hang it on.  Stack address from the
  global symbol table when the stack is in the link, otherwise from the external
  symbol table, which under SDL is the usual case.  --no-pde-stacks disables it.
  Committed on branch pde-stack-address in that repo; NOT pushed, no PR opened.
- SSW is now 429/470 in-index sections matching, 95 of 138 files matching completely.
  PDE 29/29, PROCEDURE 120/120, PROGRAM 29/29, all 110 HAL_LIBRARY_*.  Remaining: 41
  sections, DATA 23 and ZCON 18.
- lnk101 already had Addr.sector_encode(), which is exactly the paged-halfword rule
  found independently from #PCDIMMU: 0x8000 | (hw & 0x7FFF) for hw >= 0x8000.  Every
  stack CSECT across all eight configurations is below 0x10000 (highest 0xE914), so
  raw and encoded agree and the choice is not load-bearing here.
- nsts-sdl-dps's ctest is 176 of 204 FAILING on a clean tree, on .fcm inputs that were
  never produced -- nothing to do with linking.  Verified by reverting the change,
  rebuilding and re-running: the failure sets are identical before and after.  So
  "tests pass" is not available as a gate there; "no change in the failure set" is.

### [2026-08-06] Target: [compileLinkCompare.md]
- The ZCON group is FIXED, all 18, and it was not what I guessed.  These are not
  consequences to be written off: a configuration can carry a module's ZCON without
  carrying the module, and the ZCON is a CROSS-CONFIGURATION POINTER holding the
  address the code has in whichever configuration does load that overlay.  SSW's
  #ZDCDDG1 points at 0x1DE62, which is where G16 keeps #CDCDDG1.
- Recovered from the OTHER CONFIGURATIONS' OWN INDEXES, which beat HALSTAT here: same
  unlinkMAFGEN2 scrape, carries sizes, and covers HALSTAT's misses (#CDCDDG3 and
  #CDKFCM9 are in no HALSTAT phase but sit in G3's and G9's indexes at exactly the
  decoded address).  HALSTAT still earns its place for #CDCDDS4 and #CDKFCM5, which
  are in none of the eight configurations we have dumps for.
- Discriminator is the dump's own decoded ZCON: HW0 sector-encoded address, HW1 with
  BSR bits 7-4 (code) and DSR bits 3-0 (data).  A candidate is accepted only if it
  equals the decoded value.  All 18 agree.
- Both #C and #D are needed from the same source; #C alone fixes HW0 and leaves HW1's
  sector fields wrong, leaving the ZCON differing by one halfword.
- User's observation that the CSECT name encodes the configuration is a good sanity
  check and held for every case, but it is NOT the rule and is not relied on.
  IBM-82-SS-4556 section 2.1.1.1 gives the block-label format as ABB_C...C with only
  the subsystem ID and a two-character ID structured, the rest "descriptive of the
  purpose of the code block"; downlist units take a DCD prefix, so DCDDS8 is DCD +
  "DS8".  There is no S8 configuration -- confirmed by the user -- and #CDCDDS8 sits
  in P9's index accordingly.  S4 does exist; we have no dump for it.
- My phase-to-configuration table was inferred from agreement counts and is only a
  rough guide: several phases serve more than one configuration, and phases 16 and 18
  correspond to configurations we have no dump for.  Nothing relies on it; every
  address is accepted on direct evidence.
- SSW now: 447/470 in-index sections matching, 113 of 138 files matching completely.
  ZCON 56/0, PDE 29/0, PROCEDURE 120/0, PROGRAM 29/0, all HAL_LIBRARY_*.  Remaining:
  DATA 23, plus 2 files that still fail to link.
- dass-syms.py gained --base, because the relocation-evidence pass can only see a
  symbol that was unresolved in the sweep it reads: re-running it against a sweep that
  already used the augmented table finds nothing and would silently drop the earlier
  recoveries.  The cross-configuration pass has no such dependency.

### [2026-08-06] Target: [README.md]
- Extracted modules/sdfpkg/refs/IBM-82-SS-4556-Programming-Standards-Rev4.txt, the
  Orbiter Avionics Software Programming Standards Document, for its naming standards.

### [2026-08-06] Target: [compileLinkCompare.md]
- The DATA class is now understood in structure, though not closed.  13 of the 23
  differing DATA sections look like "we emit content where the dump is fill" and are
  mostly NOT differences at all: they sit in the "??? ADCONS,LITERALS,ETC. ???" region
  at the head of a #D, which MAFGEN's data listing skips.  unlinkMAFGEN2 leaves the
  range at its not-initialised marker (0xC9FB / 0xC6C6, unlinkMAFGEN2.py:481-488), and
  fcmcmp's --equiv only treats a pair as equal when BOTH sides are in the set, so our
  real content is reported against their nothing.
- MAFGEN does know those halfwords: it prints them as literals wherever code refers to
  them -- "LITERAL: =F'-2132803578', =X'80E00006'" against EFFAD 000728, which is
  #DAIBGPC+0x2C.  Harvesting every such annotation over DASS_SSW gives 356 addresses
  with ZERO conflicting values, 33 of them where the scrape lost the data.
- Comparing ours against those recovered values, restricted to sections the module
  actually owns: 22 agree, 10 disagree.  So most of the class is a scraping gap, and
  the residue is real and systematic.
- The residue is a constant small delta in pointers to remote COMPOOLs, almost always
  exactly 2 halfwords high: ours 8213 vs DASS 8211, 8659 vs 8657, 8011 vs 800F, 800D
  vs 800B.  Decoding 8213 with DSR 5 gives 0x28213; csects-SSW.json puts #PCDB021 at
  0x28212, so we point at base+1 where the original points at base-1.  The same delta
  appears directly in #PCDAP02, every diff exactly 2 high.  #PCANNCO's delta is 0x80
  and may be a different cause.
- Also worth knowing: fcmcmp cannot distinguish "the dump says fill" from "the dump
  says nothing".  Feeding the recovered literals back -- as a diff-json overlay, or by
  teaching unlinkMAFGEN2 to scrape LITERAL annotations -- would remove the false
  differences and leave only the real ones.  That is probably the next piece of
  tooling, and it benefits every configuration.

### [2026-08-06] Target: [compileLinkCompare.md]
- Tooling fixed before chasing the delta, on the user's suggestion, and it was the
  right order: it removed a known false factor and in doing so EXPOSED real
  differences that were previously invisible.
- fcmcmp gained --no-data C9FB,C6C6.  Those two values are not observations: for any
  halfword the MAFGEN listing never reported, unlinkMAFGEN2 leaves -1 and then
  synthesises a value purely from the address (unlinkMAFGEN2.py:481-488, 0xC9FB below
  0x20000 and 0xC6C6 above).  Comparing against a guess manufactured differences.
  Such halfwords are now a THIRD category -- neither matched nor counted as differing,
  reported per section as "[N no reference data]" and totalled at the end -- so
  nothing is hidden.  Default is empty, preserving existing behaviour.
- New dass-literals.py recovers the values MAFGEN does report but the scrape drops.  A
  literal is data, but MAFGEN prints it against the instruction referencing it, with
  the effective address: "LITERAL: =F'-2132803578', =X'80E00006'" against EFFAD 000728.
  Over SSW that is 1053 addresses, 0 contradicting, of which 1342 halfwords are also
  present in the scrape and ALL 1342 agree -- an independent check that the parse is
  right -- and 67 fill halfwords the scrape had synthesised.  Writes a patched copy;
  PFS/mafgen is untouched.  Pass it as --memory=.
- Both together: SSW goes from 447/470 sections matching to 454/470, and from 113 of
  138 files exact to 120.  16 differing sections remain, ALL of them DATA.
- The two halves are complementary and neither alone is right.  --no-data alone would
  have marked #DAIBGPC and #DAIESIP as fully matching, because the halfwords where
  they disagree are exactly the ones the scrape lost; the patched image turns those
  back into real, countable differences (n=1 and n=3).
- WATCH THE PARSER when fcmcmp's output changes.  Adding "[N no reference data]"
  between the size and the em-dash silently stopped dass-run.py's SECTION_RE matching
  those lines, so ten sections vanished from the database and the totals looked better
  than they were (470 in-index became 460).  Caught by the section count moving in the
  wrong direction.  --reparse fixed it without recompiling anything.
- Remaining 16, and they are now a small sharply-defined set: six with a single
  differing halfword (DCDDOW, VMELOAD, AIBGPCLO, CDULNK, DM4DEU, DM9ITEM), then
  AIESIP 3, CGBOBF 4, DMTERR 5, CDAP02 6, CZ3COM 9, CVKSACSC 20, CRDCIL 24, and three
  large ones that look like a different problem: CDCPHA 48 of 57, FCMGPT 955 of 1093,
  CDQANNUN 1981 of 2010 with the length itself wrong (2010 against 2695 expected).
