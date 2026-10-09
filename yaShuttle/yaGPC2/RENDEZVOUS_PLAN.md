# STS-134 rendezvous with the ISS: plan

Written 2026-10-08. **Status:** the first milestone (M1, and a first try
at M1b) is built and has flown; see section 5a.  Stage 1's star tracker
target track is built and has flown to Ti; see section 5b -- with one
blocker in this tape's I-loads.  Stage 2's midcourses MC1-MC4 are built and
have flown; see section 5c -- with a second I-load question (the Lambert
flags) and a navigation finding (PASS drops burns under 0.9 ft/s).
Everything else is still a plan.  The plan was written read-only from the repository, the
flight source, and the documents listed under Sources.

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

## 5a. M1 as built and flown (2026-10-08, macOS)

**How to run it** (one line; about 75 min at rate 1 to TI, 2.6 h to the
end of COAST):

    python3 examples/flights/fly_rndz134.py --logs DIR --port-base 48600 --rate 1 --to TI

from `discretePanel`, with the STS-134 volume
(`--tape`, default `~/dropbox-copy/sts134-ksc6-entry/OI340700-v44boot-sts134-ksc6.mmv`)
and the ISS targets file (`--targets`, default
`~/sts134-runs/rendezvous/sts134-targets.txt`).  Without `--to TI` it goes on
to TIBURN (the Ti burn, M1b) and COAST (to T2).  `rndz-check.log` in DIR is
the record: PASS's relative state against the truth every `--check-every`
s, the Orbiter's navigation error in LVLH, the -Z axis's angle to the ISS,
and each Ti solution beside the independent Lambert.

**What was built.**
- `vehdyn.c`: `YAGPC_VEHDYN_START_REL=NORAD,X,Y,Z,XD,YD,ZD[,UNIX]`, the
  Orbiter placed off a target in PASS's own target-centred curvilinear LVLH
  (GWJ_ORB_TGT_REL_COMP's inverse, GWJORB.hal), at the time UNIX, coasted to
  the moment the calendar becomes known (the IPL's HALT puts that a minute
  or two after `--date-time-epoch`); attitude +XVV -ZLV at the orbital rate.
  Unit test `test/test_vehdyn_rel.c`.
- `vehdyn.c`, **a bug fix**: the forward verniers F5L/F5R fire DOWN (they
  are named for their side, not their plume).  Read as a left- and a
  right-firing jet they gave no pitch, and VERN attitude hold fired them
  without end (0.09 kg/s).  Test in `test_vehdyn.c`.
- `mtumodel.c`: `YAGPC_MTU_MET_EPOCH=<Unix time>`, the timing unit's MET
  accumulator counting from liftoff, so a run started on orbit has the
  flight's MET (PASS takes its MET reference as GMT less the unit's MET,
  FPMMTURM) and the crew keys the burn pad's MET times.  Default unchanged.
- `tools/rndz_start.py`: `start` (the starting state) and `lambert` (the
  acceptance check: conic and precision J2-J4 Lambert, PASS's LVLH).
- `groundstation.py tsv`: message 10 from TGT1 (and `--state`).
- `examples/flights/fly_rndz134.py`: the driver.  It reads PASS's own
  variables out of capture memory images at the DASS addresses of the
  OI-34 GNC2 map (`PFS/mafgen/DASS_G2.ASC`), checked on each image against
  the Lambert flags' INITIAL.

**Corrections to the plan above.**
1. **The Ti point is not reached co-elliptically.**  The checklist's ORBT
   RENDEZVOUS PROFILE (p. 1-5) has NC at PET -1:32, 246 kft behind and about
   1.2 kft below, starting a one-revolution loop that dips some 40 kft below
   the station and comes up to the Ti point, arriving with XD about
   -9 ft/s.  From there Ti is a posigrade burn of about 9 ft/s (STS-134 flew
   8.4); from a co-elliptic arrival (XD = 1.5 n DZ, item 2 of section 5) it
   would be a 2.7 ft/s retrograde one.  `rndz_start.py start` puts the
   Orbiter on the nominal NC arc (a J2-J4 shooting solution from the NC
   point to the Ti point, coplanar at NC); at 06:30 that is 237.5 kft behind
   and 20.8 kft below, closing at 35 ft/s.
2. **This tape's orbit-targeting I-loads are zero** (all 40 sets; read from
   the IPL capture), the generic source's INITIAL(0); the Lambert flags are
   the source's (10 ON).  The crew keys TGT 10 (ITEM 6, 17, 18-20) and
   LOADs it, as the checklist's "check TGT set data" allows.  The target
   drag I-loads are mass 1, CD 2, area 1; no K-factor (message 42) was sent.
