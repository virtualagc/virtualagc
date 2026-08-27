# CLAUDE_LOG.md

(Cleared 2026-08-27 by Full Documentation Sync.  34 entries spanning
2026-08-26 to 2026-08-27 were applied to the two files they named:

- **`problems.md`** (27 entries) — five new subsections continuing §8:
  **§8.11** finishing the OI340700 `.dfg` recovery (all twelve differing
  decks accounted for, five compools recovered exactly, the learned
  decoder encoding, `SPCHAR`, the column budget for recovered source, and
  the three halfwords that are `dfg`'s rather than ours); **§8.12** the
  `-full` exceptions lists, one of whose entries is demonstrably wrong and
  which cannot be regenerated; **§8.13** booting from the real tape and why
  `ITEM 1` loaded nothing (`SSLENGTH` zero underflows `SSLCHECK`'s `BCT`),
  plus the deterministic harness; **§8.14** the emulator defects running
  the SSL found (silence read as a switch position; `#BU@` indirection,
  settled from `FIOBBM` rather than from the POO wording; `FIOMUWB2` as a
  link-input gap); **§8.15** the fullword alignment mask, written up in
  full as an unresolved conflict with four explanations ruled out.  Seven
  new method failures were appended to §8.10 and the section's date range
  extended to 2026-08-27.
- **`HANDOFF-FCMBOOT.md`** (7 entries) — two new §2 subsections, "The
  firmware IPL" (no-`fcm` boot over the bus, the IPL pushbutton, FTSBB,
  the stamper, why reload is load-bearing) and "The SSL" (the `ITEM 1`
  diagnosis and where the boot now stands); the deterministic harness and
  the no-`fcm` invocation added to §3, with a second address table for
  GPCIPL and the SSL; three tools added to §4; three traps added to §5;
  "What is actually still open" rewritten.

**The stale line the log flagged for this sync is fixed.**  §2 said nothing
emulated the IOP microcode and that `--power-on` was what FCMBOOT's "RECEIVES
CONTROL FROM THE MICRO CODE LOADER VIA THE SYSTEM RESET PSW" meant, which
contradicted its own address table.  Both halves were wrong; the paragraph now
says so rather than being quietly deleted, and §1's matching bullet was
corrected too.

Claims were checked against the tree rather than copied from the log.  Two log
claims did not survive and were corrected in the process: **the BCE decode
table has 27 instructions**, not the 24 the log corrected 21 to — measured by
listing the mnemonics instead of counting regex matches, which is what produced
both wrong figures — and **five deck/config pairs**, not six, needed no source
change (the log names five and gives five numbers).  `YAGPC_LXATRACE` was not
written down: it was temporary and no longer exists.  Everything else cited —
the trace variables, the three new tools, `--discrete-a`/`--discrete-b`, the
`#BU@` dereference, `cpu->lastProtFaultAddr`, `#WAT` at `iop_bce_instr.c:440`,
the `psaRanges` carve-out, the unpushed-commit count — was verified present.)
