/*
 * License:    This program is declared by its author, Ronald Burkey, to be the
 *             U.S. Public Domain, and may be freely used, modified, or
 *             distributed for any purpose whatever.
 * Filename:   dec.c
 * Purpose:    Decimal arithmetic to Python's rules, at 20 significant digits.
 * Contact:    info@sandroid.org
 */

#include "dec.h"

#include <math.h>

void
dec_zero (Dec *r)
{
  r->sign = 0;
  r->nd = 0;
  r->exp = 0;
}

int
dec_is_zero (const Dec *a)
{
  return a->nd == 0;
}

/* Drop leading zeros, and collapse an all-zero coefficient to canonical zero.
   Trailing zeros are LEFT ALONE:  Python keeps them too, and they affect only
   a representation this never prints. */
static void
dec_normalize (Dec *r)
{
  int i = 0;
  while (i < r->nd && r->d[i] == 0)
    i++;
  if (i == r->nd)
    {
      dec_zero (r);
      return;
    }
  if (i > 0)
    {
      memmove (r->d, r->d + i, (size_t) (r->nd - i));
      r->nd -= i;
    }
}

static void
dec_strip_trailing_zeros (Dec *r)
{
  while (r->nd > 1 && r->d[r->nd - 1] == 0)
    {
      r->nd--;
      r->exp++;
    }
  if (r->nd == 1 && r->d[0] == 0)
    dec_zero (r);
}

/*---------------------------------------------------------------------------
 * Rounding to `prec` significant digits.  `halfUp` selects ROUND_HALF_UP,
 * which `to_integral_value` asks for; otherwise ties go to even, which is
 * Python's default context rounding and therefore what * and / use.
 */
static void
dec_round_prec (Dec *r, int prec, int halfUp)
{
  int drop, i;
  int roundUp;
  if (r->nd <= prec)
    return;
  drop = r->nd - prec;
  {
    unsigned char first = r->d[prec];
    int rest = 0;
    for (i = prec + 1; i < r->nd; i++)
      if (r->d[i] != 0)
        {
          rest = 1;
          break;
        }
    if (first > 5)
      roundUp = 1;
    else if (first < 5)
      roundUp = 0;
    else if (rest)
      roundUp = 1;
    else if (halfUp)
      roundUp = 1;
    else
      roundUp = (prec > 0) && (r->d[prec - 1] & 1);
  }
  r->nd = prec;
  r->exp += drop;
  if (roundUp)
    {
      for (i = prec - 1; i >= 0; i--)
        {
          if (r->d[i] < 9)
            {
              r->d[i]++;
              break;
            }
          r->d[i] = 0;
        }
      if (i < 0)
        {
          /* Carried out of the top -- 999 becomes 1000 -- which is one digit
             wider and has to be rounded back down to `prec`. */
          memmove (r->d + 1, r->d, (size_t) prec);
          r->d[0] = 1;
          r->nd = prec + 1;
          dec_round_prec (r, prec, halfUp);
          return;
        }
    }
  dec_normalize (r);
}

/*---------------------------------------------------------------------------
 * Construction
 */
void
dec_from_int (Dec *r, uint64_t n)
{
  unsigned char buf[24];
  int i, len = 0;
  dec_zero (r);
  if (n == 0)
    return;
  while (n > 0)
    {
      buf[len++] = (unsigned char) (n % 10);
      n /= 10;
    }
  r->nd = len;
  r->exp = 0;
  for (i = 0; i < len; i++)
    r->d[i] = buf[len - 1 - i];
}

