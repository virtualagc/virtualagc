#!/bin/bash
# test_scheduler.sh — end-to-end regression test for HAL/S TASK/
# SCHEDULE/WAIT support (see src/schedule.h/.c, wired into src/halucp.c's
# SVC dispatch). Like test_debugger.sh, this has no JS reference to diff
# against (the scheduler is a new, yaGPC2-only subsystem -- see
# problems.md 2.7/7) -- instead each case runs a real HAL/S-compiled
# fixture and diffs against a golden output captured from an independent
# oracle: yaHALMAT2 running that same fixture's own HALSFC-compiled
# HALMAT (via `HALSFC fixture.hal ...; yaHALMAT2 halmat.bin` -- NOTE:
# rely on yaHALMAT2's own --litfile/--memory auto-discovery, don't pass
# them explicitly pointing both at the same file, which silently
# corrupts CHARACTER-literal output while still exiting 0) — confirmed
# byte-identical to yaGPC2's own output for the same source, which is
# what this test guards against regressing.
set -u
cd "$(dirname "$0")"

YAGPC2="../yaGPC2"

fail=0

# --time-scale: yaGPC2's standalone CLI now paces SCHEDULE/WAIT against
# real wall-clock time by default (--time-scale 1.0, matching
# yaHALMAT2's own default -- see run.c's batchrunner_pace()), so a
# program with any real virtual-time span would otherwise make this
# test take that long every time `make test` runs, once per --pacing
# mode below. A large factor collapses that to milliseconds without
# changing any tick arithmetic or program output at all (confirmed:
# same golden files this is diffed against, captured with yaHALMAT2
# similarly sped up via its own --time-scale).
run_case() {
    label="$1"; pacing="$2"; fcm="$3"; sym="$4"; golden="$5"

    act_out=$(mktemp)
    act_err=$(mktemp)

    "$YAGPC2" --interactive --no-trace --no-verbose --symbols "$sym" --line-width 240 --max-steps 200000 \
        --time-scale 1000000 --pacing "$pacing" "$fcm" >"$act_out" 2>"$act_err"
    act_code=$?

    ok=1

    if ! diff -u "$golden" "$act_out"; then
        echo "FAIL [scheduler/$label]: stdout differs from $golden"
        ok=0
    fi

    if [ -s "$act_err" ]; then
        echo "FAIL [scheduler/$label]: unexpected stderr output"
        cat "$act_err"
        ok=0
    fi

    if [ "$act_code" != 0 ]; then
        echo "FAIL [scheduler/$label]: exit code $act_code (expected 0)"
        ok=0
    fi

    if [ "$ok" = 1 ]; then
        echo "PASS [scheduler/$label]"
    else
        fail=1
    fi

    rm -f "$act_out" "$act_err"
}

# --pacing=burst (default polling design) and --pacing=signal (POSIX
# timer/sigsuspend-driven alternative, run.c's batchrunner_pace_signal())
# -- both implement the same pacing contract and must produce byte-
# identical program output, only wall-clock jitter/precision differs
# (see run.c's own header comment), so both diff against the same
# golden file.
run_case "countup/burst"  "burst"  "fixtures/countup.fcm" "fixtures/countup-lnk101.json" "fixtures/countup_golden.txt"
run_case "countup/signal" "signal" "fixtures/countup.fcm" "fixtures/countup-lnk101.json" "fixtures/countup_golden.txt"

# WAIT UNTIL (SVC #7, sched_handle_wait_until_svc) -- a real compiled
# program (WRITE, WAIT UNTIL <absolute time>, WRITE), no TASK/SCHEDULE
# involved at all, just the primal process suspending itself.
run_case "waituntil/burst"  "burst"  "fixtures/waituntil.fcm" "fixtures/waituntil-lnk101.json" "fixtures/waituntil_golden.txt"
run_case "waituntil/signal" "signal" "fixtures/waituntil.fcm" "fixtures/waituntil-lnk101.json" "fixtures/waituntil_golden.txt"

# TERMINATE, named-target form (SVC #3, sched_handle_terminate_named_svc)
# -- a REPEAT EVERY task TERMINATEd by the primal mid-stream; asserts it
# actually stops repeating (4 firings, not 5+), unlike merely reaching
# its own CLOSE (which would re-arm it).
run_case "terminate/burst"  "burst"  "fixtures/terminate.fcm" "fixtures/terminate-lnk101.json" "fixtures/terminate_golden.txt"
run_case "terminate/signal" "signal" "fixtures/terminate.fcm" "fixtures/terminate-lnk101.json" "fixtures/terminate_golden.txt"

# TERMINATE, bare/self form (SVC #2, sched_handle_terminate_self_svc) --
# a task that TERMINATEs itself; asserts execution actually stops right
# there (the pre-fix bug: an unhandled SVC just fell through and kept
# executing the task's own remaining statements).
run_case "selfterminate/burst"  "burst"  "fixtures/selfterminate.fcm" "fixtures/selfterminate-lnk101.json" "fixtures/selfterminate_golden.txt"
run_case "selfterminate/signal" "signal" "fixtures/selfterminate.fcm" "fixtures/selfterminate-lnk101.json" "fixtures/selfterminate_golden.txt"

# PRIO() built-in (SVC 0x0317) -- confirmed deterministic/comparable
# (unlike RUNTIME(), see problems.md 7.4/7.5: two independently-invented
# timing models can't be expected to agree on an elapsed-time *value*,
# but PRIO() returns an exact INTEGER with no timing dependency at all).
run_case "prio/burst"  "burst"  "fixtures/prio.fcm" "fixtures/prio-lnk101.json" "fixtures/prio_golden.txt"
run_case "prio/signal" "signal" "fixtures/prio.fcm" "fixtures/prio-lnk101.json" "fixtures/prio_golden.txt"

# Process name as Boolean (USA003087 13.5) -- a task's own PDE+0 bit 0,
# read directly by compiled code (no SVC at all). Checks both ACTIVE
# (right after SCHEDULE) and INACTIVE (right after TERMINATE). No
# yaHALMAT2 cross-check exists for this fixture: yaHALMAT2 itself
# errors out on this construct ("SYT index 2 is a whole ARRAY/VECTOR/
# MATRIX referenced outside an arrayed-paragraph replay") -- a real
# yaHALMAT2 gap, not a yaGPC2 one; see problems.md.
run_case "processboolean/burst"  "burst"  "fixtures/processboolean.fcm" "fixtures/processboolean-lnk101.json" "fixtures/processboolean_golden.txt"
run_case "processboolean/signal" "signal" "fixtures/processboolean.fcm" "fixtures/processboolean-lnk101.json" "fixtures/processboolean_golden.txt"

exit $fail
