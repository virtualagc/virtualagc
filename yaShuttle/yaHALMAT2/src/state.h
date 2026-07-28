#ifndef HALMAT_STATE_H
#define HALMAT_STATE_H

#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>

#include "hal_random.h"
#include "halmat.h"
#include "literal.h"
#include "opcode_table.h" /* for the halmat_state_t typedef */
#include "symtab.h"
#include "value.h"

/* Logical device numbers, per class-0/XXAR.md's Unresolved-Questions note
 * on USA00309 Sec. 6.1.4's "device numbers 2-9 map to a fixed DD name"
 * JCL convention -- 0-9 is the whole implementation-defined range. Device
 * 5=input/6=output are wired to stdin/stdout by default (HAL/S language
 * convention, Plan.md Phase 3); --ddi/--ddo (main.c) can remap any device
 * to a file, including overriding 5/6. */
#define HALMAT_DEVICE_MAX 10

/* Ticks-per-(real-)second calibration for the virtual-clock scheduler
 * (see halmat_state_t's virtual_time/scheduler comment block below) --
 * sourced from the AP-101S Software Model PDF ("the POO", https://www.
 * ibiblio.org/apollo/Shuttle/Shuttle%20GPC%20Software%20Model%20AP-
 * 101S.pdf) plus an empirical HALMAT-to-AP-101S-instruction-count
 * sample, not a guess:
 *
 *   - Sec. 16.1 ("Instruction Execution - Pipeline Basics") states
 *     directly: "For the AP-101S computer, the pipeline cycle time is
 *     0.250 microseconds."
 *   - Sec. 17.0 ("AP-101S Instruction Execution Times") is a per-
 *     mnemonic table in microseconds; SCAL (subroutine call) = 18.125us
 *     and SVC (supervisor call) = 20.25us are the two entries that
 *     matter most for real HAL/S-compiled code, since runtime-library
 *     calls (I/O formatting, matrix/scalar math support routines) are a
 *     major real cost on this architecture, not just explicit HAL/S
 *     CALL statements.
 *   - To get the other half of the calibration -- how many AP-101S
 *     instructions a typical HALMAT instruction expands into -- 7
 *     representative existing test fixtures (test_int_arith2.hal,
 *     test_pcal.hal, test_scalar_arith.hal, test_write_lit.hal,
 *     test_bit.hal, test_matrix_sub.hal, test_cfor.hal) were compiled
 *     with HALSFC --parms="LSTALL" (reengineered-documentation/STATUS.md's
 *     LSTALL section) and pass2.rpt's interleaved HALMAT/generated-
 *     AP-101S-assembly listing was parsed. Aggregated across all 7:
 *     230 HALMAT instructions -> 188 AP-101S instructions, mnemonic mix
 *     dominated by SCAL (34 occurrences) and SVC (7), the remainder
 *     simple RR/RS/RI loads/stores/arithmetic priced via Sec. 16's
 *     format-class averages (RR=0.25us, SRS=0.375us, RS=0.5us
 *     steady-state pipelined cycles; ~0.4us used as a single
 *     representative "simple instruction" figure rather than chasing
 *     every individual mnemonic in an OCR'd/hand-transcribed table).
 *     This works out to ~3.62 us/HALMAT-instruction aggregate (per-
 *     fixture range 2.45-6.05 us, i.e. ~165,000-408,000 ticks/sec
 *     depending on program mix -- arithmetic-heavy code is cheaper per
 *     instruction, call/I-O-heavy code pricier).
 *
 * See reengineered-documentation/class-0/SCHD.md's "Real-time
 * calibration" section for the full writeup/derivation, including how
 * to redo or refine this sample. Deliberately rough (HAL/S source
 * doesn't determine exact AP-101S code shape) but sourced, not
 * asserted. */
#define HALMAT_TICKS_PER_SECOND 276000

/* interp_run()'s wall-clock pacing window (see its own comment in
 * interp.c): execute a burst of instructions, then check the wall
 * clock and sleep off any surplus, on roughly this cycle -- long enough
 * that the monotonic-clock read/sleep-syscall overhead is negligible
 * (~20 checks/sec of virtual-equivalent time), short enough to track
 * real time closely from a human user's perspective. Per the project
 * owner's own direction ("a 50 or 100 millisecond cycle"). */
#define HALMAT_REALTIME_BURST_MS 50

/* Which of interp.c's two interp_run() pacing implementations to use
 * (--pacing, main.c) -- both implement the identical "keep virtual_time
 * roughly in step with the wall clock" contract, added side by side for
 * direct comparison per the project owner's own request: HALMAT_PACING_
 * BURST is interp_run_burst()'s original polling design (periodically
 * compare elapsed virtual ticks against monotonic_seconds(), sleep off
 * any surplus); HALMAT_PACING_SIGNAL is interp_run_signal()'s POSIX
 * real-time-timer-driven alternative (a signal/platform-timer callback
 * notifies the interpreter instead of it having to ask). See interp.c's
 * comments on both for the full writeup. */
typedef enum { HALMAT_PACING_BURST, HALMAT_PACING_SIGNAL } halmat_pacing_mode_t;

/* Sized generously per yaHALMAT's precedent (see Plan.md M2); revisit
 * once a --memory-size CLI switch exists (Plan.md Phase 3 default is
 * meant to be AP-101S-realistic, pending the M0.1 PDF findings). */
#define HALMAT_SYT_MAX 4096

/* VAC is addressed directly by producing-instruction word index. This is
 * only correct within a single 1800-word record; cross-record VAC
 * references (top bit of DATA set, per HALMAT.md) aren't handled yet --
 * every fixture compiled so far fits in one record, so this is deferred
 * until a multi-record program is actually encountered. */
#define HALMAT_VAC_MAX HALMAT_RECORD_WORDS

/* ARRAY/MATRIX/VECTOR element storage. Declared dimensions aren't
 * visible in HALMAT itself (no ADLP-arrayed case carries them either --
 * see HALMAT.md's Optimizer-HALMAT notes) -- they come from the
 * compiler's own symbol table (COMMON*.out's SYM_TYPE/SYM_LENGTH/
 * SYM_ARRAY+EXTuARRAY fields, symtab.h/symtab.c) when it's available
 * (main.c auto-discovers/loads it same as litfile/memory; --py units
 * have none, degrading gracefully). When it's not available (or the
 * symbol isn't found in it), DSUB/MASN/etc fall back to a generic
 * flat buffer of this capacity with a placeholder stride -- correct
 * for simple single-dimension access, wrong for true multi-dimension
 * row-major addressing without the real extents. See interp.c's
 * ensure_container/DSUB/MASN-family handling. */
#define HALMAT_CONTAINER_CAPACITY 64

/* Maximum number of "hop" symbols an EXTN (class-0/EXTN.md) nested-
 * named-substructure reference can record between its base and its
 * final field/template operand (halmat_vac_slot_t's own
 * struct_mid_path comment) -- generous headroom over the deepest
 * confirmed real-corpus depth (176-P.hal's `STATE2.STATE.ACCEL.V`,
 * 2 hops: STATE, ACCEL). */
#define HALMAT_STRUCT_PATH_MAX 6

/* Row-major MATRIX(r,c) storage, per row: HAL/S itself is the actual
 * unresolved-primary-source question here (no MSC-01847/USA003087
 * page confirming row-major vs. column-major was found), but row-major
 * is the far more common convention and DSUB's own subscript-operand
 * order (row index first, per class-0/DSUB.md's confirmed trace)
 * matches a row-major flattening more naturally than column-major
 * would -- treated as the working assumption, not independently
 * confirmed. */

typedef enum {
    SYT_TYPE_UNKNOWN = 0,
    SYT_TYPE_INTEGER,
    SYT_TYPE_SCALAR,
    SYT_TYPE_CHARACTER,
    SYT_TYPE_BIT,
    SYT_TYPE_NAME,
} halmat_syt_type_t;

/* NAME (pointer) sentinel for "points at nothing" (NULL), distinct from
 * any valid SYT index (0 is itself a valid slot, hence ~0 not 0). */
#define HALMAT_NAME_NULL ((uint16_t)0xFFFFu)

typedef struct {
    halmat_syt_type_t type;
    int32_t value;          /* SYT_TYPE_INTEGER */
    halmat_scalar_t scalar; /* SYT_TYPE_SCALAR (plain, non-subscripted) */
    halmat_scalar_t *elements; /* non-NULL => this symbol is an ARRAY/MATRIX/VECTOR of SCALAR
                                 * or INTEGER (INTEGER ARRAY elements are boxed as scalar --
                                 * confirmed empirically that the compiler itself uses SINT,
                                 * not IINT, for an INTEGER ARRAY's element-list INITIAL()
                                 * form, so HALMAT never distinguishes the two at this level
                                 * either); lazily allocated. Mutually exclusive with
                                 * bit_elements/char_elements below -- exactly one of the
                                 * three is non-NULL once ensure_container() has run, per the
                                 * symbol's own declared ARRAY element type (symtab.h's
                                 * hal_class: 1=BIT, 2=CHARACTER, else numeric here);
                                 * MATRIX/VECTOR are always numeric (HAL/S has no BIT/
                                 * CHARACTER MATRIX/VECTOR). Without a symbol table (e.g.
                                 * --py mode) the element type can't be determined, so this
                                 * numeric form is always what gets allocated as a fallback. */
    size_t element_count;
    uint32_t *bit_elements; /* non-NULL => this symbol is an ARRAY of BIT (see `elements`
                              * above); parallel to `elements`, same element_count. Same
                              * "no declared-width tracking" caveat as bit_value below. */
    char **char_elements; /* non-NULL => this symbol is an ARRAY of CHARACTER (see
                            * `elements` above); parallel to `elements`, same
                            * element_count. Each entry is owned/malloc'd/NUL-terminated,
                            * like char_value below -- never NULL once allocated (starts
                            * as ""), so reads never need a NULL check. */
    int rows, cols; /* MATRIX(r,c): both set (row-major, r*c elements). VECTOR(n): cols=n, rows=0.
                      * Plain ARRAY(n): both 0 (element_count is authoritative, single dimension).
                      * A genuinely 2-dimensional ARRAY(r,c) of SCALAR/INTEGER, or an ARRAY(r) of
                      * VECTOR(c) (see array_of_vector below), both reuse this same rows/cols
                      * convention so DSUB's MATRIX-shaped indexing logic applies to them for free.
                      * Set by ensure_container() the first time the symbol's elements are
                      * allocated -- 0/0 also means "not yet allocated" together with elements==NULL. */
    bool array_of_vector; /* true only for the ARRAY(r) VECTOR(c) case above (rows=r, cols=c) --
                            * distinguishes it from a genuine MATRIX(r,c), which shares the same
                            * rows/cols encoding but must NOT be sliced by arrayed_index below.
                            * Set by ensure_container(); consulted by resolve_container()'s
                            * QUAL_SYT case, user-reported (117-EXAMPLE_8.hal's `[VELOCITY] =
                            * ([POSITIONS] - [OLD_POSN]) / DELTA_T;`, POSITIONS/OLD_POSN/VELOCITY
                            * all ARRAY(5) VECTOR): a whole-container arithmetic op (VSUB/VSDV/
                            * VASN/VDOT/BFNC's ABVAL/UNIT) on an ARRAY-of-VECTOR SYT operand,
                            * replayed once per array index by the ADLP/DLPE mechanism
                            * (arrayed_index, see below), must resolve to just the *one* VECTOR
                            * slice at the current arrayed_index each time -- not the whole flat
                            * container -- so it can combine correctly with a plain (un-arrayed)
                            * VECTOR operand on the other side (`ABVAL([POSITIONS] - MY_POSN)`,
                            * MY_POSN a plain VECTOR(3): a same-shape ARRAY-of-VECTOR pair would
                            * *coincidentally* still come out right if resolved as one flat whole-
                            * container op instead, elementwise math not caring about the VECTOR
                            * grouping, but the mixed-shape ABVAL/UNIT/VDOT cases in this same file
                            * prove that coincidence can't be relied on generally). */
    char *char_value; /* SYT_TYPE_CHARACTER; owned, malloc'd, NUL-terminated. No
                        * fixed-length/VARYING-vs-fixed truncation-or-padding
                        * behavior is implemented yet (class-2/CASN.md's
                        * Unresolved Questions) -- the string just grows/
                        * shrinks to fit whatever's assigned. */
    uint32_t bit_value; /* SYT_TYPE_BIT; raw pattern, no declared-width
                          * tracking -- BIT(n)'s truncation/padding rule
                          * is unconfirmed (class-1/BAND.md's Unresolved
                          * Questions), so AND/OR/NOT operate on the full
                          * 32-bit pattern as-is. */
    uint16_t name_target; /* SYT_TYPE_NAME; the SYT index this pointer
                            * refers to, or HALMAT_NAME_NULL. Only
                            * pointer *identity* is modeled (NASN/NEQU/
                            * NNEQ/NINT) -- dereferencing through a NAME
                            * to read/write its target's value (HAL/S's
                            * CONTENT pseudo-variable) isn't implemented,
                            * no fixture needs it yet. */
} halmat_syt_entry_t;

