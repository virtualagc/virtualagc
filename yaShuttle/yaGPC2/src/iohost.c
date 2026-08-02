#include "iohost.h"

#include <stdlib.h>
#include <string.h>

void iohost_init_from_opts(IOHost *io, HalUCP *halUCP, const Options *opts) {
    memset(io, 0, sizeof(*io));
    io->halUCP = halUCP;
    for (int ch = 0; ch < IOHOST_MAX_CHANNEL; ch++) {
        io->inFiles[ch] = opts->infile[ch];
        io->outFiles[ch] = opts->outfile[ch];
    }
    io->ebcdic = opts->ebcdic;
    io->verbose = opts->verbose;
}

void iohost_free(IOHost *io) {
    for (int ch = 0; ch < IOHOST_MAX_CHANNEL; ch++) {
        if (io->inLines[ch]) {
            for (int i = 0; i < io->inLineCount[ch]; i++) free(io->inLines[ch][i]);
            free(io->inLines[ch]);
        }
        if (io->outStreams[ch]) fclose(io->outStreams[ch]);
    }
    memset(io, 0, sizeof(*io));
}

void iohost_fatal(IOHost *io, const char *msg) {
    if (io->errorCallback) {
        io->errorCallback(io->cbCtx, msg);
    } else {
        fprintf(stderr, "FATAL: %s\n", msg);
    }
    exit(1);
}

/* Splits `content` on '\n' into io->inLines[ch] (like JS's
 * content.split('\n')), dropping a single trailing empty element
 * produced by a final newline (matches the source's explicit .pop()). */
static void load_input_file(IOHost *io, int ch, const char *content, size_t len) {
    int cap = 16;
    char **lines = malloc((size_t)cap * sizeof(char *));
    int count = 0;
    size_t start = 0;
    for (size_t i = 0; i <= len; i++) {
        if (i == len || content[i] == '\n') {
            size_t lineLen = i - start;
            if (lineLen > 0 && content[start + lineLen - 1] == '\r') lineLen--; /* CRLF-terminated source */
            char *line = malloc(lineLen + 1);
            memcpy(line, content + start, lineLen);
            line[lineLen] = '\0';
            if (count >= cap) {
                cap *= 2;
                lines = realloc(lines, (size_t)cap * sizeof(char *));
            }
            lines[count++] = line;
            start = i + 1;
        }
    }
    /* Drop a single trailing empty line from a final newline. */
    if (count > 0 && lines[count - 1][0] == '\0') {
        free(lines[count - 1]);
        count--;
    }
    io->inLines[ch] = lines;
    io->inLineCount[ch] = count;
    io->inLineNext[ch] = 0;
    io->inConfigured[ch] = true;
}

void iohost_init(IOHost *io, const SymbolTable *symOrNull) {
    if (symOrNull) halucp_init_from_symbols(io->halUCP, symOrNull);

    if (!io->ebcdic) io->halUCP->iobufAscii = true;

    for (int ch = 0; ch < IOHOST_MAX_CHANNEL; ch++) {
        if (!io->inFiles[ch]) continue;
        FILE *f = fopen(io->inFiles[ch], "rb");
        if (!f) {
            char msg[512];
            snprintf(msg, sizeof msg, "Cannot open input file for channel %d: %s (ENOENT: no such file or directory)", ch, io->inFiles[ch]);
            iohost_fatal(io, msg);
            continue;
        }
        fseek(f, 0, SEEK_END);
        long sz = ftell(f);
        fseek(f, 0, SEEK_SET);
        char *buf = malloc((size_t)sz + 1);
        size_t got = fread(buf, 1, (size_t)sz, f);
        buf[got] = '\0';
        fclose(f);
        load_input_file(io, ch, buf, got);
        free(buf);
    }

    for (int ch = 0; ch < IOHOST_MAX_CHANNEL; ch++) {
        if (!io->outFiles[ch]) continue;
        io->outStreams[ch] = fopen(io->outFiles[ch], "wb");
        if (!io->outStreams[ch]) {
            char msg[512];
            snprintf(msg, sizeof msg, "Cannot open output file for channel %d: %s", ch, io->outFiles[ch]);
            iohost_fatal(io, msg);
        }
    }

    io->halUCP->cbCtx = io;
    io->halUCP->outputCallback = iohost_handle_output;
}

void iohost_handle_output(void *ioVp, const char *text, int channel) {
    IOHost *io = ioVp;
    if (channel >= 0 && channel < IOHOST_MAX_CHANNEL && io->outStreams[channel]) {
        fputs(text, io->outStreams[channel]);
    }
    if (io->outputCallback) {
        io->outputCallback(io->cbCtx, text, channel);
    } else {
        fputs(text, stdout);
    }
}

const char *iohost_read_input_line(IOHost *io, int channel) {
    if (channel < 0 || channel >= IOHOST_MAX_CHANNEL || !io->inConfigured[channel]) return NULL;
    if (io->inLineNext[channel] >= io->inLineCount[channel]) {
        if (io->verbose) {
            fprintf(stderr, "IOHost: Input exhausted on channel %d\n", channel);
        }
        return NULL;
    }
    return io->inLines[channel][io->inLineNext[channel]++];
}

bool iohost_has_file_configured(IOHost *io, int channel) {
    return channel >= 0 && channel < IOHOST_MAX_CHANNEL && io->inFiles[channel] != NULL;
}

bool iohost_has_file_input(IOHost *io, int channel) {
    return channel >= 0 && channel < IOHOST_MAX_CHANNEL && io->inConfigured[channel] &&
           io->inLineNext[channel] < io->inLineCount[channel];
}

void iohost_close(IOHost *io) {
    for (int ch = 0; ch < IOHOST_MAX_CHANNEL; ch++) {
        if (io->outStreams[ch]) {
            fclose(io->outStreams[ch]);
            io->outStreams[ch] = NULL;
        }
    }
}
