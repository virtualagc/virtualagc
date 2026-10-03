# OPS 1, launch and ascent: plan

Written 2026-10-03.

**Goal.** A by-the-book launch for demonstration videos: the crew follows the
ascent checklist, the ground (an emulated Launch Processing System) runs the
countdown, PASS's Redundant Set Launch Sequencer (RSLS) starts the engines,
and the vehicle flies through SRB separation and on to MECO and orbit.

**Cross-checking.** Don has done ascent work in nsts-sim-gpc: he has shown a
pad-abort video.  By the user's instruction (2026-10-03), compare with his code
only AFTER ours works, unless blocked by a question the primary sources cannot
answer.  The research behind this plan used the flight source and the
documents only.

Paths used below: `APPL` = `~/workspace/PFS/OI340600/APPLSRC`; `RCV` =
`~/workspace/PFS/"OI340600 as received"`; documents are under
`~/Desktop/sandroid.org/public_html/apollo/Shuttle/`.

## Where things stand (measured 2026-10-03)

**Run:** one GPC, IPL → OPS 901 → OPS 101, with `YAGPC_MDM_DEVICES=1
YAGPC_VEHDYN=1`, held in MM 101 for about 10 minutes.  The GPC stays in RUN:
PASS turns everything that goes unanswered into commfaults and does not fail
itself.

PASS's commfault words in MM 101 (`CZEB_COMM_FAULT`; each element's bit number
is its `BMTENT` CFBIT in `RCV/MLIB80/FCMBMTMC`, counted globally from 0):

| Flagged | Element | Status |
|---|---|---|
| word 1, bits 19-20 | star trackers | Expected: PASS bypasses them in configuration 16. |
| word 3, bits 17-20 | SRB MDMs LL1, LL2, LR1, LR2 | Launch buses 12/13 are unanswered. |
| word 5 | payload MDMs PF1/PF2, low-rate elements | Payload buses unanswered.  Harmless for GNC. |
| word 3, bit 8 | NSP2 data on FF3 | The NSP is not powered. |
| word 3, bits 26-27 and 30-31 | **IMU 2 and IMU 3 data and discretes** | **Unexplained.**  Not cleared by I/O RESET EXEC.  The IMU discrete read (`FIOIMUC2`) ran only 78 times, against about 12,800 data reads.  OPEN. |
| word 3, bits 22-23 | not identified | Configuration-specific table entries. |
| word 2 | EIUs | Clean: answered with zeros.  But zeros fail PASS's ID-complement test, so every engine data path fails. |

**Other findings from the run:**
- With no IMU commanded into operate, PASS sends no torque pulses, and the
  platforms drift at the I-load rate (0.15-0.26 deg in about 17 minutes).
  Physically right; on the pad, gyrocompassing must take over.
- MM 101 → MM 102 is not a crew step.  `GO1ASC.hal:313` advances on
  `CGSE_IGN_SRB_CMD`, which only the RSLS sets, after LPS commands, engine
  start with 90% chamber pressure, and the PIC checks.

## The interfaces (from the flight source and documents)

### 1. Launch data bus and the LPS (buses 12/13, ground IUA 17)

**Polling:**
- The GPC that commands LB1 polls; its redundant-set partners listen.
  Polling starts on bus 12 and toggles 12↔13 after 3 consecutive errors
  (`DGEGSEER`).
- Polling is enabled by DPS UTIL SPEC 1 item 50 "GSE POLL ENABLE" in OPS 9
  (`RCV/SSSRC/ASMAUX`), and survives the G9→G1 transition.
- One poll every 40 ms (25 Hz).  PASS stops polling by itself at SRB ignition
  (`GSRRSL.hal:1803-1806`).

**Command word:**

| Bits of the 24-bit word | Contents |
|---|---|
| 0-4 | address 17 |
| 5-8 | command code |
| 9-11 | GPC ID |
| 12-23 | word count, or status mask |

**Cycles** (`APPL/DGILDBIO.hal`; `RCV/SSSRC/FIOLDBPG`):

| Code | Cycle | LPS answer |
|---|---|---|
| 0011 | INTERROGATE | One word: `0x3000` (no need for the bus), or `0x6000 \| (n−1)` (ground has n words) |
| 0101 | GO-AHEAD | Reads the n words |
| 1101 | INTERROGATE WITH GPC DATA | `0xB000` (send GPC data) |
| 1001 | TRANSMISSION ENABLE | The GPC writes its words |
| 0010 | STATUS REQUEST | One word; its content is not checked |
| 1010 | STATUS | 12-bit mask in the command word; nothing to answer |

