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
