# STS-134 rendezvous with the ISS: plan

Written 2026-10-08. **Status: PLAN ONLY.** Nothing here has been built. It
was written read-only from the repository, the flight source, and the
documents listed under Sources.

The goal is to fly STS-134's rendezvous and docking (FD1-FD3) the way the
ascent, OMS 2 and entry are flown already:
- **PASS** does the navigation, targeting and attitude control.
- **The driver's crew scripts** follow the flight's own checklist.
- **The ground** (`groundstation.py`) sends what MCC sent.
- **yaGPC2** supplies the sensors and the physics.

The Orbiter has never yet been flown toward the ISS. Today the ISS is only a
point mass that vehdyn moves (`YAGPC_VEHDYN_TARGETS`) and portview draws.

## 1. What STS-134 actually did

**Docking time.** Docking was on **FD3, 2011-05-18 10:14 UTC**. That is the
instant `~/sts134-runs/rendezvous/sts134-targets.txt` was made for.

**The profile.** The Shuttle's ISS profile is the Stable Orbit Rendezvous
(Stuit, AIAA; JSC-48072-134 p. 1-5):
- **FD1-FD2:** phasing burns NC1, NC2 (and NC3/NPC as needed) shrink the
  catch-up.
- **NH** (if required) puts the Orbiter's relative apogee about 1,200 ft
  below the ISS's.
- **NC4**, one rev before Ti, puts it about 40 nmi behind.
- **NCC** (Ti − ~1 h) is the first burn targeted from onboard sensor
  navigation. It aims at the **Ti point: 48.6 kft behind and 1.2 kft below
  the ISS**.
- **Ti** opens the intercept. On STS-134 it was **07:38 UTC**, about 9 nmi
  out: the left OMS for about 10 s, about 8.4 ft/s.
- **MC1-MC4** are midcourse corrections, targeted onboard.
- **R-bar arrival:** about 600 ft below the ISS.
- **Manual phase:** the commander flies from about MC4 on.
- **RPM**, the R-bar pitch maneuver: started 09:15 UTC; 360° at 0.75°/s.
- **TORVA:** a quarter-orbit fly-around to the +V-bar at about 400-310 ft.
- **+V-bar approach** to PMA-2.
- **Contact** at 10:14 UTC.

The checklist (JSC-48072-134 Rev A) gives the onboard target sets, quoted
from its pages 4-11 to 4-21. These are the numbers the crew scripts will key
on SPEC 34 (ORBIT TGT); kft, minutes, LVLH of the target with +Z down.

| Burn | TGT NO | T1 TIG | EL | ΔT (min) | ΔX | ΔY | ΔZ |
|---|---|---|---|---|---|---|---|
| NCC | 9 | NCC TIG | 0 | 57.7 | −48.6 | 0 | +1.2 |
| Ti | 10 | BASE TIME | 0 | 76.9 | −0.9 | 0 | +1.8 |
| MC1 | 11 | MC1 TIG | 0 | 56.9 | −0.9 | 0 | +1.8 |
| MC2 | 12 (19 if TIG slips) | MC2 TIG | **29.07** | 27.0 | −0.9 | 0 | +1.8 |
| MC3 | 13 | BASE + 0:17:00 | 0 | 10.0 | −0.9 | 0 | +1.8 |
| MC4 | 14 | BASE + 0:27:00 | 0 | 13.0 | 0 | 0 | +0.6 |

**Burn solution rules (p. 1-3).**
- Every burn before NCC flies the **ground** solution.
- NCC and Ti fly the onboard FLTR solution once navigation has converged:
  more than 40 marks, with the last 4 SV updates under 0.5 kft.
- MC1-MC4 fly the onboard solution.
- Engine: RCS multi-axis below 4 ft/s, +X RCS for 4-6 ft/s, a single OMS
  engine above 6 ft/s.

## 2. What PASS has for this (OI-34, `~/workspace/PFS/OI340600/APPLSRC`)

All of the rendezvous software is in the OPS 2 load. Nothing new has to be
written for the GPC.

