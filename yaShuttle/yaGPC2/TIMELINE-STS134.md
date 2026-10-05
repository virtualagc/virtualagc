# STS-134 launch to orbit: the simulated timeline

This is the flight being flown in yaGPC2: one GPC running PASS OI-34 (tape
`OI340700-v44boot` with STS-134's OPS 1 overlay I-loads), from IPL on LC-39A
to the orbit after OMS 2.

**T = 0 is SRB ignition** (the MECs fire SRM IGNITION; the hold-down posts let
go). STS-134's was **136/12:56:27.994 GMT** on 2011-05-16 (JSC 37461,
Appendix A). In the simulated flights SRB ignition comes at
**136/12:56:27.81**: the ground uplinks the GMT of liftoff as 12:56:25, because
PASS's RSLS starts the SSMEs 3.8 s before it and fires SRB ignition 6.6 s
after that, so T−0 = GMTLO + 2.8 s (GSRRSL.hal:370, 379, 822-823, 1859-1872).

Each row says who acts:
- **CREW**: keystrokes on CRT1/KB1, or panel switches and pushbuttons.
- **GROUND**: LPS countdown commands on the launch data bus, or uplinks
  through the NSP.
- **SIM**: the simulation itself, such as the vehicle clock and the starting
  state.
- **PASS**: the flight software's own actions, shown for orientation. Nobody
  supplies these.

The whole sequence is scripted by `discretePanel/examples/flights/fly_sts134.py`.
`--from PHASE` resumes from the capture the previous phase left;
`--reuplink` (with `--from COUNT`) sends the day-of-launch I-loads again
before OPS 101, onto the already aligned vehicle.  `--flight FILE` flies
another flight with the same model (`sts135-flight.json`; see the STS-135
cross-check below).  The driver ends the simulation after the last capture.

**LPS** is the Launch Processing System: the ground's countdown computers in
the KSC firing room.  Until liftoff they talk to the GPCs over the launch
data bus, through the T-0 umbilical.  Here that is `lpsmodel.c`.

