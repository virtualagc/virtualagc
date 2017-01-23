/*
  Copyright 2003,2009,2016 Ronald S. Burkey <info@sandroid.org>

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
                08/21/16 RSB    Adapted for --block1.

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
static int PriorPassUsedInBank[NUM_FIXED_BANKS] = { 0 };
static int UsedInBank[NUM_FIXED_BANKS] = { 0 };

void SaveUsedCounts(void)
{
  memcpy (PriorPassUsedInBank, UsedInBank, sizeof(PriorPassUsedInBank));
}
int GetPriorBankCount(int bank)
{
    if (bank < 0 || bank >= NUM_FIXED_BANKS)
        return (0);

    return (PriorPassUsedInBank[bank]);
}

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

    for (i = (Block1 ? 1 : 0); i < (Block1 ? 035 : NUM_FIXED_BANKS); i++) {
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
    int Count = 0, bank = 0;

    if (pc->Invalid || !pc->Address || !pc->Fixed || pc->Overflow)
        return;

    if (pc->Banked) {
        Count = pc->SReg - (Block1 ? 06000 : 02000);
        bank = pc->FB + 010 * pc->Super;
    } else if (pc->Unbanked) {
        if (Block1) {
            if (pc->SReg >= 02000 && pc->SReg < 04000) {
                Count = pc->SReg - 02000;
                bank = 1;
            } else if (pc->SReg >= 04000 && pc->SReg < 05777) {
                // Note:  05777 is used instead of 06000 for a reason.
                // It's a kludge, but address 05777 is used out of order
                // (it's the "standard locations for extending bits"
                // in the fixed-fixed interpreter section), and it
                // would fool us into thinking the bank is full, when
                // it really isn't.
                Count = pc->SReg - 04000;
                bank = 2;
            } else
                return;
        } else {
          if (pc->SReg >= 04000 && pc->SReg < 06000) {
              Count = pc->SReg - 04000;
              bank = 2;
          } else if (pc->SReg >= 06000 && pc->SReg < 010000) {
              Count = pc->SReg - 06000;
              bank = 3;
          } else
              return;
        }
    }  

    // We know from the tests performed above that Count is in the range
    // 0-01777.
    if (Count > UsedInBank[bank])
        UsedInBank[bank] = Count;
}

int
ParseSECSIZ(ParseInput_t *InRecord, ParseOutput_t *OutRecord)
{
  int Count = 0, bank = 0, newSize;
  unsigned sectionSize;
  Address_t *pc;

  if (1 != sscanf (InRecord->Operand, "%o", &sectionSize) || sectionSize == 0)
    goto error;

  OutRecord->ProgramCounter = InRecord->ProgramCounter;
  OutRecord->Extend = InRecord->Extend;
  OutRecord->EBank = InRecord->EBank;
  OutRecord->SBank = InRecord->SBank;
  OutRecord->Index = InRecord->Index;
  OutRecord->IndexValid = InRecord->IndexValid;

  pc = &InRecord->ProgramCounter;
  if (pc->Invalid || !pc->Address || !pc->Fixed || pc->Overflow)
    goto error;

  if (pc->Banked) {
      Count = pc->SReg - (Block1 ? 06000 : 02000);
      bank = pc->FB + 010 * pc->Super;
  } else if (pc->Unbanked) {
      if (Block1) {
          if (pc->SReg >= 02000 && pc->SReg < 04000) {
              Count = pc->SReg - 02000;
              bank = 1;
          } else if (pc->SReg >= 04000 && pc->SReg < 05777) {
              // Note:  05777 is used instead of 06000 for a reason.
              // It's a kludge, but address 05777 is used out of order
              // (it's the "standard locations for extending bits"
              // in the fixed-fixed interpreter section), and it
              // would fool us into thinking the bank is full, when
              // it really isn't.
              Count = pc->SReg - 04000;
              bank = 2;
          } else
              goto error;
      } else {
        if (pc->SReg >= 04000 && pc->SReg < 06000) {
            Count = pc->SReg - 04000;
            bank = 2;
        } else if (pc->SReg >= 06000 && pc->SReg < 010000) {
            Count = pc->SReg - 06000;
            bank = 3;
        } else
            goto error;
      }
  }

  newSize = Count + sectionSize;
  if (newSize > 02000)
    {
      UsedInBank[bank] = 02000;
      goto error;
    }
  if (newSize > UsedInBank[bank])
    UsedInBank[bank] = newSize;

  return (0);
  error:;
  strcpy(OutRecord->ErrorMessage, "Irregular SECSIZ.");
  OutRecord->Warning = 1;
  return (1);
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

#ifdef YAYUL_TRACE
        PrintTrace(InRecord, OutRecord);
#endif

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
                OutRecord->ProgramCounter.Super = 1;
                OutRecord->ProgramCounter.FB = Value - 010;
            } else {
                OutRecord->ProgramCounter.Super = 0;
                OutRecord->ProgramCounter.FB = Value;
            }

            if (Block1 && Value >= 0 && Value <= 2)
              {
                OutRecord->ProgramCounter.Value = 02000 * Value;
                OutRecord->ProgramCounter.SReg = 02000 * Value;
                OutRecord->ProgramCounter.Banked = 0;
                OutRecord->ProgramCounter.Unbanked = 1;
              }
            else if (Block1)
              {
                OutRecord->ProgramCounter.Value = 06000;
                OutRecord->ProgramCounter.SReg = 06000;
              }
            else if (Value == 2 || Value == 3)
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

#ifdef YAYUL_TRACE
    PrintTrace(InRecord, OutRecord);
#endif

    return (0);
}
