# Conventions register

One place for the standards this work applies: what a number *means* (what a height is measured from, which frame, which
clock, what a mass includes), where that was established, and how sure we are.  Written 2026-11-26 after the apsis-height
convention had been chosen wrongly about ten times, each time costing runs before the cause was found.

## Rules

1. **Every convention has a status.**  VERIFIED means tested against an independent as-flown dataset or against the code
   itself, with the method written down.  ASSUMED means inferred, copied from another flight, or read from a comment.
2. **Do not tune to a number whose convention is ASSUMED.**  Verify it first (recipes below), or say in the commit that
   the tuning rests on an assumption.
3. **A convention found on one flight is not a convention for the next.**  STS-81's orbit heights are above the
   equatorial radius; STS-134's were assumed to be above a sphere, and that was never checked.
4. **State a convention where the number is used**, as a flight-file key or a named constant, not as a bare
   `3.854` in an expression.  `apsis_eq` in `sts081-flight.json` is the first.
5. **When two sources disagree, say which one you followed and why**, and add the disagreement here.
6. **Record a new convention or a corrected one here in the same commit** that depends on it.

## Standards documents in the library

| Document | Where | What it settles |
|---|---|---|
| JSC-09084, *Coordinate Systems for the Shuttle Program* | `~/Desktop/sandroid.org/public_html/apollo/Shuttle/` | The frames; **geodetic altitude h is the distance from the point to the reference ellipsoid along the geodetic local vertical**. |
| JSC-14262 / 78-FM-32, *Space Shuttle Astrodynamical Constants* (1978) | same | Gravitational equatorial radius 6378.160 km (sec. 4.2.3.1); **Fischer 1960 ellipsoid: a = 6,378,166 m (20,925,741 ft), f = 1/298.30** (sec. 4.5). |
| Flight Data File Standards | `Shuttle/Other/` | FDF notation; not yet read for this register. |
| Shuttle Reference Data (Rev E, H, I) | `Shuttle/Reference Data/` | Flight-ops reference; it does **not** define what an apogee or perigee height is measured from. |

Neither the Mission Reports, the Missions Summary (NASA/TM-2011-216142) nor JSC-63400 defines the reference for the apsis
heights they quote.  That has to be established per source.

## The register

