#!/bin/bash
# Stop a sweep completely, and prove it.
#
# Doing this by hand orphaned three compiles in one day.  Two mistakes, both
# easy to repeat:
#
#   - compileLinkCompare was never in the kill list.  Killing dass-run.py left
#     it running, and it then launched the NEXT HALSFC pass -- after the pkill
#     for HALSFC had already gone by.  That pass survived as an orphan, spinning
#     at 100% of a core until someone noticed hours later.
#
#   - the check afterwards used `ps | grep`, which on this machine returns
#     nothing because grep is rewritten to `rtk grep` and does not read stdin
#     the same way.  It reported "0 remaining, clean" every time, including
#     when six orphans were running.  pgrep is what tells the truth.
#
# So: kill outside-in, repeatedly, then verify with pgrep and say plainly
# whether anything survived.

set -u
PATTERNS=(
    # NOT '^bash ...': reached through the ~/bin symlink the command line is
    # '/bin/bash /home/rburkey/bin/run-configs.sh', which that cannot match.
    # The parent then survived a stop and launched the next configuration --
    # two sweeps sharing jobs/1-4, where HALSFC's fixed-name workfiles
    # corrupt each other.  Requiring a path after 'bash ' keeps this from
    # matching an interactive 'bash -c ...' that merely mentions the script.
    'bash /[^ ]*run-configs\.sh'
    'dass-run\.py'
    'compileLinkCompare'
    'HALSFC'
)

for pass in 1 2; do
    for pat in "${PATTERNS[@]}"; do
        pkill -f "$pat" 2>/dev/null
    done
    sleep 2
done

# Anything still alive gets SIGKILL.
for pat in "${PATTERNS[@]}"; do
    pkill -9 -f "$pat" 2>/dev/null
done
sleep 2

self=$$
survivors=0
for pat in "${PATTERNS[@]}"; do
    for pid in $(pgrep -f "$pat" 2>/dev/null); do
        # pgrep -f matches this script's own command line; skip ourselves and
        # our children, or the check can never come out clean.
        [ "$pid" = "$self" ] && continue
        [ "$(ps -p "$pid" -o ppid= 2>/dev/null | tr -d ' ')" = "$self" ] && continue
        echo "STILL RUNNING: $(ps -p "$pid" -o pid=,etime=,args= 2>/dev/null | cut -c1-120)"
        survivors=$((survivors + 1))
    done
done

if [ "$survivors" -eq 0 ]; then
    echo "sweep stopped; nothing left running"
else
    echo "WARNING: $survivors process(es) survived -- investigate before relaunching,"
    echo "         since an orphan writes halmat.bin and litfile.bin into a job tree"
    echo "         that the next sweep will hand to a different compile."
fi
exit 0
