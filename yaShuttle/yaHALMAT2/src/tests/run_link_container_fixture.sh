#!/usr/bin/env bash
# Round-trips an @list through `yaHALMAT2 --link-only` (building a self-
# contained, compressed linked-archive container -- see
# reengineered-documentation/MULTI-FILE-LINKING.md's container-format
# section) and back, diffing yaHALMAT2's container-run output against the
# expected string. Supports both ways an @list gets built elsewhere in
# this test suite:
#   --plain : one independently-compiled directory per unit, no TEMPLIB/
#             INCLUDE TEMPLATE step -- same pattern as run_link_fixture.sh
#             (the EXTERNAL COMPOOL case).
#   --tmpl  : all units compiled in one shared directory via
#             --parms=TEMPLATE, FUNCTION/PROCEDURE units first and the
#             PROGRAM unit last -- same pattern as run_ext_func_fixture.sh
#             (the EXTERNAL FUNCTION/PROCEDURE case).
#
# Also asserts the resulting container file is small -- MAX_BYTES is
# caller-supplied rather than a single hardcoded number, since a
# multi-unit container legitimately embeds one COMMON*.out symbol-table
# text blob per unit (tens of KB each, real declared-symbol content, see
# MULTI-FILE-LINKING.md) and so is naturally larger than a minimal single-
# unit fixture -- but every case here should still be orders of magnitude
# under the 16MB COMMONn.out.bin.gz memory image this container format
# specifically avoids ever embedding (see literal.c's HALMAT_MEM_IMAGE_MAX
# and this project's own measurements in MULTI-FILE-LINKING.md). A
# regression that reintroduced that 16MB blob would blow through any of
# these caps by two orders of magnitude, so this still catches it.
#
# Usage:
#   run_link_container_fixture.sh --plain MAX_BYTES EXPECTED_OUTPUT NAME1 [NAME2 ...]
#   run_link_container_fixture.sh --tmpl MAX_BYTES EXPECTED_OUTPUT PROG_NAME FUNC_NAME1 [FUNC_NAME2 ...]
# Each NAME must have a src/tests/hal/test_NAME.hal source file.
set -euo pipefail

HALSFC="/home/rburkey/git/virtualagc/yaShuttle/Source Code/PASS.REL32V0/HALSFC"
HAL_SRC_DIR="$(dirname "$0")/hal"
YAHALMAT2="$(dirname "$0")/../yaHALMAT2"

mode="$1"; shift
max_bytes="$1"; shift
expected="$1"; shift
argsdesc="$*"

workdir=$(mktemp -d)
trap 'rm -rf "$workdir"' EXIT
listfile="$workdir/list.txt"
: > "$listfile"

case "$mode" in
    --plain)
        for name in "$@"; do
            unitdir="$workdir/$name"
            mkdir -p "$unitdir"
            cp "$HAL_SRC_DIR/test_$name.hal" "$unitdir/"
            ( cd "$unitdir" && "$HALSFC" "test_$name.hal" >/dev/null )
            echo "$unitdir" >> "$listfile"
        done
        ;;
    --tmpl)
        prog_name="$1"; shift
        for name in "$@"; do
            cp "$HAL_SRC_DIR/test_$name.hal" "$workdir/"
            ( cd "$workdir" && "$HALSFC" --clean --archive --parms=TEMPLATE "test_$name.hal" >/dev/null )
            readlink -f "$workdir/current.results" >> "$listfile"
        done
        cp "$HAL_SRC_DIR/test_$prog_name.hal" "$workdir/"
        ( cd "$workdir" && "$HALSFC" --clean --archive "test_$prog_name.hal" >/dev/null )
        readlink -f "$workdir/current.results" >> "$listfile"
        ;;
    *)
        echo "usage: $0 --plain|--tmpl MAX_BYTES EXPECTED_OUTPUT NAME..." >&2
        exit 2
        ;;
esac

label="link_container($mode $argsdesc)"

container="$workdir/out.yhla"
"$YAHALMAT2" --link-only "$container" "@$listfile" >/dev/null

container_bytes=$(wc -c < "$container")
if [ "$container_bytes" -ge "$max_bytes" ]; then
    echo "FAIL: $label (container too large)"
    echo "  container is $container_bytes bytes, expected well under $max_bytes -- this guards"
    echo "  against ever again embedding the 16MB COMMONn.out.bin.gz memory image verbatim"
    echo "  (see reengineered-documentation/MULTI-FILE-LINKING.md's container-format section)"
    exit 1
fi

actual=$("$YAHALMAT2" "$container")

if [ "$actual" = "$expected" ]; then
    echo "PASS: $label ($container_bytes bytes)"
    exit 0
else
    echo "FAIL: $label"
    echo "  expected: $(printf '%q' "$expected")"
    echo "  actual:   $(printf '%q' "$actual")"
    exit 1
fi
