#!/usr/bin/env bash
# Same as run_fixture.sh, but compiles with HAL_S_FC.py (the pure-Python
# PASS1 port) instead of HALSFC, producing FILE1.bin/FILE2.bin/LIT_CHAR.bin
# rather than halmat.bin/litfile0.bin/COMMON0.out.bin -- tests --py.
#
# Usage: run_py_fixture.sh NAME EXPECTED_OUTPUT
# NAME must have a Halmat/data/test_NAME.hal source file.
set -euo pipefail

HAL_S_FC_PY="/home/rburkey/git/virtualagc/yaShuttle/ported/PASS1.PROCS/HAL_S_FC.py"
HAL_SRC_DIR="/mnt/STORAGE/home/rburkey/git/Halmat/data"
YAHALMAT2="$(dirname "$0")/../yaHALMAT2"

name="$1"
expected="$2"

workdir=$(mktemp -d)
trap 'rm -rf "$workdir"' EXIT
cp "$HAL_SRC_DIR/test_$name.hal" "$workdir/"
( cd "$workdir" && python3 "$HAL_S_FC_PY" "--hal=test_$name.hal" >/dev/null )

actual=$("$YAHALMAT2" --py "$workdir/FILE1.bin")

if [ "$actual" = "$expected" ]; then
    echo "PASS: py($name)"
    exit 0
else
    echo "FAIL: py($name)"
    echo "  expected: $(printf '%q' "$expected")"
    echo "  actual:   $(printf '%q' "$actual")"
    exit 1
fi
