# STS-134 launch to orbit: the simulated timeline

This is the flight being flown in yaGPC2: one GPC running PASS OI-34 (tape
`OI340700-v44boot` with STS-134's OPS 1 overlay I-loads), from IPL on LC-39A
to the orbit after OMS 2.

**T = 0 is SRB ignition** (the MECs fire SRM IGNITION; the hold-down posts let
go). STS-134's was **136/12:56:27.994 GMT** on 2011-05-16 (JSC 37461,
Appendix A). The simulated vehicle's clock is set so that its T−0 comes at
**136/12:56:28**.

Each row says who acts:
- **CREW**: keystrokes on CRT1/KB1, or panel switches and pushbuttons.
- **GROUND**: LPS countdown commands on the launch data bus, or uplinks
  through the NSP.
- **SIM**: the simulation itself, such as the vehicle clock and the starting
  state.
- **PASS**: the flight software's own actions, shown for orientation. Nobody
  supplies these.

The whole sequence is scripted by `discretePanel/examples/flights/fly_sts134.py`.

## Sources of the times

| Phase | Where the times come from | Notes |
|---|---|---|
| Pre-launch | The flight now running (run `sts134`, panel and yaGPC2 logs) | Accurate to about ±10 s. The pre-launch timetable is *ours*: STS-134's real countdown spread these activities over a day (S0007 and the GLS document; see References). |
| Terminal count and ascent | The last tuned flight, run `tl1` | Flown from a T−15 s capture with every STS-134 load in place. MECO landed on target. |
| OMS 2 | Run `oms2a` | Flown from `tl1`'s post-ET-separation capture. |
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
| GROUND | **15** launch targeting | T_GMTLO_REF 11,796,988 s (136/12:56:28). IY_MIN = IYD = IYD_NOM = (0.75321, −0.21645, −0.62115): the 51.6° plane through the nav base, heading north-east, Earth-fixed (inertial azimuth 44.95°). DELTA_PSI etc. are 0. | 51.6°: MOD FRR FDD p3 and JSC 37461. The geometry is this work's. Convention checked against the tape's own 38° vector. |
| GROUND | **12** yaw table PSI(30) | The tape's table turned by −18.71°, ending at the 51.6° azimuth (PSI = tan(ψ/4), GG31ST step 16) | Tape values plus the azimuth above |
| GROUND | **13** pitch table THET(1,30) | The tape's pitch-over scaled by 0.75. The simulated stack then reaches STS-1's SRB-separation state: 167,274 ft, Vrel 4,187 ft/s, γ 34.9°. | STS-1 OFP (JSC-14483 Vol 3) Table 6.2-I. Calibrated on the simulated vehicle, as the real DOLILU was for the real one. |
| GROUND | **40** roll table PHI(15) | The same turn at liftoff, blended out by heads-down (180°) | |
| GROUND | **14** QPOLY, TREF | QPOLY = 55, 935, 1100, 10000 ft/s: the simulated vehicle's Vrel at STS-134's throttle times. TREF_ADJUST = 22.5 s, its time to 488 ft/s, so adaptive throttling stays off. | JSC 37461 Appendix A: 104.5% at T+4.1, 72% at T+39.5, 104.5% at T+51.3 |
| GROUND | **39** THROT | 104, 72, 104, 104 (INTEGER, so 104 stands in for 104.5) | JSC 37461 (SSME section, Appendix A) |
| GROUND | **96** MECO pseudo targets | VDMAG 25,819 ft/s; GAMD 0.5° (the tape's) | STS-134 Ascent Checklist (ASC/134/FIN): MECO "√VI = 25819" |
| GROUND | **37** OMS assist and masses | ASSIST_OMS_DT 170 s. MASS_ORBITER_LIFTOFF 8,347.7 slug. MASS_VEHICLE_ET 60,570.6 slug (orbiter + SLWT + 1,621,722 lb propellant). The rest is the tape's own 58 halfwords. | MOD FRR FDD p26: "170 sec OMS Assist". Masses: as above. |
| GROUND | **25** OMS targeting | IYD_OMS(1,2) = the STS-134 plane. OMS 1 is the tape's (not flown). **OMS 2: DTIG 1,756 s after ET separation, HT 175.8 nmi, θT 4.14°, C1 0, C2 0.** | TIG: JSC 37461, ET sep at MET 8:42 and OMS-2 TIG at MET 37:58. Targets designed with `omstarget.py` (PASS's GGOTGT + GGILTV) on the simulated post-MECO orbit, for STS-134's 124.3 × 175.8 nmi. |

