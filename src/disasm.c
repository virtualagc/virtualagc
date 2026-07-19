#include "disasm.h"

#include "opcode_table.h"

void halmat_disasm_program(const halmat_program_t *prog, FILE *out) {
    for (size_t i = 0; i < prog->count; i++) {
        const halmat_instr_t *ins = &prog->instrs[i];
        const opcode_desc_t *desc = opcode_lookup(ins->opcode);
        const char *mnemonic = desc ? desc->mnemonic : "????";
        const char *gloss = desc ? desc->gloss : "unknown opcode -- not in the 179-entry inventory";

        fprintf(out, "#%-6zu 0x%03X %-4s  numop=%u tag=0x%02X copt=0x%X  ; %s\n",
                ins->index, ins->opcode, mnemonic, ins->numop, ins->tag, ins->copt, gloss);

        for (uint8_t o = 0; o < ins->operand_count; o++) {
            const halmat_operand_t *op = &ins->operands[o];
            fprintf(out, "        [%u] data=0x%04X(%u) qual=%s tag1=0x%02X tag2=0x%X\n",
                    o, op->data, op->data, halmat_qual_name(op->qual), op->tag1, op->tag2);
        }
    }
}
