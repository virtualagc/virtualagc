# STS-134 deorbit to wheels stop: the simulated timeline

This is the second half of the flight in `TIMELINE-STS134.md`: the same
single GPC running PASS OI-34, from the orbit after OMS 2 through the deorbit
burn, entry, TAEM, approach and landing on KSC 15 to wheels stop.  The volume
is `OI340700-v44boot-sts134-ksc6.mmv`: the STS-134 OPS 1 overlay plus the KSC
site and four G3 I-load cells (see "Sources of the times").

**This is not STS-134's entry.**  STS-134 landed on KSC runway 15 at
152/06:34:50 GMT, after 15 days 17 hours (JSC 37461 p15).  The simulation
deorbits on flight day 1.  The ground takes the first pass after the ORBIT
capture that comes within 550 nmi crossrange of KSC 15 (`deorbit_target.py`
defaults: REI 4,350 nmi, TIG to EI 30 min).  The orbit, the weight and the
cargo differ from the real landing, so the real flight is shown only where
its own report gives a number to set beside ours.

**T = 0 is the deorbit burn's TIG**, 136/20:05:38.733 GMT.  As the crew keyed
it, that is MET 0/07:09:10.7, counted from STS-134's own liftoff
(12:56:27.994; the run's SRB ignition was 12:56:27.81).
- **Entry interface (EI)**: the ground planned it for 136/20:35:38.852
  (TIG+30:00.12).  The truth crossed 400,000 ft at **20:35:48.20
  (TIG+30:09.47)**.
- **Main gear touchdown**: 136/21:07:07.67 (TIG+1:01:28.94).

**The clock.**  The logs' `t` is the vehicle clock in seconds.  In this run
**GMT = 136/11:30:28.292 + t**, not 11:30:00 + t.  This comes from the `gmt=`
field of every `vehdyn-state` line, constant to 1 ms from t = 70 to
t = 34,655.  Each capture's `gmtUnix` agrees: `sts134-land`'s 1305580081.704
is 21:08:01.704 at t = 34,653.413.

Each row says who acts:
- **CREW**: keystrokes on CRT1/KB1, the CRT 2 edge keys, or panel switches
  and pushbuttons.
- **GROUND**: Mission Control's deorbit targets.  Here they are read up and
  keyed by the crew.
- **SIM**: the simulation itself.  This means events the truth model logs
  (gear, touchdown, chute) and the captures.
- **PASS**: the flight software's own actions, shown for orientation.  Nobody
  supplies these.

The whole sequence is scripted by `discretePanel/examples/flights/fly_sts134.py`.
The checklist citations below (ENT/ALL/GEN H, ENT/134/FIN) are the driver's.
The reference flight is **`~/workspace/pass-run/full-ksc6/run1`**, flown
2026-10-07 from IPL with no development flags:

    fly_sts134.py --logs DIR --port-base 47200 --tape ~/workspace/pass-run/OI340700-v44boot-sts134-ksc6.mmv --rate 2 --crts 2

It ran with `YAGPC_NAVAIDS=yaGPC2/tools/sites/ksc-navaids.txt`.

## Sources of the times

| Source | What it gives | Notes |
|---|---|---|
| `logs/panel.log` | Every crew keystroke, switch and script step, and the CRT titles the driver waited for | The panel's own clock runs at half the vehicle's (`--rate 2`).  **Vehicle t = 2 × panel t − 22.2 s.**  This was checked against the seven plays the driver timed by GMT (OMS-2 EXEC, OPS 301, the targets, OPS 302, MNVR, EXEC, OPS 304), the five device events yaGPC2.log also logs (probes, gear DN, chute DPY, brakes), and three capture times.  All agree to 0.1 s, so the panel-derived times are good to about ±0.2 s. |
| `logs/yaGPC2.log` | The truth: `vehdyn-state` (r, v, mass), `vehdyn-entry` (h, M, α, β, q, surfaces) and `vehdyn-orbit` (osculating HA/HP, inclination, specific force), every 5 s.  It also logs gear, touchdown, chute, brakes, probes, valves and vent doors, each with its own t. | Event lines are exact.  Anything read off the 5-s samples is marked ≈ or "sampled". |
| `driver.out` | The ground's targets; the driver's decisions and the truth values it acted on (gear at 1,982 ft, and so on) | Its lines carry no times.  Each is timed from the matching panel.log play. |
| `logs/meds*.log` | Display activity only | No times.  It confirms the A/E PFD on CRT 2 (`action AE_PFD`). |
| Derived | The bank angle, the runway frame, peak drag and the heating index | See "Derived data". |
| STS-134 actual | JSC 37461, STS-134 Mission Report | p15 events, p44 OMS table, p57 landing parameters |
| STS-1 nominal | JSC-14483 Vol 5, STS-1 OFP Descent, Cycle 3, as digitized in `~/workspace/pass-run/aero-docs/entry-ofp/entry-ofp.csv` | Tables 6.3-I and 6.4-I.  A plan, not a flight. |

**The volume.**  Each one was checked by diffing it against its predecessor
(changed data halfwords, checksums included):

| Volume | Adds | Halfwords changed | Site file / commit |
|---|---|---|---|
| `OI340700-v44boot-sts134.mmv` | The STS-134 OPS 1 reconfiguration | — | `sts134-reconfig.json` (see `TIMELINE-STS134.md`) |
| `…-ksc3.mmv` | KSC 15/33, TACANs TTS and COF, and the MLS area table as PASS's G3 site I-loads (CGN13R) | 89 | `tools/sites/ksc.json` via `tools/landing_sites.py`; 0a861eeca, 3b729fae0, 1cb919d85, d5a48d6bc |
| `…-ksc4.mmv` | CGNS_GPS_LOCKOUT 3, which makes GPS INCORPORATE legal | 10 | `sts134-gps-lockout.json`, d5a48d6bc |
| `…-ksc5.mmv` | CGCV_GDQ_SLOPE as flown | 7 | `sts134-gdq-slope.json`, e80309746 |
| `…-ksc6.mmv` | CGYS_KCD1..6, NAVDAD's drag fit as flown | 11 | `sts134-navdad-kcd.json`, 208a121a9 |

## The timeline

### Orbit coast after OPS 2 (MM 201)

| T | GMT 136/ | Who | Event | Data source |
|---|---|---|---|---|
| −6:13:50.8 | 13:51:47.9 | CREW | `OPS 201 PRO`, after GPC MEMORY configuration 2 for a single G2.  GNC UNIV PTG (2011/) is on CRT 1 at 13:52:07.7. | panel.log |
| −6:12:48.0 | 13:52:50.8 | SIM | Capture `sts134-ops2` | yaGPC2.log dump, t = 8,542.49 |
| | | SIM | Coast from t = 8,545 to 30,900 (4,472 samples): HA 161.2–172.3 and HP 117.7–128.4 nmi above the equatorial radius (mean 165.5 × 121.8), osculating.  Inclination 51.63–51.67° of date. | `vehdyn-orbit` |
| −4:38:38.6 | 15:27:00.2 | SIM | Capture `sts134-orbit`, after the ORBIT phase's one orbit (5,600 s).  Its last sample (t = 14,190): 161.64 × 119.54 nmi, 51.631°.  The ground designs the deorbit from this capture. | driver.out; GPC1 SNAPSHOT t = 14,191.86 |
| −0:00:00.4 | 20:05:38.3 | SIM | The orbit at TIG: 164.97 × 119.25 nmi above the equatorial radius (165.12 × 119.40 above the ellipsoid); 51.643° | `vehdyn-orbit` t = 30,910.0 |

### Deorbit targeting (GROUND)

`deorbit_target.py` ran on the ORBIT capture's truth state, standing in for
Mission Control's tracking (driver.out):

| Item | Value | Note |
|---|---|---|
| Opportunity | Closest approach 310 nmi from KSC 15 at 136/20:55:00.128 (capture + 5.47 h), crossrange −298 nmi | The first pass within 550 nmi |
| TIG (ITEM 10) | 136/20:05:38.733 (capture + 16,718.6 s), keyed as MET 0/07:09:10.7 | |
| C1, C2 (ITEMs 14, 15) | 15310 ft/s, −0.6157 | STS-1's (OFP Table 6.1-III) |
| HT (ITEM 16) | 65.832 nmi, which is 400,000 ft | |
| THETA T (ITEM 17) | 119.927° | Solved for REI 4,350 nmi |
| PRPLT (ITEM 18) | 517 | See "Known differences" |
| Burn | Impulsive ΔV 237.3 ft/s; coast to EI 30.00 min | |
| EI predicted | 136/20:35:38.852; 43.29 N 173.21 W; 25,773 ft/s inertial; γ −1.227°; REI 4,350 nmi | |

### Deorbit prep (OPS 3: MM 301, then 302)

| T | GMT 136/ | Who | Event | Data source |
|---|---|---|---|---|
| −1:15:00.0 | 18:50:38.7 | CREW | TIG−75 (ENT/ALL/GEN H): GPC MEMORY.  `SPEC 0 PRO` (−1:14:58.0), then `ITEM 1 +3 EXEC` (−1:14:48.0) for memory configuration 3.  Items 2–19 follow every 16 s until −1:10:00.0: the single-G2 table, with configuration 3. | panel.log |
| −1:09:40.0 | 18:55:58.7 | CREW | `OPS 301 PRO`.  **G3 comes from the upper-memory archive (rapid G3), not mass memory.**  The run did not use `--g3-from-mm`, and the archive store and retrieve work since c87bce8b6. | panel.log; driver.out has no WORKAROUND line |
| −1:09:32.0 | 18:56:06.7 | PASS | DEORB MNVR COAST (3011/) on CRT 1, 8 s after PRO.  The C3 DAP lamps show AUTO, with ROLL, PITCH and YAW DISC. | panel.log |
| −0:44:58.0 to −0:44:16.6 | 19:20:40.7 to 19:21:22.1 | CREW | TIG−45, the targets on DEORB MNVR COAST, one item at a time: ITEM 10 TIG `+0+7+9+10.7`; then ITEM 14 C1, 15 C2, 16 HT, 17 THETA T and 18 PRPLT, 7–11 s apart | panel.log; deorb-targets.script |
| −0:44:08.0 | 19:21:30.7 | CREW | `ITEM 6 +0.0 −5.7 +5.7 EXEC`: the two-engine trims (ENT/ALL/GEN H 3-8) | panel.log |
| −0:43:57.4 | 19:21:41.3 | CREW | `ITEM 22 EXEC`: LOAD | panel.log |
| −0:43:48.0 | 19:21:50.7 | CREW | `ITEM 23 EXEC`: TIMER | panel.log |
| −0:43:46.0 to −0:43:34.0 | 19:21:52.7 to 19:22:04.7 | CREW | GPS INCORPORATE: `SPEC 50 PRO`, `ITEM 44 EXEC` (−0:43:40.0), `RESUME`.  It is legal only with CGNS_GPS_LOCKOUT 3 (ksc4). | panel.log |
| −0:24:58.0 | 19:40:40.7 | CREW | TIG−25: `OPS 302 PRO` | panel.log |
| −0:19:58.0 | 19:45:40.7 | CREW | TIG−20: DAP AUTO (C3), then `ITEM 27 EXEC` (−0:19:48.0): MNVR to the burn attitude.  The time the attitude was reached is not logged. | panel.log |
| −0:00:15.0 | 20:05:23.7 | CREW | TIG−15: `EXEC` | panel.log |

### The deorbit burn (MM 302)

| T | GMT 136/ | Who | Event | Data source |
|---|---|---|---|---|
| ≈ −0:00:00.2 | ≈ 20:05:38.5 | PASS | **OMS ignition, both engines.**  The truth's mass starts falling at 17.5 kg/s.  Extrapolated back from the 5-s samples, that puts ignition at t ≈ 30,910.2, at TIG to within the sampling. | `vehdyn-state` mass_kg (derived) |
| ≈ +0:02:31.8 | ≈ 20:08:10.5 | PASS | **Cutoff**, extrapolated the same way: about **152 s**.  Mass 115,796.6 → 113,132.6 kg, so **2,664 kg (5,873 lb)** burned. | `vehdyn-state` (derived) |
| | | | **ΔV ≈ 236 ft/s**, two ways: <br>• the sensed specific force summed over the 30 samples that see it is 232.9 ft/s, covering 150 of the ~152 s; <br>• the rocket equation on the truth's masses with Isp 316 s (the driver's PEG constants) gives 236.6. <br>The ground's impulsive design was 237.3. | `vehdyn-orbit` sf_g; masses (derived) |
| +0:02:34.6 | 20:08:13.3 | SIM | First sample after the burn: **155.18 × 1.67 nmi** above the equatorial radius (158.06 × 4.55 above the ellipsoid), osculating; 51.650°.  HP climbs to 4.98 by t = 31,295 as the orbit is perturbed. | `vehdyn-orbit` t = 31,065 |

