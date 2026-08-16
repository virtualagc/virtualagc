/*
 * License:    This program is declared by its author, Ronald Burkey, to be the
 *             U.S. Public Domain, and may be freely used, modified, or
 *             distributed for any purpose whatever.
 * Filename:   model101.h
 * Purpose:    Object-code generation for ASM101S, specific to the assembly
 *             language of the IBM AP-101S computer.
 * Contact:    info@sandroid.org
 * Refer to:   https://www.ibiblio.org/apollo/ASM101S.html
 *
 * A port of model101.py.  The long design commentary at the head of that file
 * -- on pseudo-addresses, on the units of the second operand of an SRS or RS
 * instruction, and on how the four passes divide the work -- applies here
 * unchanged and is reproduced at the head of model101.c.
 */

#ifndef ASM101SA_MODEL101_H
#define ASM101SA_MODEL101_H

#include "common.h"
#include "val.h"

/*---------------------------------------------------------------------------
 * The assembly's non-line-by-line state, as the Python's module-level globals.
 */
extern Val *sects;        /* dict: CSECTs and DSECTs */
extern Val *symtab;       /* dict */
extern Val *entries;      /* insertion-ordered set, for ENTRY */
extern Val *extrns;       /* insertion-ordered set, for EXTRN */
extern Val *relocations;  /* list of RLD entries */
extern Val *literalPools; /* list */
extern Val *metadata;
extern Val *ignoreOps; /* dict used as a set */
extern unsigned char fillPattern[2];

/* The internal key of the unnamed dummy section.  Deliberately not a legal
   symbol, so it cannot collide with a section the source names, nor with "",
   which is the unnamed CONTROL section. */
#define UNNAMED_DSECT "*DSECT*"

void model101_init (int forceD);

/* Reverses the hashing of a computed arithmetic result.  `*sect` is set to
   NULL for a purely numerical value, or to the name of an EXTRN or CSECT for
   an address.  Returns 0 for the (None, None) case, in which neither output is
   meaningful. */
int unhash (asmint result, const char **sect, asmint *number);
asmint getHashcode (const char *symbol);
const char *hashcodeSymbol (asmint hashcode);
const char *rextrnSymbol (asmint value);

Val *generateObjectCode (Val *source, Val *macros);

/* The literal pools, exposed for the listing. */
extern size_t emptyPoolLength;

#endif /* ASM101SA_MODEL101_H */
