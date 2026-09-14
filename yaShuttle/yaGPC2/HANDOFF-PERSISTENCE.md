# HANDOFF: persistent simulation state (save and resume without re-IPL)

STATUS: PLAN ONLY, NOT STARTED.  The project owner wants to think it over
before any implementation begins (2026-09-14).  Do not start building from this
file without their go-ahead; raise changes to the plan with them first.

## Why

Bringing up a multi-GPC simulation with simulatePASS.py takes many minutes of
panel and keyboard steps per computer.  The goal is to save the whole
simulation on an orderly shutdown (and on request) and resume it later exactly
where it stopped: GPC memory and CPU/IOP state, the shared hardware models,
the MEDS displays, the panel switches, and the window layout.

A worked example of the cost (2026-09-14).  The owner brought up a 4-GPC,
2-CRT simulation by hand through every IPL and the NBAT, recording the screen
as they went.  Mid-way through the NBAT they backed up one step to re-check an
entry, and the entries after that repeated the previous line's value: the
target set went in as `ITEM 3+1`, `4+1`, `5+1` (GPC1 alone, instead of
`+2 +3 +4`) and CRT 2 as `ITEM 13+1`, while strings and MM2 were still given
to GPCs 2-4.  Shortly after `OPS 2 0 1 PRO`, GPCs 1, 3 and 4 voted GPC2 out
(CAM 22, 12, 32, 42) and it stayed failed.  Nothing in the simulator was at
fault; the keyboard log and the video agree.  The owner's point: instructions
live outside the simulated keyboard and display, so every glance between them
is a chance to slip, and adding clarification past a point makes slips MORE
likely.  Recovery meant re-IPLing a computer or starting all over.  With
persistence, a pinned save taken just before the NBAT turns such a slip into a
restore of a few seconds.

## Decisions already made with the owner

- **Format versioning, not build versioning.**  Each save carries a
  persistence-FORMAT version.  Any build of yaGPC2 / MEDS2 / panelO6 that knows
  that format accepts it; rebuilding a program must never invalidate saves.  A
  converter upgrades an older format to a newer one.
- **Autosave is OFF by default** (`--autosave MIN` to enable).
- **A save must not be noticeable.**  GPC threads copy their state into
  in-memory buffers at a quiet instant (sub-millisecond for ~1.5 MB per GPC);
  a dedicated writer thread compresses (zlib) and writes the file while the
  GPCs keep running.  (In-process buffers are enough; OS shared memory only
  matters if a separate process does the writing.)
- **Time continues from the saved GMT.**  Nothing is advanced to real time on
  restore; only host-clock anchors are rebuilt.  To move GMT to real time, use
  SPEC 2 (TIME) as the crew would.
- **Retention is capped.**  Newest save plus 3 older by default
  (`--keep-saves N`, minimum 1); exit, manual and autosave saves share that
  cap.  The oldest is deleted only after a new save is fully committed.
- **Pinned saves** (`s NAME` in the simulatePASS terminal) are exempt from
  rotation; listed by `--list-saves`, resumed with `--resume NAME`, removed only
  with `--forget`.

## The plan

### Naming and matching
- `simulatePASS.py --name NAME`; without it a name is derived from the
  configuration (e.g. `g1-2_c2`).  Saves in `~/.local/state/simulatePASS/<name>/`.
- Manifest fingerprint that must match to resume: the GPC set, the CRT count,
  the tape's SHA-256.  Port base, sizes and titles do not matter.  A mismatch is
  refused with a message saying what differs.
- `--cold` starts fresh and leaves saves alone; `--list-saves`; `--forget NAME`.

### When saves happen
- Orderly exit (Enter, Ctrl-C, end of `--duration`).
- Manual: `s` + Enter in the simulatePASS terminal, or SIGUSR1.
- Periodic: `--autosave MIN` only.
- Pinned: `s NAME`.

### Taking a save
1. simulatePASS sends "save N" on a control port.
2. At the next instant with no GPC mid-transaction with an external peer (a
   display poll, a mass-memory transfer), every GPC thread pauses together at
   the barrier and copies its state into buffers.
3. GPCs resume; the writer thread compresses and writes.
4. MEDS2 and panelO6 snapshot their own (small) state in their own processes on
   the same request.  They may be a few ms newer than the GPC copy; PASS's next
   display refresh covers that.
5. simulatePASS commits the manifest when every part has reported, then
   rotates old generations.  Every file is written under a temporary name and
   renamed.

