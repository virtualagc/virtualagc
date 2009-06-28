/*
  Copyright 2003-2005,2009 Ronald S. Burkey <info@sandroid.org>
  
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

  Filename:	yaYUL.c
  Purpose:	This is an assembler for Apollo Guidance Computer (AGC)
  		assembly language.  It is called yaYUL because the original
		assembler was called YUL, and this "yet another YUL".
  Contact:	Ron Burkey <info@sandroid.org>
  Website:	www.ibiblio.org/apollo/index.html
  Mode:		04/11/03 RSB.	Began.
  		07/03/04 RSB.	Now writes the binary file, but does not
				yet compute the bugger words.  This is
				principally useful as a temporary measure
				to allow me to assemble Validation.s, 
				which doesn't use the bugger words.
		07/04/04 RSB	Now returns non-zero if there are fatal
				errors in assembly.
		07/07/04 RSB	Added the predefined symbol "$7".
		07/26/04 RSB	Added --force.
		07/30/04 RSB	Added terminating bugger words to banks.
		08/12/04 RSB	Added NVER.
		05/14/05 RSB	Corrected website reference.
		07/27/05 JMS	(04/30/05) Write symbol table to binary file 
				with --g flag.
		07/28/05 RSB	Made --g the default.  Still accepts the
				--g switch, but it doesn't do anything.
		07/28/05 JMS    Added support for writing SymbolLines_to to symbol
		                table file.
		03/17/09 RSB	Make sure there's no .bin file produced on error.
		06/06/09 RSB	Corrected the address offsets printed in the 
				bugger word table.  (Was printing addresses like
				33,1777 rather than 33,3777.)
		06/27/09 RSB	Added some stuff for HtmlOut.  Don't know yet if
				it will actually go anywhere, or if I'm just
				messing around.	
*/

#define ORIGINAL_YAYUL_C
#include "yaYUL.h"
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <stdint.h>

//#define VERSION(x) #x

//-------------------------------------------------------------------------
// Some global data.

int Force = 0;
char *InputFilename = NULL, *OutputFilename = NULL;
//FILE *InputFile = NULL;
FILE *OutputFile = NULL;

#if 0
static Address_t RegA = REG(00);
static Address_t RegL = REG(01);
static Address_t RegQ = REG(02);
#endif
static Address_t RegEB = REG(03);
static Address_t RegFB = REG(04);
static Address_t RegZ = REG(05);
static Address_t RegBB = REG(06);
static Address_t RegZeroes = REG (07);
#if 0
static Address_t RegARUPT = REG(010);
static Address_t RegLRUPT = REG(011);
static Address_t RegQRUPT = REG(012);
// Registers 013 and 014 are reserved.
static Address_t RegZRUPT = REG(015);
static Address_t RegBBRUPT = REG(016);
#endif
static Address_t RegBRUPT = REG(017);
#if 0
static Address_t RegCYR = REG(020);
static Address_t RegSR = REG(021);
static Address_t RegCYL = REG(022);
static Address_t RegEDOP = REG(023);
#endif

//-------------------------------------------------------------------------
// The following two utility functions are used in computing the bank
// checksums, and were simply copied from Oct2Bin.c.

// Convert an AGC-format signed integer to native format.
static int
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
int
Add (int n1, int n2)
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
  //if (Sum > 16383 || Sum < -16383)
  //  printf ("Arithmetic overflow.\n");
  // Convert back to 1's-complement and return.
  if (Sum >= 0)
    return (Sum);
  return (077777 & ~(-Sum)); 
}

//-------------------------------------------------------------------------
// The main program.

