/*
 * License:    This program is declared by its author, Ronald Burkey, to be the
 *             U.S. Public Domain, and may be freely used, modified, or
 *             distributed for any purpose whatever.
 * Filename:   expressions.c
 * Purpose:    Expression evaluation and symbolic variables.
 * Contact:    info@sandroid.org
 *
 * A transliteration of expressions.py.  The long explanatory comments there
 * record why particular shapes are recognised the way they are, and where one
 * of them is load-bearing it is repeated here rather than left behind.
 */

#include "expressions.h"
#include "ebcdic.h"
#include "fieldparser.h"
#include "pyutil.h"

Val *definedNormalSymbols = NULL;
Val *svGlobals = NULL;
Val *svGlobalLocals = NULL;
Val *readTimeSymbols = NULL;
Val *svImplicitArrays = NULL;

static asmint errorCount = 0;
static asmint maxSeverity = 0;
static Val *programSymtab = NULL;
static Val *emptyDict = NULL;

void
expressions_init (void)
{
  definedNormalSymbols = val_dict ();
  svGlobals = val_dict ();
  readTimeSymbols = val_dict ();
  svImplicitArrays = val_dict ();
  emptyDict = val_dict ();
  programSymtab = emptyDict;
  /* svGlobalLocals = { "parent": [None, 0, 0, None] }, for debugging only. */
  svGlobalLocals = val_dict ();
  {
    Val *parent = val_seq (V_LIST);
    val_append (parent, V_None);
    val_append (parent, val_int (0));
    val_append (parent, val_int (0));
    val_append (parent, V_None);
    val_dset (svGlobalLocals, "parent", parent);
  }
}

Val *
scratchProperties (void)
{
  Val *p = val_dict ();
  val_dset (p, "errors", val_seq (V_LIST));
  return p;
}

void
asmError (Val *properties, const char *msg, asmint severity)
{
  Val *errors;
  if (severity > maxSeverity)
    maxSeverity = severity;
  errorCount += 1;
  if (properties == NULL)
    return;
  errors = val_dget (properties, "errors");
  if (!val_is_seq (errors))
    {
      errors = val_seq (V_LIST);
      val_dset (properties, "errors", errors);
    }
  val_append (errors,
              val_str (py_format ("(Pass %lld, Severity %lld) %s",
                                  (long long) val_dget_int (svGlobals,
                                                            "_passCount", 0),
                                  (long long) severity, msg)));
}

void
getErrorCount (asmint *count, asmint *maxSev)
{
  *count = errorCount;
  *maxSev = maxSeverity;
}

void
setErrorCounters (asmint count, asmint maxSev)
{
  errorCount = count;
  maxSeverity = maxSev;
}

void
setProgramSymtab (Val *table)
{
  programSymtab = table;
}

/*
 * ATTRIBUTES OF SYMBOLS DEFINED DURING THE SOURCE READ.  The symbol table
 * proper does not exist while the source is being read, so a macro that asks
 * for an attribute of a symbol an EARLIER macro generated has nowhere to look.
 * `readTimeSymbols` is consulted only as a FALLBACK, so once `symtab` is
 * populated the real entry always wins.
 */
Val *
symbolEntry (const char *name, Val *symtab)
{
  Val *entry;
  if (name == NULL)
    return NULL;
  entry = val_dget (symtab, name);
  if (entry != NULL && !val_is_none (entry))
    return entry;
  entry = val_dget (readTimeSymbols, name);
  if (entry != NULL && !val_is_none (entry))
    return entry;
  return NULL;
}

/*
 * The text inside a `characterTerm`, which the grammar writes as
 *     characterTerm = "C'" <any run of non-quotes> "'" ;
 * and hands over as the three-element sequence ("C'", text, "'").  Returns
 * NULL if it does not have that shape.
 *
 * JOINING THE TOKENS IS NOT THE SAME THING and was what went wrong:  it
 * rebuilds the whole term, `C'#'`, so taking its first character answered 'C'
 * for every three-operand EQU in the corpus.
 */
const char *
characterTermValue (Val *ast)
{
  if (val_is_seq (ast) && val_len (ast) == 3 && val_eq_str (val_get (ast, 0), "C'")
      && val_eq_str (val_get (ast, 2), "'"))
    return val_cstr (val_get (ast, 1));
  return NULL;
}

Val *
evalQuietly (Val *expression, Val *svLocals, Val *symtab)
{
  /*
   * Evaluate WITHOUT recording a diagnostic or counting an error.  This is for
   * speculative evaluation during the source read, where most operands
   * legitimately cannot be evaluated yet -- `FOO EQU BAR+4` names a symbol no
   * pass has defined -- and saying so would be wrong.
   *
   * Saving and restoring the counters is not decoration.  `error` bumps
   * `maxSeverity` whatever severity it is given, and `maxSeverity` decides the
   * assembler's exit status, so a speculative evaluation that merely FAILED
   * would have failed the assembly.
   */
  asmint savedCount = errorCount, savedSeverity = maxSeverity;
  Val *value = evalArithmeticExpression (expression, svLocals,
                                         scratchProperties (),
                                         symtab != NULL ? symtab : emptyDict,
                                         NULL, 0);
  errorCount = savedCount;
  maxSeverity = savedSeverity;
  return value;
}

/*===========================================================================
 * Macro arguments and sublists
 */
char *
renderMacroArgument (Val *value)
{
  if (val_is_sublist (value))
    {
      StrBuf b;
      size_t i;
      sb_init (&b);
      sb_add (&b, "(");
      for (i = 0; i < val_len (value); i++)
        {
          if (i)
            sb_add (&b, ",");
          sb_add (&b, renderMacroArgument (val_get (value, i)));
        }
      sb_add (&b, ")");
      return sb_take (&b);
    }
  if (val_is_none (value))
    return arena_strdup (ARENA_MAIN, "");
  if (val_is_bool (value))
    return arena_strdup (ARENA_MAIN, val_truthy (value) ? "1" : "0");
  if (val_is_str (value))
    return arena_strdup (ARENA_MAIN, val_cstr (value));
  return val_str_of (value);
}

Val *
subscriptMacroArgument (Val *value, Val *indices)
{
  size_t k;
  for (k = 0; k < val_len (indices); k++)
    {
      asmint index = val_as_int (val_get (indices, k));
      if (!val_is_sublist (value))
        {
          Val *wrapped = val_seq (V_SUBLIST);
          val_append (wrapped, value);
          value = wrapped;
        }
      if (index < 1 || (size_t) index > val_len (value))
        return val_str ("");
      value = val_get (value, (size_t) (index - 1));
    }
  return value;
}

asmint
countMacroArgument (Val *value)
{
  if (val_is_sublist (value))
    return (asmint) val_len (value);
  return 1;
}

/*
 * Whether a value can be used as an arithmetic term, and what it is worth if
 * so.  GC26-3758-3 p.19:  a character string may be used as an arithmetic term
 * when it represents a valid self-defining term, and "a null value is treated
 * as zero".  That leaves exactly three cases -- null, which is zero; a
 * self-defining term, which is its value; and anything else, including a whole
 * sublist, which is a program error to diagnose rather than something to
 * coerce.
 */
int
selfDefiningTerm (Val *value, asmint *out)
{
  const char *s;
  char *stripped;
  size_t n;
  if (val_is_bool (value))
    {
      *out = val_truthy (value) ? 1 : 0;
      return 1;
    }
  if (val_is_int (value))
    {
      *out = val_as_int (value);
      return 1;
    }
  if (!val_is_str (value))
    return 0;
  stripped = py_strip (val_cstr (value));
  s = stripped;
  n = strlen (s);
  if (n == 0)
    {
      *out = 0;
      return 1;
    }
  if (n >= 3 && s[0] == 'X' && s[1] == '\'' && s[n - 1] == '\'')
    {
      int ok = 0;
      char *inner = arena_strndup (ARENA_MAIN, s + 2, n - 3);
      asmint v = py_atoi_base (inner, 16, &ok);
      if (!ok)
        return 0;
      *out = v;
      return 1;
    }
  if (n >= 3 && s[0] == 'B' && s[1] == '\'' && s[n - 1] == '\'')
    {
      int ok = 0;
      char *inner = arena_strndup (ARENA_MAIN, s + 2, n - 3);
      asmint v = py_atoi_base (inner, 2, &ok);
      if (!ok)
        return 0;
      *out = v;
      return 1;
    }
  if (n >= 3 && s[0] == 'C' && s[1] == '\'' && s[n - 1] == '\'')
    {
      asmint v = 0;
      size_t i;
      for (i = 2; i + 1 < n; i++)
        {
          unsigned char c = (unsigned char) s[i];
          if (c >= 128)
            return 0; /* IndexError in the Python, caught there */
          v = (asmint) (((asmuint) v << 8) | asciiToEbcdic[c]);
        }
      *out = v;
      return 1;
    }
  if (py_isdigit (s)
      || ((s[0] == '+' || s[0] == '-') && py_isdigit (s + 1)))
    {
      int ok = 0;
      asmint v = py_atoi_base (s, 10, &ok);
      if (!ok)
        return 0;
      *out = v;
      return 1;
    }
  return 0;
}

int
isMacroArgument (const char *name, Val *value, Val *svLocals)
{
  if (name != NULL && strcmp (name, "&SYSLIST") == 0)
    return 1;
  if (val_is_sublist (value))
    return 1;
  if (name != NULL)
    {
      char *meta = py_concat ("_", name);
      if (val_dhas (svLocals, meta))
        return 1;
    }
  return 0;
}

/*===========================================================================
 * AST helpers
 */
Val *
unroll (Val *expression)
{
  while (val_is_seq (expression))
    {
      size_t n = val_len (expression);
      if (n == 1)
        expression = val_get (expression, 0);
      else if (n > 0 && val_is_listlike (val_get (expression, n - 1))
               && val_len (val_get (expression, n - 1)) == 0)
        expression = val_slice (expression, 0, (ptrdiff_t) n - 1);
      else if (n == 4 && val_eq_str (val_get (expression, 0), "(")
               && val_is_listlike (val_get (expression, 2))
               && val_len (val_get (expression, 2)) == 0
               && val_eq_str (val_get (expression, 3), ")"))
        expression = val_get (expression, 1);
      else
        break;
    }
  return expression;
}

/* Python indexing that raises IndexError, including into a string, since
   `astFlattenList` reaches that case for malformed input. */
static Val *
pyindex (Val *v, size_t i)
{
  if (val_is_seq (v))
    return i < val_len (v) ? val_get (v, i) : NULL;
  if (val_is_str (v))
    return i < val_strlen (v) ? val_strn (val_cstr (v) + i, 1) : NULL;
  return NULL;
}

