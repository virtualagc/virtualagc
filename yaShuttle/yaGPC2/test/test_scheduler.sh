#!/bin/bash
# test_scheduler.sh — end-to-end regression test for HAL/S TASK/
# SCHEDULE/WAIT support (see src/schedule.h/.c, wired into src/halucp.c's
# SVC dispatch). Like test_debugger.sh, this has no JS reference to diff
# against (the scheduler is a new, yaGPC2-only subsystem -- see
# problems.md 2.7/7) -- instead each case runs a real HAL/S-compiled
# fixture and diffs against a golden output captured from an independent
# oracle: yaHALMAT2 running that same fixture's own HALSFC-compiled
# HALMAT (via `HALSFC fixture.hal ...; yaHALMAT2 halmat.bin` -- NOTE:
# rely on yaHALMAT2's own --litfile/--memory auto-discovery, don't pass
# them explicitly pointing both at the same file, which silently
# corrupts CHARACTER-literal output while still exiting 0) — confirmed
# byte-identical to yaGPC2's own output for the same source, which is
# what this test guards against regressing.
set -u
cd "$(dirname "$0")"

YAGPC2="../yaGPC2"

fail=0

# --time-scale: yaGPC2's standalone CLI now paces SCHEDULE/WAIT against
# real wall-clock time by default (--time-scale 1.0, matching
# yaHALMAT2's own default -- see run.c's batchrunner_pace()), so a
# program with any real virtual-time span would otherwise make this
# test take that long every time `make test` runs, once per --pacing
# mode below. A large factor collapses that to milliseconds without
# changing any tick arithmetic or program output at all (confirmed:
# same golden files this is diffed against, captured with yaHALMAT2
# similarly sped up via its own --time-scale).
run_case() {
    label="$1"; pacing="$2"; fcm="$3"; sym="$4"; golden="$5"
    shift 5 || true
    extra_args=("$@")

    act_out=$(mktemp)
    act_err=$(mktemp)

    "$YAGPC2" --interactive --no-trace --no-verbose --symbols "$sym" --line-width 240 --max-steps 200000 \
        --time-scale 1000000 --pacing "$pacing" "${extra_args[@]}" "$fcm" >"$act_out" 2>"$act_err"
    act_code=$?

    ok=1

    if ! diff -u "$golden" "$act_out"; then
        echo "FAIL [scheduler/$label]: stdout differs from $golden"
        ok=0
    fi

    if [ -s "$act_err" ]; then
        echo "FAIL [scheduler/$label]: unexpected stderr output"
        cat "$act_err"
        ok=0
    fi

    if [ "$act_code" != 0 ]; then
        echo "FAIL [scheduler/$label]: exit code $act_code (expected 0)"
        ok=0
    fi

    if [ "$ok" = 1 ]; then
        echo "PASS [scheduler/$label]"
    else
        fail=1
    fi

    rm -f "$act_out" "$act_err"
}

# Like run_case, but for fixtures that deliberately trigger a real
# SEND ERROR (SVC 0x0014) -- hal_report_error() reports every SEND
# ERROR unconditionally to stderr (not gated on --verbose, unlike
# hal_log()'s own diagnostic-only messages), so these fixtures always
# produce real stderr output, unlike every other case in this file.
# Diffs stderr against its own golden instead of requiring it empty.
run_case_with_stderr() {
    label="$1"; pacing="$2"; fcm="$3"; sym="$4"; golden="$5"; errGolden="$6"
    shift 6 || true
    extra_args=("$@")

    act_out=$(mktemp)
    act_err=$(mktemp)

    "$YAGPC2" --interactive --no-trace --no-verbose --symbols "$sym" --line-width 240 --max-steps 200000 \
        --time-scale 1000000 --pacing "$pacing" "${extra_args[@]}" "$fcm" >"$act_out" 2>"$act_err"
    act_code=$?

    ok=1

    if ! diff -u "$golden" "$act_out"; then
        echo "FAIL [scheduler/$label]: stdout differs from $golden"
        ok=0
    fi

    if ! diff -u "$errGolden" "$act_err"; then
        echo "FAIL [scheduler/$label]: stderr differs from $errGolden"
        ok=0
    fi

    if [ "$act_code" != 0 ]; then
        echo "FAIL [scheduler/$label]: exit code $act_code (expected 0)"
        ok=0
    fi

    if [ "$ok" = 1 ]; then
        echo "PASS [scheduler/$label]"
    else
        fail=1
    fi

    rm -f "$act_out" "$act_err"
}

