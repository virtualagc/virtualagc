#include "iop.h"
#include "busword.h"
#include <stdio.h>
#include <stdlib.h>

#include <stdlib.h>
#include <string.h>

#include "cpu.h"
#include "discretes.h"

#include "envcache.h"
#include "vehicle.h"
/* YAGPC_MSCRING helpers, defined beside iop_write_main16(). */
static void msc_ring_record(IOP *iop, uint32_t pc, uint32_t hw1, uint32_t hw2);
static void msc_ring_dump_once(IOP *iop, const char *why);

static void iop_watch_store(IOP *iop, uint32_t addr, uint32_t value,
                            const char *kind);

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
/* One word time on the 1 MHz serial bus: 28 bits plus a >=5 us
 * interword gap.  nsts-sim-gpc BUS_WORD_NS = 33000. */
#define MIA_BUS_WORD_US 33.0

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
 * The switch and vehicle bits hold a fixed default standing in for the crew
 * panel and the vehicle: GPC 1, IPL source MM1, MM1 attached, display CRT 1.
 * Leaving them zero -- which is what this port did -- is not a neutral
 * choice: it reports GPC ID 0, which is not a legal ID, so GPCIPL cannot
 * identify itself.  The two MASS MEMORY READY bits are NOT fixed; they are
 * computed per read by iop_discrete_in_a() below. */
#define DISCRETE_IN_A_DEFAULT 0x0a000000u  /* bit 4 MM1 IPL source, bit 6 MM1 ready */
#define DISCRETE_IN_B_DEFAULT 0x21000000u  /* bits 0-2 GPC 1, bits 6-7 CRT 1 */

/* The two MM READY bits of discrete input A, in IBM numbering from the MS
 * end of the 32-bit register, and the bus controllers they report on.
 * FCMBOOT's own arithmetic confirms both: it holds the bus mask
 * FCMBBS18 EQU X'2000' for MM1 and shifts it left 12 before testing, giving
 * 0x02000000 -- bit 6 -- and FCMBBS19 EQU X'1000' likewise gives bit 7.  Its
 * "DEFAULT TO BUS 18 (MMU1)" fixes the channel numbers. */
#define DISCRETE_A_MM1_READY 0x02000000u   /* IBM bit 6 */
#define DISCRETE_A_MM2_READY 0x01000000u   /* IBM bit 7 */
#define MM1_BCE 18
#define MM2_BCE 19

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

/* Is this bus controller actually executing?  Same test
 * iop_any_processor_running() makes for the machine as a whole: a processor
 * runs when its bit is set in BOTH the halt register (the enable) and the
 * busy/wait register. */
static bool iop_channel_running(const IOP *iop, int p) {
    uint32_t m = iop_proc_bit(p);
    return (register_get32(&iop->regHalt) & register_get32(&iop->regBusyWait) & m) != 0;
}

/* One MM READY bit.  The STORED bit says whether that mass memory is there
 * at all -- the default attaches MM1 and not MM2 -- and a mass memory that
 * is not attached is never ready.  An attached one is ready exactly while
 * its channel is idle. */
static uint32_t iop_mm_ready(const IOP *iop, uint32_t stored, uint32_t mask, int bce) {
    if (!(stored & mask)) return 0u;
    return iop_channel_running(iop, bce) ? 0u : mask;
}

/* Discrete input A as READ DISCRETE INPUT A reports it: the stored switch
 * and vehicle bits, with the two MASS MEMORY READY bits computed rather
 * than stored.
 *
 * Why computed.  FCMBOOT -- the IPL bootstrap loader the IOP microcode
 * fetches from the MMU -- does not sample this bit once, it HANDSHAKES on
 * it.  Having picked its mass memory from bits 4/5, it waits for ready,
 * starts the transfer, and then runs two more loops over the same mask
 * (FCMBOOT.asm, "LOOP UNTIL THE MASS MEMORY IS BUSY" followed by "LOOP
 * UNTIL POSITION OR READ IS COMPLETE"):
 *
 *     DO UNTIL=(Z)     PC read; NR R4,R3     -- wait for READY to CLEAR
 *     DO UNTIL=(NZ)    PC read; NR R4,R3     -- wait for it to SET again
 *
 * A constant ready bit, which is what this port had, satisfies the first
 * wait and then hangs forever in the second: the mass memory never appears
 * to go busy, so the transfer never appears to start.
 *
 * Deriving the bit here, from state this emulator owns, rather than from
 * anything the mass memory itself reports, is deliberate.  The MMU is a
 * separate process developed independently of this one, and no part of this
 * handshake should depend on its internals, its wire protocol or its
 * timing; all that is required of it is that it answer the bus. */
/* Let whatever is actually on the discrete bus have the last word.
 *
 * A bit somebody is publishing overrides what we hold or derive for it; a
 * bit nobody is publishing keeps the local value.  So a real mass memory,
 * once attached, becomes the thing that says whether it is ready, while a
 * run with nothing attached still works off the derivation above.
 *
 * The poll happens here, on the read, rather than on a timer: this is
 * called from the READ DISCRETE INPUT PCIs, which is exactly when the
 * value has to be current, and the flight software polls those in tight
 * loops while it waits.  Draining a non-blocking socket is cheap. */
static uint32_t iop_discrete_overlay(IOP *iop, int reg, uint32_t local) {
    Discretes *d = iop->discretes;
    if (!discretes_enabled(d)) return local;
    discretes_poll(d);
    /* Cached on the bus generation: this runs on every READ DISCRETE INPUT
     * PCI and the flight software polls those in tight loops. */
    int i = (reg == DISCRETES_REG_B) ? 1 : 0;
    unsigned gen = discretes_generation(d);
    if (gen != iop->discOverlayGen[i]) {
        iop->discOverlayDriven[i] = discretes_driven_mask(d, reg);
        iop->discOverlayValue[i] = discretes_value(d, reg);
        iop->discOverlayGen[i] = gen;
    }
    uint32_t effective = (local & ~iop->discOverlayDriven[i]) |
                         (iop->discOverlayValue[i] & iop->discOverlayDriven[i]);
    /* What a REQUEST for this register is answered with.  Only here can the
     * locally derived bits and the published ones be combined. */
    discretes_set_canonical(d, reg, effective);
    return effective;
}

void iop_set_discrete_in(IOP *iop, int reg, uint32_t value) {
    register_set32(reg == DISCRETES_REG_B ? &iop->regDiscreteInB
                                          : &iop->regDiscreteInA, value);
}

/* The stored value, before the computed READY bits and the crew panel's
 * overlay -- so a caller can add to it without having to know either. */
uint32_t iop_discrete_in_a_stored(const IOP *iop) {
    return register_get32(&iop->regDiscreteInA);
}

uint32_t iop_discrete_in_a(IOP *iop) {
    uint32_t stored = register_get32(&iop->regDiscreteInA);
    uint32_t v = stored & ~(DISCRETE_A_MM1_READY | DISCRETE_A_MM2_READY);
    v |= iop_mm_ready(iop, stored, DISCRETE_A_MM1_READY, MM1_BCE);
    v |= iop_mm_ready(iop, stored, DISCRETE_A_MM2_READY, MM2_BCE);
    uint32_t out = iop_discrete_overlay(iop, DISCRETES_REG_A, v);
    /* YAGPC_DISCTRACE: report every change of discrete input A as the flight
     * software actually reads it -- stored, computed, and after the crew
     * panel's overlay -- so "the MMU published READY but CZ2BDIA never got
     * it" can be attributed to a stage instead of guessed at. */
    if (yagpc_getenv("YAGPC_DISCTRACE")) {
        static uint32_t last = 0xffffffffu;
        if (out != last) {
            fprintf(stderr, "DISCA stored=%08x computed=%08x out=%08x "
                            "(MM1RDY stored=%d computed=%d out=%d) t=%.2f\n",
                    (unsigned)stored, (unsigned)v, (unsigned)out,
                    !!(stored & DISCRETE_A_MM1_READY),
                    !!(v & DISCRETE_A_MM1_READY),
                    !!(out & DISCRETE_A_MM1_READY),
                    (iop->cpu != NULL) ? iop->cpu->elapsedTimeUs / 1e6 : 0.0);
            last = out;
        }
    }
    return out;
}

