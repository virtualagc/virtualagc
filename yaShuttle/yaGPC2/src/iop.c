#include "iop.h"

#include <stdlib.h>
#include <string.h>

#include "cpu.h"

/* ---------------------------------------------------------------------
 * IOPLocalStore
 * ------------------------------------------------------------------- */

void iopls_init(IOPLocalStore *ls) {
    for (int i = 0; i <= 24; i++) ls->storePage[i] = registerfile_create(16);
    ls->slice = 0;
    ls->curBCE = 0;
    ls->curPage = 0;
}

void iopls_free(IOPLocalStore *ls) {
    for (int i = 0; i <= 24; i++) registerfile_free(&ls->storePage[i]);
}

void iopls_next_slice(IOPLocalStore *ls) {
    ls->slice++;
    if (ls->slice == 33) {
        ls->slice = 0;
        ls->curBCE = 0;
        ls->curPage = 0;
    }
    if (ls->slice % 4 != 0) {
        ls->curBCE++;
        ls->curPage = ls->curBCE;
    } else {
        ls->curPage = 0;
    }
}

RegisterFile *iopls_cp(IOPLocalStore *ls) { return &ls->storePage[ls->curPage]; }

Register *iopls_ls(IOPLocalStore *ls, int bank, int word) {
    return registerfile_r(iopls_cp(ls), bank * 4 + word);
}

Register *iopls_PC(IOPLocalStore *ls) { return iopls_ls(ls, 0, 2); }
Register *iopls_IH(IOPLocalStore *ls) { return iopls_ls(ls, 1, 2); }
Register *iopls_IL(IOPLocalStore *ls) { return iopls_ls(ls, 2, 2); }

Register *iopls_X(IOPLocalStore *ls) { return iopls_ls(ls, 0, 3); }
Register *iopls_AH(IOPLocalStore *ls) { return iopls_ls(ls, 1, 3); }
Register *iopls_AL(IOPLocalStore *ls) { return iopls_ls(ls, 2, 3); }
Register *iopls_ECR(IOPLocalStore *ls) { return iopls_ls(ls, 2, 6); }
Register *iopls_MST(IOPLocalStore *ls) { return iopls_ls(ls, 2, 7); }

Register *iopls_DH(IOPLocalStore *ls) { return iopls_ls(ls, 1, 0); }
Register *iopls_DL(IOPLocalStore *ls) { return iopls_ls(ls, 2, 0); }
Register *iopls_ID(IOPLocalStore *ls) { return iopls_ls(ls, 0, 3); }
Register *iopls_MTO(IOPLocalStore *ls) { return iopls_ls(ls, 1, 3); }
Register *iopls_BASE(IOPLocalStore *ls) { return iopls_ls(ls, 2, 3); }
Register *iopls_IUAR(IOPLocalStore *ls) { return iopls_ls(ls, 2, 5); }
Register *iopls_BSTH(IOPLocalStore *ls) { return iopls_ls(ls, 2, 6); }
Register *iopls_BSTL(IOPLocalStore *ls) { return iopls_ls(ls, 2, 7); }

uint32_t iopls_getI(IOPLocalStore *ls) {
    return (register_get16(iopls_IH(ls)) << 16) | register_get16(iopls_IL(ls));
}
void iopls_setI(IOPLocalStore *ls, uint32_t v) {
    register_set16(iopls_IH(ls), v >> 16);
    register_set16(iopls_IL(ls), v & 0xffff);
}

uint32_t iopls_getD(IOPLocalStore *ls) {
    return (register_get16(iopls_DH(ls)) << 16) | register_get16(iopls_DL(ls));
}
void iopls_setD(IOPLocalStore *ls, uint32_t v) {
    register_set16(iopls_DH(ls), v >> 16);
    register_set16(iopls_DL(ls), v & 0xffff);
}

uint32_t iopls_getACC(IOPLocalStore *ls) {
    return (register_get16(iopls_AH(ls)) << 16) | register_get16(iopls_AL(ls));
}
void iopls_setACC(IOPLocalStore *ls, uint32_t v) {
    register_set16(iopls_AH(ls), v >> 16);
    register_set16(iopls_AL(ls), v & 0xffff);
}

uint32_t iopls_getBST(IOPLocalStore *ls) {
    return (register_get16(iopls_BSTH(ls)) << 16) | register_get16(iopls_BSTL(ls));
}
void iopls_setBST(IOPLocalStore *ls, uint32_t v) {
    register_set16(iopls_BSTH(ls), v >> 16);
    register_set16(iopls_BSTL(ls), v & 0xffff);
}

