/*
  Copyright 2012 Jim Lawton <jim dot lawton at gmail dot com>

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

  Filename:     Utilities.c
  Purpose:      Useful utility functions for yaYUL.
  History:      2012-10-04 JL   Began.
 */

#include "yaYUL.h"
#include <stdlib.h>
#include <string.h>

//-------------------------------------------------------------------------
// Adjust superbank bits in terms of SBANK= and so on.
void FixSuperbankBits(ParseInput_t *record, Address_t *address, int *outValue)
{
    int sbfix = 0060;
    int tmpval = *outValue;

#if 0
    if (address->Fixed && address->Banked) {
        if (address->FB < 030) {
            if (record->SBank.current.Super)
                sbfix = 0100;
            else
                sbfix = 0060;
        } else if (address->FB >= 030 && address->FB <= 033) {
            if (address->Super)
                sbfix = 0100;
            else
                sbfix = 0060;
        } else if (address->FB > 033 && address->FB <= 037) {
            sbfix = 0060;
        } else {
            sbfix = 0060;
        }
    } else {
        sbfix = 0060;
    }
#else
    if (address->Fixed && address->Banked) {
        if (address->Super && !record->ProgramCounter.Super) {
            sbfix = 0100;
        } else {
            if (record->SBank.current.Super || record->ProgramCounter.Super)
                sbfix = 0100;
        }
    }
#endif

    *outValue |= sbfix;

#ifdef YAYUL_TRACE
    printf("--- %s: PC=(FB=%03o,super=%d) SB.super=%d addr=(bank=%03o,super=%d,value=%06o) fix=%05o value=%06o\n",
           __FUNCTION__,
           record->ProgramCounter.FB,
           record->ProgramCounter.Super,
           record->SBank.current.Super,
           address->FB,
           address->Super,
           tmpval,
           sbfix,
           *outValue);
#endif
}

//-------------------------------------------------------------------------
// Print an Address_t.
void PrintAddress(const Address_t *address)
{
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
    if (address->Fixed)
        printf("F");
    if (address->Invalid)
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
    if (address->Erasable)
        printf("EB=%03o|", address->EB);
    if (address->Fixed)
        printf("FB=%03o|", address->FB);
    printf("%06o", address->Value);
}

//-------------------------------------------------------------------------
// Print a Bank_t.
void PrintBank(const Bank_t *bank)
{
    printf(" %d ", bank->oneshotPending);
    PrintAddress(&bank->current);
    printf(" ");
    PrintAddress(&bank->last);
}

//-------------------------------------------------------------------------
// Print a ParseInput_t.
void PrintInputRecord(const ParseInput_t *record)
{
    PrintAddress(&record->ProgramCounter);
    printf(" ");
    PrintBank(&record->EBank);
    printf(" ");
    PrintBank(&record->SBank);
}

//-------------------------------------------------------------------------
// Print a ParseOutput_t.
void PrintOutputRecord(const ParseOutput_t *record)
{
    PrintAddress(&record->ProgramCounter);
    printf(" ");
    PrintBank(&record->EBank);
    printf(" ");
    PrintBank(&record->SBank);
}

//-------------------------------------------------------------------------
// Print a trace record.
void PrintTrace(const ParseInput_t *inRecord, const ParseOutput_t *outRecord)
{
    printf("---                                     -------------------------------EBANK------------------------------ -------------------------------SBANK------------------------------\n");
    printf("---     --------------PC--------------- 1S ---------------curr------------ --------------last------------- 1S --------------curr------------- -------------last--------------\n");
    printf("--- in  ", inRecord->Operator, inRecord->Operand);
    PrintInputRecord(inRecord);
    printf("\n");
    printf("--- out ", inRecord->Operator, inRecord->Operand);
    PrintOutputRecord(outRecord);
    printf("\n");
}