**Timing:** the reply must begin within about 610 µs (the bus 12/13 BCE
timeout, `FCMTMB2`).

**Messages from the ground:**
- Format: word 1 = destination (5 bits) and transaction ID (11 bits; never 0,
  never repeated); then the data words; then a 16-bit sumcheck (words summed,
  carries discarded).
- Destination 6 (`00110`) is the launch sequence.
- PASS's RSLS (`GSRRSL.hal:399-487`) takes the code from word 2, bits 11-16:

| Code | Command |
|---|---|
| 1 | GO FOR AUTO SEQUENCE |
| 2 | HOLD |
| 3 | RECYCLE |
| 4 | RESUME |
| 8 | GO FOR ENGINE START |
| 9 | GMT OF PREDICTED LIFTOFF — words 3-4, a 32-bit integer of GMT seconds; accepted only while holding |
| 12-14 | bypasses |
| 6, 7, 15 | slews |

**Replies from the GPC:** a 6-word response (echo, milliseconds of day,
accepted/rejected) through an INTERROGATE WITH GPC DATA cycle.  **The LPS must
take these responses**, or `DGO_GSE_COORD` blocks and every later command is
rejected as "FD busy".

**The countdown, as the LPS sends it** (GLS document KLO-82-0071 App A):

| When | Commands |
|---|---|
| T-20:00 hold | G9→G1 (an operator `OPS 101 PRO`, emulated by keystrokes) |
| T-19:00 | GMTLO (9), RESUME (4) |
| T-9:00 hold | HOLD (2), GMTLO (9), RESUME (4) — a fresh GMTLO is needed for each resume |
| T-31 s | GO FOR AUTO SEQUENCE (1) |
| About T-10 s | GO FOR ENGINE START (8) |

**Missing in yaGPC2:**
- Nothing answers buses 12/13 today (they fall through to
  `bus_no_peripheral`, `run.c`).
- Listener synchronisation (`busMarksSync`) does not include 12/13.
- `exec_MIN_at` does not set `armingWords` (`iop_bce_instr.c:539-552`), and
  `#MOUT@`/`#RDL` are untested.  LDB is the first workload to use them.

### 2. Engine interface units and SSMEs (EIU1/2/3 = IUA 17/23/24 on FC5-8, buses 14-17)

**Reads:**
- HFE: 6 words at 25 Hz (`FIOHI1EI` X'4005').  Primary path on the EIU's
  MIA1 bus (EIU1 bus 14, EIU2 bus 15, EIU3 bus 16).  Secondary path for all
  three on bus 17 (MIA4).
- MFE: 32 words at 6.25 Hz (`FIOFAIC5` X'401F'), primary only.

**Commands:** 2 words (command, BCH) through `FIOHO107` X'4C001' at 25 Hz.
Every copy goes out on all four FC5-8 buses; the controller votes.

**Data words:**

| Word | Contents | PASS's test |
|---|---|---|
| 1 | ID | — |
| 2 | must equal ~word 1 | mismatch = channel fail |
| 3 | status | see below |
| 4 | time reference, 20 ms per count | must change on every read, or the data counts as stale |
| 5 | hard-failure identification | — |
| 6 | chamber pressure | `% = counts × CPRESS`, about 24,111 counts at 100% |

Status word (word 3; bit 0 is the most significant):

| Bits | Mask | Contents |
|---|---|---|
| 1-2 | `0x6000` | command status: 11 = accepted, 01 / 10 = rejected |
| 3-5 | `0x1C00` | channel errors |
| 7 | `0x0100` | limit control |
| phase | `0x00E0` | 2 start prep, 3 start, 4 mainstage, 5 shutdown, 6 post-shutdown |
| mode | `0x001C` | per phase, e.g. 2/6 ENGINE READY |
| 14-15 | `0x0003` | self-test (01 = OK) |

**Commands** (`GPTSSM.hal`; Sequencers Table 4.8.2-1):

