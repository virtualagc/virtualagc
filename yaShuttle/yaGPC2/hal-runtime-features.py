#!/usr/bin/env python3
'''
License:    Public Domain, no restrictions believed to exist.
Filename:   hal-runtime-features.py
Purpose:    Itemized survey of HAL/S RUNTIME language features against
            yaGPC2's actual implementation and test coverage. Builds/
            queries hal-runtime-features.db.
Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).

Usage:      hal-runtime-features.py build              (re)create + populate the DB
            hal-runtime-features.py list [--category=C] [--impl=STATUS] [--test=STATUS]
            hal-runtime-features.py show ID [ID ...]
            hal-runtime-features.py search TEXT
            hal-runtime-features.py stats

WHY.  Survey requested 2026-08-17: "assess how well yaGPC2 supports the
documented runtime features of the HAL/S language," using USA003090
(HAL/S-FC User's Manual), USA003087 (HAL/S Programmer's Guide), and
USA003088 (HAL/S Language Specification) -- extracted text under
../yaHALMAT2/source-documentation/ -- as primary sources. Six parallel
research passes over those manuals produced ~230 raw candidate features;
this file is the synthesis, cross-referenced against yaGPC2's actual
source (src/halucp.c, src/schedule.c) and this project's own test/
corpus history (problems.md sections 2, 3, and 5).

STATUS VOCABULARY (see also each row's own impl_notes/test_notes --
the vocabulary is a coarse sort key, not the full story):

impl_status:
  implemented          -- yaGPC2 has dedicated C code for this (an SVC
                           handler, the scheduler, a HalUCP I/O routine).
  implemented_via_cpu   -- no yaGPC2-specific code exists or is needed:
                           this "just works" because the compiled HAL/S
                           program's own generated instructions (and,
                           for built-in functions, the real linked
                           AP-101S runtime-library object code from
                           Appendix D) execute correctly on a correct
                           CPU emulator. Correctness here depends on
                           CPU instruction-set completeness (extensively
                           unit-tested, ~500K exec fixtures) and on the
                           PASS/OI340600/OI301700 toolchain corpus work
                           (modules/sdfpkg/HANDOFF.md), not on anything
                           in this repo's own runtime-support code.
  partial               -- some documented variant(s) implemented,
                           others not (e.g. WAIT's delta-time form only).
  not_implemented       -- no code path handles this at all; a compiled
                           program using it falls through to the
                           generic "SVC trapped"/unhandled path, or the
                           feature has no runtime counterpart anywhere.
  not_applicable        -- compile-time-only (nothing for a CPU-level
                           runtime emulator to do), or documented by
                           the manual itself as unused by real PASS/BFS
                           flight software (e.g. READ/READALL, per
                           USA003087 12.3's own DR102959 note).
  unresolved            -- the source documentation itself doesn't
                           pin this down precisely enough to assess
                           (e.g. several unlabeled Appendix D CSECT
                           families).

test_status:
  tested_dedicated  -- yaGPC2 has its own purpose-built test for this
                       (test/test_schedule.c, test/test_scheduler.sh,
                       test/test_gpcops.c, or a test/fixtures/*.fcm
                       exercised by run_matrix.sh).
  tested_corpus     -- exercised (not necessarily exhaustively) by the
                       99-file "Programming in HAL/S" corpus sweep
                       (problems.md section 3 and the section-5 direct
                       yaGPC2-vs-yaHALMAT2 re-sweep) and/or the 164-file
                       yaHALMAT2 test/tests/hal/ sweep (section 2) --
                       both already run and their discrepancies already
                       triaged in problems.md.
  untested          -- no known automated or corpus exercise of this.
  not_applicable    -- n/a (matches impl_status not_applicable, usually).

Every row's source_ref cites the manual section the feature came from.
Rows were synthesized from six parallel research passes (2026-08-17);
where a row's own correctness is uncertain from the source text alone
(OCR ambiguity, an unlabeled table entry), that's noted in impl_notes.
This is a snapshot, not a live oracle -- re-verify anything you're about
to act on, the same as any other memory/survey artifact.
'''
import sys
import os
import sqlite3
import argparse

DB_PATH = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'hal-runtime-features.db')

SCHEMA = '''
CREATE TABLE IF NOT EXISTS features (
    id            INTEGER PRIMARY KEY AUTOINCREMENT,
    key           TEXT UNIQUE NOT NULL,
    category      TEXT NOT NULL,
    name          TEXT NOT NULL,
    description   TEXT NOT NULL,
    source_ref    TEXT NOT NULL,
    impl_status   TEXT NOT NULL CHECK (impl_status IN
                     ('implemented','implemented_via_cpu','partial',
                      'not_implemented','not_applicable','unresolved')),
    impl_notes    TEXT,
    test_status   TEXT NOT NULL CHECK (test_status IN
                     ('tested_dedicated','tested_corpus','untested','not_applicable')),
    test_notes    TEXT,
    updated_at    DATETIME DEFAULT CURRENT_TIMESTAMP
);
CREATE TRIGGER IF NOT EXISTS features_set_updated_at
AFTER UPDATE ON features
FOR EACH ROW
BEGIN
    UPDATE features SET updated_at = CURRENT_TIMESTAMP WHERE id = OLD.id;
END;
'''

def slug(name):
    out = []
    prev_us = False
    for c in name.lower():
        if c.isalnum():
            out.append(c)
            prev_us = False
        elif not prev_us:
            out.append('_')
            prev_us = True
    return ''.join(out).strip('_')[:60]

# ---------------------------------------------------------------------
# Feature data. (category, name, description, source_ref, impl_status,
# impl_notes, test_status, test_notes)
# ---------------------------------------------------------------------
FEATURES = []

def F(category, name, description, source_ref, impl_status, impl_notes, test_status, test_notes=''):
    FEATURES.append((category, name, description, source_ref, impl_status, impl_notes, test_status, test_notes))

CORPUS = ("Exercised by the 99-file 'Programming in HAL/S' corpus sweep (problems.md section 3, "
          "re-swept directly against yaGPC2 in section 5: 76/99 agree, 15 discrepancies -- "
          "all 15 owned by yaHALMAT2, not yaGPC2) and/or the 164-file yaHALMAT2 test/tests/hal/ "
          "sweep (section 2).")

# --- Real-Time: Task/Process model -------------------------------------------------
F('Real-Time: Task/Process', 'RTE process model (ACTIVE/INACTIVE, EXECUTING/READY/WAITING)',
  'A HAL/S program is one or more real-time processes managed by priority in a process queue; '
  'ACTIVE processes are EXECUTING, READY, or WAITING.',
  'USA003087 §13.1', 'implemented',
  "src/schedule.h's TaskState enum (RUNNING/WAITING/DORMANT/SLOT_FREE) implements this state "
  "model for the cooperative subset actually reachable (READY is declared but nothing produces "
  "it in this cut -- only used by a future one-shot SCHEDULE with no REPEAT).",
  'tested_dedicated', 'test/test_schedule.c scenario 1 (priority ordering + context round-trip).')
F('Real-Time: Task/Process', 'TASK block definition',
  'A static block nested in a PROGRAM, from which SCHEDULE creates a real-time process.',
  'USA003087 §13.2', 'implemented',
  'Compiled TASK bodies run as ordinary linked machine code once dispatched to their PDE entry point; '
  'src/schedule.c decodes the PDE far-pointer (decode_pde_far_pointer) to find it.',
  'tested_dedicated', 'test/test_scheduler.sh (real compiled COUNTUP.hal, one TASK).')
F('Real-Time: Task/Process', 'Process termination paths (RETURN / CLOSE / TERMINATE) + dependent cascading',
  "A process ends via TERMINATE (immediate, cascades to dependents), or reaching CLOSE/RETURN "
  "(waits for its own dependents to finish first, if any).",
  'USA003087 §13.3', 'implemented',
  "CLOSE (sched_handle_task_close, SVC 0x0015) and both TERMINATE forms (sched_handle_terminate_self_svc "
  "SVC #2, sched_handle_terminate_named_svc SVC #3) are implemented, and dependent-cascading now is too: "
  "a task reaching its own bare CLOSE with a still-active DEPENDENT child transitions to "
  "TASK_STATE_WAITING_FOR_DEPENDENTS instead of deactivating (confirmed empirically that the real "
  "compiler emits the identical bare SVC 0x0015 regardless of whether dependents exist -- this really "
  "is this file's own runtime responsibility, no compiler-inserted wait). "
  "sched_notify_dependent_finished (src/schedule.c) releases the parent -- freeing it (cascading "
  "further up in turn) or restoring it to TASK_STATE_READY, depending which path led here -- once its "
  "last dependent finishes, for any reason (natural CLOSE, or TERMINATE). "
  "sched_terminate_idx_and_dependents cascades TERMINATE transitively down the whole dependency "
  "subtree, unconditionally and immediately, per USA003087 13.3/23.6.",
  'tested_dedicated',
  "test_schedule.c (test_dependent_close_blocks_until_dependent_finishes, "
  "test_terminate_cascades_to_dependents_transitively -- the latter confirmed 2 levels deep, no real "
  "fixture goes deeper) and countup.hal's own CLOSE NEXT; test/fixtures/terminate.hal, "
  "selfterminate.hal, dependentclose.hal.")

