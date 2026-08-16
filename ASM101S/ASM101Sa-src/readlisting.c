/*
 * License:    This program is declared by its author, Ronald Burkey, to be the
 *             U.S. Public Domain, and may be freely used, modified, or
 *             distributed for any purpose whatever.
 * Filename:   readlisting.c
 * Purpose:    Reads a legacy AP-101S assembly listing for its object code.
 * Contact:    info@sandroid.org
 */

#include "readlisting.h"
#include "pyutil.h"
#include "val.h"

#define CHUNK_SIZE 4096

static ListSect *
listing_add (Listing *l, const char *name)
{
  ListSect *s;
  size_t i;
  if (l->n == l->cap)
    {
      l->cap = l->cap ? l->cap * 2 : 8;
      l->sects = (ListSect *) realloc (l->sects, l->cap * sizeof (ListSect));
      if (l->sects == NULL)
        fatal ("out of memory");
    }
  s = &l->sects[l->n++];
  s->name = arena_strdup (ARENA_MAIN, name);
  s->cap = CHUNK_SIZE;
  s->len = CHUNK_SIZE;
  s->memory = (int16_t *) malloc (s->cap * sizeof (int16_t));
  if (s->memory == NULL)
    fatal ("out of memory");
  for (i = 0; i < s->len; i++)
    s->memory[i] = -1;
  return s;
}

ListSect *
listing_find (Listing *l, const char *name)
{
  size_t i;
  if (l == NULL || name == NULL)
    return NULL;
  for (i = 0; i < l->n; i++)
    if (strcmp (l->sects[i].name, name) == 0)
      return &l->sects[i];
  return NULL;
}

static void
listing_grow (ListSect *s, size_t need)
{
  size_t i, old = s->len;
  while (need >= s->len)
    s->len += CHUNK_SIZE;
  if (s->len > s->cap)
    {
      while (s->cap < s->len)
        s->cap *= 2;
      s->memory = (int16_t *) realloc (s->memory, s->cap * sizeof (int16_t));
      if (s->memory == NULL)
        fatal ("out of memory");
    }
  for (i = old; i < s->len; i++)
    s->memory[i] = -1;
}

/* `re.match(r"[0-9A-F]{5} ", line[offset:offset+6])` */
static int
looksLikeAddress (const char *line, size_t lineLen, size_t offset)
{
  size_t i;
  if (offset + 6 > lineLen)
    return 0;
  for (i = 0; i < 5; i++)
    {
      char c = line[offset + i];
      if (!((c >= '0' && c <= '9') || (c >= 'A' && c <= 'F')))
        return 0;
    }
  return line[offset + 5] == ' ';
}

static int
hexValue (char c)
{
  if (c >= '0' && c <= '9')
    return c - '0';
  if (c >= 'A' && c <= 'F')
    return c - 'A' + 10;
  if (c >= 'a' && c <= 'f')
    return c - 'a' + 10;
  return -1;
}

