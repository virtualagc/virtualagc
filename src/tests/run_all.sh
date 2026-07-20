#!/usr/bin/env bash
# Full permanent regression suite. Run after any interp.c/value.c change,
# before committing (see Plan.md M8's testing-strategy note on running
# the full suite before every commit).
set -uo pipefail
cd "$(dirname "$0")"

fail=0
run() { "$@" || fail=1; }

# INTEGER field width (11-char right-justified, num_blanks=5 separator --
# see interp.c's flush_write) is easy to mistype by hand; derive the
# expected strings for the purely-INTEGER fixtures from the *reference*
# yaHALMAT emulator (ground truth for these two -- no known reference
# bug affects them, unlike case/nested below) rather than hardcoding a
# hand-counted string of spaces or comparing against our own output.
HALSFC="/home/rburkey/git/virtualagc/yaShuttle/Source Code/PASS.REL32V0/HALSFC"
REF_YAHALMAT="/mnt/STORAGE/home/rburkey/git/Halmat/emu/yaHALMAT"
derive_expected() {
    local name="$1"
    local workdir
    workdir=$(mktemp -d)
    cp "/mnt/STORAGE/home/rburkey/git/Halmat/data/test_$name.hal" "$workdir/"
    ( cd "$workdir" && "$HALSFC" "test_$name.hal" >/dev/null 2>&1 )
    gzip -dk "$workdir/COMMON0.out.bin.gz" 2>/dev/null
    "$REF_YAHALMAT" "$workdir/halmat.bin"
    rm -rf "$workdir"
}

