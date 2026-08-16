/*
 * License:    This program is declared by its author, Ronald Burkey, to be the
 *             U.S. Public Domain, and may be freely used, modified, or
 *             distributed for any purpose whatever.
 * Filename:   asm101s.c
 * Purpose:    An assembler for the assembly language of the IBM AP-101S
 *             computer.  This is the main program:  it reads the source,
 *             resolves the macro language, drives the code generator and
 *             prints the assembly listing.
 * Contact:    info@sandroid.org
 * Refer to:   https://www.ibiblio.org/apollo/ASM101S.html
 *
 * A port of ASM101S.py.
 *
 * WHICH VERSION THIS IS A PORT OF is recorded in version.h, and printed by
 * `--version`.  It is written down in exactly one place so that it cannot go
 * stale in one of several; update it as part of every parity pass.
 *
 * A MOVING SOURCE TREE IS NOT A SOUND THING TO MEASURE AGAINST.  The
 * differential tests for this port compare its output against ASM101S.py's,
 * and one such sweep was run while expressions.py was being edited underneath
 * it -- half the corpus went through the old code and half through the new,
 * and the result was reported as though it were one measurement.  Check
 * `git rev-parse HEAD` and the working tree's cleanliness before a sweep and
 * again after it, and treat any change between the two as invalidating it.
 */

#include "common.h"
#include "version.h"
#include "expressions.h"
#include "fieldparser.h"
#include "model101.h"
#include "objectwriter.h"
#include "pyutil.h"
#include "readlisting.h"
#include "tables.h"
#include "val.h"

#include <time.h>

static const char *program = "ASM101S";
static const char *version = "0.00";
static char currentDate[16];

/*=============================================================================
 * For reading source files.  The entire macro library is read into `source` as
 * needed, and then all of the files listed on the command line are read.  All
 * `COPY` operations are performed and all macro invocations expanded.  All of
 * the lines are parsed, except that macro definitions are only barely parsed,
 * and are fully parsed upon expansion.
 */
static Val *source;        /* list of line-properties dicts */
static Val *macros;        /* name -> [positional, total, start, proto, end, file] */
static Val *sequenceGlobalLocals;
static Val *libraries;     /* list of directory names */
static Val *libraryMembers; /* dir -> set of member names */
static Val *unindexedMembers;
static Val *noLibraryMember;
static asmint sysndx = -1;
static int listOn = 1;
static int trace = 0;
static asmint endLibraries = 0;
/* Read every listed member ahead of the module, as this always used to.  Off:
   members are fetched by name when invoked.  See `loadLibraryMacro`. */
static const int preReadLibraries = 0;

static void readSourceFile (const char *fromWhere, Val *svLocals, Val *sequence,
                            int copy, int printable, asmint depth);

/*-----------------------------------------------------------------------------
 * Card handling
 */

/* `"%-80s" % text.rstrip()[:80]` */
static char *
padTo80 (const char *text)
{
  size_t n = strlen (text);
  char *out;
  size_t i;
  while (n > 0
         && (text[n - 1] == ' ' || text[n - 1] == '\t' || text[n - 1] == '\r'
             || text[n - 1] == '\n' || text[n - 1] == '\f'
             || text[n - 1] == '\v'))
    n--;
  if (n > 80)
    n = 80;
  out = (char *) arena_alloc (ARENA_MAIN, 81);
  memcpy (out, text, n);
  for (i = n; i < 80; i++)
    out[i] = ' ';
  out[80] = '\0';
  return out;
}

/*
 * Does this card continue onto the next one?  Column 72 says so, EXCEPT that a
 * typed card is never continued by a macro-generated card.
 *
 * OI301700 IS PRE-EXPANDED and the expansions were spliced in, displacing what
 * the continuation actually pointed at.  FIOCGR's `LR R2,R7` carries an X in
 * column 72 and the `CHI R6,2` now standing after it was eaten as its
 * continuation and never assembled:  the original has 00009 B5E6 0002 and we
 * generated nothing, putting every later address four bytes low.
 */
static int
continuesOnto (const char *line, Val *lines, size_t lineNumber)
{
  if (line[71] == ' ')
    return 0;
  if (lineNumber + 1 < val_len (lines))
    {
      char *nextCard = padTo80 (val_cstr (val_get (lines, lineNumber + 1)));
      if (macroStamped (nextCard) && !macroStamped (line))
        return 0;
    }
  return 1;
}

/*
 * `parseLine` parses an input card into `name`, `operation` and `operand`.  It
 * does not try to determine validity (except as far as necessary for parsing)
 * nor to evaluate any expressions.  It takes into account continuation cards,
 * macro definitions (without expanding them), and the alternate continuation
 * format sometimes used for macro arguments and macro formal parameters, as
 * well as parenthesisation and quoted strings within sub-operands.  The return
 * is the number of continuation lines processed.
 *
 * Lines in macro definitions are not parsed beyond their prototypes; that is
 * done only during expansion.
 */
static ptrdiff_t
parseLine (Val *lines, size_t lineNumber, int inMacroDefinition,
           int inMacroProto)
{
  Val *properties = val_get (source, val_len (source) - 1);
  const char *text;
  size_t j, k, n;
  char *name;
  char *operation;
  char *operand = arena_strdup (ARENA_MAIN, "");
  ptrdiff_t skipped = 0;
  int status;

  val_dset (properties, "operand", V_None);
  if (val_dget_bool (properties, "empty", 0)
      || val_dget_bool (properties, "fullComment", 0)
      || val_dget_bool (properties, "dotComment", 0))
    return 0;
  text = val_dget_str (properties, "text", "");
  n = strlen (text);

  /* Parse all fields prior to the operand, at least enough to determine the
     contents if not the validity. */
  j = 0;
  while (j < n && text[j] != ' ') /* scan past the label, if any */
    j++;
  name = arena_strndup (ARENA_MAIN, text, j);
  val_dset_str (properties, "name", name);
  while (j < n && text[j] == ' ') /* scan up to the operation */
    j++;
  k = j;
  while (j < n && text[j] != ' ') /* scan past the operation */
    j++;
  operation = arena_strndup (ARENA_MAIN, text + k, j - k);
  val_dset_str (properties, "operation", operation);
  if (strcmp (operation, "MACRO") == 0)
    {
      if (inMacroDefinition)
        ERROR (properties, "Nested MACRO definitions");
      return 0;
    }
  if (strcmp (operation, "MEND") == 0)
    {
      if (!inMacroDefinition)
        ERROR (properties, "MEND without preceding MACRO");
      return 0;
    }
  if (inMacroDefinition && !inMacroProto)
    return 0;
  while (j < n && text[j] == ' ') /* scan up to the operand or comment */
    j++;

  /* Determine the full operand field, after accounting for continuation lines,
     end-of-line comments, and the "alternate" format for continuations that
     may optionally be used for macro-prototype and macro-invocation lines.  No
     replacement of symbolic variables, nor expansion of macros, has yet been
     performed or will be performed here. */
  if (inMacroProto)
    {
      status = joinOperand (lines, lineNumber, j, 1, 0, &operand, &skipped);
      if (!status)
        ERROR (properties, "Cannot parse macro-prototype cards");
    }
  else if (val_dhas (macros, operation))
    {
      status = joinOperand (lines, lineNumber, j, 0, 1, &operand, &skipped);
      if (!status)
        ERROR (properties, "Cannot parse macro-invocation operands");
    }
  else if (intmap_has (&instructionsWithoutOperands, operation))
    {
      /* No operand field at all. */
    }
  else if (pairmap_get (&pseudoOps, operation) != NULL
           && pairmap_get (&pseudoOps, operation)->a == 0)
    {
      /* A pseudo-operation that takes no operands. */
    }
  else
    {
      /* The operation has operands, subject to continuation lines and
         end-of-line comments, but not to the "alternate" form of continuation
         lines. */
      status = joinOperand (lines, lineNumber, j, 0, 0, &operand, &skipped);
      if (!status)
        ERROR (properties, "Cannot parse macro-invocation operands");
    }
  val_dset_str (properties, "operand", operand);
  return skipped;
}

/*
 * The diagnostic for an exhausted ACTR.  It names where the loop was, because
 * the alternative -- an assembly that simply never returns -- gives no clue at
 * all, and because the count is very often correct and the loop's exit
 * condition is what is wrong.
 */
static char *
actrMessage (const char *fromWhere)
{
  return py_format ("ACTR exhausted: too many AIF/AGO branches in %s.  This is "
                    "a conditional-assembly loop that never terminates; the "
                    "assembler has abandoned the expansion.",
                    fromWhere);
}

/*
 * The EXTENDED, or computed, AGO of GC28-6514:
 *
 *       AGO   (arithmetic-expression)seq1,seq2,...,seqN
 *
 * the expression selecting which of the N sequence symbols to branch to, 1 for
 * the first.  A value OUTSIDE 1..N branches nowhere and falls through to the
 * next statement.  That is not an error condition and the sources depend on it:
 * in CHAR and CHAR0 the card after the computed AGO is `AGO .INVCMSG`, reached
 * only when the operand's length is something other than 1 through 6.
 *
 * Returns the chosen sequence symbol, or NULL when nothing is to be branched to
 * -- either because the value was out of range, which is normal, or because the
 * operand could not be made sense of, in which case it has already complained.
 */
static const char *
computedAgoTarget (const char *operandField, Val *svLocals, Val *properties)
{
  int depthParen = 0;
  ptrdiff_t closeAt = -1;
  size_t i, n = strlen (operandField);
  char *expression;
  char **targets;
  size_t nTargets = 0;
  Val *ast;
  Val *nv;
  asmint value;

  /* Find the parenthesis matching the one the field opens with.  Counting
     rather than searching for the first `)` because the expression may itself
     be parenthesised or subscripted -- `(&N+1)`, `(&CCODE1(&I))`. */
  for (i = 0; i < n; i++)
    {
      if (operandField[i] == '(')
        depthParen++;
      else if (operandField[i] == ')')
        {
          depthParen--;
          if (depthParen == 0)
            {
              closeAt = (ptrdiff_t) i;
              break;
            }
        }
    }
  if (closeAt < 0)
    {
      asmError (properties,
                py_format ("Unbalanced parentheses in computed AGO: %s",
                           operandField),
                255);
      return NULL;
    }
  expression = arena_strndup (ARENA_MAIN, operandField + 1, (size_t) closeAt - 1);
  {
    char **fields;
    size_t nf = py_split_char (operandField + closeAt + 1, ',', &fields);
    size_t k;
    targets = (char **) arena_alloc (ARENA_MAIN, (nf + 1) * sizeof (char *));
    for (k = 0; k < nf; k++)
      if (fields[k][0] != '\0')
        targets[nTargets++] = fields[k];
  }
  if (nTargets == 0)
    {
      asmError (properties,
                py_format ("Computed AGO has no sequence symbols: %s",
                           operandField),
                255);
      return NULL;
    }
  ast = parserASM (expression, "setaOperand");
  if (ast == NULL)
    {
      asmError (properties,
                py_format ("Cannot parse computed AGO expression: %s",
                           expression),
                255);
      return NULL;
    }
  nv = evalArith (val_dget (ast, "v"), svLocals, properties);
  if (nv == NULL)
    {
      asmError (properties,
                py_format ("Cannot evaluate computed AGO expression: %s",
                           expression),
                255);
      return NULL;
    }
  value = val_as_int (nv);
  if (value < 1 || (size_t) value > nTargets)
    return NULL;
  return targets[value - 1];
}

static void
printTraceMessage (asmint depth, const char *name, const char *operation,
                   Val *operand, const char *extra)
{
  if (!trace)
    return;
  {
    char *msg = py_format ("Trace: %04d %02d    %-16s %-8s %s", (int) sysndx,
                           (int) depth, name, operation,
                           val_is_str (operand) ? val_cstr (operand)
                                                : val_str_of (operand));
    if (extra != NULL && extra[0] != '\0')
      printf ("%s %s\n", msg, extra);
    else
      printf ("%s\n", msg);
    fflush (stdout);
  }
}

/*
 * Convert the parsed form of a sublist into a `Sublist` of strings, nested to
 * whatever depth the source text was.  The parser hands a sublist over as
 *    ( '(', ( first, [ [',', item], ... ] ), ')' )
 * in which any item may itself be a sublist of the same shape.  Failing to
 * recurse here is what turned `(10,(100,200,300),30)` into the unusable
 * `(10,((,(100,((,,200),(,,300))),)),30)`.
 */
static Val *evalSublist (Val *properties, Val *ast);

static Val *
evalSublistEntry (Val *properties, Val *entry)
{
  if (val_is_str (entry))
    return entry;
  if (val_is_seq (entry) && val_len (entry) == 3
      && val_eq_str (val_get (entry, 0), "(")
      && val_eq_str (val_get (entry, 2), ")"))
    return evalSublist (properties, entry);
  {
    /* Something like `4(R3)`, which parses as a tuple of strings. */
    StrBuf b;
    size_t i;
    sb_init (&b);
    for (i = 0; i < val_len (entry); i++)
      {
        if (!val_is_str (val_get (entry, i)))
          {
            sb_free (&b);
            asmError (properties,
                      py_format ("Implementation error in sublist entry %s",
                                 val_str_of (entry)),
                      255);
            return val_str ("");
          }
        sb_add (&b, val_cstr (val_get (entry, i)));
      }
    return val_str (sb_take (&b));
  }
}