/*
 * Rules of the form `X { ',' X }` create an AST that looks like
 *     ( AST1, [ [',', AST2], [',', AST3], ... ] )
 * and this turns it into the flat [ AST1, AST2, AST3, ... ] the rest of the
 * assembler wants.
 */
Val *
astFlattenList (Val *ast)
{
  Val *flattened;
  Val *rest;
  size_t i;
  if (val_is_listlike (ast) && val_len (ast) == 0)
    return val_seq (V_LIST);
  flattened = val_seq (V_LIST);
  {
    Val *first = pyindex (ast, 0);
    if (first == NULL)
      goto bad;
    val_append (flattened, first);
  }
  rest = pyindex (ast, 1);
  if (rest == NULL)
    goto bad;
  if (val_is_seq (rest))
    {
      for (i = 0; i < val_len (rest); i++)
        {
          Val *e = pyindex (val_get (rest, i), 1);
          if (e == NULL)
            goto bad;
          val_append (flattened, e);
        }
    }
  else if (val_is_str (rest))
    {
      for (i = 0; i < val_strlen (rest); i++)
        goto bad; /* a one-character element has no [1] */
    }
  else
    goto bad;
  return flattened;

bad:
  printf ("Implementation error: AST for X{',',X} not appropriate\n");
  exit (1);
}

/*
 * Render a parsed expression back into something close to the source text it
 * came from, for use in diagnostics.  The AST is mostly nested lists of the
 * original tokens, so flattening it recovers the text well enough to identify
 * which statement is at fault -- which is the whole difficulty with a message
 * like "Eval error type 3", that names nothing at all.
 */
static void
describeInto (StrBuf *b, Val *expression, int depth)
{
  size_t i;
  if (depth > 12)
    {
      sb_add (b, "...");
      return;
    }
  if (val_is_str (expression))
    {
      sb_add (b, val_cstr (expression));
      return;
    }
  if (val_is_dict (expression))
    {
      for (i = 0; i < val_dlen (expression); i++)
        {
          const char *k = val_dkey (expression, i);
          if (strcmp (k, "parseinfo") == 0)
            continue;
          describeInto (b, val_dval (expression, i), depth + 1);
        }
      return;
    }
  if (val_is_seq (expression))
    {
      for (i = 0; i < val_len (expression); i++)
        describeInto (b, val_get (expression, i), depth + 1);
      return;
    }
  if (val_is_none (expression))
    return;
  sb_add (b, val_str_of (expression));
}

char *
describeExpression (Val *expression)
{
  StrBuf b;
  sb_init (&b);
  describeInto (&b, expression, 0);
  return sb_take (&b);
}

/*===========================================================================
 * Subscripts
 */
Val *
subscriptList (Val *first, Val *rest, Val *svLocals, Val *properties,
               Val *symtab, Val *star, asmint severity)
{
  Val *expressions = val_seq (V_LIST);
  Val *indices = val_seq (V_LIST);
  size_t i;
  val_append (expressions, first);
  for (i = 0; i < val_len (rest); i++)
    {
      Val *e = val_get (rest, i);
      if (val_is_seq (e) && val_len (e) == 2 && val_eq_str (val_get (e, 0), ","))
        val_append (expressions, val_get (e, 1));
      else
        {
          asmError (properties,
                    py_format ("Unrecognized subscript %s", val_str_of (e)),
                    severity);
          return NULL;
        }
    }
  for (i = 0; i < val_len (expressions); i++)
    {
      Val *e = val_get (expressions, i);
      Val *n = evalArithmeticExpression (e, svLocals, properties, symtab, star,
                                         severity);
      if (n == NULL)
        {
          asmError (properties,
                    py_format ("Cannot evaluate subscript %s", val_str_of (e)),
                    severity);
          return NULL;
        }
      val_append (indices, n);
    }
  return indices;
}

/*
 * WHETHER A MACRO MAY SEE A GLOBAL, which is only where it declared GBLx
 * itself, plus the two the ASSEMBLER seeds rather than the source.
 *
 * `svGlobals` is one dictionary for the whole assembly, so before this a name
 * declared GBLx ANYWHERE was visible EVERYWHERE, and a macro that never
 * mentioned the name still found it.  BILDNEW5 is where that shows: MACSMITH
 * declares `GBLC ...&L(264)...`, POS declares only &LA and &TA and then uses
 * &L as a scalar, and POS was handed MACSMITH's 264-element array.  &L then
 * never took a value, `AIF (&L GE 0)` could not be evaluated, and XPOS was
 * passed the literal text `-&L`, reaching the DC parser as `FL.11'-&L'`.
 * MENU12 is the control: it invokes POS 23 times and assembles clean, because
 * it does not COPY MACSMITH and so nothing declares the global.
 *
 * THIS DOES NOT COLLAPSE GBLx INTO LCLx.  They still denote different storage
 * -- GBLx binds the name to one shared cell that persists across invocations
 * and is seen by every macro declaring it, LCLx makes a fresh cell per
 * invocation.  Only reaching the shared cell now requires saying so.
 *
 * THE TWO EXEMPTIONS ARE NOT A CONVENIENCE.  &SYSPARM is a system variable
 * symbol, available without declaration by definition, and RUNASM's ACOSH is
 * the module that proves it: with the exemption missing it went from 0 bytes
 * mismatched to 59.  &ASM101S is seeded deliberately so a source file can
 * write `AIF (&ASM101S)` with no declaration -- the whole gated-RTL-fix
 * mechanism depends on reading it bare, and --no-rtl-fixes flips it.
 */
#define GLOBALS_DECLARED "_globalsDeclared"

static int
svGlobalVisible (const char *name, Val *svLocals)
{
  Val *declared;
  if (!val_dhas (svGlobals, name))
    return 0;
  if (strcmp (name, "&SYSPARM") == 0 || strcmp (name, "&ASM101S") == 0)
    return 1;
  declared = val_dget (svLocals, GLOBALS_DECLARED);
  return declared != NULL && val_dhas (declared, name);
}

/*===========================================================================
 * svReplace
 */
static int
isSvLetter (char c)
{
  return (c >= 'A' && c <= 'Z') || c == '#' || c == '$' || c == '@';
}

static int
isSvLetterOrDigit (char c)
{
  return isSvLetter (c) || (c >= '0' && c <= '9');
}

/*
 * The compiled pattern is
 *     (?<!&)&[A-Z#$@][A-Z#$@0-9]*(?![#@_$A-Z0-9])
 * Since the trailing character class of the star and the lookahead's set
 * differ only by `_`, backtracking can never rescue a match whose follower is
 * in that set:  a shorter match ends on a character the star had consumed,
 * which is in the set too.  So the match succeeds exactly when the greedy
 * match is not followed by an underscore.
 */
static int
svMatchAt (const char *text, size_t n, size_t pos, size_t *endOut)
{
  size_t end;
  if (text[pos] != '&')
    return 0;
  if (pos > 0 && text[pos - 1] == '&')
    return 0;
  if (pos + 1 >= n || !isSvLetter (text[pos + 1]))
    return 0;
  end = pos + 2;
  while (end < n && isSvLetterOrDigit (text[end]))
    end++;
  if (end < n && text[end] == '_')
    return 0;
  *endOut = end;
  return 1;
}

/*
 * Replace all symbolic variables in a string.
 *
 * EVERY MATCH IS READ OUT OF THE ORIGINAL TEXT, and the result is built up
 * forward.  This used to walk the matches in REVERSE and re-slice the text
 * after each replacement, on the reasoning that later replacements cannot
 * disturb earlier indexes -- true of the indexes and false of the text.  A
 * variable whose right-hand neighbour had already been replaced was re-parsed
 * against that REPLACEMENT:  in `X&OPS&CNT`, `&CNT` became `0` first, and
 * `nameSet0` then read `&OPS0` as one variable name.  That is
 * `ENTRY FIOM&OPS&CNT` in FIOMODMC, which reached the assembler as
 * `ENTRY FIOM&OPS0`.
 */
