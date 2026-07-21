#!/usr/bin/env bash
# Recompiles a HAL/S fixture with the locally installed HALSFC (to get the
# full companion-file set -- litfile0.bin + COMMON0.out.bin.gz -- that the
# prebaked Halmat/data/out_* fixtures don't ship with) and diffs
# yaHALMAT2's output against the expected string.
#
# Usage: run_fixture.sh NAME EXPECTED_OUTPUT
# NAME must have a Halmat/data/test_NAME.hal source file.
set -euo pipefail

HALSFC="/home/rburkey/git/virtualagc/yaShuttle/Source Code/PASS.REL32V0/HALSFC"
HAL_SRC_DIR="/mnt/STORAGE/home/rburkey/git/Halmat/data"
YAHALMAT2="$(dirname "$0")/../yaHALMAT2"

name="$1"
expected="$2"

workdir=$(mktemp -d)
trap 'rm -rf "$workdir"' EXIT
cp "$HAL_SRC_DIR/test_$name.hal" "$workdir/"
( cd "$workdir" && "$HALSFC" "test_$name.hal" >/dev/null )

actual=$("$YAHALMAT2" "$workdir/halmat.bin")

if [ "$actual" = "$expected" ]; then
    echo "PASS: $name"
    exit 0
else
    echo "FAIL: $name"
    echo "  expected: $(printf '%q' "$expected")"
    echo "  actual:   $(printf '%q' "$actual")"
    exit 1
fi