### What is saved
- **yaGPC2 per GPC** (explicit big-endian format, NOT raw struct dumps):
  both general register sets and FP registers, DSEs, PSW, BSR/DSR, main store
  plus protection bits, interval timers and their deferred flags, pending
  interrupts and codes, IOP registers and local store (which holds the BCE
  PCs), per-BCE state including MIA latches, `rxNextUs`, `latchCmdSync`, delay
  fields, `busFreeUs`, the DMA queue (BCE pointers saved as indices), watchdog,
  `iopNextPassUs`, HalUCP/scheduler, `elapsedTimeUs`, `writtenOffUs`,
  `prevMode`, `cfailLatched`.
- **yaGPC2 shared hardware (Vehicle):** mass memory position/status/queues and
  listener taps, plus ONLY the blocks PASS has changed (e.g. an SM checkpoint)
  together with the tape hash -- the original .mmv is never modified; MTU reply
  queues; ICC queues; DEU model; barrier offsets (`barOffsetUs`), `clockUs`,
  DK claimant and bus owners; discrete register values.
- **Rebuilt, not saved:** pointers, callbacks, sockets, threads, mutexes.
  **Re-initialised on restore:** every host wall-clock anchor -- RTPacer,
  `pacingRefWall*`, discretes `lastSeen`/attentive clock, bcenet framer
  `lastPeerWall`/`heldSinceCmd`, the transport token bucket.
- **MEDS2 per IDP** (read through BusPump.call, since the IDP belongs to that
  thread): DEUUnit `mem` (8192 words), `ipled`, `iplRunning`, `keyQueue`, `spl`,
  `majorFunc`, `msgResetPending`, `ackPending`, `iplError`, `selfTest`,
  `swStatus`, `timeWords`/`time`, `medsDK`, `deuId`; IDP `powered`, `kybdSel`.
  **Per MDU:** `curDisplay`, `currentMenuName`, `cmdPort`, `flightCritBus`,
  `portReconfigModeAuto`, `modeNegView`, `majorFunc`, `idpPower`.  The picture
  is rebuilt by replaying the IDP's display memory as one full FILL (as
  `IDP._clearMDUs` already sends) plus a CLOCK message.
- **panelO6:** every switch (GPC power/output/mode, IPL source, BFC CRT
  display/select, BFC disengage, IDP/CRT power and MAJ FUNC 1-4, IDP/CRT SEL)
  and the BFC engage latches -- applied BEFORE the constructor's first publish,
  or it announces MODE HALT and IDP POWER OFF and wrecks the restored machines.
- **cam.py, stsKeyboard.py:** window geometry only (the CAM REQUESTs its
  registers from the bus at start-up).
- **Every window:** position and size reported at each save (Tk
  `winfo_geometry`, Qt `frameGeometry`) and passed back on restore
  (`--geometry`, `NSTS_MDU_POS`), overriding the computed layout.

### Restoring
1. Start MEDS2 and panelO6 from their saved state.
2. Start yaGPC2 paused with its state applied.
3. Wait until the panel's discretes and the IDP heartbeats are heard.
4. Release all GPCs together.

### Stages (each verified before the next)
0. Audit the ~200 function-level statics in ap101.c, iop.c, cpu.c, run.c (most
   are trace caches; some may be machine state, e.g. iop.c `xmitWords`).
   Complete one-GPC save/restore.  Criterion: a restored GPC matches a
   continuous run by register, memory and IOP state.
1. Several GPCs: the pause step, writer thread with zlib, shared hardware.
   Criterion: a headless two-GPC set restored in OPS 2 runs 30 minutes with no
   fail votes, and saving adds no measurable delay.
2. MEDS2 and panelO6 state and the restore order.  Criterion: a networked
   restore brings back the same displays and switches, no POLL FAIL or I/O
   errors.
3. simulatePASS controls: names, fingerprint, `--cold`, manual/auto/pinned
   saves, retention, geometry.
4. Robustness: kill mid-save, mismatched tape, old format through the
   converter, resume after days.

## What the surveys found (2026-09-14), for whoever implements

- **Existing partial facility:** `--dump-state` / `--state`
  (ageharness.c:497-704 load, 729-886 dump; opts.c:24; run.c:1617-1690 triggers,
  `YAGPC_DUMPSTATE_AT`/`_BUSY`).  JSON plus `.protect.bin`; one GPC; only the
  active register set, FP, timers, pending interrupts, IOP registers, local
  store and some BCE fields.  It deliberately does NOT restore `elapsedTimeUs`
  (ageharness.c:778-785) because it breaks the pacer; BCE deadlines are rebased
  instead.  `YAGPC_SNAPSHOT` / `YAGPC_LOADBIN` dump/load raw main store
  (ap101.c:274-380).  .fcm images load at address 0 via `membus_load16`
  (ageharness.c:220-240).
