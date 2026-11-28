# Handoff: a Shuttle-Mir docking simulation (STS-81 first)

Written 2026-11-04 by yagpc2-eb at Ron's request, so the work can be picked up later without the conversation.
STATUS: FEASIBILITY ONLY.  Nothing has been built, run or committed for Mir.  Everything below was read from documents
or measured on the element file; items marked UNVERIFIED are my expectations, not facts.

Ron's standard: NOT the STS-134 level of fidelity.  The Orbiter has to reach Mir and dock at roughly the time the Mission
Report documents.  Procedures may be modified so that OI-34 can stand in for OI-25 (STS-81 flew OI-25).
**SUPERSEDED 2026-11-11: Ron now wants the flight software to be OI-30 (OI301700), not OI-34 -- see "Revision" below.**

## Verdict

Realistic.  STS-81 is the best candidate.  The flown rendezvous burn table, docking times, Mir element history and a detailed
Mir 3D model are all already on this machine.  What is missing is Mir docking-port geometry in the model's frame, STS-81
ascent I-loads, and Mir-flight rendezvous procedures (see Gaps).

## Revision 2026-11-11: fly STS-81 on OI-30 (OI301700)

Ron's decision (2026-11-11): OI-34 was only a stand-in because it is the version we can run.  He would much rather fly STS-81 on
OI-30, which is nearer to what STS-81 flew (OI-25) than OI-34 is.  UNVERIFIED by me: how close OI-30 is to OI-25 in the
rendezvous/orbit-ops/DAP functions the mission uses; the OI-25 CSOM and DPS Dictionary (item 5 below) are the check.  This makes
STS-81 depend on a prerequisite that is a project in its own right: **an OI-30 flight computer that can be IPLed and run.**
That prerequisite is NOT started; nothing below has been run.

Where OI301700 stands (measured from the handoffs, not this session; re-measure before relying):
- HAL/S: the full OI301700 corpus compiles (`successful == attempts`, the 939-module count in the dass-handoff DB, section 1).
- AP-101S assembly: 272 of 272 modules assemble byte for byte against their listings, 0 bytes mismatched (HANDOFF-ASM101S).
- NOT done: link (lnk101), the load-module/CSECT layout, tape build (mass memory volume with OPS load modules), IPL, run.
  The OI340600 link-and-compare work (HANDOFF-OI340600, `modules/sdfpkg`) and `HANDOFF-OI340700-BUILD.md` are the templates:
  OI340600 was assembled and linked, then compared to DASS dumps; OI340700 was then built into the taped volumes
  (`OI340700-OPS*.7z`) that every STS-134 run uses.
