/*
  Copyright 2004 Ronald S. Burkey <info@sandroid.org>
  
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

  Filename:     Parse2CADR.c
  Purpose:      Assembles the 2CADR and 2BCADR pseudo-ops.
  Mode:         07/09/04 RSB.   Adapted from 2FCADR.
*/

#include "yaYUL.h"
#include <stdlib.h>
#include <math.h>
#include <string.h>

//-------------------------------------------------------------------------
// Adjust superbank bits in terms of SBANK= and so on.
void FixSuperbankBits(ParseInput_t *InRecord, Address_t *Address, int *OutValue)
{
  if (Address->Fixed && Address->Banked)
    {
      if (Address->FB < 030)
        {
          if (InRecord->SBank.current.Super)
              *OutValue |= 0100;
          else
              *OutValue |= 0060;
        }
      else if (Address->FB >= 030 && Address->FB <= 033)
        {
          if (Address->Super)
              *OutValue |= 0100;
          else
              *OutValue |= 0060;
        }
      else if (Address->FB > 033 && Address->FB <= 037)
        {
          *OutValue |= 0060;
        }
      else
          *OutValue |= 0060;
    }
  else
      *OutValue |= 0060;
}

//-------------------------------------------------------------------------
// Returns non-zero on unrecoverable error.
int Parse2CADR(ParseInput_t *InRecord, ParseOutput_t *OutRecord)
{
  Address_t Address;
  int i;

  printf("--- 2CADR: i/p PC=%o FB=%o S=%d SB=%d\n", 
         InRecord->ProgramCounter.Value, InRecord->ProgramCounter.FB, InRecord->ProgramCounter.Super, InRecord->SBank.current.Super);

  IncPc(&InRecord->ProgramCounter, 2, &OutRecord->ProgramCounter);
  if (!OutRecord->ProgramCounter.Invalid && OutRecord->ProgramCounter.Overflow)
    {
      strcpy(OutRecord->ErrorMessage, "Next code may overflow storage.");
      OutRecord->Warning = 1;
    }

  OutRecord->EBank = InRecord->EBank;
  OutRecord->SBank = InRecord->SBank;
  OutRecord->NumWords = 2;
  OutRecord->Words[0] = 0;
  OutRecord->Words[1] = 0;

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
    
  i = FetchSymbolPlusOffset(&InRecord->ProgramCounter, InRecord->Operand, InRecord->Mod1, &Address);
  if (i)
    {
      sprintf(OutRecord->ErrorMessage, "Symbol \"%s\" undefined or offset bad", InRecord->Operand);
      OutRecord->Fatal = 1;
    }
  else
    {
      if (Address.Invalid)
        {
          strcpy(OutRecord->ErrorMessage, "Destination address not resolved.");
          OutRecord->Fatal = 1;
          return (0);
        }

      if (!Address.Address)
        {
          strcpy(OutRecord->ErrorMessage, "Destination is not a memory address.");
          OutRecord->Fatal = 1;
          return (0);
        }

      printf("--- 2CADR: symbol=%o (%o,%o) S=%d\n", Address.Value, Address.FB, Address.SReg, Address.Super);

      OutRecord->Words[0] = Address.SReg;

      if (InRecord->EBank.current.SReg >= 0 && InRecord->EBank.current.SReg < 01400)
        OutRecord->Words[1] = InRecord->EBank.current.SReg / 0400;
      else
        OutRecord->Words[1] = InRecord->EBank.current.EB;

      if (Address.SReg < 02000)
        ;
      else if (Address.SReg <= 07777)
        {
          if (Address.SReg < 04000)
              OutRecord->Words[1] |= (Address.FB << 10);
          else
              OutRecord->Words[1] |= ((Address.SReg / 02000) << 10);

          // Superbank processing.
          FixSuperbankBits(InRecord, &Address, &OutRecord->Words[1]);
        }
      else
        {
          strcpy(OutRecord->ErrorMessage, "Internal error implementing 2CADR.");
          OutRecord->Fatal = 1;
          return (0);
        }
      printf("--- 2CADR: o/p PC=%o FB=%o S=%d\n", OutRecord->ProgramCounter.Value, OutRecord->ProgramCounter.FB, OutRecord->ProgramCounter.Super);
    }

  return (0);  
}

