# CLAUDE_LOG.md

(Cleared 2026-08-31 by Full Documentation Sync.  146 entries spanning
2026-08-27 to 2026-08-31 were applied to the four files they named.

- **`problems.md`** (121 entries) — §8's date range extended to 2026-08-31,
  a RESOLVED banner added to **§8.15** pointing at its answer, seventeen new
  method failures appended to **§8.10**, and eleven new subsections:
  **§8.16** the wrong manual (the AP-101 C/M masks bit 15 for fullword
  operands, the AP-101S explicitly does not, and `ISPB`'s fullword forms
  changed with it — the single error behind four successive wrong
  conclusions); **§8.17** the BCE `@`-family, the one instruction at which
  `gpc` and yaGPC2 diverge, and why no differential harness was built;
  **§8.18** completing phase 2, a stale compiler and two extensionless-member
  traps; **§8.19** the four things the ground Mass Memory Build writes that our
  toolchain did not, and the five-step volume recipe; **§8.20** pacing the IOP
  by simulated time; **§8.21** store protection end to end, including the
  `SPON`/`SPOFF` design and the unresolved `mmbstamp`-vs-`lnk101` deck
  disagreement; **§8.22** placement fidelity and `--external-syms`;
  **§8.23** three context-switch defects only running PASS could find;
  **§8.24** driving the crew station headlessly and the BFC CRT discrete's
  double duty; **§8.25** real peripherals — `--real-time`, the MTU, the
  intercomputer bus, MM READY; **§8.26** why PASS went idle after 26 seconds.
- **`HANDOFF-FCMBOOT.md`** (26 entries) — retitled to `… → PASS`, §1's goal
  chain extended through the SSL, a state-in-a-paragraph added at the top of
  §2, the SSL subsection rewritten from "where the boot stands" to how it was
  finished, a new "PASS runs" subsection, "What is actually still open"
  rewritten from scratch, and three new subsections: the headless run recipe,
  the env-gated instrumentation, and the traps.
- **`HANDOFF-PASS-IDLE.md`** (1 entry) — rewritten.  Its open question is
  answered, so it now records the fix, the death chain, the before/after
  measurements, the two map corrections (the stride-`0x12` table at `090b2` is
  the IOQE table, not the TQEs; the CVT base is `0x140`), and the confirmed
  FCOS field offsets.
- **`HANDOFF-OI340600.md`** (2 entries) — added through `dass-handoff.py` as
  entries **#289** and **#290**, since that file is generated and a hand edit
  would be silently overwritten.  #289 is the load-block checksum technique
  (find the length by searching for the L satisfying the flight software's own
  invariant; the DMA count is not the length); #290 is the TQE-table count
  discrepancy, with the causal claim built on it explicitly withdrawn.
  `dass-handoff.py check` reports all three generated documents matching the
  database.

Claims were checked against the tree rather than copied from the log.
Verified present: the AP-101S "may now be located on odd address boundaries"
quotation in `cpu.c` with the mask gone (the one surviving `0xfffe` is inside
the `YAGPC_ALIGNTRACE` print, beside a "AP-101S: NO MASK" comment);
`HAL_S_LIBRARY_ERROR_GROUP 4` in `halucp.c`; `YAGPC_IOP_PER_INSTR` and
`YAGPC_IOP_PASS_US`; the `YAGPC_ISPB_ALIGN` gate; §2.2.8 and the "MODIFY PSW
ACTION" citations; `YAGPC_DEUKEYS_AFTER`; `--script` in `discretePanel.py`; and
all ten referenced commits.  The three `nsts-sdl-dps` fixes are still local and
uncommitted on HEAD `755a372` — `parent_pool_lo` in `mmbstamp.py`,
`fcmImage.py` and `mmu2mmv.py`, plus `LoadBlock.reserved` in `mmbstamp.py`.

Three corrections were made in the process.  **`mmu2mmv.py` lives in
`src/tools/`, not `src/ap101Utils/`**, which the log implied.  **The
`YAGPC_DEUKEYS` `!ipled` gate the 2026-08-30 entry flagged as a model
limitation has since been removed**, with the reason recorded in
`deumodel.c:171`, so it is not carried forward as open.  And the log's own
retractions were followed rather than its first statements: the corrupt TQE
link, the "steady leak", the ordinal-parity invariant, "the flight software is
exonerated", "the phase build is blocked on Don", "phase 3 destroys FCMLINIT",
"there is a second `mmbstamp` gap at `FIOMUWB2`" and "`SPON`/`SPOFF` is
redundant" are all recorded as withdrawn, with what survives them kept.

Two things were *not* re-verified and are carried forward as reported: that
`--watch` misattributes a store to the following instruction, and that the 8K
DEU program image at `DCPSTART` is all zeros in every load.)

