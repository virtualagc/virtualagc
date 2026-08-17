#!/bin/bash
# Reproduces hello.fcm, read_write.fcm, read_eof_onerror.fcm,
# countup.fcm, waituntil.fcm, terminate.fcm, selfterminate.fcm,
# updatepriority.fcm, prio.fcm, runtimeprio.fcm, processboolean.fcm,
# schedulein.fcm, scheduleat.fcm, schedulerepeat.fcm, waitfor.fcm,
# waitfornot.fcm, waitforand.fcm, waitforor.fcm, scheduleon.fcm,
# dependent.fcm, dependentin.fcm, dependentrepeat.fcm,
# dependentclose.fcm, waitfordependent.fcm, cancel.fcm, selfcancel.fcm,
# and cancelnamed.fcm (plus their -lnk101.json symbol tables) via the
# real HAL/S toolchain
# documented in ../../tools.md (HALSFC + lnk101, both expected on PATH).
# Not run automatically (no CI machine has the toolchain) — kept for
# provenance and to regenerate if the encoding/format ever changes.
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
#   prio.fcm              <- prio.hal (checked in alongside this script
#                          — PRIO() called from within a dispatched TASK;
#                          confirmed deterministic/byte-diffable against
#                          yaHALMAT2, unlike RUNTIME() below, since it
#                          returns an exact INTEGER with no timing
#                          dependency at all).
#   runtimeprio.fcm       <- runtimeprio.hal (checked in alongside this
#                          script — RUNTIME() called from the primal,
#                          PRIO() from within a dispatched TASK). Kept
#                          for provenance/smoke-testing only, same
#                          reasoning as updatepriority.fcm above:
#                          RUNTIME()'s own returned *value* (and its
#                          output line's relative order against the
#                          task's own WRITE) isn't comparable against
#                          yaHALMAT2 even in principle -- see problems.md
#                          7.4/7.5 (yaHALMAT2 interprets HALMAT, which
#                          has no hardware timing semantics of its own,
#                          so its own per-instruction "cost" is a
#                          convention it invented, not a measurement of
#                          anything real). test_schedule.c's own
#                          scenario 5 is the deterministic regression
#                          test for RUNTIME()/PRIO() instead.
#   processboolean.fcm    <- processboolean.hal (checked in alongside
#                          this script — a task's own name used as a
#                          Boolean, both ACTIVE right after SCHEDULE and
#                          INACTIVE right after TERMINATE; see
#                          sched_set_active_flag, src/schedule.c). No
#                          yaHALMAT2 cross-check: yaHALMAT2 itself errors
#                          out on this construct (a real yaHALMAT2 gap,
#                          not a yaGPC2 one -- see problems.md).
#   schedulein.fcm        <- schedulein.hal (checked in alongside this
#                          script — SCHEDULE NEXT IN 1.5 PRIORITY(80);,
#                          the delayed-initiation form, no REPEAT;
#                          confirmed byte-diffable against yaHALMAT2 --
#                          see problems.md 7.7).
#   scheduleat.fcm        <- scheduleat.hal (checked in alongside this
#                          script — SCHEDULE NEXT AT 1.5 PRIORITY(80);,
#                          the absolute-time-initiation form, no REPEAT;
#                          confirmed byte-diffable against yaHALMAT2 --
#                          see problems.md 7.7).
#   schedulerepeat.fcm    <- schedulerepeat.hal (checked in alongside
#                          this script — SCHEDULE NEXT IN 1.5
#                          PRIORITY(80), REPEAT EVERY 1.0;, proving the
#                          REPEAT phase anchor is the IN deadline (1.5,
#                          2.5, 3.5, 4.5), not t=0; confirmed
#                          byte-diffable against yaHALMAT2 -- see
#                          problems.md 7.7).
#   waitfor.fcm           <- waitfor.hal, waitfornot.fcm <- waitfornot.hal,
#   waitforand.fcm        <- waitforand.hal, waitforor.fcm <-
#                          waitforor.hal, scheduleon.fcm <- scheduleon.hal
#                          (all checked in alongside this script) -- WAIT
#                          FOR <event-expr>/SCHEDULE ... ON <event-expr>
#                          (single/NOT/AND-chain/OR-chain forms, plus a
#                          genuine SCHEDULE ... ON deferred-dispatch
#                          case). NO yaHALMAT2 cross-check exists for any
#                          of these: yaHALMAT2 has a confirmed bug on
#                          WAIT FOR (relayed upstream, not yet fixed --
#                          see problems.md 7.8) -- verified instead
#                          directly against USA003087 24.6/24.8's own
#                          text ("if exp is already TRUE... the
#                          statement has no effect"), same reasoning as
#                          processboolean.fcm above.
#   dependent.fcm         <- dependent.hal, dependentin.fcm <-
#                          dependentin.hal, dependentrepeat.fcm <-
#                          dependentrepeat.hal (all checked in alongside
#                          this script) -- SCHEDULE ... DEPENDENT (FLAGS
#                          bit 0x0020), plain and combined with IN/REPEAT
#                          EVERY, confirming the bit composes additively
#                          like every other FLAGS bit.
#   dependentclose.fcm    <- dependentclose.hal (checked in alongside
#                          this script) -- a parent task reaching its
#                          own bare CLOSE with a still-active DEPENDENT
#                          child; proves the real compiler emits the
#                          identical bare SVC 0x0015 regardless (no
#                          compiler-inserted wait), so the "don't
#                          deactivate until dependents finish" behavior
#                          (USA003087 13.3) is this file's own runtime
#                          responsibility, not something the compiler
#                          handles.
#   waitfordependent.fcm  <- waitfordependent.hal (checked in alongside
#                          this script) -- WAIT FOR DEPENDENT (SVC #9).
#   cancel.fcm            <- cancel.hal (checked in alongside this
#                          script) -- named CANCEL of a DORMANT ("not
#                          yet initiated") REPEAT EVERY target; it never
#                          runs at all.
#   selfcancel.fcm        <- selfcancel.hal (checked in alongside this
#                          script) -- bare CANCEL; inside a REPEAT EVERY
#                          task's own body, followed by more code in the
#                          same block; confirms the current cycle runs
#                          to completion normally (that code DOES
#                          execute) and only the next re-arm is
#                          suppressed.
#   cancelnamed.fcm       <- cancelnamed.hal (checked in alongside this
#                          script) -- CANCEL of two DORMANT REPEAT EVERY
#                          targets in one statement (the named form's
#                          count+PDE-list encoding); neither ever runs.
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
PRIO_HAL="$(dirname "$0")/prio.hal"
RUNTIMEPRIO_HAL="$(dirname "$0")/runtimeprio.hal"
PROCESSBOOLEAN_HAL="$(dirname "$0")/processboolean.hal"
SCHEDULEIN_HAL="$(dirname "$0")/schedulein.hal"
SCHEDULEAT_HAL="$(dirname "$0")/scheduleat.hal"
SCHEDULEREPEAT_HAL="$(dirname "$0")/schedulerepeat.hal"
WAITFOR_HAL="$(dirname "$0")/waitfor.hal"
WAITFORNOT_HAL="$(dirname "$0")/waitfornot.hal"
WAITFORAND_HAL="$(dirname "$0")/waitforand.hal"
WAITFOROR_HAL="$(dirname "$0")/waitforor.hal"
SCHEDULEON_HAL="$(dirname "$0")/scheduleon.hal"
DEPENDENT_HAL="$(dirname "$0")/dependent.hal"
DEPENDENTIN_HAL="$(dirname "$0")/dependentin.hal"
DEPENDENTREPEAT_HAL="$(dirname "$0")/dependentrepeat.hal"
DEPENDENTCLOSE_HAL="$(dirname "$0")/dependentclose.hal"
WAITFORDEPENDENT_HAL="$(dirname "$0")/waitfordependent.hal"
CANCEL_HAL="$(dirname "$0")/cancel.hal"
SELFCANCEL_HAL="$(dirname "$0")/selfcancel.hal"
CANCELNAMED_HAL="$(dirname "$0")/cancelnamed.hal"

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
build "$PRIO_HAL" prio prio
build "$RUNTIMEPRIO_HAL" runtimeprio runtimeprio
build "$PROCESSBOOLEAN_HAL" processboolean processboolean
build "$SCHEDULEIN_HAL" SCHIN schedulein
build "$SCHEDULEAT_HAL" SCHAT scheduleat
build "$SCHEDULEREPEAT_HAL" SCHINREP schedulerepeat
build "$WAITFOR_HAL" WAITFOR waitfor
build "$WAITFORNOT_HAL" WFNOT waitfornot
build "$WAITFORAND_HAL" WFAND waitforand
build "$WAITFOROR_HAL" WFOR waitforor
build "$SCHEDULEON_HAL" SCHON3 scheduleon
build "$DEPENDENT_HAL" DEPTEST dependent
build "$DEPENDENTIN_HAL" DEPIN dependentin
build "$DEPENDENTREPEAT_HAL" DEPREP dependentrepeat
build "$DEPENDENTCLOSE_HAL" DEPCLOSE dependentclose
build "$WAITFORDEPENDENT_HAL" WFDEP waitfordependent
build "$CANCEL_HAL" CANCELT cancel
build "$SELFCANCEL_HAL" SELFCAN selfcancel
build "$CANCELNAMED_HAL" CANCEL2 cancelnamed

echo "Rebuilt hello.fcm, read_write.fcm, read_eof_onerror.fcm, countup.fcm, waituntil.fcm, terminate.fcm, selfterminate.fcm, updatepriority.fcm, prio.fcm, runtimeprio.fcm, processboolean.fcm, schedulein.fcm, scheduleat.fcm, schedulerepeat.fcm, waitfor.fcm, waitfornot.fcm, waitforand.fcm, waitforor.fcm, scheduleon.fcm, dependent.fcm, dependentin.fcm, dependentrepeat.fcm, dependentclose.fcm, waitfordependent.fcm, cancel.fcm, selfcancel.fcm, cancelnamed.fcm (+ -lnk101.json)"
