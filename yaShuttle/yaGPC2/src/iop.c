#include "iop.h"
#include <stdio.h>
#include <stdlib.h>

#include <stdlib.h>
#include <string.h>

#include "cpu.h"

/* Interrupt register A (Group 1 / EX0) sources, in the order the
 * instruction set lists them.  Reading register A is how the EX0 handler
 * learns which of these raised it; the read is destructive (read and
 * clear), which is why the values live here rather than being recomputed.
 *
 *   GO_NOGO    the go/no-go (watchdog) timer timed out
 *   IOP_FAIL   IOP fail latch, from the RM voter logic -- a Computer Fail
 *              affecting the capability of the machine, originating in
 *              the voter rather than in transmission termination
 *   CM_IDLE    "The IOP Control/Monitor logic is in the Idle mode and
 *              available for further operations."
 *   ROS_PAR    parity error during a transfer from IOP Read Only Storage
 *   IOP_FAULT  IOP timing fault
 */
/* One GO/NO-GO timer count is 0.768 ms -- "bit 31 = 0.768 ms" in the
 * POO's own RM status layout -- and the count is 12 bits wide. */
#define WD_TICK_US     768.0
#define WD_COUNT_MASK  0xfffu

/* Which bits of a MIA enable/disable data word are writable: BCE 1-24
 * in processor numbering.  Only they have MIAs. */
#define MIA_WRITE_MASK 0x7fffff80u

#define INTA_GO_NOGO   0x80000000u
#define INTA_IOP_FAIL  0x40000000u
#define INTA_CM_IDLE   0x20000000u
#define INTA_IOP_FAULT 0x08000000u

/* Discrete inputs.
 *
 * The two discrete-input registers carry the switch positions and vehicle
 * signals the software configures itself from.  The IOP Principles of
 * Operation, carried as an appendix of AP-101S-instruction-set.txt, gives
 * the bits under "PCI FORMAT / READ DISCRETE INPUT A" (08180000, device
 * DF) and "READ DISCRETE INPUTS B" (081c0000, device RM), where "0 = D.I.
 * RESET, 1 = D.I. SET" and IBM bit numbering runs from the MS end:
 *
 *   A   0-2   HALT / STANDBY / RUN crew panel switches ("The setting of
 *             this bit indicates that the crew panel switch has been set
 *             to 'HALT'", which holds the CPU in system reset)
 *       4,5   MM1 / MM2 selected as the IPL source
 *       6,7   MM1 / MM2 READY -- the MMU's own signal, not a switch
 *   B   0-2   GPC SELF ID (1-5; 0 is NOT a legal ID)
 *       3-5   BFS ENGAGE 1/2/3, "set by orbiter BFS controller when BFS
 *             engage push-button is depressed"
 *       6,7   BFS CRT SELECT A and B, the current setting of the orbiter
 *             BFC CRT select switch
 *      8-31   not used
 *
 * Nothing in this emulator drives them yet, so they hold a fixed default
 * standing in for the crew panel and the vehicle: GPC 1, IPL source MM1,
 * MM1 ready, display CRT 1.  Leaving them zero -- which is what this port
 * did -- is not a neutral choice: it reports GPC ID 0, which is not a
 * legal ID, so GPCIPL cannot identify itself. */
#define DISCRETE_IN_A_DEFAULT 0x0a000000u  /* bit 4 MM1 IPL source, bit 6 MM1 ready */
#define DISCRETE_IN_B_DEFAULT 0x21000000u  /* bits 0-2 GPC 1, bits 6-7 CRT 1 */

/* An MIA enable register as its READ PCI reports it.
 *
 * The registers are kept in PROCESSOR numbering, bit n being BCE n with
 * the MSC at bit 0.  The READ PCIs answer in CHANNEL numbering instead --
 * "BIT 0 CHANNEL NO. 1 MIA TRANSMITTER ... BIT 23 CHANNEL NO. 24 MIA
 * TRANSMITTER, BIT 24-31 NOT USED. BITS, IF SET, ARE INVALID." -- so what
 * comes back is the stored word moved one place left and cut off above
 * channel 24.  Returning the register raw, as this port did, reports
 * every channel one place off. */
#define MIA_READ_MASK 0xffffff00u

static uint32_t mia_read_back(const Register *reg) {
    return (register_get32(reg) << 1) & MIA_READ_MASK;
}

uint32_t iop_proc_bit(int p) { return 0x80000000u >> p; }

uint32_t iop_proc_get(const Register *r, int p) {
    return (register_get32(r) & iop_proc_bit(p)) ? 1u : 0u;
}

void iop_proc_set(Register *r, int p, uint32_t v) {
    uint32_t m = iop_proc_bit(p);
    uint32_t cur = register_get32(r);
    register_set32(r, v ? (cur | m) : (cur & ~m));
}

bool iop_any_processor_running(const IOP *iop) {
    uint32_t enabled = register_get32(&iop->regHalt);
    uint32_t busy = register_get32(&iop->regBusyWait);
    return (enabled & busy & PROC_ALL) != 0;
}

bool iop_has_servicer(const IOP *iop) { return iop->servicer != NULL; }

void iop_reset_discrete_inputs(IOP *iop) {
    register_set32(&iop->regDiscreteInA, DISCRETE_IN_A_DEFAULT);
    register_set32(&iop->regDiscreteInB, DISCRETE_IN_B_DEFAULT);
}

