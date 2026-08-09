#!/bin/bash
# Collect every diagnostic ASM101S emits over the FCOS corpus, one file per
# module, so that they can be counted across the whole corpus rather than read
# one module at a time.
#
# WHY THIS EXISTS.  fcos-sweep.sh classifies a module by exit status --
# OK/ERRORS/CRASH/HANG -- which was the right instrument while most modules
# were crashing.  It is the wrong one now that most of them assemble far enough
# to complain: a module that produces 300 diagnostics and one that produces 2
# are both just "ERRORS", and a defect that produces a WRONG ANSWER WITHOUT
# COMPLAINING is invisible to it entirely.  Several of the defects found in
# August 2026 were exactly that shape, silently wrong for years while RUNASM
# stayed at 205 of 205.
#
# Each diagnostic is emitted once per assembly pass, so the same complaint
# appears up to three times with different "Pass N" prefixes.  Count one pass,
# not all of them; fcos-diagnostics.py does that.
#
# Usage:
#     fcos-diagnostics.sh OUTDIR [VERSION ...]
#
#     FCOS_TIMEOUT   seconds per module, default 900.  Do not lower it much:
#                    DCICYC alone needs 861s and a module killed part-way
#                    contributes a truncated diagnostic list.
set -u
OUTDIR=${1:?usage: fcos-diagnostics.sh OUTDIR [VERSION ...]}
shift
VERS=${*:-OI340600}
PFS=~/workspace/PFS
export FCOS_TIMEOUT=${FCOS_TIMEOUT:-900}
export OUTDIR

mkdir -p "$OUTDIR"
for V in $VERS; do
    D="$PFS/$V/SSSRC"
    [ -d "$D" ] || { echo "missing $D" >&2; continue; }
    for f in "$D"/*.asm; do
        printf '%s\t%s\n' "$V" "$(basename "$f" .asm)"
    done
done | xargs -P 6 -n 2 bash -c '
    V=$0; m=$1
    PFS=~/workspace/PFS
    cd "$PFS/$V/SSSRC" || exit 1
    # --object must end in .obj or ASM101S rejects it before assembling a line.
    obj=$(mktemp --suffix=.obj)
    out="$OUTDIR/$V.$m.diag"
    timeout -k 5 "$FCOS_TIMEOUT" \
        ASM101S --library=../MLIB80 --tolerable=4 --object="$obj" "$m.asm" 2>&1 \
        | grep -E "^\(Pass -?[0-9]+, Severity [0-9]+\)" > "$out"
    rc=${PIPESTATUS[0]}
    printf "%s\t%s\t%s\t%s\n" "$V" "$m" "$rc" "$(wc -l < "$out")"
    rm -f "$obj"
' > "$OUTDIR/index.tsv"
echo "DONE -> $OUTDIR ($(wc -l < "$OUTDIR/index.tsv") modules)"