# --- Real-Time: SCHEDULE variants ---------------------------------------------------
F('Real-Time: SCHEDULE', 'SCHEDULE (immediate initiation, PRIORITY, DEPENDENT)',
  'SCHEDULE label PRIORITY(a) DEPENDENT; creates a process, READY immediately.',
  'USA003087 §13.4', 'implemented',
  "PRIORITY and immediate-READY are implemented (sched_handle_schedule_svc). DEPENDENT is FLAGS bit "
  "0x0020, confirmed empirically to compose additively with AT/IN/REPEAT EVERY exactly like every "
  "other FLAGS bit (recognizedMask in halucp.c now includes it). sched_handle_schedule_svc's new "
  "dependent parameter records the new task's own parentIdx as whichever task is currently running at "
  "SCHEDULE time (USA003087 13.4: dependency is on the executing process, not a separately-named "
  "parent, so no extra SVC field is needed) -- lazily engaging the primal pseudo-task first if "
  "scheduling has never been engaged before, same pattern as WAIT's own lazy allocation. DEPENDENT "
  "combined with ON (SCHEDULE ... ON exp PRIORITY(a) DEPENDENT, legal per USA003087 24.5) is not "
  "empirically confirmed and stays unrecognized.",
  'tested_dedicated',
  "test_schedule.c scenario 1 (two one-shot SCHEDULEs, different priorities) plus the new "
  "test_dependent_close_blocks_until_dependent_finishes/test_wait_for_dependent/"
  "test_terminate_cascades_to_dependents_transitively scenarios; test/fixtures/dependent.hal, "
  "dependentin.hal, dependentrepeat.hal (byte-diffed via test_scheduler.sh, confirming the FLAGS bit "
  "combines correctly with IN/REPEAT EVERY in real compiled programs).")
F('Real-Time: SCHEDULE', 'SCHEDULE ... IN interval (delayed initiation, relative)',
  'Process WAITING until interval seconds after schedule time, then READY.',
  'USA003087 §13.4', 'implemented',
  "halucp.c decodes FLAGS bit 0x0008 (IN) and reads the interval from FPR0-1 (the same FPR pair "
  "delta-time WAIT and WAIT UNTIL already use), computing an absolute wake deadline "
  "(cpu->elapsedTimeUs + interval) passed to sched_handle_schedule_svc's new initialWakeDeadlineUs "
  "parameter. Combines correctly with REPEAT EVERY: the repeat phase anchors off the IN deadline, "
  "not off t=0 (see test/fixtures/schedulerepeat.hal).",
  'tested_dedicated',
  "test/fixtures/schedulein.hal (byte-diffed against yaHALMAT2 via test_scheduler.sh) and "
  "test_schedule.c's test_schedule_in_delays_first_firing_and_anchors_repeat (deterministic, also "
  "covers the IN+REPEAT EVERY phase-anchoring interaction).")
F('Real-Time: SCHEDULE', 'SCHEDULE ... AT time (delayed initiation, absolute)',
  'Process WAITING until absolute real time is reached, then READY.',
  'USA003087 §13.4', 'implemented',
  "halucp.c decodes FLAGS bit 0x0004 (AT) and reads the absolute time from FPR0-1, clamping to "
  "cpu->elapsedTimeUs if already past (mirroring sched_handle_wait_until_svc's own precedent for a "
  "past WAIT UNTIL deadline) before passing it as initialWakeDeadlineUs.",
  'tested_dedicated',
  "test/fixtures/scheduleat.hal, byte-diffed against yaHALMAT2 via test_scheduler.sh.")
F('Real-Time: SCHEDULE', 'SCHEDULE ... REPEAT (cyclic, immediate recycling)',
  'Next cycle starts immediately when one pass ends, until an UNTIL condition cancels it.',
  'USA003087 §23.5', 'not_implemented', 'Same FLAGS-word gate.', 'untested')
F('Real-Time: SCHEDULE', 'SCHEDULE ... REPEAT AFTER delay (cyclic, fixed intercycle delay)',
  'Fixed WAITING delay between the end of one cycle and the start of the next.',
  'USA003087 §23.5', 'not_implemented',
  "Explicitly out of scope per schedule.h's own header comment (REPEAT EVERY implemented, "
  "REPEAT AFTER flagged as 'mechanically similar follow-on once EVERY works').", 'untested')
F('Real-Time: SCHEDULE', 'SCHEDULE ... REPEAT EVERY interval (cyclic, fixed-interval recycling)',
  'Each new cycle starts a fixed interval after the START of the previous one (phase-anchored).',
  'USA003087 §23.5', 'implemented',
  'src/schedule.c: repeatPhaseRefUs anchors re-arming to phaseRef + N*interval, matching the '
  "manual's phase-anchored (not delay-anchored) semantics exactly.",
  'tested_dedicated', "test_schedule.c scenario 2 (4 firings in a 3.5s WAIT) and countup.hal (200 firings, byte-identical to yaHALMAT2's own real-time-paced output).")
F('Real-Time: SCHEDULE', 'SCHEDULE ... REPEAT ... UNTIL time',
  'Cyclic process cancelled at the end of the first cycle finishing after an absolute time.',
  'USA003087 §23.5', 'not_implemented',
  'No UNTIL/cancellation-time field is decoded anywhere in halucp.c/schedule.c; a REPEAT EVERY '
  'task runs forever (until the primal process itself ends).', 'untested')
F('Real-Time: SCHEDULE', 'SCHEDULE cycle-overrun runtime error',
  "If a REPEAT EVERY cycle's own execution time exceeds its interval, the language defines this "
  "as a documented runtime error, not a silently-absorbed skip.",
  'USA003087 §23.5', 'not_implemented',
  "RESEARCHED (item #9 of the implementation-order pass) and left deliberately unimplemented: this "
  "is a spec-vs-real-implementation gap, not a to-do, matching the same pattern as DEPENDENT's bare "
  "self-form and UPDATE PRIORITY's bare self-form (real HAL/S-FC/FCOS not fully supporting a generic "
  "language-spec feature). USA003087's own §25.1 states error-group/code assignment is 'implementation "
  "dependent -- see appropriate User's Manual', so the Shuttle-specific manuals are the ones that would "
  "actually confirm this exists. Checked both: USA003090 (HAL/S-FC User's Manual) §8.4/Appendix C "
  "enumerates exactly one runtime error group -- group 4, compiler-emitted arithmetic/library checks "
  "(division by zero, domain errors, etc.) -- with NO group covering RTE/scheduler-detected conditions; "
  "its own §8.3 'Real-Time Statements' section header reads 'This section was deleted by CR13613'. The "
  "IBM-76-SS-1110 Rev 5 Interface Control Document (already this whole implementation's own primary "
  "SVC-protocol source) confirms FCOS's error numbering scheme has 6 groups -- group 2 'FCOS software "
  "defined errors' and group 5 'other FCOS defined system errors' both exist and are the natural home "
  "for a scheduler-detected condition -- but neither group's own contents are enumerated anywhere in "
  "the document; only group 4's table is given (§4.2.3.4, byte-for-byte the same table as USA003090's "
  "Appendix C). Neither document contains the words 'cyclic', 'overrun', 'late', 'missed', or "
  "'deadline' anywhere. And structurally, even if this error existed, there is no SVC-level mechanism "
  "for FCOS to report it back into a running HAL/S program at all: a cyclic task's own CLOSE compiles "
  "to the identical SVC 0x0015 every other CLOSE does (confirmed directly, schedule.h's own header "
  "comment), with no separate 'cycle overrun' SVC observed in any traced protocol this whole session. "
  "schedule.c's own re-arm loop (`while (next <= elapsedTimeUs) next += interval;`) continues to "
  "silently catch up by skipping missed cycles -- kept as-is, now with a confirmed rationale rather "
  "than a known gap.",
  'not_applicable',
  "Deliberately not tested: there is nothing to test against (no real FCOS documentation, no SVC "
  "mechanism, and neither yaHALMAT2 nor any real compiled fixture exercises a genuinely overrunning "
  "cycle). See problems.md 7.10 for the full research trail.")
