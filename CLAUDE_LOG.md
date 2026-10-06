# Documentation staging log

Timestamped notes staged for other documents accumulate here between
documentation syncs.  Format:

    ### [YYYY-MM-DD] Target: [Target_Filename.md]
    - Brief, high-density update note

Applied and cleared 2026-10-05 (fifth sync).

### [2026-10-05] Target: [yaShuttle/yaGPC2/TIMELINE-STS134.md]
- Pitch table RE-SHAPED for the day's winds (c2d0baba2, message 13 row): +1.0 deg at Vrel 190-963, -3.6..-3.8 at 1,587-2,801, -1.5 from 4,030 (flights t1-t4 from cap-s1). QPOLY and TREF 21.4 re-read and unchanged: bucket 72% at T+39.40-51.24 (STS-134 39.5-51.3), adaptive throttling off (t4r). Note in the message 14 row: a change below Vrel ~500 delays the 488 ft/s point and switches AGT on (t3: 77%).
- Card comparison: replace with run t4f (whole ascent, re-shaped table, day's weather), INTERPOLATED in time/Vi: T+30-110 9.0/26.2/50.8/85.6/126.9 kft, 659/1020/1491/1911/2162 ft/s; Vi 6000 232.8K/1547, 7000 281.5/1143, 8000 312.0/826, 9000 331.3/567, 10000 342.9/355, 12000 351.9/40, 14000 350.6/-153, 16000 345.9/-186, 18000 342.2/-188, 20000 338.3/-209, 22000 335.5/-133, 24000 335.3/35, MECO 339.5/286. The sts134f column now in the timeline was read from the NEAREST 5-s sample (up to 2.5 s off; 248.4K at Vi 6000 is really 242.7K) -- replace it; pre-retune interpolated values (s1 = sts134f within ~0.3 kft): 8.9/25.9/50.4/85.6/128.3 kft, Vi 6000 242.6K. Drop "+28,000 ft at Vi 6,000" (was +22.6 interpolated, now +12.8).
- t4f: SRB sep T+124.72, ET sep T+524.16, 1,293 kg LO2 / 648 LH2 left; truth max-q 682 psf at T+55.6 (s1 697): the flatter mid first stage lowers it further -- max-q is a performance (air-speed) question, not a shaping one. A from-IPL flight with the new DOLILU should replace sts134f as the baseline.

### [2026-10-05] Target: [yaShuttle/yaGPC2/TIMELINE-STS134.md]
- References: add **JSC-19041 Rev F (2003), SSME Overview** (`Reference/SSME Overview.pdf`; SB 1.17 pages headed JSC-17239): each power level its own command, 65-109 (SB 1.11); Pc ref linear 1840.5 psia @67% .. 2994.2 @109% (SB 1.17); Block II/IIA 100% = 2747 psia, the 104 command = 2871 psia = 104.5% (SB 1.7). And NASA 20120001539 (Van Hooser & Bradley, SSME - The Relentless Pursuit of Improvement): RPL 469,448 / NPL 490,847 / FPL 512,271 lb; Block IIA (STS-89) 'A-Cal software'. Message 39 row: replace "the Block II controller runs a 104 command at 104.5%" (was an inference) with that citation. Derived-data: the SSME 104 -> 104.5% mapping is now documented (eiumodel.c, a71671fd9; ledger #280).

### [2026-10-05] Target: [yaShuttle/yaGPC2/TIMELINE-STS134.md]
- New baseline: run **sts134h** (from IPL, re-shaped DOLILU, day's weather, `--to OMS2`) replaces sts134f. Throttle 72% T+39.16, 104% T+51.16; truth max-q 683 psf T+56.5; SRB sep T+124.80; MECO command T+502.84; ET sep T+524.08 (1,358 kg LO2 / 659 LH2 left). Card (interpolated) T+30-110: 8.9/26.1/50.8/85.5/126.8 kft, 658/1019/1488/1911/2158 ft/s; Vi 6000 232.9K/1545, 7000 281.6/1144, 8000 312.2/829, 9000 331.6/573, 10000 343.4/362, 12000 352.7/51, 14000 351.9/-129, 16000 348.3/-149, 18000 344.7/-205, 20000 340.8/-202, 22000 338.3/-111, 24000 338.6/62, MECO 344.0/309. OMS-2 targets HT 171.95 / THETA T 328.92 (dV 262.1 ft/s); orbit after OMS-2 171.68 x 121.16 nmi (eq radius; 171.87 x 121.35 ellipsoid), inc 51.669 deg; before 121.62 x 26.13. Agrees with the t4f ascent-only run within ~0.6 kft.
