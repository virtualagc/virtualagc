/*
 * License:    This program is declared by its author, Ronald Burkey, to be the
 *             U.S. Public Domain, and may be freely used, modified, or
 *             distributed for any purpose whatever.
 * Filename:   peg.c
 * Purpose:    The TatSu parser runtime, reimplemented in C.
 * Contact:    info@sandroid.org
 *
 * Every function here corresponds to one in tatsu/contexts.py or tatsu/ast.py
 * and is named after it.  Where the behaviour is surprising the comment says
 * which observed parse depends on it.
 */

#include "peg.h"

PegChoice *pegCurrentChoice = NULL;

/*===========================================================================
 * Memoization
 *
 * TatSu memoizes by (position, rule, substate).  `substate` is never set by
 * anything in this grammar -- nothing calls the state-machine primitives -- so
 * it is always None and the key is just (position, rule).
 *
 * A FAILED RULE STAYS FAILED, and that falls out of the left-recursion guard
 * rather than needing its own bookkeeping:  `_invoke_rule` memoizes a failure
 * BEFORE running the body, so that a rule which re-enters itself at the same
 * position fails at once, and only success overwrites it.  A rule that simply
 * fails therefore leaves the guard behind, which is the same answer.
 */
typedef struct MemoEntry
{
  size_t pos;
  int rule;   /* -1 when the slot is empty */
  int ok;     /* 0 = failed (or guard), 1 = succeeded */
  Val *node;
  size_t newpos;
} MemoEntry;

static void
memo_clear (PegCtx *c)
{
  size_t i;
  if (c->memo == NULL)
    {
      size_t size = 4096;
      c->memo = (MemoEntry *) malloc (size * sizeof (MemoEntry));
      if (c->memo == NULL)
        fatal ("out of memory");
      c->memoMask = size - 1;
    }
  for (i = 0; i <= c->memoMask; i++)
    c->memo[i].rule = -1;
  c->memoLen = 0;
}

static void
memo_grow (PegCtx *c)
{
  size_t oldSize = c->memoMask + 1;
  MemoEntry *old = c->memo;
  size_t newSize = oldSize * 2;
  size_t i;
  c->memo = (MemoEntry *) malloc (newSize * sizeof (MemoEntry));
  if (c->memo == NULL)
    fatal ("out of memory");
  c->memoMask = newSize - 1;
  for (i = 0; i < newSize; i++)
    c->memo[i].rule = -1;
  c->memoLen = 0;
  for (i = 0; i < oldSize; i++)
    if (old[i].rule >= 0)
      {
        size_t h = (old[i].pos * 1000003u + (size_t) old[i].rule) & c->memoMask;
        while (c->memo[h].rule >= 0)
          h = (h + 1) & c->memoMask;
        c->memo[h] = old[i];
        c->memoLen++;
      }
  free (old);
}

static MemoEntry *
memo_slot (PegCtx *c, size_t pos, int rule)
{
  size_t h = (pos * 1000003u + (size_t) rule) & c->memoMask;
  for (;;)
    {
      if (c->memo[h].rule < 0)
        return &c->memo[h];
      if (c->memo[h].rule == rule && c->memo[h].pos == pos)
        return &c->memo[h];
      h = (h + 1) & c->memoMask;
    }
}

/*===========================================================================
 * Context
 */
static void
states_reserve (PegCtx *c, size_t need)
{
  if (need <= c->capstates)
    return;
  {
    size_t cap = c->capstates ? c->capstates * 2 : 64;
    PegState *p;
    while (cap < need)
      cap *= 2;
    p = (PegState *) realloc (c->states, cap * sizeof (PegState));
    if (p == NULL)
      fatal ("out of memory");
    c->states = p;
    c->capstates = cap;
  }
}

void
peg_begin (PegCtx *c, const char *text, size_t len)
{
  c->text = text;
  c->len = len;
  c->pos = 0;
  c->nstates = 0;
  c->lastNode = V_None;
  c->handler = NULL;
  c->failed = 0;
  c->ruleName = NULL;
  memo_clear (c);
  states_reserve (c, 1);
  c->states[0].ast = val_dict ();
  c->states[0].cst = V_None;
  c->states[0].pos = 0;
  c->nstates = 1;
}

void
peg_end (PegCtx *c)
{
  (void) c;
}

