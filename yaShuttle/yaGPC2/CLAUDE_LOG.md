# CLAUDE_LOG.md

Staging area for documentation updates.  Append timestamped entries as

    
### [2026-10-29] Target: TIMELINE-STS134-ENTRY.md
- The deorbit-to-landing run is a minute short (EI to touchdown 30:39 vs flown 31:44) because G3's flown entry I-loads (tools/sites/sts134-entry-iloads.json, 100 cells) were never applied: 0/100 on the ksc6-rndz2 volume, and OPS 3 is already resident in a TIG-60 capture, so a tape patch alone does nothing. Writing the 100 cells into the capture's gpc1.mem.bin (rootcause/run2) gives TAEM 36.6 nmi out and touchdown at EI+31:45; 215 kt, 4.4 ft/s still high. Ledger #306.
### [2026-10-29] Target: TIMELINE-STS134-ENTRY.md
- Fixed (ledger #306, commit c9a85da02): fly_return.py writes STS-134's flown G3 entry I-loads (entry_iloads.py, 100 cells) into the capture --from EXEC/TIG1/BURN/ENTRY/LAND restores, and a DEORBIT run patches sts134r-tig1 and restarts from it. Verified at rate 3: --from EXEC touchdown EI+31:44, full chain from ORBIT EI+31:42 (flown 31:44); TAEM 36 nmi out; touchdown 217-220 kt, 4.2-4.4 ft/s (flown 195 kt, 1.2 ft/s) still high. The first patched-tape attempt did nothing: OPS 3 is already resident in a TIG-60 capture. The captured memory keeps the original as gpc1.mem.bin.generic.
