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
  SYNCORDER-JOIN offsets.  CORRECTED 21:50: a GPC that rejoins the barrier
  at its HALT->RUN gets a SECOND join line with a new offset, and the offset
  IN FORCE is the last join whose own= is <= the landmark's t (eve3: GPC3
  352.001817 then 352.005465 s from own 168.8157 s; GPC4 532.002634 then
  532.004685 s from own 168.8159 s).  With that: #1 GPC4 shared 1986.279441,
  #2 GPC3 1986.284998, #3 GPC2 1986.285013, #4 GPC1 1986.285026 -- GPC4
  FIRST, 4.13 ms after its final IOC issue (1986.275310), i.e. the 3.85 ms
  timeout plus handling (the first version of this note used the first
  offsets and wrongly said 1.45 ms, not a timeout).  The others followed
  ~5.6 ms later (voting).
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
- LOSS 2 of eve3: 21:46:37.531 (block 1, host quiet; Xorg 18-26% at :35-:36,
  no RDELAY for the simulation): GPC3 out.  A GPC3-ONLY I/O ERROR: `ERRTERM
  gpc=3 bce=20 pc=1cc2e left=1` at shared 2139.468247 (timing-unit bus 20;
  the steady all-GPC BCE20 errors are pc 1cc32 / GPC1 1cc1c with left=25);
  IPR handshakes .470284 and .471090 (GPC3 238 us late on the second); IOC
  handshake complete .473033; GPC3 ALONE into FCMSFAIL at .473263, no
  handshake pending; GPC1/GPC2 at .484938/.484945.  = FIOERRLC's one-GPC-
  with-errors self-FTS, the #136 family.
- ONE-GPC ERRORS ACROSS eve1 AND eve3 (ERRTERM on a bus with no other GPC
  erring on that bus within 20 ms, after OPS 2):
      eve1  989.227  GPC4 bce20 pc=1cc2e left=1   no loss then (GPC4 later
                                                   lost to a SLIP at 1118.8)
      eve1 1137.986  GPC1 bce21 pc=1ccae left=2   no loss
      eve1 1233.866  GPC2 bce20 pc=1cc2e left=1   GPC2 LOST (final sync
                                                   1233.871182, 5 ms later)
      eve1 1256.066  GPC3 bce20 pc=1ccae left=4   no loss
      eve3 1073.668  GPC2 bce22 pc=1ccae left=4   no loss (and 5 more 1ccae
                                                   left=2/4/6 on GPC1/2/4)
      eve3 1924.908  GPC3 bce20 pc=1cc2e left=1   no loss then
      eve3 2139.468  GPC3 bce20 pc=1cc2e left=1   GPC3 LOST (its SECOND)
  READING: `bce20 pc=1cc2e left=1` (a timing-unit receive ONE WORD short on
  one GPC) is the killer, and FIOERRLC forces self-FTS at the second count
  (CHI R5,2) -- eve3 GPC3 shows first-no-loss / second-loss exactly; eve1
  GPC2's first may be hidden by the 20 ms uniqueness filter (a routine BCE20
  error on another GPC nearby).  pc=1ccae short reads (left 2-6) on buses
  20-22 occur without losses.  SO TONIGHT'S FOUR LOSSES ARE TWO EMULATOR
  DEFECTS, NOT HOST EVENTS: (a) handshake SLIPS, both on GPC4 (eve1 21:02,
  eve3 21:44); (b) one-word-short timing-unit receives on one GPC (eve1
  GPC2 21:04, eve3 GPC3 21:46).  NEXT: which program is at 1cc2e, and how
  the mtumodel's per-reader reply delivery can leave one listener a word
  short.
