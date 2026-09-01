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
- **ONE PASS IS ENOUGH, WITH A FLIP OF THE BFC CRT SWITCH.**  GPCIPL loads the DEU on
  the SELECTED CRT and PASS masks exactly that bus, so the display PASS drives is never
  the one that was loaded.  Selecting **CRT 2** through the IPL and flipping to **CRT 1**
  after the SSL load and before RUN gets IDP2 loaded first and handed to PASS afterwards.
  Measured: DK2 then takes 92 polls, 172 TIME_FILLs and **86 DISPLAY_FILLs**, with a
  358-halfword variable-data fill at `0x1a06` carrying real GPC MEMORY content ("CODE",
  hex fields) and a 35-halfword message line at `0x19be` reading `BCE STRG 1 NSP 1
  21:29:42(11)`.  Against 6 tiny fills and 2 polls with an unloaded unit.
- MEDS's config override is read from `NSTS_SIM_CONFIG` and **deep-merged**
  (`simRunner/main/main.civet:230`, absolute paths accepted, logs "[meds] loaded config
  override from ..."), so the override only needs the four `idp*` entries and does not
  have to track the rest of `config/meds.json`.
- THE RETEST RIG lives in `~/workspace/pass-run/`: `rebuild-tape.sh` (regenerates
  `DEUCFLM.bin` and `pass-ipl-cflm.mmv`, byte-reproducible, never touches
  `pass-ipl.mmv`), `meds-unipled.json`, and `retest-crt2.sh`.  **Not yet verified
  against real MEDS** -- every measurement here is against `deustub2.py`, so the last
  step, MEDS actually RENDERING the critical-format buffer, is still unconfirmed.
- The MEDS keyboard fix is applied in `~/donschmidt/nsts-sim-gpc` as a LOCAL,
  UNCOMMITTED edit to `meds/mdu.coffee`, after a `git pull` that reported "Already up to
  date" (the branch is 1 ahead of `origin/main`, 0 behind).  It compiles under the
  repo's own `coffee`, and resolves CRT1 -> _KYBD1, CRT2 -> _KYBD2, CRT3 -> _KYBD1,
  CRT4 -> _KYBD3.

### [2026-08-31] Target: problems.md, HANDOFF-FCMBOOT.md
- **THE KEYBOARD FIX IS CONFIRMED IN THE REAL SYSTEM.**  User: keystrokes at CRT2 are
  recognized, and `SPEC 1 PRO` / `SPEC 2 PRO` take PASS to *different* screens.  So the
  `_KYBD` routing was the whole of that problem, and PASS is responding to items.
- THE MEDS CONFIG OVERRIDE PROVABLY TOOK: both instances logged `[meds] loaded config
  override from .../meds-unipled.json`, and the GPC log shows the 3004-block
  `pass-ipl-cflm.mmv`.  So the tape and the `ipled:false` change were both in play and
  the display was STILL blank -- which is why the next run has to be recorded rather
  than reasoned about.
- **NOT EVERY BACKGROUND IS THE GPC'S TO SEND ANY MORE.**  `CD0010.dfg:25` --
  `CR93220A 01/23/08 OI3404 MOVE DPS UTILITY BACKGROUND TO MEDS`.  Exactly three decks
  in OI340600 say it: **CD0010 (DPS UTILITY), CG0500, XG0500**.  So SPEC 1 coming up
  blank is MEDS's own missing background, NOT our tape, and our build's CD0010 having 9
  static FCWs and no title text is CORRECT rather than a gap.  `CD0001`/`XD0001` (GPC
  MEMORY) say nothing of the sort -- that background is still the GPC's, via the
  critical-format buffer, so the DEUCFLM work is the right fix for it.
- ALSO NOT WHAT THEY LOOK LIKE: `CD0002`/`CD0003` are not SPEC 1 and SPEC 2.  They are
  small message compools -- "MM IO ACTIVE FOR / ROLL-IN PAGE" and "MM IO PAGE NOT
  RETRIEVED".
- MEDS'S RENDERER *CAN* DRAW A CRITICAL FORMAT, checked in the source rather than
  assumed: `mduScreen_DPS.refresh` draws `@bgFCWS` from `DISPLAY_HEADER` and **follows
  the branch words**; `applyFill` writes every fill into that array; `deuUnit._fill`
  treats FORMAT_FILL and DISPLAY_FILL identically and calls `onFill`, which the IDP
  forwards to the MDU; `mdu.recvFromPri` routes a FILL to `screens['DPS']` whatever
  screen is showing; and `@bgFCWS` is allocated ONCE, in the constructor, so it is not
  wiped by a redraw or by POLL FAIL.  If the formats arrive and nothing draws, the
  fault is further in than this.
- TRAP #14 AGAIN, FROM THE OTHER SIDE: a live test of mine against the user's running
  MEDS was invalidated because **their** `discretePanel.py` was still up from their
  attempt, publishing onto the same machine-wide discretes bus.  The signature is
  unmistakable in the GPC log -- `MODE: RUN` / `MODE: HALT` alternating forever.
  `retest-crt2.sh` now REFUSES to start when a yaGPC2 or discretePanel is already
  running, rather than producing a measurement that is really about two publishers.
- NEW TOOL, committed: `tools/dksniff.py`, a RECEIVE-ONLY DK bus sniffer.  A stub peer
  answers the GPC and answering changes what the GPC does next, so a stub cannot be
  used to observe a MEDS run at all.  SO_REUSEADDR only, never SO_REUSEPORT, so it
  cannot end up in a load-balancing pair with the peer it is watching.
- **A RELATIVE PATH WROTE INTO SOMEBODY ELSE'S REPOSITORY, and it took two "vanished
  file" mysteries to notice.**  The shell's working directory PERSISTS BETWEEN Bash
  calls, so a `cd ~/donschmidt/nsts-sim-gpc` in one invocation was still in force in
  the next, and `cat > tools/dksniff.py` created it THERE.  It had not vanished; it was
  never in yaGPC2.  The same thing swallowed a `CLAUDE_LOG.md` append, which became a
  new 31-line `CLAUDE_LOG.md` in Don's tree.  Both were found as untracked files while
  preparing a PR, and removed; his repo is clean again apart from the intended
  `meds/mdu.coffee` edit.  **Use an absolute path, or `cd` at the START of every
  invocation** -- and note that this is a way to modify another project silently, which
  is exactly what the standing rule about other people's repositories exists to
  prevent.

### [2026-08-31] Target: problems.md, HANDOFF-FCMBOOT.md
- **THE TAPE FIX IS CONFIRMED END TO END AGAINST REAL MEDS.**  Recorded off the wire by
  `tools/dksniff.py` during the user's own run: at t=38.2-38.4 GPCIPL sends IDP2 seven
  `FORMAT_FILL`s of 509 halfwords to `0x0100..0x0cee` plus a 94-halfword tail at
  `0x0eeb`, carrying **455-489 non-zero halfwords each** and decoding to `GPC MEMORY`,
  `MEM/BUS ...`, `GPS STATUS`, `TRK ID`, `OXID`.  The critical-format buffer is loaded.
  The display is STILL blank, so the remaining fault is in the RENDERING.
- **WHAT PASS ACTUALLY SENDS FOR GPC MEMORY**, and it is two pieces: a THREE-halfword
  background at `0x1fe2` -- `2000 1107 1fe2` -- and a 382-halfword dynamic list at
  `0x19ee` that ends in `3200`, end-of-refresh.  `0x2000` is op 2 SUBLIST with
  **sector 0**, `0x1107` is op 1 BRANCH with a 12-bit address of `0x107`.
- **`0x107` IS EXACTLY RIGHT, AND THE FLIGHT SOFTWARE SAYS SO.**  `CD0001.dfg:89` reads
  `DEULOC=000263`; 263 decimal = `0x107` = `0x100 + 7`, and 7 is `#PXD0001`'s index in
  CFSYSIN's `CRTFMTCU=` list.  Every DEULOC in the release is 256..271, i.e.
  `0x100..0x10F`, the CFIT slots.  So the branch word carries **twelve** address bits
  and the SUBLIST's `ssss` supplies the sector.
- **TWO THINGS IN MEDS STOP IT DRAWING, both in Don's renderer.**  (1)
  `deuFCW.coffee:139` resolves a BRANCH as `hw & 0x1fff`, so `1107` becomes `0x1107`
  instead of `0x0107` -- empty memory -- and `mduScreen_DPS`'s walker ignores op 2's
  sector when the count is zero, which is the very thing that selects sector 0.  Note
  the 13-bit reading IS right inside the display half: the same list branches `1a0e`,
  which must resolve to `0x1a0e`, the dynamic portion.  The discriminator is the
  sector word.  (2) `refresh()` starts the walk at `DISPLAY_HEADER` (`0x19ee`) and
  nothing else, and the 382-halfword list there contains NO branch to `0x1fe2` -- I
  searched it -- so the background block is never executed at all.  Both have to be
  right before a critical format can draw.
- NOT ATTEMPTED, deliberately: patching the beam interpreter.  The sector semantics
  (what the current sector is, what a critical format's `111e` exit branch means -- it
  is also CFSYSIN's `PAD`) need the DEU POO, and guessing them is exactly the trap of
  copying a condition without understanding why it is there.
- THE "SECOND SILENT WRITE FAILURE" recorded here was the same mistake and is
  withdrawn: the append reported success because it SUCCEEDED, into
  `~/donschmidt/nsts-sim-gpc/CLAUDE_LOG.md`.  Nothing is wrong with heredocs.  What is
  worth keeping is the check that caught it -- after writing a file, verify the file
  you meant to write actually changed.

### [2026-08-31] Target: problems.md, HANDOFF-FCMBOOT.md
- **MEDS2 EXISTS, at `~/workspace/MEDS2`, and it is a deliberate stopgap.**  A clone of
  `nsts-sim-gpc` on a branch `meds2` off the keyboard fix, with its push remote set to
  the literal string `DISABLED-never-push-MEDS2-upstream` so it cannot go anywhere.  It
  is renamed only enough to tell apart -- `MEDS2.sh`, and the MDU windows titled
  "MEDS2 MDU / CRTn".  **Don's own MEDS supersedes it the moment it lands**: point
  `retest-crt2.sh`'s `SIM=` back at `~/donschmidt/nsts-sim-gpc` and drop the `2`.
  The reasoning was the user's and is worth keeping: the wasted effort is real, and it
  is cheaper than an indeterminate wait on a determinate blocker.
- **THE FIX IS THREE CHANGES IN THE DPS BEAM INTERPRETER.**  (1) `deuProto` gains
  `CF_PAD = 0x111e`, CFSYSIN's own `PAD=`, which is the word every DFG static body ends
  with.  (2) `deuFCW` decodes a BRANCH as **twelve** address bits; the sector comes from
  the op 2 SUBLIST word ahead of it.  (3) `mduScreen_DPS` keeps a sector register, set
  by op 2 whatever its count, and `refresh()` makes **two** passes -- the first from
  `BACKGROUND_TOP`.
- WHY TWO PASSES, and it is the answer to "why is this a MEDS problem at all": a DFG
  display is not one list.  Its background is RESIDENT, downloaded once during the
  unit's IPL, and at call-up the GPC writes only a POINTER to it at the top of memory.
  Measured side by side off the wire: GPCIPL's screen is one self-contained 196-halfword
  block at `0x19ee` whose single branch (`1ab1`) stays inside itself, so walking from
  DISPLAY_HEADER alone renders it perfectly -- which is why GPCIPL always looked right.
  PASS's is four separate pieces: the resident background, a 3-halfword pointer at
  `0x1fe2`, a message line at `0x19be`, and the per-cycle list at `0x19ee`/`0x1a06`
  whose only branch (`1a0e`) goes to its own dynamic area.  Nothing in it mentions the
  background.
- **VERIFIED AGAINST THE REAL DATA, not reasoned about.**  Load the built `DEUCFLM.bin`
  at `0x0100`, write the `2000 1107 1fe2` PASS actually put at `0x1fe2`, walk from
  `0x1fe4` under the new rules: `0x1fe2` -> sector 0 -> `0x0107` (the CFIT slot) ->
  `0x04fc` (the XD0001 body) -> draws `GPC MEMORY`, `MEM/BUS CONFIG`, `1 CONFIG ( )`,
  `2 GPC`, `STRING 1 7`, `PL 1/2 11`, `CRT 1 12`, `LAUNCH 1 16`, `OPS 3 UPLK 50`,
  `READ/WRITE`, `DATA 20`, `BIT SET 22`, `SEQ ID 24` ... and stops at the PAD after 465
  steps.  That is the screen the user described from the real vehicle.
- THE PAD HAS TO TERMINATE, and following it is a trap: `111e` under sector 0 is CFIT
  slot `0x11E`, which is SPARE and therefore points at `XD0000` -- sixteen halfwords
  that draw **"NO CFMT BKGD"**.  That body is what an EMPTY slot is for; painting it
  over a background that just drew correctly is not a return path.  Taking it also
  loops, and the walker's `visited` guard would have hidden the mistake by stopping
  after the damage.
- STILL A HYPOTHESIS IN ONE PLACE: that the sector PERSISTS after the branch that used
  it, rather than being one-shot.  It has to, or the CFIT indirection (`0x107` ->
  `0x04fc`) would land in sector 1.  No document; it is what the data requires.

### [2026-08-31] Target: problems.md, HANDOFF-FCMBOOT.md
- **THE WRONG POSITIONS WERE ONE CONSTANT: MEDS's beam-coordinate wrap is 2048 and the
  generator's is 1536.**  `deuFCW.coffee:49` `GRID = 2048`; Don's own
  `nsts-sdl-dps/src/dfg/fcw.py` says `GRID = 1536  # screen-coordinate wrap (both
  axes)`.  The two implementations disagree, and the modulus a coordinate is READ under
  has to be the one it was WRITTEN under.
- WHY IT SHOWS UP ONLY BELOW ROW 13: a character row runs DOWNWARD from `ROW_ORIGIN`
  366 at `ROW_PITCH` 27, so row 14 is already coordinate -12 and is stored wrapped.
  XD0001's `YC=18` is the word **1416 = -120 + 1536**.  Taken modulo 2048 that reads as
  row 37, off the bottom.  The user's description was exact -- "each line starts in the
  middle vertically, and every line wraps around, occupying the right half of a line
  and the left half of the next, twice as many lines as expected".
- MEASURED, against the deck's own directives rather than by eye: walk the real
  `DEUCFLM.bin` loaded at `0x0100` with the `2000 1107 1fe2` PASS writes, and score the
  text runs against `XD0001.dfg`'s `XC=`/`YC=`.  **At 1536 all 45 runs land exactly
  where the deck puts them and NONE is off-screen; at 2048, nine are.**  Spot checks:
  (18,1) `GPC MEMORY`, (1,3) `MEM/BUS CONFIG`, (9,8), (4,11), (2,18) `LAUNCH 1 16`,
  (18,3) `READ/WRITE`, (18,8).
- THE PREVIOUS ROUND WAS RIGHT AS FAR AS IT WENT, and the user's report is what showed
  it: "bits and pieces of the GPC MEMORY screen, always at the wrong position" means
  the CONTENT arrived -- the two-pass walk and the sector-qualified branch work -- and
  only the geometry was wrong.  Two independent defects in series, and the first had to
  be fixed before the second could even be seen.
- NOTE FOR WHEN DON'S MEDS LANDS: this one is a one-line disagreement between his own
  two implementations, and worth telling him about separately from the rendering work,
  since it will bite any display with content below row 13 no matter who wrote the
  interpreter.

### [2026-08-31] Target: problems.md, HANDOFF-FCMBOOT.md
- **THE PREVIOUS ENTRY'S "ONE CONSTANT" IS WITHDRAWN.  There are TWO COORDINATE SYSTEMS
  on this bus, differing in FOUR constants, and which one a word is in depends on who
  wrote it.**  Scoring every list's position words by whether they land on integer
  character cells and on screen at all, over real captured traffic:

        list                     MEDS's calibration      DFG's constants
        GPCIPL's own screen      2/2 cols, 2/2 rows      0/2 cols, 0/2 rows
        PASS display list        15/24, 0/19, OFF        24/24, 19/19, on
        PASS 0x1a06 area         14/22, 0/18, OFF        22/22, 18/18, on
        PASS message line        0/1, 0/1, OFF           1/1, on
        XD0001 critical format   0/6 (cols 97.8, 80.8)   6/6, matching its deck

  MEDS: `GRID 2048, COL_ORIGIN 1573, ROW_ORIGIN 364, ABS 1555/364`.  DFG:
  `1536, 1042, 366, 1024/1902`.
- WHY MEDS HAS THE ONE IT HAS, and it is not a mistake anyone should be blamed for:
  its constants are "calibrated against captured display memory", and **the only
  display memory anyone could capture before PASS ran was GPCIPL's**.  They are exactly
  right for GPCIPL and wrong for everything PASS emits, which is all of it.
- WHY DFG'S IS THE FLIGHT SOFTWARE'S: `src/dfg/fcw.py` generates every format with
  those constants, and our generated XD0001 is byte-identical to the historical DFG
  output OI301700 still carries -- so the HISTORICAL formats encode `YC=18` as 1416,
  which is row 18 only under 1536/366.
- MEDS2 now SELECTS the geometry, defaulting to DFG's because running PASS is the
  point; `NSTS_DEU_GEOM=gpcipl` restores the other for reading GPCIPL's own menu.  The
  two cannot both be right at once and reconciling them wants documentation nobody has.
- **THE LESSON, and it is one this log already carries in another form:** the user
  reported GPCIPL's screen getting WORSE at the same time as PASS's got better, and
  that pair is what exposed the mistake.  A change that improves the case you are
  watching and quietly breaks the case you are not is indistinguishable from a fix
  until somebody looks at both.  I had "verified" 1536 against XD0001's deck alone --
  a real oracle, but a single one, and every format in that corpus shares a producer.

### [2026-08-31] Target: problems.md, HANDOFF-FCMBOOT.md
- **DON'S OWN CAPTURE SETTLES WHICH FRAME IS THE HARDWARE'S**, and it is not the one I
  guessed.  `data/0001-O-GPC_MEMORY.dfb` is a capture of THIS VERY SCREEN, and it
  decodes under MEDS's calibrated constants with **201 of 201 integer columns AND
  rows**; under DFG's, 72 of 201 columns and 0 of 201 rows.  So MEDS's frame is the
  DEU's, and the DFG frame is a format-relative one that something relocates -- the two
  differ by a fixed offset, +531 in X and +510 in Y mod 2048, no scaling.
- AND ITS LAYOUT IS THE ORACLE FOR THE WHOLE SCREEN: `GPC MEMORY` at row 2 col 17,
  `MEM/BUS CONFIG` and `READ/WRITE` both at row 4, `1 CONFIG` at row 5, last line at
  row 25, 177 text runs.  Our render of XD0001 under the DFG constants plus the
  renderer's own `+1` produces exactly that, row for row -- which means the row numbers
  are RIGHT and any residual vertical compression is downstream of them.
- MEDS2 now switches frames **live with F10** rather than only at startup, since GPCIPL
  and PASS need different ones and both happen in a single run.
- **A ONE-ROW UPWARD DISPLACEMENT, LONG KNOWN AND NOW FIXED**: the user has reported for
  some time that the whole DPS page sits a row high -- the top of the header clock
  clipped, a row of slack at the bottom -- and it was left alone because MEDS was not
  ours to modify.  `mduScreen_DPS.build` already carried `@group.position.y = -0.75`
  with the comment "was +1, shifted up 1.75"; it is now `-0.75 + 1`, tunable with
  `NSTS_DPS_YSHIFT` (which is the CORRECTION, so 0 restores MEDS's value).  One cell is
  one world unit, so this moves text, clock, scratch pad and the POLL FAIL cross alike.
- STILL UNEXPLAINED: the user reports the vertical spacing "compressed to about 0.7".
  The row numbers match Don's capture exactly, so it is not the coordinates.  The
  discriminating observation to ask for is which row `MEM/BUS CONFIG` lands on and which
  row the last line lands on -- 4 and 25 means the layout is right and the impression is
  coming from somewhere else.

### [2026-08-31] Target: problems.md, HANDOFF-FCMBOOT.md
- **F10 WAS A BAD KEY AND THAT IS THE WHOLE OF THAT SYMPTOM**: Chromium gives F10 to the
  menu bar, so pressing it moved focus out of the document and the DEU keyboard stopped
  taking keys -- "it no longer accepts my ITEM 1 EXEC".  The toggle is now **Shift+V**,
  one of the few letters `DPSKeys` does not map to a DEU key.  It also only called
  `redraw()`, which repaints geometry already built, so the frame change reached nothing
  but the furniture rebuilt each cycle -- about a character's width, exactly as reported.
  It now calls `refresh()` first.
- **MEDS'S BUILT-IN SCREENSHOT CANNOT WORK HERE**: `mdu.screenshot()` builds a `data:`
  URL and calls `a.click()`, which needs a download handler Electron does not have in
  this app.  Shift+S saves nothing and never did.  Do not ask for one.
- THE CAMERA IS NOT THE EXPLANATION FOR THE 0.701, checked rather than assumed:
  `resetCamera` spans 53.24 cells across and 38.32 down, so in a 1024-px window a cell
  is 19.23 x 26.72 px -- already the 19/27 aspect of `COL_PITCH`/`ROW_PITCH`.  Square
  cells would have given 0.717, which is close enough to the measurement to have been
  believed without checking.
- SO THE REMAINING CANDIDATE IS THE WALK ITSELF, and specifically the one thing my
  offline model does NOT implement: `mduScreen_DPS` folds the X/Y REFERENCE REGISTERS
  into every position word when FCW2's `xyRef` gate is set (`beamY = (v.y + (if xyRef
  then ty else 0))`).  My walk reproduces the deck's rows without them; MEDS may not.
  `NSTS_CELL_TRACE` exists to settle that -- it records what the RENDERER computed, not
  what I think it should have.
- METHOD NOTE, and it is the one this whole day keeps teaching: three separate times now
  a number I derived offline has looked decisive and been incomplete because the model
  left something out -- the sector, the second coordinate frame, and now possibly the
  reference registers.  An offline model of somebody else's interpreter is a hypothesis
  generator, not an oracle.  Instrument the real thing.

### [2026-08-31] Target: problems.md, HANDOFF-FCMBOOT.md
- **THE GLYPH TRACE CAPTURED THE WRONG THING, and the flaw was mine**: it capped the
  whole RUN at 6000 glyphs, and GPCIPL's screen -- repainted every 0.57 s -- spent the
  budget in about twenty seconds.  6008 lines, every one of them `FG`, none of PASS and
  none of the background pass.  It now truncates at the start of each `refresh()`, so
  the file always holds the frame that is on the display.
- IT DID PROVE ONE THING: **GPCIPL's screen under the DFG frame is nonsense** -- glyph
  rows come out at 1.11, 2.07, 3.07 and one run at row **56**, all crammed into columns
  28-52.  Non-integer rows are the signature of the wrong frame, and they are exactly
  the "upper right quadrant" the user reported.
- **THE FRAME TOGGLE ONLY MOVED THE PAGE A CHARACTER'S WIDTH BECAUSE THE WALK READ
  LOAD-TIME CONSTANTS.**  `mduScreen_DPS` takes its starting beam position from
  `FCWD.COL_ORIGIN`/`FCWD.ROW_ORIGIN` and wraps position words with `FCWD.GRID` -- all
  captured at module load, so `setGeom` reached `cellCol`/`cellRow` and nothing else.
  The walk now reads a live `FCWD.geom()`.  Same bug in both F10 and Shift+V, so the key
  change was necessary but not sufficient, and the second report of an unchanged symptom
  is what showed it.
- The default frame is now **gpcipl**, because GPCIPL is what comes first in every run
  and its menu has to be readable to work the sequence; Shift+V once after RUN moves to
  PASS's.  `NSTS_DEU_GEOM=dfg` starts the other way.
- ALSO NUDGED: the rule above `MAIN MENU` and the legend itself sit a row high like the
  rest of the page, so `mduMenuArea` takes the same `NSTS_DPS_YSHIFT`.

### [2026-08-31] Target: problems.md, HANDOFF-FCMBOOT.md
- **THE GLYPH TRACE SETTLES IT: THE CRITICAL FORMAT NOW RENDERS EXACTLY RIGHT.**  409
  background glyphs and 163 foreground, reconstructed into a page:

        row  2   GPC MEMORY
        row  4   MEM/BUS CONFIG   READ/WRITE
        row  5   1 CONFIG  ( )     DATA 20   BIT SET 22   SEQ ID 24
        row  8    STRING 1  7      ADD ID   DESIRED   ACTUAL
        row 16                    MEMORY DUMP        STORE   MC=
        row 25   OPS 3 INIT 51    ERR LOG RESET 48       SM  54

  Every row matches XD0001's deck AND Don's own capture: title row 2, MEM/BUS CONFIG
  and READ/WRITE row 4, 1 CONFIG row 5, last line row 25.  The user's own example --
  "line 24 should read OPS 3 INIT 51 / ERR LOG RESET 48 / SM 54" -- is there complete,
  at columns 2, 18 and 40.
- SO THE ~0.70 IS NOT IN THE WALK, and that is now established rather than argued.  The
  remaining candidate is the mapping from rows to the window: 26 text rows drawn one
  cell per row into a camera **38.32 cells tall** (`resetCamera`: 0.20..53.44 across,
  -1.75..36.57 down) fill 26/38.32 = **0.68** of it.  Against a measurement of ~0.70
  that the user has since said may be ~4% out because the reference document is an OI30
  screen with one fewer text row.  `NSTS_DPS_YSCALE` dials it live; the default stays 1
  until somebody MEASURES the number instead of deriving it, which is the mistake this
  log already records three times today.
- ONE COLUMN, NOT CHASED: our title starts one column right of Don's capture (deck
  XC=18 against his 17).  The user says horizontal spacing is right, so it is left
  alone and written down rather than tuned away.
- **A REGRESSION TO CHASE: GPCIPL now shows nothing but its clock.**  It rendered
  before, in its own frame, which is now the default.  Not diagnosed -- the trace holds
  one frame and by the time it was read the run was at GPC MEMORY.  Next run, capture
  `cells.log` WHILE GPCIPL is on screen and before pressing anything.

### [2026-08-31] Target: problems.md, HANDOFF-FCMBOOT.md
- **THE VERTICAL SCALE WAS THE WRONG INSTRUMENT AND IS REVERTED.**  `@group.scale.y`
  stretched the GLYPHS rather than the gaps, and carried the POLL FAIL cross, the red X
  and the boxed GPC number down into the MAIN MENU area, because they are drawn in the
  same group and the same units.  A knob is not automatically a safe way to let somebody
  else find a number: this one could only be wrong in ways that looked like progress.
- AND THERE IS NOWHERE FOR THE HEIGHT TO GO.  The page already runs to row 25 with the
  MAIN MENU rule just below it, so anything past about 1.05 pushes text through it.
  Extra space between rows is only possible if the page AREA grows first.
- **SO THE ~0.70 IS NOT A RENDERING ERROR AT ALL.**  The cell rows are right -- the
  glyph trace matches XD0001's deck and Don's own capture row for row.  A real MCDS CRT
  gives its 26 lines the whole screen; an MDU gives them the area above its menu bar.
  The proportion differs because the two devices are laid out differently, and closing
  it is an MDU LAYOUT change -- move the menu area down, give the page the height, and
  scale row PLACEMENT (not the group) to fill it.  That is a change to Don's design, not
  a fix to ours, and it is cosmetic.
- STILL OPEN AND NOT DIAGNOSED: GPCIPL shows nothing but its clock, and during the scale
  experiment it reappeared only above about 1.2 -- which makes no sense under any model I
  have and is the reason to stop guessing.  It needs `cells.log` captured WHILE GPCIPL is
  on screen.

### [2026-08-31] Target: problems.md, HANDOFF-FCMBOOT.md
- **THE OVERLAID "GARBAGE" IS PASS'S OWN VARIABLE DATA, CORRECTLY PLACED.**  Overlaying
  both passes from the glyph trace gives a coherent GPC MEMORY page -- `1 CONFIG`,
  `2 GPC`, `DATA 20`, `BIT SET 22`, `BIT RST 23`, `SEQ ID 24`, `WRITE 25`,
  `26 ENG UNITS`, `HEX 27`, `ADD ID / DESIRED / ACTUAL` with items 28-39,
  `MEMORY DUMP`, `40 START ID`, `41 NO WORDS`, `42 WDS/FRAME`, `DUMP START/STOP 43`,
  `44 DOWNLIST GPC`, `STORE MC=`, `45 CONFIG`, `46 GPC`, `STORE 47`, `MM AREA`,
  `PL 52 / GNC 53 / SM 54`, `OPS 0 ENA 49`, `OPS 3 UPLK 50`, `OPS 3 INIT 51`,
  `ERR LOG RESET 48` -- with the variable fields sitting inside it, not scattered over
  it.
- WHAT THE FIELDS CONTAIN, counted off the wire: **362 nulls, 307 spaces, 100 `M`
  (0x4d), 44 `F`, 40 `0`, 17 `-`**, and six `]` (code 0x01).  One `M` trails every data
  field on the page.  The likely reading is the DPS missing-data flag -- the release
  does carry the concept, `FPMMTURM.asm:678` masks a "DATA MISSING" bit -- so a GPC
  MEMORY page with nothing requested showing `M` on every field is plausibly CORRECT
  rather than broken.  **Not verified** to the display character; that trace has not
  been followed.
- TWO THINGS THAT DO LOOK WRONG, and they are small and specific: the DPS header's
  display-ID field reads **`-0602/   /`** where Don's capture of the same screen reads
  `0001/000/`; and `2 GPC` shows **ten `F`s** for its five GPC slots.  Both are field
  CONTENT, in the right place, so they are questions about what PASS computed, not about
  the renderer.
- THE BOXED GPC NUMBER moved up one text row -- box, digit and both kybd-active bars
  together, since they are one assembly.  The page nudge had left them behind and the
  rule over MAIN MENU was bisecting the box.
- ROWGAP: the user settled on **1.15**, not the 1.35 I derived.  Recorded because the
  derivation was again from geometry rather than from the screen.

### [2026-08-31] Target: problems.md, HANDOFF-FCMBOOT.md
- **THE "MISSING DATA" READING OF THE `M`s IS WITHDRAWN.**  The user rejected it flatly
  -- `]`, `F` and `M` scattered through every field is the opposite of plausible data --
  and they are right.  I reached for a convention that would make the output acceptable
  instead of asking what would produce it.  That is the same failure as the sector, the
  second frame and the row pitch: a story that fits, offered before a measurement that
  discriminates.
- A LEAD RAISED AND KILLED IN THE SAME SITTING, recorded so it is not raised again:
  **the display compool's address constants are correct.**  `#PCD0001` carries 99
  relocations and **99 of 99 match their linker target** when read as HALFWORDS.  (Read
  as fullwords 0 of 99 match, which briefly looked like a catastrophe -- the address is
  one halfword and the next halfword is the following FCW.)  So the fields are being fed
  from the right addresses; unrelocated PADRs are not the explanation.
