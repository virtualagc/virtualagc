/* I/O Processor, ported from gpc/iop.coffee. Holds the Master Sequence
 * Controller (MSC, a single-accumulator I/O computer) and up to 24 Bus
 * Control Elements (BCEs, one per system bus), each executing its own
 * micro-program against a shared, page-switched IOPLocalStore register
 * bank. See iop_bce_instr.h/iop_msc_instr.h for the two instruction sets.
 *
 * Networking (com/bus.civet's real UDP multicast, used by MIA to talk to
 * other GPCs/BCEs over the simulated hardware bus) was originally out of
 * scope for standalone `gpc run` -- a batch process had no network peers,
 * and network I/O didn't affect captured stdout/stderr/output-file bytes.
 * That's still the *default*: MIA is an inert stub -- dataAvailable()
 * always false, getData() always 0, xmitWord/xmitCmd no-ops -- observably
 * identical to a real MIA that never receives anything. But `gpc run
 * --bce-network` now opts into exactly this (src/bcenet_framer.c/
 * bcenet_transport.c, installed via ap101_set_servicer() in run.c), for
 * driving a real peripheral emulator (e.g. Don Schmidt's MEDS in
 * nsts-sim-gpc) from the standalone CLI, not just through the GpcOps
 * embedding API below.
 *
 * When embedded in a larger simulator (see yaGpcIntegration.h), an
 * externally-supplied GpcServicerFn can be installed via
 * iop_set_servicer()/ap101_set_servicer(); when set, mia_xmit_word/
 * mia_xmit_cmd/mia_data_available/mia_get_data route through it instead
 * of the stub. This is already the natural word/command-level boundary
 * for that -- BCE opcodes hand whole 16/24-bit words to these functions
 * atomically, with no bit-level serialization simulated. With no
 * servicer installed, behavior is byte-for-byte the same stub as before. */
#ifndef YAGPC_IOP_H
#define YAGPC_IOP_H

#include <stdbool.h>
#include <stdint.h>

#include "instr.h"
#include "mcm.h"
#include "regmem.h"
#include "yaGpcIntegration.h"

struct CPU; /* forward decl; defined in cpu.h */
struct IOP;

typedef void (*IopInstrExecFn)(struct IOP *iop, DInstr *v);

/* IOPLocalStore — 25 register-file "pages" (page 0 = MSC, pages 1-24 =
 * BCE 1-24), each with the same 16-register layout; which fields mean
 * what depends on whether the page is being used as MSC or BCE local
 * store (see iop.coffee's MSC/BCE Mapping comment tables). nextSlice()
 * implements the round-robin page-switching schedule: a 33-slice major
 * cycle visiting each of the 24 BCEs once (3 consecutive slices each)
 * with the MSC serviced after every group of 3 BCEs.
 *
 * NOTE on a real bug in the reference implementation: gpc/iop.coffee's
 * `ls: (bank,word) -> @cp.r(bank*4+word)` is missing the call parens on
 * `cp` (`@cp` is the bound *method itself*, not its return value — should
 * be `@cp().r(...)`). Since almost every BCE/MSC instruction reaches this
 * via PC()/X()/BASE()/etc, or indirectly via incrNIA/setNIA (which route
 * through PC()), this throws an uncaught TypeError on essentially any
 * matched BCE/MSC instruction in the live reference — verified directly
 * against it; there's no try/catch between here and cmd_run.coffee's main
 * loop, so it would crash the whole `gpc run` process. In practice this
 * is unreachable for typical batch runs: regBusyWait starts all-zero, so
 * IOP.execProcessors() no-ops for every processor until something
 * explicitly starts one (e.g. an MSC @SIO or a CPU PC-instruction command
 * that sets a busy bit), which none of the pre-existing HAL/S-compiled
 * fixture .fcm files do. iopls_ls() below implements the evidently-intended,
 * correct behavior rather than replicating an accidental process crash —
 * consistent with how a couple of other genuine reference-implementation
 * bugs were handled earlier in this port (see cpu_instr.c's ICR/ISPB
 * notes).
 *
 * CONFIRMED, not just theorized: test/fixtures/iop_msc_sio.fcm (a
 * hand-assembled program that sets the MSC busy bit via a CPU `PC`
 * instruction, same "derive bit-layout by hand, validate against the
 * live JS reference first" technique as the svc_*.fcm fixtures) does
 * exactly this and reproduces the predicted crash in `gpc run` verbatim
 * (TypeError: this.cp.r is not a function, at IOPLocalStore.ls). yaGPC2
 * runs the same fixture to completion correctly (drives @SIO through the
 * real execProcessors() round-robin scheduler for the first time via the
 * actual run() pipeline, not just the isolated fixture harness) — see
 * that fixture's generator script and its dedicated, non-reference-diffed
 * check in run_matrix.sh (diffing against the reference here would never
 * pass, by design, same as the read_eof_onerror case). */
