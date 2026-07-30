# CLAUDE_LOG.md

(Cleared 2026-07-29 by Full Documentation Sync — pending entries applied to problems.md §6.)

### [2026-07-29] Target: problems.md
- Issue 75 (`mm6sn_display_multiply_residual_source_unidentified`) fixed. Root cause was NOT the suspected MM6SN.asm F3 register leak (fixed anyway as a real latent bug, but proven inactive via trace); real cause was yaHALMAT2's OP_MMPR/OP_MVPR/OP_VMPR/OP_VDOT truncating to single precision after every dot-product term instead of accumulating in genuine extended precision like real RTL's SEDR/AEDR, matching only once at the final STE. Fixed in yaHALMAT2 `interp.c`.
- New issue 77 (`mv6sn_accumulator_leak_uninitialized_companion_register`, fixed, yagpc2): found while auditing MM6SN.asm's siblings (MV6SN/VM6SN/VV6SN) for the same bug class. MV6SN.asm cleared its accumulator with single-precision `SER F0,F0` instead of extended `SEDR F0,F0`, leaving companion F1 uncleared. Fixed via added `SER F1,F1`, `&ASM101S`-gated.
- Discovered and documented a serious build-pipeline gotcha (see issue 75's `detail` field in the DB for full text): the `nsts-sdl-dps` project's own `asm101` CMake target (`make runtime`) uses a from-scratch reimplemented assembler that SILENTLY DROPS `GBLB`/`AIF`/`AGO` conditional-assembly blocks with no error. Running `make runtime` there silently reverts every `&ASM101S`-gated RTL fix (id-53, id-72/73, and now MM6SN/MV6SN) back to original/buggy object code. Correct object files must be reassembled by hand with the real `ASM101S.py` and copied into `build/lib/runtime/RUN/` directly.
- Full corpus re-sweep (98 files, sweep9): AGREE 84→85, DISCREPANCY 4→3, zero regressions. Remaining 3 discrepancies (104-EXAMPLE_1, 120-EXAMPLE_A, 167-ASSORTEDIO) are pre-existing/unrelated, still open.