char *
svReplace (Val *properties, const char *text, Val *svLocals)
{
  const char *original = text;
  size_t n;
  size_t pos = 0;
  size_t scan;
  StrBuf out;

  if (text == NULL)
    return arena_strdup (ARENA_MAIN, "");
  if (strchr (text, '&') == NULL) /* quick test for absence */
    return arena_strdup (ARENA_MAIN, text);

  n = strlen (original);
  sb_init (&out);
  for (scan = 0; scan < n; scan++)
    {
      size_t mStart = scan, mEnd;
      size_t start, end;
      char *replacement = NULL;
      int haveReplacement = 0;
      if (!svMatchAt (original, n, scan, &mEnd))
        continue;
      scan = mEnd - 1; /* finditer's matches do not overlap */
      /* A subscripted variable consumes its own subscript, so a `&` inside
         those parentheses has already been dealt with. */
      if (mStart < pos)
        continue;

      start = mStart;
      end = mEnd;

      /* resolve() */
      {
        Val *ast = parserASM (original + start, "nameSet0");
        const char *sv;
        Val *replacementVal = NULL;
        if (ast == NULL)
          {
            asmError (properties,
                      py_format ("Cannot parse: %s", original + start), 255);
            goto emit;
          }
        sv = val_cstr (val_get (val_dget (ast, "sv"), 0));
        if (val_dhas (svLocals, sv))
          replacementVal = val_dget (svLocals, sv);
        else if (svGlobalVisible (sv, svLocals))
          replacementVal = val_dget (svGlobals, sv);
        else
          goto emit;

        if (val_dhas (ast, "exp"))
          {
            Val *expList = val_dget (ast, "exp");
            Val *indices = val_seq (V_LIST);
            size_t i;
            for (i = 0; i < val_len (expList); i++)
              {
                Val *v = evalArith (val_get (expList, i), svLocals, properties);
                if (v == NULL)
                  {
                    asmError (properties,
                              py_format ("Cannot evaluate index of %s: %s", sv,
                                         val_str_of (expList)),
                              255);
                    break;
                  }
                val_append (indices, v);
              }
            if (val_len (indices) != val_len (expList))
              goto emit;
            if (isMacroArgument (sv, replacementVal, svLocals))
              {
                if (strcmp (sv, "&SYSLIST") == 0
                    && val_as_int (val_get (indices, 0)) == 0)
                  {
                    /* &SYSLIST(0) is the name field of the macro invocation. */
                    Val *l0 = val_dget (svLocals, "&SYSLIST0");
                    replacementVal = subscriptMacroArgument (
                        l0 != NULL ? l0 : val_str (""),
                        val_slice (indices, 1, (ptrdiff_t) val_len (indices)));
                  }
                else
                  replacementVal
                      = subscriptMacroArgument (replacementVal, indices);
                end = start
                      + (size_t) val_dget_int (val_dget (ast, "parseinfo"),
                                               "endpos", 0);
              }
            else if (val_is_seq (replacementVal))
              {
                /* A SETA/SETB/SETC array, which takes exactly one subscript. */
                asmint idx;
                if (val_len (indices) != 1)
                  {
                    asmError (properties,
                              py_format ("Too many subscripts for %s", sv), 255);
                    goto emit;
                  }
                idx = val_as_int (val_get (indices, 0)) - 1;
                if (idx < 0 || (size_t) idx >= val_len (replacementVal))
                  {
                    asmError (properties,
                              py_format ("Index of %s(%lld) out of range", sv,
                                         (long long) (idx + 1)),
                              255);
                    goto emit;
                  }
                replacementVal = val_get (replacementVal, (size_t) idx);
                end = start
                      + (size_t) val_dget_int (val_dget (ast, "parseinfo"),
                                               "endpos", 0);
              }
            else
              {
                /* Not subscriptable at all, so the parentheses are not a
                   subscript:  they belong to whatever the variable is embedded
                   in, as in the address `&D(&X,&B)`. */
              }
          }

        if (end < n && original[end] == '.') /* optional "join" */
          end += 1;

        if (val_is_sublist (replacementVal))
          {
            /* K' is the length of the sublist's text, N' its entry count. */
            if (start >= 2 && original[start - 2] == 'N'
                && original[start - 1] == '\'')
              {
                start -= 2;
                replacement = py_format (
                    "%lld", (long long) countMacroArgument (replacementVal));
              }
            else if (start >= 2 && original[start - 2] == 'K'
                     && original[start - 1] == '\'')
              {
                start -= 2;
                replacement = py_format (
                    "%u",
                    (unsigned) strlen (renderMacroArgument (replacementVal)));
              }
            else
              replacement = renderMacroArgument (replacementVal);
            haveReplacement = 1;
          }
        else if (val_is_bool (replacementVal))
          {
            /* Before the int case:  a Python bool *is* an int. */
            replacement = arena_strdup (ARENA_MAIN,
                                        val_truthy (replacementVal) ? "1" : "0");
            haveReplacement = 1;
          }
        else if (val_is_int (replacementVal))
          {
            /*
             * SUBSTITUTION OF AN ARITHMETIC VALUE IS UNSIGNED.  A NEGATIVE
             * value substitutes as its magnitude and the caller writes any
             * sign it wants itself.  This is not a nicety; the macros are
             * written around it -- POS writes `XPOS -&L` for a negative
             * coordinate, and rendering the value signed made that operand
             * `--456`, which no DC can parse.
             */
            asmint v = val_as_int (replacementVal);
            asmuint mag = (v < 0) ? ((asmuint) 0 - (asmuint) v) : (asmuint) v;
            replacement = py_format ("%llu", (unsigned long long) mag);
            haveReplacement = 1;
          }
        else if (val_is_seq (replacementVal))
          {
            if (start >= 2 && original[start - 1] == '\''
                && (original[start - 2] == 'K' || original[start - 2] == 'N'))
              {
                start -= 2;
                replacement = py_format (
                    "%u", (unsigned) val_len (replacementVal));
                haveReplacement = 1;
              }
            else
              {
                asmError (properties,
                          py_format ("Cannot use array as a replacement: %s=%s",
                                     sv, val_str_of (replacementVal)),
                          255);
                goto emit;
              }
          }
        else if (val_is_str (replacementVal))
          {
            replacement = arena_strdup (ARENA_MAIN, val_cstr (replacementVal));
            haveReplacement = 1;
          }
        else
          {
            asmError (properties,
                      py_format ("Cannot use %s as a replacement for %s",
                                 val_str_of (replacementVal), sv),
                      255);
            goto emit;
          }
      }

    emit:
      if (start > pos)
        sb_addn (&out, original + pos, start - pos);
      if (haveReplacement)
        sb_add (&out, replacement);
      else
        sb_addn (&out, original + start, end - start);
      pos = end;
    }
  sb_addn (&out, original + pos, n - pos);
  return sb_take (&out);
}

/*===========================================================================
 * evalArithmeticExpression
 *
 * Evaluate an arithmetic expression to a number and return it, or NULL where
 * the Python returns None.  `star` is the value of `*`, and `severity` is the
 * severity to file any diagnostic at -- 0 on the collecting passes, where a
 * forward reference is ordinary and saying so would fail the assembly.
 *
 * The result is an INT except where the source wrote a floating-point literal,
 * which is why it is a Val and not an integer:  `=E'...'` and `=D'...'` come
 * back as floats and `evalLiteralAttributes` needs them that way.
 */

/* Arithmetic on the int-or-float pair, as Python's operators give it. */
static Val *
numAdd (Val *a, Val *b)
{
  if (val_is_float (a) || val_is_float (b))
    return val_float (val_as_float (a) + val_as_float (b));
  return val_int (ASM_ADD (val_as_int (a), val_as_int (b)));
}

static Val *
numSub (Val *a, Val *b)
{
  if (val_is_float (a) || val_is_float (b))
    return val_float (val_as_float (a) - val_as_float (b));
  return val_int (ASM_SUB (val_as_int (a), val_as_int (b)));
}

static Val *
numMul (Val *a, Val *b)
{
  if (val_is_float (a) || val_is_float (b))
    return val_float (val_as_float (a) * val_as_float (b));
  return val_int (ASM_MUL (val_as_int (a), val_as_int (b)));
}

static Val *
numDiv (Val *a, Val *b)
{
  /*
   * Assembler division is INTEGER division with the remainder discarded, and
   * division by zero yields zero rather than failing (GC28-6514-8 p.28).
   * Truncation is toward zero rather than floor, so -7/2 is -3 and not -4,
   * which is why this is not simply a floor division.
   */
  if (val_is_float (a) || val_is_float (b))
    {
      double rb = val_as_float (b);
      if (rb == 0.0)
        return val_int (0);
      {
        double q = val_as_float (a) / rb;
        return val_int ((asmint) q);
      }
    }
  return val_int (py_div_trunc (val_as_int (a), val_as_int (b)));
}

Val *
evalArith (Val *expression, Val *svLocals, Val *properties)
{
  return evalArithmeticExpression (expression, svLocals, properties, emptyDict,
                                   NULL, 255);
}