typedef struct {
    RegisterFile storePage[25];
    int slice;
    int curBCE;
    int curPage;
} IOPLocalStore;

void iopls_init(IOPLocalStore *ls);
void iopls_free(IOPLocalStore *ls);
void iopls_next_slice(IOPLocalStore *ls);
RegisterFile *iopls_cp(IOPLocalStore *ls);
Register *iopls_ls(IOPLocalStore *ls, int bank, int word);

/* COMMON */
Register *iopls_PC(IOPLocalStore *ls);
Register *iopls_IH(IOPLocalStore *ls);
Register *iopls_IL(IOPLocalStore *ls);
/* MSC */
Register *iopls_X(IOPLocalStore *ls);
Register *iopls_AH(IOPLocalStore *ls);
Register *iopls_AL(IOPLocalStore *ls);
Register *iopls_ECR(IOPLocalStore *ls);
Register *iopls_MST(IOPLocalStore *ls);
/* BCE */
Register *iopls_DH(IOPLocalStore *ls);
Register *iopls_DL(IOPLocalStore *ls);
Register *iopls_ID(IOPLocalStore *ls);
Register *iopls_MTO(IOPLocalStore *ls);
Register *iopls_BASE(IOPLocalStore *ls);
Register *iopls_IUAR(IOPLocalStore *ls);
Register *iopls_BSTH(IOPLocalStore *ls);
Register *iopls_BSTL(IOPLocalStore *ls);

uint32_t iopls_getI(IOPLocalStore *ls);
void iopls_setI(IOPLocalStore *ls, uint32_t v);
uint32_t iopls_getD(IOPLocalStore *ls);
void iopls_setD(IOPLocalStore *ls, uint32_t v);
uint32_t iopls_getACC(IOPLocalStore *ls);
void iopls_setACC(IOPLocalStore *ls, uint32_t v);
uint32_t iopls_getBST(IOPLocalStore *ls);
void iopls_setBST(IOPLocalStore *ls, uint32_t v);

/* MIA — stub (or servicer-backed), see header comment. bceNum doubles as
 * GpcServiceInput.busID when a servicer is installed. */
typedef struct {
    int bceNum;
} MIA;

void mia_init(MIA *m, int bceNum);
bool mia_data_available(struct IOP *iop, MIA *m);
uint32_t mia_get_data(struct IOP *iop, MIA *m);
void mia_xmit_word(struct IOP *iop, MIA *m, uint32_t halfword);
void mia_xmit_cmd(struct IOP *iop, MIA *m, uint32_t cmd24);

typedef struct {
    int bceNum;
    MIA mia;
} BCE;

void bce_init(BCE *b, int bceNum);

typedef struct {
    Register regFailDisc; /* 5-bit fail discretes */
    Register regIntProg;  /* 12-bit IOP programmable interrupt register */
} MSC;

void msc_init(MSC *m);

/* One pending DMA request, queued by TDS/TDL/RDS/RDL/MOUT/MIN etc and
 * drained one-per-IOP-cycle (or all-at-once in burst mode) by
 * iop_exec_dma_queue. direction: 0 = 'read' (IOP->bus, i.e. transmit),
 * 1 = 'write' (bus->IOP, i.e. receive) — matches queueDMA's string arg. */
typedef enum { DMA_READ = 0, DMA_WRITE = 1 } DMADirection;

typedef struct {
    uint32_t addr;
    DMADirection direction;
    BCE *bce; /* NULL if none */
} DMARequest;

/* Growable FIFO (mirrors JS Array#push/#shift on @dmaQueue). */
typedef struct {
    DMARequest *items;
    int cap, head, count;
} DMAQueue;

