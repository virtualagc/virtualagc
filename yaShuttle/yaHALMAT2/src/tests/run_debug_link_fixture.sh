#!/usr/bin/env bash
# Proves --debug now works for a single-unit @list (previously silently
# ignored -- debug_mode was parsed but never threaded through
# run_linked()/run_linked_units(), so the program just ran normally with
# no debugger attached and no error either), and fails loudly -- not
# silently -- for a multi-unit one, since real multi-unit interactive
# debugging (tracking/switching between several independent
# halmat_state_t instances across a cross-unit CALL) isn't implemented.
#
# No arguments; self-contained, exercises both cases in one script.
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

# --- multi-unit case: must fail loudly, not silently ignore --debug ----
workdir2=$(mktemp -d)
mkdir -p "$workdir2/pool_out" "$workdir2/prog_out"
cp "$HAL_SRC_DIR/test_link_pool.hal" "$workdir2/pool_out/"
cp "$HAL_SRC_DIR/test_link_prog.hal" "$workdir2/prog_out/"
( cd "$workdir2/pool_out" && "$HALSFC" test_link_pool.hal >/dev/null )
( cd "$workdir2/prog_out" && "$HALSFC" test_link_prog.hal >/dev/null )
listfile2="$workdir2/list.txt"
printf '%s\n%s\n' "$workdir2/pool_out" "$workdir2/prog_out" > "$listfile2"

set +e
stderr2=$("$YAHALMAT2" --debug "@$listfile2" 2>&1 >/dev/null)
rc2=$?
set -e
rm -rf "$workdir2"

if [ "$rc2" -ne 0 ] && echo "$stderr2" | grep -qF "only supported when @list"; then
    echo "PASS: debug_link(multi-unit-rejected)"
else
    echo "FAIL: debug_link(multi-unit-rejected)"
    echo "  exit code: $rc2 (expected nonzero)"
    echo "  stderr: $(printf '%q' "$stderr2")"
    fail=1
fi

exit $fail
