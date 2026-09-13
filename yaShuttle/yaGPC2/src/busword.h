/* The SYNC TYPE of a received bus word.
 *
 * Every word on a Shuttle serial bus carries either command sync or data
 * sync, and the BCE Principles of Operation (IBM-6246556A part 3) makes the
 * receiver's behaviour depend on it: a BCE in Command Mode skips one echoed
 * command before its first data word, and a BCE in Listen Mode -- its MIA
 * transmitter disabled -- waits indefinitely for a command with a matching
 * IUA and only then starts timing out the first data word (section 4.1).
 *
 * The bus-service interface that carries words between the IOP and the
 * device models (yaGpcIntegration.h) has no field for it, and that header is
 * shared with other programs, so the sync type rides in the one bit a
 * received word never otherwise uses: the top bit.  A model that produces a
 * command-sync word sets it; the MIA layer strips it before any bus program
 * sees the word and records it on the adapter instead.  A model that never
 * sets it produces data-sync words, which is what every model did before, so
 * nothing that does not use it changes. */
#ifndef YAGPC_BUSWORD_H
#define YAGPC_BUSWORD_H

#define YAGPC_BUSWORD_CMD_SYNC 0x80000000u

#endif
