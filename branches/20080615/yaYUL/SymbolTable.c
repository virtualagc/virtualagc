/*
  Copyright 2003 Ronald S. Burkey <info@sandroid.org>
  
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

  Filename:	SymbolTable.c
  Purpose:	Stuff for managing the assembler's symbol table.
  Mode:		04/11/03 RSB.	Began.
  		04/17/03 RSB.	Removed Namespaces.
		07/27/05 JMS    Added support for writing the symbol table
                                to a file for symbol debugging purposes.
		07/28/05 JMS    Added support for writing SymbolLines_to to symbol
		                table file.
		08/03/05 JMS    Support for yaLEMAP

  Concerning the concept of a symbol's namespace.  I had originally 
  intended to implement this, and so many functions had a namespace
  parameter.  I've decided to remove the parameters, but there is 
  still the underlying code for it, in case it might be handy in the
  future.
*/

#include "yaYUL.h"
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>

//-------------------------------------------------------------------------
// Some global data.

// On the first pass, the symbols are collected into an unsorted array.  
// At the end of the pass the array is sorted, and duplicates will cause 
// error messages.  The symbol table is initially empty.  Whenever more 
// symbols are defined than the table has room for, its space is enlarged.  
// On the second pass, true values are assigned to the symbols.
Symbol_t *SymbolTable = NULL;
int SymbolTableSize = 0, SymbolTableMax = 0;

//-------------------------------------------------------------------------
// Delete the symbol table.

void
ClearSymbols (void)
{
  if (SymbolTable != NULL)
    free (SymbolTable);
  SymbolTable = NULL;
  SymbolTableSize = SymbolTableMax = 0;  
}

//-------------------------------------------------------------------------
// Add a symbol to the table.  The newly-added symbol always has the value
// ILLEGAL_SYMBOL_VALUE.  Returns 0 on success, or non-zero on fatal
// error.

int
AddSymbol (const char *Name)
{
  char Namespace = 0;
  
  // A sanity clause.
  if (strlen (Name) > MAX_LABEL_LENGTH)
    {
      printf ("Symbol name \"%s\" is too long.\n", Name);
      return (1);
    }
  // If the symbol table is too small, enlarge it.
  if (SymbolTableSize == SymbolTableMax)
    {
      if (SymbolTable==NULL)
        {
	  // This default size comes from the fact that I know there are about
	  // 7100 symbols in the Luminary131 symbol table. There are far fewer
	  // symbols in yaLEMAP, but that is ok since this isn't much memory
	  // anyhow.
	  SymbolTableMax = 10000;
          SymbolTable = (Symbol_t *) calloc (SymbolTableMax, sizeof (Symbol_t));
	}
      else
        {
          SymbolTableMax += 1000;
	  SymbolTable = (Symbol_t *) realloc (SymbolTable, 
					      SymbolTableMax * sizeof (Symbol_t));
	}
      if (SymbolTable == NULL)
        {
	  printf ("Out of memory (3).\n");
	  return (1);
	}
    }
  // Now add the symbol.
  SymbolTable[SymbolTableSize].Namespace = Namespace;
  SymbolTable[SymbolTableSize].Value.Invalid = 1;
  strcpy (SymbolTable[SymbolTableSize].Name, Name);
  SymbolTableSize++;
  return (0); 
}

//-------------------------------------------------------------------------
// JMS: Assign a symbol a new value. Returns 0 on success. This is used for
// backward compatability to avoid changing lots of exsiting code. Sets the
// new debugging parameters to their default values.
int
EditSymbol (const char *Name, Address_t *Value)
{
  return EditSymbolNew (Name, Value, SYMBOL_REGISTER, "", 0);
}

//-------------------------------------------------------------------------
// Compare two symbol-table entries, for comparison purposes.  Both the
// Namespace and Name fields are used.

static
int CompareSymbolName (const void *Raw1, const void *Raw2)
{
#define Element1 ((Symbol_t *) Raw1)
#define Element2 ((Symbol_t *) Raw2)
  if (Element1->Namespace < Element2->Namespace)
    return (-1);
  if (Element1->Namespace > Element2->Namespace)
    return (1);
  return (strcmp (Element1->Name, Element2->Name));    
#undef Element1
#undef Element2
}

//-------------------------------------------------------------------------
// Sort the symbol table.  Returns the number of duplicated symbols.

int
SortSymbols (void)
{
  int i, j, ErrorCount = 0;
  qsort (SymbolTable, SymbolTableSize, sizeof (Symbol_t), CompareSymbolName);
  // If a symbol is duplicated (in the same namespace), be remove the
  // duplicates.
  for (i = 1; i < SymbolTableSize; )
    {
      if (SymbolTable[i - 1].Namespace == SymbolTable[i].Namespace &&
          !strcmp (SymbolTable[i - 1].Name, SymbolTable[i].Name))
        {
	  printf ("Symbol \"%s\" (%d) is duplicated.\n", 
	          SymbolTable[i].Name, SymbolTable[i].Namespace);
          ErrorCount++;		  
	  for (j = i; j < SymbolTableSize; j++)
	    SymbolTable[j - 1] = SymbolTable[j];
	  SymbolTableSize--;  
	}	  
      else
        i++;	
    }
  return (ErrorCount);
}

