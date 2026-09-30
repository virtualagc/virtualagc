#include "ebcdic.h"

/* Both tables are written out in full, sixteen entries to a row with the
 * row's high hex digit at the left, and -1 wherever there is no mapping.
 * They used to be sparse -- `[0 ... 255] = -1` and then the entries that
 * exist -- but the range designator is a GNU extension that MSVC does not
 * compile.  test/test_ebcdic.c checks every one of the 512 entries against
 * gpc/ebcdic.coffee's own tables. */

/* Table entries copied verbatim from gpc/ebcdic.coffee. */
const int EBCDIC_TO_ASCII[256] = {
    /* 0x */   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
    /* 1x */   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
    /* 2x */   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
    /* 3x */   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
    /* 4x */  ' ',   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,  '.',  '.',  '<',  '(',  '+',  '|',
    /* 5x */  '&',   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,  '!',  '$',  '*',  ')',  ';',  '^',
    /* 6x */  '-',  '/',   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,  '|',  ',',  '%',  '_',  '>',  '?',
    /* 7x */   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,  '`',  ':',  '#',  '@', '\'',  '=',  '"',
    /* 8x */   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
    /* 9x */   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
    /* Ax */   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
    /* Bx */   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
    /* Cx */   -1,  'A',  'B',  'C',  'D',  'E',  'F',  'G',  'H',  'I',   -1,   -1,   -1,   -1,   -1,   -1,
    /* Dx */   -1,  'J',  'K',  'L',  'M',  'N',  'O',  'P',  'Q',  'R',   -1,   -1,   -1,   -1,   -1,   -1,
    /* Ex */   -1,   -1,  'S',  'T',  'U',  'V',  'W',  'X',  'Y',  'Z',   -1,   -1,   -1,   -1,   -1,   -1,
    /* Fx */  '0',  '1',  '2',  '3',  '4',  '5',  '6',  '7',  '8',  '9',   -1,   -1,   -1,   -1,   -1,   -1,
};

/* ASCII_TO_EBCDIC is built by inverting EBCDIC_TO_ASCII (gpc/ebcdic.coffee
 * does this at load time via `for ebcdic, ascii of EBCDIC_TO_ASCII`). Note
 * 0x4A and 0x4B both map to '.', so ASCII_TO_EBCDIC['.'] takes whichever
 * was assigned last when iterating EBCDIC_TO_ASCII in ascending numeric
 * key order — that's 0x4B (matches JS object key iteration order for
 * integer-like keys, which is always ascending numeric). Likewise 0x4F
 * and 0x6A both map to '|': ASCII_TO_EBCDIC['|'] = 0x6A. */
const int ASCII_TO_EBCDIC[256] = {
    /* 0x */   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
    /* 1x */   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
    /* 2x */ 0x40, 0x5A, 0x7F, 0x7B, 0x5B, 0x6C, 0x50, 0x7D, 0x4D, 0x5D, 0x5C, 0x4E, 0x6B, 0x60, 0x4B, 0x61,
    /* 3x */ 0xF0, 0xF1, 0xF2, 0xF3, 0xF4, 0xF5, 0xF6, 0xF7, 0xF8, 0xF9, 0x7A, 0x5E, 0x4C, 0x7E, 0x6E, 0x6F,
    /* 4x */ 0x7C, 0xC1, 0xC2, 0xC3, 0xC4, 0xC5, 0xC6, 0xC7, 0xC8, 0xC9, 0xD1, 0xD2, 0xD3, 0xD4, 0xD5, 0xD6,
    /* 5x */ 0xD7, 0xD8, 0xD9, 0xE2, 0xE3, 0xE4, 0xE5, 0xE6, 0xE7, 0xE8, 0xE9,   -1,   -1,   -1, 0x5F, 0x6D,
    /* 6x */ 0x79,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
    /* 7x */   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1, 0x6A,   -1,   -1,   -1,
    /* 8x */   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
    /* 9x */   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
    /* Ax */   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
    /* Bx */   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
    /* Cx */   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
    /* Dx */   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
    /* Ex */   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
    /* Fx */   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
};
