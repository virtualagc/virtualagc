/* Cross-checks instr_to_str() (gpc/cpu_instr.coffee's Instruction#toStr —
 * disassembly text for --trace output and watchpoint messages) against
 * the live CoffeeScript across random (hw1, hw2) pairs spanning the full
 * 16-bit space (naturally exercises every instruction plus plenty of
 * UNDEFINED no-matches, since toStr just formats decode()'s own output).
 *
 * Fixtures regenerated via:
 *   node test/gen_instr_tostr_fixtures.cjs 20000 > fixtures.json
 *   python3 test/gen_instr_tostr_fixtures_header.py fixtures.json > test/instr_tostr_fixtures.h
 */
#include <stdio.h>
#include <string.h>

#include "../src/cpu_instr.h"
#include "instr_tostr_fixtures.h"

int main(void) {
    int total = (int)(sizeof(TOSTR_FIXTURES) / sizeof(TOSTR_FIXTURES[0]));
    int failures = 0;
    for (int i = 0; i < total; i++) {
        const ToStrFixture *fx = &TOSTR_FIXTURES[i];
        char got[256];
        instr_to_str(fx->hw1, fx->hw2, got, sizeof got);
        if (strcmp(got, fx->s) != 0) {
            printf("FAIL [%04x,%04x]: got=\"%s\" expected=\"%s\"\n", fx->hw1, fx->hw2, got, fx->s);
            failures++;
        }
    }
    printf("%d/%d toStr fixtures passed\n", total - failures, total);
    return failures == 0 ? 0 : 1;
}