| Command | Word 1 | BCH |
|---|---|---|
| Start enable | 8F00 | 6522 |
| Start | 8100 | 9D7A |
| Shutdown enable | 8A00 | 3CA6 |
| Shutdown | 9C00 | 6040 |
| Throttle | (K+6)<<8, K = 65-109% | `CGPV_THROTTLE_SET` |
| Limit enable / inhibit | 8900 / 8800 | — |
| Dumps | 9100, 9200, 9000 | — |
| DCU switch | 9B00 | — |

**PASS's rules:**
- After SRB ignition the last command is re-sent every cycle.  "Accepted" must
  be reported only when the command word changes, within 1-3 reads.
- RSLS:
  - Throttle to 100% at T-8 s.
  - At T-6.5 s, requires ENGINE READY on all three, then sends START ENABLE.
  - Starts engine 3 at the start time, engine 2 0.115 s later, engine 1
    another 0.115 s later.
  - Any engine below 90% chamber pressure 4.6 s after its start is shut down
    (pad abort).
  - SRB ignition comes 6.6 s after the start.
- Nothing may report phase 5 or 6 before MECO, or PASS declares the engine
  failed.
- MECO: SHUTDOWN ENABLE and SHUTDOWN on alternate passes; MECO is confirmed
  when all three are below 30%.

**Missing:** the EIU reads are answered with zeros, and the commands are
discarded.

### 3. Master events controllers, PIC voltages, SRB data

**MECs** (MEC1/2 = IUA 18/20 on buses 14-17):
- Commands only.  **PASS reads nothing back** (PCR 42206 "ELIMINATE MECREAD").
- Every 40 ms, per MEC: a non-critical SET (`X'22C00'`), a 4-word critical
  write (`X'60003'`), and a non-critical RESET (`X'21C00'`).
- The critical words (`GPYMEC.hal`; Sequencers Table 4.8.1-1) name the
  events, ARM then FIRE1/FIRE2 plus the non-critical FIRE3 bit:

| Event | Arm | Fire 1 | Fire 2 |
|---|---|---|---|
| T-0 umbilical | CEDC | CE6A | CE9A |
| SRM ignition | 3EAC | 3E6A | 3E42 |
| SRB sep | 3154 | 316A | 319B |
| ET umbilical unlatch | C121 | C162 | C193 |
| ET structural sep | E117 (arm) | E168 | E199 |

- Master reset: command only, `0x92C000` / `0xA2C000`.
- The MEC's own decode and port vote are undocumented locally.  Proposed rule:
  the same value on at least 2 ports.

**PIC capacitor voltages:**
- Read from the FA MDM HFE read (`FIOHI1C1`), FA1 and FA2, words 33 (RH) and
  35 (LH).
- PASS requires at least 28,032 counts (35.7 V) from T-12 s, after SRM
  ignition ARM at T-15 s.  Otherwise it holds after two bad passes.
  **Today they are zero, so the countdown would hold at T-12 s.**

**SRB data PASS uses:**

| Item | Where | Scaling |
|---|---|---|
| SRB chamber pressure | FA1-3 HFE words 32 (RH) and 34 (LH) | psia = counts × 0.0313211 + K |
| SRB rate gyros (pitch, yaw) | FA1-4 HFE words 50-51 | 2/6400 per count |

The SRB rate gyros replace the orbiter's pitch and yaw rates in first-stage
flight control.

**The SRB MDMs** (launch buses, IUA 9/6/15/18) go to downlink only.  Answering
them with plausible static values clears the SRB commfaults.

**Separation sequences:**
- SRB sep (`GSESRB`):
  - The cue arms at 100 s.  Both chamber pressures ≤ 50 psia for 4 passes,
    or the backup at 130.6 s.
  - Mode switch 4.3 s after the cue; fire at 6 s, if q-bar ≤ 75 and the
    orbiter rates are within 5/2/2.
- ET sep (`GSTETS`):
  - Unlatch, then the feedline disconnects, which need valve and latch
    indications from the FA discretes.
  - Fire when the rates are within ±0.7.

### 4. Other words that change PASS's behaviour (the analog survey)

- **SRB chamber pressure** reads −15 psia today, so SRB sep would come at
  about 106 s instead of about 123 s.
- **Hydraulic pressure** (FA HFE words 26-27, plus HYD3 C) reads zero, so
  all three systems are declared failed.  About 3000 psi; the 6.4 counts/psi
  scale is inferred.
- **Landing-gear uplock bits** read "not up".
- **ET feedline disconnect latch and valve bits** are zero, so SEP INH at
  MECO.