### [2026-08-31] Target: problems.md, HANDOFF-FCMBOOT.md
- **CRT2's missing menu was the BCE `@`-family reading its count tables as
  HALFWORDS.**  `#TDL`, `#MIN@`, `#MOUT@` and `#RDL` fetched the word count with
  `iop_g_eah` from a per-bus table at a `2*BCE#` bias.  Those tables are arrays of
  `A()` FULLWORDS -- the shape `#BU@`, `#LBR@` and `#CMD@` were already fixed to
  fetch through, and the one `EQU *-36` implies.  A halfword read at an even entry
  returns the fullword's HIGH half, always zero for a count, so every one of these
  instructions moved exactly ONE word regardless of the count.  Fixed as 96ab01cc4.
- MEASURED IN PASS'S DISPLAY PATH.  A DEU display fill is a 2-word header from the
  `#TDS` at `0x199ae` plus data from the `#TDL` at `0x199b2`; the DK2 count table at
  `0x08c94` holds `0000 0016` for BCE 7.  Before: **commanded 360 halfwords, 3 sent,
  every time** -- 21 truncations in 40 s on the wire, 0 complete.  After: 29 of 29
  complete in the GPC's own accounting, 17 complete / 0 truncated on the wire, and
  CRT2 renders GMT/MET, the GPC indicator and the display list instead of a bare
  clock.  TIME_FILL (7 hw, `#MOUT`, no table) always worked, which is exactly why the
  symptom was "a counting clock and no menu".
- WHY IT HAD NEVER BEEN ISOLATED: a fill whose data is one word is commanded as 3 and
  COMPLETES, so the small fills our DEU stub elicits mostly work; the stub only ever
  showed "abandoned 2 halfwords short" on a count of 5.  Real MEDS asks for a whole
  screen and the shortfall becomes 357.  A crude peer made a total failure look like a
  rounding error.
- HOW IT WAS FOUND, and the instrument is the reusable part: `YAGPC_XMITTRACE=<bus>`
  prints one line per bus command with the count it DECLARES against the words
  actually QUEUED and actually SENT before the next command.  Queued-vs-sent is the
  discriminator -- short at queue time means the bus program asked for too little,
  short at send time means the emulator lost words -- and the peer cannot tell you
  which, it can only say a transfer ended short.  The DMA-read counter is taken in
  `iop_queue_dma` so none of the FIVE instructions that can start a transmit (`#TDS`,
  `#TDL`, `#TDLI`, `#MOUT`, `#MOUT@`) is missed; an early attempt instrumented
  `exec_MOUT`/`exec_MOUT_at` by hand and silently patched `exec_TDLI` instead, which
  is why the first trace showed a display fill with no transmit instruction at all.
- FALSE LEADS, each killed by measurement: the transport's outbound queue (4096 deep,
  with an explicit "dropping a datagram" message that never appeared); the DMA queue
  (growable, verified); `dmaq_drop_for_bce` on an error terminate (`YAGPC_DMATRACE`
  counted ZERO drops).  The words were never queued in the first place.
- `#MIN@` FIXED ON THE SAME EVIDENCE, not by analogy: its BCE 24 table entry reads
  `0000 0002`, so the halfword read was receiving one word where three were wanted.
  `#MOUT@` and `#RDL` do not execute in this workload and are fixed on the family
  argument alone -- stated plainly rather than implied.
- THE FIXTURES CANNOT ARBITRATE, measured properly this time: `test_iop_bce_exec` is
  73499/74699 both ways and the failing SET is BYTE-IDENTICAL, 1200 lines either way.
  Getting that took forcing a rebuild -- `make` reported the test binary "up to date"
  after the source changed, so the first A/B compared the same binary with itself.
  That is §8.10's stale-binary trap, hit again.
- STILL OPEN, seen while measuring and not chased: `func=005 count=254` to IUA 8 on
  DK2 is issued 118 times and transmits nothing.  Nothing queues for it, MEDS never
  replies to IUA 8, and BCE 7 takes ZERO receive timeouts, so it is consistent with a
  control or receive-shaped command rather than a second truncation -- but it has not
  been identified.
- ALSO: the rendered CRT2 screen is sparse -- clocks, the GPC indicator, the MEDS menu
  bar and a scatter of F/M characters.  The truncation is fixed and verified; whether
  that is the CORRECT PASS display for this state is a separate question and I have no
  reference image to judge it against.
- HARNESS NOTE: `MEDS.sh` runs `electron-esbuild build`, which CLEANS `dist/`, so
  starting a second instance wipes the first one's `main.js` mid-launch.  Launch the
  second directly -- `electron dist/main/main.js meds --size 512 crt1 idp1`, which is
  MEDS.sh's own last line minus the rebuild -- and nothing is written in Don's repo.
- TRAP HIT AGAIN, fifth time in this project: a `pgrep -f` whose pattern text appears
  in the same command line matched the shell and killed it (exit 144).
