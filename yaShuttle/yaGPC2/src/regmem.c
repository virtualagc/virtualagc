#include "regmem.h"

#include <stdlib.h>

/* ---------------------------------------------------------------------
 * Register
 * ------------------------------------------------------------------- */

void register_init(Register *r) {
    r->b[0] = r->b[1] = r->b[2] = r->b[3] = 0;
}

uint32_t register_get16(const Register *r) {
    return ((uint32_t)r->b[0] << 8) | (uint32_t)r->b[1];
}

void register_set16(Register *r, uint32_t v) {
    r->b[0] = (uint8_t)((v >> 8) & 0xff);
    r->b[1] = (uint8_t)(v & 0xff);
}

uint32_t register_get32(const Register *r) {
    return (register_get16(r) << 16) | (((uint32_t)r->b[2] << 8) | (uint32_t)r->b[3]);
}

void register_set32(Register *r, uint32_t v) {
    register_set16(r, (v >> 16) & 0xffff);
    r->b[2] = (uint8_t)((v >> 8) & 0xff);
    r->b[3] = (uint8_t)(v & 0xff);
}

uint32_t register_getbit32(const Register *r, int b) {
    uint32_t mask = 1u << b;
    return (register_get32(r) & mask) >> b;
}

uint32_t register_getbit16(const Register *r, int b) {
    uint32_t mask = 1u << b;
    return (register_get16(r) & mask) >> b;
}

void register_setbit32(Register *r, int b, uint32_t v) {
    uint32_t v1 = register_get32(r);
    uint32_t mask = 0xffffffffu ^ (1u << b);
    v1 = (v1 & mask) | (v << b);
    register_set32(r, v1);
}

void register_setbit16(Register *r, int b, uint32_t v) {
    uint32_t v1 = register_get16(r);
    uint32_t mask = 0xffffu ^ (1u << b);
    v1 = (v1 & mask) | (v << b);
    register_set16(r, v1);
}

/* ---------------------------------------------------------------------
 * RegisterFile
 * ------------------------------------------------------------------- */

RegisterFile registerfile_create(int num) {
    RegisterFile rf;
    rf.count = num + 1; /* CoffeeScript `[0..@num]` is inclusive */
    rf.regs = calloc((size_t)rf.count, sizeof(Register));
    for (int i = 0; i < rf.count; i++) register_init(&rf.regs[i]);
    rf.dse[0] = rf.dse[1] = rf.dse[2] = rf.dse[3] = 0;
    return rf;
}

void registerfile_free(RegisterFile *rf) {
    free(rf->regs);
    rf->regs = NULL;
    rf->count = 0;
}

Register *registerfile_r(RegisterFile *rf, int x) {
    return &rf->regs[x];
}

uint32_t registerfile_get_dse(const RegisterFile *rf, int baseReg) {
    return rf->dse[baseReg & 3];
}

void registerfile_set_dse(RegisterFile *rf, int baseReg, uint32_t value) {
    rf->dse[baseReg & 3] = (uint8_t)(value & 0xf);
}

/* ---------------------------------------------------------------------
 * ProgramStatusWord
 * ------------------------------------------------------------------- */

/* IBM-75-A97-001/p.21, IBM-6246156/p.29 — see regmem.coffee for the full
 * bit-layout comment. */
#define PSW_DESC1 "ppppppppppppppppccrvf_usbbbbdddd"
/* IBM-6246156B p.2-18, Figure 2-19: PSW2 is bits 32-63 (32 bits) --
 * 8-bit System Mask (32-39), 4 reserved (40-43), Register Set (44),
 * Machine Check Mask (45), Wait State (46), Problem/Supervisor (47),
 * 16-bit Interrupt Code (48-63). The historical descriptor here (and in
 * gpc/regmem.coffee's own @DESC2, ported faithfully) was 34 characters --
 * 18 i's instead of 16 -- which, via getFieldShft's `length - lastIndexOf
 * - 1`, shifts every field from 'r' onward two bits toward the MSB:
 * 'p' (problem/supervisor) read what is really bit 45 (machine check
 * mask), not bit 47, so any load of a supervisor-state PSW with the
 * machine check mask bit set was misread as problem (user) state.
 * Confirmed against the manual directly, not just against gpc, which
 * carries the identical defect (its own getFieldMask/getField coerce
 * through the same 32-bit bitwise ops once actually applied to real
 * 32-bit data, even though intermediate values are computed via
 * non-truncating parseInt). */
#define PSW_DESC2 "mmmmmmmmeeeercwpiiiiiiiiiiiiiiii"

static const PBField *f1(const ProgramStatusWord *p, char c) {
    return &p->pack1.field[(unsigned char)c];
}
static const PBField *f2(const ProgramStatusWord *p, char c) {
    return &p->pack2.field[(unsigned char)c];
}

