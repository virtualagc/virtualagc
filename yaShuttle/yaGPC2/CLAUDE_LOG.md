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

### [2026-09-13] Target: [yaShuttle/yaGPC2/README.md]
- MULTI-GPC STATE. `--gpcs 1,2` now: both computers IPL and load PASS
  identically (both mass memories 56 commands / 432 blocks); they exchange
  sync codes bidirectionally at the correct rotated positions; the common set
  FORMS -- `TCVTCSSM` 0x888 on GPC1 and 0x111 on GPC2, each naming the other;
  `FCMCSYNC` admits the member; and `FCMSFAIL` votes it out 4.33 ms later
  against a 3.85 ms timeout. GPC1 transitions to OPS 2 (mmu1 71/749); GPC2
  does not (mmu2 59/432). The open question is which branch of `FCMISYNC`'s
  mask selection the four failing passes per machine take -- gpc-causes #117.
- Diagnostics added this round, all env-gated and off by default:
  `YAGPC_SYNCTRACE` (3-bit codes per neighbour, with the driven mask),
  `YAGPC_BUSCENSUS` (transactions per computer per bus),
  `YAGPC_RANGETRACE_GPC` (restrict the range trace to one computer),
  `YAGPC_ICCTRACE` (intercomputer-bus command words). The range trace's line
  budget is a FILE STATIC shared by every machine and its `afterSec` gate is
  in each machine's OWN simulated time -- both silently return nothing for a
  later-starting computer.
- METHOD WARNINGS worth keeping, each cost a round: a trace count is
  meaningless if the budget truncated it; an entry count is not a barrier
  count; and a suspicious register value should be checked against TFCVT's
  constant table before it is treated as evidence (0x088 is TCVTSVCI, not a
  mask). See gpc-causes #110, #117, #118.
