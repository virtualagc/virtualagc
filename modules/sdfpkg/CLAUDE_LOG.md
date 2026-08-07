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

### [2026-08-06] Target: [compileLinkCompare.md]
- THE DELTA IS A LINKER BUG, and the cleanest one yet.  lnk101 dropped the RLD sign
  bit on the ZCON path: linker.py masked the flags to the type to dispatch
  (flags & 0x7F) and ZCon.apply then built its AddrCon from the masked value, so
  AddrCon.sign was always 0.  A negative displacement was therefore ADDED instead of
  subtracted, putting every such pointer out by exactly twice the displacement.
  The YCON/ACON path was always correct -- it passes the whole flag byte.
- The evidence was unambiguous.  Every affected halfword carried fcmcmp's own
  "(negative disp.)" annotation, printed from flags & 0x80, so the bit was
  demonstrably in the data; and the error was exactly 2x the displacement each time:
  #PCDB021 base 0x28212, dump base-1, ours base+1; #PCANNCO base 0x30120, dump
  base-0x40, ours base+0x40.
- Fixed by passing the unmasked flag byte to ZCon.apply too, defaulting to the masked
  one so an existing caller is unaffected.  Branch zcon-negative-displacement, off
  master, NOT pushed; draft PR text in ~/ForClaude/PR-zcon-negative-displacement.md.
- MEASURED: six DATA CSECTs become byte-identical (#DVMELOA, #DAIBGPC, #DDM4DEU,
  #DDM9ITE, #DDMTERR, #PCDAP02) and #DAIESIP drops from 3 differing halfwords to 2.
  SSW is now 460/470 sections matching and 126 of 138 files exact.
- BRANCH HYGIENE COST ME A FALSE ALARM.  I built and tested from fcmcmp-no-data, which
  branches off master and does NOT contain the PDE fix, so DMTERR's PDE appeared to
  regress.  It had not; the fix simply was not in that build.  There are now three
  independent upstream branches plus a local-only `integration` branch that merges all
  three, and sweeps must be run from `integration` or the results are not comparable.
- Remaining 10 differing sections, all DATA, and they no longer look like one thing:
  DCDDOW 1, CDULNK 1, AIESIP 2, CGBOBF 4, CZ3COM 9, CVKSACSC 20, CRDCIL 24, and three
  large ones -- CDCPHA 48 of 57, FCMGPT 955 of 1093, CDQANNUN 1981 of 2010 with the
  length itself wrong (2010 against 2695 expected).  The last three are probably a
  different problem from the rest.

### [2026-08-06] Target: [compileLinkCompare.md]
- PR #29 opened for the ZCON sign fix.  All three linker PRs (#27 PDE, #28 fcmcmp
  --no-data, #29 ZCON sign) are now open and ready for review, none draft.
- The small residue is CLOSED, and it closes as correctly unfixable.  MAFGEN prints a
  leading asterisk on a value whose contents are not what the build produced --
  I-LOADs and patches applied after linking.  The names say it: MISSION_ID *001D,
  CDUV_NSP_VEHICLE_ILOAD *0005, FCMMGPT_NUM_LOAD_BLKS *000A.
- The test is as clean as they come: of the 127 asterisked locations inside a section
  we link, our value matches 0 times and differs 127.  A hundred per cent.  If the
  asterisk meant anything else we would match at some of them, since we now reproduce
  most of what we compare.
- Accounts for #DDCDDOW 1 of 1 and #PCDULNK 1 of 1 entirely, #PCGBOBF 2 of 4 (the
  other two are the same variable on lines the pattern misses), #PFCMGPT 118 of 955,
  #PCDCPHA 3 of 48.  Nothing of CZ3COM, CVKSACSC, CRDCIL or CDQANNUN.
- AIESIP fixed too, by re-running dass-syms.py against the post-fix sweep: #PCSZICC
  now has 2 usable references and both corroborate HALSTAT's 0xA77C, where before the
  negative-displacement fix the noisier sites diluted it below the 60% threshold.
- WORTH KNOWING: the same regeneration accepted 18 more symbols on the weaker "sole
  HALSTAT candidate, no contrary evidence" rule, and they changed NOTHING -- the sweep
  moved 460/470 to 461/470 and the single gain was AIESIP, from the one corroborated
  address.  Every real improvement so far has come from dump-corroborated addresses.
  The weak rule is harmless but has yet to earn its place; drop it if it ever misfires.
- SSW now 461/470 sections and 127 of 138 files exact.  Nine differing sections
  remain, all DATA, in two groups: CZ3COM 9, CVKSACSC 20, CRDCIL 24 (we emit values
  where the dump has 0000), and the large ones CDCPHA 48 of 57, FCMGPT 955 of 1093,
  CDQANNUN 1981 of 2010 -- the last with its LENGTH wrong too (2010 against 2695
  expected), which points at the source rather than at the build.

### [2026-08-06] Target: [compileLinkCompare.md]
- I was wrong to file the starred locations as unfixable.  "The values are not
  reproducible" and "they must keep appearing as discrepancies" are different claims
  and only the first is true.  The user's point stands: a class that has to be
  explained away every time a report is read is a tooling gap, and bookkeeping beats
  prose.
- fcmcmp gained --exceptions, taking a file of "address value [name]" lines and
  reporting matches as "[N patched after build]" instead of as differences.  An entry
  is honoured ONLY where the reference image really holds the claimed value; a
  mismatch is warned about and ignored, so a stale file cannot suppress a real
  difference.  dass-literals.py --exceptions=F generates the file from the DASS.
- Reading the listing right took two passes.  Starred values come in two line shapes:
  a named variable carrying one ("CDUV_NSP_VEHICLE_ILOAD *0005"), and a hex-dump row
  carrying several consecutive ones ("--------+0000  *0000 *1381"), which is how
  CHECKSUMs appear.  Treating the second like the first put right values at wrong
  addresses.  The generator now self-checks every entry against the .fcm -- 1193
  entries, 1193 agree, 0 disagree -- which caught it.
- SSW: differing sections 9 -> 4, files matching completely 127 -> 132 of 138, and
  466 of 470 in-index sections match.  #DDCDDOW, #PCDULNK, #PCGBOBF, #PCDCPHA and
  #PFCMGPT all clear, FCMGPT's 955 differing halfwords included -- they were almost
  all mass-memory load parameters.
- THE PARSER BROKE THE SAME WAY A SECOND TIME.  A regex spelling out
  "[N no reference data]" stopped matching once the bracket could also say
  "[N patched after build]", so five sections vanished and errors went 2 -> 6.  It now
  matches any bracketed note and parses the counts out afterwards.  Twice is a
  pattern: never spell fcmcmp's wording into the regex.
- Remaining: FOUR sections, all DATA.  #PCZ3COM 9, #PCVKSAC 20, #PCRDCIL 24 -- we emit
  values where the dump has 0000 -- and #PCDQANN 1981 of 2010, whose length disagrees
  too (2010 against 2695 expected), pointing at the source rather than the build.

