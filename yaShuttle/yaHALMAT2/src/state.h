#ifndef HALMAT_STATE_H
#define HALMAT_STATE_H

#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>

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
    halmat_scalar_t *elements; /* non-NULL => this symbol is an ARRAY/MATRIX/VECTOR of SCALAR; lazily allocated */
    size_t element_count;
    int rows, cols; /* MATRIX(r,c): both set (row-major, r*c elements). VECTOR(n): cols=n, rows=0.
                      * Plain ARRAY(n): both 0 (element_count is authoritative, single dimension).
                      * Set by ensure_container() the first time the symbol's elements are
                      * allocated -- 0/0 also means "not yet allocated" together with elements==NULL. */
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
    halmat_syt_entry_t value;
} halmat_struct_field_t;

#define HALMAT_MAX_TASKS 32

typedef enum {
    TASK_READY,
    TASK_WAITING,    /* wake_deadline: a fixed future virtual_time tick (WAIT interval, or SCHD's AT/IN/EVERY/AFTER) */
    TASK_WAITING_ON, /* on_event_syt: re-checked every tick (SCHD's ON <bit exp> initiation) -- no fixed
                       * deadline exists to fast-forward to, unlike TASK_WAITING, since nothing says in
                       * advance *when* another task's SIGNAL will flip the bit; see interp.c's
                       * sched_wake_on_events(). */
    TASK_TERMINATED,
} halmat_task_state_t;

/* SCHD's tag-bitmask sub-fields (class-0/SCHD.md's confirmed table), decoded once at SCHEDULE
 * time and stored per-task rather than re-decoded on every rearm. */
typedef enum {
    SCHD_REPEAT_NONE = 0,
    SCHD_REPEAT_BARE = 1,  /* ", REPEAT" alone -- rearm immediately (tag 0x10) */
    SCHD_REPEAT_EVERY = 2, /* ", REPEAT EVERY <exp>" -- fixed period, chained off the previous target (tag 0x20) */
    SCHD_REPEAT_AFTER = 3, /* ", REPEAT AFTER <exp>" -- delay measured from this cycle's completion (tag 0x30) */
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
    uint16_t on_event_syt;  /* valid iff has_on_event; only a plain (unsubscripted) EVENT SYT reference is
                              * confirmed (class-0/SCHD.md's "QUAL=1=SYT, plain EVENT ref, no VAC needed") */

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
    uint16_t stop_event_syt; /* valid iff stop_kind==SCHD_STOP_WHILE_BIT/UNTIL_BIT: re-read live (a plain
                               * SYT operand, unlike stop_deadline, needs no re-execution to get a fresh
                               * value) each time a cycle completes -- see interp.c's OP_CLOS. */
} halmat_task_t;

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

    /* Logical device number -> open file, see HALMAT_DEVICE_MAX above.
     * NULL = unmapped (READ/WRITE against it fails loudly). Not owned by
     * the interpreter -- main.c opens/closes any --ddi/--ddo files and
     * owns stdin/stdout, so interp_cleanup() must not fclose() these. */
    FILE *devices[HALMAT_DEVICE_MAX];

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
        struct {
            bool is_string;
            bool is_scalar;
            char *string;   /* borrowed from the literal table; not owned */
            int32_t integer;
            halmat_scalar_t scalar;
            /* READ/READALL only (kind != 2): the destination operand,
             * captured raw by XXAR rather than resolved to a value, plus
             * the HALMAT class number (XXAR's TAG1, class-0/XXAR.md) that
             * tells READ's handler which format to parse from the device.
             * Only INTEGER(6)/SCALAR(5) are implemented -- see interp.c's
             * OP_READ case. */
            halmat_operand_t dest_operand;
            uint8_t dest_class;
        } items[HALMAT_MAX_OPERANDS];
        uint8_t item_count;
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
    } shape_pending;

    /* Structure-field shadow-slot table, see halmat_struct_field_t above.
     * Growable (realloc'd in interp.c's find_or_create_struct_field). */
    halmat_struct_field_t *struct_fields;
    size_t struct_field_count;
    size_t struct_field_capacity;

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
     * variable directly and falls straight into the body (the range
     * form always runs its first in-range cycle without a pre-test,
     * per class-0/DFOR.md); EFOR increments, compares against the final
     * value (direction per the increment's sign), and either branches
     * back to just past DFOR (re-running the body) or falls through
     * (loop exit). Per-EFOR position: its matching DFOR's position, so
     * the increment/final/[step] operands can be read straight from it. */
    size_t *efor_dfor_pos;
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
     * class-0/SCHD.md's <SCHEDULE CONTROL> ::= <STOPPING> alternative, which
     * would presumably cancel a still-pending delayed AT/IN/ON activation
     * rather than end a cycle -- is not implemented; no fixture exercises
     * it and its semantics were never empirically confirmed, so OP_SCHD
     * fails loudly on that combination rather than guessing). virtual_time
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
    int *symbol_active_task; /* indexed by SYT symbol: index into tasks[], or -1; for named TERM/CANCEL */
};

#define HALMAT_MAX_CASES 64

#define HALMAT_LABEL_MAX 4096

#endif