/* ---------------------------------------------------------------------
 * MIA (networking stub, or servicer-backed — see iop.h header comment)
 * ------------------------------------------------------------------- */

void mia_init(MIA *m, int bceNum) { m->bceNum = bceNum; }

bool mia_data_available(struct IOP *iop, MIA *m) {
    if (!iop->servicer) return false;
    GpcServiceInput input = {.busID = m->bceNum, .address = 0};
    GpcServiceOutput output = {0};
    iop->servicer(iop->servicerCtx, GPC_SVC_RECV_POLL, &input, &output);
    return output.out.poll.available;
}

uint32_t mia_get_data(struct IOP *iop, MIA *m) {
    if (!iop->servicer) return 0;
    GpcServiceInput input = {.busID = m->bceNum, .address = 0};
    GpcServiceOutput output = {0};
    iop->servicer(iop->servicerCtx, GPC_SVC_RECV_WORD, &input, &output);
    return output.out.recv.available ? output.out.recv.word : 0;
}

void mia_xmit_word(struct IOP *iop, MIA *m, uint32_t halfword) {
    if (!iop->servicer) return;
    GpcServiceInput input = {.busID = m->bceNum, .address = 0, .in.word = halfword};
    GpcServiceOutput output = {0};
    iop->servicer(iop->servicerCtx, GPC_SVC_XMIT_WORD, &input, &output);
}

void mia_xmit_cmd(struct IOP *iop, MIA *m, uint32_t cmd24) {
    if (!iop->servicer) return;
    /* IUA occupies bits 19-23 of the 24-bit command word (see
     * exec_CMDI/exec_CMD in iop_bce_instr.c, which build it as
     * (IUA << 19) | rest). */
    GpcServiceInput input = {.busID = m->bceNum, .address = (int)((cmd24 >> 19) & 0x1fu), .in.word = cmd24};
    GpcServiceOutput output = {0};
    iop->servicer(iop->servicerCtx, GPC_SVC_XMIT_CMD, &input, &output);
}

void bce_init(BCE *b, int bceNum) {
    b->bceNum = bceNum;
    mia_init(&b->mia, bceNum);
}

void msc_init(MSC *m) {
    register_init(&m->regFailDisc);
    register_init(&m->regIntProg);
}

/* ---------------------------------------------------------------------
 * DMA queue — growable FIFO (mirrors Array#push/#shift)
 * ------------------------------------------------------------------- */

static void dmaq_init(DMAQueue *q) {
    q->cap = 64;
    q->items = malloc((size_t)q->cap * sizeof(DMARequest));
    q->head = 0;
    q->count = 0;
}

static void dmaq_free(DMAQueue *q) {
    free(q->items);
    q->items = NULL;
    q->cap = q->head = q->count = 0;
}

static void dmaq_push(DMAQueue *q, DMARequest req) {
    if (q->head + q->count >= q->cap) {
        if (q->head > 0) {
            memmove(q->items, q->items + q->head, (size_t)q->count * sizeof(DMARequest));
            q->head = 0;
        }
        if (q->count >= q->cap) {
            q->cap *= 2;
            q->items = realloc(q->items, (size_t)q->cap * sizeof(DMARequest));
        }
    }
    q->items[q->head + q->count] = req;
    q->count++;
}

static bool dmaq_shift(DMAQueue *q, DMARequest *out) {
    if (q->count == 0) return false;
    *out = q->items[q->head];
    q->head++;
    q->count--;
    return true;
}

/* ---------------------------------------------------------------------
 * IOP
 * ------------------------------------------------------------------- */

void iop_init(IOP *iop, struct CPU *cpu) {
    iop->cpu = cpu;

    msc_init(&iop->msc);
    for (int i = 0; i < 24; i++) bce_init(&iop->bce[i], i + 1);

    iop->curPE = 0;

    iop->dmaBurst = true;
    iop->dmaForceBadParity = false;
    iop->dataForceBadParity = false;

    register_init(&iop->regXmitEna);
    register_init(&iop->regRecvEna);
    register_init(&iop->regProgExcept);
    register_init(&iop->regBusyWait);
    register_init(&iop->regHalt);
    register_init(&iop->regIndicator);
    register_init(&iop->regDiscreteOut);
    register_init(&iop->regDiscreteInA);
    register_init(&iop->regDiscreteInB);
    register_init(&iop->regRMStatus);
    iop->regInterrupts = registerfile_create(5);
    iop->intForceTest = false;
    register_init(&iop->regCCData);

    iopls_init(&iop->ls);

    dmaq_init(&iop->dmaQueue);
    iop->clockCycleCount = 0;

    iop->servicer = NULL;
    iop->servicerCtx = NULL;
}

