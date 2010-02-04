/*
  Copyright 2010 Ronald S. Burkey <info@sandroid.org>

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

  Filename:	yaASM.c
  Purpose:	Cross-assembler for Gemini OBC and Apollo LVDC
  		source code.
  Compiler:	GNU gcc.
  Reference:	http://www.ibibio.org/apollo
  Mode:		2010-01-30 RSB.	Began adapting from yaLEMAP.c.
				
  Note that we use yaYUL's symbol-table machinery for handling the
  symbol table.
*/

#include "../yaYUL/yaYUL.h"

#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include <math.h>
#include <stdint.h>

enum ComputerType_t { CT_OBC = 0, CT_LVDC };
static int PultorakHardwareSim = 0;
static enum ComputerType_t ComputerType = CT_OBC;
// The MemoryWordSize is the number of 13-bit chunks per memory word.  It is
//	2	For LVDC.
//	2	For John Pultorak's OBC hardware sim.
//	3	For actual OBC.
static int MemoryWordSize = 3;
typedef uint16_t MemoryWord_t[3];
#define MASK13 017777
#define MASK26 0377777777
#define REV4(n) ( \
  ((n << 3) & 010) | \
  ((n << 1) & 004) | \
  ((n >> 1) & 002) | \
  ((n >> 3) & 001)
)

// A macro to advance the location counter to the next 13-bit position.
#define NEXTLOC() NextLoc (&Location, &Offset)
static inline void 
NextLoc (int *Location, int *Offset)
{
  (*Offset)++;
  if (*Offset >= MemoryWordSize)
    {
      *Offset = 0;
      (*Location)++;
    }
}
#define INCLOC(n) IncLoc (&Location, &Offset, (n))
static inline void
IncLoc (int *Location, int *Offset, int Increment)
{
  (*Offset) += Increment;
  while (*Offset < 0)
    {
      (*Offset) += MemoryWordSize;
      (*Location)--;
    }
  while (*Offset >= MemoryWordSize)
    {
      (*Offset) -= MemoryWordSize;
      (*Location)++;
    }
}
#define ALIGN() Align (&Location, &Offset)
static inline void
Align (int *Location, int *Offset)
{
  if (*Offset != 0)
    {
      *Offset = 0;
      (*Location)++;
    }
}

#define MEMSIZE 010000
#define MEMMASK (MEMSIZE - 1)
static MemoryWord_t Memory[MEMSIZE], Valid[MEMSIZE];
static char s[1000], sd[1000];
static int ErrCount, WarnCount;
static char *Comment, Label[1000], Operator[1000], Variables[1000];
static char *FileSelected = NULL;
static int Lines;
static FILE *Lst;
FILE *HtmlOut = NULL;
int Html = 0;

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
  if (HtmlOut != NULL)
    fprintf (HtmlOut, COLOR_FATAL "*** Error *** %s</span>\n", NormalizeString (Msg));
}

static void
WarningMsg (char *Msg)
{
  WarnCount++;
  fprintf (Lst, "*** Warning *** %s\n", Msg);
  fprintf (stderr, "%s:%d: Warning: %s\n", FileSelected, Lines, Msg);
  if (HtmlOut != NULL)
    fprintf (HtmlOut, COLOR_WARNING "*** Warning *** %s</span>\n", NormalizeString (Msg));
}

static void
Msg (char *Msg)
{
  fprintf (Lst, "%s\n", Msg);
  fprintf (stderr, "%s\n", Msg);
  if (HtmlOut != NULL)
    fprintf (HtmlOut, "%s\n", NormalizeString (Msg));
}

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

//------------------------------------------------------------------------
// Print an Address_t record.  Returns 0 on success, non-zero on error.

