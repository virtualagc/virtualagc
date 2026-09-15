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

00. **atop, which the owner started 2026-09-14 20:22** -- `atop -w
   /fastlogs/atop.raw` (default 10 s interval) on the NVMe root; the atop
   package (2.10.0) also runs a system service writing
   `/var/log/atop/atop_YYYYMMDD` every 600 s, whose first record was 20:09:55
   that evening -- NEITHER covers the 2026-09-14 losses.  Read with
   `atop -r /fastlogs/atop.raw -b HH:MM -e HH:MM` (text) or add
   `-P PRG,PRC,PRD,CPU,DSK` for parseable lines; the first record in a file
   is cumulative since boot -- skip it.  WHAT MATTERS IN IT: per-process
   `RDELAY` (time runnable but waiting for a CPU -- the direct "host got
   busy" figure) and `BDELAY` (waiting on block I/O) for yaGPC2 and each
   MEDS2 python3, next to the top CPU users, CPU idle/wait, disk busy and
   PAG/SWP lines, for the record containing each CAM change.  In a quiet
   record at 20:33 all of the simulation's processes showed RDELAY and
   BDELAY 0.00 s.  SIZE: one 10 s record was 65,956 bytes; the size is per
   record (mostly per-process data), so 1 s intervals cost ~66 KB/s, ~240
   MB/h, ~2.4 GB for a 10 h night -- affordable on the SSD (254 GB free) but
   delete afterwards.  Records are averages: a 20-50 ms freeze inside one
   barely moves them, so atop NAMES the busy program while the probe below
   catches the stall itself.  Suggested: 1 s only during the disturbed runs,
   the owner's 10 s otherwise.  Do not restart or reconfigure the owner's
   atop without asking.

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
     (d2) THE REAL CASE SEEN: the owner's hand run lost GPC2 at 19:51:46,
         3 min 24 s after Eclipse C/C++ 2024-06 started (19:48:22; java,
         -Xmx4g, 3.2 GB RSS, ~100 s CPU in its first 20 min -- start-up and
         probably CDT indexing from /mnt/STORAGE).  ASK THE OWNER before
         launching their Eclipse or its workspace; a throwaway workspace
         (`eclipse -data <scratch dir>`) importing a large C tree is the safe
         stand-in;
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

## EVENING RUN eve1 (started 2026-09-14 20:43, owner using the desktop)

The owner agreed (20:39-20:42) to start early so their own desktop use --
exercise break ~20:42-21:12, then at least an hour of normal use -- is the
DISTURBED condition; the unattended night is the quiet one.  The owner's
simulation and 10 s atop were stopped with permission.

Files (scratchpad = /tmp/claude-1000/-mnt-STORAGE-home-rburkey-git-virtualagc-
yaShuttle-yaGPC2/8cd63a77-3409-4931-9bc0-d9c0953b865d/scratchpad, NVMe):
- run: `simulatePASS.py --gpcs 1-4 --crts 2 --port-base 25000 --title sync-eve
  --logs <scratch>/eve1 --panel-script <scratch>/perf-in/panel.script --keys
  <scratch>/perf-in/keys.txt --duration 18000` (defaults, ends ~01:43), env
  `YAGPC_PACETRACE=1 YAGPC_SYNCORDER=1 YAGPC_ERRTERM_TRACE= (empty = all buses)
  YAGPC_TIMEOUT_TRACE=1 YAGPC_TIMEOUT_TRACE_PE=6,7,8,9`.  simulatePASS started
  20:43:31; yaGPC2 pid 3020726 started 20:43:33.300 (<scratch>/eve1-yagpc2-
  start.txt); OPS 2 keyed ~20:57:35.  yaGPC2.log grows ~300 KB/s (~5.5 GB).
- `/fastlogs/atop-1s.raw` (atop at 1 s, started 20:42:31 by Claude; the
  owner's old `/fastlogs/atop.raw` 10 s file is kept).
- `<scratch>/stall/latprobe.log` (latprobe.c, started 20:42:4x): per second
  `HH:MM:SS wakes maxlate_ms n>2 n>5 n>20 n>100`.
- `<scratch>/stall/camwatch-eve1.log`: every cam.log line with a wall stamp.
- Scripts in `<scratch>/stall/`: `around.py HH:MM:SS [secs]` (probe + atop
  1 s + camwatch around a moment); `sync_margin.py yaGPC2.log START_ISO`
  (handshakes aligned per code in sequence, spread/3850 us, per-minute worst/
  p99/p90 and the largest spreads with wall times).

Baselines measured 20:55-21:01 (owner away, host quiet):
- margin: 55,359 handshakes, all 4 GPCs; per minute p90 ~0.015, p99 ~0.10,
  worst 0.41-0.57.  The three largest (20:55:16.442 SSIP 2201 us, 20:58:39.411
  SVC 2032 us, 20:58:01.011 SVC 1984 us) were at QUIET host moments (probe
  max < 0.2 ms, atop RDELAY/BDELAY 0.00 for yaGPC2 and MEDS2, disks idle) --
  so ~0.5 spreads are intrinsic, and big SVC spreads recur at .011/.019 s
  positions (20:58:01.011, :08.819, :16.019, 20:59:04.019, :52.019),
  suggesting a periodic flight-software cycle.
- THE BARRIER MAKES HOST STALLS INVISIBLE TO SYNC SPREAD: all four machines
  stay within 25 us of simulated time, so a wall-clock freeze makes everyone
  wait rather than opening a spread.  Host stalls can only bite through
  WALL-CLOCK waits that become I/O errors -- the display peer holds (200 ms
  first word, 5 ms minus time held for the rest) -- feeding FIOERRLC.
- ERRTERM after OPS 2: GPC1 steady on BCE 8, 20, 22 (~125/187/188 per
  minute; known #137 kind); GPC3 and GPC4 on 8/20/22 only through 20:58;
  GPC2 none.  Peer holds after OPS 2: bus 6 29 replies (median 3 ms, max 67),
  bus 7 85 replies (median 9.1, max 66) and 3 'none' (10-38 ms held).
- LOSS 1 of eve1: 21:02:17.248 (camwatch), owner AWAY: 44, 14, 24, 34 ON --
  GPC4 out, its diagonal lit.  ANALYSIS: (a) sync margins in the 13 shared
  seconds before were normal (per second worst 0.02-0.18, p99 ~0.11);
  (b) GPC4 was the LAST member in the final nine SVC handshakes, its lag
  growing 12 -> 475 us over ~2 ms (margin 0.003 -> 0.123) -- beyond the
  25 us barrier, so GPC4 was executing MORE instructions between syncs, not
  being held; (c) its last SVC issue (tshared 1118.793778 s) was matched by
  no other GPC; it held the code 5.35 ms (> 3850 us timeout), returned to
  null at 1118.799131 s and never issued again; GPC1-3 went on syncing.  So
  GPC4 DIVERGED (an SVC sync the others did not make) and failed itself --
  not a slow handshake.  (d) ERRTERM identical on all four GPCs (BCE 8, 20,
  22, steady; bus 8 is the absent IDP3) -- no self-only I/O error; display
  peer holds nearby all replied within 7 ms (~1.4 s earlier).  (e) HOST: the
  only blip in 25 s was at 21:02:13 -- a new chrome renderer (pid 3022340,
  +285 MB, 140% CPU, RDELAY 0.12 s; exited since; owner away) with latprobe
  max 2.96 ms (2 wakes > 2 ms), yaGPC2 RDELAY 0.02 s, cam.py 0.05 s -- 3-4 s
  BEFORE the loss (wall<->shared mapping uncertain by ~1 s: PACE wall counts
  from pacer birth, slightly after process start).  Also Claude's own
  analysis (two 51 MB log parses, atop reads) ran 21:00-21:02 -- analysis now
  runs under `nice -n 19 ionice -c3`.  HYPOTHESIS TO TEST: host delays act on
  the set not through sync spread (the barrier hides that) but through INPUT
  DIVERGENCE -- data from networked peers (MEDS2 IDPs/keyboards, the panel)
  arrives in wall time and each GPC reads it at its own simulated instant, so
  a delayed datagram can be seen by one GPC at a different point from the
  others; divergent processing then shows as an unmatched sync, as here.
- LOSS 2 of eve1: 21:04:12.354, owner AWAY: 24 OFF, 22/12/32 ON -- GPC2
  out, diagonal lit, leaving GPC1+GPC3.  HOST: nothing -- latprobe no wake
  over 2 ms; RDELAY/BDELAY 0.00 for yaGPC2 and every MEDS2 in 15 s; only
  Claude's niced analysis (python3 59% at 21:04:07, an atop read 21:04:11).
  LOG: margins normal (per shared second worst 0.02-0.15); GPC2's last codes
  were two IPR handshakes (the second 239 us spread, GPC2 last) and an IOC
  handshake at 1233.870930 s that COMPLETED with all three, then null at
  1233.871182 s and nothing more; GPC1/GPC3 synced on 144 s.  No unmatched
  GPC2 event.  In ~20 s of log around it: no ERRTERM off BCE 8/20/22, no
  BCE6/7 RECV TIMEOUT, no unanswered PEER HOLD; one BCE7 PEER HOLD 40.59 ms
  -> reply ~1 s before.  IPR handshakes are routine (~9/s, probably the
  absent IDP3 on bus 8).  CONCLUSION: neither eve1 loss shows its cause in
  these traces; neither had a self-only I/O error, a near-timeout
  handshake, or a host stall at the moment.  NEXT: landmarks at FCMSFAIL
  entry and its call sites (FIOERRLC+0313 self-FTS, FCMSFINT from each sync
  program, FPMSVC for SVC 39) so a loss names its FCOS path.
- SUPERVISOR (`<scratch>/stall/supervise.py`, started 21:06:36): adopts the
  current run, and when two CAM diagonals are lit (or the run ends) stops it
  by SIGINT and IPLs the next, eve2, eve3, ... (port base 25000+100*(n-1),
  same traces, max 12 runs, stops if < 30 GB free); every CAM line from
  every run and 'SUPERVISOR ...' events go to `<scratch>/stall/
  camwatch-all.log` with wall stamps; a persistent Monitor tails that.  eve1
  was stopped 21:06:36; eve2 launched 21:06:38 (OPS 2 ~21:20:40).
  eve2 was STOPPED BY HAND at 21:10:51, 5 min into its IPL, to relaunch with
  landmarks; the supervisor now takes `--fresh N` to launch run N directly.
  eve3 launched 21:10:53 (port base 25200, OPS 2 ~21:24:55) with
  `YAGPC_LANDMARKS=1948c:FCMSFAIL,19674:FCMSFINT` (entries from
  mafgen/csects-G2.json, decimal 103564 and 104052; FCMSFAIL also serves SVC
  39; FIOERRLC 105140 = 0x19ab4 and FPMSVC 110906 = 0x1b13a were NOT marked
  -- they run on every I/O error / SVC and would spend the 20-hit budget).
  LANDMARK lines carry t= on the hitting GPC's OWN clock and no gpc id --
  tell the GPCs apart by their clock offsets (SYNCORDER-JOIN offset_us).
  The 20-hit cap is per landmark for the whole process, not per GPC.
  Reading a loss: FCMSFINT shortly before FCMSFAIL on that GPC = a sync
  program's timeout; FCMSFAIL alone = FIOERRLC's self-FTS or SVC 39 (ARC
  drop).
  NORMAL HITS, NOT LOSSES: in eve3, FCMSFINT fired 8 times during the IPLs
  (#1 t=160.99 at GPC1 RUN; #2-#8 at t~168.8 on each later GPC's own clock
  and at t~341/349/521/529 as each new GPC joined) and FCMSFAIL none -- so a
  joining computer costs about two FCMSFINT hits, and 12 of the 20 remained
  for losses once eve3 reached OPS 2 (~21:25).
- LOSS 1 of eve3: 21:44:04.321, disturbance block 1 (none), owner at the
  desktop but host quiet before it (latprobe clean, RDELAY/BDELAY 0.00 for
  yaGPC2 and MEDS2; sda 26% busy in the loss second itself; chrome 194% only
  3-5 s AFTER).  GPC4 out, diagonal lit.  FCMSFINT had spent all 20 landmark
  hits at the IPLs and the OPS 2 transition (#11-#20 at shared ~842.35/842.5
  on all four clocks) -- useless at the loss.  FCMSFAIL hits, mapped by
  SYNCORDER-JOIN offsets (GPC2 172.0118, GPC3 352.0018, GPC4 532.0026 s):
  #1 GPC4 shared 1986.2770, #2 GPC3 1986.2813, #3 GPC2 1986.2850, #4 GPC1
  1986.2850 -- GPC4 FIRST, 1.45 ms after its final IOC issue (1986.275310),
  i.e. NOT a 3.85 ms timeout; the others followed 4-8 ms later (voting).
  THE SYNC SEQUENCE (all GPCs, shared s): IOC handshake 1: GPC3/1/2 issue
  .272490-.272513, GPC4 .272522 (9 us after the last), GPC1-3 null .272741-
  .272769 but GPC4 STAYS in IOC; handshake 2: GPC1-3 IOC .273655-.273681,
  all four null .27389-.27392 -- GPC4 consumed the others' 2nd handshake as
  its 1st; then GPC4 IOC .274133 vs others .274225-.274244; GPC4 .274662 vs
  others .274868-.274879; GPC4's 4th IOC .275310 answered by nobody (the
  others' next code was timer at .280975); FCMSFAIL at .2770; GPC4 null
  .280666.  So GPC4 slipped ONE I/O-completion handshake out of phase: on
  handshake 1 its confirming DIA read did not see the agreement before the
  others (holding IOC only ~220-250 us) had returned to null, and from then
  on it was one behind; FCMISYNC's own shorter checks (csect labels
  FCMIT3DL/FCMIT5DL) caught the extra.  ISSUE-TIME SPREAD WAS 9-32 us --
  the spread metric CANNOT see this failure.  The margin that matters is the
  COMMON OVERLAP of all members' code-held intervals (min over members of
  drop time minus max issue time) against what a member needs to confirm
  (read, FCMNOISE settle, re-read).  ERRTERM around it: only the steady all-
  GPC BCE 20/22 pattern; PEER HOLDs all replies <= 3 ms; nothing GPC4-only.
  eve1's GPC4 loss (SVC, 5.35 ms hold) is very likely the same slip.
  NEXT: an overlap-margin script over SYNCORDER, and YAGPC_SYNCTRACE (what
  each GPC READS from its neighbours) on a run to see the missed read.
  Runs from eve4 mark FCMSFAIL only (supervisor restarted 21:46:22 with
  `--adopt 3`).
- OWNER NOTE (21:45): the CAM window does not draw the eye; the owner saw
  this loss only because Claude's output scrolled.  Earlier 'unnoticed for
  15+ min' cases are consistent with that.
- DISTURBANCE SCHEDULER (owner approved all blocks, 21:40): `<scratch>/stall/
  disturb.py`, started 21:41:45, log `<scratch>/stall/disturb.log` (one
  timestamped line per burst, 'BLOCK ... begin/end' per block).  Two cycles
  of five 10-min blocks, then it exits by itself at ~23:21:45 so the
  overnight quiet runs are not disturbed:
    1 none  21:41:45 / 22:31:45      2 cpu  21:51:45 / 22:41:45
    3 disk  22:01:45 / 22:51:45      4 mem  22:11:45 / 23:01:45
    5 stop  22:21:45 / 23:11:45      (cycle 1 / cycle 2 block start)
  cpu = 2 s busy loop on every core every 30 s; disk = 4 GB dd conv=fsync to
  /mnt/STORAGE/home/rburkey/.claude-disturb-io.bin, deleted after each, every
  60 s; mem = 8 GB bytes object (memset, so touched) held 5 s, every 60 s;
  stop = SIGSTOP/SIGCONT of the current run's CRT2 MEDS2 (highest port base
  >= 25000) for 5, 20, 100 ms in turn, every 20 s, SIGCONT in a finally.
  All at normal priority.  To stop early: SIGTERM its python PID (find by
  cmdline disturb.py) -- it logs 'DISTURB stopped by signal'; check no
  .claude-disturb-io.bin is left and no MEDS2 is in state T (stopped).
  around.py now prints disturb.log lines near the window and reads
  camwatch-all.log.  The owner cannot see when bursts happen.
