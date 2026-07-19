#ifndef HALMAT_OPCODE_TABLE_H
#define HALMAT_OPCODE_TABLE_H

#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>

/* Forward declarations; real signatures land with the interpreter (M2)
 * and disassembler (M4) modules. Kept as typedefs here so opcode_desc_t's
 * shape doesn't need to change again once handlers exist. */
typedef struct halmat_state halmat_state_t;
typedef int (*exec_fn_t)(halmat_state_t *state);
typedef void (*disasm_fn_t)(halmat_state_t *state, char *out, size_t out_size);

typedef struct {
    uint16_t opcode;              /* combined 12-bit class:opcode */
    uint8_t hal_class;            /* 0..8, redundant with opcode, kept for convenience */
    const char *mnemonic;
    const char *gloss;            /* one-line description, from reengineered-documentation */
    const uint8_t *operand_roles; /* filled in per-opcode as implemented; NULL until then */
    uint8_t operand_role_count;
    bool trailing_repeats;        /* true for variadic instructions (e.g. WRIT's argument list) */
    exec_fn_t exec;               /* interpreter handler; NULL until implemented */
    disasm_fn_t disasm;           /* NULL => generic formatter */
} opcode_desc_t;

extern const opcode_desc_t g_opcode_table[];
extern const size_t g_opcode_table_count;

/* Binary search by combined 12-bit class:opcode; returns NULL if not found
 * (an opcode value never seen in reengineered-documentation's 179-entry
 * inventory -- see Plan.md M0.2 on the known-absent gaps). */
const opcode_desc_t *opcode_lookup(uint16_t combined_opcode);

#endif
