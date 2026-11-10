# State-isolation audit (milestone 4)

Scope: every file linked into an ODYSSEY computer: `agc_engine.c`,
`agc_engine_init.c`, `rfopen.c`. Method: the authoritative inventory of writable
data came from the compiled objects, not from grep:

```
nm -S --size-sort build/up_agc_engine.o build/up_agc_engine_init.o build/up_rfopen.o
```
filtering to `b/B/d/D` symbols (this also catches function-local statics, which
show up as `name.N`). Each symbol was then traced to its readers and writers.

AGENTS.md's starting list was **accurate but not complete**. The real picture:

## 1. Per-computer state: moved into `agc_t.Periph`  (isolated)

These evolve while a computer runs and describe that computer's simulated
IMU/CDU/gyro hardware, so sharing them corrupted any second computer.

| Was | Used for |
|---|---|
| `CduFifos[3]`, `CduChecker` | fake FIFOs on the CDU X/Y/Z input counters (regs 032-034) |
| `CountCDUX/Y/Z` (function-local statics in `BurstOutput`) | coarse-align drive remainder per axis |
| `GyroCount`, `OldChannel14`, `GyroTimer` | gyro torque pulse generator; **`GyroTimer` advances every machine cycle**, so every computer perturbed every other one on every step |
| `ImuCduCount`, `ImuChannel14` | IMU CDU burst timing |

Evidence the hazard was real: on the pristine engine, two interleaved instances
fail to reproduce their solo-run fingerprints (and one instance's IMU-CDU burst
count collapsed from 20 to 2). On the modified engine they match exactly.

## 2. Process-wide immutable: justified, left shared

| Symbol | Why it is not shared mutable state |
|---|---|
| `TrapPIPA` | Debug-print guard. Its only setters are commented out upstream; the one live write was `= 0`. Now `static const int = 0`. |
| `DownlinkListZero`, `MAX_CLIENTS`, `SocketInterlaceReload`, `Swidth`, `Sheight`, `SingleStepCounter` | Initialised data used by CLI/debugger/telemetry code only; not touched by `agc_engine()`. |
| `InstallationPath`, `DefaultInstallationPath` (`rfopen.c`) | Path lookup config, set once at startup. Not on the execution path. |
| `ShowAlarms`, `InhibitAlarms`, `DebugDsky` | Read inside `agc_engine()`; written only by `agc_simulator.c` option parsing, never by the engine. Default 0. Constant in an ODYSSEY process because ODYSSEY never calls the option parser. |
| `DebuggerInterruptMasks[11]` | **On the interrupt hot path**, so it matters. Initialised all-1 (all interrupts enabled) and written only by `agc_debugger.c`. ODYSSEY has no debugger, so it is effectively constant. It is *not* declared `const`: attaching a debugger to one computer would change interrupt behaviour for all of them. |
| `initializeSunburst37` | Config read during `agc_engine_init()`; written by CLI code. Default 0. |

## 3. Optional subsystem state: must stay OFF in a multi-computer process

These are mutable and shared, and they are safe only because they are inert by
default. **Do not enable them while more than one computer exists.**

| Symbol(s) | Subsystem | What enabling would do |
|---|---|---|
| `CoverageCounts` flag; `ErasableReadCounts`, `ErasableWriteCounts`, `ErasableInstructionCounts`, `FixedAccessCounts`, `IoReadCounts`, `IoWriteCounts` | structural-coverage counters | Engine increments shared arrays whenever `CoverageCounts != 0` (5 sites). Counts from all computers would merge. Default 0. |
| `CduLog` | CDU debug log (`FILE *`) | Engine `fprintf`s to it when non-NULL. Default NULL. |
| `DedaMonitor`, `DedaWhen`, `DedaAddress`, `DedaQuiet`, `DebugDeda` | `--debug-deda` helper | `DedaWhen` is the one global the engine *writes at runtime*, but only under `if (DedaMonitor ...)`; default off. |
| `DebugMode`, `DebugRules`, `NumDebugRules`, `Backtrace*` | interactive debugger / backtraces | `DebugMode` is only *read*, in `MakeCoreDump()` (`agc_engine_init.c`), which ODYSSEY never calls; the rest have no references in the linked engine files. `BacktraceAdd` is stubbed to a no-op in `odyssey_io.c`. |
| `CmOrLm`, `Sundance`, `LastRhc*`, `DownlinkList*`, `ProcessDownlinkList`, `Sbuffer`, `DownlinkListBuffer` | downlink telemetry decoding | Used only by `DecodeDigitalDownlink.c` / `SocketAPI.c` / CLI. Not linked into ODYSSEY. |
| `Clients`, `ServerSockets`, `NumServers`, `DefaultClients`, `DefaultSockets` | socket server | Used only by `SocketAPI.c`. Not linked into ODYSSEY. |

Note that many of these are *defined* in `agc_engine.c` only because
`agc_engine.h` uses an `AGC_ENGINE_C` define-the-globals trick, not because the
engine uses them. They appear in `nm` output for that reason.

## 4. Not a hazard

* `agc_t` itself is fully per-instance (memory, registers, counters, interrupt
  state, `agc_clientdata`).
* ODYSSEY's own state (`odyssey_computer_t`: queues, counters, sequence numbers)
  is per-instance by construction and routed by `State->agc_clientdata`.

## Result

All **mutable shared state that evolves during execution** is now per-instance
(section 1) or provably immutable (section 2). The remaining mutable globals
(section 3) are optional subsystems that are off by default and are documented
as must-stay-off. This satisfies the AGENTS.md acceptance test *"All mutable
engine state is either per-instance or explicitly justified as process-wide"*,
**with the stated section-3 restriction.**

## How to re-run the audit

```
make -C yaAGC/odyssey            # builds the upstream objects into build/
nm -S --size-sort yaAGC/odyssey/build/up_agc_engine.o | awk '$3 ~ /^[bBdD]$/'
```
Any new writable symbol that is not in this document is a new hazard.

## Tests (see `tests/run_isolation_tests.sh`)

* differential: pristine vs modified, bit-identical (spin ROM and Comanche055)
* interference: interleaved A/B at chunk sizes 1, 7, 1000 each equal their solo runs
* reset: re-initialising A mid-run leaves B untouched; A equals a fresh run
* control: the pristine engine **fails** the interference and reset checks
* unit: `Periph` is independent, cleared by reset, untouched in the neighbour