- WHAT THE ARITHMETIC RULES OUT: `F` = 0x46 IS a correct hex F from a nibble conversion
  (`0x30 + n + 7` for n = 15).  `M` = 0x4d cannot come from one -- it would need a nibble
  of 22 -- so the `M`s are a literal character the flight software chose to write, not a
  digit conversion gone wrong.  Whatever they are, they are not garbage arithmetic in a
  field.
- NEXT STEP WHEN THIS IS PICKED UP, and it should be a measurement, not a theory: take
  ONE field -- the display-ID field is best, it reads `-0602/   /` where Don's capture of
  the same screen reads `0001/000/` -- find its DDT entry in `CD0001.dfg`, find the
  variable it names, and watch what PASS writes there.  One field traced end to end
  beats another round of pattern-matching on the characters.

### [2026-09-01] Target: problems.md, HANDOFF-FCMBOOT.md
- **THE DISPLAY-ID FIELD, TRACED END TO END.  The display path is faithful; the DATA it
  renders is uninitialised.**  That reframes the whole "garbage overlay".
- THE PATH: `SSSRC/DCICYC.asm`, `DCIBHDR` (linked at **0x42345**) builds the header line.
  It emits the X/Y FCWs, sets up a pseudo DDT entry at `CLOCDDTP`, points it at
  `CMATPAGE`, and calls `DCI#CON` (**0x42495**) to convert the OPS page number; then the
  SPEC page (`CMATPAGE+1`) and the DISP page (`CMATPAGE+2`), each preceded by a slash
  FCW `X'C02F'`.  `CDDMAT` (`MLIB80/CDDMAT.asm`) is a DSECT: `CMATPAGE` is +10 halfwords
  from `CMATSTRT`, three halfwords, one per display level.
