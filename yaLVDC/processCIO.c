/*
 * Copyright 2020 Ronald S. Burkey <info@sandroid.org>
 *
 * This file is part of yaAGC.
 *
 * yaAGC is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 * yaAGC is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with yaAGC; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 *
 * Filename:    processCIO.c
 * Purpose:     Process pending CIO activity, on the basis of contents
 *              of state.cio[] and state.cioChange, in between emulation
 *              of PTC instructions.
 * Compiler:    GNU gcc.
 * Reference:   http://www.ibibio.org/apollo
 * Mods:        2020-05-02 RSB  Began.
 */

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include "yaLVDC.h"

// Returns 0 on success, non-zero on fatal error.
int
processCIO (void)
{
  int retVal = 1;

  if (!ptc)
    return (0);

  if (state.cioChange < -1 || state.cioChange >= 01000)
    goto done;
  if (state.cioChange != -1)
    {

      // Note that a CIO to the port has been done by the code, but that's
      // not necessarily a change in the value stored in the array.
      // The action that led to being here is a CIO OPERAND; at this point,
      // state.cioChange == OPERAND, and state.cio[state.cioChange] == ACC.

      // ... now do something with this information ...
    }

  // ... if anything has happened externally that needs to change the state. cio[]
  // array so that the PTC software can read those ports later with a
  // CIO instruction, change the array elements now.  As far as I know, only ports
  // 0154, 0204, 0214, 0220 are input ports.

  retVal = 0;
  done: ;
  return (retVal);
}
