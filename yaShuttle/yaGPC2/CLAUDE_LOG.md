# CLAUDE_LOG.md

(Cleared 2026-09-08 by Full Documentation Sync.  Three entries applied, all to
`problems.md` (10298 → 10434 lines) as new §8.72-§8.74: the `INCL80`/`INCLIB`
rebuild trap and the silenced-stderr trap that made eight resolves fail
invisibly; `#PCVKSAC`'s `F GEN` block zeroed, 160 halfwords across all eight
configurations, invisible to the CSECT score; the `CDCDD*` retraction, where an
`owner[i]=n` map made the last writer win and pinned every contested difference
to an arbitrary candidate; the real shape of the residue, 75914 halfwords in
8500 runs; the phase-order overlay rule and where the load order comes from;
and 97.09% → 97.98% over three fixes.  Four earlier conclusions are retracted
there -- the `CDCDD*` concentration, §8.62's "`#PCSASAT` is address-only",
"`#PCSASAT` is 48 halfwords late", and the `0x30DE` class as a separate defect
-- along with the rule they cost: do not analyse content inside a contested
region until the overlay question is settled for it.)

Append new entries below this line.

### [2026-09-08] Target: problems.md
- **The IOP DMA store-protect check EXISTS, and the comment saying it does not
  is what misled me.**  `cpu.c`'s CC-anomaly comment read "the DMA store
  protect cannot arise here yet: nothing in this emulator's IOP DMA path checks
  store protection, so no External 1 ever carries code 0x0004."  That is stale.
  `iop_write_main16()` (iop.c) calls `mcm_set16()` with the protection check
  ON, bypassable by `YAGPC_NO_DMA_PROTECT` and traceable by `YAGPC_DMAPROT`,
  and hands a refusal to `cpu_signal_dma_protect_violation()`, which sets
  `ext1Code = 0x0004` and `intPending.iopGrp2`, and in the MASKED case applies
  the CC anomaly itself plus the Fig 2-20 lost-arithmetic-interrupt rule.  The
  implementation is complete, correct and on by default.  Comment corrected in
  place.
- **Why the canary did not sing for the G9 overlay bug, which is the useful
  part.**  Phase 8's DMA overwrote `FCMCBLKS` (`0x0811A-0x08B89`) -- including
  `FCMMGEVT`, the event a process was blocked on -- and no violation was
  raised because `FCMCBLKS` is UNPROTECTED, as it has to be: FCOS fills in the
  SVC parameter lists that live there, so writing to it is not a violation
  under any rule the hardware has.  A store-protect check cannot catch a bad
  transfer whose destination is legitimately writable memory.  Every watched
  write to `0x8173` in the traces reports `prot=0`, which is correct
  behaviour, not a gap.
- **What WOULD have caught it, and needs no emulator run at all.**  63.6% of
  memory varies between the eight DASS configurations and 36.4% never does,
  and every module in the overlay chain -- `FCMCBLKS`, `FCMMGPOV`, `FCMMGBOV`,
  `FIOSVC`, `FIOMGCMP`, `FIOMGMTR`, `FPMIHPC2`, `FCMPSA` -- has ZERO varying
  halfwords.  So the never-varying mask is a build-time acceptance test for any
  volume we cut: reject a load-block destination that lands inside it.  That is
  the canary this problem actually wanted, and it belongs in the tape-building
  path rather than the emulator.