STS-134's burn: 152/05:29:03.1, dual OMS, 158.3 s and 298.4 ft/s (p44's
table: 159.2 s, 296.9), leaving 23.2 × 188.5 nmi (JSC 37461 p15, p44).

### Post-burn (MM 303)

| T | GMT 136/ | Who | Event | Data source |
|---|---|---|---|---|
| +0:06:02.0 | 20:11:40.7 | CREW | `OPS 303 PRO`.  The driver waits for TIG+6 min. | panel.log |
| +0:06:06.0 | 20:11:44.7 | PASS | DEORB MNVR EXEC (3031/) on CRT 1 | panel.log |
| +0:06:12.0 | 20:11:50.7 | CREW | `ITEM 27 EXEC`: MNVR to the EI attitude | panel.log |
| +0:06:12.1 | 20:11:50.9 | SIM | Capture `sts134-deorbit` | GPC1 SNAPSHOT t = 31,282.58 |

### Entry (MM 304)

| T | GMT 136/ | Who | Event | Data source |
|---|---|---|---|---|
| +0:25:02.2 | 20:30:40.9 | CREW | EI−5 (ENTRY MANEUVERS cue card): `OPS 304 PRO`.  The driver's play came at EI−5 exactly, 20:30:38.9. | panel.log |
| +0:25:05.8 | 20:30:44.5 | PASS | ENTRY TRAJ 1 (3041/) on CRT 1 | panel.log |
| +0:25:07.0 | 20:30:45.7 | PASS | Lamps: pitch and roll/yaw AUTO (CDR and PLT); body flap and speedbrake AUTO on F2 and F4 | panel.log |
| +0:25:10.2 to +0:25:38.2 | 20:30:48.9 to 20:31:16.9 | CREW | IDP 2 power ON; 20 s later the CRT 2 edge keys UP, FLT INST, A/E PFD.  The A/E PFD is on CRT 2 for the rest of the flight. | panel.log; meds2.log |
| +0:25:12.2 to +0:25:32.0 | 20:30:50.9 to 20:31:10.7 | PASS | Vent doors close: groups 1, 2, 3, 5, 6 | yaGPC2.log valve lines |
| **+0:30:09.5** | **20:35:48.2** | SIM | **EI, 400,000 ft**, interpolated between the samples at t = 32,718.1 and 32,723.1.  Truth: 25,772 ft/s inertial, γ −1.229° inertial, 43.96 N 172.33 W, 4,313 nmi from the KSC 15 threshold; α 40.3°, M 27.6.  Planned: 9.4 s and about 37 nmi earlier (above). | `vehdyn-entry`, `vehdyn-state` (derived) |
| ≈ +0:35:45 | ≈ 20:41:23 | PASS | **Roll-in to the right**: the first sample with \|bank\| > 20° is 22.7° at t = 33,055 (V_rel 24,700 ft/s).  Bank is 74–77° from t = 33,100 to 33,150. | Derived bank |
| ≈ +0:43:13 | ≈ 20:48:52 | — | Peak of the heating index √ρV³ (sampled; an index, not a heat rate): V_rel 20,440 ft/s, 216,100 ft, M 20.5, q 63 psf | Derived from `vehdyn-entry` q and the truth V |
| ≈ +0:46:01.6 | ≈ 20:51:40.3 | PASS | **Roll reversal 1**, right to left: V_rel 16,900 ft/s, M 16.2, 195,000 ft.  Heading 11.7° right of the bearing to the threshold. | Derived bank (zero crossing) |
| ≈ +0:46:43 | ≈ 20:52:22 | — | **Peak drag, 33.9 ft/s²** (C_D q S/m, S = 2,690 ft²): M 14.9, 189,800 ft, q 101 psf.  The truth's own acceleration gives 33.8 at t = 33,715. | `vehdyn-entry`, mass (derived) |
| ≈ +0:48:13 | ≈ 20:53:52 | PASS | **Pitch-down from 40°.**  α was about 40° from EI (38.9–41.6 sampled) and is 39.8° at M 11.8.  Then: 37.6° at M 10, 32.5° at M 8.1, 22.2° at M 5, 18.2° at M 3.5, 15.0° at M 2.5. | `vehdyn-entry` |
| ≈ +0:49:38 | ≈ 20:55:17 | PASS | **Speedbrake opens**: first non-zero sample 6.4° at M 9.13; 98.6° from M 8.07 (t = 33,928) to M 3.9 | `vehdyn-entry` sb |
| ≈ +0:50:17.4 | ≈ 20:55:56.1 | PASS | **Roll reversal 2**, left to right: V_rel 8,790 ft/s, M 8.07, 150,000 ft.  Heading 19.1° left of the threshold bearing. | Derived bank |
| ≈ +0:51:22.5 | ≈ 20:57:01.2 | SIM | V_rel passes 7,000 ft/s.  The driver's trigger is the truth feed's ground speed < 7,000 ft/s. | Derived from `vehdyn-state` |
| +0:51:25.2 to +0:51:39.2 | 20:57:03.9 to 20:57:17.9 | CREW | **V = 7K** (ENT/134/FIN FS 3-34): GPS INCORPORATE, i.e. `SPEC 50 PRO`, `ITEM 44 EXEC` (+0:51:33.2), `RESUME` | panel.log |
| +0:51:43.2, +0:51:45.2 | 20:57:21.9, 20:57:23.9 | CREW | C3 AIR DATA PROBE LEFT, then RIGHT, to DEPLOY.  Truth: left and right probes DEPLOYING at t = 34,013.7 and 34,015.7. | panel.log; yaGPC2.log |
| +0:51:53.2 | 20:57:31.9 | CREW | `SPEC 50`, `ITEM 28 EXEC`: ADTA to G&C AUT.  `RESUME` follows at +0:51:59.2. | panel.log |
| +0:52:37.3 | 20:58:16.0 | PASS | E1–E3 LO2 prevalves CLOSED | yaGPC2.log t = 34,067.744 |
| ≈ +0:53:16.3 | ≈ 20:58:55.0 | PASS | **Roll reversal 3**, right to left: V_rel 4,460 ft/s, M 4.34, 104,400 ft.  Heading 20.7° right of the threshold bearing. | Derived bank |
| ≈ +0:54:08 | ≈ 20:59:47 | PASS | **Rudder active**: the first non-zero rudder sample is 2.5° at M 3.42 (t = 34,158.4).  The sample before it, at M 3.51, was 0.  CGCS_MACH_RUDDER is 3.5 on this tape. | `vehdyn-entry` rud |
| ≈ +0:54:58.0 | ≈ 21:00:36.7 | — | **Maximum q: 316 psf** at M 2.64, 77,800 ft (α 12.5°) | `vehdyn-entry` |
| **≈ +0:54:59.1** | **≈ 21:00:37.8** | PASS | **V_rel 2,500 ft/s.  This is the TAEM interface:** entry guidance ends when REL_VEL < CGGS_V_TAEM = 2,500 (GGEENT.hal:1030-1035; CGGC03.hal:517).  At the same speed, air data replaces NAVDAD's qbar in G&C (CGYS_V_ADS, GYAADT.hal:110-114).  Truth: M 2.62, 77,500 ft, 33.0 nmi surface distance to the threshold.  **The MM 305 transition itself is not logged.** | Derived from `vehdyn-state`, `vehdyn-entry` |
| +0:55:01.0 | 21:00:39.7 | SIM | Capture `sts134-entry` | GPC1 SNAPSHOT t = 34,211.41 |

