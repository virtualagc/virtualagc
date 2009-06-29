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
  Mode:		04/11/03 RSB.	Began.
  		07/03/04 RSB.	Provided for placing the object code into
				the object code buffer for subsequent
				output to a file.
		07/04/04 RSB	For multi-word pseudo-ops like 2DEC, only
				the first word was being written to the
				binary.
		07/05/04 RSB	Added KeepExtend, to fix the INDEX instruction
				resetting the Extend flag.
		07/23/04 RSB	Continued changes relating to interpretive 
				opcodes and operands.
		07/17/05 RSB	Fixed some structure-initializer problems
				I discovered when trying to compile for
				Kubuntu-PPC.
		07/27/05 JMS    Added support for symbolic debugging output.
		07/28/05 JMS    Added support for writing SymbolLines_to to symbol
		                table file.
		06/27/09 RSB	Began adding support for HtmlOut.
		06/29/09 RSB	Added some fixes for BASIC vs. PSEUDO-OP in
				HTML colorizing.

  I don't really try to duplicate the formatting used by the original
  assembly-language code, since that format was appropriate for 
  punch-cards, but not really for decent text editors.  [As near as I
  can tell by just reading the source code, it appeared to involved
  fixed-size fields:  (perhaps) nothing in column 1 (or maybe something 
  to indicate a remark), 8 characters for a label (but ignored if blank
  in column 2), blank, 6 characters for opcode, blank, etc.]  It's 
  particularly easy to ignore the original format, since I don't have
  any machine-readable AGC source code anyhow.  Since it all has to be
  entered manually, it may as well be a more-flexible format.  So 
  here's how it will go:
  
  	Labels begin in column 1.
	The next field is the opcode or pseudo op.
	The next field is the operand, if any.
	Comments are anything following a pound #.
	
  An exception is anything that looks like +%d or -%d in col. 2.  (These
  notations are just ignored.)
*/

#define ORIGINAL_PASS_C
#include "yaYUL.h"
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <ctype.h>

//-------------------------------------------------------------------------
// Colors for HTML.

#define COLOR_BASIC	"<span style=\"color: rgb(153, 51, 0);\">"
#define COLOR_DOWNLINK	"<span style=\"color: rgb(0, 153, 0);\">"
#define COLOR_FATAL	"<span style=\"color: rgb(255, 0, 0);\">"
#define COLOR_INTERPRET	"<span style=\"color: rgb(255, 102, 0);\">"
#define COLOR_PSEUDO	"<span style=\"color: rgb(51, 102, 102);\">"
#define COLOR_SYMBOL	"<span style=\"color: rgb(0, 0, 255);\">"
#define COLOR_WARNING	"<span style=\"color: rgb(255, 153, 0);\">"

//-------------------------------------------------------------------------
// Some global data.

Line_t CurrentFilename;
int CurrentLineInFile = 0;
  
// We allow a certain number of levels of include files.  To handle this,
// we need a stack of input files.
#define MAX_STACKED_INCLUDES 5
static int NumStackedIncludes = 0;
typedef struct {
  FILE *InputFile;
  Line_t InputFilename;
  int CurrentLineInFile;
  FILE *HtmlOut;
} StackedInclude_t;
static StackedInclude_t StackedIncludes[MAX_STACKED_INCLUDES];

// Some dummy strings for parsing an input line.
static Line_t Fields[6];
static int NumFields = 0;

//-------------------------------------------------------------------------
// Add an opcode to OpcodeOffset.

#if 0
static int
ExtendAgc (int Value)
{
  Value &= 077777;
  if (Value & 040000)
    Value |= 0100000;
  return (Value);
}
#endif // 0

static int
AddAgc (int Val1, int Val2)
{
#if 0
  int Sum;
  Sum = ExtendAgc (Val1) + ExtendAgc (Val2);
  if (0200000 & Sum)
    Sum++;
  Sum &= ~040000;
  if (0100000 & Sum)
    Sum |= 040000;
  return (Sum & 077777);
#endif // 0
  return (077777 & (Val1 + Val2));  
}

//-------------------------------------------------------------------------
// A function used to compare two ParserMatch_t structures on the basis
// of the operator names they embody.  Used for sorting or searching the
// Parsers array.

static int
CompareParsers (const void *p1, const void *p2)
{
#define Parser1 ((ParserMatch_t *) p1)
#define Parser2 ((ParserMatch_t *) p2)
  return (strcmp (Parser1->Name, Parser2->Name));
#undef Parser2
#undef Parser1
}

static int ParsersSorted = 0;
void
SortParsers (void)
{
  if (!ParsersSorted)
    {
      ParsersSorted = 1;
      qsort (Parsers, NUM_PARSERS, sizeof (Parsers[0]), CompareParsers);
    }
}

static ParserMatch_t *
FindParser (const char *Name)
{
  ParserMatch_t Key;
  strcpy (Key.Name, Name);
  return (bsearch (&Key, Parsers, NUM_PARSERS, sizeof (Parsers[0]), CompareParsers));
}

//-------------------------------------------------------------------------
// A function used to compare two InterpreterMatch_t structures on the basis
// of the operator names they embody.  Used for sorting or searching the
// InterpreterOpcodes array.

static int
CompareInterpreters (const void *p1, const void *p2)
{
#define Interpreter1 ((InterpreterMatch_t *) p1)
#define Interpreter2 ((InterpreterMatch_t *) p2)
  return (strcmp (Interpreter1->Name, Interpreter2->Name));
#undef Interpreter2
#undef Interpreter1
}