/* A VAC slot either holds a plain computed value (most opcodes: IADD,
 * comparisons, etc.) or -- when produced by DSUB -- a reference into an
 * ARRAY/MATRIX element, to be read (dereferenced) or written (write-
 * through) depending on which operand position it's used in by the
 * consuming instruction. See class-0/DSUB.md and interp.c's DSUB/
 * resolve_operand/write_destination. */
typedef struct {
    bool is_ref;
    bool is_scalar;         /* is_ref=false: true if this slot holds a SCALAR (e.g. SADD/SSUB) rather than INTEGER result */
    bool is_string;          /* is_ref=false: true if this slot holds a CHARACTER result (e.g. CCAT); takes priority over is_scalar */
    char *string;            /* is_ref=false, is_string; owned, malloc'd. VAC slots are
                               * reused across loop iterations (addressed by static
                               * stream position, not a fresh allocation per call) --
                               * re-running CCAT overwrites .string without freeing the
                               * prior iteration's buffer. Deliberately leaked rather
                               * than reference-counted/arena-managed: bounded by loop
                               * iteration count within one interpreter run, not a
                               * long-lived-process concern. Freed in bulk (best-effort,
                               * only the final value per slot) by interp_cleanup(). */
    bool is_bits;            /* is_ref=false, !is_string: true if this slot holds a BIT result (e.g. BAND/BOR/BNOT); takes priority over is_scalar */
    uint32_t bits;           /* is_ref=false, is_bits */
    int bit_width;           /* is_ref=false, is_bits: the value's real declared BIT(n) width, when
                               * known -- 0 (the default, via store_resolved_to_vac's own memset) means
                               * "unknown," the same "no declared-width tracking, default to 32"
                               * fallback already used for a bare BIT literal/computed BAND/BOR/BNOT
                               * result elsewhere in this file. Set only when the width genuinely is
                               * known some other way: OP_RTRN's own same-unit-call-frame branch, for a
                               * FUNCTION whose declared return type is BIT/BOOLEAN, sets this from the
                               * callee's own symtab-declared bit_width (BOOLEAN is a synonym for
                               * BIT(1), USA003087's own terminology) -- user-reported, 129-ALMOST_EQUAL.hal
                               * (`ALMOST_EQUAL: FUNCTION(A,B) BOOLEAN; ...`): its call result's own VAC
                               * slot carries no width of its own the way a plain SYT variable reference
                               * does (WRITE's own argument-capture code, further down, already looks up
                               * a plain SYT operand's declared width via the symbol table -- this is
                               * the equivalent lookup for a QUAL_VAC operand that's a FUNCTION-call
                               * result instead), so without this every BOOLEAN function's result
                               * printed as a full 32-bit field regardless of its real declared width. */
    bool is_container;       /* is_ref=false, !is_string, !is_bits: true if this slot holds a whole
                               * MATRIX/VECTOR intermediate result (e.g. MADD/VADD), consumed by a
                               * following MASN/VASN or another MATRIX/VECTOR op -- class-3/MADD.md's
                               * "no destination operand -- consumed by a following MASN via a VAC-
                               * qualified operand" pattern. Takes priority over is_scalar. */
    halmat_scalar_t *container; /* is_ref=false, is_container; owned, malloc'd -- heap, NOT an inline
                                  * array, since HALMAT_VAC_MAX (1800) slots x a fixed-size inline
                                  * buffer would balloon halmat_state_t (itself a local/stack variable
                                  * in main.c) by well over a megabyte, risking stack overflow on
                                  * platforms with small default stacks (Windows threads default to
                                  * 1 MiB -- a real concern per Plan.md's MSVC/cross-platform target).
                                  * Unlike the VAC string-buffer leak-across-loop-iterations tradeoff
                                  * above, interp.c's store_container_result() frees the previous
                                  * buffer before replacing it -- no accumulating leak here, just the
                                  * final value per slot freed again in bulk by interp_cleanup(). */
    size_t container_count;
    int container_rows, container_cols; /* is_container: shape, same convention as halmat_syt_entry_t's rows/cols */
    bool container_is_integer; /* is_container: true if this container's elements represent an INTEGER
                                 * ARRAY subscript result (e.g. `MISMATCH$(J,*)`, MISMATCH a 2D
                                 * `ARRAY(r,c) INTEGER` -- user-reported, 113-EXAMPLE_7.hal) rather than
                                 * SCALAR/VECTOR/MATRIX data (HAL/S has no INTEGER MATRIX/VECTOR, so this
                                 * is always false for a genuine MATRIX/VECTOR result). Set only by
                                 * OP_DSUB's own row/column/whole-vector asterisk-select branch, from the
                                 * DSUB instruction's own operator-word TAG (class-0/DSUB.md: "the HALMAT
                                 * class number of the subscripted result's type", 6=INTEGER) -- every
                                 * other store_container_result() caller leaves this at its default
                                 * (false), since none of them can ever legitimately produce INTEGER
                                 * data. Consulted by resolve_operand()'s own is_container per-element
                                 * read (below), the path an ADLP/DLPE replay uses to expand this
                                 * container into individual WRITE fields -- without this, every element
                                 * silently read back as RV_SCALAR regardless of the container's real
                                 * declared type. */
    /* Set *in addition to* is_container above (not exclusive with it --
     * deliberately additive, so the existing is_container-only read path
     * above is completely unaffected) when this container is also a
     * *live view* into another SYT's own storage -- possibly strided --
     * rather than a fully independent computed result. Currently set by
     * DSUB's asterisk-partition row-select (`M$(i,*)`, stride=1),
     * whole-vector (`V$(*)`, stride=1), and column-select (`M$(*,j)`,
     * stride=cols) cases. Lets MASN/VASN (interp.c) write straight back
     * into the selected row/column/vector when such a slot is used as an
     * *assignment receiver* (`M$(I,*) = ...;`) instead of only ever being
     * readable -- user-reported (047-ROWS.hal for the row/whole-vector
     * cases; column-select generalized in the same follow-up). The
     * component at-partition VECTOR-slice case (`V$(n AT p)`) deliberately
     * does NOT set this: confirmed via HALSFC that real HAL/S rejects
     * `V$(n AT p) = ...;` as a compile-time error (it type-checks the
     * partition against the whole vector's declared length, not the
     * slice), so no real program can ever exercise a writable form of it.
     * container_count above is reused as the write's own element count
     * (the two are always identical: this is the same slot the read-side
     * count already describes). */
    bool is_container_ref;
    uint16_t container_ref_syt;
    size_t container_ref_offset;
    size_t container_ref_stride; /* is_container_ref: element stride between
                                   * successive written values, in `rbase->
                                   * elements` units; 1 for every case except
                                   * column-select, where it's the MATRIX's
                                   * column count. */
    bool is_struct_ref;      /* is_ref=false, !is_string, !is_bits, !is_container: true if this slot
                               * holds an EXTN-resolved structure reference (class-0/EXTN.md) --
                               * (struct_base_syt, struct_field_syt), consumed by a following TASN/
                               * TEQU/TNEQ (whole-structure) or an ordinary xASN (single qualified
                               * field, e.g. ZQ1.QI=...) via a QUAL_XPT operand referencing EXTN's own
                               * stream position. Takes priority over is_scalar/is_container. */
    uint16_t struct_base_syt, struct_field_syt; /* is_struct_ref; struct_field_syt is the structure's
                               * own TEMPLATE symbol for a bare/unqualified reference (EXTN.md's
                               * confirmed "operand 2 = the TEMPLATE's own symbol" case) rather than a
                               * real field -- interp.c's TASN/TEQU/TNEQ treat that case specially. */
    uint16_t struct_mid_path[HALMAT_STRUCT_PATH_MAX]; /* is_struct_ref; every operand strictly between
                               * EXTN's base (struct_base_syt) and its final field/template symbol
                               * (struct_field_syt), in source order -- populated only for a *named*
                               * multi-level nested-substructure reference (yahalmat2_extn_multifile_
                               * template, 176-P.hal's `STATE2.STATE.ACCEL`/`STATE2.STATE.ACCEL.V`,
                               * STATE2 a plain STRUCTURE but STATE2.STATE and .ACCEL each themselves a
                               * *named*-sub-template field, i.e. `1 STATE STATEVEC-STRUCTURE`/`1 ACCEL
                               * SUPER_VECTOR-STRUCTURE` rather than a level-number sub-structure --
                               * confirmed empirically to compile to one EXTN with operand_count = 2 +
                               * however many named-sub-template hops the reference crosses, base first,
                               * final field/template last, every hop in between recorded here). Empty
                               * (struct_mid_path_len=0) for the ordinary, single-level EXTN(2) case
                               * (base + field/template only) that was this opcode's only previously-
                               * confirmed shape -- every existing call site/consumer is unaffected. */
    uint8_t struct_mid_path_len; /* is_struct_ref; see struct_mid_path. */
    int32_t struct_copy_index; /* is_struct_ref; -1 = "use the ambient current_copy_index() (interp.c)",
                               * the ordinary case for a ADLP/DLPE-driven multi-copy replay or a plain
                               * single-instance structure. >=0 = an *explicit* copy, set when this
                               * EXTN's base came from a TSUB single-copy-select (is_copy_ref below)
                               * rather than a plain SYT -- overrides the ambient index, since a
                               * TSUB-selected copy is fixed at compile-time/by-expression, independent
                               * of whatever replay (if any) happens to be active when this executes. */
    bool is_copy_ref;       /* is_ref=false, !is_string, !is_bits, !is_container, !is_struct_ref: true if
                               * this slot holds a TSUB single-copy-select result (class-0/TSUB.md),
                               * (copy_ref_base_syt, copy_ref_copy_index), consumed by a following EXTN
                               * via a QUAL_VAC operand referencing TSUB's own stream position (in place
                               * of EXTN's ordinary plain-SYT base operand). */
    uint16_t copy_ref_base_syt;
    int32_t copy_ref_copy_index;
    int32_t integer;        /* is_ref=false, !is_scalar, !is_string, !is_bits, !is_container, !is_struct_ref */
    halmat_scalar_t scalar; /* is_ref=false, is_scalar */
    uint16_t ref_syt;       /* is_ref=true */
    size_t ref_offset;      /* is_ref=true */
    bool is_subbit_ref;     /* is_ref=false: true if this slot holds a SUBBIT
                               * pseudo-conversion assignment-context reference
                               * (class-1/ITOQ.md's shared XBTOQ family, TAG=1
                               * form: `SUBBIT(x) = ...;`), consumed by a
                               * following BASN (the only assign opcode SUBBIT
                               * ever chains into, since its whole point is
                               * routing the write through a bit-string
                               * intermediary) via a QUAL_VAC operand
                               * referencing the xTOQ instruction's own stream
                               * position. */
    uint16_t subbit_target_syt; /* is_subbit_ref: the plain SYT variable whose
                               * raw storage gets overwritten with the
                               * assigned bit pattern -- interp.c's
                               * write_destination dispatches on this target's
                               * *own* declared type (only SYT_TYPE_INTEGER/
                               * SYT_TYPE_BIT have a confirmed, lossless raw-
                               * bit-pattern mapping in this interpreter; any
                               * other type fails loudly rather than guess an
                               * unmodeled byte layout). */
    bool is_bitpart_ref;    /* is_ref=false: true if this slot holds a native BIT-string
                               * at-partition/single-index reference (`B$(width AT
                               * position)` or `B$(n)`, OP_DSUB's TAG=1 "component"
                               * cases), applied directly to a plain (non-ARRAY) BIT/
                               * INTEGER/SCALAR SYT variable's own raw storage --
                               * deferred (not resolved to a value at DSUB time) so the
                               * exact same slot works as *either* a read (resolve_operand
                               * dereferences it) *or* a write-through (write_destination
                               * dereferences it), the same "produced by DSUB, consumed by
                               * whichever operand position uses it" pattern is_ref already
                               * establishes for ARRAY/MATRIX element references just above
                               * -- user-reported, 250-BITS.hal's `B$(1) = ON;` (`B` a plain
                               * `BIT(8)`): this DSUB shape was originally implemented
                               * read-only (its own comment explicitly noted "no fixture...
                               * needs this as an assignment target"), eagerly resolving to
                               * an `is_bits` plain value -- correct for every read use seen
                               * until this file, but wrong here since BASN's own receiver
                               * operand needs a *destination*, not a value, and hit
                               * write_destination's generic "assignment destination is not
                               * a subscript reference" fallback (is_ref false, is_subbit_ref
                               * false, nothing else recognized). */
    uint16_t bitpart_target_syt; /* is_bitpart_ref: the plain SYT variable whose raw bit
                               * pattern is read from/written into (or, when bitpart_
                               * array_offset >= 0, the ARRAY(n) BIT(w) variable one of
                               * whose own elements is read/written instead). */
    int bitpart_position;   /* is_bitpart_ref: the 1-indexed HAL/S bit position (MSB-first
                               * within the target's own declared width -- same convention
                               * as OP_DSUB's read-side extraction, format_bit_field, etc). */
    int bitpart_width;      /* is_bitpart_ref: the field width in bits (1 for the
                               * single-index `B$(n)` form, the explicit "width" operand
                               * for the at-partition `B$(width AT position)` form). */
    int32_t bitpart_array_offset; /* is_bitpart_ref: -1 (default) for a plain scalar
                               * bitpart_target_syt, as originally established (250-
                               * BITS.hal's `B$(1) = ON;`); >= 0 selects element
                               * bitpart_target_syt's own bit_elements[this] instead --
                               * `INFO(WORD+1):BITNUM+1` (INFO an ARRAY(n) BIT(16)),
                               * user-reported (bit_partition_extraction_mismatch;
                               * 253-TEST0.hal): a *combined* array-index-plus-bit-
                               * sub-index DSUB shape, distinct from both the plain-
                               * scalar at-partition/single-index forms above and the
                               * numeric-ARRAY to-partition range form (task #64's own
                               * DSUB branch) -- see OP_DSUB's own comment. */
} halmat_vac_slot_t;