**How the roll reversals were identified.**  `vehdyn-entry` carries no bank
angle, so it was derived from the truth (see "Derived data").  A reversal is
a sign change of the derived bank with \|bank\| > 15° on one side.  There are
exactly three between roll-in and the TAEM interface.  Each matches a turn of
the Earth-relative heading: right turn to t ≈ 33,670, left to ≈ 33,925, right
to ≈ 34,105, then left.  The next sign change, at t = 34,520, is the roll-out
onto final, not a reversal.

Sideslip stayed small throughout: \|β\| ≤ 0.45° from Mach 4 to 2.2, where the
earlier flights departed (`lateral-departure-findings.md`).  It was ≤ 2.3°
above Mach 4 and ≤ 1.1° below Mach 2.2.

### TAEM (MM 305)

| T | GMT 136/ | Who | Event | Data source |
|---|---|---|---|---|
| ≈ +0:55:05.6 | ≈ 21:00:44.3 | — | M 2.5 (75,100 ft) | `vehdyn-entry` |
| +0:55:10.2 to +0:55:30.0 | 21:00:48.9 to 21:01:08.7 | PASS | Vent doors open: groups 2, 5, 3, 1, 6 | yaGPC2.log |
| ≈ +0:55:15 to +0:56:05 | | PASS | A right bank of 14–24° (derived, t ≈ 34,225–34,275).  Heading goes from 126.5° to 146.8°. | Derived |
| ≈ +0:56:25 to +1:00:09.6 | ≈ 21:02:03 to 21:05:48.3 | PASS | **The turn onto final.**  From t ≈ 34,297 the vehicle banks left, about −45° to −50° from t = 34,325 to 34,390 (derived).  The heading turns left through **358°**, from 146.8° at t = 34,295 to 136.6° at 34,520.  The vehicle stays 6.8–7.8 nmi from the threshold the whole way.  Mach 1 comes in the turn at +0:56:47.3 (50,500 ft). | Derived heading and range |
| ≈ +1:00:10 to +1:00:20 | | PASS | Rolled out on the runway heading (150°) at about t = 34,525: 5.5 nmi out, h 6,300 ft (truth).  Flight-path angle −8.5° at t = 34,525, then **−0.2° at 34,530**: a level-off before the glide slope. | Derived γ; `vehdyn-entry` h |
| | | PASS | **The TAEM / A/L interface is not logged.** | |