| Function | Modules | Display |
|---|---|---|
| Ground state vectors | GTBUPL: **message 9** Orbiter SV; **message 10 rendezvous (target) vehicle SV** into `CGNV_T/R/V_TV_GND_MFE`, the same 23-halfword layout as 9; message 42 drag K-factors including `CGNV_TARGET_KFACTOR`; message 43 covariance (σ, correlations); message 16 on-orbit PEG 7 (external ΔV) | — |
| Relative navigation (Kalman filter, FLTR and PROP states) | GL9REN (init), GL7REN (filter), GL6COV (covariance and measurement), GLQREN (sensor init), GL3REN (sensor select), GLARRD (RR range/rdot), GLBRRA (RR angles), GLRREN (SV interpolation), GLIMEA (statistics), GLMREL (display) | SPEC 33 REL NAV (CG0330.dfg; items in GKVREL/GWFREL) |
| Rendezvous radar data | GYNRRP: `CGBV_RNDZ_RDR`, 10 words, **FF3** (bus 22) **card 3 channel 3**, command `FIOFFIC3` X'24C69' (MLIB80/FIOMFBCE.asm, BCEEQU.asm:196). Commfault slot 21. Word 1 status (bit 1 radar on, bit 10 self-test); words 3/4 the two gimbal angles; word 5 rdot; words 7-8 range; words 9/10 angle rates | SPEC 33 |
| Star tracker target track (offset or auto-scan) | GY3STT, through the existing STU path (`startrk.c`) | SPEC 22 TGT TRK |
| COAS marks | GY6COA and GY7STC. The mark is `CGEB_FLT_LG2_FLAG1_MFE` bits 12-13 (GYZSTS.hal:1159), apparently the ATT REF pushbuttons. Verify. | SPEC 22, SPEC 33 |
| Orbit targeting | GK3ORB calls GWR (Lambert, from a target set), GWG (non-Lambert/CW) or GWN (maneuver). Target sets are I-loads `CGZV_T1/DT/EL/ROFF_ILOAD_ARRAY(40)` and `CGZB_LAMB_ILOAD` (CGZMC2.hal:216-219, 288). Item handling is in GKQORB. | SPEC 34 ORBIT TGT: ITEM 1 TGT NO, 2-20 data, 21-24 BASE TIME, 26 LOAD, 28 COMPUTE T1, 29 COMPUTE T2 |
| Burns | OPS 202 MNVR EXEC: PEG 7 / Lambert guidance, OMS or RCS | ORBIT MNVR EXEC |
| Target-track attitude; Ku pointing vector | GVUUNI (UNIV PTG TGT ID 1 = the rendezvous target). With KU ANT ENA, `CGNV_RTLOS` goes to the SM GPC's antenna management over the ICC (GOAGNC.hal:120-131) | UNIV PTG |

## 3. What the repository has now

| Piece | Where | State |
|---|---|---|
| Other vehicles: the real ISS from its May 2011 TLE, its own gravity and drag, LVLH attitude, carried through snapshots | `vehdyn.c` "OTHER VEHICLES", `tools/tle_target.py`, `~/sts134-runs/rendezvous/` | Works. It is a point mass to the physics. |
| TGT1 feed (M50 r, v, q) and the TRU1 truth feed | `mdmdev.c` targets_publish / truth_publish | Works |
| portview: overhead windows W7/W8, the ISS model, `ISS_PMA2`, scripted `vbar` and `flyaround` demos | `discretePanel/portview.py`, `portview/vehicles/` | Works. The demos are scripted, not PASS. |
| RCS: 38 primaries and 6 verniers from the MDM fire words, propellant, mass properties | `vehdyn.c` | Works. 17 jet positions are estimated, and vernier positions are estimates. |
| OMS engines and gimbals | `vehdyn.c`, `mdmdev.c` | Proven by OMS 2 and deorbit |
| Orbit DAP, THC/RHC, DAP pushbuttons (A/B, AUTO/INRTL/LVLH/FREE, PRI/ALT/VERN, PULSE, LOW Z), ATT REF, ADI, SENSE | `handcontrollers.py`, `crewscript.py` (`thc`, `rhc`, `dap c3/a6u ...`, `attref`), `SCRIPTABLE_CONTROLS.md` | Works in OPS 2 |
| Star trackers: catalog stars, shutter, panel O6 | `startrk.c`, `STAR_TRACKER_PLAN.md` | Done. Its "known gaps" list target track as waiting for a target. |
| IMUs, IMU drift, star alignment; GPS | `mdmdev.c` | Works |
| Ground uplink through NSP1: message 9 SV, message 59 RNP, DOLILU, raw; downlist decode | `discretePanel/groundstation.py` | Works. There is **no message 10** verb yet. |
| A1U KU-BAND STEERING MODE switch | panel, `SCRIPTABLE_CONTROLS.md` | The switch only. Nothing behind it. |
| Flight driver: IPL → ascent → OMS 2 → OPS 201 → one orbit → deorbit → entry → landing; a capture per phase; `rate` | `examples/flights/fly_sts134.py` | Works. No rendezvous phases. |
| Fresh start straight to OPS 201 in a chosen orbit | `YAGPC_VEHDYN_ORBIT`, `examples/1gpc-ops201-imu.script`, `--date-time-epoch` | Works |

## 4. The gaps, in order of size

1. **The manual phase pilot.** From MC4 through RPM, TORVA and the V-bar
   approach to contact, the crew flies the THC against braking gates, the
   COAS and the centerline camera. The driver has to close that loop
   itself. This is the largest new piece.
