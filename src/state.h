#ifndef HALMAT_STATE_H
#define HALMAT_STATE_H

#include <stdbool.h>
#include <stdint.h>

#include "halmat.h"
#include "literal.h"
#include "opcode_table.h" /* for the halmat_state_t typedef */
#include "value.h"

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

/* ARRAY/MATRIX element storage: declared dimensions aren't visible
 * anywhere in HALMAT for the simple (no ADLP) cases seen so far -- that
 * needs the compiler's own symbol table (SYM_ARRAY et al in COMMON*.out),
 * which isn't parsed yet (a natural fit for the same --common/symtab
 * work M6's EXTERNAL-symbol linking will need). Until then, containers
 * get a generous fixed-size flat buffer and DSUB's multi-index offset
 * flattening uses a placeholder stride rather than the real per-
 * dimension extent -- fine for fixtures that don't observe layout via
 * printed output, wrong for anything that would actually depend on true
 * row-major addressing. See interp.c's DSUB handling. */
#define HALMAT_CONTAINER_CAPACITY 64

typedef enum {
    SYT_TYPE_UNKNOWN = 0,
    SYT_TYPE_INTEGER,
    SYT_TYPE_SCALAR,
} halmat_syt_type_t;

typedef struct {
    halmat_syt_type_t type;
    int32_t value;          /* SYT_TYPE_INTEGER */
    halmat_scalar_t scalar; /* SYT_TYPE_SCALAR (plain, non-subscripted) */
    halmat_scalar_t *elements; /* non-NULL => this symbol is an ARRAY/MATRIX of SCALAR; lazily allocated */
    size_t element_count;
} halmat_syt_entry_t;

/* A VAC slot either holds a plain computed value (most opcodes: IADD,
 * comparisons, etc.) or -- when produced by DSUB -- a reference into an
 * ARRAY/MATRIX element, to be read (dereferenced) or written (write-
 * through) depending on which operand position it's used in by the
 * consuming instruction. See class-0/DSUB.md and interp.c's DSUB/
 * resolve_operand/write_destination. */
typedef struct {
    bool is_ref;
    int32_t integer;   /* is_ref=false */
    uint16_t ref_syt;  /* is_ref=true */
    size_t ref_offset; /* is_ref=true */
} halmat_vac_slot_t;

struct halmat_state {
    const halmat_program_t *prog;
    const halmat_literal_table_t *literals;
    size_t pc; /* index into prog->instrs */

    halmat_syt_entry_t syt[HALMAT_SYT_MAX];
    halmat_vac_slot_t vac[HALMAT_VAC_MAX];

    int num_blanks; /* WRITE-item separator, Plan.md Phase 3 default 5 */

    /* Pending WRITE-statement argument list, accumulated between XXST
     * and XXND (see class-0/WRIT.md's Usage Context). */
    /* XXST/XXAR/XXND is a general bracketed-argument-list construct
     * (class-0/XXST.md), shared by I/O statements and function/procedure
     * calls alike -- discriminated by XXST's own operand qualifier
     * (IMD=I/O kind code, SYT=called symbol). */
    struct {
        bool active;
        bool is_call;
        int kind;             /* I/O case: XXST's IMD operand (2 = WRITE, only kind implemented) */
        uint16_t call_target; /* call case: XXST's SYT operand (the called function/procedure) */
        struct {
            bool is_string;
            char *string;   /* borrowed from the literal table; not owned */
            int32_t integer;
        } items[HALMAT_MAX_OPERANDS];
        uint8_t item_count;
    } io_pending;

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

    /* Function/procedure calls (FDEF/FCAL/RTRN/CLOS): a function's body
     * sits inline in the enclosing PROGRAM's own instruction stream, so
     * FDEF, reached by ordinary fall-through (i.e. NOT via a call jump,
     * since FCAL jumps past FDEF straight to its body), skips over the
     * whole definition to its matching CLOS. FCAL jumps to fdef_pos+1
     * and binds arguments to SYT slots per class-0/FCAL.md's confirmed
     * positional convention (callee_symbol+1+i). RTRN resolves its
     * operand as the return value, stores it in VAC at FCAL's own word
     * index (so the caller's ordinary VAC-qualified pickup works
     * unmodified), and jumps back to just past FCAL. See
     * interp.c's precompute_subprograms(). */
    size_t *symbol_fdef_pos;   /* indexed by SYT symbol: FDEF's array position, or NO_TARGET */
    size_t *fdef_clos_target;  /* per-FDEF position: matching CLOS's array position + 1 */
    size_t call_return_stack[64]; /* FCAL's own array position, per active call */
    int call_return_sp;
};

#define HALMAT_MAX_CASES 64

#define HALMAT_LABEL_MAX 4096

#endif