static Val *
evalSublist (Val *properties, Val *ast)
{
  Val *inner = val_get (ast, 1);
  Val *entries = val_seq (V_SUBLIST);
  size_t i;
  val_append (entries, evalSublistEntry (properties, val_get (inner, 0)));
  for (i = 0; i < val_len (val_get (inner, 1)); i++)
    val_append (entries,
                evalSublistEntry (properties,
                                  val_get (val_get (val_get (inner, 1), i), 1)));
  return entries;
}

/*
 * Try to evaluate a suboperand of a macro invocation, as returned by
 * `parserASM(..., "operandInvocation")`.  What is returned is a key and a
 * value:  `key` is the formal parameter (such as "&A") for a non-positional
 * parameter (such as `A=53`) and NULL for a positional one.
 */
static const char *
evalMacroArgument (Val *properties, Val *suboperand, Val **valueOut)
{
  *valueOut = V_None;
  /* A positional parameter that is just a bare, unquoted string. */
  if (val_is_str (suboperand))
    {
      *valueOut = suboperand;
      return NULL;
    }
  if (!val_is_seq (suboperand))
    {
      asmError (properties,
                py_format ("Implementation error in replacement argument %s",
                           val_str_of (suboperand)),
                255);
      *valueOut = NULL;
      return NULL;
    }
  /* A non-positional parameter that is just a bare, unquoted string. */
  if (val_len (suboperand) == 3 && val_eq_str (val_get (suboperand, 1), "=")
      && val_is_str (val_get (suboperand, 2)))
    {
      *valueOut = val_get (suboperand, 2);
      return py_concat ("&", val_cstr (val_get (suboperand, 0)));
    }
  /* A non-positional parameter that is a quoted string. */
  if (val_is_tuplelike (suboperand) && val_len (suboperand) == 6
      && val_eq_str (val_get (suboperand, 1), "=")
      && val_eq_str (val_get (suboperand, 2), "'")
      && val_eq_str (val_get (suboperand, 5), "'")
      && val_is_listlike (val_get (suboperand, 4))
      && val_len (val_get (suboperand, 4)) == 0
      && val_is_str (val_get (suboperand, 3)))
    {
      *valueOut = val_str (py_format ("'%s'", val_cstr (val_get (suboperand, 3))));
      return py_concat ("&", val_cstr (val_get (suboperand, 0)));
    }
  /* A non-positional parameter that is a sublist. */
  if (val_len (suboperand) == 5 && val_eq_str (val_get (suboperand, 1), "=")
      && val_eq_str (val_get (suboperand, 2), "(")
      && val_is_tuplelike (val_get (suboperand, 3))
      && val_eq_str (val_get (suboperand, 4), ")"))
    {
      *valueOut = evalSublist (properties, val_slice (suboperand, 2, 5));
      return py_concat ("&", val_cstr (val_get (suboperand, 0)));
    }
  /* A positional parameter that is a quoted string. */
  if (val_is_tuplelike (suboperand) && val_len (suboperand) == 4
      && val_eq_str (val_get (suboperand, 0), "'")
      && val_eq_str (val_get (suboperand, 3), "'")
      && val_is_listlike (val_get (suboperand, 2))
      && val_len (val_get (suboperand, 2)) == 0
      && val_is_str (val_get (suboperand, 1)))
    {
      *valueOut = val_str (py_format ("'%s'", val_cstr (val_get (suboperand, 1))));
      return NULL;
    }
  /* A positional parameter that is a sublist, such as `(1,2,A)`. */
  if (val_is_tuplelike (suboperand) && val_len (suboperand) == 3
      && val_eq_str (val_get (suboperand, 0), "(")
      && val_eq_str (val_get (suboperand, 2), ")")
      && val_is_tuplelike (val_get (suboperand, 1)))
    {
      *valueOut = evalSublist (properties, suboperand);
      return NULL;
    }
  {
    /* There are some replacements, like "4(R3)", that parse as a tuple of
       strings -- ( '4', '(', 'R3', ')' ) for that example. */
    StrBuf b;
    size_t i;
    int allStrings = 1;
    sb_init (&b);
    for (i = 0; i < val_len (suboperand); i++)
      {
        if (!val_is_str (val_get (suboperand, i)))
          {
            allStrings = 0;
            break;
          }
        sb_add (&b, val_cstr (val_get (suboperand, i)));
      }
    if (allStrings)
      {
        *valueOut = val_str (sb_take (&b));
        return NULL;
      }
    sb_free (&b);
  }
  /* Not a recognised shape.  Could be a coding error, but more likely
     something not yet implemented. */
  asmError (properties,
            py_format ("Implementation error in replacement argument %s",
                       val_str_of (suboperand)),
            255);
  *valueOut = NULL;
  return NULL;
}

/*-----------------------------------------------------------------------------
 * File reading
 */
static Val *
readLines (const char *filename)
{
  FILE *f = fopen (filename, "rb");
  Val *lines;
  StrBuf b;
  int c;
  if (f == NULL)
    return NULL;
  lines = val_seq (V_LIST);
  sb_init (&b);
  for (;;)
    {
      c = fgetc (f);
      if (c == '\r')
        continue; /* universal newlines, as Python's text mode gives */
      if (c == EOF && b.len == 0)
        break;
      if (c != EOF)
        sb_addc (&b, (char) c);
      if (c == '\n' || c == EOF)
        {
          val_append (lines, val_str (b.s ? b.s : ""));
          sb_clear (&b);
          if (c == EOF)
            break;
        }
    }
  sb_free (&b);
  fclose (f);
  return lines;
}

static int
fileExists (const char *path)
{
  FILE *f = fopen (path, "rb");
  if (f == NULL)
    return 0;
  fclose (f);
  return 1;
}

static char *
joinPath (const char *a, const char *b)
{
  size_t n = strlen (a);
  if (n > 0 && (a[n - 1] == '/' || a[n - 1] == '\\'))
    return py_concat (a, b);
  return py_concat (py_concat (a, PATH_SEPARATOR_STR), b);
}

/*
 * FETCH A LIBRARY MACRO ON DEMAND, by name, the way OS/360 fetches a SYSLIB
 * member:  the member's name IS the macro's name.  Returns true if `name` is
 * defined as a macro afterwards.
 *
 * WHY NOT SIMPLY READ THE WHOLE LIBRARY UP FRONT, which is what this did.
 * Every member read that way puts its cards into `source` AHEAD of the module,
 * and OI340600's library is 26,566 of them.  That is not merely slow:
 *
 *   - Sequence symbols are file-level, so a library member's `.END` becomes
 *     visible to the module's own open code.  FIOPDISP's `AGO .FIOMTU`, whose
 *     target is the very next card, started failing with "Target out of this
 *     macro" the moment the library was pre-read, and it has no COPY statement
 *     and invokes no library macro at all.
 *   - A member's OPEN code runs.  MACROS.asm is fifty-one open-code PDEF
 *     invocations behind a TITLE, and pre-reading it defined P1-P51 ahead of
 *     every module in the corpus.
 *
 * Reading a member only when something asks for it by name avoids both.  Don
 * Schmidt reached the same conclusion independently in asm101, which is where
 * the SYSLIB model here comes from.
 *
 * The member is read with its OWN sequence-symbol namespace rather than the
 * shared one, for the first reason above.
 */
static int
loadLibraryMacro (const char *name)
{
  size_t li;
  if (val_dhas (macros, name))
    return 1;
  if (val_dhas (noLibraryMember, name) || name[0] == '\0' || name[0] == '.'
      || name[0] == '&' || name[0] == '=')
    return 0;
  for (li = 0; li < val_len (libraries); li++)
    {
      const char *library = val_cstr (val_get (libraries, li));
      Val *members = val_dget (libraryMembers, library);
      int candidate;
      if (members == NULL || !val_dhas (members, name))
        {
          /*
           * Not a macro member of this library.  The index says which of its
           * members define macros and which are COPY fragments, and a COPY
           * fragment read as open code is what puts a DS outside any control
           * section.
           *
           * SAY SO WHEN THE MEMBER IS ACTUALLY THERE.  Most misses here are
           * ordinary -- the name is simply not a macro -- but a member that
           * EXISTS in the library and is not indexed is a probable index error,
           * and it is silent:  the invocation goes on to fail as an undefined
           * macro, naming the operation and never the cause.  That is what
           * FPMSWTCC did, and five modules failed for it before anyone looked
           * at MACROFILES.txt.
           */
          for (candidate = 0; candidate < 2; candidate++)
            {
              const char *cname
                  = candidate == 0 ? name : py_concat (name, ".asm");
              char *path = joinPath (library, cname);
              if (fileExists (path))
                {
                  char *key = py_format ("%s%c%s", library, '\1', cname);
                  if (!val_dhas (unindexedMembers, key))
                    {
                      val_dset (unindexedMembers, key, V_True);
                      fprintf (stderr,
                               "Warning: %s exists in %s but is not listed in"
                               " its MACROFILES.txt, so it cannot be fetched"
                               " as a macro; re-run makeMACROFILES.py if that"
                               " is wrong\n",
                               cname, library);
                    }
                  break;
                }
            }
          continue;
        }
      for (candidate = 0; candidate < 2; candidate++)
        {
          const char *cname = candidate == 0 ? name : py_concat (name, ".asm");
          char *path = joinPath (library, cname);
          if (fileExists (path))
            {
              readSourceFile (path, svGlobalLocals, val_dict (), 0, 0, 0);
              if (val_dhas (macros, name))
                return 1;
            }
        }
    }
  val_dset (noLibraryMember, name, V_True);
  return 0;
}

/*
 * Recursively read a batch of lines of source code, expanding if necessary for
 * the `COPY` pseudo-op or the invocation of a macro.  The parameters:
 *    fromWhere   Either a filename or the name of a macro.  The latter lets the
 *                macro definitions be read in once and reused as many times as
 *                wanted without rereading the file that contained them.
 *    svLocals    The symbolic variables "local" to a macro invocation.
 *                Initially the replacement values for the macro's formal
 *                parameters; LCLx and SETx within the macro alter it.
 *    sequence    A dictionary of sequence symbols encountered, and the line
 *                number at which they start.
 *    copy        The file is being read as the target of a `COPY`.
 *    printable   The file will be listed in the output assembly listing.  False
 *                for anything read from the macro library.
 *    depth       The depth into the macro expansion(s); 0 is open code.
 */
