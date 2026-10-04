# STS-134 launch to orbit: the simulated timeline

This is the flight being flown in yaGPC2: one GPC running PASS OI-34 (tape
`OI340700-v44boot` with STS-134's OPS 1 overlay I-loads), from IPL on LC-39A
to the orbit after OMS 2.

**T = 0 is SRB ignition** (the MECs fire SRM IGNITION; the hold-down posts let
go). STS-134's was **136/12:56:27.994 GMT** on 2011-05-16 (JSC 37461,
Appendix A). In run `sts134c` the simulated SRB ignition came at
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
before OPS 101, onto the already aligned vehicle.

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
| Pre-launch | The flight now running (run `sts134`, panel and yaGPC2 logs) | Accurate to about ±10 s. The pre-launch timetable is *ours*: STS-134's real countdown spread these activities over a day (S0007 and the GLS document; see References). |
| Terminal count, ascent and OMS 2 | The full flight, run `sts134c` (scratch-2026-10-03), from IPL | Tape `OI340700-v44boot-sts134.mmv` as it was then (MECO radius 21,250,656 ft), synthesized stack aerodynamics, the HPM booster trace, Isp 455.2 s, the in-plane target. Times are from its SRB ignition, 136/12:56:27.81. |
| The vehicle model since | Ascent test flights `ia88`, `ib88`, `ic88`, `id88`, restored from a pre-ignition capture of the ISS-plane setup | See "Since run sts134c" below: the aerodynamics, the RSRM, the 52 nmi MECO and the engines' Isp have changed, and no full flight has been made with them yet. |
| STS-134 actual | JSC 37461, Appendix A | Shown alongside where it exists. |

## The timeline

### Setup on the pad (OPS 0 → OPS 9)

| T | GMT 136/ | Who | Event | Data source |
|---|---|---|---|---|
| −1:26:28 | 11:30:00 | SIM | Vehicle clock starts (`--date-time-epoch 2011-05-16T11:30:00`). The stack is on the pad at the nav base, belly north. The orbiter weighs 121,826 kg. The SLWT holds 1,387,457 lb LO2 and 234,265 lb LH2. The truth's RNP epoch is 2011 day 136. | Pad position: NAVBASE I-loads (CGNCOM). Belly north: STS-1 OFP 4.2.1.21. Orbiter mass: spacefacts.de. Tank load: SLWT, Wikipedia. |
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
| GROUND | **13** pitch table THET(1,30) | The tape's pitch-over scaled by **0.88**.  At 0.75 the simulated stack matched STS-1's SRB-separation state (167,274 ft, Vrel 4,187 ft/s, γ 34.9°), but with the orbiter's true mass MECO then fell short; 0.88 gains 113 ft/s, and 0.80 and 0.75 still fall 45 and 169 ft/s short with the lower MECO.  Max-q is then about 950 psf, against STS-134's 733. | STS-1 OFP (JSC-14483 Vol 3) Table 6.2-I; flights `t082`, `t088`. Calibrated on the simulated vehicle, as the real DOLILU was for the real one. |
| GROUND | **40** roll table PHI(15) | The same −28.71° turn at liftoff (PHI(1) = PSI(1): no roll on the pad), blended out by heads-down (180°) | |
| GROUND | **14** QPOLY, TREF | QPOLY = 55, 935, 1100, 10000 ft/s: the simulated vehicle's Vrel at STS-134's throttle times. TREF_ADJUST = **21.9 s**: the vehicle (IA156 aero, RSRM) reaches VREF_ADJUST 488 ft/s at T+21.6, and guidance sees it on its next pass, so TDEL stays inside the 0.21 s deadband and adaptive throttling stays off. Run `sts134c` flew 22.5, and AGT raised its bucket to 84%; 0.4-0.7 s off moves the bucket to 65-92%, because the QPOLY span is only 165 ft/s. | JSC 37461 Appendix A: 104.5% at T+4.1, 72% at T+39.5, 104.5% at T+51.3; JSC 37461 SSME section: single-step bucket to 72%, AGT not activated. GG31ST (THRT_FAC 6000/4500, deadband 0.21 s). |
| GROUND | **39** THROT | 104, 72, 104, 104 (INTEGER; the Block II controller runs a 104 command at 104.5%) | JSC 37461 (SSME section, Appendix A) |
| GROUND | **96** MECO pseudo targets | VDMAG 25,819 ft/s; GAMD 0.65° | STS-134 Ascent Checklist (ASC/134/FIN): MECO "√VI = 25819" |
| GROUND | **37** OMS assist and masses | ASSIST_OMS_DT 170 s. MASS_ORBITER_LIFTOFF 8,347.7 slug. MASS_VEHICLE_ET 60,570.6 slug (orbiter + SLWT + 1,621,722 lb propellant). The rest is the tape's own 58 halfwords. | MOD FRR FDD p26: "170 sec OMS Assist". Masses: as above. |
| GROUND | **25** OMS targeting | IYD_OMS(1,2) = the plane of message 15. OMS 1 is the tape's (not flown). OMS 2: DTIG 1,756 s after ET separation, with pre-flight targets HT 175.8 nmi, θT 330.43°, C1 0, C2 0. **After MECO the ground designs the real targets from the insertion and uplinks message 25 again, in OPS 1** (`fly_sts134.py`, `oms2_targets`). In run `sts134c`: HT 175.80, θT 314.45°, predicted 124.1 × 175.8 nmi for 267.2 ft/s. | TIG: JSC 37461, ET sep at MET 8:42 and OMS-2 TIG at MET 37:58. Targets: `omstarget.py fromlog` (PASS's GGOTGT + GGILTV, ported), solved for STS-134's 124.3 × 175.8 nmi. |