F('Real-Time: SCHEDULE', 'SCHEDULE ... ON event-expr (event-triggered initiation)',
  'Process WAITING until an event expression becomes TRUE, then READY.',
  'USA003087 §24.5', 'implemented',
  "SVC #1 with FLAGS=0x000d (the AT bit 0x0004 and IN bit 0x0008 reused combined as the ON marker, "
  "not a dedicated bit of its own -- confirmed empirically), sched_handle_schedule_on_svc "
  "(src/schedule.c). The target task is marked ACTIVE immediately (matching every other SCHEDULE "
  "variant's own 'in the process queue' semantics, same precedent as AT/IN) but its own readiness is "
  "gated on the event expression (ScheduledTask.eventDescAddr) instead of a deadline -- "
  "sched_dispatch() re-evaluates it every time it runs, which happens naturally on every ACTIVE-flag "
  "transition (SCHEDULE/CLOSE/TERMINATE), so no separate wake-up/notification mechanism was needed. "
  "REPEAT EVERY combined with ON is not empirically confirmed and is left unrecognized (falls "
  "through to the unhandled-SVC-trap path, same as any other unrecognized FLAGS combination).",
  'tested_dedicated',
  "test/fixtures/scheduleon.hal (byte-diffed via test_scheduler.sh; no yaHALMAT2 oracle -- see the "
  "WAIT FOR entry below) and test_schedule.c's test_schedule_on_deferred_dispatch (deterministic, "
  "confirms a higher-priority ON-pending task correctly does NOT preempt a lower-priority immediately-"
  "eligible one, and is dispatched only once its own event becomes true).")
F('Real-Time: SCHEDULE', 'SCHEDULE ... REPEAT ... WHILE / UNTIL event-expr',
  'Cyclic process cancelled when an event expression goes FALSE (WHILE) or TRUE (UNTIL).',
  'USA003087 §24.5', 'not_implemented', 'Same FLAGS-word gate.', 'untested')
F('Real-Time: SCHEDULE', 'Program Processes (SCHEDULE targeting a separate compiled PROGRAM)',
  'SCHEDULE can target another independently-compiled PROGRAM (via an EXTERNAL PROGRAM template '
  'and link-time assembly), not just a local TASK.',
  'USA003087 §23.1-23.3', 'not_implemented',
  'schedule.c only decodes a PDE reached from the current linked image; no multi-program-unit '
  'process-creation path exists. Likely low priority: this needs a genuinely different runtime '
  'topology (multiple linked "primal" units), not just a scheduler extension.', 'untested')

# --- Real-Time: WAIT variants -------------------------------------------------------
F('Real-Time: WAIT', 'WAIT (delta-time)', 'WAIT interval; suspends the executing process for interval seconds.',
  'USA003087 §13.5', 'implemented', 'SVC #6, sched_handle_wait_svc.',
  'tested_dedicated', "test_schedule.c scenario 1's WAIT 1.0 and scenario 2's WAIT 3.5, plus countup.hal's WAIT 199.5.")
F('Real-Time: WAIT', 'WAIT UNTIL time (absolute)', 'WAITING until an absolute real time is reached.',
  'USA003087 §13.5', 'implemented',
  'SVC #7, sched_handle_wait_until_svc (src/schedule.c): delegates to sched_handle_wait_svc with a '
  'delta computed from the absolute target minus cpu->elapsedTimeUs, clamped at zero -- confirmed '
  'empirically via a real compiled WAIT UNTIL that loads its argument into the same FPR0-1 pair as '
  'delta-time WAIT.',
  'tested_dedicated',
  'test/test_scheduler.sh (waituntil/burst, waituntil/signal): real HALSFC-compiled '
  'test/fixtures/waituntil.hal, output byte-identical to yaHALMAT2.')
F('Real-Time: WAIT', 'WAIT FOR event-expr', 'WAITING until an event expression becomes TRUE.',
  'USA003087 §24.6', 'implemented',
  "SVC #8, sched_handle_wait_for_svc (src/schedule.c). The event-expression descriptor format "
  "(single/NOT-single/AND-chain/OR-chain -- the real HAL/S-FC PASS2 compiler itself rejects any "
  "mixed form with 'E102 INVALID EVENT EXPRESSION', so these are the entire legal design space, not "
  "a partial case of something bigger) was reverse-engineered from 7 real compiled signatures (N=1 "
  "plain, N=1 NOT, N=2/3/4 AND-chains, N=2/3 OR-chains) -- see schedule.h's own header comment for "
  "the exact bit layout. Correctly implements USA003087 24.6's own 'if exp is already TRUE ... the "
  "statement has no effect' rule as a true no-op (no context save, no dispatch at all) distinct from "
  "every other WAIT-family SVC, which always hands off to the dispatcher unconditionally. NO working "
  "yaHALMAT2 oracle exists for this feature: yaHALMAT2 has a confirmed bug on the identical test "
  "program (SCHEDULE A; WAIT FOR A;) at any priority -- it runs A and then simply never resumes the "
  "primal to print its own trailing WRITE, at all -- found and relayed upstream this session, not "
  "yet fixed. Verified instead directly against USA003087 24.6/24.8's own text (process-name-as-"
  "event polarity: ACTIVE<->TRUE, same as process-name-as-Boolean's own already-implemented polarity) "
  "plus multiple real compiled programs whose output matches the spec's own predicted behavior "
  "exactly, including the one case (WAIT FOR NOT <already-ACTIVE-task>) where the expression is "
  "genuinely FALSE at entry and a real block-then-resume-on-transition cycle is observed.",
  'tested_dedicated',
  "test/fixtures/waitfor.hal (already-TRUE no-op), waitfornot.hal (genuine block+resume), "
  "waitforand.hal, waitforor.hal (all byte-diffed via test_scheduler.sh, self-consistency goldens "
  "only -- see above) and test_schedule.c's test_wait_for_event_expressions (deterministic: the "
  "already-TRUE zero-side-effects case, block+resume via a real ACTIVE-flag transition, and a mixed-"
  "truth 3-operand AND/OR chain neither real fixture exercises).")
F('Real-Time: WAIT', 'WAIT FOR DEPENDENT', 'WAITING until all of the process\'s own dependents have terminated.',
  'USA003087 §13.5', 'implemented',
  "SVC #9 (confirmed empirically: no parameters of its own, tests the calling task's own dependents), "
  "sched_handle_wait_for_dependent_svc (src/schedule.c). Implements USA003087 13.5's own 'if there are "
  "no dependents, the statement has no effect' rule as a true no-op, same precedent as WAIT FOR's own "
  "already-TRUE case. Distinguishes itself from the implicit CLOSE-with-dependents wait (see the "
  "Process termination paths entry above) via pendingCloseAfterDependents=false: once satisfied, this "
  "resumes execution (TASK_STATE_READY, restored from ctx) rather than freeing the slot.",
  'tested_dedicated',
  "test_schedule.c's test_wait_for_dependent (no-dependents no-op, and genuine block+resume) and "
  "test/fixtures/waitfordependent.hal, byte-diffed via test_scheduler.sh.")

# --- Real-Time: Events --------------------------------------------------------------
F('Real-Time: Events', 'EVENT data declaration (with/without LATCHED)',
  'A Boolean-valued data item whose changes are RTE-visible; LATCHED holds TRUE/FALSE persistently, '
  'non-LATCHED is normally FALSE with transient TRUE pulses.',
  'USA003087 §24.1-24.2', 'implemented_via_cpu',
  'Storage/declaration is an ordinary compiled data item; no yaGPC2-specific runtime code needed '
  'for the declaration itself.', 'tested_corpus', CORPUS + ' (sgnl.hal, eron_event.hal-style fixtures.)')
F('Real-Time: Events', 'SET / RESET statements', 'Force a LATCHED event to TRUE (SET) or FALSE (RESET).',
  'USA003087 §24.4', 'implemented', 'SVC 0x000D (SET) / 0x000E (RESET), halucp_handle_svc.',
  'untested', 'No dedicated test exercises SET/RESET directly; only reached transitively via ON ERROR ... AND SET/RESET.')
F('Real-Time: Events', 'SIGNAL statement',
  'Non-latched: transient TRUE pulse. Latched: transient value complement.',
  'USA003087 §24.4', 'implemented', 'SVC 0x000C, halucp_handle_svc.', 'untested', 'Same as SET/RESET above.')
F('Real-Time: Events', 'Event expressions in SCHEDULE/WAIT (RTE-continuous re-evaluation)',
  'A Boolean expression over event operands, re-evaluated by the RTE whenever any operand changes, '
  'not just once at statement execution.',
  'USA003087 §24.3, §24.5-24.6', 'not_implemented',
  'No event-expression evaluator exists; nothing in schedule.c consumes event state as a wake '
  'condition at all -- SET/RESET/SIGNAL change memory but nothing ever blocks on it.', 'untested')
F('Real-Time: Events', 'Events in plain Boolean context (snapshot-evaluated, not RTE-tracked)',
  'Outside SCHEDULE/WAIT, an event reads exactly like an ordinary BOOLEAN, evaluated once.',
  'USA003087 §24.7', 'implemented_via_cpu', 'Ordinary compiled comparison instruction; no runtime substitution needed.',
  'tested_corpus', CORPUS)
F('Real-Time: Events', 'Process events (process name as event-expression operand)',
  "A process's own ACTIVE/INACTIVE name, usable inside an event expression in SCHEDULE/WAIT.",
  'USA003087 §24.8', 'not_implemented',
  "Depends on both event-expression evaluation (not implemented) and a way to query a process's "
  "current scheduler state from compiled code (also not implemented). Real FCOS itself didn't "
  "fully support combining this with real events either, per the manual's own footnote 42 (E102 error) "
  "-- a documented FCOS-vs-language-spec gap, good precedent for deferring.", 'untested')

