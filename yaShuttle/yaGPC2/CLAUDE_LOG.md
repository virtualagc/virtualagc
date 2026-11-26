# CLAUDE_LOG.md

Staging area for documentation updates.  Append timestamped entries as

    ### [YYYY-MM-DD] Target: [Target_Filename.md]

### [2026-11-25] Target: RENDEZVOUS_PLAN.md
- CLOSE-RANGE PASS NAV DIVERGENCE: CAUSE FOUND AND FIXED (uncommitted C, kuradar.c, peers pending).  rr10 (angle REJ/RESID now in the rr: line): angle residuals grow to +-1-3 deg inside 350 ft, PASS rejects angles from Ti+122 (~240 ft; REJ 13/4 by 170 ft), range still accepted, lateral state unobserved and runs off.  Cause = the radar model's close-range angle wander atan(3 m/R) (my first-try judgement: 1.7 deg at 330 ft vs PASS's 0.19 deg allowance).  New knob YAGPC_KU_WANDER_M, default now 0.3 m: rr11 no angle rejects, residuals <0.7 deg, PASS range error +0.4 ft at 171 ft (rr10 -96 ft, dk9 growing to 3.4 kft).  dk11 (DOCK30->DOCK on rr11's capture): CAPTURE Ti+157.5 (flown 160.9, 3.4 min early), hard mate reached (TCS 5.5 ft); PASS range error then drifts to +255 ft over 40 min because all RR counts freeze below ~170 ft (KU STBY at 100 ft in the Flight Plan; no data after).  test_kuradar 53/53.  Still a judgement (no source for the wander).
- STILL OPEN: MC2 1.65 / MC3 2.98 ft/s sensed vs flown 0.7 / 0.2 (nav error at those burns only 25-40 ft, so it is the targeting/geometry, not nav); capture 3.4 min early; absolute vector drift ~500 ft.
