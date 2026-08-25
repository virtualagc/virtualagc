# HANDOFF — FCMBOOT → GPCIPL → MEDS

Written to survive a `/compact`. Everything needed to resume is here; the
long-form narrative is in `CLAUDE_LOG.md` (entries dated 2026-08-24 and
2026-08-25) and should be read for *why*, not *what*.

---

## 1. The goal

Boot the real Shuttle IPL chain in yaGPC2, end to end:

    firmware IPL → FCMBOOT (bootstrap) → reads GPCIPL off the mass memory
                 → hands control to GPCIPL → GPCIPL drives the MEDS display

PASS User's Guide (`~/Desktop/sandroid.org/public_html/apollo/Shuttle/PASS
USER GUIDE - OI32.pdf`) §2.3 and Table 2-2 (pages 49, 52, 53) describe the
sequence. Key facts established from it:

- **HALT** = hardware RESET held; no software runs. **STBY entered from
  HALT** releases reset and gives control to the Bootstrap Loader. The
  mode switch is a reset line, not a polled input — FCMBOOT never tests
  those bits.
- Table 2-2 step 10 (GPC IPL push/release) is the *firmware* IPL: it
  fills memory (C9FB 0-1FFFF, C6C6 20000-7FFFF) and reads the bootstrap
  in from the MMU. We do not emulate that microcode; `--ipl` stands in
  for the fill, and we load FCMBOOT from a file instead of from tape.

---

## 2. WHERE IT STANDS RIGHT NOW

FCMBOOT runs its entire logic and reaches the handover. It does **not**
yet transfer control to GPCIPL.

Reproducible failure, 2,707,470 steps:

    ERROR: invalid instruction 0xc99c at 0x7c3c

What happens: at `0x30239` FCMBOOT executes `LPS X'0014'` — its own
"ISSUE THE SYSTEM RESET", which is *how* it gives control to GPCIPL, by
loading the PSW pair from PSA 0x0014 where GPCIPL's reset vector should
now be. **The PSW it loads is 0x00000000.** Execution therefore begins at
address 0 and slides ~32,000 instructions through empty store until it
reaches FCMSSLPT and hits an invalid opcode.

### The open puzzle — START HERE

The tape carries the right vector. LB1 has `0x0014 = 013F 0011 0008`
(GPCIPL's `SRESINTN → IOPHISAM`), and the composed IPL image agrees. But
at the moment of the LPS, memory reads:

| addr   | memory | tape | |
|--------|--------|------|-|
| 0x0004 | 0000   | 0235 | |
| 0x0014 | 0000   | 013F | ← the reset vector |
| 0x0044 | 0000   | 08A6 | |
| 0x1000 | 8000   | 8000 | matches |
| 0x3C21 | D779   | D779 | matches |

So the PSA end of LB1 did not take while the rest did.

**Ruled out: store protection.** `iop_write_main16()` (src/iop.c ~1059)
does enforce it and raises External 1 (DMA store protect violation, code
0004) on refusal; `YAGPC_INTTRACE=1` reports **zero** interrupts
dispatched for the whole run. Nothing was refused.

**RECONCILE THIS FIRST.** Breakpoint `0x3034e` (checksum FAILURE) *still*
hits in the same run as `0x30352` (checksum pass). If LB1's PSA really is
zeros in memory while the tape has content there, LB1's checksum could not
pass. The two observations contradict each other, so do not build on
either until you know which load block passes and which fails. Suggested
first move: instrument per-LB — at 0x30332 the checksum loop starts with
R6 = number of LBs remaining and R0 = the LB descriptor pointer, so a
watch/break there identifies *which* block is being summed.

---

## 3. HOW TO RUN THINGS

Paths (scratchpad, session-specific — recreate if gone, see §5):

    SP=/tmp/claude-1000/-mnt-STORAGE-home-rburkey-git-virtualagc-yaShuttle-yaGPC2/187b3ac5-a4ae-459c-9827-61f2ad3aa645/scratchpad

| artifact | path | what |
|---|---|---|
| FCMBOOT image, stamped | `$SP/boot/BOOT-stamped.fcm` | PHASE01 + IPL phase table. **Use this one.** |
| FCMBOOT image, raw | `$SP/boot/real/BOOT.fcm` | before stamping |
| its symbols | `$SP/boot/real/BOOT.sym.json` | FCMPTAD1/2/3 = 894/1150/1406 |
| FCMBOOT listing | `$SP/boot/real/FCMBOOT.log` | ASM101S listing — **the reference for addresses** |
| tape | `$SP/tape/mmu2.mmv` | 1085 blocks, GPCIPL at 2/4/3/0 |
| composed IPL image | `$SP/donroute/IPL/IPL.fcm` | 1 MB, 6 bytes from Don's reference |
| phase libs (25) | `$SP/phase_build/OI340600/PHASEnn.lib` | **top level**; sym.json is in `PHASEnn/` |

**The canonical run** (deterministic, no sockets):

    ./yaGPC2 run --ipl --mmu-model $SP/tape/mmu2.mmv --deu-model \
        --max-steps 40000000 $SP/boot/BOOT-stamped.fcm

Add `--break <hexaddr>`, `--watch <hexaddr>`, `--verbose` (register dump at
stop), `--trace` (~100 bytes/step), or `--debug` with commands piped on
stdin: `printf 'b 0x30239\nc\nr\nx 0x14 4\nq\n' | ./yaGPC2 run ...`

Env traces: `YAGPC_INTTRACE=1` (interrupt dispatches — invaluable),
`YAGPC_MMUTRACE=1`, `YAGPC_DISCRETETRACE=1`, `YAGPC_CLKTRACE=1`.

### Addresses you will need

FCMBOOT relocates itself to **sector 6**, so its runtime addresses are
`0x30000 + offset`. Breakpoints take the **full** address (0x30239), but
the hit message prints only 4 hex digits ("breakpoint at 0x0239").

| addr | what |
|---|---|
| 0x0014 | PSA system-reset vector; FCMBOOT's own = 014B → FCMBMOVR |
| 0x0004 | PSA power-on vector; FCMBOOT parks here (wait-state bit) — **`--power-on` is wrong for FCMBOOT, use `--ipl`** |
| 0x3014B | FCMBMOVR, where `--ipl` starts it |
| 0x30180 | FCMBSTRT, after relocation to sector 6 |
| 0x30199 | FCMBSSM2 "NO MASS MEMORY" wait |
| 0x3019d | "SAVE THE BCE NUMBER" — a mass memory was selected |
| 0x3021E | FCMBSSM3, "tried all three areas" give-up wait |
| 0x3023E | `@SIO` — starts the MSC, i.e. talks to the MMU |
| 0x30332 | checksum loop entry (R6 = LBs left) |
| 0x3034E | `ZH FCMBGRD` — checksum FAILED |
| 0x30352 | checksum PASSED |
| 0x30239 | `LPS X'0014'` — the handover. **Currently loads zeros.** |

Phase 10's five load blocks (start, length, protected):

    0x00000 15394 1   0x03C22 9632 1   0x06DC0 502 0
    0x06FBC   994 1   0x07C00  770 1

---

## 4. TOOLS BUILT THIS WEEK (all committed, all ours)

- **`src/mmumodel.c/.h` + `--mmu-model <vol>` / `--mmu-unit <n>`** —
  in-process mass memory, ported from `mmu.coffee`/`mmuConf.coffee`/
  `volume.coffee`. Reads real `.mmv` files. Answers synchronously; no
  socket, no drops, no pacing. **Takes one bus only** and composes with
  `--bce-network` and `--deu-model` via `bus_router_service()` in run.c.
  This is what made the work reproducible — the networked runs disagreed
  with themselves and `--trace`/`--debug`/`--verbose` each changed the
  outcome. The user explicitly wants non-UI peripherals built in like
  this; MEDS stays external because it has a GUI worth having.
- **`tools/stamp_ipl_phase_table.py`** — builds FCMBOOT's IPL phase table
  and stamps it into FCMPTAD1/2/3. Nothing in the toolchain generates it
  (checked twice: `--stamp-phase-tables` covers #PFCMGPT/#PCDCPHA/
  FCMG3DAT, and mmubuild's DMMD pass names only SMARDD2A/SMARDD4A).
  Layout: four 3-hw phase descriptors (phases 10, 2, 13, 3), then 3-hw
  load-block descriptors, from `mmbstamp.LoadBlock.words()`.
  **Assumption, flagged: contiguous layout in that order.** Never verified
  against an original stamped table.
- **`tools/build_ipl_fcm.sh`** — rewritten to Don's composition route
  (relink with current lnk101, then `mmu2fcm --config IPL --phases 10
  --stamp-checksums`). Needs PHASE02.lib present. Output is 6 bytes from
  Don's reference IPL.fcm (the two unrelocated FIOMUWB2 constants).
- **`yaShuttle/discretePanel/`** (pushed): `discretes.py`,
  `discretePanel.py` (Tk), `discreteMonitor.py`. Wire format: multicast
  239.255.1.1:6980, four 16-bit words — op (SET=1/RESET=2), register
  (A=1/B=2), 32-bit mask in two halves, IBM bit numbering.

Emulator fixes made (all with POO citations, all committed):
- **MVH** wrote back the *expanded* address, overflowing and destroying
  the sector bit. gpc has the identical bug, unfixed upstream.
- **tick_counter** carried the timer borrow into the PSA high halfword
  unconditionally; the POO says a *masked* interrupt must not.
- **Instruction Monitor / MODE switch / discretes** — see CLAUDE_LOG.

---

## 5. TRAPS THAT COST REAL TIME — DO NOT REPEAT

1. **A breakpoint hit is not proof.** `0x4713` "proved" GPCIPL got
   control; the trace showed `004713: 0000  A 0,X'0000'(0)` — a runaway
   sliding through zeros traverses every address. **Check the instruction
   at the breakpoint.** I reported success on this and had to retract it.
2. **`timeout N cmd | grep` loses ALL output** when the timeout fires.
   Redirect to a file. (Done this four times.)
3. **The Bash tool's own default timeout is 2 minutes** regardless of the
   `timeout` given to the shell. Raise the tool timeout for long runs.
4. **Tool output is not reliably shown to the user.** Paste anything they
   must read into the reply itself.
5. **`mmu get`/`dump` take slash addresses** (`2/4/3/0`), not the ALLOC
   card form (`42300`) — the latter silently reads blank tape.
6. **Probe instruction *starts***, taken from the listing. 0x1c0 is the
   second halfword of the instruction at 0x1bf and never hits.
7. **A "wait state" stop exits 0 and prints nothing** without `--verbose`.
   Silence is a result, not a failure to run.

---

## 6. OUTSTANDING, NOT CODE

- **11 commits unpushed** on `master` (`e7417f9c8` … `2f19b1281`). The
  user pushes themselves; they asked not to push until things were tested.
- **MVH bug report to Don — drafted-but-held.** The user asked to wait.
  gpc still has it (`cpu_instr.coffee:5461`,
  `t.r(v.x).set32((destAddr << 16) | 0)`); JS bitwise is 32-bit so the
  same overflow applies. **Show the text before posting.**
- **Issue #30** (github.com/ColanderCombo/nsts-sim-gpc/issues/30) is open,
  asking Don for discretes; the PR is offered but explicitly withheld
  unless he asks. Branch `yagpc2-discretes` in `~/donschmidt/nsts-sim-gpc`
  is ready to become it (rebased on origin/main, 25/25 tests).
- **Issue #27** comment posted (CVFX; his call left standing).
- Repos as of now: `nsts-sdl-dps` master @ `b14293b`;
  `nsts-sim-gpc` on `yagpc2-discretes` @ `cb6b28d`. The user asks for a
  repo check first thing each session — Don is committing frequently and
  **read the commit comments**, they are substantive.

## 7. STANDING RULES (from CLAUDE.md / the user)

- **Never edit an existing `*.md`** without the phrase "Full Documentation
  Sync". Appending to `CLAUDE_LOG.md` and writing `HANDOFF*`/`RELAY-*` is
  always allowed.
- **Commit finished, verified work** without being asked. Don't commit
  unverified work.
- **Show outward-facing text before it is sent** — PR/issue prose gets
  reviewed first.
- **Use ASM101S.py / HALSFC, never `asm101` or `halsc`** for builds.
  `asm101` is a reimplementation; `halsc` is a wrapper whose API differs,
  so neither can underpin user-facing instructions.
- `~/workspace/PFS` and `~/donschmidt/*` are other people's repos: pull
  before changing, prefer read-only, say what was touched. (Everything on
  local branches in nsts-sdl-dps is ours.)
- Measure, don't recall. Re-run rather than quoting an old number.
