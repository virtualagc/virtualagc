# HANDOFF: PASS loads and runs — RESOLVED

Written 2026-08-31; **the question this file was created to hand off is
answered**, and the fix is committed as `bbe9e9dcc`. The account is kept
because the eight excluded theories and the run procedure are still worth
having, and because the shape of the mistake — forty seconds of measurements
taken downstream of the event — is worth not repeating.

The long-form write-up is `problems.md` §8.26.

## 1. What was wrong

PASS IPLed, loaded, started, painted a display and did real cyclic flight I/O
for about 26 seconds of simulated time (t≈73 → t≈101), then sat in `FPMIDLE`
for good: Clock 2, the 25 Hz cyclic clock, stopped and only Clock 1 continued
every 2.097 s. No crash, no fault, no wait state, no hang — the scheduler
simply had nothing left to run.

**The cause was one line in `exec_SVC`.** yaGPC2 saved the SVC's
effective-address extension as `(ea >> 16) & 0xf`; it has to be
`(ea >> 15) & 0xf`. A sector on this machine is `0x8000` halfwords — every
expansion in `cpu.c` is `sector << 15` — and the 16-bit address field's own bit
15 is the "expand me" flag the sector *replaces*, so the four bits that turn
the 16-bit interrupt code back into a 19-bit address begin at bit **15**.
`FPMSVC` settles it: it ORs the nibble into a ZCON as a **DSE**, and `FIOSVC`'s
`LXAR R3,R3` masks the address with `0x7fff` and expands by `dse << 15`. Taken
from bit 16 it arrives **halved** — `0x3832b` was rebuilt as `0x1832b`.

6,387 of 33,961 SVCs in one run come from sector 7, which is where PASS's
applications live. Every one handed FCOS a parameter-list address four sectors
low, inside FCOS's own code. Sector-0 SVCs — all of GPCIPL and the SSL —
round-trip correctly under either formula, which is why this survived every
earlier stage.

## 2. The death chain

1. `FIOSVC`/`FIOINITQ` builds an IOQE out of the "parameter list" at `0x1832b`,
   which is code: `FLGS=b5e2 OPCD=dc0c WDCD=8271 PRI=a2f3 EVNT=9af3`, device
   id 9. `FIOINITQ` copies it faithfully; the list itself is rubbish.
2. `FIOBCD[9]` = `0x0f00`, so the phantom request wants buses 20-23, the FF
   MDMs.
3. `FIOPDISP` toggles those four busy in `TCVTBCEB` (`XST` — an exclusive-or
   store) and enables the BCEs; the device-dependent `CASENTRY` then indexes a
   table with the garbage op code, branches to `0x04081` (unloaded data
   storage) and takes a program check.
4. It is abandoned **before** `ST R2,TCVTSIOM`, so no `@SIO` is ever issued,
   the BCEs never run, `FIOCMPLT` never toggles the bits back, and `TCVTBCEB`
   keeps `0x0f00` forever.
5. `FPMIHPC2`'s wait-queue scan starts a queued IOQE only when all its buses
   are idle, so every later MTU read (mask `0x0e00`, buses 20-22) queues behind
   it — exactly **one IOQE leaked per second**, against a pool of 26.
6. Pool dry → `TCVTIOFP` runs off the end to `0x080ce` → the store to that
   "IOQE"'s `TIOQINDX` at `0x080d6` hits protected code → store protect →
   Clock 2 never re-armed → `FPMIDLE` for good.

Before and after, same headless rig:

| | before | after |
|---|---|---|
| PASS stops | t≈101 s | still running at t=316 s |
| `TCVTBCEB` | `0x00000f00` | `0x00000000` |
| free IOQE pool | 0 | 26 of 26, at t=120 and t=300 |
| I/O wait queue | 25 stranded | 0 |
| Clock 2 | dead after t=98.88 | arming/firing every 39.5 ms at t=320 |
| software clock | — | 61.9 s → 241.2 s over 180 s of sim: 1:1 |
| idle fraction, t=98.00-98.12 | 95.0% | 92.5% |
| DK2/DK3 | time fills only | display fills too |