/* Structure-field "shadow slot" storage: HAL/S structure fields (class-0/
 * EXTN.md's qualified references, e.g. ZQ1.QI) are addressed by a
 * (base_syt, field_syt) pair, NOT by field_syt alone -- confirmed
 * empirically this session that field_syt is the same symbol-table index
 * across every instance of a given STRUCTURE TEMPLATE (ZQ1.QI and ZQ2.QI
 * both resolve field_syt=3 for two independently-DECLAREd ZQ1/ZQ2), so
 * using field_syt as a direct storage key would incorrectly alias every
 * instance's same-named field together. Real hardware instead computes a
 * byte offset into the structure's own memory block (confirmed by TASN.md's
 * "ZQ1+2"-style addressing in its object-code trace); this interpreter
 * doesn't model byte-precise structure layout at all (would need parsing
 * TEMPLATE field lists/sizes from the symbol table, not done), so instead
 * gives each distinct (base_syt, field_syt) pair its own independent
 * halmat_syt_entry_t-shaped storage slot, found-or-created on first touch.
 * A small growable linear-scan table -- structures aren't expected to be
 * touched in tight hot loops for the kind of programs this interpreter
 * targets.
 *
 * copy_index distinguishes copies of a multiple-copy structure
 * (`TEMPLATE-STRUCTURE(n)`, class-0/TSUB.md) -- 0 for an ordinary
 * single-instance structure. HAL/S folds "structureness" (multi-copy
 * looping) into the same ADLP/DLPE arrayness bracket already used for
 * arrays (confirmed: `ZQ4 = ZQ1;` between two `(3)`-copy structures
 * compiles to plain TASN wrapped in ADLP(3)/DLPE, no distinct opcode --
 * see STATUS.md), so the copy index for any given field touch during
 * such a replay is just interp.c's existing state->arrayed_index. */
typedef struct {
    uint16_t base_syt, field_syt;
    int32_t copy_index;
    uint16_t mid_path[HALMAT_STRUCT_PATH_MAX]; /* every hop strictly between base_syt and
                               * field_syt for a *named*-sub-template nested reference
                               * (halmat_vac_slot_t's own struct_mid_path comment) -- part
                               * of this slot's own key, alongside base_syt/field_syt/
                               * copy_index, since field_syt alone is shared across every
                               * same-named field of a given TEMPLATE (e.g. `V`, declared
                               * once in SUPER_VECTOR-STRUCTURE but reachable via three
                               * different sibling instances, POSITION/VELOCITY/ACCEL, of
                               * a shared STATEVEC-STRUCTURE) -- without mid_path in the
                               * key, `STATE2.STATE.POSITION.V`/`.VELOCITY.V`/`.ACCEL.V`
                               * would all alias the exact same storage cell. Zero-length
                               * (mid_path_len=0) for the ordinary single-level EXTN(2)
                               * case, identical to this struct's pre-existing behavior. */
    uint8_t mid_path_len;
    halmat_syt_entry_t value;
} halmat_struct_field_t;

/* One ON ERROR-registered error-environment modification (class-0/
 * ERON.md, USA003087 Sec. 25.2). `group`/`member` are -1 for the
 * unsubscripted "all groups"/"all members in group" forms (ERON's own
 * 255/63 wire sentinels are translated to -1 at registration time so a
 * real group/member number can never collide with the wildcard). Only
 * flat, un-scoped registration is implemented -- USA003087 Sec. 25.1's
 * per-block dynamic-scoping rule (a modification make in a PROCEDURE/
 * FUNCTION is unwound on return from it) is not; see interp.c's OP_ERON
 * comment for the resulting limitation. */
typedef enum { HALMAT_ERRACT_SYSTEM, HALMAT_ERRACT_IGNORE, HALMAT_ERRACT_GOTO } halmat_error_action_t;

/* ERON's "AND SET/RESET/SIGNAL var" clause (class-0/ERON.md): confirmed
 * wire encoding of the event operand's own TAG2 sub-flag -- 0=SIGNAL,
 * 1=SET, 2=RESET. Only ever paired with HALMAT_ERRACT_SYSTEM/IGNORE (the
 * GOTO/user-statement form has no such clause in the grammar). */
typedef enum { HALMAT_EVENT_SIGNAL = 0, HALMAT_EVENT_SET = 1, HALMAT_EVENT_RESET = 2 } halmat_error_event_action_t;

typedef struct {
    int group;  /* -1 = all groups */
    int member; /* -1 = all members in group */
    halmat_error_action_t action;
    size_t goto_pc; /* valid only if action == HALMAT_ERRACT_GOTO */
    bool has_event_action;  /* AND SET/RESET/SIGNAL clause was present */
    uint16_t event_syt;     /* valid iff has_event_action */
    halmat_error_event_action_t event_action; /* valid iff has_event_action */
} halmat_error_handler_t;

#define HALMAT_MAX_TASKS 32

typedef enum {
    TASK_READY,
    TASK_WAITING,    /* wake_deadline: a fixed future virtual_time tick (WAIT interval, or SCHD's AT/IN/EVERY/AFTER) */
    TASK_WAITING_ON, /* on_event_syt: re-checked every tick (SCHD's ON <bit exp> initiation) -- no fixed
                       * deadline exists to fast-forward to, unlike TASK_WAITING, since nothing says in
                       * advance *when* another task's SIGNAL will flip the bit; see interp.c's
                       * sched_wake_on_events(). */
    TASK_WAITING_FOR_DEPENDENTS, /* reached CLOSE/RETURN with at least one still-active DEPENDENT
                                  * child (parent_task below) -- USA003087 Sec. 13.3: "If execution
                                  * ends on a CLOSE or RETURN statement, the process goes into the
                                  * inactive state directly only if it has no dependents. Otherwise,
                                  * it goes into a waiting state until the dependents have in their
                                  * turn terminated." Re-checked every tick, no fixed deadline (like
                                  * TASK_WAITING_ON), by interp.c's sched_wake_dependents(): once no
                                  * dependent remains active, this task actually terminates (or, if
                                  * it's the primal, halts the whole interpreter -- Sec. 13.1's
                                  * overriding "all other processes are always dependent on the
                                  * primal process for their existence" rule, which is what finally
                                  * ends everything once the primal itself is done). Confirmed this
                                  * session via a user-reported bug (COUNTUP2.hal/NESTED_TASK_
                                  * SCHEDULE_TEST.hal): the primal previously halted unconditionally
                                  * at its own CLOSE, ignoring any still-active DEPENDENT task. */
    TASK_WAITING_FOR_DEPENDENTS_RESUME, /* `WAIT FOR DEPENDENT;` (class-0/WAIT.md, tag=0, no
                                          * operands), USA003087 Sec. 13.5 -- same "block until every
                                          * DEPENDENT child has terminated" condition as
                                          * TASK_WAITING_FOR_DEPENDENTS above, re-checked the same way
                                          * (interp.c's sched_wake_dependents(), has_active_dependents()),
                                          * but this task's own body isn't finished -- it must resume
                                          * at its own next instruction (TASK_READY) once its
                                          * dependents clear, not terminate/halt. A distinct enum value
                                          * rather than a flag alongside TASK_WAITING_FOR_DEPENDENTS:
                                          * sched_wake_dependents() branches on task_state already, and
                                          * an explicit second value keeps that branch a plain
                                          * exhaustive switch rather than a state+flag combination that
                                          * would need its own separate invariant-checking. */
    TASK_TERMINATED,
} halmat_task_state_t;

/* SCHD's tag-bitmask sub-fields (class-0/SCHD.md's confirmed table), decoded once at SCHEDULE
 * time and stored per-task rather than re-decoded on every rearm. */
