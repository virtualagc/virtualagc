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

### [2026-09-09] Target: HANDOFF-OPS9.md
- GOAL MET.  `OI340700-v27boot.mmv` -- the first tape whose every part comes
  from our own chain (HALSFC + ASM101S/ASM101Sa only, our own GPCIPL, no
  spliced reference content) -- IPLs, loads G9 and reaches the `GPC MEMORY`
  menu.  Its final DEU image is IDENTICAL to v26's, 0 of 8192 words differing,
  so nothing about the display depended on the borrowed GPCIPL v26 carried.
  Run: `TAPE=.../OI340700-v27boot.mmv DEUMF=1 SOURCE_RUN=OFF
  DEUKEYS="@150:ITEM,1,EXEC" RUN_AT=260 PORT_BASE=6800 ./headless-gpcmem.sh
  1500 headless-v27`; SIGINT at 873,990,427 steps, no halt.

### [2026-09-09] Target: HANDOFF-OPS9.md
- Seven build defects were behind the earlier failures, in the order found:
  (1) a pruned `--external-syms` csect table silently disabling relocation
  (phase 2 divergence 8.37% -> 0.77%); (2) phase 3's LB2 straddling
  `FCMLINIT`; (3) the GPCIPL power-refail path; (4) `AIB_GPC_LOCATOR` trimmed
  off the tape by a union csect table; (5) 240 unresolved cross-phase symbols,
  fixed with `contents` entries (658 -> 290 unresolved); (6) all 30 process
  stacks missing, because SDL-mode objects carry no stack ERs and the CON80
  ` STACK $0<prog>` cards are commented out; (7) v18-v22's spliced phase 10,
  which brought the reference's `FCMSSLPT` and so described reference-sized
  phases against our records.  Code divergence from the flight machine
  8.37% -> 0.50%.

### [2026-09-09] Target: HANDOFF-OPS9.md
- ASM101S REPRODUCES GPCIPL EXACTLY; THE LEGACY TAPE DOES NOT.  Scored against
  the original IBM listing `PFS/temp/temp/BILDNEW5.lst` (GPCIPL VER 9.05
  09-23-96) over the 13,285 halfwords whose object code it prints:
  `objects/BILDNEW5.obj` (ASM101S) mismatches 0 (0.000%); the GPCIPL inside
  `pass-run/pass-ipl-cflm.mmv` mismatches 1,167 (8.78%).  The legacy tape's
  deviations are systematic, not random -- 459 of them change only the low
  nibble of an instruction's first halfword to `3` (the base/index register
  field) with the following address halfword adjusted by a matching constant.
  At `00285` the listing and ASM101S both emit `ECF0 1988` for
  `LA R4,STMWAIT`; the legacy tape has `ECF3 1DF6`.  That is an assembler
  resolving base-register addressing differently, not a source-version
  difference, and it is the shape the `asm101` hypothesis predicted.  All
  three of our BILDNEW5 objects (`objects/`, `objects.prefix-backup/`,
  `cb/obj/`) are byte-identical, so the difference is not ours.
- The flashing `>>> GPC POWER REFAIL` message tracks our GPCIPL exactly:
  present in v2-v17 and v27 (our GPCIPL), absent in v18-v26 (spliced
  reference GPCIPL).  It does NOT block the load -- v27 shows it and still
  reaches `GPC MEMORY`.  Since our GPCIPL is bit-exact to the listing, the
  message is not a build defect of ours.

### [2026-09-09] Target: HANDOFF-OPS9.md
- STILL OPEN: phases 4, 5, 6, 7, 8 and 15 come out short of the phase table's
  block counts, and phase 16 does not link at all (`CON80/SM4TAB` CHANGE cards
  want SPEC-4 symbols that the OI340700 exclusion markers remove).  None of
  these blocked `GPC MEMORY`.
- STILL OPEN, needs a decision: the 181 ` STACK $0<prog>` cards in
  `~/pass-build/OI340700/CON80/{SSW,GNC1,GNC2,GNC3,GNC8,GNC9,MFB14,OPS0,PL9,SM4}`
  are COMMENTED OUT.  The flight machine has all 30 process stacks and
  SDL-mode objects carry no stack ERs, so the cards are the only trigger.
  Uncommenting them in a COPY at `/tmp/claude-1000/CON80s` produced 28 of the
  30, 24 at the exact flight addresses.  The user's tree is UNMODIFIED.
