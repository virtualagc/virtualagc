/* Layer 2 of the real-peripheral servicer bridge (see plan-mode discussion
 * history, 2026-08-19): a GpcServicerFn implementation that buffers
 * yaGPC2's own word-at-a-time GPC_SVC_XMIT_WORD/XMIT_CMD/RECV_WORD/
 * RECV_POLL calls into whole bus messages and hands them to bcenet_transport
 * (layer 3) as real UDP packets, matching nsts-sim-gpc/com/bus.civet's
 * own wire framing.
 *
 * Message-boundary framing does NOT decode the BCE command word's own
 * bit-level word-count field (that field's exact bits, and whether they're
 * even consistently interpreted across every BCE instruction, was
 * confirmed uncertain -- see iop_bce_instr.c's own #MOUT/#MIN comment on
 * command-word format inconsistency). Instead this relies on a structural
 * fact confirmed from iop.c/ap101.c: one #TDL/#TDS instruction's entire
 * DMA-queued word burst arrives as an uninterrupted run of
 * GPC_SVC_XMIT_WORD calls, fully drained by iop_exec_dma_queue()'s burst
 * mode within a single iop_exec() call (itself called once per
 * ap101_exec1() -- one CPU instruction tick) -- with no other instruction
 * able to interleave mid-burst. So flushing whatever's accumulated per
 * busID once per engine tick (bcenet_framer_flush_tick(), called by the
 * new --bce-network CLI wiring after every ap101_exec1()/batchrunner
 * step -- NOT from inside iop.c/ap101.c/gpcops.c themselves, so no shared
 * engine code changes at all) reliably captures "one #TDL/#TDS transfer =
 * one flushed UDP packet" without needing any protocol-specific decode. */
#ifndef YAGPC_BCENET_FRAMER_H
#define YAGPC_BCENET_FRAMER_H

#include "bcenet_transport.h"
#include "yaGpcIntegration.h"

typedef struct BceNetFramer BceNetFramer;

/* transport is NOT owned/freed by the framer -- caller creates and frees
 * it separately (same lifetime discipline as any other servicerCtx). */
BceNetFramer *bcenet_framer_create(BceNetTransport *transport);
void bcenet_framer_free(BceNetFramer *f);

/* The GpcServicerFn itself -- install via ap101_set_servicer()/
 * iop_set_servicer() with servicerCtx = the BceNetFramer*. */
void bcenet_framer_service(void *ctx, GpcServiceNumber serviceNumber, const GpcServiceInput *input,
                            GpcServiceOutput *output);

/* Call once per CPU instruction tick (see this file's own header comment)
 * to flush any per-bus word buffers accumulated since the last call. */
void bcenet_framer_flush_tick(BceNetFramer *f);

#endif