static int InterpretersSorted = 0;
void
SortInterpreters (void)
{
  if (!InterpretersSorted)
    {
      InterpretersSorted = 1;
      qsort (InterpreterOpcodes, NUM_INTERPRETERS, sizeof (InterpreterOpcodes[0]), 
             CompareInterpreters);
    }
}

static InterpreterMatch_t *
FindInterpreter (const char *Name)
{
  InterpreterMatch_t Key;
  strcpy (Key.Name, Name);
  return (bsearch (&Key, InterpreterOpcodes, NUM_INTERPRETERS, 
          sizeof (InterpreterOpcodes[0]), CompareInterpreters));
}

//-------------------------------------------------------------------------
// This function simply checks to see if a given string is the name of an 
// interpreter instruction.  It is used only for colorizing HTML output.
// Returns 1 if yes, 0 if no.
static int
IsInterpretive (char *s)
{
  ParserMatch_t *Match;
  if (NULL != FindInterpreter (s))
    return (1);
  Match = FindParser (s);
  if (Match != NULL && Match->OpType == OP_INTERPRETER)
    return (1);
  return (0);
}

//------------------------------------------------------------------------
// Print an Address_t record.  Returns 0 on success, non-zero on error.

int
AddressPrint (Address_t *Address)
{
  if (Address->Invalid)
    {
      printf ("???????  "); 
      if (HtmlOut != NULL)
        fprintf (HtmlOut, "???????&nbsp;&nbsp;");
    }
  else if (Address->Constant)
    {
      printf ("%07o  ", Address->Value & 07777777);
      if (HtmlOut != NULL)
        fprintf (HtmlOut, "%07o&nbsp;&nbsp;", Address->Value & 07777777);
    }  
  else if (Address->Unbanked)
    {
      printf ("   %04o  ", Address->SReg);
      if (HtmlOut != NULL)
        fprintf (HtmlOut, "&nbsp;&nbsp;&nbsp;%04o&nbsp;&nbsp;", Address->SReg);
    }
  else if (Address->Banked)
    {
      if (Address->Erasable)
        {
	  printf ("E%1o,%04o  ", Address->EB, Address->SReg);
	  if (HtmlOut != NULL)
	    fprintf (HtmlOut, "E%1o,%04o&nbsp;&nbsp;", Address->EB, Address->SReg);
	}
      else if (Address->Fixed)
        {
	  printf ("%02o,%04o  ", Address->FB + 010 * Address->Super, Address->SReg);
	  if (HtmlOut != NULL)
	    fprintf (HtmlOut, "%02o,%04o&nbsp;&nbsp;", Address->FB + 010 * Address->Super, Address->SReg);
	}
      else
	{
	  printf ("int-err  ");
	  if (HtmlOut != NULL)
	    fprintf (HtmlOut, "int-err&nbsp;&nbsp;");
	  return (1);
	}  
    }
  else
    {
      printf ("int-err  ");
      if (HtmlOut != NULL)
        fprintf (HtmlOut, "int-err&nbsp;&nbsp;");
      return (1);  
    } 
  return (0);   
}

// Checks a string to see if is of one of the forms
//	+n
//	-n
//	+nD
//	-nD
// Returns 1 if so, or 0 otherwise.
int
IsFalseLabel (char *s)
{
  if (*s != '-' && *s != '+')
    return (0);
  if (!isdigit (*++s))
    return (0);
  for (s++; isdigit (*s); s++);
  if (*s == 0)
    return (1);
  if (*s++ != 'D')
    return (0); 
  return (*s == 0);
}

// JMS: Returns 1 if the given operator is an "embedded" constant, meaning
// the label is a memory location which holds some data. The following
// operands are embedded constants: ERASE, DEC, DEC*, 2DEC, 2DEC*, OCT
int
IsEmbeddedConstant (char *s)
{
  if (!strcmp(s, "ERASE") || !strcmp(s, "DEC") || !strcmp(s, "DEC*") ||
      !strcmp(s, "2DEC") || !strcmp(s, "2DEC*") || !strcmp(s, "OCT"))
    {
      return 1;
    }
  return 0;
}

//-------------------------------------------------------------------------
// The assembler itself.  If called with WriteOutput==0, simply tries to
// resolve symbols.  With each successive pass, resolves more symbols.
// It returns -1 on a completely unrecoverable error.  When called with 
// WriteOutput=1 tries to write the output binary.  It is assumed that 
// SymbolPass and SortSymbols have been used prior to the first call to Pass.

int WriteOutputDebug;

// The following used to be local to the Pass() function, but apparently
// the initializers don't work the way I expect, causing boogered-up 
// behavior, so I made them global.
static Address_t DefaultAddress = INVALID_ADDRESS;
static ParseInput_t ParseInputRecord;
static ParseInput_t DefaultParseInput = { 
  INVALID_ADDRESS, 0, "", "", "", "", "", "", "", "", "",
  0, 0, 0, INVALID_EBANK 
};
static ParseOutput_t ParseOutputRecord, DefaultParseOutput = { 
  INVALID_ADDRESS, 0, { 0, 0 }, 0, "", INVALID_ADDRESS,
  0, 0, 0, 0, 0, 0, INVALID_EBANK, 0
};
  
