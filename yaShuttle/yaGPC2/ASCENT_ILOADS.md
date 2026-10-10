# STS-134's flown ascent/abort I-loads (#PCGGCOM)

`tools/sites/sts134-ascent-iloads.json` puts on the volume the part of
STS-134's flown `#PCGGCOM` that the KSC6 tape didn't have and that no launch-day
path supplies.  `#PCGGCOM` is the GN&C compool for ascent and abort guidance,
X'4E4E'-X'50B2'.  `tools/sites/sts134-gnc-iloads.json` left it out because it is
not an OPS 2 csect.

## Where it is

`#PCGGCOM` is resident: it has one copy on the volume, at flat = halfword address
+ 109968, and it is in memory in every major-mode configuration, OPS 9 included.
The PATCH SUMMARY in DASS_G16.ASC (G1) and DASS_G2.ASC (G2) gives the same 506
patched words: an LM value (the generic load module, which is what the tape has)
and an MM value (the flown one).

## The 506 words: what we did with each

The MM column is the flight's **2010 tape build**: launch year 2010, RNP day
225, last year's trajectory tables.  For the words that the launch day itself
sets, that value is older than what the KSC6 tape already holds.
PASS-IDLE's KSC6 volume carries the 2011 launch-day values: the
`examples/flights/sts134-dolilu.json` uplink, written to the tape, and
`sts134-reconfig.json`.  So each variable was sorted per word: does the KSC6 tape
hold the LM value, the MM value, or something else (a launch-day value)?

| Disposition | Variables | Words |
|---|---|---|
| **Patched** (tape = LM everywhere; nothing on the launch day sets them) | P_INT, P_SLP, DEL_CST, V_EO_SW, V_KMAX_DOWN, V_KMAX_UP, TARGET2/4/6/9/10/11/12/14_1, GRNZC1, NZSW1, CGES_OMS_ASSIST_DELAY | 36 |
| Kept: launch-day value already on the tape | PHI, PSI, THET, QPOLY, THROT, WNDE/WNDN_TAB, T_GMTLO_REF, IY_MIN_EF, EF_TRAJ_PLANE_UNIT_NORMAL(_NOM), IYD_OMS, ALTITUDE/THETA, ASSIST_OMS_DT, M_EMPTY, ET_LEVEL_SENSOR_MASS, MASS_ORBITER_LIFTOFF, OMS_CUTOFF_MASS, MBOD_ONE/TWO_MFB, FPA_MECO, FPA_MECO_ATO, TREF_ADJUST, LAUNCH_YEAR, RNP_DAY | most of the rest |
| Kept: DOLILU authoritative (tape = LM, but a GMESTA uplink message covers the word) | DELTA_NODE_PHASE, T_GMTLO_PHASE (op 15); REL_OMS_TIG (op 25); ATO/RTLS/TAL_OMS_DT, MANUAL_OMS_DUMP_TIME, ENTRY_OMS_FUEL_BURN_TIME, OR_INTERCON_INIT/TERM_FU_TIME, CONT_OR_ICNCT_TERM_FU_TIME, FWD_RCS_DUMP_TIMER_OPS1/3, MASS_OMS_LESS_MASS_DVTOL, ATO_PREMECO_K2_LOWLIM, ATO_OMS_RCS_V, ATO_PRE_MECO_OMS_RCS_V, V_MSSN_CNTN (op 37); V_MAG_MECO_ATO (op 96) | 30 |
| Kept: deliberately left at the tape value | CGGS_PPOLY (58), CGGS_DELPLO (4) | 62 |
| Already the flown value | INTERCEPT, V_MAG_MECO | 2 |

The DOLILU uplink ranges come from GMESTA.hal:

| Op | Starts at | Length (hw) | Halfwords |
|---|---|---|---|
| 15 | T_GMTLO_REF | 40 + 8 | 20158-20205 |
| 25 | IYD_OMS | 44 | 20206-20249 |
| 37 | CGSS_OMS_ASSIST | 58 | 20260-20317 |
| 96 | CGGV_FPA_MECO | 8 | 20322-20329 |