### Approach and landing (A/L)

| T | GMT 136/ | Who | Event | Data source |
|---|---|---|---|---|
| ≈ +1:00:35 to +1:01:05 | | PASS | The glide slope (relative γ, 5-s samples): −12.2°, −12.1° and −12.1° at t = 34,550 to 34,560; −15.6° at 34,565; **−20.3° and −20.1°** at 34,570 and 34,575 | Derived γ |
| +1:00:59.96 | 21:06:38.69 | CREW | **LANDING GEAR ARM** (F6) at 1,982 ft wheel height.  The rule is 2,000 ft. | panel.log; driver.out |
| ≈ +1:01:10 to +1:01:20 | | PASS | **Preflare and flare**: γ −12.8° at t = 34,580, −4.9° at 34,585, +0.3° at 34,590 (sampled).  PASS's A/L phase changes are not logged. | Derived γ |
| +1:01:12.36 | 21:06:51.09 | CREW | **LANDING GEAR DN** at 233 ft and 274 KGS.  The rule is 300 ft; the driver polls the truth feed.  vehdyn: DOWN commanded at t = 34,582.9. | panel.log; yaGPC2.log |
| +1:01:22.46 | 21:07:01.19 | SIM | Gear DOWN AND LOCKED, 10.0 s after the command | yaGPC2.log t = 34,592.9 |
| ≈ +1:01:27.6 | ≈ 21:07:06.4 | SIM | Over the threshold, at about 208 kt | Derived runway frame |
| **+1:01:28.94** | **21:07:07.67** | SIM | **MAIN GEAR TOUCHDOWN**: left at 34,599.38 (202.5 kt, sink 3.8 ft/s); right at 34,599.39 (202.4 kt, 3.7 ft/s).  The state point is **453 ft past the threshold**.  EI to touchdown: 31:19.5. | yaGPC2.log; derived runway frame |
| +1:01:29.47 to +1:01:30.04 | 21:07:08.20 to 21:07:08.77 | SIM | A skip: right and left mains lift off at 34,599.91 and 34,600.00 (200.0 and 199.6 kt, rising at 2.2 and 1.8 ft/s).  Both are down again at 34,600.47 and 34,600.48 (197.8 kt, 0.3 ft/s). | yaGPC2.log |
| +1:01:28.96 | 21:07:07.69 | CREW | DRAG CHUTE ARM (F2) at main-gear touchdown, 202 KGS, then DPY at +1:01:30.96 | panel.log; driver.out |
| +1:01:30.96 | 21:07:09.69 | SIM | Drag chute DEPLOYED, TD + 2.0 s, 1,128 ft past the threshold | yaGPC2.log t = 34,601.4 |
| **+1:01:42.36** | **21:07:21.09** | SIM | **NOSE GEAR TOUCHDOWN**: 140.7 kt, TD + 13.4 s, 4,354 ft past the threshold | yaGPC2.log t = 34,612.80 |
| +1:01:48.56 | 21:07:27.29 | CREW | **BRAKES** (F6 ON) at 120 KGS, once the nose is down and the speed is below 120 KGS.  vehdyn: BRAKES on at t = 34,619.0, TD + 19.6 s, 5,711 ft. | panel.log; yaGPC2.log |
| +1:01:59.76 | 21:07:38.49 | CREW | **DRAG CHUTE JETT** (F2) at 55 KGS.  The rule is 60.  vehdyn: JETTISONED at t = 34,630.3, TD + 30.9 s, 7,339 ft. | panel.log; yaGPC2.log |
| **≈ +1:02:11.9** | **≈ 21:07:50.6** | SIM | **WHEELS STOP** at t ≈ 34,642.3, TD + 42.9 s.  Derived: 18.0 ft/s at 34,640.0 and 0 at 34,645.0, at the previous 5 s's 7.7 ft/s².  The driver declared it after 5 s below 0.5 kt. | Derived; driver.out |
| +1:02:22.97 | 21:08:01.70 | SIM | Capture `sts134-land`; the driver ends the simulation | GPC1 SNAPSHOT t = 34,653.41 |

