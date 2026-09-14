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