void
peg_fail (PegCtx *c)
{
  if (c->handler != NULL)
    longjmp (c->handler->jb, 1);
  c->failed = 1;
  longjmp (c->top, 1);
}

/*===========================================================================
 * CST and AST
 */
static PegState *
state (PegCtx *c)
{
  return &c->states[c->nstates - 1];
}

Val *
peg_cst (PegCtx *c)
{
  return state (c)->cst;
}

void
peg_set_cst (PegCtx *c, Val *v)
{
  state (c)->cst = v == NULL ? V_None : v;
}

Val *
peg_ast (PegCtx *c)
{
  return state (c)->ast;
}

/* tatsu: _copy_node -- a plain list is copied, anything else is not.  A
   `closure` is deliberately NOT copied, `is_list` being an exact type test. */
static Val *
copy_node (Val *node)
{
  if (val_is_none (node))
    return V_None;
  if (val_is_exact_list (node))
    return val_retype (node, V_LIST);
  return node;
}

void
peg_append_cst (PegCtx *c, Val *node)
{
  PegState *s = state (c);
  Val *previous = s->cst;
  c->lastNode = node == NULL ? V_None : node;
  if (val_is_none (previous))
    s->cst = copy_node (node);
  else if (val_is_exact_list (previous))
    val_append (previous, node == NULL ? V_None : node);
  else
    {
      Val *l = val_seq (V_LIST);
      val_append (l, previous);
      val_append (l, node == NULL ? V_None : node);
      s->cst = l;
    }
}

Val *
peg_extend_cst (PegCtx *c, Val *node)
{
  PegState *s = state (c);
  Val *previous;
  c->lastNode = node == NULL ? V_None : node;
  if (val_is_none (node))
    return V_None;
  previous = s->cst;
  if (val_is_none (previous))
    s->cst = copy_node (node);
  else if (val_is_exact_list (node))
    {
      if (val_is_exact_list (previous))
        val_extend (previous, node);
      else
        {
          Val *l = val_seq (V_LIST);
          val_append (l, previous);
          val_extend (l, node);
          s->cst = l;
        }
    }
  else if (val_is_exact_list (previous))
    val_append (previous, node);
  else
    {
      Val *l = val_seq (V_LIST);
      val_append (l, previous);
      val_append (l, node);
      s->cst = l;
    }
  return node;
}

void
peg_push_cst (PegCtx *c)
{
  Val *ast = state (c)->ast;
  states_reserve (c, c->nstates + 1);
  c->states[c->nstates].ast = ast; /* shared, as TatSu shares it */
  c->states[c->nstates].cst = V_None;
  c->states[c->nstates].pos = 0;
  c->nstates++;
}

void
peg_pop_cst (PegCtx *c)
{
  Val *ast = state (c)->ast;
  c->nstates--;
  state (c)->ast = ast;
}

Val *
peg_merge_cst (PegCtx *c, int extend)
{
  Val *cst = state (c)->cst;
  peg_pop_cst (c);
  if (extend)
    peg_extend_cst (c, cst);
  else
    peg_append_cst (c, cst);
  return cst;
}

void
peg_push_ast (PegCtx *c, int copyast)
{
  Val *ast = copyast ? val_copy (state (c)->ast) : val_dict ();
  state (c)->pos = c->pos;
  states_reserve (c, c->nstates + 1);
  c->states[c->nstates].ast = ast;
  c->states[c->nstates].cst = V_None;
  c->states[c->nstates].pos = c->pos;
  c->nstates++;
}

void
peg_pop_ast (PegCtx *c)
{
  c->nstates--;
  c->pos = state (c)->pos;
}

void
peg_merge_ast (PegCtx *c)
{
  size_t pos = c->pos;
  Val *ast = state (c)->ast;
  Val *cst = state (c)->cst;
  c->nstates--;
  state (c)->ast = ast;
  peg_extend_cst (c, cst);
  c->pos = pos;
}

/*---------------------------------------------------------------------------
 * `_define`.  A fresh AST is built with the declared keys -- plain ones set to
 * None and accumulating ones to [] -- and the working AST is then merged over
 * it.  The ORDER matters: the declared keys come first, and `describeExpression`
 * walks an AST's items in order to rebuild the text of an expression for a
 * diagnostic.
 */
