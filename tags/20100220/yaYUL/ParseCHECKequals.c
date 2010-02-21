/*
  Copyright 2003-2004 Ronald S. Burkey <info@sandroid.org>
  Copyright 2009 Jim Lawton <jim DOT lawton AT gmail DOT com>
  
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

  Filename:	ParseCHECKequals.c
  Purpose:	Assembles the CHECK= pseudo-op.
  Mode:		2009-09-03 JL	Added, based on original EQUALS parser.
*/

#include "yaYUL.h"
#include <stdlib.h>
#include <string.h>

extern Line_t CurrentFilename;
extern int CurrentLineInFile;

//------------------------------------------------------------------------
// Return 0 on success.

int ParseCHECKequals(ParseInput_t *InRecord, ParseOutput_t *OutRecord)
{
  Address_t labelValue = { 1 };
  Address_t checkValue = { 1 };
  int lhValue, rhValue, i;
  int lhValid = 0;
  int rhValid = 0;

  if (*InRecord->Label == 0)
    {
      strcpy(OutRecord->ErrorMessage, "Label must be supplied for CHECK= directive.");
      OutRecord->Fatal = 1;
      return (0);
    }
  else
    {
      Symbol_t *labelSymbol = GetSymbol(InRecord->Label);
      if (labelSymbol == NULL)
        {
          sprintf(OutRecord->ErrorMessage, "Symbol \"%s\" not defined, skipping...", InRecord->Label);
          OutRecord->Warning = 1;
          return (0);
        }
      else
        {
          labelValue = labelSymbol->Value;
          lhValue = labelValue.Value;
          lhValid = 1;
        } 
    }

  if (*InRecord->Operand == 0 && *InRecord->Mod1 == 0)
    {
      strcpy(OutRecord->ErrorMessage, "Operand must be supplied for CHECK= directive.");
      OutRecord->Fatal = 1;
      return (0);
    }  

  // Next, it may be that the operand is simply a number.  If so, then
  // we're talking about a simple constant.  
  i = GetOctOrDec(InRecord->Operand, &rhValue);
  if (i)
    {
      // The operand is NOT a number.  Presumably, it's a symbol.
      i = FetchSymbolPlusOffset(&InRecord->ProgramCounter, InRecord->Operand, InRecord->Mod1, &checkValue);
      if (i)
        {
          sprintf(OutRecord->ErrorMessage, "Symbol \"%s\" undefined or offset bad", InRecord->Operand);
	      OutRecord->Warning = 1;
          return (0);
        }
      if (OpcodeOffset)
        {
          if (checkValue.Constant)
            {
              checkValue.Value += OpcodeOffset;
            }
          else
            {
	          IncPc(&checkValue, OpcodeOffset, &checkValue);
	        }
	      rhValue = checkValue.Value;
	      rhValid = 1;
        }
    }
  else
    {
      if (*InRecord->Operand == '+' || *InRecord->Operand == '-')
        {
          IncPc(&InRecord->ProgramCounter, rhValue, &checkValue);
        }
      else
        {
          if (rhValue < -16383 || rhValue > 32767)
	        {
	          strcpy(OutRecord->ErrorMessage, "Value out of range, truncating");
	          OutRecord->Warning = 1;
	          if (rhValue < -16383)
	            rhValue = -16383;
	          else if (rhValue > 32767)
	            rhValue = 32767;  
	        }
	      checkValue.Invalid = 0;
	      checkValue.Constant = 1;
	      checkValue.Value = rhValue;
	    }
        rhValue = checkValue.Value;
	    rhValid = 1;
    }  

  if (lhValid == 1 && rhValid == 1)
    {
      if (lhValue != rhValue)
        {
	      strcpy(OutRecord->ErrorMessage, "Address check failed");
	      OutRecord->Fatal = 1;
          return (0);
        }
    }
  return (0);  
}