# --- Real-Time: Priority & Control ---------------------------------------------------
F('Real-Time: Priority & Control', 'TERMINATE statement',
  'Forces one or more named processes (or self) to INACTIVE immediately, cascading to dependents.',
  'USA003087 §13.5', 'partial',
  'SVC #2 (bare/self form, sched_handle_terminate_self_svc) and SVC #3 (named-target form, '
  'sched_handle_terminate_named_svc) are implemented -- confirmed empirically via a real compiled '
  'program that the named form\'s parameter word is (count<<8)|3 followed by `count` PDE-address '
  'halfwords, and the self form is SVC #2 with no parameters. Both always deactivate unconditionally '
  '(no REPEAT re-arm, unlike reaching CLOSE naturally). Dependent-cascading not implemented (DEPENDENT '
  'itself out of scope); a primal process TERMINATEing itself is not supported (falls through '
  'unhandled) -- no real fixture needs it.',
  'tested_dedicated',
  'test/test_scheduler.sh (terminate/burst, terminate/signal, selfterminate/burst, selfterminate/signal); '
  'output byte-identical to yaHALMAT2 for both forms.')
F('Real-Time: Priority & Control', 'CANCEL statement',
  'Graceful alternative to TERMINATE for cyclic processes: finishes the current cycle first, '
  'shuts down dependents in order rather than force-terminating them.',
  'USA003087 §23.6', 'implemented',
  "SVC #4 (bare/self) / SVC #5 (named), confirmed empirically to mirror TERMINATE's own #2/#3 split "
  "and the named form's identical count-then-PDE-list encoding exactly. sched_cancel_idx_and_dependents "
  "(src/schedule.c) implements the state-dependent effect USA003087 23.6 describes: a RUNNING target "
  "(only ever the calling context itself) is just flagged (ScheduledTask.cancelled), checked by "
  "sched_handle_task_close at that task's own next CLOSE (a cancelled REPEAT EVERY task does not "
  "re-arm) -- confirmed via a full instruction trace, not just the SVC summary, that a bare self-CANCEL "
  "does NOT alter control flow at all: the rest of the current cycle's own code (including its own "
  "WRITE calls) executes completely normally. A DORMANT target ('not yet initiated' or 'waiting "
  "between cycles', both producing the identical outcome per 23.6's own text) is canceled immediately "
  "but gracefully -- reusing the same TASK_STATE_WAITING_FOR_DEPENDENTS mechanism a natural "
  "CLOSE-with-dependents case uses if it has active DEPENDENT children, cascading CANCEL's own graceful "
  "semantics recursively to each of them (23.6: 'cyclic dependents are allowed to finish their own "
  "current cycle of execution') rather than TERMINATE's unconditional-immediate cascade. No yaHALMAT2 "
  "oracle available: it diverges from these traced/spec-derived semantics on all three real fixtures "
  "checked in for this item (a DORMANT target still runs instead of being removed; a bare self-CANCEL "
  "skips the rest of its own cycle instead of letting it finish) -- found and will be relayed upstream "
  "separately, not fixed in this repository.",
  'tested_dedicated',
  "test/fixtures/cancel.hal (named CANCEL of a DORMANT target), selfcancel.hal (bare self-CANCEL mid-"
  "cycle), cancelnamed.hal (two DORMANT targets in one statement), all byte-diffed via "
  "test_scheduler.sh, plus four test_schedule.c scenarios covering what no real fixture combines: "
  "graceful deactivation of a DORMANT target with a live RUNNING dependent, transitive propagation of "
  "that wait up a 3-level chain, and a RUNNING dependent being flagged rather than force-freed "
  "mid-cycle.")
F('Real-Time: Priority & Control', 'UPDATE PRIORITY statement', "Changes an active process's priority at runtime.",
  'USA003087 §13.5', 'partial',
  'Named-target form (SVC #11, sched_handle_update_priority_svc) is implemented -- confirmed '
  'empirically via a real compiled program that the SVC parameter word is (newPriority<<8)|11 '
  'followed by the target task\'s own PDE address. The bare/self form ("UPDATE PRIORITY TO alpha;", '
  'no label) is NOT implemented: a real compiled test case for it hits a genuine HAL/S-FC PASS2 '
  'compiler limitation ("INDIRECT STACK USAGE CONFLICT") unrelated to yaGPC2 -- there is no compiled '
  'program to trace its SVC encoding from.',
  'tested_dedicated',
  'test_schedule.c scenario 3 (deterministic hand-assembled priority-flip test -- a real compiled '
  'fixture, test/fixtures/updatepriority.hal, exists for toolchain-encoding provenance but is NOT '
  'diffed against yaHALMAT2, since its exact firing order is sensitive to a separate, pre-existing '
  'timing discrepancy for simultaneously-due REPEAT EVERY tasks -- see problems.md).')
F('Real-Time: Priority & Control', 'RUNTIME() built-in function',
  'Returns the current value of real time as a SCALAR, in seconds.',
  'USA003087 §13.5, Appendix B; USA003090 §8.2 item 18', 'implemented',
  "SVC 0x0016 (halucp.c): writes cpu->elapsedTimeUs (converted from microseconds to seconds) as a "
  "double-precision IBM float into FP0-FP1, letting the compiled code's own STE/STD choice handle "
  "single-vs-double narrowing (confirmed empirically: a real compiled T = RUNTIME; with T declared "
  "plain SCALAR emits STE reading FP0 alone right after the SVC returns). The problems.md 2.6 "
  "FPMGMTIM/periodic-timer-interrupt blocker no longer applies now that cpu->elapsedTimeUs is a "
  "real, working virtual-time clock (added for TASK/SCHEDULE/WAIT).",
  'tested_dedicated',
  'test_schedule.c scenario 5 (direct SVC injection, checks the FP0-FP1 conversion in isolation). '
  'A real compiled fixture (test/fixtures/runtimeprio.hal) exists for toolchain-encoding provenance '
  'but is NOT diffed against yaHALMAT2 -- its returned value (and output ordering relative to a '
  'task\'s own WRITE) is inherently incomparable between two independently-invented instruction-'
  'timing models (see problems.md 7.4/7.5).')
F('Real-Time: Priority & Control', 'PRIO() built-in function',
  'Returns the priority of the invoking process, as an INTEGER.',
  'USA003087 §13.5, Appendix B', 'implemented',
  "SVC 0x0317 (halucp.c): writes the running ScheduledTask's own priority into general register 5's "
  "upper 16 bits -- confirmed empirically across two independent compiled contexts, and corroborated "
  "by ERRGRP/ERRNUM (SVC 0x0117/0x0217) already using the identical R5 convention for their own "
  "INTEGER results. Calling PRIO() with scheduling never engaged (no running task at all) returns 0 "
  "-- a defined, non-crashing default, not confirmed against any real fixture.",
  'tested_dedicated',
  'test_schedule.c scenario 5 (direct SVC injection); test/fixtures/prio.hal (real compiled '
  'fixture, PRIO() from within a dispatched TASK -- deterministic/byte-diffable against yaHALMAT2, '
  'unlike RUNTIME(), since it\'s an exact INTEGER with no timing dependency), exercised by '
  'test_scheduler.sh under both --pacing modes.')
F('Real-Time: Priority & Control', 'Process name as Boolean (ACTIVE/INACTIVE query)',
  "A process's own name usable directly as TRUE (ACTIVE) / FALSE (INACTIVE) in an expression.",
  'USA003087 §13.5', 'implemented',
  "No SVC at all -- confirmed empirically that 'IF <task> THEN' compiles to a direct TB (test-bit) "
  "instruction reading bit 0 of the task's own PDE+0 halfword (the 'PROCESS EVENT' field "
  "schedule.h's own PDE-layout comment had already flagged as unmodeled). Implemented as "
  "sched_set_active_flag (src/schedule.c), called from sched_handle_schedule_svc (sets the bit), "
  "sched_handle_task_close's non-REPEAT branch, and sched_handle_terminate_named_svc (both clear "
  "it) -- ordinary RUNNING/WAITING/DORMANT transitions never touch it, matching USA003087 13.1's "
  "ACTIVE-means-queued definition.",
  'tested_dedicated',
  'test_schedule.c scenario 6 (all three transitions: SCHEDULE sets, CLOSE-with-no-REPEAT clears, '
  'TERMINATE clears even on a REPEAT EVERY task). test/fixtures/processboolean.hal (real compiled '
  'fixture, both ACTIVE and INACTIVE paths) exercised by test_scheduler.sh under both --pacing '
  'modes -- no yaHALMAT2 cross-check exists: yaHALMAT2 itself errors out on this construct '
  '("SYT index 2 is a whole ARRAY/VECTOR/MATRIX referenced outside an arrayed-paragraph replay"), '
  'a real yaHALMAT2 gap, not a yaGPC2 one.')