- CLAUDE CODE FREEZES (owner, 21:36): the claude process (pid 2745832) hit
  >= 25% CPU in 45 of 2,258 seconds 21:00-21:37 (mostly Claude's own work;
  40% at 21:36:51 as the owner typed); those seconds rarely coincide with
  latprobe wakes > 2 ms, and no other process showed RDELAY then -- a stall
  of the claude process itself, not host-wide.  latprobe saw 22 seconds with
  a wake > 2 ms in 37 min, all 2-6.5 ms.  At the eve1 losses the probe was
  clean; claude was 4% (GPC4) and 36% (GPC2).  Claude keeps its analysis
  light while the owner's disturbed hour runs.
- A persistent Monitor tails camwatch for lamp changes; on a loss run
  `around.py` at the camwatch stamp, then look at ERRTERM/PEER HOLD/SYNCORDER
  lines just before it on each GPC's clock (map own clock -> wall with that
  GPC's PACE group: offsets ~0/10 s GPC1, ~180 GPC2, ~360 GPC3, ~540 GPC4).

## Deliverables for the morning

1. The metric working (script A at least), with its definition written down.
2. Margin results for: a clean run, a run that lost a GPC, and the barrier
   sweep -- stating whether the meter predicts the loss.
3. Findings recorded in `gpc-causes.py` (update #145 and/or add), CLAUDE_LOG
   notes for README targets, verified work committed.  No `.md` edits other
   than this handoff and CLAUDE_LOG.md.
