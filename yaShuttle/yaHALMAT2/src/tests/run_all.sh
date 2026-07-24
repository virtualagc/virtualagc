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
run ./run_fixture.sh discrete_for "RESULT=              63"
run ./run_fixture.sh case "RESULT=              20"    # reference tool's "30" is its own bug -- YERRORS.md
run ./run_fixture.sh nested "K=             150"        # reference tool's "40" is its own bug -- YERRORS.md
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
run ./run_ext_func_fixture.sh "$(printf '          1      1.0000000E+00      1.0000000E+00\n          2      4.0000000E+00      1.4142132E+00\n          3      9.0000000E+00      1.7320499E+00')" ext_mytable ext_square ext_squroo
run ./run_ext_func_fixture.sh "          5              10" ext_pcal_prog ext_double

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
run ./run_local_fixture.sh pcal "RESULT=              15"
run ./run_local_fixture.sh bit "I1=               8     I2=              14     I3=             -13"
run ./run_local_fixture.sh scalar_exp "$(printf ' 8.0000000E+00\n 8.0000000E+00\n 2.5000000E-01\n 1.4142132E+00')"
run ./run_local_fixture.sh matrix_sub "$(printf ' 5.0000000E+00\n 3.0000000E+00\n 4.0000000E+00')"
run ./run_local_fixture.sh matvec "$(printf ' 6.0000000E+00\n 8.0000000E+00\n 1.0000000E+01\n 1.2000000E+01\n 1.9000000E+01\n 2.2000000E+01\n 4.3000000E+01\n 5.0000000E+01')"
run ./run_local_fixture.sh vec "$(printf ' 3.2000000E+01\n-3.0000000E+00\n 6.0000000E+00\n-3.0000000E+00')"
run ./run_local_fixture.sh bit_conv "$(printf ' 1.2000000E+01\n12\nBEQU-TRUE\n         12')"
run ./run_local_fixture.sh init8 "$(printf '      43690\n 9.0000000E+00\n 9.0000000E+00\n 4.0000000E+00')"
run ./run_local_fixture.sh vshp "$(printf ' 1.0000000E+00\n 2.0000000E+00\n 3.0000000E+00')"
run ./run_local_fixture.sh bfnc "$(printf ' 1.4142132E+00\n 3.5000000E+00\n-1.0000000E+00\n 2.0000000E+00\n 5.0000000E+00')"
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
run ./run_local_fixture.sh errfix_matrix "$(printf -- ' 1.0000000E+00      0.0000000E+00\n 0.0000000E+00      1.0000000E+00\n 0.0000000E+00      0.0000000E+00      0.0000000E+00\n 7.0000000E+00      1.0000000E+01\n 1.5000000E+01      2.2000000E+01\n 1.0000000E+00      0.0000000E+00\n 0.0000000E+00      1.0000000E+00\n-1.9999990E+00      9.9999994E-01\n 1.5000000E+00     -4.9999994E-01\n 1.0000000E+00      0.0000000E+00\n 0.0000000E+00      1.0000000E+00\n 1.0000000E+00      2.0000000E+00\n 3.0000000E+00      4.0000000E+00')"
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
run ./run_local_fixture.sh eron_goto "$(printf -- 'BEFORE TRAP      1.0000000E+00      0.0000000E+00\n                 0.0000000E+00      1.0000000E+00\nAFTER ON ERROR\nAFTER SKIPPED LABEL\nAFTER RESTORE      1.0000000E+00      0.0000000E+00\n                   0.0000000E+00      1.0000000E+00')"
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
run ./run_local_fixture.sh errfix_scalar "$(printf -- ' 2.0000000E+00\n-7.2370051E+75\n 1.6094370E+00\n 7.2370051E+75\n 1.9999990E+00\n 0.0000000E+00\n 0.0000000E+00\n 0.0000000E+00')"
# Errors 11 (TAN |arg| too large -> 1), 8 (SIN/COS |arg| too large ->
# sqrt(2)/2), and 15 (SCALAR too large for INTEGER conversion -> the
# maximum representable value -- this emulator's own INT32 range, since
# INTEGER here is always a plain int32_t with no SINGLE/DOUBLE precision
# distinction modeled, unlike the primary source's 16-bit halfword
# default; see value.c's halmat_scalar_to_integer).
run ./run_local_fixture.sh errfix_trig "$(printf ' 1.0000000E+00\n 7.0710677E-01\n 7.0710677E-01\n 2147483647')"
run ./run_local_fixture.sh eron "I1=               1"
run ./run_local_fixture.sh subbit "$(printf '          5\n         42')"
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
# whole-ARRAY WRITE, which enumerates every element) sides.
run ./run_local_fixture.sh arrinit_types "$(printf 'AB     CD     EF\n          1               2               3')"
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
run ./run_local_fixture.sh matrix_identity_init "$(printf ' 1.0000000E+00      0.0000000E+00      0.0000000E+00\n 0.0000000E+00      1.0000000E+00      0.0000000E+00\n 0.0000000E+00      0.0000000E+00      1.0000000E+00')"
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
run ./run_local_fixture.sh matrix_identity5_init "$(printf ' 1.0000000E+00      0.0000000E+00      0.0000000E+00      0.0000000E+00      0.0000000E+00\n 0.0000000E+00      1.0000000E+00      0.0000000E+00      0.0000000E+00      0.0000000E+00\n 0.0000000E+00      0.0000000E+00      1.0000000E+00      0.0000000E+00      0.0000000E+00\n 0.0000000E+00      0.0000000E+00      0.0000000E+00      1.0000000E+00      0.0000000E+00\n 0.0000000E+00      0.0000000E+00      0.0000000E+00      0.0000000E+00      1.0000000E+00')" --line-length 200
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
run ./run_local_fixture.sh proc_matrix_arg "$(printf '      1.0000000E+00      0.0000000E+00      0.0000000E+00      0.0000000E+00      0.0000000E+00\n      0.0000000E+00      1.0000000E+00      0.0000000E+00      0.0000000E+00      0.0000000E+00\n      0.0000000E+00      0.0000000E+00      1.0000000E+00      0.0000000E+00      0.0000000E+00\n      0.0000000E+00      0.0000000E+00      0.0000000E+00      1.0000000E+00      0.0000000E+00\n      0.0000000E+00      0.0000000E+00      0.0000000E+00      0.0000000E+00      1.0000000E+00')" --line-length 200
# USA003087 Sec. 11.2/11.4's "precision conversion is allowed" MATRIX/
# VECTOR argument-transmission rule: a SINGLE MATRIX argument (A) passed
# to a DOUBLE parameter widens (scale_precision, the same exact bit-level
# rule STOS/MTOM/VTOV already use); a DOUBLE argument (B) passed to a
# SINGLE parameter narrows -- both directions bind by the *parameter's*
# own declared precision (dest_state's symbol table), not the argument's.
run ./run_local_fixture.sh proc_matrix_precision "$(printf ' 1.5000000000000000E+00      2.5000000000000000E+00\n 3.5000000000000000E+00      4.5000000000000000E+00\n 1.0500000E+01      2.0500000E+01\n 3.0500000E+01      4.0500000E+01')"
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
run ./run_local_fixture.sh nest_call "$(printf '      1.0000000E+00      0.0000000E+00      0.0000000E+00      0.0000000E+00      0.0000000E+00\n      0.0000000E+00      1.0000000E+00      0.0000000E+00      0.0000000E+00      0.0000000E+00\n      0.0000000E+00      0.0000000E+00      1.0000000E+00      0.0000000E+00      0.0000000E+00\n      0.0000000E+00      0.0000000E+00      0.0000000E+00      1.0000000E+00      0.0000000E+00\n      0.0000000E+00      0.0000000E+00      0.0000000E+00      0.0000000E+00      1.0000000E+00')" --line-length 200
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
# WRITE data-field line wrapping (USA003087 Sec. 12.2, "unpaged output:
# [80 columns/line]"): an 8-element VECTOR's fields total 8*19-5=147
# columns (14-col SCALAR field + 5-blank separator each, no leading
# separator on the first) -- wraps after 4 elements at the 80-column
# default, after 2 at an explicit --line-length 40.
run ./run_local_fixture.sh write_wrap "$(printf ' 1.0000000E+00      2.0000000E+00      3.0000000E+00      4.0000000E+00\n 5.0000000E+00      6.0000000E+00      7.0000000E+00      8.0000000E+00')"
run ./run_local_fixture.sh write_wrap "$(printf ' 1.0000000E+00      2.0000000E+00\n 3.0000000E+00      4.0000000E+00\n 5.0000000E+00      6.0000000E+00\n 7.0000000E+00      8.0000000E+00')" --line-length 40
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

echo "============================"
if [ "$fail" -eq 0 ]; then
    echo "ALL TESTS PASSED"
else
    echo "SOME TESTS FAILED"
fi
exit $fail