### [2026-08-06] Target: [compileLinkCompare.md]
- PR #30 opened for fcmcmp --exceptions (stacked on #28).  Four upstream PRs now open.
- The three same-shape sections are RECONFIGURATION DATA, and they are one mechanism.
  #PCZ3COM's CZ3_FLEX_MDM_TABLE and #PCVKSAC's CVAV_FLEX_TBL are both initialised
  inside "F GEN" ... "F END" regions -- column-1 F cards bracketing a generated block
  -- in INCL80/FLEXDATA.hal and INCL80/FLEXTBL.hal.  Our tree's copy carries device
  IDs and indices; the STS-134 memory holds zeros throughout both.
- #PCRDCIL is the one that proves the compiler is right.  CRDS_MTR_SPD_THRESH's
  INITIAL list names CSSS_COT_985296 and siblings, and INCL80/CSSCOTR.hal says
  REPLACE CSSS_COT_985296 BY "2.4853566".  Our image holds 4127C405, which as an IBM
  float is 2.48535 -- converted exactly right.  The dump holds 425A0000, which is
  90.0.  Same compiler, different input.
- So this is a SOURCE-DATA difference, not a build defect, and a different class from
  the starred locations: MAFGEN does not mark these, because the build really did
  place them -- from other data than ours.
- DELIBERATELY NOT added to the exceptions file.  That mechanism is for locations the
  listing marks as changed after the build, and it verifies each entry against the
  reference image.  Stretching it to cover "our source disagrees" would turn a narrow
  checkable statement into a way of silencing anything inconvenient.
- SSW therefore stands at 466 of 470 in-index sections matching, 132 of 138 files
  exact, with four differing sections: three reconfiguration-data and #PCDQANN, whose
  length disagrees (2010 halfwords against 2695 expected) and which is still unexamined.

### [2026-08-06] Target: [compileLinkCompare.md]
- #PCDQANN is the SAME mechanism as the other three, not a separate problem, and my
  guess that its length mismatch pointed at CARDTYPE or conditional compilation was
  wrong.  SSRC/CDQANNUN.hal is generated data almost end to end -- six "F GEN ...
  F END" regions across 1328 lines -- and the numbers are visible in it:
      DECLARE CDQV_INDEX_ARRAY ARRAY(4) INTEGER INITIAL(
    F GEN ...
         18,278,575,1815
  which is exactly what we emit at +0000 (0012 0116 023F 0717).  The dump has
  28, 443, 915, 2443.  And CDQK_PL_FMPS, declared STRUCTURE(278) here, occupies 886
  halfwords in the dump = 443 copies of two -- the same 443 the dump's index array
  carries in the same slot.
- So STS-134's annunciator tables were generated with 443 payload entries where ours
  have 278, and the CSECT is 2695 halfwords against our 2010 because of that.  The
  length disagreement is a consequence of the data, not a symptom of the build.
- SSW IS EFFECTIVELY COMPLETE.  466 of 470 in-index sections match byte for byte, 132
  of 138 files match completely, and all four differing sections are one understood
  mechanism: our source tree's generated/reconfiguration data is from a different
  reconfiguration than STS-134's.  Every category of CSECT -- PROCEDURE, PROGRAM, PDE,
  ZCON, EXCLUSIVE and all HAL/S runtime library -- matches in full.
- Two files still fail to LINK and have never been examined: APPLSRC/CVJFDECP.hal and
  APPLSRC/DGRGSERO.hal.  They are the last unexplained thing in SSW.

### [2026-08-06] Target: [compileLinkCompare.md]
- WHAT WE ARE COMPARING, stated properly: the source is OI-34.06 and the MAFGEN
  listings say "AT RELEASE 034    VERSION 070", i.e. OI-34.07.  The claim that source
  is identical across OI-34.xx and only patches differ is measurable, because HALSTAT
  records each unit's RVL and our source carries a two-letter revision code in columns
  79-80 of every card.
- Over SSW's 137 HAL/S files, comparing the highest revision code in our file against
  HALSTAT's RVL for the same unit:
      at the SAME revision:  21 files, 0 differ or error
      at a LATER revision:  116 files, 6 differ or error
  So a revision bump changes what we can see 5.2% of the time.  "Very close to 100%
  true" is 94.8%.
- The correlation is perfect the other way: ALL SIX files that differ or fail are ones
  OI-34.07 revised, and not one same-revision file gives trouble.  CVJFDECP is 10
  revisions newer, CZ3COM 9, CVKSACSC 4, DGRGSERO 3, CRDCIL 2, CDQANNUN 1.
- This reframes the four DATA differences.  The "F GEN ... F END" generated-data
  observation stands -- that is what the data IS -- but the reason our copy differs is
  better stated as OI-34.07 having revised those units than as per-vehicle
  reconfiguration.  Same conclusion, better supported.
- It also predicts the two link failures, which were the last unexamined thing in SSW.
  Check the revision gap before treating either as a defect of ours.
- It does NOT undermine the fixes.  A dropped sign bit, an unfilled PDE field and a
  masked flag byte are structural and independent of the release.  Nor the positive
  result: 131 of 137 SSW files reproduce OI-34.07 memory byte for byte from OI-34.06
  source, which is a strong statement about the compiler and linker precisely BECAUSE
  the inputs are a release apart.

### [2026-08-06] Target: [compileLinkCompare.md]
- THE TWO UNLINKABLE FILES ARE FIXED, and writing them off would have been wrong.  It
  was tempting once the revision analysis showed both were heavily revised, but a link
  failure is a toolchain problem, not a version difference.
- CVJFDECP referenced seven undefined #E symbols and DGRGSERO two.  A #E is a process
  directory entry, so this is a SCHEDULE of a program living in another
  configuration's overlay -- the cross-configuration case already handled for ZCONs,
  reached through a different kind of reference.  All nine are in G9 or G16 and in
  HALSTAT at the same address.
- lnk101 is lenient about an undefined #P COMPOOL (warns, links at zero) and strict
  about everything else, so these failed outright, wrote no symbol JSON, and dropped
  out of the comparison entirely -- worse than differing, because a file with no
  result is invisible in the totals.
- Two consequences, both handled: the relocation pass reads symbol JSONs and a failed
  link writes none, so these had to come from the LOGS; and the log has two wordings,
  "Undefined symbol:" and "Undefined COMPOOL:".  Scraping only the first left DGRGSERO
  linking but two halfwords out on #PCV1LSR and #PCV9LSR, whose addresses (0xEE2A,
  0xA324) are corroborated three ways -- dump-implied base, other config's index, and
  HALSTAT.
- SSW NOW HAS NO ERRORS AT ALL.  Every one of its 138 HAL/S files compiles, links and
  compares.  472 of 476 in-index sections match, 134 of 138 files are byte-identical,
  and the only four differing sections are exactly the four units OI-34.07 revised.

