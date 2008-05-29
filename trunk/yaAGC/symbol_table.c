/*
  Copyright 2005 Jordan M. Slott <jordanslott@yahoo.com>
  
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

  In addition, as a special exception, Ronald S. Burkey gives permission to
  link the code of this program with the Orbiter SDK library (or with 
  modified versions of the Orbiter SDK library that use the same license as 
  the Orbiter SDK library), and distribute linked combinations including 
  the two. You must obey the GNU General Public License in all respects for 
  all of the code used other than the Orbiter SDK library. If you modify 
  this file, you may extend this exception to your version of the file, 
  but you are not obligated to do so. If you do not wish to do so, delete 
  this exception statement from your version. 
 
  Filename:	symbol_table.c
  Purpose:	Symbol table for debugging AGC source code
  Contact:	Jordan Slott <jordanslott@yahoo.com>
  Reference:	http://www.ibiblio.org/apollo
  Mods:		04/30/05 JMS.	Began.
  		07/27/05 RSB.	A couple of cleanups to eliminate
				compiler warnings.
		07/28/05 RSB	Now uses 'rfopen' (rather than 'open') to
				open the symbol table, in order to find
				the "installed" table. Added regular expression
				matching to the symbol dump.  Did a bunch of
				stuff related to getting the symbol dump to 
				fit on the screen in Windows.
                07/28/05 JMS    Added support for reading in SymbolLine_t
                                table from symbol table and added the ability
                                to list source files.
		07/30/05 RSB	Now it always makes clear what the source-file
				is.  Also, for the usual one-line disassembly
				when the program halts, the address and
				address-contents are displayed.
		07/31/05 JMS    Keep a sorted list of source files so they
                                may be listed and for tab-completion.
*/

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <fcntl.h>
#include <sys/types.h>
//#include <sys/uio.h>
#include <unistd.h>
#include "agc_engine.h"
#ifdef WIN32
// For some reason, mingw doesn't supply the regex module.  What I do to 
// overcome this is simply to insert GNU regex's regex.c and regex.h.  
// Naturally, GNU regex is GPL'd, so I'm entitled to do this.  Unfortunately, 
// regex.c relies on bcopy, bcmp, and bzero, which mingw also does not provide.
// Therefore, I fake up those functions from memcpy, memcmp, and memset.
#include "regex.h"
void 
bzero (void *s, size_t n) 
{ 
  memset (s, 0, n); 
}
void
bcopy (const void *src, void *dest, size_t n)
{
  memcpy (dest, src, n);
}
int 
bcmp (const void *s1, const void *s2, size_t n) 
{ 
  return (memcmp (s1, s2, n)); 
}
#define DUMP_FORMAT  "%4s %8s %9s%8s %s\n"
#define DUMP_FORMAT2 "%4d %8s %9s%8s %s:%d\n"
#else
#include <regex.h>
#define DUMP_FORMAT  "%6s\t%12s\t%9s\t%8s\t%s\n"
#define DUMP_FORMAT2 "%6d\t%12s\t%9s\t%8s\t%s:%d\n"
#endif

// A list of the symbols is stored here, sorted. This table is used when
// looking up a symbol by its name
Symbol_t *SymbolTable = NULL;
int SymbolTableSize = 0;

// JMS: 07.28
// A list of all program line number is stored here, sorted. This table
// is used when looking up a source line by its (fixed) memory address
SymbolLine_t *LineTable = NULL;
int LineTableSize = 0;

// JMS: 07.28
// The currently opened source file name and current line number and its
// file pointer. This is used to maintain the state for the "list" debug
// command and when stepping through the program. The nominal case--that
// is, the next line is the most likely one which will be printed next
// is what this optimizes for. The memory for CurrentSourceFile is
// maintained by the ListFile() routine.
char *CurrentSourceFile = NULL;
int  CurrentLineNumber = -1;
FILE *CurrentSourceFP = NULL;
// 20050730 RSB.  The following tracks the CurrentSourceFP, and provides
// the textual form of the filename.
char CurrentSourcePath[MAX_PATH_LENGTH + MAX_FILE_LENGTH + 3];

// The path of the source files
char *SourcePathName = NULL;

// A list of all source file names, sorted alphabetically. This is used
// for listing source files and also for tab completion
char SourceFiles[MAX_NUM_FILES][MAX_FILE_LENGTH];
int NumberFiles = 0;

