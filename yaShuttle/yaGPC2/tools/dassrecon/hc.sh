#!/bin/bash
# hc.sh STEM [SUBDIR]: compile one unit in the scratch tree ($DASSRECON_TREE) as compilePASS does
# (--sdl, --release=OI340700), with a fresh second each time: HALSFC names its results folder by it.
STEM=$1; SUB=${2:-APPLSRC}
PR="$HOME/git/virtualagc/yaShuttle/Source Code/PASS.REL32V0"
export PATH="$PR:$HOME/git/virtualagc/ASM101S:$PATH"
TREE=${DASSRECON_TREE:-/tmp/claude-1000/smfix/tree}; LOG=$(dirname "$TREE")
cd "$TREE" || exit 1
P=$(cd "$PR" && python3 -c "
import halsParms
print(halsParms.getParms('$STEM', '', options=[o for o in halsParms.DEFAULT_OPTIONS if o not in ('LIST','LISTING2')], sdl=True, release='OI340700'))")
rm -f objects/$STEM.obj; s0=$(date +%s); while [ "$(date +%s)" = "$s0" ]; do sleep 0.1; done
HALSFC $SUB/$STEM.hal --parms="$P" -o objects/$STEM.obj --clean --sdfi=SDFLIB > $LOG/hc-$STEM.log 2>&1
rc=$?
[ -s objects/$STEM.obj ] && echo "$STEM: compiled (rc $rc)" || { echo "$STEM: FAILED rc $rc"; tail -15 $LOG/hc-$STEM.log; exit 1; }