## 3. How to run it

Four terminals. Every command is one line.

**(a) Clear anything stale.** Do this first, always:

    pkill -x yaGPC2; pkill -f 'discretePane[l]'; pkill -f 'gpcmd.js uni[t]'; pkill -f 'meds --size'; sleep 2; pgrep -af 'yaGPC2|discretePane[l]|electron|gpcmd' | head

It should print nothing. Note this kills the user's own panel too — track your
own PIDs instead when anything of theirs is running.

**(b) MEDS #1 — the GPCIPL menu display:**

    cd ~/donschmidt/nsts-sim-gpc && ./MEDS.sh --size 512 crt1 idp1

**(c) MEDS #2 — the display PASS actually drives:**

    cd ~/donschmidt/nsts-sim-gpc && ./MEDS.sh --size 512 crt2 idp2

**(d) Crew panel:**

    cd /mnt/STORAGE/home/rburkey/git/virtualagc/yaShuttle/discretePanel && python3 discretePanel.py

**(e) The GPC.** Start this BEFORE touching any panel switch:

    cd /mnt/STORAGE/home/rburkey/git/virtualagc/yaShuttle/yaGPC2 && stdbuf -oL -eL ./yaGPC2 run --mmu-model /home/rburkey/workspace/pass-run/pass-ipl.mmv --mtu-model --discretes --bce-network --real-time --gpc-id 1 --no-halucp-svc --max-steps 4000000000 2>&1 | tee /home/rburkey/workspace/pass-run/run.log

It should print `MODE: HALT; CPU held in reset`.

**(f) Then, on the panel, in this order:**

1. mode → **HALT**
2. BFC CRT select → **CRT 1**
3. IPL source → **MM1**
4. press and release **IPL**
5. mode → **STANDBY**

**(g) On MEDS #1**, the GPCIPL menu appears within a few seconds. Key
**ITEM 1 EXEC**. The PASS load starts immediately — you do not need RUN first.

**(h) Wait about 1 minute 25 seconds**, then on the panel: mode → **RUN**.

**(i) Watch MEDS #2.** PASS paints there.

### Why each flag matters

- `--real-time` is **mandatory**. Without it nothing works over the bus at all:
  the transport paces the wire against the wall clock while the GPC times out
  in simulated time, so every reply arrives after its receive has expired.
  yaGPC2 now warns if you omit it (`710ae8dd2`).
- `--mtu-model` answers the Master Timing Unit on BCE 20-22. Without it PASS's
  flight I/O collapses — 5,453 intercomputer datagrams against 81,795.
- `--gpc-id 1` selects the intercomputer bus port; BCE 24 is per-GPC.
- `--no-halucp-svc` stops HalUCP intercepting PASS's own SVCs, whose numbers
  collide with the flight software's (13/14/20 are `FPMSET`/`FPMRESET`/
  `FPMSDERR`).

### Headless, no GUI and no MEDS

Start yaGPC2 **first** — the IPL pushbutton is momentary, so a panel started
first fires the pulse before anything is listening.

    ./yaGPC2 run --mmu-model <vol>.mmv --mtu-model --discretes --bce-network \
        --real-time --gpc-id 1 --no-halucp-svc --port-base 7000 \
        --max-steps 4000000000
    python3 /tmp/claude-1000/deustub.py 7000 6            # DK1, sends ITEM 1 EXEC
    python3 /tmp/claude-1000/deustub.py 7000 7 nokeys     # DK2
    python3 /tmp/claude-1000/deustub.py 7000 8 nokeys     # DK3
    python3 /tmp/claude-1000/drive.py   7000 85           # crew discretes, RUN at 85 s

`drive.py` opens no window; use it rather than `discretePanel.py --script`,
which opens one on the user's display. Always use `--port-base 7000` so an
automated rig cannot collide with a live session on the default 6900.

