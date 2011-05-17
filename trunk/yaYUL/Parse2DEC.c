/*
  Copyright 2003-2004,2009 Ronald S. Burkey <info@sandroid.org>
  
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

  Filename:     Parse2DEC.c
  Purpose:      Assembles the 2DEC pseudo-op.
  Mod History:  04/15/03 RSB   Began.
                07/23/04 RSB   Added VN.
                09/04/04 RSB   DEC and 2DEC weren't detecting -0 -- i.e.,
                               -0 was converted to +0.
                02/28/09 RSB   Several incorrect string-compares 
                               (of the form string=="" rather than
                               string[0]==0) which had for some reason
                               previously been working were fixed.
*/

#include "yaYUL.h"
#include <stdlib.h>
#include <math.h>
#include <string.h>

//-------------------------------------------------------------------------
// Converts a string like "E+-n" or "B+-n" to a scale factor.
double ScaleFactor(char *s)
{
  int n;

  if (*s == 0)
    return (1.0);

  if (*s == 'E')
    {
      n = atoi(s + 1);
      return (pow(10.0, n));
    }
  else if (*s == 'B')
    {
      n = atoi(s + 1);
      return (pow(2.0, n));
    }
  else 
    return (1.0);      
}

//-------------------------------------------------------------------------
// Returns non-zero on unrecoverable error  We don't do a heckuva lot of 
// error-checking in this version.
int Parse2DECstar(ParseInput_t *InRecord, ParseOutput_t *OutRecord)
{
  return (Parse2DEC(InRecord, OutRecord));
}

int Parse2DEC(ParseInput_t *InRecord, ParseOutput_t *OutRecord)
{
  double x;
  double tmpval;
  char *tmpmod1 = NULL, *tmpmod2 = NULL;
  int Sign, Value, i;

  IncPc(&InRecord->ProgramCounter, 2, &OutRecord->ProgramCounter);

  if (!OutRecord->ProgramCounter.Invalid && OutRecord->ProgramCounter.Overflow)
    {
      strcpy(OutRecord->ErrorMessage, "Next code may overflow storage.");
      OutRecord->Warning = 1;
    }

  OutRecord->EBank = InRecord->EBank;
  OutRecord->SBank = InRecord->SBank;
  OutRecord->Words[0] = ILLEGAL_SYMBOL_VALUE;
  OutRecord->Words[1] = ILLEGAL_SYMBOL_VALUE;
  OutRecord->NumWords = 2;

  if (InRecord->Extend && !InRecord->IndexValid)
    {
      strcpy(OutRecord->ErrorMessage, "Illegally preceded by EXTEND.");
      OutRecord->Fatal = 1;
      OutRecord->Extend = 0;
    }

  if (InRecord->IndexValid) 
    {
      strcpy(OutRecord->ErrorMessage, "Illegally preceded by INDEX.");
      OutRecord->Fatal = 1;
      OutRecord->IndexValid = 0;
    }

  if (InRecord->Operand[0] == 0)
    {
      strcpy(OutRecord->ErrorMessage, "Operand is missing.");
      OutRecord->Fatal = 1;
      return (0);
    }  

  // Handle numbers where only scale factor(s) are supplied. 
  if (*InRecord->Operand == 'E' || *InRecord->Operand == 'B')
    {
      tmpval = 1.0;
      tmpmod1 = InRecord->Operand;
      tmpmod2 = InRecord->Mod1;
    }
  else
    {
      tmpval = strtod(InRecord->Operand, NULL);
      tmpmod1 = InRecord->Mod1;
      tmpmod2 = InRecord->Mod2;
    }

  // Under some circumstances, add a default scale factor.
  if (strstr(InRecord->Operand, ".") == NULL && *InRecord->Mod1 == 0 && *InRecord->Mod2 == 0)
    InRecord->Mod1 = "B-28";

  // Compute the constant as a floating-point number.  
  x = tmpval * ScaleFactor(tmpmod1) * ScaleFactor(tmpmod2);

  // Convert to 1's complement format.
  Sign = 0;
  if (InRecord->Operand[0] == '-')
    {
      // x < 0
      Sign = 1;
      x = -x;
    }

  if (fmod(x, 1.0) == 0.0)
    {
      // Integer: just convert directly to octal.
      Value = (int)x;
    } 
  else
    {
      // Floating point: scale. FP numbers > 1.0 are an error.
      if (x >= 1.0)
        return (1);

      for (Value = 0, i = 0; i < 28; i++)
        {
          Value = Value << 1;
          if (x >= 0.5)
            {
              Value++;
              x -= 0.5;
            }
          x *= 2;
        }

      if (x >= 0.5 && Value < 0x0fffffff)
        Value++;
    }

  i = Value & 0x00003fff;
  Value = (Value >> 14) & 0x00003fff;
  if (Sign)
    {
      Value = ~Value;
      i = ~i;
      i &= 0x00007fff;
      Value &= 0x00007fff;
    }

  OutRecord->Words[0] = Value;
  OutRecord->Words[1] = i;

  return (0);
}

