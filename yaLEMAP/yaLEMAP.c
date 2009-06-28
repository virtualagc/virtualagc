/*
  Copyright 2005,2009 Ronald S. Burkey <info@sandroid.org>

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

  Filename:	yaLEMAP.c
  Purpose:	Cross-assembler for Abort Guidance System
  		(AGS) source code.
  Compiler:	GNU gcc.
  Reference:	http://www.ibibio.org/apollo
  Mode:		2005-01-11 RSB.	Began.  Some machinery adapted 
  				from binLEMAP.c.
		2005-01-13 RSB	Seemingly working, for the sample code.
				I know that the flight code has a few
				features I haven't accounted for yet.
		2005-01-18 RSB	Printout columns hopefully aligned better.
				Fixed OCT, I hope. Changed checksums
				to allow multiple checksum regions.
		2005-01-19 RSB	The binLEMAP-compatible file 
				yaLEMAP.binsource is now output.
				This is to aid proofing by feeding
				that file back into a text-to-speech
				converter.
		2005-01-24 RSB	Fixed some of the field alignments in the
				output listing file.  Also, got rid of
				leading zeroes in the output binsource
				file.	
		2005-04-30 RSB	PrintSymbolsToFile has been renamed
				PrintSymbolsToFileL in order to avoid
				some build-time warnings..
		2005-08-02 JMS  Write out the symbol table to a file.
		                This format of the symbol table is the
				same as yaYUL.
		2009-03-17 RSB	Make sure that no .bin or .symtab file 
				is produced when there is an error.
		2009-06-28 RSB	Added HtmlOut ... just as an allocation,
				not as anything functional yet.
				
  Note that we use yaYUL's symbol-table machinery for handling the
  symbol table.
*/

#include "../yaYUL/yaYUL.h"

#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include <math.h>

#define MEMSIZE 010000
static int Memory[MEMSIZE], Valid[MEMSIZE];
static char s[1000], sd[1000];
static int ErrCount, WarnCount;
static char *Comment, Label[1000], Operator[1000], Variables[1000];
static char *FileSelected = NULL;
static int Lines;
static FILE *Lst;
FILE *HtmlOut = NULL;

#define MAX_CHECKSUM_REGIONS 16
typedef struct {
  int Start, Stop, Store, Sum;
} ChecksumRegion_t;
static ChecksumRegion_t ChecksumRegions[MAX_CHECKSUM_REGIONS];
static int NumChecksumRegions = 0;

//------------------------------------------------------------------------

static void
ErrorMsg (char *Msg)
{
  ErrCount++;
  fprintf (Lst, "*** Error *** %s\n", Msg);
  fprintf (stderr, "%s:%d: Error: %s\n", FileSelected, Lines, Msg);
}

static void
WarningMsg (char *Msg)
{
  WarnCount++;
  fprintf (Lst, "*** Warning *** %s\n", Msg);
  fprintf (stderr, "%s:%d: Warning: %s\n", FileSelected, Lines, Msg);
}

static void
Msg (char *Msg)
{
  fprintf (Lst, "%s\n", Msg);
  fprintf (stderr, "%s\n", Msg);
}

#if 0

//------------------------------------------------------------------------
// Is the character something that can appear in a label?  0 if no, 
// non-zero if yes.

static int
IsLabelSym (char c)
{
  if (c == '+' || c == '-' || c == '/' || c == '*' ||
      c == '$' || c == '=' || c == ',')
    return (0);
  return (1);
}

#endif // 0

//------------------------------------------------------------------------
// Print an Address_t record.  Returns 0 on success, non-zero on error.

int
AddressPrint (Address_t *Address)
{
  if (Address->Invalid)
    fprintf (Lst, "????\t"); 
  else if (Address->Constant)
    {
      fprintf (Lst, "%04o\t", Address->Value & 07777);
    }  
  else if (Address->Address)
    fprintf (Lst, "%04o\t", Address->SReg & 07777);
  else
    {
      fprintf (Lst, "int-err ");
      return (1);  
    } 
  return (0);   
}

//------------------------------------------------------------------------
// Print the symbol table.

static void
PrintSymbolsToFileL (FILE *fp)
{
  extern Symbol_t *SymbolTable;
  extern int SymbolTableSize;
  int i;
  fprintf (fp, "Symbol Table\n"
          "------------\n");
  for (i = 0; i < SymbolTableSize; i++)
    {
      if (!(i & 3) && i != 0)
        fprintf (fp, "\n");
      fprintf (fp, "%6d: %-*s ", i + 1, MAX_LABEL_LENGTH, SymbolTable[i].Name);
      AddressPrint (&SymbolTable[i].Value);
      if (3 != (i & 3))
        fprintf (fp, "\t");
    }
  fprintf (fp, "\n");  
}