//-------------------------------------------------------------------------
// Locate a string in the symbol table.  
// Returns a pointer to the symbol-table entry, or NULL if not found.. 

Symbol_t *
GetSymbol (const char *Name)
{
  char Namespace = 0;
  Symbol_t Symbol;
  if (strlen (Name) > MAX_LABEL_LENGTH)
    return (NULL);
  Symbol.Namespace = Namespace;
  strcpy (Symbol.Name, Name);
  return ((Symbol_t *) bsearch (&Symbol, SymbolTable, SymbolTableSize,
                                sizeof (Symbol_t), CompareSymbolName));
}

//------------------------------------------------------------------------
// Print the symbol table.

void
PrintSymbolsToFile (FILE *fp)
{
  int i;
  fprintf (fp, "Symbol Table\n"
          "------------\n");
  for (i = 0; i < SymbolTableSize; i++)
    {
      if (!(i & 3) && i != 0)
        fprintf (fp, "\n");
      fprintf (fp, "%6d:   %-*s   ", i + 1, MAX_LABEL_LENGTH, SymbolTable[i].Name);
      AddressPrint (&SymbolTable[i].Value);
      if (3 != (i & 3))
        fprintf (fp, "\t\t");
    }
  fprintf (fp, "\n");  
}

void
PrintSymbols (void)
{
  PrintSymbolsToFile (stdout);
}

//------------------------------------------------------------------------
// Counts the number of unresolved symbols.

int
UnresolvedSymbols (void)
{
  int i, Ret = 0;
  for (i = 0; i < SymbolTableSize; i++)
    if (SymbolTable[i].Value.Invalid)
      Ret++;
  return (Ret);    
}

//------------------------------------------------------------------------
// JMS: Begin additions for output of symbol table to a file for symbolic
// debugging purposes.
//------------------------------------------------------------------------

// JMS: 07.28

// These holds entries for every single compiled line in the source and
// its file and line number. This table is needed to print out the source
// line as we step through code. It is also needed for "break <line #>".
SymbolLine_t *LineTable = NULL;
int LineTableSize = 0, LineTableMax = 0;

//------------------------------------------------------------------------
// Assign a symbol a new value including is type, and the file name/line
// number from which it came which is used for debugging purposes. Returns
// 0 upon success, 1 upon failure.
int
EditSymbolNew (const char *Name, Address_t *Value, int Type, char *FileName,
	       unsigned int LineNumber)
{
  char Namespace = 0;
  Symbol_t *Symbol;

  // Find out where the symbol is located in the symbol table.
  Symbol = GetSymbol (Name);
  if (Symbol == NULL)
    {
      printf ("Implementation error: symbol %d,\"%s\" lost between passes.\n",
              Namespace, Name);
      return (1);
    }
  // This can't happen, but still ...
  if (strcmp (Name, Symbol->Name))
    {
      printf ("***** Name mismatch:  %s/%s\n", Name, Symbol->Name);
    }  

  // Check to see if the symbol is in a namespace that allows it to be
  // reassigned.
  if (0)
    {
      printf ("Symbol \"%s\" in namespace %d cannot be reassigned.\n",
              Symbol->Name, Symbol->Namespace);
    }

  // Reassign the value.
  Symbol->Value = *Value;

  // Assign the symbol type, file name, and line number
  Symbol->Type = Type;
  Symbol->LineNumber = LineNumber;
  strcpy(Symbol->FileName, FileName);

  return (0);
}

//------------------------------------------------------------------------
// Writes the symbol table to a file in binary format. See yaYUL.h for
// more information about the format. Takes the name of the symbol file.

#ifndef O_BINARY
// The O_BINARY flag is needed only in Windows.  If it's not defined,
// it's okay to just make it zero, because it means it's not needed.
#define O_BINARY 0
#endif

void
WriteSymbolsToFile (char *fname)
{
  int i, fd;
  SymbolFile_t symfile;

  // Open the symbol table file
  if ((fd = open (fname, O_BINARY | O_WRONLY | O_CREAT | O_TRUNC, 0666)) < 0) {
    printf ("\nFailed to open symbol table file: %s\n", fname);
    return;
  }

  // Write the SymbolFile_t header to the symbol file, filling its
  // members first.
  getcwd (symfile.SourcePath, MAX_PATH_LENGTH);
  symfile.NumberSymbols = SymbolTableSize;
  symfile.NumberLines = LineTableSize; // JMS: 07.28
  write (fd, (void *)&symfile, sizeof(SymbolFile_t));

  // Loop and write the symbols to a file
  for (i = 0; i < SymbolTableSize; i++)
    {
      write (fd, (void *)&SymbolTable[i], sizeof (Symbol_t));
    }

  // JMS: 07.28
  // Loop and write the symbol lines to a file
  for (i = 0; i < LineTableSize; i++)
    {
      write (fd, (void *)&LineTable[i], sizeof (SymbolLine_t));
    }
  close (fd);
}

