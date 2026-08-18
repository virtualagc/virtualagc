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
run ./run_local_fixture.sh sched_high "$(printf 'BEFORE SCHEDULE\nAFTER SCHEDULE\nWORKER RUNNING')"
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
# DISTANCE line's own expected value corrected 2026-07-29 (id 66, then
# again same day once id 69 landed): was 1.7023535811925805E+08, never
# actually verified against real gpc (this fixture's own point was the
# IASN/SASN precision-tagging fix above, predating TAN's own real port
# entirely -- whatever yaHALMAT2 happened to compute via the old libm
# tan() got locked in unchecked); briefly 1.7023535802332896E+08 once
# TAN itself was fixed (id 66) but before OP_SSDV's own DOUBLE-precision
# QDEDR fix (id 69) closed the remaining ~11th-significant-digit gap.
# Now bit-exact against real gpc end to end (TAN(ANGULAR_SHIFT) alone
# already independently confirmed bit-exact, 5.4630249015163663E-01
# both, isolated in a standalone probe; the division itself now uses
# the same QDEDR algorithm real hardware's own compiled `/` between two
# DOUBLEs does, not value.c's own genuinely-exact halmat_scalar_divide).
run ./run_local_fixture.sh scalar_double "$(printf ' 9.3000000000000007E+07\n 5.0000000000000000E-01\n 1.7023535809041477E+08')"
# This WRITE statement's 8 fields ('I1=',I1,'I2=',I2,'I3=',I3,'I4=',I4)
# total 91 columns -- past the 80-column line_length UNPAGED default, so
# under an UNPAGED device this wraps onto two lines. Channel 6 here is
# PAGED by default though (USA003090 Sec. 5.2), whose own default is 132
# columns (user-reported correction, 2026-07-25 session -- see state.h's
# line_length comment: LRECL 133 minus the automatically-generated ANSI/
# ASA carriage-control byte an FBA PAGED record implies, matching the IBM
# 1403 line printer's 132-column width), comfortably fitting all 91
# columns on one line -- no wrap. The reference yaHALMAT emulator (ground
# truth elsewhere in this file) also doesn't wrap, consistent with this.
# SCALAR->INTEGER rounding: round to nearest, but exact-.5 ties round
# TOWARD zero (truncate), not away from it -- value.c's halmat_scalar_
# to_integer comment. I2/I3 updated from 8/-8 to 7/-7 accordingly;
# confirmed against real gpc output for this exact probe plus a fuller
# 24-point sweep of the real ETOH.asm runtime-library conversion routine.
run ./run_local_fixture.sh stoi "$(printf 'I1=               7     I2=               7     I3=              -7     I4=              -7')"
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
#
# Expected output updated from SCALAR-style (" 1.0000000E+01 ...") to
# INTEGER-style ("10 ..."): cross-project-tracked as
# compool_array_integer_type, found via yaGPC2 dev and confirmed against
# real gpc. Turned out NOT to be COMPOOL-specific at all -- test_arrint_
# write.hal below reproduces the identical bug with a plain local ARRAY(n)
# INTEGER, no linking involved. Root cause: a whole ARRAY(n) INTEGER
# WRITE argument is wrapped in an ADLP per-element replay (like any
# other numeric/BIT/CHARACTER ARRAY), and resolve_operand's arrayed
# QUAL_SYT branch always returns RV_SCALAR for a numeric array element
# regardless of the array's own declared INTEGER/SCALAR type (elements[]
# is shared storage for both -- state.h's own comment). The WRITE-
# argument capture's tag1==6 "reclassify as INTEGER" check only looked
# at QUAL_LIT operands (bare literals), not QUAL_SYT array-element reads
# -- broadened in interp.c to cover both identically.
run ./run_link_fixture.sh "$(printf '         10              20              30')" link_pool_array link_prog_array
# Direct (non-COMPOOL) regression for the same root cause -- see the
# comment above.
run ./run_local_fixture.sh arrint_write "$(printf '         10              20              30')"
# ext_squroo's SQRT(3) row was updated from 1.7320499E+00 to the
# authentic RUNASM/SQRT.asm result 1.7320509E+00 -- independently
# confirmed against yaGPC2's own real execution of this exact fixture
# (task 100/id 51's own verification, hal_transcendental.c's
# hal_sqrt_single). The old value was simply imprecise, not a match to
# any real emulator's own output.
run ./run_ext_func_fixture.sh "$(printf '          1      1.0000000E+00      1.0000000E+00\n          2      4.0000000E+00      1.4142132E+00\n          3      9.0000000E+00      1.7320509E+00')" ext_mytable ext_square ext_squroo
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

# DB id 38 (yahalmat2_rtrn_inline_extern_matrix_vector_return): the
# "MATRIX/VECTOR half... still blocked" gap the comment right above
# describes is now implemented, for both remaining OP_RTRN forms.
# Cross-unit (EXTERNAL FUNCTION) case: VECFUNC (a separate unit,
# --parms=TEMPLATE) returns a whole VECTOR; interp_copy_external_call_
# result()'s own is_container deep-copy branch already existed and was
# ready for this (added alongside the CHARACTER fix above) but nothing
# on the OP_RTRN external-call path ever set is_container until now.
# Confirmed against real gpc via a manual multi-object HALSFC+lnk101
# link+run (compileLinkRun only supports single-file programs).
run ./run_ext_func_fixture.sh " 4.0000000E+00      5.0000000E+00      6.0000000E+00" ext_vecprog ext_vecfunc

# Inline-FUNCTION (class-0/IDEF.md) case: `RESULT = FUNCTION VECTOR;
# DECLARE V VECTOR INITIAL(1,2,3); RETURN V; CLOSE; ;` -- same
# ret_whole_syt/ret_whole_vac/ret_whole_xpt detection reused directly in
# OP_RTRN's inline-FUNCTION branch, routing through resolve_container()/
# store_container_result() into the IDEF's own VAC slot instead of
# store_resolved_to_vac() (which has no container case). Confirmed
# against real gpc via compileLinkRun.
run ./run_local_fixture.sh inline_vector_return "$(printf ' 1.0000000E+00      2.0000000E+00      3.0000000E+00')"

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
run ./run_link_container_fixture.sh --tmpl 150000 "$(printf '          1      1.0000000E+00      1.0000000E+00\n          2      4.0000000E+00      1.4142132E+00\n          3      9.0000000E+00      1.7320509E+00')" ext_mytable ext_square ext_squroo
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
# I3's expected value updated from -13 to 243: BNOT (NOT B1, B1 declared
# BIT(8)) must mask its complement to the operand's own declared width,
# not complement the full 32-bit pattern -- confirmed against real gpc
# output (`XHI R7,255` in the generated assembly, an 8-bit-masked XOR,
# not a full-word complement). interp.c's OP_BNOT case fixed accordingly.
run ./run_local_fixture.sh bit "I1=               8     I2=              14     I3=             243"
run ./run_local_fixture.sh scalar_exp "$(printf ' 8.0000000E+00\n 8.0000000E+00\n 2.5000000E-01\n 1.4142132E+00')"
run ./run_local_fixture.sh matrix_sub "$(printf ' 5.0000000E+00\n 3.0000000E+00\n 4.0000000E+00')"
# User-reported (107-EXAMPLE_3.hal): `DECLARE ARRAY(3,3), M1...;`, a
# genuinely 2-dimensional ARRAY (not MATRIX), subscripted throughout as
# `M1(ROW,COL)` and `M1$(ROW,*)`. `WRITE(6) M1$(ROW,*);` failed loudly
# ("DSUB: asterisk subscript with 2 indices not yet implemented"), but
# ensure_container() had a deeper, silent bug too: it only ever read
# array_dims[0] for any ARRAY shape, discarding a second dimension
# entirely and leaving rows/cols at 0 -- so the *plain* 2-index case
# (`M1(ROW,COL) = ...;`, used throughout the matrix-multiply loop) was
# ALSO silently using a generic placeholder-stride offset formula
# instead of real row-major addressing, corrupting every element write
# with no error at all. Fixed by giving a confirmed 2-dimensional ARRAY
# the same rows/cols treatment MATRIX already gets, letting DSUB's
# existing MATRIX-shaped logic (index/asterisk-partition/at-partition)
# handle it for free. Output is the verified-correct 3x3 matrix product
# of M2={1..9} and M3={11..19}.
run ./run_local_fixture.sh array2d "$(printf ' 9.0000000E+01      9.6000000E+01      1.0200000E+02\n 2.1600000E+02      2.3100000E+02      2.4600000E+02\n 3.4200000E+02      3.6600000E+02      3.9000000E+02')"
# User-reported (107-EXAMPLE_4.hal): `DECLARE A ARRAY(5) SCALAR DOUBLE
# INITIAL(1,2,3,4,5);`, rotated left by one via `TEMP=A(1); A(T)=A(T+1)
# for T=1..4; A(5)=TEMP;`. WRITE(6) A printed the first 4 elements in
# SINGLE-precision format and only the 5th (the one that happened to
# pass through the already-precision-normalized plain SCALAR DOUBLE
# `TEMP`) in DOUBLE format. Root cause: write_container_element() (the
# one shared choke point every numeric ARRAY/VECTOR/MATRIX element
# write funnels through -- INITIAL() population via STRI/SINT, DSUB
# element-to-element copies, and ordinary subscripted assignment alike)
# never normalized to the container's own declared SINGLE/DOUBLE
# precision the way the equivalent plain-SCALAR-destination path
# already did -- so every element wrote through single-precision except
# ones that happened to already carry DOUBLE from elsewhere. Fixed by
# giving write_container_element() the same symtab-driven
# scale_precision() normalization OP_IASN/OP_SASN's own dest_sym check
# already uses for a plain destination.
run ./run_local_fixture.sh array_double "$(printf ' 2.0000000000000000E+00      3.0000000000000000E+00      4.0000000000000000E+00      5.0000000000000000E+00\n 1.0000000000000000E+00')" --line-length 132
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
# Second line updated from "12" to "00001100": BTOC (simple-form
# CHARACTER(<bit-expression>), no @DEC/@OCT/@HEX qualifier) must map each
# bit to a literal '0'/'1' character, one character per declared bit
# (USA003087 Sec. 21.4), not format the raw pattern as a decimal number
# -- interp.c's OP_BTOC case fixed accordingly (problems-yaHALMAT2.md
# item 5), confirmed against real gpc output. CTOB (BIT(<character-
# expression>), the inverse conversion `B3 = BIT(C1);` a few lines later
# in this same test) fixed to match -- its own final INTEGER(B3)=12
# output is unchanged, confirming the round-trip still works correctly
# through the corrected string representation.
run ./run_local_fixture.sh bit_conv "$(printf ' 1.2000000E+01\n00001100\nBEQU-TRUE\n         12')"
# First line updated from 43690 to -21846: `INTEGER(B1)` (B1 declared
# BIT(16), exactly filling a single-precision INTEGER's own halfword
# storage) must be truncated/reinterpreted as a signed 16-bit value when
# printed, not left as this emulator's wider int32_t -- interp.c's
# WRITE-argument capture now does this by default (a plain, non-DOUBLE
# INTEGER symbol), matching real gpc output exactly.
run ./run_local_fixture.sh init8 "$(printf '     -21846\n 9.0000000E+00\n 9.0000000E+00\n 4.0000000E+00')"
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
# IA's expected output updated from SCALAR-style to INTEGER-style
# ("10 20"): another instance of the same ARRAY(n) INTEGER whole-WRITE
# bug fixed above (compool_array_integer_type) -- confirmed against real
# gpc.
run ./run_local_fixture.sh sshp_ishp "$(printf ' 1.5000000E+00      2.5000000E+00\n         10              20')"
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
# ABVAL's own expected value corrected 2026-07-29 (id 67,
# yagpc2-yahalmat2-issues.db): was 3.6055508E+00, never actually
# verified against real gpc -- ABVAL used a plain libm sqrt() shortcut
# instead of the authentic hal_sqrt_single RTL port, which happened to
# be off by 1 ULP here too (same root cause as id 67's own main repro).
# Confirmed 3.6055517E+00 bit-exact against a fresh real-gpc run.
run ./run_local_fixture.sh vec_atpartition "$(printf ' 1.0000000E+00      2.0000000E+00\n 3.6055517E+00')"
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
# M2**(-1)'s own expected value was updated from -1.9999990E+00/
# 9.9999994E-01/1.5000000E+00/-4.9999994E-01 (the old native-double-
# based matrix_invert's own less-authentic result) to an exact
# -2.0000000E+00/1.0000000E+00/1.5000000E+00/-5.0000000E-01, the
# authentic RUNASM/MM14SN.asm result -- independently confirmed
# bit-for-bit against yaGPC2's own real execution of this exact fixture
# (task 100/id 51's own verification, hal_matrix.c).
run ./run_local_fixture.sh errfix_matrix "$(printf -- ' 1.0000000E+00      0.0          \n 0.0                1.0000000E+00\n 0.0                0.0                0.0          \n 7.0000000E+00      1.0000000E+01\n 1.5000000E+01      2.2000000E+01\n 1.0000000E+00      0.0          \n 0.0                1.0000000E+00\n-2.0000000E+00      1.0000000E+00\n 1.5000000E+00     -5.0000000E-01\n 1.0000000E+00      0.0          \n 0.0                1.0000000E+00\n 1.0000000E+00      2.0000000E+00\n 3.0000000E+00      4.0000000E+00')"
# Task #106/id 51: authentic AP-101S RUNASM/MM14S3.asm (via MM12S3.asm's
# own Sarrus-rule determinant) N==3 single-precision MATRIX**(-1) port
# (hal_matrix.c). Uses DECLARE...INITIAL(...) rather than a runtime
# MATRIX(...) assignment deliberately -- a real trace showed the latter
# leaves genuine, non-zero leftover state in F1/F3/F5/F7 as a side
# effect of the compiler's own literal-constructor register cycling,
# the same class of "mainline compiled code touches the odd companion
# registers" gap already documented for MMWSNP/assignment-copy
# (interp.c's own store_container_result comment) and equally out of
# scope here -- see hal_matrix.h's own header comment. INITIAL(...) has
# no runtime register traffic at all, so this fixture's own entering
# fpu state genuinely matches yaHALMAT2's own (zero, at program start),
# and the result is independently confirmed bit-for-bit against
# yaGPC2's own real execution.
run ./run_local_fixture.sh mm14s3 "$(printf -- '-2.0000000E+00      1.3333330E+00     -3.3333331E-01\n 3.0000000E+00     -3.6666660E+00      1.6666660E+00\n-1.0000000E+00      2.0000000E+00     -1.0000000E+00')"
# Task #107/id 51: authentic AP-101S RUNASM/MM14DN.asm (N=2 closed
# form + general Gauss-Jordan) and RUNASM/MM14D3.asm (N==3, via
# MM12D3.asm's own genuine extended-precision Sarrus-rule determinant)
# DOUBLE-precision MATRIX**(-1) ports (hal_matrix.c). Same
# DECLARE...INITIAL(...) rationale as mm14s3 above. Also locks in a
# real bug fix: QDEDR's own internal DER/DE steps were initially
# modeled as reading full extended-precision (msw+lsw) operands (which
# happened to give the right answer whenever the divisor's own lsw was
# 0, as in every N=2/N=3 case here and in this fixture's own N=4 K=0-2
# pivots) -- but a real trace of this exact N=4 case's own K=3 pivot
# (5/3, genuinely nonzero lsw) proved DER/DE narrow BOTH operands to
# msw-only, not just the output; the M(3,3)=6.0000000089404137E-01
# element below only became bit-exact after that fix (previously
# 6.0000000089406802E-01, wrong from the 11th significant digit
# onward). Independently confirmed bit-for-bit against yaGPC2's own
# real execution (N=2, N=3, and N=4).
run ./run_local_fixture.sh mm14dn "$(printf -- '-2.0000000000000000E+00      1.0000000000000000E+00\n 1.5000000000000000E+00     -5.0000000000000000E-01\n-2.0000000009313226E+00      1.3333333339542150E+00     -3.3333333348855376E-01\n 3.0000000013969839E+00     -3.6666666683740914E+00      1.6666666674427688E+00\n-1.0000000004656613E+00      2.0000000009313226E+00     -1.0000000004656613E+00\n 5.7142857142856940E-01      0.0                         0.0                        -1.4285714284051210E-01\n 0.0                         4.0000000024835147E-01     -2.0000000043461719E-01      0.0                   \n 0.0                        -2.0000000043461719E-01      6.0000000089404137E-01      0.0                   \n-1.4285714284051210E-01      0.0                         0.0                         2.8571428568102419E-01')"

# id 53/72 (yagpc2-yahalmat2-issues.db, datatypes_repeated_singular_
# inverse_unstable_result / yahalmat2_matrix_leak_model_should_match_
# corrected_rtl): three back-to-back INVERSE(A4A) calls on the same
# exactly-singular 4x4 matrix used to give three DIFFERENT results
# (near-identity, wild ~1E12 garbage, near-identity) because the
# general-N reduction loop's own AEDR read genuinely-leaked companion
# registers (F3/F5) that unrelated prior floating-point call history
# could corrupt -- confirmed a real RTL bug (RUNASM/MM14SN.asm), fixed
# on the real RTL side (yaGPC2 commit 8439ae054, an &ASM101S-gated
# SER F3,F3/SER F5,F5 pair) and here in hal_matrix.c (both companions
# now modeled as freshly zeroed at every use, matching the corrected
# RTL). All three calls now consistently give the standard singularity
# fixup (identity matrix), matching yaGPC2 exactly.
run ./run_local_fixture.sh repeated_singular_inverse "$(printf ' 1.0000000E+00      0.0                0.0                0.0          \n 0.0                1.0000000E+00      0.0                0.0          \n 0.0                0.0                1.0000000E+00      0.0          \n 0.0                0.0                0.0                1.0000000E+00\n 1.0000000E+00      0.0                0.0                0.0          \n 0.0                1.0000000E+00      0.0                0.0          \n 0.0                0.0                1.0000000E+00      0.0          \n 0.0                0.0                0.0                1.0000000E+00\n 1.0000000E+00      0.0                0.0                0.0          \n 0.0                1.0000000E+00      0.0                0.0          \n 0.0                0.0                1.0000000E+00      0.0          \n 0.0                0.0                0.0                1.0000000E+00')"

