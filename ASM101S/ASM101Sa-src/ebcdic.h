/*
 * License:    This program is declared by its author, Ronald Burkey, to be the
 *             U.S. Public Domain, and may be freely used, modified, or
 *             distributed for any purpose whatever.
 * Filename:   ebcdic.h
 * Purpose:    ASCII/EBCDIC conversion tables.
 * Contact:    info@sandroid.org
 */

#ifndef ASM101SA_EBCDIC_H
#define ASM101SA_EBCDIC_H

/* Indexed by an ASCII code 0-127.  A character outside that range never
   reaches these; the Python guards every use the same way. */
extern const unsigned char asciiToEbcdic[128];
extern const char ebcdicToAscii[256];

#endif /* ASM101SA_EBCDIC_H */
