#!/bin/bash
# test_rtl.sh — regression test for real AP-101S runtime-library
# routines whose own Appendix D catalog entries were previously
# "unresolved" (hal-runtime-features.db rows 131/133; see problems.md
# 7.21). All confirmed implemented_via_cpu -- ordinary CPU-executed RTL
# calls (no SVC), the same category as SQRT/RANDOM/etc. -- so this only
# needs a real compiled program that exercises each one, diffed against
# yaHALMAT2 as an independent oracle. No TASK/SCHEDULE/WAIT involved.
set -u
cd "$(dirname "$0")"

YAGPC2="../yaGPC2"

fail=0

run_case() {
    label="$1"; fcm="$2"; sym="$3"; golden="$4"

    act_out=$(mktemp)
    act_err=$(mktemp)

    "$YAGPC2" --interactive --no-trace --no-verbose --symbols "$sym" --line-width 240 --max-steps 20000 "$fcm" >"$act_out" 2>"$act_err"
    act_code=$?

    ok=1

    if ! diff -u "$golden" "$act_out"; then
        echo "FAIL [rtl/$label]: stdout differs from $golden"
        ok=0
    fi

    if [ -s "$act_err" ]; then
        echo "FAIL [rtl/$label]: unexpected stderr output"
        cat "$act_err"
        ok=0
    fi

    if [ "$act_code" != 0 ]; then
        echo "FAIL [rtl/$label]: exit code $act_code (expected 0)"
        ok=0
    fi

    if [ "$ok" = 1 ]; then
        echo "PASS [rtl/$label]"
    else
        fail=1
    fi

    rm -f "$act_out" "$act_err"
}

# charactercompare.hal — CPR ("CHARACTER COMPARE" per its own real
# RUNASM/CPR.asm TITLE line), row 131's own CAS/CASP/CASR/CPAS/CPR
# family — turns out to be an ordinary CHARACTER comparison/assignment
# family, nothing to do with Compool/REMOTE access despite the original
# survey's guess (CAS is simply an alias of CASV, already confirmed and
# in daily use throughout this whole codebase's own WRITE-with-string-
# literal support).
run_case "charactercompare" "fixtures/charactercompare.fcm" "fixtures/charactercompare-lnk101.json" "fixtures/charactercompare_golden.txt"

# remotevectorcopy.hal — VR1SN ("SCALAR TO REMOTE VECTOR MOVE, SP" per
# its own real RUNASM/VR1SN.asm TITLE line), the genuine REMOTE-data-
# movement family row 131 was actually looking for (VR* for VECTOR,
# MSTR for STRUCTURE — see structurecompare below).
run_case "remotevectorcopy" "fixtures/remotevectorcopy.fcm" "fixtures/remotevectorcopy-lnk101.json" "fixtures/remotevectorcopy_golden.txt"

# structurecompare.hal — CSTRUC ("STRUCTURE COMPARE" per its own real
# RUNASM/CSTRUC.asm TITLE line), one of row 133's own "unlabeled CSECT"
# entries.
run_case "structurecompare" "fixtures/structurecompare.fcm" "fixtures/structurecompare-lnk101.json" "fixtures/structurecompare_golden.txt"

# charactersubbit.hal — CSLD ("CHARACTER SUBBIT LOAD AND STORE
# ROUTINES" per its own real RUNASM/CSLD.asm TITLE line), another of
# row 133's own named members. Golden is hand-verified against the
# BIN literal's own known bit pattern, NOT diffed against yaHALMAT2 --
# their own binary explicitly errors on CHARACTER SUBBIT assignment as
# unimplemented (a real gap on their side, reported but not usable as
# an oracle here).
run_case "charactersubbit" "fixtures/charactersubbit.fcm" "fixtures/charactersubbit-lnk101.json" "fixtures/charactersubbit_golden.txt"

if [ "$fail" = 0 ]; then
    echo "=== ALL RTL TESTS PASS ==="
else
    echo "=== RTL TEST FAILURES ABOVE ==="
fi
exit $fail