F('Real-Time: Priority & Control', 'NEXTIME(<label>) built-in function',
  'For a process scheduled with IN/AT and not yet started, returns its future start time; otherwise RUNTIME()-equivalent.',
  'USA003087 Appendix B', 'not_implemented', 'Depends on both RUNTIME() and SCHEDULE...IN/AT, neither implemented.', 'untested')

# --- I/O: Statements ------------------------------------------------------------------
F('I/O: Statement', 'WRITE statement', 'Outputs a comma-separated expression list to a paged/unpaged channel.',
  'USA003087 §12.2', 'implemented', 'halucp.c handle_output(), reached via the OUTRAP trap address.',
  'tested_dedicated', "test_gpcops.c (hello.fcm), test_debugger.sh, " + CORPUS)
F('I/O: Statement', 'READ statement', 'Reads values left-to-right from an unpaged channel.',
  'USA003087 §12.3', 'implemented',
  "halucp.c handle_input()/read_char_string(), reached via INTRAP. Per the manual's own §12.3 note, "
  "real PASS/BFS flight software never actually uses READ (DR102959, 'READ...will generate incorrect "
  "results for BFS and produce an error in the linkage editor for PASS'), so this is more than the "
  "real flight-software target needs.",
  'tested_dedicated', "test/fixtures/read_write.fcm, run_matrix.sh's read_write/interactive case, " + CORPUS)
F('I/O: Statement', 'READALL statement (raw CHARACTER stream input)',
  'Reads into CHARACTER/all-CHARACTER-structure targets as a raw, unconverted character stream.',
  'USA003087 §22.1', 'implemented_via_cpu',
  'Compiles down to the same IOINIT/READ trap mechanism as an ordinary READ (iocode<=1) -- no '
  'distinct runtime code needed. Same DR102959 "unused by real flight software" caveat as READ.',
  'tested_corpus', "yaHALMAT2's rdal.hal fixture exists; not confirmed run through yaGPC2 specifically.")
F('I/O: Statement', 'FILE statement, write-mode (random-access output)',
  'Saves a value as a binary-image record at a given record address on a random-access channel.',
  'USA003087 §22.2', 'not_implemented', 'No random-access/FILE-statement support found anywhere in src/.', 'untested')
F('I/O: Statement', 'FILE statement, read-mode (random-access input)',
  'Retrieves a binary-image record from a random-access channel.',
  'USA003087 §22.2', 'not_implemented', 'Same as write-mode above.', 'untested')

# --- I/O: Formatting -------------------------------------------------------------------
F('I/O: Formatting', 'TAB(a) / COLUMN(b) horizontal positioning',
  'Relative (TAB) or absolute (COLUMN) column positioning within a WRITE/READ statement.',
  'USA003087 §12.4', 'implemented', 'halucp.c handle_control(), iocodes 5/6.', 'tested_dedicated', CORPUS + ' (tabcol.hal.)')
F('I/O: Formatting', 'SKIP(a) / PAGE(b) / LINE(c) vertical positioning',
  'Line/page positioning within a WRITE/READ statement; LINE branches on paged vs. unpaged device semantics.',
  'USA003087 §12.4', 'implemented', 'halucp.c handle_control(), iocodes 4/7/8.', 'tested_dedicated',
  CORPUS + ' (page.hal, skipline.hal, page_overflow_no_autoformfeed.hal.)')
F('I/O: Formatting', 'FORMAT expression mechanism (WRITE/READ ... IN fmt)',
  'Associates a FORMAT character expression with a READ/WRITE via IN, with repeat-factor/parenthesized-group re-scan semantics.',
  'USA003087 §12.4.1', 'implemented', 'halucp.c emit_field()/format_integer()/format_scalar() implement field-level formatting.',
  'tested_dedicated', CORPUS + ' (reformat_csz.hal.)')
F('I/O: Formatting', 'I / F / E / U / A / X / quote-string / P format items',
  'The individual FORMAT-item vocabulary: integer, scalar fixed/scientific, generic, character, '
  'blank-filler, literal text, and mixed-picture fields.',
  'USA003087 §12.4.1', 'implemented',
  'format_integer()/format_scalar() in halucp.c cover I/F/E; the rest are believed covered by the '
  'same field-emission machinery but not individually re-verified item-by-item in this survey.',
  'tested_corpus', CORPUS)

# --- I/O: Device attributes -------------------------------------------------------------
F('I/O: Device Attribute', 'PAGED vs UNPAGED device-attribute inference',
  'A channel is inferred PAGED if only WRITE ever targets it, UNPAGED if any READ does.',
  'USA003087 §12.5', 'implemented', 'halucp_is_paged(), halucp_set_channel_mode().', 'tested_corpus', CORPUS + ' (unpaged.hal.)')
F('I/O: Device Attribute', 'Standard inter-field blank count', 'Default 5 blanks between WRITE fields (runtime-configurable).',
  'USA003087 §12.2 fn.14', 'implemented', '--halucp-format-num-blanks CLI option, HalUCP.formatNumBlanks.', 'tested_corpus', CORPUS)
F('I/O: Device Attribute', 'Logical record length (columns/line)', 'Bounds legal TAB/COLUMN movement; 132 (paged) / 80 (unpaged) columns.',
  'USA003087 §12.4 fn.', 'implemented', '--line-width CLI option, effective_line_width() (USA003090 §6.1.4 default split).', 'tested_corpus', CORPUS)
F('I/O: Device Attribute', 'Lines per page', 'Bounds legal paged-device LINE(g) values.',
  'USA003087 §12.4', 'implemented', 'HalUCP.linesPerPage, default 66 (IBM 1403 line printer convention).', 'tested_corpus', CORPUS)

# --- I/O: Data-type behavior --------------------------------------------------------------
F('I/O: Data-Type Behavior', 'Vector/matrix WRITE and READ field layout', 'Row-by-row field layout with vertical alignment.',
  'USA003087 §12.2-12.3', 'implemented_via_cpu', 'Ordinary compiled field-emission loop calling WRITE per element.', 'tested_corpus', CORPUS + ' (write_vector.hal, write_matrix.hal.)')
F('I/O: Data-Type Behavior', 'Array element-by-element I/O ordering', 'Arrayed items transfer one element at a time, in declaration order.',
  'USA003087 §12.2-12.3, §20.7', 'implemented_via_cpu', 'Ordinary compiled iteration.', 'tested_corpus', CORPUS)
F('I/O: Data-Type Behavior', 'Structure I/O ordering (single- and multiple-copy)', 'Terminal-node values transmit in template declaration order, per copy.',
  'USA003087 §19.12', 'implemented_via_cpu', 'Ordinary compiled iteration.', 'tested_corpus', CORPUS + ' (write_whole_structure_recursive.hal.)')
F('I/O: Data-Type Behavior', 'NAME (pointer) terminals excluded from sequential I/O',
  'A structure\'s NAME-typed terminals are silently skipped by WRITE/READ/READALL.',
  'USA003087 §28.10', 'implemented_via_cpu', 'A compile-time code-generation concern (compiler simply never emits I/O code for NAME terminals).', 'untested', 'No fixture specifically confirms this asymmetry.')
F('I/O: Data-Type Behavior', 'NAME (pointer) terminals included in random-access FILE I/O',
  'FILE statements DO transfer a NAME-terminal\'s pointer value.', 'USA003087 §28.10', 'not_implemented', 'FILE statements are not implemented at all (see above).', 'not_applicable')

# --- I/O: Error handling -------------------------------------------------------------------
F('I/O: Error Handling', 'WRITE numeric field-overflow handling', 'Too-narrow numeric field -> error message plus asterisks in place of the value.',
  'USA003087 §12.4.1', 'implemented', 'format_integer()/format_scalar() width-overflow paths.', 'untested', 'Not directly confirmed by a dedicated test in this survey.')
F('I/O: Error Handling', 'READ end-of-device runtime error', 'Reading past a fixed-length input strip\'s end is a runtime error.',
  'USA003087 §12.1', 'implemented', 'halucp_provide_eof() / read-side EOF handling.', 'tested_dedicated', 'test/fixtures/read_eof_onerror.fcm.')
F('I/O: Error Handling', 'READ empty-field (double-comma) semantics', 'Two consecutive separator commas leave the target item untouched, not zeroed.',
  'USA003087 §12.3', 'implemented', 'consume_trailing_separator()/handle_input() field-skip logic.', 'tested_corpus', CORPUS + ' (read_comma.hal, read_leading_comma.hal.)')

# --- Error Handling: Declaration -----------------------------------------------------------
F('Error Handling: Declaration', 'ON ERROR ... SYSTEM / IGNORE / <statement>',
  'Installs the default system action, silent-ignore, or a user statement as the recovery action for a matched error.',
  'USA003087 §25.2', 'implemented', 'try_on_error_dispatch()/match_error_handler(), dispatch_to_handler().', 'tested_dedicated', CORPUS + ' (eron.hal, eron_goto.hal, return_on_error.hal.)')
