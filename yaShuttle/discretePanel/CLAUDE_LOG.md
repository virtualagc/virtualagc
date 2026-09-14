### [2026-09-14] Target: README.md (simulatePASS), HANDOFF-stsKeyboard.md
- simulatePASS --instructions now begins "a. O6: GENERAL PURPOSE COMPUTER POWER -> ON for GPC..." (as the vehicle procedure does, though the switches drive nothing yet), then IDP/CRT POWER, IDP/CRT SEL, MODE HALT as b-d.
- --keyboards defaults to the keyboards the CRTs can use: 1 with --crts 1, 2 with --crts 2 or 3, 3 only with --crts 4 (the aft keyboard reaches only IDP 4, the right keyboard only IDP 2 or 3). Verified by 10 s launches: 1, 2 and 3 keyboards started.