# id 76 (yagpc2-yahalmat2-issues.db, mm12sn_determinant_algorithm_
# fidelity_gap): DET() on a single-precision N>=4 matrix used a generic
# double-precision Gaussian-elimination fallback, giving small residuals
# that didn't match real hardware's own RUNASM/MM12SN.asm (a distinct,
# genuinely single-precision-throughout complete-pivoting algorithm --
# confirmed via direct reading to have NO register-pair-leak bug, unlike
# the MM14SN/VX6S3/VV6S3 family fixed just above). Ported bit-exactly as
# hal_matrix_determinant_single, dispatched for n>=4 single-precision
# matrices only (n==2/n==3 and DOUBLE precision stay on the generic
# path -- real hardware routes those to MM12SN's own closed form/the
# separate MM12S3.asm instead, neither touched by this fix). The
# residuals below (-3.4799951E+02 vs the mathematically exact -348.0,
# -2.3999977E+02 vs -240.0) are real, expected single-precision
# roundoff -- confirmed bit-exact against a direct yaGPC2 run, which
# shows the identical residuals.
run ./run_local_fixture.sh mm12sn_determinant "$(printf -- '-3.4799951E+02      4x4 determinant should be -348.0.\n-2.3999977E+02      5x5 determinant should be -240.0.')"

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
# id 61 (yagpc2-yahalmat2-issues.db): the second `A = INVERSE(SNG);` call
# below is made WITH the `GO TO SKIPPED` handler already registered, so
# this fixture's own expected output used to lock in a GOTO dispatch
# that skipped 'SHOULD NOT PRINT' entirely -- but real hardware's SEND
# ERROR SVC handler never dispatches to a user handler at the OS/SVC
# level for group-4:27 (INVERSE-of-a-singular-matrix) specifically,
# confirmed via a real gpc run of this exact fixture (compileLinkRun):
# 'SHOULD NOT PRINT' genuinely prints there, per id 46's own finding
# that this error's compiled call site (unlike SQRT/UNIT/MDIV/ZEROPOW,
# see eron_goto_appc below) has no compiler-generated re-check to branch
# on. Fixed via a `member != HAL_S_ERROR_INVERSE_SINGULAR` bypass in
# arithmetic_error_should_apply_fixup()'s GOTO-redirect branch (interp.c).
# The matrix VALUES real hardware prints there (huge register-garbage
# numbers, not identity) are the separately-documented, non-reproducible
# id-53 MM14SN register-garbage class -- out of scope here; this fixture
# only exercises yaHALMAT2's own consistent (identity-fallback) value,
# not a bit-for-bit match against that specific real-hardware garbage.
run ./run_local_fixture.sh eron_goto "$(printf -- 'BEFORE TRAP\n 1.0000000E+00      0.0          \n 0.0                1.0000000E+00\nAFTER ON ERROR\nSHOULD NOT PRINT\n 1.0000000E+00      0.0          \n 0.0                1.0000000E+00\nAFTER SKIPPED LABEL\nAFTER RESTORE\n 1.0000000E+00      0.0          \n 0.0                1.0000000E+00')"
# Per direct instruction, every App. C fixup site implemented this
# session now consults the ON ERROR table (not just INVERSE's error 27,
# the one a bug report happened to exercise) -- spot-checks a GOTO
# handler firing at four of them across three different opcode families
# (BFNC's shared arithmetic case for SQRT/error 5, BFNC's UNIT/error 28,
# the combined MSPR/MSDV/VSPR/VSDV case/error 25, and SPEX/error 4), plus
# confirming SYSTEM correctly restores the ordinary fixup afterward.
run ./run_local_fixture.sh eron_goto_appc "$(printf -- 'AFTER SQRT TRAP\nAFTER UNIT TRAP\nAFTER MDIV TRAP\nAFTER ZEROPOW TRAP\nRESTORED SQRT      2.0000000E+00')"
# SEND ERROR (ERSE, class-0/ERSE.md), USA003087 Sec. 25.3 -- previously a
# complete no-op ("which opcode this compiles to remains genuinely
# unresolved," per an earlier session's comment; disproven by compiling
# this exact test through the real toolchain). ERSE now dispatches
# through the same find_error_handler table ON ERROR/ERON already uses
# (cross-project-tracked as yahalmat2_send_error_no_dispatch). NOT
# verified against real gpc -- gpc's own SEND ERROR looked like an
# unimplemented stub in direct probing (always prints a raw message and
# falls through to the next statement regardless of which handler is
# registered); implemented per the language spec and yaGPC2's
# independent (dispatching) behavior instead, per direct guidance.
run ./run_local_fixture.sh send_error "$(printf ' 1.0000000E+01      1.1000000E+01      1.2000000E+01              13              14              15')"
# Same table, the plain-SCALAR-argument errors: 5 (SQRT<0 -> sqrt(|x|)),
# 7 (LOG<=0 -> 0: -max value, else LOG(|x|) via the real authentic
# RUNASM/LOG.asm port -- hal_transcendental.c, task 100/id 51), 6
# (EXP>174.673 -> max value), 24 (negative-base exponentiation -> |A|**B,
# via SEXP), and 4 (0**B, B<=0 -> 0, across SEXP/SPEX/SIEX's three
# different HALMAT opcodes for "non-literal", "literal>=0", and
# "literal any-sign" exponents respectively). LOG(|-5.0|)'s own expected
# value was updated from 1.6094370E+00 (the old libm-based
# implementation's own less-authentic result) to 1.6094379E+00, the
# authentic RUNASM/LOG.asm result -- independently confirmed bit-for-bit
# against yaGPC2's own real execution (task 100/id 51's own verification).
run ./run_local_fixture.sh errfix_scalar "$(printf -- ' 2.0000000E+00\n-7.2370051E+75\n 1.6094379E+00\n 7.2370051E+75\n 1.9999990E+00\n 0.0          \n 0.0          \n 0.0          ')"
# Errors 11 (TAN |arg| too large -> 1), 8 (SIN/COS |arg| too large ->
# sqrt(2)/2), and 15 (SCALAR too large for INTEGER conversion -> the
# maximum representable value, 32767/-32767 -- see value.c's
# halmat_scalar_to_integer).
#
# Last line's history: this session went 2147483647 -> -1 -> 32767.
# 2147483647 was this emulator's own INT32_MAX, an internally-consistent
# but unverified choice (no SINGLE/DOUBLE INTEGER precision modeled). -1
# came from a first attempt at matching real gpc directly, which for this
# exact probe (IRESULT = INTEGER(HUGESCALAR), HUGESCALAR = 50000000000.0)
# gives IRESULT=3 with no error-15 SEND ERROR message at all -- looking
# like the documented fixup doesn't apply. That conclusion was wrong:
# `CVFX` genuinely raises a CPU-level "convert overflow" interrupt
# (confirmed against the actual Shuttle flight-software OS source,
# workspace/PFS/OI340600/SSSRC/FPMSDERR.asm's FPMCVFX handler, direct
# guidance) which patches in 32767 (positive) or -32767 (X'8001', not the
# manual's -32768) before resuming -- entirely invisible in ETOH.asm's
# own straight-line code, which never branches on it itself. real gpc's
# own emulation of this specific interrupt turned out to be unreliable
# (order/state-dependent in further probing -- the identical value
# clamps correctly embedded as the 3rd-6th conversion in a longer test
# program, but returns 0 in an otherwise-identical isolated program, and
# large-enough magnitudes return -32768 regardless of sign later in a
# sequence) -- not a trustworthy ground truth for this one corner case
# the way it has been for everything else. Per direct guidance, this
# clamps to the interrupt handler's own real values instead.
run ./run_local_fixture.sh errfix_trig "$(printf ' 1.0000000E+00\n 7.0710677E-01\n 7.0710677E-01\n      32767')"
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
# First line updated from 61680 to -3856: `SUBBIT(I1) = BIN'...';` stores
# the raw bit pattern (0xF0F0) directly into I1's storage; since I1 is a
# plain (single-precision, 16-bit) INTEGER, printing it must reinterpret
# those bits as signed -- interp.c's WRITE-argument capture now does this
# by default, matching real gpc output exactly.
run ./run_local_fixture.sh subbit_assign "$(printf '      -3856\n1010 1010 1010 1010')"
run ./run_local_fixture.sh name "$(printf 'NEQU-TRUE\nNNEQ-TRUE')"
run ./run_local_fixture.sh cfor "LASTI=               5"
# User-reported (113-EXAMPLE_7.hal): a range-form `DO FOR J = I+1 TO 4;`
# with I=4 (start=5, already past end=4) still ran its body once, with
# J=5 -- corrupting an unrelated array element (MISMATCH$(1,1)) via a
# wrapped out-of-bounds DSUB offset. OP_DFOR's own comment claimed "the
# range form always runs its first in-range cycle without a pre-test",
# but a real `HALSFC --parms=LSTALL` trace shows DFOR's initial branch
# actually lands on EFOR's own store+compare code (skipping only the
# increment, not the bounds check) -- confirmed independently via
# compileLinkRun giving the correct zero-iteration result. Fixed by
# giving DFOR the same in-range check EFOR already does each cycle,
# applied once up front (new dfor_efor_pos[] reverse mapping so DFOR can
# find its own matching EFOR's exit target).
run ./run_local_fixture.sh dfor_zero "$(printf '          0\n          1')"
# Same file, a second bug found while fixing the first: WRITE(6)
# MISMATCH$(I,*); (MISMATCH a confirmed-2D `ARRAY(4,4) INTEGER`) printed
# every element in SCALAR format instead of INTEGER. Root cause: the
# whole-container WRITE path's own container_is_integer flag was only
# ever set for a plain whole-SYT reference, never a VAC-carried DSUB
# row-select result -- and separately, resolve_operand()'s per-element
# read from such a container (used once this WRITE argument gets
# expanded into its own ADLP/DLPE replay) had no INTEGER awareness at
# all, always producing RV_SCALAR. Fixed both: the first by dropping the
# whole-SYT restriction (DSUB's own TAG1=6 already marks an INTEGER
# result either way), the second with a new container_is_integer flag on
# the VAC slot itself, set from DSUB's own operator-word TAG and
# consulted by resolve_operand. Fixture reuses 113-EXAMPLE_7.hal's own
# ATTITUDE-comparison logic (needs --line-length 132 like the original).
run ./run_local_fixture.sh mismatch_array "$(printf '          0               1               0               1\n          1               0               1               0\n          0               1               0               1\n          1               0               1               0')" --line-length 132
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
# Own expected value corrected 2026-07-29 (id 65, yagpc2-yahalmat2-
# issues.db): the fixture's own `WRITE(6) '', M$(I,*);` leads with an
# empty CHARACTER literal, which used to reserve a 6-blank inter-field
# separator gap before the matrix row (dm_emit_field's own prior
# unconditional separator, id 65's actual root cause) -- was locked in
# as "expected" from that stale behavior, never verified against real
# hardware. Confirmed via yaGPC2 directly that a leading empty literal
# contributes nothing to the output stream, same as an empty CHARACTER
# variable's own runtime-empty content (id 65's own original repro) --
# real hardware doesn't distinguish the two. Now matches yaGPC2 exactly
# (1 leading space, ordinary field spacing, not 6).
run ./run_local_fixture.sh proc_matrix_arg "$(printf ' 1.0000000E+00      0.0                0.0                0.0                0.0          \n 0.0                1.0000000E+00      0.0                0.0                0.0          \n 0.0                0.0                1.0000000E+00      0.0                0.0          \n 0.0                0.0                0.0                1.0000000E+00      0.0          \n 0.0                0.0                0.0                0.0                1.0000000E+00')" --line-length 200
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
# Own expected value corrected 2026-07-29 (id 65) -- same stale-
# leading-empty-literal-separator issue as proc_matrix_arg above (this
# fixture reuses the same test_proc_matrix_arg.hal source), same fix.
run ./run_local_fixture.sh nest_call "$(printf ' 1.0000000E+00      0.0                0.0                0.0                0.0          \n 0.0                1.0000000E+00      0.0                0.0                0.0          \n 0.0                0.0                1.0000000E+00      0.0                0.0          \n 0.0                0.0                0.0                1.0000000E+00      0.0          \n 0.0                0.0                0.0                0.0                1.0000000E+00')" --line-length 200
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
# WRITE data-field line wrapping (default wrap point -- see state.h's
# line_length comment for the PAGED(132)/UNPAGED(80) per-device default
# derivation): an 8-element VECTOR's fields total 8*19-5=147 columns
# (14-col SCALAR field + 5-blank separator each, no leading separator on
# the first) -- wraps after 7 elements at channel 6's PAGED-by-default
# 132-column default, after 2 at an explicit --line-length 40.
run ./run_local_fixture.sh write_wrap "$(printf ' 1.0000000E+00      2.0000000E+00      3.0000000E+00      4.0000000E+00      5.0000000E+00      6.0000000E+00      7.0000000E+00\n 8.0000000E+00')"
run ./run_local_fixture.sh write_wrap "$(printf ' 1.0000000E+00      2.0000000E+00\n 3.0000000E+00      4.0000000E+00\n 5.0000000E+00      6.0000000E+00\n 7.0000000E+00      8.0000000E+00')" --line-length 40
# User-reported (this same session, following the MATRIX-alignment
# question above): --line-length 240 vs 300 looked identical, which led
# to finding this real bug once the actual cause (134-DOTS.hal's MATRIX
# row-boundary behavior) turned out to be a red herring -- confirmed via
# USA003090 Sec. 6.1.4 that a PAGED file (channel 6's own default,
# Sec. 5.2) defaults to RECFM=FBA, LRECL 133, but the trailing "A" means
# an ANSI/ASA carriage-control byte is automatically generated as byte 1
# of every record -- so only 132 of those 133 bytes are printable (also
# the IBM 1403 line printer's own documented width, corroborating
# independently). This project's own line_length default had been left
# at a flat 80 for both PAGED and UNPAGED devices (state.h's line_length
# comment, previously flagged but not fixed pending this decision).
# Fixed by picking 132/80 per-device (flush_write, interp.c) instead of
# one flat global default; --line-length still overrides either. This
# same VECTOR(8) fixture (8*19-5=147 columns) demonstrates both defaults
# side by side: wraps after 7 elements PAGED (above), after 4 UNPAGED.
run ./run_local_fixture.sh write_wrap "$(printf ' 1.0000000E+00      2.0000000E+00      3.0000000E+00      4.0000000E+00\n 5.0000000E+00      6.0000000E+00      7.0000000E+00      8.0000000E+00')" --unpaged 6
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
# `WRITE(6) HEX'1234';`'s own field width needed updating again this
# session: a bare HEX/OCT/BIN literal's real declared width is BIT(n),
# n = digit count * bits-per-digit (4 hex digits = BIT(16) here), not this
# project's usual "unknown declared width" 32-bit fallback -- confirmed
# against real compiled PASS2 output (`HALSFC --parms=LSTALL`, litfile.h's
# bit_width comment): the literal table's own page-3 cell stores this
# width directly (PASS1's own "LOC n BIT <value> (<width>)" report agrees),
# and generated code loads it into R6 (`LHI R6,20`/`LFXI R6,7` for this
# session's own HEX'00123'/BIN'0101010' probes) immediately before the
# WRITE call -- literal.c now reads that cell instead of discarding it.
run ./run_local_fixture.sh bit_write "$(printf '0000 1100\n0001 0010 0011 0100')"
run ./run_local_fixture.sh bit_write "$(printf '\x270000 1100\x27\n\x270001 0010 0011 0100\x27')" --unpaged 6
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
run ./run_local_fixture.sh sched_on "$(printf 'BEFORE SCHEDULE\nBEFORE SIGNAL\nAFTER SIGNAL')"
# sched_every (EVERY 1000 UNTIL 3500) is N=4, not 5: its UNTIL falls in a true
# intercycle gap ([3000,4000]), so per USA003087 Sec. 23.5 cancellation happens
# immediately at t=3500 and the 4000-start cycle never runs -- corrected from an
# earlier at-cycle-end-only check that ran that extra cycle. sched_after
# (AFTER 1000 UNTIL 4200, worker WAITs 300/cycle) stays N=4: there its UNTIL
# coincides with a cycle's own completion, so the at-cycle-end termination
# governs and no between-cycles cancel applies (cancellation never fires mid-
# cycle, Sec. 23.6). See sched_every_wait (same EVERY case, worker WAITs).
run ./run_local_fixture.sh sched_every "N=               4" --time-scale 1000000
run ./run_local_fixture.sh sched_after "N=               4" --time-scale 1000000
# REPEAT WHILE <event>: EV1 is FALSE at the (immediate) initiation, so per
# USA003087 Sec. 24.5 rule 5 the process "is merely removed again from the
# process queue ... without ever executing" -- N=0, not 1. (Corrected from an
# earlier check that only evaluated WHILE at each cycle's CLOSE, so it ran one
# cycle first. UNTIL <event> keeps its guaranteed >=1 cycle -- see
# sched_until_compound.)
run ./run_local_fixture.sh sched_while "N=               0" --time-scale 1000000
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
run ./run_local_fixture.sh sched_every_wait "N=               4" --time-scale 1000000
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
# CANCEL (class-0/CANC.md, USA003087 Sec. 23.6) -- graceful cancellation,
# the key distinction from TERMINATE. cancel_dormant: a not-yet-initiated
# cyclic task CANCELed before it runs is removed, never executes (non-
# preemptive scheduling means it doesn't sneak a run in before the CANCEL).
# self_cancel: a bare `CANCEL;` runs the *rest of the current cycle* (the
# WRITE after it prints) and only suppresses the next re-arm -- unlike
# TERMINATE, which would abort the cycle. cancel_named_list: the multi-name
# `CANCEL A, B;` list form removes both dormant tasks. Cross-checked against
# yaGPC2's traced real HAL/S-FC (SVC #4 self / #5 named).
run ./run_local_fixture.sh cancel_dormant "$(printf 'BEFORE\nDONE')" --time-scale 1000000
run ./run_local_fixture.sh self_cancel "$(printf 'BEFORE\nIN A\nAFTER CANCEL\nDONE')" --time-scale 1000000
run ./run_local_fixture.sh cancel_named_list "$(printf 'BEFORE\nDONE')" --time-scale 1000000
# EXCLUSIVE procedures (class-0 flag 0x00080000, USA003087 Sec. 27.2): the
# RTE serializes access -- only one process inside the block at a time. A
# contending caller is blocked at the CALL's XXST, before any call/I-O state
# is pushed, so the shared interpreter call stack only ever holds the one
# process actually inside (a plain non-EXCLUSIVE proc used concurrently is an
# invalid category-1 program per Sec. 27.1 and isn't guarded). serialized: a
# DEPENDENT contender is blocked, then granted the proc after the holder
# releases -- both ENTER/LEAVE pairs non-overlapping, both CALLs return
# correctly (a barge-in would corrupt the shared stack). cutoff: a non-
# DEPENDENT contender is blocked and then cut off at the primal's halt
# (Sec. 13.1), so the proc body runs exactly once. Cross-checked against
# yaGPC2's traced real HAL/S-FC (SVC #15/17 reserve/release before the body).
run ./run_local_fixture.sh exclusive_serialized "$(printf 'BEFORE\nENTER P\nB TRY P\nLEAVE P\nPRIMAL DONE\nENTER P\nLEAVE P\nB GOT P')" --time-scale 1000000
run ./run_local_fixture.sh exclusive_cutoff "$(printf 'BEFORE\nIN P\nB CALLS\nOUT P\nDONE')" --time-scale 1000000
# DATE()/CLOCKTIME() (USA00309 Sec. 8.2 rules 17/18): mission clock anchored
# at program start and advanced by *virtual* time (same base as RUNTIME), not
# re-read from the real host clock per call. --start-time pins the anchor for a
# reproducible run. DATE=YYDDD (INTEGER DOUBLE), CLOCKTIME=seconds since local
# midnight; here 1978-02-01 00:00:00 -> DATE 78032, CLOCKTIME 0 then 3600 after
# WAIT 3600. Convention shared with yaGPC2 (start anchor + virtual progression
# + override) so the two emulators don't diverge.
run ./run_local_fixture.sh datetime "$(printf '      78032\n 0.0          \n 3.6000000E+03')" --start-time "1978-02-01 00:00:00" --time-scale 1000000
# REPEAT AFTER ... UNTIL time, between-cycles cancellation (USA003087 Sec. 23.5
# CONSTANT INTERCYCLE DELAY: "if the cancellation condition is met in the
# interval between cycles, cancellation takes place immediately"). NEXT runs one
# cycle, then its UNTIL 3.0 falls inside the AFTER-10.0 intercycle gap, so it's
# cancelled at t=3 before a second cycle -- the fast-forward now stops at the
# UNTIL instant instead of overshooting to the next wake. Expected TICK/DONE (a
# regression here prints TICK/TICK/DONE). Cross-checked with yaGPC2.
run ./run_local_fixture.sh repeat_after_until "$(printf 'TICK\nDONE')" --time-scale 1000000
# REPEAT ... UNTIL <event>, cancellation BETWEEN cycles (USA003087 Sec. 24.5):
# a separate task SIGNALs EV1 at t=2.5, in WORKER's dormant gap [2,3], so WORKER
# is cancelled immediately before its t=3 cycle -> N=3 (checking UNTIL only at
# CLOSE would run that cycle -> N=4). Event stops have no deadline, so this is
# re-checked every tick (sched_cancel_dormant_on_events), not fast-forwarded to.
run ./run_local_fixture.sh sched_until_event_between "N=               3" --time-scale 1000000

# --pacing=signal smoke test: reuses sched_every (a fast, already-passing
# fixture) with a large --time-scale, same reasoning as the --time-scale
# usage above, to confirm interp_run_signal()'s tick-budget accounting
# and task interleaving produce byte-identical output to the default
# interp_run_burst() path -- this is what would catch a bug in the
# signal-mode budget/tick-consumption arithmetic itself, independent of
# real-time precision (see interp.c's interp_run_signal()).
run ./run_local_fixture.sh sched_every "N=               4" --time-scale 1000000 --pacing=signal

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
# (error 18), TRANSPOSE/TRACE, RANDOM/RANDOMG (originally a from-scratch
# deterministic Park-Miller generator + Box-Muller transform, documented
# at the time as "no primary source... a compromise" -- superseded, see
# DB id 36 comment below), RUNTIME (the existing virtual-clock model), and
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
# ARCTANH(0.5)'s own expected value was updated from 5.4930609E-01 (the
# old libm-based implementation's own less-authentic result) to
# 5.4930639E-01, the authentic RUNASM/ATANH.asm result -- independently
# confirmed bit-for-bit against yaGPC2's own real execution (task
# 100/id 51's own verification, hal_transcendental.c).
# ARCSINH(2.0)'s own expected value was updated from 1.4436350E+00 (the
# old libm-based implementation's own less-authentic result) to
# 1.4436359E+00, the authentic RUNASM/ASINH.asm result -- independently
# confirmed bit-for-bit against yaGPC2's own real execution of this exact
# fixture (task 100/id 51's own verification, hal_transcendental.c).
# SINH(1.0)/TANH(1.0)/ARCCOSH(2.0)'s own expected values were updated
# from 1.1752005E+00/7.6159412E-01/1.3169575E+00 (the old libm-based
# implementation's own less-authentic results) to 1.1752014E+00/
# 7.6159418E-01/1.3169584E+00, the authentic RUNASM/SINH.asm/TANH.asm/
# ACOSH.asm results (task 108/id 51's own RUNASM SINH.asm/TANH.asm/
# ACOSH.asm ports) -- independently confirmed bit-for-bit against
# yaGPC2's own real execution of this exact fixture.
run ./run_local_fixture.sh bfnc_hyperbolic "$(printf ' 1.5430803E+00\n 1.1752014E+00\n 7.6159418E-01\n 1.3169584E+00\n 1.4436359E+00\n 5.4930639E-01\n 0.0          ')"
run ./run_local_fixture.sh bfnc_invtrig "$(printf ' 1.0471973E+00\n 5.2359873E-01\n 0.0          \n 1.5707960E+00\n 3.1415920E+00\n-1.5707960E+00\n 7.8539813E-01\n 0.0          ')"
run ./run_local_fixture.sh bfnc_rounding "$(printf ' 2.0000000E+00\n 3.0000000E+00\n 2.0000000E+00\n 1.0000000E+00\n-3.0000000E+00\n-2.0000000E+00\n-2.0000000E+00\n-1.0000000E+00\n 5.0000000E+00')"
run ./run_local_fixture.sh bfnc_intops "$(printf '          3\n          2\n 2.0000000E+00\n 3.0000000E+00\n          1\n          0\n         48\n         16\n        188')"
run ./run_local_fixture.sh bfnc_char "$(printf '          6\n          0\nAB   \n   AB')"
run ./run_local_fixture.sh bfnc_matrix2 "$(printf ' 1.0000000E+00      4.0000000E+00\n 2.0000000E+00      5.0000000E+00\n 3.0000000E+00      6.0000000E+00\n 1.5000000E+01')"
run ./run_local_fixture.sh lfnc_array "$(printf ' 7.0000000E+00\n 1.0000000E+00\n 1.5000000E+01\n 8.4000000E+01\n          4')"
# DB id 36: the Park-Miller/Box-Muller placeholder above was confirmed
# wrong -- RANDOM/RANDOMG's real algorithm (RUNASM/RANDOM.asm,
# USA003088.txt Sec. 9397/9399) is a classic IBM-SSP "RANDU"-family LCG
# (seed = (65539*seed) mod 2^32, with a two's-complement wraparound fixup)
# shared by both built-ins: RANDOM converts one draw to IBM hex float and
# rounded-multiplies it by 2^-15 (NOT 2^-31 as the asm's own comment
# misleadingly claims -- verified via yaGPC2's floatIBM.c, not by hand-
# decoding); RANDOMG (Irwin-Hall) sums 12 RANU draws and subtracts 6.0.
# Ported bit-exact into hal_random.c/.h, operating directly on
# halmat_scalar_t (confirmed identical bit layout to yaGPC2's FloatIBM).
# Verified three ways for a fixed 28-draw sequence: yaGPC2's own reference
# hal_random.c/floatIBM.c standalone harness, yaHALMAT2 itself, and real
# gpc via compileLinkRun -- all three matched bit-for-bit. Expected values
# below re-derived the same way (yaHALMAT2 and gpc agree).
run ./run_local_fixture.sh random "$(printf ' 4.3794729E-02\n 2.6276231E-01\n 3.9709830E-01')"

# Dedicated bit-exact lock-in for DB id 36: a 28-draw mixed RANDOM/RANDOMG
# sequence (matching the one used against the standalone reference C
# harness and real gpc during this fix's verification) into a SCALAR
# DOUBLE variable, so the full extended-precision (F0:F1) hex-float path
# is exercised end-to-end, not just the single-precision-truncated values
# the "random" fixture above happens to produce. Expected values below
# are yaHALMAT2's own output, cross-checked bit-for-bit against real gpc
# (compileLinkRun) for the identical program before being locked in here.
run ./run_local_fixture.sh random_deterministic "$(printf ' 4.3794728815555573E-02\n 2.6276230812072754E-01\n 1.8242156505584717E-01\n 7.2966837882995605E-01\n 7.3621582984924316E-01\n 1.5062534809112549E-01\n 1.1224867850542068E+00\n-2.6469413563609123E-01\n-1.3050046935677528E-01\n 8.9225000888109207E-01\n 1.7391182482242584E-01\n-1.5725612472742796E+00\n 5.2557062916457653E-01\n 3.6610984429717064E-01\n 8.8674899935722351E-01\n 2.3147720098495483E-01\n 7.8192532062530518E-01\n 5.1727104187011719E-01\n 5.4636526107788086E-01\n 2.3366975784301758E-01\n-3.0304364114999771E-01\n 6.4744396507740021E-01\n 8.3109536767005920E-01\n-1.4940198436379433E+00\n 1.3369635958224535E-01\n 3.2427629269659519E-01\n 1.4605471119284630E-01\n 8.9314310997724533E-01')"
# Expected values updated three times (all user-requested): (1) virtual_time
# now charges 0 ticks for HALMAT opcodes confirmed to have no emitted
# AP-101S machine code of their own on real hardware (SMRK/PXRC/the
# whole Class-8 INITIAL(...) family/etc. -- interp.c's own
# op_cost_ticks(), state.h's HALMAT_TICKS_PER_SECOND comment)
# instead of the uniform 1-tick-per-instruction charge every opcode
# used to get; (2) HALMAT_TICKS_PER_SECOND itself was recalibrated from
# a direct dynamic yaGPC2-vs-yaHALMAT2 runtime comparison across 6 real
# fixtures (state.h's own updated calibration comment) -- 276000 ->
# 16800 ticks/sec, a real instruction now costs ~16.4x more simulated
# time than before; (3) interp.c's op_cost_ticks() moved from that single
# flat non-zero-cost charge to individually-measured per-opcode weights
# for the assignment/arithmetic/loop-control/call opcodes covered so far
# (SASN/IASN/BASN/CASN/VASN/MASN/IADD/SADD/DFOR/EFOR/CTST/CLOS/RTRN/
# PCAL/FCAL/LFNC -- see op_cost_ticks()'s own comment), and
# HALMAT_TICKS_PER_SECOND moved to 1000000 (1 tick == 1 microsecond)
# now that weights are individually-measured microsecond values rather
# than a single pooled multiplier; opcodes not yet in that weighted set
# keep the previous flat rate's own real-world duration (60us, i.e. the
# old 1 tick at 16800 ticks/sec, rounded) unchanged; (4) OP_XXST/OP_XXAR
# gained a real per-item-class WRITE-statement charge (fixed per-statement
# base + per-class marginal rate, both measured from real yaGPC2 traces --
# see op_cost_ticks()'s own OP_XXAR comment), replacing their previous
# flat 60-tick default specifically for WRITE (not READ/CALL) statements.
# RUNTIME()'s own first call (after only a handful of mostly-structural
# and now-individually-weighted setup instructions, no WRITE yet) is
# unaffected by (4) and shifts only from (3); the second (after WAIT(5.0),
# so dominated by the explicit 5-second wait, but by then two WRITE(6)
# statements have also executed) shows a further small residual shift
# from (4) on top of the same small (3)-driven effect on the surrounding
# instructions; (5) OP_BFNC (which RUNTIME itself is, selector 52) gained
# a real per-tag switch in op_cost_ticks(), whose default arm for every
# not-yet-individually-priced selector (including RUNTIME) is 13 ticks --
# the measured mean LOCAL cost of a BFNC instruction generally -- instead
# of the previous flat 60-tick unmeasured-opcode default, so BOTH of
# RUNTIME's own two calls shift by that same -47-tick (-47us) delta on
# top of everything (3)/(4) already changed around them; (6)/(7) READ and
# MATRIX/VECTOR/STRUCTURE WRITE items gained real per-item weights too
# (op_cost_ticks()'s own OP_XXAR comment) -- this fixture uses neither
# directly (no READ), but that same edit accidentally DROPPED the
# existing SCALAR(5)/INTEGER(6) cases from the WRITE-context XXAR switch
# (an editing mistake, not an intentional repricing -- confirmed by
# diffing against the commit that introduced it) while adding the new
# MATRIX/VECTOR/STRUCTURE cases, silently falling those two back to the
# generic 60-tick default instead of their correct 64/62; this fixture's
# own WRITE(6) S1; (S1 a SCALAR) was hit by that regression, which is
# what the "some small change... not fully explained" note previously
# here was actually seeing. (8) Fixed by restoring the two missing
# cases -- the second RUNTIME() call's value reverts to exactly its
# pre-regression figure, back to matching (7)'s own original value.
run ./run_local_fixture.sh runtime "$(printf ' 7.2999988E-05\n 5.0003185E+00')"
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

