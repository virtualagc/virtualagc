/* EBCDIC <-> ASCII translation tables, ported from gpc/ebcdic.coffee. */
#ifndef YAGPC_EBCDIC_H
#define YAGPC_EBCDIC_H

/* Indexed by EBCDIC byte (0-255); -1 if unmapped (matches a JS object with
 * no entry for that key -> undefined). */
extern const int EBCDIC_TO_ASCII[256];

/* Indexed by ASCII byte (0-255); -1 if unmapped. */
extern const int ASCII_TO_EBCDIC[256];

#endif
