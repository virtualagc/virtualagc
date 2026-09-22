#!/bin/bash
# Build the PATCHED REFERENCE that the CPU instruction fixtures are cut from.
#
#   ./make_patched_ref.sh [<gpc-root>] [<out-dir>]
#
# The fixtures in test/cpu_instr_exec_fixtures.h are generated from Don
# Schmidt's gpc -- the reference implementation this emulator was ported from
# -- but not from it verbatim.  Five places have been found where the
# reference is wrong and yaGPC2 is right, each with its own measured evidence
# in src/cpu_instr.c or src/cpu.c and each restated in the header comment of
# test/test_cpu_instr_exec.c: SVC's 19-bit effective address, CVFX storing its
# result before the interrupt, g_EA's B2 == 11 rule, g_EA's double-indirect
# expansion, and BAL/SCAL snapshotting the link before the EA is formed.
#
# Generating fixtures from an unpatched reference reintroduces all five as
# test failures, and re-deriving them costs a day.  They were living only in a
# scratch copy under /tmp, which is exactly the sort of step that gets
# forgotten, so they are checked in as patches against upstream and applied by
# this script.
#
# Then, from yaShuttle/yaGPC2:
#
#   ./test/make_patched_ref.sh
#   YAGPC_REF_ROOT=<out-dir> NODE_PATH=<gpc-root>/node_modules \
#       node test/gen_cpu_instr_exec_fixtures.cjs $(names) > fixtures.json
#   python3 test/gen_cpu_instr_exec_fixtures_header.py fixtures.json \
#       > test/cpu_instr_exec_fixtures.h
#
# where $(names) is the 135 instruction names the header's own dispatch table
# lists:
#
#   grep -oE '\{ "[A-Z0-9]+", EXEC_FIXTURES_' test/cpu_instr_exec_fixtures.h \
#       | sed 's/{ "//;s/", EXEC_FIXTURES_//'
#
# IF A PATCH NO LONGER APPLIES, upstream has changed that code.  Do not force
# it: read what changed first, because the likeliest reason is that Don has
# fixed the same defect, in which case the patch should be dropped rather than
# rebased.  Issue ColanderCombo/nsts-sim-gpc#34 is the model for reporting one.
set -u

REF="${1:-$HOME/donschmidt/nsts-sim-gpc}"
OUT="${2:-${TMPDIR:-/tmp}/yagpc2-refpatched}"
HERE="$(cd "$(dirname "$0")" && pwd)"

if [ ! -d "$REF/gpc" ]; then
    echo "no gpc/ under $REF -- give the reference root as argument 1" >&2
    exit 1
fi

rm -rf "$OUT"
mkdir -p "$OUT"
cp -r "$REF/gpc" "$REF/com" "$OUT/" || exit 1
# esbuild resolves `com/lru` through the reference's own tsconfig.json, and
# node finds its packages through the real node_modules; a symlink keeps this
# copy small.
cp "$REF/tsconfig.json" "$REF/package.json" "$OUT/" 2>/dev/null
ln -sfn "$REF/node_modules" "$OUT/node_modules"

for p in "$HERE"/refpatches/*.patch; do
    f="$(basename "$p" .patch)"
    if ! patch -s -p0 -d "$OUT/gpc" "$f" < "$p"; then
        echo "FAILED to apply $(basename "$p") -- see this script's header" >&2
        exit 1
    fi
    echo "applied $(basename "$p")"
done

echo "patched reference ready: $OUT"