Not uplinkable, so they are on the tape instead (`yaGPC2/tools/mission_reconfig.py` with `sts134-reconfig.json`, OPS 1 overlay):

| Cell | Tape | STS-134 | Data source |
|---|---|---|---|
| CGGS_V_MAG_MECO_NOM | 25,668 | **25,819** ft/s | Ascent Checklist |
| CGGS_K_CMD_NOM | 100 | **104**% | JSC 37461: 104.5% to the 3-g throttling |
| CGGS_RAD_MECO_NOM | 21,290,308 ft (a + 60.02 nmi) | **21,241,604** ft = a + 52 nmi, where a = 20,925,646.3 ft is PASS's equatorial radius | Space Shuttle Missions Summary (NASA 20110001406), STS-134: "a 52 nautical mile MECO", one of the flight's performance enhancements. The tape's own value fixes the convention. Run `sts134c` flew 21,250,656 ft (a + 53.5 nmi, from an unsourced "107 km"). |
| CGGS_FPA_MECO_NOM | 0.5° | **0.65°** | No STS-134 value found. With VI 25,819 it gives a post-MECO apogee near the MOD FRR's "insertion altitude 122 nm". |

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

### Ascent (PASS, MM 102 → 103 → 104), run `sts134c`

| T | Event | STS-134 actual (JSC 37461; Missions Summary) |
|---|---|---|
| **0.00** | **SRM IGNITION fired; liftoff (hold-down posts released)**, 136/12:56:27.81 | 136/12:56:27.994 |
| +0.04 | T-0 umbilical fired | |
| +4.36 | Throttle up to 104.5% | +4.1 |
| ≈ +7 to +20 | Roll program to heads-down | |
| +39.24 | Throttle down for max-q to **84%**: adaptive throttling raised the 72% I-load (TREF 22.5; now 21.9, see below) | 72% at +39.5; AGT not activated |
| +45.96 | Throttle up to 104.5% | +51.3 |
| +66.3 | Max-q, **949 psf** | Max-q **733.1 psf** at +60.0 |
| +128.08 | MEC: SRB SEPARATION ARMED | Both SRMs at 50 psia +119.95 / +120.31; end of action +122.5 / +122.9 |
| **+129.84** | **SRB separation** on the 50 psia cue | **+124.7** (Missions Summary: 2:04.8) |
| +130.12 | 106% (K_CMD_STG2) | |
| ≈ +134 to +304 | OMS assist, both engines, 170 s | +134 to +300.5 (164.2 s) |
| +218.44 | 104.5% (K_CMD_NOM, from the tape reconfiguration) | |
| +448.84 to +504.52 | 3-g throttling, 100% → 67% | 3-g throttle-down from +440.0; 67% at +494.7 |
| **+510.8** | **MECO command** (guided).  VI **25,819 ft/s** truth (target 25,819); 780 kg LO2 left at ET separation | **MECO +501.1** (Missions Summary: 8:21.5); VI 25,819 (P), 25,818 (A) |
| +524.64 | MEC: ET umbilical unlatch fired | |
| **+532.0** | **ET separation**.  Post-MECO orbit 123.8 × 27.6 nmi | ET sep +522 |

The truth's velocity budget to ET separation (vehdyn): 30,550 ft/s of thrust,
of it 27,551 along the velocity; drag loss 520 ft/s; gravity loss 2,549 ft/s.

### Since run `sts134c`