void iop_free(IOP *iop) {
    registerfile_free(&iop->regInterrupts);
    iopls_free(&iop->ls);
    dmaq_free(&iop->dmaQueue);
}

void iop_set_servicer(IOP *iop, GpcServicerFn fn, void *servicerCtx) {
    iop->servicer = fn;
    iop->servicerCtx = servicerCtx;
}

void iop_exec_channel_control(IOP *iop) { (void)iop; }
void iop_exec_rm(IOP *iop) { (void)iop; }

void iop_exec_dma_queue(IOP *iop) {
    if (iop->dmaQueue.count == 0) return;
    DMARequest req;
    dmaq_shift(&iop->dmaQueue, &req);
    if (req.direction == DMA_READ) {
        /* IOP reading from main memory (transmit to bus) */
        uint32_t data = mcm_get16(&iop->cpu->mainStorage, req.addr);
        iopls_setD(&iop->ls, data);
        if (req.bce) mia_xmit_word(iop, &req.bce->mia, data);
    } else {
        /* IOP writing to main memory (receive from bus) */
        uint32_t data;
        if (req.bce && mia_data_available(iop, &req.bce->mia)) {
            data = mia_get_data(iop, &req.bce->mia);
            iopls_setD(&iop->ls, data);
        } else {
            data = iopls_getD(&iop->ls);
        }
        mcm_set16(&iop->cpu->mainStorage, req.addr, data, false); /* bypass protection */
    }

    if (iop->dmaBurst && iop->dmaQueue.count > 0) {
        iop_exec_dma_queue(iop); /* burst mode: continue processing */
    }
}

void iop_exec_processors(IOP *iop) {
    iopls_next_slice(&iop->ls);
    int page = iop->ls.curPage;
    /* Fixes problems.md 1.5: gpc/iop.coffee initializes @curPE=0 ("MSC=0,
     * BCE=1-24") but never reassigns it anywhere, so every BCE
     * instruction's "2*curPE" addressing offset and per-PE bit indexing
     * always computed as if BCE 0 were running. curPage/curBCE (which
     * the round-robin scheduler *does* keep current, immediately above)
     * already carry exactly the intended value — 0 while MSC runs, 1-24
     * while a given BCE runs — so curPE just needs to track it here. */
    iop->curPE = page;

    if (page == 0) {
        if (register_getbit32(&iop->regHalt, 0)) return;
        if (!register_getbit32(&iop->regBusyWait, 0)) return;
    } else {
        int bceIdx = page;
        if (register_getbit32(&iop->regHalt, bceIdx)) return;
        if (!register_getbit32(&iop->regBusyWait, bceIdx)) return;
    }

    /* PC must be read/written via the 32-bit accessor here, matching every
     * instruction's own NIA logic (iop_set_nia/iop_incr_nia, and #BU/#BU@'s
     * direct register_set32 calls) — Register's get16()/set16() only touch
     * the register's *first* backing halfword, while get32()/set32() span
     * both (see regmem.c's Register comment). Using get16()/set16() here
     * (as gpc/iop.coffee's execProcessors does: `@ls.PC().get16()` vs
     * setNIA/incrNIA's `.get32()`) reads/writes a different halfword than
     * every instruction's own PC update, so for any address under 0x10000
     * (i.e. every real address in this system) the fetch loop never sees
     * what an instruction just set: BCE's PC never actually follows a
     * branch or a multi-halfword instruction's true length (just free-runs
     * on its own +1-per-tick default below), and MSC's PC never advances
     * past its initial value at all (no default-increment fallback exists
     * for MSC). Confirmed empirically against both paths; not merely a
     * theoretical concern. */
    uint32_t pc = register_get32(iopls_PC(&iop->ls));
    uint32_t hw1 = mcm_get16(&iop->cpu->mainStorage, pc);
    uint32_t hw2 = mcm_get16(&iop->cpu->mainStorage, pc + 1);
    register_set16(iopls_IH(&iop->ls), hw1);
    register_set16(iopls_IL(&iop->ls), hw2);

    if (page == 0) {
        msc_instr_exec(iop, hw1, hw2);
    } else {
        bce_instr_exec(iop, hw1, hw2);
    }
    /* Both MSC and BCE instructions manage their own NIA via
     * incrNIA/setNIA (see e.g. iop_bce_instr.c's #WIX, which must be able
     * to leave NIA untouched while waiting for a Listen command, and its
     * and MSC's own — deliberately asymmetric, see both files' comments
     * on unrecognized-instruction handling — behavior on an unrecognized
     * opcode). A second bug used to live here: this function forced BCE's
     * NIA to (pre-dispatch PC)+1 unconditionally after every call,
     * discarding whatever the matched instruction had just set — so
     * #BU/#BU@ branches and every multi-halfword instruction's true
     * length never actually took effect, silently replaced by a
     * halfword-per-tick free-run. Confirmed inherited from gpc/iop.coffee
     * verbatim (`@ls.PC().set16(pc + 1) # Default NIA increment for BCE`)
     * rather than a porting mistake. Removed; each instruction's own NIA
     * handling is authoritative now, matching how MSC already worked. */
}

