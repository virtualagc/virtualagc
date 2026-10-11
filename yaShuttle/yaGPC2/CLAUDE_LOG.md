# CLAUDE_LOG.md

Staging area for documentation updates.  Append timestamped entries as

    ### [YYYY-MM-DD] Target: [Filename.md]
    - note

and they are applied to their targets on the next "Full Documentation Sync".

For CAUSES INVESTIGATED and FIXES ATTEMPTED use `gpc-causes.py` instead --
that is a database with an `addr`/`search` front end, not prose, precisely
because this file records everything and recovers nothing.

### [2026-10-10] Target: RENDEZVOUS_PLAN.md
- Replace end-of-5l "The owner's decision, pending" paragraph: DECIDED (owner via Mac-portview, 2026-10-10). Default volume = -rndz2.mmv (83990ee41, fly_rndz134 --tape default ~/sts134-runs/rendezvous/...-rndz2.mmv). Default GNC stays option A (rndz2, tape tracker mounting, PASS started with the true state). Option B = one switch --flight-gnc: a -gnc volume with STS-134's GNC I-loads except ascent/abort guidance (#PCGGCOM), plus YAGPC_STARTRK_MOUNT=flown and --onboard-error flown (review/flight-gnc, plan 5n, being flown); B may become default later if it flies well and the owner agrees. IGOAL radiator white plate: CLOSED -- it is the real 2008 S1 radiator face-sheet peel (there for STS-134); geometry kept, retextured with the panel's own texture instead of IGOAL's white edge texel (29575bad0, fetch_assets.prepare_iss_radiator_damage), at the owner's request.

### [2026-10-10] Target: RENDEZVOUS_PLAN.md
- Docking backlog closed (a0d55bfd9): KU FOR COMM at 110 ft and GNC 23 JET DES F1F/F2F at 75 ft per CC 9-5/9-8; post5 test capture 0.14/0.17 ft off axis, hard mate, [22A]. PCT not modelled (needs F2/F4 SPDBK/THROT pb); angular flyout is contingency only.

### [2026-10-10] Target: README.md
- OMS/RCS interconnect on review/oms-interconnect (8fd2d2c39): 12 valves (RCS TK ISOL, RCS XFEED, OMS XFEED A/B) in valvemodel.c; mdmdev aft_rcs_feed routes an aft group to the fuller OMS pod. Awaiting the TAL re-fly and the peer pass.

