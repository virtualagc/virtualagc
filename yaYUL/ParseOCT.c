/*
  Copyright 2003-2004 Ronald S. Burkey <info@sandroid.org>
  
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

  Filename:	ParseOCT.c
  Purpose:	Assembles the 2DEC pseudo-op.
  Mode:		04/18/03 RSB.	Began.
  		07/23/04 RSB.	Added 2OCT.
*/

#include "yaYUL.h"
#include <stdlib.h>
#include <math.h>
#include <string.h>

//-------------------------------------------------------------------------
// Returns non-zero on unrecoverable error  We don't do a heckuva lot of 
// error-checking in this version.
int ParseOCT(ParseInput_t *InRecord, ParseOutput_t *OutRecord)
{
  char *s;
  int Value;

  IncPc(&InRecord->ProgramCounter, 1, &OutRecord->ProgramCounter);
  if (!OutRecord->ProgramCounter.Invalid && OutRecord->ProgramCounter.Overflow)
    {
      strcpy(OutRecord->ErrorMessage, "Next code may overflow storage.");
      OutRecord->Warning = 1;
    }

  OutRecord->EBank = InRecord->EBank;
  OutRecord->SBank = InRecord->SBank;
  OutRecord->Words[0] = ILLEGAL_SYMBOL_VALUE;
  OutRecord->NumWords = 1;

  s = InRecord->Operand;
  if (*s == '+' || *s == '-')
    s++;
  for (; *s; s++)
    if (*s < '0' || *s > '7')
      break;

  if (!*s && s != InRecord->Operand)    
    {  
      int Minus;

      Minus = 0;
      if (InRecord->Operand[0] == '-')
        Minus = 1;

      if (1 == sscanf(&InRecord->Operand[Minus], "%o", &Value))
	{
	  if (0 != (Value & ~077777))
	    {
	      Value &= 077777;
	      strcpy(OutRecord->ErrorMessage, "Value out of range.");
	      OutRecord->Warning = 1;
	    }
	  if (Minus)
	    Value = ~Value;
	  OutRecord->Words[0] = Value;
	}
    }  
  else
    {
      strcpy (OutRecord->ErrorMessage, "Not an octal number.");
      OutRecord->Fatal = 1;
    }    
  return (0);
}


int Parse2OCT(ParseInput_t *InRecord, ParseOutput_t *OutRecord)
{
  char *s;
  int Value;

  IncPc(&InRecord->ProgramCounter, 2, &OutRecord->ProgramCounter);
  if (!OutRecord->ProgramCounter.Invalid && OutRecord->ProgramCounter.Overflow)
    {
      strcpy(OutRecord->ErrorMessage, "Next code may overflow storage.");
      OutRecord->Warning = 1;
    }

  OutRecord->EBank = InRecord->EBank;
  OutRecord->SBank = InRecord->SBank;
  OutRecord->Words[0] = ILLEGAL_SYMBOL_VALUE;
  OutRecord->NumWords = 2;

  s = InRecord->Operand;
  if (*s == '+' || *s == '-')
    s++;
  for (; *s; s++)
    if (*s < '0' || *s > '7')
      break;

  if (!*s && s != InRecord->Operand)    
    {  
      int Minus;

      Minus = 0;
      if (InRecord->Operand[0] == '-')
        Minus = 1;

      if (1 == sscanf(&InRecord->Operand[Minus], "%o", &Value))
	{
	  if (0 != (Value & ~07777777777))
	    {
	      Value &= 07777777777;
	      strcpy(OutRecord->ErrorMessage, "Value out of range.");
	      OutRecord->Warning = 1;
	    }
	  if (Minus)
	    Value = ~Value;
	  OutRecord->Words[0] = 077777 & (Value >> 15);
	  OutRecord->Words[1] = 077777 & Value;
	}
    }  
  else
    {
      strcpy(OutRecord->ErrorMessage, "Not an octal number.");
      OutRecord->Fatal = 1;
    }    
  return (0);
}