These changes to the vehicle model have been flown only in ascent test
flights, from a pre-ignition capture with the ISS-plane uplink:

| Change | Source | Effect (test flight) |
|---|---|---|
| **Stack aerodynamics from wind-tunnel data.** Forebody CA and the power-on base drag on Mach; CN = CNα (α − α₀). Commit 7b2c9a80e. | IA156 data (ADDB Vol II, SD72-SH-0060-2K) as plotted in the STS-1 OFP (JSC-14483 Vol 3) fig. 6.2-1 (ww), (o), (l), (k), (yy), digitized. S = 2,690 ft² is confirmed by (zz) = CA q S + base drag. | Drag loss 514 → 662 ft/s (STS-1's own, integrated from the OFP: about 380 ft/s at 575 psf). `ia88`: MECO 24 ft/s short. |
| **TREF_ADJUST** 23.2, then 21.9 | GG31ST; the vehicle's own time to 488 ft/s | Bucket 72%, AGT off |
| **RSRM thrust trace** in place of the pre-Challenger HPM's. Commit 624a328ab. | JSC-19041 SRB Overview Rev F, Fig 4.3-I (RSRM population nominal, 60 °F); STS-134's PMBT was 62 °F | SRB separation +129.8 → +127.6 |
| **52 nmi MECO** (RD_NOM, table above) | Missions Summary | `ic88` (with the RSRM and TREF 21.9): MECO VI 25,830 with 646 kg LO2 left; max-q 954 psf |
| **SSME Isp 452.07 s** at 104.5%, flow = thrust / Isp, in place of PASS's nominal 455.2. Commit 26ffacd6b. | JSC 37461, SSME section | `id88`: LO2 depletion at VI 25,755, **64 ft/s short**; MECO command +510.0; SRB separation +127.6; 3-g throttling from +446.6; max-q 955 psf |

### OMS 2 (MM 105), run `sts134c`

The crew's actions are from the STS-134 Ascent Checklist (ASC/134/FIN), pp. 3-3 to 3-7 and the OMS 2 cue cards.

| T | MET | Who | Event |
|---|---|---|---|
| after ET sep | | GROUND | Message 25 with the OMS-2 targets designed from the insertion: HT 175.80, θT 314.45° (predicted 124.1 × 175.8 nmi, 267.2 ft/s) |
| ≈ +1,137 | 0:18:57 | CREW | `dap c3 auto` (C3 DAP – AUTO) |
| ≈ +1,142 | 0:19:02 | CREW | `OPS 105 PRO` (MAJOR MODE CHANGE: CRT1 GNC, OPS 105 PRO) |
| ≈ +1,162 | 0:19:22 | CREW | TRIM LOAD: `ITEM 6 +0.4 −5.7 +5.7 EXEC` |
| ≈ +1,167 | 0:19:27 | CREW | LOAD: `ITEM 22 EXEC` |
| ≈ +1,172 | 0:19:32 | CREW | TIMER: `ITEM 23 EXEC` |
| ≈ +1,182 | 0:19:42 | CREW | MNVR: `ITEM 27 EXEC` (maneuver to burn attitude) |
| — | — | SIM | OMS engines ARM/PRESS (`YAGPC_OMS_ARMED=1`; the checklist's TIG−2 switch) |
| +2,280.0 | 0:38:00 | CREW | `EXEC` at TIG−8 s |
| **+2,288.0** | **0:38:08** | PASS | **OMS 2 ignition** (TIG = ET separation + 1,756 s), about 176 s.  STS-134: ignition MET 0:37:58, 168.6 s, 259.2 ft/s. |

### Result: the orbit after OMS 2

| | Simulated (truth) | STS-134 (JSC 37461) |
|---|---|---|
| Apogee × perigee, just after the burn (osculating, T+2,471) | **175.8 × 124.8 nmi** above the equatorial radius | **175.8 × 124.3 nmi** (Missions Summary predicted 175.9 × 124.7) |
| Inclination | **51.62°** to the equator of date | **51.6°** |
| One-orbit average (1,091 samples over 5,450 s) | **169.6 × 124.4 nmi** above the equatorial radius (osculating range: apogee 165.4-176.0, perigee 120.3-130.8); 169.8 × 124.6 above the ellipsoid; **51.60°** (51.58-51.62) | 175.8 × 124.3 nmi, 51.6° |

Osculating apsides move about ±5.5 nmi around an orbit (J2).  Run `sts134b`
(the tape's MECO radius, pre-flight OMS-2 targets) averaged 171.0 × 126.9 nmi
and 51.60° over one orbit.

## Derived data and how it was obtained

| Data | How | Where |
|---|---|---|
| Plane normal IYD | The 51.6° plane through the nav base at the inertial azimuth asin(cos i / cos φc) = 44.95°, as IY = d × r̂ in PASS's Earth-fixed frame | Checked on the tape's 38° I-load: (0.5073, −0.3488, −0.7880) against the tape's (0.5172, −0.3339, −0.7880) |
| Yaw/roll tables | The tape's tables turned by the azimuth difference (63.66° → 44.95°), then a further −10° found by flight on the out-of-plane error and MECO margin | GG31ST.hal step 16 |
| Pitch table | Pitch-over scaled 0.88, by flight with the orbiter's true mass.  The first tuning (0.75, to the STS-1 SRB-separation state) was done on test flights that had silently restored a 100,000 kg dry orbiter instead of the flight's 121,826 kg. | STS-1 OFP Table 6.2-I |
| QPOLY, TREF | QPOLY: the simulated vehicle's Vrel at the report's throttle times. TREF: its time to 488 ft/s plus guidance's detection lag (about 0.3 s), read back from PASS's CGGV_TDEL_ADJUST with `pasvar` | JSC 37461 App. A; GG31ST |
| MECO radius | a + 52 nmi, with a and the convention from the tape's own RD_NOM (a + 60.02 nmi) | Missions Summary |
| OMS 2 HT, θT | `omstarget.py`: PASS's PEG 4 target geometry (GGOTGT) and linear-terminal-velocity constraint (GGILTV), ported, solved for HP 124.3 / HA 175.8 at the fixed TIG.  In flight, `fromlog` takes the truth after ET separation and coasts it to TIG. | |
| Gimbal pitch sense | −1 for SSMEs and SRBs. With +1 the loop diverged at liftoff. | vehdyn.c |
| AA normal axis | Positive up (−Z) | GDRENT.hal:107 (LOAD = AA_NORM × g0); NZREF table (CGCUN1.hal) |
| Stack aerodynamics | IA156 wind-tunnel data, digitized from the STS-1 OFP's plots of its nominal ascent: forebody CA and base drag (as a coefficient on the OFP's q) on Mach; CN = CNα (α − α₀), the slope measured below Mach 0.4 and assumed above, α₀ fitted to every OFP point.  Run `sts134c` flew synthesized tables. | JSC-14483 Vol 3 fig. 6.2-1; vehdyn.c |
| SSME tail-off | 0.958 s at full thrust | PASS's own CGGS_T_TAILOFF (GG42ND step 87) |
| SSME Isp | 452.07 s; the controller holds thrust, so flow = thrust / Isp.  Run `sts134c` flew 455.2. | JSC 37461 |
| SRB thrust | RSRM population nominal at 60 °F, digitized; its integral is the propellant at Isp 266 s to 0.1%, so unscaled.  Run `sts134c` flew SODB Fig 6.3.1-2, which is the pre-Challenger HPM, with a tail-off about 3 s longer. | JSC-19041 SRB Overview Fig 4.3-I |
| SRB chamber-pressure words | 914 psia scaled by thrust, through PASS's calibration | GPXSRB.hal; GSESRB.hal |

## Known differences from STS-134

These reflect the current model (test flight `id88`) unless they say otherwise.

- **MECO velocity is 64 ft/s short** (LO2 depletion at VI 25,755), and **max-q is about 955 psf** against STS-134's 733.1.  STS-134 itself had little to spare: an I-load design ascent performance margin of 1,566 lb, 1,107 lb projected (MOD FRR FDD p3), and an FPR of 2,821 lb (Missions Summary).  So performance is missing elsewhere in the model, and the pitch table cannot yet be lofted toward 733 psf.
- **The stack is heavier than STS-134's at a given time** by about 28,000 lb: 3-g throttling begins near +447 against +440.0, and MECO comes near +510 against +501.1.
  - The ET load is the tank-capacity figure (LO2 1,387,457 lb, LH2 234,265 lb, Wikipedia).  No sourced STS-134 load has been found; the FRR says the OMRSD loading quantities were delivered separately.
  - The engines burn at mixture ratio 6.0 against a load ratio of 5.92, which strands about 3,000 lb of LH2 at MECO.  STS-134 planned a fuel bias of 954 lb.
- **SRB separation is about 3 s late** (+127.6 against +124.7).  The RSRM trace reaches 50 psia about a second later than STS-134's motors, and PASS's separation sequence takes longer after it.
- **The first stage ends out of the final plane** (about 18 nmi for the in-plane target), which second stage steers out.  The yaw table was tuned for best MECO margin, not zero plane error.
- **The pre-launch timetable is compressed into 85 minutes.** The real one spanned the day before launch (S0007: IMU power-up at L-27h30m; OPERATE and ATT DET by L-8h20m; gyrocompass about 42 min).
- **The crew's post-MECO procedures are abridged to what the flight needs.** Omitted: MPS dump, APU shutdown, ET umbilical doors.
- **MECO flight-path angle** 0.65° is chosen, not sourced.
- **MECO time:** JSC 37461 puts it at T+501.1 (SSME shutdown commands at
  13:04:49.10), and the Missions Summary at 8:21.5.  The T+504 also quoted
  elsewhere is not supported by either.

## References

All are in the local ibiblio mirror (`~/Desktop/sandroid.org/public_html/apollo/Shuttle/`) unless marked otherwise.

- **JSC 37461, STS-134 Space Shuttle Mission Report** (Sept 2011): `Reports/Mission Reports/STS-134 Space Shuttle Mission Report.pdf`. Launch time, Appendix A event times, SSME throttle profile and Isp, OMS assist, MECO and ET separation, OMS 2 (TIG, 168.6 s, 259.2 ft/s, 124.3 × 175.8 nmi).
- **STS-134 Ascent Checklist** (ASC/134/FIN): `Ascent Checklists/STS-134 Ascent Checklist.pdf`. MECO VI 25,819; post-OMS-1 and OMS 2 procedures (OPS 105, TRIM LOAD, LOAD, TIMER, MNVR, EXEC).
- **STS-134 MOD FRR, Flight Design and Dynamics** (Mar 2011): `FRR/FDD/STS-134 FRR FDD.pdf`. Insertion 122 nm / 51.6°, DOLILU II, 170 s OMS assist, ascent performance margins (I-load design 1,566 lb, projected 1,107 lb).
- **Space Shuttle Missions Summary** (NASA 20110001406, `20110001406.pdf`, pdf pp. 258-263, STS-134): max-q 733.5 (P) / 733.1 (A) psf; SRB staging 2:04.8; MECO command 8:21.5; VI 25,819 (P) / 25,818 (A); throttle 104.5/72/104.5; FPR 2,821 lb, fuel bias 954 lb; performance enhancements operational high-q, OMS assist, a 52 nmi MECO, Del Psi; post-OMS-2 predicted 175.9 × 124.7. (Its "4,365,726 LBS" is accumulated program cargo, not a liftoff weight.)
- **JSC-19041 SRB Overview** (Rev F, 2003): `Reference/SRB Overview.pdf`, Fig 4.3-I, the RSRM nominal thrust trace.
- **JSC-14483 (78-FM-51) Vol 3, STS-1 Operational Flight Profile, Ascent, Cycle 3**: Table 6.2-I, SRB separation state; §5.2 and fig. 6.2-1, the IA156 aerodynamics along its nominal ascent.
- **STS 83-0002-34, GN&C FSSR, Guidance Ascent/RTLS**: §4.2 DOLILU parameters and uplinks, §4.12 I-load memory layout.
- **STS 83-0013-34, IMU SOP FSSR**: OPERATE runup, discretes.
- **S0007 Vols 1-2 (OMI) and the GLS document** (`Countdown/`): the real countdown's IMU and G9 → G1 schedule.
- **DPS Console Handbook; DPS Dictionary Rev J**: BITE 4 output read-back at OPS transitions.
- **SODB (JSC-08934 Vol 1, Rev E)**: stack geometry; SRB Isp.  Its Fig 6.3.1-2 is the pre-Challenger HPM's thrust, not the RSRM's.
- **PASS OI-34 flight source** (`~/workspace/PFS/OI340600/`): GSRRSL (RSLS), GMESTA (OPS 9 uplink), GUCIMU / GMXGCA / GMESTA (IMU), VG9OPS9 / GO1ASC / FIOGNIPG (OPS transitions), GG31ST / GG42ND (first and second stage), GGOTGT / GGILTV (PEG 4), GZMASC (OMS targeting), CGGCOM / CGGC01 / CGGC13 (I-loads), GPXSRB / GSESRB (SRB separation), CGCUN1 (DAP I-loads), GDRENT (AA sign).
- **Not in the mirror:**
  - spacefacts.de, STS-134: orbiter liftoff mass 121,826 kg.
  - Wikipedia, Space Shuttle external tank: SLWT 58,500 lb inert, LO2 1,387,457 lb, LH2 234,265 lb.
  - The commonly cited ascent drag loss of about 107 m/s.
  - Space-Track: ISS TLEs for 2011 days 135-136 (supplied by the user).