2. **The rendezvous radar.** The Ku-band deployed assembly in radar mode is a
   new device: the FF3 serial channel, the A1U/A2 switches, the search and
   track logic, range limits, and noise. There is a complication: the
   antenna is pointed by the **SM** GPC's antenna management, which takes
   GNC's target LOS over the ICC. The simulation runs no SM GPC. The model
   will have to stand in for SM plus the KuSP; see Stage 3.
3. **Getting to FD3.** The ORBIT capture is at MET ~1:30. Ti was at MET
   42:41. The simulator runs at about 1× on the fast host
   (CAUSES.md #164, #159), so flying the phasing honestly means about 41 h
   of simulated time. Hence the first milestone below starts near Ti
   instead.
4. **Docking and the mated vehicle.** This means the PMA-2 / ODS geometry,
   the capture conditions, and two bodies becoming one: mass properties,
   and who holds attitude.
5. **Star tracker target track** (an extension of `startrk.c`), **COAS**
   (crew marks from portview truth), and **TCS / HHL / RPOP**. The last
   three never reach the GPC, so they are driver-side instruments.
6. **I-loads not yet checked on this tape:**
   - the 40 orbit-targeting sets;
   - the DAP configurations A7-A12 / B7-B12 the checklist loads;
   - the RR mounting and noise constants.

   If the tape carries another mission's values or zeros, the sets go in
   through the crew's own SPEC 34 entries (items 2-20, which the checklist
   already lists). The DAP configurations go in through SPEC 20, or a
   `mission_reconfig.py` OPS 2 overlay.
7. **Single GPC, no SM.** The flight rules want two GNC GPCs for Ti and for
   prox ops inside 250 ft. The checklist also uses SM pages: SM 2 TIME,
   SM ANTENNA self-test, SM 167 DOCKING STATUS. These are deviations,
   recorded as such, until a G2 + SM configuration runs.

## 5. FIRST MILESTONE (M1): the ISS in the overhead window under PASS's own guidance

**Goal.** Start one GPC in OPS 201 about 70 minutes before Ti, with the
Orbiter on its real FD3 approach to the real ISS. The ground then uplinks
both state vectors. From there:
- PASS's rendezvous navigation runs (PROP state, no sensors yet);
- SPEC 34 computes the Ti burn from target set 10;
- UNIV PTG TGT ID 1, BODY VECT 3 (−Z) target track brings the ISS into the
  centre of portview's overhead view.

M1b adds the Ti burn itself in OPS 202 (left OMS, Lambert) and the coast
toward the R-bar.

**Why start this way.** No new sensor is needed. Every computation shown is
PASS's own. It uses only paths that already work: fresh OPS 201, the
message 9 uplink, OMS burns, and portview. Starting at the real epoch with
the real ISS also gives the real lighting for the later sensor work.

**Work.**
1. **vehdyn: an Orbiter start relative to a target.** For example
   `YAGPC_VEHDYN_START_REL=25544,x,y,z,vx,vy,vz`, in the target's LVLH (m,
   m/s) at the start time:
   - the target is propagated from its file epoch to the start clock;
   - the Orbiter is placed off it, and the attitude is +XVV/−ZLV or from
     `YAGPC_VEHDYN_ATT`.

   About 60 lines next to `targets_advance`, plus a unit test: the round
   trip of LVLH placement against `lvlh_axes`.
2. **`tools/rndz_start.py`.** It computes the starting LVLH state at
   NCC − 10 min, about Ti − 68 min, by working back from the Ti point:
   - the Ti point is −48.6 kft / +1.2 kft below at 07:38:00 UTC;
   - its rate is the co-elliptic closing rate, ẋ ≈ 1.5 n Δh;
   - it is walked back with Clohessy-Wiltshire, checked against a numerical
     two-body propagation.

   NCC absorbs the residual. A simpler M1-only start at Ti − 15 min, already
   on the Ti point, skips NCC.
3. **`groundstation.py tsv`: message 10 from TGT1.** The data are the
   target's M50 r, v at the TRU1 GMT, in feet and ft/s, and the words are
   `state_vector_words` with opcode 10. Optional: `kfactor` (message 42) and
   `cov` (message 43).