- WHAT THAT PROVES ABOUT OUR HEADER: ours reads `-0602/   /`.  The second and third
  fields being **slash-plus-blanks is the code's own ZERO branch** ("THE SPEC PAGE
  NUMBER IS NOT VALID, SO STORE A SLASH ... AND MOVE SPACES OVER"), so `CMATPAGE+1` and
  `+2` are 0 and correct.  Only the OPS page converts, and it converts to a NEGATIVE
  five-character value where the reference shows `0001`.
- **THE LOAD-BEARING OBSERVATION IS A FIELD WITH NO ARITHMETIC IN IT.**  The deck has
  `XC=12, CHARR=(CZ2V_MF_MC,2)` -- a plain two-character copy, no conversion -- and on
  the wire that field renders `e346` = **"FF"**.  PASS stores characters in EBCDIC and
  translates to DEU codes when building FCWs; DEU 0x46 comes from EBCDIC 0xC6, and
  **0xC6 is the fill byte** (`STACK_FILL_BYTE`, `INIT=C6C6` on every MMUDAT allocation).
  So that variable holds the FILL PATTERN and the display is drawing it correctly.
- SO THE `M`s AND `F`s ARE DOWNSTREAM OF UNINITIALISED COMPOOL STORAGE, not of a broken
  renderer or a broken conversion: a character field shows the fill as "FF", and a
  numeric conversion of fill produces out-of-range "digits" -- `AHI R4,X'3030'` on a
  value of 29 is exactly 0x4d, `M`.  `CZ2V_MC_REQ` rendering as **-50** where a memory
  configuration should be 0-8 is the same thing.
