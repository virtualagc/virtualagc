/*
 * Copyright 2021 Ronald S. Burkey <info@sandroid.org>
 *
 * This file is part of yaAGC.
 *
 * yaAGC is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * yaAGC is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with yaAGC; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 *
 * Filename:    strcmpEBCDIC.c
 * Purpose:     Compare two strings in EBCDIC collation order.
 * Mod History: 2021-04-20 RSB  Began.
 *
 * All that's provided here is a replacement for strcmp() that
 * compares in EBCDIC ordering rather than ASCII ordering.  Plus
 * a bonus function that does the same for the Honeywell H-800
 * character encoding.
 *
 * I assume, not necessarily correctly, that the native encoding for
 * strings is plain-vanilla 8-bit ASCII.  If it's not, then this
 * function won't work.  (Probably a lot of other stuff in yaYUL
 * won't work either, but I don't care about that at the moment.)
 * A better approach might be to try an use the iconv() related
 * function in libiconv, but I'm afraid that if I do that, I'll
 * open up a world of hurt, cross-platform-wise.
 */

#include "yaYUL.h"
#include <stdlib.h>
#include <string.h>
#include <stdio.h>

// I copied this array from the web, and am not sure of its actual
// origin or accuracy without doing the work myself :frown:.
// Still, it should be good enough for my purpose, which is simply to
// compare strings containing the characters in symbols used in
// AGC code.  Presumably I could have gotten a more-trustworthy version
// from table 13-2 of the document FR-2-113
// (http://www.ibiblio.org/apollo/Documents/agcis_13_yul.pdf#page=32).
// The array contains the numerical EBCDIC equivalent for each ASCII
// character.
static unsigned char asciiToEbcdic[256] =
  { 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, /*              */
  0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, /*              */
  0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, /*              */
  0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, /*              */
  0x40, 0x4F, 0x7F, 0x7B, 0x5B, 0x6C, 0x50, 0x7D, /*  !"#$%&'     */
  0x4D, 0x5D, 0x5C, 0x4E, 0x6B, 0x60, 0x4B, 0x61, /* ()*+,-./     */
  0xF0, 0xF1, 0xF2, 0xF3, 0xF4, 0xF5, 0xF6, 0xF7, /* 01234567     */
  0xF8, 0xF9, 0x7A, 0x5E, 0x4C, 0x7E, 0x6E, 0x6F, /* 89:;<=>?     */
  0x7C, 0xC1, 0xC2, 0xC3, 0xC4, 0xC5, 0xC6, 0xC7, /* @ABCDEFG     */
  0xC8, 0xC9, 0xD1, 0xD2, 0xD3, 0xD4, 0xD5, 0xD6, /* HIJKLMNO     */
  0xD7, 0xD8, 0xD9, 0xE2, 0xE3, 0xE4, 0xE5, 0xE6, /* PQRSTUVW     */
  0xE7, 0xE8, 0xE9, 0x4A, 0xE0, 0x5A, 0x5F, 0x6D, /* XYZ[\]^_     */
  0x79, 0x81, 0x82, 0x83, 0x84, 0x85, 0x86, 0x87, /* `abcdefg     */
  0x88, 0x89, 0x91, 0x92, 0x93, 0x94, 0x95, 0x96, /* hijklmno     */
  0x97, 0x98, 0x99, 0xA2, 0xA3, 0xA4, 0xA5, 0xA6, /* pqrstuvw     */
  0xA7, 0xA8, 0xA9, 0xC0, 0x6A, 0xD0, 0xA1, 0x40, /* xyz{|}~      */
  0xB9, 0xBA, 0xED, 0xBF, 0xBC, 0xBD, 0xEC, 0xFA, /*              */
  0xCB, 0xCC, 0xCD, 0xCE, 0xCF, 0xDA, 0xDB, 0xDC, /*              */
  0xDE, 0xDF, 0xEA, 0xEB, 0xBE, 0xCA, 0xBB, 0xFE, /*              */
  0xFB, 0xFD, 0x7d, 0xEF, 0xEE, 0xFC, 0xB8, 0xDD, /*              */
  0x77, 0x78, 0xAF, 0x8D, 0x8A, 0x8B, 0xAE, 0xB2, /*              */
  0x8F, 0x90, 0x9A, 0x9B, 0x9C, 0x9D, 0x9E, 0x9F, /*              */
  0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, /*              */
  0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, /*              */
  0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, /*              */
  0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, /*              */
  0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, /*              */
  0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, /*              */
  0xAA, 0xAB, 0xAC, 0xAD, 0x8C, 0x8E, 0x80, 0xB6, /* ????         */
  0xB3, 0xB5, 0xB7, 0xB1, 0xB0, 0xB4, 0x76, 0xA0, /*              */
  0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, /*              */
  0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40 /*               */
  };

