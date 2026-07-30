# CLAUDE_LOG.md

(Cleared 2026-07-29 by Full Documentation Sync — pending entries applied to problems.md §6.6.)

### [2026-07-29] Target: debugger-planner.md
- `--debug` mode Stages 0-3 all implemented and committed (commit ca1e9784a + Stage 3 follow-up): src/run.c loop unification, src/debugger.{h,c} (step/next/run/break/bl/bd/be/reg/disasm/mem/xw/deposit/sym/sections/where/steps/backtrace/trace/info/help/quit + Stage 2 mw/mwc/mwl/watch/unwatch/wl/set), new --debug/--source-map CLI flags.
- Stage 3 pivoted away from the SDF binary format this doc originally targeted: direct testing (compiled HELLO.hal without NOTABLES, loaded the real SDF via modules/sdf+modules/sdfpkg) found the per-statement SRN field comes back all-blank from this toolchain's HAL/S compiler port -- a dead end, not a parsing gap. Used pass1.rpt (source text per SRN) + pass2.rpt ("ST#N EQU *" markers give CSECT-relative code addresses per SRN) instead, via new tools/gen_source_map.py, which also had to be taught that a statement's "ST#N" marker can land in a non-code CSECT (zero-code DECLAREs interleaved with data literals) and must be bound to the code CSECT's next resumption point, not discarded -- verified against a real compile (test/fixtures/hello.srcmap.json), address ranges bounds-checked (codeStart/codeEnd) so addresses outside the mapped module never spuriously match.
- New test/test_debugger.sh covers all three stages via golden-transcript diffs (hello/watch/srcmap cases) against test/fixtures/hello.fcm.
- debugger-planner.md's Stage 3 section should be updated to describe the pass1.rpt/pass2.rpt approach actually used, in place of the SDF-based one originally proposed there.