typedef enum {
    SCHD_REPEAT_NONE = 0,
    SCHD_REPEAT_BARE = 1,  /* ", REPEAT" alone -- rearm immediately (tag 0x10) */
    SCHD_REPEAT_EVERY = 2, /* ", REPEAT EVERY <exp>" -- fixed period, chained off the previous target (tag 0x20) */
    SCHD_REPEAT_AFTER = 3, /* ", REPEAT AFTER <exp>" -- delay measured from this cycle's completion (tag 0x30) */
    SCHD_REPEAT_ON = 4,    /* Interpreter-internal only -- never produced by a real HALMAT tag (repeat_bits is
                             * a 2-bit tag field, values 0-3 only). Synthesized solely for a task
                             * self-rescheduling itself with `SCHEDULE <self> ON <event>;` and no explicit
                             * REPEAT clause (interp.c's OP_SCHD self-reschedule branch): rearm by waiting on
                             * the event again, the same TASK_WAITING_ON minor state a brand-new ON-initiated
                             * task uses (has_on_event/on_event_syt below), rather than a fixed-deadline wait. */
} halmat_schd_repeat_t;

typedef enum {
    SCHD_STOP_NONE = 0,
    SCHD_STOP_UNTIL_TIME = 1, /* WHILE/UNTIL <ARITH EXP> -- both keywords compile identically (tag 0x40):
                                * confirmed by HALSFC itself rejecting "WHILE <time>" ("WHILE EXPRESSION MAY
                                * NOT BE A TIMING EXPRESSION"), so UNTIL is the only legal keyword here --
                                * "while it's before T" and "until T" describe the same deadline anyway. */
    SCHD_STOP_WHILE_BIT = 2,  /* REPEAT WHILE <bit exp> -- stop once the event goes false (tag 0x80, FIXL(MP)=0) */
    SCHD_STOP_UNTIL_BIT = 3,  /* REPEAT UNTIL <bit exp> -- stop once the event goes true (tag 0xC0, FIXL(MP)=1).
                                * WHILE vs UNTIL for a bit exp DO get distinct tags -- confirmed by compiling
                                * both this session (SCHD.md previously only had the WHILE case, and flagged
                                * FIXL(MP) as unconfirmed for anything but 0); the tag's own bit width (an
                                * 8-bit trailing field, 2 bits already spent on bits 6-7 here) caps FIXL(MP)
                                * at {0,1}, so a subscripted/latched-event third value structurally cannot
                                * exist within this encoding -- the "unconfirmed higher FIXL(MP)" case from
                                * SCHD.md's Unresolved Questions is now resolved as moot, not just untested. */
} halmat_schd_stop_t;

typedef struct {
    bool in_use;
    bool is_primal;
    uint16_t symbol;   /* SYT slot of the task's own name (arbitrary for primal) */
    int parent_task;   /* tasks[] index of whichever process executed the SCHD that created this
                         * task (-1 for the primal, which has none) -- used by has_active_dependents()
                         * (interp.c) to find a given process's own DEPENDENT children when it
                         * reaches CLOSE/RETURN (USA003087 Sec. 13.3). Set once at creation time in
                         * OP_SCHD; unaffected by a later self-reschedule (interp.c's OP_SCHD
                         * self-targeting branch), which reuses this same task-table slot rather
                         * than creating a new one, so the parent relationship doesn't change. */
    int priority;
    halmat_task_state_t task_state;
    size_t saved_pc;
    int64_t wake_deadline; /* virtual_time tick at which a TASK_WAITING task becomes TASK_READY --
                             * set by WAIT <n> (OP_WAIT), SCHD's AT/IN delayed-initiation targets, and
                             * (as the *result* of each cyclic rearm) SCHD_REPEAT_EVERY/AFTER's own
                             * rearm code in OP_CLOS. This is the only field sched_wake_waiting() reads,
                             * so whichever of those wrote it last must leave it holding the actual next
                             * wake tick. Previously also doubled as SCHD_REPEAT_EVERY's own chained
                             * phase reference, which collided with an internal WAIT inside the same
                             * task's body (both write this field) and made EVERY's period silently
                             * drift like AFTER's; fixed by giving EVERY its own dedicated field,
                             * every_phase_ref below -- see that field's comment and
                             * test_sched_every_wait.hal. */
    int64_t every_phase_ref; /* valid iff repeat_kind==SCHD_REPEAT_EVERY: the task's own chained phase
                               * reference for REPEAT EVERY, kept separate from wake_deadline so that an
                               * ordinary WAIT executed *inside* the task's own cyclic body (OP_WAIT,
                               * which only ever touches wake_deadline) can't clobber it. Initialized at
                               * OP_SCHD time to the tick SCHD itself executed (or the AT/IN target, if
                               * delayed) -- mirroring wake_deadline's own initial value at that same
                               * moment, since that's the natural first phase reference for a task that
                               * hasn't cycled yet -- then incremented by repeat_interval on each
                               * OP_CLOS rearm so the period stays fixed instead of drifting with
                               * execution jitter; wake_deadline is then assigned from this field's
                               * post-increment value so sched_wake_waiting() still sees the right tick.
                               * Not used by REPEAT AFTER, whose rearm recomputes wake_deadline directly
                               * from the *current* virtual_time rather than chaining off a stored
                               * reference (confirmed harmless by test_sched_after.hal, whose WORKER
                               * body does WAIT internally without perturbing AFTER's own delay). */
    bool dependent;    /* SCHEDULE ... DEPENDENT was specified; parsed but not yet behaviorally enforced beyond primal-exit ending the whole program */

    bool has_on_event;      /* SCHD's ON <bit exp> initiation form was used */
    halmat_operand_t on_event_op; /* valid iff has_on_event: either a plain (unsubscripted) EVENT SYT
                              * reference (class-0/SCHD.md's "QUAL=1=SYT, plain EVENT ref, no VAC needed")
                              * or a QUAL_VAC reference to a compound BAND/BOR/BNOT event-expression chain
                              * (`ON (ORBIT & (ORBIT2 & ORBIT3))`, USA003087 Sec. 24.6 -- 239-STARTUP.hal)
                              * -- re-evaluated live via interp.c's reevaluate_live_bit_operand() every
                              * time this is consulted (sched_wake_on_events()), never read directly. */

    halmat_schd_repeat_t repeat_kind;
    int32_t repeat_interval; /* ticks; valid iff repeat_kind is EVERY or AFTER. Resolved once, at the
                               * original SCHEDULE statement's execution -- re-evaluating it per cycle
                               * would mean re-running whatever HALMAT produced its value, which nothing
                               * else in this interpreter's execution model does for an instruction that
                               * already ran (see interp.c's OP_SCHD comment). */

    halmat_schd_stop_t stop_kind;
    int64_t stop_deadline;   /* valid iff stop_kind==SCHD_STOP_UNTIL_TIME: virtual_time tick at which the
                               * cycle stops. Resolved once at SCHEDULE time (same reasoning as
                               * repeat_interval above -- the compiled operand is a VAC snapshot, not a
                               * live reference). */
    halmat_operand_t stop_event_op; /* valid iff stop_kind==SCHD_STOP_WHILE_BIT/UNTIL_BIT: re-evaluated
                               * live (either a plain SYT operand or a QUAL_VAC compound BAND/BOR/BNOT
                               * chain, unlike stop_deadline, which is a one-time-resolved snapshot) each
                               * time a cycle completes -- see interp.c's OP_CLOS and
                               * reevaluate_live_bit_operand(). */
} halmat_task_t;

/* One WRITE/READ/READALL/call argument's captured state -- named (rather
 * than an anonymous nested struct) so halmat_io_pending_frame below can
 * hold a growable, heap-allocated array of these (`items`/
 * `items_capacity`) instead of a fixed-size inline one. User-reported
 * (134-DOTS.hal's `WRITE(6) 'DOTS:', DOTS(V1, V2);`, V1/V2 each
 * `ARRAY(10) VECTOR(3)` -- a same-unit FUNCTION call whose own two ARRAY
 * arguments each get ADLP/DLPE-replayed per element, per XXAR's already-
 * established "a plain (or BIT/CHARACTER) ARRAY argument IS wrapped in a
 * per-element replay" rule): needs 10 items for V1 plus 10 for V2 -- 20
 * total, comfortably more than the fixed HALMAT_MAX_OPERANDS(=16)-sized
 * inline array items[] previously had room for, which failed loudly with
 * "I/O statement has too many items" partway through V2's own replay.
 * HALMAT_MAX_OPERANDS itself is a correct, primary-sourced bound on a
 * single HALMAT *instruction's* own operand count (a small, fixed number
 * the real wire format can carry) -- reusing it to size this *list*,
 * which needs one entry per WRITE/CALL data item and can genuinely scale
 * with an array argument's own declared size, was always an
 * architectural mismatch, not a real HAL/S limit. Grown via realloc-
 * doubling (interp.c's io_pending_reserve_item()) up to item_count's own
 * uint8_t range (255) -- not widened further, since that would also
 * require widening every `for (uint8_t i = 0; i < ...item_count; i++)`
 * loop across interp.c to avoid a silent wraparound/infinite loop for a
 * hypothetical >255-item statement; no corpus program has been found
 * needing more than 134-DOTS.hal's own 20, so left as a smaller,
 * separately-fixable gap rather than guessed at now. */
