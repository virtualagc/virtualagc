# CLAUDE_LOG.md

Staging area for documentation updates.  Append timestamped entries as

    ### [YYYY-MM-DD] Target: [Filename.md]
    - note

and they are applied to their targets on the next "Full Documentation Sync".

For CAUSES INVESTIGATED and FIXES ATTEMPTED use `gpc-causes.py` instead --
that is a database with an `addr`/`search` front end, not prose, precisely
because this file records everything and recovers nothing.

### [2026-09-10] Target: HANDOFF-OI340700-BUILD.md
- The recipe's `compilePASS --no-csects` does NOT reproduce the objects the tape was built from. A tape build needs `compilePASS --no-csects --sdl --release=OI340700`: without `--sdl`, 160 PROGRAM objects gain a START csect, stack prologue and stack ERs; without `--release`, CPUSLS/CPTOSV get CARDTYPE ACBD instead of ACBC, fail XI3, and 8 phase-15 objects cascade away. With both, 1,981 of 1,981 objects match in loaded content. Also: `dfg` must be the pinned one (yaGPC2/tapebuild, stage 0b), and compilePASS's dfg `--release` probe was broken by rich's ANSI styling until 2026-09-10. See HANDOFF-OPS9.md sections 0-3.
