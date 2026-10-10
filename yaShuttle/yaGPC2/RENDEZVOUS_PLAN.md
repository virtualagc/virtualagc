# STS-134 rendezvous with the ISS: plan

Written 2026-10-08. **Status:** the first milestone (M1, and a first try
at M1b) is built and has flown; see section 5a.  Stage 1's star tracker
target track is built and has flown to Ti; see section 5b -- with one
blocker in this tape's I-loads.  Stage 2's midcourses MC1-MC4 are built and
have flown; see section 5c -- with a second I-load question (the Lambert
flags) and a navigation finding (PASS drops burns under 0.9 ft/s).  Stage
3's Ku-band rendezvous radar is built and has flown from Ti - 44 min to the
arrival; see section 5d -- PASS's FLTR now holds tens of feet, the RR bias
I-loads bite like the star tracker's, and PASS's MC2-MC4 ALARM KILL turns
out not to be navigation's.  **Section 5e settles the I-load questions:**
STS-134's own GNC2 I-loads are in PFS/mafgen/DASS_G2.ASC (its PATCH
SUMMARY), and this tape holds the load module's placeholders instead.
With the flight's own values in the capture (`--dass-iloads rndz`, run
only), PASS targets and flies all four midcourses itself -- no ALARM KILL,
every burn within 0.15 ft/s of the truth's Lambert.  **Section 5f:**
Stages 4 and 5 -- the crew's instruments (HHL, TCS, COAS, centerline
camera) and the manual phase, flown by a scripted pilot from the R-bar
arrival through the RPM and TORVA to 100 ft station-keeping on the +V-bar,
where docking (PASS-IDLE's autopilot) picks up; with three findings for
yaGPC2 (LOW Z's sign without jet cants, the verniers' push, the radar's
close-range range rate).
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
(Answered in 5e: STS-134's DASS listing has all four bias INITs at 0.0.)

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
PROP, was fine.  [5d and 5e correct this: the ALARM KILLs were not the
drifted state's.  MC2's elevation search ran 50 fixed 500 s steps because
this tape holds the load module's GWQ constants (CGZV_DEL_X_TOL 1E7, not
the flight's 1E-2/1E-8), and with STS-134's own I-loads every MC solves
onboard.  Items 1 and 3 above are I-load placeholders as well: the flight's
GL5_VEL_THRESH is 0.06 ft/s, and its Lambert flags are ON for 9-14 and 19.]  PASS's navigation at the arrival: FLTR =
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

## 5d. Stage 3 as built: the Ku-band rendezvous radar (2026-10-09, macOS)

**How to run it** (one line, from a STRKNAV capture; about 80 min at rate 2
from Ti - 65 min to the arrival):

    python3 examples/flights/fly_rndz134.py --logs DIR --port-base 48800 --rate 2 --start-utc 2011-05-18T06:10:00 --from TI --zero-sensor-bias --lambert-mc

with DIR holding `sts134r-ipl` and `sts134r-strknav` from a Stage 1 run.
The new phase is RRNAV, between TI and STRKEND.  `--no-rr` gives Stage 2's
star-tracker-only run.

**Where PASS reads the radar.**  The Ku-band signal processor's ten words
come in on **FF3, card 3, channel 3**:
- FIOMFBCE.asm 537-549 reads them in FF3's MFE sequence, as FIOFFIC3
  X'24C69'.
- They land in CGBV_RNDZ_RDR; CGBIM1.hal's "CD 5 CH 5" comment is stale.
- GYNRRP decodes them (FSSR Part E 4.229).
- GELORB passes them on at LFE rate, range times 1000 into feet.
- GLARRD and GLBRRA incorporate them (Part C 4.2.8).

The words:

| Word | Bits | Meaning |
|---|---|---|
| 1 | 1 | RADAR ON (else 'COMM') |
| 1 | 2 | AUTO TRACK ('ATRK') |
| 1 | 3 | GPC DESIG ('GDSG') |
| 1 | 4 | GPC ACQ ('GPC') |
| 1 | 8-9 | angle data-good code |
| 1 | 10 | SELF-TEST ('STST') |
| 2 | 3 | TRACK |
| 2 | 15-16 | range data-good code |
| 3 | sign + 12 bits | roll, 0.0878906 deg |
| 4 | sign + 11 bits | pitch, 0.0878906 deg |
| 5 | sign + 15 bits | range rate, 0.05 ft/s |
| 7-8 | 23 bits | range, 0.005/16 kft |
| 9-10 | sign + 14 bits | roll and pitch rates, shown on SPEC 33 as mrad/s |

GLBRRA turns roll and pitch into shaft and trunnion through CGNS_K_ANG
(67 deg).  It predicts them from the line of sight in CGNS_M_BODY_TO_RR
axes, a 67 deg turn about body Z; the tape holds the source's INITIAL, at
X'0E96A'.  The line of sight runs from GLRREN's antenna offset, (-12.2211,
11.1971, -1.82292) ft from the c.g.  The two 67 deg turns undo each other,
so pitch is the line of sight's tilt along body X and roll is minus its
tilt along body Y.

**yaGPC2: `src/kuradar.c`.**
- **The device.** FF3's card 3 channel 3 read (mdmdev.c, RR_READ), driven
  by vehdyn's first target.
- **The angles.** It inverts GLBRRA's transform exactly: with w = (-u1,
  u2, -u3), sin P = -(c w1 + s w2) and tan R = (s w1 - c w2) / w3.
- **What it stands in for.** The SM computer and the Ku signal processor
  are not here, so the radar steers itself:
  - powered ON in RDR PASSIVE or RDR COOP (COOP skin-tracks too; the ISS
    has no transponder) and steered GPC, GPC DESIG or AUTO TRACK, it
    searches for 8-20 s and locks;
  - MAN SLEW never locks;
  - the reach is YAGPC_KU_ACQ_KFT, default 150 kft, and lock is lost
    beyond 1.1 times that;
  - lock is also lost with the station more than 30 deg below the body's
    X-Y plane.
- **Noise.**
  - Range: sqrt(15^2 + (0.0015 R)^2) ft.
  - Range rate: 0.3 ft/s.
  - Angles: 0.08 deg each, plus a close-range wander inside 3 kft.  The
    wander is Gauss-Markov, atan(3 m / R) with a 30 s time constant.
- **Saturation.** RADAR OUTPUT HIGH saturates inside 300 ft.
- **The panel.** One word from panelO6 (op 4 VALUE, type 9, to FF3; the
  bits are in kuradar.h).
- **Captures.** Kept in vehdyn.json's `kuRadar`.
- **Tests.** `test/test_kuradar.c`, 44 checks:
  - GYNRRP's decode of the words returns the truth's range and range rate
    to their LSBs;
  - GLBRRA's shaft and trunnion match PASS's own prediction, worked out
    from scratch, within the angle LSB, on and 20 deg off the boresight;
  - the noise is near its sigmas;
  - the steering bits and messages, MAN SLEW, the reach, the body
    blockage, SELF-TEST, and a capture.
- **Build.** Added to Makefile and NMakefile; `make test` passes.

**The panel: A1U** (panelcontrols.py: `ku_power` ON/STBY/OFF, `ku_mode`
COMM/RDR PASSIVE/RDR COOP, `ku_steering`, `ku_radar_output` HIGH/MED/LOW,
`ku_control` PNL/CMD; crew scripts set them with `switch ku_power ON`).
Their `ku` bits make the word panelO6 sends.

**The driver** (`RadarNav` in fly_rndz134.py):
- **[4A]'s A1U:** STBY, MAN SLEW, RDR PASSIVE, HI, PNL.
- **KU OPS** at PASS's NAV RNG < 150 kft: PWR ON, GPC, CMD, and SPEC 33 KU
  ANT ENA - ITEM 2.
- **At RR RNG < 135 kft:**
  - END S TRK NAV [10B];
  - RR NAVIGATION [13B]: FLTR TO PROP and SV SEL PROP if FLTR, RR - ITEM
    13, AUTO RNG/RDOT/Angles - ITEM 17/20/23;
  - SV SEL FLTR when SV UPDATE POS < 1.0 kft with RNG ACPT > 9.
- **POST Ti NAV [16A]:** the same pass again on the radar.
- **No second star tracker pass**, and no [18C].
- **RADAR OUTPUT LOW** at 700 ft.
- **Logging.** An `rr:` line every check in `rndz-check.log`: RR range,
  range rate and angles; ACPT and REJ; residuals; sensor; SV SEL.

**THE RR BIAS I-LOADS BITE TOO.**  GLQREN's GLQ_RR_ANGLES_BIAS_INIT is 1.0,
1.0 RADIAN on this tape, like the star tracker's.  GLQ_RRDOT_BIAS_INIT is
1.0 ft and 1.0 ft/s, against bias sigmas of 26.7 ft and 0.33 ft/s
(GLQ_BIAS_VAR_RRDOT 711, 0.11).
- **When they load.** The range set is set up once, at RNDZ NAV ENA, so a
  capture taken after that already holds the 1.0, 1.0 in
  CGNV_SENSOR_BIAS$(3,4), at X'0E7A2' + 4.
- **`rr-run1`** zeroed only the INITs:
  - PASS's FLTR range rate went 1.0 ft/s off the truth within a minute of
    [13B];
  - its relative state went 900 ft off (radial);
  - it estimated a 0.8 ft/s "bias".
- **`--zero-sensor-bias` now covers it.** It zeroes all four INITs (COAS,
  RR angles, RR range and range rate, S TRK) and, when they hold exactly
  1.0, 1.0, the live CGNV_SENSOR_BIAS$(3,4).  It is still only an
  EXPERIMENT pending Ron's I-load decision; the tape is not touched.

**Results** (`~/sts134-runs/rendezvous/rr-run2`, from strk-run2's
STRKNAV capture, `--zero-sensor-bias --lambert-mc`; `rr-run3` MC4 and the
arrival again with the wander at 3 m / 30 s).
- **The radar's timeline.** It locked at 147.5 kft, at Ti - 44 min.  RR RNG
  < 135 kft came at Ti - 40.7.  [13B] followed, and FLTR was selected at
  Ti - 37.2 (10 range marks, SV UPDATE POS 23 ft).
- **Marks.** About 490 range, range rate and angle marks were accepted to
  260 ft, and one rejected.
- **PASS's FLTR against the truth** (ft; PROP is the same pass without
  marks):

  | Ti + min | range ft | FLTR error (x y z) | abs | FLTR rate err ft/s | PROP abs |
  |---|---|---|---|---|---|
  | -37 | 120 500 | +57 +113 +24 | 129 | 0.13 | 223 |
  | -17.6 | 50 900 | +15 +90 +64 | 111 | 0.16 | 483 |
  | -1 | 42 300 | +58 -122 +110 | 174 | 0.23 | 675 |
  | +24 | 33 200 | +16 +30 +28 | 44 | 0.22 | 755 |
  | +46.8 | 16 900 | +3 +13 +11 | 17 | 0.04 | 794 |
  | +61.4 | 8 600 | +4 +14 +13 | 20 | 0.06 | 130 |
  | +76 | 3 360 | -8 +7 +9 | 14 | 0.37 | -- |
  | +86.2 | 1 470 | -3 +3 -7 | 9 | 0.21 | -- |
  | +94.5 | 590 | +12 +12 -33 | 37 | 0.36 | -- |
  | +98.7 | 290 | +5 -4 -22 | 22 | 0.15 | -- |

  Stage 2's star tracker FLTR walked 4-11 kft off after the midcourses.
  The radar holds it to tens of feet all the way in.
- **Ti on the radar's FLTR.** +9.92 -0.66 +4.23 against the truth's
  Lambert +9.80 -0.71 +4.31.
- **MC1.** -0.23 -0.17 +0.58 against -0.29 +0.02 +1.12, inside the
  checklist's 3 sigma; burned onboard.
