/* Register file and Program Status Word, ported from gpc/regmem.coffee.
 *
 * The JS RAM/Register classes carry access-tracking (lastRead/lastWritten,
 * a `step` counter) and a `setView` GUI-binding hook purely for the debug
 * GUI's memory/register panes to highlight recent writes. `gpc run` never
 * calls AGEHarness#_syncStep (grep-verified), so `step` never advances
 * past 0 in batch mode and none of that tracking is observable in `run`'s
 * output — omitted here entirely, per the port plan's Phase 2 scope.
 *
 * Similarly, `bits` (the constructor arg controlling how many halfwords
 * RAM allocates for a Register) turns out to have no effect on Register's
 * own get16/get32/set16/set32, which always address halfword index 0 (and
 * 1, for the 32-bit accessors) of the register's own storage regardless
 * of `bits` — every Register in this codebase uses bits in [18,32], which
 * always rounds up to exactly 2 halfwords anyway. So Register here is
 * just a fixed 4-byte big-endian cell. */
#ifndef YAGPC_REGMEM_H
#define YAGPC_REGMEM_H

#include <stdint.h>

#include "util.h"

typedef struct {
    uint8_t b[4]; /* big-endian: b[0..1] = halfword 0 (high), b[2..3] = halfword 1 (low) */
} Register;

void register_init(Register *r);
uint32_t register_get16(const Register *r);
void register_set16(Register *r, uint32_t v);
uint32_t register_get32(const Register *r);
void register_set32(Register *r, uint32_t v);
uint32_t register_getbit32(const Register *r, int b);
uint32_t register_getbit16(const Register *r, int b);
void register_setbit32(Register *r, int b, uint32_t v);
void register_setbit16(Register *r, int b, uint32_t v);

/* RegisterFile#r(x) allocates x in [0, num] via CoffeeScript's inclusive
 * `[0..@num]` range — i.e. num+1 registers, not num. Some call sites
 * genuinely rely on the "extra" top slot (e.g. iop.coffee addresses
 * regInterrupts[5] with num=5 -> 6 slots), so this is replicated exactly
 * rather than "fixed". */
typedef struct {
    Register *regs;
    int count;       /* == num + 1 */
    uint8_t dse[4];  /* 4-bit each; base registers 0-3 */
} RegisterFile;

RegisterFile registerfile_create(int num);
void registerfile_free(RegisterFile *rf);
Register *registerfile_r(RegisterFile *rf, int x);
uint32_t registerfile_get_dse(const RegisterFile *rf, int baseReg);
void registerfile_set_dse(RegisterFile *rf, int baseReg, uint32_t value);

/* ProgramStatusWord — see regmem.coffee's field-layout comment for the
 * PSW1/PSW2 bit assignments; the field descriptors themselves come from
 * PackedBits over DESC1/DESC2 (ported verbatim in regmem.c). */
typedef struct {
    Register psw1;
    Register psw2;
    PBDesc pack1;
    PBDesc pack2;
} ProgramStatusWord;

void psw_init(ProgramStatusWord *p);

uint32_t psw_get_nia(const ProgramStatusWord *p);
void psw_set_nia(ProgramStatusWord *p, uint32_t v);
uint32_t psw_get_cc(const ProgramStatusWord *p);
void psw_set_cc(ProgramStatusWord *p, uint32_t v);
uint32_t psw_get_carry(const ProgramStatusWord *p);
void psw_set_carry(ProgramStatusWord *p, uint32_t v);
uint32_t psw_get_overflow(const ProgramStatusWord *p);
void psw_set_overflow(ProgramStatusWord *p, uint32_t v);
uint32_t psw_get_fixed_pt_overflow(const ProgramStatusWord *p);
void psw_set_fixed_pt_overflow(ProgramStatusWord *p, uint32_t v);
uint32_t psw_get_exponent_underflow(const ProgramStatusWord *p);
void psw_set_exponent_underflow(ProgramStatusWord *p, uint32_t v);
uint32_t psw_get_significance_mask(const ProgramStatusWord *p);
void psw_set_significance_mask(ProgramStatusWord *p, uint32_t v);
uint32_t psw_get_bsr(const ProgramStatusWord *p);
void psw_set_bsr(ProgramStatusWord *p, uint32_t v);
uint32_t psw_get_dsr(const ProgramStatusWord *p);
void psw_set_dsr(ProgramStatusWord *p, uint32_t v);
uint32_t psw_get_int_mask(const ProgramStatusWord *p);
void psw_set_int_mask(ProgramStatusWord *p, uint32_t v);
uint32_t psw_get_reg_set(const ProgramStatusWord *p);
void psw_set_reg_set(ProgramStatusWord *p, uint32_t v);
uint32_t psw_get_mach_check_mask(const ProgramStatusWord *p);
void psw_set_mach_check_mask(ProgramStatusWord *p, uint32_t v);
int psw_get_wait_state(const ProgramStatusWord *p);
void psw_set_wait_state(ProgramStatusWord *p, int v);
int psw_get_problem_state(const ProgramStatusWord *p);
void psw_set_problem_state(ProgramStatusWord *p, int v);
uint32_t psw_get_int_code(const ProgramStatusWord *p);
void psw_set_int_code(ProgramStatusWord *p, uint32_t v);

void psw_load(ProgramStatusWord *p, uint32_t p1, uint32_t p2);

#endif
