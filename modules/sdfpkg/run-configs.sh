#!/bin/bash
# Work through the remaining memory configurations unattended.
#
# The sequence per configuration is the one SSW and P9 established:
#
#   1  dass-literals.py            patch the reference image from MAFGEN's own
#                                  literal annotations, and list the locations
#                                  it marks as changed after the build
#   2  sweep with the plain index  harvest lnk101's unresolved relocations
#   3  dass-syms.py                recover CSECT addresses from that evidence
#   4  sweep with the augmented index
#   5  dass-syms.py --base         a second pass: at least one symbol per
#                                  configuration only becomes acceptable once
#                                  the other fixes stop diluting its evidence
#   6  dass-versions.py            no-claim entries for units the later release
#                                  revised
#   7  final sweep
#
# Every sweep purges the build archives first.  HALSFC keeps about 48 MB of
# reports per compile, and six configurations at three sweeps each would be
# roughly 340 GB otherwise.  Nothing in them is needed once fcmcmp has run; a
# single file can be recompiled by hand when one is.
#
# Runs four compiles at once, in four separate source trees.  They must be
# separate: HALSFC writes halmat.bin, litfile.bin and COMMON*.out into its
# current directory under fixed names, so two compiles sharing a directory
# corrupt each other.

set -u
# The data lives in PFS, the code in virtualagc; the instructions have the
# reader cd to the PFS directory first.  $PFS overrides.
if [ -z "${PFSDIR:-}" ]; then
    if [ -d mafgen ]; then PFSDIR=$(pwd); else PFSDIR=$HOME/workspace/PFS; fi
fi
CLC=~/ForClaude/OI340600-clc
JOBS=~/ForClaude/jobs
SRC=$(cd "$(dirname "$0")" && pwd)
DB=$SRC/dass-compare.db
LOG=~/ForClaude/run-configs.log

exec >>"$LOG" 2>&1
echo "=================== started $(date -Is)"

# Snapshot the scripts, and run from the snapshot.  A sweep takes three and a
# half hours, and editing a dass-*.py file while one is in flight silently
# changes the tooling underneath it: an edit eleven minutes into a run forced a
# restart, and three branch switches in nsts-sdl-dps contaminated G16.  Copying
# costs nothing and makes the two independent, so an investigation can proceed
# against the working tree while the sweep keeps what it started with.  The
# commit is recorded so a result can be traced back to it.
# --db must be passed explicitly at every call site below.  dass-db.py derives
# its default from Path(__file__).parent, so running from the snapshot silently
# writes results into the snapshot's own dass-compare.db -- which the trap then
# deletes.  Four configurations were swept into a throwaway database before the
# 0/0 section counts gave it away.
SDF=$(mktemp -d ~/ForClaude/.sweep-XXXXXX)
cp "$SRC"/dass-*.py "$SDF"/
rm -f "$SDF"/dass-compare.db
trap 'rm -rf "$SDF"' EXIT
echo "toolchain: dass-*.py snapshot in $SDF, from $(git -C "$SRC" rev-parse --short HEAD)$(git -C "$SRC" diff --quiet -- "$SRC" || echo ' + uncommitted changes')"
# lnk101 and fcmcmp run from a venv inside nsts-sdl-dps/build whose
# _editable_impl_ap101.pth points straight at nsts-sdl-dps/src, so editing that
# tree changes them under a running sweep exactly as editing dass-*.py did.
# They are NOT pip-installed into the user environment -- `pip list` shows
# nothing -- so the fix is not a reinstall but PYTHONPATH, which python places
# ahead of a .pth entry.  Copy src and point at the copy.
cp -r ~/donschmidt/nsts-sdl-dps/src "$SDF"/src
export PYTHONPATH="$SDF/src${PYTHONPATH:+:$PYTHONPATH}"
echo "toolchain: nsts-sdl-dps $(git -C ~/donschmidt/nsts-sdl-dps rev-parse --abbrev-ref HEAD) $(git -C ~/donschmidt/nsts-sdl-dps rev-parse --short HEAD)$(git -C ~/donschmidt/nsts-sdl-dps diff --quiet || echo ' + uncommitted changes'), snapshot in $SDF/src"

purge() {
    rm -rf "$CLC"/archive.results "$CLC"/current*.results
    for n in 1 2 3 4; do rm -rf "$JOBS/$n"/archive.results "$JOBS/$n"/current*.results; done
}

sweep() {   # sweep <config> <outdir> <extra args...>
    local cfg=$1 out=$2; shift 2
    purge
    ( cd "$CLC" && python3 "$SDF/dass-run.py" --config="$cfg" --db="$DB" \
        --out-dir="$CLC/$out" --log-dir="$CLC/${cfg}logs" \
        --jobs=4 --jobs-root="$JOBS" "$@" )
}

# Configurations to run: all eight by default, or just those named as
# arguments.  A change that can only affect some configurations -- the forced
# link comparison affects only those with link failures -- is worth re-running
# narrowly rather than spending three and a half hours to re-derive results
# that cannot have moved.
CONFIGS="${@:-SSW P9 G8 S2 G9 G2 G3 G16}"

