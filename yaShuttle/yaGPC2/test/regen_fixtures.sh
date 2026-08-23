#!/bin/bash
#
# Regenerate every generated test fixture from a reference simulator.
#
#   ./test/regen_fixtures.sh [REF_ROOT]
#
# REF_ROOT is the root of the gpc checkout to cut fixtures from -- the
# directory holding gpc/ and com/.  It defaults to $YAGPC_REF_ROOT, and
# failing that to yaShuttle/, which is what the generators used before
# this script existed.
#
# WHICH REFERENCE MATTERS.  yaShuttle/gpc and yaShuttle/com are symlinks
# to a frozen checkout, and that frozen gpc still contains bugs that have
# since been fixed upstream -- it computed the RS-form auto-index
# write-back from the effective address instead of the index register's
# own address field, which yaGPC2 inherited and has now fixed.  Fixtures
# cut from a buggy oracle assert the bug, so the suite fails on correct
# code and passes on incorrect code.  Point this at the current upstream
# simulator (a nsts-sim-gpc checkout) unless you specifically want the
# frozen behaviour.
#
# Each fixture is a two-stage pipeline: the .cjs generator builds the
# reference CoffeeScript with esbuild, runs it, and prints JSON; the
# matching _header.py turns that JSON into the C header the tests
# compile against.
#
# NOT COVERED, and reported rather than silently skipped:
#   - gen_cpu_instr_exec_fixtures.cjs and gen_iop_instr_exec_fixtures.cjs
#     take an explicit instruction-name list (and bce|msc) on the command
#     line, so they need a curated argument set this script does not carry.
#   - gen_packedbits_fixtures.cjs has no gen_packedbits_fixtures_header.py
#     of its own; it goes through the generic gen_fixtures_header.py.
#
# BEWARE: as of this writing the committed fixtures do not reproduce from
# EITHER available oracle -- regenerating from the frozen checkout differs
# from the committed cpu_ea/regmem/mcm_membus headers, and regenerating
# from a current nsts-sim-gpc differs far more widely (that simulator has
# moved on, and some of its differences are changed function contracts
# rather than fixes).  Diff before adopting any regenerated header.
set -euo pipefail

cd "$(dirname "$0")"

REF_ROOT="${1:-${YAGPC_REF_ROOT:-$(cd ../.. && pwd)}}"
REF_ROOT="$(cd "$REF_ROOT" && pwd)"

for d in gpc com; do
    [ -d "$REF_ROOT/$d" ] || { echo "regen: $REF_ROOT has no $d/" >&2; exit 1; }
done

echo "regen: reference = $REF_ROOT"
export YAGPC_REF_ROOT="$REF_ROOT"

# The generators require('esbuild'), 'esbuild-coffeescript' and
# '@danielx/civet' to build the reference CoffeeScript/civet sources, and
# nothing up the yaGPC2 tree provides them -- they live in the reference
# checkout's own node_modules.  Take the build toolchain from the same
# place as the sources so the oracle is one coherent checkout.
[ -d "$REF_ROOT/node_modules" ] || {
    echo "regen: $REF_ROOT has no node_modules (run npm install there)" >&2; exit 1; }
export NODE_PATH="$REF_ROOT/node_modules${NODE_PATH:+:$NODE_PATH}"

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

status=0
for gen in gen_*_fixtures.cjs; do
    base="${gen%.cjs}"                 # gen_<name>_fixtures
    name="${base#gen_}"                # <name>_fixtures
    hdr="gen_${name}_header.py"
    [ -f "$hdr" ] || { echo "  SKIP $name (no $hdr)"; continue; }

    printf '  %-32s' "$name"
    if ! node "$gen" > "$tmp/$name.json" 2> "$tmp/$name.err"; then
        echo "GENERATOR FAILED"; sed 's/^/      /' "$tmp/$name.err" >&2; status=1; continue
    fi
    if ! python3 "$hdr" "$tmp/$name.json" > "$tmp/$name.h" 2> "$tmp/$name.hdr.err"; then
        echo "HEADER FAILED"; sed 's/^/      /' "$tmp/$name.hdr.err" >&2; status=1; continue
    fi

    if [ -f "$name.h" ] && cmp -s "$tmp/$name.h" "$name.h"; then
        echo "unchanged"
    else
        cp "$tmp/$name.h" "$name.h"
        echo "UPDATED"
    fi
done

exit $status
