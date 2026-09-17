# Four GPCs in a real redundant set: G3, and GPC-to-GPC loading

Written 2026-09-16 evening, for the morning.  The ledger
(`gpc-causes.py`, entries #151-#158) holds the evidence; this file holds only
the plan and the order to do it in.

## Where we got to

A whole evening was spent chasing GPCs losing sync in a four-computer OPS 201
set, and the most useful thing found was that **the configuration we were
testing is not one the vehicle flies**.  OPS 2 on orbit is a two-GPC set.  Four
computers in one redundant set is CONFIG 1 (ascent) or CONFIG 3 (entry).  Our
script asked for memory configuration 2 while assigning buses the CONFIG 3 way.

Every sync measurement we have -- #153's I/O asymmetry, the join-delay
distribution, the timer-sync failure -- was taken on that mixture.  They may
still be right.  We do not currently know.

Two defects were found and fixed along the way (#152, both halves), and four
hypotheses were refuted, three of them Claude's.  #154 went from "confirmed"
back to "open" within an hour of being written.

## To do, in order

1. ~~**Run `examples/4gpc-g3-startup.script`.**~~  DONE, unattended, 21:14 on
   2026-09-16 -- and it did NOT form a working set.  See **#158** and "What the
   first G3 run did" below.  The script itself is sound: all four IPLs, all
   fifteen NBAT entries and `OPS 3 0 1 PRO` went in, and all three CRTs kept
   taking fills.  Four GPCs, memory configuration 3, OPS 301, three CRTs.

       python3 simulatePASS.py --gpcs 1-4 --crts 3 \
           --tape ~/workspace/pass-run/OI340700-v44boot.mmv \
           --script examples/4gpc-g3-startup.script --duration 1200

   (a bare tape name is resolved relative to `discretePanel/` and will not be
   found -- give the path)

   Watch the OPS 3 overlay load -- that is the step most likely to behave
   differently from OPS 2, and on the first run it is where things went wrong.

2. ~~**Work out why GPC1 and GPC2 stop**~~  ANSWERED 2026-09-17: **a third
   powered IDP was the variable, not G3.**  With `--crts 2` the same script
   gives a FULL FOUR-COMPUTER SET that holds.  The script now ships in that
   configuration.  What remains open is *why* a third IDP kills GPC2 before the
   set forms -- see #158 and "The third-CRT problem" below.

3. **Re-measure #153 on it** -- a set now holds, so this is unblocked.  Do the computers still diverge in I/O?  The
   counting is a per-GPC tally of non-null sync codes over a few minutes; the
   OPS 201 numbers to compare against are in #153 (SVC 33901 against
   33885/33887/33887, timer/SSIP/IPR identical).

4. **Put simulated time on the `SYNC` trace line.**  `discretes_synctrace()`
   prints `yagpc_monotonic_seconds()` only, and FCOS's 3.85 ms timeout is
   SIMULATED time, so every join-delay figure we have mixes the two.  Until
   this is done, arguments about the timing margin are arguments, not
   measurements.  See #153.

5. **Try GPC-to-GPC loading (freeze dry).**  See below; this is the piece Ron
   asked for specifically.

6. **Only then**, if the set still loses computers, go back to #137 (identical
   I/O between set members) and #107 (the ICC read path).

## The third-CRT problem  --  SOLVED 2026-09-17 (#159)

