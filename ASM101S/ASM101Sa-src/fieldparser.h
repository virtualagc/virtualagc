/*
 * License:    This program is declared by its author, Ronald Burkey, to be the
 *             U.S. Public Domain, and may be freely used, modified, or
 *             distributed for any purpose whatever.
 * Filename:   fieldparser.h
 * Purpose:    The part of ASM101S responsible for most parsing:  the entry
 *             point to the grammar, and the joining of continuation cards.
 * Contact:    info@sandroid.org
 * Refer to:   https://www.ibiblio.org/apollo/ASM101S.html
 *
 * A port of fieldParser.py.  The grammar itself lives in parser_asm.c, having
 * been generated from the same TatSu grammar text that the Python version
 * embeds; what remains here is the calling convention and `joinOperand`.
 */

#ifndef ASM101SA_FIELDPARSER_H
#define ASM101SA_FIELDPARSER_H

#include "common.h"
#include "val.h"

/* Parse `text` by the named grammar rule.  Returns the AST, or NULL where the
   Python returns None.  The result is in the main arena and stays valid. */
Val *parserASM (const char *text, const char *rule);

/* Where the operand field of a statement ends:  at the first blank that is
   neither inside a quoted string NOR inside parentheses. */
size_t operandFieldEnd (const char *text);

/* Is the end of `text` inside a quoted string? */
int insideQuote (const char *text);

/* Does a card carry the expander's stamp -- `nn-NAME` -- in columns 73-80? */
int macroStamped (const char *card);

/* Form the merged operand field, taking continuation cards into account.
   `lines` is a list of source-card strings.  On return `*operand` is the
   joined field and `*skipCount` the number of continuation cards consumed;
   the function's value is the `status` of the Python original. */
int joinOperand (Val *lines, size_t index, size_t column, int proto, int invoke,
                 char **operand, ptrdiff_t *skipCount);

#endif /* ASM101SA_FIELDPARSER_H */