### [2026-08-06] Target: [compileLinkCompare.md]
- SSW IS COMPLETE.  138 of 138 HAL/S files match, 476 of 476 in-index sections, zero
  errors and zero differences.  Of those sections, 5 carry verified post-build patches,
  10 carry halfwords the listing never reported, and 4 carry no-claim entries for the
  units OI-34.07 revised.  Everything else is byte-identical to the memory dump.
- The user's -1 proposal is better than either of the alternatives I offered.  An
  exceptions entry with a value ASSERTS the reference image holds it and is verified;
  -1 asserts nothing at all, only "ignore this address, the difference is expected on
  grounds recorded elsewhere".  Writing the dump's own value in would have verified
  trivially while claiming knowledge we do not have.  fcmcmp reports the two
  separately, as "[N patched after build]" and "[N ignored]".
- New dass-versions.py emits the -1 entries.  It acts only where HALSTAT's RVL is
  newer than the highest revision code in our source, names the unit and the gap in
  every line, and reports what it acted on: CDQANNUN CD->CE 1981 halfwords, CRDCIL
  BI->BK 24, CVKSACSC AU->AY 20, CZ3COM AK->AT 9.
- It caught a flaw in itself first.  Written naively it also emitted entries for
  DKFCM1/3/9 and DG9LIGHT -- units that match perfectly -- because their #C and #D
  sections are placed at another configuration's addresses and compared against
  unrelated memory.  Restricted to CSECTs the configuration's own index contains.
- THIRD TIME BUILDING FROM THE WRONG BRANCH, and the worst one: differing sections
  jumped from 4 to 33 and it looked like a regression in the change under test.  It
  was a build off fcmcmp-exceptions, which branches off master and predates the PDE
  and ZCON fixes.  dass-run.py now warns if nsts-sdl-dps is not on `integration`.
- Parser generalised again.  NOTE_RE spelled out the known phrases, so the new
  "[N ignored]" was not recorded and the database showed nothing suppressed while the
  report showed plenty.  It now matches any "N phrase".  That is three format changes
  in a row; the lesson is written down twice already.

### [2026-08-06] Target: [compileLinkCompare.md]
- P9 IS COMPLETE, and NO NEW MECHANISM WAS NEEDED.  158 of 158 HAL/S files match,
  509 of 509 in-index sections, zero errors, zero differences.  Every tool ran
  unchanged: dass-literals.py, dass-syms.py and dass-versions.py all take --config and
  needed no edits at all.
- That is the premise of the whole phase confirmed.  compileLinkCompare.md predicted
  that a mechanism knocked down in one configuration is already fixed wherever else it
  occurs, and that later configurations should go much faster than their size
  suggests.  SSW took most of a session and seven mechanisms; P9 took three sweeps,
  about forty minutes of compute, and no investigation beyond one iteration.
- The sequence that works, and it is now routine:
     1. dass-literals.py --config=X            (independent of any sweep)
     2. sweep with the plain index             -> harvest unresolved relocations
     3. dass-syms.py --config=X                -> recover addresses
     4. sweep with the augmented index
     5. dass-syms.py again with --base         -> a second pass picks up symbols whose
                                                  evidence was diluted by noise the
                                                  first time round
     6. dass-versions.py --config=X            -> no-claim entries for revised units
     7. final sweep
- Step 5 matters and is not optional.  In both configurations exactly one symbol
  (#PCSZICC at 0xA77C) needed it: its references only stop disagreeing once the other
  fixes are in, and until then the vote ratio falls below the acceptance threshold.
- P9 progress by stage: 122 match / 33 differ / 3 link errors with the plain index;
  149 / 9 / 0 after symbol recovery; 158 / 0 / 0 after the second pass and the version
  no-claims.  The three link errors were the same foreign-#E-symbol mechanism as SSW's
  two, fixed by the same code.
- Of P9's 169 source files, 133 also appear in SSW.  They still had to be verified,
  since P9 places them at different addresses -- and they all matched, which is a
  stronger statement than it looks: the same object code relocated to a different
  memory layout still reproduces the dump byte for byte.
- Standing: SSW and P9 both complete.  Six configurations left -- G8 849, S2 865,
  G9 896, G2 1010, G3 1228, G16 1406 HAL/S CSECTs.

### [2026-08-06] Target: [compileLinkCompare.md]
- PARALLEL SWEEPS HAD A REAL BUG AND IT COST A WHOLE CONFIGURATION.  dass-run.py's
  --jobs assigned job i the tree i % N, which does NOT guarantee one compile per tree:
  with four workers, a slow job in tree 1 is still running when job 5 starts, and job
  5 was also given tree 1.  Two compiles in one directory corrupt each other's
  halmat.bin, litfile.bin and COMMON*.out and end in "Unable to open COMMON input
  file" -- precisely the failure HANDOFF.md section 3 describes, and precisely what
  the option exists to prevent.  My own docstring for --jobs-root warned about it.
- It produced 60 spurious errors in G8 (44 compile, 16 link) out of 332 files, plus an
  unknown share of the 14 differing sections.  Fixed by exclusion through POSSESSION
  rather than arithmetic: a queue.Queue of trees, each worker taking one for the
  duration of a compile and returning it afterwards.  --jobs > number of trees is now
  an error rather than silent overcommitment.
- Worth remembering as a class: a scheme that looks like it partitions work can fail
  to, if the partition is by index and the work is not uniform.  The symptom did not
  look like a concurrency bug -- it looked like 44 files that would not compile.
- Also note: archive.results had reached 126 GB over 2651 compiles, about 48 MB each.
  Six configurations at three sweeps each would be roughly 340 GB against 539 GB free.
  run-configs.sh purges the archives before every sweep; nothing in them is needed
  once fcmcmp has run, and a single file can be recompiled by hand when it is.

### [2026-08-06] Target: [mafgenComparison.md]
- TO WRITE, no hurry: an end-to-end account of the comparison process for somebody not
  familiar with it, at PFS/mafgenComparison.md.  Should cover what is being compared
  and against what (OI-34.06 source, OI-34.07 dumps), the seven-step per-configuration
  sequence, what each of the five dass-*.py scripts does and why, the three kinds of
  exception (verified patch, no-claim, no reference data) and the standard of evidence
  each represents, and how to tell a real discrepancy from an artefact.  The mechanism
  table in dass-compare.db is the raw material.

### [2026-08-06] Target: [compileLinkCompare.md]
- G8 with the concurrency fix: 1625 of 1637 sections match, 12 differ, 7 link errors
  (was 60 errors with the broken tree assignment).  S2 onward running.
- The 7 remaining G8 link failures are a NEW variant, and the right fix is identified
  but deliberately deferred to avoid changing tooling mid-run.  They need undefined
  #Z symbols -- another module's ZCON -- rather than the #E PDEs SSW and P9 needed.
  dass-syms.py refused them correctly: #ZGK5MNV exists in G2 at 0x3F0, G3 at 0x4B2 and
  G16 at 0x41E, three different addresses, and the recovery requires its sources to
  agree.  The discriminator used everywhere else -- the dump's value at the
  referencing site minus the addend -- needs lnk101's relocation records, and a link
  that FAILS writes no symbol JSON at all.
- Confirmed the way out: re-linking with lnk101 -f produces the JSON anyway, and its
  unresolvedRelocations give exactly the evidence needed.  On GKRORB that immediately
  yields #PCGZ123 at 0x827C.  (#ZGK5MNV's own site is fill in the dump, so it stays
  ambiguous and would still be refused -- correctly.)