## 4. What is NOT a fault

- **MEDS #1 goes to POLL FAIL right after ITEM 1 EXEC.** Expected. With BFC
  CRT = CRT 1 you are telling PASS the BFS owns display 1, so PASS masks DK1
  and drives DK2/DK3 instead. Correct behaviour.
- **No "download complete" message from yaGPC2.** There is none on the
  `--bce-network` path; the `deu: load complete` lines belong to `--deu-model`.
- **A frozen DEU image.** `deu_complete_fill` counts a time fill and discards
  it, so the clock never reaches `d->mem`, and a static format refreshed every
  cycle writes identical words.
- **`wordsLost` on the GPCIPL-loader path.** `mmumodel.c:211-214` records that
  the loader takes what it wants and stops; the losses are exact multiples of
  360. The SSL path loses zero because it takes everything.

## 5. Eight theories excluded by measurement — do not re-investigate

Every one of these was tested and ruled out, and every one of them was looking
at t≈98-101, which is the pool draining. The event is at t≈60.

1. **IOQE/TQE free-pool size.** Pools of 25, 28 and 82 entries all stop at
   ≈100 s. Enlarging the pool removes only the store-protect symptom.
2. **The corrupt chain link at `09262`** (file offset `0x11b540` holds `80ce`;
   the neighbours form an exact `+0x12` progression). Patching it — to `9274`
   or to a `0000` terminator, checksum restamped — does not fix the stop.
3. **`AIBGPCLO`'s `SEND ERROR$(6:6)`** ("RUNTIME USED INSTEAD OF PCMMU TIME").
   It appeared only while `--no-halucp-svc` was broken; with the wiring
   restored PASS raises no SEND ERROR at all.
4. **The 24-hour software clock.** Real — `FPMMTURM.asm:457` defaults any GMT
   under 1 day to exactly 24 h, and `--mtu-model` reports GMT from zero — but
   correcting it does not fix the stop, and feeding a true day-of-year makes
   things worse (GPCIPL enters a 0.2 ms timer loop).
5. **The store-protect at `080d6`.** Disappears entirely with a large pool, and
   PASS still stops.
6. **Crew input.** `OPS 1 0 1 PRO` delivered on DK2 *during* the live window,
   while PASS was still polling, changes nothing. (Keying after POLL FAIL
   proves nothing: keys are only delivered inside a poll reply.)
7. **PCT cancellation.** No store clears the cancel bit `0x8000` or the cyclic
   bits `0x00C0` anywhere near the stop; all such writes are PCT
   initialisation at t=74.5.
8. **The TSIP / half-hour time base.** `TCVTSWCH` advances correctly, reaches
   only ~68e6 of the 1.8e9 µs in a half hour, and keeps ticking long after PASS
   goes idle.

## 6. Two map corrections

Both earlier identifications were confidently wrong and misdirected the search:

- The stride-`0x12` table at `090b2` is the **IOQE** table (`TFIOQ`, 18
  halfwords), **not** the TQEs. The TQEs are the stride-6 chain (`TFTQE`,
  6 halfwords) and the EQEs the stride-`0x0a` one (`TFEQE`, 10). So "TQE
  enqueueing stops at t=98.09" was really I/O-queue activity stopping.
- **The CVT base is `0x140`**, anchored by `TCVTCID` (+0x51) reading 1 for
  `--gpc-id 1` and by the PCT/EQE/TQE/IOE free-pool group at +0x0a..+0x0d.
  `TCVTSIPI` is a **fullword**, so every field past it sits two halfwords later
  than a naive parse of `MLIB80/TFCVT.asm` puts it. PCTs are at `0x0827c`,
  stride `0x32` (50 halfwords = `TPCTLNTH`).

