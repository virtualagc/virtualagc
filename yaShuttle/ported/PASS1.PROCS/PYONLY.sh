#!/usr/bin/bash
if [ -z "$1" ]; then
    echo "Usage: $0 <HAL/S-source-file>" >&2
    exit 1
fi
python "/home/rburkey/git/virtualagc/yaShuttle/ported/PASS1.PROCS/HAL_S_FC.py" --pfs CARDTYPE=UDVMWCXCYCZM    --templib --hal="$1" >pass1p.rpt
IGNORE_LINES='(HAL/S|FREE STRING AREA|NUMBER OF FILE 6|PROCESSING RATE|CPU TIME FOR|TODAY IS|COMPOOL.*VERSION|^REALLOCATIONS|^ *$|SRN STMT|^.[-]+$)'
egrep -v "$IGNORE_LINES" pass1p.rpt >pass1pA.rpt
