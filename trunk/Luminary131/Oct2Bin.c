/*
  Copyright 2003-2006,2009 Ronald S. Burkey <info@sandroid.org>
  
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

  Filename:	Oct2Bin.c
  Purpose:	For the purpose of validating yaYUL, Luminary131, and 
  		Colossus249 the binary from the Luminary131 and Colussus249
		source-code listings is checked against the yaYUL-produced
		binary produced from the source-code in those listings.
		This checking is most-easily done by the computer, which
		implies that the Luminary/Colossus source AND the
		Luminary/Colossus binary must separately be entered into
		the computer.  (Of course, once the binaries are entered
		they can also be used directly with yaAGC, whether or not
		yaYUL or the Luminary/Colossus sources are correct.)
		But entering binary data directly into the computer is not
		very convenient (particularly when it is originally listed
		in octal 15-bit format), so an intermediate ASCII format
		is used.  Then, a program (namely this one, Oct2Bin) is used
		to convert the intermediate file to binary.
  Contact:	Ron Burkey <info@sandroid.org>
  Website:	http://www.ibiblio.org/apollo/index.html
  Mode:		08/24/03 RSB	Began.
  		08/31/03 RSB	Added some additional checks for the kind of
				garbage produced by OCR.
		09/07/03 RSB	Made error messages a little cleaner.
		08/12/04 RSB	Added NVER.
		04/30/05 RSB	Unused variable removed.
		05/14/05 RSB	Corrected website references
		01/02/06 RSB	Now allow commas to appear as delimiters.
				This is done because I find it convenient
				when entering data using Dragon 
				NaturallySpeaking 8.
		05/20/09 RSB	Added the --invert command-line switch.
				With this switch, the program reverses the
				normal process, taking a binary file and
				turning it into a textual file.  Such a
				file is helpful in proofing when converting
				a set of page images to source-code files,
				since when you assemble the source-code files
				so-created the result usually won't be what
				it's supposed to, and at some point you have
				to compare the binary created by yaYUL against
				the binary in the page images.  Also added
				the --page switch.
		11/22/10 RSB    Added the CHECKWORDS=Count variable to
                                supplement the existing BANK=BankNumber
                                variable.  CHECKWORDS is the number of words
                                participating in the checksum, including the
                                bugger word.  It defaults to 02000, which is
                                the number of words in a bank.  This is
                                normally okay, since any unuused words
                                following the bugger word are zero.  But with
                                Solarium 055, some banks have data stored
                                *after* the bugger word, and shouldn't
                                participate in the checksum.  The CHECKWORDS
                                variable is used when necessary to compensate
                                for that funky fact.  It must *follow* the
                                BANK variable when it's used.  Also, I added the
                                NUMBANKS variable, which should precede any
                                bank and give the total number of banks.
                                Defaults to 044.  Both of the new variables
                                are in octal.
  
  The format of the file is simple.  Each line just consists of 8 fields,
  delimited by whitespace.  Each field consists of 5 octal digits.  Blank
  lines and lines beginning with ';' are ignored.
  
  The checksum of any given bank is equal to the sum of all of the words
  in the bank, including the so-called "bugger" word, which follows all of the
  valid data.  The sum is supposed to be equal to the bank number.  Filler
  words of 0 should be added after the bugger word, so that the banks never
  end prematurely
  
  Oct2Bin internally attempts to compute the checksum, thus providing an
  additional check on the data.  To account for this, the data for each bank 
  should be followed immediately by a line that reads
  	BANK=BankNumber
  
  The input is on the standard input.  Status messages are on the standard
  output.  The binary is put into a file called Oct2Bin.bin.
  
  If the command-line switch --invert is used, then the input should be a binary
  file called Oct2Bin.bin, and the output will be a text file named Oct2Bin.binsource.
  When --invert is used, the switch --page=N can be used to select a starting page
  number for the binary listing, so as to create something that corresponds to the
  set of page images.
*/

//#define VERSION(x) #x

#include <stdio.h>
#include <ctype.h>
#include <stdint.h>
#include <string.h>
uint16_t Checksum = 0;
int ErrorCount = 0;
int NumBanks = 044;

// Convert an AGC-format signed integer to native format.
int
AgcToNative (uint16_t n)
{
  int i;
  i = n;
  if (0 != (n & 040000))
    i = -(077777 & ~i);
  return (i);
}