# --pacing=burst (default polling design) and --pacing=signal (POSIX
# timer/sigsuspend-driven alternative, run.c's batchrunner_pace_signal())
# -- both implement the same pacing contract and must produce byte-
# identical program output, only wall-clock jitter/precision differs
# (see run.c's own header comment), so both diff against the same
# golden file.
run_case "countup/burst"  "burst"  "fixtures/countup.fcm" "fixtures/countup-lnk101.json" "fixtures/countup_golden.txt"
run_case "countup/signal" "signal" "fixtures/countup.fcm" "fixtures/countup-lnk101.json" "fixtures/countup_golden.txt"

# WAIT UNTIL (SVC #7, sched_handle_wait_until_svc) -- a real compiled
# program (WRITE, WAIT UNTIL <absolute time>, WRITE), no TASK/SCHEDULE
# involved at all, just the primal process suspending itself.
run_case "waituntil/burst"  "burst"  "fixtures/waituntil.fcm" "fixtures/waituntil-lnk101.json" "fixtures/waituntil_golden.txt"
run_case "waituntil/signal" "signal" "fixtures/waituntil.fcm" "fixtures/waituntil-lnk101.json" "fixtures/waituntil_golden.txt"

# TERMINATE, named-target form (SVC #3, sched_handle_terminate_named_svc)
# -- a REPEAT EVERY task TERMINATEd by the primal mid-stream; asserts it
# actually stops repeating (4 firings, not 5+), unlike merely reaching
# its own CLOSE (which would re-arm it).
run_case "terminate/burst"  "burst"  "fixtures/terminate.fcm" "fixtures/terminate-lnk101.json" "fixtures/terminate_golden.txt"
run_case "terminate/signal" "signal" "fixtures/terminate.fcm" "fixtures/terminate-lnk101.json" "fixtures/terminate_golden.txt"

# TERMINATE, bare/self form (SVC #2, sched_handle_terminate_self_svc) --
# a task that TERMINATEs itself; asserts execution actually stops right
# there (the pre-fix bug: an unhandled SVC just fell through and kept
# executing the task's own remaining statements).
run_case "selfterminate/burst"  "burst"  "fixtures/selfterminate.fcm" "fixtures/selfterminate-lnk101.json" "fixtures/selfterminate_golden.txt"
run_case "selfterminate/signal" "signal" "fixtures/selfterminate.fcm" "fixtures/selfterminate-lnk101.json" "fixtures/selfterminate_golden.txt"

# PRIO() built-in (SVC 0x0317) -- confirmed deterministic/comparable
# (unlike RUNTIME(), see problems.md 7.4/7.5: two independently-invented
# timing models can't be expected to agree on an elapsed-time *value*,
# but PRIO() returns an exact INTEGER with no timing dependency at all).
run_case "prio/burst"  "burst"  "fixtures/prio.fcm" "fixtures/prio-lnk101.json" "fixtures/prio_golden.txt"
run_case "prio/signal" "signal" "fixtures/prio.fcm" "fixtures/prio-lnk101.json" "fixtures/prio_golden.txt"