F('Error Handling: Declaration', 'ON ERROR ... AND SET/RESET/SIGNAL <event>',
  'Optional clause changing an event\'s value at the moment the covered error occurs.',
  'USA003087 §25.2', 'implemented', 'apply_ignore_event_action(), match_ignore_event_handler().', 'untested', 'Not confirmed by a dedicated test in this survey.')
F('Error Handling: Declaration', 'OFF ERROR statement', 'Removes a previously-installed ON ERROR modification with the identical specification.',
  'USA003087 §25.2', 'unresolved', 'Not confirmed present or absent by this survey -- needs a direct grep/read of the OFF-ERROR code path.', 'untested')
F('Error Handling: Declaration', 'Error specification granularity (ERROR / ERRORm / ERRORm:n)',
  'Three specification widths: all errors, a whole group, or one specific member.',
  'USA003087 §25.2', 'implemented', 'match_error_handler() decodes the group:member fixv encoding.', 'tested_dedicated', CORPUS + ' (errgrp_errnum.hal.)')

# --- Error Handling: Recovery Flow -----------------------------------------------------------
F('Error Handling: Recovery Flow', 'Per-process error environment', "Each real-time process has its own independent set of ON ERROR overrides.",
  'USA003087 §25.1', 'unresolved', "Not directly confirmed: yaGPC2's ON ERROR dispatch tables are process-agnostic globals in HalUCP as far as this survey checked -- worth confirming whether a per-task error environment is needed/present now that TASK/SCHEDULE/WAIT is real.", 'untested')
F('Error Handling: Recovery Flow', 'Dynamic scoping of error-environment modifications', 'An ON ERROR modification is in force only until the enclosing invocation returns (call-depth scoped, not lexical).',
  'USA003087 §25.1', 'unresolved', 'Not directly confirmed by this survey.', 'untested')
F('Error Handling: Recovery Flow', 'ON ERROR precedence / handler-resolution search order',
  'Innermost scope first; within a scope, exact-member match beats group beats all-errors.',
  'USA003087 §25.2', 'implemented', 'match_error_handler()\'s fixv decode implies this precedence, matching problems.md §2.1\'s already-fixed "trap does not stop the trapping statement" finding.',
  'tested_dedicated', CORPUS)
F('Error Handling: Recovery Flow', 'Standard system recovery action per error group',
  'Implementation-defined default action (fixup and continue / abnormal terminate / ignore) when no ON ERROR override is in force.',
  'USA003087 §25.1; USA003090 Appendix C', 'implemented',
  "svc_error_message()'s table (halucp.c) matches Appendix C's error catalog exactly (same error "
  "numbers: 4,5,6,7,8,9,10,11,12,14-20,22,24,25,27-33,50,59,60,62). The 'fixup' computation itself "
  "is done by the real linked math/runtime-library code (Appendix D), not by yaGPC2; yaGPC2's own "
  "job is just correctly reporting SEND ERROR when that library code calls it.",
  'tested_corpus', CORPUS + ' (errfix_scalar.hal, errfix_matrix.hal, errfix_trig.hal.)')

# --- Error Handling: Simulation -----------------------------------------------------------
F('Error Handling: Simulation', 'SEND ERRORm:n statement',
  'Triggers the same recovery-action machinery as a genuine occurrence of error m:n; the only mechanism for raising a user-defined error.',
  'USA003087 §25.3', 'implemented', 'SVC 0x0014, halucp_handle_svc.', 'tested_dedicated', CORPUS + ' (send_error.hal.)')

# --- Built-in: Math functions --------------------------------------------------------------
MATH_FNS = ['ABS','CEILING','DIV','FLOOR','MIDVAL','MOD','ODD','REMAINDER','ROUND','SIGN','SIGNUM','TRUNCATE',
            'ARCCOS','ARCCOSH','ARCSIN','ARCSINH','ARCTAN','ARCTAN2','ARCTANH','COS','COSH','EXP','LOG','SIN','SINH','SQRT','TAN','TANH']
for fn in MATH_FNS:
    F('Built-in: Math Function', f'{fn}()', f'HAL/S built-in arithmetic/algebraic function {fn}.',
      'USA003087 Appendix B', 'implemented_via_cpu',
      f'Compiles to a call into the real linked AP-101S runtime-library routine (USA003090 Appendix D); '
      f'executes correctly given a correct CPU emulator + correctly-linked library object code. Domain-error '
      f'fixup behavior (where applicable) reported via the existing SVC 0x0014 SEND ERROR path, not yaGPC2-specific code.',
      'tested_corpus', CORPUS + ' (bfnc.hal, bfnc_hyperbolic.hal, bfnc_invtrig.hal, errfix_trig.hal.)')

# --- Built-in: Vector-Matrix functions -----------------------------------------------------
VM_FNS = [('ABVAL', 'vector magnitude'), ('DET', 'matrix determinant'), ('INVERSE', 'matrix inverse'),
          ('TRACE', 'sum of diagonal elements'), ('TRANSPOSE', 'matrix transpose'), ('UNIT', 'unit vector')]
for fn, desc in VM_FNS:
    F('Built-in: Vector-Matrix Function', f'{fn}()', f'HAL/S built-in: {desc}.', 'USA003087 Appendix B',
      'implemented_via_cpu', 'Same CPU+linked-library reasoning as the math functions above (Appendix D MMxx/VVxx/VMxx/VOxx/MVxx/VXxx CSECT families).',
      'tested_corpus', CORPUS + ' (bfnc_det.hal, bfnc_inv.hal, bfnc_matrix2.hal, mm12sn_determinant.hal, minv.hal, repeated_singular_inverse.hal.)')

# --- Built-in: Time/Random functions -----------------------------------------------------
F('Built-in: Time/Random Function', 'DATE()', 'Returns a double-precision INTEGER YYDDD encoding.',
  'USA003087 Appendix B; USA003090 §8.2 item 17', 'not_implemented',
  'problems.md §2.6: DATE()/CLOCKTIME() confirmed implemented via real OS wall-clock time in yaHALMAT2, but not comparable/deterministic across runs by design; no equivalent SVC exists in yaGPC2 at all.',
  'untested')
F('Built-in: Time/Random Function', 'CLOCKTIME()', 'Returns a double-precision SCALAR "time of day".',
  'USA003087 Appendix B; USA003090 §8.2 item 18', 'not_implemented',
  "problems.md §2.6: ties to the real FCOS task scheduler's own TQE tick machinery -- WORTH REVISITING now that a real virtual-time scheduler (schedule.c, cpu->elapsedTimeUs) exists; not attempted in this survey.",
  'untested')
F('Built-in: Time/Random Function', 'RANDOM()', 'Returns a random number, rectangular distribution over [0,1).',
  'USA003087 Appendix B', 'not_implemented', 'problems.md §2.6: no PRNG/seed mechanism exists in yaGPC2; non-comparable by nature even if implemented.', 'untested')
F('Built-in: Time/Random Function', 'RANDOMG()', 'Returns a random number, Gaussian distribution mean 0 variance 1.',
  'USA003087 Appendix B', 'not_implemented', 'Same as RANDOM() above.', 'untested')

# --- Built-in: Character functions -----------------------------------------------------
CHAR_FNS = [('INDEX', 'first-index of a substring, or 0'), ('LENGTH', 'current dynamic length'),
            ('LJUST', 'left-justify (right-pad) to a given length'), ('RJUST', 'right-justify (left-pad) to a given length'),
            ('TRIM', 'strip leading/trailing blanks')]
for fn, desc in CHAR_FNS:
    F('Built-in: Character Function', f'{fn}()', f'HAL/S built-in: {desc}.', 'USA003087 Appendix B',
      'implemented_via_cpu', 'CTOx/xTOC-family and GTBYTE/STBYTE runtime-library routines (Appendix D); ordinary CPU execution.',
      'tested_corpus', CORPUS + ' (bfnc_char.hal, stri.hal, char.hal, char_conv.hal.)')
F('Built-in: Other', 'XOR(a,b) bit function', 'Exclusive-OR of two bit strings, shorter operand left-zero-padded.',
  'USA003087 Appendix B', 'implemented_via_cpu', 'Ordinary compiled bit-instruction execution.', 'tested_corpus', CORPUS + ' (bit.hal, bit_conv.hal.)')
F('Built-in: Other', 'MAX(a) / MIN(a) / SUM(a) / PROD(a) array-reduction functions',
  'Reduce an n-dimensional array to a single value across all elements.', 'USA003087 Appendix B',
  'implemented_via_cpu', 'IMIN/HMIN/EMIN/DMIN-family runtime library routines (Appendix D).', 'tested_corpus', CORPUS + ' (statistics.hal.)')
F('Built-in: Other', 'SIZE(a)', 'Returns array length, structure copy count, or terminal array length depending on argument shape.',
  'USA003087 Appendix B', 'implemented_via_cpu', 'Believed compiler-resolved (a compile-time-known constant in most cases) rather than a runtime call; not independently confirmed.', 'untested')
