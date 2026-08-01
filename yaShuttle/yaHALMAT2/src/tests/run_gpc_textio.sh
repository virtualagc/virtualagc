#!/usr/bin/env bash
# Builds tests/hal/test_add154.hal and runs it through gpc_textio_test --
# the WRITE/READ-via-GpcOutputFn/GpcInputFn content check for the
# yaGpcIntegration.h contract (yaGpcOps.c). No stdin/expected-output
# argument needed here (unlike run_read_fixture.sh): gpc_textio_test
# supplies its own input via GpcInputFn and checks the captured
# GpcOutputFn text itself. Self-contained PASS/FAIL via gpc_textio_test's
# own exit code, same pattern as run_gpc_smoke.sh.
set -euo pipefail

HALSFC="/home/rburkey/git/virtualagc/yaShuttle/Source Code/PASS.REL32V0/HALSFC"
HAL_SRC_DIR="$(dirname "$0")/hal"
GPC_TEXTIO_TEST="$(dirname "$0")/../gpc_textio_test"

workdir=$(mktemp -d)
trap 'rm -rf "$workdir"' EXIT
cp "$HAL_SRC_DIR/test_add154.hal" "$workdir/"
( cd "$workdir" && "$HALSFC" test_add154.hal >/dev/null )

if "$GPC_TEXTIO_TEST" "$workdir/halmat.bin"; then
    echo "PASS: gpc_textio"
    exit 0
else
    echo "FAIL: gpc_textio"
    exit 1
fi