4. **`examples/flights/fly_rndz134.py`, or `fly_sts134.py --rndz-start`.**
   - Environment: `--date-time-epoch 2011-05-18T06:30:00`,
     `YAGPC_VEHDYN_TARGETS` (the existing file),
     `YAGPC_VEHDYN_START_REL`, and the Orbiter's FD3 mass.
   - Scripts, IPL through OPS 201: the existing IPL, then the SPEC 21 IMU
     OPER sequence with DAP FREE first, as in `1gpc-ops201-imu.script`.
   - Ground: RNP (message 59, 2011/136), then **sv** (message 9) and
     **tsv** (message 10), both from truth.
   - Crew, from the checklist's ENABLE RENDEZVOUS NAV and TARGET Ti blocks:
     - SPEC 33: `ITEM 1 EXEC` (RNDZ NAV ENA), then `ITEM 4` SV SEL to PROP
       (the item numbers are from the STS-134 checklist);
     - SPEC 34: `ITEM 1 +10 EXEC`, BASE TIME `ITEM 21-24` = Ti TIG,
       `ITEM 26 EXEC` LOAD, `ITEM 28 EXEC` COMPUTE T1;
     - UNIV PTG (from LOAD TARGET TRACK [9A]): `ITEM 21 EXEC` (CNCL), then
       TGT ID +1, BODY VECT +3 (−Z), OM 0, and `ITEM 19 EXEC` TRK, with
       DAP B/AUTO/ALT and then A/AUTO/VERN.
   - **M1b:** `OPS 202 PRO`, load engine select (L OMS), the trims and the
     weight, `ITEM 22` LOAD, `ITEM 23` TIMER, `ITEM 27` MNVR, and `EXEC` at
     TIG − 15 s, as the OMS 2 and deorbit scripts already do. Then
     `OPS 201 PRO` and target track again.
5. **portview:** launched with the run as now (TGT1 and TRU1). Nothing new
   is needed, though an optional COAS reticle overlay on the overhead view
   could be added.

**Acceptance.**
- **The uplinks land.** SPEC 33 RNG and RDOT agree with the truth range and
  range rate (from TRU1/TGT1) to within a few feet and 0.01 ft/s.
- **Ti.** The SPEC 34 TGT 10 COMPUTE T1 ΔV is within about 1 ft/s of an
  independent Lambert solution in the tool from the same states (and of the
  ~8.4 ft/s flown).
- **Target track.** The vehicle comes into target-track attitude, and in the
  overhead view the ISS sits within about 1° of the −Z axis. It stays there,
  growing, through the coast.
- **M1b.** After the Ti burn, the truth trajectory passes the MC4 region
  (about 600-1,800 ft below the ISS) within the Ti dispersions. MC1-MC4 are
  not flown yet. A capture (`sts134-ti`) is left for the later stages.

**Effort: 3-5 days** (M1b +1-2).

## 6. The stages

Effort is in working days for one agent with Ron's review, assuming the
platform behaves. Each stage ends with a capture that the next stage
resumes from.

### Stage 1: relative navigation from the star trackers (NCC)

**PASS.** GY3STT drives the −Z (or −Y) tracker in target track. It offsets
toward PASS's predicted target LOS, and the tracker reports the brightest
object in the box. GL6COV/GL7REN take the angles. SPEC 33 shows the
residuals, ratios, SV UPDATE POS and FLTR − PROP.

**Crew** (STAR TRACKER NAV [10A] and END S TRK NAV [10B]):
- SPEC 21: deselect the NAV IMU;
- SPEC 22: THOLD `ITEM 13/14 +3`, `ITEM 6(5)` TGT TRK, wait for S PRES;
- SPEC 33: S TRK `ITEM 12`, AUTO Angles `ITEM 23`;
- SPEC 33, SV SEL `ITEM 4`: PROP until SV UPDATE POS < 1.0 kft with
  ACPT > 9, then FLTR, and FLTR TO PROP (`ITEM 8`) as directed;
- break track (`ITEM 7/8`) when the residuals jump;
- NIGHTTIME STRK OPS: THOLD 0 at sunset;
- then TARGET NCC [11A] (SPEC 34 TGT 9) and the RCS burn.

The driver reads the residuals and SV UPDATE POS from the downlist decode or
from the screen text.

**Ground.** It sends the ground NCC solution for comparison, and the IMU to
deselect.