**Where it stopped: 7,895 ft past the KSC 15 threshold, 3 ft right of the
centreline**, about 7,100 ft short of the KSC 33 end.  The **rollout from main-gear
touchdown was 7,442 ft**.  These are the truth's state point, put in the
runway frame from the landing capture with:
- PASS's own M50-to-Earth-fixed rotation for 2011 day 136 (vehdyn.c
  `pass_rnp`);
- GNKGEO's ellipsoid (a 20,925,646.3255 ft, f 1/298.3);
- the runway ends of `ksc.json`, taken as geodetic.

An earlier reckoning of the same capture against the nav base gave 7,952 ft
and 6 ft right.  The 57 ft between the two is not resolved.  The touchdown
point inferred from it (about 700 ft, from an integrated rollout of 7,254 ft)
is superseded by the position track above.

### Against STS-134's landing

STS-134's own figures are from JSC 37461: p15 for the events, p57 for the
landing parameters (measured from main-gear touchdown).

| | Simulated | STS-134 |
|---|---|---|
| Deorbit burn | ≈152 s, ≈236 ft/s | 158.3 s, 298.4 ft/s |
| TIG to EI | 30:09.5 | 34:03 |
| EI to main-gear touchdown | 31:19.5 | 31:44 |
| Runway | KSC 15 | KSC 15 |
| Main gear touchdown, past the threshold | **453 ft** (state point) | **3,186 ft** |
| Main gear touchdown speed, sink rate | 202.5 KGS, 3.8 ft/s | 195.3 KGS (190.6 KEAS), 1.21 ft/s |
| Drag chute deployed | TD + 2.0 s | TD + 3.04 s |
| Nose gear touchdown | TD + 13.4 s, 140.7 KGS | TD + 9.35 s, 155.0 KGS |
| Brakes on | TD + 19.6 s, 120 KGS | TD + 16.76 s, 118.8 KGS |
| Drag chute jettison | TD + 30.9 s | TD + 28.85 s |
| Wheels stop | TD + 42.9 s | TD + 42.47 s |
| Rollout | 7,442 ft | 6,596 ft |
| Stop, past the threshold | 7,895 ft | 9,782 ft |
| Weight at landing | 248,388 lb (vehdyn) | 204,477 lb |

