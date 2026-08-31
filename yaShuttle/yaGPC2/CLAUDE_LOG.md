# CLAUDE_LOG.md

(Cleared 2026-08-31 by Full Documentation Sync.  Two entries, both dated
2026-08-31 and both naming `problems.md` and `HANDOFF-FCMBOOT.md`, were
applied.  They are one story — the BCE count tables — told in two halves,
so they were merged rather than filed separately.

- **`problems.md`** (6949 → 7103 lines) — a new **§8.27**, "The count tables
  are fullwords too — CRT2's missing menu, and a bisect that halved the fix":
  the `iop_g_eah` count fetch and its 3-of-360 display fills, the measured
  before/after with PASS loaded, why our own DEU stub rescaled the failure
  below notice, `YAGPC_XMITTRACE`'s queued-vs-sent discriminator, the false
  leads killed by measurement, the bisect that reverted `#MIN@`/`#RDL`, the
  `_KYBD` bus, PASS declining `OPS 101`, and the two open items.  Also: four
  new method failures in **§8.10** (fix only what the evidence covers;
  question a long-lived peer's accumulated state; patch instrumentation at the
  chokepoint; `make` calls test binaries up to date); a forward pointer from
  **§8.17**, since the branch forms and the count forms are the same defect and
  fixing one did not fix the other; and the CRT2 clock chain added to **§8.25**
  — the 24 h `FPMMTURM` floor *plus* a 16-bit truncation in MEDS's own header
  rendering, with the note that day 1 plus the real time of day would clear
  both at once.
- **`HANDOFF-FCMBOOT.md`** (998 → 1086 lines) — §2's state paragraph now says
  the displays render; "PASS runs" gains the `#TDL` fix and an explicit **do
  not re-widen it** on the reverted half; "What is actually still open" gains
  four bullets (CRT1's flashing menu, `OPS 101` declined, the unidentified
  `func=005` to IUA 8, and the clock's truncation folded into the existing 24 h
  bullet); §3's MEDS recipe gains "restart MEDS with the GPC", the 25 s launch
  spacing, and `gpcmd key --idp`; §4 gains `YAGPC_XMITTRACE` and
  `YAGPC_DMATRACE`; §5 gains the `MEDS.sh` clean race and the
  wrong-function instrumentation patch, with the `pkill` self-match trap
  updated to six occurrences and the stale-binary trap to its second instance.

Claims were checked against the tree rather than copied from the log.
Verified present: `YAGPC_XMITTRACE` in `iop.c:355` and `YAGPC_DMATRACE` in
`iop.c:418`/`iop_bce_instr.c:357`; `iop_g_eaf` on the two count fetches at
`iop_bce_instr.c:305`/`376` and `iop_g_eah` still on `411`/`435`, which is
exactly the half-reverted state described; commits `96ab01cc4` and `5e663c3f5`;
`/KYBD/ → recvKYBD` at `nsts-sim-gpc/meds/idp.coffee:93`; `ibmFloat48`,
`timeFillWords` and `parseTimeFill` in `meds/deuProto.coffee`; `DEUCharset` in
`meds/deuFCW.coffee`.  Read-only in Don's repo, nothing written there.

Three citations in the log were wrong and were corrected rather than copied.
The 160-block stall is **not** documented in §8.13, so it is now stated against
the 431 a working run reads.  The 0.57 s repaint rate is **not** §8.25's
figure; it is Don's known-good `IPL.fcm` reference, 87 display fills in 45 s.
And the time fill is built by `timeFillWords` but *decoded* by `parseTimeFill`,
which is the function the truncation sits downstream of.

One thing is carried forward as reported and not re-verified: that MEDS
truncates to 16 bits in its DPS header rendering.  The decode was checked
against MEDS's own `ibmFloat48` and the arithmetic is exact, but the rendering
code itself was not read.)