# User-reported (117-EXAMPLE_8.hal): `POSITIONS ARRAY(5) VECTOR`, indexed
# `POSITIONS$(I:*)`, failed with "DSUB: asterisk subscript with 2 indices
# not yet implemented" -- the same generic-ARRAY-shape gap task #16 had
# deferred (ensure_container() had no shape metadata distinguishing an
# ARRAY-of-VECTOR from a real MATRIX, so it fell back to a 1-dimensional
# element count that also silently undersized the container by 3x,
# discarding each VECTOR's own components). Fixed in two parts: (1)
# symtab.c now decodes SYM_LENGTH into the element's own VECTOR shape
# even when SYM_ARRAY made the symbol's shape==ARRAY (previously only
# read for the plain, unarrayed VECTOR/MATRIX case); (2) ensure_container()
# gives a confirmed ARRAY(n) VECTOR(m) the same rows/cols treatment the
# 2D-ARRAY-of-SCALAR fix gave a real MATRIX, plus a new array_of_vector
# flag (state.h) so DSUB's existing MATRIX-shaped asterisk-select logic
# picks it up "for free" like the 2D-ARRAY case did. A second, deeper bug
# surfaced verifying the file's whole-array vector arithmetic
# (`[VELOCITY] = ([POSITIONS] - [OLD_POSN]) / DELTA_T;`, `[DISTANCE] =
# ABVAL([POSITIONS] - MY_POSN);`, both compiled as VSUB/VSDV/VASN/BFNC
# wrapped in an ADLP/DLPE per-array-index replay): resolve_container()
# always returned an ARRAY-of-VECTOR SYT operand's *whole* flat container,
# never slicing by the replay's own arrayed_index -- happened to still
# give the right final answer when both VSUB operands were same-shaped
# ARRAY-of-VECTORs (pure elementwise math doesn't care about the VECTOR
# grouping), but broke the mixed-shape ABVAL/VDOT cases (`POSITIONS`, an
# ARRAY(5) VECTOR, combined with `MY_POSN`, a plain VECTOR(3) broadcast
# across every array index) with a shape-mismatch failure. Fixed by making
# resolve_container's QUAL_SYT case (and OP_VASN's own dest-SYT write,
# which has its own hand-rolled write path rather than going through
# write_destination) consult the new array_of_vector flag and slice to
# just the current arrayed_index's own VECTOR when set, leaving a plain
# (non-array_of_vector) VECTOR/MATRIX operand's whole-container resolution
# untouched -- exactly the automatic "broadcast" behavior the mixed-shape
# case needs. All values independently hand-verified (vector subtraction/
# magnitude/dot-product arithmetic), not just cross-checked against
# compileLinkRun.
# The two ABVAL lines' own expected values corrected 2026-07-29 (id 67,
# yagpc2-yahalmat2-issues.db): were 1.0488088E+01/5.3851643E+00 --
# "independently hand-verified" per the comment above, but that hand
# verification used ordinary (mathematically exact) arithmetic, which is
# NOT what real hardware's own ABVAL actually computes -- real hardware
# calls the genuine SQRT.asm RTL algorithm (a hyperbolic-approximation-
# plus-Newton-Raphson routine, not a mathematically exact sqrt), same as
# every other SQRT call site, and lands 1 ULP off from the exact value
# here. yaHALMAT2 previously used a libm sqrt() shortcut for ABVAL that
# happened to coincidentally match the mathematically-exact hand-
# verification instead of real hardware. Confirmed 1.0488089E+01/
# 5.3851652E+00 bit-exact against a fresh real-gpc run of this exact
# file.
run ./run_local_fixture.sh array_of_vector "$(printf ' 1.0000000E+00      2.0000000E+00      3.0000000E+00\n 4.0000000E+00      5.0000000E+00      6.0000000E+00\n 7.0000000E+00      8.0000000E+00      9.0000000E+00\n 0.0                0.0                0.0          \n 1.0000000E+00      1.0000000E+00      1.0000000E+00\n 2.0000000E+00      2.0000000E+00      2.0000000E+00\n 1.0488089E+01\n 5.3851652E+00\n 1.4142132E+00\n 1.0000000E+00      2.0000000E+00      3.0000000E+00\n 4.0000000E+00      5.0000000E+00      6.0000000E+00\n 7.0000000E+00      8.0000000E+00      9.0000000E+00')"
# User-reported (119-EXAMPLE_9.hal's `INNER: DO FOR TEMPORARY J = 1 TO 3;
# ... EXIT INNER; ... END INNER;`): "branch to undefined label 11" --
# `EXIT <label>;` targeting a *labeled* `DO FOR` compiles to a plain BRA
# whose INL operand is the same construct-id number DFOR/EFOR both carry
# (like EXIT-of-DTST/ETST does), but precompute_labels() only ever
# registered OP_LBL and OP_ETST, never DFOR/EFOR's own label. Fixed by
# registering it from EFOR (which already carries the label directly,
# needing no separate DFOR lookup), landing at EFOR's position + 1 per
# EFOR.md's own confirmed LSTALL trace (same "just past this instruction"
# convention as ETST's own registration, not landing on EFOR itself,
# which would re-run its increment/re-test instead of exiting). Building
# this fixture surfaced a second, latent bug: precompute_labels()'s own
# OP_LBL branch never checked the operand's qualifier, so `INNER:`'s own
# LBL (a STATEMENT LABEL declaration, QUAL_SYT) could numerically collide
# with an unrelated QUAL_INL bookkeeping label elsewhere in the same
# small unit, silently mis-registering it -- not observed against the
# real corpus file (no collision there), but a real latent trap once
# constructed. Fixed by requiring QUAL_INL on that branch too. Expected
# output (top-3-by-magnitude selection: V has magnitudes 3,7,1,9,5)
# independently hand-derived by tracing the algorithm by hand.
run ./run_local_fixture.sh exit_dfor_label "$(printf ' 9.0000000E+00\n 7.0000000E+00\n 5.0000000E+00')"
# User-reported (120-EXAMPLE_A.hal's `DATA_VALID$(J:) = FALSE;`, DATA_VALID
# an `ARRAY(4) BOOLEAN`): "DSUB: asterisk subscript with 2 indices not yet
# implemented". A BIT/BOOLEAN (or CHARACTER) ARRAY subscript compiles
# through the same "index + trailing asterisk" DSUB shape M$(i,*) uses --
# confirmed via a real compiled trace (DSUB's own tag=1=BIT). Unlike
# VECTOR/MATRIX, the asterisk here selects no sub-range (a BIT/CHARACTER
# element has nothing further to select "all of"); it's just how the
# compiler always spells this subscript. Fixed by treating it as an
# ordinary single-element writable reference (the same is_ref VAC-slot
# mechanism DSUB's generic per-dimension path already uses), not a
# container-producing partition select. Fixing this surfaced a second,
# independent bug once execution got further: `CALL EXAMPLE_A(SCALAR(...),
# ...)`, an ARRAY(4) SCALAR procedure input parameter fed by a SCALAR(...)
# shaping-function argument, silently bound as all-zero -- the compiler
# wraps that argument's own XXAR in an ADLP(4)/DLPE per-element replay
# (like a plain ARRAY WRITE argument), but the XXAR's operand is a VAC
# slot already holding SSHP's own whole computed container, not a plain
# per-index SYT reference -- resolve_operand's QUAL_VAC case has no
# is_container fallback at all, so every replay pass silently left the
# parameter's SYT storage at its zero-initialized default (`ALT(J) <= 0`
# reading 0.0, unconditionally true, rejecting every element with no
# error). Fixed by letting a VAC container operand bypass the
# arrayed_index<0 whole-container gate entirely (unlike a plain SYT
# reference, a VAC container has no per-replay-pass ambiguity to
# disambiguate), captured once on the first pass only (later passes
# skipped, avoiding duplicate items[] entries that would misalign later
# arguments' own parameter binding). Output independently hand-verified
# (AVERAGE = mean of 4 in-range readings; single-precision catastrophic
# cancellation at VRUNTIM's 1e6 magnitude makes the "how recent" check
# pass trivially for the tiny sub-1.0 TIMETAG offsets used here).
run ./run_local_fixture.sh bit_array_dsub "$(printf ' 9.9500000E+03     1     1     1     1')"
# User-suggested sweep of "not (yet) implemented" fail() sites still left
# in interp.c: UPDATE PRIORITY (class-0/PRIO.md) had a fully primary-
# source-confirmed operand-word format (a real HALSFC LSTALL trace) but
# no runtime implementation at all -- every real compile of the statement
# failed with "opcode 0x038 (PRIO) not yet implemented". Implemented by
# writing the resolved new-priority value into the target task's own
# `priority` field (the same field SCHEDULE...PRIORITY(...) already sets
# at task creation, and sched_pick_next() already consults to choose the
# next READY task to run) -- named-process form per the confirmed trace;
# self/unlabeled form (operand_count==1, no process operand) is a
# reasonable inference from CANC/TERM's own already-confirmed self-vs-
# named distinction, though PRIO.md itself flags that specific form as
# untested. Demonstrates actual preemption: WORKER is scheduled at a
# priority (30) too low to preempt the primal's own default (50, same as
# test_sched_low.hal), then UPDATE PRIORITY WORKER TO 90 raises it above
# the primal's -- the very next scheduler tick switches to WORKER,
# confirming the write actually reaches the field sched_pick_next() reads.
run ./run_local_fixture.sh prio "$(printf 'BEFORE SCHEDULE\nBEFORE UPDATE\nAFTER UPDATE\nWORKER RUNNING')"
# Same sweep: WAIT (class-0/WAIT.md) only had its interval form (tag=1)
# implemented; WAIT UNTIL (tag=2) and WAIT FOR DEPENDENT (tag=0, no
# operands) both failed loudly despite WAIT.md's own operand-word format
# already being fully confirmed for all three forms. WAIT UNTIL reuses
# the same schd_seconds_to_ticks() helper SCHD's AT/STOPPING...UNTIL
# clauses already use, with the same "absolute virtual-time-in-seconds,
# not relative to now" semantics (confirmed by SCHD's own stop_deadline
# comparing directly against state->virtual_time, never adding it) --
# WAIT.md's own "wait until a specified real time" wording matches this
# directly.
run ./run_local_fixture.sh wait_until "DONE" --time-scale 1000000
# WAIT FOR DEPENDENT ("wait until all dependent processes have
# terminated", USA003087 Sec. 13.5) reuses the existing has_active_
# dependents()/sched_wake_dependents() mechanism already built for the
# CLOSE-triggered TASK_WAITING_FOR_DEPENDENTS case (COUNTUP2.hal, earlier
# session) -- but that existing mechanism unconditionally *terminates*
# the waiting task once its dependents clear, which is correct for "this
# task's own body is already finished" but wrong for a *mid-body* WAIT
# statement, which must resume execution instead. Fixed with a new,
# distinct TASK_WAITING_FOR_DEPENDENTS_RESUME state (state.h) that
# sched_wake_dependents() transitions back to TASK_READY rather than
# TASK_TERMINATED. Fixture confirms genuine blocking, not a no-op: the
# primal's own "PRIMAL DONE" only prints after WORKER's "WORKER DONE"
# (WORKER itself does a 1-second WAIT first), not before.
run ./run_local_fixture.sh wait_dependent "$(printf 'WORKER DONE\nPRIMAL DONE')" --time-scale 1000000
# Direct user correction of an earlier wrong claim in this sweep ("SUBBIT
# assignment to SCALAR needs IEEE-754 modeling this interpreter doesn't
# have"): AP-101S SCALAR is IBM hexadecimal floating point, not IEEE-754,
# and this project's own halmat_scalar_t (value.h) already stores the
# exact bit-for-bit wire format -- SUBBIT(a_scalar_var) (SINGLE
# precision) needs no new modeling at all, just reinterpreting `msw`
# directly. Fixed two bugs: (1) the reference-context read (STOQ,
# `B = SUBBIT(scalar_var);`) previously rounded the scalar to its
# nearest INTEGER first (rv_to_integer(), the same routine STOI/STOB use
# for the semantically different ordinary INTEGER()/BIT() conversion
# functions) instead of reading its real raw bits -- a latent,
# previously-unexercised bug (only SUBBIT(integer) had a fixture before).
# (2) the assignment-context write (`SUBBIT(scalar_var) = ...;`) simply
# had no SCALAR case at all. DOUBLE-precision SCALAR (a real 64-bit
# pattern) still fails loudly both directions -- this interpreter's BIT
# value representation is uint32_t everywhere, a project-wide ceiling,
# not something safe to guess past. Fixture: test_subbit_scalar.hal
# (round-trips a known scalar's raw bits out through SUBBIT-in-reference-
# context and back in through SUBBIT-in-assignment-context, onto both an
# already-scalar-typed and a never-before-written target -- 1093140480
# independently hand-verified as 0x41280000, the correct IBM HFP encoding
# of 2.5).
# First line updated from 1093140480 to 0: `WRITE(6) INTEGER(B2);` (B2 =
# SUBBIT(S1), a bare BIT expression with no declared width of its own)
# defaults to single-precision (16-bit signed) truncation like any other
# non-DOUBLE INTEGER context -- interp.c's WRITE-argument capture (same
# fix as `init8`/`subbit_assign`/`bit_at_partition`). B2's low 16 bits are
# all zero here (S1=2.5's IBM-hex representation, 0x41280000, has zeros
# throughout its own low half), so the truncated/reinterpreted result is
# plain 0 -- matching real gpc output exactly (this was previously flagged
# in problems-yaHALMAT2.md as "genuinely ambiguous," but it's the same
# root cause as the other four items in that report, not a separate
# unresolved question).
run ./run_local_fixture.sh subbit_scalar "$(printf '          0\n 2.5000000E+00\n 2.5000000E+00')"
# Found cross-checking the SUBBIT/SCALAR fix above against a genuinely
# DOUBLE-precision variable: a plain (non-array) SCALAR DOUBLE's own
# INITIAL() literal value silently kept SINGLE precision. Real HALSFC
# emits the shortest exact literal encoding regardless of the
# destination's declared precision (2.5 compiles as an ordinary "Type
# FIXED"/SINGLE literal even when INITIAL()-assigned into a SCALAR DOUBLE
# target) -- write_syt_entry() (SINT's own destination-write path for a
# plain, non-array SCALAR SYT) never normalized to the destination's
# declared SINGLE/DOUBLE precision the way OP_IASN/OP_SASN's own
# dest_sym coercion and write_container_element() already do at their
# own sites -- this was the one remaining plain-SCALAR-destination write
# path missing it. Fixed by threading the destination SYT index through
# (mirroring write_container_element's existing dest_syt convention) and
# applying the same symtab-driven scale_precision() normalization.
run ./run_local_fixture.sh scalar_double_initial " 2.5000000000000000E+00"
# User-reported (128-MASS.hal's `WRITE(6) MASS(REST_MASS, SPEED);`, MASS
# a same-unit, non-inline SCALAR-returning FUNCTION -- containing its own
# nested FUNCTION TAU, called via an ordinary FCAL/RTRN pair): always
# printed a constant INTEGER "1" regardless of input. Root cause:
# OP_RTRN's genuine same-unit-call-frame branch (`state->call_return_sp >
# 0`, as opposed to the inline-FUNCTION or external-call forms just
# above it, both already correct) unconditionally forced the return
# value through rv_to_integer() and stored only `.integer` on the FCAL's
# own VAC slot -- discarding the function's real declared return type
# (SCALAR here) entirely. MASS's own relativistic-mass result happens to
# stay close enough to 1.0 for any realistic input that rv_to_integer()
# rounds it to a constant 1 every time, which is what made the bug read
# as "always exactly 1" rather than an obviously wrong value. Fixed by
# routing through store_resolved_to_vac() (the same kind-preserving
# helper the inline-FUNCTION case a few lines above already uses
# correctly) instead of hand-rolling an INTEGER-only write. Apparently
# never exercised by any prior fixture: every existing SCALAR/CHARACTER-
# returning FUNCTION fixture is either EXTERNAL (a separate cross-unit
# result-copy path) or INLINE (the IDEF/ICLS branch) -- this was the
# first real corpus program found to call an ordinary same-unit FUNCTION
# and look at its own non-INTEGER return value. Output independently
# hand-verified against the relativistic mass formula
# (1/sqrt(1-(v/c)^2)) for two different speeds; a compileLinkRun
# cross-check was attempted but the tool hung on interactive stdin
# redirection, unrelated to this fix. Fixture: test_fcal_scalar_return.hal
# (a minimal same-unit FUNCTION returning a non-integer SCALAR, isolating
# the exact mechanism without 128-MASS.hal's own nested-FUNCTION and
# READ-loop complexity).
run ./run_local_fixture.sh fcal_scalar_return "$(printf ' 1.2500000E+00\n 3.2500000E+00')"
# Same file, a second bug in the same fix's neighborhood, user-reported
# (129-ALMOST_EQUAL.hal's `WRITE(6) ..., ALMOST_EQUAL(1.0, 1.0);`,
# ALMOST_EQUAL a same-unit FUNCTION declared BOOLEAN -- a synonym for
# BIT(1), USA003087's own terminology): printed every result as a full
# 32-bit binary field ("0000 0000 0000 0000 0000 0000 0000 0001")
# instead of the single-digit BIT(1) it actually is. Unlike a bare BIT
# literal or a computed BAND/BOR/BNOT result (where the real width
# genuinely isn't known, and defaulting to the documented legal maximum
# of 32 is the correct, already-established fallback -- USA003090 Sec.
# 8.2 rule 6), a FUNCTION-call result's width *is* knowable here, from
# the callee's own declared return type -- WRITE's existing argument-
# capture code already looks this up for a plain SYT variable reference
# via the symbol table, but never for a QUAL_VAC operand carrying a
# FUNCTION-call result. Fixed by having OP_RTRN's own genuine-call-frame
# branch (the exact site the previous fcal_scalar_return fix touched)
# stamp the callee's own symtab-declared bit_width onto the VAC slot
# (new bit_width field, state.h) whenever the return value is BIT-typed,
# for the WRITE-argument-capture code to prefer over the generic 32-bit
# default. Fixture: test_fcal_boolean_return.hal.
run ./run_local_fixture.sh fcal_boolean_return "$(printf '1\n0')"
# User-reported (134-DOTS.hal's `WRITE(6) 'DOTS:', DOTS(V1, V2);`, V1/V2
# each `ARRAY(10) VECTOR(3)`): "I/O statement has too many items". A
# same-unit FUNCTION call's own ARRAY arguments each get ADLP/DLPE-
# replayed per element (XXAR's already-established "a plain (or BIT/
# CHARACTER) ARRAY argument IS wrapped in a per-element replay" rule) --
# 10 items for V1 plus 10 for V2, comfortably more than the fixed
# HALMAT_MAX_OPERANDS(=16)-sized items[] array previously had room for.
# HALMAT_MAX_OPERANDS is a correct, primary-sourced bound on a single
# HALMAT *instruction's* own operand count -- reusing it to size
# io_pending's own item *list*, which needs one entry per WRITE/CALL data
# item and can genuinely scale with an array argument's declared size,
# was always an architectural mismatch, not a real HAL/S limit. Fixed by
# making io_pending.items a growable, heap-allocated array (new
# halmat_io_item_t type, state.h; io_pending_reserve_item(), interp.c),
# grown via realloc-doubling as needed instead of capped at a fixed
# compile-time size -- also shrinks halmat_state_t itself slightly (a
# pointer+size_t per frame instead of 16 full items inline, x9 frames
# between io_pending and its own 8-deep nesting stack). 134-DOTS.hal
# itself still doesn't fully run after this fix -- its own `RETURN
# RESULT;` (RESULT a whole MATRIX(10,10)) hits the separate, already-
# tracked "OP_RTRN's deeper whole-array-return gap" (task #26) -- so this
# fixture isolates just the item-capacity mechanism (20 plain SCALAR call
# arguments, no arrays/matrices involved) rather than reproducing
# 134-DOTS.hal verbatim.
run ./run_local_fixture.sh many_call_args " 2.1000000E+02"
# User-reported, follow-up on the same file (134-DOTS.hal, "Fix it" after
# the many_call_args fix above): once the item-capacity gap was fixed, the
# file ran to completion but still hit two further bugs. (1) OP_RTRN's
# genuine same-unit-call-frame branch had no handling at all for a whole
# VECTOR/MATRIX RETURN value (`RETURN RESULT;`, RESULT a MATRIX(10,10)) --
# only ever exercised RV_SCALAR/RV_STRING/RV_BITS/RV_INTEGER via
# store_resolved_to_vac, which has no container case -- so it fell through
# to the ordinary resolve_operand() path and failed loudly ("SYT index 7
# is a whole ARRAY/VECTOR/MATRIX referenced outside an arrayed-paragraph
# replay"). Fixed by detecting a whole VECTOR/MATRIX (QUAL_SYT,
# syt_is_vector_or_matrix_shaped) or VAC-container RETURN operand and
# routing it through resolve_container()/store_container_result() instead,
# mirroring the WRITE-argument whole-container capture's own established
# pattern. (2) Even with that fix, DOTS's own RESULT matrix printed as all
# zeros -- traced to OP_XXAR's plain-value capture path calling
# resolve_operand() (one flat scalar per ADLP replay pass) for a same-unit
# CALL's own whole-ARRAY-of-VECTOR argument (`DOTS(V1, V2)`, V1/V2 each
# `ARRAY(10) VECTOR(3)`), which the compiler wraps in an ADLP(10)/DLPE
# replay (confirmed via --disasm: ADLP's own count is 10, one per VECTOR
# row, not 30) -- each of the resulting 10 replay-captured items[] entries
# was then bound by bind_call_argument's positional loop to its own
# separate parameter SYT slot (callee+1+i), when all 10 are really parts
# of ONE logical argument (A1), corrupting DOTS's other locals while
# leaving A1/A2 themselves unpopulated. Fixed with a new call_array_replay
# case alongside the existing whole_vac_container one: in a CALL context, a
# plain SYT ARRAY-shaped operand under replay is captured whole (via
# resolve_container with arrayed_index temporarily forced to -1, reusing
# its already-correct "outside a replay" whole-container path instead of
# its per-row array_of_vector slicing) on the replay's first pass only,
# then skipped on subsequent passes -- exactly the idempotent-skip pattern
# whole_vac_container already established (120-EXAMPLE_A.hal fix). Fixture:
# test_dots.hal (the real corpus file itself, copied verbatim -- its own
# documented `V1(I)=(I,0,0), V2(J)=(1,0,0) => RESULT(I,J)=I` comment gives
# an independently hand-verifiable expected result: each output row I is
# constant, filled with I across all 10 columns). Expected string updated
# for the PAGED-default line-length fix below (132, was 80) -- each row's
# first physical line now fits 6 fields before wrapping, was 3.
run ./run_local_fixture.sh dots "$(printf 'DOTS:\n 1.0000000E+00      1.0000000E+00      1.0000000E+00      1.0000000E+00      1.0000000E+00      1.0000000E+00      1.0000000E+00\n 1.0000000E+00      1.0000000E+00      1.0000000E+00\n 2.0000000E+00      2.0000000E+00      2.0000000E+00      2.0000000E+00      2.0000000E+00      2.0000000E+00      2.0000000E+00\n 2.0000000E+00      2.0000000E+00      2.0000000E+00\n 3.0000000E+00      3.0000000E+00      3.0000000E+00      3.0000000E+00      3.0000000E+00      3.0000000E+00      3.0000000E+00\n 3.0000000E+00      3.0000000E+00      3.0000000E+00\n 4.0000000E+00      4.0000000E+00      4.0000000E+00      4.0000000E+00      4.0000000E+00      4.0000000E+00      4.0000000E+00\n 4.0000000E+00      4.0000000E+00      4.0000000E+00\n 5.0000000E+00      5.0000000E+00      5.0000000E+00      5.0000000E+00      5.0000000E+00      5.0000000E+00      5.0000000E+00\n 5.0000000E+00      5.0000000E+00      5.0000000E+00\n 6.0000000E+00      6.0000000E+00      6.0000000E+00      6.0000000E+00      6.0000000E+00      6.0000000E+00      6.0000000E+00\n 6.0000000E+00      6.0000000E+00      6.0000000E+00\n 7.0000000E+00      7.0000000E+00      7.0000000E+00      7.0000000E+00      7.0000000E+00      7.0000000E+00      7.0000000E+00\n 7.0000000E+00      7.0000000E+00      7.0000000E+00\n 8.0000000E+00      8.0000000E+00      8.0000000E+00      8.0000000E+00      8.0000000E+00      8.0000000E+00      8.0000000E+00\n 8.0000000E+00      8.0000000E+00      8.0000000E+00\n 9.0000000E+00      9.0000000E+00      9.0000000E+00      9.0000000E+00      9.0000000E+00      9.0000000E+00      9.0000000E+00\n 9.0000000E+00      9.0000000E+00      9.0000000E+00\n 1.0000000E+01      1.0000000E+01      1.0000000E+01      1.0000000E+01      1.0000000E+01      1.0000000E+01      1.0000000E+01\n 1.0000000E+01      1.0000000E+01      1.0000000E+01')"
# User-reported: WRITE-context SKIP/COLUMN/TAB/LINE/PAGE (USA003087 Sec.
# 12.4's five device-mechanism-positioning pseudo-functions) printed their
# own numeric argument as an ordinary data field instead of repositioning
# anything -- OP_XXAR's TAG2 check for these specifiers was only ever
# wired up for READ/READALL (task #17), never WRITE. Implementing this
# properly required a genuine architecture change: the device mechanism's
# position (page/line/col) now persists per-device across WRITE
# statements (new device_mech[], state.h), and the *current* line stays
# buffered in memory (not flushed to the output file) until something
# actually moves the mechanism down -- this is what makes backward
# TAB(-n)/COLUMN(n) overstrike possible at all, since a plain streaming
# write can never move backward once a character reaches the file.
# Verified end-to-end against all three of USA003087's own worked
# examples (Sec. 12.4, Figs. 12-5/12-6/12-7), each independently
# reconstructed with a known starting position (the book's own diagrams
# assume unshown prior context, so exact page/line/column numbers differ
# from the text, but the underlying mechanics match precisely):
# - Fig. 12-5 (TAB/COLUMN): `TAB(-50),C1,COLUMN(5),C2,C3,TAB(2)` from an
#   established column (via a preceding TAB(79) write) correctly produces
#   C1 rightmost (overstrike after backward TAB), C2 leftmost (absolute
#   COLUMN), C3 via the ordinary separator -- also surfaced a real
#   modeling gap while chasing this: a *leading* TAB/COLUMN is relative
#   to the column the mechanism was already at, not column 1 (Sec. 12.4:
#   "it overrides the default positioning at column 1", despite the
#   ordinary vertical movement still happening). Fixture: test_tabcol.hal.
run ./run_local_fixture.sh tabcol "$(printf '                                                                               Q\n    SECOND     THIRD          FIRST')"
# - Fig. 12-6 (SKIP/LINE): `SKIP(0),C1, LINE(1),C2,C3` -- SKIP(0)
#   "inhibits [the] default line advance" (stays on the same line) while
#   C1 still "starts in column 1" (Fig. 12-6's own label) -- surfaced a
#   second gap: dm_advance_lines(n=0) is a real, meaningful case (SKIP(0),
#   or LINE(gamma) when already on line gamma), not just a degenerate
#   no-op skip; needed an explicit column-1 reset since n==0 means the
#   per-line loop that normally does that never runs. LINE(1), gamma=1
#   less than the current (established via a preceding SKIP(4)) line,
#   correctly crosses to line 1 of the next page. Fixture:
#   test_skipline.hal, run with --page-length 10.
run ./run_local_fixture.sh skipline "$(printf '\n\n\n\nFIRST\n\fSECOND     THIRD')" --page-length 10
# - Fig. 12-7 (PAGE): `SKIP(4),C1, PAGE(1),C2` -- PAGE(1) moves to the
#   next page while keeping the *relative line number unchanged* (C1 and
#   C2 land on the same line number, one page apart) -- confirmed via
#   USA003090 Sec. 6.1.4's RECFM=FBA finding (this same session's
#   line-length fix): the between-page string defaults to a bare
#   ASCII form-feed (0x0C), matching a real line printer's own page-eject
#   convention, exposed as --ff (with %p auto-substituted with the page
#   number, an implied trailing newline unless the string is empty/a bare
#   form-feed/already ends in '\n' -- user-specified design). Fixture:
#   test_page.hal, run with --page-length 10.
run ./run_local_fixture.sh page "$(printf '\n\n\n\nFIRST\n\f\n\n\n\nSECOND')" --page-length 10
# Same fixture, --ff overridden to a page-heading template with a
# literal "%p" (user-specified design): confirms the substitution (page 2,
# the page being advanced *to*) and the implied trailing newline a
# non-empty/non-bare-form-feed/non-newline-terminated --ff string gets
# (so the heading lands on its own line rather than running into the
# blank-line padding that follows it).
run ./run_local_fixture.sh page "$(printf '\n\n\n\nFIRST\n=== PAGE 2 ===\n\n\n\n\nSECOND')" --page-length 10 --ff '=== PAGE %p ==='
# User-reported (140-STATISTICS.hal's `CALL STATISTICS(DATA) ASSIGN(LO,
# HI, MN);`, STATISTICS's own `DATA` parameter declared `ARRAY(*)
# SCALAR` -- USA003087 Sec. 7.5/20.11's assumed-size parameter, whose
# real size "may...vary from invocation to invocation"): "MATRIX/VECTOR/
# ARRAY argument shape does not match parameter 7". Root-caused to two
# compounding bugs. (1) symtab.c's own EXT_ARRAY dimension-bound parsing
# never sign-extended from the field's real 16-bit width (confirmed via
# the raw COMMON0.out dump: "EXTuARRAY n BIT xxxx", always 4 hex
# digits) -- an assumed-size parameter's own bound is encoded as a
# *negative* 16-bit sentinel (0xFFF9 = -7 here; cross-checked against
# 141-VSUM.hal's own `ARRAY(*) VECTOR` case, which uses a *different*
# magnitude, 0xFFFC = -4, confirming "any negative value" rather than
# one fixed constant), previously misread as a huge unsigned "size"
# (65529) instead. (2) Even with that fixed, ensure_container() had no
# way to represent "this parameter's real size isn't known until a call
# actually supplies one" -- it would still try to allocate *something*
# from whatever bogus size fell out of the (still-visible-as-generic-
# fallback) shape logic. Fixed by having ensure_container() leave an
# assumed-size ARRAY parameter entirely unallocated, and bind_call_
# argument() allocate it directly from the caller's own actual argument
# shape instead of requiring a match against a declared size that
# doesn't exist for this kind of parameter. Separately confirmed (same
# investigation, not fixed -- a different, pre-existing gap unrelated to
# assumed-size specifically): 141-VSUM.hal's own `ARRAY(*) VECTOR` case
# no longer crashes with this fix, but still computes a wrong answer
# (3x too large) -- LFNC's SIZE selector returns an array_of_vector-
# shaped argument's flat scalar count (9) rather than the "length of
# array" USA003087 Appendix B's SIZE FUNCTION table actually specifies
# (3, the VECTOR count), inflating a `DO FOR N=1 TO SIZE(V)` loop bound
# 3x. Fixture: test_statistics.hal (134-DOTS.hal-style: the real corpus
# file itself, copied verbatim; LO=MIN=10, HI=MAX=50, MEAN=SUM/SIZE=
# 150/5=30, all hand-derivable from DATA's own INITIAL(10,20,30,40,50)).
run ./run_local_fixture.sh statistics "$(printf 'LO=      1.0000000E+01     HI=      5.0000000E+01     MEAN=      3.0000000E+01')"
# User-instructed follow-up ("Fix 141-VSUM.hal's SIZE bug too"), flagged
# as a separate finding during the ARRAY(*) fix above:
# `DECLARE V ARRAY(*) VECTOR; ... DO FOR TEMPORARY N = 1 TO SIZE(V); TOTAL
# = TOTAL + V$(N:); END;` computed SUM=(3,6,9) instead of the hand-
# derivable (1,2,3) -- 3x too large. LFNC's SIZE selector (23) returned
# an `array_of_vector`-shaped argument's *flat scalar* count (resolve_
# container's own OUT_COUNT, e.g. 9 for an ARRAY(3) VECTOR(3)) rather
# than the "length of array" USA003087 Appendix B's own SIZE FUNCTION
# table specifies (3, the VECTOR count) -- inflating the loop bound 3x,
# each of the 3 "extra" passes silently re-summing the same 3 real
# VECTORs again via V$(N:)'s own modulo-wrapping index. Fixed by using
# `rows` (the array's own length) instead of the flat count whenever
# resolve_container reports a 2D shape (rows>0 && cols>0) -- unambiguous
# in practice, since a genuinely 2-dimensional ARRAY(r,c) of SCALAR
# shares that same rows/cols encoding but isn't "one-dimensional," so
# SIZE() on one isn't valid HAL/S to begin with. A plain flat ARRAY (not
# array-of-VECTOR) is unaffected -- its own flat count already equals
# its "array length." Fixture: test_vsum.hal (141-VSUM.hal copied
# verbatim; output hand-derived from V's own INITIAL(1,0,0, 0,2,0,
# 0,0,3): elementwise sum = (1,2,3)).
run ./run_local_fixture.sh vsum "$(printf 'SUM=\n 1.0000000E+00      2.0000000E+00      3.0000000E+00')"
# User-instructed corpus sweep ("test all such files which have not
# already been reported to you as problematic"), 254-TEST1.hal: `OUTPUT =
# 10*OUTPUT + INTEGER(INPUT$(4 AT I));` (INPUT a plain BIT(24), unpacking
# it 4 bits at a time) failed with "VAC whole-container result referenced
# outside an arrayed-paragraph replay". DSUB's own "VECTOR at-partition"
# branch (046-XYZ_TO_POLAR.hal's earlier fix, `P$(2 AT 1)`) was gated only
# on `base->rows == 0` -- true for ANY non-MATRIX base including a plain
# scalar BIT variable, not just a VECTOR -- so it wrongly fired here too,
# reading through `base->elements`, which a scalar BIT symbol doesn't
# have (ensure_container()'s own generic "unknown shape" fallback
# silently allocates a bogus 64-element placeholder for any unclassified
# SYT entry regardless, letting this read through without an immediate
# crash but producing nonsense). Fixed by gating that branch on
# `ins->tag == 4` (this instruction's own confirmed "HALMAT class of the
# result" convention -- 4=VECTOR, vs. 1=BIT for this file's own case) and
# adding a new, dedicated branch for the BIT case: a native `B$(width AT
# position)` bit-substring read directly on a scalar BIT/INTEGER/SCALAR
# value's own raw bits (MSB-first, matching format_bit_field's own
# established convention), computed immediately as a plain is_bits VAC
# result rather than routed through the container machinery at all.
# Output independently hand-verified: digit-by-digit hand-simulation
# against the file's own WRITE(6) INPUT; bit-group dump matches the
# computed OUTPUT=56525 exactly. Fixture: test_bit_at_partition.hal
# (254-TEST1.hal plus one added WRITE(6) OUTPUT; line).
# Updated from 56525 to -9011: the accumulated OUTPUT (`OUTPUT = 10
# OUTPUT + INTEGER(...)`) already computed the exact right unsigned 16-bit
# value (56525 = 0xDCCD); the fix is that a plain single-precision
# INTEGER must be reinterpreted as *signed* 16-bit when finally printed,
# not left as this emulator's own wider int32_t -- interp.c's
# WRITE-argument capture (same fix as `init8`/`subbit_assign`/
# `subbit_scalar`), matching real gpc output exactly (0xDCCD as signed
# 16-bit is -9011).
run ./run_local_fixture.sh bit_at_partition "$(printf '      -9011')"
# 154-ADD.hal: `READ(5) A;`, A a plain flat ARRAY(100) SCALAR, wrapped in
# an ADLP(100)/DLPE per-element replay at XXAR-capture time (unlike a
# whole VECTOR/MATRIX READ destination, which is NOT replayed -- see
# XXAR.md) -- failed with "SYT index N is a whole ARRAY/VECTOR/MATRIX
# referenced outside an arrayed-paragraph replay". Root cause: OP_READ's
# own per-item write loop runs *after* the whole ADLP replay (which only
# wrapped the XXAR capture step) has already finished and reset
# arrayed_index to -1, but write_destination's plain-SYT-ARRAY branch
# needs arrayed_index >= 0 to know which element to write. Fixed by
# substituting the loop's own item index i (items[] preserves the same
# 0..N-1 order the real replay used during capture) as arrayed_index for
# each item's own write_destination call, restored once after the whole
# loop. Fixture: test_read_array.hal (154-ADD.hal verbatim; 100 values
# via stdin, hand-derivable TOTAL=10+20+30=60 once the loop hits the
# first 0 and its own UNTIL clause stops).
run ./run_read_fixture.sh read_array "$(python3 -c "print(' '.join(['10','20','30'] + ['0']*97))")" "$(printf 'TOTAL IS       6.0000000E+01')"
# 159-AGE.hal: `CASE_NUM = INTEGER(C$(1 TO 3));`/`SEX = INTEGER(C$(6));`
# (`C` a plain, non-ARRAY `CHARACTER(80)`) failed with "CTOI: operand is
# not CHARACTER". DSUB's own CHARACTER to-partition/single-index
# substring kinds (`C$(a TO b)`/`C$(n)`, this instruction's own operator-
# word TAG confirming a CHARACTER result -- 2=CHARACTER) were entirely
# unimplemented (DSUB.md's own longstanding "To-partition (CHARACTER
# substring)... still isn't handled" gap) -- both previously fell through
# to the generic per-dimension index loop, which misreads a to-partition
# pair as two unrelated indices (or a single index as a numeric offset),
# producing a bogus numeric `is_ref` into a scalar CHARACTER symbol's own
# nonexistent element array. Fixed with two new DSUB branches (plain-
# literal-bounds only -- the `#`-relative/CSZ form, 160-REFORMAT.hal,
# remains a separate, still-unresolved gap) reading the substring
# directly from the base's own `char_value` string. Output independently
# hand-verified against a probe with an added WRITE (X's own `7 TO 10`
# bound wasn't otherwise exercised by the real corpus file, which has no
# WRITE at all). Fixture: test_char_subscript.hal (159-AGE.hal plus one
# added WRITE(6) line).
run ./run_read_fixture.sh char_subscript "1234567890" "$(printf "CASE_NUM=             123     AGE=              45     SEX=               6     X=            7890")"
# 254-TEST2.hal: `IF B$(1) THEN ...;`/`IF B$(#) THEN ...;` (`B` a plain
# `BIT(16)`, used directly as a boolean condition after `B = BIT(I);`)
# failed with "BTRU: operand is not BIT". A single-index BIT-string
# subscript (implicit 1-bit width) on a plain, non-ARRAY BIT/INTEGER/
# SCALAR base was entirely unhandled, falling through to the generic
# per-dimension index loop the same way the at-partition case
# (test_bit_at_partition.hal, above) did -- fixed the same way, a new
# DSUB branch reading 1 bit directly via the same MSB-first shift-and-
# mask. `B$(#)` turns out not to need CSZ at all here -- HALSFC folds a
# *bare* `#` to a compile-time literal (B's own known declared width,
# 16) whenever it's not part of a larger arithmetic expression, unlike
# 160-REFORMAT.hal's still-deferred `#-DECIMALS` case. Output
# independently hand-verified: I=5 (positive, odd) -> "ODD" only;
# I=-3 (negative, odd, two's-complement) -> both "NEGATIVE" and "ODD".
# Fixture: test_bit_index.hal (254-TEST2.hal verbatim).
run ./run_read_fixture.sh bit_index "5" "$(printf 'VALUE OF I WAS ODD')"
run ./run_read_fixture.sh bit_index "-3" "$(printf 'VALUE OF I WAS NEGATIVE\nVALUE OF I WAS ODD')"
# 158-STATE.hal: `WRITE(6) STATE(TRUE, 1), STATE(FALSE, 1);` (`STATE` a
# same-unit `FUNCTION(B, TYPE) CHARACTER(5)`, `B` declared `BOOLEAN` --
# a synonym for `BIT(1)`) failed with "BTRU: operand is not BIT" inside
# STATE's own `IF B THEN`. Root cause, unrelated to any DSUB subscript
# this time: `bind_call_argument()`'s own non-container parameter-
# binding path only ever distinguished SCALAR vs. "everything else
# defaults to INTEGER" -- silently mis-binding a BIT/BOOLEAN argument
# (and, it turns out, a CHARACTER one too) as INTEGER, reading a field
# (`.integer`) a BIT-kind captured item never actually populates. Fixed
# by adding the missing is_string/is_bits cases, mirroring store_
# resolved_to_vac's own already-established kind-preserving convention.
# Fixing *that* surfaced a second, independent bug once execution got
# further: a same-unit FUNCTION's own CHARACTER RETURN value
# (`RETURN YES$(TYPE:);`, YES a local, AUTOMATIC `ARRAY(4)
# CHARACTER(5)`) was captured by *borrowing* resolve_operand's own
# pointer into YES's own char_elements storage rather than copying it --
# harmless for a single call, but a genuine use-after-free (confirmed
# via ASan) once a *second* call to the same FUNCTION appears in the
# same WRITE statement's own argument list: HAL/S locals are AUTOMATIC
# (re-initialized fresh on every call) by default, and a same-unit call
# shares SYT storage with its caller, so the second call's own
# re-initialization of YES frees the exact string the first call's
# result was still pointing at, before flush_write ever gets to read
# either one. Fixed by having store_resolved_to_vac() dup_string() a
# RV_STRING return value instead of borrowing it -- every one of that
# function's 3 call sites is a RETURN-value capture, so this can't
# regress anything that was relying on the borrow. Output independently
# hand-verified against all 4 WRITE statements' own worked YES/NO
# array values. Fixture: test_state_boolean.hal (158-STATE.hal verbatim).
run ./run_local_fixture.sh state_boolean "$(printf 'TRUE     FALSE\nON     OFF\nOPEN     SHUT\nVALID     ERROR')"