int
AddressPrint (Address_t *Address)
{
  if (Address->Invalid)
    {
      fprintf (Lst, "????\t"); 
      if (HtmlOut != NULL)
        fprintf (HtmlOut, "????    ");
    }
  else if (Address->Constant)
    {
      fprintf (Lst, "%04o\t", Address->Value & MEMMASK);
      if (HtmlOut != NULL)
        fprintf (HtmlOut, "%04o    ", Address->Value & MEMMASK);
    }  
  else if (Address->Address)
    {
      fprintf (Lst, "%04o\t", Address->SReg & MEMMASK);
      if (HtmlOut != NULL)
        fprintf (HtmlOut, "%04o    ", Address->SReg & MEMMASK);
    }
  else
    {
      fprintf (Lst, "int-err ");
      if (HtmlOut != NULL)
        fprintf (HtmlOut, "int-err ");
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
  char s[137];
  int i;
  fprintf (fp, "Symbol Table\n"
          "------------\n");
  if (HtmlOut != NULL)
    fprintf (HtmlOut, "</pre>\n<h1>Symbol Table</h1>\n<pre>\n");
  for (i = 0; i < SymbolTableSize; i++)
    {
      if (!(i & 3) && i != 0)
        {
          fprintf (fp, "\n");
	  if (HtmlOut != NULL)
	    fprintf (HtmlOut, "\n");
	}
      sprintf (s, "%6d: %-*s ", i + 1, MAX_LABEL_LENGTH, SymbolTable[i].Name);
      fprintf (fp, "%s", s);
      if (HtmlOut != NULL)
        fprintf (HtmlOut, "%s", NormalizeString (s));
      AddressPrint (&SymbolTable[i].Value);
      if (3 != (i & 3))
        {
          fprintf (fp, "\t");
	  if (HtmlOut != NULL)
	    fprintf (HtmlOut, "        ");
	}
    }
  fprintf (fp, "\n");  
  if (HtmlOut != NULL)
    fprintf (HtmlOut, "\n");
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
      if (HtmlOut != NULL)
        {
	  for (; i > 0; i--)
	    fprintf (HtmlOut, " ");
	  fprintf (HtmlOut, "  " COLOR_COMMENT "# %s</span>", NormalizeString (Comment));
	}
    }
  fprintf (Lst, "\n");
  if (HtmlOut != NULL)
    fprintf (HtmlOut, "\n");
}

static void
HtmlChar (c)
{
  if (c == '<')
    fprintf (HtmlOut, "&lt;");
  else if (c == '&')
    fprintf (HtmlOut, "&amp;");
  else
    fputc (c, HtmlOut);
}

static void
PrintVariablesAndComments (void)
{
  int i;
  i = fprintf (Lst, "%s", Variables);
  if (HtmlOut != NULL)
    {
      // This is tricky, because the operand field (Variables) often
      // looks something like "DIAT+1,1", where just "DIAT" is an
      // actual symbol and the other stuff represents operations on
      // it.  So we actually have to parse the field using characters
      // that are illegal for symbols as delimiters, and then check the
      // individual parts to see if they are defined symbols.  Whew!
      char *s;
      // Eliminate gunk at beginning.
      for (s = Variables; *s && !IsLabelSym (*s); s++)
        HtmlChar (*s);
      // Now loop on all the potential symbols remaining.
      while (*s)
        {
	  char *ss, c;
	  Symbol_t *Symbol;
	  // Find the potential variable itself.
	  for (ss = s; *ss && IsLabelSym (*ss); ss++);
	  // Re-delimit it.
	  c = *ss;
	  *ss = 0;
	  // Is it a real symbol?
	  Symbol = GetSymbol (s);
	  // Output it, with a hyperlink if appropriate.
	  if (Symbol != NULL)
	    fprintf (HtmlOut, "<a href=\"#%s\">", NormalizeAnchor (s));
	  fprintf (HtmlOut, "%s", NormalizeString (s));
	  if (Symbol != NULL)
	    fprintf (HtmlOut, "</a>");
	  // Fix the delimiting.
	  *ss = c;
	  // Take care of the non-symbol delimiting stuff.
	  for (s = ss; *s && !IsLabelSym (*s); s++)
	    HtmlChar (*s);
	}
    }
  PrintComments (i);
}