# Process name as Boolean (USA003087 13.5) -- a task's own PDE+0 bit 0,
# read directly by compiled code (no SVC at all). Checks both ACTIVE
# (right after SCHEDULE) and INACTIVE (right after TERMINATE). No
# yaHALMAT2 cross-check exists for this fixture: yaHALMAT2 itself
# errors out on this construct ("SYT index 2 is a whole ARRAY/VECTOR/
# MATRIX referenced outside an arrayed-paragraph replay") -- a real
# yaHALMAT2 gap, not a yaGPC2 one; see problems.md.
run_case "processboolean/burst"  "burst"  "fixtures/processboolean.fcm" "fixtures/processboolean-lnk101.json" "fixtures/processboolean_golden.txt"
run_case "processboolean/signal" "signal" "fixtures/processboolean.fcm" "fixtures/processboolean-lnk101.json" "fixtures/processboolean_golden.txt"

# SCHEDULE ... IN / AT (delayed initiation, halucp.c's FLAGS bits 0x0008/
# 0x0004) and IN combined with REPEAT EVERY (proving the repeat phase is
# anchored to the IN deadline, not t=0) -- see sched_handle_schedule_svc
# (src/schedule.h/.c) and problems.md 7.7.
run_case "schedulein/burst"  "burst"  "fixtures/schedulein.fcm" "fixtures/schedulein-lnk101.json" "fixtures/schedulein_golden.txt"
run_case "schedulein/signal" "signal" "fixtures/schedulein.fcm" "fixtures/schedulein-lnk101.json" "fixtures/schedulein_golden.txt"
run_case "scheduleat/burst"  "burst"  "fixtures/scheduleat.fcm" "fixtures/scheduleat-lnk101.json" "fixtures/scheduleat_golden.txt"
run_case "scheduleat/signal" "signal" "fixtures/scheduleat.fcm" "fixtures/scheduleat-lnk101.json" "fixtures/scheduleat_golden.txt"
run_case "schedulerepeat/burst"  "burst"  "fixtures/schedulerepeat.fcm" "fixtures/schedulerepeat-lnk101.json" "fixtures/schedulerepeat_golden.txt"
run_case "schedulerepeat/signal" "signal" "fixtures/schedulerepeat.fcm" "fixtures/schedulerepeat-lnk101.json" "fixtures/schedulerepeat_golden.txt"

# WAIT FOR <event-expr> / SCHEDULE ... ON <event-expr> (SVC #8 / SVC #1
# FLAGS=0x000d) -- single/NOT/AND-chain/OR-chain forms, plus a genuine
# SCHEDULE ... ON deferred-dispatch case. No yaHALMAT2 cross-check exists
# for any of these (yaHALMAT2 has a confirmed bug on WAIT FOR, relayed
# upstream -- see problems.md 7.8); verified instead directly against
# USA003087 24.6/24.8's own text, same reasoning as processboolean above.
run_case "waitfor/burst"  "burst"  "fixtures/waitfor.fcm" "fixtures/waitfor-lnk101.json" "fixtures/waitfor_golden.txt"
run_case "waitfor/signal" "signal" "fixtures/waitfor.fcm" "fixtures/waitfor-lnk101.json" "fixtures/waitfor_golden.txt"
run_case "waitfornot/burst"  "burst"  "fixtures/waitfornot.fcm" "fixtures/waitfornot-lnk101.json" "fixtures/waitfornot_golden.txt"
run_case "waitfornot/signal" "signal" "fixtures/waitfornot.fcm" "fixtures/waitfornot-lnk101.json" "fixtures/waitfornot_golden.txt"
run_case "waitforand/burst"  "burst"  "fixtures/waitforand.fcm" "fixtures/waitforand-lnk101.json" "fixtures/waitforand_golden.txt"
run_case "waitforand/signal" "signal" "fixtures/waitforand.fcm" "fixtures/waitforand-lnk101.json" "fixtures/waitforand_golden.txt"
run_case "waitforor/burst"  "burst"  "fixtures/waitforor.fcm" "fixtures/waitforor-lnk101.json" "fixtures/waitforor_golden.txt"
run_case "waitforor/signal" "signal" "fixtures/waitforor.fcm" "fixtures/waitforor-lnk101.json" "fixtures/waitforor_golden.txt"
run_case "scheduleon/burst"  "burst"  "fixtures/scheduleon.fcm" "fixtures/scheduleon-lnk101.json" "fixtures/scheduleon_golden.txt"
run_case "scheduleon/signal" "signal" "fixtures/scheduleon.fcm" "fixtures/scheduleon-lnk101.json" "fixtures/scheduleon_golden.txt"