// Some Function declarations
static void CreateFileList (void);
void nbadd_source_file (const char *file);
void nbclear_files (void);

//------------------------------------------------------------------------
// Print an Address_t record formatted for the AGC architecture.  Returns
// 0 on success, non-zero on error. This was copied directly from yaYUL/Pass.c
int
AddressPrintAGC (Address_t *Address, char *AddressStr)
{
  if (Address->Invalid)
    sprintf (AddressStr, "???????  "); 
  else if (Address->Constant)
    {
      sprintf (AddressStr, "%07o  ", Address->Value & 07777777);
    }  
  else if (Address->Unbanked)
    sprintf (AddressStr, "   %04o  ", Address->SReg);
  else if (Address->Banked)
    {
      if (Address->Erasable)
	sprintf (AddressStr, "E%1o,%04o  ", Address->EB, Address->SReg);
      else if (Address->Fixed)
	sprintf (AddressStr, "%02o,%04o  ", Address->FB + 010 * Address->Super, Address->SReg);
      else
	{
	  printf ("int-err  ");
	  return (1);
	}  
    }
  else
    {
      printf ("int-err  ");
      return (1);  
    } 
  return (0);
}

//------------------------------------------------------------------------
// Print an Address_t record formatted to the AGS architecture.  Returns 0
// on success, non-zero on error. This was copied from yaLEMAP.c
int
AddressPrintAGS (Address_t *Address, char *AddressStr)
{
  if (Address->Invalid)
    sprintf (AddressStr, "????\t"); 
  else if (Address->Constant)
    {
      sprintf (AddressStr, "%04o\t", Address->Value & 07777);
    }  
  else if (Address->Address)
    sprintf (AddressStr, "%04o\t", Address->SReg & 07777);
  else
    {
      sprintf (AddressStr, "int-err ");
      return (1);  
    } 
  return (0);   
}

//-------------------------------------------------------------------------
// Returns a string constant for the type
static const char *
TypeString (int Type)
{
  switch (Type)
    {
    case SYMBOL_REGISTER: return "REGISTER";
    case SYMBOL_VARIABLE: return "VARIABLE";
    case SYMBOL_LABEL:    return "LABEL";
    case SYMBOL_CONSTANT: return "CONSTANT";
    default:              return "";
    }
}

//-------------------------------------------------------------------------
// Clears out symbol table
void
ResetSymbolTable (void)
{
  int i;

  // Clear the symbol table
  if (SymbolTable)
    free (SymbolTable);
  SymbolTableSize = 0;

  // Clear the line table
  if (LineTable)
    free (LineTable);
  LineTableSize = 0;

  // Clear the list of source files
  for (i = 0; i < MAX_NUM_FILES; i++)
    strcpy (SourceFiles[i], "");
  NumberFiles = 0;

  // Tell the nbfgets code to clear out its list of source
  // files names
  nbclear_files ();

  // Close the current open source file
  if (CurrentSourceFP != NULL)
    {
      fclose(CurrentSourceFP);
      CurrentSourceFP = NULL;
      strcpy(CurrentSourceFile, "");
      CurrentLineNumber = -1;
    }
}

