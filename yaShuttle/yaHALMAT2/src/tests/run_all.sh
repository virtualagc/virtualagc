#!/usr/bin/env bash
# Full permanent regression suite. Run after any interp.c/value.c change,
# before committing (see Plan.md M8's testing-strategy note on running
# the full suite before every commit).
set -uo pipefail
cd "$(dirname "$0")"

fail=0
run() { "$@" || fail=1; }

# INTEGER field width (11-char right-justified, num_blanks=5 separator --
# see interp.c's flush_write) is easy to mistype by hand; derive the
# expected strings for the purely-INTEGER fixtures from the *reference*
# yaHALMAT emulator (ground truth for these two -- no known reference
# bug affects them, unlike case/nested below) rather than hardcoding a
# hand-counted string of spaces or comparing against our own output.
HALSFC="/home/rburkey/git/virtualagc/yaShuttle/Source Code/PASS.REL32V0/HALSFC"
REF_YAHALMAT="/mnt/STORAGE/home/rburkey/git/Halmat/emu/yaHALMAT"
derive_expected() {
    local name="$1"
    local workdir
    workdir=$(mktemp -d)
    cp "/mnt/STORAGE/home/rburkey/git/Halmat/data/test_$name.hal" "$workdir/"
    ( cd "$workdir" && "$HALSFC" "test_$name.hal" >/dev/null 2>&1 )
    gzip -dk "$workdir/COMMON0.out.bin.gz" 2>/dev/null
    "$REF_YAHALMAT" "$workdir/halmat.bin"
    rm -rf "$workdir"
}

run ./run_fixture.sh simple_do "$(derive_expected simple_do)"
run ./run_fixture.sh ifelse "$(printf 'C IS FIVE\nDONE')"
run ./run_fixture.sh while "TOTAL=              45"
# User-reported (095-TAN_SUMS.hal): a bare `REPEAT;` statement inside a
# DO UNTIL loop failed with "branch to undefined label 2". Traced to
# PASS1.PROCS/SYNTHESI.xpl's actual REPEAT synthesis ("REPEATING:"):
# REPEAT emits a BRA whose INL operand is the enclosing loop's own
# DTST/ETST bookkeeping-label value PLUS ONE -- a number no LBL (or any
# other instruction) ever separately materializes in the HALMAT stream;
# real Pass 2 code generation resolves it structurally from loop-nesting
# state this interpreter doesn't have. Fixed by synthesizing it in
# precompute_labels(): label+1 now resolves to the exact same position
# OP_ETST's own fall-through back-edge already computes
# (etst_back_target -- the loop's per-cycle retest entry), since
# REPEAT's "abandon this cycle, retest for the next" is exactly what
# ETST itself already does on ordinary fall-through.
run ./run_local_fixture.sh repeat "          6               5"
run ./run_fixture.sh discrete_for "RESULT=              63"
run ./run_fixture.sh case "RESULT=              20"    # reference tool's "30" is its own bug -- YERRORS.md
run ./run_fixture.sh nested "K=             150"        # reference tool's "40" is its own bug -- YERRORS.md
# User-reported (080-EXAMPLE_4A.hal): a DO CASE selector outside the
# legal 1..N range failed loudly ("out-of-range/ELSE handling not yet
# implemented") instead of taking the ELSE clause. Traced via a direct
# --disasm of the real program: an ELSE clause compiles as plain in-line
# code placed immediately after DCAS itself, *before* the first ordinary
# case's CLBL -- not as an extra CLBL appended at the end, as DCAS.md/
# CLBL.md's own Unresolved Questions had speculated. Fixed by having
# OP_DCAS simply not branch at all for an out-of-range selector, letting
# ordinary sequential fall-through do the rest (falls into the ELSE body
# when one exists; falls straight into case 1's own CLBL, which
# immediately redirects to ECAS as a no-op, when it doesn't). The
# no-ELSE reading was cross-checked directly against the real AP-101S
# emulator (compileLinkRun): that specific input actually hangs the real
# runtime in an infinite loop, an apparent bug this project has no
# interest in replicating -- falling through to ECAS is the safe,
# well-defined choice instead.
run ./run_local_fixture.sh case_else "$(printf '          0      1.0000000E+02\n          1      2.0000000E+02\n          2      3.0000000E+02\n          3      4.0000000E+02\n          4      5.0000000E+02\n          5      1.0000000E+02')"
# User-reported (104-EXAMPLE_1.hal): `TMAX, TMEAN, TMIN = TIME(1);`, a
# multiple-assignment statement (USA003087 Sec. 8.5: "the value of the
# R-expression is assigned to all L1...Ln in turn"), failed with "IASN/
# SASN: expected 2 operands" -- confirmed via --disasm that same-class
# multi-assignment compiles to a single IASN/SASN with the source plus
# every receiver as its own trailing operand (operand_count = 1+N, not
# always 2). Fixed by looping over every receiver operand instead of
# hard-requiring exactly one.
run ./run_local_fixture.sh multi_assign "$(printf ' 3.5000000E+00      3.5000000E+00      3.5000000E+00\n          7               7')"
# While validating the fix above directly against USA003087 Sec. 8.5's
# own worked example (`C, I = 127.2;`, CHARACTER + INTEGER receivers,
# neither SCALAR): found that a *mixed-type* multi-assignment compiles
# to a single instruction too (here SASN, confirmed via --disasm) whose
# receivers can have completely different declared types unrelated to
# the opcode's own nominal class -- previously would have silently
# mis-formatted C as a raw SCALAR (matching I's own wrong scientific-
# notation output) instead of the CHARACTER rendering Sec. 8.5 itself
# documents (`C ≡ '1.2720000E+02'`, `I ≡ 127`). Fixed by having each
# receiver's own coercion consult its *own* declared symtab class
# (SCALAR/CHARACTER/INTEGER) rather than trusting the opcode's class for
# every receiver alike; CHARACTER reuses OP_STOC's own formatting.
run ./run_local_fixture.sh multi_assign_mixed " 1.2720000E+02             127"
run ./run_fixture.sh proc "$(derive_expected proc)"
run ./run_fixture.sh array ""
run ./run_fixture.sh matrix ""
run ./run_local_fixture.sh sched_high "$(printf 'BEFORE SCHEDULE\nWORKER RUNNING\nAFTER SCHEDULE')"
# WORKER is DEPENDENT, so per USA003087 Sec. 13.3 (see class-0/SCHD.md's
# "Waiting For Dependents At CLOSE" section, added in a later session) the
# primal doesn't halt at its own CLOSE while WORKER is still active -- it
# waits, so WORKER (lower priority, never preempts the primal, but still
# gets its turn once nothing higher-priority is left to run) now correctly
# executes before the whole program ends. Previously "WORKER RUNNING" never
# appeared at all -- a real yaHALMAT2 bug (the primal halted unconditionally
# at CLOSE, ignoring any still-active DEPENDENT task), not the intended
# behavior this fixture was meant to lock in.
run ./run_local_fixture.sh sched_low "$(printf 'BEFORE SCHEDULE\nAFTER SCHEDULE\nWORKER RUNNING')"
run ./run_local_fixture.sh scalar_arith " 3.7500000E+00"
run ./run_local_fixture.sh scalar_sub "-7.5000000E-01"
run ./run_local_fixture.sh scalar_muldiv "$(printf ' 1.0000000E+01\n 3.3333331E-01')"
run ./run_local_fixture.sh int_arith2 "P=              12     N=              -3     E=              27"
run ./run_local_fixture.sh scalar_cmp "$(printf 'LESS\nEQUAL\nAND-TRUE\nNOT-TRUE')"
run ./run_local_fixture.sh logical_or "OR-TRUE"
run ./run_local_fixture.sh mixed_type "S2=      5.5000000E+00"
# User-reported (GOOGLE-PARALLAX.hal's SCALAR DOUBLE `DISTANCE` printing
# with single-precision formatting). Traced to two compounding bugs in
# OP_IASN/OP_SASN (interp.c): (1) class-6/IASN.md's long-documented-but-
# never-fixed "whole-valued literal" quirk -- PASS1 emits IASN, not SASN,
# for a genuinely SCALAR receiver whenever the literal happens to be
# whole-valued (`EOR = 93000000.0;`), silently mistyping the destination
# SYT_TYPE_INTEGER; (2) even via ordinary SASN, a literal's own encoded
# precision (always single, litfile) was never widened to a DOUBLE
# receiver's declared precision on assignment. Both fixed the same way:
# consult the symbol table's declared class/precision (same technique as
# TINT's per-field correction and bind_call_argument's parameter-
# precision conversion) and let it override the opcode's nominal class
# and normalize precision on every write to a plain SCALAR destination.
run ./run_local_fixture.sh scalar_double "$(printf ' 9.3000000000000007E+07\n 5.0000000000000000E-01\n 1.7023535811925805E+08')"
# This WRITE statement's 8 fields ('I1=',I1,'I2=',I2,'I3=',I3,'I4=',I4)
# total 91 columns -- past the 80-column line_length default added this
# session (--line-length, USA003087 Sec. 12.2's "unpaged output: [80
# columns/line]"), so the last field wraps onto its own line. The
# reference yaHALMAT emulator (ground truth elsewhere in this file)
# predates this feature and doesn't wrap at all -- not a discrepancy,
# just untested behavior on its part; this fixture is the one that
# happens to be long enough to exercise the new wrap.
run ./run_local_fixture.sh stoi "$(printf 'I1=               7     I2=               8     I3=              -8     I4=\n         -7')"
run ./run_local_fixture.sh char "$(printf 'HELLOHELLO\nEQUAL\nLESS')"
run ./run_local_fixture.sh char_conv "$(printf '42\n 3.5000000E+00\n42\nI2=             123\nS2=      7.5000000E+00')"
run ./run_link_fixture.sh "Y=              43" link_pool link_prog
# User-reported sweep item: ARRAY/MATRIX-typed EXTERNAL COMPOOL variables
# were silently dropped to a null/empty container (main.c's import loop
# hardcoded elements=NULL, "not yet supported") -- previously masked by
# the same missing-field bug also affecting BIT/CHARACTER scalars
# (bit_value/char_value were never copied either, only value/scalar).
# Both fixed with a proper deep copy out of the auxiliary unit's SYT
# entry before it's interp_cleanup()'d. SHARED_ARR (ARRAY(3) INTEGER)
# comes across the COMPOOL link intact.
run ./run_link_fixture.sh "$(printf ' 1.0000000E+01      2.0000000E+01      3.0000000E+01')" link_pool_array link_prog_array
run ./run_ext_func_fixture.sh "$(printf '          1      1.0000000E+00      1.0000000E+00\n          2      4.0000000E+00      1.4142132E+00\n          3      9.0000000E+00      1.7320499E+00')" ext_mytable ext_square ext_squroo
run ./run_ext_func_fixture.sh "          5              10" ext_pcal_prog ext_double
# User-reported sweep item: an external (cross-unit) FUNCTION returning a
# CHARACTER value previously failed loudly -- interp_copy_external_call_
# result() was copying the whole VAC-slot struct verbatim from the
# callee's own state into the caller's, which would alias the owned
# char*/container heap pointer between two independently-cleaned-up
# interp_state_t's (a double-free waiting to happen), so it refused to
# even try. Fixed with a deep copy (dup_string), same convention used
# throughout this file for every other owned-string handoff. (The
# MATRIX/VECTOR half of this is still blocked -- turned out to be a much
# deeper, pre-existing gap: OP_RTRN always resolves its return value via
# resolve_operand(), which has no representation for a whole array at
# all, so `RETURN <whole VECTOR/MATRIX>;` fails identically even for a
# same-unit call, external or not -- comparable in depth to task #16's
# already-deferred ARRAY-of-VECTOR/MATRIX gap, not something this fix
# alone can close. The container-copy half of interp_copy_external_call_
# result() is implemented and ready for whenever RTRN itself gains that
# capability.)
run ./run_ext_func_fixture.sh "$(printf 'ONE\nOTHER')" ext_charfunc_prog ext_charfunc