# SCHEDULE ... DEPENDENT (FLAGS bit 0x0020) and its two consequences:
# CLOSE-with-a-live-dependent blocks instead of deactivating (USA003087
# 13.3), and TERMINATE cascades to dependents (13.3/23.6). Plus WAIT FOR
# DEPENDENT (SVC #9). No yaHALMAT2 cross-check attempted (same category
# as WAIT FOR/SCHEDULE ON above -- see problems.md 7.8/7.9).
run_case "dependent/burst"  "burst"  "fixtures/dependent.fcm" "fixtures/dependent-lnk101.json" "fixtures/dependent_golden.txt"
run_case "dependent/signal" "signal" "fixtures/dependent.fcm" "fixtures/dependent-lnk101.json" "fixtures/dependent_golden.txt"
run_case "dependentin/burst"  "burst"  "fixtures/dependentin.fcm" "fixtures/dependentin-lnk101.json" "fixtures/dependentin_golden.txt"
run_case "dependentin/signal" "signal" "fixtures/dependentin.fcm" "fixtures/dependentin-lnk101.json" "fixtures/dependentin_golden.txt"
run_case "dependentrepeat/burst"  "burst"  "fixtures/dependentrepeat.fcm" "fixtures/dependentrepeat-lnk101.json" "fixtures/dependentrepeat_golden.txt"
run_case "dependentrepeat/signal" "signal" "fixtures/dependentrepeat.fcm" "fixtures/dependentrepeat-lnk101.json" "fixtures/dependentrepeat_golden.txt"
run_case "dependentclose/burst"  "burst"  "fixtures/dependentclose.fcm" "fixtures/dependentclose-lnk101.json" "fixtures/dependentclose_golden.txt"
run_case "dependentclose/signal" "signal" "fixtures/dependentclose.fcm" "fixtures/dependentclose-lnk101.json" "fixtures/dependentclose_golden.txt"
run_case "waitfordependent/burst"  "burst"  "fixtures/waitfordependent.fcm" "fixtures/waitfordependent-lnk101.json" "fixtures/waitfordependent_golden.txt"
run_case "waitfordependent/signal" "signal" "fixtures/waitfordependent.fcm" "fixtures/waitfordependent-lnk101.json" "fixtures/waitfordependent_golden.txt"

# CANCEL (SVC #4 self / SVC #5 named) -- the graceful sibling of
# TERMINATE (USA003087 13.5/23.6). No yaHALMAT2 cross-check attempted:
# yaHALMAT2 diverges from these traced/spec-derived semantics on all
# three fixtures below (relayed upstream separately) -- see problems.md
# 7.11.
run_case "cancel/burst"  "burst"  "fixtures/cancel.fcm" "fixtures/cancel-lnk101.json" "fixtures/cancel_golden.txt"
run_case "cancel/signal" "signal" "fixtures/cancel.fcm" "fixtures/cancel-lnk101.json" "fixtures/cancel_golden.txt"
run_case "selfcancel/burst"  "burst"  "fixtures/selfcancel.fcm" "fixtures/selfcancel-lnk101.json" "fixtures/selfcancel_golden.txt"
run_case "selfcancel/signal" "signal" "fixtures/selfcancel.fcm" "fixtures/selfcancel-lnk101.json" "fixtures/selfcancel_golden.txt"
run_case "cancelnamed/burst"  "burst"  "fixtures/cancelnamed.fcm" "fixtures/cancelnamed-lnk101.json" "fixtures/cancelnamed_golden.txt"
run_case "cancelnamed/signal" "signal" "fixtures/cancelnamed.fcm" "fixtures/cancelnamed-lnk101.json" "fixtures/cancelnamed_golden.txt"

