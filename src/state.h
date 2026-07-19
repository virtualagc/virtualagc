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
};

#endif