Val *
evalArithmeticExpression (Val *expression, Val *svLocals, Val *properties,
                          Val *symtab, Val *star, asmint severity)
{
  size_t n;

  if (properties == NULL)
    properties = scratchProperties ();
  if (symtab == NULL)
    symtab = emptyDict;
  if (svLocals == NULL)
    svLocals = emptyDict;

  expression = unroll (expression);

  /*---------------------------------------------------------------------
   * A so-called literal, `=X'...'` and its fellows, which the grammar hands
   * over as an AST with a `T` key naming the type.
   */
  if (val_is_dict (expression) && val_dhas (expression, "T"))
    {
      Val *literal = expression; /* kept whole; a Z literal needs A1 and A2 */
      const char *datatype = val_cstr (val_get (val_dget (expression, "T"), 0));
      Val *body = unroll (val_dget (expression, datatype));
      if (strcmp (datatype, "C") == 0)
        {
          asmError (properties,
                    py_format ("Cannot convert string '%s' to arithmetic "
                               "expression",
                               val_str_of (body)),
                    255);
          return NULL;
        }
      if (strcmp (datatype, "B") == 0)
        {
          int ok = 0;
          asmint v = py_atoi_base (val_cstr (body), 2, &ok);
          return ok ? val_int (v) : NULL;
        }
      if (strcmp (datatype, "X") == 0)
        {
          int ok = 0;
          asmint v = py_atoi_base (val_cstr (body), 16, &ok);
          return ok ? val_int (v) : NULL;
        }
      if (strcmp (datatype, "E") == 0 || strcmp (datatype, "D") == 0)
        {
          StrBuf b;
          sb_init (&b);
          describeInto (&b, body, 0);
          {
            double d = py_atof (b.s ? b.s : "");
            sb_free (&b);
            return val_float (d);
          }
        }
      if (strcmp (datatype, "F") == 0 || strcmp (datatype, "H") == 0)
        {
          /* F and H are FIXED-point types, so an integral value must come back
             as an int.  Testing with `isdigit` sent every negative one down
             the float path -- `=F'-5'` became -5.0 -- and a float in an
             address context is what raises TypeError further down. */
          StrBuf b;
          char *s;
          asmint iv;
          sb_init (&b);
          describeInto (&b, body, 0);
          s = sb_take (&b);
          if (py_parse_int (s, &iv))
            return val_int (iv);
          return val_float (py_atof (s));
        }
      if (strcmp (datatype, "Y") == 0)
        {
          /* A Y LITERAL HOLDS AN EXPRESSION, evaluated exactly as the
             generator evaluates the one in `DC Y(...)`.  The value comes back
             hashed if it is relocatable, which is what the caller wants. */
          return evalArithmeticExpression (body, svLocals, properties, symtab,
                                           star, severity);
        }
      if (strcmp (datatype, "Z") == 0)
        {
          /*
           * A ZCON literal, `=Z(,address,flags)`.  Its encoding is not
           * documented anywhere; it was derived from the original build, where
           * `DC Z(FCMTRACE,FCMTRCLG,15)` assembles to 00000F00 and
           * `=Z(,FPMXQETB+2,0)` to 00020000:
           *     bytes 0-1   the ABSOLUTE part of the address expression
           *     byte 2      the flags
           *     byte 3      reserved, always zero
           */
          Val *address = evalArithmeticExpression (val_dget (literal, "A1"),
                                                   svLocals, properties, symtab,
                                                   star, severity);
          Val *flags = evalArithmeticExpression (val_dget (literal, "A2"),
                                                 svLocals, properties, symtab,
                                                 star, severity);
          if (address == NULL || flags == NULL)
            {
              asmError (properties,
                        "Cannot evaluate the operands of a Z-type literal",
                        255);
              return NULL;
            }
          return val_int ((asmint) (((asmuint) (val_as_int (address) & 0xFFFF)
                                     << 16)
                                    | ((asmuint) (val_as_int (flags) & 0xFF)
                                       << 8)));
        }
      asmError (properties,
                py_format ("Literals =%s not implemented", datatype), 255);
      return NULL;
    }

  /*---------------------------------------------------------------------
   * A bare term.
   */
  if (val_is_str (expression))
    {
      const char *s = val_cstr (expression);
      Val *sv = NULL;
      /* A LEADING PLUS COUNTS AS A NUMBER, as a leading minus already did.
         FIOMCNTL writes `@TI +1`, and the token reached here as the string
         "+1", failed this test, and was looked up as a symbol of that name. */
      if (py_isdigit (s) || ((s[0] == '+' || s[0] == '-') && py_isdigit (s + 1)))
        {
          asmint v = 0;
          py_parse_int (s, &v);
          return val_int (v);
        }
      if (val_dhas (svLocals, s))
        sv = svLocals;
      else if (svGlobalVisible (s, svLocals))
        sv = svGlobals;
      if (sv != NULL)
        {
          Val *value = val_dget (sv, s);
          asmint out;
          if (selfDefiningTerm (value, &out))
            return val_int (out);
          asmError (properties,
                    py_format ("Cannot be interpreted as an integer value: "
                               "'%s' (%s)",
                               renderMacroArgument (value), s),
                    severity);
          return NULL;
        }
      if (strcmp (s, "*") == 0 && star != NULL)
        return star;
      if (val_dhas (symtab, s))
        {
          Val *entry = val_dget (symtab, s);
          if (val_dget_int (svGlobals, "_passCount", 0) == 3)
            {
              Val *refs = val_dget (entry, "references");
              if (refs == NULL || !val_is_seq (refs))
                {
                  refs = val_seq (V_LIST);
                  val_dset (entry, "references", refs);
                }
              val_append (refs, val_dget (properties, "n"));
            }
          if (val_dhas (entry, "value"))
            {
              Val *value = val_dget (entry, "value");
              /* The `try:` in the Python swallows a missing "dsect" or
                 "section" key, in which case the adjustment is simply not
                 made. */
              if (val_dget_int (svGlobals, "_passCount", 0) > 1
                  && val_is_int (value) && val_as_int (value) != 0
                  && val_as_int (value) != -1
                  && ASM_AND (val_as_int (value), HASHCODE_MASK) != 0
                  && val_dhas (entry, "dsect") && !val_dget_bool (entry, "dsect", 0)
                  && val_dhas (symtab, "_firstCSECT"))
                {
                  Val *firstName = val_dget (symtab, "_firstCSECT");
                  Val *first = val_dget (symtab, val_cstr (firstName));
                  Val *sectName = val_dget (entry, "section");
                  Val *sectEntry
                      = sectName != NULL && val_is_str (sectName)
                            ? val_dget (symtab, val_cstr (sectName))
                            : NULL;
                  if (first != NULL && sectEntry != NULL
                      && val_dhas (sectEntry, "preliminaryOffset")
                      && val_dhas (entry, "address"))
                    return val_int (ASM_ADD (
                        ASM_ADD (val_dget_int (first, "value", 0),
                                 val_dget_int (sectEntry, "preliminaryOffset",
                                               0)),
                        val_dget_int (entry, "address", 0)));
                }
              return value;
            }
        }
    }

  if (!val_is_seq (expression))
    {
      /* A bare term that resolved to nothing.  Having got this far it is not a
         number, not a symbolic variable, not '*', and either absent from the
         symbol table or present without a value yet -- and those two are worth
         telling apart, because the second is an ordinary forward reference on
         an early pass and the first is a real undefined symbol. */
      if (val_is_str (expression))
        {
          if (val_dhas (symtab, val_cstr (expression)))
            asmError (properties,
                      py_format ("Symbol '%s' has no value yet",
                                 val_cstr (expression)),
                      severity);
          else
            asmError (properties,
                      py_format ("Undefined symbol '%s'", val_cstr (expression)),
                      severity);
        }
      else
        asmError (properties,
                  py_format ("Not an arithmetic term: %s",
                             describeExpression (expression)),
                  severity);
      return NULL;
    }

  n = val_len (expression);

  /*---------------------------------------------------------------------
   * &NAME(subscripts)
   */
  if (n == 5 && val_eq_str (val_get (expression, 1), "(")
      && val_eq_str (val_get (expression, 4), ")")
      && val_is_str (val_get (expression, 0))
      && py_startswith (val_cstr (val_get (expression, 0)), "&"))
    {
      const char *arrayName = val_cstr (val_get (expression, 0));
      Val *arrayData;
      Val *indices;
      asmint out;
      if (val_dhas (svLocals, arrayName))
        arrayData = val_dget (svLocals, arrayName);
      else if (svGlobalVisible (arrayName, svLocals))
        arrayData = val_dget (svGlobals, arrayName);
      else
        {
          asmError (properties, py_format ("Cannot find %s", arrayName), 255);
          return NULL;
        }
      indices = subscriptList (val_get (expression, 2), val_get (expression, 3),
                               svLocals, properties, symtab, star, severity);
      if (indices == NULL)
        return NULL;
      if (isMacroArgument (arrayName, arrayData, svLocals))
        {
          Val *value;
          if (strcmp (arrayName, "&SYSLIST") == 0
              && val_as_int (val_get (indices, 0)) == 0)
            {
              Val *l0 = val_dget (svLocals, "&SYSLIST0");
              value = subscriptMacroArgument (
                  l0 != NULL ? l0 : val_str (""),
                  val_slice (indices, 1, (ptrdiff_t) val_len (indices)));
            }
          else
            value = subscriptMacroArgument (arrayData, indices);
          if (selfDefiningTerm (value, &out))
            return val_int (out);
          /* Not a coercion failure to paper over.  A sublist or a symbol has
             no arithmetic value, and saying so is the whole point:  comparing
             it cleanly would turn a loud failure into a wrong assembly. */
          asmError (properties,
                    py_format ("%s is not a self-defining term: '%s'",
                               arrayName, renderMacroArgument (value)),
                    severity);
          return NULL;
        }
      if (!val_is_exact_list (arrayData))
        {
          asmError (properties, py_format ("%s is not an array", arrayName),
                    255);
          return NULL;
        }
      if (val_len (indices) != 1)
        {
          asmError (properties,
                    py_format ("Too many subscripts for %s", arrayName), 255);
          return NULL;
        }
      {
        asmint index = val_as_int (val_get (indices, 0)) - 1;
        if (index < 0 || (size_t) index >= val_len (arrayData))
          {
            asmError (properties,
                      py_format ("Index is out of range (%lld > %u)",
                                 (long long) (index + 1),
                                 (unsigned) val_len (arrayData)),
                      255);
            return NULL;
          }
        if (selfDefiningTerm (val_get (arrayData, (size_t) index), &out))
          return val_int (out);
        asmError (properties,
                  py_format ("Cannot be interpreted as an integer value: "
                             "'%s' (%s)",
                             renderMacroArgument (
                                 val_get (arrayData, (size_t) index)),
                             arrayName),
                  severity);
        return NULL;
      }
    }

  if (n == 3 && val_eq_str (val_get (expression, 0), "(")
      && val_eq_str (val_get (expression, 2), ")"))
    return evalArithmeticExpression (val_get (expression, 1), svLocals,
                                     properties, symtab, star, severity);

  if (n == 3 && val_eq_str (val_get (expression, 0), "X'")
      && val_eq_str (val_get (expression, 2), "'"))
    {
      int ok = 0;
      asmint v = py_atoi_base (val_cstr (val_get (expression, 1)), 16, &ok);
      if (!ok)
        {
          asmError (properties,
                    py_format ("Not hexadecimal: %s",
                               val_cstr (val_get (expression, 1))),
                    severity);
          return NULL;
        }
      return val_int (v);
    }

  if (n == 3 && val_eq_str (val_get (expression, 0), "B'")
      && val_eq_str (val_get (expression, 2), "'"))
    {
      int ok = 0;
      asmint v = py_atoi_base (val_cstr (val_get (expression, 1)), 2, &ok);
      if (!ok)
        {
          asmError (properties,
                    py_format ("Not binary: %s",
                               val_cstr (val_get (expression, 1))),
                    severity);
          return NULL;
        }
      return val_int (v);
    }

  /*---------------------------------------------------------------------
   * The attribute operators, N' K' L' S' I'
   */
  if (n == 2 && val_is_str (val_get (expression, 0))
      && (val_eq_str (val_get (expression, 0), "N'")
          || val_eq_str (val_get (expression, 0), "K'")
          || val_eq_str (val_get (expression, 0), "L'")
          || val_eq_str (val_get (expression, 0), "S'")
          || val_eq_str (val_get (expression, 0), "I'")))
    {
      const char *op = val_cstr (val_get (expression, 0));
      Val *symvarVal = val_get (expression, 1);
      Val *indices = NULL;
      Val *sv;
      Val *var;
      const char *symvar;
      if (val_is_seq (symvarVal))
        {
          if (!(val_len (symvarVal) == 5
                && val_eq_str (val_get (symvarVal, 1), "(")
                && val_eq_str (val_get (symvarVal, 4), ")")))
            {
              asmError (properties,
                        py_format ("Unrecognized operand of %s: %s", op,
                                   val_str_of (symvarVal)),
                        severity);
              return NULL;
            }
          indices = subscriptList (val_get (symvarVal, 2),
                                   val_get (symvarVal, 3), svLocals, properties,
                                   symtab, star, severity);
          if (indices == NULL)
            return NULL;
          symvarVal = val_get (symvarVal, 0);
        }
      symvar = val_cstr (symvarVal);
      if (val_dhas (svLocals, symvar))
        sv = svLocals;
      else if (svGlobalVisible (symvar, svLocals))
        sv = svGlobals;
      else if (strcmp (op, "L'") == 0 && indices == NULL)
        {
          /* L' OF A PROGRAM SYMBOL, not of a symbolic variable.  This branch
             existed only for the macro-time attributes, so `L'TIOQSELF` -- a
             symbol defined by a DS in a DSECT -- was diagnosed as a missing
             symbolic variable, which is what blocks FIOCBLKS.

             A symbol that exists but carries no length attribute is NOT the
             same as one that does not exist, and the two are reported
             separately. */
          Val *entry = symbolEntry (symvar, symtab);
          if (entry == NULL)
            {
              asmError (properties,
                        py_format ("Symbol %s not found for L'", symvar),
                        severity);
              return NULL;
            }
          if (!val_dhas (entry, "lengthAttribute"))
            {
              asmError (properties,
                        py_format ("Symbol %s has no length attribute", symvar),
                        severity);
              return NULL;
            }
          return val_dget (entry, "lengthAttribute");
        }
      else
        {
          asmError (properties,
                    py_format ("Symbolic variable %s not found", symvar),
                    severity);
          return NULL;
        }
      var = val_dget (sv, symvar);
      if (indices != NULL)
        {
          if (isMacroArgument (symvar, var, sv))
            {
              if (strcmp (symvar, "&SYSLIST") == 0
                  && val_as_int (val_get (indices, 0)) == 0)
                {
                  Val *l0 = val_dget (svLocals, "&SYSLIST0");
                  var = subscriptMacroArgument (
                      l0 != NULL ? l0 : val_str (""),
                      val_slice (indices, 1, (ptrdiff_t) val_len (indices)));
                }
              else
                var = subscriptMacroArgument (var, indices);
            }
          else if (val_len (indices) != 1)
            {
              asmError (properties,
                        py_format ("Too many subscripts for %s", symvar),
                        severity);
              return NULL;
            }
          else
            {
              asmint index = val_as_int (val_get (indices, 0)) - 1;
              if (index < 0 || (size_t) index >= val_len (var))
                {
                  asmError (properties, "Index out of range", severity);
                  return NULL;
                }
              var = val_get (var, (size_t) index);
            }
        }
      {
        char *metavar = py_concat ("_", symvar);
        Val *meta = val_dhas (sv, metavar) ? val_dget (sv, metavar) : NULL;
        if (strcmp (op, "N'") == 0)
          {
            if (strcmp (symvar, "&SYSLIST") != 0
                && (meta == NULL || !val_dhas (meta, "omitted")))
              {
                asmError (properties,
                          py_format ("Not a macro parameter: %s", symvar),
                          severity);
                return NULL;
              }
            if (strcmp (symvar, "&SYSLIST") != 0
                && val_dget_bool (meta, "omitted", 0))
              return val_int (0);
            return val_int (countMacroArgument (var));
          }
        if (strcmp (op, "K'") == 0)
          {
            /* The number of characters in the value, which for a sublist is
               the width of its source text rather than its number of
               entries. */
            return val_int ((asmint) strlen (renderMacroArgument (var)));
          }
        if (strcmp (op, "L'") == 0)
          {
            /* L' OF THE SYMBOL A VARIABLE'S VALUE NAMES, not of the variable.
               POS builds the name into a SETC and then asks for its length. */
            char *name = renderMacroArgument (var);
            Val *entry = symbolEntry (name, symtab);
            if (entry == NULL)
              {
                /* Defaulting to 1 was tried and is WRONG here:  POS documents
                   that the coordinate IS the length attribute, and the caller
                   subtracts 1025, so a default silently turns every coordinate
                   into 1-1025.  A module that cannot be assembled correctly
                   must not be assembled quietly. */
                asmError (properties,
                          py_format ("Symbol %s not found for L'", name),
                          severity);
                return NULL;
              }
            if (!val_dhas (entry, "lengthAttribute"))
              {
                asmError (properties,
                          py_format ("Symbol %s has no length attribute", name),
                          severity);
                return NULL;
              }
            return val_dget (entry, "lengthAttribute");
          }
        asmError (properties, py_format ("Not yet implemented: %s", op),
                  severity);
        return NULL;
      }
    }

  /*---------------------------------------------------------------------
   * A unary sign.  Must be tested before the binary-chain branch below, which
   * reads element 0 as a left operand and element 1 as a list of (operator,
   * operand) pairs; a unary node is neither.
   */
  if (n == 2
      && (val_eq_str (val_get (expression, 0), "-")
          || val_eq_str (val_get (expression, 0), "+")))
    {
      Val *value = evalArithmeticExpression (val_get (expression, 1), svLocals,
                                             properties, symtab, star, severity);
      if (value == NULL)
        return NULL;
      if (val_eq_str (val_get (expression, 0), "-"))
        {
          if (val_is_float (value))
            return val_float (-val_as_float (value));
          return val_int (ASM_NEG (val_as_int (value)));
        }
      return value;
    }

  /*---------------------------------------------------------------------
   * term { ('+'|'-') term } and factor { ('*'|'/') factor }
   */
  if (n == 2)
    {
      Val *left = evalArithmeticExpression (val_get (expression, 0), svLocals,
                                            properties, symtab, star, severity);
      if (left != NULL)
        {
          Val *next = val_get (expression, 1);
          int chained = 0;
          if (val_is_seq (next))
            {
              size_t i;
              chained = 1;
              for (i = 0; i < val_len (next); i++)
                {
                  Val *entry = val_get (next, i);
                  if (val_is_seq (entry) && val_len (entry) == 2
                      && val_is_str (val_get (entry, 0))
                      && (val_eq_str (val_get (entry, 0), "+")
                          || val_eq_str (val_get (entry, 0), "-")
                          || val_eq_str (val_get (entry, 0), "*")
                          || val_eq_str (val_get (entry, 0), "/")))
                    continue;
                  chained = 0;
                  break;
                }
            }
          if (chained)
            {
              size_t i;
              for (i = 0; i < val_len (next); i++)
                {
                  Val *entry = val_get (next, i);
                  const char *op = val_cstr (val_get (entry, 0));
                  Val *right = evalArithmeticExpression (
                      val_get (entry, 1), svLocals, properties, symtab, star,
                      severity);
                  if (right != NULL)
                    {
                      if (op[0] == '+')
                        left = numAdd (left, right);
                      else if (op[0] == '-')
                        left = numSub (left, right);
                      else if (op[0] == '*')
                        left = numMul (left, right);
                      else if (op[0] == '/')
                        left = numDiv (left, right);
                    }
                  else
                    {
                      asmError (properties,
                                py_format ("Cannot evaluate '%s' in the "
                                           "expression '%s'",
                                           describeExpression (
                                               val_get (entry, 1)),
                                           describeExpression (expression)),
                                severity);
                      return NULL;
                    }
                }
              return left;
            }
        }
    }

  /* Nothing in the evaluator recognised the shape of this expression.  Show
     it, because the alternative -- the bare "Eval error type 3" this replaced
     -- was the commonest diagnostic in the FCOS corpus and identified
     nothing. */
  asmError (properties,
            py_format ("Cannot evaluate the expression '%s'",
                       describeExpression (expression)),
            severity);
  return NULL;
}