**yaGPC2: `startrk.c` target mode.**
- In offset-scan or target-track mode, the ISS is a candidate "star":
  - its position is the truth LOS from the Orbiter's centre of gravity,
    through the same TNBST, aberration and noise path the catalog stars use;
  - its magnitude comes from range, a size about 100 m, and the solar phase
    angle (about −1 to +3 over 40-5 nmi; tune so lock-on ranges match the
    checklist's use);
  - it is visible only when sunlit: not in the Earth's shadow, and not
    against the lit Earth (the existing limb shutter);
  - real catalog stars in the box can still steal the lock (false lock), as
    the HIGH RESID contingency expects.
- Break track excludes the object for the next search.
- Lock is lost at body rates above 0.5°/s, as now.

**Exists.** The tracker device, its interface, the shutter, the catalog, the
Sun almanac, and target truth.

**Missing.**
- the target candidate and its brightness model;
- a lighting test: the ISS in shadow (the umbra cylinder or cone, from the
  almanac);
- driver logic for the SPEC 33 decisions.

**Check.**
- PASS's FLTR state converges to the truth relative state to well under
  1 kft.
- The NCC FLTR solution agrees with the tool's solution from truth within
  the ground limits (0.8 / 1.6 / 2.3 ft/s).

**Effort: 4-6 days.**

### Stage 2: onboard targeting and the burns (NCC, Ti, MC1-MC4)

**PASS.**
- SPEC 34 Lambert (GWR) from TGT 9-14 (19 for a slipped MC2).
- The MC2 elevation-angle TIG of 29.07° (GWR iterates the TIG; the "TGT EL
  ANG" alarm path).
- OPS 202 guidance for OMS (Ti) and RCS (NCC, MCs).

**Crew.**
- TARGET [11A]/[13A]/[15A]/[17A]/[17B]/[18A]/[18B]/[19B]/[20A], as tabled
  in §1: TGT NO, check the set, COMPUTE T1, record the solution, choose
  FLTR, PROP or ground by the rules.
- **RCS BURN cue card:**
  - +X burns: OPS 202, `RCS SEL` (ITEM 4), `EXEC`, THC +X until VGO X is
    nulled;
  - multi-axis burns: DAP A/LVLH or AUTO, then null VGO X/Y/Z with the
    THC in PULSE (0.1 ft/s pulses) or NORM.
- MANUAL OUT-OF-PLANE NULL [19A]: when Y = 0, null ẏ with the THC.

The driver needs a VGO-nulling loop that reads VGO from the downlist (or the
MNVR display) and issues `thc` pulses.

**Ground.** Final ground solutions and the GO for Ti, as text: the
driver's "MCC". Also the Ti DELAY solution, not flown nominally.

**yaGPC2.** It already models the jets and the OMS. Two things are needed:
- check the THC translation path in OPS 202 (RCS SEL) and PULSE quantization
  against the DAP's I-loaded pulse size;
- confirm the vernier jets' estimated positions do not make VERN attitude
  hold fight the translations.

**Exists.** The OMS burn procedure (OMS 2, deorbit), `thc`, the DAP
pushbuttons, the downlist decode.

**Missing.**
- the VGO-nulling loop;
- the burn-solution bookkeeping, the "PAD";
- a Lambert check tool (for acceptance only).

**Check.** Each burn's ΔV against the checklist's mean ± 3σ:

| Burn | ΔVX | ΔVY | ΔVZ |
|---|---|---|---|
| MC1 | −0.1 ± 0.6 | −0.1 ± 0.7 | +0.5 ± 1.2 |
| MC2 | 0.0 ± 0.4 | 0.0 ± 0.2 | +0.9 ± 2.5 |
| MC3 | +0.9 ± 1.3 | 0.0 ± 0.5 | +1.1 ± 2.6 |
| MC4 | +1.3 ± 1.3 | −0.1 ± 0.6 | +0.9 ± 2.2 |

Arrival is about 600 ft below the ISS at MC4 + 13 min.

**Effort: 4-6 days.**

### Stage 3: the Ku-band rendezvous radar

**PASS.**
- GYNRRP decodes the 10 words on FF3 card 3 channel 3.
- GLARRD and GLBRRA incorporate range, rdot and angles.
- The KU ANT ENA command (SPEC 33 `ITEM 2`) and the LOS go to SM over the
  ICC.

**Crew.**
- AFT FLT STATION CONFIG [4A]:
  - A1U: KU PWR STBY, sel MAN SLEW, MODE RDR PASSIVE, RADAR OUTPUT HI,
    CNTL PNL, PWR ON;
  - A2: DIGI-DIS R/RDOT, X-PNTR scale ×1;
  - the SM ANTENNA self-test (`ITEM 7`), then MODE COMM, sel GPC, CNTL CMD.
- KU OPS cue card at NAV RNG < 150 kft.
- At RR RNG < 135 kft, RR NAVIGATION [13B]: SPEC 33 RR `ITEM 13`,
  FLTR TO PROP `ITEM 8`, AUTO RNG/RDOT/Angles `ITEM 17/20/23`, SV SEL
  logic.
- Post-Ti: KU sel GPC.
- RADAR OUTPUT LOW at about 700 ft.
- KU PWR STBY through the RPM.
- Terminate: INH RNG/RDOT/Angles (`ITEM 18/21/24`), KU ANT ENA off.

**Ground.** Nothing new.

**yaGPC2: a radar device** (a section of `mdmdev.c` or a new `kuradar.c`),
with panel A1U/A2 inputs over the existing crew-panel channel (as the star
tracker's O6 switches use, `CREW_TYPE_*`):
- **Pointing.** There is no SM GPC, so the device stands in for the SM
  antenna management and the KuSP. In GPC / GPC DESIG with ANT ENA, it
  designates at the truth target plus a pointing error, searches, and
  locks. In AUTO TRACK it tracks once locked. MAN SLEW follows the panel
  slew. Reading GNC's `CGNV_RTLOS` off the ICC traffic (`iccmodel.c`) would
  be more faithful; it is a later option.
- **Acquisition.** Passive skin track: the signal falls as R⁻⁴, with first
  lock inside 135 kft (Stuit; the checklist's 135 kft). Track becomes
  erratic inside a few thousand feet, as the beam wanders over the ISS
  structure. There are minimum-range and output-power rules, and the Ku
  deployed assembly's blockage zones are an estimate.
- **Words.** Laid out exactly as GYNRRP decodes them: range
  `bits × 0.005/16` (units per the FSSR NAVAIDS 4.229), rdot ×0.05, gimbal
  angles 0.0878906°/LSB, angle rates, status bits (on, self-test, data
  good). The commfault and self-test sequence produce 'COMM' / 'STST'.
- **Gimbal frame.** The radar mounting I-loads used by GLBRRA, with
  gimbal-to-body taken from the same I-loads.
- **Panel A2.** The A2 range/rdot and EL/AZ display, and the cross-pointer,
  for the panel (optional).
- **Capture/restore** in `vehdyn.json`, and unit tests that PASS's decode of
  the words returns the truth.

**Exists.** The FF read path, the panel channel, target truth, and the A1U
switch widget.

**Missing.** Everything else listed above. The exact RR word bit map needs
the FSSR SOP section, or reverse-reading GYNRRP / GLBRRA fully.

**Effort: 6-9 days.**

### Stage 4: crew instruments outside the GPC (COAS, TCS, HHL, centerline camera)

**PASS.** It does nothing with TCS or HHL. COAS marks feed rel nav only in
the COAS NAVIGATION contingency.

**Crew.**
- −Z COAS installed and on;
- HHL reports of R and Rdot from MC4 onward;
- RPOP/TCS activation (AUTO ACQ 10,000 ft) after MC2;
- the centerline camera from 2,000 ft;
- the COAS logic in RADAR FAIL [20D]: N° high → 2N +X pulses.

**yaGPC2 / driver.**
- **An "instruments" module** in the driver (Python, reading TRU1 and TGT1)
  gives, each with documented noise:
  - HHL range and rdot to an ISS structure point;
  - TCS range, rdot and bearing to the reflectors (`ISS_PMA2` and the
    reflector positions in the ISS frame);
  - COAS angles of the target in the reticle;
  - centerline-camera alignment errors (pitch, yaw, roll) to the Node 2 /
    PMA-2 target.
- **portview.** A COAS reticle on the overhead view, and a centerline-camera
  view along the ODS axis, so a human sees what the scripted crew uses.
- **COAS marks** for the contingency: `attref` on the crew's mark when the
  instruments say the target is on the reticle.

**Exists.** TRU1/TGT1, `ISS_PMA2`, and the portview views.

**Missing.**
- the module;
- the ODS docking-port location in Orbiter coordinates (Xo/Zo of the ODS
  in the payload bay, from the APDS/ODS documents);
- the PMA-2 docking target and the TCS reflector positions.

**Effort: 3-4 days.**

### Stage 5: the manual phase (R-bar, RPM, TORVA, +V-bar approach)

**PASS.** The orbit DAP:
- configurations A8/B8 (approach), A9/B9 (RPM, TORVA) and A10/B10
  (alignment);
- TRANS PULSE/NORM and LO Z;
- PRI, VERN or ALT jets;
- UNIV PTG tracks: TGT ID 2 BODY VECT 5 P 270 for the R-bar; the RPM via
  P = 145 / 270 with `ITEM 19` TRK and DAP FREE in the middle.

All of it is PASS's.

**Crew** (APPROACH, RPM and VBAR APPROACH cue cards; TERMINATE RNDZ OPS
[22A]):
- **Braking gates.** At 2,000 / 1,700 / 1,500 / 1,000 / 900 / 800 / 700 /
  650 / 600 ft, Rdot of −3.0 / −2.4 / −2.1 / −1.3 / −1.1 / ... / −0.4 ft/s.
  THC −Z ("in") when Rdot falls below the next gate. LO Z at 1,000 ft.
- **Null Xdot** to 0 ± 0.1 ft/s, then stationkeep at 600-620 ft until the
  RPM window opens.
- **RPM SETUP** (SPEC 20): PRI ROT RATE `ITEM 10 +0.75`, VERN ROT RATE
  `ITEM 23 +0.75`, PRI Y OPTION `ITEM 16`. Then UNIV PTG P 145 / 270 with
  TRK at the pitch callouts, FLT CNTLR PWR off/on, and KU PWR STBY/ON.
- **TORVA.** UNIV PTG P `ITEM 15 +179`, TRK, then THC +X (up) to start the
  fly-around, keeping the ISS in the centerline camera and range above
  250 ft docking-port to docking-port. ESTABLISH VBAR at pitch error < 2°,
  at about MC2 + 1:10.
- **VBAR APPROACH**, from about 350-250 ft docking-port to docking-port: the
  AUTO ANGULAR FLYOUT / TARGET ALIGNMENT cue cards (UNIV PTG corrections
  from the camera errors), then close at about 0.1-0.2 ft/s and line up
  laterally to within inches.

**The driver: a pilot model.** This is the core of this stage. It needs:
- a state machine over the cue-card events;
- control laws that turn the instruments' range, rate and angle errors into
  `thc` pulses (pulse-counting in PULSE mode, as crews flew), with the
  checklist's rate limits;
- hand-offs to UNIV PTG for the rotations.

It must run at rate 1 (about 2 h of sim time) and tolerate the crewscript
command latency.

**yaGPC2.** No new devices. Possibly needed:
- RCS plume impingement on the ISS. Ignore it, but log jet firings toward
  the ISS inside 200 ft for interest.
- An ISS attitude for docking: the LVLH hold is good enough; the docking
  attitude is +XVV, Z nadir, PMA-2 forward.

**Exists.** The THC and DAP verbs, UNIV PTG, and the portview scripted
demos (useful references for the geometry).

**Missing.** The pilot model and its tuning.

**Effort: 8-12 days.** This stage carries the most risk.

### Stage 6: contact, capture and the mated stack

**PASS / crew.**
- DOCKING SEQUENCE (APDS, panel A7L) and SM 167: capture, damping, ring
  retract, hooks closed.
- TERMINATE RNDZ OPS:
  - mated DAP A12/B12;
  - X JET ROT ENA;
  - SPEC 23 jet deselects (F1L, F3L, F2R, F4R, F1U, F3U, F2U);
  - free drift, or LVLH with verniers;
  - RNDZ NAV ENA off.

**yaGPC2.**
- **Contact detection:** the ODS ring against PMA-2 within the capture
  envelope. Closing rate about 0.1 ft/s, lateral within a few inches,
  angular within a few degrees: take the envelope from the APDS documents,
  if they are available.
- **Capture** freezes the relative pose. **Mated:** vehdyn treats the
  Orbiter and the ISS as one rigid body:
  - combined mass and inertia (ISS about 400 t at ULF6);
  - the ISS's attitude control off, or a simple CMG hold;
  - the target's own propagation suspended while mated.
- An A7L panel and SM 167 need SM, so they are scripted as "capture
  confirmed" events for now.

**Exists.** The point-mass target and the mass-properties code.

**Missing.**
- contact geometry and capture;
- the mated mode in vehdyn and its snapshot;
- portview drawing the stack rigidly (it already draws both).

**Effort: 3-6 days** (a capture freeze alone, 1-2).

### Stage 7: FD1-FD2 phasing from the real insertion

**PASS.** Ground-targeted burns through OPS 202. The targets arrive either
as message 16 (on-orbit PEG 7: TIG, ΔVx/y/z) or as the crew's burn-pad
entries on MNVR EXEC. NC1 on FD1, NC2 and NC3 on FD2, NH and NC4 on FD3.

**Crew.**
- The Post Insertion and Orbit Ops procedures: PLBD open, the Ku antenna
  deploy, the OMS/RCS burn cards.
- IMU star alignments, about every 12-24 h, since `YAGPC_IMU_DRIFT` makes
  them matter.
- Sleep periods, as stretches of simulated time.

**Ground.**
- **A phasing planner**, `discretePanel/rndz_target.py` in the manner of
  `deorbit_target.py`. From the truth states (the ground's tracking), with
  drag and the K-factors, it solves the NC / NH sequence to reach NC4 and
  Ti at STS-134's times.
- Orbiter and target SV uplinks (messages 9 and 10), daily and at Ti − 3 h
  ("MCC UPLINK ORB SV, TGT SV, drag K-factor").
- The burn pads.

**yaGPC2.**
- **Time.** About 41 h of sim. Measure the highest `rate` a single quiet
  OPS 2 GPC sustains on the fast host:
  - at 5-10×, this stage is an overnight run with captures at each burn;
  - if the GPC cannot go much above 1×, look at a "coast skip": restore a
    capture with the clock advanced and the truth propagated, then
    re-uplink both state vectors. That needs the MTU/GMT and PASS's
    navigation time to move together, which is unexplored. Treat it as
    research, not a given.
- **Differential drag** between the Orbiter (`phys_set_drag`) and the ISS
  (BC 130): sanity-check it against the 2011 decay rates.

**Exists.** The OMS 2 capture and the ORBIT phase, OMS burns, the message 9
uplink, `deorbit_target.py` as a template, the ISS's TLE pair for days
137-138.

**Missing.** The planner, the message 16 verb, the FD1-FD3 crew procedures,
and the run time.

**Effort: 6-10 days, plus wall time.**

### Stage 8: integration into the flight

**New phases in `fly_sts134.py`** after ORBIT, with captures:
- **PHASING**: FD1-FD3 burns to NC4;
- **RNDZ**: Ti − 3 h through MC4, covering Stages 1-3;
- **PROX**: MC4 through contact, covering Stages 4-6;
- **DOCKED**: ends mated.

**The fast-start path.** The quick M1-style start stays as
`--rndz-start` for development: it begins at NCC − 10 min from the
relative-state tool.

**Timeline.** A `TIMELINE-STS134-RNDZ.md` like the ascent and entry
timelines: who acts, what PASS did, against the STS-134 actuals.

**Undocking and the STORRM re-rendezvous** (TPI 3.4 ft/s, 42° EL) are
optional follow-ons from the same machinery.

**Effort: 3-4 days.**

## 7. Effort summary

| Stage | Days |
|---|---|
| M1 (Orbiter start relative to the ISS; message 10; nav, Ti targeting, target track) | 3-5 (+1-2 for the Ti burn) |
| 1 Star tracker target track | 4-6 |
| 2 Onboard targeting and RCS/OMS burns | 4-6 |
| 3 Rendezvous radar | 6-9 |
| 4 COAS / TCS / HHL / camera instruments | 3-4 |
| 5 Manual phase pilot | 8-12 |
| 6 Contact, capture, mated stack | 3-6 |
| 7 FD1-FD2 phasing | 6-10, plus wall time |
| 8 Integration and timeline | 3-4 |
| **Total** | **about 40-60 working days** |

**Suggested order:** M1 → 2 → 1 → 3 → 4 → 5 → 6 → 8 → 7. Phasing comes
last because it is the slowest to run and adds the least that is new.

## 8. Open questions to settle early

1. **I-loads on this tape:**
   - the targeting sets `CGZV_*_ILOAD_ARRAY` / `CGZB_LAMB_ILOAD`;
   - the DAP configurations A7-A12;
   - `CGNV_TARGET_KFACTOR`;
   - the RR/ST mounting constants.

   Read them from an OPS 2 capture with `tools/pasvar.py`. If they are
   zero or another flight's, choose between crew-keyed sets (as the
   checklist allows) and an OPS 2 reconfiguration overlay.
2. **SM OPS 2.** Is it on the tape, and can a G2 + SM pair run alongside?
   That would bring in SM 2 TIME, SM ANTENNA, SM 167, and the real Ku
   antenna management.
3. **The COAS mark discrete:** confirm that `CGEB_FLT_LG2_FLAG1_MFE`
   bits 12-13 are the ATT REF pushbuttons.
4. **The RR word bit map and units.** The FSSR NAVAIDS RR SOP (4.229) is
   not in the repository.
5. **Achievable `rate` in OPS 2.** This decides Stage 7's approach.
6. **The ISS's docking attitude and mass properties** for ULF6. They are
   needed only for Stage 6.

## Sources

- **JSC-48072-134 Rendezvous checklist, Final Rev A** (2011-03-15, PCN-2).
  Mirrored at ibiblio:
  https://ibiblio.org/apollo/Shuttle/Rendezvous/STS-134%20Rendezvous.pdf.
  The target sets, item numbers, braking gates, RPM and procedures above
  are from its pp. 1-2..1-11 and 4-5..4-22, and cue cards CC 9-6..9-12.
- **T. Stuit, "Designing the STS-134 Re-Rendezvous"** (AIAA; NTRS
  20110014805): the SOR profile, RR maximum range 135 kft, TCS/HHL roles.
- **STS-134 actual times:** Ti 07:38 UTC (left OMS about 10 s), RPM from
  09:15 UTC, docking 10:14 UTC on 2011-05-18, from collectSPACE flight day
  journal FD3 and the NASA status reports via SpaceRef / NASASpaceflight.
- **Flight source OI-34** (`~/workspace/PFS/OI340600`, OI340700 overlay):
  GTBUPL, GYNRRP, GY3STT, GY6COA, GYZSTS, GK3ORB, GWRORB, GKQORB, GKVREL,
  GVUUNI, GOAGNC, CGZMC2, CGBIM1, MLIB80/FIOMFBCE.asm, BCEEQU.asm.
- **This repository:** `vehdyn.c`, `mdmdev.c`, `startrk.c`,
  `STAR_TRACKER_PLAN.md`, `TIMELINE-STS134.md`, `CAUSES.md` (#159, #164),
  `discretePanel/groundstation.py`, `portview.py`, `SCRIPTABLE_CONTROLS.md`,
  `examples/flights/fly_sts134.py`, `examples/1gpc-ops201-imu.script`.
