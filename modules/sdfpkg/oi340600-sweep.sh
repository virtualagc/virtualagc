#!/bin/bash
# Assemble every OI340600 module and classify the outcome, one TSV row per
# module: module, exit status, class, detail.
#
# THIS IS NOT verify-sweep.sh AND CANNOT BECOME IT.  That script compares each
# OI301700 module against its own contemporary listing, which settles the bytes.
# OI340600 HAS NO LISTINGS -- its "as received" directory holds source card
# images, no addresses and no object code -- so the only question this script
# can answer is whether ASM101S has anything to COMPLAIN about.  A module that
# exits 0 here has established that and nothing more; the bytes are settled by
# LINKING the objects with lnk101 and comparing the image against the DASS
# memory dumps.  See HANDOFF-OI340600.md.
#
# THE LIBRARY IS MLIB80, USED WHERE IT SITS.  Nothing is built, copied or
# symlinked.  MLIB80 is the assembler's macro library and it already carries its
# own MACROFILES.txt -- 210 of its 278 members are read as open code -- so
# there is nothing for this script to prepare.  INCL80 and INCLIB BELONG TO THE
# HAL/S COMPILER, not to the assembler, and have no part in assembling these
# modules; merging all three was tried here first and added 560 member names
# that no OI340600 source or MLIB80 member ever COPYs.  (User's correction,
# 2026-08-12.  Note that assemble-one.sh and verify-sweep.sh still build a
# merged library; that is OI301700's arrangement and is not evidence about
# this one.)
#
# PFS is somebody else's repository and is not written to.  Using MLIB80 in
# place rather than through a directory of symlinks is also what removes the
# write-through hazard that truncated its real MACROFILES.txt twice.
set -u
OUT=${1:?usage: oi340600-sweep.sh OUTFILE}
REL=${2:-OI340600}
PFS=~/workspace/PFS
SRC="$PFS/$REL/SSSRC"
MLIB="$PFS/$REL/MLIB80"
# 1800s, matching verify-sweep.sh.  Every module reads 210 macro definitions
# ahead of itself, and the slowest module of the OI301700 corpus exceeded 1200s
# while being merely slow.  A HANG should mean hung.
export SWEEP_TIMEOUT=${SWEEP_TIMEOUT:-1800}

[ -d "$SRC" ] || { echo "missing $SRC" >&2; exit 1; }
[ -f "$MLIB/MACROFILES.txt" ] || { echo "missing $MLIB/MACROFILES.txt" >&2; exit 1; }
echo "library: $MLIB -- $(ls "$MLIB" | wc -l) members, $(grep -vc '^;' "$MLIB/MACROFILES.txt") read as open code" >&2

# Where the objects and listings go, because the linking half of this phase
# needs the objects and re-assembling the corpus to get them back is 20 minutes.
# THE LISTINGS ARE KEPT for a reason: a Severity 0 message on pass 1 is a
# forward reference and normal, the same message on a compile pass is not, and
# the pass number is only in the listing.
OBJDIR=${OBJDIR:-$(dirname "$OUT")/obj-$REL}
mkdir -p "$OBJDIR"
export MLIB SRC OBJDIR

: > "$OUT"
# BILDNEW5 IS OUT OF SCOPE and must not be swept.  It never completes: it
# takes the full SWEEP_TIMEOUT and is then reported HANG, which is 30
# minutes added to every run and one row of noise in every result.  Skipping
# it by name here rather than leaving it to be remembered each time.
SKIP='^BILDNEW5$'
ls "$SRC"/*.asm | xargs -n 1 basename | sed 's/\.asm$//' | grep -Ev "$SKIP" \
  | xargs -P 6 -n 1 bash -c '
    m=$0
    cd "$SRC" || exit 1
    # STDERR IS KEPT beside the listing, not discarded with a mktemp.  It is
    # where tracebacks land, and now also where ASM101S reports a library
    # member that exists but is not indexed -- a warning that is useless if
    # the file it was written to is deleted before anyone reads it.
    se="$OBJDIR/$m.err"
    timeout -k 5 "$SWEEP_TIMEOUT" \
    ASM101S --library="$MLIB" --tolerable=4 --object="$OBJDIR/$m.obj" \
            "$m.asm" > "$OBJDIR/$m.lst" 2> "$se"
    rc=$?
    so="$OBJDIR/$m.lst"
    # BOTH streams matter.  Diagnosed errors go to stdout with the listing; a
    # Python traceback goes to stderr.  A sweep reading one of them reports
    # every module as an undifferentiated failure.
    if [ "$rc" = 124 ] || [ "$rc" = 137 ]; then
        class=HANG; detail="exceeded ${SWEEP_TIMEOUT}s"
    elif grep -q Traceback "$se"; then
        class=CRASH
        detail="$(grep -E "^[A-Za-z_.]*Error|^[A-Za-z]*Exception" "$se" | tail -1) @ $(grep -oE "\"[^\"]+\", line [0-9]+" "$se" | tail -1)"
    elif grep -qi "for COPY not found" "$so" "$se"; then
        class=NOCOPY; detail=$(grep -hi "for COPY not found" "$so" "$se" | sort -u | tr "\n" ";" | cut -c1-200)
    elif [ "$rc" != 0 ]; then
        class=ERRORS
        n=$(grep -oE "[0-9]+ intolerable line\(s\)" "$so" | tail -1)
        top=$(grep -oE "\(Pass -?[0-9]+, Severity [0-9]+\) .*" "$so" \
              | sort | uniq -c | sort -rn | head -1 | sed "s/^ *//" | cut -c1-120)
        detail="$n; commonest: $top"
    else
        # Exit 0 is not silence, and the pass number decides which messages
        # matter.  Passes 1 and 2 collect, so an undefined symbol there is a
        # forward reference; passes 3 and up compile, so the same message there
        # is a symbol that never got defined.
        late=$(grep -oE "\(Pass [0-9]+, Severity [0-9]+\)" "$so" \
               | awk -F"[ ,]" "{if (\$2+0 >= 3) n++} END {print n+0}")
        early=$(grep -cE "\(Pass -?[0-9]+, Severity [0-9]+\)" "$so")
        if [ "$late" != 0 ]; then
            class=OK-LATE
            detail="$late on a compile pass: $(grep -oE "\(Pass [0-9]+, Severity [0-9]+\) .*" "$so" | awk -F"[ ,]" "\$2+0 >= 3" | sort | uniq -c | sort -rn | head -1 | sed "s/^ *//" | cut -c1-120)"
        elif [ "$early" != 0 ]; then
            class=OK-EARLY; detail="$early on collect passes only"
        else
            class=OK; detail=""
        fi
    fi
    printf "%s\t%s\t%s\t%s\n" "$m" "$rc" "$class" "$detail"
    # $se is $OBJDIR/$m.err now and is deliberately retained; see above.
' >> "$OUT"
echo "DONE: $(wc -l < "$OUT") rows in $OUT; objects and listings in $OBJDIR"
awk -F'\t' '{print $3}' "$OUT" | sort | uniq -c | sort -rn
