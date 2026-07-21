#!/usr/bin/env bash
# Proves interp_run()'s wall-clock pacing (state.h's scheduler comment,
# HALMAT_REALTIME_BURST_MS) actually throttles execution against the real
# clock -- for whichever pacing implementation is selected (--pacing,
# main.c; default burst, interp_run_burst()'s original polling design,
# or signal, interp_run_signal()'s POSIX/Win32 timer-notification-driven
# alternative -- see interp.c's comments on both). Every other WAIT/
# SCHEDULE fixture in this suite passes a large --time-scale specifically
# to make its sleep negligible, so none of them can catch a regression
# that silently disables throttling entirely (or one that hangs/massively
# over-sleeps) -- this fixture is the one that runs at the DEFAULT
# time_scale=1.0 rate and brackets the yaHALMAT2 invocation with
# wall-clock timestamps, asserting the run took approximately its
# expected real-time duration. Tolerance is deliberately generous (at
# least 50% of the expected interval, at most 5x it) -- real dev-
# machine/CI timing has natural jitter, and the point is only to catch a
# gross regression, not to validate microsecond precision.
#
# Usage: run_realtime_fixture.sh NAME EXPECTED_OUTPUT EXPECTED_SECONDS [PACING]
# NAME must have a src/tests/hal/test_NAME.hal source file. PACING is
# burst (default, if omitted) or signal, passed straight through as
# --pacing=PACING.
set -euo pipefail

HALSFC="/home/rburkey/git/virtualagc/yaShuttle/Source Code/PASS.REL32V0/HALSFC"
HAL_SRC_DIR="$(dirname "$0")/hal"
YAHALMAT2="$(dirname "$0")/../yaHALMAT2"

name="$1"
expected="$2"
expected_seconds="$3"
pacing="${4:-burst}"

workdir=$(mktemp -d)
trap 'rm -rf "$workdir"' EXIT
cp "$HAL_SRC_DIR/test_$name.hal" "$workdir/"
( cd "$workdir" && "$HALSFC" "test_$name.hal" >/dev/null )

start=$(date +%s.%N)
actual=$("$YAHALMAT2" "--pacing=$pacing" "$workdir/halmat.bin")
end=$(date +%s.%N)
elapsed=$(awk -v s="$start" -v e="$end" 'BEGIN { printf "%.3f", e - s }')

min_ok=$(awk -v x="$expected_seconds" 'BEGIN { printf "%.3f", x * 0.5 }')
max_ok=$(awk -v x="$expected_seconds" 'BEGIN { printf "%.3f", x * 5.0 }')
in_bounds=$(awk -v e="$elapsed" -v lo="$min_ok" -v hi="$max_ok" 'BEGIN { print (e >= lo && e <= hi) ? "yes" : "no" }')

if [ "$actual" = "$expected" ] && [ "$in_bounds" = "yes" ]; then
    echo "PASS: realtime($name, pacing=$pacing) elapsed=${elapsed}s (expected ~${expected_seconds}s, bounds [${min_ok}s, ${max_ok}s])"
    exit 0
else
    echo "FAIL: realtime($name, pacing=$pacing)"
    echo "  expected output: $(printf '%q' "$expected")"
    echo "  actual output:   $(printf '%q' "$actual")"
    echo "  elapsed: ${elapsed}s -- expected bounds [${min_ok}s, ${max_ok}s] (target ~${expected_seconds}s)"
    exit 1
fi
