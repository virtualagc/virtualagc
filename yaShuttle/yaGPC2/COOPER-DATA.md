# The Cooper shift-report cache, and what it changes in the STS-134 simulations

Source: `~/Desktop/Shuttle Stuff/Cooper Shift/`, 48 files: 35 Consolidated Shift Reports (FD01-FD16, as the files
number them), 10 daily reports (FD1-3, 6-10, 14, 16; the FD16 one is the Landing-plus-2-hour report), the CSR
report, the 5/17 on-orbit report and Boeing's Actual Mass Properties Report SE11HOU028.  The Mission Report
(JSC-37461) outranks them wherever both give a value.  Everything below is in
`yaShuttle/yaGPC2/sts134-mission.db`, built by `sts134-mission-db.py` (`build`, `timeline FROM TO`, `search TEXT`,
`prop`); rebuild after the cache changes.

**What the cache does not have.**  No shift report for FD14 S2, FD15 S3, FD16 S3 or anything on FD17; none for FD11-12;
FD13 only S3.  The coast from 150/16:00 to 152/08:00 is therefore covered by FD15 S2, FD16 S1 and S2 (subsystem
status, FES dumps, the FCS checkout time) and the landing report.  There is no deorbit PAD, no state vector, and no
RCS hot-fire, MAUI or FRCS-dump procedure in it.

## The database

| Table | Rows (build of 2026-10-24) | What |
|---|---|---|
| `documents`, `lines`, `lines_fts` | 48, 4,536 | every line of every file with its section; full-text search |
| `events` | 460 | every GMT-stamped sentence, deduplicated across the repeating shift reports |
| `burns` | 39 | OMS and RCS firings: TIG, cutoff, duration, delta-V, resulting orbit, jets; the FD15 LVLH delta-Vs and body residuals |
| `propellant` | 15 | the PFS % block of each report, with the OMS-interconnect usage |
| `consumables`, `thrusters`, `orbits` | 141, 14, 13 | GN2, waste and supply water, PPCO2; "N of 38 primary thrusters fired"; orbits after each burn |
| `attitudes` | 18 | attitude and DAP states from reboost to the water-dump attitude |
| `mass_items`, `mass_summary` | 172, 31 | the weight-and-balance checklist; inert OV-105 178,280 lb at X 1113.1 in |
| `discrepancies`, `sim_impact`, `sources` | 15, 8, 3 | curated: where documents disagree, and what each datum means for a simulation |

Periods for five shift reports whose headers are unusable (FD01_S1, FD02_S1, FD03_S1, FD06_S1, FD09_S1) are inferred
from the neighbouring shifts and marked so in the builder.

## The propellant series (PFS %, oxidizer / fuel)

| GMT | Left | Right | Forward |
|---|---|---|---|
| 136/15:00 | 88.8 / 88.6 | 88.0 / 88.4 | 64.0 / 62.4 |
| 145/16:10 | 79.6 / 80.2 | 79.0 / 80.2 | 49.6 / 47.8 |
| 149/08:14 (after the reboost) | 77.0 / 77.2 | 75.0 / 76.4 | 37.2 / 35.8 |
| 149/16:00 | 76.8 / 77.2 | 75.4 / 76.4 | 37.0 / 36.0 |
| 150/09:00 (20 min after SEP3) | 64.8 / 65.0 | 62.8 / 63.8 | 16.8 / 14.6 |