int 
main (int argc, char *argv[])
{
  int MaxPasses = 10;
  int RetVal = 1, i, j, k, LastUnresolved, Fatals, Warnings;
  
  // JMS: OutputSymbols = 1 to output a symbol table to SymbolFile.
  // RSB: Jordan made this an option, but I think it should be the default.
  int OutputSymbols = 1;	// 0;
  char *SymbolFile = NULL;

  printf ("Apollo Guidance Computer (AGC) assembler, version " NVER 
  	  ", built " __DATE__ "\n");
  printf ("(c)2003-2005,2009 Ronald S. Burkey\n");
  printf ("Refer to http://www.ibiblio.org/apollo/index.html for more information.\n");
  
  // Parse the command-line options.
  for (i = 1; i < argc; i++)
    {
      if (!strcmp (argv[i], "--help") || !strcmp (argv[i], "/?"))
        goto Done;
      else if (1 == sscanf (argv[i], "--max-passes=%d", &j))
        MaxPasses = j;	
      else if (!strcmp (argv[i], "--force"))
        Force = 1;	
      else if (!strcmp (argv[i], "--g"))
        OutputSymbols = 1;
      else if (!strcmp (argv[i], "--html"))
        Html = 1;
      else if (*argv[i] == '-' || *argv[i] == '/')
        {
	  printf ("Unknown switch \"%s\".\n", argv[i]);
	  goto Done;
	}	
      else if (InputFilename == NULL)
        {
	  InputFilename = argv[i];
	  OutputFilename = (char *) malloc (5 + strlen (InputFilename));
	  if (OutputFilename == NULL)
	    {
	      printf ("Out of memory (1).\n");
	      goto Done;
	    }
	  sprintf (OutputFilename, "%s.bin", InputFilename);
	  //InputFile = fopen (InputFilename, "r");
	  //if (InputFile == NULL)
	  //  {
	  //    printf ("Input file does not exist.\n");
	  //    goto Done;
	  //  }
	  OutputFile = fopen (OutputFilename, "wb");
	  if (OutputFile == NULL)
	    {
	      printf ("Cannot create output file.\n");
	      goto Done;
	    }

	}
      else
        {
	  printf ("Two input files defined.\n");
	  goto Done;
	}	
    }
  if (InputFilename == NULL || OutputFile == NULL)
    goto Done;  
  if (Html)
    {
      if (HtmlCreate (InputFilename))
	goto Done;
    }
    
  // Perform a preliminary pass, whose sole purpose is to identfy
  // all symbols defined in the program.
  SymbolPass (InputFilename);
  // Also, define all register names.
  // ... Later:  It turns out that the Luminary or Colossus source code
  // defines any registers it needs, so this step isn't required.
#if 0
  AddSymbol ("A");
  AddSymbol ("L");
  AddSymbol ("Q");
  AddSymbol ("EB");
  AddSymbol ("FB");
  AddSymbol ("Z");
  AddSymbol ("BB");
  AddSymbol ("ARUPT");
  AddSymbol ("LRUPT");
  AddSymbol ("QRUPT");
  AddSymbol ("ZRUPT");
  AddSymbol ("BBRUPT");
  AddSymbol ("BRUPT");
  AddSymbol ("CYR");
  AddSymbol ("SR");
  AddSymbol ("CYL");
  AddSymbol ("EDOP");
#endif  
  // I use the following symbols, which I don't allow the source to define.
  AddSymbol ("$3");
  AddSymbol ("$4");
  AddSymbol ("$5");
  AddSymbol ("$6");
  AddSymbol ("$7");
  AddSymbol ("$17");

  // Sort the symbol table, or else we won't be able to locate the 
  // symbols later.
  Fatals += SortSymbols ();  

  // Assign the registers their proper addresses.
#if 0
  EditSymbol ("A", &RegA);
  EditSymbol ("L", &RegL);
  EditSymbol ("Q", &RegQ);
  EditSymbol ("EB", &RegEB);
  EditSymbol ("FB", &RegFB);
  EditSymbol ("Z", &RegZ);
  EditSymbol ("BB", &RegBB);
  EditSymbol ("ARUPT", &RegARUPT);
  EditSymbol ("LRUPT", &RegLRUPT);
  EditSymbol ("QRUPT", &RegQRUPT);
  EditSymbol ("ZRUPT", &RegZRUPT);
  EditSymbol ("BBRUPT", &RegBBRUPT);
  EditSymbol ("BRUPT", &RegBRUPT);
  EditSymbol ("CYR", &RegCYR);
  EditSymbol ("SR", &RegSR);
  EditSymbol ("CYL", &RegCYL);
  EditSymbol ("EDOP", &RegEDOP);
#endif  
  EditSymbol ("$3", &RegEB);
  EditSymbol ("$4", &RegFB);
  EditSymbol ("$5", &RegZ);
  EditSymbol ("$6", &RegBB);
  EditSymbol ("$7", &RegZeroes);
  EditSymbol ("$17", &RegBRUPT);
    
  // Perform all compiler passes. What happens is that we keep 
  // running passes until all defined symbols have known values.  
  // Then we do one final pass to actually generate object code.
  // At the end of each pass we do a check, and if some symbols 
  // are still not resolved, we bump LAST_PASS upward.  I'm sure
  // there's a more mathematically sophisticated way to do this,
  // but it's not worth the effort to figure it out.
  
  LastUnresolved = UnresolvedSymbols ();
  for (i = 1; i <= MaxPasses; i++)
    {
      printf ("Pass #%d\n", i);
      j = Pass (0, InputFilename, OutputFile, &Fatals, &Warnings);
      k = UnresolvedSymbols ();
      if (j == -1)	
	{
	  printf ("Unrecoverable error.\n");
	  break;
	} 
      if (k == 0 || k >= LastUnresolved)
        {
	  printf ("Pass #%d\n", i + 1);
	  Pass (1, InputFilename, OutputFile, &Fatals, &Warnings);
	  break;
	}
      LastUnresolved = k;
      //PrintSymbols ();	
    }  
    
  // Print the symbol table.
  printf ("\n\n");
  PrintBankCounts ();
  printf ("\n\n");
  PrintSymbols (); 
  printf ("\nUnresolved symbols:  %d\n", UnresolvedSymbols ());
  printf ("Fatal errors:  %d\n", Fatals);
  printf ("Warnings:  %d\n", Warnings); 
  if (HtmlOut != NULL)
    {
      fprintf (HtmlOut, "<br>\n");
      fprintf (HtmlOut, "<h1>Assembly Status</h1>\n");
      fprintf (HtmlOut, "Unresolved symbols:  %d<br>\n", UnresolvedSymbols ());
      fprintf (HtmlOut, "Fatal errors:  %d<br>\n", Fatals);
      fprintf (HtmlOut, "Warnings:  %d<br>\n", Warnings); 
      fprintf (HtmlOut, "<br>\n");
      fprintf (HtmlOut, "<h1>Bugger Words</h1>\n");
    }

  // JMS: 07.28
  // We sort the lines by increasing physical address so we can look them
  // up later.
  SortLines (SORT_YUL);

  // JMS: Print the symbol table to a binary file if we want to
  if (OutputSymbols)
    {
      SymbolFile = (char *) malloc (8 + strlen (InputFilename));
      if (SymbolFile == NULL)
	{
	  printf ("Out of memory (2).\n");
	  goto Done;
	}
      sprintf (SymbolFile, "%s.symtab", InputFilename);
      WriteSymbolsToFile (SymbolFile);
    }

  // Output the executable object code.
  if (Fatals == 0 || Force)
    {
      int BankRaw, Bank, Offset, Value;
      uint16_t Bugger, GuessBugger;
      printf ("\n");
      for (BankRaw = 0; BankRaw < 044; BankRaw++)
        {
	  // Compute the actual bank number.
	  Bank = BankRaw;
	  if (Bank < 4)			// flip-flop 0,1 with 2,3.
	    Bank ^= 2;
	  // Add bugger info to the bank.
	  if (Bank == 2)
	    Offset = 04000;
	  else if (Bank == 3)
	    Offset = 06000;
	  else
	    Offset = 02000;
	  Value = GetBankCount (Bank);
	  if (Value < 01776)
	    {
	      ObjectCode[Bank][Value] = Value + Offset;
	      Value++;
	    }
	  if (Value < 01777)
	    {
	      ObjectCode[Bank][Value] = Value + Offset;
	      Value++;
	    }
	  if (Value < 02000)
	    {
	      for (Bugger = Offset = 0; Offset < Value; Offset++)
		Bugger = Add (Bugger, ObjectCode[Bank][Offset]);
	      if (0 == (040000 & Bugger))
	        GuessBugger = Add (Bank, 077777 & ~Bugger);
	      else
	        GuessBugger = Add (077777 & ~Bank, 077777 & ~Bugger);
	      ObjectCode[Bank][Value] = GuessBugger;
	      printf ("Bugger word %05o at %02o,%04o.\n", GuessBugger, Bank, 02000 + Value);
	      if (HtmlOut != NULL)
	        fprintf (HtmlOut, "Bugger word %05o at %02o,%04o.<br>\n", GuessBugger, Bank, 02000 + Value);
	    } 
	  // Output the binary data.  
	  for (Offset = 0; Offset < 02000; Offset++)
	    {
	      Value = (ObjectCode[Bank][Offset] << 1); 
	      fputc (Value >> 8, OutputFile);
	      fputc (Value, OutputFile);
	    }  
	}
    }
    
  // All done!  
  RetVal = 0;
Done:  
  //if (InputFile != NULL)
  //  fclose (InputFile);
  if (OutputFile != NULL)
    fclose (OutputFile); 
  HtmlClose ();
  if (RetVal)
    {
      printf ("USAGE:\n"
	      "\tyaYUL [OPTIONS] InputFile\n"
	      "The output (binary executable) always has the same name\n"
	      "as the assembly-language input file, except that .bin is \n"
	      "appended to it.  (E.g., Luminary.agc->Luminary.agc.bin.)\n"
	      "No relocatable object-file output format is provided,\n"
	      "because the original development team had no such\n"
	      "capability, and so there is no linker.\n\n"
	      "The assembly listing, including symbol table and any error\n"
	      "messages appear on the standard output.\n\n"
	      "OPTIONS:\n");
      printf ("--help or /?     Display this message.\n"); 
      printf ("--max-passes=n   By default, the assembler makes at most\n"
              "                 %d passes trying to resolve addresses.\n"
	      "                 This switch changes that value.\n", MaxPasses);
      printf ("--force          Force creation of core-rope image. (By\n"
              "                 default, the core-rope is not created if\n"
	      "                 there were fatal errors during assembly.\n"); 
      //printf ("--g              Output the binary symbol table to the file\n"
      //        "                 InputFile.symtab\n");
      printf ("--html=F         (This is just experimental and may not do\n"
      	      "                 anything useful yet.)  Causes an HTML file\n"
	      "                 (F) to be created, which is the same as the\n"
	      "                 output listing except that it has syntax\n"
	      "                 highlighting and hyperlinks from where each\n"
	      "                 symbol is used back to where it was defined.\n");
    }   
  if (RetVal || Fatals)
    remove (OutputFilename);
  if (RetVal == 0)
    return (Fatals);
  else    
    return (RetVal);
}

  

