#!/usr/bin/env bash
# Same as run_fixture.sh, but for HAL/S sources authored directly in this
# project (src/tests/hal/) rather than the prebaked Halmat/data/ fixtures
# -- used for behavior (SCHEDULE/WAIT/TERM, etc.) that the original 9
# out_* fixtures don't exercise.
#
# Usage: run_local_fixture.sh NAME EXPECTED_OUTPUT [YAHALMAT2_ARGS...]
# NAME must have a src/tests/hal/test_NAME.hal source file. Any extra
# arguments (e.g. --time-scale=1000000, so SCHEDULE/WAIT-using fixtures'
# now-real-time-throttled runs still finish fast -- see state.h's
# scheduler comment) are passed straight through to the yaHALMAT2
# invocation, before the halmat.bin positional argument.
set -euo pipefail

HALSFC="/home/rburkey/git/virtualagc/yaShuttle/Source Code/PASS.REL32V0/HALSFC"
HAL_SRC_DIR="$(dirname "$0")/hal"
YAHALMAT2="$(dirname "$0")/../yaHALMAT2"

name="$1"
expected="$2"
shift 2
extra_args=("$@")

workdir=$(mktemp -d)
trap 'rm -rf "$workdir"' EXIT
cp "$HAL_SRC_DIR/test_$name.hal" "$workdir/"
( cd "$workdir" && "$HALSFC" "test_$name.hal" >/dev/null )

actual=$("$YAHALMAT2" "${extra_args[@]}" "$workdir/halmat.bin")

if [ "$actual" = "$expected" ]; then
    echo "PASS: $name"
    exit 0
else
    echo "FAIL: $name"
    echo "  expected: $(printf '%q' "$expected")"
    echo "  actual:   $(printf '%q' "$actual")"
    exit 1
fi