void iop_exec(IOP *iop) {
    iop_exec_channel_control(iop);
    iop_exec_dma_queue(iop);
    iop_exec_processors(iop);
    iop_exec_rm(iop);
}

BCE *iop_cur_bce(IOP *iop) {
    if (iop->ls.curPage > 0) return &iop->bce[iop->ls.curPage - 1];
    return NULL;
}

void iop_queue_dma(IOP *iop, uint32_t addr, DMADirection direction, BCE *bce) {
    DMARequest req = {addr, direction, bce};
    dmaq_push(&iop->dmaQueue, req);
}

uint32_t iop_msc_ea(IOP *iop, uint32_t disp, bool indexed) {
    if (disp & 0x400) disp |= 0xfffff800u;
    uint32_t pc = register_get32(iopls_PC(&iop->ls));
    uint32_t ea = (pc + disp) & 0x3ffff;
    if (indexed) {
        uint32_t x = register_get32(iopls_X(&iop->ls));
        ea = (ea + x) & 0x3ffff;
    }
    return ea;
}

uint32_t iop_msc_long_ea(IOP *iop, uint32_t addr, bool indexed) {
    uint32_t ea = addr & 0x3ffff;
    if (indexed) {
        uint32_t x = register_get32(iopls_X(&iop->ls));
        ea = (ea + x) & 0x3ffff;
    }
    return ea;
}

uint32_t iop_g_eaf(IOP *iop, uint32_t addr) { return mcm_get32(&iop->cpu->mainStorage, addr); }
uint32_t iop_g_eah(IOP *iop, uint32_t addr) { return mcm_get16(&iop->cpu->mainStorage, addr); }
void iop_s_eaf(IOP *iop, uint32_t addr, uint32_t value) { mcm_set32(&iop->cpu->mainStorage, addr, value, false); }
void iop_s_eah(IOP *iop, uint32_t addr, uint32_t value) { mcm_set16(&iop->cpu->mainStorage, addr, value, false); }

void iop_set_nia(IOP *iop, uint32_t x) { register_set32(iopls_PC(&iop->ls), x); }
void iop_incr_nia(IOP *iop, int incr) {
    iop_set_nia(iop, register_get32(iopls_PC(&iop->ls)) + (uint32_t)incr);
}

/* ---------------------------------------------------------------------
 * CPU <-> IOP link (cpu.h declares these as iop_recv_from_cpu/iop_get_cc_data)
 * ------------------------------------------------------------------- */

uint32_t iop_get_cc_data(IOP *iop) { return register_get32(&iop->regCCData); }

