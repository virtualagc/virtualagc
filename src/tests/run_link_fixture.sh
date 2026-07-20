#!/usr/bin/env bash
# Compiles two or more HAL/S sources from src/tests/hal/ into separate
# directories (as if independently compiled and later linked), builds
# an @list file, and diffs yaHALMAT2's linked-run output against the
# expected string. Tests M6 (multi-file linking).
#
# Usage: run_link_fixture.sh EXPECTED_OUTPUT NAME1 [NAME2 ...]
# Each NAME must have a src/tests/hal/test_NAME.hal source file.
set -euo pipefail

HALSFC="/home/rburkey/git/virtualagc/yaShuttle/Source Code/PASS.REL32V0/HALSFC"
HAL_SRC_DIR="$(dirname "$0")/hal"
YAHALMAT2="$(dirname "$0")/../yaHALMAT2"

expected="$1"
shift

workdir=$(mktemp -d)
trap 'rm -rf "$workdir"' EXIT
listfile="$workdir/list.txt"
: > "$listfile"

for name in "$@"; do
    unitdir="$workdir/$name"
    mkdir -p "$unitdir"
    cp "$HAL_SRC_DIR/test_$name.hal" "$unitdir/"
    ( cd "$unitdir" && "$HALSFC" "test_$name.hal" >/dev/null )
    gzip -dk "$unitdir/COMMON0.out.bin.gz"
    echo "$unitdir" >> "$listfile"
done

actual=$("$YAHALMAT2" "@$listfile")

if [ "$actual" = "$expected" ]; then
    echo "PASS: link($*)"
    exit 0
else
    echo "FAIL: link($*)"
    echo "  expected: $(printf '%q' "$expected")"
    echo "  actual:   $(printf '%q' "$actual")"
    exit 1
fi
