#!/bin/sh
# ODYSSEY-AGC milestone 4: state-isolation tests.
#
# Builds the SAME harness against the frozen pristine upstream engine
# (tests/baseline) and the modified engine (../agc_engine.c), then checks:
#   1. the baseline files are still verbatim (SHA-256 guard);
#   2. DIFFERENTIAL: solo runs are bit-identical, pristine vs modified, on both
#      a watchdog-safe spin ROM and a real flight ROM (Comanche055);
#   3. INTERFERENCE: interleaved A/B each reproduce their solo fingerprint on
#      the modified engine, at several interleave granularities;
#   4. RESET: re-initialising A mid-run leaves B untouched and A matches a
#      fresh run;
#   5. CONTROL: the pristine engine FAILS the interference/reset checks, i.e.
#      the tests really detect the shared-state hazard.
# Exits non-zero if any check fails.
set -u

here=$(cd "$(dirname "$0")/.." && pwd)
build=${BUILD:-build}
cd "$here"
roms="$build/roms"
san=${SAN:-}

fails=0
pass() { echo "PASS  $1"; }
fail() { echo "FAIL  $1"; fails=$((fails + 1)); }
same() { if [ "$2" = "$3" ]; then pass "$1"; else fail "$1 (got '$2', want '$3')"; fi; }
differs() { if [ "$2" != "$3" ]; then pass "$1"; else fail "$1 (unexpectedly identical)"; fi; }

echo "== baseline integrity =="
if (cd tests/baseline && sha256sum -c SHA256SUMS >/dev/null 2>&1); then
  pass "tests/baseline matches recorded SHA-256 (verbatim upstream copy)"
else
  fail "tests/baseline was modified; it must stay a verbatim copy of upstream"
fi

echo "== build harness: pristine and modified engines =="
CC=${CC:-gcc}
$CC -std=gnu99 -O1 -w $san -Itests/baseline -I.. -o "$build/diff_orig" \
    tests/diff/diff_harness.c tests/baseline/agc_engine.c \
    tests/baseline/agc_engine_init.c ../rfopen.c -lm || { fail "build diff_orig"; exit 1; }
$CC -std=gnu99 -O1 -w $san -I.. -o "$build/diff_new" \
    tests/diff/diff_harness.c ../agc_engine.c ../agc_engine_init.c ../rfopen.c -lm \
    || { fail "build diff_new"; exit 1; }
pass "both harness builds succeeded"

fp() { cut -d' ' -f3-4; }   # "hash=... state=..." (drops the step count)

for rom in SILENT Comanche055; do
  R="$roms/$rom.bin"
  [ -f "$R" ] || { fail "missing ROM $R (run make roms)"; continue; }
  N=300000
  echo "== workload: $rom ($N steps per instance) =="

  # 2. differential
  oA=$("$build/diff_orig" "$R" solo A $N | fp); nA=$("$build/diff_new" "$R" solo A $N | fp)
  oB=$("$build/diff_orig" "$R" solo B $N | fp); nB=$("$build/diff_new" "$R" solo B $N | fp)
  same "$rom: solo A identical on pristine and modified engine" "$nA" "$oA"
  same "$rom: solo B identical on pristine and modified engine" "$nB" "$oB"
  differs "$rom: scenarios A and B are actually different (non-vacuous)" "$nA" "$nB"

  # 3. interference, modified engine, several granularities
  for ch in 1 7 1000; do
    out=$("$build/diff_new" "$R" inter $ch $N)
    same "$rom: interleaved chunk=$ch, A equals its solo run" "$(echo "$out" | sed -n 1p | fp)" "$nA"
    same "$rom: interleaved chunk=$ch, B equals its solo run" "$(echo "$out" | sed -n 2p | fp)" "$nB"
  done

  # 4. reset isolation, modified engine
  soloA2=$("$build/diff_new" "$R" solo A 200000 | fp)
  out=$("$build/diff_new" "$R" reset 1000 $N 100000)
  same "$rom: after reset, A matches a fresh run" "$(echo "$out" | sed -n 1p | fp)" "$soloA2"
  same "$rom: reset of A leaves B untouched" "$(echo "$out" | sed -n 2p | fp)" "$nB"
done

# 5. control: the PRISTINE engine must show interference (only meaningful with
# the spin ROM whose scenario exercises the IMU/CDU/gyro paths heavily).
echo "== control: pristine engine must exhibit the hazard =="
R="$roms/SILENT.bin"
oA=$("$build/diff_orig" "$R" solo A 300000 | fp)
out=$("$build/diff_orig" "$R" inter 1 300000)
differs "control: PRISTINE interleaved A differs from its solo run" "$(echo "$out" | sed -n 1p | fp)" "$oA"
out=$("$build/diff_orig" "$R" reset 1000 300000 100000)
oB=$("$build/diff_orig" "$R" solo B 300000 | fp)
differs "control: PRISTINE reset of A disturbs B" "$(echo "$out" | sed -n 2p | fp)" "$oB"

echo
if [ "$fails" -eq 0 ]; then echo "ISOLATION TESTS PASSED"; else echo "$fails ISOLATION CHECK(S) FAILED"; fi
exit "$fails"