//-------------------------------------------------------------------------
// Reads in the symbol table. The .symtab file is given as an argument. This
// routine updates the global variables storing the symbol table. Returns
// 0 upon success, 1 upon failure
int
ReadSymbolTable (char *fname)
{
  extern FILE *rfopen (const char *Filename, const char *mode);
  FILE *fp;
  int i, fd;
  Symbol_t *symbol;
  SymbolLine_t *Line;
  SymbolFile_t symfile;

  // Open the symbol table file. If it does not exist, that is ok.
  if (NULL == (fp = rfopen (fname, "rb")))
    {
      printf ("Cannot open symbol table file: %s\n", fname);
      return 1;
    }
  fd = fileno (fp);

  // Read in the SymbolFile_t structure as the header
  read (fd, &symfile, sizeof(SymbolFile_t));
  SourcePathName = strdup (symfile.SourcePath);

  // Allocate the symbol table
  SymbolTableSize = symfile.NumberSymbols;
  SymbolTable = (Symbol_t *) calloc (SymbolTableSize, sizeof (Symbol_t));

  // Loop through the number of symbols and read them each in. Since it is
  // a file, we kind of assume the read will succeed.
  for (i = 0; i < SymbolTableSize; i++)
    {
      // Allocate a new symbol
      if ((symbol = (Symbol_t *) malloc (sizeof(Symbol_t))) == NULL)
	{
	  printf ("Out of memory in symbol table\n");
	  fclose (fp);
	  return 1;
	}

      // Read it in from the symbol table file
      read (fd, symbol, sizeof(Symbol_t));
      SymbolTable[i] = *symbol;
    }

  // Allocate the line table
  LineTableSize = symfile.NumberLines;
  LineTable = (SymbolLine_t *) calloc (LineTableSize, sizeof (SymbolLine_t));

  // Loop through the number of symbols and read them each in. Since it is
  // a file, we kind of assume the read will succeed.
  for (i = 0; i < LineTableSize; i++)
    {
      // Allocate a new symbol
      if ((Line = (SymbolLine_t *) malloc (sizeof(SymbolLine_t))) == NULL)
	{
	  printf ("Out of memory in line table\n");
	  fclose (fp);
	  return 1;
	}

      // Read it in from the symbol table file
      read (fd, Line, sizeof(SymbolLine_t));
      LineTable[i] = *Line;
    }

  // Create the list of files from the LineTable
  CreateFileList ();

#if 0
  // Print out
  {
    FILE *tmp;
    int i;
    char AddressStr[64];

    tmp = fopen("linetest.out", "w");
    for (i = 0; i < LineTableSize; i++) {
      AddressPrintAGS(&LineTable[i].CodeAddress, AddressStr);
      fprintf(tmp, "%s\t%s\t%d\n", AddressStr, LineTable[i].FileName,
	      LineTable[i].LineNumber);
    }
    fclose(tmp);
  }
#endif
  
  fclose (fp);
  return 0;
}

//-------------------------------------------------------------------------
// Dumps the entire symbol table to the screen
void
DumpSymbols (const char *Pattern, int Arch)
{
  int i, Count = 0;
  char Address[16];
  regex_t preg;
  int (*AddressPrint)(Address_t *, char *);

  i = regcomp (&preg, Pattern, REG_ICASE | REG_NOSUB | REG_EXTENDED);
  if (i)
    {
      printf ("Illegal regular-expression.\n");
      regfree (&preg);
      return;
    }

  // Check to make sure the architecture flag passed in is valid
  if (Arch == ARCH_AGC)
    AddressPrint = AddressPrintAGC;
  else if (Arch == ARCH_AGS)
    AddressPrint = AddressPrintAGS;
  else
    {
      printf ("Invalid architecture given.\n");
      regfree (&preg);
      return;
    }

  // JMS: XXX This does not quite work. For some reason this information
  // gets truncated, see 08/10/04 comment by Ron Burkey in main.c. It
  // looks like the same problem. The fflush() calls don't seem to help.

  // Print out the number of symbols and a little header
  printf ("There are %d symbols in the symbol table\n", SymbolTableSize);
  printf (DUMP_FORMAT,
	 "NUM", "NAME", "ADDRESS  ", "TYPE", "FILE:LINE #");
  printf ("--------------------------------"
	 "--------------------------------\n");
  fflush(stdout);

  // Loop through and print out the entire symbol table
  for (i = 0; i < SymbolTableSize; i++)
    if (0 == regexec (&preg, SymbolTable[i].Name, 0, NULL, 0))
      {
	if (Count >= MAX_SYM_DUMP)
	  {
	    printf ("... Dump truncated at %d symbols ...\n", MAX_SYM_DUMP);
	    break;
	  }
	AddressPrint (&SymbolTable[i].Value, Address);
	printf (DUMP_FORMAT2,
		i, SymbolTable[i].Name, Address,
		TypeString(SymbolTable[i].Type),
		SymbolTable[i].FileName,
		SymbolTable[i].LineNumber);
	fflush(stdout);
	Count++;
      }
  printf ("\n");
  fflush (stdout);
  regfree (&preg);
}

//-------------------------------------------------------------------------
// Compare two symbol-table entries, for comparison purposes.  Both the
// Namespace and Name fields are used. This is taken directly from
// yaYUL/SymbolTable.c
static
int CompareSymbolName (const void *Raw1, const void *Raw2)
{
#define Element1 ((Symbol_t *) Raw1)
#define Element2 ((Symbol_t *) Raw2)
  return (strcmp (Element1->Name, Element2->Name));    
#undef Element1
#undef Element2
}

