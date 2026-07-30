#!/bin/bash
# test_debugger.sh — end-to-end regression test for `yaGPC2 --debug`
# (see src/debugger.c). Unlike compare.sh/compare_stdin.sh, this has no
# JS reference to diff against (the debugger is a new, yaGPC2-only
# feature -- see debugger-planner.md) -- instead it scripts a fixed
# sequence of debugger commands via stdin against a real HAL/S-compiled
# fixture and diffs the transcript against a captured golden file,
# following this project's usual "run it, diff the captured output"
# discipline.
set -u
cd "$(dirname "$0")"

YAGPC2="../yaGPC2"
FCM="fixtures/hello.fcm"
SYM="fixtures/hello-lnk101.json"

fail=0

run_case() {
    label="$1"; shift
    commands="fixtures/debugger_${label}_commands.txt"
    golden="fixtures/debugger_${label}_golden.txt"

    act_out=$(mktemp)
    act_err=$(mktemp)

    "$YAGPC2" --symbols "$SYM" --debug --line-width 240 "$@" "$FCM" <"$commands" >"$act_out" 2>"$act_err"
    act_code=$?

    ok=1

    if ! diff -u "$golden" "$act_out"; then
        echo "FAIL [debugger/$label]: stdout differs from $golden"
        ok=0
    fi

    if [ -s "$act_err" ]; then
        echo "FAIL [debugger/$label]: unexpected stderr output"
        cat "$act_err"
        ok=0
    fi

    if [ "$act_code" != 0 ]; then
        echo "FAIL [debugger/$label]: exit code $act_code (expected 0)"
        ok=0
    fi

    if [ "$ok" = 1 ]; then
        echo "PASS [debugger/$label]"
    else
        fail=1
    fi

    rm -f "$act_out" "$act_err"
}

# Stage 1: skeleton + core cmd_debug.coffee ports (break/continue/reg/
# disasm/mem/bt/next/steps/sym/sections/quit).
run_case "hello"

# Stage 2: memory watchpoints ('mw'), watch expressions ('watch'), and
# register alteration ('set'). Exercises the base-register-relative
# effective-address computation (STH 1,X'0005'(0) actually writes to
# 0x217, not literal 0x5 -- see cpu_g_ea's non-indexed/DSE branch)
# indirectly, since the watched address had to be the real one.
run_case "watch"

# Stage 3: HAL/S source-line display ('source'/'src', and automatically
# at each stop) via a source map built by tools/gen_source_map.py from a
# real HALSFC compile's pass1.rpt/pass2.rpt (see that script's header
# comment for why -- not the SDF binary format originally targeted).
run_case "srcmap" --source-map fixtures/hello.srcmap.json

exit $fail
