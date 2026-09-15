# HANDOFF: measuring how close a redundant set is to losing sync

Written 2026-09-14 18:50 CDT.  Owner's instruction: **do NOT start any runs
until the owner signs off for the evening** -- the runs would interfere with
what they are doing on this machine.  After sign-off, run as much as is useful
overnight.  Report in the morning.

## Why

"A GPC was voted out" / "no GPC was voted out" is binary and needs a failure
to say anything.  The owner wants a graded measure of **marginal sync
stability**: 0 = solidly in sync, 1 = at the edge (any disturbance tips it
over), with meaningful values in between -- so that "more stable, sync-wise"
becomes a goal that changes can be compared against.  (Reducing CPU was
measured and judged not worth changing; see "Background" below.)

## The two ways a GPC leaves a redundant set, and the margin for each

### 1. Timing: a sync wait runs out (the main metric)

Flight source (OI301700 tree; **verify the OI340700 sources match** before
relying on line numbers -- our tape is OI340700-v44boot):

- `~/workspace/PFS/OI301700/SSSRC/FCMCBLKS.asm:818`
  `FCMSNTO2 DC F'3850'  3.85 MILLISEC IN MICROSECONDS`
- `FCMCBLKS.asm:683` `FCMNOISE DC F'10'  DISCRETE SIGNAL RISE/NOISE CONSTANT`
- `FCMCSYNC.asm` ~lines 293-316, the common-set (SSIP) sync loop:
  - `ICR R1,R7` read PC1 timer; `S R1,FCMSNTO2` -> loop end time
  - loop: `PC R2,R6` read DIA; `ICR R3,R7; S R3,FCMNOISE` settle delay;
    compare first/second sync discretes
  - `ICR R4,R7; SR R4,R1` **TIME LEFT TILL LOOP TIMEOUT**;
    `N R4,FCMBIT16; BZ FCMDIAR2` -> if not timed out, second DIA read;
    else `BAL 7,FCMSFINT` then `BAL 7,FCMSFAIL` (vote-out path)
  - FCMDIAR2 waits out the noise delay, re-reads DIA, stores PC1 time in
    FCMCTTIM
- The same deadline-and-spin pattern, same `FCMSNTO2`, is in
  `FCMTSYNC.asm` (135/140/146), `FCMSSYNC.asm` (184; NOTE line ~244
  "REINITIALIZE TIMEOUT" -- SVC sync can restart its deadline, so measure per
  loop pass, not per call), `FCMISYNC.asm` (196/282), `FCMSFAIL.asm` (615,
  uses R3).  `FCMASYNC.asm:106` (set FORMATION) uses its own
  `LOOP1TIM` 10 ms timeout -- exclude it or scale separately.

**Metric:** for each sync event, `margin = time waited / 3850 us`, where time
waited = loop start -> neighbours agree (in PC1 / simulated time).  Report per
minute: max margin, count > 0.5, count > 0.8, and a histogram; break down by
sync program (code: SSIP 110, timer 101, SVC 100, IPR 010, I/O-complete 001),
by waiting GPC, and by which neighbour agreed last.  Expected healthy floor
roughly 0.003-0.05 (the 10-unit noise delay is ~0.003).  A timeout = 1.

Sync code alphabet (src/discretes.c ~338-356, from MLIB80/TFCVT.asm): null
111 (TCVTNULS X'0888'), SSIP 110, timer 101, SVC 100, IPR 010, I/O complete
001, halt/standby/dead 000.  Output bits 20/24/28 = A/B/C.

### 2. Errors: a non-universal I/O error (secondary metric)

`FIOERRLC.asm` ~1030-1060 ("FAIL TO SYNC PROCESSING"): a per-element counter
at `0(R2)` gets +1 once per erring transaction (`MSTH 0(R2),X'0001'`); when
`CHI R5,2` (count >= 2) AND `FIOGPCWE == 1` (exactly one GPC had the error)
AND that GPC is self (`TCVTCID == FIOGPCID`) AND the device is not SRB/PMU,
it loads `X'8000'` (FORCE F-T-S) and calls FCMSFAIL -- the computer takes
itself out.  This is the #136/#137 route (FCMSFAIL entered from
FIOERRLC+0313, R3=IOQE).

**Metric:** count of self-only I/O errors per element per GPC; each one is
0.5 of the way to a vote-out.  **OPEN: when does that counter reset?**  Read
FIOERRLC/FIOCOUNT before scoring -- it decides whether an isolated error
stays at 0.5 or decays.