3. **`--rate 2` works (fixed in b4eb048).**  At first, with SPEC 33 up, the
   IDP's transfers broke at rate 2 ("transfer abandoned", the bus pump not
   answering) and every key after SPEC 33 was lost.  The cause was macOS
   App Nap throttling MEDS2 while its windows were unseen; macdock.py now
   opts every GUI program out and MEDS2's bus pump yields between buses,
   and the fixed code reached TI at rate 2 cleanly.

**Results** (run DIRs `~/sts134-runs/rendezvous/m1-run2`, `-run3`, `-run4`).
- **The uplinks land.**  A minute after messages 9 and 10 (run m1-run2),
  PASS's range and rate (from its own states in the downlist, format 22)
  agreed with the truth to **+0.5 ft and +0.003 ft/s**; ten minutes later
  +2.3 ft and +0.005 ft/s.  SPEC 33 showed RNG 208.324 kft, RDOT -61.86.
- **Target track.**  UNIV PTG TGT ID 1, BODY VECT 3: the maneuver took about
  4 min; in B/AUTO/ALT the -Z axis held 2.6-2.9 deg off the ISS, in
  A/AUTO/VERN **0.2-1.0 deg** (PASS's own attitude errors agree: the DAP's
  deadband).  In portview's overhead view the ISS (sunlit, ~51 kft out) is
  the disc 7.3 deg from the view's centre toward the nose -- the view looks
  5 deg aft of -Z.
- **Ti, TGT 10, COMPUTE T1** (BASE TIME = T1 TIG = MET 001/18:41:32, GMT
  138/07:38:00; DT 76.9 min; T2 offset -0.9, 0, +1.8 kft):

  | | DVX | DVY | DVZ | DVT ft/s |
  |---|---|---|---|---|
  | PASS, preliminary (Ti -50 min, MM 201) | +9.03 | -0.68 | +2.46 | 9.39 |
  | Lambert from PASS's own states, preliminary | +8.90 | -0.88 | +2.63 | 9.33 |
  | PASS, final (Ti -17 min, MM 202) | +9.02 | -0.68 | +2.44 | 9.37 |
  | Lambert from PASS's own states, final | +8.89 | -0.88 | +2.60 | 9.31 |
  | Lambert from the truth, final ("ground") | +8.62 | -0.68 | +1.98 | 8.87 |
  | STS-134 as flown | | | | ~8.4 |

  PASS's solution is within 0.2 ft/s per axis of the independent one from
  the same states, and within the final-ground limits of the truth's.  A
  second, clean run of the one-line command (`m1-run4`, `--to TI`, final in
  MM 201) gave PASS +9.07 -0.68 +2.52 (9.44) against +8.94 -0.89 +2.69
  (9.38) from its own states and +8.56 -0.68 +1.85 (8.79) from the truth.
  In that run the first comparison after the uplinks, with the target-track
  maneuver already under way, was -0.8 ft and -0.039 ft/s: the 0.01 ft/s
  holds only until the jets start (see the drift below).
