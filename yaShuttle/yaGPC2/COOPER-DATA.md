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
09:15:31.  Sent to Codex by mailbox (message 163) and as `/mnt/STORAGE/forClaude/cooper/sts134-fd1-3-cooper.json` (message 165: burns, events, orbits, propellant, consumables, thrusters, discrepancies and sim_impact for liftoff to 138/12:00).  Codex's `fly_fd13.py` carries the NC1-NC4 table; its use of the rest is for Codex to say (message 171).

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
closed throughout in the simulation, so their closing at 152/02:48:24 and 02:49:45 is not a state change.  Flown as `coast-3`, `coast-4` and `coast-5` (the simulator's hard 20,000 s wall-clock limit stopped the first two, which resumed from their own 4-hour checkpoints; `FLY_DURATION` now lifts it): SEP3 to 152/01:29:03 at 2 to 3 times real time, PASS's orbiter position error 1.6 kft at the last check before the uplinks and 1.45 ft after them, the RAMBO firings and the water-dump attitude flown.  The ORBIT capture `sts134r-orbit` (152/01:32:39, 96,829 kg, osculating orbit 188.8 x 183.4 n.mi. above the equatorial radius) starts the deorbit.

**Deorbit, entry, landing (`fly_sts134` phases, driven by `fly_return.py`).**  The ground designs the burn for the opportunity the Orbiter took (orbit 248, KSC 15) from the simulated state, `deorbit_target.py` standing in for Mission Control.  The flown values it is read against: TIG 152/05:29:03.1, burn 296.9-298.4 ft/s (158.3 s, 6,103 lb), EI 06:03:06, main gear 06:34:50, nose 06:35:00, wheels stop 06:35:33, landing weight 204,463 lb.

*The orbit reference.*  The Mission Report's orbit heights are above a 6,371 km sphere, 3.854 n.mi. below the equatorial radius that the tool prints (TIMELINE-STS134.md, Apsis conventions).  The flown post-burn 188.5 x 23.2 is therefore **184.6 x 19.3 above the equatorial radius**, and the EI flight-path angle it implies is about -1.20 deg (first read as -1.17).  The first runs below were compared with it in the wrong reference.

| Run (all from a physics-carried or coast capture, 2026-10-24/25) | Design TFF / target-line gamma | Burn | TIG | Post-burn orbit (equatorial ref.) | EI gamma | Main gear |
|---|---|---|---|---|---|---|
| deorb-1 (r2, 152/03:32) | 34.05 min / -1.10 | 335 ft/s, 6,860 lb | 05:29:02.4 | 188.4 x 22 (truth) | -1.197 | 06:34:11.9, 211 kt |
| deorb-4 (the coast's own capture, first complete) | 34.05 / -1.10 | 334 ft/s | 05:29:02 | 348 x 40 km (truth) | -1.197 | 06:33:50, 217 kt |
| deorb-5 | 31.0 / -1.10 | 297.5 ft/s | 05:32:05.6 | 186.9 x 23.9 design; 346 x 37 km truth | -1.181 | 06:33:46, 220 kt; nose 06:34:00; wheels stop about 06:34:49 |
| deorb-6 (the design in `fly_return.py` now) | 30.0 / -1.14 | 297.9 ft/s (design) | 05:33:05.7 | 186.6 x 21.4 (design) | -1.207 | flown after this was written: see the log |
| flown | | 296.9-298.4 ft/s | 05:29:03.1 | 184.6 x 19.3 | about -1.20 | 06:34:50; nose 06:35:00; stop 06:35:33 |

*Why 334, and why TFF is not the flown 34.05 min.*  The burn size follows where on its orbit TIG falls and what apogee the target line asks for.  At TIG this Orbiter's radius (6,722.8 km) is 7.7 km below a post-burn apogee of 190.3 n.mi., so the design needed 283 ft/s retro plus about 180 ft/s radial (root-sum 334); the flown orbit's apogee is about 4 km above its burn radius.  By hand, a tangential burn at apogee from the capture's 188.8 x 183.4 to the flown 184.6 x 19.3 is 293 ft/s, consistent with the flown 297.  Scanning TFF and the target-line angle on the capture (EI pinned at 06:03:06) against the flown burn, orbit and EI angle (scaled 1 ft/s, 1 n.mi., 1 n.mi., 0.01 deg) puts the best at TFF 30.0 / -1.14: the flown burn size, 186.6 x 21.4, EI gamma -1.207.  TIG then falls 4 minutes after the flown one.  Touchdown barely moves with TFF or the EI-to-runway range (about 64 s before the flown 06:34:50 in every run): it is the Orbiter's own orbital phase.  None of this can be closed without the flown pre-burn state, which no document in the cache or the Mission Report gives.

*The tolerance.*  The STS-134 Flight Plan, Final (a one-page overview timeline, launch 2011-04-19 23:48:53 GMT, "14+1+2" days) puts KSC landing at MET 13/17:39; with the two extension days that is 15/17:39, and the flown landing was 15/17:38: the real flight landed one minute from its plan.  Other flown-against-planned differences on the same mission: maximum dynamic pressure 734 psf against 745; FD15 burns SEP2 1.53 against 1.5, NH2 1.83 against 2.0, NSR 2.49 against 2.4, TPI 3.38 against 3.4 ft/s with a 33 s TIG slip; MC2 flown 7.8 minutes after its nominal TIG.  The owner accepted a touchdown 64 s early as close enough (2026-10-25), adding that his own autonomous-landing runs arrive too fast.  End mass in deorb-5 was 93,508 kg = 206,151 lb, 1,688 lb above the documented 204,463 lb (the mass budget is good to about 2,000 lb).

*Three defects found on the way,* all fixed on `undock-model`: `simulatePASS --duration` was a hard 20,000 wall seconds in `fly_rndz134.py` (`FLY_DURATION` is read now); `wait_gmt` slept half the sim-second gap in wall seconds, overshooting by half at rate 3, so the EXEC at TIG-15 s could go in after TIG; and the deorbit never keyed `ITEM 1` (OMS BOTH), while `RCS SEL` from the STORRM burns survived the coast, so PASS planned a 9-minute RCS burn and the OMS never lit (perigee stayed 342 km).

## Open

- PASS's position drifts about 35 ft/min without an update (340 ft to 2,400 ft in 2.5 h); six-hourly uplinks leave a few kft before each, and the flight had GPS 2 on throughout.
- The forward RCS dump after the burn (152/05:45:06.7, 11.04 s) is not flown; its procedure is not in hand.  MAUI (four primary firings totalling 144 s, direction and split unknown), the RCS hot-fire (151/03:30:57), the FCS checkout, the water and FES dumps and the FRCS driver power-down (150/11:50:46) are not flown either (no procedure or no model).
- `fly_sts134` still follows the Entry Checklist from TIG-75; the Deorbit Prep checklist (Rev Q) puts OPS 3 at TIG-2:20, IMU/IMU alignment at TIG-1:10 and the PLBD closing at TIG-2:40.
- The deorbit design against the flown values: the flown pre-burn state is the missing datum.
- The 0.4-0.65 ft/s bias between delivered and asked delta-V in LVLH X on MC5 and TPI is not explained.
- Aft start loads (1,691/1,689 lb) come from the mass budget; the PFS scale gives 1,530 +- 200 lb.
- Codex: message 171 asks which of the FD1-3 data it has applied and what it still needs; unanswered while its FD13 flight runs.

## Side findings from the same sessions (2026-10-25)

The O6 clock froze for 30 s and the MEDS flash was irregular in the owner's demo run.  Measured causes and what was pushed (details in problems.md 8.79-8.81): the X server and the NVS 510 GPU shared with portview, and font metrics and canvas colours that Tk fetched from the X server on every redraw.  `panelO6.py` and `helvetica.py` now cache font metrics and draw new items before deleting the old; `MEDS2.py` follows the wall clock's second for the flash and has a render cache (`NSTS_MEDS_CACHE`) and draw batching (`NSTS_MEDS_BATCH`), on by default since origin/master 3b0bf0182 (`=0` turns them off).  The owner's 30 fps recording of the flash: lit 0.626 s, dark 0.375 s, period 1.000 s, sd 0.030 s over 69 cycles.  The Mac, WSL and Windows 11 peers passed the series (the cache byte-exact everywhere; batching exact on Linux and Windows, 1-2 levels on isolated edge pixels on macOS).  The Windows KVM window-restore is on master as 1412eec.
