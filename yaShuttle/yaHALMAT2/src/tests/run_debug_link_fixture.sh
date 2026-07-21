#!/usr/bin/env bash
# Proves --debug works for a single-unit @list (previously silently
# ignored -- debug_mode was parsed but never threaded through
# run_linked()/run_linked_units(), so the program just ran normally with
# no debugger attached and no error either), and that real multi-unit
# interactive debugging (--debug over an @list naming a PROGRAM plus a
# separately-compiled EXTERNAL PROCEDURE unit) actually works: `next`
# runs a cross-unit CALL atomically (never showing the callee's own
# instructions/source), `step` descends *into* it (showing the callee's
# own source/instructions), and the stepped-into call auto-returns to
# the caller once the callee's own CLOS is reached -- both paths must
# still produce the exact same final program output as an ordinary
# non-debug run.
#
# No arguments; self-contained, exercises all three cases in one script.
set -euo pipefail

HALSFC="/home/rburkey/git/virtualagc/yaShuttle/Source Code/PASS.REL32V0/HALSFC"
HAL_SRC_DIR="$(dirname "$0")/hal"
YAHALMAT2="$(dirname "$0")/../yaHALMAT2"

fail=0

# --- single-unit case ---------------------------------------------------
# Reuses test_int_arith2.hal's already-established, hand-verified
# expected output (see run_all.sh's own `int_arith2` line) rather than
# re-deriving it -- --debug's transcript interleaves debugger prose
# (banner, source-line echoes, instruction dumps, prompts) with the
# program's own WRITE output, so this checks the known line appears
# somewhere in the transcript rather than an exact whole-output match.
workdir1=$(mktemp -d)
unitdir1="$workdir1/prog"
mkdir -p "$unitdir1"
cp "$HAL_SRC_DIR/test_int_arith2.hal" "$unitdir1/"
( cd "$unitdir1" && "$HALSFC" test_int_arith2.hal >/dev/null )
listfile1="$workdir1/list.txt"
echo "$unitdir1" > "$listfile1"

transcript=$(printf 'continue\nquit\n' | "$YAHALMAT2" --debug "@$listfile1" 2>&1)
rm -rf "$workdir1"

if echo "$transcript" | grep -qF "P=              12     N=              -3     E=              27"; then
    echo "PASS: debug_link(single-unit)"
else
    echo "FAIL: debug_link(single-unit)"
    echo "  transcript did not contain the expected program output line"
    echo "  transcript: $(printf '%q' "$transcript")"
    fail=1
fi

# --- multi-unit case: build a two-unit @list (PROGRAM + EXTERNAL --------
# PROCEDURE), same shared-directory compile recipe run_ext_func_fixture.sh
# uses (the PROGRAM's own `D INCLUDE TEMPLATE DOUBLE_IT` needs to see the
# PROCEDURE unit's own TEMPLIB/ output from compiling in the same dir).
# test_ext_pcal_prog.hal's EXTPROC calls test_ext_double.hal's DOUBLE_IT(5)
# once, which WRITEs "X, X+X" (5, 10) -- run_all.sh's own `ext_func`
# fixture line already established "          5              10" as the
# correct plain (non-debug) output for this exact pair.
workdir2=$(mktemp -d)
listfile2="$workdir2/list.txt"
: > "$listfile2"
cp "$HAL_SRC_DIR/test_ext_double.hal" "$workdir2/"
( cd "$workdir2" && "$HALSFC" --clean --archive --parms=TEMPLATE test_ext_double.hal >/dev/null )
readlink -f "$workdir2/current.results" >> "$listfile2"
cp "$HAL_SRC_DIR/test_ext_pcal_prog.hal" "$workdir2/"
( cd "$workdir2" && "$HALSFC" --clean --archive test_ext_pcal_prog.hal >/dev/null )
readlink -f "$workdir2/current.results" >> "$listfile2"

# `next` x8 (empirically confirmed sufficient, by an actual manual
# --debug session read before writing this expectation, to walk EXTPROC's
# PROGRAM from its first instruction through the CALL DOUBLE_IT(5) and on
# to its own CLOS): every cross-unit CALL must run atomically -- the
# transcript should show the program's own output but never the callee's
# own "DOUBLE_IT:" source label (only shown if its own source is ever
# displayed, i.e. only if the debugger had descended into it) or a
# "returned to caller" auto-pop message (only printed when a frame the
# debugger itself pushed via `step` finishes).
next_transcript=$(printf 'next\nnext\nnext\nnext\nnext\nnext\nnext\nnext\nquit\n' | "$YAHALMAT2" --debug "@$listfile2" 2>&1)

next_ok=1
if ! echo "$next_transcript" | grep -qF "          5              10"; then
    echo "FAIL: debug_link(multi-unit-next): missing expected program output"
    next_ok=0
fi
if echo "$next_transcript" | grep -qF "DOUBLE_IT:"; then
    echo "FAIL: debug_link(multi-unit-next): transcript shows the callee's own source -- 'next' should have stayed atomic"
    next_ok=0
fi
if echo "$next_transcript" | grep -qF "returned to caller"; then
    echo "FAIL: debug_link(multi-unit-next): transcript shows a step-into auto-return -- 'next' should never push a frame"
    next_ok=0
fi
if [ "$next_ok" -eq 1 ]; then
    echo "PASS: debug_link(multi-unit-next)"
else
    echo "  transcript: $(printf '%q' "$next_transcript")"
    fail=1
fi

# `step` x6 (to walk EXTPROC's PROGRAM from its first instruction up to,
# but not through, the PCAL into DOUBLE_IT -- one fewer than `next` above
# since the 7th step is the one that descends into the call rather than
# running past it), then a few more `step`s inside the callee (showing
# its own source/instructions), then `continue` to run it to completion
# and auto-return: the transcript must show the callee's own "DOUBLE_IT:"
# source label (proving the debugger actually displayed its source, not
# just resolved the call name), the "returned to caller" auto-pop
# message, and the exact same final program output as the atomic `next`
# case and an ordinary non-debug run.
step_transcript=$(printf 'step\nstep\nstep\nstep\nstep\nstep\nstep\nstep\nstep\ncontinue\nquit\n' | "$YAHALMAT2" --debug "@$listfile2" 2>&1)
rm -rf "$workdir2"

step_ok=1
if ! echo "$step_transcript" | grep -qF "          5              10"; then
    echo "FAIL: debug_link(multi-unit-step): missing expected program output"
    step_ok=0
fi
if ! echo "$step_transcript" | grep -qF "DOUBLE_IT:"; then
    echo "FAIL: debug_link(multi-unit-step): transcript never shows the callee's own source -- 'step' should have descended into it"
    step_ok=0
fi
if ! echo "$step_transcript" | grep -qF "returned to caller"; then
    echo "FAIL: debug_link(multi-unit-step): transcript is missing the step-into auto-return message"
    step_ok=0
fi
if [ "$step_ok" -eq 1 ]; then
    echo "PASS: debug_link(multi-unit-step)"
else
    echo "  transcript: $(printf '%q' "$step_transcript")"
    fail=1
fi

exit $fail
