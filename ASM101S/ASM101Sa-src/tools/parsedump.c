/*
 * License:    Public Domain, as the rest of ASM101S.
 * Filename:   tools/parsedump.c
 * Purpose:    Differential-test harness for the C parser.
 *
 * Reads `RULE<TAB>TEXT` lines on stdin and writes a canonical rendering of the
 * resulting parse tree, one per line.  tools/parsedump.py does the same thing
 * through the real TatSu parser, so that `diff` answers the only question that
 * matters about a reimplemented parser:  does it build the same tree, node for
 * node, for every operand the corpus actually contains.
 *
 * The rendering distinguishes every type the assembler's consumers distinguish
 * -- tuple from list, list from closure, and the insertion order of an AST --
 * because each of those differences changes what the code generator does.
 */

#include "fieldparser.h"
#include "pyutil.h"
#include "val.h"

static void
dump (Val *v, StrBuf *b)
{
  size_t i;
  if (v == NULL || val_is_none (v))
    {
      sb_add (b, "N");
      return;
    }
  switch (v->type)
    {
    case V_STR:
      sb_addf (b, "S%u:", (unsigned) val_strlen (v));
      sb_addn (b, val_cstr (v), val_strlen (v));
      break;
    case V_INT:
      sb_addf (b, "I%lld", (long long) val_as_int (v));
      break;
    case V_BOOL:
      sb_add (b, val_truthy (v) ? "B1" : "B0");
      break;
    case V_TUPLE:
      sb_add (b, "T(");
      for (i = 0; i < val_len (v); i++)
        {
          if (i)
            sb_add (b, ",");
          dump (val_get (v, i), b);
        }
      sb_add (b, ")");
      break;
    case V_LIST:
      sb_add (b, "L[");
      for (i = 0; i < val_len (v); i++)
        {
          if (i)
            sb_add (b, ",");
          dump (val_get (v, i), b);
        }
      sb_add (b, "]");
      break;
    case V_CLOSURE:
      sb_add (b, "C[");
      for (i = 0; i < val_len (v); i++)
        {
          if (i)
            sb_add (b, ",");
          dump (val_get (v, i), b);
        }
      sb_add (b, "]");
      break;
    case V_DICT:
      sb_add (b, "D{");
      for (i = 0; i < val_dlen (v); i++)
        {
          const char *k = val_dkey (v, i);
          if (i)
            sb_add (b, ",");
          if (strcmp (k, "parseinfo") == 0)
            sb_addf (b, "parseinfo=P%lld",
                     (long long) val_dget_int (val_dval (v, i), "endpos", -1));
          else
            {
              sb_add (b, k);
              sb_add (b, "=");
              dump (val_dval (v, i), b);
            }
        }
      sb_add (b, "}");
      break;
    default:
      sb_add (b, "?");
      break;
    }
}

int
main (void)
{
  char *line = NULL;
  size_t cap = 0;
  arena_init ();
  for (;;)
    {
      size_t len = 0;
      int c;
      for (;;)
        {
          c = getchar ();
          if (c == EOF || c == '\n')
            break;
          if (len + 2 > cap)
            {
              cap = cap ? cap * 2 : 256;
              line = (char *) realloc (line, cap);
              if (line == NULL)
                return 1;
            }
          line[len++] = (char) c;
        }
      if (c == EOF && len == 0)
        break;
      if (line == NULL)
        {
          cap = 256;
          line = (char *) malloc (cap);
        }
      line[len] = '\0';
      {
        char *tab = strchr (line, '\t');
        StrBuf b;
        if (tab == NULL)
          {
            if (c == EOF)
              break;
            continue;
          }
        *tab = '\0';
        sb_init (&b);
        dump (parserASM (tab + 1, line), &b);
        fputs (b.s ? b.s : "", stdout);
        fputc ('\n', stdout);
        sb_free (&b);
      }
      if (c == EOF)
        break;
    }
  free (line);
  return 0;
}