int
dec_from_string (Dec *r, const char *s)
{
  int nd = 0, exp = 0, seen = 0, afterPoint = 0;
  dec_zero (r);
  while (*s == ' ' || *s == '\t')
    s++;
  if (*s == '+')
    s++;
  else if (*s == '-')
    {
      r->sign = 1;
      s++;
    }
  for (; *s != '\0'; s++)
    {
      if (*s >= '0' && *s <= '9')
        {
          seen = 1;
          if (nd < DEC_MAX_DIGITS)
            r->d[nd++] = (unsigned char) (*s - '0');
          if (afterPoint)
            exp--;
        }
      else if (*s == '.' && !afterPoint)
        afterPoint = 1;
      else if (*s == 'E' || *s == 'e')
        {
          int esign = 1, ev = 0, any = 0;
          s++;
          if (*s == '+')
            s++;
          else if (*s == '-')
            {
              esign = -1;
              s++;
            }
          for (; *s >= '0' && *s <= '9'; s++)
            {
              ev = ev * 10 + (*s - '0');
              any = 1;
            }
          if (!any || *s != '\0')
            return 0;
          exp += esign * ev;
          break;
        }
      else
        return 0;
    }
  if (!seen)
    return 0;
  r->nd = nd;
  r->exp = exp;
  dec_normalize (r);
  return 1;
}

/* Multiply the coefficient in place by a small integer. */
static void
coeff_mul_small (Dec *r, unsigned int m)
{
  unsigned int carry = 0;
  int i;
  if (r->nd == 0)
    return;
  for (i = r->nd - 1; i >= 0; i--)
    {
      unsigned int v = (unsigned int) r->d[i] * m + carry;
      r->d[i] = (unsigned char) (v % 10);
      carry = v / 10;
    }
  while (carry > 0)
    {
      if (r->nd >= DEC_MAX_DIGITS)
        fatal ("decimal coefficient overflow");
      memmove (r->d + 1, r->d, (size_t) r->nd);
      r->d[0] = (unsigned char) (carry % 10);
      carry /= 10;
      r->nd++;
    }
}

void
dec_pow2 (Dec *r, int n)
{
  int i;
  dec_from_int (r, 1);
  if (n >= 0)
    {
      for (i = 0; i < n; i++)
        coeff_mul_small (r, 2);
      return;
    }
  /* 2**-n is 5**n / 10**n, exactly. */
  for (i = 0; i < -n; i++)
    coeff_mul_small (r, 5);
  r->exp = n;
}

/* An exact product, without rounding.  Used only where Python's own
   construction is exact. */
static void
dec_mul_exact (Dec *r, const Dec *a, const Dec *b)
{
  int na = a->nd, nb = b->nd, i, k, n;
  static unsigned int acc[DEC_MAX_DIGITS];
  Dec out;
  if (na == 0 || nb == 0)
    {
      dec_zero (r);
      return;
    }
  n = na + nb;
  if (n > DEC_MAX_DIGITS)
    fatal ("decimal coefficient overflow in multiply");
  for (k = 0; k < n; k++)
    acc[k] = 0;
  for (i = na - 1; i >= 0; i--)
    for (k = nb - 1; k >= 0; k--)
      acc[i + k + 1] += (unsigned int) a->d[i] * b->d[k];
  for (k = n - 1; k > 0; k--)
    {
      acc[k - 1] += acc[k] / 10;
      acc[k] %= 10;
    }
  out.sign = a->sign ^ b->sign;
  out.nd = n;
  out.exp = a->exp + b->exp;
  for (k = 0; k < n; k++)
    out.d[k] = (unsigned char) acc[k];
  dec_normalize (&out);
  *r = out;
}

void
dec_from_double (Dec *r, double x)
{
  int e, i, negative = 0;
  double m;
  uint64_t mantissa;
  Dec mant, p2;
  dec_zero (r);
  if (x == 0.0)
    return;
  if (x < 0)
    {
      negative = 1;
      x = -x;
    }
  /* A double is m * 2**e with m a 53-bit integer once it is scaled up, so its
     decimal expansion is finite and this is exact -- which is what
     Decimal(float) gives, and what a scale modifier of 2**-n needs. */
  m = frexp (x, &e);
  for (i = 0; i < 64 && m != floor (m); i++)
    {
      m *= 2.0;
      e--;
    }
  mantissa = (uint64_t) m;
  dec_from_int (&mant, mantissa);
  dec_pow2 (&p2, e);
  dec_mul_exact (r, &mant, &p2);
  if (negative && r->nd != 0)
    r->sign = 1;
}

