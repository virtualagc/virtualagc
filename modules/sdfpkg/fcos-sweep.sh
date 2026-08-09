#!/bin/bash
# Assemble every FCOS .asm in PFS/<VER>/SSSRC with ASM101S and classify the
# outcome, one TSV row per module: version, module, exit status, class, detail.
#
# BOTH streams matter and neither alone is enough.  ASM101S writes its listing
# and its diagnosed errors ("Severity 255", "N intolerable line(s)") to STDOUT,
# and dies with a Python traceback on STDERR.  A sweep that reads only one of
# them reports every module as an undifferentiated failure, which is what the
# first version of this script did.
#
# A module that never terminates is the one failure a sweep cannot survive: it
# blocks the run, which then reports DONE with a row missing and no sign of it.
# So every assembly is run under `timeout`, and a module that exceeds it is
# classified HANG rather than silently dropped.  FCOS_TIMEOUT overrides the
# default.
set -u
OUT=${1:?usage: fcos-sweep.sh OUTFILE [VERSION ...]}
shift
VERS=${*:-"OI340600 OI301700"}
PFS=~/workspace/PFS
export FCOS_TIMEOUT=${FCOS_TIMEOUT:-120}

: > "$OUT"
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
    # The object name MUST end in .obj -- ASM101S rejects anything else before
    # it assembles a line, and a bare mktemp name makes every module fail
    # identically in a way that looks like a result.
    so=$(mktemp); se=$(mktemp); obj=$(mktemp --suffix=.obj)
    timeout -k 5 "$FCOS_TIMEOUT" \
    ASM101S --library=../MLIB80 --tolerable=4 --object="$obj" "$m.asm" \
        > "$so" 2> "$se"
    rc=$?
    if [ "$rc" -eq 124 ] || [ "$rc" -eq 137 ]; then
        class=HANG
        detail="no output after ${FCOS_TIMEOUT}s"
    elif grep -q "Traceback" "$se"; then
        class=CRASH
        detail=$(grep -E "^[A-Za-z_.]*Error|^[A-Za-z]*Exception" "$se" | tail -1)
        where=$(grep -oE "\"[^\"]+\", line [0-9]+" "$se" | tail -1)
        detail="$detail @ $where"
    elif [ "$rc" -ne 0 ]; then
        class=ERRORS
        detail=$(grep -oE "[0-9]+ intolerable line\(s\)" "$so" | tail -1)
        top=$(grep -oE "\(Pass [0-9]+, Severity [0-9]+\) .*" "$so" \
              | sed "s/(Pass [0-9]*, //" | sort | uniq -c | sort -rn \
              | head -1 | sed "s/^ *//")
        detail="$detail; commonest: $top"
    else
        class=OK
        detail=""
    fi
    printf "%s\t%s\t%s\t%s\t%s\n" "$V" "$m" "$rc" "$class" "$detail"
    rm -f "$so" "$se" "$obj"
' >> "$OUT"
echo "DONE -> $OUT ($(wc -l < "$OUT") rows)"
