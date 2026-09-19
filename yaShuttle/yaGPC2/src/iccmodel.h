/* THE INTERCOMPUTER BUS, between machines in one process.
 *
 * Bus 24 is the one bus that is not a peripheral's: it is how the computers
 * tell each other what they are doing.  The inter-GPC DISCRETES carry a
 * three-bit sync code and nothing else, so everything with content -- each
 * GPC's current OPS, its common-set and redundant-set masks, its copy of
 * every other GPC's discrete input A -- travels here, redundancy-managed by
 * FCMDSCRM into CZ2BDIA, and DM6OPS reads exactly that when it works out
 * which computers are available to receive a memory configuration.
 *
 * Measured: with nothing carrying it, two computers that IPL, load, and sync
 * with each other perfectly still cannot form a set.  GPC1 transitions to
 * OPS 2 alone and GPC2 is never included, with no fault message, because
 * GPC1 has no way to learn that GPC2 exists beyond its sync code.
 *
 * This is a WIRE, not a device: a word one computer transmits is delivered
 * to every other computer's receive queue on the same bus, and to nobody
 * else.  No peripheral answers, because none is there -- on the vehicle the
 * subscribers are the other GPCs.
 */
#ifndef YAGPC_ICCMODEL_H
#define YAGPC_ICCMODEL_H

#include <stdbool.h>
#include <stdint.h>

#include "yaGpcIntegration.h"

typedef struct IccModel IccModel;

/* THE INTERCOMPUTER BUSES ARE 1-5, ONE PER COMPUTER -- NOT BUS 24.
 *
 * The bus table this emulator's numbering comes from (nsts-sim-gpc
 * com/bus.civet, the same table that gives DK1=6, MM1=18, MM2=19) names
 * gpcBceNum 1..5 "Intercomputer 1".."Intercomputer 5", and gpcBceNum 24
 * IP1..IP5, one per GPC.  yaGPC2 inherited the ICC on bus 24, which is the
 * IP bus, and the flight software's own command words settle which is
 * right:
 *
 *   CMD gpc=1 bus=1  iua=5  func=000 words=124
 *   CMD gpc=2 bus=2  iua=5  func=000 words=124
 *   CMD gpc=1 bus=24 iua=13 func=120..126 words=32     x7134 each
 *   CMD gpc=1 bus=24 iua=15 func=221      words=481    x6147
 *
 * 124 is SIPICCNT, the SSIP ICC word count in FIOICCPG.asm, to the word --
 * and each computer commands ITS OWN bus, GPC 1 bus 1 and GPC 2 bus 2,
 * exactly as the table says.  Bus 24 carries 32-word and 481-word reads
 * from two other units and nothing resembling an intercomputer transfer.
 *
 * So a computer COMMANDS its own bus and LISTENS on the other four, which
 * is why the queues are per (bus, receiver) rather than per receiver: the
 * words GPC 1 puts on bus 1 must reach whoever is reading BUS 1, and must
 * not be confused with what GPC 2 is putting on bus 2 at the same moment.
 * With one shared wire they were. */
#define YAGPC_ICC_BUS_FIRST 1
#define YAGPC_ICC_BUS_LAST  5
#define YAGPC_ICC_IS_BUS(b) \
    ((b) >= YAGPC_ICC_BUS_FIRST && (b) <= YAGPC_ICC_BUS_LAST)

IccModel *iccmodel_create(void);
void iccmodel_free(IccModel *m);

/* Serve one intercomputer-bus transaction for the named computer.  Words
 * transmitted on a bus go to every OTHER computer's queue FOR THAT BUS;
 * a receive takes from this computer's queue for the bus it is reading. */
void iccmodel_service(IccModel *m, int gpcId, GpcServiceNumber svc,
                      const GpcServiceInput *in, GpcServiceOutput *out);

/* The caller's time on the vehicle's shared clock, for the instruments only:
 * a message sent by one computer and read by another can only be put in
 * order on a clock both share.  Set immediately before iccmodel_service. */
void iccmodel_note_shared_us(IccModel *m, int gpcId, double sharedUs);

void iccmodel_report(const IccModel *m);

/* THE WIRE, CAPTURED AND PUT BACK.  A snapshot that leaves this out restores
 * a vehicle whose computers were mid-transfer with the transfer gone: the
 * one that was waiting for the rest of an ICC message never gets it, its
 * next I/O sync does not match its partner's, and the pair fail each other
 * within ten milliseconds of the restore (2026-09-19).  Only what the
 * machines can observe is kept -- queued words with their tags and times,
 * the per-bus transfer state -- not the instruments' counters.  Times are
 * written relative to `nowUs` and rebased on load, like every other duration
 * in a capture.  Both return false and say why on stderr if the file cannot
 * be written or read. */
/* `present` is a bit per computer (bit 1 = GPC1): a machine that is not in
 * this vehicle never drains its queue, so its 2048 words are the model's
 * own bookkeeping rather than anything to restore -- and they were 300 KB
 * of a 320 KB capture. */
bool iccmodel_dump(const IccModel *m, const char *path, double nowUs,
                   unsigned present);
bool iccmodel_load(IccModel *m, const char *path, double nowUs);

#endif