static void
readSourceFile (const char *fromWhere, Val *svLocals, Val *sequence, int copy,
                int printable, asmint depth)
{
  ptrdiff_t lineNumber;
  size_t firstIndexOfFile = val_len (source);
  int inMacroProto = 0;
  int inMacroDefinition = 0;
  const char *name = "";
  const char *operation = "";
  int continuePrototype = 0;
  Val *lineCorrespondence = val_seq (V_LIST);
  const char *mendLabel = NULL;
  Val *thisSource = NULL;
  const char *filename = NULL;
  const char *macroname = NULL;
  ptrdiff_t skipCount = 0;
  const char *skipToSeq = NULL;
  Val *properties = NULL;
  const char *macroName = "";
  size_t macroStart = 0;
  /*
   * The conditional-assembly loop counter.  It is decremented every time an AIF
   * or AGO branch is actually taken, and when it goes negative this expansion is
   * abandoned with a diagnostic.  That is the assembler's own guard against a
   * runaway AIF/AGO loop, and the AP-101S sources rely on it -- five files in
   * MLIB80 set it explicitly, ENDCASE with `ACTR 30000`.  Because
   * `readSourceFile` recurses once per macro expansion, a plain local gives each
   * expansion its own counter, which is the required scope.  4096 is the default
   * when no ACTR appears (SC26-4940).
   */
  asmint actr = 4096;

  if (val_dhas (macros, fromWhere))
    {
      /* Load the macro definition into the list of source-code lines. */
      Val *macroWhere = val_dget (macros, fromWhere);
      asmint start = val_as_int (val_get (macroWhere, 2));
      asmint protoIdx = val_as_int (val_get (macroWhere, 3));
      asmint end = val_as_int (val_get (macroWhere, 4));
      asmint fileStart = val_as_int (val_get (macroWhere, 5));
      asmint i;
      macroname = fromWhere;
      thisSource = val_seq (V_LIST);
      sequence = val_dict ();
      /* The MEND line is excluded from the body below, but a sequence symbol
         written ON it -- `.MEND    MEND` -- is the ordinary way to jump to the
         end of a macro, so remember it.  Branching there is not an error;
         running off the end of the body IS the branch. */
      mendLabel = py_strip (val_dget_str (val_get (source, (size_t) end), "name",
                                          ""));
      if (mendLabel[0] != '.')
        mendLabel = NULL;
      for (i = start; i <= end; i++)
        {
          Val *p = val_get (source, (size_t) i);
          if (i == start || i == end)
            continue;
          if (i == protoIdx)
            {
              if (val_dget_bool (p, "continues", 0))
                continuePrototype = 1;
              continue;
            }
          if (continuePrototype)
            {
              if (!val_dget_bool (p, "continues", 0))
                continuePrototype = 0;
              continue;
            }
          val_append (thisSource,
                      val_str (py_concat (val_dget_str (p, "text", ""),
                                          val_dget_bool (p, "continues", 0)
                                              ? "X"
                                              : " ")));
          val_append (lineCorrespondence, val_int (i - fileStart));
        }
    }
  else
    {
      thisSource = readLines (fromWhere);
      if (thisSource == NULL)
        {
          fprintf (stderr, "Source file '%s' does not exist\n", fromWhere);
          exit (1);
        }
      {
        size_t i;
        for (i = 0; i < val_len (thisSource); i++)
          val_append (lineCorrespondence, val_int ((asmint) i));
      }
      filename = fromWhere;
      macroname = NULL;
    }

  lineNumber = -1;
  while ((size_t) (lineNumber + 1) < val_len (thisSource))
    {
      const char *rawLine;
      char *line;
      char *text;

      lineNumber += 1;
      rawLine = val_cstr (val_get (thisSource, (size_t) lineNumber));
      if (skipToSeq != NULL
          && !py_startswith (rawLine, py_concat (skipToSeq, " ")))
        {
          /*
           * RECORD ANY SEQUENCE SYMBOL WE SKIP PAST.  A skipped line is never
           * parsed, so its symbol never reached `sequence`; a later branch BACK
           * to it then found nothing there, set `skipToSeq`, scanned FORWARD to
           * the end of the file, and silently discarded everything after it --
           * no diagnostic, no generated code, no clue.  In FIOCMPLT that
           * swallowed the last thousand lines, including the `GENERATE COPY=`
           * statements that define the control-block DSECTs.
           */
          char **fields;
          size_t nf = py_split_ws (rawLine, &fields);
          const char *symbol = nf > 0 ? fields[0] : "";
          if (strlen (symbol) > 1 && symbol[0] == '.' && symbol[1] != '*'
              && !val_dhas (sequence, symbol))
            {
              Val *where = val_seq (V_LIST);
              val_append (where, val_str (fromWhere));
              val_append (where, val_int (lineNumber));
              val_dset (sequence, symbol, where);
            }
          continue;
        }
      skipToSeq = NULL;

      line = padTo80 (rawLine);
      text = arena_strndup (ARENA_MAIN, line, 71);
      properties = val_dict ();
      val_dset (properties, "section", V_None);
      val_dset (properties, "pos1", V_None);
      val_dset (properties, "length", V_None);
      val_dset_int (properties, "alignment", 2);
      val_dset_str (properties, "text", text);
      val_dset_str (properties, "name", "");
      val_dset_str (properties, "operation", "");
      val_dset_str (properties, "operand", "");
      val_dset (properties, "file",
                filename == NULL ? V_None : val_str (filename));
      val_dset (properties, "macro",
                macroname == NULL ? V_None : val_str (macroname));
      val_dset_int (properties, "lineNumber", lineNumber + 1);
      /*
       * A CARD DOES NOT CONTINUE ONTO AN EXPANSION.  Columns 73-80 read
       * `nn-NAME` on a card the expander produced and a sequence number on one
       * somebody typed, so a typed card cannot be continued by a generated card
       * -- that card was not in the deck when this column 72 was punched.
       *
       * Corrected HERE rather than at the three places that consume it, which is
       * what makes one edit do the work:  `joinOperand` still reads column 72
       * off the card itself and needs its own guard, but the two gates that
       * DISCARD the card both read this flag.
       */
      val_dset_bool (properties, "continues",
                     continuesOnto (line, thisSource, (size_t) lineNumber));
      val_dset_str (properties, "identification", line + 72);
      val_dset_bool (properties, "empty", py_strip (text)[0] == '\0');
      val_dset_bool (properties, "fullComment", line[0] == '*');
      val_dset_bool (properties, "dotComment",
                     line[0] == '.' && line[1] == '*');
      val_dset_str (properties, "endComment", "");
      /* The parsed operand field, filled in by `generateObjectCode`.  It is
         created here, as None, so that the key always exists:  the code
         generator tests it for None in a dozen places, and a line that never
         reached the parsing step used to raise KeyError there instead. */
      val_dset (properties, "ast", V_None);
      val_dset (properties, "errors", val_seq (V_LIST));
      val_dset_bool (properties, "inMacroDefinition", inMacroDefinition);
      val_dset_bool (properties, "copy", copy);
      val_dset_bool (properties, "printable", printable);
      val_dset_bool (properties, "listOn", listOn);
      val_dset_int (properties, "depth", depth);
      val_dset_int (properties, "n", (asmint) val_len (source));
      val_append (source, properties);

      if (skipCount > 0)
        {
          skipCount -= 1;
          val_dset_bool (properties, "skip", 1);
          continue;
        }
      if (val_dget_bool (properties, "empty", 0)
          || val_dget_bool (properties, "fullComment", 0)
          || val_dget_bool (properties, "dotComment", 0))
        continue;
      /*
       * Skip a card that is the continuation of the one before it.  "The one
       * before it" means the previous line of THIS source -- this file, or this
       * macro body -- and it used to be read as `source[-2]`, the previous entry
       * of the GLOBAL line list, which is a different thing at the boundary
       * between them.  When a macro body began expanding, `source[-2]` was the
       * caller's invocation line, so a CONTINUED INVOCATION made the assembler
       * discard the FIRST STATEMENT OF THE MACRO BODY.
       *
       * In FCMSFAIL that lost the `PUSHNEST IF` from all seven of the IF
       * invocations written across two cards, while the thirty-one written on
       * one card kept it; the nesting stack then went negative, and EXIT's
       * search loop ran until ACTR stopped it 4096 iterations later.  That one
       * line accounted for over sixteen thousand diagnostics.
       */
      if (lineNumber > 0)
        {
          char *previous
              = padTo80 (val_cstr (val_get (thisSource, (size_t) lineNumber - 1)));
          if (continuesOnto (previous, thisSource, (size_t) lineNumber - 1))
            continue;
        }

      /* Note that while `parseLine` determines how `inMacroDefinition` and
         `inMacroProto` will change, we make our own determination here, because
         we want to do some things with macro definitions that `parseLine` does
         not do for us. */
      skipCount = parseLine (thisSource, (size_t) lineNumber, inMacroDefinition,
                             inMacroProto);
      name = val_dget_str (properties, "name", "");
      if (name[0] == '.')
        {
          /* Note that the `fromWhere` stored in the symbol *should* be
             completely irrelevant to anything and should not be used. */
          Val *where = val_seq (V_LIST);
          val_append (where, val_str (fromWhere));
          val_append (where, val_int (lineNumber));
          val_dset (sequence, name, where);
        }
      operation = val_dget_str (properties, "operation", "");
      {
        Val *operandVal = val_dget (properties, "operand");
        const char *operand = val_is_str (operandVal) ? val_cstr (operandVal) : NULL;

        if (strcmp (operation, "PRINT") == 0)
          {
            if (!inMacroDefinition)
              {
                if (operand != NULL && strcmp (operand, "ON") == 0)
                  {
                    listOn = 1;
                    val_dset_bool (properties, "listOn", 0);
                  }
                else if (operand != NULL && strcmp (operand, "OFF") == 0)
                  {
                    listOn = 0;
                    val_dset_bool (properties, "listOn", 0);
                  }
                continue;
              }
          }

        if (strcmp (operation, "MACRO") == 0)
          {
            inMacroProto = 1;
            inMacroDefinition = 1;
            macroStart = val_len (source) - 1;
            val_dset_bool (properties, "inMacroDefinition", 1);
          }
        else if (inMacroProto)
          {
            /* This line gives the "prototype" of the macro:  the name, the
               number of positional parameters, and the number of non-positional
               ones. */
            asmint positional = 0, nonpositional = 0;
            Val *pformals = parserASM (operand == NULL ? "" : operand,
                                       "operandPrototype");
            Val *entry;
            inMacroProto = 0;
            if (pformals != NULL && val_dhas (pformals, "pi"))
              {
                Val *pi = val_dget (pformals, "pi");
                size_t k;
                for (k = 0; k < val_len (pi); k++)
                  {
                    Val *sub = val_get (pi, k);
                    /* `"=" in sub` -- a substring test for a string, a
                       membership test for a tuple; both are true exactly when
                       the parameter carries a default. */
                    int hasEquals = 0;
                    if (val_is_str (sub))
                      hasEquals = strchr (val_cstr (sub), '=') != NULL;
                    else
                      {
                        size_t m;
                        for (m = 0; m < val_len (sub); m++)
                          if (val_eq_str (val_get (sub, m), "="))
                            hasEquals = 1;
                      }
                    if (hasEquals)
                      nonpositional += 1;
                    else
                      positional += 1;
                  }
              }
            macroName = operation;
            entry = val_seq (V_LIST);
            val_append (entry, val_int (positional));
            val_append (entry, val_int (positional + nonpositional));
            val_append (entry, val_int ((asmint) macroStart));
            val_append (entry, val_int ((asmint) (val_len (source) - 1)));
            val_dset (macros, macroName, entry);
          }
        else if (strcmp (operation, "MEND") == 0)
          {
            Val *entry = val_dget (macros, macroName);
            if (entry != NULL)
              {
                val_append (entry, val_int ((asmint) (val_len (source) - 1)));
                val_append (entry, val_int ((asmint) firstIndexOfFile));
              }
            inMacroDefinition = 0;
            continue;
          }
        else if (strcmp (operation, "COPY") == 0)
          {
            int found = 0;
            size_t li;
            char **fields;
            size_t nf = py_split_ws (line, &fields);
            const char *fname
                = (line[0] == ' ') ? (nf > 1 ? fields[1] : "")
                                   : (nf > 2 ? fields[2] : "");
            for (li = 0; li < val_len (libraries); li++)
              {
                const char *library = val_cstr (val_get (libraries, li));
                char *fcopy = joinPath (library, py_concat (fname, ".asm"));
                if (fileExists (fcopy))
                  {
                    found = 1;
                    readSourceFile (fcopy, svLocals, sequence, 1, printable,
                                    depth);
                    break;
                  }
              }
            if (!found)
              {
                fprintf (stderr, "File %s.asm for COPY not found\n", fname);
                exit (1);
              }
            continue;
          }

        if (inMacroDefinition)
          continue;

        /* Take care of the various macro-language pseudo-ops. */
        if (strcmp (operation, "MEXIT") == 0)
          break;
        if (strcmp (operation, "GBLA") == 0 || strcmp (operation, "GBLB") == 0
            || strcmp (operation, "GBLC") == 0 || strcmp (operation, "LCLA") == 0
            || strcmp (operation, "LCLB") == 0 || strcmp (operation, "LCLC") == 0)
          {
            svDeclare (operation, operand == NULL ? "" : operand, svLocals,
                       properties);
            continue;
          }
        if (strcmp (operation, "SETA") == 0 || strcmp (operation, "SETB") == 0
            || strcmp (operation, "SETC") == 0)
          {
            printTraceMessage (depth, name, operation, operandVal, "");
            svSet (operation, name, operand == NULL ? "" : operand, svLocals,
                   properties);
            continue;
          }
        if (strcmp (operation, "ACTR") == 0)
          {
            Val *ast;
            Val *nv;
            printTraceMessage (depth, name, operation, operandVal, "");
            ast = parserASM (py_rstrip (operand == NULL ? "" : operand),
                             "setaOperand");
            if (ast == NULL)
              {
                asmError (properties,
                          py_format ("Cannot parse ACTR operand %s", operand),
                          255);
                continue;
              }
            nv = evalArith (val_dget (ast, "v"), svLocals, properties);
            if (nv == NULL)
              {
                asmError (properties,
                          py_format ("Cannot evaluate ACTR operand %s", operand),
                          255);
                continue;
              }
            actr = val_as_int (nv);
            continue;
          }
        if (strcmp (operation, "AGO") == 0)
          {
            char **fields;
            size_t nf;
            const char *target;
            printTraceMessage (depth, name, operation, operandVal, "");
            /* The operand field ends at the first blank; what follows is a
               comment.  `rstrip()` alone left the comment attached to the
               target, so `AGO .LOOP    *** LABEL ...` looked for a sequence
               symbol whose name included the comment, never found it, and
               silently skipped the rest of the macro or file. */
            nf = py_split_ws (operand == NULL ? "" : operand, &fields);
            target = nf > 0 ? fields[0] : "";
            if (target[0] == '(')
              {
                target = computedAgoTarget (target, svLocals, properties);
                if (target == NULL)
                  {
                    /* Out of range, so no branch is taken at all.  Fall through
                       to the next statement WITHOUT charging ACTR:  a branch not
                       taken is not a branch, the same rule AIF already
                       follows. */
                    continue;
                  }
              }
            actr -= 1;
            if (actr < 0)
              {
                asmError (properties, actrMessage (fromWhere), 255);
                break;
              }
            /*
             * A BRANCH TAKEN ABANDONS THIS STATEMENT'S CONTINUATION CARDS.
             * `skipCount` still holds the number of cards `parseLine` consumed
             * for THIS statement, and the top of the loop uses it to skip
             * whatever comes next -- which, after a branch, is the TARGET, not a
             * continuation.  So a CONTINUED AIF or AGO landed one card late and
             * the target card was silently skipped, with no diagnostic of any
             * kind.  STKINS is where this cost bytes:  GETCC never ran and
             * &CCVAL kept the value left by the PREVIOUS condition, so `IF (LT)`
             * after an `IF (...EQ...)` assembled with the EQ mask.
             */
            skipCount = 0;
            if (val_dhas (sequence, target))
              {
                Val *where = val_dget (sequence, target);
                if (strcmp (fromWhere, val_cstr (val_get (where, 0))) != 0)
                  {
                    ERROR (properties, "Target out of this macro");
                    continue;
                  }
                lineNumber = val_as_int (val_get (where, 1)) - 1;
              }
            else
              skipToSeq = target;
            continue;
          }
        if (strcmp (operation, "AIF") == 0)
          {
            Val *ast;
            char *rstripped = py_rstrip (operand == NULL ? "" : operand);
            printTraceMessage (depth, name, operation, operandVal, "");
            ast = parserASM (rstripped, "aifAll");
            if (ast != NULL && val_is_dict (ast) && val_dhas (ast, "exp")
                && val_dhas (ast, "seq"))
              {
                const char *target
                    = val_cstr (val_get (val_dget (ast, "seq"), 0));
                Val *expression = val_dget (ast, "exp");
                Val *passFail
                    = evalBooleanExpression (expression, svLocals, properties);
                if (passFail == NULL)
                  {
                    asmError (properties,
                              py_format ("Cannot evaluate %s",
                                         val_str_of (expression)),
                              255);
                    continue;
                  }
                if (!val_truthy (passFail))
                  continue;
                /* The conditional test has passed, so "go to" the selected
                   sequence symbol.  Only a branch actually taken is counted
                   against ACTR; an AIF whose condition is false is not a
                   branch. */
                actr -= 1;
                if (actr < 0)
                  {
                    asmError (properties, actrMessage (fromWhere), 255);
                    break;
                  }
                /* Same as AGO above: a branch taken abandons this statement's
                   continuation cards. */
                skipCount = 0;
                if (val_dhas (sequence, target))
                  {
                    Val *where = val_dget (sequence, target);
                    if (strcmp (fromWhere, val_cstr (val_get (where, 0))) != 0)
                      {
                        ERROR (properties, "Target out of this macro");
                        continue;
                      }
                    lineNumber = val_as_int (val_get (where, 1)) - 1;
                  }
                else
                  skipToSeq = target;
                continue;
              }
            asmError (properties,
                      py_concat ("Unrecognized AIF operand: ", rstripped), 255);
            continue;
          }
        if (strcmp (operation, "ANOP") == 0)
          {
            printTraceMessage (depth, name, operation, operandVal, "");
            continue;
          }
        if (strcmp (operation, "MNOTE") == 0)
          {
            Val *ast = parserASM (operand == NULL ? "" : operand, "mnote");
            if (ast == NULL)
              asmError (properties,
                        py_concat ("Cannot parse MNOTE: ",
                                   operand == NULL ? "" : operand),
                        255);
            else
              {
                Val *msgAst = unroll (val_dget (ast, "msg"));
                char *msg = val_len (msgAst) > 1
                                ? arena_strdup (ARENA_MAIN,
                                                val_cstr (val_get (msgAst, 1)))
                                : arena_strdup (ARENA_MAIN, "");
                msg = svReplace (properties, msg, svLocals);
                if (val_dhas (ast, "com"))
                  {
                    /* An MNOTE * is a comment and carries no severity. */
                  }
                else if (val_dhas (ast, "sev"))
                  {
                    asmint sev = 0;
                    py_parse_int (val_cstr (val_get (val_dget (ast, "sev"), 0)),
                                  &sev);
                    asmError (properties, msg, sev);
                  }
                val_dset_bool (properties, "fullComment", 1);
                val_dset_str (properties, "text", msg);
                val_dset_str (properties, "name", "");
                val_dset_str (properties, "operation", "");
                val_dset_str (properties, "operand", "");
                val_dset_bool (properties, "mnote", 1);
              }
            continue;
          }

        /*
         * Symbolic-variable replacement.
         *
         * THE TEST IS ON THE JOINED FIELDS, NOT ON THE FIRST CARD.  `line` is
         * only the card the statement starts on, and a continued statement can
         * carry its only variable on a LATER card.  FCMBMTMC has three BMTENT
         * invocations within a few lines of each other, all continued and all
         * ending in `&AERRLBL`; the one with no variable on its first card was
         * not substituted, so `&AERRLBL` reached BMTENT as literal text and
         * assembled as an undefined symbol.
         *
         * svReplace already returns immediately when there is no `&`, so the
         * guard was only ever an optimisation; computing it from the wrong text
         * made it a filter.
         */
        if (strchr (line, '&') != NULL
            || strchr (py_format ("%s%s%s", name, operation,
                                  operand == NULL ? "" : operand),
                       '&')
                   != NULL)
          {
            val_dset_str (properties, "rawName", name);
            val_dset_str (properties, "rawOperation", operation);
            val_dset_str (properties, "rawOperand",
                          operand == NULL ? "" : operand);
            name = svReplace (properties, name, svLocals);
            operation = svReplace (properties, operation, svLocals);
            operand = svReplace (properties, operand == NULL ? "" : operand,
                                 svLocals);
            val_dset_str (properties, "name", name);
            val_dset_str (properties, "operation", operation);
            val_dset_str (properties, "operand", operand);
            operandVal = val_dget (properties, "operand");
          }

        /*
         * FETCH THE MACRO BEFORE ANYTHING ASKS WHETHER THIS IS ONE.  The block
         * just below declines to register the name field of a macro invocation,
         * leaving that to the expansion, and it decides by asking whether the
         * operation is a known macro.  Loading at the point of expansion instead
         * is too late by exactly those few lines:  `ASIN AENTRY ...` registered
         * ASIN as an ordinary label AND then expanded a macro that defines it,
         * so every RUNASM module carrying a secondary entry point died with
         * "Already defined".
         */
        if (!val_dhas (macros, operation)
            && pairmap_get (&pseudoOps, operation) == NULL)
          loadLibraryMacro (operation);
        if (name[0] != '\0' && name[0] != '.' && name[0] != '&'
            && strcmp (operation, "TITLE") != 0
            && strcmp (operation, "CSECT") != 0
            && strcmp (operation, "DSECT") != 0
            && !val_dhas (macros, operation))
          {
            if (!val_dhas (definedNormalSymbols, name))
              {
                Val *e = val_dict ();
                val_dset_bool (e, "label", 1);
                val_dset_str (e, "fromWhere", fromWhere);
                val_dset_int (e, "lineNumber", lineNumber);
                val_dset (e, "fromLine",
                          val_get (lineCorrespondence, (size_t) lineNumber));
                val_dset (definedNormalSymbols, name, e);
              }
            else
              asmError (properties, py_concat ("Already defined: ", name), 255);
          }
        else if (strcmp (operation, "EXTRN") == 0)
          {
            /*
             * STRIP EACH NAME.  The operand arrives padded out to column 71, so
             * splitting it on commas registered `FC$BUSPC` followed by fifty
             * blanks, and every later lookup of the bare name missed.  That is
             * what made `D'` blind to an EXTRN:  RETURN decides whether to
             * restore the registers with `AIF (D'&SAVAREA).RESTORE`, and with
             * the test false it generated a bare `BR 7` and no `LM`, leaving the
             * section TWO HALFWORDS SHORT.  33 SSW modules were short by exactly
             * that.
             *
             * A SHORT SECTION IS WORSE THAN A WRONG HALFWORD, because everything
             * after it is displaced.
             *
             * THE OPERAND FIELD ENDS AT THE FIRST BLANK and what follows is a
             * comment, which is why taking the whole field was not enough.
             */
            char **words;
            size_t nw = py_split_ws (operand == NULL ? "" : operand, &words);
            char **symbols;
            size_t ns = py_split_char (nw > 0 ? words[0] : "", ',', &symbols);
            size_t k;
            for (k = 0; k < ns; k++)
              {
                const char *symbol = py_strip (symbols[k]);
                if (symbol[0] == '\0')
                  continue;
                if (!val_dhas (definedNormalSymbols, symbol))
                  {
                    Val *e = val_dict ();
                    val_dset_bool (e, "label", 1);
                    val_dset_str (e, "fromWhere", fromWhere);
                    val_dset_int (e, "lineNumber", lineNumber);
                    val_dset (e, "fromLine",
                              val_get (lineCorrespondence, (size_t) lineNumber));
                    val_dset (definedNormalSymbols, symbol, e);
                  }
              }
          }

        /*
         * RECORD AN EQU'S LENGTH ATTRIBUTE AS SOON AS IT IS GENERATED.
         *
         * This is the interleaving that lets one macro use what an earlier one
         * defined.  The statement has been through `svReplace` just above, so
         * `&N.X EQU &X,&X+1025,C'@'` has become `P2X EQU -456,-456+1025,C'@'`
         * and its length operand is now ordinary arithmetic; recording it here
         * makes it visible to every POS expanded after this point, and to
         * nothing expanded before it.
         *
         * MOST EQUs CANNOT BE EVALUATED HERE AND THAT IS NORMAL.  `FOO EQU
         * BAR+4` names a symbol no pass has defined yet, so the evaluation fails
         * and nothing is recorded -- the passes settle it later exactly as
         * before.  `evalQuietly` is what keeps that silent.
         *
         * It is a FALLBACK only.  Once the real symbol table is built, the entry
         * there wins.
         */
        if (strcmp (operation, "EQU") == 0 && name[0] != '\0' && name[0] != '.'
            && name[0] != '&')
          {
            Val *equAst = parserASM (py_rstrip (operand == NULL ? "" : operand),
                                     "equOperand");
            if (equAst != NULL)
              {
                if (val_dhas (equAst, "len")
                    && val_len (val_dget (equAst, "len")) > 0)
                  {
                    Val *lv = evalQuietly (val_get (val_dget (equAst, "len"), 0),
                                           svLocals, NULL);
                    if (lv != NULL)
                      {
                        if (!val_dhas (readTimeSymbols, name))
                          val_dset (readTimeSymbols, name, val_dict ());
                        val_dset (val_dget (readTimeSymbols, name),
                                  "lengthAttribute", lv);
                      }
                  }
                /*
                 * THE TYPE ATTRIBUTE IS NEEDED HERE TOO, and for the same
                 * reason.  PDEF types its position symbols with a third operand
                 * -- `&N EQU 1,1,C'#'` -- and both POS and VECTOR branch on the
                 * answer, so a symbol whose type was not yet recorded fell
                 * through to `INVALID SPECIFICATION: P37`.  Recording the length
                 * alone was tried and left exactly those four MNOTEs standing in
                 * MENU12.
                 */
                if (val_dhas (equAst, "typc")
                    && val_len (val_dget (equAst, "typc")) > 0)
                  {
                    const char *tc = characterTermValue (
                        val_get (val_dget (equAst, "typc"), 0));
                    if (tc != NULL && tc[0] != '\0')
                      {
                        if (!val_dhas (readTimeSymbols, name))
                          val_dset (readTimeSymbols, name, val_dict ());
                        val_dset_str (val_dget (readTimeSymbols, name),
                                      "typeAttribute", py_substr (tc, 0, 1));
                      }
                  }
              }
          }

        if (val_dhas (macros, operation))
          {
            Val *macrostats = val_dget (macros, operation);
            Val *formalsVal
                = val_dget (val_get (source,
                                     (size_t) val_as_int (val_get (macrostats, 3))),
                            "operand");
            Val *pformals = parserASM (val_is_str (formalsVal)
                                           ? val_cstr (formalsVal)
                                           : "",
                                       "operandPrototype");
            Val *poperands;
            Val *newLocals;
            Val *syslist;
            Val *keyFormals;
            const char *fname;
            size_t k;
            asmint positionalIndex = 0;

            sysndx += 1;
            if (operand == NULL || py_strip (operand)[0] == '\0')
              poperands = val_seq (V_LIST);
            else
              poperands = parserASM (operand, "operandInvocation");
            if (poperands != NULL && val_is_dict (poperands)
                && val_dhas (poperands, "pi"))
              poperands = val_dget (poperands, "pi");
            else
              poperands = val_seq (V_LIST);
            if (pformals != NULL && val_is_dict (pformals)
                && val_dhas (pformals, "pi"))
              pformals = val_retype (val_dget (pformals, "pi"), V_LIST);
            else
              pformals = val_seq (V_LIST);

            /* Relate the formal parameters to their replacements. */
            newLocals = val_dict ();
            {
              Val *parent = val_seq (V_LIST);
              val_append (parent, val_str (fromWhere));
              val_append (parent, val_int (lineNumber));
              val_append (parent,
                          val_get (lineCorrespondence, (size_t) lineNumber));
              val_append (parent, svLocals);
              val_dset (newLocals, "parent", parent);
            }
            fname = val_dget_str (val_get (source,
                                           (size_t) val_as_int (
                                               val_get (macrostats, 3))),
                                  "name", "");
            if (fname[0] != '\0')
              val_dset_str (newLocals, fname, name);
            syslist = val_seq (V_LIST);
            keyFormals = val_seq (V_LIST);
            /* First fill in all default values, walking backwards so that the
               keyword parameters can be deleted from the positional list as they
               are found. */
            for (k = val_len (pformals); k-- > 0;)
              {
                Val *pformal = val_get (pformals, k);
                if (val_is_str (pformal))
                  {
                    Val *meta = val_dict ();
                    val_dset_str (newLocals, val_cstr (pformal), "");
                    val_dset_bool (meta, "omitted", 1);
                    val_dset (newLocals, py_concat ("_", val_cstr (pformal)),
                              meta);
                  }
                else if (val_is_seq (pformal))
                  {
                    Val *meta;
                    if (val_len (pformal) != 3
                        || !val_eq_str (val_get (pformal, 1), "=")
                        || !val_is_str (val_get (pformal, 0))
                        || val_cstr (val_get (pformal, 0))[0] != '&'
                        || !val_is_str (val_get (pformal, 2)))
                      {
                        asmError (properties,
                                  py_format ("Unrecognized format for formal "
                                             "parameter %s",
                                             val_str_of (pformal)),
                                  255);
                        continue;
                      }
                    meta = val_dict ();
                    val_dset (newLocals, val_cstr (val_get (pformal, 0)),
                              val_get (pformal, 2));
                    val_dset_bool (meta, "omitted", 1);
                    val_dset (newLocals,
                              py_concat ("_", val_cstr (val_get (pformal, 0))),
                              meta);
                    val_remove_at (pformals, k);
                  }
                else
                  {
                    asmError (properties,
                              py_format ("Implementation error in formal "
                                         "parameter %s",
                                         val_str_of (pformal)),
                              255);
                    continue;
                  }
              }
            /* Now do the replacements. */
            for (k = 0; k < val_len (poperands); k++)
              {
                Val *value;
                const char *key = evalMacroArgument (properties,
                                                     val_get (poperands, k),
                                                     &value);
                if (value == NULL)
                  continue;
                if (key == NULL)
                  {
                    val_append (syslist, value);
                    if ((size_t) positionalIndex >= val_len (pformals))
                      {
                        /* This can happen when there is a comment but no
                           positional replacement arguments in a macro
                           invocation and the first word of the comment has been
                           parsed as the operand field; it is harmless. */
                        continue;
                      }
                    {
                      const char *formal
                          = val_cstr (val_get (pformals, (size_t) positionalIndex));
                      Val *meta = val_dget (newLocals, py_concat ("_", formal));
                      val_dset (newLocals, formal, value);
                      if (meta != NULL && val_is_dict (meta))
                        val_dset_bool (meta, "omitted", 0);
                    }
                    positionalIndex += 1;
                  }
                else
                  {
                    Val *meta = val_dget (newLocals, py_concat ("_", key));
                    val_append (keyFormals, val_str (key));
                    val_dset (newLocals, key, value);
                    if (meta != NULL && val_is_dict (meta))
                      val_dset_bool (meta, "omitted", 0);
                  }
              }
            val_dset (newLocals, "&SYSLIST", val_retype (syslist, V_SUBLIST));
            val_dset_str (newLocals, "&SYSLIST0", name);
            val_dset_int (newLocals, "&SYSNDX", sysndx);
            if (trace)
              {
                StrBuf extra;
                sb_init (&extra);
                for (k = 0; k < val_len (keyFormals); k++)
                  {
                    const char *key = val_cstr (val_get (keyFormals, k));
                    sb_addf (&extra, " %s=%s", key,
                             val_str_of (val_dget (newLocals, key)));
                  }
                printTraceMessage (depth, name, operation, syslist,
                                   extra.s ? extra.s : "");
                sb_free (&extra);
              }
            readSourceFile (operation, newLocals, sequence, copy, printable,
                            depth + 1);
          }
      }
    }

  /* Falling off the end still looking for a sequence symbol means everything
     from the branch onwards was discarded.  Say so.  Silently swallowing the
     rest of a file or a macro is the worst way for this to fail, and it is how
     it used to fail. */
  if (skipToSeq != NULL && (mendLabel == NULL || strcmp (skipToSeq, mendLabel) != 0))
    asmError (properties,
              py_format ("Branch to %s in %s: the sequence symbol was never "
                         "found, so the rest of it was skipped",
                         skipToSeq, fromWhere),
              255);
}

