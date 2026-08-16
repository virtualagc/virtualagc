/*
 * License:    This program is declared by its author to be the U.S. Public
 *             Domain, and may be freely used, modified, or distributed for any
 *             purpose.
 * Filename:   objectwriter.h
 * Purpose:    Emit an IBM object module.
 * Reference:  C28-6538-3, "IBM System/360 Operating System Linkage Editor"
 */

#ifndef ASM101SA_OBJECTWRITER_H
#define ASM101SA_OBJECTWRITER_H

#include "common.h"
#include "val.h"

int writeObjectModule (const char *filename, Val *metadata, Val *symtab,
                       Val *sects, Val *entries, Val *extrns);

#endif /* ASM101SA_OBJECTWRITER_H */