### [2026-10-11] Target: RENDEZVOUS_PLAN.md
- Entry I-loads (sts134-entry-iloads.json, #PCGGC03 flown, on -full3 09123320): nominal KSC re-fly (entry-full3/run1, orbit capture retagged; coast at rate 4) lands 196.5 kt / 3.9 ft/s, OGS q ~200 psf: flown entry set safe for nominal. TAL: MECO on PASS targets (361 kft over ellipsoid, gamma 0 at 363 kft at ET SEP, = JSC-10559); remaining TAL defect is post-pull-out 129 deg low-q roll + beta the DAP cannot hold (I-loads, fc filters, aero L/D, damping, Ny sign ruled out). RTLS: site-table fix 054ef3cbb gives normal touchdown (233 kt/3.7 ft/s) but OGS q still ~360 psf with speedbrake full (dump time not the cause) -- open.

### [2026-10-11] Target: README.md
- OPS 101 hang (gpc-causes #297) FIXED a825ee831: CONFIGURE PROCESSORS ENABLE now puts a released MSC in Wait (IBM-6246556A 2.0); previously it resumed and double-posted an IOQE, corrupting FCOS free lists and killing Clock 2. Also: windowLayout remembers minimised windows and converges near the bottom panel; fly_sts134 --layout/--hold-start/--rtls-runway/--portview-views; Manager End simulation closes orphaned runs; simulatePASS quit robust.

### [2026-10-11] Target: RENDEZVOUS_PLAN.md
- RTLS over-speed on final (abort24/26, OGS q ~360-370 psf, sb 98.6): TAEM energy matches PASS reference at handover (EOW +0.6k) but altitude is 1,690 ft ABOVE TAEM HREF (12,897 vs 14,587 ft at t=2254) -> high and slow; A/L pushes over to -27 deg to capture the -18 deg RTLS OGS (GAMSGS_RTLS -18, X_AIM_PT 1000, V_REF 506 fps) and gains ~90 fps it cannot shed (vehdyn full-SB L/D 2.55 vs 3.08 needed). Open: TAEM altitude/airspeed split (Nz limits, handover criteria) and vehdyn subsonic CL (alpha 9-10) / full-SB CD vs LA66/TP-1779.
- (RTLS cont.) TAEM read from abort26 caps: IPHASE 1 (ACQ) at t=1894/2000, 3 (PREFINAL) at 2254/2270 -- the -27 deg push-over is PREFINAL at its Nz floor (NZC -0.5 g, DNZC -0.73) recovering a HAC exit 1,690 ft above HREF; TAEM began 27 kft LOW on EOW at Mach 2.5 (186k vs 214k). Next: vehdyn subsonic CL/CD (alpha 6-12, SB 0-98.6, M 0.4-0.9) vs LA66/TP-1779 against PASS TAEM assumptions. TAL: JSC-10559 p.3.3-67 says early S-turn roll reversals are designed, so the TAL issue is jet authority / mass properties / DAP jet-effectiveness vs vehdyn.
- (TAL cont.) Roll-by-yaw: the entry DAP builds beta deliberately and lets Cl_beta roll the vehicle (abort9 trace). Sensitivity from OA98 M10.3 alpha 40 (Cl_beta -0.0023, Cn_beta -0.0018 vs vehdyn held -0.0021/-0.00134): ~1.2x HARDER for the jets than vehdyn, and TM-4500 flight Cl_beta lower still -> aero hold is not the TAL cause. Next: jet thrust/moment arms vs the G3 entry DAP jet tables (assumed jet effectiveness).
- (TAL cont.) Mac-portview local experiment: yaw/primary jet thrust x1.6 above q 200 Pa makes the beta cycle WORSE (M15-30 max 17 vs 11.8) -> loop gain too high, not authority short. Hypothesis: vehdyn jets are vacuum thrust, instant on/off; real yaw jets at q 40-80 psf lose/reverse effectiveness by plume interaction (TM-4500 figs 15/16/26, TP-1011) which the DAP was tuned to. Pending 0.6x/0.8x runs; if they damp, model jet interaction vs mass-flow ratio in vehdyn.
- (TAL cont.) Jet-scale sweep (Mac-portview local harness, ~/sts134-runs/ascent/tal-jet*): beta above M7 monotonic in jet scale (0.6x mean 1.7, 1.0x 2.7, 1.6x 4.7 deg) -> plume-interaction model target 0.6-0.8x; BUT ~5,040 aft jet-s at every scale (nominal ~340) and a Mach 7-2 dive to q 1,400-1,500 psf in all -> separate problems: a persistent lateral moment the jets hold against (aileron/trim path at alpha 40-43, q 40-100?) and TAL entry energy/guidance (lift-down). NEXT SESSION: jet-usage by axis vs q/Mach + aileron/trim from a 1.0x and 0.8x trace (forClaude/tal-short/jetscale/); then range-to-go vs EOW/drag through the dive.
  - correction: vehdyn jet-seconds count only while a module has propellant (vehdyn.c:~3072), so ~5,040 just means pods emptied; usage evidence is the abort9 trace (yaw jets on most of every 50 s, t~1950-2450). Real TAL entry flies aft jets on pod propellant too (SPEC 51 ICNCT inhibited in OPS 3, JSC-10559 3.1-38) and stays far above the 57% RCS cue.
  - abort21 traced (1.0x): aft yaw firing BALANCED and alternating, L/R ~80-90 jet-s per 50 s each from Mach 21 to 9, aileron trim ~0 (unsaturated), up/down jets ~0 above q 20 -> symmetric limit cycle (loop gain), not a trim fight. Plan: build jet plume-interaction model; compare duty with tal-jetq0.6-trace (forClaude/tal-short/jetscale/).
  - 0.6x traced: per-side yaw duty UNCHANGED (~80-95 jet-s/50 s) while beta halves -> demand side, not jet efficiency. Histogram t=1950-2400: L runs median 2.9 s, R 3.0 s, gaps median 0.16 s, jets on ~90%; r swings +/-1.8 deg/s, period ~6.5 s = RELAY LIMIT CYCLE (loop lag, Cn_beta pushes past each switch). Plume interaction would cut beta but not save the pods. NEXT: capture PASS through one cycle (yaw-rate cmd, DAB/DELTA_AB, aileron cmd, NYP_LAT_ACCEL) vs vehdyn aileron deflection/moments to find the lagging or wrong-sign link in the DAP lateral feedback (GCDAER.hal:587).
  - Jets fire in the DAMPING direction (0.6x: 1,177 vs 81 jet-s oppose r) and the 6.4 s cycle matches vehdyn Dutch roll -> airframe model. Candidate: vehdyn inertia has NO products of inertia (vehdyn.c:131-134); STS-134 flown I-loads give Ixz ~273,803 slug-ft2 (~371,000 kg m2, 29% of Ixx). physics.c:332 solves with the full tensor, so a symmetric [0][2]=[2][0] takes effect. Mac-portview testing +/-371227 locally (tal-ixz+-371227); if one damps, add products of inertia from flown mass properties to mass_properties() with a test.
  - Ixz test NEGATIVE: symmetric I[0][2]=I[2][0]=-/+371,227 kg m2 -> M15-30 mean |beta| 2.58/2.57 (vs 2.73 without), yaw duty unchanged (L~627/R~641 jet-s t=2000-2350). Products of inertia still worth adding for realism, not the cause. Ruled out for the TAL relay cycle: entry I-loads, fc filters, MECO targets, aero L/D, damping derivs, Ny sign, alpha-34 lateral hold, jet scale 0.6-1.6x, Ixz. NEXT: capture DAP lateral feedback (DAB/beta-dot from Ny, yaw-rate cmd, aileron cmd) vs vehdyn aileron moment through one 6.5 s cycle.

### [2026-10-11] Target: README.md
- Entry aero: subsonic speedbrake increments now from CP-2283 Fig 5 flight data (tools/entryaero.py, src/entryaero.h regenerated); RTLS re-fly lands 223 kt/3.2 ft/s. Nominal entry not re-flown with it; on review/ops1-lps, not master.