run ./run_fixture.sh simple_do "$(derive_expected simple_do)"
run ./run_fixture.sh ifelse "$(printf 'C IS FIVE\nDONE')"
run ./run_fixture.sh while "TOTAL=              45"
run ./run_fixture.sh discrete_for "RESULT=              63"
run ./run_fixture.sh case "RESULT=              20"    # reference tool's "30" is its own bug -- YERRORS.md
run ./run_fixture.sh nested "K=             150"        # reference tool's "40" is its own bug -- YERRORS.md
run ./run_fixture.sh proc "$(derive_expected proc)"
run ./run_fixture.sh array ""
run ./run_fixture.sh matrix ""
run ./run_local_fixture.sh sched_high "$(printf 'BEFORE SCHEDULE\nWORKER RUNNING\nAFTER SCHEDULE')"
run ./run_local_fixture.sh sched_low "$(printf 'BEFORE SCHEDULE\nAFTER SCHEDULE')"
run ./run_local_fixture.sh scalar_arith " 3.7500000E+00"
run ./run_local_fixture.sh scalar_sub "-7.5000000E-01"
run ./run_local_fixture.sh scalar_muldiv "$(printf ' 1.0000000E+01\n 3.3333331E-01')"
run ./run_local_fixture.sh int_arith2 "P=              12     N=              -3     E=              27"
run ./run_local_fixture.sh scalar_cmp "$(printf 'LESS\nEQUAL\nAND-TRUE\nNOT-TRUE')"
run ./run_local_fixture.sh logical_or "OR-TRUE"
run ./run_local_fixture.sh mixed_type "S2=      5.5000000E+00"
run ./run_local_fixture.sh stoi "I1=               7     I2=               8     I3=              -8     I4=              -7"
run ./run_local_fixture.sh char "$(printf 'HELLOHELLO\nEQUAL\nLESS')"
run ./run_local_fixture.sh char_conv "$(printf '42\n 3.5000000E+00\n42\nI2=             123\nS2=      7.5000000E+00')"
run ./run_link_fixture.sh "Y=              43" link_pool link_prog
run ./run_read_fixture.sh read_write "42 3.5" "I1=              42     S1=      3.5000000E+00"
run ./run_read_fixture.sh rdal "HELLO WORLD" "$(printf 'HELLO\nWORLD')"
run ./run_local_fixture.sh pcal "RESULT=              15"
run ./run_local_fixture.sh bit "I1=               8     I2=              14     I3=             -13"
run ./run_local_fixture.sh scalar_exp "$(printf ' 8.0000000E+00\n 8.0000000E+00\n 2.5000000E-01\n 1.4142132E+00')"
run ./run_local_fixture.sh matrix_sub "$(printf ' 5.0000000E+00\n 3.0000000E+00\n 4.0000000E+00')"
run ./run_local_fixture.sh matvec "$(printf ' 6.0000000E+00\n 8.0000000E+00\n 1.0000000E+01\n 1.2000000E+01\n 1.9000000E+01\n 2.2000000E+01\n 4.3000000E+01\n 5.0000000E+01')"
run ./run_local_fixture.sh vec "$(printf ' 3.2000000E+01\n-3.0000000E+00\n 6.0000000E+00\n-3.0000000E+00')"
run ./run_local_fixture.sh bit_conv "$(printf ' 1.2000000E+01\n12\nBEQU-TRUE\n         12')"
run ./run_local_fixture.sh init8 "$(printf '      43690\n 9.0000000E+00\n 9.0000000E+00\n 4.0000000E+00')"
run ./run_local_fixture.sh vshp "$(printf ' 1.0000000E+00\n 2.0000000E+00\n 3.0000000E+00')"
run ./run_local_fixture.sh bfnc "$(printf ' 1.4142132E+00\n 3.5000000E+00\n-1.0000000E+00\n 2.0000000E+00\n 5.0000000E+00')"
run ./run_local_fixture.sh minv "$(printf ' 5.9999996E-01\n-6.9999999E-01\n-1.9999999E-01\n 3.9999998E-01')"
run ./run_local_fixture.sh bfnc_inv "$(printf ' 5.9999996E-01\n 3.9999998E-01')"
run ./run_local_fixture.sh eron "I1=               1"
run ./run_local_fixture.sh subbit "$(printf '          5\n         42')"
run ./run_local_fixture.sh name "$(printf 'NEQU-TRUE\nNNEQ-TRUE')"
run ./run_local_fixture.sh cfor "LASTI=               5"
run ./run_local_fixture.sh struct "$(printf 'TEQU-TRUE\nTNEQ-TRUE\n          5\nTASN-COPIED')"
run ./run_local_fixture.sh adlp "$(printf ' 3.0000000E+00\n 3.0000000E+00\n 3.0000000E+00')"
run ./run_local_fixture.sh lfnc "$(printf ' 9.0000000E+00\n 2.0000000E+00')"
run ./run_local_fixture.sh idlp "$(printf ' 4.0000000E+00\n 4.0000000E+00\n 4.0000000E+00')"
run ./run_local_fixture.sh stri "$(printf ' 1.5000000E+00\n 1.5000000E+00\n 1.5000000E+00')"
run ./run_local_fixture.sh canc "N=               0"
run ./run_local_fixture.sh canc_control "N=               1"
run ./run_local_fixture.sh sgnl "DONE"
run ./run_local_fixture.sh idef " 1.2000000E+01"
run ./run_local_fixture.sh tdcl " 6.0000000E+00"
run ./run_local_fixture.sh stos " 1.5000000000000000E+00"
run ./run_local_fixture.sh mtom "$(printf ' 1.0000000E+00\n 4.0000000E+00')"
run ./run_local_fixture.sh vtov "$(printf ' 5.0000000E+00\n 7.0000000E+00')"

HAL_S_FC_PY="/home/rburkey/git/virtualagc/yaShuttle/ported/PASS1.PROCS/HAL_S_FC.py"
workdir=$(mktemp -d)
cp /mnt/STORAGE/home/rburkey/git/Halmat/data/test_simple_do.hal "$workdir/"
( cd "$workdir" && python3 "$HAL_S_FC_PY" "--hal=test_simple_do.hal" >/dev/null )
py_exp=$(./../yaHALMAT2 --py "$workdir/FILE1.bin")
rm -rf "$workdir"
run ./run_py_fixture.sh simple_do "$py_exp"

echo "============================"
if [ "$fail" -eq 0 ]; then
    echo "ALL TESTS PASSED"
else
    echo "SOME TESTS FAILED"
fi
exit $fail