# Corpus sweep: 250-BITS.hal, `B$(1) = ON;` (`B` a plain BIT(8)) used as an
# assignment target -- OP_DSUB's single-index BIT-string subscript branch
# (added earlier for 254-TEST2.hal's read-only `IF B$(1) THEN ...;`) used
# to eagerly resolve to a plain `is_bits` VAC value at DSUB-execution
# time, correct for a read but not usable as BASN's own receiver operand:
# write_destination's QUAL_VAC case only recognizes is_ref (ARRAY/MATRIX
# element) and is_subbit_ref (SUBBIT(x)=...;), so this fell into the
# generic "assignment destination is not a subscript reference" fallback.
# Fixed by making this DSUB shape (and the sibling `B$(width AT
# position)` at-partition shape, on general principle -- same mechanism,
# no corpus program yet exercises it as a write target but there's no
# reason it wouldn't work) deferred: state.h's new is_bitpart_ref VAC
# slot kind stores (target_syt, position, width) instead of a resolved
# value, so the same slot now works as either a read (resolve_operand's
# QUAL_VAC case) or a write-through (write_destination's QUAL_VAC case,
# merging the assigned bit into the target's current raw pattern via the
# same MSB-first shift-and-mask this file's read-side extraction already
# uses, preserving every other bit). Fixture: test_bit_index_assign.hal
# (250-BITS.hal verbatim, but the real corpus file's own `DO WHILE ON;`
# outer loop is genuinely infinite -- an illustrative textbook snippet,
# not meant to run to completion standalone, same class as
# 265-ENQUEUE.hal/269-STALL.hal -- so it's bounded to a single pass here,
# plus a WRITE(6) B; added). Only C1/C2/C8's IF blocks are literally
# present in the compilable source (the book elides C3-C7 with "..."
# comments), so B's expected final value has just bits 1, 2, and 8 set:
# BIN'11000001', independently hand-verified.
run ./run_local_fixture.sh bit_index_assign "1100 0001"

# Corpus sweep: 112-EXAMPLE_6.hal, `ATT_RATE(DEVICE,*) = GYRO_INPUT
# (DEVICE,*) * SCALE + BIAS;` (`ATT_RATE`/`GYRO_INPUT` both ARRAY(4,3),
# `SCALE` a plain ARRAY(3) SCALAR) -- a plain SASN (not MASN/VASN) whose
# receiver is a DSUB row-partition select (`$(DEVICE,*)`, state.h's
# is_container_ref), replayed once per row-element by an ADLP/DLPE wrap
# (HALSFC's own documented workaround for ARRAY having no dedicated
# whole-container assign opcode the way VECTOR/MATRIX get VASN/MASN).
# write_destination's QUAL_VAC case only ever consulted is_container_ref
# from inside OP_MASN/OP_VASN's own dedicated (whole-container-at-once)
# handling -- an ordinary SASN's receiver operand fell into the generic
# "assignment destination is not a subscript reference" fallback, since
# nothing else recognized is_container_ref at all. Fixed by adding a
# parallel is_container_ref case to write_destination itself, writing
# just the *current* replay iteration's one element (container_ref_offset
# + arrayed_index * container_ref_stride) via the existing
# write_container_element() helper -- the exact write-side mirror of
# resolve_operand's own is_container per-element replay-read case.
# Fixture: test_row_container_write.hal (112-EXAMPLE_6.hal verbatim,
# already has its own WRITE loop). Output independently hand-verified:
# row i = GYRO_INPUT row i (INTEGER) elementwise * SCALE (.013,.026,.013)
# + BIAS (57.296).
run ./run_local_fixture.sh row_container_write "$(printf ' 5.7308975E+01      5.7347977E+01      5.7334976E+01\n 5.7347977E+01      5.7425980E+01      5.7373978E+01\n 5.7386978E+01      5.7503983E+01      5.7412979E+01\n 5.7425980E+01      5.7581985E+01      5.7451981E+01')"

# Corpus sweep: 242-P.hal, `WAIT FOR DONE;`/`WAIT FOR DO_SOMETHING;` (both
# a bare EVENT symbol) -- a WAIT form documented separately in USA003087
# Sec. 24.6 ("Event Expressions in WAIT Statement": "causes a process to
# remain in a waiting state until some event expression becomes TRUE"),
# distinct from the three WAIT forms (interval/UNTIL/FOR DEPENDENT,
# Sec. 13.5) already implemented -- OP_WAIT's own operand-shape check
# rejected this fourth form's tag=3/one-SYT-operand encoding outright,
# "WAIT: expected 1 operand (interval or UNTIL form) or 0 (FOR
# DEPENDENT)". Fixed by adding a tag==3 case that reuses SCHD's own
# `ON <bit exp>` mechanism (TASK_WAITING_ON/sched_wake_on_events,
# has_on_event/on_event_syt) verbatim -- entered from a currently-running
# task instead of at SCHD-creation time, but the same re-check-every-tick
# "become READY once this plain EVENT SYT's bit_value is nonzero" logic
# applies unchanged. Only the plain-SYT-operand case is implemented (same
# scope as SCHD's own ON clause; compound BAND/BOR event expressions are
# task #47's still-deferred gap, not independently reinvestigated here).
# Fixture: test_wait_for_event.hal (242-P.hal verbatim, plus two added
# WRITE statements to make the SIGNAL/WAIT FOR/SET interaction
# independently checkable) -- output confirms the correct order (T's own
# WAIT FOR DO_SOMETHING unblocks from the primal's SIGNAL, then T's own
# SET DONE unblocks the primal's WAIT FOR DONE).
run ./run_local_fixture.sh wait_for_event "$(printf 'T RAN\nMAIN RESUMED')"

# Corpus sweep: 167-ASSORTEDIO.hal, `DECLARE FWDSENSORS IOPARM-STRUCTURE
# INITIAL(16, HEX'0', NULL, 27);` (`BUFFER NAME ARRAY(10) INTEGER` is the
# 3rd of 4 terminals) -- TINT's own coalesced-run mechanism only ever
# handled a QUAL_LIT second operand (a run of literal-table entries);
# NULL has no litfile entry to coalesce against (NASN/NINT's own
# confirmed "NULL is QUAL=IMD" encoding, reused here by the compiler),
# so it always breaks the coalescing and gets its own standalone TINT
# instruction with a bare QUAL_IMD operand instead -- previously hit the
# blanket "TINT: expected a LIT second operand" fallback. Fixed by adding
# a QUAL_IMD case that writes SYT_TYPE_NAME/HALMAT_NAME_NULL directly
# into the one affected terminal's shadow field slot, bypassing the
# run/litfile machinery entirely (a NULL terminal is always exactly one
# terminal, no run-count concept applies). Fixture:
# test_tint_null_terminal.hal (167-ASSORTEDIO.hal's structure/INITIAL
# construct in isolation -- the real corpus file also uses a %SVC macro
# invocation later, deliberately out of this interpreter's scope, so
# can't be used verbatim). Output confirms the numeric/BIT terminals
# coalesced on either side of the NULL terminal (DEVICE=16, STATUS=
# HEX'0', WORDS=27) all came through correctly despite the run-breaking
# NULL terminal between them.
#
# STATUS's field updated from 32 to 16 bits (0000 0000 0000 0000, not
# ...0000 0000 0000 0000 0000 0000 0000): a WRITE argument that's a
# QUAL_XPT structure-field reference (interp.c's WRITE-argument bit_width
# lookup) previously fell through to the bare 32-bit default instead of
# looking up STATUS's own declared BIT(16) width via the resolving EXTN's
# struct_field_syt -- problems-yaHALMAT2.md item 4, confirmed against
# real gpc output.
run ./run_local_fixture.sh tint_null_terminal "         16     0000 0000 0000 0000              27"

# Corpus sweep: 180-EXAMPLE_N.hal/184-EXAMPLE_N.hal, `V.STATUS$(N)`/
# `V.TIMETAG$(N)` (V a Q-STRUCTURE(3), N a plain loop-counter INTEGER --
# a structure-copy select with a *variable*, not literal, copy index).
# TSUB's own operand-shape check only ever accepted QUAL_IMD (a literal
# copy number); the variable form's real compiled shape (confirmed
# against this file's own HALMAT) is a plain QUAL_SYT operand referencing
# the variable directly (tag1=0x09, distinct from the literal form's own
# tag1) -- previously hit "TSUB: only a literal copy index is
# implemented". Fixed by resolving a QUAL_SYT second operand the same way
# any other integer-valued SYT read would be. (The corpus files
# themselves can't be used as fixtures verbatim -- every PROCEDURE they
# CALL through this construct has an elided "..." placeholder body, no
# real executable content, the same illustrative-textbook-snippet pattern
# as 265-ENQUEUE.hal/269-STALL.hal; the actual CALL...ASSIGN() write-back
# additionally hits a separate, deeper whole-STRUCTURE-copy-receiver gap
# related to task #23's own deferred TASN/structure-terminal-array
# limitation, not investigated further here.) Fixture:
# test_tsub_variable_index.hal, a minimal REC-STRUCTURE(3) isolating just
# the variable-copy-index read/write, independently verified (Q.X$(N) =
# 10+N for N=1,2,3 -> 11,12,13).
run ./run_local_fixture.sh tsub_variable_index "$(printf '         11\n         12\n         13')"

# Task #47: compound event-expressions in SCHEDULE ON/WHILE-UNTIL and
# WAIT FOR (239-STARTUP.hal's `SCHEDULE FREEFALL ON (ORBIT & (ORBIT2 &
# ORBIT3)))`/`SCHEDULE FREEFALL2 ON (ORBIT | (ORBIT2 | ORBIT3))`,
# 238-P.hal's `REPEAT EVERY 1/6 UNTIL ORBIT AND ENGINE_OFF`) -- a
# BAND/BOR/BNOT event-expression chain, USA003087 Sec. 24.6's "the value
# of exp becomes TRUE... evaluations of EV1&EV2 by the RTE": this needs
# LIVE re-evaluation of the underlying EVENT symbols every tick, not a
# one-time captured snapshot, since the whole point is waiting for them
# to change *after* the SCHEDULE/WAIT statement itself already executed.
# SCHD's ON/WHILE/UNTIL clauses and WAIT's own FOR form previously only
# accepted a plain SYT EVENT operand. Fixed with a new
# reevaluate_live_bit_operand() helper (interp.c): a QUAL_SYT operand
# reads state->syt[...].bit_value directly (always live); a QUAL_VAC
# operand looks up the *original* producing BAND/BOR/BNOT instruction by
# its own HALMAT word position (binary search over state->prog->instrs[],
# since a QUAL_VAC operand's `data` is the raw word index, not that
# instruction's logical array position -- they diverge after the first
# multi-operand instruction) and recursively re-evaluates its own
# operands the same way. halmat_task_t's on_event_syt/stop_event_syt
# (uint16_t, plain-SYT-only) generalized to on_event_op/stop_event_op
# (halmat_operand_t, either shape). Same mechanism covers all three call
# sites (SCHD's ON, SCHD's STOPPING WHILE/UNTIL, WAIT's FOR) since they
# all previously used the identical plain-SYT-only pattern. Fixtures:
# test_sched_on_compound.hal (BAND -- WORKER starts only once E1,E2,E3
# ALL true, output order independently confirms it waits for the third
# SIGNAL, not the first), test_sched_on_compound_or.hal (BOR -- WORKER
# starts on the FIRST signaled event, not needing all three),
# test_sched_until_compound.hal (BAND as a STOPPING clause -- a REPEAT
# EVERY cyclic task keeps rearming while false, stops once true: exactly
# 2 cycles, not more), test_wait_for_compound.hal (WAIT FOR with BAND).
run ./run_local_fixture.sh sched_on_compound "$(printf 'BEFORE ANY SIGNAL\nAFTER E1\nAFTER E2\nWORKER STARTED\nAFTER E3')" --time-scale 1000000
run ./run_local_fixture.sh sched_on_compound_or "$(printf 'BEFORE ANY SIGNAL\nWORKER STARTED\nAFTER E2')" --time-scale 1000000
run ./run_local_fixture.sh sched_until_compound "$(printf 'CYCLE               1\nCYCLE               2\nDONE, N=               2')"
run ./run_local_fixture.sh wait_for_compound "$(printf 'SETTER: E1 SIGNALED\nSETTER: E2 SIGNALED\nPRIMAL RESUMED')"

# Task #35: 193-TEST_X.hal, `ON ERROR$(IO:5) GO TO DONE;` guarding a
# `DO WHILE TRUE; READ(5) INPUT, EXPECTED; ...; END;` loop meant to run
# until input is exhausted -- READ's own end-of-file case previously
# always aborted via fail() regardless of any registered ON ERROR
# handler. Group 10 member 5 ("the end of file error") is confirmed
# directly against source-documentation/ProgrammingInHALS.txt's own
# Sec. 10 discussion of this *exact* example (not guessed, and not
# derivable from USA003090's Appendix C, which covers only group-4
# arithmetic errors) -- doubly confirmed by the real compiled HALMAT
# showing exactly one ERON with group=10/member=5 (the corpus file's own
# apparently-duplicate bare `ON ERROR GO TO DONE;` line immediately
# above it is a transcription artifact; the real book page and the
# compiled output both show only the one specific registration). Fixed
# via a new io_error_redirect_on_eof() helper (interp.c), mirroring
# arithmetic_error_should_apply_fixup()'s established find_error_handler
# GOTO-redirect pattern, wired into all 4 of READ's own end-of-input
# fail() sites. Fixture: test_read_eof_onerror.hal (193-TEST_X.hal
# verbatim -- X's own body is elided ("...") in the real book too, so it
# never sets OUTPUT, always leaving it at 0; fed 3 pairs where EXPECTED
# is never 0, independently verified as 0 correct/3 incorrect once the
# loop correctly exhausts input and redirects to DONE).
run ./run_read_fixture.sh read_eof_onerror "$(printf '1 1\n2 3\n4 4\n')" "$(printf 'RESULTS OF TESTING X\n          0      SAMPLES CORRECT,                3      SAMPLES INCORRECT')"
# 194-TEST_X.hal -- the same page-193 example rewritten (per the book's
# own text) to use `ON ERROR ... DO; ...; RETURN; END;` instead of GO TO.
# RETURN reached with no active call frame, no inline-FUNCTION, and not
# an external-call target (i.e. as an ON-ERROR-triggered inline action
# body's own terminator) previously failed loudly ("RTRN with no active
# call") instead of ending the process -- cross-project-tracked as
# return_from_on_error_do_hangs. Fixed by extracting OP_CLOS's own
# process/task-closing logic into a shared close_current_process()
# helper and reaching it from this OP_RTRN branch too, since
# class-0/RTRN.md's "every subprogram body is terminated regardless"
# note makes no real distinction between an explicit top-level RETURN
# and naturally falling through to CLOS. Fixture: test_return_on_error.hal.
run ./run_read_fixture.sh return_on_error "$(printf '1 1\n2 3\n4 4\n')" "$(printf 'TEST RESULTS FOLLOW\n          0               3')"