//-------------------------------------------------------------------------
// Resolves the symbol given its desired type mask.  Returns the Symbol_t
// entry if found or NULL if not found.
Symbol_t *
ResolveSymbol (char *Name, int TypeMask)
{
  Symbol_t Symbol, *Found = NULL;

  // Search for the symbol in the table
  strcpy (Symbol.Name, Name);
  Found = (Symbol_t *) bsearch (&Symbol, SymbolTable, SymbolTableSize,
                                sizeof (Symbol_t), CompareSymbolName);

  // If we found a symbol, then make sure it is the desired type.
  if (Found && (Found->Type & TypeMask))
    {
      return Found;
    }
  return NULL;
}

//-------------------------------------------------------------------------
// Returns information about a given symbol if found
void
WhatIsSymbol (char *SymbolName, int Arch)
{
  char AddressStr[64];
  Symbol_t Symbol, *Found = NULL;
  int (*AddressPrint)(Address_t *, char *);

  // Check to make sure the architecture flag passed in is valid
  if (Arch == ARCH_AGC)
    AddressPrint = AddressPrintAGC;
  else if (Arch == ARCH_AGS)
    AddressPrint = AddressPrintAGS;
  else
    {
      printf ("Invalid architecture given.\n");
      return;
    }

  // Search for the symbol in the table
  strcpy (Symbol.Name, SymbolName);
  Found = (Symbol_t *) bsearch (&Symbol, SymbolTable, SymbolTableSize,
                                sizeof (Symbol_t), CompareSymbolName);

  if (Found)
    {
      AddressPrint(&Found->Value, AddressStr);
      printf ("%12s\t%10s\t%10s\t%s:%d\n",
	      Found->Name, AddressStr,
	      TypeString(Found->Type),
	      Found->FileName,
	      Found->LineNumber);
    }
  else
    {
      printf("Symbol %s not found in symbol table\n", SymbolName);
    }
}

