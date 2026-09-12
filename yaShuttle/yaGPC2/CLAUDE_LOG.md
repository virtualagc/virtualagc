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

### [2026-09-11] Target: HANDOFF-OI340700-BUILD.md
- The volume is now v44 (tapebuild/build.sh, ~/workspace/pass-run/OI340700-v44boot.mmv): v43 plus ASM101S 6d418f3c6, which changes only BILDNEW5.obj's RLDs and ten phase-10 halfwords. GPCIPL's ">>> GPC POWER REFAIL -PROGRAM/MACHINE WERE R" was message 132 with message 130's text, not a refail -- see gpc-causes #84 and HANDOFF-OPS9.md "Closed since the last sync".

### [2026-09-12] Target: [yaShuttle/yaGPC2/README.md]
- The headless-gpcmem.sh reference figures quoted in the multi-GPC plan ("744
  commands, 256 fills, 241 timeFills, 248 displayFills, 247 polls") are STALE:
  they predate the MTU/clock and MEDS work. Measured 2026-09-12 on a 420 s run,
  the run now reaches `deu: 1848 commands, 375 fills, 569 timeFills, 367
  displayFills, 8 formatFills, 328 medsXfers, 575 polls, 114476 wordsIn, 9110
  wordsOut` and `mtu: 7890 commands, 5421 timeReads, 26139 wordsOut`, with the
  DEUKEYS batch landing at `poll=247 simt=135.520 s wall=120.0 s`. Only `polls`
  at the keystroke (247) survives from the old set. Reproduced byte for byte
  across three runs on two different builds, so it is a usable regression gate.
- `--gpcs <list>` runs several computers, one thread each. `YAGPC_BARRIER_US`
  sets how far apart in SIMULATED microseconds they may drift (default 200,
  0 disables); vehicle_free reports holds, seconds held and abandoned holds.