- PLAN: after all six configurations have run, add to compileLinkCompare a retry with
  -f whose only purpose is to write the symbol JSON, so a failed link still
  contributes evidence to the next recovery pass, while still being reported as a
  failure.  Then re-run whichever configurations still show errors.  Doing it now
  would leave the six configurations built by different tooling.

### [2026-08-06] Target: [compileLinkCompare.md]
- S2: 1227 of 1249 sections match, 22 differ, 1 error.  G8: 1625/1637, 12 differ, 7
  errors.  Both after their version no-claims, so the remainders are unexplained.
- THE "SOLE HALSTAT CANDIDATE" RULE IS NOW ACTIVELY HARMFUL AND MUST GO.  In SSW it
  merely added nothing; in S2 it appears to be supplying WRONG addresses.  S2 has
  PROCEDURE and PROGRAM differences, which SSW and P9 had none of after the fixes, and
  they have the signature of a base that is slightly off rather than of bad code:
      $0SPSPSP +00C3  ours AFD0  dump AFD5   RLD #PCSPCLB (#PCSPCLB+62)
      #DSRESTO +001E  ours 9148  dump 9166   RLD #PCSASAT (#PCSASAT+686)
  #PCSPCLB resolved from HALSTAT phase 14 at 0xAF6E, and 0xAF6E+0x62 = 0xAFD0, which is
  what we emit; the dump implies a base of 0xAF73, five halfwords higher.  A wrong base
  by a small constant, not a relocation defect.
- Recall that #PCSPCLB was ALREADY flagged as ambiguous during SSW: 24 references, only
  2 of 23 agreeing, candidates in phase 8 at 0xA7EE and phase 14 at 0xAF6E.  It was
  rejected there for want of agreement and then accepted in S2 by the weaker rule,
  which asks only that one phase offer it.  That is the flaw: "the only candidate" is
  not evidence that the candidate is right.
- TWO FIXES TO MAKE, both deferred to the end of the run so the six configurations are
  built by identical tooling:
    1. Drop the "sole HALSTAT candidate, no contrary evidence" acceptance, or demote it
       to requiring dump corroboration like every other rule.  Then VERIFY: after
       linking, lnk101's appliedRelocations give the resolved value at each site, so
       every address that came from recovery can be checked against the dump, and any
       that disagrees withdrawn.  That check should exist regardless.
    2. compileLinkCompare should retry a failed link with lnk101 -f purely to write the
       symbol JSON, so a failed link still contributes relocation evidence to the next
       recovery pass while still being reported as a failure.  Confirmed to work: on
       GKRORB it immediately yields #PCGZ123 at 0x827C.
- Also worth noting for whoever picks this up: reading dass-compare.db while a sweep is
  running fails with "database is locked".  Use sqlite3's online backup --
  src.backup(dst) on a read-only connection with a timeout -- rather than copying the
  file, which can tear.  And do not `git add` the database while a sweep is writing it:
  git aborts with "confused by unstable object source data".

### [2026-08-06] Target: [compileLinkCompare.md]
- ALL EIGHT CONFIGURATIONS RUN.  14175 of 14300 in-index CSECTs match, 99.13%, with
  125 differing and 8 errors.  Per configuration:
      SSW  476/476    P9   509/509    G8  1625/1637   S2  1227/1249
      G9  1353/1369   G2  2545/2558   G3 2877/2903   G16 3563/3599
  Six of the eight have no errors at all; the 8 are G8's 7 and S2's 1, all the same
  undefined-#Z link-failure variant.
- Both deferred fixes are now in, and both are tested:
    1. The "sole HALSTAT candidate" acceptance is WITHDRAWN (--sole-candidates restores
       it for experiment).  It accepted 18 symbols in SSW and changed nothing, and in
       S2 it supplied #PCSPCLB at HALSTAT phase 14's 0xAF6E where the dump implies
       0xAF73, putting $0SPSPSP and other CODE sections out by five halfwords.  Costs
       correctness, buys nothing.  With it off, S2's recovery drops to only
       dump-corroborated and cross-configuration addresses.
    2. compileLinkCompare now re-links a FAILED link with lnk101 -f, purely so the
       symbol JSON gets written.  The failure is still reported and the exit is still
       nonzero; the image is discarded.  But the JSON's unresolvedRelocations name each
       unresolved symbol, its site and its addend, which is the evidence dass-syms.py
       needs -- and without it a file that will not link contributes nothing to the
       next recovery pass and can never be fixed.  Verified on GKRORB.
- Re-running all eight with both fixes.  The numbers above are therefore provisional:
  expect the 8 errors to fall and, more importantly, expect some of the 125 differences
  to turn out to have been caused by wrongly recovered addresses rather than by
  anything in the compiler or linker.

### [2026-08-06] Target: [compileLinkCompare.md]
- ALL FOUR PRs MERGED UPSTREAM, three of them with changes by the maintainer.  Read the
  comments before assuming our local versions are what landed:
    #27  "The patching part is superceded by 'patchStackPDEs' BUT this also catches a
         bug with multi-task PDE slots."  So the PDE fixup already existed upstream and
         what our PR actually contributed was the multi-slot binding -- slot k to stack
         '@' + STACK_SEQUENCE[k] + name.  That part was kept and reworked onto HEAD.
    #29  "Updated commit to work on HEAD and add fix to phaseresolve as well" -- the
         ZCON sign bug was present in a second place we never saw.
    #30  "Change updated to be compatible with file reorganization in my latest pushes."
    #28  merged as-is.
- Upstream had moved 38 commits ahead, including a substantial reorganisation, so the
  re-run then in flight was building against superseded tooling.  Stopped it rather
  than spend four more hours producing results nobody would trust.