//-------------------------------------------------------------------------
// Delete the line table.
void
ClearLines (void)
{
  if (LineTable != NULL)
    free (LineTable);
  LineTable = NULL;
  LineTableSize = LineTableMax = 0;  
}

//-------------------------------------------------------------------------
// Adds a new program line to the table. Takes the Address_t at which this
// is stored in (fixed) memory, and the file name and line number where it
// is found. Takes the number of words the instruction takes up in memory.
// Returns 0 on success, or non-zero on fatal error.
int
AddLine (Address_t *Address, const char *FileName, int LineNumber)
{
  // A sanity clause.
  if (strlen (FileName) > MAX_FILE_LENGTH)
    {
      printf ("File name \"%s\" is too long.\n", FileName);
      return (1);
    }

  // If the line table is too small, enlarge it.
  if (LineTableSize == LineTableMax)
    {
      if (LineTable==NULL)
        {
	  // This default size comes from the fact that I know there is 32K
	  // of fixed memory in the AGC.
	  LineTableMax = 32768;
          LineTable = (SymbolLine_t *) calloc (LineTableMax, sizeof (SymbolLine_t));
	}
      else
        {
          LineTableMax += 1000;
	  LineTable = (SymbolLine_t *) realloc (LineTable, 
						LineTableMax * sizeof (SymbolLine_t));
	}
      if (LineTable == NULL)
        {
	  printf ("Out of memory (3).\n");
	  return (1);
	}
    }

  // Now add the line but adjust for the word inside the instruction.
  LineTable[LineTableSize].CodeAddress = *Address;
  strcpy(LineTable[LineTableSize].FileName, FileName);
  LineTable[LineTableSize].LineNumber = LineNumber;
  LineTableSize++;
  return (0); 
}

//-------------------------------------------------------------------------
// Compare function for the line table. We must sort the lines in increasing
// order of physical address. This routine is used for the AGC way of
// addressing memory.
static int
CompareLineAGC (const void *Raw1, const void *Raw2)
{
#define Address1 ((SymbolLine_t *) Raw1)->CodeAddress
#define Address2 ((SymbolLine_t *) Raw2)->CodeAddress

  // It is unclear whether we can ever get erasable addresses here, I
  // don't think so, so we'll just pretend there are fixed address
  // only. The ordering is by 'bank' then 'address', so fixed banks
  // 00 and 01 come before the unbanked 02 and 03 addresses.
  int Bank1, Bank2;

  if (Address1.Banked && Address1.FB >= 020 && Address1.Super)
    Bank1 = Address1.FB + 010;
  else if (Address1.Banked)
    Bank1 = Address1.FB;
  else
    Bank1 = Address1.SReg / 02000;

  if (Address2.Banked && Address2.FB >= 020 && Address2.Super)
    Bank2 = Address2.FB + 010;
  else if (Address2.Banked)
    Bank2 = Address2.FB;
  else
    Bank2 = Address2.SReg / 02000;

  if (Bank1 < Bank2)
    return -1;
  else if (Bank1 > Bank2)
    return 1;
  else if (Address1.SReg < Address2.SReg)
    return -1;
  else if (Address1.SReg > Address2.SReg)
    return 1;
  else
    return 0;

#undef Address1
#undef Address2
}

//-------------------------------------------------------------------------
// Compare function for the line table. We must sort the lines in increasing
// order of physical address. This uses the yaLEMAP way of addressing.
static int
CompareLineAGS (const void *Raw1, const void *Raw2)
{
#define Address1 ((SymbolLine_t *) Raw1)->CodeAddress
#define Address2 ((SymbolLine_t *) Raw2)->CodeAddress

  if (Address1.SReg < Address2.SReg)
    return -1;
  else if (Address1.SReg > Address2.SReg)
    return 1;
  else
    return 0;

#undef Address1
#undef Address2
}

//-------------------------------------------------------------------------
// Sort the line table.
void
SortLines (int Type)
{
  int i, j;
  int (*Compare)(const void *, const void *);

  // Sort the entries based upon the architecture
  if (Type == SORT_YUL)
    Compare = CompareLineAGC;
  else if (Type == SORT_LEMAP)
    Compare = CompareLineAGS;
  else
    {
      printf ("Invalid architecture type given.\n");
      return;
    }

  qsort (LineTable, LineTableSize, sizeof (SymbolLine_t), Compare);

  // Remove duplicates from the line table. I think this is a completely
  // normal situation because multiple passes are made throug the code
  // when compiling.
  printf("Removing the duplicated lines... ");
  for (i = 1; i < LineTableSize; )
    {
      if (!Compare((const void *)&LineTable[i - 1].CodeAddress,
		   (const void *)&LineTable[i].CodeAddress))
	{
	  AddressPrint(&LineTable[i - 1].CodeAddress);

	  for (j = i; j < LineTableSize; j++)
	    LineTable[j - 1] = LineTable[j];
	  LineTableSize--;  
	}	  
      else
        i++;	
    }
  printf("\n");
}

//------------------------------------------------------------------------
// JMS: End additions for output of symbol table
//------------------------------------------------------------------------
