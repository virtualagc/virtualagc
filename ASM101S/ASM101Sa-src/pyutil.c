/*
 * License:    This program is declared by its author, Ronald Burkey, to be the
 *             U.S. Public Domain, and may be freely used, modified, or
 *             distributed for any purpose whatever.
 * Filename:   pyutil.c
 * Purpose:    Implementation of the Python-compatible helpers.
 * Contact:    info@sandroid.org
 */

#include "pyutil.h"
#include "val.h"

#include <ctype.h>
#include <math.h>
#include <stdarg.h>

/*===========================================================================
 * StrBuf
 */
void
sb_init (StrBuf *b)
{
  b->s = NULL;
  b->len = 0;
  b->cap = 0;
}

void
sb_free (StrBuf *b)
{
  free (b->s);
  b->s = NULL;
  b->len = 0;
  b->cap = 0;
}

void
sb_clear (StrBuf *b)
{
  b->len = 0;
  if (b->s != NULL)
    b->s[0] = '\0';
}

static void
sb_reserve (StrBuf *b, size_t need)
{
  if (need + 1 <= b->cap)
    return;
  {
    size_t cap = b->cap ? b->cap : 64;
    char *p;
    while (cap < need + 1)
      cap *= 2;
    p = (char *) realloc (b->s, cap);
    if (p == NULL)
      fatal ("out of memory");
    b->s = p;
    b->cap = cap;
    if (b->len == 0)
      b->s[0] = '\0';
  }
}

void
sb_addn (StrBuf *b, const char *s, size_t n)
{
  if (n == 0)
    {
      sb_reserve (b, 0);
      return;
    }
  sb_reserve (b, b->len + n);
  memcpy (b->s + b->len, s, n);
  b->len += n;
  b->s[b->len] = '\0';
}

void
sb_add (StrBuf *b, const char *s)
{
  if (s != NULL)
    sb_addn (b, s, strlen (s));
}

void
sb_addc (StrBuf *b, char c)
{
  sb_addn (b, &c, 1);
}

void
sb_addf (StrBuf *b, const char *fmt, ...)
{
  va_list ap;
  int n;
  char stackBuf[512];
  va_start (ap, fmt);
  n = vsnprintf (stackBuf, sizeof (stackBuf), fmt, ap);
  va_end (ap);
  if (n < 0)
    return;
  if ((size_t) n < sizeof (stackBuf))
    {
      sb_addn (b, stackBuf, (size_t) n);
      return;
    }
  {
    char *big = (char *) malloc ((size_t) n + 1);
    if (big == NULL)
      fatal ("out of memory");
    va_start (ap, fmt);
    vsnprintf (big, (size_t) n + 1, fmt, ap);
    va_end (ap);
    sb_addn (b, big, (size_t) n);
    free (big);
  }
}

char *
sb_dup (const StrBuf *b)
{
  return arena_strndup (ARENA_MAIN, b->s ? b->s : "", b->len);
}

char *
sb_take (StrBuf *b)
{
  char *out = sb_dup (b);
  sb_free (b);
  return out;
}

/*===========================================================================
 * Numbers
 */
asmint
py_round (double x)
{
  /*
   * PYTHON ROUNDS HALF TO EVEN, and this matters wherever a scaled constant
   * lands exactly on a half.  C's round() rounds half away from zero, and
   * nearbyint() depends on the current rounding mode, so neither can be used
   * without setting or assuming state.  This computes it outright.
   */
  double f = floor (x);
  double diff = x - f;
  double r;
  if (diff > 0.5)
    r = f + 1.0;
  else if (diff < 0.5)
    r = f;
  else
    {
      /* Exactly halfway: choose the even neighbour. */
      double half = f / 2.0;
      r = (half == floor (half)) ? f : f + 1.0;
    }
  return (asmint) r;
}

asmint
py_div_trunc (asmint a, asmint b)
{
  /*
   * Assembler division is integer division with the remainder discarded, and
   * division by zero yields zero rather than failing (GC28-6514-8 p.28).
   * Truncation is toward zero rather than floor, so -7/2 is -3 and not -4.
   */
  asmuint ua, ub, q;
  int negative;
  if (b == 0)
    return 0;
  negative = ((a < 0) != (b < 0));
  ua = (a < 0) ? (asmuint) 0 - (asmuint) a : (asmuint) a;
  ub = (b < 0) ? (asmuint) 0 - (asmuint) b : (asmuint) b;
  q = ua / ub;
  return negative ? (asmint) ((asmuint) 0 - q) : (asmint) q;
}

asmint
py_floordiv (asmint a, asmint b)
{
  asmint q;
  if (b == 0)
    return 0;
  q = py_div_trunc (a, b);
  if (ASM_SUB (a, ASM_MUL (q, b)) != 0 && ((a < 0) != (b < 0)))
    q -= 1;
  return q;
}

asmint
py_mod (asmint a, asmint b)
{
  if (b == 0)
    return 0;
  return ASM_SUB (a, ASM_MUL (py_floordiv (a, b), b));
}

