#!/usr/bin/env bash
# Compiles one or more EXTERNAL FUNCTION/PROCEDURE units (each --parms=
# TEMPLATE, producing an INCLUDE-TEMPLATE prototype in a shared TEMPLIB/),
# then a PROGRAM unit that calls them via `D INCLUDE TEMPLATE <name>`,
# builds an @list file from the resulting output directories, and diffs
# yaHALMAT2's linked-run output against the expected string. Tests
# cross-unit FUNCTION/PROCEDURE calls (source-documentation/Multiple-
# file-problem.md) -- distinct from run_link_fixture.sh's EXTERNAL
# COMPOOL case, which needs no TEMPLIB/INCLUDE TEMPLATE step at all.
#
# Usage: run_ext_func_fixture.sh EXPECTED_OUTPUT PROGRAM_NAME FUNC_NAME1 [FUNC_NAME2 ...]
# PROGRAM_NAME and each FUNC_NAMEn must have a src/tests/hal/test_NAME.hal
# source file. All units are compiled in one shared directory (so the
# PROGRAM's INCLUDE TEMPLATE can see the FUNC units' TEMPLIB/ output),
# func units first, program last.
set -euo pipefail

HALSFC="/home/rburkey/git/virtualagc/yaShuttle/Source Code/PASS.REL32V0/HALSFC"
HAL_SRC_DIR="$(dirname "$0")/hal"
YAHALMAT2="$(dirname "$0")/../yaHALMAT2"

expected="$1"; shift
prog_name="$1"; shift

workdir=$(mktemp -d)
trap 'rm -rf "$workdir"' EXIT
listfile="$workdir/list.txt"
: > "$listfile"

for name in "$@"; do
    cp "$HAL_SRC_DIR/test_$name.hal" "$workdir/"
    ( cd "$workdir" && "$HALSFC" --clean --archive --parms=TEMPLATE "test_$name.hal" >/dev/null )
    readlink -f "$workdir/current.results" >> "$listfile"
done

cp "$HAL_SRC_DIR/test_$prog_name.hal" "$workdir/"
( cd "$workdir" && "$HALSFC" --clean --archive "test_$prog_name.hal" >/dev/null )
readlink -f "$workdir/current.results" >> "$listfile"

actual=$("$YAHALMAT2" "@$listfile")

if [ "$actual" = "$expected" ]; then
    echo "PASS: ext_func($prog_name $*)"
    exit 0
else
    echo "FAIL: ext_func($prog_name $*)"
    echo "  expected: $(printf '%q' "$expected")"
    echo "  actual:   $(printf '%q' "$actual")"
    exit 1
fi
