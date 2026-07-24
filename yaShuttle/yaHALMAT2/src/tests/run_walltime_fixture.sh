#!/usr/bin/env bash
# Proves DATE/CLOCKTIME (BFNC selectors 18/54, class-0/BFNC.md) read the
# real OS wall-clock -- user-clarified: these mean actual calendar time
# in the system's configured local timezone, not the interpreter's own
# simulated virtual clock (unlike RUNTIME/NEXTIME). Can't use a fixed
# expected string the way every other run_local_fixture.sh case does,
# since the "expected" value is different every time this runs --
# instead computes the same values independently via the `date` shell
# builtin right around the yaHALMAT2 invocation and checks the program's
# own output falls within a small tolerance window, the same bounds-
# checking approach run_realtime_fixture.sh already uses for the
# identical "can't hardcode real-world timing" reason.
#
# Usage: run_walltime_fixture.sh NAME
# NAME must have a src/tests/hal/test_NAME.hal source file that WRITEs
# exactly two lines: an INTEGER DATE value (YYDDD, [USA00309] Sec. 8.2
# rule 17), then a SCALAR CLOCKTIME value (seconds since local
# midnight -- this project's own documented judgment call for
# CLOCKTIME's otherwise-unspecified unit, see OP_BFNC's comment).
set -euo pipefail

HALSFC="/home/rburkey/git/virtualagc/yaShuttle/Source Code/PASS.REL32V0/HALSFC"
HAL_SRC_DIR="$(dirname "$0")/hal"
YAHALMAT2="$(dirname "$0")/../yaHALMAT2"

name="$1"

# Seconds since local midnight, computed the same portable way on every
# platform (no `date -d`/`-j` GNU-vs-BSD split needed) -- 10# forces
# base-10 parsing so a leading zero (e.g. "08") isn't misread as octal.
seconds_of_day() {
    local h m s
    IFS=: read -r h m s <<< "$(date +%H:%M:%S)"
    echo $((10#$h * 3600 + 10#$m * 60 + 10#$s))
}

workdir=$(mktemp -d)
trap 'rm -rf "$workdir"' EXIT
cp "$HAL_SRC_DIR/test_$name.hal" "$workdir/"
( cd "$workdir" && "$HALSFC" "test_$name.hal" >/dev/null )

before_date=$(date +%y%j)
before_sod=$(seconds_of_day)

actual=$("$YAHALMAT2" "$workdir/halmat.bin")

after_date=$(date +%y%j)
after_sod=$(seconds_of_day)

actual_date=$(echo "$actual" | sed -n '1p' | tr -d ' ')
actual_clock=$(echo "$actual" | sed -n '2p' | tr -d ' ')

date_ok="no"
[ "$actual_date" = "$before_date" ] || [ "$actual_date" = "$after_date" ] && date_ok="yes"

# +-5s tolerance around whichever of the two snapshots is wider --
# generous enough for process-startup/compile jitter without being so
# wide it'd miss a genuine "wrong unit" bug (e.g. returning virtual_time
# instead of a real timestamp would be off by many thousands of seconds
# unless the test run happens to start near virtual_time=0).
clock_ok=$(awk -v c="$actual_clock" -v lo="$before_sod" -v hi="$after_sod" \
    'BEGIN { if (lo > hi) { t = lo; lo = hi; hi = t } lo -= 5; hi += 5; print (c+0 >= lo && c+0 <= hi) ? "yes" : "no" }')

if [ "$date_ok" = "yes" ] && [ "$clock_ok" = "yes" ]; then
    echo "PASS: walltime($name) date=$actual_date clocktime=$actual_clock (real time was $before_sod-$after_sod s since midnight)"
    exit 0
else
    echo "FAIL: walltime($name)"
    echo "  actual: $(printf '%q' "$actual")"
    echo "  date_ok=$date_ok (got $actual_date, expected $before_date or $after_date)"
    echo "  clock_ok=$clock_ok (got $actual_clock, expected near [$before_sod, $after_sod])"
    exit 1
fi
