#!/bin/bash
# Build a GPCIPL (IPL) flight image from the OI340600 sources.
#
# What changed, and why this looks different from the previous version
# --------------------------------------------------------------------
# This used to link phase 10's modules straight into an .fcm with lnk101,
# and then bolt a store-protect map on afterwards with a helper of our own
# (tools/add_store_protect.py, now deleted).  That helper existed because
# mmu2fcm's unionSym() composed the final .sym.json from an explicit key
# list and never carried `storeProtect` across from the constituent
# phases, so a composed image could not get a real map by relinking.  The
# map we synthesised instead was a blanket sweep of every loaded section --
# not what the linker would emit, as its own docstring admitted.
#
# Both halves of that are now fixed upstream in nsts-sdl-dps:
#
#   7fff229  lnk101: carry store-protect ranges into .sym.json
#   0846b59  tools: union the store-protect map into the composed image
#            (masked per phase to the halfwords it still owns, and omitted
#             entirely when no phase carries one)
#
# So the real map -- which honours explicit PROT ranges and per-csect
# marks, rather than protecting whole sections -- now arrives on its own.
# For phase 10 that is 9 halfword ranges covering 27,275 halfwords.  This
# matters: gpc refuses to IPL an image whose protection is wrong, and a
# blanket map protects the runtime's own scratch cells.
#
# The composition step is also different.  Rather than lnk101 -o writing
# just the loaded extents, mmu2fcm emulates the IPL/SSL load itself --
# background fill, load blocks placed at their linked addresses, later
# phases overlaying earlier ones -- and emits a whole 512K-halfword memory
# image.  That is the shape Don Schmidt's own tools/mkfcm.sh produces, and
# it is what the reference emulator is fed.
#
# How good is the result
# ----------------------
# Measured against the IPL.fcm we have been testing with: of 1,048,576
# bytes, SIX differ.  They are four halfwords in FCMINSSL at 0x0735E,
# where the reference has 832A 0006 / A32A 0006 and this build has
# 8000 0000 / A000 0000 -- the two unrelocated address constants for
# FIOMUWB2.  That symbol lives in DEUIPLCP, which phase 2 builds as an
# OVERLAY, so it stays undefined here and --allow-undefined is required.
# Nothing else in the image differs at all.
#
# What it needs
# -------------
# A tree of linked phase load modules, in con80build's own layout:
#   <root>/PHASEnn.lib              (top level -- this is what mmu2fcm reads)
#   <root>/PHASEnn/PHASEnn.sym.json (subdirectory -- note the asymmetry)
# Phase 10 alone is NOT enough: mmu2fcm resolves phase 10's parent Z1 pool
# from PHASE02.lib, so phase 2 must be present too.
#
# Usage:  tools/build_ipl_fcm.sh <phase-lib-root> [OUTDIR]
set -euo pipefail

SRC="${PFS_OI340600:-$HOME/workspace/PFS/OI340600}"
SDL="${SDL_ROOT:-$HOME/donschmidt/nsts-sdl-dps}"
BIN="${SDL_BIN:-$SDL/build/bin}"
PY="${SDL_PY:-$SDL/build/venv/bin/python}"

ROOT="${1:?usage: build_ipl_fcm.sh <phase-lib-root> [OUTDIR]}"
OUT="${2:-$ROOT/IPL-build}"

MODULES="BILDNEW5 FAZ2 FCMCKSUM FCMINBCE FCMINMSC FCMINSSL FCMSSLPT
         LOADTBL MENU12 MMULDTBL MMUPURTB"

[ -d "$SRC/SSSRC" ]        || { echo "no sources at $SRC/SSSRC" >&2; exit 1; }
[ -x "$BIN/lnk101" ]       || { echo "no lnk101 at $BIN" >&2; exit 1; }
[ -f "$ROOT/PHASE02.lib" ] || { echo "need PHASE02.lib in $ROOT (parent pool)" >&2; exit 1; }

mkdir -p "$ROOT/PHASE10/obj" "$OUT"

echo "assembling phase 10"
cd "$SRC"
for m in $MODULES; do
    "$BIN/asm101" -L MLIB80 -L SSSRC -L INCL80 \
                  -o "$ROOT/PHASE10/obj/$m.obj" "SSSRC/$m.asm" > "$OUT/$m.log" 2>&1
done

# --allow-undefined is for FIOMUWB2 alone; see the header.  --lib writes the
# load module mmu2fcm reads; --json-symbols now carries the store-protect map.
echo "linking phase 10"
"$BIN/lnk101" --concard CON80 --concard-root PHASE10 --allow-undefined \
    -o "$ROOT/PHASE10/PHASE10.fcm" \
    --json-symbols "$ROOT/PHASE10/PHASE10.sym.json" \
    --lib "$ROOT/PHASE10.lib" \
    "$ROOT/PHASE10/obj"/*.obj > "$OUT/link.log" 2>&1

echo "composing the IPL image"
PYTHONPATH="$SDL/src" "$PY" "$SDL/src/tools/mmu2fcm.py" \
    --mmu "$ROOT" --config IPL --phases 10 \
    --con80 "$SRC/CON80" --out "$OUT" --stamp-checksums

echo
echo "built $OUT/IPL.fcm"
"$PY" - "$OUT/IPL.sym.json" <<'EOF'
import json, sys
d = json.load(open(sys.argv[1]))
sp = d.get("storeProtect")
print("  sections:      %d" % len(d.get("sections", [])))
print("  entry point:   %s" % d.get("entryPoint"))
if sp:
    n = sum(hi - lo for lo, hi in sp["ranges"])
    print("  store protect: %d halfwords in %d ranges" % (n, len(sp["ranges"])))
else:
    print("  store protect: NONE -- relink the phases with a current lnk101")
EOF