/* Read an entire macro library. */
static void
readMacroLibrary (const char *dir)
{
  char *path = joinPath (dir, "MACROFILES.txt");
  FILE *f = fopen (path, "rt");
  Val *macroFiles;
  Val *members;
  char lineBuf[512];
  if (f == NULL)
    {
      fprintf (stderr, "Cannot open %s\n", path);
      exit (1);
    }
  val_append (libraries, val_str (dir));
  macroFiles = val_dict ();
  while (fgets (lineBuf, sizeof (lineBuf), f) != NULL)
    {
      char *s = py_strip (lineBuf);
      if (s[0] == '\0' || s[0] == ';') /* a comment or whitespace */
        continue;
      val_dset (macroFiles, s, V_True);
    }
  fclose (f);
  /*
   * WHAT THE INDEX NOW DRIVES.  It used to be the list of members read ahead of
   * the module; it is now the list of members ELIGIBLE to be fetched when
   * something invokes them.  Same file, same meaning -- which members define
   * macros and which are for COPY -- but consulted at the moment of use.
   * `makeMACROFILES.py` maintains it and must be re-run whenever the library
   * gains members.
   */
  members = val_dict ();
  {
    size_t i;
    for (i = 0; i < val_dlen (macroFiles); i++)
      {
        const char *m = val_dkey (macroFiles, i);
        if (py_endswith (m, ".asm"))
          val_dset (members, py_substr (m, 0, strlen (m) - 4), V_True);
        else
          val_dset (members, m, V_True);
      }
  }
  val_dset (libraryMembers, dir, members);
  if (!preReadLibraries)
    return;
  /* The pre-reading path is retained but disabled; see `loadLibraryMacro`. */
}