- **The Orbiter's PROP navigation error** -- 1 ft at the uplink, 2 kft
  and 2.1 ft/s (mostly LVLH Z) by Ti - 23 min, the target's within ~160
  ft -- **is not an IMU artefact and not a drift.**  It is put in during
  the first few minutes of attitude control after the uplink, by PASS's
  own rule for small maneuvers, and orbital mechanics grows it from there
  (investigated 2026-10-08, runs `imu-diag1`-`3`):
  - *GL5NAV steps 9A-9C.*  On orbit PASS takes IMU velocity into the state
    only while a "maneuver" is in progress (any jet fired since the last
    3.84 s nav cycle, or a sensed acceleration over threshold), summing it
    in GL5_DV_SUM; when a cycle without jets ends the maneuver, a sum under
    0.9 ft/s is **removed** -- the velocity is put back as if nothing had
    happened (CGNV_DV_COUNT, the count of maneuvers accepted, stayed 0 all
    run).  Attitude control does translate the vehicle, and that real
    translation goes out with the sum.  Watched in PASS's memory
    (YAGPC_WATCHHW on GL5_DV_SUM) from the RNDZNAV capture: four maneuvers
    in 125 s were removed, -0.49 +0.51 +0.00 ft/s M50 in all, and at each
    removal PASS's velocity error jumped by that sum; the largest, 0.34
    ft/s, was the target-track maneuver's start in B/AUTO/ALT -- L2D and
    R2D alone for 1.6 s (PASS's own ALT jet choice, ALT_MAX_JETS 2), 1740
    lbf x 1.6 s / 8354 slug = 0.33 ft/s, and the truth's sensed delta-V
    agreed (0.33); the others were VERN attitude control before it (single
    verniers on for 2-16 s at a time).  PASS's sums agreed with the truth's
    sensed delta-V to 0.01-0.02 ft/s.
  - *The growth afterwards is Clohessy-Wiltshire.*  From the Ti - 54.5 min
    error (52 25 191 ft, -0.05 +0.06 +0.56 ft/s LVLH) CW alone predicts, at
    Ti - 28.8 min, 1786 50 946 ft and +0.82 -0.04 +2.26 ft/s; m1-run4 had
    1743 49 912 ft and +0.78 -0.04 +2.18.  (A comparison in the rotating
    frame must take omega x dr out of the velocity error; without that it
    looked like a 6e-4 ft/s^2 drift.)  In coast the nav takes no IMU data
    at all -- CGNV_DV_FILT is zeroed every cycle (GL5NAV step 8) -- and the
    truth Orbiter and the truth ISS agree with each other to under 1 mm/s
    in 220 s against a gravity-only propagation.
  - *The IMUs are right.*  Each IMU's compensated total (CGMV_TOT_DV_M50,
    downlist) follows the truth's sensed delta-V to within a pulse; PASS's
    time tags match the model's read times to 0.2 ms; a new test
    (test_mdmdev, 30 min coasting while turning at orbital rate) holds every
    compensated axis to one pulse.  The 19 micro-g wander of CGMV_VEL_SEL
    is PASS's own: GRJIMU re-anchors each IMU's bias to the selected
    velocity every 0.96 s, so GRHIMU's mid-value select works on per-cycle
    increments, and the mid value of three accelerometers' quantised
    (floor/ceiling) counts is not zero-mean; a replay of the logged counts
    (YAGPC_IMU_ACCLOG) gave the same sign and order of size.  A real IMU counts the same way.  It reaches the
    state only inside a maneuver, and is removed with the sum.
  - *For the real flight*, the same: maneuver-induced translation under 0.9
    ft/s is lost to PROP, which is why the flight burned NCC and Ti on the
    FLTR state (star tracker marks) and why MC1-MC4 exist.  How large the
    loss is depends on the DAP: this tape's DAP B (ALT, unconfigured, no
    SPEC 20 B7) turned the vehicle at 0.64 deg/s with two aft jets.
- **M1b (first try).**  PROP was within the limits of the ground solution,
  so PROP was burned (p. 1-3 rules).  Both OMS engines fired, 6.96 s each,
  not the left alone: the engine select keyed before COMPUTE T1 did not
  survive it (the driver now keys "Eng sel" again after it, as RNDZ OMS
  BURN step 2 checks it).  With the navigation 2 kft and 2 ft/s off, the
  truth was predicted to arrive at T2 some 28.8 kft behind the aim point --
  the miss that sensor navigation and MC1-MC4 exist to remove.  Flown on
  to T2 (Ti + 76.9 min, the coast in -Z target track) it arrived **25.3 kft
  behind, 0.7 kft right and 1.0 kft below** the station, closing at
  0.6 ft/s, instead of TGT 10's 0.9 kft behind and 1.8 kft below.  The
  truth-based ("ground") solution would have reached the aim point; under
  the checklist's rules PROP was nonetheless the one to burn, being within
  the limits, so with no sensor pass the miss is the honest outcome.
  M1b is therefore not passed: it needs the navigation drift above
  understood, or Stage 1's sensors, or both.