/*---------------------------------------------------------------------------
 * Comparison
 */
static int
cmp_magnitude (const Dec *a, const Dec *b)
{
  int ea, eb, i;
  if (a->nd == 0 && b->nd == 0)
    return 0;
  if (a->nd == 0)
    return -1;
  if (b->nd == 0)
    return 1;
  ea = a->exp + a->nd; /* where the decimal point sits relative to d[0] */
  eb = b->exp + b->nd;
  if (ea != eb)
    return ea < eb ? -1 : 1;
  for (i = 0; i < a->nd || i < b->nd; i++)
    {
      int da = i < a->nd ? a->d[i] : 0;
      int db = i < b->nd ? b->d[i] : 0;
      if (da != db)
        return da < db ? -1 : 1;
    }
  return 0;
}

int
dec_cmp (const Dec *a, const Dec *b)
{
  int sa = a->nd == 0 ? 0 : (a->sign ? -1 : 1);
  int sb = b->nd == 0 ? 0 : (b->sign ? -1 : 1);
  if (sa != sb)
    return sa < sb ? -1 : 1;
  if (sa == 0)
    return 0;
  {
    int c = cmp_magnitude (a, b);
    return sa < 0 ? -c : c;
  }
}

void
dec_neg (Dec *r)
{
  if (r->nd != 0)
    r->sign = !r->sign;
}

/*---------------------------------------------------------------------------
 * Multiplication and division, both rounded to the context precision.
 */
void
dec_mul (Dec *r, const Dec *a, const Dec *b)
{
  dec_mul_exact (r, a, b);
  dec_round_prec (r, DEC_PRECISION, 0);
}

/*
 * Classic long division.  The remainder is kept as a digit array and one
 * quotient digit is produced per step, so a quotient digit is always 0..9 --
 * subtracting the divisor from the whole remainder instead, which is the
 * obvious shortcut, produces "digits" above 9 the moment the dividend is more
 * than ten times the divisor.
 *
 * An exact quotient stops early and keeps its exact value, which is what
 * Python gives:  Decimal(10)/Decimal(16) is 0.625, not 0.625 padded out to
 * twenty digits.  Otherwise one guard digit past the precision is produced and
 * the remainder becomes the sticky bit for the rounding.
 */
