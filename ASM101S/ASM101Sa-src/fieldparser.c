/*
 * License:    This program is declared by its author, Ronald Burkey, to be the
 *             U.S. Public Domain, and may be freely used, modified, or
 *             distributed for any purpose whatever.
 * Filename:   fieldparser.c
 * Purpose:    Parser entry point and continuation-card joining.
 * Contact:    info@sandroid.org
 */

#include "fieldparser.h"
#include "parser_asm.h"
#include "peg.h"
#include "pyutil.h"

#include <setjmp.h>

/*===========================================================================
 * parserASM
 */
static PegCtx theCtx;
static int ctxReady = 0;

Val *
parserASM (const char *text, const char *rule)
{
  const AsmRule *r;
  Val *volatile result = NULL;
  int savedArena;

  if (text == NULL)
    text = "";
  for (r = asmRules; r->name != NULL; r++)
    if (strcmp (r->name, rule) == 0)
      break;
  if (r->name == NULL)
    fatal ("no grammar rule named '%s'", rule);

  if (!ctxReady)
    {
      memset (&theCtx, 0, sizeof (theCtx));
      ctxReady = 1;
    }

  /*
   * EVERYTHING THE PARSE BUILDS IS THROWN AWAY BUT THE ANSWER.  A parse of one
   * operand field builds a great deal of tree that backtracking then discards,
   * and confining all of it to the parse arena keeps that from accumulating
   * over the tens of thousands of parses a macro-heavy module performs.  The
   * result is copied into the main arena by `val_export` on the way out, with
   * its internal sharing preserved.
   */
  arena_reset_parse ();
  savedArena = val_arena;
  val_arena = ARENA_PARSE;

  peg_begin (&theCtx, text, strlen (text));
  if (setjmp (theCtx.top) == 0)
    {
      r->fn (&theCtx);
      result = peg_cst (&theCtx);
      /* The rule's own node was appended to the root state's CST, which starts
         out None, so the CST *is* the node. */
    }
  else
    result = NULL; /* `except: return None` */
  peg_end (&theCtx);

  val_arena = ARENA_MAIN;
  if (result != NULL)
    result = val_export (result);
  val_arena = savedArena;
  /* Python returns None for a failed parse, and the callers test for it with
     `== None`; NULL is that. */
  if (result != NULL && val_is_none (result))
    return NULL;
  return result;
}

/*===========================================================================
 * Auxiliary functions
 *
 * WHERE THE OPERAND FIELD OF A STATEMENT ENDS: at the first blank that is
 * neither inside a quoted string NOR inside parentheses.  Everything after it
 * is a comment.
 *
 * The parentheses matter as much as the quotes.  A conditional-assembly
 * expression is full of blanks that are outside any quoted string --
 *     AIF   ('&P2' EQ '' OR '&P2' EQ 'OR' OR '&P2' EQ 'AND' OR '        X
 *           &P2' EQ 'ORIF').SGLOPR
 * -- and stopping at the first of them truncated the operand and then joined
 * the continuation card onto the stump, silently producing a different
 * condition from the one written.
 */
size_t
operandFieldEnd (const char *text)
{
  int quoted = 0;
  int depth = 0;
  size_t i = 0;
  size_t n = strlen (text);
  while (i < n)
    {
      char c = text[i];
      if (c == '\'')
        {
          /* A doubled quote inside a string is an escaped quote, not the end. */
          if (quoted && i + 1 < n && text[i + 1] == '\'')
            {
              i += 2;
              continue;
            }
          quoted = !quoted;
        }
      else if (!quoted)
        {
          if (c == '(')
            depth++;
          else if (c == ')')
            {
              if (depth > 0)
                depth--;
            }
          else if (c == ' ' && depth == 0)
            return i;
        }
      i++;
    }
  return n;
}

int
insideQuote (const char *text)
{
  int quoted = 0;
  size_t i = 0;
  size_t n = strlen (text);
  while (i < n)
    {
      if (text[i] == '\'')
        {
          if (quoted && i + 1 < n && text[i + 1] == '\'')
            {
              i += 2;
              continue;
            }
          quoted = !quoted;
        }
      i++;
    }
  return quoted;
}

int
macroStamped (const char *card)
{
  /* `"%-80s" % card.rstrip("\r\n")[:80]`, then columns 73-75. */
  char field[81];
  size_t i, n;
  const char *end = card + strlen (card);
  while (end > card && (end[-1] == '\r' || end[-1] == '\n'))
    end--;
  n = (size_t) (end - card);
  if (n > 80)
    n = 80;
  for (i = 0; i < 80; i++)
    field[i] = i < n ? card[i] : ' ';
  field[80] = '\0';
  return field[72] >= '0' && field[72] <= '9' && field[73] >= '0'
         && field[73] <= '9' && field[74] == '-';
}

/*---------------------------------------------------------------------------
 * Python-style slicing helpers, so that the transliteration below can be read
 * against the original.  Both clamp rather than fail, as Python's do.
 */
