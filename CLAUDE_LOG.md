# Documentation staging log

Timestamped notes staged for other documents accumulate here between
documentation syncs.  Format:

    ### [YYYY-MM-DD] Target: [Target_Filename.md]
    - Brief, high-density update note

Applied and cleared 2026-10-05 (fourth sync).

### [2026-10-05] Target: [yaShuttle/yaGPC2/TIMELINE-STS134.md]
- CORRECTION to the third sync: max-q with the day's weather is the TRUTH's 697-698 psf at T+56.4-56.6 (vehdyn-asc q=, runs w2/s1/sts134f), NOT 723 at +47.6 -- that was a scratch script recomputing q from the 1976 atmosphere with no wind. Fix the ascent-table max-q row ("With the day's winds and atmosphere: 698 psf at +56.4"), and Known differences: "Max-q is ~4.8% low with the day's weather (698 against 733.1; 715 with the Patrick atmosphere and no wind)" -- the day's air makes it lower, not higher.
- Baseline from IPL, run sts134f (tape e50c4dc40466, all reconfig cells incl. SRB sep I-loads, 12:56Z sounding): liftoff stack 4,524,350 lb; max-q 698 psf at T+56.4; SRB sep T+124.84 (actual 124.72); MECO ~T+502.8 (ET sep - 21.2; actual 501.1), Vi 25,819 (25,818); MECO altitude ~343K (card 345K); ET sep T+523.96 (522), 1,420 kg LO2 / 669 kg LH2 left; OMS-2 designed 263.3 ft/s (259.2). Card: first stage +0-5 kft high, second stage up to +28 kft at Vi 6000 (sts134e +17). Orbit: just after OMS-2 172.1 x 120.7 nmi above the equatorial radius = 176.0 x 124.6 above the 6,371 km mean radius (STS-134 175.8 x 124.3; sts134e 176.4 x 125.3); one-orbit average 166.0 x 120.5 eq = 169.9 x 124.3 mean; inclination 51.63-51.67; post-MECO 121.9 x 96.4 eq. Make sts134f the timeline's reference run (Sources table) in place of sts134e, with these numbers.
