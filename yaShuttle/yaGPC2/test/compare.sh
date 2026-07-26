#!/bin/bash
# compare.sh — run the Node reference (`node dist/gpc.js run`) and the C
# port (`yaGPC/yaGPC`) with identical arguments and diff stdout, stderr,
# and exit code byte-for-byte.
#
# Usage: test/compare.sh <label> [gpc-run-args...]
set -u

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
YAGPC="$ROOT/yaGPC/yaGPC"

label="$1"; shift

exp_out=$(mktemp); exp_err=$(mktemp)
act_out=$(mktemp); act_err=$(mktemp)

(cd "$ROOT" && node dist/gpc.js run "$@") >"$exp_out" 2>"$exp_err"
exp_code=$?

(cd "$ROOT" && "$YAGPC" "$@") >"$act_out" 2>"$act_err"
act_code=$?

ok=1

if ! diff -u "$exp_out" "$act_out" >"$exp_out.diff"; then
    echo "FAIL [$label]: stdout differs"
    cat "$exp_out.diff"
    ok=0
fi

if ! diff -u "$exp_err" "$act_err" >"$exp_err.diff"; then
    echo "FAIL [$label]: stderr differs"
    cat "$exp_err.diff"
    ok=0
fi

if [ "$exp_code" != "$act_code" ]; then
    echo "FAIL [$label]: exit code differs (expected=$exp_code actual=$act_code)"
    ok=0
fi

if [ "$ok" = 1 ]; then
    echo "PASS [$label]"
fi

rm -f "$exp_out" "$exp_err" "$act_out" "$act_err" "$exp_out.diff" "$exp_err.diff"
exit $((1 - ok))
