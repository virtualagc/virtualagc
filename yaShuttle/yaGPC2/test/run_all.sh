#!/bin/bash
# run_all.sh — drives compare.sh over the current regression corpus.
#
# Phase 0 only covers CLI parsing (help/usage/error paths) since the
# simulator core isn't implemented yet. Later phases add fixture-based
# `gpc/gen/*.fcm` runs here as each subsystem comes online.
set -u
cd "$(dirname "$0")"

fail=0

run() {
    ./compare.sh "$@" || fail=1
}

# --- CLI parsing: help / usage / error paths -------------------------------
run "help"                          --help
run "missing-fcm-arg"
run "unknown-option"                foo.fcm --bogus
run "too-many-positional"           gpc/gen/SIMPLE.fcm gpc/gen/TEST.fcm
run "unknown-option-no-fcm"         --bogus
run "help-among-other-args"         foo.fcm -h

# TODO(phase 7+): fixture-based simulator runs, e.g.:
#   run "simple-start0-trace" gpc/gen/SIMPLE.fcm --start 0 --max-steps 20 --trace --verbose

if [ "$fail" = 0 ]; then
    echo "=== ALL PASS ==="
else
    echo "=== FAILURES ABOVE ==="
fi
exit $fail
