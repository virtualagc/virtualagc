#!/usr/bin/env bash
# Builds tests/hal/test_repeat.hal and runs it through gpc_smoke_test --
# the two-instance independence check for the yaGpcIntegration.h contract
# (yaGpcOps.c). Self-contained PASS/FAIL via gpc_smoke_test's own exit
# code, same pattern as run_debug_link_fixture.sh.
set -euo pipefail

HALSFC="/home/rburkey/git/virtualagc/yaShuttle/Source Code/PASS.REL32V0/HALSFC"
HAL_SRC_DIR="$(dirname "$0")/hal"
GPC_SMOKE_TEST="$(dirname "$0")/../gpc_smoke_test"

workdir=$(mktemp -d)
trap 'rm -rf "$workdir"' EXIT
cp "$HAL_SRC_DIR/test_repeat.hal" "$workdir/"
( cd "$workdir" && "$HALSFC" test_repeat.hal >/dev/null )

if "$GPC_SMOKE_TEST" "$workdir/halmat.bin"; then
    echo "PASS: gpc_smoke"
    exit 0
else
    echo "FAIL: gpc_smoke"
    exit 1
fi
