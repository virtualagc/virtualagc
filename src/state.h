#ifndef HALMAT_STATE_H
#define HALMAT_STATE_H

#include <stdbool.h>
#include <stdint.h>

#include "halmat.h"
#include "literal.h"
#include "opcode_table.h" /* for the halmat_state_t typedef */

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

typedef enum {
    SYT_TYPE_UNKNOWN = 0,
    SYT_TYPE_INTEGER,
} halmat_syt_type_t;

typedef struct {
    halmat_syt_type_t type;
    int32_t value; /* INTEGER only, for now; widened as other types are implemented */
} halmat_syt_entry_t;

struct halmat_state {
    const halmat_program_t *prog;
    const halmat_literal_table_t *literals;
    size_t pc; /* index into prog->instrs */

    halmat_syt_entry_t syt[HALMAT_SYT_MAX];
    int32_t vac[HALMAT_VAC_MAX];

    int num_blanks; /* WRITE-item separator, Plan.md Phase 3 default 5 */

    /* Pending WRITE-statement argument list, accumulated between XXST
     * and XXND (see class-0/WRIT.md's Usage Context). */
    struct {
        bool active;
        int kind; /* XXST's IMD operand: 2 = WRITE (only kind implemented so far) */
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
};

#define HALMAT_MAX_CASES 64

#define HALMAT_LABEL_MAX 4096

#endif
