/*
 * License:    This program is declared by its author, Ronald Burkey, to be the
 *             U.S. Public Domain, and may be freely used, modified, or
 *             distributed for any purpose whatever.
 * Filename:   parser_asm.h
 * Purpose:    The table of grammar rules the generated parser exposes.
 * Contact:    info@sandroid.org
 */

#ifndef ASM101SA_PARSER_ASM_H
#define ASM101SA_PARSER_ASM_H

#include "peg.h"

typedef struct
{
  const char *name;
  void (*fn) (PegCtx *c);
} AsmRule;

extern const AsmRule asmRules[];

#endif /* ASM101SA_PARSER_ASM_H */