//-------------------------------------------------------------------------
// Compares two Address_t structures for comparison purposes using the
// AGC address architecture
static
int LineCompareAGC (const void *Raw1, const void *Raw2)
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
// Compares two Address_t structures for comparison purposes using the
// AGS address architecture
static
int LineCompareAGS (const void *Raw1, const void *Raw2)
{
#define Address1 ((SymbolLine_t *) Raw1)->CodeAddress
#define Address2 ((SymbolLine_t *) Raw2)->CodeAddress

  // It is unclear whether we can ever get erasable addresses here, I
  // don't think so, so we'll just pretend there are fixed address
  // only.
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
// Resolves the given program counter into a SymbolFile_t structure for
// the AGC address architecture. Returns NULL if the program line was not
// found.
SymbolLine_t *
ResolveLineAGC (int Address12, int FB, int SBB)
{
  SymbolLine_t Line;

  // Convert the <Address12, FB, SBB> into an Address_t structure. We only
  // want to find fixed memory addresses. We can get instances where the
  // program counter points to an erasable memory address, that is, when
  // we return from a subroutine, the return location is placed in the
  // Q register as an instruction itself.
  Line.CodeAddress = FIXED();
  if (Address12 < 02000)
    return NULL;
  else if (Address12 >= 02000 && Address12 < 04000)
    Line.CodeAddress.Banked = 1;
  else
    Line.CodeAddress.Unbanked = 1;

  // Otherwise, from now on, we have a fixed memory location, so populate
  // the Address_t structure.
  Line.CodeAddress.SReg = Address12 & 07777;
  Line.CodeAddress.FB = FB;
  Line.CodeAddress.Super = SBB;

  // Search for the line in the table
  return (SymbolLine_t *) bsearch (&Line, LineTable, LineTableSize,
				   sizeof (SymbolLine_t), LineCompareAGC);
}

//-------------------------------------------------------------------------
// Resolves the given program counter into a SymbolFile_t structure.
// Returns NULL if the program line was not found
SymbolLine_t *
ResolveLineAGS (int Address12)
{
  SymbolLine_t Line;

  Line.CodeAddress.Invalid = 0;
  Line.CodeAddress.Address = 1;
  Line.CodeAddress.SReg = Address12 & 07777;

  // Search for the line in the table
  return (SymbolLine_t *) bsearch (&Line, LineTable, LineTableSize,
				   sizeof (SymbolLine_t), LineCompareAGS);
}

//-------------------------------------------------------------------------
// Resolves a line number by searching the file name and line number.
// This is used for the "break <line>" debugging command. It is a rather
// inefficient implementation as it searches this entire ~32k list of
// program lines each time. However, I felt this wouldn't take too long
// and it saves another ~8MB of RAM for a LineTable which is sorted  by
// <file name, line number>.  The line number is referenced to the currently
// opened file. If there is none, then print an error and return NULL, although
// this should not happen in practice.
SymbolLine_t *
ResolveLineNumber (int LineNumber)
{
  int i;

  // Check for current file name. This should not really happen in practice
  // because when stepping through the source code, it will always have a
  // currently opened file.
  if (CurrentSourceFP == NULL)
    {
      printf("There is no current source file.\n");
      return NULL;
    }

  for (i = 0; i < LineTableSize; i++)
    {
      if (!strcmp(LineTable[i].FileName, CurrentSourceFile) &&
	  LineTable[i].LineNumber == LineNumber)
	{
	  return &LineTable[i];
	}
    }
  return NULL;
}

//-------------------------------------------------------------------------
// The following section contains routines pertaining to the reading of
// source files and displaying them in the debugging window
//-------------------------------------------------------------------------

//-------------------------------------------------------------------------
// Opens up the given file and positions the file pointer to the beginning
// of the file. This closes an existing open file, if any. Returns 0 upon
// success, 1 upon failure
static int
OpenSourceFile (char *FileName)
{
  char PathName[MAX_PATH_LENGTH + MAX_FILE_LENGTH + 3];
  char *ss;

  // Close out any existing file if any. Even if we cannot open the new
  // file, go ahead and close this out anyway
  if (CurrentSourceFP != NULL)
    {
      fclose (CurrentSourceFP);
      free (CurrentSourceFile);
      CurrentLineNumber = -1;
    }

  // Form the complete path of the source and try to open
  sprintf(PathName, "%s/%s", SourcePathName, FileName);
  if ((CurrentSourceFP = fopen (PathName, "r")) == NULL)
    {
      printf ("Cannot open source: %s\n", PathName);
      CurrentSourcePath[0] = 0;
      return 1;
    }
  // Remove the directory name from the path.  Otherwise, it will
  // print too wide for poor old Win32.
  for (ss = &PathName[strlen (PathName) - 1]; ss > &PathName[0]; ss--)
    if (*ss == '/' || *ss ==':' || *ss == '\\')
      {
        ss++;
        break;
      }
  strcpy (CurrentSourcePath, ss);

  // Otherwise, we can open the file so complete and return
  CurrentSourceFile = strdup (FileName);
  return 0;
}

//-------------------------------------------------------------------------
// Seeks the current open file pointer to the line number. This assumes
// that the file is valid and open. We do not care about what we read in,
// we just want to position the file pointer to the proper reading position.
// The first line number in a file is line 1.
static void
PositionFilePointer (int LineNumber)
{
  int i;
  char Line[MAX_LINE_LENGTH + 1];

  // Rewind to the beginning of the file
  rewind (CurrentSourceFP);

  // Loop through and read lines up until, but not including the current
  // line number.
  for (i = 1; i < LineNumber; i++)
    fgets (Line, MAX_LINE_LENGTH, CurrentSourceFP);
}

//-------------------------------------------------------------------------
// Skips a given number of lines in the open file. This function assumes
// that the file is valid and open. We do not care about what we read in,
// we just want to position the file pointer to the proper reading position.
static void
SkipFilePointer (int NumberLines)
{
  int i;
  char Line[MAX_LINE_LENGTH + 1];

  // Loop through and read lines up until, but not including the current
  // line number.
  for (i = 0; i < NumberLines; i++)
    fgets (Line, MAX_LINE_LENGTH, CurrentSourceFP);
}

//-------------------------------------------------------------------------
// Backups a given line number 5 lines to start printing. This function
// simply subtracts five and makes sure the line number is >= 1
static int
BackupLineNumber (int LineNumber, int Amount)
{
  LineNumber -= Amount;
  if (LineNumber < 1)
    LineNumber = 1;

  return LineNumber;
}

//-------------------------------------------------------------------------
// Displays a series of source file lines to the console. This assumes that
// the file is opened and the file pointer is positions to the proper
// location. The current file number is updated after this is done.
// 20050730 RSB.  If address field is non-NULL, then the line-number (from
// the source file) that would normally be printed is replaced by 
// AddressField.  For a one-line disassembly this allows an address and
// address-contents to be displayed rather than a line number.  The AddressField,
// if not NULL, is always a 16-character string with whitespace at the end.
static void
DisplaySource (int NumberLines, char *AddressField)
{
  int i;
  char Line[MAX_LINE_LENGTH + 1];

  // Loop through and read lines up until we read NumberLines. If
  // we reach the end of the file, then say so and stop.
  // line number.
  for (i = 0; i < NumberLines; i++)
    {
      // If fgets returns non-NULL we have a good line, otherwise we
      // have an error or an EOF.
      if (fgets (Line, MAX_LINE_LENGTH, CurrentSourceFP) != NULL)
	{
	  if (AddressField == NULL)
	    printf("%d\t%s", CurrentLineNumber, Line);
	  else
	    printf ("%s%s", AddressField, Line);
	  CurrentLineNumber++;
	}
      else
	{
	  printf("<End of File: %s>\n", CurrentSourceFile);
	  break;
	}
    }
}

//-------------------------------------------------------------------------
// Outputs the sources for the given file name and line number to the
// console. The 5 lines before the line given and the 10 lines after the
// line number given is displayed, subject to the file bounds. If the given
// LineNumber is -1, then display the next MAX_LIST_LENGTH line numbers.
void
ListSource (char *SourceFile, int LineNumber)
{
  // Debug Command: LINENUM
  // If the requested source is the NULL, then we want to display
  // the current file. If no such file exists, then print out an error
  // message.
  if (SourceFile == NULL && CurrentSourceFP == NULL)
    {
      printf("No current source file.\n");
    }
  else if (SourceFile == NULL && LineNumber != -1)
    {
      // Debug Command: LIST LINENUM
      // Otherwise, if there is no source file and we do have one
      // currently open, then just display the source. List "around"
      // the given line number.
      printf ("Source file = %s\n", CurrentSourcePath);
      CurrentLineNumber = BackupLineNumber (LineNumber, 5);
      PositionFilePointer (CurrentLineNumber);
      DisplaySource (MAX_LIST_LENGTH, NULL);
    }
  else if (SourceFile == NULL && LineNumber == -1)
    {
      // Debug Command: LIST
      // We want to display the next MAX_LIST_LENGTH line numbers from
      // the current position
      printf ("Source file = %s\n", CurrentSourcePath);
      DisplaySource (MAX_LIST_LENGTH, NULL);
    }
  else
    {
      // Debug Command: LIST FILE:LINENUM
      // For the given file name, list "around" the given line number
      if (!OpenSourceFile (SourceFile))
	{
          printf ("Source file = %s\n", CurrentSourcePath);
	  CurrentLineNumber = BackupLineNumber (LineNumber, 5);
	  PositionFilePointer (CurrentLineNumber);
	  DisplaySource (MAX_LIST_LENGTH, NULL);
	}
    }
}

//-------------------------------------------------------------------------
// Displays a listing of source before the last one. This call results from
// a "LIST -" command which it is assumed follows some "LIST" command. We
// just backup 2 * MAX_LIST_LENGTH. It also assumes we want to list in the
// current file, so if there is not, this does nothing
void
ListBackupSource (void)
{
  if (CurrentSourceFP == NULL)
    {
      printf("No current source file.\n");
    }
  else
    {
      printf ("Source file = %s\n", CurrentSourcePath);
      CurrentLineNumber = BackupLineNumber (CurrentLineNumber, 2 * MAX_LIST_LENGTH);
      PositionFilePointer (CurrentLineNumber);
      DisplaySource (MAX_LIST_LENGTH, NULL);
    }
}

//-------------------------------------------------------------------------
// Displays a listing of source for the current file for the line given
// line numbers. Both given line numbers must be positive and LineNumberTo
// >= LineNumberFrom.
void
ListSourceRange (int LineNumberFrom, int LineNumberTo)
{
  if (CurrentSourceFP == NULL)
    {
      printf("No current source file.\n");
    }
  else if (LineNumberFrom < 1 || LineNumberTo < 1 || LineNumberFrom > LineNumberTo)
    {
      printf("Invalid line number ranges given.\n");
    }
  else
    {
      printf ("Source file = %s\n", CurrentSourcePath);
      CurrentLineNumber = LineNumberFrom;
      PositionFilePointer (CurrentLineNumber);
      DisplaySource (LineNumberTo - LineNumberFrom + 1, NULL);
    }
}

//-------------------------------------------------------------------------
// Displays a single line given the file name and line number. This is
// called when displaying the next line to display while stepping through
// code. It is optimized for such: it looks to see if the file name is the
// same as the request file and if the requested line number is greater
// than the current line number. Returns 0 upon success, 1 upon failure.
int
ListSourceLine (char *SourceFile, int LineNumber, char *Contents)
{
  // If we think we are close to the line to read in, then just skip to
  // that position
  if (CurrentSourceFP != NULL && !strcmp(CurrentSourceFile, SourceFile) &&
      CurrentLineNumber <= LineNumber)
    {
      SkipFilePointer (LineNumber - CurrentLineNumber);
      CurrentLineNumber = LineNumber;
      
      printf ("Source file = %s:%d\n", CurrentSourcePath, CurrentLineNumber);
      DisplaySource (1, Contents);
    }
  else
    {
      // Go through the whole deal of loading in the proper file and
      // positioning from the beginning
      if (!OpenSourceFile (SourceFile))
	{
	  CurrentLineNumber = LineNumber;
	  PositionFilePointer (CurrentLineNumber);
          printf ("Source file = %s:%d\n", CurrentSourcePath, CurrentLineNumber);
	  DisplaySource (1, Contents);
	}
      else
	{
	  printf("Cannot find source file: %s\n", SourceFile);
	  return 1;
	}
    }
  return 0;
}

//-------------------------------------------------------------------------
// The following section contains routines pertaining to the list of
// source files for listing and file completion purposes.
//-------------------------------------------------------------------------

//-------------------------------------------------------------------------
// Dumps a list of source files given a regular expression pattern
void
DumpFiles (const char *Pattern)
{
  int i, Count = 0;
  //char Address[16];
  regex_t preg;

  i = regcomp (&preg, Pattern, REG_ICASE | REG_NOSUB | REG_EXTENDED);
  if (i)
    {
      printf ("Illegal regular-expression.\n");
      regfree (&preg);
      return;
    }

  // Loop through and print out the matching files
  for (i = 0; i < NumberFiles; i++)
    if (0 == regexec (&preg, SourceFiles[i], 0, NULL, 0))
      {
	if (Count >= MAX_FILE_DUMP)
	  {
	    printf ("... Dump truncated at %d files ...\n", MAX_FILE_DUMP);
	    break;
	  }

	printf ("%s\n", SourceFiles[i]);
	Count++;
      }

  fflush (stdout);
  regfree (&preg);
}

//-------------------------------------------------------------------------
// Compare two source file for comparison purposes.
static
int CompareFileName (const void *Raw1, const void *Raw2)
{
#define Element1 ((char *) Raw1)
#define Element2 ((char *) Raw2)
  return (strcmp (Element1, Element2));    
#undef Element1
#undef Element2
}

//-------------------------------------------------------------------------
// Creates the list of source files from the LineTable table. Sorts the
// list of files
static void
CreateFileList (void)
{
  int i, j, Found;

  // Loop through each of the lines in the LineTable and add the source
  // file to the list, making sure not to add duplications.
  for (i = 0; i < LineTableSize; i++)
    {
      Found = 0;

      // See if it already exists...
      for (j = 0; j < NumberFiles; j++)
	if (!strcmp (SourceFiles[j], LineTable[i].FileName))
	  {
	    Found = 1;
	    break;
	  }

      // If not, then add it, up the the limit
      if (!Found)
	{
	  if (NumberFiles >= MAX_NUM_FILES)
	    {
	      printf ("Out of memory in source file list\n");
	      break;
	    }
	  
	  strcpy (SourceFiles[NumberFiles], LineTable[i].FileName);
	  NumberFiles++;
	}
    }

  // Now sort the files alphabetically
  qsort (SourceFiles, NumberFiles, MAX_FILE_LENGTH * sizeof(char), CompareFileName);

  // Add the list of source files to the nbgets facility. This is temporary
  // to decouple the two because yaAGC uses nbfgets.
  for (i = 0; i < NumberFiles; i++)
    {
      nbadd_source_file (SourceFiles[i]);
    }

#if 0
  // Print
  printf("Number Files=%d\n", NumberFiles);
  for (i = 0; i < NumberFiles; i++)
    printf("%s\n", SourceFiles[i]);
#endif
}

