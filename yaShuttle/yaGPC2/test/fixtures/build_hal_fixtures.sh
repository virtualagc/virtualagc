#!/bin/bash
# Reproduces hello.fcm, read_write.fcm, read_eof_onerror.fcm,
# countup.fcm, waituntil.fcm, terminate.fcm, selfterminate.fcm, and
# updatepriority.fcm (plus their -lnk101.json symbol tables) via the
# real HAL/S toolchain documented in ../../tools.md (HALSFC + lnk101,
# both expected on PATH). Not run automatically (no CI machine has the
# toolchain) — kept for provenance and to regenerate if the
# encoding/format ever changes.
#
# Sources:
#   hello.fcm            <- HELLO.hal (ported/PASS1.PROCS/HELLO.hal in the
#                          virtualagc/yaShuttle tree) — WRITE-only smoke test.
#   read_write.fcm        <- yaHALMAT2/src/tests/hal/test_read_write.hal —
#                          a single READ(5) I1,S1 statement.
#   read_eof_onerror.fcm  <- yaHALMAT2/src/tests/hal/test_read_eof_onerror.hal
#                          — READ-until-EOF loop with ON ERROR GO TO DONE,
#                          the standard HAL/S idiom ("Programming in HAL/S"
#                          p.193). Used to confirm HalUCP's ON ERROR/EOF
#                          dispatch end-to-end; also the fixture that
#                          exposed a real gpc run --interactive bug (see
#                          run.c's interactive_input_cb comment) — do NOT
#                          add this one to run_matrix.sh's byte-diff
#                          matrix, its expected output is checked directly
#                          against yaGPC2 only.
#   countup.fcm           <- countup.hal (checked in alongside this
#                          script, not sourced externally — a small
#                          user-provided TASK/SCHEDULE/WAIT test program;
#                          see src/schedule.h and test_scheduler.sh, and
#                          problems.md 2.7).
#   waituntil.fcm         <- waituntil.hal (checked in alongside this
#                          script — a small WRITE/WAIT UNTIL/WRITE test
#                          program, no TASK/SCHEDULE involved; see
#                          sched_handle_wait_until_svc (src/schedule.h/.c)
#                          and problems.md's runtime-feature-survey
#                          implementation-order work).
#   terminate.fcm         <- terminate.hal (checked in alongside this
#                          script — a REPEAT EVERY task TERMINATEd by
#                          name from the primal; see
#                          sched_handle_terminate_named_svc.)
#   selfterminate.fcm     <- selfterminate.hal (checked in alongside
#                          this script — a task that TERMINATEs itself;
#                          see sched_handle_terminate_self_svc.)
#   updatepriority.fcm    <- updatepriority.hal (checked in alongside
#                          this script — two competing REPEAT EVERY
#                          tasks, one raised above the other mid-run via
#                          UPDATE PRIORITY; see
#                          sched_handle_update_priority_svc). Kept for
#                          provenance/smoke-testing (confirms the real
#                          toolchain's own SVC #11 encoding is handled
#                          without an unhandled-SVC trap) but
#                          deliberately NOT added to test_scheduler.sh's
#                          byte-diff suite: its exact firing-order
#                          interleaving is sensitive to a real, separate,
#                          pre-existing yaGPC2-vs-yaHALMAT2 instruction-
#                          timing discrepancy for simultaneously-due
#                          REPEAT EVERY tasks (see problems.md) unrelated
#                          to UPDATE PRIORITY itself -- test_schedule.c's
#                          own hand-assembled scenario 3 is the
#                          deterministic regression test for this
#                          feature instead, same reasoning
#                          read_eof_onerror.fcm above already documents
#                          for a different known discrepancy.
set -eu

HAL_SRC_DIR="/home/rburkey/git/virtualagc/yaShuttle"
HELLO_HAL="$HAL_SRC_DIR/ported/PASS1.PROCS/HELLO.hal"
READ_WRITE_HAL="$HAL_SRC_DIR/yaHALMAT2/src/tests/hal/test_read_write.hal"
ONERROR_HAL="$HAL_SRC_DIR/yaHALMAT2/src/tests/hal/test_read_eof_onerror.hal"
COUNTUP_HAL="$(dirname "$0")/countup.hal"
WAITUNTIL_HAL="$(dirname "$0")/waituntil.hal"
TERMINATE_HAL="$(dirname "$0")/terminate.hal"
SELFTERMINATE_HAL="$(dirname "$0")/selfterminate.hal"
UPDATEPRIORITY_HAL="$(dirname "$0")/updatepriority.hal"

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

PARMS="LIST,NOTABLES,SRN,TEMPLATE,NOLFXI,REGOPT,VARSYM,CARDTYPE=FCRMYCZM"

build() {
    local hal="$1" base="$2" outprefix="$3"
    cp "$hal" "$WORK/$base.hal"
    (cd "$WORK" && HALSFC "$base.hal" --parms="$PARMS" -o "$base.obj")
    (cd "$WORK" && lnk101 "$base.obj" -o "$base.fcm" --json-symbols "$base-lnk101.json")
    cp "$WORK/$base.fcm" "$outprefix.fcm"
    cp "$WORK/$base-lnk101.json" "$outprefix-lnk101.json"
}

cd "$(dirname "$0")"
build "$HELLO_HAL" HELLO hello
build "$READ_WRITE_HAL" test_read_write read_write
build "$ONERROR_HAL" test_read_eof_onerror read_eof_onerror
build "$COUNTUP_HAL" countup countup
build "$WAITUNTIL_HAL" waituntil waituntil
build "$TERMINATE_HAL" terminate terminate
build "$SELFTERMINATE_HAL" selfterminate selfterminate
build "$UPDATEPRIORITY_HAL" updatepriority updatepriority

echo "Rebuilt hello.fcm, read_write.fcm, read_eof_onerror.fcm, countup.fcm, waituntil.fcm, terminate.fcm, selfterminate.fcm, updatepriority.fcm (+ -lnk101.json)"