Any word in those ranges belongs to the DOLILU, even where the file we send
happens to leave it at the LM value, so it is not patched.  Ops 88
(CGGS_TARGET2_1, 20 hw) and 89 (V_KMAX_DOWN, 4 hw) are messages that
`sts134-dolilu.json` does not send, so their words are patched.
`sts134-reconfig.json`'s cells (V_MAG_MECO_NOM, K_CMD_NOM, RAD_MECO_NOM,
FPA_MECO_NOM, ASSUMED_SSME_FAIL_MET, ROLL_CMD_CHANGE_V, the GSE SEP delays) are in
the OPS 1 overlay (CGGC01 and GSE), not in `#PCGGCOM`, so nothing overlaps them.

### The 17 cells

The values below are tape → flown.  A value written XXXX is a single halfword of
a float.

| Cell | Function (where it's used) | Tape | Flown |
|---|---|---|---|
| CGGS_P_INT (2) | engine-out pitch steering intercept (GGNSSM) | 0.07854, 0.06981 | 0.05, 0.045 |
| CGGS_P_SLP (2) | engine-out pitch steering slope (GGNSSM) | -2.685e-5, -4.028e-5 | -5.55e-5, -5e-5 |
| CGGS_DEL_CST (2) | engine-out steering limit (GGNSSM) | 0.07854, 0.07417 | 0.015, 0.015 |
| CGGS_V_EO_SW (high hw) | engine-out switch velocity (GGNSSM) | 4315 | 4338 |
| CGGS_V_KMAX_DOWN | engine-out throttle-down velocity (GGNSSM) | 12500 | 0 |
| CGGS_V_KMAX_UP | engine-out max-throttle velocity (GGNSSM) | 6500 | 30000 |
| CGGS_TARGET2_1 | RTLS target | 989.18 | 869.85 |
| CGGS_TARGET4_1 | RTLS target | 525.64 | 420.69 |
| CGGS_TARGET6_1 | RTLS target | 2295.55 | 2179.56 |
| CGGS_TARGET9_1 | RTLS target (GO1ASC) | 0.17625 | 0.17447 |
| CGGS_TARGET10_1 | RTLS target | 0.15800 | 0.16044 |
| CGGS_TARGET11_1 | RTLS target | 0.17010 | 0.17268 |
| CGGS_TARGET12_1 (low hw) | RTLS target | 2042 | 1EA9 |
| CGGS_TARGET14_1 | RTLS target | 0 | 6806.71 |
| CGGS_GRNZC1 (low hw) | RTLS g-limit/pullout normal-acceleration constant (GHHPHA) | 0000 | F5C2 |
| CGGS_NZSW1 | glide-RTLS Nz switch (GG9GLI) | 1.65 | 1.71 |
| CGES_OMS_ASSIST_DELAY (high hw) | ascent OMS assist delay (GEAASC) | 41F0 (15 s) | 41A0 (10 s) |

The nominal ascent touches only the last of these.  The rest are engine-out
steering (GGNSSM, the module that also safes an SSME) and RTLS/glide-RTLS
targeting, all idle unless an engine fails.

### Flagged

- **CGGS_PPOLY / CGGS_DELPLO: not patched.**  GG31ST takes the first-stage
  attitude from the THET/PSI/PHI tables, using PPOLY as the relative-velocity
  breakpoints:

  ```
  IF CGGV_REL_VEL_MAG_MFE >= CGGS_PPOLY$(2) ...
  DENOM = CGGS_PPOLY$(CGGV_ATT_INDEX + 1) - CGGS_PPOLY$(CGGV_ATT_INDEX)
  ```

  The flown PPOLY (PPOLY(1) 110.7 → 118.45 …) belongs to the 2010 tables.  The
  tables on the KSC6 tape are the 2011 launch-day ones.  Of THET's 174 words,
  120 are still LM, because rows 2+ are not DOLILU-reachable.  Mixing the 2010
  breakpoints with the 2011 tables would bend first stage in a way no flight
  did.  PPOLY should be patched only together with the THET/PSI/PHI it was built
  for, and that is a trajectory question for PASS-IDLE's first-stage work
  (#278).
- **OMS_ASSIST_DELAY 15 → 10 s** is the one word that changes a nominal ascent.
  STS-134 flew a 170 s OMS assist (ASSIST_OMS_DT 170, DOLILU op 37), starting
  this many seconds after SRB separation.  The flight's +134 is SRB separation
  + 9.3 s.  See the A/B below.
- **The engine-out constants** (P_INT, P_SLP, DEL_CST, V_EO_SW, V_KMAX) **and
  the RTLS targets** matter as soon as an abort is flown.  Fly the abort tests
  on this tape.
- **The OPS 1 overlays** (#PCGG01R, #PCGGC01, #PCGGD01, #PCGGC13, #PCGN13R)
  and the abort D-csects are on `-full2`: see "The OPS 1 abort I-loads" below.
  Still generic: the flight-control overlays #PCGCFL1 and #PCGCUN1.

## Volumes

```
python3 mission_reconfig.py sites/sts134-ascent-iloads.json <KSC6 volume> --out …-ksc6-ascent.mmv
python3 mission_reconfig.py sites/sts134-ascent-iloads.json …-ksc6-gnc.mmv --out …-ksc6-full.mmv
```

| Volume | Built from | SHA-256 |
|---|---|---|
| `~/sts134-runs/ascent/OI340700-v44boot-sts134-ksc6-ascent.mmv` | KSC6 + ascent | `49a8f5afddd6713877b3bcb0548a73985992d47b2587aab37c53e27c98860720` |
| `~/sts134-runs/ascent/OI340700-v44boot-sts134-ksc6-full.mmv` | KSC6 + gnc + ascent | `8c465f35d96bcb86d220d3178ad5f71a88a4665e5293e65d6fecca794beed386` |

The words are resident in memory, so a capture taken on the KSC6 tape holds the
tape values.  Restoring one onto these volumes therefore needs its
`gpc1.mem.bin` patched with the same 17 cells, at byte offset 2 × the
halfword address, with the "was" values checked first.  It also needs
`vehicle.json`'s tape and tapeSha256 changed, or simulatePASS refuses the
restore.  The pad62 IMU, COUNT and TERMINAL captures all held the tape ("was")
values.

## The OPS 1 abort I-loads (-full2, 2026-10-10)

`tools/sites/sts134-abort-iloads.json` puts STS-134's flown values on 5,762
halfwords in 2,210 cells.  The source is DASS_G16.ASC's PATCH SUMMARY: every
word whose tape value is the generic one and whose flown value differs.  The
cells sit in seven load blocks: six in the G1/G16 loads, one in G3.

```
python3 mission_reconfig.py sites/sts134-abort-iloads.json …-ksc6-full.mmv --out …-ksc6-full2.mmv
```

| Volume | Built from | SHA-256 |
|---|---|---|
| `~/sts134-runs/ascent/OI340700-v44boot-sts134-ksc6-full2.mmv` | full + abort | `a4c7670355f9b5840b8ce561fada8322e63b20af97f7abe433b266e531509bc8` |

**The landing-site table #PCGN13R was blank on the tape.**  Its slots held
spaces and zeros: no runway had a latitude, longitude or azimuth, so a TAL or
RTLS had nowhere to go.  The flown table has 90 runways (lat/lon in degrees,
heading in degrees, length in feet):

| Slots | Site | Runways | Lat | Lon | Length |
|---|---|---|---|---|---|
| 1-2 | Kennedy (KSC) | 15, 33 | 28.6 N | 80.7 W | 15,000 |
| 3-4, 23-24 | Ben Guerir (BEN) | 36, 18 | 32.1 N | 7.9 W | 13,720 / 13,220 |
| 5-6, 25-26 | Morón (MRN) | 20, 02 | 37.2 N | 5.6 W | 11,729 |
| 7-8, 27-28 | Zaragoza (ZZA) | 30, 12 | 41.7 N | 1.1 W | 12,197 |
| 9-22, 29-44 | East Coast abort landing sites | MYR ILM NKT NTU WAL DOV ACY FOK FMH PSM YHZ YJT YYT YQX YYR | | | |
| 45-60 | Other overseas sites | Lajes (LAJ), Beja (BEJ), Keflavik (IKF), Shannon (INN), Fairford (FFA), Köln-Bonn (KBO), Istres (FMI), Esenboğa (ESN) | | | |
| 61-90 | Pacific and western sites | KKI JDG AMB PTN JTY GUA WAK HNL EDF HAO EDT HAW NOR EDW | | | |

The TAL sites for STS-134's 51.6° flight are therefore Zaragoza, Morón and
Ben Guerir.  The table also carries the MLS and TACAN tables, and these
indexes:

- CGGS_TARGET_INDEX: 0x000A.
- CGNS_ALTERNATE_SITE_1: 0x0013 and 0x002A.
- CGNS_ALTERNATE_SITE_2: 0x0015.

Both copies are patched.  G16's copy is at load block @1087488 (flat =
address + 890,078).  G3's is entry's (flat = address + 1,130,718): a TAL's
OPS 304 keeps the OPS 1 site index, so the runway has to be in G3 as well.

For the G3 copy, the values come from DASS_G3's own patch summary, and only
words that still hold the blank tape value are written.  The 82 words
landing_sites.py wrote from ksc.json are left alone: KSC 15/33 in slots 1-2
and their MLS and TACAN entries.  Outside those, G3's flown table differs from
G16's in only 9 words.

landing_sites.py's docstring says the tables are blank in the DASS dumps.
They are blank in the listings' symbol sections, but each listing's PATCH
SUMMARY carries the flown table.

**The guidance overlays.**  The cells cover the RTLS PPA and fuel-dissipation
constants, the RTLS targets in #PCGG01R, and the ATO OMS-1/2 targets and
switch velocities (#PCGGD01).  They also cover the TAL g-limits,
CGGS_V_RHO_TAL, the yaw-steering velocities and the contingency constants
(#PCGGC01), and the second-stage and engine-out limits (#PCGGC13).

Left out:

- The cells sts134-reconfig.json already sets, and the ones the launch day
  replaced.
- CGGS_P_Y_INDEX_CHG_LIMIT, which belongs with the 2011 first-stage tables.
- **CGGB_EF_PLANE_SW.**  It flew OFF: an inertial target plane, rotated for
  nodal regression from #PCGGCOM's CGGS_T_GMTLO_REF (flown 18,186,605 s, day
  210, which is the 2010 build's launch date).  That plane is a launch-day
  product.  The tape's ON flies to the earth-fixed plane, which is the ISS's.
  A first -full2 that had the flown OFF went wrong in all three aborts: just
  after SRB SEP, second stage pitched up 25° and the stack fell back, with
  hdot -250 ft/s at MET 215 against +1,000 nominal.  The cause was bisected
  from the T-8 capture in three rounds: all of C01 (99 cells), then the
  quarters, then this one cell.
- #PCGGC13's second copy, in G3 (flat = address + 1,135,264).

**The D-csects** (G1):

| Cell | Tape | Flown |
|---|---|---|
| GSS_DT_DRY (LO2 low-level cutoff delay, no engine out) | 1.918 s | 0.238 s |
| GSS_RTLS_DT_DRY, GSS_PTM_DT_DRY | 2.6, 2.598 s | 0 |
| GSS_RTLS_LH2_LL_DELAY, GSS_NOM_LH2_LL_DELAY | 2.3, 1.1 s | 0 |
| GSS_FS_ZERO_THRUST_DLY | 5.7 s | 3 s |
| GSS_PRVL_CL_DELAY_TIME | 4.9 s | 4.442 s |
| CGSS_RTLS_{SIDESLIP,ROLL,YAW,PITCH}_LO/HI (ET SEP inhibit) | ±2, ±5, ±0.5, −5 | ±20 |
| CGSS_RTLS_ANG_ATK_HI | −2° | −2.8° |
| CGSS_ETSEP_INH_TIME | 1.7 s | 2.19 s |
| CGGS_TAL_MASS_SSME_TRIM | 19,500 | 14,700 |
| CGGS_K_CMD_STG2 | 106 | 104 |
| CGNS_DRAG_CONST_RTLS | 0.2226 | 0.1822 |
| GSQ_STP_VENT_CMDS_DELAY | 4.96 s | 2.56 s |
| #DGG9GLI, #DGHHPHA | glide-RTLS alpha and Nz-hold constants | |

Left out:

- #DGG31ST: first stage, coupled to the launch day.
- #DGSRRSL: RSLS countdown timing.
- #DGSESRB: already holds the flown values.

**Placement.**  Every cell is placed by its flat position on the volume, and
each position is checked against the tape value before it is written.  Each
csect's single copy was found from a ±32-halfword context and then checked
over the csect's whole range against the OPS 1 terminal capture.  A context
search (`--mem`) does not work here: blank neighbourhoods matched zeros all
over the volume, and a dry run would have written into some 200 blocks.

**Captures.**  An OPS 9 capture made before OPS 101 can fly on -full2 once its
`vehicle.json` is retagged, because OPS 101 reads G1/G16 from the volume.  The
abort re-flights below start from a copy of asc-C's `sts134-imu`, retagged
(the copies carry `RETAGGED.txt`).

## A/B (2026-10-10)

Every arm was flown with `fly_sts134.py`, headless, at rate 1:

- **A:** the KSC6 tape, resumed from the pad62 `sts134-terminal` capture (T-8 s).
- **B:** the `-ascent` volume, the same capture with its memory patched.
- **C:** the `-full` volume, from the pad62 `sts134-imu` capture.  C goes
  through a fresh OPS 101 keyed from tape, the count, and on through OMS-2,
  then OPS 106 and OPS 201 (GNC UNIV PTG came up).

Times are from SRB ignition.  Orbits are osculating, above the equatorial
radius.  The actual post-OMS-2 orbit, 175.8 × 124.3 above the mean radius, is
171.9 × 120.4 above the equatorial radius.

| | STS-134 actual | PASS-IDLE jets-asc | A: KSC6 | B: +ascent | C: full, fresh OPS 101 |
|---|---|---|---|---|---|
| max-q | 733.1 psf at +60.0 | ~680 at ~+52.9 | 680 at +52.9 | 680 at +52.9 | 677 at +54.8 |
| throttle bucket | 72%, +39.5 to +51.3 | | **78%**, +39.6 to +51.2 | **78%**, +39.6 to +51.2 | **72%**, +39.0 to +50.8 |
| SRB separation | +124.72 | +124.80 | +124.80 | +124.80 | +124.80 |
| OMS assist | +134 to +300.5 | | ≈+139.9 to +309.9 | **+134.88 to +305.04** | (flown delay, as B) |
| MECO command | +501.1 | +501.72 | +501.72 | +501.72 | +502.24 |
| VI after the tailoff | 25,819 | | 25,823 | 25,824 | 25,816 |
| post-MECO orbit | (insertion 122 nm) | 127.0 × 26.2 | 126.8 × 26.7 | 127.2 × 26.8 | 119.6 × 26.6 |
| ET separation | +522 | +522.96 | +522.96 | +522.96 | +523.44 |
| OMS-2 design | 259.2 ft/s, 168.6 s | | 269.4 ft/s | 270.1 ft/s; burned 163.7 s | 264.6 ft/s |
| after OMS-2 | 171.9 × 120.4 | 173.0 × 121.8 | 173.0 × 121.3 | 173.1 × 121.3 | 171.2 × 120.9 |

Notes on the rows:

- **OMS assist.**  B's times come from vehdyn's OMS trace
  (`YAGPC_VEHDYN_TRACE=1`).  A ran without the trace, so its times come from
  the mass: B is 87 kg lighter from +142.9 to +302.9, which is 5 s of two OMS
  engines, and the two match again by +312.9.
- **VI after the tailoff** is the truth \|v\| at MECO + 6 s.

**What the flown `#PCGGCOM` moves.**  It moves the OMS assist start, from SRB
separation + 15 s to + 10 s: +134.9 against the flight's +134.  The assist
still runs 170 s, as ASSIST_OMS_DT says.  Nothing else in a nominal ascent
moves:

- MECO, SRB separation, ET separation and the throttles are identical to the
  0.01 s.
- Insertion and the post-OMS-2 orbit agree to 0.4 nmi.

So it is a step toward the flight, but a small one.  It does not explain #278
(max-q low) or #279 (MECO late).  Those belong to the first-stage tables and
the 3-g throttling, not to these words.  The engine-out and RTLS words only
act in an abort.

**#281 shows up here too.**  Both terminal-capture resumes (A, B) flew a 78%
bucket.  C, through a fresh OPS 101 and count, flew the flight's 72%, with
throttle-down at +39.0 against +39.5.  C's insertion (119.6 × 26.6) and
post-OMS-2 orbit (171.2 × 120.9) are the nearest of the three to the flight's
122 nm insertion and 171.9 × 120.4.  For anything that compares trajectories,
start from `sts134-imu` (`--from COUNT`), not from `sts134-terminal`.

**OPS 101 and OPS 201 on the full volume.**  C's OPS 101 came up: the GPC
accepted the LPS GMTLO at 12:41:20.  OPS 201 came up too.  The 17 words held
their flown values in C's OPS 2 capture.  A's OMS-2 capture still has the
tape values, as it should.

## First aborts (2026-10-10)

These runs used PASS-IDLE's `YAGPC_SSME_FAIL` (origin review/vern-ssme
6cfa42d, merged only into a local test build: none of it is in this branch).
Each one:

- failed engine 2 at the time shown after SRB ignition;
- 5 s later, played a crew script: ABORT MODE to the mode, ABORT pressed,
  ABORT MODE back to OFF;
- flew the `-full` volume, from arm C's T-8 s capture, with its 72% bucket;
- was flown `--to ASCENT`.

The boundaries are the Missions Summary's: NEG RETURN 3:54, PRESS TO ATO
4:57.  The abort flags were read from PASS memory in each run's ET-separation
capture: CGEB_FLT_LG2_FLAG1_HFE, CGRB_RM_FLAG_3 and CGOV_MMODE_CUR_HFE,
addresses from DASS_G16.

| Abort | Failure | What PASS did | Outcome |
|---|---|---|---|
| RTLS | E2 at +150 (106% → 0) | The failure was detected.  E2's prevalves closed at +155.7 (LO2) and +160.6 (LH2).  E1/E3 went to 104.5%.  The rates held after a transient of about 2°/s.  Fuel dissipation lasted to the **powered pitch-around at about +305** (alpha -32 → -127). | **No MECO and no ET separation.** After the pitch-around the stack came down: 342 kft at +323, 203 kft at +503 (\|v\| inertial 2,600), and **54 kft at +623 with q 800 psf** while still under thrust.  The propellant ran out at about +670 with no MECO command, and the stack was falling through 84 kft when the run was stopped. |
| TAL | E2 at +265 | TAL was declared.  RM_FLAG_3 saved the switch position as TAL. | **Loss of control.**  From +283 the yaw rate built up and stayed at 2.9°/s, beta reached -50° and alpha -140° to -170°.  The vehicle fell.  PASS ended up with the RTLS flag set and **MM 602**.  MECO came at +590 at 16 kft. |
| ATO | E2 at +330 | ATO was declared (ATO_FLAG and AOA_ATO_ACT on).  Control held through the roll to heads-up. | MECO command at +574.76, **with the LO2 gone** (0 kg LO2 and 433 kg LH2 at ET separation, +595.9).  VI 25,399.  Orbit 58.6 × -134.6 nmi, so the OMS would have to make up the rest.  The run stopped in MM 104 at ET separation. |

So the engine-out path itself works.  The failure is detected, the prevalves
close, the throttles go up and the abort is declared.  What follows does not
work yet: none of the three reaches a credible MECO.  The suspects, in the
order I would check them:

1. **The OPS 1 overlay I-loads are still the generic tape's.**  #PCGGC01,
   #PCGGD01, #PCGG01R and the others (see "Not covered" above) hold the
   abort-specific targets: the TAL landing sites and their runway data, RTLS
   PPA and MECO targets beyond CGGS_TARGETn, and the ATO MECO targets.  A TAL
   site that doesn't belong to a 51.6° flight would explain a yaw maneuver
   held at the rate limit.
2. **Propellant and level sensors.**  The ATO ran the LO2 dry, and the RTLS
   burned to depletion with no MECO.  PASS's low-level cutoff needs the ET
   LO2/LH2 level sensors (GSSSSM's sensor-disable logic), and it is not clear
   that vehdyn drives them.
3. **The ascent DAP with one engine out.**  Pitch and yaw rates of 2-3.5°/s
   came right after every failure.  The failed engine's actuators sat at
   +3°/+3° afterwards.

Logs: `~/sts134-runs/ascent/abort-{rtls,tal,ato}/` (the failure line is
`eiu: ME2 FAILED`; the crew script is `abort.script`).

## Aborts on -full2 (2026-10-10)

The test-only build was origin/master plus PASS-IDLE's review/vern-ssme
(YAGPC_SSME_FAIL) and review/et-lowlevel (the ET low-level sensors; 2476016,
then e048a6b).  Every run was a fresh `--from COUNT`, headless, at rate 1,
with `fly_sts134.py --abort MODE`: the crew's ABORT MODE and ABORT pb 5 s
after the failure.  Times are after SRB ignition.  Logs are in
`~/sts134-runs/ascent/abort2-rtls`, `abort3-ato` and `abort4-tal` (TAL resumed
from abort3-ato's T-8 s capture: three fresh `--from COUNT` TALs hung at
OPS 101, GNC OPS 0 after the fourth mass-memory read; see below); the DAP
CSVs are in the dropbox, `ascent-aborts/`.

| | RTLS: ME2 at +150 | TAL: ME2 at +265 | ATO: ME2 at +330 |
|---|---|---|---|
| MECO | +671.2, guided (PPA) | +595.8, guided | +574.4, **low level** |
| ET left at SEP | 12,851 kg LO2, 2,575 kg LH2 (~2.1%) | 10,467 kg LO2, 2,177 kg LH2 | 815 kg LO2, 569 kg LH2 |
| ET SEP | +688.5 | +617.0 | +595.6 |
| After | glide RTLS to KSC; touchdown 262 kt, 11 ft/s, gear locked 0.3 s before | OPS 3 → MM 304, controlled entry; came down short, near 34.1 N 9.4 W (about 260 km NW of Ben Guerir), stalled from 12.8 kft, no gear | 57 × −106 nmi: underspeed |

- **Low-level cutoff (ATO, e048a6b).**  The LO2 trip came at 3,500 lb, then
  PASS's MECO 92 ms later: the K_CMD > 67 immediate path, GSSSSM.hal 127K.
  The engines stopped with 815 kg of LO2 left.  On 2476016, with the trip at
  1,500 lb, the shutdown ran the LO2 dry.
- **ATO is short of propellant.**  It is the only abort here that ends at a
  low-level MECO instead of guidance's target.  The open question is
  performance: the ATO targets, the OMS dump/assist, and vehdyn's propellant.
- **RTLS** flies the whole profile: powered pitch-around, PPA, MECO with RTLS's
  2% residual, ET SEP, glide RTLS (MM 602/603), TAEM and approach to KSC.  It
  came in fast, at 330 kt at 800 ft, and touched down hard with the gear just
  locking (the driver puts the gear down at 300 ft wheel height).
- **TAL** needs the crew's OPS 3 straight after ET SEP.  PASS stays in OPS 1
  (MM 104), which flies no aerosurfaces: without OPS 3 the orbiter tumbled
  at about 220 kft, 4-5 minutes after ET SEP.
  - From MM 104, OPS 3 0 1 PRO goes straight to MM 304 (ENTRY TRAJ).
  - The OPS 301 GPC MEMORY table followed by OPS 3 0 4 PRO stayed on 1041.
  - G3 has to come from mass memory (G3_FROM_MM).  The upper-memory archive
    holds the G3 of the volume the capture was taken on, without the TAL
    runways.
  - With all three in place, MM 304 came up 40 s after ET SEP.  Entry pulled
    out at about 210 kft at alpha 40-50, and PASS flew toward Morocco.  It
    arrived low on energy: 390 kt at 12.8 kft about 260 km short (the
    position is approximate, from the M50 state), then slowed and fell.
  - Still open: which TAL site PASS chose, the energy shortfall, and the
    runway height.  vehdyn's ground is KSC's 8.3 ft unless
    YAGPC_GROUND_ALT_FT is set, and setting it (1,034 ft for Zaragoza) did
    not get past the OPS 101 hang.
- **The OPS 101 hang.**  Three fresh-COUNT TALs, one ATO and two short tests
  stopped at vehicle t ≈ 57 s, on both test builds and on both -full2
  versions.  The panels went to GNC OPS 0 after the fourth MM read.  A
  repeat of a configuration that had worked minutes earlier also hung, so
  the cause is not one volume or setting.  Not investigated further.
