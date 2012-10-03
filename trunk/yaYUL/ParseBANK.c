/*
  Copyright 2003,2009 Ronald S. Burkey <info@sandroid.org>

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

  Filename:     ParseBANK.c
  Purpose:      Assembles the BANK pseudo-op.
  History:      04/26/03 RSB    Began.
                06/28/09 RSB    Added HTML output.
                09/07/09 JL     Fixed typo in PrintBankCounts.

  I'm not actually certain what the BANK pseudo-op is supposed to do with 
  the banks in super-bank 1.  I allow those to be accepted, as bank 
  numbers 040-043.
 */

#include "yaYUL.h"
#include <stdlib.h>
#include <string.h>

//------------------------------------------------------------------------
// We need to keep a running total of the number of words used so far in
// each bank.   

#define NUM_FIXED_BANKS 044
static int UsedInBank[NUM_FIXED_BANKS] = { 0 };

//------------------------------------------------------------------------
// A function for clearing the UsedInBank array at the start of a pass.
void StartBankCounts(void)
{
    int i;

    for (i = 0; i < NUM_FIXED_BANKS; i++)
        UsedInBank[i] = 0;
}

//------------------------------------------------------------------------
// Check bank count.
int GetBankCount(int bank)
{
    if (bank < 0 || bank >= NUM_FIXED_BANKS)
        return (0);

    return (UsedInBank[bank]);
}

//------------------------------------------------------------------------
// Prints out a table showing how much of each bank is used.
void PrintBankCounts(void)
{
    int i;

    printf("Usage Table for Fixed-Memory Banks\n");
    printf("----------------------------------\n");

    if (HtmlOut != NULL)
        fprintf (HtmlOut, "<h1>Usage Table for Fixed-Memory Banks</h1>\n");

    for (i = 0; i < NUM_FIXED_BANKS; i++) {
        printf("Bank %02o:  %04o/2000 words used.\n", i, UsedInBank[i]);
        if (HtmlOut != NULL)
            fprintf(HtmlOut, "Bank %02o:  %04o/2000 words used.\n", i, UsedInBank[i]);
    }
}

//------------------------------------------------------------------------
// A function which can be used to update the UsedInBank array after
// assembling an instruction.  Basically, it's safe to call after any
// source line.
void UpdateBankCounts(Address_t *pc)
{
    int Count, bank;

    if (pc->Invalid || !pc->Address || !pc->Fixed || pc->Overflow)
        return;

    if (pc->Banked) {
        Count = pc->SReg - 02000;
        bank = pc->FB + 010 * pc->Super;
    } else if (pc->Unbanked) {
        if (pc->SReg >= 04000 && pc->SReg < 06000) {
            Count = pc->SReg - 04000;
            bank = 2;
        } else if (pc->SReg >= 06000 && pc->SReg < 010000) {
            Count = pc->SReg - 06000;
            bank = 3;
        } else
            return;
    }  

    // We know from the tests performed above that Count is in the range
    // 0-01777.
    if (Count > UsedInBank[bank])
        UsedInBank[bank] = Count;
}

//------------------------------------------------------------------------
// Return non-zero on unrecoverable error.

int 
ParseBANK(ParseInput_t *InRecord, ParseOutput_t *OutRecord)
{
    int Value, i;

    // Pass EXTEND through.
    OutRecord->Extend = InRecord->Extend;

    if (InRecord->IndexValid) {
        strcpy(OutRecord->ErrorMessage, "Illegally preceded by INDEX.");
        OutRecord->Fatal = 1;
        OutRecord->Index = 0;
    }

    // The case of no Operand has a special meaning.  It means simply to
    // advance the program counter by however many words have already
    // been used in the current bank.  It would be used after a SETLOC.
    if (!*InRecord->Operand) {
        OutRecord->ProgramCounter = InRecord->ProgramCounter;

        if (OutRecord->ProgramCounter.Invalid)
            return (0);

        if (!OutRecord->ProgramCounter.Address || !OutRecord->ProgramCounter.Fixed) {
            strcpy(OutRecord->ErrorMessage, "Works only for fixed-memory.");
            OutRecord->Fatal = 1;
            return (0);
        }

        if (OutRecord->ProgramCounter.Banked) {
            i = OutRecord->ProgramCounter.FB + 010 * OutRecord->ProgramCounter.Super;
            OutRecord->ProgramCounter.SReg = 02000 + UsedInBank[i];
            OutRecord->ProgramCounter.Value = 010000 + i * 02000 + UsedInBank[i];
        } else if (OutRecord->ProgramCounter.Value >= 04000 && OutRecord->ProgramCounter.Value <= 05777) {
            OutRecord->ProgramCounter.SReg = 04000 + UsedInBank[2];
            OutRecord->ProgramCounter.Value = OutRecord->ProgramCounter.SReg;
        } else if (OutRecord->ProgramCounter.Value >= 06000 && OutRecord->ProgramCounter.Value <= 07777) {
            OutRecord->ProgramCounter.SReg = 06000 + UsedInBank[3];
            OutRecord->ProgramCounter.Value = OutRecord->ProgramCounter.SReg;
        }

        return (0);
    }

    // Here's where we assume that an Operand field exists.
    i = GetOctOrDec(InRecord->Operand, &Value);
    if (!i) {
        if (Value >= 0 && Value <= 043) {
            OutRecord->ProgramCounter = (const Address_t) { 0 };
            OutRecord->ProgramCounter.Address = 1;
            OutRecord->ProgramCounter.SReg = 02000;
            OutRecord->ProgramCounter.Fixed = 1;
            OutRecord->ProgramCounter.Banked = 1;

            if (Value >= 040) {
#ifdef YAYUL_TRACE
                printf("--- BANK: setting superbank bit\n");
#endif
                OutRecord->ProgramCounter.Super = 1;
                OutRecord->ProgramCounter.FB = Value - 010;
            } else {
#ifdef YAYUL_TRACE
                printf("--- BANK: clearing superbank bit\n");
#endif
                OutRecord->ProgramCounter.Super = 0;
                OutRecord->ProgramCounter.FB = Value;
            }

            if (Value == 2 || Value == 3)
                OutRecord->ProgramCounter.Value = Value * 02000;
            else
                OutRecord->ProgramCounter.Value = 010000 + Value * 02000;

            OutRecord->ProgramCounter.Value += UsedInBank[Value];
            OutRecord->ProgramCounter.SReg += UsedInBank[Value];
        } else {
            strcpy(OutRecord->ErrorMessage, "BANK operand range is 00 to 43.");
            OutRecord->Fatal = 1;
            OutRecord->ProgramCounter = (const Address_t) { 0 };
            OutRecord->ProgramCounter.Invalid = 1;
        }
    } else {
        strcpy(OutRecord->ErrorMessage, "BANK pseudo-op has an invalid operand.");
        OutRecord->Fatal = 1;
        OutRecord->ProgramCounter = (const Address_t) { 0 };
        OutRecord->ProgramCounter.Invalid = 1;
    }

    // Make sure this prints properly in the output listing (?).
    InRecord->ProgramCounter = OutRecord->ProgramCounter;

    return (0);
}