- **The first close-range wander** (15 m, 10 s; `rr-run2`'s end) was too
  much:
  - PASS read it as 5 ft/s of lateral motion inside 1.5 kft;
  - the -Z track chased PASS's state to 112 deg of roll;
  - the radar lost the station behind the body at 430 ft.
  At 3 m and 30 s (`rr-run3`) FLTR stays inside 80 ft to the arrival.

**WHAT THE RADAR SETTLES ABOUT STAGE 2.**  PASS's MC2-MC4 Lambert still ends
in ALARM KILL (PRED MATCH 999999) with the radar, on a FLTR state 14-20 ft
and 0.1-0.4 ft/s from the truth (MC3 and MC4 in `rr-run2` and `rr-run3`).
So 5c's reading, that the drifted state made GWR give up, is wrong.
- **What fails.** From MC2's preliminary on, every COMPUTE T1 ends in ALARM
  KILL. MC2's elevation search lands revolutions away (+417, +833 min),
  and SPEC 34 shows EL 178.92 for an EL 29.07 set.
- **What still works.** MC1 and Ti, before it, solve.
- **What to look at next.** Something MC2's search leaves behind -- 5c
  notes the search re-seeding from the BASE TIME it moved (GWRORB step
  140) -- or the elevation angle's sign or reference.  That is GWR's
  side, not navigation's.

So MC2-MC4 were again flown on the ground's (truth Lambert) solutions:

| Burn | Lambert from the truth | Checklist mean (3 sigma) | Burned (truth sensed) |
|---|---|---|---|
| MC2 final (TGT 19, nominal + 7) | +0.50 -0.11 +1.72 | 0.0 (0.4), 0.0 (0.2), +0.9 (2.5) | +0.63 -0.02 +1.66 |
| MC3 final | +0.19 -0.13 +1.02 | +0.9 (1.3), 0.0 (0.5), +1.1 (2.6) | +0.33 -0.01 +0.90 |
| MC4 final | +0.01 -0.10 -0.29 | +1.3 (1.3), -0.1 (0.6), +0.9 (2.2) | +0.14 -0.01 -0.27 |

**Arrival** (`rr-run3`, MC4 + 13.5 min): the truth 27 ft ahead, 60 ft out
of plane and **372 ft below** the ISS, ZD -1.14 ft/s, against 0, 0, +600.
- **The miss is the burn's.** MC4's ground solution, from the truth at
  TIG, predicts arrival at 600 ft with ZD -0.63.  The burn as flown added
  +0.13 ft/s in X, and the truth's ZD was already -2.1 ft/s three minutes
  after it.  That is how the burn was flown (Stage 2's VGO loop and the
  -Z track's jets), not navigation.
- **`rr-run2`'s arrival** (48 ft below, 365 ft out of plane) came from
  the wander's chase above.

**Not done.**
- **SM pointing.** The SM computer's antenna management: the radar points
  itself, and SPEC 33's KU ANT ENA reaches nothing.
- **Panel A2.** The DIGI-DIS range/rdot and the cross-pointers.
- **SM ANTENNA self-test.** The panel bit exists; nothing sends it.
- **The radar's own errors.** Bias, scale factor and the close-range range
  noise are estimates; there are no figures from a document.
- **Blockage.** The Ku deployed assembly's zones are a single 30 deg cut.
- **Prox ops.** The rendezvous radar's role inside 200 ft (Stage 5).
- **One-line run.** Not flown end to end in one run: `rr-run2` and
  `rr-run3` are the result.

## 5e. STS-134's own I-loads: PASS targets every midcourse (2026-10-09, macOS)

**How to run it** (one line, from a POSTTI capture of a Stage 3 run; about
75 min at rate 2 from Ti + 11 min to the arrival):

    python3 examples/flights/fly_rndz134.py --logs DIR --port-base 48800 --rate 2 --start-utc 2011-05-18T06:10:00 --from MC1 --dass-iloads rndz

`--dass-iloads rndz` replaces `--zero-sensor-bias --lambert-mc`: it puts
the flight's own values into every cell that those two options patched,
and into the rest of the rendezvous I-loads.

**THE SOURCE: STS-134'S OWN DASS LISTING.**  `~/workspace/PFS/mafgen/DASS_G2.ASC`
is the MAFGEN memory map of the flight's own GNC2 load (its header reads
"STS134/OI034/C2 MDD 134.09 DASS GNC2", 13 Dec 2010).  Its PATCH SUMMARY
lists every halfword that the flight's I-loads changed from the load
module: ADDR, CSECT+OFFSET, LM (the load module's value, the source's
INITIAL) and MM (the flight's value, on mass memory).  It has 2919 entries,
all in data csects.

**What this tape holds.**  Of those 2919 words, 2026 hold LM and 853 hold MM.
- **The 853 MM words** are all in the system's #PFCMGPT and #PCDCPHA.
- **The GNC application csects hold LM throughout**: #PCGZMC2, #PCGGCOM,
  #PCGCMFR, #DGL*, #DGW*, #PCGN*.

So every rendezvous I-load on this tape is the source's placeholder, not
STS-134's.

The ones that bit (LM to MM):

| Cell | LM (tape) | MM (STS-134) | Effect |
|---|---|---|---|
| GLQ_{COAS,RR,RRDOT,ST}_..._BIAS_INIT (#DGLQREN) | 1.0, 1.0 each | 0.0 | 5b's and 5d's 1 rad / 1 ft/s biases |
| CGZB_LAMB_ILOAD (#PCGZMC2) | sets 1-10 ON | 9-14, 19, 25-27, 29-40 ON | 5c item 3: MC1-MC4 and TGT 19 are Lambert sets |
| GL5_VEL_THRESH (#DGL5NAV) | 0.9 ft/s | 0.06 ft/s | 5c item 1: PASS keeps a midcourse in its state |
| CGZV_DEL_X_GUESS (#PCGZMC2) | 500, 500 s | 100, 100 s | GWQ's first step |
| CGZV_DEL_X_TOL | 1E7, 1E7 | 1E-2, 1E-8 | GWQ's secant guard (below) |
| CGZV_ICMAX | 50 | 10 | GWS/GWQ iteration limit |
| CGZV_EL_DH_TOL, CGZV_EL_TOL (#DGWSORB) | 500 ft, 1E-3 | 100 ft, 5E-3 | GWS tolerances |
| CGZV_DEL_T_MAX (#DGWXORB) | 500 s | 300 s | GWX's step limit |
| CGZV_ORB_TGT_DTMIN_LAMB, CGZV_PROX_DTMIN | 0 | 60 s | minimum time to TIG |
| CGZV_DU, CGZV_EPS_U (#DGWYORB); CGZV_N_MIN, CGZV_R_TOL (#DGWWORB) | 2, 1E-6; 15, 824.5 | 0, 1E-7; 3, 125 | Lambert and precision iteration |
| T1/DT/EL/ROFF_ILOAD (#PCGZMC2) | 0 | the flight's target sets 9-39 | TGT 9-14 and 19 as p. 6-4 has them (TGT 12's EL 29.072 deg) |

These answer three open questions:
- **The bias I-loads:** 0.0.
- **The Lambert flags:** ON for 9-14 and 19.
- **TGT 10 keyed by hand:** the flight had the sets loaded.

**WHY MC2's ELEVATION SEARCH LANDED REVOLUTIONS AWAY.**  GWQ (the secant
iterator that GWS calls through GWX) takes a secant step only when
|ΔX_DEP| >= CGZV_DEL_X_TOL; otherwise it steps -DEL_X_GUESS.
- **On the tape:** with DEL_X_TOL at 1E7 and elevation errors in radians,
  it never took a secant step.  Every iteration moved T1 +500 s, until
  ICMAX = 50 set SFAIL: 50 x 500 s = 416.7 min.
- **The runs fit this exactly:** mc-run3 and rr-run2 landed at Ti + 466.6
  min, which is 49.9 + 416.7.  The next compute, seeded from the BASE
  TIME that step 140 had moved, landed at Ti + 883.2 min.

With the flight's 1E-8 the search is a true secant.

The ALARM KILLs on the EL = 0 sets after it (MC3, MC4 in rr-run2/3) are
also gone with the flight's values.  Which of the GWY/GWW/GWR constants
above did it was not isolated.

**The elevation search with the flight's constants** (`dass-run1`).  The
search converges when an EL = 29.07 time exists.
- **This trajectory never reached 29.07.**  After MC1 the elevation, by
  GWS's own formula from the truth, peaked at 24.0 deg at Ti + 56 and fell
  after; TGT 19 then flies MC2 (below).
- **What GWS did with it.**  It oscillated about that maximum, alternating
  +/-300 s (DEL_T_MAX) steps until ICMAX.  It exits with SFAIL, the TGT EL
  ANG alarm, displaying EL 21.4 and 23.7 deg.
- **The TIG it left.**  Ti + 56.57, 53.23 and 59.90 min for the
  preliminary, intermediate and final; each is seed + 100 + (+/-300) x 9.
- **What the driver did.**  The final's slip of +10.0 min is outside
  [18B]'s -3/+7, so the driver flew TGT 19 at nominal + 7 min, as the
  checklist says.

**What 5c's "dropped burns" became.**  With GL5_VEL_THRESH at 0.06 ft/s,
PASS's PROP state shows no step at MC1, and MC2-MC4 are in its state.
CGNV_DV_COUNT rose from 1 to 6 by MC4.

**`--dass-iloads GROUPS`** (fly_rndz134.py):
- **What it writes.** The PATCH SUMMARY's MM values go into the capture
  resumed from (on a fresh run, the UPLINK capture).
- **Which csects.**
  - `rndz`: #PCGZ, #DGW, #PCGN and #DGL, about 400 halfwords.
  - `all`: every #PCG and #DG csect; not flown yet.
  - Or csect names.
- **Which words.** Only words that still hold LM are written; a word the
  run has changed is left alone and logged.  A pair that happens to be 0
  again (TGT 12's T1_ILOAD after a search) is restored.
- **The live range-bias pair.** CGNV_SENSOR_BIAS$(3,4) goes to 0 when it
  holds the LM's 1.0, 1.0.
- **What is untouched.** The tape and the volume.

Putting these values on the volume (tools/mission_reconfig.py, or an
OPS 2 build from the DASS) is Ron's decision.

**Results** (`~/sts134-runs/rendezvous/dass-run1`, from rr-run2's POSTTI
capture, rate 2; Ku radar on, FLTR within 9-60 ft of the truth
throughout).  Every solution is PASS's own, and every burn was flown on it
(`--mc-rule limits` never had to substitute).

| Burn | PASS (onboard) | Lambert from the truth | Checklist mean (3 sigma) | Burned (truth sensed) |
|---|---|---|---|---|
| MC1 final | -0.13 +0.12 +0.89 | -0.29 +0.02 +1.12 | -0.1 (0.6), -0.1 (0.7), +0.5 (1.2) | -0.09 +0.01 +0.93 |
| MC2 (TGT 12: ICMAX, slip +10.0) | +0.46 +0.03 +2.49 (TGT 19, nominal + 7) | +0.45 +0.01 +2.62 | 0.0 (0.4), 0.0 (0.2), +0.9 (2.5) | +0.50 +0.00 +2.40 |
| MC3 final | +0.75 +0.05 +1.06 | +0.72 +0.02 +1.06 | +0.9 (1.3), 0.0 (0.5), +1.1 (2.6) | +0.78 -0.01 +1.04 |
| MC4 final | -0.49 +0.05 -0.71 | -0.54 +0.06 -0.71 | +1.3 (1.3), -0.1 (0.6), +0.9 (2.2) | -0.52 -0.01 -0.75 |

- **Against the truth.** PASS's MC2-MC4 agree with the truth's Lambert to
  0.13 ft/s; MC1 to 0.23 ft/s.
- **Against the checklist.** MC2's X (+0.46 against 0.0 +/- 0.4) and Z
  (+2.49 against 0.9 +/- 2.5, just inside) and MC4's X and Z (the wrong
  sign) fall outside its means.  The burns there absorb the trajectory's
  dispersion after MC1; the elevation never reached 29.07, so the
  trajectory was off nominal from the start of MC2.

**THE ARRIVAL.** `dass-run1`, at TGT 14's T2 (MC4 + 13.0 min): 35 ft
behind, 48 ft out of plane, **462 ft below** the ISS, ZD -1.01 ft/s,
against 0, 0, +600.  The 138 ft shortfall comes from two sources:
- **The burn's residuals.** About 70 ft.
  - **What was left.** VGO was left at +0.06 +0.08 +0.19 ft/s (body), so
    the sensed delta-V was off the required by +0.03 -0.07 -0.05 ft/s
    (LVLH).
  - **What it leads to.** The post-burn truth, coasted to T2 with J2
    (RK4), arrives 12 ft behind and 529 ft below.
  - **The cross-check.** An independent J2 Lambert from the truth at TIG
    asks -0.543 +0.058 -0.704 ft/s, as PASS and the ground did.
  - **Why it was left.** The card's "Trim VGOs < 0.2 fps" lets 0.19 ft/s
    stand, which is a third of a 0.9 ft/s burn.
- **The vernier jets in the 13-minute coast.** About 67 ft.
  - **The jets.** In DAP A/AUTO/VERN on the -Z track, the down-firing
    verniers (F5L, F5R, L5D, R5D) fired 72 jet-seconds and the side ones
    9.
  - **The delta-V.** The IMU-sensed delta-V over the coast was -0.02 +0.01
    -0.20 ft/s (LVLH): 0.2 ft/s toward the ISS, as down-firing jets must
    give with body -Z on the target.
  - **Its time pattern.** A CW coast from just after the burn matches the
    truth to 12 ft for 8.5 min and diverges after that.
  - **Physics, not a bug.** rr-run3's MC4 showed the same (0.39 ft/s of
    down-firing VERN in 12 min).  On the flight the commander flies from
    MC4 on (the manual phase, Stage 5), so no burn of the flight's
    corrects it.

**The fix in the driver: `--pulse-trim FPS`** (default 0.08).
- **When.** After a midcourse's VGO null has met the card (TRANS NORM,
  every axis < 0.2), DAP TRANS PULSE.
- **What.** Each axis at FPS or more gets one THC deflection per A7 pulse
  (PRI TRAN PLS 0.10 ft/s), all axes back to back, up to three passes.
- **Why back to back.** It is one GL5NAV maneuver.
- **Exempt.** The Ti burn's residual trim keeps its card's 0.2 alone.
- **Off.** `--pulse-trim 0` gives the card alone.

**With the pulse trim** (`dass-run2`, MC4 again from dass-run1's MC3
capture).
- **The burn.** The NORM null left VGO at -0.01 +0.05 -0.05 ft/s, so no
  pulse was needed.  PASS's solution was -0.50 +0.05 -0.74 against the
  truth's -0.54 +0.06 -0.71, and the truth sensed -0.54 -0.01 -0.64.
  PASS's CGNV_DV_COUNT went 6 to 7: GL5NAV kept it.
- **Its coast.** The post-burn truth coasted ballistically to T2 arrives
  44 ft ahead and 611 ft below.
- **What it reached.** At T2 the truth was **27 ft ahead, 45 ft out of
  plane and 558 ft below**, ZD -0.90 ft/s.  The 42 ft left is the
  verniers': 0.16 ft/s toward the ISS over the coast.  `dass-run1` had 35
  behind, 48 out and 462 below.

**THE VOLUME.**
- **The spec.** `yaGPC2/tools/sites/sts134-rndz-iloads.json` holds the
  same values, every rendezvous cell of the PATCH SUMMARY (#PCGZ, #DGW,
  #PCGN, #DGL; was = LM, H = MM; 329 cell copies at flat positions, one per configuration's copy where a csect is on the volume more than once).
- **Its sources.** It is checked against corrected-G2.fcm, the flown G2
  dump, which holds MM in all 211 cells.
- **PASS-IDLE's values.** PASS-IDLE independently sent the flown values of
  CGZB_LAMB_ILOAD and the GLQREN locals, from the DASS G2 dump
  (pure-G2.fcm), on 2026-10-09:
  - **What agrees.** The bias INITs at 0, TAU_RR at 4000, VAR_RRDOT and
    BIAS_VAR_RRDOT at 711 and 1, VAR_ST at 1E-6, and the Lambert flags 9-14,
    19, 25-27 ON.
  - **What differs.** PASS-IDLE listed sets 28 and up OFF; DASS_G2.ASC and
    corrected-G2.fcm both have 29-40 ON.  Sets 29-40 are not used here.
- **The volume.** `tools/mission_reconfig.py` applied the spec to a copy
  of the volume, with the G2 context taken from a pre-RNDZ NAV ENA
  capture (`rr-run2/sts134r-ipl`).  The copy is
  `~/sts134-runs/rendezvous/OI340700-v44boot-sts134-ksc6-rndz.mmv`.
- **Using it.** `--tape` that file, and a fresh run needs no
  `--dass-iloads`, `--zero-sensor-bias` or `--lambert-mc` (the last two
  are now legacy shortcuts).  Captures made from the old volume still need
  `--dass-iloads` when resumed.

**THE WHOLE FLIGHT ON THE VOLUME** (`~/sts134-runs/rendezvous/vol-run1`).
A fresh run from 06:10 on the reconfigured volume, with no
`--dass-iloads`, `--zero-sensor-bias` or `--lambert-mc`, flown in one go
to the arrival at rate 2.
- **The load.** After UPLINK, PASS's memory held the flight's values: the
  bias INITs 0, TAU_RR 4000, GL5_VEL_THRESH 0.06, DEL_X_TOL 1E-2/1E-8,
  ICMAX 10, the target sets, and the Lambert flags 9-14, 19, 25-27, 29-40.
  - **Set 7.** It was still ON (not in the PATCH SUMMARY); a hand-added
    cell now clears it on the volume as written since.
- **Navigation.** S TRK residuals were 0.00-0.01 deg from the first
  marks.  The radar went to FLTR at Ti - 37.1 min.
- **MC2's elevation search converged.** EL 28.83, 28.97 and 29.06 deg at
  T1 Ti + 52.81, 56.01 and 57.67 min, from the preliminary to the final.
  The final's +7.77 min slip is just outside [18B]'s +7, so TGT 19 flew
  at nominal + 7 min.
- **The pulse trim.** It cleared MC3's and MC4's last 0.1 ft/s; VGO was
  left at 0.02-0.08 ft/s on every burn.

| Burn | PASS (onboard) | Lambert from the truth | Checklist mean (3 sigma) | Burned (truth sensed) |
|---|---|---|---|---|
| Ti final | +9.75 -0.55 +4.54 | +9.72 -0.53 +4.56 | -- | (OMS) |
| MC1 final | -0.09 -0.33 +0.09 | -0.07 -0.26 +0.14 | -0.1 (0.6), -0.1 (0.7), +0.5 (1.2) | -0.00 -0.32 +0.00 |
| MC2 final (TGT 19, nominal + 7) | +0.29 -0.06 +1.55 | +0.28 -0.11 +1.58 | 0.0 (0.4), 0.0 (0.2), +0.9 (2.5) | +0.28 -0.03 +1.52 |
| MC3 final | +0.31 -0.08 +0.26 | +0.20 -0.12 +0.16 | +0.9 (1.3), 0.0 (0.5), +1.1 (2.6) | +0.35 -0.09 +0.22 |
| MC4 final | +0.33 -0.04 -1.35 | +0.30 -0.10 -1.53 | +1.3 (1.3), -0.1 (0.6), +0.9 (2.2) | +0.25 +0.00 -1.39 |

- **Against the truth.** Every solution was PASS's own and every one was
  burned.  All agree with the truth's Lambert within 0.18 ft/s per axis.
- **Against the checklist.** All are inside its 3 sigma, except MC4's Z
  (-1.35 against +0.9 +/- 2.2).
- **The arrival.** At TGT 14's T2 (MC4 + 13.0 min) the truth was **112 ft
  ahead, 72 ft out of plane and 652 ft below**, ZD -0.66 ft/s, against
  0, 0, +600 -- 52 ft above the aim this time, on the R-bar ready for
  the manual phase.



**THE SECOND VOLUME, rndz2** (2026-10-09, branch rndz-iloads-2).
`tools/sites/sts134-rndz-iloads.json` now has 242 cells, all in G2's own
copy, and is written to
`~/sts134-runs/rendezvous/OI340700-v44boot-sts134-ksc6-rndz2.mmv`
(SHA-256 1684f4ca...17ae8e).  The first volume, `-rndz.mmv`, is kept.
- **Added: mass properties and DAP.**  PASS-IDLE reported these from
  pure-G2.fcm; they agree with DASS_G2.ASC and corrected-G2.fcm.
  - **#DGCQORB.**
    - CGCS_CG_NOM: 1105.2, 0.4, 376.2 -> 1104.2, 0.4, 371.8 in.
    - CGCS_MOMENTS_OF_INERTIA_NOM: 951736, 7180436, 7507857 -> 938131,
      7129268, 7462045 slug-ft^2.
    - CGCS_PRODUCTS_OF_INERTIA_NOM: -2475, 274960, -2539 -> -2415,
      273803, -2486.
    - Jet-select and VERN candidate thresholds.  CGCS_REF_FORCE is
      unchanged.
  - **#PCGCFL2.**
    - CGKV_PRINCIPAL_INERTIA_REF: 840000, 6.11E6, 6.30E6 -> STS-134's.
    - The primary and vernier acceleration gains: 6.4E-5 -> 6.4E-6.
    - The unique-filter gains, CGCS_VERN_ROT_MIN_IMPULSE 0.0015 -> 0.002,
      and CGCK_MAG_CONTROL_FORCE.
  - **#PCGCFL3.** The phase-plane hysteresis CGPS_DHYS1/2, and
    CGCS_MAG_CONTROL_ACCL_REF_PRIM 0.98, 1.0, 0.73 -> 0.8, 0.9, 0.6.
  - **#PCGCCOM.** The phase-plane switching lines CGPS_K4/K5 (all to -10).
  - **#DGC1ORB.** The DAP load-percentage table.
  - **#DGC9ORB.** KH.
- **Added: navigation and targeting.**
  - **What else came in.** The 54 PATCH SUMMARY lines that carry a '0'
    carriage control in column 1.  The first version's parser missed them.
    The rendezvous ones among them: CGZV_ROFF_ILOAD_ARRAY+97 (TGT 9's
    offset's low half), CGNS_QA3_DELR_RATIO_SF_INV, CGNS_GPS_QA2_VTOL_MAX_UVW
    and CGGS_NAVBASE_ALT+2.
  - **#PCGNFLT.** The drag coefficients CGNS_CDA/CDF/CDN/CDS and
    CGNS_EXP_SHAPE_FACTOR.
  - **GLRREN's antenna offset, GLR_R_OFFSET_BODY.** (-12.22, 11.20, -1.82)
    -> **(45.74, 11.13, -5.79) ft** from the c.g.  This one was already in
    the first volume.
  - **CGNS_VAR_RR_RNG_MIN.** 711 -> 6400 ft^2.
- **Added: CGRS_JET_MAP** (#PCGRRMC+0482, a resident compool), checked at
  PASS-IDLE's request.
  - **What changed.** The flown map holds the tape's 38 values, reordered.
    It takes the DAP's internal jet order to the JON index that GRORCS
    packs into the MDM fire words.
  - **The check.** Every reordered run lies inside one jet group of
    GKNRCS's JET_MAP_INDEX_START (1, 4, 6, 8, 11, 13, 15, 17, 19, 23, 27,
    30, 33, 36).  Groups 1, 2, 3, 9, 10, 11 and 12 are reordered, each
    keeping its own set of jets.
  - **What it changes.** Only which jet of a group PASS prefers, the crew's
    SPEC 23 jet priority preset, not where a command lands.  vehdyn decodes
    the MDM bits by GRORCS's fixed layout.
  - **Consistency.** DASS_G16.ASC carries the same patch.
- **Only the G2 copy is changed now.**  STS-134's G1/G6 load
  (DASS_G16.ASC) has other values for 27 of #DGLJRCV's words.  The first
  volume changed all four configurations' copies of #DGLJRCV; this one
  leaves the others alone.
- **Left out.**
  - **RCS redundancy management.** The VRCS leak limits and
    CGRS_DILEMMA_CTR_LIMIT.
  - **The other GNC compools.** About 1900 words, not reviewed.
  - **Thirteen cells not placed.**  They are listed in the spec's notes.
- **The check.**  IPL to OPS 201 on port base 49800 (`rndz2-ipl`): PASS
  came up, its DAP configured A/AUTO/VERN.  The UPLINK capture holds
  every value above (rechecked after the jet map, `rndz2-ipl2`).

**GLQREN against the flown load.**  Of GLQREN's 16 constant pairs, these
differ (tape -> flown), all on both volumes:
- **Bias INITs:** 1.0 -> 0, all four pairs.
- **TAU_RR_ANGLES:** 600 -> 4000 s.
- **BIAS_VAR_RRDOT(2):** 0.11 -> 1.0 (ft/s)^2.
- **VAR_RRDOT(1):** 1.0 -> **711 ft^2**.
- **VAR_ST_ANGLES:** 1.2E-6 -> 1E-6.

These are the same as the flown load: BIAS_VAR_COAS, BIAS_VAR_RR,
BIAS_VAR_RRDOT(1) 711, BIAS_VAR_ST, TAU_COAS, TAU_RRDOT 600, TAU_ST,
VAR_COAS and VAR_RR.

**The range bias.**  The range bias is a Gauss-Markov state, sigma 26.7 ft
(711 ft^2) with a 600 s time constant, on both loads.
- **The tape's range mark is too precise.**  It is weighted at 1 ft^2 (a
  1 ft sigma), where the radar model's noise is 15 ft and more.  The filter
  takes each mark as almost exact.
- **What that does in a static R-bar hold.**  The range is constant, so
  the bias and the position along the line of sight are hard to tell
  apart.  A 1 ft^2 weight lets each mark's 15 ft of noise move the
  estimates, so the bias estimate random-walks within its 26.7 ft sigma
  and beyond: the 6-to-51 ft drift the kuradar agent saw.
- **What the flown values change.**  The flown 711 ft^2, with
  CGNS_VAR_RR_RNG_MIN raised 711 -> 6400, gives each mark 1/700 of the
  weight.  The bias estimate should then settle near its true value and
  stay within a few feet.  Expected, not yet flown: vol-run1 had these
  values but no hold.
- **The antenna offset (above) needs care.**  kuradar.c's angle inversion
  uses the tape's (-12.22, 11.20, -1.82) ft.  The Ku antenna is forward,
  over the payload bay, so the flown (45.74, 11.13, -5.79) is the physical
  one.  With the flown offset in PASS and the old one in kuradar.c, the
  predicted and measured angles disagree by about atan(58 ft / range):
  5 deg at 600 ft.  The model should take the flown offset (a yaGPC2
  change, for the radar's owner).  vol-run1 flew with this mismatch.

**Not done.**
- **The other I-loads.** `--dass-iloads all` (DAP, guidance, the other
  GNC compools: 2026 words) is not yet flown.
- **The one-line run.** Flown end to end only on the reconfigured volume
  (vol-run1), not from a fresh start with `--dass-iloads`.
- **GWY/GWW/GWR.** Which of their constants ended the EL = 0 ALARM KILLs
  is not isolated.
- **Why the post-MC1 trajectory never reached 29.07 deg.** MC1's onboard
  solution was 0.16/0.10/0.23 ft/s from the truth's, and the Ti point was
  reached from the 06:10 start without NCC.  Not traced.
- **The volume.** The reconfigured copy is outside the repository.  Making
  it the default volume is Ron's decision.

## 5f. Stages 4-5 as built: the instruments and the manual phase, to 100 ft on the +V-bar (2026-10-09, macOS)

**Scope.**  The manual phase ends at STATION-KEEPING 100 FT OUT ON THE
+V-BAR (Ron and PASS-IDLE, 2026-10-06: nothing yet models the ODS mechanism
or contact).  Docking picks up from that hold -- see "Interfaces for the
docking autopilot" below; PASS-IDLE's `dock_autopilot.py` and a capture
model in vehdyn start from the HOLD capture.

**How to run it** (one line, from the ARRIVAL capture of a 5e run; the
volume must be the one that capture was taken with -- see the note on
volumes below):

    python3 examples/flights/fly_rndz134.py --logs DIR --port-base 48800 --rate 2 --from RBAR --tape VOLUME

Five new phases after ARRIVAL: RBAR, RPM, TORVA, VBAR, HOLD
(`examples/flights/rndz_manual.py`, mixed into `Rendezvous`); `--hold-min`
(default 20), `--low-z` (off: see LOW Z below).  Each phase is captured
(`sts134r-rbar` ... `sts134r-hold-end`), so any of them resumes with
`--from`.  `manual.json` keeps each leg's report; `--portview` shows it all
in portview, and portview has two new views for it: `cl`, the ODS
centerline camera, and `aft`, the aft station's overhead windows W11/W12.

### Stage 4: the instruments (`examples/flights/rndz_instruments.py`)

Python, from the truth -- PASS uses none of them.  `Instruments(seed).read(tru,
tgt)` gives, each with its own noise (estimates; no document figures here):

| Instrument | Reads | 1 sigma | In view |
|---|---|---|---|
| HHL | range, range rate to the nearest structure (a 25 m sphere about the ISS's c.m.) | 0.5 ft + 0.1 %, 0.02 ft/s | inside 5,000 ft |
| TCS | range, range rate, bearing (H, V off -Z) of the reflectors at PMA-2, from the ODS ring | 0.1 ft + 0.05 %, 0.005 ft/s, 0.03 deg | inside 10,000 ft, -Z hemisphere |
| -Z COAS | the ISS's c.m. in the reticle, H right V up | 0.1 deg | 10 deg field |
| ODS centerline camera | PMA-2's face off the ring's axis (ft), range, and the two axes' pitch, yaw, roll misalignment | 0.05 ft, 0.05 deg | 50 deg of the axis |

The pilot model flies on the TCS (truth + its noise, rotated by the
attitude); every log line carries all four readings.

### Stage 5: the pilot model and the legs

**One control law for every leg.**  A goal -- a point and a velocity in the
ISS's LVLH frame (x ahead, y right of the track, z down; the turning frame's
rates, as `rndz_start.m50_to_lvc`) -- for a control point (the c.m., or for
VBAR and HOLD the ODS ring against PMA-2's face):

    v_cmd = v_goal + clip((r_goal - r) / tau, vmax),  dv = v_cmd - v

turned into THC pulses along the body axes in DAP TRANS PULSE, back to
back, whenever an axis needs most of a pulse.  Each axis's pulse is learned
from the response (below).  A response check stops the leg if the pulses
twice move the vehicle the wrong way.

**Results (manual-run2, from vol-run1's ARRIVAL: X +112 Y +74 Z +571 ft,
closing 0.28 ft/s):**

| Leg | Time | Truth's error from the goal (rms; max) | RCS used (truth, lb) |
|---|---|---|---|
| RBAR: brake, null the 74 ft out of plane, station-keep 600 ft below | 30 min (the leg's limit; settled in ~10) | last 3 min: X 2.3 Y 5.2 Z 1.3 ft; max 3.7 6.0 2.2 ft | 378 (FRCS 143, L 118, R 117) |
| RPM: 360 deg of pitch about the ISS line of sight, the R-bar point held | 21.9 min | X 5.9 Y 3.4 Z 6.2 ft; max 11.8 7.5 14.8 ft | 471 (FRCS 171, L 152, R 148) |
| TORVA: R-bar to +V-bar, 90 deg at twice the orbital rate, 596 to 400 ft | 11.5 min arc, 15.1 min to settled | X 8.1 Y 2.6 Z 5.5 ft; max 35.6 12.8 22.4 ft | 416 (FRCS 164, L 130, R 122) |
| VBAR: docking attitude, then the ODS ring in along PMA-2's axis, 334 to 100 ft at range/1000 ft/s | 23.7 min | X 2.7 Y 2.1 ft (Z: the 60 ft it started off the axis, nulled in 2 min); centerline camera under 2.5 ft and 1.5 deg from 270 ft in | 579 (FRCS 216, L 185, R 178) |
| HOLD: 100 ft from PMA-2's face, on its axis | 20.1 min | X 2.7 Y 3.5 Z 1.6 ft; max 6.2 6.3 2.8 ft; rates up to 0.23 ft/s; 75 THC pulses (~9 ft/s) | 337 (FRCS 132, L 103, R 101) |

The whole manual phase: about 2,180 lb of RCS propellant (the truth's,
`vehdyn.json` in the phase captures; `manual_summary`).

The checklist's propellant budget for the manual phase is not in this
repository's notes, so these stand on their own.  It is the verniers'
attitude work and the primary-jet pulses together.  The HOLD's 75 pulses in
20 min (about 0.45 ft/s a minute) are the pilot chasing the TCS noise and
the verniers' push with whole pulses: a deadband nearer a pulse, or a longer
time constant, would spend less and hold looser; the 5 ft lateral offset it
carried for the first 8 min is that deadband (5 ft over tau 90 s asks for
0.06 ft/s, under half a 0.16 ft/s Y pulse).

**The RPM.**  RPM SETUP (SPEC 20: DAP A's PRI ROT RATE, ITEM 10, and VERN ROT
RATE, ITEM 23, to 0.75 deg/s), then four quarter turns of UNIV PTG's BODY
VECT 5 (GKTUNI.hal's vector: cos P cos Y, sin Y, -sin P cos Y), TGT ID 1,
P 180, 270, 0, 90 -- -X, +Z, +X and back to -Z on the ISS -- a full turn in
pitch with the ISS tracked; then the rates back (A7: 0.200, 0.016) and the
-Z track.  Each quarter turn took 3 to 4 min (8 for one: its body rate never
settled under 0.1 deg/s) against the flight's 8 min for the whole, which was
one continuous turn.  Each ended 6 to 10 deg from the true ISS: TGT ID 1
points at PASS's own state of the ISS (see "PASS's relative state" below).

**TORVA.**  The -Z target track throughout, so the bay stays on the ISS; the
goal runs round a quarter circle at 2n, its radius from 596 to 400 ft.  It
ends nose up and bay toward the ISS, which is already the docking attitude.

**VBAR.**  ESTABLISH VBAR: UNIV PTG TGT ID 2 (the Earth's centre), BODY VECT
5 P 180 (-X), OM 0 -- the nose to the zenith, the bay to the ISS; found by
trying OMs, of which 0 is right (-Z 1.9 deg off the -V-bar).  The maneuver
is flown in DAP B/AUTO/ALT (B7's 0.5 deg/s) and the attitude then held in
A/AUTO/VERN.  The ring then comes in at range/1000 ft/s (0.33 at 334 ft, 0.1
at 100).

### Findings

1. **LOW Z comes out the wrong way.**  With LOW Z pressed (the APPROACH card,
   inside 1,000 ft), a +Z translation command moved the Orbiter -Z, toward
   the ISS (manual-run1: ZD -0.27 to -1.39 ft/s in 70 s; the run was
   stopped).  Without LOW Z, Z pulses go the right way.  PASS's LOW Z
   (GFFORB.hal, X_JETS_PLUS_Z) gets +Z from firing the forward- and
   aft-firing jets together, relying on the aft jets' cant; vehdyn models
   every jet along a pure body axis ("The real jets are canted a few
   degrees ... not modelled", vehdyn.c), so what comes out is whatever
   the X jets' moment arms and the rest of the DAP's firings make.  **A
   yaGPC2 fix**: the jets' real cant angles in vehdyn's jet table (from
   the RCS jet table I-loads or the Orbiter data book).  Until then the
   manual phase flies without LOW Z (`--low-z` to try it).
2. **The verniers push.**  Turning the Orbiter with the verniers translates
   it: vehdyn's vernier pairs fire along the body axes, so a pitch pair is a
   net -Z.  The first RPM, holding the R-bar point only between the quarter
   turns, drifted out to 1,640 ft at 2 ft/s; holding it through each turn
   kept it within 15 ft.  Whether the real verniers' cant reduces this as
   much is again the jet table's question (finding 1).
3. **A pulse is bigger than PRI TRAN PLS.**  DAP A7's PRI TRAN PLS is
   0.10 ft/s; the pulses measured 0.11-0.20 ft/s (x 0.11-0.14, y 0.10-0.20,
   z 0.07-0.19, varying with the attitude and the jets chosen), and the MC
   pulse trims saw 0.24.  The pilot learns each axis's pulse from the
   response (60/40 running mean).
4. **PASS's relative state drifts inside 1,000 ft -- found and fixed
   (kuradar-close-range).**  During the R-bar hold PASS's FLTR state went
   from 64 to ~190 ft off the truth at 600 ft, with ~750 radar marks
   accepted and small residuals; the -Z track (TGT ID 1), which points at
   that state, ran 10-12 deg off the true ISS, and the RPM's quarter turns
   ended 6-10 deg off.  THE CAUSE was the radar's antenna point.  PASS
   predicts every mark from GLR_R_OFFSET_BODY (GLRREN), which STS-134 flew
   as (+45.738, +11.13, -5.79) ft from the c.g. -- forward on the starboard
   sill, where the Ku dish deploys (DASS_G2.ASC #DGLRREN+0014, a patched
   word, carried by tools/sites/sts134-rndz-iloads.json).  kuradar.c
   measured from the source's INITIAL, (-12.2211, 11.1971, -1.82292), a
   placeholder 58 ft aft.  Far out that is nothing; inside a few thousand
   feet it is degrees of angle and tens of feet of range, and PASS's filter
   absorbed it into its own sensor biases (CGNV_SENSOR_BIAS: RR angle bias
   8.5 deg and range bias 84 ft at the end of the R-bar leg, from 0.3 deg
   and 50 ft at arrival) and into its state, the residuals near zero all
   the while.  test_kuradar's own check of the radar against PASS's
   prediction used the same placeholder, and only beyond 135 kft, so it
   could not see it.  (The range rate, first suspected, is unbiased:
   +0.02 ft/s mean against the truth's 0.00 over 61 samples, sigma 0.31.)
   THE FIX: kuradar.c measures from the flown point, and test_kuradar
   checks range, shaft/trunnion and range rate against PASS's prediction
   from that point -- written out from the listing -- 600 ft from the
   station with it along -Z, +X and -X (the old offset fails 8 of those
   checks; 7.3 deg of angle along -Z).  THE CHECK, kuradar-run2 (vol-run1's
   MC4 capture through ARRIVAL and the R-bar leg, the vol-run1 volume):
   at arrival PASS's FLTR state was 10-15 ft off the truth and the -Z
   track 1.0 deg off the ISS (manual-run2: 64 ft, 10 deg); over the R-bar
   leg the track held 1.3 deg mean, 2.7 max, and PASS's angle biases stayed
   under 0.7 deg; the radar read 7.4 ft short of the c.g.-to-c.g. range
   inside 700 ft, where the antenna point should read 4 short.  STILL OPEN:
   in the static R-bar hold PASS's range bias walked from 6 to 51 ft and
   its FLTR state 37 ft mean, 85 max, off along the line of sight, with
   zero-mean residuals -- on a fixed line of sight a range bias and a
   position error along it cannot be told apart, and PASS trades them; its
   I-loaded range-bias process noise is the next thing to look at.  Also:
   the range noise's 15 ft floor is 2.5 % at 600 ft, and the 3 m angle
   wander is 1 deg there.
5. **Volumes and captures.**  A capture resumes only on the volume it was
   taken with (simulatePASS checks the SHA-256).  vol-run1 flew the
   reconfigured volume before CGZB_LAMB_ILOAD set 7 was added to the spec;
   its captures need that volume, rebuilt with
   `tools/mission_reconfig.py` from the spec less the set-7 cell (SHA-256
   e98ed16b79d8...).

### Interfaces for the docking autopilot

1. **The hand controllers and the DAP from a script.**  simulatePASS's
   `--rhc lh` starts handcontrollers.py's commander's window; a crew script
   then moves the THC and RHC:
   - `thc fwd|aft DIR S` -- hold THC direction DIR (`+x -x +y -y +z -z`,
     body axes: THC +Z is +Z body, down) for S seconds (fwd = the
     commander's, aft = the aft station's).  In TRANS PULSE one
     deflection is one pulse (the pilot uses 0.30 s, one a second); in
     TRANS NORM the jets fire for as long as it is held (the THC's
     accelerations, measured in 5c: +X 0.43, -X 0.42, +Y 0.44, -Y 0.38,
     +Z 0.65, -Z 1.22 ft/s^2 -- fly_rndz134's THC_ACC_SEED).
   - `rhc lh|rh|aft AXIS F S` -- deflect roll, pitch or yaw by F of full
     throw (-1..1; the detent is about 0.1) for S seconds.
   - `dap c3|a6u x_norm|x_pulse|y_norm|y_pulse|z_norm|z_pulse|low_z|high_z`
     -- TRANSLATION; `dap c3 a|b`, `auto|inrtl|lvlh|free`, `pri|alt|vern`.
   - The pulse size: SPEC 20 DAP A's PRI TRAN PLS is ITEM 17 (B's 37);
     `keys SPEC 2 0 PRO`, `keys ITEM 1 7 + . 1 EXEC`, `keys RESUME`
     (rndz_manual's `spec20_rates` keys items 10 and 23 the same way).
     The learned sizes above are what one deflection gives.
   - The scripts go to panelO6 on port base + 92 (crewscript's
     CONTROL_OFFSET); handcontrollers.py takes the `thc`/`rhc` lines on
     base + 86 and acknowledges on base + 87 (HC_OFFSET, HC_ACK_OFFSET), and
     drives the THC/RHC contacts on the MDMs' I/O ports, base + 100..103.
     From Python: `fly_sts134.Flight.play(text, name)` and
     `script_done(name, timeout)`; `rndz_manual.ManualPhase.thc_pulses()`
     turns an LVLH dv into pulses.
2. **What the crew sees, and where.**
   - The truth: TRU1 on base + 98 (yaGPC2 mdmdev.c, `truth_publish`:
     big-endian doubles -- t, GMT, q body->M50 (w x y z), w body rad/s, r,
     v M50 m and m/s of the c.m., ..., [27:30] the c.m. off the dry CG,
     body m); TGT1 on base + 109 (`targets_publish`: t, NORAD, r, v M50,
     q body->M50 in the ISS frame).  fly_rndz134's `Ears` keeps both, time
     aligned (`truth_at`).
   - HHL, TCS, COAS, centerline camera: no port of their own --
     `rndz_instruments.Instruments(seed).read(tru, tgt)` from those two
     feeds returns `hhl_range_ft, hhl_rdot_fps, tcs_range_ft,
     tcs_rdot_fps, tcs_bearing_deg (H, V), coas_deg (H, V),
     cl_offset_ft (right, up), cl_range_ft, cl_pitch_deg, cl_yaw_deg,
     cl_roll_deg`; `rndz_instruments.points(tru, tgt)` gives the ODS ring's
     and PMA-2's M50 position and velocity.  An autopilot reads exactly
     what these logs show by calling the same function.
   - The rendezvous radar is yaGPC2's (kuradar.c), read by PASS on FF3
     card 3 channel 3 (5d); what the crew sees of it is PASS's: SPEC 33
     (RR RNG, RDOT, angles; `fly_rndz134.RadarNav.rr_summary` reads them off
     the format-22 downlist, base + 88).  Inside 300 ft with RADAR OUTPUT
     HIGH its range is flagged bad; the checklist has it LOW from 700 ft.
3. **The geometry.**
   - ODS ring (the APDS docking interface), Orbiter structural X_o 576,
     Y_o 0, Z_o 513 in -- body (13.31, 0, -3.51) m from vehdyn's dry-CG
     origin -- its axis body -Z.  APPROXIMATE: the external airlock's
     station and a ring face above the sill, not from the ODS/APDS ICD
     (rndz_instruments.ODS_XO/ZO; portview's `cl` view sits there too).
   - PMA-2's docking face, ISS frame (+X forward, +Y starboard, +Z nadir;
     origin the c.m. vehdyn moves) (15.66, 0, 5.48) m -- portview's
     ISS_PMA2, from the ISS model -- its axis the ISS's +X.
   - The docking attitude: LVLH, nose to the zenith, -Z (the ring's axis)
     along -V-bar toward PMA-2, wings level (centerline camera roll ~0).
4. **The 100 ft station-keeping capture.**  `~/sts134-runs/rendezvous/manual-run2/sts134r-hold`
   (Mac-portview's machine; `sts134r-hold-end` is the same instant): the
   ODS ring 98.9 ft from PMA-2's face, 1.3 ft and 1.6 ft off its axis,
   rates under 0.06 ft/s, docking attitude in DAP A/AUTO/VERN (UNIV PTG
   TGT ID 2, BODY VECT 5 P 180, OM 0, TRK), TRANS PULSE in X, Y and Z, no
   LOW Z.  Its volume is `~/sts134-runs/rendezvous/OI340700-v44boot-sts134-ksc6-rndz-volrun1.mmv`
   (SHA-256 e98ed16b79d8...; rebuilt from `sts134-rndz-iloads-noset7.json`
   beside it).  To fly on from it, add the autopilot's phase after HOLD in
   fly_rndz134's PHASES (the base class resumes `--from X` from the capture
   of the phase before X) and run:

       python3 examples/flights/fly_rndz134.py --logs ~/sts134-runs/rendezvous/manual-run2 --port-base 48800 --rate 2 --from DOCK --tape ~/sts134-runs/rendezvous/OI340700-v44boot-sts134-ksc6-rndz-volrun1.mmv

   (or, without the driver, `simulatePASS.py ... --snapshot-resume
   ~/sts134-runs/rendezvous/manual-run2/sts134r-hold --tape THAT VOLUME`,
   with fly_rndz134's `start()` environment).  Copy the directory first if
   it should stay as it is: a run writes its captures beside it.

**Not done.**  LOW Z (finding 1, a vehdyn jet-cant fix); the radar's
close-range range rate (finding 4); the RPM as one continuous turn; the
COAS reticle drawn on portview's overhead view; the AUTO ANGULAR FLYOUT /
TARGET ALIGNMENT cards' UNIV PTG corrections (the attitude is held in LVLH
and lined up by translation alone); KU antenna stow, FLT CNTLR PWR and the
RPM's photo callouts; plume logging of jets fired toward the ISS inside
200 ft; the one-line run from IPL to HOLD in one go (manual-run2 flew
RBAR from vol-run1's ARRIVAL, then RPM, TORVA, VBAR and HOLD from its own
captures, the pilot fixed between them -- each fix is in the code).

**full-run1, before the jet-geometry change** (2026-10-09; kuradar-close-range
76f8a65 + b0bf186, volrun1 volume, old vehdyn jets): from vol-run1's MC4
capture in one process, ARRIVAL and RBAR flew (RBAR settled in 8 min, rms
12.6/6.9/3.9 ft); the RPM's quarter turns never got going -- the Orbiter
turned at a steady ~0.07 deg/s instead of 0.75 -- first cut off after 1.2 min
by the old turn-complete test (fixed in b0bf186: a turn is stopped only once
it has been under way), then given up after 5 min each, 17-132 deg short;
stopped in TORVA when the jet geometry landed.  FLTR ran 50-110 ft off in
the static R-bar hold: volrun1 carries the tape's CGNS_VAR_RR_RNG_MIN 711
(flown 6400), so range marks were weighted ~700x too heavily.


## 5g. The clean run (2026-10-09, macOS)

**What it is.** The whole rendezvous on the corrected vehicle, flown on
branch `rndz-clean` (origin `review/rndz-clean`). That branch is
`review/ops1-lps` 38a0783 (PASS-IDLE's RCS jet table: every jet fires as PASS
assumes, so LOW Z pushes +Z; kuradar's flown antenna position), plus 62fa890
(`script_done` waits for "script complete"), b0bf186 (the RPM turn test),
ac70551 (I-load spec v2 with the jet map), and the driver fixes below.

- **Tape:** `~/sts134-runs/rendezvous/OI340700-v44boot-sts134-ksc6-rndz2.mmv`
  (SHA-256 1684f4ca...), carrying the flown I-loads. No run-only patches.
- **Run:** `~/sts134-runs/rendezvous/clean-run1`, port base 48800, rate 2,
  `--low-z`.
  - **IPL -> TORVA:** one process, start 06:10 UTC.
  - **VBAR:** re-flown from the TORVA capture with the documented ODS geometry.
  - **HOLD:** re-flown from the VBAR capture, with the RM thresholds seeded,
    IMU 1 checked, MSG RESET and DAP A10/B10.

    python3 examples/flights/fly_rndz134.py --logs ~/sts134-runs/rendezvous/clean-run1 --port-base 48800 --rate 2 --start-utc 2011-05-18T06:10:00 --to HOLD --low-z --tape ~/sts134-runs/rendezvous/OI340700-v44boot-sts134-ksc6-rndz2.mmv

**The burns** (ft/s, LVLH). Every one was targeted and flown on PASS's own
solution.

| Burn | PASS (final) | Truth's Lambert | Flown (truth sensed) |
|---|---|---|---|
| Ti | +8.93 -1.14 +2.84 | +8.91 -0.67 +2.87 | 9.35 ft/s, left OMS 12.4 s; residuals VGO -0.04 -0.21 +0.40 |
| MC1 | +0.09 -0.21 +0.05 | +0.10 +0.17 +0.04 | +0.14 +0.10 +0.01 |
| MC2 | +0.08 +0.17 +0.58 | -0.01 -0.09 +0.58 | -0.02 +0.00 +0.62 |
| MC3 | -0.13 -0.05 -0.37 | -0.13 -0.13 -0.35 | -0.07 -0.11 -0.45 |
| MC4 | +1.66 +0.26 +0.93 | +1.66 +0.12 +0.90 | +1.71 +0.20 +0.76 |

All are within the checklist's 3-sigma. MC4's +1.7 is X, inside its 1.3 +/-
1.3.

**Arrival** (MC4 + 13.0 min): X -36.8, Y +40.0, Z +515.8 ft; XD -0.07, YD
-0.02, ZD -0.88 ft/s. The aim was 0, 0, +600.

**The manual legs** (the truth's error from the goal; RCS from the captures)

| Leg | Time | rms error ft (x y z) | max ft | RCS lb |
|---|---|---|---|---|
| RBAR, 600 ft | settled in ~8 min | 2.5 1.3 5.5 (last 3 min) | 4.6 1.7 10.0 | 507 |
| RPM, 360 deg | 16.9 min | -- | -- | 1,552 |
| TORVA | 15.5 min | 6.7 1.0 5.6 | 29.9 1.7 24.9 | 648 |
| VBAR, 331 -> 100 ft | 21.3 min | 2.6 2.3 4.8 | 6.2 9.4 30.3 | 1,062 |
| HOLD, 100 ft | 20.1 min, 13 pulses | 3.1 3.2 2.5 | 8.1 5.9 4.5 | 263 |

The RPM's quarter turns stopped 2.2, 8.4, 6.4 and 8.3 deg from the ISS,
where PASS's own target is.

**FLTR** (|PASS's relative state - the truth|, ft, mean/max):

| Phase | FLTR mean | FLTR max |
|---|---|---|
| star tracker pass | 16 | 21 |
| Ti targeting | 44 | 125 |
| RR nav | 65 | 85 |
| MC1-MC4 | 11-58 | 92 |
| ARRIVAL | 19 | 60 |
| RBAR | 82 | 138 |
| RPM | 130 | 188 |
| TORVA | 89 | 187 |
| VBAR | 124 | 177 |
| HOLD | 58 | 114 |

So VAR_RR_RNG_MIN 6400 did not bring the static R-bar and V-bar holds down to
tens of feet. They run about 60-130 ft, mostly along the line of sight: still
open.

**-Z on the ISS:** 0.8-1.5 deg mean in the tracked phases (STRKNAV to
ARRIVAL), 3.9 deg in RBAR and 4.9 deg in TORVA. In VBAR and HOLD the docking
attitude points -Z down the -V-bar, so the number means nothing there.

**LOW Z.** It is flown throughout the manual phase, and with the new jet table
+Z goes the right way: RBAR converged under it. LOW Z TOGGLES (GCQORB.hal
1443-1458, 3256-3280), and the old blind press turned it off every second
call. `dap_lamps.set_low_z` now presses only while FF1's lamp (card 10 ch 1,
0x0001) disagrees, and confirms the change. Every other DAP pushbutton
selects; HIGH Z also clears LOW Z.

**Fixed on the way:**
- **RPM turn test** (b0bf186): a turn now counts as stopped only once it has
  been under way (> 0.3 deg/s) or after 5 min. Before, the verniers'
  run-up was cut off.
- **`feeds()` at one instant:** TGT1's newest sample is carried to TRU1's GMT
  along its velocity, or nothing is used if they are over 1 s apart. This
  fixes ~1,650 ft outliers in rel("ods").
- **rel() jump guard:** it drops and logs any step beyond 5 ft + 2 ft/s x dt.
- **ODS geometry** from the Shuttle Systems Handbook Vol 3, SCOM 2.20 and
  Flight Rules A10-385:
  - ring axis Xo 649.00, face Zo 475.75 ready to dock;
  - centerline camera Zo 422.85;
  - TCS head 599.68 / -7.45 / 415.31;
  - portview's `cl` view moved with it.
- **DAP A10/B10** stored as JSC-48072-134 p. 6-2's DOCKING column
  (`rndz_manual.DAP_DOCK`): DAP EDIT, every item read back, A7/B7 kept
  selected. ALT JET OPT only toggles ALL <-> TAIL (GKKORB.hal 688-697), so it
  takes one press, not the P/Y options' two.
- **The IMU caution** (with the IMU investigator):
  - [10A]'s SPEC 21 ITEM 7 was never typed: `script_done` returned when the
    step started, and the next play dropped the rest. ITEM 7 toggles
    (GKUIMU.hal 203-212), so [10B]'s ITEM 7 deselected IMU 1 for the rest of
    the flight. Fixed in fly_sts134 (62fa890), and `imu1_select` now keys
    ITEM 7 only while CGUB_IMU_SEL_MFE (X'59DC') disagrees, then checks it.
  - PASS's IMU attitude RM thresholds X'566E'-X'5679' are zero in any run
    started in OPS 2, because GRS_IMU_RM_INIT never runs. With two IMUs the
    RM dilemma lit IMU and the backup C&W. `seed_imu_rm` copies the six
    I-load pairs into every capture flown on from; a fresh run restarts from
    UPLINK to get them.
  - Still lit in the final capture: the RM dilemma latched before the
    seeding (RM DLMA IMU, GMT ...151325) keeps IMU and BACKUP C/W ALARM lit
    after MSG RESET. PASS keeps writing them.
- **C&W** (79d7451): every change of the PASS-driven C&W lights is logged to
  driver.out and rndz-check.log.
  - When the tone rises and every light on is expected (IMU after [10A]),
    the driver presses MASTER ALARM, adds MSG RESET for latched class-2
    lights, and logs the fault summary (X'1D02').
  - An unexpected caution is logged and left sounding. The simulator's audio
    stays on.

**The docking start point.** `~/mnt/forClaude/rndz-hold-v2/` holds
sts134r-hold, the rndz2 volume and README.txt. The ring is ~100 ft from
PMA-2's face. The capture has:
- DAP A10/B10 stored as DOCKING and A7/B7 selected;
- LOW Z on;
- IMU 1 selected and the thresholds seeded.

Coming: vehdyn's capture model (PASS-IDLE), with TRU1 [30] the docking state
and [31] the contact count.

**Before the jet-geometry change.** full-run1 is recorded in 5f.

## 5h. End-to-end verification run (2026-10-09, macOS)

**e2e-run1**: one process from IPL (06:10 UTC) to the 100 ft HOLD capture, no resumes, no run-only
patches; review/rndz-clean c741f73 plus 6cdb438 (the HOLD restructure below), i.e. yaGPC2 with
the new RCS jet geometry and the Ku antenna fix; tape `-rndz2.mmv` (flown I-loads, CG/MOI, jet
map); `--low-z`; port base 48800, rate 2.  Logs in `~/sts134-runs/rendezvous/e2e-run1`.

    python3 examples/flights/fly_rndz134.py --logs DIR --port-base 48800 --rate 2 --start-utc 2011-05-18T06:10:00 --to HOLD --low-z --tape ~/sts134-runs/rendezvous/OI340700-v44boot-sts134-ksc6-rndz2.mmv

**Burns** (ft/s, LVLH; every one PASS's own FLTR solution, burned onboard; "ground" = the truth's
precision Lambert):

| Burn | PASS final | Ground | Flown (truth sensed) |
|---|---|---|---|
| Ti | +8.92 -0.67 +2.83 | +8.92 -0.67 +2.87 | 9.45 ft/s, L OMS 12.5 s |
| MC1 | +0.18 +0.13 -0.53 | +0.11 +0.20 -0.32 | +0.14 +0.10 -0.49 |
| MC2 | +0.13 +0.05 +0.72 | +0.11 -0.00 +0.69 | +0.15 +0.11 +0.71 |
| MC3 | -0.05 -0.07 -0.07 | -0.08 -0.10 -0.02 | 0 (every axis under a pulse) |
| MC4 | +1.40 -0.06 +0.38 | +1.40 -0.09 +0.36 | +1.46 -0.08 +0.27 |

Arrival, MC4 + 13 min: X +11, Y +42, Z +560 ft (aim 0, 0, +600), closing ZD -0.81 ft/s.

**The manual phase** (truth; RCS from the phase captures):

| Leg | Time | rms error ft (x y z) | max ft | RCS lb |
|---|---|---|---|---|
| RBAR (last 3 min) | settled ~11 min | 3.8 / 1.1 / 2.4 | 5.0 / 2.0 / 5.2 | 411 |
| RPM | 16.3 min (quarter turns 2.5-3.6 min, stops 1.4-5.4 deg from the ISS) | -- | -- | 2,219 |
| TORVA | 16.2 min | 9.9 / 1.2 / 5.5 | 41.7 / 3.9 / 23.0 | 863 |
| VBAR, to 100 ft | 20.9 min | 2.4 / 1.3 / 10.2 | 5.9 / 5.0 / 53.5 | 1,077 |
| HOLD | 26.2 min, 53 pulses | 2.1 / 2.4 / 1.7 | 5.5 / 4.8 / 7.0 | 660 |

The RPM's propellant (2,219 lb, FRCS 1,180) cannot be split into rotation and position hold from
these logs: only the phase captures carry propellant.  It is high against the other legs and
against clean-run1's 1,552 lb; the position hold through each quarter turn (added after
manual-run2's 1,640 ft drift) fires translation pulses against the rotation's own jet
cross-coupling.  Open.

**PASS's FLTR against the truth**, |relative position error| ft, mean / max by phase: TRACK 3 / 8,
STRKNAV 12 / 17, TI 30 / 41, RRNAV 54 / 73, TIBURN 50 / 178, MC1 116 / 195, MC2 48 / 66, MC3 15 / 22,
MC4 8 / 12, ARRIVAL 15 / 43, RBAR 75 / 117, RPM 84 / 146, TORVA 68 / 145, VBAR 154 / 250, HOLD 109 /
265.  Good to MC4; inside 600 ft it runs 70-150 ft off, mostly along the line of sight, with the flown
VAR_RR_RNG_MIN.  Open (the crew instruments, not REL NAV, fly the manual phase and the docking).

**IMU and C&W.** RM thresholds seeded at UPLINK; [10A] deselected IMU 1 (CGUB_IMU_SEL_MFE 7 -> 3)
and [10B] reselected it (-> 7), each read back; with the thresholds seeded the two-IMU interval
raised nothing.  The C&W watcher saw one SM ALERT TONE (4 s, acknowledged); nothing lit at the
capture.

**Re-flown 2026-10-10 (optA-run650, 5n):**
- **Build:** review/flight-gnc-2 (CC 9-7's 650 ft RR inhibit, the RR FORCE
  logic, mdmdev.c's INJ_WARM 20000).
- **Command:** the e2e-run1 command on port 49700, headless.
- **Navigation:** the RR never forced (initial RESID RANGE -0.01). Every Ti
  and midcourse burned onboard.
- **Manual phase:** RBAR rms 3.6/3.1/4.2 ft; TORVA 7.7/2.2/22.3; VBAR
  1.9/2.6/9.8; HOLD 2.8/1.8/1.2 ft over 22.7 min.
- **Propellant:** 316/53/672/996/725 lb by leg.
- **Errors:** 0 tracebacks, 0 ILLEGAL ENTRY.

The 650 ft inhibit costs option A nothing.

**ILLEGAL ENTRY** (7 in e2e-run1): not dropped keys.  Bisected on a resumed copy (port 49900): after
`OPS 2 0 2 PRO` the SPEC 34 ORBIT TGT page left up from targeting stays over the MNVR display, and
its title "2021/034/" satisfied the script's `wait crt 1 title 2021/`; `ITEM 4 EXEC` (RCS SEL) then
went to SPEC 34 -- ILLEGAL ENTRY -- and `ITEM 9 +WT EXEC` keyed SPEC 34's item 9 (DZ), overwritten at
the next TGT load.  So RCS SEL and WT were never entered for MC1-MC4 (the burns, flown by THC on
VGO, were unaffected).  Fix (b4f1645): RESUME after the transition and wait for `title MNVR EXEC`
(RESUME on the MNVR display itself checked harmless).  e2e-run2 confirms it: IPL to ARRIVAL in one process with b4f1645, **no ILLEGAL ENTRY**; RCS SEL and
WT entered for every midcourse; MC1-MC4 burned onboard (MC1 -0.26 +0.02 +0.83, MC2 -0.05 -0.04 +0.23,
MC3 +0.29 -0.08 +0.58, MC4 +0.91 +0.06 -0.16 ft/s against the truth's Lambert within 0.1 per axis);
arrival at MC4 + 13 min about X +20, Y +19, Z +585 ft.

**The HOLD capture.**  rndz-hold-v2's capture had restored drifting (ring X +75.2 Z +36.2 ft, ZD
+0.18 ft/s) after unpiloted chores at the END of HOLD.  HOLD now does every chore first -- IMU 1,
MSG RESET x2, DAP A10/B10 store, pulse modes -- noting the truth around each, then station-keeps,
and captures only after every truth rate has stayed under 0.02 ft/s for 120 s, with nothing in
between (the run loop's later capture is skipped).  The chores here moved ZD only +0.030 ->
+0.043 ft/s, so v2's 0.18 ft/s was not reproduced; the capture is at ring X +99.1 Y +0.5 Z -2.5 ft,
XD +0.001 YD -0.019 ZD +0.001 ft/s.  Published as `forClaude/rndz-hold-v3/` with the volume and a
README; it supersedes v2.

## 5i. Close in: PASS's filtered state, and the RPM's propellant (2026-10-09, macOS)

Two questions left by the clean run (5g), answered from its logs and
captures (`~/sts134-runs/rendezvous/clean-run1`) and one test run.

**PASS's FLTR state runs 60-130 ft off inside 1,500 ft: PASS behaving as
it should, given its inputs.** The error is along the line of sight
(RBAR and RPM: LVLH Z; VBAR and HOLD: LVLH X), and it equals PASS's own
estimate of the radar's range bias, CGNV_SENSOR_BIAS(3) (#PCGNMC2+3FA,
X'E7A6'), read from each capture:

| Capture (phase end) | FLTR error along the LOS (ft, mean) | Range bias estimate (ft) | Angle bias estimates (rad) |
|---|---|---|---|
| ARRIVAL | -7 | +8.6 | 0.022, 0.001 |
| RBAR | -75 | +82.5 | 0.072, 0.001 |
| RPM | -122 | +108.9 | 0.068, 0.020 |
| TORVA | -64 / -35 | +59.7 | 0.037, -0.030 |
| HOLD | -94 | +111.2 | 0.008, 0.023 |

- **The measurements are right.** In the static R-bar hold the radar's
  range less the truth's averages +1.2 ft (σ 13.9, 31 samples). In the RPM
  it swings ±40-60 ft with the line of sight, which is the antenna's
  45.7 ft lever arm. PASS's model has the same arm (GLR_R_OFFSET_BODY in
  the capture: 45.738, 11.13, -5.79 = kuradar's `ANT_BODY_FT`), and its
  range residuals stay near zero throughout. The check's truth points
  (TRU1's c.g., TGT1's ISS point) are the ones kuradar ranges to.
- **The split is what moves.** On a fixed line of sight, a range bias and a
  position error along it give the same range, and an angle bias and a
  lateral error give the same angles, so only the orbital dynamics can tell
  them apart. PASS lets them trade: range bias σ 26.7 ft (BIAS_VAR 711 ft²),
  τ 600 s, range marks weighted at σ 80 ft (VAR_RR_RNG_MIN 6400).
- **What pushes the split: the verniers' steady translation, which PASS
  never sees.** VERN attitude hold fires continuously at ~0.5 lb/min, about
  0.0003 ft/s² of net translation. That is ~0.011 ft/s per 3.84 s nav cycle,
  under GL5_VEL_THRESH (0.06), so GL5NAV drops every cycle of it, as flown.
  PROP (no marks) therefore runs away: 0.13 to 0.49 ft/s of velocity error
  over RBAR, and 0.5-1.15 ft/s over RPM and TORVA. FLTR follows the radar
  only as fast as those weights allow, and the difference lands in the
  bias states.
- **Operationally:** close in, the crew flew on TCS, HHL and the centerline
  camera, not on PASS's REL NAV. The checklist even says, after the RPM, "use
  raw TCS and raw radar for Rdot until TCS NAV converges" (the
  prox ops sensor table, PDF p. 173). Our pilot and PASS-IDLE's docking autopilot read
  the instruments, not FLTR.
- **Nothing to fix in our measurements.** The vernier's translational
  authority is PASS-IDLE's jet table; if real duty cycles prove smaller,
  PROP's drift and these numbers shrink with it.

**The RPM's 1,552 lb: the pilot held the R-bar point through the turn, the
cue card doesn't.**
- **Where it went:** clean-run1's RPM took 67 THC pulses (+x 16, -x 10,
  +y 3, -y 1, +z 30, -z 7). Its 30 LOW Z +Z pulses cost ~40 lb each,
  because LOW Z makes +Z from opposed, canted X jets. In the HOLD, each +Z
  pulse shows as a 44-50 lb/min spike in the truth's mass (yaGPC2.log
  `vehdyn-state`), against a 0-0.7 lb/min VERN baseline. RBAR (51 pulses,
  7 +Z) cost 507 lb, and HOLD (13 pulses, 5 +Z) 263 lb, the same way.
- **The cue card:** RBAR PITCH MNVR, B, CC 9-8 (PDF p. 306) flies the RPM
  hands off. FLT CNTLR PWR is OFF from P = 100 to P = 60, KU PWR STBY, VERN
  (PRI) for the turn. `--rpm-cue-card` now does that: no pulses, and the Ku
  radar in STBY until the turn ends.
- **Flown that way (`~/sts134-runs/rendezvous/rpm-cue-test`, from
  clean-run1's RBAR capture, port base 49900):**
  - 360° in 17.6 min, every quarter turn within 1.3° of the ISS;
  - **145 lb** for the whole leg, setup included;
  - **but the Orbiter drifted to 1,446 ft ahead and 1,669 ft below, at
    2.5 ft/s ahead and 1.55 ft/s down.** The verniers fire nearly
    continuously through the turns, about 8-12 lb/min or 1.5 jets'
    worth. That is far more than starting and stopping 0.75 °/s needs
    (~70 lb for four quarter turns), so the turn is fighting a coupling.
    The likely source is the new canted F5L/F5R (44° outboard: a lone F5
    yaws and rolls as well as pitches), which PASS-IDLE flagged.
- **So the default stays the position hold** (expensive but safe for TORVA).
  `--rpm-cue-card` is there for when the vernier coupling is understood.
- **For PASS-IDLE (the jet table):**
  - the RPM's ~1.5-jet continuous vernier duty and its 2.9 ft/s net
    translation, against the ~0.4 ft/s a single start and stop should give;
  - whether VERN rate holding at 0.75 °/s chatters on the canted F5s.

## 5j. The RPM as one turn, cue card B (2026-10-09, macOS)

**Why.** The driver flew the RPM as four separate UNIV PTG quarter turns, with
the R-bar point held by THC pulses. That cost 1,552 lb (clean-run1) and
2,219 lb (e2e-run1) over 16-22 min, against 263-1,077 lb for the other legs
(5i: 67 pulses in clean-run1, 30 of them LOW Z +Z at ~40 lb each; and the
verniers spin up at only ~0.007 deg/s^2, so each quarter turn spent about 2
of its 3.3 min accelerating and braking).

**What the card does** (APPROACH, CC 9-7, JSC-48072-134 p. 305; RPM SETUP
A and RBAR PITCH MNVR B). RPM SETUP: PRI and VERN ROT RATE 0.75, PRI Y
OPTION ALL, UNIV PTG P 145 loaded. Then one turn, staged by the aft ADI's
pitch, which starts at 90 in the R-bar attitude (theta below = aft P - 90):

| theta | Card | What it does |
|---|---|---|
| 0 | A/AUTO/PRI, TRK (ITEM 19); FLT CNTLR PWR OFF | PRI spins the Orbiter up toward a target 125 deg on, so that the shortest way there is the RPM's way round |
| 10 | VERN (PRI); KU PWR STBY | vernier hold of the rate |
| 80 | FREE; P ITEM 15 + 270, TRK | no jets: it coasts at 0.75 deg/s; the target is set back to the start attitude |
| 145-215 | photos | the ISS crew photographs the TPS |
| 280 | PRI, A/AUTO | PRI brakes the last 80 deg onto the target |
| 330 | KU PWR ON | |
| 360 | VERN (PRI); FLT CNTLR PWR ON | THC: set up for TORVA |

The card's P values are in its BODY VECT convention; the driver flies the
same stages in its own (P 90 = -Z on the ISS): the intermediate target 125
deg on (P 215), the final one the start (P 90). The APPROACH card also asks,
at 620-580 ft, for "-0.2 < Rdot < -0.1 ... Null Xdot to 0 +- 0.1 ft/sec prior
to mnvr start": the R-bar is no equilibrium -- 600 ft below the ISS with no
thrust the Orbiter falls away at 3 n^2 z (~0.0024 ft/s^2) -- and closing at
0.15 ft/s at the start takes part of that back.

**Built** (rndz_manual.py, `--rpm-mode continuous`, now the default;
`--rpm-mode quarters` keeps the older four quarter turns and `--rpm-cue-card`):
`rpm_continuous()` flies the stages by theta, measured from the truth as the
pitch at which the ISS lies in the Orbiter's body (`iss_pitch`); no THC from
start to end; the vehdyn mass logged every 30 s and at each stage.  Before
it, the card's start rates (Xdot 0, Rdot -0.15) when they are not already
so.  After it, `rpm_recover()` flies back to the R-bar point if the turn left
the Orbiter more than 50 ft off (the card instead goes on into TORVA from
wherever it is; the driver's TORVA arc starts at the R-bar point), its
pulses and propellant logged apart from the turn's.

**Flown** from e2e-run1's RBAR capture, rndz2 volume, LOW Z, port 49900
(~/sts134-runs/rendezvous/rpm-cont-1, -2):

| | four quarter turns, hold (clean-run1 / e2e-run1) | one turn (rpm-cont-1) | one turn, card start rates (rpm-cont-2) |
|---|---|---|---|
| Turn | 16.9 / 16.3 min | 9.0 min | 9.8 min |
| -Z off the ISS at the end | 2-8 deg | 1.2 deg | 2.2 deg |
| Start rates | -- | -- | 5.7 kg |
| Turn: PRI spin-up / VERN / FREE / PRI brake | -- | 7.5 / 0.7 / 0.0 / 1.9 kg | 7.4 / 1.1 / 0.0 / 13.6 kg |
| Position at the end | held within ~10 ft | 273 ft off (0.56 / 0.64 ft/s) | 141 ft off (0.36 / 0.03 ft/s) |
| Back to the R-bar point | -- | 129.3 kg, 45 pulses, 15 min | 78.9 kg, 26 pulses, 8.7 min |
| **RCS in all** | **704 / 1,007 kg (1,552 / 2,219 lb)** | **139 kg (307 lb)** | **107 kg (235 lb)** |

So the turn itself costs 10-22 kg -- the verniers coast through 200 deg of
it -- and almost all the rest is the R-bar's own dynamics, paid either
continuously (the old hold) or once afterwards (here).  The flight's own
RPM propellant is not in our sources.

**TORVA from wherever the RPM ends, as the card** (now the default;
`--rpm-return` keeps the return to the R-bar point first).  TORVA's arc was
already built from the current angle and radius, blending the radius to
400 ft along it.  Flown through TORVA, port 49900:

| | As the card: TORVA from the turn's end (rpm-cont-3) | Return first (rpm-cont-2, then rpm-cont-2b) |
|---|---|---|
| Start rates + RPM | 5.7 + 19.4 kg | 5.7 + 22.1 kg |
| Return to the R-bar point | -- | 78.9 kg, 26 pulses, 8.7 min |
| TORVA starts at | X +118, Z +670 ft (703 ft), XD +0.35 ZD +0.13 ft/s; 78 deg of arc | the R-bar point, 600 ft; 90 deg |
| TORVA | 412.0 kg, 70 pulses, 14.0 min | 320.5 kg, 69 pulses, 15.6 min |
| TORVA error, rms (max) | 5.7 / 3.3 / 11.5 (19 / 17 / 43) ft | 10.3 / 2.3 / 6.1 (43 / 9 / 22) ft |
| **RPM + return + TORVA** | **437 kg (964 lb), ~24 min** | **427 kg (942 lb), ~34 min** |

Within 2 % on propellant: what the return saves TORVA, it spends itself.
The card's way is ten minutes shorter and is what was flown, so it is the
default.

**Not done.** The photo window calls; PRI Y OPTION ALL (a toggle on SPEC 20:
left as it is).

## 5k. Applying all of STS-134's GNC I-loads: a trial (2026-10-09, macOS)

**Question** (Ron's, open): should the rest of STS-134's flown GNC I-loads -- `--dass-iloads all`,
DASS_G2.ASC's PATCH SUMMARY for every `#PCG`/`#DG` csect -- go on top of the rndz2 volume (which
already carries the rendezvous set, tools/sites/sts134-rndz-iloads.json)?  No default changed here.

**What it would change.**  Against the rndz2 volume's UPLINK memory: 1,453 halfwords still at the load
module's (LM) value would take the flight's (MM); 469 already hold MM; 2 hold neither (#PCGGCOM,
left).  By csect, with the named cells (DASS_G2.ASC's symbol listing):

| Csect | Words | What | Rendezvous? |
|---|---|---|---|
| #PCGCMFR | 618 | the DAP's stored A/B configurations (rates, deadbands, pulses, ALT jet options, notch-filter frequencies), CGCS_CG/MOI/POI_ARRAY | yes: the DAP |
| #PCGGCOM | 495 | ascent/insertion/abort guidance: THET/PSI/PPOLY, targets, MECO, OMS dump times, wind tables | no |
| #DGFTREB | 67 | RCS jet reboost/rotation-translation timing (CGCS_RBST_*) | yes: jet selection |
| #PCGMCOM | 61 | **CGYS_I_COAS**, IMU RM constants (CGRS_A_CONS/A_RAMP -- the sources of the seeded thresholds), CGRS_TH_ATT_DG* | yes |
| #PCGYSTA | 42 | **CGYS_TNBST** (star tracker mounting), CGYV_I_CO, star-tracker tolerances | **yes: star-tracker nav** |
| #PCGNREM | 40 | GPS antenna positions and boresights | no (GPS) |
| #DGFFORB, #DGFDORB | 40 | ALT delay factors, jet thresholds, min impulse, pulse phases | yes: DAP |
| #DGPBGPS, #PCGBGPS, #PCGNFLT | 17 | GPS processing | no |
| #DGRRRCS, #DGR8RCS, #PCGRRMC | 14 | RCS leak limits, dilemma counter, FDI tolerance | RM |
| others (#PCGEIPD, #PCGYCAT, #PCGCCOM, #DGRJIMU, #PCGSGNC, #PCGBOBF, ...) | 59 | LFE covariance, COAS LOS, filter count, IMU RM, OMS/RCS gauging, discrete output masks | mixed |

Flagged before flying: CGYS_TNBST / CGYS_I_COAS / CGYV_I_CO (the trackers' and COAS's mounting --
yaGPC2's startrk.c models the TAPE's TNBST as the hardware), CGBV_OUT12_HFF_* (discrete output
words), the RM limits.

**Flown.**  dass-all-run1: IPL (06:10) to HOLD in one process, `--dass-iloads all --low-z
--rpm-mode quarters` (the RPM as e2e-run1 flew it), tape -rndz2.mmv, port base 49900, master
2f123bc.  For a like-for-like baseline, dass-base-run1: the same build and options without
`--dass-iloads`, port 49700, flown alongside.  (e2e-run1, §5h, is an older build; its numbers agree
with the baseline's within run-to-run scatter.)

| | baseline | all I-loads |
|---|---|---|
| FLTR error, ft mean / max: STRKNAV | 11 / 18 | **346 / 945** |
| TI (targeting) | 31 / 39 | **1,109 / 1,301** |
| MC1 / MC2 / MC3 / MC4 | 88 / 76 / 33 / 6 | 252 / 192 / 36 / 12 |
| Ti (TGT 10) PASS solution | +8.93 -0.65 +2.82 (9.39), miss 3.5 | +9.50 -1.64 +3.40 (10.22), miss 12.7 |
| MC1 PASS vs truth's Lambert | -0.15 -0.23 +0.19 vs -0.18 -0.22 +0.35 | -0.21 +0.62 +0.95 vs -0.23 **+1.51** +0.95 |
| MC2 | +0.08 +0.02 -0.03 vs +0.10 +0.01 +0.22 | -0.08 +0.04 -0.45 vs -0.08 **-0.43** -0.18 |
| MC3 | +0.57 +0.04 +1.07 vs +0.61 +0.02 +1.22 | +0.56 -0.31 +1.02 vs +0.59 -0.62 +0.99 |
| MC4 | +0.98 -0.06 +1.06 vs +0.97 -0.11 +1.06 | +0.62 +0.27 +0.36 vs +0.62 +0.22 +0.34 |
| Arrival, MC4 + 13 min | X -34 Y +76 Z +417 | X +31 Y +31 Z +571 |
| Coast RCS, kg/min (post-Ti → MC1, MC1 → MC2, MC2 → MC3, MC3 → MC4) | 0.97, 0.38, 1.49, 2.47 | 2.03, 1.19, 1.80, 1.63 |
| RBAR / RPM / TORVA / VBAR / HOLD RCS, kg | 233 / 1,105 / 372 / 443 / 593 | 135 / 978 / 466 / 431 / 491 |
| HOLD rms (x y z), ft | 3.5 / 2.0 / 2.8 | 2.7 / 2.4 / 1.7 |
| Close in FLTR (RBAR ... HOLD), mean ft | 81 / 176 / 122 / 77 / 61 | 54 / 189 / 126 / 81 / 71 |
| ILLEGAL ENTRY, C&W | 0; 4 SM ALERT TONEs, acknowledged | 0; 8 SM ALERT TONEs, acknowledged |

**The cause of the nav error: the trackers' mounting.**  With all I-loads, star-tracker marks are
accepted with residuals as small as the baseline's (H/V under 0.005 deg), yet FLTR lands 1,000 ft
off: PASS fits the angles exactly with a misplaced target, because the angles it is given and the
geometry it assumes disagree by a constant rotation.  CGYS_TNBST read from the two runs' STRKNAV
captures: the flown matrix differs from the tape's by **0.347 deg (-Z tracker)** and 0.222 deg
(-Y).  0.35 deg at the pass's ~240 kft is ~1,450 ft -- the error seen.  yaGPC2's startrk.c builds
the trackers' pictures from the TAPE's TNBST (as in memory on this tape); the flown TNBST is
STS-134's own alignment (its trackers' calibrated mounting).  So `all` makes PASS's model of the
trackers right for STS-134 and the simulated hardware wrong for it.  The radar then rescues the
state (MC4 onward agrees), but Ti and MC1-MC2 are targeted on a bad state (MC1's Y off 0.9 ft/s).

Everything else changed by `all` looks benign for rendezvous: the flown DAP configurations fly the
manual phase as well (HOLD a little tighter, the per-leg propellant within the run-to-run scatter,
coasts somewhat costlier), and nothing raised a C&W beyond SM alert tones.

**Recommendation.**  Not `all` as it stands.  Either
1. apply `all` **without #PCGYSTA (and CGYS_I_COAS, CGYV_I_CO in #PCGMCOM)** -- i.e. keep the
   tape's tracker/COAS mounting, which is what startrk.c models; or, better,
2. apply `all` **and** change yaGPC2's startrk.c TNBST (and the COAS's) to the flown values, so the
   simulated trackers are mounted as STS-134's were -- a C change (startrk.c's TNBST table, its
   test), for the peer pass.  Option 2 makes everything STS-134's own.
In either case the ascent/abort guidance words (#PCGGCOM, 495) and the GPS ones are irrelevant to
the rendezvous but matter to any ascent run from this volume: worth their own trial before going on
a default volume.  Runs: ~/sts134-runs/rendezvous/dass-all-run1, dass-base-run1.

**Option 2 prepared, opt-in (2026-10-10, review/startrk-mount).**  `YAGPC_STARTRK_MOUNT=flown`
mounts startrk.c's -Z/-Y trackers with STS-134's CGYS_TNBST (DASS_G2.ASC #PCGYSTA+0076,
X'BCD6'-X'BCF9'): -Z turned 0.347 deg from the tape's (boresight 0.238), -Y 0.222 deg (0.218);
test_startrk_mount checks both.  The default stays the tape's.  The COAS needs nothing: the flown
CGYV_I_CO line of sight is the tape's, body -Z (only its second vector, the reticle reference,
was patched), and rndz_instruments' COAS already sights along body -Z.

Verified IPL to Ti targeting (stm-run1, port 49900, `--dass-iloads all`, flown mounting) -- it
**helps but does not fully restore** star-tracker navigation:

| FLTR \|error\| ft, mean / max | baseline (no `all`) | `all`, tape mounting | `all`, flown mounting |
|---|---|---|---|
| STRKNAV | 11 / 18 | 346 / 945 | 74 / 192 |
| Ti targeting | 31 / 39 | 1,109 / 1,301 | 453 / 539 |

Ti (final, FLTR): precision Lambert DVT 10.15 ft/s.  So something else in `all` also costs
star-tracker navigation.  The other patched words near it are not geometric: #PCGYSTA's
CGYS_TOL6/10/12/14 and T_LIM1/2 (mark acceptance), #PCGMCOM's IMU RM thresholds and VEL/ATT
constants, CGMS_GINV and CGMS_OMEGA.  Next to try: `all` less #PCGYSTA's tolerances, or
`all` less #PCGCMFR (the DAP's stored configurations, which change the attitude hold during the
pass and so how steady the marks are).  Until that is found, option 1 (keep the tape's
#PCGYSTA) is the safer way to take the rest of `all`.

**The rest found: the rendezvous filter's initial covariance (#PCGEIPD; bisected 2026-10-10).**
Short runs from dass-base-run1's UPLINK capture (`--from RNDZNAV`, rndz2 volume, each adding one
group of csects to `rndz`; ports 49900/49700/49500), FLTR |error| ft mean / max:

| run | added to `rndz` | mounting | STRKNAV | Ti targeting |
|---|---|---|---|---|
| dass-base-run1 | -- | tape | 11 / 18 | 31 / 39 |
| bis-a | #PCGYSTA, #PCGYCAT | flown | 13 / 21 | 36 / 49 |
| bis-b | #PCGCMFR (DAP configs) | tape | 13 / 21 | 38 / 52 |
| bis-c | #PCGMCOM, #PCGGCOM, the jet/RCS/GPS/misc csects | tape | 56 / 170 | 450 / 518 |
| bis-c1 / c2 / c3 | #PCGMCOM / the IMU RM csects / #DGFTREB, #DGFFORB, #DGFDORB | tape | 19 / 28 | 44-47 / 55-62 |
| bis-d1 / d2 | #PCGGCOM / GPS and small ones | tape | 19 / 28 | -- |
| bis-d3 | #PCGEIPD, #PCGEIPB, the RCS RM, DAP filter counts, ... | tape | 65 / 199 | -- |
| **bis-e1** | **#PCGEIPD alone** | tape | **52 / 142** | -- |
| bis-e2 | d3 less #PCGEIPD | tape | 19 / 29 | -- |
| **bis-e3** | **all of `all` but #PCGEIPD** | flown | **18 / 27** | **43 / 54** |

bis-e3's Ti (TGT 10 final, FLTR) is +8.93 -0.81 +2.77 (9.38 ft/s, miss 3.3) against the
baseline's +8.93 -0.65 +2.82 (9.39, miss 3.5).

The words: **CGNV_SIG_UPDATE_LFE** (#PCGEIPD+00B4, X'BFFC'-X'C007') and
**CGNV_COV_COR_UPDATE_LFE** (X'C008'-X'C015').  The tape holds the source's INITIAL(0) for both;
STS-134 flew sigmas (2000, 20000, 2000) ft and (21, 2, 6) ft/s with correlations of -0.9
(DASS_G2.ASC's PATCH SUMMARY).  GLLREN.hal's GLL_REND_COV_INIT (steps 120-160, lines 163-176)
builds the rendezvous filter's covariance from exactly these when RNDZ NAV is enabled:
E(i,i) = SIG(i)^2, the off-diagonals from the correlations, rotated from UVW to M50.

**The mechanism.**  With the tape's zeros the filter starts certain of its state, so the marks
barely move it.  FLTR then simply rides PROP (compare bis-a, where FLTR and PROP agree to a few
feet), and PROP is excellent because YAGPC_VEHDYN_START_REL hands PASS the true relative state.  With
the flown values the filter starts as uncertain as a real flight's ground-tracked state was:
20,000 ft downtrack, -0.9 correlated with the velocity.  The first star-tracker marks then move it
hundreds of feet.  bis-c shows FLTR jumping +280 ft at the first seven accepts while PROP stayed
within 20.  Angles alone don't observe range, so any systematic angle error moves the state along
the line of sight.  Here that is the target's light centroid offset toward the Sun, about 0.2-0.3
mrad (5b), which at 240 kft is 50-70 ft lateral and maps through the correlated, range-uncertain
covariance into a few hundred feet downtrack.

**So the flown value is the right one, and the baseline's tens of feet are an artefact** of
starting PASS with a perfect state and a zero covariance.  A flight started where STS-134 was --
its onboard state a few thousand feet off the truth, as the flown covariance assumes -- is the
fair test of star-tracker navigation; a few hundred feet at Ti is within the checklist's SV UPDATE
gates.

**Recommendation.**
1. Take `all` (with `YAGPC_STARTRK_MOUNT=flown`) less #PCGEIPD for any run that starts PASS with
   the true state, as these do: it reproduces the baseline's navigation and Ti and carries every
   other flown value.
2. Before #PCGEIPD goes on a default volume, give the start a realistic onboard state: an option
   in the driver (or vehdyn's START_REL) to offset PASS's relative state at UPLINK by an error drawn
   from the flown sigmas.  Then the flown covariance is consistent with the state it describes, and
   FLTR's convergence is a real test.  That is driver or vehdyn work, not a reason to keep the
   tape's zeros.
Runs: ~/sts134-runs/rendezvous/bis-{a,b,c,c1,c2,c3,d1,d2,d3,e1,e2,e3}.

## 5l. Starting PASS with a realistic relative-state error (2026-10-10, macOS)

5k found that STS-134's own initial rendezvous covariance (#PCGEIPD+00B4) is
right, and that the baseline's tens of feet come from starting PASS with the
truth.  `fly_rndz134.py --onboard-error flown[:SEED]` (opt-in, default off)
now starts it the way the flight did: with an error the size of that covariance.

**The draw.**  The target state MCC uplinks (message 10, groundstation `tsv
--state`) is the truth's less e, so PASS's relative state (Orbiter minus
target) starts off by e.  e comes from the covariance GLL_COVINIT_UVW builds
(GLLREN.hal steps 120-140), in the shuttle's UVW frame (GVGUVW.hal: U radial,
W = R x V the orbit normal, V = W x U downtrack):
- CGNV_SIG_UPDATE_LFE (DASS_G2.ASC 21189-21190): position 2000 / 20000 / 2000 ft,
  velocity 21 / 2 / 6 ft/s;
- CGNV_COV_COR_UPDATE_LFE (21193-21194): seven correlations, of which the flight
  set two, (1,5) U with Vdot and (2,4) V with Udot, both -0.9.
The driver logs the drawn e.  Everything else is unchanged: the Orbiter's own
state (message 9) is the truth's, as before.

**Trial** (IPL to final Ti targeting, rndz2 volume, `--dass-iloads all`,
`YAGPC_STARTRK_MOUNT=flown`, `--low-z`, rate 2; oe-run1 on port 49900, oe-run2
on 49700):

| | seed 1 | seed 2 |
|---|---|---|
| drawn e, ft (U V W) | +2576 +28989 +133 | +4676 -13257 +790 |
| drawn e, ft/s | -34.39 -3.27 +0.19 | +13.87 -3.48 -8.41 |
| FLTR at TRACK, mean / max ft | 27,293 / 28,031 | 16,409 / 17,390 |
| FLTR at STRKNAV | 26,101 / 26,807 | 18,040 / 19,707 |
| FLTR at Ti -55 (preliminary) | 15,414 | 4,155 |
| FLTR at Ti -16 (final; no radar before it in this run) | **2,133** | **14,236** |
| marks accepted, by Ti -16 | 123 (34 after sunrise) | 72 (none after sunrise) |
| Ti, PASS final, ft/s | +8.98 -0.76 +3.25 (DVT 9.58) | +6.50 -0.64 -2.30 (DVT 6.92) |
| Ti, the truth's precision Lambert | +9.51 -0.65 +3.54 (DVT 10.17) | (PASS's own relative state at T1 off by about 30 kft) |

Against 5k's e3 (all but #PCGEIPD, truth start): 18/27 ft at STRKNAV, 43/54 ft at Ti.

**What it shows.**
- Star-tracker marks pull the filter in.  Both runs closed several kft within
  the first 30-40 accepted marks; seed 2 was at 2.6 kft by Ti -45.  Then the
  ISS went into the Earth's shadow (Ti -55) and marks stopped.
- **Seed 1** reacquired at sunrise (Ti -21) and closed to 2.1 kft.  Its final Ti
  is within 0.5 ft/s per axis of the truth's Lambert, inside the final-ground limits.
- **Seed 2 never reacquired.**  Its velocity error carried the filter from 2.6
  kft back out to 14 kft while the ISS was in shadow.  At sunrise the -Z track
  pointed where PASS believed the ISS was, about 11 deg off at 70 kft, outside
  the tracker's search, so there was no S PRES and no marks.  Final Ti stayed
  at the preliminary solution.  On the flight, the radar (RR NAVIGATION below
  135 kft, 5d) and MCC's ground solutions are what recover from this; in this
  driver RRNAV comes after the TI phase, so neither run had the radar for Ti.
- So with the flown covariance and a flown-size error, star-tracker navigation
  alone converges or not depending on the draw and the night pass.  That is
  realistic, and it is why the checklist has the radar and the ground's Ti.

**The radar ahead of the final Ti, as flown.**  With the run stopped at TI
the driver had done the final targeting at Ti - 17 before RRNAV; in the
flight's order KU OPS (NAV RNG < 150 kft) and RR NAVIGATION [13B] (RR RNG <
135 kft, about Ti - 40) come first.  TI now brings RRNAV in ahead of the final
when the run stops there; flying on through the burn, TIBURN's final already
came after RRNAV.  Re-flown through MC1 (oe2-run1/2, same seeds, ports
49900/49700):

| FLTR error, ft | Ti-69 | -55 | -45 | -41 (RR < 135 kft) | -38 | -36 | -30 | -20 | -17 | +5 | +19 |
|---|---|---|---|---|---|---|---|---|---|---|---|
| seed 1 | 26,497 | 15,060 | 11,429 | 10,165 | 585 | 236 | 105 | 18 | 105 | 52 | 78 |
| seed 2 | 17,830 | 4,675 | 3,052 | 3,250 | 952 | 888 | 323 | 68 | 45 | 94 | 47 |

RR NAV converged (RNG ACPT 10, SV UPDATE POS < 0.02 kft) at Ti - 36.8 in both.

| | seed 1 | seed 2 |
|---|---|---|
| Ti final, PASS | +9.48 -0.67 +3.64 (10.17) | +9.61 -0.63 +3.49 (10.24) |
| Ti, the truth's precision Lambert | +9.55 -0.65 +3.59 (10.22) | +9.49 -0.67 +3.54 (10.15) |
| Ti flown (sensed) | 10.23 ft/s | 10.31 ft/s |
| MC1 onboard / ground / flown | +0.12 +0.01 -0.11 / +0.11 +0.12 -0.07 / 0.17 | +0.09 -0.03 -0.08 / +0.05 -0.02 +0.05 / 0.14 |

Both Ti solutions are within 0.12 ft/s per axis of the truth's, and both MCs
burn onboard within limits: the radar recovers a flown-size error, seed 2's
unconverged night pass included, as on the flight.

**The other error figure, corrected.**  The "check" lines' |PASS - truth|
target error read ~2.8 kft while the strk lines' relative error read 26 kft at
the same time (oe-run1).  The check refused any cycle whose PASS target state
was more than 8,000 ft off the truth -- a guard against the downlist's 1 s
turnover between frames 0 and 5 (~24 kft) -- and silently repeated the last
good comparison, which with an uplinked 29 kft error was from before the
uplink: stale.  The strk lines (the tables above, and 5k's) were right.  The
check now tells a turnover by PASS's own consistency -- this cycle's target
state against the last one's carried along its velocity, more than 4,000 ft
apart -- and labels a repeated line STALE.  In oe2-run1 at Ti - 69 the two
agree: target 26,604 ft, relative 26,639 ft.

**The star tracker's search.**  PASS itself already falls back from the offset
box to a 20 s full-field scan and starts over (GY3STT, 5b), and the driver
breaks track and retries at acquisition ([10A]'s BREAK TRK).  Neither can find
a target 11 deg off the -Z axis, outside the tracker's field: the recovery is
the radar (above) or MCC.  No further search was added.

**Not done.**  More seeds; the trial on through MC2-MC4 and the manual phase.

**The owner's decision, pending.**  5k and 5l together leave the choice of
default for rendezvous runs open.  With the radar ahead of the final Ti
targeting, `--dass-iloads all` with `YAGPC_STARTRK_MOUNT=flown` and
`--onboard-error flown` recovers on both seeds; Mac-portview's recommendation
is that combination.  The tracker mounting is in yaGPC2 (startrk.c, peer-passed
at 6e767035f) but opt-in, the tape's mounting the default.  `all` less
#PCGEIPD with the flown mounting reproduces the baseline when PASS is started
with the true state.  Also still the owner's: the default volume
(Mac-portview suggests `-rndz2.mmv`) and the IGOAL radiator white plate.

## 5m. Docking, and the aft flight station (2026-10-09/10, Linux)

**Docking is flown.**  vehdyn's capture model and `examples/flights/
dock_autopilot.py` fly from the 100 ft hold to hard mate unattended, at cue
card 9-8's schedule: LOW Z at 0.15 ft/s to 75 ft; DAP B, NORM Z and A10/B10 at
0.10 ft/s to 30 ft; an alignment hold; 0.07 ft/s to 10 ft; 0.10 ft/s to
contact.  First flown in dock10 (contact 0.100 ft/s, 1.17 in, 0.51 deg or
less); every run since captures and hard-mates the same way.  The A7L sequence
follows cue cards 9-11/9-12.  Run with `dock_autopilot.py --from DOCK30
--targets <file>`, the ISS's line ending in `port 15.655 0 5.562`.

**PMA-2's port is the ISS model's own.**  The port was first a model value,
(15.66, 0, 5.48) m.  The ISS model portview draws puts its PMA-2 face at
(15.655, 0, 5.562) m, axis +X, 8.2 cm further nadir, and MON1 showed the ring
2.3 deg low against the crosshair.  The crew docked to what they saw, so the
port follows the model -- in the targets file, `tools/tle_target.py`,
portview, rndz_instruments and the centerline target -- and a restore takes
the port from the targets file over the capture's.  Hard-mated, MON1's ring,
target and crosshair are concentric within 2-3 px.

**The aft station, as the crew had it** (with `--crts 4 --views
aft,cctv,rpop`):

- AFD 1 shows the ORBIT PFD and CRT 4 shows PASS (SPEC 33 REL NAV), both fed
  by IDP 4, with keyboard 3 wired to IDP 4 alone (SCOM p261, p277, p310).
  What AFD 1 showed during docking is not documented; the checklist names DPS
  pages for "CRT", so the split is an inference.
- CRT 3 is released before CRT 4 is assigned to GPC 1, because a PASS GPC
  commands at most three IDPs ('>3 DEU', gpc-causes #99).
- PASS loads an IDP only in OPS 0 after its IPL, in PL 9, or in SM 2/SM 4
  (OI340600 DMIMCD.hal 508-530).  A GNC computer in OPS 2 polls a freshly
  powered IDP 4 and never loads it (gpc-causes #294).  On the vehicle every
  IDP was loaded long before docking.  So `fly_rndz134.seed_idp4` gives a
  capture with IDP 4 off IDP 1's loaded state.  A full flight could instead
  power and load IDP 4 in OPS 0.
- RPOP, the aft PGSC's display (`rpop.py`, Mac-portview, from JSC-63400 Fig
  20.4), gives TCS and HHL range and rate; `rpop` in `--views` or the
  Manager's aft station starts it.
- MON1 is the ODS centerline camera on A3; MON2 is its neighbour.

**Open.**

- SPEC 23 F1F/F2F deselect, and the angular flyout.
- The crew's commands to the APDS, beyond the A7L sequence.
- The stack's shared momentum at contact, and the post-contact thruster
  firing (PCT).
- The 4 deg angular capture limit is a model choice, not documented.
- The virtual RHC/THC shows its red "inactive" message while scripted input
  visibly moves the controllers.  It should not show while scripted input
  drives them; the window should not grab focus to hide it.
- For the video: a layout per station, switched by the script at the handover
  to the aft station, and SimpleScreenRecorder driven through its stdin
  (`record-start`, `record-save`).  Agreed with the owner; not started.

## 5n. Option B: the flight's GNC, as one switch (2026-10-10, macOS)

Ron's decision (2026-10-10): keep **option A** -- the rndz2 volume, the tape's
star-tracker mounting, PASS started on the true state -- as the default, and
add **option B** as one switch to try; B becomes the default only once it has
been flown to the hold.

**Option B** is `fly_rndz134.py --flight-gnc`:
- the volume `~/sts134-runs/rendezvous/OI340700-v44boot-sts134-ksc6-gnc.mmv`
  (unless `--tape`), built from the KSC6 volume with
  `tools/sites/sts134-gnc-iloads.json` (`python3 mission_reconfig.py
  sites/sts134-gnc-iloads.json <KSC6 volume> --out <it>`; SHA-256
  82fbcfcda355d8d4..., also in forClaude/volumes/);
- `YAGPC_STARTRK_MOUNT=flown` in yaGPC2's environment (the flown CGYS_TNBST,
  5k);
- `--onboard-error flown` (5l; a seed given with `--onboard-error` is kept).

**The spec** is the rndz set (242 cells) plus 277 more: every #PCG*/#DG*
word the DASS_G2 PATCH SUMMARY changes, except the ascent/abort guidance
compool #PCGGCOM (495 words, untried), placed only in G2's own load block
(offsets 109968 resident, 576000, 635804/635808, 643162, 649516, 649900,
1133994; #PCGCMFR at -75566), 519 copies in 9 load blocks, none refused.  Not
placed: about 80 words with no reliable anchor (mostly GPS quality tables in
#DGLJRCV, a few output masks, two DAP filter words).

**gnc-run1** (IPL to HOLD in one process; port 49900, rate 2,
`--flight-gnc --low-z`, seed 134; RPM continuous, TORVA from where it ends).
It does NOT yet fly the manual phase.

| | Option A (e2e-run1, 5h) | Option B (gnc-run1) |
|---|---|---|
| Onboard error drawn | none | U -1325 V +1326 W +4377 ft, -3.3 +1.2 -11.4 ft/s |
| FLTR error at Ti | tens of ft | 7.6 kft |
| RR range marks before Ti | accepted | **all 177 rejected** (residual over the edit limit); rdot and angles accepted |
| Ti, PASS / truth's Lambert | +8.92 -0.67 +2.83 / +8.92 -0.67 +2.87 | +9.51 -4.26 +0.49 / +8.81 -0.64 +2.72 (flown) |
| MC1 | onboard | onboard -0.65 -1.09 -0.19 vs truth -0.18 -0.03 +0.34 (outside 3 sigma) |
| MC2 | onboard | onboard outside limits; ground -0.20 -0.73 -2.77 flown |
| MC3 / MC4 | onboard | onboard, within 0.2 ft/s of the truth's |
| Arrival (MC4 + 13 min) | X +11 Y +42 Z +560 | X -30 Y +17 Z +501 ft |
| RBAR | rms 3.8/1.1/2.4 ft, 411 lb | rms 1.4/1.1/3.7 ft (last 3 min), 329 lb |
| RPM | 2,219 lb (quarters) | 91 lb, but 300+ ft of drift in X and Y |
| TORVA / VBAR / HOLD | flown, 863 / 1,077 / 660 lb | **diverged**: TORVA rms 365/239/538 ft; VBAR and HOLD drifted to tens of kft |
| ILLEGAL ENTRY | 0 | 0 |

**Two findings:**
1. **RR range marks rejected.**  With FLTR thousands of feet off when the
   radar locked, every range mark failed PASS's edit test until after Ti; only
   range rate and angles went in, which cannot fix range.  The flight's
   remedy is the crew's: RR NAVIGATION [13B]'s FORCE when the residual ratios
   stay high and steady.  The driver doesn't do that yet.  (The 5l seeds
   started differently and converged.)
2. **Attitude hold lost in the manual phase.**  From the start of RBAR
   (DAP A/AUTO/VERN, -Z target track) the -Z axis swung 30 -> 164 -> 74 deg
   and kept swinging; position was held but the attitude was not.  A resume
   from the arrival capture without LOW Z did the same, more slowly (21 ->
   92 -> 158 deg over 13 min), so it is not LOW Z alone.  Option A's runs
   held attitude in the same leg, so it comes with the new csects: #PCGCMFR
   (the stored DAP configurations, notch filters, mass properties) or #DGFFORB
   / #DGFTREB / #DGRRRCS (jet selection), against vehdyn's jet table.  This
   needs PASS-IDLE's look (vehdyn's jets) before B can fly the manual phase.

**Recommendation:** keep option A the default.  Before B can become the
default: (a) the driver's RR FORCE per [13B]; (b) find what in #PCGCMFR /
#DGF* makes VERN AUTO lose attitude with vehdyn's jets -- bisect those two
groups from gnc-run1's arrival capture; (c) fly B to the hold again.
Runs: `~/sts134-runs/rendezvous/gnc-run1`, `gnc-rbar-nolowz`.

**Follow-ups (review/flight-gnc-2, 2026-10-10, macOS).**

*The attitude hold: the verniers were deselected, not a DAP or I-load
fault.*  Bisected from gnc-run1's arrival capture:
- On option A's arrival with `--dass-iloads` (all of B's csects but
  #PCGGCOM; then #PCGCMFR alone), attitude held, with -Z 2-4 deg off the ISS.
- On B's arrival, it swung with the flown star-tracker mounting and without
  it, and with the true state vectors uplinked at the resume.
- So it was not the mounting and not PASS's state.

A new check-line probe settled it:
- PASS's attitude (CGNV_Q_BI_HFE) agreed with the truth to 0.07 deg.
- After a UNIV PTG maneuver in DAP A/AUTO/VERN, the DAP's own
  CGCV_ATTITUDE_ERROR grew steadily (0 -> 13 deg) and nothing fired.
- CGRB_JET_AVAILABLE read FWD X'FFCF' and AFT X'FCFFFCFF': all six
  verniers deselected.

The mechanism:
- #DGRRRCS's flown vernier leak limits in orbit
  (CGRS_{F,L,R}VRCS_{OX,FU}_LEAK_TEMP_LT_ORB) are X'4100' = 16640 counts,
  2.6 V, against the source's 1.3 V.
- GRRRCS.hal (1.12) copies them into the working limits when VERN is first
  selected in OPS 2.
- mdmdev.c reported every injector at 2.5 V (16000).
- Every vernier therefore read as leaking, and RM deselected it.

Why the earlier bisects missed it:
- A `--dass-iloads` resume patches the I-load, but not the working limit
  already copied, so no resume can show it.
- Option A's rndz2 volume doesn't carry #DGRRRCS.

The fix is in mdmdev.c (yaGPC2, not vehdyn): INJ_WARM is now 20000 (3.125 V),
clear of both limits. test_mdmdev now checks that the injectors are above the
flown limit, and `make test` is clean.

With it, in gnc-run2:
- the verniers stayed selected (FWD X'FFFF', AFT X'FFFFFFFF');
- −Z was 1.2 deg off the ISS at arrival, where gnc-run1 was 21 deg off.

A checklist R-bar attitude ([20B]/[20C], TGT ID 2, BV 5, P 270) was tried
while this was open. It is not kept: the -Z track holds once the verniers
fire.

*RR FORCE.*
- **The checklist:** RNDZ/134 [13B] has none; it says that if RESID RANGE
  > 5.0 or RDOT > 3.0, go SV SEL PROP, take data, and call MCC.
- **What the driver does:** `rr_converge` logs [13B]'s initial residuals and
  plays "this driver's MCC". When range rejects outrun accepts by 10 and the
  last six residuals have one sign, it keys FORCE RNG (ITEM 19) and RDOT
  (ITEM 22). It returns to AUTO (17, 20) after 10 forced marks or
  |resid| < 1.
- **Opting out:** `--no-rr-force`.
- **gnc-run2:** the initial RESID RANGE was 9.07, RDOT 0.79. FORCE came at
  80 rejected against 7 accepted. After 4 forced marks the residual was 0.03,
  and the driver went back to AUTO.

*CC 9-7's 650 ft RR inhibit.*
- **What the driver keys:** GNC 33 INH RNG, RDOT, ANGLES (ITEMs 18, 21,
  24), at the manual phase's start. Arrival is already inside 650 ft.
- **KU power:** the continuous RPM's KU PWR STBY at 10 deg and ON at 330 deg
  were already there, and both runs logged them.

**gnc-run2** (B, IPL to HOLD in one process, port 49900, rate 2,
`--flight-gnc --low-z`, headless) and **optA-run650** (A, the same on the
rndz2 tape, port 49700):

| | Option A (optA-run650) | Option B (gnc-run2) |
|---|---|---|
| Ti final, onboard / ground | +9.52 -0.68 +3.54 / +9.49 -0.66 +3.54, onboard | +10.31 -0.27 +5.50 / +9.51 -0.67 +3.59, ground's burned |
| MC1 | onboard | onboard |
| MC2 | onboard | onboard outside the limits; ground's burned |
| MC3 / MC4 | onboard | onboard |
| Manual phase start (CG from the ISS) | X +26 Y +31 Z +531 ft | X -59 Y +210 Z +462 ft |
| RBAR, last 3 min | rms 3.6/3.1/4.2 ft, 316 lb | rms 3.7/11.4/1.5 ft, 327 lb |
| RPM (continuous) | 9.5 min, -Z 6.1 deg off at the end, 53 lb | 9.6 min, -Z 26.1 deg off, 57 lb |
| TORVA | rms 7.7/2.2/22.3 ft, 672 lb | rms 10.0/4.2/14.0 ft, 1,429 lb |
| VBAR | rms 1.9/2.6/9.8 ft, 996 lb | rms 1.7/1.3/11.6 ft, 1,570 lb |
| HOLD | 22.7 min, rms 2.8/1.8/1.2 ft, 725 lb | 26.9 min, rms 3.3/2.6/2.2 ft, 622 lb |
| Tracebacks / ILLEGAL ENTRY | 0 / 0 | 0 / 0 |

**B now flies to the hold.** Its TORVA and VBAR cost 2.1x and 1.6x A's
propellant. B starts the manual phase 210 ft out of plane, where A starts
31 ft out, and ends the RPM 26 deg off the ISS against A's 6.

**Recommendation:** B is flyable end to end. Before it becomes the default:
- PASS-IDLE reviews the mdmdev.c change. It affects every volume that
  carries the flown #DGRRRCS.
- Fly a second B run. The open item is B's out-of-plane arrival and its
  TORVA/VBAR propellant.

Runs: `gnc-run2`, `optA-run650`; the bisect probes `bisA-full`, `bisA-a`,
`bisB-repro`, `bisB-tapemount`, `bisB-fresh`, `bisB-rbaratt`, `bisB-att`.

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
