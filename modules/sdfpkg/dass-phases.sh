#!/bin/bash
# Link PASS one CON80 PHASE at a time, cross-resolve the phases against each
# other, and combine them into one memory image per configuration.
#
#     dass-phases.sh <build-tree>          e.g. dass-phases.sh ~/pass-build/OI340700
#
# WHY THIS EXISTS, GIVEN THAT dass-link.sh SCORES HIGHER.
#
# dass-link.sh links a whole configuration in one go and gets every section's
# address from --external-syms, i.e. from the DASS index itself.  That places
# 100% of sections correctly and scores 76-82%.  It cannot, however, resolve a
# reference from one phase into another: FIOADCNS is resident (it sits at 38616
# in all eight configurations) and holds the addresses of display pages that
# live in the GNC phases, and a configuration-at-a-time link has nowhere to get
# those from -- it appends the modules past the end of the image and bakes the
# wrong address into 458 halfwords of FIOADCNS/FIOADCCL.
#
# This pipeline is the structure the ground build actually used, and it fixes
# that class outright.  Its cost is placement: CON80 deck layout puts about 75%
# of sections at the address the dump has, against 100% for --external-syms, so
# it currently scores far lower overall.  The two are complementary, not
# rivals, and the placement gap is the thing to close.
#
# THE PHASE STRUCTURE IS READ OUT OF THE DECKS, NOT ASSUMED:
#     PHASE03 = MAP2 + PATCH03 + MFB3          PHASE14 = MAP2 + PATCH14 + MFB14
#     PHASE04..08 = MAP2 + MAP3 + PATCHnn + GNCn
#     PHASE15 = MAP2 + MAP14 + PATCH15 + SM2   PHASE12 = MAP2 + MAP9 + ... + PL9
# A MAP card is an earlier phase mapped in, and it becomes --map-lib N=PHASE0N.lib.
#
# TWO THINGS THAT MUST BE RIGHT, BOTH MEASURED:
#
#   1. A PHASE MUST BE GIVEN ONLY ITS OWN DECK'S MODULES.  Feeding every object
#      to every phase defines everything locally, leaves no residual cross-phase
#      RLD sites, and phaseresolve then reports "0 site(s) resolved" for all 18
#      phases -- it looks like it ran and it did nothing.  Restricted to their
#      own decks the same run resolves 31,416 sites.
#
#   2. A MAPPED SECTION MUST NOT OVERWRITE THE PHASE THAT CARRIES IT.  A section
#      reached through a MAP card is DEFINED by the later phase but not
#      re-emitted by it, so its range in that phase's image is all zero.
#      Overlaying it blindly buries the real text: 390 sections sat at the right
#      address holding nothing but zeros, and the score was 1.7% instead of
#      31.5%.  dass-combine.py skips a range a phase did not actually emit.
set -e
T=${1:?build tree}
# readlink -f: this names the SIBLING SCRIPTS, and reached through a ~/bin
# symlink dirname "$0" is ~/bin, which only works while every sibling
# happens to be symlinked there as well.
PFS=$(cd "$(dirname "$(readlink -f "$0")")" && pwd)
BIN=${LNK101_BIN:-$HOME/donschmidt/nsts-sdl-dps/build/bin}
SRC=${LNK101_SRC:-$HOME/donschmidt/nsts-sdl-dps}
cd "$T"; mkdir -p phase; rm -f phase/PHASE*.lib phase/PHASE*.fcm phase/PHASE*.sym.json

python3 "$PFS/dass-phaselists.py" "$T"

for spec in "01:" "10:" "02:" "13:" "03:2" "04:2,3" "05:2,3" "06:2,3" "07:2,3" \
            "08:2,3" "09:2" "14:2" "12:2,9" "15:2,14" "16:2,14" "18:2,3"; do
  p=${spec%%:*}; maps=${spec##*:}
  [ -s phase/objlist-$p.txt ] || continue
  ml=""; for n in ${maps//,/ }; do ml="$ml --map-lib $n=phase/PHASE$(printf %02d $n).lib"; done
  printf "PHASE%s " $p
  "$BIN/lnk101" "@phase/objlist-$p.txt" --concard CON80 --concard-root PHASE$p \
     -L SYSLIBL1 -L lib/runtime/RUN -L lib/runtime/ZCON $ml --allow-undefined \
     -o phase/PHASE$p.fcm --lib phase/PHASE$p.lib --json-symbols phase/PHASE$p.sym.json \
     > phase/PHASE$p.log 2>&1 && echo "ok" || { echo FAILED; exit 1; }
done

( cd "$SRC" && PYTHONPATH=src python3 -m lnk101.phaseresolve \
      --con80 "$T/CON80" "$T"/phase/PHASE*.lib ) | grep -E '^PHASE'

DASS_TREE="$T" python3 "$PFS/dass-combine.py" SSW G16 G2 G3 G8 G9 P9 S2
