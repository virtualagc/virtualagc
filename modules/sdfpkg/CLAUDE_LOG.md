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