static char *
slice (const char *s, size_t start, size_t end)
{
  size_t n = strlen (s);
  if (start > n)
    start = n;
  if (end > n)
    end = n;
  if (end < start)
    end = start;
  return arena_strndup (ARENA_MAIN, s + start, end - start);
}

static char *
rstrip_crlf (const char *s)
{
  size_t n = strlen (s);
  while (n > 0 && (s[n - 1] == '\r' || s[n - 1] == '\n'))
    n--;
  return arena_strndup (ARENA_MAIN, s, n);
}

/*===========================================================================
 * joinOperand
 *
 * Forms the merged operand field, taking continuation cards into account and
 * discarding comments.  Returns True,operand,skipCount on success or
 * False,...,skipCount on error.
 *
 * The long comments in fieldParser.py explain why each of the three joining
 * rules below is what it is; they are not repeated in full here, but the
 * structure is statement-for-statement the same so that the two can be read
 * together.
 */
int
joinOperand (Val *lines, size_t index, size_t column, int proto, int invoke,
             char **operandOut, ptrdiff_t *skipCountOut)
{
  int continuation = 0;
  ptrdiff_t skipCount = -1;
  int status = 1;
  int done = 0;
  char *operand = arena_strdup (ARENA_MAIN, "");
  size_t nlines = val_len (lines);

  while (continuation || skipCount < 0)
    {
      const char *lineRaw;
      char *line;
      size_t lineLen;

      if (index >= nlines)
        break;
      skipCount += 1;
      lineRaw = val_cstr (val_get (lines, index));
      line = rstrip_crlf (lineRaw);
      lineLen = strlen (line);

      if (done)
        {
          /* pass */
        }
      else if (continuation)
        {
          if (invoke || proto)
            {
              /* These two trim the accumulated operand with the parser, via
                 `endpos` below, so leave them alone. */
              operand = py_concat (rstrip_crlf (operand), slice (line, 15, 71));
            }
          else
            {
              size_t fieldEnd = operandFieldEnd (operand);
              char *field = slice (operand, 0, fieldEnd);
              char *fieldStripped = py_rstrip (field);
              if (fieldEnd >= strlen (py_rstrip (operand))
                  || py_endswith (fieldStripped, ","))
                {
                  /* A CONTINUED OPERAND'S TRAILING BLANKS ARE PADDING out to
                     column 71, not data -- except inside a character literal,
                     where they are data, which is why this is guarded. */
                  if (!insideQuote (field))
                    field = fieldStripped;
                  operand = py_concat (field, rstrip_crlf (slice (line, 15, 71)));
                }
              else if (macroStamped (line))
                {
                  /* A MACRO-GENERATED CARD IS NOT SWALLOWED.  Columns 73-80
                     reading `nn-NAME` say the expander produced this card, so
                     it was not in the deck when the column 72 above it was
                     punched and cannot be part of that statement. */
                  skipCount -= 1;
                  break;
                }
            }
        }
      else
        operand = rstrip_crlf (slice (line, column, 71));

      if (lineLen < 72)
        continuation = 0;
      else
        continuation = (line[71] != ' ');
      index += 1;
      if (done || !(invoke || proto))
        continue;

      /* The Python wraps what follows in `try: ... except: status = False;
         done = True`, and every way it can raise is a way the parse did not
         give an answer this can use. */
      {
        Val *ret = parserASM (operand, invoke ? "operandInvocation0"
                                              : "operandPrototype0");
        Val *info = (ret != NULL) ? val_dget (ret, "parseinfo") : NULL;
        if (ret == NULL || !val_is_dict (ret) || info == NULL)
          {
            status = 0;
            done = 1;
            continue;
          }
        {
          ptrdiff_t endpos = (ptrdiff_t) val_dget_int (info, "endpos", 0);
          ptrdiff_t operandLen = (ptrdiff_t) strlen (operand);
          /* `operand[:endpos-1]`, with Python's meaning for a negative bound:
             an endpos of 0 drops the last character rather than the whole
             string.  It cannot arise from any alternative that reaches here,
             but reproducing it costs nothing and guessing does not. */
          ptrdiff_t cut = endpos - 1;
          if (cut < 0)
            cut += operandLen;
          if (cut < 0)
            cut = 0;
          if (val_dhas (ret, "end0") && invoke && endpos > 1
              && endpos - 2 < operandLen && operand[endpos - 2] == ',')
            operand = slice (operand, 0, (size_t) cut);
          else if (val_dhas (ret, "end0"))
            {
              done = 1;
              operand = slice (operand, 0, (size_t) cut);
            }
          else if (val_dhas (ret, "end1"))
            operand = slice (operand, 0, (size_t) cut);
          else if (val_dhas (ret, "end2"))
            {
              /* pass */
            }
          else if (val_dhas (ret, "end3"))
            operand = arena_strdup (ARENA_MAIN, "");
          else if (val_dhas (ret, "end4"))
            operand = py_rstrip (operand);
          else
            {
              status = 0;
              done = 1;
            }
        }
      }
    }

  *operandOut = operand;
  *skipCountOut = skipCount;
  return status;
}
