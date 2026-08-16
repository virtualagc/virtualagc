/*
 * License:    This program is declared by its author, Ronald Burkey, to be the
 *             U.S. Public Domain, and may be freely used, modified, or
 *             distributed for any purpose whatever.
 * Filename:   pattern.c
 * Purpose:    The grammar's regular expressions, written out.
 * Contact:    info@sandroid.org
 */

#include "pattern.h"

/* The "letters" of AP-101S assembly language:  A-Z and the three national
   characters, which is what `[@#$A-Z]` spells throughout the grammar. */
static int
isLetter (char c)
{
  return (c >= 'A' && c <= 'Z') || c == '@' || c == '#' || c == '$';
}

static int
isLetterOrDigit (char c)
{
  return isLetter (c) || (c >= '0' && c <= '9');
}

static int
isDigit (char c)
{
  return c >= '0' && c <= '9';
}

/* One literal character. */
static ptrdiff_t
one (const char *t, size_t len, size_t pos, char c)
{
  if (pos < len && t[pos] == c)
    return 1;
  return -1;
}

/* ' ' */
ptrdiff_t
pat0 (const char *t, size_t len, size_t pos)
{
  return one (t, len, pos, ' ');
}

/* ' *' */
ptrdiff_t
pat1 (const char *t, size_t len, size_t pos)
{
  size_t n = 0;
  while (pos + n < len && t[pos + n] == ' ')
    n++;
  return (ptrdiff_t) n;
}

/* [^']* */
ptrdiff_t
pat2 (const char *t, size_t len, size_t pos)
{
  size_t n = 0;
  while (pos + n < len && t[pos + n] != '\'')
    n++;
  return (ptrdiff_t) n;
}

/* [^ ]+ */
ptrdiff_t
pat3 (const char *t, size_t len, size_t pos)
{
  size_t n = 0;
  while (pos + n < len && t[pos + n] != ' ')
    n++;
  return n == 0 ? -1 : (ptrdiff_t) n;
}

/*
 * (?<![@#$A-Z0-9&])[@#$A-Z][@#$A-Z0-9]*
 *
 * THE LOOKBEHIND IS THE POINT OF THIS RULE.  It is what keeps the tail of a
 * symbolic variable from being read as an identifier in its own right:  in
 * `&ABC`, the parser reaches `ABC` with `&` behind it and this refuses to
 * match, so the text can only be a `variable`.  It also refuses the tail of a
 * longer name, which is what makes the grammar's alternation between
 * identifiers and variables unambiguous.
 */
ptrdiff_t
pat4 (const char *t, size_t len, size_t pos)
{
  size_t n;
  if (pos > 0)
    {
      char prev = t[pos - 1];
      if (isLetterOrDigit (prev) || prev == '&')
        return -1;
    }
  if (pos >= len || !isLetter (t[pos]))
    return -1;
  n = 1;
  while (pos + n < len && isLetterOrDigit (t[pos + n]))
    n++;
  return (ptrdiff_t) n;
}

/* [.][@#$A-Z][@#$A-Z0-9]*   -- a sequence symbol */
ptrdiff_t
pat5 (const char *t, size_t len, size_t pos)
{
  size_t n;
  if (pos + 1 >= len || t[pos] != '.' || !isLetter (t[pos + 1]))
    return -1;
  n = 2;
  while (pos + n < len && isLetterOrDigit (t[pos + n]))
    n++;
  return (ptrdiff_t) n;
}

/* [-+]?[0-9]+ */
ptrdiff_t
pat6 (const char *t, size_t len, size_t pos)
{
  size_t n = 0;
  if (pos < len && (t[pos] == '-' || t[pos] == '+'))
    n = 1;
  if (pos + n >= len || !isDigit (t[pos + n]))
    return -1;
  while (pos + n < len && isDigit (t[pos + n]))
    n++;
  return (ptrdiff_t) n;
}

/* [0-9A-F]+ */
ptrdiff_t
pat7 (const char *t, size_t len, size_t pos)
{
  size_t n = 0;
  while (pos + n < len
         && (isDigit (t[pos + n]) || (t[pos + n] >= 'A' && t[pos + n] <= 'F')))
    n++;
  return n == 0 ? -1 : (ptrdiff_t) n;
}

/* [0-1]+ */
ptrdiff_t
pat8 (const char *t, size_t len, size_t pos)
{
  size_t n = 0;
  while (pos + n < len && (t[pos + n] == '0' || t[pos + n] == '1'))
    n++;
  return n == 0 ? -1 : (ptrdiff_t) n;
}

/* C */
ptrdiff_t
pat9 (const char *t, size_t len, size_t pos)
{
  return one (t, len, pos, 'C');
}

/* [0-9]+ */
ptrdiff_t
pat10 (const char *t, size_t len, size_t pos)
{
  size_t n = 0;
  while (pos + n < len && isDigit (t[pos + n]))
    n++;
  return n == 0 ? -1 : (ptrdiff_t) n;
}

/* X */
ptrdiff_t
pat11 (const char *t, size_t len, size_t pos)
{
  return one (t, len, pos, 'X');
}

/* B */
ptrdiff_t
pat12 (const char *t, size_t len, size_t pos)
{
  return one (t, len, pos, 'B');
}