/*=============================================================================
 * Output formatting helpers.
 *
 * Python's `"%06X" % n` on a NEGATIVE value writes a minus sign and pads the
 * magnitude, where C's would print the two's complement.  A negative address
 * really occurs -- an ENTRY may sit before its own section -- so the difference
 * is not hypothetical.
 */
static char *
hexPad (asmint v, int width)
{
  char digits[32];
  int negative = v < 0;
  asmuint mag = negative ? ((asmuint) 0 - (asmuint) v) : (asmuint) v;
  int n = 0;
  char *out;
  int i, pad;
  if (mag == 0)
    digits[n++] = '0';
  while (mag > 0)
    {
      int d = (int) (mag & 0xF);
      digits[n++] = (char) (d < 10 ? '0' + d : 'A' + d - 10);
      mag >>= 4;
    }
  pad = width - n - (negative ? 1 : 0);
  if (pad < 0)
    pad = 0;
  out = (char *) arena_alloc (ARENA_MAIN, (size_t) (n + pad + 2));
  i = 0;
  if (negative)
    out[i++] = '-';
  while (pad-- > 0)
    out[i++] = '0';
  while (n-- > 0)
    out[i++] = digits[n];
  out[i] = '\0';
  return out;
}

/*
 * A peculiar collation for sorting the symbol table on the printout.  It is not
 * EBCDIC, nor ASCII.  The alphanumeric ordering seems normal, but the other
 * "letters" (#, @, $) follow the alphanumerics -- or at least the alphabetics.
 * There is no example whatever with @, so it is left in its ASCII place.
 */
static char *
sortOrder (const char *s)
{
  size_t n = strlen (s), i;
  char *out = arena_strndup (ARENA_MAIN, s, n);
  for (i = 0; i < n; i++)
    {
      if (out[i] == '$')
        out[i] = 'a';
      else if (out[i] == '#')
        out[i] = 'b';
    }
  return out;
}

typedef struct
{
  const char *key;
  char *sortKey;
  size_t index;
} SortEntry;

static int
compareSortEntries (const void *a, const void *b)
{
  const SortEntry *x = (const SortEntry *) a;
  const SortEntry *y = (const SortEntry *) b;
  int c = strcmp (x->sortKey, y->sortKey);
  if (c != 0)
    return c;
  /* Python's sort is stable, so equal keys keep their original order.  Two
     distinct symbols can collide here -- `A$` and `Aa` both fold to `Aa` -- so
     this is not merely tidiness. */
  return x->index < y->index ? -1 : (x->index > y->index ? 1 : 0);
}


/*
 * Print where this program came from.  `--version` gives the whole of it and
 * `--help` names the commit, because the question "which ASM101S is this?" is
 * most often asked by someone who has just typed --help to find out what the
 * program is.
 */
static void
printProvenance (int full)
{
  printf ("%s %s -- C port, executable ASM101Sa\n", program, version);
  printf ("Ported from ASM101S.py at virtualagc commit %s (%s)\n",
          PORTED_FROM_COMMIT, PORTED_FROM_DATE);
  if (!full)
    return;
  printf ("    %s\n", PORTED_FROM_SUBJECT);
#ifdef PORTED_EXTRAS
  printf ("Additionally carries:\n    %s\n", PORTED_EXTRAS);
#endif
#ifdef PARITY_INCOMPLETE
  printf ("PARITY IS INCOMPLETE: %s\n", PARITY_INCOMPLETE);
#endif
}

/*=============================================================================
 * Main
 */