### Cross-check: STS-1's nominal TAEM interface

The STS-1 descent OFP's nominal entry: Tables 6.3-I and 6.4-I, as digitized
in `aero-docs/entry-ofp/entry-ofp.csv`.

| | Simulated | STS-1 OFP (planned) |
|---|---|---|
| Entry/TAEM interface, time from EI | 24:49.6 | 25:03.3 |
| V_rel, Mach | 2,500 ft/s, 2.62 | 2,494.9 ft/s, 2.55 |
| qbar | 316 psf | 208.7 psf |
| α | ≈12.3° | 14.26° |
| Distance to the threshold | 33.0 nmi (straight, over the surface) | "range to threshold" 60.1 nmi |
| Main gear touchdown, time from EI | 31:19.5 | 31:29.44 |

The two distances are not the same measure: the OFP's range is the one TAEM
flies, presumably around the HAC.  But the simulated vehicle arrived much
closer in and faster, and then flew a full circle (358°) to lose the energy.
That is one of the open items below.

## What it took

Every one of these was needed for this flight to land.  All are in the
virtualagc repository on branch `review/ops1-lps`.

| Fix | The cause it removed | Commit (volume) |
|---|---|---|
| B2=11 data operands expanded by DSR | The G3 archive store at OPS 9→1 and the retrieve at OPS 2→3 read their DAT through C6C6 fill and moved nothing.  OPS 301 then hung, ILLEGAL ENTRY with G3 never loaded. | c87bce8b6 |
| Landing devices: MLS, radar altimeter, gear and weight-on-wheels, the ground, drag chute, brakes; GPS at the nav base | The vehicle had no ground, gear or landing aids for PASS to fly to | d5a48d6bc (ksc3 site tables) |
| GPS lockout I-load: CGNS_GPS_LOCKOUT 3 | The checklists' GPS INCORPORATE (SPEC 50 ITEM 44) was an ILLEGAL ENTRY on the generic tape, so nav carried its orbit error into entry | `sts134-gps-lockout.json`, d5a48d6bc (ksc4) |
| The TAEM pitch gain table CGCV_GDQ_SLOPE as flown | The source INITIAL's slopes sit two places off their intercepts.  GDQ was pinned at its 0.2 floor from Mach 3 to 1.2, and the elevator moved only on the trim integrator. | `sts134-gdq-slope.json`, e80309746 (ksc5) |
| ADTAs and air data probes; the body flap's valves vote 2 of 3 | With no air data PASS took qbar from its drag estimate, three times the truth, and guidance's qbar limit commanded full pull-up.  The body-flap pilot valves were ORed: one held DOWN by redundancy management cancelled the others' UP, and the flap froze at +21°. | e80309746 |
| Probe switches on C3, and the driver's air-data steps | ADTA PROBES DEPLOY and ADTA to G&C AUT at V = 7K, as ENT/134/FIN FS 3-34 has them | 163048910 |
| ADTA pressures in inches of mercury | They were sent in psi.  PASS saw 1/2.036 of every pressure: TAEM forced Nz −0.5, and on final the speedbrake stayed shut 166 ft/s fast. | 4af6c8334 |
| NAVDAD's drag fit CGYS_KCD1..6 as flown | Above 2,500 ft/s qbar comes from NAVDAD.  With the INITIALs it read 2.2–5.7× high from Mach 4 to 2.7, the lateral gains sank to their floors, and the vehicle departed at Mach 2.8. | `sts134-navdad-kcd.json`, 208a121a9 (ksc6) |

