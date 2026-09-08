# CLAUDE_LOG.md

(Cleared 2026-09-08 by Full Documentation Sync, the second of the day.  One
entry applied, to `problems.md` as new §8.75: the IOP DMA store-protect check
already exists and works -- `iop_write_main16` -> `mcm_set16` with the check on
-> `cpu_signal_dma_protect_violation` setting `ext1Code 0x0004` -- and the
`cpu.c` comment claiming otherwise was stale and is corrected in `8bd535813`.
It did not fire on the G9 overlay bug because `FCMCBLKS` is legitimately
unprotected, so a store-protect check could never have caught it; the check
that would have is a build-time one, the never-varying mask across the eight
DASS configurations, shipped as `tools/check_volume_destinations.py`.)

Append new entries below this line.
