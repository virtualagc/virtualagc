# CLAUDE_LOG.md

Staging area for documentation updates.  Append timestamped entries as

    
### [2026-10-29] Target: TIMELINE-STS134-ENTRY.md
- The deorbit-to-landing run is a minute short (EI to touchdown 30:39 vs flown 31:44) because G3's flown entry I-loads (tools/sites/sts134-entry-iloads.json, 100 cells) were never applied: 0/100 on the ksc6-rndz2 volume, and OPS 3 is already resident in a TIG-60 capture, so a tape patch alone does nothing. Writing the 100 cells into the capture's gpc1.mem.bin (rootcause/run2) gives TAEM 36.6 nmi out and touchdown at EI+31:45; 215 kt, 4.4 ft/s still high. Ledger #306.
### [2026-10-29] Target: TIMELINE-STS134-ENTRY.md
- Fixed (ledger #306, commit c9a85da02): fly_return.py writes STS-134's flown G3 entry I-loads (entry_iloads.py, 100 cells) into the capture --from EXEC/TIG1/BURN/ENTRY/LAND restores, and a DEORBIT run patches sts134r-tig1 and restarts from it. Verified at rate 3: --from EXEC touchdown EI+31:44, full chain from ORBIT EI+31:42 (flown 31:44); TAEM 36 nmi out; touchdown 217-220 kt, 4.2-4.4 ft/s (flown 195 kt, 1.2 ft/s) still high. The first patched-tape attempt did nothing: OPS 3 is already resident in a TIG-60 capture. The captured memory keeps the original as gpc1.mem.bin.generic.
### [2026-10-30] Target: TIMELINE-STS134-ENTRY.md
- Fast/hard landing (ledger #307): EI-to-touchdown runs 217 kt/4.4 ft/s -> 205.5 kt/2.1 ft/s (flown 195.3 kt/1.21 ft/s).  Causes found and fixed, each tested alone in sequence: #PCGGC13 A/L I-loads (41 cells, WT_GS1, X_AIM_PT, ...) 208/3.2; subsonic speedbrake drag was nil (CD 0.0875->0.0892 closed to full), now CP-2283 fig 14: 215/2.9 but q on final holds 300 psf = V_REF; gear drag +0.010: 207/3.1; ground effect +25% L/D (JSC-23266 B.4; 30 ft scale assumed): 205.5/2.1.  Flight-control and the other guidance csects' flown I-loads made no difference (runs 6, 7).  Still 10 kt and 0.9 ft/s off; scatter between runs about 10 kt.  Untouched: TAEM interface range, TPS drag, speedbrake pitching moment.

### [2026-10-30] Target: CAUSES.md
- Ledger #308: the KSC VERT SIT snap at ~16 kft is the first MSBLS processing correcting a nav altitude that drifts ~-1.8 kft after drag-H aiding ends at 85.2 kft (GPS incorporated once per checklist); the middle line is a fixed polyline, not HREF; NAV EDIT ALT not reproduced. MLS_AZ_COVER_DEG 15 unsourced.

### [2026-10-30] Target: CAUSES.md
- #309: entry nav drift is drag-H (GND_DRAG_MEAS) accepting a residual biased by truth CD vs PASS C_D(alpha) fit; not atmosphere (run17), not fixed by ADTA H AUT (run18); entryaero.py now pulls L/D to the flown 1.85 at M2.2-4.5 (run19: nav err -1.22 kft vs -1.74 at 16 kft, touchdown 207 kt / 2.2 ft/s); remainder is PASS fit 5-10% under flight CD below M3.5; TACAN nav not modelled (STS-134 checklist has none).

### [2026-10-30] Target: CAUSES.md
- #310: driver never keyed G51 SEL ATMOSPHERE (June = item 24); drag-H used index 0. Keyed now; run20 nav err -795 ft at 15.8 kft (was -1222), drag-H residual -258 ft.

### [2026-10-30] Target: CAUSES.md
- #311: GPS TO NAV AUTO (SPEC 50 ITEM 42) after the V=7K incorporate holds nav to +-30 ft and removes the 16 kft snap; touchdown 200.3 kt / 2.1 ft/s. STS-134 checklist has GPS INH; whether flown AUTO is unverified. FLY_GPS_AUT=1 is dev-only.

### [2026-10-30] Target: CAUSES.md
- #312: OV-105 has no TACAN; GPS is prime for entry navigation (STS-118 MOD FRR). Driver now keys GPS TO NAV AUTO (SPEC 50 item 42) after the V=7K incorporate by default; FLY_GPS_INH=1 for the old behaviour.

### [2026-10-30] Target: CAUSES.md
- #313: vehdyn touchdown sink was geocentric not geodetic (low by 0.8 ft/s); true 2.9 ft/s vs design 3, flown 1.21; TD range 1550 ft vs 2500 design / 3186 flown is not ground effect (fade height tested 30-90 ft: no change).

### [2026-10-30] Target: CAUSES.md
- #314: tools/flown_iloads.py applies all flown #PC* I-load cells (7,645 differ in G3, 6,287 were missing) to a volume and to captures; run30 touchdown 1.7 s from the flown GMT (was +8.7 s), 190 kt, 3.3 ft/s, X ~2,800 ft; X_ZERO(1) 6,500 vs flown 7,500 caused the low/fast pullup (run28 -> run29).
