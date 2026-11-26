# CLAUDE_LOG.md

Staging area for documentation updates.  Append timestamped entries as

    ### [YYYY-MM-DD] Target: [Target_Filename.md]

### [2026-11-26] Target: HANDOFF-MIR-STS81.md
- STS-81 MISSION REPORT BURN NUMBERING (owner noticed OMS-3 "fires only the right engine"): the report has two lists that number the burns differently.  OMS MANEUVERS table (p. 18): OMS 3 both engines 012:13:03:03.3 / MET 3:35:40.3, 51.4 s, 82 ft/s; OMS 4 (NC-2) RIGHT engine 013:01:02:27.8 / MET 15:35:04.8, 10.0 s, 8.0 ft/s; OMS-5 both 94; OMS-6 (NC-6) both 103; OMS-7 (Ti) LEFT 12.0 s 9.5.  The engine bi-prop valve event list (later in the report): "OMS-3" ignition = right valve only 013:01:02:27.8, cutoff :38.0 (the NC-2 burn), left N/A; "OMS-4" = both valves 013:13:03:03.4 to :55.1 (51.7 s: the 82 ft/s burn, dated 013 where the table says 012).  So the right-engine-only burn is NC-2 (the table's OMS 4, the valve list's OMS-3); the 82 ft/s burn is both engines in both lists.  Thrust agrees: one 6000 lbf engine x 10 s on ~242 klb = 8 ft/s; two x 51.4 s = 82 ft/s.
- The valve list's 013 date for the 82 ft/s burn is a day typo: burn chain with it at 013:13:03:03.4 (after NC-2 and NC-3; ~/work/sts081/burn_chain3.py) gives after OMS-5 180.6x130.9 and after OMS-6 240.6x140.4 (sphere) against the documented 209.7x142.4 and 209.9x201.6, far worse than the 012:13:03 order (217.0x128.0, 215.1x179.8); the table's GMT and MET columns agree with 012.  Another candidate for the OMS-3 x1.22 gap closed: the burn order/date is right, the numbering of the report's two lists is not.
