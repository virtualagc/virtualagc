/* Needed (before any header pulls in <time.h> transitively) for
 * clock_gettime()/CLOCK_MONOTONIC/nanosleep() below (interp_run()'s
 * wall-clock pacing) -- POSIX.1-2008, not exposed under plain -std=c99
 * without this. No effect on _WIN32 (which takes the QueryPerformanceCounter/
 * Sleep() path instead). */
#ifndef _WIN32
#define _POSIX_C_SOURCE 200809L
#endif

#include "interp.h"

#include <ctype.h>
#include <errno.h>
#include <math.h>
#include <stdarg.h>
#include <stdlib.h>
#include <string.h>

#ifdef _WIN32
#include <windows.h>
#else
#include <signal.h>
#include <time.h>
#endif

#include "opcode_table.h"
#include "value.h"

/* Combined 12-bit class:opcode values for the instructions implemented so
 * far. Extended opcode-by-opcode as later fixtures require -- see
 * Plan.md M4. */
#define OP_NOP 0x000
#define OP_EXTN 0x001
#define OP_XREC 0x002
#define OP_SMRK 0x004
#define OP_PXRC 0x005
#define OP_IFHD 0x007
#define OP_LBL 0x008
#define OP_BRA 0x009
#define OP_FBRA 0x00A
#define OP_DCAS 0x00B
#define OP_ECAS 0x00C
#define OP_CLBL 0x00D
#define OP_ADLP 0x017
#define OP_IDLP 0x01A
#define OP_DLPE 0x018
#define OP_STRI 0x801
#define OP_SLRI 0x802
#define OP_ELRI 0x803
#define OP_ETRI 0x804
#define OP_IDEF 0x051
#define OP_ICLS 0x052
#define OP_IMRK 0x003
#define OP_TDCL 0x033
#define OP_UDEF 0x02E
#define OP_EINT 0x8E3
#define OP_PMHD 0x059
#define OP_PMAR 0x05A
#define OP_PMIN 0x05B
#define OP_DFOR 0x010
#define OP_EFOR 0x011
#define OP_CFOR 0x012
#define OP_DSMP 0x013
#define OP_ESMP 0x014
#define OP_AFOR 0x015
#define OP_DTST 0x00E
#define OP_ETST 0x00F
#define OP_CTST 0x016
#define OP_DSUB 0x019
#define OP_TSUB 0x01B
#define OP_FILE 0x022
#define OP_RDAL 0x020
#define OP_READ 0x01F
#define OP_WRIT 0x021
#define OP_ERON 0x03C
#define OP_ERSE 0x03D
#define OP_TNEQ 0x04D
#define OP_TEQU 0x04E
#define OP_TASN 0x04F
#define OP_NNEQ 0x055
#define OP_NEQU 0x056
#define OP_NASN 0x057
#define OP_MSHP 0x040
#define OP_VSHP 0x041
#define OP_SSHP 0x042
#define OP_ISHP 0x043
#define OP_BFNC 0x04A
#define OP_LFNC 0x04B
/* OP_LFNC (0x04B, MAX/MIN over an ARRAY) not implemented -- its argument
 * is bracketed by ADLP/DLPE (class-0/ADLP.md's "free arrayness" loop
 * markers), a distinct and substantially larger mechanism not built yet;
 * falls through to the default "not yet implemented" case. */
#define OP_SFST 0x045
#define OP_SFND 0x046
#define OP_SFAR 0x047
#define OP_XXST 0x025
#define OP_XXND 0x026
#define OP_XXAR 0x027
#define OP_TDEF 0x02A
#define OP_MDEF 0x02B
#define OP_CDEF 0x02F
#define OP_FDEF 0x02C
#define OP_PDEF 0x02D
#define OP_WAIT 0x034
#define OP_SGNL 0x035
#define OP_CANC 0x036
#define OP_TERM 0x037
#define OP_PRIO 0x038
#define OP_SCHD 0x039
#define OP_CLOS 0x030
#define OP_EDCL 0x031
#define OP_RTRN 0x032
#define OP_PCAL 0x01D
#define OP_FCAL 0x01E
#define OP_IASN 0x601
#define OP_SASN 0x501
#define OP_BASN 0x101
#define OP_BCAT 0x105
#define OP_BAND 0x102
#define OP_BOR 0x103
#define OP_BNOT 0x104
#define OP_ITOB 0x1C1
#define OP_BTOI 0x621
#define OP_BTOB 0x121
#define OP_BTOQ 0x122
#define OP_CTOB 0x141
#define OP_CTOQ 0x142
#define OP_STOQ 0x1A2
#define OP_ITOQ 0x1C2
#define OP_STOB 0x1A1
#define OP_BTOC 0x221
#define OP_BTOS 0x521
#define OP_ITOI 0x6C1
#define OP_BTRU 0x720
#define OP_BNEQ 0x725
#define OP_BEQU 0x726
#define OP_CASN 0x201
#define OP_CCAT 0x202
#define OP_CTOC 0x241
#define OP_STOC 0x2A1
#define OP_ITOC 0x2C1
#define OP_CTOS 0x541
#define OP_CTOI 0x641
#define OP_CNEQ 0x745
#define OP_CEQU 0x746
#define OP_CNGT 0x747
#define OP_CGT 0x748
#define OP_CNLT 0x749
#define OP_CLT 0x74A
#define OP_SNEQ 0x7A5
#define OP_SEQU 0x7A6
#define OP_SNGT 0x7A7
#define OP_SGT 0x7A8
#define OP_SNLT 0x7A9
#define OP_SLT 0x7AA
#define OP_CAND 0x7E2
#define OP_COR 0x7E3
#define OP_CNOT 0x7E4
#define OP_INEQ 0x7C5
#define OP_IEQU 0x7C6
#define OP_INGT 0x7C7
#define OP_IGT 0x7C8
#define OP_INLT 0x7C9
#define OP_ILT 0x7CA
#define OP_IADD 0x6CB
#define OP_ISUB 0x6CC
#define OP_IIPR 0x6CD
#define OP_INEG 0x6D0
#define OP_IPEX 0x6D2
#define OP_SADD 0x5AB
#define OP_SSUB 0x5AC
#define OP_SSPR 0x5AD
#define OP_SSDV 0x5AE
#define OP_MASN 0x301
#define OP_MTRA 0x329
#define OP_MINV 0x3CA
#define OP_MNEG 0x344
#define OP_MTOM 0x341
#define OP_MADD 0x362
#define OP_MSUB 0x363
#define OP_MMPR 0x368
#define OP_VVPR 0x387
#define OP_MSPR 0x3A5
#define OP_MSDV 0x3A6
#define OP_VASN 0x401
#define OP_VNEG 0x444
#define OP_VTOV 0x441
#define OP_MVPR 0x46C
#define OP_VMPR 0x46D
#define OP_VADD 0x482
#define OP_VSUB 0x483
#define OP_VCRS 0x48B
#define OP_VSPR 0x4A5
#define OP_VSDV 0x4A6
#define OP_VDOT 0x58E
#define OP_MNEQ 0x765
#define OP_MEQU 0x766
#define OP_VNEQ 0x785
#define OP_VEQU 0x786
#define OP_SIEX 0x571
#define OP_SPEX 0x572
#define OP_SEXP 0x5AF
#define OP_SNEG 0x5B0
#define OP_ITOS 0x5C1
#define OP_STOI 0x6A1
#define OP_STOS 0x5A1
#define OP_IINT 0x8C1
#define OP_SINT 0x8A1
#define OP_CINT 0x841
#define OP_TINT 0x8E2
#define OP_BINT 0x821
#define OP_MINT 0x861
#define OP_VINT 0x881
#define OP_NINT 0x8E1

#define NO_TARGET ((size_t)-1)

/* USA003090 Appendix C's group-4 "standard fixups" for arithmetic
 * runtime error conditions (execution-time errors detected by the HAL/S-
 * FC library and emitted code) -- see STATUS.md for the fuller citation
 * and per-error trace. Shared by BFNC's plain-SCALAR arithmetic
 * functions (EXP/LOG/SIN/COS/TAN/SQRT, errors 5-8/11-12) and SEXP/SPEX/
 * SIEX/IPEX's exponentiation opcodes (errors 4/24). */
/* (1 - 16**-6) * 16**63 -- the true maximum AP-101S SINGLE-precision
 * hex-float magnitude (all-1s 6-hex-digit fraction at the top
 * characteristic), matching the primary source's own "7.237 x 10**75"
 * to its stated precision. Deliberately NOT the rounder 16**63 itself:
 * halmat_scalar_from_double's normalization loop divides by 16 until
 * the mantissa drops below 1.0, so a value >= 16**63 costs one extra
 * division/characteristic-increment that then gets silently clamped
 * back to 127 without rescaling the mantissa -- producing a packed
 * result 16x too small. This value sits just under that boundary so
 * the loop lands exactly on characteristic=127 without tripping it. */
#define HAL_S_MAX_REPRESENTABLE 7.2370051459731155e75 /* errors 6/7/9/12 */
#define HAL_S_SIN_COS_OVERFLOW_RESULT 0.70710678118654752 /* sqrt(2)/2, error 8 */

/* USA003090 Appendix C's error grouping/numbering (page 199: "classified
 * as group 4 errors"; the table's own "ERROR NUMBER" column is the
 * member number within that group) -- ON ERROR's group:member operand
 * (state.h's halmat_error_handler_t) is specified against these same
 * numbers by a HAL/S program, e.g. `ON ERROR$(4:27) ...;`. One constant
 * per App. C error this interpreter actually implements the standard
 * fixup for (every one now also consults arithmetic_error_should_apply_
 * fixup() below before applying it, unlike the first session that wired
 * only error 27 through, per direct instruction to cover every listed
 * error, not just the one a bug report happened to exercise). */
#define HAL_S_ERROR_GROUP_ARITHMETIC 4
#define HAL_S_ERROR_ZERO_TO_NONPOSITIVE_POWER 4
#define HAL_S_ERROR_SQRT_NEGATIVE 5
#define HAL_S_ERROR_EXP_OVERFLOW 6
#define HAL_S_ERROR_LOG_NONPOSITIVE 7
#define HAL_S_ERROR_SIN_COS_OVERFLOW 8
#define HAL_S_ERROR_TAN_OVERFLOW 11
#define HAL_S_ERROR_TAN_SINGULARITY 12
#define HAL_S_ERROR_SCALAR_TO_INTEGER_OVERFLOW 15
#define HAL_S_ERROR_NEGATIVE_BASE_EXPONENT 24
#define HAL_S_ERROR_VECTOR_MATRIX_DIVIDE_BY_ZERO 25
#define HAL_S_ERROR_INVERSE_SINGULAR 27
#define HAL_S_ERROR_UNIT_NULL_VECTOR 28
#define HAL_S_ERROR_SINH_COSH_OVERFLOW 9
#define HAL_S_ERROR_ARCSIN_ARCCOS_DOMAIN 10
#define HAL_S_ERROR_REMAINDER_DIVIDE_BY_ZERO 16
#define HAL_S_ERROR_LJUST_RJUST_BAD_LENGTH 18
#define HAL_S_ERROR_MOD_DOMAIN 19
#define HAL_S_ERROR_MOD_MAGNITUDE 33
#define HAL_S_ERROR_ARCCOSH_DOMAIN 59
#define HAL_S_ERROR_ARCTANH_DOMAIN 60
#define HAL_S_ERROR_ARCTAN2_ZERO 62

/* Group 10, member 5: "the end of file error" -- confirmed directly
 * against the primary source, not the group-4 Appendix C arithmetic
 * catalog (which doesn't cover I/O at all): source-documentation/
 * ProgrammingInHALS.txt's own Sec. 10 ("Error Recovery"), discussing
 * this exact worked example (193-TEST_X.hal): "ON ERROR$(10:5) GO TO
 * DONE; This is an executable statement which establishes 'GO TO DONE;'
 * as a handler for the end of file error." -- verified twice over: the
 * book's own prose states it explicitly, and the real compiled HALMAT
 * for this exact program shows exactly one ERON registration with
 * group=10 (operand[0].data), member=5 (operand[0].tag1) -- matching
 * the book's `REPLACE IO BY "10"; ON ERROR$(IO:5) ...;` precisely (the
 * corpus .hal file's own duplicate-looking bare `ON ERROR GO TO DONE;`
 * line immediately before it is a transcription/OCR artifact -- the
 * real book page shows only the one `ON ERROR$(10:5)` statement, and
 * HALSFC compiles only one ERON either way). */
#define HAL_S_ERROR_GROUP_IO 10
#define HAL_S_ERROR_IO_END_OF_FILE 5

/* Strict C99 (this project's -std=c99) doesn't guarantee <math.h> defines
 * M_PI (a POSIX/BSD extension, hidden under -std=c99's stricter feature
 * visibility) -- BFNC's RANDOMG (selector 51, Box-Muller transform)
 * needs it, spelled out to full double precision rather than relying on
 * an unportable macro. */
#define HAL_S_PI 3.14159265358979323846

typedef enum { RV_STRING, RV_INTEGER, RV_SCALAR, RV_BITS } rv_kind_t;

typedef struct {
    rv_kind_t kind;
    char *string;   /* RV_STRING; borrowed from the literal table */
    int32_t integer; /* RV_INTEGER */
    halmat_scalar_t scalar; /* RV_SCALAR */
    uint32_t bits;   /* RV_BITS -- raw pattern, no declared-width tracking (see state.h) */
} resolved_value_t;

static int32_t rv_to_integer(const resolved_value_t *v) {
    if (v->kind == RV_SCALAR) return halmat_scalar_to_integer(v->scalar);
    if (v->kind == RV_BITS) return (int32_t)v->bits;
    return v->integer;
}

static halmat_scalar_t rv_to_scalar(const resolved_value_t *v) {
    if (v->kind == RV_SCALAR) return v->scalar;
    if (v->kind == RV_INTEGER) return halmat_scalar_from_integer(v->integer, false);
    return halmat_scalar_zero(false);
}

/* Stores a resolved_value_t into a VAC slot by its own kind (mirrors the
 * inline field-setting every other opcode does at its own ins->index,
 * factored out for OP_RTRN's inline-FUNCTION case, which needs to store
 * to a slot other than its own -- IDEF's, not RTRN's -- and must
 * preserve whatever type the inline function actually returns, unlike
 * the existing FCAL/RTRN path which always narrows to INTEGER). */
static char *dup_string(const char *s); /* forward-declared -- defined below, needed here for the RV_STRING case's own copy */
static bool reevaluate_live_bit_operand(halmat_state_t *state, const halmat_operand_t *op, uint32_t *out); /* forward-declared -- defined below (near sched_wake_on_events), needed here for OP_CLOS's own STOPPING WHILE/UNTIL <bit exp> check */
static void store_resolved_to_vac(halmat_vac_slot_t *slot, const resolved_value_t *val) {
    memset(slot, 0, sizeof(*slot));
    switch (val->kind) {
        case RV_SCALAR:
            slot->is_scalar = true;
            slot->scalar = val->scalar;
            break;
        case RV_STRING:
            slot->is_string = true;
            /* Copied, not borrowed -- unlike most other VAC-slot string
             * assignments in this file (which is why this function's own
             * every caller is a RETURN-value capture, not an ordinary
             * expression result), `val->string` here can be a pointer
             * *into* a same-unit callee's own local storage (e.g.
             * `RETURN YES$(TYPE:);`, YES a local `ARRAY(4) CHARACTER(5)`
             * -- resolve_operand's own char_elements read returns that
             * array's own element pointer directly, not a copy). Since a
             * same-unit call shares SYT storage with its caller
             * (dest_state == state) and HAL/S locals are AUTOMATIC
             * (re-initialized fresh on every call) by default, that same
             * storage gets freed and reallocated the *next* time this
             * same FUNCTION is called -- a real crash (use-after-free,
             * confirmed via ASan) when two calls to the same FUNCTION
             * appear in one WRITE statement's own argument list
             * (`WRITE(6) STATE(TRUE,1), STATE(FALSE,1);`, user-reported
             * via 158-STATE.hal): the first call's own returned string
             * gets freed out from under it by the second call's own
             * AUTOMATIC re-initialization, before flush_write ever reads
             * either one. */
            slot->string = dup_string(val->string);
            break;
        case RV_BITS:
            slot->is_bits = true;
            slot->bits = val->bits;
            break;
        default:
            slot->integer = val->integer;
            break;
    }
}

/* Precision-scale conversion for STOS/MTOM/VTOV's family (class-5/
 * STOS.md, class-3/MTOM.md, class-4/VTOV.md), per USA00309 Sec. 8.2's
 * confirmed bit-level rules: rule 12 (widening, single->double) pads 32
 * zero bits onto the mantissa's right; rule 7 (narrowing, double->
 * single) truncates the rightmost 32 bits. Since this project's
 * halmat_scalar_t already keeps lsw==0 for every single-precision value
 * (halmat_scalar_from_ibm_words, value.c), both directions reduce to
 * just flipping the double_precision flag (widening) or additionally
 * zeroing lsw (narrowing) -- no reconstruction through a native double
 * intermediate needed, so this is exact, not an approximation. */
static halmat_scalar_t scale_precision(halmat_scalar_t s, bool to_double) {
    s.double_precision = to_double;
    if (!to_double) s.lsw = 0;
    return s;
}

static void fail(halmat_state_t *state, const char *fmt, ...) {
    char buf[256];
    va_list ap;
    va_start(ap, fmt);
    vsnprintf(buf, sizeof(buf), fmt, ap);
    va_end(ap);
    fprintf(stderr, "yaHALMAT2: %s (at HALMAT word #%zu)\n", buf,
            state->prog->instrs[state->pc].index);
    state->halted = true;
    state->exit_code = 1;
}

/* Converts a resolved HAL/S numeric-seconds value (as produced by SCHD's
 * AT/IN/EVERY/AFTER/UNTIL-time arith exps, or WAIT's interval exp) to a
 * tick count via HALMAT_TICKS_PER_SECOND (state.h) -- multiplying the
 * *raw* seconds value (as a double) by the tick rate, then rounding once
 * at the end. Deliberately NOT implemented as rv_to_integer() followed
 * by a multiply: rv_to_integer() rounds a SCALAR to the nearest whole
 * number first (halmat_scalar_to_integer), which would round to the
 * nearest whole *second* before ever being scaled -- destroying
 * sub-second precision (WAIT(0.5) must become
 * round(0.5*HALMAT_TICKS_PER_SECOND) ticks, not round(0.5)=... seconds
 * first). `what` names the clause for fail()'s message (e.g. "SCHD: AT/IN",
 * "WAIT"). Fails loudly (via fail(), state->halted per this file's
 * established convention) and returns false if the tick count doesn't
 * fit in an int64_t, or -- when want_int32 is true -- doesn't fit in an
 * int32_t either. Only repeat_interval needs want_int32=true: it's the
 * one genuinely fixed-width int32_t field of halmat_task_t this value
 * ever gets narrowed into (state.h). at_in_value/stop_deadline/WAIT's
 * own tick count all flow into int64_t fields/locals (wake_deadline,
 * etc.) and pass want_int32=false accordingly -- none of them have a
 * real 32-bit ceiling to enforce, and at HALMAT_TICKS_PER_SECOND=276000,
 * an ordinary multi-thousand-second WAIT/AT/IN interval can legitimately
 * exceed INT32_MAX ticks without being any kind of error. */
static bool schd_seconds_to_ticks(halmat_state_t *state, const resolved_value_t *v,
                                   const char *what, bool want_int32, int64_t *out_ticks) {
    double seconds = (v->kind == RV_SCALAR) ? halmat_scalar_to_double(v->scalar)
                      : (v->kind == RV_BITS) ? (double)(int32_t)v->bits
                                              : (double)v->integer;
    double rounded = round(seconds * (double)HALMAT_TICKS_PER_SECOND);
    if (!(rounded >= (double)INT64_MIN && rounded <= (double)INT64_MAX)) {
        fail(state, "%s: %.6g seconds overflows a 64-bit tick count at %d ticks/second",
             what, seconds, HALMAT_TICKS_PER_SECOND);
        return false;
    }
    int64_t ticks = (int64_t)rounded;
    if (want_int32 && (ticks < INT32_MIN || ticks > INT32_MAX)) {
        fail(state, "%s: %.6g seconds (%lld ticks) overflows a 32-bit tick count at %d ticks/second",
             what, seconds, (long long)ticks, HALMAT_TICKS_PER_SECOND);
        return false;
    }
    *out_ticks = ticks;
    return true;
}

/* strdup is POSIX, not ISO C99 -- MSVC (Plan.md's cross-platform build
 * target) doesn't provide it under strict conformance either. */
static char *dup_string(const char *s) {
    size_t len = strlen(s) + 1;
    char *copy = malloc(len);
    if (copy) memcpy(copy, s, len);
    return copy;
}

/* Forward-declared: defined later in this file (needs HALMAT_CONTAINER_
 * CAPACITY-adjacent machinery), but resolve_operand/write_destination's
 * QUAL_SYT case (arrayed-paragraph-replay redirection, see state.h's
 * arrayed_index comment) needs it earlier in the file than its own
 * natural home alongside resolve_container/store_container_result. */
static void ensure_container(halmat_state_t *state, uint16_t syt_index);

/* Forward-declared for the same reason as ensure_container above --
 * OP_CLOS (inside exec_one, earlier in the file than the scheduler
 * helpers it's grouped with) needs it before its natural home alongside
 * sched_pick_next/sched_wake_waiting. See its own definition for the
 * USA003087 Sec. 13.3 "dependents" rule this implements. */
static bool has_active_dependents(const halmat_state_t *state, int parent_task_idx);

/* Shared by QUAL_SYT and QUAL_XPT (structure-field shadow slots, see
 * state.h's halmat_struct_field_t) -- both address the same shape of
 * storage, just keyed differently. */
static void read_syt_entry(const halmat_syt_entry_t *e, resolved_value_t *out) {
    if (e->type == SYT_TYPE_SCALAR) {
        out->kind = RV_SCALAR;
        out->scalar = e->scalar;
    } else if (e->type == SYT_TYPE_CHARACTER) {
        out->kind = RV_STRING;
        out->string = e->char_value ? e->char_value : "";
    } else if (e->type == SYT_TYPE_BIT) {
        out->kind = RV_BITS;
        out->bits = e->bit_value;
    } else {
        out->kind = RV_INTEGER;
        out->integer = e->value;
    }
}

/* The copy index for whatever structure-field touch is happening right
 * now (state.h's halmat_struct_field_t comment) -- state->arrayed_index
 * during an ADLP/DLPE-driven multi-copy replay, 0 for an ordinary
 * single-instance structure access outside one. */
static int32_t current_copy_index(halmat_state_t *state) {
    return state->arrayed_index >= 0 ? state->arrayed_index : 0;
}

/* Finds (or lazily creates) the shadow storage slot for a structure
 * field reference, keyed by (base_syt, field_syt, copy_index) -- see
 * state.h's halmat_struct_field_t comment for why this indirection
 * exists (field symbols are shared across every instance of a STRUCTURE
 * TEMPLATE, so field_syt alone can't be used as a direct storage key;
 * copy_index further distinguishes copies of a multiple-copy structure). */
static halmat_syt_entry_t *find_or_create_struct_field(halmat_state_t *state, uint16_t base_syt, uint16_t field_syt, int32_t copy_index) {
    for (size_t i = 0; i < state->struct_field_count; i++) {
        if (state->struct_fields[i].base_syt == base_syt && state->struct_fields[i].field_syt == field_syt &&
            state->struct_fields[i].copy_index == copy_index) {
            return &state->struct_fields[i].value;
        }
    }
    if (state->struct_field_count >= state->struct_field_capacity) {
        size_t new_cap = state->struct_field_capacity ? state->struct_field_capacity * 2 : 32;
        state->struct_fields = realloc(state->struct_fields, new_cap * sizeof(halmat_struct_field_t));
        state->struct_field_capacity = new_cap;
    }
    halmat_struct_field_t *slot = &state->struct_fields[state->struct_field_count++];
    memset(slot, 0, sizeof(*slot));
    slot->base_syt = base_syt;
    slot->field_syt = field_syt;
    slot->copy_index = copy_index;
    return &slot->value;
}

/* Maps a TINT run's flattened OFFSET "slot" index (class-8/TINT.md) back
 * to the structure terminal it belongs to, plus the element offset
 * within that terminal -- needed because a VECTOR terminal consumes
 * `cols` consecutive slots (one per component) instead of the single
 * slot a plain scalar/integer/bit terminal occupies, so slot index and
 * terminal-chain position diverge once a VECTOR terminal precedes the
 * target slot (170-OUTER.hal's `1 V VECTOR, 1 S1 SCALAR, ...`: slot 3
 * is S1, not the field 3 positions after the template, since V alone
 * consumes slots 0-2). Walks struct_first_field/struct_next_field
 * (symtab.h) summing each terminal's own slot width. Same conservative
 * hal_class==4 (VECTOR)-only scoping as the whole-structure READ/WRITE
 * terminal walk (task #62) -- MATRIX/ARRAY terminals aren't handled,
 * no confirmed real-corpus trigger yet. */
static bool tint_locate_slot(halmat_state_t *state, uint16_t template_syt, int slot, uint16_t *out_field_syt, int *out_elem, int *out_width) {
    if (!state->symtab) return false;
    int field_syt = -1;
    {
        const halmat_symtab_entry_t *tsym = halmat_symtab_find_by_index(state->symtab, template_syt);
        if (!tsym) return false;
        field_syt = tsym->struct_first_field;
    }
    int cursor = 0;
    while (field_syt >= 0) {
        const halmat_symtab_entry_t *fsym = halmat_symtab_find_by_index(state->symtab, (size_t)field_syt);
        if (!fsym) return false;
        int width = (fsym->hal_class == 4 && fsym->cols > 0) ? fsym->cols : 1;
        if (slot < cursor + width) {
            *out_field_syt = (uint16_t)field_syt;
            *out_elem = slot - cursor;
            *out_width = width;
            return true;
        }
        cursor += width;
        field_syt = fsym->struct_next_field;
    }
    return false;
}

/* Finds the active ON ERROR-registered handler for (group, member), or
 * NULL if none is registered (the default/SYSTEM "standard fixup"
 * applies -- USA003090 Appendix C). USA003087 Sec. 25.2's confirmed
 * precedence order: an exact group:member entry beats a group-only
 * entry beats an all-errors entry (halmat_error_handler_t's group/
 * member == -1 conventions, state.h). Only a flat/global table is
 * searched -- see halmat_error_handler_t's own comment on the missing
 * per-block dynamic-scoping rule. */
static halmat_error_handler_t *find_error_handler(halmat_state_t *state, int group, int member) {
    halmat_error_handler_t *exact = NULL, *by_group = NULL, *all = NULL;
    for (size_t i = 0; i < state->error_handler_count; i++) {
        halmat_error_handler_t *h = &state->error_handlers[i];
        if (h->group == group && h->member == member) exact = h;
        else if (h->group == group && h->member == -1) by_group = h;
        else if (h->group == -1) all = h;
    }
    if (exact) return exact;
    if (by_group) return by_group;
    return all;
}

/* Registers an ON ERROR modification for (group, member) -- USA003087
 * Sec. 25.2: re-registering the same specification replaces the
 * existing entry ("erasing memory of the previous recovery action")
 * rather than adding a second one. */
static void register_error_handler(halmat_state_t *state, int group, int member, halmat_error_action_t action, size_t goto_pc,
                                    bool has_event_action, uint16_t event_syt, halmat_error_event_action_t event_action) {
    for (size_t i = 0; i < state->error_handler_count; i++) {
        halmat_error_handler_t *h = &state->error_handlers[i];
        if (h->group == group && h->member == member) {
            h->action = action;
            h->goto_pc = goto_pc;
            h->has_event_action = has_event_action;
            h->event_syt = event_syt;
            h->event_action = event_action;
            return;
        }
    }
    if (state->error_handler_count >= state->error_handler_capacity) {
        size_t new_cap = state->error_handler_capacity ? state->error_handler_capacity * 2 : 8;
        state->error_handlers = realloc(state->error_handlers, new_cap * sizeof(halmat_error_handler_t));
        state->error_handler_capacity = new_cap;
    }
    halmat_error_handler_t *h = &state->error_handlers[state->error_handler_count++];
    h->group = group;
    h->member = member;
    h->action = action;
    h->goto_pc = goto_pc;
    h->has_event_action = has_event_action;
    h->event_syt = event_syt;
    h->event_action = event_action;
}

/* OFF ERROR (USA003087 Sec. 25.2): removes a previously-registered
 * modification with the same group:member specification, a no-op if
 * none exists. */
static void unregister_error_handler(halmat_state_t *state, int group, int member) {
    for (size_t i = 0; i < state->error_handler_count; i++) {
        if (state->error_handlers[i].group == group && state->error_handlers[i].member == member) {
            memmove(&state->error_handlers[i], &state->error_handlers[i + 1],
                    (state->error_handler_count - i - 1) * sizeof(halmat_error_handler_t));
            state->error_handler_count--;
            return;
        }
    }
}

/* Resolves a QUAL_XPT operand (class-0/EXTN.md's "extended pointer",
 * DATA=stream position of the resolving EXTN instruction) to its shadow
 * storage slot, for whichever copy is current (current_copy_index).
 * Fails loudly if the referenced VAC slot isn't actually an EXTN
 * result, or if it's a bare/unqualified reference (struct_field_
 * syt is the structure's own TEMPLATE symbol, not a real field --
 * TASN/TEQU/TNEQ handle that case themselves; this helper is only for
 * ordinary xASN-family opcodes reading/writing a single qualified
 * field). */
static halmat_syt_entry_t *resolve_xpt_field(halmat_state_t *state, const halmat_operand_t *op) {
    if (op->data >= HALMAT_VAC_MAX) {
        fail(state, "XPT stream position %u out of range", op->data);
        return NULL;
    }
    const halmat_vac_slot_t *slot = &state->vac[op->data];
    if (!slot->is_struct_ref) {
        fail(state, "XPT operand does not reference an EXTN result");
        return NULL;
    }
    int32_t copy_idx = slot->struct_copy_index >= 0 ? slot->struct_copy_index : current_copy_index(state);
    return find_or_create_struct_field(state, slot->struct_base_syt, slot->struct_field_syt, copy_idx);
}

/* True if the symbol table (state->symtab, unavailable e.g. for --py
 * units) confirms this SYT index is a declared ARRAY/VECTOR/MATRIX --
 * used by resolve_operand/write_destination's QUAL_SYT case to tell a
 * genuine whole-array reference (only valid inside an arrayed-paragraph
 * replay, state.h's arrayed_index) from an ordinary scalar/integer one. */
static bool syt_is_array_shaped(halmat_state_t *state, uint16_t syt_index) {
    if (!state->symtab) return false;
    const halmat_symtab_entry_t *sym = halmat_symtab_find_by_index(state->symtab, syt_index);
    return sym && (sym->shape == HALMAT_SHAPE_ARRAY || sym->shape == HALMAT_SHAPE_VECTOR || sym->shape == HALMAT_SHAPE_MATRIX);
}

/* Narrower than syt_is_array_shaped above -- true only for VECTOR/MATRIX,
 * excluding ARRAY. Used by write_destination's "null VECTOR/MATRIX"
 * special case just below, which is confirmed by [USA003087] Sec. 8.2
 * for VECTOR/MATRIX receivers specifically; ARRAY has no equivalent
 * documented idiom, so it's deliberately excluded rather than assumed to
 * work the same way. */
static bool syt_is_vector_or_matrix_shaped(halmat_state_t *state, uint16_t syt_index) {
    if (!state->symtab) return false;
    const halmat_symtab_entry_t *sym = halmat_symtab_find_by_index(state->symtab, syt_index);
    return sym && (sym->shape == HALMAT_SHAPE_VECTOR || sym->shape == HALMAT_SHAPE_MATRIX);
}

static bool resolve_operand(halmat_state_t *state, const halmat_operand_t *op, resolved_value_t *out) {
    memset(out, 0, sizeof(*out));
    switch (op->qual) {
        case QUAL_SYT: {
            if (op->data >= HALMAT_SYT_MAX) {
                fail(state, "SYT index %u out of range", op->data);
                return false;
            }
            if (syt_is_array_shaped(state, op->data)) {
                if (state->arrayed_index < 0) {
                    fail(state, "SYT index %u is a whole ARRAY/VECTOR/MATRIX referenced outside an arrayed-paragraph replay", op->data);
                    return false;
                }
                ensure_container(state, op->data);
                halmat_syt_entry_t *e = &state->syt[op->data];
                size_t idx = (size_t)state->arrayed_index % (e->element_count ? e->element_count : 1);
                if (e->bit_elements) {
                    out->kind = RV_BITS;
                    out->bits = e->bit_elements[idx];
                } else if (e->char_elements) {
                    out->kind = RV_STRING;
                    out->string = e->char_elements[idx];
                } else {
                    out->kind = RV_SCALAR;
                    out->scalar = e->elements[idx];
                }
                return true;
            }
            read_syt_entry(&state->syt[op->data], out);
            return true;
        }
        case QUAL_XPT: {
            const halmat_syt_entry_t *e = resolve_xpt_field(state, op);
            if (!e) return false;
            read_syt_entry(e, out);
            return true;
        }
        case QUAL_LIT: {
            if (!state->literals || op->data >= state->literals->count) {
                fail(state, "literal index %u out of range", op->data);
                return false;
            }
            const halmat_literal_t *lit = &state->literals->entries[op->data];
            if (lit->type == LIT_STRING) {
                out->kind = RV_STRING;
                out->string = lit->string;
            } else if (lit->type == LIT_FIXED || lit->type == LIT_DOUBLE) {
                /* Litfile numeric entries carry no INTEGER-vs-SCALAR
                 * distinction of their own (see literal.h) -- resolve as
                 * the exact bit-level SCALAR value; INTEGER-context
                 * consumers convert via rv_to_integer(). Callers that
                 * instead *store* this resolved value under a type tag
                 * (XXAR's CALL/WRITE argument binding, interp.c) can't
                 * rely on `out->kind` alone for that -- they reclassify
                 * using the operand's own tag1 (the HALMAT class the
                 * compiler actually recorded for it), the same signal
                 * XXAR's READ/READALL destination-class case already
                 * uses; see OP_XXAR's `integer_class_scalar` below. */
                out->kind = RV_SCALAR;
                out->scalar = halmat_scalar_from_ibm_words(lit->msw, lit->lsw, lit->type == LIT_DOUBLE);
            } else if (lit->type == LIT_BIT) {
                out->kind = RV_BITS;
                out->bits = lit->bits;
            } else {
                fail(state, "literal index %u has an unsupported type (%d) for this context",
                     op->data, (int)lit->type);
                return false;
            }
            return true;
        }
        case QUAL_IMD:
            out->kind = RV_INTEGER;
            out->integer = (int32_t)(int16_t)op->data; /* IMD is a signed 16-bit immediate */
            return true;
        case QUAL_VAC: {
            if (op->data >= HALMAT_VAC_MAX) {
                fail(state, "VAC index %u out of range", op->data);
                return false;
            }
            const halmat_vac_slot_t *slot = &state->vac[op->data];
            if (slot->is_ref) {
                if (slot->ref_syt >= HALMAT_SYT_MAX) {
                    fail(state, "VAC subscript reference SYT out of range");
                    return false;
                }
                const halmat_syt_entry_t *base = &state->syt[slot->ref_syt];
                if ((!base->elements && !base->bit_elements && !base->char_elements) ||
                    slot->ref_offset >= base->element_count) {
                    fail(state, "subscript reference out of range");
                    return false;
                }
                if (base->bit_elements) {
                    out->kind = RV_BITS;
                    out->bits = base->bit_elements[slot->ref_offset];
                } else if (base->char_elements) {
                    out->kind = RV_STRING;
                    out->string = base->char_elements[slot->ref_offset];
                } else {
                    out->kind = RV_SCALAR;
                    out->scalar = base->elements[slot->ref_offset];
                }
            } else if (slot->is_bitpart_ref) {
                /* Read side of a deferred BIT at-partition/single-index
                 * reference (state.h's is_bitpart_ref) -- reads the
                 * target SYT's *current* raw value (not whatever it held
                 * when the DSUB executed; matters when the same VAC slot
                 * is read after an intervening write to the same
                 * variable elsewhere), same MSB-first shift-and-mask
                 * extraction OP_DSUB's own read branches use. */
                if (slot->bitpart_target_syt >= HALMAT_SYT_MAX) {
                    fail(state, "VAC bitpart reference SYT out of range");
                    return false;
                }
                const halmat_syt_entry_t *tsyt = &state->syt[slot->bitpart_target_syt];
                uint32_t raw;
                switch (tsyt->type) {
                    case SYT_TYPE_BIT: raw = tsyt->bit_value; break;
                    case SYT_TYPE_INTEGER: raw = (uint32_t)tsyt->value; break;
                    case SYT_TYPE_SCALAR: raw = tsyt->scalar.msw; break;
                    default: raw = 0; break;
                }
                int decl_width = 32;
                if (state->symtab) {
                    const halmat_symtab_entry_t *bsym = halmat_symtab_find_by_index(state->symtab, slot->bitpart_target_syt);
                    if (bsym && bsym->bit_width > 0) decl_width = bsym->bit_width;
                }
                int shift = decl_width - slot->bitpart_position - slot->bitpart_width + 1;
                uint32_t mask = (slot->bitpart_width == 32) ? 0xFFFFFFFFu : ((1u << slot->bitpart_width) - 1u);
                out->kind = RV_BITS;
                out->bits = (shift >= 0) ? ((raw >> shift) & mask) : 0;
            } else if (slot->is_string) {
                out->kind = RV_STRING;
                out->string = slot->string ? slot->string : "";
            } else if (slot->is_bits) {
                out->kind = RV_BITS;
                out->bits = slot->bits;
            } else if (slot->is_scalar) {
                out->kind = RV_SCALAR;
                out->scalar = slot->scalar;
            } else if (slot->is_container) {
                /* A whole-container shaping-function result (VSHP/SSHP/
                 * ISHP/MSHP, or MADD/VADD/etc.) assigned element-by-
                 * element into a whole SCALAR/INTEGER ARRAY destination
                 * via a plain SASN/IASN -- ARRAY has no dedicated whole-
                 * container assign opcode of its own the way VECTOR/
                 * MATRIX get VASN/MASN (which read this same is_container
                 * slot via resolve_container instead, never reaching
                 * here), so HALSFC instead wraps the ordinary SASN/IASN
                 * in an ADLP/DLPE replay and re-executes it once per
                 * element -- confirmed empirically this session
                 * (`SA = SCALAR(S1, S2);`, SA a SCALAR ARRAY(2)): the
                 * SASN instruction genuinely appears only once in the
                 * HALMAT stream, immediately followed by what looks like
                 * an *empty* ADLP(2)/DLPE bracket in a plain linear
                 * listing, but this interpreter's own arrayed-paragraph
                 * replay mechanism re-enters and re-executes that
                 * preceding SASN once per array element, cycling
                 * arrayed_index 0,1 -- matching this function's own
                 * QUAL_SYT whole-array-during-replay case above, which
                 * already uses arrayed_index the same way. Before this
                 * fix, this branch didn't exist at all, so a container
                 * slot fell through to the plain-INTEGER default just
                 * below, silently reading whatever stale
                 * state->vac[...].integer happened to hold (0, since
                 * store_container_result never touches that field) --
                 * user-reported: SA ended up all zeros instead of
                 * S1/S2's actual values, no error at all. Only ever
                 * reached inside a replay in practice (arrayed_index
                 * picks which element) -- outside one there's no way to
                 * choose an element, so that's a genuine error rather
                 * than a default-to-zero guess. */
                if (state->arrayed_index < 0) {
                    fail(state, "VAC whole-container result referenced outside an arrayed-paragraph replay");
                    return false;
                }
                if (slot->container_count == 0) {
                    fail(state, "VAC whole-container result is empty");
                    return false;
                }
                size_t idx = (size_t)state->arrayed_index % slot->container_count;
                if (slot->container_is_integer) {
                    out->kind = RV_INTEGER;
                    out->integer = halmat_scalar_to_integer(slot->container[idx]);
                } else {
                    out->kind = RV_SCALAR;
                    out->scalar = slot->container[idx];
                }
            } else {
                out->kind = RV_INTEGER;
                out->integer = slot->integer;
            }
            return true;
        }
        default:
            fail(state, "operand qualifier %s not yet implemented in this context", halmat_qual_name(op->qual));
            return false;
    }
}

/* Assignment destination: a plain SYT slot (coerced to whichever of
 * INTEGER/SCALAR the destination already is, or established by this
 * first write -- matches the empirical finding that the assign opcode's
 * class tracks the *source*'s type, with any INTEGER<->SCALAR coercion
 * happening implicitly at the store, not via a separate conversion
 * opcode; see class-0/FCAL.md-adjacent notes and the out_array/
 * out_matrix fixtures), or a DSUB-produced subscript reference (ARRAY/
 * MATRIX element, always SCALAR for now -- see class-0/DSUB.md). */
/* Shared by QUAL_SYT and QUAL_XPT, mirroring read_syt_entry() above.
 * `dest_syt` is the SYT index `e` itself lives at, for the same
 * symtab-driven SINGLE/DOUBLE precision-normalization purpose
 * write_container_element() already uses it for -- HALMAT_SYT_MAX means
 * "no SYT index available" (the two structure-terminal call sites,
 * OP_TASN's own field write and TINT's whole-structure INITIAL()
 * population, neither of which this normalization has been extended to
 * yet; not known to be exercised by any real corpus file). */
static bool write_syt_entry(halmat_state_t *state, uint16_t dest_syt, halmat_syt_entry_t *e, const resolved_value_t *val) {
    if (e->type == SYT_TYPE_UNKNOWN) {
        e->type = (val->kind == RV_STRING) ? SYT_TYPE_CHARACTER
                : (val->kind == RV_BITS) ? SYT_TYPE_BIT
                : (val->kind == RV_SCALAR) ? SYT_TYPE_SCALAR : SYT_TYPE_INTEGER;
    }
    if (e->type == SYT_TYPE_CHARACTER) {
        if (val->kind != RV_STRING) {
            fail(state, "cannot assign a non-CHARACTER value to a CHARACTER destination");
            return false;
        }
        free(e->char_value);
        e->char_value = dup_string(val->string);
    } else if (e->type == SYT_TYPE_BIT) {
        if (val->kind != RV_BITS) {
            fail(state, "cannot assign a non-BIT value to a BIT destination");
            return false;
        }
        e->bit_value = val->bits;
    } else if (e->type == SYT_TYPE_SCALAR) {
        halmat_scalar_t sv = rv_to_scalar(val);
        /* User-caught while cross-checking a SUBBIT(SCALAR DOUBLE) fix:
         * a plain (non-array) SCALAR DOUBLE variable's INITIAL() literal
         * (SINT -> write_destination -> here) silently kept SINGLE
         * precision -- real HALSFC emits the shortest exact literal
         * encoding regardless of the destination's own declared
         * precision (2.5 compiles as a plain "Type FIXED"/SINGLE literal
         * even into a SCALAR DOUBLE target), and nothing here ever
         * normalized it up. OP_IASN/OP_SASN's own dest_sym coercion and
         * write_container_element() both already apply this same
         * symtab-driven scale_precision() fix at their own sites (this
         * session, and an earlier one respectively) -- this was the one
         * remaining plain-SCALAR-destination write path that had it,
         * confirmed via `DECLARE S SCALAR DOUBLE INITIAL(2.5); WRITE(6)
         * S;` printing in SINGLE format (7 significant digits) instead
         * of DOUBLE's 16. */
        if (dest_syt < HALMAT_SYT_MAX && state->symtab) {
            const halmat_symtab_entry_t *dsym = halmat_symtab_find_by_index(state->symtab, dest_syt);
            if (dsym && (dsym->flags & (HALMAT_SYM_FLAG_SINGLE | HALMAT_SYM_FLAG_DOUBLE))) {
                bool want_double = (dsym->flags & HALMAT_SYM_FLAG_DOUBLE) != 0;
                if (sv.double_precision != want_double) sv = scale_precision(sv, want_double);
            }
        }
        e->scalar = sv;
    } else {
        e->value = rv_to_integer(val);
    }
    return true;
}

/* Writes one resolved value into a container element (elements/
 * bit_elements/char_elements, state.h -- exactly one is non-NULL on a
 * given entry, per ensure_container()'s own dispatch), shared by
 * write_destination's QUAL_SYT/QUAL_VAC/QUAL_OFF array-element write
 * paths below. `idx` is assumed already in range. `dest_syt` is the
 * SYT index `e` itself lives at (every call site already has it handy)
 * -- needed only for the numeric-element precision lookup below, not
 * for indexing `e`. char_elements' strings are owned, so the old one is
 * freed before the new one is dup'd in, same convention as
 * write_syt_entry's SYT_TYPE_CHARACTER case for a non-subscripted
 * CHARACTER variable. A value/container kind mismatch (e.g. a BIT
 * literal into a numeric-only container, which happens when no symbol
 * table was available to tell ensure_container the real declared
 * element type -- see its own comment) fails loudly rather than
 * silently storing zero/corrupting. */
static bool write_container_element(halmat_state_t *state, uint16_t dest_syt, halmat_syt_entry_t *e, size_t idx, const resolved_value_t *val) {
    if (e->bit_elements) {
        if (val->kind != RV_BITS) {
            fail(state, "cannot assign a non-BIT value to a BIT ARRAY element");
            return false;
        }
        e->bit_elements[idx] = val->bits;
        return true;
    }
    if (e->char_elements) {
        if (val->kind != RV_STRING) {
            fail(state, "cannot assign a non-CHARACTER value to a CHARACTER ARRAY element");
            return false;
        }
        free(e->char_elements[idx]);
        e->char_elements[idx] = dup_string(val->string);
        return true;
    }
    if (val->kind == RV_BITS || val->kind == RV_STRING) {
        fail(state, "BIT/CHARACTER ARRAY element write with no symbol table available to determine element storage");
        return false;
    }
    /* Normalize to the ARRAY/VECTOR/MATRIX's own declared SINGLE/DOUBLE
     * precision (USA00309 Sec. 8.2 rules 7/12), user-reported
     * (107-EXAMPLE_4.hal's `DECLARE A ARRAY(5) SCALAR DOUBLE
     * INITIAL(1,2,3,4,5);`, then `A(T) = A(T+1);` element-to-element
     * shifts): neither a literal (single-precision-encoded in litfile,
     * literal.c) nor an ordinary expression result is otherwise tagged
     * to the *container's* declared precision anywhere upstream, so
     * without this, elements populated via INITIAL() or a plain
     * element-to-element copy silently stayed single-precision --
     * printing with single-precision (8-significant-digit) formatting
     * instead of double's 17 -- while only an element that happened to
     * pass through an *already-correctly-normalized* plain SCALAR
     * DOUBLE variable (this file's own `TEMP`) picked up the right
     * precision, incidentally. Exact same rule, and same rationale, as
     * the plain (non-subscripted) SCALAR destination case already
     * applied in OP_IASN/OP_SASN's own dest_sym lookup -- this is that
     * fix's container-element counterpart, applied at the one shared
     * choke point every numeric container write already funnels
     * through, so it covers every caller (element assign, DSUB-element-
     * to-element copy, and STRI/SINT's own ARRAY INITIAL() population)
     * in one place rather than needing a fix at each one. */
    halmat_scalar_t sv = rv_to_scalar(val);
    if (state->symtab) {
        const halmat_symtab_entry_t *dsym = halmat_symtab_find_by_index(state->symtab, dest_syt);
        if (dsym && (dsym->flags & (HALMAT_SYM_FLAG_SINGLE | HALMAT_SYM_FLAG_DOUBLE))) {
            bool want_double = (dsym->flags & HALMAT_SYM_FLAG_DOUBLE) != 0;
            if (sv.double_precision != want_double) sv = scale_precision(sv, want_double);
        }
    }
    e->elements[idx] = sv;
    return true;
}

static bool write_destination(halmat_state_t *state, const halmat_operand_t *op, const resolved_value_t *val) {
    if (op->qual == QUAL_SYT) {
        if (op->data >= HALMAT_SYT_MAX) {
            fail(state, "SYT index %u out of range", op->data);
            return false;
        }
        if (syt_is_array_shaped(state, op->data)) {
            if (state->arrayed_index < 0) {
                /* [USA003087] Sec. 8.2 rule 3 (MATRIX) / rule 3 (VECTOR):
                 * "The only condition under which the R-type is integer
                 * is if it is the literal value zero. The assignment
                 * then creates a null matrix [vector]" -- e.g. `M3 = 0;`/
                 * `V2 = 0;` zero every element in one shot; any other
                 * integer/scalar value (`M3 = 1;`) is illegal and
                 * rejected by the real compiler, so it's never expected
                 * to reach here. This is genuinely different from an
                 * arrayed-paragraph replay's per-element write (which
                 * still requires arrayed_index >= 0 below) -- it compiles
                 * as one plain IASN/SASN with the whole VECTOR/MATRIX SYT
                 * as the receiver, no ADLP wrapping at all, confirmed
                 * against real compiled HALMAT (039-CORNERS.hal's
                 * `AB = 0;`, AB a VECTOR(2) -- user-reported). IASN's own
                 * OP_IASN normalization (this file) always yields
                 * RV_INTEGER for a whole-number literal regardless of the
                 * receiver's real declared type, which is how a VECTOR
                 * receiver ends up going through plain IASN rather than
                 * VASN here. ARRAY has no documented equivalent, so it's
                 * excluded (syt_is_vector_or_matrix_shaped) and still
                 * falls through to the fail() below. */
                bool is_zero = (val->kind == RV_INTEGER && val->integer == 0) ||
                                (val->kind == RV_SCALAR && halmat_scalar_to_double(val->scalar) == 0.0);
                if (is_zero && syt_is_vector_or_matrix_shaped(state, op->data)) {
                    ensure_container(state, op->data);
                    halmat_syt_entry_t *e = &state->syt[op->data];
                    for (size_t i = 0; i < e->element_count; i++) {
                        e->elements[i] = halmat_scalar_zero(e->elements[i].double_precision);
                    }
                    return true;
                }
                fail(state, "SYT index %u is a whole ARRAY/VECTOR/MATRIX referenced outside an arrayed-paragraph replay", op->data);
                return false;
            }
            ensure_container(state, op->data);
            halmat_syt_entry_t *e = &state->syt[op->data];
            size_t idx = (size_t)state->arrayed_index % (e->element_count ? e->element_count : 1);
            return write_container_element(state, op->data, e, idx, val);
        }
        return write_syt_entry(state, op->data, &state->syt[op->data], val);
    }
    if (op->qual == QUAL_XPT) {
        halmat_syt_entry_t *e = resolve_xpt_field(state, op);
        if (!e) return false;
        return write_syt_entry(state, HALMAT_SYT_MAX, e, val);
    }
    if (op->qual == QUAL_VAC) {
        if (op->data >= HALMAT_VAC_MAX) {
            fail(state, "VAC index %u out of range", op->data);
            return false;
        }
        halmat_vac_slot_t *slot = &state->vac[op->data];
        if (slot->is_subbit_ref) {
            /* SUBBIT(x) = ...; (class-1/ITOQ.md's assignment-context
             * form, OP_ITOQ/BTOQ/CTOQ/STOQ's TAG=1 case above) -- writes
             * `val`'s raw bit pattern directly into x's own storage,
             * bypassing ordinary type coercion (val is already guaranteed
             * RV_BITS here: BASN, the only opcode that ever consumes this
             * kind of slot, checks that before calling write_destination
             * at all). SYT_TYPE_INTEGER/BIT/SCALAR(SINGLE) all have a
             * confirmed, lossless raw-bit-pattern representation this
             * interpreter already models bit-for-bit (BIT trivially;
             * INTEGER via the same reinterpret-cast the reference-context
             * branch above already uses in the opposite direction;
             * SINGLE-precision SCALAR because this project's own SCALAR
             * representation, halmat_scalar_t, already stores the exact
             * AP-101S/IBM hex-float wire format rather than a native
             * double -- its `msw` field genuinely *is* the argument's own
             * 32-bit in-memory pattern, direct user correction of an
             * earlier wrong "needs IEEE-754 modeling" excuse here).
             * DOUBLE-precision SCALAR's real width is 64 bits (msw+lsw),
             * wider than this interpreter's uint32_t bits/RV_BITS
             * representation supports anywhere (a project-wide ceiling on
             * every BIT value, not SUBBIT-specific) -- fails loudly.
             * CHARACTER also still fails loudly, but for a different,
             * more specific reason than SCALAR ever did: per direct user
             * clarification, real AP-101S CHARACTER storage is a fixed
             * 2-byte length header (declared max, current) plus N
             * EBCDIC-encoded bytes, left-justified -- this interpreter's
             * own char_value/char_elements are plain malloc'd, growable,
             * already-ASCII-decoded C strings (state.h's own char_value
             * comment: "the string just grows/shrinks to fit whatever's
             * assigned," no fixed-width/VARYING truncation modeled at
             * all, class-2/CASN.md's own longstanding Unresolved
             * Question) -- there is no byte layout to reinterpret bits
             * into or out of at all, a genuinely deeper and separate gap
             * from SCALAR's, not just an unwritten switch-case. */
            if (slot->subbit_target_syt >= HALMAT_SYT_MAX) {
                fail(state, "SUBBIT assignment: target SYT out of range");
                return false;
            }
            halmat_syt_entry_t *e = &state->syt[slot->subbit_target_syt];
            halmat_syt_type_t subbit_type = e->type;
            bool dest_double_precision = (subbit_type == SYT_TYPE_SCALAR) && e->scalar.double_precision;
            if (subbit_type == SYT_TYPE_UNKNOWN && state->symtab) {
                /* SUBBIT deliberately bypasses write_syt_entry's ordinary
                 * first-write type inference (it writes a bit pattern into
                 * an *already, if only declaratively, typed* variable's
                 * storage, not a value whose kind should itself dictate
                 * the type) -- so a target never written before this point
                 * still has e->type==UNKNOWN even though its real type was
                 * fixed at DECLARE time. Consult the symbol table for the
                 * declared class instead, same hal_class convention
                 * ensure_container() and IASN/SASN's own dest_sym lookup
                 * already use (1=BIT, 5=SCALAR, 6=INTEGER). */
                const halmat_symtab_entry_t *dsym = halmat_symtab_find_by_index(state->symtab, slot->subbit_target_syt);
                if (dsym && dsym->hal_class == 6) subbit_type = SYT_TYPE_INTEGER;
                else if (dsym && dsym->hal_class == 1) subbit_type = SYT_TYPE_BIT;
                else if (dsym && dsym->hal_class == 5) {
                    subbit_type = SYT_TYPE_SCALAR;
                    dest_double_precision = (dsym->flags & HALMAT_SYM_FLAG_DOUBLE) != 0;
                }
            }
            if (subbit_type == SYT_TYPE_INTEGER) {
                e->type = SYT_TYPE_INTEGER;
                e->value = (int32_t)val->bits;
                return true;
            }
            if (subbit_type == SYT_TYPE_BIT) {
                e->type = SYT_TYPE_BIT;
                e->bit_value = val->bits;
                return true;
            }
            if (subbit_type == SYT_TYPE_SCALAR) {
                if (dest_double_precision) {
                    fail(state, "SUBBIT assignment: DOUBLE-precision SCALAR target needs a 64-bit bit-pattern window, "
                                "wider than this interpreter's BIT value representation supports");
                    return false;
                }
                e->type = SYT_TYPE_SCALAR;
                e->scalar = halmat_scalar_from_ibm_words(val->bits, 0, false);
                return true;
            }
            fail(state, "SUBBIT assignment: target type has no confirmed raw-bit-pattern mapping (only INTEGER/BIT/SINGLE-precision SCALAR are implemented)");
            return false;
        }
        if (slot->is_bitpart_ref) {
            /* Write-through side of a deferred BIT at-partition/single-
             * index reference (state.h's is_bitpart_ref) -- merges `val`'s
             * bits into the target SYT's *current* raw pattern at the
             * fixed (position, width) resolved back when the producing
             * DSUB executed, preserving every other bit and the target's
             * own declared type. User-reported, 250-BITS.hal's
             * `B$(1) = ON;` (`B` a plain `BIT(8)`). */
            if (slot->bitpart_target_syt >= HALMAT_SYT_MAX) {
                fail(state, "BIT at-partition assignment: target SYT out of range");
                return false;
            }
            if (val->kind != RV_BITS) {
                fail(state, "BIT at-partition assignment: source is not BIT");
                return false;
            }
            halmat_syt_entry_t *e = &state->syt[slot->bitpart_target_syt];
            uint32_t raw;
            switch (e->type) {
                case SYT_TYPE_BIT: raw = e->bit_value; break;
                case SYT_TYPE_INTEGER: raw = (uint32_t)e->value; break;
                case SYT_TYPE_SCALAR: raw = e->scalar.msw; break;
                default: raw = 0; break;
            }
            int decl_width = 32;
            if (state->symtab) {
                const halmat_symtab_entry_t *bsym = halmat_symtab_find_by_index(state->symtab, slot->bitpart_target_syt);
                if (bsym && bsym->bit_width > 0) decl_width = bsym->bit_width;
            }
            int width = slot->bitpart_width;
            int shift = decl_width - slot->bitpart_position - width + 1;
            if (shift >= 0) {
                uint32_t mask = (width == 32) ? 0xFFFFFFFFu : ((1u << width) - 1u);
                raw = (raw & ~(mask << shift)) | ((val->bits & mask) << shift);
            }
            switch (e->type) {
                case SYT_TYPE_BIT: e->bit_value = raw; break;
                case SYT_TYPE_INTEGER: e->value = (int32_t)raw; break;
                case SYT_TYPE_SCALAR: e->scalar.msw = raw; break;
                default:
                    /* Never written before -- default to BIT, matching
                     * this same target's own declared class if the
                     * variable really is a BIT string (the overwhelmingly
                     * common case for this construct). */
                    e->type = SYT_TYPE_BIT;
                    e->bit_value = raw;
                    break;
            }
            return true;
        }
        if (slot->is_container_ref) {
            /* Plain-scalar write into one element of a row/column/vector
             * container-reference slot (DSUB's asterisk-partition case,
             * state.h's is_container_ref) via an ordinary SASN/IASN,
             * *not* MASN/VASN's own whole-container-at-once path just
             * below (which bypasses write_destination entirely) --
             * state.h's own is_container_ref comment already notes ARRAY
             * has no dedicated whole-container assign opcode the way
             * VECTOR/MATRIX get VASN/MASN, so HALSFC instead wraps a
             * plain SASN/IASN in an ADLP/DLPE replay and re-executes it
             * once per element, cycling arrayed_index -- the exact
             * mirror of resolve_operand's own is_container replay-read
             * case, just for the write side. User-reported,
             * 112-EXAMPLE_6.hal's `ATT_RATE(DEVICE,*) = GYRO_INPUT
             * (DEVICE,*) * SCALE + BIAS;` (`ATT_RATE`/`GYRO_INPUT` both
             * ARRAY(4,3)): previously fell into the generic "not a
             * subscript reference" fallback below, since only MASN/VASN
             * consulted is_container_ref at all. */
            if (state->arrayed_index < 0) {
                fail(state, "container-reference assignment used outside an arrayed-paragraph replay");
                return false;
            }
            if (slot->container_ref_syt >= HALMAT_SYT_MAX) {
                fail(state, "container-reference assignment: SYT index out of range");
                return false;
            }
            halmat_syt_entry_t *rbase = &state->syt[slot->container_ref_syt];
            size_t idx = slot->container_ref_offset + (size_t)state->arrayed_index * slot->container_ref_stride;
            if (!rbase->elements || idx >= rbase->element_count) {
                fail(state, "container-reference assignment out of range");
                return false;
            }
            return write_container_element(state, slot->container_ref_syt, rbase, idx, val);
        }
        if (!slot->is_ref) {
            fail(state, "assignment destination is not a subscript reference");
            return false;
        }
        if (slot->ref_syt >= HALMAT_SYT_MAX) {
            fail(state, "VAC subscript reference SYT out of range");
            return false;
        }
        halmat_syt_entry_t *base = &state->syt[slot->ref_syt];
        if ((!base->elements && !base->bit_elements && !base->char_elements) ||
            slot->ref_offset >= base->element_count) {
            fail(state, "subscript destination out of range");
            return false;
        }
        return write_container_element(state, slot->ref_syt, base, slot->ref_offset, val);
    }
    if (op->qual == QUAL_OFF) {
        /* OFFSET-addressed element write, used by SINT inside a
         * STRI/.../ETRI repeated-initialize group (class-8/STRI.md,
         * SLRI.md). Two sub-cases share this one path (see OP_SINT's own
         * comment for how they're told apart and why the same formula
         * covers both): inside an SLRI-driven `n#value` replay, op->data
         * is always observed as 0 and state->arrayed_index (the
         * SLRI-driven paragraph-replay counter, same mechanism ADLP/IDLP
         * use for QUAL_SYT redirection -- see interp_step) supplies the
         * whole index; outside any replay (arrayed_index still -1, the
         * explicit-literal-list `VECTOR INITIAL(10,11,12)` form, no SLRI
         * at all -- confirmed empirically this session), op->data is
         * itself the run's absolute/cumulative target element offset, so
         * it's used alone. The target symbol itself isn't carried by
         * this operand at all; it comes from the most recently executed
         * STRI (state->stri_target_syt). */
        if (state->stri_target_syt < 0 || state->stri_target_syt >= HALMAT_SYT_MAX) {
            fail(state, "QUAL_OFF destination used without a preceding STRI");
            return false;
        }
        int32_t base = state->arrayed_index >= 0 ? state->arrayed_index : 0;
        uint16_t base_syt = (uint16_t)state->stri_target_syt;
        ensure_container(state, base_syt);
        halmat_syt_entry_t *e = &state->syt[base_syt];
        size_t idx = (size_t)(base + (int32_t)op->data) % (e->element_count ? e->element_count : 1);
        return write_container_element(state, base_syt, e, idx, val);
    }
    fail(state, "unsupported assignment destination qualifier %s", halmat_qual_name(op->qual));
    return false;
}

/* Shared OFFSET-addressed run-length write for the class-8 `xINT`
 * family's OFFSET-addressed form (SINT/BINT/CINT -- see OP_SINT's own
 * comment for the full disambiguation between this form's two
 * sub-cases: the `n#value` uniform-repeat case, where this loop is a
 * no-op since tag1 is always 1 and the repetition instead comes from an
 * enclosing SLRI-driven arrayed-paragraph replay; and the explicit-
 * literal-list case, where tag1 itself carries the run length). Each
 * resolved literal is passed to write_destination in its own native
 * kind (RV_SCALAR/RV_BITS/RV_STRING, whichever resolve_operand's
 * QUAL_LIT case produced for that literal's real stored type) rather
 * than being coerced -- write_container_element (above) dispatches on
 * that kind against the target container's own allocated storage kind
 * (elements/bit_elements/char_elements, state.h), so a mismatch (e.g. a
 * numeric literal run landing on a CHARACTER ARRAY) fails loudly there
 * rather than silently corrupting. */
static bool xint_offset_run(halmat_state_t *state, const halmat_instr_t *ins) {
    int run_count = ins->operands[1].tag1 > 0 ? ins->operands[1].tag1 : 1;
    for (int k = 0; k < run_count; k++) {
        halmat_operand_t lit_op = ins->operands[1];
        lit_op.data = (uint16_t)(ins->operands[1].data + k);
        resolved_value_t rv;
        if (!resolve_operand(state, &lit_op, &rv)) return false;
        halmat_operand_t off_op = ins->operands[0];
        off_op.data = (uint16_t)(ins->operands[0].data + k);
        if (!write_destination(state, &off_op, &rv)) return false;
    }
    return true;
}

/* Lazily allocates a SYT slot's ARRAY/MATRIX/VECTOR element storage
 * (idempotent -- returns immediately if already allocated), sizing it
 * from the symbol table's declared dimensions when available (state->
 * symtab, see symtab.h) and falling back to the generic placeholder
 * capacity otherwise (HALMAT_CONTAINER_CAPACITY's comment, state.h).
 * Sets rows/cols too, which DSUB/MASN-family opcodes use to tell a
 * real declared MATRIX shape from the unknown-shape fallback.
 *
 * Picks which of elements/bit_elements/char_elements (state.h) to
 * allocate from the symbol table's declared ARRAY element type
 * (hal_class 1=BIT, 2=CHARACTER, confirmed empirically against real
 * compiled ARRAY(n) BIT/CHARACTER declarations this session --
 * everything else, including MATRIX/VECTOR, which are always numeric in
 * HAL/S, defaults to the numeric `elements` form). Without a symbol
 * table (e.g. --py mode) the element type can't be known, so this
 * always falls back to numeric -- callers that need a BIT/CHARACTER
 * container in that situation fail loudly (see write_destination's
 * QUAL_OFF case) rather than silently misinterpreting numeric storage
 * as a bit pattern or string. */
static void ensure_container(halmat_state_t *state, uint16_t syt_index) {
    halmat_syt_entry_t *e = &state->syt[syt_index];
    if (e->elements || e->bit_elements || e->char_elements) return;

    int rows = 0, cols = 0;
    size_t count = 0;
    int elem_kind = 0; /* 0=numeric, 1=BIT, 2=CHARACTER */
    bool array_of_vector = false;
    if (state->symtab) {
        const halmat_symtab_entry_t *sym = halmat_symtab_find_by_index(state->symtab, syt_index);
        if (sym && sym->shape == HALMAT_SHAPE_MATRIX && sym->rows > 0 && sym->cols > 0) {
            rows = sym->rows;
            cols = sym->cols;
            count = (size_t)rows * (size_t)cols;
        } else if (sym && sym->shape == HALMAT_SHAPE_VECTOR && sym->cols > 0) {
            cols = sym->cols;
            count = (size_t)cols;
        } else if (sym && sym->shape == HALMAT_SHAPE_ARRAY && sym->array_dim_count == 1 &&
                   sym->hal_class == 4 && sym->cols > 0 && sym->array_dims[0] > 0) {
            /* ARRAY(n) VECTOR(m) -- an ARRAY-of-VECTOR, not a true MATRIX,
             * but stored identically (row-major, n*m elements: n groups of
             * m) and subscripted the same way for the "one plain index +
             * one asterisk" case (`V(N)`/`POSITIONS$(I:*)`, DSUB's own
             * `base->rows > 0` branch below picks this up for free, same
             * as the 2D-ARRAY-of-SCALAR case above) -- confirmed
             * user-reported, 117-EXAMPLE_8.hal (`POSITIONS ARRAY(5)
             * VECTOR`, indexed as `POSITIONS$(I:*)`; symtab.c's own fix
             * decodes SYM_LENGTH into sym->cols here even though
             * SYM_ARRAY made shape==ARRAY, same as the MATRIX/VECTOR
             * branches just above). Previously fell through to the
             * generic single-dimension branch below, which read only
             * array_dims[0] (5) as the *whole* element count, discarding
             * the VECTOR's own 3 components entirely and undersizing the
             * container by 3x -- silent corruption, not just DSUB's loud
             * "asterisk subscript with 2 indices not yet implemented"
             * failure. Also flagged array_of_vector (state.h) so
             * resolve_container() knows to slice by arrayed_index during
             * an ADLP/DLPE-driven whole-array-expression replay
             * (`[VELOCITY] = ([POSITIONS] - [OLD_POSN]) / DELTA_T;`),
             * rather than treating this like a real MATRIX. ARRAY-of-
             * MATRIX isn't handled here (no confirmed real-corpus case
             * yet) -- deliberately scoped to hal_class==4 (VECTOR) only,
             * same conservative "exactly this shape, not a guess at the
             * generalization" precedent as the 2D-ARRAY fix. */
            rows = sym->array_dims[0];
            cols = sym->cols;
            count = (size_t)rows * (size_t)cols;
            array_of_vector = true;
        } else if (sym && sym->shape == HALMAT_SHAPE_ARRAY && sym->array_dim_count == 2 &&
                   sym->array_dims[0] > 0 && sym->array_dims[1] > 0) {
            /* Genuinely 2-dimensional ARRAY(r,c) -- HAL/S allows
             * subscripting one exactly like MATRIX (row-major storage,
             * 2-index/asterisk-partition/at-partition access), confirmed
             * user-reported via 107-EXAMPLE_3.hal (`DECLARE ARRAY(3,3),
             * M1, M2, M3;`, subscripted throughout as `M1(ROW,COL)` and
             * `M1$(ROW,*)`). Setting rows/cols here (the same fields
             * HALMAT_SHAPE_MATRIX uses) is what lets DSUB's existing
             * `base->rows > 0` MATRIX-shaped logic pick this up for free
             * -- previously left rows==cols==0 for *any* ARRAY shape
             * (only array_dims[0] was ever read, silently discarding a
             * second dimension entirely), which broke two different
             * things: DSUB's 2-index asterisk-partition case failed
             * loudly ("asterisk subscript with 2 indices not yet
             * implemented"), and -- more seriously, no error at all --
             * the *plain* 2-index case (`M1(ROW,COL) = ...;`) silently
             * fell through to the generic placeholder-stride fallback
             * (`offset*16+idx`) instead of real row-major addressing
             * (`row*cols+col`), corrupting every element write throughout
             * the whole matrix-multiply loop. 3+ dimensional ARRAYs don't
             * get this treatment -- MATRIX's own 2-index convention has
             * no defined generalization beyond 2D, so they still fall
             * through to the single-dimension/placeholder-stride path
             * below, unchanged. */
            rows = sym->array_dims[0];
            cols = sym->array_dims[1];
            count = (size_t)rows * (size_t)cols;
            if (sym->hal_class == 1) elem_kind = 1;
            else if (sym->hal_class == 2) elem_kind = 2;
        } else if (sym && sym->shape == HALMAT_SHAPE_ARRAY && sym->array_dim_count >= 1 &&
                   sym->array_dims[0] < 0) {
            /* `ARRAY(*)` assumed-size parameter (USA003087 Sec. 7.5/20.11):
             * its own DECLARE inside the procedure/function body carries no
             * real size at all -- symtab.c's own comment on this same
             * sentinel (a negative 16-bit EXT_ARRAY dimension-bound entry,
             * confirmed against two independent real-corpus cases,
             * 140-STATISTICS.hal and 141-VSUM.hal, with two *different*
             * negative magnitudes -- "any negative value," not one fixed
             * constant) -- so there is nothing to allocate here at all.
             * Left entirely unallocated (elements/element_count/etc. all
             * stay at their zero-initialized default) -- bind_call_
             * argument() detects this exact state (`!pe->elements`) and
             * allocates the real container sized from the *caller's own*
             * actual argument shape instead, the only place a size is
             * ever actually known for this kind of parameter. If this
             * function is reached for an assumed-size parameter that
             * hasn't been bound by a call yet (shouldn't happen for valid
             * HALMAT -- every parameter is bound before the callee's own
             * body starts running), the caller of ensure_container() will
             * simply see a NULL/zero-length container, the same as any
             * other genuinely-unbound-yet SYT entry. */
            return;
        } else if (sym && sym->shape == HALMAT_SHAPE_ARRAY && sym->array_dim_count >= 1 &&
                   sym->array_dims[0] > 0) {
            count = (size_t)sym->array_dims[0]; /* only a single dimension is used -- see symtab.h */
            if (sym->hal_class == 1) elem_kind = 1;
            else if (sym->hal_class == 2) elem_kind = 2;
        }
    }
    if (count == 0) count = HALMAT_CONTAINER_CAPACITY;

    if (elem_kind == 1) {
        e->bit_elements = calloc(count, sizeof(uint32_t));
    } else if (elem_kind == 2) {
        e->char_elements = calloc(count, sizeof(char *));
        for (size_t i = 0; i < count; i++) e->char_elements[i] = dup_string("");
    } else {
        e->elements = calloc(count, sizeof(halmat_scalar_t));
    }
    e->element_count = count;
    e->rows = rows;
    e->cols = cols;
    e->array_of_vector = array_of_vector;
}

/* Matrix inverse (MINV, class-3/MINV.md; BFNC's INVERSE selector), via
 * ordinary double-precision Gauss-Jordan elimination with partial
 * pivoting. No specific inversion algorithm is mandated by the primary
 * sources -- only that INVERSE/MINV compute a genuine matrix inverse --
 * so this doesn't attempt bit-exact matching against whatever routine
 * the original compiler's runtime library used, and goes through double
 * (via halmat_scalar_to_double/from_double) rather than genuine hex-
 * float arithmetic, the same documented precision compromise as SEXP.
 * n is capped at 8 (n*n <= HALMAT_CONTAINER_CAPACITY=64, this
 * interpreter's generic container-size ceiling elsewhere). Returns
 * false for a singular (or n>8) matrix -- a genuine runtime ERROR
 * CONDITION under HAL/S's error model, not a value to silently
 * substitute (same disposition as SSDV's divide-by-zero), though the
 * exact USA003090 Appendix C response text wasn't available to consult
 * in this session -- the caller fail()s loudly rather than guessing at
 * that wording. */
static bool matrix_invert(const halmat_scalar_t *in, int n, halmat_scalar_t *out) {
    if (n <= 0 || n > 8) return false;
    double aug[8][16];
    for (int i = 0; i < n; i++) {
        for (int j = 0; j < n; j++) aug[i][j] = halmat_scalar_to_double(in[i * n + j]);
        for (int j = 0; j < n; j++) aug[i][n + j] = (i == j) ? 1.0 : 0.0;
    }
    for (int col = 0; col < n; col++) {
        int pivot = col;
        double best = fabs(aug[col][col]);
        for (int r = col + 1; r < n; r++) {
            if (fabs(aug[r][col]) > best) { best = fabs(aug[r][col]); pivot = r; }
        }
        if (best < 1e-12) return false; /* singular */
        if (pivot != col) {
            for (int j = 0; j < 2 * n; j++) { double t = aug[col][j]; aug[col][j] = aug[pivot][j]; aug[pivot][j] = t; }
        }
        double pv = aug[col][col];
        for (int j = 0; j < 2 * n; j++) aug[col][j] /= pv;
        for (int r = 0; r < n; r++) {
            if (r == col) continue;
            double factor = aug[r][col];
            for (int j = 0; j < 2 * n; j++) aug[r][j] -= factor * aug[col][j];
        }
    }
    bool dbl = false;
    for (int i = 0; i < n * n; i++) {
        if (in[i].double_precision) { dbl = true; break; }
    }
    for (int i = 0; i < n; i++)
        for (int j = 0; j < n; j++)
            out[i * n + j] = halmat_scalar_from_double(aug[i][n + j], dbl);
    return true;
}

/* USA003090 App. C error 27's standard fixup ("argument of INVERSE is a
 * singular matrix" -> "the result is the identity matrix"), shared by
 * both real HAL/S spellings of matrix inverse -- BFNC's INVERSE selector
 * and MINV's `M**(-1)` exponentiation form -- since both route through
 * matrix_invert() and hit the identical singular-matrix case. `in` only
 * supplies the elements' SINGLE/DOUBLE precision (the identity's own
 * value doesn't depend on the singular matrix's contents). */
static void fill_identity_matrix(const halmat_scalar_t *in, int n, halmat_scalar_t *out) {
    bool dbl = false;
    for (int i = 0; i < n * n; i++) {
        if (in[i].double_precision) { dbl = true; break; }
    }
    for (int r = 0; r < n; r++)
        for (int c = 0; c < n; c++)
            out[r * n + c] = (r == c) ? halmat_scalar_from_integer(1, dbl) : halmat_scalar_zero(dbl);
}

/* Consults the ON ERROR table (state.h's halmat_error_handler_t, OP_ERON)
 * for group-4 (USA003090 Appendix C) `member` on a fixup-eligible
 * runtime error -- shared by every App. C "standard fixup" call site
 * this interpreter implements. If a GOTO handler is registered,
 * redirects `*pc`/`*branched` there and returns false -- the caller must
 * not write any result (the interrupted assignment/expression never
 * completes, matching USA003087 Sec. 25.2 Figure 25-3) and should just
 * `break` out of its own case without producing a value. Otherwise
 * (SYSTEM, IGNORE, or no handler -- see OP_ERON's own comment on
 * IGNORE's unconfirmed exact semantics here) returns true: the caller
 * should apply its own standard fixup and continue as before. */
static bool arithmetic_error_should_apply_fixup(halmat_state_t *state, int member, size_t *pc, bool *branched) {
    /* ERRGRP/ERRNUM (BFNC selectors 38/39, state.h's last_error_group/
     * last_error_member comment): every group-4 error this interpreter
     * detects funnels through this one function, whether or not a
     * fixup/GOTO ends up applying -- "last error detected" per
     * [USA003087] Appendix B means detected, not merely unhandled. */
    state->last_error_group = HAL_S_ERROR_GROUP_ARITHMETIC;
    state->last_error_member = member;
    halmat_error_handler_t *h = find_error_handler(state, HAL_S_ERROR_GROUP_ARITHMETIC, member);
    if (h && h->has_event_action && h->event_syt < HALMAT_SYT_MAX) {
        /* ERON's `AND SET/RESET/SIGNAL var` clause (class-0/ERON.md):
         * applied here, at the one place that actually detects a matching
         * error, regardless of which of GOTO/SYSTEM/IGNORE the main
         * action is (though in practice only SYSTEM/IGNORE ever carry an
         * event action -- the user-statement/GOTO form has no such clause
         * in the grammar). SET and SIGNAL are both modeled as the same
         * direct BIT write OP_SGNL itself uses (bit_value=1) -- this
         * interpreter doesn't model the persistent/latched-vs-transient
         * distinction between them (see OP_SGNL's own comment); RESET is
         * the same write with 0 instead of 1. */
        halmat_syt_entry_t *e = &state->syt[h->event_syt];
        e->type = SYT_TYPE_BIT;
        e->bit_value = (h->event_action == HALMAT_EVENT_RESET) ? 0 : 1;
    }
    if (h && h->action == HALMAT_ERRACT_GOTO) {
        *pc = h->goto_pc;
        *branched = true;
        return false;
    }
    return true;
}

/* Resolves one DSUB to-partition subscript bound (class-0/DSUB.md), an
 * ordinary literal/SYT/VAC-qualified value or the `#`-relative CSZ form
 * (`C(1 TO #-DECIMALS)`, 160-REFORMAT.hal) -- advances `*oi` past
 * whatever operand(s) it consumed: 1 for an ordinary bound, 2 for CSZ
 * (DSUB.md's confirmed "CSZ operand optionally followed by one
 * subsidiary operand word" shape -- controlled-compile-confirmed via
 * `C1(2 TO # - 2)`, which produces exactly `DATA`=2 with a literal `2`
 * subsidiary immediately after). `declared_len` is the CHARACTER base's
 * own current working length -- HAL/S's own `#` value for this context
 * (USA003087's "current working length L", not a fixed declared
 * maximum).
 *
 * `DATA`=0 is a bare `#` (no subsidiary). `DATA`=2 is confirmed as
 * `# − subsidiary` via the controlled compile above. `DATA`=1 (`# +
 * subsidiary`) is inferred purely by symmetry with the primary source's
 * own documented formula ("tag = 1 + expression, or 2 − expression")
 * and has never been independently observed in any real or synthetic
 * trace -- implemented anyway since the encoding is otherwise self-
 * consistent, but if a real corpus program ever exercises it and
 * disagrees, this inference (not the confirmed `DATA`=2 case) is where
 * to look first. */
static bool resolve_to_partition_bound(halmat_state_t *state, const halmat_instr_t *ins, uint8_t *oi, int32_t declared_len, int32_t *out) {
    if (*oi >= ins->operand_count) { fail(state, "DSUB: to-partition bound operand missing"); return false; }
    if (ins->operands[*oi].qual == QUAL_CSZ) {
        uint16_t data = ins->operands[*oi].data;
        (*oi)++;
        if (data == 0) { *out = declared_len; return true; }
        if (*oi >= ins->operand_count) { fail(state, "DSUB: CSZ missing subsidiary operand"); return false; }
        resolved_value_t av;
        if (!resolve_operand(state, &ins->operands[*oi], &av)) return false;
        int32_t adj = rv_to_integer(&av);
        (*oi)++;
        if (data == 1) { *out = declared_len + adj; return true; }
        if (data == 2) { *out = declared_len - adj; return true; }
        fail(state, "DSUB: CSZ unsupported DATA=%u", data);
        return false;
    }
    resolved_value_t v;
    if (!resolve_operand(state, &ins->operands[*oi], &v)) return false;
    *out = rv_to_integer(&v);
    (*oi)++;
    return true;
}

/* Redirects to a registered `ON ERROR$(10:5) ...;` (or a broader by-
 * group/catch-all) handler for READ's own end-of-file condition --
 * user-reported, 193-TEST_X.hal's `ON ERROR$(IO:5) GO TO DONE;` guarding
 * a `DO WHILE TRUE; READ(5) ...; END;` loop meant to run until input is
 * exhausted: this previously always aborted via fail() on the first
 * end-of-file, regardless of any registered handler. Mirrors
 * arithmetic_error_should_apply_fixup()'s own established GOTO-redirect
 * shape (pc/branched out-parameters, same as OP_ERON's other consumer)
 * but returns a plain bool (redirected or not) rather than
 * "should the caller apply some fallback" -- there's no I/O-error
 * equivalent of an arithmetic standard fixup to fall back to; the
 * caller's only alternative when this returns false is its own ordinary
 * fail(). Deliberately narrow: only READ's genuine end-of-file case
 * (fscanf returning EOF) should ever be classified this specifically;
 * a malformed-but-present value is a different condition this project
 * has no primary-source classification for, but the two aren't
 * distinguished by the caller today (see this function's own call
 * sites) -- matches this interpreter's existing combined "end of input
 * or malformed" error message, not a new gap introduced here. */
static bool io_error_redirect_on_eof(halmat_state_t *state, size_t *pc, bool *branched) {
    halmat_error_handler_t *h = find_error_handler(state, HAL_S_ERROR_GROUP_IO, HAL_S_ERROR_IO_END_OF_FILE);
    if (h && h->action == HALMAT_ERRACT_GOTO) {
        *pc = h->goto_pc;
        *branched = true;
        return true;
    }
    return false;
}

/* Square n x n matrix product, out = a * b -- shared by OP_MMPR (below)
 * and OP_MINV's repeated-self-multiplication exponentiation (M**N, N>1
 * or N<-1). `out` must not alias `a` or `b`. */
static void matrix_multiply_square(const halmat_scalar_t *a, const halmat_scalar_t *b, int n, halmat_scalar_t *out) {
    for (int i = 0; i < n; i++) {
        for (int j = 0; j < n; j++) {
            halmat_scalar_t sum = halmat_scalar_zero(false);
            for (int k = 0; k < n; k++) sum = halmat_scalar_add(sum, halmat_scalar_multiply(a[i * n + k], b[k * n + j]));
            out[i * n + j] = sum;
        }
    }
}

/* Matrix determinant (DET, BFNC selector 3 -- class-0/BFNC.md). Same
 * double-precision Gaussian elimination with partial pivoting as
 * matrix_invert just above (no bit-exact algorithm mandated by the
 * primary sources), tracking the running product of pivots and the sign
 * flip from each partial-pivot row swap. n capped at 8, same container-
 * size ceiling as matrix_invert; unlike INVERSE, a singular matrix isn't
 * a HAL/S error condition here -- DET of a singular matrix is simply
 * 0.0, so this returns that instead of failing. */
static halmat_scalar_t matrix_determinant(const halmat_scalar_t *in, int n, bool dbl) {
    double aug[8][8];
    for (int i = 0; i < n; i++)
        for (int j = 0; j < n; j++) aug[i][j] = halmat_scalar_to_double(in[i * n + j]);
    double det = 1.0;
    for (int col = 0; col < n; col++) {
        int pivot = col;
        double best = fabs(aug[col][col]);
        for (int r = col + 1; r < n; r++) {
            if (fabs(aug[r][col]) > best) { best = fabs(aug[r][col]); pivot = r; }
        }
        if (best < 1e-12) return halmat_scalar_from_double(0.0, dbl); /* singular -> DET is 0 */
        if (pivot != col) {
            for (int j = col; j < n; j++) { double t = aug[col][j]; aug[col][j] = aug[pivot][j]; aug[pivot][j] = t; }
            det = -det;
        }
        double pv = aug[col][col];
        det *= pv;
        for (int r = col + 1; r < n; r++) {
            double factor = aug[r][col] / pv;
            for (int j = col; j < n; j++) aug[r][j] -= factor * aug[col][j];
        }
    }
    return halmat_scalar_from_double(det, dbl);
}

/* Advances state->rng_state's Park-Miller "minimal standard" Lehmer
 * generator (state.h's own comment on the algorithm/reproducibility
 * rationale) and returns the next draw in [0,1). Shared by BFNC's
 * RANDOM/RANDOMG cases below. */
static double next_random_uniform(halmat_state_t *state) {
    state->rng_state = (uint32_t)(((uint64_t)state->rng_state * 16807u) % 2147483647u);
    return (double)state->rng_state / 2147483647.0;
}

/* Reads a whole MATRIX/VECTOR operand (SYT variable or a VAC-carried
 * intermediate result, e.g. a prior MADD/VADD -- class-3/MADD.md's "no
 * destination operand, consumed by a following MASN via a VAC-qualified
 * operand" pattern applies to every MATRIX/VECTOR arithmetic opcode).
 * Does not copy -- the returned pointer aliases the SYT/VAC slot's own
 * storage, valid until that slot is next written. */
static bool resolve_container(halmat_state_t *state, const halmat_operand_t *op,
                               halmat_scalar_t **out_elems, size_t *out_count, int *out_rows, int *out_cols) {
    if (op->qual == QUAL_SYT) {
        if (op->data >= HALMAT_SYT_MAX) { fail(state, "SYT index %u out of range", op->data); return false; }
        ensure_container(state, op->data);
        halmat_syt_entry_t *e = &state->syt[op->data];
        /* An ARRAY-of-VECTOR operand (state.h's array_of_vector comment)
         * inside an ADLP/DLPE-driven whole-array-expression replay
         * resolves to just the *one* VECTOR at the current arrayed_index,
         * not the whole flat container -- user-reported, 117-EXAMPLE_8.hal
         * (`ABVAL([POSITIONS] - MY_POSN)`, POSITIONS an ARRAY(5) VECTOR,
         * MY_POSN a plain VECTOR(3): each replay must pair MY_POSN's full
         * 3 elements against exactly one of POSITIONS' 5 VECTORs, not all
         * 15 at once). Outside a replay (arrayed_index < 0) falls through
         * to the whole-container form below, unchanged. */
        if (e->array_of_vector && state->arrayed_index >= 0 && e->rows > 0) {
            size_t i = (size_t)state->arrayed_index % (size_t)e->rows;
            *out_elems = &e->elements[i * (size_t)e->cols];
            *out_count = (size_t)e->cols;
            *out_rows = 0;
            *out_cols = e->cols;
            return true;
        }
        *out_elems = e->elements;
        *out_count = e->element_count;
        *out_rows = e->rows;
        *out_cols = e->cols;
        return true;
    }
    if (op->qual == QUAL_VAC) {
        if (op->data >= HALMAT_VAC_MAX) { fail(state, "VAC index %u out of range", op->data); return false; }
        halmat_vac_slot_t *slot = &state->vac[op->data];
        if (!slot->is_container) { fail(state, "operand is not a MATRIX/VECTOR intermediate result"); return false; }
        *out_elems = slot->container;
        *out_count = slot->container_count;
        *out_rows = slot->container_rows;
        *out_cols = slot->container_cols;
        return true;
    }
    if (op->qual == QUAL_XPT) {
        /* A qualified structure-field reference (e.g. `X.V`, V a VECTOR
         * terminal) that happens to be VECTOR/MATRIX-shaped -- distinct
         * from a bare/unqualified whole-structure reference (state.h's
         * dest_is_structure/is_structure comments, which walk the whole
         * template field chain instead): resolve_xpt_field() already
         * returns the *one* target field's own shadow entry directly,
         * with the identical elements/rows/cols shape every plain
         * VECTOR/MATRIX SYT entry uses, so no extra unraveling is
         * needed here. User-reported (172-OUTER.hal's `RETURN X.V;`,
         * X a STRUCTURE-typed FUNCTION parameter). */
        halmat_syt_entry_t *e = resolve_xpt_field(state, op);
        if (!e) return false;
        *out_elems = e->elements;
        *out_count = e->element_count;
        *out_rows = e->rows;
        *out_cols = e->cols;
        return true;
    }
    fail(state, "unsupported MATRIX/VECTOR operand qualifier %s", halmat_qual_name(op->qual));
    return false;
}

/* Unravels one shaping-function argument (SFAR, class-0/SFAR.md) into
 * `out`'s flat result buffer, per [USA003088] Sec. 6.6's general <arith
 * conversion> rule 3: "[t]he data elements in each <expression> are
 * unraveled in their natural sequence... The result of doing this for
 * each argument in turn is a single linear string of data elements[,
 * which] is then reformed or 'reraveled' to generate the result." A
 * whole VECTOR/MATRIX/ARRAY argument (VECTOR/MATRIX's own rule 5:
 * "VECTOR and MATRIX may have arguments of integer, scalar, vector, and
 * matrix types only") contributes its own element_count elements in
 * natural order; anything else (a plain scalar/integer expression, the
 * only case VSHP/SSHP/ISHP/MSHP's callers previously assumed
 * exclusively) contributes exactly one. Shared by OP_VSHP/SSHP/ISHP/MSHP
 * below -- confirmed necessary for MSHP specifically (`MATRIX(X, Y, Z)`,
 * each of X/Y/Z a whole VECTOR, 044-ORTHONORMAL.hal, user-reported), but
 * the same unraveling rule is written generally for all four shaping
 * functions, not just MSHP, so it isn't special-cased to MSHP alone.
 * Returns the number of elements appended (0 on failure -- fail() is
 * already called; genuinely zero-element arguments don't occur in this
 * grammar, so 0 is an unambiguous error sentinel). */
static size_t unravel_shaping_argument(halmat_state_t *state, const halmat_operand_t *op,
                                        halmat_scalar_t *out, size_t out_capacity, size_t out_used) {
    bool whole_syt = op->qual == QUAL_SYT && syt_is_array_shaped(state, op->data);
    bool whole_vac = op->qual == QUAL_VAC && op->data < HALMAT_VAC_MAX && state->vac[op->data].is_container;
    if (whole_syt || whole_vac) {
        halmat_scalar_t *elems; size_t count; int rows, cols;
        if (!resolve_container(state, op, &elems, &count, &rows, &cols)) return 0;
        if (out_used + count > out_capacity) { fail(state, "shaping function: result too large"); return 0; }
        memcpy(&out[out_used], elems, count * sizeof(halmat_scalar_t));
        return count;
    }
    resolved_value_t item;
    if (!resolve_operand(state, op, &item)) return 0;
    if (out_used + 1 > out_capacity) { fail(state, "shaping function: result too large"); return 0; }
    out[out_used] = rv_to_scalar(&item);
    return 1;
}

/* Ensures state->io_pending.items has room for at least one more entry
 * (i.e. index [item_count]), growing it (realloc-doubling, starting from
 * 16 -- HALMAT_MAX_OPERANDS' own old value, now just the initial size
 * rather than a hard ceiling) as needed -- see halmat_io_item_t's own
 * comment (state.h) for why a plain fixed-size array sized to
 * HALMAT_MAX_OPERANDS (a real HALMAT *instruction's* own small operand-
 * count bound, not a real limit on how many WRITE/CALL data items one
 * statement can have) was wrong. Capped at 255 (item_count's own uint8_t
 * range) as a sanity ceiling -- fails loudly rather than silently
 * wrapping if ever actually reached, which no confirmed corpus program
 * has (134-DOTS.hal's own worst case needs 20). */
static bool io_pending_reserve_item(halmat_state_t *state) {
    if (state->io_pending.item_count >= 255) {
        fail(state, "I/O statement has too many items");
        return false;
    }
    if ((size_t)state->io_pending.item_count >= state->io_pending.items_capacity) {
        size_t new_cap = state->io_pending.items_capacity ? state->io_pending.items_capacity * 2 : HALMAT_MAX_OPERANDS;
        if (new_cap > 255) new_cap = 255;
        halmat_io_item_t *grown = realloc(state->io_pending.items, new_cap * sizeof(halmat_io_item_t));
        if (!grown) { fail(state, "out of memory"); return false; }
        state->io_pending.items = grown;
        state->io_pending.items_capacity = new_cap;
    }
    return true;
}

/* Stores a computed MATRIX/VECTOR result (elems/count, freshly built by
 * the caller into a stack buffer -- copied here, not aliased) into a VAC
 * slot, for a following MASN/VASN or chained arithmetic op to consume.
 * Frees any previous container this slot held (unlike the VAC string/
 * bits leak-across-loop-iterations tradeoff elsewhere in this file,
 * freeing here is just as simple as leaking and avoids it outright). */
static bool store_container_result(halmat_state_t *state, size_t vac_index,
                                    const halmat_scalar_t *elems, size_t count, int rows, int cols) {
    if (vac_index >= HALMAT_VAC_MAX) { fail(state, "VAC index out of range"); return false; }
    halmat_vac_slot_t *slot = &state->vac[vac_index];
    free(slot->container);
    slot->container = malloc(count * sizeof(halmat_scalar_t));
    if (!slot->container) { fail(state, "out of memory"); return false; }
    memcpy(slot->container, elems, count * sizeof(halmat_scalar_t));
    slot->is_ref = false;
    slot->is_container = true;
    slot->container_count = count;
    slot->container_rows = rows;
    slot->container_cols = cols;
    slot->container_is_integer = false; /* default; only OP_DSUB's own asterisk-select branch overrides this */
    return true;
}

/* Binds one positional call argument (state->io_pending.items[item_index])
 * into param_syt's SYT slot in dest_state -- shared by OP_PCAL/OP_FCAL's
 * same-unit binding and interp_prepare_external_call's cross-unit
 * binding (dest_state is `state` itself for the former, the callee's own
 * state for the latter). A whole MATRIX/VECTOR argument
 * (item->is_container, OP_XXAR's whole-container capture above) is
 * shape-conformance-checked against the parameter's own declared
 * dimensions (ensure_container, driven by dest_state's symbol table) and
 * copied element-by-element -- USA003087 Sec. 11.2/11.4's documented
 * MATRIX/VECTOR parameter rules ("the number of rows and columns of the
 * argument must be the same as those of the parameter") and transmission
 * model ("may be viewed as the assignment of the value of each
 * expression... to its corresponding input parameter", i.e. by value,
 * not by reference -- confirmed by a direct user pointer to this
 * section).
 *
 * Cross-precision (SINGLE<->DOUBLE) conversion during transmission (also
 * documented in Sec. 11.4, "precision conversion is allowed") is applied
 * per element via scale_precision() -- the same exact bit-level rule
 * already used for STOS/MTOM/VTOV (USA00309 Sec. 8.2) -- to whichever
 * precision the *parameter* is declared with (dest_state->symtab's
 * HALMAT_SYM_FLAG_DOUBLE/SINGLE bits, symtab.h), matching the
 * "assignment to its corresponding input parameter" model: the
 * parameter's own declared precision wins, exactly as an ordinary
 * `param = argument;` assignment would produce, regardless of whatever
 * precision the caller's argument happened to be. Without a symbol
 * table (dest_state->symtab NULL, e.g. a --py unit) the parameter's
 * declared precision can't be determined, so elements are copied as-is
 * (each keeps its own source precision) -- the same graceful-degradation
 * pattern used elsewhere when the symbol table is unavailable. */
static bool bind_call_argument(halmat_state_t *state, halmat_state_t *dest_state, uint16_t param_syt, uint8_t item_index) {
    if (state->io_pending.items[item_index].is_structure) {
        /* Whole STRUCTURE call argument (state.h's is_structure
         * comment, WRITE/CALL-side XXAR capture): deep-copies each
         * terminal from the caller's own shadow struct-field storage
         * into the callee's, walking the same template field chain
         * both the caller's instance and the callee's own STRUCTURE-
         * typed parameter share (same symtab -- a same-unit call
         * always shares template definitions), mirroring OP_TASN's
         * own elements-aware per-terminal copy technique and OP_READ/
         * flush_write's own field-chain walk for whole-structure I/O.
         * Passed strictly by value (USA003087 Sec. 11.2's ordinary
         * parameter-transmission rule; HAL/S has no structure-typed
         * reference/OUTPUT parameter form), so the callee's own copy
         * always lives at copy_index 0 (an ordinary parameter is
         * never itself part of a Q-STRUCTURE(n) array). User-reported,
         * 172-OUTER.hal's `UTIL(ARG)`. */
        uint16_t src_base = state->io_pending.items[item_index].struct_base_syt;
        /* Whole `Q-STRUCTURE(n)` ARRAY passed by value with no index at
         * all (`CALL SELECT_BEST(VEL);`, VEL declared `SUPER_VECTOR-
         * STRUCTURE(3)`, matched by SELECT_BEST's own `V SUPER_VECTOR-
         * STRUCTURE(3)` parameter) -- user-reported
         * (yahalmat2_assign_array_struct_element; 180-EXAMPLE_N.hal/
         * 184-EXAMPLE_N.hal). Confirmed via real compiled HALMAT that
         * this compiles as ONE XXAR (not one per copy), wrapped in an
         * ADLP(3)/DLPE trailing-metadata pair -- interp_step's own
         * arrayed-paragraph replay (precompute_arrayed_paragraphs)
         * re-executes that single XXAR 3 times, once per arrayed_index,
         * each pass appending its OWN io_pending item with its own
         * correctly-resolved struct_copy_index (0, 1, 2) -- i.e. one
         * *logical* argument becomes 3 *separate* items[] entries, each
         * already carrying the right source copy. The destination copy
         * must track the SAME index (source copy k -> parameter's own
         * copy k), not always land on copy 0 the way a genuine single-
         * copy structure argument (172-OUTER.hal's `UTIL(ARG)`, whose
         * own struct_copy_index is likewise a concrete value -- current_
         * copy_index()'s ambient default of 0 outside any replay, not a
         * literal -1 -- so this formula reduces to the previous
         * hardcoded-0 behavior for that case unchanged). The *caller*
         * (OP_PCAL/OP_FCAL's own binding loop) is responsible for
         * recognizing these 3 items as copies of one logical parameter
         * and passing the SAME `param_syt` for all of them, not 3
         * sequentially-increasing ones -- see resolve_param_syt's own
         * call sites. */
        int32_t src_copy = state->io_pending.items[item_index].struct_copy_index >= 0
            ? state->io_pending.items[item_index].struct_copy_index : current_copy_index(state);
        int32_t dst_copy = src_copy;
        int field_syt = -1;
        if (state->symtab) {
            const halmat_symtab_entry_t *tsym = halmat_symtab_find_by_index(state->symtab, state->io_pending.items[item_index].struct_template_syt);
            field_syt = tsym ? tsym->struct_first_field : -1;
        }
        while (field_syt >= 0) {
            const halmat_symtab_entry_t *fsym = state->symtab ? halmat_symtab_find_by_index(state->symtab, (size_t)field_syt) : NULL;
            if (!fsym) break;
            halmat_syt_entry_t *src_fe = find_or_create_struct_field(state, src_base, (uint16_t)field_syt, src_copy);
            halmat_syt_entry_t *dst_fe = find_or_create_struct_field(dest_state, param_syt, (uint16_t)field_syt, dst_copy);
            if (fsym->hal_class == 4 && fsym->cols > 0) {
                if (!dst_fe->elements) {
                    dst_fe->elements = calloc((size_t)fsym->cols, sizeof(halmat_scalar_t));
                    dst_fe->element_count = (size_t)fsym->cols;
                    dst_fe->cols = fsym->cols;
                    dst_fe->rows = 0;
                }
                if (src_fe->elements) {
                    memcpy(dst_fe->elements, src_fe->elements, (size_t)fsym->cols * sizeof(halmat_scalar_t));
                }
            } else if (fsym->hal_class == 6) {
                dst_fe->type = SYT_TYPE_INTEGER;
                dst_fe->value = src_fe->value;
            } else if (fsym->hal_class == 1) {
                dst_fe->type = SYT_TYPE_BIT;
                dst_fe->bit_value = src_fe->bit_value;
            } else if (fsym->hal_class == 5) {
                dst_fe->type = SYT_TYPE_SCALAR;
                dst_fe->scalar = src_fe->scalar;
            }
            /* Unsupported terminal types are silently skipped here
             * rather than failing loudly -- matching flush_write/
             * OP_READ's own whole-structure handling of every OTHER
             * terminal kind this template actually uses; a genuinely
             * unsupported kind will still surface loudly the first
             * time it's actually read or written through some other
             * path. */
            field_syt = fsym->struct_next_field;
        }
        return true;
    }
    if (state->io_pending.items[item_index].is_container) {
        ensure_container(dest_state, param_syt);
        halmat_syt_entry_t *pe = &dest_state->syt[param_syt];
        size_t count = state->io_pending.items[item_index].container_count;
        if (!pe->elements) {
            /* Either a genuinely unallocated (never-declared-shape) SYT
             * entry, or -- confirmed the common real case, user-reported
             * (140-STATISTICS.hal/141-VSUM.hal) -- an `ARRAY(*)` assumed-
             * size parameter, which ensure_container() deliberately
             * leaves unallocated (its own comment) since it has no
             * declared size of its own to allocate from. An assumed-size
             * parameter's real size is only ever known from the actual
             * argument at each call site (that's the whole point of
             * `ARRAY(*)` -- USA003087 Sec. 7.5/20.11: "size may...vary
             * from invocation to invocation"), so it's allocated directly
             * here instead, sized and shaped to match the caller's own
             * container exactly -- no shape-conformance check needed (or
             * possible) the way a normal, fixed-size parameter gets
             * below, since there is no declared shape to conform to.
             * Freed and reallocated on a later call if a *different*
             * size is passed then, since a same-unit procedure's SYT
             * storage (dest_state == state) persists across calls. */
            free(pe->elements);
            pe->elements = calloc(count, sizeof(halmat_scalar_t));
            pe->element_count = count;
        } else if (count != pe->element_count) {
            fail(state, "procedure/function call: MATRIX/VECTOR/ARRAY argument shape does not match parameter %u",
                 param_syt);
            return false;
        }
        const halmat_scalar_t *src = state->io_pending.items[item_index].container;
        const halmat_symtab_entry_t *psym = dest_state->symtab
            ? halmat_symtab_find_by_index(dest_state->symtab, param_syt) : NULL;
        if (psym && (psym->flags & (HALMAT_SYM_FLAG_SINGLE | HALMAT_SYM_FLAG_DOUBLE))) {
            bool to_double = (psym->flags & HALMAT_SYM_FLAG_DOUBLE) != 0;
            for (size_t k = 0; k < count; k++) pe->elements[k] = scale_precision(src[k], to_double);
        } else {
            memcpy(pe->elements, src, count * sizeof(halmat_scalar_t));
        }
        pe->rows = state->io_pending.items[item_index].container_rows;
        pe->cols = state->io_pending.items[item_index].container_cols;
        return true;
    }
    /* Kind-preserving parameter binding -- previously only ever
     * distinguished SCALAR vs. "everything else defaults to INTEGER,"
     * silently mis-binding both a CHARACTER and a BIT/BOOLEAN argument as
     * INTEGER (reading `.integer`, which a `is_string`/`is_bits` item
     * never populates -- garbage, not just the wrong declared type).
     * User-reported (158-STATE.hal's `STATE(TRUE, 1)`, `STATE`'s own
     * `B` parameter declared `BOOLEAN` -- a synonym for `BIT(1)`):
     * "BTRU: operand is not BIT," since `B`'s own SYT entry ended up
     * `SYT_TYPE_INTEGER` instead. Apparently never exercised before by
     * any fixture passing a `BIT`/`CHARACTER` argument to a same-unit
     * `PROCEDURE`/`FUNCTION` this way -- the same "first real corpus
     * program to hit this exact combination" pattern as several other
     * fixes this session. Mirrors `store_resolved_to_vac`'s own already-
     * established kind-preserving convention. */
    /* SCALAR<->INTEGER cross-coercion by the callee's own DECLARED
     * parameter type -- user-reported (function_result_scalar_integer_
     * confusion; 127-LIMIT.hal/211-LIMIT.hal's `LIMIT(VALUE, BOUND)
     * SCALAR;`, `RETURN BOUND;`/`RETURN VALUE;` printing INTEGER-style
     * instead of SCALAR-style). Root cause: XXAR's own `integer_class_
     * scalar` reclassification (this function's caller, OP_XXAR) is
     * correct for a WRITE argument's TAG1 (which genuinely describes
     * how to *format* the expression being printed) but is the wrong
     * signal here -- for a CALL argument, TAG1 instead reflects the
     * *caller's own literal's* natural HALMAT class, independent of the
     * callee's declared parameter type: confirmed empirically that
     * `LIMIT(5.0, 10.0)` (both whole-number-valued) compiles its XXAR
     * operands with TAG1=6/INTEGER, while the otherwise-identical
     * `LIMIT(5.5, 10.25)` (fractional) compiles TAG1=5/SCALAR for the
     * same SCALAR-declared VALUE/BOUND parameters -- i.e. TAG1 here
     * tracks the *literal's own value*, not the target's type. VALUE/
     * BOUND ended up `SYT_TYPE_INTEGER` despite their own `DECLARE
     * SCALAR`, so a bare-parameter `RETURN` read back an INTEGER-kind
     * value; `RETURN`'s computed-expression cousins (e.g. `RETURN
     * -BOUND;`) worked correctly since SCALAR arithmetic always yields
     * an `RV_SCALAR` result regardless of its operand's stored kind --
     * masking this as "3 of 4 values wrong, oddly inconsistent" rather
     * than a total failure. Consulting the parameter's own declared
     * type here (mirroring the container-argument branch's existing
     * `psym`-driven `scale_precision` coercion above) fixes this
     * generally: any INTEGER-kind argument bound to a declared-SCALAR
     * parameter is coerced to SCALAR, and vice versa -- correct
     * regardless of *why* the argument came in INTEGER-kind (a
     * genuinely INTEGER-typed caller expression is just as legal a
     * SCALAR-parameter argument in HAL/S as a reclassified literal). */
    const halmat_symtab_entry_t *psym = dest_state->symtab
        ? halmat_symtab_find_by_index(dest_state->symtab, param_syt) : NULL;
    if (psym && psym->hal_class == 5 /* SCALAR */ &&
        !state->io_pending.items[item_index].is_scalar && !state->io_pending.items[item_index].is_string &&
        !state->io_pending.items[item_index].is_bits) {
        dest_state->syt[param_syt].type = SYT_TYPE_SCALAR;
        dest_state->syt[param_syt].scalar = halmat_scalar_from_integer(state->io_pending.items[item_index].integer, false);
        return true;
    }
    if (psym && psym->hal_class == 6 /* INTEGER */ && state->io_pending.items[item_index].is_scalar) {
        dest_state->syt[param_syt].type = SYT_TYPE_INTEGER;
        dest_state->syt[param_syt].value = halmat_scalar_to_integer(state->io_pending.items[item_index].scalar);
        return true;
    }
    if (state->io_pending.items[item_index].is_scalar) {
        dest_state->syt[param_syt].type = SYT_TYPE_SCALAR;
        dest_state->syt[param_syt].scalar = state->io_pending.items[item_index].scalar;
    } else if (state->io_pending.items[item_index].is_string) {
        dest_state->syt[param_syt].type = SYT_TYPE_CHARACTER;
        free(dest_state->syt[param_syt].char_value);
        dest_state->syt[param_syt].char_value = dup_string(state->io_pending.items[item_index].string);
    } else if (state->io_pending.items[item_index].is_bits) {
        dest_state->syt[param_syt].type = SYT_TYPE_BIT;
        dest_state->syt[param_syt].bit_value = state->io_pending.items[item_index].bits;
    } else {
        dest_state->syt[param_syt].type = SYT_TYPE_INTEGER;
        dest_state->syt[param_syt].value = state->io_pending.items[item_index].integer;
    }
    return true;
}

/* Resolves a PCAL/FCAL call operand's symbol to the real PDEF/FDEF-
 * defining symbol, following the compiler's own "IND CALL LABEL"
 * indirection (SYM_TYPE=0x45, symtab.h's sym_ptr comment) -- confirmed
 * this session via a user-reported bug: a call site lexically nested in
 * a *different* block than the callee's own definition (e.g. one
 * PROCEDURE calling a sibling PROCEDURE, both nested directly in the
 * same enclosing PROGRAM/TASK -- USA003087 p. 22ff's block-name scoping
 * rules, which explicitly allow this) does NOT carry the callee's own
 * PDEF-defining symbol on its XXST/PCAL operands; it carries a
 * *separate*, alias-only symbol-table entry of type 0x45 instead, whose
 * own SYM_PTR points at the real definition. Without following this
 * redirect, state->symbol_def_pos[[alias symbol]] is NO_TARGET (only
 * ever populated for a real PDEF/FDEF's own symbol -- precompute_
 * subprograms), so the call fails loudly as "undefined" even though the
 * compiler accepted it. Requires a symbol table (state->symtab); without
 * one this indirection can't be detected at all (no HALMAT-level marker
 * distinguishes it -- the operand word itself is an ordinary QUAL=SYT
 * reference either way), so `sym` is returned unchanged, same as before
 * this fix -- the same graceful degradation every other symtab-dependent
 * feature in this interpreter already has. */
static uint16_t resolve_call_target(const halmat_state_t *state, uint16_t sym) {
    if (!state->symtab || sym >= HALMAT_SYT_MAX) return sym;
    const halmat_symtab_entry_t *e = halmat_symtab_find_by_index(state->symtab, sym);
    if (e && e->hal_class == 0x45 && e->sym_ptr > 0 && (size_t)e->sym_ptr < HALMAT_SYT_MAX) {
        return (uint16_t)e->sym_ptr;
    }
    return sym;
}

/* Returns the SYT index a callee's argument `i` (0-indexed) binds to.
 * FCAL.md's own confirmed "callee+1+i" positional convention (parameters
 * occupy the SYT slots immediately following the callee's own symbol,
 * contiguously) only holds when nothing else was allocated a symbol-
 * table slot between the callee's own symbol and its first declared
 * parameter -- true whenever the callee happens to be fully DEFINED
 * before this call site is compiled, but user-reported FALSE for a
 * genuinely forward-referenced PROCEDURE/FUNCTION (called before its own
 * textual `PROCEDURE(...)`/`FUNCTION(...)` definition appears later in
 * the source, 180-EXAMPLE_N.hal/184-EXAMPLE_N.hal's `CALL READ_IMU(I)
 * ASSIGN(VEL(I));`, READ_IMU's own body defined last in the file): every
 * OTHER procedure/task/label symbol forward-referenced earlier in the
 * same enclosing block (SELECT_BEST, GUIDANCE, OTHER_SW, in this file --
 * each gets its own symbol-table slot the moment it's first *referenced*,
 * not when its body is compiled) sits in the gap instead, so
 * "callee+1+i" silently binds arguments to the wrong, unrelated symbols
 * (confirmed via direct instrumentation: READ_IMU's own STRUC parameter,
 * real SYT 20, was computed as SYT 11 -- landing on GUIDANCE's own
 * PROCEDURE LABEL symbol instead). Confirmed via direct COMMON0.out
 * inspection that a real PROCEDURE/FUNCTION LABEL symbol's own SYM_PTR
 * field (already parsed into halmat_symtab_entry_t.sym_ptr for the
 * unrelated IND-CALL-LABEL-alias case above) carries a SECOND, different
 * meaning for this symbol type: the SYT index of the procedure/
 * function's own FIRST formal parameter directly (READ_IMU's SYM_PTR=19
 * =UNIT_NUM's real index; SELECT_BEST's SYM_PTR=13=V's real index --
 * both confirmed against this exact file's own COMMON0.out symbol
 * dump), regardless of how many other symbols were forward-declared in
 * between. Falls back to the "+1+i" approximation when no symbol table
 * is available or `sym_ptr` looks unpopulated (0) -- the same graceful-
 * degradation convention every other symtab-dependent feature in this
 * interpreter already follows; every previously-confirmed fixture
 * (FCAL.md/PCAL.md's own traces) has the callee defined before its call
 * site, where sym_ptr and "+1" necessarily agree, so this is a strict
 * generalization, not a behavior change, for those cases. */
static uint16_t resolve_param_syt(const halmat_state_t *state, uint16_t callee_syt, uint8_t i) {
    if (state->symtab) {
        const halmat_symtab_entry_t *e = halmat_symtab_find_by_index(state->symtab, callee_syt);
        if (e && e->sym_ptr > 0 && (size_t)e->sym_ptr < HALMAT_SYT_MAX) {
            return (uint16_t)((size_t)e->sym_ptr + i);
        }
    }
    return (uint16_t)(callee_syt + 1 + i);
}

/* True if io_pending item `i` is a *replay continuation* of item `i-1`
 * -- one more copy of the SAME logical whole-`Q-STRUCTURE(n)` ARRAY
 * call argument, not a genuinely new positional argument. User-reported
 * (yahalmat2_assign_array_struct_element; 180-EXAMPLE_N.hal's
 * `CALL SELECT_BEST(VEL) ASSIGN(BEST);`, VEL a `SUPER_VECTOR-
 * STRUCTURE(3)`): confirmed via real compiled HALMAT that a whole
 * multi-copy structure argument with no index (`SELECT_BEST(VEL)`)
 * compiles as a SINGLE XXAR wrapped in an ADLP(3)/DLPE trailing-
 * metadata pair, not 3 separate XXARs -- interp_step's own arrayed-
 * paragraph replay mechanism (already used for numeric whole-ARRAY
 * WRITE/CALL arguments) re-executes that one XXAR 3 times, appending
 * a SEPARATE io_pending item each pass (struct_copy_index 0, 1, 2).
 * Without this check, OP_PCAL/OP_FCAL's own positional binding loop
 * (which advances one parameter slot per items[] entry) treated those
 * 3 replay-generated items as 3 DISTINCT arguments, silently binding
 * copies 1 and 2 (and every subsequent real argument/ASSIGN parameter)
 * to the wrong, unrelated parameter slots -- confirmed via direct
 * instrumentation: `ASSIGN(BEST)`'s own parameter resolved to
 * `SELECTED`'s neighbor `MOST_RECENT` instead, two slots off. */
static bool item_is_struct_replay_continuation(const halmat_io_item_t *items, uint8_t i) {
    if (i == 0) return false;
    const halmat_io_item_t *cur = &items[i], *prev = &items[i - 1];
    return cur->is_structure && prev->is_structure &&
           cur->struct_base_syt == prev->struct_base_syt &&
           cur->struct_template_syt == prev->struct_template_syt &&
           cur->struct_copy_index >= 0 && prev->struct_copy_index >= 0 &&
           cur->struct_copy_index == prev->struct_copy_index + 1;
}

/* DTST/ETST bracket a DO WHILE/UNTIL loop, matched by the "bookkeeping
 * label" carried as both instructions' sole INL operand (see
 * class-0/DTST.md, class-0/ETST.md). CTST (class-0/CTST.md) sits right
 * after the per-cycle condition computation and has no label of its own;
 * it belongs to whichever DTST is innermost-open when it's reached, which
 * a single forward pass with a small stack captures directly (HALMAT
 * blocks nest strictly, so this doesn't need label-based matching for
 * CTST). CTST's own tag distinguishes WHILE (0, exit when the condition
 * is false) from UNTIL (1, exit when the condition is true) -- both
 * confirmed against a real compiled test_while.hal trace. */
#define LOOP_STACK_MAX 64

static void precompute_loop_targets(halmat_state_t *state) {
    size_t n = state->prog->count;
    state->ctst_exit_target = malloc(n * sizeof(size_t));
    state->etst_back_target = malloc(n * sizeof(size_t));
    for (size_t i = 0; i < n; i++) {
        state->ctst_exit_target[i] = NO_TARGET;
        state->etst_back_target[i] = NO_TARGET;
    }

    struct {
        size_t dtst_pos;
        size_t ctst_pos;
    } stack[LOOP_STACK_MAX];
    int sp = 0;

    for (size_t i = 0; i < n; i++) {
        uint16_t opcode = state->prog->instrs[i].opcode;
        if (opcode == OP_DTST) {
            if (sp < LOOP_STACK_MAX) {
                stack[sp].dtst_pos = i;
                stack[sp].ctst_pos = NO_TARGET;
                sp++;
            }
        } else if (opcode == OP_CTST) {
            if (sp > 0) stack[sp - 1].ctst_pos = i;
        } else if (opcode == OP_ETST) {
            if (sp > 0) {
                sp--;
                if (stack[sp].ctst_pos != NO_TARGET) {
                    state->ctst_exit_target[stack[sp].ctst_pos] = i + 1;
                }
                state->etst_back_target[i] = stack[sp].dtst_pos + 1;
            }
        }
    }
}

/* See state.h's arrayed_paragraph_end/_count comment. Finds every
 * "ADLP immediately followed by DLPE" trailing-metadata pair (the only
 * shape confirmed empirically this session -- role 2/3's own no-body
 * cases share this exact shape too, so they're harmlessly treated the
 * same way: a paragraph of zero or more instructions, replayed N times,
 * is a correct no-op replay when N-times-replaying an empty or already-
 * scalar paragraph doesn't change anything) and records the preceding
 * paragraph as replayable -- corrected in a later session; see the
 * ADLP/IDLP branch's own comment below for the full account of what was
 * wrong with the original single-fixed-rule version (always the whole
 * enclosing statement, back to the last SMRK) and the two different,
 * independent ways real programs broke it. Multiple consecutive ADLPs
 * before one DLPE (the multi-dimensional-array case) use only the last
 * ADLP's element count -- documented simplification, not exercised by
 * any fixture. */
static void precompute_arrayed_paragraphs(halmat_state_t *state) {
    size_t n = state->prog->count;
    state->arrayed_paragraph_end = malloc(n * sizeof(size_t));
    state->arrayed_paragraph_count = malloc(n * sizeof(int));
    state->arrayed_paragraph_unit_size = malloc(n * sizeof(int));
    for (size_t i = 0; i < n; i++) {
        state->arrayed_paragraph_end[i] = NO_TARGET;
        state->arrayed_paragraph_count[i] = 0;
        state->arrayed_paragraph_unit_size[i] = 0; /* 0 = ADLP/IDLP-style entry (plain per-index
                                                     * arrayed_index, no accumulation -- see
                                                     * run_arrayed_paragraph); an SLRI-style entry
                                                     * always records a positive value below. */
    }

    size_t boundary = 0;
    for (size_t i = 0; i < n; i++) {
        uint16_t opcode = state->prog->instrs[i].opcode;
        if (opcode == OP_SMRK) {
            boundary = i + 1;
        } else if (opcode == OP_ADLP || opcode == OP_IDLP) {
            /* IDLP (STATIC-array counterpart of ADLP, class-0/IDLP.md)
             * shares the exact same single-instance-plus-trailing-
             * metadata shape for the uniform-INITIAL()-value case
             * (confirmed empirically: `V1 INITIAL(4.0)` on a default/
             * STATIC ARRAY(3) compiles to one SINT then IDLP(3) then
             * DLPE, no per-element repetition) -- treated identically. */
            size_t j = i;
            int count = 0;
            while (j < n && (state->prog->instrs[j].opcode == OP_ADLP || state->prog->instrs[j].opcode == OP_IDLP)) {
                const halmat_instr_t *adlp = &state->prog->instrs[j];
                if (adlp->operand_count == 1 && adlp->operands[0].qual == QUAL_IMD) {
                    count = (int16_t)adlp->operands[0].data;
                }
                j++;
            }
            if (j < n && state->prog->instrs[j].opcode == OP_DLPE && count > 0 && i > 0 &&
                state->prog->instrs[i - 1].opcode != OP_SFAR) {
                /* The paragraph ADLP/IDLP trails and replays *starts* at
                 * the single instruction immediately before this chain
                 * (i-1) -- confirmed by every "one XXAR/SINT/VINT/BASN,
                 * then ADLP(count), then DLPE" trace seen throughout
                 * this project, including the multi-item-statement case
                 * (`WRITE(6) AVERAGE, DATA_VALID;`, `DATA_VALID` an
                 * `ARRAY(4) BOOLEAN`): `DATA_VALID`'s own XXAR is *at*
                 * i-1, immediately preceding its own ADLP, so this rule
                 * already correctly excludes `AVERAGE`'s separate,
                 * earlier XXAR without any special-casing -- user-
                 * reported, 120-EXAMPLE_A.hal, found investigating a
                 * related whole-BIT-ARRAY-argument fix. (An intermediate
                 * version of this fix instead tracked "position after
                 * the most recently-seen XXAR/SFAR" as an alternate,
                 * *later* boundary candidate than i-1 -- wrong: for a
                 * whole-ARRAY/structure-copy WRITE argument, or the
                 * `TSUB`/structure-copy-initialization shape, the item's
                 * own XXAR sitting at i-1 must stay *included* in its
                 * own replay, not be treated as an exclusion marker
                 * merely for occupying that position -- confirmed
                 * regressing test_tsub/test_structcopy_init before this
                 * was caught and reverted back to the simpler, correct
                 * i-1 rule below.)
                 *
                 * `!= OP_SFAR`: the one confirmed exception to "i-1
                 * always starts the paragraph" -- a shaping-function
                 * whole-array argument's own SFAR (`MAX(SA1)`/`SUM(SA1)`/
                 * etc., class-0/LFNC.md) also trails an ADLP/DLPE pair,
                 * but SFAR's own handler always appends exactly one
                 * entry to shape_pending.items[] no matter how many
                 * times it fires (correct as-is for other shaping
                 * functions' genuinely-repeated, *separate* SFAR calls,
                 * e.g. `SCALAR(S1, S2)`'s two real SFAR instructions --
                 * one call each, not a replay of one) and LFNC's own
                 * handler expects to see it exactly once, resolving the
                 * whole array itself via resolve_container rather than
                 * accumulating per-element replay results -- so
                 * excluded here entirely (no arrayed_paragraph_end entry
                 * at all, i.e. genuinely not replayed, confirmed
                 * regressing test_lfnc_array otherwise).
                 *
                 * Beyond i-1: a genuine computed *expression* assigned to
                 * a whole ARRAY (`A3 = A1 + A2;`: SADD computing each
                 * element's sum, immediately followed by SASN storing
                 * it, both wrapped in the *same* ADLP/DLPE) needs more
                 * than the single instruction at i-1 replayed -- SASN's
                 * own source operand is a `QUAL_VAC` reference to SADD's
                 * freshly-computed result, so replaying SASN alone would
                 * just copy the *same* stale value N times instead of
                 * recomputing it fresh per element (confirmed regressing
                 * test_adlp otherwise). Handled generally, not just for
                 * this one shape: walk backward from i-1, and whenever
                 * the instruction at the current `start` has a
                 * `QUAL_VAC` operand pointing to an *earlier* position
                 * still within this same statement, extend `start` back
                 * to that position and keep walking from there --
                 * correctly pulls SADD in behind SASN, and generalizes
                 * to deeper same-statement VAC dependency chains the
                 * same way, while never reaching past `boundary` into a
                 * genuinely separate, earlier statement or list item.
                 *
                 * A `QUAL_VAC` operand's own `data` is the *raw HALMAT
                 * word position* of its producing instruction (this
                 * project's own established VAC-addressing convention --
                 * `state->vac[]` is indexed the same way, via each
                 * instruction's own `.index` field, not by `instrs[]`'s
                 * *logical* array position used everywhere else in this
                 * function/`state->pc`) -- so it can't be compared
                 * against `start`/`boundary` directly; the inner
                 * backward scan below converts it to the matching
                 * `instrs[]` logical index by comparing against each
                 * candidate entry's own `.index` (monotonically
                 * increasing with logical position, so a plain linear
                 * walk suffices). */
                /* User-reported (partition_array_shift_wrong;
                 * 138-FILTER.hal's `[BUFF] 1 TO 3 = [BUFF] 2 TO 4;`, a
                 * SASN with TWO independent QUAL_VAC operands -- the
                 * to-partition DSUB results for both its receiver AND
                 * its source, neither depending on the other): the
                 * original version below only ever examined the
                 * operands of the instruction *currently at* `start`,
                 * re-pointed to the single newly-found candidate each
                 * time it moved `start` back -- so after finding SASN's
                 * *first* QUAL_VAC operand (its source, this project's
                 * own "source-first" SASN convention) and moving `start`
                 * to that producer (the source DSUB, which itself has no
                 * further QUAL_VAC operands), the loop's own `cur`
                 * pointer permanently lost access to SASN's *second*
                 * QUAL_VAC operand (its receiver, the dest DSUB) --
                 * `break` abandoning the rest of that `for k` scan the
                 * moment one candidate was found, and the next pass only
                 * ever re-examining the instruction at the *new* `start`,
                 * never revisiting SASN's own remaining operand. The dest
                 * DSUB was left entirely outside the replayed paragraph,
                 * executing exactly once with arrayed_index still -1
                 * (confirmed via direct instrumentation: dest resolved
                 * once to a fixed offset while the src DSUB correctly
                 * replayed 3 times) instead of once per ADLP iteration --
                 * so `[BUFF] 1 TO 3` never advanced across the shift
                 * register's 3 elements at all. Fixed by re-scanning
                 * *every* instruction currently within `[start, i-1]`
                 * each pass (not just the instruction at `start` itself)
                 * for a QUAL_VAC operand pointing earlier than `start`,
                 * a proper fixed-point walk that keeps chasing every
                 * independent dependency an instruction in the paragraph
                 * has, not just a single linear chain -- the already-
                 * confirmed single-dependency cases (e.g. `A3 = A1 +
                 * A2;`'s SASN<-SADD chain) are unaffected, since a chain
                 * of length 1 behaves identically either way. */
                size_t start = i - 1;
                size_t scan_end = i - 1;
                bool progress = true;
                while (progress && start > boundary) {
                    progress = false;
                    for (size_t p = start; p <= scan_end; p++) {
                        const halmat_instr_t *cur = &state->prog->instrs[p];
                        for (uint8_t k = 0; k < cur->operand_count; k++) {
                            if (cur->operands[k].qual != QUAL_VAC) continue;
                            size_t target_word = cur->operands[k].data;
                            size_t candidate = start;
                            while (candidate > boundary && state->prog->instrs[candidate - 1].index >= target_word) candidate--;
                            if (candidate < start && candidate >= boundary && state->prog->instrs[candidate].index == target_word) {
                                start = candidate;
                                progress = true;
                            }
                        }
                    }
                }
                state->arrayed_paragraph_end[start] = j + 1;
                state->arrayed_paragraph_count[start] = count;
            }
        } else if (opcode == OP_SLRI) {
            /* STRI/SLRI/ELRI/ETRI: repeated-initialize group for the
             * n#value INITIAL() repetition-factor form (class-8/
             * SLRI.md). Unlike ADLP/IDLP (which trail the paragraph
             * they replay), SLRI leads it -- the preceding STRI names
             * the target symbol (recorded at runtime into
             * state->stri_target_syt, consumed by QUAL_OFF writes
             * inside the paragraph), SLRI's own first operand carries
             * the repetition count, its second operand the number of
             * elements per repeated unit (confirmed this session -- see
             * below), and the bracketed paragraph runs from just after
             * SLRI up to (not including) this SLRI's *own* matching
             * ELRI.
             *
             * SLRI/ELRI pairs are matched by the operator word's own
             * TAG field (a 1-based nesting depth), NOT by "the next
             * ELRI found" -- confirmed this session against a real
             * compile of USA003087 Sec. 16.2's documented nested-
             * repetition-factor form, `INITIAL(4#(1,5#0),1)` (meant as a
             * 5x5 identity matrix): this produces an *outer* SLRI(tag=1,
             * count=4, unit_size=6) whose own bracketed body itself
             * contains a complete *inner* SLRI(tag=2, count=5,
             * unit_size=1)...ELRI(tag=2) pair (for the nested `5#0`)
             * before the outer's own ELRI(tag=1) -- so a naive "first
             * ELRI found" scan from the outer SLRI would wrongly stop at
             * the *inner* ELRI instead of its own. Matching by equal TAG
             * instead correctly skips over any more-deeply-nested (and
             * therefore higher-tagged) SLRI/ELRI pairs in between. (This
             * generalizes the single-level "stop at ELRI, not the outer
             * ETRI" fix from an earlier session, which mixed independent
             * *sibling* SLRI groups within one STRI/ETRI but never
             * nested one SLRI's body inside another's.)
             *
             * The bracketed paragraph is replayed by
             * run_arrayed_paragraph() (interp_step's caller), which
             * recurses into any nested SLRI-driven entry it finds inside
             * its own body instead of just skipping over it as a no-op
             * -- see that function's own comment for the offset-
             * accumulation arithmetic (`outer_base + idx*unit_size`)
             * that a nested repetition-factor group needs and a flat,
             * single-level replay can't express. Contrary to SLRI.md's
             * original documented trace (which showed literal
             * per-element unrolling for a 1000-element array), today's
             * HALSFC build was confirmed (an earlier session) to always
             * emit exactly one SINT/ELRI unit here regardless of count
             * -- i.e. the same single-instance-plus-replay-count shape
             * ADLP/IDLP use, just with SLRI leading instead of trailing.
             * Corrected in SLRI.md alongside this change. */
            const halmat_instr_t *slri = &state->prog->instrs[i];
            if (slri->operand_count == 2 && slri->operands[0].qual == QUAL_IMD &&
                slri->operands[1].qual == QUAL_IMD) {
                int count = (int16_t)slri->operands[0].data;
                int unit_size = (int16_t)slri->operands[1].data;
                size_t j = i + 1;
                while (j < n && !(state->prog->instrs[j].opcode == OP_ELRI && state->prog->instrs[j].tag == slri->tag)) j++;
                if (j < n && count > 0 && unit_size > 0) {
                    state->arrayed_paragraph_end[i + 1] = j + 1;
                    state->arrayed_paragraph_count[i + 1] = count;
                    state->arrayed_paragraph_unit_size[i + 1] = unit_size;
                }
            }
        }
    }
}

/* Precomputed per array-index position: the HAL/S statement number whose
 * code that position belongs to, for --debug's source-line display (see
 * srcmap.c, debug.c, interp_current_stmt_for_next()). SMRK's confirmed
 * placement (empirically, and per direct user correction) is *after* a
 * statement's own HALMAT, not before it -- SMRK(K) is the last
 * instruction generated for statement K, and the code that follows it
 * belongs to statement K+1. So the statement a given position belongs to
 * can't be determined by remembering the last SMRK *executed* (that's
 * always one statement behind); it has to be found by looking *forward*
 * to the next SMRK at or after that position. Filled by a single
 * backward scan: walking from the end, each SMRK(K) sets a running
 * "next statement" value to K, and every position (including the SMRK's
 * own) gets stamped with whatever that running value currently is.
 * Positions after the last SMRK in the stream (e.g. the trailing XREC)
 * get -1 (no statement). */
static void precompute_stmt_for_pc(halmat_state_t *state) {
    size_t n = state->prog->count;
    state->stmt_for_pc = malloc(n * sizeof(long));
    long next_stmt = -1;
    for (size_t i = n; i-- > 0; ) {
        const halmat_instr_t *ins = &state->prog->instrs[i];
        if (ins->opcode == OP_SMRK && ins->operand_count == 1) {
            next_stmt = (long)ins->operands[0].data;
        }
        state->stmt_for_pc[i] = next_stmt;
    }
}

/* LBL destinations for BRA/FBRA (IF/THEN/ELSE), keyed by INL label
 * number -- a flat table, not stack-based, since BRA/FBRA/LBL don't
 * nest the way DTST/CTST/ETST do (see class-0/LBL.md, class-0/BRA.md,
 * class-0/FBRA.md). Confirmed against a real compiled test_ifelse.hal
 * trace: the branch target is LBL's own position (a no-op instruction),
 * not position+1 -- falling through it naturally lands one past it.
 *
 * Also registers `EXIT loop-label;`'s own target here: confirmed by
 * compiling `037-ROOTS.hal` (a user-supplied fixture using `EXIT
 * ROOTLOOP;` to break out of a `DO WHILE TRUE`) that EXIT compiles to
 * a completely ordinary BRA, targeting the *same* INL bookkeeping-label
 * number the enclosing DTST/ETST pair both carry as their own sole
 * operand (class-0/DTST.md, class-0/ETST.md) -- previously unregistered
 * anywhere, since DTST/ETST aren't OP_LBL and precompute_loop_targets()
 * (which does understand DTST/ETST pairing) only ever indexes by
 * instruction *position*, never by this label *number*, so a real EXIT
 * statement always failed with "branch to undefined label N". Landing
 * position is ETST's own position **+ 1**, not ETST's position itself
 * (unlike the OP_LBL case above): OP_ETST's own handler, reached by
 * ordinary fall-through at the bottom of a loop body, unconditionally
 * branches back to retest the loop condition (etst_back_target) rather
 * than continuing past itself, so landing exactly on ETST would loop
 * forever instead of exiting -- `i + 1` is the identical "loop actually
 * exited" position CTST's own ctst_exit_target already uses. */
static void precompute_labels(halmat_state_t *state) {
    state->label_pos = malloc(HALMAT_LABEL_MAX * sizeof(size_t));
    state->label_pos_syt = malloc(HALMAT_SYT_MAX * sizeof(size_t));
    for (size_t i = 0; i < HALMAT_LABEL_MAX; i++) {
        state->label_pos[i] = NO_TARGET;
    }
    for (size_t i = 0; i < HALMAT_SYT_MAX; i++) {
        state->label_pos_syt[i] = NO_TARGET;
    }
    for (size_t i = 0; i < state->prog->count; i++) {
        const halmat_instr_t *ins = &state->prog->instrs[i];
        if (ins->opcode == OP_LBL && ins->operand_count == 1 && ins->operands[0].qual == QUAL_SYT) {
            /* A real `GO TO <label>;` targets a user-declared STATEMENT
             * LABEL -- a *separate* LBL/BRA pairing from the INL-numbered
             * bookkeeping-label case just below, keyed by SYT index
             * instead (state.h's label_pos_syt comment). */
            uint16_t syt = ins->operands[0].data;
            if (syt < HALMAT_SYT_MAX) state->label_pos_syt[syt] = i;
        } else if (ins->opcode == OP_LBL && ins->operand_count == 1 && ins->operands[0].qual == QUAL_INL) {
            /* LBL.md's confirmed IF/ELSE-join-point shape: QUAL_INL,
             * registered into label_pos[] (the bookkeeping-label table).
             * Originally this branch had no qualifier check at all, and
             * shared a single flat table with the QUAL_SYT case just
             * above -- SYT indices and INL numbers are independent,
             * both-near-zero numbering spaces that can coincidentally
             * collide in a small enough program (found via a synthetic
             * regression fixture for the EXIT-to-labeled-DFOR fix just
             * below, whose labeled DO FOR's own STATEMENT LABEL SYT index
             * happened to equal an unrelated INL number, silently
             * mis-registering the INL target -- no error, just a branch
             * landing somewhere wrong). Splitting the two into separate
             * tables (state.h's label_pos_syt comment), with OP_BRA/
             * OP_FBRA below choosing which one to consult from their own
             * operand's qualifier, removes the collision risk entirely
             * rather than just hiding it. */
            uint16_t label = ins->operands[0].data;
            if (label < HALMAT_LABEL_MAX) state->label_pos[label] = i;
        } else if (ins->opcode == OP_ETST && ins->operand_count == 1) {
            uint16_t label = ins->operands[0].data;
            if (label < HALMAT_LABEL_MAX) state->label_pos[label] = i + 1;
            /* REPEAT's own target (user-reported, 095-TAN_SUMS.hal): confirmed
             * against PASS1.PROCS/SYNTHESI.xpl's actual REPEAT synthesis
             * (search "REPEATING:") that REPEAT emits a BRA whose INL operand
             * is DO_LOC(TEMP)+1 -- one more than the *same* DO_LOC value EXIT
             * emits verbatim (matching this enclosing loop's own DTST/ETST-
             * shared label, registered just above). No LBL (or any other
             * instruction) ever carries this "+1" value in the HALMAT stream
             * itself -- Pass 2's real code generator resolves it structurally
             * from DO_LOC's own loop-nesting bookkeeping, which this
             * interpreter doesn't have, so it's synthesized here instead:
             * REPEAT's intended landing spot ("abandon the rest of this
             * cycle's body, retest for the next one") is exactly the same
             * position OP_ETST's own fall-through back-edge already computes
             * (etst_back_target, precompute_loop_targets() above, called
             * before this function) -- dtst_pos+1, the loop's per-cycle
             * retest entry, not dtst_pos itself (landing exactly on DTST
             * would just redundantly re-run its own one-time setup). Without
             * this, every real REPEAT statement failed with "branch to
             * undefined label N". */
            if (label < HALMAT_LABEL_MAX - 1) state->label_pos[label + 1] = state->etst_back_target[i];
        } else if (ins->opcode == OP_EFOR && ins->operand_count == 1) {
            /* `EXIT <label>;` targeting a *labeled* `DO FOR` (range or
             * list form) -- user-reported (119-EXAMPLE_9.hal's `INNER:
             * DO FOR TEMPORARY J = 1 TO 3; ... EXIT INNER; ... END
             * INNER;`): EXIT compiles to a plain BRA, same as the DTST/
             * ETST case above, but targeting the INL construct-id number
             * DFOR/EFOR share (class-0/DFOR.md/EFOR.md), which this
             * function previously never registered at all (only OP_LBL
             * and OP_ETST were), so every such EXIT failed with "branch
             * to undefined label N". EFOR.md's own confirmed LSTALL
             * trace settles the landing position: the real AP-101S label
             * matching this construct id (`L#8`/`L#13` in that trace)
             * sits immediately after EFOR's own generated logic (the
             * store+compare+branch-back for range form, or the
             * saved-return-address dispatch for list form) in both
             * forms -- i.e. `i + 1`, the same "just past this
             * instruction" convention ETST's own registration above
             * uses, not EFOR's own position (which would re-run its
             * increment/re-test, or list-form dispatch, instead of
             * genuinely exiting). Registered from EFOR rather than DFOR
             * since EFOR already carries the identical label directly as
             * its own sole operand in both forms (EFOR.md), needing no
             * separate DFOR-to-EFOR position lookup. */
            uint16_t label = ins->operands[0].data;
            if (label < HALMAT_LABEL_MAX) state->label_pos[label] = i + 1;
            /* REPEAT inside a `DO FOR` loop (as opposed to a `DO WHILE`/
             * `DO UNTIL`, the DTST/ETST case above) -- user-reported
             * (yahalmat2_assign_array_struct_element;
             * 180-EXAMPLE_N.hal/184-EXAMPLE_N.hal's `DO FOR N = 1 TO 3;
             * IF V.STATUS = OFF THEN REPEAT; ...`): the same "REPEAT's
             * BRA targets DO_LOC(TEMP)+1" convention as the DTST/ETST
             * case (confirmed by this exact file's own compiled HALMAT:
             * DFOR/EFOR's shared construct-id label is 6, REPEAT's own
             * BRA targets label 7=6+1), but landing at a different
             * position than ETST's own case needs: a DTST/ETST loop's
             * `etst_back_target` skips past DTST's one-time setup logic,
             * which range-form DFOR has no equivalent of -- EFOR's own
             * instruction position *is* already the loop's per-cycle
             * increment/retest/branch-back entry point (its own body
             * unconditionally re-evaluates the loop control variable and
             * either branches back into the body or falls through past
             * the loop), so REPEAT should land exactly *on* EFOR itself
             * (`i`, not `i+1` -- landing at `i+1`, EXIT's own target,
             * would incorrectly skip the loop entirely instead of
             * continuing it). Without this, every `REPEAT;` inside a
             * `DO FOR` loop failed with "branch to undefined label N". */
            if (label < HALMAT_LABEL_MAX - 1) state->label_pos[label + 1] = i;
        }
    }
}

/* List-form DO FOR (class-0/AFOR.md's "call-and-computed-return"
 * mechanism): a DFOR with exactly 2 operands (construct id + control
 * variable, no range literals -- see class-0/DFOR.md) opens the list,
 * followed immediately by one AFOR per value, then the (single, shared)
 * loop body, then the matching EFOR. */
#define FOR_STACK_MAX 64

static void precompute_for_loops(halmat_state_t *state) {
    size_t n = state->prog->count;
    state->afor_body_target = malloc(n * sizeof(size_t));
    state->afor_return_target = malloc(n * sizeof(size_t));
    state->afor_control_var = calloc(n, sizeof(uint16_t));
    state->efor_is_list_form = calloc(n, sizeof(bool));
    state->efor_dfor_pos = malloc(n * sizeof(size_t));
    state->dfor_efor_pos = malloc(n * sizeof(size_t));
    state->cfor_exit_target = malloc(n * sizeof(size_t));
    for (size_t i = 0; i < n; i++) {
        state->afor_body_target[i] = NO_TARGET;
        state->afor_return_target[i] = NO_TARGET;
        state->efor_dfor_pos[i] = NO_TARGET;
        state->dfor_efor_pos[i] = NO_TARGET;
        state->cfor_exit_target[i] = NO_TARGET;
    }

    struct {
        bool is_list;
        size_t dfor_pos;
        uint16_t control_var;
        size_t afor_positions[HALMAT_MAX_OPERANDS * 8]; /* generous: real lists are short */
        size_t afor_count;
        size_t cfor_positions[64]; /* range-form only: pending CFORs to patch once EFOR's position is known */
        size_t cfor_count;
    } stack[FOR_STACK_MAX];
    int sp = 0;

    for (size_t i = 0; i < n; i++) {
        const halmat_instr_t *ins = &state->prog->instrs[i];
        if (ins->opcode == OP_DFOR) {
            if (sp < FOR_STACK_MAX) {
                bool is_list = (ins->operand_count == 2);
                stack[sp].is_list = is_list;
                stack[sp].dfor_pos = i;
                stack[sp].control_var = is_list ? ins->operands[1].data : 0;
                stack[sp].afor_count = 0;
                stack[sp].cfor_count = 0;
                sp++;
            }
        } else if (ins->opcode == OP_AFOR) {
            if (sp > 0 && stack[sp - 1].is_list && stack[sp - 1].afor_count < HALMAT_MAX_OPERANDS * 8) {
                stack[sp - 1].afor_positions[stack[sp - 1].afor_count++] = i;
                state->afor_control_var[i] = stack[sp - 1].control_var;
            }
        } else if (ins->opcode == OP_CFOR) {
            if (sp > 0 && !stack[sp - 1].is_list && stack[sp - 1].cfor_count < 64) {
                stack[sp - 1].cfor_positions[stack[sp - 1].cfor_count++] = i;
            }
        } else if (ins->opcode == OP_EFOR) {
            if (sp > 0) {
                sp--;
                if (stack[sp].is_list) {
                    state->efor_is_list_form[i] = true;
                    size_t count = stack[sp].afor_count;
                    for (size_t k = 0; k < count; k++) {
                        size_t pos = stack[sp].afor_positions[k];
                        state->afor_body_target[pos] = stack[sp].afor_positions[count - 1] + 1;
                        state->afor_return_target[pos] = (k + 1 < count) ? stack[sp].afor_positions[k + 1] : (i + 1);
                    }
                } else {
                    state->efor_dfor_pos[i] = stack[sp].dfor_pos;
                    state->dfor_efor_pos[stack[sp].dfor_pos] = i;
                    for (size_t k = 0; k < stack[sp].cfor_count; k++) {
                        state->cfor_exit_target[stack[sp].cfor_positions[k]] = i + 1;
                    }
                }
            }
        }
    }
}

/* DO CASE (DCAS/CLBL/ECAS): see state.h's field comments and
 * class-0/DCAS.md, class-0/CLBL.md, class-0/ECAS.md. The final CLBL
 * before ECAS (tag=1, class-0/CLBL.md's "trap" CLBL) is excluded from
 * the selectable case list -- its role for out-of-range selectors is
 * documented as untested/unresolved, so an out-of-range selector fails
 * loudly here rather than guessing. */
#define CASE_STACK_MAX 64

static void precompute_case_dispatch(halmat_state_t *state) {
    size_t n = state->prog->count;
    state->dcas_case_target = malloc(n * HALMAT_MAX_CASES * sizeof(size_t));
    state->dcas_case_count = calloc(n, sizeof(size_t));
    state->clbl_ecas_target = malloc(n * sizeof(size_t));
    for (size_t i = 0; i < n; i++) state->clbl_ecas_target[i] = NO_TARGET;

    struct {
        size_t dcas_pos;
        size_t clbl_positions[HALMAT_MAX_CASES];
        size_t clbl_count;
    } stack[CASE_STACK_MAX];
    int sp = 0;

    for (size_t i = 0; i < n; i++) {
        const halmat_instr_t *ins = &state->prog->instrs[i];
        if (ins->opcode == OP_DCAS) {
            if (sp < CASE_STACK_MAX) {
                stack[sp].dcas_pos = i;
                stack[sp].clbl_count = 0;
                sp++;
            }
        } else if (ins->opcode == OP_CLBL) {
            if (sp > 0 && stack[sp - 1].clbl_count < HALMAT_MAX_CASES) {
                stack[sp - 1].clbl_positions[stack[sp - 1].clbl_count++] = i;
            }
        } else if (ins->opcode == OP_ECAS) {
            if (sp > 0) {
                sp--;
                size_t dcas_pos = stack[sp].dcas_pos;
                size_t clbl_count = stack[sp].clbl_count;
                size_t ordinary_count = clbl_count > 0 ? clbl_count - 1 : 0; /* last CLBL is a
                    trailing bookkeeping label, not a jump target of its own (OP_DCAS's own
                    comment: an ELSE clause, if present, compiles as plain in-line code right
                    after DCAS itself, not as an extra trailing CLBL) */
                state->dcas_case_count[dcas_pos] = ordinary_count;
                for (size_t k = 0; k < clbl_count; k++) {
                    size_t clbl_pos = stack[sp].clbl_positions[k];
                    state->clbl_ecas_target[clbl_pos] = i + 1;
                    if (k < ordinary_count) {
                        state->dcas_case_target[dcas_pos * HALMAT_MAX_CASES + k] = clbl_pos + 1;
                    }
                }
            }
        }
    }
}

/* Function/procedure/task definitions (FDEF|TDEF...CLOS) sit inline in
 * the enclosing PROGRAM's own instruction stream, so ordinary
 * fall-through must skip over them entirely -- they're only ever
 * entered via an explicit FCAL/SCHD jump (to def_pos+1, bypassing
 * FDEF/TDEF itself, so its own "skip to my CLOS" logic never fires on
 * entry). Matched by SYT symbol equality (FDEF/TDEF and their CLOS
 * share the same operand), not a nesting stack, since HAL/S
 * functions/procedures/tasks don't nest inside each other -- only
 * inside the top-level MDEF (also closed by CLOS, but never opened via
 * FDEF/TDEF, so it never enters this map). See state.h's field comments. */
static void precompute_subprograms(halmat_state_t *state) {
    size_t n = state->prog->count;
    state->symbol_def_pos = malloc(HALMAT_SYT_MAX * sizeof(size_t));
    state->def_clos_target = malloc(n * sizeof(size_t));
    state->symbol_active_task = malloc(HALMAT_SYT_MAX * sizeof(int));
    for (size_t i = 0; i < HALMAT_SYT_MAX; i++) {
        state->symbol_def_pos[i] = NO_TARGET;
        state->symbol_active_task[i] = -1;
    }
    for (size_t i = 0; i < n; i++) state->def_clos_target[i] = NO_TARGET;

    for (size_t i = 0; i < n; i++) {
        const halmat_instr_t *ins = &state->prog->instrs[i];
        if ((ins->opcode == OP_FDEF || ins->opcode == OP_TDEF || ins->opcode == OP_PDEF) && ins->operand_count == 1) {
            uint16_t sym = ins->operands[0].data;
            if (sym < HALMAT_SYT_MAX) state->symbol_def_pos[sym] = i;
        } else if (ins->opcode == OP_CLOS && ins->operand_count == 1) {
            uint16_t sym = ins->operands[0].data;
            if (sym < HALMAT_SYT_MAX && state->symbol_def_pos[sym] != NO_TARGET) {
                state->def_clos_target[state->symbol_def_pos[sym]] = i + 1;
            }
        }
    }
}

void interp_init(halmat_state_t *state, const halmat_program_t *prog,
                  const halmat_literal_table_t *literals, int num_blanks) {
    memset(state, 0, sizeof(*state));
    state->prog = prog;
    state->literals = literals;
    state->num_blanks = num_blanks;
    state->line_length = -1; /* not explicitly set; flush_write picks the per-device
                               * PAGED(132)/UNPAGED(80) default -- see state.h's comment */
    state->page_length = 66; /* IBM 1403 line printer default; --page-length overrides (main.c) */
    state->page_break_string = dup_string("\f");
    state->page_break_implies_newline = false; /* bare form-feed default -- see state.h's comment */
    precompute_loop_targets(state);
    precompute_labels(state);
    precompute_for_loops(state);
    precompute_case_dispatch(state);
    precompute_subprograms(state);
    precompute_arrayed_paragraphs(state);
    precompute_stmt_for_pc(state);
    state->arrayed_index = -1;

    /* Primal process: priority 50 by default (USA003087 Sec. 13.1-13.3),
     * starts at the first instruction, READY. */
    state->tasks[0].in_use = true;
    state->tasks[0].is_primal = true;
    state->tasks[0].parent_task = -1; /* the primal has no parent */
    state->tasks[0].priority = 50;
    state->tasks[0].task_state = TASK_READY;
    state->tasks[0].saved_pc = 0;
    state->task_count = 1;
    state->current_task = 0;
    state->stri_target_syt = -1;
    state->stri_target_template_syt = -1;
    state->time_scale = 1.0; /* genuine real-time pacing by default; --time-scale overrides (main.c) */
    state->pacing_mode = HALMAT_PACING_BURST; /* interp_run_burst() by default; --pacing=signal overrides (main.c) */

    /* Default device mapping: 5=input/6=output, per HAL/S language
     * convention (Plan.md Phase 3) -- overridable via interp_set_device
     * (main.c's --ddi/--ddo). Every other device starts unmapped. */
    state->devices[5] = stdin;
    state->devices[6] = stdout;

    /* RANDOM/RANDOMG's Park-Miller generator (state.h's rng_state
     * comment): seeded to a fixed non-zero value, not real entropy, so
     * every run is exactly reproducible -- the generator is degenerate
     * (stays at zero forever) if ever seeded with 0. */
    state->rng_state = 1;
}

void interp_set_device(halmat_state_t *state, int device, FILE *f) {
    if (device < 0 || device >= HALMAT_DEVICE_MAX) return;
    state->devices[device] = f;
}

void interp_set_device_unpaged(halmat_state_t *state, int device, bool unpaged) {
    if (device < 0 || device >= HALMAT_DEVICE_MAX) return;
    state->device_unpaged[device] = unpaged;
}

void interp_set_raf_device(halmat_state_t *state, int channel, FILE *f, int record_size) {
    if (channel < 0 || channel >= HALMAT_DEVICE_MAX) return;
    state->raf_devices[channel] = f;
    state->raf_record_size[channel] = record_size;
}

void interp_set_symtab(halmat_state_t *state, const halmat_symtab_t *symtab) {
    state->symtab = symtab;
    /* Pre-seed every plain (unarrayed, non-structure) declared symbol's
     * SYT entry with the *declared* type's own zero-value, rather than
     * leaving it at SYT_TYPE_UNKNOWN (memset-zero's default) until its
     * first write. read_syt_entry() (this file) treats anything that
     * isn't explicitly SCALAR/CHARACTER/BIT as INTEGER -- correct for a
     * genuinely-INTEGER-declared variable, but wrong for a BIT/CHARACTER/
     * SCALAR one that's read *before* ever being written: user-reported,
     * 250-BITS.hal's `DECLARE B BIT(8); ... IF B = HEX'00' THEN ...;`
     * (`B` has no `INITIAL()`, so no BINT/etc. instruction ever touches
     * its SYT entry before this comparison) -- "BEQU/BNEQ: both operands
     * must be BIT," since B's own type was still SYT_TYPE_UNKNOWN,
     * silently read as RV_INTEGER instead. A real DECLARE with no
     * INITIAL() defaults to all-zero-bits/empty-string/0.0/0 per HAL/S's
     * own semantics -- exactly what this seeding produces, matching the
     * *value* a real BINT(0)/CINT("")/SINT(0.0) would have set anyway,
     * just without needing the source to spell it out. Harmless for a
     * symbol that *does* have an explicit INITIAL() (or gets assigned
     * before its first read some other way): that real init/assignment
     * instruction runs after this and simply overwrites the seed.
     * Function/procedure parameters are seeded the same way (harmless --
     * bind_call_argument() overwrites this the moment the parameter is
     * actually bound by a real call). Scoped to hal_class 1/2/5/6/9 (BIT/
     * CHARACTER/SCALAR/INTEGER/EVENT) with no recognized ARRAY/VECTOR/
     * MATRIX shape -- an arrayed or structure-shaped symbol's own storage
     * is handled by ensure_container()/EDCL-time struct setup instead,
     * not this scalar-only mechanism.
     *
     * hal_class==9 (EVENT, confirmed against 239-STARTUP.hal's own
     * COMMON0.out symbol-table report -- SYM_TYPE=09 for `DECLARE ORBIT
     * EVENT LATCHED;`/`DECLARE ORBIT3 EVENT;` alike, a class number not
     * otherwise documented anywhere else in this codebase) is seeded the
     * same way as BIT: an EVENT's runtime state is already modeled as a
     * plain SYT_TYPE_BIT bit_value (0=not signaled, 1=signaled -- see
     * this file's own SIGNAL/SET/RESET handling, `e->bit_value = ...`),
     * just never given an explicit type at DECLARE time the way BINT
     * would for a real BIT variable. 239-STARTUP.hal's own `SCHEDULE
     * FREEFALL ON (ORBIT & (ORBIT2 & ORBIT3))` reads ORBIT2/ORBIT3
     * directly in a BAND event-expression before either is ever
     * SET/RESET/SIGNALed -- previously misread as RV_INTEGER by the same
     * SYT_TYPE_UNKNOWN default this whole fix addresses, "BAND: both
     * operands must be BIT." An EVENT genuinely defaults to "not
     * signaled" until first set, matching plain BIT's own all-zero
     * default here. */
    if (!symtab) return;
    for (size_t i = 0; i < symtab->count; i++) {
        const halmat_symtab_entry_t *sym = &symtab->entries[i];
        if (sym->index >= HALMAT_SYT_MAX) continue;
        if (sym->shape != HALMAT_SHAPE_NONE) continue;
        halmat_syt_entry_t *e = &state->syt[sym->index];
        if (e->type != SYT_TYPE_UNKNOWN) continue;
        switch (sym->hal_class) {
            case 1: e->type = SYT_TYPE_BIT; e->bit_value = 0; break;
            case 2: e->type = SYT_TYPE_CHARACTER; e->char_value = dup_string(""); break;
            case 5: e->type = SYT_TYPE_SCALAR; e->scalar = halmat_scalar_zero(false); break;
            case 6: e->type = SYT_TYPE_INTEGER; e->value = 0; break;
            case 9: e->type = SYT_TYPE_BIT; e->bit_value = 0; break;
            default: break;
        }
    }
}

void interp_set_external_units(halmat_state_t *state, const halmat_external_call_map_t *map, size_t count) {
    free(state->external_calls);
    state->external_calls = calloc(HALMAT_SYT_MAX, sizeof(*state->external_calls));
    for (size_t i = 0; i < count; i++) {
        if (map[i].local_syt >= HALMAT_SYT_MAX) continue;
        state->external_calls[map[i].local_syt].target_state = map[i].target_state;
        state->external_calls[map[i].local_syt].target_entry_syt = map[i].target_entry_syt;
    }
}

void interp_set_time_scale(halmat_state_t *state, double scale) {
    state->time_scale = scale;
}

void interp_set_pacing_mode(halmat_state_t *state, halmat_pacing_mode_t mode) {
    state->pacing_mode = mode;
}

void interp_set_line_length(halmat_state_t *state, int line_length) {
    state->line_length = line_length;
}

void interp_set_page_length(halmat_state_t *state, int page_length) {
    state->page_length = page_length;
}

/* Sets the between-page string (--ff, main.c) and precomputes whether it
 * gets an implied trailing newline (state.h's page_break_implies_newline
 * comment: suppressed for "", a bare form-feed, or a string that already
 * ends in '\n'). `s` is copied; the caller retains ownership of its own
 * argument. */
void interp_set_page_break_string(halmat_state_t *state, const char *s) {
    free(state->page_break_string);
    state->page_break_string = dup_string(s);
    size_t len = strlen(s);
    state->page_break_implies_newline =
        !(len == 0 || (len == 1 && s[0] == '\f') || (len > 0 && s[len - 1] == '\n'));
}

/* Frees whichever of elements/bit_elements/char_elements (state.h) an
 * entry has -- char_elements needs each owned string freed individually
 * first, unlike the other two forms' flat calloc'd buffers. Leaves the
 * entry's fields NULL/0, safe to call on an entry that never had a
 * container allocated at all. */
static void free_syt_container(halmat_syt_entry_t *e) {
    free(e->elements);
    e->elements = NULL;
    free(e->bit_elements);
    e->bit_elements = NULL;
    if (e->char_elements) {
        for (size_t i = 0; i < e->element_count; i++) free(e->char_elements[i]);
        free(e->char_elements);
        e->char_elements = NULL;
    }
}

void interp_cleanup(halmat_state_t *state) {
    /* io_pending's own items buffer, plus any still-pending nested frames
     * left on io_pending_stack (e.g. a fail()/halt reached mid-nested-
     * call, before OP_XXND's own pop-and-free ever ran) -- best-effort,
     * same convention as this function's other bulk frees. */
    free(state->io_pending.items);
    for (uint8_t i = 0; i < state->io_pending_sp; i++) {
        free(state->io_pending_stack[i].items);
    }
    free(state->ctst_exit_target);
    free(state->etst_back_target);
    free(state->label_pos);
    free(state->label_pos_syt);
    free(state->afor_body_target);
    free(state->afor_return_target);
    free(state->afor_control_var);
    free(state->efor_is_list_form);
    free(state->efor_dfor_pos);
    free(state->dfor_efor_pos);
    free(state->cfor_exit_target);
    free(state->dcas_case_target);
    free(state->dcas_case_count);
    free(state->clbl_ecas_target);
    free(state->symbol_def_pos);
    free(state->def_clos_target);
    free(state->symbol_active_task);
    free(state->arrayed_paragraph_end);
    free(state->arrayed_paragraph_count);
    free(state->arrayed_paragraph_unit_size);
    free(state->stmt_for_pc);
    free(state->external_calls); /* the table itself; the target_states it
                                   * points to are not owned here -- main.c's */
    state->external_calls = NULL;
    state->symbol_active_task = NULL;
    state->ctst_exit_target = NULL;
    state->etst_back_target = NULL;
    state->label_pos = NULL;
    state->label_pos_syt = NULL;
    state->afor_body_target = NULL;
    state->afor_return_target = NULL;
    state->afor_control_var = NULL;
    state->efor_is_list_form = NULL;
    state->efor_dfor_pos = NULL;
    state->dfor_efor_pos = NULL;
    state->cfor_exit_target = NULL;
    state->dcas_case_target = NULL;
    state->dcas_case_count = NULL;
    state->clbl_ecas_target = NULL;
    state->symbol_def_pos = NULL;
    state->def_clos_target = NULL;
    state->arrayed_paragraph_end = NULL;
    state->arrayed_paragraph_count = NULL;
    state->arrayed_paragraph_unit_size = NULL;
    state->stmt_for_pc = NULL;

    for (size_t i = 0; i < HALMAT_SYT_MAX; i++) {
        free_syt_container(&state->syt[i]);
        free(state->syt[i].char_value);
        state->syt[i].char_value = NULL;
    }
    for (size_t i = 0; i < HALMAT_VAC_MAX; i++) {
        if (state->vac[i].is_string) free(state->vac[i].string);
        if (state->vac[i].is_container) free(state->vac[i].container);
    }
    for (size_t i = 0; i < state->struct_field_count; i++) {
        free_syt_container(&state->struct_fields[i].value);
        free(state->struct_fields[i].value.char_value);
    }
    free(state->struct_fields);
    state->struct_fields = NULL;
    state->struct_field_count = 0;
    state->struct_field_capacity = 0;

    free(state->error_handlers);
    state->error_handlers = NULL;
    state->error_handler_count = 0;
    state->error_handler_capacity = 0;

    /* A WRITE's own last line stays buffered (device_mech's own comment,
     * state.h) until something moves the mechanism down -- for the very
     * *last* WRITE issued to a device in the whole run, nothing ever does,
     * so it must be flushed here or it's silently lost. Called before
     * main.c's own fclose() of these files (interp_cleanup doesn't own
     * them either way, same as devices[] itself). */
    for (int d = 0; d < HALMAT_DEVICE_MAX; d++) {
        halmat_device_mech_t *dm = &state->device_mech[d];
        if (dm->started && state->devices[d]) {
            if (dm->line_buf_len > 0) fwrite(dm->line_buf, 1, dm->line_buf_len, state->devices[d]);
            fputc('\n', state->devices[d]);
        }
        free(dm->line_buf);
        dm->line_buf = NULL;
    }
    free(state->page_break_string);
    state->page_break_string = NULL;
}

/* Writes `text` into `dm`'s current-line buffer starting at 1-based
 * column `col`, growing the buffer as needed and space-padding any gap
 * between the buffer's existing high-water content and `col` (so a
 * forward jump past the end of what's been written so far reads as
 * blanks, matching a real device mechanism moving right over untouched
 * paper). Does NOT truncate or clear anything already in the buffer past
 * `col + strlen(text)` -- an earlier COLUMN/TAB that jumped backward and
 * is now being followed by a *shorter* field correctly leaves the
 * remainder of whatever was there before untouched (overstrike, not
 * replace-to-end-of-line; this is what makes Fig. 12-5's own `TAB(-50)`
 * worked example -- moving left mid-line then writing more text -- come
 * out right). Updates dm->col to just past the written text. */
static void dm_write_at(halmat_device_mech_t *dm, int col, const char *text) {
    size_t start = (size_t)(col - 1);
    size_t len = strlen(text);
    size_t need = start + len;
    if (need > dm->line_buf_cap) {
        size_t new_cap = dm->line_buf_cap ? dm->line_buf_cap * 2 : 128;
        while (new_cap < need) new_cap *= 2;
        dm->line_buf = realloc(dm->line_buf, new_cap);
        dm->line_buf_cap = new_cap;
    }
    if (start > dm->line_buf_len) {
        memset(dm->line_buf + dm->line_buf_len, ' ', start - dm->line_buf_len);
    }
    if (len > 0) memcpy(dm->line_buf + start, text, len);
    if (need > dm->line_buf_len) dm->line_buf_len = need;
    dm->col = col + (int)len;
}

/* Commits `dm`'s current-line buffer to `out` with a trailing newline and
 * resets it for the next line -- the device mechanism's own vertical
 * movement (dm_advance_lines/dm_do_page/dm_do_line below) is what decides
 * *when* this happens; flush_write itself never calls this at the end of
 * a statement (state.h's device_mech comment: the last line of a WRITE
 * stays open/buffered for whatever comes next, matching USA003087 Sec.
 * 12.2's own "device mechanism is left positioned one column to the
 * right of the end of the last data field written" -- not flushed to a
 * fresh line). Does NOT touch dm->line/dm->page; the caller owns those. */
static void dm_finalize_line(halmat_device_mech_t *dm, FILE *out) {
    if (dm->line_buf_len > 0) fwrite(dm->line_buf, 1, dm->line_buf_len, out);
    fputc('\n', out);
    dm->line_buf_len = 0;
    dm->col = 1;
}

/* Substitutes every literal "%p" in `tmpl` (state->page_break_string,
 * --ff) with `page_num` in decimal -- the only substitution the user
 * asked for; any other content (including a stray lone '%') passes
 * through verbatim. Returns a malloc'd buffer the caller must free(). */
static char *expand_page_break_string(const char *tmpl, int page_num) {
    size_t cap = strlen(tmpl) + 16;
    char *out = malloc(cap);
    size_t o = 0;
    for (const char *p = tmpl; *p; ) {
        if (p[0] == '%' && p[1] == 'p') {
            char numbuf[16];
            int n = snprintf(numbuf, sizeof(numbuf), "%d", page_num);
            if (o + (size_t)n + 1 > cap) { cap = (o + (size_t)n + 1) * 2; out = realloc(out, cap); }
            memcpy(out + o, numbuf, (size_t)n);
            o += (size_t)n;
            p += 2;
        } else {
            if (o + 2 > cap) { cap *= 2; out = realloc(out, cap); }
            out[o++] = *p++;
        }
    }
    if (o + 1 > cap) { cap += 1; out = realloc(out, cap); }
    out[o] = '\0';
    return out;
}

/* Emits state->page_break_string (with "%p" resolved to `page_num`) to
 * `out`, honoring page_break_implies_newline (state.h's comment). Called
 * every time dm_advance_lines/dm_do_page/dm_do_line cross a page
 * boundary on a PAGED device. */
static void emit_page_break(halmat_state_t *state, FILE *out, int page_num) {
    char *expanded = expand_page_break_string(state->page_break_string, page_num);
    fputs(expanded, out);
    if (state->page_break_implies_newline) fputc('\n', out);
    free(expanded);
}

/* Moves `dm` down exactly `n` (>= 0) lines, finalizing each line crossed
 * along the way (dm_finalize_line -- the first is whatever content was
 * actually written on it, the rest are blank), and correctly turning the
 * page (emit_page_break) whenever a PAGED device's line counter would
 * exceed state->page_length. UNPAGED devices have no page concept at all
 * (USA003087 Sec. 12.4 rule 4 vs. rule 5) so `unpaged` skips the page-
 * length check entirely -- a flat, ever-increasing line counter. Shared
 * by: the default 1-line advance at the start of every WRITE but a
 * device's very first, an ordinary field-overflow wrap (a field that
 * wouldn't fit within the line-length limit), and explicit SKIP(n)/
 * LINE(gamma) (dm_do_line's own same-page branch). n is looped one line
 * at a time rather than batch-computed -- n is always small in any real
 * program (bounded by page_length at most, typically far less), and a
 * straightforward per-line loop is far less error-prone than batching
 * the page-crossing arithmetic.
 *
 * n == 0 is a real, meaningful case (SKIP(0), or LINE(gamma) when
 * already on line gamma) -- Fig. 12-6's own worked example
 * (`SKIP(0),C1, LINE(1),C2,C3;`) shows SKIP(0) "inhibits [the] default
 * line advance" (so no line is finalized/no page-turn check happens)
 * while C1 still "starts in column 1" -- i.e. the mechanism still gets
 * *repositioned* to column 1 of the (unchanged) current line, it just
 * doesn't move to a new one. The ordinary n>=1 loop below achieves this
 * as a side effect of dm_finalize_line's own col=1 reset; n==0 needs it
 * spelled out explicitly since the loop body never runs. */
static void dm_advance_lines(halmat_state_t *state, halmat_device_mech_t *dm, FILE *out, int n, bool unpaged) {
    if (n == 0) { dm->col = 1; return; }
    for (int i = 0; i < n; i++) {
        dm_finalize_line(dm, out);
        if (!unpaged && dm->line >= state->page_length) {
            dm->page++;
            emit_page_break(state, out, dm->page);
            dm->line = 1;
        } else {
            dm->line++;
        }
    }
}

/* PAGE(beta), USA003087 Sec. 12.4 rule 3: moves down `beta` (>= 0) pages,
 * *keeping the relative line number unchanged* (Fig. 12-7's own worked
 * example: line 41 of page 5 -> PAGE(1) -> line 41 of page 6) -- distinct
 * from dm_advance_lines, which always lands on line 1 of a new page.
 * Fails loudly on an UNPAGED device (Sec. 12.4: "PAGE can be used only in
 * I/O via a paged device"). beta == 0 is a genuine no-op (mechanism
 * completely unchanged) -- still meaningful at the start of a WRITE,
 * where it suppresses the default 1-line advance the same way SKIP(0)
 * does, without otherwise doing anything. */
static bool dm_do_page(halmat_state_t *state, halmat_device_mech_t *dm, FILE *out, int beta, bool unpaged) {
    if (unpaged) { fail(state, "PAGE: only valid for a PAGED device"); return false; }
    if (beta < 0) { fail(state, "PAGE: argument must not be negative"); return false; }
    if (beta == 0) return true;
    int saved_line = dm->line;
    dm_finalize_line(dm, out);
    for (int i = 0; i < beta; i++) {
        dm->page++;
        emit_page_break(state, out, dm->page);
    }
    dm->line = 1;
    if (saved_line > 1) {
        for (int k = 1; k < saved_line; k++) fputc('\n', out);
        dm->line = saved_line;
    }
    return true;
}

/* LINE(gamma), USA003087 Sec. 12.4 rule 4 (UNPAGED)/rule 5 (PAGED).
 * PAGED: "[l]et the device mechanism be on line l prior to execution of
 * LINE(gamma). If gamma < l then the device mechanism moves to line
 * [gamma] on the next page. If gamma > l then the device mechanism moves
 * to line gamma on the current page" -- user-corrected reading of the
 * primary source's own text (USA003087.txt:6220ish literally says "moves
 * to line l on the next page," which would mean LINE's own argument is
 * ignored on a page-crossing move, an internally-inconsistent reading
 * against the whole point of specifying gamma; the project owner
 * confirmed this is presumed to be a source typo for "line gamma"). The
 * gamma == l case is treated as "already there" (falls into the
 * gamma >= l / same-page branch, zero lines to move) rather than forcing
 * a page turn, since gamma < l is the only case Sec. 12.4 actually
 * documents as needing one. UNPAGED: a flat line counter with no page
 * concept at all -- gamma must not be less than the current line
 * ("must not be such as to cause upward movement," rule 4), fails loudly
 * otherwise (matching the project's established "fail loudly rather than
 * misbehave" convention for a genuinely illegal request, same as a real
 * HALSFC compile would reject it). */
static bool dm_do_line(halmat_state_t *state, halmat_device_mech_t *dm, FILE *out, int gamma, bool unpaged) {
    if (unpaged) {
        if (gamma < dm->line) { fail(state, "LINE: illegal upward movement on an UNPAGED device"); return false; }
        dm_advance_lines(state, dm, out, gamma - dm->line, true);
        return true;
    }
    if (gamma < 1 || gamma > state->page_length) {
        fail(state, "LINE: argument %d out of range 1..%d (--page-length)", gamma, state->page_length);
        return false;
    }
    if (gamma >= dm->line) {
        dm_advance_lines(state, dm, out, gamma - dm->line, false);
    } else {
        dm_finalize_line(dm, out);
        dm->page++;
        emit_page_break(state, out, dm->page);
        dm->line = 1;
        if (gamma > 1) {
            for (int k = 1; k < gamma; k++) fputc('\n', out);
        }
        dm->line = gamma;
    }
    return true;
}

/* Emits one already-formatted WRITE data field into `dm`'s current line,
 * honoring the standard num_blanks separator and the line_length wrap
 * column (USA003087 Sec. 12.2: fields "separated from each other by the
 * standard number of blanks, ... overflowing onto succeeding lines as
 * required") -- shared by every field kind flush_write below produces,
 * including each individual element of an expanded whole-VECTOR/MATRIX/
 * ARRAY item. `*need_sep` is false only for the very first field of the
 * whole WRITE statement, right after a forced line break (a MATRIX row
 * boundary, or an ordinary overflow wrap, below), or right after an
 * explicit TAB/COLUMN/SKIP/LINE/PAGE specifier (which "overrides the
 * standard data field separation," Sec. 12.4) -- in each of those cases
 * the field lands exactly at dm->col with no leading blanks. */
static void dm_emit_field(halmat_state_t *state, halmat_device_mech_t *dm, FILE *out, const char *text, bool *need_sep, int wrap_col, bool unpaged) {
    int width = (int)strlen(text);
    int col = *need_sep ? dm->col + state->num_blanks : dm->col;
    if (*need_sep && col - 1 + width > wrap_col) {
        dm_advance_lines(state, dm, out, 1, unpaged);
        col = dm->col; /* == 1, just reset by dm_advance_lines */
        *need_sep = false;
    }
    dm_write_at(dm, col, text);
    *need_sep = true;
}

/* UNPAGED CHARACTER-string WRITE formatting (USA003087 Appendix F /
 * USA003090 Sec. 6.1.3, both confirmed against "Programming in HAL/S"
 * Sec. 8.1's direct worked example): "the string of characters is
 * enclosed in apostrophes, and all internal apostrophes are converted
 * to apostrophe pairs." Returns a malloc'd buffer the caller must
 * free(); sized exactly for the worst case (every character an
 * apostrophe) rather than a fixed guess, so an unusually long CHARACTER
 * literal can't overflow it. */
static char *quote_character_for_unpaged(const char *s) {
    size_t len = strlen(s);
    char *buf = malloc(len * 2 + 3); /* 2 enclosing quotes + NUL, each char doubled worst-case */
    if (!buf) return NULL;
    size_t o = 0;
    buf[o++] = '\'';
    for (size_t k = 0; k < len; k++) {
        buf[o++] = s[k];
        if (s[k] == '\'') buf[o++] = '\'';
    }
    buf[o++] = '\'';
    buf[o] = '\0';
    return buf;
}

/* BIT WRITE field formatting (USA003087 Appendix F): "a series of ones
 * and zeros... [l]eading binary zeroes are not suppressed[;] the field
 * width is equal to the number of binary digits in the string plus an
 * inserted blank following every fourth digit (to enhance readability)."
 * Confirmed via "Programming in HAL/S" Sec. 8.1's own worked example,
 * HEX'1234' (16 bits) -> "0001 0010 0011 0100": the inserted blank is a
 * readability grouping between groups, not a trailing field separator
 * (no blank after the last group, whether or not width is a multiple of
 * 4). Most-significant bit first. `buf` must be at least
 * width + width/4 + 1 bytes (a blank per interior group boundary, plus
 * NUL) -- width is capped at 32 (state.h's bit_width comment; also
 * USA003090 Sec. 8.2 rule 6's documented legal maximum) everywhere this
 * is called, so a 48-byte stack buffer is always enough. */
static void format_bit_field(uint32_t bits, int width, char *buf) {
    int o = 0;
    for (int i = 0; i < width; i++) {
        int bit_index = width - 1 - i;
        buf[o++] = ((bits >> bit_index) & 1u) ? '1' : '0';
        if ((i + 1) % 4 == 0 && (i + 1) != width) buf[o++] = ' ';
    }
    buf[o] = '\0';
}

static void flush_write(halmat_state_t *state, int device, FILE *out, bool unpaged) {
    halmat_device_mech_t *dm = &state->device_mech[device];
    /* state->line_length < 0 means --line-length wasn't explicitly given
     * (main.c) -- pick the per-device default derived from USA003090 Sec.
     * 6.1.4's LRECL defaults (state.h's line_length comment): 132 for
     * PAGED (133-byte LRECL minus the automatically-generated ANSI/ASA
     * carriage-control byte an FBA record format implies), 80 for UNPAGED
     * (plain FB, no control byte, the full LRECL is printable). */
    int wrap_col = state->line_length >= 0 ? state->line_length : (unpaged ? 80 : 132);

    /* USA003087 Sec. 12.2's own execution-sequence rule: "[i]f the WRITE
     * statement is the first to be executed for the specified device, the
     * device mechanism positions itself at column 1 of line 1 (on page 1
     * if the device is paged). Otherwise, the device mechanism moves down
     * one line from its current position, and repositions itself at
     * column 1" -- UNLESS an explicit SKIP/LINE/PAGE is the very first
     * item, which "overrides the default downward movement of one line"
     * entirely (that item does the real work in the loop below instead).
     *
     * Separately: Sec. 12.4's own "[i]f a TAB or COLUMN pseudo-function
     * appears at the beginning of a...WRITE statement, it overrides the
     * default positioning at column 1" -- confirmed via Fig. 12-5's own
     * worked example (`WRITE(6)TAB(-50),C1,COLUMN(5),C2,C3,TAB(2);`,
     * starting from an established column ~80 left over from whatever
     * came before): a *leading* TAB is relative to the column the
     * mechanism was already at before this statement began, NOT relative
     * to column 1 -- despite the ordinary default vertical movement still
     * happening (Fig. 12-5's own "MOVE DOWN 1 LINE BY DEFAULT" label,
     * simultaneous with "TAB LEFT 50 COLUMNS"). So the pre-statement
     * column is captured here, and restored (overriding the default
     * advance's own col=1 reset) right before a leading TAB/COLUMN item
     * gets its turn in the loop below. Scoped narrowly to items[0]
     * specifically (the literal "at the beginning" case Fig. 12-5
     * demonstrates) -- an explicit SKIP/LINE/PAGE followed by a TAB/
     * COLUMN in items[1] is left as ordinary sequential application
     * (relative to whatever column that vertical item's own move landed
     * on), a reasonable default for a combination no fixture or corpus
     * program is confirmed to need. */
    int pre_stmt_col = dm->col;
    bool leads_with_horizontal = state->io_pending.item_count > 0 &&
        state->io_pending.items[0].is_ioctl &&
        (state->io_pending.items[0].ioctl_kind == 1 || state->io_pending.items[0].ioctl_kind == 2);
    bool need_sep = false;
    if (!dm->started) {
        dm->started = true;
        dm->page = 1;
        dm->line = 1;
        dm->col = 1;
        dm->line_buf_len = 0;
    } else {
        bool leads_with_vertical = state->io_pending.item_count > 0 &&
            state->io_pending.items[0].is_ioctl &&
            (state->io_pending.items[0].ioctl_kind == 3 || state->io_pending.items[0].ioctl_kind == 4 ||
             state->io_pending.items[0].ioctl_kind == 5);
        if (!leads_with_vertical) {
            dm_advance_lines(state, dm, out, 1, unpaged);
            if (leads_with_horizontal) dm->col = pre_stmt_col;
        }
    }

    for (uint8_t i = 0; i < state->io_pending.item_count; i++) {
        if (state->io_pending.items[i].is_ioctl) {
            /* USA003087 Sec. 12.4's five device-mechanism-positioning
             * pseudo-functions (class-0/XXAR.md's confirmed TAG2 encoding,
             * mirrored by ioctl_kind: 1=TAB, 2=COLUMN, 3=SKIP, 4=LINE,
             * 5=PAGE) -- not a data value, so this branch never falls
             * through to the ordinary field-formatting logic below. Each
             * (per Sec. 12.4's own general rule) "overrides the standard
             * data field separation" for whichever field follows it, so
             * need_sep is forced false afterward -- except a no-op
             * PAGE(0), which by definition changes nothing. */
            int n = state->io_pending.items[i].ioctl_n;
            switch (state->io_pending.items[i].ioctl_kind) {
                case 1: { /* TAB(alpha): relative */
                    int new_col = dm->col + n;
                    if (new_col < 1) { fail(state, "TAB: would move left of column 1"); return; }
                    if (new_col > wrap_col) { fail(state, "TAB: would move right of column %d", wrap_col); return; }
                    dm->col = new_col;
                    need_sep = false;
                    break;
                }
                case 2: { /* COLUMN(beta): absolute */
                    if (n < 1) { fail(state, "COLUMN: must be >= 1"); return; }
                    if (n > wrap_col) { fail(state, "COLUMN: must be <= %d", wrap_col); return; }
                    dm->col = n;
                    need_sep = false;
                    break;
                }
                case 3: /* SKIP(alpha) */
                    if (n < 0) { fail(state, "SKIP: argument must not be negative"); return; }
                    dm_advance_lines(state, dm, out, n, unpaged);
                    need_sep = false;
                    break;
                case 4: /* LINE(gamma) */
                    if (!dm_do_line(state, dm, out, n, unpaged)) return;
                    need_sep = false;
                    break;
                case 5: /* PAGE(beta) */
                    if (!dm_do_page(state, dm, out, n, unpaged)) return;
                    if (n > 0) need_sep = false;
                    break;
            }
            continue;
        }
        if (state->io_pending.items[i].is_container) {
            /* Whole VECTOR/MATRIX/ARRAY WRITE argument (OP_XXAR above):
             * expand every element into its own data field, per
             * USA003087 Sec. 12.2's "DATA FORMATS". */
            int rows = state->io_pending.items[i].container_rows;
            int cols = state->io_pending.items[i].container_cols;
            const halmat_scalar_t *elems = state->io_pending.items[i].container;
            if (rows > 0) {
                /* MATRIX: laid out row by row, each row written as if it
                 * were its own n-vector. "The first element of the
                 * second and subsequent rows begin a new line, vertically
                 * aligned under the first element of the first row" --
                 * an unconditional forced line break at each row
                 * boundary (distinct from, and taking priority over, the
                 * generic "only when it doesn't fit" wrap rule used
                 * everywhere else), with the new line's starting column
                 * fixed to wherever row 0's own first field began. */
                int align_col = 1;
                for (int r = 0; r < rows; r++) {
                    if (r > 0) {
                        dm_advance_lines(state, dm, out, 1, unpaged);
                        dm->col = align_col;
                        need_sep = false;
                    }
                    for (int c = 0; c < cols; c++) {
                        char buf[32];
                        halmat_scalar_format(elems[(size_t)r * cols + c], buf, sizeof(buf));
                        dm_emit_field(state, dm, out, buf, &need_sep, wrap_col, unpaged);
                        if (r == 0 && c == 0) align_col = dm->col - (int)strlen(buf);
                    }
                }
            } else {
                /* VECTOR, or a plain ARRAY: a flat sequential run of
                 * fields, wrapping generically like any other field. */
                size_t count = state->io_pending.items[i].container_count;
                bool is_int = state->io_pending.items[i].container_is_integer;
                for (size_t k = 0; k < count; k++) {
                    char buf[32];
                    if (is_int) {
                        /* INTEGER WRITE field: 11-char right-justified,
                         * same convention as a plain INTEGER item below. */
                        snprintf(buf, sizeof(buf), "%11d", halmat_scalar_to_integer(elems[k]));
                    } else {
                        halmat_scalar_format(elems[k], buf, sizeof(buf));
                    }
                    dm_emit_field(state, dm, out, buf, &need_sep, wrap_col, unpaged);
                }
            }
        } else if (state->io_pending.items[i].is_bit_array) {
            /* Whole BIT ARRAY WRITE argument (OP_XXAR above, state.h's
             * is_bit_array comment): one binary-digit-string field per
             * element, same per-element format as a lone BIT value
             * (format_bit_field) -- flat sequential layout like VECTOR/
             * plain-ARRAY above (BIT ARRAY has no MATRIX-like row
             * grouping). */
            size_t count = state->io_pending.items[i].container_count;
            const uint32_t *bits = state->io_pending.items[i].bit_array;
            int width = state->io_pending.items[i].bit_array_width;
            for (size_t k = 0; k < count; k++) {
                char buf[48];
                format_bit_field(bits[k], width, buf);
                if (unpaged) {
                    char *quoted = quote_character_for_unpaged(buf);
                    dm_emit_field(state, dm, out, quoted ? quoted : buf, &need_sep, wrap_col, unpaged);
                    free(quoted);
                } else {
                    dm_emit_field(state, dm, out, buf, &need_sep, wrap_col, unpaged);
                }
            }
        } else if (state->io_pending.items[i].is_char_array) {
            /* Whole CHARACTER ARRAY WRITE argument (OP_XXAR above,
             * state.h's is_char_array comment): one field per element,
             * same per-element format as a lone CHARACTER value. */
            size_t count = state->io_pending.items[i].container_count;
            char *const *strs = state->io_pending.items[i].char_array;
            for (size_t k = 0; k < count; k++) {
                if (unpaged) {
                    char *quoted = quote_character_for_unpaged(strs[k]);
                    dm_emit_field(state, dm, out, quoted ? quoted : strs[k], &need_sep, wrap_col, unpaged);
                    free(quoted);
                } else {
                    dm_emit_field(state, dm, out, strs[k], &need_sep, wrap_col, unpaged);
                }
            }
        } else if (state->io_pending.items[i].is_structure) {
            /* Whole STRUCTURE WRITE argument (OP_XXAR above, state.h's
             * is_structure comment): one data field per terminal, in
             * declaration order, same "walk struct_first_field/
             * struct_next_field" technique OP_READ's own
             * dest_is_structure handling uses -- a VECTOR terminal
             * expands to one field per component (matching a lone
             * whole-VECTOR WRITE argument, is_container's own flat-
             * VECTOR branch above), everything else (SCALAR/INTEGER/
             * BIT) is a single ordinary field, same formatting each
             * already uses standalone. */
            uint16_t base_syt = state->io_pending.items[i].struct_base_syt;
            int32_t copy_idx = state->io_pending.items[i].struct_copy_index >= 0
                ? state->io_pending.items[i].struct_copy_index : current_copy_index(state);
            int field_syt = -1;
            if (state->symtab) {
                const halmat_symtab_entry_t *tsym = halmat_symtab_find_by_index(state->symtab, state->io_pending.items[i].struct_template_syt);
                field_syt = tsym ? tsym->struct_first_field : -1;
            }
            while (field_syt >= 0) {
                const halmat_symtab_entry_t *fsym = state->symtab ? halmat_symtab_find_by_index(state->symtab, (size_t)field_syt) : NULL;
                if (!fsym) break;
                halmat_syt_entry_t *fe = find_or_create_struct_field(state, base_syt, (uint16_t)field_syt, copy_idx);
                if (fsym->hal_class == 4 && fsym->cols > 0) {
                    for (int k = 0; k < fsym->cols; k++) {
                        char buf[32];
                        halmat_scalar_t v = fe->elements ? fe->elements[k] : halmat_scalar_zero(false);
                        halmat_scalar_format(v, buf, sizeof(buf));
                        dm_emit_field(state, dm, out, buf, &need_sep, wrap_col, unpaged);
                    }
                } else if (fsym->hal_class == 6) {
                    char buf[16];
                    snprintf(buf, sizeof(buf), "%11d", fe->value);
                    dm_emit_field(state, dm, out, buf, &need_sep, wrap_col, unpaged);
                } else if (fsym->hal_class == 1) {
                    char buf[48];
                    int width = fsym->bit_width > 0 ? fsym->bit_width : 32;
                    format_bit_field(fe->bit_value, width, buf);
                    if (unpaged) {
                        char *quoted = quote_character_for_unpaged(buf);
                        dm_emit_field(state, dm, out, quoted ? quoted : buf, &need_sep, wrap_col, unpaged);
                        free(quoted);
                    } else {
                        dm_emit_field(state, dm, out, buf, &need_sep, wrap_col, unpaged);
                    }
                } else if (fsym->hal_class == 5) {
                    char buf[32];
                    halmat_scalar_format(fe->scalar, buf, sizeof(buf));
                    dm_emit_field(state, dm, out, buf, &need_sep, wrap_col, unpaged);
                } else {
                    fail(state, "WRITE: structure terminal '%s' has an unsupported type for whole-structure WRITE", fsym->name ? fsym->name : "?");
                    break;
                }
                field_syt = fsym->struct_next_field;
            }
        } else if (state->io_pending.items[i].is_string) {
            if (unpaged) {
                char *quoted = quote_character_for_unpaged(state->io_pending.items[i].string);
                dm_emit_field(state, dm, out, quoted ? quoted : state->io_pending.items[i].string, &need_sep, wrap_col, unpaged);
                free(quoted);
            } else {
                dm_emit_field(state, dm, out, state->io_pending.items[i].string, &need_sep, wrap_col, unpaged);
            }
        } else if (state->io_pending.items[i].is_scalar) {
            /* Fixed-width scientific-notation field per class-2/STOC.md
             * (USA00309 Sec. 6.1.3). */
            char buf[32];
            halmat_scalar_format(state->io_pending.items[i].scalar, buf, sizeof(buf));
            dm_emit_field(state, dm, out, buf, &need_sep, wrap_col, unpaged);
        } else if (state->io_pending.items[i].is_bits) {
            /* Binary-digit-string field, state.h's bit_width comment /
             * format_bit_field's own comment above. */
            char buf[48];
            format_bit_field(state->io_pending.items[i].bits, state->io_pending.items[i].bit_width, buf);
            if (unpaged) {
                char *quoted = quote_character_for_unpaged(buf);
                dm_emit_field(state, dm, out, quoted ? quoted : buf, &need_sep, wrap_col, unpaged);
                free(quoted);
            } else {
                dm_emit_field(state, dm, out, buf, &need_sep, wrap_col, unpaged);
            }
        } else {
            /* INTEGER WRITE field: 11-char right-justified, empirically
             * confirmed against a real HALSFC compile + yaHALMAT run
             * (see commit message / STATUS.md follow-up) -- not yet
             * cross-checked against USA00309's own text. */
            char buf[16];
            snprintf(buf, sizeof(buf), "%11d", state->io_pending.items[i].integer);
            dm_emit_field(state, dm, out, buf, &need_sep, wrap_col, unpaged);
        }
    }
    /* Deliberately does NOT finalize the current line here -- it stays
     * open/buffered (dm->line_buf) for whatever the next vertical move is,
     * whether that's the next WRITE to this same device (dm_advance_lines
     * at the top of this function, next call) or program-end cleanup
     * (interp_cleanup, state.h's device_mech comment) -- matching
     * USA003087 Sec. 12.2's own "device mechanism is left positioned one
     * column to the right of the end of the last data field written,"
     * not "the line is terminated." */
    state->io_pending.active = false;
    state->io_pending.item_count = 0;
}

/* Three things a READ field's own leading position (skipping any
 * ordinary separator first) can turn out to hold, per USA003087 Sec.
 * 12.3/USA003088 Sec. 10.1.1 rules 5-6 and "Programming in HAL/S" Sec.
 * 8.3 (all three agree): ordinary data (go read it normally); a *null
 * field* (a comma/semicolon found where data was expected because it's
 * immediately adjacent to another separator -- leave *this* item's
 * destination untouched, move on to the next item); or a semicolon
 * found as this field's own leading character, which is a stronger,
 * distinct effect from an ordinary null field -- USA003088 rule 5:
 * "a semicolon field separator encountered during a normal sequential
 * scan to fill a variable element terminates the READ statement...
 * [t]he current <variable> element is left unchanged; [a]ll remaining
 * <variable>s in the statement are unchanged" -- i.e. not just this
 * item but the *entire rest of the list*, matching "Programming in
 * HAL/S" p. 153's own worked example ("1.5, 2.6;" into a 3-item list
 * leaves the third untouched) and its array-sum idiom (reading a
 * variable-length list terminated by `;`, leaving the unused tail of
 * an ARRAY at its initial value). */
typedef enum { HALMAT_READ_FIELD_DATA, HALMAT_READ_FIELD_NULL, HALMAT_READ_FIELD_TERMINATE } halmat_read_field_t;

/* Consumes the separator USA003087 Sec. 12.3/USA003088 Sec. 10.1.1 (rule
 * 6) allows before a READ data field ("a comma and/or at least one
 * blank"), classifying what's actually found there as one of the three
 * halmat_read_field_t outcomes above. A semicolon is left unconsumed in
 * the `TERMINATE` case (and a null-triggering comma likewise, one level
 * down -- see below) rather than consumed here, for the reason given next.
 *
 * A semicolon (or any other leftover un-consumed data) found here is
 * left in the stream for a different reason than it might first appear:
 * not because a later part of *this* statement will pick it back up, but
 * because it's the *next* READ/READALL statement's job to discard it, as
 * part of the "device mechanism moves down one line" default positioning
 * USA003087 Sec. 12.3 mandates at the start of every READ but a device's
 * first (see device_read_started's comment in state.h, and OP_READ's own
 * discard_to_eol call below) -- this function only needs to decide *this*
 * statement's own outcome, not clean up after itself.
 *
 * `require_separator` (pass whether any data field of the whole READ
 * statement has already been consumed yet -- OP_READ's own
 * `any_field_read`, not simply an item's index, since a single item can
 * itself expand into several fields for a whole VECTOR/MATRIX
 * destination) distinguishes two call shapes, both needed to get this
 * right without misaligning the whole remaining list (an earlier version
 * of
 * this fix used one shape for every item and *consumed* the first
 * comma it found unconditionally, which shifted every subsequent field
 * over by one whenever a leading comma appeared, instead of nulling
 * just the first item):
 *
 *   - `true` (every item after the first): an ordinary separator is
 *     *expected* here, closing the previous item's field -- skip
 *     blanks, consume exactly one comma if present (space-only
 *     separation like "1 2 3" is also legal and consumes no comma),
 *     skip trailing blanks, then peek for a comma or semicolon
 *     immediately following (rule 6's "preceded by a comma...following
 *     the last comma" case) -- a doubled mid-list comma ("1,,3") nulls
 *     the field in between, leaving its own trailing comma unconsumed
 *     so the *next* item's own `require_separator=true` call treats it
 *     as an ordinary preceding separator in turn (this is what makes a
 *     run of several consecutive nulls, e.g. ",,3", null every field up
 *     to the first one that finds real data).
 *   - `false` (the very first item only): no separator is expected to
 *     precede it at all, so only *peek* at the next non-blank
 *     character rather than requiring/consuming a comma first; a comma
 *     found here means the field the caller is about to read is itself
 *     null-preceded-by-nothing (a *leading* comma, e.g. "READ(5)
 *     A,B,C;" fed ",2,3" -- user-reported, since rule 6's text doesn't
 *     special-case "nothing precedes the first field" out of the
 *     general null-field mechanism, and there's no principled reason
 *     for the first item to behave differently from any other) -- left
 *     unconsumed for the *second* item's own `require_separator=true`
 *     call to treat as its ordinary preceding separator, exactly like
 *     the doubled-comma case above. A semicolon found here terminates
 *     the whole list starting from item 0, same as any other item. */
static halmat_read_field_t read_skip_separator(FILE *in, bool require_separator) {
    int c;
    while ((c = fgetc(in)) != EOF && isspace(c)) {}
    /* Consume one expected ordinary-separator comma, if present -- but
     * unlike an earlier version of this function, don't early-return
     * just because there wasn't one (space-only separation, "1 2 3",
     * legitimately has none): USA003088 Sec. 10.1.1 rule 4 describes
     * the scan as "looking for fields...separated by commas,
     * semicolons, or blanks," so a semicolon reached via plain blanks
     * alone, with no comma at all, still terminates the list -- the
     * checks below must run either way, not just when a comma was
     * found first. */
    if (require_separator && c == ',') {
        while ((c = fgetc(in)) != EOF && isspace(c)) {}
    }
    if (c == ';') {
        ungetc(c, in);
        return HALMAT_READ_FIELD_TERMINATE;
    }
    if (c == ',') {
        ungetc(c, in);
        return HALMAT_READ_FIELD_NULL;
    }
    if (c != EOF) ungetc(c, in);
    return HALMAT_READ_FIELD_DATA;
}

/* USA003087 Sec. 12.3's "the device mechanism moves down one line from
 * its current position and repositions itself at column 1," performed by
 * OP_READ at the start of every READ/READALL but a device's first (see
 * device_read_started's comment in state.h). Discards whatever the
 * *previous* statement against this device left unconsumed on the
 * current line -- most notably a `;`-terminated list's own leftover
 * semicolon (read_skip_separator leaves it unconsumed deliberately, for
 * this to clean up) -- so it can't be misread as this statement's own
 * first field. User-reported: without this, a semicolon left in the
 * stream by one READ(5) A,B,C; iteration of a loop caused every
 * subsequent iteration's READ to see that same semicolon immediately,
 * terminate instantly without reading any new input, and leave A/B/C at
 * their previous values -- an infinite loop that silently reused stale
 * data instead of prompting for more. */
static void discard_to_eol(FILE *in) {
    int c;
    while ((c = fgetc(in)) != EOF && c != '\n') {}
}

/* Binds `state`'s currently-open io_pending call arguments into
 * `target`'s own SYT numbering (positional, entry_syt+1+i -- the same
 * convention FCAL/PCAL already use for same-unit calls, applied here to
 * the *target* unit's own numbering rather than the caller's) and runs
 * `target` from its own entry point to completion of exactly one call --
 * a cross-unit call into a separately-compiled EXTERNAL FUNCTION/
 * PROCEDURE (source-documentation/Multiple-file-problem.md), triggered
 * by FCAL/PCAL below via state->external_calls[].
 *
 * `target` is a persistent, previously interp_init'd state for the
 * external unit (main.c's interp_set_external_units) -- reused across
 * every call to it, not recreated fresh each time. Its own SYT storage
 * (ordinary local variables) therefore intentionally persists across
 * repeated calls, matching how a same-unit function's own locals
 * already behave (no per-call freshness is modeled anywhere in this
 * interpreter, so this isn't a new inconsistency). Scheduler/task state
 * is reset to a single fresh READY primal task before each call, since
 * concurrent scheduling across units is explicitly out of scope for now
 * (per direct user guidance) -- an external call is always a plain
 * synchronous call, never a SCHEDULEd task of its own.
 *
 * Returns false (having already called fail() on `state`, the *caller*)
 * if entry_syt has no FDEF/PDEF in `target`, there are too many
 * arguments, or the callee itself failed (its own fail() has already
 * fired against `target`, e.g. for a genuinely unimplemented opcode
 * reached inside the callee's own body). */
bool interp_prepare_external_call(halmat_state_t *state, halmat_state_t *target, uint16_t entry_syt) {
    if (target->symbol_def_pos[entry_syt] == NO_TARGET) {
        fail(state, "external call has no entry point (symbol %u)", entry_syt);
        return false;
    }
    for (uint8_t i = 0; i < state->io_pending.item_count; i++) {
        uint16_t param_syt = resolve_param_syt(target, entry_syt, i);
        if (param_syt >= HALMAT_SYT_MAX) { fail(state, "too many call arguments"); return false; }
        if (!bind_call_argument(state, target, param_syt, i)) return false;
    }
    target->pc = target->symbol_def_pos[entry_syt] + 1;
    target->halted = false;
    target->exit_code = 0;
    target->in_external_call = true;
    target->external_call_has_result = false;
    target->call_return_sp = 0;
    target->inline_func_sp = 0;
    target->current_task = 0;
    target->tasks[0].task_state = TASK_READY;
    target->tasks[0].saved_pc = target->pc;
    return true;
}

bool interp_finish_external_call(halmat_state_t *state, halmat_state_t *target) {
    if (target->exit_code != 0) {
        fail(state, "external call failed");
        return false;
    }
    return true;
}

bool interp_copy_external_call_result(halmat_state_t *state, halmat_state_t *target, const halmat_instr_t *ins) {
    if (!target->external_call_has_result) {
        fail(state, "external function returned no value");
        return false;
    }
    if (ins->index >= HALMAT_VAC_MAX) { fail(state, "VAC index out of range"); return false; }
    if (target->external_call_result.is_string) {
        /* Owned heap pointer (char*) -- copying the slot verbatim would
         * alias ownership between this caller's own VAC array and the
         * callee's, risking a double-free when both states are eventually
         * cleaned up. Deep-copy instead, same dup_string convention used
         * throughout this file for every other owned-string handoff. */
        state->vac[ins->index] = target->external_call_result;
        state->vac[ins->index].string = dup_string(target->external_call_result.string);
        return true;
    }
    if (target->external_call_result.is_container) {
        /* Same aliasing concern as is_string above, for the owned
         * halmat_scalar_t* container pointer (MATRIX/VECTOR return
         * value) -- deep-copy via a fresh malloc+memcpy. */
        state->vac[ins->index] = target->external_call_result;
        size_t n = target->external_call_result.container_count;
        state->vac[ins->index].container = malloc(n * sizeof(halmat_scalar_t));
        memcpy(state->vac[ins->index].container, target->external_call_result.container, n * sizeof(halmat_scalar_t));
        return true;
    }
    state->vac[ins->index] = target->external_call_result;
    return true;
}

bool interp_is_external_call(const halmat_state_t *state, const halmat_instr_t *ins,
                              halmat_state_t **target_out, uint16_t *entry_syt_out, bool *is_function_out) {
    if (!ins || (ins->opcode != OP_FCAL && ins->opcode != OP_PCAL) || ins->operand_count != 1) return false;
    uint16_t callee = resolve_call_target(state, ins->operands[0].data);
    if (callee >= HALMAT_SYT_MAX || state->symbol_def_pos[callee] != NO_TARGET) return false;
    if (!state->external_calls || !state->external_calls[callee].target_state) return false;
    if (target_out) *target_out = state->external_calls[callee].target_state;
    if (entry_syt_out) *entry_syt_out = state->external_calls[callee].target_entry_syt;
    if (is_function_out) *is_function_out = (ins->opcode == OP_FCAL);
    return true;
}

/* Runs a cross-unit call (source-documentation/Multiple-file-problem.md)
 * to completion in one shot -- `target` is a persistent, previously
 * interp_init'd state for the external unit (main.c's
 * interp_set_external_units), reused across every call to it, not
 * recreated fresh each time. Its own SYT storage (ordinary local
 * variables) therefore intentionally persists across repeated calls,
 * matching how a same-unit function's own locals already behave (no
 * per-call freshness is modeled anywhere in this interpreter, so this
 * isn't a new inconsistency). Scheduler/task state is reset to a single
 * fresh READY primal task before each call (interp_prepare_external_
 * call()), since concurrent scheduling across units is explicitly out of
 * scope for now (per direct user guidance) -- an external call is always
 * a plain synchronous call, never a SCHEDULEd task of its own.
 *
 * Just interp_prepare_external_call() + interp_run() + interp_finish_
 * external_call() -- the atomic path OP_FCAL/OP_PCAL's own cross-unit
 * branches use below, and what --debugger's `next` command gets for free
 * simply by calling interp_step() on the FCAL/PCAL instruction itself
 * (exec_one() below reaches this same function). Only `step`, which
 * needs to run the callee via its *own* step loop instead of straight
 * through, calls the two phases directly rather than through this
 * wrapper (debug.c). */
static bool run_external_call(halmat_state_t *state, halmat_state_t *target, uint16_t entry_syt, FILE *out) {
    if (!interp_prepare_external_call(state, target, entry_syt)) return false;
    interp_run(target, out);
    return interp_finish_external_call(state, target);
}

/* Ends the current process/task's execution -- extracted from OP_CLOS's
 * own "no active call frame" branches (below) so OP_RTRN can reach the
 * exact same logic when RETURN is executed with no active call frame,
 * no open inline-FUNCTION, and not as an external-call target: RETURN
 * reached inside an ON-ERROR/ERSE-triggered inline action body (which
 * has no call frame of its own) previously fell straight through to
 * OP_RTRN's own "no active call" fail() instead -- user-reported
 * (194-TEST_X.hal's `ON ERROR ... DO; ...; RETURN; END;`, matching
 * USA003087 p.194's own worked example). class-0/RTRN.md's "every
 * subprogram body is terminated regardless" note makes no distinction
 * between an explicit top-level RETURN and naturally falling through to
 * CLOS -- USA003087 Sec. 13.3's task-vs-process closing rules apply
 * identically either way, so this must be the same code, not a
 * parallel reimplementation of it. */
static void close_current_process(halmat_state_t *state, bool *branched) {
    if (!state->tasks[state->current_task].is_primal) {
        /* A scheduled task's body fell through to its own end
         * without an explicit TERMINATE -- either genuine
         * completion (class-0/RTRN.md's "every subprogram body
         * is terminated regardless" note, TASK analog) or, for
         * a cyclic (REPEAT) task, just the end of one cycle.
         * Explicit TERMINATE/CANCEL (OP_TERM/OP_CANC below)
         * always end the task outright and bypass this rearm
         * check entirely -- only a *fallthrough* CLOS is
         * eligible to rearm, matching REPEAT/WHILE/UNTIL's
         * role as governing the task's own natural completion,
         * not something an explicit mid-body CANCEL could be
         * talked out of. */
        halmat_task_t *cur = &state->tasks[state->current_task];
        bool stop = true;
        if (cur->repeat_kind != SCHD_REPEAT_NONE) {
            /* Stopping-condition expressions are evaluated only
             * here -- once per completed cycle, at the moment
             * the task would otherwise be rearmed -- never
             * continuously every tick. class-0/SCHD.md frames
             * WHILE/UNTIL as governing *whether the cycle
             * continues*, the same "test at the iteration
             * boundary" shape HAL/S's own DO WHILE/DO UNTIL
             * loops use (already this interpreter's CFOR
             * pattern) -- there's no primary-source basis for
             * treating it as an asynchronous mid-execution
             * interrupt, and WAIT is already the language's
             * only mechanism for a task to suspend mid-body. */
            switch (cur->stop_kind) {
                case SCHD_STOP_NONE:
                    stop = false;
                    break;
                case SCHD_STOP_UNTIL_TIME:
                    stop = (state->virtual_time >= cur->stop_deadline);
                    break;
                case SCHD_STOP_WHILE_BIT: {
                    /* WHILE <bit exp>: keep cycling while true, stop once false. */
                    uint32_t v;
                    stop = !reevaluate_live_bit_operand(state, &cur->stop_event_op, &v) || v == 0;
                    break;
                }
                case SCHD_STOP_UNTIL_BIT: {
                    /* UNTIL <bit exp>: keep cycling until true, stop once true. */
                    uint32_t v;
                    stop = reevaluate_live_bit_operand(state, &cur->stop_event_op, &v) && v != 0;
                    break;
                }
            }
        }
        if (!stop) {
            /* Rearming jumps this task's own pc back to its
             * body's start -- must go through the same state-
             * >pc/branched mechanism TDEF/RTRN use (not a bare
             * cur->saved_pc write), since exec_one's own tail
             * ("if (!branched) state->pc++") and interp_step's
             * post-exec_one "saved_pc = state->pc" would
             * otherwise clobber it with CLOS's own position+1
             * right after this case returns. */
            state->pc = state->symbol_def_pos[cur->symbol] + 1;
            *branched = true;
            switch (cur->repeat_kind) {
                case SCHD_REPEAT_BARE:
                    /* No interval -- immediate back-to-back retrigger. */
                    cur->task_state = TASK_READY;
                    break;
                case SCHD_REPEAT_EVERY:
                    /* Fixed period, chained off the previous
                     * target (not off "now") so a late-running
                     * cycle doesn't push later ones out --
                     * every_phase_ref already holds that
                     * previous target (set at SCHD time, or by
                     * the prior rearm), kept in its own field
                     * (state.h) so it can't be clobbered by an
                     * internal WAIT in the task's body (OP_WAIT
                     * only ever touches wake_deadline). Assign
                     * wake_deadline from the post-increment
                     * value since sched_wake_waiting() only
                     * ever reads wake_deadline, never this
                     * field directly. */
                    cur->every_phase_ref += cur->repeat_interval;
                    cur->wake_deadline = cur->every_phase_ref;
                    cur->task_state = TASK_WAITING;
                    break;
                case SCHD_REPEAT_AFTER:
                    /* Delay measured from *this* completion,
                     * so it does drift with however long the
                     * cycle actually took -- the language-level
                     * distinction from EVERY. */
                    cur->wake_deadline = state->virtual_time + cur->repeat_interval;
                    cur->task_state = TASK_WAITING;
                    break;
                case SCHD_REPEAT_ON:
                    /* Self-reschedule ON <event>, synthesized
                     * above -- has_on_event/on_event_op are
                     * already set from that SCHD call; just wait
                     * on the event again, same as a brand-new
                     * ON-initiated task. */
                    cur->task_state = TASK_WAITING_ON;
                    break;
                default:
                    break;
            }
        } else if (has_active_dependents(state, state->current_task)) {
            /* USA003087 Sec. 13.3: "If execution ends on a
             * CLOSE or RETURN statement, the process goes
             * into the inactive state directly only if it
             * has no dependents. Otherwise, it goes into a
             * waiting state until the dependents have in
             * their turn terminated." Deferred, not
             * abandoned -- sched_wake_dependents() (checked
             * every tick) finalizes this once true, and
             * symbol_active_task is deliberately left
             * pointing at this task until then: it's still
             * the sole active process for this task symbol
             * (just in a different minor state), so a new
             * SCHEDULE of the same symbol must still be
             * rejected in the meantime. */
            cur->task_state = TASK_WAITING_FOR_DEPENDENTS;
        } else {
            cur->task_state = TASK_TERMINATED;
            if (cur->symbol < HALMAT_SYT_MAX) state->symbol_active_task[cur->symbol] = -1;
        }
    } else if (has_active_dependents(state, state->current_task)) {
        /* Primal process closing, but with a still-active
         * DEPENDENT task (user-reported bug, COUNTUP2.hal/
         * NESTED_TASK_SCHEDULE_TEST.hal) -- same Sec. 13.3
         * rule as the non-primal branch above applies
         * identically here (Sec. 13.3's own "programs and
         * tasks are treated together since their
         * representations at run time are in both cases real
         * time processes"): the primal doesn't halt yet, it
         * waits. Once sched_wake_dependents() finds no
         * dependents left, it sets state->halted itself --
         * that's still what finally ends the whole program,
         * per Sec. 13.1's overriding "all other processes are
         * always dependent on the primal process for their
         * existence" rule (which cuts off anything else still
         * running at that point, dependent or not). */
        state->tasks[state->current_task].task_state = TASK_WAITING_FOR_DEPENDENTS;
    } else {
        /* Primal process closing with no active dependents --
         * per USA003087 Sec. 13.3, ends the whole program
         * immediately (Sec. 13.1's overriding dependency rule
         * means nothing else could legitimately outlive this
         * anyway). */
        state->halted = true;
        state->exit_code = 0;
    }
}

/* Executes exactly one instruction for whatever task is current
 * (state->current_task, state->pc already set to its saved_pc by the
 * scheduler loop in interp_run). Split out from interp_run so the
 * scheduler can interleave tasks at instruction granularity -- see
 * state.h's scheduler field comments. */
static void exec_one(halmat_state_t *state, FILE *out) {
    (void)out; /* WRIT/READ now resolve their own device via state->devices
                * (--ddi/--ddo, state.h) rather than this parameter; kept
                * for interp_step/interp_run's public signature stability. */
    {
        const halmat_instr_t *ins = &state->prog->instrs[state->pc];
        resolved_value_t a, b;
        bool branched = false;

        switch (ins->opcode) {
            case OP_EXTN:
                /* "Extended pointer" -- resolves a structure-variable
                 * reference for a following TASN/TEQU/TNEQ or ordinary
                 * xASN-family opcode to consume via a QUAL_XPT operand
                 * referencing this instruction's own stream position
                 * (class-0/EXTN.md). Two operands always: base structure
                 * symbol, then either a specific field's symbol
                 * (qualified reference, e.g. ZQ1.QI) or the structure's
                 * own TEMPLATE symbol (bare/unqualified reference, e.g.
                 * plain ZQ1) -- EXTN.md's confirmed shape. No runtime
                 * effect of its own beyond recording this for later
                 * lookup (find_or_create_struct_field/resolve_xpt_field).
                 *
                 * The base operand is ordinarily QUAL_SYT (the plain
                 * structure symbol; struct_copy_index=-1, meaning "use
                 * whatever copy is ambient" -- current_copy_index()).
                 * When a single-copy-select subscript is present (e.g.
                 * `ZQ3 = ZQ1; S 2` picking ZQ3's copy 2, class-0/TSUB.md),
                 * the base is instead QUAL_VAC referencing a preceding
                 * TSUB's own stream position -- an *explicit* copy index
                 * that overrides the ambient one. */
                if (ins->operand_count != 2) { fail(state, "EXTN: expected 2 operands"); break; }
                if (ins->operands[1].qual != QUAL_SYT) {
                    fail(state, "EXTN: expected a SYT field operand");
                    break;
                }
                if (ins->index >= HALMAT_VAC_MAX) { fail(state, "VAC index out of range"); break; }
                if (ins->operands[0].qual == QUAL_SYT) {
                    state->vac[ins->index].is_ref = false;
                    state->vac[ins->index].is_struct_ref = true;
                    state->vac[ins->index].struct_base_syt = ins->operands[0].data;
                    state->vac[ins->index].struct_field_syt = ins->operands[1].data;
                    state->vac[ins->index].struct_copy_index = -1;
                } else if (ins->operands[0].qual == QUAL_VAC) {
                    if (ins->operands[0].data >= HALMAT_VAC_MAX) { fail(state, "EXTN: VAC index out of range"); break; }
                    const halmat_vac_slot_t *copy_slot = &state->vac[ins->operands[0].data];
                    if (!copy_slot->is_copy_ref) { fail(state, "EXTN: VAC base operand does not reference a TSUB result"); break; }
                    state->vac[ins->index].is_ref = false;
                    state->vac[ins->index].is_struct_ref = true;
                    state->vac[ins->index].struct_base_syt = copy_slot->copy_ref_base_syt;
                    state->vac[ins->index].struct_field_syt = ins->operands[1].data;
                    state->vac[ins->index].struct_copy_index = copy_slot->copy_ref_copy_index;
                } else {
                    fail(state, "EXTN: unsupported base operand qualifier %s", halmat_qual_name(ins->operands[0].qual));
                    break;
                }
                break;

            case OP_TSUB:
                /* Structure-copy subscript specifier, single-copy-select
                 * form only (class-0/TSUB.md) -- range-select (3
                 * operands) fails loudly, untested. Two operands: the
                 * multi-copy structure's own SYT, then the copy number,
                 * either a literal (QUAL_IMD) or an expression (per
                 * USA003087 Sec 19.6, which documents both as legal) --
                 * the expression case's own shape confirmed empirically
                 * against real compiled HALMAT, user-reported
                 * (180/184-EXAMPLE_N.hal's `V.STATUS$(N)`/`V.TIMETAG$(N)`,
                 * N a plain loop-counter INTEGER, and 264-INITIALIZE.hal's
                 * `TQ.NEXT$(N)`): a plain QUAL_SYT operand referencing the
                 * variable directly (tag1=0x09, distinct from the literal
                 * form's own tag1), not a VAC-qualified arithmetic chain
                 * -- resolved the same way any other integer-valued SYT
                 * read would be. A genuinely computed expression (e.g.
                 * `V.STATUS$(N+1)`) would presumably show up as QUAL_VAC
                 * instead; not exercised by any fixture yet, so not
                 * handled here. Result consumed by a following EXTN via a
                 * QUAL_VAC operand referencing TSUB's own stream position
                 * (see OP_EXTN above), not used directly by anything
                 * else. */
                if (ins->operand_count != 2) { fail(state, "TSUB: only the single-copy-select form (2 operands) is implemented"); break; }
                if (ins->operands[0].qual != QUAL_SYT) { fail(state, "TSUB: expected a SYT structure operand"); break; }
                if (ins->index >= HALMAT_VAC_MAX) { fail(state, "VAC index out of range"); break; }
                {
                    int32_t copy_number;
                    if (ins->operands[1].qual == QUAL_IMD) {
                        copy_number = (int32_t)(int16_t)ins->operands[1].data;
                    } else if (ins->operands[1].qual == QUAL_SYT) {
                        resolved_value_t cv;
                        if (!resolve_operand(state, &ins->operands[1], &cv)) break;
                        copy_number = rv_to_integer(&cv);
                    } else {
                        fail(state, "TSUB: only a literal or plain-SYT copy index is implemented");
                        break;
                    }
                    state->vac[ins->index].is_ref = false;
                    state->vac[ins->index].is_copy_ref = true;
                    state->vac[ins->index].copy_ref_base_syt = ins->operands[0].data;
                    /* Copy numbers are 1-based in HAL/S source (`copy 2`)
                     * but this interpreter's copy_index is 0-based
                     * (matches arrayed_index's own 0-based convention, and
                     * ADLP's count directly, per state.h) -- subtract 1. */
                    state->vac[ins->index].copy_ref_copy_index = copy_number - 1;
                }
                break;

            case OP_STRI:
                /* Names the target for a following repeated-initialize
                 * group (class-8/STRI.md). Two distinct forms, per the
                 * operand's own qualifier:
                 * - QUAL_SYT: the `n#value` array-repetition form
                 *   (SLRI/ELRI/ETRI, class-8/SLRI.md) -- stri_target_syt
                 *   is the array's own symbol, consumed by
                 *   write_destination's QUAL_OFF case.
                 * - QUAL_XPT: the whole-structure INITIAL(...) form
                 *   (TINT, class-8/TINT.md) -- the operand is a bare/
                 *   unqualified EXTN reference (struct_field_syt is the
                 *   TEMPLATE's own symbol, not a real field). Records
                 *   both the structure *instance*'s own SYT
                 *   (stri_target_syt, the shadow-slot storage base) and
                 *   the TEMPLATE's SYT (stri_target_template_syt, used
                 *   to compute each terminal's own field symbol via
                 *   offset arithmetic -- see TINT's own case). */
                state->stri_target_template_syt = -1;
                if (ins->operand_count == 1 && ins->operands[0].qual == QUAL_SYT) {
                    state->stri_target_syt = (int32_t)ins->operands[0].data;
                } else if (ins->operand_count == 1 && ins->operands[0].qual == QUAL_XPT) {
                    if (ins->operands[0].data < HALMAT_VAC_MAX) {
                        const halmat_vac_slot_t *slot = &state->vac[ins->operands[0].data];
                        if (slot->is_struct_ref) {
                            state->stri_target_syt = (int32_t)slot->struct_base_syt;
                            state->stri_target_template_syt = (int32_t)slot->struct_field_syt;
                        }
                    }
                }
                break;

            case OP_NOP:
            case OP_PXRC:
            case OP_XREC:
            case OP_SMRK:
            case OP_MDEF:
            case OP_CDEF:
            case OP_EDCL:
            case OP_DSMP:
            case OP_ESMP:
            case OP_DTST:
            case OP_IFHD:
            case OP_LBL:
            case OP_ADLP:
            case OP_IDLP:
            case OP_DLPE:
            case OP_SLRI:
            case OP_ELRI:
            case OP_ETRI:
            case OP_IMRK:
            case OP_TDCL:
            case OP_UDEF:
            case OP_EINT:
                /* IMRK (class-0/IMRK.md) brackets each statement inside
                 * an inline FUNCTION block -- a pure marker (see
                 * OP_IDEF/OP_ICLS below for the block's own open/close
                 * handling). TDCL (class-0/TDCL.md, `TEMPORARY`
                 * data-item declaration) generates no code of its own
                 * ("pure declaration" per its confirmed trace). UDEF
                 * (class-0/UDEF.md) just labels an update block's own
                 * name; the block's body is ordinary already-supported
                 * HALMAT. EINT (`EQUATE EXTERNAL`, class-8/EINT.md) is
                 * pure linker metadata for non-HAL/S callers -- "takes
                 * up no space," generates an ESD entry-point record at
                 * the object-code level, and its new equate name is
                 * flagged INACTIVE so HAL/S itself can never reference
                 * it again (confirmed: doing so is a compile error) --
                 * nothing for this interpreter to do at runtime. */
                /* Structural/bookkeeping markers; no runtime effect on
                 * their own. DTST/LBL just open a bookkeeping label --
                 * the real work happens in CTST/ETST/BRA/FBRA below.
                 * ADLP/DLPE (class-0/ADLP.md) are reached directly here
                 * only as a defensive fallback -- interp_step's own
                 * arrayed-paragraph replay (state.h's arrayed_paragraph_
                 * end/_count, precompute_arrayed_paragraphs) normally
                 * jumps straight past a recognized ADLP/DLPE pair without
                 * ever executing them individually. Falling through to
                 * here (role 3's structureness metadata, which never
                 * wraps a real body; or a role 1/2 shape this session's
                 * precompute didn't recognize) is a safe no-op either
                 * way -- see ADLP.md's own confirmation that role 3
                 * "brackets no HALMAT loop body at all". */
                break;

            case OP_ERSE: {
                /* SEND ERROR (ERSE, class-0/ERSE.md), USA003087 Sec. 25.3:
                 * "the recovery action taking place on execution of a
                 * SEND ERROR statement is as if the corresponding run
                 * time error had really occurred." An earlier version of
                 * this comment claimed the opcode itself was unreached/
                 * unresolved -- wrong; compiling a real `SEND ERROR$(m:n);`
                 * (199-P.hal, "Programming in HAL/S" p.199) confirms ERSE
                 * IS what it compiles to, with one IMD operand carrying
                 * DATA=group, TAG1=member (the same packed encoding
                 * ERON's own group:member operand uses).
                 *
                 * real gpc's own runtime behavior for this statement was
                 * cross-checked directly (three separate probes: the
                 * 199-P.hal corpus file, a group-5/RETURN registration, a
                 * group-5/IGNORE registration) and turned out to always
                 * print a raw system message and fall through to the next
                 * statement regardless of which handler was registered --
                 * indistinguishable from an unimplemented stub, not real
                 * dispatch (gpc is not authoritative here; see this
                 * project's own notes on that). Implemented instead per
                 * the language spec and independent confirmation from
                 * yaGPC2 (a from-scratch reimplementation that does
                 * dispatch correctly here): looks up the matching handler
                 * the exact same way arithmetic_error_should_apply_fixup
                 * does for real runtime errors (same shared table,
                 * find_error_handler, same exact/group/all precedence),
                 * branches on GOTO, applies any AND SET/RESET/SIGNAL event
                 * action, and otherwise (SYSTEM, IGNORE, or no handler
                 * registered) just falls through to the next statement --
                 * there's no computed value to "fix up" for a simulated
                 * error the way there is for e.g. SQRT<0, so SYSTEM's
                 * "standard system recovery action" and IGNORE both reduce
                 * to the same no-op-but-continue behavior here. Doesn't
                 * print gpc's own "*** HAL/S SEND ERROR: RUNTIME: #N ERROR
                 * M" message -- gpc's version didn't correlate cleanly
                 * with group/member in testing, and no primary source
                 * confirms real hardware's exact wording, so silence was
                 * preferred over guessing at unverified text. */
                if (ins->operand_count != 1) { fail(state, "ERSE: expected 1 operand"); break; }
                int group = (int)ins->operands[0].data;
                int member = (int)ins->operands[0].tag1;
                state->last_error_group = group;
                state->last_error_member = member;
                halmat_error_handler_t *h = find_error_handler(state, group, member);
                if (h && h->has_event_action && h->event_syt < HALMAT_SYT_MAX) {
                    halmat_syt_entry_t *e = &state->syt[h->event_syt];
                    e->type = SYT_TYPE_BIT;
                    e->bit_value = (h->event_action == HALMAT_EVENT_RESET) ? 0 : 1;
                }
                if (h && h->action == HALMAT_ERRACT_GOTO) {
                    state->pc = h->goto_pc;
                    branched = true;
                }
                break;
            }

            case OP_ERON: {
                /* ON ERROR/OFF ERROR (class-0/ERON.md). `ins->tag` is a
                 * 4-way discriminant confirmed against real compiled
                 * HALMAT: 0=user-statement (GOTO) form, 1=SYSTEM,
                 * 2=IGNORE, 3=OFF. operand[0] is the packed error
                 * group:member specification (DATA=group, 255="all
                 * groups"; TAG1=member, 63="all members in group").
                 *
                 * **Session finding, correcting an earlier session's
                 * documentation error**: for the user-statement (GOTO)
                 * form, ERON.md's own compiled trace already shows
                 * "BC 7,L#1 <- unconditional branch skipping the handler
                 * code in normal flow" as part of ERON's *own* generated
                 * object code -- not a separate BRA HALMAT instruction
                 * emitted after it, as an earlier session's comment here
                 * mistakenly assumed (no such separate BRA exists in the
                 * HALMAT stream; confirmed by decoding a real compile of
                 * `ON ERROR$(4:27) GO TO SKIPPED;` directly). That
                 * mistaken assumption made this whole case a no-op,
                 * which left the inline handler body (the compiled GOTO
                 * itself, sitting directly after ERON) executing
                 * unconditionally on every pass through normal flow --
                 * exactly the "line after ON ERROR never runs" bug a
                 * user report against a modified `029-DATATYPES.hal`
                 * (USA003087 Sec. 25 example) diagnosed. Fixed by having
                 * this form perform that same unconditional skip itself,
                 * identically to OP_BRA/OP_FBRA's own `state->label_pos[]`
                 * lookup (populated by precompute_labels() from *any*
                 * OP_LBL instruction regardless of its operand's SYT/INL
                 * qualifier, so the compiler's internal "bookkeeping
                 * label" numbering -- confirmed distinct from ordinary
                 * SYT-indexed statement labels like the `SKIPPED:` in
                 * the trace above -- resolves through the exact same
                 * table BRA already uses).
                 *
                 * **Still not implemented**: USA003087 Sec. 25.1's per-
                 * block dynamic-scoping rule (a modification made inside
                 * a PROCEDURE/FUNCTION is unwound on return from it) --
                 * this table is flat/global for the whole run. Consulted
                 * by only one App. C "standard fixup" site so far (BFNC
                 * INVERSE selector 49 and MINV's `M**(-1)`, error 27 --
                 * the specific case the bug report exercised); every
                 * other fixup site (UNIT null vector, SQRT<0, etc.)
                 * still always applies its own fixup unconditionally,
                 * not yet consulting this table. IGNORE's exact
                 * semantics for a *value-producing* built-in (as opposed
                 * to a procedural side-effect error) aren't spelled out
                 * by the primary source's examples, so it's treated the
                 * same as SYSTEM (apply the standard fixup) pending a
                 * clearer primary-source citation or test case. The
                 * `AND SET/RESET/SIGNAL` event-modification clause is now
                 * implemented -- see the tag==1/2 branch below and
                 * arithmetic_error_should_apply_fixup()'s own comment. */
                if (ins->operand_count < 1) { fail(state, "ERON: expected at least 1 operand"); break; }
                int group = ins->operands[0].data == 255 ? -1 : (int)ins->operands[0].data;
                int member = ins->operands[0].tag1 == 63 ? -1 : (int)ins->operands[0].tag1;
                if (ins->tag == 0) {
                    if (ins->operand_count != 2) { fail(state, "ERON: expected 2 operands for the user-statement form"); break; }
                    uint16_t label = ins->operands[1].data;
                    if (label >= HALMAT_LABEL_MAX || state->label_pos[label] == NO_TARGET) {
                        fail(state, "ERON: undefined bookkeeping label %u", label);
                        break;
                    }
                    /* Two distinct targets, easy to conflate: the
                     * handler's own goto_pc (consulted only when a
                     * matching error later actually occurs) must be
                     * where the inline handler body *starts* -- the very
                     * next instruction after this ERON, exactly where
                     * ordinary fall-through would have gone had ERON not
                     * skipped it -- not the bookkeeping label's position,
                     * which is where fall-through *lands after* the
                     * handler body. Using the bookkeeping-label position
                     * for both (an earlier version of this fix did)
                     * makes the registered handler jump back into the
                     * middle of its own "normal continuation" code
                     * instead of the handler body, an infinite loop the
                     * first time it actually fires. */
                    register_error_handler(state, group, member, HALMAT_ERRACT_GOTO, state->pc + 1, false, 0, HALMAT_EVENT_SIGNAL);
                    state->pc = state->label_pos[label];
                    branched = true;
                } else if (ins->tag == 1 || ins->tag == 2) {
                    /* AND SET/RESET/SIGNAL var (class-0/ERON.md's confirmed
                     * 3-way TAG2 sub-flag on the event operand: 0=SIGNAL,
                     * 1=SET, 2=RESET) -- stored alongside the SYSTEM/IGNORE
                     * action itself, and applied (SGNL-style direct BIT
                     * write; RESET is the same write with 0 instead of 1,
                     * there being no other runtime difference this
                     * interpreter models between a plain/latched event or
                     * SET-vs-SIGNAL's "persistent" vs "transient" nuance --
                     * see OP_SGNL's own comment) at the one site that
                     * actually detects a matching error and consults this
                     * table: arithmetic_error_should_apply_fixup(). */
                    bool has_event_action = false;
                    uint16_t event_syt = 0;
                    halmat_error_event_action_t event_action = HALMAT_EVENT_SIGNAL;
                    if (ins->operand_count == 2) {
                        if (ins->operands[1].qual != QUAL_SYT) {
                            fail(state, "ERON: AND SET/RESET/SIGNAL expects a plain EVENT symbol operand");
                            break;
                        }
                        has_event_action = true;
                        event_syt = ins->operands[1].data;
                        event_action = (halmat_error_event_action_t)ins->operands[1].tag2;
                    }
                    register_error_handler(state, group, member,
                                            ins->tag == 1 ? HALMAT_ERRACT_SYSTEM : HALMAT_ERRACT_IGNORE, 0,
                                            has_event_action, event_syt, event_action);
                } else if (ins->tag == 3) {
                    unregister_error_handler(state, group, member);
                } else {
                    fail(state, "ERON: unrecognized opcode-line tag %u", ins->tag);
                }
                break;
            }

            case OP_TASN: {
                /* Structure assign, class-0/TASN.md: source-first,
                 * receiver-second, both QUAL_XPT (stream position of
                 * the resolving EXTN) referencing a *bare* structure
                 * reference. Real hardware copies the whole structure
                 * as a byte blob; this interpreter has no byte-layout
                 * model (state.h's halmat_struct_field_t comment), so
                 * instead copies every field this interpreter has
                 * itself already tracked (via a prior qualified
                 * assignment) from the source's shadow slots to the
                 * receiver's -- an approximation that's exact once every
                 * field has been touched individually at least once, but
                 * won't reproduce a field the source never had assigned
                 * (stays at the receiver's own prior/zero value instead
                 * of copying source's zero-initialized default). */
                if (ins->operand_count != 2) { fail(state, "TASN: expected 2 operands"); break; }
                if (ins->operands[0].qual != QUAL_XPT || ins->operands[1].qual != QUAL_XPT) {
                    fail(state, "TASN: both operands must be XPT");
                    break;
                }
                if (ins->operands[0].data >= HALMAT_VAC_MAX || ins->operands[1].data >= HALMAT_VAC_MAX) {
                    fail(state, "TASN: XPT stream position out of range");
                    break;
                }
                const halmat_vac_slot_t *src_ref = &state->vac[ins->operands[0].data];
                const halmat_vac_slot_t *dst_ref = &state->vac[ins->operands[1].data];
                if (!src_ref->is_struct_ref || !dst_ref->is_struct_ref) {
                    fail(state, "TASN: XPT operand does not reference an EXTN result");
                    break;
                }
                uint16_t src_base = src_ref->struct_base_syt, dst_base = dst_ref->struct_base_syt;
                int32_t ambient_idx = current_copy_index(state);
                int32_t src_copy_idx = src_ref->struct_copy_index >= 0 ? src_ref->struct_copy_index : ambient_idx;
                int32_t dst_copy_idx = dst_ref->struct_copy_index >= 0 ? dst_ref->struct_copy_index : ambient_idx;
                /* Snapshot the count first: find_or_create may realloc/append
                 * (a field touched on the destination for the first time)
                 * while we're iterating, which would otherwise walk into
                 * newly-appended entries. */
                size_t count = state->struct_field_count;
                bool ok = true;
                for (size_t i = 0; ok && i < count; i++) {
                    if (state->struct_fields[i].base_syt != src_base || state->struct_fields[i].copy_index != src_copy_idx) continue;
                    uint16_t field = state->struct_fields[i].field_syt;
                    /* Snapshot the source's scalar fields by value before
                     * find_or_create_struct_field's possible realloc (which
                     * would invalidate a pointer into struct_fields[i]). */
                    halmat_syt_entry_t src_snapshot = state->struct_fields[i].value;
                    halmat_syt_entry_t *dst_field = find_or_create_struct_field(state, dst_base, field, dst_copy_idx);
                    if (src_snapshot.elements || src_snapshot.bit_elements || src_snapshot.char_elements) {
                        /* ARRAY/MATRIX/VECTOR structure terminal -- deep
                         * copy, same three-way numeric/BIT/CHARACTER
                         * storage-kind dispatch already established
                         * elsewhere (e.g. write_container_element).
                         * Previously failed loudly here as unreachable
                         * ("no HALSFC-compilable program can get non-zero
                         * per-element data into a structure-terminal
                         * array field... for TASN to ever copy") -- no
                         * longer true: task #38's whole-structure READ
                         * (`READ(5) ARG;`, a STRUCTURE with a VECTOR
                         * terminal) is the first mechanism that populates
                         * exactly this, unblocking the deep copy this
                         * comment already described as "mechanically
                         * straightforward." *dst_field = src_snapshot
                         * (the plain-scalar path below) would alias the
                         * two entries' elements/bit_elements/char_elements
                         * pointers together instead of copying -- a
                         * double-free/dangling-pointer bug the first time
                         * either side's own storage is freed/reallocated,
                         * so this can't reuse that shortcut the way the
                         * scalar case does. */
                        free(dst_field->elements);
                        free(dst_field->bit_elements);
                        if (dst_field->char_elements) {
                            for (size_t k = 0; k < dst_field->element_count; k++) free(dst_field->char_elements[k]);
                            free(dst_field->char_elements);
                        }
                        size_t n = src_snapshot.element_count;
                        if (src_snapshot.elements) {
                            halmat_scalar_t *copy = malloc(n * sizeof(halmat_scalar_t));
                            memcpy(copy, src_snapshot.elements, n * sizeof(halmat_scalar_t));
                            dst_field->elements = copy;
                            dst_field->bit_elements = NULL;
                            dst_field->char_elements = NULL;
                        } else if (src_snapshot.bit_elements) {
                            uint32_t *copy = malloc(n * sizeof(uint32_t));
                            memcpy(copy, src_snapshot.bit_elements, n * sizeof(uint32_t));
                            dst_field->elements = NULL;
                            dst_field->bit_elements = copy;
                            dst_field->char_elements = NULL;
                        } else {
                            char **copy = malloc(n * sizeof(char *));
                            for (size_t k = 0; k < n; k++) copy[k] = dup_string(src_snapshot.char_elements[k]);
                            dst_field->elements = NULL;
                            dst_field->bit_elements = NULL;
                            dst_field->char_elements = copy;
                        }
                        dst_field->element_count = n;
                        dst_field->rows = src_snapshot.rows;
                        dst_field->cols = src_snapshot.cols;
                        dst_field->array_of_vector = src_snapshot.array_of_vector;
                        continue;
                    }
                    free(dst_field->char_value);
                    *dst_field = src_snapshot;
                    dst_field->char_value = src_snapshot.char_value ? dup_string(src_snapshot.char_value) : NULL;
                }
                if (!ok) break;
                break;
            }

            case OP_TEQU:
            case OP_TNEQ: {
                /* Structure equal/not-equal, class-0/TEQU.md/TNEQ.md:
                 * same XPT-pair shape as TASN. Real hardware delegates
                 * to a runtime routine (#QCSTRUC) that loops over every
                 * terminal; this compares every field either side's
                 * shadow-slot table knows about (union of both), via the
                 * same exact-value comparison as SEQU/MEQU -- a field
                 * neither side has touched contributes a vacuous zero-
                 * equals-zero match, consistent with TASN's own
                 * approximation above. */
                if (ins->operand_count != 2) { fail(state, "TEQU/TNEQ: expected 2 operands"); break; }
                if (ins->operands[0].qual != QUAL_XPT || ins->operands[1].qual != QUAL_XPT) {
                    fail(state, "TEQU/TNEQ: both operands must be XPT");
                    break;
                }
                if (ins->operands[0].data >= HALMAT_VAC_MAX || ins->operands[1].data >= HALMAT_VAC_MAX) {
                    fail(state, "TEQU/TNEQ: XPT stream position out of range");
                    break;
                }
                const halmat_vac_slot_t *lhs_ref = &state->vac[ins->operands[0].data];
                const halmat_vac_slot_t *rhs_ref = &state->vac[ins->operands[1].data];
                if (!lhs_ref->is_struct_ref || !rhs_ref->is_struct_ref) {
                    fail(state, "TEQU/TNEQ: XPT operand does not reference an EXTN result");
                    break;
                }
                uint16_t lhs_base = lhs_ref->struct_base_syt, rhs_base = rhs_ref->struct_base_syt;
                int32_t ambient_idx = current_copy_index(state);
                int32_t lhs_copy_idx = lhs_ref->struct_copy_index >= 0 ? lhs_ref->struct_copy_index : ambient_idx;
                int32_t rhs_copy_idx = rhs_ref->struct_copy_index >= 0 ? rhs_ref->struct_copy_index : ambient_idx;
                bool all_equal = true;
                size_t count = state->struct_field_count;
                for (size_t i = 0; i < count && all_equal; i++) {
                    uint16_t base = state->struct_fields[i].base_syt;
                    int32_t want_idx = (base == lhs_base) ? lhs_copy_idx : rhs_copy_idx;
                    if (state->struct_fields[i].copy_index != want_idx) continue;
                    if (base != lhs_base && base != rhs_base) continue;
                    uint16_t field = state->struct_fields[i].field_syt;
                    halmat_syt_entry_t *lhs_field = find_or_create_struct_field(state, lhs_base, field, lhs_copy_idx);
                    halmat_syt_entry_t *rhs_field = find_or_create_struct_field(state, rhs_base, field, rhs_copy_idx);
                    resolved_value_t lv, rv;
                    read_syt_entry(lhs_field, &lv);
                    read_syt_entry(rhs_field, &rv);
                    if (lv.kind == RV_STRING || rv.kind == RV_STRING) {
                        if (lv.kind != rv.kind || strcmp(lv.string, rv.string) != 0) all_equal = false;
                    } else {
                        halmat_scalar_t diff = halmat_scalar_sub(rv_to_scalar(&lv), rv_to_scalar(&rv));
                        if (!(diff.msw == 0 && diff.lsw == 0)) all_equal = false;
                    }
                }
                bool result = (ins->opcode == OP_TEQU) ? all_equal : !all_equal;
                if (ins->index >= HALMAT_VAC_MAX) { fail(state, "VAC index out of range"); break; }
                state->vac[ins->index].is_ref = false;
                state->vac[ins->index].integer = result ? 1 : 0;
                break;
            }

            case OP_NASN:
                /* NAME (pointer) assign, class-0/NASN.md: both operands
                 * are ordinary SYT references to data items, not to the
                 * NAME variable's own stored value -- pointer semantics
                 * are implicit in NASN's identity, not the operand
                 * qualifiers. Bypasses resolve_operand/write_destination
                 * entirely (those resolve a *value*; NASN needs the raw
                 * target SYT index instead). NULL is QUAL=IMD (any
                 * value), per NINT.md's confirmed NULL encoding. */
                if (ins->operand_count != 2) { fail(state, "NASN: expected 2 operands"); break; }
                if (ins->operands[1].qual != QUAL_SYT) { fail(state, "NASN: receiver must be SYT"); break; }
                {
                    uint16_t target = (ins->operands[0].qual == QUAL_SYT) ? ins->operands[0].data : HALMAT_NAME_NULL;
                    uint16_t dest_syt = ins->operands[1].data;
                    if (dest_syt >= HALMAT_SYT_MAX) { fail(state, "NASN: SYT index out of range"); break; }
                    state->syt[dest_syt].type = SYT_TYPE_NAME;
                    state->syt[dest_syt].name_target = target;
                }
                break;

            case OP_NEQU:
            case OP_NNEQ:
                /* NAME (pointer) equal/not-equal, class-0/NEQU.md/
                 * NNEQ.md: TRUE if both sides' stored pointer target
                 * matches (pointer identity, not target-value equality).
                 * A NAME variable never assigned via NASN/NINT defaults
                 * to SYT_TYPE_UNKNOWN with name_target=0 (zero-
                 * initialized), which is a valid-looking SYT index, not
                 * NULL -- comparisons against an unset NAME are
                 * therefore not reliably NULL-equivalent; no fixture
                 * exercises that case. */
                if (ins->operand_count != 2) { fail(state, "NEQU/NNEQ: expected 2 operands"); break; }
                if (ins->operands[0].qual != QUAL_SYT || ins->operands[1].qual != QUAL_SYT) {
                    fail(state, "NEQU/NNEQ: both operands must be SYT");
                    break;
                }
                if (ins->index >= HALMAT_VAC_MAX) { fail(state, "VAC index out of range"); break; }
                {
                    uint16_t sym_a = ins->operands[0].data, sym_b = ins->operands[1].data;
                    if (sym_a >= HALMAT_SYT_MAX || sym_b >= HALMAT_SYT_MAX) { fail(state, "NEQU/NNEQ: SYT index out of range"); break; }
                    bool equal = (state->syt[sym_a].name_target == state->syt[sym_b].name_target);
                    bool result = (ins->opcode == OP_NEQU) ? equal : !equal;
                    state->vac[ins->index].is_ref = false;
                    state->vac[ins->index].integer = result ? 1 : 0;
                }
                break;

            case OP_DFOR: {
                if (ins->operand_count == 2) {
                    break; /* list-form: no-op, AFOR does the real work */
                }
                if (ins->operand_count < 4) { fail(state, "DFOR: expected 2 (list) or 4-5 (range) operands"); break; }
                if (!resolve_operand(state, &ins->operands[2], &a)) break; /* initial value */
                if (ins->operands[1].qual != QUAL_SYT) { fail(state, "DFOR: control variable must be SYT"); break; }
                state->syt[ins->operands[1].data].type = SYT_TYPE_INTEGER;
                int32_t initial = rv_to_integer(&a);
                state->syt[ins->operands[1].data].value = initial;
                /* Range form's initial in-range check (user-reported,
                 * 113-EXAMPLE_7.hal's `DO FOR J = I+1 TO 4;`, silently
                 * running one bogus body pass with J=5 when I=4, since
                 * 5>4 should mean zero iterations -- corrupted an
                 * unrelated array element via a wrapped out-of-bounds
                 * DSUB offset). class-0/DFOR.md's own prior "always runs
                 * its first in-range cycle without a pre-test" reading
                 * was wrong: a real compiled trace (`HALSFC
                 * --parms=LSTALL`) shows DFOR's initial branch lands
                 * squarely on EFOR's own STH+CHI+BC sequence (`L#5` in
                 * the trace), *after* the AH increment step but *before*
                 * anything else -- i.e. only the increment is skipped on
                 * the first pass, not the bounds check, exactly
                 * mirroring what EFOR itself already does on every
                 * subsequent cycle (case OP_EFOR below) -- this is that
                 * exact same check, just without the increment, applied
                 * once up front. Confirmed independently against a real
                 * AP-101S run (`compileLinkRun`, user-verified) giving
                 * the correct (zero-iteration) result. */
                resolved_value_t final_val, incr_val;
                if (!resolve_operand(state, &ins->operands[3], &final_val)) break;
                if (ins->operand_count == 5) {
                    if (!resolve_operand(state, &ins->operands[4], &incr_val)) break;
                } else {
                    incr_val.kind = RV_INTEGER;
                    incr_val.integer = 1; /* implicit default increment (class-0/DFOR.md) */
                }
                int32_t incr = rv_to_integer(&incr_val);
                int32_t final = rv_to_integer(&final_val);
                bool in_range = (incr >= 0) ? (initial <= final) : (initial >= final);
                if (!in_range) {
                    size_t efor_pos = state->dfor_efor_pos[state->pc];
                    if (efor_pos == NO_TARGET) { fail(state, "DFOR has no matching EFOR"); break; }
                    state->pc = efor_pos + 1;
                    branched = true;
                }
                /* else: fall through into CFOR (if any)/the body, unchanged. */
                break;
            }

            case OP_BRA:
            case OP_FBRA: {
                if (ins->opcode == OP_FBRA) {
                    if (ins->operand_count != 2) { fail(state, "FBRA: expected 2 operands"); break; }
                    if (!resolve_operand(state, &ins->operands[1], &a)) break;
                    if (rv_to_integer(&a) != 0) break; /* condition true: fall through, no branch */
                } else if (ins->operand_count != 1) {
                    fail(state, "BRA: expected 1 operand");
                    break;
                }
                uint16_t label = ins->operands[0].data;
                /* Two independent target namespaces share this one branch
                 * opcode (state.h's label_pos_syt comment, precompute_
                 * labels() above): QUAL_INL for the ordinary IF/ELSE-join/
                 * EXIT-of-loop bookkeeping-label case, QUAL_SYT for a real
                 * `GO TO <label>;` targeting a user-declared STATEMENT
                 * LABEL -- dispatched here on the operand's own qualifier
                 * rather than assuming one shared table, which is what let
                 * the two numbering spaces silently collide before this
                 * fix (user-reported regression, test_eron_goto.hal, found
                 * fixing 119-EXAMPLE_9.hal's EXIT-to-labeled-DFOR bug). */
                size_t target;
                if (ins->operands[0].qual == QUAL_SYT) {
                    target = (label < HALMAT_SYT_MAX) ? state->label_pos_syt[label] : NO_TARGET;
                } else if (ins->operands[0].qual == QUAL_INL) {
                    target = (label < HALMAT_LABEL_MAX) ? state->label_pos[label] : NO_TARGET;
                } else {
                    fail(state, "%s: unsupported target operand qualifier %s",
                         ins->opcode == OP_FBRA ? "FBRA" : "BRA", halmat_qual_name(ins->operands[0].qual));
                    break;
                }
                if (target == NO_TARGET) {
                    fail(state, "branch to undefined label %u", label);
                    break;
                }
                state->pc = target;
                branched = true;
                break;
            }

            case OP_CNEQ:
            case OP_CEQU:
            case OP_CNGT:
            case OP_CGT:
            case OP_CNLT:
            case OP_CLT: {
                /* Plain strcmp: padding rule for unequal-length operands
                 * is unconfirmed (class-7/CEQU.md) -- no fixture found a
                 * counterexample to the natural "compare as-is" reading,
                 * so that's what's implemented; revisit if a fixed-length
                 * CHARACTER comparison ever needs blank-padding instead. */
                if (ins->operand_count != 2) { fail(state, "character comparison: expected 2 operands"); break; }
                if (!resolve_operand(state, &ins->operands[0], &a)) break;
                if (!resolve_operand(state, &ins->operands[1], &b)) break;
                if (a.kind != RV_STRING || b.kind != RV_STRING) { fail(state, "character comparison: both operands must be CHARACTER"); break; }
                int cmp = strcmp(a.string, b.string);
                bool result;
                switch (ins->opcode) {
                    case OP_CNEQ: result = cmp != 0; break;
                    case OP_CEQU: result = cmp == 0; break;
                    case OP_CNGT: result = cmp <= 0; break;
                    case OP_CGT: result = cmp > 0; break;
                    case OP_CNLT: result = cmp >= 0; break;
                    case OP_CLT: default: result = cmp < 0; break;
                }
                if (ins->index >= HALMAT_VAC_MAX) { fail(state, "VAC index out of range"); break; }
                state->vac[ins->index].is_ref = false;
                state->vac[ins->index].integer = result ? 1 : 0;
                break;
            }

            case OP_SNEQ:
            case OP_SEQU:
            case OP_SNGT:
            case OP_SGT:
            case OP_SNLT:
            case OP_SLT: {
                /* Exact hex-float comparison via subtraction, sign/true-
                 * zero test (SEQU.md's "exact vs. tolerance" question is
                 * unresolved in the primary sources -- exact bit
                 * comparison is the natural hardware-faithful reading,
                 * consistent with this interpreter's genuine-hex-float
                 * (not native-double) arithmetic elsewhere). True zero is
                 * always sign=0 (halmat_scalar_add's convention). */
                if (ins->operand_count != 2) { fail(state, "scalar comparison: expected 2 operands"); break; }
                if (!resolve_operand(state, &ins->operands[0], &a)) break;
                if (!resolve_operand(state, &ins->operands[1], &b)) break;
                halmat_scalar_t diff = halmat_scalar_sub(rv_to_scalar(&a), rv_to_scalar(&b));
                bool is_zero = (diff.msw == 0 && diff.lsw == 0);
                bool is_negative = ((diff.msw >> 31) & 1) != 0;
                bool result;
                switch (ins->opcode) {
                    case OP_SNEQ: result = !is_zero; break;
                    case OP_SEQU: result = is_zero; break;
                    case OP_SNGT: result = is_zero || is_negative; break;
                    case OP_SGT: result = !is_zero && !is_negative; break;
                    case OP_SNLT: result = is_zero || !is_negative; break;
                    case OP_SLT: default: result = !is_zero && is_negative; break;
                }
                if (ins->index >= HALMAT_VAC_MAX) { fail(state, "VAC index out of range"); break; }
                state->vac[ins->index].is_ref = false;
                state->vac[ins->index].integer = result ? 1 : 0;
                break;
            }

            case OP_CAND:
            case OP_COR: {
                if (ins->operand_count != 2) { fail(state, "logical AND/OR: expected 2 operands"); break; }
                if (!resolve_operand(state, &ins->operands[0], &a)) break;
                if (!resolve_operand(state, &ins->operands[1], &b)) break;
                bool ab = (rv_to_integer(&a) != 0), bb = (rv_to_integer(&b) != 0);
                if (ins->index >= HALMAT_VAC_MAX) { fail(state, "VAC index out of range"); break; }
                state->vac[ins->index].is_ref = false;
                state->vac[ins->index].integer = ((ins->opcode == OP_CAND) ? (ab && bb) : (ab || bb)) ? 1 : 0;
                break;
            }

            case OP_CNOT:
                if (ins->operand_count != 1) { fail(state, "logical NOT: expected 1 operand"); break; }
                if (!resolve_operand(state, &ins->operands[0], &a)) break;
                if (ins->index >= HALMAT_VAC_MAX) { fail(state, "VAC index out of range"); break; }
                state->vac[ins->index].is_ref = false;
                state->vac[ins->index].integer = (rv_to_integer(&a) == 0) ? 1 : 0;
                break;

            case OP_INEQ:
            case OP_IEQU:
            case OP_INGT:
            case OP_IGT:
            case OP_INLT:
            case OP_ILT: {
                if (ins->operand_count != 2) { fail(state, "integer comparison: expected 2 operands"); break; }
                if (!resolve_operand(state, &ins->operands[0], &a)) break;
                if (!resolve_operand(state, &ins->operands[1], &b)) break;
                int32_t ai = rv_to_integer(&a), bi = rv_to_integer(&b);
                bool result;
                switch (ins->opcode) {
                    case OP_INEQ: result = ai != bi; break;
                    case OP_IEQU: result = ai == bi; break;
                    case OP_INGT: result = ai <= bi; break;
                    case OP_IGT: result = ai > bi; break;
                    case OP_INLT: result = ai >= bi; break;
                    case OP_ILT: default: result = ai < bi; break;
                }
                if (ins->index >= HALMAT_VAC_MAX) { fail(state, "VAC index out of range"); break; }
                state->vac[ins->index].is_ref = false;
                state->vac[ins->index].integer = result ? 1 : 0;
                break;
            }

            case OP_CTST: {
                if (ins->operand_count != 1) { fail(state, "CTST: expected 1 operand"); break; }
                if (!resolve_operand(state, &ins->operands[0], &a)) break;
                bool cond_true = (rv_to_integer(&a) != 0);
                /* tag 0 = WHILE (exit when condition false), tag 1 = UNTIL
                 * (exit when condition true) -- confirmed against a real
                 * compiled test_while.hal trace (see precompute_loop_targets). */
                bool exit_loop = ins->tag ? cond_true : !cond_true;
                if (exit_loop) {
                    size_t target = state->ctst_exit_target[state->pc];
                    if (target == NO_TARGET) { fail(state, "CTST has no matching ETST"); break; }
                    state->pc = target;
                    branched = true;
                }
                break;
            }

            case OP_CFOR: {
                /* Range-form DO FOR's supplementary WHILE/UNTIL clause,
                 * class-0/CFOR.md -- same tag=WHILE(0)/UNTIL(1)
                 * convention as CTST, but exits to one past the
                 * enclosing EFOR (precompute_for_loops' cfor_exit_
                 * target) rather than a DTST/ETST pair's own target. */
                if (ins->operand_count != 1) { fail(state, "CFOR: expected 1 operand"); break; }
                if (!resolve_operand(state, &ins->operands[0], &a)) break;
                bool cond_true = (rv_to_integer(&a) != 0);
                bool exit_loop = ins->tag ? cond_true : !cond_true;
                if (exit_loop) {
                    size_t target = state->cfor_exit_target[state->pc];
                    if (target == NO_TARGET) { fail(state, "CFOR has no matching (range-form) EFOR"); break; }
                    state->pc = target;
                    branched = true;
                }
                break;
            }

            case OP_ETST: {
                size_t target = state->etst_back_target[state->pc];
                if (target == NO_TARGET) { fail(state, "ETST has no matching DTST"); break; }
                state->pc = target;
                branched = true;
                break;
            }

            case OP_AFOR: {
                if (ins->operand_count != 1) { fail(state, "AFOR: expected 1 operand"); break; }
                if (!resolve_operand(state, &ins->operands[0], &a)) break;
                if (state->afor_body_target[state->pc] == NO_TARGET) {
                    fail(state, "AFOR outside of a recognized list-form DO FOR");
                    break;
                }
                state->syt[state->afor_control_var[state->pc]].type = SYT_TYPE_INTEGER;
                state->syt[state->afor_control_var[state->pc]].value = rv_to_integer(&a);
                if (state->for_return_sp >= 64) { fail(state, "DO FOR nesting too deep"); break; }
                state->for_return_stack[state->for_return_sp++] = state->afor_return_target[state->pc];
                state->pc = state->afor_body_target[state->pc];
                branched = true;
                break;
            }

            case OP_EFOR: {
                if (state->efor_is_list_form[state->pc]) {
                    if (state->for_return_sp <= 0) { fail(state, "EFOR with no matching AFOR dispatch"); break; }
                    state->pc = state->for_return_stack[--state->for_return_sp];
                    branched = true;
                    break;
                }
                size_t dfor_pos = state->efor_dfor_pos[state->pc];
                if (dfor_pos == NO_TARGET) { fail(state, "EFOR has no matching DFOR"); break; }
                const halmat_instr_t *dfor = &state->prog->instrs[dfor_pos];
                resolved_value_t final_val, incr_val;
                if (!resolve_operand(state, &dfor->operands[3], &final_val)) break;
                if (dfor->operand_count == 5) {
                    if (!resolve_operand(state, &dfor->operands[4], &incr_val)) break;
                } else {
                    incr_val.kind = RV_INTEGER;
                    incr_val.integer = 1; /* implicit default increment (class-0/DFOR.md) */
                }
                int32_t incr = rv_to_integer(&incr_val);
                int32_t final = rv_to_integer(&final_val);
                uint16_t control_var = dfor->operands[1].data;
                int32_t new_value = state->syt[control_var].value + incr;
                state->syt[control_var].value = new_value;
                bool in_range = (incr >= 0) ? (new_value <= final) : (new_value >= final);
                if (in_range) {
                    state->pc = dfor_pos + 1;
                    branched = true;
                }
                /* else: fall through, loop exit */
                break;
            }

            case OP_DCAS: {
                /* [USA003087] §10.3 rule 3: "a run time error results if
                 * k < 0 or k is greater than the number of statements in
                 * the group" -- "unless an ELSE clause... is executed if
                 * the value of the case variable is outside the legal
                 * range." Confirmed directly against real compiled HALMAT
                 * (080-EXAMPLE_4A.hal, user-reported): an `ELSE` clause's
                 * body compiles to plain in-line code placed immediately
                 * after DCAS itself, *before* the first ordinary case's
                 * CLBL -- not as an extra CLBL appended at the end the
                 * way an initial reading of DCAS.md/CLBL.md's own
                 * Unresolved Questions had suggested. DCAS's own computed
                 * jump only ever targets an in-range ordinary case's
                 * CLBL; for an out-of-range selector it simply doesn't
                 * jump at all, so ordinary sequential fall-through
                 * (interp_step's `if (!branched) state->pc++`) does the
                 * rest on its own: falls into the ELSE body when one
                 * exists, or straight into case 1's own CLBL when it
                 * doesn't -- which, reached by fall-through rather than a
                 * DCAS landing, immediately acts as this construct's
                 * implicit branch to ECAS (see this file's own
                 * precompute_case_dispatch()/CLBL comment), i.e. a silent
                 * no-op with no case body executed. That no-ELSE
                 * no-op reading was cross-checked directly against the
                 * real AP-101S emulator (`compileLinkRun`): the real
                 * runtime actually hangs in an infinite loop for that
                 * exact input, rather than either aborting per rule 3's
                 * prose or falling through cleanly -- an apparent bug in
                 * the real runtime library that this project has no
                 * interest in replicating; falling through to ECAS is
                 * the safe, well-defined behavior instead. */
                if (ins->operand_count != 2) { fail(state, "DCAS: expected 2 operands"); break; }
                if (!resolve_operand(state, &ins->operands[1], &a)) break;
                int32_t sel = rv_to_integer(&a);
                size_t count = state->dcas_case_count[state->pc];
                if (sel < 1 || (size_t)sel > count) {
                    /* Out of range: no jump: fall straight through to
                     * whatever instruction follows DCAS (the ELSE body,
                     * or case 1's own CLBL if there's no ELSE). */
                    break;
                }
                state->pc = state->dcas_case_target[state->pc * HALMAT_MAX_CASES + (sel - 1)];
                branched = true;
                break;
            }

            case OP_CLBL: {
                /* Reached here only by falling through from the
                 * preceding case's body (DCAS always jumps past its
                 * target CLBL) -- this is the implicit "branch to ECAS"
                 * every case body ends with (class-0/ECAS.md). */
                size_t target = state->clbl_ecas_target[state->pc];
                if (target == NO_TARGET) { fail(state, "CLBL has no matching ECAS"); break; }
                state->pc = target;
                branched = true;
                break;
            }

            case OP_ECAS:
                break; /* join point; no-op */

            case OP_DSUB: {
                /* Only the single-index "index" subscript kind, the
                 * asterisk ("*") partition kind, and the component
                 * at-partition kind are implemented (see class-0/DSUB.md's
                 * confirmed table). To-partition (CHARACTER substring,
                 * `C1(a TO b)`) and ASZ forms still aren't handled. Two-
                 * index (MATRIX) flattening uses the real declared
                 * row-major shape when the symbol table confirms it
                 * (ensure_container/symtab.h); otherwise (no symtab, or
                 * more than 2 indices) falls back to a placeholder stride
                 * -- unobserved by any fixture that doesn't also have its
                 * COMMON*.out available.
                 *
                 * CSZ (`#`-relative CHARACTER subscript, 160-REFORMAT.hal's
                 * `RETURN RJUST(S||C(1 TO #-DECIMALS)||'.'||
                 * C(#-DECIMALS-1 TO #), WIDTH);`) is now implemented --
                 * see resolve_to_partition_bound()'s own comment and the
                 * CHARACTER to-partition branch below. Resolving this took
                 * three real traces to pin down: DSUB.md's own controlled
                 * compile (`C1(2 TO # - 2)`, a synthetic test, not a real
                 * program) cleanly confirms `DATA`=2 means "# − subsidiary"
                 * in isolation. 160-REFORMAT.hal's own real compiled trace
                 * showed the *second* substring's subsidiary is a
                 * *computed* VAC result, `IADD(DECIMALS, 1)` (the literal
                 * confirmed as exactly 1 via a standalone litfile.bin
                 * probe) -- reconciling algebraically with the corpus
                 * file's own `#-DECIMALS-1` formula. That formula was
                 * independently re-verified letter-for-letter against
                 * *both* the 1st (NASA-CR-151872, Sept. 1978,
                 * `~/Downloads/Programming in HAL_S Sept 1978.pdf`, p.160)
                 * and 2nd (source-documentation/ProgrammingInHALS.txt, Ch.
                 * 8) editions of "Programming in HAL/S" -- present in both,
                 * ruling out an OCR artifact in either scan. What looked
                 * like a contradiction in an earlier pass (hand-deriving
                 * REFORMAT's own worked textbook example, `REFORMAT(SQRT(2)
                 * ,3,5)` -> `'1.414'`, seemed to need the *opposite* sign)
                 * turned out to rest on a wrong assumption about how the
                 * pieces recombine -- the corpus .hal file itself doesn't
                 * even call REFORMAT with those textbook values (it uses
                 * `REFORMAT(3.14159,2,10)` and two others instead), so the
                 * textbook's own prose claim was never actually
                 * verifiable against this file's own compiled behavior in
                 * the first place. This interpreter implements the
                 * formula exactly as compiled, whatever behavior that
                 * produces -- matching this project's own standing
                 * principle of faithfully executing the real HALMAT
                 * rather than second-guessing the source against a
                 * secondary prose description. */
                if (ins->operand_count < 2) { fail(state, "DSUB: expected at least 2 operands"); break; }
                if (ins->operands[0].qual == QUAL_LIT) {
                    /* CHARACTER to-partition subscript on a compile-time
                     * CONSTANT base (`ZEROS(1 TO DECIMALS-LENGTH(C))`,
                     * `ZEROS` a `CHARACTER(20) CONSTANT(CHAR(20)'0')` --
                     * 160-REFORMAT.hal): the base itself is QUAL_LIT (a
                     * literal-table string reference), not QUAL_SYT, since
                     * a compile-time CONSTANT never gets its own SYT
                     * storage the way an ordinary variable does. Handled
                     * as its own narrow case rather than folding into the
                     * generic base_syt/ensure_container machinery every
                     * other DSUB kind below shares (a literal has no SYT
                     * entry to look up at all). Scoped to exactly the
                     * shape this corpus file needs (to-partition, CSZ or
                     * plain) -- any other subscript kind on a literal base
                     * fails loudly rather than guessing. */
                    if (ins->tag != 2 || ins->operand_count < 3 || ins->operands[1].tag1 != 2) {
                        fail(state, "DSUB: unsupported subscript shape on a literal/CONSTANT base");
                        break;
                    }
                    resolved_value_t basev;
                    if (!resolve_operand(state, &ins->operands[0], &basev)) break;
                    if (basev.kind != RV_STRING) { fail(state, "DSUB: literal base is not a CHARACTER constant"); break; }
                    const char *src = basev.string ? basev.string : "";
                    int32_t srclen = (int32_t)strlen(src);
                    uint8_t oi = 1;
                    int32_t start, end;
                    if (!resolve_to_partition_bound(state, ins, &oi, srclen, &start)) break;
                    if (!resolve_to_partition_bound(state, ins, &oi, srclen, &end)) break;
                    if (start < 1) start = 1;
                    if (end > srclen) end = srclen;
                    int32_t width = end - start + 1;
                    if (width < 0) width = 0;
                    char *sub = malloc((size_t)width + 1);
                    if (!sub) { fail(state, "out of memory"); break; }
                    if (width > 0) memcpy(sub, src + (start - 1), (size_t)width);
                    sub[width] = '\0';
                    if (ins->index >= HALMAT_VAC_MAX) { fail(state, "VAC index out of range"); free(sub); break; }
                    state->vac[ins->index].is_ref = false;
                    state->vac[ins->index].is_string = true;
                    state->vac[ins->index].string = sub;
                    break;
                }
                if (ins->operands[0].qual != QUAL_SYT) { fail(state, "DSUB: reference must be SYT"); break; }
                uint16_t base_syt = ins->operands[0].data;
                if (base_syt >= HALMAT_SYT_MAX) { fail(state, "DSUB: SYT index out of range"); break; }
                ensure_container(state, base_syt);
                halmat_syt_entry_t *base = &state->syt[base_syt];

                uint8_t num_indices = ins->operand_count - 1;

                /* Asterisk ("$(...,*)") partition subscript: selects a
                 * whole VECTOR (V$(*)), or a whole MATRIX row/column
                 * (M$(i,*)/M$(*,j)) -- confirmed this session against
                 * real compiled HALMAT (`WRITE(6) N$(1,*);` on a
                 * MATRIX(2,2)): produces a VECTOR-shaped VAC container
                 * result (this DSUB instruction's own operator-word TAG
                 * is confirmed to be the HALMAT class of the *result*,
                 * 4=VECTOR here), consumed the same way as any other
                 * MATRIX/VECTOR-arithmetic VAC result (e.g. by a
                 * following WRITE argument -- OP_XXAR's whole-container
                 * handling below -- or MASN/VASN). Only "select one axis
                 * entirely, index the other" is implemented; to-
                 * partition/at-partition subscripts (2 operand words per
                 * axis) still aren't. */
                int ast_axis = -1;
                for (uint8_t i = 0; i < num_indices; i++) {
                    if (ins->operands[1 + i].qual == QUAL_AST) { ast_axis = (int)i; break; }
                }
                if (ast_axis >= 0) {
                    halmat_scalar_t buf[HALMAT_CONTAINER_CAPACITY];
                    size_t count;
                    /* Set for every case below, since all of them select a
                     * regularly-strided run of `base`'s own row-major
                     * storage (offset, offset+stride, offset+2*stride, ...)
                     * -- lets this VAC slot also be used as an assignment
                     * *receiver* later (`M$(I,*) = ...;`, user-reported,
                     * 047-ROWS.hal; `M$(*,j) = ...;` generalized in the
                     * same follow-up), writing straight back into `base`
                     * instead of only ever being readable. stride=1 for
                     * the row-select/whole-vector cases (genuinely
                     * contiguous); a column select has stride=cols
                     * instead, since row-major storage places successive
                     * column entries `cols` elements apart. */
                    bool writable_ref = false;
                    size_t ref_offset = 0;
                    size_t ref_stride = 1;
                    if (num_indices == 1) {
                        /* V$(*): the whole vector, unchanged. */
                        count = base->element_count;
                        if (count > HALMAT_CONTAINER_CAPACITY) { fail(state, "DSUB: container too large"); break; }
                        memcpy(buf, base->elements, count * sizeof(halmat_scalar_t));
                        writable_ref = true;
                        ref_offset = 0;
                    } else if (num_indices == 2 && base->rows > 0) {
                        resolved_value_t idx;
                        uint8_t other = 1 - (uint8_t)ast_axis;
                        if (!resolve_operand(state, &ins->operands[1 + other], &idx)) break;
                        int32_t n = rv_to_integer(&idx) - 1;
                        if (n < 0) n = 0;
                        if (ast_axis == 1) {
                            /* M$(i,*): row i, every column. */
                            int r = n % base->rows;
                            count = (size_t)base->cols;
                            for (int c = 0; c < base->cols; c++) buf[c] = base->elements[(size_t)r * base->cols + c];
                            writable_ref = true;
                            ref_offset = (size_t)r * (size_t)base->cols;
                        } else {
                            /* M$(*,j): every row, column j. */
                            int c = n % base->cols;
                            count = (size_t)base->rows;
                            for (int r = 0; r < base->rows; r++) buf[r] = base->elements[(size_t)r * base->cols + c];
                            writable_ref = true;
                            ref_offset = (size_t)c;
                            ref_stride = (size_t)base->cols;
                        }
                    } else if (base->bit_elements || base->char_elements) {
                        /* A BIT/BOOLEAN or CHARACTER ARRAY subscript
                         * compiles through this same "index + trailing
                         * asterisk" DSUB shape as M$(i,*) -- confirmed
                         * user-reported (120-EXAMPLE_A.hal's
                         * `DATA_VALID$(J:) = FALSE;`, DATA_VALID an
                         * `ARRAY(4) BOOLEAN`, DSUB's own tag=1=BIT
                         * confirming the element type). Unlike VECTOR/
                         * MATRIX, where the asterisk selects a genuine
                         * sub-range of several elements, a BIT/CHARACTER
                         * element has no further internal structure to
                         * select "all of" -- there is no plain-index-only
                         * DSUB shape for these types, so the trailing
                         * asterisk here is just how the compiler always
                         * spells a BIT/CHARACTER array subscript, making
                         * this exactly equivalent to an ordinary
                         * single-index subscript (the generic per-
                         * dimension `is_ref` path much further down in
                         * this same case, reached for the num_indices==1
                         * shape another ARRAY element type would use
                         * instead) rather than a container-producing
                         * partition select -- so this produces a plain
                         * writable element reference, not a VAC container,
                         * and returns immediately rather than falling
                         * through to this block's shared store_container_
                         * result() tail below (which assumes a numeric
                         * `buf`/`count` this path never builds). */
                        uint8_t other = 1 - (uint8_t)ast_axis;
                        resolved_value_t idx;
                        if (!resolve_operand(state, &ins->operands[1 + other], &idx)) break;
                        int32_t n = rv_to_integer(&idx) - 1;
                        if (n < 0) n = 0;
                        if (ins->index >= HALMAT_VAC_MAX) { fail(state, "VAC index out of range"); break; }
                        state->vac[ins->index].is_ref = true;
                        state->vac[ins->index].ref_syt = base_syt;
                        state->vac[ins->index].ref_offset = (size_t)n % base->element_count;
                        break;
                    } else {
                        /* Also reached (num_indices==2, base->rows==0) for
                         * `V(N)` where V is declared ARRAY(n) VECTOR(m) --
                         * an ARRAY-of-VECTOR, not a true MATRIX -- compiling
                         * to the same "one plain index + one asterisk"
                         * DSUB shape as M$(i,*). A *concrete*-size ARRAY(n)
                         * VECTOR(m) (n a literal, known at DECLARE time) is
                         * now handled: ensure_container() gives it real
                         * rows/cols (n, m) plus the array_of_vector flag
                         * (state.h), same as the 2D-ARRAY-of-SCALAR fix
                         * above, so it lands in the `base->rows > 0` branch
                         * just above instead of down here -- confirmed
                         * user-reported, 117-EXAMPLE_8.hal's `POSITIONS
                         * ARRAY(5) VECTOR`, indexed `POSITIONS$(I:*)`.
                         * Still reached for an *assumed-size* `ARRAY(*)
                         * VECTOR` formal parameter (its real length only
                         * known at the call site, not DECLARE time) --
                         * confirmed as the actual real-corpus blocker for
                         * that case this session (141-VSUM.hal's `TOTAL =
                         * TOTAL + V(N);` inside `VSUM: FUNCTION(V) VECTOR;
                         * DECLARE V ARRAY(*) VECTOR;`) -- tracked
                         * separately (task #29) since it needs the
                         * parameter's real bound threaded in from the call
                         * site, not just a symtab decode. That same file
                         * also still needs a whole-VECTOR FUNCTION RETURN
                         * (a separate, deeper OP_RTRN gap -- see that
                         * opcode's own comment, added investigating
                         * external function return values) even once
                         * ARRAY(*) binding is fixed. */
                        fail(state, "DSUB: asterisk subscript with %u indices not yet implemented", num_indices);
                        break;
                    }
                    if (!store_container_result(state, ins->index, buf, count, 0, (int)count)) break;
                    /* User-reported (113-EXAMPLE_7.hal's `MISMATCH$(J,*)`,
                     * MISMATCH a confirmed-2D `ARRAY(4,4) INTEGER`):
                     * DSUB's own operator-word TAG is the subscripted
                     * result's real HALMAT class (class-0/DSUB.md,
                     * confirmed empirically -- 6=INTEGER); propagate it
                     * onto this VAC slot so a later per-element read
                     * (resolve_operand's own is_container branch, reached
                     * via the ADLP/DLPE replay this WRITE argument gets
                     * expanded into) knows to format as INTEGER rather
                     * than defaulting to SCALAR. A genuine MATRIX/VECTOR
                     * result always has TAG=5/4 here, never 6 -- HAL/S has
                     * no INTEGER MATRIX/VECTOR -- so this is safe to set
                     * unconditionally for every asterisk-select shape. */
                    state->vac[ins->index].container_is_integer = (ins->tag == 6);
                    if (writable_ref) {
                        state->vac[ins->index].is_container_ref = true;
                        state->vac[ins->index].container_ref_syt = base_syt;
                        state->vac[ins->index].container_ref_offset = ref_offset;
                        state->vac[ins->index].container_ref_stride = ref_stride;
                    }
                    break;
                }

                /* Component to-partition ("start TO end") subscript on a
                 * whole VECTOR (`V(4 TO 7)`, V a VECTOR(10)) -- DSUB.md's
                 * confirmed table: TAG1=2 on both subscript operand words
                 * (the "component" column's to-partition row, the same
                 * marker CHARACTER to-partition uses -- distinguished by
                 * this instruction's own operator-word TAG, 4=VECTOR here
                 * vs. 2=CHARACTER). Produces a VECTOR-shaped VAC container
                 * result, writable the same way the asterisk-partition
                 * case above is (`V(4 TO 7) = SUBV;`, SUBV itself a
                 * VECTOR(4)) -- confirmed via a direct HALSFC compile that
                 * a plain SCALAR RHS is rejected outright at compile time
                 * ("AV1: TYPE OF V IS ILLEGAL FOR ASSIGNMENT FROM GIVEN
                 * RIGHT-HAND SIDE"), so this is only ever reached with a
                 * genuine VECTOR-shaped source -- user-reported. Only the
                 * single-dimension VECTOR/ARRAY case (`base->rows == 0`)
                 * is implemented, mirroring the at-partition case just
                 * below -- a MATRIX to-partition isn't handled. */
                if (num_indices == 2 && base->rows == 0 && ins->tag == 4 &&
                    ins->operands[1].tag1 == 2 && ins->operands[2].tag1 == 2) {
                    resolved_value_t startv, endv;
                    if (!resolve_operand(state, &ins->operands[1], &startv)) break;
                    if (!resolve_operand(state, &ins->operands[2], &endv)) break;
                    int32_t start = rv_to_integer(&startv);
                    int32_t end = rv_to_integer(&endv);
                    if (start < 1) start = 1;
                    if (end > (int32_t)base->element_count) end = (int32_t)base->element_count;
                    int32_t count32 = end - start + 1;
                    if (count32 < 0) count32 = 0;
                    size_t count = (size_t)count32;
                    if (count > HALMAT_CONTAINER_CAPACITY) { fail(state, "DSUB: container too large"); break; }
                    halmat_scalar_t buf[HALMAT_CONTAINER_CAPACITY];
                    for (size_t k = 0; k < count; k++) buf[k] = base->elements[(size_t)(start - 1) + k];
                    if (!store_container_result(state, ins->index, buf, count, 0, (int)count)) break;
                    state->vac[ins->index].is_container_ref = true;
                    state->vac[ins->index].container_ref_syt = base_syt;
                    state->vac[ins->index].container_ref_offset = (size_t)(start - 1);
                    state->vac[ins->index].container_ref_stride = 1;
                    break;
                }

                /* Component at-partition ("length AT position") subscript
                 * on a whole VECTOR -- DSUB.md's confirmed table: TAG1=3 on
                 * both subscript operand words (the "component" column's
                 * at-partition row, distinct from TAG1=7's ARRAY-dimension
                 * at-partition, which isn't implemented here), argument
                 * order confirmed "length AT position" (`V1(2 AT 2)` means
                 * 2 elements starting at 1-indexed position 2), matching
                 * the already-confirmed ARRAY-dimension case's own operand
                 * order. Produces a VECTOR-shaped VAC container result,
                 * same mechanism as the asterisk case just above. Only the
                 * single-dimension VECTOR/ARRAY case (`base->rows == 0`) is
                 * implemented -- a MATRIX at-partition (`M1(2 AT 1,1)`)
                 * needs a third operand for the other, plainly-indexed
                 * dimension and isn't handled, so it deliberately falls
                 * through to the ordinary per-dimension path below (which
                 * will fail loudly on the unexpected TAG1 rather than
                 * silently misreading length/position as raw indices).
                 * User-reported (046-XYZ_TO_POLAR.hal's
                 * `ABVAL(P$(2 AT 1))`, `P` a `VECTOR`). Deliberately NOT
                 * marked `is_container_ref` (unlike the asterisk-partition
                 * cases above): confirmed via HALSFC that real HAL/S
                 * rejects `V$(n AT p) = ...;` outright at compile time
                 * (QD1/AV3: it type-checks the partition against the
                 * *whole* vector's declared length, not the slice, so no
                 * source shape can ever satisfy it) -- not a construct any
                 * real compiled program can produce, so left read-only.
                 *
                 * Gated on `ins->tag == 4` (this instruction's own
                 * operator-word TAG, confirmed elsewhere in this file to be
                 * "the HALMAT class of the subscripted result" -- 4=VECTOR)
                 * -- user-reported, 254-TEST1.hal's `INPUT$(4 AT I)`
                 * (`INPUT` a plain `BIT(24)`, i.e. an ordinary SUBBIT-style
                 * at-partition, `ins->tag`=1=BIT) previously *also* matched
                 * this branch's old, looser condition (`base->rows == 0 &&`
                 * both operands TAG1==3 -- true for ANY non-MATRIX base,
                 * scalar included), reading through `base->elements` even
                 * though a plain scalar `BIT` symbol has no real element
                 * array at all -- `ensure_container()`'s own generic
                 * "unknown shape" fallback (`HALMAT_CONTAINER_CAPACITY`
                 * placeholder) silently allocates one anyway for *any*
                 * unclassified `SYT` entry, scalar or not, so this branch
                 * fired and produced a bogus whole-container result
                 * ("VAC whole-container result referenced outside an
                 * arrayed-paragraph replay" at the following BTOI, since
                 * that result is never actually inside a replay -- a
                 * plain `SUBBIT`-style at-partition is a *single* value,
                 * not a container, so it correctly falls through to the
                 * ordinary per-dimension `is_ref` path below instead once
                 * this branch stops misfiring for it). */
                if (num_indices == 2 && base->rows == 0 && ins->tag == 4 &&
                    ins->operands[1].tag1 == 3 && ins->operands[2].tag1 == 3) {
                    resolved_value_t lenv, posv;
                    if (!resolve_operand(state, &ins->operands[1], &lenv)) break;
                    if (!resolve_operand(state, &ins->operands[2], &posv)) break;
                    int32_t len = rv_to_integer(&lenv);
                    int32_t pos = rv_to_integer(&posv) - 1; /* HAL/S is 1-indexed */
                    if (len < 0) len = 0;
                    if (pos < 0) pos = 0;
                    if (len > HALMAT_CONTAINER_CAPACITY || (size_t)pos + (size_t)len > base->element_count) {
                        fail(state, "DSUB: at-partition subscript out of range");
                        break;
                    }
                    halmat_scalar_t buf[HALMAT_CONTAINER_CAPACITY];
                    for (int32_t k = 0; k < len; k++) buf[k] = base->elements[(size_t)pos + k];
                    if (!store_container_result(state, ins->index, buf, (size_t)len, 0, len)) break;
                    break;
                }

                /* Native BIT-string at-partition subscript (`B$(width AT
                 * position)`), applied directly to a plain, non-array BIT
                 * variable's own raw storage -- an ordinary bit-substring
                 * read (HAL/S's own "component" at-partition kind, same
                 * DSUB shape as the VECTOR-slice case just above, but on a
                 * scalar rather than a container: distinguished by this
                 * instruction's own operator-word TAG, confirmed
                 * elsewhere in this file to be "the HALMAT class of the
                 * subscripted result" -- 1=BIT here, vs. 4=VECTOR above).
                 * User-reported, 254-TEST1.hal's `INTEGER(INPUT$(4 AT
                 * I))` (`INPUT` a plain `BIT(24)`, unpacking it 4 bits at
                 * a time into decimal digits): this used to fall into the
                 * VECTOR-slice branch above (before that branch was
                 * correctly gated on `ins->tag==4`), reading through
                 * `base->elements` even though a plain scalar `BIT` symbol
                 * has none -- `ensure_container()`'s own generic
                 * "unknown shape" fallback silently allocates a bogus
                 * placeholder container for *any* unclassified `SYT`
                 * entry regardless, so this branch fired anyway and
                 * produced nonsense.
                 *
                 * Deferred (not resolved to a value here): stores a
                 * bitpart_ref (state.h) instead, so this same DSUB result
                 * works as either a read (resolve_operand's QUAL_VAC case
                 * dereferences it) or a write-through destination
                 * (write_destination's QUAL_VAC case does) -- confirmed
                 * both directions are needed by real corpus programs (see
                 * bitpart_ref's own state.h comment for the write-side
                 * case, 250-BITS.hal's `B$(1) = ON;`, found for the
                 * sibling single-index branch just below but the same
                 * fix applies here on general principle: real HAL/S may
                 * equally allow `B$(width AT position) = ...;`, and there
                 * is no cost to supporting it since the mechanism is
                 * identical). Bit numbering is MSB-first within the
                 * base's own declared width (USA003090 Sec. 8.2's
                 * documented BIT-string convention, already relied on by
                 * format_bit_field's identical "width-1-i" indexing
                 * elsewhere in this file): HAL/S bit position `p`
                 * (1-indexed) of a `W`-bit string is 0-indexed-from-LSB
                 * position `W-p` in this interpreter's own right-
                 * justified `uint32_t` BIT representation, so the `width`
                 * bits starting at position `position` occupy 0-indexed-
                 * from-LSB positions `[W-position-width+1, W-position]`
                 * inclusive -- extracted via a single shift-and-mask once
                 * the base's own full raw bit pattern is read (reusing
                 * the exact same "read any resolvable kind's raw bits"
                 * technique this opcode family's own reference-context
                 * branch already established for `SUBBIT`, just above in
                 * this same `case` group, since a plain `BIT`/`INTEGER`/
                 * `SCALAR` base all resolve the same way here). */
                if (num_indices == 2 && ins->tag == 1 &&
                    ins->operands[1].tag1 == 3 && ins->operands[2].tag1 == 3) {
                    resolved_value_t widthv, posv;
                    if (!resolve_operand(state, &ins->operands[1], &widthv)) break;
                    if (!resolve_operand(state, &ins->operands[2], &posv)) break;
                    int width = rv_to_integer(&widthv);
                    int position = rv_to_integer(&posv);
                    int decl_width = 32;
                    if (state->symtab) {
                        const halmat_symtab_entry_t *bsym = halmat_symtab_find_by_index(state->symtab, base_syt);
                        if (bsym && bsym->bit_width > 0) decl_width = bsym->bit_width;
                    }
                    if (width < 0 || width > 32 || position < 1 || position + width - 1 > decl_width) {
                        fail(state, "DSUB: BIT at-partition subscript out of range");
                        break;
                    }
                    if (ins->index >= HALMAT_VAC_MAX) { fail(state, "VAC index out of range"); break; }
                    state->vac[ins->index].is_ref = false;
                    state->vac[ins->index].is_bitpart_ref = true;
                    state->vac[ins->index].bitpart_target_syt = base_syt;
                    state->vac[ins->index].bitpart_position = position;
                    state->vac[ins->index].bitpart_width = width;
                    break;
                }

                /* Single-index BIT-string subscript (`B$(n)`, a single
                 * 1-bit extraction), on a plain (non-array) BIT/INTEGER/
                 * SCALAR base -- the same underlying "component" DSUB
                 * shape as the at-partition case just above, with an
                 * implicit width of 1 rather than an explicit "width AT
                 * position" pair (index kind, TAG1=1, per this file's own
                 * confirmed table, rather than TAG1=3). User-reported,
                 * 254-TEST2.hal's `IF B$(1) THEN ...;`/`IF B$(#) THEN
                 * ...;` (`B` a plain `BIT(16)`, used directly as a boolean
                 * condition) and 158-STATE.hal's identical pattern:
                 * "BTRU: operand is not BIT" -- previously fell through to
                 * the generic per-dimension index loop below, producing a
                 * bogus numeric `is_ref` into a scalar `BIT` symbol's own
                 * nonexistent element array, the same class of bug as the
                 * at-partition case above. Reuses that same MSB-first
                 * shift-and-mask extraction with `width` fixed to 1.
                 * Deferred (bitpart_ref), not resolved to a value here --
                 * also user-reported as an *assignment* target,
                 * 250-BITS.hal's `B$(1) = ON;`: BASN's own receiver
                 * operand landed on write_destination's generic "not a
                 * subscript reference" fallback before this, since the
                 * old code eagerly stored a plain `is_bits` value instead
                 * of something write-through-capable (see bitpart_ref's
                 * own state.h comment). */
                if (num_indices == 1 && ins->tag == 1 && ins->operands[1].tag1 == 1) {
                    resolved_value_t posv;
                    if (!resolve_operand(state, &ins->operands[1], &posv)) break;
                    int position = rv_to_integer(&posv);
                    int decl_width = 32;
                    if (state->symtab) {
                        const halmat_symtab_entry_t *bsym = halmat_symtab_find_by_index(state->symtab, base_syt);
                        if (bsym && bsym->bit_width > 0) decl_width = bsym->bit_width;
                    }
                    if (position < 1 || position > decl_width) {
                        fail(state, "DSUB: BIT index subscript out of range");
                        break;
                    }
                    if (ins->index >= HALMAT_VAC_MAX) { fail(state, "VAC index out of range"); break; }
                    state->vac[ins->index].is_ref = false;
                    state->vac[ins->index].is_bitpart_ref = true;
                    state->vac[ins->index].bitpart_target_syt = base_syt;
                    state->vac[ins->index].bitpart_position = position;
                    state->vac[ins->index].bitpart_width = 1;
                    break;
                }

                /* CHARACTER to-partition substring (`C$(start TO end)`),
                 * including the `#`-relative CSZ form -- DSUB.md's own
                 * "To-partition (CHARACTER substring...) ... still isn't
                 * handled" gap, confirmed empirically here (this
                 * instruction's own operator-word TAG, the HALMAT class of
                 * the result, is 2=CHARACTER; the start bound's own TAG1=2,
                 * the "component" column's to-partition row per this
                 * file's already-confirmed table -- true whether that
                 * bound is an ordinary value or a CSZ operand, since
                 * DSUB.md's own traces show TAG1=2 on the CSZ operand
                 * itself too). User-reported, 159-AGE.hal's `CASE_NUM =
                 * INTEGER(C$(1 TO 3));` (`C` a plain `CHARACTER(80)`, not
                 * an ARRAY) -- previously fell through to the generic
                 * per-dimension index loop below, which misreads a
                 * to-partition's own (start, end) pair as two unrelated
                 * plain indices, producing a bogus numeric `is_ref` into a
                 * scalar CHARACTER symbol's own (nonexistent) element
                 * array (`ensure_container()`'s generic "unknown shape"
                 * fallback silently allocates a numeric placeholder for
                 * any unclassified SYT entry) -- CTOI then failed
                 * ("operand is not CHARACTER") since that phantom result
                 * resolves as RV_SCALAR, not RV_STRING.
                 *
                 * CSZ (`C(1 TO #-DECIMALS)`, `C(#-DECIMALS-1 TO #)`,
                 * 160-REFORMAT.hal) resolved via resolve_to_partition_
                 * bound() (see its own comment for the confirmed `DATA`=0/
                 * 2 encoding) -- each bound consumes 1 or 2 operand words,
                 * so `num_indices` (a fixed `operand_count-1` computed
                 * once for every DSUB kind) can't gate this branch the
                 * way the old plain-literal-only version did; detected
                 * instead by the start bound's own TAG1==2 marker plus at
                 * least 3 total operands (base + at least 2 more),
                 * regardless of how many CSZ subsidiary words follow.
                 * Deliberately scoped to a plain (non-ARRAY) base. Read-
                 * only (no fixture or corpus program needs `C$(a TO b) =
                 * ...;` as an assignment target yet). */
                if (ins->tag == 2 && ins->operand_count >= 3 && ins->operands[1].tag1 == 2) {
                    const char *src = state->syt[base_syt].char_value ? state->syt[base_syt].char_value : "";
                    int32_t srclen = (int32_t)strlen(src);
                    uint8_t oi = 1;
                    int32_t start, end;
                    if (!resolve_to_partition_bound(state, ins, &oi, srclen, &start)) break;
                    if (!resolve_to_partition_bound(state, ins, &oi, srclen, &end)) break;
                    if (start < 1) start = 1;
                    if (end > srclen) end = srclen;
                    int32_t width = end - start + 1;
                    if (width < 0) width = 0;
                    char *sub = malloc((size_t)width + 1);
                    if (!sub) { fail(state, "out of memory"); break; }
                    if (width > 0) memcpy(sub, src + (start - 1), (size_t)width);
                    sub[width] = '\0';
                    if (ins->index >= HALMAT_VAC_MAX) { fail(state, "VAC index out of range"); free(sub); break; }
                    state->vac[ins->index].is_ref = false;
                    state->vac[ins->index].is_string = true;
                    state->vac[ins->index].string = sub; /* deliberately not freeing any prior
                        * value at this slot -- VAC string slots are reused across loop
                        * iterations without freeing (state.h's own documented convention;
                        * see e.g. CCAT), bounded by this run's own iteration count rather
                        * than reference-counted, freed in bulk by interp_cleanup(). */
                    break;
                }

                /* CHARACTER single-index substring (`C$(n)`, a single
                 * 1-character extraction) on a plain (non-ARRAY) CHARACTER
                 * base -- the exact same underlying gap as the to-partition
                 * case just above, one operand instead of two. User-
                 * reported, 159-AGE.hal's `SEX = INTEGER(C$(6));`. */
                if (num_indices == 1 && ins->tag == 2 && ins->operands[1].tag1 == 1) {
                    resolved_value_t idxv;
                    if (!resolve_operand(state, &ins->operands[1], &idxv)) break;
                    int32_t idx = rv_to_integer(&idxv);
                    const char *src = state->syt[base_syt].char_value ? state->syt[base_syt].char_value : "";
                    int32_t srclen = (int32_t)strlen(src);
                    char *sub = malloc(2);
                    if (!sub) { fail(state, "out of memory"); break; }
                    if (idx >= 1 && idx <= srclen) {
                        sub[0] = src[idx - 1];
                        sub[1] = '\0';
                    } else {
                        sub[0] = '\0';
                    }
                    if (ins->index >= HALMAT_VAC_MAX) { fail(state, "VAC index out of range"); free(sub); break; }
                    state->vac[ins->index].is_ref = false;
                    state->vac[ins->index].is_string = true;
                    state->vac[ins->index].string = sub;
                    break;
                }

                /* Numeric ARRAY to-partition range ("start TO end") on a
                 * 1-D array, resolved per-element via an enclosing ADLP/
                 * DLPE arrayed replay -- user-reported
                 * (partition_array_shift_wrong; 138-FILTER.hal's sliding-
                 * window shift, `[BUFF] 1 TO 3 = [BUFF] 2 TO 4;`, BUFF an
                 * ARRAY(4) SCALAR). Confirmed empirically that a numeric
                 * ARRAY to-partition compiles as an ordinary 2-operand
                 * DSUB with no special TAG1 marking (unlike the VECTOR
                 * to-partition branch above, gated on TAG1==2) -- the
                 * compiler instead signals "one element per iteration,
                 * not one bulk range-to-range copy" purely by wrapping
                 * the whole SASN in an ADLP(count)/DLPE replay, count ==
                 * end-start+1. A 1-D ARRAY (base->rows == 0, i.e. no
                 * symtab-confirmed second dimension) has no second
                 * dimension for 2 operands to legitimately index, so
                 * num_indices==2 here can only be a to-partition range,
                 * never two genuine per-dimension indices -- the generic
                 * multi-dimension "placeholder stride" fallback below
                 * (designed for an unknown real dimension count) instead
                 * misread (start,end) as (dim0_index,dim1_index) and
                 * computed one FIXED offset via its base-16 placeholder
                 * stride, identical on every one of the ADLP replay's
                 * iterations since arrayed_index was never consulted --
                 * so the same one element got read/written 3 times over
                 * (e.g. always BUFF(3)=BUFF(4)) instead of the 3
                 * different element pairs the shift actually needs.
                 * Resolves to element `start + arrayed_index` (0 when
                 * reached outside any active replay, matching this
                 * shape's only confirmed real trigger, which is always
                 * ADLP-wrapped) -- a plain writable single-element
                 * reference (`is_ref`), the same mechanism the ordinary
                 * single-index case below already uses, so both the
                 * receiver (dest, `[BUFF] 1 TO 3 = ...`) and source
                 * (`... = [BUFF] 2 TO 4`) sides work identically through
                 * the existing read/write-through machinery. */
                if (base->rows == 0 && num_indices == 2) {
                    resolved_value_t startv;
                    if (!resolve_operand(state, &ins->operands[1], &startv)) break;
                    int32_t start = rv_to_integer(&startv);
                    int32_t idx = start - 1 + (state->arrayed_index >= 0 ? state->arrayed_index : 0);
                    if (idx < 0) idx = 0;
                    if (ins->index >= HALMAT_VAC_MAX) { fail(state, "VAC index out of range"); break; }
                    state->vac[ins->index].is_ref = true;
                    state->vac[ins->index].ref_syt = base_syt;
                    state->vac[ins->index].ref_offset = (size_t)idx % (base->element_count ? base->element_count : 1);
                    break;
                }

                bool ok = true;
                size_t offset = 0;
                if (base->rows > 0 && num_indices == 2) {
                    resolved_value_t ridx, cidx;
                    if (!resolve_operand(state, &ins->operands[1], &ridx)) { ok = false; }
                    else if (!resolve_operand(state, &ins->operands[2], &cidx)) { ok = false; }
                    else {
                        int32_t r = rv_to_integer(&ridx) - 1, c = rv_to_integer(&cidx) - 1;
                        if (r < 0) r = 0;
                        if (c < 0) c = 0;
                        offset = (size_t)r * (size_t)base->cols + (size_t)c;
                    }
                } else {
                    for (uint8_t i = 0; i < num_indices; i++) {
                        resolved_value_t idx;
                        if (!resolve_operand(state, &ins->operands[1 + i], &idx)) { ok = false; break; }
                        int32_t idx_val = rv_to_integer(&idx) - 1; /* HAL/S is 1-indexed */
                        if (idx_val < 0) idx_val = 0;
                        offset = offset * 16 + (size_t)idx_val; /* placeholder stride per extra dimension */
                    }
                }
                if (!ok) break;
                offset %= base->element_count;

                if (ins->index >= HALMAT_VAC_MAX) { fail(state, "VAC index out of range"); break; }
                state->vac[ins->index].is_ref = true;
                state->vac[ins->index].ref_syt = base_syt;
                state->vac[ins->index].ref_offset = offset;
                break;
            }

            case OP_MASN:
            case OP_VASN: {
                /* Whole-container assign, source-first/receiver-second
                 * like the rest of the xASN family (class-3/MASN.md,
                 * class-4/VASN.md). The receiver may also be a MATRIX
                 * row-partition (or whole-VECTOR) select instead of a
                 * plain SYT -- `M$(I,*) = C * MM$(I,*);` (a QUAL_VAC
                 * referencing a prior asterisk-partition DSUB result) --
                 * user-reported (047-ROWS.hal). DSUB's own asterisk-select
                 * branch marks such a VAC slot `is_container_ref`
                 * (additively, alongside the `is_container` it already
                 * sets for the read direction, which this doesn't touch)
                 * with the base SYT/offset/stride the selected
                 * row/column/vector/slice actually lives at, letting this
                 * write straight back into it instead of discarding an
                 * orphaned copy -- generalized to a per-element stride
                 * (`container_ref_stride`) so the column-select case
                 * (`M$(*,j)`, stride = column count, not contiguous in
                 * row-major storage) writes correctly too, not just the
                 * originally-implemented contiguous (stride=1) cases. */
                if (ins->operand_count != 2) { fail(state, "MASN/VASN: expected 2 operands"); break; }
                halmat_scalar_t *src; size_t src_count; int src_rows, src_cols;
                if (!resolve_container(state, &ins->operands[0], &src, &src_count, &src_rows, &src_cols)) break;
                if (ins->operands[1].qual == QUAL_VAC) {
                    if (ins->operands[1].data >= HALMAT_VAC_MAX) { fail(state, "MASN/VASN: VAC index out of range"); break; }
                    halmat_vac_slot_t *slot = &state->vac[ins->operands[1].data];
                    if (!slot->is_container_ref) { fail(state, "MASN/VASN: receiver must be SYT"); break; }
                    if (slot->container_ref_syt >= HALMAT_SYT_MAX) { fail(state, "MASN/VASN: receiver SYT index out of range"); break; }
                    halmat_syt_entry_t *rbase = &state->syt[slot->container_ref_syt];
                    if (src_count != slot->container_count ||
                        (src_count > 0 &&
                         slot->container_ref_offset + (src_count - 1) * slot->container_ref_stride >= rbase->element_count)) {
                        fail(state, "MASN/VASN: shape mismatch (%zu vs %zu elements)", src_count, slot->container_count);
                        break;
                    }
                    for (size_t k = 0; k < src_count; k++) {
                        rbase->elements[slot->container_ref_offset + k * slot->container_ref_stride] = src[k];
                    }
                    break;
                }
                if (ins->operands[1].qual != QUAL_SYT) { fail(state, "MASN/VASN: receiver must be SYT"); break; }
                uint16_t dest_syt = ins->operands[1].data;
                if (dest_syt >= HALMAT_SYT_MAX) { fail(state, "MASN/VASN: SYT index out of range"); break; }
                ensure_container(state, dest_syt);
                halmat_syt_entry_t *dest = &state->syt[dest_syt];
                if (dest->array_of_vector && state->arrayed_index >= 0 && dest->rows > 0) {
                    /* ARRAY(n) VECTOR(m) destination, mid ADLP/DLPE replay
                     * (state.h's array_of_vector comment; user-reported,
                     * 117-EXAMPLE_8.hal's `[VELOCITY] = ([POSITIONS] -
                     * [OLD_POSN]) / DELTA_T;` and `[OLD_POSN] =
                     * [POSITIONS];`) -- write just the current
                     * arrayed_index's own VECTOR(m), not the whole
                     * container; `src` is already sliced to exactly one
                     * VECTOR by resolve_container's matching array_of_vector
                     * case above when the source is itself an ARRAY-of-
                     * VECTOR SYT, or is already a single VECTOR-shaped VAC
                     * result (an arithmetic chain rooted at one) otherwise. */
                    if (src_count != (size_t)dest->cols) {
                        fail(state, "MASN/VASN: shape mismatch (%zu vs %d elements)", src_count, dest->cols);
                        break;
                    }
                    size_t i = (size_t)state->arrayed_index % (size_t)dest->rows;
                    memcpy(&dest->elements[i * (size_t)dest->cols], src, src_count * sizeof(halmat_scalar_t));
                    break;
                }
                if (dest->element_count != src_count) {
                    fail(state, "MASN/VASN: shape mismatch (%zu vs %zu elements)", src_count, dest->element_count);
                    break;
                }
                memcpy(dest->elements, src, src_count * sizeof(halmat_scalar_t));
                dest->rows = src_rows;
                dest->cols = src_cols;
                break;
            }

            case OP_MNEG:
            case OP_VNEG: {
                if (ins->operand_count != 1) { fail(state, "MNEG/VNEG: expected 1 operand"); break; }
                halmat_scalar_t *src; size_t count; int rows, cols;
                if (!resolve_container(state, &ins->operands[0], &src, &count, &rows, &cols)) break;
                if (count > HALMAT_CONTAINER_CAPACITY) { fail(state, "MNEG/VNEG: container too large"); break; }
                halmat_scalar_t result[HALMAT_CONTAINER_CAPACITY];
                for (size_t i = 0; i < count; i++) result[i] = halmat_scalar_negate(src[i]);
                if (!store_container_result(state, ins->index, result, count, rows, cols)) break;
                break;
            }

            case OP_MTOM:
            case OP_VTOV: {
                /* Matrix/vector precision scale (class-3/MTOM.md,
                 * class-4/VTOV.md) -- same exp$(@SINGLE)/exp$(@DOUBLE)
                 * trigger and TAG convention as STOS, applied
                 * elementwise. One operand (source SYT); consumed by a
                 * following MASN/VASN via this instruction's own VAC
                 * slot, same "no destination operand" pattern as MADD/
                 * VADD. Confirmed empirically this session to compile as
                 * a single whole-container instruction (like MADD/VADD),
                 * not the ADLP/DLPE-wrapped per-element loop originally
                 * documented -- see MTOM.md/VTOV.md's correction. */
                if (ins->operand_count != 1) { fail(state, "MTOM/VTOV: expected 1 operand"); break; }
                halmat_scalar_t *ca; size_t count_a; int rows_a, cols_a;
                if (!resolve_container(state, &ins->operands[0], &ca, &count_a, &rows_a, &cols_a)) break;
                if (count_a > HALMAT_CONTAINER_CAPACITY) { fail(state, "MTOM/VTOV: container too large"); break; }
                halmat_scalar_t result[HALMAT_CONTAINER_CAPACITY];
                bool to_double = (ins->tag == 2);
                for (size_t i = 0; i < count_a; i++) result[i] = scale_precision(ca[i], to_double);
                if (!store_container_result(state, ins->index, result, count_a, rows_a, cols_a)) break;
                break;
            }

            case OP_MADD:
            case OP_MSUB:
            case OP_VADD:
            case OP_VSUB: {
                /* Elementwise add/sub, class-3/MADD.md's confirmed
                 * "no destination operand -- consumed by a following
                 * MASN via a VAC-qualified operand" pattern. */
                if (ins->operand_count != 2) { fail(state, "MADD/MSUB/VADD/VSUB: expected 2 operands"); break; }
                halmat_scalar_t *ca, *cb; size_t count_a, count_b; int rows_a, cols_a, rows_b, cols_b;
                if (!resolve_container(state, &ins->operands[0], &ca, &count_a, &rows_a, &cols_a)) break;
                if (!resolve_container(state, &ins->operands[1], &cb, &count_b, &rows_b, &cols_b)) break;
                if (count_a != count_b) { fail(state, "MADD/MSUB/VADD/VSUB: operand shape mismatch"); break; }
                if (count_a > HALMAT_CONTAINER_CAPACITY) { fail(state, "MADD/MSUB/VADD/VSUB: container too large"); break; }
                bool is_sub = (ins->opcode == OP_MSUB || ins->opcode == OP_VSUB);
                halmat_scalar_t result[HALMAT_CONTAINER_CAPACITY];
                for (size_t i = 0; i < count_a; i++) {
                    result[i] = is_sub ? halmat_scalar_sub(ca[i], cb[i]) : halmat_scalar_add(ca[i], cb[i]);
                }
                if (!store_container_result(state, ins->index, result, count_a, rows_a, cols_a)) break;
                break;
            }

            case OP_MSPR:
            case OP_MSDV:
            case OP_VSPR:
            case OP_VSDV: {
                /* Matrix/vector times/divided-by a plain SCALAR operand
                 * (class-3/MSPR.md, class-3/MSDV.md, class-4/VSPR.md,
                 * class-4/VSDV.md) -- assumed container-operand-first,
                 * scalar-operand-second by analogy with every other
                 * base-then-modifier operand order in this project
                 * (e.g. SPEX/IPEX's base-then-exponent); operand-word
                 * order isn't independently confirmed in the primary
                 * sources for these four opcodes specifically. */
                if (ins->operand_count != 2) { fail(state, "MSPR/MSDV/VSPR/VSDV: expected 2 operands"); break; }
                halmat_scalar_t *ca; size_t count; int rows, cols;
                if (!resolve_container(state, &ins->operands[0], &ca, &count, &rows, &cols)) break;
                if (!resolve_operand(state, &ins->operands[1], &b)) break;
                if (count > HALMAT_CONTAINER_CAPACITY) { fail(state, "MSPR/MSDV/VSPR/VSDV: container too large"); break; }
                halmat_scalar_t scalar_operand = rv_to_scalar(&b);
                bool is_div = (ins->opcode == OP_MSDV || ins->opcode == OP_VSDV);
                halmat_scalar_t result[HALMAT_CONTAINER_CAPACITY];
                if (is_div && halmat_scalar_to_double(scalar_operand) == 0.0) {
                    /* USA003090 App. C error 25 ("VECTOR/MATRIX division
                     * by zero"): standard fixup is the original vector/
                     * matrix, unchanged -- not an abort. */
                    if (!arithmetic_error_should_apply_fixup(state, HAL_S_ERROR_VECTOR_MATRIX_DIVIDE_BY_ZERO, &state->pc, &branched)) break;
                    for (size_t i = 0; i < count; i++) result[i] = ca[i];
                } else if (is_div) {
                    for (size_t i = 0; i < count; i++) halmat_scalar_divide(ca[i], scalar_operand, &result[i]);
                } else {
                    for (size_t i = 0; i < count; i++) result[i] = halmat_scalar_multiply(ca[i], scalar_operand);
                }
                if (!store_container_result(state, ins->index, result, count, rows, cols)) break;
                break;
            }

            case OP_MTRA: {
                if (ins->operand_count != 1) { fail(state, "MTRA: expected 1 operand"); break; }
                halmat_scalar_t *src; size_t count; int rows, cols;
                if (!resolve_container(state, &ins->operands[0], &src, &count, &rows, &cols)) break;
                if (rows <= 0 || cols <= 0) { fail(state, "MTRA: operand is not a MATRIX (unknown shape)"); break; }
                if (count > HALMAT_CONTAINER_CAPACITY) { fail(state, "MTRA: container too large"); break; }
                halmat_scalar_t result[HALMAT_CONTAINER_CAPACITY];
                for (int r = 0; r < rows; r++)
                    for (int c = 0; c < cols; c++)
                        result[c * rows + r] = src[r * cols + c];
                if (!store_container_result(state, ins->index, result, count, cols, rows)) break;
                break;
            }

            case OP_MINV: {
                /* Two operands: operand[0]=SYT (the matrix), operand[1]=
                 * QUAL=5=LIT. class-3/MINV.md previously left the second
                 * operand's role unresolved (an earlier session, seeing
                 * only the `A**(-1)` case, mistook its HALMAT-word DATA
                 * field -- the literal *table index* -- for the operand's
                 * actual value, since that index didn't match -1). This
                 * session's `029-DATATYPES.hal` fixture (`A2B**2`,
                 * `A2B**(-1)`, `A2B**0`, all real HALSFC-compiled) decodes
                 * the literal table entries themselves as 2.0/-1.0/0.0 --
                 * exactly the source exponents -- confirming MINV is
                 * HAL/S's general matrix-exponentiation opcode (`M**N`),
                 * not INVERSE-only: N=-1 is inverse, N=0 is the identity,
                 * N>0 is N-fold self-multiplication. Other negative N
                 * (inverse-then-power) aren't confirmed against a real
                 * compile but are handled by the same rule MATRIX
                 * exponentiation's documented integer-power restriction
                 * implies. */
                if (ins->operand_count != 2) { fail(state, "MINV: expected 2 operands"); break; }
                halmat_scalar_t *src; size_t count; int rows, cols;
                if (!resolve_container(state, &ins->operands[0], &src, &count, &rows, &cols)) break;
                if (rows <= 0 || cols <= 0 || rows != cols) { fail(state, "MINV: operand is not a square MATRIX"); break; }
                if (count > HALMAT_CONTAINER_CAPACITY) { fail(state, "MINV: container too large"); break; }
                if (!resolve_operand(state, &ins->operands[1], &b)) break;
                int32_t exponent = rv_to_integer(&b);
                halmat_scalar_t result[HALMAT_CONTAINER_CAPACITY];
                if (exponent == 0) {
                    fill_identity_matrix(src, rows, result);
                } else {
                    halmat_scalar_t base[HALMAT_CONTAINER_CAPACITY];
                    if (exponent < 0) {
                        if (!matrix_invert(src, rows, base)) {
                            /* USA003090 App. C error 27 ("argument of
                             * INVERSE is a singular matrix"): standard
                             * fixup is the identity matrix, not an abort
                             * -- applies here too, since a negative-
                             * exponent M**N still inverts M as its first
                             * step. Same GOTO-handler check as BFNC's
                             * INVERSE selector (49) above. */
                            if (!arithmetic_error_should_apply_fixup(state, HAL_S_ERROR_INVERSE_SINGULAR, &state->pc, &branched)) break;
                            fill_identity_matrix(src, rows, base);
                        }
                    } else {
                        memcpy(base, src, count * sizeof(halmat_scalar_t));
                    }
                    fill_identity_matrix(src, rows, result);
                    uint32_t magnitude = (exponent < 0) ? (uint32_t)(-(int64_t)exponent) : (uint32_t)exponent;
                    for (uint32_t p = 0; p < magnitude; p++) {
                        halmat_scalar_t tmp[HALMAT_CONTAINER_CAPACITY];
                        matrix_multiply_square(result, base, rows, tmp);
                        memcpy(result, tmp, count * sizeof(halmat_scalar_t));
                    }
                }
                if (!store_container_result(state, ins->index, result, count, rows, cols)) break;
                break;
            }

            case OP_MMPR: {
                if (ins->operand_count != 2) { fail(state, "MMPR: expected 2 operands"); break; }
                halmat_scalar_t *ca, *cb; size_t count_a, count_b; int rows_a, cols_a, rows_b, cols_b;
                if (!resolve_container(state, &ins->operands[0], &ca, &count_a, &rows_a, &cols_a)) break;
                if (!resolve_container(state, &ins->operands[1], &cb, &count_b, &rows_b, &cols_b)) break;
                if (rows_a <= 0 || cols_a <= 0 || rows_b <= 0 || cols_b <= 0) { fail(state, "MMPR: operands must be MATRIX (unknown shape)"); break; }
                if (cols_a != rows_b) { fail(state, "MMPR: dimension mismatch (%dx%d times %dx%d)", rows_a, cols_a, rows_b, cols_b); break; }
                size_t result_count = (size_t)rows_a * (size_t)cols_b;
                if (result_count > HALMAT_CONTAINER_CAPACITY) { fail(state, "MMPR: result too large"); break; }
                halmat_scalar_t result[HALMAT_CONTAINER_CAPACITY];
                for (int i = 0; i < rows_a; i++) {
                    for (int j = 0; j < cols_b; j++) {
                        halmat_scalar_t sum = halmat_scalar_zero(false);
                        for (int k = 0; k < cols_a; k++) {
                            sum = halmat_scalar_add(sum, halmat_scalar_multiply(ca[i * cols_a + k], cb[k * cols_b + j]));
                        }
                        result[i * cols_b + j] = sum;
                    }
                }
                if (!store_container_result(state, ins->index, result, result_count, rows_a, cols_b)) break;
                break;
            }

            case OP_MVPR: {
                /* Matrix-vector product (matrix premultiplies vector),
                 * class-4/MVPR.md. */
                if (ins->operand_count != 2) { fail(state, "MVPR: expected 2 operands"); break; }
                halmat_scalar_t *ca, *cb; size_t count_a, count_b; int rows_a, cols_a, rows_b, cols_b;
                if (!resolve_container(state, &ins->operands[0], &ca, &count_a, &rows_a, &cols_a)) break;
                if (!resolve_container(state, &ins->operands[1], &cb, &count_b, &rows_b, &cols_b)) break;
                if (rows_a <= 0 || cols_a <= 0) { fail(state, "MVPR: first operand must be MATRIX"); break; }
                if ((size_t)cols_a != count_b) { fail(state, "MVPR: dimension mismatch"); break; }
                if ((size_t)rows_a > HALMAT_CONTAINER_CAPACITY) { fail(state, "MVPR: result too large"); break; }
                halmat_scalar_t result[HALMAT_CONTAINER_CAPACITY];
                for (int i = 0; i < rows_a; i++) {
                    halmat_scalar_t sum = halmat_scalar_zero(false);
                    for (int k = 0; k < cols_a; k++) sum = halmat_scalar_add(sum, halmat_scalar_multiply(ca[i * cols_a + k], cb[k]));
                    result[i] = sum;
                }
                if (!store_container_result(state, ins->index, result, (size_t)rows_a, 0, rows_a)) break;
                break;
            }

            case OP_VMPR: {
                /* Vector-matrix product (vector premultiplies matrix),
                 * class-4/VMPR.md. */
                if (ins->operand_count != 2) { fail(state, "VMPR: expected 2 operands"); break; }
                halmat_scalar_t *ca, *cb; size_t count_a, count_b; int rows_a, cols_a, rows_b, cols_b;
                if (!resolve_container(state, &ins->operands[0], &ca, &count_a, &rows_a, &cols_a)) break;
                if (!resolve_container(state, &ins->operands[1], &cb, &count_b, &rows_b, &cols_b)) break;
                if (rows_b <= 0 || cols_b <= 0) { fail(state, "VMPR: second operand must be MATRIX"); break; }
                if (count_a != (size_t)rows_b) { fail(state, "VMPR: dimension mismatch"); break; }
                if ((size_t)cols_b > HALMAT_CONTAINER_CAPACITY) { fail(state, "VMPR: result too large"); break; }
                halmat_scalar_t result[HALMAT_CONTAINER_CAPACITY];
                for (int j = 0; j < cols_b; j++) {
                    halmat_scalar_t sum = halmat_scalar_zero(false);
                    for (int k = 0; k < rows_b; k++) sum = halmat_scalar_add(sum, halmat_scalar_multiply(ca[k], cb[k * cols_b + j]));
                    result[j] = sum;
                }
                if (!store_container_result(state, ins->index, result, (size_t)cols_b, 0, cols_b)) break;
                break;
            }

            case OP_VCRS: {
                if (ins->operand_count != 2) { fail(state, "VCRS: expected 2 operands"); break; }
                halmat_scalar_t *ca, *cb; size_t count_a, count_b; int rows_a, cols_a, rows_b, cols_b;
                if (!resolve_container(state, &ins->operands[0], &ca, &count_a, &rows_a, &cols_a)) break;
                if (!resolve_container(state, &ins->operands[1], &cb, &count_b, &rows_b, &cols_b)) break;
                if (count_a != 3 || count_b != 3) { fail(state, "VCRS: both operands must be 3-element VECTORs"); break; }
                halmat_scalar_t result[3];
                result[0] = halmat_scalar_sub(halmat_scalar_multiply(ca[1], cb[2]), halmat_scalar_multiply(ca[2], cb[1]));
                result[1] = halmat_scalar_sub(halmat_scalar_multiply(ca[2], cb[0]), halmat_scalar_multiply(ca[0], cb[2]));
                result[2] = halmat_scalar_sub(halmat_scalar_multiply(ca[0], cb[1]), halmat_scalar_multiply(ca[1], cb[0]));
                if (!store_container_result(state, ins->index, result, 3, 0, 3)) break;
                break;
            }

            case OP_VDOT: {
                /* Vector dot product, class-5/VDOT.md -- classed under
                 * SCALAR by HALMAT's result-type convention; unlike
                 * every other MATRIX/VECTOR opcode here, the result is a
                 * plain scalar VAC value, not a container. */
                if (ins->operand_count != 2) { fail(state, "VDOT: expected 2 operands"); break; }
                halmat_scalar_t *ca, *cb; size_t count_a, count_b; int rows_a, cols_a, rows_b, cols_b;
                if (!resolve_container(state, &ins->operands[0], &ca, &count_a, &rows_a, &cols_a)) break;
                if (!resolve_container(state, &ins->operands[1], &cb, &count_b, &rows_b, &cols_b)) break;
                if (count_a != count_b) { fail(state, "VDOT: operand shape mismatch"); break; }
                if (ins->index >= HALMAT_VAC_MAX) { fail(state, "VAC index out of range"); break; }
                halmat_scalar_t sum = halmat_scalar_zero(false);
                for (size_t i = 0; i < count_a; i++) sum = halmat_scalar_add(sum, halmat_scalar_multiply(ca[i], cb[i]));
                state->vac[ins->index].is_ref = false;
                state->vac[ins->index].is_scalar = true;
                state->vac[ins->index].scalar = sum;
                break;
            }

            case OP_VVPR: {
                /* Vector outer product, class-3/VVPR.md -- classed under
                 * MATRIX by HALMAT's result-type convention. */
                if (ins->operand_count != 2) { fail(state, "VVPR: expected 2 operands"); break; }
                halmat_scalar_t *ca, *cb; size_t count_a, count_b; int rows_a, cols_a, rows_b, cols_b;
                if (!resolve_container(state, &ins->operands[0], &ca, &count_a, &rows_a, &cols_a)) break;
                if (!resolve_container(state, &ins->operands[1], &cb, &count_b, &rows_b, &cols_b)) break;
                size_t result_count = count_a * count_b;
                if (result_count > HALMAT_CONTAINER_CAPACITY) { fail(state, "VVPR: result too large"); break; }
                halmat_scalar_t result[HALMAT_CONTAINER_CAPACITY];
                for (size_t i = 0; i < count_a; i++)
                    for (size_t j = 0; j < count_b; j++)
                        result[i * count_b + j] = halmat_scalar_multiply(ca[i], cb[j]);
                if (!store_container_result(state, ins->index, result, result_count, (int)count_a, (int)count_b)) break;
                break;
            }

            case OP_MEQU:
            case OP_MNEQ:
            case OP_VEQU:
            case OP_VNEQ: {
                /* Elementwise comparison across the whole container
                 * (class-7/MEQU.md/VEQU.md); *EQU true only if every
                 * element matches exactly (same exact-comparison
                 * rationale as SEQU -- see that case's comment). */
                if (ins->operand_count != 2) { fail(state, "MEQU/MNEQ/VEQU/VNEQ: expected 2 operands"); break; }
                halmat_scalar_t *ca, *cb; size_t count_a, count_b; int rows_a, cols_a, rows_b, cols_b;
                if (!resolve_container(state, &ins->operands[0], &ca, &count_a, &rows_a, &cols_a)) break;
                if (!resolve_container(state, &ins->operands[1], &cb, &count_b, &rows_b, &cols_b)) break;
                bool all_equal = (count_a == count_b);
                for (size_t i = 0; all_equal && i < count_a; i++) {
                    halmat_scalar_t diff = halmat_scalar_sub(ca[i], cb[i]);
                    if (!(diff.msw == 0 && diff.lsw == 0)) all_equal = false;
                }
                bool is_neq = (ins->opcode == OP_MNEQ || ins->opcode == OP_VNEQ);
                if (ins->index >= HALMAT_VAC_MAX) { fail(state, "VAC index out of range"); break; }
                state->vac[ins->index].is_ref = false;
                state->vac[ins->index].integer = (is_neq ? !all_equal : all_equal) ? 1 : 0;
                break;
            }

            case OP_IINT:
                if (ins->operand_count != 2) { fail(state, "IINT: expected 2 operands"); break; }
                if (!resolve_operand(state, &ins->operands[1], &a)) break;
                if (ins->operands[0].qual != QUAL_SYT) { fail(state, "IINT: destination must be SYT"); break; }
                state->syt[ins->operands[0].data].type = SYT_TYPE_INTEGER;
                state->syt[ins->operands[0].data].value = rv_to_integer(&a);
                break;

            case OP_SINT:
                /* Direct symbol-table form (class-8/SINT.md) -- goes
                 * through write_destination (not a raw state->syt field
                 * write) specifically so a whole-ARRAY/VECTOR/MATRIX
                 * destination (the uniform-INITIAL()-value case, e.g.
                 * `V1 INITIAL(4.0)` on ARRAY(3) SCALAR, confirmed to
                 * compile to exactly this single SINT plus a trailing
                 * IDLP/ADLP-and-DLPE metadata pair -- see interp_step's
                 * arrayed-paragraph replay) correctly redirects through
                 * the same syt_is_array_shaped check ordinary assignment
                 * opcodes use, instead of silently corrupting the
                 * array's element storage with a scalar write. The
                 * OFFSET-addressed form (QUAL_OFF) has two distinct
                 * sub-cases, disambiguated below: the `n#value` uniform-
                 * repeat form (STRI/SLRI/SINT/ELRI/ETRI, STRI.md's
                 * family, no run loop needed here -- SLRI's own count
                 * drives interp_step's arrayed-paragraph replay instead),
                 * and the explicit-literal-list form (`VECTOR
                 * INITIAL(10,11,12)`, bare STRI/SINT/ETRI, no SLRI at
                 * all) confirmed this session: PASS1's ICQ_OUTPUT emits
                 * one SINT per *coalesced run* of consecutive literal-
                 * table entries feeding consecutive target elements, the
                 * run length carried in the LIT operand's own tag1 byte
                 * (same mechanism OP_TINT above already uses for
                 * whole-structure INITIAL() lists) -- defaulting to 1
                 * when absent/zero, which is always the case for the
                 * `n#value` sub-case, so this run loop is a no-op there
                 * and both sub-cases share one code path. Compiling `V
                 * VECTOR INITIAL(10,11,12)` produces exactly one
                 * STRI/SINT/ETRI group with tag1=3; compiling `VECTOR
                 * INITIAL(1,-5,3)` (whose compile-time `-5` expression's
                 * own "5" operand literal is never referenced) splits
                 * into two SINTs, OFF=0/tag1=1 and OFF=1/tag1=2 -- i.e.
                 * OFF's own DATA is the run's absolute/cumulative target
                 * element offset, not implicitly relative to a persistent
                 * "current literal" pointer. */
                if (ins->operand_count != 2) { fail(state, "SINT: expected 2 operands"); break; }
                if (ins->operands[0].qual == QUAL_OFF && ins->operands[1].qual == QUAL_LIT) {
                    xint_offset_run(state, ins);
                    break;
                }
                if (!resolve_operand(state, &ins->operands[1], &a)) break;
                {
                    halmat_scalar_t sv = rv_to_scalar(&a);
                    a.kind = RV_SCALAR;
                    a.scalar = sv;
                }
                if (!write_destination(state, &ins->operands[0], &a)) break;
                break;

            case OP_CINT:
                /* Direct symbol-table form (class-8/CINT.md), same shape
                 * as SINT/IINT. The OFFSET-addressed form (CHARACTER
                 * ARRAY INITIAL(v1,v2,...), no HAL-1971-vs-HAL/S
                 * distinction from SINT's own case beyond the element
                 * type) shares SINT's xint_offset_run helper -- see
                 * OP_SINT's comment for the general mechanism. */
                if (ins->operand_count != 2) { fail(state, "CINT: expected 2 operands"); break; }
                if (ins->operands[0].qual == QUAL_OFF && ins->operands[1].qual == QUAL_LIT) {
                    xint_offset_run(state, ins);
                    break;
                }
                if (!resolve_operand(state, &ins->operands[1], &a)) break;
                if (ins->operands[0].qual != QUAL_SYT) { fail(state, "CINT: unsupported destination qualifier"); break; }
                if (a.kind != RV_STRING) { fail(state, "CINT: initializer is not CHARACTER"); break; }
                {
                    halmat_syt_entry_t *e = &state->syt[ins->operands[0].data];
                    free(e->char_value);
                    e->type = SYT_TYPE_CHARACTER;
                    e->char_value = dup_string(a.string);
                }
                break;

            case OP_TINT: {
                /* Structure-terminal initialize (class-8/TINT.md):
                 * whole-structure INITIAL(...) list, one TINT per
                 * *coalesced run* of consecutive terminals (the
                 * compiler's ICQ_OUTPUT coalescing -- confirmed
                 * empirically this session: the literal operand's own
                 * tag1 carries the run length, defaulting to 1 when
                 * absent/zero). Two operands: OFFSET (the run's starting
                 * terminal-slot index, cumulative across the whole STRI
                 * group) and the first coalesced value's literal-table
                 * index. Requires a preceding structure-form STRI (see
                 * OP_STRI) to have resolved the target instance/template;
                 * each terminal's own field symbol is template_syt+1+
                 * offset -- the compiler emits a template's terminal
                 * symbols at consecutive SYT indices immediately
                 * following the template's own (confirmed empirically),
                 * matching FCAL's "callee+1+i" argument convention.
                 * VECTOR terminals (which occupy `cols` consecutive
                 * terminal-slots each, per TINT.md's own worked
                 * multi-terminal trace) are handled via tint_locate_slot's
                 * slot-to-terminal walk, confirmed against real-corpus
                 * 170-OUTER.hal (`1 V VECTOR, 1 S1 SCALAR, 1 C INTEGER,
                 * 1 S2 SCALAR, 1 E BOOLEAN` with `INITIAL(0,1,0, 0,83,0,
                 * OFF)` -- 7 coalesced slots for V's 3 components + 4
                 * scalar terminals in one TINT, previously mis-mapped by
                 * the plain template_syt+1+offset+k formula below since
                 * that assumes one slot advances one terminal, silently
                 * shifting every terminal after V onto the wrong field).
                 * MATRIX/ARRAY terminals aren't handled -- no confirmed
                 * real-corpus trigger yet.
                 *
                 * "Copiness" (`Q-STRUCTURE(n)`, an array of structure
                 * copies): confirmed this session that a coalesced run
                 * can *also* span copies of the same terminal rather than
                 * consecutive terminals of one copy -- e.g. `STRUCTURE Q:
                 * 1 QI INTEGER; DECLARE Z Q-STRUCTURE(3)
                 * INITIAL(1,2,3);` produces a *single* TINT with
                 * OFFSET.DATA=0 (constant) and tag1=3, the same shape as
                 * the single-copy multi-terminal case, but here `k` needs
                 * to advance the *copy* index with the terminal held
                 * fixed, not the reverse. Nothing in the HALMAT stream
                 * itself distinguishes the two shapes; disambiguated here
                 * via the target's own declared copy count
                 * (halmat_symtab_entry_t.struct_copies, symtab.h) --
                 * defaulting to the pre-existing terminal-advancing
                 * behavior (struct_copies <= 1, or no symtab available)
                 * to keep the already-tested single-copy multi-terminal
                 * case unchanged. A run that coalesces *both* several
                 * terminals *and* several copies in one instruction
                 * (which would need advancing both axes at once) is not
                 * handled -- not exercised by any fixture yet, and
                 * TINT.md already flags multi-copy structures as
                 * under-tested in general. */
                if (ins->operand_count != 2) { fail(state, "TINT: expected 2 operands"); break; }
                if (ins->operands[0].qual != QUAL_OFF) { fail(state, "TINT: expected an OFFSET first operand"); break; }
                if (state->stri_target_syt < 0 || state->stri_target_template_syt < 0) {
                    fail(state, "TINT used without a preceding whole-structure STRI");
                    break;
                }
                if (ins->operands[1].qual == QUAL_IMD) {
                    /* NULL initializer for a single NAME-typed structure
                     * terminal (`1 BUFFER NAME ARRAY(10) INTEGER;` field
                     * of `DECLARE FWDSENSORS IOPARM-STRUCTURE INITIAL(16,
                     * HEX'0', NULL, 27);`) -- user-reported,
                     * 167-ASSORTEDIO.hal. NULL has no litfile entry to
                     * coalesce a run against (NASN/NINT's own confirmed
                     * "NULL is QUAL=IMD" encoding, reused here), so this
                     * terminal always gets its own standalone TINT rather
                     * than joining the surrounding numeric/BIT terminals'
                     * coalesced LIT run -- always exactly one terminal,
                     * no run-count concept applies. */
                    uint16_t base_syt = (uint16_t)state->stri_target_syt;
                    uint16_t template_syt = (uint16_t)state->stri_target_template_syt;
                    int32_t copy_idx = current_copy_index(state);
                    uint32_t field_syt32 = (uint32_t)template_syt + 1 + ins->operands[0].data;
                    if (field_syt32 >= HALMAT_SYT_MAX) { fail(state, "TINT: computed field SYT out of range"); break; }
                    halmat_syt_entry_t *field = find_or_create_struct_field(state, base_syt, (uint16_t)field_syt32, copy_idx);
                    field->type = SYT_TYPE_NAME;
                    field->name_target = HALMAT_NAME_NULL;
                    break;
                }
                if (ins->operands[1].qual != QUAL_LIT) { fail(state, "TINT: expected a LIT second operand"); break; }
                uint16_t base_syt = (uint16_t)state->stri_target_syt;
                uint16_t template_syt = (uint16_t)state->stri_target_template_syt;
                int run_count = ins->operands[1].tag1 > 0 ? ins->operands[1].tag1 : 1;
                int32_t copy_idx = current_copy_index(state);
                int struct_copies = 0;
                if (state->symtab) {
                    const halmat_symtab_entry_t *zsym = halmat_symtab_find_by_index(state->symtab, base_syt);
                    if (zsym) struct_copies = zsym->struct_copies;
                }
                bool spans_copies = struct_copies > 1;
                bool ok = true;
                for (int k = 0; ok && k < run_count; k++) {
                    halmat_operand_t lit_op = {0};
                    lit_op.qual = QUAL_LIT;
                    lit_op.data = (uint16_t)(ins->operands[1].data + k);
                    resolved_value_t rv;
                    if (!resolve_operand(state, &lit_op, &rv)) { ok = false; break; }

                    if (spans_copies) {
                        /* Copiness case (TINT.md's "Copiness" section):
                         * one fixed terminal, k advances the copy index
                         * instead -- never seen combined with a VECTOR
                         * terminal, so the plain template_syt+1+offset
                         * formula (no slot-width walk needed) still
                         * applies here unchanged. */
                        uint32_t field_syt32 = (uint32_t)template_syt + 1 + ins->operands[0].data;
                        int32_t this_copy_idx = copy_idx + k;
                        if (field_syt32 >= HALMAT_SYT_MAX) { fail(state, "TINT: computed field SYT out of range"); ok = false; break; }
                        if (state->symtab && rv.kind == RV_SCALAR) {
                            const halmat_symtab_entry_t *fsym = halmat_symtab_find_by_index(state->symtab, field_syt32);
                            if (fsym && fsym->hal_class == 6) { /* INTEGER */
                                int32_t iv = rv_to_integer(&rv);
                                rv.kind = RV_INTEGER;
                                rv.integer = iv;
                            }
                        }
                        halmat_syt_entry_t *field = find_or_create_struct_field(state, base_syt, (uint16_t)field_syt32, this_copy_idx);
                        if (!write_syt_entry(state, HALMAT_SYT_MAX, field, &rv)) { ok = false; break; }
                        continue;
                    }

                    uint16_t field_syt16;
                    int elem_idx, width;
                    if (!tint_locate_slot(state, template_syt, (int)ins->operands[0].data + k, &field_syt16, &elem_idx, &width)) {
                        fail(state, "TINT: OFFSET slot does not map to a structure terminal");
                        ok = false;
                        break;
                    }
                    halmat_syt_entry_t *field = find_or_create_struct_field(state, base_syt, field_syt16, copy_idx);
                    if (width > 1) {
                        /* VECTOR terminal: allocate this shadow slot's own
                         * elements[] the first time it's touched (same
                         * ensure_container()-style convention the READ-side
                         * whole-structure destination uses, task #62) --
                         * literal-table FIXED/DOUBLE entries always resolve
                         * RV_SCALAR (TINT.md), and VECTOR components are
                         * never anything else. */
                        if (!field->elements) {
                            field->elements = calloc((size_t)width, sizeof(halmat_scalar_t));
                            field->element_count = (size_t)width;
                            field->cols = width;
                            field->rows = 0;
                        }
                        field->elements[elem_idx] = rv.scalar;
                        continue;
                    }
                    /* Litfile numeric entries carry no INTEGER-vs-SCALAR
                     * distinction of their own (resolve_operand's QUAL_LIT
                     * case always resolves FIXED/DOUBLE as RV_SCALAR) --
                     * unlike SINT/IINT (whose own opcode identity already
                     * says which), TINT is shared across every terminal
                     * type, so the declared type has to come from the
                     * symbol table instead, per-terminal. */
                    if (state->symtab && rv.kind == RV_SCALAR) {
                        const halmat_symtab_entry_t *fsym = halmat_symtab_find_by_index(state->symtab, field_syt16);
                        if (fsym && fsym->hal_class == 6) { /* INTEGER */
                            int32_t iv = rv_to_integer(&rv);
                            rv.kind = RV_INTEGER;
                            rv.integer = iv;
                        }
                    }
                    if (!write_syt_entry(state, HALMAT_SYT_MAX, field, &rv)) { ok = false; break; }
                }
                if (!ok) break;
                break;
            }

            case OP_BINT:
                /* Direct symbol-table form (class-8/BINT.md), same shape
                 * as SINT/IINT/CINT. The OFFSET-addressed form (BIT
                 * ARRAY INITIAL(v1,v2,...)) shares SINT's
                 * xint_offset_run helper -- see OP_SINT's comment for
                 * the general mechanism. */
                if (ins->operand_count != 2) { fail(state, "BINT: expected 2 operands"); break; }
                if (ins->operands[0].qual == QUAL_OFF && ins->operands[1].qual == QUAL_LIT) {
                    xint_offset_run(state, ins);
                    break;
                }
                if (!resolve_operand(state, &ins->operands[1], &a)) break;
                if (ins->operands[0].qual != QUAL_SYT) { fail(state, "BINT: unsupported destination qualifier"); break; }
                if (a.kind != RV_BITS) { fail(state, "BINT: initializer is not BIT"); break; }
                state->syt[ins->operands[0].data].type = SYT_TYPE_BIT;
                state->syt[ins->operands[0].data].bit_value = a.bits;
                break;

            case OP_NINT:
                /* NAME (pointer) initialize, class-8/NINT.md: operand 1
                 * = the NAME variable, operand 2 = SYT target (real
                 * pointer) or IMD (NULL) -- same raw-index handling as
                 * NASN, bypassing resolve_operand.
                 *
                 * Investigated this session (task sweep item): NINT.md's
                 * own confirmed operand-word trace only ever shows
                 * QUAL_SYT for operand 1 (both the real-pointer and NULL
                 * cases); an OFFSET form was never observed, only
                 * speculatively guarded against (mirroring SINT/BINT/
                 * CINT's genuinely-confirmed OFFSET form for ARRAY
                 * INITIAL lists). Tried to construct the analogous
                 * trigger -- an ARRAY of NAME with an INITIAL list -- via
                 * direct HALSFC compile probes; hit a real, unrelated
                 * compiler-level obstacle ("ARRAYNESS/MULTI-COPINESS
                 * CONFLICT", PASS2 DI110) before ever producing a HALMAT
                 * trace to confirm or refute the OFFSET hypothesis
                 * either way. Left failing loudly -- still no primary-
                 * source or empirical basis to implement against. */
                if (ins->operand_count != 2) { fail(state, "NINT: expected 2 operands"); break; }
                if (ins->operands[0].qual != QUAL_SYT) { fail(state, "NINT: OFFSET-addressed form not yet implemented"); break; }
                {
                    uint16_t target = (ins->operands[1].qual == QUAL_SYT) ? ins->operands[1].data : HALMAT_NAME_NULL;
                    state->syt[ins->operands[0].data].type = SYT_TYPE_NAME;
                    state->syt[ins->operands[0].data].name_target = target;
                }
                break;

            case OP_MINT:
            case OP_VINT:
                /* Uniform fill: every element of the MATRIX/VECTOR gets
                 * the same literal value (class-8/MINT.md/VINT.md);
                 * per-element INITIAL() lists instead use repeated SINT,
                 * already handled by SINT's own direct-SYT case.
                 *
                 * Investigated this session (task sweep item): MINT.md/
                 * VINT.md's own "OFFSET" mention is carried over from the
                 * HAL-1971 predecessor-language instruction only ("HAL/S
                 * operand-word format is unconfirmed" -- their own
                 * Unresolved Questions); no real HALSFC trace has ever
                 * shown it. Tried both realistic real-HAL/S triggers this
                 * session: `ARRAY(n) VECTOR(m) INITIAL(uniform-value)`
                 * compiles to plain-SYT VINT wrapped in IDLP/DLPE replay
                 * (already handled, no OFFSET involved); `ARRAY(n)
                 * VECTOR(m) INITIAL(v1,v2,...,distinct-per-element)`
                 * compiles to STRI + repeated SINT with OFFSET addressing
                 * across the whole flattened element run (already handled
                 * by SINT's own case) -- MINT/VINT itself never appears
                 * with anything but QUAL_SYT in either case. Left failing
                 * loudly -- no confirmed trigger exists to implement
                 * against. */
                if (ins->operand_count != 2) { fail(state, "MINT/VINT: expected 2 operands"); break; }
                if (!resolve_operand(state, &ins->operands[1], &a)) break;
                if (ins->operands[0].qual != QUAL_SYT) { fail(state, "MINT/VINT: OFFSET-addressed form not yet implemented"); break; }
                {
                    uint16_t dest_syt = ins->operands[0].data;
                    if (dest_syt >= HALMAT_SYT_MAX) { fail(state, "MINT/VINT: SYT index out of range"); break; }
                    ensure_container(state, dest_syt);
                    halmat_syt_entry_t *e = &state->syt[dest_syt];
                    halmat_scalar_t fill = rv_to_scalar(&a);
                    for (size_t i = 0; i < e->element_count; i++) e->elements[i] = fill;
                }
                break;

            case OP_IADD:
            case OP_ISUB:
                if (ins->operand_count != 2) { fail(state, "IADD/ISUB: expected 2 operands"); break; }
                if (!resolve_operand(state, &ins->operands[0], &a)) break;
                if (!resolve_operand(state, &ins->operands[1], &b)) break;
                if (ins->index >= HALMAT_VAC_MAX) { fail(state, "VAC index out of range"); break; }
                state->vac[ins->index].is_ref = false;
                state->vac[ins->index].is_scalar = false;
                state->vac[ins->index].integer = (ins->opcode == OP_IADD)
                    ? (rv_to_integer(&a) + rv_to_integer(&b))
                    : (rv_to_integer(&a) - rv_to_integer(&b));
                break;

            case OP_IIPR:
                if (ins->operand_count != 2) { fail(state, "IIPR: expected 2 operands"); break; }
                if (!resolve_operand(state, &ins->operands[0], &a)) break;
                if (!resolve_operand(state, &ins->operands[1], &b)) break;
                if (ins->index >= HALMAT_VAC_MAX) { fail(state, "VAC index out of range"); break; }
                state->vac[ins->index].is_ref = false;
                state->vac[ins->index].is_scalar = false;
                state->vac[ins->index].integer = rv_to_integer(&a) * rv_to_integer(&b);
                break;

            case OP_INEG:
                if (ins->operand_count != 1) { fail(state, "INEG: expected 1 operand"); break; }
                if (!resolve_operand(state, &ins->operands[0], &a)) break;
                if (ins->index >= HALMAT_VAC_MAX) { fail(state, "VAC index out of range"); break; }
                state->vac[ins->index].is_ref = false;
                state->vac[ins->index].is_scalar = false;
                state->vac[ins->index].integer = -rv_to_integer(&a);
                break;

            case OP_IPEX: {
                /* Positive-literal-exponent integer power (class-6/IPEX.md):
                 * repeated multiplication, exponent >= 0 (non-negative
                 * literal, confirmed compile-time-known). Negative/non-
                 * literal exponents never reach this opcode -- HAL/S
                 * coerces those to SCALAR (ITOS+SIEX/SEXP) at compile
                 * time instead, per IPEX.md's Usage Context. */
                if (ins->operand_count != 2) { fail(state, "IPEX: expected 2 operands"); break; }
                if (!resolve_operand(state, &ins->operands[0], &a)) break;
                if (!resolve_operand(state, &ins->operands[1], &b)) break;
                if (ins->index >= HALMAT_VAC_MAX) { fail(state, "VAC index out of range"); break; }
                int32_t base = rv_to_integer(&a);
                int32_t exponent = rv_to_integer(&b);
                if (exponent < 0) { fail(state, "IPEX: negative exponent (expected non-negative literal)"); break; }
                /* USA003090 App. C error 4: 0**0 is a documented runtime
                 * fixup of zero, not the ordinary 0**0=1 convention the
                 * loop below would otherwise produce -- unless a GOTO
                 * handler is registered for it. */
                bool zero_to_zero = (base == 0 && exponent == 0);
                if (zero_to_zero && !arithmetic_error_should_apply_fixup(state, HAL_S_ERROR_ZERO_TO_NONPOSITIVE_POWER, &state->pc, &branched)) break;
                int32_t result = zero_to_zero ? 0 : 1;
                for (int32_t i = 0; i < exponent; i++) result *= base;
                state->vac[ins->index].is_ref = false;
                state->vac[ins->index].is_scalar = false;
                state->vac[ins->index].integer = result;
                break;
            }

            case OP_SADD:
            case OP_SSUB:
                /* Genuine IBM hex-float arithmetic (value.c's
                 * halmat_scalar_add/sub), not a native-double
                 * approximation -- see value.h's documented caveats
                 * (no guard digits, characteristic overflow clamps
                 * rather than raising the real ERROR CONDITION). */
                if (ins->operand_count != 2) { fail(state, "SADD/SSUB: expected 2 operands"); break; }
                if (!resolve_operand(state, &ins->operands[0], &a)) break;
                if (!resolve_operand(state, &ins->operands[1], &b)) break;
                if (ins->index >= HALMAT_VAC_MAX) { fail(state, "VAC index out of range"); break; }
                state->vac[ins->index].is_ref = false;
                state->vac[ins->index].is_scalar = true;
                state->vac[ins->index].scalar = (ins->opcode == OP_SADD)
                    ? halmat_scalar_add(rv_to_scalar(&a), rv_to_scalar(&b))
                    : halmat_scalar_sub(rv_to_scalar(&a), rv_to_scalar(&b));
                break;

            case OP_SSPR:
                if (ins->operand_count != 2) { fail(state, "SSPR: expected 2 operands"); break; }
                if (!resolve_operand(state, &ins->operands[0], &a)) break;
                if (!resolve_operand(state, &ins->operands[1], &b)) break;
                if (ins->index >= HALMAT_VAC_MAX) { fail(state, "VAC index out of range"); break; }
                state->vac[ins->index].is_ref = false;
                state->vac[ins->index].is_scalar = true;
                state->vac[ins->index].scalar = halmat_scalar_multiply(rv_to_scalar(&a), rv_to_scalar(&b));
                break;

            case OP_SSDV: {
                if (ins->operand_count != 2) { fail(state, "SSDV: expected 2 operands"); break; }
                if (!resolve_operand(state, &ins->operands[0], &a)) break;
                if (!resolve_operand(state, &ins->operands[1], &b)) break;
                if (ins->index >= HALMAT_VAC_MAX) { fail(state, "VAC index out of range"); break; }
                halmat_scalar_t quotient;
                if (!halmat_scalar_divide(rv_to_scalar(&a), rv_to_scalar(&b), &quotient)) {
                    fail(state, "division by zero (floating point divide exception)");
                    break;
                }
                state->vac[ins->index].is_ref = false;
                state->vac[ins->index].is_scalar = true;
                state->vac[ins->index].scalar = quotient;
                break;
            }

            case OP_SPEX:
            case OP_SIEX: {
                /* SPEX (positive-literal exponent, class-5/SPEX.md) and
                 * SIEX (any-sign integer exponent, class-5/SIEX.md): both
                 * inline repeated multiplication on the base; SIEX
                 * additionally takes the reciprocal for a negative
                 * exponent (1/base^|n|) since HAL/S has no separate
                 * negative-exponent opcode. */
                if (ins->operand_count != 2) { fail(state, "SPEX/SIEX: expected 2 operands"); break; }
                if (!resolve_operand(state, &ins->operands[0], &a)) break;
                if (!resolve_operand(state, &ins->operands[1], &b)) break;
                if (ins->index >= HALMAT_VAC_MAX) { fail(state, "VAC index out of range"); break; }
                halmat_scalar_t base = rv_to_scalar(&a);
                int32_t exponent = rv_to_integer(&b);
                bool dbl = base.double_precision;
                if (ins->opcode == OP_SPEX && exponent < 0) {
                    fail(state, "SPEX: negative exponent (expected a positive literal)");
                    break;
                }
                halmat_scalar_t result;
                if (halmat_scalar_to_double(base) == 0.0 && exponent <= 0) {
                    /* USA003090 App. C error 4 ("exponentiation of zero to
                     * a power <= 0"): standard fixup is zero -- not the
                     * ordinary 0**0=1 convention the loop below would
                     * otherwise produce for SPEX/an exponent==0 SIEX, nor
                     * SIEX's own reciprocal-of-zero division for a
                     * negative exponent -- unless a GOTO handler is
                     * registered for it. */
                    if (!arithmetic_error_should_apply_fixup(state, HAL_S_ERROR_ZERO_TO_NONPOSITIVE_POWER, &state->pc, &branched)) break;
                    result = halmat_scalar_zero(dbl);
                } else {
                    result = halmat_scalar_from_integer(1, dbl);
                    uint32_t magnitude = (exponent < 0) ? (uint32_t)(-(int64_t)exponent) : (uint32_t)exponent;
                    for (uint32_t i = 0; i < magnitude; i++) result = halmat_scalar_multiply(result, base);
                    if (exponent < 0) {
                        halmat_scalar_t reciprocal;
                        if (!halmat_scalar_divide(halmat_scalar_from_integer(1, dbl), result, &reciprocal)) {
                            fail(state, "SIEX: division by zero (0 raised to a negative exponent)");
                            break;
                        }
                        result = reciprocal;
                    }
                }
                state->vac[ins->index].is_ref = false;
                state->vac[ins->index].is_scalar = true;
                state->vac[ins->index].scalar = result;
                break;
            }

            case OP_SEXP: {
                /* Scalar-exponent-by-scalar (class-5/SEXP.md), the fully
                 * general case (e.g. fractional exponents). No documented
                 * hex-float power algorithm exists in the extracted
                 * AP-101S material (unlike SADD/SSPR/SSDV's primary-
                 * sourced characteristic/fraction algorithms) -- goes
                 * through double via pow(), a documented precision
                 * compromise for this one opcode rather than the genuine
                 * hex-float arithmetic used everywhere else in this
                 * interpreter. */
                if (ins->operand_count != 2) { fail(state, "SEXP: expected 2 operands"); break; }
                if (!resolve_operand(state, &ins->operands[0], &a)) break;
                if (!resolve_operand(state, &ins->operands[1], &b)) break;
                if (ins->index >= HALMAT_VAC_MAX) { fail(state, "VAC index out of range"); break; }
                halmat_scalar_t base = rv_to_scalar(&a);
                double base_d = halmat_scalar_to_double(base);
                double exponent_d = halmat_scalar_to_double(rv_to_scalar(&b));
                double result;
                if (base_d == 0.0 && exponent_d <= 0.0) {
                    /* USA003090 App. C error 4 ("exponentiation of zero to
                     * a power <= 0"): standard fixup is zero -- pow(0,0)=1
                     * and pow(0,negative)=+Inf per C99 would otherwise
                     * either give the wrong value or (worse, for a
                     * negative exponent) feed +Inf into
                     * halmat_scalar_from_double, whose normalization loop
                     * never terminates for a non-finite input. */
                    if (!arithmetic_error_should_apply_fixup(state, HAL_S_ERROR_ZERO_TO_NONPOSITIVE_POWER, &state->pc, &branched)) break;
                    result = 0.0;
                } else if (base_d < 0.0) {
                    /* USA003090 App. C error 24 ("negative base in
                     * exponentiation"): standard fixup is |A|**B --
                     * pow()'s underlying log/exp implementation is
                     * undefined (NaN) for a negative base with any
                     * non-integer exponent, and this rule applies
                     * unconditionally (integer exponents too) per the
                     * primary source, not just the domain-error cases. */
                    if (!arithmetic_error_should_apply_fixup(state, HAL_S_ERROR_NEGATIVE_BASE_EXPONENT, &state->pc, &branched)) break;
                    result = pow(fabs(base_d), exponent_d);
                } else {
                    result = pow(base_d, exponent_d);
                }
                state->vac[ins->index].is_ref = false;
                state->vac[ins->index].is_scalar = true;
                state->vac[ins->index].scalar = halmat_scalar_from_double(result, base.double_precision);
                break;
            }

            case OP_SNEG:
                if (ins->operand_count != 1) { fail(state, "SNEG: expected 1 operand"); break; }
                if (!resolve_operand(state, &ins->operands[0], &a)) break;
                if (ins->index >= HALMAT_VAC_MAX) { fail(state, "VAC index out of range"); break; }
                state->vac[ins->index].is_ref = false;
                state->vac[ins->index].is_scalar = true;
                state->vac[ins->index].scalar = halmat_scalar_negate(rv_to_scalar(&a));
                break;

            case OP_ITOS:
                /* Integer->scalar, per class-5/ITOS.md's USA00309 Sec.
                 * 8.2 rule 9. The rule's "double-precision intermediate,
                 * narrowed afterward if needed" framing describes the
                 * conversion *algorithm* (exact for any INTEGER value
                 * either way -- INTEGER's full range fits losslessly in
                 * a single-precision 6-hex-digit fraction too, since
                 * HAL/S INTEGER is at most 32 bits ~ 8 hex digits...
                 * actually not always lossless at single precision, but
                 * empirically ITOS's own HALMAT-level result is single
                 * -- see below), not the static HALMAT-level type ITOS
                 * itself produces: cross-checked against the reference
                 * yaHALMAT emulator on `S2 = I1 + S1;` (S1/S2 single-
                 * precision SCALAR), which prints single-precision
                 * (7 fractional digits), not double -- ITOS carries no
                 * precision tag of its own in the compiled HALMAT (no
                 * operand/TAG distinguishes it), so single is the only
                 * representation consistent with that observation. */
                if (ins->operand_count != 1) { fail(state, "ITOS: expected 1 operand"); break; }
                if (!resolve_operand(state, &ins->operands[0], &a)) break;
                if (ins->index >= HALMAT_VAC_MAX) { fail(state, "VAC index out of range"); break; }
                state->vac[ins->index].is_ref = false;
                state->vac[ins->index].is_scalar = true;
                state->vac[ins->index].scalar = halmat_scalar_from_integer(rv_to_integer(&a), false);
                break;

            case OP_STOS:
                /* Scalar precision scale (class-5/STOS.md), triggered by
                 * the explicit exp$(@SINGLE)/exp$(@DOUBLE) qualifier
                 * (not plain assignment, which widens/narrows via the
                 * object code directly with no HALMAT-level opcode of
                 * its own). One operand (source SCALAR SYT); the
                 * instruction's own TAG carries the target precision --
                 * confirmed 2=DOUBLE_FLAG, 1=SINGLE_FLAG. */
                if (ins->operand_count != 1) { fail(state, "STOS: expected 1 operand"); break; }
                if (!resolve_operand(state, &ins->operands[0], &a)) break;
                if (ins->index >= HALMAT_VAC_MAX) { fail(state, "VAC index out of range"); break; }
                state->vac[ins->index].is_ref = false;
                state->vac[ins->index].is_scalar = true;
                state->vac[ins->index].scalar = scale_precision(rv_to_scalar(&a), ins->tag == 2);
                break;

            case OP_STOI:
                /* Scalar->integer, per class-6/STOI.md's USA00309 Sec.
                 * 8.2 rule 10: rounds to nearest, but exact-.5 ties round
                 * TOWARD zero (halmat_scalar_to_integer's documented
                 * behavior, value.c -- confirmed against real gpc output
                 * for the runtime library's actual ETOH.asm, a 24-point
                 * probe across magnitudes/signs; NOT the "ties away from
                 * zero"/reference-emulator-derived rule this comment used
                 * to claim). USA003090 App. C error 15 ("SCALAR too large
                 * for INTEGER conversion"): out-of-range clamps to
                 * 32767/-32767 (halmat_scalar_to_integer's own documented
                 * fixup, value.c -- confirmed via the real CVFX-overflow
                 * CPU interrupt handler, FPMSDERR.asm's FPMCVFX, not the
                 * manual's simplified -32768). The range check here is
                 * deliberately duplicated (not read back out of
                 * halmat_scalar_to_integer, a generic coercion used by
                 * many unrelated call sites too, e.g. array subscripts,
                 * that aren't the HAL/S-level STOI conversion this error
                 * is specifically about) so only *this* opcode consults
                 * the ON ERROR table for it -- so it must apply the exact
                 * same rounding rule and boundary as that function, or
                 * this detects the error at the wrong threshold even
                 * though the fixup value itself (computed via the shared
                 * rv_to_integer/halmat_scalar_to_integer path below,
                 * regardless of whether this check fires) would still
                 * come out right. */
                if (ins->operand_count != 1) { fail(state, "STOI: expected 1 operand"); break; }
                if (!resolve_operand(state, &ins->operands[0], &a)) break;
                if (ins->index >= HALMAT_VAC_MAX) { fail(state, "VAC index out of range"); break; }
                if (a.kind == RV_SCALAR) {
                    double raw = halmat_scalar_to_double(a.scalar);
                    double d = trunc(raw);
                    double frac = raw - d;
                    if (fabs(frac) > 0.5) d += (raw >= 0.0) ? 1.0 : -1.0;
                    if (d > 32767.0 || d < -32768.0) {
                        if (!arithmetic_error_should_apply_fixup(state, HAL_S_ERROR_SCALAR_TO_INTEGER_OVERFLOW, &state->pc, &branched)) break;
                    }
                }
                state->vac[ins->index].is_ref = false;
                state->vac[ins->index].is_scalar = false;
                state->vac[ins->index].integer = rv_to_integer(&a);
                break;

            case OP_IASN:
            case OP_SASN: {
                /* Resolve the source, then coerce it to the kind the
                 * opcode's own class asserts (IASN=INTEGER, SASN=SCALAR)
                 * *before* write_destination() sees it. This matters
                 * because a LIT-qualified source carries no INTEGER-vs-
                 * SCALAR distinction of its own (litfile numeric entries
                 * always resolve as RV_SCALAR -- see resolve_operand),
                 * so on a destination's *first* write (still
                 * SYT_TYPE_UNKNOWN) write_destination's type inference
                 * needs the opcode's own class as the ground truth, not
                 * the source operand's generic resolved kind. This still
                 * lets write_destination correctly write an
                 * IASN-sourced INTEGER value into an already-SCALAR
                 * destination (e.g. out_array's ARR=I into a SCALAR
                 * array element) via its own coercion -- only the
                 * *kind tag* changes here, not any value.
                 *
                 * EXCEPT: class-6/IASN.md's own Unresolved-Questions note
                 * documents that PASS1 emits IASN -- not SASN -- for a
                 * genuinely SCALAR receiver whenever the literal being
                 * assigned happens to be whole-valued (`S1 = 4;`, even
                 * `S1 = 1.0;`), even though "the generated machine code
                 * still stores the value as a float"; that quirk was
                 * previously only noted, never corrected here, so a plain
                 * (QUAL_SYT) SCALAR destination silently got mistyped
                 * SYT_TYPE_INTEGER (write_syt_entry's first-write
                 * inference trusts `a.kind`) on exactly this input shape
                 * -- discarding its SCALAR-ness (and, for a DOUBLE
                 * receiver, its precision) for the rest of the program.
                 * User-reported (GOOGLE-PARALLAX.hal's SCALAR DOUBLE
                 * `DISTANCE` printing with single-precision formatting,
                 * traced back to `EOR = 93000000.0;`, a whole-valued
                 * literal into SCALAR DOUBLE `EOR`, silently losing its
                 * SCALAR/DOUBLE-ness this same way and poisoning every
                 * computation downstream). The symbol table's own
                 * declared class -- already the established source of
                 * truth for this exact ambiguity elsewhere (TINT's
                 * identical per-field correction, OP_TINT above; call-
                 * argument precision, bind_call_argument's `psym` check)
                 * -- overrides the opcode's nominal class here too when
                 * the destination is a plain symbol. This same symtab
                 * lookup also normalizes a SCALAR destination's precision
                 * to its own declared SINGLE/DOUBLE (scale_precision(),
                 * USA00309 Sec. 8.2 rules 7/12) on *every* write, not
                 * just the first -- neither a literal (always single-
                 * precision-encoded in litfile, literal.c) nor an
                 * expression result is otherwise tagged to the
                 * *receiver's* declared precision anywhere upstream, so
                 * without this a SCALAR DOUBLE variable assigned a plain
                 * literal (`ANGULAR_SHIFT = 0.5;`) stayed single-
                 * precision-formatted even via ordinary SASN. */
                /* Multiple assignment ([USA003087] Sec. 8.5, user-reported
                 * against 104-EXAMPLE_1.hal's `TMAX, TMEAN, TMIN = TIME(1);`):
                 * "several data items may be assigned to the same
                 * R-expression in the same statement... [t]he value of the
                 * R-expression is assigned to all L1...Ln in turn... [n]o
                 * particular order of assignment is guaranteed. Any L-type
                 * must be compatible with the R-type" (rule 2 -- each
                 * receiver's *own* declared type governs its own coercion,
                 * independently of every other receiver's). Confirmed
                 * empirically that multi-assignment compiles to one IASN or
                 * SASN instruction (whichever the compiler happens to pick
                 * for the group -- confirmed NOT always tied to any one
                 * receiver's own type, see below) with the source as
                 * operand 0 and every receiver as its own trailing operand
                 * (operand_count = 1 + N receivers, not always 2) --
                 * previously unhandled, failing loudly on any N != 1.
                 *
                 * Sec. 8.5's own worked example, directly compiled and
                 * cross-checked: `C, I = 127.2;` (`C` CHARACTER, `I`
                 * INTEGER) -- despite mixing two receiver types neither of
                 * which is SCALAR -- compiles to a *single* SASN carrying
                 * both `C` and `I` as operands (confirmed via --disasm: one
                 * SASN, numop=3, LIT source + both receiver SYTs). So the
                 * opcode chosen for the whole group is not a reliable guide
                 * to any individual receiver's own real type at all here --
                 * unlike the single-receiver case above (where the
                 * *destination's* declared class already overrides the
                 * opcode's nominal one when available, this just extends
                 * that same "symtab is ground truth over opcode class" rule
                 * to every receiver type this project has a confirmed
                 * conversion for, not just SCALAR: CHARACTER (hal_class=2,
                 * via the same fixed-width scientific-notation rendering
                 * OP_STOC uses -- confirmed to match Sec. 8.5's own stated
                 * result, `C` = `'1.2720000E+02'`) and INTEGER (hal_class=6,
                 * truncating rv_to_integer()). A receiver whose class isn't
                 * one of these three (or with no symtab available at all)
                 * falls back to the opcode's own nominal class, same as the
                 * pre-existing single-receiver behavior. Source is resolved
                 * once, then each receiver gets its own independent
                 * coercion pass on a fresh copy (the coercion below mutates
                 * it), since a later receiver must never see an earlier
                 * receiver's own coerced kind. */
                if (ins->operand_count < 2) { fail(state, "IASN/SASN: expected at least 2 operands"); break; }
                if (!resolve_operand(state, &ins->operands[0], &a)) break;
                for (uint8_t ri = 1; ri < ins->operand_count; ri++) {
                    resolved_value_t coerced = a;
                    const halmat_symtab_entry_t *dest_sym = (ins->operands[ri].qual == QUAL_SYT && state->symtab)
                        ? halmat_symtab_find_by_index(state->symtab, ins->operands[ri].data) : NULL;
                    int dest_class = dest_sym ? dest_sym->hal_class : -1;
                    if (dest_class == 5) {
                        halmat_scalar_t sv = rv_to_scalar(&coerced);
                        if (dest_sym->flags & (HALMAT_SYM_FLAG_SINGLE | HALMAT_SYM_FLAG_DOUBLE)) {
                            bool want_double = (dest_sym->flags & HALMAT_SYM_FLAG_DOUBLE) != 0;
                            if (sv.double_precision != want_double) sv = scale_precision(sv, want_double);
                        }
                        coerced.kind = RV_SCALAR;
                        coerced.scalar = sv;
                    } else if (dest_class == 2) {
                        char buf[32];
                        halmat_scalar_format(rv_to_scalar(&coerced), buf, sizeof(buf));
                        coerced.kind = RV_STRING;
                        coerced.string = buf; /* write_destination copies out (write_syt_entry's dup_string) before this scope ends */
                        if (!write_destination(state, &ins->operands[ri], &coerced)) break;
                        continue;
                    } else if (dest_class == 6) {
                        int32_t iv = rv_to_integer(&coerced);
                        coerced.kind = RV_INTEGER;
                        coerced.integer = iv;
                    } else if (ins->opcode == OP_IASN) {
                        int32_t iv = rv_to_integer(&coerced);
                        coerced.kind = RV_INTEGER;
                        coerced.integer = iv;
                    } else {
                        halmat_scalar_t sv = rv_to_scalar(&coerced);
                        coerced.kind = RV_SCALAR;
                        coerced.scalar = sv;
                    }
                    if (!write_destination(state, &ins->operands[ri], &coerced)) break;
                }
                break;
            }

            case OP_BASN:
                /* Bit-string assign, source-first/receiver-second like
                 * the rest of the xASN family (class-1/BASN.md). */
                if (ins->operand_count != 2) { fail(state, "BASN: expected 2 operands"); break; }
                if (!resolve_operand(state, &ins->operands[0], &a)) break;
                if (a.kind != RV_BITS) { fail(state, "BASN: source is not BIT"); break; }
                if (!write_destination(state, &ins->operands[1], &a)) break;
                break;

            case OP_BCAT:
                /* Bit-string catenate (class-1/BCAT.md): B1 || B2, B1
                 * occupying the more-significant bits. Neither operand
                 * carries its own width (confirmed empirically: both are
                 * plain SYT references, tag1=0) -- the declared BIT(n)
                 * width is the only source of truth for how far to shift
                 * B1 left, so this requires a symtab (state->symtab) and
                 * both operands to be QUAL_SYT; any other shape fails
                 * loudly rather than guessing a width. */
                if (ins->operand_count != 2) { fail(state, "BCAT: expected 2 operands"); break; }
                if (ins->operands[0].qual != QUAL_SYT || ins->operands[1].qual != QUAL_SYT) {
                    fail(state, "BCAT: only plain SYT operands are implemented (need declared BIT width)");
                    break;
                }
                if (!state->symtab) { fail(state, "BCAT: needs a symbol table (auto-discovered COMMON*.out) for declared BIT widths"); break; }
                {
                    const halmat_symtab_entry_t *sym2 = halmat_symtab_find_by_index(state->symtab, ins->operands[1].data);
                    if (!sym2 || sym2->bit_width <= 0) { fail(state, "BCAT: second operand's declared BIT width is unknown"); break; }
                    if (!resolve_operand(state, &ins->operands[0], &a)) break;
                    if (!resolve_operand(state, &ins->operands[1], &b)) break;
                    if (a.kind != RV_BITS || b.kind != RV_BITS) { fail(state, "BCAT: both operands must be BIT"); break; }
                    if (ins->index >= HALMAT_VAC_MAX) { fail(state, "VAC index out of range"); break; }
                    uint32_t mask2 = (sym2->bit_width >= 32) ? 0xFFFFFFFFu : ((1u << sym2->bit_width) - 1u);
                    state->vac[ins->index].is_ref = false;
                    state->vac[ins->index].is_bits = true;
                    state->vac[ins->index].bits = (a.bits << sym2->bit_width) | (b.bits & mask2);
                }
                break;

            case OP_BAND:
            case OP_BOR:
                /* class-1/BAND.md/BOR.md: full 32-bit pattern AND/OR, no
                 * declared-width masking (unconfirmed truncation rule,
                 * see state.h). */
                if (ins->operand_count != 2) { fail(state, "BAND/BOR: expected 2 operands"); break; }
                if (!resolve_operand(state, &ins->operands[0], &a)) break;
                if (!resolve_operand(state, &ins->operands[1], &b)) break;
                if (a.kind != RV_BITS || b.kind != RV_BITS) { fail(state, "BAND/BOR: both operands must be BIT"); break; }
                if (ins->index >= HALMAT_VAC_MAX) { fail(state, "VAC index out of range"); break; }
                state->vac[ins->index].is_ref = false;
                state->vac[ins->index].is_bits = true;
                state->vac[ins->index].bits = (ins->opcode == OP_BAND) ? (a.bits & b.bits) : (a.bits | b.bits);
                break;

            case OP_BNOT: {
                if (ins->operand_count != 1) { fail(state, "BNOT: expected 1 operand"); break; }
                if (!resolve_operand(state, &ins->operands[0], &a)) break;
                if (a.kind != RV_BITS) { fail(state, "BNOT: operand is not BIT"); break; }
                if (ins->index >= HALMAT_VAC_MAX) { fail(state, "VAC index out of range"); break; }
                /* Real compiled code masks NOT to the operand's own
                 * declared BIT(n) width (`XHI R7,255` for a BIT(8)
                 * operand) rather than complementing the full 32-bit
                 * pattern -- confirmed against test_bit.hal's `I3 =
                 * INTEGER(NOT B1);` (B1 declared BIT(8)): real gpc output
                 * is 243 (0xF3, the 8-bit-masked complement reinterpreted
                 * as a non-negative INTEGER), not a full-32-bit
                 * complement's -13. Same declared-width lookup convention
                 * as the WRITE-argument BIT case below and BCAT's own
                 * established technique; unlike BAND/BOR just above (whose
                 * own comment already flags this as unconfirmed and whose
                 * existing test coverage never exercises a case that would
                 * distinguish the two), this one has direct, real-hardware
                 * evidence. */
                int width = 32;
                if (ins->operands[0].qual == QUAL_SYT && state->symtab) {
                    const halmat_symtab_entry_t *sym = halmat_symtab_find_by_index(state->symtab, ins->operands[0].data);
                    if (sym && sym->bit_width > 0) width = sym->bit_width;
                } else if (ins->operands[0].qual == QUAL_VAC && ins->operands[0].data < HALMAT_VAC_MAX) {
                    int vac_width = state->vac[ins->operands[0].data].bit_width;
                    if (vac_width > 0) width = vac_width;
                } else if (ins->operands[0].qual == QUAL_LIT && state->literals &&
                           ins->operands[0].data < state->literals->count) {
                    const halmat_literal_t *lit = &state->literals->entries[ins->operands[0].data];
                    if (lit->type == LIT_BIT && lit->bit_width > 0) width = lit->bit_width;
                }
                uint32_t mask = (width >= 32) ? 0xFFFFFFFFu : ((1u << width) - 1u);
                state->vac[ins->index].is_ref = false;
                state->vac[ins->index].is_bits = true;
                state->vac[ins->index].bits = (~a.bits) & mask;
                state->vac[ins->index].bit_width = width;
                break;
            }

            case OP_ITOB:
                /* Integer->bit, class-1/ITOB.md: raw bit pattern of the
                 * integer value (inline shift/store per real object code
                 * -- here just a reinterpretation of the same 32 bits). */
                if (ins->operand_count != 1) { fail(state, "ITOB: expected 1 operand"); break; }
                if (!resolve_operand(state, &ins->operands[0], &a)) break;
                if (ins->index >= HALMAT_VAC_MAX) { fail(state, "VAC index out of range"); break; }
                state->vac[ins->index].is_ref = false;
                state->vac[ins->index].is_bits = true;
                state->vac[ins->index].bits = (uint32_t)rv_to_integer(&a);
                break;

            case OP_BTOI:
                if (ins->operand_count != 1) { fail(state, "BTOI: expected 1 operand"); break; }
                if (!resolve_operand(state, &ins->operands[0], &a)) break;
                if (a.kind != RV_BITS) { fail(state, "BTOI: operand is not BIT"); break; }
                if (ins->index >= HALMAT_VAC_MAX) { fail(state, "VAC index out of range"); break; }
                state->vac[ins->index].is_ref = false;
                state->vac[ins->index].is_scalar = false;
                state->vac[ins->index].integer = (int32_t)a.bits;
                break;

            case OP_BTOS:
                /* Bit->scalar, class-5/BTOS.md: the raw bit pattern
                 * reinterpreted as an unsigned integer value (matching
                 * the reference emulator's own `(double)a.v.bits` -- no
                 * primary-source operand format exists to check this
                 * against independently, but it's the only reading
                 * consistent with BTOI's parallel "raw pattern as
                 * integer" conversion). */
                if (ins->operand_count != 1) { fail(state, "BTOS: expected 1 operand"); break; }
                if (!resolve_operand(state, &ins->operands[0], &a)) break;
                if (a.kind != RV_BITS) { fail(state, "BTOS: operand is not BIT"); break; }
                if (ins->index >= HALMAT_VAC_MAX) { fail(state, "VAC index out of range"); break; }
                state->vac[ins->index].is_ref = false;
                state->vac[ins->index].is_scalar = true;
                state->vac[ins->index].scalar = halmat_scalar_from_double((double)a.bits, false);
                break;

            case OP_ITOI:
                /* Integer precision scale, class-6/ITOI.md -- this
                 * interpreter's INTEGER has no single/double precision
                 * distinction to scale between (int32_t only), so this
                 * is a plain passthrough. */
                if (ins->operand_count != 1) { fail(state, "ITOI: expected 1 operand"); break; }
                if (!resolve_operand(state, &ins->operands[0], &a)) break;
                if (ins->index >= HALMAT_VAC_MAX) { fail(state, "VAC index out of range"); break; }
                state->vac[ins->index].is_ref = false;
                state->vac[ins->index].is_scalar = false;
                state->vac[ins->index].integer = rv_to_integer(&a);
                break;

            case OP_BTOC: {
                /* Bit->character (simple form, no @DEC/@OCT/@HEX radix
                 * qualifier), class-2/BTOC.md: USA003087 Sec. 21.4's own
                 * worked example says "the number of characters is the
                 * same as the number of bits" -- each bit becomes a
                 * literal '0'/'1' character, most-significant first (the
                 * same MSB-first convention as format_bit_field's WRITE
                 * formatting just above, but with no inserted grouping
                 * blanks -- confirmed against real gpc output: BIT(8)
                 * value 12 (00001100) converts to the 8-character string
                 * "00001100", not "12"). An earlier version of this case
                 * instead did decimal-of-the-raw-pattern formatting
                 * (`"%u"`), matching the reference emulator's own
                 * behavior there rather than real hardware -- that was
                 * simply wrong (problems-yaHALMAT2.md item 5), not a
                 * @DEC-qualified radix form (that's a different,
                 * separately-tagged conversion, not plain BTOC). Same
                 * declared-width lookup convention as BNOT/BCAT/the
                 * WRITE-argument BIT case, defaulting to 32 when
                 * unknown. */
                if (ins->operand_count != 1) { fail(state, "BTOC: expected 1 operand"); break; }
                if (!resolve_operand(state, &ins->operands[0], &a)) break;
                if (a.kind != RV_BITS) { fail(state, "BTOC: operand is not BIT"); break; }
                if (ins->index >= HALMAT_VAC_MAX) { fail(state, "VAC index out of range"); break; }
                int width = 32;
                if (ins->operands[0].qual == QUAL_SYT && state->symtab) {
                    const halmat_symtab_entry_t *sym = halmat_symtab_find_by_index(state->symtab, ins->operands[0].data);
                    if (sym && sym->bit_width > 0) width = sym->bit_width;
                } else if (ins->operands[0].qual == QUAL_VAC && ins->operands[0].data < HALMAT_VAC_MAX) {
                    int vac_width = state->vac[ins->operands[0].data].bit_width;
                    if (vac_width > 0) width = vac_width;
                } else if (ins->operands[0].qual == QUAL_LIT && state->literals &&
                           ins->operands[0].data < state->literals->count) {
                    const halmat_literal_t *lit = &state->literals->entries[ins->operands[0].data];
                    if (lit->type == LIT_BIT && lit->bit_width > 0) width = lit->bit_width;
                }
                /* Radix-qualified form (`CHARACTER(B) @HEX/@DEC/@OCT/
                 * @BIN;`) -- user-reported (radix_qualified_character_
                 * bit_ignored; 255-TEST3.hal's four WRITE(6) CHARACTER(B)
                 * calls, B a BIT(8) holding decimal 25): this instruction's
                 * own operator-word TAG carries the radix qualifier,
                 * confirmed empirically against this exact file's real
                 * compiled HALMAT (source order @HEX/@DEC/@OCT/@BIN):
                 * TAG=4 is @HEX ("19"), TAG=2 is @DEC ("025"), TAG=3 is
                 * @OCT ("031"), TAG=1 is @BIN ("00011001" -- identical to
                 * the plain/unqualified simple form below, TAG=0, which
                 * this project's own established BTOC.md trace
                 * (`C1 = CHARACTER(B0);`, no qualifier) already confirms
                 * compiles as TAG=0). Field width for each radix is the
                 * minimum number of digits needed to represent every
                 * value the source BIT's own declared width can hold,
                 * zero-padded -- confirmed against the width=8 case above
                 * (HEX: ceil(8/4)=2 digits, "19"; OCT: ceil(8/3)=3 digits,
                 * "031"; DEC: digit count of 2^8-1=255, i.e. 3 digits,
                 * "025"); no primary source decodes the general rule
                 * (BTOC.md's own "Unresolved Questions" -- #QBTOC's exact
                 * formatting was never decoded), so this generalizes from
                 * the one confirmed real trace rather than guessing at a
                 * different rule. Hex digit case (upper vs. lower) is
                 * unconfirmed -- this file's own "19"/"025"/"031" never
                 * exercise a letter digit -- upper chosen as this
                 * project's own general convention (matching HEX literal
                 * formatting elsewhere in this file). */
                if (ins->tag == 2 || ins->tag == 3 || ins->tag == 4) {
                    uint32_t maxval = (width >= 32) ? 0xFFFFFFFFu : ((1u << width) - 1u);
                    uint32_t v = (width >= 32) ? a.bits : (a.bits & maxval);
                    char buf[33];
                    if (ins->tag == 4) {
                        int digits = (width + 3) / 4;
                        snprintf(buf, sizeof buf, "%0*X", digits, v);
                    } else if (ins->tag == 3) {
                        int digits = (width + 2) / 3;
                        snprintf(buf, sizeof buf, "%0*o", digits, v);
                    } else {
                        int digits = 1;
                        for (uint32_t t = maxval; t >= 10; t /= 10) digits++;
                        snprintf(buf, sizeof buf, "%0*u", digits, v);
                    }
                    state->vac[ins->index].is_ref = false;
                    state->vac[ins->index].is_string = true;
                    state->vac[ins->index].string = dup_string(buf);
                    break;
                }
                char buf[33];
                for (int i = 0; i < width; i++) {
                    buf[i] = ((a.bits >> (width - 1 - i)) & 1u) ? '1' : '0';
                }
                buf[width] = '\0';
                state->vac[ins->index].is_ref = false;
                state->vac[ins->index].is_string = true;
                state->vac[ins->index].string = dup_string(buf);
                break;
            }

            case OP_CTOB: {
                /* Character->bit (simple form), class-1/CTOB.md: the
                 * natural inverse of BTOC's own simple-form fix above --
                 * each character is one bit, most-significant first (a
                 * non-'1' character, in particular '0', contributes a 0
                 * bit; this project has no primary-source citation for
                 * what a truly invalid character like 'X' should do, and
                 * no fixture exercises it, so it's treated the same as
                 * '0' rather than failing loudly). Confirmed against real
                 * gpc output for test_bit_conv.hal's `B3 = BIT(C1);`
                 * (C1 = "00001100" from the BTOC fix above): INTEGER(B3)
                 * comes back as 12 (0b00001100), matching this decode,
                 * not the previous decimal-string-parse convention
                 * (which the two fixes' own comments already flagged as
                 * an unverified, "natural inverse of a guess" pairing). */
                if (ins->operand_count != 1) { fail(state, "CTOB: expected 1 operand"); break; }
                if (!resolve_operand(state, &ins->operands[0], &a)) break;
                if (a.kind != RV_STRING) { fail(state, "CTOB: operand is not CHARACTER"); break; }
                if (ins->index >= HALMAT_VAC_MAX) { fail(state, "VAC index out of range"); break; }
                size_t len = strlen(a.string);
                if (len > 32) len = 32; /* project-wide 32-bit BIT ceiling, state.h's bit_width comment */
                uint32_t bits = 0;
                for (size_t i = 0; i < len; i++) {
                    bits = (bits << 1) | (a.string[i] == '1' ? 1u : 0u);
                }
                state->vac[ins->index].is_ref = false;
                state->vac[ins->index].is_bits = true;
                state->vac[ins->index].bits = bits;
                state->vac[ins->index].bit_width = (int)len;
                break;
            }

            case OP_STOB:
                /* Scalar->bit, class-1/STOB.md. No reference
                 * implementation exists to cross-check -- implemented as
                 * BTOS's inverse: round to the nearest integer (STOI's
                 * rule, halmat_scalar_to_integer) then reinterpret as an
                 * unsigned bit pattern. */
                if (ins->operand_count != 1) { fail(state, "STOB: expected 1 operand"); break; }
                if (!resolve_operand(state, &ins->operands[0], &a)) break;
                if (ins->index >= HALMAT_VAC_MAX) { fail(state, "VAC index out of range"); break; }
                state->vac[ins->index].is_ref = false;
                state->vac[ins->index].is_bits = true;
                state->vac[ins->index].bits = (uint32_t)rv_to_integer(&a);
                break;

            case OP_BTOB:
                /* Bit->bit self-conversion (length adjustment), class-1/
                 * BTOB.md -- confirmed to compile to a plain register
                 * load/store with no runtime call, i.e. a pure
                 * passthrough at the value level (this interpreter has
                 * no declared-width tracking to actually adjust, see
                 * state.h). */
                if (ins->operand_count != 1) { fail(state, "BTOB: expected 1 operand"); break; }
                if (!resolve_operand(state, &ins->operands[0], &a)) break;
                if (a.kind != RV_BITS) { fail(state, "BTOB: operand is not BIT"); break; }
                if (ins->index >= HALMAT_VAC_MAX) { fail(state, "VAC index out of range"); break; }
                state->vac[ins->index].is_ref = false;
                state->vac[ins->index].is_bits = true;
                state->vac[ins->index].bits = a.bits;
                break;

            case OP_BTOQ:
            case OP_CTOQ:
            case OP_STOQ:
            case OP_ITOQ:
                /* SUBBIT pseudo-conversion (class-1/ITOQ.md's shared
                 * XBTOQ family): TAG=0 is reference context (read the
                 * argument's raw representation as a bit pattern --
                 * identical in effect to BTOB/CTOB/STOB/ITOB's own
                 * conversions, per ITOQ.md's confirmed "I1's raw bit
                 * pattern copied directly into B1" trace); TAG=1 is
                 * assignment context (`SUBBIT(x) = ...;`, ITOQ.md's own
                 * confirmed trace: this opcode's VAC result supplies the
                 * *receiver* for a following BASN, rather than a value --
                 * SUBBIT always routes the actual write through a bit-
                 * string intermediary, so BASN is the only assign opcode
                 * it ever chains into, confirmed operand-for-operand
                 * against `SUBBIT(I1) = BIN'...';`). Only a plain SYT
                 * argument is confirmed (the subscripted `SUBBITn TO
                 * m(...)` window form is an ITOQ.md Unresolved Question,
                 * not implemented here either). */
                if (ins->tag == 1) {
                    if (ins->operand_count != 1 || ins->operands[0].qual != QUAL_SYT) {
                        fail(state, "SUBBIT assignment: expected a plain SYT operand");
                        break;
                    }
                    if (ins->index >= HALMAT_VAC_MAX) { fail(state, "VAC index out of range"); break; }
                    state->vac[ins->index].is_ref = false;
                    state->vac[ins->index].is_subbit_ref = true;
                    state->vac[ins->index].subbit_target_syt = ins->operands[0].data;
                    break;
                }
                if (ins->tag != 0) {
                    fail(state, "SUBBIT: unrecognized TAG %u (expected 0=reference or 1=assignment)", ins->tag);
                    break;
                }
                if (ins->operand_count != 1) { fail(state, "BTOQ/CTOQ/STOQ/ITOQ: expected 1 operand"); break; }
                if (!resolve_operand(state, &ins->operands[0], &a)) break;
                if (ins->index >= HALMAT_VAC_MAX) { fail(state, "VAC index out of range"); break; }
                /* RV_SCALAR (STOQ, `SUBBIT(a_scalar_var)`): SUBBIT "opens
                 * a window on the [argument's] bit pattern" (USA003087
                 * Sec. 21.5) -- a raw memory reinterpretation, NOT a
                 * numeric conversion. This previously called
                 * rv_to_integer(), which *rounds the scalar to its
                 * nearest whole number first* (the same routine STOI/
                 * STOB use for the ordinary, semantically different
                 * `INTEGER(...)`/`BIT(...)` conversion functions) -- wrong
                 * for SUBBIT specifically, silently returning "the
                 * argument's value rounded to an integer, reinterpreted
                 * as bits" instead of "the argument's own raw stored
                 * bits." Fixed by reinterpreting halmat_scalar_t's own
                 * `msw` directly: this project's SCALAR representation is
                 * already the exact bit-for-bit AP-101S/IBM hexadecimal-
                 * floating-point wire format (value.h), not a native
                 * double approximated at read time, so `msw` genuinely
                 * *is* the argument's real 32-bit in-memory pattern for a
                 * SINGLE-precision SCALAR -- no reinterpret-cast trickery
                 * needed, unlike INTEGER's C-level cast below. A DOUBLE-
                 * precision SCALAR's real width is 64 bits (msw+lsw), which
                 * doesn't fit this interpreter's uint32_t bits/RV_BITS
                 * representation at all (a project-wide ceiling on every
                 * BIT value, not something specific to SUBBIT) -- fails
                 * loudly rather than silently truncating half the pattern
                 * away. No fixture previously exercised SUBBIT on any
                 * SCALAR argument at all (only INTEGER, test_subbit.hal),
                 * so this was a latent, never-observed bug rather than a
                 * regression. */
                if (a.kind == RV_SCALAR && a.scalar.double_precision) {
                    fail(state, "SUBBIT: DOUBLE-precision SCALAR argument needs a 64-bit bit-pattern window, "
                                "wider than this interpreter's BIT value representation supports");
                    break;
                }
                state->vac[ins->index].is_ref = false;
                state->vac[ins->index].is_bits = true;
                switch (a.kind) {
                    case RV_BITS: state->vac[ins->index].bits = a.bits; break;
                    case RV_INTEGER: state->vac[ins->index].bits = (uint32_t)a.integer; break;
                    case RV_SCALAR: state->vac[ins->index].bits = a.scalar.msw; break;
                    case RV_STRING: state->vac[ins->index].bits = (uint32_t)strtoul(a.string, NULL, 10); break;
                }
                break;

            case OP_BTRU:
                /* Bit-is-true test, class-7/BTRU.md: the generic "make
                 * this bit value branch-testable" operator FBRA consumes
                 * -- nonzero is true, matching BEQU/BNEQ/every other
                 * comparison's VAC-carried 0/1 convention. */
                if (ins->operand_count != 1) { fail(state, "BTRU: expected 1 operand"); break; }
                if (!resolve_operand(state, &ins->operands[0], &a)) break;
                if (a.kind != RV_BITS) { fail(state, "BTRU: operand is not BIT"); break; }
                if (ins->index >= HALMAT_VAC_MAX) { fail(state, "VAC index out of range"); break; }
                state->vac[ins->index].is_ref = false;
                state->vac[ins->index].integer = (a.bits != 0) ? 1 : 0;
                break;

            case OP_BEQU:
            case OP_BNEQ:
                if (ins->operand_count != 2) { fail(state, "BEQU/BNEQ: expected 2 operands"); break; }
                if (!resolve_operand(state, &ins->operands[0], &a)) break;
                if (!resolve_operand(state, &ins->operands[1], &b)) break;
                if (a.kind != RV_BITS || b.kind != RV_BITS) { fail(state, "BEQU/BNEQ: both operands must be BIT"); break; }
                if (ins->index >= HALMAT_VAC_MAX) { fail(state, "VAC index out of range"); break; }
                {
                    bool equal = (a.bits == b.bits);
                    bool result = (ins->opcode == OP_BEQU) ? equal : !equal;
                    state->vac[ins->index].is_ref = false;
                    state->vac[ins->index].integer = result ? 1 : 0;
                }
                break;

            case OP_CASN:
                /* Character assign, source-first/receiver-second like the
                 * rest of the xASN family (class-2/CASN.md). Unlike IASN/
                 * SASN, no kind coercion is needed: a CHARACTER source
                 * (SYT or LIT) already resolves as RV_STRING. */
                if (ins->operand_count != 2) { fail(state, "CASN: expected 2 operands"); break; }
                if (!resolve_operand(state, &ins->operands[0], &a)) break;
                if (a.kind != RV_STRING) { fail(state, "CASN: source is not CHARACTER"); break; }
                if (!write_destination(state, &ins->operands[1], &a)) break;
                break;

            case OP_CCAT: {
                if (ins->operand_count != 2) { fail(state, "CCAT: expected 2 operands"); break; }
                if (!resolve_operand(state, &ins->operands[0], &a)) break;
                if (!resolve_operand(state, &ins->operands[1], &b)) break;
                if (a.kind != RV_STRING || b.kind != RV_STRING) { fail(state, "CCAT: both operands must be CHARACTER"); break; }
                if (ins->index >= HALMAT_VAC_MAX) { fail(state, "VAC index out of range"); break; }
                size_t len_a = strlen(a.string), len_b = strlen(b.string);
                char *result = malloc(len_a + len_b + 1);
                if (!result) { fail(state, "CCAT: out of memory"); break; }
                memcpy(result, a.string, len_a);
                memcpy(result + len_a, b.string, len_b + 1);
                state->vac[ins->index].is_ref = false;
                state->vac[ins->index].is_string = true;
                state->vac[ins->index].string = result;
                break;
            }

            case OP_CTOC:
                /* Character-to-character (length-adjustment) self-
                 * conversion, class-2/CTOC.md. This interpreter's
                 * CHARACTER storage has no fixed-length/VARYING
                 * distinction (state.h), so there's nothing to truncate
                 * or pad -- a straight passthrough copy. */
                if (ins->operand_count != 1) { fail(state, "CTOC: expected 1 operand"); break; }
                if (!resolve_operand(state, &ins->operands[0], &a)) break;
                if (a.kind != RV_STRING) { fail(state, "CTOC: operand is not CHARACTER"); break; }
                if (ins->index >= HALMAT_VAC_MAX) { fail(state, "VAC index out of range"); break; }
                state->vac[ins->index].is_ref = false;
                state->vac[ins->index].is_string = true;
                state->vac[ins->index].string = dup_string(a.string);
                break;

            case OP_STOC: {
                /* Scalar->character, class-2/STOC.md: same fixed-width
                 * scientific-notation field as WRITE's own SCALAR
                 * formatting (halmat_scalar_format) -- STOC.md's format
                 * rules explicitly cite the same USA00309 Sec. 6.1.3
                 * source WRITE uses. */
                if (ins->operand_count != 1) { fail(state, "STOC: expected 1 operand"); break; }
                if (!resolve_operand(state, &ins->operands[0], &a)) break;
                if (ins->index >= HALMAT_VAC_MAX) { fail(state, "VAC index out of range"); break; }
                char buf[32];
                halmat_scalar_format(rv_to_scalar(&a), buf, sizeof(buf));
                state->vac[ins->index].is_ref = false;
                state->vac[ins->index].is_string = true;
                state->vac[ins->index].string = dup_string(buf);
                break;
            }

            case OP_ITOC: {
                /* Integer->character, class-2/ITOC.md: variable-length
                 * (up to 11 chars), right-justified with leading zeros
                 * suppressed, no sign character for non-negative values
                 * -- i.e. just "%d", not WRITE's fixed-width "%11d". */
                if (ins->operand_count != 1) { fail(state, "ITOC: expected 1 operand"); break; }
                if (!resolve_operand(state, &ins->operands[0], &a)) break;
                if (ins->index >= HALMAT_VAC_MAX) { fail(state, "VAC index out of range"); break; }
                char buf[16];
                snprintf(buf, sizeof(buf), "%d", rv_to_integer(&a));
                state->vac[ins->index].is_ref = false;
                state->vac[ins->index].is_string = true;
                state->vac[ins->index].string = dup_string(buf);
                break;
            }

            case OP_CTOS:
                /* Character->scalar, class-5/CTOS.md: parses the
                 * standard input formats (USA00309 Sec. 6.1.2) --
                 * strtod() covers the decimal and "dddEddd" forms
                 * directly; the HAL/S-specific B(binary)/H(hex) exponent
                 * suffixes aren't implemented (no fixture uses them). No
                 * rounding step for SCALAR (unlike CTOI below). */
                if (ins->operand_count != 1) { fail(state, "CTOS: expected 1 operand"); break; }
                if (!resolve_operand(state, &ins->operands[0], &a)) break;
                if (a.kind != RV_STRING) { fail(state, "CTOS: operand is not CHARACTER"); break; }
                if (ins->index >= HALMAT_VAC_MAX) { fail(state, "VAC index out of range"); break; }
                state->vac[ins->index].is_ref = false;
                state->vac[ins->index].is_scalar = true;
                state->vac[ins->index].scalar = halmat_scalar_from_double(strtod(a.string, NULL), false);
                break;

            case OP_CTOI:
                /* Character->integer, class-6/CTOI.md: same parse as
                 * CTOS, then rounds to nearest (per the doc's explicit
                 * "rounded to the nearest integral value" rule) rather
                 * than truncating. */
                if (ins->operand_count != 1) { fail(state, "CTOI: expected 1 operand"); break; }
                if (!resolve_operand(state, &ins->operands[0], &a)) break;
                if (a.kind != RV_STRING) { fail(state, "CTOI: operand is not CHARACTER"); break; }
                if (ins->index >= HALMAT_VAC_MAX) { fail(state, "VAC index out of range"); break; }
                state->vac[ins->index].is_ref = false;
                state->vac[ins->index].is_scalar = false;
                state->vac[ins->index].integer = (int32_t)lround(strtod(a.string, NULL));
                break;

            case OP_SFST:
                /* Shaping-function argument-list start (class-0/SFST.md);
                 * its own operand (nesting level/flow number) isn't
                 * needed for evaluation, only by the compiler itself. */
                state->shape_pending.active = true;
                state->shape_pending.item_count = 0;
                break;

            case OP_SFAR:
                /* One per shaping-function argument (class-0/SFAR.md).
                 * Stored raw -- see state.h's shape_pending comment for
                 * why resolution is deferred to the shaping-result
                 * opcode (VSHP/MSHP/etc) rather than done here. */
                if (!state->shape_pending.active) { fail(state, "SFAR outside of an SFST...SFND block"); break; }
                if (ins->operand_count != 1) { fail(state, "SFAR: expected 1 operand"); break; }
                if (state->shape_pending.item_count >= HALMAT_MAX_OPERANDS) {
                    fail(state, "shaping-function argument list too long");
                    break;
                }
                state->shape_pending.items[state->shape_pending.item_count++] = ins->operands[0];
                break;

            case OP_SFND:
                state->shape_pending.active = false;
                break;

            case OP_VSHP:
            case OP_SSHP:
            case OP_ISHP: {
                /* List-form VECTOR(...)/SCALAR(...)/INTEGER(...)
                 * construction (class-0/VSHP.md, SSHP.md, ISHP.md): own
                 * operand = the resulting flat length (IMD literal); each
                 * pending SFAR argument is unraveled via
                 * unravel_shaping_argument (a whole VECTOR/MATRIX/ARRAY
                 * argument contributes more than one element -- not just
                 * plain scalars, [USA003088] Sec. 6.6 rule 5's "VECTOR
                 * and MATRIX may have arguments of integer, scalar,
                 * vector, and matrix types"; the *result* here is always
                 * flat/1-D regardless, matching these three opcodes'
                 * "linear array" semantic rule). Result is a flat
                 * container of boxed halmat_scalar_t -- which HAL/S type
                 * (VECTOR vs SCALAR ARRAY vs INTEGER ARRAY) this is
                 * ultimately assigned into is entirely the destination's
                 * own declared shape, not something this container
                 * itself needs to tag (state.h's elements comment). MSHP
                 * (matrix result, 2-D reraveling) gets its own case
                 * below. */
                if (ins->operand_count != 1) { fail(state, "VSHP/SSHP/ISHP: expected 1 operand"); break; }
                if (!resolve_operand(state, &ins->operands[0], &a)) break;
                size_t length = (size_t)rv_to_integer(&a);
                if (length > HALMAT_CONTAINER_CAPACITY) { fail(state, "VSHP/SSHP/ISHP: result too large"); break; }
                halmat_scalar_t result[HALMAT_CONTAINER_CAPACITY];
                size_t used = 0;
                bool ok = true;
                for (uint8_t i = 0; ok && i < state->shape_pending.item_count; i++) {
                    size_t added = unravel_shaping_argument(state, &state->shape_pending.items[i], result, HALMAT_CONTAINER_CAPACITY, used);
                    if (added == 0) { ok = false; break; }
                    used += added;
                }
                if (!ok) break;
                if (used != length) {
                    fail(state, "VSHP/SSHP/ISHP: declared length %zu doesn't match %zu unraveled elements", length, used);
                    break;
                }
                if (!store_container_result(state, ins->index, result, length, 0, (int)length)) break;
                break;
            }

            case OP_MSHP: {
                /* List-form MATRIX(...) construction (class-0/MSHP.md):
                 * [USA003088] Sec. 6.6's general <arith conversion> rule
                 * governs this the same as VSHP/SSHP/ISHP above (unravel
                 * every SFAR argument -- plain scalar/integer or whole
                 * VECTOR/MATRIX alike -- into one flat sequence), but
                 * MATRIX reravels that sequence into a genuinely 2-D
                 * (row-major) result instead of a flat one (Sec. 6.6
                 * semantic rule 4: "the row and column dimensions...
                 * [t]heir product must therefore match the total number
                 * of data elements implied by the argument(s)"). Two
                 * confirmed real forms both reach here (`MATRIX(1,2,...,
                 * 9)`, 9 separate plain-scalar SFARs; `MATRIX(X,Y,Z)`,
                 * 044-ORTHONORMAL.hal's real call site, 3 whole-VECTOR
                 * SFARs, user-reported gap) -- both compile to the
                 * *identical* MSHP operand value (empirically confirmed
                 * this session, `unHALMAT.py` against both), which rules
                 * out inferring the result shape from shape_pending's own
                 * item count/shape (right for the second form only, by
                 * coincidence, and silently wrong for the first). Instead
                 * MSHP's own operand -- an encoded dimension descriptor,
                 * confirmed decimal 771=0x0303 for the unsubscripted
                 * "assumed 3 by 3" default (Sec. 6.6 semantic rule 1) --
                 * is decoded directly as high-byte=rows/low-byte=cols
                 * (0x03,0x03 -> 3,3): the cleanest reading of a value
                 * that's obviously an intentional byte-packed pair, not
                 * an opaque bitfield. Only independently confirmed for
                 * this one default-3x3 data point -- the explicit
                 * `MATRIXm,n(...)` subscript form's real HAL/S-FC source
                 * syntax wasn't found this session (several plausible
                 * spellings from [USA003088]'s own typeset examples, e.g.
                 * `MATRIX2,3(...)`/`MATRIX 2,3 (...)`, both rejected by
                 * the real compiler) -- so this decode is untested
                 * against any non-default shape; flagged here rather than
                 * silently assumed reliable. */
                if (ins->operand_count != 1) { fail(state, "MSHP: expected 1 operand"); break; }
                if (!resolve_operand(state, &ins->operands[0], &a)) break;
                uint32_t descriptor = (uint32_t)rv_to_integer(&a);
                size_t rows = (descriptor >> 8) & 0xFF;
                size_t cols = descriptor & 0xFF;
                if (rows == 0 || cols == 0 || rows * cols > HALMAT_CONTAINER_CAPACITY) {
                    fail(state, "MSHP: unrecognized dimension descriptor %u (decoded %zux%zu)", descriptor, rows, cols);
                    break;
                }
                halmat_scalar_t result[HALMAT_CONTAINER_CAPACITY];
                size_t used = 0;
                bool ok = true;
                for (uint8_t i = 0; ok && i < state->shape_pending.item_count; i++) {
                    size_t added = unravel_shaping_argument(state, &state->shape_pending.items[i], result, HALMAT_CONTAINER_CAPACITY, used);
                    if (added == 0) { ok = false; break; }
                    used += added;
                }
                if (!ok) break;
                if (used != rows * cols) {
                    fail(state, "MSHP: %zux%zu result needs %zu elements, got %zu", rows, cols, rows * cols, used);
                    break;
                }
                if (!store_container_result(state, ins->index, result, rows * cols, (int)rows, (int)cols)) break;
                break;
            }

            case OP_LFNC: {
                /* MAX/MIN/SUM/PROD/SIZE over an ARRAY, class-0/LFNC.md's
                 * "L-FUNC" dispatch category -- QUAL=IMD selector on
                 * LFNC's own operand. LFNC.md's own Unresolved Questions
                 * ("whether any other built-in shares this category...
                 * not exhaustively tested") turned out to include more
                 * than just MAX(7)/MIN(8): user-reported (071-DARTBOARD_
                 * APPROXIMATION.hal's RANDOM, a *different* BFNC bug --
                 * see below -- prompted a "find every unimplemented
                 * built-in" sweep that started this batch), empirically
                 * cross-checking every ARRAY-reduction function from
                 * [USA003087] Appendix B's "ARRAY FUNCTIONS"/"SIZE
                 * FUNCTION" tables against a real compile confirmed
                 * SUM=14 (141-VSUM.hal's own `SIZE(V)` call surfaced this
                 * file's *other* selector, 23=SIZE, as an unhandled-
                 * selector failure first) and PROD=20 also route through
                 * this exact same opcode, not BFNC as first assumed --
                 * both compiled directly (`S2=SUM(SA1); S2=PROD(SA1);`)
                 * and confirmed via this project's own --disasm: `LFNC`
                 * operand data=14 and =20 respectively, i.e. the *same*
                 * selector numbers as their position in BFNC's own
                 * BI_NAME table (class-0/BFNC.md), just dispatched
                 * through this separate opcode instead -- consistent
                 * with MAX=7/MIN=8 (LFNC.md's already-confirmed pair)
                 * using their BI_NAME position too. SIZE(23) similarly
                 * confirmed via 141-VSUM.hal's real `DO FOR ... = 1 TO
                 * SIZE(V);`: unlike MAX/MIN/SUM/PROD's fold-to-one-value
                 * reduction, SIZE just wants the argument's own element
                 * count -- resolve_container's own `count` output serves
                 * directly, needing no per-element loop at all, and
                 * (unlike a symbol-table-based approach) reads the
                 * *runtime* SFAR-captured array like every other
                 * selector here, so it works for a VAC-carried argument
                 * too, not just a bare declared symbol. The array
                 * argument itself was captured raw by SFAR (inside an
                 * ADLP/DLPE bracket this interpreter treats as a no-op --
                 * see interp_step's arrayed-paragraph replay comment;
                 * SFAR's own operand capture doesn't call resolve_operand
                 * so it's unaffected by the arrayed-whole-array guard
                 * either way), so it's read here via resolve_container. */
                if (ins->operand_count != 1 || ins->operands[0].qual != QUAL_IMD) {
                    fail(state, "LFNC: expected 1 IMD operand");
                    break;
                }
                if (!state->shape_pending.active || state->shape_pending.item_count != 1) {
                    fail(state, "LFNC: expected exactly one SFAR-captured array argument");
                    break;
                }
                halmat_scalar_t *ca; size_t count; int rows, cols;
                if (!resolve_container(state, &state->shape_pending.items[0], &ca, &count, &rows, &cols)) break;
                if (ins->index >= HALMAT_VAC_MAX) { fail(state, "VAC index out of range"); break; }
                uint16_t selector = ins->operands[0].data;
                if (selector == 23) { /* SIZE: "length of array," no reduction loop needed -- INTEGER.
                    * USA003087 Appendix B's own SIZE FUNCTION table: "alpha is an
                    * unsubscripted arrayed variable with a one-dimensional array
                    * specification -- function returns length of array." For a
                    * plain flat ARRAY (rows==cols==0 via ensure_container), the
                    * array's own length IS its flat element count (`count`,
                    * already correct). But for an ARRAY-of-VECTOR (rows>0,
                    * cols>0, array_of_vector-shaped -- ensure_container's own
                    * comment) `count`/resolve_container's OUT_COUNT is the *flat
                    * scalar* count (n*m, e.g. 9 for an ARRAY(3) VECTOR(3)), not
                    * the array's own length (n, e.g. 3) -- user-reported,
                    * 141-VSUM.hal's `DECLARE V ARRAY(*) VECTOR; ... DO FOR
                    * TEMPORARY N = 1 TO SIZE(V); TOTAL = TOTAL + V$(N:); END;`:
                    * SIZE(V) returning 9 instead of 3 ran the loop 3x too many
                    * times, each of the 3 "extra" passes silently re-summing the
                    * same 3 real VECTORs again (modulo-wrapping V$(N:)'s own
                    * index), inflating the total exactly 3x (SUM=(3,6,9) instead
                    * of the hand-derivable (1,2,3)). A genuinely 2-dimensional
                    * ARRAY(r,c) of SCALAR also sets rows>0/cols>0 the same way
                    * (the 2D-ARRAY-of-SCALAR fix, ensure_container's own
                    * comment) but isn't "one-dimensional" in the first place, so
                    * SIZE() on one isn't valid HAL/S to begin with (no confirmed
                    * real-corpus case reaches here that way) -- rows>0 && cols>0
                    * is therefore an unambiguous "this is the array-of-VECTOR
                    * case, use the array's own length" signal in practice. */
                    int32_t size = (rows > 0 && cols > 0) ? rows : (int32_t)count;
                    state->vac[ins->index].is_ref = false;
                    state->vac[ins->index].is_scalar = false;
                    state->vac[ins->index].integer = size;
                    break;
                }
                if (count == 0) { fail(state, "LFNC: empty array argument"); break; }
                if (selector != 7 && selector != 8 && selector != 14 && selector != 20) {
                    fail(state, "LFNC: unknown selector %u (expected 7=MAX, 8=MIN, 14=SUM, 20=PROD, or 23=SIZE)", selector);
                    break;
                }
                halmat_scalar_t result = (selector == 14) ? halmat_scalar_zero(false)
                                        : (selector == 20) ? halmat_scalar_from_double(1.0, false) : ca[0];
                for (size_t i = 0; i < count; i++) {
                    if (selector == 14) { result = halmat_scalar_add(result, ca[i]); continue; }
                    if (selector == 20) { result = halmat_scalar_multiply(result, ca[i]); continue; }
                    /* MAX/MIN: sign/zero-ness of ca[i]-result decides the comparison, same technique this opcode already used before this batch */
                    halmat_scalar_t diff = halmat_scalar_sub(ca[i], result);
                    bool is_zero = (diff.msw == 0 && diff.lsw == 0);
                    bool is_negative = ((diff.msw >> 31) & 1) != 0;
                    bool i_is_greater = !is_zero && !is_negative;
                    bool i_is_less = !is_zero && is_negative;
                    if ((selector == 7 && i_is_greater) || (selector == 8 && i_is_less)) result = ca[i];
                }
                state->vac[ins->index].is_ref = false;
                state->vac[ins->index].is_scalar = true;
                state->vac[ins->index].scalar = result;
                break;
            }

            case OP_BFNC: {
                /* Built-in function call, class-0/BFNC.md's confirmed
                 * selector table (the instruction's own TAG field), per
                 * [USA003087] Appendix B's full function catalog. Batch-
                 * implemented across several selector families in one
                 * pass (user request, after repeated one-at-a-time
                 * BFNC-selector bug reports: "make a concerted effort to
                 * find all... and implement them in a big batch"):
                 * plain-SCALAR-argument arithmetic/algebraic functions
                 * (including the hyperbolic/inverse-trig/rounding group
                 * added this session), the niladic functions (PRIO/
                 * RANDOM/RANDOMG/RUNTIME/ERRGRP/ERRNUM -- no argument),
                 * the VECTOR/MATRIX functions (ABVAL/UNIT/LENGTH/TRIM/
                 * DET/INVERSE/TRANSPOSE/TRACE), the ARRAY aggregate
                 * functions (MAX/MIN/SUM/PROD/SIZE), the two/three-
                 * argument functions (DIV/MOD/REMAINDER/MIDVAL/ARCTAN2/
                 * SHL/SHR/XOR/INDEX/LJUST/RJUST), and ODD. DET/INVERSE
                 * share the same double-via-Gaussian-elimination
                 * precision compromise as MINV (class-3/MINV.md); SIGN's
                 * documented return type is unconfirmed, implemented
                 * returning SCALAR like its arithmetic-function siblings,
                 * not INTEGER -- the same simplification is used for
                 * every other selector in this file whose Appendix B
                 * entry says "result type matches argument type" (FLOOR/
                 * CEILING/TRUNCATE/SIGNUM/DIV/MOD/REMAINDER): none of
                 * this file's arithmetic-function results distinguish
                 * INTEGER vs. SCALAR by argument type, so these don't
                 * either, for consistency with the existing group rather
                 * than introducing a distinction nothing else here makes.
                 * DATE(18)/CLOCKTIME(54): user-clarified these mean real
                 * OS wall-clock time in the system's configured local
                 * timezone, not the interpreter's own simulated virtual
                 * clock (unlike RUNTIME/NEXTIME, [USA00309] Sec. 8.2 rule
                 * 18 explicitly calls those the *simulated* elapsed
                 * time) -- see their own case bodies below for the exact
                 * format ([USA00309] Sec. 8.2 rule 17 pins DATE down
                 * precisely; CLOCKTIME's unit is a documented judgment
                 * call, Appendix B's "time of day" being the only prose
                 * describing it).
                 * Deliberately NOT implemented, and documented as such
                 * rather than guessed at: NEXTIME(50) (would need deep
                 * scheduler-internals introspection -- state->tasks[]'s
                 * IN/AT-scheduled wake time -- not undertaken this
                 * pass); and BIT(57)/
                 * SUBBIT(58)/INTEGER(59)/SCALAR(60)/VECTOR(61)/
                 * MATRIX(62)/CHARACTER(63) (these BI_NAME slots almost
                 * certainly back the explicit-conversion/shaping-function
                 * *syntax* `SCALAR(...)`/`VECTOR(...)`/etc., which this
                 * project's own extensive prior work already confirmed
                 * compiles to dedicated opcodes -- STOI/CTOS/MSHP/VSHP/
                 * SSHP/ISHP/BASN/ITOQ and friends -- not a raw BFNC call;
                 * no real compiled HALMAT hitting BFNC with any of these
                 * selectors has been observed, so implementing them here
                 * would be unverifiable invention). */
                if (ins->tag == 19) { /* PRIO: no argument, current task's priority */
                    if (ins->index >= HALMAT_VAC_MAX) { fail(state, "VAC index out of range"); break; }
                    state->vac[ins->index].is_ref = false;
                    state->vac[ins->index].is_scalar = false;
                    state->vac[ins->index].integer = state->tasks[state->current_task].priority;
                    break;
                }
                if (ins->tag == 42 || ins->tag == 51) {
                    /* RANDOM/RANDOMG: no argument -- user-reported
                     * (071-DARTBOARD_APPROXIMATION.hal's `X = RANDOM;`
                     * failing "BFNC: expected 1 operand (selector 42)",
                     * the same "no-argument built-in rejected by the
                     * generic 1-operand check" shape PRIO already had to
                     * be special-cased for above). RANDOM: state.h's
                     * rng_state comment -- Park-Miller minimal-standard
                     * Lehmer generator, [0,1) rectangular distribution
                     * per Appendix B. RANDOMG: Box-Muller transform over
                     * two RANDOM draws for a mean-0/variance-1 Gaussian
                     * (Appendix B) -- an extra source of imprecision
                     * beyond RANDOM's own already-undocumented algorithm,
                     * same "no primary-source algorithm mandated"
                     * compromise. */
                    if (ins->index >= HALMAT_VAC_MAX) { fail(state, "VAC index out of range"); break; }
                    double u1 = next_random_uniform(state);
                    double r;
                    if (ins->tag == 42) {
                        r = u1;
                    } else {
                        double u2 = next_random_uniform(state);
                        if (u1 < 1e-300) u1 = 1e-300; /* guard log(0) */
                        r = sqrt(-2.0 * log(u1)) * cos(2.0 * HAL_S_PI * u2);
                    }
                    state->vac[ins->index].is_ref = false;
                    state->vac[ins->index].is_scalar = true;
                    state->vac[ins->index].scalar = halmat_scalar_from_double(r, false);
                    break;
                }
                if (ins->tag == 52) {
                    /* RUNTIME: no argument, virtual Real Time Executive
                     * clock (Sec. 8) in seconds -- [USA00309] Sec. 8.2
                     * rule 18: "double precision scalar" (fixed here
                     * alongside adding DATE/CLOCKTIME below: this
                     * previously returned single precision). */
                    if (ins->index >= HALMAT_VAC_MAX) { fail(state, "VAC index out of range"); break; }
                    double seconds = (double)state->virtual_time / (double)HALMAT_TICKS_PER_SECOND;
                    state->vac[ins->index].is_ref = false;
                    state->vac[ins->index].is_scalar = true;
                    state->vac[ins->index].scalar = halmat_scalar_from_double(seconds, true);
                    break;
                }
                if (ins->tag == 18 || ins->tag == 54) {
                    /* DATE/CLOCKTIME: no argument, real OS wall-clock
                     * time in the system's own configured local
                     * timezone (user-clarified) -- plain standard-C
                     * time()/localtime() (identically portable across
                     * this project's POSIX/MSVC targets, unlike
                     * interp_run_signal()'s platform-split
                     * monotonic_seconds() a few thousand lines down,
                     * which needs CLOCK_MONOTONIC precision this doesn't).
                     * localtime() already honors TZ/the OS's configured
                     * zone with no extra code. */
                    if (ins->index >= HALMAT_VAC_MAX) { fail(state, "VAC index out of range"); break; }
                    time_t now = time(NULL);
                    struct tm local_tm = *localtime(&now);
                    if (ins->tag == 18) {
                        /* DATE: [USA00309] Sec. 8.2 rule 17, confirmed
                         * exact format -- "a double precision integer
                         * whose decimal value is YYDDD where YY are the
                         * year and DDD represents the day of the year
                         * (i.e., February 1, 1978=78032)": two-digit
                         * year, 1-indexed day-of-year (tm_yday is
                         * 0-indexed; tm_year is years since 1900).
                         * "Double precision integer" is this project's
                         * ordinary 32-bit INTEGER -- no INTEGER SINGLE/
                         * DOUBLE distinction is modeled anywhere else
                         * either (STATUS.md's error-15 fixup note). */
                        int32_t yy = (local_tm.tm_year + 1900) % 100;
                        int32_t ddd = local_tm.tm_yday + 1;
                        state->vac[ins->index].is_ref = false;
                        state->vac[ins->index].is_scalar = false;
                        state->vac[ins->index].integer = yy * 1000 + ddd;
                    } else {
                        /* CLOCKTIME: rule 18 confirms "double precision
                         * scalar" and Appendix B says "time of day", but
                         * neither pins down a unit the way DATE's rule
                         * 17 does -- seconds since local midnight is
                         * used here, the natural "time of day as a
                         * single number" reading and consistent with
                         * RUNTIME's own seconds convention; a documented
                         * judgment call, not primary-source-confirmed
                         * the way DATE's format is. */
                        double seconds_since_midnight =
                            local_tm.tm_hour * 3600.0 + local_tm.tm_min * 60.0 + local_tm.tm_sec;
                        state->vac[ins->index].is_ref = false;
                        state->vac[ins->index].is_scalar = true;
                        state->vac[ins->index].scalar = halmat_scalar_from_double(seconds_since_midnight, true);
                    }
                    break;
                }
                if (ins->tag == 38 || ins->tag == 39) {
                    /* ERRGRP/ERRNUM: no argument, INTEGER -- "group/number
                     * of last error detected, or zero" (state.h's
                     * last_error_group/last_error_member comment). */
                    if (ins->index >= HALMAT_VAC_MAX) { fail(state, "VAC index out of range"); break; }
                    state->vac[ins->index].is_ref = false;
                    state->vac[ins->index].is_scalar = false;
                    state->vac[ins->index].integer = (ins->tag == 38) ? state->last_error_group : state->last_error_member;
                    break;
                }
                /* SIZE(23)/MAX(7)/MIN(8)/SUM(14)/PROD(20) are BI_NAME
                 * positions that turn out to never actually reach BFNC in
                 * real compiled HALMAT -- confirmed via direct compile +
                 * --disasm cross-check (see OP_LFNC's own comment above)
                 * that all five route through the separate LFNC ("L-FUNC")
                 * opcode instead, alongside the already-implemented
                 * MAX/MIN pair. No case for them appears below. */
                if (ins->operand_count < 1) { fail(state, "BFNC: expected at least 1 operand (selector %u)", ins->tag); break; }
                if (ins->index >= HALMAT_VAC_MAX) { fail(state, "VAC index out of range"); break; }
                /* DET(3)/ABVAL(28)/UNIT(27)/INVERSE(49)/TRANSPOSE(56)/
                 * TRACE(34) take a whole VECTOR/MATRIX argument and
                 * resolve it via resolve_container themselves below --
                 * resolve_operand would (correctly, per the new arrayed-
                 * paragraph-replay guard) reject a bare whole-array SYT
                 * reference outside a replay context, so it's only called
                 * for the plain-scalar-argument selectors that actually
                 * need `a` (including this batch's new two/three-argument
                 * selectors' *first* operand -- their own case bodies
                 * below resolve any further operands themselves). */
                if (ins->tag != 3 && ins->tag != 27 && ins->tag != 28 && ins->tag != 49 &&
                    ins->tag != 56 && ins->tag != 34) {
                    if (!resolve_operand(state, &ins->operands[0], &a)) break;
                }

                switch (ins->tag) {
                    case 1: case 2: case 5: case 6: case 13: case 15: case 21: case 24: case 33: case 37:
                    case 17: case 22: case 25: case 29: case 35: case 36: case 43: case 44: case 45: case 46: case 48: case 53: {
                        /* ABS/COS/EXP/LOG/SIN/TAN/SIGN/SQRT/ROUND/ARCTAN/
                         * COSH/SINH/TANH/FLOOR/ARCCOS/ARCSIN/SIGNUM/
                         * ARCCOSH/ARCSINH/ARCTANH/CEILING/TRUNCATE:
                         * through double via libm, same documented precision
                         * compromise as SEXP (no hex-float algorithm for
                         * these in the extracted AP-101S material). Domain/
                         * overflow guards on EXP/LOG/SIN/COS/TAN/SQRT below
                         * implement USA003090 App. C's group-4 "standard
                         * fixups" (errors 5-8/11-12) rather than letting
                         * libm's NaN/Inf for out-of-domain input silently
                         * propagate into the packed result -- see
                         * STATUS.md's Class 0 section for the fuller
                         * per-error trace and citation. ARCTAN needs no such
                         * guard: [USA003087] Appendix B gives it no
                         * restricted domain ("ARCTAN(α) tan-1 α", unlike
                         * ARCSIN/ARCCOS/ARCTANH's documented |α|<1 limits),
                         * and USA003090 Appendix C's error table has no
                         * ARCTAN-specific entry either (only ARCTANH/
                         * ARCTAN2 do) -- libm's plain `atan()` is total over
                         * every representable double already. */
                        double x = halmat_scalar_to_double(rv_to_scalar(&a));
                        bool dbl = rv_to_scalar(&a).double_precision;
                        double r;
                        /* Set (and `break`s out of the inner switch below)
                         * whenever a GOTO handler redirects execution away
                         * from one of these fixups -- checked once after
                         * the inner switch closes, since a plain `break`
                         * there only exits that switch, not this whole
                         * case, and no result may be written in that case
                         * (USA003087 Sec. 25.2 Figure 25-3: the
                         * interrupted expression never completes). */
                        bool redirected = false;
                        switch (ins->tag) {
                            case 1: r = fabs(x); break;
                            case 2: case 13: { /* COS/SIN: error 8 */
                                double v = (ins->tag == 2) ? cos(x) : sin(x);
                                if (fabs(x) > 823296.0) {
                                    if (!arithmetic_error_should_apply_fixup(state, HAL_S_ERROR_SIN_COS_OVERFLOW, &state->pc, &branched)) { redirected = true; break; }
                                    r = HAL_S_SIN_COS_OVERFLOW_RESULT;
                                } else {
                                    r = v;
                                }
                                break;
                            }
                            case 5: /* EXP: error 6 */
                                if (x > 174.673) {
                                    if (!arithmetic_error_should_apply_fixup(state, HAL_S_ERROR_EXP_OVERFLOW, &state->pc, &branched)) { redirected = true; break; }
                                    r = HAL_S_MAX_REPRESENTABLE;
                                } else {
                                    r = exp(x);
                                }
                                break;
                            case 6: /* LOG (natural log): error 7 */
                                if (x <= 0.0) {
                                    if (!arithmetic_error_should_apply_fixup(state, HAL_S_ERROR_LOG_NONPOSITIVE, &state->pc, &branched)) { redirected = true; break; }
                                    r = (x == 0.0) ? -HAL_S_MAX_REPRESENTABLE : log(fabs(x));
                                } else {
                                    r = log(x);
                                }
                                break;
                            case 15: { /* TAN: errors 11/12 */
                                double sp_limit = 823549.625, dp_limit = 3.537e15;
                                if (fabs(x) > (dbl ? dp_limit : sp_limit)) {
                                    /* error 11: argument magnitude too large */
                                    if (!arithmetic_error_should_apply_fixup(state, HAL_S_ERROR_TAN_OVERFLOW, &state->pc, &branched)) { redirected = true; break; }
                                    r = 1.0;
                                } else {
                                    double v = tan(x);
                                    /* error 12: argument too close to an odd
                                     * multiple of pi/2 -- rather than
                                     * replicating the primary source's own
                                     * proximity test, detect the same
                                     * condition by its effect (tan()
                                     * approaching the singularity, i.e. no
                                     * longer finite/representable). */
                                    if (!isfinite(v)) {
                                        if (!arithmetic_error_should_apply_fixup(state, HAL_S_ERROR_TAN_SINGULARITY, &state->pc, &branched)) { redirected = true; break; }
                                        r = HAL_S_MAX_REPRESENTABLE;
                                    } else {
                                        r = v;
                                    }
                                }
                                break;
                            }
                            case 21: r = (x > 0.0) ? 1.0 : (x < 0.0) ? -1.0 : 0.0; break;
                            case 24: /* SQRT: error 5 */
                                if (x < 0.0) {
                                    if (!arithmetic_error_should_apply_fixup(state, HAL_S_ERROR_SQRT_NEGATIVE, &state->pc, &branched)) { redirected = true; break; }
                                    r = sqrt(fabs(x));
                                } else {
                                    r = sqrt(x);
                                }
                                break;
                            case 33: r = round(x); break;
                            case 37: r = atan(x); break;
                            case 17: /* COSH: error 9 */
                                if (fabs(x) > 175366.0) {
                                    if (!arithmetic_error_should_apply_fixup(state, HAL_S_ERROR_SINH_COSH_OVERFLOW, &state->pc, &branched)) { redirected = true; break; }
                                    r = HAL_S_MAX_REPRESENTABLE;
                                } else {
                                    r = cosh(x);
                                }
                                break;
                            case 22: /* SINH: error 9 (odd function -- sign of x preserved in the fixup, per COSH's positive-only fixup contrasted with SINH's own sign) */
                                if (fabs(x) > 175366.0) {
                                    if (!arithmetic_error_should_apply_fixup(state, HAL_S_ERROR_SINH_COSH_OVERFLOW, &state->pc, &branched)) { redirected = true; break; }
                                    r = copysign(HAL_S_MAX_REPRESENTABLE, x);
                                } else {
                                    r = sinh(x);
                                }
                                break;
                            case 25: r = tanh(x); break; /* TANH: bounded (-1,1), no App. C entry -- no overflow possible */
                            case 29: r = floor(x); break; /* FLOOR: "largest integer <= a", no App. C entry */
                            case 35: /* ARCCOS: error 10 */
                                if (x > 1.0) {
                                    if (!arithmetic_error_should_apply_fixup(state, HAL_S_ERROR_ARCSIN_ARCCOS_DOMAIN, &state->pc, &branched)) { redirected = true; break; }
                                    r = 0.0;
                                } else if (x < -1.0) {
                                    if (!arithmetic_error_should_apply_fixup(state, HAL_S_ERROR_ARCSIN_ARCCOS_DOMAIN, &state->pc, &branched)) { redirected = true; break; }
                                    r = HAL_S_PI;
                                } else {
                                    r = acos(x);
                                }
                                break;
                            case 36: /* ARCSIN: error 10 */
                                if (x > 1.0) {
                                    if (!arithmetic_error_should_apply_fixup(state, HAL_S_ERROR_ARCSIN_ARCCOS_DOMAIN, &state->pc, &branched)) { redirected = true; break; }
                                    r = HAL_S_PI / 2.0;
                                } else if (x < -1.0) {
                                    if (!arithmetic_error_should_apply_fixup(state, HAL_S_ERROR_ARCSIN_ARCCOS_DOMAIN, &state->pc, &branched)) { redirected = true; break; }
                                    r = -HAL_S_PI / 2.0;
                                } else {
                                    r = asin(x);
                                }
                                break;
                            case 43: r = (x > 0.0) ? 1.0 : (x < 0.0) ? -1.0 : 0.0; break; /* SIGNUM: same formula as SIGN(21) -- USA003087 Appendix B distinguishes them only by SIGN having no "=0" case documented, both computed identically here */
                            case 44: /* ARCCOSH: error 59 */
                                if (x < 1.0) {
                                    if (!arithmetic_error_should_apply_fixup(state, HAL_S_ERROR_ARCCOSH_DOMAIN, &state->pc, &branched)) { redirected = true; break; }
                                    r = 0.0;
                                } else {
                                    r = acosh(x);
                                }
                                break;
                            case 45: r = asinh(x); break; /* ARCSINH: unbounded domain, no App. C entry */
                            case 46: /* ARCTANH: error 60 -- guard uses >= 1 rather than the documented >1, since libm's atanh(±1) is +-Inf and this project has already hit (and fixed) a real hang from an unguarded Inf reaching halmat_scalar_from_double's normalization loop (see error 4's SEXP fix, STATUS.md) */
                                if (fabs(x) >= 1.0) {
                                    if (!arithmetic_error_should_apply_fixup(state, HAL_S_ERROR_ARCTANH_DOMAIN, &state->pc, &branched)) { redirected = true; break; }
                                    r = 0.0;
                                } else {
                                    r = atanh(x);
                                }
                                break;
                            case 48: r = ceil(x); break; /* CEILING: "smallest integer > a", no App. C entry */
                            case 53: r = trunc(x); break; /* TRUNCATE: "largest integer <= |a| times SIGNUM(integer(a))" == truncation toward zero */
                            default: r = round(x); break;
                        }
                        if (redirected) break;
                        state->vac[ins->index].is_ref = false;
                        state->vac[ins->index].is_scalar = true;
                        state->vac[ins->index].scalar = halmat_scalar_from_double(r, dbl);
                        break;
                    }
                    case 3: { /* DET: matrix determinant -> SCALAR */
                        halmat_scalar_t *ca; size_t count; int rows, cols;
                        if (!resolve_container(state, &ins->operands[0], &ca, &count, &rows, &cols)) break;
                        if (rows <= 0 || cols <= 0 || rows != cols) { fail(state, "DET: operand is not a square MATRIX"); break; }
                        if (count > HALMAT_CONTAINER_CAPACITY) { fail(state, "DET: container too large"); break; }
                        bool dbl = false;
                        for (size_t i = 0; i < count; i++) {
                            if (ca[i].double_precision) { dbl = true; break; }
                        }
                        state->vac[ins->index].is_ref = false;
                        state->vac[ins->index].is_scalar = true;
                        state->vac[ins->index].scalar = matrix_determinant(ca, rows, dbl);
                        break;
                    }
                    case 28: { /* ABVAL: vector magnitude -> SCALAR */
                        halmat_scalar_t *ca; size_t count; int rows, cols;
                        if (!resolve_container(state, &ins->operands[0], &ca, &count, &rows, &cols)) break;
                        halmat_scalar_t sum = halmat_scalar_zero(false);
                        for (size_t i = 0; i < count; i++) sum = halmat_scalar_add(sum, halmat_scalar_multiply(ca[i], ca[i]));
                        double mag = sqrt(halmat_scalar_to_double(sum));
                        state->vac[ins->index].is_ref = false;
                        state->vac[ins->index].is_scalar = true;
                        state->vac[ins->index].scalar = halmat_scalar_from_double(mag, false);
                        break;
                    }
                    case 27: { /* UNIT: normalize -> VECTOR */
                        halmat_scalar_t *ca; size_t count; int rows, cols;
                        if (!resolve_container(state, &ins->operands[0], &ca, &count, &rows, &cols)) break;
                        if (count > HALMAT_CONTAINER_CAPACITY) { fail(state, "UNIT: container too large"); break; }
                        halmat_scalar_t sum = halmat_scalar_zero(false);
                        for (size_t i = 0; i < count; i++) sum = halmat_scalar_add(sum, halmat_scalar_multiply(ca[i], ca[i]));
                        double mag = sqrt(halmat_scalar_to_double(sum));
                        halmat_scalar_t result[HALMAT_CONTAINER_CAPACITY];
                        if (mag == 0.0) {
                            /* USA003090 App. C error 28 ("argument of UNIT
                             * function is null vector"): standard fixup is
                             * a result vector "all of whose components are
                             * zero (i.e. the input vector)" -- every
                             * component of a null vector is already zero,
                             * so this is just the input passed through
                             * unnormalized rather than a division-by-zero
                             * abort. Unless a GOTO handler is registered
                             * for it, in which case execution redirects
                             * there and UNIT produces no result at all. */
                            if (!arithmetic_error_should_apply_fixup(state, HAL_S_ERROR_UNIT_NULL_VECTOR, &state->pc, &branched)) break;
                            for (size_t i = 0; i < count; i++) result[i] = ca[i];
                        } else {
                            for (size_t i = 0; i < count; i++) {
                                result[i] = halmat_scalar_from_double(halmat_scalar_to_double(ca[i]) / mag, false);
                            }
                        }
                        if (!store_container_result(state, ins->index, result, count, rows, cols)) break;
                        break;
                    }
                    case 40: /* LENGTH: CHARACTER length -> INTEGER */
                        if (a.kind != RV_STRING) { fail(state, "LENGTH: operand is not CHARACTER"); break; }
                        state->vac[ins->index].is_ref = false;
                        state->vac[ins->index].is_scalar = false;
                        state->vac[ins->index].integer = (int32_t)strlen(a.string);
                        break;
                    case 26: /* TRIM: strip trailing blanks -> CHARACTER */
                        if (a.kind != RV_STRING) { fail(state, "TRIM: operand is not CHARACTER"); break; }
                        {
                            size_t len = strlen(a.string);
                            while (len > 0 && a.string[len - 1] == ' ') len--;
                            char *trimmed = malloc(len + 1);
                            memcpy(trimmed, a.string, len);
                            trimmed[len] = '\0';
                            state->vac[ins->index].is_ref = false;
                            state->vac[ins->index].is_string = true;
                            state->vac[ins->index].string = trimmed;
                        }
                        break;
                    case 49: { /* INVERSE: matrix inverse, same algorithm as MINV */
                        halmat_scalar_t *ca; size_t count; int rows, cols;
                        if (!resolve_container(state, &ins->operands[0], &ca, &count, &rows, &cols)) break;
                        if (rows <= 0 || cols <= 0 || rows != cols) { fail(state, "INVERSE: operand is not a square MATRIX"); break; }
                        if (count > HALMAT_CONTAINER_CAPACITY) { fail(state, "INVERSE: container too large"); break; }
                        halmat_scalar_t result[HALMAT_CONTAINER_CAPACITY];
                        if (!matrix_invert(ca, rows, result)) {
                            /* USA003090 App. C error 27 ("argument of
                             * INVERSE is a singular matrix"): standard
                             * fixup is the identity matrix, not an abort
                             * -- unless a GOTO handler is registered for
                             * it (ON ERROR$(4:27) ...), in which case
                             * execution redirects there instead and this
                             * BFNC call produces no result at all. */
                            if (!arithmetic_error_should_apply_fixup(state, HAL_S_ERROR_INVERSE_SINGULAR, &state->pc, &branched)) break;
                            fill_identity_matrix(ca, rows, result);
                        }
                        if (!store_container_result(state, ins->index, result, count, rows, cols)) break;
                        break;
                    }
                    case 56: { /* TRANSPOSE: matrix transpose -> MATRIX */
                        halmat_scalar_t *ca; size_t count; int rows, cols;
                        if (!resolve_container(state, &ins->operands[0], &ca, &count, &rows, &cols)) break;
                        if (rows <= 0 || cols <= 0) { fail(state, "TRANSPOSE: operand is not a MATRIX"); break; }
                        if (count > HALMAT_CONTAINER_CAPACITY) { fail(state, "TRANSPOSE: container too large"); break; }
                        halmat_scalar_t result[HALMAT_CONTAINER_CAPACITY];
                        for (int r = 0; r < rows; r++)
                            for (int c = 0; c < cols; c++)
                                result[(size_t)c * rows + r] = ca[(size_t)r * cols + c];
                        if (!store_container_result(state, ins->index, result, count, cols, rows)) break;
                        break;
                    }
                    case 34: { /* TRACE: sum of diagonal elements of a square MATRIX -> SCALAR */
                        halmat_scalar_t *ca; size_t count; int rows, cols;
                        if (!resolve_container(state, &ins->operands[0], &ca, &count, &rows, &cols)) break;
                        if (rows <= 0 || cols <= 0 || rows != cols) { fail(state, "TRACE: operand is not a square MATRIX"); break; }
                        halmat_scalar_t sum = halmat_scalar_zero(false);
                        for (int i = 0; i < rows; i++) sum = halmat_scalar_add(sum, ca[(size_t)i * cols + i]);
                        state->vac[ins->index].is_ref = false;
                        state->vac[ins->index].is_scalar = true;
                        state->vac[ins->index].scalar = sum;
                        break;
                    }
                    case 47: { /* ARCTAN2(α,β): atan2(α,β) per Appendix B's "α=k sinθ, β=k cosθ" convention -> SCALAR angle */
                        if (ins->operand_count != 2) { fail(state, "ARCTAN2: expected 2 operands"); break; }
                        resolved_value_t b2;
                        if (!resolve_operand(state, &ins->operands[1], &b2)) break;
                        double alpha = halmat_scalar_to_double(rv_to_scalar(&a));
                        double beta = halmat_scalar_to_double(rv_to_scalar(&b2));
                        bool dbl2 = rv_to_scalar(&a).double_precision || rv_to_scalar(&b2).double_precision;
                        double r;
                        if (alpha == 0.0 && beta == 0.0) {
                            /* error 62: libm's atan2(0,0) already returns 0.0,
                             * satisfying the documented fixup on its own --
                             * still routed through arithmetic_error_should_
                             * apply_fixup so ERRGRP/ERRNUM and any registered
                             * ON ERROR$(4:62) handler still see/react to it. */
                            if (!arithmetic_error_should_apply_fixup(state, HAL_S_ERROR_ARCTAN2_ZERO, &state->pc, &branched)) break;
                            r = 0.0;
                        } else {
                            r = atan2(alpha, beta);
                        }
                        state->vac[ins->index].is_ref = false;
                        state->vac[ins->index].is_scalar = true;
                        state->vac[ins->index].scalar = halmat_scalar_from_double(r, dbl2);
                        break;
                    }
                    case 4: { /* DIV(α,β): integer division α/β, both arguments rounded to integers first -> INTEGER */
                        if (ins->operand_count != 2) { fail(state, "DIV: expected 2 operands"); break; }
                        resolved_value_t b2;
                        if (!resolve_operand(state, &ins->operands[1], &b2)) break;
                        int32_t alpha = rv_to_integer(&a), beta = rv_to_integer(&b2);
                        if (beta == 0) { fail(state, "DIV: division by zero (no App. C fixup documented for this selector)"); break; }
                        state->vac[ins->index].is_ref = false;
                        state->vac[ins->index].is_scalar = false;
                        state->vac[ins->index].integer = alpha / beta;
                        break;
                    }
                    case 9: { /* MOD(α,β): floor-based real modulo, α - β*floor(α/β) -- SCALAR (unlike DIV/REMAINDER, Appendix B doesn't say MOD's arguments are rounded to integers) */
                        if (ins->operand_count != 2) { fail(state, "MOD: expected 2 operands"); break; }
                        resolved_value_t b2;
                        if (!resolve_operand(state, &ins->operands[1], &b2)) break;
                        double alpha = halmat_scalar_to_double(rv_to_scalar(&a));
                        double beta = halmat_scalar_to_double(rv_to_scalar(&b2));
                        bool dbl2 = rv_to_scalar(&a).double_precision || rv_to_scalar(&b2).double_precision;
                        double r;
                        if (beta == 0.0) {
                            if (alpha < 0.0) {
                                /* error 19 */
                                if (!arithmetic_error_should_apply_fixup(state, HAL_S_ERROR_MOD_DOMAIN, &state->pc, &branched)) break;
                                r = 0.0;
                            } else {
                                r = alpha; /* alpha>=0, beta==0: no App. C row covers this branch -- the natural "a mod 0 = a" limit */
                            }
                        } else {
                            double mag_limit = dbl2 ? 7.2058e16 /* ~16**14 */ : 1.6777e7 /* ~16**6 */;
                            if (fabs(alpha / beta) > mag_limit) {
                                /* error 33 */
                                if (!arithmetic_error_should_apply_fixup(state, HAL_S_ERROR_MOD_MAGNITUDE, &state->pc, &branched)) break;
                                r = 0.0;
                            } else {
                                r = alpha - beta * floor(alpha / beta);
                            }
                        }
                        state->vac[ins->index].is_ref = false;
                        state->vac[ins->index].is_scalar = true;
                        state->vac[ins->index].scalar = halmat_scalar_from_double(r, dbl2);
                        break;
                    }
                    case 55: { /* REMAINDER(α,β): signed remainder of integer division α/β, arguments rounded to integers -> INTEGER */
                        if (ins->operand_count != 2) { fail(state, "REMAINDER: expected 2 operands"); break; }
                        resolved_value_t b2;
                        if (!resolve_operand(state, &ins->operands[1], &b2)) break;
                        int32_t alpha = rv_to_integer(&a), beta = rv_to_integer(&b2);
                        int32_t r;
                        if (beta == 0) {
                            /* error 16: "the result is set to A" */
                            if (!arithmetic_error_should_apply_fixup(state, HAL_S_ERROR_REMAINDER_DIVIDE_BY_ZERO, &state->pc, &branched)) break;
                            r = alpha;
                        } else {
                            r = alpha % beta;
                        }
                        state->vac[ins->index].is_ref = false;
                        state->vac[ins->index].is_scalar = false;
                        state->vac[ins->index].integer = r;
                        break;
                    }
                    case 41: { /* MIDVAL(α,β,γ): the argument algebraically between the other two -- "result is always scalar" (Appendix B, explicit) */
                        if (ins->operand_count != 3) { fail(state, "MIDVAL: expected 3 operands"); break; }
                        resolved_value_t b2, c2;
                        if (!resolve_operand(state, &ins->operands[1], &b2)) break;
                        if (!resolve_operand(state, &ins->operands[2], &c2)) break;
                        double x1 = halmat_scalar_to_double(rv_to_scalar(&a));
                        double x2 = halmat_scalar_to_double(rv_to_scalar(&b2));
                        double x3 = halmat_scalar_to_double(rv_to_scalar(&c2));
                        bool dbl2 = rv_to_scalar(&a).double_precision || rv_to_scalar(&b2).double_precision || rv_to_scalar(&c2).double_precision;
                        double r = fmax(fmin(x1, x2), fmin(fmax(x1, x2), x3)); /* standard median-of-three formula */
                        state->vac[ins->index].is_ref = false;
                        state->vac[ins->index].is_scalar = true;
                        state->vac[ins->index].scalar = halmat_scalar_from_double(r, dbl2);
                        break;
                    }
                    case 11: case 12: { /* SHL/SHR(α,β): shift α's integer bit-pattern left/right by β bits, β clamped to [0,63] (Appendix B) -> INTEGER */
                        if (ins->operand_count != 2) { fail(state, "SHL/SHR: expected 2 operands"); break; }
                        resolved_value_t b2;
                        if (!resolve_operand(state, &ins->operands[1], &b2)) break;
                        int32_t alpha = rv_to_integer(&a);
                        int32_t shift = rv_to_integer(&b2);
                        if (shift < 0) shift = 0;
                        if (shift > 63) shift = 63;
                        int32_t r;
                        if (shift >= 32) {
                            /* Beyond this emulator's actual 32-bit INTEGER
                             * width -- saturate rather than invoke C's
                             * shift-amount->=width undefined behavior. */
                            r = (ins->tag == 12 && alpha < 0) ? -1 : 0;
                        } else if (ins->tag == 11) {
                            r = (int32_t)((uint32_t)alpha << shift); /* logical left shift over the raw bit pattern, avoiding signed-overflow UB */
                        } else {
                            r = alpha >> shift; /* arithmetic (sign-propagating) right shift, per Appendix B's "SHR is an arithmetic shift" -- implementation-defined in C99 but universal on every real target this project builds for */
                        }
                        state->vac[ins->index].is_ref = false;
                        state->vac[ins->index].is_scalar = false;
                        state->vac[ins->index].integer = r;
                        break;
                    }
                    case 16: { /* XOR(α,β): bitwise exclusive-or of two BIT strings -> BIT ([USA003087] Appendix B "BIT FUNCTIONS") */
                        if (ins->operand_count != 2) { fail(state, "XOR: expected 2 operands"); break; }
                        resolved_value_t b2;
                        if (!resolve_operand(state, &ins->operands[1], &b2)) break;
                        if (a.kind != RV_BITS || b2.kind != RV_BITS) { fail(state, "XOR: both operands must be BIT"); break; }
                        state->vac[ins->index].is_ref = false;
                        state->vac[ins->index].is_bits = true;
                        state->vac[ins->index].bits = a.bits ^ b2.bits;
                        break;
                    }
                    case 30: { /* INDEX(α,β): 1-based index of the first occurrence of string β within α, or 0 if absent -> INTEGER */
                        if (ins->operand_count != 2) { fail(state, "INDEX: expected 2 operands"); break; }
                        resolved_value_t b2;
                        if (!resolve_operand(state, &ins->operands[1], &b2)) break;
                        if (a.kind != RV_STRING || b2.kind != RV_STRING) { fail(state, "INDEX: both operands must be CHARACTER"); break; }
                        const char *found = strstr(a.string, b2.string);
                        state->vac[ins->index].is_ref = false;
                        state->vac[ins->index].is_scalar = false;
                        state->vac[ins->index].integer = found ? (int32_t)(found - a.string) + 1 : 0;
                        break;
                    }
                    case 31: case 32: { /* LJUST/RJUST(α,β): pad/truncate CHARACTER α to length β -> CHARACTER */
                        if (ins->operand_count != 2) { fail(state, "LJUST/RJUST: expected 2 operands"); break; }
                        resolved_value_t b2;
                        if (!resolve_operand(state, &ins->operands[1], &b2)) break;
                        if (a.kind != RV_STRING) { fail(state, "LJUST/RJUST: first operand must be CHARACTER"); break; }
                        int32_t want_len = rv_to_integer(&b2);
                        if (want_len < 0) want_len = 0;
                        size_t src_len = strlen(a.string);
                        bool is_ljust = (ins->tag == 31);
                        if ((size_t)want_len < src_len) {
                            /* error 18: bad length -- truncation to the
                             * specified length occurs, dropping characters
                             * on the right (LJUST keeps the left portion)
                             * or the left (RJUST keeps the right portion). */
                            if (!arithmetic_error_should_apply_fixup(state, HAL_S_ERROR_LJUST_RJUST_BAD_LENGTH, &state->pc, &branched)) break;
                        }
                        char *result = malloc((size_t)want_len + 1);
                        size_t keep = (size_t)want_len < src_len ? (size_t)want_len : src_len;
                        if (is_ljust) {
                            memcpy(result, a.string, keep);
                            for (size_t i = keep; i < (size_t)want_len; i++) result[i] = ' ';
                        } else {
                            size_t pad = (size_t)want_len - keep;
                            for (size_t i = 0; i < pad; i++) result[i] = ' ';
                            memcpy(result + pad, a.string + (src_len - keep), keep);
                        }
                        result[want_len] = '\0';
                        state->vac[ins->index].is_ref = false;
                        state->vac[ins->index].is_string = true;
                        state->vac[ins->index].string = result;
                        break;
                    }
                    case 10: { /* ODD(α): BOOLEAN (BIT) -- 1 if the rounded-to-integer α is odd, else 0 */
                        int32_t v = rv_to_integer(&a);
                        state->vac[ins->index].is_ref = false;
                        state->vac[ins->index].is_bits = true;
                        state->vac[ins->index].bits = (uint32_t)(v & 1);
                        break;
                    }
                    default:
                        fail(state, "BFNC: unknown/unimplemented built-in function selector %u", ins->tag);
                        break;
                }
                break;
            }

            case OP_XXST: {
                /* General bracketed-argument-list start: I/O (IMD kind
                 * code) or a function/procedure call (SYT callee) --
                 * see class-0/XXST.md. Two reasons io_pending can already
                 * be active here: (1) this exact XXST instruction is
                 * being re-entered mid-ADLP/DLPE-driven replay (a whole-
                 * array/structure-field WRITE argument, e.g.
                 * `WRITE(6) ZQ3.QI;` on a multi-copy structure, compiles
                 * with XXST itself inside the replayed paragraph) --
                 * state->pc == io_pending.start_pc identifies this case,
                 * and it must keep accumulating into the same item list
                 * rather than wiping it; or (2) this is a genuinely
                 * different, nested XXST (e.g. `WRITE(6) I, SQUARE(I);`,
                 * where SQUARE(I)'s own call brackets sit inside WRITE's
                 * argument list -- source-documentation/Multiple-file-
                 * problem.md's reproduction case), which must push the
                 * enclosing frame onto io_pending_stack and start a fresh
                 * one, so the nested call's own XXAR/FCAL/XXND see their
                 * own frame instead of corrupting the outer one. */
                if (ins->operand_count != 1) { fail(state, "XXST: expected 1 operand"); break; }
                bool replay = state->io_pending.active && state->io_pending.start_pc == state->pc;
                if (!replay) {
                    if (state->io_pending.active) {
                        if (state->io_pending_sp >= 8) { fail(state, "XXST nesting too deep"); break; }
                        state->io_pending_stack[state->io_pending_sp++] = state->io_pending;
                        /* The enclosing frame's own items buffer (just
                         * saved above, by value) is now owned by the
                         * stack slot -- this new, genuinely nested frame
                         * must start with its own fresh buffer, not
                         * accidentally alias the just-saved one (state.h's
                         * halmat_io_item_t comment). */
                        state->io_pending.items = NULL;
                        state->io_pending.items_capacity = 0;
                    }
                    state->io_pending.active = true;
                    state->io_pending.item_count = 0;
                    state->io_pending.has_skip = false;
                    state->io_pending.has_column = false;
                    state->io_pending.start_pc = state->pc;
                    if (ins->operands[0].qual == QUAL_SYT) {
                        state->io_pending.is_call = true;
                        state->io_pending.call_target = ins->operands[0].data;
                    } else {
                        if (!resolve_operand(state, &ins->operands[0], &a)) break;
                        state->io_pending.is_call = false;
                        state->io_pending.kind = rv_to_integer(&a);
                    }
                }
                break;
            }

            case OP_XXAR:
                if (!state->io_pending.active) { fail(state, "XXAR outside of an XXST...XXND block"); break; }
                if (ins->operand_count != 1) { fail(state, "XXAR: expected 1 operand"); break; }
                if (!io_pending_reserve_item(state)) break;
                state->io_pending.items[state->io_pending.item_count].is_ioctl = false; /* stale-flag
                    clear, same reason as is_container/is_bit_array/is_char_array below --
                    items[] slots are reused across statements without zeroing, and only the
                    new WRITE-context ioctl branch just below ever sets this true */
                if (!state->io_pending.is_call && state->io_pending.kind != 2) {
                    /* READ/READALL: the argument is a destination, not a
                     * value -- capture the raw operand for OP_READ to
                     * write through later, per class-0/XXAR.md. TAG2 != 0
                     * means an I/O control specifier (TAB/COLUMN/SKIP/
                     * LINE/PAGE); TAG1 outside {2=CHARACTER,5=SCALAR,
                     * 6=INTEGER} means a type this interpreter doesn't
                     * store yet as a single field (BIT/structure) -- fails
                     * loudly rather than misbehave, no fixture needs them
                     * yet. (CHARACTER matters in practice: real HAL/S's
                     * READALL requires CHARACTER-typed targets -- confirmed
                     * via a real HALSFC compile rejecting an INTEGER/SCALAR
                     * READALL with "VARIABLE IN READALL IS NOT OF
                     * CHARACTER TYPE".) */
                    if (ins->operands[0].tag2 != 0) {
                        /* I/O control specifier (class-0/XXAR.md's
                         * confirmed TAG2 encoding: 1=TAB, 2=COLUMN,
                         * 3=SKIP, 4=LINE, 5=PAGE) -- a specifier in its
                         * own right, not a real destination, so captured
                         * into io_pending's dedicated has_skip/skip_n /
                         * has_column/column_n fields (state.h) instead of
                         * items[]/item_count. Only SKIP/COLUMN are
                         * implemented, applied by OP_READ/OP_RDAL before
                         * processing the ordinary destination items --
                         * user-reported (164-OUTER.hal's `READ(INFILE)
                         * SKIP(0), COLUMN(9), PHI;` idiom). TAB/LINE/PAGE
                         * have no confirmed READ-context meaning tested
                         * against any fixture or corpus program, so they
                         * still fail loudly rather than guessing. */
                        if (ins->operands[0].tag2 != 2 && ins->operands[0].tag2 != 3) {
                            fail(state, "READ: TAB/LINE/PAGE control specifiers are not yet implemented");
                            break;
                        }
                        if (!resolve_operand(state, &ins->operands[0], &a)) break;
                        int32_t n = rv_to_integer(&a);
                        if (ins->operands[0].tag2 == 3) {
                            state->io_pending.has_skip = true;
                            state->io_pending.skip_n = n;
                        } else {
                            state->io_pending.has_column = true;
                            state->io_pending.column_n = n;
                        }
                        break;
                    }
                    uint8_t cls = ins->operands[0].tag1;
                    /* Whole VECTOR(4)/MATRIX(3) READ destination -- same
                     * unreplayed QUAL=SYT/TAG1=class shape as the WRITE/
                     * CALL whole-container case below (class-0/XXAR.md's
                     * "Whole VECTOR/MATRIX/ARRAY argument" section), not
                     * wrapped in an ADLP/DLPE per-element replay the way a
                     * whole ARRAY is -- so `state->arrayed_index < 0` here
                     * genuinely means "this XXAR names the whole
                     * container," not merely "no replay is active yet."
                     * USA003087 Sec. 12.3's "[a] vector data item causes
                     * one data field per vector element to be read... [a]
                     * matrix... row by row" (the same unrolled order as
                     * WRITE output/INITIAL) governs the field count; OP_READ
                     * does the actual per-element unrolling. User-reported
                     * (044-ORTHONORMAL.hal's `READ(5) X;`, X a VECTOR(3)). */
                    if ((cls == 3 || cls == 4) && ins->operands[0].qual == QUAL_SYT &&
                        state->arrayed_index < 0 && syt_is_array_shaped(state, ins->operands[0].data)) {
                        state->io_pending.items[state->io_pending.item_count].dest_operand = ins->operands[0];
                        state->io_pending.items[state->io_pending.item_count].dest_is_container = true;
                        state->io_pending.items[state->io_pending.item_count].dest_is_structure = false;
                        state->io_pending.item_count++;
                        break;
                    }
                    if (cls == 10 && ins->operands[0].qual == QUAL_XPT) {
                        if (ins->operands[0].data >= HALMAT_VAC_MAX) { fail(state, "READ: XPT stream position out of range"); break; }
                        const halmat_vac_slot_t *sref = &state->vac[ins->operands[0].data];
                        if (!sref->is_struct_ref) { fail(state, "READ: XPT operand does not reference an EXTN result"); break; }
                        /* Bare/unqualified structure reference: EXTN's own
                         * struct_field_syt IS the template symbol itself
                         * for this case (not a real field) -- confirmed by
                         * checking the symbol table's own hal_class for
                         * it, 0x3E, the TEMPLATE DEFINITION's own class
                         * marker (distinct from 0x0A/MAJ_STRUC, which is
                         * an *instance* variable's class -- e.g. ARG's own
                         * entry -- confirmed empirically against two
                         * different real templates' own COMMON0.out dumps,
                         * 172-OUTER.hal's UTIL_PARM and 167-ASSORTEDIO.
                         * hal's IOPARM, both SYM_TYPE=3E on the template
                         * symbol itself), the same signal a qualified
                         * single-field reference could never produce. */
                        const halmat_symtab_entry_t *tsym = state->symtab ? halmat_symtab_find_by_index(state->symtab, sref->struct_field_syt) : NULL;
                        if (!tsym || tsym->hal_class != 0x3E) {
                            fail(state, "READ: structure argument must be a whole (unqualified) structure reference");
                            break;
                        }
                        state->io_pending.items[state->io_pending.item_count].dest_is_structure = true;
                        state->io_pending.items[state->io_pending.item_count].dest_is_container = false;
                        state->io_pending.items[state->io_pending.item_count].struct_base_syt = sref->struct_base_syt;
                        state->io_pending.items[state->io_pending.item_count].struct_template_syt = sref->struct_field_syt;
                        state->io_pending.items[state->io_pending.item_count].struct_copy_index = sref->struct_copy_index;
                        state->io_pending.item_count++;
                        break;
                    }
                    if (cls != 2 && cls != 5 && cls != 6) {
                        fail(state, "READ: only CHARACTER/SCALAR/INTEGER arguments are implemented (got HALMAT class %u)", cls);
                        break;
                    }
                    state->io_pending.items[state->io_pending.item_count].dest_operand = ins->operands[0];
                    state->io_pending.items[state->io_pending.item_count].dest_class = cls;
                    state->io_pending.items[state->io_pending.item_count].dest_is_container = false; /* items[]
                        * slots are reused across READ statements without zeroing -- a stale true from a
                        * previous statement's whole-container item at this same slot must be cleared,
                        * same convention as the WRITE-side is_container reset just below. */
                    state->io_pending.items[state->io_pending.item_count].dest_is_structure = false;
                    state->io_pending.item_count++;
                    break;
                }
                if (state->io_pending.kind == 2 && !state->io_pending.is_call && ins->operands[0].tag2 != 0) {
                    /* WRITE-context I/O control specifier (class-0/XXAR.md's
                     * confirmed TAG2 encoding, same as the READ/READALL
                     * case above: 1=TAB, 2=COLUMN, 3=SKIP, 4=LINE, 5=PAGE)
                     * -- user-reported: these previously fell straight
                     * through to the ordinary "resolve and print as a data
                     * value" path below (this whole check simply didn't
                     * exist for WRITE), so `WRITE(6) SKIP(0), C1,
                     * COLUMN(20), C2;` printed the literal numbers 0 and 20
                     * as ordinary INTEGER fields instead of repositioning
                     * anything. Unlike READ/READALL's simpler has_skip/
                     * has_column pre-pass fields (only ever applied once,
                     * before any destination item), these can appear
                     * *anywhere* in a WRITE's item list, interleaved with
                     * ordinary data items (USA003087 Sec. 12.4: "[i]f a TAB
                     * or COLUMN appears between two expressions in a WRITE
                     * statement, it overrides the standard data field
                     * separation" -- SKIP/LINE/PAGE have the equivalent
                     * vertical-movement version of this same rule) -- so
                     * captured as an ordinary items[]/item_count entry
                     * (is_ioctl, state.h) instead, applied in original
                     * sequence by flush_write (interp.c). */
                    if (!resolve_operand(state, &ins->operands[0], &a)) break;
                    state->io_pending.items[state->io_pending.item_count].is_ioctl = true;
                    state->io_pending.items[state->io_pending.item_count].ioctl_kind = ins->operands[0].tag2;
                    state->io_pending.items[state->io_pending.item_count].ioctl_n = rv_to_integer(&a);
                    state->io_pending.item_count++;
                    break;
                }
                /* ASSIGN-form CALL argument (class-0/XXST.md's `CALL
                 * TWO(I1) ASSIGN(I1);` trace, state.h's is_assign
                 * comment): still captured/bound exactly like an ordinary
                 * argument below (by-value positional binding doesn't
                 * change), just additionally marked so OP_XXND can write
                 * the callee's corresponding parameter's final value back
                 * into this operand once the call returns. */
                bool is_assign_arg = state->io_pending.is_call && ins->operands[0].tag2 != 0;
                if ((state->io_pending.kind == 2 || state->io_pending.is_call) &&
                    ins->operands[0].tag1 == 10 && ins->operands[0].qual == QUAL_XPT) {
                    /* Whole (bare/unqualified) STRUCTURE WRITE/CALL
                     * argument (TAG1=10/MAJ_STRUC) -- the WRITE/CALL-side
                     * mirror of OP_XXAR's own READ/READALL dest_is_structure
                     * case above (state.h's is_structure comment): not
                     * wrapped in an ADLP/DLPE replay any more than the
                     * READ-side XPT reference is, so this is always the
                     * whole structure, unconditionally. Validated the same
                     * way (bare EXTN reference confirmed via the template
                     * symbol's own hal_class==0x3E marker). flush_write
                     * (WRITE) and bind_call_argument (CALL) both walk the
                     * template's own struct_first_field/struct_next_field
                     * chain to emit/copy each terminal, mirroring OP_READ's
                     * own walk. User-reported, 172-OUTER.hal's `WRITE(6)
                     * ARG;` and `UTIL(ARG)` (previously fell through to the
                     * generic resolve_operand/resolve_xpt_field path below,
                     * which resolves the *template* symbol itself as a
                     * bogus scalar "field" READ never populates -- printing/
                     * passing zero regardless of ARG's real contents). */
                    if (ins->operands[0].data >= HALMAT_VAC_MAX) { fail(state, "WRITE/CALL: XPT stream position out of range"); break; }
                    const halmat_vac_slot_t *sref = &state->vac[ins->operands[0].data];
                    if (!sref->is_struct_ref) { fail(state, "WRITE/CALL: XPT operand does not reference an EXTN result"); break; }
                    const halmat_symtab_entry_t *tsym = state->symtab ? halmat_symtab_find_by_index(state->symtab, sref->struct_field_syt) : NULL;
                    if (!tsym || tsym->hal_class != 0x3E) {
                        fail(state, "WRITE/CALL: structure argument must be a whole (unqualified) structure reference");
                        break;
                    }
                    state->io_pending.items[state->io_pending.item_count].is_container = false; /* stale-flag
                        clear, same reason as elsewhere in this function */
                    state->io_pending.items[state->io_pending.item_count].is_bit_array = false;
                    state->io_pending.items[state->io_pending.item_count].is_char_array = false;
                    state->io_pending.items[state->io_pending.item_count].is_structure = true;
                    state->io_pending.items[state->io_pending.item_count].struct_base_syt = sref->struct_base_syt;
                    state->io_pending.items[state->io_pending.item_count].struct_template_syt = sref->struct_field_syt;
                    /* Eagerly resolved here (not left as sref's own -1
                     * "ambient" marker) -- user-reported
                     * (yahalmat2_assign_array_struct_element;
                     * 180-EXAMPLE_N.hal's `CALL SELECT_BEST(VEL);`, VEL a
                     * `SUPER_VECTOR-STRUCTURE(3)` replayed via ADLP/DLPE,
                     * one XXAR capture per copy): a bare EXTN reference's
                     * own struct_copy_index is always -1 by design
                     * (state.h's own comment -- deferred resolution is
                     * the right default for an ordinary field *read*,
                     * re-evaluated fresh each time it's consulted), but
                     * this io_pending item is a *captured snapshot* meant
                     * to be consumed later, once this call's own PCAL/
                     * FCAL/XXND finally runs -- by which point the ADLP
                     * replay that resolved this XXAR is long over and
                     * state->arrayed_index has already reverted to -1,
                     * so current_copy_index() at bind time always came
                     * back 0 regardless of which replay pass captured
                     * this particular item (confirmed via direct
                     * instrumentation: all 3 replay-captured items showed
                     * src_copy=0). Resolving now, while arrayed_index
                     * still reflects the copy actually being captured,
                     * fixes this permanently; reduces to the previous
                     * value (0) for a genuinely non-replayed single-copy
                     * structure argument like 172-OUTER.hal's
                     * `UTIL(ARG)`, since current_copy_index() is 0
                     * outside any replay too. */
                    state->io_pending.items[state->io_pending.item_count].struct_copy_index =
                        sref->struct_copy_index >= 0 ? sref->struct_copy_index : current_copy_index(state);
                    state->io_pending.items[state->io_pending.item_count].is_assign = is_assign_arg;
                    state->io_pending.items[state->io_pending.item_count].dest_operand = ins->operands[0];
                    state->io_pending.item_count++;
                    break;
                }
                /* A VAC operand already marked is_container (SSHP/VSHP/
                 * MSHP/ISHP, VADD/VSUB/MADD/MSUB, a DSUB asterisk-select,
                 * etc.) is unambiguously a whole-container *value* -- there
                 * is no "per-element replay" reading of it the way a plain
                 * SYT ARRAY reference can be ambiguous between "the whole
                 * array" and "one element, index from arrayed_index"
                 * (whole_syt's own case just below, which the arrayed_index
                 * < 0 guard genuinely needs to disambiguate). So this
                 * bypasses that guard entirely -- user-reported
                 * (120-EXAMPLE_A.hal's `CALL EXAMPLE_A(SCALAR(9800, 9900,
                 * 10000, 10100), ...)`: the SCALAR(...) shaping-function's
                 * own SSHP result, fed to the ALT parameter via an XXAR the
                 * compiler wraps in an ADLP(4)/DLPE exactly like a plain
                 * per-element ARRAY argument would be -- previously fell
                 * through to the ordinary per-element resolve_operand path
                 * below on every replay pass since arrayed_index was
                 * already >= 0 by the time this XXAR first ran, and
                 * resolve_operand's QUAL_VAC case has no is_container
                 * fallback at all, silently leaving ALT/TIMETAG's SYT
                 * storage at its zero-initialized default -- corrupting
                 * every element of this call's own IF-condition checks
                 * (`ALT(J) <= 0` reading 0.0 unconditionally true) with no
                 * error at all). Capturing the same already-computed whole
                 * container once per replay pass is redundant but harmless
                 * (idempotent), the same tolerance this file's own ADLP/
                 * DLPE precompute step already documents elsewhere. */
                bool whole_vac_container = ins->operands[0].qual == QUAL_VAC && ins->operands[0].data < HALMAT_VAC_MAX &&
                                            state->vac[ins->operands[0].data].is_container;
                if (whole_vac_container && state->arrayed_index > 0) {
                    /* Already captured on this same XXAR's first pass
                     * (arrayed_index <= 0, i.e. either no replay or the
                     * replay's own first iteration) -- unlike a plain SYT
                     * ARRAY reference (which genuinely means something
                     * different on each replay pass: element N, not "the
                     * whole array" again), a VAC container's own value is
                     * fixed for the whole replay, so passes 2+ must NOT
                     * append a second (or third, or Nth) duplicate items[]
                     * entry -- that would misalign every later argument's
                     * own item_index against its real parameter position. */
                    break;
                }
                /* A plain ARRAY (including ARRAY-of-VECTOR) *CALL* argument
                 * -- as opposed to a whole VECTOR/MATRIX argument, whole_syt's
                 * own case just below, which is NOT replayed -- *is* wrapped
                 * in an ADLP/DLPE replay by the compiler, confirmed via
                 * 134-DOTS.hal's own real HALMAT: `CALL DOTS(V1, V2)`, V1/V2
                 * both `ARRAY(10) VECTOR(3)`, compiles to XXAR(V1) then
                 * ADLP(10)/DLPE -- ADLP's own count is 10 (one per VECTOR
                 * row, matching resolve_container's array_of_vector-aware
                 * per-row slicing), not 30. Unlike a WRITE argument (which
                 * genuinely needs one flat data field per element for output
                 * formatting -- the `state->arrayed_index < 0` guard's own
                 * comment below, unchanged), a CALL argument's *whole* array
                 * must land in the callee's single parameter SYT slot as one
                 * container (bind_call_argument's existing is_container
                 * branch) -- not bound piecemeal across N different
                 * positional parameter slots, which is what the pre-fix
                 * code did: each replay pass appended its own separate
                 * items[] entry (one flat scalar, or -- for ARRAY-of-VECTOR
                 * -- just the current row's 3 elements, from
                 * resolve_operand's non-array_of_vector-aware QUAL_SYT
                 * case), positionally misaligning every later argument's
                 * own item_index against its real parameter position and
                 * corrupting the callee's other locals, while the array
                 * parameter itself ended up unpopulated or wrong (user-
                 * reported, 134-DOTS.hal: `DOTS(V1, V2)`'s own formal
                 * parameters A1/A2 read back as entirely zero). So a
                 * CALL-context whole ARRAY/ARRAY-of-VECTOR argument (BIT/
                 * CHARACTER excluded -- those use bit_elements/char_elements
                 * storage, not this numeric elements[] path, and aren't
                 * confirmed to be ADLP-wrapped the same way in a CALL
                 * context) is captured once, in full, on the first replay
                 * pass, then skipped on every subsequent pass -- the same
                 * idempotent-skip pattern whole_vac_container above already
                 * uses. */
                bool call_array_replay = state->io_pending.is_call && ins->operands[0].qual == QUAL_SYT &&
                                          ins->operands[0].tag1 != 1 && ins->operands[0].tag1 != 2 &&
                                          syt_is_array_shaped(state, ins->operands[0].data);
                if (call_array_replay && state->arrayed_index > 0) {
                    break;
                }
                if (((state->io_pending.kind == 2 || state->io_pending.is_call) && state->arrayed_index < 0) ||
                    whole_vac_container || call_array_replay) {
                    /* A whole VECTOR/MATRIX reference (QUAL=SYT, confirmed
                     * via a real HALSFC compile of `WRITE(6) V;`/
                     * `WRITE(6) M;` -- class-0/XXAR.md's former "whether
                     * an arrayed argument switches QUAL" question, now
                     * resolved: it stays QUAL=SYT with TAG1=the ordinary
                     * class number, exactly like an unarrayed variable,
                     * NOT wrapped in an ADLP/DLPE per-element replay), or
                     * a MATRIX row/column slice's VAC container result
                     * (`WRITE(6) M$(1,*);`, this file's own OP_DSUB
                     * asterisk-subscript handling above) is captured
                     * whole here -- as a WRITE argument, flush_write
                     * expands every element into its own WRITE data field
                     * per USA003087 Sec. 12.2; as a same-unit PCAL/FCAL
                     * argument (confirmed this session by a real HALSFC
                     * compile of `CALL some_procedure(a_whole_matrix);` --
                     * USA003087 Sec. 11.2/11.4-11.5's documented "MATRIX
                     * argument"/"VECTOR argument" parameter-passing rules,
                     * shape-conformance-checked, transmitted "as [an]
                     * assignment... to its corresponding input parameter"
                     * i.e. by value, not by reference), OP_PCAL/OP_FCAL's
                     * own parameter-binding loop below copies it into the
                     * callee's own SYT storage instead. Either way, this
                     * bypasses resolve_operand's ordinary single-value
                     * QUAL_SYT case below (which requires
                     * state->arrayed_index >= 0 and fails loudly outside
                     * any arrayed-paragraph replay -- exactly the
                     * "outside an arrayed-paragraph replay" report this
                     * session's bug reports described; this argument
                     * genuinely isn't one).
                     *
                     * The `state->arrayed_index < 0` guard matters: unlike
                     * VECTOR/MATRIX, a plain (or BIT/CHARACTER) `ARRAY`
                     * whole-WRITE argument (`WRITE(6) C;`, confirmed via
                     * test_arrinit_types.hal's real compiled HALMAT) *is*
                     * wrapped in an ADLP/DLPE per-element replay around
                     * this exact same QUAL=SYT XXAR shape -- that case
                     * must keep going through the ordinary per-element
                     * resolve_operand path below (arrayed_index >= 0
                     * during the replay selects each element in turn),
                     * which already handled it correctly before this
                     * session; only the *unreplayed* whole-container
                     * shape is new here. */
                    bool whole_syt = (state->arrayed_index < 0 || call_array_replay) &&
                                      ins->operands[0].qual == QUAL_SYT &&
                                      syt_is_array_shaped(state, ins->operands[0].data);
                    bool whole_vac = whole_vac_container;
                    if (whole_syt || whole_vac) {
                        if (whole_syt && (ins->operands[0].tag1 == 1 || ins->operands[0].tag1 == 2)) {
                            /* Whole BIT/CHARACTER ARRAY argument
                             * (`WRITE(6) DATA_VALID;`, `DATA_VALID` an
                             * `ARRAY(4) BOOLEAN`) -- genuinely different
                             * storage (bit_elements/char_elements, not
                             * elements/halmat_scalar_t), so captured
                             * separately from the numeric is_container
                             * path below (state.h's is_bit_array/
                             * is_char_array comment). User-reported
                             * (120-EXAMPLE_A.hal's `WRITE(6) AVERAGE,
                             * DATA_VALID;`). */
                            ensure_container(state, ins->operands[0].data);
                            halmat_syt_entry_t *e = &state->syt[ins->operands[0].data];
                            state->io_pending.items[state->io_pending.item_count].is_container = false; /* stale-flag clear, same reason as elsewhere in this function */
                            state->io_pending.items[state->io_pending.item_count].is_bit_array = false;
                            state->io_pending.items[state->io_pending.item_count].is_char_array = false;
                            state->io_pending.items[state->io_pending.item_count].is_structure = false;
                            if (ins->operands[0].tag1 == 1) {
                                if (!e->bit_elements) { fail(state, "WRITE/call argument: expected a BIT ARRAY"); break; }
                                int width = 1;
                                if (state->symtab) {
                                    const halmat_symtab_entry_t *sym = halmat_symtab_find_by_index(state->symtab, ins->operands[0].data);
                                    if (sym && sym->bit_width > 0) width = sym->bit_width;
                                }
                                state->io_pending.items[state->io_pending.item_count].is_bit_array = true;
                                state->io_pending.items[state->io_pending.item_count].bit_array = e->bit_elements;
                                state->io_pending.items[state->io_pending.item_count].bit_array_width = width;
                            } else {
                                if (!e->char_elements) { fail(state, "WRITE/call argument: expected a CHARACTER ARRAY"); break; }
                                state->io_pending.items[state->io_pending.item_count].is_char_array = true;
                                state->io_pending.items[state->io_pending.item_count].char_array = e->char_elements;
                            }
                            state->io_pending.items[state->io_pending.item_count].container_count = e->element_count;
                            state->io_pending.items[state->io_pending.item_count].is_assign = is_assign_arg;
                            state->io_pending.items[state->io_pending.item_count].dest_operand = ins->operands[0];
                            state->io_pending.item_count++;
                            break;
                        }
                        halmat_scalar_t *elems; size_t count; int rows, cols;
                        /* call_array_replay means arrayed_index is
                         * genuinely >= 0 here (we're on this replay's first
                         * pass, not outside one) -- but resolve_container's
                         * own array_of_vector branch treats any
                         * arrayed_index >= 0 as "slice to just this one
                         * row," which is exactly what must NOT happen here
                         * (the whole point of this branch is capturing the
                         * *entire* array as one item). Temporarily forcing
                         * arrayed_index to -1 for this one call reuses
                         * resolve_container's already-correct "outside a
                         * replay" whole-container path instead of
                         * duplicating it. */
                        int32_t saved_arrayed_index = state->arrayed_index;
                        if (call_array_replay) state->arrayed_index = -1;
                        bool container_ok = resolve_container(state, &ins->operands[0], &elems, &count, &rows, &cols);
                        state->arrayed_index = saved_arrayed_index;
                        if (!container_ok) break;
                        state->io_pending.items[state->io_pending.item_count].is_container = true;
                        state->io_pending.items[state->io_pending.item_count].is_bit_array = false; /* stale-flag
                            * clear, same reason as the plain-value path's own is_container reset below */
                        state->io_pending.items[state->io_pending.item_count].is_char_array = false;
                        state->io_pending.items[state->io_pending.item_count].container = elems;
                        state->io_pending.items[state->io_pending.item_count].container_count = count;
                        state->io_pending.items[state->io_pending.item_count].container_rows = rows;
                        state->io_pending.items[state->io_pending.item_count].container_cols = cols;
                        /* User-reported (113-EXAMPLE_7.hal's `WRITE(6)
                         * MISMATCH$(J,*);`, MISMATCH a confirmed-2D
                         * `ARRAY(4,4) INTEGER`): previously restricted to
                         * `whole_syt` (a plain whole-array reference like
                         * `WRITE(6) MISMATCH;`), silently formatting as
                         * SCALAR instead -- a VAC-carried container result
                         * (`whole_vac`, e.g. this DSUB row-select) carries
                         * the identical TAG1=6 INTEGER-class marking on
                         * its own capturing XXAR operand (confirmed via
                         * --disasm), it just wasn't being consulted for
                         * that case. See state.h's own comment. */
                        state->io_pending.items[state->io_pending.item_count].container_is_integer =
                            ins->operands[0].tag1 == 6;
                        state->io_pending.items[state->io_pending.item_count].is_assign = is_assign_arg;
                        state->io_pending.items[state->io_pending.item_count].dest_operand = ins->operands[0];
                        state->io_pending.item_count++;
                        break;
                    }
                }
                if (!resolve_operand(state, &ins->operands[0], &a)) break;
                /* A bare numeric literal (QUAL_LIT) always resolves as
                 * RV_SCALAR (see resolve_operand's QUAL_LIT case -- the
                 * litfile itself carries no INTEGER-vs-SCALAR distinction
                 * for LIT_FIXED/LIT_DOUBLE entries), even when the
                 * literal is actually being used in an INTEGER context
                 * (e.g. `CALL P(5);` with P's parameter declared
                 * INTEGER, or `WRITE(6) 5;`). This operand's own tag1 --
                 * the HALMAT class the compiler recorded for it, already
                 * used the same way just above for READ/READALL's
                 * dest_class -- is the actual source of truth for a
                 * literal's intended class, so use it to reclassify a
                 * RV_SCALAR resolution as INTEGER when tag1 says so.
                 *
                 * Originally thought unnecessary for non-literal operands
                 * ("SYT reads already carry the correct kind via the SYT
                 * entry's own stored type, independent of tag1") -- true
                 * for a plain, unarrayed SYT_TYPE_INTEGER symbol, but NOT
                 * for an ARRAY(n) INTEGER element read during an ADLP
                 * per-element WRITE replay: resolve_operand's arrayed QUAL_
                 * SYT branch always returns RV_SCALAR for a numeric array
                 * regardless of declared element type (state.h's `elements`
                 * comment: "INTEGER ARRAY elements are boxed as scalar" --
                 * HALMAT itself never distinguishes the two at the storage
                 * level). Confirmed against real gpc output for a plain
                 * `WRITE(6) A;` (A an ARRAY(3) INTEGER, local or EXTERNAL
                 * COMPOOL): yaHALMAT2 printed it SCALAR-style
                 * (" 1.0000000E+01 ...") instead of INTEGER-style ("10
                 * ..."). Dropping the QUAL_LIT restriction fixes both
                 * cases identically -- a genuinely SCALAR-typed operand's
                 * own tag1 is never 6, so this can't misfire. */
                bool integer_class_scalar = (a.kind == RV_SCALAR) && ins->operands[0].tag1 == 6;
                if (integer_class_scalar) {
                    a.integer = halmat_scalar_to_integer(a.scalar);
                    a.kind = RV_INTEGER;
                }
                state->io_pending.items[state->io_pending.item_count].is_container = false; /* items[] slots
                    * are reused across WRITE statements without zeroing -- a stale true from a
                    * previous statement's whole-container item at this same slot must be cleared. */
                state->io_pending.items[state->io_pending.item_count].is_bit_array = false;
                state->io_pending.items[state->io_pending.item_count].is_char_array = false;
                state->io_pending.items[state->io_pending.item_count].is_structure = false;
                state->io_pending.items[state->io_pending.item_count].is_string = (a.kind == RV_STRING);
                state->io_pending.items[state->io_pending.item_count].is_scalar = (a.kind == RV_SCALAR);
                state->io_pending.items[state->io_pending.item_count].is_bits = (a.kind == RV_BITS);
                state->io_pending.items[state->io_pending.item_count].string = a.string;
                if (a.kind == RV_SCALAR) {
                    state->io_pending.items[state->io_pending.item_count].scalar = a.scalar;
                } else if (a.kind == RV_BITS) {
                    /* state.h's bit_width comment: the real declared width
                     * for a plain variable reference (BCAT's own
                     * established technique for this identical problem),
                     * falling back to 32 (USA003090 Sec. 8.2 rule 6's
                     * documented maximum legal BIT string length) for
                     * anything else -- user-confirmed against
                     * ["Programming in HAL/S"] p. 255. A QUAL_VAC operand
                     * carrying a same-unit FUNCTION-call result (OP_RTRN's
                     * own genuine-call-frame branch, this file) may also
                     * know its own real width -- a BOOLEAN-returning
                     * FUNCTION's result, user-reported (129-ALMOST_EQUAL.hal) --
                     * via the VAC slot's own bit_width field, checked
                     * before falling back to 32 the same way the QUAL_SYT
                     * case just above already does via the symbol table. A
                     * bare QUAL_LIT HEX/OCT/BIN literal (`WRITE(6)
                     * HEX'00123';`) similarly knows its own real width --
                     * not 32, but the digit-count-derived BIT(n) the real
                     * compiler records in the literal table itself
                     * (litfile.h's bit_width comment; empirically confirmed
                     * against real compiled output's `LHI R6,20`/
                     * `LFXI R6,7` immediately preceding the WRITE call). A
                     * QUAL_XPT structure-field reference (`WRITE(6)
                     * FWDSENSORS.STATUS;`, STATUS declared BIT(16) inside
                     * a STRUCTURE) similarly has a real declared width,
                     * found the same way write_destination's own
                     * structure-field paths do -- via the resolving EXTN's
                     * VAC slot's struct_field_syt (the TEMPLATE's own
                     * field symbol index), not ins->operands[0].data
                     * itself (that's the EXTN's own stream position, not
                     * a symbol index). Previously fell through to the
                     * bare 32-bit default -- user-reported
                     * (test_tint_null_terminal.hal, problems-yaHALMAT2.md
                     * item 4), confirmed against real gpc output. */
                    int width = 32;
                    if (ins->operands[0].qual == QUAL_SYT && state->symtab) {
                        const halmat_symtab_entry_t *sym = halmat_symtab_find_by_index(state->symtab, ins->operands[0].data);
                        if (sym && sym->bit_width > 0) width = sym->bit_width;
                    } else if (ins->operands[0].qual == QUAL_VAC && ins->operands[0].data < HALMAT_VAC_MAX) {
                        int vac_width = state->vac[ins->operands[0].data].bit_width;
                        if (vac_width > 0) width = vac_width;
                    } else if (ins->operands[0].qual == QUAL_LIT && state->literals &&
                               ins->operands[0].data < state->literals->count) {
                        const halmat_literal_t *lit = &state->literals->entries[ins->operands[0].data];
                        if (lit->type == LIT_BIT && lit->bit_width > 0) width = lit->bit_width;
                    } else if (ins->operands[0].qual == QUAL_XPT && ins->operands[0].data < HALMAT_VAC_MAX && state->symtab) {
                        const halmat_vac_slot_t *xpt_slot = &state->vac[ins->operands[0].data];
                        if (xpt_slot->is_struct_ref) {
                            const halmat_symtab_entry_t *sym = halmat_symtab_find_by_index(state->symtab, xpt_slot->struct_field_syt);
                            if (sym && sym->bit_width > 0) width = sym->bit_width;
                        }
                    }
                    state->io_pending.items[state->io_pending.item_count].bits = a.bits;
                    state->io_pending.items[state->io_pending.item_count].bit_width = width;
                } else if (a.kind != RV_STRING) {
                    /* HAL/S plain INTEGER (no DOUBLE qualifier) is a
                     * genuine 16-bit signed halfword on real AP-101S
                     * hardware; this project's own INTEGER representation
                     * is a plain int32_t throughout with no single/double
                     * precision distinction modeled (value.c's halmat_
                     * scalar_to_integer's own comment, run_all.sh's
                     * errfix_trig fixture comment), so a value whose
                     * magnitude exceeds +-32767 -- from arithmetic
                     * overflow, a full-width BIT(16) reinterpreted via
                     * BTOI, or a raw SUBBIT(I1)=... store -- must still be
                     * truncated/reinterpreted as signed 16-bit right here,
                     * where it's finally read out for WRITE, to match real
                     * hardware. Confirmed against real gpc output for
                     * test_bit_at_partition.hal, test_subbit_assign.hal,
                     * test_init8.hal, and test_subbit_scalar.hal: e.g. an
                     * accumulated OUTPUT of 56525 (0xDCCD) prints as
                     * -9011, not 56525. A confirmed DOUBLE INTEGER symbol
                     * keeps its full 32-bit value; default to single/
                     * 16-bit whenever precision can't be confirmed
                     * (QUAL_VAC/QUAL_LIT operands have no symtab entry to
                     * check) -- matching this project's usual "default to
                     * the common case" convention (state.h's bit_width
                     * comment) and the language's own default. */
                    int32_t ival = rv_to_integer(&a);
                    bool is_double_integer = false;
                    if (ins->operands[0].qual == QUAL_SYT && state->symtab) {
                        const halmat_symtab_entry_t *sym = halmat_symtab_find_by_index(state->symtab, ins->operands[0].data);
                        if (sym && (sym->flags & HALMAT_SYM_FLAG_DOUBLE)) is_double_integer = true;
                    }
                    if (!is_double_integer) ival = (int32_t)(int16_t)(ival & 0xFFFF);
                    state->io_pending.items[state->io_pending.item_count].integer = ival;
                }
                state->io_pending.items[state->io_pending.item_count].is_assign = is_assign_arg;
                state->io_pending.items[state->io_pending.item_count].dest_operand = ins->operands[0];
                state->io_pending.item_count++;
                break;

            case OP_WRIT: {
                if (!state->io_pending.active) { fail(state, "WRIT outside of an XXST...XXND block"); break; }
                if (ins->operand_count != 1) { fail(state, "WRIT: expected 1 operand"); break; }
                if (!resolve_operand(state, &ins->operands[0], &a)) break;
                int device = rv_to_integer(&a);
                if (device < 0 || device >= HALMAT_DEVICE_MAX || !state->devices[device]) {
                    fail(state, "WRITE(%d): device not mapped (use --ddo)", device);
                    break;
                }
                flush_write(state, device, state->devices[device], state->device_unpaged[device]);
                break;
            }

            case OP_FILE: {
                /* Random-access file I/O (class-0/FILE.md): FILE(n,addr)=exp
                 * (write) or var=FILE(n,addr) (read). Two operands: LIT
                 * (the record address/number -- confirmed to be the address
                 * itself, not a format descriptor) and SYT (the transferred
                 * variable) -- only a plain unsubscripted SYT is confirmed/
                 * implemented. The channel is the operator word's own TAG
                 * (confirmed via two independent real compiles this
                 * session: FILE(1,...) both times shows tag=0x01). Write
                 * vs read is disambiguated by the SYT operand's own TAG2
                 * (confirmed empirically this session, not previously
                 * documented: 1=write/source, 0=read/destination).
                 *
                 * Channel/record-size mapping comes from --raf (main.c),
                 * modeled directly on the historical HAL/S-FC runtime's
                 * own option of the same name and shape (a *separate*
                 * device-number namespace from READ/WRITE's --ddi/--ddo,
                 * per that option's own documentation) -- see
                 * interp_set_raf_device. Record layout: INTEGER as a
                 * 4-byte big-endian value; SCALAR as its existing
                 * msw/lsw wire format (4 bytes single, 8 bytes double,
                 * matching this project's already-established bit-exact
                 * representation elsewhere, e.g. literal.c). No
                 * real-toolchain cross-validation is possible (BFS
                 * object files use a different format from PFS, and the
                 * available lnk101 doesn't support BFS -- direct user
                 * confirmation), so this is validated by internal
                 * write-then-read round-trip correctness only, not
                 * byte-for-byte compatibility with any other tool. */
                if (ins->operand_count != 2) { fail(state, "FILE: expected 2 operands"); break; }
                if (ins->operands[0].qual != QUAL_LIT) { fail(state, "FILE: expected a LIT address operand"); break; }
                if (ins->operands[1].qual != QUAL_SYT) { fail(state, "FILE: only a plain SYT transferred-variable operand is implemented"); break; }
                int channel = ins->tag;
                if (channel < 0 || channel >= HALMAT_DEVICE_MAX || !state->raf_devices[channel]) {
                    fail(state, "FILE(%d): channel not mapped (use --raf)", channel);
                    break;
                }
                if (!resolve_operand(state, &ins->operands[0], &a)) break;
                int32_t record_num = rv_to_integer(&a);
                int record_size = state->raf_record_size[channel];
                FILE *fp = state->raf_devices[channel];
                long position = (long)record_size * (long)record_num;
                uint16_t var_syt = ins->operands[1].data;
                if (var_syt >= HALMAT_SYT_MAX) { fail(state, "FILE: SYT index out of range"); break; }
                bool is_write = (ins->operands[1].tag2 != 0);
                halmat_syt_entry_t *e = &state->syt[var_syt];
                if (fseek(fp, position, SEEK_SET) != 0) { fail(state, "FILE(%d): seek to record %d failed", channel, record_num); break; }
                if (is_write) {
                    uint8_t buf[8];
                    int nbytes;
                    if (e->type == SYT_TYPE_SCALAR) {
                        nbytes = e->scalar.double_precision ? 8 : 4;
                        buf[0] = (uint8_t)(e->scalar.msw >> 24); buf[1] = (uint8_t)(e->scalar.msw >> 16);
                        buf[2] = (uint8_t)(e->scalar.msw >> 8);  buf[3] = (uint8_t)e->scalar.msw;
                        if (e->scalar.double_precision) {
                            buf[4] = (uint8_t)(e->scalar.lsw >> 24); buf[5] = (uint8_t)(e->scalar.lsw >> 16);
                            buf[6] = (uint8_t)(e->scalar.lsw >> 8);  buf[7] = (uint8_t)e->scalar.lsw;
                        }
                    } else {
                        int32_t v = (e->type == SYT_TYPE_INTEGER) ? e->value : 0;
                        nbytes = 4;
                        buf[0] = (uint8_t)(v >> 24); buf[1] = (uint8_t)(v >> 16);
                        buf[2] = (uint8_t)(v >> 8);  buf[3] = (uint8_t)v;
                    }
                    if (nbytes > record_size) {
                        fail(state, "FILE(%d): value needs %d bytes, --raf record size is only %d", channel, nbytes, record_size);
                        break;
                    }
                    if (fwrite(buf, 1, (size_t)nbytes, fp) != (size_t)nbytes) {
                        fail(state, "FILE(%d): write to record %d failed", channel, record_num);
                        break;
                    }
                    fflush(fp);
                } else {
                    /* If the destination has never been written before
                     * (still SYT_TYPE_UNKNOWN), its format can't be
                     * inferred from itself -- consult the symbol table's
                     * declared type instead (same fallback TINT uses),
                     * since guessing INTEGER by default would silently
                     * misinterpret a SCALAR's hex-float bit pattern as a
                     * plain integer. */
                    bool as_scalar = (e->type == SYT_TYPE_SCALAR);
                    if (e->type == SYT_TYPE_UNKNOWN && state->symtab) {
                        const halmat_symtab_entry_t *vsym = halmat_symtab_find_by_index(state->symtab, var_syt);
                        if (vsym && vsym->hal_class == 5) as_scalar = true;
                    }
                    int nbytes = as_scalar ? (e->scalar.double_precision ? 8 : 4) : 4;
                    if (nbytes > record_size) {
                        fail(state, "FILE(%d): value needs %d bytes, --raf record size is only %d", channel, nbytes, record_size);
                        break;
                    }
                    uint8_t buf[8] = {0};
                    if (fread(buf, 1, (size_t)nbytes, fp) != (size_t)nbytes) {
                        fail(state, "FILE(%d): read from record %d failed (short or missing record)", channel, record_num);
                        break;
                    }
                    if (as_scalar) {
                        uint32_t msw = ((uint32_t)buf[0] << 24) | ((uint32_t)buf[1] << 16) | ((uint32_t)buf[2] << 8) | buf[3];
                        uint32_t lsw = e->scalar.double_precision
                            ? (((uint32_t)buf[4] << 24) | ((uint32_t)buf[5] << 16) | ((uint32_t)buf[6] << 8) | buf[7])
                            : 0;
                        e->type = SYT_TYPE_SCALAR;
                        e->scalar = halmat_scalar_from_ibm_words(msw, lsw, e->scalar.double_precision);
                    } else {
                        int32_t v = (int32_t)(((uint32_t)buf[0] << 24) | ((uint32_t)buf[1] << 16) | ((uint32_t)buf[2] << 8) | buf[3]);
                        e->type = SYT_TYPE_INTEGER;
                        e->value = v;
                    }
                }
                break;
            }

            case OP_READ:
            case OP_RDAL: {
                /* RDAL (READALL) is structurally identical to READ for
                 * the plain scalar/integer-list case (class-0/RDAL.md) --
                 * shares this handler. READALL's real-HAL/S array/until-
                 * EOF looping behavior isn't modeled (reads exactly the
                 * listed items, same as READ); no fixture uses an
                 * arrayed READALL target yet. */
                if (!state->io_pending.active) { fail(state, "READ/READALL outside of an XXST...XXND block"); break; }
                if (ins->operand_count != 1) { fail(state, "READ/READALL: expected 1 operand"); break; }
                if (!resolve_operand(state, &ins->operands[0], &a)) break;
                int device = rv_to_integer(&a);
                if (device < 0 || device >= HALMAT_DEVICE_MAX || !state->devices[device]) {
                    fail(state, "READ(%d): device not mapped (use --ddi)", device);
                    break;
                }
                FILE *in = state->devices[device];
                /* USA003087 Sec. 12.3 default positioning -- see
                 * discard_to_eol's own comment and device_read_started's
                 * in state.h. SKIP(n) (state.h's has_skip/skip_n comment)
                 * overrides the default single-line advance: SKIP(0)
                 * suppresses it entirely -- re-read the current,
                 * not-yet-fully-consumed line, 164-OUTER.hal's own idiom
                 * (peek a line's leading token via READALL, then re-read
                 * that same line's remaining fixed-column fields) -- and
                 * (since no new line is being entered) device_line_start
                 * deliberately stays whatever the *previous* read call on
                 * this device already established it as. SKIP(n>=1)
                 * advances n lines instead of the usual one. */
                int skip_lines = state->io_pending.has_skip ? state->io_pending.skip_n : 1;
                if (state->device_read_started[device]) {
                    for (int s = 0; s < skip_lines; s++) discard_to_eol(in);
                    if (skip_lines > 0) state->device_line_start[device] = ftell(in);
                } else {
                    state->device_read_started[device] = true;
                    state->device_line_start[device] = ftell(in);
                }
                if (state->io_pending.has_column) {
                    /* COLUMN(n) (state.h's has_column/column_n comment):
                     * 1-indexed absolute column within the *current*
                     * line, per [USA003087] Sec. 12.3 -- reposition
                     * relative to this device's own tracked line-start
                     * offset rather than wherever the previous field's
                     * own fscanf happened to leave the cursor. */
                    fseek(in, state->device_line_start[device] + (state->io_pending.column_n - 1), SEEK_SET);
                }
                /* Tracks "has any data field of this whole READ statement
                 * already been consumed yet" -- read_skip_separator's
                 * `require_separator` needs this, not simply "am I past
                 * item 0," now that a single item can itself expand into
                 * several fields (the whole-VECTOR/MATRIX case just
                 * below): the 2nd/3rd element of a VECTOR(3) destination
                 * still needs `require_separator=true` even though both
                 * belong to outer item index 0. */
                bool any_field_read = false;
                int32_t saved_arrayed_index_outer = state->arrayed_index;
                for (uint8_t i = 0; i < state->io_pending.item_count; i++) {
                    resolved_value_t rv;
                    /* A plain (non-container) destination captured via an
                     * ADLP/DLPE per-element replay at XXAR-capture time (a
                     * flat ARRAY -- unlike the whole-VECTOR/MATRIX dest_is_
                     * container case just below, which is NOT replayed)
                     * needs write_destination's own arrayed_index-based
                     * element indexing to know which element *this* item
                     * corresponds to -- but by the time this loop runs, the
                     * real replay (which only ever wrapped the XXAR capture
                     * step, not OP_READ itself) has already finished and
                     * arrayed_index reset to -1. Substituting this loop's
                     * own item index recreates the exact same 0..N-1
                     * sequence the real replay used during capture (items[]
                     * preserves that order) -- user-reported, 154-ADD.hal's
                     * `READ(5) A;`, A a plain ARRAY(100) SCALAR: "SYT index
                     * N is a whole ARRAY/VECTOR/MATRIX referenced outside an
                     * arrayed-paragraph replay". Harmless to set
                     * unconditionally on every item regardless of its own
                     * destination shape -- write_destination only consults
                     * arrayed_index for a genuinely array-shaped plain SYT
                     * destination in the first place, ignoring it entirely
                     * for an ordinary scalar/integer/character one. Restored
                     * once after the whole loop, not per-item, since nothing
                     * else in this loop body depends on it. */
                    if (state->io_pending.items[i].dest_operand.qual == QUAL_SYT &&
                        syt_is_array_shaped(state, state->io_pending.items[i].dest_operand.data)) {
                        state->arrayed_index = (int32_t)i;
                    }
                    if (state->io_pending.items[i].dest_is_container) {
                        /* Whole VECTOR/MATRIX destination (state.h's
                         * dest_is_container comment) -- USA003087 Sec.
                         * 12.3: "a vector data item causes one data field
                         * per vector element to be read... a matrix...
                         * row by row," the same element order WRITE/
                         * INITIAL already use, so a plain sequential
                         * elements[] walk is correct for both shapes.
                         * Every element still goes through the ordinary
                         * null-field/terminate rules below, same as any
                         * other item -- a semicolon mid-VECTOR leaves the
                         * rest of *this* container AND every later item
                         * unchanged, matching a semicolon between two
                         * ordinary items. User-reported (044-ORTHONORMAL.
                         * hal's `READ(5) X;`, X a VECTOR(3)). */
                        uint16_t syt_index = state->io_pending.items[i].dest_operand.data;
                        ensure_container(state, syt_index);
                        halmat_syt_entry_t *e = &state->syt[syt_index];
                        bool stop = false;
                        for (size_t k = 0; k < e->element_count; k++) {
                            halmat_read_field_t field = read_skip_separator(in, any_field_read);
                            any_field_read = true;
                            if (field == HALMAT_READ_FIELD_TERMINATE) { stop = true; break; }
                            if (field == HALMAT_READ_FIELD_NULL) continue;
                            double v;
                            if (fscanf(in, "%lf", &v) != 1) {
                                if (!io_error_redirect_on_eof(state, &state->pc, &branched)) {
                                    fail(state, "READ(%d): end of input or malformed SCALAR", device);
                                }
                                stop = true;
                                break;
                            }
                            /* Always single precision, matching the
                             * ordinary plain-SCALAR item branch below
                             * (rv.scalar = halmat_scalar_from_double(v,
                             * false)) -- READ doesn't otherwise consult a
                             * destination's declared precision anywhere
                             * in this interpreter yet, so this stays
                             * consistent rather than special-casing
                             * containers alone. */
                            e->elements[k] = halmat_scalar_from_double(v, false);
                        }
                        if (stop) break;
                        continue;
                    }
                    if (state->io_pending.items[i].dest_is_structure) {
                        /* Whole-structure destination (state.h's
                         * dest_is_structure comment) -- one data field
                         * per terminal, in declaration order (a VECTOR
                         * terminal like any other whole-VECTOR
                         * destination above, one field per component),
                         * walked via the template's own symtab
                         * struct_first_field/struct_next_field chain and
                         * written directly into each terminal's own
                         * shadow field slot (find_or_create_struct_field)
                         * -- bypassing write_destination entirely, since
                         * there's no QUAL_XPT operand naming any one
                         * terminal individually here (this whole branch
                         * exists precisely because HALSFC's own compiled
                         * output never spells out per-terminal operands
                         * for a *whole*-structure I/O argument the way
                         * TINT's own OFFSET-driven INITIAL() does).
                         * User-reported, 172-OUTER.hal's `READ(5) ARG;`. */
                        uint16_t base_syt = state->io_pending.items[i].struct_base_syt;
                        int32_t copy_idx = state->io_pending.items[i].struct_copy_index >= 0
                            ? state->io_pending.items[i].struct_copy_index : current_copy_index(state);
                        bool stop = false;
                        int field_syt = -1;
                        if (state->symtab) {
                            const halmat_symtab_entry_t *tsym = halmat_symtab_find_by_index(state->symtab, state->io_pending.items[i].struct_template_syt);
                            field_syt = tsym ? tsym->struct_first_field : -1;
                        }
                        while (!stop && field_syt >= 0) {
                            const halmat_symtab_entry_t *fsym = state->symtab ? halmat_symtab_find_by_index(state->symtab, (size_t)field_syt) : NULL;
                            if (!fsym) break;
                            halmat_syt_entry_t *fe = find_or_create_struct_field(state, base_syt, (uint16_t)field_syt, copy_idx);
                            if (fsym->hal_class == 4 && fsym->cols > 0) {
                                /* VECTOR terminal (`V VECTOR`): allocate
                                 * this shadow slot's own elements[] the
                                 * first time it's touched, the same
                                 * ensure_container() convention a plain
                                 * VECTOR SYT uses -- never done before for
                                 * a structure-field shadow slot (TASN's
                                 * own comment flags writing array-shaped
                                 * data into one as a previously-
                                 * unreachable gap; this is the first
                                 * confirmed real trigger). */
                                if (!fe->elements) {
                                    fe->elements = calloc((size_t)fsym->cols, sizeof(halmat_scalar_t));
                                    fe->element_count = (size_t)fsym->cols;
                                    fe->cols = fsym->cols;
                                    fe->rows = 0;
                                }
                                for (int k = 0; !stop && k < fsym->cols; k++) {
                                    halmat_read_field_t rf = read_skip_separator(in, any_field_read);
                                    any_field_read = true;
                                    if (rf == HALMAT_READ_FIELD_TERMINATE) { stop = true; break; }
                                    if (rf == HALMAT_READ_FIELD_NULL) continue;
                                    double v;
                                    if (fscanf(in, "%lf", &v) != 1) {
                                        if (!io_error_redirect_on_eof(state, &state->pc, &branched)) {
                                            fail(state, "READ(%d): end of input or malformed SCALAR", device);
                                        }
                                        stop = true;
                                        break;
                                    }
                                    fe->elements[k] = halmat_scalar_from_double(v, false);
                                }
                            } else if (fsym->hal_class == 5 || fsym->hal_class == 6 || fsym->hal_class == 1) {
                                /* Plain SCALAR/INTEGER/BIT(BOOLEAN) terminal. */
                                halmat_read_field_t rf = read_skip_separator(in, any_field_read);
                                any_field_read = true;
                                if (rf == HALMAT_READ_FIELD_TERMINATE) { stop = true; break; }
                                if (rf != HALMAT_READ_FIELD_NULL) {
                                    double v;
                                    if (fscanf(in, "%lf", &v) != 1) {
                                        if (!io_error_redirect_on_eof(state, &state->pc, &branched)) {
                                            fail(state, "READ(%d): end of input or malformed SCALAR", device);
                                        }
                                        stop = true;
                                        break;
                                    }
                                    if (fsym->hal_class == 6) {
                                        fe->type = SYT_TYPE_INTEGER;
                                        fe->value = (int32_t)v;
                                    } else if (fsym->hal_class == 1) {
                                        fe->type = SYT_TYPE_BIT;
                                        fe->bit_value = (uint32_t)(int32_t)v;
                                    } else {
                                        fe->type = SYT_TYPE_SCALAR;
                                        fe->scalar = halmat_scalar_from_double(v, false);
                                    }
                                }
                            } else {
                                fail(state, "READ: structure terminal '%s' has an unsupported type for whole-structure READ", fsym->name ? fsym->name : "?");
                                stop = true;
                                break;
                            }
                            field_syt = fsym->struct_next_field;
                        }
                        if (stop) break;
                        continue;
                    }
                    /* USA003087 Sec. 12.3/USA003088 Sec. 10.1.1 rules 5-6
                     * (also "Programming in HAL/S" Sec. 8.3, p. 153):
                     * fields are separated by "a comma and/or at least
                     * one blank"; a comma found where data was expected
                     * is a *null field* (leaves just that destination
                     * untouched, e.g. a leading comma -- "READ(5)
                     * A,B,C;" fed ",2,3" -- nulls A the same way a
                     * doubled mid-list comma nulls a later item, not a
                     * parse error -- user-reported); a *semicolon* found
                     * where data was expected instead terminates the
                     * *entire remaining list* (this item and every item
                     * after it stay untouched) -- user-reported,
                     * previously a hard parse error rather than the
                     * documented "process a variable number of input
                     * values" idiom. */
                    halmat_read_field_t field = read_skip_separator(in, any_field_read);
                    any_field_read = true;
                    if (field == HALMAT_READ_FIELD_TERMINATE) break;
                    if (field == HALMAT_READ_FIELD_NULL) continue;
                    if (state->io_pending.items[i].dest_class == 6) {
                        long v;
                        if (fscanf(in, "%ld", &v) != 1) {
                            if (!io_error_redirect_on_eof(state, &state->pc, &branched)) {
                                fail(state, "READ(%d): end of input or malformed INTEGER", device);
                            }
                            break;
                        }
                        rv.kind = RV_INTEGER;
                        rv.integer = (int32_t)v;
                    } else if (state->io_pending.items[i].dest_class == 2) {
                        /* Whitespace-delimited token, same convention as
                         * the numeric cases -- HAL/S's real fixed-column
                         * card-image READ format isn't modeled (see
                         * state.h's CHARACTER-storage note), just enough
                         * for the common case of reading a plain word. */
                        char buf[1024];
                        if (fscanf(in, "%1023s", buf) != 1) {
                            if (!io_error_redirect_on_eof(state, &state->pc, &branched)) {
                                fail(state, "READ(%d): end of input for CHARACTER", device);
                            }
                            break;
                        }
                        rv.kind = RV_STRING;
                        rv.string = buf;
                        if (!write_destination(state, &state->io_pending.items[i].dest_operand, &rv)) break;
                        continue;
                    } else {
                        double v;
                        if (fscanf(in, "%lf", &v) != 1) {
                            if (!io_error_redirect_on_eof(state, &state->pc, &branched)) {
                                fail(state, "READ(%d): end of input or malformed SCALAR", device);
                            }
                            break;
                        }
                        rv.kind = RV_SCALAR;
                        rv.scalar = halmat_scalar_from_double(v, false);
                    }
                    if (!write_destination(state, &state->io_pending.items[i].dest_operand, &rv)) break;
                }
                state->arrayed_index = saved_arrayed_index_outer;
                state->io_pending.active = false;
                state->io_pending.item_count = 0;
                break;
            }

            case OP_XXND: {
                /* ASSIGN-form call arguments (state.h's is_assign
                 * comment): this is the exact point control lands back on
                 * after a completed PCAL/FCAL call -- RTRN/CLOS's return
                 * jump always targets PCAL/FCAL's own stream position + 1,
                 * which per class-0/XXST.md's bracket shape (XXAR...XXAR,
                 * PCAL/FCAL, XXND) is always this closing XXND. This
                 * frame's own io_pending (items[]/call_target) is still
                 * exactly as OP_XXAR/OP_PCAL/OP_FCAL left it -- untouched
                 * by anything the callee itself did in between, since any
                 * I/O or further calls *it* made would have pushed/popped
                 * their own frame via io_pending_stack around themselves
                 * (see OP_XXST above) -- so the callee's finished
                 * parameter values are read here, before this frame itself
                 * gets popped/reset below. Each ASSIGN argument's
                 * parameter binds to the same positional SYT slot
                 * (call_target+1+item_index) ordinary arguments already
                 * use (OP_PCAL/OP_FCAL's binding loop), so no separate
                 * bookkeeping of *which* parameter was tracked at call
                 * time -- just the item's own position in this list. */
                if (state->io_pending.active && state->io_pending.is_call) {
                    uint16_t resolved_call_target = resolve_call_target(state, state->io_pending.call_target);
                    uint8_t param_pos = 0;
                    uint32_t param_syt = 0;
                    for (uint8_t i = 0; i < state->io_pending.item_count; i++) {
                        if (!item_is_struct_replay_continuation(state->io_pending.items, i)) {
                            param_syt = resolve_param_syt(state, resolved_call_target, param_pos++);
                        }
                        if (!state->io_pending.items[i].is_assign) continue;
                        if (param_syt >= HALMAT_SYT_MAX) { fail(state, "ASSIGN: parameter SYT out of range"); break; }
                        /* Whole STRUCTURE ASSIGN parameter targeting one
                         * copy of a Q-STRUCTURE(n) array
                         * (`CALL READ_IMU(I) ASSIGN(VEL(I));`, VEL a
                         * SUPER_VECTOR-STRUCTURE(3), READ_IMU's own STRUC
                         * parameter a plain single-copy SUPER_VECTOR-
                         * STRUCTURE) -- user-reported,
                         * yahalmat2_assign_array_struct_element;
                         * 180-EXAMPLE_N.hal/184-EXAMPLE_N.hal. `VEL(I)`
                         * compiles to a TSUB(copy index)+EXTN pair
                         * resolving to a QUAL_XPT struct_ref (task #39's
                         * own TSUB copy-index mechanism), not a plain SYT
                         * reference -- deep-copies each of the callee's
                         * STRUC terminals into the caller's own copy-I
                         * shadow storage, the same per-terminal walk/
                         * storage-kind dispatch bind_call_argument's own
                         * is_structure case already uses for the opposite
                         * (call-argument-in) direction. */
                        if (state->symtab) {
                            const halmat_symtab_entry_t *psym = halmat_symtab_find_by_index(state->symtab, param_syt);
                            if (psym && psym->hal_class == 0x0A) {
                                if (state->io_pending.items[i].dest_operand.qual != QUAL_XPT) {
                                    fail(state, "ASSIGN: whole-STRUCTURE receiver must be a qualified structure reference");
                                    break;
                                }
                                uint16_t dest_vac = state->io_pending.items[i].dest_operand.data;
                                if (dest_vac >= HALMAT_VAC_MAX || !state->vac[dest_vac].is_struct_ref) {
                                    fail(state, "ASSIGN: whole-STRUCTURE receiver is not a structure reference");
                                    break;
                                }
                                uint16_t dest_base = state->vac[dest_vac].struct_base_syt;
                                int32_t dest_copy = state->vac[dest_vac].struct_copy_index >= 0
                                    ? state->vac[dest_vac].struct_copy_index : current_copy_index(state);
                                int field_syt = -1;
                                if (psym->struct_template_syt >= 0) {
                                    const halmat_symtab_entry_t *tsym = halmat_symtab_find_by_index(state->symtab, (size_t)psym->struct_template_syt);
                                    field_syt = tsym ? tsym->struct_first_field : -1;
                                }
                                while (field_syt >= 0) {
                                    const halmat_symtab_entry_t *fsym = halmat_symtab_find_by_index(state->symtab, (size_t)field_syt);
                                    if (!fsym) break;
                                    halmat_syt_entry_t *src_fe = find_or_create_struct_field(state, (uint16_t)param_syt, (uint16_t)field_syt, 0);
                                    halmat_syt_entry_t *dst_fe = find_or_create_struct_field(state, dest_base, (uint16_t)field_syt, dest_copy);
                                    if (fsym->hal_class == 4 && fsym->cols > 0) {
                                        if (!dst_fe->elements) {
                                            dst_fe->elements = calloc((size_t)fsym->cols, sizeof(halmat_scalar_t));
                                            dst_fe->element_count = (size_t)fsym->cols;
                                            dst_fe->cols = fsym->cols;
                                            dst_fe->rows = 0;
                                        }
                                        if (src_fe->elements) memcpy(dst_fe->elements, src_fe->elements, (size_t)fsym->cols * sizeof(halmat_scalar_t));
                                    } else if (fsym->hal_class == 6) {
                                        dst_fe->type = SYT_TYPE_INTEGER;
                                        dst_fe->value = src_fe->value;
                                    } else if (fsym->hal_class == 1) {
                                        dst_fe->type = SYT_TYPE_BIT;
                                        dst_fe->bit_value = src_fe->bit_value;
                                    } else if (fsym->hal_class == 5) {
                                        dst_fe->type = SYT_TYPE_SCALAR;
                                        dst_fe->scalar = src_fe->scalar;
                                    }
                                    field_syt = fsym->struct_next_field;
                                }
                                continue;
                            }
                        }
                        if (syt_is_array_shaped(state, (uint16_t)param_syt)) {
                            /* Whole ARRAY/VECTOR/MATRIX ASSIGN parameter
                             * (`PROCEDURE(...) ASSIGN(WHOLE_ARRAY);`) --
                             * resolve_operand/write_destination below are
                             * for a single value; this needs a bulk
                             * element-storage copy instead, same three
                             * storage kinds ensure_container itself
                             * distinguishes (numeric/BIT/CHARACTER).
                             * User-reported (120-EXAMPLE_A.hal's `CALL
                             * ... ASSIGN(DATA_VALID, AVERAGE);`,
                             * `DATA_VALID` an `ARRAY(4) BOOLEAN`). */
                            if (state->io_pending.items[i].dest_operand.qual != QUAL_SYT) {
                                fail(state, "ASSIGN: whole-ARRAY receiver must be a plain SYT variable");
                                break;
                            }
                            ensure_container(state, (uint16_t)param_syt);
                            halmat_syt_entry_t *pe = &state->syt[param_syt];
                            uint16_t dest_syt = state->io_pending.items[i].dest_operand.data;
                            if (dest_syt >= HALMAT_SYT_MAX) { fail(state, "ASSIGN: receiver SYT out of range"); break; }
                            ensure_container(state, dest_syt);
                            halmat_syt_entry_t *de = &state->syt[dest_syt];
                            if (pe->element_count != de->element_count) {
                                fail(state, "ASSIGN: whole-ARRAY shape mismatch (%zu vs %zu elements)",
                                     pe->element_count, de->element_count);
                                break;
                            }
                            if (pe->elements && de->elements) {
                                memcpy(de->elements, pe->elements, pe->element_count * sizeof(halmat_scalar_t));
                                de->rows = pe->rows;
                                de->cols = pe->cols;
                            } else if (pe->bit_elements && de->bit_elements) {
                                memcpy(de->bit_elements, pe->bit_elements, pe->element_count * sizeof(uint32_t));
                            } else if (pe->char_elements && de->char_elements) {
                                for (size_t k = 0; k < pe->element_count; k++) {
                                    free(de->char_elements[k]);
                                    de->char_elements[k] = dup_string(pe->char_elements[k]);
                                }
                            } else {
                                fail(state, "ASSIGN: whole-ARRAY receiver's storage kind doesn't match the parameter's");
                                break;
                            }
                            continue;
                        }
                        halmat_operand_t param_op = {0};
                        param_op.qual = QUAL_SYT;
                        param_op.data = (uint16_t)param_syt;
                        resolved_value_t rv;
                        if (!resolve_operand(state, &param_op, &rv)) break;
                        if (!write_destination(state, &state->io_pending.items[i].dest_operand, &rv)) break;
                    }
                }
                /* Closes whichever bracket was most recently opened. If
                 * that bracket was nested inside an enclosing one (e.g. a
                 * function-call argument list nested inside a WRITE's own
                 * argument list -- see OP_XXST above), restore the
                 * enclosing frame so its own XXAR/WRIT/FCAL/PCAL/XXND see
                 * their own item list again instead of an empty one. */
                if (state->io_pending_sp > 0) {
                    /* This (nested) frame's own items buffer is about to
                     * be discarded, overwritten by the restored outer
                     * frame's own -- free it first, or it leaks (state.h's
                     * halmat_io_item_t comment). */
                    free(state->io_pending.items);
                    state->io_pending = state->io_pending_stack[--state->io_pending_sp];
                } else {
                    state->io_pending.active = false;
                }
                break;
            }

            case OP_FDEF:
            case OP_TDEF:
            case OP_PDEF: {
                /* Only ever reached by ordinary fall-through -- FCAL/PCAL/
                 * SCHD jump straight to def_pos+1, past this instruction
                 * (see precompute_subprograms). Skip the whole
                 * definition; it's entered only via an explicit
                 * call/schedule. */
                size_t target = state->def_clos_target[state->pc];
                if (target == NO_TARGET) { fail(state, "FDEF/TDEF/PDEF has no matching CLOS"); break; }
                state->pc = target;
                branched = true;
                break;
            }

            case OP_PCAL: {
                /* Procedure call header (class-0/PCAL.md): same
                 * bracketed-argument-list/positional-binding mechanism as
                 * FCAL, but no VAC return-value slot to fill -- the
                 * callee returns via RTRN's 0-operand (procedure) form. */
                if (!state->io_pending.active || !state->io_pending.is_call) {
                    fail(state, "PCAL outside of an XXST...XXND call block");
                    break;
                }
                if (ins->operand_count != 1) { fail(state, "PCAL: expected 1 operand"); break; }
                uint16_t proc = resolve_call_target(state, ins->operands[0].data);
                if (proc < HALMAT_SYT_MAX && state->symbol_def_pos[proc] == NO_TARGET &&
                    state->external_calls && state->external_calls[proc].target_state) {
                    /* Cross-unit call into a separately-compiled EXTERNAL
                     * PROCEDURE (source-documentation/Multiple-file-
                     * problem.md) -- see run_external_call(). No result
                     * to copy back (procedures don't return a value). */
                    run_external_call(state, state->external_calls[proc].target_state,
                                       state->external_calls[proc].target_entry_syt, out);
                    break;
                }
                if (proc >= HALMAT_SYT_MAX || state->symbol_def_pos[proc] == NO_TARGET) {
                    fail(state, "call to undefined procedure (symbol %u)", proc);
                    break;
                }
                {
                    bool bind_ok = true;
                    uint8_t param_pos = 0;
                    uint16_t param_syt = 0;
                    for (uint8_t i = 0; i < state->io_pending.item_count && bind_ok; i++) {
                        if (!item_is_struct_replay_continuation(state->io_pending.items, i)) {
                            param_syt = resolve_param_syt(state, proc, param_pos++);
                        }
                        if (param_syt >= HALMAT_SYT_MAX) { fail(state, "too many call arguments"); bind_ok = false; break; }
                        /* ASSIGN-only parameter (state.h's is_assign
                         * comment): no real input value exists for it
                         * (`CALL P(...) ASSIGN(Y);` transmits nothing in
                         * for the parameter Y binds to -- only the
                         * write-*back* after return, at OP_XXND). Binding
                         * one anyway -- from the caller's own possibly-
                         * never-assigned ASSIGN-argument variable --
                         * previously pre-typed the parameter's SYT entry
                         * (write_syt_entry's first-write inference) before
                         * the procedure body's own first real assignment
                         * to it ever ran, permanently locking in the wrong
                         * kind whenever that first real assignment was
                         * itself a whole-valued-VAC-sourced IASN (this
                         * project's own already-known IASN quirk, class-6/
                         * IASN.md) -- the procedure-local destination's
                         * correct SCALAR type IS available via the symbol
                         * table by the time IASN's own fix-up runs, but
                         * only helps on a genuine *first* write. Skipping
                         * the bind entirely leaves the parameter fresh
                         * (SYT_TYPE_UNKNOWN) each call, exactly like any
                         * other never-yet-written procedure-local
                         * variable, letting that first real assignment
                         * establish its type correctly on its own. */
                        if (state->io_pending.items[i].is_assign) continue;
                        bind_ok = bind_call_argument(state, state, param_syt, i);
                    }
                    if (!bind_ok) break;
                }
                if (state->call_return_sp >= 64) { fail(state, "call nesting too deep"); break; }
                state->call_return_stack[state->call_return_sp++] = state->pc;
                state->pc = state->symbol_def_pos[proc] + 1;
                branched = true;
                break;
            }

            case OP_FCAL: {
                if (!state->io_pending.active || !state->io_pending.is_call) {
                    fail(state, "FCAL outside of an XXST...XXND call block");
                    break;
                }
                if (ins->operand_count != 1) { fail(state, "FCAL: expected 1 operand"); break; }
                uint16_t callee = resolve_call_target(state, ins->operands[0].data);
                if (callee < HALMAT_SYT_MAX && state->symbol_def_pos[callee] == NO_TARGET &&
                    state->external_calls && state->external_calls[callee].target_state) {
                    /* Cross-unit call into a separately-compiled EXTERNAL
                     * FUNCTION (source-documentation/Multiple-file-
                     * problem.md) -- see run_external_call(). Copy the
                     * callee's captured RTRN result into *this* call's
                     * own VAC slot, the same place a same-unit call's
                     * result would land. */
                    halmat_state_t *target = state->external_calls[callee].target_state;
                    uint16_t entry_syt = state->external_calls[callee].target_entry_syt;
                    if (!run_external_call(state, target, entry_syt, out)) break;
                    interp_copy_external_call_result(state, target, ins);
                    break;
                }
                if (callee >= HALMAT_SYT_MAX || state->symbol_def_pos[callee] == NO_TARGET) {
                    fail(state, "call to undefined function (symbol %u)", callee);
                    break;
                }
                /* Positional argument binding: SYT callee+1+i, per
                 * class-0/FCAL.md's confirmed convention (generalized via
                 * resolve_param_syt for a forward-referenced callee --
                 * see that function's own comment). */
                {
                    bool bind_ok = true;
                    uint8_t param_pos = 0;
                    uint16_t param_syt = 0;
                    for (uint8_t i = 0; i < state->io_pending.item_count && bind_ok; i++) {
                        if (!item_is_struct_replay_continuation(state->io_pending.items, i)) {
                            param_syt = resolve_param_syt(state, callee, param_pos++);
                        }
                        if (param_syt >= HALMAT_SYT_MAX) { fail(state, "too many call arguments"); bind_ok = false; break; }
                        /* ASSIGN-only parameter: see OP_PCAL's own,
                         * identical comment above -- same reasoning
                         * applies unchanged to a FUNCTION with its own
                         * ASSIGN/output parameter(s). */
                        if (state->io_pending.items[i].is_assign) continue;
                        bind_ok = bind_call_argument(state, state, param_syt, i);
                    }
                    if (!bind_ok) break;
                }
                if (state->call_return_sp >= 64) { fail(state, "call nesting too deep"); break; }
                state->call_return_stack[state->call_return_sp++] = state->pc;
                state->pc = state->symbol_def_pos[callee] + 1;
                branched = true;
                break;
            }

            case OP_IDEF:
                /* Opens an inline FUNCTION block (class-0/IDEF.md) --
                 * unlike FCAL, no branch: the block's own HALMAT already
                 * appears in-line in the stream and simply falls
                 * through. Pushed so the matching RTRN (see below) knows
                 * which VAC slot to write its result to. */
                if (state->inline_func_sp >= 16) { fail(state, "inline FUNCTION nesting too deep"); break; }
                state->inline_func_stack[state->inline_func_sp++] = state->pc;
                break;

            case OP_ICLS:
                /* Closes the inline FUNCTION block opened by the most
                 * recent IDEF (class-0/ICLS.md); pure bracket, no
                 * runtime effect of its own beyond popping the stack IDEF
                 * pushed -- the RTRN inside already wrote the result. */
                if (state->inline_func_sp <= 0) { fail(state, "ICLS with no active inline FUNCTION"); break; }
                state->inline_func_sp--;
                break;

            case OP_RTRN: {
                /* Two forms (class-0/RTRN.md): 1 operand = function
                 * return value (result flows back via the FCAL's own VAC
                 * slot); 0 operands = procedure/task return (no value --
                 * used by PCAL-initiated calls, which have no VAC result
                 * to write). Inline-FUNCTION form (class-0/IDEF.md): a
                 * RTRN reached with no active FCAL/PCAL call frame but an
                 * open IDEF instead writes its result to the IDEF's own
                 * VAC slot (mirroring FCAL's role) and simply falls
                 * through (no branch -- IDEF.md's confirmed trace shows
                 * the inline body already appears in-line in the
                 * instruction stream, unlike a real subprogram body
                 * defined elsewhere). External-call form (source-
                 * documentation/Multiple-file-problem.md): a RTRN
                 * reached with no active call frame at all, while this
                 * state is being run as a run_external_call() target,
                 * instead captures its result (if any) for the *caller*
                 * (a different state entirely) to retrieve, and signals
                 * completion via halted=true -- the same signal CLOS's
                 * existing "primal process closing" branch already gives
                 * for an ordinary top-level program falling through
                 * without an explicit RETURN. */
                if (ins->operand_count > 1) { fail(state, "RTRN: expected 0 or 1 operands"); break; }
                if (state->call_return_sp <= 0) {
                    if (state->inline_func_sp > 0) {
                        if (ins->operand_count != 1) { fail(state, "RTRN: inline FUNCTION requires a return value"); break; }
                        if (!resolve_operand(state, &ins->operands[0], &a)) break;
                        size_t idef_pos = state->inline_func_stack[state->inline_func_sp - 1];
                        size_t vac_index = state->prog->instrs[idef_pos].index;
                        if (vac_index >= HALMAT_VAC_MAX) { fail(state, "VAC index out of range"); break; }
                        store_resolved_to_vac(&state->vac[vac_index], &a);
                        break;
                    }
                    if (state->in_external_call) {
                        if (ins->operand_count == 1) {
                            if (!resolve_operand(state, &ins->operands[0], &a)) break;
                            store_resolved_to_vac(&state->external_call_result, &a);
                            state->external_call_has_result = true;
                        }
                        state->halted = true;
                        break;
                    }
                    /* No active call frame, no inline-FUNCTION, not an
                     * external-call target: a top-level (PROGRAM- or
                     * TASK-body-level) RETURN, most commonly reached as
                     * the terminator of an ON-ERROR/ERSE-triggered inline
                     * action body -- ends the process/task exactly like
                     * naturally falling through to CLOS would (see
                     * close_current_process's own comment). An earlier
                     * version of this branch instead failed loudly here
                     * ("RTRN with no active call") -- user-reported via a
                     * real ON-ERROR-DO-block RETURN (194-TEST_X.hal,
                     * matching USA003087 p.194's own worked example),
                     * which also reported the process hanging afterward
                     * rather than halting cleanly; the exact mechanism
                     * for that second symptom wasn't independently
                     * reproduced/traced this session (fail() itself
                     * already sets state->halted, so it's not simply "the
                     * same failing instruction re-executed forever" in
                     * the single-task case this was checked against) --
                     * this fix addresses the dispatch/termination gap
                     * directly rather than the hang symptom specifically. */
                    close_current_process(state, &branched);
                    break;
                }
                if (ins->operand_count == 1) {
                    /* Whole VECTOR/MATRIX RETURN (`RETURN RESULT;`, RESULT
                     * a whole VECTOR/MATRIX SYT reference, or a VAC-
                     * carried container result of a chained VECTOR/MATRIX
                     * expression like `RETURN A + B;`) -- user-reported
                     * (134-DOTS.hal's `RETURN RESULT;`, RESULT a `MATRIX
                     * (10,10)`, this file's own second bug once the
                     * "I/O statement has too many items" fix let
                     * execution get this far): resolve_operand's ordinary
                     * QUAL_SYT case requires arrayed_index >= 0 (an
                     * active ADLP/DLPE replay) and fails loudly on a bare
                     * whole-array reference outside one -- exactly this
                     * shape, since RETURN's own operand is never replay-
                     * wrapped -- so a container must be resolved via
                     * resolve_container() (no such restriction) and
                     * stored via store_container_result() (the same
                     * container-producing mechanism DSUB's own asterisk-
                     * select and MADD/VADD/etc. use), not treated as a
                     * scalar value at all. Checked and handled *before*
                     * the ordinary resolve_operand() path below, mirroring
                     * the identical whole_syt/whole_vac detection XXAR's
                     * own WRITE/CALL-argument capture code already uses
                     * for the same "unreplayed whole-container reference"
                     * shape. Deliberately scoped to VECTOR/MATRIX only
                     * (syt_is_vector_or_matrix_shaped, not the broader
                     * syt_is_array_shaped -- HAL/S has no confirmed
                     * whole-ARRAY FUNCTION return type/idiom), and to
                     * this genuine same-unit call-frame branch only --
                     * the inline-FUNCTION and external-call RTRN forms
                     * just above still only handle resolved_value_t's
                     * plain SCALAR/CHARACTER/BIT/INTEGER kinds
                     * (store_resolved_to_vac has no container case
                     * either), left as still-deferred, unconfirmed gaps
                     * of their own (no corpus file found needing an
                     * inline or cross-unit FUNCTION to return a whole
                     * VECTOR/MATRIX) rather than guessed at now. */
                    bool ret_whole_syt = ins->operands[0].qual == QUAL_SYT &&
                                          syt_is_vector_or_matrix_shaped(state, ins->operands[0].data);
                    bool ret_whole_vac = ins->operands[0].qual == QUAL_VAC && ins->operands[0].data < HALMAT_VAC_MAX &&
                                          state->vac[ins->operands[0].data].is_container;
                    /* `RETURN X.V;` (V a VECTOR terminal of a STRUCTURE-
                     * typed parameter/variable X) -- a *qualified*
                     * structure-field reference, QUAL_XPT, distinct from
                     * ret_whole_syt/ret_whole_vac's own plain-SYT/VAC
                     * shapes. state->vac[...].struct_field_syt holds the
                     * target *field's* own SYT index for a qualified
                     * reference (as opposed to the *template's* index a
                     * bare/unqualified whole-structure reference like
                     * ARG carries -- OP_XXAR's dest_is_structure/
                     * is_structure comments' own hal_class==0x3E check),
                     * so this only needs to confirm that field is itself
                     * VECTOR-shaped (class 4, cols>0) before routing
                     * through the same resolve_container()/
                     * store_container_result() path. User-reported,
                     * 172-OUTER.hal's `UTIL: FUNCTION(X) VECTOR; ...
                     * RETURN X.V; CLOSE UTIL;`. */
                    bool ret_whole_xpt = false;
                    if (ins->operands[0].qual == QUAL_XPT && ins->operands[0].data < HALMAT_VAC_MAX &&
                        state->vac[ins->operands[0].data].is_struct_ref && state->symtab) {
                        const halmat_symtab_entry_t *fsym = halmat_symtab_find_by_index(state->symtab, state->vac[ins->operands[0].data].struct_field_syt);
                        ret_whole_xpt = fsym && fsym->hal_class == 4 && fsym->cols > 0;
                    }
                    if (ret_whole_syt || ret_whole_vac || ret_whole_xpt) {
                        halmat_scalar_t *elems; size_t count; int rows, cols;
                        if (!resolve_container(state, &ins->operands[0], &elems, &count, &rows, &cols)) break;
                        size_t fcal_pos = state->call_return_stack[--state->call_return_sp];
                        size_t vac_index = state->prog->instrs[fcal_pos].index;
                        if (!store_container_result(state, vac_index, elems, count, rows, cols)) break;
                        state->pc = fcal_pos + 1;
                        branched = true;
                        break;
                    }
                    if (!resolve_operand(state, &ins->operands[0], &a)) break;
                    size_t fcal_pos = state->call_return_stack[--state->call_return_sp];
                    size_t vac_index = state->prog->instrs[fcal_pos].index;
                    if (vac_index >= HALMAT_VAC_MAX) { fail(state, "VAC index out of range"); break; }
                    /* User-reported (128-MASS.hal's `WRITE(6)
                     * MASS(REST_MASS, SPEED);`, MASS a same-unit,
                     * non-inline SCALAR-returning FUNCTION called via an
                     * ordinary FCAL/RTRN pair): this always forced the
                     * return value through rv_to_integer() regardless of
                     * the function's real declared return type, silently
                     * rounding every SCALAR (or CHARACTER/BIT) result to
                     * an INTEGER -- MASS's own relativistic-mass result
                     * stayed close enough to 1.0 for any realistic input
                     * that this rounded to a constant "1" every time,
                     * masking the bug as "always prints 1" rather than an
                     * obviously-wrong value. The inline-FUNCTION case just
                     * above already gets this right via
                     * store_resolved_to_vac() (kind-preserving: RV_SCALAR/
                     * RV_STRING/RV_BITS/RV_INTEGER each land in their own
                     * VAC slot field) -- this same-unit ordinary-call case
                     * had simply never been given the same treatment.
                     * Apparently never exercised by any prior fixture:
                     * every existing SCALAR/CHARACTER-returning FUNCTION
                     * fixture is either EXTERNAL (cross-unit, a completely
                     * separate result-copy path, interp_copy_external_
                     * call_result) or INLINE (the IDEF/ICLS branch just
                     * above) -- this is the first real corpus program
                     * found to call an ordinary same-unit FUNCTION and
                     * actually look at its non-INTEGER return value. */
                    store_resolved_to_vac(&state->vac[vac_index], &a);
                    if (a.kind == RV_BITS && state->symtab) {
                        /* User-reported (129-ALMOST_EQUAL.hal's `WRITE(6)
                         * ..., ALMOST_EQUAL(1.0, 1.0);`, ALMOST_EQUAL a
                         * same-unit FUNCTION declared BOOLEAN -- a
                         * synonym for BIT(1), USA003087's own
                         * terminology): a FUNCTION-call result carries no
                         * declared width of its own the way a plain SYT
                         * variable reference does (WRITE's own argument-
                         * capture code, further down, already looks up a
                         * plain SYT operand's declared width via the
                         * symbol table for exactly this reason -- see its
                         * own comment) -- so every BOOLEAN function's
                         * result printed as a full 32-bit binary field
                         * (this project's own established "no declared
                         * width known, default to 32" fallback,
                         * appropriate for a bare BIT literal/computed
                         * BAND/BOR/BNOT result, but wrong here: the real
                         * width genuinely *is* known, from the callee's
                         * own declared return type). Re-derives the
                         * callee's SYT index the exact same way FCAL
                         * itself did (resolve_call_target on the FCAL
                         * instruction's own first operand, at fcal_pos --
                         * handles the IND CALL LABEL alias case
                         * identically too) and, if the symbol table gives
                         * it a real declared bit_width, stamps it onto
                         * this VAC slot for the WRITE-argument-capture
                         * code (or any other BIT-consuming site) to
                         * prefer over the generic 32-bit default. */
                        uint16_t callee_op = state->prog->instrs[fcal_pos].operands[0].data;
                        uint16_t callee = resolve_call_target(state, callee_op);
                        const halmat_symtab_entry_t *csym = halmat_symtab_find_by_index(state->symtab, callee);
                        if (csym && csym->bit_width > 0) {
                            state->vac[vac_index].bit_width = csym->bit_width;
                        }
                    }
                    state->pc = fcal_pos + 1;
                } else {
                    size_t call_pos = state->call_return_stack[--state->call_return_sp];
                    state->pc = call_pos + 1;
                }
                branched = true;
                break;
            }

            case OP_CLOS:
                if (state->call_return_sp > 0) {
                    /* Implicit return (procedure with no explicit RETURN,
                     * or a fallthrough past the last statement) -- no
                     * return value is available here. */
                    size_t fcal_pos = state->call_return_stack[--state->call_return_sp];
                    state->pc = fcal_pos + 1;
                    branched = true;
                } else {
                    close_current_process(state, &branched);
                }
                break;

            case OP_SCHD: {
                /* Full tag decode per class-0/SCHD.md's primary-source-
                 * confirmed bitmask (PASS1.PROCS/SYNTHESI.xpl's <SCHEDULE
                 * HEAD>/<SCHEDULE PHRASE>/<SCHEDULE CONTROL> construction
                 * of INX(REFER_LOC)) -- every field below is exclusive
                 * within its own bit range, so a plain switch/if-chain on
                 * each extracted sub-field covers every legal combination
                 * with no guessing. Operands appear in strict left-to-
                 * right source order (SCHD.md's confirmed general rule):
                 * task, [AT/IN-exp or ON-event], [priority], [EVERY/AFTER-
                 * exp], [stop-exp-or-event] -- operand_idx just walks that
                 * fixed sequence, skipping whichever clauses the tag says
                 * aren't present. */
                if (ins->operand_count < 1 || ins->operands[0].qual != QUAL_SYT) {
                    fail(state, "SCHD: expected task symbol as first operand");
                    break;
                }
                uint16_t task_sym = ins->operands[0].data;
                if (task_sym >= HALMAT_SYT_MAX || state->symbol_def_pos[task_sym] == NO_TARGET) {
                    fail(state, "SCHEDULE of undefined task (symbol %u)", task_sym);
                    break;
                }

                uint8_t init_kind = ins->tag & 0x3;          /* 0=immediate, 1=AT, 2=IN, 3=ON */
                bool has_priority = (ins->tag & 0x4) != 0;
                bool dependent = (ins->tag & 0x8) != 0;
                uint8_t repeat_bits = (ins->tag & 0x30) >> 4; /* 0=none, 1=bare, 2=EVERY, 3=AFTER -- matches halmat_schd_repeat_t's own numbering */
                uint8_t stop_bits = (ins->tag & 0xC0) >> 6;   /* 0=none, 1=UNTIL-time, 2=WHILE-bit, 3=UNTIL-bit -- matches halmat_schd_stop_t's own numbering */
                /* repeat_bits==0 && stop_bits!=0 (STOPPING with no
                 * REPEAT/TIMING at all) is grammatically legal per SCHD.md's
                 * <SCHEDULE CONTROL> ::= <STOPPING> alternative, and HALSFC
                 * really does accept and compile it. SCHD.md's Unresolved
                 * Questions section researched its *runtime* semantics at
                 * length and found them genuinely undocumented in the
                 * primary source -- but that research also settles what
                 * this interpreter should do: SYNTHESI.xpl's own grammar
                 * action for this case is a bare no-op (no special-casing
                 * vs. the cyclic <TIMING><STOPPING> form -- it just ORs in
                 * whatever bits <STOPPING> contributes), and USA003087
                 * frames a stopping condition exclusively as "cancel the
                 * next cycle" (Sec. 23.4-23.5), a concept with no meaning
                 * for a process that has no next cycle to begin with. This
                 * interpreter already implements exactly that: below, a
                 * freshly scheduled (non-self, non-repeating) task gets
                 * repeat_kind==SCHD_REPEAT_NONE, and OP_CLOS's rearm check
                 * only ever consults stop_kind when repeat_kind !=
                 * SCHD_REPEAT_NONE (defaulting to "stop" unconditionally
                 * otherwise) -- so simply falling through here, parsing and
                 * storing the stop-exp-or-event operand like any other
                 * clause, reproduces the bare-no-op behavior precisely: the
                 * condition is accepted and stored but never consulted, and
                 * the task terminates normally at its first CLOS regardless
                 * of it. (A *self*-reschedule with no REPEAT is a different
                 * case, already handled below: it synthesizes an implicit
                 * one-shot repeat_kind of its own, so a STOPPING clause
                 * paired with it becomes a genuine, well-defined cyclic
                 * stop check -- not a guess either, just the existing
                 * self-rearm mechanism composing naturally with this one.) */

                int64_t at_in_value = 0;
                halmat_operand_t on_event_op = {0};
                uint8_t operand_idx = 1;
                if (init_kind == 1 || init_kind == 2) { /* AT or IN: VAC ref to the arith exp */
                    if (operand_idx >= ins->operand_count) { fail(state, "SCHD: missing AT/IN operand"); break; }
                    if (!resolve_operand(state, &ins->operands[operand_idx], &a)) break;
                    if (!schd_seconds_to_ticks(state, &a, "SCHD: AT/IN", false, &at_in_value)) break;
                    operand_idx++;
                } else if (init_kind == 3) { /* ON <bit exp>: plain EVENT SYT ref (SCHD.md's confirmed "no
                                               * VAC needed" case) or a QUAL_VAC compound BAND/BOR/BNOT
                                               * event-expression chain (239-STARTUP.hal's `ON (ORBIT &
                                               * (ORBIT2 & ORBIT3))`) -- either way, stored as-is and
                                               * re-evaluated live by reevaluate_live_bit_operand()
                                               * wherever it's actually consulted, never resolved here. */
                    if (operand_idx >= ins->operand_count ||
                        (ins->operands[operand_idx].qual != QUAL_SYT && ins->operands[operand_idx].qual != QUAL_VAC)) {
                        fail(state, "SCHD: ON expects a plain EVENT symbol or BAND/BOR/BNOT event-expression operand");
                        break;
                    }
                    on_event_op = ins->operands[operand_idx];
                    operand_idx++;
                }

                int priority = 50; /* default when no PRIORITY(...) clause; matches the primal's own default, but untested -- no primary-source confirmation for this specific case */
                if (has_priority) {
                    if (operand_idx >= ins->operand_count) { fail(state, "SCHD: missing PRIORITY operand"); break; }
                    if (!resolve_operand(state, &ins->operands[operand_idx], &a)) break;
                    priority = rv_to_integer(&a);
                    operand_idx++;
                }
                if (priority <= 0 || priority >= 255) {
                    fail(state, "SCHEDULE priority %d out of range 0<P<255 (USA003087 Sec. 13.1-13.3)", priority);
                    break;
                }

                int32_t repeat_interval = 0;
                if (repeat_bits == 2 || repeat_bits == 3) { /* EVERY or AFTER: VAC ref to the arith exp */
                    if (operand_idx >= ins->operand_count) { fail(state, "SCHD: missing REPEAT EVERY/AFTER operand"); break; }
                    if (!resolve_operand(state, &ins->operands[operand_idx], &a)) break;
                    int64_t repeat_interval64;
                    if (!schd_seconds_to_ticks(state, &a, "SCHD: REPEAT EVERY/AFTER", true, &repeat_interval64)) break;
                    repeat_interval = (int32_t)repeat_interval64;
                    operand_idx++;
                }

                int64_t stop_deadline = 0;
                halmat_operand_t stop_event_op = {0};
                if (stop_bits == 1) { /* UNTIL <ARITH EXP>: VAC ref to the time-valued exp */
                    if (operand_idx >= ins->operand_count) { fail(state, "SCHD: missing WHILE/UNTIL operand"); break; }
                    if (!resolve_operand(state, &ins->operands[operand_idx], &a)) break;
                    if (!schd_seconds_to_ticks(state, &a, "SCHD: WHILE/UNTIL <time>", false, &stop_deadline)) break;
                    operand_idx++;
                } else if (stop_bits == 2 || stop_bits == 3) { /* WHILE/UNTIL <BIT EXP>: plain SYT ref or a
                                                                  * QUAL_VAC compound BAND/BOR/BNOT chain,
                                                                  * same as ON above (238-P.hal's `REPEAT
                                                                  * EVERY 1/6 UNTIL ORBIT AND ENGINE_OFF`). */
                    if (operand_idx >= ins->operand_count ||
                        (ins->operands[operand_idx].qual != QUAL_SYT && ins->operands[operand_idx].qual != QUAL_VAC)) {
                        fail(state, "SCHD: WHILE/UNTIL <bit exp> expects a plain event symbol or BAND/BOR/BNOT event-expression operand");
                        break;
                    }
                    stop_event_op = ins->operands[operand_idx];
                    operand_idx++;
                }

                if (operand_idx != ins->operand_count) {
                    fail(state, "SCHD: operand count %u doesn't match tag 0x%X's expected clauses", ins->operand_count, ins->tag);
                    break;
                }

                if (state->symbol_active_task[task_sym] == state->current_task &&
                    !state->tasks[state->current_task].is_primal) {
                    /* A task scheduling *itself*, from within its own body
                     * (e.g. `NEST: TASK; ...; SCHEDULE NEST IN 1.0
                     * PRIORITY(80); CLOSE NEST;` -- a user-reported bug).
                     * USA003087 Sec. 13.4's "only one process derived from
                     * a given task block may be active at any given time"
                     * (p. 13-2/160) does NOT forbid this: per the same
                     * page's own definition, a process is "active" iff it
                     * is *in the process queue*; a task rescheduling
                     * itself doesn't add a second entry to the queue, it
                     * changes its own (sole, still-in-the-queue) entry's
                     * minor state from EXECUTING to WAITING/READY -- the
                     * exact same "rearm in place" transition CLOS's
                     * existing REPEAT EVERY/AFTER/bare handling already
                     * implements below for a *declaratively* cyclic task
                     * (`SCHEDULE label REPEAT EVERY ...`). A self-SCHEDULE
                     * from inside the body is the same mechanism spelled
                     * imperatively instead of declaratively, so this
                     * reuses that exact rearm path: rather than creating a
                     * new task-table entry (which really would violate
                     * Sec. 13.4, and is still correctly rejected below for
                     * a *different* process targeting an already-active
                     * task), just update *this* task's own rearm
                     * parameters -- CLOS's unmodified rearm switch (a few
                     * hundred lines down) picks them up when this task
                     * naturally falls through to its own CLOSE right
                     * after this statement, exactly as it already does for
                     * an externally-declared REPEAT. */
                    halmat_task_t *cur = &state->tasks[state->current_task];
                    cur->priority = priority;
                    cur->dependent = dependent;
                    if (repeat_bits != 0) {
                        /* An explicit REPEAT EVERY/AFTER clause on this
                         * self-SCHEDULE call -- honor it exactly as
                         * external scheduling would. */
                        cur->repeat_kind = (halmat_schd_repeat_t)repeat_bits;
                        cur->repeat_interval = repeat_interval;
                    } else if (init_kind == 3) {
                        /* Self-reschedule via ON <event>, no explicit REPEAT
                         * clause -- same "spelled imperatively instead of
                         * declaratively" equivalence as the AT/IN case just
                         * below, but for the ON initiation form: synthesize
                         * a rearm that waits on the event again rather than
                         * a fixed deadline. SCHD_REPEAT_ON (state.h) is an
                         * interpreter-internal rearm kind for exactly this;
                         * CLOS's rearm switch further down sets task_state
                         * back to TASK_WAITING_ON using has_on_event/
                         * on_event_op, the same fields/mechanism a
                         * brand-new ON-initiated task uses
                         * (sched_wake_on_events() re-checks every tick). */
                        cur->repeat_kind = SCHD_REPEAT_ON;
                        cur->has_on_event = true;
                        cur->on_event_op = on_event_op;
                    } else {
                        /* No REPEAT clause -- synthesize the equivalent
                         * one-shot rearm from the plain immediate/AT/IN
                         * form, per SCHD_REPEAT_AFTER's own documented
                         * "delay measured from this cycle's completion"
                         * semantics (which is exactly what a self-
                         * scheduled IN/AT, executed right before this same
                         * cycle's own completion, means). */
                        cur->repeat_kind = (init_kind == 0) ? SCHD_REPEAT_BARE : SCHD_REPEAT_AFTER;
                        cur->repeat_interval = (init_kind == 1)
                            ? (at_in_value > state->virtual_time ? at_in_value - state->virtual_time : 0)
                            : at_in_value; /* init_kind==2 (IN): already a relative delay */
                    }
                    if (cur->repeat_kind == SCHD_REPEAT_EVERY) cur->every_phase_ref = state->virtual_time;
                    if (stop_bits != 0) {
                        cur->stop_kind = (halmat_schd_stop_t)stop_bits;
                        cur->stop_deadline = stop_deadline;
                        cur->stop_event_op = stop_event_op;
                    } else {
                        cur->stop_kind = SCHD_STOP_NONE;
                    }
                    break;
                }
                if (state->symbol_active_task[task_sym] != -1) {
                    /* A *different* process targeting a task that's still
                     * active (not the self-reschedule case just above) --
                     * this is not a placeholder gap, it's a genuine HAL/S
                     * language constraint violation, correctly rejected:
                     * USA003087 Sec. 13.4 (p. 160/13-2) states "only one
                     * process derived from a given task block may be
                     * active at any given time", where "active" means "in
                     * the process queue" (the same definition that made
                     * the self-reschedule case above legal -- that case
                     * doesn't add a second queue entry, this one would).
                     * There's no "rearm in place" reading available here
                     * the way there is for self-reschedule, since this
                     * calling process isn't the one occupying that task's
                     * sole queue entry -- see class-0/SCHD.md's
                     * "Self-Rescheduling Tasks" section, "Genuinely still
                     * unsupported, and still correctly rejected". */
                    fail(state, "SCHEDULE: task is already active -- only one process derived from a given task block may be active at any given time (USA003087 Sec. 13.4)");
                    break;
                }
                if (state->task_count >= HALMAT_MAX_TASKS) { fail(state, "too many concurrent tasks"); break; }
                int idx = state->task_count++;
                halmat_task_t *nt = &state->tasks[idx];
                nt->in_use = true;
                nt->is_primal = false;
                nt->parent_task = state->current_task;
                nt->symbol = task_sym;
                nt->priority = priority;
                nt->saved_pc = state->symbol_def_pos[task_sym] + 1;
                nt->dependent = dependent;
                nt->repeat_kind = (halmat_schd_repeat_t)repeat_bits;
                nt->repeat_interval = repeat_interval;
                nt->stop_kind = (halmat_schd_stop_t)stop_bits;
                nt->stop_deadline = stop_deadline;
                nt->stop_event_op = stop_event_op;
                /* every_phase_ref (state.h) holds REPEAT EVERY's own
                 * phase reference, kept separate from wake_deadline so an
                 * internal WAIT in the task's body can't corrupt it --
                 * default to "now" (this SCHD's own execution tick) so a
                 * bare/ON/immediate-start cyclic task's first period is
                 * measured from here; overridden just below for AT/IN,
                 * whose own target is the more natural first reference
                 * point. Mirrors wake_deadline's own default/override
                 * below for exactly the same reason -- at this moment,
                 * before the task has ever run, both fields agree. */
                nt->wake_deadline = state->virtual_time;
                nt->every_phase_ref = state->virtual_time;

                switch (init_kind) {
                    case 1: /* AT <absolute virtual time> */
                        nt->task_state = TASK_WAITING;
                        nt->wake_deadline = at_in_value;
                        nt->every_phase_ref = at_in_value;
                        break;
                    case 2: /* IN <relative delay> */
                        nt->task_state = TASK_WAITING;
                        nt->wake_deadline = state->virtual_time + at_in_value;
                        nt->every_phase_ref = nt->wake_deadline;
                        break;
                    case 3: /* ON <bit exp>: no fixed deadline, re-checked every tick (state.h's TASK_WAITING_ON) */
                        nt->task_state = TASK_WAITING_ON;
                        nt->has_on_event = true;
                        nt->on_event_op = on_event_op;
                        break;
                    default: /* immediate */
                        nt->task_state = TASK_READY;
                        break;
                }
                state->symbol_active_task[task_sym] = idx;
                /* No branch here -- SCHD only adds the task to the pool;
                 * the scheduler loop in interp_run naturally picks it up
                 * next if it's immediately READY and higher-priority than
                 * whatever is currently executing, or lets the current
                 * flow continue otherwise (delayed/ON forms aren't READY
                 * at all yet). */
                break;
            }

            case OP_WAIT: {
                /* Four forms, distinguished by operand count and the
                 * opcode line's own trailing tag field (class-0/WAIT.md's
                 * confirmed encoding, all three original forms' operand-
                 * word shape verified against a real `HALSFC
                 * --parms=LSTALL` trace):
                 * WAIT interval (tag=1, one VAC operand, relative to now);
                 * WAIT UNTIL time (tag=2, one VAC operand, an *absolute*
                 * virtual-time-in-seconds value -- same convention as
                 * SCHD's own AT clause and STOPPING...UNTIL's stop_deadline
                 * just above, both of which compare directly against
                 * state->virtual_time rather than adding it); WAIT FOR
                 * DEPENDENT (tag=0, no operands, USA003087 Sec. 13.5 --
                 * "wait until all dependent processes have terminated"),
                 * reusing has_active_dependents()/sched_wake_dependents()'s
                 * existing re-check-every-tick mechanism (state.h's
                 * TASK_WAITING_FOR_DEPENDENTS comment) via the new
                 * TASK_WAITING_FOR_DEPENDENTS_RESUME state, which resumes
                 * (TASK_READY) rather than terminating the task the way
                 * the CLOSE-triggered TASK_WAITING_FOR_DEPENDENTS case
                 * does -- this task's own body isn't finished yet.
                 *
                 * WAIT FOR <event expression> (tag=3, one operand,
                 * USA003087 Sec. 24.6 -- a *separate* WAIT form from all
                 * three above, documented in its own later chapter rather
                 * than alongside them in Sec. 13.5: "causes a process to
                 * remain in a waiting state until some event expression
                 * becomes TRUE" -- user-reported, 242-P.hal's plain
                 * `WAIT FOR DONE;`/`WAIT FOR DO_SOMETHING;` (both a bare
                 * EVENT symbol) and, once task #47's compound-event-
                 * expression support landed, a QUAL_VAC BAND/BOR/BNOT
                 * chain operand works here too via the same
                 * reevaluate_live_bit_operand() mechanism SCHD's ON/
                 * WHILE/UNTIL clauses use. Reuses TASK_WAITING_ON/
                 * sched_wake_on_events() verbatim -- the exact same "re-
                 * evaluate the live event expression every tick, become
                 * READY once nonzero" mechanism SCHD's ON-initiation form
                 * already established, just entered from a *currently
                 * running* task instead of at SCHD-creation time (already
                 * proven safe for that too -- see the ON-event self-
                 * reschedule case elsewhere in this same file). */
                halmat_task_t *cur = &state->tasks[state->current_task];
                if (ins->tag == 0 && ins->operand_count == 0) {
                    cur->task_state = TASK_WAITING_FOR_DEPENDENTS_RESUME;
                    break;
                }
                if (ins->tag == 3 && ins->operand_count == 1) {
                    if (ins->operands[0].qual != QUAL_SYT && ins->operands[0].qual != QUAL_VAC) {
                        fail(state, "WAIT: FOR expects a plain EVENT symbol or BAND/BOR/BNOT event-expression operand");
                        break;
                    }
                    cur->task_state = TASK_WAITING_ON;
                    cur->has_on_event = true;
                    cur->on_event_op = ins->operands[0];
                    break;
                }
                if (ins->operand_count != 1 || (ins->tag != 1 && ins->tag != 2)) {
                    fail(state, "WAIT: expected 1 operand (interval, UNTIL, or FOR form) or 0 (FOR DEPENDENT)");
                    break;
                }
                if (!resolve_operand(state, &ins->operands[0], &a)) break;
                /* Not narrowed to int32_t: unlike repeat_interval (a real,
                 * fixed-width int32_t field of halmat_task_t), WAIT's tick
                 * count is only ever added into wake_deadline (int64_t) --
                 * there's no persisted 32-bit field it must fit into, and
                 * at HALMAT_TICKS_PER_SECOND=276000, a real (if unusually
                 * long) WAIT(10000) already exceeds INT32_MAX ticks, so
                 * narrowing here would fail loudly on a perfectly ordinary
                 * interval. want_int32=false matches at_in_value/
                 * stop_deadline's own int64_t treatment above. */
                int64_t ticks;
                if (!schd_seconds_to_ticks(state, &a, "WAIT", false, &ticks)) break;
                if (ticks < 0) ticks = 0;
                cur->task_state = TASK_WAITING;
                cur->wake_deadline = (ins->tag == 2) ? ticks : state->virtual_time + ticks;
                break;
            }

            case OP_CANC: {
                /* CANCEL statement (class-0/CANC.md): gracefully cancels
                 * a cyclic process, removing it from the run queue --
                 * same observable effect as TERM for this interpreter's
                 * purposes (no distinct "cyclic re-arm" state is
                 * modeled, since SCHD's cyclic REPEAT EVERY/AFTER forms
                 * aren't implemented either -- see OP_SCHD above), so
                 * this reuses TERM's exact self/named-form logic. */
                if (ins->operand_count == 0) {
                    halmat_task_t *cur = &state->tasks[state->current_task];
                    cur->task_state = TASK_TERMINATED;
                    if (cur->symbol < HALMAT_SYT_MAX) state->symbol_active_task[cur->symbol] = -1;
                } else {
                    for (uint8_t i = 0; i < ins->operand_count; i++) {
                        if (ins->operands[i].qual != QUAL_SYT) { fail(state, "CANC: expected SYT operand"); break; }
                        uint16_t sym = ins->operands[i].data;
                        if (sym < HALMAT_SYT_MAX && state->symbol_active_task[sym] != -1) {
                            int idx = state->symbol_active_task[sym];
                            state->tasks[idx].task_state = TASK_TERMINATED;
                            state->symbol_active_task[sym] = -1;
                        }
                    }
                }
                break;
            }

            case OP_SGNL: {
                /* SIGNAL statement (class-0/SGNL.md): makes an EVENT
                 * data item transiently TRUE. Modeled as a direct BIT
                 * write to the target's SYT entry (bit_value=1) -- the
                 * "transient" (auto-reset) aspect and WAIT-ON-EVENT
                 * consumption aren't modeled, since this interpreter has
                 * no EVENT-aware WAIT form yet (only WAIT's interval
                 * form is implemented -- see OP_WAIT above); no fixture
                 * currently observes the target afterward, so this is a
                 * safe, honest partial implementation rather than a
                 * silent no-op. */
                if (ins->operand_count != 1 || ins->operands[0].qual != QUAL_SYT) {
                    fail(state, "SGNL: expected one SYT operand");
                    break;
                }
                uint16_t sym = ins->operands[0].data;
                if (sym >= HALMAT_SYT_MAX) { fail(state, "SGNL: SYT index out of range"); break; }
                halmat_syt_entry_t *e = &state->syt[sym];
                e->type = SYT_TYPE_BIT;
                e->bit_value = 1;
                break;
            }

            case OP_TERM: {
                if (ins->operand_count == 0) {
                    /* Self form. */
                    halmat_task_t *cur = &state->tasks[state->current_task];
                    cur->task_state = TASK_TERMINATED;
                    if (cur->symbol < HALMAT_SYT_MAX) state->symbol_active_task[cur->symbol] = -1;
                } else {
                    /* Named/list form: terminating an inactive/already-
                     * finished task is a no-op (USA003087's "removed
                     * from the process queue" framing), not an error. */
                    for (uint8_t i = 0; i < ins->operand_count; i++) {
                        if (ins->operands[i].qual != QUAL_SYT) { fail(state, "TERM: expected SYT operand"); break; }
                        uint16_t sym = ins->operands[i].data;
                        if (sym < HALMAT_SYT_MAX && state->symbol_active_task[sym] != -1) {
                            int idx = state->symbol_active_task[sym];
                            state->tasks[idx].task_state = TASK_TERMINATED;
                            state->symbol_active_task[sym] = -1;
                        }
                    }
                }
                break;
            }

            case OP_PRIO: {
                /* UPDATE PRIORITY [label] TO alpha; (class-0/PRIO.md,
                 * USA003087 Sec. 13.5) -- changes an active process's
                 * scheduling priority (sched_pick_next() picks the
                 * highest task->priority among TASK_READY tasks, same
                 * field SCHEDULE...PRIORITY(...) already sets at task
                 * creation, OP_SCHD above). Confirmed operand order:
                 * operand 0 = the new priority value (LIT in every
                 * compiled trace seen; resolve_operand also covers a
                 * VAC/SYT-expression form per PRIO.md's own "reasonable
                 * but untested" note, so this doesn't hard-code LIT),
                 * operand 1 = the named process's own SYT symbol,
                 * present only for the named form -- unlabeled/self form
                 * (operand_count==1, priority only) mirrors CANC/TERM's
                 * already-confirmed self-vs-named distinction just below,
                 * a reasonable inference from the same family of
                 * statements though PRIO.md itself flags this specific
                 * form as untested. Updating an inactive/already-finished
                 * named process's priority is a no-op, not an error --
                 * same disposition as TERM's own named form (there's
                 * nothing left to schedule). */
                if (ins->operand_count < 1 || ins->operand_count > 2) {
                    fail(state, "PRIO: expected 1 (self) or 2 (named) operands");
                    break;
                }
                if (!resolve_operand(state, &ins->operands[0], &a)) break;
                int32_t new_priority = rv_to_integer(&a);
                if (ins->operand_count == 1) {
                    state->tasks[state->current_task].priority = new_priority;
                } else {
                    if (ins->operands[1].qual != QUAL_SYT) { fail(state, "PRIO: expected SYT process operand"); break; }
                    uint16_t sym = ins->operands[1].data;
                    if (sym < HALMAT_SYT_MAX && state->symbol_active_task[sym] != -1) {
                        state->tasks[state->symbol_active_task[sym]].priority = new_priority;
                    }
                }
                break;
            }

            case OP_PMHD:
            case OP_PMAR:
            case OP_PMIN:
                /* %macro invocation (class-0/PMHD.md/PMAR.md/PMIN.md):
                 * a small, fixed set of compiler-predefined utility
                 * macros (%SVC, %NAMEBIAS, %NAMECOPY, %COPY, %SVCI,
                 * %NAMEADD) that compile directly to raw AP-101S
                 * machine instructions (confirmed: %SVC(5) literally
                 * emits an SVC -- supervisor call -- trap instruction),
                 * not portable HALMAT-level semantics. Deliberately out
                 * of scope, per this project's own stated boundary
                 * (yaHALMAT2 interprets HALMAT, never AP-101S object
                 * code) -- failing loudly here with a specific message
                 * rather than silently no-opping, since ignoring an SVC
                 * call could hide behavior a real program depends on. */
                fail(state, "opcode 0x%03X (%s): %%macro invocations (%%SVC etc.) compile to raw "
                            "AP-101S machine instructions with no portable HALMAT-level semantics -- "
                            "out of scope for this interpreter",
                     ins->opcode, ins->opcode == OP_PMHD ? "PMHD" : ins->opcode == OP_PMAR ? "PMAR" : "PMIN");
                break;

            default: {
                const opcode_desc_t *desc = opcode_lookup(ins->opcode);
                fail(state, "opcode 0x%03X (%s) not yet implemented", ins->opcode,
                     desc ? desc->mnemonic : "????");
                break;
            }
        }

        if (!state->halted && !branched) {
            state->pc++;
        }
    }
}

/* Replays one arrayed paragraph (ADLP/IDLP's per-array-element loop, or
 * an SLRI's own n#value repeated-initialize loop, both precomputed by
 * precompute_arrayed_paragraphs) `count` times, recursing into any
 * nested SLRI-driven paragraph found inside its own body instead of
 * executing it as a plain no-op (exec_one's behavior for a bare SLRI/
 * ELRI reached without going through this function) -- needed for
 * USA003087 Sec. 16.2's nested repetition-factor form (`n#(v1, m#v2)`),
 * confirmed this session against a real compile of `INITIAL(4#(1,5#0),
 * 1)` (meant as a 5x5 identity matrix, previously miscomputed with no
 * nesting support at all: a naive flat single-level replay treats a
 * nested SLRI/ELRI as inert markers, so the inner `5#0` group's value
 * was written once instead of five times, at the wrong offsets).
 *
 * `unit_size` is 0 for an ADLP/IDLP-driven entry (plain per-index
 * arrayed_index, exactly the pre-existing single-level behavior) or the
 * SLRI's own confirmed "elements per repeated unit" operand (its 2nd
 * operand, class-8/SLRI.md) for an SLRI-driven entry. `outer_base` is
 * the accumulated offset contribution from every already-active
 * enclosing level (0 at the top-level call). Each level's own
 * contribution to a QUAL_OFF write's absolute offset
 * (write_destination, interp.c) is `idx*unit_size`, added to
 * `outer_base` -- confirmed against the identity-matrix repro: the
 * outer SLRI's unit_size=6 (its repeated group `(1,5#0)` spans 6
 * elements) and the inner SLRI's unit_size=1 give absolute offset
 * outer_idx*6 + inner_idx*1 + this_instruction's own OFF operand,
 * exactly matching every element of the expected identity matrix. */
static void run_arrayed_paragraph(halmat_state_t *state, FILE *out, size_t start, size_t end,
                                   int count, int unit_size, int32_t outer_base) {
    for (int idx = 0; idx < count && !state->halted; idx++) {
        int32_t level_base = unit_size > 0 ? outer_base + idx * unit_size : idx;
        state->arrayed_index = level_base;
        state->pc = start;
        while (state->pc < end && !state->halted) {
            /* state->pc == start is excluded here: that position is
             * necessarily *this call's own* registered entry (it's
             * exactly how the caller found `start`/`end` in the first
             * place), not a genuinely different nested paragraph --
             * checking it unconditionally would immediately re-detect
             * and recurse into this very call with identical arguments,
             * infinitely (confirmed by a real stack-overflow segfault
             * before this guard was added). Any *actually* nested SLRI
             * always registers its own entry at a position strictly
             * after `start` (one past its own instruction slot), so this
             * exclusion never hides a real nested paragraph. */
            size_t nested_end = state->pc == start ? NO_TARGET : state->arrayed_paragraph_end[state->pc];
            if (nested_end != NO_TARGET && nested_end <= end) {
                int nested_count = state->arrayed_paragraph_count[state->pc];
                int nested_unit = state->arrayed_paragraph_unit_size[state->pc];
                run_arrayed_paragraph(state, out, state->pc, nested_end, nested_count, nested_unit, level_base);
                state->pc = nested_end;
                state->arrayed_index = level_base; /* restore -- the nested call left its own iterations' values here */
            } else {
                exec_one(state, out);
            }
        }
    }
}

/* Highest-priority TASK_READY task, or -1 if none are ready (everything
 * is TERMINATED or TASK_WAITING). */
static int sched_pick_next(halmat_state_t *state) {
    int best = -1;
    for (int i = 0; i < state->task_count; i++) {
        if (!state->tasks[i].in_use || state->tasks[i].task_state != TASK_READY) continue;
        if (best == -1 || state->tasks[i].priority > state->tasks[best].priority) best = i;
    }
    return best;
}

static void sched_wake_waiting(halmat_state_t *state) {
    for (int i = 0; i < state->task_count; i++) {
        if (state->tasks[i].in_use && state->tasks[i].task_state == TASK_WAITING &&
            state->tasks[i].wake_deadline <= state->virtual_time) {
            state->tasks[i].task_state = TASK_READY;
        }
    }
}

/* Live re-evaluation of a SCHEDULE ON/WHILE/UNTIL or WAIT FOR event
 * expression, USA003087 Sec. 24.6: "the value of exp becomes TRUE...
 * evaluations of EV1&EV2 by the RTE" -- the expression must be
 * re-evaluated from the *current* state of every EVENT symbol it
 * mentions each time it's consulted, not read once and cached, since
 * any of those EVENTs can change after the original SCHEDULE/WAIT
 * statement executed. `op` is either QUAL_SYT (a plain EVENT reference,
 * read directly -- state->syt[...].bit_value is already always live) or
 * QUAL_VAC referencing a BAND/BOR/BNOT instruction (`ORBIT & (ORBIT2 &
 * ORBIT3)`, `ORBIT | ENGINE_OFF`, the only opcodes a compound HAL/S
 * event bit-expression can compile to) -- looked up by its own stream
 * position in state->prog->instrs[] (the same array random-access
 * disasm.c/DSUB's "ins->index" convention already relies on) and
 * recursively re-evaluated the same way, rather than reading the stale
 * snapshot that instruction's own one-time execution left in
 * state->vac[]. User-reported: 239-STARTUP.hal's `SCHEDULE FREEFALL ON
 * (ORBIT & (ORBIT2 & ORBIT3))`, 238-P.hal's `REPEAT EVERY 1/6 UNTIL
 * ORBIT AND ENGINE_OFF`. Fails loudly for any other node opcode rather
 * than guessing -- HAL/S event expressions are documented as bit
 * expressions built purely from BAND/BOR/BNOT of EVENT operands
 * (Sec. 24.3/24.6), so nothing else should ever appear here. */
static bool reevaluate_live_bit_operand(halmat_state_t *state, const halmat_operand_t *op, uint32_t *out) {
    if (op->qual == QUAL_SYT) {
        if (op->data >= HALMAT_SYT_MAX) { fail(state, "event expression: SYT index out of range"); return false; }
        *out = state->syt[op->data].bit_value;
        return true;
    }
    if (op->qual == QUAL_VAC) {
        /* A QUAL_VAC operand's own `data` is the raw HALMAT *word*
         * position of its producing instruction, not that instruction's
         * logical array index into prog->instrs[] (which advances by
         * one per instruction regardless of operand count, diverging
         * from the word position after the first multi-operand
         * instruction) -- this project's own established VAC-addressing
         * convention (see the near-identical comment on the QUAL_VAC
         * same-statement-dependency scan elsewhere in this file). Binary
         * search rather than that scan's bounded linear walk, since an
         * event-expression chain isn't confined to a nearby window the
         * way same-statement VAC dependencies are -- .index is
         * monotonically non-decreasing across the whole program. */
        if (!state->prog) { fail(state, "event expression: no program loaded"); return false; }
        size_t lo = 0, hi = state->prog->count;
        while (lo < hi) {
            size_t mid = lo + (hi - lo) / 2;
            if (state->prog->instrs[mid].index < op->data) lo = mid + 1;
            else hi = mid;
        }
        if (lo >= state->prog->count || state->prog->instrs[lo].index != op->data) {
            fail(state, "event expression: no instruction at word #%u", op->data);
            return false;
        }
        const halmat_instr_t *node = &state->prog->instrs[lo];
        if (node->opcode == OP_BAND || node->opcode == OP_BOR) {
            if (node->operand_count != 2) { fail(state, "event expression: BAND/BOR expected 2 operands"); return false; }
            uint32_t l, r;
            if (!reevaluate_live_bit_operand(state, &node->operands[0], &l)) return false;
            if (!reevaluate_live_bit_operand(state, &node->operands[1], &r)) return false;
            *out = (node->opcode == OP_BAND) ? (l & r) : (l | r);
            return true;
        }
        if (node->opcode == OP_BNOT) {
            if (node->operand_count != 1) { fail(state, "event expression: BNOT expected 1 operand"); return false; }
            uint32_t v;
            if (!reevaluate_live_bit_operand(state, &node->operands[0], &v)) return false;
            *out = ~v;
            return true;
        }
        fail(state, "event expression: unsupported node opcode 0x%03X at word #%zu", node->opcode, node->index);
        return false;
    }
    fail(state, "event expression: unsupported operand qualifier %s", halmat_qual_name(op->qual));
    return false;
}

/* SCHD's ON <bit exp> initiation (state.h's TASK_WAITING_ON): unlike
 * TASK_WAITING's fixed wake_deadline, there's no way to know in advance
 * *when* (or whether) some other task's SIGNAL will flip the event, so
 * this has to actually re-evaluate the live expression every tick
 * rather than being folded into sched_advance_to_next_wake's fast-
 * forward -- see that function's comment for why TASK_WAITING_ON is
 * deliberately left out of it. */
static void sched_wake_on_events(halmat_state_t *state) {
    for (int i = 0; i < state->task_count; i++) {
        halmat_task_t *t = &state->tasks[i];
        if (!t->in_use || t->task_state != TASK_WAITING_ON) continue;
        uint32_t v;
        if (reevaluate_live_bit_operand(state, &t->on_event_op, &v) && v != 0) {
            t->task_state = TASK_READY;
        }
    }
}

/* True if any task still has `parent_task_idx` as its parent_task and
 * hasn't yet reached TASK_TERMINATED -- USA003087 Sec. 13.3's
 * "dependents" check for a process reaching CLOSE/RETURN. Only a task
 * scheduled with DEPENDENT (state.h's `dependent` field) counts as an
 * actual dependent the parent must wait for; an independent child of
 * this same parent doesn't block it (it's still bound by the separate,
 * unconditional "all other processes are always dependent on the primal
 * process for their existence" rule, Sec. 13.1, enforced instead by the
 * primal's own eventual halt cutting off everything at once). */
static bool has_active_dependents(const halmat_state_t *state, int parent_task_idx) {
    for (int i = 0; i < state->task_count; i++) {
        const halmat_task_t *t = &state->tasks[i];
        if (t->in_use && t->dependent && t->parent_task == parent_task_idx && t->task_state != TASK_TERMINATED) {
            return true;
        }
    }
    return false;
}

/* Re-checked every tick (no fixed deadline to fast-forward to, same
 * reasoning as TASK_WAITING_ON/sched_wake_on_events -- a dependent's own
 * termination could come from an arbitrary CANCEL/TERMINATE/stop
 * condition elsewhere, not a fixed time this function could predict):
 * finalizes any TASK_WAITING_FOR_DEPENDENTS task whose dependents have
 * all now terminated (USA003087 Sec. 13.3 -- see state.h's
 * TASK_WAITING_FOR_DEPENDENTS comment). The primal finalizing this way
 * halts the whole interpreter (Sec. 13.1's overriding dependency-on-
 * primal rule cuts off everything else at that point, the same way its
 * CLOS handler already did when there were no dependents to begin with);
 * an ordinary task instead just completes its own now-deferred
 * termination. */
static void sched_wake_dependents(halmat_state_t *state) {
    for (int i = 0; i < state->task_count; i++) {
        halmat_task_t *t = &state->tasks[i];
        if (!t->in_use || has_active_dependents(state, i)) continue;
        if (t->task_state == TASK_WAITING_FOR_DEPENDENTS) {
            if (t->is_primal) {
                state->halted = true;
                state->exit_code = 0;
            } else {
                t->task_state = TASK_TERMINATED;
                if (t->symbol < HALMAT_SYT_MAX) state->symbol_active_task[t->symbol] = -1;
            }
        } else if (t->task_state == TASK_WAITING_FOR_DEPENDENTS_RESUME) {
            /* `WAIT FOR DEPENDENT;` (state.h's own comment): unlike the
             * CLOSE-triggered wait just above, this task's body isn't
             * finished -- resume it, don't terminate it. */
            t->task_state = TASK_READY;
        }
    }
}

/* If every in-use task is either TERMINATED, TASK_WAITING_ON, or
 * TASK_WAITING (nothing READY right now, but something will eventually
 * wake), fast-forwards state->virtual_time to the earliest pending
 * wake_deadline and re-applies sched_wake_waiting -- otherwise the
 * interpreter would incorrectly treat "nothing is READY this instant" as
 * "the program has ended" even though a WAIT(n)/delayed SCHD is due to
 * expire later, since virtual_time (per state.h's scheduler comment) only
 * otherwise advances one tick per *executed* instruction, and no
 * instruction executes while every task is blocked. A no-op when
 * something is already READY or truly nothing is left (all TERMINATED).
 * TASK_WAITING_ON tasks are deliberately excluded from the "something will
 * eventually wake" determination -- an ON condition has no deadline to
 * fast-forward to, so if only TASK_WAITING_ON tasks remain (nothing left
 * that could ever SIGNAL the event they're waiting on), this correctly
 * falls through to "nothing left to run" rather than spinning forever;
 * that's a silent-starvation outcome (the ON task just never runs), not a
 * crash or a hang, and no fixture has hit it in practice. */
static void sched_advance_to_next_wake(halmat_state_t *state) {
    bool any_ready = false, any_waiting = false;
    int64_t earliest = 0;
    for (int i = 0; i < state->task_count; i++) {
        if (!state->tasks[i].in_use) continue;
        if (state->tasks[i].task_state == TASK_READY) { any_ready = true; break; }
        if (state->tasks[i].task_state == TASK_WAITING) {
            if (!any_waiting || state->tasks[i].wake_deadline < earliest) earliest = state->tasks[i].wake_deadline;
            any_waiting = true;
        }
    }
    if (!any_ready && any_waiting && earliest > state->virtual_time) {
        state->virtual_time = earliest;
        sched_wake_waiting(state);
    }
}

/* Runs the scheduler for exactly one instruction (picks the
 * highest-priority TASK_READY task, executes one instruction for it,
 * advances the virtual clock). Returns true once nothing is left to run
 * (halted, or no task is READY/ever going to wake). Exposed for
 * --debugger's step command; interp_run() is just this called in a loop. */
bool interp_step(halmat_state_t *state, FILE *out) {
    if (state->halted) return true;

    sched_wake_waiting(state);
    sched_wake_on_events(state);
    sched_wake_dependents(state);
    if (state->halted) return true; /* sched_wake_dependents just finalized the primal's own deferred CLOSE */
    sched_advance_to_next_wake(state);
    int next = sched_pick_next(state);
    if (next == -1) return true; /* nothing left ready (and nothing left to ever wake) */

    state->current_task = next;
    state->pc = state->tasks[next].saved_pc;

    if (state->pc >= state->prog->count) {
        fail(state, "instruction stream ended without a CLOS");
        return true;
    }

    /* Arrayed-paragraph replay (state.h's arrayed_paragraph_end/_count):
     * if this position starts a recognized ADLP-trailed paragraph or an
     * SLRI-led one, replay it via run_arrayed_paragraph() (handles
     * arbitrarily nested SLRI groups, see its own comment) instead of
     * executing it once -- see precompute_arrayed_paragraphs() and the
     * resolve_operand/write_destination QUAL_SYT/QUAL_OFF redirections
     * it enables. */
    size_t paragraph_end = state->arrayed_paragraph_end[state->pc];
    if (paragraph_end != NO_TARGET) {
        size_t paragraph_start = state->pc;
        int count = state->arrayed_paragraph_count[paragraph_start];
        int unit_size = state->arrayed_paragraph_unit_size[paragraph_start];
        run_arrayed_paragraph(state, out, paragraph_start, paragraph_end, count, unit_size, 0);
        state->arrayed_index = -1;
        if (!state->halted) state->pc = paragraph_end;
    } else {
        exec_one(state, out);
    }

    state->tasks[next].saved_pc = state->pc;
    /* 1 tick per HALMAT instruction executed -- unchanged, still the
     * interpreter's fundamental virtual-time granularity. WAIT/SCHD
     * intervals are converted from real seconds into however many of
     * these ticks that represents (schd_seconds_to_ticks(), OP_SCHD/
     * OP_WAIT above, via HALMAT_TICKS_PER_SECOND); interp_run()'s
     * wall-clock pacing (below) is a separate layer on top of this that
     * never changes the tick arithmetic itself, only how fast real time
     * elapses alongside it. */
    state->virtual_time++;

    return state->halted;
}

#ifdef _WIN32
static double monotonic_seconds(void) {
    static LARGE_INTEGER freq;
    static bool have_freq = false;
    if (!have_freq) {
        QueryPerformanceFrequency(&freq);
        have_freq = true;
    }
    LARGE_INTEGER count;
    QueryPerformanceCounter(&count);
    return (double)count.QuadPart / (double)freq.QuadPart;
}

static void sleep_seconds(double seconds) {
    if (seconds <= 0.0) return;
    /* Sleep() only takes whole milliseconds -- round up so this never
     * sleeps for less than the computed deficit. */
    DWORD ms = (DWORD)ceil(seconds * 1000.0);
    Sleep(ms);
}
#else
static double monotonic_seconds(void) {
    struct timespec ts;
    clock_gettime(CLOCK_MONOTONIC, &ts);
    return (double)ts.tv_sec + (double)ts.tv_nsec / 1e9;
}

static void sleep_seconds(double seconds) {
    if (seconds <= 0.0) return;
    struct timespec req;
    req.tv_sec = (time_t)seconds;
    req.tv_nsec = (long)((seconds - (double)req.tv_sec) * 1e9);
    nanosleep(&req, NULL);
}
#endif

/* Runs interp_step() in a loop (same as always) but paced against the
 * wall clock, per the project owner's own direction: "burst execute some
 * number of instructions, then sleep to let the operating system do
 * whatever else it needs to do, then execute a new burst ... on a 50 or
 * 100 millisecond cycle. This keeps you close to being synchronized with
 * real time from a human user's perception without really using much of
 * the CPU." Deliberately NOT inside interp_step() itself -- that stays a
 * pure virtual-time primitive shared by --debug's own run/step loop
 * (debug_run(), debug.c), which must NOT be throttled (time spent
 * blocked on debugger input must never count against real time).
 *
 * ref_wall/ref_virtual are reset together every time a pacing window's
 * threshold (window_ticks, ~HALMAT_REALTIME_BURST_MS worth of ticks) is
 * crossed: interp_step() is called repeatedly, accumulating virtual_time
 * ticks with no wall-clock check at all, until elapsed_virtual crosses
 * that threshold -- so the monotonic-clock read happens only ~20x/sec of
 * virtual-equivalent time, not once per instruction. This same check
 * also correctly handles sched_advance_to_next_wake()'s idle fast-
 * forward (a single interp_step() call that can jump virtual_time a
 * large amount at once, when every task is TASK_WAITING and nothing is
 * READY): that jump alone pushes elapsed_virtual past the threshold, and
 * the resulting sleep correctly represents the real elapsed time
 * equivalent to it -- sched_advance_to_next_wake() itself needs no
 * special-casing here at all.
 *
 * If a burst genuinely took longer in wall-clock terms than its virtual-
 * time equivalent (slow host, heavy/debug build), target_wall_seconds >
 * actual_wall_seconds is false, nothing sleeps, and the reference pair
 * simply resets to "now" -- no catch-up/runaway-acceleration debt ever
 * accumulates across windows; a stall is never made up for by later
 * blasting through instructions faster than real time. */
static int interp_run_burst(halmat_state_t *state, FILE *out) {
    double ref_wall = monotonic_seconds();
    int64_t ref_virtual = state->virtual_time;
    int64_t window_ticks = (int64_t)(HALMAT_TICKS_PER_SECOND * (HALMAT_REALTIME_BURST_MS / 1000.0));

    while (!interp_step(state, out)) {
        int64_t elapsed_virtual = state->virtual_time - ref_virtual;
        if (elapsed_virtual >= window_ticks) {
            double target_wall_seconds = (elapsed_virtual / (double)HALMAT_TICKS_PER_SECOND) / state->time_scale;
            double actual_wall_seconds = monotonic_seconds() - ref_wall;
            if (target_wall_seconds > actual_wall_seconds) {
                sleep_seconds(target_wall_seconds - actual_wall_seconds);
            }
            ref_wall = monotonic_seconds();
            ref_virtual = state->virtual_time;
        }
    }
    return state->exit_code;
}

/* interp_run_signal(): the alternative, signal/timer-notification-driven
 * pacing implementation, added purely for direct side-by-side comparison
 * against interp_run_burst() above (both implement the exact same
 * pacing contract -- see state.h's halmat_pacing_mode_t comment; select
 * with --pacing=signal, main.c). Where interp_run_burst() periodically
 * *asks* "how much wall-clock time has elapsed?" (a polling design whose
 * reaction granularity is bounded by how often it happens to check, i.e.
 * HALMAT_REALTIME_BURST_MS), this implementation is *notified*: a POSIX
 * per-process real-time timer (CLOCK_MONOTONIC, same clock source as
 * interp_run_burst() -- must not be affected by wall-clock/NTP
 * adjustments) delivers a real-time signal on a fixed schedule, and the
 * interpreter blocks (sigsuspend(), never a busy-poll) until notified,
 * rather than discovering drift only at its next scheduled check.
 *
 * SIGRTMIN+2 (a real-time signal), not SIGALRM: real-time signals queue
 * rather than coalescing multiple pending instances into one, so if
 * interp_step() occasionally takes a while (a genuinely slow
 * instruction, or the idle-fast-forward case below) no tick
 * notifications are silently lost while the interpreter is busy -- they
 * are delivered/counted once it catches up. (+2 rather than bare
 * SIGRTMIN on the untested-but-plausible theory that SIGRTMIN itself is
 * the first one anything else sharing this process might reach for.)
 *
 * The signal handler (pacing_signal_handler, below) does *only*
 * `pacing_flag = 1` -- a static volatile sig_atomic_t, nothing else
 * touched, no calls into interpreter state -- the same async-signal-safe
 * pattern discussed with the project owner. Race-free wait: the signal
 * is blocked up front (sigprocmask), then sigsuspend() atomically
 * unblocks it and sleeps until *some* unblocked signal arrives, closing
 * the check-then-sleep missed-wakeup window a naive
 * "if (!pacing_flag) sleep()" loop would leave open.
 *
 * Budget accounting mirrors interp_run_burst()'s own window (point 5 of
 * the project owner's spec, for an apples-to-apples comparison): each
 * timer firing grants HALMAT_TICKS_PER_SECOND * (HALMAT_REALTIME_BURST_MS
 * / 1000.0) * time_scale ticks of budget, exactly interp_run_burst()'s
 * own per-window tick count -- HALMAT_TICKS_PER_SECOND itself and every
 * SCHD/WAIT seconds-to-ticks conversion are untouched either way.
 *
 * Idle-fast-forward special case (point 4): sched_advance_to_next_wake()
 * (unchanged) can jump virtual_time far ahead in a single interp_step()
 * call when every task is TASK_WAITING/TASK_WAITING_ON and nothing is
 * READY. interp_run_burst() handles this for free (its check is purely
 * "how much virtual time has elapsed", regardless of how it
 * accumulated) -- but naively letting this fall through here would mean
 * looping on sigsuspend() through however many real timer firings the
 * gap represents (a 10-second idle gap at a 50ms window is ~200
 * firings): correct, but needlessly granular for a jump the interpreter
 * already knows about in one shot from a single virtual_time read.
 * Instead, once a step's tick delta exceeds a whole window's worth,
 * compute the equivalent real-time gap directly (same computation
 * interp_run_burst() already does) and sleep that directly, then resume
 * normal signal-driven pacing for the next window. */
#ifdef HAVE_POSIX_TIMERS

/* SIGRTMIN is not a compile-time constant on Linux glibc (it's a function
 * call, to allow for kernel-reserved real-time signals) -- fine, this is
 * only ever evaluated at runtime, never in a preprocessor conditional. */
#define HALMAT_PACING_RT_SIGNAL (SIGRTMIN + 2)

static volatile sig_atomic_t pacing_flag = 0;

static void pacing_signal_handler(int signo) {
    (void)signo;
    pacing_flag = 1;
}

static int interp_run_signal(halmat_state_t *state, FILE *out) {
    pacing_flag = 0;

    sigset_t rt_set;
    sigemptyset(&rt_set);
    sigaddset(&rt_set, HALMAT_PACING_RT_SIGNAL);

    struct sigaction sa, old_sa;
    memset(&sa, 0, sizeof(sa));
    sa.sa_handler = pacing_signal_handler;
    sigemptyset(&sa.sa_mask);
    sa.sa_flags = 0;
    if (sigaction(HALMAT_PACING_RT_SIGNAL, &sa, &old_sa) != 0) {
        fail(state, "interp_run_signal: sigaction failed: %s", strerror(errno));
        return state->exit_code;
    }

    /* Block the signal up front so it can never be delivered
     * asynchronously mid-check between interp_step() calls -- sigsuspend()
     * below is the only place it's ever transiently unblocked, atomically,
     * right before going to sleep for it. */
    sigset_t old_mask;
    if (sigprocmask(SIG_BLOCK, &rt_set, &old_mask) != 0) {
        fail(state, "interp_run_signal: sigprocmask failed: %s", strerror(errno));
        sigaction(HALMAT_PACING_RT_SIGNAL, &old_sa, NULL);
        return state->exit_code;
    }

    timer_t timerid;
    struct sigevent sev;
    memset(&sev, 0, sizeof(sev));
    sev.sigev_notify = SIGEV_SIGNAL;
    sev.sigev_signo = HALMAT_PACING_RT_SIGNAL;
    sev.sigev_value.sival_ptr = &timerid;
    if (timer_create(CLOCK_MONOTONIC, &sev, &timerid) != 0) {
        fail(state, "interp_run_signal: timer_create failed: %s", strerror(errno));
        sigprocmask(SIG_SETMASK, &old_mask, NULL);
        sigaction(HALMAT_PACING_RT_SIGNAL, &old_sa, NULL);
        return state->exit_code;
    }

    double window_seconds = HALMAT_REALTIME_BURST_MS / 1000.0;
    struct itimerspec its;
    its.it_value.tv_sec = (time_t)window_seconds;
    its.it_value.tv_nsec = (long)((window_seconds - (double)its.it_value.tv_sec) * 1e9);
    its.it_interval = its.it_value;
    if (timer_settime(timerid, 0, &its, NULL) != 0) {
        fail(state, "interp_run_signal: timer_settime failed: %s", strerror(errno));
        timer_delete(timerid);
        sigprocmask(SIG_SETMASK, &old_mask, NULL);
        sigaction(HALMAT_PACING_RT_SIGNAL, &old_sa, NULL);
        return state->exit_code;
    }

    int64_t window_ticks_budget =
        (int64_t)(HALMAT_TICKS_PER_SECOND * (HALMAT_REALTIME_BURST_MS / 1000.0) * state->time_scale);
    if (window_ticks_budget < 1) window_ticks_budget = 1;
    int64_t budget_ticks = 0;

    bool halted = false;
    while (!halted) {
        if (budget_ticks <= 0) {
            while (!pacing_flag) {
                sigsuspend(&old_mask);
            }
            pacing_flag = 0;
            budget_ticks += window_ticks_budget;
        }

        int64_t before_virtual = state->virtual_time;
        halted = interp_step(state, out);
        int64_t consumed = state->virtual_time - before_virtual;

        if (consumed > window_ticks_budget) {
            /* Idle fast-forward (see this function's own comment above) --
             * sleep the equivalent real time directly instead of waiting
             * out however many timer firings it represents. */
            double gap_seconds = (consumed / (double)HALMAT_TICKS_PER_SECOND) / state->time_scale;
            sleep_seconds(gap_seconds);
            budget_ticks = 0; /* resume ordinary signal-driven pacing next window */
        } else {
            budget_ticks -= consumed;
        }
    }

    timer_delete(timerid);
    sigprocmask(SIG_SETMASK, &old_mask, NULL);
    sigaction(HALMAT_PACING_RT_SIGNAL, &old_sa, NULL);
    return state->exit_code;
}

#elif defined(_WIN32)

/* Windows has no POSIX signals at all, so this uses the platform's own
 * equivalent primitives rather than trying to emulate signals:
 * CreateTimerQueueTimer() for the periodic notification -- which runs
 * its callback on a thread-pool thread, NOT synchronously on the main
 * thread, a real difference from POSIX signals interrupting the same
 * thread -- and a Win32 Event object (CreateEvent/SetEvent in the
 * callback, WaitForSingleObject in the main loop) as the equivalent of
 * sigsuspend()'s blocking wait, rather than a raw flag spin-polled in a
 * loop (which would defeat the entire "don't waste CPU" point).
 *
 * Because the callback runs on a separate thread, the tick-budget
 * bookkeeping can't just be a flag the way POSIX's sig_atomic_t works
 * (same-thread signal handlers get an implicit ordering guarantee a
 * plain cross-thread write does not). pacing_fired_count is instead a
 * genuine Interlocked (atomic) counter of how many timer periods have
 * fired since the main loop last serviced it -- not just a boolean --
 * for the same reason the POSIX side uses a *queuing* real-time signal
 * instead of SIGALRM: a plain auto-reset Event collapses any number of
 * un-waited SetEvent() calls into a single signaled state, which would
 * silently lose tick notifications if the callback fires again before
 * the main thread catches up (e.g. while it's blocked in a slow
 * interp_step()). Counting fired periods, then multiplying by
 * window_ticks_budget when serviced, avoids that loss. */
static volatile LONG pacing_fired_count = 0;

static void CALLBACK pacing_timer_callback(void *param, BOOLEAN timer_or_wait_fired) {
    (void)timer_or_wait_fired;
    InterlockedIncrement(&pacing_fired_count);
    SetEvent((HANDLE)param);
}

static int interp_run_signal(halmat_state_t *state, FILE *out) {
    pacing_fired_count = 0;

    HANDLE event = CreateEvent(NULL, FALSE, FALSE, NULL); /* auto-reset, initially unsignaled */
    if (!event) {
        fail(state, "interp_run_signal: CreateEvent failed (error %lu)", (unsigned long)GetLastError());
        return state->exit_code;
    }

    HANDLE timer = NULL;
    DWORD period_ms = (DWORD)HALMAT_REALTIME_BURST_MS;
    if (!CreateTimerQueueTimer(&timer, NULL, pacing_timer_callback, event, period_ms, period_ms,
                                WT_EXECUTEDEFAULT)) {
        fail(state, "interp_run_signal: CreateTimerQueueTimer failed (error %lu)", (unsigned long)GetLastError());
        CloseHandle(event);
        return state->exit_code;
    }

    int64_t window_ticks_budget =
        (int64_t)(HALMAT_TICKS_PER_SECOND * (HALMAT_REALTIME_BURST_MS / 1000.0) * state->time_scale);
    if (window_ticks_budget < 1) window_ticks_budget = 1;
    int64_t budget_ticks = 0;

    bool halted = false;
    while (!halted) {
        if (budget_ticks <= 0) {
            LONG fired;
            while ((fired = InterlockedExchange(&pacing_fired_count, 0)) == 0) {
                WaitForSingleObject(event, INFINITE);
            }
            budget_ticks += (int64_t)fired * window_ticks_budget;
        }

        int64_t before_virtual = state->virtual_time;
        halted = interp_step(state, out);
        int64_t consumed = state->virtual_time - before_virtual;

        if (consumed > window_ticks_budget) {
            /* Idle fast-forward -- see this function's own comment above
             * interp_run_signal's POSIX branch for the full reasoning
             * (identical here). */
            double gap_seconds = (consumed / (double)HALMAT_TICKS_PER_SECOND) / state->time_scale;
            sleep_seconds(gap_seconds);
            budget_ticks = 0;
        } else {
            budget_ticks -= consumed;
        }
    }

    /* INVALID_HANDLE_VALUE as the completion event makes this call block
     * until any in-flight callback finishes, so the timer is fully torn
     * down (no lingering thread-pool callback touching `event` after
     * it's closed) before returning. */
    DeleteTimerQueueTimer(NULL, timer, INVALID_HANDLE_VALUE);
    CloseHandle(event);
    return state->exit_code;
}

#else

/* Neither HAVE_POSIX_TIMERS (Makefile's build-time probe) nor _WIN32:
 * this target has no known reliable periodic-timer-plus-notification
 * primitive available (notably, real per-process interval timers via
 * timer_create()/timer_settime() have historically been unreliable or
 * absent on some BSD-family systems, including macOS, despite this
 * project's own Makefile listing Mac as a supported target). Fail
 * loudly and specifically rather than silently falling back to
 * interp_run_burst()'s behavior or crashing -- matches this project's
 * established "fail loudly, don't silently degrade" discipline. */
static int interp_run_signal(halmat_state_t *state, FILE *out) {
    (void)out;
    fail(state,
         "this build was compiled without POSIX real-time timer support -- "
         "rebuild with HAVE_POSIX_TIMERS, or use --pacing=burst");
    return state->exit_code;
}

#endif

int interp_run(halmat_state_t *state, FILE *out) {
    if (state->pacing_mode == HALMAT_PACING_SIGNAL) return interp_run_signal(state, out);
    return interp_run_burst(state, out);
}

const halmat_instr_t *interp_peek_next(halmat_state_t *state) {
    if (state->halted) return NULL;
    sched_wake_waiting(state);
    sched_wake_on_events(state);
    sched_wake_dependents(state);
    if (state->halted) return NULL;
    sched_advance_to_next_wake(state);
    int next = sched_pick_next(state);
    if (next == -1) return NULL;
    if (state->tasks[next].saved_pc >= state->prog->count) return NULL;
    return &state->prog->instrs[state->tasks[next].saved_pc];
}

int interp_peek_next_task(halmat_state_t *state) {
    if (state->halted) return -1;
    sched_wake_waiting(state);
    sched_wake_on_events(state);
    sched_wake_dependents(state);
    if (state->halted) return -1;
    sched_advance_to_next_wake(state);
    return sched_pick_next(state);
}

/* HAL/S statement number of the instruction interp_peek_next() would
 * return (see precompute_stmt_for_pc()'s comment for why this can't be
 * tracked incrementally as SMRK instructions execute), or -1 if there is
 * no next instruction (halted, or nothing left to run). For --debug's
 * source-line display. */
long interp_current_stmt_for_next(halmat_state_t *state) {
    if (state->halted) return -1;
    sched_wake_waiting(state);
    sched_wake_on_events(state);
    sched_wake_dependents(state);
    if (state->halted) return -1;
    sched_advance_to_next_wake(state);
    int next = sched_pick_next(state);
    if (next == -1) return -1;
    size_t pc = state->tasks[next].saved_pc;
    if (pc >= state->prog->count) return -1;
    return state->stmt_for_pc[pc];
}
