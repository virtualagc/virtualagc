/*
  Copyright 2004,2005 Ronald S. Burkey <info@sandroid.org>
  
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

  Filename:	webb2burkey-rope.c
  Purpose:	A utility program that converts an AGC core-rope
  		from Julian Webb's format to the Virtual AGC
		(Ron Burkey's) format, and vice-versa.
  Contact:	Ron Burkey <info@sandroid.org>
  Website:	www.ibiblio.org/apollo/index.html
  Mod history:	07/16/04 RSB	Began.
  		05/14/05 RSB	Fixed website references.
  
  The point of this utility is that it allows AGC programs assembled with
  Julian Webb's assembler to be run on yaAGC (if prefer my sim to Julian's), 
  and AGC programs assembled with yaYUL to be run on Julian Webb's AGC sim
  (if you prefer Julian's sim to mine).
  
  The format of a yaAGC rope is defined in www.ibiblio.org/apollo/developer.html.
  The format of Webb's rope format is as follows:  The files are ASCII,
  with one line for each memory location.  The lines are arranged in order
  of increasing addresses: i.e., Bank 0 offset 0 is first and Bank 43 (octal)
  offset 1777 (octal) is last.  Each line consists of a comma-separated
  pair of decimal numbers.  The SECOND number is the value stored at the
  location.  The FIRST number represents the address, but is mutated as
  follows:  first the numbers 4096 through 6143 are used, then the numbers
  2048 through 4095 are used, and finally the numbers 8192 through 40959
  are used.  (No, 0-2047 and 6144-8191 are not used.)  
*/

//#define VERSION(x) #x

#include <stdlib.h>
#include <stdio.h>
#include <string.h>

// Data is read into this array, and then it is written out again.
static unsigned Rope[044][02000] = { { 0 } };

int
main (int argc, char *argv[])
{
  int i, j, FromWebb = 0, RetVal = 1;
  char *InFile = NULL, *OutFile = NULL;
  FILE *fin = NULL, *fout = NULL;
  int Bank, Address;
  unsigned Value;
  
  printf ("(c)2004,2005 Ronald S. Burkey, ver " NVER 
          ", built " __DATE__ "\n");
  printf ("Refer to http://www.ibiblio.org/apollo/index.html for more information.\n");
  
  //----------------------------------------------------------------------
  // Parse the command-line.
  for (i = 1; i < argc; i++)
    {
      if (!strcmp (argv[i], "--help") || !strcmp (argv[i], "/?"))
        {
	  printf ("USAGE:\n"
	          "\twebb2burkey-rope [OPTIONS] Infile Outfile\r\n"
		  "By default, the InFile is in Virtual AGC (Burkey)\r\n"
		  "format and the OutFile is in Webb format.  Available\r\n"
		  "OPTIONS are:\r\n"
		  "--help       Display this menu.\r\n"
		  "--from-webb  Convert to Virtual AGC (Burkey) format\r\n"
		  "             from Webb format.\r\n");
	  return (0);
	}
      else if (!strcmp (argv[i], "--from-webb"))
        FromWebb = 1;
      else if (argv[i][0] == '-')
        {
	  printf ("Unknown option \"%s\".\r\n", argv[i]);
	  return (1);
	}
      else if (InFile == NULL)
        InFile = argv[i];
      else if (OutFile == NULL)
        OutFile = argv[i];
      else
        {
	  printf ("Unknown stuff on command line: \"%s\".\r\n", argv[i]);
	  return (1);
	}
    }
  if (OutFile == NULL)
    {
      printf ("Not enough files specified on command line.\r\n");
      return (1);
    }
  if (FromWebb)
    {
      fin = fopen (InFile, "r");
      fout = fopen (OutFile, "wb");
    }
  else
    {
      fin = fopen (InFile, "rb");
      fout = fopen (OutFile, "w");
    }
  if (fin == NULL)
    printf ("Cannot open the input file.\r\n");
  if (fout == NULL)
    printf ("Cannot create the output file.\r\n");
  if (fin == NULL || fout == NULL)
    goto Error;

  //----------------------------------------------------------------------
  // Read the input file.
  if (FromWebb)
    {
      for (i = Bank = Address = 0; i < 36864; i++)
        {
	  if (2 != fscanf (fin, "%d,%u", &j, &Value))
	    {
	      printf ("Corrupted input line or premature end of file.\r\n");
	      goto Error;
	    }
	  Rope[Bank][Address] = Value;
	  Address++;
	  if (Address >= 02000)
	    {
	      Address = 0;
	      Bank++;
	    }
	}
    }
  else
    {
      for (Bank = 2; Bank < 044; )
        {
	  for (Address = 0; Address < 02000; Address++)
	    {
	      int b;
              b = fgetc (fin);
	      if (b == EOF)
	        {
		  printf ("File-read error.\r\n");
		  goto Error;
		}
	      Value = (b << 7) & 077600;
              b = fgetc (fin);
	      if (b == EOF)
	        {
		  printf ("File-read error.\r\n");
		  goto Error;
		}
	      Value |= (b >> 1) & 0177;
	      Rope[Bank][Address] = Value;
	    }
	  // Next bank.
	  if (Bank == 2)
	    Bank = 3;
	  else if (Bank == 3)
	    Bank = 0;
	  else if (Bank == 0)
	    Bank = 1;
	  else if (Bank == 1)
	    Bank = 4;
	  else
	    Bank++;
	}
    }
    
  //----------------------------------------------------------------------
  // Write the output file.
  if (FromWebb)
    {
      for (Bank = 2; Bank < 044; )
        {
	  for (Address = 0; Address < 02000; Address++)
	    {
	      if (EOF == fputc (Rope[Bank][Address] >> 7, fout))
	        {
		  printf ("Write error. (Disk full?)\r\n");
	          goto Error;
		}
	      if (EOF == fputc (Rope[Bank][Address] << 1, fout))
	        {
		  printf ("Write error. (Disk full?)\r\n");
	          goto Error;
		}
	    }
	  // Next bank.
	  if (Bank == 2)
	    Bank = 3;
	  else if (Bank == 3)
	    Bank = 0;
	  else if (Bank == 0)
	    Bank = 1;
	  else if (Bank == 1)
	    Bank = 4;
	  else
	    Bank++;
	}
    }
  else
    {
      for (i = 4096, Bank = 0; Bank < 044; Bank++)
        {
	  for (Address = 0; Address < 02000; Address++)
	    {
	      fprintf (fout, "%d,%u\r\n", i, Rope[Bank][Address]);
	      i++;
	      if (i == 6144)
	        i = 2048;
	      else if (i == 4096)
	        i = 8192;
	    }
	}
    }

  //----------------------------------------------------------------------
  // All done.
  RetVal = 0;
Error:
  if (fin != NULL)
    fclose (fin);
  if (fout != NULL)
    fclose (fout);
  return (RetVal);
}