void
dec_div (Dec *r, const Dec *a, const Dec *b)
{
  unsigned char rem[DEC_MAX_DIGITS + 4];
  int remLen = 0;
  unsigned char q[DEC_PRECISION + 8];
  int qn = 0;
  int sig = 0;   /* significant quotient digits so far */
  int extra = 0; /* digits produced after the dividend ran out */
  int i, k;
  int exact = 0;

  if (b->nd == 0)
    fatal ("decimal division by zero");
  if (a->nd == 0)
    {
      dec_zero (r);
      return;
    }

  i = 0;
  for (;;)
    {
      unsigned char bring;
      int digit = 0;
      if (i < a->nd)
        bring = a->d[i++];
      else
        {
          bring = 0;
          extra++;
        }
      /* rem = rem * 10 + bring */
      if (remLen > 0 || bring != 0)
        {
          if (remLen + 1 > (int) sizeof (rem))
            fatal ("decimal division overflow");
          rem[remLen++] = bring;
          if (remLen > 1 && rem[0] == 0)
            {
              memmove (rem, rem + 1, (size_t) (remLen - 1));
              remLen--;
            }
        }
      /* How many times does b's coefficient fit?  At most nine. */
      for (;;)
        {
          int cmp;
          if (remLen > b->nd)
            cmp = 1;
          else if (remLen < b->nd)
            cmp = -1;
          else
            {
              cmp = 0;
              for (k = 0; k < remLen; k++)
                if (rem[k] != b->d[k])
                  {
                    cmp = rem[k] > b->d[k] ? 1 : -1;
                    break;
                  }
            }
          if (cmp < 0)
            break;
          {
            int borrow = 0;
            int off = remLen - b->nd;
            for (k = b->nd - 1; k >= 0; k--)
              {
                int v = rem[off + k] - b->d[k] - borrow;
                if (v < 0)
                  {
                    v += 10;
                    borrow = 1;
                  }
                else
                  borrow = 0;
                rem[off + k] = (unsigned char) v;
              }
            for (k = off - 1; k >= 0 && borrow; k--)
              {
                int v = rem[k] - borrow;
                if (v < 0)
                  {
                    v += 10;
                    borrow = 1;
                  }
                else
                  borrow = 0;
                rem[k] = (unsigned char) v;
              }
          }
          {
            int lead = 0;
            while (lead < remLen && rem[lead] == 0)
              lead++;
            if (lead == remLen)
              remLen = 0;
            else if (lead > 0)
              {
                memmove (rem, rem + lead, (size_t) (remLen - lead));
                remLen -= lead;
              }
          }
          digit++;
        }
      if (qn < (int) sizeof (q))
        q[qn++] = (unsigned char) digit;
      else
        fatal ("decimal division overflow");
      if (sig > 0 || digit != 0)
        sig++;
      if (remLen == 0 && i >= a->nd)
        {
          exact = 1;
          break;
        }
      if (sig > DEC_PRECISION)
        break;
    }

  r->sign = a->sign ^ b->sign;
  r->nd = qn;
  for (k = 0; k < qn; k++)
    r->d[k] = q[k];
  /* The quotient digits form an integer that was scaled down by one power of
     ten for every digit produced after the dividend ran out. */
  r->exp = a->exp - b->exp - extra;
  dec_normalize (r);
  if (r->nd == 0)
    return;
  if (!exact)
    {
      /* A non-zero remainder makes the discarded tail non-zero, which decides
         a tie exactly as a further non-zero digit would. */
      if (remLen != 0 && r->nd < DEC_MAX_DIGITS)
        {
          r->d[r->nd++] = 1;
          r->exp--;
        }
      dec_round_prec (r, DEC_PRECISION, 0);
    }
  else
    {
      dec_round_prec (r, DEC_PRECISION, 0);
      dec_strip_trailing_zeros (r);
    }
}

/*---------------------------------------------------------------------------
 * to_integral_value(ROUND_HALF_UP), then int().
 */
uint64_t
dec_to_integral_half_up (const Dec *a, int *ok)
{
  Dec t = *a;
  uint64_t v = 0;
  int i;
  if (ok != NULL)
    *ok = 1;
  if (t.nd == 0)
    return 0;
  if (t.exp < 0)
    {
      int keep = t.nd + t.exp; /* digits ahead of the decimal point */
      if (keep <= 0)
        {
          /* The magnitude is below one, so the answer is 0 or 1 and the only
             way it is 1 is a leading digit of 5 or more in the tenths place. */
          return (keep == 0 && t.d[0] >= 5) ? 1u : 0u;
        }
      dec_round_prec (&t, keep, 1);
      /* dec_round_prec has already moved the exponent to the units place, or
         to one above it if the rounding carried out of the top. */
    }
  for (i = 0; i < t.nd; i++)
    {
      if (v > (uint64_t) 0xFFFFFFFFFFFFFFFFULL / 10)
        {
          if (ok != NULL)
            *ok = 0;
          return 0;
        }
      v = v * 10 + t.d[i];
    }
  for (i = 0; i < t.exp; i++)
    {
      if (v > (uint64_t) 0xFFFFFFFFFFFFFFFFULL / 10)
        {
          if (ok != NULL)
            *ok = 0;
          return 0;
        }
      v *= 10;
    }
  return v;
}
