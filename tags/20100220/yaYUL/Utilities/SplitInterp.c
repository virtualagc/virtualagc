/*
  Copyright 2009 Ronald S. Burkey <info@sandroid.org>
  
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

  Filename:	SplitInterp.c
  Purpose:	This is a little utility that takes a 15-bit word from an
  		AGC binary executable and splits it apart to see what 
		interpretive codes it might have included.  I am using this
		solely for reverse engineering Block 1 interpretive language.
		(I must have done something similar for Block 2, but don't 
		know what it was.)
  Contact:	Ron Burkey <info@sandroid.org>
  Website:	www.ibiblio.org/apollo
  Mode:		2009-07-26 RSB	Began.
*/

#include <stdio.h>
#include <string.h>

int
main (int argc, char *argv[])
{
  int i, Code, Reverse = 0;
  
  for (i = 1; i < argc; i++)
    {
      if (!strcmp (argv[i], "--reverse"))
        Reverse = 1;
    }
  
  while (1)
    {
      printf ("Enter an octal code: ");
      if (1 == scanf ("%o", &Code))
	{
	  Code = ~Code;
	  if (Reverse)
	    {
	      printf ("Index=%d CODE1=%03o CODE2=%03o\n",
		      1 & (Code >> 14),
		      (127 & (Code >> 7)) - 1,
		      (127 & (Code)) - 1);
  	    }
	  else
	    {
	      printf ("Index=%d CODE1=%03o CODE2=%03o\n",
		      1 & (Code >> 14),
		      (127 & (Code)) - 1,
		      (127 & (Code >> 7)) - 1);
	    }
	  printf ("Index=%d CODE=%02o VALUE=%04o\n",
	  	  1 & (Code >> 14),
		  (15 & (Code >> 10)),
		  (0x3FF & Code) - 1);
	}
    }
}

