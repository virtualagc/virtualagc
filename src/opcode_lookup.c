#include "opcode_table.h"

const opcode_desc_t *opcode_lookup(uint16_t combined_opcode) {
    size_t lo = 0, hi = g_opcode_table_count;
    while (lo < hi) {
        size_t mid = lo + (hi - lo) / 2;
        uint16_t v = g_opcode_table[mid].opcode;
        if (v == combined_opcode) {
            return &g_opcode_table[mid];
        } else if (v < combined_opcode) {
            lo = mid + 1;
        } else {
            hi = mid;
        }
    }
    return NULL;
}