- The source is RECOVERED FROM LISTINGS (`~/workspace/PFS/OI301700/`, `OI301700 as received/`): the HAL/S was extracted from the
  output-writer reports, so extraction errors are possible (dass-handoff section 4: "the extractor is the root of every OI301700
  artifact"), and column-1 conditional-compilation letters were lost (memory: oi301700 col 1 is pre-resolved).
- A BIG DIFFERENCE from OI-34: the DASS dumps (`~/workspace/PFS/mafgen/*.fcm`) are STS-134 / Endeavour software.  There is no
  external memory image to compare an OI-30 link against, so link correctness has to be established by other means (the "as
  received" listings' own link/CSECT information, if they have it -- UNVERIFIED; self-consistency checks; IPL and behaviour).
  Ron's standing rule applies: no tape is an original, so a tape of ours cannot be a control.

What this changes for the STS-81 work (everything not about the flight software is unchanged):
1. A new first stage, before any Mir work: get OI301700 linked, taped and IPLed to GPC MEMORY / OPS 1 on yaGPC2.  A draft
   requirements note by the Codex agent exists (`~/workspace-codex/virtualagc/yaShuttle/yaGPC2/Requirements-OI30.md`, untracked
   there; Ron had speculated about the task and never started it; a Codex agent was stopped 2026-11-11) -- read it for the toolchain
   pointers (HALSFC, ASM101S, the PFS source layout), then discard what is out of date.
2. Everything in "Existing machinery" assumes the OI-34 memory map: the I-load tooling (`sts134-dolilu.json`, DASS patch
   summaries), the address-based scrub, the display/keyboard model (OPS/SPEC numbers differ between OI-25/30/34), the GPS inputs
   (1997 had no GPS on OV-104; OI-34 expects it -- this may be easier on OI-30, UNVERIFIED), the ADTA/TACAN set.  Each is a port
   item for OI-30, not a given.
3. STS-134 I-loads are not valid for STS-81 (different flight, different software).  The I-loads would come from OI-30's own source
   defaults plus whatever STS-81 values the Mission Report and FDF give; the DASS patch summaries give nothing for it.
4. Consequently "decide whether to fly OI-34 with Mir as the target" (last step below) is replaced by: fly OI-30 once it runs;
   OI-34 remains the fallback if the OI-30 bring-up stalls (the Mir geometry, ephemeris and burn-table work is software-independent
   and can proceed in parallel with the OI-30 bring-up).
5. Ledger: no entries yet.  A new area (suggest `flight-sw`, config `OI301700`) when work starts.

## What exists, and where

1. STS-81 Mission Report (local copy of the ibiblio file Ron named):
   `~/Desktop/sandroid.org/public_html/apollo/Shuttle/Reports/Mission Reports/STS-81 Space Shuttle Mission Report.pdf`
   Mission Reports for STS-63, 71, 74, 76, 81, 84, 86, 89 and 91 are all in that directory.  STS-79's is NOT in that
   directory but is in the Shuttle directory itself: `~/Desktop/sandroid.org/public_html/apollo/Shuttle/STS-079.pdf`
   (NSTS-37410, November 1996, NTRS 19970008143; https://www.ibiblio.org/apollo/Shuttle/STS-079.pdf, per Ron).  So all nine
   Mir-flight reports are local.  (My first scan missed them because it did not descend into subdirectories.)
   Text extraction used: `pdftotext -layout` (scratch copy was /tmp/claude-1000/mir/sts81.txt, not kept).

2. Missions Summary, NASA/TM-2011-216142 (`20110001406.pdf` in the same Shuttle directory): page 2-98 is STS-81 (and has a
   page for every Mir flight).  JSC-63400 "History of Space Shuttle Rendezvous" (`20110023479.pdf`): Chapter 20 is
   "Mir and the International Space Station" (Table 20.1 lists all Mir flights; the profile is +R bar, ground-up,
   stable orbit; STS-86 was the first ORBT flight; figures 20.16-20.19 are +R bar approach sketches, not data).
   Chapter 20's reference list points to Portree "Mir Hardware Heritage" (NASA RP-1357) and Zimpfer & Spehar, "STS-71
   Shuttle/Mir ...".

3. Mir element history: `~/Desktop/"Shuttle Stuff"/S16609.txt`.  SOURCE SITE: https://planet4589.org/space/ele.html -- a
   historical ephemeris (element-set) archive for large numbers of orbital objects, one file per catalog number (`S<number>.txt`).
   Ron has not checked, but it likely has every object a Shuttle mission needs: other Mir-era targets and deployed payloads
   (Spartan, SFU, TSS-1R, LDEF, Hubble, ISS elements) and Mir itself.  Check there FIRST for any target ephemeris before looking
   elsewhere; the catalog numbers for portview's vehicles are in `portview/vehicles/SURVEY.md`.
   - 16609 IS the NORAD number: the designator on every line is 86 17 A (1986-017A), Mir's.
   - 11,003 element sets, 1986 to 2001.  Three lines per record; the third line is a source tag such as `gb/GB970110.ELM`
     (looks like the NASA/NORAD element bulletins).  SGP4, TEME, UTC.
   - Formatting is not clean: some fields look like `+.00002762` or `051.6501`, and the last records are hand-made with a
     different epoch format.  A loader must tolerate this.
   - January 1997 coverage: 52 element sets between day 005 and day 022, several per day, including 97015.148 (about
     30 min before capture), 97014.827 and 97015.468.  Orbit 51.65 deg, 15.60 rev/day, about 390 km, which agrees with the
     Missions Summary braking orbit (209.5 x 208.9 nmi).
   - Quality: python `sgp4` is installed.  Propagating each set to the next set's epoch (days 014-016) gives position
     differences of 0.3-2 km, but 8 and 11 km across 97015.72 -> 97015.79 -> 97016.24, probably the drag change after
     docking (the stack's ndot jumps).  Use only sets from BEFORE docking for rendezvous planning.

4. Mir 3D model (portview), already in the repo:
   `yaShuttle/discretePanel/portview/vehicles/mir.py` (+ `_mir_core.py`, `_mir_tks.py`, `_mir_soyuz.py`, `_mir_shapes.py`),
   built model in `portview/cache/models/mir/` (`model.json`, `model.npz`, about 15 texture JPEGs, 1.6 MB), also in the
   `portview-cache-*.tar.gz` in the dropbox.  Listed in `portview/vehicles/SURVEY.md` as `mir`.
   - It is Mir as at STS-91 (June 1998), about 119,000 triangles: Kvant-1, Kvant-2, Kristall with the Docking Module on the
     Shuttle port, Spektr, Priroda, Soyuz TM-27 and Progress M-39.  Total mass 128,285 kg.  Body frame and centre-of-mass
     origin documented in the `mir.py` docstring and `model.json`.
   - The layout had been unchanged since Priroda arrived in April 1996, so it should match STS-81 except for the docked
     vehicles (STS-81 saw different Soyuz and Progress) and Spektr (damaged by Progress M-34 on 25 June 1997, after STS-81).
   - UNVERIFIED: where the Docking Module's APAS port sits in that body frame.

5. Software and procedure references already in the Shuttle directory: OI-25 CSOM (4 parts), OI-25 DPS Dictionary,
   `CRT Reference Summary OI-25.pdf`, the OI-34 documents, JSC-10589 RPO Handbook (1988), `Introduction To Space Shuttle
   Rendezvous.pdf`, JSC-48067-81 STS-81 Post Insertion FDF, JSC-480360-89 STS-89 Orbit Operations Checklist, NSTS-12820 Vol A
   flight rules (PCN-8, 1996), and the ISS rendezvous books under `Rendezvous/` (STS-113 onwards, plus 41B and 51I).

## STS-81 facts from the Mission Report (UTC, day-of-year:h:m:s, MET in parentheses)

Liftoff 1997-01-12 09:27:23 UTC (per the Missions Summary, "12:09:27:23Z"); 51.67 deg direct insertion; launch window
6 min 59 s (Mir planar/phase window and ET heating).  Direct ascent, so no OMS-1.

| Burn (report's name) | Time | dV |
|---|---|---|
| OMS-2 | 012:10:10:23.3 (0:00:43:00) | 75 ft/s, 47.6 s, both |
| OMS-3 | 013:13:03:03.3 (0:03:35:40) | 82 ft/s, 51.4 s, both |
| OMS-4 "NC-2" | 013:01:02:27.8 (0:15:35:05) | 8 ft/s, 10.0 s, right |
| NC-3 (RCS, +X) | 013:11:37:23 (1:02:10:01) | 2.9 ft/s |
| NC-4 (RCS) | 014:02:35:21 (1:17:07:59) | 3.3 ft/s |
| OMS-5 | 014:09:10:44.1 (1:23:43:21) | 94 ft/s, 58.5 s, both |
| OMS-6 "NC-6" | 014:23:41:15.6 (2:14:13:53) | 103 ft/s, 63.3 s, both |
| NH (RCS) | 015:00:16:12 (2:14:48:50) | 1.3 ft/s |
| OMS-7 "Ti" | 015:01:13:54.1 (2:15:46:31) | 9.5 ft/s, 12.0 s, left |
| MC-1 / MC-2 / MC-3 (RCS) | 015:01:36:06 / 02:06:16 / 02:16:00 | 0.7 / 0.7 / 0.2 ft/s |
| +X separation | 020:04:02:00 (7:18:34:38) | 3.0 ft/s |
| OMS-8 orbit adjust | 020:13:53:53.2 | 42.7 ft/s |
| Deorbit | 022:13:17:33.2 | 355.8 ft/s |

Docking: ODS powered 015:03:19:25 (2:17:52:03); capture 015:03:54:50 (2:18:27:28); capture latches 015:04:02:36; docking
complete 015:04:02:43 (2:18:35:21).  Hatch opening 015:05:57.  Hatch closure 019:12:46.  Undocking 020:02:15:23.  Landing KSC 33,
1997-01-22 14:22:44 UTC.

Post-OMS-2 orbit 159.9 x 84.9 nmi (Missions Summary), then 209.7 x 142.4, 209.9 x 201.6, 209.5 x 208.9 (braking).  Cargo: Spacehab
double module, ODS; no RMS.  Mated phase: Orbiter takes control about 16 min after docking, Mir takes it on flight day 5.

CAUTIONS:
- The report's burn names are inconsistent with the Missions Summary (which labels OMS-5 and OMS-6 as NC5 and NC6, while the
  report's acronym list says "NC1-6 rendezvous maneuvers (four)").  OMS-3 (82 ft/s) is not named NC-1 in the table.  Check Table I
  (sequence of events) in the report and the Mir-flight sections of JSC-63400 before reusing the numbering.
- Day-of-year 012 liftoff matches OMS-2 on day 012, but several RCS times above are on days 013/014; the MET column is the cross-check.

## Launch site and lighting (Ron, 2026-11-04)

- STS-81 launched from PAD 39B (Missions Summary: KSC Pad 39B, MLP-2, pad 39B-36), not 39A as STS-134 did.
- In 1997 the two pads looked essentially identical to a casual observer, so the existing pad 3D models can be reused for 39B.
- They are at different physical positions, so the rendered terrain around the pad will differ slightly (new position, and the
  azimuth to landmarks and the horizon change).
- Concrete pad elevation (Ron): 39A is 48 ft above sea level, 39B is 55 ft.  The 7 ft difference matters wherever the sim takes
  the pad altitude (launch-site altitude in the truth model, terrain/height-above-ground for the portview views, the start of
  the countdown/ascent state).  (Done 2026-11-26/27: see "Progress 2026-11-26/27: launch pad and night lighting".)
- STS-81 was a NIGHT launch (Missions Summary: liftoff 4:27:23 AM EST on 12 January 1997 = 09:27:23 UTC; "Shuttle night launch
  #15").  A launch simulation of it needs night lighting modelled: pad floodlighting/xenon searchlights, the exhaust plume and
  SRB flame as the light sources, illumination of the vehicle and the ground, no sun.  Ron had not asked for a launch
  simulation before; he finds this more interesting because a night launch looks visually distinct from STS-134.
  (The post-ISS entry run already got a night-lighting treatment; see TIMELINE-STS134-ENTRY and the portview night code before
  designing a new one.)

## Gaps (what is NOT in hand)

- Mir flight data file procedures (rendezvous book).  The rendezvous books we have start at STS-113.  Burn sizes/times would be
  planned by our own machinery, with the flown table as the check.
- STS-81 ascent I-loads / DOLILU: use the STS-134 ascent and accept a different insertion (UNVERIFIED how far off the
  inclination/phasing would be).
- Mir docking-port position in the model frame, and APAS target geometry for the ODS camera view.
- The mass and inertia of the Orbiter with the Spacehab double module (the sim has STS-134 values).
- Mir attitude profile for the approach (JSC-63400 mentions a Mir attitude request and a mechanism roll alignment of about 1 deg; no numbers).

## Existing machinery to reuse (from the STS-134 work)

- `fly_rndz134.py`, `rndz_start.py`: target line and START_REL machinery; `sts134-targets.txt` format (one `target` line per epoch
  with the ISS state, `lvlh`, ballistic coefficient and port).  The ISS is a point mass in `lvlh` mode in vehdyn with no attitude
  dynamics; Mir would be the same (so a docking model of Mir would also be kinematic).
- `fly_fd13.py` and the planner (`FD13Propagator`): burn design from the truth state, aimed at a target state.  The 2026-11-04 work
  (ledger #325) added an Ti-state aim and an RCS trim; see CAUSES.md #325 before touching it.
- `dock_autopilot.py` (frozen, docking approach), `fly_undock.py` (undock plan) and the portview vehicle kit (`portview/vehicles/`).

## Suggested order when this is picked up

1. Read the STS-81 report's Table I and the rendezvous section; settle the burn numbering; extract a clean event list into a notes file.
2. Write a loader that parses `S16609.txt` tolerantly, picks the last pre-liftoff and pre-docking element sets, and writes a Mir
   `target` line for the STS-134 targets-file format (epoch near the intended Ti).  Check SGP4 TEME -> M50/J2000 handling against how
   `iss-tle-*.txt` is turned into targets today.
3. Check the flown NH/Ti/MC burns against that Mir orbit (propagate Mir and the Orbiter's post-OMS-6 orbit to Ti; does a Ti of 9.5 ft/s
   produce a +R bar intercept at 015:03:55?).  This tests the element set and the burn table together before any sim run.
4. Mir port geometry: find the Docking Module port in `model.json`/`mir.py` coordinates; decide the dock point and approach corridor.
5. Only then decide how much of the ISS procedures (STS-134 Rendezvous book) to adapt, and whether to fly OI-34 with Mir as the target.

## Plan and status as of 2026-11-24 (supersedes the "FEASIBILITY ONLY" status and the 2026-11-11 revision above)

**Goals (Ron, 2026-11-23).**  OI-34.07 is released and working, so two separate goals, each worthwhile alone, both kept documented and runnable:
(A) STS-81 flown on OI-34.07 (procedures adapted OI-25 -> 34); (B) STS-81 flown on OI-30.17 (OI301700).  A is not a stepping stone to be
discarded.  Order: A first; OI-30.17 bring-up (link, tape, IPL to OPS 1; lnk101, the OI340600 link-and-compare and OI340700 tape-build
handoffs as templates) is a PARALLEL track that does not block A.  Do NOT borrow the OI-34.07 memory map for OI-30.17: the layout must come
from an OI-30 link, the OI-34 DASS dumps validate only OI-34, and address-based tooling (I-loads, scrub, ledger addresses) needs true OI-30
addresses.  Re-measure before relying: OI301700 HAL/S corpus compiles in full, AP-101S assembly 272/272 byte for byte (2026-08-08); link,
tape and IPL not done.  Codex's draft `~/workspace-codex/virtualagc/yaShuttle/yaGPC2/Requirements-OI30.md` has toolchain pointers.

**Phases (Ron, 2026-11-24).**
1. STS-81 on OI-34.07, with the post-2000 glass cockpit (MEDS and control panels) AS IS, edgekeys included.  (CURRENT.)
2. Middle phase: a real OI-30.17 mission, STS-117 (chosen by Ron after correcting his launch-time mix-up; glass cockpit as flown; landing on
   Edwards runway 22 by day).  STS-116 (the OI-30-era night launch, 9 Dec 2006) and STS-114 (night landing at Edwards 22) are optional extras.
   Launch/landing times to be confirmed against the Missions Summary.
3. STS-81 on OI-30.17, now simulating the pre-2000 cockpit as far as feasible: a new `MEDS2.py --mcds` switch (beyond `--no-edgekeys`)
   that also removes the edgekey-menu canvas area and renders green-on-black monochrome, plus whatever else the MCDS-era CRTs need
   (check the DEU vs IDP display formats); and the ADI and other PFD elements, which were physical instruments on panels F6 and F8 --
   a NOTE only so far, the pre-2000 panel elements need more thought.

**Method for phase 1.**  STS-81 is a new FLIGHT, not a new tape: `fly_sts134.py --flight FILE` (ascent through ORBIT) and
`fly_rndz134.py --mission FILE` (rendezvous, from the JSON keys epoch, ti_tig, met_zero, rnp, norad, orbiter_kg, tgt_sets, targets).
OV-104 had no GPS in 1997 (OI-34 expects it: CGNS_GPS_LOCKOUT, GPS-to-NAV procedures): fly with GPS inhibited; whether TACAN is needed for
entry/landing is open.  Acceptance is the phase chain completing within documented dispersions (the owner's standard), not a match to the record.

**Done so far (2026-11-23/24).**
- `tools/mir_elements.py` (5dd3eb634): loads S16609.txt (11,001 usable sets, 2 hand-made 1999 records dropped), picks the last set at or before
  an instant (never after docking), emits a TLE or a `target` line.  Mir's orbit (a 6765.0 km, e 0.0008, mean altitude 209.0 nmi) matches the
  Orbiter's 209.5 x 208.9 nmi braking orbit; the pad is 1.056 deg off Mir's plane at SRB ignition and in plane +404 s later.
- Flight files (`tools/make_sts081_flight.py`; c4928893b, 1b458faa7, f06d2d7c7): `sts081-flight.json`, `sts081-dolilu.json`,
  `sts081-reconfig.json`.  Sourced from the Mission Report Table I and Missions Summary: SRB ignition 012/09:27:22.984, MECO 09:35:55
  (8:29.9), ET sep 531 s MET, OMS-2 TIG 10:10:23.3 to 159.9 x 84.9 nmi (75.5 ft/s), MECO VI 25,922 ft/s.  `--apogee-trim` (default -6.7 nmi,
  a calibration of the MECO aim) and `--oms-assist-dt` (default 0: STS-81 flew NO OMS assist, the Missions Summary p. 127 says STS-90 was
  the first; verified, OMS burned 43.2 s vs 150.3 s with the tape's 109 s).
- Ascent runs 1-4 (Linux): IPL through OMS2 complete.  Remaining misses: ET sep 5-6 s early (525.8 vs 531 s; not the OMS assist; FPA unknown, the
  tape's 0.5 deg is used; throttle/profile suspected), post-OMS-2 perigee about 78 nmi vs 84.9 (altitudes are above PASS's equatorial radius,
  +-3 nmi convention), inclination 51.687 vs Mir 51.672.  Run 3 tuning: orbit 160.9 x 78.1.
- Report Table I numbering trap: it lists OMS-3 as 013:01:02:27.8 and OMS-4 as 013:13:03:03.4, but chronologically OMS-3 is 012:13:03:03
  (82 ft/s, 51.4 s), OMS-4 = NC-2 013:01:02:27.8 (8 ft/s, 10.2 s, one engine), OMS-5 014:09:10:44.1, OMS-6 014:23:41:15.6, OMS-7 = Ti
  015:01:13:54.1 (12.0 s, left engine).  The table above has the corrected clock times; trust the MET column.
- Rendezvous generalized (`fly_rndz134.py --mission examples/flights/sts081-rndz.json`; `rndz_start.py --norad`; commit a5090222a, TITLE_YEAR
  016b4b97a: the CRT titles show 2011/ whatever the date).  Ti burn on Mir: 10.00 ft/s, left OMS 12.40 s (flown 9.5 ft/s, 12.0 s); independent
  Lambert agrees; T2 arrival X -900 Y 0 Z +1800 ft.  Star tracker and radar navigation phases ran on Mir's state; MC1-MC4 and ARRIVAL (about
  1500 ft) flew.  The Ti point and TGT sets are STS-134's, an assumption (STS-81's MC-1/2/3 at Ti+22/52/62 min fit them).
- Docking port: Mir's model frame is turned 180 deg about X in `portview/vehicles/mir.py` (369559f6a), so the Docking Module's free APAS face
  (2.929, 0.081, 17.698) m is on the +Z/nadir side under `lvlh` (the Shuttle docked from below), axis +Z; `tle_target.py --port` takes the axis and
  up too; the Mir target line carries it (`sts081-targets.txt`, regenerate with the same command).  No vehdyn.c change.  Cached portview models
  need `fetch_assets.py --vehicles mir --rebuild`.  APAS-89 (Mir) vs APAS-95 (ISS): the ODS is the same hardware and vehdyn's capture is
  geometric (closing <= 0.20 ft/s, lateral <= 4.2 in, angular 4 deg), so no mechanism model is needed (from memory, to confirm).
- Run rz4 (IPL through HOLD, full chain): RBAR/RPM/TORVA/VBAR/HOLD all ran; HOLD at 100 ft from the port within 3 ft; manual-phase RCS
  347/71/354/150/17 lb.  `dock_autopilot.py --from DOCK30` on that capture flew 100 -> 30 ft along the port axis with lateral rms 0.3 ft;
  the leg to contact/capture was running when this was written (result in ~/work/sts081/dk1.out).

**Open items.**
- (UPDATED 2026-11-25, see the investigation and RENDEZVOUS_PLAN 5o: the cause was the pre-Ti TRACK never running; relative nav is now good to Ti+105 and diverges only inside ~800 ft.)  PASS's onboard range to Mir at HOLD is about 10x the truth (1.7 kft vs 170 ft; filter error +1.6 kft LVLH x, slowly growing): a target-state or
  nav mismatch, invisible to the truth-driven manual phase.  Investigate (target epoch/propagation, RR and ST marks).
- Unsourced: Mir ballistic coefficient (130 is the ISS's), the port's "up" axis (+X; now -X, see the 2026-11-24 entries), Mir's attitude (lvlh nadir assumed), weight at SRB ignition
  (242,000 lb estimated; ET/SRB masses are model defaults), the 1997-01-12 Cape sounding (74794) and message 11, pad 39B position/55 ft elevation
  (the code uses 39A, 48 ft), night-launch lighting, the Table I OMS-5/6 naming versus the Missions Summary's NC5/NC6.
- (DONE 2026-11-25 for STS-81: capture, mate, undock, SEPX, deorbit, entry and landing, see the progress section) Remaining chain: undock, deorbit, entry and landing generalized (KSC 33, 1997-01-22 14:22:44, a wizard option), GPS/TACAN handling, then the
  scripts for OI-30 and the phase 2/3 work above.

## Progress 2026-11-24/25: the STS-81 chain on OI-34.07 (from CLAUDE_LOG, synced 2026-11-25)

Entries as written during the work, in order; later entries supersede earlier ones where they differ (e.g. the "Open items" above are updated by the final entries here).

### 2026-11-24: Dk1: no contact, the port was the ISS's PMA-2

- STS-81 dk1 (dock_autopilot --from DOCK30 on rz4's HOLD): NO CONTACT in 60 min.  Cause found: discretePanel/examples/flights/rndz_instruments.py hardcodes the ISS's PMA-2 (PMA2 = (15.655, 0, 5.562) m in the target body frame) and rndz_manual/dock_autopilot read "ring from PMA-2" from it, so rz4's RBAR..HOLD and dk1's DOCK30/DOCK were all flown to the ISS point in Mir's frame, not to the port in the target line (2.929 0.081 17.698, axis +Z); vehdyn's own contact test (needs the ring within 0.5 m of the real port axis, dock_check) never fired (no "vehdyn: CONTACT" line).  rz4/dk1 therefore prove the chain runs, not that Mir's port is reached.  The V-bar final approach, the 100 ft HOLD and the goal frame (X along the port axis) are also ISS geometry; Mir's final is R-bar (axis nadir).
- NEXT: take the port (B, axis, up) from the mission targets into rndz_instruments (PMA2 and the port frame), generalize the manual-phase goal frame to the port axis (R-bar final: RBAR to the port, no V-bar leg), then re-fly rz4/dk1.  Also still open: PASS's onboard range to Mir ~10x the truth.

### 2026-11-24: Rule: sim geometry must agree with the portview model

- RULE (owner, 2026-11-24): the sim's port/contact/capture geometry must agree with portview's 3D model even where the model is inexact; never "docked" with the view showing a gap or overlap.  Memory sim-consistent-with-3d-model.
- Checked: the portview Mir cache on this machine was stale (9 Oct, old frame: docking tip not at the port); rebuilt locally (fetch_assets.py --vehicles mir --rebuild, git-ignored cache).  A fresh build has the Docking Module's free APAS on the axis at (2.929, 0.081) with the structural ring end at z 17.698 (apas() x 4.30 + 0.40) and the guide petals protruding to 18.018 (0.32 m beyond).  So the target-line port (17.698) is the structural interface plane, the petals stand 0.32 m proud of it.
- TODO: (1) derive the port in the target line from the model (meta 'port'), not typed constants; (2) when docking works, view the mated and at-contact states in portview and confirm the Orbiter's drawn APAS ring meets the DM's plane (petals interleaved, no gap/overlap), as for the ISS; (3) fix rndz_instruments.PMA2 (the Python side still points at the ISS's PMA-2).

### 2026-11-24: Flight Plan attitude timeline and the docking attitude

- STS-81 Flight Plan (JSC-48000-81, "L-3 month vector"; pdftotext garbles the scanned pages, READ THEM AS IMAGES: pdftoppm -f N -l N -r 120) Attitude Timeline pp. 224-229 (8-2..8-7): ALL attitudes M50, PYR Euler sequence.  DMT = Moscow time = GMT+3 (p. 50: docking 1/18:44 MET = 07:06 DMT = 014/04:06:23 GMT).  THE PLAN docks on 014 (MET 1/18:44), a day before the flown 015/03:54 (MET 2/18:27): it is a plan, not the flown profile.
- DOCKING ATTITUDE (p. 225, rows 23-24, MET 1/17:15 and 1/17:25 = 014/02:37 and 02:47 GMT): ESTABLISH RBAR = LVLH R0 P0 Y0 (TGT=2 Earth, BV=5, P=270, OM=0); then "Docking Att, Tail Fwd, +ZLV -XVV" = LVLH R180 P180 Y0 (OM=180): the Orbiter flies the R-bar docking TAIL FORWARD, bay toward Mir (zenith), +Z nadir, +X = -velocity.  FINAL APPROACH row 25: Ku to comm at RNG = 100 ft (MET 1/18:12).  vehdyn's mated pose has Orbiter +X along the port's "up": so for lvlh Mir (+X velocity) the port up should be -X, not +X (sts081-targets.txt currently 0 0 1 / 1 0 0).  Mir's own roll about the port axis (Mir attitude "DOCKING ATTITUDE (OSC-7)", p. 50) is NOT in the plan; it must make the DM's and ODS's petals interleave (3-fold, 120 deg steps) with the Orbiter tail forward.
- Attitude IDs: "I05.1-35+00" = "IO 5.1/-35/0" (event column, p. 226 row 27): an inertial orientation of the docked stack, Sun-referenced (SUN P=354 Y=23, OM=112), reached by an INRTL maneuver to R=38 P=79 Y=282 at MET 1/19:05 (014/04:27 GMT) after capture (this is the "SHUTTLE ATT MNVR (I05.1-35+00)" on p. 50).  "I03.2-48+180" = IO 3.2/-48/180 = R=92 P=65 Y=303 at MET 3/20:00 ("MIR CNTL'D MNVR", FD4); "I03.2-48+00" is the same orientation in the Orbiter's frame (the +180 is the Mir-vs-Shuttle frame flip).  "GO-5.3" = a gravity-gradient (LVLH) stack orientation: LVLH R=277.63 P=279.03 Y=317.13 = UNIV PTG TGT 2, BV 5 P=316.5 Y=356.2, OM=275.6.  These stack rows are Sun/torque-equilibrium attitudes, not the docking attitude; they do not give the port axis directly.

### 2026-11-24: Capture and hard mate on Mir (27d53aca1)

- STS-81 on OI-34.07: CAPTURE AND HARD MATE ON MIR (commit 27d53aca1).  rndz_instruments.py now takes the port (B, axis, up) from the targets-file line (set_port/parse_port; ISS defaults unchanged) and the mission JSON's "approach": "rbar"; rndz_manual.py: for an R-bar approach the ODS-point state is in the port's frame (x along the port axis, so the ISS goals [d,0,0] fly Mir's R-bar), RBAR's goal line is the port's R-bar, RPM and TORVA are skipped, and the docking attitude is the Flight Plan's (UNIV PTG TGT 2 BV 5 P 270 OM 180 = LVLH R180 P180 Y0, tail forward).  sts081-targets.txt port up is -X (Orbiter +X = -V when mated).  rz5 (--from RBAR --to HOLD): ring 100 ft out within 1.7/1.5/2.9 ft; manual-phase RCS 342 (RBAR) / 674 (VBAR) / 26 (HOLD) lb.  dk2 (dock_autopilot --from DOCK30): vehdyn "CONTACT ... closing 0.119 ft/s, lateral 1.89 in, pitch +0.29 yaw -0.11 roll -0.50 deg -- CAPTURE", A7L hard mate.
- STILL TO DO for the owner's consistency rule: portview check at contact and mate (dk3 with --portview --views up,cl; screenshots in ~/work/sts081/shots), petal clocking (DM petals vs the ODS's) fixes Mir's roll about the nadir; PASS range-to-Mir 10x error; undock, deorbit, entry and landing for STS-81.

### 2026-11-24: Portview check of the docking, and the post-docking chain

- Portview check of the Mir docking (dk4, standalone `portview.py --views up,cl --port-base N --snapshot PREFIX` run beside the sim; `import -window` of a GL window is black, use --snapshot): /mnt/STORAGE/forClaude/sts081-shots/ pre10-cl.png (10 ft), mated-cl.png (hard mate), mated-up.png.  The centerline camera shows the Docking Module's APAS ring and its petals centred in both; at mate the ring fills the view with the petal pattern interleaved.  A side-on external view of the mated ring planes (no gap, no overlap) is NOT yet checked.
- POST-DOCKING CHAIN (to do): the STS-134 recipe is year-agnostic where it matters: tools/undock_start.py (docked stack on a fresh PASS boot at the new date, --base), fly_undock.py (HOOK/FREE/UNDOCK GMT constants are day 150 of 2011; its FLYAROUND/SEP1..SEP3/STORRM legs are STS-134's), make_return_start.py (undock_coast physics carry + fresh PASS + orbit_overlay; 1293840000 = 2011-01-01 hardcoded), fly_return.py (G(152,...) day numbers, KSC 15).  STS-81 flew: ODS power 020:01:46:24, undock complete 020:02:15:24, fly-around, +X separation 3.0 ft/s 020:04:02:00, OMS-8 42.7 ft/s 020:13:53:53, deorbit 355.8 ft/s 022:13:17:33.2, KSC 33 landing 022 14:22:44.  Plan: mission-file the GMT constants, Mir targets-at-undock line from the post-docking element sets (S16609), skip the STORRM re-rendezvous, +X separation then coast, return start on 022 (TIG-4 h), fly_return --from ORBIT with runway 33.

### 2026-11-24: Undock on Mir works (fb8ad7340)

- STS-81 UNDOCK ON MIR WORKS (fb8ad7340): undock_start.py (rz5's mated capture on a fresh PASS boot at 1997-01-20T01:40, Mir's line from the post-docking sets, port up -X) then fly_undock.py --mission sts081-rndz.json --from SEPCFG --to SEPX: SEPCFG keys the Flight Plan's docking attitude (UNIV PTG TGT 2 BV 5 P 270 OM 180, "att" in the mission's "undock" block), UNDOCK: hooks open (UNDOCK COMPLETE 130 s after the command, MR 127 s), the Orbiter separates along the port axis (the nadir for Mir; port_axis_lvlh) at 0.35 ft/s to 150 ft; SEPX (new): the Mission Report's 3.0 ft/s +X separation (got -3.04 ft/s LVLH x), flown 15 min after the undock instead of 020:04:02 (no fly-around is flown here, so nothing holds the Orbiter near Mir for 1h45m): range 495 ft at the end.  Mission block keys: undock{free,hook,undock,att,sepx}, return{tff,gamma_ei,ei,landing,runway_slot,runway}.  apply_mission no longer overrides an explicit --targets.
- NEXT: make_return_start.py (--year 1997 --norad 16609 --mission --sim-props; vehdyn_coast built at build/vehdyn_coast) carries the separated Orbiter's physics to 1997-01-22T10:00 on a fresh boot; then fly_return.py --mission --from ORBIT: deorbit targets for KSC 33 (slot 2) near the flown landing 022/14:22:44, entry (STS-134's flown entry I-loads, OV-105 GPS/TACAN question for OV-104), landing.

### 2026-11-24: Owner: match flown before the next phase

- OWNER (2026-11-24): do not progress to the next plan phase before the simulated STS-81 times and orbits agree with the documented as-flown values; avoid extra burns, GPS where no GPS flew, etc.  First end-to-end chain (IPL to landing run in progress) is a first draft.  Timing vs the Mission Report: Ti 01:13:54 (set), MC-1/2/3 about 2/3/4 min early (STS-134 TGT sets), capture 04:21:46 vs 03:54:50 (+27 min), hard mate 04:31:54 vs 04:02:43 (+29), capture to mate about 10 min vs 7:53.
- DEVIATIONS TO REMOVE, in order: (1) ascent ET sep 5-6 s early, perigee ~6 nmi low; (2) the rendezvous starts at Ti-68 min from a constructed relative state, not the flown OMS-3/NC-2/NC-3/NC-4/OMS-5/OMS-6/NH burns (check post-burn orbits against 209.7x142.4, 209.9x201.6, 209.5x208.9); (3) MC-4 is flown, STS-81 had only MC-1..3 (01:36:06, 02:06:16, 02:16:00): Mir-designed targeting; (4) approach pace so capture ~03:54:50 and docking complete ~04:02:43; (5) GPS inhibited (OV-104, 1997) and entry without it (TACAN?); (6) Mission Report weights; entry I-loads are STS-134's (say so, or find STS-81's).

### 2026-11-24: First return run, and the ascent timing analysis

- First return run (ret2) result: deorbit burn fired once DEORB MNVR's TIG was keyed with the right MET zero (fly_sts134.T0 now set from the mission's met_zero in apply_mission; before, TIG came out as MET -114 days from STS-134's day 136); post-burn orbit 388 x 62 km; the planner's TIG 022/13:17:30.1 (flown 13:17:33.2), TIG-to-EI 33.5 min, EI 13:51:00 (REI 7690 n.mi.); entry keyed HORIZ SIT runway KSC 33.  The LAND leg ended at "time is up" at EI+~15 min (M 27, 285 kft): the driver's land_time is 900 s unless FLY_DURATION (the wizard sets FLY_DURATION=60000).  And it keyed STS-134's GPS steps (INCORPORATE at deorbit and at V=7K, GPS TO NAV AUTO "prime for entry on OV-105"), which OV-104 in 1997 did not have: now mission "no_gps": true sets FLY_NO_GPS=1 and fly_sts134 skips all three (PASS then uses TACAN, landaids.c models its RA reads).  ret3 = the rerun from pre-ops301 with FLY_DURATION=60000.
- ASCENT TIMING ANALYSIS (run4 logs, sim vs Mission Report Table I): SRM ignition to SRB sep 125.1 s (flown 125.7), to ET sep 525.8 s (flown 531.0): the gap grows only in stage 2 (381.7 vs 386.3 s, 1.2%); max-q 47 s vs flown 53 s; the sim's throttle bucket is STS-135's (72 %, T+38.7 to 56.8) against STS-81's flown 70 % from T+31.1 to 60.7, the booster 50-psia time STS-134's 120.13 (flown 120.41).  make_sts081_flight.py now writes THROT [104, 70, 104, 104], QPOLY [66, 770, 1447, 10000] (the simulated vehicle's Vrel at the flown times, from run4) and env SSME_ISP 453.59 (the flight-derived average, Mission Report p.~3; the tag was 453.18) and SRB_PC50_S 120.41; ET_LB/SRB_LB already from A-6.  The bucket alone is worth ~1 s of the 5.2 s; the rest is untested (ET inert is the SLWT's 58,500 lb in vehdyn.c where ET-83 was a LWT; the orbiter's 8 k lb ascent consumption, A-6 250,167 -> 242,178 lb, is not modelled).  run5 (--to ASCENT) tests the first set.

### 2026-11-24: Ascent tuning result

- ASCENT TUNING RESULT (run5, flown throttle bucket 70 % T+31.1-60.7, THROT/QPOLY, SRB 50 psia 120.41 s, Isp 453.59): SRB sep MET 125.44 s (flown 125.72), ET sep 530.32 s (flown 531.0; was 525.8), MECO orbit 157.9 x 40.7 nmi (eq radius), inclination 51.670 deg (Mir 51.672; was 51.687).  The 5 s ET-sep error was the throttle schedule, not mass.  Apogee 2 nmi under the 159.9 aim: --apogee-trim now -4.7 (MECO radius a + 51.60 nmi; STS081c.mmv = STS081b with that one cell changed via mission_reconfig, spec in the log of this entry: was 47144054EFF07320, now 47144156F9BCDDB6, --mem run5/sts081-terminal/gpc1.mem.bin).  run6 (--to OMS2) tests it.
- RETURN: with OMS-8 (020:13:53:53.2, 42.7 ft/s, 25.6 s, Mission Report) carried over the coast as an impulsive retrograde burn (make_return_start --burn; direction not stated in the report, retrograde fits), the deorbit planner's TIG is 022/13:17:01 (flown 13:17:33.2) and EI 13:50:31 / landing about 14:22:13 (flown 14:22:44): the orbit phase matches the flown within ~30 s; without OMS-8 it was 14.5 min late and the planner needed REI 7,690 n.mi.  OPEN: the planner's impulsive dV is 270 ft/s against the flown 355.8 ft/s (deorbit design parameters tff/gamma are STS-134's); vehdyn_coast.c takes VEHDYN_COAST_JAN1 (uncommitted, C).  ret5 = the return from ORBIT, to LAND, GPS off; the LAND leg needs RETURN_LAND_TIME (the 900 s default ended ret2/ret3 at EI+14 min).

### 2026-11-24: Orbit convention, run6

- ORBIT CONVENTION (project's own finding, TIMELINE-STS134.md "Apsis conventions"): the Missions Summary / Mission Report orbits are heights above a 6,371 km sphere, 3.854 nmi below the equatorial radius the vehdyn-orbit log uses.  STS-81's 159.9 x 84.9 nmi post OMS-2 is therefore 156.0 x 81.0 above the equatorial radius; 209.7 x 142.4 = 205.8 x 138.6; 209.9 x 201.6 = 206.0 x 197.7; 209.5 x 208.9 = 205.6 x 205.0 (braking orbit; Mir's mean altitude from the 97014.827 set is 209.0 above the equatorial radius, so the braking orbit is about 3.4 nmi below Mir's).  My earlier apogee tuning (trim -6.7, then -4.7) compared the eq-radius number with 159.9 directly: wrong by 3.9 nmi, and run5's "157.9" was an osculating value 3 min after ET sep, not comparable.  The OMS-2 perigee design (HT 81.05 for 84.9) already had the conversion.
- run6 (trim -4.7): ET sep MET 530.4 (flown 531.0), OMS-2 TIG MET 2579.7 (flown 2580.3), dV 72.8 ft/s (flown 75.5), post-burn 162.9 x 80.2 eq = 166.8 x 84.0 in the report's convention: perigee within 1 nmi, apogee 6.9 nmi too high.  Aim-to-measured bias of the generator's MECO radius for apogee: +7.4 nmi (run4 +6.9, run6 +7.7), so --apogee-trim -11.3 (default now; MECO radius a + 49.35 nmi; STS081d.mmv = STS081c with that one cell, was 47144156F9BCDDB6, now 47143E019CB6FDE0).  run7 tests it.

### 2026-11-24: Run7, the burn table to Ti, and the rendezvous start

- run7 (apogee trim -11.3): ET sep MET 530.1 (flown 531.0), OMS-2 TIG MET 2579.4 (flown 2580.3), post-OMS-2 apsides at burn end HA 155.5 / HP 80.5 above the equatorial radius = 159.4 x 84.4 in the report's 6,371 km convention (flown 159.9 x 84.9); OMS-2 dV designed 79.3 ft/s (flown 75.5, the sim's MECO perigee is ~2 nmi lower than flown's); inc 51.69 deg (Mir 51.672).  Ascent is now within ~1 s and ~0.5 nmi at the burn.
- BURN TABLE TO Ti (impulsive along the velocity, ~/work/sts081/burn_chain.py): with the Mission Report's burns as listed (OMS-3 82, NC-2 8, NC-3 2.9, NC-4 3.3, OMS-5 94, OMS-6 103 ft/s, all prograde at their flown times) the orbit after OMS-5 is 217.0 x 128.0 and after OMS-6 215.1 x 179.8 nmi (6,371 km sphere) against the Missions Summary's 209.7 x 142.4 and 209.9 x 201.6: perigee 14-22 nmi low.  No shift of the OMS-3 time (-30..+30 min) and no uniform dV scaling reproduces both orbits (the 142.4 perigee needs ~55 nmi of perigee gain from ~96 ft/s of burns, the ideal 0.568 nmi per ft/s of an apogee burn; our OMS-3 is 32 deg before apogee, efficiency 0.85).  Scaling OMS-3 alone by 1.20-1.25 gives 214.1 x 141.7 / 208.1 x 203.5 (k 1.2) and 212.5 x 145.4 / 210.7 x 204.7 (k 1.25).  UNEXPLAINED; used as a labelled calibration, k = 1.22 (OMS-3 effective 100 ft/s).  Candidates: unlisted burn pitch/plane content, drag, the Missions Summary's apsides being predicted values, J2 osculating differences of ~3 nmi.
- Rendezvous start (no more constructed relative state): make_return_start.py --base-phase ipl --out-name sts134r-ipl --burn ... (all seven burns incl. NH 00:16:12) --mass-kg 105600 (A-6 insertion 242,178 lb less the burns' OMS propellant) on a fresh boot at 1997-01-15T00:21:00 (mission epoch moved from 00:05:54: NH is carried by the physics, not flown by the driver), then fly_rndz134 --from UPLINK.

### 2026-11-24: First landing attempt, and midcourse

- First end-to-end STS-81 landing (ret6, entry/landing GPS-off, mass 112.9 t = 249 klb as carried): reached M 1.65 at 69 kft normally (alpha 14, q 189), FCS SATURATION at GMT 022/14:51 (about M 1), alpha 56 -> -87 at 52 kft, "ON THE GROUND WITHOUT THE GEAR".  Suspects: the vehicle is ~25 klb over the flown landing weight (A-6: 215,337 lb; the sim's orbiter mass never drops to it: 250 klb at SRB ignition minus propellant only), and no GPS (TACAN path).  ret7 = the return rebuilt with --mass-kg 101,470 (215,337 + 7,860 deorbit burn + ~500 entry RCS lb), GPS still off.
- MIDCOURSE: mission "midcourse": 3 drops MC-4 (fly_rndz134 LAST_MC = 13, arrival = MC-3's T2, set 13 now aims at the R-bar point 600 ft below); TGT sets 11/12/13 carry STS-134's offsets and DTs with the flown times as T1 (22.2, 52.4 min after Ti, MC2 + 9.73 min).  rr2 = fly_rndz134 --from UPLINK --to ARRIVAL on the carried burn-table start (sts134r-ipl at 1997-01-15T00:21:00, mass 105,600 kg).

### 2026-11-24: Phasing of the burn-table carry; decision; JSC-63400

- PHASING OF THE BURN-TABLE CARRY: from the run7 OMS-2 capture through OMS-3..NH (OMS-3 x1.22) the Orbiter is at 00:21 on 15 Jan 1,680 n.mi. AHEAD of Mir (X +10.2 Mft, the design is X -187.5 kft = 31 n.mi behind), 34 n.mi out of plane (RAAN 134.54 vs Mir 135.30 deg), and the Ti burn the PASS solved was 51.6 ft/s (flown 9.5).  Findings: (1) PLANE: the launch targeting had DELTA_NODE_PHASE 0; the lower Orbiter regresses 0.76 deg more than Mir in 3 days, so the flown launch plane must have led Mir's by about 0.76 deg (rotating the carried state by +0.76 deg about the pole nulls Y to 70 ft).  (2) PHASE: X moves -496 kft per +1 % of OMS-3 dV, -141 kft per +1 % of OMS-5, -3.6 kft per +1 % of OMS-6; the 27 deg (10.4 Mft) needs ~+21 % on OMS-3, which would break the documented apsides.  The phasing is the ground's NC targeting from tracking; our a(t) cannot be known to the 0.1 n.mi that 24 orbits need.  A Gauss-Newton solver diverged (X is 2000 sigma off); abandoned.  (3) OMS-3 in our orbit is 32 deg before apogee (efficiency 0.85); the report's OMS-6 103 ft/s at apogee gives exactly the documented perigee +59.2.
- DECISION: the rendezvous starts, as in rz4, from the constructed Ti geometry (rndz_start: Mir's TLE state plus the designed relative state; it reproduces the flown Ti 9.5 ft/s to 10.0), now at 00:21:00 with MC-1/2/3 at the flown times, no MC-4 (Figure 20.17 of JSC-63400, the STS-81 profile, still labels 'manual takeover MC-4+2 min'; the Mission Report lists only MC-1..3 as flown), orbiter mass 105,600 kg.  The burn-table carry (burn_chain.py, solve_chain.py in ~/work/sts081, not in the repo) is kept as a CHECK of the documented orbits, disclosed as such.  NEEDED LATER: DOLILU DELTA_NODE_PHASE (plane lead ~0.76 deg) for the ascent.
- JSC-63400 (History of Space Shuttle Rendezvous) p. 138: STS-76/79/81/84 flew TAIL-FORWARD dockings (for Mir communications); Fig. 20.17 STS-81 profile: manual takeover (MC-4+2 min) about 2,800 ft below, +R-bar crossing, braking gates 2,000-1,200 ft, +R-bar arrival with a tail-forward maneuver, 170 ft station-keeping (Russian ground station coverage, if required), 30 ft station-keeping, docking.

### 2026-11-24: Landing failure analysis; rendezvous timeline (rr5)

- LANDING FAILURE (all STS-81 entries so far): the entry is normal to Mach ~1.6 (alpha follows 40 -> 14 deg), then at ~M 1.5 / 69 kft (t ~ +16830 s on the run clock) alpha climbs (14.3 -> 15.0 -> 18.1 -> 20.7 -> 28 deg at M 1.0), bank steps -30 -> -48 -> -53 deg, elevon commands grow TE-up (-3.9 -> -8 deg), FCS SATURATION by ~M 1.0, tumbling below M 0.64, "ON THE GROUND WITHOUT THE GEAR".  Same in ret6/7 (KSC 33, GPS off, 113 t and 98.3 t), ret8 (93 t) and ret9 (GPS on).  NOT: weight (landing weight 215,337 lb is typical; Missions Summary A-pages, 109 flights: landing X CG mean 1085.5, sd 5.4, STS-81 1083.1 vs STS-134 1082.3), CG (vehdyn's 1100 in is only the body-offset origin), GPS, the truth atmosphere (checked: implied density / table = 1.000 +- 0.001 from 97 to 52 kft; the 22 Nov atmosphere fix was at 66 km and 86 km).  Suspects: KSC 33 geometry (never flown to completion in the repo's records), the sim's ADTA air-data alpha (src/adtaair.c clamps alpha to -4..20 deg as PASS does) and the FCS alpha loop.  ret10 = the same orbit on runway 15 (planner TIG 13:17:00.5, EI 13:50:30.6, identical to the KSC 33 plan: REI 4,400 fixes the EI point).
- RENDEZVOUS TIMELINE (rr5, MC-1/2/3 at flown times, STS-134's TGT offsets): MC1 0.35 / MC2 0.24 / MC3 3.26 ft/s (flown 0.7 / 0.7 / 0.2), Ti 9.9 ft/s (flown 9.5), arrival at MC3+10 min X -1182 Z +1689 ft at Ti+73.7, RBAR phase start Ti+72.4 (Flight Plan: ESTABLISH RBAR at Ti+72), HOLD 100 ft at Ti+161 (Flight Plan: Ti+129).  A 1000 ft R-bar aim of MC-3 needs 5.5 ft/s.  Tuning (rr6): R-bar leg vmax 1.2 ft/s (was 0.8, took 31 min), closing 0.40 ft/s to 200 ft.

### 2026-11-24: Docking time (dk5) and the entry diagnosis

- DOCKING TIME vs the Mission Report (dk5, rr7 manual phase: R-bar leg 16 min, docking attitude Ti+95, HOLD 100 ft at Ti+141): capture 04:02:14 (Ti+168.3) vs flown 03:54:50 (Ti+160.9), +7.4 min; hard mate 04:12:44 vs 04:02:43 (+10 min); capture to hard mate 10.5 min vs 7.9.  The Flight Plan's own times (Ti+72 ESTABLISH RBAR, +82 docking attitude, +129 final approach at 100 ft, +161 docking).  MIR_CLOSE_FPS 0.50 (was 0.40) to move the 100 ft point to ~Ti+135.
- ENTRY DIAGNOSIS (ret7/8/9/10 all depart at M ~1.5): vs STS-134's AB23 entry the first difference is PASS's lift-vector control: at M 26.8 (q 10 psf, h 260 kft) AB23's bank is -73..-87 deg; ours stays at 0 until M ~20 (bank -30 held to M 10, -18 to M 3, then -30/-55 in TAEM), the vehicle is 14-18 kft HIGHER at the same Mach (278 vs 263 kft), alpha leaves the TAEM 14 -> 9 deg schedule (stays 14 to M 1.5).  Not: GPS, runway (15 and 33 fail alike), weight (93, 98, 113 t), CG, truth atmosphere, PASS's Earth orientation (CGNS_M_M50TOEF_AT_EPOCH read out of the entry capture: Greenwich RA 110.9 deg = GMST of 1997 d12 111.53 less B1950 precession 0.64; RNP_DAY 12, LAUNCH_YEAR 1997), the planner's EI point (GC EI to KSC 33 4,402 n.mi.), nav (PASS error 1.8 kft at TIG), the keyed WT (223.6 klb).  The pass flown is DESCENDING (EI lat +46 lon -176) where STS-134's was ASCENDING (EI lat -30 lon -125): the deorbit planner's --after option finds the ascending pass at 023/04:06:41 (EI lat -31.2 lon -125.3, gamma -1.100, crossrange +163 n.mi., dV 303 ft/s); rt6 builds a return start for it (boot 1997-01-23T00:30) to test geometry.

### 2026-11-24: Docking time (rr8/dk6)

- DOCKING TIME (rr8/dk6, R-bar closing 0.50 ft/s, nmax-12 braking, MC-1/2/3 flown TIGs, no MC-4): ESTABLISH RBAR Ti+72, docking attitude Ti+95 (Flight Plan +82), 100 ft at Ti+130.9 (Flight Plan +129), 30 ft aligned Ti+153.6, CAPTURE 03:53:55 (Ti+160.0) vs flown 03:54:50 (Ti+160.9): 0.9 min EARLY; HARD MATE 04:04:31 vs flown 04:02:43: +1.8 min.  Burns: Ti 9.9 ft/s (flown 9.5), MC-1 0.35 / MC-2 0.24 / MC-3 3.26 ft/s (flown 0.7 / 0.7 / 0.2).  START is the designed Ti geometry (see the phasing entry).

### 2026-11-25: Entry geometry test (ret11)

- ENTRY GEOMETRY TEST (ret11, rt6 start for the ASCENDING pass: TIG 023/04:06:40, EI lat -31.2 lon -125.3, dV 302 ft/s, crossrange +161 n.mi.): entry flew to wheels-stop with no loss of control at M 1.5 (touchdown 16407.9 s, 199 kt, sink 1.9 ft/s) -- so the failure of every STS-81 return so far is tied to the DESCENDING pass geometry (EI lat +46 lon -176), not to date, weights, GPS, atmosphere or runway.  But touchdown was 26.5 n.mi. off the KSC 33 centerline (Y +160,900 ft, X -106,400 ft from the threshold): the +161 n.mi. crossrange of that opportunity is beyond what TAEM absorbs.  Next: why the descending pass fails (PASS bank/roll-reversal logic at high crossrange sign?), and a lower-crossrange ascending opportunity (flown landing 022/14:22:44 has no ascending equivalent near KSC).

### 2026-11-25: Root cause of the entry failures: skip-out

- ROOT CAUSE of every STS-81 entry failure (rt..rt5, ret7-10): the entry SKIPPED OUT.  The planner's gamma_ei -0.96 (STS-134's "design value") gave a 270 ft/s burn (flown 355.8); the post-burn orbit's perigee (84.6 km at lat 51 deg, the descending pass's northern turning point) was only 85 km, so the first dip peaked at q 5.4 psf (below PASS's guidance engagement, bank 0), the Orbiter bounced to 337 kft and re-entered 25 min later over the S Atlantic (6,650 n.mi. from KSC); the "bank -30 constant / alpha early decay / M1.5 departure" was PASS guiding a hopeless range.  The ascending pass (ret11, perigee at lat -31) entered normally.  Earlier hypotheses (date, RNP, GMST, atmosphere item, weights) were all wrong; check GMT of M 27 vs TIG+38 min FIRST.  FIX: gamma_ei -1.37 in sts081-rndz.json (planner burn = flown 355.8 ft/s, TIG 13:17:14 vs flown 13:17:33).  The planner's own note says STS-134's burn implies -1.20.

### 2026-11-25: STS-81 landing (ret12) and Phase-1 gate status

- STS-81 LANDING (ret12, rt5 start, planner gamma_ei -1.37, no GPS, runway KSC 33 via HORIZ SIT item 4): deorbit burn TIG 022/13:17:15 (flown 13:17:33.2) 360 ft/s planned (flown 355.8), orbit after 384 x 25 km; ENTRY flies the whole way; main gear touchdown at 022/14:22:45.5 GMT (flown 14:22:44: +1.5 s), 196 kt, 2.0 ft/s sink, 2,712 ft past the KSC 33 threshold, Y +7 ft (centreline), stop at 9,170 ft.  (The ascending-pass ret11 likewise: 2,479 ft, Y +6.)  tools/touchdown_x.py had the STS-134 RNP (2011 day 136) hard-wired, which made the earlier STS-81 touchdowns read 23-26 n.mi. off the runway; TD_RNP_YEAR=1997 TD_RNP_DAY=12 fixes it.  Phase-1 gate status: ascent (ET sep +0.9 s, OMS-2 +0.9 s), rendezvous (capture -0.9 min, hard mate +1.8 min), undock/SEPX, deorbit TIG -18 s, landing +1.5 s all within about 2 min of the flown record.

### 2026-11-25: TACAN

- TACAN (owner: "complete a full, correct implementation"): history search found NO range/bearing model ever written (only the radar-altimeter words of the TACAN read; the TTS 59Y / COF 97X stations went into the site I-loads on 10-06; 10-30 the session itself said so); implemented now in src/landaids.c (+ mdmdev.c capturing the FIOHO205 control-register write X'200C1', tools/landing_sites.py --navaids-tacan, tools/sites/ksc-navaids-tacan.txt): words per the research agent's spec from GYTTAC/GYUTAC/GVQSIT (0x6CC0 = 251.71875 deg; 257.85 nmi = 0x2578/0x5089; word 6 0x5000, word 7 = control word), magnetic bearing TO the station (GNBTAC.hal:252-257), 29 ms time bias, 400 nmi / radio horizon / 150 kft lock ceiling / 10 s acquisition (assumptions: noise 0.3 deg / 0.03 nmi, 0.5 deg unit bias).  Gate found: PASS runs TACAN only if CGNV_NUM_GPS_INSTALLED < 3 and CGNS_GPS_TAC_CONFIG OFF (volume has 3, ON = OV-105): mission "tacan": true patches @064F4 and @0CAFF live with the entry I-loads (entry_iloads.tacan_cells) and keys SPEC 50 item 19 (AUTO).  test_landaids 31/31, test_mdmdev 100/100, test_vehdyn 81/81.  ret13 (STS-81 return, TACAN on): 143 I-load cells written (141 + 2), TACAN AUTO keyed; at wheels stop CGNV_TACAN_MARK_NUM 135 (7 without TACAN), all three units powered and tuned to -59 (TTS 59Y), station EF in CGNV_R_TACAN_EF; touchdown 2,667 ft past KSC 33, Y +7 ft (ret12 without: 2,712 / +7) -- the dead-reckoned nav was already good enough that TACAN changes the landing by 45 ft.  NOT modelled: O7 rotary contact, antenna offset, plasma blackout, cone-of-silence bearing loss, 40 deg glitches.  C awaits Mac/Win11/WSL.

### 2026-11-25: Investigation of the PASS range-to-Mir error (rr3/rr8)

- INVESTIGATION, PASS RANGE-TO-MIR ERROR (open issue b; rr3/rr8 logs): PASS's relative state is good until the Ti burn (|r| error 9-18 ft, rate 0.01-0.03 ft/s at Ti -33..-1 min) and then drifts: 43 ft / 0.097 ft/s at Ti +3.7, 262 ft / 0.276 at +8.8 (MC1 targeting runs on this state), 450 ft / 0.42 at +25, 190-300 ft through MC3, then 300 -> 3,800 ft by the hold (Ti +73..+133) at ~1 ft/s growth.  Two causes seen: (1) NO USEFUL MEASUREMENTS AFTER Ti: star-tracker angle marks stop at ACPT 106/106 (END S TRK at Ti -19) and the Ku radar never takes over -- RRNAV logged "no radar range under 135 kft by Ti -20 min" (RR RNG 0), kuradar.c "1 locks, 2 losses, not locked", and in the RBAR phase RR RNG reads true range but ACPT rng 0 rdot 0 (range/rdot never accepted: RRNAV's SPEC 33 items 13/17/20/23 not keyed or radar not locked then); (2) a 0.1-0.4 ft/s relative velocity error appears at the Ti burn (9.9 ft/s: ~1-3%) and after each MC burn: PASS's sensed dV vs the truth's delivered dV differ -- same family as the OMS-3 x1.22 calibration (open issue d).  MC burn sizes (0.35/0.24/3.26 vs flown 0.7/0.7/0.2) are computed from this drifting state, so (c) probably follows from (a)+(b).  NEXT: find why the Ku radar did not lock for Mir at Ti -30 min (power ON/steering/mode seen by kuradar_panel; LOS/body-shadow test; reach for a smaller target), key RRNAV items so range is accepted, then compare PASS's sensed vs true dV for the Ti burn.


## Progress 2026-11-25/26, continued (from CLAUDE_LOG, synced 2026-11-26)

The entries below follow the first progress section in time; where they differ the later one stands.

### 2026-11-25: rr12: MC sets aim at one time; drag ruled out for OMS-3

- rr12 (mission file tgt_sets: every MC set aims at T2 = Ti+76.9, the TGT 10 aim, DT 54.7/24.5/14.77 with the flown MC times Ti+22.2/52.4/62.13 and EL 0 on set 12; commit 806a566f8): MC1/MC2/MC3 sensed 0.32/0.75/0.11 ft/s (flown ~0.7/0.7/0.2; was 0.60/1.65/2.98).  Cause of the old MC2/MC3: STS-134's DTs kept with STS-81's burn times aimed the sets at Ti+79.1/83.6/76.6 (and EL 29.07 slipped MC2 to Ti+56.6).  Radar close-range wander cause: see the entry above (kuradar.c 0.3 m, uncommitted C).
- rr12 timeline: ESTABLISH RBAR Ti+77.4 (Flight Plan +72), docking attitude Ti+100.2 (+82), HOLD 100 ft Ti+135.9 (+129), CAPTURE Ti+163.4 (flown 160.9, +2.5 min), hard mate Ti+174.2 (flown 168.8, +5.4 min); capture to hard mate 9.2 min vs flown 7.9 (the A7L sequence waits come from the ISS-era cards: 90 s dampers, 30 s ring check, 198 s ring-in: unsourced for STS-81).  dk12 died once on a keystroke wait ('+3 keys RESUME' not in panel.log), rerun as dk12b OK.  MIR_CLOSE_FPS 0.50 -> 0.55 under test (rr13).
- DRAG is NOT the cause of the OMS-3 x1.22 calibration: burn_chain.py from run7's OMS-2 capture with the density scaled 1.0 / 0.5 / 0.3 (a temporary YAGPC_DRAG_SCALE in physics.c, reverted) gives after OMS-5 217.0x128.0 / 219.1x129.7 / 219.9x130.4 (sphere) vs the Missions Summary 209.7x142.4: apogee 7-10 nmi high, perigee 12-14 low at every scale.  Post-OMS-3 orbit (sim) 165.0x122.6; OMS-3 is 41 deg before the OMS-2-apogee's next return.  The Vallado table is a solar-mean static atmosphere, but a factor 3 in density moves the orbits only ~2 nmi.

### 2026-11-25: Plane lead derived, Mir bc, petals

- PLANE LEAD DERIVED (tools/make_sts081_flight.py NODE_LEAD_DEG 0.758, --node-lead): J2 nodal regression of the Orbiter against Mir (209 nmi circular) over the documented orbits from OMS-2 to Ti (84.9x159.9 2.9 h -0.053; 122.6x165.0 [the sim's post-OMS-3 orbit, the report gives none] 44.1 h -0.605; 142.4x209.7 14.5 h -0.099; rest ~0) = -0.758 deg, matching the 0.76 deg found by trial; sts081-dolilu.json's IYD node now leads Mir's by that (255.504 -> 256.262 deg EF; IYD 0.7595,-0.19637 -> 0.76203,-0.1863).  run8 (ascent to OMS2 on STS081d.mmv, --flight sts081-flight.json, port 43000) tests it.
- MIR BALLISTIC COEFFICIENT: the 130 kg/m2 is the ISS's, unsourced for Mir (TLE B* 4.2-5.6e-5 in Jan 1997, not convertible reliably); the Orbiter-Mir differential drag over the 1-2 h rendezvous is ~5 m: irrelevant to Phase 1.  PETALS/side-on: portview has no external camera (views out of the Orbiter's windows only); the centerline view at mate shows the petals interleaved; the mated ring plane agrees numerically (ring -0.00 ft from the face).

### 2026-11-25: OV-104 TACAN/GPS source

- OV-104 TACAN/GPS SOURCE (open item closed): the STS-81 Mission Report has no operational GPS: GPS appears only as DTO 700-12 (the Litton LN-100G GPS/INS on a PGSC, first flight, p. 36; it did not feed the Orbiter's navigation), so GPS-off entry on TACAN is right for STS-81.  The STS-86 Mission Report (Atlantis, Sept 1997, the same OV-104 configuration) says: drag measurement processing 233,900 -> 84,200 ft, TACAN station acquisition at ~154,300 ft, ADTA data incorporation 81,900 -> 17,400 ft, all residuals nominal.  The landaids.c model (lock ceiling 150 kft with the 400 nmi / radio-horizon limits) acquires within ~4 kft of that; no change.  (The STS-81 report itself is silent on entry nav sensors.)

### 2026-11-25: Docking times on the flown record (rr13/dk14)

- DOCKING TIMES NOW ON THE FLOWN RECORD (rr13 + dk14; commits b3cd1be93, and the apds_waits one): MIR_CLOSE_FPS 0.55 (rr13: 100 ft hold Ti+134.6 [Flight Plan +129], CAPTURE Ti+161.0; dk13 hooks closed Ti+171.3 with the ISS-era card waits) and the mission key "apds_waits" [30, 10, 10] s (ISS cards: 90/30/30; a CALIBRATION to the flown 7.9 min capture->docked complete, no STS-81 card): dk14 CAPTURE Ti+160.8 (flown 03:54:50 = Ti+160.9), HOOKS 1/2 CLOSED Ti+168.9 (flown docking complete 04:02:43 = Ti+168.8), capture to hard mate 8.1 min (flown 7.9).  Rendezvous chain rr12 (MC sets aim Ti+76.9) + rr13 (R-bar from the arrival capture) + dk14 (DOCK30 -> DOCK).  Ti+72/+82/+129 of the Flight Plan: ours 77.4 / 100.2 / 134.6 (ESTABLISH RBAR and docking attitude later than planned, the 100 ft hold 5.6 min late, made up in the final approach: unsourced pacing).

### 2026-11-25: Sim branch merged; rendezvous rework rr14-rr17

- review/sts081-sim MERGED TO MASTER (27b1c244d, 2026-11-26) after the peer gate: kuradar.c close-range wander 3 m -> 0.3 m (YAGPC_KU_WANDER_M), vehdyn.c YAGPC_VEHDYN_ET_INERT_LB, vehdyn_coast.c VEHDYN_COAST_JAN1.  Linux make test passes; Mac (arm64 clang 21, STS-134 radar approach + docking: HARD MATE TCS 5.6 ft, all angles accepted close in), Win11 (MSVC, TAL to ZZA matches master), WSL (clang 21, STS-134 landing chain, fault-free): all PASS, tests test_kuradar 53, test_vehdyn 81, test_mdmdev 100.
- Rendezvous rework (rr14-rr17): every MC set aims at T2 = Ti+72.1 (= flown MC3 TIG Ti+62.13 + 10 min = the Flight Plan's ESTABLISH RBAR at Ti+72); TGT 10 DT 72.1 with the Ti point calibrated to -66.04 kft behind (mission key "ti_point", fly_rndz134 TI_POINT -> rndz_start --ti-point=; STS-134's -48.6 gave 10.58 ft/s, flown 9.5, now 9.49; offline Lambert scan via rndz_start functions: 9.91 vs PASS 9.82 at DT 76.9, 10.44 vs 10.58 at 72.1).  MC1/2/3 then sense 0.28/0.00/0.00 ft/s (PASS's own MC2/MC3 solutions ~0.06): the transfer is already on target; the flown 0.7/0.7/0.2 were dispersion corrections (checklist 3-sigma MC1 0.6/0.7/1.2, MC2 0.4/0.2/2.5), which a nominal sim cannot reproduce.  Timeline at MIR_CLOSE_FPS 0.50 (rr15): ESTABLISH RBAR Ti+72.2 (Flight Plan 72), docking attitude Ti+96.7 (82), HOLD Ti+132.3 (129), CAPTURE Ti+159.2, hooks closed Ti+166.7 (flown 160.9 / 168.8); PASS range error at the mate +132 ft (was 3.4 kft).  0.47: capture Ti+165.5 (+4.6 min); the response is nonlinear, 0.49 under test (rr17).

### 2026-11-26: Rendezvous on the flown record (rr15/rr17)

- RENDEZVOUS ON THE FLOWN RECORD (rr15 full run, rr17 = --from RBAR with MIR_CLOSE_FPS 0.49, dk18; pushed, master): Ti burn 9.49 ft/s (flown 9.5), MC1 0.28, MC2/MC3 ~0 (flown 0.7/0.7/0.2: dispersion corrections, not reproducible by a nominal sim; within the checklist's 3-sigma), ESTABLISH RBAR Ti+72.2 (FP 72), docking attitude Ti+96.7 (FP 82), HOLD 100 ft Ti+133.8 (FP 129), CAPTURE Ti+160.2 (flown 160.9), HOOKS 1/2 CLOSED Ti+168.0 (flown docking complete 168.8), capture to docked 7.8 min (flown 7.9).  Calibrations (labelled, none sourced for STS-81): Ti point -66.04 kft, apds_waits 30/10/10, MIR_CLOSE_FPS 0.49 (response nonlinear: 0.50 -> 159.2, 0.47 -> 165.5).
- PASS NAV INSIDE ~150 FT: the accepted-measurement counts freeze (829) once the range is ~150-160 ft while the radar still reads and its residuals keep updating: PASS stops using RR data at close range (its own data editing, not the sim); the relative state then dead-reckons, +/- 30 ft down to 220 ft, +100-700 ft by the mate (rr15 +132, rr17 +670).  The flown crew used COAS/TCS and KU STBY at 100 ft; the autopilot flies the truth.  Not a defect to fix.
- REMAINING OPEN (labelled, not fixable from available sources): OMS-3 x1.22 burn-table calibration (drag ruled out; only the constructed rendezvous start depends on the burn table as a check), Flight Plan intermediate times (docking attitude +14 min late), unsourced Mir bc/port clocking, STS-81 APDS card, pad exhaust light (sourced numbers in PORTVIEW_PLAN, not built), the STS-81 weights/I-loads beyond A-6 (entry I-loads are STS-134's), a full IPL->landing STS-81 run on the final settings (the stages were run separately).

### 2026-11-26: End-to-end tail on the final settings

- END-TO-END TAIL ON THE FINAL SETTINGS (~/work/sts081/ee.sh, run 2026-11-26 03:00-04:45 CST): rr15's mated capture (dk18; final mission file: Ti point -66.04, T2 Ti+72.1, apds_waits, MIR_CLOSE_FPS 0.49) -> undock_start (mass 113,478.5 kg, props as rz5's) -> fly_undock SEPCFG..SEPX (3.0 ft/s +X, range 507 ft) -> make_return_start (OMS-8 42.7 ft/s at 020/13:53:53.2, 101,470 kg, 1997-01-22T10:00) -> fly_return ORBIT..LAND (no GPS, TACAN, KSC 33, FLY_DURATION 60000, ports 46400/46700/47000): deorbit TIG 022/13:17:09.7 (flown 13:17:33.2: -23 s), post-burn orbit 209.4 x 7.2 n.mi. eq, entry normal, main gear touchdown 022/14:22:41.1 (flown 14:22:44: -2.9 s), 195.6 kt, 2,630 ft past the KSC 33 threshold, Y +7 ft, stopped at 9,215 ft, WHEELS STOP, rc ok.  With ascent (run8), rendezvous/docking (rr15+rr17+dk18) and this tail, every Phase 1 stage has now been run on the final settings (the stages are separate captures: constructed rendezvous start, undock from the mated capture, return from the carried orbit).
- OMS-3 CALIBRATION, re-examined and still open: with the burn table all-prograde at the flown times the sim reaches 217.0x128.0 after OMS-5 vs the documented 209.7x142.4 (sphere): a is 3.5 nmi too small in the sum (an energy gap ~12.6 ft/s) AND the orbit too eccentric.  OMS-5 (94 ft/s at perigee, +2*25.8 nmi apogee) matches the documented apogee rise; the gap is in what OMS-3 (82 ft/s, 51.4 s two engines at 6000 lbf and 242 klb: consistent with the report) leaves: the sim gets perigee 85 -> 122.6 (+37.7, ~19-32 deg before apogee, efficiency ~0.84) and apogee +5, the documented chain needs perigee ~142 with the apogee not moving.  No time shift and no uniform scale fits both documented orbits; the report gives no orbit between OMS-3 and OMS-5.

### 2026-11-26: OMS-3 direction refuted

- OMS-3 DIRECTION REFUTED as the cause of the burn-table gap (burn_chain2.py in ~/work/sts081: OMS-3's 82 ft/s given an in-plane radial component, BETA deg out of the velocity, run7 OMS-2 capture, other burns prograde): after OMS-5 (sphere) -20: 214.4x126.7, -10: 215.9x128.2, 0: 217.0x128.0, +10: 218.1x125.8, +20: 218.9x121.8, +30: 218.9x116.2 (documented 209.7x142.4); after OMS-6 -20: 217.2x173.1 ... +30: 220.4x163.3 (documented 209.9x201.6).  No angle brings the perigee near 142.  Also the sim's OMS-2 capture starts 159.4x81.9 against the documented 159.9x84.9 (perigee 3 nmi low), which carries through but explains ~3 of the ~14 nmi perigee shortfall.  So: not drag (3x density range), not the OMS-3 direction (+-30 deg), not a TIG shift (-30..+30 min), not a uniform dV scale; what remains is the report's own numbers (the Missions Summary apsides may be predicted values) or burns not listed.  Kept as the labelled k = 1.22 calibration for the burn-table CHECK only; the rendezvous start is constructed.

### 2026-11-26: Flight Plan profile (rr18-rr19, dk20): reading the Flight Plan page itself

Read from the page image (STS-81 Flight Plan pdf p. 49 = printed 3-14, the RNDZ/CDR-PLT columns; the left axis is 3 px per minute, 16:00 MET at the top):
RBAR ARRIVAL (DAP LOW Z, 1000 ft) about MET 1/17:15 = Ti+72, TAIL FORWARD MANEUVER about 17:23 = Ti+80, 170 ft (50 m) STATIONKEEPING about 17:39 = Ti+96 and held (the Russian ground-station coverage pause, JSC-63400 Fig 20.17) until the "Initiate approach to 30 ft ... when R = 100 ft, KU-STBY and reconfig for COMM" at about 18:10 = Ti+127, 30 ft stationkeeping about 18:25 = Ti+142, DAP NORM Z about 18:33 = Ti+151, CONTACT 18:44 = Ti+161.  JSC-63400 Fig 20.17: manual takeover about 2,800 ft below, braking gates 2,000-1,200 ft, +R-bar arrival.

- WHY THE DOCKING ATTITUDE RAN LATE (rr15/rr17: Ti+96.7 against Ti+80): the MC aim was STS-134's (-0.9, 0, +1.8 kft) and the manual phase began at T2, so the Orbiter arrived 876 ft off the R-bar and spent 13 min crossing at 1.2 ft/s.  rr18: the aim moved onto the R-bar 1000 ft below (DX 0, DZ +1.0 kft in tgt_sets 10-13), Ti point -84 kft (Ti 9.85-9.99 ft/s at best; flown 9.5: this aim cannot give 9.5), mission key "fp_profile" {"r170": 96, "r100": 127} (rndz_manual.FP_PROFILE: close to 170 ft by Ti+96, hold, then the card's d' = -d/800 to 100 ft at Ti+127).  rr18: Ti 9.99, MC1/2/3 1.21/0.34/0.27 ft/s (flown 0.7/0.7/0.2; total 1.82 vs 1.6), ESTABLISH RBAR Ti+72.2, but the R-bar leg took 11 min: it arrived at Z +879 ft closing at 5 ft/s (the natural Ti transfer) and overshot to 632 ft; HOLD 100 ft Ti+128.5 (plan 127), 30 ft aligned Ti+150.4 (plan NORM Z 151), capture Ti+156.7 (4.2 min early: the 0.07 ft/s final approach is faster than the plan's ~10 min from NORM Z to contact).
- dk20: mission key "final_fps" 0.04 (the 30 -> 10 ft closing, dock_autopilot FINAL_FPS 0.07 by default): aligned at 30 ft Ti+151.5, CAPTURE Ti+161.4 (flown 160.9), HOOKS 1/2 CLOSED Ti+169.4 (flown 168.8).
- rr19 (running when this was written): mission key "takeover_min" 5.0 (fly_rndz134 TAKEOVER_MIN; ARRIVAL waits until MC3 TIG + 5 min, about 2,800 ft below, instead of T2) and rndz_manual RBAR_MIR_VMAX 3.0 (was 1.2) so the R-bar leg can follow the natural descent from takeover.  Ti 9.85, MC1 1.05 ft/s.  Result not yet known; if it does not bring the attitude to about Ti+80, the plan times stay unreached and the configuration of rr17 (T2 aim -0.9/+1.8, Ti point -66.04, FP_PROFILE off, final_fps off, takeover off) is the last one that matched Ti 9.49 / capture 160.2 / docked 168.0.

## Progress 2026-11-26: orbit conventions, masses, MECO targets (from CLAUDE_LOG)

### 2026-11-26: Mission Report burn numbering
- STS-81 MISSION REPORT BURN NUMBERING (owner noticed OMS-3 "fires only the right engine"): the report has two lists that number the burns differently.  OMS MANEUVERS table (p. 18): OMS 3 both engines 012:13:03:03.3 / MET 3:35:40.3, 51.4 s, 82 ft/s; OMS 4 (NC-2) RIGHT engine 013:01:02:27.8 / MET 15:35:04.8, 10.0 s, 8.0 ft/s; OMS-5 both 94; OMS-6 (NC-6) both 103; OMS-7 (Ti) LEFT 12.0 s 9.5.  The engine bi-prop valve event list (later in the report): "OMS-3" ignition = right valve only 013:01:02:27.8, cutoff :38.0 (the NC-2 burn), left N/A; "OMS-4" = both valves 013:13:03:03.4 to :55.1 (51.7 s: the 82 ft/s burn, dated 013 where the table says 012).  So the right-engine-only burn is NC-2 (the table's OMS 4, the valve list's OMS-3); the 82 ft/s burn is both engines in both lists.  Thrust agrees: one 6000 lbf engine x 10 s on ~242 klb = 8 ft/s; two x 51.4 s = 82 ft/s.
- The valve list's 013 date for the 82 ft/s burn is a day typo: burn chain with it at 013:13:03:03.4 (after NC-2 and NC-3; ~/work/sts081/burn_chain3.py) gives after OMS-5 180.6x130.9 and after OMS-6 240.6x140.4 (sphere) against the documented 209.7x142.4 and 209.9x201.6, far worse than the 012:13:03 order (217.0x128.0, 215.1x179.8); the table's GMT and MET columns agree with 012.  Another candidate for the OMS-3 x1.22 gap closed: the burn order/date is right, the numbering of the report's two lists is not.

### 2026-11-26: OMS-7 left engine only; the orbiter-mass error
- OMS-7 (Ti) FIRES ONLY THE LEFT ENGINE (Mission Report, owner noted): 12.0 s, 9.5 ft/s; the sim's Ti burn also fires the left engine only (R 0.00 s) -- but for 10.0-10.6 s, not 12.0.  CAUSE FOUND: vehdyn's YAGPC_VEHDYN_ORBITER_KG is the Orbiter with FULL OMS and RCS (liftoff), the propellant used is then subtracted (YAGPC_VEHDYN_OMS_USED_LB / RCS_USED_LB, fly_rndz134 types STS-134's 7820.7/7898.0 lb OMS in the no-ascent-capture path); the STS-81 mission file gave it 105,600 kg (the mass at Ti), so the typed STS-134 OMS use was subtracted again and the sim's Orbiter weighed 97,284 kg at Ti (214.5 klb vs ~233): every RCS pulse, attitude maneuver and OMS burn was ~8% too brisk.  FIX: mission "orbiter_kg" 109,847 (A-6 insertion 242,178 lb) and new key "oms_used_lb" "4266.0,4459.0" (OMS-2, -3, -5, -6 both engines 220.8 s, NC-2 right 10.0 s, at 19.32 lb/s per engine; fly_rndz134 OMS_USED_LB): 105,384 kg at Ti, the Ti burn 11.28 s (flown 12.0 s: a 6% remainder = thrust or mass within the report's rounding).
- rr20/dk23 ON THE CORRECTED MASS, with the R-bar aim (DX 0, DZ +1.0 kft at Ti+72.1), Ti point -84, manual takeover MC3+5 min (RBAR_MIR_VMAX 3.0), the Flight Plan profile (fp_profile r170 96 / r100 127) and final_fps 0.04: Ti 9.87 ft/s, MC1/MC2/MC3 0.79 / 0.00 / 0.31 (flown 0.7/0.7/0.2), takeover Ti+67.7, R-bar reached Ti+81.4 (plan arrival 72-74), docking attitude Ti+88.3 (plan 80), HOLD 100 ft Ti+128.2 (plan 127), 30 ft aligned Ti+150.0 (plan NORM Z 151), CAPTURE Ti+159.9 (flown 160.9), HOOKS 1/2 CLOSED Ti+167.6 (flown 168.8); PASS range error +-35 ft down to 180 ft.  dk22 died once on the '+3 keys RESUME' wait (known, flaky), rerun as dk23.  Committed 3abbfa94e (master).  Still later than the plan: the R-bar leg (takeover Ti+67.7 to the R-bar at 81.4: 13.7 min) and the docking attitude (+8 min).

### 2026-11-26: Undock start mass; rr21 results; end-to-end tail
- UNDOCK START MASS ERROR (same class as the rendezvous one): the earlier tail (ee.sh) passed undock_start.py --mass-kg 113478.548, the LIFTOFF weight (A-6 250,167 lb); undock_start takes the CURRENT mass.  At undock (020/01:40) the Orbiter weighs the 215,337 lb landing weight + OMS-8 (25.6 s x 2 x 19.32 lb/s = 989 lb) + deorbit (202.6 s x 2 x 19.32 = 7,828 lb) + entry RCS ~500 lb = ~224,650 lb = 101,919 kg; the prop args (OMS ~1947/2018 kg) were already right.  ee2.sh uses 101,919.
- rr21/dk27 (corrected Orbiter mass 105,384 kg at Ti, R-bar aim, takeover MC3+5 min, RBAR_MIR_VMAX 10, fp_profile, final_fps 0.033; committed): Ti 9.82 ft/s over 11.2 s left engine (flown 9.5 over 12.0), MC1/2/3 1.33/0.30/0.79 (varies run to run: rr20 0.79/0.00/0.31), takeover Ti+67.9, R-bar reached Ti+77.6 (plan 72-74), docking attitude Ti+84.7 (plan 80), HOLD 100 ft Ti+128.5 (plan 127), 30 ft aligned Ti+149.3 (plan NORM Z ~151), CAPTURE Ti+161.4 (flown 160.9), HOOKS 1/2 CLOSED Ti+169.0 (flown 168.8).  dk25/dk26 died deterministically on the '+3 keys RESUME' wait (a state-dependent flake: dk22 too), dkloop.sh retried on fresh copies of the logs dir; attempt 2 passed.
- END-TO-END TAIL ON THE CORRECTED SETTINGS (ee2.sh: rr21c's mated capture -> undock_start 101,919 kg -> SEPX 3.0 ft/s, range 516 ft -> return start (OMS-8, 101,470 kg) -> fly_return ORBIT..LAND, no GPS, TACAN, KSC 33): deorbit TIG 022/13:17:07.7 (flown 13:17:33.2: -26 s), post-burn orbit 209.4 x 7.1 n.mi. eq, entry normal, main gear touchdown GMT 1952557.4 = 022/14:22:37.4 (flown 14:22:44: -6.6 s), 194 kt, 2.1 ft/s sink, 2,822 ft past the KSC 33 threshold, Y +7 ft, stopped at 9,060 ft, WHEELS STOP.
- OMS-3 x1.22: the Mission Report, JSC-63400 and the Flight Plan's text layer contain no post-burn apsides; the Missions Summary's orbits remain the only source.  Engine counts do not enter the check: Delta-v is applied directly; single-engine thrust is 0.503 of dual (cos 6.5 deg of cant cancelled in dual, full T in single with the vehicle lined up on the thrust line), not a 22% effect; a single-engine OMS-3 would deliver ~41 ft/s in 51.4 s, not 82.

### 2026-11-26: OMS-3 x1.22 root cause: apsis convention
- OMS-3 x1.22 ROOT CAUSE FOUND (new source: the Orbiter's OWN element sets, planet4589 https://planet4589.org/space/elements/24700/S24711 , STS-81 = NORAD 24711, 28 sets 12-22 Jan 1997, gb/GB970113.ELM...; saved /tmp only, not in the repo): (1) APSIS CONVENTION: the Missions Summary's 159.9 x 84.9 (post OMS-2), 209.7 x 142.4 (post OMS-5), 209.9 x 201.6 (post OMS-6) are heights above the EQUATORIAL radius for STS-81, not above a 6,371 km sphere: the TLE mean elements give 163.3 x 88.7 / 213.5 x 145.5 / 214.4 x 203.9 above the sphere = 159.5 x 84.9 / 209.7 x 141.7 / 210.5 x 200.1 above the equatorial radius (the earlier "orbit convention" finding, from STS-134, was applied to STS-81 and was wrong: it set the OMS-2 aim and the MECO apogee aim 3.85 nmi too low in both apsides).  (2) THE BURN TABLE NEEDS NO x1.22: burn_chain.py started from the flown post-OMS-2 TLE state (10:11:12 12 Jan, converted TEME ~ J2000 -> M50) with the Mission Report's burns all prograde impulsive at the flown times, k = 1: after OMS-3 163.1 x 132.6 (TLE osculating 163.1 x 134.0, equatorial), after NC-2/NC-3/NC-4 163.7x136.1 / 161.9x138.1 / 162.1x139.5, after OMS-5 212.1 x 141.3 (documented 209.7 x 142.4), after OMS-6 208.7 x 205.4 (documented 209.9 x 201.6).  The k = 1.22 was compensating for the sim's post-OMS-2 orbit (eq 155.5 x 80.5) being 4.4 nmi low in a.  Both numbers were mine: the drag, direction, timing and engine-count tests earlier all looked in the wrong place.
- FIX (uncommitted until run9 verifies): flight key "apsis_eq": true (fly_sts134.oms2_targets: no 3.854 nmi sphere offset: OMS-2 designs HP 84.9, HA 159.9 equatorial), make_sts081_flight --apogee-trim -11.3 -> -6.9 (MECO radius a + 50.85 nmi, was 49.35), STS081e.mmv = STS081d with the new MECO radius cells (mission_reconfig, spec with 'was' = the current cell values).  run9 (ascent to OMS2, port 44000) tests it; then burn_chain from run9's OMS-2 capture at k = 1 must reproduce 209.7 x 142.4 / 209.9 x 201.6.

### 2026-11-26: Ascent runs for the orbit convention; conventions audit
- ASCENT RUNS FOR THE ORBIT CONVENTION (all on the OMS-2 capture, equatorial apsides, then burn_chain.py at k = 1): documented post-OMS-2 159.9 x 84.9, after OMS-5 209.7 x 142.4, after OMS-6 209.9 x 201.6; flown-TLE-start chain 212.1 x 141.3 / 208.7 x 205.4.  run8 (old sphere offset, trim -11.3, HT 81.05, ahead 190.5): 156.4 x 78.2; chain 213.2 x 124.1 / 211.3 x 175.9; run9 (apsis_eq, trim -6.9, HT 84.9, ahead 190.5): 161.1 x 82.0, OMS-2 design 82.3 ft/s (flown 75.5), mean anomaly at the TLE epoch 174.9 (flown 191.1); chain 215.2 x 134.2 / 209.8 x 196.7; run10 (same with ahead 174.3: phase right, M 190.8): 161.1 x 81.5 but the design needs 102.9 ft/s; chain 216.9 x 132.3 / 214.9 x 190.9 -- no better.  Committed run9's configuration (98adbfd21; flight key apsis_eq, trim -6.9; "oms2_ahead" is a flight key now, unset for STS-81).  What stays open and is not in any document found: the MECO flight-path angle (0.5 deg is the tape's; "STS-81's value NOT found"), which sets where the apogee falls relative to the OMS-2 burn: post-OMS-2 apsis phase 16 deg off and the OMS-2 dV 82 vs 75.5.  The burn table itself is vindicated (k = 1 from the flown state reproduces the tracked orbits to 1-2 nmi, the TLE source above).
- CONVENTIONS AUDIT (owner, 2026-11-26: the "height standard" has been chosen wrongly ~10 times): Earth-radius / altitude conventions are applied in ~10 files (grep 3.854|6371|20925646|6378137|sphere: vehdyn.c 14 hits, fly_sts134.py 11, startrk.c 5, landing_sites.py 3, physics.c 3, landaids.c 3, fly_return.py 3, fly_fd13.py 3, make_sts081_flight.py 2, rndz_instruments.py 2, touchdown_x.py 1, sts134-dolilu.json 2, sts135-flight.json 1), each with its own comment, none tied to evidence.  Standards in the library: JSC-09084 (Coordinate Systems for the Shuttle Program: geodetic altitude h = distance from the point to the reference ellipsoid along the geodetic local vertical) and JSC-14262/78-FM-32 (Space Shuttle Astrodynamical Constants: gravitational equatorial radius 6378.160 km, Fischer 1960 ellipsoid a = 6,378,166 m, f = 1/298.30); neither says what a Mission Report's apogee/perigee height is measured from, and the Reference Data book does not either; PASS/omstarget measure HA/HP from the equatorial radius.  The STS-134 claim ("heights above a 6,371 km sphere", fly_sts134.oms2_targets, from 'unreachable otherwise') is UNVERIFIED and may be wrong too.  PROPOSAL (needs the owner's go-ahead; a new CONVENTIONS.md): one register, each row = quantity, convention, source (document + page), status VERIFIED (against an independent as-flown dataset: TLEs of the vehicle itself at planet4589.org/space/elements/<catalogue>/, telemetry) or ASSUMED; a rule to tune to nothing whose convention is ASSUMED; one module for the conversions with each flight file declaring its choices (apsis_eq is the first).

### 2026-11-26: MECO state from the flown facts (two-body; superseded by the root cause below)
- MECO STATE FROM THE FLOWN FACTS (two-body, PASS mu 1.407644e16 ft^3/s^2, MECO MET 509.9, OMS-2 TIG MET 2580.3, dt 2070.4 s; the model reproduces the sim's own apsis phase: gamma 0.5 -> M(TIG) 174.2 deg vs the sim's 174.9): the conditions apogee 160 (the burn is near apogee, so MECO apogee = post-OMS-2 apogee), perigee 43.5 (the OMS-2 burn of 75.5 ft/s raises perigee by ~41 nmi) and the flown MECO speed 25,922 ft/s give r = a + 52.1 nmi, gamma 0.49 deg: the tape's default angle, and M(TIG) 171.7 deg.  The flown post-burn phase (TLE 97012.42445, mean anomaly 191.1 deg at 10:11:12.9) needs M(TIG) of ~185 (the burn rotates the apsis line only ~3 deg at this geometry): then the same apsides need V = 25,860 ft/s, r = a + 60.5 nmi, gamma 0.665 deg (M 180: V 25,886, a + 57.0, 0.603; M 188: V 25,844, a + 62.7, 0.699).  Those V are 36-78 ft/s BELOW the flown 25,922, so the flown MECO speed, the 75.5 ft/s OMS-2, the TLE phase and the MECO/TIG times cannot all hold in two-body mechanics: one input is wrong or not what it seems (the TLE set of 10:11 may be a predicted or smoothed state; MECO VI may be a relative or other speed).  Not resolvable with the sources in hand; the post-OMS-2 phase offset (sim 16 deg early) and the OMS-2 design dV (82 vs 75.5) therefore stay open, labelled, and affect only the ascent orbit and the burn-table check.

### 2026-11-26: STS-134 convention check attempted
- STS-134 CONVENTION CHECK ATTEMPTED: Endeavour is NORAD 37577 (2011-020A); planet4589's elements/37500/S37577 exists but is EMPTY (the archive has no 2011 sets for it: "does not contain recent element sets"), so STS-134's "heights above a 6,371 km sphere" (fly_sts134.oms2_targets) cannot be tested that way; it stays ASSUMED.  Other candidate checks for it: the STS-134 Mission Report's own post-OMS-2 numbers against the sim's vehdyn-orbit HA/HP at the flown burn end, or Space-Track/CelesTrak data from the owner (not available offline).  The STS-81 Post Insertion / Rendezvous books are not in the local library (Post Insertion starts at STS-114, Rendezvous at STS-113 plus 41B and 51I).

### 2026-11-26: Why the MC burns vary (SUPERSEDED: see the noiseless-pair entry)
- WHY THE MC BURNS VARY RUN TO RUN (mechanism, read from the source; not tested by two identical runs): the Ku radar (kuradar.c, xorshift, seed 0x9E3779B97F4A7C15) and star tracker (startrk.c, LCG, seed 0x5A17 + tracker) noise generators have FIXED seeds, but a draw is made each time the device is polled, and the number of polls before a given sim time depends on real-time scheduling (rate 3 pacing, host load); so the same seed gives a different noise realization at the same sim time, and PASS's filtered state, hence each MC solution, differs by a few hundred feet of state error.  Observed spread: MC1 0.28-1.33 ft/s, MC2 0.00-0.75, MC3 0.00-0.79 across rr12-rr21.  Pace-independent runs would need the noise keyed to sim time (a C change, peer gate).

### 2026-11-26: Post-OMS-2 phase and OMS-2 size: root cause
- POST-OMS-2 PHASE AND OMS-2 SIZE: ROOT CAUSE FOUND.  (1) The comparison had mixed mean and osculating elements (TLE mean anomaly 191.1 vs the sim's osculating 174.9); done properly, STATE AGAINST STATE at the TLE epoch (012/10:11:12.9, 2 s after the flown OMS-2 cutoff): flown altitude 159.80 nmi (eq), 25,232.1 ft/s, flight-path angle -0.073 deg, osculating 160.1 x 90.6, true anomaly 187.5; run9 160.79, 25,214.7, +0.070, 161.0 x 84.0, 173.6; run10 160.25, 25,207.3, -0.086, 160.6 x 78.2, 187.4.  The offset is real (14 deg), and the flown osculating perigee is 90.6: the documented 84.9 is a MEAN-element height.  (2) Backing the 75.5 ft/s OMS-2 out of the flown state (47.6 s, inertial hold along the velocity) and coasting back (J2-J4): before OMS-2 160.0 x 49.4, flight-path angle -0.02 deg at TIG; at MET 513.3 altitude 57.56 nmi, 25,879.7 ft/s, +0.604 deg (158.5 x 43.7): the classic 57 nmi MECO.  run9 at the same instants: MET 518 51.20 nmi, 25,922.9 ft/s, +0.540 deg (6.6 nmi low, 45 ft/s fast, 0.07 deg shallow); MET 2573 160.52, 25,147.0, +0.074 (flown 160.00, 25,155.7, -0.019).  (3) WHY: the Missions Summary's STS-81 page carries STS-80's MECO block: "MECO CMD 8:29.9 / 8:30.4, VI 25922 / 25915" is identical on both pages (STS-80: 17:15:53:17 duration, 28.45 deg).  The STS-81 Mission Report gives SSME shutdown commands at 012:09:35:54.79-.82 = MET 511.8 (SSME cutoff 518.13-518.37 s from engine start), MECO command flag 09:35:55, and NO MECO speed.  The sim's MECO targets (VI 25,915, radius from an apogee trim, FPA 0.5) were built on STS-80's speed.  75.5 ft/s from 160.0 x 49.4 reaches an osculating 90.6, exactly the tracked perigee: the flown numbers are mutually consistent once STS-80's are dropped.
- FIX (run11, tape STS081f = STS081e with the four MECO cells): tools/make_sts081_flight.py MECO_VI 25,870.0, MECO_ALT_NMI 57.41 (r 21,274,476 ft), MECO_FPA_DEG 0.571 (the tracked coast state at MET 513.3 less the sim's cutoff bias +7.9 ft/s, +0.15 nmi, +0.033 deg measured in run9; VDMAG in the op-96 uplink too), and OMS-2's aim osculating 160.1 x 90.6 (OMS2_HA_OSC / OMS2_HP_OSC).  --apogee-trim is no longer used.  The tape's own FPA cell was 0.650 deg (3F2E77B8) and its radius a + 60.02 nmi: the earlier "0.5 deg, the tape's" was not the tape's.

### 2026-11-26: MC-burn variation: Ti-burn execution dispersion
- MC-BURN RUN-TO-RUN VARIATION: THE NOISE EXPLANATION IS REFUTED (the earlier entry above is superseded).  Two identical runs with the radar and star-tracker noise OFF (temporary YAGPC_NOISE_SCALE=0 knob, reverted; nzA/nzB to MC1): Ti burn 9.80 ft/s (M50 -3.46 +8.10 -4.31) vs 9.78 (-4.00 +8.07 -3.82): the burns themselves differ by ~0.7 ft/s; MC1 0.82 (-0.04 +0.11 +0.81 LVLH) vs 0.78 (+0.00 -0.63 -0.46): similar magnitude, unrelated directions.  So the variation is not sensor noise; it is the Ti burn's execution dispersion (the burn's pointing, timing and cutoff, which depend on how the scripted crew's steps fall against the wall clock), which MC1 then corrects.  Consequence: the flown MC burns (0.7/0.7/0.2) are the correction of the flown Ti burn's execution error; matching them would mean reproducing that error, which cannot be done from any source.  Not fixable by seeding.

### 2026-11-26: Run12: tracked MECO targets
- RUN12 (tracked MECO targets: MECO_VI 25,880, MECO_ALT_NMI 57.41, MECO_FPA_DEG 0.571, OMS-2 aim osculating 160.1 x 90.6 with oms2_ahead 174.3; tape STS081g): MECO at MET 513.2 alt 57.55 nmi, 25,878.2 ft/s, +0.603 deg, osc 157.7 x 43.7 (tracked 57.56, 25,879.7, +0.604, 158.5 x 43.7); ET sep MET 532.6 (flown 531.0), OMS-2 TIG 2581.9 (2580.3); OMS-2 designed 89.7 ft/s (flown 75.5; run9 82.3, run10 102.9, run11 103.4); at the TLE epoch 164.7 x 88.0, true anomaly 189.2 (flown 160.1 x 90.6, 187.5): phase 1.7 deg off (was 14).  BURN TABLE AT k = 1 FROM RUN12'S OWN OMS-2 CAPTURE (eq): after OMS-3 166.9 x 132.9 (flown-TLE-start chain 163.1 x 132.6), NC-2 167.6 x 136.2 (163.7 x 136.1), NC-3 166.1 x 138.8 (161.9 x 138.1), NC-4 166.7 x 140.1 (162.1 x 139.5), OMS-5 213.2 x 142.7 (212.1 x 141.3; documented mean 209.7 x 142.4), OMS-6 213.3 x 205.1 (208.7 x 205.4; documented 209.9 x 201.6), NH 210.4 x 200.6 (209.8 x 199.5): perigees within 1.5 nmi throughout; apogees 1-5 nmi high (the oversized OMS-2 leaves the post-burn apogee 164.7 vs 160.1).  THE OMS-3 x1.22 IS GONE: the sim's own ascent orbit now carries the Mission Report's burns at k = 1.  Run history of the post-OMS-2 fix: run8 (old sphere offset) chain after OMS-5 213.2 x 124.1; run9 215.2 x 134.2; run10 216.9 x 132.3; run11 (MECO fixed, ahead 190.5) 159.7 x 78.8 at the epoch, OMS-2 103.4; run12 as above.
- STILL OPEN (small): OMS-2 designed 89.7 vs 75.5 ft/s and the post-burn apogee +4.6 nmi: PASS's design takes HT and THETA T only, so HA falls out (162.9 designed); the 14 ft/s excess is the extra apogee energy; trimming OMS2_HP_OSC / OMS2_AHEAD would trade it against the perigee and the phase.  Not needed for the burn-table check.


## Progress 2026-11-26/27: launch pad and night lighting (from CLAUDE_LOG)

Branch `review/pad-choice` (worktree `~/work/wt-pad`; commits 2205ee7b1, e652cbd7d, 7b9263ead, 41e3f3471, 730eaa793, 87d2ed9ff,
7bccad1f2).  NOT pushed, NOT merged: it carries a C change (`vehdyn.c`), so Mac, Win11 and WSL must gate it first.

- **The launch pad is a choice (owner: 39A and 39B must both stay available).**  STS-81 had been flown from LC-39A's position
  (vehdyn `PAD_LAT/LON` constants and PASS's `CGGS_NAVBASE_LAT/LONG` cells, 28.6085 N, 2.6 km from 39B) with only the pad
  height 39B's, so portview's 39B gantry and lamps were out of sight; the earlier "pad 39B" answer rested on the generator,
  which used 39B only for the launch-plane calculation.  Fix: vehdyn reads `YAGPC_VEHDYN_PAD_LAT/LON` (degrees, both or
  neither; default 39A unchanged); `make_sts081_flight.py --pad 39a|39b` (default 39b) writes the env (lat/lon, `NSTS_PAD`, pad
  height 64.1 / 62.0 m) and the nav-base cells (both copies of the GNC common block, flat 133308/841020 for LAT, +4 for LONG);
  `test_vehdyn` has a per-process pad case (`yagpc_getenv` caches, so env changes inside a process are invisible).  Tape
  STS081h = STS081g + the cells (`mission_reconfig`; never in the repo).  The `NSTS_PAD_AT` portview stopgap was reverted.
- **39B position (owner: the gantry filled 5-10% of the CDR windows against most of them on STS-134).**  portview's `lc39b`
  was the published, arc-second-rounded 28.62722 -80.62083 (a ~30 m rounding) while `lc39a` is the calibrated ET axis (nav base
  + 9.12 m north).  Measured instead by matching 39A's pad (+-150 m template) onto 39B's in the 2010 NAIP patches
  (`portview/cache/sites/ksc/patch_lc39a/b.jpg`; same orientation, NCC 0.62 against 0.39 for the next rotation, the 100 m and
  150 m templates agree to ~1 m): the ET axis is 28.627412 -80.620845 (21.6 m north, 1.2 m west of the rounded point), nav base
  28.62733 -80.62084.  portview's pad surface is per pad now (39A 48 ft, 39B 55 ft).  The layout of the two pads is assumed
  identical.  Captures for the launch scenario must come from a fresh IPL->OMS2 run on the new tape (the nav-base cells act at
  IPL; a capture restores the GPC memory it was taken with): run14 (port 45800) is the one; run13's nav base is 12 m off.
  run14: MECO 57.50 nmi / 25,876.6 ft/s / +0.600 deg, OMS-2 designed 91.0 ft/s, post-burn 166.4 x 87.5 (run12 on 39A: 57.55 /
  25,878.2 / +0.603, 89.7 ft/s, 164.7 x 88.0).  The launch scenario is `fly_sts134.py --from COUNT --to OPS2` on
  `~/work/sts081/launch1` (a copy of run14's `sts081-imu`) with `--portview-pad lc39b --station fwd`; it ends at about MET 0:54-0:56
  (OPS 201 at MET 0:50 plus the keystroke script, the CRT wait and the payload-bay-door step) -- the OPS 2 transition itself has
  not been exercised on STS-81.
- **Pad lamps (owner, from the night photos in `~/Desktop/pad-night-photos/`: ~3 m apart along a layer, much brighter, and they
  tint what is near them; source for the number: "several hundred" lights on the structures and perimeter fence).**
  `structure_lamps` cell 7 -> 3 m (246 -> 874 lamps, cap 4096), read from an RGB32F texture (a 256-vec3 uniform no longer
  fits), reach 30 -> 40 m, `STRUCT_LAMP_CD` 1500 -> 6000.  `lamps_seen_from_stack` then keeps a lamp only if a ray from some
  window position (stack axis plus a 5 m ring, heights 30-600 m) reaches it through a 1 m voxel model of the structure's
  surfaces: 874 -> 223 lamps, and 60 s for 60 ticks of a software-GL test again (it was 188 s with all 874).  The lamp is tested,
  not the surfaces it lights, so a hidden lamp that would have lit a visible column is dropped (`NSTS_STRUCT_LAMP_OCCLUDE=0`
  turns it off).  Lamps are drawn 0.9 m across, glow 4, a hot core in a soft halo, 3-48 px, fall-off (150/d)^1.5
  (`NSTS_STRUCT_GLOW_SIZE_M`, `NSTS_STRUCT_GLOW`; 1.4 m / 6 was too blobby from 150 m); the fixture colour is #F8FFFB as
  measured in the photographs (`NSTS_STRUCT_GLOW_RGB`), the light they cast stays warm (`NSTS_STRUCT_LAMP_RGB`).  The owner
  accepted these ("plenty good enough").
- **Structure colour.**  STS-114-39B pixel means: Orbiter #99989B (neutral), FSS lattice #7E5C45, ET #6D461A; our structure
  under white xenon and floods was #8A867C.  portview multiplies the xenon and flood terms on the structure by
  `NSTS_PAD_WASH_RGB` (the vehicle is another shader and stays white).  The first fit used the photograph's sRGB ratio
  1 : 0.73 : 0.55 as though it were linear and was too pale; in LINEAR light the lattice is 1 : 0.50 : 0.27, so the light on
  the steel is ~1 : 0.52 : 0.30 (about 25% white xenon spill and 75% high-pressure sodium; the owner's ChatGPT: 400-1,000 W HPS
  floods on the FSS, RSS and MLP, aviation obstruction lights on the tall structures, no layout known).  Default 1,0.52,0.30;
  tower render #866146 (G/R 0.72, B/R 0.53) against the photo's #7E5C45 (0.73, 0.55).  Lowering the searchlights
  (`NSTS_PAD_GAIN` 0.25) only darkened the structure.  The owner: colour and brightness "still don't seem quite right" but
  not worth pursuing.  What actually lights the real FSS warm, and where the floods stand, is a JUDGEMENT; aviation
  obstruction lights are not modelled.  Lesson: fit colours in linear light.
- **Night-light switches.**  The bright dotted line along the horizon in the launch view is the SLF runway's edge lights, 7-8.5 km
  west of the pad (the SLF may be lit for an RTLS or for launch-support aircraft, and the pad may or may not be lit for a night
  SLF landing).  portview `--pad-lights on|off` (searchlights, floods, structure lamps, pad ground light) and the existing
  `--runway-lights` are independent; `--night-lights on|off` (`NSTS_NIGHT_LIGHTS`, default on) is the default for both.
  Checked: `--pad-lights off` leaves the runway line and removes every pad light.
- **Peer gate and push (2026-11-27).**  review/pad-choice (tip f9a5d0c3d, C: vehdyn pad choice + the test_vehdyn Windows fix) passed
  Mac-integrate, Win11-native (build, tests, TAL, STS-134 COUNT -> ORBIT; not the docking leg, whose capture is on the retired T2
  tape) and WSL-integration (build, 34 test binaries, landing, docking chain at rate 2).  Rebased onto one unrelated Solarium055
  commit and pushed: origin/master 3414fa53c (the yaShuttle tree equals the gated tip plus the Python-only pad-lights commit).
  Win11's first FAIL was test_vehdyn's POSIX popen/pclose/2>/dev/null, fixed with `#ifdef _WIN32`.  WSL's finding, NOT in the
  ledger and unfixed: kuradar loses track on the first tick after a snapshot resume (src/kuradar.c ~247), so every `--from`
  resume in a rendezvous adds one G33 RNDZ RADAR entry.
- **Jump guard (09f79c8f8).**  `rndz_manual.rel()`'s guard (a sample that moves more than 5 + 2 dt ft from the last one is dropped,
  three in a row are taken) ran BEFORE the R-bar port-frame conversion but stored the converted sample, so every Mir (R-bar)
  sample looked like a 1.41 x range jump: pairs of drops, two samples in three lost, 10-20 s gaps (64 in 7 min at 953 ft).
  Now it runs after the conversion; a headless run from `arrival` to V-bar logged none.
- **RPOP for Mir (30cde3955).**  rpop.py assumed the ISS: the docking corridor and target were drawn along +X (V-bar), and the
  reflector was the ISS's PMA-2 in Mir's frame (~40 ft off), so DP-DP R read ~44 ft long (146 against 99 at a 100 ft ring, X -42
  instead of -1) and the Orbiter seemed to approach 90 degrees off the cone.  fly_rndz134 now exports `NSTS_RPOP_PORT`
  (JSON: port, axis, up, approach); rpop.py applies it (`ri.set_port`), the corridor and a Docking Module box follow the
  port's axis (`port_axis`), and `geo["axis"]` carries it.  The open payload bay is a rectangular cut-out in the fuselage
  outline (bay floor ~Z_o 310 in), not the doors as a box on it.  Owner decisions: the Rdot window and the layout stay
  where the STS-126 capture puts them (nothing documents another place; F5 hides the window; the real PGSC's pointing device
  is unknown, so no dragging); close in on R-bar the nose half of the Orbiter is cropped at the right edge, and the owner uses
  F8 (orbiter-centred) and Ctrl+Left (pan).
- **Rendezvous start from `arrival`.**  A driver resumes from the capture of the phase BEFORE `--from`, so `arrival` is
  `--from RBAR`.  The R-bar approach holds at 170 ft from Ti+96 to about Ti+120 min (Flight Plan JSC-48000-81 pp. 3-14:
  `fp_profile` r170 96, r100 127), closes to 100 ft by Ti+127, holds there ~10 min, then DOCK30.
  RPOP's big R is CG-CG or DP-DP by the "Orb ... to Tgt ..." line; CG-CG is ~74 ft more than the ring distance.
- **Open.**  Unseen on screen after the final lamp change; the 39B layout is assumed identical to 39A and rests on 2010
  imagery; the kuradar post-resume track loss above; the owner's launch, docking, undocking and landing run-through decides
  Phase 1; Phase 2 not started.

## Related

Ledger: no Mir entries yet.  Memory: [[reference-gps-to-nav-flown-procedures]] (the orbit-ops GPS procedures, relevant because 1997 had no GPS
on OV-104; UNVERIFIED), [[project-dass-dumps-are-sts134-endeavour]] (the DASS dumps are STS-134 software, not OI-25).