//------------------------------------------------------------------------
// For printing variable and comment fields.

static void
PrintComments (int i)
{
  if (Comment != NULL && Comment[0] != 0)
    {
      if (i < 16)
	i = 16 - i;
      else
	i = 1;
      fprintf (Lst, "%*s# %s", i, "", Comment);
    }
  fprintf (Lst, "\n");
}

static void
PrintVariablesAndComments (void)
{
  int i;
  i = fprintf (Lst, "%s", Variables);
  PrintComments (i);
}

//------------------------------------------------------------------
// Evaluates a decimal number, with decimal point, 'B' and 'E' 
// modifiers.  Returns 0 on success, non-zero otherwise.

static int
EvaluateDecimal (char *s, Address_t *Address)
{
  int Sign, Bn, En, i, RetVal = 0;
  unsigned long Integer, Numerator, Denominator;
  double Value;
  
  // Take care of optional sign.
  Sign = 1;
  if (*s == '+')
    s++;
  else if (*s == '-')
    {
      Sign = -1;
      s++;
    }
    
  // Take care of optional integer portion.
  Integer = 0;
  for (; *s >= '0' && *s <= '9'; s++)
    Integer = *s - '0' + (Integer * 10);
  if (*s != '.' && *s != 'B' && *s != 'E')
    {
      i = Integer;
      goto Done;
    }
    
  // Take care of optional decimal point and fraction.
  Numerator = 0;
  Denominator = 1;
  if (*s == '.')
    {
      for (s++; *s >= '0' && *s <= '9'; s++)
        {
          Numerator = *s - '0' + 10 * Numerator;
	  Denominator *= 10;
	}
    }
   
  // Take care of optional 'B' and 'E' thingies. 
  if (0 < (i = sscanf (s, "B%dE%d", &Bn, &En)))
    {
      if (i == 1)
        En = 0;
    }
  else if (2 == sscanf (s, "E%dB%d", &En, &Bn))
    ;
  else
    {
      ErrorMsg ("Missing binary point.");
      i = 0;
      goto Done;
    }
    
  // Now put it all together.
  Value = Integer + (Numerator * 1.0) / Denominator;
  Value *= pow (10.0, En) * pow (2.0, 17 - Bn);
  i = Value + 0.5;
  
Done:
  if (i > 0377777)
    {
      i = 0;
      RetVal = 1;
    }
  i *= Sign;
  
  Address->Invalid = 0;
  Address->Address = 0;
  Address->Constant = 1;
  Address->Value = i;
  return (RetVal);
}

//------------------------------------------------------------------
// Evaluates an octal number. Returns 0 on success, non-zero otherwise.

static int
EvaluateOctal (char *s, Address_t *Address)
{
  int i, RetVal = 0;
  
  if (1 != sscanf (s, "%o", &i))
    {
      ErrorMsg ("Not an octal value.");
      RetVal++;
      i = 0;
    }
  else
    {
      for (; *s && *s != ','; s++)
        if (*s < '0' || *s > '7')
	  {
	    ErrorMsg ("Non-octal digits in variable field.");
	    RetVal++;
	    break;
	  }
    }
    
  Address->Invalid = 0;
  Address->Address = 0;
  Address->Constant = 1;
  Address->Value = i;
  return (RetVal);
}

//------------------------------------------------------------------
// Evaluates an expression involving any combination of Labels,
// constants, +, and -.  Returns 0 on success, non-zero error
// code otherwise.  ForceOctal is interpreted as follows:
//	-1	Force decimal.
//	0	Auto-interpret as decimal or octal
//	1	Force octal.

// **** This function needs to have more checking of stuff, such
// as valid characters in labels ****.