**How liftoff happens.**
- The truth model holds the stack on the pad (`vehdyn.c`'s pad state:
  Earth-fixed, with the pad's 1 g reaction felt by the accelerometers).
- It releases the stack when the MEC model sees PASS fire SRM IGNITION.  On
  the vehicle the same MEC command fires the hold-down nuts.
- T-0 UMBILICAL is only logged: nothing models what it disconnects.

## Sources of the times

| Phase | Where the times come from | Notes |
|---|---|---|
| Pre-launch | Run `sts134` (panel and yaGPC2 logs) | Accurate to about ±10 s. The pre-launch timetable is *ours*: STS-134's real countdown spread these activities over a day (S0007 and the GLS document; see References). |
| Terminal count | Run `sts134c` | The procedure and its times are unchanged since. |
| Ascent, OMS 2 and the orbit | Run `sts134e` (scratch-2026-10-03) | Resumed from the countdown capture of the full reference flight `sts134d` (from IPL), with the current model and DOLILU.  Times are from its SRB ignition, 136/12:56:27.81. |
| Max-q and SRB separation with the day's weather and the flight's separation I-loads | Runs `w2` and `s1` (scratch-2026-10-03) | Resumed from a first-stage capture (`cap-w1`) with the 12:56Z sounding as the truth; `s1` adds the separation I-loads to its memory.  Shown in the ascent table where they differ from `sts134e`. |
| STS-134 actual | JSC 37461, Appendix A | Shown alongside where it exists. |

## The timeline

### Setup on the pad (OPS 0 → OPS 9)

| T | GMT 136/ | Who | Event | Data source |
|---|---|---|---|---|
| −1:26:28 | 11:30:00 | SIM | Vehicle clock starts (`--date-time-epoch 2011-05-16T11:30:00`). The stack is on the pad at the nav base, belly north. The masses are STS-134's at SRB ignition: orbiter 268,769 lb (121,912 kg), each SRB 1,299,069 lb, ET 1,657,445 lb.  The ET is loaded with 1,612,805 lb (LO2 1,381,587, LH2 231,218: mixture ratio 6.0 plus the 954 lb fuel bias), so that after the main engines' 13,860 lb on the pad it weighs 1,657,445 at SRB ignition.  The truth's RNP epoch is 2011 day 136. | Pad position: NAVBASE I-loads (CGNCOM). Belly north: STS-1 OFP 4.2.1.21. Masses: Space Shuttle Missions Summary App. A (orbiter 229,529 without cargo + 39,210 cargo + 30; SRBs 1,298,824 / 1,299,313; total 4,525,091 = these + 740 lb in no column). SLWT inert 58,500 lb (SCOM). |
| −1:26:21 | 11:30:07 | CREW | GPC 1 to HALT; IDP 1 power ON; IPL source MM1; CRT 1; IPL; GPC mode STANDBY | `examples/ipl-one-gpc.script` |
| −1:26:09 | 11:30:19 | CREW | `ITEM 1 EXEC` on the GPC IPL display | |
| −1:25:34 | 11:30:54 | CREW | GPC 1 mode RUN; IPL source OFF | |
| −1:25:11 to −1:23:35 | 11:31:17 to 11:32:53 | CREW | GPC MEMORY, memory configuration 1 (OPS 1): `ITEM 1 +1`, then GPC 1 selected and 2-4 deselected (`ITEM 2 +1`, `3/4/5 +0`), then every string, payload and launch bus to GPC 1 (`ITEM 7,8,9,10,11,12,18,19 +1`) | The NBAT layout comes from SSSRC/CD0001.dfg |
| −1:23:27 to −1:21:51 | 11:33:01 to 11:34:37 | CREW | The same NBAT for configuration 9 (`ITEM 1 +9`, then the same items). Without this, OPS 9 commands string 1 only, and IMUs 2 and 3 are never read. | Found in this work. |
| −1:21:30 | 11:34:58 | CREW | `OPS 901 PRO`: preflight G9 | |
| −1:20:50 | 11:35:38 | CREW | `SPEC 1 PRO` (DPS UTILITY) | |
| −1:20:45 | 11:35:43 | CREW | `ITEM 50 EXEC`: GSE POLL ENABLE, the launch data bus to the ground | |
| −1:20:35 | 11:35:53 | CREW | `SPEC 104 PRO`: GND IMU CNTL/MON | APPLSRC/CV1040.dfg. On the vehicle this is called up on CRT2 by LPS (S0007 Vol 2 p618). |

### Day-of-launch uplink (OPS 9)

The ground sends these through the NSP with `groundstation.py`, between T−1:20:24 and T−1:19:35.

| Who | Message | Contents | Data source |
|---|---|---|---|
| GROUND | **59** RNP epoch | LAUNCH_YEAR 2011, RNP_DAY 136 | Launch date: JSC 37461 |
| GROUND | **15** launch targeting | T_GMTLO_REF 11,796,988 s (136/12:56:28). IY_MIN = IYD = IYD_NOM: now **the ISS's orbit plane at T−0**, (0.75822, −0.20025, −0.62049) Earth-fixed, from the Space-Track TLE (epoch 11136.48289737: i 51.6484°, RAAN 323.2151° at T−0, node 255.2057° Earth-fixed). The pad was 44.8 nmi off that plane at T−0. Run `sts134c` flew the earlier vector, (0.75321, −0.21645, −0.62115): the 51.6° plane through the nav base (inertial azimuth 44.95°). DELTA_PSI etc. are 0. | 51.6°: MOD FRR FDD p3 and JSC 37461. ISS plane: Space-Track TLE. The geometry is this work's; convention checked against the tape's own 38° vector. Test flight `iss1`: MECO with 922 kg LO2 left against 780 for the in-plane vector. |
| GROUND | **12** yaw table PSI(30) | The tape's table turned by **−28.71°**: −18.71° for the inertial azimuth (63.66° → 44.95°), and −10° found by flight.  The first stage then ends 18 nmi out of the final plane instead of 29, and MECO is reached; at −18° and −26° the tank runs dry first. (PSI = tan(ψ/4), GG31ST step 16.) | Tape values; flights `p10`, `p18`, `p26` |
| GROUND | **13** pitch table THET(1,30) | **Shaped by flight to the ASCENT ADI – NOMINAL cue card** (see "Against the card" below).  THET is applied before the yaw turn, and load relief takes several degrees at max-q, so it runs well above the flown pitch: up to 78.8° near Vrel 1,280 ft/s. | STS-134 Ascent Checklist CC 10-11 (ASC-14a/134); flights `p7`, `p10` (commits 63608afdb, a34c5a538). Calibrated on the simulated vehicle, as the real DOLILU was for the real one. |
| GROUND | **40** roll table PHI(15) | The same −28.71° turn at liftoff (PHI(1) = PSI(1): no roll on the pad), blended out by heads-down (180°) | |
| GROUND | **14** QPOLY, TREF | QPOLY = 55, 955, 1187, 10000 ft/s: the simulated vehicle's Vrel at STS-134's throttle times. TREF_ADJUST = **21.4 s**: the vehicle reaches VREF_ADJUST 488 ft/s at T+21.15, and guidance sees it on its next pass, so TDEL stays inside the 0.21 s deadband and adaptive throttling stays off.  Both must be re-read whenever the first stage changes: 0.3-0.7 s off moves the bucket to 65-92%. | JSC 37461 Appendix A: 104.5% at T+4.1, 72% at T+39.5, 104.5% at T+51.3; JSC 37461 SSME section: single-step bucket to 72%, AGT not activated. GG31ST (THRT_FAC 6000/4500, deadband 0.21 s). |
| GROUND | **11** winds WNDE_TAB / WNDN_TAB | ft/s toward east / north at ALT_WND 0, 8, 18, 28, 38, 48, 58, 80 kft: east 6.9, 49.3, 39.9, 69.9, 111.6, 84.7, 42.3, −47.5; north 0.0, −8.7, 7.2, −2.2, −45.6, −17.6, −37.1, 5.9.  First-stage guidance flies its pitch and yaw tables against air-relative velocity, so these shift it as the day's winds would.  The tape's are all 0. | The Cape Canaveral sounding (station 74794) of 2011-05-16 **12Z**, the last balloon before launch in the University of Wyoming archive (nothing from 00Z-09Z exists for that day).  The ground's own DOLILU winds (Jimsphere, the 50 MHz profiler) are not available. |
| GROUND | **39** THROT | 104, 72, 104, 104 (INTEGER; the Block II controller runs a 104 command at 104.5%) | JSC 37461 (SSME section, Appendix A) |
| GROUND | **96** MECO pseudo targets | VDMAG 25,819 ft/s; GAMD 0.65° | STS-134 Ascent Checklist (ASC/134/FIN): MECO "√VI = 25819" |
| GROUND | **37** OMS assist and masses | ASSIST_OMS_DT 170 s. MASS_ORBITER_LIFTOFF 8,353.6 slug (268,769 lb), and the tape's other orbiter masses moved with it. MASS_VEHICLE_ET 59,868.7 slug (orbiter + ET at SRB ignition). The rest is the tape's own 58 halfwords. | MOD FRR FDD p26: "170 sec OMS Assist". Masses: Missions Summary App. A. |
| GROUND | **25** OMS targeting | IYD_OMS(1,2) = the plane of message 15. OMS 1 is the tape's (not flown). OMS 2: DTIG 1,756 s after ET separation, with pre-flight targets HT 175.8 nmi, θT 330.43°, C1 0, C2 0. **After MECO the ground designs the real targets from the insertion and uplinks message 25 again, in OPS 1** (`fly_sts134.py`, `oms2_targets`): the cheapest burn that reaches STS-134's 124.3 × 175.8 nmi, read as heights above a 6,371 km mean radius (120.45 × 171.95 above the equatorial radius).  In run `sts134e`: HT 171.95, θT 344.30°, 264.6 ft/s. | TIG: JSC 37461, ET sep at MET 8:42 and OMS-2 TIG at MET 37:58. Targets: `omstarget.py fromlog` and `design` (PASS's GGOTGT + GGILTV, ported). The convention: see "Derived data". |

Not uplinkable, so they are on the tape instead (`yaGPC2/tools/mission_reconfig.py` with `sts134-reconfig.json`, OPS 1 overlay; the GSE_ cells are in GSESRB's data, G16 39a0c-39a37):

| Cell | Tape | STS-134 | Data source |
|---|---|---|---|
| CGGS_V_MAG_MECO_NOM | 25,668 | **25,819** ft/s | Ascent Checklist |
| CGGS_K_CMD_NOM | 100 | **104**% | JSC 37461: 104.5% to the 3-g throttling |
| CGGS_RAD_MECO_NOM | 21,290,308 ft (a + 60.02 nmi) | **21,241,604** ft = a + 52 nmi, where a = 20,925,646.3 ft is PASS's equatorial radius | Space Shuttle Missions Summary (NASA 20110001406), STS-134: "a 52 nautical mile MECO", one of the flight's performance enhancements. The tape's own value fixes the convention. Run `sts134c` flew 21,250,656 ft (a + 53.5 nmi, from an unsourced "107 km"). |
| CGGV_RAD_MECO | 21,290,308 ft | **21,241,604** ft, the same as RD_NOM | The radius second-stage guidance flies to until the guidance parameter reset (GG42ND step 54, T+218); the flight source initializes it to RD_NOM's value (CGGC01).  Left at the tape's 60 nmi it lofted second stage and dove at the reset (commit 7190ce67d). |
| CGGS_FPA_MECO_NOM | 0.5° | **0.65°** | No STS-134 value found. With VI 25,819 it gives a post-MECO apogee near the MOD FRR's "insertion altitude 122 nm". |
| CGGS_ASSUMED_SSME_FAIL_MET (TFAIL) | 218 s | **0**: no second-stage trajectory lofting | FSSR STS 83-0002-34 §4.8 ("if trajectory lofting is desired (TFAIL is not zero)").  No STS-134 value is published; the tape's 218 s lofted second stage ~30,000 ft above the card and dove at the RTLS/AOA boundary (also 218 s); with 0 the climb rate follows the card (commit 63608afdb). |
| CGGS_ROLL_CMD_CHANGE_V (V_RHO_PHI) | 12,500 ft/s | **12,000** ft/s | The Earth-relative velocity at which second-stage guidance commands the roll to heads-up (PHI_2STG).  A second-stage I-load built into each flight's load: FSSR Table 4.2-1 (the DOLILU parameters) and §4.12 (the uplink memory groups) do not include it.  12,000 puts the roll on the Ascent Checklist's "VI = 13.2K √Roll Heads Up"; the tape's value started it near Vi 13,700 (commit 531edd4a6). |
| GSE_SEP_CMD_DELAY (V97U9753C) | 6 s | **4.42 s** | The SRB separation command delay after both SRMs' Pc < 50 psia.  GSESRB declares it and the five below as locals carrying the generic release's values, which a flight's I-loads replace (commit d63cfcfd2, gpc-causes #277).  All six: Booster Console Handbook SCP 2.2.1, Table 2.2.1-I (typical values).  Checked against the mission reports' Appendix A: 2002-2011 flights separated 4.32-4.80 s (mean 4.53, 20 flights) after the later SRM's 50 psi, which is 4.42 plus half of GSESRB's 0.16 s cycle; 1989-96 flights 4.88-5.60 s (mean 5.10), an earlier value. |
| GSE_SEP_MOD_DELAY (V97U9752C) | 4.3 s | **2.71 s** | Moding: the SRB nozzles to null, the PICs armed |
| GSE_BU_CUE_TIME (V97U9751C) | 130.6 s | **131.28 s** MET | The backup cue, if the Pc test fails |
| GSE_SEP_CMD_ABORT_DELAY (V99U7589C) | 8.16 s | **10 s** | One SSME out |
| GSE_SEP_CMD_CONT_ABORT_DELAY (V99U7676C) | 10 s | **14 s** | Two SSMEs out |
| GSE_MAX_SEP_CUE (V97U9761C) | 5.9 s | **5 s** | The most the two SRMs' 50 psia times may differ |

### IMU operate and gyrocompass alignment (OPS 9, SPEC 104)

| T | Who | Event | Data source |
|---|---|---|---|
| −1:19:32, −1:19:29, −1:19:26 | CREW | `ITEM 13`, `14`, `15 EXEC`: IMUs 1, 2, 3 to OPERATE | GUCIMU.hal 293-315. FF card 13 ch 0 bit 10 (CGBOBF.hal). |
| −1:18:52 to −1:18:46 | (IMUs) | IN OPERATE, about 40 s after each command | KT-70 runup 29-45 s (IMU SOP FSSR sts83-0013-34 p10) |
| −1:18:30 to −1:18:24 | CREW | `ITEM 16`, `17`, `18 EXEC`: SEL IMU 1, 2, 3 | |
| −1:18:19 | CREW | `ITEM 19 EXEC`: ATT DET, about 4 min. It **deselects the IMUs when complete.** | GMSIMU; PASS User Guide p417 |
| −1:13:28 to −1:13:22 | CREW | `ITEM 16`, `17`, `18 EXEC`: select again | |
| −1:13:18 | CREW | `ITEM 24 EXEC`: GYROCOMP, two positions, about 47 min | GMXGCA.hal. 38-42 min on the vehicle (S0007; LCC GNC-62). |
| ≈ −0:26 | PASS | GYROCOMP CPLT. GC_ALIGN1 maintenance follows until OPS 1. | GMXGCA; flag V95X0010X |

### Terminal count (OPS 1)

| T | GMT 136/ | Who | Event | Data source |
|---|---|---|---|---|
| ≈ −0:23 | ≈ 12:33:30 | CREW | `OPS 101 PRO`: terminal count; the G9 → G1 transition | GLS doc: G9 → G1 at the T−20 hold |
| −0:22:25.9 | 12:34:01.9 | GROUND | `gmtlo`: GMT of liftoff **136/12:56:25**, so that T−0 falls at 12:56:27.8.  PASS accepted it. | LPS command 9 (lpsmodel.c); GSRRSL.hal (CGSV_T_SSME_ST −3.8 s, CGSV_T_ENG_OK_CK 6.6 s) |
| −0:22:23.9 | 12:34:03.9 | GROUND | `resume` | LPS command 4 |
| −0:04:30 | | PASS | RSLS: IMU platform release; the IMUs go inertial (REFS_RDY) | I-load CGSV_T_IMU_INERT −270 s before GMTLO (GSRRSL.hal:373). The FSSR and GLS give T−240 s. |
| −0:00:34.2 to −0:00:14.4 | | PASS | Vent doors open, groups 2, 5, 3, 1, 6 | |
| −0:00:30.5 | 12:55:57.3 | GROUND | `go_auto`: GO FOR AUTO SEQUENCE (driver: T−31 s).  PASS acts on it from GMTLO − 25 s. | GLS: T−31 s. CGSV_LPS_GO_AUTO_SEQ_TIME |
| −0:00:29.5 | | PASS | LO2 POGO recirc valves PV20/21 OPEN | |
| −0:00:17.8 | | PASS | MEC: T-0 UMBILICAL and SRM IGNITION ARMED | |
| ≈ −0:00:15 | | SIM | Capture `sts134-count` (for re-flying the ascent) | |
| −0:00:10.8 | | PASS | SSME command 6A00 (100%) | |
| −0:00:09.3 | 12:56:18.5 | GROUND | `go_engine`: GO FOR ENGINE START (driver: T−10 s) | GLS |
| −0:00:09.3 | | PASS | SSME 8F00 (start enable) | |
| −0:00:08.3, −0:00:07.3 | | PASS | LH2 prevalves PV4-6 OPEN; LO2 overboard bleed PV19 CLOSED | |
| **−6.56 / −6.44 / −6.32 s** | | PASS | **SSME 3, 2, 1 start.** STS-134: −6.555 / −6.430 / −6.317 s. | JSC 37461 App. A |

### Ascent (PASS, MM 102 → 103 → 104), run `sts134e`

| T | Event | STS-134 actual (JSC 37461; Missions Summary) |
|---|---|---|
| **0.00** | **SRM IGNITION fired; liftoff (hold-down posts released)**, 136/12:56:27.81.  Stack 4,524,353 lb. | 136/12:56:27.994; 4,525,091 lb |
| +0.04 | T-0 umbilical fired | |
| +3.96 | Throttle up to 104.5% | +4.1 |
| ≈ +7 to +20 | Roll program to heads-down | |
| +39.48 | Throttle down for max-q to **72%** (AGT not activated) | 72% at +39.5; AGT not activated |
| +51.32 | Throttle up to 104.5% | +51.3 |
| +57.6 | Max-q, **715 psf** (721 in flight `p11`).  With the day's winds and atmosphere (`w2`, `s1`): **723 psf** at +47.6 | Max-q **733.1 psf** at +60.0 |
| +122.96 | MEC: SRB SEPARATION ARMED (PASS's moding time, cue + 2.23 s; run `s1`) | Both SRMs at 50 psia +119.95 / +120.31; end of action +122.5 / +122.9 |
| **+124.72** | **SRB separation** (cue + 3.94 s; run `s1`.  `sts134e`, with the release's 6 s command delay: +126.40) | **+124.72** (APU loss of signal; Missions Summary: 2:04.8) |
| +126.68 | 106% (K_CMD_STG2, a GG42ND constant) | |
| ≈ +130 to +300 | OMS assist, both engines, 170 s | +134 to +300.5 (164.2 s) |
| +218.84 | 104.5% (K_CMD_NOM) at the guidance parameter reset | |
| ≈ +350 | Roll to heads-up begins (Vi ≈ 13,280 by the time it shows, flight `p12`; V_RHO_PHI on the tape, Vrel 12,000) | crew cue: VI 13.2K |
| +439.64 to +496.60 | 3-g throttling, 100% → 67% | 3-g throttle-down from +440.0; 67% at +494.7 |
| **+502.88** | **MECO command** (guided).  VI **25,821 ft/s** truth (target 25,819); 1,329 kg LO2 and 654 kg LH2 left at ET separation | **MECO +501.1** (Missions Summary: 8:21.5); VI 25,819 (P), 25,818 (A) |
| +516.72 | MEC: ET umbilical unlatch fired | |
| **+524.08** | **ET separation**.  Post-MECO orbit 124.1 × 25.7 nmi osculating above the equatorial radius; PASS's display (J2-mean) 125.3 × 25.1 | ET sep +522; MOD FRR: "insertion altitude 122 nm" |

The truth's velocity budget to ET separation (vehdyn): 30,353 ft/s of thrust,
of it 27,542 along the velocity; drag loss 424 ft/s; gravity loss 2,634 ft/s.

The vehicle crosses the abort-boundary velocities of the checklist's no-comm
table 2-4 s behind STS-134's actual calls (Missions Summary: 2 ENG MRN 2:36,
NEG RETURN 3:54, PRESS TO ATO 4:57, SE PRESS 6:55; run `p10`).

### Against the card

The STS-134 Ascent Checklist's **ASCENT ADI – NOMINAL** cue card (CC 10-11,
ASC-14a/134) gives the nominal pitch, altitude and altitude rate at fixed
times in first stage and fixed inertial velocities in second.  The same card
appears, to about 4,000 ft and 2°, in every OI-34 flight's checklist
(STS-128 to STS-135): it is the standard ISS ascent design.  Run `sts134e`
(altitude is geodetic, on PASS's ellipsoid, as the vehicle logs it):

| | Card θ / H / Ḣ | Simulated H / Ḣ |
|---|---|---|
| T+0:30 | 69° / 10K / 670 | 9.7K / 674 |
| T+0:50 | 62° / 27K / 1,007 | 27.0K / 1,018 |
| T+1:10 | 52° / 51K / 1,441 | 51.8K / 1,497 |
| T+1:30 | 39° / 85K / 1,903 | 86.8K / 1,953 |
| T+1:50 | 30° / 126K / 2,200 | 129.3K / 2,237 |
| Vi 6,000 | 19° / 220K / 1,698 | 237K / 1,610 |
| Vi 8,000 | 14° / 311K / 903 | 319K / 850 |
| Vi 12,000 | 6° / 357K / 56 | 358K / 10 |
| Vi 18,000 | 23° / 344K / −268 | 344K / −245 |
| Vi 24,000 | 17° / 337K / 66 | 335K / 20 |
| MECO, Vi 25,819 | 13° / 345K / 272 | 345K / 310 |

(The pitch flown in `p10`, the same table: 70.1 / 63.3 / 56.1 / 38.9 / 29.3°
at T+30 to T+110.)

### OMS 2 (MM 105), run `sts134e`

The crew's actions are from the STS-134 Ascent Checklist (ASC/134/FIN), pp. 3-3 to 3-7 and the OMS 2 cue cards.

| T | MET | Who | Event |
|---|---|---|---|
| ET sep + 120 s | 0:10:44 | GROUND | Message 25 with the OMS-2 targets designed from the insertion: HT 171.95, θT 344.30° (264.6 ft/s) |
| ET sep + 600 s | 0:18:44 | CREW | `dap c3 auto`, `OPS 105 PRO`, TRIM LOAD `ITEM 6 +0.4 −5.7 +5.7 EXEC`, LOAD `ITEM 22`, TIMER `ITEM 23`, MNVR `ITEM 27 EXEC` |
| — | — | SIM | OMS engines ARM/PRESS (`YAGPC_OMS_ARMED=1`; the checklist's TIG−2 switch) |
| +2,272.1 | 0:37:52 | CREW | `EXEC` at TIG−8 s |
| **+2,280.1** | **0:38:00** | PASS | **OMS 2 ignition** (TIG = ET separation + 1,756 s), about 164 s.  STS-134: ignition MET 0:37:58, 168.6 s, 259.2 ft/s. |

### Result: the orbit after OMS 2

| | Simulated (truth) | STS-134 |
|---|---|---|
| Just after the burn (osculating) | **172.5 × 121.4 nmi** above the equatorial radius = **176.4 × 125.2** above the 6,371 km mean radius | **175.8 × 124.3 nmi** (JSC 37461) |
| PASS's display (J2-mean, GZIASC) | 166.1 × 120.9 | |
| One-orbit average (1,090 samples over 5,450 s) | 166.4 × 121.0 osculating above the equatorial radius (170.2 × 124.8 above the mean radius); inclination **51.63°** | |
| Plane | Ascending node within ±0.05° of the ISS's (Space-Track TLE, regressed), inclination 51.63-51.65° against the TLE's mean 51.648° | the ISS's |
| OMS-2 burn | 264.6 ft/s | 259.2 ft/s |

Osculating apsides move about ±5.5 nmi around an orbit (J2).

### Cross-check: STS-135 with the same model

STS-135 was flown with the model built for STS-134 (`fly_sts134.py --flight
sts135-flight.json`, run `sts135b`), changing only what the documents give
for that flight: its masses, its motors' 50 psia time, its SSME Isp (451.78
s), its throttle times, OMS assist (83.2 s) and OMS-2 targets, and a plane
through the pad at its in-plane time.

| | Simulated | STS-135 (its mission report; Missions Summary) |
|---|---|---|
| Stack at SRB ignition | 4,520,355 lb | 4,521,103 less the 740 → 4,520,363 |
| Throttle down / up | +38.48 / +57.36 | +38.72 / +56.80 |
| Max-q | 721 psf | 734 (745 planned) |
| SRB separation | +124.9 (the release's 6 s command delay) | +123.0 (2:03.0) |
| 3-g throttling | +442.0 | +442.09 |
| MECO | +504.4, VI 25,812 | +503.8 (8:23.8), VI 25,817 |
| ET separation | +525.6 | +525 |
| After OMS 2 | 123.3 × 86.0 nmi (mean radius) | 123.9 × 85.2 |
| OMS-2 burn (cheapest design from the insertion) | 119.5 ft/s | 97.0 |

The differences common to both flights were the model's, not one flight's
tuning: SRB separation ~1.7-1.9 s late, since traced to the tape's
separation I-loads (now fixed for STS-134), and max-q ~2% low.  `sts135b`
had neither the separation I-loads nor its day's weather.  **Before STS-135
is flown again** it needs its own Cape sounding (74794, 2011-07-08 12Z) as
the truth, a message 11 wind table made from it, and the separation cells
in its reconfiguration; then the pitch table re-shaped and QPOLY/TREF
re-read with that wind.

### How the model got here

Run `sts134c`, the first full flight, used synthesized stack aerodynamics,
the pre-Challenger HPM booster trace, PASS's nominal Isp, the tank's capacity
loads and the 1976 standard atmosphere, with the pitch table scaled to make
MECO; its max-q was 949 psf.  Changed since, each from a document:

| Change | Source | Commit |
|---|---|---|
| Stack aerodynamics: forebody CA and power-on base drag on Mach, CN = CNα (α − α₀) | IA156 (ADDB Vol II, SD72-SH-0060-2K) as plotted in the STS-1 OFP fig. 6.2-1 | 7b2c9a80e |
| RSRM thrust trace, its tail-off timed to STS-134's 50 psia, chamber pressure per pound of thrust falling to 50 psia at 200,000 lbf | JSC-19041 Fig 4.3-I; JSC 37461 App. A; Booster Console Handbook | 624a328ab, 3ae9c5c3f |
| 52 nmi MECO, the pseudo MECO radius with it | Missions Summary; CGGC01 | 624a328ab, 7190ce67d |
| SSME Isp 452.07 s | JSC 37461 | 26ffacd6b |
| Masses at SRB ignition; the pad burn drawn from the ET | Missions Summary App. A | e1d4f2b21 |
| Pitch table to the ADI nominal card; no second-stage lofting | ASC-14a/134; FSSR §4.8 | 63608afdb, a34c5a538 |
| The 1963 Patrick AFB reference atmosphere below 66 km | STS-1 OFP §5.3; JSC-08964 App. A | e82d94d21 |
| OMS-2 targets in the reports' mean-radius convention, cheapest burn | omstarget; JSC 37461 | 0de0adbab, cd05369b3 |
| The day's atmosphere and wind: the truth flies the Cape sounding at launch (12Z and 15Z interpolated to 12:56Z), PASS the 12Z winds as DOLILU message 11 | Cape Canaveral station 74794 soundings, University of Wyoming archive; JSC 37461 | 60ceb8368, eaaba5cc0 |
| SRB separation I-loads: command delay 4.42 s and five more | Booster Console Handbook Table 2.2.1-I; mission reports App. A | d63cfcfd2 |

## Derived data and how it was obtained

| Data | How | Where |
|---|---|---|
| Plane normal IYD | The 51.6° plane through the nav base at the inertial azimuth asin(cos i / cos φc) = 44.95°, as IY = d × r̂ in PASS's Earth-fixed frame | Checked on the tape's 38° I-load: (0.5073, −0.3488, −0.7880) against the tape's (0.5172, −0.3339, −0.7880) |
| Yaw/roll tables | The tape's tables turned by the azimuth difference (63.66° → 44.95°), then a further −10° found by flight on the out-of-plane error and MECO margin | GG31ST.hal step 16 |
| Pitch table | Corrected by flight, point by point in Vrel, toward the card's pitch, altitude and climb rate at T+30-110 (four iterations; THET maps nonlinearly to the flown pitch through the yaw turn and load relief) | ASC-14a/134 |
| QPOLY, TREF | QPOLY: the simulated vehicle's Vrel at the report's throttle times. TREF: its time to 488 ft/s plus guidance's detection lag (about 0.3 s), read back from PASS's CGGV_TDEL_ADJUST with `pasvar` | JSC 37461 App. A; GG31ST |
| MECO radius | a + 52 nmi, with a and the convention from the tape's own RD_NOM (a + 60.02 nmi) | Missions Summary |
| OMS 2 HT, θT | `omstarget.py`: PASS's PEG 4 target geometry (GGOTGT) and linear-terminal-velocity constraint (GGILTV), ported; the cheapest (HT, θT) that reaches the target apsides at the fixed TIG.  In flight, `fromlog` takes the truth after ET separation and coasts it to TIG. | |
| Apsis conventions | The reports' orbits are heights above a spherical Earth of 6,371 km, 3.854 nmi below the equatorial radius: read against the equatorial radius, STS-134's 124.3 nmi perigee is unreachable from its ~122-125 nmi insertion apogee, and converted it designs to 262-265 ft/s against the 259.2 flown.  PASS's own displayed HA/HP (GZIASC) are J2-mean heights above the equatorial radius 3,443.934 nmi. | GZIASC.hal; JSC 37461 |
| Atmosphere and wind | **The day's**: the Cape Canaveral sounding (station 74794) nearest launch, by default 12Z and 15Z of 2011-05-16 interpolated to 12:56Z (`YAGPC_VEHDYN_SOUNDING`, set by `fly_sts134.py`; 85 levels to 24 km): pressure, geopotential height made geometric, temperature made virtual from the mixing ratio, and the wind, subtracted from the vehicle's Earth-relative velocity along local east and north.  Above the sounding, and without one, the 1963 Patrick AFB reference atmosphere, pressure and density at 55 altitudes 0-66 km read from JSC-08964's tables, temperature p/ρR, no wind; the 1976 standard above that (and with `YAGPC_VEHDYN_ATMOS=us1976`).  Between 12Z and 15Z the westerly at 10-12 km strengthened 7-11 m/s, JSC 37461's "late predicted change in the wind"; density changed < 1%, and the 12Z and 12:56Z truths fly within ~2,000 ft of each other. | Wyoming archive; JSC-08964 App. A |
| Gimbal pitch sense | −1 for SSMEs and SRBs. With +1 the loop diverged at liftoff. | vehdyn.c |
| AA normal axis | Positive up (−Z) | GDRENT.hal:107 (LOAD = AA_NORM × g0); NZREF table (CGCUN1.hal) |
| Stack aerodynamics | IA156 wind-tunnel data, digitized from the STS-1 OFP's plots of its nominal ascent: forebody CA and base drag (as a coefficient on the OFP's q) on Mach; CN = CNα (α − α₀), the slope measured below Mach 0.4 and assumed above, α₀ fitted to every OFP point.  Run `sts134c` flew synthesized tables. | JSC-14483 Vol 3 fig. 6.2-1; vehdyn.c |
| SSME tail-off | 0.958 s at full thrust | PASS's own CGGS_T_TAILOFF (GG42ND step 87) |
| SSME Isp | 452.07 s; the controller holds thrust, so flow = thrust / Isp.  Run `sts134c` flew 455.2. | JSC 37461 |
| SRB thrust | RSRM population nominal at 60 °F, digitized (its integral is the propellant at Isp 266 s to 0.1%), run 0.74% fast so that it reaches 50 psia at STS-134's T+120.13 (`YAGPC_VEHDYN_SRB_PC50_S` for another flight).  Run `sts134c` flew SODB Fig 6.3.1-2, the pre-Challenger HPM. | JSC-19041 SRB Overview Fig 4.3-I; JSC 37461 App. A |
| SRB chamber-pressure words | 914 psia at the 3.312 Mlbf peak, falling linearly to 50 psia at 200,000 lbf at the end of the burn, through PASS's calibration | Booster Console Handbook; GPXSRB.hal; GSESRB.hal |
| Per-flight vehicle values | ET weight and fuel bias, SRB weight, the SRMs' 50 psia time, SSME Isp: STS-134's by default, `YAGPC_VEHDYN_ET_LB`, `_FUEL_BIAS_LB`, `_SRB_LB`, `_SRB_PC50_S`, `_SSME_ISP` otherwise | vehdyn.c |

## Known differences from STS-134

- **SRB separation: resolved.**  It was ~1.7 s late (+126.4 against
  +124.7), and STS-135's ~1.9 s, because the tape carried GSESRB's
  generic-release separation timings instead of the flight's I-loads; with
  them it is +124.72 against +124.72 (run `s1`).  No sensor offset was
  needed.
- **Max-q is ~1.4% low** with the day's winds and atmosphere (723 psf
  against 733.1; 715-721 with the Patrick atmosphere and no wind).
  STS-135's (721 against 734) was flown without its day's weather.
- **The OMS-2 burn is 2% (STS-134) to 20% (STS-135) dearer** than flown, from
  insertion apogees a few nmi low; STS-135's MECO was 5 ft/s low.
- **No second-stage lofting** (TFAIL 0) is chosen to fit the card; STS-134's
  value is not published.
- **The first stage ends out of the final plane**, which second stage steers
  out.  The yaw table was tuned for best MECO margin, not zero plane error.
- **The pre-launch timetable is compressed into 85 minutes.** The real one
  spanned the day before launch (S0007: IMU power-up at L-27h30m; OPERATE and
  ATT DET by L-8h20m; gyrocompass about 42 min).
- **The crew's post-MECO procedures are abridged to what the flight needs.**
  Omitted: MPS dump, APU shutdown, ET umbilical doors.
- **MECO flight-path angle** 0.65° is chosen, not sourced; the card's MECO
  climb rate is 272 ft/s against our 310.
- **PASS's winds are the 12Z balloon's**, as an uplink built before launch
  would be; the truth flies the air at launch.  The ground's own DOLILU
  winds (Jimsphere, the 50 MHz profiler) are not available.
- **A one-GPC session save once froze the vehicle** after its capture
  (gpc-causes #276); the flight resumed from that capture.

## References

All are in the local ibiblio mirror (`~/Desktop/sandroid.org/public_html/apollo/Shuttle/`) unless marked otherwise.

- **JSC 37461, STS-134 Space Shuttle Mission Report** (Sept 2011): `Reports/Mission Reports/STS-134 Space Shuttle Mission Report.pdf`. Launch time, Appendix A event times, SSME throttle profile and Isp, OMS assist, MECO and ET separation, OMS 2 (TIG, 168.6 s, 259.2 ft/s, 124.3 × 175.8 nmi).
- **STS-134 Ascent Checklist** (ASC/134/FIN): `Ascent Checklists/STS-134 Ascent Checklist.pdf`. MECO VI 25,819; post-OMS-1 and OMS 2 procedures (OPS 105, TRIM LOAD, LOAD, TIMER, MNVR, EXEC); the ASCENT ADI – NOMINAL card (CC 10-11, pdf p201); the no-comm abort-boundary velocities; throttle cues .83M / 1.19M; "Pc < 50 + 5 s √SRB SEP".  The same card is in the STS-128 to STS-135 checklists.
- **STS-135 Space Shuttle Mission Report**: `Reports/Mission Reports/STS-135 Space Shuttle Mission Report.pdf`. The cross-check flight's events, Isp, OMS assist and OMS 2.
- **STS-134 MOD FRR, Flight Design and Dynamics** (Mar 2011): `FRR/FDD/STS-134 FRR FDD.pdf`. Insertion 122 nm / 51.6°, DOLILU II, 170 s OMS assist, ascent performance margins (I-load design 1,566 lb, projected 1,107 lb).
- **Space Shuttle Missions Summary** (NASA 20110001406, `20110001406.pdf`, pdf pp. 258-263, STS-134; pp. 264-266, STS-135; App. A pp. 280-281, flight weights): max-q 733.5 (P) / 733.1 (A) psf; SRB staging 2:04.8; MECO command 8:21.5; VI 25,819 (P) / 25,818 (A); throttle 104.5/72/104.5; FPR 2,821 lb, fuel bias 954 lb; performance enhancements operational high-q, OMS assist, a 52 nmi MECO, Del Psi; post-OMS-2 predicted 175.9 × 124.7. (Its "4,365,726 LBS" is accumulated program cargo, not a liftoff weight.)
- **JSC-19041 SRB Overview** (Rev F, 2003): `Reference/SRB Overview.pdf`, Fig 4.3-I, the RSRM nominal thrust trace.
- **Booster Console Handbook**: `MCC/Booster Console Handbook.pdf`. "At 50 psia, an SRB may produce approximately 200,000 lbs of thrust"; the separation cue logic; SCP 2.2.1 Table 2.2.1-I, the SRB separation I-loads.
- **Mission reports, Appendix A** (`Reports/Mission Reports/`, STS-33 to STS-135): "Both SRMs at 50 psi" and "SRB Physical Separation", for the separation delay by era.
- **JSC-08964, Cubic spline function interpolation in atmosphere models for the SDL** (Kirkpatrick): App. A, the 1963 Patrick AFB reference atmosphere tables.
- **JSC-14483 (78-FM-51) Vol 3, STS-1 Operational Flight Profile, Ascent, Cycle 3**: Table 6.2-I, SRB separation state; §5.2 and fig. 6.2-1, the IA156 aerodynamics along its nominal ascent.
- **STS 83-0002-34, GN&C FSSR, Guidance Ascent/RTLS**: §4.2 DOLILU parameters and uplinks (Table 4.2-1), Table 4.3.5-3 second-stage I-loads (V_RHO_PHI, PHI_2STG), §4.12 uplink memory groups, §4.8 PEG and trajectory lofting (TFAIL, T_RTLS_AOA), §4.12 I-load memory layout.
- **STS 83-0013-34, IMU SOP FSSR**: OPERATE runup, discretes.
- **S0007 Vols 1-2 (OMI) and the GLS document** (`Countdown/`): the real countdown's IMU and G9 → G1 schedule.
- **DPS Console Handbook; DPS Dictionary Rev J**: BITE 4 output read-back at OPS transitions.
- **SODB (JSC-08934 Vol 1, Rev E)**: stack geometry; SRB Isp.  Its Fig 6.3.1-2 is the pre-Challenger HPM's thrust, not the RSRM's.
- **PASS OI-34 flight source** (`~/workspace/PFS/OI340600/`): GZIASC (displayed HA/HP), GGQCOM (lofting), GSRRSL (RSLS), GMESTA (OPS 9 uplink), GUCIMU / GMXGCA / GMESTA (IMU), VG9OPS9 / GO1ASC / FIOGNIPG (OPS transitions), GG31ST / GG42ND (first and second stage), GGOTGT / GGILTV (PEG 4), GZMASC (OMS targeting), CGGCOM / CGGC01 / CGGC13 (I-loads), GPXSRB / GSESRB (SRB separation), CGCUN1 (DAP I-loads), GDRENT (AA sign).
- **Not in the mirror:**
  - SLWT inert 58,500 lb (SCOM figure, as quoted by Wikipedia's Space Shuttle external tank article).
  - The commonly cited ascent drag loss of about 107 m/s.
  - Space-Track: ISS TLEs for 2011 days 135-136 (supplied by the user).
  - University of Wyoming upper-air archive: Cape Canaveral (74794) soundings, 2011-05-16 12Z and 15Z (`weather.uwyo.edu`; saved as `discretePanel/examples/flights/sts134-sounding-74794-*.csv`).