- **No stop-the-world point today.**  `vehicle_barrier_wait` (vehicle.c:189-262)
  runs per instruction (run.c:2021) and in the idle loop (run.c:2150);
  publishing is unlocked.  Machines held in HALT leave the barrier (run.c:1590)
  and need their own acknowledge.  Device models are serialised by `busLock`
  (vehicle.c:142-164).  SIGINT sets `g_sigint_received` (run.c:2671, 2735-2740);
  main joins threads (main.c:137-150) -- the save-on-exit hook.
- **Time:** pacer "ahead" = `(elapsedTimeUs - simStartUs)/factor - (monotonic -
  wallStartSeconds)` (rtpacer.c:118-122); deficits are repaid, never dropped
  (rtpacer.c:224-231).  MTU time of day = `epochSec + (clockUs +
  offsetUs)/1e6` (mtumodel.c:128) with `offsetUs = writtenOffUs` (run.c:293,
  415-418).  HAL DATE/CLOCKTIME use the CPU anchor plus elapsed time with no
  offset (cpu.h:196-211) -- relevant if time is ever adjusted on restore.
- **Redundant set:** barrier tolerance (vehicle.c:22), `barrier_join` offsets
  (vehicle.c:85-104), a hold over 0.25 s is abandoned (vehicle.c:244).
  Inter-GPC discrete levels go stale after 1.5 s (discretes.h:107) on a
  wall-based attentive clock (discretes.c:552-556).  Past failures from stale
  state: ledger #93 (phantom IPL), #110 (steady levels aging out), #131 and
  #139 (stale queued words broke the set), #86/#87 (re-IPL from a running
  machine), #144 (display replies stalled, set broke).
- **External peers:** framer peer-hold state is wall-based
  (bcenet_framer.c:72-76, 417, `PEER_LIVE_SECONDS`).  A command in flight to a
  display at save time is lost; hence saving only at a quiet instant.
- **Mass memory:** writes go to in-memory blocks only (`write_block_done`,
  mmumodel.c:497-511), honouring the volume's write-protect flag; the .mmv is
  opened read-only (mmumodel.c:671).  In 43 logged runs `blocksWritten` was 0.
  PASS writes on crew request: SM checkpoint (SPEC 60 item 18; DPS Workbook
  USA005350 Rev B 3.1.14), IMU calibration parameters (GNC OPS 9 SPEC 104 item
  28; DPS Dictionary).
- **MEDS2:** no SIGTERM handler; code after `app.exec()` runs on Ctrl+Q or last
  window close; `app.aboutToQuit` is the hook.  `LocalStorage` holds only
  reference-overlay placements; `NSTS_EXEC` runs Python 2 s after start-up;
  `NSTS_SIM_CONFIG` deep-merges config (window x/y, init display/menu).
- **panelO6:** state fields at panelO6.py ~386-404; the constructor publishes
  defaults before `mainloop` (~2055-2074); `--script` lacks GPC POWER and OUTPUT
  BACKUP commands.
- **Tk programs:** no signal handlers; code after `root.mainloop()` runs on
  `root.quit`.  A handler = `signal.signal` plus a `root.after` poll.
- **simulatePASS:** children run in their own sessions (Launcher.start ~240);
  `stop()` (~249) sends SIGINT to yaGPC2 (10 s), then SIGTERM to process groups
  in reverse order, then SIGKILL after 5 s.  Save requests must happen before
  the SIGTERM step.

## Alternatives considered and rejected

- OS process checkpointing (CRIU): Linux-only; breaks on GUIs and sockets; the
  project must also run on macOS and Windows.
- Record and replay of inputs: not deterministic (wall-clock pacing, threads).
- Conditioning saves on yaGPC2's build: rejected by the owner (rebuilds would
  destroy saves irrecoverably).
- A scripted fast start-up (`--autostart OPS2` generating panel/keys scripts)
  was offered as a cheap interim; not chosen yet.

## Questions still open for the owner

- Where saves live on macOS and Windows (platform state directories).
- Whether two simulations may run under the same name at once (a lock file).
- How long a save may wait for a quiet instant before giving up and reporting.
- Whether the converter is a separate tool or built into each program.
