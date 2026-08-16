/*
 * License:    This program is declared by its author, Ronald Burkey, to be the
 *             U.S. Public Domain, and may be freely used, modified, or
 *             distributed for any purpose whatever.
 * Filename:   peg.h
 * Purpose:    A reimplementation, in C, of exactly as much of the TatSu
 *             parser runtime (tatsu/contexts.py, tatsu/ast.py) as the
 *             generated parser for the AP-101S grammar uses.
 * Contact:    info@sandroid.org
 * Refer to:   https://tatsu.readthedocs.io/
 *
 * WHY THIS IS A REIMPLEMENTATION AND NOT A REDESIGN.  The assembler does not
 * consume an abstract syntax tree of its own devising; it consumes TatSu's
 * concrete syntax tree, and it recognises the parts of it by SHAPE.  Sixty-odd
 * places in expressions.py and model101.py read a parse result with tests like
 *
 *     len(expression) == 5 and expression[1] == "(" and expression[4] == ")"
 *
 * so the tree this produces has to be the same tree, node for node, including
 * the three distinctions Python draws that C does not:
 *
 *   - a tuple is what a rule returns when it has no named elements, and a
 *     LIST is what an accumulating capture returns;
 *   - `tatsu.contexts.closure` is a list SUBCLASS, and TatSu's own `is_list`
 *     is `type(o) is list`, an exact test, so a closure is NOT a list to the
 *     parser -- which is the entire reason a `{ ... }` repetition becomes one
 *     element of the enclosing sequence rather than being spread across it;
 *   - an AST is an insertion-ordered dict whose declared keys are seeded ahead
 *     of its captured ones by `_define`.
 *
 * The primitives below are the ones the generated parser actually calls, and
 * no others.  A survey of parser_asm.py finds exactly: _token, _pattern,
 * _check_eof, _choice, _option, _optional, _group, _closure, _define,
 * name_last_node, add_last_node_to_name, _error, and rule invocation.  There
 * is no cut, no lookahead, no left recursion, no gather and no semantic
 * action anywhere in it, so none of that machinery is here.
 *
 * FAILURE IS A LONGJMP.  TatSu signals a failed parse with an exception that
 * unwinds through the nested context managers, and `_option` is the only place
 * that catches one and carries on.  Everything else needs its state unwound
 * rather than inspected, and all of that state lives in the context's explicit
 * stacks -- so an option records the stack depths on the way in and truncates
 * to them on the way out, which is both simpler and faster than a handler at
 * every level.
 */

#ifndef ASM101SA_PEG_H
#define ASM101SA_PEG_H

#include "common.h"
#include "val.h"

#include <setjmp.h>

typedef struct
{
  Val *ast; /* always a V_DICT, possibly empty */
  Val *cst; /* V_None when TatSu would have None */
  size_t pos;
} PegState;

typedef struct PegHandler
{
  struct PegHandler *prev;
  jmp_buf jb;
} PegHandler;

typedef struct PegCtx PegCtx;

typedef void (*PegBlock) (PegCtx *);

struct PegCtx
{
  const char *text;
  size_t len;
  size_t pos;

  PegState *states;
  size_t nstates;
  size_t capstates;

  Val *lastNode;

  /* Memoization, keyed by (position, rule).  Cleared at the start of every
     parse, exactly as TatSu's `_clear_memoization_caches` does. */
  struct MemoEntry *memo;
  size_t memoMask;
  size_t memoLen;

  PegHandler *handler; /* innermost option that may catch a failure */
  jmp_buf top;         /* the parse as a whole failed */
  int failed;

  const char *ruleName; /* innermost rule, for parseinfo */
};

/*---------------------------------------------------------------------------
 * Choice and option frames.  These are declared as locals by the macros
 * below so that setjmp is executed in the function that owns the frame, as
 * the standard requires.
 */
typedef struct
{
  jmp_buf jb;
  PegHandler *savedHandler;
} PegChoice;

typedef struct
{
  PegHandler h;
  size_t stateDepth;
  size_t pos;
  PegChoice *choice;
} PegOption;

extern PegChoice *pegCurrentChoice;

/*---------------------------------------------------------------------------
 * Context management
 */
void peg_begin (PegCtx *c, const char *text, size_t len);
void peg_end (PegCtx *c);