# --link-only / linked-archive-container round trips (self-contained
# compressed file built from an @list, run positionally with no @list
# directory tree needed -- see reengineered-documentation/MULTI-FILE-
# LINKING.md's container-format section). Round-trip both the EXTERNAL
# COMPOOL and EXTERNAL FUNCTION linking cases above through it (proving
# the linking logic itself survives), plus a minimal CHARACTER-literal-
# only fixture that specifically exercises the string-blob mechanism
# replacing the 16MB memory image (would fail or print blank/wrong output
# if that plumbing were broken or omitted).
run ./run_link_container_fixture.sh --plain 150000 "Y=              43" link_pool link_prog
run ./run_link_container_fixture.sh --tmpl 150000 "$(printf '          1      1.0000000E+00      1.0000000E+00\n          2      4.0000000E+00      1.4142132E+00\n          3      9.0000000E+00      1.7320499E+00')" ext_mytable ext_square ext_squroo
run ./run_link_container_fixture.sh --plain 50000 "HELLO CONTAINER" link_lit

# --debug + @list: works for a single-unit @list (previously silently
# ignored -- debug_mode was parsed but never threaded through
# run_linked()/run_linked_units()), fails loudly for a multi-unit one
# rather than silently ignoring --debug (real multi-unit interactive
# debugging isn't implemented).
run ./run_debug_link_fixture.sh