- WHAT MOVED: src/LNK101/lnk101/* -> src/lnk101/*, fcmcmp -> src/tools/fcmcmp.py,
  rldanalyze -> src/tools/rldanalyze.py.  New modules phaseresolve.py and
  stacksizer.py.  New tools mmu2fcm and mmubuild compose a memory-configuration image
  from per-phase load modules, which is much closer to how the original build actually
  worked than our per-file compare-at-CSECT-addresses approach -- worth understanding
  before doing much more of this.
- WHAT SURVIVED, checked rather than assumed: lnk101 still takes --external-syms, and
  fcmcmp still takes --no-data and --exceptions, so the whole workflow is intact.
  Every tool it invokes is still on PATH, rldanalyze included.  Smoke-tested after
  rebuilding: APPLSRC/GI1GPS.hal matches all three sections, now through the
  maintainer's patchStackPDEs rather than ours, and SSSRC/DMTERR.hal gives 15.
- The ext/virtualagc submodule refuses to update because our working tree has changes.
  That is correct and should be left alone: letting it check out its pinned commit
  would discard them.  The build does not touch the virtualagc tree otherwise --
  verified, only dass-compare.db shows modified.
- Re-running all eight configurations against upstream master with both of our own
  deferred fixes in place (sole-candidate rule withdrawn, failed links re-linked with
  -f to harvest evidence).

### [2026-08-06] Target: [compileLinkCompare.md]
- WHAT THIS PHASE IS ACTUALLY FOR, from the user, and it corrects a misreading of mine.
  The comparison is A TEST OF HALSFC AND lnk101.  It is done one file at a time
  because we do not have all the object files -- the assembly modules among them --
  and because nobody, Don included, yet understands the ordering of CSECTs within the
  DASS files, which would have to be reproduced exactly to build a whole image.
- So the CSECT indexes, the HALSTAT address recoveries and the exceptions files are
  NOT scaffolding to be outgrown.  They are what makes the compiler and linker
  testable at all while the missing pieces are missing.  I had suggested Don's new
  mmu2fcm and mmubuild might make much of our approach unnecessary; that is premature.
  Those tools become relevant at the NEXT stage -- building FCMs with no reference to
  CSECT indexes, the DASS files or HALSTAT, by linking every object module in the
  right order -- and that stage is gated on this one finishing.
- THE CONSEQUENCE FOR HOW RESULTS ARE READ.  "How many CSECTs match" is the wrong
  headline.  The question each remaining difference has to be put to is: DOES THIS
  IMPLICATE HALSFC OR lnk101?  On that measure the phase has so far produced four real
  results, all of them in the linker, and all now merged upstream: the ZCON sign bit
  (which the maintainer found also affected phaseresolve, a path we never exercise),
  the multi-task PDE slot binding, and two reporting gaps in fcmcmp.  Everything else
  found -- post-build patches, revision differences, generated reconfiguration data,
  scrape gaps -- exonerates the tools rather than accusing them, which is a result too
  but a different kind.
- Triage the 125 remaining differences that way when the current run lands, rather than
  by count.  A difference traced to an I-LOAD or a revision gap is evidence the
  compiler is right; only an unexplained one is evidence it might not be.

### [2026-08-06] Target: [compileLinkCompare.md]
- CORRECTION, from the user, to the entry above.  Attributing a discrepancy is not the
  same as eliminating it, and the previous entry was starting to treat "explained" as
  if it were "done".  Success is still every error and every discrepancy gone.  The
  triage ordering is a strategy for reaching that faster, not a redefinition of it.
- SSW and P9 are the proof that the target is reachable and what it looks like: both
  finished at 0 differing sections and 0 errors, not at "0 unexplained".  Every
  category found its own means of elimination -- version gaps by -1 no-claim entries,
  post-build patches by verified exceptions, scrape gaps by recovered literals, missing
  addresses by HALSTAT recovery, and three real linker bugs by being fixed.  Nothing
  was left labelled-but-present.
- So the target for the remaining six is the same number: zero.  Read the attribution
  of a difference as telling you WHICH elimination applies to it, not as permission to
  leave it standing.

### [2026-08-06] Target: mafgenComparison.md
- G8's 7 "errors" are ONE mechanism, not seven.  Each of GKRORB, GMMLAT,
  GTBUPL, GWAORB, GWBORB, GX4DIS, GYZSTS contributes exactly ONE section to
  G8 -- its ZCON, `#Z<unit>` -- and every undefined symbol is referenced from
  `#C`/`#D` sections that live in other configurations' overlays and are
  excluded from scoring anyway.  The `-f` retry already writes a usable .fcm;
  the driver discards the file as an error and never compares it.
- All 7 ZCONs link at exactly the index address, 2 halfwords, 1 differing:
  HW0 matches (8000), HW1 is ours 0E20 vs dump 0E00.  Per addrcon.py, HW1 is
  XC(9) C(8) BSR(7-4) DSR(3-0), and "the BSR/DSR byte stays 0 until the
  linker patches it".  So ours = BSR 2, dump = BSR 0 (unpatched).  BSR 2 is
  the sector of 0x10000, the fallback address lnk101 gives `#C<unit>` when
  the section is not in the index -- an artifact of our link, not of the build.
- Decoding confirmed empirically: of G8's ZCONs whose `#C` IS in the index
  (154), BSR equals the code section's sector in every case.
- NOT yet explained: 53 G8 ZCONs have no `#C` in our index, but 21 of those
  carry a patched BSR (e.g. #ZDKFCM1 E9F0 0E30, #ZDCDDG9 83AA 0E60).  So
  "absent => unpatched" is not the whole rule; more likely our G8 index is
  incomplete for those units.  Settle this before choosing the fix.
- Separately, a real upstream bug: rldanalyze.py:394 `tracker.save(...)`
  dies with "TypeError: Object of type ZCon is not JSON serializable" on
  GKRORB, GWBORB, GYZSTS.  It runs after the symfile is written so it cost us
  nothing here, but it aborts the analysis and should go upstream.

### [2026-08-06] Target: mafgenComparison.md
- ANSWERED: the G8 index is NOT missing the 21 patched-BSR units.  Each such
  ZCON points at the overlay slot the unit occupies in ITS OWN configuration;
  G8's memory at that address holds whichever variant is resident in G8, so
  the target always lands inside a different, already-indexed CSECT.
- 18 of 21 reproduce exactly from another configuration's index, and the
  config is encoded in the unit name exactly as Ron observed:
  DCDDG1/DKFCM1->G16, G2->G2, G3->G3, G9->G9, DCDDS2/DKFCM4->S2,
  DCDDS8/DKFCM6->P9.  Independent confirmation of the S8 <-> P9 pairing.
- 2 of 21 are a real bounded gap: #ZDCDDS4 and #ZDKFCM5 have a `#C` section in
  NO configuration we hold.  They belong to S4, for which we have no DASS.
  Their ZCONs point at 24074 / 2403A -- exactly where their S2 siblings
  (#CDCDDS2 / #CDKFCM4) live, so S2 and S4 share an overlay slot.  The value
  is therefore inferable, but that is an inference, not evidence; needs an S4
  DASS to claim honestly.
- 1 of 21 explained: #ZRIOCGR points at 18030, the exact START of #CFIOCGR,
  identical across all 8 configurations, and there is no FIOCGR.hal -- not a
  HAL/S unit.  Two ZCONs (#ZFIOCGR, #ZRIOCGR) for one resident section.
- The other 32 code-absent ZCONs, INCLUDING all 7 G8 error files, decode to
  address 00000 (BSR=0, HW0=8000) and 00000 holds zeros.  Genuinely unpatched
  because the target is absent from G8.  So BSR=0 is CORRECT output for our
  seven, and our BSR=2 comes from lnk101 giving the unplaced `#C<unit>` a
  fallback address of 10000 under -f.  Fix belongs in the link, not the index:
  a relocation to a section absent from the configuration must be left
  unpatched rather than pointed at a fabricated address.

### [2026-08-06] Target: mafgenComparison.md
- BSR-only hypothesis is WRONG.  The relocation in each of the 7 G8 ZCONs is
  flag 0x10 = RLD_ZCON_ADDR, target #C<unit> (or an internal label, e.g.
  GWBORB's $Y022001), resolved to lnk101's fallback 10000.  Per ZCon.apply(),
  0x10 writes HW0 *and* sets BSR when sector>0 and CB.
- So HW0 is written by our link too.  It matched only by luck: 10000 is
  sector-aligned, so HW0 = 8000|(10000 & 7FFF) = 8000, which happens to equal
  the unpatched value.  A non-sector-aligned fallback would differ in BOTH
  halfwords.  The defect is bigger than the 1-halfword symptom suggests.
- Confirmed 8000 0E00 is the as-assembled ZCON: ALL 32 of G8's code-absent
  BSR=0 ZCONs are byte-identical 8000 0E00.  The real build never patched
  them, because the target is absent from the configuration.
- Fix direction unchanged: a relocation whose target section is absent from
  the configuration must be left entirely unpatched.  Pull nsts-sdl-dps
  immediately before making the change.

### [2026-08-06] Target: mafgenComparison.md
- dass-literals.py had a THIRD DASS line shape wrong: a named variable
  spanning several halfwords, only some starred --
    004F64-004F65  #PCGGCOM+0116  CGGV_V_MAG_MECO   4464 *DB00       SP SCALAR
    005B2C-005B2F  #PCGNCOM+0104  CGGS_NAVBASE_LAT  407F *D2DB *03C7 *34DD
  It put the first STARRED value at the leading address; the values are
  positional there too (*DB00 belongs to 004F65).  Fix: halfwords are
  positional in EVERY row shape, bounded by the address range.
- Also handled a name wide enough to collide with the value column, gluing
  them (CGGS_FD_THRUST_ANG_COEF_SWITCH_V*4411).  The split is accepted only
  where it supplies the count the address range demands, so it self-validates.
- Self-check over all 8 configurations: 27788 agree, 0 DISAGREE (was 203
  disagreeing across G8/G9/G2/G3).  Recovery also went UP a lot, so the old
  parser was LOSING starred locations, not merely misplacing them:
  SSW 1193->1199, P9 1122->1128, G8 2549->2827, S2 1256->1262,
  G9 2363->2568, G2 2794->3093, G3 6003->7757, G16 ->7954.
- Projected effect on known differences, every match EXACT, never partial:
    G8 12 -> 7 differing (#PCGCCOM 6, #PCGNCOM 7, #PCGNFLT 16, #PCGZCOM 4,
                          #DGPBGPS 2 all fully accounted for)
    G9 16 -> 12 (#PCGCCOM 6, #PCGNCOM 7, #PCGZCOM 4, #DGPBGPS 2)
    G2 13 -> 4  (9 of 13 sections fully accounted for)
    S2 22 -> 22 (unaffected; S2's self-check was already clean, so its 22 are
                 a different mechanism -- the SPSPSP/SAFACQ family)
- Every configuration therefore needs re-running with the corrected exceptions.
  fcmcmp's checked-value design contained the damage: entries whose asserted
  value did not match were warned about and ignored, never applied, so the
  wrong entries suppressed nothing.  The cost was missing suppressions, not
  false ones.
- SEPARATE: dass-run.py's checkToolchainBranch() was stale -- it demanded
  branch 'integration', but upstream merged all four PRs so 'master' is now
  correct.  It fired on all 21 sweeps of this run; 21 spurious warnings is how
  a check stops being read.  Replaced the branch test with a capability test
  (--no-data, --exceptions, --external-syms, patchStackPDEs, ZCon.apply flags).
  Verified all five present on master, so THIS RUN'S RESULTS ARE VALID.

### [2026-08-06] Target: mafgenComparison.md
- S2's SPSPSP family is a VERSION difference, not a compiler or linker defect.
  SPSPSP itself is at the build's own revision (BP = BP).  What moved is the
  COMPOOLs it references, which were revised between OI-34.06 and OI-34.07 and
  grew, so every reference past an insertion point resolves a few halfwords low.
- Proof for CSPCLB, the largest contributor:
    HALSTAT RVL BO, our source BN -- revised.
    fcmcmp: "#PCSPCLB @ 0AF6E (134 halfwords vs 140 expected)" -- ours is 6 short.
    HALSTAT's 37 offset/address rows all imply base AF6E, agreeing with our
    link and the index, so the BASE is right and the OFFSETS differ.
    The dump's targets AFD5/AFF4/AFF6 ARE real HALSTAT variables, at offsets
    67/86/88.  OUR targets AFD0/AFEE/AFF0 appear in HALSTAT NOWHERE.  We place
    the same variables at 62/80/82.  max(offset+size) = 8C = 140 = index size.
- All 40 SPSPSP-family differences classify: 23 -> #PCSPCLB (BN->BO),
  7 -> #PCPGSPL (AA->AD), 3 -> #PCSAPDT (CC->CD), 2 -> #PFCMCOM (CK->CQ),
  5 -> FIOCDATS/FIOMODSM (FCOS, no HAL/S source, so no RVL to read).
- Across ALL of S2's differing sections, 251 differences point into a unit
  revised since our source and 23 into CSECTs with no HAL/S source.  ZERO
  point into a same-revision unit.  That zero is the control that makes the
  attribution credible -- it is the same control dass-versions.py already
  relies on ("not one same-revision file gives any trouble").
- NOT FIXABLE without OI-34.07 source for CSPCLB/CPGSPL/CSAPDT/FCMCOM.  A real
  hard blocker, the same class as the missing S4 DASS -- not "expensive".
- PROPOSED, needs a decision: dass-versions.py currently emits -1 no-claim
  entries only for a revised unit's OWN sections.  The observable difference
  is in every unit that REFERENCES it, and those are unrevised, so nothing
  flags them.  Extending no-claim to reference sites would close S2, but it
  WIDENS a suppression mechanism, so the guard matters: emit only where the
  differing halfword's DUMP value lands in a CSECT whose HALSTAT RVL exceeds
  our source's, never blanket-by-file.
- SEPARATE fcmcmp weakness: 44 S2 sections have a size mismatch against the
  index and 42 of them report OK, because only the overlap is compared.
  "#PCSPCLB (134 halfwords vs 140 expected)" passed.  A section short by 6
  halfwords should not be a PASS.  Worth raising upstream.

### [2026-08-06] Target: mafgenComparison.md
- dass-versions.py now also records reference-site no-claims: a halfword in an
  UNREVISED unit whose difference is explained by a unit it REFERENCES having
  been revised.  Guards, deliberately narrow:
    * both our value and the dump's must resolve into the SAME CSECT -- the
      layout-shift signature, far narrower than "looks like an address into a
      revised unit", which coincidence could satisfy;
    * containment only, no nearest-preceding fallback (that fallback had
      attributed differences to a CSECT 4000 halfwords away, inventing deltas
      of 18396 and 55948);
    * CSECT extents widened by HALSTAT's own offset table where it reaches past
      MAFGEN's index, so the reach is primary evidence, not a proximity guess.
- Effect on S2: 190 halfwords attributed, CSDMD1 and SPRPRB fully clean,
  SPSPSP 7 -> 4 sections, ~22 -> ~16 differing sections overall.
  G9: 35 halfwords, incl. SPSPSP->GMAMIN BK->BO and VG9OPS9->CSPCLB.
- What remains in S2 is the honest floor on present evidence: every survivor
  targets either an FCOS CSECT (FIOCDATS, FIOMODSM, FIOCBLKS, FCMPSA -- NOT in
  HALSTAT at all, since HALSTAT covers only HAL/S compilations, so no RVL
  exists to read) or an address no indexed CSECT claims and S2's DASS does not
  disassemble.  Checked #PCPGSPL specifically: HALSTAT gives it extent 338,
  identical to the index, so it really does end at 0DCE5 and the EC** targets
  are outside it.  The strict rule correctly refused these.
- Corroboration for the FCOS group, short of proof: their deltas rise
  monotonically with address exactly as the HAL/S cases do --
  FIOCDATS +6,+12,+12,+20,+28 over rising addresses; FIOCBLKS +30 twice;
  FIOMODSM +28; FCMPSA +6.  That is the insertion signature, but with no
  revision level to check it stays circumstantial.
- HALSTAT provenance, checked rather than assumed: its CSECT bases match a
  configuration index in 1221 cases against 213 not, so HALSTAT describes the
  DUMPED build.  Its newest dataset qualifier is OI340600 and no OI340700
  exists anywhere in it.  Since the qualifier records where a unit's source
  LAST CHANGED, that complicates the tidy "34.06 vs 34.07" story rather than
  confirming it -- but it leaves the per-unit revision attribution untouched,
  which stands on its own control: same-revision units never differ.

### [2026-08-06] Target: mafgenComparison.md
- MY ERROR, recorded so it is not repeated: nsts-sdl-dps installs lnk101 and
  fcmcmp into build/venv as EDITABLE packages (_editable_impl_ap101.pth,
  sdl.pth), so both run straight from the working tree.  Switching branches
  changes the toolchain instantly.  I switched branches three times while the
  G16 sweep was running, so part of G16 linked with master and part with the
  fix.  Rule: never switch branches in that repo while a sweep is running;
  build an integration branch first and leave it alone.  Costs little here
  only because every configuration needs re-running anyway.
- lnk101 fix written and verified, on branch lnk101-absent-section-relocs
  (commit 8579162, NOT pushed, no PR -- awaiting review):
  a relocation whose target section is absent from the CSECT table is now
  treated exactly as unresolved, taking the existing issue-#22 path.  Gated on
  a table being loaded, and on truthiness rather than "is not None", since
  csectTable defaults to {} and testing for None would have found every
  section absent on links passing no table.
    * all 7 G8 files now produce 8000 0E00, matching the dump exactly;
    * every in-index section across the 7 compares clean -- 0 in-index
      failures, where before the link failed and nothing was compared at all;
    * 12 modules from P9 (already 509/509) still match, so no regression.
- fcmcmp size-mismatch reporting on branch fcmcmp-size-mismatch (commit
  1d6ce6d, NOT pushed): mismatches always listed; --strict-sizes makes them
  fail; default exit status unchanged (verified 0 default, 1 strict).
- NEXT: let G16 finish, build a local integration branch (master + both
  fixes), then re-run all 8 configurations.  The branch-name check is gone, so
  integration no longer has a special status -- the capability test will pass
  on any branch carrying the features.

### [2026-08-06] Target: mafgenComparison.md
- #DAIESIP n=2 appeared in EVERY configuration; it is one symbol, #PCSZICC.
  AIESIP holds two addresses into that COMPOOL; the dump has A7C4 and A7EC,
  we had the bare offsets 0048 and 0070, both short by exactly A77C.
- #PCSZICC IS in HALSTAT (OFFSET 000000, PHASE 14 ADDR 00A77C) and S2's index
  starts it at A77C, so two independent sources give the same address.
  dass-syms rejected it anyway: of 5 references, the 2 in #DAIESIP agree on
  A77C while 3 in #CGFBRCS derive 09DAF, 0F4DB and 0ECAC -- mutually
  disagreeing, the signature of a reference whose own section is not at its
  true address, so it reads unrelated memory.  2/5 = 0.40 lost the 0.60
  majority test, and the true address was outvoted by noise.
- New rule: accept a value that HALSTAT corroborates, that at least two
  references agree on, and that is the ONLY corroborated value; ambiguity
  still refuses.  This is NOT the withdrawn sole-candidate rule -- that took
  HALSTAT with no dump evidence at all, whereas here dump and HALSTAT must
  independently agree.  Measured on G16/G8/G2/G3 it accepts exactly one more
  symbol each, #PCSZICC, and nothing else.
- Verified: with #PCSZICC at A77C, AIESIP goes to "PASS: all 17 sections
  match" in G16.  Fixes a difference present in all 8 configurations.
- Also fixed a misleading rejection message: a symbol failing only the ratio
  test was reported as "matches no candidate", which is what sent me looking
  in the wrong place first.
- G3 projection from the literals fix alone: 19 of 23 differing sections
  fully explained, every match exact (incl. #PCGN13R n=882, #PCGZMC3 n=191,
  #PCGCFL1 n=173).  G3 23 -> 4.
- Restarted the full 8-configuration run from scratch at this point, because
  dass-syms.py changed 11 minutes into the previous attempt and a half-old
  sweep is worth nothing.  Toolchain pinned to branch `integration`
  (master + fcmcmp-size-mismatch + lnk101-absent-section-relocs) and NOT to be
  touched while it runs.

### [2026-08-07] Target: mafgenComparison.md
- Full 8-configuration run on the fixed tooling (literals parser, reference-site
  no-claims, #PCSZICC recovery, lnk101 absent-section relocations):
      before                          after
      SSW   476/476   0 differ 0 err  476/476   0 differ 0 err
      P9    509/509   0        0      509/509   0        0
      G2   2545/2558 13        0     2558/2558  0        0   <== now perfect
      G3   2882/2905 23        0     2903/2905  2        0
      G16  3596/3599  3        0     3597/3599  2        0
      G8   1625/1637 12        7     1635/1637  2        7
      G9   1353/1369 16        0     1363/1369  6        0
      S2   1227/1249 22        1     1233/1249 16        1
    TOTAL 14213/14292 79 differ 8 err -> 14274/14292 28 differ 8 err.
    Three configurations now at zero: SSW, P9, G2.
- G8's 7 errors survived because the lnk101 fix corrects relocation VALUES but
  does not make a link with undefined symbols succeed.  Fixed separately:
  compileLinkCompare now COMPARES the forced (-f) image instead of discarding
  it.  Legitimate only because lnk101 now leaves an absent-section relocation
  unpatched, so the forced image holds what the build held, not a fabrication.
  Preceded by a FORCED LINK banner; dass-run no longer short-circuits on
  "Linking failed" when that banner is present.  Verified on GKRORB and
  GYZSTS: both now score (G8 errors 7 -> 5 with just those two re-run).
- run-configs.sh now takes configurations as arguments, defaulting to all
  eight.  Only G8 and S2 have link failures, so only they need re-running --
  an hour instead of three and a half.
- REMAINING after that re-run is expected to be ~28 differences, all small:
    G3  #DGO3ENT 1, #DGZ1ALT 1        G16 #DGFKGRT 1, #DGO1ASC 1
    G8  #PCGA2MC 1, #DGO8ORB 1
    G9  #PCSDMD1 24, SPSPSP family 8, $0VG9OPS 1
    S2  #PCSSSPA 76, SAFACQ 13, SPSPSP 16, SRESTO 5, STMTAB 5, others
  Note the recurring single-halfword #D differences across G3/G16/G8 --
  #DGO3ENT, #DGZ1ALT, #DGFKGRT, #DGO1ASC, #DGO8ORB -- all n=1, all in a #D
  section of an ORB/ASC/ENT-family unit.  Likely one mechanism; not yet looked
  at.  #PCSDMD1 cleared in S2 via the reference-site rule but not in G9, worth
  checking why (probably CSAPDT absent from G9's index).

### [2026-08-07] Target: mafgenComparison.md
- G8/S2 re-run with the forced-image comparison: ALL ERRORS GONE.
    G8 1737/1739  2 differ 0 err   (was 1635/1637, 2, 7)
    S2 1236/1252 16 differ 0 err   (was 1233/1249, 16, 1)
  Section totals ROSE (G8 1637->1739, S2 1249->1252) because the eight files
  that previously produced nothing now contribute their sections.
  OVERALL: 14379/14407 match, 28 differ, 0 errors.  Was 79 differ, 8 errors.
- A GENUINE DEFECT, not a version artifact, and the best finding so far:
  three units in three configurations hold the same 32-bit constant and we get
  it wrong the same way every time --
      GO8ORB (G8)  @07F5B    GO1ASC (G16) @0B82F    GO3ENT (G3) @0B0D3
      ours A0B5 ED8E        dump A0B5 ED8C
  The sites are at DIFFERENT offsets in their units (C3, F3, 10B), so it is a
  constant, not a shared address.  Every neighbouring halfword matches exactly,
  including recognisable literals (3FA3D70A is 1.28 in IEEE-754 single), so it
  is specific to this one value.  Units and target COMPOOLs are all at the
  build's own revision, #PCGCUN1 compares clean at its correct size, and there
  is no RLD -- a compile-time constant our compiler converts differently.
  NOT DECODED: whether the low byte is mantissa or exponent decides whether
  this is a 2-ULP rounding difference or a factor-of-four error.  Do not guess;
  get the AP-101S float format, or recompile GO8ORB and read the listing to
  find the source literal.  The three sources share only four decimal literals
  (0.040, 19.06, 19.07, 21.01) and the last three look like version numbers in
  comments, so 0.040 is a candidate but is NOT confirmed.
- The foreign-symbol withdrawal fixes two more, both verified by hand:
    G3  #DGZ1ALT  456A vs 0000  -- #EGZRBRG absent from G3; now all 7 match
    G8  #PCGA2MC  E3C5 vs 0019  -- #PCGNMC2 absent from G8's index, dass-syms
        had placed it at 0E3AC, and 0E3AC+19 = E3C5 exactly.  The dump's 0019
        is the raw addend: the real build left it unresolved.  Now 1/1 match.
  Still needs the full run to confirm it costs nothing in SSW/P9/G2.
- G9 #PCSDMD1 (24 hw) NOT SOLVED: all 24 are unresolved relocations to
  #PCSAPDT, which is in neither G9's index nor HALSTAT.  Dump values land in
  #DVKISAC/#EDGRGSE and ours in @0ARBIDL -- incoherent as offsets into one
  CSECT -- and dump-existing is not constant (13/6/3/2), so `existing` is not
  a reliable addend and there is no honest base to recover.

### [2026-08-07] Target: mafgenComparison.md
- IDENTIFIED the A0B5ED8E/A0B5ED8C constant.  Recompiled GO8ORB into an
  isolated symlink tree (~/ForClaude/listing-tree) so as not to disturb the
  running sweep; the literal table names it outright:
      Literal 178: FIXED  3C10C6F7,A0B5ED8E ' 1.000000000000000E-06'
  It is a DOUBLE-precision .000001, declared in a SHARED INCLUDE --
  INCL80/GKPMNV.hal:365, ".000001 SCALAR$(@DOUBLE)(CZ2V_MET_MSEC_MFE);" --
  which is exactly why the identical value appears in three unrelated units.
- Decoded as IBM hex double (exponent 3C, 56-bit fraction), against the exact
  value of 1e-6, whose true mantissa is 4722366482869645.2137:
      ours  0x10C6F7A0B5ED8E = ...646   error +0.786 ULP
      dump  0x10C6F7A0B5ED8C = ...644   error -1.214 ULP
      correctly rounded would be ...645, which is NEITHER of them.
- So this is NOT our compiler being wrong: OUR VALUE IS CLOSER TO 1e-6 THAN
  THE ORIGINAL BUILD'S.  Neither conversion is correctly rounded; the original
  is 2 ULP below ours, consistent with truncation where we round.  Checked the
  other double literals in the table -- their low words vary in parity, so the
  granularity really is the full 56 bits and ...645 was available.
- DECISION NEEDED, not a bug to fix: reproducing the dump bit-for-bit requires
  replicating the original HAL/S-FC's less accurate decimal-to-hex-float
  conversion.  That is a deliberate fidelity choice, and it is the user's to
  make -- it trades numerical accuracy for reproduction.  Three sections
  (#DGO8ORB, #DGO1ASC, #DGO3ENT) hang on it, one halfword each.
