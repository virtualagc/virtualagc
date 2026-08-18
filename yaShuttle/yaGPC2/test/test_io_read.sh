#!/bin/bash
# test_io_read.sh — end-to-end regression test for three READ-side I/O
# fixes (see src/halucp.c: extract_readall_field(), the TAB case's
# inReadIOInit branch, write_input_value()'s BIT case, and
# apply_read_positioning()'s retry-on-not-yet-buffered fix), found by
# tracing a real upstream `gpc` (JS) fix (Don Schmidt, 2026-08-06) that
# yaGPC2 had independently missed:
#
#   1. READALL(ch) VNAME transfers raw column data (no comma/blank
#      delimiter parsing) -- USA003087 10.1.2.
#   2. TAB(n) on a READ statement actually repositions the input column
#      (previously silently had no effect at all, only COLUMN did).
#   3. BIT input with an illegal character (anything but 0/1/blank)
#      reports ILLEGAL BIT STRING and sets the value to 0, instead of
#      silently stripping the bad character and parsing what's left.
#
# Like test_debugger.sh/test_scheduler.sh, no JS reference to diff
# against -- fixed and confirmed correct via direct spec citation
# (USA003087 10.1.1/10.1.2, RUNASM/CTOB.asm) and cross-checked against
# the real upstream gpc fix's own described behavior, then captured as
# a golden here.
set -u
cd "$(dirname "$0")"

YAGPC2="../yaGPC2"
FCM="fixtures/ioreadfixes.fcm"
SYM="fixtures/ioreadfixes-lnk101.json"
STDIN="fixtures/ioreadfixes_stdin.txt"
GOLDEN="fixtures/ioreadfixes_golden.txt"

act_out=$(mktemp)
act_err=$(mktemp)

"$YAGPC2" --interactive --no-trace --no-verbose --symbols "$SYM" --line-width 240 "$FCM" \
    <"$STDIN" >"$act_out" 2>"$act_err"
act_code=$?

fail=0

if ! diff -u "$GOLDEN" "$act_out"; then
    echo "FAIL [io_read/stdout]: stdout differs from $GOLDEN"
    fail=1
fi

if ! grep -q "ILLEGAL BIT STRING" "$act_err"; then
    echo "FAIL [io_read/stderr]: expected ILLEGAL BIT STRING warning not seen"
    cat "$act_err"
    fail=1
fi

if [ "$act_code" != 0 ]; then
    echo "FAIL [io_read]: exit code $act_code (expected 0)"
    fail=1
fi

if [ "$fail" = 0 ]; then
    echo "PASS [io_read]"
fi

rm -f "$act_out" "$act_err"
exit $fail