# Task #38: 172-OUTER.hal, `READ(5) ARG;` (ARG a UTIL_PARM-STRUCTURE with
# fields `V VECTOR, S1 SCALAR, C INTEGER, S2 SCALAR, E BOOLEAN`) -- a
# whole (bare/unqualified) STRUCTURE READ destination (HALMAT class 10),
# previously "READ: only CHARACTER/SCALAR/INTEGER arguments are
# implemented". USA003087 Sec. 12.3 governs the field order/count the
# same way it does for a whole VECTOR/MATRIX destination (one field per
# terminal, in declaration order; a VECTOR terminal contributes one
# field per component) -- OP_READ now walks the terminals via a new
# symtab.h struct_first_field/struct_next_field linked list (parsed from
# the raw SYM_LINK1/SYM_LINK2 symbol-table fields, confirmed empirically
# against two different real structure templates' own COMMON0.out dumps:
# the template's SYM_LINK1 points to its first field, each field's own
# SYM_LINK2 to the next, terminating in a raw value that's negative when
# reinterpreted as int16_t) and writes each terminal directly into its
# own shadow field slot (find_or_create_struct_field) -- bypassing
# write_destination, since HALSFC's compiled output for a whole-
# structure I/O argument never spells out per-terminal operands the way
# TINT's own OFFSET-driven INITIAL() does. The VECTOR terminal's own
# elements[]/cols allocation on first touch is new ground: no code path
# had ever written array-shaped data into a structure-terminal shadow
# slot before (TASN's own comment flags this as a previously-unreachable
# gap). Fixture: test_read_structure.hal (172-OUTER.hal's own
# STRUCTURE/DECLARE plus a minimal READ+WRITE, isolated since the real
# corpus file's own remaining statements need whole-structure CALL-
# argument passing and structure-terminal VECTOR RETURN/WRITE display --
# separate, still-unimplemented gaps, not attempted here). Verifies S1/
# C/S2/E all land on the correct values immediately after V's own 3
# components, proving those were correctly consumed even though direct
# display of a VECTOR-shaped structure field is a separate, pre-existing
# gap (resolve_operand's QUAL_XPT case has no elements[]-shaped read
# path yet, only ever reads the scalar union member) not exercised here.
# E's field updated from 32 bits (0000...0001) to 1 bit ("1"): the same
# QUAL_XPT structure-field bit_width lookup fix as problems-yaHALMAT2.md
# item 4 (test_tint_null_terminal.hal's STATUS field) also applies here --
# E is declared BOOLEAN (BIT(1)), and WRITE now looks up its real
# declared width via the resolving EXTN's struct_field_syt instead of
# falling through to the 32-bit default. Confirmed against real gpc
# output for this exact fixture's own input.
run ./run_read_fixture.sh read_structure "$(printf '1 2 3 10.5 7 20.5 1\n')" " 1.0500000E+01               7      2.0500000E+01     1"

# Task #62 (yahalmat2_structure_read_write_all_zero): 172-OUTER.hal
# verbatim (not the isolated subset above), exercising the three gaps
# read_structure's own comment flagged as separate and unattempted: (1)
# WRITE of a whole structure that contains a VECTOR terminal (previously
# printed all zeros -- flush_write's is_structure branch now walks
# struct_first_field/struct_next_field and formats each terminal by its
# real hal_class, VECTOR emitting one field per component); (2) passing
# a whole (bare/unqualified) structure as a FUNCTION argument by value
# (UTIL(ARG) -- OP_XXAR gained an is_structure capture case keyed off
# TAG1=10/QUAL_XPT with the EXTN target's own hal_class==0x3E "TEMPLATE
# DEFINITION" marker distinguishing a whole-structure reference from a
# qualified single-field one; bind_call_argument gained a matching
# deep-copy case, walking the same terminal list into the callee's own
# fresh copy-index-0 shadow slots); (3) RETURNing a structure's VECTOR
# terminal (RETURN X.V -- OP_RTRN's whole-container-return detection
# gained a QUAL_XPT case resolving through the VAC slot's struct_field_syt
# to confirm the target field is itself hal_class==4/VECTOR before
# treating it as a whole-container return). All 10 loop iterations
# verified digit-by-digit against the fed input: WRITE(6) echoes ARG's
# 7 fields (V's 3 components, S1, C, S2, E) exactly as read, and
# UTIL(ARG) returns exactly ARG.V. No real-gpc cross-check was obtained
# for this exact fixture (gpc's own interactive run of this file did not
# complete within a practical wait even on a second attempt, apparently
# genuine cycle-accurate-simulation slowness rather than a hang); this
# was verified against yaHALMAT2's own before/after behavior and the
# language-spec-level terminal-ordering rule task #38's own fixture
# already confirmed against real gpc (USA003087 Sec. 12.3).
run ./run_read_fixture.sh outer_struct "$(printf '1 2 3 10.5 7 20.5 1\n2 3 4 11.5 8 21.5 1\n3 4 5 12.5 9 22.5 1\n4 5 6 13.5 10 23.5 1\n5 6 7 14.5 11 24.5 1\n6 7 8 15.5 12 25.5 1\n7 8 9 16.5 13 26.5 1\n8 9 10 17.5 14 27.5 1\n9 10 11 18.5 15 28.5 1\n10 11 12 19.5 16 29.5 1\n')" "$(printf 'UTIL OF      1.0000000E+00      2.0000000E+00      3.0000000E+00      1.0500000E+01               7      2.0500000E+01     1     =\n 1.0000000E+00      2.0000000E+00      3.0000000E+00\nUTIL OF      2.0000000E+00      3.0000000E+00      4.0000000E+00      1.1500000E+01               8      2.1500000E+01     1     =\n 2.0000000E+00      3.0000000E+00      4.0000000E+00\nUTIL OF      3.0000000E+00      4.0000000E+00      5.0000000E+00      1.2500000E+01               9      2.2500000E+01     1     =\n 3.0000000E+00      4.0000000E+00      5.0000000E+00\nUTIL OF      4.0000000E+00      5.0000000E+00      6.0000000E+00      1.3500000E+01              10      2.3500000E+01     1     =\n 4.0000000E+00      5.0000000E+00      6.0000000E+00\nUTIL OF      5.0000000E+00      6.0000000E+00      7.0000000E+00      1.4500000E+01              11      2.4500000E+01     1     =\n 5.0000000E+00      6.0000000E+00      7.0000000E+00\nUTIL OF      6.0000000E+00      7.0000000E+00      8.0000000E+00      1.5500000E+01              12      2.5500000E+01     1     =\n 6.0000000E+00      7.0000000E+00      8.0000000E+00\nUTIL OF      7.0000000E+00      8.0000000E+00      9.0000000E+00      1.6500000E+01              13      2.6500000E+01     1     =\n 7.0000000E+00      8.0000000E+00      9.0000000E+00\nUTIL OF      8.0000000E+00      9.0000000E+00      1.0000000E+01      1.7500000E+01              14      2.7500000E+01     1     =\n 8.0000000E+00      9.0000000E+00      1.0000000E+01\nUTIL OF      9.0000000E+00      1.0000000E+01      1.1000000E+01      1.8500000E+01              15      2.8500000E+01     1     =\n 9.0000000E+00      1.0000000E+01      1.1000000E+01\nUTIL OF      1.0000000E+01      1.1000000E+01      1.2000000E+01      1.9500000E+01              16      2.9500000E+01     1     =\n 1.0000000E+01      1.1000000E+01      1.2000000E+01')"

# Task #70 (yahalmat2_structure_param_vector_return): 170-OUTER.hal,
# `DECLARE LOCAL UTIL_PARM-STRUCTURE INITIAL(0, 1, 0, 0, 83, 0, OFF);`
# (V's 3 VECTOR components + S1, C, S2, E) followed by `RESULT =
# UTIL(LOCAL);` (UTIL(X) VECTOR; ... RETURN X.V;). Previously aborted
# ("operand is not a MATRIX/VECTOR intermediate result") before task
# #62's RETURN/CALL-argument fix landed; once that crash was fixed, a
# second, distinct bug surfaced: RESULT printed as all-zero instead of
# LOCAL's own INITIAL value (0,1,0). Root cause: OP_TINT (class-8/
# TINT.md's whole-structure INITIAL() mechanism) mapped each coalesced
# literal to a structure terminal via a flat `template_syt + 1 + offset
# + k` formula -- one literal always advanced exactly one terminal. That
# formula silently breaks the moment a VECTOR terminal appears earlier
# in the template: V alone consumes 3 of the run's 7 coalesced literals
# (per real HALMAT, one TINT with OFFSET=0, run-count=7 -- V's 3 slots
# plus S1/C/S2/E), but the old formula treated all 7 as one-terminal-
# each, writing V's own single scalar union member 3 times (each
# overwriting the last, ending at 0.0 since V is otherwise never
# assigned in this file) and shifting every later value onto the wrong
# terminal entirely (S1 would receive V's 2nd component, etc.) -- masked
# in task #62's own read_structure/outer_struct fixtures since those
# populate every field explicitly via READ, never relying on TINT's
# INITIAL() path. Fixed via a new tint_locate_slot() helper (interp.c)
# that walks struct_first_field/struct_next_field summing each
# terminal's own slot width (`cols` for a VECTOR terminal, 1 otherwise)
# to map a flattened OFFSET slot index back to (terminal, element
# index), allocating the VECTOR terminal's own elements[] on first touch
# exactly like the READ-side whole-structure destination does. The
# "copiness" (`Q-STRUCTURE(n)`) coalesced-run case is unaffected (kept
# on its original single-terminal formula -- never observed combined
# with a VECTOR terminal). Confirmed against real gpc: RESULT= 0.0 1.0
# 0.0 (this fixture's own hand-computed value, matching the DB issue's
# recorded gpc ground truth for this exact file).
run ./run_local_fixture.sh outer170_vecinit "$(printf 'RESULT=\n 0.0                1.0000000E+00      0.0          ')"

# Task #23: TASN (whole-structure assign, `DST = SRC;`) copying an
# ARRAY/MATRIX/VECTOR structure terminal -- previously failed loudly as
# unreachable ("no HALSFC-compilable program can get non-zero
# per-element data into a structure-terminal array field... for TASN to
# ever copy"), aborting the ENTIRE copy the moment it reached the first
# such terminal (UTIL_PARM's own V VECTOR is declared *first*, so no
# other field ever got copied either). Task #38's whole-structure READ
# is the first mechanism that populates exactly this, unblocking the
# deep copy TASN's own comment had already described as "mechanically
# straightforward": same numeric/BIT/CHARACTER three-way storage-kind
# dispatch used elsewhere (e.g. write_container_element), malloc+memcpy
# (or dup_string per element for CHARACTER) instead of the plain-scalar
# path's `*dst_field = src_snapshot`, which would alias the two
# entries' elements/bit_elements/char_elements pointers together instead
# of copying -- confirmed via a dedicated ASan+UBSan build (zero errors)
# given the manual malloc/free bookkeeping involved. Fixture:
# test_tasn_array_terminal.hal -- READ populates SRC (including its own
# VECTOR terminal), `DST = SRC;` copies it, a second READ overwrites
# SRC's own fields, and DST's scalar/integer/BOOLEAN terminals still
# holding the *first* READ's values proves TASN performed a genuine
# independent copy (not an aliased reference) despite the leading VECTOR
# terminal that used to abort the whole operation.
# E's field updated from 32 bits to 1 bit -- same QUAL_XPT structure-
# field bit_width fix as read_structure above (E is BOOLEAN = BIT(1)).
run ./run_read_fixture.sh tasn_array_terminal "$(printf '1 2 3 10.5 7 20.5 1\n99 98 97 999.9 88 888.8 0\n')" " 1.0500000E+01               7      2.0500000E+01     1"

# Task #27: CSZ (`#`-relative CHARACTER to-partition subscript,
# 160-REFORMAT.hal's `C(1 TO #-DECIMALS)`/`C(#-DECIMALS-1 TO #)`) --
# resolved via a real (not synthetic) copy of the primary source. DATA=0
# is a bare `#`; DATA=2 is `# - subsidiary` (a second operand word
# immediately following) -- confirmed by a controlled compile in
# DSUB.md, and separately re-confirmed letter-for-letter identical
# against *both* the 1st (NASA-CR-151872, Sept. 1978) and 2nd editions
# of "Programming in HAL/S", ruling out an OCR scanning artifact in
# either copy. A related, separate gap surfaced once CSZ resolution
# actually ran real code: `ZEROS(1 TO DECIMALS-LENGTH(C))` (ZEROS a
# CHARACTER CONSTANT) uses a QUAL_LIT base operand, not QUAL_SYT --
# a compile-time CONSTANT never gets its own SYT storage -- so DSUB
# gained a narrow QUAL_LIT-base case for exactly this to-partition
# shape. Fixture: test_reformat_csz.hal (160-REFORMAT.hal verbatim, all
# 3 of its own real WRITE(6) REFORMAT(...) calls, not the textbook's own
# different SQRT(2) example) -- every output independently hand-derived
# and verified digit-by-digit (REFORMAT(3.14159,2,10) -> `C="314"`,
# `#-DECIMALS=1` -> "3", `#-DECIMALS-1=0` clamped to 1 -> "314", giving
# "3.314"; REFORMAT(-42.5,1,10) -> "-42.425"; REFORMAT(0.007,3,10) ->
# C padded to "007" -> ".007", each then RJUST-padded to WIDTH=10).
run ./run_local_fixture.sh reformat_csz "$(printf '     3.314\n   -42.425\n      .007')"

# User-reported (investigating whether NINT/MINT/VINT relate to VECTOR
# slice assignment turned up a genuine, separate bug instead): `V(4 TO
# 7) = SUBV;` (V a VECTOR(10), SUBV a VECTOR(4)) -- a VECTOR to-partition
# subscript used as an assignment receiver. DSUB's own to-partition
# branch only ever produced a *readable* VAC container result; nothing
# marked it is_container_ref the way the sibling asterisk-partition case
# (`M$(I,*) = ...;`) already does, so MASN/VASN's own receiver check
# rejected it outright ("MASN/VASN: receiver must be SYT"). Fixed by
# adding the same is_container_ref/container_ref_syt/offset/stride
# marking the asterisk-partition branch already sets, scoped to the
# single-dimension VECTOR/ARRAY case only (matching the sibling
# at-partition branch's own scope; MATRIX to-partition isn't handled).
# Confirmed via a direct HALSFC compile that a plain SCALAR RHS
# (`V(4 TO 7) = 5.0;`) is illegal HAL/S in the first place ("TYPE OF V
# IS ILLEGAL FOR ASSIGNMENT FROM GIVEN RIGHT-HAND SIDE"), so this DSUB
# shape is only ever reached with a genuine VECTOR-shaped source.
# Fixture: test_vector_to_partition_write.hal -- output confirms V's
# untouched positions (1-3, 8-10) stay 0.0 while exactly positions 4-7
# become 5.0.
run ./run_local_fixture.sh vector_to_partition_write "$(printf ' 0.0                0.0                0.0                5.0000000E+00      5.0000000E+00      5.0000000E+00      5.0000000E+00\n 0.0                0.0                0.0          ')"

# Task #63 (function_result_scalar_integer_confusion): 127-LIMIT.hal /
# 211-LIMIT.hal, `LIMIT(VALUE, BOUND) SCALAR; ... RETURN BOUND;`/
# `RETURN VALUE;`/`RETURN -BOUND;` -- a SCALAR-returning same-unit
# FUNCTION called with whole-number-valued arguments (`LIMIT(52, 100)`,
# `LIMIT(5.0, 10.0)`) printed 3 of its 4 results INTEGER-style ("52",
# "100") instead of SCALAR-style (" 5.2000000E+01") -- oddly, only the
# `RETURN -BOUND;` branch (a *computed* SCALAR-negation expression, not
# a bare parameter) came out correctly. Root cause: bind_call_argument
# (interp.c) bound each parameter purely from the caller-side XXAR
# item's own already-classified kind (is_scalar/is_string/is_bits/else-
# INTEGER), which for a whole-number-valued argument had already been
# reclassified INTEGER by OP_XXAR's own `integer_class_scalar` check
# (`ins->operands[0].tag1 == 6`) -- correct for a WRITE argument's own
# TAG1 (which genuinely describes how to *format* the printed
# expression), but the wrong signal for a CALL argument: confirmed
# empirically that `LIMIT(5.0, 10.0)` (whole-number-valued) compiles its
# XXAR operands TAG1=6/INTEGER while the otherwise-identical `LIMIT(5.5,
# 10.25)` (fractional) compiles TAG1=5/SCALAR for the exact same
# SCALAR-declared VALUE/BOUND parameters -- i.e. TAG1 here tracks the
# *literal's own value*, not VALUE/BOUND's declared type. So VALUE/
# BOUND ended up `SYT_TYPE_INTEGER` despite their own `DECLARE SCALAR`,
# and a bare-parameter `RETURN BOUND;`/`RETURN VALUE;` read that back
# directly; `RETURN -BOUND;` worked only because SCALAR negation always
# produces an `RV_SCALAR` VAC result regardless of its operand's stored
# kind. Fixed by consulting the callee's own declared parameter type
# (dest_state->symtab, mirroring the container-argument branch's
# existing `psym`-driven precision coercion a few lines above) and
# cross-coercing SCALAR<->INTEGER by that declared type instead of the
# caller-side classification. Confirmed against real gpc for both files
# (fast, non-interactive -- no READ/stdin involved): 127-LIMIT.hal gives
# " 5.2000000E+01 / -5.2000000E+01 / 1.0000000E+02 / -1.0000000E+02",
# 211-LIMIT.hal gives "LIMIT(5,10)=      5.0000000E+00" etc., both
# matching yaHALMAT2's own fixed output exactly.
run ./run_local_fixture.sh limit127 "$(printf ' 5.2000000E+01\n-5.2000000E+01\n 1.0000000E+02\n-1.0000000E+02')"
run ./run_local_fixture.sh limit211 "$(printf 'LIMIT(5,10)=      5.0000000E+00\nLIMIT(15,10)=      1.0000000E+01\nLIMIT(-15,10)=     -1.0000000E+01\nLIMIT(0,1)=      0.0          ')"

# Task #64 (partition_array_shift_wrong): 138-FILTER.hal, a 4-element
# sliding-window shift register (`[BUFF] 1 TO 3 = [BUFF] 2 TO 4; BUFF(4)
# = INPUT;`, BUFF an ARRAY(4) SCALAR) run over inputs 10,20,30,40,50,60
# -- correct for the first two averages (2.5, 7.5) then wrong from the
# third onward (12.5 instead of 15, etc.). Two independent, compounding
# bugs found investigating this, both in interp.c:
#  (1) precompute_arrayed_paragraphs's backward dependency walk (the
#      ADLP/DLPE "trailing metadata" case) only ever examined the
#      operands of the instruction *currently at* its own `start`
#      candidate, re-pointing `cur` to whichever single QUAL_VAC
#      producer it found first and abandoning the rest of that scan via
#      `break` -- correct for a linear one-dependency chain (`A3 = A1 +
#      A2;`'s SASN<-SADD case, already covered by an existing fixture),
#      but this SASN has TWO independent QUAL_VAC operands (the
#      to-partition DSUB results for both its receiver `[BUFF] 1 TO 3`
#      and its source `[BUFF] 2 TO 4`, neither depending on the other):
#      once `start` moved to chase the source DSUB (this project's own
#      "source-first" SASN operand convention), the receiver DSUB's own
#      dependency was never revisited, leaving it entirely OUTSIDE the
#      replayed paragraph -- confirmed via direct instrumentation, it
#      resolved exactly once with arrayed_index still -1 while the
#      source DSUB correctly replayed 3 times. Fixed by re-scanning
#      every instruction currently within [start, i-1] each pass (a
#      proper fixed-point walk) instead of only the instruction at
#      `start` itself.
#  (2) Even with (1) fixed, DSUB itself (OP_DSUB) had no case at all for
#      a numeric ARRAY's to-partition "start TO end" bounds resolved
#      per-element via an enclosing ADLP replay -- confirmed empirically
#      that (unlike the VECTOR to-partition case, gated on TAG1==2) a
#      numeric ARRAY to-partition compiles as an ordinary 2-operand DSUB
#      with no special TAG1 marking, relying entirely on the surrounding
#      ADLP(count)/DLPE wrapping to signal "one element per iteration."
#      A 1-D ARRAY (base->rows==0) has no second dimension for 2
#      operands to legitimately index, so this shape fell through to
#      the generic multi-dimension "placeholder stride" fallback, which
#      misread (start,end) as (dim0_index,dim1_index) and computed one
#      FIXED offset (base-16 placeholder stride) identical on every
#      replay iteration -- e.g. always resolving to BUFF(3)=BUFF(4),
#      three times over, instead of the 3 different element pairs the
#      shift needs. Fixed by adding a dedicated branch resolving to
#      element `start + arrayed_index`, the same writable single-element
#      `is_ref` mechanism the ordinary single-index case already uses.
# Confirmed against real gpc: exact match, all 6 averages correct
# (2.5, 7.5, 15, 25, 35, 45). Fixture: test_filter138.hal.
run ./run_local_fixture.sh filter138 "$(printf 'IN=      1.0000000E+01     AVG=      2.5000000E+00\nIN=      2.0000000E+01     AVG=      7.5000000E+00\nIN=      3.0000000E+01     AVG=      1.5000000E+01\nIN=      4.0000000E+01     AVG=      2.5000000E+01\nIN=      5.0000000E+01     AVG=      3.5000000E+01\nIN=      6.0000000E+01     AVG=      4.5000000E+01')"

# Task #65 (radix_qualified_character_bit_ignored): 255-TEST3.hal,
# `WRITE(6) CHARACTER(B) @HEX/@DEC/@OCT/@BIN;` (B a BIT(8) holding
# decimal 25, 00011001) -- all four radix-qualified conversions
# previously gave the IDENTICAL plain bit-string "00011001", since
# OP_BTOC (interp.c) never consulted its own operator-word TAG at all,
# always falling back to the same unqualified-simple-form behavior
# (already correctly fixed separately, class-2/BTOC.md's own confirmed
# TAG=0 trace, `C1 = CHARACTER(B0);`, no radix qualifier). Confirmed
# empirically against this exact file's real compiled HALMAT that TAG
# carries the radix qualifier (source order @HEX/@DEC/@OCT/@BIN):
# TAG=4=@HEX, TAG=2=@DEC, TAG=3=@OCT, TAG=1=@BIN (@BIN identical to the
# TAG=0 unqualified form -- both just the raw bit string). Field width
# for each radix is the minimum digit count needed to represent every
# value the source BIT's own declared width can hold, zero-padded (no
# primary source decodes #QBTOC's exact formatting -- BTOC.md's own
# "Unresolved Questions" -- so this generalizes from the one confirmed
# real trace: HEX ceil(8/4)=2 digits "19", OCT ceil(8/3)=3 digits "031",
# DEC digit-count-of-255=3 digits "025"). Confirmed against real gpc:
# exact match, "19"/"025"/"031"/"00011001".
run ./run_local_fixture.sh test3_255 "$(printf '19\n025\n031\n00011001\n0001 1001')"

# Task #67 (yahalmat2_assign_array_struct_element): 180-EXAMPLE_N.hal/
# 184-EXAMPLE_N.hal, `CALL READ_IMU(I) ASSIGN(VEL(I));` (VEL a
# SUPER_VECTOR-STRUCTURE(3) array-of-structure) inside a `DO FOR
# TEMPORARY I=1 TO 3;` loop -- previously aborted immediately with
# "ASSIGN: whole-ARRAY receiver must be a plain SYT variable" (VEL(I)
# compiles to a TSUB(copy index)+EXTN qualified structure reference,
# not a plain SYT). Four separate, compounding bugs found chasing this
# to a complete, gpc-matching run (interp.c unless noted):
#  (1) OP_XXND's ASSIGN write-back had no case at all for a whole-
#      STRUCTURE ASSIGN parameter -- added, deep-copying each of the
#      callee's own terminals into the caller's own copy-I shadow
#      storage (mirroring bind_call_argument's own is_structure case
#      for the opposite/call-argument-in direction). Needed a NEW
#      symtab.h field, struct_template_syt (symtab.c), since a
#      structure INSTANCE symbol's own SYM_LINK1 is NOT populated the
#      way struct_first_field's doc comment assumes -- only the
#      TEMPLATE symbol itself has a real SYM_LINK1; an instance's own
#      template is instead found via its SYM_LENGTH field (confirmed
#      empirically: VEL/STRUC's own SYM_LENGTH both equal SUPER_VECTOR's
#      real SYT index).
#  (2) resolve_param_syt() (new helper): the "callee+1+i" positional
#      parameter convention (FCAL.md/PCAL.md) only holds when nothing
#      else was allocated a symbol-table slot between the callee's own
#      symbol and its first parameter -- false for a genuinely forward-
#      referenced PROCEDURE (READ_IMU is called before its own textual
#      definition, which appears last in the file); every OTHER
#      procedure forward-referenced earlier (SELECT_BEST, GUIDANCE,
#      OTHER_SW) sits in the gap instead. Fixed by consulting a real
#      PROCEDURE/FUNCTION LABEL symbol's own SYM_PTR field directly (a
#      second, distinct meaning from the unrelated IND-CALL-LABEL-alias
#      case already handled by resolve_call_target -- SYM_PTR here is
#      the procedure's own first parameter's real SYT index).
#  (3) `REPEAT;` inside a `DO FOR` loop (as opposed to `DO WHILE`/`DO
#      UNTIL`, the already-working DTST/ETST case) had no label-target
#      registration at all -- added to precompute_labels' own OP_EFOR
#      case, landing REPEAT's BRA exactly on EFOR itself (the loop's own
#      per-cycle increment/retest/branch-back entry point), not EFOR+1
#      (EXIT's own, different target, which would skip the loop
#      entirely).
#  (4) A whole `Q-STRUCTURE(n)` ARRAY passed by value with no index
#      (`CALL SELECT_BEST(VEL);`) compiles as ONE XXAR wrapped in an
#      ADLP(3)/DLPE replay, not 3 separate XXARs -- each replay pass
#      appends its own io_pending item, so one logical argument becomes
#      3 items[] entries. A bare EXTN reference's own struct_copy_index
#      is always -1 ("ambient," deferred resolution) by design, but an
#      io_pending item is a captured snapshot consumed later -- by PCAL/
#      FCAL/XXND time the replay is long over and arrayed_index has
#      reverted, so resolving copy index at *bind* time always gave 0
#      regardless of which pass captured it. Fixed by resolving eagerly
#      at *capture* time instead (OP_XXAR), while arrayed_index still
#      reflects the right copy. A new item_is_struct_replay_continuation()
#      helper then lets OP_PCAL/OP_FCAL/OP_XXND recognize consecutive
#      replay-generated items as copies of the SAME logical parameter
#      (not 3 distinct ones), and bind_call_argument's own destination
#      copy index now tracks the source's (previously hardcoded to 0).
# Confirmed against real gpc for both files: 180-EXAMPLE_N.hal gives
# "BEST=               1" (SELECT_BEST's complete logic, all VEL copies
# default OFF/0 per READ_IMU's own elided body -> falls to "ALL EQUALLY
# BAD" -> SELECTED=1); 184-EXAMPLE_N.hal (deliberately-incomplete-per-
# the-book SELECT_BEST body, and an assumed-size `V SUPER_VECTOR-
# STRUCTURE(*)` parameter) gives "BEST=               0" -- both exact
# matches.
run ./run_local_fixture.sh examplen180 "BEST=               1"
run ./run_local_fixture.sh examplen184 "BEST=               0"