OMS interconnect usage, %: left 0.161, right 1.605, right 2.057 after the interconnect at 150/10:25:00.  A point is
about 21 lb forward (the reboost's 135 lb of F5L/F5R plus quiet holds over the 12.4 points between 145/16:10 and
149/08:14), roughly 20 lb aft.  The scale is the weak part; the forward undock load of 733 lb follows from it by two
routes (37 % at 149/16:00 less the undock-attitude maneuvers, and 16.8/14.6 % at 150/09:00 plus the simulated
legs' ~390 lb).

## What it changes, simulation by simulation

**Ascent and OMS 2.**  Nothing needs changing.  New detail to hold the timeline against: liftoff 136/12:56:27.994
(GNC 27.958), OMS assist 12:58:43.0 for 165.4 s (the daily says 164.24 s), RCS window-protect 12:58:31.9 for 2.08 s
on F1U/F2U/F3U, ET separation maneuver 6 s with ten jets, ET photo +X 10 s, OMS-2 velocity residuals -0.02, 0.06,
0.02 ft/s.

**FD1-3 flight (Codex, `fly_fd13.py`).**  The burn table in the database is acceptance data: NC1 66.7 s / 93.6 fps,
NC2 14.4 s / 11.2 (right engine, interconnect from 137/05:39:00), NC3 an RCS +X burn 11.5 s / 2.7 fps on the right
interconnect, NC4 138/06:07:27.4 10.6 s / 8.2, Ti 07:38:13 10.8 s / 8.6, MC1 0.54, MC2 0.96, MC4 1.7 fps, RPM
09:15:31.  Sent to Codex by mailbox (message 163).

**Docking.**  Contact 138/10:13:52 (the daily's 1:13:52 is a typo), hook drive 10:22:52, hard mate 10:26:47, Ku
RADAR on at 06:53:26 with the ISS acquired at 140,000 ft and back to COMM at 09:54:24 at 147 ft.

**Undock, fly-around, STORRM (`fly_undock.py`).**  The flown LVLH delta-Vs and body residuals are scoring data (SEP2
1.53, NH2 -1.83, MC5 0.08/-0.02/0.53, NSR -2.49/0.10/-0.02, TPI 0.25/0.07/-3.38 with a 33 s TIG slip, SEP3 -1.00;
all burns in DAP A/Auto/Pri); closest approach 955 ft at 150/08:24:25; the hook drive 2:07; TCS tracking from 5,330 ft.
The burns are recomputed from the simulated state by the flown methods and aimed at the reference milestones;
nothing replays the flown values.  The PFS series fixed the forward start load (733 lb).  The sim's undock-to-SEP3
use, 462 lb forward in the demo run and 414 lb with the VGO-nulling fix, sits at the real ~430 lb.

**The post-ISS coast (`fly_return.py`, phase COAST).**  Flown from `sts134r-sep3` at the rate the host sustains
(about 2.3-3.1x), to 152/01:29:03, four hours before the flown TIG, where the Deorbit Prep checklist begins
("Begin NOMINAL DEORBIT PREP timeline at TIG-4 hr").  Events the record has and the simulation can fly:
150/09:10:19 the water-dump attitude -ZLV +YVV (primaries to the attitude, verniers to hold), 151/07:33:10 RAMBO-2
(three +X firings of L1A/R1A), a state-vector uplink every six hours, a capture every four.  Not flown, with the
blocker: MAUI (150/11:43:18; four firings totalling 144 s, direction and split unknown; 144 s of two aft jets would be
38 ft/s), the RCS hot-fire (151/03:30:57, procedure not in hand), the FCS checkout, the water dumps and FES dumps
(no model; about 0.3 % of the mass), FRCS drivers off at 150/11:50:46 (no panel control).  The payload bay doors are
closed throughout in the simulation, so their closing at 152/02:48:24 and 02:49:45 is not a state change.

**Deorbit, entry, landing (`fly_sts134` phases, driven by `fly_return.py`).**  The ground now designs the burn for the
opportunity the Orbiter took (orbit 248, KSC 15), from the simulated state: `deorbit_target.py --tff 34.05
--ei-gmt 152/06:03:06 --near-gmt 152/06:34:50 --gamma-ei -1.10`.  Two choices are calibrations to the record: the target
line's flight-path angle (STS-1's C1 gives EI gamma -1.38 deg and 394 ft/s where STS-134 burned 297 and left 23.2 x 188.5
n.mi., which implies about -1.17 deg), and the range from EI to the runway (4,438-4,481 n.mi., solved so EI falls at 06:03:06).

Run `deorb-1`, from the earlier physics-carried orbit capture (152/03:32), 2026-10-24:

| | Simulated | Flown (Mission Report) |
|---|---|---|
| TIG | 152/05:29:02.4 | 05:29:03.1 |
| burn delta-V; propellant | 335 ft/s; 6,860 lb at WT 211,123 | 296.9-298.4 ft/s; 6,103 lb |
| orbit after the burn | 349 x 41 km (188.4 x 22 n.mi.) | 188.5 x 23.2 n.mi. |
| EI | 06:03:05 | 06:03:06 |
| main gear touchdown | 06:34:11.9, 211 kt | 06:34:50 |
| nose gear | 06:34:25.7 | 06:35:00 |

EI to touchdown is 31:07 against the flown 31:44.  The 38 ft/s of extra delta-V is the open difference: the orbit
before the burn is the simulation's own.

## Open

- The coast has been flown to the first six hours at the time of writing; the full run (`coast-3`) was started
  2026-10-24 22:53 and takes about 14 hours.  Its result, and the deorbit from its own capture, are logged in
  `CLAUDE_LOG.md`.
- PASS's position drifts about 35 ft/min without an update (340 ft to 2,400 ft in 2.5 h); six-hourly uplinks leave
  tens of kft before each, and the flight had GPS 2 on throughout.
- The forward RCS dump after the burn (152/05:45:06.7, 11.04 s) is not flown; its procedure is not in hand.
- `fly_sts134` still follows the Entry Checklist from TIG-75; the Deorbit Prep checklist (Rev Q) puts OPS 3 at TIG-2:20,
  IMU/IMU alignment at TIG-1:10 and the PLBD closing at TIG-2:40.
- Aft start loads (1,691/1,689 lb) come from the mass budget; the PFS scale gives 1,530 +- 200 lb.