**A display powered before the NBAT names its commander goes to whoever is
already running.**  USA005350 3.2.15.1: a PASS GPC moded to RUN takes IDPs 1 TO
3 when the common set commands no DK buses.  So with all three powered during
the IPLs, GPC1 alone drove every display while the others idled.  ONE GPC
DRIVING THREE DISPLAYS NEEDS MORE THAN ONE CORE AND A GPC ONLY GETS ONE -- its
emulation is serial, so the host's other sixteen cores cannot help.  Rate fell
to 0.42, the barrier correctly paced everyone to the slowest, MEDS2's WALL-CLOCK
watchdogs began firing against a vehicle running at 0.42, and a set member alone
with an I/O error failed itself out (#137).

**The fix is in `examples/4gpc-g3-startup.script`:** `--crts 3`, `ITEM 14 +3`
giving CRT3 to GPC3, and `idppower`/`majfunc`/`idpload` for IDP3 moved AFTER
`OPS 3 0 1 PRO`.  An 18-minute run gave whole-run rate 0.979 / 0.823 / 0.925 /
0.874 against the two-display baseline's 0.735 / 0.811 / 0.976 / 0.895 -- three
displays now cost nothing measurable -- with zero fail-votes, zero BCE8 timeouts
where early power cost 120, and one dominant commander per display.

### What was refuted, so nobody retries it

| idea | result |
|---|---|
| barrier Delta too small | Delta 200 cut holds by a third; rate did not move |
| host CPU starvation | four threads at 100% of a core, sixteen cores idle |
| the extra MEDS2 process | three processes with IDP3 off: rate 1.00 |
| the `poll()` rate (2 us gate) | measured 3-8% of wall time, not the culprit |

### The profile, and its limits

`YAGPC_PACETRACE=1` now labels each report with its computer.  Steady state in
the FAILING configuration, four machines at the same wall time:

    rate 0.649   exec1 48.42s (20%)   bus service 15.58s ( 6%)   slept 22.46s
    rate 0.413   exec1 74.88s (31%)   bus service 19.12s ( 8%)
    rate 0.210   exec1 15.35s ( 6%)   bus service  6.48s ( 3%)   175.1s written off
    rate 0.040   exec1  2.06s ( 1%)   bus service  1.09s (0.4%)  224.4s written off

`exec1` is ~0.3 us per emulated instruction.  **These categories account for
under 40% of each thread's wall time**; the rest is mostly barrier spinning,
which the pacer does not instrument and which is known not to be causal.  So
the profile rules the poll rate OUT but does not explain where the majority
goes -- that is still open if anyone wants the emulation faster.

### Residual limit, unfixed

A single computer driving three displays still runs at about 0.42.  The real
vehicle concentrates displays on one GPC freely, so that configuration remains
beyond this emulator at real time.  What was fixed is the configuration, not the
emulation speed.  Two candidate levers if it is ever worth chasing:
`YAGPC_BUS_SERVICE_US` from 2 to 10 (worth ~5%, and 16.5 us is the hardware's
own sampling limit per BCE PoO 3.4.1, so it is defensible -- but it needs the
regression gate, since coarser servicing is exactly what produces #137-style
receive timeouts), and moving the socket RECEIVE path to its own thread as
transmit already is (`tx_thread_main`) -- though note the traffic is 12:1 in the
GPC's favour, 113,292 halfwords out against 9,110 in, so the win would be
syscalls rather than data.

## The third-CRT problem  (earlier framing, kept for the timeline)

**Cause found.**  A third display halves the simulation rate, and the set then
loses a computer.  Rate (simulated seconds per wall second): **0.74-0.98 with
two displays, 0.31-0.48 with three.**  Confirmed independently by the SSIP
cadence, 160.0 ms on every computer in a working run against 377-386 ms in a
failing one -- 160 / 0.42 = 381.

It is NOT host starvation: the four GPC threads sit at 100% of a core each on a
20-core machine with sixteen cores idle.  Two things combine:

- **Linear bus cost.**  Four computers on three display buses instead of two is
  1.5x the transactions, and each `sendto` costs about 8 us.
- **The barrier amplifies it.**  It holds a machine 241,300 times a second with
  three displays against 75,800 with two, and for 44% of thread time against
  19%.  A held machine does not advance simulated time.
  Unheld time 56% vs 81%, and 0.40/0.56 = 0.71 against 0.90/0.81 = 1.11 -- a
  ratio of 1.56, which is the linear bus scaling.  So the two together give the
  2.25x observed.

**Why a low rate kills a computer.**  MEDS2's watchdogs are in WALL time --
`POLL_FAIL_MS = 4000`, `IDP_LOST_MS = 2000` -- while the GPCs run in simulated
time.  At rate 0.4 everything a computer does takes 2.5x longer in wall terms,
so those timers fire on far less provocation.  The victim varies between runs
(GPC1+GPC2, then GPC2, then GPC3), which is what a timing failure looks like.

Symptoms that follow rather than cause: GPC1 takes 120 `BCE8` (DK3) receive
timeouts, all `gotAny=1 left=15`, but they total 810 ms in 420 s -- 0.2%.  IDP3
logs `load started` and never `load complete`, taking 5 fills where IDP1 takes
174, so it keeps asserting IPL_REQUIRED.

**Fixes under test**, in order of promise:

1. `YAGPC_BARRIER_US=200` -- simulatePASS forces 25 while the emulator's own
   default is 200, still 19x inside FCOS's 3850 us deadline.  This is the new
   evidence #125 asked for before retuning.
2. `idpload 3` -- the script does `idpload 1` and `idpload 2` and never 3, and
   an IDP that starts unpowered comes up cold wanting a load.  `deuLoad()`
   clears the stuck `iplRunning`/`xfer` state IDP3 is in.
3. Power IDP3 only AFTER the set is formed and CRT3 assigned.  Before the NBAT
   is typed at minute 5, GPC1 holds all three displays (USA005350: a GPC in RUN
   takes IDPs 1 to 3 when the common set commands none), and the barrier paces
   the whole vehicle at its speed.

Variants for all three are in the session scratchpad as `g3-3crt.script`,
`g3-3crt-load.script` and `g3-3crt-late.script`.

### Earlier framing, kept for the timeline



Three runs, and the variable is clear:

| run | CRTs | outcome |
|---|---|---|
| g3-first | 3 | GPC1 and GPC2 both die at the OPS transition |
| g3-census | 3 | GPC2 dies at minute 2; GPC1+GPC3+GPC4 form a healthy THREE-computer set |
| g3-2crt | 2 | **all four form and hold**, ~36,320 issues/min each |

GPC2 dies at about minute 2, but the NBAT that assigns CRT3 to GPC3 is not
typed until minute 5 -- so it is not the assignment, it is the PRESENCE of a
third powered IDP.  #99 quotes USA005350: a PASS GPC moded to RUN automatically
takes control of **IDPs 1 to 3** when no DK buses are commanded by the common
set, and "no check is made to ensure against multiple commanders on the same DK
bus ... Dual commanders should be avoided, as it can result in PASS GPCs
failing-to-sync."  The three-CRT census fits: GPC1 held bus 8 (DK3) with 127,203
transactions where GPC3, the computer the NBAT gives CRT3 to, had 413.

So the likely shape is that GPC1, first to RUN, grabs IDPs 1-3 including the
one GPC2 needs, and GPC2 fails to sync against a dual-commanded DK bus.  If
that is right it is FAITHFUL behaviour being provoked by our IPL order, not an
emulator defect -- and the fix is a crew-procedure one: assign the displays
before the other computers come up, or IPL in an order that does not leave GPC1
holding three.

Worth having, because CRT3 on GPC3 is what would give a dropped-out computer a
keyboard -- the thing every recovery attempt on 2026-09-16 lacked.

## What the first G3 run did

Sync issues per GPC per minute, from the run's own trace:

    min 1-2   GPC1 alone (684, 668)                 the IPLs
    min 3     GPC1 + GPC3 (1300 each)
    min 4     GPC4 joins (1520 / 1520 / 1454)
    min 5     all four (1080 / 310 / 1080 / 1080)
    min 6     GPC3,GPC4 ~4575 each; GPC1 828; GPC2 0
    min 7     GPC1 and GPC2 ZERO; GPC3,GPC4 ~5475
    min 8-20  GPC3,GPC4 steady ~666/min; the others silent

So the two computers that go quiet are **GPC1 and GPC2 -- exactly the two the
NBAT gives mass memory and CRTs to** -- and MM2 was still cycling READY/BUSY
when the run ended.  The suspicion is that they are stuck in the OPS 3 overlay
load.  GPC3 and GPC4 settle into the common-set-but-not-redundant-set rhythm of
#155 (SSIP, I/O complete, null, nothing else), and the CAM ends with one lamp:
21, GPC2 voting against GPC1.

This is one run, ended by its own `--duration`, on entry software that drives
flight-critical buses and sensors this vehicle model may not provide -- and Ron
saw FAx bus faults on all four computers reaching OPS 301 by hand earlier the
same day, which may be the same thing.  It is a starting point, not a verdict
on G3.

## GPC-to-GPC loading: what it is and how it is driven

Recorded in full as **#157**.  Two halves that fit together:

**Freeze dry** puts the overlays into a spare computer.  It is a crew action on
that computer's own `GPC MEMORY` display:

    GPC/CRT <FD GPC> <CRT> EXEC        give the spare a display
    <maj func> GPC MEMORY              its own GPC MEMORY page
    ITEM 45 + <MC> EXEC                which memory configuration to store
    ITEM 46 + <FD GPC> EXEC            naming ITSELF
    ITEM 47 EXEC                       STORE
                                       done when MC reads the stored number

Constraints, from `ARFDPSCO.hal`, and they matter:

- ITEM 46 is refused unless `CZ2B_RS$(TFCMID;) = HEX'0000'` **and** the GPC
  named is the one taking the entry.  So it must be typed on a computer that is
  **not in a redundant set**, and it can only name **itself**.
- ITEM 47 is refused if the entering GPC is in a redundant set or is not in
  OPS 0.
- ITEM 45 is refused unless `CZ2V_GRT_MC` agrees the MC is valid.

**Overlay sourcing** takes them out again, automatically, at the next OPS
transition.  `ARCGPC.hal` searches `DO FOR MEM_SRC = 1 TO 4` where 1 and 2 are
"MF OVL GPC TO GPC" and "PG OVL GPC TO GPC" and 3 and 4 are the same from mass
memory -- **a GPC that holds the overlay is preferred over the MMU**.  The
transfer runs on the **launch data buses 12 and 13**, not the mass memory buses:
`ARC_BUS_DELTA = -6`, commented `LDB BUS 12,13 -- MM BUS 18,19`.  The source GPC
is given the bus on demand (`ASSIGN LDB BUS TO SOURCE GPCS IF REQUIRED`, ICC
message type 3), which is why CONFIG 2 and CONFIG 3 both leave L1/L2 unassigned
in the NBAT.

### What to try

A spare computer is needed, so freeze dry does not fit the four-in-a-set
configuration directly.  The natural experiment is the one the real procedure
does: bring up the set with a computer left out, give that computer a CRT, and
freeze-dry a configuration into it.

- With `--gpcs 1-4 --crts 3`, run the G3 script, then take GPC4 out
  (`RUN -> STBY -> RUN`) so it lands in OPS 0 outside the set.
- `GPC/CRT 4 3 EXEC` to give it CRT3.  **Note:** per #155 a `GPC/CRT` to a
  computer outside the set has never yet worked here, and per #154 the flight
  software marks the DEU offline when it does that.  If the display does not
  come up, freeze dry cannot be driven at all, and THAT is the finding -- it
  makes #155 block a documented crew procedure, not just a display.
- If the display does come up: `ITEM 45 + 3 EXEC`, `ITEM 46 + 4 EXEC`,
  `ITEM 47 EXEC` on GPC4, and watch for MC to read 3.

### What is untested in our model

Buses 12 and 13 are inside `YAGPC_BUS_MAX` (24) and nothing treats them
specially, so under `--bce-network` they ride the framer like any other bus.
**Whether one GPC's LDB transmission reaches the other computers' framers has
never been checked.**  That is worth a direct test before blaming the flight
software for anything: two GPCs, one commanded to transmit on bus 12, and a
look at whether the other's framer sees it.

## Standing warnings

- **`GPC/CRT` to a computer outside the set can strand the crew station.**  It
  cost two runs on 2026-09-16.  Sacrifice a CRT you are not typing on, never
  the last one.  #154.
- **A dark CAM is not proof the vehicle is whole.**  Votes can clear while a
  computer stays outside the set.  Check sync rates or SPEC 6, not the lamps.
  #155.
- **SPEC 6's view of ANOTHER computer arrives over the ICC** and can be that
  computer's absence rather than its state.  #155.
- **`YAGPC_ICCTRACE_MAX=0`** for an unlimited ICC trace; the default 20,000
  lines covers only about 13 minutes of a four-GPC run.
- **`YAGPC_SYNCTRACE=1` costs about a gigabyte every ten minutes.**  Leave it
  off unless the run is about sync.