void
py_float_repr (char *out, size_t outSize, double x)
{
  /*
   * Python's repr() of a float is the shortest decimal string that reads back
   * as the same double.  %.17g always round-trips but is ugly; try shorter
   * precisions first, exactly as CPython's own algorithm arrives at.
   */
  int precision;
  if (x != x)
    {
      snprintf (out, outSize, "nan");
      return;
    }
  if (x == (double) (int64_t) x && x > -1e16 && x < 1e16)
    {
      snprintf (out, outSize, "%.1f", x);
      return;
    }
  for (precision = 1; precision <= 17; precision++)
    {
      snprintf (out, outSize, "%.*g", precision, x);
      if (strtod (out, NULL) == x)
        break;
    }
}

/* Used by val.c's repr of a float. */
void
asm_format_float (char *out, size_t outSize, double d)
{
  py_float_repr (out, outSize, d);
}

double
py_atof (const char *s)
{
  return strtod (s, NULL);
}

asmint
py_atoi_base (const char *s, int base, int *ok)
{
  asmuint value = 0;
  int negative = 0;
  int any = 0;
  if (ok != NULL)
    *ok = 0;
  if (s == NULL)
    return 0;
  while (*s == ' ' || *s == '\t')
    s++;
  if (*s == '+')
    s++;
  else if (*s == '-')
    {
      negative = 1;
      s++;
    }
  for (; *s != '\0'; s++)
    {
      int digit;
      char c = *s;
      if (c >= '0' && c <= '9')
        digit = c - '0';
      else if (c >= 'A' && c <= 'Z')
        digit = c - 'A' + 10;
      else if (c >= 'a' && c <= 'z')
        digit = c - 'a' + 10;
      else if (c == ' ' || c == '\t')
        break;
      else
        return 0;
      if (digit >= base)
        return 0;
      value = value * (asmuint) base + (asmuint) digit;
      any = 1;
    }
  while (*s == ' ' || *s == '\t')
    s++;
  if (*s != '\0' || !any)
    return 0;
  if (ok != NULL)
    *ok = 1;
  return negative ? (asmint) ((asmuint) 0 - value) : (asmint) value;
}

int
py_parse_int (const char *s, asmint *out)
{
  int ok = 0;
  asmint v = py_atoi_base (s, 10, &ok);
  if (ok && out != NULL)
    *out = v;
  return ok;
}

/*===========================================================================
 * Strings
 */
int
py_isdigit_n (const char *s, size_t n)
{
  size_t i;
  if (n == 0)
    return 0; /* str.isdigit() is False for the empty string. */
  for (i = 0; i < n; i++)
    if (s[i] < '0' || s[i] > '9')
      return 0;
  return 1;
}

int
py_isdigit (const char *s)
{
  return s == NULL ? 0 : py_isdigit_n (s, strlen (s));
}

char *
py_ljust (const char *s, size_t width)
{
  size_t n = strlen (s);
  char *out;
  if (n >= width)
    return arena_strdup (ARENA_MAIN, s);
  out = (char *) arena_alloc (ARENA_MAIN, width + 1);
  memcpy (out, s, n);
  memset (out + n, ' ', width - n);
  out[width] = '\0';
  return out;
}

char *
py_rjust (const char *s, size_t width, char fill)
{
  size_t n = strlen (s);
  char *out;
  if (n >= width)
    return arena_strdup (ARENA_MAIN, s);
  out = (char *) arena_alloc (ARENA_MAIN, width + 1);
  memset (out, fill, width - n);
  memcpy (out + width - n, s, n);
  out[width] = '\0';
  return out;
}

char *
py_center (const char *s, size_t width)
{
  /*
   * str.center() puts the ODD column on the RIGHT:  'AB'.center(5) is ' AB  '.
   * Getting that backwards shifts the listing's heading by one column on every
   * page whose title has odd length.
   */
  size_t n = strlen (s);
  size_t left, right;
  char *out;
  if (n >= width)
    return arena_strdup (ARENA_MAIN, s);
  left = (width - n) / 2;
  right = width - n - left;
  out = (char *) arena_alloc (ARENA_MAIN, width + 1);
  memset (out, ' ', left);
  memcpy (out + left, s, n);
  memset (out + left + n, ' ', right);
  out[width] = '\0';
  return out;
}

static int
in_chars (char c, const char *chars)
{
  return strchr (chars, c) != NULL;
}

char *
py_rstrip_chars (const char *s, const char *chars)
{
  size_t n = strlen (s);
  while (n > 0 && in_chars (s[n - 1], chars))
    n--;
  return arena_strndup (ARENA_MAIN, s, n);
}

char *
py_rstrip (const char *s)
{
  return py_rstrip_chars (s, " \t\r\n\f\v");
}

char *
py_lstrip (const char *s)
{
  while (*s == ' ' || *s == '\t' || *s == '\r' || *s == '\n' || *s == '\f'
         || *s == '\v')
    s++;
  return arena_strdup (ARENA_MAIN, s);
}