# EXCLUSIVE procedures/functions (SVC #15 reserve / #17 release, code
# block -- USA003087 27.2, confirmed against IBM-76-SS-1110 4.2.2/
# 4.2.2.3's own fully-documented reserve/release SVC family).
# exclusivecontend.hal is the interesting one: genuine cross-task
# contention (a SCHEDULEd task's own attempt to enter the same EXCLUSIVE
# procedure the primal is still inside correctly blocks). yaHALMAT2
# diverges on that one specifically -- it doesn't enforce mutual
# exclusion at all (relayed upstream separately) -- see problems.md 7.12.
run_case "exclusive/burst"  "burst"  "fixtures/exclusive.fcm" "fixtures/exclusive-lnk101.json" "fixtures/exclusive_golden.txt"
run_case "exclusive/signal" "signal" "fixtures/exclusive.fcm" "fixtures/exclusive-lnk101.json" "fixtures/exclusive_golden.txt"
run_case "exclusivetwo/burst"  "burst"  "fixtures/exclusivetwo.fcm" "fixtures/exclusivetwo-lnk101.json" "fixtures/exclusivetwo_golden.txt"
run_case "exclusivetwo/signal" "signal" "fixtures/exclusivetwo.fcm" "fixtures/exclusivetwo-lnk101.json" "fixtures/exclusivetwo_golden.txt"
run_case "exclusivecontend/burst"  "burst"  "fixtures/exclusivecontend.fcm" "fixtures/exclusivecontend-lnk101.json" "fixtures/exclusivecontend_golden.txt"
run_case "exclusivecontend/signal" "signal" "fixtures/exclusivecontend.fcm" "fixtures/exclusivecontend-lnk101.json" "fixtures/exclusivecontend_golden.txt"

# WAIT FOR on a genuine EVENT-typed variable operand (SET/RESET, not a
# process name) -- confirmed this needed zero source changes, since
# item #7's own event-expression descriptor format and evaluator are
# operand-type-agnostic. Byte-diffed against yaHALMAT2, matching
# exactly -- see problems.md 7.14.
run_case "waitforeventvar/burst"  "burst"  "fixtures/waitforeventvar.fcm" "fixtures/waitforeventvar-lnk101.json" "fixtures/waitforeventvar_golden.txt"
run_case "waitforeventvar/signal" "signal" "fixtures/waitforeventvar.fcm" "fixtures/waitforeventvar-lnk101.json" "fixtures/waitforeventvar_golden.txt"
run_case "waitforeventvarblock/burst"  "burst"  "fixtures/waitforeventvarblock.fcm" "fixtures/waitforeventvarblock-lnk101.json" "fixtures/waitforeventvarblock_golden.txt"
run_case "waitforeventvarblock/signal" "signal" "fixtures/waitforeventvarblock.fcm" "fixtures/waitforeventvarblock-lnk101.json" "fixtures/waitforeventvarblock_golden.txt"
run_case "waitforeventvarand/burst"  "burst"  "fixtures/waitforeventvarand.fcm" "fixtures/waitforeventvarand-lnk101.json" "fixtures/waitforeventvarand_golden.txt"
run_case "waitforeventvarand/signal" "signal" "fixtures/waitforeventvarand.fcm" "fixtures/waitforeventvarand-lnk101.json" "fixtures/waitforeventvarand_golden.txt"

