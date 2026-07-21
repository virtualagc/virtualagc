#include "halmat.h"

#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

const char *halmat_qual_name(uint8_t qual) {
    switch (qual) {
        case QUAL_EMPTY: return "  0";
        case QUAL_SYT: return "SYT";
        case QUAL_INL: return "INL";
        case QUAL_VAC: return "VAC";
        case QUAL_XPT: return "XPT";
        case QUAL_LIT: return "LIT";
        case QUAL_IMD: return "IMD";
        case QUAL_AST: return "AST";
        case QUAL_CSZ: return "CSZ";
        case QUAL_ASZ: return "ASZ";
        case QUAL_OFF: return "OFF";
        default: return "???";
    }
}

#define HALMAT_OPCODE_XREC 0x002

static uint32_t decode_word_be(const uint8_t *p) {
    return ((uint32_t)p[0] << 24) | ((uint32_t)p[1] << 16) | ((uint32_t)p[2] << 8) | (uint32_t)p[3];
}

static void decode_operand(uint32_t w, halmat_operand_t *o) {
    o->data = (uint16_t)((w >> 16) & 0xFFFF);
    o->tag1 = (uint8_t)((w >> 8) & 0xFF);
    o->qual = (uint8_t)((w >> 4) & 0xF);
    o->tag2 = (uint8_t)((w >> 1) & 0x7);
}

bool halmat_load(const char *path, halmat_program_t *out, char *errbuf, size_t errbuf_size) {
    memset(out, 0, sizeof(*out));

    FILE *f = fopen(path, "rb");
    if (!f) {
        snprintf(errbuf, errbuf_size, "cannot open '%s': %s", path, strerror(errno));
        return false;
    }

    if (fseek(f, 0, SEEK_END) != 0) {
        snprintf(errbuf, errbuf_size, "cannot seek '%s'", path);
        fclose(f);
        return false;
    }
    long size = ftell(f);
    if (size < 0 || fseek(f, 0, SEEK_SET) != 0) {
        snprintf(errbuf, errbuf_size, "cannot determine size of '%s'", path);
        fclose(f);
        return false;
    }
    if (size % HALMAT_RECORD_BYTES != 0) {
        snprintf(errbuf, errbuf_size,
                 "'%s' is %ld bytes, not a multiple of the %d-byte HALMAT record size",
                 path, size, HALMAT_RECORD_BYTES);
        fclose(f);
        return false;
    }

    uint8_t *buf = malloc((size_t)size);
    if (!buf) {
        snprintf(errbuf, errbuf_size, "out of memory reading '%s'", path);
        fclose(f);
        return false;
    }
    if (fread(buf, 1, (size_t)size, f) != (size_t)size) {
        snprintf(errbuf, errbuf_size, "short read on '%s'", path);
        free(buf);
        fclose(f);
        return false;
    }
    fclose(f);

    size_t num_records = (size_t)size / HALMAT_RECORD_BYTES;
    size_t num_words_total = (size_t)size / 4;

    /* Upper bound: worst case every word is its own operator instruction
     * with zero operands, i.e. one halmat_instr_t per word. */
    halmat_instr_t *instrs = malloc(num_words_total * sizeof(halmat_instr_t));
    if (!instrs) {
        snprintf(errbuf, errbuf_size, "out of memory decoding '%s'", path);
        free(buf);
        return false;
    }
    size_t instr_count = 0;

    for (size_t rec = 0; rec < num_records; rec++) {
        size_t record_base_word = rec * HALMAT_RECORD_WORDS;
        size_t lw = 0;
        while (lw < HALMAT_RECORD_WORDS) {
            size_t gw = record_base_word + lw;
            uint32_t w = decode_word_be(buf + gw * 4);

            if (w & 1) {
                snprintf(errbuf, errbuf_size,
                         "malformed HALMAT stream in '%s': expected an operator word "
                         "at word index %zu, found an operand word (record %zu)",
                         path, gw, rec);
                free(instrs);
                free(buf);
                return false;
            }

            halmat_instr_t *instr = &instrs[instr_count++];
            instr->index = gw;
            instr->tag = (uint8_t)((w >> 24) & 0xFF);
            instr->numop = (uint8_t)((w >> 16) & 0xFF);
            instr->opcode = (uint16_t)(((w >> 12) & 0xF) << 8 | ((w >> 4) & 0xFF));
            instr->copt = (uint8_t)((w >> 1) & 0x7);
            instr->operand_count = 0;

            if (instr->numop > HALMAT_MAX_OPERANDS) {
                snprintf(errbuf, errbuf_size,
                         "instruction at word index %zu in '%s' claims %u operands, "
                         "exceeding the %d-operand cap -- format assumption needs revisiting",
                         gw, path, instr->numop, HALMAT_MAX_OPERANDS);
                free(instrs);
                free(buf);
                return false;
            }
            if (lw + 1 + instr->numop > HALMAT_RECORD_WORDS) {
                snprintf(errbuf, errbuf_size,
                         "instruction at word index %zu in '%s' overruns its record boundary",
                         gw, path);
                free(instrs);
                free(buf);
                return false;
            }

            for (uint8_t i = 0; i < instr->numop; i++) {
                size_t ogw = gw + 1 + i;
                uint32_t ow = decode_word_be(buf + ogw * 4);
                if (!(ow & 1)) {
                    snprintf(errbuf, errbuf_size,
                             "malformed HALMAT stream in '%s': expected an operand word "
                             "at word index %zu (operand %u of instruction at %zu)",
                             path, ogw, i, gw);
                    free(instrs);
                    free(buf);
                    return false;
                }
                decode_operand(ow, &instr->operands[i]);
                instr->operand_count++;
            }

            lw += 1 + instr->numop;

            if (instr->opcode == HALMAT_OPCODE_XREC) {
                break; /* rest of this record is a wasted gap; move to next record */
            }
        }
    }

    free(buf);
    out->instrs = instrs;
    out->count = instr_count;
    return true;
}

void halmat_program_free(halmat_program_t *prog) {
    free(prog->instrs);
    prog->instrs = NULL;
    prog->count = 0;
}