# Task #75 (no_return_function_undefined_behavior_diverges, DB status
# still "deferred", NOT fully resolved -- see below): 130-EXAMPLE_N.hal,
# `DO FOR V = 250000 TO 0 BY -100 UNTIL ALMOST_EQUAL(1, MASS(1, V));`
# (V declared plain SCALAR). Previously printed "THE ANSWER IS
# 32767" -- bare-INTEGER-formatted garbage, no error, exit 0. Root
# cause (a real, concrete, now-fixed bug): OP_DFOR/OP_EFOR
# unconditionally typed the loop control variable INTEGER and forced
# its initial/incremented value through rv_to_integer() regardless of
# its own DECLARE'd type -- silently clamping 250000 to the SCALAR->
# INTEGER overflow fixup's own 32767 ceiling (this project's confirmed
# error-15 clamp) even though HAL/S's DO FOR control variable can be
# declared SCALAR, not just INTEGER (USA003087 Sec. 10.2). Fixed by
# consulting the variable's own declared type (symtab) and keeping a
# genuinely SCALAR-declared loop running in double-precision space
# instead. Output now correctly SCALAR-formatted: "THE ANSWER IS
# 2.5000000E+05" -- NOT independently confirmed against real gpc,
# which gives "2.4990000E+05" (249900, i.e. one iteration ran before
# the loop's UNTIL condition took effect) instead of ours (250000, no
# iterations ran, exiting on the very first pre-body UNTIL check since
# ALMOST_EQUAL always unconditionally returns TRUE). That remaining
# discrepancy traces to two separate, genuinely open questions not
# resolved here: (1) whether CFOR's own UNTIL pre-body check
# (class-0/CFOR.md) should be skipped on the loop's very first entry,
# mirroring DFOR's own already-confirmed "skip only the increment, not
# the bounds check, on the first pass" precedent for the TO-clause
# range test; (2) MASS's own missing RETURN statement (USA003090
# error #14, documented fixup "Continue" -- leave the result register
# untouched) is still never detected/reported at all, and its exact
# runtime effect on this file's specific control flow was not traced
# further. This fixture locks in the current (improved but unconfirmed)
# behavior as a regression baseline, not a claim of gpc parity.
# DB id 35: expected value corrected. DO FOR ... UNTIL is post-tested
# (USA003087's DO...UNTIL rule: always runs at least once; the UNTIL
# expression -- ALMOST_EQUAL(1,MASS(1,V)) here, unconditionally TRUE --
# is only evaluated starting from the *second* cycle, using the
# already-stepped V). The old expected value (2.5000000E+05) locked in
# yaHALMAT2's previous, now-confirmed-wrong pre-test-on-every-cycle
# behavior (CFOR checked before the body on cycle 1 too, so the loop
# exited with zero iterations). Real V=249900, confirmed against real
# gpc via compileLinkRun -- see state.h's dfor_body_start comment for
# the fix (OP_DFOR now jumps past CFOR straight into the body on the
# very first cycle, only reaching CFOR from cycle 2 onward via EFOR's
# existing back-branch).
run ./run_local_fixture.sh examplen130 "THE ANSWER IS      2.4990000E+05"

# Dedicated minimal isolation of the same DB id 35 fix, with no MASS/
# ALMOST_EQUAL involved at all: `DO FOR V=250000 TO 0 BY -100 UNTIL
# TRUE;`, a compile-time-constant, unconditionally-true UNTIL. If CFOR
# ran before the body on cycle 1 (the old, wrong behavior), this would
# exit with zero iterations (V=250000); post-tested per spec, it runs
# one full cycle and exits with V=249900. Cross-checked against real
# gpc via compileLinkRun.
run ./run_local_fixture.sh dfor_until_posttest " 2.4990000E+05"

# Task #68 (yahalmat2_nested_structure_vector_field_assign) -- PARTIALLY
# resolved, DB status left "deferred": 177-P.hal,
# `MYSTATE.STATE.POSITION.V = VECTOR(1,2,3);` (POSITION a level-number
# sub-structure of STATE, not a separately-named sub-template) -- two
# compounding bugs found and fixed, both in interp.c:
#  (1) OP_MASN/OP_VASN's receiver-resolution only ever handled QUAL_VAC
#      (a container_ref, e.g. `M$(I,*) = ...;`) and QUAL_SYT (a plain
#      whole-array variable) -- a qualified structure-field receiver
#      (QUAL_XPT, `X.FIELD = ...;`) fell through to "receiver must be
#      SYT" regardless of nesting depth. Fixed via a new QUAL_XPT
#      branch using the already-established resolve_xpt_field() (task
#      #62), allocating the target field's own elements[] on first
#      touch, the same convention every other structure-field VECTOR
#      write already uses.
#  (2) Even with the ASSIGN itself fixed, WRITE/CALL-argument capture
#      (OP_XXAR) had no case at all for a *qualified* VECTOR/MATRIX
#      field reference -- only a *whole* (bare/unqualified) structure
#      reference (TAG1=10) was handled; a single qualified field
#      (TAG1=4/VECTOR or 3/MATRIX) fell through to the generic scalar
#      resolve_operand()/read_syt_entry() path, which has no VECTOR/
#      MATRIX-aware branch at all and silently read the field's unused
#      `.value` union member (0) -- confirmed via direct testing,
#      printed "0" instead of the real VECTOR. Fixed by routing a
#      QUAL_XPT operand with TAG1 in {3,4} through the same resolve_
#      container() path already used for whole_syt/whole_vac.
# Confirmed against real gpc (values match exactly; line-wrapping
# differs only because compileLinkRun's own gpc invocation uses a wider
# --line-width than this fixture's default): POSITION.V=(1,2,3),
# VELOCITY.V=(4,5,6).
#
# DB id 27 (yahalmat2_nested_structure_vector_field_assign): the
# remaining piece above -- `MYSTATE.STATE.ACCEL.V` (ACCEL a *named*
# SUPER_VECTOR-STRUCTURE sub-template nested inside STATE, a level-
# number field) -- is now ALSO resolved, as a byproduct of DB id 21's
# own EXTN multi-hop generalization (struct_mid_path, find_or_create_
# struct_field_path): that fix threads an arbitrary-length chain of
# intermediate hops through the shadow-storage key regardless of
# whether each hop is a level-number field or a named sub-template
# field -- exactly the "genuine data-model extension" this fixture's
# own comment above once called out as still missing. This fixture now
# uses 177-P.hal's full, original content (the ACCEL.V line restored),
# confirmed against real gpc: exact match (POSITION.V=(1,2,3),
# VELOCITY.V=(4,5,6), ACCEL.V=(7,8,9)).
run ./run_local_fixture.sh p177_nested_vec "$(printf 'POSITION.V=\n 1.0000000E+00      2.0000000E+00      3.0000000E+00\nVELOCITY.V=\n 4.0000000E+00      5.0000000E+00      6.0000000E+00\nACCEL.V=\n 7.0000000E+00      8.0000000E+00      9.0000000E+00')"

# Task #69 (yahalmat2_read_vector_unimplemented): 164-OUTER.hal,
# `READ(INFILE) SKIP(0), COLUMN(9), INITIAL_POSN;` (INITIAL_POSN a
# VECTOR DOUBLE) -- the DB item's own original trigger. Investigating
# turned up that the whole-VECTOR READ destination case itself was
# ALREADY fixed by an earlier session (044-ORTHONORMAL.hal's plain
# `READ(5) X;`, dest_is_container path, interp.c) -- reproducing this
# exact file with only PHI/ALPHA/I_POSN/MODE/END input cards (no PRINT
# card) already completed successfully with no crash. The REAL
# remaining trigger, found once a PRINT card was added to actually
# reach every READ branch in this file's own DO WHILE loop, is
# `READ(INFILE) SKIP(0), COLUMN(9), PRINT;` (PRINT declared BOOLEAN)
# -- a completely different, genuinely still-unimplemented gap: READ
# into a plain BIT/BOOLEAN destination (HALMAT class 1), which this
# same "only CHARACTER/SCALAR/INTEGER" allow-list also rejected.
# Fixed by adding a BIT case alongside the existing INTEGER/CHARACTER/
# SCALAR ones, parsed as a plain decimal token reinterpreted as the
# raw bit pattern (matching STOB's own established "round to nearest
# integer, reinterpret as bits" convention) -- no confirmed primary-
# source or real-gpc example of a distinct raw BIT-string external
# READ format was found, unlike HEX'...'/OCT'...'/BIN'...' literals'
# own confirmed encodings. Confirmed against real gpc: exact match
# (PHI=45, ALPHA=30, INITIAL_POSN=(1,1,1), MODE=2).
run ./run_read_fixture.sh outer164 "$(printf 'PHI     45\nALPHA   30\nI_POSN  1,1,1\nMODE    2\nPRINT   1\nEND\n')" "$(printf ' 4.5000000E+01      3.0000000E+01\n 1.0000000E+00      1.0000000E+00      1.0000000E+00               2')"

# DB id 39 (yahalmat2_read_tab_line_page_unimplemented): READ-context
# TAB, implemented and verified this session. Direct HALSFC compile
# probes confirmed TAB(alpha)/LINE(gamma)/PAGE(beta) all compile as
# real, legal HAL/S (no pre-existing corpus file happened to use any of
# them). TAB is now implemented, reusing COLUMN's own has_column/
# column_n mechanism with alpha+1 (a leading TAB is relative to the
# column-1 baseline, matching the already-implemented WRITE-side TAB
# and USA003087 Sec.12.4's own "independent of READ or WRITE" rule) --
# below, TAB(8) and COLUMN(9) target the identical column and must
# produce identical results. A second, unexpected finding drove a new
# has_skip gate on COLUMN/TAB application (OP_READ's own comment):
# repeated real-gpc probes of a *bare* COLUMN/TAB with no SKIP clause
# (relying on the ordinary implicit single-line advance) showed no
# observable positioning effect whatsoever on real hardware -- every
# existing corpus use of COLUMN already pairs it with an explicit SKIP,
# so this was never caught before; this fixture (like every existing
# COLUMN fixture) always pairs TAB/COLUMN with SKIP(0), so it isn't
# itself affected by the gate, but the gate is what makes yaHALMAT2
# match real hardware for the previously-unexercised bare-COLUMN/TAB
# shape too. LINE/PAGE remain unimplemented -- no confirmed behavioral
# model exists for either yet (see interp.c's OP_XXAR comment).
run ./run_read_fixture.sh read_tab "$(printf 'PHI     45\nALPHA   30\nEND\n')" "$(printf ' 4.5000000E+01      3.0000000E+01')"

# Task #71 (yahalmat2_update_block_no_output): 222-BETTER.hal's
# `UPDATE; IF A NOT=0 THEN DO; B=C/A; END; CLOSE; WRITE(6) 'B=',B,
# 'C=',C;` -- an `UPDATE;...CLOSE;` critical-section block (USA003087
# Sec. 15, here guarding a SCALAR LOCK(1) variable) produced completely
# empty output (exit 0). Root cause: `UPDATE;...CLOSE;`'s own closing
# `CLOSE;` reuses the SAME CLOS opcode a PROGRAM/PROCEDURE/FUNCTION/
# TASK's own final CLOSE uses, but its operand is a compiler-synthesized
# internal statement label (`$UPDATE1`, confirmed via COMMON0.out:
# SYM_TYPE=0x42="STATEMENT LABEL") matching the opening UDEF's own
# operand, never the enclosing unit's own label (SYM_TYPE 0x47/0x48/
# 0x49). OP_CLOS had no way to tell the two shapes apart, so this CLOS
# fell into the "primal process closing" branch exactly as if it were
# BETTER's own final CLOSE, halting the whole program before it ever
# reached the WRITE that follows. Fixed by checking the CLOS operand's
# own symtab hal_class: 0x42 (an UPDATE block's own synthesized label)
# is now a no-op, matching UDEF's own already-established "just a
# marker, no real effect to model" role (this interpreter has no
# concurrent-access hazard for UPDATE to actually guard against).
# Confirmed against real gpc for both this file and 224-GNC_POOL.hal
# (a LABELED `COPY_INPUTS: UPDATE; ...; CLOSE COPY_INPUTS;` block copying
# LOCK'd COMPOOL VECTOR variables) -- both exact matches (gpc's own
# "SVC trapped" messages for the LOCK-related SVC codes it doesn't
# model are a separate, harmless log line this project doesn't
# replicate, not a value mismatch).
run ./run_local_fixture.sh better222 "B=      0.0               C=      6.0000000E+00"
run ./run_local_fixture.sh gncpool224 "$(printf 'VEL2=\n 0.0                0.0                0.0               POSN2=\n 0.0                0.0                0.0          ')"

# Task #72 (bit_partition_extraction_mismatch): 253-TEST0.hal's
# `RETURN INFO(WORD+1:BITNUM+1);` (DSUB.md's DSUB, one array-element
# index PLUS one bit-sub-index in a single instruction -- INFO an
# ARRAY(63) BIT(16), the function extracting a single bit out of one
# specific 16-bit array element) previously always returned FALSE for
# every I, confirmed via unHALMAT.py/--disasm to compile to a DSUB
# shape (tag=1, 2 operands, base->rows==0, second operand's own tag1=1)
# never before seen -- distinct from task #64's own `base->rows==0 &&
# num_indices==2` to-partition branch, which the new, more specific
# bit-sub-index branch had to be ordered ahead of since both match the
# same coarse shape. Two compounding, genuinely separate bugs found:
# (1) this DSUB shape's array-element-plus-bit-subindex extraction
# itself was entirely unimplemented, falling through to a generic
# fallback that discarded the bit sub-index -- fixed via a new
# bitpart_array_offset field (state.h's halmat_vac_slot_t) generalizing
# the existing bitpart_ref deferred-BIT-reference mechanism (previously
# scalar-target-only) to also address one element of an ARRAY's own
# bit_elements[], consumed by both resolve_operand's QUAL_VAC read path
# and write_destination's QUAL_VAC write path; (2) once bit-sub-index
# extraction was reading the right array element, that element's own
# INITIAL(BIN'...') value turned out to be all-zero regardless --
# traced to OP_BINT's plain-symbol-write fallback (BIT ARRAY's own
# uniform-INITIAL()-value case, compiled as one BINT wrapped in an
# IDLP/DLPE replay pair, one execution per array element) writing
# directly into the destination's scalar bit_value union member on
# every replay pass instead of routing through write_destination's
# already-correct array-element/arrayed_index-aware logic, exactly
# mirroring the fix OP_SINT's own comment already documents for the
# analogous SCALAR-array case -- INFO's bit_elements[] was therefore
# never populated by INITIAL() at all, for any I. Fixing both in
# combination now correctly returns TEST(0)=FALSE, TEST(1)=FALSE,
# TEST(2)=FALSE, TEST(5)=TRUE, confirmed against real gpc (exact
# match).
run ./run_local_fixture.sh test0_253 "$(printf 'TEST(0)=     0\nTEST(1)=     0\nTEST(2)=     0\nTEST(5)=     1')"

# Task #73 (yahalmat2_bit_concat_sum_expression): 257-TEST4.hal's
# `AVERAGE = BIT$(5 AT #-4)(SUM(INTEGER(DATA$(*:1 TO 5))) / 3) || ...`
# (DATA an ARRAY(3) BIT(16)) previously aborted with "operand is not a
# MATRIX/VECTOR intermediate result" before producing any output at
# all. Four compounding, genuinely separate gaps found and fixed: (1)
# `SUM(INTEGER(DATA$(*:...)))`'s own SFAR-preceded ADLP/DLPE bracket
# was unconditionally excluded from replay by precompute_arrayed_
# paragraphs (a rule tuned for the *other*, already-working
# `SUM(SA1)` whole-array-symbol shape) -- narrowed to exclude only a
# QUAL_SYT SFAR operand, letting a QUAL_VAC (computed sub-expression)
# SFAR genuinely replay once per array element instead; (2) each
# replay pass re-executes the same instructions, so a plain VAC-slot
# capture would lose every pass but the last -- OP_SFAR now eagerly
# resolves a QUAL_VAC operand into new shape_pending.resolved[]/
# has_resolved[] fields (state.h) whenever captured mid-replay, and
# OP_LFNC builds its reduction buffer directly from those when present
# instead of resolve_container (which only knows how to read an
# already-existing array, not assemble one from N independent per-
# pass scalars); (3) DSUB's own asterisk-plus-bit-range shape
# (`DATA$(*:1 TO 5)`/`DATA$(*:5 AT 6)`, both to-partition and at-
# partition range spellings) was entirely unhandled -- extended via
# the same bitpart_ref/bitpart_array_offset mechanism task #72 already
# established, selecting the array element via state->arrayed_index
# during the now-genuine replay; (4) the outer `BIT$(5 AT #-4)(...)`
# explicit-width conversion compiles to a 3-operand STOB (width/
# position, TAG1=3) this project's own STOB previously rejected
# outright, and the chain of BCATs concatenating three such computed
# (not plain-SYT) BIT results needed BCAT's declared-width lookup
# generalized to also read a QUAL_VAC's own bit_width/bitpart_width
# rather than only ever a QUAL_SYT's symtab entry. Confirmed against
# real gpc via compileLinkRun: exact match (AVERAGE=0000 0000 0000
# 0000).
run ./run_local_fixture.sh bitconcat257 "AVERAGE=     0000 0000 0000 0000"

# Task #74 (yahalmat2_extn_multifile_template) -- PARTIALLY resolved,
# DB status left "deferred": 176-P.hal (COMPOOL-templated SUPER_VECTOR
# + EXTERNAL FUNCTION READ_ACC + main PROGRAM P, 3-way @list link)
# aborted immediately with "EXTN: expected 2 operands" on
# `STATE2.STATE.ACCEL = READ_ACC(17);` (STATE2 a plain STRUCTURE, but
# STATE2.STATE and STATE.ACCEL each a *named*-sub-template field --
# `1 STATE STATEVEC-STRUCTURE`/`1 ACCEL SUPER_VECTOR-STRUCTURE` --
# rather than a level-number sub-structure, the one previously-
# confirmed nested shape, task #68). Root cause confirmed via
# --disasm: a named-sub-template nested reference compiles EXTN with
# MORE than 2 operands -- one per dot-qualified hop, base first, final
# field/template last (`STATE2.STATE.ACCEL.V` -> EXTN(4) = [STATE2,
# STATE, ACCEL, V]; the bare whole-substructure form `STATE2.STATE.
# ACCEL` -> EXTN(4) = [STATE2, STATE, ACCEL, SUPER_VECTOR]) -- a shape
# this opcode's previously-confirmed-only 2-operand form couldn't
# parse at all. Fixed: EXTN now accepts any operand_count>=2, threading
# every intermediate hop through a new struct_mid_path (state.h's
# halmat_vac_slot_t) that becomes part of the structure-field shadow-
# slot storage key (find_or_create_struct_field_path, interp.c) --
# needed since a field symbol alone (e.g. V) is shared across every
# sibling instance of its declaring TEMPLATE (POSITION/VELOCITY/ACCEL
# all reach the SAME V symbol), so without the intermediate hops in
# the key, STATE2.STATE.POSITION.V/.VELOCITY.V/.ACCEL.V would alias
# the same storage cell. Threaded through every structure-field call
# site 176-P.hal's own *qualified*-field reads/writes need (resolve_
# xpt_field) and its whole-substructure CALL/ASSIGN-argument passing
# needs (bind_call_argument, the ASSIGN-parameter write-back in OP_
# XXND, TASN's own per-field copy scan) -- confirmed zero regressions
# across the full existing structure-fixture suite (mid_path_len=0,
# identical key, for every pre-existing single-level caller). This
# fixture (isolated, single-unit, no external-function linking at all)
# locks in that generalization: `ST.POSITION.V`/`ST.VELOCITY.V`
# (STATEVEC-STRUCTURE's own two named SUPER_VECTOR-STRUCTURE fields)
# read back correctly disambiguated, confirmed against real gpc (exact
# match, modulo gpc's own two-line WRITE wrapping for a CHARACTER-
# literal-plus-VECTOR argument -- a pre-existing, unrelated formatting
# difference, not a value mismatch).
#
# 176-P.hal ITSELF now runs end-to-end (DB id 21, follow-up session):
# past the EXTN fix, it hit "TASN: both operands must be XPT" on
# `STATE2.STATE.ACCEL = READ_ACC(17);`, because READ_ACC's own FCAL
# result (not a structure XPT reference) is TASN's *source* operand
# here -- READ_ACC is an EXTERNAL FUNCTION *returning a whole
# STRUCTURE* across the unit boundary (MULTI-FILE-LINKING.md's
# "CHARACTER return values implemented; MATRIX/VECTOR still not" --
# STRUCTURE turned out to be in the same unimplemented boat). Fixed:
# OP_RTRN's own external-call branch now detects a bare/whole
# QUAL_XPT structure return and records its identity (base_syt/
# mid_path/copy_index) on external_call_result rather than trying to
# resolve it as a scalar; interp_copy_external_call_result's own new
# is_struct_ref case bridges the callee's and caller's independently-
# numbered symbol tables by field *name* (the two units share the
# byte-identical `D INCLUDE TEMPLATE` source, so both templates'
# struct_first_field/struct_next_field chains visit fields in the same
# order), deep-copying each field's value into the caller's own
# struct_fields[] under a synthetic base_syt (HALMAT_SYT_MAX + this
# FCAL's own VAC index, a reserved range no real SYT index can ever
# occupy) with the caller's own field_syt numbering already baked in --
# from that point on it's just an ordinary same-state structure
# reference. TASN itself was relaxed to accept a QUAL_VAC source (an
# FCAL result) alongside the original QUAL_XPT (an EXTN result), since
# both just index state->vac[] the same way and is_struct_ref (the
# true semantic signal) already gates correctly either way -- and its
# own per-field copy scan/destination-side field creation was threaded
# through struct_mid_path too (a gap task #74 itself left: TASN's
# whole-structure `=` copy only ever reached resolve_xpt_field/bind_
# call_argument/the ASSIGN write-back at the time, not this path).
# Two more compounding gaps surfaced getting 176-P.hal's own output to
# match real gpc exactly (not just avoid crashing): (1) resolve_xpt_
# field lazily allocates a VECTOR-shaped structure-terminal field's own
# elements[] the first time it's *read* (not just written) -- needed
# because PROCEDURE INTEGRATE reads OUTPUT.V (`OUTPUT.V = OUTPUT.V +
# INPUT.V DELTA_T;`) before ever writing it on its very first call
# (OUTPUT.V starts implicitly zero), and every OTHER structure-field
# write path already lazily shapes a never-touched field this same way
# at *write* time, but nothing did at *read* time; (2) an ASSIGN-only
# STRUCTURE parameter's own struct_fields[] entries were never reset
# between calls to the SAME same-unit PROCEDURE (`CALL INTEGRATE(...)
# ASSIGN(...);` called twice in a row) -- confirmed against real gpc
# that HAL/S's own AUTOMATIC storage class re-initializes a local
# fresh each call, but this project's own struct_fields[] shadow-slot
# mechanism has no equivalent reset at all once a field exists; the
# second INTEGRATE call's own early-RETURN path (`IF INPUT.STATUS =
# FALSE THEN DO; OUTPUT.STATUS = FALSE; RETURN; END;`, correctly taken
# since STATE2.STATE.VELOCITY.STATUS really is FALSE) never touches
# OUTPUT.V at all, so without a reset the ASSIGN write-back silently
# copied the *first* call's own leftover OUTPUT.V value into
# STATE2.STATE.POSITION.V instead of real gpc's own 0.0/0.0/0.0 --
# fixed via a new reset_struct_param_fields, called for every ASSIGN-
# form structure parameter right before its (deliberately skipped, see
# OP_PCAL/OP_FCAL's own is_assign comment) bind. named_nest176 (below)
# stays as an isolated, single-unit regression lock for the EXTN
# generalization on its own; this new fixture locks in the full 3-way
# multi-file chain, confirmed against real gpc (exact match) via a
# manual lnk101 3-object link + direct gpc run (compileLinkRun itself
# only supports a single source file).
run ./run_local_fixture.sh named_nest176 "$(printf 'POS=\n 1.0000000E+00      2.0000000E+00      3.0000000E+00\nVEL=\n 4.0000000E+00      5.0000000E+00      6.0000000E+00')"
run ./run_ext_struct_fixture.sh "$(printf 'ACCEL=\n 9.9999964E-02     -1.9999999E-01      9.7999992E+00\nVEL=\n 9.9999905E-03     -1.9999988E-02      9.7999954E-01\nPOS=\n 0.0                0.0                0.0          \nCYCLE=               1')" p176_compool p176_readacc p176_prog

# DB id 17 (integer_exponentiation_overflow_needs_fcos) -- CORRECTED
# 2026-07-28 from its own original framing (a --fcos-needs-extending
# yaGPC2 question): 052-TABLE.hal's `WRITE(6) N, 2**(N-1), N/LOG2(10)`
# with N a compile-time-constant (8,12,16,18,24,30,31, then a final
# `WRITE(6) 2**30 + (2**30-1);`) has HALSFC constant-fold the whole
# `2**(N-1)` expression at compile time -- confirmed via a real Pass 2
# listing: N=16 onward, the folded literal (32768 upward, to
# 2147483647) loads via a full-word `L` into #QIOUT, never a genuine
# CVFX conversion or a 16-bit `LHI`/#QHOUT at all. Two compounding
# yaHALMAT2 bugs found: (1) WRITE's own INTEGER-format argument capture
# reused halmat_scalar_to_integer, the CVFX-interrupt-modeling
# 32767/-32767 clamp -- correct for a genuine runtime SCALAR->INTEGER
# conversion, but wrong here (no real interrupt is ever involved for a
# value the compiler already committed to a wide load for) -- fixed via
# a new halmat_scalar_to_integer_wide/halmat_double_to_integer_wide
# (value.c), full int32_t range, no CVFX clamp; (2) a SEPARATE,
# already-existing 16-bit-register reinterpret truncation further down
# the same WRITE-argument-capture code (modeling a genuine single-
# precision INTEGER's real hardware width, confirmed correct for
# BTOI/SUBBIT-sourced values) was ALSO firing unconditionally on a bare
# QUAL_LIT literal -- exempted QUAL_LIT specifically, since a literal's
# own compiled load-instruction width is dictated by its own value, not
# a genuine runtime register op; (3) resolve_operand's own QUAL_LIT
# scalar resolution (used for the SCALAR-formatted N/LOG2(10) argument,
# unrelated to the INTEGER fix) turned out to already correctly zero a
# literal's own lsw for single-precision display -- confirmed this is
# NOT a reliable single-vs-double signal in general (every literal in
# this file, including the ones needing full lsw precision for exact
# INTEGER display, is tagged LIT_FIXED, never LIT_DOUBLE), so the
# INTEGER-display fix reads literal.c's own already-full-precision
# `lit->numeric` directly instead of routing through that same
# scalar-resolution path, leaving SCALAR-context resolution/formatting
# completely untouched. Confirmed against real gpc via compileLinkRun:
# exact match.
run ./run_local_fixture.sh table052 "$(printf '          8             128      2.4082394E+00\n         12            2048      3.6123590E+00\n         16           32768      4.8164797E+00\n         18          131072      5.4185390E+00\n         24         8388608      7.2247190E+00\n         30       536870912      9.0308990E+00\n         31      1073741824      9.3319292E+00\n 2147483647')"

