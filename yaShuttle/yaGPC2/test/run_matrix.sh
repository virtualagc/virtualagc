#!/bin/bash
# run_matrix.sh — exercises compare.sh across the .fcm fixture corpus and
# a representative option matrix (Phase 11 validation). compare.sh itself
# cd's to the repo root before running both the Node reference and
# yaGPC, so all paths here (including the .fcm arguments) are relative to
# the repo root, not to this script's location.
set -u

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
COMPARE="$SCRIPT_DIR/compare.sh"
COMPARE_STDIN="$SCRIPT_DIR/compare_stdin.sh"
DEVNULL="/dev/null"

FCMS="gpc/gen/SIMPLE.fcm gpc/gen/TEST.fcm gpc/gen/TESTSET.fcm gpc/gen/SS.fcm gpc/gen/asm.fcm gpc/gen/A3GRESCH.fcm"

fail=0

for fcm in $FCMS; do
    name=$(basename "$fcm" .fcm)
    bash "$COMPARE" "$name/default" "$fcm" --start 0 --max-steps 2000 || fail=1
    bash "$COMPARE" "$name/verbose" "$fcm" --start 0 --verbose --max-steps 2000 || fail=1
    bash "$COMPARE" "$name/trace" "$fcm" --start 0 --trace --verbose --max-steps 500 || fail=1
    bash "$COMPARE" "$name/trace-dump" "$fcm" --start 0 --trace --verbose --max-steps 500 --dump-interval 50 || fail=1
    bash "$COMPARE" "$name/no-verbose" "$fcm" --start 0 --no-verbose --max-steps 500 || fail=1
    bash "$COMPARE" "$name/max-steps-small" "$fcm" --start 0 --max-steps 3 || fail=1
done

echo "--- watch/break matrix ---"
bash "$COMPARE" "TEST/watch" gpc/gen/TEST.fcm --start 0 --verbose --max-steps 2000 --watch 0x10:4 || fail=1
bash "$COMPARE" "TEST/watch-log" gpc/gen/TEST.fcm --start 0 --verbose --max-steps 500 --watch 0x10:4 --watch-log || fail=1
bash "$COMPARE" "TEST/break" gpc/gen/TEST.fcm --start 0 --verbose --max-steps 2000 --break 0x40 || fail=1

echo "--- previously-uncovered CLI option matrix ---"
bash "$COMPARE" "TEST/ebcdic" gpc/gen/TEST.fcm --start 0 --verbose --max-steps 500 --ebcdic || fail=1
bash "$COMPARE" "TEST/trap-svc-error" gpc/gen/TEST.fcm --start 0 --verbose --max-steps 500 --trap-svc-error || fail=1
bash "$COMPARE" "TEST/no-trap-svc-error" gpc/gen/TEST.fcm --start 0 --verbose --max-steps 500 --no-trap-svc-error || fail=1
bash "$COMPARE" "TEST/halucp-blanks" gpc/gen/TEST.fcm --start 0 --verbose --max-steps 500 --halucp-format-num-blanks 3 || fail=1
bash "$COMPARE" "TEST/line-width" gpc/gen/TEST.fcm --start 0 --verbose --max-steps 500 --line-width 80 || fail=1

echo "--- HAL/S SVC trap matrix (hand-assembled fixtures, see test/fixtures/gen_svc_fcms.cjs) ---"
SVC_FCMS="yaGPC/test/fixtures/svc_halt.fcm yaGPC/test/fixtures/svc_senderror.fcm yaGPC/test/fixtures/svc_unknown.fcm"
for fcm in $SVC_FCMS; do
    name=$(basename "$fcm" .fcm)
    bash "$COMPARE" "$name/default" "$fcm" --start 0 --max-steps 10 || fail=1
    bash "$COMPARE" "$name/verbose-trace" "$fcm" --start 0 --verbose --trace --max-steps 10 || fail=1
    bash "$COMPARE" "$name/no-trap-svc-error" "$fcm" --start 0 --verbose --trace --no-trap-svc-error --max-steps 10 || fail=1
done

echo "--- real HAL/S-compiled fixtures (HALSFC/lnk101, see test/fixtures/build_hal_fixtures.sh) ---"
HELLO_SYM="yaGPC/test/fixtures/hello-lnk101.json"
RW_SYM="yaGPC/test/fixtures/read_write-lnk101.json"
bash "$COMPARE_STDIN" "hello/interactive" "$DEVNULL" --interactive --no-trace --no-verbose --symbols "$HELLO_SYM" --line-width 240 yaGPC/test/fixtures/hello.fcm || fail=1
bash "$COMPARE" "hello/batch-verbose" --verbose --symbols "$HELLO_SYM" yaGPC/test/fixtures/hello.fcm || fail=1
bash "$COMPARE_STDIN" "read_write/interactive" yaGPC/test/fixtures/read_write_stdin.txt --interactive --no-trace --no-verbose --symbols "$RW_SYM" --line-width 240 yaGPC/test/fixtures/read_write.fcm || fail=1

echo "--- known gpc-run defect, checked against expected output only, NOT diffed against the reference ---"
echo "    (gpc run --interactive silently truncates READ-until-EOF programs; see run.c's"
echo "    interactive_input_cb comment. yaGPC completes the program correctly, by design.)"
ONERROR_SYM="yaGPC/test/fixtures/read_eof_onerror-lnk101.json"
onerror_out=$(printf "1, 1\n2, 2\n3, 4\n" | yaGPC/yaGPC --interactive --no-trace --no-verbose --symbols "$ONERROR_SYM" --line-width 240 yaGPC/test/fixtures/read_eof_onerror.fcm)
if echo "$onerror_out" | grep -q "0      SAMPLES CORRECT,                3      SAMPLES INCORRECT"; then
    echo "PASS [read_eof_onerror/yaGPC-completes-correctly]"
else
    echo "FAIL [read_eof_onerror/yaGPC-completes-correctly]"
    echo "$onerror_out"
    fail=1
fi

echo "--- another known gpc-run defect (iop.ls missing call parens, see iop.h) ---"
echo "    reached for the first time by iop_msc_sio.fcm, which starts the MSC via a real"
echo "    CPU PC instruction; gpc run crashes (TypeError), yaGPC completes correctly."
iop_out=$(yaGPC/yaGPC --start 0x10 --verbose --max-steps 10 yaGPC/test/fixtures/iop_msc_sio.fcm 2>&1)
iop_exit=$?
if [ "$iop_exit" = 0 ] && echo "$iop_out" | grep -q "R04=00000001"; then
    echo "PASS [iop_msc_sio/yaGPC-completes-correctly]"
else
    echo "FAIL [iop_msc_sio/yaGPC-completes-correctly] exit=$iop_exit"
    echo "$iop_out"
    fail=1
fi

if [ "$fail" = 0 ]; then
    echo "=== ALL MATRIX RUNS PASS ==="
else
    echo "=== SOME MATRIX RUNS FAILED ==="
fi
exit $fail
