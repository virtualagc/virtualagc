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
 * targets. */
typedef struct {
    uint16_t base_syt, field_syt;
    halmat_syt_entry_t value;
} halmat_struct_field_t;

#define HALMAT_MAX_TASKS 32

typedef enum {
    TASK_READY,
    TASK_WAITING,
    TASK_TERMINATED,
} halmat_task_state_t;

typedef struct {
    bool in_use;
    bool is_primal;
    uint16_t symbol;   /* SYT slot of the task's own name (arbitrary for primal) */
    int priority;
    halmat_task_state_t task_state;
    size_t saved_pc;
    int64_t wake_deadline; /* virtual_time tick at which a TASK_WAITING task becomes TASK_READY */
    bool dependent;    /* SCHEDULE ... DEPENDENT was specified; parsed but not yet behaviorally enforced beyond primal-exit ending the whole program */
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

    /* Pending WRITE/READ-statement argument list, accumulated between
     * XXST and XXND (see class-0/WRIT.md's Usage Context). */
    /* XXST/XXAR/XXND is a general bracketed-argument-list construct
     * (class-0/XXST.md), shared by I/O statements and function/procedure
     * calls alike -- discriminated by XXST's own operand qualifier
     * (IMD=I/O kind code, SYT=called symbol). */
    struct {
        bool active;
        bool is_call;
        int kind;             /* I/O case: XXST's IMD operand (0=READ, 1=READALL, 2=WRITE) */
        uint16_t call_target; /* call case: XXST's SYT operand (the called function/procedure) */
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
    } io_pending;

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

    /* Virtual-clock task scheduler (SCHD/WAIT/TERM; SGNL/CANC/PRIO and
     * SCHD's delayed/cyclic AT/IN/ON/EVERY/AFTER/WHILE/UNTIL forms are
     * not yet implemented -- immediate SCHEDULE with PRIORITY/DEPENDENT
     * only). Ticks 1:1 per HALMAT instruction executed (the user's
     * confirmed per-instruction granularity choice), with WAIT's
     * duration treated as that many ticks -- an explicit, documented
     * simplification (no wall-clock fidelity is attempted regardless;
     * see Plan.md's Phase 3 scheduler notes), not a calibration to real
     * seconds. sched_advance() is the single seam where a future
     * `--time-scale` option could someday multiply ticks against a
     * wall-clock delta. Priority: 0 < P < 255, higher number = higher
     * priority, primal defaults to 50 (USA003087 Sec. 13.1-13.3). */
    halmat_task_t tasks[HALMAT_MAX_TASKS];
    int task_count;
    int current_task; /* index into tasks[], set by the scheduler loop before each instruction */
    int64_t virtual_time;
    int *symbol_active_task; /* indexed by SYT symbol: index into tasks[], or -1; for named TERM/CANCEL */
};

#define HALMAT_MAX_CASES 64

#define HALMAT_LABEL_MAX 4096

#endif