typedef struct {
    /* WRITE only (kind == 2): one of the five USA003087 Sec. 12.4 device-
     * mechanism-positioning pseudo-functions (TAB/COLUMN/SKIP/LINE/PAGE) --
     * not a data value at all, so every other field below is meaningless
     * when this is set. `ioctl_kind` mirrors OP_XXAR's own already-
     * confirmed TAG2 encoding (class-0/XXAR.md): 1=TAB, 2=COLUMN, 3=SKIP,
     * 4=LINE, 5=PAGE. `ioctl_n` is the resolved integer argument (alpha/
     * beta/gamma in the spec's own notation). These can appear anywhere in
     * a WRITE statement's item list, interleaved with ordinary data items
     * (`WRITE(6) C1, SKIP(1), C2;`) -- flush_write (interp.c) applies each
     * in original sequence rather than pulling them out to a separate
     * pre-pass the way READ/READALL's simpler has_skip/has_column fields
     * (below) do; user-reported (WRITE-context SKIP/COLUMN silently
     * printing their own numeric argument as an ordinary data field
     * instead of repositioning anything -- OP_XXAR's TAG2 check was only
     * ever wired up for READ/READALL, never WRITE). */
    bool is_ioctl;
    int ioctl_kind;
    int32_t ioctl_n;
    bool is_string;
    bool is_scalar;
    bool is_bits;   /* WRITE only (kind == 2): a raw BIT-typed argument -- see
                      * OP_XXAR's capture logic (interp.c) and bit_width just below. */
    char *string;   /* borrowed from the literal table; not owned */
    int32_t integer;
    halmat_scalar_t scalar;
    uint32_t bits;   /* is_bits only */
    int bit_width;   /* is_bits only: the declared BIT(n) width to format `bits` at --
                       * looked up from the symbol table (state->symtab) for a plain
                       * QUAL_SYT variable reference, same technique BCAT (class-1/
                       * BCAT.md) already established for the identical "resolved_
                       * value_t's RV_BITS carries no width of its own" problem; falls
                       * back to 32 (the documented maximum legal BIT string length,
                       * USA003090 Sec. 8.2 rule 6) for anything else -- an expression
                       * result, a literal, or no symbol table available -- per
                       * ["Programming in HAL/S"] p. 255: "[t]he value returned by the
                       * BIT function is always of the maximum legal length for bit
                       * strings, as defined for the compiler version in use," the
                       * closest primary/secondary-source statement about what width a
                       * BIT value with no better-known width should be treated as
                       * (direct user citation, confirmed against USA003090's own 1-32
                       * range for this specific compiler). */
    /* WRITE only (kind == 2): a whole VECTOR/MATRIX/ARRAY argument
     * (`WRITE(6) V;`, or a MATRIX row/column slice like
     * `WRITE(6) M$(1,*);`) -- confirmed this session against real
     * compiled HALMAT that such an argument is NOT wrapped in an
     * ADLP/DLPE per-element replay (class-0/XXAR.md's former
     * "Unresolved Questions" entry, now resolved), so it can't be
     * captured as a single scalar/integer/string value the way
     * every other item here is. `container` borrows either the
     * SYT's own `elements` storage or a DSUB asterisk-subscript's
     * VAC container result (interp.c's OP_DSUB) -- not owned,
     * valid only until flush_write runs (no mutation of it can
     * happen between this XXAR and the statement's own WRIT).
     * `container_rows/cols` follow halmat_syt_entry_t's own
     * convention (MATRIX: both set, row-major; VECTOR/ARRAY:
     * rows=0) -- flush_write uses rows>0 to distinguish "lay out
     * row by row, forcing a new aligned line per row" (MATRIX,
     * USA003087 Sec. 12.2) from the flat sequential layout shared
     * by VECTOR and ARRAY. `container_is_integer` selects the
     * 11-column INTEGER field format over the default 14-column
     * SCALAR one, from the capturing XXAR's own TAG1 (class-0/
     * XXAR.md: "literally the argument's HALMAT class number"),
     * which is set the same way -- 6=INTEGER -- whether the
     * argument is a plain whole-SYT reference or a VAC-carried
     * container result (e.g. `MISMATCH$(J,*)`, a DSUB row-select
     * out of a confirmed-2-dimensional INTEGER ARRAY -- user-
     * reported, 113-EXAMPLE_7.hal; DSUB's own operator-word TAG
     * already carries this class number for exactly this reason,
     * see class-0/DSUB.md). A true MATRIX/VECTOR slice is always
     * SCALAR (HAL/S has no INTEGER MATRIX/VECTOR) and naturally
     * gets TAG1=5 there, so this check needs no separate case for
     * it. */
    bool is_container;
    const halmat_scalar_t *container;
    size_t container_count;
    int container_rows, container_cols;
    bool container_is_integer;
    bool container_is_vecmat; /* is_container: true for a genuine VECTOR/MATRIX argument (the
                       * capturing XXAR's own TAG1 == 3 or 4), false for a plain numeric
                       * ARRAY (TAG1 == 5/6, sharing this same is_container/rows==0 flat-
                       * layout path for VECTOR -- container_rows>0 alone already
                       * distinguishes MATRIX from ARRAY, but a flat VECTOR and a flat
                       * ARRAY are otherwise indistinguishable at this struct's own level).
                       * Needed because real hardware's WRITE runtime routes VECTOR/MATRIX
                       * output through a dedicated interface (RUNASM/MMWSNP.asm, "SINGLE
                       * PRECISION VECTOR/MATRIX OUTPUT INTERFACE") that unconditionally
                       * forces a fresh line before writing -- a plain numeric ARRAY has no
                       * such forced-newline behavior (mmwsnp_vector_forces_newline;
                       * flush_write's own use, interp.c). */
    /* WRITE only (kind == 2): a whole BIT or CHARACTER ARRAY
     * argument (`WRITE(6) DATA_VALID;`, `DATA_VALID` an
     * `ARRAY(4) BOOLEAN`) -- the same unreplayed QUAL=SYT/TAG1=
     * class shape as `is_container` just above (TAG1=1=BIT/
     * 2=CHARACTER instead of 3=MATRIX/4=VECTOR/6=INTEGER), but a
     * genuinely different storage kind (`bit_elements`/
     * `char_elements`, not `elements`/halmat_scalar_t) so it
     * can't share that field. At most one of is_container/
     * is_bit_array/is_char_array is ever true for a given item.
     * `bit_array`/`char_array` borrow the SYT's own storage, same
     * non-owned/valid-until-flush_write convention as `container`.
     * `container_count` (shared) gives the element count either
     * way. `bit_array_width` is the declared per-element BIT(n)
     * width (symtab lookup, same technique as the existing
     * single-BIT-value `bit_width` field just below) -- needed
     * per element the same way a lone BIT value needs it.
     * User-reported (120-EXAMPLE_A.hal's `WRITE(6) AVERAGE,
     * DATA_VALID;`). */
    bool is_bit_array;
    const uint32_t *bit_array;
    int bit_array_width;
    bool is_char_array;
    char *const *char_array;
    /* WRITE/CALL only (kind == 2 or is_call): a whole (bare/
     * unqualified) STRUCTURE argument (TAG1=10/MAJ_STRUC, the same
     * QUAL_XPT/EXTN shape as dest_is_structure below, just on the
     * WRITE/CALL side instead of READ/READALL) -- reuses
     * struct_base_syt/struct_template_syt/struct_copy_index below
     * (never set alongside dest_is_structure on the same item;
     * READ/READALL and WRITE/CALL are mutually exclusive per this
     * struct's own established convention, see dest_operand's own
     * comment). flush_write/bind_call_argument walk the template's
     * own struct_first_field/struct_next_field chain to emit/copy
     * each terminal in turn, mirroring OP_READ's own
     * dest_is_structure handling. User-reported, 172-OUTER.hal's
     * `WRITE(6) ARG;` and `UTIL(ARG)` (ARG a `UTIL_PARM-STRUCTURE`). */
    bool is_structure;
    /* READ/READALL only (kind != 2): the destination operand,
     * captured raw by XXAR rather than resolved to a value, plus
     * the HALMAT class number (XXAR's TAG1, class-0/XXAR.md) that
     * tells READ's handler which format to parse from the device.
     * Only INTEGER(6)/SCALAR(5)/CHARACTER(2) are implemented as
     * single-field destinations -- see interp.c's OP_READ case. */
    halmat_operand_t dest_operand;
    uint8_t dest_class;
    /* True when dest_operand is a whole VECTOR/MATRIX SYT
     * reference (TAG1=4/3, class-0/XXAR.md's confirmed "no ADLP/
     * DLPE replay" shape -- same unreplayed pattern as the WRITE/
     * CALL whole-container case above, `is_container`) rather
     * than a single scalar/integer/character destination. OP_READ
     * unrolls this into one field read per element (dest_operand.
     * data is the container's own SYT index) instead of the
     * ordinary single-value write_destination path. ARRAY has no
     * equivalent here -- confirmed (class-0/XXAR.md) it stays
     * ADLP/DLPE-replayed even when whole, so each element already
     * arrives as its own ordinary-shaped XXAR/dest_class item via
     * the ordinary ADLP replay this struct's other fields already
     * handle, cycling arrayed_index -- no separate case needed. */
    bool dest_is_container;
    /* True when dest_operand is a whole (bare/unqualified) STRUCTURE
     * reference (TAG1=10/MAJ_STRUC, a QUAL_XPT operand referencing an
     * EXTN result whose struct_field_syt is itself a template symbol --
     * EXTN.md's "bare/unqualified reference" case) -- USA003087 Sec.
     * 12.3's structure READ rule: one data field per terminal, in
     * declaration order (a VECTOR terminal like any other whole-VECTOR
     * destination, one field per component), same unrolled order WRITE/
     * INITIAL use. OP_READ walks the terminals via the template's own
     * symtab struct_first_field/struct_next_field chain (symtab.h) and
     * writes each one directly into its shadow field slot
     * (find_or_create_struct_field), not through the ordinary
     * write_destination path -- user-reported, 172-OUTER.hal's `READ(5)
     * ARG;` (ARG a `UTIL_PARM-STRUCTURE`, fields `V VECTOR, S1 SCALAR, C
     * INTEGER, S2 SCALAR, E BOOLEAN`). */
    bool dest_is_structure;
    uint16_t struct_base_syt;    /* valid iff dest_is_structure or is_structure: the structure instance itself */
    uint16_t struct_template_syt; /* valid iff dest_is_structure or is_structure: its own template symbol, for the
                                    * struct_first_field/struct_next_field walk */
    int32_t struct_copy_index;   /* valid iff dest_is_structure or is_structure: -1 means "use the ambient
                                    * current_copy_index()" (an explicit TSUB-selected copy
                                    * overrides this the same way EXTN's own struct_copy_index does) */
    uint16_t struct_mid_path[HALMAT_STRUCT_PATH_MAX]; /* valid iff dest_is_structure or is_structure:
                                    * copied straight from the capturing EXTN's own is_struct_ref VAC slot
                                    * (halmat_vac_slot_t's own struct_mid_path comment) for a *named*-sub-
                                    * template nested whole-structure argument (yahalmat2_extn_multifile_
                                    * template, 176-P.hal's `CALL INTEGRATE(STATE2.STATE.ACCEL) ASSIGN(
                                    * STATE2.STATE.VELOCITY);`) -- empty for the ordinary single-level case. */
    uint8_t struct_mid_path_len;
    /* Call-only (is_call == true, so never set alongside the
     * READ/READALL dest_* fields above -- they share dest_operand,
     * the two contexts are mutually exclusive): true when this
     * argument's XXAR had a nonzero TAG2, i.e. an ASSIGN-form call
     * argument (`CALL P(X) ASSIGN(Y);`, class-0/XXST.md's own
     * confirmed `CALL TWO(I1) ASSIGN(I1);` trace) -- the callee's
     * corresponding parameter's *final* value must be written back
     * into dest_operand (the caller's own variable) once the call
     * returns, not just transmitted in like an ordinary argument.
     * Still participates in the normal by-value positional binding
     * on the way in (OP_PCAL/OP_FCAL's existing binding loop
     * doesn't need to know or care that an item is also
     * ASSIGN-tagged) -- this only adds the write-*back* half.
     * Handled at OP_XXND, the exact point control lands back on
     * after the callee returns (RTRN/CLOS's jump always targets
     * PCAL/FCAL's own position + 1, i.e. this closing XXND) and
     * this frame's own items[]/call_target are still intact
     * (io_pending_stack correctly shields them from any of the
     * callee's *own* I/O/call activity in between). User-reported
     * (140-STATISTICS.hal/138-FILTER.hal/120-EXAMPLE_A.hal, all
     * three real corpus programs using PROCEDURE...ASSIGN(...)). */
    bool is_assign;
} halmat_io_item_t;

/* Per-device "device mechanism" position, USA003087 Sec. 12.2/12.4's own
 * term -- persists across WRITE statements to the same device (unlike
 * io_pending, which is reset per-statement), since the mechanism's
 * position at the end of one WRITE is exactly where the next one picks up
 * ("[o]therwise, the device mechanism moves down one line from its
 * current position" -- Sec. 12.2's execution-sequence rule). `line_buf`
 * buffers the CURRENT (not yet finalized) line's content: a WRITE
 * statement's own last line stays open/buffered, not flushed to the
 * output file, until something actually moves the mechanism down (the
 * *next* WRITE's own default or explicit vertical movement, or program-
 * end cleanup) -- this is what makes backward TAB(-n)/COLUMN(n) overstrike
 * possible at all (USA003087 Fig. 12-5's own worked example exercises
 * exactly this), since a plain streaming write to the output FILE* could
 * never move backward once a character is flushed. `col` is 1-based
 * (matching the spec's own "must not move left past column 1" language)
 * and names the column the *next* character will land at; it is
 * independent of line_buf_len (a backward TAB followed by a short
 * overwrite leaves col short of the buffer's true extent, exactly
 * matching a real line printer's overstrike). */