typedef struct IOP {
    struct CPU *cpu;
    /* No separate IOP storage: real AP-101S main storage is a single
     * memory shared by the CPU and IOP (AP-101S-instruction-set.txt Sec.
     * III "1.1.2 Addressing and Instruction Formats" -- the IOP is simply
     * restricted to the lower half of the CPU's own 19-bit address space).
     * All IOP memory access already went straight to cpu->mainStorage
     * (iop_g_eaf/iop_g_eah/iop_s_eaf/iop_s_eah below); see membus.h's
     * header comment for the CPU-side half of this fix. */

    MSC msc;
    BCE bce[24]; /* bce[0] = BCE #1 ... bce[23] = BCE #24 */

    /* "MSC = 0, BCE = 1-24": which processing element's instruction is
     * currently executing, used throughout iop_bce_instr.c for "2*curPE"
     * addressing offsets and per-PE bit indexing. Fixes problems.md 1.5:
     * gpc/iop.coffee initializes @curPE=0 in the constructor and never
     * reassigns it anywhere (grep-verified across the whole source
     * tree), so every BCE beyond BCE 1 computed its addressing/bit
     * offsets as if it were BCE 0 — a genuine bug in the reference,
     * previously replicated exactly rather than fixed. Kept current now
     * by iop_exec_processors() (mirroring curBCE()/ls.curPage, which the
     * round-robin scheduler already keeps correct). */
    int curPE;

    bool dmaBurst, dmaForceBadParity, dataForceBadParity;

    Register regXmitEna, regRecvEna;
    Register regProgExcept, regBusyWait, regHalt, regIndicator;
    Register regDiscreteOut, regDiscreteInA, regDiscreteInB, regRMStatus;
    RegisterFile regInterrupts; /* 5 regs (num=5 -> 6 slots; slot 5 used by RM status read) */
    bool intForceTest;
    Register regCCData;

    IOPLocalStore ls;

    DMAQueue dmaQueue;
    long clockCycleCount;

    /* See header comment: NULL (default) preserves the exact inert-stub
     * MIA behavior; set via iop_set_servicer()/ap101_set_servicer().
     * servicerCtx is opaque -- never a GpcState, see yaGpcIntegration.h's
     * GpcServicerFn comment. */
    GpcServicerFn servicer;
    void *servicerCtx;
} IOP;

void iop_init(IOP *iop, struct CPU *cpu);
void iop_free(IOP *iop);

void iop_set_servicer(IOP *iop, GpcServicerFn fn, void *servicerCtx);

void iop_exec(IOP *iop);
void iop_exec_channel_control(IOP *iop);
void iop_exec_dma_queue(IOP *iop);
void iop_exec_processors(IOP *iop);
void iop_exec_rm(IOP *iop);

BCE *iop_cur_bce(IOP *iop); /* NULL if ls.curPage == 0 (MSC) */
void iop_queue_dma(IOP *iop, uint32_t addr, DMADirection direction, BCE *bce);

uint32_t iop_msc_ea(IOP *iop, uint32_t disp, bool indexed);
uint32_t iop_msc_long_ea(IOP *iop, uint32_t addr, bool indexed);

uint32_t iop_g_eaf(IOP *iop, uint32_t addr);
uint32_t iop_g_eah(IOP *iop, uint32_t addr);
void iop_s_eaf(IOP *iop, uint32_t addr, uint32_t value);
void iop_s_eah(IOP *iop, uint32_t addr, uint32_t value);

void iop_set_nia(IOP *iop, uint32_t x);
void iop_incr_nia(IOP *iop, int incr);

/* recvFromCPU/getCCData — declared in cpu.h as iop_recv_from_cpu/
 * iop_get_cc_data (cpu.c calls them by those names); defined here. */

/* MSC/BCE instruction decode+exec entry points (iop_msc_instr.c /
 * iop_bce_instr.c), matching MSCInstruction#exec / BCEInstruction#exec. */
void msc_instr_table_init(void);
void msc_instr_exec(IOP *iop, uint32_t hw1, uint32_t hw2);

void bce_instr_table_init(void);
void bce_instr_exec(IOP *iop, uint32_t hw1, uint32_t hw2);

#endif