/*===========================================================================
 * Attributes
 *
 * Resolve the operand of a T' or D' attribute -- a bare symbol, a symbolic
 * variable, or a subscripted one such as `&SYSLIST(1)` or `&SYSLIST(&I,3)` --
 * to the text it stands for.  Returns whether it was found; `*text` is the
 * text and `*isArgument` says whether it is a macro argument rather than a SET
 * variable or an ordinary symbol.
 */
int
attributeOperand (Val *properties, Val *operand, Val *svLocals, char **textOut,
                  int *isArgumentOut)
{
  Val *indices = NULL;
  const char *name;
  Val *value;
  int isArgument;

  *textOut = arena_strdup (ARENA_MAIN, "");
  *isArgumentOut = 0;

  if (val_is_str (operand))
    {
      const char *s = val_cstr (operand);
      if (s[0] != '&')
        {
          *textOut = arena_strdup (ARENA_MAIN, s); /* an ordinary symbol */
          return 1;
        }
      name = s;
    }
  else if (val_is_seq (operand) && val_len (operand) == 5
           && val_eq_str (val_get (operand, 1), "(")
           && val_eq_str (val_get (operand, 4), ")")
           && val_is_str (val_get (operand, 0))
           && val_cstr (val_get (operand, 0))[0] == '&')
    {
      name = val_cstr (val_get (operand, 0));
      indices = subscriptList (val_get (operand, 2), val_get (operand, 3),
                               svLocals, properties, NULL, NULL, 255);
      if (indices == NULL)
        return 0;
    }
  else
    return 0;

  if (val_dhas (svLocals, name))
    value = val_dget (svLocals, name);
  else if (svGlobalVisible (name, svLocals))
    value = val_dget (svGlobals, name);
  else
    return 0;

  isArgument = isMacroArgument (name, value, svLocals);
  if (indices != NULL)
    {
      if (isArgument)
        {
          if (strcmp (name, "&SYSLIST") == 0
              && val_as_int (val_get (indices, 0)) == 0)
            {
              Val *l0 = val_dget (svLocals, "&SYSLIST0");
              value = subscriptMacroArgument (
                  l0 != NULL ? l0 : val_str (""),
                  val_slice (indices, 1, (ptrdiff_t) val_len (indices)));
            }
          else
            value = subscriptMacroArgument (value, indices);
        }
      else if (val_len (indices) == 1 && val_is_seq (value))
        {
          asmint i = val_as_int (val_get (indices, 0)) - 1;
          value = (i >= 0 && (size_t) i < val_len (value))
                      ? val_get (value, (size_t) i)
                      : val_str ("");
        }
      else
        return 0;
    }
  *textOut = renderMacroArgument (value);
  *isArgumentOut = isArgument;
  return 1;
}

/*
 * The type attribute T'.  The AP-101S macro library tests only two of its
 * values, and they are the two the manuals define for a macro argument
 * (SC26-4940 Table 58):  'O' when the operand was omitted or is null, and 'N'
 * when it is a self-defining term.  A macro argument that is neither -- a
 * symbol name, a sublist -- is 'U', undefined.
 */
const char *
typeAttribute (Val *properties, Val *operand, Val *svLocals, Val *symtab)
{
  char *text;
  int isArgument;
  int found;
  asmint dummy;
  if (symtab == NULL)
    symtab = programSymtab;
  found = attributeOperand (properties, operand, svLocals, &text, &isArgument);
  if (found && text[0] == '\0')
    {
      /* NULL IS 'O' FOR A SET SYMBOL TOO, not only for a macro argument.
         DCHAR and SCHAR copy their operand into a local SETC and then test
         `T'&C EQ 'O'` to decide whether it was supplied, so answering 'C' for
         the null value let the guard fall through and called CHAR with
         nothing.  BILDNEW5 raised that 2679 times and the original build
         raised it not once. */
      return "O";
    }
  if (!found)
    {
      /* A SYMBOL MAY CARRY ITS OWN TYPE ATTRIBUTE, given outright by the third
         operand of a three-operand EQU.  That is how the position symbols are
         typed -- PDEF writes `EQU 1,1,C'#'` -- and the POS macro branches on
         the answer. */
      Val *entry = val_is_str (operand)
                       ? symbolEntry (val_cstr (operand), symtab)
                       : NULL;
      if (entry != NULL && val_dhas (entry, "typeAttribute"))
        return val_cstr (val_dget (entry, "typeAttribute"));
      return "U";
    }
  if (!isArgument)
    {
      Val *entry = symbolEntry (text, symtab);
      if (entry != NULL && val_dhas (entry, "typeAttribute"))
        return val_cstr (val_dget (entry, "typeAttribute"));
      /* A SET SYMBOL WHOSE VALUE IS A SELF-DEFINING TERM IS 'N'.  The
         attribute follows the VALUE, not the fact that a SETC holds it, and
         the library asks this fifteen times.  Answering 'C' sent every one of
         them down its error arm. */
      if (selfDefiningTerm (val_str (text), &dummy))
        return "N";
      return "C";
    }
  if (text[0] == '\0')
    return "O";
  return selfDefiningTerm (val_str (text), &dummy) ? "N" : "U";
}

