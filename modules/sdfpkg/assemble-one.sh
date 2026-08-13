#!/bin/bash
# Assemble ONE module from a PFS release with the same macro library the sweeps
# build, and -- for OI301700, which has them -- compare against its as-received
# listing.
#
#     assemble-one.sh MODULE [RELEASE] [extra ASM101S args...]
#
# RELEASE defaults to OI301700.  For OI340600 there ARE no assembly listings,
# so no `--compare` is passed and the run is checked by LINKING instead; see
# HANDOFF-OI340600.md.
#
# WHY THE LIBRARY IS BUILT RATHER THAN NAMED.  ASM101S wants one directory
# holding every COPY member and a MACROFILES.txt index of it, and a release
# spreads them over MLIB80, INCL80 and INCLIB.  The directory is symlinks, so
# it costs nothing and always reflects the release as it stands.
#
#   *** SYMLINKS WRITE THROUGH. ***  Anything that edits a file in the assembled
#   library is editing the real member in PFS.  Read only.
#
# The library is rebuilt per run, which takes a second or two.  For a sweep of
# many modules, build it once with `--library=DIR` and pass that instead.
set -u
PFS=~/workspace/PFS
VAGC=~/git/virtualagc
OUTDIR=${OUTDIR:-.}

m="${1:?usage: assemble-one.sh MODULE [RELEASE] [ASM101S args...]}"; shift
REL=OI301700
if [[ $# -gt 0 && "$1" != -* ]]; then REL="$1"; shift; fi

MLIB=$(mktemp -d) || exit 1
trap 'rm -rf "$MLIB"' EXIT
for d in "$PFS/$REL"/MLIB80 "$PFS/$REL"/INCL80 "$PFS/$REL"/INCLIB; do
    [ -d "$d" ] || continue
    for f in "$d"/*; do
        b=$(basename "$f")
        [ "$b" = MACROFILES.txt ] && continue
        [ -f "$f" ] && ln -sf "$f" "$MLIB/$b"
    done
done
rm -f "$MLIB/MACROFILES.txt"
( cd "$MLIB" && python3 "$VAGC/ASM101S/makeMACROFILES.py" ) \
    > "$MLIB/MACROFILES.txt.tmp" && mv "$MLIB/MACROFILES.txt.tmp" "$MLIB/MACROFILES.txt"

COMPARE=()
LST="$PFS/$REL as received/SSSRC/$m"
# An as-received file is a LISTING only where the release has one.  OI340600's
# are source card images -- no addresses, no object code -- and comparing
# against them would be meaningless rather than merely empty.
if [ -f "$LST" ] && grep -qE '^.[0-9A-F]{5} [0-9A-F]{4}' "$LST" 2>/dev/null; then
    COMPARE=(--compare="$LST")
fi

cd "$PFS/$REL/SSSRC" || exit 1
# A TIMEOUT, because one module that hangs otherwise stops the run without
# saying so, and `python3 -u`, because a killed command loses ALL of its piped
# output rather than the tail of it.
timeout -k 5 1800 python3 -u "$VAGC/ASM101S/ASM101S.py" \
    --library="$MLIB" --tolerable=4 --object="$OUTDIR/$m.obj" \
    "${COMPARE[@]}" "$@" "$m.asm" > "$OUTDIR/$m.lst" 2>&1
rc=$?
echo "exit=$rc  listing: $OUTDIR/$m.lst  object: $OUTDIR/$m.obj"
[ ${#COMPARE[@]} -gt 0 ] || echo "(no listing for $REL; nothing was compared)"
tail -3 "$OUTDIR/$m.lst"
exit $rc
