/*
  Copyright 2003-2005 Ronald S. Burkey <info@sandroid.org>
  
  This file is part of yaAGC. 

  yaAGC is free software; you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation; either version 2 of the License, or
  (at your option) any later version.

  yaAGC is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with yaAGC; if not, write to the Free Software
  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

  Filename:	CheckDec.c
  Purpose:	This is a small utility program, mainly for checking to
  		see how DEC or 2DEC constants are converted to octal
		by yaYUL.
  Mode:		11/02/03 RSB	Added the GPL header.
  		05/09/04 RSB	Converted from a simple main program to 
				a function and an optional main program.
				This allows me to call the function 
				from within yaAGC.
		06/13/04 RSB	Corrected the sign of the parenthesized
				getoct value.
		05/14/05 RSB	Corrected website reference.
*/

#include <stdio.h>
#include <stdlib.h>
#include <math.h>

// ----------------------------------------------------------------------
// Prints a line-feed terminated conversion to octal from one of the 
// following formats:
//	%o %o * E%d B%d
//	%o %o
//	%s / %s		(%s hex or floating-point decimal)
//	%s * %s
//	%s

void
CheckDec (char *s)
{
  char s1[133], s2[133], SignC;
  double x, xx, scalar;
  int Value;
  int i, n2, n10;
  int Sign;
  int Oct1, Oct2;
  
  if (4 == (i = sscanf (s, "%o %o * E%d B%d", &Oct1, &Oct2, &n10, &n2)))
    {
      scalar = pow (2.0, n2) * pow (10.0, n10);
      goto Oct2Dec;
    }
  if (2 == (i = sscanf (s, "%o %o", &Oct1, &Oct2)))
    {
      printf ("%05o %05o -> ", Oct1, Oct2);
      scalar = 1;
    Oct2Dec:
      if (0 != (040000 & Oct1))
	{
	  Oct1 = ~Oct1;
	  Oct2 = ~Oct2;
	  Sign = -1;
	  SignC = '-';
	}
      else
        {
	  Sign = 1;
	  SignC = '+';
	}
      i = ((Oct1 & 037777) << 14) | (Oct2 & 037777);
      scalar *= pow (2.0, -28);
      x = Sign * scalar * i;
      printf ("(%c%010o) %.10g\n", SignC, i, x);
      return;
    }
  if (2 == (i = sscanf (s, "%s / %s", s1, s2)))
    {
      xx = strtod (s1, NULL);
      scalar = strtod (s2, NULL);
      x = xx / scalar;
    }
  else
    {
      if (1 == (i = sscanf (s, "%s * %s", s1, s2)))
	scalar = 1.0;
      else if (i == 2)
	scalar = strtod (s2, NULL);
      else
        {
	  printf ("?\n");
	  return;
	}
      xx = strtod (s1, NULL);
      x = xx * scalar;
    }
  Sign = 0;
  if (x < 0)
    {
      Sign = 1;
      x = -x;
    }
  if (x >= 1.0)
    {
      printf ("Illegal value: Must be <1.0 according to AGC rules.\n");
      return;
    }
  for (Value = 0, i = 0; i < 28; i++)
    {
      Value = Value << 1;
      if (x >= 0.5)
	{
	  Value++;
	  x -= 0.5;
	}
      x *= 2;
    }
  if (x >= 0.5)
    Value++;
  i = Value & 0x00003fff;
  Value = (Value >> 14) & 0x00003fff;
  if (Sign)
    {
      Value = ~Value;
      i = ~i;
      i &= 0x00007fff;
      Value &= 0x00007fff;
    }
  printf ("%05o %05o\n", Value, i);
  
}

#ifdef MAIN_PROGRAM

int
main (void)
{
  char s[133];
  
  printf ("(c)2003-2005 Ronald S. Burkey\n");
  printf ("Refer to http://www.ibiblio.org/apollo/index.html for more information.\n");
  printf ("\n");
  printf ("This program is interactive.  The main purpose is to enter DEC or 2DEC\n");
  printf ("constants to see how yaYUL would convert them to octal in the core-rope\n");
  printf ("image file, however some other formats are accepted as well.  This is\n");
  printf ("useful when working with corrupted assembly listings of AGC code.\n");
  printf ("Enter one of the following:\n");
  printf ("\tCtrl-C to exit.\n");
  printf ("\toctal octal * Edecimal Bdecimal\n");
  printf ("\toctal octal\n");
  printf ("\tdecimal\n");
  printf ("\tdecimal / decimal\n");
  printf ("\tdecimal * decimal\n"); 
  printf ("Decimal numbers can include a sign and decimal point, octals cannot.\n");
  printf ("The output is two 5-octal-digit numbers, the more-signficant being first.\n");
  
  for (;;)
    {
      printf ("> ");
      s[sizeof (s) - 1] = 0;
      fgets (s, sizeof (s) - 1, stdin);
      CheckDec (s);
    }
}

#endif //MAIN_PROGRAM


