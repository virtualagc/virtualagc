#!/usr/bin/env bash
# Same as run_local_fixture.sh, but feeds STDIN_TEXT to yaHALMAT2's own
# stdin -- for fixtures exercising READ (device 5 defaults to stdin, see
# state.h/interp.c's device-mapping default). No reference-emulator
# cross-check is possible here: the reference yaHALMAT has no READ/FILE
# I/O at all (Plan.md Phase 3's stated gap list), so EXPECTED_OUTPUT is
# hand-derived instead.
#
# Usage: run_read_fixture.sh NAME STDIN_TEXT EXPECTED_OUTPUT
# NAME must have a src/tests/hal/test_NAME.hal source file.
set -euo pipefail

HALSFC="/home/rburkey/git/virtualagc/yaShuttle/Source Code/PASS.REL32V0/HALSFC"
HAL_SRC_DIR="$(dirname "$0")/hal"
YAHALMAT2="$(dirname "$0")/../yaHALMAT2"

name="$1"
stdin_text="$2"
expected="$3"

workdir=$(mktemp -d)
trap 'rm -rf "$workdir"' EXIT
cp "$HAL_SRC_DIR/test_$name.hal" "$workdir/"
( cd "$workdir" && "$HALSFC" "test_$name.hal" >/dev/null )
gzip -dk "$workdir/COMMON0.out.bin.gz"

actual=$(printf '%s' "$stdin_text" | "$YAHALMAT2" "$workdir/halmat.bin")

if [ "$actual" = "$expected" ]; then
    echo "PASS: read($name)"
    exit 0
else
    echo "FAIL: read($name)"
    echo "  expected: $(printf '%q' "$expected")"
    echo "  actual:   $(printf '%q' "$actual")"
    exit 1
fi