- RULED OUT ALONG THE WAY, each checked rather than argued: the compool's address
  constants (99 of 99 correct); `SRDL`/`SLDL` register pairing (already carries the
  `(R1+1) mod 8` fix POO 6.6 requires); and the linked `#PCZ2COM` initial image, which
  is mostly ZEROS rather than fill -- so whatever puts C6C6 into these variables does it
  at RUN TIME, not at link time.
- **A REAL INCONSISTENCY FOUND WHILE LOOKING, not yet a proven bug**: `exec_D`
  (`cpu_instr.c:176`) forms its register pair with `cpu_r(t, x + 1)` and **no `% 8`**,
  while `exec_SLDL`/`exec_SRDL` were explicitly corrected to `(x + 1) % 8` with the POO
  citation.  `D R6` does not hit it, so it is not this symptom, but `D R7` would address
  a ninth register.  Worth fixing on its own.
- NEXT: find where `CZ2V_MF_MC` gets C6C6 at run time.  It is a two-character variable
  with no arithmetic anywhere near it, which makes it the cheapest possible probe --
  snapshot main storage after RUN, read it, and find who wrote it.  Its address needs
  the SDF, not the link map (HAL/S compool variables are not individually in
  `PHASE02.sym.json`; only `#PCZ2COM` at 0x23f4 and a few entries are).