void
peg_define (PegCtx *c, const char *const *keys, const char *const *listKeys)
{
  Val *ast = val_dict ();
  Val *old = state (c)->ast;
  size_t i;
  if (keys != NULL)
    for (i = 0; keys[i] != NULL; i++)
      if (!val_dhas (ast, keys[i]))
        val_dset (ast, keys[i], V_None);
  if (listKeys != NULL)
    for (i = 0; listKeys[i] != NULL; i++)
      if (!val_dhas (ast, listKeys[i]))
        val_dset (ast, listKeys[i], val_seq (V_LIST));
  val_dupdate (ast, old);
  state (c)->ast = ast;
}

/* tatsu AST._set.  Note that it REPLACES the value with a new list rather than
   appending to the old one, so nothing that captured the previous list sees
   the addition. */
static void
ast_set (PegCtx *c, const char *name, Val *value, int forceList)
{
  Val *ast = state (c)->ast;
  Val *previous = val_dget (ast, name);
  Val *newValue;
  if (value == NULL)
    value = V_None;
  if (previous == NULL || val_is_none (previous))
    {
      if (forceList)
        {
          newValue = val_seq (V_LIST);
          val_append (newValue, value);
        }
      else
        newValue = value;
    }
  else if (val_is_exact_list (previous))
    {
      newValue = val_retype (previous, V_LIST);
      val_append (newValue, value);
    }
  else
    {
      newValue = val_seq (V_LIST);
      val_append (newValue, previous);
      val_append (newValue, value);
    }
  val_dset (ast, name, newValue);
}

void
peg_name_last_node (PegCtx *c, const char *name)
{
  ast_set (c, name, c->lastNode, 0);
}

void
peg_add_last_node_to_name (PegCtx *c, const char *name)
{
  ast_set (c, name, c->lastNode, 1);
}

/*===========================================================================
 * Terminals.
 *
 * `_next_token` is a no-op for this grammar:  the parser is configured with
 * whitespace='' and a comment pattern that cannot match, so there is nothing
 * to skip.  `nameguard` is off as well -- the config sets namechars='' -- so a
 * literal token is a plain prefix comparison, and 'OR' matches the start of
 * 'ORDER'.  Both were confirmed against the running parser rather than assumed.
 */
void
peg_token (PegCtx *c, const char *token)
{
  size_t n = strlen (token);
  if (c->pos + n > c->len || memcmp (c->text + c->pos, token, n) != 0)
    peg_fail (c);
  c->pos += n;
  peg_append_cst (c, val_str (token));
}

void
peg_pattern (PegCtx *c, PegMatcher m)
{
  ptrdiff_t n = m (c->text, c->len, c->pos);
  Val *v;
  if (n < 0)
    peg_fail (c);
  v = val_strn (c->text + c->pos, (size_t) n);
  c->pos += (size_t) n;
  peg_append_cst (c, v);
}

void
peg_check_eof (PegCtx *c)
{
  if (c->pos != c->len)
    peg_fail (c);
}

/*===========================================================================
 * Rule invocation
 */
Val *
peg_call (PegCtx *c, int id, const char *name, PegBlock impl)
{
  MemoEntry *slot;
  Val *node;

  c->lastNode = V_None;

  slot = memo_slot (c, c->pos, id);
  if (slot->rule >= 0)
    {
      if (!slot->ok)
        peg_fail (c);
      c->pos = slot->newpos;
      peg_append_cst (c, slot->node);
      return slot->node;
    }

  /* The left-recursion guard.  It doubles as the failure memo:  a rule that
     fails leaves this behind, so the next attempt at the same position fails
     without re-running the body. */
  slot->rule = id;
  slot->pos = c->pos;
  slot->ok = 0;
  slot->node = V_None;
  slot->newpos = c->pos;
  c->memoLen++;
  if (c->memoLen * 2 > c->memoMask + 1)
    {
      memo_grow (c);
      slot = memo_slot (c, c->pos, id);
    }

  {
    size_t startPos = c->pos;
    peg_push_ast (c, 0);
    impl (c);

    /* _get_node */
    {
      Val *ast = state (c)->ast;
      if (val_dlen (ast) != 0)
        {
          Val *info = val_dict ();
          val_dset_int (info, "pos", (asmint) startPos);
          val_dset_int (info, "endpos", (asmint) c->pos);
          val_dset_str (info, "rule", name);
          val_dset (ast, "parseinfo", info);
          node = ast;
        }
      else
        {
          Val *cst = state (c)->cst;
          node = val_is_exact_list (cst) ? val_retype (cst, V_TUPLE) : cst;
        }
    }
    slot = memo_slot (c, startPos, id);
    slot->rule = id;
    slot->pos = startPos;
    slot->ok = 1;
    slot->node = node;
    slot->newpos = c->pos;
    peg_pop_ast (c);
    c->pos = slot->newpos;
  }

  peg_append_cst (c, node);
  return node;
}