static int
EvaluateExpression (char *Expression, Address_t *Address, int Location, int ForceOctal)
{
  int NumAddresses = 0, Value = 0, Sign, i, j, RetVal = 0;
  char *s, *ss, *sss, Operator;
  Symbol_t *Symbol;

  //if (ForceOctal == -1)
  //  return (EvaluateDecimal (Expression, Address));

  s = Expression;
  while (1)
    {
      if (*s == 0 || *s == ',')
        break;
      // Take care of Operator.
      Sign = 1;
      if (*s == '+')
        s++;
      else if (*s == '-')
        {
	  Sign = -1;
          s++;	
	}
      // Pick off next number or label.
      for (ss = s + 1; *ss && *ss != ',' && *ss != '-' && *ss != '+'; ss++);
      Operator = *ss;
      *ss = 0;
      // Is this a number or a label?
      for (sss = s; *sss; sss++)
        if (!isdigit (*sss))
	  break;
      if (*sss == 0)
        {
	  // A number.
	  if (ForceOctal == -1 || (sss - s <= 3 && ForceOctal != 1))
	    {
	      // Decimal.
	      sscanf (s, "%d", &i);
	      Value += i * Sign;
	    }
	  else
	    {
	      // Octal.
	      i = 0;
	      if (1 != sscanf (s, "%o%d", &i, &j))
	        RetVal = 1;
	      Value += i * Sign;
	    }  
	}
      else if (*s == '*')
        {
	  Value += Location * Sign;
	}
      else
        {
	  // A symbol.
	  Symbol = GetSymbol (s);
	  if (Symbol == NULL || Symbol->Value.Invalid)
	    {
	      Address->Invalid = 1;
	      Address->Constant = Address->Address = 0;
	      RetVal = 2;
	      break;
	    }
	  if (Symbol->Value.Constant)
	    Value += Symbol->Value.Value * Sign;
	  else if (Symbol->Value.Address)
	    {
	      Value += Symbol->Value.SReg * Sign;
	      NumAddresses += Sign;
	    }
	}
      // Advance.
      *ss = Operator;
      s = ss;	
    }
  if (RetVal)
    {
      Address->Invalid = 1;
      Address->Constant = Address->Address = 0;
    }
  else
    {
      Address->Invalid = 0;
      if (NumAddresses == 1)
        {
	  Address->Address = 1;
	  Address->Constant = 0;
	  Address->SReg = Value;
	}
      else	
	{
	  Address->Constant = 1;
	  Address->Address = 0;
	  Address->Value = Value;
	}
    }
  return (RetVal);
}

//------------------------------------------------------------------
// Returns the number of unresolved symbols on the pass.  The 
// total number of errors on the pass is written to the global
// variable ErrCount.  The input value of Action modifies the
// behavior in the following ways:
//	Action = -1	Merely add symbols to the symbol table.
//	Action = 0	Try to resolve symbols.
// 	Action = 1	Finish up and write the assembly listing.