/*===========================================================================
 * Relations
 */
static int
isStringExpression (Val *expression)
{
  Val *e = unroll (expression);
  if (val_is_str (e))
    return val_eq_str (e, "'") || val_eq_str (e, "T'");
  if (val_is_seq (e) && val_len (e) > 0)
    return isStringExpression (val_get (e, 0));
  return 0;
}

static int
evaluateRelation (Val *rawLeft, const char *op, Val *rawRight, Val *svLocals,
                  Val *properties)
{
  Val *left = unroll (rawLeft);
  Val *right = unroll (rawRight);
  int leftIsString = isStringExpression (left);
  int rightIsString = isStringExpression (right);

  if (leftIsString != rightIsString)
    {
      asmError (properties, "Cannot determine int vs char for comparison", 255);
      return 0;
    }
  if (!leftIsString)
    {
      Val *valLeft = evalArith (left, svLocals, properties);
      if (valLeft != NULL)
        {
          Val *valRight = evalArith (right, svLocals, properties);
          if (valRight != NULL)
            {
              int c;
              if (val_is_float (valLeft) || val_is_float (valRight))
                {
                  double a = val_as_float (valLeft), b = val_as_float (valRight);
                  c = a < b ? -1 : (a > b ? 1 : 0);
                }
              else
                {
                  asmint a = val_as_int (valLeft), b = val_as_int (valRight);
                  c = a < b ? -1 : (a > b ? 1 : 0);
                }
              if (strcmp (op, "EQ") == 0)
                return c == 0;
              if (strcmp (op, "NE") == 0)
                return c != 0;
              if (strcmp (op, "LT") == 0)
                return c < 0;
              if (strcmp (op, "LE") == 0)
                return c <= 0;
              if (strcmp (op, "GT") == 0)
                return c > 0;
              if (strcmp (op, "GE") == 0)
                return c >= 0;
            }
          asmError (properties,
                    py_format ("Cannot evaluate relational expression %s %s %s",
                               val_str_of (rawLeft), op, val_str_of (rawRight)),
                    255);
          return 0;
        }
    }
  else
    {
      char *valLeft = evalCharacterExpression (left, svLocals, properties);
      if (valLeft != NULL)
        {
          char *valRight = evalCharacterExpression (right, svLocals, properties);
          if (valRight != NULL)
            {
              /* Recall that string comparisons prioritise string LENGTH, and
                 compare characters -- in EBCDIC collation -- only when the
                 lengths are identical. */
              size_t la = strlen (valLeft), lb = strlen (valRight);
              int cmp;
              if (la < lb)
                cmp = -1;
              else if (la > lb)
                cmp = 1;
              else
                {
                  size_t i;
                  cmp = 0;
                  for (i = 0; i < la; i++)
                    {
                      unsigned char ca = (unsigned char) valLeft[i];
                      unsigned char cb = (unsigned char) valRight[i];
                      unsigned char ea = ca < 128 ? asciiToEbcdic[ca] : 0;
                      unsigned char eb = cb < 128 ? asciiToEbcdic[cb] : 0;
                      if (ea < eb)
                        {
                          cmp = -1;
                          break;
                        }
                      if (ea > eb)
                        {
                          cmp = 1;
                          break;
                        }
                    }
                }
              if (strcmp (op, "EQ") == 0)
                return cmp == 0;
              if (strcmp (op, "NE") == 0)
                return cmp != 0;
              if (strcmp (op, "LT") == 0)
                return cmp < 0;
              if (strcmp (op, "LE") == 0)
                return cmp <= 0;
              if (strcmp (op, "GT") == 0)
                return cmp > 0;
              if (strcmp (op, "GE") == 0)
                return cmp >= 0;
            }
        }
    }
  asmError (properties,
            py_format ("Cannot evaluate relational expression %s %s %s",
                       val_str_of (rawLeft), op, val_str_of (rawRight)),
            255);
  return 0;
}

/*===========================================================================
 * Boolean expressions
 */
static int
isRelOp (Val *v)
{
  return val_eq_str (v, "EQ") || val_eq_str (v, "NE") || val_eq_str (v, "LT")
         || val_eq_str (v, "LE") || val_eq_str (v, "GT")
         || val_eq_str (v, "GE");
}

Val *
evalBooleanExpression (Val *expression, Val *svLocals, Val *properties)
{
  size_t n;
  if (properties == NULL)
    properties = scratchProperties ();
  if (svLocals == NULL)
    svLocals = emptyDict;

  expression = unroll (expression);

  /* A parenthesised sub-expression, which may have blanks inside the
     parentheses:  ( '(', blanks, expression, blanks, ')' ). */
  while (val_is_seq (expression) && val_len (expression) == 5
         && val_eq_str (val_get (expression, 0), "(")
         && val_eq_str (val_get (expression, 4), ")"))
    expression = unroll (val_get (expression, 2));

  if (val_is_str (expression))
    {
      const char *s = val_cstr (expression);
      if (strcmp (s, "0") == 0)
        return val_bool (0);
      if (strcmp (s, "1") == 0)
        return val_bool (1);
      if (s[0] == '&')
        {
          if (val_dhas (svLocals, s))
            return val_dget (svLocals, s);
          if (svGlobalVisible (s, svLocals))
            return val_dget (svGlobals, s);
          asmError (properties, py_format ("Not defined: %s", s), 255);
          return NULL;
        }
      asmError (properties,
                py_format ("Implementation error:  %s as boolean expression", s),
                255);
      return NULL;
    }
  if (!val_is_seq (expression))
    {
      asmError (properties,
                py_format ("Cannot evaluate boolean expression '%s'",
                           describeExpression (expression)),
                255);
      return NULL;
    }
  n = val_len (expression);

  if (n == 2 && val_eq_str (val_get (expression, 0), "D'"))
    {
      char *symbol;
      int isArgument;
      if (!attributeOperand (properties, val_get (expression, 1), svLocals,
                             &symbol, &isArgument))
        return val_bool (0);
      return val_bool (val_dhas (definedNormalSymbols, symbol));
    }

  /* &A(...) */
  if (n == 5 && val_is_str (val_get (expression, 0))
      && val_cstr (val_get (expression, 0))[0] == '&'
      && val_eq_str (val_get (expression, 1), "(")
      && val_eq_str (val_get (expression, 4), ")"))
    {
      const char *sv = val_cstr (val_get (expression, 0));
      Val *scope;
      const char *what;
      Val *indices;
      if (val_dhas (svLocals, sv))
        {
          scope = svLocals;
          what = "local";
        }
      else if (svGlobalVisible (sv, svLocals))
        {
          scope = svGlobals;
          what = "global";
        }
      else
        {
          asmError (properties,
                    py_format ("Symbolic variable %s not found in local or "
                               "global scope",
                               sv),
                    255);
          return NULL;
        }
      indices = subscriptList (val_get (expression, 2), val_get (expression, 3),
                               svLocals, properties, NULL, NULL, 255);
      if (indices == NULL)
        return NULL;
      if (isMacroArgument (sv, val_dget (scope, sv), scope))
        {
          if (strcmp (sv, "&SYSLIST") == 0
              && val_as_int (val_get (indices, 0)) == 0)
            {
              Val *l0 = val_dget (svLocals, "&SYSLIST0");
              return subscriptMacroArgument (
                  l0 != NULL ? l0 : val_str (""),
                  val_slice (indices, 1, (ptrdiff_t) val_len (indices)));
            }
          return subscriptMacroArgument (val_dget (scope, sv), indices);
        }
      if (!val_is_exact_list (val_dget (scope, sv)))
        {
          asmError (properties,
                    py_format ("Access to non-subscripted %s %s", what, sv),
                    255);
          return NULL;
        }
      if (val_len (indices) != 1)
        {
          asmError (properties, py_format ("Too many subscripts for %s", sv),
                    255);
          return NULL;
        }
      {
        asmint k = val_as_int (val_get (indices, 0)) - 1;
        Val *array = val_dget (scope, sv);
        if (k < 0 || (size_t) k >= val_len (array))
          {
            asmError (properties,
                      py_format ("Subscript out of range for %s %s(%lld)", what,
                                 sv, (long long) (k + 1)),
                      255);
            return NULL;
          }
        return val_get (array, (size_t) k);
      }
    }

  /* NOT */
  if (n == 4 && val_eq_str (val_get (expression, 1), "NOT"))
    {
      Val *right
          = evalBooleanExpression (val_get (expression, 3), svLocals, properties);
      if (right == NULL)
        {
          asmError (properties, "Cannot evaluate boolean expression None", 255);
          return NULL;
        }
      return val_bool (!val_truthy (right));
    }

  /* AND, OR */
  if (n == 2)
    {
      /*
       * `booleanExpression = booleanTerm { 'OR' booleanTerm }` gives one
       * repetition per additional term, so a chain of N terms arrives as N-1 of
       * them.  This used to accept ONE and nothing else, so `A OR B` worked and
       * `A OR B OR C` could not be evaluated at all.  STKINS tests five
       * alternatives, which is why the IF macro stopped recognising its own
       * condition mnemonics.
       */
      Val *left = unroll (val_get (expression, 0));
      Val *rest = val_get (expression, 1);
      Val *single = unroll (rest);
      Val *repetitions;
      size_t i;
      int allGood = 1;
      if (val_is_seq (single) && val_len (single) == 4
          && (val_eq_str (val_get (single, 1), "AND")
              || val_eq_str (val_get (single, 1), "OR")))
        {
          repetitions = val_seq (V_LIST);
          val_append (repetitions, single);
        }
      else if (val_is_seq (rest))
        repetitions = val_retype (rest, V_LIST);
      else
        repetitions = val_seq (V_LIST);
      if (val_len (repetitions) == 0)
        allGood = 0;
      for (i = 0; i < val_len (repetitions) && allGood; i++)
        {
          Val *r = val_get (repetitions, i);
          if (!(val_is_seq (r) && val_len (r) == 4
                && (val_eq_str (val_get (r, 1), "AND")
                    || val_eq_str (val_get (r, 1), "OR"))))
            allGood = 0;
        }
      if (allGood)
        {
          Val *value = evalBooleanExpression (left, svLocals, properties);
          if (value == NULL)
            {
              asmError (properties,
                        py_format ("Cannot evaluate boolean expression '%s'",
                                   describeExpression (left)),
                        255);
              return NULL;
            }
          /* AND binds tighter than OR in the grammar, so every operator at
             this level is the same one and left-to-right is correct. */
          for (i = 0; i < val_len (repetitions); i++)
            {
              Val *r = val_get (repetitions, i);
              Val *operand
                  = evalBooleanExpression (val_get (r, 3), svLocals, properties);
              if (operand == NULL)
                {
                  asmError (properties,
                            py_format ("Cannot evaluate boolean expression '%s'",
                                       describeExpression (val_get (r, 3))),
                            255);
                  return NULL;
                }
              /* Python's `or`/`and` yield one of their OPERANDS, not a bool. */
              if (val_eq_str (val_get (r, 1), "OR"))
                value = val_truthy (value) ? value : operand;
              else
                value = val_truthy (value) ? operand : value;
            }
          return value;
        }
    }

  /* Relational expressions */
  if (n == 5 && isRelOp (val_get (expression, 2)))
    return val_bool (evaluateRelation (val_get (expression, 0),
                                       val_cstr (val_get (expression, 2)),
                                       val_get (expression, 4), svLocals,
                                       properties));

  asmError (properties,
            py_format ("Cannot evaluate boolean expression '%s'",
                       describeExpression (expression)),
            255);
  return NULL;
}

