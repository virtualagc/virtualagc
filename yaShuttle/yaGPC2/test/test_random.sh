#!/bin/bash
# test_random.sh — regression test for RANDOM()/RANDOMG() (see
# hal-runtime-features.db rows 98/99, problems.md 7.20). Unlike most of
# this codebase's built-ins, these compile to a call into a real linked
# RUNASM/RANDOM.obj library routine with no SVC of its own at all (the
# same category as SQRT/COS/etc.) — a deterministic RANDU-family linear
# congruential generator seeded from a fixed compiled-in constant, not
# wall-clock/hardware entropy (problems.md 2.6, established for gpc/
# yaGPC and re-confirmed here to hold for yaGPC2 unchanged). No TASK/
# SCHEDULE/WAIT involved in any of these fixtures, so unlike
# test_scheduler.sh there is no --time-scale/--pacing matrix to run.
set -u
cd "$(dirname "$0")"

YAGPC2="../yaGPC2"

fail=0

run_case() {
    label="$1"; fcm="$2"; sym="$3"; golden="$4"

    act_out=$(mktemp)
    act_err=$(mktemp)

    "$YAGPC2" --interactive --no-trace --no-verbose --symbols "$sym" --line-width 240 --max-steps 500000 "$fcm" >"$act_out" 2>"$act_err"
    act_code=$?

    ok=1

    if ! diff -u "$golden" "$act_out"; then
        echo "FAIL [random/$label]: stdout differs from $golden"
        ok=0
    fi

    if [ -s "$act_err" ]; then
        echo "FAIL [random/$label]: unexpected stderr output"
        cat "$act_err"
        ok=0
    fi

    if [ "$act_code" != 0 ]; then
        echo "FAIL [random/$label]: exit code $act_code (expected 0)"
        ok=0
    fi

    if [ "$ok" = 1 ]; then
        echo "PASS [random/$label]"
    else
        fail=1
    fi

    rm -f "$act_out" "$act_err"
}

# randomsequence.hal — a minimal, fast, dedicated fixture: 3 RANDOM()
# calls then 2 RANDOMG() calls, nothing else, isolating the algorithm
# itself from any other floating-point register traffic (see problems.md
# 2.6's own "F1-chaining disrupted by other float ops" caveat — real
# only for yaHALMAT2's own simplified reference model, not yaGPC2's real
# register-level execution, but avoided here anyway for a clean signal).
run_case "randomsequence" "fixtures/randomsequence.fcm" "fixtures/randomsequence-lnk101.json" "fixtures/randomsequence_golden.txt"

# dartboard.fcm / roll.fcm — the two real "Programming in HAL/S" sample
# programs RANDOM()/RANDOMG() exist to support (071-DARTBOARD_APPROXIMATION.hal,
# 134-ROLL.hal). dartboard runs a real 10,000-iteration Monte Carlo
# estimate of pi (~400K CPU steps, ~2s) — confirms RANDOM() computing
# with drawn values in between calls (X**2+Y**2) still works correctly
# end-to-end, not just in the isolated back-to-back case above.
run_case "dartboard" "fixtures/dartboard.fcm" "fixtures/dartboard-lnk101.json" "fixtures/dartboard_golden.txt"
run_case "roll" "fixtures/roll.fcm" "fixtures/roll-lnk101.json" "fixtures/roll_golden.txt"

if [ "$fail" = 0 ]; then
    echo "=== ALL RANDOM TESTS PASS ==="
else
    echo "=== RANDOM TEST FAILURES ABOVE ==="
fi
exit $fail