# DATE()/CLOCKTIME() (SVC #22, TYPE=1/2) -- WAIT 3600 then read both, so
# each reflects real virtual-time progression past the anchor, not just
# the anchor itself. --date-time-epoch 951912000 = 2000-03-01 12:00:00
# UTC (a fixed literal, not computed via `date` at test time, so this
# stays reproducible regardless of the host's own timezone database);
# TZ=UTC pins localtime()'s own decomposition the same way, since
# DATE()/CLOCKTIME() are deliberately host-timezone-dependent by design
# (see problems.md 7.15) -- without pinning TZ, this test would produce
# a different (but still internally correct) golden value on every
# machine. Byte-diffed against yaHALMAT2 (its own --start-time, same
# epoch, same TZ=UTC) -- matches exactly.
TZ=UTC run_case "datetimefn/burst"  "burst"  "fixtures/datetimefn.fcm" "fixtures/datetimefn-lnk101.json" "fixtures/datetimefn_golden.txt" "--date-time-epoch" "951912000"
TZ=UTC run_case "datetimefn/signal" "signal" "fixtures/datetimefn.fcm" "fixtures/datetimefn-lnk101.json" "fixtures/datetimefn_golden.txt" "--date-time-epoch" "951912000"

# SCHEDULE ... REPEAT's remaining variants (USA003087 23.5): bare REPEAT
# (immediate recycling, cancelled by a small UNTIL time checked at
# CLOSE), REPEAT AFTER (constant intercycle delay, no UNTIL), REPEAT
# EVERY ... UNTIL (UNTIL-time cancellation layered on the already-known
# EVERY cadence), and REPEAT AFTER ... UNTIL cancelling *between* cycles
# -- the last one is the direct regression test for a real internal bug
# (sched_dispatch's own virtual-time fast-forward wasn't considering a
# DORMANT task's own UNTIL time as a candidate deadline, so it could
# overshoot straight past the cancellation instant to the task's own
# next wake time -- only observable via RUNTIME()'s own value once
# nothing else in the program is scheduled in that gap, exactly what
# this fixture's own DEPENDENT + WAIT FOR DEPENDENT + RUNTIME() shape is
# built to expose) -- see problems.md 7.16.
run_case "repeatbare/burst"  "burst"  "fixtures/repeatbare.fcm" "fixtures/repeatbare-lnk101.json" "fixtures/repeatbare_golden.txt"
run_case "repeatbare/signal" "signal" "fixtures/repeatbare.fcm" "fixtures/repeatbare-lnk101.json" "fixtures/repeatbare_golden.txt"
run_case "repeatafter/burst"  "burst"  "fixtures/repeatafter.fcm" "fixtures/repeatafter-lnk101.json" "fixtures/repeatafter_golden.txt"
run_case "repeatafter/signal" "signal" "fixtures/repeatafter.fcm" "fixtures/repeatafter-lnk101.json" "fixtures/repeatafter_golden.txt"
run_case "repeateveryuntil/burst"  "burst"  "fixtures/repeateveryuntil.fcm" "fixtures/repeateveryuntil-lnk101.json" "fixtures/repeateveryuntil_golden.txt"
run_case "repeateveryuntil/signal" "signal" "fixtures/repeateveryuntil.fcm" "fixtures/repeateveryuntil-lnk101.json" "fixtures/repeateveryuntil_golden.txt"
run_case "repeataftercancel/burst"  "burst"  "fixtures/repeataftercancel.fcm" "fixtures/repeataftercancel-lnk101.json" "fixtures/repeataftercancel_golden.txt"
run_case "repeataftercancel/signal" "signal" "fixtures/repeataftercancel.fcm" "fixtures/repeataftercancel-lnk101.json" "fixtures/repeataftercancel_golden.txt"