# DB id 14 (mmwsnp_vector_forces_newline): a VECTOR/MATRIX WRITE
# argument (not a plain numeric ARRAY, which has no equivalent forced-
# newline behavior) always starts a fresh line at column 1 before
# writing, confirmed against the real compiled object code: it calls
# into RUNASM/MMWSNP.asm ("SINGLE PRECISION VECTOR/MATRIX OUTPUT
# INTERFACE"), whose own OLOOP unconditionally does ACALL SKIP then
# ACALL COLUMN(1) before writing each row -- including the first row,
# not just subsequent ones. yaHALMAT2 previously kept a VECTOR/MATRIX
# argument on the same line as whatever preceded it in the same WRITE
# statement (`WRITE(6) 'SUM=', V;` printed "SUM=" and V's values on one
# line). Fixed via a new container_is_vecmat flag (state.h, set from the
# capturing XXAR's own TAG1==3/4, distinguishing a genuine VECTOR/MATRIX
# from a plain numeric ARRAY sharing the same flat-layout WRITE-argument
# path) consulted in flush_write: when the device mechanism isn't
# already at column 1 (i.e. something's already been written on the
# current line, matching MMWSNP's own real-hardware forced-skip
# behavior), force a fresh line before the VECTOR's flat element list or
# the MATRIX's own first row (the MATRIX row-loop already forced a
# newline for every row after the first; this is what makes the first
# row behave the same way). Gated on dm->col != 1 specifically because
# an *unconditional* skip (tried first) broke every already-gpc-
# confirmed fixture where the VECTOR/MATRIX is the WRITE statement's own
# only/first item (`WRITE(6) X;` alone) -- the ordinary per-statement
# default vertical movement already lands column 1 before any item
# runs, so forcing a second skip there added a genuinely wrong extra
# blank line. Confirmed against real gpc for both shapes (`WRITE(6)
# 'SUM=', V;` forces the newline; `WRITE(6) X;` alone does not), and
# re-confirmed against real gpc for every existing VECTOR/MATRIX WRITE
# fixture this fix touched (vsum, dots, outer170_vecinit,
# p177_nested_vec, gncpool224, named_nest176) -- their own previously-
# recorded expected strings turned out to have never actually been
# verified against real gpc for this specific newline-placement detail,
# and were updated to match the newly-confirmed-correct behavior (a
# fixture correction, not a regression). eron_goto's own expected
# string was similarly updated (same values, newline placement only) --
# not independently re-verified against real gpc for this one file
# since it exercises MATRIX INVERSE of a singular matrix, an area
# already documented (DET/INVERSE's own Gaussian-elimination
# approximation) as not a reliable real-gpc comparison point; outer164
# likewise (its own EXPECTED_OUTPUT was always hand-derived, no
# reference emulator available for READ fixtures).
run ./run_local_fixture.sh mmwsnp_sum "$(printf 'SUM=\n 1.0000000E+00      2.0000000E+00      3.0000000E+00')"

# DB id 22 (read_array_early_termination_stale_iobuf): READ(5) A; (A a
# DECLARE ARRAY(100) SCALAR INITIAL(0)) fed only 8 comma-separated
# values, semicolon-terminated, previously left A(9..100) at their own
# DECLARE INITIAL value (0) -- idealized textbook semantics, but not
# what real AP-101S hardware does. RUNASM/HIN.asm's EIN/HIN/IIN/DIN/BIN
# routines unconditionally re-store whatever raw value is still sitting
# in the shared IOBUF register into every remaining pass of the
# compiled fixed-size (always 100-iteration here) READ loop, with no
# check for whether a fresh value was actually supplied that pass -- so
# A(9..100) all silently become 7.50 (the last value actually read),
# confirmed against real gpc. Fixed in OP_READ's own per-element replay
# loop (a plain ARRAY destination is captured as N separate io_pending
# items at XXAR-capture time, unlike a genuine VECTOR/MATRIX -- see
# below): tracks the last successfully-read value across the loop, and
# when a semicolon terminates a still-in-progress run of items all
# naming the same array SYT, writes that stale value into every
# remaining element of that same array instead of leaving the loop
# (stopping the propagation, and the whole READ statement, at the first
# item that isn't part of the same array -- an unrelated later variable
# in the same READ list stays at its own prior value, matching the
# ordinary null-field/terminate rules). Deliberately does NOT apply to
# a genuine VECTOR/MATRIX destination (dest_is_container, a single XXAR
# naming the whole container rather than N replayed items) -- tried
# first, and confirmed via real gpc (read_vecmat_edge fixture, `READ(5)
# A, V, B;` fed "1,2,3;", V a VECTOR(3)) that a VECTOR/MATRIX's own
# unread elements (and any later item) stay at their prior/INITIAL
# value instead, meaning VECTOR/MATRIX READ goes through a different
# real runtime routine that doesn't share this specific bug.
run ./run_read_fixture.sh add154 "$(printf -- '-3.95, -17.31, -9.93, 572.35, -250, +1.10, -.45, +7.50;\n')" "TOTAL IS       9.8930933E+02"

# DB id 34 (no_return_function_undefined_behavior_diverges), follow-up
# piece: yaHALMAT2 previously never detected/reported USA003090
# Appendix C error #14 ("NO RETURN STATEMENT IN FUNCTION") at all -- a
# FUNCTION falling through its own CLOSE with no RETURN silently
# returned whatever the FCAL-result VAC slot happened to already
# contain (uninitialized/leftover from an unrelated prior VAC use),
# with no error logged and ERRGRP()/ERRNUM() left stale. Confirmed via
# real gpc (a minimal `NORET: FUNCTION SCALAR; ... CLOSE NORET;`, no
# RETURN, then `R = NORET;`) that real hardware genuinely detects and
# logs this condition ("*** HAL/S SEND ERROR: RUNTIME: #14 NO RETURN
# STATEMENT IN FUNCTION") before continuing with whatever raw value
# already occupied the real return register -- confirmed to be
# genuine, non-reproducible hardware nondeterminism (real gpc gave
# R=5.0, exactly NORET's own last-assigned local variable S=5, an
# artifact of register reuse, not a spec-defined value) rather than
# something worth chasing bit-for-bit. Per USA003090 Appendix C's own
# documented fixup for error #14 (literally "Continue," distinct from
# the adjacent, unrelated error #15's own 32767/-32768 SCALAR-to-
# INTEGER-overflow clamp) and the user's own 2026-07-27 recommendation
# (informed by prior experience solving the identical problem in an
# XPL compiler): implemented via OP_CLOS's own implicit-return path
# (interp.c) -- when the closing unit is a FUNCTION (OP_FCAL, not
# OP_PCAL, distinguished via the pushed call_return_stack entry's own
# opcode), routes through the same arithmetic_error_should_apply_
# fixup/find_error_handler dispatch every other Appendix C error
# already uses (so ERRGRP()/ERRNUM() now correctly report 4/14, and a
# registered `ON ERROR$(4:14) GO TO ...;` handler is honored -- unlike
# real gpc's own ON ERROR/SEND ERROR dispatch, independently confirmed
# elsewhere in this project to not reliably work, "gpc is not
# authoritative"), then applies a deterministic, type-appropriate
# zero/empty default read directly off the callee's own declared
# return type (its FUNCTION LABEL symbol's own hal_class, confirmed
# via symtab.c to be the raw SYM_TYPE field verbatim -- 0 for SCALAR/
# INTEGER, OFF/0 for BIT/BOOLEAN, empty string for CHARACTER, a zero-
# filled container for VECTOR/MATRIX when the declared shape is known)
# instead of leaving whatever was previously sitting in the VAC slot.
# Confirmed against real gpc for the error-detection/ERRGRP/ERRNUM
# mechanism itself, the GOTO-handler-honoring behavior, and BIT/
# BOOLEAN/CHARACTER-returning cases; the SCALAR default (0) doesn't
# match gpc's own 5.0 by design, per the "don't reproduce hardware
# garbage" reasoning above.
#
# Does NOT resolve 130-EXAMPLE_N.hal's own remaining discrepancy
# (yaHALMAT2 gives "THE ANSWER IS 2.5000000E+05", real gpc gives
# "2.4990000E+05") -- re-investigated this session via a direct
# unHALMAT.py --disasm trace of the real compiled HALMAT: confirmed
# CFOR (the DO-FOR loop's own UNTIL-clause check) is compiled directly
# after DFOR, before the very first body pass, exactly the same
# "always check, even on the first pass" pattern DFOR's own TO-range
# bounds check already uses (independently confirmed correct via a
# real AP-101S run) -- i.e. yaHALMAT2's own CFOR-before-first-body-pass
# sequencing is a faithful match to the real compiled instruction
# order, not a bug. Since ALMOST_EQUAL unconditionally `RETURN TRUE;`
# regardless of its own arguments, this ordering means BOTH tools
# should evaluate the UNTIL condition as true on the very first check,
# before any body iteration -- yet real gpc's own final answer implies
# ONE iteration actually ran. This remains a genuinely open, deeper
# question about a real-hardware behavior not evident from the
# compiled instruction stream alone (possibly some AP-101S-specific
# error-#14-trap/control-flow interaction not documented anywhere
# accessible) -- left open rather than guessed at, per this project's
# own standing discipline against unconfirmed speculative fixes.
run ./run_local_fixture.sh noret14 "$(printf 'R=      0.0          \nERRGRP=               4\nERRNUM=              14')"

# User-reported: "HAL-S-360 Users Manual"/DEMO.hal ("THIS IS A
# DEMONSTRATION PROGRAM TO SHOW THE LISTING PRODUCED BY THE HAL/S-360
# COMPILER") crashed with "DSUB: asterisk subscript with 4 indices not
# yet implemented" -- a genuinely new, real (confirmed compiled and run
# by real gpc, not just a syntax-coverage listing artifact), corpus
# subscript shape: `K$(2 TO 5:)` (K an ARRAY(5) MATRIX(3,4)), an array-
# dimension to-partition combined with a full component (matrix)
# wildcard on both axes -- selects a contiguous run of whole MATRIX
# elements. Root-caused to several compounding, genuinely new gaps:
# (1) ensure_container() never had an ARRAY(n) MATRIX(r,c) case at all
# (new array_of_matrix/array_len fields, state.h), so K's own 60-value
# INITIAL list was being silently mis-sized; (2) DSUB itself never
# accepted a QUAL_XPT (structure-field) base -- `MY_STRUCTURE.RR.AAREF.
# BB.CC$(3;1 TO 3,*)`, CC a plain MATRIX(4,3) structure terminal --
# resolved the same way OP_RTRN's `RETURN X.V;` already does
# (resolve_xpt_field), extended to also lazily shape-allocate MATRIX/
# ARRAY-of-MATRIX terminals (previously VECTOR-only); (3) a second new
# DSUB shape, `CC$(1 TO 3,*)` -- a component (matrix-axis) to-partition
# on rows plus a full wildcard on columns; (4) MASN's own QUAL_XPT
# destination write unconditionally overwrote the destination field's
# rows/cols from the *source* container's own (unrelated) shape,
# corrupting `MY_STRUCTURE.RR.AAREF.DD.EE$(I;) = K$(2 TO 5:);`'s target
# EE field (ARRAY(4) MATRIX(3,4)) -- fixed to preserve a declared
# array_of_matrix field's own fixed shape. Verified against real gpc
# (compileLinkRun): 59 of 60 printed WRITE values now match exactly.
# The one remaining divergence (D, the very last value on this
# program's own `DO FOR C=1 TO 100; D=K$(C:2,3); END;` loop -- K only
# has 5 array elements, so this deliberately runs 95 iterations out of
# bounds) is a separate, real-hardware behavior (D holding whatever raw
# memory sits past K's own declared bound) that isn't meant to compare
# equal across tools with a different static memory layout -- real gpc
# gives D=0.0, yaHALMAT2 gives D=307.0, both "correct" for their own
# build; not attempted here, left as yaHALMAT2's own consistent value.
#
# id 59 (multi_item_write_truncated_with_bareword_array_of_matrix)
# fix updated K's own expected block below from a
# WRONG 5-element truncation (this fixture's own PRE-FIX snapshot,
# apparently locked in without noticing K itself was wrong, only D's
# own separate divergence above) to the authentic full 60-element
# ARRAY(5) MATRIX(3,4) result -- confirmed bit-for-bit against yaGPC2's
# own real execution of this exact fixture (WRITE(6) K; K=0; both
# affected: real hardware's own ADLP(5)/DLPE replay for K resolves each
# pass to a genuine rows*cols=12-element MATRIX block, not one flat
# scalar, which resolve_container's/write_destination's own generic
# per-element replay logic had no array_of_matrix awareness for).
run ./run_local_fixture.sh demo_users_manual "$(printf ' 0.0                0.0                0.0          \n 0.0                0.0                0.0          \n 0.0                0.0                0.0          \n 2.0100000E+02      2.0200000E+02      2.0300000E+02      2.0400000E+02\n 2.0500000E+02      2.0600000E+02      2.0700000E+02      2.0800000E+02\n 2.0900000E+02      2.1000000E+02      2.1100000E+02      2.1200000E+02\n 3.0100000E+02      3.0200000E+02      3.0300000E+02      3.0400000E+02\n 3.0500000E+02      3.0600000E+02      3.0700000E+02      3.0800000E+02\n 3.0900000E+02      3.1000000E+02      3.1100000E+02      3.1200000E+02\n 4.0100000E+02      4.0200000E+02      4.0300000E+02      4.0400000E+02\n 4.0500000E+02      4.0600000E+02      4.0700000E+02      4.0800000E+02\n 4.0900000E+02      4.1000000E+02      4.1100000E+02      4.1200000E+02      3.0700000E+02\n 1.0000000E+02      2.0000000E+02      3.0000000E+02      4.0000000E+02      4.5000000E+01      5.6000000E+01      6.7000000E+01\n 7.8000000E+01      8.9000000E+01\n 0.0                0.0                0.0                0.0          \n 0.0                0.0                0.0                0.0          \n 0.0                0.0                0.0                0.0          \n 0.0                0.0                0.0                0.0          \n 0.0                0.0                0.0                0.0          \n 0.0                0.0                0.0                0.0          \n 0.0                0.0                0.0                0.0          \n 0.0                0.0                0.0                0.0          \n 0.0                0.0                0.0                0.0          \n 0.0                0.0                0.0                0.0          \n 0.0                0.0                0.0                0.0          \n 0.0                0.0                0.0                0.0          \n 0.0                0.0                0.0                0.0          \n 0.0                0.0                0.0                0.0          \n 0.0                0.0                0.0                0.0                9.0000000E+01      1.0000000E+00      1.2000000E+01\n 2.3000000E+01')"

# id 59's own dedicated, minimal repro: a bareword ARRAY(5) MATRIX(3,4)
# WRITE (real HALSFC compiles this as an ADLP(5)/DLPE-replayed XXAR,
# TAG1=3, confirmed via --disasm -- each replay pass must resolve to a
# genuine rows*cols=12-element MATRIX block) and the "null MATRIX
# array" idiom (`K=0;`, also ADLP(5)/DLPE-replayed on real hardware,
# each pass zeroing a whole 12-element block) -- both independently
# confirmed bit-for-bit against yaGPC2's own real execution.
run ./run_local_fixture.sh array_of_matrix_write "$(printf ' 1.0000000E+00      2.0000000E+00      3.0000000E+00      4.0000000E+00\n 5.0000000E+00      6.0000000E+00      7.0000000E+00      8.0000000E+00\n 9.0000000E+00      1.0000000E+01      1.1000000E+01      1.2000000E+01\n 1.0100000E+02      1.0200000E+02      1.0300000E+02      1.0400000E+02\n 1.0500000E+02      1.0600000E+02      1.0700000E+02      1.0800000E+02\n 1.0900000E+02      1.1000000E+02      1.1100000E+02      1.1200000E+02\n 2.0100000E+02      2.0200000E+02      2.0300000E+02      2.0400000E+02\n 2.0500000E+02      2.0600000E+02      2.0700000E+02      2.0800000E+02\n 2.0900000E+02      2.1000000E+02      2.1100000E+02      2.1200000E+02\n 3.0100000E+02      3.0200000E+02      3.0300000E+02      3.0400000E+02\n 3.0500000E+02      3.0600000E+02      3.0700000E+02      3.0800000E+02\n 3.0900000E+02      3.1000000E+02      3.1100000E+02      3.1200000E+02\n 4.0100000E+02      4.0200000E+02      4.0300000E+02      4.0400000E+02\n 4.0500000E+02      4.0600000E+02      4.0700000E+02      4.0800000E+02\n 4.0900000E+02      4.1000000E+02      4.1100000E+02      4.1200000E+02\n 0.0                0.0                0.0                0.0          \n 0.0                0.0                0.0                0.0          \n 0.0                0.0                0.0                0.0          \n 0.0                0.0                0.0                0.0          \n 0.0                0.0                0.0                0.0          \n 0.0                0.0                0.0                0.0          \n 0.0                0.0                0.0                0.0          \n 0.0                0.0                0.0                0.0          \n 0.0                0.0                0.0                0.0          \n 0.0                0.0                0.0                0.0          \n 0.0                0.0                0.0                0.0          \n 0.0                0.0                0.0                0.0          \n 0.0                0.0                0.0                0.0          \n 0.0                0.0                0.0                0.0          \n 0.0                0.0                0.0                0.0          ')"

# DB id 49 (demo_hal_matrix_shaping_wildcard_dsub_crash): the live
# "HAL-S-360 Users Manual"/DEMO.hal has since been substantially
# rewritten upstream (it now exercises even more subscript shapes than
# the snapshot demo_users_manual locks in above) and its own new
# leading statement crashed with "operand qualifier AST not yet
# implemented" -- `MY_STRUCTURE.RR.AAREF.BB.CC$(1;*,*) =
# MATRIX$(4,3)(...);`, a full-wildcard $(*,*) MATRIX structure-field
# assignment (both matrix axes wildcarded at once, distinct from the
# already-implemented M$(i,*)/M$(*,j) single-axis-wildcard cases).
# Fixed alongside a second, closely related new shape found pushing
# further into the same rewritten file: `EE$(J:)`/`K$(J+1:)`, a
# single *computed* (non-literal, non-range) array index combined
# with a full component wildcard on an ARRAY-of-MATRIX. Both required
# extending the writable-container-reference mechanism (MASN/state.h)
# to support a receiver resolved through a QUAL_XPT (structure-field)
# DSUB base, not just a plain SYT one. Confirmed against real gpc via
# compileLinkRun. The live DEMO.hal still doesn't run to completion --
# a third, deeper gap (TSUB accepting an asterisk copy-index to
# broadcast an assignment across every copy of a multi-copy structure)
# remains and needs its own dedicated investigation; see the DB's own
# follow-up entry.
run ./run_local_fixture.sh matrix_field_wildcard "$(printf ' 5.1100000E+02      5.1200000E+02      5.1300000E+02      5.1400000E+02      5.1500000E+02      5.1600000E+02      5.1700000E+02\n 5.1800000E+02      5.1900000E+02      5.2000000E+02      5.2100000E+02      5.2200000E+02\n 2.1000000E+01      2.2000000E+01      2.3000000E+01      2.4000000E+01\n 2.5000000E+01      2.6000000E+01      2.7000000E+01      2.8000000E+01\n 2.9000000E+01      3.0000000E+01      3.1000000E+01      3.2000000E+01')"

# DB id 44 (plain_2d_array_scalar_forced_newline_regression,
# 106-EXAMPLE_2.hal's ATT_RATE, a plain ARRAY(4,3) SCALAR): the flush_
# write MATRIX-row-per-line layout (mmwsnp_vector_forces_newline, id
# 14) was gated only on container_rows>0, which a genuinely 2-D plain
# ARRAY also has (ensure_container's own 2D-ARRAY comment: same rows/
# cols encoding a real MATRIX uses, so DSUB's indexing applies for
# free) -- incorrectly forcing a newline every 3rd element as if it
# were a true MATRIX. Real hardware's MMWSNP.asm forced-newline
# behavior only applies to the genuine VECTOR/MATRIX runtime WRITE
# path; a plain numeric ARRAY, however many declared dimensions, wraps
# flat/generically like any other field. Gated on the pre-existing
# container_is_vecmat flag instead (already correctly computed from
# the XXAR operand's own TAG1, and already used by this same
# function's "force a fresh line first" check just above -- only the
# row-vs-flat layout choice itself hadn't been extended to match).
# Confirmed against real gpc.
run ./run_local_fixture.sh array2d_scalar_write "$(printf ' 1.0000000E+00      2.0000000E+00      3.0000000E+00      4.0000000E+00      5.0000000E+00      6.0000000E+00      7.0000000E+00\n 8.0000000E+00      9.0000000E+00      1.0000000E+01      1.1000000E+01      1.2000000E+01')"

# DB id 45 (vector_write_precision_format_mismatch, 119-EXAMPLE_9.hal's
# `V$(I:) = VECTOR(RANDOM, RANDOM, RANDOM);`, V a plain -- not DOUBLE
# -- VECTOR(3)): VASN/MASN's own plain-SYT destination write (interp.c)
# was a raw memcpy with zero precision scaling, copying each source
# element's own double_precision flag straight through regardless of
# the destination's declared precision -- harmless before RANDOM was
# fixed to genuinely return DOUBLE (id 36; the old placeholder always
# produced SINGLE, masking this), now a real WRITE-formatting bug
# (halmat_scalar_format keys directly off that per-element flag: 7 vs
# 16 fractional digits). Fixed with the same symtab-driven
# scale_precision() convention already used for plain-SCALAR
# destinations elsewhere in this file, applied per element. Confirmed
# against real gpc.
run ./run_local_fixture.sh vector_precision_write " 4.3794729E-02      2.6276231E-01      1.8242157E-01"

# DB id 47 (read_eof_spurious_trailing_blank_line, 159-AGE.hal run with
# stdin=/dev/null so its READALL(5) immediately hits EOF with no ON
# ERROR handler installed): interp_cleanup's own final per-device
# flush -- needed to commit the very *last* WRITE's still-open line,
# which nothing else ever finalizes (device_mech's own state.h
# comment) -- unconditionally emitted a trailing '\n' for any
# `started` device, even when that still-open "line" was never
# actually written to: a leading `WRITE(6) COLUMN(1);` (an
# io-control-only WRITE, no data expressions) merely repositions the
# device mechanism per USA003087 Sec. 12.2's own rule ("[i]f no
# expressions are supplied in the WRITE statement, the device merely
# performs its initial positioning") -- confirmed against real gpc,
# which correctly emits no extra line here. Fixed by tracking whether
# a genuine data field (dm_emit_field, the sole path into a line's
# buffer) has actually been written to the device's current open line
# (new line_has_data flag, state.h/interp.c) and gating cleanup's
# trailing-newline flush on it -- distinct from line_buf_len>0, since
# a WRITE of a genuine zero-length CHARACTER field must still flush
# (it supplied a real, if empty, data expression) while a positioning-
# only WRITE must not. Verified the ordinary non-EOF completion path
# (real stdin input) still matches real gpc byte-for-byte, including
# the *embedded* blank line the same COLUMN(1) statement legitimately
# produces there (finalized by the next WRITE's own default vertical
# movement, not orphaned the way it is at EOF). Needs a byte-exact
# harness (run_read_fixture_bytes.sh): the ordinary run_read_fixture.sh
# `actual=$(...)` capture silently strips every trailing newline, so
# it can never distinguish a missing vs. present final blank line.
run ./run_read_fixture_bytes.sh read_eof_no_trailing_blank "" $'A\nB\n'

# DB id 56 (wildcard_subscript_matrix_write_loses_row_forcing): OP_DSUB's
# asterisk-select handling (`M$(...)` -- V$(*), M$(i,*), M$(*,j), M$(*,*))
# shares one store_container_result() tail for the four simplest shapes,
# hardcoded to rows=0 -- correct for the three genuinely VECTOR-shaped
# results (V$(*), M$(i,*), M$(*,j)), but wrong for M$(*,*) (both axes
# wildcarded), which is a real 2-D MATRIX result. That meant a WRITE of a
# MATRIX referenced via an explicit `X$(*,*)` subscript, rather than a
# bare `X`, silently lost flush_write's rows>0-gated per-row forced-
# newline layout (mmwsnp_vector_forces_newline, id 14) -- both forms are
# semantically identical per USA003087 (the wildcard subscript means "the
# whole dimension"). Confirmed via a minimal repro (`WRITE(6) X$(*,*);`,
# X a MATRIX(3,3)) and against real gpc, which keeps the 3-rows-per-
# matrix layout for both forms. Fixed by threading a `result_rows`
# variable through the shared tail instead of a hardcoded 0, set to
# `base->rows` only in the M$(*,*) branch. Directly relevant to DEMO.hal
# (Section 4 of problems.md), which uses `$(*,*)`/`$(n;*,*)`-subscripted
# MATRIX WRITE arguments extensively.
run ./run_local_fixture.sh matrix_wildcard_write_rows "$(printf ' 1.0000000E+00      2.0000000E+00      3.0000000E+00\n 4.0000000E+00      5.0000000E+00      6.0000000E+00\n 7.0000000E+00      8.0000000E+00      9.0000000E+00')"