/*===========================================================================
 * Character expressions
 */
char *
evalCharacterExpression (Val *expression, Val *svLocals, Val *properties)
{
  char *s = NULL;
  size_t n;
  if (properties == NULL)
    properties = scratchProperties ();
  if (svLocals == NULL)
    svLocals = emptyDict;

  expression = unroll (expression);
  n = val_len (expression);

  if (val_is_seq (expression))
    {
      if (n == 4 && val_eq_str (val_get (expression, 0), "'")
          && val_eq_str (val_get (expression, 3), "'"))
        {
          /*
           * 'string1''string2'...'stringN'
           *
           * A DOUBLED QUOTE INSIDE A QUOTED STRING IS ONE QUOTE CHARACTER, and
           * dropping it silently corrupts the value:  `&RESERVE SETC 'H''0'''`
           * gave `H0` instead of `H'0'`, and the card built from it arrived as
           * `DC 4H0`, which no dcOperands rule can parse.
           */
          StrBuf b;
          Val *pieces = val_get (expression, 2);
          size_t i;
          sb_init (&b);
          sb_add (&b, val_cstr (val_get (expression, 1)));
          for (i = 0; i < val_len (pieces); i++)
            {
              Val *ss = val_get (pieces, i);
              if (!val_is_seq (ss) || val_len (ss) != 2
                  || !val_eq_str (val_get (ss, 0), "''"))
                {
                  sb_free (&b);
                  asmError (properties,
                            py_format ("Cannot evaluate string expression: %s",
                                       val_str_of (expression)),
                            255);
                  return NULL;
                }
              sb_add (&b, "'");
              sb_add (&b, val_cstr (val_get (ss, 1)));
            }
          s = sb_take (&b);
        }
      else if (n == 2 && val_eq_str (val_get (expression, 0), "T'"))
        return arena_strdup (ARENA_MAIN,
                             typeAttribute (properties, val_get (expression, 1),
                                            svLocals, NULL));
      else if (n == 2 || n == 3)
        {
          size_t index;
          s = evalCharacterExpression (val_get (expression, 0), svLocals,
                                       properties);
          if (s == NULL)
            {
              asmError (properties,
                        py_format ("Cannot evaluate string expression: %s",
                                   val_str_of (val_get (expression, 0))),
                        255);
              return NULL;
            }
          for (index = 1; index < n; index++)
            {
              Val *e = unroll (val_get (expression, index));
              if (val_is_seq (e) && val_len (e) == 2
                  && val_eq_str (val_get (e, 0), "."))
                {
                  /* exp1.exp2 */
                  char *ss = evalCharacterExpression (val_get (e, 1), svLocals,
                                                      properties);
                  if (ss == NULL)
                    {
                      asmError (properties,
                                py_format ("Cannot evaluate string expression: "
                                           "%s",
                                           val_str_of (val_get (expression, 1))),
                                255);
                      return NULL;
                    }
                  s = py_concat (s, ss);
                }
              else if (val_is_seq (e) && val_len (e) == 5
                       && val_eq_str (val_get (e, 0), "(")
                       && val_eq_str (val_get (e, 2), ",")
                       && val_eq_str (val_get (e, 4), ")"))
                {
                  /* exp(i1,i2) */
                  Val *iv = evalArith (val_get (e, 1), svLocals, properties);
                  Val *nv;
                  asmint i, count;
                  if (iv == NULL)
                    {
                      asmError (properties,
                                py_format ("Cannot evaluate index %s",
                                           val_str_of (val_get (e, 1))),
                                255);
                      return NULL;
                    }
                  i = val_as_int (iv) - 1;
                  nv = evalArith (val_get (e, 3), svLocals, properties);
                  if (nv == NULL)
                    {
                      asmError (properties,
                                py_format ("Cannot evaluate length %s",
                                           val_str_of (val_get (e, 3))),
                                255);
                      return NULL;
                    }
                  count = val_as_int (nv);
                  if (i < 0 || count < 0)
                    {
                      /* If i+n runs past the end of the string, that is
                         allowed; only a negative is not. */
                      asmError (properties, "Index or length out of range", 255);
                      return NULL;
                    }
                  s = py_substr (s, (size_t) i, (size_t) count);
                }
              else
                {
                  char *ss
                      = evalCharacterExpression (e, svLocals, properties);
                  if (ss == NULL)
                    {
                      asmError (properties,
                                py_format ("Cannot evaluate string expression: "
                                           "%s",
                                           val_str_of (val_get (expression, 1))),
                                255);
                      return NULL;
                    }
                  s = py_concat (s, ss);
                }
            }
        }
    }
  if (s != NULL)
    return svReplace (properties, s, svLocals);
  asmError (properties,
            py_format ("Cannot evaluate string expression: %s",
                       val_str_of (expression)),
            255);
  return NULL;
}

/*===========================================================================
 * Declaration and assignment of symbolic variables
 */

/* Only int, boolean, string, and lists of those occur.  Returns true if the
   types DIFFER.  A Python bool is a distinct type from int here, which is what
   stops a GBLA and a GBLB of the same name from being confused.

   A DIMENSION IS NOT A TYPE.  Two arrays of the same element type differing
   only in length used to be reported as a type change, which made a global
   re-declared at a different size an intolerable error.  BILDNEW5 is where
   that shows: MACSMITH declares `GBLC ...&T(264),&T2(264)' while TEXT and
   FAZ2MAC declare the same two globals at (250), and the sequence numbers say
   why -- MACSMITH's card carries modification level AG and both others AA, so
   only MACSMITH was re-issued when the tables grew.  596 of BILDNEW5's 2068
   errors were those two names, every one at severity 255.  Nothing indexes
   &T past 250 anywhere in that assembly, so the conflict was declarative noise
   that aborted a build the original assembler completed. */
static int
isDifferentType (Val *q0, Val *q1)
{
  if (val_is_exact_list (q0) && val_is_exact_list (q1))
    {
      /* A dimension below 1 is rejected before we get here, so neither list
         is ever empty; the Python would raise IndexError if one were. */
      if (val_len (q0) == 0 || val_len (q1) == 0)
        return 0;
      return val_get (q0, 0)->type != val_get (q1, 0)->type;
    }
  if (q0 == NULL || q1 == NULL)
    return q0 != q1;
  return q0->type != q1->type;
}

void
svDeclare (const char *operation, const char *operand, Val *svLocals,
           Val *properties)
{
  char **fields;
  size_t nfields, i;
  char typ = operation[3];
  Val *originalValue;
  Val *sv;
  {
    char **words;
    size_t nwords = py_split_ws (operand, &words);
    nfields = py_split_char (nwords > 0 ? words[0] : "", ',', &fields);
  }
  if (typ == 'A')
    originalValue = val_int (0);
  else if (typ == 'B')
    originalValue = val_bool (0);
  else
    originalValue = val_str ("");
  sv = py_startswith (operation, "GBL") ? svGlobals : svLocals;

  for (i = 0; i < nfields; i++)
    {
      char *field = fields[i];
      Val *value = originalValue;
      if (field[0] != '&')
        {
          asmError (properties,
                    py_format ("In %s, %s is not a symbolic variable",
                               operation, field),
                    255);
          continue;
        }
      if (strchr (field, '(') != NULL)
        {
          char **subfields;
          size_t nsub = py_split_char (field, '(', &subfields);
          char *length;
          Val *ast;
          Val *nv;
          asmint count;
          if (nsub != 2 || !py_endswith (subfields[1], ")"))
            {
              asmError (properties,
                        py_format ("In %s, %s is improperly formed", operation,
                                   field),
                        255);
              continue;
            }
          length = py_substr (subfields[1], 0, strlen (subfields[1]) - 1);
          ast = parserASM (length, "arithmeticExpressionOnly");
          if (ast == NULL)
            {
              asmError (properties,
                        py_format ("Could not parse dimension of %s", field),
                        255);
              continue;
            }
          nv = evalArith (ast, svLocals, properties);
          if (nv == NULL)
            {
              asmError (properties,
                        py_format ("Could not compute dimension of %s", field),
                        255);
              continue;
            }
          count = val_as_int (nv);
          if (count < 1)
            {
              asmError (properties,
                        py_format ("Dimension of %s out of range (%lld)", field,
                                   (long long) count),
                        255);
              continue;
            }
          field = subfields[0];
          {
            Val *array = val_seq (V_LIST);
            asmint k;
            for (k = 0; k < count; k++)
              val_append (array, originalValue);
            value = array;
          }
        }
      if (py_startswith (operation, "GBL"))
        {
          Val *declared = val_dget (svLocals, GLOBALS_DECLARED);
          if (declared == NULL || !val_is_dict (declared))
            {
              declared = val_dict ();
              val_dset (svLocals, GLOBALS_DECLARED, declared);
            }
          val_dset (declared, field, V_True);
        }
      if (val_dhas (sv, field))
        {
          if (isDifferentType (val_dget (sv, field), value))
            asmError (properties,
                      py_format ("Attempt to change type of existing symbolic "
                                 "variable %s",
                                 field),
                      255);
          /* THE FIRST DECLARATION FIXES THE DIMENSION.  Growing the array to
             the largest dimension seen was tried and is WRONG: RUNASM's VX6S3
             then generated 34 mismatched bytes and ran 12 bytes past the end
             of its listing, because a longer array is a larger N' and the data
             built from it grew to match.  A later declaration of a different
             size is accepted in silence and changes nothing. */
          continue;
        }
      val_dset (sv, field, value);
    }
}