- **MPS fill/drain and dump valves, manifold pressures, He supply.**
- **Orbiter rate gyros (FA words 47-49) and accelerometers (FF HFE words
  34-35)** are zero today.  In flight they must follow the truth.

### 5. Crew controls missing in OPS 1 (the switch survey)

- SBTC TAKEOVER pushbuttons and the SBTC analog (the pilot's manual throttle).
- RHC trim switches.
- Rudder pedals.

All are harmless at zero.  Everything else PASS reads in OPS 1 is driven.

### 6. MEDS

- OMS/MPS, HYD/APU and SPI are hard-coded constants in `MEDS2.py`.
- MPS chamber pressure should come from the engine model.  APU and hydraulic
  readings should come from a simple systems model.
- Gauge bugs to fix:
  - pneumatic helium tank shows the regulator's value;
  - hydraulic 3000 psi drawn red;
  - LO2 manifold always red;
  - helium tank uses the regulator's limits.
- `mdmdev.c` stores FF analog-output writes as discrete masks, which garbles
  them.  These are the SPI and the MPS chamber-pressure outputs.

## Phases

Each phase is verified with PASS flying before the next starts.  The C goes
on review branches and to master after the peers test it, as before.

1. **LPS and the launch data bus.**
   - The bus 12/13 router entry and listener synchronisation.
   - `exec_MIN_at` fixed.
   - The LPS model, answering the interrogate, go-ahead, transmission-enable
     and status cycles.
   - A countdown script, fed like `groundstation.py`'s uplink: GMTLO, RESUME,
     HOLD, GO FOR AUTO SEQUENCE, GO FOR ENGINE START.
   - Verify: PASS accepts each command (its response says so), and the CRT
     countdown clock runs from the GMTLO.
2. **EIUs and SSMEs.**
   - Status and data words, command decoding, start and shutdown sequences,
     throttle.
   - Verify: ENGINE READY on all three; a T-31 s countdown goes through
     engine start to the T-0 decision, holding only where the next phase is
     missing.
3. **MECs, PIC voltages, SRB MDM answers.**
   - Verify: the PIC check passes, SRB ignition is commanded and MM 102
     starts.
4. **The pad and the ascent vehicle.**
   - Earth-fixed hold-down; release on the T-0 events.
   - Stack mass properties.
   - SSME thrust gimballed by the ATVC commands (FA outputs: decode needed).
   - SRB thrust and TVC.
   - Crude aerodynamics (no coefficients in the mirror: synthesise for max-q
     of about 575 psf near 54 s).
   - SRB and ET separation.
   - Gravity and drag exist already.
   - IMUs on the pad: Earth-rate gyrocompassing, 1 g, release to inertial.
5. **Sensor words.**
   - Rate gyros (orbiter and SRB), accelerometers, SRB chamber pressure,
     hydraulics, gear uplock, MPS valves and pressures, feedline disconnects
     answering PASS's close commands.
6. **MEDS systems displays and the crew script.**
   - OMS/MPS and HYD/APU fed from the models; the gauge bugs fixed.
   - The by-the-book countdown script from the ascent checklist (STS-126
     Ascent C/L, OI-34 era).
7. **After MECO.** ET sep, OMS-1/2 (the OMS model exists), OPS 105/106, OPS 2.
8. **Cross-check against Don's nsts-sim-gpc.**  Record disagreements in the
   ledger before deciding which side is right.

**First demo target:** T-31 s through SRB separation, then through MECO.

## Known unknowns

- **The LDB:** SS-P-0002-150 (the LDB interface requirements) is not in the
  mirror; the GPC-ID bits and the SACS "EQ DEU" format are inferred or
  unknown.
- **The EIUs:** the meaning of the time word (reset at each phase change is
  inferred); real start and shutdown timelines; the bus encodings of the
  "status override" and "master reset" DIOs.
- **The MECs:** their critical-word decode and port voting.
- **The PIC:** the A/D scale beyond 438 counts = 35.7 V.
- **Hydraulics:** the count scale.
- **Vehicle data:** aerodynamic coefficients and the SRB thrust-time curve
  (not in the mirror); OI-34-era masses.
- **IMU 2/3 commfaults in MM 101** (see "Where things stand").
- **Multi-GPC:** four-GPC OPS 1 has open ledger entries (#204, #210, #215,
  #216).  Each phase is verified on one GPC first, then four.