Also needed, from the vehicle model: the pitch derivatives below Mach 5 set
to measured values (6112f28f4).  The blend had made the orbiter statically
unstable at Mach 1.3–2.  The driver's DEORBIT, ENTRY and LAND phases are
89fae5fde and 13dfaadfd.

## Derived data and how it was obtained

| Data | How | Where |
|---|---|---|
| Vehicle t ↔ panel clock | t = 2 × panel t − 22.2 s, fitted on 15 events with both times (see "Sources") | panel.log, yaGPC2.log |
| GMT | 136/11:30:28.292 + t: the `gmt=` field, the GMT the driver itself waits on | `vehdyn-state` |
| Burn start and stop | The truth's mass at 5-s samples falls at a constant 17.52 kg/s.  Start and stop are extrapolated to where that line meets the constant mass before and after. | `vehdyn-state` mass_kg |
| Bank angle | From the truth's inertial velocity, as a central difference over ±5 s, less J2 gravity.  That gives the aerodynamic specific force; minus its component along the Earth-relative velocity, it gives the lift.  Bank = atan2(lift · right, lift · up), with "up" the local vertical made normal to the velocity.  Positive is right.  It is meaningless above about 300,000 ft, where there is no lift. | `vehdyn-state` |
| Heading, bearing, distance to the threshold; γ | The truth's state rotated to Earth-fixed with PASS's own RNP matrix for 2011 day 136 and CGNS_EARTH_RATE (vehdyn.c `pass_rnp`; GLWRNP), on GNKGEO's ellipsoid; the threshold from `ksc.json` | |
| Runway frame | The same rotation.  x is along the runway from the KSC 15 threshold to the KSC 33 end (15,001 ft between the `ksc.json` end points); y is to the right.  Event positions come from Hermite interpolation of the 5-s states with their velocities. | |
| Drag acceleration | C_D × q × 2,690 ft² / mass.  The truth's C_D and q are from `vehdyn-entry`, the mass from `vehdyn-state`.  2,690 ft² is NAVDAD's reference area (GYDNAV). | |
| Heating index | √ρ V³ = √(2q) V², from the logged q and the truth's Earth-relative V.  It locates the peak; it is not a heat rate. | |
| EI | 400,000 ft by linear interpolation of the truth's `h` between 5-s samples.  Position and velocity are interpolated from `vehdyn-state`.  The distance to the threshold is the great-circle arc on a 6,371 km sphere. | |

## Known differences and open items

- **The touchdown is short: 453 ft past the threshold, against STS-134's
  3,186 ft.**  The approach also has a 358° turn and a level-off at 6,000 ft
  before the glide slope.
  - Not yet traced.  The first suspects are the G3 I-loads still at their
    HAL source INITIALs rather than the flown DASS values (`pure-G3.fcm`).
  - A/L (`~/workspace/pass-run/entry/al-guidance-findings.md` §5):
    CGGS_X_AIM_PT 1,500 (flown 1,000), CGGS_V_REF 490 (506.3), CGGS_SB_REF
    55 (65) and CGGS_WT_GS1 8,000 (6,900 slug, which would select the heavy
    −18° glide slope).  The flare geometry (H_K, R, X_K) and 80-odd more of
    the 395 CGGS cells compared also differ.
  - TAEM: the qbar, energy and HAC geometry I-loads, for example
    CGGS_R_HAC_RW and CGGS_X_NEP.
  - Flight control (`lateral-departure-findings.md` §2):
    - CGCS_NZFDFILT3 −0.0923 against −0.923.  This is a probable
      factor-of-ten source typo in the pitch Nz filter, with DC gain 0.085
      instead of 1.
    - CGCS_MACH_RUDDER 3.5 against 5.0.  Here the rudder came in at
      Mach 3.42.
    - The GRAY Ny-to-yaw-rate gain, 3.9× the flown value at Mach 2.8.
    - Much of CGCFL1 (916 of 1,688 halfwords) and CGYMC3 (146 of 296).
