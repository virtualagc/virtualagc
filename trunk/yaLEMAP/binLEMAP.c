/*
  Copyright 2005 Ronald S. Burkey <info@sandroid.org>

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

  Filename:	binLEMAP.c
  Purpose:	Accepts octal data from an ASCII file in a format
  		that is natural for data taken from an AGS (LEMAP)
		assembly listing, and converts it into a binary
		format suitable for use with the yaAGS AGS CPU
		emulator.  The main purpose, aside from quickly
		preparing binaries from LEMAP assembly listings
		is to prepare binaries that can be used to verify
		yaLEMAP operation and AGS flight-program source code.
  Compiler:	GNU gcc.
  Reference:	http://www.ibibio.org/apollo
  Mode:		2005-01-10 RSB.	Began.
  		2005-01-19 RSB	Eliminate all appearances of the 
				character 'p' (which is sometimes
				added to fool iMac's text-to-speech
				into saying the numbers correctly).

  The format of the input file is as follows:
  
  1.  Anything following a '#' char is discarded.
  2.  Blank lines (after comment removal) are discarded.
  3.  Non-blank lines have one of the following formats:
	ORG OctalNum
	OctalNum
	OctalNum OctalNum OctalNum
	
  The line-format containing 3 octal numbers produces a
  single output number that is produced by shifting and
  logical-ORring the 3 numbers as if the first number is an
  opcode, the second is an index bit, and the third is an
  address.
  
  Note that the checksum, if known, should be placed at
  address 07777.
  
  The output file simply contains the binary values, 32
  bits for each location from 0 to 07777, in little-endian
  format.  Only the least-significant 18 bits are used, 
  and the upper 14 bits of each value are zero. The format
  is chosen to be easy for lazy users on little-endian
  CPUs like the Intel Pentium, but binLEMAT itself works
  on big-endian CPUs as well, and is platform-independent.

  The output file is always called binLEMAP.bin.
*/

#include <stdio.h>
#include <string.h>
#include <ctype.h>

#define MEMSIZE 010000
static int Memory[MEMSIZE], Valid[MEMSIZE];
static char s[1000], sd[1000];

int
main (void)
{
  int i, i1, i2, i3, RetVal = 0, Lines = 0;
  int Location = 0, Checksum;
  char *ss;
  FILE *fp;

  // Process the input file.
  while (NULL != fgets (s, sizeof (s) - 1, stdin))
    {
      Lines++;
      // Eliminate the newline.
      for (ss = s; *ss; ss++)
	if (*ss == '\n')
	  {
	    *ss = 0;
	    break;
	  }
	else
	  *ss = toupper (*ss);
      // Eliminate comments.
      ss = strstr (s, "#");
      if (ss != NULL)
	*ss = 0;
	
      // Turn 'p' in to a space.
      for (ss = s; *ss; ss++)
        if (*ss == 'p')
	  *ss = ' ';

      if (1 == sscanf (s, "ORG%o%s", &i, sd))
	Location = i;
      else
	{
	  i = sscanf (s, "%o%o%o%s", &i1, &i2, &i3, sd);
	  switch (i)
	    {
	    case -1:
	    case 0:
	      if (0 != (i = sscanf (s, "%s", sd)) && -1 != i)
		{
		  RetVal++;
		  fprintf (stderr, "%d: Unrecognized line: %s\n", Lines, s);
		}
	      break;
	    case 1:
	    BufferIt:
	      if (Location < 0 || Location >= MEMSIZE)
		{
		  RetVal++;
		  fprintf (stderr, "%d: Location Counter out of range.\n",
			   Lines);
		}
	      else
		{
		  if (i1 < 0 || i1 > 0777777)
		    {
		      RetVal++;
		      fprintf (stderr, "%d: Octal value %o out of range.\n",
			       Lines, i1);
		      i1 &= 0777777;
		    }
		  if (Valid[Location])
		    {
		      RetVal++;
		      fprintf (stderr, "%d: Overwriting address 0%04o.\n",
			       Lines, Location);
		    }
		  Memory[Location] = i1;
		  Valid[Location] = 1;
		  Location++;
		}
	      break;
	    case 2:
	      RetVal++;
	      fprintf (stderr, "%d: Wrong number of values.\n", Lines);
	      break;
	    case 3:
	      if (i1 < 0 || i1 > 077 || 0 != (i1 & 1))
		{
		  RetVal++;
		  fprintf (stderr, "%d: Illegal opcode %o.\n", Lines, i1);
		}
	      if (i2 != 0 && i2 != 1)
		{
		  RetVal++;
		  fprintf (stderr, "%d: Illegal index bit %o.\n", Lines, i2);
		}
	      if (i3 < 0 || i3 >= MEMSIZE)
		{
		  RetVal++;
		  fprintf (stderr, "%d: Illegal address %o.\n", Lines, i3);
		}
	      i1 = (((i1 | i2) << 12) | i3);
	      goto BufferIt;
	    default:
	      RetVal++;
	      fprintf (stderr, "%d: Unrecognized line: %s\n", Lines, s);
	      break;
	    }
	}
    }

  // Compute Checksum, and store at the last address in memory.
  // (Or compare it to the value that is already there.
  for (i = 04000, Checksum = 0; i < MEMSIZE - 1; Checksum += Memory[i++]);
  Checksum = (0777777 & -Checksum);
  if (Valid[MEMSIZE - 1] && Memory[MEMSIZE - 1] != Checksum)
    {
      RetVal++;
      fprintf (stderr, "Checksum mismatch, computed=%o, embedded=%o.\n",
	       Checksum, Memory[MEMSIZE - 1]);
    }
  else
    {
      Memory[MEMSIZE - 1] = Checksum;
      Valid[MEMSIZE - 1] = 1;
    }

  // Output the binary
  fp = fopen ("binLEMAP.bin", "wb");
  if (fp == NULL)
    {
      RetVal++;
      fprintf (stderr, "Cannot create output file.\n");
    }
  else
    {
      for (i = 0; i < MEMSIZE; i++)
	{
	  fputc (0xFF & Memory[i], fp);
	  fputc (0xFF & (Memory[i] >> 8), fp);
	  fputc (0x03 & (Memory[i] >> 16), fp);
	  fputc (0, fp);
	}
      fclose (fp);
    }

  // All done!
  if (RetVal == 0)
    fprintf (stderr, "Successful!\n");
  else
    fprintf (stderr, "%d total errors.\n", RetVal);
  return (RetVal);

}