/*===========================================================================
 * Choice and option
 */
void
peg_choice_push (PegCtx *c, PegChoice *ch)
{
  ch->savedHandler = c->handler;
  pegCurrentChoice = ch;
  c->lastNode = V_None;
}

void
peg_choice_pop (PegCtx *c, PegChoice *ch)
{
  c->handler = ch->savedHandler;
}

void
peg_option_enter (PegCtx *c, PegOption *op)
{
  c->lastNode = V_None;
  op->choice = pegCurrentChoice;
  op->stateDepth = c->nstates;
  op->pos = c->pos;
  /* _try: push a copy of the working AST, so that names captured by an option
     that then fails do not survive into the next one. */
  peg_push_ast (c, 1);
  c->lastNode = V_None;
  op->h.prev = c->handler;
  c->handler = &op->h;
}

void
peg_option_ok (PegCtx *c, PegOption *op)
{
  c->handler = op->h.prev;
  peg_merge_ast (c);
  /* `raise OptionSucceeded`, which the enclosing choice suppresses -- skipping
     every option after this one. */
  longjmp (op->choice->jb, 1);
}

void
peg_option_failed (PegCtx *c, PegOption *op)
{
  c->handler = op->h.prev;
  /*
   * THE ENCLOSING CHOICE HAS TO BE UNWOUND TOO, and forgetting it is a crash
   * rather than a wrong answer.  `pegCurrentChoice` names the choice a
   * succeeding option must longjmp back to, and a failure that arrives here
   * from deep inside another rule has left it naming a choice in a frame that
   * has since been abandoned -- `variable = subvar variable | ...` reaches
   * that on its very first recursion.  The next option of THIS choice would
   * then capture the dead frame and longjmp into it when it succeeded.
   *
   * Restoring it here is right because an option that has failed leaves us
   * back in the choice the option belongs to, which is exactly `op->choice`.
   */
  pegCurrentChoice = op->choice;
  c->nstates = op->stateDepth;
  c->pos = op->pos;
}

/*===========================================================================
 * Repetition
 *
 * `_isolate` and `_repeat` from tatsu/contexts.py, and then `_closure` built
 * from them.  The shape is worth keeping exactly:  the first iteration runs
 * inside an `_optional` and is wrapped by `self.cst = [self.cst]`, while every
 * later one runs through `_isolate`, and the two paths produce the same list
 * only because `_extend_cst` and `_append_cst` differ in just the right way.
 */
static void
peg_isolate (PegCtx *c, PegBlock block)
{
  Val *cst;
  peg_push_cst (c);
  block (c);
  cst = state (c)->cst;
  peg_pop_cst (c);
  if (val_is_exact_list (cst))
    cst = val_retype (cst, V_CLOSURE);
  peg_append_cst (c, cst);
}

static void
peg_repeat (PegCtx *c, PegBlock block)
{
  for (;;)
    {
      volatile int completed = 0;
      PEG_CHOICE_BEGIN (c)
      PEG_OPTION_BEGIN (c)
      {
        size_t p = c->pos;
        peg_isolate (c, block);
        if (c->pos == p)
          peg_fail (c); /* 'empty closure' */
      }
      PEG_OPTION_END (c)
      completed = 1;
      PEG_CHOICE_END (c)
      if (completed)
        return;
    }
}

Val *
peg_closure (PegCtx *c, PegBlock block)
{
  peg_push_cst (c);
  peg_set_cst (c, val_seq (V_LIST));
  PEG_OPTIONAL_BEGIN (c)
  {
    Val *wrapper;
    block (c);
    wrapper = val_seq (V_LIST);
    val_append (wrapper, state (c)->cst);
    peg_set_cst (c, wrapper);
  }
  PEG_OPTIONAL_END (c)
  peg_repeat (c, block);
  peg_set_cst (c, val_retype (state (c)->cst, V_CLOSURE));
  return peg_merge_cst (c, 1);
}
