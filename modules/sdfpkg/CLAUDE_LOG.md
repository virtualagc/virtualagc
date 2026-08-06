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