run ./run_local_fixture.sh write_lit "          5      3.5000000E+00"
run ./run_read_fixture.sh read_write "42 3.5" "I1=              42     S1=      3.5000000E+00"
run ./run_read_fixture.sh rdal "HELLO WORLD" "$(printf 'HELLO\nWORLD')"
# USA003087 Sec. 12.3: READ data fields are separated by "a comma and/or
# at least one blank" -- fscanf's own %lf/%ld/%s skip leading whitespace
# but not a leading comma, so any comma-separated READ input (user-
# reported against 037-ROOTS.hal's `READ(5) A, B, C;`) previously failed
# outright with "end of input or malformed SCALAR/INTEGER" on the first
# comma. Also exercises that section's "two consecutive separating
# commas" rule (the field between them is left untouched, not read as
# zero/blank) -- S2 stays at its pre-READ value (99.5) across the "1,,3"
# double comma.
run ./run_read_fixture.sh read_comma "$(printf '1,,3\n42\n')" "$(printf -- ' 1.0000000E+00      9.9500000E+01      3.0000000E+00              42')"
# USA003088 Sec. 10.1.1 rule 6's null-field mechanism doesn't special-
# case "nothing precedes the first field" out of its general definition
# -- a *leading* comma (before any field has been read at all) nulls
# the first item exactly like a doubled mid-list comma nulls a later
# one (user-reported, extending the read_comma fixture above). This
# needed a real fix, not just a guard removal: naively calling the same
# "consume one comma, then peek for a second" logic for the first item
# too shifts every subsequent field over by one instead of nulling just
# the first (A=2, B=3, C starves) -- read_skip_separator's `i > 0`
# parameter distinguishes "a separator is expected here" (every item
# after the first) from "only peek, nothing is expected to precede this
# one" (the first item only).
run ./run_read_fixture.sh read_leading_comma "$(printf ',2,3\n')" "$(printf -- '-1.5000000E+00      2.0000000E+00      3.0000000E+00')"
# USA003088 Sec. 10.1.1 rule 5, confirmed by "Programming in HAL/S" Sec.
# 8.3 p. 153's own worked example (this fixture's exact input/values,
# user-reported): a semicolon reached where READ data was expected
# terminates the *entire remaining list* (not just the one field a
# comma would null) -- the documented mechanism for "process a variable
# number of input values," previously a hard parse error in yaHALMAT2
# rather than a legal, useful idiom. Also caught a real bug in the
# first attempt at this fix before considering it done: the function's
# "no comma found, must be space-only separation" early-return path
# skipped the semicolon check entirely, so this exact fixture's input
# still failed even after "leading semicolon with nothing else" alone
# appeared to work.
run ./run_read_fixture.sh read_semicolon "$(printf '1.5, 2.6;\n')" "$(printf -- ' 1.5000000E+00      2.5999994E+00     -3.5000000E+00')"
# User-reported, found while re-checking read_semicolon against a real
# multi-iteration loop (037-ROOTS.hal): read_skip_separator deliberately
# leaves a terminating semicolon unconsumed in the stream (see its own
# comment), but nothing was discarding it before the *next* READ
# statement -- so that next READ saw the leftover semicolon as its own
# first character, terminated instantly without reading any of the
# second line's data, and left A/B/C unchanged. In a real DO WHILE TRUE
# input loop this repeats forever: the same stale values get reused every
# iteration and the program never actually blocks for new user input
# again. Fixed per USA003087 Sec. 12.3's own documented default: "the
# device mechanism moves down one line from its current position" at the
# start of every READ but a device's very first -- discarding whatever
# the previous READ left unconsumed (the semicolon here) before starting
# its own field scan. This fixture's second iteration (input "4,5,6")
# only reads correctly if that discard happens.
run ./run_read_fixture.sh read_semicolon_loop "$(printf '1,2;\n4,5,6\n')" "$(printf -- ' 1.0000000E+00      2.0000000E+00     -9.5000000E+00\n 4.0000000E+00      5.0000000E+00      6.0000000E+00')"
# User-reported (164-OUTER.hal's `READALL(INFILE) VNAME; ... READ(INFILE)
# SKIP(0), COLUMN(9), PHI;` idiom -- peek a line's leading fixed-column
# token via READALL, then conditionally re-read that same line's
# remaining fixed-column data): READ's TAB/COLUMN/SKIP/LINE/PAGE control
# specifiers (class-0/XXAR.md's confirmed TAG2 encoding) failed loudly,
# entirely unimplemented. Implemented SKIP(n)/COLUMN(n) only (TAB/LINE/
# PAGE have no confirmed READ-context meaning and no fixture/corpus
# program needs them -- still fail loudly): a new per-device
# device_line_start ftell() offset (state.h), updated whenever a newline
# is actually consumed, lets COLUMN(n) seek to an absolute column within
# the *current* line (not wherever the previous field's own fscanf
# happened to leave the cursor); SKIP(0) suppresses the usual single-
# line advance entirely (deliberately leaving device_line_start
# untouched -- still the same line), SKIP(n>=1) advances n lines. Works
# even over a genuine non-seekable pipe (glibc's stdio buffering permits
# an already-buffered-data-only fseek/ftell without a real lseek()
# syscall), confirmed directly against this exact fixture.
run ./run_read_fixture.sh read_skip_column "$(printf 'PHI     1.5\nALPHA   2.5\nMODE    3\nEND\n')" "$(printf ' 1.5000000E+00      2.5000000E+00               3')"
# User-reported (044-ORTHONORMAL.hal's `READ(5) X;`, X a VECTOR(3)):
# READ against a whole VECTOR/MATRIX destination failed outright
# ("only CHARACTER/SCALAR/INTEGER arguments are implemented (got HALMAT
# class 4)") -- XXAR's TAG1=4=VECTOR/3=MATRIX arrives as a single
# unreplayed whole-SYT operand (class-0/XXAR.md's confirmed "no ADLP/
# DLPE replay" shape, same as the already-handled WRITE/CALL
# whole-container case), not a per-element list this interpreter already
# understood. Fixed per USA003087 Sec. 12.3 ("a vector data item causes
# one data field per vector element to be read... a matrix... row by
# row" -- the same unrolled order WRITE/INITIAL already use): OP_READ
# now unrolls a whole-container destination into one field read per
# element directly, sharing the exact same null-field/semicolon-
# terminate rules as any other item.
run ./run_read_fixture.sh read_vecmat "$(printf '1,2,3\n4,5,6,7\n')" "$(printf -- ' 1.0000000E+00      2.0000000E+00      3.0000000E+00\n 4.0000000E+00      5.0000000E+00\n 6.0000000E+00      7.0000000E+00')"
# Edge case the plain read_vecmat fixture above doesn't exercise: a
# whole-container item sandwiched between two ordinary scalar items in
# the same READ statement (`READ(5) A, V, B;`), confirming (1) the
# separator between A and V's first element is still correctly required
# (any_field_read, not simply "item index > 0", now that a single item
# can expand into several fields -- see OP_READ's own comment) and (2) a
# semicolon reached mid-container terminates the *whole remaining
# statement*, leaving both the rest of V (its 3rd element) and the later
# scalar B untouched, exactly like a semicolon between two ordinary
# items.
run ./run_read_fixture.sh read_vecmat_edge "$(printf '1,2,3;\n')" "$(printf -- ' 1.0000000E+00\n 2.0000000E+00      3.0000000E+00     -9.5000000E+00\n-7.5000000E+00')"
run ./run_local_fixture.sh pcal "RESULT=              15"
run ./run_local_fixture.sh bit "I1=               8     I2=              14     I3=             -13"
run ./run_local_fixture.sh scalar_exp "$(printf ' 8.0000000E+00\n 8.0000000E+00\n 2.5000000E-01\n 1.4142132E+00')"
run ./run_local_fixture.sh matrix_sub "$(printf ' 5.0000000E+00\n 3.0000000E+00\n 4.0000000E+00')"
# User-reported (047-ROWS.hal's `M$(I,*) = C * MM$(I,*);`): a MATRIX
# row-partition select used as an *assignment receiver* failed with
# "MASN/VASN: receiver must be SYT" -- OP_MASN/OP_VASN only ever accepted
# a plain whole-SYT destination, never a QUAL_VAC row-select result (the
# same DSUB asterisk-partition mechanism already readable as a WRITE/CALL
# source, class-0/DSUB.md). Fixed by having DSUB's row-select (`M$(i,*)`)
# and whole-vector (`V$(*)`) cases -- both genuinely *contiguous* in
# row-major storage -- additionally mark their VAC result as a live,
# writable view into the base MATRIX/VECTOR's own storage (new
# is_container_ref/container_ref_syt/container_ref_offset fields,
# state.h), which MASN/VASN now recognizes and writes straight back
# into instead of failing. Exercises all three idioms from the real
# program: scaling a row by a constant, adding a scaled row to another
# row, and swapping two rows via a VECTOR temporary.
run ./run_local_fixture.sh matrix_row_assign "$(printf ' 2.2000000E+01      2.4000000E+01      2.6000000E+01\n 2.1000000E+01      2.2000000E+01      2.3000000E+01\n 3.1000000E+01      3.2000000E+01      3.3000000E+01\n 2.1000000E+01      2.2000000E+01      2.3000000E+01\n 1.1000000E+01      1.2000000E+01      1.3000000E+01\n 3.1000000E+01      3.2000000E+01      3.3000000E+01')"
# Follow-up to the row-select fix above, same user report (047-ROWS.hal):
# a column select (`M$(*,j) = C * MM$(*,j);`) was originally left
# deliberately unmarked/read-only, since row-major storage makes it
# non-contiguous (stride = column count, not 1). Generalized the
# is_container_ref mechanism with a new container_ref_stride field
# (state.h) -- 1 for the row-select/whole-vector cases, cols for a
# column select -- so MASN/VASN's write-back loop (interp.c) now
# handles both uniformly instead of memcpy-ing a fixed contiguous run.
# (Also considered making the same generalization apply to DSUB's
# component at-partition VECTOR-slice case, `V$(n AT p)`, as a related
# "other issue" -- but confirmed via HALSFC that real HAL/S rejects
# `V$(n AT p) = ...;` at compile time regardless of source shape, so
# that case is intentionally left read-only; no real program can ever
# reach a writable form of it.)
run ./run_local_fixture.sh matrix_col_assign "$(printf ' 1.1000000E+01      2.4000000E+01      1.3000000E+01\n 2.1000000E+01      4.4000000E+01      2.3000000E+01\n 3.1000000E+01      6.4000000E+01      3.3000000E+01')"
run ./run_local_fixture.sh matvec "$(printf ' 6.0000000E+00\n 8.0000000E+00\n 1.0000000E+01\n 1.2000000E+01\n 1.9000000E+01\n 2.2000000E+01\n 4.3000000E+01\n 5.0000000E+01')"
run ./run_local_fixture.sh vec "$(printf ' 3.2000000E+01\n-3.0000000E+00\n 6.0000000E+00\n-3.0000000E+00')"
run ./run_local_fixture.sh bit_conv "$(printf ' 1.2000000E+01\n12\nBEQU-TRUE\n         12')"
run ./run_local_fixture.sh init8 "$(printf '      43690\n 9.0000000E+00\n 9.0000000E+00\n 4.0000000E+00')"
run ./run_local_fixture.sh vshp "$(printf ' 1.0000000E+00\n 2.0000000E+00\n 3.0000000E+00')"
# User-reported (044-ORTHONORMAL.hal's `DETERMINANT = DET(MATRIX(X, Y,
# Z));`/`V = MATRIX(A1, A2, A3) V;`): MSHP (list-form MATRIX(...)) was a
# hard "not yet implemented" stub. [USA003088] Sec. 6.6's general <arith
# conversion> rule governs MATRIX/VECTOR/SCALAR/INTEGER shaping functions
# uniformly: every SFAR argument is "unraveled" into a flat sequence of
# scalar elements (a whole VECTOR/MATRIX argument contributes its own
# elements, not just one; a plain scalar/integer expression contributes
# one), which is then "reraveled" into the result shape. Two real forms
# both compile to the *identical* MSHP operand value (confirmed this
# session via unHALMAT.py): the row-vector form 044-ORTHONORMAL.hal
# actually uses (`MATRIX(X, Y, Z)`, 3 whole-VECTOR SFARs) and the flat
# scalar-list form USA003087's own worked example shows
# (`MATRIX(1,2,...,9)`, 9 plain-scalar SFARs) -- ruling out inferring the
# result shape from the SFAR list's own count/shape (right for the first
# form only, by coincidence). Fixed by decoding MSHP's own operand
# directly instead (confirmed decimal 771=0x0303 for the unsubscripted
# "assumed 3 by 3" default, [USA003088] Sec. 6.6 semantic rule 1 --
# high-byte=rows/low-byte=cols) and unraveling every SFAR argument
# uniformly via a new unravel_shaping_argument() helper, shared with
# VSHP/SSHP/ISHP (which needed the same generalization -- they previously
# only handled plain-scalar arguments, silently wrong for a
# whole-VECTOR/MATRIX argument even though the same Sec. 6.6 rules cover
# that case for them too). This fixture exercises both confirmed forms
# into the same 3x3 result. See MSHP.md's own comment in interp.c for
# why the explicit MATRIXm,n(...) subscript form's real source syntax
# remains unconfirmed (several plausible spellings tried, all rejected by
# the real compiler) -- not needed for either form this fixture covers.
run ./run_local_fixture.sh mshp "$(printf ' 1.0000000E+00      2.0000000E+00      3.0000000E+00\n 4.0000000E+00      5.0000000E+00      6.0000000E+00\n 7.0000000E+00      8.0000000E+00      9.0000000E+00\n 1.0000000E+00      2.0000000E+00      3.0000000E+00\n 4.0000000E+00      5.0000000E+00      6.0000000E+00\n 7.0000000E+00      8.0000000E+00      9.0000000E+00')"
# Found while testing SSHP/ISHP after fixing MSHP above (not itself
# user-reported, but the user asked to fix "anything else... encountered
# along the way"): `SA = SCALAR(S1, S2);` (SA a SCALAR ARRAY(2)) silently
# wrote 0.0 into every element instead of S1/S2's real values, no error
# at all. ARRAY has no dedicated whole-container assign opcode the way
# VECTOR/MATRIX get VASN/MASN (which read a shaping-function's VAC result
# via resolve_container and already worked correctly) -- HALSFC instead
# emits a plain SASN/IASN wrapped in an ADLP/DLPE replay, re-executing it
# once per element (confirmed via a debug trace this session: the
# replay's own arrayed_index correctly cycled 0,1 across two real
# write_destination calls, both correctly identifying SA as array-shaped
# -- the *source* side was the actual bug). resolve_operand's QUAL_VAC
# case never checked slot->is_container at all, so a shaping-function
# result read this way fell through to the plain-INTEGER default branch,
# silently returning a stale zero (state->vac[...].integer, never set by
# store_container_result) instead of failing or reading the right
# element. Fixed by adding an is_container branch that indexes the
# container by arrayed_index (mod element count), matching this same
# function's own QUAL_SYT whole-array-during-replay case.
run ./run_local_fixture.sh sshp_ishp "$(printf ' 1.5000000E+00      2.5000000E+00\n 1.0000000E+01      2.0000000E+01')"
run ./run_local_fixture.sh bfnc "$(printf ' 1.4142132E+00\n 3.5000000E+00\n-1.0000000E+00\n 2.0000000E+00\n 5.0000000E+00')"
# User-reported (046-XYZ_TO_POLAR.hal's `ARCTAN(P$2 / P$1) DEGREES_PER_RADIAN`):
# BFNC selector 37 (ARCTAN, class-0/BFNC.md's alphabetical XMSHP... no, BI_NAME
# built-in-function table -- ABS=1,...,ARCCOS=35,ARCSIN=36,ARCTAN=37) was
# entirely unimplemented ("unknown/unimplemented built-in function selector
# 37"). USA003087 Appendix B: ARCTAN(a) = tan^-1(a), no restricted domain
# (unlike ARCSIN/ARCCOS/ARCTANH's documented |a|<1 limits) and no
# USA003090 Appendix C error-fixup entry either -- a plain libm atan() call
# is correct with no guard needed, added alongside the existing ABS/COS/
# EXP/LOG/SIN/TAN/SIGN/SQRT/ROUND selector group.
run ./run_local_fixture.sh arctan " 7.8539813E-01"
# Same 046-XYZ_TO_POLAR.hal report, second bug hit immediately after fixing
# ARCTAN above: `ABVAL(P$(2 AT 1))` ("2 elements starting at position 1", a
# VECTOR sub-vector slice) failed with "operand is not a MATRIX/VECTOR
# intermediate result". class-0/DSUB.md already fully documented this wire
# shape from an earlier session (TAG1=3 on both subscript operand words --
# the "component" at-partition row, distinct from TAG1=7's ARRAY-dimension
# at-partition -- argument order confirmed "length AT position") but the
# interpreter never implemented it, only the asterisk/plain-index kinds.
# Fixed with a dedicated OP_DSUB branch (single-dimension VECTOR/ARRAY
# only, matching what's confirmed/needed -- a MATRIX at-partition needs a
# third operand for the other, plainly-indexed dimension and isn't
# handled) producing a VECTOR-shaped VAC container result, same mechanism
# the existing asterisk-partition case already uses.
run ./run_local_fixture.sh vec_atpartition "$(printf ' 1.0000000E+00      2.0000000E+00\n 3.6055508E+00')"
run ./run_local_fixture.sh minv "$(printf ' 5.9999996E-01\n-6.9999999E-01\n-1.9999999E-01\n 3.9999998E-01')"
run ./run_local_fixture.sh bfnc_inv "$(printf ' 5.9999996E-01\n 3.9999998E-01')"
# BFNC selector 3 (DET, class-0/BFNC.md): a whole-MATRIX argument (`WRITE(6)
# DET(A2);`) used to hit resolve_operand's arrayed-paragraph-replay guard,
# since OP_BFNC only exempted ABVAL/UNIT/INVERSE from it, not DET -- "SYT
# index N is a whole ARRAY/VECTOR/MATRIX referenced outside an
# arrayed-paragraph replay".
run ./run_local_fixture.sh bfnc_det "$(printf -- '-1.9000000E+01\n 1.8000000E+01')"
# USA003090 App. C's group-4 "standard fixups" for execution-time errors
# (STATUS.md's Class 0 section has the full per-error trace): errors 27
# (INVERSE of a singular matrix -> identity, both BFNC's INVERSE selector
# and MINV's `M**(-1)`), 28 (UNIT of a null vector -> the input vector
# itself), and 25 (MATRIX/scalar division by zero -> the original
# matrix). Also exercises this session's MINV finding that the opcode is
# general matrix exponentiation (`M**N`), not INVERSE-only -- N=0/2 here.
run ./run_local_fixture.sh errfix_matrix "$(printf -- ' 1.0000000E+00      0.0          \n 0.0                1.0000000E+00\n 0.0                0.0                0.0          \n 7.0000000E+00      1.0000000E+01\n 1.5000000E+01      2.2000000E+01\n 1.0000000E+00      0.0          \n 0.0                1.0000000E+00\n-1.9999990E+00      9.9999994E-01\n 1.5000000E+00     -4.9999994E-01\n 1.0000000E+00      0.0          \n 0.0                1.0000000E+00\n 1.0000000E+00      2.0000000E+00\n 3.0000000E+00      4.0000000E+00')"
# ON ERROR's user-statement (GOTO) form (class-0/ERON.md), USA003087 Sec.
# 25 -- a user-reported bug against a modified 029-DATATYPES.hal (adding
# ON ERROR/OFF ERROR around the INVERSE-of-a-singular-matrix section):
# the statement immediately after `ON ERROR$(4:27) GO TO SKIPPED;` was
# being skipped even though no error had occurred yet, as if ON ERROR
# reacted to a *past* error rather than arming a handler for a *future*
# one. Root cause: OP_ERON was a complete no-op, so the inline compiled
# handler body (the `GO TO SKIPPED` itself, placed directly after ERON
# in the HALMAT stream) executed unconditionally on normal fall-through
# instead of being skipped past to the compiler's own "bookkeeping
# label" -- exactly the branch ERON.md's own compiled trace already
# showed as part of ERON's *own* object code ("BC 7,L#1 <- unconditional
# branch skipping the handler code in normal flow"), not a separate
# HALMAT instruction as an earlier session's comment here assumed.
run ./run_local_fixture.sh eron_goto "$(printf -- 'BEFORE TRAP      1.0000000E+00      0.0          \n                 0.0                1.0000000E+00\nAFTER ON ERROR\nAFTER SKIPPED LABEL\nAFTER RESTORE      1.0000000E+00      0.0          \n                   0.0                1.0000000E+00')"
# Per direct instruction, every App. C fixup site implemented this
# session now consults the ON ERROR table (not just INVERSE's error 27,
# the one a bug report happened to exercise) -- spot-checks a GOTO
# handler firing at four of them across three different opcode families
# (BFNC's shared arithmetic case for SQRT/error 5, BFNC's UNIT/error 28,
# the combined MSPR/MSDV/VSPR/VSDV case/error 25, and SPEX/error 4), plus
# confirming SYSTEM correctly restores the ordinary fixup afterward.
run ./run_local_fixture.sh eron_goto_appc "$(printf -- 'AFTER SQRT TRAP\nAFTER UNIT TRAP\nAFTER MDIV TRAP\nAFTER ZEROPOW TRAP\nRESTORED SQRT      2.0000000E+00')"
# Same table, the plain-SCALAR-argument errors: 5 (SQRT<0 -> sqrt(|x|)),
# 7 (LOG<=0 -> 0: -max value, else log(|x|)), 6 (EXP>174.673 -> max
# value), 24 (negative-base exponentiation -> |A|**B, via SEXP), and 4
# (0**B, B<=0 -> 0, across SEXP/SPEX/SIEX's three different HALMAT
# opcodes for "non-literal", "literal>=0", and "literal any-sign"
# exponents respectively).
run ./run_local_fixture.sh errfix_scalar "$(printf -- ' 2.0000000E+00\n-7.2370051E+75\n 1.6094370E+00\n 7.2370051E+75\n 1.9999990E+00\n 0.0          \n 0.0          \n 0.0          ')"
# Errors 11 (TAN |arg| too large -> 1), 8 (SIN/COS |arg| too large ->
# sqrt(2)/2), and 15 (SCALAR too large for INTEGER conversion -> the
# maximum representable value -- this emulator's own INT32 range, since
# INTEGER here is always a plain int32_t with no SINGLE/DOUBLE precision
# distinction modeled, unlike the primary source's 16-bit halfword
# default; see value.c's halmat_scalar_to_integer).
run ./run_local_fixture.sh errfix_trig "$(printf ' 1.0000000E+00\n 7.0710677E-01\n 7.0710677E-01\n 2147483647')"
run ./run_local_fixture.sh eron "I1=               1"
# User-reported sweep item: ERON's "AND SET/RESET/SIGNAL var" clause
# (class-0/ERON.md's confirmed 3-way TAG2 sub-flag) previously failed
# loudly whenever a second operand was present. Applied at the one site
# that actually detects a matching group-4 (App. C) error --
# arithmetic_error_should_apply_fixup() -- regardless of whether the main
# action is SYSTEM or IGNORE. HALSFC confirms SET/RESET require a
# LATCHED EVENT ("AN UNLATCHED EVENT MAY NOT BE SET OR RESET", RT10
# error) while plain SIGNAL works on either: EV1 (unlatched) goes from
# unset to SET via AND SIGNAL; EV2 (latched, pre-signaled TRUE) goes back
# to NOT SET via AND RESET; EV3 (latched, starts FALSE) goes to SET via
# AND SET -- each triggered by the same SQRT(-4.0) (error 4:5) fixup site
# eron_goto_appc above already exercises.
run ./run_local_fixture.sh eron_event "$(printf 'EV1 SET\nEV2 NOT SET\nEV3 SET')"
run ./run_local_fixture.sh subbit "$(printf '          5\n         42')"
# User-reported sweep item: SUBBIT's assignment context (`SUBBIT(x) =
# ...;`, class-1/ITOQ.md's shared XBTOQ family, TAG=1) previously failed
# loudly. ITOQ.md's own confirmed trace shows this opcode's VAC result
# supplies the *receiver* for a following BASN rather than a value (the
# same "produces a reference for the next instruction to write through"
# shape DSUB already uses, but targeting a plain SYT's own raw storage
# instead of a container element) -- new is_subbit_ref VAC-slot field
# (state.h) plus a write_destination case (interp.c) that reinterprets
# the assigned bit pattern per the target's declared type (only
# INTEGER/BIT have a confirmed lossless mapping; SCALAR/CHARACTER still
# fail loudly, no hardware byte-layout modeled). I1 (never written
# before, so its type must be pulled from the symbol table rather than
# write_syt_entry's usual first-write inference) becomes 61680 (BIN
# '1111000011110000' as an unsigned pattern); B1 becomes the same bits
# verbatim.
run ./run_local_fixture.sh subbit_assign "$(printf '      61680\n1010 1010 1010 1010')"
run ./run_local_fixture.sh name "$(printf 'NEQU-TRUE\nNNEQ-TRUE')"
run ./run_local_fixture.sh cfor "LASTI=               5"
# EXIT loop-label; (found while chasing the READ comma-separator bug
# above, against the same user-supplied 037-ROOTS.hal): compiles to a
# plain BRA targeting the enclosing DTST/ETST pair's own bookkeeping-
# label number, which precompute_labels() never registered anywhere
# (DTST/ETST aren't OP_LBL, and precompute_loop_targets() only indexes
# by instruction position, never by that label number) -- every EXIT
# statement failed with "branch to undefined label N". See
# precompute_labels()'s own updated comment for why the landing position
# is ETST's position + 1, not ETST's position itself.
run ./run_local_fixture.sh exit_loop "DONE               3"
run ./run_local_fixture.sh struct "$(printf 'TEQU-TRUE\nTNEQ-TRUE\n          5\nTASN-COPIED')"
run ./run_local_fixture.sh adlp "$(printf ' 3.0000000E+00\n 3.0000000E+00\n 3.0000000E+00')"
run ./run_local_fixture.sh lfnc "$(printf ' 9.0000000E+00\n 2.0000000E+00')"
run ./run_local_fixture.sh idlp "$(printf ' 4.0000000E+00\n 4.0000000E+00\n 4.0000000E+00')"
run ./run_local_fixture.sh stri "$(printf ' 1.5000000E+00\n 1.5000000E+00\n 1.5000000E+00')"
# Explicit-literal-list VECTOR/MATRIX INITIAL() -- bare STRI/SINT/ETRI, no
# SLRI at all, run length carried in SINT's LIT operand's own tag1 byte
# (class-8/SINT.md). vecinit_split additionally covers a coalescing break
# (the compile-time `-5` expression's own unused "5" literal splits the
# run into two SINTs with a non-zero second OFF).
run ./run_local_fixture.sh vecinit "$(printf ' 1.0000000E+01\n 1.1000000E+01\n 1.2000000E+01')"
run ./run_local_fixture.sh vecinit_split "$(printf ' 1.0000000E+00\n-5.0000000E+00\n 3.0000000E+00')"
# BIT/CHARACTER ARRAY explicit-literal-list INITIAL(): BINT/CINT share
# SINT's xint_offset_run OFFSET-addressed run-length write, and their
# element storage (state.h's bit_elements/char_elements, dispatched by
# ensure_container from the symbol table's declared ARRAY element type)
# is exercised on both the write (INITIAL()) and read (unsubscripted
# whole-ARRAY WRITE, which enumerates every element) sides. Expected
# value for B (a BIT ARRAY(3) BIT(4)) updated this session: previously
# "1 2 3" was the *old bug's* output (a BIT WRITE field silently
# misformatted as plain INTEGER -- see CLAUDE_LOG.md's BIT-WRITE-
# formatting entries -- coincidentally numeric-looking here since
# BIN'0001'/'0010'/'0011' also equal 1/2/3 as plain integers, which is
# exactly why this discrepancy went unnoticed until BIT WRITE formatting
# was actually implemented); "0001 0010 0011" is the correct binary-
# digit-string format at B's real declared per-element width (4), not
# the fallback 32 -- this fixture is also what caught symtab.c's own
# separate bug (BIT ARRAY per-element width was silently discarded
# whenever a BIT symbol was also ARRAY-shaped, since the shape-resolving
# if/else chain treated "has an ARRAY shape" and "is BIT-typed" as
# mutually exclusive when a symbol can genuinely be both).
run ./run_local_fixture.sh arrinit_types "$(printf 'AB     CD     EF\n0001     0010     0011')"
# INITIAL() list mixing a bare literal with n#value repeats in the same
# clause (`INITIAL(1, 3#0, 1, 3#0, 1)`, a 3x3 identity matrix): user-
# reported bug -- precompute_arrayed_paragraphs' SLRI branch scanned
# forward for the *outer* STRI group's ETRI instead of this SLRI's own
# matching ELRI, so the first SLRI's replay swallowed every following
# SINT/SLRI/ELRI up to the true end, corrupting every element after the
# first repeat group (came out 1,1,0,0,1,1,1,0,1 instead of identity).
# Every previously-tested fixture had only one SLRI...ELRI pair with
# nothing else before the group's ETRI, so this had no observable effect
# until a source combining more than one segment was tried.
run ./run_local_fixture.sh matrix_identity_init "$(printf ' 1.0000000E+00      0.0                0.0          \n 0.0                1.0000000E+00      0.0          \n 0.0                0.0                1.0000000E+00')"
# Nested repetition-factor form (USA003087 Sec. 16.2, "The factored form
# may be nested if necessary"), user-reported: `INITIAL(4#(1,5#0),1)`
# (a 5x5 identity matrix) -- a second, deeper bug than the one just
# above: the outer SLRI's own bracketed body itself contains a complete
# inner SLRI...ELRI pair (for the nested `5#0`), so a flat single-level
# replay (even with the ELRI-matching fix above) treats the inner SLRI/
# ELRI as inert no-op markers and never replays the inner group at all,
# writing its one value at the wrong offset instead of 5 correct ones.
# Fixed by making the replay itself recurse into nested SLRI-driven
# paragraphs (run_arrayed_paragraph, interp.c), accumulating each
# level's own idx*unit_size contribution (SLRI's own confirmed 2nd
# operand, "elements per repeated unit") into the absolute OFF-write
# offset. --line-length 200 keeps this fixture's expected output
# focused on the INITIAL()-value correctness rather than also
# depending on line-wrap arithmetic (covered separately by write_wrap).
run ./run_local_fixture.sh matrix_identity5_init "$(printf ' 1.0000000E+00      0.0                0.0                0.0                0.0          \n 0.0                1.0000000E+00      0.0                0.0                0.0          \n 0.0                0.0                1.0000000E+00      0.0                0.0          \n 0.0                0.0                0.0                1.0000000E+00      0.0          \n 0.0                0.0                0.0                0.0                1.0000000E+00')" --line-length 200
# User-reported bug: `CALL some_procedure(a_whole_matrix);` failed with
# the same "outside an arrayed-paragraph replay" error as the whole-
# VECTOR/MATRIX WRITE-argument bug above, for the same reason -- a
# whole-MATRIX call argument's XXAR entry has the identical unreplayed
# QUAL=SYT shape, but OP_XXAR's whole-container detection was gated on
# WRITE only. Fixed by widening that detection to calls too, and adding
# bind_call_argument() (interp.c, shared by OP_PCAL/OP_FCAL/
# interp_prepare_external_call) to copy such an argument's elements into
# the callee's own parameter storage by value, shape-checked against the
# parameter's declared dimensions (USA003087 Sec. 11.2/11.4-11.5).
run ./run_local_fixture.sh proc_matrix_arg "$(printf '      1.0000000E+00      0.0                0.0                0.0                0.0          \n      0.0                1.0000000E+00      0.0                0.0                0.0          \n      0.0                0.0                1.0000000E+00      0.0                0.0          \n      0.0                0.0                0.0                1.0000000E+00      0.0          \n      0.0                0.0                0.0                0.0                1.0000000E+00')" --line-length 200
# User-reported bug (039-CORNERS.hal's `AB = 0;`, AB a VECTOR(2)): a
# third distinct trigger for the same "outside an arrayed-paragraph
# replay" error as the two fixtures above, this time via a plain scalar
# assignment rather than a WRITE/CALL argument. [USA003087] Sec. 8.2
# rule 3 (MATRIX)/rule 3 (VECTOR): the *only* legal non-container R-value
# for a whole VECTOR/MATRIX receiver is the literal INTEGER 0, which
# "creates a null matrix"/"creates a null vector" (every element
# zeroed) -- confirmed by compiling `V = 0;`/`M = 0;` and reading the
# real HALMAT: both compile as a single plain IASN (not VASN/MASN) with
# the whole VECTOR/MATRIX SYT as the receiver, no ADLP wrapping, since
# IASN also fires for a whole-number-literal source regardless of the
# receiver's real declared type (class-6/IASN.md's already-documented
# "leaking" behavior, here extended to VECTOR/MATRIX receivers too).
# Fixed in write_destination's whole-array-shaped QUAL_SYT branch: a
# zero-valued source against a VECTOR/MATRIX (not ARRAY, which has no
# documented equivalent idiom) receiver zeros every element directly
# instead of requiring arrayed_index >= 0.
run ./run_local_fixture.sh vecmat_null_assign "$(printf ' 0.0                0.0          \n 0.0                0.0          \n 0.0                0.0          ')"
# USA003087 Sec. 11.2/11.4's "precision conversion is allowed" MATRIX/
# VECTOR argument-transmission rule: a SINGLE MATRIX argument (A) passed
# to a DOUBLE parameter widens (scale_precision, the same exact bit-level
# rule STOS/MTOM/VTOV already use); a DOUBLE argument (B) passed to a
# SINGLE parameter narrows -- both directions bind by the *parameter's*
# own declared precision (dest_state's symbol table), not the argument's.
run ./run_local_fixture.sh proc_matrix_precision "$(printf ' 1.5000000000000000E+00      2.5000000000000000E+00\n 3.5000000000000000E+00      4.5000000000000000E+00\n 1.0500000E+01      2.0500000E+01\n 3.0500000E+01      4.0500000E+01')"
# User-reported (140-STATISTICS.hal/138-FILTER.hal/120-EXAMPLE_A.hal, all
# three real corpus programs using `PROCEDURE(...) ASSIGN(...)`): a
# CALL's ASSIGN-form argument failed loudly ("PCAL: ASSIGN-form arguments
# are not yet implemented"). class-0/XXST.md's own confirmed `CALL
# TWO(I1) ASSIGN(I1);` trace shows an ASSIGN argument as its own separate
# XXAR entry (TAG2=1) occupying the *same* positional slot scheme as
# ordinary arguments (`callee+1+i`) -- so the callee's corresponding
# parameter must be `PROCEDURE(...) ASSIGN(param_list)`'s own declared
# parameter, contiguous immediately after the ordinary ones. Fixed with a
# new is_assign flag on each io_pending item (state.h), set by OP_XXAR
# when TAG2!=0, and a write-back loop added to OP_XXND -- the exact point
# control lands back on after a completed PCAL/FCAL (RTRN/CLOS's return
# jump always targets PCAL/FCAL's position+1) -- reading the finished
# parameter's value and writing it into the caller's own ASSIGN-tagged
# operand. A second bug found while verifying this end-to-end against a
# real corpus program: ASSIGN-only parameters were initially still given
# an ordinary *input* bind (the caller's pre-call variable value) before
# the call, which pre-typed the parameter's SYT entry and silently broke
# this project's own existing IASN whole-valued-literal-into-SCALAR fix
# for the procedure body's own first real assignment to it (write_syt_
# entry's first-write type inference only fires once). Fixed by skipping
# the ordinary bind entirely for ASSIGN-only items -- they have no real
# input value anyway, so leaving the parameter fresh each call lets the
# procedure body's own first assignment establish its type correctly, the
# same as any other never-yet-written procedure-local variable.
run ./run_local_fixture.sh pcal_assign "$(printf ' 1.0000000E+01\n 1.0000000E+01')"
# User-reported (120-EXAMPLE_A.hal's `WRITE(6) AVERAGE, DATA_VALID;`,
# `DATA_VALID` an `ARRAY(4) BOOLEAN`): a whole BIT/CHARACTER ARRAY WRITE
# or CALL argument failed loudly, entirely unimplemented -- new
# is_bit_array/is_char_array io_pending item fields (state.h) borrow the
# SYT's own bit_elements/char_elements storage, rendered in flush_write
# the same per-element way a lone BIT/CHARACTER value already is.
# Verifying this against the real corpus program surfaced two further,
# genuinely separate bugs found and fixed in the same pass:
# (1) the CALL/ASSIGN write-back mechanism (the batch's earlier PCAL
# ASSIGN-form fix) didn't handle a whole-ARRAY ASSIGN parameter at all
# (`CALL ... ASSIGN(DATA_VALID, AVERAGE);`) -- extended OP_XXND's
# write-back loop with a bulk element-storage copy for that case,
# alongside the existing single-value path.
# (2) A genuine pre-existing, unrelated bug in precompute_arrayed_
# paragraphs(): the ADLP/IDLP-trailed replay paragraph's start position
# was computed from the *whole enclosing statement's* own start (the
# last SMRK) unconditionally, which happens to be correct only when the
# arrayed reference is the *first* thing in its statement -- for
# `WRITE(6) AVERAGE, DATA_VALID;` specifically, that swept AVERAGE's own
# earlier, unrelated XXAR into DATA_VALID's replay too, re-emitting
# AVERAGE once per array element instead of once. Corrected to start
# from the single instruction immediately preceding the ADLP/IDLP chain,
# walking further back only through confirmed QUAL_VAC same-statement
# dependencies (needed for e.g. `A3 = A1 + A2;`'s SADD+SASN pair, both
# needing to replay together) and excluding a SFAR-preceded chain
# entirely (a shaping-function whole-array argument, `MAX(SA1)`/etc.,
# which must never be replayed) -- found via two real regression
# fixtures (test_lfnc_array, test_adlp) this change itself initially
# broke before landing on the general fix; see
# precompute_arrayed_paragraphs()'s own comment for the full account.
run ./run_local_fixture.sh write_bit_array "$(printf ' 3.5000000E+00     0     1     0     1')"
run ./run_local_fixture.sh assign_array "$(printf ' 3.5000000E+00\n0     0     0     0')"
# User-reported bug: a PROCEDURE calling a *sibling* PROCEDURE (both
# nested directly in the same enclosing PROGRAM) failed with "call to
# undefined procedure" -- USA003087 p. 22ff's block-name scoping rules
# explicitly allow this, and HALSFC compiled it without complaint, but
# the call site's own XXST/PCAL operand doesn't carry the callee's real
# PDEF-defining symbol; the compiler emits a *separate*, alias-only
# symbol-table entry (SYM_TYPE=0x45, "IND CALL LABEL") instead, whose own
# SYM_PTR field points at the real definition. Fixed by
# resolve_call_target() (interp.c), which follows that redirect before
# treating a call operand's symbol as a callable target -- used by
# OP_PCAL, OP_FCAL, and interp_is_external_call (the debugger's step-into
# detection). Confirmed the identical alias shape is emitted for a call
# from inside a TASK block too (not just PROCEDURE/FUNCTION), so the fix
# (being purely symbol-table-driven, not block-kind-specific) covers that
# case the same way, though no TASK-based fixture is included here.
run ./run_local_fixture.sh nest_call "$(printf '      1.0000000E+00      0.0                0.0                0.0                0.0          \n      0.0                1.0000000E+00      0.0                0.0                0.0          \n      0.0                0.0                1.0000000E+00      0.0                0.0          \n      0.0                0.0                0.0                1.0000000E+00      0.0          \n      0.0                0.0                0.0                0.0                1.0000000E+00')" --line-length 200
# WRITE of a whole VECTOR/MATRIX argument (`WRITE(6) V;`): confirmed this
# session that -- unlike a plain ARRAY, which the ADLP/DLPE per-element
# replay above already covered -- this compiles as a single, unreplayed
# QUAL=SYT XXAR reference to the whole container (class-0/XXAR.md's
# formerly-unresolved "arrayed argument" question), which used to fail
# ("... referenced outside an arrayed-paragraph replay") since
# resolve_operand's ordinary QUAL_SYT case requires an active replay.
# OP_XXAR now recognizes this shape directly and flush_write expands
# every element into its own WRITE data field per USA003087 Sec. 12.2.
run ./run_local_fixture.sh write_vector "$(printf ' 1.0000000E+00      2.0000000E+00      3.0000000E+00')"
# WRITE of a whole MATRIX (row-by-row layout, second/subsequent rows
# forced onto a new line aligned under the first row's own start column,
# USA003087 Sec. 12.2), plus MATRIX row ($(1,*)) and column ($(*,2))
# partition selects -- OP_DSUB's new asterisk-subscript handling,
# producing a VECTOR-shaped VAC container consumed the same way.
run ./run_local_fixture.sh write_matrix "$(printf ' 1.0000000E+00      2.0000000E+00\n 3.0000000E+00      4.0000000E+00\n 1.0000000E+00      2.0000000E+00\n 2.0000000E+00      4.0000000E+00')"
# WRITE data-field line wrapping (default 80-column wrap point -- see
# state.h's line_length comment for why "unpaged output: 80 columns" is
# not actually why this project uses 80): an 8-element VECTOR's fields
# total 8*19-5=147 columns (14-col SCALAR field + 5-blank separator
# each, no leading separator on the first) -- wraps after 4 elements at
# the 80-column default, after 2 at an explicit --line-length 40.
run ./run_local_fixture.sh write_wrap "$(printf ' 1.0000000E+00      2.0000000E+00      3.0000000E+00      4.0000000E+00\n 5.0000000E+00      6.0000000E+00      7.0000000E+00      8.0000000E+00')"
run ./run_local_fixture.sh write_wrap "$(printf ' 1.0000000E+00      2.0000000E+00\n 3.0000000E+00      4.0000000E+00\n 5.0000000E+00      6.0000000E+00\n 7.0000000E+00      8.0000000E+00')" --line-length 40
# User-asked follow-up (044-ORTHONORMAL.hal's WRITE-formatting
# discrepancy investigation): PAGED vs UNPAGED is normally chosen by a
# compile-time DEVICE directive or JCL DD card (USA003090 Sec. 5.2),
# neither of which this interpreter has access to (just compiled
# HALMAT) -- --unpaged N is the runtime substitute, independent per
# device number (not a single global switch: a real program can mix
# PAGED and UNPAGED channels). Confirms CHARACTER WRITE output is
# identical either way except for apostrophe-quoting (USA003087 Appendix
# F / USA003090 Sec. 6.1.3, matching "Programming in HAL/S" Sec. 8.1's
# own worked example almost verbatim -- this fixture's first line is
# that exact example) -- SCALAR fields are unaffected, and an embedded
# apostrophe (`'IT''S HERE'`, HAL/S's own literal-escaping syntax for a
# literal `'` character) gets doubled only in the UNPAGED form.
run ./run_local_fixture.sh unpaged "$(printf 'THE ANSWER IS      7.5836206E+05\nIT'"'"'S HERE')"
run ./run_local_fixture.sh unpaged "$(printf '\x27THE ANSWER IS\x27      7.5836206E+05\n\x27IT\x27\x27S HERE\x27')" --unpaged 6
# WRITE of a raw BIT-typed expression (not first converted via a shaping
# function) previously misformatted as plain decimal INTEGER instead of
# USA003087 Appendix F's binary-digit-string format -- found while
# implementing --unpaged above (the fixture right above this one), user-
# confirmed and directed to fix per ["Programming in HAL/S"] p. 255 ("The
# value returned by the BIT function is always of the maximum legal
# length for bit strings" -- the closest available primary/secondary
# source statement for what width to use when no better one is known).
# B1 (a declared BIT(8)) formats at its real declared width (8, looked
# up from the symbol table -- same technique BCAT already established
# for this identical "no width in resolved_value_t" problem); the bare
# HEX'1234' literal has no declared width to look up, so falls back to
# 32 (the documented legal maximum, USA003090 Sec. 8.2 rule 6),
# confirming both the declared-width and fallback paths in one fixture.
# Also caught a second, separate bug along the way: symtab.c was
# silently discarding a BIT symbol's own declared per-element width
# whenever it was *also* ARRAY-shaped (the shape-resolution code treated
# "has an ARRAY shape" and "is BIT-typed" as mutually exclusive) --
# fixed there directly (the arrinit_types fixture elsewhere in this file
# independently exercises the ARRAY-of-BIT angle specifically -- its own
# expected value needed updating this session too, for the same reason).
run ./run_local_fixture.sh bit_write "$(printf '0000 1100\n0000 0000 0000 0000 0001 0010 0011 0100')"
run ./run_local_fixture.sh bit_write "$(printf '\x270000 1100\x27\n\x270000 0000 0000 0000 0001 0010 0011 0100\x27')" --unpaged 6
# --time-scale 1000000 keeps these WAIT-using fixtures' now-real-time-
# throttled runs fast (see interp_run()'s wall-clock pacing, state.h's
# scheduler comment) -- it's a pure sleep-duration divisor, so the tick
# arithmetic/expected output below is unaffected either way (verified by
# comparing against a --time-scale-free run of the same fixtures).
run ./run_local_fixture.sh canc "N=               0" --time-scale 1000000
run ./run_local_fixture.sh canc_control "N=               1" --time-scale 1000000
run ./run_local_fixture.sh sgnl "DONE"
run ./run_local_fixture.sh idef " 1.2000000E+01"
run ./run_local_fixture.sh tdcl " 6.0000000E+00"
run ./run_local_fixture.sh stos " 1.5000000000000000E+00"
run ./run_local_fixture.sh mtom "$(printf ' 1.0000000E+00\n 4.0000000E+00')"
run ./run_local_fixture.sh vtov "$(printf ' 5.0000000E+00\n 7.0000000E+00')"
run ./run_local_fixture.sh bcat "        165"
run ./run_local_fixture.sh eint " 2.5000000E+00"
run ./run_local_fixture.sh tsub "          0               9               0"
run ./run_local_fixture.sh tint "$(printf '          5\n 4.2999992E+00')"
# Structure "copiness" (`Q-STRUCTURE(n)`) INITIAL(): a coalesced TINT run
# can span *copies* of one terminal, not just several terminals of one
# copy -- disambiguated via the target's declared copy count
# (symtab.h's struct_copies, class-8/TINT.md). Un-subscripted Z.QI in
# WRITE enumerates every copy.
run ./run_local_fixture.sh structcopy_init "$(printf '          1               2               3')"
run ./run_raf_fixture.sh file 8 "$(printf '         42\n 3.5000000E+00\n         99')"