/* Signal a failed parse.  Never returns. */
ASM_NORETURN void peg_fail (PegCtx *c);

/*---------------------------------------------------------------------------
 * The CST/AST primitives, named as in tatsu/contexts.py.
 */
Val *peg_cst (PegCtx *c);
void peg_set_cst (PegCtx *c, Val *v);
Val *peg_ast (PegCtx *c);
void peg_append_cst (PegCtx *c, Val *node);
Val *peg_extend_cst (PegCtx *c, Val *node);
void peg_push_cst (PegCtx *c);
void peg_pop_cst (PegCtx *c);
Val *peg_merge_cst (PegCtx *c, int extend);
void peg_push_ast (PegCtx *c, int copyast);
void peg_pop_ast (PegCtx *c);
void peg_merge_ast (PegCtx *c);

/* `_define(keys, list_keys)`.  Both arrays are NULL-terminated. */
void peg_define (PegCtx *c, const char *const *keys,
                 const char *const *listKeys);
void peg_name_last_node (PegCtx *c, const char *name);
void peg_add_last_node_to_name (PegCtx *c, const char *name);

/*---------------------------------------------------------------------------
 * Terminals
 */
void peg_token (PegCtx *c, const char *token);
/* Patterns are hand-written matchers rather than a regular-expression engine;
   see pattern.c.  A matcher returns the length matched at `pos`, or -1 for no
   match.  A zero-length match is a match, as it is for a regex. */
typedef ptrdiff_t (*PegMatcher) (const char *text, size_t len, size_t pos);
void peg_pattern (PegCtx *c, PegMatcher m);
void peg_check_eof (PegCtx *c);

/*---------------------------------------------------------------------------
 * Rule invocation.  `id` indexes the memo table; `name` goes into parseinfo.
 */
Val *peg_call (PegCtx *c, int id, const char *name, PegBlock impl);

/*---------------------------------------------------------------------------
 * Repetition
 */
Val *peg_closure (PegCtx *c, PegBlock block);

/*---------------------------------------------------------------------------
 * The control-flow macros.  These reproduce, statement for statement, the
 * `with self._choice():` / `with self._option():` structure of the generated
 * Python, so that a rule transliterated from parser_asm.py can be read
 * alongside it.
 */
void peg_choice_push (PegCtx *c, PegChoice *ch);
void peg_choice_pop (PegCtx *c, PegChoice *ch);
void peg_option_enter (PegCtx *c, PegOption *op);
ASM_NORETURN void peg_option_ok (PegCtx *c, PegOption *op);
void peg_option_failed (PegCtx *c, PegOption *op);

#define PEG_CHOICE_BEGIN(c)                                                   \
  {                                                                           \
    PegChoice _pegChoice;                                                     \
    PegChoice *_pegSavedChoice = pegCurrentChoice;                            \
    peg_choice_push ((c), &_pegChoice);                                       \
    if (setjmp (_pegChoice.jb) == 0)                                          \
      {

#define PEG_CHOICE_END(c)                                                     \
    }                                                                         \
    peg_choice_pop ((c), &_pegChoice);                                        \
    pegCurrentChoice = _pegSavedChoice;                                       \
  }

#define PEG_OPTION_BEGIN(c)                                                   \
  {                                                                           \
    PegOption _pegOption;                                                     \
    peg_option_enter ((c), &_pegOption);                                      \
    if (setjmp (_pegOption.h.jb) == 0)                                        \
      {

#define PEG_OPTION_END(c)                                                     \
        peg_option_ok ((c), &_pegOption);                                     \
      }                                                                       \
    peg_option_failed ((c), &_pegOption);                                     \
  }

/* `_optional` is `with self._choice(), self._option():` and, unlike an
   explicit choice, has no `_error` after its single option. */
#define PEG_OPTIONAL_BEGIN(c) PEG_CHOICE_BEGIN (c) PEG_OPTION_BEGIN (c)
#define PEG_OPTIONAL_END(c) PEG_OPTION_END (c) PEG_CHOICE_END (c)

#define PEG_GROUP_BEGIN(c)                                                    \
  {                                                                           \
    peg_push_cst (c);

#define PEG_GROUP_END(c)                                                      \
    peg_merge_cst ((c), 1);                                                   \
  }

#endif /* ASM101SA_PEG_H */