typedef struct {
    bool started;         /* has this device had a WRITE issued yet? (Sec.
                            * 12.2: the very first WRITE positions at
                            * column 1/line 1[/page 1], no line finalized) */
    int page;              /* current page number, 1-based (PAGED only) */
    int line;               /* current line within the page, 1-based */
    int col;                 /* column the next character will be written
                               * at, 1-based */
    char *line_buf;         /* growable buffer for the still-open current line */
    size_t line_buf_len;    /* high-water content length (bytes actually
                              * written or space-padded so far) */
    size_t line_buf_cap;
} halmat_device_mech_t;

struct halmat_state {
    const halmat_program_t *prog;
    const halmat_literal_table_t *literals;
    const halmat_symtab_t *symtab; /* optional (NULL if unavailable, e.g. --py units);
                                     * needed for MATRIX/VECTOR/ARRAY declared dimensions
                                     * (DSUB/MASN-family container allocation) since HALMAT
                                     * itself never carries them -- see HALMAT_CONTAINER_
                                     * CAPACITY's comment above. Not owned by the interpreter. */
    size_t pc; /* index into prog->instrs */

    halmat_syt_entry_t syt[HALMAT_SYT_MAX];
    halmat_vac_slot_t vac[HALMAT_VAC_MAX];

    int num_blanks; /* WRITE-item separator, Plan.md Phase 3 default 5 */
    int line_length; /* WRITE data-field wrap column, or -1 for "not
                       * explicitly set via --line-length" (main.c), in which
                       * case flush_write (interp.c) picks a per-device
                       * default from device_unpaged[] below: 132 for PAGED,
                       * 80 for UNPAGED. A field that wouldn't fit within the
                       * effective column count starts a fresh line instead;
                       * MATRIX rows additionally force a new line
                       * unconditionally at each row boundary regardless of
                       * this limit.
                       * *Correction (2026-07-25 session)*, resolving an
                       * ambiguity an earlier session's comment here had
                       * flagged but left unresolved: USA003090 Sec. 5.2's
                       * default-channel-mode rule makes channel 6 (write-
                       * only, no DEVICE directive, in every fixture checked)
                       * PAGED by default, whose own documented default LRECL
                       * (Sec. 6.1.4) is 133 -- but Sec. 6.1.4 also says a
                       * PAGED file with no RECFM supplied defaults to FBA,
                       * the trailing "A" meaning an ANSI/ASA carriage-control
                       * character is *automatically generated* as byte 1 of
                       * every record (UNPAGED defaults to plain FB instead,
                       * no such byte) -- so PAGED's 133-byte LRECL is 1
                       * non-printing control byte plus 132 *printable*
                       * columns, not 133 printable columns. 132 is also the
                       * IBM 1403 line printer's own documented print width
                       * (this HAL/S-FC runtime's own historical target
                       * hardware), independently corroborating the same
                       * number. 80 (UNPAGED, no control byte, all of LRECL
                       * 80 is printable) was already correct and unaffected
                       * by this fix. */

    /* Logical device number -> open file, see HALMAT_DEVICE_MAX above.
     * NULL = unmapped (READ/WRITE against it fails loudly). Not owned by
     * the interpreter -- main.c opens/closes any --ddi/--ddo files and
     * owns stdin/stdout, so interp_cleanup() must not fclose() these. */
    FILE *devices[HALMAT_DEVICE_MAX];

    /* Per-device PAGED (false, the default)/UNPAGED (true) mode --
     * USA003090 Sec. 5.2: real HAL/S-FC determines this per channel via a
     * `D DEVICE CHANNEL=n [UN]PAGED` *compile-time* source directive
     * (falling back to a channel-usage-based default: WRITE-only ->
     * PAGED, any READ/READALL use -> UNPAGED), never anything runtime or
     * JCL-DD-card-driven the way this comment previously assumed device
     * *mapping* itself was (see devices[] above, and --ddi/--ddo, main.c)
     * -- but this interpreter has no access to the original HAL/S source
     * at all (just compiled HALMAT), so there's no way to see a DEVICE
     * directive even if the program had one. Exposed instead as a
     * runtime override, --unpaged N (main.c, repeatable, one device
     * number per flag -- independent per device, not a single global
     * on/off switch: a real program can and does mix PAGED and UNPAGED
     * channels, e.g. an UNPAGED channel feeding data to a later READ
     * alongside a PAGED one for human-readable diagnostics). Only
     * observably affects CHARACTER (and BIT, once WRITE of a raw BIT
     * value is implemented -- not yet, see interp.c's flush_write)
     * output: UNPAGED encloses the value in apostrophes, doubling any
     * embedded ones (USA003087 Appendix F / USA003090 Sec. 6.1.3, both
     * confirmed against "Programming in HAL/S" Sec. 8.1's direct worked
     * example, `WRITE(6) 'THE ANSWER IS', V;` printing `THE ANSWER IS
     * 7.5836210E+05` PAGED vs. `'THE ANSWER IS' 7.5836210E+05` UNPAGED)
     * -- SCALAR/INTEGER field formatting is identical either way. */
    bool device_unpaged[HALMAT_DEVICE_MAX];

    /* WRITE-only device mechanism state (halmat_device_mech_t's own
     * comment) -- one entry per logical device number, independent of
     * devices[]/device_unpaged[] above (READ/READALL use their own,
     * simpler device_read_started/device_line_start tracking below,
     * unaffected by this). */
    halmat_device_mech_t device_mech[HALMAT_DEVICE_MAX];

    /* PAGE(beta)/LINE(gamma)'s own "L" (USA003087 Sec. 12.4: "[t]he value
     * of gamma must lie in the range 1 <= gamma <= L, where L is the
     * number of lines per page[, which] is implementation dependent" --
     * exposed as --page-length, main.c). Default 66, the IBM 1403 line
     * printer's own documented lines-per-page (user-supplied, this
     * runtime's own historical target hardware, matching the same
     * reasoning as line_length's 132-column PAGED default above). Only
     * meaningful for PAGED devices -- LINE(gamma) on an UNPAGED device has
     * no page concept at all (Sec. 12.4 rule 4 vs. rule 5), and PAGE()
     * itself is documented as usable "only in I/O via a paged device". */
    int page_length;

    /* The string emitted between pages (PAGE()/an automatic page-length
     * overflow), user-facing as --page-length's companion --ff option
     * (main.c) -- default a single ASCII form-feed (0x0C), matching a
     * real line printer's own page-eject convention, but may be any
     * string (a page-heading template, or '' to suppress the gap
     * entirely). A literal "%p" substring is replaced with the page
     * number being advanced *to* (1-based, auto-incrementing) at each
     * emission -- expand_page_break_string(), interp.c. Owned (dup_string'd
     * by interp_set_page_break_string()); freed by interp_cleanup(). */
    char *page_break_string;

    /* Whether page_break_string gets an implied trailing newline appended
     * at each emission -- true unless the *configured* string (before %p
     * substitution) is empty, is a bare single form-feed character, or
     * already ends in '\n' itself (avoiding a doubled blank line in the
     * common case of a user-supplied heading template that already ends
     * with its own newline). Computed once by interp_set_page_break_
     * string() rather than re-derived at every page break. */
    bool page_break_implies_newline;

    /* Per-device: has a READ/READALL already executed against this device?
     * USA003087 Sec. 12.3: "If the READ statement is the first to be
     * executed for the specified device, the device mechanism positions
     * itself at column 1 of line 1. Otherwise, the device mechanism moves
     * down one line from its current position and repositions itself at
     * column 1" -- i.e. every READ/READALL but a device's first discards
     * whatever the *previous* one left unconsumed on the current line
     * (extra un-listed values, or a `;`-terminated list's own leftover
     * semicolon -- see read_skip_separator's comment) before starting its
     * own field scan; interp.c's OP_READ does the discard. False (memset-
     * zeroed by interp_init) is the correct initial state for every
     * device: "not yet read from," so the very first READ skips the
     * discard, matching the "first...positions at line 1" case above. */
    bool device_read_started[HALMAT_DEVICE_MAX];

    /* `ftell()` offset of the start of the line the device is currently
     * positioned within -- used by READ's COLUMN(n) control specifier
     * ([USA003087] Sec. 12.3/12.4's TAB/COLUMN/SKIP/LINE/PAGE "pseudo-
     * functions") to reposition to an absolute column within the
     * *current* line rather than wherever the previous field's `fscanf`
     * happened to leave the cursor. Updated every time a newline is
     * actually consumed (OP_READ/OP_RDAL, right after discard_to_eol());
     * 0 is the correct initial value (matches device_read_started's own
     * "not yet read from" default, memset-zeroed by interp_init -- the
     * first read starts at the file's own beginning, offset 0). Only
     * COLUMN(n) is implemented (state.h's own scope note doesn't extend
     * to TAB/LINE/PAGE, which have no confirmed READ-context meaning and
     * no fixture/corpus program needing them); WRITE's own pseudo-
     * functions remain entirely unimplemented (no fixture needs them
     * either). User-reported (164-OUTER.hal's `READ(INFILE) SKIP(0),
     * COLUMN(9), PHI;` idiom -- peek a line's leading token via READALL,
     * then re-read the same line's remaining fixed-column data). */
    long device_line_start[HALMAT_DEVICE_MAX];

    /* --raf=I,R,N,F ("random-access file", per the historical HAL/S-FC
     * runtime's own option of the same name/shape -- see class-0/FILE.md)
     * device table. A *separate* device-number namespace from `devices`
     * above (confirmed: the real option's own docs note device N for
     * --raf can be safely reused for --ddi with no collision), since a
     * FILE statement's channel and a READ/WRITE device number are
     * distinct HAL/S concepts that just happen to share the same numeric
     * range by convention. record_size is fixed per device (host-side
     * configuration, not carried by the HALMAT stream itself); fp NULL
     * means unmapped. Not owned by the interpreter -- main.c opens/closes
     * these, matching `devices`' own ownership convention. */
    FILE *raf_devices[HALMAT_DEVICE_MAX];
    int raf_record_size[HALMAT_DEVICE_MAX];

    /* Pending WRITE/READ-statement argument list, accumulated between
     * XXST and XXND (see class-0/WRIT.md's Usage Context). */
    /* XXST/XXAR/XXND is a general bracketed-argument-list construct
     * (class-0/XXST.md), shared by I/O statements and function/procedure
     * calls alike -- discriminated by XXST's own operand qualifier
     * (IMD=I/O kind code, SYT=called symbol). One such bracket can nest
     * inside another (e.g. `WRITE(6) I, SQUARE(I);` -- WRITE's own
     * XXST...XXND brackets a nested XXST...XXND for the SQUARE(I) call,
     * source-documentation/Multiple-file-problem.md's reproduction case),
     * so this is a small stack, not a single frame -- see start_pc below
     * for how a genuinely nested XXST is told apart from an ADLP/DLPE
     * replay of the *same* XXST instruction. */
    struct halmat_io_pending_frame {
        bool active;
        bool is_call;
        int kind;             /* I/O case: XXST's IMD operand (0=READ, 1=READALL, 2=WRITE) */
        uint16_t call_target; /* call case: XXST's SYT operand (the called function/procedure) */
        size_t start_pc;      /* prog->instrs index of the XXST that opened this frame -- an
                                * ADLP/DLPE replay re-executes that *same* XXST instruction
                                * (state->pc == start_pc) and must keep accumulating into this
                                * frame, whereas a genuinely nested call's XXST is a different,
                                * not-yet-seen instruction and must push a new frame instead. */
        halmat_io_item_t *items; /* heap-allocated, growable -- see halmat_io_item_t's own comment above */
        size_t items_capacity;   /* allocated element count of items[]; independent of item_count below */
        uint8_t item_count;
        /* READ/READALL only (kind != 2, !is_call): SKIP(n)/COLUMN(n)
         * control specifiers (class-0/XXAR.md's confirmed TAG2=2=COLUMN/
         * 3=SKIP encoding -- an XXAR entry in its own right, not a real
         * destination item, so captured here instead of in items[]/
         * item_count). Frame-level (one SKIP/COLUMN per READ statement,
         * not per-item) since every corpus/primary-source example has
         * them appear once, "at the beginning of a READ" ([USA003087]
         * Sec. 12.3) -- mid-list placement isn't modeled. See OP_READ's
         * own comment (interp.c) for how these are applied. */
        bool has_skip;
        int32_t skip_n;
        bool has_column;
        int32_t column_n;
    } io_pending, io_pending_stack[8];
    uint8_t io_pending_sp; /* # of saved frames in io_pending_stack (the enclosing
                             * brackets of whatever nested XXST is active in io_pending
                             * right now); 0 = io_pending is the outermost/only frame. */