/*
 * Split the operand of a SETx into its comma-separated list of values.
 *
 * The split is at TOP LEVEL only:  a comma inside a quoted string, or inside
 * parentheses, belongs to the value it sits in.  Both cases are real -- CHAR
 * writes `'LPAREN','RPAREN'` and also `'&CHAR'(1,&N+4)`.
 *
 * It also stops at the first blank outside a quoted string, because everything
 * after that is a trailing comment.  CHAR has one, and so does its neighbour
 * CMTX6, whose comment field contains a LONE APOSTROPHE; stopping at the blank
 * is what keeps that stray quote from swallowing the rest of the card.
 */
size_t
splitSetOperands (const char *operand, char ***partsOut)
{
  size_t cap = 8, count = 0;
  char **parts = (char **) arena_alloc (ARENA_MAIN, cap * sizeof (char *));
  StrBuf current;
  int inQuote = 0;
  int depth = 0;
  size_t i = 0, n = strlen (operand);
  sb_init (&current);
  while (i < n)
    {
      char c = operand[i];
      if (inQuote)
        {
          if (c == '\'')
            {
              if (i + 1 < n && operand[i + 1] == '\'')
                {
                  /* A doubled apostrophe is one literal apostrophe and does
                     not end the string. */
                  sb_add (&current, "''");
                  i += 2;
                  continue;
                }
              inQuote = 0;
            }
          sb_addc (&current, c);
        }
      else if (c == '\'')
        {
          inQuote = 1;
          sb_addc (&current, c);
        }
      else if (c == ' ')
        break;
      else
        {
          if (c == '(')
            depth++;
          else if (c == ')')
            depth--;
          if (c == ',' && depth == 0)
            {
              if (count == cap)
                {
                  char **bigger = (char **) arena_alloc (
                      ARENA_MAIN, cap * 2 * sizeof (char *));
                  memcpy (bigger, parts, cap * sizeof (char *));
                  parts = bigger;
                  cap *= 2;
                }
              parts[count++] = sb_dup (&current);
              sb_clear (&current);
            }
          else
            sb_addc (&current, c);
        }
      i++;
    }
  if (count == cap)
    {
      char **bigger
          = (char **) arena_alloc (ARENA_MAIN, (cap + 1) * sizeof (char *));
      memcpy (bigger, parts, cap * sizeof (char *));
      parts = bigger;
    }
  parts[count++] = sb_take (&current);
  *partsOut = parts;
  return count;
}

static Val *
svEvaluate (const char *operation, const char *text, Val *v, Val *svLocals,
            Val *properties, const char *sname)
{
  Val *ast;
  if (strcmp (operation, "SETA") == 0 && val_is_int (v))
    {
      ast = parserASM (text, "setaOperand");
      if (ast == NULL)
        {
          asmError (properties,
                    py_format ("Cannot parse arithmetic expression %s", text),
                    255);
          return NULL;
        }
      return evalArith (val_dget (ast, "v"), svLocals, properties);
    }
  if (strcmp (operation, "SETB") == 0 && val_is_bool (v))
    {
      ast = parserASM (text, "setbOperand");
      if (ast == NULL)
        {
          asmError (properties,
                    py_format ("Cannot parse boolean expression %s", text), 255);
          return NULL;
        }
      return evalBooleanExpression (val_dget (ast, "v"), svLocals, properties);
    }
  if (strcmp (operation, "SETC") == 0 && val_is_str (v))
    {
      char *value;
      ast = parserASM (text, "setcOperand");
      if (ast == NULL)
        {
          asmError (properties,
                    py_format ("Cannot parse character expression %s", text),
                    255);
          return NULL;
        }
      value = evalCharacterExpression (val_dget (ast, "v"), svLocals, properties);
      if (value != NULL)
        {
          /*
           * 8 IS ASSEMBLER F'S LIMIT AND THIS LIBRARY IS ASSEMBLER H, where a
           * SETC value may be up to 255 characters.  The old limit did not
           * reject an over-long value, it silently TRUNCATED one, so the card
           * built from it was cut off mid-symbol.  TFPSA builds a whole PSW
           * pair in one SETC, which is nowhere near eight.
           */
          if (strlen (value) > 255)
            value = py_substr (value, 0, 255);
          return val_str (value);
        }
      return NULL;
    }
  asmError (properties, py_format ("Data type doesn't match %s", sname), 255);
  return NULL;
}

void
svSet (const char *operation, const char *name, const char *operand,
       Val *svLocals, Val *properties)
{
  Val *pname;
  const char *sname;
  Val *sv;
  Val *v;
  char *strippedOperand = py_strip (operand);

  pname = parserASM (name, "nameSet");
  if (pname == NULL)
    {
      asmError (properties, py_format ("Cannot parse name field %s", name), 255);
      return;
    }
  if (!val_dhas (pname, "sv"))
    {
      asmError (properties, "No symbolic variable for assignment", 255);
      return;
    }
  sname = val_cstr (val_get (val_dget (pname, "sv"), 0));
  if (val_dhas (svLocals, sname))
    sv = svLocals;
  else if (svGlobalVisible (sname, svLocals))
    sv = svGlobals;
  else if (!val_dhas (pname, "exp"))
    {
      /*
       * The (non-arrayed) SET symbol that is the target has not been declared,
       * which the System/360 manual requires.  AP-101S assembly language
       * evidently has a convenience feature that declares it as local.
       */
      Val *dv;
      if (strcmp (operation, "SETA") == 0)
        dv = val_int (0);
      else if (strcmp (operation, "SETB") == 0)
        dv = val_bool (0);
      else if (strcmp (operation, "SETC") == 0)
        dv = val_str ("");
      else
        {
          asmError (properties, "Instruction is not SETA, SETB, or SETC", 255);
          return;
        }
      sv = svLocals;
      val_dset (svLocals, sname, dv);
    }
  else
    {
      /*
       * A SUBSCRIPTED target that has not been declared either.  Assembler H
       * declares that implicitly too, taking the dimension from the highest
       * subscript ever assigned; processing the deck in order, that means the
       * array simply grows.
       *
       * FCMBMTMC RELIES ON THIS.  It assigns four payload high-rate comfault
       * mask tables with no LCLC or GBLC anywhere.
       */
      Val *dv;
      Val *array;
      if (strcmp (operation, "SETA") == 0)
        dv = val_int (0);
      else if (strcmp (operation, "SETB") == 0)
        dv = val_bool (0);
      else if (strcmp (operation, "SETC") == 0)
        dv = val_str ("");
      else
        {
          asmError (properties, "Instruction is not SETA, SETB, or SETC", 255);
          return;
        }
      sv = svLocals;
      array = val_seq (V_LIST);
      val_append (array, dv);
      val_dset (svLocals, sname, array);
      val_dset (svImplicitArrays, sname, V_True);
    }

  v = val_dget (sv, sname);
  if (val_is_exact_list (v))
    {
      if (!val_dhas (pname, "exp"))
        {
          asmError (properties, py_format ("Is subscripted: %s", sname), 255);
          return;
        }
      /* Just a representative value for testing the datatype, not the element
         that is indexed. */
      v = val_get (v, 0);
    }
  else if (val_dhas (pname, "exp"))
    {
      asmError (properties, py_format ("Is not subscripted: %s", sname), 255);
      return;
    }

  if (!val_dhas (pname, "exp"))
    {
      Val *value = svEvaluate (operation, strippedOperand, v, svLocals,
                               properties, sname);
      if (value == NULL)
        {
          asmError (properties,
                    py_format ("Unable to evaluate data expression %s",
                               strippedOperand),
                    255);
          return;
        }
      val_dset (sv, sname, value);
      return;
    }

  if (val_len (val_dget (pname, "exp")) != 1)
    {
      /* The target of a SETx is a scalar or one element of an array.  Only a
         macro argument, which cannot be assigned to, has multiple
         subscripts. */
      asmError (properties, py_format ("Too many subscripts in %s", name), 255);
      return;
    }
  {
    Val *indexVal = evalArith (val_get (val_dget (pname, "exp"), 0), svLocals,
                               properties);
    asmint index;
    char **texts;
    size_t nparts, offset;
    if (indexVal == NULL)
      {
        asmError (properties,
                  py_format ("Cannot evaluate subscript in %s", name), 255);
        return;
      }
    index = val_as_int (indexVal) - 1; /* 1-based to 0-based */
    /*
     * A SUBSCRIPTED target may be given a LIST of values, assigned to
     * consecutive elements starting at that subscript -- so `&CCODE1(1) SETA
     * 48,49,...,57` fills the first ten.  An omitted entry, `43,,45`, leaves
     * that one element as it was.  Only a subscripted target is split, which is
     * why an unsubscripted SETC operand may still contain a comma of its own.
     */
    nparts = splitSetOperands (strippedOperand, &texts);
    for (offset = 0; offset < nparts; offset++)
      {
        char *text = py_strip (texts[offset]);
        Val *value;
        asmint i;
        Val *array;
        if (text[0] == '\0')
          continue;
        value = svEvaluate (operation, text, v, svLocals, properties, sname);
        if (value == NULL)
          {
            asmError (properties,
                      py_format ("Unable to evaluate data expression %s", text),
                      255);
            return;
          }
        i = index + (asmint) offset;
        array = val_dget (sv, sname);
        if ((size_t) i >= val_len (array) && i >= 0
            && val_dhas (svImplicitArrays, sname))
          {
            /* Only an IMPLICITLY declared array grows.  One declared with LCLC
               or GBLC has a stated dimension, and an index past it is a real
               defect that must keep being reported. */
            Val *first = val_get (array, 0);
            Val *pad = first == NULL         ? val_str ("")
                       : val_is_bool (first) ? val_bool (0)
                       : val_is_int (first)  ? val_int (0)
                                             : val_str ("");
            while ((size_t) i >= val_len (array))
              val_append (array, pad);
          }
        if (i < 0 || (size_t) i >= val_len (array))
          {
            asmError (properties,
                      py_format ("Index out of range: %s(%lld)", sname,
                                 (long long) (i + 1)),
                      255);
            return;
          }
        val_set (array, (size_t) i, value);
      }
  }
}
