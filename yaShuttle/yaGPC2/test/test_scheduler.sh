#!/bin/bash
# test_scheduler.sh — end-to-end regression test for HAL/S TASK/
# SCHEDULE/WAIT support (see src/schedule.h/.c, wired into src/halucp.c's
# SVC dispatch). Like test_debugger.sh, this has no JS reference to diff
# against (the scheduler is a new, yaGPC2-only subsystem -- see
# problems.md 2.7) -- instead it runs a real HAL/S-compiled fixture and
# diffs against a golden output captured from an independent oracle:
# yaHALMAT2 running fixtures/countup.hal's own HALSFC-compiled HALMAT
# (via `HALSFC countup.hal ... ; yaHALMAT2 halmat.bin`) — confirmed
# byte-identical to yaGPC2's own output for the same source, which is
# what this test guards against regressing.
set -u
cd "$(dirname "$0")"

YAGPC2="../yaGPC2"
FCM="fixtures/countup.fcm"
SYM="fixtures/countup-lnk101.json"
GOLDEN="fixtures/countup_golden.txt"

fail=0

# --time-scale: yaGPC2's standalone CLI now paces SCHEDULE/WAIT against
# real wall-clock time by default (--time-scale 1.0, matching
# yaHALMAT2's own default -- see run.c's batchrunner_pace()), so this
# program's genuine ~199.5 virtual seconds would otherwise make this
# test take ~199.5 real seconds every time `make test` runs, once per
# --pacing mode below. A large factor collapses that to milliseconds
# without changing any tick arithmetic or program output at all
# (confirmed: same golden file this was already diffed against, captured
# with yaHALMAT2 similarly sped up via its own --time-scale).
run_case() {
    label="$1"; pacing="$2"

    act_out=$(mktemp)
    act_err=$(mktemp)

    "$YAGPC2" --interactive --no-trace --no-verbose --symbols "$SYM" --line-width 240 --max-steps 200000 \
        --time-scale 1000000 --pacing "$pacing" "$FCM" >"$act_out" 2>"$act_err"
    act_code=$?

    ok=1

    if ! diff -u "$GOLDEN" "$act_out"; then
        echo "FAIL [scheduler/$label]: stdout differs from $GOLDEN"
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
run_case "countup/burst" "burst"
run_case "countup/signal" "signal"

exit $fail
