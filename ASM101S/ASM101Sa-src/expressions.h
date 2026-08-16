/*
 * License:    This program is declared by its author, Ronald Burkey, to be the
 *             U.S. Public Domain, and may be freely used, modified, or
 *             distributed for any purpose whatever.
 * Filename:   expressions.h
 * Purpose:    Computing the values of expressions (arithmetic, boolean,
 *             character) and maintaining symbolic variables.
 * Contact:    info@sandroid.org
 * Refer to:   https://www.ibiblio.org/apollo/ASM101S.html
 *
 * A port of expressions.py.  In all cases here an "expression" is an AST in
 * the form the parser returns, and the code recognises the parts of it by
 * shape, exactly as the Python does.
 */

#ifndef ASM101SA_EXPRESSIONS_H
#define ASM101SA_EXPRESSIONS_H

#include "common.h"
#include "val.h"

/*---------------------------------------------------------------------------
 * Global state, named as in expressions.py.
 */
extern Val *definedNormalSymbols; /* dict */
extern Val *svGlobals;            /* dict */
extern Val *svGlobalLocals;       /* dict */
extern Val *readTimeSymbols;      /* dict */
extern Val *svImplicitArrays;     /* dict used as a set */

void expressions_init (void);

/* Mark an error against a line of source code. */
void asmError (Val *properties, const char *msg, asmint severity);
#define ERROR(props, msg) asmError ((props), (msg), 255)
void getErrorCount (asmint *count, asmint *maxSeverity);
void setErrorCounters (asmint count, asmint maxSeverity);

/* The symbol table of the assembly in progress, so that T' can reach it. */
void setProgramSymtab (Val *table);
Val *symbolEntry (const char *name, Val *symtab);

/*---------------------------------------------------------------------------
 * Macro arguments and sublists
 */
char *renderMacroArgument (Val *value);
Val *subscriptMacroArgument (Val *value, Val *indices);
asmint countMacroArgument (Val *value);
int selfDefiningTerm (Val *value, asmint *out);
int isMacroArgument (const char *name, Val *value, Val *svLocals);

/*---------------------------------------------------------------------------
 * AST helpers
 */
Val *unroll (Val *expression);
Val *astFlattenList (Val *ast);
char *describeExpression (Val *expression);
const char *characterTermValue (Val *ast);

/*---------------------------------------------------------------------------
 * Evaluation.  A NULL return is Python's None.
 */
Val *evalArithmeticExpression (Val *expression, Val *svLocals, Val *properties,
                               Val *symtab, Val *star, asmint severity);
/* The common short form:  properties with only an `errors` list, no symtab,
   no `*` and full severity. */
Val *evalArith (Val *expression, Val *svLocals, Val *properties);
Val *evalQuietly (Val *expression, Val *svLocals, Val *symtab);
Val *evalBooleanExpression (Val *expression, Val *svLocals, Val *properties);
char *evalCharacterExpression (Val *expression, Val *svLocals,
                               Val *properties);
const char *typeAttribute (Val *properties, Val *operand, Val *svLocals,
                           Val *symtab);
int attributeOperand (Val *properties, Val *operand, Val *svLocals,
                      char **text, int *isArgument);
Val *subscriptList (Val *first, Val *rest, Val *svLocals, Val *properties,
                    Val *symtab, Val *star, asmint severity);

/*---------------------------------------------------------------------------
 * Symbolic variables
 */
char *svReplace (Val *properties, const char *text, Val *svLocals);
void svDeclare (const char *operation, const char *operand, Val *svLocals,
                Val *properties);
void svSet (const char *operation, const char *name, const char *operand,
            Val *svLocals, Val *properties);
size_t splitSetOperands (const char *operand, char ***parts);

/* A `properties` standing in for the Python default argument
   `{ "errors": [] }`. */
Val *scratchProperties (void);

#endif /* ASM101SA_EXPRESSIONS_H */