Useful field offsets, all confirmed against `MLIB80/`:

    TFPCT   50 hw   NXT+0 PRI+1 STOR+2 PDE+3 PSW+4..7 GPR0+8 DSE+42
                    OPRI+44 ERR+45 ECNT+46 FLGS+0x2f WAIT+0x30 IOPP+0x31
    TFTQE    6 hw   NXT+0 PCT+1 TOXH+2..3 TOXM+4 FLGS+5
    TFEQE   10 hw   NXT+0 PCT+1 OPS+2..3 VAR1..5+4..8 TYPE+9
    TFIOQ   18 hw   NXT+0 PCT+1 SELF+2..3 MNTM+4..5 BUFA+6 FLG1+7 FLG2+8
                    PRI+9 ICNT+10 EVNT+11 DVID+12 OPCD+13 WDCD+14 STAD+15
                    OMSK+16..17
    TFCVT  100 hw   base 0x140:  PCT+0 OLD+1 NEW+2 TTQE+3 IOA+4 IOW+5
                    PCTP+0x0a EQEP+0x0b TQEP+0x0c IOFP+0x0d STOR+0x0e
                    TEQE+0x0f  BCEB+0x12  SIOM+0x14  CZ1+0x50 CID+0x51
                    SWCH+0x54 SWCM+0x56

## 7. Techniques worth reusing

- **`YAGPC_SNAPSHOT=<t1>[,<t2>...]:<prefix>`** writes the whole of main storage
  to a file the first time simulated time passes each of those seconds. A raw
  image is what lets the FCOS control blocks be read **offline with a script**
  instead of guessed at from a trace, and it is what made the leak visible as a
  table. This is the first thing to reach for.
- **Trigger on state, not on time.** `YAGPC_TRACETRIG=<addr>:<val>:<count>:<f>`
  arms a per-instruction trace when a fullword takes a value. The event here
  moved by a third of a second between runs, so a fixed time window kept
  missing it.
- **`YAGPC_EATRACE=<nia>[,...]`** gives the effective address a named
  instruction computed and what is there. A register dump says *what* a wild
  branch went to; only the EA says *where the address came from*. Note the NIA
  during EA computation is already the *next* instruction's address.
- **Finding FCOS control-block tables.** Search the image for linked chains of
  any stride — a record whose first halfword points at the next. Guessing
  locations failed twice; this works, and the strides are the DSECT lengths in
  `MLIB80/TF*.asm`, which can be computed directly from the `DS` chains.
- **Load-block checksum.** Do NOT assume the DMA count is the block length.
  Find the length by searching for the L satisfying the flight software's own
  invariant, `sum(hw[0..L-2]) == hw[L-1]` (`FCMINSSL.asm:844-861`).

## 8. Warnings learned the hard way

- **Commit before reverting.** `git checkout -- src/ageharness.c` destroyed
  hours of uncommitted work. It was recovered only because the session
  transcript at `~/.claude/projects/<project>/<session-id>.jsonl` records every
  Edit's `old_string`/`new_string` and every Bash heredoc.
- **Never `pkill` by a broad pattern.** `pkill -f 'discretePane[l]'` killed the
  user's own crew panel mid-session. Track your own PIDs and kill by PID.
- **Check whether a test can even detect the thing** before asking someone to
  run it. The crew-input test was proposed in a form that could not have
  worked — keys are only delivered inside a poll reply, so keying after POLL
  FAIL proves nothing.
- **Stop measuring at the symptom.** Eight theories were tested at t≈98-101
  before anyone asked what was set up at t≈60 with a 27-second horizon. When
  every measurement at the failure point comes back clean, the event is
  upstream.

## 9. Commits

    bbe9e9dcc  the SVC address extension is bits 15-18, and PASS stops going idle
    fd8d76771  actually wire --no-halucp-svc, so PASS keeps its own SVCs
    2331c5e3e  the MTU reply is SEVEN words, not six
    38e2fcd6d  an in-process mass memory must assert its own READY discrete
    d7cda7736  map the intercomputer bus (BCE 24), which selecting PFS needs
    710ae8dd2  warn when --bce-network is given without --real-time