### [2026-09-01] Target: problems.md, HANDOFF-FCMBOOT.md
- **NOTHING WRITES C6C6 THERE.  THE MEMORY IS CORRECT AND THE DISPLAY IS MISRENDERING
  IT.**  That is the answer, and it inverts yesterday's conclusion.
- HOW IT WAS PINNED.  `ap101Utils.sdf` gives the compool offsets the link map does not:
  `CZ2V_MC_REQ` is INTEGER at `#PCZ2COM`+772 = **0x026f8**, `CZ2V_MF_MC` is CHARACTER(2)
  at +774 = **0x026fa** (`#PCZ2COM` is at 0x23f4).  `YAGPC_WATCHHW=26f8-26fc` over a
  whole run catches **ten stores, all of them IOP writes from BCE 18** -- the tape:
  GPCIPL's own phase at t=4.6 s, then the SSL loading phase 2 at t=26.4 s writing
  `0000 0000 0202 2020 f000`, which is EXACTLY the linked `PHASE02.fcm` content.  After
  that, for the rest of the run, **no store of any kind**.
- SO WHEN THE DISPLAY DRAWS, MEMORY HOLDS: `CZ2V_MC_REQ` = **0** and `CZ2V_MF_MC` =
  `0202 2020`.  And the wire, in the same run, 60 display fills in: col 9 renders
  **`-50`**, col 12 renders **`FF`**, col 13 renders `-0`.  A field holding zero is
  being drawn as minus fifty.
