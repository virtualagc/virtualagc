# CLAUDE_LOG.md

Staging area for documentation updates.  Append timestamped entries as

    ### [YYYY-MM-DD] Target: [Target_Filename.md]

### [2026-11-07] Target: yaShuttle/discretePanel/portview docs (fetch_assets docstring / README)
- New tool portview/msfs_cgl.py (commit 9c1e0ff1b on review/ops1-lps): builds a landing site's ring0 (+-4 km, 8192 px) and ringF (+-1.5 km, 4096 px) from a Microsoft Flight Simulator add-on's .cgl (carve the 256-px PNG tiles, rebuild the mosaic by edge matching, SIFT-register to the site's Sentinel-2 ring, snap to the Web Mercator grid); keeps *_s2.jpg and ring.json.s2, `--restore` undoes it; needs OpenCV; imagery stays in the git-ignored cache. Used for zza (LEZG: LOD17 40x27 tiles at 0.89 m/px, LOD16 19x13 at 1.78 m/px). KTTS's package has no CGL (objects and decals only). Verified on Linux only; the add-on states no licence terms.

### [2026-11-07] Target: yaShuttle/discretePanel/portview docs (fetch_assets docstring / README)
- portview sites esn (Ankara LTAC), kbo (Koeln/Bonn EDDK), ilm (Wilmington KILM) now have MSFS-add-on aerial imagery (portview/msfs_cgl.py, commit abac6e9ad on review/ops1-lps; the first commit 9c1e0ff1b is the original tool); zza rebuilt with the new matcher (same LOD17/16 placements, plus a LOD15 group). Levels placed: ilm LOD20/19/18 (0.12/0.25/0.49 m/px), kbo LOD19/18/17 (0.19/0.38/0.75), esn LOD18/17/16 (0.46/0.91/1.8), zza LOD17/16/15 (0.89/1.8/3.6). ring0 +-4 km 8192 px; ringF +-1.5 km 4096 px (zza) or 8192 px (the rest). Of the 18 downloaded packages only these three have a CGL (the others are object packs); no package stated licence terms. New sites are defined by msfs_cgl.py --new-site (fetch_assets.py untouched, it has staged changes of others). Peak memory 17 GB (ilm). Linux only.

### [2026-11-08] Target: yaShuttle/discretePanel/PORTVIEW_PLAN.md
- portview --site ksc,zza (fd13-codex c947daaaa): sites taken in turn as the eye moves; old site's textures deleted beyond its outer ring (reach), next uploaded a band of rows a frame, mips made in linear light on a thread. Linux TAL run looked right (owner); Mac M1 Max: swap 6 s, worst step 20 ms, no errors. Win11 (Intel UHD 770, ksc,edw): swap 43 s, worst step 41 ms, no errors. WSL (llvmpipe, ksc,edw): swap 29 s, worst step 138 ms, no errors. The patch does NOT apply to master's portview.py (hunk near line 3775): reconcile before any master merge. fly_sts134 --abort TAL defaults to ksc,zza (zza,ksc from ENTRY/LAND). Patch + relay on the share t2-injector/portview/.

### [2026-11-10] Target: RENDEZVOUS_PLAN.md
- OPEN (owner-accepted for now): single-tape OPS2-only run ST4 (T1-no136) docks with RCS F 388 / L 674 / R 680 kg vs Mission Report undock F 385 / L 794 / R 794 kg; earlier runs (flown loads at Ti, no coast flown) had F too high and aft right. Coast OPS2->NC4 (40 h) burns F 150 / L 184 / R 181 kg (~4.5 kg/h per aft pod, ~0.4 %/h vs owner's flown ~0.07 %/h). Hypothesis untested: sim attitude control during the coast over-consumes; investigate coast attitude control/jet selection (and need flown tank levels before docking, not only at undock). Per-phase levels are in vehdyn.json fields 16-18 (F/L/R kg) of the captures under ~/sts134-runs/singletape/ST2-fd13-T1no136 and ST4-rndz-dock-T1no136.
- ST4 dock capture 10:42:31 UTC vs recent single-tape runs 10:36:27-10:36:39 (all earlier 10:24:39-10:52:40); the extra ~6 min: arrival +1.5-2 min, VBAR->hold 3.5 min (vs 0.1). Contact flown 10:14 UTC.

### [2026-11-11] Target: yaShuttle/yaGPC2/TIMELINE-STS134.md
- T1 single-set tests passed (ascent from stamped IPL, deorbit/entry/landing 189.9 kt / 1.5 ft/s, mid-set Ti burn). Hard landings AB21/22 = no YAGPC_NAVAIDS (ledger #336, default added in fly_return); OPS 303 miss = restart re-applied RETURN_RESUME_FROM (#337). New: snapshot_bundle.py, simulatePASS ARCHIVE.7z::SET/NAME, vehicle-key CRT lines, MEDS2 dropped-key log, wait-timeout screen dump.

### [2026-11-11] Target: yaShuttle/yaGPC2/PHASES.md
- Peer gate on unify a5dd3cb64 (relay: forClaude/unify/RELAY-TO-peers-unify.md): Mac, Win11-native, WSL all pass build, C tests, Python checks, snapshot_bundle round trip, and Zaragoza TAL on T1 (left main 189.9/191.6/190.0 kt, 3.0/2.9/2.9 ft/s). T1 docking not run on any peer: the only dock-start capture is T2-based and the tape-digest guard refuses it (docking passes on T2 stand). portview --help fixed afterwards (a617b1735, Linux-only check).

### [2026-11-11] Target: TIMELINE-STS134.md
- AB27 PASS: rendezvous-to-dock on T1 from the stamped ST4 sts134r-uplink snapshot (fly_return.py --from RNDZNAV --to STAY, no PFS/RESULT.json): hard mate 5.5 ft, -0.001 ft/s (AB25/ST4 control 5.4/5.5 ft). Wizard rendezvous scenario can start here. UNDOCK_PREFREE=skip is a recording aid only; NSTS_RPOP_PREDICTOR (hold|coast) is a display option the wizard exposes.

### [2026-11-11] Target: TIMELINE-STS134.md
- AB28 PASS: undock SEPCFG->SEP3 on T1 from stamped ST3b sts134r-start. SEP2 1.52, NH2 1.97, MC5 1.09, NSR 2.75, TPI 3.15 ft/s (ST3b control 1.51/1.91/0.95/2.67/3.58).