    /* Pending shaping-function argument list, accumulated between SFST
     * and SFND (class-0/SFST.md/SFAR.md/SFND.md) -- e.g. `V1 =
     * VECTOR(S1, S2, S1);`. Each SFAR's operand is stored raw (not
     * resolved) since the appropriate resolution differs by which
     * shaping-result opcode (VSHP/MSHP/SSHP/ISHP) ultimately consumes
     * the list -- VSHP resolves each as a plain SCALAR, but MSHP's own
     * arguments are themselves whole VECTORs (class-0/MSHP.md), which
     * isn't known until MSHP itself is reached. Only VSHP is
     * implemented; MSHP/SSHP/ISHP fail loudly. */
    struct {
        bool active;
        halmat_operand_t items[HALMAT_MAX_OPERANDS];
        uint8_t item_count;
        /* Eager per-item scalar capture, populated only when an SFAR
         * operand is QUAL_VAC *and* we're inside an arrayed-paragraph
         * replay (arrayed_index >= 0) -- i.e. LFNC.md's `SUM(INTEGER(
         * DATA$(*:1 TO 5)))` shape (bit_concat_sum_expression,
         * 257-TEST4.hal), where the SFAR-preceded ADLP/DLPE bracket
         * genuinely replays a per-element sub-expression N times (one
         * SFAR firing per array element) rather than the plain "capture
         * one whole-array SYT reference, ADLP/DLPE is a no-op" shape
         * (`SUM(SA1)`) this struct's items[] alone already handles.
         * Deferred (raw operand) resolution can't work for the replayed
         * case: each pass re-executes the *same* instruction, so its VAC
         * slot (state->vac[]) only ever holds the *last* pass's value by
         * the time LFNC finally reads it after DLPE -- resolving eagerly,
         * once per SFAR firing, is the only way to keep each pass's own
         * value. has_resolved[i] false means resolved[i] is unset (the
         * ordinary raw-operand path, resolved later by whichever shaping-
         * result opcode consumes items[i]). */
        halmat_scalar_t resolved[HALMAT_MAX_OPERANDS];
        bool has_resolved[HALMAT_MAX_OPERANDS];
    } shape_pending;

    /* Structure-field shadow-slot table, see halmat_struct_field_t above.
     * Growable (realloc'd in interp.c's find_or_create_struct_field). */
    halmat_struct_field_t *struct_fields;
    size_t struct_field_count;
    size_t struct_field_capacity;

    /* ON ERROR-registered error-environment modifications, see
     * halmat_error_handler_t above. Growable (realloc'd in interp.c's
     * register_error_handler); OP_ERON's OFF/tag==3 case removes an
     * entry by shifting the tail down rather than leaving a hole, so
     * error_handler_count is always exactly the live entry count. */
    halmat_error_handler_t *error_handlers;
    size_t error_handler_count;
    size_t error_handler_capacity;

    bool halted;
    int exit_code;

    /* Arrayed-expression "paragraph" replay (class-0/ADLP.md role 1):
     * an ordinary arithmetic/assign paragraph over ARRAY-typed operands
     * compiles as a SINGLE-instance instruction sequence (e.g. one
     * SADD + one SASN, not one per element) with an ADLP/DLPE pair
     * *trailing* it (not wrapping it, confirmed empirically this
     * session -- PASS2/the optimizer does the per-element loop
     * unrolling at object-code-generation time using ADLP's element-
     * count operand as metadata; HALMAT itself never repeats the
     * paragraph). Reproducing the correct per-element result therefore
     * needs this interpreter to itself replay the paragraph N times,
     * once per array index, redirecting any ARRAY/VECTOR/MATRIX-typed
     * SYT operand within it to that element instead of treating the
     * whole-array symbol as an illegal scalar reference. Precomputed by
     * interp.c's precompute_arrayed_paragraphs(): keyed by the
     * paragraph's start position (right after the previous SMRK/program
     * start); NO_TARGET where a position doesn't start a recognized
     * arrayed paragraph. Only the single-ADLP case is handled (the
     * multi-ADLP multi-dimensional-array case existing in principle per
     * ADLP.md is not; no fixture exercises it). Requires a symbol table
     * (state->symtab) to know which SYT operands within the paragraph
     * are actually the arrayed ones -- without one, arrayed paragraphs
     * aren't detected at all and their SYT operands fail loudly instead
     * (see interp.c's resolve_operand/write_destination). */
    size_t *arrayed_paragraph_end; /* one past the trailing DLPE */
    int *arrayed_paragraph_count;  /* element count to replay */
    int *arrayed_paragraph_unit_size; /* 0 for an ADLP/IDLP-driven entry (plain per-index
                                        * arrayed_index, unchanged); for an SLRI-driven entry
                                        * (class-8/SLRI.md), the confirmed "elements per
                                        * repeated unit" value (SLRI's own 2nd operand) --
                                        * needed because a *nested* repetition-factor group
                                        * (`n#(v1, m#v2)`, USA003087 Sec. 16.2) replays a
                                        * multi-element body per outer iteration, not one
                                        * element, so the outer loop's contribution to a
                                        * QUAL_OFF write's absolute offset is
                                        * idx*unit_size, not just idx -- see interp.c's
                                        * run_arrayed_paragraph(). */
    /* Set (>=0) only while actively replaying a paragraph found above;
     * -1 otherwise. Consulted by resolve_operand/write_destination's
     * QUAL_SYT case to redirect an ARRAY/VECTOR/MATRIX-shaped operand to
     * elements[arrayed_index] instead of treating it as an ordinary
     * (illegal, for a whole-array symbol) scalar/integer reference. */
    int32_t arrayed_index;

    /* Precomputed DTST/CTST/ETST loop-branch targets (array positions
     * into prog->instrs), one entry per instruction; NO_TARGET (SIZE_MAX)
     * where not applicable. See interp.c's precompute_loop_targets(). */
    size_t *ctst_exit_target;
    size_t *etst_back_target;

    /* LBL destinations for BRA/FBRA (IF/THEN/ELSE), keyed by the INL
     * "bookkeeping label" number carried by LBL/BRA/FBRA's own operand --
     * a separate numbering/table from the loop labels above. Sized
     * HALMAT_LABEL_MAX; NO_TARGET where unset. See precompute_labels(). */
    size_t *label_pos;

    /* A *second*, parallel LBL-destination table, keyed by SYT index
     * instead of INL bookkeeping-label number -- a real `GO TO <label>;`
     * targeting a user-declared STATEMENT LABEL (`SKIPPED: ...;`)
     * compiles to a BRA/LBL pair whose shared operand is QUAL_SYT (the
     * label's own symbol-table index), not QUAL_INL, confirmed against a
     * real compiled `GO TO SKIPPED;` trace (user-reported,
     * test_eron_goto.hal, found as a regression while fixing 119-
     * EXAMPLE_9.hal's EXIT-to-labeled-DFOR bug below). SYT indices and
     * INL bookkeeping numbers are independent, both-starting-near-zero
     * numbering spaces that can coincidentally collide (small enough
     * programs make this a real, not just theoretical, risk -- caught by
     * a synthetic regression fixture whose labeled DO FOR's own STATEMENT
     * LABEL SYT index happened to equal an unrelated INL bookkeeping
     * number), so they can't safely share one flat table the way an
     * earlier version of this fix tried; OP_BRA/OP_FBRA now pick which of
     * the two tables to consult based on their own operand's qualifier,
     * exactly mirroring how the operand was produced. Sized
     * HALMAT_SYT_MAX (same convention as label_pos above, just keyed by
     * the other namespace's own natural size); NO_TARGET where unset.
     * See precompute_labels(). */
    size_t *label_pos_syt;

    /* List-form DO FOR (AFOR): per class-0/AFOR.md's "call-and-computed-
     * return" mechanism -- each AFOR sets the control variable and jumps
     * into the (single, shared) loop body; EFOR jumps back to whichever
     * address the triggering AFOR pushed (the next AFOR, or the loop
     * exit for the list's last AFOR). Modeled here as a small runtime
     * LIFO return-address stack (safe because nested DO FOR bodies fully
     * complete, including their own AFOR/EFOR cycles, before control
     * returns to an enclosing one). See interp.c's precompute_for_loops(). */
    size_t *afor_body_target;   /* per-AFOR: where to jump to run the body */
    size_t *afor_return_target; /* per-AFOR: what EFOR should return to afterward */
    uint16_t *afor_control_var; /* per-AFOR: SYT slot to assign this value into */
    bool *efor_is_list_form;    /* per-EFOR: true if it uses the AFOR return-stack */

    /* Range-form DO FOR (DFOR with 4-5 operands: construct id, control
     * var, initial, final, [increment]). DFOR assigns the control
     * variable directly, then -- corrected after a user-reported bug,
     * see OP_DFOR's own comment in interp.c -- performs the *same*
     * in-range check EFOR does before ever entering the body, skipping
     * straight to the loop exit if the initial value is already out of
     * range (`DO FOR J = 5 TO 4;` must run zero times, not one; a real
     * compiled AP-101S trace confirms DFOR's own initial branch lands on
     * EFOR's store+compare code, not directly on the body -- only the
     * increment step is actually skipped on the first pass, not the
     * bounds check). EFOR increments, compares against the final value
     * (direction per the increment's sign), and either branches back to
     * just past DFOR (re-running the body) or falls through (loop exit).
     * Per-EFOR position: its matching DFOR's position, so the increment/
     * final/[step] operands can be read straight from it. */
    size_t *efor_dfor_pos;
    size_t *dfor_efor_pos; /* per-DFOR: its matching EFOR's position (the reverse of efor_dfor_pos
                             * above), so DFOR's own initial out-of-range case can skip straight to
                             * the loop exit (dfor_efor_pos[dfor_pos] + 1) without a separate
                             * forward search. NO_TARGET for a list-form DFOR (no matching-EFOR
                             * bounds check applies there -- see OP_DFOR). */
    size_t for_return_stack[64];
    int for_return_sp;

    /* CFOR (class-0/CFOR.md): a range-form DO FOR's supplementary
     * WHILE/UNTIL clause, positioned once per cycle just before the
     * loop body. Consumes a VAC-carried boolean; when false, exits the
     * loop the same place EFOR's own range-exhausted exit would (one
     * past the enclosing EFOR) -- per-CFOR position, precomputed
     * alongside efor_dfor_pos since it needs the same DFOR/EFOR nesting
     * walk. NO_TARGET for a CFOR not inside a range-form DO FOR (list-
     * form DO FOR's own supplementary-condition case isn't handled
     * here, no fixture exercises it). */
    size_t *cfor_exit_target;