- **The TAEM interface came 33 nmi from the threshold at 316 psf.**  STS-1's
  plan had 60.1 nmi and 208.7 psf.  It is not established whether this is
  the targeting (REI 4,350 against STS-1's 4,358, with EI 37 nmi downrange of
  plan), entry guidance's I-loads, or our aerodynamics.
- **EI came 9.4 s late and about 37 nmi downrange of the ground's
  prediction**, at the predicted speed and angle (25,772 against 25,773 ft/s,
  −1.229° against −1.227°).  `deorbit_target.py` uses an impulsive burn and
  its own Earth orientation (GMST, "good to tens of n.mi."), not PASS's.
- **PRPLT was keyed as 517, but the burn used 5,873 lb.**
  - The driver computes PRPLT from the capture's propellant entries alone
    (`vehdyn.json` indices 16–20, 10,137 kg).  The entry it adds as the
    vehicle's mass, index 194, is 0, so the dry 105,738 kg is left out.
  - What PEG 4 does with a PRPLT this low is not established.  The FSSR
    reads PRPLT as the total propellant to expend, with out-of-plane waste
    reaching it.
  - The burn's ΔV still matched the design to about 1 ft/s.
- **The deorbit is on flight day 1, with STS-134's launch cargo still
  aboard.**  The landing weight is 248,388 lb against STS-134's 204,477.
- **A main-gear skip at touchdown**: 0.5 s off the runway, at 3.8 ft/s sink.
  STS-134 touched at 1.21 ft/s.
- **The 57 ft between two reckonings of the stop point** (7,895 here, 7,952
  against the nav base) is not resolved.
- **Not logged:** PASS's major-mode transitions (MM 305 and A/L are taken
  from the guidance thresholds, not observed), the burn attitude and EI
  attitude reached, PASS's A/L phases (preflare, flare), and heating.

## References

All are in the local ibiblio mirror (`~/Desktop/sandroid.org/public_html/apollo/Shuttle/`) unless marked otherwise.

- **JSC 37461, STS-134 Space Shuttle Mission Report** (Sept 2011):
  `Reports/Mission Reports/STS-134 Space Shuttle Mission Report.pdf`.
  - p15: the deorbit burn (152/05:29:03 GMT, 158.3 s, 298.4 ft/s,
    23.2 × 188.5 nmi), EI 152/06:03:06, and main gear on KSC runway 15 at
    152/06:34:50, then chute, nose gear and wheels stop.
  - p44: the OMS table.
  - p57: LANDING PARAMETERS, the distances from the threshold, speeds,
    rollout and weight.
- **JSC-14483 (78-FM-51) Vol 5, STS-1 Operational Flight Profile, Descent,
  Cycle 3**: Table 6.1-III (C1, C2, HT, the deorbit nominal) and Tables
  6.3-I, 6.4-I and 6.0-I (the TAEM and A/L interfaces, touchdown).  Digitized
  in `~/workspace/pass-run/aero-docs/entry-ofp/` (not in the repository).
- **STS 83-0003-34, GN&C FSSR, Guidance On-orbit/Deorbit**: the PEG 4 target
  definitions, as summarized in `~/workspace/pass-run/entry/peg4-deorbit-findings.txt`.
- **Findings** (`~/workspace/pass-run/entry/`, not in the repository):
  `al-guidance-findings.md` (A/L and TAEM I-loads, ADTA units),
  `lateral-departure-findings.md` (NAVDAD KCD and the lateral I-loads),
  `taem-pitch-findings.md` (GDQ), `landing-devices-findings.md`,
  `gear-rollout-findings.md`, `gps-nav-findings.md`.
- **PASS OI-34 flight source** (`~/workspace/PFS/OI340600/APPLSRC/`):
  - GGEENT (the entry/TAEM interface) and CGGC03 (CGGS_V_TAEM 2,500);
  - GYAADT (CGYS_V_ADS) and GYDNAV (NAVDAD, KCD1..6, 2,690 ft²);
  - GCBAER (the qbar-scheduled DAP gains, GDQ);
  - GLWRNP and GNKGEO (the Earth's orientation and ellipsoid, as ported in
    vehdyn.c).
- **The site and the driver**: `yaGPC2/tools/sites/ksc.json` (runway ends
  from the FAA KTTS record; lengths and MLS channels from ENT/134/FIN FS 3-2),
  the three `sts134-*.json` site I-loads, `discretePanel/deorbit_target.py`
  and `discretePanel/examples/flights/fly_sts134.py`.
