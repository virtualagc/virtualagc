This directory contains `yaGPC2`, a C-language emulator for the AP-101S CPU (the Shuttle GPC). It began as a fork of `yaGPC` — itself a byte-for-byte-faithful C port of `gpc run`, a mode of the Javascript program `gpc` from the `nsts-sim-gpc` repository — but unlike `yaGPC`, `yaGPC2`'s explicit purpose is to **fix** the bugs and omissions it inherited from `gpc`/`yaGPC`, not to reproduce them. See `problems.md` for the full list of bugs found and their fix status.

`yaGPC2` also aims for output parity with a separate, independently-developed HALMAT bytecode interpreter, `yaHALMAT2` (`../yaHALMAT2/`) — specifically, byte-identical `WRITE`/`FILE` output for the same compiled HAL/S program. (An earlier goal of also matching `yaHALMAT2`'s command-line-option surface was considered and dropped as impractical; `yaGPC2` uses its own command-line conventions, inherited from `yaGPC`/`gpc run`.)

There is one deliberate, exact exception to that. `yaGPC2` supports real-time
wall-clock pacing for `TASK`/`SCHEDULE`/`WAIT` programs through `--time-scale`
and `--pacing`, which match `yaHALMAT2`'s own flags of the same names and
semantics. This is a narrow, intentional overlap rather than a reversal of the
decision above: the rest of the option surface remains `yaGPC2`'s own. See the
`gpc run` / `yaGPC2` section of `tools.md` for the full flag documentation.

This port was created using Claude Sonnet 5, under direction. The initial `yaGPC` port worked the first time it was tried, without modification. All code was written by Claude.

To build:
<pre>
# In Linux, Mac OS, or Windows under MSYS2:
make
</pre>
or
<pre>
# In Windows:
nmake /v NMakefile
</pre>
To use, get `yaGPC2` or `yaGPC2.exe` into your `PATH`, and simply replace the commands "`gpc run ...`" that you would otherwise use with "`yaGPC2 ...`".

Example: Consider the HAL/S program
<pre>
 HELLO: PROGRAM;
  DECLARE I INTEGER;
    DECLARE POOKIE CHARACTER(20);
    DECLARE MY_NAME CHARACTER(20) INITIAL('RON BURKEY');
    DECLARE INTEGER, J;
    REPLACE PRINTER BY "6";
    WRITE(PRINTER) 'THE BEGINNING';
    DO FOR I = 1 TO 5;
       WRITE(PRINTER) I, 'HELLO, WORLD!';
       DO FOR J = 2 TO 8 BY 2;
          WRITE(PRINTER) '     ', J, MY_NAME||' SAYS ISN''T THIS FUN?';
       END;
    END;
    WRITE(6) 'THE END';
 CLOSE HELLO;
</pre>
Compiling, linking, and then running with `gpc run` gives the following results:
<pre>
&gt; <span style="color: brown">HALSFC HELLO.hal -o HELLO.obj --test --force --clean --archive</span>
&gt; <span style="color: brown">lnk101 HELLO.obj -o HELLO.fcm --json-symbols HELLO-lnk101.json</span>
&gt; <span style="color: brown">gpc run --interactive --no-trace --no-verbose --symbols HELLO-lnk101.json HELLO.fcm</span>
THE BEGINNING
          1     HELLO, WORLD!
                    2     RON BURKEY SAYS ISN'T THIS FUN?
                    4     RON BURKEY SAYS ISN'T THIS FUN?
                    6     RON BURKEY SAYS ISN'T THIS FUN?
                    8     RON BURKEY SAYS ISN'T THIS FUN?
          2     HELLO, WORLD!
                    2     RON BURKEY SAYS ISN'T THIS FUN?
                    4     RON BURKEY SAYS ISN'T THIS FUN?
                    6     RON BURKEY SAYS ISN'T THIS FUN?
                    8     RON BURKEY SAYS ISN'T THIS FUN?
          3     HELLO, WORLD!
                    2     RON BURKEY SAYS ISN'T THIS FUN?
                    4     RON BURKEY SAYS ISN'T THIS FUN?
                    6     RON BURKEY SAYS ISN'T THIS FUN?
                    8     RON BURKEY SAYS ISN'T THIS FUN?
          4     HELLO, WORLD!
                    2     RON BURKEY SAYS ISN'T THIS FUN?
                    4     RON BURKEY SAYS ISN'T THIS FUN?
                    6     RON BURKEY SAYS ISN'T THIS FUN?
                    8     RON BURKEY SAYS ISN'T THIS FUN?
          5     HELLO, WORLD!
                    2     RON BURKEY SAYS ISN'T THIS FUN?
                    4     RON BURKEY SAYS ISN'T THIS FUN?
                    6     RON BURKEY SAYS ISN'T THIS FUN?
                    8     RON BURKEY SAYS ISN'T THIS FUN?
THE END

*** HAL/S PROGRAM HALT (SVC 0)
</pre>
Running it instead with `yaGPC2` produces byte-identical output (this particular example doesn't happen to exercise any of the bugs `yaGPC2` fixes relative to `gpc`/`yaGPC` — see `problems.md` for programs that do):
<pre>
&gt; <span style="color: brown">yaGPC2 --interactive --no-trace --no-verbose --symbols HELLO-lnk101.json HELLO.fcm</span>
THE BEGINNING
          1     HELLO, WORLD!
                    2     RON BURKEY SAYS ISN'T THIS FUN?
                    4     RON BURKEY SAYS ISN'T THIS FUN?
                    6     RON BURKEY SAYS ISN'T THIS FUN?
                    8     RON BURKEY SAYS ISN'T THIS FUN?
          2     HELLO, WORLD!
                    2     RON BURKEY SAYS ISN'T THIS FUN?
                    4     RON BURKEY SAYS ISN'T THIS FUN?
                    6     RON BURKEY SAYS ISN'T THIS FUN?
                    8     RON BURKEY SAYS ISN'T THIS FUN?
          3     HELLO, WORLD!
                    2     RON BURKEY SAYS ISN'T THIS FUN?
                    4     RON BURKEY SAYS ISN'T THIS FUN?
                    6     RON BURKEY SAYS ISN'T THIS FUN?
                    8     RON BURKEY SAYS ISN'T THIS FUN?
          4     HELLO, WORLD!
                    2     RON BURKEY SAYS ISN'T THIS FUN?
                    4     RON BURKEY SAYS ISN'T THIS FUN?
                    6     RON BURKEY SAYS ISN'T THIS FUN?
                    8     RON BURKEY SAYS ISN'T THIS FUN?
          5     HELLO, WORLD!
                    2     RON BURKEY SAYS ISN'T THIS FUN?
                    4     RON BURKEY SAYS ISN'T THIS FUN?
                    6     RON BURKEY SAYS ISN'T THIS FUN?
                    8     RON BURKEY SAYS ISN'T THIS FUN?
THE END

*** HAL/S PROGRAM HALT (SVC 0)
</pre>

### Running more than one GPC

An orbiter carries five General Purpose Computers, and `--gpcs` runs any
combination of them in one process, one thread each:

<pre>
yaGPC2 run --gpcs 1,2 ...        # also "1", "1-3,5"
</pre>

They share the vehicle's hardware — two mass memory units, one master timing
unit, the display units, one set of bus sockets — because that is what the
spacecraft has; what each computer owns privately is its discrete channel, its
identity, its pacer and its intercomputer bus. `--gpc-id <n>` remains the
single-computer spelling, and a GPC that is not named is simply not there: its
discrete channel answers nobody and its neighbours see it as absent, which the
flight software already reads as halt/standby/dead.

`--interactive` and `--debug` drive one machine from stdin and are refused with
more than one.

Each computer paces itself to the wall clock, which keeps the group roughly
together but says nothing about how far apart they drift in *simulated* time.
That matters because the flight software's synchronisation programs spin on the
inter-GPC discrete lines with a 3.85 ms timeout measured in the GPC's own time,
and a miss votes the offending computer out of the redundant set — so a
fail-to-sync caused by the host's scheduler would be indistinguishable from a
flight-software defect. A barrier therefore holds any machine that gets more
than `YAGPC_BARRIER_US` microseconds of simulated time ahead of the slowest
(default 200; `0` disables it). Holding is normal and costs nothing measurable;
the run's closing report gives the number of holds, the seconds spent in them,
and the number *abandoned* — a hold given up on because the machine being
waited for had stopped rather than merely fallen behind, which is the number
worth looking at. The runs verified below used `YAGPC_BARRIER_US=25`, which is
also what `simulatePASS.py` sets.

#### Where it stands (2026-09-13)

Two-, three- and four-computer redundant sets form, hold lockstep through the
OPS 2 transition with no votes or overlay errors, and bring OPS 2's UNIV PTG
page (major mode 201) up on screen, both with the in-process display model and
with real `MEDS2.py` displays over `--bce-network`. The things that had to be
fixed on the way, each recorded in `gpc-causes.py`:

- **#139** — the set dissolved about 31 s into the OPS 2 transition because a
  mass-memory listener error-terminated. Mass-memory reads now take about 1 ms
  (`YAGPC_MMU_READ_LATENCY_US`), a BCE's latched word keeps its command-sync
  type, and a commander's own command echo replaces its stale latch.
- **CRT1 must go to the first computer in the NBAT.** Given to another, no
  OPS 2 page ever appeared; the earlier scripts gave CRT1 to GPC3 (commit
  a526004e8).
- **#141** — every fail vote reaches the CAM, including one set and cleared
  within a few milliseconds, and each computer's Computer Fail (the CAM
  diagonal) is published as discrete register 5.
- **#142** — the timing unit's time of day includes the time a GPC spent held
  in HALT, so PASS's GMT matches the real time of day.
- **#143** — several computers against real network displays: every datagram
  on buses 1-23 is fanned out to every computer that uses the bus, as a real
  bus would carry it.
- **#140** — five computers: GPC4 fails itself out on a timing-unit
  transaction that four handle cleanly. Real, but deliberately out of scope;
  the target is four PASS computers, the fifth being the BFS machine.

`../discretePanel/simulatePASS.py` launches one to four GPCs together with the
crew station (displays, keyboards, GPC panel and, with more than one computer,
the CAM) and prints the switch-and-keyboard procedure for them.

Diagnostics added for this work, all env-gated and off by default:
`YAGPC_SYNCTRACE` (3-bit sync codes per neighbour, with the driven mask),
`YAGPC_BUSCENSUS` (transactions per computer per bus),
`YAGPC_RANGETRACE_GPC` (restrict the range trace to one computer) and
`YAGPC_ICCTRACE` (intercomputer-bus command words). The range trace's line
budget is a file static shared by every machine, and its `afterSec` gate is in
each machine's *own* simulated time — both silently return nothing for a
later-starting computer.

Method warnings, each of which cost a round: a trace count is meaningless if
the budget truncated it; an entry count is not a barrier count; and a
suspicious register value should be checked against TFCVT's constant table
before it is treated as evidence (0x088 is TCVTSVCI, not a mask). See
`gpc-causes.py` #110, #117 and #118.

#### Where four computers' CPU goes (measured 2026-09-14)

A four-GPC, two-CRT `simulatePASS.py` run to OPS 2 uses about 350% of a core in
`yaGPC2`: each GPC thread about 85% (65% user, 20% system) and the bus transmit
thread about 10%. Four options exist for measuring it, each defaulting to the
earlier behaviour, and a `pacing:` line on stderr states their values for any
multi-GPC or `--real-time` run:

- `--rt-min-sleep-ms <ms>` (default 2): the pacer sleeps off a lead over the
  wall clock only past this.
- `--rt-idle-poll-ms <ms>` (default 1): the wait-state loop's sleep.
- `--barrier-us <us>` and `--barrier-spin-us <us>`: override
  `YAGPC_BARRIER_US` and `YAGPC_BARRIER_SPIN_US` (else 200 each).

**None of them reduces CPU.** Measured per thread from `/proc` over 240 s of
OPS 2: defaults 356%, `--barrier-spin-us 20` 348%, `--barrier-spin-us 0` 352%,
`--rt-idle-poll-ms 4` 349%, `--rt-min-sleep-ms 10` 348%. In OPS 2 no computer
ever enters a wait state, only the machine furthest ahead sleeps in the pacer
(about 34 s in 240), and barrier holds end while still spinning whatever the
budget. The time is in the work itself: about 0.75 million instructions a
second per GPC (1.32 µs simulated each); `ap101_exec1` about 36% of a core; bus
service about 25% (`bcenet_framer_flush_tick` every `BUS_SERVICE_US_DEFAULT` =
2 µs simulated, about 205,000 calls a second, each a `poll()` over some 28
sockets at 315-433 ns); `mode_switch_held()` about 9%, because it calls
`discretes_poll_one()` -- an unconditional non-blocking `recv()` (115 ns) plus a
clock read -- before every instruction; barrier and step overhead the rest.
The savings available are code, not settings: gate that per-instruction receive
(while still seeing pulses one datagram at a time) and service the buses less
often (a BCE samples its MIA at most every 16.5 µs). `perf` is not available on
the host that measured this (`kernel.perf_event_paranoid=4`).

#### When the crew panel goes quiet

A running computer does not halt because the crew panel stops talking. If its
mode bits go stale (older than `DISCRETES_STALE_SEC`, 1.5 s) while it was last
heard in RUN or STBY, it keeps that position and logs `MODE: crew panel silent
N s; keeping RUN (held after 60 s)`; only after `YAGPC_DISCRETES_HOLD_SEC`
seconds of silence (default 60) is it held (`holding the CPU until it is
heard`), and it is released when the panel is heard again. A computer that has
never heard a panel still starts held. `YAGPC_HELDTRACE=1` logs every change of
a machine's held state with register A's value, the driven mask and the age of
each mode bit. The cause was a saturated X server stalling `panelO6.py`'s
publishing, which had halted every running GPC at once (`gpc-causes.py` #147).

#### Time, the timing unit and the intercomputer buses (2026-09-28)

**The master timing unit is one box on one clock.** It used to take its time
from whichever computer was reading it, so its three accumulators were really
three computers' clocks, a millisecond apart (#213). It now runs on the
vehicle's shared clock. The time a computer spent held in HALT goes into the
GMT it reports and not into the mission accumulators, which count only while
the vehicle runs (`mtu_fill_time` keeps `us` and `epochUs` apart).

**It reports time in eighths of a millisecond, as the real unit does.** The
milliseconds field is in 0.125 ms units and PASS uses all thirteen bits
(`FPMMTUFX`: `MH R4,FPM125`). The model used to truncate to whole milliseconds.
PASS resets its clock from the unit every 960 ms (`FPMMTURM`), so the discarded
fraction became a step in the vehicle's clock: the set's minor-cycle grid
walked +1/3, +1/3, -2/3 ms with a period of 2.88 s. About one time in a hundred,
a computer joining the set then issued its first `SCHEDULE AT` just before a
boundary instead of just after it, took one SIP too many and was voted out
(#259). Fixed in `fc482e01a`; 452 joins since, none failed. On the TIME
display (SPEC 2), MTU ACCUM 1, 2 and 3 now equal GPC time, with no down
arrow, and GMT matches the real time of day.

**A word on a bus is delivered by simulated time.** On the timing unit's buses
(14-23) a word becomes available when the reader's clock reaches the time it
was put on the wire (#254). The intercomputer buses (1-5) now follow the same
rule, `YAGPC_ICC_TIMEGATE`, on by default since `128183909` (#260). Without
it, 21% of intercomputer transfers reached their reader before they had been
sent, by up to 29 µs at the default barrier and up to 201 µs at 200 µs. With
it, none does, and rate, joins and stress runs are unchanged. The end-of-run
`icc: bus N read by GPCn` line counts the transfers "read before they were
sent", which is how to check.

**Seven behaviours have been the default since 2026-09-26**, after validation
on the four-computer three-CRT vehicle, the five-computer acid test and a
watched run (#249, #250). Each still reads its variable, and `=0` (or `off`,
`no`, `false`) restores the old behaviour for a measurement:

- `YAGPC_FC_MDM`: the listener echo rule, the wire pacing on the shared
  clock, the accumulators on the shared clock, and listen-mode on buses 14-17
  (#219), which were never in the mask and so were served once every 40 ms
  instead of every 33 µs.
- `YAGPC_FC_SENSORS`: answers the sensor reads on the timing unit's string.
  Without it the unit is bypassed in a five-computer ascent. This isn't the
  unit's own fault: `FCMRTBLE` groups the NSP with the MTU, and `FCMBCEMD`
  bypasses the whole string when the sensors on it stop answering.
- `YAGPC_FC_ANY_IUA`, `YAGPC_FC_ANSWER_UNNAMED`, `YAGPC_MTU_ECHO_EXPIRE`
  (a command word passes once and does not wait for a late listener, #247),
  `YAGPC_MTU_LOCKED` and `YAGPC_MTU_WIRELOG` (the delivery by simulated time
  above).

The regression gate caught these once already. When the MDM work first made
three of them unconditional, the default gate took four fail votes at
t=1914. They went back behind the switch until they had been validated.
`BST_I` on an illegal BCE opcode (BCE Principles of Operation 3.4.7) was
left unconditional; it was measured inert, with zero occurrences in that
gate's log.

The wire pacing had indexed on `head`, the unit's reply cursor, which only
`mtu_fill_time` resets, so listeners lost their data word. Before the fix,
2,240 command syncs against 8 data words at `FIOBYNC3+4`, 1,560 error
terminations and 3 votes; after, 2,352 against 1,176, 51 errors and no votes.
One source of unanswered reads remains unexplained: a device at IUA 13 on
bus 24 is read about 14,000 times a run and never answers, 99% of all
unanswered receives (#220).

`../discretePanel/mtuscore.py` scores a run for the timing unit and the set
from one place: votes with their times, the model's counters, and the six
`FIOPRMPG` bypass slots read out of a capture. More than one measurement of
#210 was voided because two arms had been scored by different means.

A method warning: `YAGPC_RECVWORD_TRACE` changes the outcome it is meant to
observe. Six sensor-answering runs split exactly by whether it was on: 4, 6,
6 and 6 bypass slots live on GPC1-GPC4 without it, 0, 0, 0 and 0 with it.

#### Design note: devices the vehicle does not have (not yet asked for)

An idea of the owner's, recorded so that it is not lost: skeleton models for
the peripherals PASS reads but this vehicle lacks, each answering with
plausible data at first and growing later, so the buses carry traffic of the
right kind and quantity. `fc-bus-survey.py` already gives the specification:
75 commanded reads across the bus programs, 37 answered and 38 not. The
unanswered ones are:

| Device | Reads |
|---|---|
| SRB MDMs (IUAs 6, 9, 15, 18) | 12 |
| FIOPFC15-19 on the FF/FA MDMs | 8 |
| EIUs (IUAs 17, 23, 24) | 3 |
| Nose wheel steering | 3 |
| IMUs | 2 |
| Payload signal processor | 2 |
| Payload data interleaver | 2 |
| Launch data bus | 2 |
| GPS | 1 |
| MCIU | 1 |

What the failures on the way to the current timing unit say such models must
get right:

1. **Zero is a reading, not a default.** Answering the MDMs' A/D BITE
   reference channels with zeros told PASS that every converter in every
   forward and aft MDM was dead. PASS isolated them all exactly as designed,
   storing 115,128 stopping instructions into the bus programs.
2. **Symmetry beats accuracy.** A device that answers some computers and not
   others breaks the redundant set; one that answers none merely commfaults a
   string, which the flight software is built for. So a model is a
   vehicle-level object on the shared clock, never a per-computer one.
3. **Delivery is the hard part, not the data.** Five listener-delivery designs
   failed (#210). Solve delivery once, centrally, with wire timing on the
   shared clock, rather than in each device.
4. **Answer only an armed receive.** A `#CMDI` that sets a listener's IUAR is
   not a read, and `FIOHIBAD` is a read of a channel that is not there, which
   PASS branches to on purpose to stop a BCE. `iop_bce_armed_words` tells them
   apart.
5. **The wire has a capacity.** A flight-critical bus carries about 940
   commands a second in OPS 1. At 33 µs a word, a reply must be the length
   actually armed for: a guessed 64-word reply took 2.1 ms against a 1 ms
   budget.
6. **Start with GPS**, not nose wheel steering, which cannot be exercised
   without simulating a landing. `FIOGPSPG` is resident, so its traffic runs
   from the first IPL. It is bidirectional (`FIOGPSRD` X'00026C5F' MDM
   transmit, `FIOGPSWT` X'00022C5F' MDM receive, card 11 channel 2). It has
   three units, FF01-03, one per string, so it drives redundancy management.
   It issues the listen command, and its 32-word payload is a realistic bus
   load. Scripted position and velocity is the right content. The check is
   SPEC 055, GPS STATUS, in OPS 1, 2, 3, 6, 8 or 9, read as text with
   `NSTS_ANNOUNCE_ROWS=all` and `screenwatch.py`. The traffic starts in OPS 0
   but the display doesn't, so the check needs an OPS transition.

### The regression gate

Most of `yaGPC2`'s defects have been caught not by the unit tests but by one
long run: boot the real PASS flight software from a mass-memory volume, let it
reach GPC MEMORY, and compare the device models' counters. The harness that
drives it (`headless-gpcmem.sh`, roughly seven minutes unattended) lives with
the flight-software workspace rather than in this repository, since it needs a
built volume; what matters here is the shape of the check.

**Only half of the counters are a gate** (`gpc-causes.py` #124). The harness
cuts the run off after a fixed *wall* duration, so:

- **Event-driven counters are the gate, and must match exactly** across runs
  and builds: the mass memory's commands, blocksRead, wordsOut, wordsTaken,
  wordsLost and position; the display unit's formatFills, resets, modeStatus
  and ipled; and every error counter, which should be zero. A healthy run
  shows exactly one `MODE: IPL` line.
- **Periodic counters are not a gate**: the display unit's commands, fills,
  timeFills, displayFills, medsXfers, polls, wordsIn and wordsOut, and every
  timing-unit counter. They count how much simulated time fitted into the wall
  duration, so an exact hit is luck and a small miss is weather. A *higher*
  number is not a regression.

Measured 2026-09-12 over a 420-second run:

<pre>
mmu1: 56 commands, 431 blocksRead, 220731 wordsOut, 220011 wordsTaken, 720 wordsLost
deu:  ~1848 commands, 375 fills, 569 timeFills, 367 displayFills, 8 formatFills,
      575 polls
mtu:  ~7890 commands, 5421 timeReads
</pre>

with the scripted keystrokes landing at `poll=247 simt=133.704 s wall=120.0 s`.
The `simt` figure and the mmu1 line reproduce exactly; the deu and mtu figures
are one sample. Four runs on two builds on 2026-09-13 gave 1848, 1845, 1844
and 1844 deu commands, with every event counter identical and the keystroke at
`simt=133.704` in all four. (Figures quoted before 2026-09-12 came from a run
that IPLed twice, `gpc-causes.py` #93: 503 blocksRead and `simt=135.520`, the
1.8 s the spurious IPL cost.)

Compare against a same-day control run of the committed build, not against
these numbers: the point of the gate is that a run of the current tree and a
run of the tree being compared against are made the same afternoon. The timing
unit's `lastTime` is the time of day at which the run was stopped and always
differs between runs.

Three more things a tester needs to know:

- **The unit tests are built only by `make test`.** Plain `make`, or
  `make -j8`, builds the emulator without them. `test_mtumodel` once printed a
  hard-coded "23/23" over sixteen checks; together the two hid a live defect
  behind a passing run.
- **The five-computer acid script ends in OPS 1**, not OPS 901, which is only
  a step on the way. SPEC 2, the TIME display, isn't valid in OPS 1, so in that
  configuration the timing unit's accumulators have to be read on CRT3 from
  GPC5, which stays in OPS 0.
- **With four computers in OPS 201, SPEC 2 works directly.**
  `../discretePanel/examples/4gpc-mtu-time.script` brings it up after the
  start-up. Run it with `NSTS_ANNOUNCE_ROWS=all` and read the frames with
  `../discretePanel/screenwatch.py`.