# DB id 55 (ctoi_invalid_digit_substring_wrong_result): OP_CTOI/OP_CTOS
# (character->integer/scalar conversion) used plain strtod(), which
# parses a leading numeric *prefix* and silently ignores everything
# after -- not what real gpc does. USA00309 Sec. 6.1.2/Sec. 8.2 rule 16
# require the string to be in a standard input format "only if" it
# converts at all; confirmed empirically against 159-AGE.hal's own
# `X = INTEGER(C(7 TO 10));` across a matrix of inputs: valid whole-
# number strings convert correctly (with ONLY TRAILING blanks
# tolerated, e.g. "7   "->7), but ANY interior non-blank non-digit
# character anywhere invalidates the WHOLE string to 0 -- including a
# LEADING blank before an otherwise-valid digit ("  9 "->0, not 9),
# which strtod()'s partial-prefix parsing can never produce. Fixed via
# a new ctoi_parse_scalar() helper (interp.c) implementing strict
# whole-string validation (optional sign, digits, optional decimal
# point + digits, optional E-exponent, then only trailing blanks) --
# any leftover non-blank character anywhere fails the whole conversion
# to 0.0, matching every one of 10 confirmed real-gpc cross-check
# cases. Applied to both OP_CTOI and OP_CTOS (the doc frames them as
# sharing "the same parse"); only the CTOI/INTEGER side was
# independently reconfirmed against real gpc.
run ./run_read_fixture.sh ctoi_invalid_digit "1234567890" "       7890"
run ./run_read_fixture.sh ctoi_invalid_digit "1234567AAA" "          0"

# DB id 50 (tsub_asterisk_copy_broadcast_unimplemented): TSUB's asterisk
# copy-index (`$(*;...)`, broadcasting an assignment across every copy
# of a multi-copy structure -- USA003087 Sec 19.6) previously failed
# loudly. A bare TSUB fix alone wasn't enough (DEMO.hal's own repro:
# `EE$(*;3:2,*) = CC$(*;*,2);` compiles to TWO separate TSUB/EXTN/DSUB
# chains feeding one VASN): TSUB would run once, before any replay, and
# every one of the ADLP(5)/DLPE replay's 5 passes would see the same
# fixed copy. Fixed by widening precompute_arrayed_paragraphs' own
# backward dependency-chase to also follow QUAL_XPT operands, not just
# QUAL_VAC ones -- resolve_xpt_field's own comment confirms QUAL_XPT
# uses the identical stream-position addressing convention, it's just a
# different qualifier tag; this alone pulls TSUB/EXTN transitively into
# the SAME replayed paragraph as the DSUB/VASN that depends on them
# (via DSUB's own QUAL_XPT base operand -> EXTN -> EXTN's own QUAL_VAC
# operand -> TSUB), no new paragraph-boundary rule needed. Also added a
# new array-of-matrix DSUB shape hit along the way (`EE$(3:2,*)`: a
# single index plus a row-or-column select on that one element, distinct
# from the already-implemented "index + full wildcard" and "index +
# range" shapes). Confirmed against real gpc via a minimal isolated
# repro (byte-identical for all 5 copies).
run ./run_local_fixture.sh tsub_asterisk_broadcast "$(printf ' 5.1200000E+02      5.1500000E+02      5.1800000E+02      5.2100000E+02\n 6.1200000E+02      6.1500000E+02      6.1800000E+02      6.2100000E+02\n 7.1200000E+02      7.1500000E+02      7.1800000E+02      7.2100000E+02\n 8.1200000E+02      8.1500000E+02      8.1800000E+02      8.2100000E+02\n 9.1200000E+02      9.1500000E+02      9.1800000E+02      9.2100000E+02')"

# DB id 58 (whole_structure_write_no_recursion_or_matrix_char_fields):
# flush_write's own is_structure WRITE-argument walk (struct_first_field/
# struct_next_field) only handled 4 terminal hal_class values directly
# (VECTOR/INTEGER/BIT/SCALAR) -- a nested-STRUCTURE terminal (hal_class
# 0x0A), a MATRIX terminal (0x03), or a CHARACTER terminal (0x02) all
# failed loudly. DEMO.hal's own `WRITE(PRINTER) MY_STRUCTURE;` (MY_
# STRUCTURE QQ-STRUCTURE(5), QQ = `1 RR, 2 AAREF AA-STRUCTURE, 2 SS
# CHARACTER(5)`) hits all three: RR is a bare anonymous grouping
# terminal (itself hal_class 0x0A) wrapping AAREF/SS. Extracted into a
# new recursive write_structure_fields() helper. Two real bugs found
# along the way, both confirmed via a real COMMON0.out symtab dump and
# fixed: (1) an anonymous nested grouping like RR has NO struct_
# template_syt of its own (a zero-cost compile-time label the real
# EXTN instruction chain skips entirely -- confirmed empirically:
# `MY_STRUCTURE.RR.AAREF.BB.CC` compiles to an EXTN with mid_path=
# [AAREF's own syt] ONLY, RR and BB entirely absent) -- naively adding
# every hal_class 0x0A field to mid_path during recursion produced a
# mid_path that didn't match what the corresponding assignment
# statement actually stored under, reading back all-zero; (2) an
# ARRAY-of-MATRIX terminal's fsym->rows/cols hold only the PER-ELEMENT
# matrix shape, not the outer array length (which lives in
# array_dims[0], HALMAT_SHAPE_ARRAY) -- row-forcing needs total_rows =
# rows * array_dims[0]. MATRIX/ARRAY-of-MATRIX terminals ARE row-
# forced within a whole-structure WRITE (confirmed against real gpc's
# own output for this exact statement) -- a genuinely different real-
# hardware behavior than a single subscripted structure-field WRITE
# argument (id 56's own comment), since gpc's whole-structure output
# routine reuses the same MMWSNP-style row-forcing internally. Verified
# byte-identical against real gpc via an isolated minimal probe (no
# preceding WRITE statements to entangle the comparison with DEMO.hal's
# own separate, unrelated multi-item-WRITE gap -- see id 59).
run ./run_local_fixture.sh write_whole_structure_recursive "$(printf ' 5.1100000E+02      5.1200000E+02      5.1300000E+02\n 5.1400000E+02      5.1500000E+02      5.1600000E+02\n 5.1700000E+02      5.1800000E+02      5.1900000E+02\n 5.2000000E+02      5.2100000E+02      5.2200000E+02\n 1.0000000E+00      2.0000000E+00      3.0000000E+00      4.0000000E+00\n 5.0000000E+00      6.0000000E+00      7.0000000E+00      8.0000000E+00\n 9.0000000E+00      1.0000000E+01      1.1000000E+01      1.2000000E+01\n 0.0                0.0                0.0                0.0          \n 0.0                0.0                0.0                0.0          \n 0.0                0.0                0.0                0.0          \n 0.0                0.0                0.0                0.0          \n 0.0                0.0                0.0                0.0          \n 0.0                0.0                0.0                0.0          \n 0.0                0.0                0.0                0.0          \n 0.0                0.0                0.0                0.0          \n 0.0                0.0                0.0                0.0               ELEM1\n 6.1100000E+02      6.1200000E+02      6.1300000E+02\n 6.1400000E+02      6.1500000E+02      6.1600000E+02\n 6.1700000E+02      6.1800000E+02      6.1900000E+02\n 6.2000000E+02      6.2100000E+02      6.2200000E+02\n 2.1000000E+01      2.2000000E+01      2.3000000E+01      2.4000000E+01\n 2.5000000E+01      2.6000000E+01      2.7000000E+01      2.8000000E+01\n 2.9000000E+01      3.0000000E+01      3.1000000E+01      3.2000000E+01\n 0.0                0.0                0.0                0.0          \n 0.0                0.0                0.0                0.0          \n 0.0                0.0                0.0                0.0          \n 0.0                0.0                0.0                0.0          \n 0.0                0.0                0.0                0.0          \n 0.0                0.0                0.0                0.0          \n 0.0                0.0                0.0                0.0          \n 0.0                0.0                0.0                0.0          \n 0.0                0.0                0.0                0.0               ELEM2')"

# DB id 70 (demo_recursive_structure_write_spurious_form_feed): a
# same-day attempt to strip the automatic "line count reaches
# page_length => turn the page" check out of dm_advance_lines
# (reasoning it didn't match yaGPC2's own halucp.c) was REVERTED per
# direct user correction: real hardware DOES turn the page whenever
# writing crosses the page-length boundary, regardless of which
# statement caused the line advance (implicit default advance,
# SKIP(n), or an explicit LINE/PAGE wrap) -- yaGPC2's own agreement
# with the (wrong) no-turn theory was not independent confirmation
# (see feedback_gpc_not_authoritative memory: yaGPC2's halucp.c likely
# shares lineage with gpc's own halUCP.coffee), and yaGPC2 itself has
# this same bug, being fixed on that side. This minimal repro (70
# single-line WRITEs, crossing the 66-line default page_length
# mid-stream) confirms a form-feed correctly appears right after line
# 66 (before line 67 is written), with no LINE/PAGE statement in sight.
run ./run_local_fixture.sh page_overflow_no_autoformfeed "$(printf '          1\n          2\n          3\n          4\n          5\n          6\n          7\n          8\n          9\n         10\n         11\n         12\n         13\n         14\n         15\n         16\n         17\n         18\n         19\n         20\n         21\n         22\n         23\n         24\n         25\n         26\n         27\n         28\n         29\n         30\n         31\n         32\n         33\n         34\n         35\n         36\n         37\n         38\n         39\n         40\n         41\n         42\n         43\n         44\n         45\n         46\n         47\n         48\n         49\n         50\n         51\n         52\n         53\n         54\n         55\n         56\n         57\n         58\n         59\n         60\n         61\n         62\n         63\n         64\n         65\n         66\n\f         67\n         68\n         69\n         70')"

# DB id 51 (yahalmat2_uses_ieee_double_not_ibm_hex_float, re-investigated
# 2026-07-29 per direct user clarification: the real fidelity target is
# the original AP-101S hardware/software via yaGPC2, not real gpc, which
# only achieves partial hex-float authenticity itself): found and fixed a
# genuine, foundational literal-precision bug while cross-checking SQRT
# against yaGPC2. resolve_operand's own QUAL_LIT case defaulted every
# numeric literal to SINGLE precision (halmat_scalar_from_ibm_words'
# own `double_precision ? lsw : 0`, zeroing lsw) unless the litfile's own
# type tag was literally LIT_DOUBLE -- but confirmed via a real litfile
# dump (literals1.txt) that EVERY literal is tagged LIT_FIXED regardless
# of its actual value's precision needs, the exact same tag-ambiguity
# already documented elsewhere in this file (OP_XXAR's own
# integer_class_scalar comment, for the analogous INTEGER-context case) --
# so a genuine DOUBLE-precision literal like `X = 1.4142135623730951;`
# (X SCALAR DOUBLE) permanently lost its own low word before OP_SASN's
# later widening pass ever ran (widening only flips the double_precision
# flag, it can't recover already-zeroed bits). Confirmed as a real,
# previously-undetected bug (not expected precision loss) via a real
# litfile dump showing the full msw/lsw pair genuinely present
# (4116A09E/667F3BCC), and via real gpc/yaGPC2 both displaying the
# correct value for this exact literal while yaHALMAT2 alone showed a
# drastically wrong one. Fixed narrowly at OP_SASN's own precision-
# widening site (not resolve_operand itself -- a first attempt broadening
# resolve_operand's own default broke several already-correct SINGLE-
# precision consumers, VASN/MASN MATRIX/VECTOR constructor literals
# among them, that have no narrowing step of their own): when widening a
# literal source to double, re-derive the value directly from the
# literal table's own msw/lsw instead of merely flipping the flag on the
# already-truncated resolved scalar.
run ./run_local_fixture.sh double_literal_precision " 1.4142135623730949E+00"

# id 63 (yagpc2-yahalmat2-issues.db, 108-EXAMPLE_5.hal's own `RMS =
# SQRT(TOTAL/COUNT);`, TOTAL SCALAR DOUBLE, RMS plain SCALAR): SQRT of a
# DOUBLE-precision argument previously reused hal_sqrt_single on X's own
# narrowed msw and just re-tagged the result double_precision=true --
# correct bits, wrong ALGORITHM (inherently single-precision ~24-bit-
# mantissa accuracy mislabeled as double), landing on a different last
# digit than real hardware once narrowed back down to RMS's own single-
# precision 7-significant-digit format (previously 5.8167862E+01, real
# gpc/yaGPC2 both give 5.8167847E+01). Fixed via a real, genuinely
# double-precision port of RUNASM/DSQRT.asm (hal_sqrt_double,
# hal_transcendental.c) -- instruction-by-instruction against a real
# yaGPC2 --trace of this exact repro, reusing the project's own already-
# verified extended-precision hex-float core (hrfp_addE/subE/mulE/divE)
# for DSQRT's own genuine SEDR/AEDR double-precision correction pass,
# the one thing hal_sqrt_single's own single-precision-only Newton-
# Raphson can never provide. Confirmed bit-exact against real gpc.
run ./run_local_fixture.sh dsqrt_precision " 5.8167847E+01"

# id 67 (yagpc2-yahalmat2-issues.db, 119-EXAMPLE_9.hal's own `V$(I:) =
# VECTOR(RANDOM, RANDOM, RANDOM);`, V a plain -- not DOUBLE -- ARRAY(999)
# VECTOR(3)): id 45's own scale_precision() narrowing fix (VASN's plain-
# whole-SYT destination branch) never reached the SEPARATE is_container_ref
# write path a SUBSCRIPTED ARRAY(n) VECTOR(m) element assignment actually
# uses -- a genuinely DOUBLE-precision source (D SCALAR DOUBLE below,
# standing in for RANDOM()'s own real DOUBLE return) landed in storage
# still flagged double_precision=true, which halmat_scalar_format then
# printed at full double-precision width instead of narrowing to V's own
# single-precision declared shape. Fixed via the same per-element
# scale_precision() pattern id 45 already established, applied to
# is_container_ref's own write loop (interp.c's OP_VASN). Uncovered a
# SECOND, previously-masked gap while verifying against the full
# 119-EXAMPLE_9.hal repro: ABVAL/UNIT (BFNC selectors 28/27) used a plain
# libm sqrt() shortcut instead of the real, authentic hal_sqrt_single/
# hal_sqrt_double RTL port (no dedicated RUNASM RTL routine exists for
# either -- PASS2 code generation inlines a dot-product plus a genuine
# ACALL SQRT at each call site instead) -- a small, systematic last-2-
# digit divergence on every ABVAL() call that this fixture's own
# genuinely-double-precision input (D) exercises just as it did the real
# RANDOM()-sourced repro. Both fixed together; confirmed bit-exact
# against real gpc.
run ./run_local_fixture.sh array_of_vector_precision "$(printf ' 1.9052544E+00\n 1.0999994E+00      1.0999994E+00      1.0999994E+00')"

# id 66 (yagpc2-yahalmat2-issues.db, GOOGLE-PARALLAX.hal): id 51's own
# closing summary of ported RUNASM transcendentals never actually
# listed plain TAN (only ATAN/TANH) -- a genuine gap, not just an
# already-adequate libm shortcut. TAN(X) on a DOUBLE-precision X
# previously used libm tan() directly (double round-trip through native
# IEEE 754, not real hardware's own hex-float algorithm), landing on a
# different value starting around the 10th significant digit. Fixed via
# a real, genuinely double-precision port of RUNASM/DTAN.asm
# (hal_tan_double, hal_transcendental.c) -- instruction-by-instruction
# against a real yaGPC2 --trace of this exact repro (confirmed bit-exact
# at every intermediate step: range-reduction, the cubic rational-
# polynomial P/Q, and the QDEDR-refined final divide, reusing this
# file's own already-verified datan2_qdedr). A companion single-
# precision port (hal_tan_single, RUNASM/TAN.asm) was written and wired
# in at the same time for completeness, though not independently
# trace-verified the same way (no single-precision TAN divergence was
# ever reported). NOTE: GOOGLE-PARALLAX.hal's own FULL printed answer
# still differs from real gpc beyond TAN itself -- two SEPARATE,
# already-filed gaps (a literal DOUBLE argument passed directly to a
# BFNC call losing its own lsw before ever reaching TAN, and double-
# precision SSDV division not matching real hardware's own QDEDR-based
# algorithm) contribute additional divergence downstream of TAN's own
# now-correct result; this fixture sidesteps both by feeding TAN a
# COMPUTED (not literal) DOUBLE argument and WRITEing its own result
# directly (no further division).
run ./run_local_fixture.sh dtan_precision " 1.4805486979148472E-06"

# id 64 (yagpc2-yahalmat2-issues.db, 072-EXAMPLE_2.hal's own `RESULT2 =
# V_PRIME * E;`): a plain exact halmat_scalar_sub/multiply gave a
# subtly wrong result even for clean, exactly-representable integer
# inputs. Root-caused by reading RUNASM/VX6S3.asm (single) and
# RUNASM/VX6D3.asm (double) directly: DOUBLE's own MED (rounds each
# operand to 31 bits, hrfp_mulQeE) differs from an exact product;
# SINGLE's own subtraction is genuinely-extended SEDR despite being a
# single-precision routine. Fixed in interp.c's own OP_VCRS.
#
# id 73 (yagpc2-yahalmat2-issues.db, yahalmat2_vcrs_leak_model_should_
# match_corrected_rtl): OP_VCRS used to thread state->fpu.f1/f3 across
# the three per-component SEDR computations (F1 chaining forward, F3
# held fixed), faithfully matching VX6S3.asm's own historical behavior
# -- its own F0/F2 odd companions were never explicitly loaded before
# any SEDR, so they genuinely carried forward whatever a PRIOR
# floating-point-heavy RTL call left them as. That turned out to be a
# genuine, undetected RTL bug (same reasoning as id 53/72): the three
# cross-product components are mathematically INDEPENDENT, so a result
# depending on unrelated prior register history was never intentional.
# Fixed on the real RTL side via an &ASM101S-gated `SER F1,F1`/
# `SER F3,F3` pair before EACH SEDR (yaGPC2 commit cb63663cd) and here
# in OP_VCRS the same way -- both companions now freshly zeroed for
# every component, no chaining, nothing left to leak forward either.
# This fixture (isolated, no other floating-point-heavy call before it)
# confirmed bit-exact against a direct yaGPC2 run either way.
run ./run_local_fixture.sh vcrs_precision "-6.8000000E+01      1.3600000E+02     -6.8000000E+01"

# id 71 (yagpc2-yahalmat2-issues.db, unit_abval_not_wired_into_fpu_
# state_leak_model): UNIT/ABVAL (interp.c cases 27/28) compute their
# magnitude via a genuine ACALL into SQRT.asm (real RUNASM/VV9S3.asm,
# VV10S3.asm/VV10SN/VV9SN) -- hal_sqrt_single now threads `state->fpu`
# through (id 71's fix) so SQRT.asm's own leaked F1/F3 correctly
# propagates to whatever RTL-family call comes next. This fixture is
# 072-EXAMPLE_2.hal ("Programming in HAL-S" p. 72) verbatim -- the
# original repro id 71 was found from. Its own RESULT2 (the VCRS call
# immediately following UNIT) used to land on -6.7999985E+01 (real
# hardware's own F1/F3-garbage-perturbed answer, matching the OLD,
# unpatched VX6S3.asm) -- id 73's own fix means VCRS no longer reads
# ANY incoming companion state at all, so UNIT's own leak now has no
# effect on it whatsoever, and RESULT2 lands on the same mathematically
# clean -6.8000000E+01 vcrs_precision's own isolated fixture gives.
# Confirmed bit-exact against a direct yaGPC2 run (not gpc) either way.
run ./run_local_fixture.sh unit_vcrs_fpu_leak "$(printf 'V_PRIME=\n 1.4000000E+01      3.2000000E+01      5.0000000E+01\nRESULT1=\n 2.2953898E-01      5.2466059E-01      8.1978220E-01\nRESULT2=\n-6.8000000E+01      1.3600000E+02     -6.8000000E+01')"

# id 40 (yagpc2-yahalmat2-issues.db, long-open "architectural" item):
# X=RANDOM;Y=RANDOM;Z=X**2+Y**2;V=RANDOM; -- V (the RANDOM draw
# immediately after an intervening floating-point computation) diverged
# from real hardware in the low-order digits only. Two genuine, distinct
# fixes, found by first fixing the underlying arithmetic (verified via
# X/Y/Z all already matching, then V still wrong) and THEN getting a
# real yaGPC2 --trace to find the true remaining cause (a first,
# plausible-but-wrong guess -- hooking SADD's own result into the
# shared fpu.f1 leak state -- was empirically disproven by that same
# trace and removed):
#   (1) value.c's halmat_scalar_add/sub had NO guard-digit extra
#       precision during exponent alignment (an immediate, full-width
#       truncating right-shift) -- real hardware's own AE/AED algorithm
#       (hal_random.c's own hrfp_addsub, already verified for RANDOM/
#       EXP/LOG/TAN/VCRS) genuinely retains one extra hex digit of the
#       smaller operand's own fraction through the add itself. Fixed by
#       porting that same algorithm into halmat_scalar_add's own
#       alignment step.
#   (2) Even with (1) fixed, V was STILL wrong -- a real trace of this
#       exact repro showed `Y**2`'s own squaring (SPEX, a genuine
#       register-pair self-multiply reusing Y's own still-resident F0:F1
#       from the immediately-preceding RANDOM draw) is the LAST
#       operation to touch F0:F1 before the next RANDOM call -- the
#       FOLLOWING add's own result goes to a DIFFERENT register pair
#       (F2:F3) and never touches F0:F1 again. Fixed by hooking SPEX/
#       SIEX's own DOUBLE-precision result into the shared fpu.f1 leak
#       state instead of SADD/SSUB.
# Confirmed bit-exact against real gpc for this exact repro, AND
# re-confirmed the pre-existing 071-DARTBOARD_APPROXIMATION.hal
# aggregate cross-check (10000 RANDOM-pair draws, HIT/N) still matches
# bit-for-bit (3.1507998E+00) -- this fix doesn't just move the needle
# on a synthetic probe. Full regression suite passes, no regressions.
# NOTE: item (2)'s own fix is still only a narrow, trace-confirmed
# special case (a squaring whose own operand was just computed and
# still resident in F0:F1), not a general solution for arbitrary
# floating-point-op sequences between RANDOM calls -- which physical
# register pair any given HALMAT arithmetic result lands in is a
# genuine PASS2 register-allocation decision HALMAT's own IR doesn't
# expose. Left as a documented, narrower-scoped known gap rather than
# claimed fully general.
run ./run_local_fixture.sh random_f1_chain "$(printf ' 4.3794728815555573E-02\n 2.6276230812072754E-01\n 7.0962008840960209E-02\n 1.8242163863033056E-01')"

# id 68 (yagpc2-yahalmat2-issues.db, GOOGLE-PARALLAX.hal): a literal
# DOUBLE constant passed directly as a BFNC argument (or into an ARRAY
# element via INITIAL(...)) lost its own lsw precision -- resolve_
# operand's own QUAL_LIT default zeroes lsw unless the litfile's own
# type tag happens to be LIT_DOUBLE (unreliable), and neither OP_SINT's
# own plain-SYT write path nor xint_offset_run's own ARRAY-element path
# had the same literal-table re-derivation OP_SASN's own dest_sym
# coercion already uses (id 45/51) -- both fixed the same way now.
# Confirmed bit-exact against real gpc for both the plain-SCALAR
# (Y=TAN(X), X a DOUBLE literal-initialized variable) and ARRAY-element
# (A$1, ARRAY(2) SCALAR DOUBLE INITIAL(...)) cases.
run ./run_local_fixture.sh literal_double_precision "$(printf ' 1.1400000008460927E-06\n 1.1399999999999999E-06')"

# id 69 (yagpc2-yahalmat2-issues.db, GOOGLE-PARALLAX.hal): real
# hardware's own compiled code for a plain "/" between two DOUBLE
# scalars uses the QDEDR Newton-refined narrowing-divide macro (already
# ported once for DATAN2/DTAN's own final divide, hal_qdedr_double),
# confirmed via a real yaGPC2 --trace of this exact repro (a plain,
# unrelated C=A/B, no RTL call involved at all -- NOT scoped to
# "dividing by an RTL-call result" as first suspected) -- NOT a
# genuinely exact division the way value.c's own halmat_scalar_divide
# computes. A companion trace of a plain SINGLE-precision "/" confirmed
# that one compiles to a single plain DE instead, so SINGLE keeps using
# halmat_scalar_divide unchanged. Fixing this also closed the
# previously-documented residual gap in GOOGLE-PARALLAX.hal's own full
# comparison (see id 66/scalar_double's own updated comment) -- that
# repro is now bit-exact against real gpc end to end.
run ./run_local_fixture.sh ssdv_double_qdedr " 7.5330000802590851E+07"

# id 65 (yagpc2-yahalmat2-issues.db, 186-P.hal). Genuinely root-caused
# this time (2026-07-29): an earlier pass this session closed this as
# not_a_bug because a fresh `gpc` run also showed 5 trailing blanks --
# but `gpc` itself was wrong here (see feedback_gpc_not_authoritative
# memory), confirmed via yaGPC2 (this project's own actually-
# authoritative reference) showing genuinely zero trailing characters,
# and via a real instruction trace of RUNASM/CASV.asm ("CHARACTER
# ASSIGN") computing MIN(srcCurrLen, destMaxLen) -- srcCurrLen=0 for an
# empty CHARACTER, so the real algorithm never pads. Root cause was NOT
# a padding bug at all, despite how it looked: the string VALUE was
# already correctly empty at every step upstream (storage, WRITE-
# argument capture) -- dm_emit_field (interp.c) unconditionally
# reserved the inter-field separator's own blank-fill gap before EVERY
# WRITE item regardless of that item's own content length, and
# dm_write_at's own column-alignment gap-fill then wrote real blank
# bytes into that reserved gap; since a zero-length field's own text
# never occupies any of it, those separator blanks became the only
# visible output, indistinguishable from "padded to declared width".
# Fixed by making dm_emit_field skip entirely (no column advance, no
# separator consumed) for a zero-length field, matching real hardware
# treating it as contributing nothing to the output stream at all.
# Confirmed bit-exact against yaGPC2 for both the standalone (`WRITE(6)
# C2;`, C2 empty CHARACTER(5)) and mixed-item (`'C=', STATUS.C`) cases.
run ./run_local_fixture.sh empty_character_write "$(printf '\nB1=     0     C=')"

# yaGpcIntegration.h contract (yaGpcOps.c): two independently-initialized
# yaHALMAT2_ops instances, stepped with a deliberately uneven interleaving,
# must not leak state into each other -- see gpc_smoke_test.c.
run ./run_gpc_smoke.sh

# yaGpcIntegration.h contract (yaGpcOps.c): WRITE/READ actually flow
# through GpcOutputFn/GpcInputFn, purely via the GpcOps surface -- not
# just "does the program halt" (RELAY-TO-YAHALMAT2-TextIO.txt's own
# section 3). See gpc_textio_test.c.
run ./run_gpc_textio.sh

echo "============================"
if [ "$fail" -eq 0 ]; then
    echo "ALL TESTS PASSED"
else
    echo "SOME TESTS FAILED"
fi
exit $fail