void iop_recv_from_cpu(IOP *iop, uint32_t cmd, uint32_t data) {
    uint32_t isOutput = cmd >> 31;
    uint32_t devSelect = (cmd >> 25) & 0x1f;
    uint32_t dataSelect = (cmd >> 14) & 0x3ff;

    register_set32(&iop->regCCData, data);

    switch (cmd) {
        case 0xc0030000: /* DMA BURST INHIBIT */
            iop->dmaBurst = false;
            break;
        case 0xc1040000: /* DMA BURST ENABLE */
            iop->dmaBurst = true;
            break;
        case 0xc1100000: /* BAD PARITY DMA ADDRESS ENABLE */
            iop->dmaForceBadParity = true;
            break;
        case 0xc0100000: /* BAD PARITY DMA ADDRESS DISABLE */
            iop->dmaForceBadParity = false;
            break;
        case 0xc1200000: /* BAD PARITY DATA INPUT ENABLE */
            iop->dataForceBadParity = true;
            break;
        case 0xc0200000: /* BAD PARITY DATA INPUT DISABLE */
            iop->dataForceBadParity = false;
            break;
        case 0x84040000: { /* MIA TRANSMITTER DISABLE */
            uint32_t r1 = register_get32(&iop->regXmitEna);
            uint32_t r2 = r1 & data;
            r1 = r1 ^ r2;
            register_set32(&iop->regXmitEna, r1);
            break;
        }
        case 0x85040000: { /* MIA TRANSMITTER ENABLE */
            uint32_t r1 = register_get32(&iop->regXmitEna);
            r1 = r1 | data;
            register_set32(&iop->regXmitEna, r1);
            break;
        }
        case 0x84080000: { /* MIA RECEIVER DISABLE */
            uint32_t r1 = register_get32(&iop->regRecvEna);
            uint32_t r2 = r1 & data;
            r1 = r1 ^ r2;
            register_set32(&iop->regRecvEna, r1);
            break;
        }
        case 0x85080000: { /* MIA RECEIVER ENABLE */
            uint32_t r1 = register_get32(&iop->regRecvEna);
            r1 = r1 | data;
            register_set32(&iop->regRecvEna, r1);
            break;
        }
        case 0x84100000: { /* DISCRETE OUTPUT RESET */
            uint32_t r1 = register_get32(&iop->regDiscreteOut);
            uint32_t r2 = r1 & data;
            r1 = r1 ^ r2;
            register_set32(&iop->regDiscreteOut, r1);
            break;
        }
        case 0x85100000: { /* DISCRETE OUTPUT SET */
            uint32_t r1 = register_get32(&iop->regDiscreteOut);
            r1 = r1 | data;
            register_set32(&iop->regDiscreteOut, r1);
            break;
        }
        case 0x86200000: { /* CONFIGURE PROCESSORS HALT */
            uint32_t r1 = register_get32(&iop->regHalt);
            r1 = r1 | data;
            register_set32(&iop->regHalt, r1);
            break;
        }
        case 0x87200000: { /* CONFIGURE PROCESSORS ENABLE */
            uint32_t r1 = register_get32(&iop->regHalt);
            uint32_t r2 = r1 & data;
            r1 = r1 ^ r2;
            register_set32(&iop->regHalt, r1);
            break;
        }
        case 0x84400000: /* MASTER RESET */
            register_set32(&iop->regProgExcept, 0xfffff800u);
            register_set32(&iop->regBusyWait, 0x00000000u);
            register_set32(&iop->regHalt, 0xfffff800u);
            register_set32(&iop->regXmitEna, 0x00000000u);
            register_set32(&iop->regRecvEna, 0x00000000u);
            register_set32(&iop->regDiscreteOut, 0x00000000u);
            break;
        case 0x88040000: { /* LOAD GO/NO-GO TIMER */
            uint32_t r1 = register_get32(&iop->regRMStatus);
            uint32_t timerVal = data & 0x00000fffu;
            r1 = (r1 & 0xf000ffffu) | (timerVal << 16);
            register_set32(&iop->regRMStatus, r1);
            break;
        }
        case 0x88048000: { /* LOAD GO/NO-GO TIMER TEST */
            uint32_t r1 = register_get32(&iop->regRMStatus);
            uint32_t timerVal = data & 0x00000fffu;
            r1 = (r1 & 0xf000ffffu) | (timerVal << 16);
            register_set32(&iop->regRMStatus, r1);
            break;
        }
        case 0x88080000: { /* CONFIGURE TERMINATION CONTROL LATCHES */
            uint32_t timerLatch = (data >> 1) & 0x1u;
            uint32_t voterLatch = data & 0x1u;
            uint32_t r1 = register_get32(&iop->regRMStatus);
            r1 = (r1 & 0xffffafffu) | (timerLatch << 12) | (voterLatch << 14);
            register_set32(&iop->regRMStatus, r1);
            break;
        }
        case 0x88100000: /* LOAD TEST REGISTER */
            return;      /* no-op */
        case 0x88180000: /* TEST INTERRUPTS */
            iop->intForceTest = true;
            register_set32(registerfile_r(&iop->regInterrupts, 0), 0xffffffffu);
            register_set32(registerfile_r(&iop->regInterrupts, 1), 0xffffffffu);
            register_set32(registerfile_r(&iop->regInterrupts, 3), 0xffffffffu);
            register_set32(registerfile_r(&iop->regInterrupts, 4), 0xffffffffu);
            break;
        case 0x88140000: /* ENABLE INTERRUPTS */
            iop->intForceTest = false;
            break;
        case 0x92000000: /* RESET STATUS1(GO/NO-GO) */
            return;      /* no-op */
        case 0x92040000: { /* LOAD MSC BUSY */
            uint32_t r1 = register_get32(&iop->regBusyWait);
            r1 |= (1u << 0);
            register_set32(&iop->regBusyWait, r1);
            break;
        }
        case 0xc1008000: /* INHIBIT COMPLETION OF A DMA CYCLE */
            return;      /* no-op */
        case 0x04000000: /* READ MIA TRANSMITTER STATUS */
            register_set32(&iop->regCCData, register_get32(&iop->regXmitEna));
            break;
        case 0x40400000: /* READ MIA RECEIVER STATUS */
            register_set32(&iop->regCCData, register_get32(&iop->regRecvEna));
            break;
        case 0x04080000: /* READ DISCRETE OUTPUT STATUS */
            register_set32(&iop->regCCData, register_get32(&iop->regDiscreteOut));
            break;
        case 0x040c0000: /* READ PROCESSOR HALT STATUS */
            register_set32(&iop->regCCData, register_get32(&iop->regHalt));
            break;
        case 0x08000000: /* READ INTERRUPT REGISTER A */
            register_set32(&iop->regCCData, register_get32(registerfile_r(&iop->regInterrupts, 0)));
            register_set32(registerfile_r(&iop->regInterrupts, 0), 0x0);
            break;
        case 0x08040000: /* READ INTERRUPT REGISTER B */
            register_set32(&iop->regCCData, register_get32(registerfile_r(&iop->regInterrupts, 1)));
            register_set32(registerfile_r(&iop->regInterrupts, 1), 0x0);
            break;
        case 0x08080000: /* READ INTERRUPT REGISTER C */
            register_set32(&iop->regCCData, register_get32(registerfile_r(&iop->regInterrupts, 2)));
            register_set32(registerfile_r(&iop->regInterrupts, 2), 0x0);
            break;
        case 0x080c0000: /* READ INTERRUPT REGISTER D */
            register_set32(&iop->regCCData, register_get32(registerfile_r(&iop->regInterrupts, 3)));
            register_set32(registerfile_r(&iop->regInterrupts, 3), 0x0);
            break;
        case 0x08100000: /* READ INTERRUPT REGISTER E */
            register_set32(&iop->regCCData, register_get32(registerfile_r(&iop->regInterrupts, 4)));
            register_set32(registerfile_r(&iop->regInterrupts, 4), 0x0);
            break;
        case 0x08140000: /* READ RM STATUS REGISTERS */
            register_set32(&iop->regCCData, register_get32(&iop->regRMStatus));
            register_set32(registerfile_r(&iop->regInterrupts, 5), 0x0);
            break;
        case 0x08180000: /* READ DISCRETE INPUT A (1-32) */
            register_set32(&iop->regCCData, register_get32(&iop->regDiscreteInA));
            break;
        case 0x081c0000: /* READ DISCRETE INPUTS (33-40) */
            register_set32(&iop->regCCData, register_get32(&iop->regDiscreteInA));
            break;
        case 0x10000000: /* READ STATUS1(GO/NO-GO) */
            register_set32(&iop->regCCData, register_get32(&iop->regProgExcept));
            break;
        case 0x10040000: /* READ STATUS4(BUSY/WAIT) */
            register_set32(&iop->regCCData, register_get32(&iop->regBusyWait));
            break;
        default:
            break;
    }

    if (devSelect == 0x8) { /* Local Store */
        uint32_t region = dataSelect >> 5;
        uint32_t bank = (dataSelect >> 3) & 0x3;
        uint32_t word = dataSelect & 0x7;
        (void)region;

        Register *r = iopls_ls(&iop->ls, (int)bank, (int)word);
        if (isOutput) {
            register_set32(&iop->regCCData, register_get32(r));
        } else {
            register_set32(r, data);
        }
    }
}