Not uplinkable, so they are on the tape instead (`yaGPC2/tools/mission_reconfig.py` with `sts134-reconfig.json`, OPS 1 overlay):

| Cell | Tape | STS-134 | Data source |
|---|---|---|---|
| CGGS_V_MAG_MECO_NOM | 25,668 | **25,819** ft/s | Ascent Checklist |
| CGGS_K_CMD_NOM | 100 | **104**% | JSC 37461: 104.5% to the 3-g throttling |

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

| T | GMT | Who | Event | Data source |
|---|---|---|---|---|
| ≈ −0:23:12 | ≈ 12:33:16 | CREW | `OPS 101 PRO`: terminal count; the G9 → G1 transition | GLS doc: G9 → G1 at the T−20 hold |
| ≈ −0:22:30 | ≈ 12:33:58 | GROUND | `gmtlo =11796988` (GMT of liftoff 136/12:56:28), then `resume` | LPS commands 9 and 4 (lpsmodel.c) |
| −0:04:30 | 12:51:58 | PASS | RSLS: IMU platform release; the IMUs go inertial (REFS_RDY) | I-load CGSV_T_IMU_INERT −270 s (GSRRSL.hal:373). The FSSR and GLS give T−240 s. |
| −0:00:48 | 12:55:40 | PASS | LO2 POGO recirc valves PV20/21 OPEN (after GO AUTO) | |
| −0:00:47 | 12:55:41 | GROUND | `go_auto`: GO FOR AUTO SEQUENCE | Real GLS: T−31 s |
| −0:00:34 to −0:00:14 | | PASS | Vent doors open, groups 2, 5, 3, 1, 6 | |
| −0:00:27 | 12:56:01 | GROUND | `go_engine`: GO FOR ENGINE START | |
| −0:00:17.8 | | PASS | MEC: T-0 UMBILICAL and SRM IGNITION ARMED | |
| −0:00:15 | | SIM | Capture `sts134-count` (for re-flying the ascent) | |
| −0:00:10.8, −0:00:09.2 | | PASS | SSME commands 6A00 and 8F00 (start preparation / start enable) | |
| −0:00:08.3 | | PASS | LH2 prevalves PV4-6 OPEN | |
| −0:00:07.3 | | PASS | LO2 overboard bleed PV19 CLOSED | |
| **−6.56 / −6.44 / −6.32 s** | | PASS | **SSME 3, 2, 1 start commands.** STS-134: −6.555 / −6.430 / −6.317 s. | JSC 37461 App. A |

### Ascent (PASS, MM 102 → 103 → 104)

| T | Event | STS-134 actual (JSC 37461) |
|---|---|---|
| **0.00** | **SRM IGNITION fired; liftoff (hold-down posts released)** | 136/12:56:27.994 |
| +0.04 | T-0 umbilical fired | |
| +4.5 | Throttle up to 104% | 104.5% at +4.1 |
| ≈ +7 to +20 | Roll program to heads-down, azimuth about 46° | |
| +40.0 | Throttle down for max-q. **87%**: adaptive throttling raised the 72% I-load. | 72% at +39.5; AGT not activated |
| +47.0 | Throttle up to 104% | +51.3 |
| ≈ +62 | Max-q, about 810 psf | Max-q at +60 |
| +128.0 | MEC: SRB SEPARATION ARMED | |
| **+129.8** | **SRB separation** (50 psia cue). The state is 176k ft, 4,322 ft/s relative, γ 35.7°. | Sep command +125. STS-1: 167k ft, 4,187 ft/s, γ 34.9° |
| +130.1 | 106% (K_CMD_STG2) | |
| ≈ +134 to +304 | OMS assist, both engines, 170 s | +134 to +300.5 (164.2 s) |
| +218.4 | 104% (K_CMD_NOM, from the tape reconfiguration) | |
| +446.9 to +508.0 | 3-g throttling, 100% → 65% | 3-g throttle-down from +440; 67% at +494.7 |
| **+514.0** | **MECO command** (guided). VI = **25,818 ft/s** (target 25,819); 2.6 t of LO2/LH2 left. | **MECO +501**; Ascent Checklist VI 25,819 |
| +516.3 to +524.0 | LO2/LH2 prevalves closed; ET umbilical latches open; 17-inch disconnects closed | |
| +528.0 | MEC: ET umbilical unlatch fired | |
| **+535.3** | **ET separation**. Orbit 43.5 × 133.9 nmi (above the equatorial radius). | ET sep +522 |