# SCHEDULE ... REPEAT's event-expression cancellation clauses
# (USA003087 24.5): REPEAT ... WHILE exp (cycles while an EVENT stays
# TRUE, an explicit RESET mid-run stopping it between cycles -- 3 ticks,
# not the full ~7-8 a plain REPEAT EVERY over the same WAIT span would
# give), REPEAT ... UNTIL exp (cycles until an EVENT becomes TRUE,
# guaranteeing at least one cycle regardless of the event's initial
# value, unlike WHILE -- 2 ticks: cycle 1 always runs even though EV1
# starts FALSE, cycle 3 never does once EV1 goes TRUE between cycles 2
# and 3), and REPEAT ... WHILE exp already FALSE before the very first
# cycle (removed without ever executing at all -- no TICK output). No
# yaHALMAT2 cross-check exists for any of these three -- confirmed this
# variant isn't wired up on that side yet (falls back to ignoring the
# clause entirely, cycling as a plain REPEAT EVERY) -- see problems.md
# 7.17.
run_case "repeatwhile/burst"  "burst"  "fixtures/repeatwhile.fcm" "fixtures/repeatwhile-lnk101.json" "fixtures/repeatwhile_golden.txt"
run_case "repeatwhile/signal" "signal" "fixtures/repeatwhile.fcm" "fixtures/repeatwhile-lnk101.json" "fixtures/repeatwhile_golden.txt"
run_case "repeatuntilevent/burst"  "burst"  "fixtures/repeatuntilevent.fcm" "fixtures/repeatuntilevent-lnk101.json" "fixtures/repeatuntilevent_golden.txt"
run_case "repeatuntilevent/signal" "signal" "fixtures/repeatuntilevent.fcm" "fixtures/repeatuntilevent-lnk101.json" "fixtures/repeatuntilevent_golden.txt"
run_case "repeatwhilefalse/burst"  "burst"  "fixtures/repeatwhilefalse.fcm" "fixtures/repeatwhilefalse-lnk101.json" "fixtures/repeatwhilefalse_golden.txt"
run_case "repeatwhilefalse/signal" "signal" "fixtures/repeatwhilefalse.fcm" "fixtures/repeatwhilefalse-lnk101.json" "fixtures/repeatwhilefalse_golden.txt"

# OFF ERROR (USA003087 25.2), per-process error environments, and
# dynamic (call-depth) scoping of ON ERROR modifications (25.1) --
# confirmed already correctly implemented with zero new code (see
# problems.md 7.18). All three deliberately trigger a real domain error
# (SQRT of a negative number) so run_case_with_stderr's own stderr
# golden captures the real SEND ERROR report hal_report_error() always
# emits, unconditionally, for a real error -- unlike every other case
# in this file, these are NOT expected to have empty stderr.
run_case_with_stderr "offerror/burst"  "burst"  "fixtures/offerror.fcm" "fixtures/offerror-lnk101.json" "fixtures/offerror_golden.txt" "fixtures/offerror_stderr_golden.txt"
run_case_with_stderr "offerror/signal" "signal" "fixtures/offerror.fcm" "fixtures/offerror-lnk101.json" "fixtures/offerror_golden.txt" "fixtures/offerror_stderr_golden.txt"
run_case_with_stderr "errorpertask/burst"  "burst"  "fixtures/errorpertask.fcm" "fixtures/errorpertask-lnk101.json" "fixtures/errorpertask_golden.txt" "fixtures/errorpertask_stderr_golden.txt"
run_case_with_stderr "errorpertask/signal" "signal" "fixtures/errorpertask.fcm" "fixtures/errorpertask-lnk101.json" "fixtures/errorpertask_golden.txt" "fixtures/errorpertask_stderr_golden.txt"
run_case_with_stderr "errordynscope/burst"  "burst"  "fixtures/errordynscope.fcm" "fixtures/errordynscope-lnk101.json" "fixtures/errordynscope_golden.txt" "fixtures/errordynscope_stderr_golden.txt"
run_case_with_stderr "errordynscope/signal" "signal" "fixtures/errordynscope.fcm" "fixtures/errordynscope-lnk101.json" "fixtures/errordynscope_golden.txt" "fixtures/errordynscope_stderr_golden.txt"

exit $fail
