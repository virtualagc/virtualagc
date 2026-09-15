# CLAUDE_LOG.md

Staging area for documentation updates.  Append timestamped entries as

    ### [YYYY-MM-DD] Target: [Filename.md]
    - note

and they are applied to their targets on the next "Full Documentation Sync".

For CAUSES INVESTIGATED and FIXES ATTEMPTED use `gpc-causes.py` instead --
that is a database with an `addr`/`search` front end, not prose, precisely
because this file records everything and recovers nothing.

### [2026-09-14] Target: README.md
- New yaGPC2 options for measuring multi-GPC CPU use (each default is the old behaviour): --rt-min-sleep-ms (default 2; rtpacer_pace sleeps off a lead only past this), --rt-idle-poll-ms (default 1; the wait-state loop's sleep, was RTPACE_IDLE_POLL_SECONDS), --barrier-us and --barrier-spin-us (override YAGPC_BARRIER_US / YAGPC_BARRIER_SPIN_US, else 200 each). A "pacing:" line on stderr states the values for multi-GPC or --real-time runs. Context: a 4-GPC 2-CRT simulatePASS run used ~324% CPU, ~80% per GPC thread and ~6% the bcenet transmit thread; candidates are barrier spinning (at 25 us each 1 ms idle tick holds the first-ticking machine, which spins up to 200 us), the 1 ms idle tick, and execution itself. Not yet measured. Host note: GNU ar 2.42 segfaults in /usr/lib/bfd-plugins/LLVMgold-14.so (even on one object), so `make` fails at libyaGPC2.a; `make AR=llvm-ar` works.

### [2026-09-14] Target: README.md
- MEASURED where 4-GPC CPU goes (simulatePASS --gpcs 1-4 --crts 2, unattended to OPS 2 at 840 s, per-thread /proc CPU over 960-1200 s). yaGPC2 ~350% in every setting: defaults 356%, --barrier-spin-us 20 348%, --barrier-spin-us 0 352%, --rt-idle-poll-ms 4 349%, --rt-min-sleep-ms 10 348%, defaults without YAGPC_PACETRACE 351%. Each GPC thread ~85% (65% user, 20% system), bcenet transmit thread ~10% (mostly system). So the pacing/barrier knobs do NOT reduce CPU: in OPS 2 no GPC ever enters a wait state (wait-loop time unchanged across the window), only the machine furthest ahead sleeps in the pacer (~34 s per 240 s), and barrier holds nearly all end while spinning whatever the spin budget. Per GPC thread: ~0.75 M instructions/s (1.32 us simulated each); ap101_exec1 ~36% of a core; bus service ~25% (bcenet_framer_flush_tick every BUS_SERVICE_US_DEFAULT = 2 us simulated, ~205k calls/s, each a poll() over ~28 bus sockets, measured 315-433 ns on this host for 24-32 idle sockets); mode_switch_held() calls discretes_poll_one() -- an unconditional recv() plus a clock read in attend() -- before EVERY instruction, ~9% (empty non-blocking recv measured 115 ns); the rest ~15% barrier and step overhead. Candidate savings are code, not knobs: gate the per-instruction discrete recv (discretes_poll() already gates 1 in 32 plus a time gate, but pulses must still be seen one datagram at a time), and service the buses less often (a BCE samples its MIA at most every 16.5 us). perf is unavailable (kernel.perf_event_paranoid=4).

### [2026-09-14] Target: README.md
- A running GPC no longer halts when the crew panel merely goes quiet. If its mode bits go stale (more than 1.5 s) while it was last heard in RUN or STBY, it keeps that position and logs 'MODE: crew panel silent N s; keeping RUN'; after YAGPC_DISCRETES_HOLD_SEC seconds of silence (default 60) it is held ('holding the CPU until it is heard') and released when the panel is heard again. A GPC that never heard a panel still starts held. YAGPC_HELDTRACE=1 logs every change of a machine's held state with register A's value, driven mask and the age of each mode bit. Cause: a saturated X server stalled panelO6's publishing and halted every running GPC at once (ledger #147).

### [2026-09-15] Target: problems.md
- --mtu-model on buses 20-22 now echoes EVERY bus command (command-sync) to listening computers, not only its own read (0x24C26); data is still returned only for the read. Listen-Mode receives wait indefinitely for a command at their IUA, so NSP listeners had stalled and drawn MSC time-outs in 4-GPC sets (ledger #145, commit 273563b7f). Single-GPC behaviour unchanged (gate echo-regress ALL MATCH).
- Host note: if /usr/bin/ar segfaults, build the library with `make AR=llvm-ar`.

### [2026-09-15] Target: problems.md
- CORRECTION to the llvm-ar note above: /usr/bin/ar was not broken. GNU ar dlopens every /usr/lib/bfd-plugins plugin (LLVMgold-14 -> libLLVM-14.so.1) and the PAGE-CACHE copy of libLLVM-14.so.1 was corrupt in RAM (md5 b56ec9da..., disk/direct read and package c7037a8d...), so ar segfaulted inside libLLVM-14 (also Sep 14 16:18). Fix: `dd if=/usr/lib/x86_64-linux-gnu/libLLVM-14.so.1 iflag=nocache count=0` (no root) evicts the pages; plain ar then works. Not LTO-related. Repeat corruption suggests running memtest86+.

### [2026-09-15] Target: problems.md
- yaGPC2 now drives GPC discrete output bit 31 (IPL talkback, hardware) from a successful firmware IPL until the HALT -> STBY release (run.c ipl_talkback), published against the last announced OUT value so a re-IPL also clears a stale RUN(READY) bit 9. panelO6 shows it as IPL on the O6 MODE talkback.
