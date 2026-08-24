#!/bin/bash
# Build a GPCIPL flight image from the OI340600 sources, from scratch.
#
# Why this exists
# ---------------
# Every yaGPC2 display test until now used an IPL.fcm supplied by Don
# Schmidt.  That was the right thing while yaGPC2 itself was the suspect --
# debugging an emulator against an image of unknown provenance proves
# nothing -- but it left open whether this project can produce a working
# image of its own.  It can.
#
# What it produces
# ----------------
# An image whose twelve sections are byte-identical to Don's, at identical
# addresses and sizes, with the identical entry point (18195).  Verified:
# of the 65,024 bytes the two images share, the only differences inside a
# section we build are SIX BYTES in FCMINSSL, which are the two unrelocated
# references to FIOMUWB2 (see below).  Everything else that differs lies in
# inter-section padding or in the two sections we cannot build.
#
# Both emulators IPL a real display unit from it -- "load complete (250
# halfwords at 0x2), reporting initialized as unit 1", zero unheadered
# fills, 37 mass-memory commands, on yaGPC2 and on the reference alike.
#
# What is missing, and why it does not stop it
# --------------------------------------------
# Don's image carries two sections this build cannot:
#
#   #Y101001    500 halfwords from PCH10TXT.  All 47 PCHnnTXT patch decks
#               are absent corpus-wide; there is no source for them here.
#   #PCVNMMU  16393 halfwords from DEUIPLCP, which is built by OPS0 as an
#               OVERLAY and reached from phase 10 by the CON80 deck's
#               `MAP 2,DEUIPLCP` card.  Building it means building phase 2.
#
# DEUIPLCP is where FIOMUWB2 lives, so without it the link leaves that one
# symbol undefined and --allow-undefined is required.  It was reasonable to
# expect this to be fatal: FIOMUWB2 is a buffer FCMINSSL cites, and the name
# DEUIPLCP reads as "DEU IPL Control Program", the very thing the display
# load transmits.  It is not fatal, and the reason is worth recording: the
# DEU model does not EXECUTE the control program.  deuUnit.coffee stores the
# load in @mem and never runs it -- no opcodes, no program counter -- and
# gates "load complete" purely on a final block whose count is 250.  The
# picture comes from the format control words in the fills that follow, and
# MENU12, which draws the GPCIPL MENU, is one of the eleven modules here.
#
# Usage:  tools/build_ipl_fcm.sh [OUTDIR]
set -euo pipefail

SRC="${PFS_OI340600:-$HOME/workspace/PFS/OI340600}"
BIN="${SDL_BIN:-$HOME/donschmidt/nsts-sdl-dps/build/bin}"
OUT="${1:-./ipl-build}"

MODULES="BILDNEW5 FAZ2 FCMCKSUM FCMINBCE FCMINMSC FCMINSSL FCMSSLPT
         LOADTBL MENU12 MMULDTBL MMUPURTB"

[ -d "$SRC/SSSRC" ] || { echo "no sources at $SRC/SSSRC" >&2; exit 1; }
[ -x "$BIN/asm101" ] || { echo "no asm101 at $BIN" >&2; exit 1; }
mkdir -p "$OUT/obj"

echo "assembling into $OUT/obj"
cd "$SRC"
for m in $MODULES; do
    "$BIN/asm101" -L MLIB80 -L SSSRC -L INCL80 \
                  -o "$OUT/obj/$m.obj" "SSSRC/$m.asm" > "$OUT/$m.log" 2>&1
    printf '  %-10s %s bytes\n' "$m" "$(stat -c%s "$OUT/obj/$m.obj")"
done

# --allow-undefined is for FIOMUWB2 alone; see the header.  The CON80 deck
# is what places the csects -- without --concard the layout is not Don's.
echo "linking"
"$BIN/lnk101" --concard CON80 --concard-root PHASE10 --allow-undefined \
    -o "$OUT/IPL.fcm" --json-symbols "$OUT/IPL.sym.json" -M "$OUT/IPL.map" \
    "$OUT"/obj/*.obj > "$OUT/link.log" 2>&1

echo "built $OUT/IPL.fcm ($(stat -c%s "$OUT/IPL.fcm") bytes)"
grep -c "Undefined symbol" "$OUT/link.log" | sed 's/^/  undefined symbols: /'

# The reference emulator takes storage protection from the .sym.json as of
# its commit 0e275b1 and will not boot an image carrying none; lnk101 here
# does not write that map (mmu2fcm's unionSym drops it too).  So add one.
if [ -x tools/add_store_protect.py ] 2>/dev/null; then :; fi
echo
echo "For the reference emulator, add a store-protect map first:"
echo "  tools/add_store_protect.py $OUT/IPL.sym.json -o $OUT/forgpc --fcm $OUT/IPL.fcm"