//------------------------------------------------------------------
// Shortcuts for outputting various stuff to the HTML.

static void
HtmlLabel (char *Label)
{
  if (Label[0])
    fprintf (HtmlOut, 
             "<a name=\"%s\"></a>" COLOR_SYMBOL "%s</span>  ", 
             NormalizeAnchor (Label),
    	     NormalizeStringN (Label, 6));
  else
    fprintf (HtmlOut, "%s", NormalizeStringN (Label, 8));
}

static void
HtmlOperator (char *Color, char *Operator)
{
  fprintf (HtmlOut, "%s%s</span>", Color, NormalizeStringN (Operator, 8));
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
  Value *= pow (10.0, En) * pow (2.0, 25 - Bn);
  i = Value + 0.5;
  
Done:
  if (i > 0377777777)
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
EvaluateExpression (char *Expression, Address_t *Address, int ForceOctal)
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
PassAsm (FILE *fp, int Action)
{
  int Location = 0, i, j, Extra, Missing, Dummy = 0, Offset = 0;
  char *ss;
  Address_t Address = { 0 }, LineAddress = { 0 };
  FILE *SingAlong;

  Lines = 0;
  rewind (fp);
  ErrCount = WarnCount = 0;
  if (Action == 1)
    SingAlong = fopen ("yaASM.binsource", "w");
  else
    SingAlong = NULL;

  while (NULL != fgets (s, sizeof (s) - 1, fp))
    {
      Lines++;

      // Is it an HTML insert?  If so, transparently process and discard.
      if (HtmlCheck ((Action == 1), fp, s, sizeof (s), 
      		     FileSelected, &Lines, &Dummy))
        continue;
      
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
	else if (Comment == NULL)
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
		  EvaluateExpression (Variables, &Address, 0);
		  EditSymbolNew (Label, &Address, SYMBOL_CONSTANT, FileSelected, Lines);
	        }
	    }
	  else if (!strcmp (Operator, "DEFINE"))
	    {
	      if (Label[0] != 0)
	        {
		  EvaluateExpression (Variables, &Address, 1);
		  EditSymbolNew (Label, &Address, SYMBOL_CONSTANT, FileSelected, Lines);
	        }
	    }
	  else if (!strcmp (Operator, "DEC") ||
	  	   !strcmp (Operator, "OCT"))
	    {
	      ALIGN ();
	      if (Label[0] != 0)
	        {
		  Address.Invalid = 0;
		  Address.Constant = 0;
		  Address.Address = 1;
		  Address.SReg = Location;
		  Address.Syllable = Offset;
		  EditSymbolNew (Label, &Address, SYMBOL_VARIABLE, FileSelected, Lines);
	        }
	      // All we need to do here is to know the number
	      // of commas in the Variables field.  The number
	      // of items is one more than that.  
	      for (Location++, ss = Variables; *ss; ss++)
	        if (*ss == ',')
		  {
		    // Each data item is 26 bit.
	            ALIGN ();
		    NEXTLOC ();
		    NEXTLOC ();
		  }
	    }
	  else if (!strcmp (Operator, "ORG"))
	    {
	      EvaluateExpression (Variables, &Address, 1);
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
		  Address.Syllable = Offset;
		  EditSymbolNew (Label, &Address, SYMBOL_LABEL, FileSelected, Lines);
	        }
	    }
	  else if (!strcmp (Operator, "BES"))
	    {
	      EvaluateExpression (Variables, &Address, 0);
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
		  Address.Syllable = Offset;
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
		  Address.Syllable = Offset;
		  EditSymbolNew (Label, &Address, SYMBOL_LABEL, FileSelected, Lines);
	        }
	      EvaluateExpression (Variables, &Address, 0);
	      if (Address.Constant)
	        INCLOC (Address.Value);
	      else if (Address.Address)
	        INCLOC (Address.Address);
	    }    
	  else
	    {
	      if (Label[0] != 0)
	        {
		  Address.Invalid = 0;
		  Address.Constant = 0;
		  Address.Address = 1;
		  Address.SReg = Location;
		  Address.Syllable = Offset;
		  EditSymbolNew (Label, &Address, SYMBOL_LABEL, FileSelected, Lines);
	        }
	      NEXTLOC ();
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
	  if (HtmlOut != NULL)
	    {
	      fprintf (HtmlOut, "%04o: %04o%s", Lines, Location, NormalizeStringN ("", 32));
	      HtmlLabel (Label);
	      fprintf (HtmlOut, COLOR_PSEUDO "CHECKSUM RANGE</span> %04o-%04o\n", i, j);
	    }
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
	  if (HtmlOut != NULL)
	    {
	      fprintf (HtmlOut, "%04o: %04o%s", Lines, Location, NormalizeStringN ("", 31));
	      HtmlLabel (Label);
	      HtmlOperator (COLOR_PSEUDO, Operator);
	    }
	  PrintComments (24);
	  break;
	}
      else if (Operator[0] == 0)
        {
	  if (Comment == NULL || Comment[0] == 0)
	    {
	      fprintf (Lst, "%04o:\n", Lines);
	      if (HtmlOut != NULL)
	        fprintf (HtmlOut, "%04o:\n", Lines);	  
	    }
	  else
	    {
	      fprintf (Lst, "%04o:                             \t# %s\n", Lines, Comment);
	      if (HtmlOut != NULL)
	        {
                  fprintf (HtmlOut, "%04o:%s", Lines, NormalizeStringN ("", 37));
		  fprintf (HtmlOut, COLOR_COMMENT "# %s</span>\n", NormalizeString (Comment));
		}
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
	      if (HtmlOut != NULL)
	        {
		  fprintf (HtmlOut, "%04o:%s", Lines, NormalizeStringN ("", 32));
	          HtmlLabel (Label);
		  HtmlOperator (COLOR_PSEUDO, Operator);
		}
	    }
	  else if (Symbol->Value.Invalid)
	    {
	      ErrorMsg ("Label not resolved.");
	      fprintf (Lst, "%04o:                             \t%-6s\t%-8s",
		       Lines, Label, Operator);
	      if (HtmlOut != NULL)
	        {
		  fprintf (HtmlOut, "%04o:%s", Lines, NormalizeStringN ("", 32));
		  HtmlLabel (Label);
		  HtmlOperator (COLOR_PSEUDO, Operator);
		}
	    }
	  else if (Symbol->Value.Address)
	    {
	      fprintf (Lst, "%04o:                         %04o\t%-6s\t%-8s",
		       Lines, Symbol->Value.SReg, Label, Operator);
	      if (HtmlOut)
	        {
		  fprintf (HtmlOut, "%04o:%s", Lines, NormalizeStringN ("", 25));
		  fprintf (HtmlOut, "%04o%s", Symbol->Value.SReg, NormalizeStringN ("", 8));
		  HtmlLabel (Label);
		  HtmlOperator (COLOR_PSEUDO, Operator);
		}
	    }
	  else if (Symbol->Value.Constant)
	    {
	      fprintf (Lst, "%04o:                         %04o\t%-6s\t%-8s",
		       Lines, Symbol->Value.Value, Label, Operator);
	      if (HtmlOut)
	        {
		  fprintf (HtmlOut, "%04o:%s", Lines, NormalizeStringN ("", 25));
		  fprintf (HtmlOut, "%04o%s", Symbol->Value.Value, NormalizeStringN ("", 8));
		  HtmlLabel (Label);
		  HtmlOperator (COLOR_PSEUDO, Operator);
		}
	    }
	  else
	    {
	      if (Symbol->Value.Value > MEMMASK || Symbol->Value.Value < -04000)
	        {
		  WarningMsg ("Symbol value out of range.");
		  fprintf (Lst, "%04o:                         %04o\t%-6s\t%-8s",
			   Lines, MEMMASK & Symbol->Value.Value, Label, Operator);
		  if (HtmlOut)
		    {
		      fprintf (HtmlOut, "%04o:%s", Lines, NormalizeStringN ("", 25));
		      fprintf (HtmlOut, "%04o%s", MEMMASK & Symbol->Value.Value, NormalizeStringN ("", 8));
		      HtmlLabel (Label);
		      HtmlOperator (COLOR_PSEUDO, Operator);
		    }
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
	      ALIGN ();
	      if (ForceOctal == 1)
	        i = EvaluateOctal (ss, &Address);
	      else
	        i = EvaluateDecimal (ss, &Address);
	      if (i)
	        ErrorMsg ("Value out of range.");
	      if (Address.Constant)
	        {
	          Memory[Location][0] = (Address.Value >> 13) & MASK13;
	          Memory[Location][1] = Address.Value & MASK13;
                  if (0 != (Address.Value & ~MASK26))
                    ErrorMsg ("Value out of range.");
	        }
	      else if (Address.Address)
	        {
	          Memory[Location][0] = 0;
	          Memory[Location][1] = Address.SReg;
	        }
	      if (Valid[Location][0] || Valid[Location][1])
	        WarningMsg ("Memory location overwritten.");
	      if (ss == Variables)
	        {
		  fprintf (Lst, "%04o: %04o           %06o       \t%-6s\t%-8s",
			   Lines, Location, Memory[Location], Label, Operator);
		  if (HtmlOut != NULL)
		    {
		      fprintf (HtmlOut, "%04o: %04o%s", Lines, Location, NormalizeStringN ("", 11));
		      fprintf (HtmlOut, "%06o%s", Memory[Location], NormalizeStringN ("", 15));
		      HtmlLabel (Label);
		      HtmlOperator (COLOR_PSEUDO, Operator);
		    }
		  PrintVariablesAndComments ();
		}
	      else
	        {
		  fprintf (Lst, "%04o: %04o           %06o\n",
			   Lines, Location, Memory[Location]);
		  if (HtmlOut != NULL)
		    {
		      fprintf (HtmlOut, "%04o: %04o%s", Lines, Location, NormalizeStringN ("", 11));
		      fprintf (HtmlOut, "%06o%s\n", Memory[Location], NormalizeStringN ("", 15));
		    }
		}
	      if (SingAlong != NULL)
	        fprintf (SingAlong, "%op\n", Memory[Location]);
	      Valid[Location][0] = 1;
	      Valid[Location][1] = 1;
	      Offset = 2;
	      for (; *ss && *ss != ','; ss++);
	      if (*ss == 0)
	        break;
	      ss++;
	    }
	}
      else if (!strcmp (Operator, "ORG"))
	{
	  EvaluateExpression (Variables, &Address, 1);
	  if (Address.Constant)
	    Location = Address.Value;
	  else if (Address.Address)
	    Location = Address.Address;
	  if (Location < 0 || Location >= MEMSIZE)
	    {
	      WarningMsg ("Address out of range.");
	      Location &= MEMMASK;
	    }
	  fprintf (Lst, "%04o: %04o                        \t%-6s\t%-8s",
	           Lines, Location, Label, Operator);
	  if (HtmlOut != NULL)
	    {
	      fprintf (HtmlOut, "%04o: %04o%s",
		       Lines, Location, NormalizeStringN ("", 32));
	      HtmlLabel (Label);
	      HtmlOperator (COLOR_PSEUDO, Operator);
	    }
	  PrintVariablesAndComments ();
	  if (SingAlong != NULL)
	    fprintf (SingAlong, "org %op\n", Location);
	}
      else if (!strcmp (Operator, "BES") || !strcmp (Operator, "BSS"))
	{
	  EvaluateExpression (Variables, &Address, 0);
	  if (Address.Constant)
	    i = Address.Value;
	  else if (Address.Address)
	    {
	      ErrorMsg ("Address used with BES pseudo-op.");
	      i = Address.Address;
	    }
	  for (; i > 0; i--)
	    {
	      Memory[Location][Offset] = 0;
	      if (Valid[Location][Offset])
	        WarningMsg ("Overwriting memory.");
	      Valid[Location][Offset] = 1;
	      if (SingAlong != NULL)
	        fprintf (SingAlong, "0p");
	      NEXTLOC ();
	    }
	  fprintf (Lst, "%04o: %04o                        \t%-6s\t%-8s",
	           Lines, Location, Label, Operator);
	  if (HtmlOut != NULL)
	    {
	      fprintf (HtmlOut, "%04o: %04o%s",
		       Lines, Location, NormalizeStringN ("", 31));
	      HtmlLabel (Label);
	      HtmlOperator (COLOR_PSEUDO, Operator);
	    }
	  PrintVariablesAndComments ();
	}
      else
	{
	  int Opcode = 0, Tag = 0, Addr = 0;
	  // The remaining are all instructions and can be treated
	  // a little more uniformly.
	  if (!strcmp (Operator, "HOP"))
	    Opcode = 000;
	  else if (!strcmp (Operator, "DIV"))
	    Opcode = 001;
	  else if (!strcmp (Operator, "PRO"))
	    Opcode = 002;
	  else if (!strcmp (Operator, "RSU"))
	    Opcode = 003;
	  else if (!strcmp (Operator, "ADD"))
	    Opcode = 004;
	  else if (!strcmp (Operator, "SUB"))
	    Opcode = 005;
	  else if (!strcmp (Operator, "CLA"))
	    Opcode = 006;
	  else if (!strcmp (Operator, "AND"))
	    Opcode = 007;
	  else if (!strcmp (Operator, "MPY"))
	    Opcode = 010;
	  else if (!strcmp (Operator, "TRA"))
	    Opcode = 011;
	  else if (!strcmp (Operator, "SHF"))
	    Opcode = 012;
	  else if (!strcmp (Operator, "TMI"))
	    Opcode = 013;
	  else if (!strcmp (Operator, "STO"))
	    Opcode = 014;
	  else if (!strcmp (Operator, "SPQ"))
	    Opcode = 015;
	  else if (!strcmp (Operator, "CLD"))
	    Opcode = 016;
	  else if (!strcmp (Operator, "TNZ"))
	    Opcode = 017;
	  else 
	    ErrorMsg ("Unknown operator.");
	  
	  EvaluateExpression (Variables, &Address, 0);
	  if (Address.Invalid)
	    ErrorMsg ("Address expression cannot be resolved.");
	  else 
	    {
	      if (Address.Constant)
	        Addr = Address.Value;
	      else 
	        Addr = Address.SReg;
	      if (Addr < 0 || Addr > MEMMASK)
	        {
		  WarningMsg ("Address out of range.");
		  Addr &= MEMMASK;
		}
	      if (!strcmp (Operator, "AXT") && Addr > 7)
	        {
		  ErrorMsg ("Address for index out of range.");
		  //Addr &= 7;
		}
	      for (ss = Variables; *ss && *ss != ','; ss++);
	      if (*ss == ',')
	        {
		  EvaluateExpression (ss + 1, &Address, 0);
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
	  if (HtmlOut != NULL)
	    {
	      fprintf (HtmlOut, "%04o: %04o %02o %01o %04o%s",
		       Lines, Location, Opcode, Tag, Addr, NormalizeStringN ("", 22));
	      HtmlLabel (Label);
	      HtmlOperator (COLOR_BASIC, Operator);
	    }
	  PrintVariablesAndComments ();
	  if (SingAlong != NULL)
	    fprintf (SingAlong, "%02op %op %04op\n", Opcode, Tag, Addr);

	  // Add the compiled line to the symbol table which tracks file:line
	  // to program counter memory addresses.
	  LineAddress.SReg = Location;
	  LineAddress.Syllable = Offset;
	  LineAddress.Address = 1;
	  AddLine (&LineAddress, FileSelected, Lines);

	  NEXTLOC ();
	  if (Location > MEMMASK)
	    {
	      WarningMsg ("Overflow of memory space.");
	      Location &= MEMMASK;
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
  int PassCount;
  char *Compare = NULL;
  FILE *fp;
  
  printf ("Gemini and LVDC cross-assembler yaASM, " __DATE__ ", " __TIME__ "\n");
  printf ("Copyright 2010 Ronald S. Burkey.\n");
  printf ("Licensed under the General Public License (GPL).\n");
  
  Lst = fopen ("yaASM.lst", "w");
  if (Lst == NULL)
    {
      fprintf (stderr, "Cannot create yaASM.lst.\n");
      return (1);
    }

  fprintf (Lst, "Gemini and LVDC cross-assembler yaASM, " __DATE__ ", " __TIME__ "\n");
  fprintf (Lst, "Copyright 2010 Ronald S. Burkey.\n");
  fprintf (Lst, "Licensed under the General Public License (GPL).\n");

  // Process the command-line switches.
  for (i = 1; i < argc; i++)
    {
      if (!strncmp (argv[i], "--compare=", 10))
        Compare = &argv[i][10];
      else if (!strcmp (argv[i], "--html"))
        Html = 1;
      else if (!strcmp (argv[i], "--help"))
        {
	  printf ("Usage:\n");
	  printf ("\tyaASM [OPTIONS] SourceFile\n");
	  printf ("The executable binary is output into the\n");
	  printf ("file yaASM.bin.  The assembly listing is\n");
	  printf ("written to the file yaASM.lst.\n");
	  printf ("The available OPTIONs are:\n");
	  printf ("--compare=F   Compare the binary output to the file F.\n");
	  printf ("              Note that using this switch causes yaASM\'s\n");
	  printf ("              return code to be totally dependent on the\n");
	  printf ("              result of the file comparison rather than on\n");
	  printf ("              fatal errors and warnings.  This allows (for\n");
	  printf ("              example) for a file comparison to be the basis\n");
	  printf ("              of a regression test run from a makefile.\n");
	  printf ("--html        Causes an HTML file to be created, which is \n"
		  "              the same as the output listing except that it\n"
		  "              if a lot more convenient to use. It has syntax\n"
		  "              highlighting and hyperlinks from where each\n"
		  "              symbol is used back to where it was defined.\n"
		  "              The top-level HTML file produced is named the\n"
		  "              same as the input source file, except with .html\n"
		  "              replacing .s (if applicable).\n");
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
  if (Html)
    {
      if (HtmlCreate (FileSelected))
        {
	  fclose (fp);
	  return (1);
	}
    }

  // Process the input file.  Keep doing passes until all symbols
  // are resolved, or until the pass did not resolve any symbols.
  // We simply do passes until all symbols are resolved or until
  // there is no change in the number of unresolved symbols.
  Unresolved = PassAsm (fp, -1);
  DupSymbols = SortSymbols ();
  LastUnresolved = Unresolved + 1;
  PassCount = 0;
  while (Unresolved != 0 && Unresolved != LastUnresolved)
    {
      if (PassCount >= 10)
        break;
      LastUnresolved = Unresolved;
      Unresolved = PassAsm (fp, 0);
      PassCount++;
    }
    
  // Make the assembly listing, not including the symbol table.
  // Yes, I know this is more passes than needed.  I don't care.
  // It's just easier than having to somehow buffer the assembly
  // listing, and with the speed of today's computers the 
  // loss is minimal.
  PassAsm (fp, 1);  

#if 0
  // At this point should logically go stuff for computing the
  // checksums of the binary, and/or comparing the checksums to
  // known values.  However, at this point, all knowledge of this
  // stuff isn't available, so I don't know what if anything I
  // should put here.
#endif        

  // Output the binary
  fp = fopen ("yaASM.bin", "wb");
  if (fp == NULL)
    {
      RetVal++;
      ErrorMsg ("Cannot create output file.");
    }
  else
    {
      for (i = 0; i < MEMSIZE; i++)
        for (j = 0; j < MemoryWordSize; j++)
	  {
	    fputc (0xFF & Memory[i][j], fp);
	    fputc (0x1F & (Memory[i][j] >> 8), fp);
	  }
      fclose (fp);
    }

  // We sort the lines by increasing physical address so we can look them
  // up later.
  SortLines (SORT_ASM);

  // Print the symbol table to a binary file
  WriteSymbolsToFile ("yaASM.symtab");

  // Print symbol table.
  fprintf (Lst, "\n");
  if (HtmlOut != NULL)
    fprintf (HtmlOut, "\n");
  PrintSymbolsToFileL (Lst);
  fprintf (Lst, "\n");
  if (HtmlOut != NULL)
    fprintf (HtmlOut, "\n");
  ClearSymbols ();
  if (DupSymbols)
    sprintf (s, "%d duplicate symbols.", DupSymbols);
  else
    sprintf (s, "No duplicate symbols.");
  Msg (s);
  
  // Do a file-comparison, if appropriate.
  if (Compare != NULL)
    {
      if (HtmlOut != NULL)
	fprintf (HtmlOut, "\n</pre>\n<h1>Binary-File Comparison</h1>\n<pre>\n");
    
      fprintf (Lst, "\n");
      fprintf (Lst, "File comparison with \"%s\":\n", Compare);
      if (HtmlOut != NULL)
        {
	  fprintf (HtmlOut, "File comparison with \"%s\":\n", NormalizeString (Compare));
	} 
      fp = fopen (Compare, "rb");
      if (fp == NULL)
        {
          fprintf (Lst, "\tCould not open file.\n");
	  if (HtmlOut != NULL)
	    fprintf (HtmlOut, "    " COLOR_WARNING "Could not open file.</span>\n");
	}
      else
        {
	  int Location;
	  RetVal = 0;
	  for (Location = 0; Location < MEMSIZE; Location++)
	    for (j = 0; j < MemoryWordSize; j++)
	      {
		i = fgetc (fp);
		i += 0x100 * fgetc (fp);
		if (i != Memory[Location][j])
		  {
		    fprintf (Lst, "\t%04o:  %06o != %06o\n", 
			     Location, i, Memory[Location][j]);
		    if (HtmlOut != NULL)
		      fprintf (HtmlOut, "    %04o:  %06o != %06o\n", 
			     Location, i, Memory[Location][j]);
		  }
	      }
	  fclose (fp);
	  if (RetVal == 0)
	    {
	      fprintf (Lst, "\tBinary file is correct!\n");
	      if (HtmlOut != NULL)
	        fprintf (HtmlOut, "    Binary file is correct!\n");
	      printf ("Binary file is correct!\n");
	    }
	  else
	    {
	      fprintf (Lst, "\tBinary file comparison failed with %d mismatches.\n", RetVal);
	      if (HtmlOut != NULL)
	        fprintf (HtmlOut, "    Binary file comparison"
		                  " failed with %d mismatches.\n", RetVal);
	      printf ("Binary file comparison failed with %d mismatches.\n", RetVal);
	    }
	}
      fprintf (Lst, "\n");
    }
  else
    RetVal = ErrCount + WarnCount;

  // All done!
  if (HtmlOut != NULL)
    fprintf (HtmlOut, "\n</pre>\n<h1>Assembly Status</h1>\n<pre>\n");
    
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
      remove ("yaASM.bin");
      remove ("yaASM.symtab");
    }
  HtmlClose ();
  return (RetVal);

}