| Quantity | Convention | Status | Evidence, where used |
|---|---|---|---|
| **STS-81 orbit heights** (159.9 x 84.9 nmi post-OMS-2, 209.7 x 142.4, 209.9 x 201.6; Missions Summary p. 2-98 and Mission Report) | Heights above the **equatorial radius** | **VERIFIED** (2026-11-26) | The Orbiter's own element sets (NORAD 24711, planet4589 `elements/24700/S24711`): the mean elements after OMS-2 give 163.3 x 88.7 above a 6,371 km sphere = 159.5 x 84.9 above the equatorial radius; after OMS-5 213.5 x 145.5 = 209.7 x 141.7; and the Mission Report's burn table at k = 1 from the flown state reproduces the tracked orbits.  `fly_sts134.py` `FL["apsis_eq"]`, `sts081-flight.json`. |
| STS-134 orbit heights (124.3 x 175.8 post-OMS-2) | Assumed above a **6,371 km sphere** | **ASSUMED** | Inferred in `fly_sts134.oms2_targets` from "unreachable otherwise".  The element archive has no 2011 file for Endeavour (S37577 is empty).  Test it against the STS-134 Mission Report's burn-end orbit before relying on it. |
| PASS / `omstarget.py` HA, HP | Heights above the equatorial radius (PASS's A) | ASSUMED (code comment) | `fly_sts134.py`; not rechecked against the FSSR. |
| Earth equatorial radius in the code | `A_PASS_FT` = 20,925,646.3 ft = 6,378,137 m (WGS-84) | ASSUMED | JSC-14262's Fischer a is 6,378,166 m: 29 m (0.016 nmi) larger, negligible for apsides.  Which one PASS itself holds in its I-loads was not checked. |
| Nautical mile | 1,852 m = 6,076.115 ft | VERIFIED (definition) | Used in `rndz_start.py`, `burn_chain.py`, `make_sts081_flight.py`. |
| Geodetic altitude in the sim | First order in the flattening above the WGS-84 ellipsoid | VERIFIED against JSC-09084's definition | `physics.c` `altitude()`; metres of error. |
| **Orbiter mass in vehdyn** | `YAGPC_VEHDYN_ORBITER_KG` is the Orbiter with **full OMS and RCS tanks**; the propellant used (`YAGPC_VEHDYN_OMS_USED_LB`, `RCS_USED_LB`) is then subtracted | **VERIFIED** (reading `vehdyn.c` and the log's `mass_kg`) | The STS-81 mission file gave it the mass at Ti, so the typed STS-134 OMS use was subtracted again and the Orbiter weighed 97,284 kg at Ti.  Now 109,847 kg (A-6 insertion, 242,178 lb) less STS-81's own OMS use.  `fly_rndz134.py` `OMS_USED_LB`, `sts081-rndz.json`. |
| Mass in `undock_start.py`, `make_return_start.py` (`--mass-kg`) | The **current** mass, not the liftoff mass | VERIFIED | `undock_start` had been given 113,478 kg (liftoff); it should be ~101,919 kg (landing weight + OMS-8 + deorbit propellant). |
| Vehicle clock | GMT seconds = day-of-year x 86,400 + time of day (day 1 = 86,400 s) | VERIFIED (code) | `gmt_s()` in `make_sts081_flight.py`, `g()` in `burn_chain.py`. |
| MET | Seconds from SRB ignition (`met_zero` in the mission file) | VERIFIED | Mission Report; STS-81 `1997-01-12T09:27:22.984`. |
| **Mission Report burn numbering** | The OMS MANEUVERS table (p. 18) and the engine valve event list number the burns **differently**: the table's OMS 3 (82 ft/s, both engines) is the valve list's "OMS-4"; the table's OMS 4 (NC-2, right engine, 8 ft/s) is the valve list's "OMS-3".  Follow the **table** (with its Delta-v and duration).  The valve list dates the 82 ft/s burn 013 where the table says 012: a day typo. | VERIFIED | Thrust arithmetic (one engine x 10 s = 8 ft/s; two x 51.4 s = 82 ft/s) and the orbit test (the 013 date gives 180.6 x 130.9 after OMS-5 against the documented 209.7 x 142.4). |
| Where the Mission Report's GMT and MET disagree | Trust the **MET** column | VERIFIED (twice) | The report's GMT day numbers have typos; MET agrees with the Delta-v table. |
| Frame of the vehicle state | **M50** | VERIFIED (code) | `vehdyn.json`, `vehdyn-state:` lines. |
| Target (TLE) states | GCRS ~ J2000, rotated to M50 by `J2000_TO_M50` | VERIFIED (code) | `tle_target.py`, `rndz_start.py`.  `burn_chain.py` from a TLE uses SGP4's TEME as J2000: an error of a few arcseconds, not checked. |
| Relative state | LVLH of the target, x ahead, y = -(orbit normal), z down | VERIFIED (code) | `rndz_start.py`; the mission files' `DX DY DZ` are kft in it. |
| Attitude notation | `-ZLV` = payload bay to zenith; `+ZLV` = bay to Earth; `-ZLV +YVV` is one attitude (bay up, +Y along the velocity: the water-dump attitude) | VERIFIED (code and the STS-134 Flight Plan) | `vehdyn.c` near line 2024; Flight Plan p. 3-12. |
| TGT set times (`T1`, `DT`, `EL`) | `T2 = TIG + DT`; `T1` is minutes after BASE TIME (Ti TIG for sets 10-12; MC2 TIG for 13 and 14) | VERIFIED (code comments, JSC-48072-134) | `fly_rndz134.py` `TGT_SETS`.  Every STS-81 set now aims at Ti+72.1. |
| Ranges in the logs | "truth RNG" is Orbiter-CG to target-CG; the manual phase works in the ODS ring's distance to the port face (100 ft HOLD, 30 ft, contact) | ASSUMED (log reading) | Label which one a number is. |
| OMS engine | 6,087 lbf, Isp 315.1 s, nozzle cant 15.82 deg up and 6.50 deg inboard, gimbal limits 7 / 8 deg | VERIFIED against the FSSR as quoted in `vehdyn.c` | A single engine is steered through the CG (~11.9 deg of yaw); its thrust is 0.503 of a pair's, not 0.5. |
| MECO targets for STS-81 | VI 25,915 ft/s predicted (25,922 flown); FPA 0.5 deg is the **tape's default** | **ASSUMED** | "STS-81's value not found".  The flown post-OMS-2 phase and the 75.5 ft/s OMS-2 do not both fit these (CLAUDE_LOG 2026-11-26). |
| Flight Plan page reading | The timeline's left axis is 3 px per minute at the page images used (`pdftoppm -r 110`); read pages as **images**, the OCR text layer is garbage | VERIFIED (a cross-check against the 1/18:44 contact) | STS-81 Flight Plan pp. 3-12 to 3-14. |
| Element sets | planet4589 `elements/<NNN00>/S<catalogue>`; Mir 16609, STS-81 24711; no 2011 sets | VERIFIED | `tools/mir_elements.py` for Mir. |

## Verification recipes

**Apsis heights of a flight.**  Find the vehicle's own element sets (planet4589, by catalogue number; the Orbiter has
its own).  Take the set after a burn, compute the mean-element apsides above the equatorial radius and above a
6,371 km sphere, and see which matches the document to within a nmi or two.  Then start `burn_chain.py` from the flown
state and check that the report's burns at k = 1 reproduce the later sets.  (Works only to the early 2000s; the archive
has nothing for 2011.)

**A mass.**  Read the `mass_kg=` field of the first `vehdyn-state:` line of the run's `yaGPC2.log` and compare it with
the intended number before anything else; check that the OMS burn time matches the flown one (Ti: 12.0 s, left engine).

**A burn-table check.**  Impulsive burns along the velocity, at the report's times and Delta-v, from the flown state.  If it
fails from the *simulated* state but passes from the *flown* one, the fault is in the simulated state.

## Past errors this register exists to prevent

| Error | Cost |
|---|---|
| STS-134's sphere convention applied to STS-81's apsides | The ascent aimed 3.85 nmi low; the OMS-3 "x1.22" calibration; many runs. |
| Orbiter mass given as the mass at Ti, then typed propellant subtracted again | 8% light Orbiter: OMS burns 10.0 s instead of 11.3 s, every RCS pulse brisk. |
| Undock mass given as the liftoff weight | 11 t too heavy on the undock. |
| Mission Report's two burn lists read as one numbering | A day lost chasing the "right-engine OMS-3". |
| ISS port (PMA-2) hard-coded in `rndz_instruments.py` for a Mir run | Docking flown to the wrong point in Mir's frame. |
| STS-134's target-set DTs kept with STS-81's burn times | MC2 and MC3 aimed at different times. |
| CRT page title matched on the year prefix (`2011/`) | The pre-Ti tracking never ran. |
| Attitude notation read as two separate attitudes | Wrong picture of the rendezvous attitudes. |

Append to this table, and to the register, when the next one is found.
