/* AP-101 computer assembly (CPU + IOP + shared MemoryBus), ported from
 * gpc/ap101.coffee.
 *
 * gpc/ap101.coffee's `AP101 extends LRU` (com/lru.civet): LRU's
 * constructor opens a real UDP socket (`new Bus('__SIMCONTROL', ...)`)
 * for a simulation-control channel, plus per-named-bus sockets from
 * `@config.busses` — AP101 always passes `busses: []`, so no per-bus
 * sockets are ever opened, and the `__SIMCONTROL` socket's setup has no
 * synchronous console output and is never read from or written to by any
 * code path `gpc run` exercises. Real networking is out of scope for a
 * single-process batch run (see iop.h's MIA comment for the identical
 * reasoning) — LRU is omitted entirely rather than ported, since even the
 * one thing it does unconditionally (open a socket) has no observable
 * effect on `run`'s captured output. */
#ifndef YAGPC_AP101_H
#define YAGPC_AP101_H

#include "cpu.h"
#include "iop.h"
#include "membus.h"

typedef struct {
    CPU cpu;
    IOP iop;
    MemoryBus ram; /* backs cpu.ram; gpc.ram / gpc.mainStorage aliases below */
} AP101;

void ap101_init(AP101 *gpc);
void ap101_free(AP101 *gpc);

void ap101_exec1(AP101 *gpc);
void ap101_reset(AP101 *gpc);

#endif
