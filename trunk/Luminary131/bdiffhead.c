/*
  Copyright 2004 Ronald S. Burkey <info@sandroid.org>
  
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

  Filename:	bdiffhead.c
  Purpose:	For the purpose of debugging yaYUL and the Luminary source
  		code, I need some way to do meaningful binary comparisons
		of two core-rope files and getting some meaningful list
		of their differences.  (The 'diff' utility can tell me that
		the files are identical or different, but does not tell
		me HOW they differ, as far as I can determine.  The 'xdelta'
		utility goes much farther but, again, rather than telling me
		in some simple why what's different, it gives me back an 
		unreadable patch-file. The DOS/Win32 utility fc does what
		I want, more or less, but I don't want to fire up Win32 just
		for this purpose.)
  Mode:		07/26/04 RSB	Wrote.

  The idea is simple.  We just do a word-by-word compare until we run out of
  data, and print messages where the words differ.  Originally I intended to
  limit this to just the first N (configurable) lines of output, but now I
  just do the complete files and feed the results into 'head' if I don't want
  to see the whole thing.
  
  Since this is tailored to core-rope comparisons, the data consists of 16-bit
  words and the messages use core-rope addresses rather than absolute offsets
  into the file.  
*/

#include <stdio.h>
#include <string.h>
#define CORE_LENGTH (2 * 044 * 02000)

int
main (int argc, char *argv[])
{
  FILE *f1, *f2;
  int n1, n2, i, NoSuper = 0, NoZero = 0, OnlySuper = 0;
  unsigned char d1[2], d2[2];
  
  // Parse command-line arguments.
  if (argc < 3)
    {
      printf ("USAGE:\n"
              "\tbdiffhead AgcCoreFilename1 AgcCoreFilename2 [OPTIONS]\n"
	      "A binary-compare of two files is performed, and a list of all\n"
	      "differences is printed.  The files are supposed to represent\n"
	      "AGC (Apollo Guidance Computer) core-ropes, consisting of 16-bit\n"
	      "words. The output messages use the AGC addressing scheme.\n"
	      "The available options are:\n"
	      "--no-super     This option discards differences in which one\n"
	      "               word has 100 (binary) in bit-positions 5,6,7\n"
	      "               (the least-significant bit being position 1)\n"
	      "               and 011 in the other word.\n"
	      "--only-super   The opposite of the --no-super option.  Shows\n"
	      "               ONLY differences involving 100 vs. 011 in \n"
	      "               bits 5,6,7.\n"
	      "--no-zero      This option discards differences in which the\n"
	      "               word from the 2nd file is 00000.\n");
      return (1);
    }
  f1 = fopen (argv[1], "rb");
  if (f1 == NULL)
    {
      printf ("Could not open file \"%s\".\n", argv[1]);
      return (1);
    }
  f2 = fopen (argv[2], "rb");
  if (f2 == NULL)
    {
      fclose (f1);
      printf ("Could not open file \"%s\".\n", argv[2]);
      return (2);
    }
  for (n1 = 3; n1 < argc; n1++)
    {
      if (!strcmp (argv[n1], "--no-super"))
        NoSuper = 1;
      if (!strcmp (argv[n1], "--only-super"))
        OnlySuper = 1;
      else if (!strcmp (argv[n1], "--no-zero"))
        NoZero = 1;
      else
        printf ("Unrecognized option \"%s\".\n", argv[n1]);
    }  
    
  // See if the files are the same length. 
  fseek (f1, 0, SEEK_END);
  fseek (f2, 0, SEEK_END);
  n1 = ftell (f1);
  n2 = ftell (f2);
  rewind (f1);
  rewind (f2);
  if (n1 != CORE_LENGTH || n2 != CORE_LENGTH)
    printf ("Improper file(s):  size of core-rope files should be %d.\n", CORE_LENGTH);
    
  // Now compare!
  while (1 == fread (d1, 2, 1, f1) && 1 == fread (d2, 2, 1, f2))
    if (d1[0] != d2[0] || d1[1] != d2[1])
      {
        int Bank, Offset;
	n1 = (d1[0] << 7) | (d1[1] >> 1);
	n2 = (d2[0] << 7) | (d2[1] >> 1);
	if (NoZero && n2 == 0)
	  continue;
	if (0160 == (0160 & (n1 ^ n2)) &&
	    (0100 == (0160 & n1) || 0060 == (0160 & n1)) )
	  {
	    if (NoSuper)
	      continue;
	  }
	else
	  {
	    if (OnlySuper)
	      continue;
	  }
        i = (ftell (f1) - 2) / 2;
	Offset = 02000 + (i % 02000);
	Bank = i / 02000;
	if (Bank < 4)
	  Bank ^= 2;			// Swap banks 0,1 and 2,3.
	printf ("0%06o (%02o,%04o", i, Bank, Offset);
	if (i < 04000)
	  printf (" or %04o): ", i + 04000);
	else
	  printf ("):         ");  
	printf ("%05o %05o\n", n1, n2);
      }
    
  // All done! 
  return (0);
}