- THE KILLER ERROR, EXPLAINED FROM THE FLIGHT SOURCE (OI301700
  SSSRC/FIONSPPG.asm; G2 csects: 1cc2e FIONSPPG FIOBYNC3+4, 1cc32 FIOBYNC3+8,
  1cc1c FIOBYNC2+6, 1cc56/1cc6c the bus-22 twins, 1ccae FIOPRMPG FIOEL53L+2):
  FIONSR11 (commander, FF01 cyclic NSP1 read, bus 20) sends a LISTEN command,
  then #MIN 0,0 'READ NSP1 POWER DISCRETE' and #MIN 1,0 '2-STAGE A
  DISCRETE' (one word each, through the FF MDM, IUA FIOFFIUA), then #MIN 0,31
  'READ NSP1 DATA' (32 words).  FIONSL11 (listener) does #CMDI FIOFFIUA,
  FIOMDMRT (set IUA), then FIOBYNC3: #RDS 0,0 (power discrete, at 1cc2e),
  #RDS 0,1, then FIOBYNC4 #RDLI 31 (data).  Neither MDMs nor NSPs are
  modelled.  The STEADY listener error (1cc32/1cc6c left=25, on all
  listeners) is the 32-word read getting 7 STALE TIMING-UNIT reply words (#137
  saw the same); the KILLER (1cc2e left=1, one GPC) is the one-word power-
  discrete read getting NOTHING.  mtumodel.c answers every read on buses 20-22
  from ONE shared model: an MTU command (IUA 10) refills every reader's copy,
  a command for any other IUA zeroes every reader ('the same silence') -- but
  both happen when the COMMANDER'S thread is serviced, and each listener
  reads when ITS thread gets there, so whether a listener's read comes before
  or after the silencing is a wall-clock thread race.  Usually every
  listener catches stale words (the harmless universal error); occasionally
  one listener's power-discrete read comes after the silence, errors at a
  different step from the others, FIOERRLC counts it as that computer's own,
  and at the second it fails itself out.  This is the one place tonight where
  host load plausibly MODULATES the loss rate (thread interleaving).  FIX
  (proposed, not made): the timing-unit model delivers words ONLY to a
  receive addressed to the timing unit (the reading BCE's IUAR == 10); every
  other read on buses 20-22 -- the absent MDMs/NSPs -- gets silence on every
  GPC regardless of thread order.  Expected effect: the steady left=25
  errors become universal no-reply errors at the first read, and the
  one-GPC left=1 error disappears.  Needs the reader's IUA in the service
  call (check GpcServiceInput) and a rebuild -- which would change the binary
  new runs use mid-experiment, so timing is the owner's call.
- FIX, OWNER'S CHOICE 'FIX NOW' (21:57): the IUAR filter first proposed
  CANNOT work -- FIOFFIUA EQU 10 in both FIOPRMPG and FIONSPPG, the same
  IUA as the timing unit: IUA 10 is the FORWARD MDM, through which both the
  MTU (FIOMTURD EQU X'00024C26', 'MTU READ - MDM FF01 CARD=03 CHANNEL=01
  WORD COUNT=7') and the NSPs (FIONSPDR X'25000', FIONSP1P X'26420',
  FIONSP2P X'27020', FIONSPRD X'26C7F') are read.  So mtumodel.c was
  refilling its 7-word reply and resetting every reader on EACH of the NSP's
  commands.  CHANGE (src/mtumodel.c): MTU_READ_CMD 0x024C26 and CMD_FIELD(c)
  = c & 0x7ffff; XMIT_CMD refills only when CMD_IUA==10 AND
  CMD_FIELD==MTU_READ_CMD, every other command on buses 20-22 silences all
  readers.  (GpcServiceInput already has an 'address' field documented as
  IUA/subaddress, unused for receives -- not needed after all, no shared-
  header change.)  Built 22:01:11 (make AR=llvm-ar).  GATE PASSED 22:09:
  nsp-regress ALL MATCH (periodic deu 1805/342/566/334/572, mtu commands
  2951 vs ~7897 before -- the NSP reads now bypassed); committed with the
  new ledger entry for the defect.  The gate was run as: `headless-gpcmem.sh 420 <scratch>/nsp-regress`
  then `python3 <scratch>/gate.py <scratch>/nsp-regress` (event counters must
  match exactly: mmu 56/431/220731/220011/720/3-3-0, deu formatFills 8,
  resets 1, modeStatus 6, ipled, 0 abandoned/bite/dumps/headerless/unknown);
  and eve5 (supervisor `--fresh 5`, port base 25400, launched 22:02:06 on the
  patched binary) -- expect NSP errors identical on every GPC at the first
  one-word read and NO one-GPC 'pc=1cc2e left=1'.  The disturbance scheduler
  was stopped 21:56:59 (cycle 1 block 2 cpu, partial).  CORRECTION: eve4 was
  NOT stopped at 21:58 -- simulatePASS ignored SIGINT (twice: 21:57 and
  22:08) and Claude misread a 60 s wait timeout as 'gone'; all of eve4
  (old binary, port base 25300) ran on until 22:08, overlapping the
  nsp-regress gate run and eve5's IPL (about four extra cores), and its
  keyboard windows sat exactly on top of eve5's.  Stopped 22:08 by SIGINT to
  its yaGPC2 and SIGTERM to the rest, by PID.  The supervisor's stop() now
  escalates the same way (SIGINT simulatePASS, 15 s; SIGINT yaGPC2; SIGTERM
  everything on the port base; SIGKILL) and logs anything still alive; it
  was restarted with `--adopt 5`.  CHECK FOR STRAYS by listing processes
  whose argv contains each port base, not by counting seconds.
  FIRST RESULT OF THE FIX (eve5 at 22:07, GPC1 alone in PASS OPS 0, commander
  path), ERRTERM by (bce, pc, left): old binary (eve3, own t < 300 s): bus 20
  (1cc1c, 25) x428, bus 22 (1cc56, 25) x427 -- the NSP data read failing
  every cycle, 25 words short, forever.  Fixed binary: bus 20 (1cc0a, 1) x2
  then (1cc1c, 32) x1, bus 22 (1cc44, 1) x2, and then NO MORE; bus 7 x7, bus
  8 x231 (absent IDP3), bus 24 (1ccd2, 1) x2 unchanged.  So the NSP's first
  one-word read now fails, as an absent unit should, and PASS apparently
  BYPASSES the NSP read after a couple of errors (FIOBYNC1 'OVERLAID BY BCE
  BYPASS CODE'); with the old model those one-word reads got stray timing-
  unit words and seemed to succeed, so the bypass never came and the data
  read failed every cycle.  THIS EXPLAINS THE OWNER'S 2026-09-14 MORNING
  SPEC 99 LOG: GPC1 reporting 'BCE STRG 1 NSP' / 'BCE STRG 3 NSP' over and
  over.  With the fix they should appear once at start and stop.  The owner
  will look at eve5's SPEC 99 after OPS 2 (~22:17); whether 'TIME' (seen on
  GPC1 the same morning) also stops is open -- CDLANNUN lists TIME TONE
  (TM004), CDSANNUN a minor 'MTU' message, FCMCOM MTU TMP FAILURE bits;
  nothing yet ties it to the FIOPRMPG pc=1ccae short reads.
- IPL-TIME COMMON-SET BREAKS (eve4 21:53:41, eve5 22:09:25; 'GPC 2 *' in the
  owner's SPEC 99): during a LATER GPC's IPL, GPC1 and GPC2 (PASS OPS 0,
  common set) both entered FCMSFAIL within ~15 ms with no I/O error; the
  SYNCORDER-JOIN lines show GPC1/GPC2 repeatedly LEAVING and REJOINING the
  barrier (only run.c's held path can clear barActive), and at one rejoin
  the shared frame jumped ~165 s.  DIAGNOSTIC ADDED (uncommitted, env-gated):
  YAGPC_HELDTRACE prints every flip of a machine's held state with value/
  driven of register A and the attentive age of HALT/STBY/RUN/IPL
  (discretes_bit_age() added).  REPRODUCTION heldrep (2 GPCs, ord-in scripts,
  port base 26000, 22:19:54): GPC1 'HELD nothing published t=84.79 ...
  driven=00000000 age halt=1.510 stby=1.510 run=1.510 ipl=1.510', again at
  85.77 (1.598) and 87.51 (1.742), each released by the next datagram --
  i.e. panelO6's republish to GPC1's channel went silent for more than
  DISCRETES_STALE_SEC (1.5 s) during GPC1's GPCIPL load, so run.c's 'silence
  is HALT' rule stopped the CPU and took it out of the barrier.  atop:
  panelO6 at 0-5% CPU, RDELAY 0, throughout -- not busy; its Tk thread has no
  blocking socket call (receivers are threads), so the suspect is Tk
  WAITING ON THE X SERVER (Xorg was 20-57% CPU while heldrep's windows
  opened).  Candidate fixes: publish panelO6's discretes from a thread that
  does not depend on Tk (as MEDS2's BusPump), and/or do not hold a GPC that
  was already in RUN/STBY on stale bits alone (keep the last position until
  an explicit HALT arrives) -- the owner's call.
- CONFIRMED X SATURATION AT EVERY IPL-TIME BREAK: Xorg (single-threaded) ran
  at 79-102% of a core through eve4's break (21:53:28-46), eve5's (22:09:08-
  28) and heldrep's held events (22:21:12-30); with one simulation's windows
  alone it sat at ~80%.  BOTH FIXES, OWNER'S GO-AHEAD 22:40 ('set the timeout
  at whatever seems best'):
  FIX 2 (yaGPC2 src/run.c, run.h): in mode_switch_held_uncached, when nothing
  is published and prevMode is RUN or STBY (not HALT), the machine RIDES
  THROUGH on that position until panel_quiet_seconds() (the freshest of the
  four mode bits' attentive ages) reaches YAGPC_DISCRETES_HOLD_SEC (default
  60 s), logging 'MODE: crew panel silent N s; keeping RUN (held after 60
  s)', then 'holding the CPU until it is heard', and 'crew panel heard
  again'.  A machine that never heard a position is still held.  The held
  decision (mode_held_update, which also carries YAGPC_HELDTRACE) is now also
  re-evaluated every 4096 steps, because silence sends no datagram.
  FIX 1 (discretePanel/panelO6.py): _publish only hands the columns to
  _pub_loop, a thread that does ALL discrete sending (RESET then SET per
  register, at once on a change and every REPUBLISH_MS); _tick logs 'Tk tick
  N ms late' past 200 ms; NSTS_PANEL_STALL=<start s>,<seconds> holds the Tk
  thread once, for testing.  OPEN QUESTION the late-tick log answers: whether
  Tkinter's wait on X also holds Python's GIL (then _pub_loop would stall
  too and fix 2 is the only protection).
  TESTS RUNNING 22:44: stale-test (1 GPC, port base 26100, RUN at 20 s,
  NSTS_PANEL_STALL=45,5; SIGSTOP of the panel 5 s at ~70 s and 70 s at ~90 s;
  expect no silence for the Tk stall, 'keeping RUN' then 'heard again' for 5
  s, 'holding' after 60 s of the 70 s) and the regression gate stale-regress.
  RESULT stale-test (22:46): fix 1 -- NSTS_PANEL_STALL 5 s gave 'Tk tick 4960
  ms late' in panelO6 and NO silence in yaGPC2 (but time.sleep releases the
  GIL, so a real X wait is not yet proven the same); fix 2 -- 5 s SIGSTOP:
  'crew panel silent 1.6 s; keeping RUN', 'heard again'; 70 s SIGSTOP:
  'keeping RUN', then at 60.0 s 'holding the CPU until it is heard' (mode
  bits 60.044 s old), then 'heard again' and release.  FLAW FOUND: on resume
  'HELD no position t=69.700582 value=2a000000 driven=d40c0000 run=5.200' --
  the panel's first datagram is the RESET (refreshing HALT/STBY/IPL) while
  RUN, still set, stays stale until the SET: a momentary hold, which in a set
  leaves the barrier.  REFINED (build 22:47:34): in the no-position branch a
  last-heard RUN/STBY bit still SET in the register (only stale), with HALT
  not set and quiet < hold, keeps running; a real switch move clears the old
  bit, so genuine gaps still hold.  Re-test stale-test2 (5 s SIGSTOP at ~40
  s) and gate stale-regress2 (PORT_BASE=6700) running 22:48.
  eve7 (launched 22:37 on the pre-fix build) and the supervisor were stopped
  22:44; the supervisor now also sets YAGPC_HELDTRACE=1.
  OVERNIGHT PLAN (owner signed off 22:42): once both tests pass and the fixes
  are committed, restart the supervisor with `--fresh 8` on the fixed build,
  NO disturbance scheduler (quiet condition), atop 1 s, latprobe and camwatch
  still running; for every loss record: which GPC entered FCMSFAIL first
  (offset rule above), whether a one-GPC ERRTERM/RECV TIMEOUT preceded it,
  whether any HELD/'panel silent' line or barrier rejoin preceded it, the
  last sync codes (slip vs IPR->IOC->silence), and host state.  Classify:
  (a) handshake slip; (b) IPR->IOC->silent with no logged error (eve6 x2,
  possibly ARC's SVC 39 drop for an overlay error during the OPS 2 load,
  #139 family); (c) anything new.  Stop starting runs before ~07:00 so the
  owner's machine is free; report per class in the morning.  THE OWNER WILL
  BE AT THE DESKTOP FOR 5-10 MIN SOMETIME 04:00-05:00 (said 22:45): flag any
  loss in that window as possibly disturbed, and check atop/latprobe for it.
- OVERNIGHT, FIXED BUILD (commit bca2581d5), quiet: eve8 launched 22:55:54.
  THE IPL-TIME FIX HELD: YAGPC_HELDTRACE showed only the ordinary STBY->RUN
  momentary gaps, and no SYNCORDER-JOIN after the four initial joins -- no
  barrier rejoins, no IPL-time common-set break.  eve8 LOSSES, both CLASS (b)
  (IPR, IPR, IOC completed, then silence, no logged error): 23:10:35 GPC4
  (null at shared 875.950690, FCMSFAIL 875.950938; others 875.9567) and
  23:10:47 GPC1, GPC2 and GPC3 together (FCMSFAIL ~887.9507-887.9565) -- the
  whole set dissolved; nothing in the 4000 log lines before (no ERRTERM off
  bus 8, no RECV TIMEOUT, no PEER HOLD); Xorg 0-1%.  The two losses are
  exactly 12.000 s apart (phase 11.95 s mod 12), as eve6's were 108 s apart
  (phase 8.008 s) -- but IPR handshakes are ROUTINE (3811 GPC1 IPR issues
  after 820 s, in bursts every 0.1-0.2 s, most likely the absent IDP3's bus-8
  errors), so the IPR-IPR-IOC run before each loss is background, not a 12 s
  task; the 12 s phase is unexplained or chance.  NEXT INSTRUMENT (eve10 on,
  eve9 stopped early in IPL for it at 23:13): YAGPC_RANGETRACE=1948c-1948c+
  19674-19674,2000 -- at FCMSFAIL's and FCMSFINT's first instruction R7 is
  the caller's return address (FIOERRLC+0313 self-FTS = 19dc7; FCMSFINT from
  a sync program; FSVC0039/FPMSVC for SVC 39, ARC's drop), naming the path
  of every class (b) loss.  Reusable report: `<scratch>/stall/loss_report.py
  <run>/yaGPC2.log [GPC]`.  SUPERVISOR LIMITS (23:13): MAX_RUNS 40 (was 12,
  which would have ended the night at eve12) and NO_NEW_RUN_AFTER 06:30
  local, so the owner's machine is free in the morning; re-adopted eve10 with
  `--adopt 10`.  A 23:30 check confirms whether the range trace writes lines.
- eve10 LOSS 1, 23:27:50, class (b): GPC4 null at shared 839.951986 after
  IPR, IPR, IOC; FCMSFAIL on GPC4 at 839.952233 and 839.953106, GPC1-3 at
  ~839.958; one PEER HOLD (reply) in the 4000 lines before, nothing else.
  THE CALLER TRACE MISSED IT: FCMSFINT (19674) is called by FCMISYNC's routine
  IPR processing (R7=8f7d4031, i.e. FCMISYNC+00E9 = 18f7d, #136), so its hits
  on all four GPCs from ~823 s spent the 2000-line budget first.  From eve11
  the trace is FCMSFAIL entry only (YAGPC_RANGETRACE=1948c-1948c,2000).
  Trace line format: 'RT gpc=N t=<own s> <addr> <hw1> <hw2> <mnemonic> ...
  R0=.. R7=..'.  FC-BUS ERRORS AROUND THE OPS 2 TRANSITION (shared 700-835 s):
  every GPC x2 on buses 14-17 and on 20-23 at commander and listener pcs --
  universal; NSP commander-only errors GPC1 bus 20 1cc0a x93 and GPC3 bus 22
  1cc44 x93 (listeners 1cc32 left=25 x5 each) -- but NEITHER was dropped;
  nothing at all from 835 s.  So 'the fix leaves commander-only errors and
  ARC drops them' does not fit GPC4.  GPC4-FIRST TALLY: GPC4 was the first
  lost in eve1, eve3, eve6, eve8 and eve10 -- the LAST GPC IPLed, which
  reaches RUN at 702 s with the NBAT from 715 s and OPS 2 at 840 s, only
  138 s later (eve10's loss is AT the OPS 2 request).  EXPERIMENT from eve11:
  `<scratch>/perf-in/keys-late.txt` shifts every key at or after 715 s by
  +300 s (NBAT 1015 s, OPS 2 1140 s; duration 18300 s) -- compare transition-
  time losses, early (eve8, eve10) vs late (eve11+).
- eve10 LOSS 2, 23:29:24: GPC1 out (11 ON, 21/31 votes; its vote against
  GPC4 cleared) -- class (b): IPR, IPR, IOC, null at shared 911.951802,
  FCMSFAIL on GPC1 911.952038, GPC2/GPC3 ~911.9578 and ~911.968; nothing
  logged before but one PEER HOLD (reply).  CLASS (b) LOSSES COME IN EXACT
  12-SECOND MULTIPLES OF SIMULATED TIME within a run: eve6 704.008 -> 812.008
  (108 s = 9x12), eve8 875.950 -> 887.950 (12 s), eve10 839.952 -> 911.952
  (71.9998 s = 6x12) -- to within a millisecond.  The IPR/IOC handshakes
  before each are routine (every 0.1-0.2 s), so the 12 s period belongs to
  some other periodic task whose pass occasionally takes a GPC out: FIND IT
  (flight source: a 12 s cycle in FCOS/SM/RM, time/MTU checks -- the owner
  saw 'TIME MTU' in SPEC 99).  COLLISION: Claude restarted the
  supervisor (to pick up keys-late) just as eve10's second loss was handled;
  the old supervisor had already launched eve11 (23:29:42, early keys), the
  new one adopted the dead eve10 and launched a SECOND eve11 on the same port
  base 26000 (23:29:47).  Both stopped 23:30:34; ONE clean eve11 launched
  23:30:36 (keys-late, trace FCMSFAIL only) -- ignore anything in
  eve11/prev-* from the collided attempts.  launch() now refuses a port base
  already in use and skips to the next run number; restart the supervisor
  only with `--fresh N` after stopping runs, or `--adopt N` when nothing is
  mid-transition.
- WHICH MMU AN OPS OVERLAY LOADS FROM (owner's question 22:24): not IPL
  SOURCE (yaGPC2 reads it only in firmware_ipl, run.c ~1152-1171) and not
  the keyboard/CRT.  ARCGPC CHOOSE_BUS: 'IF CZ2B_MM_MF$(ARC_J:4)= ON THEN
  ARC_BUS_ID = 19; ELSE ARC_BUS_ID = 18;' with CZ2B_MM_MF INITIAL(4#HEX'2000')
  -- bit 4 OFF, so every major function starts on MM1 (bus 18); ARCGPC's ICC
  message code confirms 'SET BIT 16 ON FOR MMU1 SELECTED' when = HEX'2000'.
  On an overlay error RETRY_CHOOSE_BUS takes the other bus (37 - ARC_BUS_ID)
  and flips the selector (XOR HEX'3000' -> HEX'1000', MM2) for that function,
  shared by ICC.  So an OPS 2 load from MM2 means the MM1 attempt failed and
  PASS silently retried -- in the owner's hand run and in Claude's scripted
  runs (#139: GPC2 commanding MM2 throughout).  Claude first misread HEX'2000'
  as MM2 and told the owner so; corrected.  OPEN: why the MM1 attempt fails
  in the emulator.
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
- eve11 LOSS, 23:50:58 (keys-late: OPS 2 at 1140 s; loss at shared 1187.951,
  so LATE KEYS DID NOT HELP -- GPC4 still first).  THE CALLER TRACE WORKED:
  GPC4 R7=9dc70031 -> 19dc7 = FIOERRLC+0313, THE SELF FAIL-TO-SYNC (error
  count >= 2, 'CHI R5,2' after FIOSSM07); GPC1-3 R7=8f4f2031 -> 18f4f =
  FCMISYNC+00BB (they see GPC4 fail).  At the call R4=0018 = 24 = FIONSPID
  (FIOERRLC's equates: NSP DEVICE ID) and R5=4 (the count) -- GPC4 WAS
  COUNTING NSP ERRORS.
  THE 12 s IS A SPLIT HANDSHAKE: at one I/O completion some GPCs issue IPR
  (010) and the rest IOC (001).  scratchpad stall/splits.py over the post-
  OPS 2 part of eve11 finds such splits only at shared 1151.947, 1163.947,
  1187.947, 1199.947 (phase 11.95 mod 12; 1175.947 had none), and eve10/eve8
  the same phase.  Every class (b) loss is one: eve11 G3,G4 IPR vs G1,G2
  IOC (G4 had IPR at 1151, 1163 and 1187 -> count 2 -> FTS); eve10 911.948
  G1 IPR vs G2,G3; eve8 875.947 G1,G4 IPR vs G2,G3.  Splits before OPS 2
  (eve11 1127-1139, every 1.92 s, G1 IOC vs G2-4 IPR) are the old NSP
  listener pattern and dropped nobody.
  THE SPLIT IS NOT AN EMULATOR ERROR TERMINATION: YAGPC_ERRTERM_TRACE is on
  for every BCE and prints nothing at any post-OPS 2 split (only the routine
  BCE8 = absent IDP3 timeouts ~12 ms later, on all GPCs).  So the flight
  software itself decides some GPCs had an NSP error: FIOERRLC's other
  sources are FIOBCERR (STAT1 no-go), FIOMSCTO (STAT4 busy/wait: the BCE
  still busy when the MSC checks -- a race an emulator could lose on one
  GPC and not another), FIOMMERR, FIOPSDTO (MSC pseudo time-out).  The NSP
  BCE programs are FIONSPPG (bypassed after the early errors: 'OVERLAID BY
  BCE BYPASS CODE' at FIOBYNC1-8; PSEUDO MDM RETURN WORD paths).
  The split sits ~0.4-0.6 ms before a DEU poll arm (FIODEUPG pc 19974/
  1997d, BCE6/7/8 every 0.48 s); the 12 s = 25 polls, i.e. a 0.48 s cycle
  beating against a 1.0 s or 0.96 s one.  Whether the DEU poll is involved
  or merely coincident is open.
  NEXT INSTRUMENT (eve12 stopped in IPL 23:59; eve13 from ~00:00): RANGETRACE
  '1948c + 19b85 FIOBCERR + 19b9d FIOMSCTO + 19bbc FIOMMERR + 19bff FIOPSDTO,
  400000 lines, from own t=600 s' and TIMEOUT_TRACE_PE widened to 20-23 (RECV
  ARM on the FF buses).  At the next split, which entry each GPC took names
  the error kind; R1/R3 there give the BCE and IOQE.
- eve13 LOSS, 00:19:42 (GPC4, then GPC3 00:20:28): THE ERROR KIND IS AN MSC
  TIME-OUT.  stall/errsrc.py <log> <after_s> decodes splits + FIOERRLC
  entries.  At the fatal split 1163.9476 (G1,G4 IPR vs G2,G3 IOC) only G1
  (BCE22) and G4 (BCE20+22) entered FIOMSCTO (19b9d) for IOQE 905a, the NSP
  cyclic read; G4 then failed itself (R1=0014 = BCE20, R7=19dc7).  At
  1151.948 ALL FOUR took that same FIOMSCTO, so nothing split.  And MSC
  time-outs are ROUTINE on every GPC: eve13 FIOMSCTO by IOQE 6764 x4938,
  6772 x4936, 905a x1611, 904c x1239, 6780 x1239, 678e x202, 90c4 x170 ...
  -- listener BCEs on BCE20-22 (masks exclude the bus the GPC commands)
  still busy when the MSC's wait ends.
  CAUSE CANDIDATE, ALREADY IN THE LEDGER: #50 (CONFIRMED) -- our 2 ms
  receive-timeout floor overrides FCMINIOP's MTOs; eve13's arms show every
  BCE20-23 receive loaded mto=2 (33 us) and run at timeout=2.00 ms, 60x.
  #52 (run u2) found YAGPC_RECV_FLOOR_US=0 safe and faithful in one GPC but
  not a fix for the DK holds -- a different claim.  The floor stays 2 ms in
  these runs because --bce-network MEDS2 keeps it (run.c:526/669 zero it
  only for in-process models).
  TEST (from eve15, eve14 stopped in IPL ~00:23): supervisor ENV adds
  YAGPC_RECV_FLOOR_US=0, everything else unchanged.  Predict: routine
  FIOMSCTO on 6764/6772/... vanish, no 12 s splits, no class (b) losses.
  If the DK buses (MTO 5 ms, networked MEDS2) misbehave, the floor may need
  to be per-bus (networked buses only) rather than zero.
- THE MSC WINDOW FOR THE NSP READ (flight source, via search agent 00:31):
  FIONSPPC (FIOADCNS.asm:912-925) starts FIONSR11/31 on buses 20/22 and
  branches to the generic FIOMCNTL (FIOMCNTL.asm), which does NOT wait on
  indicators: it @RAWs with the MSC's own bit in the mask -- a pure delay --
  then looks ONCE (FIOMCKIO @LI 0 / @RAW / @B FIOMTOUT, :182-187).  Count:
  TIIC0024 DC Y(141) (FIOCBLKS.asm:1487, 16 us units = 2256 us) -> IOQE
  deadline -> time-to-go 71 (x16/33) -> +FIOMSCDB 3 -FIOMPT1 4 = 70 ->
  70 x 33 us = 2.31 ms, then one look.  Bypassed commander (FCMBCEMD.asm
  overlays #DLYI 21/#DLYI 75, or #DLYI 109 for the FF1 return word):
  108-121 x 16.5 us = 1.78-2.00 ms + overhead ~2.0-2.2 ms -- A 0.1-0.4 ms
  MARGIN EVEN ON THE VEHICLE.  Bypassed listener: #DLYI 0s then #WAT, ~0.1
  ms -- unless it sits in a receive, which under our 2 ms floor alone
  exceeds the window (eve13's FIOMSCTO masks were exactly the LISTENED
  buses).  Rate: DUPNSP every 0.160 s (TIME_DUM, ZPRIOTIM.hal:296).  12 s:
  MEDS DK collection on NSP phase cycles every 0.48 s (AIESIP.hal:411-415)
  against DCDDOW's 1 s data cycle (frame count 0/25) -> LCM 300 frames.
  So which GPCs miss the look at the 12 s phase is decided by emulator
  timing inside a ~0.1-0.4 ms margin; the zero floor removes the 2 ms
  listener term.  If eve15 still splits, the commander side's #DLYI (16.5
  us) and @RAW (33 us) units and instruction overhead are next.
- eve15 (YAGPC_RECV_FLOOR_US=0) LOSS 00:42:33: GPC2, SAME MECHANISM -- split
  at 1163.9486 (G2,G3 IPR vs G1,G4 IOC), G2 FIOMSCTO BCE20+22 IOQE 905a ->
  count 2 -> self-FTS (R7=19dc7, R1=0016).  Over shared 1140-1215 s eve15
  has as many FIOMSCTO as eve13 (6764 x6160, 6772 x6160, 905a x1555 --
  counts span the run to that time, the window filter did not bind) and
  the same listened-bus masks, plus hundreds of FIOBCERR the floor adds.
  THE 2 ms FLOOR IS REFUTED AS THE CAUSE (its #50 infidelity stands).
  NEW LEAD (00:44): the masks are always within buses 20-22 -- exactly
  MTU_BUS_FIRST..LAST, the buses src/mtumodel.c owns -- never 23; and in
  eve13 commanders armed 1cc90 ~1022 times per bus but listeners armed
  1ccae only 3-48 times: FF listeners mostly never reach their receive.
  CORRECTION (00:47): the #WIX idea is already answered -- ledger #137:
  "PASS does not use #WIX here -- FIOWAIT is #WAT and the MSC starts the
  listener directly" (FIOADCCL rebuilds the PC table to FIONSL11/FIOMTUL1).
  So why FF listeners are still busy at the MSC's look is OPEN.  Next
  instrument: YAGPC_BWTRACE on BCE20-22 (Busy/Wait edges per GPC) against
  the FIOMSCTO RT lines, default floor restored.
- ROOT CAUSE CANDIDATE AND FIX (00:48, UNCOMMITTED until the gate passes):
  in eve13 the BCE20-22 RECV ARM lines STOP at shared 1140.9 (OPS 2) on
  every GPC -- no budget in that trace (iop.c timeout_trace_pe/_from only)
  -- and before it listeners armed the MTU read 16x on BCE21 but ~1x on 20
  and 22, the NSP buses.  iop_bce_receive: a transmitter-disabled BCE on a
  sync-marked bus (18-22) 'waits indefinitely; the timer starts when the
  command arrives', and only a command at its own IUAR ends the wait
  (iop.c ~1839).  src/mtumodel.c echoed a command to listeners ONLY for the
  MTU read (0x24C26); every other command on 20-22 -- the NSP's IUA-10
  reads included -- set echoPending false.  So NSP listeners (FIONSPPG
  FIONSL11/31, #RDS/#RDLI) waited forever, the MSC's single look found them
  busy on every GPC every cycle (thousands of FIOMSCTO), and at the 12 s
  phase the look came out differently per GPC.  Class (b) losses appeared
  with #146 (deaa3bad0), which narrowed the echo from 'any IUA 10' to the
  MTU read.  FIX: echo EVERY command to listeners (a listener ignores other
  IUAs, so the IUA-8 listen command is harmless); the data reply stays
  MTU-read-only (count 0 = silence otherwise).  Single GPC unaffected
  (echo only for named readers r != commander).  Build 00:48:39; gate
  echo-regress (PORT_BASE 6900) running; eve16 (port 26500, 00:49:05) runs
  the fixed build with YAGPC_BWTRACE on BCE20-22 and the default floor.
  HOST NOTE: /usr/bin/ar (binutils 2.42) now segfaults on ANY object, even
  an unchanged one, into any path; libyaGPC2.a rebuilt with `make
  AR=llvm-ar` (38 objects, no main.o).  The yaGPC2 binary links normally.
- RESULT, eve16 (echo fix 273563b7f, default floor), at shared 1219.5 s
  (79 s past OPS 2), same traces as eve13/eve15:
      FIOMSCTO   eve13 ~14,400   eve15 ~57,000 (whole run)   eve16 4
      splits after 1140 s   eve13 2   eve15 5   eve16 NONE
      FCMSFAIL   eve13 9   eve15 4   eve16 0
  eve16's four FIOMSCTO are ONE NSP read at 1141.8696 on all four GPCs
  together (the OPS 2 transition) -- no split.  FF listeners now reach
  their receives: 1ccae (MTU listener) 48 per bus (eve13: 3/48/3), 1cc2e
  and 1cc68 (NSP listeners) 279 each, plus 1d5xx/1d8xx/1dd24 listeners
  that never armed before.  FIOBCERR stays ~2350 (routine, all GPCs
  alike: absent IDP3 on BCE8 etc.).  No CAM vote.  Earlier runs lost a GPC
  26-170 s after OPS 2 and split every 12 s, so eve16 already has ~6
  split opportunities with none; the long run and later eve* runs are the
  confirmation.  Ledger #145 set FIXED.
- eve16 LOSS 02:42:27 (GPC2; CAM 23 first, then 12/32/42 + diagonal 22),
  shared 6021.07 s, ~4880 s after OPS 2, host quiet (latprobe max 0.15 ms,
  no disturbance), NOT the 12 s mechanism (no splits, no FIOMSCTO).  A NEW
  CLASS, an IPR-handshake slip inside the barrier:
    .069539 G1 IPR, .069539 G4, .069542 G3, .069562 G2 (GPC2 20 us late)
    .069777 GPC2 FCMSFAIL, R7=18fab = FCMISYNC+0117 (the BAL FCMSFINT after
            FCMIPRDL: after the FCMNOISE delay GPC2 re-reads DIA and a set
            member is not showing IPR), R4=8 = its N+1 = GPC3 (CAM 23)
    .069813 G1 null, .069817 G3 null (GPC2's view of G3 null stamped
            pub2=.0697925 -- 15 us after GPC2's FCMSFAIL, inside the 25 us
            barrier, so thread order can let GPC2's read see it first)
    .070170-.070209 G1,G3,G4 second IPR; G2's at .070863; GPC1/3/4 FCMSFAIL
            from FCMSSYNC+0086 (R7=1979c) at .075050 -- they drop GPC2.
  Candidate lever: the barrier delta (YAGPC_BARRIER_US, 25 us) lets one GPC
  lag its peers by up to 25 us; real GPCs lag microseconds.  Log note: eve16
  yaGPC2.log reached 2.19 GB in 2 h, 16.4 M of 29 M lines BW (the BCE20-22
  Busy/Wait trace, no longer needed); RANGETRACE used 43k of 400k.