Listing *
readListing (const char *filename)
{
  FILE *f;
  char **lines = NULL;
  size_t nlines = 0, capLines = 0;
  size_t shift = 0, candidate, best = 0;
  Listing *l;
  const char *sect = NULL;
  const char *firstCSECT = NULL;
  /* `name` and `operation` deliberately persist between cards.  The Python
     assigns them only in two of three cases, so a card that is neither leaves
     the previous card's values standing, and the tests below then see those. */
  const char *name = NULL;
  const char *operation = "";
  size_t i;

  f = fopen (filename, "rb");
  if (f == NULL)
    return NULL;
  {
    StrBuf b;
    int c;
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
            if (nlines == capLines)
              {
                capLines = capLines ? capLines * 2 : 1024;
                lines = (char **) realloc (lines, capLines * sizeof (char *));
                if (lines == NULL)
                  fatal ("out of memory");
              }
            lines[nlines++] = sb_dup (&b);
            sb_clear (&b);
            if (c == EOF)
              break;
          }
      }
    sb_free (&b);
  }
  fclose (f);

  /*
   * NOT EVERY LISTING STARTS IN COLUMN 1.  RUNLST's do, but the "as received"
   * listings carry an ANSI carriage-control character ahead of everything, so
   * every field sits one column further right.  Both alignments are tried and
   * the one that actually produces address lines wins.
   */
  {
    size_t bestCount = 0;
    for (i = 0; i < nlines; i++)
      if (looksLikeAddress (lines[i], strlen (lines[i]), 0))
        bestCount++;
    best = bestCount;
    for (candidate = 1; candidate < 4; candidate++)
      {
        size_t count = 0;
        for (i = 0; i < nlines; i++)
          if (looksLikeAddress (lines[i], strlen (lines[i]), candidate))
            count++;
        if (count > best)
          {
            best = count;
            shift = candidate;
          }
      }
  }

  l = (Listing *) calloc (1, sizeof (Listing));
  if (l == NULL)
    fatal ("out of memory");

  for (i = 0; i < nlines; i++)
    {
      const char *line = lines[i];
      size_t lineLen;
      char *front, *back;
      char col1;
      char **frontFields, **backFields;
      size_t nFront, nBack, k;
      asmint address;
      int values[64];
      size_t nValues = 0;
      int bad = 0;

      if (shift > 0)
        {
          size_t n = strlen (line);
          line = (shift < n) ? line + shift : "";
        }
      lineLen = strlen (line);

      if (lineLen > 20 && line[20] == ' ')
        front = arena_strndup (ARENA_MAIN, line, 21);
      else
        front = arena_strndup (ARENA_MAIN, line, lineLen < 30 ? lineLen : 30);
      back = (lineLen > 36)
                 ? arena_strndup (ARENA_MAIN, line + 36,
                                  (lineLen - 36) < 71 ? (lineLen - 36) : 71)
                 : arena_strdup (ARENA_MAIN, "");
      col1 = back[0];
      if (col1 == '*')
        continue;

      nFront = py_split_ws (front, &frontFields);
      if (nFront == 0 || strlen (frontFields[0]) != 5)
        continue;
      {
        int ok = 0;
        address = py_atoi_base (frontFields[0], 16, &ok);
        if (!ok)
          continue;
        address *= 2; /* to get a byte address */
      }
      for (k = 1; k < nFront && !bad; k++)
        {
          const char *field = frontFields[k];
          size_t flen = strlen (field);
          size_t j;
          if ((flen & 1) != 0)
            {
              bad = 1;
              break;
            }
          for (j = 0; j < flen; j += 2)
            {
              int hi = hexValue (field[j]), lo = hexValue (field[j + 1]);
              if (hi < 0 || lo < 0)
                {
                  bad = 1;
                  break;
                }
              if (nValues < sizeof (values) / sizeof (values[0]))
                values[nValues++] = hi * 16 + lo;
            }
        }
      if (bad)
        continue;

      nBack = py_split_ws (back, &backFields);
      if (nBack == 0)
        continue;
      if (nBack > 0 && col1 == ' ')
        {
          name = NULL;
          operation = backFields[0];
        }
      else if (nBack > 1 && col1 != ' ')
        {
          name = backFields[0];
          operation = backFields[1];
        }

      /*
       * THE LITERAL POOL BELONGS TO THE FIRST CONTROL SECTION, wherever it is
       * printed.  GC28-6514-8 page 23:  the first control section "contains the
       * literals of the program, unless their positioning has been altered by
       * LTORG statements."  A listing prints the pool after everything else,
       * which in these modules is after the last DSECT and with no CSECT card
       * to end it -- so this reader was still inside the DSECT and filed the
       * pool's bytes there.  Nothing generates object code in a DSECT, so they
       * came back as missing.
       */
      if (operation[0] == '=' || (name != NULL && name[0] == '='))
        {
          if (firstCSECT != NULL)
            sect = firstCSECT;
        }
      else if (strcmp (operation, "DSECT") == 0)
        {
          sect = name;
          continue;
        }
      else if (strcmp (operation, "CSECT") == 0
               || (sect == NULL && nValues > 0))
        {
          if (strcmp (operation, "CSECT") != 0)
            name = "";
          if (name == NULL)
            name = "";
          if (listing_find (l, name) == NULL)
            listing_add (l, name);
          sect = name;
          if (firstCSECT == NULL)
            firstCSECT = name;
          continue;
        }

      for (k = 0; k < nValues; k++)
        {
          ListSect *s;
          if (sect == NULL)
            sect = "";
          s = listing_find (l, sect);
          if (s == NULL)
            {
              /* A DSECT sets `sect` above without creating an entry here,
                 because a dummy section defines no storage of its own.  A
                 listing can still carry object code under one; create the
                 entry and keep the bytes. */
              s = listing_add (l, sect);
            }
          if ((size_t) address >= s->len)
            listing_grow (s, (size_t) address);
          if (s->memory[address] != -1 && s->memory[address] != values[k])
            printf ("Memory overwritten: %s,%05X %02X->%02X\n", sect,
                    (unsigned) address, (unsigned) s->memory[address],
                    (unsigned) values[k]);
          s->memory[address] = (int16_t) values[k];
          address += 1;
        }
    }

  for (i = 0; i < l->n; i++)
    {
      ListSect *s = &l->sects[i];
      while (s->len > 0 && s->memory[s->len - 1] == -1)
        s->len--;
    }
  free (lines);
  return l;
}
