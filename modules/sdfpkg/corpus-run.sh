#!/bin/bash
# Prepare and run one PASS corpus, from scratch.
#
#     corpus-run.sh ~/ForClaude/OI340600-sdftest  TAG
#
# TAG names the archives of the previous run, so nothing is lost.  Both
# corpora may be run at the same time; that has been safe since the
# HAL_S_FC.py shared-directory race was fixed (virtualagc 6367bfc85).
#
# The work directories live under ~/ForClaude, NOT under ~/workspace/PFS: the
# latter is an IDE project, and the ~2.3 million files these runs archive froze
# the IDE solid.  Keep it that way -- PFS holds the masters and nothing else.
#
# Remember that a -sdftest directory holds its OWN copies of APPLSRC, SSSRC
# and INCL80.  If you have edited the masters under ~/workspace/PFS/OI3xxxxx/,
# sync them first or the run will use the old source:
#
#     for d in APPLSRC SSSRC INCL80; do
#       rsync -a --delete ~/workspace/PFS/$V/$d/ ~/ForClaude/$V-sdftest/$d/
#     done
#
# On completion the exit status of compilePASS is written to corpus.done, so a
# waiting loop can block on that file appearing.

set -u
D="${1:?usage: corpus-run.sh WORKDIR TAG}"
TAG="${2:?usage: corpus-run.sh WORKDIR TAG}"

cd "$D" || exit 1
rm -f corpus.done
[ -f compilePASS.log ] && mv compilePASS.log "compilePASS.$TAG.log"
[ -d archive.results ] && mv archive.results "archive.results.$TAG"
rm -rf ./*.results _*.hal
rm -rf SDFLIB && mkdir -p SDFLIB     # compilePASS does not clear this itself
mkdir -p objects

prepareTEMPLIB --clear                  >  prepare.log 2>&1
prepareINCLIB  --clear --include=INCL80 >> prepare.log 2>&1

compilePASS --extra-parms=TABLST --clean --archive > compilePASS.log 2>&1
echo $? > corpus.done