// The Honeywell (system H-800, printer H-822) version of the table above
// is below.  I got the data from table 13-2 (columns "H822-3" and "H800 Code")
// of the document referenced above.
static unsigned char asciiToHoneywell[256] =
  { 060, 060, 060, 060, 060, 060, 060, 060, 060, 060, 060, 060, 060, 060, 060,
      060,

      060, 060, 060, 060, 060, 060, 060, 060, 060, 060, 060, 060, 060, 060, 060,
      060,

      015, 060, 055, 052, 053, 035, 017, 012, /*   "#$%&' */
      074, 034, 054, 020, 073, 040, 033, 061, /* ()*+,-./ */

      000, 001, 002, 003, 004, 005, 006, 007, /* 01234567 */
      010, 011, 014, 032, 060, 013, 060, 060, /* 89:; =   */

      072, 021, 022, 023, 024, 025, 026, 027, /* @ABCDEFG */
      030, 031, 041, 042, 043, 044, 045, 046, /* HIJKLMNO */

      047, 050, 051, 062, 063, 064, 065, 066, /* PQRSTUVW */
      067, 070, 071, 060, 060, 060, 060, 060, /* XYZ      */

      060, 060, 060, 060, 060, 060, 060, 060, 060, 060, 060, 060, 060, 060, 060,
      060,

      060, 060, 060, 060, 060, 060, 060, 060, 060, 060, 060, 060, 060, 060, 060,
      060,

      060, 060, 060, 060, 060, 060, 060, 060, 060, 060, 060, 060, 060, 060, 060,
      060,

      060, 060, 060, 060, 060, 060, 060, 060, 060, 060, 060, 060, 060, 060, 060,
      060,

      060, 060, 060, 060, 060, 060, 060, 060, 060, 060, 060, 060, 060, 060, 060,
      060,

      060, 060, 060, 060, 060, 060, 060, 060, 060, 060, 060, 060, 060, 060, 060,
      060,

      060, 060, 060, 060, 060, 060, 060, 060, 060, 060, 060, 060, 060, 060, 060,
      060,

      060, 060, 060, 060, 060, 060, 060, 060, 060, 060, 060, 060, 060, 060, 060,
      060,

      060, 060, 060, 060, 060, 060, 060, 060, 060, 060, 060, 060, 060, 060, 060,
      060,

      060, 060, 060, 060, 060, 060, 060, 060, 060, 060, 060, 060, 060, 060, 060,
      060 };

int
strcmpGeneral(const char *s1, const char *s2, unsigned char *translationTable)
{
  int idummy;
  for (; *s1; s1++, s2++)
    {
      if (!*s2) // s2 shorter than s1.
        return (1);
      idummy = translationTable[(unsigned int) *s1]
          - translationTable[(unsigned int) *s2];
      if (idummy)
        return (idummy);
    }
  if (*s2) // s2 longer than s1.
    return (-1);
  return (0);
}

int
strcmpEBCDIC(const char *s1, const char *s2)
{
  return strcmpGeneral(s1, s2, asciiToEbcdic);
}

int
strcmpHoneywell(const char *s1, const char *s2)
{
  static char *l1 = NULL, *l2 = NULL;
  int len = -1, n, n1, n2;
  // YUL seems to right-pad labels with spaces, thus making labels like
  // "0.00125" come earlier in the collation sequence than "0.0012".  So
  // we have to right-pad the input strings when it's necessary to make
  // them come out the same length.
  n = len;
  n1 = strlen(s1);
  n2 = strlen(s2);
  if (n1 > n)
    n = n1;
  if (n2 > n)
    n = n2;
  if (n > len)
    {
      l1 = realloc(l1, n + 1);
      l2 = realloc(l2, n + 1);
      len = n;
    }
  sprintf(l1, "%-*s", len, s1);
  sprintf(l2, "%-*s", len, s2);
  return strcmpGeneral(l1, l2, asciiToHoneywell);
}

#ifdef MAIN_STRCMPEBCDIC

int
main (int argc, char *argv[])
  {
    char line1[1024], line2[1024];
    while (1)
      {
        printf("String 1> ");
        fgets (line1, sizeof(line1), stdin);
        printf("String 2> ");
        fgets (line2, sizeof(line2), stdin);
        printf ("ASCII:     %d\n", strcmp(line1, line2));
        printf ("EBCDIC:    %d\n", strcmpEBCDIC(line1, line2));
        printf ("Honeywell: %d\n", strcmp(Honeywell(line1, line2)));
      }
  }
#endif
