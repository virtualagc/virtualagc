#!/usr/bin/env bash
# Same as run_local_fixture.sh, but attaches a --raf random-access file
# (class-0/FILE.md) to device 1, record size RECSIZE, for fixtures
# exercising the FILE opcode.
#
# Usage: run_raf_fixture.sh NAME RECSIZE EXPECTED_OUTPUT
# NAME must have a src/tests/hal/test_NAME.hal source file.
set -euo pipefail

HALSFC="/home/rburkey/git/virtualagc/yaShuttle/Source Code/PASS.REL32V0/HALSFC"
HAL_SRC_DIR="$(dirname "$0")/hal"
YAHALMAT2="$(dirname "$0")/../yaHALMAT2"

name="$1"
recsize="$2"
expected="$3"

workdir=$(mktemp -d)
trap 'rm -rf "$workdir"' EXIT
cp "$HAL_SRC_DIR/test_$name.hal" "$workdir/"
( cd "$workdir" && "$HALSFC" "test_$name.hal" >/dev/null )

actual=$("$YAHALMAT2" "--raf=B,$recsize,1,$workdir/rafdata.bin" "$workdir/halmat.bin")

if [ "$actual" = "$expected" ]; then
    echo "PASS: $name"
    exit 0
else
    echo "FAIL: $name"
    echo "  expected: $(printf '%q' "$expected")"
    echo "  actual:   $(printf '%q' "$actual")"
    exit 1
fi