// This function takes two signed integers in AGC format, adds them, and returns
// the sum (also in AGC format).  If there's overflow or underflow, the 
// carry is added in also.  This is done because that's the goofy way the
// AGC checksum is created.
uint16_t
Add (uint16_t n1, uint16_t n2)
{
  int i1, i2, Sum;
  // Convert from AGC 1's-complement format to the native integer format of this CPU.
  i1 = AgcToNative (n1);
  i2 = AgcToNative (n2);
  // Add 'em up.
  Sum = i1 + i2;
  // Account for carry or underflow.
  if (Sum > 16383)
    {
      Sum -= 16384;
      Sum++;
    }
  else if (Sum < -16383)
    {
      Sum += 16384;
      Sum--;
    }  
  // The following condition can't occur, but I'll check for it anyway.
  if (Sum > 16383 || Sum < -16383)
    printf ("Arithmetic overflow.\n");
  // Convert back to 1's-complement and return.
  if (Sum >= 0)
    return (Sum);
  return (077777 & ~(-Sum)); 
}

void
BuggerCheck (int Line, int BuggerChecked, uint16_t Banknum, uint16_t Checksum)
{
    if (!BuggerChecked) 
    {
        if (Checksum == Banknum) 
        {
            //printf("FYI: Bugger word for bank %o is a match (positive).\n", Banknum);
        } 
        else if (Checksum == (077777 & ~Banknum)) 
        {
            //printf("FYI: Bugger word for bank %o is a match (negative).\n", Banknum);
        } 
        else 
        {
            ErrorCount++;
            printf("Error: Line %d: Bugger word for bank %o does not match (computed=%05o,%05o).\n", 
                   Line, Banknum, Checksum, 077777 & ~Checksum);
        }
    }	    
}

int 
Bank (int Count)
{
  int Ret;
  Ret = Count / 1024;
  if (Ret < 2)
    Ret += 2;
  else if (Ret < 4)
    Ret -= 2;
  return (Ret);
}

// Decompile a binary file to text.  We don't bother to check the bugger codes.

int
Decompile (int Page)
{
  unsigned char b[2];
  int Value, Count = 0;
  FILE *fin, *fout;
  
#ifdef WIN32
  fin = fopen ("Oct2Bin.bin", "rb");
#else
  fin = fopen ("Oct2Bin.bin", "r");
#endif
  if (fin == NULL)
    {
      printf ("Error: input file Oct2Bin.bin does not exist.\n");
      return (1);
    }
  fout = fopen ("Oct2Bin.binsource", "w");
  if (fout == NULL)
    {
      fclose (fin);
      printf ("Error: cannot create output file Oct2Bin.binsource.\n");
      return (1);
    }
    
  // Write a template file header that can be manually edited later.
  fprintf (fout, "; Copyright:\tPublic domain\n");
  fprintf (fout, "; Filename:\tXXXX.binsource\n");
  fprintf (fout, "; Purpose:\tXXXX\n");
  fprintf (fout, "; Contact:\tinfo@sandroid.org\n");
  fprintf (fout, "; Mods:\t\tXXXX-XX-XX XXX\tAuto-generated by Oct2Bin.\n");
  fprintf (fout, ";\t\tXXXX-XX-XX XXX\tXXXX\n");
    
  // Read and write data.
  while (1 == fread (b, 2, 1, fin))
    {
      Value = (b[0] << 7) | (b[1] >> 1);
      if (0 == (Count % 8))
        fprintf (fout, "\n");
      if (0 == (Count % 32))
        fprintf (fout, "\n");
      if (0 == (Count % 256))
        {
	  char PageString[33], BankString[33];
	  if (Page <= 0)
	    PageString[0] = 0;
	  else
	    sprintf (PageString, " p. %d,", Page++);
	  if (Count < 2048)
	    sprintf (BankString, " %o", 04000 + Count);
	  else 
	    sprintf (BankString, " %02o,%04o", Bank (Count), 02000 + (Count % 1024));
          fprintf (fout, ";%s%s\n\n", PageString, BankString);
	}
      if (0 == (Count % 1024))
        fprintf (fout, "BANK=%o\n\n", Bank (Count));
      fprintf (fout, "%05o ", Value);
      Count++;
    }
  
  fclose (fin);
  fclose (fout);
  return (0);
}