//-------------------------------------------------------------------------
// Returns non-zero on unrecoverable error  We don't do a heckuva lot of 
// error-checking in this version.
int ParseDECstar(ParseInput_t *InRecord, ParseOutput_t *OutRecord)
{
  return (ParseDEC(InRecord, OutRecord));
}

int ParseDEC(ParseInput_t *InRecord, ParseOutput_t *OutRecord)
{
  double x;
  double tmpval;
  char *tmpmod1 = NULL, *tmpmod2 = NULL;
  int Sign, Value, i;

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

  if (InRecord->Extend && !InRecord->IndexValid)
    {
      strcpy(OutRecord->ErrorMessage, "Illegally preceded by EXTEND.");
      OutRecord->Fatal = 1;
      OutRecord->Extend = 0;
    }

  if (InRecord->IndexValid)
    {
      strcpy(OutRecord->ErrorMessage, "Illegally preceded by INDEX.");
      OutRecord->Fatal = 1;
      OutRecord->IndexValid = 0;
    }

  if (InRecord->Operand[0] == 0)
    {
      strcpy(OutRecord->ErrorMessage, "Operand is missing.");
      OutRecord->Fatal = 1;
      return (0);
    }

  // Handle numbers where only scale factor(s) are supplied. 
  if (*InRecord->Operand == 'E' || *InRecord->Operand == 'B')
    {
      tmpval = 1.0;
      tmpmod1 = InRecord->Operand;
      tmpmod2 = InRecord->Mod1;
    }
  else
    {
      tmpval = strtod(InRecord->Operand, NULL);
      tmpmod1 = InRecord->Mod1;
      tmpmod2 = InRecord->Mod2;
    }

  // Under some circumstances, add a default scale factor.
  if (strstr(InRecord->Operand, ".") == NULL && *InRecord->Mod1 == 0 && *InRecord->Mod2 == 0)
    InRecord->Mod1 = "B-14";

  // Compute the constant as a floating-point number.  
  x = tmpval * ScaleFactor(tmpmod1) * ScaleFactor(tmpmod2);

  // Convert to 1's complement format.
  Sign = 0;
  if (InRecord->Operand[0] == '-')
    {
      // x < 0
      Sign = 1;
      x = -x;
    }

  if (fmod(x, 1.0) == 0.0)
    {
      // Integer: just convert directly to octal.
      Value = (int)x;
    } 
  else
    {
      // Floating point: scale. FP numbers > 1.0 are an error.
      if (x >= 1.0)
        return (1);

      for (Value = 0, i = 0; i < 14; i++)
        {
          Value = Value << 1;
          if (x >= 0.5)
            {
              Value++;
              x -= 0.5;
            }
          x *= 2;
        }

      if (x >= 0.5 && Value < 0x03fff)
        Value++;
    }

  if (Sign)
    Value = 0x7FFF & ~Value;

  OutRecord->Words[0] = Value;

  return (0);
}

//----------------------------------------------------------------------------
// VN is a slightly-changed knockoff of DEC, designed to pack verb/noun
// specs into a single word of memory.
int ParseVN(ParseInput_t *InRecord, ParseOutput_t *OutRecord)
{
  char c;
  unsigned Value;

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

  if (InRecord->Extend && !InRecord->IndexValid)
    {
      strcpy(OutRecord->ErrorMessage, "Illegally preceded by EXTEND.");
      OutRecord->Fatal = 1;
      OutRecord->Extend = 0;
    }

  if (InRecord->IndexValid)
    {
      strcpy(OutRecord->ErrorMessage, "Illegally preceded by INDEX.");
      OutRecord->Fatal = 1;
      OutRecord->IndexValid = 0;
    }

  if (InRecord->Operand[0] == 0)
    {
      strcpy(OutRecord->ErrorMessage, "Operand is missing.");
      OutRecord->Fatal = 1;
      return (0);
    }

  // The idea here is that the operand is a decimal number, of which the
  // lower two digits are simply placed in the output, whereas the upper two
  // digits are multiplied by 128 before been added to the output.
  // (Isn't the sscanf clever?  The final %c checks for garbage following
  // the decimal number.)
 
  if (sscanf(InRecord->Operand,"%u%c", &Value, &c) != 1)
    {
      strcpy(OutRecord->ErrorMessage, "Operand is not a decimal number.");
      OutRecord->Fatal = 1;
      return (0);
    } 

  Value = (Value % 100) | ((Value / 100) << 7); 
  OutRecord->Words[0] = Value;

  return (0);
}

