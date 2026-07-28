#!/usr/bin/env bash
# Compiles a COMPOOL template-provider unit (--parms=TEMPLATE, producing
# a TEMPLIB/ entry other units' `D INCLUDE TEMPLATE` picks up), then an
# EXTERNAL FUNCTION provider unit (plain compile -- it's linked by name
# via yaHALMAT2's own by-name EXTERNAL match, not a TEMPLIB entry), then
# a PROGRAM unit that both includes the same template and hand-declares
# the EXTERNAL FUNCTION prototype itself, builds an @list file from the
# resulting output directories, and diffs yaHALMAT2's linked-run output
# against the expected string. Tests an EXTERNAL FUNCTION returning a
# whole STRUCTURE across the unit boundary (yahalmat2_extn_multifile_
# template) -- distinct from run_ext_func_fixture.sh's own shape, where
# every FUNC unit is itself compiled --parms=TEMPLATE and consumed via
# `D INCLUDE TEMPLATE`; here only the COMPOOL is templated, and the
# FUNCTION unit is linked purely by its own EXTERNAL-flagged name match.
#
# Usage: run_ext_struct_fixture.sh EXPECTED_OUTPUT COMPOOL_NAME FUNC_NAME PROG_NAME
# Each NAME must have a src/tests/hal/test_NAME.hal source file. All
# units are compiled in one shared directory (so the FUNC/PROG units'
# own INCLUDE TEMPLATE can see the COMPOOL's TEMPLIB/ output).
set -euo pipefail

HALSFC="/home/rburkey/git/virtualagc/yaShuttle/Source Code/PASS.REL32V0/HALSFC"
HAL_SRC_DIR="$(dirname "$0")/hal"
YAHALMAT2="$(dirname "$0")/../yaHALMAT2"

expected="$1"
compool_name="$2"
func_name="$3"
prog_name="$4"

workdir=$(mktemp -d)
trap 'rm -rf "$workdir"' EXIT
listfile="$workdir/list.txt"
: > "$listfile"

cp "$HAL_SRC_DIR/test_$compool_name.hal" "$workdir/"
( cd "$workdir" && "$HALSFC" --clean --archive --parms=TEMPLATE "test_$compool_name.hal" >/dev/null )
readlink -f "$workdir/current.results" >> "$listfile"

cp "$HAL_SRC_DIR/test_$func_name.hal" "$workdir/"
( cd "$workdir" && "$HALSFC" --clean --archive "test_$func_name.hal" >/dev/null )
readlink -f "$workdir/current.results" >> "$listfile"

cp "$HAL_SRC_DIR/test_$prog_name.hal" "$workdir/"
( cd "$workdir" && "$HALSFC" --clean --archive "test_$prog_name.hal" >/dev/null )
readlink -f "$workdir/current.results" >> "$listfile"

actual=$("$YAHALMAT2" "@$listfile")

if [ "$actual" = "$expected" ]; then
    echo "PASS: ext_struct($prog_name $func_name $compool_name)"
    exit 0
else
    echo "FAIL: ext_struct($prog_name $func_name $compool_name)"
    echo "  expected: $(printf '%q' "$expected")"
    echo "  actual:   $(printf '%q' "$actual")"
    exit 1
fi
