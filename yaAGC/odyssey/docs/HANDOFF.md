# ODYSSEY-AGC handoff (Claude -> Codex)

## State
Milestones 1-4 of AGENTS.md are done, each with test evidence. Milestones 5-8 are NOT started.

| M | Status | Evidence |
|---|---|---|
| 1 engine runs embedded | done | upstream demo runs clean, also under ASan/UBSan |
| 2 AGC writes audio words (SEQTEST) | done | exactly 8 expected words, 0 alarm restarts |
| 3 AGC-side synthesis (PHASE-*) | done | AGC output matches independent Python oracle (~145k samples); SILENT ROM yields 0 samples; deterministic across slice sizes; queue overflow never blocks |
| 4 state isolation | done | differential vs frozen pristine engine bit-identical; interleaved A/B equal solo runs; reset isolation; controls FAIL on pristine engine |

## Build / test
```
export YAYUL=/path/to/yaYUL        # from a standard cmake build of this repo
make -C yaAGC/odyssey test         # unit + synthesis + isolation tests
make -C yaAGC/odyssey asan
```
The standard VirtualAGC cmake build was verified to still pass.

## Read first
* `UPSTREAM-CHANGES.md` - the only 3 upstream files touched, and why
* `STATE-ISOLATION-AUDIT.md` - what is per-instance vs process-wide; section 3 globals MUST stay off with >1 computer
* `CHANNEL-VERIFICATION.md` - ODYSSEY channel map 0300-0325 (extension, not Apollo)

## AGC programming gotchas (learned the hard way)
* Engine models watchdogs: TC Trap (~5 ms; loops need both a TC/TCF and a non-TC instruction), Night Watchman (touch address 067 ~every 1.28 s), Rupt Lock. A trip does GOJAM restart and writes ch 077; counted as `alarm_restarts`. Use `flight/common/KEEPALIVE.agc`.
* TS overflow-correction: phase accumulators wrap mod 2^14 (unipolar sawtooth).
* AGC words are one's complement; +0=000000, -0=077777. PCM16 = value*2.
* yaYUL `--force` writes a .bin even on errors; `tools/build_roms.sh` parses fatal-error counts.
* Numbers in address fields are octal. `CCS A` needs `A EQUALS 0`.
* Useful refs: https://www.ibiblio.org/apollo/assembly_language_manual.html and https://github.com/NeilFraser/AGC-code

## Known issues / caveats
* Pre-existing upstream UBSan finding in the `DAS` handler (index -1); identical in baseline; left unfixed.
* Audio ring is single-thread only; needs atomics for M8.
* Channel 0301 semantics undefined; READ of 0320-0325 unverified.
* `tests/baseline/` is a frozen copy of pristine engine files (SHA256SUMS); do not edit.

## Next steps
1. M5: scheduler stepping two `odyssey_computer_t` (CMC, LGC) with deterministic interleave; per-instance capture; test cross-talk.
2. M6: virtual bus on channels 0310-0325 (complete-message delivery only, overflow never blocks).
3. M7: AGC-side synthesis altered by received bus messages (host must not synthesize).
4. M8: real-time audio backend (thread-safe queue, underrun metrics) with measured, not assumed, rates.
