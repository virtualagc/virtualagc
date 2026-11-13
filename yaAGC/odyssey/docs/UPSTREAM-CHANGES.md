# Upstream changes made for ODYSSEY-AGC

AGENTS.md requires every changed upstream file to be documented. As of
milestone 4 **exactly three upstream files differ from the VirtualAGC checkout**
(`git diff --stat`: 3 files, 99 insertions, 70 deletions). Everything else under
`yaAGC/odyssey/` is new.

| File | Change |
|---|---|
| `yaAGC/agc_engine.h` | Added `agc_periph_t` and moved the `CduFifo_t` type plus `MAX_CDU_FIFO_ENTRIES` / `NUM_CDU_FIFOS` here from `agc_engine.c`. Added member `agc_periph_t Periph;` to `agc_t`, placed just before `agc_clientdata`. |
| `yaAGC/agc_engine.c` | Removed 10 mutable `static` variables (7 file-scope, plus the 3 function-local statics `CountCDUX/Y/Z` in `BurstOutput()`); every use now reads/writes `State->Periph.<same name>`. Made `TrapPIPA` `static const int`. Removed the now-moved typedef/defines. No logic changes. |
| `yaAGC/agc_engine_init.c` | `agc_engine_init()` now does `memset(&State->Periph, 0, sizeof State->Periph)` next to the other CPU-state resets. |

## Exactly what moved (all type- and meaning-preserving)

Into `agc_t.Periph` (per-computer simulated IMU/CDU/gyro hardware):
`CduFifos[NUM_CDU_FIFOS]`, `CduChecker`, `CountCDUX`, `CountCDUY`, `CountCDUZ`,
`GyroCount`, `OldChannel14`, `GyroTimer`, `ImuCduCount`, `ImuChannel14`.

`TrapPIPA` did **not** move: it is a debug-print guard whose only setters are
commented out in the upstream source, so it is always 0. It is now `const`,
which makes it provably immutable and makes any future write a compile error.
Moving it would have required changing the signatures of the public
`CounterPINC()` / `CounterMINC()`, which take no `State`.

## One deliberate behaviour difference

The old statics were zero at process start and **never reset**. They are now
zeroed by `agc_engine_init()`, so re-initialising a computer resets its
simulated peripherals. For a freshly started process this is identical to before.
It only differs when `agc_engine_init()` is called again on the same `agc_t`
(a reset), where the old behaviour left stale gyro/CDU state behind. The
differential tests do not cover a re-init of the *pristine* engine, because the
pristine engine cannot reset this state.

## Evidence that behaviour is otherwise unchanged

`tests/run_isolation_tests.sh` builds one harness against both the frozen
pristine engine (`tests/baseline/`) and the modified engine, and compares a
fingerprint of every `ChannelOutput` call plus final memory/channel state after
300,000 cycles of scripted gyro, IMU-CDU, CDU-FIFO and PIPA activity, on both a
spin ROM and the real Comanche055 ROM. They are bit-identical.

The dead `#ifdef GYRO_TIMING_SIMULATED` branch was converted too; it is not run
by the tests but was compile-checked with `-DGYRO_TIMING_SIMULATED`.

The full upstream CMake build (`cmake --build`, all targets available without
SDL2/wxWidgets) succeeds with the modified files.

## Link-time interposition (no upstream edit needed)

`agc_engine.c` needs these symbols at link time; `odyssey/odyssey_io.c` supplies
them, **instead of** `NullAPI.c` / `SocketAPI.c`:
`ChannelOutput`, `ChannelInput`, `ChannelRoutine`, `ShiftToDeda`,
`RequestRadarData`, `BacktraceAdd`, `UnblockSocket`.

`agc_engine_init()` calls `UnblockSocket(fileno(stdin))`, which is a
process-level side effect. ODYSSEY defines `UnblockSocket` as a no-op so the host
never touches stdin once per AGC. That needed no change to `agc_engine_init.c`.
**`odyssey_io.c` must never be linked into the normal `yaAGC` target.**

## The frozen baseline

`tests/baseline/` holds verbatim copies of the three files as they were before
any ODYSSEY change, with SHA-256 sums in `SHA256SUMS`. The isolation test
verifies the sums so the reference cannot drift. Do not edit these files. If
upstream is ever re-synced, regenerate them from the new upstream commit and the
sums, and re-run the tests.

## Known pre-existing upstream issue (not introduced here, not fixed here)

Running the isolation suite under UBSan reports
`index -1 out of bounds for type 'int16_t [256]'` in the `DAS` handler
(`c(Address10 - 1)` when `Address10 == 0`, i.e. `DAS A` / `DDOUBL`). It occurs at
the identical code in `tests/baseline/agc_engine.c`, so it predates ODYSSEY. It
is harmless in practice and AGENTS.md says to preserve instruction behaviour, so
it was left alone. ODYSSEY's own synthesis ROMs do not execute `DAS A`.