/* F */
ptrdiff_t
pat13 (const char *t, size_t len, size_t pos)
{
  return one (t, len, pos, 'F');
}

/* -?[0-9]+ */
ptrdiff_t
pat14 (const char *t, size_t len, size_t pos)
{
  size_t n = 0;
  if (pos < len && t[pos] == '-')
    n = 1;
  if (pos + n >= len || !isDigit (t[pos + n]))
    return -1;
  while (pos + n < len && isDigit (t[pos + n]))
    n++;
  return (ptrdiff_t) n;
}

/* H */
ptrdiff_t
pat15 (const char *t, size_t len, size_t pos)
{
  return one (t, len, pos, 'H');
}

/* E */
ptrdiff_t
pat16 (const char *t, size_t len, size_t pos)
{
  return one (t, len, pos, 'E');
}

/* D */
ptrdiff_t
pat17 (const char *t, size_t len, size_t pos)
{
  return one (t, len, pos, 'D');
}

/* Y */
ptrdiff_t
pat18 (const char *t, size_t len, size_t pos)
{
  return one (t, len, pos, 'Y');
}

/* Z */
ptrdiff_t
pat19 (const char *t, size_t len, size_t pos)
{
  return one (t, len, pos, 'Z');
}

/* [FHED] */
ptrdiff_t
pat20 (const char *t, size_t len, size_t pos)
{
  if (pos < len
      && (t[pos] == 'F' || t[pos] == 'H' || t[pos] == 'E' || t[pos] == 'D'))
    return 1;
  return -1;
}

/* [AY] */
ptrdiff_t
pat21 (const char *t, size_t len, size_t pos)
{
  if (pos < len && (t[pos] == 'A' || t[pos] == 'Y'))
    return 1;
  return -1;
}

/* [A-F0-9,]+  -- commas are cosmetic separators inside a hex constant. */
ptrdiff_t
pat22 (const char *t, size_t len, size_t pos)
{
  size_t n = 0;
  while (pos + n < len
         && (isDigit (t[pos + n]) || (t[pos + n] >= 'A' && t[pos + n] <= 'F')
             || t[pos + n] == ','))
    n++;
  return n == 0 ? -1 : (ptrdiff_t) n;
}

/* [01]+ */
ptrdiff_t
pat23 (const char *t, size_t len, size_t pos)
{
  return pat8 (t, len, pos);
}

/* [-+] */
ptrdiff_t
pat24 (const char *t, size_t len, size_t pos)
{
  if (pos < len && (t[pos] == '-' || t[pos] == '+'))
    return 1;
  return -1;
}

/* [0-9]* */
ptrdiff_t
pat25 (const char *t, size_t len, size_t pos)
{
  size_t n = 0;
  while (pos + n < len && isDigit (t[pos + n]))
    n++;
  return (ptrdiff_t) n;
}

/* [NKLSI]'   -- the attribute operators */
ptrdiff_t
pat26 (const char *t, size_t len, size_t pos)
{
  if (pos + 1 < len && t[pos + 1] == '\''
      && (t[pos] == 'N' || t[pos] == 'K' || t[pos] == 'L' || t[pos] == 'S'
          || t[pos] == 'I'))
    return 2;
  return -1;
}

/* [^, ]* */
ptrdiff_t
pat27 (const char *t, size_t len, size_t pos)
{
  size_t n = 0;
  while (pos + n < len && t[pos + n] != ',' && t[pos + n] != ' ')
    n++;
  return (ptrdiff_t) n;
}

/* &[@#$A-Z][@#$A-Z0-9]*  -- a symbolic variable */
ptrdiff_t
pat28 (const char *t, size_t len, size_t pos)
{
  size_t n;
  if (pos + 1 >= len || t[pos] != '&' || !isLetter (t[pos + 1]))
    return -1;
  n = 2;
  while (pos + n < len && isLetterOrDigit (t[pos + n]))
    n++;
  return (ptrdiff_t) n;
}

/* [^ ,()]* */
ptrdiff_t
pat29 (const char *t, size_t len, size_t pos)
{
  size_t n = 0;
  while (pos + n < len && t[pos + n] != ' ' && t[pos + n] != ','
         && t[pos + n] != '(' && t[pos + n] != ')')
    n++;
  return (ptrdiff_t) n;
}

/* [^()]* */
ptrdiff_t
pat30 (const char *t, size_t len, size_t pos)
{
  size_t n = 0;
  while (pos + n < len && t[pos + n] != '(' && t[pos + n] != ')')
    n++;
  return (ptrdiff_t) n;
}

/* [^, ()]* */
ptrdiff_t
pat31 (const char *t, size_t len, size_t pos)
{
  return pat29 (t, len, pos);
}

/* [#@$A-Z][#@$A-Z0-9]* */
ptrdiff_t
pat32 (const char *t, size_t len, size_t pos)
{
  size_t n;
  if (pos >= len || !isLetter (t[pos]))
    return -1;
  n = 1;
  while (pos + n < len && isLetterOrDigit (t[pos + n]))
    n++;
  return (ptrdiff_t) n;
}

/* .*  -- with re.MULTILINE, `.` still does not match a newline. */
ptrdiff_t
pat33 (const char *t, size_t len, size_t pos)
{
  size_t n = 0;
  while (pos + n < len && t[pos + n] != '\n')
    n++;
  return (ptrdiff_t) n;
}
