# STS-134 launch to orbit: the simulated timeline

This is the flight being flown in yaGPC2: one GPC running PASS OI-34 (tape
`OI340700-v44boot` with STS-134's OPS 1 overlay I-loads), from IPL on LC-39A
to the orbit after OMS 2 and on to OPS 201.

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
| The baseline: IPL to the orbit after OMS 2 | Run **`sts134f`** (scratch-2026-10-03), from IPL on the current tape (every reconfiguration cell, the separation I-loads included) with the day's weather | Shown first wherever it measured the event.  It logs the state only every 5 s after first stage, and not the throttle commands, so rows it has no number for are `sts134e`'s. |
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

### Ascent (PASS, MM 102 → 103 → 104), runs `sts134f` and `sts134e`

| T | Event | STS-134 actual (JSC 37461; Missions Summary) |
|---|---|---|
| **0.00** | **SRM IGNITION fired; liftoff (hold-down posts released)**, 136/12:56:27.81.  Stack 4,524,353 lb. | 136/12:56:27.994; 4,525,091 lb |
| +0.04 | T-0 umbilical fired | |
| +3.96 | Throttle up to 104.5% | +4.1 |
| ≈ +7 to +20 | Roll program to heads-down | |
| +39.48 | Throttle down for max-q to **72%** (AGT not activated) | 72% at +39.5; AGT not activated |
| +51.32 | Throttle up to 104.5% | +51.3 |
| +56.4 | Max-q, **698 psf** (`sts134f`, the day's winds and atmosphere; `w2` and `s1` 697 at +56.6).  `sts134e`, the Patrick atmosphere and no wind: 715 psf at +57.6 | Max-q **733.1 psf** at +60.0 |
| +123.08 | MEC: SRB SEPARATION ARMED (PASS's moding time, cue + 2.23 s; `sts134f`; `s1` +122.96) | Both SRMs at 50 psia +119.95 / +120.31; end of action +122.5 / +122.9 |
| **+124.84** | **SRB separation** (cue + 3.94 s; `sts134f`; `s1` +124.72.  `sts134e`, with the release's 6 s command delay: +126.40) | **+124.72** (APU loss of signal; Missions Summary: 2:04.8) |
| +126.68 | 106% (K_CMD_STG2, a GG42ND constant) | |
| ≈ +130 to +300 | OMS assist, both engines, 170 s | +134 to +300.5 (164.2 s) |
| +218.84 | 104.5% (K_CMD_NOM) at the guidance parameter reset | |
| ≈ +350 | Roll to heads-up begins (Vi ≈ 13,280 by the time it shows, flight `p12`; V_RHO_PHI on the tape, Vrel 12,000) | crew cue: VI 13.2K |
| +439.64 to +496.60 | 3-g throttling, 100% → 67% | 3-g throttle-down from +440.0; 67% at +494.7 |
| **≈ +502.8** | **MECO command** (guided; ET separation less PASS's 21.2 s).  VI **25,819 ft/s** truth (target 25,819), at about 343,000 ft; 1,420 kg LO2 and 669 kg LH2 left at ET separation (`sts134f`.  `sts134e`: +502.88, 25,821, 1,329 / 654 kg) | **MECO +501.1** (Missions Summary: 8:21.5); VI 25,819 (P), 25,818 (A) |
| +516.72 | MEC: ET umbilical unlatch fired | |
| **+523.96** | **ET separation** (`sts134f`; `sts134e` +524.08).  Post-MECO orbit 120.9 × 25.9 nmi osculating above the equatorial radius (`sts134e` 124.1 × 25.7; PASS's display, J2-mean, 125.3 × 25.1) | ET sep +522; MOD FRR: "insertion altitude 122 nm" |

**A flight by the owner, run `ascent2` (2026-10-12).**  Restored from the
T-5 minute capture with the **170 s** OMS assist (the 165.4 s the flight used
is in the later `count165c` capture), on the model after the APU and OMS load
changes.  Times are PASS's command-accepted instants, from
`tools/missionaudit.py` on the run's `yaGPC2.log`; T is SRB ignition and the
flown column is JSC 37461 Appendix A:

| Event | `ascent2` | Flown |
|---|---|---|
| SSME 3 / 2 / 1 start | −6.6 / −6.4 / −6.3 | the same |
| Throttle up to 104.5% | +3.8 | +4.1 |
| Throttle down to 72% | +39.0 | +39.5 |
| Throttle up to 104.5% | +51.0 | +51.3 |
| SRB separation command | +125.1 | +125.0 |
| 3-g throttle-down | +442.2 | +440.0 |
| Throttle to 67% | +503.9 | +494.7 |
| SSME shutdown, MECO command | +504.0 | +501.0 |
| ET separation command | +525.2 | +522.0 |

Its MECO and ET separation are about 1.2 s later than the `sts134f` rows
above (+502.8, +523.96), likely the 170 s assist and the mass-model changes
since; the rows above are left as they are until a flight from the 165.4 s
capture is measured.  Max-q, the SRB arming time, OMS 2 and the orbit are not
read from this run (no vehicle trace in its log).  The flown OMS 2 ignition
is MET 0:36:57 (2,217.4 s), burn 168.6 s.

The run raised one SM alert tone (PASS's alert-tone bit, panel t=127.6 s,
136/12:52:15) and no backup C&W alarm: the C&W unit's own sensor channels are
not simulated, so a nominal ascent is nearly silent.

The truth's velocity budget to ET separation (vehdyn, `sts134f`): 30,356 ft/s
of thrust, of it 27,500 along the velocity; drag loss 377 ft/s; gravity loss
2,641 ft/s (`sts134e`: 30,353, 27,542, 424, 2,634).

The vehicle crosses the abort-boundary velocities of the checklist's no-comm
table 2-4 s behind STS-134's actual calls (Missions Summary: 2 ENG MRN 2:36,
NEG RETURN 3:54, PRESS TO ATO 4:57, SE PRESS 6:55; run `p10`).

### Against the card

The STS-134 Ascent Checklist's **ASCENT ADI – NOMINAL** cue card (CC 10-11,
ASC-14a/134) gives the nominal pitch, altitude and altitude rate at fixed
times in first stage and fixed inertial velocities in second.  The same card
appears, to about 4,000 ft and 2°, in every OI-34 flight's checklist
(STS-128 to STS-135): it is the standard ISS ascent design.  Altitude above
the ellipsoid; the second stage at the first sample at or past each velocity
(`sts134f` samples every 5 s there):

| | Card θ / H / Ḣ | `sts134f` H / Ḣ (day's weather) | `sts134e` H / Ḣ (no wind) |
|---|---|---|---|
| T+0:30 | 69° / 10K / 670 | 9.7K / 684 | 9.7K / 674 |
| T+0:50 | 62° / 27K / 1,007 | 27.2K / 1,028 | 27.0K / 1,018 |
| T+1:10 | 52° / 51K / 1,441 | 52.4K / 1,528 | 51.8K / 1,497 |
| T+1:30 | 39° / 85K / 1,903 | 88.2K / 1,985 | 86.8K / 1,953 |
| T+1:50 | 30° / 126K / 2,200 | 131.3K / 2,258 | 129.3K / 2,237 |
| Vi 6,000 | 19° / 220K / 1,698 | 248.4K / 1,571 | 237K / 1,610 |
| Vi 8,000 | 14° / 311K / 903 | 326.3K / 817 | 319K / 850 |
| Vi 12,000 | 6° / 357K / 56 | 362.7K / −30 | 358K / 10 |
| Vi 18,000 | 23° / 344K / −268 | 347.7K / −283 | 344K / −245 |
| Vi 24,000 | 17° / 337K / 66 | 339.0K / 66 | 335K / 20 |
| MECO, Vi 25,819 | 13° / 345K / 272 | ≈343K | 348K / 319 |

With the day's weather the first stage ends higher and the second stage climbs
well above the card (+28,000 ft at Vi 6,000), coming back to it by MECO.  The
pitch table and QPOLY/TREF were shaped on flights with no wind.  The MECO
altitude follows PEG's radius error at cutoff, a few thousand feet either side
of RD_NOM: at 37° latitude a cutoff exactly on RD_NOM reads about 341K above
the ellipsoid, so the card's 345K is about 3,600 ft above it.  `sts134e`'s
MECO row earlier read 345K / 310, from a sample of the coast after cutoff.

(The pitch flown in `p10`, the same table: 70.1 / 63.3 / 56.1 / 38.9 / 29.3°
at T+30 to T+110.)

### OMS 2 (MM 105), run `sts134e` (`sts134f` the same procedure)

The crew's actions are from the STS-134 Ascent Checklist (ASC/134/FIN), pp. 3-3 to 3-7 and the OMS 2 cue cards.

| T | MET | Who | Event |
|---|---|---|---|
| ET sep + 120 s | 0:10:44 | GROUND | Message 25 with the OMS-2 targets designed from the insertion: HT 171.95, θT 344.30° (264.6 ft/s).  `sts134f`: HT 171.95, θT 320.91° (263.3 ft/s) |
| ET sep + 600 s | 0:18:44 | CREW | `dap c3 auto`, `OPS 105 PRO`, TRIM LOAD `ITEM 6 +0.4 −5.7 +5.7 EXEC`, LOAD `ITEM 22`, TIMER `ITEM 23`, MNVR `ITEM 27 EXEC` |
| — | — | SIM | OMS engines ARM/PRESS (`YAGPC_OMS_ARMED=1`; the checklist's TIG−2 switch) |
| +2,272.1 | 0:37:52 | CREW | `EXEC` at TIG−8 s |
| **+2,280.1** | **0:38:00** | PASS | **OMS 2 ignition** (TIG = ET separation + 1,756 s), about 164 s.  STS-134: ignition 136/13:33:25.4 = MET 0:36:57 (JSC 37461 Appendix A; this row read 0:37:58 before), 168.6 s, 259.2 ft/s. |

Since the row above, the flight has not flown OMS 1 (the Mission Report: "Not
Required") and the driver's OMS-2 TIG is ET separation + 1,695 s, ignition at
+2,220 (0:37:00), 2.6 s after the flown one: see "The owner's flight to OPS
201" below.

### Result: the orbit after OMS 2

| | Simulated (truth) | STS-134 |
|---|---|---|
| Just after the burn (osculating), `sts134f` | **172.1 × 120.7 nmi** above the equatorial radius = **176.0 × 124.6** above the 6,371 km mean radius | **175.8 × 124.3 nmi** (JSC 37461) |
| One-orbit average, `sts134f` (1,149 samples over 5,740 s) | 166.0 × 120.5 above the equatorial radius (169.9 × 124.3 above the mean radius); inclination 51.63-51.67° | |
| OMS-2 burn, `sts134f` | 263.3 ft/s | 259.2 ft/s |
| Just after the burn, `sts134e` | 172.5 × 121.4 nmi above the equatorial radius = 176.4 × 125.2 above the mean radius | |
| PASS's display (J2-mean, GZIASC) | 166.1 × 120.9 | |
| One-orbit average (1,090 samples over 5,450 s) | 166.4 × 121.0 osculating above the equatorial radius (170.2 × 124.8 above the mean radius); inclination **51.63°** | |
| Plane | Ascending node within ±0.05° of the ISS's (Space-Track TLE, regressed), inclination 51.63-51.65° against the TLE's mean 51.648° | the ISS's |
| OMS-2 burn | 264.6 ft/s | 259.2 ft/s |

Osculating apsides move about ±5.5 nmi around an orbit (J2).

### The owner's flight to OPS 201 (run `ascent2`, 2026-10-12)

The simulated flight did not stop at OMS 2: the owner's run continued through
the post-insertion transitions to OPS 201 (ORBIT), 53 minutes after liftoff.
Times are from the panel's script log and the truth log against the vehicle
clock (T = SRB ignition; ±2 s, since the panel's clock is mapped to the
vehicle's through ET separation).  The crew's actions are from the Ascent
Checklist (ASC/134/FIN) FB 2-5 and 3-3 to 3-7 and the POST INSERTION
procedures.

| T | MET | GMT 136/ | Who | Event |
|---|---|---|---|---|
| +525.3 | 0:08:45 | 13:05:13 | CREW | MSG RESET after ET separation |
| +527.3 | 0:08:47 | 13:05:15 | CREW | ORBIT PFD on CRT 2 (`edgekey crt2 3`) |
| +549.9 | 0:09:10 | 13:05:38 | CREW | **OMS 1 not required** (the Mission Report: "Not Required"): OMS ENG LEFT and RIGHT to OFF, then on to POST OMS 1 (checklist FB 2-5) |
| +1,131 | 0:18:51 | 13:15:19 | CREW | `OPS 105 PRO` after `dap c3 auto` and the OMS ENG ARM/PRESS (the OMS 2 setup, ASC 3-3 to 3-7) |
| +2,210 | 0:36:50 | 13:33:18 | CREW | `EXEC` at TIG − 8 s |
| **≈ +2,220** | **0:37:00** | **13:33:28** | PASS | **OMS 2 ignition**: TIG = ET separation + 1,695 s (OMS 1 not flown, so no delay for it).  STS-134: MET 0:36:57, GMT 13:33:25.4 |
| ≈ +2,401 | 0:40:01 | 13:36:29 | PASS | OMS 2 cutoff, a burn of about 181 s against the flown 168.6 s (136/13:33:25.4 to 13:36:14.1).  The propellant used was 7,040 lb. |
| +2,518 | 0:41:58 | 13:38:26 | CREW | OMS ENG LEFT and RIGHT to OFF |
| +2,523 | 0:42:03 | 13:38:31 | CREW | `OPS 106 PRO`: the post-insertion major mode |
| +2,998 | 0:49:58 | 13:46:26 | CREW | `SPEC 0 PRO`, then GPC MEMORY: `ITEM 1 +2` (configuration 2, GN&C), GPC 1 for the strings and buses, and every item to its OPS 2 setting, about 8 s apart |
| +3,158 | 0:52:38 | 13:49:06 | CREW | `OPS 201 PRO`: ORBIT |
| +3,177 | 0:52:57 | 13:49:25 | PASS | The panel set changes from GNC OPS 1 to GNC OPS 2 (A7L added) |
| +3,215 | 0:53:35 | 13:50:03 | SIM | Capture `sts134-ops2` (the start of the orbital phase) |

OMS 2's orbit in this run, from the truth state (osculating apsides of the
vehicle, above the equatorial radius and above the mean radius of 6,371 km):

| | Above the equatorial radius | Above the mean radius | STS-134 |
|---|---|---|---|
| ET separation, T+526 | 124.1 × 27.7 nmi | 128.0 × 31.6 | |
| Just before OMS 2 | 126.4 × 32.2 | 130.2 × 36.1 | |
| Just after OMS 2 (T+2,411) | 171.6 × 121.7 | **175.5 × 125.6** | 175.8 × 124.3 |
| At OPS 201 (T+3,200) | 164.2 × 120.7 | 168.1 × 124.6 | |

The apogee is 0.3 nmi low and the perigee 1.3 nmi high, with a burn 12.8 s
(7.6%) longer than flown: the OMS 2 differences listed under "Known
differences".

### Beyond the simulated flight: what STS-134 did next

The simulation ends at OPS 201; none of the following is in the driver's
scripts, though STS-134 did them (JSC 37461 Appendix A; times from SRB ignition):

| T | MET | Event |
|---|---|---|
| +844.6, +858.9, +871.1 | 0:14:05, 0:14:19, 0:14:31 | APU 1, 2, 3 deactivated (the gas generator chamber pressure falls) |
| +5,322.0, +5,403.0 | 1:28:42, 1:30:03 | Payload bay doors open, right then left |
| +10,337.1 to +10,397.3 | 2:52:17 to 2:53:17 | OMS 3 |
| +62,783.7 to +62,798.3 | 17:26:24 to 17:26:38 | OMS 4 (right engine only) |
| +148,259.5 to +148,270.5 | 41:11:00 to 41:11:10 | OMS 5 |
| +153,705.1 to +153,716.3 | 42:41:45 to 42:41:56 | OMS 6 |
| +161,033 | 44:43:53 | Docking: capture, to the ISS |

The rendezvous from the OMS-2 orbit to capture is `RENDEZVOUS_PLAN.md`
sections 5 to 5n, and the return is `TIMELINE-STS134-ENTRY.md`.

### Pre-ISS coast (NC1 to NC4, flight day 13): why the residuals exploded, and the fixes (2026-11-03 to 11-05)

Applied from the staging log (Full Documentation Sync, 2026-11-05).  The stage is flown by `fly_fd13.py`; the ledger entries are #321 to #327 in `gpc-causes.db`, and the per-platform results are in `PHASES.md`.

- **The symptom.**  NC1 and NC2 closed to a predicted miss of 15 ft and 5 ft, but the state at NC4 ended 13 to 41 kft and 12 to 39 ft/s from the design at the old 06:10 UTC aim.  Along-track error is about 3 x dv x t: about 16 kft per ft/s over the 88 min from NC4 to Ti, and about 150 kft per ft/s over the 14.4 h coast from NC3 to NC4.
- **Causes found and fixed.**
  - The NC3 RCS impulse centroid was taken as a fixed 102 s; for a 2.4 to 4 ft/s burn it is 10 to 28 s (#321).
  - The driver stayed in OPS 202 after each burn, where PASS refuses GPS TO NAV AUTO, so navigation drifted (#323).  The receivers added 11 leap seconds against the flown 15, so PASS rejected the fixes (#322; environment `YAGPC_GPS_LEAP_SEC`).
  - Attitude-hold RCS jet delta-V in the coast, about 100 pulses, 0.44 to 0.63 ft/s per coast and different in every run (#325).
  - The NC4 solve aimed at 06:10 although the next target is Ti (07:38 UTC).  NC4 now aims at the design state at Ti (position error/100 m plus velocity error/0.5 m/s).
  - An NC4 execution error of about 1 ft/s, from the burn-attitude maneuver and the steering jets (about 10.5 kg of RCS propellant in 190 s).  A small NC3-style RCS trim, "NC4T", about 20 min after the 06:10 sample and aimed at Ti, closes it.
- **Refuted; do not retest.**  The NC1 "1 degree pointing offset" was an analysis artifact: I had taken the frame at EXEC, 15 s before TIG, and the frame turns 0.97 degrees in that time; at TIG the angle is 0.01 to 0.03 degrees (#324).  Also refuted: a vernier hold in the coast (#326), a finer DAP B pulse trim (#327), DAP FREE as a fix, the attitude quaternion choice, the Earth angle, the gravity degree, a constant inertial acceleration, and a position-only Ti aim.  The planner's physics is correct: with the jets off the coast holds to 552 ft over 14 h.
- **Results at Ti, gate 5 kft and 5 ft/s** (build `fd13-codex-5`, `ac4aa874`): Linux 356 ft / 1.87 ft/s (FIX9) and 1272 ft / 4.38 ft/s (FIX10, 13.2 kft / 16.5 ft/s before the trim); Mac 1334 ft / 3.47 ft/s (resumed from `coast-086` after a power loss; 1229 ft / 3.23 ft/s before the trim, so the trim added error there).  The trim is about 0.9 ft/s, which is the level below which PASS treats sensed RCS delta-V as hold noise.  Under the old 06:10 aim the platforms ended at 24.1 kft (Linux), 11.4 (Win11), 17.8 (WSL) and 5.1 (Mac).  WSL and Win11 were lost to a host power loss on 2026-11-05 at 08:57 and are being resumed from NC3.

### After docking: undocking, the STORRM re-rendezvous and the night landing (reference, not simulated)

- Reference only (owner, 2026-10-16: NOT current work).  Owner's decisions: the ISS stay is uninteresting for the PASS emulation; undocking/flyaround/separation is a demo video in its own right, run by itself (no timeline problem); the night landing (below) is welcome because it differs from the RTLS video.  Current work stays: fix the ISS approach and hard-dock at about the Mission Report's time.
- Mission Report (FD15-17), GMT: Orbiter DAP resumes attitude control 150/02:35:28; maneuver to undocking attitude 02:46:28-03:18:31; FREE drift 03:52:28; hook drive 03:53:08 (~2 min 7 s); flyaround start (+X pulses L1A/R1A) 04:20; Ku RADAR 04:49:20 (lock ~600 ft); SEP1 05:06:02 (6.48 s +X); SEP2 05:34:06 (5.2 s); STORRM re-rendezvous: NH2 06:39:38, MC5 06:59:08, NSR 07:24:08, TPI 07:57:34, closest approach 955 ft CG-CG 08:24:25 (TDA not required), SEP3 08:38:36; FCS checkout 151/02:24:36; RCS hot-fire 151/03:30:57; deorbit burn 152/05:29:03 (orbit 248, dual-engine, 158.3 s, 298.4 ft/s, resulting orbit 23.2 x 188.5 nmi); EI 152/06:03:06; KSC runway 15 main gear 152/06:34:50 (2011-06-01, about 02:35 EDT = NIGHT landing), nose gear 06:35:00, wheels stop 06:35:33.
- Orbit before the deorbit burn: apogee 188.5 nmi unchanged by the burn, so about 188.5 nmi near-circular (the ISS's orbit, 51.6 deg); the exact elements would come from the ISS TLE for 2011-05-31/06-01 (the targets file has NORAD 25544's 2011-05-18 TLE only).
- What the sim lacks: UNDOCKING in vehdyn.c (listed NOT MODELLED), a mated-stack attitude model (the Orbiter DAP controls the stack from 02:35:28; ISS mass/inertia and DAP configuration for it; whether the ISS gyros were used is not established), a TIME-WARP capture (propagate truth, re-seed PASS state vector and clocks) for the 11.7-day stay and the ~42 h after SEP3, night lighting in portview.  Rendezvous document sections: UNDOCKING PREP, UNDOCK OPS, UNDOCKING/TORS/TORF/INITIAL SEPARATION (p.1-9), STORRM DTO RE-RENDEZVOUS (p.1-10, SEP1 1.5, SEP2 1.5, NH2 2.0, NSR 2.4, TPI 3.4, SEP3 1.0 ft/s), UNDOCKING/SEPARATION TIMELINE (pp.2-x).

### Undock to SEP3: measurements and findings (2026-10-21/22)

Applied from the staging log (Full Documentation Sync, 2026-10-22); entries in date order.

[2026-10-21]
- RCS pulse/thrust check (JSC-10511 Rev B pp. 7-5..7-7, Table 7-IV; TD0340): min on/off cycle 80 ms (was 40), 15 ms tail-on/tail-off transient per firing regardless of duration, effective duration = on-time - 0.015 s; PRCS 870 lbf, VRCS 24 lbf. vehdyn.c jet_loads() is a square wave (no 15 ms loss), so a minimum pulse over-delivers impulse (and propellant) by ~23%; negligible for multi-second burns.
- Table 7-IV +X translation (L3A,R3A pair; 200K lb Orbiter): 0.279 ft/s^2 x, 0.049 z (z/x 0.176). Sim REF_FORCE 1713.6/302.2 lbf gives 0.2757 ft/s^2 at 200K lb and z/x 0.176: thrust magnitude agrees with the handbook to ~1%. SEP1 6.48 s -> 1.69 ft/s; the plan's 1.5 ft/s is not what 6.48 s delivers. The earlier "sim 12-16% too hot" inference (planned dV vs MR durations) is retracted.

[2026-10-21]
- SEP1->SEP2 reproducibility (undock-model, uncommitted): SEP1 is now ONE +X THC hold of 6.48 s (fly_undock.py thc_burn(fixed_hold=); UNDOCK_SEP1_JETS=1, UNDOCK_SEP1_HOLD overrides; handcontrollers.py logs each THC hold's start/release in vehicle s). f31b/f32a/f32b are identical to the last pulse (+0.25 ahead, -1.69 up; post-burn DAP pulses net body +0.052/+0.006/-0.107 ft/s) -> the sim is deterministic once the burn is. Old SEP1 spread (1.08..1.76 up) was the sized-hold + 0.12 ft/s correction floor + hold truncation, not physics. One DAP-cycle (80 ms) difference in THC release = 0.04 ft/s.
- CW from the sim's own pre-SEP1 state (x 635 z -39, v -0.24 -1.45) + the flown burn lands within 20 ft of the SEP2 marker; the 400 ft miss (guard stops at GMT 12979519) comes from post-burn DAP pulses (L2D+R2D pair at ~12978769 carries 0.11 ft/s) -- 0.1 ft/s = 160-240 ft at SEP2.
- Jet physics vs JSC-10511 Rev B Table 7-IV/7-V: primary-jet translation accelerations agree to 1-3%, +Pitch/-Pitch torque ratio 0.64 both, implied Iyy ~7.0e6 slug ft^2 = vehdyn's; vernier -P/+P torque ratio 0.50 vs 0.44. Not a force/inertia error. Mission Report FD15 table labels NSR/MC5 swapped vs durations (9.12 s = NSR 2.4, 1.6 s = MC5).
- Stalls at the SEP1/SEP2 capture were host I/O: a forgotten `find /` (bfs) read the whole filesystem for 2.5 h (IO pressure 26%); killed. Runs now go on the NVMe (/var/tmp/undock-runs/<run>, symlinked); design/sysmon.sh logs load/PSI/swap every 10 s to design/sysmon.log. All overlays now in ~/Desktop/Overlays/.
- vehdyn.c (undock-model, NOT built yet): YAGPC_VEHDYN_JET_DELAY_MS (default 0) dead-time model of the 15 ms tail-on transient (jetAge, jet_delay_s, anyOn keeps steps short).

[2026-10-21]
- MEASUREMENT ERROR FOUND: design/logged_track.py, overlay_logged.py and deviation_guard.py rebuilt the ISS between captures with a J2-about-frame-z RK4; the sim uses the full harmonic field of date (phys_gravity), so that reconstruction drifted 12 -> 655 ft over 1,100 s and produced the "400 ft off" guard stops and the 66% scores for f31b/f32a/f32c/f33a. vehdyn.c now logs "vehdyn-tgt:" (target r,v at ITS clock, lags the Orbiter's by ~26 ms = 650 ft, corrected in exact_track()); with it, f34a (as-flown SEP1: one +X hold of 6.48 s, primary DAP) scores 97.5% within +-200 ft of the figure, rms 58 ft, worst 265 ft, SEP1->SEP2. Exact track agrees with the driver's truth range to ~30 ft. Runs made before this have no vehdyn-tgt lines and cannot be re-scored exactly.
- 15 ms dead time (YAGPC_VEHDYN_JET_DELAY_MS=15, f34b): 97.1%, rms 78 ft -- no meaningful change SEP1->SEP2. Forward jets deselected (f32c) and VERN (f33a) were judged with the bad track; re-judge.

[2026-10-21]
- DETERMINISM: SEP1->SEP2 runs at --rate 1 are identical to the last pulse run to run (f31b = f32a = f32b = f34a: same +0.25/-1.69 SEP1, same post-burn pulses, same 403-ft artifact). At --rate 2 with host load 20-27 the SAME configuration scatters by 0.5 ft/s at SEP2 (f35b SEP2 miss 90 ft, f37b 828 ft; both primary DAP + 15 ms dead time) -- the keystroke/CRT-wait steps after SEP1 (p90 UNIV PTG) land at different vehicle times. Compare configurations only at rate 1.
- compare_fig.py: TIMING now at the commanded TIG (the detected burn start wandered by tens of seconds); LEG VELOCITY ERROR block = equivalent (x,z) velocity error at each leg's start that explains the miss at the next diamond (CW, targeted burns so no carry), with the figure's resolution floor ~100 ft / T. figure_curve.npy gap-filled where the curve runs along the axes; equal-scale base (design/trajectorySTORMMDTO2-equal.png, equal_base.py) is the overlay default; no current-<run>.png links.

[2026-10-22]
- TEST ERROR FOUND: runs with UNDOCK_FLOWN_BURNS=1 burn NH2 and MC5 with the flown FIXED vectors (-1.8 0 0; 0.1 0 0.5), never re-aimed from the actual state as the ground's solutions were, so any SEP2 error compounded (f40c/f46c: MC5 2.1 kft, NSR 5.8 kft, TPI 8.9 kft off). Without it (targeted NH2/MC5/NSR/TPI) f50b, restarted from f46c's SEP2 capture: NH2 576, MC5 961, NSR 822, TPI 517 ft off the diamonds; solutions NSR 2.4/TPI 3.36 ft/s vs the book 2.4/3.4, range at TPI 6,308 ft (book ~6,860); closest approach 984 ft at GMT 12990391 vs the Mission Report's 955 ft.
- DAP: tape's stored A9/B9 and A7/B7 are generic I-loads, not p. 6-2's (e.g. A9 VERN ROT RATE 0.2000 vs 0.130, ATT DB 5.00 vs 2.00, P/Y OPTION ALL vs TAIL); UNDOCK_DAP62=1 corrects them (A9/B9 at the undock, A7/B7 at SEP2 Preliminary), read back 'every item as 6-2'. With it the vernier firing SEP1->SEP2 fell from ~160 to ~74 jet-seconds (net z kick -0.35 -> -0.16 ft/s), concentrated in the first ~6 min after SEP1 (the quarter turn/track acquisition).
- OPEN: SEP1 burn direction depends on the attitude reached by TIG, which is not reproducible: +0.56 ahead (f44-f47), -1.49 (f48a, no early P 90), +1.68 (f49a), -1.61 (f52a), -1.72 (f52b); needed ~+0.1..0.3. The checklist burns +X up in the P 90 (-RBAR) attitude. Next: log the vehicle quaternion beside vehdyn-state (body axes in LVLH every 10 s) before more timing tests; the fly-around attitude is not deterministic at host load > ~15.
- Stroke-width criterion (owner 2026-10-21): 'visually indistinguishable' = centerlines within ~5 px of Stuit's figure = ~165 ft in x but ~50 ft in z, i.e. ~0.015-0.03 ft/s per long leg; compare_fig.py prints the pixel score and the equivalent leg velocity error.

[2026-10-22]
- Stuit (AIAA STORRM DTO paper p. 13): SEP1 is ALWAYS a radial-up 1.5 fps with a small posigrade component from the +X engines' cant; the fly-around leaves a residual dV (~1.5 fps radial up nominally) that "can vary significantly" with dispersions; the SEP2 targeting "can compensate for that difference". So Figure 21.1 is the NOMINAL plan: SEP2's position is not expected to match it (fly-around dispersions of tenths of ft/s = 160-240 ft per 0.1 ft/s at SEP2). Test the targeted chain instead (burn sizes, NH2/NSR/TPI positions, closest approach): f50b NSR 2.39/TPI 3.36/MC5 0.40 ft/s vs 2.4/3.4/0.4, misses 576/822/517 ft, closest approach 984 ft vs 955 ft.
- SEP1 attitude (attitude_series.py, vehdyn-state q): the vehicle slews at ~0.125 deg/s (the 6-2 A9 vernier rotation rate 0.130 barely exceeds the 0.127 deg/s ISS bearing rate), so the attitude at TIG is a phase of that slew set by the P-step times: -Z to ISS 10-15 deg for leads 45-100 deg (burn +0.50..+0.57 ahead), 81 deg for lead 140 (burn backward).  f60 = the corrected simulator on defaults only (committed 238ce91c8): SEP1 +0.56/-1.61, SEP2 614 ft off, then targeted burns.

[2026-10-22]
- f60 = corrected simulator on defaults only (commit 238ce91c8), SEPCFG -> SEP3 at rate 1: misses at the burns SEP2 614 / NH2 643 / MC5 176 / NSR 164 / TPI 207 ft; TPI 6,860 ft range (book ~6,860), burn 3.40 ft/s (book 3.4); NSR 2.43, MC5 ~0.4; closest approach 1,081 ft at 12990325 (mission 955 ft at ~12990265); pixel scores within 5 px: SEP1->SEP2 22%, SEP2->NH2 7%, NH2->MC5 53%, MC5->NSR 52%, NSR->TPI 92%, TPI->SEP3 63%. Equivalent leg velocity errors: 0.26, 0.29, 0.17, 0.15, 0.07, 0.09 ft/s (SEP3 0.75, driver's SEP3 not re-aimed). Early legs inherit SEP1's direction (attitude phase of the 0.125 deg/s slew) and the fly-around dispersion, which Stuit says SEP2 compensates.

### Undock to SEP3: the paper figures and the as-flown data (2026-10-22)

Applied from the staging log (Full Documentation Sync, 2026-10-22); entries in date order.

[2026-10-22]
- Mission Report FD15 narrative p.13-14 (PDF 19-20) vs the control-responsibilities page (PDF 48, printed p.42-43), owner's suggestion: SEP2/NH2/MC5/NSR/TPI/SEP3 times, durations and jet lists are IDENTICAL on both. Differences: (1) fly-around +X pulse is L1A+R1A on p.13 but L3A+R3A on p.42 (the sim's PASS fires L1A+R1A at the pulse, as at SEP1; unresolved, p.42 may reflect a different DAP/Z option); (2) p.42 only: forward jets reselected 03:18:07 EXCEPT F1F and F2F, which come back at 04:00:14 after undocking (sim has no F1F/F2F deselect; low impact, nothing fires them 03:55-04:20 except attitude control); (3) SEP3 MET 13/19:43:08 on p.13 is wrong by 60 s (p.42's 19:42:08 agrees with closest approach 08:24:25 = 13/19:27:57 + 14:11); (4) p.42 NSR MET repeats MC5's 13/18:02:40 (p.13 has 18:27:40, correct); (5) fly-around MET 13/25:22 on p.13 impossible (p.42 13/15:23:32 correct); (6) maneuver-to-undock-attitude start 02:46:28 (p.13) vs 02:35:28 (p.42, whose own MET 13/14:25:18 disagrees with p.13's 13/13:39:00). Control table adds Orbiter B/ALT/No Low Z from 03:53:00 (sim: DAP B/FREE/ALT, NORM Z at undock).

[2026-10-22]
- Christian et al., STORRM DTO (AIAA; ibiblio Shuttle/20110013437.pdf) Fig 2 "Undock, Re-rendezvous & Final Separation Relative Motion Plot" (raster 691x494; x 85 ft/px, z 36 ft/px; owner: it is the data recorded for the re-rendezvous, i.e. flown, not a plan; the paper's Reflector Visibility Tool plots use RPOP ground-processed flown state, same style). Digitized (scratchpad fig2cmp.py/fig2track.py): lower half (NH2->MC5->NSR->TPI) agrees with Fig 21.1 within a stroke; the upper SEP1->SEP2->NH2 lobe differs by ~600 ft (Fig 2 dip -1550 ft near x -10500, Fig 21.1 -2200 near -11000); Fig 21.1's lobe is a clean CW arc from SEP1 (61 ft rms), Fig 2's is not. f60 median distance to Fig 2: SEP1-SEP2 467, SEP2-NH2 984, NH2-MC5 95, MC5-NSR 161, NSR-TPI 71, TPI-SEP3 160 ft. Fig 2 hump is ~700 ft lower than f60's, dip ~4,000 ft earlier in x.
- SEP1 departure in Fig 2 (owner's observation): the path leaves SEP1 leaning ~13 deg from vertical toward -x (behind) over the first ~600 ft; f60 leaves vertical or ~3 deg toward +x (ahead). Difference ~16 deg +-8 (1 px = 85 ft) at ~3.1 ft/s = ~0.8 ft/s (+-0.4) less ahead velocity; CW fit agrees. CW: dvx -0.3 gives +0.54 kft x, +0.7 kft z (down) at SEP2 time = the observed hump offset; so the SEP1 direction (our +0.56 ahead vs ~+0.2 needed) is a candidate root cause of the early-leg departure from the flown track. Overlays: ~/Desktop/Overlays/trajectorySTORRMDTO-f60-fig2-logged.png, fig2-vs-fig21.1.png.

[2026-10-22]
- Figure 2 inset calibrated with the owner's labels (axes -1000..+1000 ft both ways, x positive to the left; frame 167x114 native px = 12 ft/px x, 17.5 ft/px z): CONSISTENT. Green loop is a circle centred (-5,-3) ft, radius 682 ft, rms 41 ft, equal in x and z, centred on the ISS icon (f60's loop: centre (12,5), radius 650). The path starts on the V-bar near 450 ft, goes up the +V-bar side, bends into the loop, circles clockwise (up on the ahead side, behind at the top), returns, and leaves up the same line (SEP1 marker at x ~ +676). Exit line vertices (x,z): (571,-395) (441,-790) (278,-988): leans 18 deg then 39 deg from vertical toward -x; f60's leans 15 then 32 deg, and is 84/113/151 ft further ahead at z -395/-790/-988. So the departure differs by only ~3.5-7 deg = ~0.2-0.4 ft/s of ahead velocity (supersedes the ~0.8 ft/s estimated from the coarse main plot). Overlay: ~/Desktop/Overlays/trajectorySTORRMDTO-f60-fig2-inset.png.

[2026-10-22, correction to the entries above, from the same session]
The Figure 2 / Fig 21.1 comparisons above were superseded the same day by Stuit's as-flown data (AIAA, ibiblio Shuttle/20110014805.pdf: Table 1, Figs 22-24, vector graphics).  Flown burn positions (x,z ft): SEP1 633,90; SEP2 -6009,-2452; NH2 -22570,-3426; MC5 -29792,-597; NSR -21412,4525 (text: -21411,4524); TPI -5176,4733; SEP3 688,2220.  Fig 21.1's SEP2 marker is 1.2 kft from the flown one, and the flown track is 300 ft median from the reference in the SEP1-SEP2-NH2 lobe (the History's "virtually on top" is a statement about the figure's overall scale).  f60's fly-around loop matches the flown TCS loop to a 7 ft median; the error was where it ended: SEP1 fired at the +V-bar crossing (z -36) where the flight was 90 ft below it, and that alone moved SEP2 by (+727,+636) ft of f60's 1,768 ft miss.  The SEP1 direction estimate above (+0.56 ahead vs ~+0.2 needed) is withdrawn: flown-implied post-SEP1 velocity is (+0.24,-2.87) ft/s against f60's (+0.32,-3.09).  Fix (fly_undock.py, UNDOCK_FA_END default 633,90): f64a SEP1 44 ft from the flown point, SEP1->SEP2 path 176 ft median from the flown track (f60 365), SEP2 miss 942 ft, SEP2 solution +1.38/+0.02/+0.26 vs flown +1.4/0/+0.1.  Stuit also gives the flown SEP2 residuals (~0.1 ft/s in both axes, which cut the range at NH2 by ~2,000 ft) and real energy growth from vernier attitude hold (NSR radial -1.4 -> -0.4 fps over 35 min).  Our NH2 TIG was 1.0-2.4 kft behind the flown one (f60 -1011, f65a -1774, f65b -2394 ft in x), the NH2 solution +1.2..+1.5 ft/s radial against the flown ~0.  Opt-in test in progress: UNDOCK_<LABEL>_UNDERBURN (fly_rndz134.py null_vgo, uncommitted); f66a UNDOCK_SEP2_UNDERBURN=0.1 delivered SEP2 +1.35/+0.02/+0.36 (f64a/f65: +1.49..1.54/+0.31..0.34); its NH2 not yet in.  Negative results: fly-around pitch steps 14 deg earlier (f63a) leave the nose at SEP1 unchanged (75.0 vs 75.1 deg at the same time; the vehicle slews at the rate limit all lap, bay 12-13 deg off, inside the book's +-15); UNDOCK_TRACK_ONCE=1 trims the NH2 burn 0.14 ft/s but leaves the SEP2->NH2 path unchanged (commit 3d6c368).

### Undock to SEP3: the SEP2 delivery, the SEP1 re-aim, the TPI coupling and the Cooper data (2026-10-22/24)

Applied from the staging log (Full Documentation Sync, 2026-10-25); entries in date order.

[2026-10-22]
- SEP2 under-burn (Stuit: crew residuals ~0.1 ft/s both axes) is now the default for SEP2 (fly_rndz134.py null_vgo, UNDOCK_SEP2_UNDERBURN, undock-model). f66a (from f64a's SEP1 capture): SEP2 delivered +1.35/+0.02/+0.36; NH2 TIG (-21935,-3628), 666 ft from the flown (-22570,-3426) (f65a 1,800, f60 1,090); NH2 solution -1.93/-0.05/+0.55 (|2.01|, book 2.0, flown -1.8/0/-0.1) where f65a/f65b needed +1.16/+1.25 radial. Remaining: SEP2 radial asked +0.27 vs flown +0.1; NH2 TIG now 635 ft ahead of flown in x.

[2026-10-22]
- UNDOCK ROOT CAUSES FOUND AND FIXED (undock-model, fly_undock.py/fly_rndz134.py/rerndz.py, all committed): (1) SEP1 fired at the +V-bar crossing; flown SEP1 (Stuit Fig 22/23) is at x 633 z +90, UNDOCK_FA_END default; (2) the lap's pitch turns run back to back at the DAP's 0.130 deg/s (6-2) so the last turn (the +Vbar attitude of [8C]) ended ~70 s after TIG: nose 80-82 deg at SEP1 (burn 8-9 deg off vertical, ~0.2 ft/s extra ahead); first turn now commanded 90 s before 04:20:00 (UNDOCK_FA_P0_T), nose 89.5 deg at TIG (f68a, f70a); (3) the crew under-burned SEP2 by ~0.1 ft/s per axis as flown (Stuit): UNDOCK_SEP2_UNDERBURN default 0.1, first pass leaves 0.15 more; (4) NH2/NSR solutions aimed y at 0 over a half-period transfer: Y +0.41/+0.45 ft/s, 372 ft out of plane at MC5; targeted_dv is now in-plane (Table 1 has Y 0.0 for every burn; RERNDZ_OOP=1 restores the 3-D aim).
- Results vs Stuit's as-flown data (vsflown.py, overlay_flown.py): f68a and f70a (all fixes, independent full runs) SEP1->SEP2 path 14 and 30 ft median from the flown track (f60 365, f67a 415), SEP2 misses 454 and 568 ft (f60 1,768); f69a NH2 solution -1.89/0.00/-0.09 vs flown -1.8/0/-0.1 (f60 +1.45 radial). Reference trajectory (Fig 21.1) overlays were replaced by flown-data overlays (watch_logged.sh).
- REMAINING: SEP2 execution scatter. Same capture, same asked burn: f71a delivered +1.76 along-track, f71b +1.63 (VGO left +0.12/+0.05); jets differ (f71b L1A/R1A 1.92 s vs 0.64 s): DAP attitude-control transients in the burn; ~+-0.15 ft/s, which moves NH2 by +-2 kft (f71a -26,643, f71b -24,228, f69a -21,616, f70a -23,779; flown -22,570). Truth dV minus PASS's (asked - VGO left) at SEP2: +0.17 +0.13 +0.13 -0.11 +0.06 -0.12 -0.19 -0.01 +0.32 +0.12 (f64a..f71b).  NH2 radial truth is ~+0.17 above PASS's figure in nearly every run: the CW term 2n*xdot over the burn (not an error).  Open: whether the sim's burn-to-burn scatter is the right size; the flight had its own (residuals ~0.1).

[2026-10-23]
- SEP2 -> NH2 ATTRIBUTION VERIFIED (11 runs f60..f71b): NH2 TIG x = -817 - 15,081 * (SEP2 truth dV x) - 5,344 * (SEP2 truth dV z); the along-track slope matches the CW prediction (4/n sin(nT) - 3T = -15,212 ft per ft/s, T 3,932 s) to 1%; residual sd 901 ft against the raw 1,374.  So the NH2 along-track scatter IS the SEP2 delivered along-track dV scatter (sd ~0.13 ft/s, range 1.22..1.76): thrust integrals from jetlog.py agree with the truth dV to 0.05 (f71a net body dV -1.407/-1.012, f71b -1.322/-0.902 ft/s: f71b fired L1A/R1A 1.92 s vs 0.64 s, the DAP's attitude-control transients in the -X hold), so the variation is delivered thrust, not a measurement artefact.  The mean ~2 kft offset behind the flown NH2 = our mean truth dVx ~1.6 against the flown ~1.4-1.5.  SEP2->NH2 path: 41/103/383/120/65/152 ft median from the flown track (f69a f70a f71a f71b f72a f72b).  The z coefficient of the fit has the wrong sign versus CW (+2,096): the runs differ in start state, so it is confounded.
- PASS's own nav error right after SEP2 (driver nav-error lines, before radar marks): velocity -0.12..-0.23 ahead, -0.35..-0.48 down; GL5NAV removes a sum under 0.9 ft/s when a cycle passes without jets (null_vgo docstring), so trim pulses after the main hold can be dropped from PASS's state: the flight software's behaviour, not a sim defect.

[2026-10-23]
- SEP2 DELIVERY SCATTER: ROOT CAUSE FOUND AND VERIFIED.  PASS sums sensed dV once per 3.84 s cycle, so a VGO read 1.5 s after a hold is stale; null_vgo learned the THC acceleration from those reads (f71a -X 0.397 -> 0.181, f71b 0.150, truth 0.23-0.24) and sized the next hold from them, overshooting and trimming back (f71b: -X 2.61 s, 5.32 s, +X 1.85 s).  Fix (undock-model, fly_rndz134.py null_vgo): an under-burn is one hold per axis with fixed accelerations UNDER_ACC, no learning, no second pass unless VGO > 0.35.  f73a/f73b (same capture): holds -X 5.32/5.35 s, truth dV +1.44/+1.46 (f71a/f71b +1.76/+1.63; flown 1.4), NH2 TIG x -21,035/-21,020 (f71a/f71b -26,643/-24,228; flown -22,570): scatter 1.3 kft -> 15 ft.  Mean offset flipped from 2 kft behind to 1.5 kft ahead; the flown NH2 equals a truth dVx of ~1.54 in our dynamics (Table 1 gives 1.4 +-0.05).
- SEP1 RECALCULATED (fly_undock.py, UNDOCK_SEP1_TARGET default -6009,-2452): the post-SEP1 velocity that reaches the flown SEP2 point is (+0.19,-2.83) ft/s from any of our SEP1 states, 0.2-0.3 ft/s less up than the fixed 6.48 s burn gave; the +X hold is scaled to the vertical part (f74a: 5.38 s, dV +0.27/0/-1.39).  f74a SEP2 miss 499 ft ahead (f68a/f70a 454/564 behind): bias gone, execution scatter ~+-500 ft remains (one run).  SEP3 remains a fixed 1.0 ft/s retrograde (RR.sep3_dv), not re-aimed.

[2026-10-23]
- Demo run chosen: f75a (closest approach 1,084 ft vs flown 955; f76a 796 ft vs the 656 ft keep-out and loops at TDA). Code frozen as branch demo-f75a in worktree ~/work/undock-f75a (b52c31ee5 + UNDOCK_PREFREE=skip + SIM_SCALE). Run dir ~/sts134-runs/undock/demo-f75a (sts134r-prefree 03:49:34 copied as sts134r-sepcfg, approachDock.layout as demo.layout). Not yet started or restore-tested.

[2026-10-24]
- New FD15 sources (Shuttle/ dir): "STS-134 D14_S3.pdf" (SSP shift report), "STS-134 D15_S1.pdf", "554443main_PAO_FD15_ExPkg.pdf". Give per-burn RCS jets and firing times (SEP2 5.2 s F2F F3F F2D F1D L2D L3D R2D R3D; NH2 6.72 s L1A R1A L2U R2U F1U; MC5 1.6 s; NSR 9.12 s F2F F3F F1D F2D L2D L2U R2D R2U; TPI 11.6 s +L3D R1R R3D; SEP3 3.68 s), flown LVLH dV (SEP2 X1.53, NH2 X-1.83, MC5 Z0.53, NSR X-2.49, MC6 no burn, TPI X0.25 Z-3.38 TIG 07:57:35 slip -33 s, SEP3 X-1.00), all burns DAP A/AUTO/PRI; closest approach 955 ft CG-CG 08:24:25; undock ~03:55:11; DAP B12 hold 03:20:21; maneuver to undock attitude 02:46:28-03:18:31 (resolves the 02:35:28 discrepancy: that is DAP to AUTO at start of undock prep); spring pushoff needed 4 DAP B +pitch firings, NORM Z 1 at 13.1 ft and 4 after 30 ft; ISS attitude error at sep -.14/-.81/.78 deg; TCS tracking began at 5330 ft, shut down after closest approach (CPU overheat); undock attitude TG=2 BV=5 P=180 Y=0 OM=0 confirmed (PAO ExPkg).
- Propellant (PFS % at ~09:00 GMT 150): FRCS ox 16.8 / fuel 14.6 (D14_S3: 17.0/15.8), L RCS 64.8/65.0, R RCS 62.8/63.8. Sim at SEP3: FRCS 76 lb = 2.8%, aft ~55.5%. PAD (MSG 176): connect OMS to RCS when L or R RCS < 56%; FRCS < 5% = breakout. FRCS logic/drivers OFF 150/11:50:46 (partial group B powerdown); Right OMS interconnect 10:25:00; MAUI burn 11:43:18; DAP LVLH 09:10:19 end of STORRM DTO.

[2026-10-24]
- undock_start.py (branch undock-model, commit above): RCS at undock F 849 / L 1750 / R 1750 lb (was 555/1691/1689), from the FD15 shift-report PFS % at 09:00 plus listed-burn use. Existing captures (demo-f75a etc.) keep the old load; rebuild the start capture to use it. Per-phase sim use vs flown jets x time x 3.05 lb/s: SEP1 aft 19.5 vs 19.8 (ok), SEP2 fwd 59 vs 63, NH2 fwd 22 vs 20.5, MC5 fwd 9.8 vs 9.8, NSR fwd 36 vs 111 (sim low), TPI fwd 180 vs 141, aft 90 vs 106-141, SEP3 fwd 37 vs 45, aft 5 vs 34 (sim low). Earlier "TPI overspends" claim was overstated; the real TPI cost a similar amount. Fly-around: sim 111 fwd / ~100 aft per pod, real unknown (aft L1A R1A pulses only listed).

[2026-10-24]
- CORRECTION to the entry above: the FD15 burn "firing times" are the SPAN from first to last jet fired and the jet lists are the UNION of jets fired, so jets x span x 3.05 lb/s overcounts (phase0-notes item 9's F 399/L 313/R 349 is the same overcount). By physics: 12.3 ft/s of listed burns at 214,677 lb = ~316 lb ideal, 410-630 lb with attitude control. Undock RCS now F 655 / L 1691 / R 1689 lb (undock_start.py). Sim use vs ideal (m*dV/Isp 260 s): SEP1 1.0x, NH2 1.3x, SEP3 1.9x, SEP2 2.7x, MC5 3x, TPI 4.3x (overshoot + passes); TPI/SEP2/MC5 are the outliers. The RCS BURN card is flown on the THC in the flight too, so the THC driver is not a deviation.

[2026-10-24]
- TPI propellant tests (tpi-test1/2/3 in sts134-runs/undock, from the f75a NSR capture, rate 3): demo 357 lb RCS; 70 % first VGO pass 308; + 4.5 s VGO read wait 310; + X before Z 294. Remaining waste: pass 0's -X hold delivers 0.136-0.14 ft/s^2 (second pass 0.267, NSR 0.298) whatever the order or read wait, so the learned value is wrong for pass 1 and it overshoots. Cause not found. Committed on undock-model: first-pass scale 0.7 (default), the other two hooks off.

[2026-10-24]
- TPI -X anomaly SOLVED: not a stale VGO read (tpi-test5 probe: VGO steady for 8 s after the pass) and not a short burn (tpi-test6 truth state at 0.25 s: the 4.75 s -X hold delivered body x -1.29 ft/s, full 0.27 ft/s^2 from F2F+F3F).  The THC holds are COUPLED: the -Z hold (5.8 s, 6 D jets) delivered z -2.91 AND x +0.57; the -X hold delivered x -1.29 AND z +0.26 (about +-0.2 per unit).  The per-axis learner read the +0.57 as a -X shortfall (0.14 vs 0.27).  Fix (7fce43f80 on undock-model): null_vgo solves [1 kxz; kzx 1] jointly (UNDOCK_NULL_COUPLE default -0.196,-0.20), seeds Undock.thc_acc from the truth (-Z 0.52, -X 0.27, +X 0.28, +Z 0.39), first-pass 70 % scale now off.  TPI RCS 357 lb (demo) -> 185 lb (fwd 104.5 / 40 / 40, tpi-test8, one null pass); with the old polluted seeds it still overshoots (tpi-test7, 370 lb).  Validation run val-nh2 (NH2->SEP3, demo sep2 capture, new seeds) started 21:25.
- User guidance (2026-10-24): burns at SEP1/SEP2/etc. must use the flown METHODS on the simulated run's own state, aimed at the reference trajectory's milestones, not the flown dV values (dispersion).  fly_undock already does this by default (RR.targeted_dv / mc5_dv / coelliptic_dv; UNDOCK_FLOWN* are diagnostics only).  Post-ISS coast: to be flown from a no-tricks SEP3 snapshot, no warp; wait for MCC Consolidated Shift Reports for FD16-17 before building it.

[2026-10-24]
- COOPER DATA (goal, 2026-10-24): the 48-file cache ~/Desktop/Shuttle Stuff/Cooper Shift/ is now a database, yaShuttle/yaGPC2/sts134-mission.db (undock-model 55ce4ea28; builder sts134-mission-db.py: build / timeline / search / prop).  Tables: documents, lines(+FTS), events (460 stamped sentences), burns (FD1-3 OMS/RCS incl. NC4, Ti, MC1/2/4 from the FD3 daily; FD15 LVLH delta-Vs and residuals), propellant (15 PFS % blocks), consumables, orbits, attitudes, mass_items (Boeing weight-and-balance), discrepancies (15 curated), sim_impact.  The cache holds NO shift report for FD15 S3, FD16 S3, FD17 or FD14 S2 and no FD11-12; the coast days 150/16:00-152/08:00 are covered by FD15_S2, FD16_S1/S2 (subsystem status only) and the Landing-plus-2-hour report.
- Cooper facts for the sims: PFS % forward 37.0/36.0 (149/16:00) -> 16.8/14.6 (150/09:00); aft 76.8/77.2 -> 64.8/65.0 (L), 75.4/76.4 -> 62.8/63.8 (R); OMS interconnect usage % L 0.161, R 1.605 -> 2.057 (right interconnect 150/10:25:00).  FD1-3 burn table sent to Codex by mailbox (message 163).  Deorbit Prep checklist (Rev Q, ~/Desktop/Work in progress/SpaceDocCache/Checklists/Deorbit Prep/) begins at TIG-4:00; PLBD closing TIG-2:40 (flown 152/02:48:24/02:49:45); OPS 3 at TIG-2:20; IMU/IMU align TIG-1:10 -- the DEORBIT driver (fly_sts134) still follows ENT/ALL/GEN H from TIG-75.
- COAST implemented in fly_return.py (not yet committed at this entry): phase COAST restores sts134r-sep3 and flies to 152/01:29:03; events: 150/09:10:19 LVLH (-ZLV +YVV, primaries then verniers), 151/07:33:10 RAMBO-2 (3 x 10 s +X L1A R1A); 6-hourly SV uplink, 4-hourly captures, 30-min nav log.  Not flown (blockers): MAUI (144 s total, jets known but direction/split unknown -- 144 s of L1A+R1A would be 38 ft/s, inconsistent with the orbit), RCS hot-fire (procedure not in hand), FCS checkout, water dumps, FRCS drivers off (no panel control).  Achieved rate on this host is ~3.1 whatever --rate asks (load ~12).  deorbit_target.py got --near-gmt; fly_sts134.deorbit_targets takes self.DEORBIT_ARGS; Return sets --tff 34.05 --near-gmt 152/06:34:50 (the flown opportunity, orbit 248).

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
- **Max-q is ~4.8% low** with the day's winds and atmosphere (698 psf
  against 733.1; 715 with the Patrick atmosphere and no wind): the day's air
  lowers it.  STS-135's (721 against 734) was flown without its day's
  weather.  (The 723 psf given here before was a recomputation from the 1976
  atmosphere with no wind, not the truth's.)
- **The OMS-2 burn is 1.6% (STS-134, `sts134f`) to 20% (STS-135) dearer** than flown, from
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
