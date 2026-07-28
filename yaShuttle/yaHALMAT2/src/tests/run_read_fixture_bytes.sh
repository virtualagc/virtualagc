#!/usr/bin/env bash
# Same as run_read_fixture.sh, but compares stdout byte-for-byte (via cmp)
# instead of through `actual=$(...)`, which silently strips ALL trailing
# newlines and so can never detect a spurious extra trailing blank line
# (DB id 47) -- the exact thing this harness exists to catch. Also
# tolerates yaHALMAT2's own nonzero exit code from an unhandled READ EOF
# (fail()'s own convention), since that's the whole point of this
# fixture's repro.
#
# Usage: run_read_fixture_bytes.sh NAME STDIN_TEXT EXPECTED_OUTPUT
# NAME must have a src/tests/hal/test_NAME.hal source file.
# EXPECTED_OUTPUT is compared verbatim (no implicit trailing newline is
# added) -- pass it via $'...\n' or printf '%s' so the exact expected byte
# count, including any deliberately-omitted final newline, is explicit.
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

printf '%s' "$stdin_text" | "$YAHALMAT2" "$workdir/halmat.bin" > "$workdir/actual.out" 2>/dev/null || true
printf '%s' "$expected" > "$workdir/expected.out"

if cmp -s "$workdir/actual.out" "$workdir/expected.out"; then
    echo "PASS: read_bytes($name)"
    exit 0
else
    echo "FAIL: read_bytes($name)"
    echo "  expected: $(cat -A "$workdir/expected.out")"
    echo "  actual:   $(cat -A "$workdir/actual.out")"
    exit 1
fi
