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

  Filename:     ParseERASE.c
  Purpose:      Assembles the ERASE pseudo-op.
  Mod History:  04/19/03 RSB   Began.
                09/04/04 RSB   Eliminated range allocation (i.e.,
                               "ERASE start - end"). It turns out
                               that this is exactly the same as
                               "EQUALS start".
*/

#include "yaYUL.h"
#include <stdlib.h>
#include <string.h>

#if 0
//------------------------------------------------------------------------
// Figure out what erasable bank a pseudo address (i.e., a linear 
// address from 0-0117777) is in.  Return values are:
//      -2      Not in erasable memory.
//      -1      Unbanked (00000-01377)
//       0      Bank 0   (00000-00377) (won't happen)
//       1      Bank 1   (00400-00777) (won't happen)
//       2      Bank 2   (01000-01377) (won't happen)
//       3      Bank 3   (01400-01777)
//              ...
//       7      Bank 7   (03400-03777)

int
GetErasableBank (int LinearAddress)
{
  if (LinearAddress < 0 || LinearAddress > 03777)
    return (-2);
  if (LinearAddress < 01400)
    return (-1);
  return (LinearAddress / 0400);    
}
#endif

//------------------------------------------------------------------------
// Return non-zero on unrecoverable error.

int 
ParseERASE(ParseInput_t *InRecord, ParseOutput_t *OutRecord)
{
  int Value, i;

  IncPc(&InRecord->ProgramCounter, 1, &OutRecord->ProgramCounter);

  if (!OutRecord->ProgramCounter.Invalid && OutRecord->ProgramCounter.Overflow)
    {
      strcpy (OutRecord->ErrorMessage, "Next code may overflow storage.");
      OutRecord->Warning = 1;
    }

  OutRecord->Bank = InRecord->Bank;

  if (InRecord->Extend && !InRecord->IndexValid)
    {
      strcpy (OutRecord->ErrorMessage, "Illegally preceded by EXTEND.");
      OutRecord->Fatal = 1;
      OutRecord->Extend = 0;
    }

  if (InRecord->IndexValid)
    {
      strcpy(OutRecord->ErrorMessage, "Illegally preceded by INDEX.");
      OutRecord->Fatal = 1;
      OutRecord->IndexValid = 0;
    }

  i = GetOctOrDec(InRecord->Operand, &Value);
  if (!i)
    {
      if (Value < 0)
        {
          strcpy(OutRecord->ErrorMessage, "Address increment is negative.");
          OutRecord->Warning = 1;
        }
      else
        {
          // There are really two cases here.  Normally, the operand is
          // simply a number, and that's the end of it.  But it's also
          // possible that Mod1 is "-", and Mod2 is another number, in 
          // which case we want to allocate a range.
          if (!strcmp(InRecord->Mod1, "-"))
            {
#if 0
              // This is the range case, "ERASE n - m".
              i = GetOctOrDec(InRecord->Mod2, &Value2);
              Value2++;
              if (i)
                {
                  strcpy(OutRecord->ErrorMessage, "End of range missing or illegal.");
                  OutRecord->Fatal = 1;
                }
              else if (Value2 <= Value)
                {
                  strcpy(OutRecord->ErrorMessage, "Ending address precedes starting address.");
                  OutRecord->Fatal = 1;
                }
              else
                {
                  ParseOutput_t Dummy = { { 0 } }, Dummy2 = { { 0 } };
                  PseudoToSegmented(Value, &Dummy);
                  PseudoToSegmented(Value2, &Dummy2);
                  if (Dummy.Fatal || Dummy.Warning || Dummy2.Fatal || Dummy2.Warning || 
                      Dummy.ProgramCounter.Invalid || !Dummy.ProgramCounter.Erasable || 
                      Dummy2.ProgramCounter.Invalid || !Dummy2.ProgramCounter.Erasable || 
                      Dummy.ProgramCounter.Banked != Dummy2.ProgramCounter.Banked || 
                      Dummy.ProgramCounter.EB != Dummy2.ProgramCounter.EB)
                    {
                      strcpy(OutRecord->ErrorMessage, "May span bank boundary.");
                      OutRecord->Warning = 1;
                    }
                  InRecord->ProgramCounter = Dummy.ProgramCounter;
                  OutRecord->ProgramCounter = Dummy2.ProgramCounter;
                }
#else // 0
              //char Mod1[1 + MAX_LINE_LENGTH], Mod2[1 + MAX_LINE_LENGTH];

              //strcpy(Mod1, InRecord->Mod1);
              //strcpy(Mod2, InRecord->Mod2);
              //*InRecord->Mod1 = 0;
              //*InRecord->Mod2 = 0;
              //strcpy(InRecord->Operator, "EQUALS");            
              ParseEQUALS(InRecord, OutRecord);

              //strcpy(InRecord->Mod1, Mod1);
              //strcpy(InRecord->Mod2, Mod2);
              //strcpy(InRecord->Operator, "ERASE");
#endif // 0
            }
          else
            {  
              // This is the normal case, "ERASE n".
              if (0 != *InRecord->Mod1 && !OutRecord->Fatal)
                {
                  strcpy(OutRecord->ErrorMessage, "Extra fields are present.");
                  OutRecord->Warning = 1;
                }

              IncPc(&InRecord->ProgramCounter, 1 + Value, &OutRecord->ProgramCounter);

              if (!OutRecord->ProgramCounter.Invalid)
                {
                  if (!OutRecord->ProgramCounter.Erasable)
                    {
                      strcpy (OutRecord->ErrorMessage, "Not in erasable memory.");
                      OutRecord->Fatal = 1;
                    }
                  else if (OutRecord->ProgramCounter.Overflow)
                    {
                      strcpy (OutRecord->ErrorMessage, "May overflow memory bank.");
                      OutRecord->Warning = 1;
                    }
                }
            }
        }
    }
  else if (0 != *InRecord->Operand)
    {
      // Note that if the Operand field is simply missing, it's legal.
      strcpy (OutRecord->ErrorMessage, "Illegal number.");
      OutRecord->Fatal = 1;
    }  
  return (0);  
}