### OMS 2 (MM 105). The crew's actions are from the STS-134 Ascent Checklist (ASC/134/FIN), pp. 3-3 to 3-7 and the OMS 2 cue cards.

| T | MET | Who | Event |
|---|---|---|---|
| +1,135 | 0:18:55 | CREW | `dap c3 auto` (C3 DAP – AUTO) |
| +1,141 | 0:19:01 | CREW | `OPS 105 PRO` (MAJOR MODE CHANGE: CRT1 GNC, OPS 105 PRO) |
| +1,161 | 0:19:21 | CREW | TRIM LOAD: `ITEM 6 +0.4 −5.7 +5.7 EXEC` |
| +1,166 | 0:19:26 | CREW | LOAD: `ITEM 22 EXEC` |
| +1,171 | 0:19:31 | CREW | TIMER: `ITEM 23 EXEC` |
| +1,181 | 0:19:41 | CREW | MNVR: `ITEM 27 EXEC` (maneuver to burn attitude) |
| — | — | SIM | OMS engines ARM/PRESS (`YAGPC_OMS_ARMED=1`; the checklist's TIG−2 switch) |
| +2,283 | 0:38:03 | CREW | `EXEC` at TIG−8 s |
| **+2,291** | **0:38:11** | PASS | **OMS 2 ignition.** Display before the burn: ΔVTOT 252.7 ft/s, TGT HA 170 / HP 126 (PASS's reckoning). STS-134: ignition MET 0:37:58, 168.6 s, 259.2 ft/s. |
| ≈ +2,590 | ≈ 0:43:10 | SIM | Capture `sts134-oms2` |

### Result: the orbit after OMS 2

| | Simulated (truth, osculating) | STS-134 (JSC 37461) |
|---|---|---|
| Apogee × perigee | **176.8 × 128.0 nmi** above the equatorial radius (180.5 × 131.6 above the WGS-84 ellipsoid) | **175.8 × 124.3 nmi** |
| Inclination | **51.53°** to the equator of date | **51.6°** |
| OMS 2 ΔV | 252.7 ft/s (PASS display) | 259.2 ft/s |

Osculating apsides move by a few nmi around an orbit (J2). The figure to compare is an orbit's average, which the ORBIT phase logs.

## Derived data and how it was obtained

| Data | How | Where |
|---|---|---|
| Plane normal IYD | The 51.6° plane through the nav base at the inertial azimuth asin(cos i / cos φc) = 44.95°, as IY = d × r̂ in PASS's Earth-fixed frame | Checked on the tape's 38° I-load: (0.5073, −0.3488, −0.7880) against the tape's (0.5172, −0.3339, −0.7880) |
| Yaw/roll tables | The tape's tables turned by the azimuth difference (63.66° → 44.95°) | GG31ST.hal step 16 |
| Pitch table | Scaled 0.75 in pitch-over, by flight against the STS-1 SRB-separation state | STS-1 OFP Table 6.2-I |
| QPOLY, TREF | Read off the simulated vehicle's Vrel at the report's throttle times | JSC 37461 App. A |
| OMS 2 HT, θT | `omstarget.py`: PASS's PEG 4 target geometry (GGOTGT) and linear-terminal-velocity constraint (GGILTV), ported, solved for HP 124.3 / HA 175.8 at the fixed TIG | |
| Gimbal pitch sense | −1 for SSMEs and SRBs. With +1 the loop diverged at liftoff. | vehdyn.c |
| AA normal axis | Positive up (−Z) | GDRENT.hal:107 (LOAD = AA_NORM × g0); NZREF table (CGCUN1.hal) |
| Stack aerodynamics | Synthesized: no data in the documents; STS 85-0118 is missing. Axial force gives about 350 ft/s (107 m/s) drag loss. Normal force is sized to the DAP's NZREF. | vehdyn.c |
| SSME tail-off | 0.958 s at full thrust | PASS's own CGGS_T_TAILOFF (GG42ND step 87) |
| SRB thrust | Nominal RSRM at 60 °F | SODB Fig 6.3.1-2 |
| SRB chamber-pressure words | 914 psia scaled by thrust, through PASS's calibration | GPXSRB.hal; GSESRB.hal |

## Known differences from STS-134

- **Throttle commands have 1% resolution.** 104.5% is flown as 104, so the vehicle is about 0.5% down on SSME thrust.
- **Adaptive guidance throttling engaged** (bucket 87%), where STS-134's did not. TREF_ADJUST is calibrated to an earlier flight of the model.
- **MECO is 13 s later than STS-134's** (+514 against +501).
- **The pre-launch timetable is compressed into 85 minutes.** The real one spanned the day before launch (S0007: IMU power-up at L-27h30m; OPERATE and ATT DET by L-8h20m; gyrocompass about 42 min). GO FOR AUTO SEQUENCE comes at T−47 s, not the GLS's T−31 s.
- **The crew's post-MECO procedures are abridged to what the flight needs.** Omitted: MPS dump, APU shutdown, ET umbilical doors.
- **The MECO radius and flight-path angle are the tape's** (60 nmi, 0.5°). No STS-134 values were found.

## References

All are in the local ibiblio mirror (`~/Desktop/sandroid.org/public_html/apollo/Shuttle/`) unless marked otherwise.

- **JSC 37461, STS-134 Space Shuttle Mission Report** (Sept 2011): `Reports/Mission Reports/STS-134 Space Shuttle Mission Report.pdf`. Launch time, Appendix A event times, SSME throttle profile and Isp, OMS assist, MECO and ET separation, OMS 2 (TIG, 168.6 s, 259.2 ft/s, 124.3 × 175.8 nmi).
- **STS-134 Ascent Checklist** (ASC/134/FIN): `Ascent Checklists/STS-134 Ascent Checklist.pdf`. MECO VI 25,819; post-OMS-1 and OMS 2 procedures (OPS 105, TRIM LOAD, LOAD, TIMER, MNVR, EXEC).
- **STS-134 MOD FRR, Flight Design and Dynamics** (Mar 2011): `FRR/FDD/STS-134 FRR FDD.pdf`. Insertion 122 nm / 51.6°, DOLILU II, 170 s OMS assist, propellant loads.
- **JSC-14483 (78-FM-51) Vol 3, STS-1 Operational Flight Profile, Ascent, Cycle 3**: Table 6.2-I, SRB separation state.
- **STS 83-0002-34, GN&C FSSR, Guidance Ascent/RTLS**: §4.2 DOLILU parameters and uplinks, §4.12 I-load memory layout.
- **STS 83-0013-34, IMU SOP FSSR**: OPERATE runup, discretes.
- **S0007 Vols 1-2 (OMI) and the GLS document** (`Countdown/`): the real countdown's IMU and G9 → G1 schedule.
- **DPS Console Handbook; DPS Dictionary Rev J**: BITE 4 output read-back at OPS transitions.
- **SODB (JSC-08934 Vol 1)**: stack geometry; RSRM thrust and Isp.
- **PASS OI-34 flight source** (`~/workspace/PFS/OI340600/`): GSRRSL (RSLS), GMESTA (OPS 9 uplink), GUCIMU / GMXGCA / GMESTA (IMU), VG9OPS9 / GO1ASC / FIOGNIPG (OPS transitions), GG31ST / GG42ND (first and second stage), GGOTGT / GGILTV (PEG 4), GZMASC (OMS targeting), CGGCOM / CGGC01 / CGGC13 (I-loads), GPXSRB / GSESRB (SRB separation), CGCUN1 (DAP I-loads), GDRENT (AA sign).
- **Not in the mirror:**
  - spacefacts.de, STS-134: orbiter liftoff mass 121,826 kg.
  - Wikipedia, Space Shuttle external tank: SLWT 58,500 lb inert, LO2 1,387,457 lb, LH2 234,265 lb.
  - The commonly cited ascent drag loss of about 107 m/s.