# SCHEDULE's delayed (AT/IN/ON) and cyclic (REPEAT EVERY/AFTER, WHILE/
# UNTIL) forms -- class-0/SCHD.md's confirmed tag bitmask. Expected
# values hand-derived from the scheduler's own rules (priority
# preemption + fixed-tick-per-instruction virtual clock), not just
# copied from a run -- see the commit message for the arithmetic. Every
# AT/IN/EVERY/AFTER/UNTIL-time/WAIT value is now real HAL/S seconds
# (HALMAT_TICKS_PER_SECOND-scaled, not a raw tick count -- see state.h's
# scheduler comment), but a uniform linear rescale of the time axis
# changes absolute tick magnitudes, not relative ordering, so every
# expected string below is unchanged; --time-scale 1000000 just keeps
# the now-real-time-throttled runs fast (verified: byte-identical
# output with and without --time-scale).
run ./run_local_fixture.sh sched_at "$(printf 'BEFORE SCHEDULE\nWORKER RUNNING\nAFTER SCHEDULE')" --time-scale 1000000
run ./run_local_fixture.sh sched_in "$(printf 'BEFORE SCHEDULE\nWORKER RUNNING\nAFTER SCHEDULE')" --time-scale 1000000
run ./run_local_fixture.sh sched_on "$(printf 'BEFORE SCHEDULE\nBEFORE SIGNAL\nWORKER RUNNING\nAFTER SIGNAL')"
run ./run_local_fixture.sh sched_every "N=               5" --time-scale 1000000
run ./run_local_fixture.sh sched_after "N=               4" --time-scale 1000000
run ./run_local_fixture.sh sched_while "N=               1" --time-scale 1000000
# User-reported sweep item: SCHEDULE's STOPPING-only form (WHILE/UNTIL
# with no REPEAT/TIMING at all, `<SCHEDULE CONTROL> ::= <STOPPING>`) --
# grammatically legal and HALSFC compiles it, but its runtime semantics
# are genuinely undocumented in the primary source (see class-0/SCHD.md's
# Unresolved Questions). Resolved as a documented no-op: SYNTHESI.xpl's
# own grammar action here is itself a bare no-op, and a non-repeating
# task's stop_kind is stored but never consulted (OP_CLOS only reads it
# when repeat_kind != NONE) -- so WORKER simply runs once (N=1) and
# terminates normally, regardless of EV1 never being signaled.
run ./run_local_fixture.sh sched_stopping_only "N=               1" --time-scale 1000000
# User-reported sweep item: a task rescheduling *itself* with `SCHEDULE
# <self> ON <event>;` (no REPEAT clause) previously failed loudly. Same
# "spelled imperatively instead of declaratively" equivalence already
# used for the AT/IN self-reschedule case (see sched-self-reschedule
# comment above): synthesizes SCHD_REPEAT_ON, an interpreter-internal
# rearm kind that waits on the event again via TASK_WAITING_ON, the same
# mechanism a brand-new ON-initiated task already uses. NEST reschedules
# itself ON EV1 (never reset -- deliberately, to prove the rearm actually
# re-fires) up to 3 times, then self-CANCELs.
run ./run_local_fixture.sh sched_self_on "COUNT=               3" --time-scale 1000000
run ./run_local_fixture.sh sched_every_wait "N=               5" --time-scale 1000000
# User-reported bug: a TASK rescheduling *itself* from inside its own
# body (`SCHEDULE NEST IN 1.0 PRIORITY(80);` executed by NEST, right
# before its own CLOSE) failed with "task already active" -- USA003087
# p. 160/13-2 defines "active" as "in the process queue", and a self-
# reschedule doesn't add a second queue entry, just changes the sole
# entry's own minor state (EXECUTING -> WAITING), the same "rearm in
# place" transition CLOS's existing REPEAT EVERY/AFTER handling already
# does for a declaratively cyclic task. Fixed by routing a detected
# self-SCHEDULE into that same rearm mechanism -- see class-0/SCHD.md's
# "Self-Rescheduling Tasks" section. NEST fires at t=0,1,2,3 (COUNT
# 1-4) before the primal's WAIT 3.5 completes and the whole program
# (and its still-waiting NEST, per Sec. 13.1's "all other processes are
# always dependent on the primal process for their existence") ends.
run ./run_local_fixture.sh nested_task_schedule "$(printf '          1\n          2\n          3\n          4')" --time-scale 1000000
# User-reported bug (a second, related report against the same underlying
# gap as sched_low's correction above): COUNTUP2 has *no* WAIT at all and
# reaches its own CLOSE immediately after the SCHEDULE statement, with
# NEXT scheduled DEPENDENT -- per USA003087 Sec. 13.3, the primal must
# wait for NEXT to terminate (its own CANCEL, once I>10) before the whole
# program actually ends, rather than halting immediately as yaHALMAT2
# previously did (which let NEXT run at most once). See class-0/SCHD.md's
# "Waiting For Dependents At CLOSE" section for the full account.
run ./run_local_fixture.sh countup2 "$(printf '          1\n          2\n          3\n          4\n          5\n          6\n          7\n          8\n          9\n         10')" --time-scale 1000000