static int
PassLemap (FILE *fp, int Action)
{
  int Location = 0, i, j, Extra, Missing;
  char *ss;
  Address_t Address = { 0 }, LineAddress = { 0 };
  FILE *SingAlong;

  Lines = 0;
  rewind (fp);
  ErrCount = WarnCount = 0;
  if (Action == 1)
    SingAlong = fopen ("yaLEMAP.binsource", "w");
  else
    SingAlong = NULL;

  while (NULL != fgets (s, sizeof (s) - 1, fp))
    {
      Lines++;

      // Eliminate the newline.
      Comment = NULL;
      for (ss = s; *ss; ss++)
        if (*ss == '#' && Comment == NULL)
	  Comment = ss;
	else if (*ss == '\n')
	  {
	    *ss = 0;
	    break;
	  }
	else
	  *ss = toupper (*ss);

      // Eliminate comments.
      if (Comment != NULL)
        {
	  *Comment = 0;
	  Comment++;
	  if (*Comment == ' ')
	    Comment++;
	}

      // Parse the line into fields.
      Label[0] = Operator[0] = Variables[0] = 0;
      Extra = Missing = 0;
      if (!s[0])
        ;
      else if (!isspace (s[0]))
        {
          i = sscanf (s, "%s%s%s%s", Label, Operator, Variables, sd);
	  if (i == 4)
	    Extra = 1;
	  else if (i == 2 && strcmp (Operator, "END"))
	    Missing = 1;
	}
      else
        {
          i = sscanf (s, "%s%s%s", Operator, Variables, sd);
	  if (i == 3)
	    Extra = 1;
	  else if (i == 1 && strcmp (Operator, "END"))
	    Missing = 1;
	}
	
      // Labels are identified but not resolved on the first pass.
      if (Action == -1)
        {
	  if (Label[0])
	    AddSymbol (Label);
	  continue;
	} 
	
      // In the mid pass (0) all we are trying to do is to resolve
      // label values.  All legal instructions (and unknown 
      // instructions) have the effect of bumping the location 
      // counter by 1.  Therefore, all we really need to know how
      // to do is to interpret the pseudo-ops that do something
      // else.  These are:
      //	ORG
      //	EQU or SYN
      //	DEFINE
      //	BES
      //	BSS
      //	DEC
      //	OCT
      //	END 
      //	... and of course, blank lines.
      if (Action == 0)
        {
	  if (Operator[0] == 0 || !strcmp (Operator, "END"))
	    {
	      // These do nothing to the location counter.
	    }
	  else if (!strcmp (Operator, "EQU") ||
	           !strcmp (Operator, "SYN"))
	    {
	      if (Label[0] != 0)
	        {
		  EvaluateExpression (Variables, &Address, Location, 0);
		  EditSymbolNew (Label, &Address, SYMBOL_CONSTANT, FileSelected, Lines);
	        }
	    }
	  else if (!strcmp (Operator, "DEFINE"))
	    {
	      if (Label[0] != 0)
	        {
		  EvaluateExpression (Variables, &Address, Location, 1);
		  EditSymbolNew (Label, &Address, SYMBOL_CONSTANT, FileSelected, Lines);
	        }
	    }
	  else if (!strcmp (Operator, "DEC") ||
	  	   !strcmp (Operator, "OCT"))
	    {
	      if (Label[0] != 0)
	        {
		  Address.Invalid = 0;
		  Address.Constant = 0;
		  Address.Address = 1;
		  Address.SReg = Location;
		  EditSymbolNew (Label, &Address, SYMBOL_VARIABLE, FileSelected, Lines);
	        }
	      // All we need to do here is to know the number
	      // of commas in the Variables field, and 
	      // advance the location counter by one more than
	      // that.
	      for (Location++, ss = Variables; *ss; ss++)
	        if (*ss == ',')
		  Location++;
	    }
	  else if (!strcmp (Operator, "ORG"))
	    {
	      EvaluateExpression (Variables, &Address, Location, 1);
	      if (Address.Constant)
	        Location = Address.Value;
	      else if (Address.Address)
	        Location = Address.Address;
	      if (Label[0] != 0)
	        {
		  Address.Invalid = 0;
		  Address.Constant = 0;
		  Address.Address = 1;
		  Address.SReg = Location;
		  EditSymbolNew (Label, &Address, SYMBOL_LABEL, FileSelected, Lines);
	        }
	    }
	  else if (!strcmp (Operator, "BES"))
	    {
	      EvaluateExpression (Variables, &Address, Location, 0);
	      if (Address.Constant)
	        Location += Address.Value;
	      else if (Address.Address)
	        Location += Address.Address;
	      if (Label[0] != 0)
	        {
		  Address.Invalid = 0;
		  Address.Constant = 0;
		  Address.Address = 1;
		  Address.SReg = Location;
		  EditSymbolNew (Label, &Address, SYMBOL_LABEL, FileSelected, Lines);
	        }
	    }
	  else if (!strcmp (Operator, "BSS"))
	    {
	      if (Label[0] != 0)
	        {
		  Address.Invalid = 0;
		  Address.Constant = 0;
		  Address.Address = 1;
		  Address.SReg = Location;
		  EditSymbolNew (Label, &Address, SYMBOL_LABEL, FileSelected, Lines);
	        }
	      EvaluateExpression (Variables, &Address, Location, 0);
	      if (Address.Constant)
	        Location += Address.Value;
	      else if (Address.Address)
	        Location += Address.Address;
	    }    
	  else
	    {
	      if (Label[0] != 0)
	        {
		  Address.Invalid = 0;
		  Address.Constant = 0;
		  Address.Address = 1;
		  Address.SReg = Location;
		  EditSymbolNew (Label, &Address, SYMBOL_LABEL, FileSelected, Lines);
	        }
	      Location++;
	      Location &= 07777;
	    }  
	  continue;
	}
      
      // Here is the final pass, in which the assembly listing
      // and binaries are produced.  We don't need to attempt to 
      // resolve symbols any longer, since we already know that
      // they're either all resolved or else that we're not going
      // to be able to resolve them.
      if (!strcmp (Operator, "CHECKSUM") && !strcmp (Variables, "RANGE")
          && 2 == sscanf (sd, "%o-%o", &i, &j))
	{
	  fprintf (Lst, "%04o: %04o                        \t%-6s\tCHECKSUM RANGE %04o-%04o\n",
		   Lines, Location, Label, i, j);
	  if (NumChecksumRegions < MAX_CHECKSUM_REGIONS)
	    {
	      ChecksumRegions[NumChecksumRegions].Start = i;
	      ChecksumRegions[NumChecksumRegions].Stop = j;
	      ChecksumRegions[NumChecksumRegions++].Store = Location;
	    }
	  else
	    ErrorMsg ("Too many checksum regions defined.");
	  if (SingAlong != NULL)
	    fprintf (SingAlong, "0p\n");	   
          Location++;  
	  continue;
	}
      else if (!strcmp (Operator, "END"))
        {
	  fprintf (Lst, "%04o: %04o                        \t%-6s\t%-8s",
		   Lines, Location, Label, Operator);
	  PrintComments (24);
	  break;
	}
      else if (Operator[0] == 0)
        {
	  if (Comment == NULL || Comment[0] == 0)
	    fprintf (Lst, "%04o:\n", Lines);	  
	  else
	    {
	      fprintf (Lst, "%04o:                             \t# %s\n", Lines, Comment);
	      if (SingAlong != NULL && !strncmp (Comment, "PAGE ", 5))
		fprintf (SingAlong, "\n# %s ---------------------\n", Comment);
	    }
	}
      else if (!strcmp (Operator, "EQU") ||
	       !strcmp (Operator, "SYN") ||
	       !strcmp (Operator, "DEFINE"))
	{
	  Symbol_t *Symbol;
	  Symbol = GetSymbol (Label);
	  if (Symbol == NULL)
	    {
	      ErrorMsg ("Label not found.");
	      fprintf (Lst, "%04o:                             \t%-6s\t%-8s",
		       Lines, Label, Operator);
	    }
	  else if (Symbol->Value.Invalid)
	    {
	      ErrorMsg ("Label not resolved.");
	      fprintf (Lst, "%04o:                             t%-6st%-8s",
		       Lines, Label, Operator);
	    }
	  else if (Symbol->Value.Address)
	    {
	      fprintf (Lst, "%04o:                         %04o\t%-6s\t%-8s",
		       Lines, Symbol->Value.SReg, Label, Operator);
	    }
	  else if (Symbol->Value.Constant)
	    {
	      fprintf (Lst, "%04o:                         %04o\t%-6s\t%-8s",
		       Lines, Symbol->Value.Value, Label, Operator);
	    }
	  else
	    {
	      if (Symbol->Value.Value > 07777 || Symbol->Value.Value < -04000)
	        {
		  WarningMsg ("Symbol value out of range.");
		  fprintf (Lst, "%04o:                         %04o\t%-6s\t%-8s",
			   Lines, 07777 & Symbol->Value.Value, Label, Operator);
		}
	    }
	  PrintVariablesAndComments ();
        }
      else if (!strcmp (Operator, "DEC") ||
	       !strcmp (Operator, "OCT"))
	{
	  int ForceOctal;
	  if (!strcmp (Operator, "DEC"))
	    ForceOctal = -1;
	  else
	    ForceOctal = 1;
	  for (ss = Variables; *ss != 0; )
	    {
	      if (ForceOctal == 1)
	        i = EvaluateOctal (ss, &Address);
	      else
	        i = EvaluateDecimal (ss, &Address);
	      if (i)
	        ErrorMsg ("Value out of range.");
	      if (Address.Constant)
	        Memory[Location] = Address.Value;
	      else if (Address.Address)
	        Memory[Location] = Address.SReg;
	      if (Valid[Location])
	        WarningMsg ("Memory location overwritten.");
	      if (Memory[Location] < -0400000 || Memory[Location] > 0777777)
	        {
		  ErrorMsg ("Value out of range.");
		  Memory[Location] = 0;
		}
	      else 
	        Memory[Location] &= 0777777;
	      if (ss == Variables)
	        {
		  fprintf (Lst, "%04o: %04o           %06o       \t%-6s\t%-8s",
			   Lines, Location, Memory[Location], Label, Operator);
		  PrintVariablesAndComments ();
		}
	      else
	        {
		  fprintf (Lst, "%04o: %04o           %06o\n",
			   Lines, Location, Memory[Location]);
		}
	      if (SingAlong != NULL)
	        fprintf (SingAlong, "%op\n", Memory[Location]);
	      Valid[Location++] = 0;
	      for (; *ss && *ss != ','; ss++);
	      if (*ss == 0)
	        break;
	      ss++;
	    }
	}
      else if (!strcmp (Operator, "ORG"))
	{
	  EvaluateExpression (Variables, &Address, Location, 1);
	  if (Address.Constant)
	    Location = Address.Value;
	  else if (Address.Address)
	    Location = Address.Address;
	  if (Location < 0 || Location > 07777)
	    {
	      WarningMsg ("Address out of range.");
	      Location &= 07777;
	    }
	  fprintf (Lst, "%04o: %04o                        \t%-6s\t%-8s",
	           Lines, Location, Label, Operator);
	  PrintVariablesAndComments ();
	  if (SingAlong != NULL)
	    fprintf (SingAlong, "org %op\n", Location);
	}
      else if (!strcmp (Operator, "BES"))
	{
	  EvaluateExpression (Variables, &Address, Location, 0);
	  i = Location;
	  if (Address.Constant)
	    Location += Address.Value;
	  else if (Address.Address)
	    Location += Address.Address;
	  if (Location < 0 || Location > 07777)
	    {
	      WarningMsg ("Address out of range.");
	      Location &= 07777;
	    }
	  for (; i < Location; i++)
	    {
	      Memory[i] = 0;
	      if (Valid[i])
	        WarningMsg ("Overwriting memory.");
	      Valid[i] = 1;
	      if (SingAlong != NULL)
	        fprintf (SingAlong, "0p");
	    }
	  fprintf (Lst, "%04o: %04o                        \t%-6s\t%-8s",
	           Lines, Location, Label, Operator);
	  PrintVariablesAndComments ();
	}
      else if (!strcmp (Operator, "BSS"))
	{
	  fprintf (Lst, "%04o: %04o                        \t%-6s\t%-8s",
	           Lines, Location, Label, Operator);
	  PrintVariablesAndComments ();
	  EvaluateExpression (Variables, &Address, Location, 0);
	  i = Location;
	  if (Address.Constant)
	    Location += Address.Value;
	  else if (Address.Address)
	    Location += Address.Address;
	  if (Location < 0 || Location > 07777)
	    {
	      WarningMsg ("Address out of range (above).");
	      Location &= 07777;
	    }
	  for (; i < Location; i++)
	    {
	      Memory[i] = 0;
	      if (Valid[i])
	        WarningMsg ("Overwriting memory (above).");
	      Valid[i] = 1;
	      if (SingAlong != NULL)
	        fprintf (SingAlong, "0p");
	    }
	}  
      else
	{
	  int Opcode = 0, Tag = 0, Addr = 0;
	  // The remaining are all instructions and can be treated
	  // a little more uniformly.
	  if (!strcmp (Operator, "ADD"))
	    Opcode = 022;
	  else if (!strcmp (Operator, "ADZ"))
	    Opcode = 032;
	  else if (!strcmp (Operator, "SUB"))
	    Opcode = 024;
	  else if (!strcmp (Operator, "SUZ"))
	    Opcode = 034;
	  else if (!strcmp (Operator, "MPY"))
	    Opcode = 06;
	  else if (!strcmp (Operator, "MPR"))
	    Opcode = 026;
	  else if (!strcmp (Operator, "MPZ"))
	    Opcode = 036;
	  else if (!strcmp (Operator, "DVP"))
	    Opcode = 04;
	  else if (!strcmp (Operator, "COM"))
	    Opcode = 060;
	  else if (!strcmp (Operator, "ABS"))
	    Opcode = 062;
	  else if (!strcmp (Operator, "CLA"))
	    Opcode = 020;
	  else if (!strcmp (Operator, "CLZ"))
	    Opcode = 030;
	  else if (!strcmp (Operator, "LDQ"))
	    Opcode = 014;
	  else if (!strcmp (Operator, "STO"))
	    Opcode = 010;
	  else if (!strcmp (Operator, "STQ"))
	    Opcode = 012;
	  else if (!strcmp (Operator, "ALS"))
	    Opcode = 056;
	  else if (!strcmp (Operator, "LLS"))
	    Opcode = 052;
	  else if (!strcmp (Operator, "LRS"))
	    Opcode = 054;
	  else if (!strcmp (Operator, "TRA"))
	    Opcode = 040;
	  else if (!strcmp (Operator, "TSQ"))
	    Opcode = 072;
	  else if (!strcmp (Operator, "TMI"))
	    Opcode = 046;
	  else if (!strcmp (Operator, "TOV"))
	    Opcode = 044;
	  else if (!strcmp (Operator, "AXT"))
	    Opcode = 050;
	  else if (!strcmp (Operator, "TIX"))
	    Opcode = 042;
	  else if (!strcmp (Operator, "DLY"))
	    Opcode = 070;
	  else if (!strcmp (Operator, "INP"))
	    Opcode = 064;
	  else if (!strcmp (Operator, "OUT"))
	    Opcode = 066;
	  else 
	    ErrorMsg ("Unknown operator.");
	  
	  EvaluateExpression (Variables, &Address, Location, 0);
	  if (Address.Invalid)
	    ErrorMsg ("Address expression cannot be resolved.");
	  else 
	    {
	      if (Address.Constant)
	        Addr = Address.Value;
	      else 
	        Addr = Address.SReg;
	      if (Addr < 0 || Addr > 07777)
	        {
		  WarningMsg ("Address out of range.");
		  Addr &= 07777;
		}
	      if (!strcmp (Operator, "AXT") && Addr > 7)
	        {
		  ErrorMsg ("Address for index out of range.");
		  //Addr &= 7;
		}
	      for (ss = Variables; *ss && *ss != ','; ss++);
	      if (*ss == ',')
	        {
		  EvaluateExpression (ss + 1, &Address, Location, 0);
		  if (Address.Invalid)
		    ErrorMsg ("Tag expression cannot be resolved.");
		  else
		    {
		      if (Address.Constant)
		        Tag = Address.Value;
		      else
		        Tag = Address.SReg;
		      if (Tag != 0 && Tag != 1)
		        {
			  WarningMsg ("Tag out of range.");
			  Tag &= 1;
			}
		    }
		}
	      else
	        {
		  if (!strcmp (Operator, "TIX") || !strcmp (Operator, "AXT"))
		    {
		      WarningMsg ("Missing tag.");
		      Tag = 1;
		    }
		}
	    }
	  
	  Memory[Location] = ((Opcode | Tag) << 12) | Addr;
	  if (Valid[Location])
	    ErrorMsg ("Overwriting memory.");
	  Valid[Location] = 1;
	  fprintf (Lst, "%04o: %04o %02o %01o %04o              \t%-6s\t%-8s",
	           Lines, Location, Opcode, Tag, Addr, Label, Operator);
	  PrintVariablesAndComments ();
	  if (SingAlong != NULL)
	    fprintf (SingAlong, "%02op %op %04op\n", Opcode, Tag, Addr);

	  // Add the compiled line to the symbol table which tracks file:line
	  // to program counter memory addresses.
	  LineAddress.SReg = Location;
	  LineAddress.Address = 1;
	  AddLine (&LineAddress, FileSelected, Lines);

	  Location++;
	  if (Location > 07777)
	    {
	      WarningMsg ("Overflow of memory space.");
	      Location &= 07777;
	    }
	}  
	
    }
  if (SingAlong != NULL)
    fclose (SingAlong);
    
  return (UnresolvedSymbols ());
}

