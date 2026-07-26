/* IOHost — file-backed I/O for CLI modes, ported from gpc/iohost.coffee.
 * Manages --infileN/--outfileN streams and wires HalUCP's outputCallback
 * to route text to the right destination(s). CLI-only (the GUI has its
 * own I/O wiring) — matches this port's scope exactly. */
#ifndef YAGPC_IOHOST_H
#define YAGPC_IOHOST_H

#include <stdbool.h>
#include <stdio.h>

#include "halucp.h"
#include "opts.h"
#include "symboltable.h"

#define IOHOST_MAX_CHANNEL 8 /* channels 0-7, matching --infile0..7/--outfile0..7 */

typedef struct {
    HalUCP *halUCP;

    const char *inFiles[IOHOST_MAX_CHANNEL];  /* NULL if unset; not owned */
    const char *outFiles[IOHOST_MAX_CHANNEL]; /* NULL if unset; not owned */
    bool ebcdic;
    bool verbose;

    /* inStreams[ch]: all lines of the input file, pre-split on '\n' (a
     * trailing empty line from a final newline is dropped, matching the
     * JS's `.pop()`), consumed front-to-back by read_input_line. */
    char **inLines[IOHOST_MAX_CHANNEL];
    int inLineCount[IOHOST_MAX_CHANNEL];
    int inLineNext[IOHOST_MAX_CHANNEL]; /* next unread index */
    bool inConfigured[IOHOST_MAX_CHANNEL];

    FILE *outStreams[IOHOST_MAX_CHANNEL];

    /* Callbacks — set by the entry point to customize output behavior. */
    void *cbCtx;
    void (*outputCallback)(void *ctx, const char *text, int channel); /* NULL -> stdout */
    void (*errorCallback)(void *ctx, const char *msg);                /* NULL -> stderr */
} IOHost;

/* Populates inFiles/outFiles (channels 0-7) from Options; strings alias
 * opts's own storage (Options outlives the IOHost in every call site). */
void iohost_init_from_opts(IOHost *io, HalUCP *halUCP, const Options *opts);
void iohost_free(IOHost *io);

/* Loads symbols into HalUCP (if not already done — safe to call even if
 * the caller already did its own symtable_load/halucp_init_from_symbols;
 * see iohost.c), sets IOBUF encoding (ascii unless --ebcdic), opens all
 * configured input/output files, and wires halUCP->outputCallback to
 * this IOHost. Calls iohost_fatal (prints + exit(1)) on any file-open
 * failure, matching the JS's uncaught behavior. */
void iohost_init(IOHost *io, const SymbolTable *symOrNull);

void iohost_handle_output(void *ioVp, const char *text, int channel); /* HalUCPOutputCB-shaped */

/* Returns NULL at EOF (no file configured for the channel, or file
 * exhausted — the latter logs to stderr if io->verbose). Caller does NOT
 * own the returned pointer (owned by the IOHost's line buffer, valid
 * until iohost_free). */
const char *iohost_read_input_line(IOHost *io, int channel);

bool iohost_has_file_configured(IOHost *io, int channel);
bool iohost_has_file_input(IOHost *io, int channel);

void iohost_close(IOHost *io);

void iohost_fatal(IOHost *io, const char *msg); /* prints + exit(1) */

#endif
