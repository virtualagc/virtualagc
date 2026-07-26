#include "ebcdic.h"

/* The `[0 ... 255] = -1` default deliberately gets overwritten by the
 * specific entries that follow (GNU range-designator idiom for "sparse
 * array, -1 elsewhere") — silence the compiler's override-init warning
 * for just these two intentional initializers. */
#if defined(__clang__)
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Winitializer-overrides"
#else
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Woverride-init"
#endif

/* Table entries copied verbatim from gpc/ebcdic.coffee. */
const int EBCDIC_TO_ASCII[256] = {
    [0 ... 255] = -1,
    [0x40] = ' ',  [0x4A] = '.',  [0x4B] = '.',  [0x4C] = '<',  [0x4D] = '(',
    [0x4E] = '+',  [0x4F] = '|',  [0x50] = '&',  [0x5A] = '!',  [0x5B] = '$',
    [0x5C] = '*',  [0x5D] = ')',  [0x5E] = ';',  [0x5F] = '^',  [0x60] = '-',
    [0x61] = '/',  [0x6A] = '|',  [0x6B] = ',',  [0x6C] = '%',  [0x6D] = '_',
    [0x6E] = '>',  [0x6F] = '?',  [0x79] = '`',  [0x7A] = ':',  [0x7B] = '#',
    [0x7C] = '@',  [0x7D] = '\'', [0x7E] = '=',  [0x7F] = '"',  [0xC1] = 'A',
    [0xC2] = 'B',  [0xC3] = 'C',  [0xC4] = 'D',  [0xC5] = 'E',  [0xC6] = 'F',
    [0xC7] = 'G',  [0xC8] = 'H',  [0xC9] = 'I',  [0xD1] = 'J',  [0xD2] = 'K',
    [0xD3] = 'L',  [0xD4] = 'M',  [0xD5] = 'N',  [0xD6] = 'O',  [0xD7] = 'P',
    [0xD8] = 'Q',  [0xD9] = 'R',  [0xE2] = 'S',  [0xE3] = 'T',  [0xE4] = 'U',
    [0xE5] = 'V',  [0xE6] = 'W',  [0xE7] = 'X',  [0xE8] = 'Y',  [0xE9] = 'Z',
    [0xF0] = '0',  [0xF1] = '1',  [0xF2] = '2',  [0xF3] = '3',  [0xF4] = '4',
    [0xF5] = '5',  [0xF6] = '6',  [0xF7] = '7',  [0xF8] = '8',  [0xF9] = '9',
};

/* ASCII_TO_EBCDIC is built by inverting EBCDIC_TO_ASCII (gpc/ebcdic.coffee
 * does this at load time via `for ebcdic, ascii of EBCDIC_TO_ASCII`). Note
 * 0x4A and 0x4B both map to '.', so ASCII_TO_EBCDIC['.'] takes whichever
 * was assigned last when iterating EBCDIC_TO_ASCII in ascending numeric
 * key order — that's 0x4B (matches JS object key iteration order for
 * integer-like keys, which is always ascending numeric). Likewise 0x4F
 * and 0x6A both map to '|': ASCII_TO_EBCDIC['|'] = 0x6A. */
const int ASCII_TO_EBCDIC[256] = {
    [0 ... 255] = -1,
    [' ']  = 0x40, ['.']  = 0x4B, ['<']  = 0x4C, ['(']  = 0x4D, ['+']  = 0x4E,
    ['|']  = 0x6A, ['&']  = 0x50, ['!']  = 0x5A, ['$']  = 0x5B, ['*']  = 0x5C,
    [')']  = 0x5D, [';']  = 0x5E, ['^']  = 0x5F, ['-']  = 0x60, ['/']  = 0x61,
    [',']  = 0x6B, ['%']  = 0x6C, ['_']  = 0x6D, ['>']  = 0x6E, ['?']  = 0x6F,
    ['`']  = 0x79, [':']  = 0x7A, ['#']  = 0x7B, ['@']  = 0x7C, ['\''] = 0x7D,
    ['=']  = 0x7E, ['"']  = 0x7F, ['A']  = 0xC1, ['B']  = 0xC2, ['C']  = 0xC3,
    ['D']  = 0xC4, ['E']  = 0xC5, ['F']  = 0xC6, ['G']  = 0xC7, ['H']  = 0xC8,
    ['I']  = 0xC9, ['J']  = 0xD1, ['K']  = 0xD2, ['L']  = 0xD3, ['M']  = 0xD4,
    ['N']  = 0xD5, ['O']  = 0xD6, ['P']  = 0xD7, ['Q']  = 0xD8, ['R']  = 0xD9,
    ['S']  = 0xE2, ['T']  = 0xE3, ['U']  = 0xE4, ['V']  = 0xE5, ['W']  = 0xE6,
    ['X']  = 0xE7, ['Y']  = 0xE8, ['Z']  = 0xE9, ['0']  = 0xF0, ['1']  = 0xF1,
    ['2']  = 0xF2, ['3']  = 0xF3, ['4']  = 0xF4, ['5']  = 0xF5, ['6']  = 0xF6,
    ['7']  = 0xF7, ['8']  = 0xF8, ['9']  = 0xF9,
};

#pragma GCC diagnostic pop