/* ---------------------------------------------------------------------
 * IOPLocalStore
 * ------------------------------------------------------------------- */

void iopls_init(IOPLocalStore *ls) {
    for (int i = 0; i <= PROC_SELFTEST; i++) ls->storePage[i] = registerfile_create(16);
    ls->slice = 0;
    ls->curBCE = 0;
    ls->curPage = 0;
}

void iopls_free(IOPLocalStore *ls) {
    for (int i = 0; i <= PROC_SELFTEST; i++) registerfile_free(&ls->storePage[i]);
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

Register *iopls_at(IOPLocalStore *ls, int region, int bank, int word) {
    if (region < 0 || region > PROC_SELFTEST) return NULL;
    return registerfile_r(&ls->storePage[region], bank * 4 + word);
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
    b->delayActive = false;
    b->delayPC = 0;
    b->delayUntilUs = 0.0;
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
    iop_reset_discrete_inputs(iop);
    register_init(&iop->regRMStatus);
    iop->wdCount = 0;
    iop->wdRunning = false;
    iop->wdTimeout = false;
    iop->wdAccumUs = 0.0;
    iop->wdLastUs = 0.0;
    iop->rmVoterInhibit = false;
    iop->rmTestInputs = 0;
    iop->rmVoterFail = false;
    /* "Events that disable parity checking include Power On, System
     * Reset", so the machine starts with the checkers off. */
    iop->parityEnabled = false;
    iop->forceHBusParity = false;
    iop->forceQueueParity = false;
    iop->forceDMAParity = false;
    iop->forceMIAParity = false;
    for (int i = 0; i <= PROC_SELFTEST; i++) iop->lsBadParity[i] = 0;
    iop->regInterrupts = registerfile_create(5);
    iop->intForceTest = false;
    register_init(&iop->regCCData);

    iopls_init(&iop->ls);

    dmaq_init(&iop->dmaQueue);
    iop->clockCycleCount = 0;
    iop->mscRepeatActive = false;
    iop->mscRepeatPC = 0;
    iop->mscRepeatUntilUs = 0.0;

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
/* Set one of the Group 1 bits and interrupt the CPU on External 0.  The
 * five conditions are grouped onto the one level, so this is a pulse to
 * the CPU's pending latch and not a level: the register is cleared by
 * the handler's own read. */
void iop_signal_group1(IOP *iop, uint32_t bit) {
    Register *a = registerfile_r(&iop->regInterrupts, 0);
    register_set32(a, register_get32(a) | bit);
    if (iop->cpu != NULL) iop->cpu->intPending.iopGrp1 = true;
}

/* LOAD GO/NO-GO TIMER (PCO 88040000).  The data word's low 12 bits are
 * the count; the PCO is what starts the counter and resets the timeout
 * latch. */
static void iop_load_watchdog(IOP *iop, uint32_t value) {
    iop->wdCount = value & WD_COUNT_MASK;
    iop->wdRunning = true;
    iop->wdTimeout = false;
    iop->wdAccumUs = 0.0;
    iop->wdLastUs = (iop->cpu != NULL) ? iop->cpu->elapsedTimeUs : 0.0;
}

/* The test form (PCO 88048000): "This PCO is used to load the Go/No-Go
 * Timer with any chosen value which is incremented by one low order bit
 * and read with a PCI (READ STATUS REGISTER) to determine the operating
 * status of the timer."  The same load plus the single increment the
 * hardware injects; a wrap past a full count latches the timeout the way
 * any other full count does, which is why STM1 resets the latch with
 * another load once it has read the count back. */
static void iop_load_watchdog_test(IOP *iop, uint32_t value) {
    iop_load_watchdog(iop, value);
    iop->wdRunning = false;
    iop->wdCount = (iop->wdCount + 1) & WD_COUNT_MASK;
    if (iop->wdCount == 0) {
        iop->wdTimeout = true;
        iop_signal_group1(iop, INTA_GO_NOGO);
    }
}

/* LOAD TEST REGISTER (PCO 88100000): redundancy management's voter, in
 * the only mode a single simulated GPC can exercise -- self test. */
static void iop_load_voter_test(IOP *iop, uint32_t data) {
    iop->rmVoterInhibit = (data & 0x10u) != 0;
    iop->rmTestInputs = data & 0xfu;
    int votes = 0;
    for (uint32_t b = 0x8u; b != 0; b >>= 1)
        if (iop->rmTestInputs & b) votes++;
    iop->rmVoterFail = votes >= 2;
}

/* Carry the watchdog forward to the CPU's clock.  A full count (the
 * counter wrapping back to zero) is the timeout: it sets the timeout
 * latch, which on a real vehicle drives the Computer Fail output, and
 * raises External 0 through Group 1 bit 0. */
void iop_tick_watchdog(IOP *iop) {
    if (!iop->wdRunning || iop->cpu == NULL) return;
    double now = iop->cpu->elapsedTimeUs;
    iop->wdAccumUs += now - iop->wdLastUs;
    iop->wdLastUs = now;
    while (iop->wdAccumUs >= WD_TICK_US) {
        iop->wdAccumUs -= WD_TICK_US;
        iop->wdCount = (iop->wdCount + 1) & WD_COUNT_MASK;
        if (iop->wdCount == 0) {
            iop->wdTimeout = true;
            iop->wdRunning = false;
            iop->wdAccumUs = 0.0;
            iop_signal_group1(iop, INTA_GO_NOGO);
            return;
        }
    }
}

/* The RM status register as the CPU reads it (POO Appendix I, READ RM
 * STATUS REGISTER), IBM bit numbering:
 *    0     fail or timeout latch (the voter's failure, or a timeout)
 *    1     PCO inhibiting the fail vote inputs for test
 *    3-6   failure votes in from the other IOPs
 *    7-10  failure votes out to them (set by the MSC; not modeled)
 *    11-14 the voter's four test inputs
 *    15    voter fail latch
 *    16    timeout latch
 *    17    voter termination control latch
 *    18    timer termination control latch
 *    20-31 GO/NO-GO timer count, bit 31 = 0.768 ms
 * Only bits 17-18 are actually stored; the rest is composed here.  This
 * read used to hand back the raw register, which held the loaded timer
 * value parked in the wrong field and none of the voter state at all. */
uint32_t iop_rm_status(const IOP *iop) {
    uint32_t v = register_get32(&iop->regRMStatus) & 0x00006000u; /* bits 17-18 */
    if (iop->rmVoterInhibit) v |= 0x40000000u;
    v |= (iop->rmTestInputs & 0xfu) << 17;
    if (iop->rmVoterFail) v |= 0x00010000u;
    if (iop->wdTimeout) v |= 0x00008000u;
    /* Bit 0 is the two of them together: "RM has detected a failure and
     * set the failure latch or ... the watchdog timer has timed out
     * forcing the fail latch." */
    if (iop->rmVoterFail || iop->wdTimeout) v |= 0x80000000u;
    v |= iop->wdCount & WD_COUNT_MASK;
    return v;
}

/* Redundancy management: the GO/NO-GO timer is RM's, and this is where
 * it advances.  Called once per CPU instruction, and also from the wait
 * loop -- the watchdog runs on wall time, not CPU instructions, so it
 * keeps counting through the wait state. */
/* Reset the four bad-parity generators.  "The Disable Flow Parity Check
 * PCO command disables the parity checkers.  It also resets any parity
 * generator which is forcing bad parity in response to one of the 'force
 * bad parity' PCOs."  Power on does the same. */
static void iop_reset_parity_generators(IOP *iop) {
    iop->forceHBusParity = false;
    iop->forceQueueParity = false;
    iop->forceDMAParity = false;
    iop->forceMIAParity = false;
}

/* A checker caught bad parity (POO Appendix I, DATA FLOW PARITY CHECK):
 * "an external 1 interrupt is issued to the CPU and all BCE's and the MSC
 * are halted, all transmitter and receiver enables are disabled and the
 * discrete outputs are reset.  The cause of this interrupt can be
 * determined by reading the IOP interrupt register B."
 *
 * The error leaves checking DISABLED and the generators reset, which is
 * why software that walks the four checkers re-issues ENABLE FLOW PARITY
 * CHECK before every one of them.  Nothing happens at all while checking
 * is disabled: "if parity is disabled no error indication is made". */
bool iop_signal_data_flow_parity(IOP *iop, uint32_t code) {
    if (!iop->parityEnabled) return false;
    Register *b = registerfile_r(&iop->regInterrupts, 1);
    uint32_t cur = (register_get32(b) & INTB_CODE_MASK) >> INTB_CODE_SHIFT;
    if (cur > code) code = cur;   /* only the highest priority is annunciated */
    register_set32(b, (register_get32(b) & ~INTB_CODE_MASK)
                      | (code << INTB_CODE_SHIFT));

    register_set32(&iop->regHalt, 0x00000000u);   /* MSC and every BCE halted */
    register_set32(&iop->regXmitEna, 0x00000000u);
    register_set32(&iop->regRecvEna, 0x00000000u);
    register_set32(&iop->regDiscreteOut, 0x00000000u);

    iop->parityEnabled = false;
    iop_reset_parity_generators(iop);

    /* External 1 with interrupt code 0000 -- IOP data flow error. */
    if (iop->cpu) {
        psw_set_int_code(&iop->cpu->psw, 0x0000);
        iop->cpu->intPending.iopGrp2 = true;
    }
    return true;
}

/* Every IOP access to CPU main storage goes over the DMA path. */
bool iop_check_dma_parity(IOP *iop) {
    if (!(iop->parityEnabled && iop->forceDMAParity)) return false;
    return iop_signal_data_flow_parity(iop, INTB_DMA);
}

/* The local store address lines and the queue control bits.  Used by both
 * the CPU's local store PCI/PCO and by a processor's own instruction
 * fetch (the queue is what an instruction is fetched into). */
bool iop_check_queue_parity(IOP *iop) {
    if (!(iop->parityEnabled && iop->forceQueueParity)) return false;
    return iop_signal_data_flow_parity(iop, INTB_QUEUE);
}

/* The bus out to the octal MIA pages: "on the IB page parity is generated
 * for all data and command words being sent to the octal MIA.  Parity for
 * this bus is then checked on the MIA's, which sends an error message back
 * to the IOP if any errors are detected."  Called by anything that puts a
 * word on that bus. */
bool iop_check_mia_parity(IOP *iop) {
    if (!(iop->parityEnabled && iop->forceMIAParity)) return false;
    return iop_signal_data_flow_parity(iop, INTB_MIA);
}

/* The IB page's second look at H-Bus data: it "indirectly checks the H-BUS
 * parity when it checks parity for registers R1, R2, R3".  A processor
 * slice touches those registers, so a page holding a word that arrived
 * over a poisoned H-Bus reports here rather than at the transfer.  With
 * checking disabled the bad word is read anyway and nothing is said, so
 * the tag has to SURVIVE those reads: the bad parity is in the stored
 * word, not in the act of looking at it, and only a rewrite clears it. */
bool iop_check_local_store_parity(IOP *iop, int page) {
    if (!iop->parityEnabled) return false;
    if (page < 0 || page > PROC_SELFTEST) return false;
    if (iop->lsBadParity[page] == 0) return false;
    iop->lsBadParity[page] = 0;
    return iop_signal_data_flow_parity(iop, INTB_R123);
}

/* ICR channel reset (POO sect.10): "The channel reset operation issues a
 * reset to the IO.  The IO and CPU uses the signal to reset the IO/CPU
 * interface logic", which zeroes the IOP's interrupt registers -- hence
 * the programming note that this must not be issued until interrupt
 * register A has been read when an External 0 has occurred. */
void iop_channel_reset(IOP *iop) {
    for (int i = 0; i <= 4; i++)
        register_set32(registerfile_r(&iop->regInterrupts, i), 0);
}

void iop_exec_rm(IOP *iop) {
    iop_tick_watchdog(iop);
}

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
        /* regHalt is 1 = Processor Enabled (iop.h), so a CLEAR bit is the
         * halted processor that must not be stepped. */
        if (!iop_proc_get(&iop->regHalt, PROC_MSC)) return;
        if (!iop_proc_get(&iop->regBusyWait, PROC_MSC)) return;
    } else {
        int bceIdx = page;
        if (!iop_proc_get(&iop->regHalt, bceIdx)) return;
        if (!iop_proc_get(&iop->regBusyWait, bceIdx)) return;
    }

    /* A slice is where the three data flow parity checkers that watch a
     * running processor get their chance, in the register's priority
     * order.  Any of them halts every processor, so the slice ends. */
    if (iop_check_queue_parity(iop)) return;
    if (iop_check_dma_parity(iop)) return;
    if (iop_check_local_store_parity(iop, page)) return;

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

    /* One line per IOP instruction actually executed, to stderr, when
     * YAGPC_IOPTRACE is set.  The CPU-side --trace says nothing about
     * what the MSC and the BCEs are doing, and every remaining
     * divergence against the reference has been on that side; diffing
     * this against `gpc --iop-trace` is how they were found.  Off unless
     * the variable is set, so it costs a getenv per slice and nothing
     * else. */
    if (getenv("YAGPC_IOPTRACE")) {
        char who[8];
        if (page == 0) snprintf(who, sizeof who, "MSC");
        else snprintf(who, sizeof who, "BCE%d", page);
        fprintf(stderr, "IOPT %-6s %05x  %04x %04x  A=%08x BST=%08x\n",
                who, (unsigned)pc, (unsigned)hw1, (unsigned)hw2,
                (unsigned)iopls_getACC(&iop->ls), (unsigned)iopls_getBST(&iop->ls));
    }
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

/* One step of the IOP while the CPU is in the wait state: the DMA queue
 * and a processor slice.  Channel control and the RM watchdog are driven
 * separately from there (the watchdog on wall time, via
 * iop_tick_watchdog). */
void iop_exec_idle(IOP *iop) {
    iop_exec_dma_queue(iop);
    iop_exec_processors(iop);
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
    /* The displacement is relative to the UPDATED PC -- "the address of
     * the next sequential instruction", i.e. the halfword after this one,
     * which is also how model101tables.py describes what the assembler
     * emits.  Leaving out the +1 put every MSC short-format reference one
     * halfword early: GPCIPL's own MSC program loads its processor mask
     * with @L and got the word before it, so @SIO started nothing. */
    uint32_t pc = (register_get32(iopls_PC(&iop->ls)) + 1u) & 0x3ffff;
    uint32_t ea = (pc + disp) & 0x3ffff;
    if (indexed) {
        uint32_t x = register_get32(iopls_X(&iop->ls));
        ea = (ea + x) & 0x3ffff;
    }
    return ea;
}

/* One "repeat" tick, in microseconds.  The count field is expressed in
 * these, and the reference uses two 16.5us IOP cycles per tick. */
#define MSC_REPEAT_TICK_US 33.0

void iop_msc_repeat(IOP *iop, DInstr *v, bool met) {
    uint32_t pc = register_get32(iopls_PC(&iop->ls)) & 0x3ffff;
    double now = (iop->cpu != NULL) ? iop->cpu->elapsedTimeUs : 0.0;

    if (!iop->mscRepeatActive || iop->mscRepeatPC != pc) {
        /* First arrival at this instruction: arm the count.  "The lower
         * 8 bits, bits 8 through 15, and the I-bit are used to compute a
         * count" -- the I bit adds the index register on top of the
         * instruction's own eight, the way it extends a displacement. */
        uint32_t count = df_get(v, 'd');
        if (df_get(v, 'i')) count += register_get32(iopls_X(&iop->ls)) & 0x3ffff;
        iop->mscRepeatActive = true;
        iop->mscRepeatPC = pc;
        iop->mscRepeatUntilUs = now + (double)count * MSC_REPEAT_TICK_US;
    }

    if (met) {
        iop->mscRepeatActive = false;
        iop_incr_nia(iop, 2);
    } else if (now >= iop->mscRepeatUntilUs) {
        iop->mscRepeatActive = false;
        iop_incr_nia(iop, 1);
    }
    /* else: leave the PC where it is and run again next slice. */
}

/* "The resolution of this timeout count is 16.5 microseconds" -- the two
 * ranges the POO quotes agree with it, 2047 counts to 33.78 ms and 262143
 * to 4.325 s. */
#define MTO_TICK_US 16.5

bool iop_bce_delay(IOP *iop, uint32_t count) {
    BCE *bce = iop_cur_bce(iop);
    if (bce == NULL) return true;
    uint32_t pc = register_get32(iopls_PC(&iop->ls)) & 0x3ffff;
    double now = (iop->cpu != NULL) ? iop->cpu->elapsedTimeUs : 0.0;
    if (!bce->delayActive || bce->delayPC != pc) {
        bce->delayActive = true;
        bce->delayPC = pc;
        bce->delayUntilUs = now + (double)count * MTO_TICK_US;
    }
    if (now < bce->delayUntilUs) return false;
    bce->delayActive = false;
    return true;
}

uint32_t iop_bce_ea(IOP *iop, uint32_t disp, bool m) {
    if (disp & 0x400) disp |= 0xfffff800u;
    uint32_t ea = (register_get32(iopls_PC(&iop->ls)) + 1u + disp) & 0x3ffff;
    if (m) ea = (ea + 2u * (uint32_t)iop->curPE) & 0x3ffff;
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

/* A processor's operand accesses to CPU main storage.  Each is a DMA
 * transfer and so passes the address and data through the generator that
 * C140 poisons; a caught error kills the access. */
uint32_t iop_g_eaf(IOP *iop, uint32_t addr) {
    if (iop_check_dma_parity(iop)) return 0;
    return mcm_get32(&iop->cpu->mainStorage, addr);
}
uint32_t iop_g_eah(IOP *iop, uint32_t addr) {
    if (iop_check_dma_parity(iop)) return 0;
    return mcm_get16(&iop->cpu->mainStorage, addr);
}
/* An IOP write to CPU main storage is store-protected like any other:
 * a protected location raises the DMA store protect violation, External
 * 1 with code 0004.  These wrote past protection entirely, so that
 * interrupt could never occur -- and GPCIPL's self test deliberately
 * provokes it. */
static bool iop_write_main16(IOP *iop, uint32_t addr, uint32_t value) {
    if (mcm_set16(&iop->cpu->mainStorage, addr, value, true)) return true;
    cpu_signal_dma_protect_violation(iop->cpu);
    return false;
}
void iop_s_eaf(IOP *iop, uint32_t addr, uint32_t value) {
    if (iop_check_dma_parity(iop)) return;
    if (!iop_write_main16(iop, addr, (value >> 16) & 0xffff)) return;
    iop_write_main16(iop, addr + 1, value & 0xffff);
}
void iop_s_eah(IOP *iop, uint32_t addr, uint32_t value) {
    if (iop_check_dma_parity(iop)) return;
    iop_write_main16(iop, addr, value);
}

void iop_set_nia(IOP *iop, uint32_t x) { register_set32(iopls_PC(&iop->ls), x); }
void iop_incr_nia(IOP *iop, int incr) {
    iop_set_nia(iop, register_get32(iopls_PC(&iop->ls)) + (uint32_t)incr);
}

/* ---------------------------------------------------------------------
 * CPU <-> IOP link (cpu.h declares these as iop_recv_from_cpu/iop_get_cc_data)
 * ------------------------------------------------------------------- */

uint32_t iop_get_cc_data(IOP *iop) { return register_get32(&iop->regCCData); }

void iop_recv_from_cpu(IOP *iop, uint32_t cmd, uint32_t data) {
    /* Control word layout (Sec. 3.3 and Appendix I, "Program Controlled
     * Inputs and Outputs"), in IBM bit numbers:
     *
     *      bit 0      ID -- 0 for an input operation, 1 for an output
     *      bits 1-5   subsystem select
     *      bit 6      handshake
     *      bits 7-16  data select
     *      bits 17-31 ignored
     *
     * A field of width w starting at IBM bit b sits at C shift 32-b-w, so
     * the subsystem select is >> 26 and the data select >> 15.  Both were
     * one place low here, which silently mis-decoded every command that is
     * dispatched on the FIELDS rather than matched whole -- above all the
     * local store, subsystem 8.  GPCIPL loads each BCE's program counter
     * through it, one PC per command in a loop; with the wrong shift those
     * commands decoded to a subsystem that does not exist and fell out the
     * bottom of the switch, so no BCE ever received a PC and the MSC's own
     * @SIO then found nothing to start. */
    uint32_t isOutput = cmd >> 31;
    uint32_t devSelect = (cmd >> 26) & 0x1f;
    uint32_t dataSelect = (cmd >> 15) & 0x3ff;

    register_set32(&iop->regCCData, data);

    /* Was a bad-parity generator already armed when this transfer
     * arrived?  Sampled BEFORE the command runs so that the "force bad
     * parity" PCO which arms a generator is not itself caught by it: the
     * generator poisons what comes after it, not the command word that
     * set it. */
    bool hbusPoisoned = iop->parityEnabled && iop->forceHBusParity;
    bool queuePoisoned = iop->parityEnabled && iop->forceQueueParity;

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
        case 0xc1010000: /* ENABLE FLOW PARITY CHECK */
            /* "necessary to start the parity checking in the data flow
             * following any event that disables parity checking." */
            iop->parityEnabled = true;
            break;
        case 0xc0010000: /* DISABLE FLOW PARITY CHECK */
            iop->parityEnabled = false;
            iop_reset_parity_generators(iop);
            break;
        case 0xc1020000: /* FORCE IOP H-BUS BAD PARITY */
            /* "forces bad parity on all data coming to the IOP via the
             * H-Bus (PCO's or DMA's)." */
            iop->forceHBusParity = true;
            break;
        case 0xc1080000: /* FORCE QUEUE CONTROL BAD PARITY */
            /* "forces bad parity on the local store address and queue
             * control bits." */
            iop->forceQueueParity = true;
            break;
        case 0xc1400000: /* FORCE DMA ADDRESS/DATA BAD PARITY */
            /* One generator covers both: which of the two checkers sees
             * it depends on the bit parity of the address against the
             * data word.  Register B reports the pair under one code, so
             * the distinction is invisible to software. */
            iop->forceDMAParity = true;
            break;
        case 0xc1800000: /* FORCE OCTAL MIA BAD PARITY */
            /* "forces bad parity on all data transmitted from the IOP to
             * the OCTAL MIA pages.  The MIA page checks parity on all
             * incoming command and data words." */
            iop->forceMIAParity = true;
            break;
        case 0xc0200000: /* BAD PARITY DATA INPUT DISABLE */
            iop->dataForceBadParity = false;
            break;
        /* Only BCE 1-24 have MIAs, so the data word is masked to their
         * bits: the MSC's bit 0 and the seven unused low bits are not
         * writable here.  Applying the word unmasked, as these did, let
         * a blanket enable/disable reach processors that have no MIA. */
        case 0x84040000: /* MIA TRANSMITTER DISABLE */
            register_set32(&iop->regXmitEna,
                           register_get32(&iop->regXmitEna) & ~(data & MIA_WRITE_MASK));
            break;
        case 0x85040000: /* MIA TRANSMITTER ENABLE */
            register_set32(&iop->regXmitEna,
                           register_get32(&iop->regXmitEna) | (data & MIA_WRITE_MASK));
            break;
        case 0x84080000: /* MIA RECEIVER DISABLE */
            register_set32(&iop->regRecvEna,
                           register_get32(&iop->regRecvEna) & ~(data & MIA_WRITE_MASK));
            break;
        case 0x85080000: /* MIA RECEIVER ENABLE */
            register_set32(&iop->regRecvEna,
                           register_get32(&iop->regRecvEna) | (data & MIA_WRITE_MASK));
            break;
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
            /* regHalt holds Status Register 5 the way the architecture
             * defines it -- 1 = Processor Enabled -- so halting CLEARS
             * the named processors' bits.  See regHalt in iop.h. */
            uint32_t r1 = register_get32(&iop->regHalt);
            register_set32(&iop->regHalt, r1 & ~data);
            break;
        }
        case 0x87200000: { /* CONFIGURE PROCESSORS ENABLE */
            uint32_t r1 = register_get32(&iop->regHalt);
            register_set32(&iop->regHalt, r1 | data);
            break;
        }
        case 0x84400000: { /* MASTER RESET */
            /* PROC_ALL, the MSC plus BCE 1-24, is 0xffffff80 -- IBM bit
             * numbering, so processor n is bit n counted from the MS end.
             * The 0xfffff800 that used to be here is bits 0-20, four
             * processors short.
             *
             * STAT1 (GO/NO-GO) resets to GO and GO is 1, so every
             * processor bit is set.  STAT5 (the Halt Register) resets to
             * HALT and enabled is 1, so "all halted" is every bit CLEAR
             * -- zero, not a mask. */
            register_set32(&iop->regProgExcept, PROC_ALL);
            register_set32(&iop->regBusyWait, 0x00000000u);
            register_set32(&iop->regHalt, 0x00000000u);
            register_set32(&iop->regXmitEna, 0x00000000u);
            register_set32(&iop->regRecvEna, 0x00000000u);
            register_set32(&iop->regDiscreteOut, 0x00000000u);
            /* MASTER RESET's INTERRUPT effects, which were missing
             * entirely.  The instruction set's own reset table gives them
             * bit by bit:
             *
             *      -C/M IDLE                 SET
             *      -IOP FAIL LTCH            NO CHANGE
             *      -TIME OUT LTCH            NO CHANGE
             *      -ROS PAR                  RESET
             *      -IOP FAULT                RESET
             *      -ALL OTHER INTERRUPTS     RESET
             *
             * C/M IDLE is the Control/Monitor logic reporting itself
             * "in the Idle mode and available for further operations",
             * and it is a Group 1 source, so setting it raises EX0 --
             * PSA 0078/007C, "External 0 (C/M Idle, IOP Reg. A)".  This
             * is what GPCIPL's self-test waits for after issuing its own
             * MASTER RESET: the handler reads interrupt register A and
             * expects to find C/M IDLE identifying the source.
             *
             * Registers B-E are "all other interrupts".  In register A
             * only the two latches survive; ROS PAR and IOP FAULT are
             * reset by falling outside the kept mask. */
            register_set32(registerfile_r(&iop->regInterrupts, 1), 0x0u);
            register_set32(registerfile_r(&iop->regInterrupts, 2), 0x0u);
            register_set32(registerfile_r(&iop->regInterrupts, 3), 0x0u);
            register_set32(registerfile_r(&iop->regInterrupts, 4), 0x0u);
            uint32_t kept = register_get32(registerfile_r(&iop->regInterrupts, 0))
                            & (INTA_GO_NOGO | INTA_IOP_FAIL);
            register_set32(registerfile_r(&iop->regInterrupts, 0),
                           kept | INTA_CM_IDLE);
            if (iop->cpu != NULL) {
                iop->cpu->intPending.iopGrp1 = true;  /* EX0 */
            }
            /* And the table's remaining line, "WATCHDOG TIMER RST=ZERO
             * COUNTER AND INHIBIT COUNTING". */
            iop->wdCount = 0;
            iop->wdRunning = false;
            iop->wdAccumUs = 0.0;
            break;
        }
        case 0x88040000: /* LOAD GO/NO-GO TIMER */
            iop_load_watchdog(iop, data);
            break;
        case 0x88048000: /* LOAD GO/NO-GO TIMER TEST */
            iop_load_watchdog_test(iop, data);
            break;
        case 0x88080000: { /* CONFIGURE TERMINATION CONTROL LATCHES */
            uint32_t timerLatch = (data >> 1) & 0x1u;
            uint32_t voterLatch = data & 0x1u;
            uint32_t r1 = register_get32(&iop->regRMStatus);
            /* They land in RM status IBM bits 18 and 17 -- 0x2000 and
             * 0x4000.  The timer latch used to go to bit 19 (0x1000)
             * behind a mask that cleared 19 and 17 but left 18 alone. */
            r1 = (r1 & ~0x6000u) | (timerLatch << 13) | (voterLatch << 14);
            register_set32(&iop->regRMStatus, r1);
            break;
        }
        case 0x88100000: /* LOAD TEST REGISTER */
            iop_load_voter_test(iop, data);
            break;
        case 0x88180000: /* TEST INTERRUPTS */
            /* "The TEST command word forces interrupt Registers A, B, D
             * and E to set all interrupts as follows:
             *      REG A  BITS 0-5  (FC00 0000)
             *      REG B  BITS 4&5  (0C00 0000)
             *      REG D  BIT 0     (8000 0000)
             *      REG E  BIT 0     (8000 0000)"
             * Not all-ones, which is what this used to write. */
            iop->intForceTest = true;
            register_set32(registerfile_r(&iop->regInterrupts, 0), 0xfc000000u);
            register_set32(registerfile_r(&iop->regInterrupts, 1), 0x0c000000u);
            register_set32(registerfile_r(&iop->regInterrupts, 3), 0x80000000u);
            register_set32(registerfile_r(&iop->regInterrupts, 4), 0x80000000u);
            /* Forcing the registers is only half of it: the point of the
             * command is "self-testing of the interrupt detection
             * circuitry", so the four levels those registers feed have to
             * actually be raised to the CPU.  Setting the registers alone
             * left GPCIPL's interrupt self-test with nothing to take once
             * it unmasked. */
            if (iop->cpu != NULL) {
                iop->cpu->intPending.iopGrp1 = true;  /* External 0, REG A */
                iop->cpu->intPending.iopGrp2 = true;  /* External 1, REG B */
                iop->cpu->intPending.ext3 = true;     /* External 3, REG D */
                iop->cpu->intPending.ext4 = true;     /* External 4, REG E */
            }
            break;
        case 0x88140000: /* ENABLE INTERRUPTS */
            iop->intForceTest = false;
            break;
        case 0x92000000: /* RESET STATUS1(GO/NO-GO) */
            /* "These PCO's provide the capability (data Word is used as
             * Mask) to reset Status Register 1 to the normal or GO
             * indicator ... 0 No Change, 1 Reset Status".  STAT1 carries
             * 1 = GO, so resetting a processor to GO SETS its bit.  This
             * was a no-op, which left the software's own GO/NO-GO resets
             * with no effect at all. */
            register_set32(&iop->regProgExcept,
                           register_get32(&iop->regProgExcept) | data);
            break;
        case 0x92040000: { /* LOAD MSC BUSY */
            /* The MSC's own bit in STAT4 -- the TOP bit of the word,
             * not the bottom one this used to set. */
            iop_proc_set(&iop->regBusyWait, PROC_MSC, 1);
            /* And the copy of it the MSC reads back with @LMS: bit 17 of
             * the 18-bit MSC status register, "the Busy/Wait bit for the
             * MSC".  Software checks the copy against X'00000001'
             * exactly, so nothing else in the register may be disturbed.
             * Reached BY REGION, not through iopls_MST(): that accessor
             * reads whichever page the IOP happens to be slicing, which
             * for a CPU-side PCO is any of the 26.  Without this the
             * MSC's own @LMS read back zero and it stored a zero status
             * where the flight software expects 1. */
            Register *mst = iopls_at(&iop->ls, PROC_MSC, 2, 7);
            if (mst) register_set32(mst, register_get32(mst) | 1u);
            break;
        }
        case 0xc1008000: /* INHIBIT COMPLETION OF A DMA CYCLE */
            return;      /* no-op */
        case 0x04000000: /* READ MIA TRANSMITTER STATUS */
            register_set32(&iop->regCCData, mia_read_back(&iop->regXmitEna));
            break;
        case 0x04040000: /* READ MIA RECEIVER STATUS (04040000, not 40400000) */
            register_set32(&iop->regCCData, mia_read_back(&iop->regRecvEna));
            break;
        case 0x04080000: /* READ DISCRETE OUTPUT STATUS */
            register_set32(&iop->regCCData, register_get32(&iop->regDiscreteOut));
            break;
        case 0x040c0000: /* READ PROCESSOR HALT STATUS */
            register_set32(&iop->regCCData, register_get32(&iop->regHalt));
            break;
        case 0x08000000: /* READ INTERRUPT REGISTER A */
            register_set32(&iop->regCCData, register_get32(registerfile_r(&iop->regInterrupts, 0)));
            if (!iop->intForceTest) register_set32(registerfile_r(&iop->regInterrupts, 0), 0x0);
            break;
        case 0x08040000: /* READ INTERRUPT REGISTER B */
            register_set32(&iop->regCCData, register_get32(registerfile_r(&iop->regInterrupts, 1)));
            if (!iop->intForceTest) register_set32(registerfile_r(&iop->regInterrupts, 1), 0x0);
            break;
        case 0x08080000: /* READ INTERRUPT REGISTER C */
            register_set32(&iop->regCCData, register_get32(registerfile_r(&iop->regInterrupts, 2)));
            if (!iop->intForceTest) register_set32(registerfile_r(&iop->regInterrupts, 2), 0x0);
            break;
        case 0x080c0000: /* READ INTERRUPT REGISTER D */
            register_set32(&iop->regCCData, register_get32(registerfile_r(&iop->regInterrupts, 3)));
            if (!iop->intForceTest) register_set32(registerfile_r(&iop->regInterrupts, 3), 0x0);
            break;
        case 0x08100000: /* READ INTERRUPT REGISTER E */
            register_set32(&iop->regCCData, register_get32(registerfile_r(&iop->regInterrupts, 4)));
            if (!iop->intForceTest) register_set32(registerfile_r(&iop->regInterrupts, 4), 0x0);
            break;
        case 0x08140000: /* READ RM STATUS REGISTERS */
            register_set32(&iop->regCCData, iop_rm_status(iop));
            if (!iop->intForceTest) register_set32(registerfile_r(&iop->regInterrupts, 5), 0x0);
            break;
        case 0x08180000: /* READ DISCRETE INPUT A (1-32) */
            register_set32(&iop->regCCData, register_get32(&iop->regDiscreteInA));
            break;
        case 0x081c0000: /* READ DISCRETE INPUTS B (33-40) */
            /* Register B, not A -- this read the A register, so discrete
             * inputs 33-40 came back as inputs 1-32. */
            register_set32(&iop->regCCData, register_get32(&iop->regDiscreteInB));
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

        /* The REGION names which processor's page this addresses -- the
         * MSC, BCE 1-24 or the self-test processor.  It used to be
         * discarded, with the access going to iopls_ls() and so to
         * whichever page the round-robin scheduler happened to have
         * selected at that instant; GPCIPL's own setup writes each
         * processor's program counter through here, so those landed in
         * arbitrary pages and no processor ever got its PC.
         *
         * The direction was inverted too.  Bit 0 of the control word is
         * "coded as 0" for an input and 1 for an output, and an OUTPUT is
         * the CPU sending a word to the IOP -- so isOutput WRITES local
         * store and the input case is the one that reads it back.
         *
         * A local store word is 18 bits, held in the low end of the
         * 32-bit data word; a read returns it with the unused high bits
         * set, as the hardware presents them. */
        Register *r = iopls_at(&iop->ls, (int)region, (int)bank, (int)word);
        if (r != NULL) {
            if (isOutput) {
                register_set32(r, data & 0x3ffffu);
                /* The word is in local store now, but with the parity the
                 * poisoned H-Bus generated for it.  Tag it so the IB page
                 * can catch it when the owning processor next uses the
                 * register -- a clean write to the same register clears
                 * the tag, because the good parity overwrites the bad. */
                uint32_t bit = 1u << (bank * 4 + word);
                if (region <= PROC_SELFTEST) {
                    if (hbusPoisoned) iop->lsBadParity[region] |= bit;
                    else              iop->lsBadParity[region] &= ~bit;
                }
            } else {
                register_set32(&iop->regCCData,
                               0xfffc0000u | (register_get32(r) & 0x3ffffu));
            }
        }
        /* The local store address lines and queue control bits carried
         * this transfer, so the C108 generator poisons it. */
        if (queuePoisoned && iop_check_queue_parity(iop)) return;
    }

    /* The device-out data bus checker sees every H-Bus transfer as it
     * arrives -- "the SI page checks the data for correct parity directly
     * off the 'DEV OUT DATA BUS'" -- so a poisoned PCI or PCO reports here
     * and now, whatever it was addressed to. */
    if (hbusPoisoned) iop_signal_data_flow_parity(iop, INTB_DEV_OUT);
}
