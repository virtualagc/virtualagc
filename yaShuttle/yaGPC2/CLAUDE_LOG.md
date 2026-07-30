# CLAUDE_LOG.md

(Cleared 2026-07-30 by Full Documentation Sync — pending entry applied to debugger-planner.md.)

### [2026-07-30] Target: problems.md
- Fixed DB issue 78: "*** HAL/S PROGRAM HALT (SVC 0)" was printed unconditionally
  on every normal program termination (SVC 0x0015, HAL/S-FC's universal
  end-of-program call), unlike yaHALMAT2 which exits silently -- gated the
  message behind `--verbose` in halucp.c. Also found and fixed: `--no-trap-svc-error`
  over-broadly disabled ALL of HalUCP's SVC handling (QUIT, ERRGRP/ERRNUM,
  SIGNAL/SET/RESET), not just SEND ERROR (0x0014) as its name/`--help` text
  documented -- this caused real data loss (final buffered WRITE line dropped)
  when used to work around the message. Narrowed the `trapSvcError` gate to
  only the 0x0014 branch. Verified: yaGPC2 stdout now byte-identical to
  yaHALMAT2 for hello.fcm/HELLO.hal by default; zero unit-test regressions.