# --pacing=signal smoke test: reuses sched_every (a fast, already-passing
# fixture) with a large --time-scale, same reasoning as the --time-scale
# usage above, to confirm interp_run_signal()'s tick-budget accounting
# and task interleaving produce byte-identical output to the default
# interp_run_burst() path -- this is what would catch a bug in the
# signal-mode budget/tick-consumption arithmetic itself, independent of
# real-time precision (see interp.c's interp_run_signal()).
run ./run_local_fixture.sh sched_every "N=               5" --time-scale 1000000 --pacing=signal

# Proves interp_run()'s wall-clock real-time pacing actually does
# something -- every sched_*/canc* fixture above passes a large
# --time-scale specifically to make its sleep negligible, so none of
# them alone would catch a regression that silently disabled throttling
# (finishing near-instantly) or hung/massively over-slept. This one runs
# at the default time_scale=1.0 (no --time-scale) and checks the actual
# wall-clock elapsed time against a generous tolerance band -- see
# run_realtime_fixture.sh. Run under both pacing implementations, for the
# same reason: neither is exempt from this regression class.
run ./run_realtime_fixture.sh realtime_wait "DONE" 0.2 burst
run ./run_realtime_fixture.sh realtime_wait "DONE" 0.2 signal

HAL_S_FC_PY="/home/rburkey/git/virtualagc/yaShuttle/ported/PASS1.PROCS/HAL_S_FC.py"
workdir=$(mktemp -d)
cp /mnt/STORAGE/home/rburkey/git/Halmat/data/test_simple_do.hal "$workdir/"
( cd "$workdir" && python3 "$HAL_S_FC_PY" "--hal=test_simple_do.hal" >/dev/null )
py_exp=$(./../yaHALMAT2 --py "$workdir/FILE1.bin")
rm -rf "$workdir"
run ./run_py_fixture.sh simple_do "$py_exp"