char *
py_strip (const char *s)
{
  size_t n;
  while (*s == ' ' || *s == '\t' || *s == '\r' || *s == '\n' || *s == '\f'
         || *s == '\v')
    s++;
  n = strlen (s);
  while (n > 0
         && (s[n - 1] == ' ' || s[n - 1] == '\t' || s[n - 1] == '\r'
             || s[n - 1] == '\n' || s[n - 1] == '\f' || s[n - 1] == '\v'))
    n--;
  return arena_strndup (ARENA_MAIN, s, n);
}

char *
py_upper (const char *s)
{
  size_t n = strlen (s), i;
  char *out = arena_strndup (ARENA_MAIN, s, n);
  for (i = 0; i < n; i++)
    out[i] = (char) toupper ((unsigned char) out[i]);
  return out;
}

char *
py_replace (const char *s, const char *from, const char *to)
{
  StrBuf b;
  size_t fromLen = strlen (from);
  sb_init (&b);
  if (fromLen == 0)
    return arena_strdup (ARENA_MAIN, s);
  while (*s != '\0')
    {
      if (strncmp (s, from, fromLen) == 0)
        {
          sb_add (&b, to);
          s += fromLen;
        }
      else
        sb_addc (&b, *s++);
    }
  return sb_take (&b);
}

char *
py_format (const char *fmt, ...)
{
  va_list ap;
  int n;
  char stackBuf[1024];
  char *out;
  va_start (ap, fmt);
  n = vsnprintf (stackBuf, sizeof (stackBuf), fmt, ap);
  va_end (ap);
  if (n < 0)
    return arena_strdup (ARENA_MAIN, "");
  if ((size_t) n < sizeof (stackBuf))
    return arena_strndup (ARENA_MAIN, stackBuf, (size_t) n);
  out = (char *) arena_alloc (ARENA_MAIN, (size_t) n + 1);
  va_start (ap, fmt);
  vsnprintf (out, (size_t) n + 1, fmt, ap);
  va_end (ap);
  return out;
}

char *
py_concat (const char *a, const char *b)
{
  size_t la = strlen (a), lb = strlen (b);
  char *out = (char *) arena_alloc (ARENA_MAIN, la + lb + 1);
  memcpy (out, a, la);
  memcpy (out + la, b, lb);
  out[la + lb] = '\0';
  return out;
}

char *
py_substr (const char *s, size_t start, size_t len)
{
  size_t n = strlen (s);
  if (start > n)
    start = n;
  if (start + len > n)
    len = n - start;
  return arena_strndup (ARENA_MAIN, s + start, len);
}

char *
py_repeat (const char *s, size_t n)
{
  size_t l = strlen (s);
  char *out = (char *) arena_alloc (ARENA_MAIN, l * n + 1);
  size_t i;
  for (i = 0; i < n; i++)
    memcpy (out + i * l, s, l);
  out[l * n] = '\0';
  return out;
}

int
py_startswith (const char *s, const char *prefix)
{
  return strncmp (s, prefix, strlen (prefix)) == 0;
}

int
py_endswith (const char *s, const char *suffix)
{
  size_t ls = strlen (s), lp = strlen (suffix);
  return ls >= lp && strcmp (s + ls - lp, suffix) == 0;
}

const char *
py_find (const char *s, const char *needle)
{
  return strstr (s, needle);
}

static int
is_ws (char c)
{
  return c == ' ' || c == '\t' || c == '\r' || c == '\n' || c == '\f'
         || c == '\v';
}

size_t
py_split_ws (const char *s, char ***fields)
{
  size_t count = 0, cap = 8;
  char **out = (char **) arena_alloc (ARENA_MAIN, cap * sizeof (char *));
  while (*s != '\0')
    {
      const char *start;
      while (*s != '\0' && is_ws (*s))
        s++;
      if (*s == '\0')
        break;
      start = s;
      while (*s != '\0' && !is_ws (*s))
        s++;
      if (count == cap)
        {
          char **bigger
              = (char **) arena_alloc (ARENA_MAIN, cap * 2 * sizeof (char *));
          memcpy (bigger, out, cap * sizeof (char *));
          out = bigger;
          cap *= 2;
        }
      out[count++] = arena_strndup (ARENA_MAIN, start, (size_t) (s - start));
    }
  *fields = out;
  return count;
}

size_t
py_split_char (const char *s, char c, char ***fields)
{
  size_t count = 0, cap = 8;
  char **out = (char **) arena_alloc (ARENA_MAIN, cap * sizeof (char *));
  const char *start = s;
  for (;;)
    {
      const char *p = strchr (start, c);
      size_t n = (p != NULL) ? (size_t) (p - start) : strlen (start);
      if (count == cap)
        {
          char **bigger
              = (char **) arena_alloc (ARENA_MAIN, cap * 2 * sizeof (char *));
          memcpy (bigger, out, cap * sizeof (char *));
          out = bigger;
          cap *= 2;
        }
      out[count++] = arena_strndup (ARENA_MAIN, start, n);
      if (p == NULL)
        break;
      start = p + 1;
    }
  *fields = out;
  return count;
}