int
main (int argc, char *argv[])
{
  FILE *OutFile;
  int Dummy, Data[8], Line, BuggerChecked = 1;
  uint16_t Dummy16, Banknum;
  int Count, CheckWords = 0;
  char s[129], *ss;
  int i, j, Invert = 0, Page = 0;
  
  printf ("(c)2003-2005,2010 Ronald S. Burkey, ver " NVER
          ", built " __DATE__ "\n");
  printf ("Refer to http://www.ibiblio.org/apollo/index.html for more information.\n");
  
  // Parse the command-line switches.
  for (i = 1; i < argc; i++)
    {
      if (!strcmp (argv[i], "--invert"))
        Invert = 1;
      else if (1 == sscanf (argv[i], "--page=%d", &j))
        Page = j;
      else
        {
	  printf ("Error: Unknown command-line switch \"%s\"\n", argv[i]);
	  return (1);
	}
    }
  
  if (Invert)
    return (Decompile (Page));
  
  OutFile = fopen ("Oct2Bin.bin", "wb");
  if (OutFile == NULL)
    {
      ErrorCount++;
      printf ("Error: Cannot create the output file Oct2Bin.bin.\n");
      return (1);
    }
  s[sizeof (s) - 1] = 0;
  Line = 0;
  while (NULL != fgets (s, sizeof (s) - 1, stdin))
    {
      Line++;
      if (s[0] == ';' || s[0] == '\n')
        continue;
      if (1 == sscanf (s, "NUMBANKS=%o", &Dummy))
        {
          NumBanks = Dummy;
          continue;
        }
      if (1 == sscanf (s, "BANK=%o", &Dummy))
        {
	  BuggerCheck (Line, BuggerChecked, Banknum, Checksum);
	  Banknum = Dummy;
	  Checksum = 0;
	  if (0 != (03777 & ftell (OutFile)))
	    {
	      ErrorCount++;
	      printf ("Error: Line %d: Bank %o is not aligned properly.\n", Line, Banknum);
	    }
	  BuggerChecked = 0;  
	  CheckWords = 02000;
	  continue;
	} 
      if (1 == sscanf (s, "CHECKWORDS=%o", &Dummy))
        {
          CheckWords = Dummy;
          if (CheckWords == 0)
            Checksum = Banknum;
          continue;
        }
      if (1 == sscanf (s, "BUGGER=%o", &Dummy))
        {
	  Dummy16 = Dummy;
	  putc (Dummy16 >> 8, OutFile);
	  putc (Dummy16 & 255, OutFile);
	  Checksum = Add (Checksum, Dummy16);
	  BuggerCheck (Line, BuggerChecked, Banknum, Checksum);
	  BuggerChecked = 1;
	  continue;
	} 
	
      // Check for certain garbage conditions.
      for (ss = s; *ss; ss++)
        if (*ss == ',')		// 01/02/06 RSB.  Remove comma delimiters.
	  *ss = ' ';
        else if (!isspace (*ss) && (*ss < '0' || *ss > '7'))
	  {
	    ErrorCount++;
	    printf ("Error: Line %d: Illegal digit \'%c\'.\n", Line, *ss);	  
	  }
      for (ss = s, i = 0; ; i++)	  
        {
	  for (; isspace (*ss); ss++);
	  if (*ss == 0)
	    break;
	  for (j = 0; *ss && !isspace (*ss); ss++, j++);
	  if (j != 5)
	    {
	      ErrorCount++;
	      printf ("Error: Line %d:  Field is not 5-characters wide.\n", Line);
	    }
	}
      if (i > 8)
        {
	  ErrorCount++;
          printf ("Error: Line %d:  Too many fields.\n", Line);	
	}
	  
      // Now, parse like the wind!
      Count = sscanf (s, "%o%o%o%o%o%o%o%o", &Data[0], &Data[1], &Data[2],
      		      &Data[3], &Data[4], &Data[5], &Data[6], &Data[7]);
      for (Dummy = 0; Dummy < Count; Dummy++)
        {
	  // Note that the data is 15-bits which has been input right-aligned
	  // (aligned at bit 0) but must be output left-aligned (aligned at
	  // bit 1).
	  Dummy16 = Data[Dummy];
	  putc (Dummy16 >> 7, OutFile);
	  putc ((Dummy16 << 1) & 255, OutFile);
	  if (CheckWords > 0)
	    {
	      // Normally, CheckWords will always be >=0, unless
	      // CHECKWORDS=something variable assignment was made for
	      // the bank.
	      Checksum = Add (Checksum, Dummy16);
	      CheckWords--;
	    }
	}	 
    }
    
  BuggerCheck (Line, BuggerChecked, Banknum, Checksum);
  if (ftell (OutFile) != 2 * NumBanks * 02000)
    {
      ErrorCount++;
      printf ("Error: The core-rope image is not %o (octal) banks "
              "(2 * 02000 * 0%o bytes) long.\n", NumBanks, NumBanks);
    }
  fclose (OutFile);
  if (!ErrorCount)
    printf ("No errors were detected.\n");
  else
    printf ("There were errors.\n");  
  return (ErrorCount);    
}


