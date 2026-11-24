# CLAUDE_LOG.md

Staging area for documentation updates.  Append timestamped entries as

    ### [YYYY-MM-DD] Target: [Target_Filename.md]

### [2026-11-24] Target: HANDOFF-MIR-STS81.md
- STS-81 dk1 (dock_autopilot --from DOCK30 on rz4's HOLD): NO CONTACT in 60 min.  Cause found: discretePanel/examples/flights/rndz_instruments.py hardcodes the ISS's PMA-2 (PMA2 = (15.655, 0, 5.562) m in the target body frame) and rndz_manual/dock_autopilot read "ring from PMA-2" from it, so rz4's RBAR..HOLD and dk1's DOCK30/DOCK were all flown to the ISS point in Mir's frame, not to the port in the target line (2.929 0.081 17.698, axis +Z); vehdyn's own contact test (needs the ring within 0.5 m of the real port axis, dock_check) never fired (no "vehdyn: CONTACT" line).  rz4/dk1 therefore prove the chain runs, not that Mir's port is reached.  The V-bar final approach, the 100 ft HOLD and the goal frame (X along the port axis) are also ISS geometry; Mir's final is R-bar (axis nadir).
- NEXT: take the port (B, axis, up) from the mission targets into rndz_instruments (PMA2 and the port frame), generalize the manual-phase goal frame to the port axis (R-bar final: RBAR to the port, no V-bar leg), then re-fly rz4/dk1.  Also still open: PASS's onboard range to Mir ~10x the truth.

### [2026-11-24] Target: HANDOFF-MIR-STS81.md
- RULE (owner, 2026-11-24): the sim's port/contact/capture geometry must agree with portview's 3D model even where the model is inexact; never "docked" with the view showing a gap or overlap.  Memory sim-consistent-with-3d-model.
- Checked: the portview Mir cache on this machine was stale (9 Oct, old frame: docking tip not at the port); rebuilt locally (fetch_assets.py --vehicles mir --rebuild, git-ignored cache).  A fresh build has the Docking Module's free APAS on the axis at (2.929, 0.081) with the structural ring end at z 17.698 (apas() x 4.30 + 0.40) and the guide petals protruding to 18.018 (0.32 m beyond).  So the target-line port (17.698) is the structural interface plane, the petals stand 0.32 m proud of it.
- TODO: (1) derive the port in the target line from the model (meta 'port'), not typed constants; (2) when docking works, view the mated and at-contact states in portview and confirm the Orbiter's drawn APAS ring meets the DM's plane (petals interleaved, no gap/overlap), as for the ISS; (3) fix rndz_instruments.PMA2 (the Python side still points at the ISS's PMA-2).