# User-reported (071-DARTBOARD_APPROXIMATION.hal's `X = RANDOM;` failing
# "BFNC: expected 1 operand (selector 42)"), broadened per direct request
# into a full sweep of every remaining unimplemented BFNC/LFNC selector
# rather than fixing them one bug report at a time -- [USA003087] Appendix
# B's complete built-in-function catalog cross-checked against class-0/
# BFNC.md's confirmed BI_NAME-position selector table. Implemented this
# batch: COSH/SINH/TANH/ARCCOS/ARCSIN/ARCCOSH/ARCSINH/ARCTANH/ARCTAN2
# (with every USA003090 Appendix C domain-error fixup that applies --
# errors 9/10/59/60/62 -- alongside the already-implemented group's
# errors 5-8/11-12/24/25/27/28), FLOOR/CEILING/TRUNCATE/SIGNUM/MIDVAL,
# DIV/MOD/REMAINDER (errors 16/19/33)/ODD/SHL/SHR/XOR, INDEX/LJUST/RJUST
# (error 18), TRANSPOSE/TRACE, RANDOM/RANDOMG (state.h's rng_state
# comment: a from-scratch deterministic Park-Miller generator, no
# primary-source algorithm mandated, same compromise as MINV/DET's
# Gaussian elimination), RUNTIME (the existing virtual-clock model), and
# ERRGRP/ERRNUM (new last_error_group/last_error_member state, updated at
# arithmetic_error_should_apply_fixup's single existing choke point).
# Deliberately NOT implemented, documented instead of guessed at:
# DATE/CLOCKTIME (no calendar/wall-clock model anywhere in this
# interpreter), NEXTIME (needs scheduler-internals introspection not
# undertaken this pass), and BFNC selectors 57-63 (BIT/SUBBIT/INTEGER/
# SCALAR/VECTOR/MATRIX/CHARACTER -- almost certainly back the explicit-
# conversion/shaping-function *syntax*, already confirmed elsewhere to
# compile to dedicated opcodes, not a raw BFNC call; no real compiled
# HALMAT hitting these selectors has been observed). A significant
# mid-batch correction: MAX(7)/MIN(8)/SUM(14)/PROD(20)/SIZE(23) were
# initially added to BFNC too, but empirical cross-checking (real
# 141-VSUM.hal hitting selector 23 unexpectedly, then two direct
# HALSFC compile+--disasm probes) found all five actually route through
# the *separate* LFNC ("L-FUNC") opcode instead -- already handling
# MAX/MIN before this session, now extended for SUM/PROD/SIZE too (same
# BI_NAME-position selector numbers, just a different dispatch opcode);
# the dead BFNC cases for these five were removed once this was
# confirmed, not left in as unreachable code.
run ./run_local_fixture.sh bfnc_hyperbolic "$(printf ' 1.5430803E+00\n 1.1752005E+00\n 7.6159412E-01\n 1.3169575E+00\n 1.4436350E+00\n 5.4930609E-01\n 0.0          ')"
run ./run_local_fixture.sh bfnc_invtrig "$(printf ' 1.0471973E+00\n 5.2359873E-01\n 0.0          \n 1.5707960E+00\n 3.1415920E+00\n-1.5707960E+00\n 7.8539813E-01\n 0.0          ')"
run ./run_local_fixture.sh bfnc_rounding "$(printf ' 2.0000000E+00\n 3.0000000E+00\n 2.0000000E+00\n 1.0000000E+00\n-3.0000000E+00\n-2.0000000E+00\n-2.0000000E+00\n-1.0000000E+00\n 5.0000000E+00')"
run ./run_local_fixture.sh bfnc_intops "$(printf '          3\n          2\n 2.0000000E+00\n 3.0000000E+00\n          1\n          0\n         48\n         16\n        188')"
run ./run_local_fixture.sh bfnc_char "$(printf '          6\n          0\nAB   \n   AB')"
run ./run_local_fixture.sh bfnc_matrix2 "$(printf ' 1.0000000E+00      4.0000000E+00\n 2.0000000E+00      5.0000000E+00\n 3.0000000E+00      6.0000000E+00\n 1.5000000E+01')"
run ./run_local_fixture.sh lfnc_array "$(printf ' 7.0000000E+00\n 1.0000000E+00\n 1.5000000E+01\n 8.4000000E+01\n          4')"
run ./run_local_fixture.sh random "$(printf ' 7.8263693E-06\n 1.3153774E-01\n-7.2352159E-01')"
run ./run_local_fixture.sh runtime "$(printf ' 1.8115941E-05\n 5.0000534E+00')"
run ./run_local_fixture.sh errgrp_errnum "$(printf '          0\n          0\n 2.0000000E+00\n          4\n          5')"
# Follow-up, direct user correction to this same batch: DATE/CLOCKTIME
# (BFNC selectors 18/54) were initially left unimplemented ("no calendar/
# wall-clock model... 'implementation-dependent format' gives no way to
# pick a reproducible value") -- the user clarified these mean real OS
# wall-clock time in the system's configured local timezone, not a
# fabrication this interpreter would need to invent. [USA00309] Sec. 8.2
# rule 17 turned out to pin DATE's exact format down precisely (YYDDD,
# confirmed against its own worked example, "February 1, 1978=78032");
# CLOCKTIME's unit isn't primary-source-specified beyond "double
# precision scalar"/"time of day" (Appendix B), so seconds-since-local-
# midnight was chosen as a documented judgment call, consistent with
# RUNTIME's own seconds convention. Implemented via plain standard-C
# time()/localtime() (portable across every platform this project
# targets with no #ifdef, unlike interp_run_signal()'s platform-split
# monotonic_seconds()). Also fixed a related bug noticed while touching
# this code: RUNTIME (already implemented) returned single precision
# despite rule 18 explicitly calling it "double precision scalar" too.
# Can't use a fixed expected string (the value is different every run) --
# uses a dedicated bounds-checking fixture runner instead,
# run_walltime_fixture.sh, computing the same values independently via
# `date` right around the yaHALMAT2 invocation, the same approach
# run_realtime_fixture.sh already uses for identically un-hardcodable
# real-world timing.
run ./run_walltime_fixture.sh date_clocktime

echo "============================"
if [ "$fail" -eq 0 ]; then
    echo "ALL TESTS PASSED"
else
    echo "SOME TESTS FAILED"
fi
exit $fail
