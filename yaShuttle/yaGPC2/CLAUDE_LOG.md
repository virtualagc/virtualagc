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

### [2026-08-31] Target: problems.md, HANDOFF-FCMBOOT.md
- **THE "GARBAGE MENU" IS A DISPLAY DRAWN BY BRANCHING INTO AN EMPTY CRITICAL-FORMAT
  BUFFER, AND THE BUFFER IS EMPTY BECAUSE NOTHING EVER BUILT IT.**  PASS's entire
  display command for the CRT it drives is THREE HALFWORDS -- `0003 1fe2 | 2000 1107
  1fe2` -- and `0x1107` is `Branch(0x107)`, CFIT slot 7, which `CON80/CFSYSIN`'s
  `CRTFMTCU=` list gives as `#PXD0001` = **GPC MEMORY**.  A critical format is
  resident in the display unit, so no background is sent; ours was 3563 halfwords of
  zeros and only the per-cycle variable data drew.  That is the whole symptom, and it
  also explains the 1- and 3-word fills that looked like a second truncation bug.
- WHY IT WAS EMPTY, three omissions in a row: the phase build generates the `CD****`
  COMPOOL half of a display deck and NOT the `XD****`/`XG****` static half (only 6
  `CD*.hal` in `gen/displays/`, no `X*` anywhere); nothing ever called `dfg deucflm`;
  and the volume recipe's step 5 ran `--sysid SYS8` only, so `DMACDFT1/2/3` were
  absent from the tape and read back as zeros.  `add_sysid_allocs.py`'s own docstring
  had already identified SYS5 as missing and observed the three reads GPCIPL makes --
  it just judged the contents unsuppliable, which is true of the DEU control program
  and NOT of the critical formats.
- FIXED, and committed as `3c232e041`.  New `tools/build_deucflm.py` runs `dfg` over
  CFSYSIN's sixteen members and lays the image out with `dfg`'s own `deucflm.build`.
  A static format module is one `ARRAY(n) BIT(16) INITIAL(HEX'....')` with no address
  constant in any of the sixteen, so its constants ARE its csect image and no HAL/S
  compile is needed -- checked against the historical DFG output where OI301700 still
  carries it, **XD0001 463 halfwords and XD0990 40, identical halfword for halfword**.
  `add_sysid_allocs.py` gains `--content` and `--member`.
- **THE LOAD BLOCK'S LENGTH IS THE SYSTEM CARD'S `HWDS=`, NOT THE ALLOCATION'S**, and
  getting that wrong cost a bisect.  DMACDFT1 is an 8-block (4096 halfword)
  allocation holding an `HWDS=E4C` (3660) module, and `MMULDTBL.asm:196` reads exactly
  3660 -- seven full blocks plus 76 halfwords -- to GPC `0xE000`.  A checksum written
  at the end of the 4096 is never seen: the reader checks the 3660 it read, rejects
  it, and re-reads.  **Four reads of `4/4/4/8` against the baseline's one**, and
  GPCIPL then never reaches the display at all.  Writing the whole of SYS5 (the
  FMADEU* DEU control program included) hangs GPCIPL the same way, so `--member
  DMACDFT1/2/3` is the recipe: the DCP's contents cannot be supplied and MEDS
  emulates the unit anyway.
- VERIFIED: GPCIPL's seven `FORMAT_FILL`s to `0x0100..0x0cee` now carry 455-489
  non-zero halfwords each instead of **0**, opening with the CFIT we built (`1120 1148
  1151 ...`) and decoding on the wire to "GPC MEMORY", "MEM/BUS CONFIG", "1 CONFIG",
  "GPS STATUS", "TRK ID".  The PASS load is unchanged, 228 + 5 + 38 blocks.
- **THE SECOND HALF OF THE PROBLEM IS THAT THE UNIT PASS DRIVES IS NEVER IPLed.**
  GPCIPL loads the DEU on the BFC-SELECTED CRT, and PASS then MASKS exactly that bus
  (the BFS owns it) and drives the others -- which nobody has loaded.  Demonstrated
  both ways round: with BFC CRT = CRT 1, GPCIPL loads DK1 and PASS drives DK2/DK3;
  with CRT 2, GPCIPL loads DK2 and PASS drives DK1/DK3.  The primary PASS display
  gets 2 polls and then nothing but `MEDS_XFER` forever.
- AND IT IS DEMONSTRABLY THE WHOLE REMAINING GAP: keeping the DK2 peer alive across a
  GPC restart -- boot once with BFC CRT = **CRT 2** so GPCIPL loads that unit, then
  restart the GPC with **CRT 1** -- gives PASS an already-loaded unit, and PASS then
  drives it properly: 66 polls, 120 TIME_FILLs, **72 DISPLAY_FILLs** including a
  358-halfword variable-data fill at `0x1a06` that decodes to real GPC MEMORY content
  ("BCE STRG 1").  Against 6 tiny fills and 2 polls before.
- ON MEDS THAT NEEDS ONE CONFIG CHANGE: `config/meds.json` gives **`idp1` `"ipled":
  false` and idp2/3/4 nothing**, and `DEUUnit`'s default is `true` -- so IDP2 comes up
  claiming to be IPLed with 8192 halfwords of ZEROS and never asks for a load.
  `MEDS.sh --config` / `NSTS_SIM_CONFIG` takes an override, so this needs no edit in
  Don's tree.
- PASS DOES have an auto-IPL path -- `DMIMCD.hal:507-520`, poll header bit 16 (our
  `HDR_IPL_REQUIRED`) under `CZ2V_POST_IPL = 0`, scheduling `AIG_DEU_LOADER` -- but it
  is gated FIRST on `CZ1V_D_TIME_STAT$(index;1) NOT = 0`, the DIO transaction status,
  and our peer asserting IPL-required never produced that.  Whether yaGPC2 fails to
  set that status is OPEN and is the next thing to measure.
- **CRT2'S KEYSTROKES NEVER LEAVE THE WINDOW: `meds/mdu.coffee:127` is
  `new KYBD(1,@)`, hardcoded.**  Every MDU window therefore publishes on `_KYBD1`,
  and `medsConf.coffee:110-137` has IDP1 listening on `_KYBD1` while IDP2 listens on
  `_KYBD2`/`_KYBD3` -- so keys typed at CRT2 went to IDP1 and DK1, the one bus PASS
  masks.  Fix: derive the number from the MDU's own primary IDP.  Patch written to
  `$SP/meds-kybd-bus.patch` and `git apply --check`ed clean; NOT applied, because
  writing into `~/donschmidt/nsts-sim-gpc` is refused here.