- **M1b again (2026-10-08, `m1b-run2`, and `m1b-run3` from its Ti capture).**
  The left engine alone now burns (L 12.48 s, R 0).  PROP +9.03 -0.68 +2.47
  against the truth's ("ground") +8.92 -0.67 +2.81 ft/s: within the limits,
  PROP burned; the Orbiter's nav error at final targeting was ~2.1 kft, 1.8
  ft/s, put in by the target-track maneuver as above.
  - `m1b-run2`, on the two-engine trims (P +0.4, LY -5.75) the driver left in
    place: residuals VGO -- body -- +0.04 -2.15 +1.01 ft/s (the burn
    attitude was computed for thrust along X; the left gimbal then swung
    ~13 deg to put the thrust through the CG), untrimmed.  At T2 the truth
    was **0.12 kft behind, 1.46 kft out of plane, 3.20 kft below**, closing
    XD +4.23 YD +1.02 ZD -3.76 ft/s.
  - `m1b-run3`, the same Ti state, with PASS's one-engine trims keyed (P
    -0.1, LY +5.2, the CGGC02 I-loads): residuals +0.05 +0.32 -0.20 ft/s
    (the THC trim moved nothing: no hand-controller window was running;
    fixed for the next run, `--rhc lh`).  Truth sensed delta-V of the burn
    9.42 ft/s.  At T2 the truth was **3.82 kft ahead of the station, 0.30
    kft out of plane, 2.31 kft below**, XD +1.97 YD -0.28 ZD -3.09 ft/s,
    against TGT 10's -0.9 / 0 / +1.8 kft: a miss of 4.7 kft along track,
    0.3 across, 0.5 low.  It crossed the R-bar (X = 0) at Ti + 64.5 min
    about 5.5 kft below, not the 600-1,800 ft of the MC4 region.
  - Both coasts carried ~0.5 ft/s of real attitude-control translation (the
    post-burn ALT target-track maneuver, then VERN), which alone moves T2
    by kilofeet; that and the PROP error are what MC1-MC4 (and the sensor
    filter) are for.  M1b's trajectory therefore lands within a few kft of
    the aim point but not in the MC4 region; flying MC1-MC4 is the next
    step.