int 
Pass (int WriteOutput, const char *InputFilename, FILE *OutputFile,
      int *Fatals, int *Warnings)
{
  int IncludeDirective;
  ParserMatch_t *Match;
  InterpreterMatch_t *iMatch;
  int RetVal = 1, PinchHitting;
  Line_t s;
  FILE *InputFile;
  int CurrentLineAll = 0;
  int i, j;				// dummies.
  char *ss;				// dummies.
  int StadrInvert = 0;
  
  WriteOutputDebug = WriteOutput;
  
  CurrentLineInFile = 0;
  StartBankCounts ();
  SortParsers ();
  SortInterpreters ();
  *Fatals = *Warnings = 0;
  
  for (i = 0; i < 044; i++)
    for (j = 0; j < 02000; j++)
      ObjectCode[i][j] = 0;
  
  // Open the input file.
  strcpy (CurrentFilename, InputFilename);
  InputFile = fopen (CurrentFilename, "r");
  if (InputFile == NULL)
    goto Done;

  // Loop on the lines of the input file.  The assembler passes differ 
  // among themselves as follows:
  //	Pass 1.	Assembly is performed, but no output is written.
  //		The purpose is simply to create a list of all symbols and
  //		their namespaces, and their values.
  //	Pass 2.	Output is written.
  s[sizeof (s) - 1] = 0;
  ParseOutputRecord.ProgramCounter = DefaultAddress;
  ParseOutputRecord.Bank = (const EBank_t) { 
    { 1 }, 
    { 1 }, 
    0,
    { 0, 0, 1, 0, 0, 1, 0, 1, 0, 030, 1, 0, 070000 }
  };
  for (;;)
    {
      IncludeDirective = 0;
      OpcodeOffset = 0;
      PinchHitting = 0;
      ArgType = 0;
      // Set up the default info for this line.
      ParseInputRecord = DefaultParseInput;
      ParseInputRecord.ProgramCounter = ParseOutputRecord.ProgramCounter;
      ParseInputRecord.Bank = ParseOutputRecord.Bank;
      ParseInputRecord.Index = ParseOutputRecord.Index;
      ParseInputRecord.IndexValid = ParseOutputRecord.IndexValid;
      ParseInputRecord.Extend = ParseOutputRecord.Extend;
      ParseOutputRecord = DefaultParseOutput;
      ParseOutputRecord.Bank = ParseInputRecord.Bank;
      if (WriteOutput && ParseInputRecord.ProgramCounter.FB == 022 && ParseInputRecord.ProgramCounter.SReg == 02411)
        {
          printf ("Hello!\n");
	  if (HtmlOut != NULL)
	    fprintf (HtmlOut, "Hello!<br>\n");
	}
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
	      if (WriteOutput)
	        {
		  printf ("(End of include-file %s, resuming %s)\n", 
			  CurrentFilename,
			  StackedIncludes[NumStackedIncludes].InputFilename);
		  if (HtmlOut != NULL)
		    {
		      fprintf (HtmlOut, "<br>\nEnd of include-file %s.  Parent file is <a href=\"%s\">%s</a><br>\n", 
			       CurrentFilename,
			       NormalizeFilename (StackedIncludes[NumStackedIncludes].InputFilename),
			       StackedIncludes[NumStackedIncludes].InputFilename);
		      HtmlClose ();
		      HtmlOut = NULL;
		      IncludeDirective = 1;
		    }
		}
	      strcpy (CurrentFilename, StackedIncludes[NumStackedIncludes].InputFilename);
	      InputFile = StackedIncludes[NumStackedIncludes].InputFile;
	      strcpy (CurrentFilename, 
	              StackedIncludes[NumStackedIncludes].InputFilename);
	      CurrentLineInFile = StackedIncludes[NumStackedIncludes].CurrentLineInFile;
	      HtmlOut = StackedIncludes[NumStackedIncludes].HtmlOut;
	      s[0] = 0;
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
		
      // Analyze the input line.  Is it an "include" directive?	
      if (s[0] == '$')
        {
	  ParseOutputRecord.ProgramCounter = ParseInputRecord.ProgramCounter;
	  ParseOutputRecord.Bank = ParseInputRecord.Bank;
	  // This is a directive to include another file.
	  if (WriteOutput)
	    printf ("%06d,%06d: %s", CurrentLineAll, CurrentLineInFile, s);
	  if (NumStackedIncludes == MAX_STACKED_INCLUDES)
	    {
	      printf ("Too many levels of include-files.\n");
	      fprintf (stderr, "%s:%d: Too many levels of include-files.\n", 
	      	       CurrentFilename, CurrentLineInFile);
	      goto Done;
	    }
	  StackedIncludes[NumStackedIncludes].InputFile = InputFile;
	  strcpy (StackedIncludes[NumStackedIncludes].InputFilename,
	  	  CurrentFilename);
	  StackedIncludes[NumStackedIncludes].CurrentLineInFile = CurrentLineInFile;
	  StackedIncludes[NumStackedIncludes].HtmlOut = HtmlOut;
	  NumStackedIncludes++;
	  if (1 != sscanf (s, "$%s", CurrentFilename))
	    {
	      printf ("Include-directive has no filename.\n");
	      fprintf (stderr, "%s:%d: Include-directive has no filename.\n", 
	      	       CurrentFilename, CurrentLineInFile);
	      goto Done;
	    }
	  if (WriteOutput && Html)
	    {
	      char *ss;
	      for (ss = s; *ss; ss++)
	        if (*ss == '\n')
		  {
		    *ss = 0;
		    break;
		  }
	      if (HtmlOut != NULL)
	        fprintf (HtmlOut, "%06d,%06d: <a href=\"%s\">%s</a><br>\n", 
			CurrentLineAll, CurrentLineInFile, NormalizeFilename (CurrentFilename), s);
	      HtmlCreate (CurrentFilename);
	      if (HtmlOut == NULL)
		goto Done;
	    }
	  InputFile = fopen (CurrentFilename, "r");
	  if (InputFile == NULL)
	    {
	      printf ("Include-file \"%s\" does not exist.\n", CurrentFilename);
	      fprintf (stderr, "%s:%d: Include-file does not exist.\n", 
	      	       CurrentFilename, CurrentLineInFile);
	      goto Done;
	    }	    
	  CurrentLineInFile = 0;
	  continue;
	} 
    
      // Find and remove the comment field, if any.
      for (ParseInputRecord.Comment = s; *ParseInputRecord.Comment && 
           *ParseInputRecord.Comment != COMMENT_SEPARATOR; ParseInputRecord.Comment++);
      if (*ParseInputRecord.Comment == '#')
        {
          *ParseInputRecord.Comment++ = 0;
	  // Trim the newline at the end:
	  for (ss = ParseInputRecord.Comment; *ss; ss++)
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
	    ParseInputRecord.Label = Fields[i++];
	  else if (IsFalseLabel (Fields[0]))
	    {
	      if (NumFields == 1 || (NULL == FindInterpreter (Fields[1]) && NULL == FindParser (Fields [1])))
	        goto NotOffset;
	      else	
	        ParseInputRecord.FalseLabel = Fields[i++];
	    }
	  iMatch = FindInterpreter (Fields[i]);
	  Match = FindParser (Fields[i]);
	  if (NumInterpretiveOperands && iMatch == NULL && Match == NULL)
	    ParseInputRecord.Operator = "";
	  else
	    {
	      if (Match != NULL && NumInterpretiveOperands &&
	          i + 1 >= NumFields)
		{
		  // This is to catch the annoying case where normal opcodes like 
		  // TC and and pseudo-ops like VN are actually data labels as well, 
		  // and are used as interpretive operands. We figure that if the 
		  // operator has no operand, then it must be a label instead.
	          Match = NULL;
		  ParseInputRecord.Operator = "";
		}
	      else if (Match != NULL && Match->PinchHit && NumInterpretiveOperands)
	        {
		  //if (i + 1 < NumFields && Fields[i + 1][0])
		    {
		      NumInterpretiveOperands--;
		      PinchHitting = 1;
		      if (i < NumFields)
			ParseInputRecord.Operator = Fields[i++];
		    }
		}
	      else 
	        {
  	          NumInterpretiveOperands = 0;
		  if (i < NumFields)
		    ParseInputRecord.Operator = Fields[i++];
		}
	    }
	NotOffset:    
	  if (i < NumFields)
	    ParseInputRecord.Operand = Fields[i++];
	  if (i < NumFields)
	    ParseInputRecord.Mod1 = Fields[i++];
	  if (i < NumFields)
	    ParseInputRecord.Mod2 = Fields[i++];
	  if (i < NumFields)
	    ParseInputRecord.Extra = Fields[i];
	}
	
      //if (!strcmp (ParseInputRecord.Label, "5FAILTAB") || !strcmp (ParseInputRecord.Label, "6FAILTAB"))
      //  printf ("****** %s *******\n", ParseInputRecord.Label);	
	
      // At this point, the input line has been completely parsed into
      // the fields Label, FalseLabel, Operator, Operand, Increment, 
      // and Comment.  Proceed with the analysis.
      if (*ParseInputRecord.Operator == 0 && !NumInterpretiveOperands)
        {
	  ParseOutputRecord.ProgramCounter = ParseInputRecord.ProgramCounter;
	  ParseOutputRecord.Bank = ParseInputRecord.Bank;
	  ParseOutputRecord.Extend = ParseInputRecord.Extend;
	  ParseOutputRecord.Bank = ParseInputRecord.Bank;
	  ParseOutputRecord.Index = ParseInputRecord.Index;
	  ParseOutputRecord.IndexValid = ParseInputRecord.IndexValid;
	}
      else	
        {
	  // Most aliases are included directly in the Parsers table.
	  // The NOOP alias is treated specially, because it aliases in
	  // two different ways, depending upon the location in memory.
	  if (!strcmp (ParseInputRecord.Operator, "NOOP") && !NumInterpretiveOperands)
	    {
	      if (0 != *ParseInputRecord.Operand)
	        {
		  strcpy (ParseOutputRecord.ErrorMessage, "Extra fields in line.");
		  ParseOutputRecord.Warning = 1;
		}
	      if (ParseInputRecord.ProgramCounter.Erasable)
	        {
		  ParseInputRecord.Operator = "CA";
		  ParseInputRecord.Operand = "A";
		}
	      else 
	        {
		  ParseInputRecord.Operator = "TCF";
		  ParseInputRecord.Operand = "+1";
		}
	      ParseInputRecord.Alias = "NOOP";
	    }
	AliasRetry:
	  // We treat the interpretive opcodes first (except for STCALL, STODL,
	  // STORE, and STOVL) separately, because they are more regular and
	  // don't follow the pattern of the other opcodes.
	  iMatch = FindInterpreter (ParseInputRecord.Operator);
	  if (iMatch != NULL)
	    {  
	      InterpreterMatch_t *iMatch2;
	      if (!strcmp (ParseInputRecord.Operator, "STADR") || !strcmp (ParseInputRecord.Operand, "STADR"))
	        StadrInvert = 2;
	      // We check to see if the opcode is an interpretive opcode.  
	      // If not, then we can fall through and process regular opcodes.
	      // If it is, there are two possibilities:  Either there is a
	      // single intepretive opcode, or else there are two (with the
	      // second being in the operand field).  We must also observe the
	      // number of operands required by the instructions, and then to
	      // increase NumInterpretive Operands by this amount.
	      NumInterpretiveOperands = 0;
	      // Look for a second one.
	      iMatch2 = NULL;
	      if (ParseInputRecord.Operand[0])
		{
		  iMatch2 = FindInterpreter (ParseInputRecord.Operand);
		  if (iMatch2 == NULL)
		    {
		      sprintf (ParseOutputRecord.ErrorMessage,
			      "Unrecognized interpretive opcode \"%s\".",
			      ParseInputRecord.Operand);
		      ParseOutputRecord.Fatal = 1;
		    }
		}
	      // At this point, iMatch should point to an interpretive
	      // opcode's type record, and iMatch2 will either be NULL
	      // or else point to one also.
	      NumInterpretiveOperands = 0;
	      if (iMatch->NumOperands)
	        {
		  SwitchIncrement[NumInterpretiveOperands] = iMatch->ArgTypes[0];
		  nnnnFields[NumInterpretiveOperands++] = iMatch->nnnn0000;
		  if (iMatch->NumOperands > 1)
		    {
		      SwitchIncrement[NumInterpretiveOperands] = iMatch->ArgTypes[1];
		      nnnnFields[NumInterpretiveOperands++] = 0;
		    }
		}
	      if (iMatch2 != NULL)
	        {
		  if (iMatch2->NumOperands)
		    {
		      SwitchIncrement[NumInterpretiveOperands] = iMatch2->ArgTypes[0];
		      nnnnFields[NumInterpretiveOperands++] = iMatch2->nnnn0000;
		      if (iMatch2->NumOperands > 1)
			{
			  SwitchIncrement[NumInterpretiveOperands] = iMatch2->ArgTypes[1];
			  nnnnFields[NumInterpretiveOperands++] = 0;
			}
		    }
		}  
	      RawNumInterpretiveOperands = NumInterpretiveOperands;	
	      ParseOutputRecord.NumWords = 1;
	      ParseOutputRecord.Words[0] = (0177 & (iMatch->Code + 1));      
	      if (NULL != iMatch2)
		ParseOutputRecord.Words[0] |= (037600 & ((iMatch2->Code + 1) << 7));
	      ParseOutputRecord.Words[0] = (077777 & ~ParseOutputRecord.Words[0]);
	      IncPc (&ParseInputRecord.ProgramCounter, ParseOutputRecord.NumWords, 
		     &ParseOutputRecord.ProgramCounter);
	      ParseOutputRecord.Bank = ParseInputRecord.Bank;
	      //UpdateBankCounts (&ParseOutputRecord.ProgramCounter);
	      goto WriteDoIt; 
	    }
	  else if (NumInterpretiveOperands && !PinchHitting)
	    {
	      // In this case, we need to find an operand for an interpretive
	      // opcode.  This will be either a label, or else a label with an
	      // offset.  Having found such an argument, we need to decrement
	      // NumInterpretiveOperands.
	      if (*ParseInputRecord.Operator == 0 && *ParseInputRecord.Operand == 0)
	        {
		  ParseOutputRecord.Words[0] = 0;
		  ParseOutputRecord.ProgramCounter = ParseInputRecord.ProgramCounter;
		  ParseOutputRecord.Bank = ParseInputRecord.Bank;
		  goto WriteDoIt;
		}
	      else if (*ParseInputRecord.Operator == 0 && *ParseInputRecord.Operand != 0)
	        {
		  ParseOutputRecord.NumWords = 1;
		  ParseInterpretiveOperand (&ParseInputRecord, &ParseOutputRecord);
		  //ParseOutputRecord.Words[0] = AddAgc (ParseOutputRecord.Words[0], OpcodeOffset);
		  NumInterpretiveOperands--;
		  IncPc (&ParseInputRecord.ProgramCounter, ParseOutputRecord.NumWords, 
			 &ParseOutputRecord.ProgramCounter);
		  ParseOutputRecord.Bank = ParseInputRecord.Bank;
		  //UpdateBankCounts (&ParseOutputRecord.ProgramCounter);
		  goto WriteDoIt;
		}
	      else
	        {
		  sprintf (ParseOutputRecord.ErrorMessage,
			  "Missing interpretive operands.");
		  ParseOutputRecord.Fatal = 1;
		  ParseOutputRecord.NumWords = 1;
		  ParseOutputRecord.Words[0] = 0;
		  NumInterpretiveOperands = 0;
		  IncPc (&ParseInputRecord.ProgramCounter, ParseOutputRecord.NumWords, 
			 &ParseOutputRecord.ProgramCounter);
		  ParseOutputRecord.Bank = ParseInputRecord.Bank;
		  //UpdateBankCounts (&ParseOutputRecord.ProgramCounter);
		  goto WriteDoIt;
		}
	    }  
	  // Now try regular opcodes.
	  Match = FindParser (ParseInputRecord.Operator);
	  if (Match == NULL)
	    {
	      int NumOperator;
	      // Check for the special case of a number simply being used in place 
	      // of the operator.
	      if (!GetOctOrDec (ParseInputRecord.Operator, &NumOperator))
	        {
		  extern int ParseGeneral (ParseInput_t *, ParseOutput_t *, int, int);
		  ParseGeneral (&ParseInputRecord, &ParseOutputRecord, NumOperator << 12, 0);
		  ParseOutputRecord.Words[0] = AddAgc (ParseOutputRecord.Words[0], OpcodeOffset);
		  ParseOutputRecord.Bank.OneshotPending = 0;
		  goto WriteDoIt;
		}
	      // Okay, nothing works.
	      ParseOutputRecord.ProgramCounter = ParseInputRecord.ProgramCounter;
	      ParseOutputRecord.Bank = ParseInputRecord.Bank;
	      sprintf (ParseOutputRecord.ErrorMessage,
	               "Unrecognized opcode/pseudo-op \"%s\".",
		       ParseInputRecord.Operator);
	      ParseOutputRecord.Fatal = 1;	   
	      // The following is just an approximation.  Since almost every
	      // operator produces a single word of output, it is more accurate
	      // to ASSUME this rather than not to advance the program counter.    
              IncPc (&ParseInputRecord.ProgramCounter, 1, &ParseOutputRecord.ProgramCounter);
	    }
	  else
	    {
	      if (Match->Parser == NULL && 0 == *Match->AliasOperator)
	        {
		  // This is the way we have marked operators we simply wish
		  // to silently discard.
		  ParseOutputRecord.ProgramCounter = ParseInputRecord.ProgramCounter;
		}
	      else if (Match->Parser == NULL)
		{
		
		  if (*ParseInputRecord.Operand != 0)
		    {
		      strcpy (ParseOutputRecord.ErrorMessage, "Extra fields are present.");
		      ParseOutputRecord.Warning = 1;
		    }
		  ParseInputRecord.Alias = ParseInputRecord.Operator;
		  ParseInputRecord.Operator = Match->AliasOperator;
		  ParseInputRecord.Operand = Match->AliasOperand;
		  ParseInputRecord.Mod1 = ParseInputRecord.Mod2 = "";
		  goto AliasRetry;
		}
	      else
	        {
		  int i;
		  (*Match->Parser) (&ParseInputRecord, &ParseOutputRecord);
		  i = ParseOutputRecord.Words[0];
		  ParseOutputRecord.Words[0] = AddAgc (ParseOutputRecord.Words[0], OpcodeOffset);
		  if ((ParseOutputRecord.Words[0] & 040000) && !(i & 040000))
		    ParseOutputRecord.Words[0]--;
		  ParseOutputRecord.Words[0] = (ParseOutputRecord.Words[0] +
		  			        Match->Adder) ^ Match->XMask;
		  ParseOutputRecord.Words[1] = (ParseOutputRecord.Words[1] +
		  			        Match->Adder2) ^ Match->XMask2;
		  /*
		  if (ParseInputRecord.Bank.OneshotPending &&
		      (Match->Parser == ParseBBCON ||
		       Match->Parser == Parse2CADR))
		    {
		      ParseOutputRecord.Bank.CurrentEBank = ParseInputRecord.Bank.LastEBank;
		    }
		  */
		  if (Match->Parser != &ParseEBANK)
		    ParseOutputRecord.Bank.OneshotPending = 0;
		  //UpdateBankCounts (&ParseOutputRecord.ProgramCounter);
		}
	    }  
	}
    WriteDoIt:
      if (StadrInvert && ParseOutputRecord.NumWords > 0)
        {
	  if (StadrInvert == 1)
	    ParseOutputRecord.Words[0] = 077777 & ~ParseOutputRecord.Words[0];
	  StadrInvert--;
	}
        
      UpdateBankCounts (&ParseOutputRecord.ProgramCounter);

      // If there is a label, and if this isn't `=' or `EQUALS', then
      // the value of the label is the current address.
      if (*ParseInputRecord.Label != 0 && !ParseOutputRecord.Equals && 
          strcmp (ParseInputRecord.Operator, "MEMORY")
          /* (ParseOutputRecord.NumWords > 0 || 
	  !strcmp (ParseInputRecord.Operator, "ERASE")) */ )
	{
	  int Type = SYMBOL_LABEL;
	  
	  // JMS: This seems to capture two cases: labels which are used
	  // to denote program line numbers, and constants which really hold
	  // the memory location. If the operator is ERASE/OCT/DEC/DEC*/2DEC
	  // or 2DEC*, then the symbol is already an embedded constant so
	  // we will treat it as variable
	  //EditSymbol (ParseInputRecord.Label, &ParseInputRecord.ProgramCounter);
	  if (IsEmbeddedConstant(ParseInputRecord.Operator))
	    {
	      Type = SYMBOL_VARIABLE;
	    }
	  
	  EditSymbolNew (ParseInputRecord.Label, &ParseInputRecord.ProgramCounter,
			 Type, CurrentFilename, CurrentLineInFile);
	}

      // Write the output.	
      if (WriteOutput && !IncludeDirective)
        {
	  char *Suffix;
	  
	  // If doing HTML output, need to put an anchor here if the line has a label
	  // or is a definition of a variable or constant.
	  if (HtmlOut != NULL && *ParseInputRecord.Label != 0)
	    fprintf (HtmlOut, "<a name=\"%s\"></a>", 
	    	     NormalizeAnchor (ParseInputRecord.Label));

	  if (*ParseInputRecord.Alias != 0)
	    {
	      ParseInputRecord.Operator = ParseInputRecord.Alias;
	      ParseInputRecord.Operand = "";
	    }
 	  if (ParseOutputRecord.Fatal)
	    {
	      printf ("Fatal Error:  %s\n", ParseOutputRecord.ErrorMessage);
	      if (HtmlOut != NULL)
	        fprintf (HtmlOut,
			 COLOR_FATAL "Fatal Error:  %s</span><br>\n", 
			 ParseOutputRecord.ErrorMessage);
	      fprintf (stderr, "%s:%d: Fatal: %s\n", 
	      	       CurrentFilename, CurrentLineInFile, ParseOutputRecord.ErrorMessage);
	      (*Fatals)++;
	    }
	  else if (ParseOutputRecord.Warning)  
	    {
	      printf ("Warning:  %s\n", ParseOutputRecord.ErrorMessage);
	      if (HtmlOut != NULL)
	        fprintf (HtmlOut,
			 COLOR_WARNING "Warning:  %s</span><br>\n", 
			 ParseOutputRecord.ErrorMessage);
	      fprintf (stderr, "%s:%d: Warning: %s\n", 
	      	       CurrentFilename, CurrentLineInFile, ParseOutputRecord.ErrorMessage);
	      (*Warnings)++;
	    }
	  printf ("%06d,%06d: ", CurrentLineAll, CurrentLineInFile); 
	  if (HtmlOut != NULL)
	    fprintf (HtmlOut, "%06d,%06d:&nbsp;", CurrentLineAll, CurrentLineInFile);
	  if (*ParseInputRecord.Label != 0 ||
	      *ParseInputRecord.FalseLabel != 0 ||
	      *ParseInputRecord.Operator != 0 ||
	      *ParseInputRecord.Operand != 0 ||
	      *ParseInputRecord.Comment != 0)
	    {    
	      if (*ParseInputRecord.Label != 0 ||
		  *ParseInputRecord.FalseLabel != 0 ||
		  *ParseInputRecord.Operator != 0 ||
		  *ParseInputRecord.Operand != 0)
	        {
		  AddressPrint (&ParseInputRecord.ProgramCounter);
		}
	      else
	        {
	          printf ("         ");	
		  if (HtmlOut != NULL)
		    fprintf (HtmlOut, "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;");
		}
	      if (ParseOutputRecord.LabelValueValid)
		{
		  AddressPrint (&ParseOutputRecord.LabelValue);
		  //printf ("%06o  ", ParseOutputRecord.LabelValue);
		}
	      else
	        {
		  printf ("         ");  
		  if (HtmlOut != NULL)
		    fprintf (HtmlOut, "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;");
		}
	      if (ParseOutputRecord.NumWords > 0)
		{
		  if (ParseOutputRecord.Words[0] == ILLEGAL_SYMBOL_VALUE)
		    {
		      printf ("????? ");
		      if (HtmlOut != NULL)
		        fprintf (HtmlOut, "?????&nbsp;");
		    }
		  else	
		    {
		      printf ("%05o ", ParseOutputRecord.Words[0] & 077777);
		      if (HtmlOut != NULL)
		        fprintf (HtmlOut, "%05o&nbsp;", ParseOutputRecord.Words[0] & 077777);
		      // Write the binary.
		      if (!ParseInputRecord.ProgramCounter.Invalid &&
		      	  ParseInputRecord.ProgramCounter.Address &&
			  ParseInputRecord.ProgramCounter.Fixed)
		        {
			  int Bank;
			  if (ParseInputRecord.ProgramCounter.Banked)
			    {
			      Bank = ParseInputRecord.ProgramCounter.FB;
			      if (Bank >= 020 && ParseInputRecord.ProgramCounter.Super)
			        Bank += 010;
			    }
			  else
			    Bank = ParseInputRecord.ProgramCounter.SReg / 02000;
			  for (i = 0; i < ParseOutputRecord.NumWords; i++)
			    {  
			      ObjectCode[Bank][(ParseInputRecord.ProgramCounter.SReg + i) & 01777] = 
				ParseOutputRecord.Words[i] & 077777;
			    }

			  // JMS: 07.28
			  // When we place the object code in the buffer, we'll add it to the
			  // line table. We assume there are no duplicates here nor do we
			  // check. We will remove duplicates when sorting at the end.
			  AddLine (&ParseInputRecord.ProgramCounter, CurrentFilename,
				   CurrentLineInFile);

			}
		    }
		}
	      else
	        {
		  printf ("      ");  
		  if (HtmlOut != NULL)
		    fprintf (HtmlOut, "%s", NormalizeStringN ("", 6));
		}
	      if (ParseOutputRecord.NumWords > 1)
		{
		  if (ParseOutputRecord.Words[1] == ILLEGAL_SYMBOL_VALUE)
		    {
		      printf ("????? ");
		      if (HtmlOut != NULL)
		        fprintf (HtmlOut, "?????&nbsp");
		    }
		  else	
		    {
		      printf ("%05o ", ParseOutputRecord.Words[1] & 077777);
		      if (HtmlOut != NULL)
		        fprintf (HtmlOut, "%05o&nbsp;", ParseOutputRecord.Words[1] & 077777);
		    }
		}
	      else
	        {
		  printf ("      "); 
		  if (HtmlOut != NULL)
		    fprintf (HtmlOut, "%s", NormalizeStringN ("", 6)); 
		}
	      if (ArgType == 1)
	        Suffix = ",1";
	      else if (ArgType == 2)
	        Suffix = ",2";
	      else
	        Suffix = "";
	      if (*Suffix)
	        {
		  if (*ParseInputRecord.Mod1)
		    strcat (ParseInputRecord.Mod1, Suffix);
		  else if (*ParseInputRecord.Operand)
		    strcat (ParseInputRecord.Operand, Suffix);	
		}
	      printf (" %-8s %-8s %-8s %-10s %-10s %-8s\t# %s",
		      ParseInputRecord.Label, 
		      ParseInputRecord.FalseLabel, 
		      ParseInputRecord.Operator, 
		      ParseInputRecord.Operand, 
		      ParseInputRecord.Mod1,
		      ParseInputRecord.Mod2, 
		      ParseInputRecord.Comment);
	      if (HtmlOut != NULL)
	        {
		  Symbol_t *Symbol;
		  int Comma = 0, Dollar = 0, n;
		  if (*ParseInputRecord.Label == 0)
		    fprintf (HtmlOut, "&nbsp;%s&nbsp;", NormalizeStringN (ParseInputRecord.Label, 8));
		  else
		    fprintf (HtmlOut, 
			     "&nbsp;" COLOR_SYMBOL "%s</span>&nbsp;", 
			     NormalizeStringN (ParseInputRecord.Label, 8));
		  fprintf (HtmlOut, "%s&nbsp;", NormalizeStringN (ParseInputRecord.FalseLabel, 8));
		  // The Operator could be an interpretive instruction, a basic opcode,
		  // a pseudo-op, or a downlink code, and we want to colorize them 
		  // differently in those cases.
		  Match = NULL;
		  iMatch = FindInterpreter (ParseInputRecord.Operator);
		  if (iMatch != NULL)
		    fprintf (HtmlOut, COLOR_INTERPRET);
		  else
		    {
		      Match = FindParser (ParseInputRecord.Operator);
		      if (Match != NULL)
		        {
			  if (Match->OpType == OP_DOWNLINK)
			    fprintf (HtmlOut, COLOR_DOWNLINK);
			  else if (Match->OpType == OP_PSEUDO)
		            fprintf (HtmlOut, COLOR_PSEUDO);
			  else if (Match->OpType == OP_INTERPRETER)
		            fprintf (HtmlOut, COLOR_INTERPRET);
			  else
		            fprintf (HtmlOut, COLOR_BASIC);
			}
		      else if (!strcmp (ParseInputRecord.Operator, "NOOP"))
		        {
			  Match = FindParser ("CAF");
			  fprintf (HtmlOut, COLOR_BASIC);
			}
		    }
		  fprintf (HtmlOut, "%s", NormalizeStringN (ParseInputRecord.Operator, 8));
		  if (iMatch != NULL || Match != NULL)
		    fprintf (HtmlOut, "</span>");
		  fprintf (HtmlOut, "&nbsp;");
		  // Detecting a symbol here is a little tricky, since if used for
		  // the interpreter there may be a suffixed ",1" or ",2" which we
		  // have to detect and account for.  Or, for the COUNT* pseudo-op,
		  // may have a prefixed "$$/".
		  Symbol = GetSymbol (ParseInputRecord.Operand);
		  n = strlen (ParseInputRecord.Operand);
		  if (Symbol == NULL)
		    {
		      if (n > 2 && ParseInputRecord.Operand[n - 2] == ',' &&
		          (ParseInputRecord.Operand[n - 1] == '1' || ParseInputRecord.Operand[n - 1] == '2'))
		        {
			  ParseInputRecord.Operand[n - 2] = 0;
			  Symbol = GetSymbol (ParseInputRecord.Operand);
			  ParseInputRecord.Operand[n - 2] = ',';
			  if (Symbol != NULL)
			    {
			      Comma = 1;
			      goto FoundComma;
			    }
			}
		      if (!strncmp (ParseInputRecord.Operand, "$$/", 3))
		        {
			  Symbol = GetSymbol (&ParseInputRecord.Operand[3]);
			  if (Symbol != NULL)
			    {
			      Dollar = 3;
			      goto FoundComma;
			    }
			}
		      // Well, it's not a variable or label match.  It could still be an 
		      // interpreter opcode.
		      j = IsInterpretive (ParseInputRecord.Operand);
		      if (j)
		        fprintf (HtmlOut, COLOR_INTERPRET);
		      fprintf (HtmlOut, "%s", NormalizeStringN (ParseInputRecord.Operand, 10));
		      if (j)
		        fprintf (HtmlOut, "</span>");
		      fprintf (HtmlOut, "&nbsp;");
		    }
		  else
		    {
		    FoundComma:
		      if (Dollar)
		        fprintf (HtmlOut, "$$/");
		      fprintf (HtmlOut, "<a href=\"%s", NormalizeFilename (Symbol->FileName));
		      if (Comma)
		        ParseInputRecord.Operand[n - 2] = 0;
		      fprintf (HtmlOut, "#%s\">", NormalizeAnchor (&ParseInputRecord.Operand[Dollar]));
		      fprintf (HtmlOut, "%s</a>", NormalizeString (&ParseInputRecord.Operand[Dollar]));
		      if (Comma)
		        {
		          ParseInputRecord.Operand[n - 2] = ',';
			  fprintf (HtmlOut, "%s", &ParseInputRecord.Operand[n - 2]);
			}
		      fprintf (HtmlOut, "&nbsp;");
		      for (i = n; i < 10; i++)
		        fprintf (HtmlOut, "&nbsp;");
		    }
		  fprintf (HtmlOut, "%s&nbsp;", NormalizeStringN (ParseInputRecord.Mod1, 10));
		  fprintf (HtmlOut, "%s", NormalizeStringN (ParseInputRecord.Mod2, 8));
		  fprintf (HtmlOut, "%s", NormalizeStringN ("", 8));
		  if (*ParseInputRecord.Comment)
		    fprintf (HtmlOut, "<i>#&nbsp;%s</i>", NormalizeString (ParseInputRecord.Comment));
		};
	    }
	  printf ("\n");  
	  if (HtmlOut != NULL)
	    fprintf (HtmlOut, "<br>\n");
          //printf ("Super=%o\n", ParseOutputRecord.Bank.CurrentSBank.Super);
	}		
      		
    }

  // Done with this pass.
  RetVal = 0;
Done:  
  if (InputFile != NULL)
    fclose (InputFile);
  for (i = 0; i < NumStackedIncludes; i++)
    fclose (StackedIncludes[i].InputFile); 
  NumStackedIncludes = 0; 
  return (RetVal);
}

  

