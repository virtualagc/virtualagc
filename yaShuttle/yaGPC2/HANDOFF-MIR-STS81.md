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
  the countdown/ascent state).  UNVERIFIED: where in the code the 39A altitude and position are set; grep before changing.
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

## Related

Ledger: no Mir entries yet.  Memory: [[reference-gps-to-nav-flown-procedures]] (the orbit-ops GPS procedures, relevant because 1997 had no GPS
on OV-104; UNVERIFIED), [[project-dass-dumps-are-sts134-endeavour]] (the DASS dumps are STS-134 software, not OI-25).
