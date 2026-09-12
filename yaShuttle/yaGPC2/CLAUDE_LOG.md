# CLAUDE_LOG.md

Staging area for documentation updates.  Append timestamped entries as

    ### [YYYY-MM-DD] Target: [Filename.md]
    - note

and they are applied to their targets on the next "Full Documentation Sync".

For CAUSES INVESTIGATED and FIXES ATTEMPTED use `gpc-causes.py` instead --
that is a database with an `addr`/`search` front end, not prose, precisely
because this file records everything and recovers nothing.

### [2026-09-12] Target: [yaShuttle/yaGPC2/README.md]
- CORRECTS the figures logged earlier today, which described a run that IPLed
  TWICE (gpc-causes #93, fixed). The regression gate is now: ONE `MODE: IPL`
  line; the scripted keystrokes land at `poll=247 simt=133.704 s wall=120.0 s`;
  `mmu1: 56 commands, 431 blocksRead, 220731 wordsOut, 220011 wordsTaken, 720
  wordsLost`; `deu: ~1848 commands, 375 fills, 569 timeFills, 367 displayFills,
  575 polls`; `mtu: ~7890 commands, 5421 timeReads`. The simt figure and the
  mmu1 counters are exactly reproducible across runs; the deu and mtu counters
  vary by one transaction depending on where the harness's kill lands, so treat
  those as +/-1 rather than exact. (The earlier note claimed the deu counters
  were byte-identical across three runs -- true of those three, but not a
  property to rely on.)
- The old figures differed by exactly one bootstrap: 503 blocksRead instead of
  431, and simt 135.520 instead of 133.704, the 1.8 s the spurious IPL cost.