int
main (int argc, char *argv[])
{
  const char *objectFileName = NULL;
  int sourceFileCount = 0;
  /*
   * 7, so that severities up to and including 7 are tolerated and 8 upwards are
   * not.  That is the System/360 convention:  MNOTE severities become the
   * assembly's return code, and 0/4 are informational and warning while 8 is an
   * error, 12 severe and 16 terminal.
   *
   * The AP-101S sources are written to it.  Across MLIB80 and RUNMAC the MNOTE
   * severities are 1 (50 of them), 2, 3, 4 (54), 5 and 6 -- and then jump
   * straight to 8 (73), 9, 10, 12 and 16, with nothing in between.  The gap
   * between 6 and 8 is where the boundary belongs.
   */
  asmint tolerableSeverity = 7;
  Val *sourceFileNames;
  const char *comparisonFile = NULL;
  Listing *comparisonSects = NULL;
  Val *comparisonAssigned = NULL;
  int forceD = 1;
  int i;
  asmint errorCount, maxSeverity;

  arena_init ();
  expressions_init ();
  {
    time_t now = time (NULL);
    struct tm *lt = localtime (&now);
    if (lt != NULL)
      strftime (currentDate, sizeof (currentDate), "%m/%d/%y", lt);
    else
      strcpy (currentDate, "00/00/00");
  }

  source = val_seq (V_LIST);
  macros = val_dict ();
  sequenceGlobalLocals = val_dict ();
  libraries = val_seq (V_LIST);
  libraryMembers = val_dict ();
  unindexedMembers = val_dict ();
  noLibraryMember = val_dict ();
  sourceFileNames = val_seq (V_LIST);

  val_dset_int (svGlobals, "_passCount", -1);
  val_dset_str (svGlobals, "&SYSPARM", "PASS");
  for (i = 1; i < argc; i++)
    {
      if (strcmp (argv[i], "--trace") == 0)
        trace = 1;
      else if (strcmp (argv[i], "--force-d") == 0)
        forceD = 1;
      else if (strcmp (argv[i], "--no-force-d") == 0)
        forceD = 0;
      else if (strcmp (argv[i], "--390") == 0)
        {
          fprintf (stderr, "System/390 support not presently available.\n");
          return 1;
        }
      else if (strcmp (argv[i], "--version") == 0)
        {
          /* Answered here, in the pre-scan, so that it needs no source file
             and assembles nothing first.  It exits 0 where --help exits 1;
             --help's status is ASM101S.py's and is matched deliberately,
             while --version is new here and takes the conventional one. */
          printProvenance (1);
          return 0;
        }
    }
  /*
   * Always-true (by default) global SETB, undeclared by default so that any
   * source file can reference &ASM101S directly without the assembler forcing a
   * declaration on it.  A source file that wants to detect "am I being assembled
   * by ASM101S specifically" declares `GBLB &ASM101S` itself; since svDeclare
   * no-ops on a global that already exists, that self-declaration harmlessly
   * preserves this True value, while the identical `GBLB &ASM101S` assembled by
   * any other assembler freshly declares it defaulting to false.  This lets a
   * file carry a deliberate, reversible divergence from historical fidelity that
   * is completely inert to any other assembler.
   *
   * --no-rtl-fixes overrides this to False, reproducing a genuine historical
   * assembler's lack of any RTL-fix knowledge.  The RTL fixes gated this way are
   * real bug fixes, but they also change the object-code size of whatever module
   * they are in, which cascades into the linker's memory-image layout for
   * everything after it.
   *
   * Checked HERE, before any source file is read, rather than in the parsing
   * loop below, so that it takes effect regardless of where it appears relative
   * to the source-file arguments.
   */
  {
    int noRtlFixes = 0;
    for (i = 1; i < argc; i++)
      if (strcmp (argv[i], "--no-rtl-fixes") == 0)
        noRtlFixes = 1;
    val_dset (svGlobals, "&ASM101S", val_bool (!noRtlFixes));
  }
  model101_init (forceD);

  for (i = 1; i < argc; i++)
    {
      const char *parm = argv[i];
      if (strcmp (parm, "--library") == 0)
        {
          /*
           * The default macro library, found relative to the executable the way
           * ASM101S.py finds it relative to its own source file:  one directory
           * up from the assembler, then into the flight-software tree.  That
           * holds when this executable sits where ASM101S.py sits, one level
           * below the repository root.
           *
           * `argv[0]` stands in for Python's `__file__`, and unlike it is not
           * resolved through symlinks and may be a bare name when the program
           * was found on the PATH -- in which case the search starts from the
           * working directory.  `--library=DIR` names the directory outright
           * and is the form to use when that is not good enough.
           */
          char *scriptDir = arena_strdup (ARENA_MAIN, argv[0]);
          char *slash = strrchr (scriptDir, PATH_SEPARATOR);
#if defined(_WIN32)
          char *other = strrchr (scriptDir, '/');
          if (other != NULL && (slash == NULL || other > slash))
            slash = other;
#endif
          if (slash != NULL)
            *slash = '\0';
          else
            scriptDir = arena_strdup (ARENA_MAIN, ".");
          readMacroLibrary (py_format ("%s%c..%cyaShuttle%cSource Code%c"
                                       "PASS.REL32V0%cRUNMAC",
                                       scriptDir, PATH_SEPARATOR,
                                       PATH_SEPARATOR, PATH_SEPARATOR,
                                       PATH_SEPARATOR, PATH_SEPARATOR));
          endLibraries = (asmint) val_len (source);
        }
      else if (py_startswith (parm, "--library="))
        {
          readMacroLibrary (parm + 10);
          endLibraries = (asmint) val_len (source);
        }
      else if (py_startswith (parm, "--object="))
        {
          if (!py_endswith (parm, ".obj"))
            {
              fprintf (stderr, "Object-code filenames must end in .obj\n");
              return 1;
            }
          objectFileName = parm + 9;
        }
      else if (py_startswith (parm, "--sysparm="))
        val_dset_str (svGlobals, "&SYSPARM", parm + 10);
      else if (py_startswith (parm, "--tolerable="))
        py_parse_int (parm + 12, &tolerableSeverity);
      else if (py_startswith (parm, "--fill="))
        {
          int ok = 0;
          asmint val = py_atoi_base (parm + 7, 16, &ok);
          fillPattern[0] = (unsigned char) ((val >> 8) & 0xFF);
          fillPattern[1] = (unsigned char) (val & 0xFF);
        }
      else if (py_startswith (parm, "--compare="))
        {
          comparisonFile = parm + 10;
          comparisonSects = readListing (comparisonFile);
          if (comparisonSects == NULL)
            {
              fprintf (stderr, "Could not load comparison file %s\n",
                       comparisonFile);
              return 1;
            }
          /* Snapshot which addresses the listing actually assigns, BEFORE the
             comparison starts blanking them as it consumes them.  It is what
             lets an uncovered byte be checked against the gap it sits in. */
          comparisonAssigned = val_dict ();
          {
            size_t s;
            for (s = 0; s < comparisonSects->n; s++)
              {
                ListSect *ls = &comparisonSects->sects[s];
                Val *flags = val_bytes (ls->len);
                size_t k;
                for (k = 0; k < ls->len; k++)
                  val_bytes_set (flags, k, ls->memory[k] != -1 ? 1 : 0);
                val_dset (comparisonAssigned, ls->name, flags);
              }
          }
        }
      else if (!py_startswith (parm, "--"))
        {
          if (!py_endswith (parm, ".asm"))
            {
              fprintf (stderr, "Source-code filenames must end with .asm\n");
              return 1;
            }
          val_append (sourceFileNames,
                      val_str (py_substr (parm, 0, strlen (parm) - 4)));
          if (objectFileName == NULL)
            {
              /* The default is the stem of the source file. */
              const char *base = parm;
              const char *p;
              for (p = parm; *p != '\0'; p++)
                if (*p == '/' || *p == '\\')
                  base = p + 1;
              objectFileName
                  = py_concat (py_substr (base, 0, strlen (base) - 4), ".obj");
            }
          readSourceFile (parm, svGlobalLocals, sequenceGlobalLocals, 0, 1, 0);
          sourceFileCount += 1;
        }
      else if (strcmp (parm, "--force-d") == 0
               || strcmp (parm, "--no-force-d") == 0
               || strcmp (parm, "--no-rtl-fixes") == 0
               || strcmp (parm, "--trace") == 0)
        {
          /* Already accounted for above. */
        }
      else if (strcmp (parm, "--help") == 0)
        {
          printProvenance (0);
          printf ("\n");
          printf ("Usage:\n");
          printf ("     ASM101Sa [OPTIONS] SOURCE1.asm ...\n");
          printf ("\n");
          printf ("The defined OPTIONS are:\n");
          printf ("\n");
          printf ("--help              Display this message.\n");
          printf ("--version           Display which version of ASM101S.py\n");
          printf ("                    this program is a port of, and whether\n");
          printf ("                    it is at parity with it.\n");
          printf ("--object=F.obj      Specify the name of the output object-code\n");
          printf ("                    file.  The default is SOURCEn.obj, where\n");
          printf ("                    SOURCEn.asm is the *last* source-code file\n");
          printf ("                    specified on the command line.\n");
          printf ("--library           Load the default macro library.  Without\n");
          printf ("                    --library or --library=L (see below), no\n");
          printf ("                    macro library at all is loaded.\n");
          printf ("--library=L         Load a macro library by name, L.  This\n");
          printf ("                    option can appear multiple times.\n");
          printf ("--sysparm=T         (Default PASS.) Sets the global SET symbol\n");
          printf ("                    &SYSPARM. For Space Shuttle flight software,\n");
          printf ("                    the allowed choices are BFS and PASS.\n");
          printf ("                    Note that while accepted, the BFS option\n");
          printf ("                    is presently ignored and produces identical\n");
          printf ("                    results to PASS.\n");
          printf ("--tolerable=N       (Default 7.) Sets the maximum tolerable\n");
          printf ("                    error severity.  All errors detected by\n");
          printf ("                    ASM101S itself are severity 255. Errors\n");
          printf ("                    reported by MNOTE instructions have a\n");
          printf ("                    severity determined by the MNOTE instruction\n");
          printf ("                    (i.e., by the source code itself), but\n");
          printf ("                    level 1 seems to be used for info messages.\n");
          printf ("--compare=F         (Default none.) Specifies the name of an\n");
          printf ("                    assembly-listing file whose generated code\n");
          printf ("                    is compared to the current assembly.\n");
          printf ("--fill=XXXX         Set the fill pattern for uninitialized\n");
          printf ("                    locations, in hexadecimal. 0000 by default,\n");
          printf ("                    with the common alternatives being C6C6 and\n");
          printf ("                    C9FB.\n");
          printf ("--force-d           (Default) An option that forces a\n");
          printf ("                    particular use of displacements in\n");
          printf ("                    RS-type instructions.\n");
          printf ("--no-force-d        Opposite of --force-d.\n");
          printf ("--trace             Enable tracing mode for debugging assembler\n");
          printf ("                    operation.\n");
          printf ("--no-rtl-fixes      Reproduce the RTL library's original, historical\n");
          printf ("                    behavior -- including its known bugs -- by making\n");
          printf ("                    &ASM101S false instead of true. Some RTL source\n");
          printf ("                    files use &ASM101S to gate a reversible, otherwise-\n");
          printf ("                    invisible bug fix; those fixes change object-code\n");
          printf ("                    size, which cascades into the linker's memory-image\n");
          printf ("                    layout. Use this switch when reproducing an exact,\n");
          printf ("                    historical memory image matters more than having\n");
          printf ("                    the fixes.\n");
          printf ("\n");
          return 1;
        }
      else
        {
          fprintf (stderr, "Unrecognized parameter '%s'\n", parm);
          return 1;
        }
    }
  if (sourceFileCount == 0)
    {
      fprintf (stderr, "No source-code files were specified\n");
      return 1;
    }

  /*---------------------------------------------------------------------------
   * Code generation
   */
  generateObjectCode (source, macros);

  /*---------------------------------------------------------------------------
   * Write the object file.
   */
  if (objectFileName != NULL)
    {
      writeObjectModule (objectFileName, metadata, symtab, sects, entries,
                         extrns);
      fprintf (stderr, "Output obj: %s\n", objectFileName);
    }

  /*---------------------------------------------------------------------------
   * When severe-enough errors have been detected, print an alternate form of
   * the listing.  This form is more helpful for tracking how macros are
   * expanded and how the values of symbolic variables evolve.
   */
  getErrorCount (&errorCount, &maxSeverity);
  if (val_len (source) > 0
      && val_dget_bool (val_get (source, val_len (source) - 1),
                        "inMacroDefinition", 0))
    {
      errorCount += 1;
      maxSeverity = 255;
    }
  if (maxSeverity > tolerableSeverity)
    {
      int lastError = 0;
      asmint intolerables = 0;
      size_t k;
      printf ("Assembly aborted due to intolerable errors. %lld total error(s) "
              "detected.\n",
              (long long) errorCount);
      printf ("Fix any intolerable errors marked below and retry.  Search for "
              "'Severity'.\n");
      printf ("\n");
      for (k = 0; k < val_len (source); k++)
        {
          Val *line = val_get (source, k);
          const char *depthStar
              = val_dget_int (line, "depth", 0) > 0 ? "+" : " ";
          Val *errors = val_dget (line, "errors");
          if (val_len (errors) == 0)
            {
              printf ("%5u: %s   %s\n", (unsigned) k, depthStar,
                      val_dget_str (line, "text", ""));
              lastError = 0;
            }
          else
            {
              int anyIntolerable = 0;
              size_t m;
              if (!lastError)
                printf ("=====================================================\n");
              for (m = 0; m < val_len (errors); m++)
                {
                  const char *msg = val_cstr (val_get (errors, m));
                  /* The severity is the last blank-delimited field before the
                     first `)`. */
                  char *head = arena_strdup (ARENA_MAIN, msg);
                  char *paren = strchr (head, ')');
                  char **fields;
                  size_t nf;
                  if (paren != NULL)
                    *paren = '\0';
                  nf = py_split_ws (head, &fields);
                  if (nf > 0)
                    {
                      asmint sev = 0;
                      if (py_parse_int (fields[nf - 1], &sev)
                          && sev > tolerableSeverity)
                        anyIntolerable = 1;
                    }
                  printf ("%s\n", msg);
                }
              if (anyIntolerable)
                intolerables += 1;
              printf ("%5u: %s   %s\n", (unsigned) k, depthStar,
                      val_dget_str (line, "text", ""));
              printf ("=====================================================\n");
              lastError = 1;
            }
        }
      if (val_len (source) > 0
          && val_dget_bool (val_get (source, val_len (source) - 1),
                            "inMacroDefinition", 0))
        printf ("No closing MEND for MACRO\n");
      printf ("Assembly aborted. Fix the errors or use --tolerable=N to adjust "
              "tolerance.\n");
      printf ("Search for 'Severity' to find the marked errors, tolerated or "
              "otherwise.\n");
      {
        StrBuf names;
        size_t m;
        sb_init (&names);
        for (m = 0; m < val_len (sourceFileNames); m++)
          {
            if (m)
              sb_add (&names, ",");
            sb_add (&names, val_cstr (val_get (sourceFileNames, m)));
          }
        printf ("%s: %lld intolerable line(s) detected, %lld < severity < %lld.\n",
                names.s ? names.s : "", (long long) intolerables,
                (long long) tolerableSeverity, (long long) (1 + maxSeverity));
        sb_free (&names);
      }
      return 1;
    }

  /*===========================================================================
   * The regular form of the assembly listing.
   */
  {
    /* "Instructions" in the macro language are by default not printed in the
       assembly report. */
    static const char *const macroLanguageInstructions[]
        = { "GBLA", "GBLB", "GBLC", "LCLA", "LCLB", "LCLC", "SETA", "SETB",
            "SETC", "AIF",  "AGO",  "ANOP", "SPACE", "MEXIT", "MNOTE", NULL };
    int inCopy = 0;
    const char *memberName = "";
    /* rvl/concat/nest are not recoverable from anything available, so 0/0/0. */
    const int rvl = 0, concat = 0, nest = 0;
    asmint printedLineNumber = 0;
    asmint pageNumber = 0;
    const asmint linesPerPage = 80;
    asmint linesThisPage = 1000;
    asmint mismatchCount = 0;
    asmint beyondCount = 0;
    asmint uncoveredCount = 0;
    char *pageSeparator;
    char *title;
    char *subtitle;
    asmint idCounter = 0;
    Val *ids = val_dict ();
    size_t k;
    asmint literalPoolNumber = 0;
    int continuationFlag = 0;
    Val *previousContext = NULL;
    Val *finalWriter;

    {
      StrBuf sep;
      sb_init (&sep);
      sb_addc (&sep, '\f');
      for (k = 0; k < 120; k++)
        sb_addc (&sep, '-');
      pageSeparator = sb_take (&sep);
    }

    title = py_center ("EXTERNAL SYMBOL DICTIONARY", 100);
    subtitle = py_format ("%-95s%16s %s",
                          "SYMBOL   TYPE  ID  ADDR  LENGTH  LD ID",
                          py_format ("%s %s", program, version), currentDate);
    for (k = 0; k < val_dlen (symtab); k++)
      {
        const char *symbol = val_dkey (symtab, k);
        Val *entry = val_dval (symtab, k);
        const char *ldId = "    ";
        const char *moduleType;
        char *pid;
        char *address = "      ";
        char *length = "      ";
        const char *type;
        if (symbol[0] == '_')
          continue;
        if (!val_is_dict (entry))
          continue;
        type = val_dget_str (entry, "type", "");
        if (strcmp (type, "CSECT") == 0 && !val_dget_bool (entry, "dsect", 0))
          {
            moduleType = "SD";
            idCounter += 1;
            val_dset_int (ids, symbol, idCounter);
            pid = py_format ("%04d", (int) idCounter);
          }
        else if (val_dhas (entry, "entry"))
          {
            const char *section = val_dget_str (entry, "section", "");
            moduleType = "LD";
            pid = "    ";
            ldId = hexPad (val_dget_int (ids, section, 0), 4);
          }
        else if (strcmp (type, "EXTERNAL") == 0)
          {
            moduleType = "ER";
            idCounter += 1;
            val_dset_int (ids, symbol, idCounter);
            pid = py_format ("%04d", (int) idCounter);
          }
        else
          continue;
        if (val_dhas (entry, "address"))
          {
            asmint a = val_dget_int (entry, "address", 0);
            if (val_dhas (entry, "preliminaryOffset"))
              a += val_dget_int (entry, "preliminaryOffset", 0);
            address = hexPad (a, 6);
          }
        if (val_dhas (sects, symbol))
          length = hexPad ((val_dget_int (val_dget (sects, symbol), "used", 0) + 1)
                               / 2,
                           6);
        if (linesThisPage >= linesPerPage)
          {
            pageNumber += 1;
            if (pageNumber > 1)
              printf ("%s\n", pageSeparator);
            printf ("         %-100s  PAGE %4d\n", title, (int) pageNumber);
            printf ("%s\n", subtitle);
            linesThisPage = 0;
          }
        printf ("%s\n",
                py_rstrip (py_format ("%-10s%-3s%-5s%-7s%-7s%s", symbol,
                                      moduleType, pid, address, length, ldId)));
        linesThisPage += 1;
      }

    title = arena_strdup (ARENA_MAIN, "");
    subtitle = arena_strdup (ARENA_MAIN, "");

    /*
     * THE LAST WRITER OF AN ADDRESS IS THE ONE THAT COUNTS.  `--compare` walks
     * the cards in source order, compares each one's bytes against the listing's
     * memory and then marks that address consumed.  Where an `ORG` sends the
     * location counter BACK and a later card overwrites an earlier one, that is
     * exactly wrong twice over:  the FIRST card is compared against the value the
     * LAST one left in the listing, and the last card then finds the address
     * already consumed and is counted as unverified rather than checked.
     *
     * BILDNEW5 is where this surfaced.  Both builds finish with E92F at 03D28
     * while the comparison reported 3002 against E92F and called it two wrong
     * bytes.  Skipping a card that a later one overwrites compares what the build
     * actually emits, which is the whole point.
     */
    finalWriter = val_dict ();
    for (k = (size_t) endLibraries; k < val_len (source); k++)
      {
        Val *p = val_get (source, k);
        const char *s;
        asmint base;
        size_t m, n;
        if (!val_dhas (p, "assembled") || val_is_none (val_dget (p, "pos1")))
          continue;
        s = val_dget_str (p, "section", NULL);
        if (s == NULL || !val_dhas (sects, s))
          continue;
        base = ASM_ADD (val_dget_int (p, "pos1", 0),
                        ASM_MUL (val_dget_int (val_dget (sects, s), "offset", 0),
                                 2));
        n = val_len (val_dget (p, "assembled"));
        if (n > 8)
          n = 8;
        for (m = 0; m < n; m++)
          val_dset_int (finalWriter,
                        py_format ("%s\1%lld", s, (long long) (base + (asmint) m)),
                        (asmint) k);
      }

    for (k = (size_t) endLibraries; k < val_len (source); k++)
      {
        Val *props = val_get (source, k);
        size_t propNum = k;
        Val *context;
        int skip = 0;
        const char *operation = val_dget_str (props, "operation", "");
        const char *depthStar;
        char *prefix;
        int havePrefix;
        asmint offset = 0;
        int haveAddress = 0;
        asmint address = 0;
        const char *section = NULL;
        ListSect *comparisonMemory = NULL;

        /*
         * A continuation only continues the line before it IN THE SAME FILE OR
         * MACRO BODY.  `source` is one flat list spanning both, so at the
         * boundary the previous entry is the macro INVOCATION -- and if that was
         * written across two cards, its `continues` swallowed the first line of
         * the body from the listing.
         */
        context = val_seq (V_LIST);
        val_append (context, val_dget (props, "depth"));
        val_append (context, val_dget (props, "macro"));
        val_append (context, val_dget (props, "file"));
        if (previousContext == NULL || !val_eq (context, previousContext))
          continuationFlag = 0;
        previousContext = context;

        if (val_len (val_dget (props, "errors")) > 0)
          {
            size_t m;
            printf ("=====================================================\n");
            for (m = 0; m < val_len (val_dget (props, "errors")); m++)
              printf ("%s\n", val_cstr (val_get (val_dget (props, "errors"), m)));
            printf ("=====================================================\n");
          }
        if (val_dget_bool (props, "empty", 0))
          continue;
        if (continuationFlag)
          {
            continuationFlag = val_dget_bool (props, "continues", 0);
            linesThisPage += 1;
            continue;
          }
        continuationFlag = val_dget_bool (props, "continues", 0);
        if (strcmp (operation, "SPACE") == 0)
          {
            asmint space = 1; /* actually depends on the operand */
            printedLineNumber += space;
            val_dset_int (props, "printedLineNumber", printedLineNumber);
            linesThisPage += space;
          }
        else if (strcmp (operation, "TITLE") == 0)
          {
            /* A TITLE MAY HAVE NO OPERAND, in which case it merely ejects and
               the heading is left as it was.  The operand arrives as None then,
               and `.rstrip()` on it is an AttributeError that killed the
               assembly outright rather than diagnosing anything -- the listing
               simply stopped.  It is reachable from ordinary source. */
            Val *operandText = val_dget (props, "operand");
            if (val_is_str (operandText))
              {
                char *t = py_rstrip (val_cstr (operandText));
                size_t n = strlen (t);
                title = n >= 2 ? py_substr (t, 1, n - 2)
                               : arena_strdup (ARENA_MAIN, "");
              }
            else
              title = arena_strdup (ARENA_MAIN, "");
            subtitle = py_format ("%-95s%16s %s",
                                  "  LOC  OBJECT CODE   ADR1 ADR2      SOURCE "
                                  "STATEMENT",
                                  py_format ("%s %s", program, version),
                                  currentDate);
            printedLineNumber += 1;
            val_dset_int (props, "printedLineNumber", printedLineNumber);
            linesThisPage = 1000;
            skip = 1;
          }
        if (linesThisPage >= linesPerPage)
          {
            pageNumber += 1;
            if (pageNumber > 1)
              printf ("%s\n", pageSeparator);
            printf ("         %-100s  PAGE %4d\n", title, (int) pageNumber);
            printf ("%s\n", subtitle);
            linesThisPage = 0;
            if (skip)
              continue;
          }
        depthStar = val_dget_int (props, "depth", 0) > 0 ? "+" : " ";
        {
          int isMacroLanguage = 0;
          int m;
          for (m = 0; macroLanguageInstructions[m] != NULL; m++)
            if (strcmp (operation, macroLanguageInstructions[m]) == 0)
              isMacroLanguage = 1;
          if (isMacroLanguage)
            continue;
        }
        if (val_dget_bool (props, "fullComment", 0)
            && py_startswith (val_dget_str (props, "text", ""), "*/"))
          continue; /* a "modern" comment */
        if (val_dget_bool (props, "copy", 0))
          {
            if (!inCopy)
              {
                /* A COPIED LINE NEED NOT NAME A FILE.  `Path(None)` raised a
                   TypeError out of the LISTING, so a module that assembled
                   perfectly well died on the way to being printed. */
                Val *fileVal = val_dget (props, "file");
                if (val_is_str (fileVal))
                  {
                    const char *f = val_cstr (fileVal);
                    const char *base = f;
                    const char *p;
                    size_t n;
                    for (p = f; *p != '\0'; p++)
                      if (*p == '/' || *p == '\\')
                        base = p + 1;
                    n = strlen (base);
                    if (n > 4 && strcmp (base + n - 4, ".asm") == 0)
                      memberName = py_substr (base, 0, n - 4);
                    else
                      memberName = arena_strdup (ARENA_MAIN, base);
                  }
                else
                  memberName = "?";
                if (val_dget_bool (props, "printable", 0)
                    && val_dget_bool (props, "listOn", 0))
                  {
                    linesThisPage += 1;
                    printf ("         START OF COPY MEMBER %-8s RVL %02d "
                            "CONCATENATION NO. %03d  NEST %03d\n",
                            memberName, rvl, concat, nest);
                  }
                inCopy = 1;
              }
          }
        else
          {
            if (inCopy)
              {
                if (val_dget_bool (props, "printable", 0)
                    && val_dget_bool (props, "listOn", 0))
                  {
                    linesThisPage += 1;
                    printf ("           END OF COPY MEMBER %-8s RVL %02d "
                            "CONCATENATION NO. %03d  NEST %03d\n",
                            memberName, rvl, concat, nest);
                  }
                inCopy = 0;
              }
          }
        if (!(val_dget_bool (props, "printable", 0)
              && val_dget_bool (props, "listOn", 0)))
          continue;

        prefix = arena_strdup (ARENA_MAIN, "");
        havePrefix = 0;
        (void) havePrefix;
        {
          const char *sn = val_dget_str (props, "section", NULL);
          if (sn != NULL && val_dhas (sects, sn)
              && val_dhas (val_dget (sects, sn), "offset"))
            offset = val_dget_int (val_dget (sects, sn), "offset", 0);
          else
            offset = 0;
        }
        if (strcmp (operation, "EQU") == 0)
          {
            /* THE NAME MAY NOT BE IN THE SYMBOL TABLE.  A card inside a macro
               DEFINITION is echoed in the listing without ever being expanded,
               so its name field can still be a variable symbol -- MACSMITH has
               `&C EQU` in one of its macro bodies -- and no such name is ever
               entered. */
            Val *entry = val_dget (symtab, val_dget_str (props, "name", ""));
            if (entry != NULL && val_dhas (entry, "value"))
              prefix = hexPad (ASM_AND (val_dget_int (entry, "value", 0),
                                        0xFFFFFFF),
                               7);
          }
        else if (strcmp (operation, "USING") == 0)
          {
            /* A USING whose base could not be established has no value to
               print.  It is set only when the first operand evaluates, so every
               diagnosed USING reached this with the key absent and took the
               whole assembly down with a KeyError, AFTER the diagnostic that
               explained the real problem had already been printed. */
            if (val_dhas (props, "using"))
              prefix = hexPad (val_dget_int (props, "using", 0), 7);
          }
        else if (strcmp (operation, "LTORG") == 0)
          {
            /* Nothing to show. */
          }
        else if (!val_is_none (val_dget (props, "pos1")))
          {
            asmint paddress;
            address = val_dget_int (props, "pos1", 0);
            haveAddress = 1;
            section = val_dget_str (props, "section", NULL);
            if (comparisonSects != NULL && section != NULL)
              comparisonMemory = listing_find (comparisonSects, section);
            paddress = address / 2;
            if (section != NULL && val_dhas (sects, section)
                && val_dhas (val_dget (sects, section), "offset"))
              paddress += offset;
            prefix = hexPad (paddress, 5);
          }
        if (val_dhas (props, "assembled"))
          {
            /*
             * EIGHT BYTES, and the cap is not arbitrary:  a listing line shows
             * FOUR HALFWORDS and never more, so eight is all the evidence there
             * is.  It is a fixed field width rather than elision of repeats --
             * FAZ2's `DC X'A92F0A3C,A2DFA000,0000A35...'` generates sixteen
             * bytes of entirely different data and the listing prints
             * A92F0A3CA2DFA000 and stops.
             *
             * Comparing beyond it was tried and produced 1180 bytes of "past the
             * end of the listing" for one patch-space module:  noise, not
             * verification.
             */
            Val *assembled = val_dget (props, "assembled");
            size_t n = val_len (assembled);
            size_t m;
            if (n > 8)
              n = 8;
            for (m = 0; m < n; m++)
              {
                unsigned char b = val_bytes_get (assembled, m);
                if (comparisonMemory != NULL && haveAddress
                    && val_dget_int (finalWriter,
                                     py_format ("%s\1%lld", section,
                                                (long long) (address
                                                             + offset * 2)),
                                     (asmint) propNum)
                           != (asmint) propNum)
                  {
                    /* A LATER CARD OVERWRITES THIS BYTE, so it is not what the
                       build emits and the listing's value belongs to that later
                       card.  Neither compared nor consumed. */
                  }
                else if (comparisonMemory != NULL)
                  {
                    asmint oaddress = ASM_ADD (address, ASM_MUL (offset, 2));
                    if (oaddress >= (asmint) comparisonMemory->len)
                      {
                        /* Generated code running past the end of the listing
                           used to be an IndexError, which killed the run and
                           took the whole comparison with it -- and it is exactly
                           the shape of failure --compare exists to report, since
                           a build that emits MORE than the listing did has a
                           real discrepancy.  Count it and carry on. */
                        beyondCount += 1;
                        address += 1;
                        if (m == 0
                            || ((m & 1) == 0 && strcmp (operation, "DC") != 0))
                          prefix = py_concat (prefix, " ");
                        prefix = py_concat (prefix, hexPad (b, 2));
                        continue;
                      }
                    if (comparisonMemory->memory[oaddress] == -1)
                      {
                        /* THE LISTING SAYS NOTHING ABOUT THIS ADDRESS, so it
                           cannot contradict us.  It happens where the original
                           listing prints a statement with neither location nor
                           object code while the location counter still advances
                           over it.  Counting those as mismatches made 32 bytes
                           across two modules look wrong when the listing simply
                           had no opinion. */
                        uncoveredCount += 1;
                      }
                    else if (b != (unsigned char) comparisonMemory->memory[oaddress])
                      {
                        mismatchCount += 1;
                        printf ("Comparison mismatch: %02X vs %02X\n",
                                (unsigned) b,
                                (unsigned) comparisonMemory->memory[oaddress]);
                      }
                    comparisonMemory->memory[oaddress] = -1;
                    address += 1;
                  }
                if (m == 0 || ((m & 1) == 0 && strcmp (operation, "DC") != 0))
                  prefix = py_concat (prefix, " ");
                prefix = py_concat (prefix, hexPad (b, 2));
              }
          }
        if (val_dhas (props, "adr1"))
          prefix = py_format ("%-21s%s", prefix,
                              hexPad (ASM_AND (val_dget_int (props, "adr1", 0),
                                               0xFFFF),
                                      4));
        if (val_dhas (props, "adr2"))
          prefix = py_format ("%-26s%s", prefix,
                              hexPad (ASM_AND (val_dget_int (props, "adr2", 0),
                                               0xFFFF),
                                      4));
        /* For whatever reason, a macro-invocation line is printed only under
           some circumstances, and is omitted in others. */
        if (val_dhas (macros, operation)
            && !val_dget_bool (props, "inMacroDefinition", 0))
          {
            Val *macroWhere = val_dget (macros, operation);
            if (val_as_int (val_get (macroWhere, 2)) > endLibraries)
              continue;
          }
        if (val_dhas (macros, operation) && val_dget_int (props, "depth", 0) > 0)
          continue;
        {
          char *identification;
          if (val_dget_int (props, "depth", 0) == 0)
            identification
                = py_substr (val_dget_str (props, "identification", ""), 0, 8);
          else
            {
              const char *suffix = "";
              Val *macroVal = val_dget (props, "macro");
              if (val_is_str (macroVal))
                suffix = val_cstr (macroVal);
              identification
                  = py_format ("%02d-%s", (int) val_dget_int (props, "depth", 0),
                               py_substr (suffix, 0, 5));
            }
          if (val_dget_bool (props, "dotComment", 0))
            {
              /* Nothing is printed for a macro-language comment. */
            }
          else if (val_dget_bool (props, "fullComment", 0)
                   || val_dget_bool (props, "inMacroDefinition", 0))
            {
              printedLineNumber += 1;
              val_dset_int (props, "printedLineNumber", printedLineNumber);
              linesThisPage += 1;
              if (py_strip (identification)[0] == '\0'
                  || (val_dget_bool (props, "fullComment", 0)
                      && depthStar[0] != ' ' && !val_dhas (props, "mnote")))
                printf ("%-30s%5d%s%s\n", prefix, (int) printedLineNumber,
                        depthStar, py_rstrip (val_dget_str (props, "text", "")));
              else
                printf ("%-30s%5d%s%-71s %s\n", prefix, (int) printedLineNumber,
                        depthStar, val_dget_str (props, "text", ""),
                        identification);
            }
          else if (operation[0] == '\0')
            continue;
          else
            {
              const char *name = val_dget_str (props, "name", "");
              Val *operandVal = val_dget (props, "operand");
              char *mid;
              if (name[0] == '.')
                name = "";
              printedLineNumber += 1;
              val_dset_int (props, "printedLineNumber", printedLineNumber);
              linesThisPage += 1;
              mid = py_format ("%-30s%5d%s%-8s %-7s %s", prefix,
                               (int) printedLineNumber, depthStar, name,
                               operation,
                               py_rstrip (val_is_str (operandVal)
                                              ? val_cstr (operandVal)
                                              : val_str_of (operandVal)));
              printf ("%-108s%s\n", mid, identification);
            }
        }
        if (strcmp (operation, "LTORG") == 0)
          {
            Val *pool;
            Val *reordered;
            size_t m;
            if ((size_t) literalPoolNumber >= val_len (literalPools))
              continue;
            pool = val_get (literalPools, (size_t) literalPoolNumber);
            reordered = val_dict ();
            for (m = emptyPoolLength; m < val_len (pool); m++)
              {
                asmint off = ASM_ADD (val_as_int (val_get (pool, 1)),
                                      val_as_int (val_get (val_get (pool, 3), m)));
                val_dset_int (reordered,
                              py_format ("%020lld", (long long) (off / 2)),
                              (asmint) m);
              }
            {
              /* `for i in sorted(reordered)` -- numerically, which the
                 zero-padded key makes a plain string sort. */
              size_t count = val_dlen (reordered);
              SortEntry *keys = (SortEntry *) arena_alloc (
                  ARENA_MAIN, (count + 1) * sizeof (SortEntry));
              size_t q;
              for (q = 0; q < count; q++)
                {
                  keys[q].key = val_dkey (reordered, q);
                  keys[q].sortKey = (char *) keys[q].key;
                  keys[q].index = q;
                }
              qsort (keys, count, sizeof (SortEntry), compareSortEntries);
              for (q = 0; q < count; q++)
                {
                  asmint idx = val_dget_int (reordered, keys[q].key, 0);
                  Val *attributes = val_get (pool, (size_t) idx);
                  Val *bytes = val_dget (attributes, "assembled");
                  asmint L = val_dget_int (attributes, "L", 0);
                  asmint j;
                  asmint hw = 0;
                  StrBuf line;
                  py_parse_int (keys[q].key, &hw);
                  sb_init (&line);
                  sb_addf (&line, "%s ", hexPad (hw, 5));
                  for (j = 0; j < L; j++)
                    sb_add (&line, hexPad (val_bytes_get (bytes, (size_t) j), 2));
                  printf ("%-50s %s\n",
                          py_substr (sb_take (&line), 0, 30),
                          val_dget_str (attributes, "operand", ""));
                }
            }
            literalPoolNumber += 1;
          }
      }

    /*-------------------------------------------------------------------------
     * The cross reference.
     */
    linesThisPage = 1000;
    {
      size_t count = val_dlen (symtab);
      SortEntry *keys = (SortEntry *) arena_alloc (
          ARENA_MAIN, (count + 1) * sizeof (SortEntry));
      size_t q;
      for (q = 0; q < count; q++)
        {
          keys[q].key = val_dkey (symtab, q);
          keys[q].sortKey = sortOrder (keys[q].key);
          keys[q].index = q;
        }
      qsort (keys, count, sizeof (SortEntry), compareSortEntries);
      for (q = 0; q < count; q++)
        {
          const char *symbol = keys[q].key;
          Val *symProps = val_dget (symtab, symbol);
          const char *type;
          asmint length;
          asmint value;
          char *defn = "     ";
          char *line;
          asmint numRefs = 0;
          if (symbol[0] == '_' || symbol[0] == '.')
            continue;
          if (!val_is_dict (symProps))
            continue;
          if (linesThisPage >= linesPerPage)
            {
              pageNumber += 1;
              printf ("%s\n", pageSeparator);
              printf ("%45s%-66sPAGE %4d\n", "", "CROSS REFERENCE",
                      (int) pageNumber);
              printf ("%-95s%16s %s\n",
                      "SYMBOL    LEN    VALUE   DEFN   REFERENCES",
                      py_format ("%s %s", program, version), currentDate);
              linesThisPage = 0;
            }
          type = val_dget_str (symProps, "type", "");
          if (strcmp (type, "EQU") == 0 || strcmp (type, "CSECT") == 0
              || strcmp (type, "EXTERNAL") == 0)
            length = 1; /* ###FIXME### */
          else if (val_dhas (symProps, "properties")
                   && val_dhas (val_dget (symProps, "properties"), "scratch"))
            {
              asmint l = val_dget_int (
                  val_dget (val_dget (symProps, "properties"), "scratch"),
                  "length", 0);
              length = l < 2 ? 1 : l / 2;
            }
          else
            length = 2;
          value = val_dget_int (symProps, "value", 0);
          if (val_dhas (symProps, "properties")
              && val_dhas (val_dget (symProps, "properties"),
                           "printedLineNumber"))
            defn = py_format ("%5d",
                              (int) val_dget_int (
                                  val_dget (symProps, "properties"),
                                  "printedLineNumber", 0));
          {
            const char *sn = val_dget_str (symProps, "section", NULL);
            if (sn != NULL && val_dhas (sects, sn)
                && val_dhas (val_dget (sects, sn), "offset"))
              value = ASM_ADD (value,
                               val_dget_int (val_dget (sects, sn), "offset", 0));
          }
          if (strcmp (type, "INSTRUCTION") == 0 || strcmp (type, "DATA") == 0)
            line = py_format ("%-8s %5d   %s %s", symbol, (int) length,
                              hexPad (ASM_AND (value, 0xFFFFFF), 6), defn);
          else
            line = py_format ("%-8s %5d %s %s", symbol, (int) length,
                              hexPad (ASM_AND (value, 0xFFFFFFFF), 8), defn);
          if (val_dhas (symProps, "references")
              && val_len (val_dget (symProps, "references")) > 0)
            {
              Val *refs = val_dget (symProps, "references");
              size_t nrefs = val_len (refs);
              SortEntry *rkeys = (SortEntry *) arena_alloc (
                  ARENA_MAIN, (nrefs + 1) * sizeof (SortEntry));
              size_t r;
              line = py_concat (line, " ");
              for (r = 0; r < nrefs; r++)
                {
                  rkeys[r].key = py_format ("%020lld",
                                            (long long) val_as_int (
                                                val_get (refs, r)));
                  rkeys[r].sortKey = (char *) rkeys[r].key;
                  rkeys[r].index = r;
                }
              qsort (rkeys, nrefs, sizeof (SortEntry), compareSortEntries);
              for (r = 0; r < nrefs; r++)
                {
                  asmint n = 0;
                  Val *src;
                  py_parse_int (rkeys[r].key, &n);
                  if (n < 0 || (size_t) n >= val_len (source))
                    continue;
                  src = val_get (source, (size_t) n);
                  if (!val_dhas (src, "printedLineNumber"))
                    continue;
                  if (numRefs == 15)
                    {
                      printf ("%s\n", line);
                      linesThisPage += 1;
                      line = py_repeat (" ", 30);
                      numRefs = 0;
                    }
                  line = py_concat (
                      line,
                      py_format (" %5d",
                                 (int) val_dget_int (src, "printedLineNumber",
                                                     0)));
                  numRefs += 1;
                }
            }
          printf ("%s\n", line);
          linesThisPage += 1;
        }
    }

    /*-------------------------------------------------------------------------
     * The comparison summary.
     */
    if (comparisonSects != NULL)
      {
        asmint mismatchCount1 = 0;
        size_t s;
        const char *base = comparisonFile;
        const char *p;
        printf ("\f\n");
        for (p = comparisonFile; *p != '\0'; p++)
          if (*p == '/' || *p == '\\')
            base = p + 1;
        printf ("Generated code was compared to file %s\n", base);
        for (s = 0; s < comparisonSects->n; s++)
          {
            ListSect *ls = &comparisonSects->sects[s];
            int headerShown = 0;
            Val *sd = val_dget (sects, ls->name);
            Val *amemory = sd == NULL ? NULL : val_dget (sd, "memory");
            size_t addr;
            for (addr = 0; addr < ls->len; addr++)
              {
                char c;
                if (ls->memory[addr] == -1)
                  continue;
                c = (addr & 1) == 0 ? 'H' : 'L';
                if (amemory != NULL && addr < val_len (amemory)
                    && ls->memory[addr] == (int16_t) val_bytes_get (amemory, addr))
                  continue;
                if (!headerShown)
                  {
                    printf ("Missing object code from section \"%s\":\n",
                            ls->name);
                    headerShown = 1;
                  }
                printf ("\t%05X(%c): %02X\n", (unsigned) (addr / 2), c,
                        (unsigned) ls->memory[addr]);
                mismatchCount1 += 1;
              }
          }
        if (uncoveredCount > 0)
          {
            /*
             * An uncovered byte is safe to disregard when it lies in an INTERIOR
             * GAP -- a run the listing leaves blank with assigned bytes on BOTH
             * sides.  The gap then pins how many bytes belong there even though
             * it says nothing about their values, and our filling it exactly is
             * why everything after it still lines up.  An uncovered byte NOT in
             * such a gap is a different matter and is called out separately,
             * because nothing bounds it.
             */
            asmint bounded = 0;
            asmint gaps = 0;
            size_t si;
            for (si = 0; si < val_dlen (comparisonAssigned); si++)
              {
                Val *assigned = val_dval (comparisonAssigned, si);
                size_t n = val_len (assigned);
                size_t a = 0;
                while (a < n)
                  {
                    if (!val_bytes_get (assigned, a))
                      {
                        size_t b = a;
                        while (b < n && !val_bytes_get (assigned, b))
                          b++;
                        if (a > 0 && val_bytes_get (assigned, a - 1) && b < n
                            && val_bytes_get (assigned, b))
                          {
                            bounded += (asmint) (b - a);
                            gaps += 1;
                          }
                        a = b;
                      }
                    else
                      a += 1;
                  }
              }
            printf ("%lld byte(s) lie at addresses the comparison listing shows "
                    "no object code for, of which %lld fall in %lld interior "
                    "gap(s) the listing brackets on both sides -- their COUNT is "
                    "pinned by the gap, their VALUES are not shown and stay "
                    "unverified\n",
                    (long long) uncoveredCount,
                    (long long) (uncoveredCount < bounded ? uncoveredCount
                                                          : bounded),
                    (long long) gaps);
            if (uncoveredCount > bounded)
              printf ("%lld of them are NOT bounded by a gap and nothing "
                      "constrains them at all\n",
                      (long long) (uncoveredCount - bounded));
          }
        if (beyondCount > 0)
          printf ("%lld byte(s) of generated code lie past the end of the "
                  "comparison listing and could not be compared\n",
                  (long long) beyondCount);
        {
          StrBuf names;
          size_t m;
          sb_init (&names);
          for (m = 0; m < val_len (sourceFileNames); m++)
            {
              if (m)
                sb_add (&names, ",");
              sb_add (&names, val_cstr (val_get (sourceFileNames, m)));
            }
          if (beyondCount == 0)
            printf ("%s: %lld bytes mismatched and %lld bytes missing in "
                    "generated code\n",
                    names.s ? names.s : "", (long long) mismatchCount,
                    (long long) mismatchCount1);
          else
            printf ("%s: %lld bytes mismatched and %lld bytes missing in "
                    "generated code, and %lld bytes past the end of the "
                    "listing\n",
                    names.s ? names.s : "", (long long) mismatchCount,
                    (long long) mismatchCount1, (long long) beyondCount);
          sb_free (&names);
        }
      }
  }

  return 0;
}