F('Built-in: Other', 'ERRGRP / ERRNUM', 'Return the group/number of the last error detected, or zero.',
  'USA003087 Appendix B', 'implemented', 'SVC 0x0117 (ERRGRP) / 0x0217 (ERRNUM), halucp_handle_svc.', 'tested_dedicated', CORPUS + ' (errgrp_errnum.hal.)')
F('Built-in: Other', 'SHL(a,b) / SHR(a,b) bit-shift functions', 'Logical/arithmetic shift by b bit positions.',
  'USA003087 Appendix B', 'implemented_via_cpu', 'Ordinary compiled shift-instruction execution.', 'tested_corpus', CORPUS)

# --- Built-in: Type conversions -----------------------------------------------------
CONVERSIONS = [
  ('VECTOR/MATRIX conversion (VECTORn / MATRIXn,m)', 'Builds a VECTOR/MATRIX result from a concatenated, unraveled expression list.', 'USA003087 §21.1'),
  ('Expression repetition factor (n#expr)', 'Repeats an expression\'s value n times inside a VECTOR/MATRIX/INTEGER/SCALAR conversion list.', 'USA003087 §21.1'),
  ('INTEGER/SCALAR conversion, simple form', 'Converts a single expression to INTEGER/SCALAR per Appendix A rules.', 'USA003087 §21.2'),
  ('INTEGER/SCALAR conversion, list form', 'Builds an arrayed INTEGER/SCALAR result from a concatenated expression list.', 'USA003087 §21.2'),
  ('@SINGLE / @DOUBLE precision specification', 'Forces explicit result precision on INTEGER/SCALAR/VECTOR/MATRIX conversions.', 'USA003087 §21.2'),
  ('BIT conversion, simple form', 'Converts INTEGER/SCALAR/BIT/CHARACTER to a bit string, fixed width by argument type.', 'USA003087 §21.3'),
  ('BIT conversion, radix form (@BIN/@OCT/@DEC/@HEX)', 'Converts a CHARACTER digit-string in a given radix directly to a bit string.', 'USA003087 §21.3'),
  ('CHARACTER conversion, simple form', 'Converts INTEGER/BIT/BOOLEAN/SCALAR/CHARACTER to CHARACTER per Appendix A rules.', 'USA003087 §21.4'),
  ('CHARACTER conversion, radix form (@BIN/@OCT/@DEC/@HEX)', 'Converts a bit string to a CHARACTER digit-string in a given radix.', 'USA003087 §21.4'),
  ('SUBBIT pseudo-conversion', 'Raw bit-pattern reinterpretation between types, bypassing normal type-compatibility rules (a reinterpret-cast).', 'USA003087 §21.5'),
]
for name, desc, ref in CONVERSIONS:
    F('Built-in: Type Conversion', name, desc, ref, 'implemented_via_cpu',
      'xTOy-family runtime-library routines (USA003090 Appendix D) + ordinary compiled conversion code; SUBBIT specifically not independently re-verified (fork\'s manual read was truncated before its full subscripting rules).',
      'tested_corpus', CORPUS + ' (tint.hal, stoi.hal, stos.hal, bit_conv.hal, subbit.hal, subbit_assign.hal.)')

# --- Data representation & conversion (HALUCP runtime characteristics) -----------------
DATA_REPR = [
  ('Data type runtime representation and range limits', 'INTEGER 16/32-bit; SCALAR single/double AP-101 float formats; CHARACTER<=255; BIT 1-32.', 'USA003090 §8.2 items 1-6'),
  ('Double-to-single SCALAR conversion algorithm', 'Truncates the rightmost 32 mantissa bits, no rounding.', 'USA003090 §8.2 item 7'),
  ('Double-to-single INTEGER conversion algorithm', 'Eliminates the leftmost 16 bits (truncation, not saturation).', 'USA003090 §8.2 item 8'),
  ('INTEGER-to-SCALAR conversion algorithm', 'Converts to double-precision SCALAR first, then narrows if needed.', 'USA003090 §8.2 item 9'),
  ('Single-to-double INTEGER conversion algorithm', 'Sign-extends the single-precision value across the new high bits.', 'USA003090 §8.2 item 11'),
  ('Single-to-double SCALAR conversion algorithm', 'Pads 32 zero bits to the right of the mantissa.', 'USA003090 §8.2 item 12'),
  ('SCALAR-to-CHARACTER conversion field widths', 'Double: 23 chars, 2 exp digits, 17 fraction digits. Single: 14 chars, 2 exp, 8 fraction.', 'USA003090 §8.2 items 13-14'),
  ('INTEGER-to-CHARACTER conversion field width', 'Variable-length, up to 11 characters.', 'USA003090 §8.2 item 15'),
]
for name, desc, ref in DATA_REPR:
    F('Data Representation & Conversion', name, desc, ref, 'implemented_via_cpu',
      'Exact bit-level algorithm specified by the manual; executed by the real linked CTOx/xTOC/xTOy '
      'runtime-library routines on a correct CPU emulator, not by yaGPC2-specific conversion code.',
      'tested_corpus', CORPUS + ' (scalar_double.hal, double_literal_precision.hal, ssdv_double_qdedr.hal.)')

# --- Runtime errors (Appendix C, one row per fixup family rather than per error number,
#     to avoid ~30 near-duplicate rows -- each impl_notes lists the specific numbers). ---
F('Runtime Error', 'Math domain-error fixups (errors 4-12, 24, 59, 60, 62)',
  'EXP(0<=0), SQRT(<0), EXP overflow, LOG(<=0), SIN/COS/TAN magnitude/singularity, SINH/COSH overflow, '
  'ARCSIN/ARCCOS/ARCCOSH/ARCTANH/ARCTAN2 domain errors, negative-base exponentiation -- each with a specific documented fixup value.',
  'USA003090 Appendix C', 'implemented_via_cpu',
  "Fixup computed by the real linked math library (Appendix D), which itself calls SVC 0x0014 SEND "
  "ERROR (implemented, halucp.c) on the domain violation; svc_error_message()'s table matches these "
  "exact error numbers verbatim.", 'tested_corpus', CORPUS + ' (errfix_trig.hal.)')
F('Runtime Error', 'Conversion/data errors (14-20, 22, 29-33, 50)',
  'Missing RETURN in FUNCTION, SCALAR-too-large-for-INTEGER, REMAINDER/MOD-by-zero, illegal CHARACTER '
  'subscript, bad LJUST/RJUST length, empty-string conversions, illegal bit string, illegal SUBBIT '
  'subscript, BIT@OCT/HEX invalid character, MOD relative-magnitude, compile-time-error-reached.',
  'USA003090 Appendix C', 'implemented_via_cpu', 'Same reasoning as the math-domain-error row above.',
  'tested_corpus', CORPUS + ' (errfix_scalar.hal, noret14.hal.)')
F('Runtime Error', 'Vector/matrix errors (25, 27, 28)',
  'VECTOR/MATRIX division by zero, INVERSE of a singular matrix, UNIT of a null vector.',
  'USA003090 Appendix C', 'implemented_via_cpu', 'Same reasoning as above (MMxx/VVxx library routines).',
  'tested_corpus', CORPUS + ' (errfix_matrix.hal, repeated_singular_inverse.hal, unit_vcrs_fpu_leak.hal.)')

# --- Runtime library routine families (Appendix D, collapsed) --------------------------------
F('Runtime Library Routine', 'Compool/remote-access subroutines (CAS/CASP/CASR/CPAS/CPR families)',
  'Compool access / REMOTE data-item resolution routines.', 'USA003090 Appendix D', 'unresolved',
  'Purpose inferred from naming convention only, not confirmed against §26.3-26.4/§8.11 (not read '
  'by any of the six research passes). Needs a follow-up read before its status can be assessed.', 'untested')
F('Runtime Library Routine', 'I/O channel primitive routines (IOINIT, xIN/xOUT family, INTRAP/IOCODE/IOBUF)',
  'The real runtime-library naming for the I/O trap mechanism yaGPC2\'s halucp.c substitutes for.',
  'USA003090 Appendix D', 'implemented', 'INTRAP/IOCODE directly match halucp.c\'s own known trap-address/iocodeAddr field names -- '
  'strong confirmation this family is the authoritative source protocol for what HalUCP already implements.',
  'tested_dedicated', CORPUS)
F('Runtime Library Routine', 'Unlabeled CSECT families (VR*, MSTR, OUTER1, CSTRUC, CSLD/CSST/CSHAPQ/QSHAPQ)',
  'Several Appendix D entries with no description column and no confident cross-reference found.',
  'USA003090 Appendix D', 'unresolved', 'Genuinely unresolved by this survey -- Appendix D itself gives no prose description for these; would need Language Spec (USA003088) cross-reference.', 'untested')