- **AND THE DDT IS NOT THE PROBLEM EITHER**, which was the obvious next suspect since our
  own `dfg` generates it: our generated `CD0001` is **byte-identical to the historical
  DFG output** OI301700 carries -- 477 of 477 halfwords.  (`XD0001`, the static half,
  was already known identical at 463 of 463.)
- THAT LEAVES ONE PLACE: **the EXECUTION of `DCI#CON`** (`MLIB80/DCI#CON.asm`, linked at
  0x42495).  Correct DDT, correct data, wrong output means an emulator defect in what
  that code runs.  Its `CHARCONV` digit loop is `SRDL R6,4` / `D R6,ITEN` / `M R6,ITEN`
  / `SLDL R6,4` / `SR R2,R6` / `SLL R2,16` / `AHI R4,X'3030'`, and its addressing is the
  SRS forms `LH R5,0(R7,3)`, `STH R3,0(R2,3)`, `LA R2,1(R2,3)`.
- TWO CANDIDATES, in order: (1) the SRS addressing form with that third operand -- if it
  is mis-decoded, every fetch and store in the loop is off, which fits BOTH the numeric
  and the character fields being wrong; (2) the register-pair arithmetic `D`/`M`.
  `SRDL`/`SLDL` already carry the POO `(R1+1) mod 8` fix, but **`exec_D` does not** --
  `cpu_instr.c:176` still forms its pair with a plain `x + 1`.
