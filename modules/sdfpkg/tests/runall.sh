#!/bin/bash
# Every SDF-import test, in one go.  Needs HALSFC on the PATH, since only
# PASS3 writes an SDF and HAL_S_FC.py is a port of PASS1 alone.
cd "$(dirname "$0")" || exit 1
status=0

# Pairs of (compools..., user).  invariant.py compiles the user program with
# and without an SDF library and requires the same symbol table either way.
for case in \
    "COMPA.hal USEA.hal" \
    "FUNCA.hal USEF.hal" \
    "PROCA.hal USEP.hal" \
    "COMPM.hal USEM.hal" \
    "COMPL.hal USELB.hal" \
    "COMPA.hal USER.hal" \
    "COMPA.hal COMPB.hal USEAB.hal"
do
    python3 invariant.py $case || status=1
done

# Forms where the two routes are meant to differ, so the expected outcome is
# stated outright instead.
python3 directives.py || status=1

exit $status
