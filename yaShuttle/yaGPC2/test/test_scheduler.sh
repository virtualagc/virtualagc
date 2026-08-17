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

act_out=$(mktemp)
act_err=$(mktemp)

"$YAGPC2" --interactive --no-trace --no-verbose --symbols "$SYM" --line-width 240 --max-steps 200000 "$FCM" >"$act_out" 2>"$act_err"
act_code=$?

ok=1

if ! diff -u "$GOLDEN" "$act_out"; then
    echo "FAIL [scheduler/countup]: stdout differs from $GOLDEN"
    ok=0
fi

if [ -s "$act_err" ]; then
    echo "FAIL [scheduler/countup]: unexpected stderr output"
    cat "$act_err"
    ok=0
fi

if [ "$act_code" != 0 ]; then
    echo "FAIL [scheduler/countup]: exit code $act_code (expected 0)"
    ok=0
fi

if [ "$ok" = 1 ]; then
    echo "PASS [scheduler/countup]"
else
    fail=1
fi

rm -f "$act_out" "$act_err"

exit $fail