- WITHDRAWN: yesterday's "the variables hold the C6C6 fill" reading.  It was inferred
  from `FF` being EBCDIC `0xC6` and never checked against memory.  The `FF` is
  manufactured by the display path out of `0x2020`.

### [2026-09-01] Target: problems.md, HANDOFF-FCMBOOT.md
- **MEASURED REFERENCE COORDINATES REPLACE THREE DAYS OF ADJUSTING BY EYE.**  The user
  measured stroke-centre positions off a reference frame, 1024x1024, origin top-left,
  +/-1 px.  Ten glyphs spanning the page plus the furniture.  Every number below is a
  fit, not an impression.
- GLYPH INK OFFSETS make the fit possible at all: a glyph's ink does not start at its
  cell anchor, and each character differs.  Computed from `deu_font.svg` through MEDS's
  own normalisation (`0.95 + 0.9*x/(512/43)`, `0.10 + 0.9*y/(512/30)`, then `drawGlyph`'s
  `x-1`): `M` +0.116/+0.142, `E` +0.048/+0.153, `I` +0.328/+0.142, `B` +0.018/+0.158,
  `S` +0.063/+0.153, `G` +0.131/+0.147, `T` +0.116/**+0.084**.  Subtracting these is what
  takes the residuals from several px to sub-px.
- **THE ROW PITCH IS ALREADY EXACT.**  Fitted 26.707 px/row against MEDS's rendered
  26.722 -- **0.06% apart over a 21-row baseline**.  So the "compressed to 0.701" was
  never in the rendering; the user had already suspected their OI30 reference document.
  `NSTS_DPS_ROWGAP` wants **1**, and the knob stays only as a knob.
- **THE TEXT SITS 1.43 ROWS LOW RELATIVE TO THE FURNITURE**, and that is the real defect.
  Converting the ten glyph measurements to cells through a fit anchored on the
  furniture's own exact constants gives -1.48 -1.48 -1.49 -1.48 -1.49 -1.48 -1.33 -1.33
  -1.41 -1.35.  **Constant to +/-0.08 across the whole page**, so an offset, not a scale.
  Carried by `NSTS_DPS_TEXTY`.
- COLUMNS ARE RIGHT within the measurement's own noise: mean +0.18 cell, and the two
  worst (`B` +0.24, `S` +0.46) are glyphs whose leftmost stroke is hardest to call.  No
  column change made.
- THE ABSOLUTE OFFSET, which is the half that depends on an assumption: furniture 1.54
  rows low, text 2.89, both satisfied by the -1.43 text offset plus a group shift of
  -1.5.  `NSTS_DPS_YSHIFT` therefore goes **+1 -> -0.5**.  It rests on the crop being
  the whole MDU face, which its own content supports (the MAIN MENU rule and legend are
  in frame, the POLL FAIL cross spans 10..1018 of 1024).  **It also contradicts the
  earlier eyeball report that the page sat a row too HIGH with the clock clipped** -- the
  fit says every text row, the clock included, was ~2.9 rows too LOW.  One of the two is
  wrong and the measurement is the one with error bars.
- MENU AREA moved 3 px right on the user's own measurement: its leftmost character sits
  at x=1 of 1024 and is clipped.
