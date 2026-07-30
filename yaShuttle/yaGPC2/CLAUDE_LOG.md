# CLAUDE_LOG.md

(Cleared 2026-07-30 by Full Documentation Sync — pending entry applied to problems.md §6.7.)

### [2026-07-30] Target: debugger-planner.md
- User corrected the debugger-planner.md Stage 3 SDF finding (per commit 4467cfa54): the SDF's own SRN field (source columns 73-78) really is a separate, less-reliable concept from the "HAL/S statement number" (1-based position in statementIndexTable, restarting at 1 per SDF) — SRN came back blank only because the test source (HELLO.hal) never had column 73-78 data, not because of a toolchain gap. pass1.rpt's leftmost column already *is* the correct HAL/S statement number, so tools/gen_source_map.py's approach was right all along, just mislabeled "srn" throughout (tools/gen_source_map.py, src/sourcemap.h/.c, src/debugger.c, test/fixtures/hello.srcmap.json) — renamed to "stmt"/HAL/S-statement-number, no logic changes, all tests still pass.
- Also fixed: debugger commands now accept a gdb-style no-space repeat count (`step5` same as `step 5`) via a new split_digit_suffix() in src/debugger.c, with "x32" (an existing alias, not "x"+32) excluded.
- debugger-planner.md's Stage 3 section (the "SDF looked right, but wasn't" update) should be corrected to reflect this: SRN wasn't populated because of the test source, not a compiler-port gap, and SRN was never the right field to key off regardless — the correct/universal identifier is the HAL/S statement number (statementIndexTable position), which is what pass1.rpt's leftmost column already gives directly.