static uint32_t get_field1(const ProgramStatusWord *p, char c) {
    return pb_get_field(register_get32(&p->psw1), f1(p, c));
}
static void set_field1(ProgramStatusWord *p, char c, uint32_t v) {
    uint32_t t = pb_set_fld(register_get32(&p->psw1), 32, f1(p, c), v);
    register_set32(&p->psw1, t);
}
static uint32_t get_field2(const ProgramStatusWord *p, char c) {
    return pb_get_field(register_get32(&p->psw2), f2(p, c));
}
static void set_field2(ProgramStatusWord *p, char c, uint32_t v) {
    uint32_t t = pb_set_fld(register_get32(&p->psw2), 32, f2(p, c), v);
    register_set32(&p->psw2, t);
}

void psw_init(ProgramStatusWord *p) {
    register_init(&p->psw1);
    register_init(&p->psw2);
    p->pack1 = pb_make_desc(PSW_DESC1);
    p->pack2 = pb_make_desc(PSW_DESC2);
}

uint32_t psw_get_nia(const ProgramStatusWord *p) {
    uint32_t nia16 = get_field1(p, 'p');
    if (nia16 & 0x8000) {
        return (psw_get_bsr(p) << 15) | (nia16 & 0x7FFF);
    }
    return nia16;
}

void psw_set_nia(ProgramStatusWord *p, uint32_t v) {
    uint32_t nia16;
    if (v >= 0x8000) {
        uint32_t sector = (v >> 15) & 0xF;
        psw_set_bsr(p, sector);
        nia16 = (v & 0x7FFF) | 0x8000;
    } else {
        nia16 = v & 0x7FFF;
    }
    set_field1(p, 'p', nia16);
}

uint32_t psw_get_cc(const ProgramStatusWord *p) { return get_field1(p, 'c'); }
void psw_set_cc(ProgramStatusWord *p, uint32_t v) { set_field1(p, 'c', v); }

uint32_t psw_get_carry(const ProgramStatusWord *p) { return get_field1(p, 'r'); }
void psw_set_carry(ProgramStatusWord *p, uint32_t v) { set_field1(p, 'r', v); }

uint32_t psw_get_overflow(const ProgramStatusWord *p) { return get_field1(p, 'v'); }
void psw_set_overflow(ProgramStatusWord *p, uint32_t v) { set_field1(p, 'v', v); }

uint32_t psw_get_fixed_pt_overflow(const ProgramStatusWord *p) { return get_field1(p, 'f'); }
void psw_set_fixed_pt_overflow(ProgramStatusWord *p, uint32_t v) { set_field1(p, 'f', v); }

uint32_t psw_get_exponent_underflow(const ProgramStatusWord *p) { return get_field1(p, 'u'); }
void psw_set_exponent_underflow(ProgramStatusWord *p, uint32_t v) { set_field1(p, 'u', v); }

uint32_t psw_get_significance_mask(const ProgramStatusWord *p) { return get_field1(p, 's'); }
void psw_set_significance_mask(ProgramStatusWord *p, uint32_t v) { set_field1(p, 's', v); }

uint32_t psw_get_bsr(const ProgramStatusWord *p) { return get_field1(p, 'b'); }
void psw_set_bsr(ProgramStatusWord *p, uint32_t v) { set_field1(p, 'b', v); }

uint32_t psw_get_dsr(const ProgramStatusWord *p) { return get_field1(p, 'd'); }
void psw_set_dsr(ProgramStatusWord *p, uint32_t v) { set_field1(p, 'd', v); }

uint32_t psw_get_int_mask(const ProgramStatusWord *p) { return get_field2(p, 'm'); }
void psw_set_int_mask(ProgramStatusWord *p, uint32_t v) { set_field2(p, 'm', v); }

uint32_t psw_get_reg_set(const ProgramStatusWord *p) { return get_field2(p, 'r'); }
void psw_set_reg_set(ProgramStatusWord *p, uint32_t v) { set_field2(p, 'r', v); }

uint32_t psw_get_mach_check_mask(const ProgramStatusWord *p) { return get_field2(p, 'c'); }
void psw_set_mach_check_mask(ProgramStatusWord *p, uint32_t v) { set_field2(p, 'c', v); }

int psw_get_wait_state(const ProgramStatusWord *p) { return !get_field2(p, 'w'); }
void psw_set_wait_state(ProgramStatusWord *p, int v) { set_field2(p, 'w', v ? 0u : 1u); }

int psw_get_problem_state(const ProgramStatusWord *p) { return (int)get_field2(p, 'p'); }
void psw_set_problem_state(ProgramStatusWord *p, int v) { set_field2(p, 'p', (uint32_t)v); }

uint32_t psw_get_int_code(const ProgramStatusWord *p) { return get_field2(p, 'i'); }
void psw_set_int_code(ProgramStatusWord *p, uint32_t v) { set_field2(p, 'i', v); }

void psw_load(ProgramStatusWord *p, uint32_t p1, uint32_t p2) {
    register_set32(&p->psw1, p1);
    register_set32(&p->psw2, p2);
}