    /* DO CASE (DCAS/CLBL/ECAS): per class-0/ECAS.md, "every case body
     * ends with an unconditional branch" to ECAS's join point -- but
     * that branch is synthesized only in PASS2's machine-code output,
     * with no corresponding distinct HALMAT opcode. Modeled here by
     * having DCAS's computed jump land just *past* the selected CLBL
     * (skipping it), while CLBL itself, whenever reached by ordinary
     * sequential fall-through from a preceding case body (i.e. every
     * time except a DCAS landing), acts as the implicit branch to ECAS.
     * See interp.c's precompute_case_dispatch(). */
    size_t *dcas_case_target;  /* flat [dcas_pos * HALMAT_MAX_CASES + (sel-1)] -> jump target */
    size_t *dcas_case_count;   /* per-DCAS position: how many ordinary (non-trap) cases */
    size_t *clbl_ecas_target;  /* per-CLBL position: where to jump (ECAS join point + 1) */

    /* Function/procedure calls and TASK bodies (FDEF/TDEF/FCAL/RTRN/
     * SCHD/CLOS): a function's or task's body sits inline in the
     * enclosing PROGRAM's own instruction stream, so FDEF/TDEF, reached
     * by ordinary fall-through (i.e. NOT via a call/schedule jump, since
     * those jump past FDEF/TDEF straight to the body), skip over the
     * whole definition to its matching CLOS. Both share one symbol->
     * definition-position map since the "skip on fall-through, enter
     * only via an explicit trigger" shape is identical; FCAL and SCHD
     * differ only in what they do once they've found the entry point
     * (FCAL jumps the *same* flow of control in and back per class-0/
     * FCAL.md's positional argument-binding convention; SCHD spawns an
     * *additional*, concurrently-scheduled task -- see the task/
     * scheduler fields below). See interp.c's precompute_subprograms(). */
    size_t *symbol_def_pos;   /* indexed by SYT symbol: FDEF/TDEF's array position, or NO_TARGET */
    size_t *def_clos_target;  /* per-FDEF/TDEF position: matching CLOS's array position + 1 */
    size_t call_return_stack[64]; /* FCAL's own array position, per active call */
    int call_return_sp;

    /* Cross-unit calls into a separately-compiled EXTERNAL FUNCTION/
     * PROCEDURE (source-documentation/Multiple-file-problem.md; the
     * "one PROGRAM plus multiple FUNCTION/PROCEDURE units" scope --
     * multiple simultaneously-*executing* PROGRAMs sharing real-time
     * scheduling remains deferred, per direct user guidance). Indexed
     * by THIS unit's own local SYT for the external symbol -- exactly
     * the index for which symbol_def_pos[] is NO_TARGET (no *local*
     * FDEF/PDEF), which is what makes "is this call external" a cheap
     * check FCAL/PCAL already needed to make anyway. Installed once by
     * main.c's interp_set_external_units() (matched by name against the
     * caller's own EXTERNAL-flagged symtab entries, the same ESD-style
     * convention already used for EXTERNAL COMPOOL variables -- just
     * resolving a callable entry point instead of a data value); NULL
     * (the default) means no external units are linked, so every
     * external_calls[i] lookup site must tolerate that. Not owned by
     * this state -- main.c keeps each target_state alive (its own
     * interp_init/interp_cleanup pair) for as long as any caller might
     * still invoke it. */
    struct {
        halmat_state_t *target_state; /* NULL if this SYT index isn't an external call target */
        uint16_t target_entry_syt;    /* target_state's OWN SYT for its top-level FDEF/PDEF symbol */
    } *external_calls;

    /* Set only while this state is being run as a synthetic external-
     * call target (interp.c's run_external_call(), triggered by some
     * *other* state's FCAL/PCAL via external_calls[] above) -- RTRN,
     * reached with no active call_return_stack/inline_func frame,
     * captures its resolved value here (function form) and always signals
     * completion via halted=true, the same way CLOS's existing "primal
     * process closing" branch already does for an ordinary top-level
     * program -- rather than failing loudly the way a genuinely
     * unexpected bare RTRN still does when none of these three cases
     * apply. */
    bool in_external_call;
    bool external_call_has_result;
    halmat_vac_slot_t external_call_result;
    size_t inline_func_stack[16]; /* IDEF's own array position, per open inline FUNCTION
                                    * block (class-0/IDEF.md) -- RTRN inside one writes its
                                    * result to the IDEF's own VAC slot (mirroring FCAL's
                                    * role) and falls through rather than branching, since
                                    * the inline body already appears in-line in the stream */
    int inline_func_sp;

    /* Virtual-clock task scheduler (SCHD/WAIT/TERM/CANC/SGNL implemented,
     * including SCHD's delayed AT/IN/ON initiation and cyclic REPEAT
     * [EVERY/AFTER] [WHILE/UNTIL] forms -- see halmat_task_t's has_on_event/
     * repeat_kind/stop_kind fields and interp.c's OP_SCHD/OP_CLOS. PRIO is
     * BFNC's selector-19 built-in, not a standalone opcode. A STOPPING
     * clause (WHILE/UNTIL) with no REPEAT at all -- grammatically legal per
     * class-0/SCHD.md's <SCHEDULE CONTROL> ::= <STOPPING> alternative -- is
     * implemented as a documented no-op (see OP_SCHD's own comment):
     * SYNTHESI.xpl's grammar action for this case is itself a bare no-op,
     * and a non-repeating task's stop_kind is stored but never consulted
     * (OP_CLOS's rearm check only reads it when repeat_kind != NONE), so
     * the task simply runs once and terminates normally. virtual_time
     * itself still ticks 1:1 per HALMAT instruction executed (interp_step's
     * own per-instruction granularity, unchanged) -- but WAIT's duration and
     * SCHD's AT/IN/EVERY/AFTER/stopping-deadline expressions are no longer
     * treated as raw tick counts. They're genuine HAL/S numeric-seconds
     * values, converted to ticks via HALMAT_TICKS_PER_SECOND (above) before
     * being stored into wake_deadline/repeat_interval/stop_deadline --
     * see interp.c's schd_seconds_to_ticks() (shared by OP_SCHD's three
     * AT/IN/EVERY/AFTER/UNTIL-time sites and OP_WAIT), which converts the
     * *raw* double seconds value before rounding once at the end, so
     * fractional-second intervals (WAIT(0.5), etc.) aren't destroyed by an
     * intermediate round-to-nearest-second step. Real wall-clock pacing is
     * then layered on top in interp_run() (interp.c) alone -- NOT in
     * interp_step() itself, which stays a pure virtual-time primitive
     * shared by both interp_run()'s automatic loop and --debug's
     * breakpoint/step loop (debug_run(), debug.c): interp_run() bursts
     * through instructions, then periodically (HALMAT_REALTIME_BURST_MS)
     * compares elapsed virtual_time-as-real-seconds against the actual
     * wall clock and sleeps off any surplus, so a real run tracks real
     * time from a human user's perspective without busy-spinning the CPU.
     * time_scale (below) is a pure sleep-duration divisor applied only in
     * that pacing layer -- it never touches HALMAT_TICKS_PER_SECOND or the
     * seconds-to-ticks conversion, so every task's tick arithmetic and
     * interleaving order (and therefore every program's computed output)
     * is completely independent of --time-scale; only wall-clock runtime
     * changes. Priority: 0 < P < 255, higher number = higher priority,
     * primal defaults to 50 (USA003087 Sec. 13.1-13.3). */
    halmat_task_t tasks[HALMAT_MAX_TASKS];
    int task_count;
    int current_task; /* index into tasks[], set by the scheduler loop before each instruction */
    long *stmt_for_pc; /* precomputed per array-index position: the HAL/S statement number
                         * whose HALMAT code that position belongs to, or -1 if none (past
                         * the last SMRK). SMRK's own confirmed placement is AFTER a
                         * statement's HALMAT, not before -- so this is filled by scanning
                         * *backward* from each SMRK to the previous one, not forward from
                         * SMRK-execution time (an earlier, simpler-looking approach that
                         * turned out to always display the *previous* statement instead of
                         * the current one). For --debug's source-line display, see srcmap.c
                         * and interp_current_stmt_for_next(). */
    int32_t stri_target_syt; /* SYT index most recently named by STRI, or -1;
                               * consumed by QUAL_OFF writes inside the
                               * SLRI/ELRI/ETRI-bracketed repeated-initialize
                               * paragraph replay (class-8/STRI.md family) */
    int32_t stri_target_template_syt; /* whole-structure INITIAL() form only
                               * (class-8/TINT.md): the structure TEMPLATE's own
                               * SYT index, when STRI's operand is QUAL_XPT (a
                               * bare/unqualified EXTN reference) rather than
                               * QUAL_SYT -- -1 otherwise/inactive. stri_target_syt
                               * itself still holds the structure *instance*'s own
                               * SYT (the base for shadow-slot storage) in this
                               * case; TINT needs both: instance to know which
                               * structure to write into, template to compute
                               * each OFFSET-addressed terminal's own field symbol
                               * as template_syt+1+offset (the compiler emits a
                               * template's terminal symbols at consecutive SYT
                               * indices immediately following the template's own,
                               * confirmed empirically -- the same "callee+1+i"
                               * positional convention already used for FCAL's
                               * arguments, class-0/FCAL.md). */
    int64_t virtual_time;
    double time_scale; /* interp_run()'s wall-clock pacing divisor (--time-scale, main.c) --
                         * defaults to 1.0 (interp_init) for genuine real-time pacing; a larger
                         * value shrinks how long interp_run() actually sleeps for a given
                         * virtual-time interval (e.g. 100000 makes an hour of virtual/HAL-S
                         * time finish in about 36ms of wall-clock sleep), without changing any
                         * tick arithmetic at all -- see the scheduler comment above. */
    halmat_pacing_mode_t pacing_mode; /* interp_run()'s dispatch selector (--pacing, main.c) --
                         * defaults to HALMAT_PACING_BURST (interp_init), same default-then-
                         * override pattern as time_scale just above. Selects between
                         * interp_run_burst() and interp_run_signal() (interp.c); orthogonal to
                         * time_scale, which either implementation still honors identically. */
    int *symbol_active_task; /* indexed by SYT symbol: index into tasks[], or -1; for named TERM/CANCEL */

    /* BFNC selector 42/51 (RANDOM/RANDOMG, class-0/BFNC.md): a bit-exact
     * replication of the real AP-101S runtime library's own RUNASM/
     * RANDOM.asm generator (hal_random.h/.c -- yahalmat2_random_not_
     * deterministic, yagpc2-yahalmat2-issues.db id 36), superseding an
     * earlier Park-Miller Lehmer generator that was merely "some
     * deterministic PRNG," not a real hardware match (that placeholder
     * predated an independently-verified reference implementation of the
     * genuine algorithm becoming available). hal_random_init()
     * (interp_init) resets this to a fresh process's own initial state
     * (SEED=1435, chained_f1=0), matching RANDOM.asm's own object-code-
     * baked initial constant and a genuinely cold register file. */
    hal_random_state_t random_rng;

    /* BFNC selectors 38/39 (ERRGRP/ERRNUM, class-0/BFNC.md): "returns
     * group/number of last error detected, or zero" [USA003087] Appendix
     * B -- updated at the single choke point every already-implemented
     * App. C arithmetic-error fixup site already routes through
     * (arithmetic_error_should_apply_fixup, interp.c), so this covers
     * every group-4 error this interpreter detects, not just the ones
     * added alongside ERRGRP/ERRNUM themselves. Zero (the memset default)
     * means "no error detected yet," matching the documented default. */
    int32_t last_error_group;
    int32_t last_error_member;
};

#define HALMAT_MAX_CASES 64

#define HALMAT_LABEL_MAX 4096

#endif
