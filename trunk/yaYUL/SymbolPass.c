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

  Filename:	SymbolPass.c
  Purpose:	A pass intended to do nothing but to identify symbols
  		defined in the program.  (Basically, anything beginning
		in column 1, but not beginning with # or $.
  Mode:		04/17/03 RSB.	Began.
*/

#include "yaYUL.h"
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <ctype.h>

//-------------------------------------------------------------------------
// Some global data.

// We allow a certain number of levels of include files.  To handle this,
// we need a stack of input files.
#define MAX_STACKED_INCLUDES 5
static int NumStackedIncludes = 0;
typedef struct {
  FILE *InputFile;
  Line_t InputFilename;
  int CurrentLineInFile;
} StackedInclude_t;
static StackedInclude_t StackedIncludes[MAX_STACKED_INCLUDES];

// Some dummy strings for parsing an input line.
static Line_t Fields[6];
static int NumFields = 0;

//-------------------------------------------------------------------------

void 
SymbolPass (const char *InputFilename)
{
  Line_t CurrentFilename;
  Line_t s;
  char *Comment, *Label, *FalseLabel, *Operator, *Operand, *Mod1, *Mod2;
  FILE *InputFile;
  int CurrentLineAll = 0, CurrentLineInFile = 0;
  int i;				// dummies.
  char *ss;				// dummies.
  
  // Open the input file.
  strcpy (CurrentFilename, InputFilename);
  InputFile = fopen (CurrentFilename, "r");
  if (InputFile == NULL)
    goto Done;

  // Loop on the lines of the input file.  
  s[sizeof (s) - 1] = 0;
  for (;;)
    {
      // Get the next line from the file.
      ss = fgets (s, sizeof (s) - 1, InputFile);
      // At end of the file?
      if (NULL == ss)
        {
	  // We've reached the end of this input file.  Need to switch
	  // files (if we were within an include-file) or to end the pass.
	  if (NumStackedIncludes)
	    {
	      fclose (InputFile);
	      NumStackedIncludes--;
	      InputFile = StackedIncludes[NumStackedIncludes].InputFile;
	      strcpy (CurrentFilename, 
	              StackedIncludes[NumStackedIncludes].InputFilename);
	      CurrentLineInFile = StackedIncludes[NumStackedIncludes].CurrentLineInFile; 
	      continue;
	    }
	  else
	    {
	      // All done!
	      break;
	    }  
	}
      else
        {
	  // No, not at end of file, so we've just read a new line.
	  CurrentLineAll++;
	  CurrentLineInFile++;
	}
	
      if (HtmlCheck (0, InputFile, s, sizeof (s), CurrentFilename, &CurrentLineAll, &CurrentLineInFile))
        continue;
		
      // Analyze the input line.  Is it an "include" directive?	
      if (s[0] == '$')
        {
	  // This is a directive to include another file.
	  if (NumStackedIncludes == MAX_STACKED_INCLUDES)
	    {
	      printf ("Too many levels of include-files.\n");
	      goto Done;
	    }
	  StackedIncludes[NumStackedIncludes].InputFile = InputFile;
	  strcpy (StackedIncludes[NumStackedIncludes].InputFilename,
	  	  CurrentFilename);
	  StackedIncludes[NumStackedIncludes].CurrentLineInFile = CurrentLineInFile;
	  NumStackedIncludes++;
	  if (1 != sscanf (s, "$%s", CurrentFilename))
	    {
	      printf ("Include-directive has no filename.\n");
	      goto Done;
	    }
	  CurrentLineInFile = 0;
	  InputFile = fopen (CurrentFilename, "r");
	  if (InputFile == NULL)
	    {
	      printf ("Include-file \"%s\" does not exist.\n", CurrentFilename);
	      goto Done;
	    }	    
	  continue;
	} 
    
      // Set up appropriate default values for various fields.
      Label = FalseLabel = Operator = Operand = Mod1 = Mod2 = "";
    
      // Find and remove the comment field, if any.
      for (Comment = s; *Comment && *Comment != COMMENT_SEPARATOR; Comment++);
      if (*Comment == '#')
        {
          *Comment++ = 0;
	  // Trim the newline at the end:
	  for (ss = Comment; *ss; ss++)
	    if (*ss == '\n')
	      *ss = 0;
        }
	
      // Suck in all other fields.
      NumFields = sscanf (s, "%s%s%s%s%s%s", Fields[0], Fields[1],
      			  Fields[2], Fields[3], Fields[4], Fields[5]);	
      if (NumFields >= 1)
        {			  
	  i = 0;
	  if (*s && !isspace (*s))
	    Label = Fields[i++];
	  else if (*Fields[0] == '+' || *Fields[0] == '-')
	    FalseLabel = Fields[i++];
	  if (i < NumFields)
	    Operator = Fields[i++];
	  if (i < NumFields)
	    Operand = Fields[i++];
	  if (i < NumFields)
	    Mod1 = Fields[i++];
	  if (i < NumFields)
	    Mod2 = Fields[i++];
	}
	
      if (*Label != 0 && strcmp(Operator, "MEMORY") && strcmp(Operator, "CHECK="))
        {
	  //if (!strcmp (Label, "ATMAGAD"))
	  //  printf ("***** %s, %d, %d, %s", CurrentFilename, CurrentLineAll, CurrentLineInFile, s);
	  if (AddSymbol (Label))
	    {
	      printf ("Out of memory (2).\n");
	      goto Done;
	    }	
	}
    }

  // Done with this pass.
Done:  
  if (InputFile != NULL)
    fclose (InputFile);
  for (i = 0; i < NumStackedIncludes; i++)
    fclose (StackedIncludes[i].InputFile); 
  NumStackedIncludes = 0; 
}

  