//------------------------------------------------------------------

int
main (int argc, char *argv[])
{

  int i, j, RetVal = 0, Unresolved, LastUnresolved, DupSymbols;
  int Checksum, PassCount;
  char *Compare = NULL;
  FILE *fp;
  
  printf ("AGS cross-assembler yaLEMAP, " __DATE__ ", " __TIME__ "\n");
  printf ("Copyright 2005,2009 Ronald S. Burkey.\n");
  printf ("Licensed under the General Public License (GPL).\n");
  
  Lst = fopen ("yaLEMAP.lst", "w");
  if (Lst == NULL)
    {
      fprintf (stderr, "Cannot create yaLEMAP.lst.\n");
      return (1);
    }

  fprintf (Lst, "AGS cross-assembler yaLEMAP, " __DATE__ ", " __TIME__ "\n");
  fprintf (Lst, "Copyright 2005 Ronald S. Burkey.\n");
  fprintf (Lst, "Licensed under the General Public License (GPL).\n");

  // Process the command-line switches.
  for (i = 1; i < argc; i++)
    {
      if (!strncmp (argv[i], "--compare=", 10))
        Compare = &argv[i][10];
      else if (!strcmp (argv[i], "--help"))
        {
	  printf ("Usage:\n");
	  printf ("\tyaLEMAP [OPTIONS] SourceFile\n");
	  printf ("The executable binary is output into the\n");
	  printf ("file yaLEMAP.bin.  The assembly listing is\n");
	  printf ("written to the file yaLEMAP.lst.\n");
	  printf ("The available OPTIONs are:\n");
	  printf ("--compare=F   Compare the binary output to the file F.\n");
	  printf ("              Note that using this switch causes yaLEMAP\'s\n");
	  printf ("              return code to be totally dependent on the\n");
	  printf ("              result of the file comparison rather than on\n");
	  printf ("              fatal errors and warnings.  This allows (for\n");
	  printf ("              example) for a file comparison to be the basis\n");
	  printf ("              of a regression test run from a makefile.\n");
	  RetVal++;
	}
      else if (argv[i][0] == '-' || FileSelected != NULL)
        {
	  fprintf (stderr, "Unknown command-line switch \"%s\".\n", argv[i]);
	  RetVal++;
	}
      else
        FileSelected = argv[i];
    }
  if (RetVal)
    return (RetVal);
  fp = fopen (FileSelected, "r");
  if (fp == NULL)
    {
      fprintf (stderr, "The source file \"%s\" does not exist.\n", FileSelected);
      return (1);
    }

  // Process the input file.  Keep doing passes until all symbols
  // are resolved, or until the pass did not resolve any symbols.
  // We simply do passes until all symbols are resolved or until
  // there is no change in the number of unresolved symbols.
  Unresolved = PassLemap (fp, -1);
  DupSymbols = SortSymbols ();
  LastUnresolved = Unresolved + 1;
  PassCount = 0;
  while (Unresolved != 0 && Unresolved != LastUnresolved)
    {
      if (PassCount >= 10)
        break;
      LastUnresolved = Unresolved;
      Unresolved = PassLemap (fp, 0);
      PassCount++;
    }
    
  // Make the assembly listing, not including the symbol table.
  // Yes, I know this is more passes than needed.  I don't care.
  // It's just easier than having to somehow buffer the assembly
  // listing, and with the speed of today's computers the 
  // loss is minimal.
  PassLemap (fp, 1);  

  // Compute Checksum, and store at the last address in memory.
  // (Or compare it to the value that is already there.
  fprintf (Lst, "\n");
  if (NumChecksumRegions == 0)
    {
      NumChecksumRegions = 1;
      ChecksumRegions[0].Start = 04000;
      ChecksumRegions[0].Stop = 07776;
      ChecksumRegions[0].Store = 07777;
    }
  for (j = 0; j < NumChecksumRegions; j++)
    {
      for (i = ChecksumRegions[j].Start, Checksum = 0; 
           i <= ChecksumRegions[j].Stop; 
	   Checksum += Memory[i++]);
      ChecksumRegions[j].Sum = Checksum = (0777777 & -Checksum);
      if (Valid[ChecksumRegions[j].Store] && Memory[ChecksumRegions[j].Store] != Checksum)
	{
	  RetVal++;
	  sprintf (s, "Checksum mismatch at address %04o (%04o-%04o), computed=%06o, embedded=%06o.\n",
		  ChecksumRegions[j].Store, ChecksumRegions[j].Start,
		  ChecksumRegions[j].Stop, Checksum, Memory[ChecksumRegions[j].Store]);
	  ErrorMsg (s);
	}
      else
	{
	  Memory[ChecksumRegions[j].Store] = Checksum;
	  Valid[ChecksumRegions[j].Store] = 1;
	}
      fprintf (Lst, "CHECKSUM at %04o (%04o-%04o) = %06o\n", 
               ChecksumRegions[j].Store, ChecksumRegions[j].Start,
	       ChecksumRegions[j].Stop, ChecksumRegions[j].Sum);
    }    

  // Output the binary
  fp = fopen ("yaLEMAP.bin", "wb");
  if (fp == NULL)
    {
      RetVal++;
      ErrorMsg ("Cannot create output file.");
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

  // We sort the lines by increasing physical address so we can look them
  // up later.
  SortLines (SORT_LEMAP);

  // Print the symbol table to a binary file
  WriteSymbolsToFile ("yaLEMAP.symtab");

  // Print symbol table.
  fprintf (Lst, "\n");
  PrintSymbolsToFileL (Lst);
  fprintf (Lst, "\n");
  ClearSymbols ();
  if (DupSymbols)
    sprintf (s, "%d duplicate symbols.", DupSymbols);
  else
    sprintf (s, "No duplicate symbols.");
  Msg (s);
  
  // Do a file-comparison, if appropriate.
  if (Compare != NULL)
    {
      fprintf (Lst, "\n");
      fprintf (Lst, "File comparison with \"%s\":\n", Compare); 
      fp = fopen (Compare, "rb");
      if (fp == NULL)
        fprintf (Lst, "\tCould not open file.\n");
      else
        {
	  int Location;
	  RetVal = 0;
	  for (Location = 0; Location < 010000; Location++)
	    {
	      i = fgetc (fp);
	      i += 0x100 * fgetc (fp);
	      i += 0x10000 * fgetc (fp);
	      i += 0x1000000 * fgetc (fp);
	      if (i != Memory[Location])
	        fprintf (Lst, "\t%04o:  %06o != %06o\n", 
		         Location, i, Memory[Location]);
	    }
	  fclose (fp);
	  if (RetVal == 0)
	    {
	      fprintf (Lst, "\tBinary file is correct!\n");
	      printf ("Binary file is correct!\n");
	    }
	  else
	    {
	      fprintf (Lst, "\tBinary file comparison failed with %d mismatches.\n", RetVal);
	      printf ("Binary file comparison failed with %d mismatches.\n", RetVal);
	    }
	}
      fprintf (Lst, "\n");
    }
  else
    RetVal = ErrCount + WarnCount;

  // All done!
  if (RetVal == 0  && ErrCount == 0 && WarnCount == 0)
    Msg ("Successful!");
  else
    {
      sprintf (s, "%d total errors.", ErrCount);
      Msg (s);
      sprintf (s, "%d total warnings.", WarnCount);
      Msg (s);
    }
  if (RetVal)
    {
      remove ("yaLEMAP.bin");
      remove ("yaLEMAP.symtab");
    }
  return (RetVal);

}