for CFG in $CONFIGS; do
    echo "########## $CFG  $(date -Is)"
    ( cd "$CLC" && python3 "$SDF/dass-db.py" init --config="$CFG" --db="$DB" )
    ( cd "$CLC" && python3 "$SDF/dass-literals.py" --config="$CFG" \
        --out="$CLC/$CFG.literals.fcm" )

    echo "---------- $CFG sweep 1 (plain index)  $(date -Is)"
    sweep "$CFG" "${CFG}work1" \
        --extra=--memory="$CLC/$CFG.literals.fcm" \

    echo "---------- $CFG symbol recovery, pass 1  $(date -Is)"
    ( cd "$CLC" && python3 "$SDF/dass-syms.py" --config="$CFG" \
        --link-dir="$CLC/${CFG}work1" --log-dir="$CLC/${CFG}logs" \
        --out="$CLC/csects-$CFG-gen.json" )

    echo "---------- $CFG sweep 2 (augmented index)  $(date -Is)"
    ( cd "$CLC" && python3 "$SDF/dass-db.py" reset --config="$CFG" --db="$DB" )
    sweep "$CFG" "${CFG}work2" \
        --extra=--ext-syms="$CLC/csects-$CFG-gen.json" \
        --extra=--memory="$CLC/$CFG.literals.fcm" \

    echo "---------- $CFG symbol recovery, pass 2  $(date -Is)"
    ( cd "$CLC" && python3 "$SDF/dass-syms.py" --config="$CFG" \
        --link-dir="$CLC/${CFG}work2" --log-dir="$CLC/${CFG}logs" \
        --base="$CLC/csects-$CFG-gen.json" --out="$CLC/csects-$CFG-gen2.json" )
    # GENERATE THE -full FILE ONLY IF IT DOES NOT EXIST.
    #
    # This used to write exceptions-$CFG-curated.txt unconditionally.  The file is
    # now hand-curated and tracked in mafgen/ -- it carries the pruning and the
    # retraction of the -2 class, judgement no script can restate -- so writing
    # over it destroyed exactly what could not be rebuilt.
    #
    # Generating it remains worth doing when there is nothing there: it derives
    # the version no-claims from each unit's revision level, which is how the
    # file gets its first contents.  Once it exists it is a curated artefact and
    # the sweep only reads it.  Regenerating over a curated file is also how the
    # entries decay unnoticed: five of the seven alive on 2026-09-06 had already
    # stopped being true, and dass-score.py now reports such entries.
    CURATED=$PFSDIR/mafgen/exceptions-$CFG-curated.txt
    if [ -f "$CURATED" ]; then
        echo "---------- $CFG version no-claims: $CURATED exists, not regenerated"
    else
        echo "---------- $CFG version no-claims (first generation)  $(date -Is)"
        ( cd "$CLC" && python3 "$SDF/dass-versions.py" --config="$CFG" \
            --link-dir="$CLC/${CFG}work2" \
            --out="$CURATED" )
    fi
    FULL=$CURATED
    if [ ! -f "$FULL" ]; then
        echo "NOTE: $CURATED was not produced; sweep 3 runs without exceptions"
        FULL=""
    fi

    echo "---------- $CFG sweep 3 (final)  $(date -Is)"
    ( cd "$CLC" && python3 "$SDF/dass-db.py" reset --config="$CFG" --db="$DB" )
    sweep "$CFG" "${CFG}work3" \
        --extra=--ext-syms="$CLC/csects-$CFG-gen2.json" \
        --extra=--memory="$CLC/$CFG.literals.fcm" \
        ${FULL:+--extra=--exceptions="$FULL"}

    echo "########## $CFG done $(date -Is)"
    # Capture rather than print directly, so a configuration that produced no
    # RESULT line can be shouted about.  A sweep that silently does not run is
    # worse than one that fails: a locked database once cost P9 its entire run,
    # and the only trace was a line that never appeared.
    SUMMARY=$( cd "$CLC" && python3 -c "
import sqlite3; db=sqlite3.connect('$DB', timeout=120.0); db.row_factory=sqlite3.Row
rows=db.execute('''SELECT sec.verdict, sec.name, s.stem, sec.n_diffs FROM section sec
 JOIN run r ON r.id=sec.run_id JOIN source s ON s.id=r.source_id
 WHERE r.config=? AND sec.in_index=1''',('$CFG',)).fetchall()
ok=sum(1 for r in rows if r['verdict']=='ok')
err=db.execute(\"SELECT COUNT(*) FROM run WHERE config=? AND outcome NOT IN ('match','differ')\",('$CFG',)).fetchone()[0]
print(f'RESULT $CFG: {ok}/{len(rows)} sections match, {len(rows)-ok} differ, {err} errors')
for r in rows:
    if r['verdict']!='ok': print(f\"   differs: {r['name']} {r['stem']} n={r['n_diffs']}\")" )
    echo "$SUMMARY"
    # A perfect section count can rest on excusing a large share of the
    # halfwords in those sections, and the two should not look alike.  S2
    # reached 1252/1252 with 22% of its halfwords carrying a no-claim, because
    # 70 of its units were revised between our source and the dump; SSW, P9 and
    # G8 sit near 1%.
    ( cd "$CLC" && python3 ~/ForClaude/noclaim.py "$CFG" "$CLC/${CFG}logs" )
    case "$SUMMARY" in
        *"RESULT $CFG:"*) ;;
        *) echo "!!!!!!!!!! $CFG PRODUCED NO RESULT LINE -- its results are"\
                "missing or the database was unreachable.  Do not trust this run." ;;
    esac
    purge
done
echo "=================== all done $(date -Is)"
