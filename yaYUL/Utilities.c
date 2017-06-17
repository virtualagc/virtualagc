/*
 *  Copyright 2012,2016 Jim Lawton <jim dot lawton at gmail dot com>
 *
 *  This file is part of yaAGC.
 *
 *  yaAGC is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  yaAGC is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with yaAGC; if not, write to the Free Software
 *  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 *
 *  Filename:   Utilities.c
 *  Purpose:    Useful utility functions for yaYUL.
 *  History:    2012-10-04 JL   Began.
 *              2016-10-21 RSB  Bypass the use of sbfix for blk2.
 *              2016-11-02 RSB  Added provision for --trace.
 *              2016-11-03 RSB  Added the "unestablished" state for superbits.
 *                              It *still* doesn't work like I expect, but
 *                              at least it lets me assemble Sunburst 120
 *                              (and all prior AGC programs).
 *              2017-01-30 MAS  Added a function to calculate parity.
 *              2017-06-17 MAS  Killed the FixSuperbankBits function and
 *                              split up printing of SBanks and EBanks.
 */

#include "yaYUL.h"
#include <stdlib.h>
#include <stdint.h>
#include <string.h>

//-------------------------------------------------------------------------
// Print an Address_t.
void
PrintAddress(const Address_t *address)
{
  printf("|");
  if (address->Invalid)
    printf("I");
  else
    printf(" ");
  if (address->Constant)
    printf("C");
  else
    printf(" ");
  if (address->Address)
    printf("A");
  else
    printf(" ");
  if (address->Erasable)
    printf("E");
  else if (address->Fixed)
    printf("F");
  else
    printf(" ");
  if (address->Banked)
    printf("B");
  else
    printf(" ");
  if (address->Super)
    printf("S");
  else
    printf(" ");
  if (address->Overflow)
    printf("O");
  else
    printf(" ");
  printf("|SREG=%04o|", address->SReg);
  if (!address->Invalid)
    {
      if (address->Erasable)
        printf("EB=%03o|", address->EB);
      if (address->Fixed)
        printf("FB=%03o|", address->FB);
    }
  else
    {
      printf("      |");
    }
  printf("%06o|", address->Value);
}

//-------------------------------------------------------------------------
// Print an EBank_t.
void
PrintEBank(const EBank_t *bank)
{
  printf("|%d", bank->oneshotPending);
  PrintAddress(&bank->current);
  PrintAddress(&bank->last);
}

//-------------------------------------------------------------------------
// Print an SBank_t.
void
PrintSBank(const SBank_t *bank)
{
  printf("|%d|%u|%u|", bank->oneshotPending, bank->current, bank->last);
}

//-------------------------------------------------------------------------
// Print a ParseInput_t.
void
PrintInputRecord(const ParseInput_t *record)
{
  PrintAddress(&record->ProgramCounter);
  printf(" ");
  PrintEBank(&record->EBank);
  printf(" ");
  PrintSBank(&record->SBank);
}

//-------------------------------------------------------------------------
// Print a ParseOutput_t.
void
PrintOutputRecord(const ParseOutput_t *record)
{
  PrintAddress(&record->ProgramCounter);
  printf(" ");
  PrintEBank(&record->EBank);
  printf(" ");
  PrintSBank(&record->SBank);
}

//-------------------------------------------------------------------------
// Print a trace record.
void
PrintTrace(const ParseInput_t *inRecord, const ParseOutput_t *outRecord)
{
  printf(
      "---    +--------------PC---------------+ +1S-------------curr-------------EBANK-------------last------------+ +1S-------------curr-------------SBANK-------------last------------+\n");
  printf("--- in ");
  PrintInputRecord(inRecord);
  printf("\n");
  printf("--- out");
  PrintOutputRecord(outRecord);
  printf("\n");
}

//-------------------------------------------------------------------------
// Calculat the parity bit for a data word.
int
CalculateParity(int Value)
{
    int p = 1;
    uint16_t n = Value;

    while (n)
    {
        n &= (n - 1);
        p = !p;
    }

    return p;
}