uint32_t iop_discrete_in_b(IOP *iop) {
    return iop_discrete_overlay(iop, DISCRETES_REG_B,
                                register_get32(&iop->regDiscreteInB));
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

/* YAGPC_IOP_UPSTREAM=1 enables the COORDINATED SET of IOP corrections from
 * nsts-sim-gpc commit 818df88, "addressing, timer and bus-rate corrections
 * in the CPU and the IOP":
 *
 *   - the receive time-out floor is zero, so the time out FCMINIOP loaded
 *     governs (33 us on most buses, 49.5 us on bus 24, 5 ms on the DK
 *     buses 6-9, 1.959936 s on mass memory 18-19);
 *   - a MIA presents one received word per 33 us bus word time;
 *   - @RAW keeps accumulator bit 0 (POO II-80).
 *
 * THEY GO TOGETHER.  Bit 0 alone was tried here and was catastrophic (run
 * x2: no transition, the IOQE sentinel fault at t=230 instead of ~398, and
 * the bus-6 hold median going from 0.85 ms to 4263 ms), which is what
 * gpc-causes.py entry 2 records.  Upstream ships it beside the pacing and
 * the zero floor, so testing one item of an interdependent set and
 * concluding the item is wrong is the error to avoid here.
 *
 * OFF by default.  Any test of it must run past 250 s: x1 looked perfectly
 * healthy for 190 s and the damage did not start until about 230. */
static int iop_upstream(void) {
    static int inited = 0, on = 0;
    if (!inited) { inited = 1; on = yagpc_getenv("YAGPC_IOP_UPSTREAM") != NULL; }
    return on;
}

/* The receive pacing on its own, so the set can be bisected: the whole set
 * regressed exactly as the @RAW mask alone did (run u1: IPL healthy, then
 * the IOQE sentinel fault at t=231.19 against x2's 230.9, and a bus-6 hold
 * median of 2166 ms against a 0.85 ms baseline), which says the mask is
 * still the item that breaks and the pacing did not rescue it.  The zero
 * timeout floor needs no flag of its own -- YAGPC_RECV_FLOOR_US=0 does it. */
static int iop_mia_pace(void) {
    static int inited = 0, on = 0;
    if (!inited) {
        inited = 1;
        on = (yagpc_getenv("YAGPC_MIA_PACE") != NULL ||
              yagpc_getenv("YAGPC_IOP_UPSTREAM") != NULL);
    }
    return on;
}

bool mia_data_available(struct IOP *iop, MIA *m) {
    if (m->latchValid) return true;
    if (!iop->servicer) return false;
    /* Paced: a word is not presentable before its bus word time is up. */
    if (iop_mia_pace() && iop_now_us(iop) < m->rxNextUs) return false;
    GpcServiceInput input = {.busID = m->bceNum, .address = 0};
    GpcServiceOutput output = {0};
    iop->servicer(iop->servicerCtx, GPC_SVC_RECV_POLL, &input, &output);
    return output.out.poll.available;
}

uint32_t mia_get_data(struct IOP *iop, MIA *m) {
    if (iop_mia_pace()) m->rxNextUs = iop_now_us(iop) + MIA_BUS_WORD_US;
    if (iop->servicer) {
        GpcServiceInput input = {.busID = m->bceNum, .address = 0};
        GpcServiceOutput output = {0};
        iop->servicer(iop->servicerCtx, GPC_SVC_RECV_WORD, &input, &output);
        if (output.out.recv.available) {
            /* A word actually on the bus OVERWRITES the adapter's buffer.
             * The latch is only what is left there when nothing newer has
             * come along; it does not queue ahead of live traffic.
             *
             * Handing the latch over first -- what this did -- was right
             * for the case it was written for and wrong everywhere after
             * it.  FCMBOOT's last load block ends in a delay like all the
             * others, but nothing follows it to spend the latched word on,
             * so it sat there until GPCIPL's first BITE STATUS took it as
             * one of the two status words and left a real one behind.
             * From then on every reply that unit sent was read one place
             * late: GPCIPL stored the POSITION reply (0x14A0) where status
             * belonged, and X'F800FFFF' -- its own MMU error mask -- made
             * that an error, so BSL1 reported ERROR 118 "MMU ERROR" and
             * reset instead of loading anything. */
            m->latchValid = false;
            m->lastFromLatch = false;
            /* The sync mark belongs to the adapter, not to the data. */
            m->lastCmdSync = (output.out.recv.word & YAGPC_BUSWORD_CMD_SYNC) != 0u;
            return output.out.recv.word & ~YAGPC_BUSWORD_CMD_SYNC;
        }
    }
    m->lastCmdSync = false;
    if (m->latchValid) {
        m->latchValid = false;
        m->lastFromLatch = true;
        m->lastCmdSync = m->latchCmdSync;
        return m->latch;
    }
    m->lastFromLatch = false;
    return 0;
}

/* YAGPC_XMITTRACE=<bus>: the ground truth for "the peer says the transfer
 * was short".  A command declares a word count; everything the MIA then
 * puts on that bus before the NEXT command is what the peer actually
 * gets.  Counting here, rather than at the instruction that queued the
 * DMA, is what distinguishes "the bus program asked for too few" from
 * "the words were queued and lost". */
static int xmit_trace_bus(void) {
    static int inited = 0, bus = -1;
    if (!inited) {
        inited = 1;
        const char *e = yagpc_getenv("YAGPC_XMITTRACE");
        if (e != NULL) bus = (int)strtol(e, NULL, 10);
    }
    return bus;
}
static long xmitWords[32];
static long dmaQueuedRead[32];

static void iop_bce_wire_hold(IOP *iop, BCE *bce, unsigned words);  /* see below */

void mia_xmit_word(struct IOP *iop, MIA *m, uint32_t halfword) {
    if (m->bceNum == xmit_trace_bus() && m->bceNum >= 0 && m->bceNum < 32)
        iop->xmitWords[m->bceNum]++;
    if (!iop->servicer) return;
    GpcServiceInput input = {.busID = m->bceNum, .address = 0, .in.word = halfword};
    GpcServiceOutput output = {0};
    iop->servicer(iop->servicerCtx, GPC_SVC_XMIT_WORD, &input, &output);
}

void mia_xmit_cmd(struct IOP *iop, MIA *m, uint32_t cmd24) {
    if (m->bceNum == xmit_trace_bus() && m->bceNum >= 0 && m->bceNum < 32) {
        unsigned iua = (cmd24 >> 19) & 0x1fu;
        unsigned func = (cmd24 >> 9) & 0x3ffu;
        unsigned cnt = cmd24 & 0x1ffu;
        fprintf(stderr, "XMIT bce=%d  [prev: queued %ld, sent %ld]  "
                "cmd iua=%u func=%03x count=%u  t=%.1f\n",
                m->bceNum, dmaQueuedRead[m->bceNum], xmitWords[m->bceNum],
                iua, func, cnt, iop->cpu ? iop->cpu->elapsedTimeUs : 0.0);
        xmitWords[m->bceNum] = 0;
        dmaQueuedRead[m->bceNum] = 0;
    }
    if (m->bceNum >= 1 && m->bceNum <= 24)
        iop_bce_wire_hold(iop, &iop->bce[m->bceNum - 1], 1u);
    /* THE ECHO OVERWRITES THE ADAPTER'S BUFFER.  A command this MIA puts on
     * the bus comes straight back into its own receiver -- the copy BCE
     * Principles of Operation 3.4.4 says a Command Mode receive may discard
     * -- and the buffer holds one word, which 'stays there until either the
     * BCE removes it or the MIA overwrites it'.  No device model echoes a
     * command to the computer that sent it, so a word latched by an earlier
     * delay outlived the command: a mass-memory commander's '#DLYI 1814'
     * latched the 00c6c6 tail of the previous stream, '#CMD FIOCWE' went
     * out, and '#RDL' took 00c6c6 as the first word of the overlay block --
     * one place late throughout, a load-block checksum failure (FIOMGSNC
     * 0080) on the COMMANDER, and ARCGPC dropped it from the redundant set
     * (ledger #139).  The latched echo is marked command sync so the receive
     * discards it; a word from the bus still overwrites it (mia_get_data). */
    m->latch = cmd24 & 0xffffffu;
    m->latchValid = true;
    m->latchCmdSync = true;
    if (!iop->servicer) return;
    /* IUA occupies bits 19-23 of the 24-bit command word (see
     * exec_CMDI/exec_CMD in iop_bce_instr.c, which build it as
     * (IUA << 19) | rest). */
    GpcServiceInput input = {.busID = m->bceNum, .address = (int)((cmd24 >> 19) & 0x1fu), .in.word = cmd24};
    GpcServiceOutput output = {0};
    iop->servicer(iop->servicerCtx, GPC_SVC_XMIT_CMD, &input, &output);
}

void bce_init(BCE *b, int bceNum) {
    b->wireHoldUntilUs = 0.0;
    b->delayActive = false;
    b->delayPC = 0;
    b->delayUntilUs = 0.0;
    b->recvActive = false;
    b->recvPC = 0;
    b->recvAddr = 0;
    b->recvLeft = 0;
    b->recvSinceUs = 0.0;
    b->recvGotAny = false;
    b->bceNum = bceNum;
    mia_init(&b->mia, bceNum);
}

void msc_init(MSC *m) {
    register_init(&m->regFailDisc);
    m->failDiscSeen = 0u;
    register_init(&m->regIntProg);
}

/* ---------------------------------------------------------------------
 * DMA queue — growable FIFO (mirrors Array#push/#shift)
 * ------------------------------------------------------------------- */

/* Drop every queued request belonging to one BCE -- an error
 * termination takes its in-flight DMA with it. */
/* YAGPC_DMATRACE: a transmit that is queued as DMA and then discarded is
 * invisible everywhere else -- the bus program has already advanced past
 * its #MOUT, the transport never sees the words, and the peer reports
 * only "transfer abandoned N short".  This names the discard. */
static void dmaq_drop_for_bce(DMAQueue *q, BCE *bce) {
    if (yagpc_getenv("YAGPC_DMATRACE")) {
        int n = 0;
        for (int i = 0; i < q->count; i++)
            if (q->items[(q->head + i) % q->cap].bce == bce) n++;
        if (n)
            fprintf(stderr, "DMADROP bce=%d dropping %d of %d queued\n",
                    bce ? bce->bceNum : -1, n, q->count);
    }
    int kept = 0;
    for (int i = 0; i < q->count; i++) {
        DMARequest *r = &q->items[(q->head + i) % q->cap];
        if (r->bce == bce) continue;
        q->items[(q->head + kept) % q->cap] = *r;
        kept++;
    }
    q->count = kept;
}

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

#define RECV_TIMEOUT_FLOOR_US 2000.0    /* 2 ms; see iop_recv_timeout_us */

void iop_init(IOP *iop, struct CPU *cpu) {
    /* NOT what the zeroing leaves: generation 0 is a real value, so a memo
     * initialised to it would serve a stale answer on the first read, and the
     * receive floor has a non-zero default. */
    for (int i = 0; i < 2; i++) {
        iop->discOverlayGen[i] = ~0u;
        iop->discOverlayDriven[i] = 0u;
        iop->discOverlayValue[i] = 0u;
    }
    iop->recvTimeoutFloorUs = RECV_TIMEOUT_FLOOR_US;
    iop->recvFloorFromEnv = 0;
    /* NO CHANNEL UNTIL ONE IS INSTALLED.  The IOP used to reach a process-wide
     * discrete bus through file statics, so nothing here had to name it; the
     * per-machine channel is a pointer, and a caller that declares its IOP on
     * the stack (the unit tests do) would otherwise dereference whatever was
     * there.  The per-bus counters below are the same story. */
    iop->discretes = NULL;
    for (int i = 0; i < 32; i++) {
        iop->xmitWords[i] = 0;
        iop->dmaQueuedRead[i] = 0;
        iop->clearWatch[i] = 0;
    }
    iop->cpu = cpu;
    iop->peerWait = NULL;
    iop->peerWaitCtx = NULL;

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
    for (int i = 0; i < 32; i++) iop->busFreeUs[i] = 0.0;
    iop->mscRepeatActive = false;
    iop->mscRepeatPC = 0;
    iop->mscRepeatUntilUs = 0.0;

    iop->servicer = NULL;
    iop->servicerCtx = NULL;
}

/* THE I/O SIDE OF THE SYSTEM RESET.  POO 2.5.3: power-on, IPL and the
 * system reset key "each produce a system reset sequence which applies to
 * the computer, I/O channels, and peripherals" -- and an IPL of a machine
 * that had been RUNNING left the IOP exactly as PASS had it: the MSC mid-
 * program, BCEs mid-transfer with receives armed and MIA words latched, DMA
 * queued, interrupt and status registers set.  The HALT switch only stops
 * the clock, so all of it resumed the moment STBY released the machine,
 * over memory the IPL had just overwritten and ahead of FCMBOOT, which does
 * not master-reset the IOP until after its two-second settling delay.
 *
 * The manual does not itemise the I/O side, so this puts the IOP back in
 * the state iop_init() gives it at power-up -- the state every first boot
 * starts from and succeeds from.  What is NOT the IOP's to reset stays:
 * the peripheral servicer and peer hook (the wiring to the outside), the
 * discrete INPUTS (driven by the crew panel, not by the GPC), the bus
 * timing and the CPU link. */
void iop_system_reset(IOP *iop) {
    msc_init(&iop->msc);
    for (int i = 0; i < 24; i++) {
        bce_init(&iop->bce[i], i + 1);
        iop->bce[i].mia.latch = 0;
        iop->bce[i].mia.latchValid = false;
        iop->bce[i].mia.rxNextUs = 0.0;
    }
    iop->curPE = 0;
    iop->dmaForceBadParity = false;
    iop->dataForceBadParity = false;
    register_init(&iop->regXmitEna);
    register_init(&iop->regRecvEna);
    register_init(&iop->regProgExcept);
    register_init(&iop->regBusyWait);
    register_init(&iop->regHalt);
    register_init(&iop->regIndicator);
    register_init(&iop->regDiscreteOut);
    register_init(&iop->regRMStatus);
    iop->wdCount = 0;
    iop->wdRunning = false;
    iop->wdTimeout = false;
    iop->wdAccumUs = 0.0;
    iop->rmVoterInhibit = false;
    iop->rmTestInputs = 0;
    iop->rmVoterFail = false;
    iop->parityEnabled = false;      /* "Power On, System Reset" disable it */
    iop->forceHBusParity = false;
    iop->forceQueueParity = false;
    iop->forceDMAParity = false;
    iop->forceMIAParity = false;
    for (int i = 0; i <= PROC_SELFTEST; i++) iop->lsBadParity[i] = 0;
    for (int i = 0; i < iop->regInterrupts.count; i++)
        register_init(&iop->regInterrupts.regs[i]);
    iop->intForceTest = false;
    register_init(&iop->regCCData);
    for (int pg = 0; pg <= PROC_SELFTEST; pg++) {
        RegisterFile *rf = &iop->ls.storePage[pg];
        for (int i = 0; i < rf->count; i++) register_init(&rf->regs[i]);
        for (int i = 0; i < 8; i++) rf->dse[i] = 0;
    }
    iop->ls.slice = 0;
    iop->ls.curBCE = 0;
    iop->ls.curPage = 0;
    iop->dmaQueue.head = 0;
    iop->dmaQueue.count = 0;
    iop->mscRepeatActive = false;
    iop->mscRepeatPC = 0;
    iop->mscRepeatUntilUs = 0.0;
}

void iop_free(IOP *iop) {
    registerfile_free(&iop->regInterrupts);
    iopls_free(&iop->ls);
    dmaq_free(&iop->dmaQueue);
}

void iop_set_discretes(IOP *iop, struct Discretes *d) {
    if (iop) iop->discretes = d;
}

void iop_set_servicer(IOP *iop, GpcServicerFn fn, void *servicerCtx) {
    iop->servicer = fn;
    iop->servicerCtx = servicerCtx;
}

void iop_set_peer_wait(IOP *iop, bool (*fn)(void *ctx, int busID, bool gotAny), void *ctx) {
    iop->peerWait = fn;
    iop->peerWaitCtx = ctx;
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

/* YAGPC_BUS_WORD_US: model the SERIAL BUS BEING BUSY for a transmitted word.
 *
 * Without this a transmit costs nothing: mia_xmit_word() hands the word to the
 * servicer synchronously, so the wire is never occupied and the only pacing is
 * how often the owning BCE gets a wheel slice (~16.5 us).  The hardware is
 * slower than that -- IBM-74-A31-016: a bus word is 28 bits at 1 MHz = 28 us,
 * plus a minimum 5 us interword gap, and the BCE book calls 33 us "the minimum
 * time for a word transmission over a serial bus".  So a 510-word DEU fill
 * occupies the wire 16.8 ms on the orbiter and about 10.9 ms here, and under
 * load we have measured it take 800 ms, a 75x spread.  AIG_DEU_LOADER paces
 * its eight DCP fills at 18 ms apiece, which only works if a fill reliably
 * fits inside that; nondeterministic occupancy is what breaks it.
 *
 * OFF BY DEFAULT (0 = the old free-wire behaviour).  mmumodel.c's own warning
 * applies with full force: FCMBOOT's block-gap timing is load-bearing, and
 * this changes the timing of EVERY bus transmit, mass memory included.  Set it
 * to 33 for the documented rate, or lower to buy margin against the emulator's
 * own dispatch latency, which the orbiter did not have. */
static double bus_word_us(void) {
    static int inited = 0;
    static double us = 0.0;
    if (!inited) {
        inited = 1;
        const char *e = yagpc_getenv("YAGPC_BUS_WORD_US");
        if (e != NULL) { double v = atof(e); if (v >= 0.0) us = v; }
    }
    return us;
}

/* YAGPC_BUS_WORD_US_BUSES=<n>[,<n>...]: the wire time above, on those buses
 * only.  All of them at once is not usable -- FCMBOOT's mass-memory block
 * timing is load-bearing and a paced bus 18 stops the load (#115) -- but the
 * display buses need it: FIODEUPG's commander sends seven time words, the
 * listen command and two delays before its '#MIN', and its listener's
 * '#DLYI 30 DELAY TO LET MOUTC/CMDI EXECUTE' is sized to that.  With a free
 * wire the '#MIN' and its echo arrive while the listener is still delaying,
 * the delay discards them, and the listener waits in Listen Mode for a
 * command that has already gone past (#137).  No list: every bus, as before. */
static double bus_word_us_for(int bus) {
    static int inited = 0;
    static unsigned mask = 0;
    if (!inited) {
        inited = 1;
        const char *e = yagpc_getenv("YAGPC_BUS_WORD_US_BUSES");
        while (e != NULL && *e != '\0') {
            int n = atoi(e);
            if (n >= 0 && n < 32) mask |= 1u << n;
            const char *c = strchr(e, ',');
            e = (c != NULL) ? c + 1 : NULL;
        }
    }
    double us = bus_word_us();
    if (us <= 0.0) return 0.0;
    if (mask == 0) return us;
    return (bus >= 0 && bus < 32 && (mask & (1u << bus))) ? us : 0.0;
}

/* YAGPC_FIRSTOP: the FIRST execution of each distinct opcode, with the
 * processor, the address the instruction sits at, and the simulated time.
 *
 * An OPS transition runs code paths that have never executed before, so an
 * opcode making its DEBUT at the moment of the transition is a prime suspect
 * for being implemented wrongly -- it has had no chance to be exercised, and
 * nothing else in a boot would have caught it.  A full instruction trace
 * cannot answer this (one line per slice is far too much to keep across a
 * boot) and an address-windowed trace answers a different question, needing
 * you to already know where to look.  One line per opcode, ever, costs
 * nothing after the first and is small enough to read end to end.
 *
 * Names are static string literals, so identity comparison is enough -- and
 * the MSC and BCE tables hold separate literals, so the same mnemonic in both
 * is reported separately, which is what is wanted: they are different
 * implementations. */
void iop_first_op(IOP *iop, const char *kind, const char *nm, uint32_t pc) {
    static int inited = 0, on = 0, nSeen = 0;
    static const char *seen[512];
    if (!inited) { inited = 1; on = yagpc_getenv("YAGPC_FIRSTOP") != NULL; }
    if (!on || nm == NULL) return;
    for (int i = 0; i < nSeen; i++) if (seen[i] == nm) return;
    if (nSeen < 512) seen[nSeen++] = nm;
    fprintf(stderr, "FIRSTOP %-6s %-8s pc=%05x t=%.6f\n", kind, nm,
            (unsigned)pc, iop_now_us(iop) / 1e6);
}

void iop_dma_queue_restore(IOP *iop, uint32_t addr, int direction, int bceNum) {
    if (iop == NULL) return;
    DMARequest req;
    memset(&req, 0, sizeof req);
    req.addr = addr;
    req.direction = direction;
    req.bce = (bceNum >= 1 && bceNum <= 24) ? &iop->bce[bceNum - 1] : NULL;
    dmaq_push(&iop->dmaQueue, req);
}

void iop_exec_dma_queue(IOP *iop) {
    if (iop->dmaQueue.count == 0) return;
    /* Hold the wire for one word time.  Only a TRANSMIT (DMA_READ: the IOP
     * reading main store to put a word on the bus) occupies it; a receive is
     * the peripheral's transmission and is paced at the far end. */
    double wordUs = bus_word_us();
    DMARequest req;
    if (wordUs > 0.0 && iop->cpu != NULL) {
        /* PER BUS, and WITHOUT HEAD-OF-LINE BLOCKING.  Each BCE drives its own
         * serial line, so transmits on different buses are concurrent -- but
         * the DMA queue is one shared FIFO, so simply refusing to drain while
         * its head waits for that head's wire stalls every other bus and every
         * receive behind it.  Both mistakes were measured the same way: PASS
         * never reached the point of accepting a keystroke.  Scan instead for
         * the first request whose wire is free, and lift it out of the queue.
         *
         * A receive is never gated: it is the peripheral's transmission and is
         * paced at the far end (mmumodel.c does exactly that for mass memory). */
        double now = iop->cpu->elapsedTimeUs;
        int n = iop->dmaQueue.count, pick = -1;
        for (int i = 0; i < n; i++) {
            const DMARequest *r = &iop->dmaQueue.items[iop->dmaQueue.head + i];
            if (r->direction != DMA_READ || r->bce == NULL) { pick = i; break; }
            int b = r->bce->bceNum;
            if (b < 0 || b >= 32 || bus_word_us_for(b) <= 0.0 ||
                now >= iop->busFreeUs[b]) { pick = i; break; }
        }
        if (pick < 0) return;                 /* every pending wire is busy */
        req = iop->dmaQueue.items[iop->dmaQueue.head + pick];
        for (int i = pick; i > 0; i--)
            iop->dmaQueue.items[iop->dmaQueue.head + i] =
                iop->dmaQueue.items[iop->dmaQueue.head + i - 1];
        iop->dmaQueue.head++; iop->dmaQueue.count--;
        if (req.direction == DMA_READ && req.bce != NULL) {
            int b = req.bce->bceNum;
            if (b >= 0 && b < 32) iop->busFreeUs[b] = now + bus_word_us_for(b);
        }
    } else {
        dmaq_shift(&iop->dmaQueue, &req);
    }
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
        iop_watch_store(iop, req.addr, data, "dma");
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
        /* YAGPC_MSCSTATE: every change in the two bits that GATE the MSC,
         * plus a per-second count of the slices it actually executes.
         *
         * These two bits are the whole question when TCVTMSC latches at -1.
         * -1 is FIOMCNTL's "MSC BUSY BUT INTERRUPTABLE", stored on entry to
         * FIOMNTR; every path out of FIOMNTR ends by storing 0 (FIOMWAIT) or
         * +1, and the only instruction that can hold the MSC there is @RAW,
         * whose count is a halfword of 33us ticks and so expires in at most
         * ~2.2 s.  A PERMANENT latch therefore cannot be the repeat waiting:
         * it has to be the MSC no longer being stepped at all, which is
         * exactly what a cleared halt or busy bit does here -- the repeat
         * then never resolves, the @INT is never reached, FIOCMPLT never
         * runs, and FIOPDISP never dispatches again. */
        {
            static int msInit = 0, msOn = 0, lastH = -1, lastB = -1;
            static long bin[4096]; static int lastBin = -1;
            if (!msInit) { msInit = 1; msOn = yagpc_getenv("YAGPC_MSCSTATE") != NULL; }
            if (msOn) {
                int h = (int)iop_proc_get(&iop->regHalt, PROC_MSC);
                int b = (int)iop_proc_get(&iop->regBusyWait, PROC_MSC);
                double now = (iop->cpu != NULL) ? iop->cpu->elapsedTimeUs : 0.0;
                if (h != lastH || b != lastB) {
                    fprintf(stderr, "MSCSTATE halt=%d busy=%d t=%.3f\n", h, b, now / 1e6);
                    lastH = h; lastB = b;
                }
                int sec = (int)(now / 1e6);
                if (sec >= 0 && sec < 4096) {
                    if (h && b) bin[sec]++;
                    if (sec != lastBin) {
                        lastBin = sec;
                        if (sec >= 1 && bin[sec - 1] == 0)
                            fprintf(stderr, "MSCSTATE IDLE-SECOND t=%d\n", sec - 1);
                    }
                }
            }
        }
        if (!iop_proc_get(&iop->regHalt, PROC_MSC)) return;
        if (!iop_proc_get(&iop->regBusyWait, PROC_MSC)) return;
    } else {
        int bceIdx = page;
        /* YAGPC_BCESTATE: for the DK buses, a per-second census of the wheel
         * revolutions in which the BCE was ELIGIBLE to run (halt+busy both
         * set) against the revolutions that went by.  A BCE gets one slice per
         * 16.5 us revolution, so a word per revolution is the floor; we have
         * measured 21 revolutions per word during a transition and 84 at
         * worst, against 1.3 during GPCIPL.  Either the BCE is ineligible most
         * of the time -- its busy bit clear, so nothing steps it -- or it is
         * eligible and spending many instructions per word.  Those are
         * opposite defects and this is what separates them. */
        if (bceIdx >= 6 && bceIdx <= 8) {
            static int bsInit = 0, bsOn = 0, lastSec = -1;
            static long elig[9], seen[9];
            if (!bsInit) { bsInit = 1; bsOn = yagpc_getenv("YAGPC_BCESTATE") != NULL; }
            if (bsOn && iop->cpu != NULL) {
                int sec = (int)(iop->cpu->elapsedTimeUs / 1e6);
                if (lastSec >= 0 && sec != lastSec) {
                    fprintf(stderr, "BCESTATE t=%d", lastSec);
                    for (int b = 6; b <= 8; b++) {
                        fprintf(stderr, " bce%d=%ld/%ld", b, elig[b], seen[b]);
                        elig[b] = seen[b] = 0;
                    }
                    fprintf(stderr, "\n");
                }
                lastSec = sec;
                seen[bceIdx]++;
                if (iop_proc_get(&iop->regHalt, bceIdx) &&
                    iop_proc_get(&iop->regBusyWait, bceIdx)) elig[bceIdx]++;
            }
        }
        /* YAGPC_BWTRACE: every transition of a BCE's Halt and Busy/Wait
         * bits, timestamped.  Busy/Wait is what actually gates execution
         * (iop_exec_slice refuses to step a processor whose bit is clear),
         * only the MSC's SIO can set it, and #WAT is what clears it -- so
         * its falling edge IS the moment the bus program ended.
         *
         * This exists to date the DK holds of gpc-causes.py entry 22 from
         * the BCE's side.  TCVTBCEB stays set for a uniform ~1053 ms while
         * the wire is silent; if #WAT lands at the START of that hold the
         * program finished and the COMPLETION was lost, and if it lands at
         * the END the BCE genuinely was occupied.  Those are opposite
         * defects in opposite files. */
        {
            static int bwInit = 0, bwOn = 0;
            static unsigned bwMask = 0;
            if (!bwInit) {
                bwInit = 1;
                bwOn = yagpc_getenv("YAGPC_BWTRACE") != NULL;
                /* YAGPC_BWTRACE_PE=<n>[,<n>...] chooses the BCEs; the default
                 * is the one the trace was built for, the DK buses 6/7/8 and
                 * mass memory 18.  The intercomputer BCEs 1-5 are the ones in
                 * question at the redundant-set barrier, where the same ICC
                 * I/O completes ~5 ms apart on two computers (ledger #134). */
                const char *e = yagpc_getenv("YAGPC_BWTRACE_PE");
                if (e != NULL && *e != '\0') {
                    while (e != NULL && *e != '\0') {
                        int n = atoi(e);
                        if (n >= 0 && n < 32) bwMask |= 1u << n;
                        const char *c = strchr(e, ',');
                        e = (c != NULL) ? c + 1 : NULL;
                    }
                } else {
                    bwMask = (1u << 6) | (1u << 7) | (1u << 8) | (1u << 18);
                }
            }
            /* One previous state per BCE PER IOP: with several computers
             * these statics are shared, and a single table would report one
             * machine's edges against the other's state. */
            static int bwLast[6][33];
            static int bwLastInit = 0;
            if (!bwLastInit) {
                bwLastInit = 1;
                for (int g = 0; g < 6; g++) for (int i = 0; i < 33; i++) bwLast[g][i] = -1;
            }
            int bwG = (iop->cpu != NULL && iop->cpu->gpcId >= 0 && iop->cpu->gpcId < 6) ? iop->cpu->gpcId : 0;
            if (bwOn && bceIdx >= 0 && bceIdx < 32 && (bwMask & (1u << bceIdx))) {
                int h = iop_proc_get(&iop->regHalt, bceIdx) ? 1 : 0;
                int b = iop_proc_get(&iop->regBusyWait, bceIdx) ? 1 : 0;
                int st = (h << 1) | b;
                if (bwLast[bwG][bceIdx] != st) {
                    bwLast[bwG][bceIdx] = st;
                    fprintf(stderr, "BW gpc=%d bce=%d halt=%d busy=%d t=%.1f\n",
                            bwG, bceIdx, h, b, iop_now_us(iop));
                }
            }
        }
        if (!iop_proc_get(&iop->regHalt, bceIdx)) return;
        if (!iop_proc_get(&iop->regBusyWait, bceIdx)) return;
        /* Still on the wire: see iop_bce_wire_hold. */
        if (bceIdx >= 1 && bceIdx <= 24 && iop->cpu != NULL &&
            iop->cpu->elapsedTimeUs < iop->bce[bceIdx - 1].wireHoldUntilUs) return;
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
    /* YAGPC_BCEPCTRACE=lo[-hi] is YAGPC_IOPTRACE narrowed to one address
     * window.  The full trace is one line per slice, which is far too much
     * to keep for a multi-second boot; this prints only while a processor
     * is fetching inside the window under study. */
    {
        static int tinited = 0;
        static long tlo = -1, thi = -1;
        if (!tinited) {
            const char *w = yagpc_getenv("YAGPC_BCEPCTRACE");
            if (w != NULL) {
                char *end = NULL;
                tlo = strtol(w, &end, 16);
                thi = (end != NULL && *end == '-') ? strtol(end + 1, NULL, 16)
                                                   : tlo;
            }
            tinited = 1;
        }
        if (tlo >= 0 && (long)pc >= tlo && (long)pc <= thi) {
            fprintf(stderr, "BCEPC %s%d pc=%05x %04x %04x t=%.1f\n",
                    (page == 0) ? "MSC" : "BCE", page, (unsigned)pc,
                    (unsigned)hw1, (unsigned)hw2, iop_now_us(iop));
        }
    }

    /* YAGPC_MSCRING=<n>: the last n MSC instructions (address and both
     * halfwords), dumped at the FIRST DMA store-protect violation.  The
     * CPU has YAGPC_NIARING; the MSC had nothing, so an MSC found running
     * somewhere absurd -- executing a HAL/S module's code as MSC
     * instructions, as OPS 901 does on v39 -- could be SEEN but not
     * TRACED back to the branch or start that put it there. */
    if (page == 0) msc_ring_record(iop, pc, hw1, hw2);

    if (yagpc_getenv("YAGPC_IOPTRACE")) {
        char who[8];
        if (page == 0) snprintf(who, sizeof who, "MSC");
        else snprintf(who, sizeof who, "BCE%d", page);
        fprintf(stderr, "%12.1f us IOPT %-6s %05x  %04x %04x  A=%08x BST=%08x BASE=%05x\n",
                (iop->cpu != NULL) ? iop->cpu->elapsedTimeUs : 0.0,
                who, (unsigned)pc, (unsigned)hw1, (unsigned)hw2,
                (unsigned)iopls_getACC(&iop->ls), (unsigned)iopls_getBST(&iop->ls),
                (unsigned)register_get32(iopls_BASE(&iop->ls)));
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

/* THE WIRE HOLD.  A transmit here costs the bus program nothing: #MOUT queues
 * its words and moves on at once, and a command word goes out inside the
 * instruction that sends it.  On the orbiter a bus word is 33 us (28 bits
 * at 1 MHz and the interword gap, IBM-74-A31-016), and bus programs are
 * written against that -- FIODEUPG's listener waits '#DLYI 30 DELAY TO LET
 * MOUTC/CMDI EXECUTE', sized to its commander's seven-word '#MOUT', listen
 * command and delays before the '#MIN'.  With a free wire that '#MIN' and its
 * echo arrived while the listener was still delaying, the delay discarded
 * them, and the listener waited for a command that had gone past (#137).
 *
 * Pacing each word through the DMA queue instead (YAGPC_BUS_WORD_US) is the
 * obvious model and is wrong here: the command words it does not queue
 * overtake the data words it does, so a '#MIN' reached the display unit
 * before the '#MOUT' ahead of it, and on the display buses traffic fell ten-
 * fold.  So the words still go at once, in order, and it is the BCE that
 * waits: its next instruction is held until the words it has sent would have
 * cleared the wire.  YAGPC_WIRE_HOLD_BUSES=<n>[,<n>...] chooses the buses;
 * none by default. */
static bool wire_hold_bus(const IOP *iop, int bus) {
    /* YAGPC_WIRE_HOLD_BUSES, when given, replaces what the router asked for:
     * a list of buses, or 'none'. */
    static int inited = 0, given = 0;
    static unsigned mask = 0;
    if (!inited) {
        inited = 1;
        const char *e = yagpc_getenv("YAGPC_WIRE_HOLD_BUSES");
        if (e != NULL) {
            given = 1;
            while (*e != '\0' && strcmp(e, "none") != 0) {
                int n = atoi(e);
                if (n >= 0 && n < 32) mask |= 1u << n;
                const char *c = strchr(e, ',');
                if (c == NULL) break;
                e = c + 1;
            }
        }
    }
    unsigned m = given ? mask : iop->wireHoldBuses;
    return bus >= 0 && bus < 32 && (m & (1u << bus));
}

void iop_set_wire_hold_buses(IOP *iop, uint32_t busMask) {
    if (iop) iop->wireHoldBuses = busMask;
}

#define WIRE_WORD_US 33.0

static void iop_bce_wire_hold(IOP *iop, BCE *bce, unsigned words) {
    if (bce == NULL || iop->cpu == NULL || !wire_hold_bus(iop, bce->bceNum)) return;
    double now = iop->cpu->elapsedTimeUs;
    if (bce->wireHoldUntilUs < now) bce->wireHoldUntilUs = now;
    bce->wireHoldUntilUs += (double)words * WIRE_WORD_US;
}

void iop_queue_dma(IOP *iop, uint32_t addr, DMADirection direction, BCE *bce) {
    if (bce && direction == DMA_READ) iop_bce_wire_hold(iop, bce, 1u);
    /* Counted here rather than in the five instructions that can queue a
     * transmit (#TDS, #TDL, #TDLI, #MOUT, #MOUT@), so no path is missed.
     * "Queued" against "sent" is the discriminator: a shortfall at queue
     * time is the bus program asking for too little, a shortfall at send
     * time is the emulator losing words. */
    if (bce && direction == DMA_READ && bce->bceNum >= 0 && bce->bceNum < 32) {
        dmaQueuedRead[bce->bceNum]++;
        if (yagpc_getenv("YAGPC_DMATRACE"))
            fprintf(stderr, "  QDMA bce=%d addr=%05x  bcePC=%05x\n",
                    bce->bceNum, (unsigned)addr,
                    (unsigned)(register_get32(iopls_at(&iop->ls, bce->bceNum, 0, 2)) & 0x3ffffu));
    }
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
        /* YAGPC_REPEATTRACE: the count each repeat ARMS, with the PC that
         * armed it.  The count is what decides whether a @RAW that cannot be
         * satisfied is a short delay or a machine-stopping park, and it is
         * not visible any other way -- the instruction's own displacement is
         * only half of it, the index register supplies the rest. */
        static int rtInit = 0, rtOn = 0;
        if (!rtInit) { rtInit = 1; rtOn = yagpc_getenv("YAGPC_REPEATTRACE") != NULL; }
        if (rtOn)
            /* THE ACCUMULATOR IS THE MONITOR MASK.  FIOMNTR0 loads it from
             * the TOP ACTIVE IOQE ("GET I/O MONITOR MASK FROM THE TOP
             * ACTIVE IOQE"), so it names which buses the MSC is watching
             * on this pass -- and therefore which completions it CANNOT
             * see.  Without it the trace says how long a repeat armed for
             * but not what it was waiting on, which is the actual
             * question when one bus's completion is 1052 ms late while
             * the MSC cycles every 34 ms. */
            fprintf(stderr, "REPEAT gpc=%d pc=%05x d=%u x=%05x count=%u (%.1f us) "
                            "acc=%08x busy=%08x t=%.1f\n",
                    (iop->cpu != NULL) ? iop->cpu->gpcId : 0,
                    (unsigned)pc, (unsigned)df_get(v, 'd'),
                    (unsigned)(register_get32(iopls_X(&iop->ls)) & 0x3ffff),
                    (unsigned)count, (double)count * MSC_REPEAT_TICK_US,
                    (unsigned)iopls_getACC(&iop->ls),
                    (unsigned)register_get32(&iop->regBusyWait), now);
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


/* ---- YAGPC_MSCRING: see the call site in the fetch loop. ---- */
static struct { uint32_t pc; uint16_t h1, h2; double t; } *mscRing = NULL;
static unsigned mscRingCap = 0, mscRingPos = 0, mscRingN = 0;
static int mscRingInit = 0, mscRingDumped = 0;
static void msc_ring_record(IOP *iop, uint32_t pc, uint32_t hw1, uint32_t hw2) {
    if (!mscRingInit) {
        mscRingInit = 1;
        const char *e = yagpc_getenv("YAGPC_MSCRING");
        if (e != NULL && atoi(e) > 0) {
            mscRingCap = (unsigned)atoi(e);
            mscRing = calloc(mscRingCap, sizeof *mscRing);
            if (mscRing == NULL) mscRingCap = 0;
        }
    }
    if (mscRingCap == 0) return;
    mscRing[mscRingPos].pc = pc;
    mscRing[mscRingPos].h1 = (uint16_t)hw1;
    mscRing[mscRingPos].h2 = (uint16_t)hw2;
    mscRing[mscRingPos].t = (iop->cpu != NULL) ? iop->cpu->elapsedTimeUs : 0.0;
    mscRingPos = (mscRingPos + 1) % mscRingCap;
    if (mscRingN < mscRingCap) mscRingN++;
}
static void msc_ring_dump_once(IOP *iop, const char *why) {
    (void)iop;
    if (mscRingCap == 0 || mscRingDumped || mscRingN == 0) return;
    mscRingDumped = 1;
    fprintf(stderr, "MSCRING (oldest first, %u entries) before %s:\n", mscRingN, why);
    unsigned start = (mscRingPos + mscRingCap - mscRingN) % mscRingCap;
    for (unsigned i = 0; i < mscRingN; i++) {
        unsigned k = (start + i) % mscRingCap;
        fprintf(stderr, "  %05x  %04x %04x  t=%.1f\n", (unsigned)mscRing[k].pc,
                (unsigned)mscRing[k].h1, (unsigned)mscRing[k].h2, mscRing[k].t);
    }
}

static bool iop_write_main16(IOP *iop, uint32_t addr, uint32_t value);

/* A commanded receive that goes this long without a word is abandoned.
 * The floor matters because the timeout count a bus program loads can be
 * zero, and a real subsystem still needs time to answer. */
/* Was 20 ms, which was too long to be a floor: it silently overrode the
 * flight software's OWN message timeout.  GPCIPL loads the display BCE an
 * MTO of 303, i.e. 5.0 ms, and the MSC services the bus on a 6 ms loop --
 * so a 20 ms floor turned every starved receive into more than three
 * whole service periods.  That is not a small distortion: each timeout
 * error-terminates the BCE, which SETS its indicator, and the MSC's
 * @RAI ("repeat until all indicators") is then satisfied early, putting
 * the whole service loop out of phase.  Measured against a real display
 * unit and mass memory, sweeping only this number:
 *
 *     20 ms   load never completes, 97 BCE6 timeouts, 27 unheadered fills
 *      5 ms   load COMPLETES,       14 timeouts,       0 unheadered
 *      2 ms   load COMPLETES,        6 timeouts,       0 unheadered
 *    0.5 ms   load COMPLETES,        6 timeouts,       0 unheadered
 *
 * 2 ms keeps a real floor for the case it exists for -- a bus program
 * that loads a very short count, such as the mass memory's MTO of 15
 * (0.25 ms), which no peer on a socket can answer inside -- while being
 * comfortably under any timeout the software sets deliberately, and
 * twenty times the ~100 us a peer here actually takes to reply. */

/* The floor is a concession to a peripheral in ANOTHER PROCESS, reached
 * over a socket: the count a bus program loads can be far shorter than
 * the host can answer in, and the reference makes the same allowance for
 * the same reason -- its comment adds "set it to 0 for exact hardware
 * behaviour when the subsystem is in this process", which is exactly the
 * case --deu-model creates.
 *
 * It is not free.  GPCIPL gives the mass memory an MTO of 15, which is
 * 0.25 ms; flooring that at 20 ms makes every retry of an absent
 * subsystem eighty times longer than the software intended, and the
 * machine then spends all its time retrying.  So an in-process
 * peripheral turns it off. */

void iop_set_recv_timeout_floor_us(IOP *iop, double us) {
    if (iop) iop->recvTimeoutFloorUs = us;
}

void iop_set_bus_marks_sync(IOP *iop, uint32_t busMask) {
    if (iop) iop->busMarksSync = busMask;
}

/* The BCE's own message time out, from its local store (bank 1, word 3),
 * in the same 16.5 us ticks the delay instructions use. */
static double iop_recv_timeout_us(IOP *iop, int p) {
    /* YAGPC_RECV_FLOOR_US overrides the floor for measurement.  It is
     * worth measuring because the floor is four times what the flight
     * software asks for here -- GPCIPL loads the display BCE an MTO of
     * 303, which is 5.0 ms, and a 20 ms floor turns one starved receive
     * into more than three whole 6 ms MSC service periods. */
    if (!iop->recvFloorFromEnv) {
        const char *e = yagpc_getenv("YAGPC_RECV_FLOOR_US");
        iop->recvFloorFromEnv = 1;
        if (e != NULL) iop->recvTimeoutFloorUs = atof(e);
        /* Upstream: "the receive time-out floor is zero: the loaded time
         * out governs."  FCMINIOP programs every BCE's MTO explicitly, and
         * a 2 ms floor overrides all of them except buses 6-9, 12-13 and
         * 18-19 -- bus 24's 49.5 us becomes 2 ms, 40x. */
        else if (iop_upstream()) iop->recvTimeoutFloorUs = 0.0;
    }
    Register *r = iopls_at(&iop->ls, p, 1, 3);
    uint32_t mto = r ? (register_get32(r) & 0x3ffffu) : 0u;
    double t = (double)mto * MTO_TICK_US;
    return t > iop->recvTimeoutFloorUs ? t : iop->recvTimeoutFloorUs;
}

void iop_bce_error_terminate(IOP *iop, int p) {
    discretes_note_io_done(iop->discretes, p, true);
    /* YAGPC_ERRTERM_TRACE=<n>[,<n>...]: every error termination of those
     * BCEs (all, if the list is empty), per computer, with the BCE's program
     * address.  A time-out has its own RECV TIMEOUT line; one without it is a
     * command-sync word arriving mid-receive or another cause, and in a
     * redundant set an error on one computer alone ends the set (#138). */
    {
        static int inited = 0, on = 0;
        static unsigned mask = 0;
        if (!inited) {
            inited = 1;
            const char *e = yagpc_getenv("YAGPC_ERRTERM_TRACE");
            if (e != NULL) {
                on = 1;
                while (*e != '\0') {
                    int n = atoi(e);
                    if (n > 0 && n < 32) mask |= 1u << n;
                    const char *c = strchr(e, ',');
                    if (c == NULL) break;
                    e = c + 1;
                }
            }
        }
        if (on && p >= 1 && p <= 24 && (mask == 0 || (mask & (1u << p))) && iop->cpu != NULL)
            fprintf(stderr, "ERRTERM gpc=%d bce=%d pc=%05x left=%u t=%.1f\n",
                    iop->cpu->gpcId, p,
                    (unsigned)(register_get32(iopls_at(&iop->ls, p, 0, 2)) & 0x3ffffu),
                    (unsigned)iop->bce[p - 1].recvLeft, iop->cpu->elapsedTimeUs);
    }
    iop_proc_set(&iop->regProgExcept, p, 0);
    iop_proc_set(&iop->regBusyWait, p, 0);
    iop_proc_set(&iop->regIndicator, p, 1);
    if (p < 1 || p > 24) return;
    BCE *bce = &iop->bce[p - 1];
    bce->recvActive = false;
    /* Anything the MIA had received is dropped with it, and so is any DMA
     * this BCE still had queued. */
    while (mia_data_available(iop, &bce->mia)) (void)mia_get_data(iop, &bce->mia);
    dmaq_drop_for_bce(&iop->dmaQueue, bce);
}

/* Is a receive at this PC only now beginning, rather than already in
 * progress?  A waiting receive re-fetches its own instruction every
 * slice, and anything the instruction does BESIDES receiving -- above
 * all putting its companion command on the bus -- must happen once, on
 * the first execution, not on every re-fetch. */
bool iop_bce_receive_starting(IOP *iop) {
    BCE *bce = iop_cur_bce(iop);
    if (bce == NULL) return true;
    uint32_t pc = register_get32(iopls_PC(&iop->ls)) & 0x3ffffu;
    return !(bce->recvActive && bce->recvPC == pc);
}

/* YAGPC_PROCTRACE: one line per CHANGE to the processor-enable register,
 * with the command that caused it.  YAGPC_PROCDUMP shows the state at the
 * END of a run, which is the quiesced state and says nothing about how it
 * got there; the question "which buses did the software bring up, and when
 * did this one go away" needs the history.
 *
 * It is what showed that GPCIPL master-resets the IOP just before handing
 * off (data=c0767fe0, every processor cleared), that PASS then re-enables
 * only the MSC and MM1 to load itself, and that the DK bus -- BCE6, the
 * display -- is never enabled again afterwards, which is why the DEU goes
 * quiet at the handoff and stays quiet. */
static void iop_log_procs(IOP *iop, const char *what, uint32_t data) {
    if (!yagpc_getenv("YAGPC_PROCTRACE")) return;
    static uint32_t last = 0xffffffffu;
    uint32_t now = register_get32(&iop->regHalt);
    if (now == last) return;
    fprintf(stderr, "PROCS %-8s t=%.0f data=%08x  %08x -> %08x  dk1(bce6)=%d"
            "  cpu@%05x\n",
            what, iop_now_us(iop), data, last, now,
            iop_proc_get(&iop->regHalt, 6) ? 1 : 0,
            iop->cpu ? (unsigned)psw_get_nia(&iop->cpu->psw) : 0u);
    last = now;
}

/* YAGPC_PROCDUMP prints, at the end of a run, which IOP processors are
 * enabled, which are in Busy/Wait, and where each PC is parked.  A BCE that
 * has executed #WAT shows as enabled but NOT busy: that combination is what
 * a permanent park looks like, and it is otherwise invisible from outside. */
void iop_dump_procs(IOP *iop) {
    if (iop == NULL) return;
    /* The MIA enables matter as much as the processor enables: a BCE can be
     * enabled and still do nothing if its bus transmitter/receiver is off,
     * and the two are set by different commands (FCMINIOP's ENABLE
     * TRANSMITTERS/RECEIVERS from TFCMXMSK/TFCMRMSK, vs CONFIGURE
     * PROCESSORS).  Printing both says which of the two is missing. */
    fprintf(stderr, "iop mia: xmit=%08x recv=%08x  dk1(bce6) xmit=%d recv=%d\n",
            (unsigned)register_get32(&iop->regXmitEna),
            (unsigned)register_get32(&iop->regRecvEna),
            iop_proc_get(&iop->regXmitEna, 6) ? 1 : 0,
            iop_proc_get(&iop->regRecvEna, 6) ? 1 : 0);
    fprintf(stderr, "iop procs: MSC halt=%d busy=%d pc=%05x\n",
            iop_proc_get(&iop->regHalt, PROC_MSC),
            iop_proc_get(&iop->regBusyWait, PROC_MSC),
            (unsigned)(register_get32(iopls_at(&iop->ls, 0, 0, 2)) & 0x3ffffu));
    for (int i = 1; i <= 24; i++) {
        int halt = iop_proc_get(&iop->regHalt, i);
        int busy = iop_proc_get(&iop->regBusyWait, i);
        if (!halt && !busy) continue;
        const BCE *b = &iop->bce[i - 1];
        /* recvActive/recvLeft answer "is this BCE parked mid-transfer",
         * which halt/busy alone cannot: a BCE waiting out a commanded
         * receive that no subsystem will ever answer looks identical to a
         * running one until the receive state is printed beside it. */
        fprintf(stderr, "iop procs: BCE%-2d halt=%d busy=%d pc=%05x ind=%d pex=%d"
                " recv=%d left=%u since=%.0f gotAny=%d dly=%d\n",
                i, halt, busy,
                (unsigned)(register_get32(iopls_at(&iop->ls, i, 0, 2)) & 0x3ffffu),
                iop_proc_get(&iop->regIndicator, i),
                iop_proc_get(&iop->regProgExcept, i),
                (int)b->recvActive, (unsigned)b->recvLeft, b->recvSinceUs,
                (int)b->recvGotAny, (int)b->delayActive);
    }
}

/* The IOP side of YAGPC_WATCHHW.  cpu.c's copy only sees CPU stores, so an
 * IOP write into the watched window -- a BCE receive whose destination runs
 * past its buffer, or a DMA store -- was invisible.  FCMINSST sits at 0731a,
 * immediately after the BCE program area that ends at 07319, so "who else
 * wrote this halfword" is exactly the question that needs answering. */
static void iop_watch_store(IOP *iop, uint32_t addr, uint32_t value,
                            const char *kind) {
    static int inited = 0;
    static long lo = -1, hi = -1;
    if (!inited) {
        const char *w = yagpc_getenv("YAGPC_WATCHHW");
        if (w != NULL) {
            char *end = NULL;
            lo = strtol(w, &end, 16);
            hi = (end != NULL && *end == '-') ? strtol(end + 1, NULL, 16) : lo + 1;
        }
        inited = 1;
    }
    if (lo < 0 || (long)addr < lo || (long)addr > hi) return;
    fprintf(stderr, "WATCHHW IOP-%s addr=%05x val=%04x pe=%d t=%.1f\n",
            kind, (unsigned)addr, (unsigned)(value & 0xffff),
            iop->curPE, iop_now_us(iop));
}


double iop_now_us(IOP *iop) {
    return (iop != NULL && iop->cpu != NULL) ? iop->cpu->elapsedTimeUs : 0.0;
}

/* Move every word the MIA has into the receive, up to its count. */
static void bce_take_words(IOP *iop, BCE *bce, int p, double now) {
    while (bce->recvLeft > 0 && mia_data_available(iop, &bce->mia)) {
        bool wasLatch = bce->mia.latchValid;
        uint32_t data = mia_get_data(iop, &bce->mia);
        /* FIRST INPUT, BY MODE.  BCE Principles of Operation 4.1 and 3.4.4.
         *
         * Listen Mode (transmitter disabled) 'waits (indefinitely) for a bus
         * word having command sync ... and an IUA that matches the BCE's
         * IUAR', and 'uses the arrival of this command as a signal to set
         * its timers and start watching for arrival of the first input of
         * data'.  Command Mode starts timing at once and may discard one
         * command-sync word -- 'the copy of that command that has been
         * echoed back by the MIA' -- and a second is an error; any
         * command-sync word after data has begun is a sync error in either
         * mode.
         *
         * Without this an intercomputer listener, which FCMINIOP gives an MTO
         * of 2 (33 us) and whose commander delays 198 us before it transmits,
         * timed out before every transfer, was retried, and read each
         * transfer one cycle late or not at all (ledger #131-#133). */
        /* YAGPC_RECVWORD_TRACE=<n>[,<n>...]: every word a SHORT receive (armed
         * for four words or fewer) takes on those BCEs, per computer, with its
         * sync type and the receive's state as the word arrives.  Written to
         * see, rather than infer from the listing, what a mass-memory
         * listener's two-word status receive is handed when it error-
         * terminates with one word left (ledger #139). */
        {
            static int rwInit = 0;
            static unsigned rwMask = 0;
            if (!rwInit) {
                rwInit = 1;
                const char *e = yagpc_getenv("YAGPC_RECVWORD_TRACE");
                while (e != NULL && *e != '\0') {
                    int n = atoi(e);
                    if (n > 0 && n < 32) rwMask |= 1u << n;
                    const char *c = strchr(e, ',');
                    if (c == NULL) break;
                    e = c + 1;
                }
            }
            /* Short receives in full; longer ones only their first three
             * words, which is enough to see whether two computers reading the
             * same segment start it on the same word. */
            if (rwMask != 0 && p > 0 && p < 32 && (rwMask & (1u << p)) &&
                (bce->recvCount <= 4 || bce->recvCount - bce->recvLeft < 3) &&
                iop->cpu != NULL)
                fprintf(stderr, "RECVWORD gpc=%d bce=%d pc=%05x word=%06x sync=%s src=%s await=%d skipped=%d got=%d left=%u xmit=%d t=%.1f\n",
                        iop->cpu->gpcId, p,
                        (unsigned)(register_get32(iopls_PC(&iop->ls)) & 0x3ffffu),
                        (unsigned)(data & 0xffffffu), bce->mia.lastCmdSync ? "CMD " : "data",
                        bce->mia.lastFromLatch ? "latch" : "bus  ",
                        (int)bce->recvAwaitCmd, (int)bce->recvSkippedEcho, (int)bce->recvGotAny,
                        (unsigned)bce->recvLeft, (int)iop_proc_get(&iop->regXmitEna, p), now);
        }
        if (bce->recvAwaitCmd || bce->mia.lastCmdSync) {
            if (bce->recvAwaitCmd) {
                if (bce->mia.lastCmdSync &&
                    ((data >> 19) & 0x1fu) ==
                        (register_get32(iopls_IUAR(&iop->ls)) & 0x1fu)) {
                    bce->recvAwaitCmd = false;
                    bce->recvSinceUs = now;          /* the MTO starts here */
                }
                continue;                            /* nothing is stored */
            }
            if (!bce->recvGotAny && !bce->recvSkippedEcho &&
                iop_proc_get(&iop->regXmitEna, p)) {
                bce->recvSkippedEcho = true;
                bce->recvSinceUs = now;
                continue;
            }
            iop_bce_error_terminate(iop, p);
            bce->recvActive = false;
            bce->recvErrored = true;
            return;
        }
        if (iop->clearWatch[p] && yagpc_getenv("YAGPC_CLEARTRACE")) {
            fprintf(stderr, "CLEARREAD bce=%d took=%04x from=%s t=%.1f\n",
                    p, (unsigned)data, wasLatch ? "latch-or-live" : "LIVE",
                    now);
            iop->clearWatch[p] = 0;
        }
        iopls_setD(&iop->ls, data);
        iop_write_main16(iop, bce->recvAddr, data);
        bce->recvAddr = (bce->recvAddr + 1) & 0x3ffffu;
        bce->recvLeft--;
        bce->recvGotAny = true;
        bce->recvSinceUs = now;
    }
}

/* How overdue, in simulated microseconds, a reply must be before a peer in
 * another process is allowed to hold the machine for it.  See iop_bce_receive. */
#define PEER_HOLD_AFTER_US 500.0

/* YAGPC_TIMEOUT_TRACE_PE=<n>[,<n>...] restricts YAGPC_TIMEOUT_TRACE to those
 * processing elements.  The unfiltered trace logs every receive the machine
 * arms, and a computer driving the whole vehicle arms millions -- the
 * intercomputer BCEs, which are the ones in question, drown in it. */
static bool timeout_trace_pe(int pe) {
    static int inited = 0;
    static unsigned mask = 0;
    static bool all = true;
    if (!inited) {
        inited = 1;
        const char *e = yagpc_getenv("YAGPC_TIMEOUT_TRACE_PE");
        if (e != NULL && *e != '\0') {
            all = false;
            while (e != NULL && *e != '\0') {
                int n = atoi(e);
                if (n >= 0 && n < 32) mask |= 1u << n;
                const char *c = strchr(e, ',');
                e = (c != NULL) ? c + 1 : NULL;
            }
        }
    }
    return all || (pe >= 0 && pe < 32 && (mask & (1u << pe)));
}

/* YAGPC_TIMEOUT_TRACE_FROM=<seconds>: arms before that point on the
 * computer's own clock are not logged.  The mass-memory BCEs arm millions of
 * receives, and the question is usually a few seconds after the OPS request. */
static double timeout_trace_from_us(void) {
    static int inited = 0;
    static double us = 0.0;
    if (!inited) {
        inited = 1;
        const char *e = yagpc_getenv("YAGPC_TIMEOUT_TRACE_FROM");
        if (e != NULL && *e != '\0') us = atof(e) * 1e6;
    }
    return us;
}

bool iop_bce_receive(IOP *iop, uint32_t addr, uint32_t count) {
    BCE *bce = iop_cur_bce(iop);
    if (bce == NULL) return true;
    int p = iop->curPE;
    uint32_t pc = register_get32(iopls_PC(&iop->ls)) & 0x3ffffu;
    double now = (iop->cpu != NULL) ? iop->cpu->elapsedTimeUs : 0.0;

    if (!bce->recvActive || bce->recvPC != pc) {
        /* YAGPC_CLEARTRACE: the SSL's "CLEAR THE MIA BUFFER" read is a
         * one-word #RDLI meant to discard a STALE word.  Whether it gets
         * the latch or a live word decides the phase of everything after
         * it, so record which. */
        if (count == 1) iop->clearWatch[p] = 1;
        bce->recvActive = true;
        bce->recvPC = pc;
        bce->recvAddr = addr & 0x3ffffu;
        bce->recvLeft = count;
        bce->recvCount = count;
        bce->recvSinceUs = now;
        bce->recvGotAny = false;
        /* LISTEN MODE is a transmitter-disabled BCE, and it waits for a
         * command before it starts timing out data -- but only where the
         * bus's model can show it one. */
        bce->recvAwaitCmd = !iop_proc_get(&iop->regXmitEna, p) &&
                            bce->bceNum >= 0 && bce->bceNum < 32 &&
                            ((iop->busMarksSync >> bce->bceNum) & 1u);
        bce->recvSkippedEcho = false;
        bce->recvErrored = false;
        if (yagpc_getenv("YAGPC_TIMEOUT_TRACE") && timeout_trace_pe(p) &&
            now >= timeout_trace_from_us()) {
            Register *r = iopls_at(&iop->ls, p, 1, 3);
            /* gpc= because with several computers the local clocks overlap
             * and a line cannot otherwise be attributed (run fc-short-0). */
            /* iuar= is what a Listen-Mode receive will accept a command for:
             * a listener whose IUAR does not match the commander's command
             * waits through the whole transfer and the MSC's single look
             * finds it still busy (ledger #137). */
            fprintf(stderr, "BCE%d RECV ARM gpc=%d t=%.1f us pc=%05x addr=%05x "
                            "count=%u mto=%u timeout=%.2f ms listen=%d xmit=%d iuar=%u\n",
                    p, (iop->cpu != NULL) ? iop->cpu->gpcId : 0,
                    now, (unsigned)pc, (unsigned)bce->recvAddr,
                    (unsigned)count,
                    (unsigned)(r ? register_get32(r) & 0x3ffffu : 0u),
                    iop_recv_timeout_us(iop, p) / 1000.0, (int)bce->recvAwaitCmd,
                    (int)iop_proc_get(&iop->regXmitEna, p),
                    (unsigned)(register_get32(iopls_IUAR(&iop->ls)) & 0x1fu));
        }
    }

    bce_take_words(iop, bce, p, now);
    if (bce->recvErrored) { bce->recvErrored = false; return false; }

    /* A PEER IN ANOTHER PROCESS IS LATE IN WALL TIME, NOT IN SIMULATED TIME.
     * Once a reply is overdue by PEER_HOLD_AFTER_US, let the peer hold the
     * machine until it arrives (bcenet_framer_peer_wait says when that is
     * warranted), so it lands inside the flight software's window as a real
     * unit's would.  A real display unit answers in tens of microseconds;
     * the threshold is well past that and well inside the 5 ms GPCIPL
     * allows, and before the MSC gives up on the BCE. */
    if (bce->recvLeft > 0 && iop->peerWait != NULL
        && now - bce->recvSinceUs >= PEER_HOLD_AFTER_US
        && iop->peerWait(iop->peerWaitCtx, bce->mia.bceNum, bce->recvGotAny))
        bce_take_words(iop, bce, p, now);
    if (bce->recvErrored) { bce->recvErrored = false; return false; }

    if (bce->recvLeft == 0) {
        bce->recvActive = false;
        /* Surplus words a subsystem put on the bus are deliberately NOT
         * flushed here.  A real receiver is inhibited except while a
         * commanded transfer is running, so it would not have captured
         * them, and dropping them is arguably right -- but it breaks the
         * mass memory path, where a block arrives as one datagram of 512
         * halfwords and a bus program that takes a block in more than one
         * receive would lose the rest of it. */
        return true;
    }
    /* A Listen-Mode BCE that has not yet seen its command waits
     * indefinitely; the timer starts when the command arrives. */
    if (!bce->recvAwaitCmd && now - bce->recvSinceUs >= iop_recv_timeout_us(iop, p)) {
        /* The reference prints the same line under NSTS_BUS_TIMEOUT_TRACE.
         * A receive that times out error-terminates the BCE, which is
         * what puts it NO-GO and sends the flight software down its
         * RESET STATUS1 recovery path -- so if that path runs here and
         * not there, this is where to look first. */
        if (yagpc_getenv("YAGPC_TIMEOUT_TRACE") && timeout_trace_pe(p) &&
            now >= timeout_trace_from_us())
            fprintf(stderr, "BCE%d RECV TIMEOUT gpc=%d t=%.1f us left=%u gotAny=%d "
                            "waited=%.2f ms mto=%.2f ms\n",
                    p, (iop->cpu != NULL) ? iop->cpu->gpcId : 0,
                    now, (unsigned)bce->recvLeft, (int)bce->recvGotAny,
                    (now - bce->recvSinceUs) / 1000.0,
                    iop_recv_timeout_us(iop, p) / 1000.0);
        iop_bce_error_terminate(iop, p);
    }
    return false;
}

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
    if (now < bce->delayUntilUs) {
        /* Nothing is armed to receive, so whatever comes down the bus
         * while this runs is lost -- and that is the point of the
         * instruction, not a side effect of it.  FCMBOOT reads the part
         * of a mass memory block it wants and then delays for exactly the
         * rest of it (see mmumodel.c's pacing comment); without this the
         * unread tail stayed queued and every load block after the first
         * landed hundreds of halfwords early.  The last word taken stays
         * in the adapter, which is the one the software's own "CLEAR THE
         * MIA BUFFER" #RDLI expects to find. */
        bool held = false;
        while (mia_data_available(iop, &bce->mia)) {
            bce->mia.latch = mia_get_data(iop, &bce->mia);
            bce->mia.latchCmdSync = bce->mia.lastCmdSync;
            held = true;             /* re-latches what it just took */
        }
        if (held) bce->mia.latchValid = true;
        return false;
    }
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
    /* YAGPC_ODDFW: report a FULLWORD read whose address is ODD.
     *
     * BCE POO (IBM-6246556A part 3) section 1: "all main memory addresses
     * computed by the BCE are represented as 18-bit absolute numbers... the
     * lowest bit (bit 17) the halfword portion of the addressed fullword...
     * WHEN USED AS A FULLWORD ADDRESS, BIT 17 IS IGNORED.  Thus, H'276' and
     * H'277' refer to the same fullword."
     *
     * The four PC-relative instructions honour that with `& ~1u`
     * (#LTO, #SBST, #SST, #DLY).  The long-format ones that carry an explicit
     * address field -- #LBR@, #CMD, #TDL, #MOUT@ -- do NOT, so an odd address
     * there would read a fullword STRADDLING two entries where the hardware
     * would read the one containing it.  Whether that ever happens is a
     * question about the flight software's tables, not about the rule, so
     * count it rather than guess. */
    if (addr & 1u) {
        static int ofInit = 0, ofOn = 0; static long n = 0;
        if (!ofInit) { ofInit = 1; ofOn = yagpc_getenv("YAGPC_ODDFW") != NULL; }
        if (ofOn && n < 40) {
            n++;
            fprintf(stderr, "ODDFW addr=%05x proc=%d pc=%05x t=%.6f\n",
                    (unsigned)addr, iop->curPE,
                    (unsigned)(register_get32(iopls_PC(&iop->ls)) & 0x3ffffu),
                    iop_now_us(iop) / 1e6);
        }
    }
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
    iop_watch_store(iop, addr, value, "write");
    /* DIAGNOSTIC ONLY.  YAGPC_NO_DMA_PROTECT makes this path bypass store
     * protection, the way iop_exec_dma_queue's own write already does.  It
     * exists to answer one question -- whether the protected SSL temp
     * buffer is the ONLY thing blocking the load -- and must never be set
     * for a fidelity run: enforcing protection here is correct and is what
     * raised GPCIPL trace agreement to 299,984/300,000 (426bca4d3). */
    {
        static int inited = 0;
        static int bypass = 0;
        if (!inited) { bypass = yagpc_getenv("YAGPC_NO_DMA_PROTECT") != NULL; inited = 1; }
        if (bypass) {
            mcm_set16(&iop->cpu->mainStorage, addr, value, false);
            return true;
        }
    }
    if (mcm_set16(&iop->cpu->mainStorage, addr, value, true)) return true;
    /* A masked DMA store protect sets the CPU's CC to binary 10 (Fig 2-20
     * note '##') WITHOUT taking an interrupt, so it is invisible to
     * YAGPC_INTTRACE while still able to break a CPU-side condition test
     * mid-loop.  YAGPC_DMAPROT is the only way to see it happen. */
    msc_ring_dump_once(iop, "the first DMA store-protect violation");
    if (yagpc_getenv("YAGPC_DMAPROT"))
        fprintf(stderr, "DMAPROT addr=%05x val=%04x pe=%d ovr=%d pc=%05x "
                        "t=%.1f\n",
                (unsigned)addr, (unsigned)(value & 0xffff), iop->curPE,
                (int)iop->cpu->storeProtectOverride,
                (unsigned)(register_get32(iopls_PC(&iop->ls)) & 0x3ffffu),
                iop_now_us(iop));
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

/* The PC is an 18-BIT local-store register, so every write wraps at
 * 0x3ffff -- the reference's setNIA masks with LS_WORD_MASK and this did
 * not.  Read sites mostly masked for themselves, which is why the
 * machine ran; what it cost was the MSC fixture suite, where 11,959 of
 * the 11,959 failures were this one thing, the full 32-bit value showing
 * up where an 18-bit one belonged.  That buried every genuine
 * per-instruction discrepancy the suite would otherwise have reported. */
void iop_set_nia(IOP *iop, uint32_t x) {
    register_set32(iopls_PC(&iop->ls), x & 0x3ffffu);
}
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
        case 0x85040000: /* MIA TRANSMITTER ENABLE */ {
            uint32_t before = register_get32(&iop->regXmitEna);
            uint32_t after = (cmd == 0x85040000u) ? (before | (data & MIA_WRITE_MASK))
                                                  : (before & ~(data & MIA_WRITE_MASK));
            register_set32(&iop->regXmitEna, after);
            /* YAGPC_XMITENA_TRACE: every transmitter enable and disable, per
             * computer, with the CPU address that sent it.  In a redundant
             * set only the commander of a bus may transmit on it; a listener
             * whose transmitter was never disabled sends every command too
             * (ledger #139). */
            if (yagpc_getenv("YAGPC_XMITENA_TRACE") && iop->cpu != NULL)
                fprintf(stderr, "XMITENA gpc=%d %s data=%08x %08x->%08x nia=%05x "
                                "t=%.1f shared=%.6f\n",
                        iop->cpu->gpcId, (cmd == 0x85040000u) ? "ENABLE " : "DISABLE",
                        (unsigned)data, (unsigned)before, (unsigned)after,
                        (unsigned)psw_get_nia(&iop->cpu->psw), iop->cpu->elapsedTimeUs,
                        vehicle_shared_us(iop->vehicle, iop->cpu->gpcId) / 1e6);
            break;
        }
        case 0x84080000: /* MIA RECEIVER DISABLE */
            register_set32(&iop->regRecvEna,
                           register_get32(&iop->regRecvEna) & ~(data & MIA_WRITE_MASK));
            break;
        case 0x85080000: /* MIA RECEIVER ENABLE */
            register_set32(&iop->regRecvEna,
                           register_get32(&iop->regRecvEna) | (data & MIA_WRITE_MASK));
            break;
        case 0x84100000: { /* DISCRETE OUTPUT RESET */
            uint32_t r0 = register_get32(&iop->regDiscreteOut);
            uint32_t r2 = r0 & data;
            uint32_t r1 = r0 ^ r2;
            register_set32(&iop->regDiscreteOut, r1);
            discretes_publish_out(iop->discretes, r0, r1);
            break;
        }
        case 0x85100000: { /* DISCRETE OUTPUT SET */
            uint32_t r0 = register_get32(&iop->regDiscreteOut);
            uint32_t r1 = r0 | data;
            register_set32(&iop->regDiscreteOut, r1);
            discretes_publish_out(iop->discretes, r0, r1);
            break;
        }
        case 0x86200000: { /* CONFIGURE PROCESSORS HALT */
            /* regHalt holds Status Register 5 the way the architecture
             * defines it -- 1 = Processor Enabled -- so halting CLEARS
             * the named processors' bits.  See regHalt in iop.h. */
            uint32_t r1 = register_get32(&iop->regHalt);
            register_set32(&iop->regHalt, r1 & ~data);
            iop_log_procs(iop, "HALT", data);
            break;
        }
        case 0x87200000: { /* CONFIGURE PROCESSORS ENABLE */
            uint32_t r1 = register_get32(&iop->regHalt);
            register_set32(&iop->regHalt, r1 | data);
            iop_log_procs(iop, "ENABLE", data);
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
            iop_log_procs(iop, "MRESET", data);
            register_set32(&iop->regXmitEna, 0x00000000u);
            register_set32(&iop->regRecvEna, 0x00000000u);
            {   /* Master reset drops every discrete output; that is a change
                 * like any other and is published. */
                uint32_t r0 = register_get32(&iop->regDiscreteOut);
                register_set32(&iop->regDiscreteOut, 0x00000000u);
                discretes_publish_out(iop->discretes, r0, 0x00000000u);
            }
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
            /* When the CPU wakes the MSC.  The gap between these is the
             * whole display story: the MSC parks itself at @WAT and can
             * do nothing until this arrives, so if the fills are slow it
             * is this cadence, not the IOP's own scheduling, that says
             * so.  No PC is printed -- iopls_PC() reads whichever page
             * the round-robin happens to have selected, which for a
             * CPU-side PCO is any of the 26. */
            if (yagpc_getenv("YAGPC_DISPTRACE")) {
                /* A busy-set arriving while the MSC is ALREADY busy is the
                 * case the POO warns about twice: "while the MSC is busy do
                 * not attempt to alter the STAT1 or STAT4 Registers by using
                 * PCO commands", and PCOs writing MSC local store -- which is
                 * where its program counter lives, and FIOSTMSC writes it with
                 * X'A201' immediately before this -- leave "MSC program
                 * execution ... unpredictable".  The running program is
                 * derailed, never reaches its @INT, and its completion is
                 * never signalled, so TCVTMSC stays latched busy. */
                int already = iop_proc_get(&iop->regBusyWait, PROC_MSC);
                fprintf(stderr, "DISP LOADMSCBUSY%s t=%.1f us\n",
                        already ? " CLOBBER" : "",
                        (iop->cpu != NULL) ? iop->cpu->elapsedTimeUs : 0.0);
            }
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
            register_set32(&iop->regCCData, iop_discrete_in_a(iop));
            break;
        case 0x081c0000: /* READ DISCRETE INPUTS B (33-40) */
            /* Register B, not A -- this read the A register, so discrete
             * inputs 33-40 came back as inputs 1-32. */
            register_set32(&iop->regCCData, iop_discrete_in_b(iop));
            break;
        case 0x10000000: /* READ STATUS1(GO/NO-GO) */
            register_set32(&iop->regCCData, register_get32(&iop->regProgExcept));
            break;
        case 0x10040000: /* READ STATUS4(BUSY/WAIT) */
            register_set32(&iop->regCCData, register_get32(&iop->regBusyWait));
            /* FCMCSYNC ORs STAT4 & FIOMMASK (X'00003000', processors 18 and
             * 19) into the DIA word it leaves in the ICC buffer, and
             * FCMDSCRM then uses those two bits to MASK OFF the MM READY
             * discretes: a BCE that reads busy takes its unit's READY away.
             * So the busy bits are as much a part of "did READY reach
             * CZ2BDIA" as READY itself, and are traced beside it. */
            if (yagpc_getenv("YAGPC_DISCTRACE")) {
                static uint32_t lastbw = 0xffffffffu;
                uint32_t bw = register_get32(&iop->regBusyWait);
                if ((bw & 0x00003000u) != (lastbw & 0x00003000u)) {
                    fprintf(stderr, "STAT4 busy=%08x mm=%04x t=%.2f\n",
                            (unsigned)bw, (unsigned)(bw & 0x00003000u),
                            (iop->cpu != NULL) ? iop->cpu->elapsedTimeUs / 1e6 : 0.0);
                    lastbw = bw;
                }
            }
            break;
        default:
            /* YAGPC_PCOUNKNOWN: a PROGRAM CONTROLLED OUTPUT this switch does
             * not decode.  The cases match an EXACT command word, so a
             * command the flight software builds with an extra field -- a
             * BCE number in the low bits, say, as FIOSTIUA does for SET IUA
             * -- falls here and is dropped in silence.  That is invisible
             * from outside, and the question it answers is a live one: no
             * GPC but GPC1 was ever seen enabling a display transmitter
             * (ledger #182), and a lost enable would look exactly like
             * that. */
            if (isOutput && yagpc_getenv("YAGPC_PCOUNKNOWN") != NULL)
                fprintf(stderr, "PCO UNDECODED gpc=%d cmd=%08x data=%08x "
                                "dev=%02x dsel=%03x nia=%05x\n",
                        iop->cpu ? iop->cpu->gpcId : 0, (unsigned)cmd,
                        (unsigned)data, (unsigned)devSelect,
                        (unsigned)dataSelect,
                        iop->cpu ? (unsigned)psw_get_nia(&iop->cpu->psw) : 0u);
            break;
    }

    if (devSelect == 0x8) { /* Local Store */
        /* THE PROCESSOR IS NAMED IN TWO PLACES, AND THEY ADD.  The manual's
         * bits 7-11 designate the MSC or a BCE, and that is all this used to
         * read -- but the flight software names the BCE in bits 23-27 (C
         * shift 4), which the layout above calls ignored:
         *
         *   FCMINIOP  FCMTBCD  X'A2158000' 'WRITE BANK B BUS 1', +16 per bus
         *   FIOCBLKS  FIOSTIUA X'A20A8000' 'SET IUA (BANK C WORD 5 OF BCE)',
         *             OR'd with BCE number SLL 4
         *   FIOMGDSP  FIOMGTSK X'A2058000' 'COMMAND LOAD TIMEOUT', 'SLL R5,4
         *             POSITION FOR COMMAND / OR R4,R5 PUT BCE NUMBER IN COMMAND'
         *
         * Reading bits 7-11 alone put every one of those writes on the MSC's
         * page or BCE 1's: no display-bus controller was ever given its IUA,
         * so a Listen-Mode receive on DK1 waited for a command it could not
         * match and the MSC's single look found it busy (ledger #137).  The
         * sum of the two fields is the only rule all three satisfy -- FCMTBCD
         * counts buses 1-24 as 1 + (0..23), the other two as 0 + (1..24) --
         * and a command that leaves bits 23-27 clear decodes as before. */
        static int lsInit = 0, lsLegacy = 0;
        if (!lsInit) { lsInit = 1; lsLegacy = yagpc_getenv("YAGPC_LS_REGION_LEGACY") != NULL; }
        uint32_t region = (dataSelect >> 5) + (lsLegacy ? 0u : ((cmd >> 4) & 0x1fu));
        uint32_t bank = (dataSelect >> 3) & 0x3;
        uint32_t word = dataSelect & 0x7;

        /* The MSC's own program counter is region 0, bank 0, word 2, and
         * the CPU setting it is how a parked MSC is aimed somewhere other
         * than the instruction after its @WAT.  Traced because whether
         * that write arrives decides where the MSC resumes, which decides
         * how much of the display's IPL it gets through per wake. */
        if (isOutput && region == 0 && bank == 0 && word == 2 &&
            yagpc_getenv("YAGPC_DISPTRACE"))
            fprintf(stderr, "DISP MSCPC<-%05x t=%.1f us\n", (unsigned)(data & 0x3ffffu),
                    (iop->cpu != NULL) ? iop->cpu->elapsedTimeUs : 0.0);

        /* Every processor's program counter as it is set, not just the
         * MSC's.  A bus program that runs somewhere unintended is almost
         * always one that was AIMED somewhere unintended, and this is the
         * only place that aiming happens. */
        if (isOutput && word == 2 && yagpc_getenv("YAGPC_PCTRACE"))
            fprintf(stderr, "PCTRACE %s%u PC<-%05x t=%.1f us\n",
                    region == 0 ? "MSC" : "BCE", (unsigned)region,
                    (unsigned)(data & 0x3ffffu),
                    (iop->cpu != NULL) ? iop->cpu->elapsedTimeUs : 0.0);

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
                /* FORCING THE MSC'S PC ENDS ANY REPEAT IN PROGRESS.
                 * On the hardware a repeat is nothing but the MSC
                 * re-executing one instruction until its condition or its
                 * count; point the PC somewhere else and there is no repeat
                 * left to be in.  We model it instead as a struct field keyed
                 * on the PC, which SURVIVES the restart -- so the MSC would
                 * run the new program, come back round to the very same @RAW
                 * (FIOMNTR is re-entered on every I/O, and FIOMDLY's @RAW
                 * sits at one fixed address), find mscRepeatActive still set
                 * and mscRepeatPC still matching, and therefore NOT re-arm.
                 * It would then compare against a deadline from the previous
                 * entry, already in the past, and fall straight through with
                 * a spurious timeout -- no delay at all, FIOMCKIO's single
                 * look taken far too early, and FIOMTOUT declaring an MSC
                 * timeout on an I/O that was merely still running.
                 *
                 * FCOS invites exactly this: TCVTMSC = -1 is "BUSY BUT
                 * INTERRUPTABLE", and FIOSTMSC's wait is DO UNTIL=(...,NP),
                 * which -1 satisfies, so the CPU restarts the MSC mid-repeat
                 * by design. */
                if ((int)region == PROC_MSC && bank == 0 && word == 2)
                    iop->mscRepeatActive = false;
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