**Overall stability = max(timing margin, error margin)**, per window.

## How to measure the timing margin -- in order of cost

### A. Offline, from logs: no emulator change (do this first)

`YAGPC_SYNCORDER=1` (src/vehicle.c `vehicle_route_out`, ~line 297) already
prints, for every change of any GPC's 3-bit sync code:

    SYNCORDER gpc=N code=ABC tshared=<us> pub1=<us> pub2=<us> ...

`tshared` is the barrier's shared frame (barPubUs), good to one instruction;
`SYNCORDER-JOIN` lines give each machine's clock offset at barrier join (#130).
Write a scratchpad script: for each handshake (a GPC leaving null for code X),
wait for GPC n = (latest time any other set member issued X in the same
handshake) - (GPC n's own issue time), floored at 0; margin = wait / 3850.
Approximation: ignores the noise re-read and each loop's exact start, and
set membership must come from the CAM/ICC state (members only).  Log volume
is high (thousands of lines/s with 4 GPCs) -- fine for ~20 min runs, not for
hours.  Check the line cap trap in #130: confirm the log was not truncated
before trusting an absence.

### B. Exact, in-process (do if A is not discriminating, or for long runs)

Hook the decision instructions in each of the five loops -- the
`N R4,FCMBIT16` / branch after `SR R4,R1` -- and read R4 (time left) at the
moment of agreement and at timeout.  Addresses come from the load map for the
tape (earlier work matched addresses against DASS_G2, e.g. 018BE9 =
FCMCSYNC+005B, 019501 = FCMSFAIL+0075 -- see #111).  Keep a per-GPC, per-
program histogram in memory and print it every N seconds and at exit, so it
can stay on for multi-hour runs.  The flight software's own number.

## Validation -- does the meter read the right thing?

1. **Clean vs failing runs.**  In the scripted networked config (below), does
   the margin climb before a vote-out and stay near the floor in runs that
   keep the set?
2. **Controlled stress.**  Loosen the barrier: `--barrier-us 500`, `1000`,
   `2000` (default in simulatePASS is 25 via YAGPC_BARRIER_US).  The delta
   adds directly to cross-GPC skew, so the margin should rise with it, and a
   vote-out should follow as it nears 1.  If it does not move, the meter is
   wrong (or the skew is not where the waits come from -- also worth knowing).
3. Compare against a headless control (in-process `--deu-model`, like
   rs41.sh) to see whether networked MEDS2 displays lower the margin.

## Configuration for the overnight runs

- Tape: `~/workspace/pass-run/OI340700-v44boot.mmv`
- Driver pattern: scratchpad `perf.py` of session 8cd63a77 (may be gone).
  It is: `simulatePASS.py --gpcs 1-4 --crts 2 --port-base <private, e.g. 22000+>
  --title perfX --logs <dir> --panel-script <file> --keys <file>
  --duration 1230 --tape <tape> --yagpc-extra "<opts>"`, run from
  `yaShuttle/discretePanel` with `cd dir;` as its own statement (NOT
  `cd && (...) &` -- that backgrounded the cd twice).  Env such as
  `YAGPC_SYNCORDER=1` passes through simulatePASS to yaGPC2.  Refuse a port
  base already in use; kill leftovers by PID in their own invocation (never
  pkill -- it matches its own shell).
- Panel script (ms; every GPC IPLs from MM1 in the documented order):

      0 gpc 1
      0 mode HALT
      10 gpc 2
      20 mode HALT
      30 gpc 3
      40 mode HALT
      50 gpc 4
      60 mode HALT
      80 idppower 1 on
      90 idppower 2 on
      100 crt 1
      200 source MM1
      400 gpc 1
      500 ipl
      3000 mode STANDBY
      160000 crt 0
      162000 mode RUN
      164000 source OFF
      169000 gpc 2
      170000 source MM1
      171000 crt 2
      171500 idpload 2
      172000 ipl
      175000 mode STANDBY
      340000 crt 0
      342000 mode RUN
      344000 source OFF
      349000 gpc 3
      350000 source MM1
      351000 crt 2
      351500 idpload 2
      352000 ipl
      355000 mode STANDBY
      520000 crt 0
      522000 mode RUN
      524000 source OFF
      529000 gpc 4
      530000 source MM1
      531000 crt 2
      531500 idpload 2
      532000 ipl
      535000 mode STANDBY
      700000 crt 0
      702000 mode RUN
      704000 source OFF

  (GPC POWER switches are not scripted; in panelO6 they only drive the local
  OUTPUT talkback, never the bus.)
- Keys (seconds):

      70 ITEM 1 EXEC
      240 KB2 ITEM 1 EXEC
      420 KB2 ITEM 1 EXEC
      600 KB2 ITEM 1 EXEC
      715 ITEM 1 + 2 EXEC
      723 ITEM 2 + 1 EXEC
      731 ITEM 3 + 2 EXEC
      739 ITEM 4 + 3 EXEC
      747 ITEM 5 + 4 EXEC
      755 ITEM 7 + 1 EXEC
      763 ITEM 8 + 2 EXEC
      771 ITEM 9 + 3 EXEC
      779 ITEM 1 0 + 4 EXEC
      787 ITEM 1 1 + 1 EXEC
      795 ITEM 1 2 + 1 EXEC
      803 ITEM 1 3 + 2 EXEC
      811 ITEM 1 8 + 1 EXEC
      819 ITEM 1 9 + 2 EXEC
      840 OPS 2 0 1 PRO

- CAM result is in `<logs>/cam.log` (lines like `voting: 34  ON (bus)`:
  row = voter, column = target; diagonal = that computer's own fail lamp).
  No timestamps -- time a change by the file mtime against the OPS request.
- Check a run actually reached OPS 2 (UNIV PTG 2011 on CRT1) before trusting
  its numbers; window titles are `perfX / CRT1 - MF GNC`, capture with
  `import -window <id>` found via `xwininfo -root -tree`.

## Background already established (do not re-measure)

- **Ledger #145 (open):** scripted 4-GPC networked runs lose one GPC after
  OPS 2 in 4 of 6 runs, a different GPC each time, +26..+170 s: A defaults
  GPC3 +26; B spin 20 GPC2 +170; C spin 0 none; D idle poll 4 none; E min
  sleep 10 GPC4 +158; F defaults, no PACETRACE, GPC4 +26.  Controls that held:
  le-g4-0 / cr-g4-0 (~200 s, headless --deu-model, MM2 for GPC2/4,
  SYNCTRACE on) and the owner's hand-run networked 4-GPC set (3+ hours, CAM
  dark).  These runs are the natural first test set for the meter: re-run the
  same config with YAGPC_SYNCORDER=1 and see if the margin predicts the loss.
- **UPDATE 2026-09-14 19:47:** the owner's next HAND-WORKED 4-GPC 2-CRT run
  (defaults, --size 384) lost GPC4 about 13 minutes after OPS 2 (cam.log
  19:19:26; OPS 2 load ended before 19:06:52).  So losses are not scripted-
  only and not a start-up transient: they arrive at random, from 26 s to 13+
  min, and a 3-hour clean run was just a lucky sample.  CONSEQUENCE FOR THE
  OVERNIGHT RUNS: "no vote-out" in one 20-minute run means nothing; use the
  margin distribution, and run long enough (or enough runs) that a loss rate
  can be stated with a count behind it.
- **CPU (commit 7f9a542bc, CLAUDE_LOG.md):** ~350% for 4 GPCs whatever the
  pacing knobs; no wait states in OPS 2; owner does not want CPU changes.
- Barrier: vehicle.c BARRIER_DELTA_US 200 default, simulatePASS sets 25;
  BARRIER_MAX_HOLD_SEC 0.25; `--barrier-us`, `--barrier-spin-us`,
  `--rt-min-sleep-ms`, `--rt-idle-poll-ms` exist (be744d5f8).
- perf is unavailable (kernel.perf_event_paranoid=4).
- Ledger entries to read first: #91 (sync path latency refuted -- and its
  warning that pairing traces by code is NOT a latency measurement: the code
  alternates between few values, so pair by handshake/sequence, not by code
  match), #111, #130, #136, #137, #139, #141, #145.

## Host events: record them alongside (owner's hypothesis)

The owner suspects exogenous host events -- swap, large memory moves, file
I/O -- freeze the host briefly and tip a GPC out.  Already checked (ledger
#145, 2026-09-14 evening): journal empty around all five losses; the
simulation's processes had no swapped pages and zero major faults through a
loss; scripted runs logging to NVMe failed as often as the hand run logging
to the spinning /mnt/STORAGE disk; barrier never abandoned (no single-thread
stall > 250 ms); display peer holds that went unanswered (including partial
replies past their 5 ms budget, which is 5 ms MINUS time already held) never
landed on the voted-out computer near its loss, and clean runs had as many.

**LEAD HYPOTHESIS (owner, 20:03): desktop activity.**  The one long clean
run (12:59-16:23) was while the machine was unattended; every loss -- the
owner's hand run and the scripted ones -- came while the owner was using the
desktop (opening and closing large programs such as an email reader).  The
logs cannot test this after the fact (program launches do not reach the
journals), and the scripted comparisons are weak: runs B-E changed timing
settings, so only A and F (defaults) are like-for-like.  RULES FOR THE
OVERNIGHT RUNS: defaults only (no pacing/barrier options) for anything
compared; an unattended overnight run IS the quiet condition, so few or no
losses there is evidence FOR the hypothesis, not a null result; the
disturbed condition must be created deliberately and timestamped.

Not yet covered, so record it overnight:

0. **A scheduling-latency probe**, the most direct measure of "the host got
   busy": a thread (or small C program) that sleeps 1 ms in a loop and logs,
   once a second with a wall timestamp, its worst overshoot and how many
   wake-ups were more than 2, 5, 20 and 100 ms late.  Run it at normal
   priority beside the simulation.  Swap was already ruled out for the
   simulation's own processes; CPU contention and scheduler delays were not.

1. **A host-stall recorder** running beside each run (scratchpad script):
   once a second, with a wall-clock timestamp, `/proc/pressure/{cpu,memory,io}`
   totals (deltas), `/proc/vmstat` pswpin/pswpout/pgmajfault/compact_stall/
   allocstall_*, and for yaGPC2 and each MEDS2 process majflt, voluntary and
   involuntary context switches, and per-thread utime/stime.  Correlate every
   CAM change (cam.log mtime, or poll cam.log once a second and timestamp the
   new lines) against the preceding seconds.
2. **The display listener path.**  GPCs 3 and 4 are only ever LISTENERS on DK
   buses 6-9 (CRT1 is GPC1's, CRT2 GPC2's) and a listener does not peer-hold,
   so a late MEDS2 reply reaching a listener is the untested route to a
   self-only I/O error (FIOERRLC).  Turn on `YAGPC_TIMEOUT_TRACE=1
   YAGPC_TIMEOUT_TRACE_PE=6,7,8,9 YAGPC_TIMEOUT_TRACE_FROM=<OPS 2 time>` and
   `YAGPC_ERRTERM_TRACE=6,7,8,9` (check each variable's exact syntax in
   src/iop.c ~1618-2000 and run.c:406 first) with `YAGPC_SYNCORDER=1`, and see
   what precedes the FCMSFAIL that takes the computer out.
3. **Quiet vs disturbed, as a controlled comparison** (after 0-2 work), all
   runs at defaults, same scripted configuration, each long enough to count
   losses (e.g. 60-90 min in OPS 2):
   - QUIET: nothing else running; probe and recorder only.
   - DISTURBED: the same, plus a timestamped disturbance every few minutes,
     one kind per run so the cause can be named --
     (a) an all-core CPU burst for 1-5 s (e.g. `nproc` busy loops);
     (b) a memory burst: allocate and touch several GB, then free it
         (large-block moves, page-cache reclaim, compaction);
     (c) spinning-disk I/O: a large `dd ... conv=fsync` to /mnt/STORAGE;
     (d) launching and closing a large program headlessly (e.g. a browser
         with a throwaway profile, `--headless`), the nearest scriptable
         stand-in for the owner opening an email reader;
     (e) SIGSTOP/SIGCONT of one MEDS2 process for 5, 20, 100 ms, by PID
         (`kill -STOP <pid>; sleep; kill -CONT <pid>`), which isolates the
         display path.
   Compare loss count and the sync-margin distribution between conditions,
   and line every loss and every margin excursion up against the probe,
   the recorder and the disturbance log.  Do NOT touch the owner's own
   programs or running simulation; use private port bases.  If losses or
   margin excursions follow a kind of disturbance, that names the mechanism
   and the fix is to make that path tolerant; if the quiet runs lose GPCs as
   often, the hypothesis is refuted -- record either way in #145.

## Deliverables for the morning

1. The metric working (script A at least), with its definition written down.
2. Margin results for: a clean run, a run that lost a GPC, and the barrier
   sweep -- stating whether the meter predicts the loss.
3. Findings recorded in `gpc-causes.py` (update #145 and/or add), CLAUDE_LOG
   notes for README targets, verified work committed.  No `.md` edits other
   than this handoff and CLAUDE_LOG.md.