**Deviations, recorded.**  One GNC GPC where the rules want two; no SM, so
no SM 2 TIME, SM ANTENNA or SM timer; DAP A7/B7 not configured (SPEC 20
not keyed: this tape's configurations are unchecked); TGT sets keyed, not
I-loaded; the burn pad's TV ROLL and trims left at PASS's own; no drag
K-factor uplink; the orbiter's mass is the liftoff figure with full OMS
tanks (`YAGPC_VEHDYN_ORBITER_KG` has no FD3 form).

## 5b. Stage 1 as built: the -Z star tracker's target track (2026-10-08, macOS)

**How to run it** (one line; about 45 min at rate 2):

    python3 examples/flights/fly_rndz134.py --logs DIR --port-base 48800 --rate 2 --start-utc 2011-05-18T06:10:00 --to TI

New phases STRKNAV (STAR TRACKER NAV [10A]) between TRACK and TI, and
STRKEND (END S TRK NAV [10B]) between TI and TIBURN; `--no-strk` skips
both.  Every --check-every s, `rndz-check.log` gets a `strk:` line: the
-Z tracker's words, PASS's display status, marks, ACPT/REJ, RESID,
SV UPDATE POS and FLTR MINUS PROP, and PASS's relative state, FLTR and
PROP, against the truth (all from the format-22 downlist; the FLTR, PROP
and target states are staged together at one T_STATE).

**The interface, from the flight source and the checklist.**
- The tracker has no target mode.  SPEC 22 -Z(-Y) TGT TRK ITEM 6(5) sets
  CGYB_MODE_CMD 3 (GYZSTS); GY3STT then breaks track, commands an offset
  scan box at the LOS PASS predicts from its own states (GY5FOV; offset
  code 15.5 + 15.5 x deg / 4.75; threshold from THOLD, ITEM 13/14), waits
  4 s for STAR PRESENT, falls back to a 20 s full-field scan, then NO
  TARGET (status 6) and starts over.  GY8DAT averages 21 samples (steady
  within TOL6, body rate under TOL8) into CGYV_H/V_NAV, time and TM50ST;
  GLCSTA/GLZANG incorporate them (S TRK ITEM 12, AUTO/INH/FORCE angles ITEM
  23/24/25; edits set FALSE TARG, which makes GY3 break track and search
  again).  The angles' residuals are GLZANG's: atan2 of the c.g.-to-c.g.
  LOS in tracker axes plus a sensor bias state (GLQREN).
- STAR TRACKER NAV [10A] (JSC-48072-134 p. 4-10): IMU DES, SV SEL PROP,
  INH angles, S TRK; THOLD +3 both; TGT TRK; at S PRES the residuals four
  cycles (BREAK TRK, ITEM 8, if they jump > 0.05 or exceed 0.6 deg); AUTO
  angles; SV SEL FLTR when SV UPDATE POS < 1.0 kft with ACPT > 9.
- The nominal pass is a daylight pass at ~40 nmi before NCC; the -Z
  tracker on every Orbiter from STS-117 was an image dissector, which
  tracked the large, bright ISS where the solid-state ones tripped target
  suppress (Herrera, "Space Shuttle Star Tracker Challenges", NTRS
  20110003998).

**yaGPC2** (`startrk.c`, TARGET TRACK in its header): the ISS is one more
object the raster can cross, from the nav base, sunlit only (Earth's
shadow with the Sun's disc; not behind the Earth), magnitude from range and
a Lambert phase function (standard -2.0 at 1000 km; -7 to -9 at 40 nmi),
the light's centroid toward the Sun (Lambert sphere, r 44.6 m), the stars'
20 arcsec noise and the word's count.  Captures keep it.
`test/test_startrk_target.c` (27 checks).

**THE BLOCKER: this tape initialises PASS's star tracker angle bias to 1.0
RADIAN.**  GLQREN's local `GLQ_ST_ANGLES_BIAS_INIT ARRAY(2) INITIAL(1.0,
1.0)` (the RR and COAS ones too) is copied into CGNV_SENSOR_BIAS when the
angle set comes in, and GLZANG adds it to the predicted angles.  In memory
at X'0B47E' (#DGLQREN X'0B45C' + X'22'); CGNV_SENSOR_BIAS_TLM reads 1.0 in
every capture of `strk-run1`.  So every residual is about 57 deg off; the
first two marks were accepted (the covariance is wide), the FLTR state was
dragged 45-56 kft off, and every later mark rejected (RESID H -112 V -9,
which is exactly the measured angle less 57.3 deg less the angle from the
dragged state).  The bias variance beside it is 1e-6 rad^2 (1 mrad sigma):
1.0 rad cannot be a flight value.  Whether the real I-load was 0 (or
anything else) needs a document this repository lacks -- the FSSR STS
81-0006 Part B 4.2.7 or the flight's I-load listing.  **Ron's call.**

**Runs** (`~/sts134-runs/rendezvous/`).
- `strk-run1`, the one-line command from 06:30 with the tape as it is.
  TRACK finished at Ti -51 min; the ISS went into the Earth's shadow at
  06:43 (Ti -55) and out at 07:17 (Ti -21), so the pass found nothing until
  sunrise; then the tracker locked (full field: PASS's PROP LOS was 1.4 deg
  off, outside the 1 deg box) at 59.8 kft, and the 1 rad bias ruined the
  FLTR state as above.  SV SEL stayed PROP; Ti on PROP as in M1.
- `strk-run2`, from 06:10 (`--start-utc`, PET -1:28, the checklist's [10A]
  time; 40 nmi out), with `GLQ_ST_ANGLES_BIAS_INIT` set to 0.0 in the
  UPLINK capture before RNDZ NAV ENA -- an EXPERIMENT, not a fix.  S PRES
  at Ti -67.4 min, 237.6 kft; initial RESID H -0.001 V -0.023 deg, steady;
  the first SV UPDATE POS 0.090 kft; ACPT 11/11 at Ti -65.4, SV SEL FLTR;
  91/91 accepted by the ISS's sunset at Ti -55, 129/129 by Ti -16 (marks
  again from sunrise, 57 kft); none rejected.  PASS's estimated angle
  biases 0.22 and -0.29 mrad (the light's centroid and the lever arm).

  | Ti - min | FLTR rel. error ft (x y z) | |r| | PROP rel. error ft | |r| |
  |---|---|---|---|---|
  | 56.6 | +183 -29 +42 | 190 | +517 -35 -11 | 519 |
  | 45.1 | +174 +51 -36 | 185 | +415 -34 -499 | 650 |
  | 34.3 | +74 +105 -82 | 152 | -511 -14 -1055 | 1172 |
  | 22.0 | -75 +99 -62 | 139 | -2398 +20 -1411 | 2782 |
  | 15.8 | +168 -70 -37 | 186 (0.46 ft/s) | -3468 +33 -1395 | 3738 (3.9 ft/s) |

  PROP is the run without marks (the same trajectory; it grows from the
  dropped small-maneuver delta-V, as in 5a, to 3.7 kft and 3.9 ft/s here
  over the longer run).  PASS's own range at Ti -16 min: -169 ft and +0.27
  ft/s from the truth (strk-run1, on PROP: -905 ft, +1.38 ft/s).
- Ti on FLTR (TGT 10, COMPUTE T1): preliminary +9.82 -0.63 +4.28 (10.73)
  against the truth's precision Lambert +9.82 -0.71 +4.32; final +9.93
  -0.83 +4.15 (10.79) against +9.79 -0.71 +4.31 -- within 0.16 ft/s per
  axis, well inside the final-ground limits.  (The 10.7 ft/s, not M1's 9,
  is the 06:10 start's coast without NCC.)

**Not done.**  The night: [18E] tracks on after sunset at THOLD 0 and
nothing here says by what light, so the station is invisible in shadow.
NCC itself (Stage 2).  The S TRK NAV contingencies (5-8, 5-9) beyond the
break-track retries.  The IMU deselect is IMU 1 (MCC's call).  The
solid-state -Y tracker's target suppress.  The 1 rad I-load above.

## 5c. Stage 2 as built: MC1-MC4 (2026-10-08, macOS)

**How to run it** (one line, from a Ti capture; about 50 min at rate 2
from Ti - 15 min to the arrival):

    python3 examples/flights/fly_rndz134.py --logs DIR --port-base 48800 --rate 2 --start-utc 2011-05-18T06:10:00 --from TIBURN --zero-sensor-bias --lambert-mc

with DIR holding `sts134r-ipl`, `sts134r-ti` and `sts134r-strkend` from a
Stage 1 run (or no `--from`, the whole flight from 06:10).  New phases after
TIBURN: POSTTI, MC1, MC2, MC3, MC4, ARRIVAL; `--no-mc` gives the old COAST
instead.  `burns.json` and the THE BURNS table in `rndz-check.log` are the
record: every PASS solution beside the truth's precision Lambert ("ground")
and the checklist's MEAN and 3 SIGMA, and what each burn put into the
truth.  `mc-state.json` carries the TIGs, solutions and THC accelerations
from phase to phase, so `--from MC2` (say) goes on from a capture.

**What was built (`fly_rndz134.py`).**
- **The timeline** (pp. 4-16 to 4-21): POST Ti NAV [16A] (FLTR TO PROP) and
  STAR TRACKER NAV [10A] again after Ti; TARGET MC1 [17A] preliminary,
  intermediate and final; TARGET MC2 [17B]/[18A]/[18B] with EL 29.07 and
  the TIG slip limits (-3/+7 min, TGT 19 with BASE TIME = nominal -3 or +7);
  MANUAL OUT-OF-PLANE NULL [19A] when PASS's Y crosses 0; END S TRK NAV
  [18C] after MC2; TARGET MC3 [19B] and MC4 [20A] with BASE TIME = MC2 TIG;
  each block's "SV SEL correct" check, which selects FLTR once the pass has
  converged (ACPT > 9, SV UPDATE POS < 1.0).
- **The target sets.** `target(n)` generalises the TGT 10 code: TGT_SETS
  holds 10-14 and 19 from TARGETING DATA (p. 6-4, the TGT ALTITUDE 210 rows
  that the timeline prints).  This tape's sets 11-14, 19 are zero, so they
  are keyed (T1 TIG, EL, DT, offsets) and LOADed, each entry checked in a
  capture and keyed again if lost (one T1 TIG entry was, in mc-run3).
- **RCS BURN (CC 9-3)** for a multi-axis midcourse: OPS 202, RCS SEL, the
  final targeting in MM 202, LOAD, TIMER; DAP A/AUTO/PRI and TRANS NORM at
  TIG - 30 s; at TIG the VGOs nulled with the THC, Z,X,Y if VGO Z is
  negative, else X,Y,Z, to < 0.2 ft/s; DAP ALT, PULSE, OPS 201, the -Z
  track again.  A burn whose TIG has passed is not flown.
- **The VGO-nulling loop** (also the Ti burn's residual trim) reads VGO from
  the format-22 downlist (CGZV_VGO, frames 17 and 42), flies every axis
  back to back in one script, and learns each THC direction's acceleration
  (DAP A7, PRI, NORM, ft/s^2: +X 0.40-0.54, -X 0.42-0.45, +Y 0.44, -Y
  0.28-0.38, +Z 0.52-0.73, -Z 1.03-1.22; the checklist's one figure, +X
  0.25, was low, and a first -Z hold on it overshot 0.8 ft/s by 3.9).
- **Ground solutions.** `--mc-rule limits` (the default) compares each final
  onboard solution with the truth's Lambert at the same TIG, by Ti's
  final-ground limits (1.3, 1.3, 1.1 ft/s), and keys the ground's EXT DVs
  (ITEMs 10-13, 19-21) when it is outside; `--mc-rule onboard` always burns
  the onboard one, as p. 1-3 says.
- **Two run-only I-load experiments**, explicit options, never the tape:
  `--zero-sensor-bias` (5b's blocker: GLQ_ST_ANGLES_BIAS_INIT 1.0 rad to 0,
  in the capture resumed from) and `--lambert-mc` (below).  Both await Ron's
  decision.

**What the runs found** (run DIRs `~/sts134-runs/rendezvous/mc-run1`..`6`).

1. **PASS throws away any burn under 0.9 ft/s.**  GL5NAV (steps 7-9C) sums
   the IMU-sensed velocity over a "maneuver" -- jets fired in every 3.84 s
   cycle -- and when a cycle passes without jets removes the sum if it is
   under 0.9 ft/s (GL5_VEL_THRESH INITIAL(0.9), a constant, not an I-load).
   The checklist's midcourses are mostly under that: MC1 flew 0.50-0.54
   ft/s, and PASS's CGNV_DV_COUNT stayed at 1 (the Ti burn) with
   CGNV_DV_DISP the Ti burn's alone.  mc-run1's first VGO loop nulled one
   axis at a time with a capture between; each hold (0.2-0.6 ft/s) was its
   own maneuver and all were removed; the loop now flies the axes back to
   back, but a whole burn under 0.9 still goes.
2. **Then the star tracker's angles walk the FLTR state off in range.**
   With a 0.5 ft/s velocity change missing from the state, the marks that
   follow (all accepted, residuals 0.00-0.03 deg) fit it with range: FLTR
   went from 134 ft to 4.3 kft in a minute after MC1 and to 10-11 kft and
   12 ft/s by MC2 (mc-run2), along the line of sight.  Angles alone do not
   observe range; the flight had the rendezvous radar (Stage 3) for that,
   and an MCC "Prox Ops Cov Matrix" uplink and COVAR REINIT after Ti
   ([16A]), neither modelled.  Hence `--mc-rule limits`.
3. **This tape's CGZB_LAMB_ILOAD has Lambert only for sets 1-10** (the
   source's INITIAL(10#ON, 30#OFF)), so GK3 sent TGT 11-14 to the
   non-Lambert GWG, which ignores the elevation angle (mc-run2: MC2's TIG
   stayed at its seed, Ti + 49.90 min).  MC2's EL of 29.07 deg is a GWR
   (GWS) feature, so the flight's I-loads must have had these sets ON;
   `--lambert-mc` sets 11-14 and 19 ON in the capture resumed from -- an
   EXPERIMENT pending Ron's decision.
4. **With Lambert, MC2's elevation search lands revolutions away** from the
   FLTR state after MC1 (Ti + 466.6 min in the preliminary, + 883 in the
   intermediate, each search seeded from the BASE TIME the last one moved,
   GWRORB step 140).  In mc-run2 the truth's elevation passed 29.07 deg at
   about Ti + 55 min (17.9 deg at Ti + 49.9, 60.7 at Ti + 66.9), inside
   the slip limits.  The checklist's slip
   rule then applies, and the driver flies TGT 19 at nominal + 7 min.
5. **Driver bugs fixed on the way:** COMPUTE T1's completion test
   (CGZV_MAN_TGT_NO stays 11 after the first Lambert set; the GK3 flag alone
   accepted MC1's numbers for TGT 19's); a -Z track "complete" that waited
   20 min because PASS points -Z where its own (wrong) state puts the ISS
   (now also complete when the vehicle stops turning); MC4 started after its
   TIG had passed; the MC2 schedule taken from a TIG hours away.

**Results.**  The pieces were flown in a chain of captures, each run
resuming the last good one: Stage 1's `strk-run2` Ti capture; `mc-run2`
TIBURN to POSTTI (the Ti burn, now trimmed in one pass); `mc-run3`
POSTTI and MC1 with `--lambert-mc`; `mc-run7` MC2; `mc-run8` MC3, MC4
and the arrival.  All with `--zero-sensor-bias --mc-rule limits`, rate 2.
The THE BURNS table of `mc-run8` (ft/s, LVLH):

| Burn | PASS (onboard) | Lambert from the truth ("ground") | Checklist mean (3 sigma) | Burned (truth sensed) |
|---|---|---|---|---|
| Ti final (FLTR) | +9.98 -0.83 +4.10 | +9.79 -0.71 +4.32 | -- | 10.79 ft/s, L OMS 14.4 s; residual -Y nulled to 0.10 |
| MC1 final (PROP) | -0.08 -0.44 +0.27 | +0.07 +0.13 +0.53 | -0.1 (0.6), -0.1 (0.7), +0.5 (1.2) | onboard: +0.05 -0.40 +0.30 |
| MC2 final (TGT 19, nominal + 7) | ALARM KILL | -0.05 -0.41 +0.34 | 0.0 (0.4), 0.0 (0.2), +0.9 (2.5) | ground: -0.14 -0.50 +0.24 |
| MC3 final | ALARM KILL | +0.31 +0.12 +0.32 | +0.9 (1.3), 0.0 (0.5), +1.1 (2.6) | ground: +0.40 +0.01 +0.36 |
| MC4 final | ALARM KILL | +0.67 -0.01 -1.47 | +1.3 (1.3), -0.1 (0.6), +0.9 (2.2) | ground: +0.65 -0.03 -1.57 |

**Arrival** (TGT 14's T2, MC4 + 13.4 min): the truth **16 ft behind, 11 ft
out of plane, 551 ft below the ISS**, XD -0.07 YD +0.09 ZD -0.66 ft/s,
against the aim point 0, 0, +600 ft -- the R-bar, ready for the manual
phase.  The ground's burns are all within the checklist's 3 sigma except
MC4's Z (-1.57 against +0.9 +- 2.2: the low side; MC2 was flown 7 min late
on TGT 19).  PASS's own Lambert solutions after MC1 all ended in ALARM KILL
(GWY/GWM's Lambert or transfer-time alarm; CGZB_ALARM_KILL, PRED MATCH
999999) -- every one of them on the FLTR state that the marks had walked off
after MC1's dropped 0.5 ft/s (item 2: 4.5-11 kft, 6-12 ft/s); MC1's, on
PROP, was fine.  Why GWR gives up on that state, rather than solving it
wrongly, is not yet understood.  PASS's navigation at the arrival: FLTR =
PROP (FLTR TO PROP at [18B]), 1.8 kft and 2.4 ft/s off; PASS's range
2.4 kft against the truth's 530 ft -- the radar's job.

Earlier runs, kept for the record: `mc-run1` (the per-axis VGO loop: MC1
dropped, FLTR walked 8 kft; stopped), `mc-run2` (no `--lambert-mc`,
non-Lambert MC sets, the onboard solution always burned: MC2 +2.46 -0.65
+6.34 ft/s from a FLTR 10 kft off, against the ground's +1.35 -0.51 +4.12;
MC4's TIG passed during a 20-min track wait), `mc-run3`..`6` (the fixes in
item 5, one at a time; `mc-run5` flew MC3 and MC4 on ground solutions with
MC2 not flown and arrived 5 ft behind, 34 out of plane, 161 ft below).


**Not yet exercised.**  The one-line command above has not been flown end
to end in one run: the result is the chain of resumed captures listed under
Results, each with the code as it then stood.  A fresh run with
`--zero-sensor-bias` or `--lambert-mc` restarts itself from its UPLINK
capture to patch it (`restart_from`): written, not yet run.  MANUAL
OUT-OF-PLANE NULL [19A] never fired: PASS's Y did not cross 0 between MC1
and MC2 - 14 min in any run.

**Not done.**  The rendezvous radar (Stage 3), on which the flight's MC3-MC4
navigation stood -- here MC3 and MC4 use the propagated FLTR state or the
ground's solution.  NIGHTTIME STRK OPS [18E] (the ISS is invisible in the
Earth's shadow from Ti + 36 min, 08:14 UTC: the last S PRES).  The MCC covariance uplink and COVAR
REINIT ([16A]).  +X and OMS midcourses (p. 1-3, > 4 ft/s): every MC is flown
multi-axis.  The burn pad and "Record solution in PAD" beyond the log.  The
two I-load questions (sensor bias, Lambert flags) are Ron's.

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