# --- Reentrancy / Exclusion -----------------------------------------------------------------
F('Reentrancy/Exclusion', 'EXCLUSIVE procedures/functions', 'At most one process may be inside an EXCLUSIVE block at a time; others WAIT.',
  'USA003087 §27.2', 'not_implemented',
  "NEW FINDING (this survey): grep confirms zero mentions of EXCLUSIVE/mutual-exclusion enforcement "
  "anywhere in yaGPC2's source. This is a genuine RTE-level mutex mechanism, the same category of "
  "OS substitution as TASK/SCHEDULE/WAIT -- if the real compiled EXCLUSIVE-entry sequence traps via "
  "an SVC (not confirmed either way), it currently falls through to the generic unhandled-SVC path.",
  'untested')
F('Reentrancy/Exclusion', 'REENTRANT procedures/functions', 'May be invoked by multiple processes concurrently, no RTE restriction.',
  'USA003087 §27.3', 'implemented_via_cpu',
  'The "allow it" case needs no RTE enforcement; likely already correct by construction since the '
  'cooperative scheduler only ever runs one task\'s instructions at a time (no true concurrency to break).',
  'untested')
F('Reentrancy/Exclusion', 'AUTOMATIC local data in REENTRANT blocks', 'One private storage copy allocated per concurrent entry, vs. one shared static copy.',
  'USA003087 §27.3', 'unresolved',
  "Not confirmed from the manual text alone whether this is ordinary compiled stack-frame code "
  "(needing nothing from yaGPC2) or a real RTE-provided allocation service.", 'untested')

# --- Shared/Remote Data Access ---------------------------------------------------------------
F('Shared/Remote Data Access', 'LOCK(n) / LOCK(*) compool data protection + UPDATE block',
  'Declares protected compool data; an UPDATE block is the only place it may be referenced, with the '
  'RTE enforcing mutual exclusion across processes contending for overlapping lock groups.',
  'USA003087 §26.4', 'not_implemented',
  'NEW FINDING (this survey): grep confirms zero mentions of LOCK/UPDATE-block enforcement anywhere '
  'in yaGPC2\'s source -- a second genuine RTE mutex mechanism (alongside EXCLUSIVE above) with no '
  'runtime substitution at all. If real compiled code traps via an SVC on UPDATE-block entry/exit '
  '(not confirmed), it currently falls through unhandled.', 'untested')
F('Shared/Remote Data Access', 'TEMPORARY data declaration', 'Compiler storage-reuse hint inside a DO...END group.',
  'USA003087 §26.3', 'not_applicable', 'Pure compile-time storage-allocation optimization; no runtime behavior at all.', 'not_applicable')
F('Shared/Remote Data Access', 'REMOTE data placement', 'Relegates infrequently-accessed compool data to a separate storage region.',
  'USA003087 §26.3', 'not_applicable', 'Pure compile-time/linker memory-layout concern.', 'not_applicable')

# --- Bit String / Structure (compiler-resolved, "free") --------------------------------------
F('Bit String / Structure', 'Bit string operators (AND/OR/NOT/CAT), assignment, conditional use',
  'Bitwise complement/OR/AND/catenation; truncate-or-pad assignment; subscripted single-bit use as a Boolean.',
  'USA003087 §17.4-17.6', 'implemented_via_cpu', 'Ordinary compiled bit/logical-instruction execution.',
  'tested_corpus', CORPUS + ' (bit.hal, bit_index.hal, bit_index_assign.hal, bitconcat257.hal.)')
F('Bit String / Structure', 'User-defined bit-string-returning / structure-returning functions',
  'A FUNCTION declared to return BIT(n) or a whole STRUCTURE.', 'USA003087 §17.8, §19.11',
  'implemented_via_cpu', 'Ordinary compiled call/return-sequence code generation.', 'tested_corpus',
  CORPUS + ' (fcal_boolean_return.hal, inline_vector_return.hal.)')

# --- NAME/Pointer runtime behavior --------------------------------------------------------
F('NAME/Pointer Runtime Behavior', 'Indirect access, subscripting, and the NAME pseudo-function (reference/assignment)',
  'Dereferencing a NAME item (including through structure terminals, self-referential/circular chains, '
  'and SCHEDULE/task-name targets); NAME(item) as pointer-creation or assignment target.',
  'USA003087 §28.3-28.4', 'implemented_via_cpu',
  'Resolved by the compiler into ordinary address-computation/indirect-addressing instructions (the '
  'AP-101S has real indirect-addressing modes) -- a compiled SCHEDULE of a NAME-pointed-to task should '
  'already present schedule.c with an already-resolved concrete PDE address, not a pointer it has to '
  'chase itself; not independently confirmed with a live test.',
  'tested_corpus', CORPUS + ' (name.hal, named_nest176.hal.)')
F('NAME/Pointer Runtime Behavior', 'NULL pointer value, NAME initialization/assignment/comparison, pointer argument passage',
  'NULL/NAME(NULL); NAME-item DECLARE-time initialization; pointer assignment and =/NOT= comparison; '
  'passing pointer values as input/ASSIGN procedure arguments.',
  'USA003087 §28.5-28.9', 'implemented_via_cpu', 'Ordinary compiled move/compare/call-sequence instructions.',
  'tested_corpus', CORPUS + ' (name.hal.)')

def build():
    if os.path.exists(DB_PATH):
        os.remove(DB_PATH)
    con = sqlite3.connect(DB_PATH)
    con.executescript(SCHEMA)
    seen = {}
    for (category, name, description, source_ref, impl_status, impl_notes, test_status, test_notes) in FEATURES:
        k = slug(name)
        if k in seen:
            seen[k] += 1
            k = f'{k}_{seen[k]}'
        else:
            seen[k] = 0
        con.execute(
            'INSERT INTO features (key, category, name, description, source_ref, impl_status, impl_notes, test_status, test_notes) '
            'VALUES (?,?,?,?,?,?,?,?,?)',
            (k, category, name, description, source_ref, impl_status, impl_notes, test_status, test_notes))
    con.commit()
    n = con.execute('SELECT COUNT(*) FROM features').fetchone()[0]
    print(f'Built {DB_PATH} with {n} features.')
    con.close()

def connect():
    if not os.path.exists(DB_PATH):
        print(f'{DB_PATH} does not exist yet -- run: hal-runtime-features.py build', file=sys.stderr)
        sys.exit(1)
    return sqlite3.connect(DB_PATH)

def do_list(args):
    con = connect()
    q = 'SELECT id, category, name, impl_status, test_status FROM features WHERE 1=1'
    params = []
    if args.category:
        q += ' AND category LIKE ?'
        params.append(f'%{args.category}%')
    if args.impl:
        q += ' AND impl_status = ?'
        params.append(args.impl)
    if args.test:
        q += ' AND test_status = ?'
        params.append(args.test)
    q += ' ORDER BY category, id'
    for row in con.execute(q, params):
        print(f'{row[0]:4d}  [{row[3]:22s} / {row[4]:17s}]  {row[1]:38s}  {row[2]}')

def do_show(args):
    con = connect()
    for ident in args.id:
        row = con.execute('SELECT * FROM features WHERE id=? OR key=?', (ident, ident)).fetchone()
        if not row:
            print(f'-- no such feature: {ident}')
            continue
        cols = [d[0] for d in con.execute('SELECT * FROM features LIMIT 0').description]
        print('=' * 78)
        for c, v in zip(cols, row):
            print(f'{c:12s}: {v}')

def do_search(args):
    con = connect()
    like = f'%{args.text}%'
    for row in con.execute(
            'SELECT id, category, name FROM features WHERE name LIKE ? OR description LIKE ? OR impl_notes LIKE ? OR test_notes LIKE ? ORDER BY id',
            (like, like, like, like)):
        print(f'{row[0]:4d}  {row[1]:38s}  {row[2]}')

def do_stats(args):
    con = connect()
    print('-- by impl_status --')
    for row in con.execute('SELECT impl_status, COUNT(*) FROM features GROUP BY impl_status ORDER BY 2 DESC'):
        print(f'  {row[0]:22s} {row[1]:4d}')
    print('-- by test_status --')
    for row in con.execute('SELECT test_status, COUNT(*) FROM features GROUP BY test_status ORDER BY 2 DESC'):
        print(f'  {row[0]:17s} {row[1]:4d}')
    print('-- by category --')
    for row in con.execute('SELECT category, COUNT(*) FROM features GROUP BY category ORDER BY 1'):
        print(f'  {row[0]:38s} {row[1]:4d}')
    total = con.execute('SELECT COUNT(*) FROM features').fetchone()[0]
    print(f'-- total: {total} --')

def main():
    p = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    sub = p.add_subparsers(dest='cmd', required=True)

    sub.add_parser('build')

    lp = sub.add_parser('list')
    lp.add_argument('--category')
    lp.add_argument('--impl')
    lp.add_argument('--test')
    lp.set_defaults(func=do_list)

    sp = sub.add_parser('show')
    sp.add_argument('id', nargs='+')
    sp.set_defaults(func=do_show)

    se = sub.add_parser('search')
    se.add_argument('text')
    se.set_defaults(func=do_search)

    st = sub.add_parser('stats')
    st.set_defaults(func=do_stats)

    args = p.parse_args()
    if args.cmd == 'build':
        build()
    else:
        args.func(args)

if __name__ == '__main__':
    main()
