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
 * Filename:    processPRS.c
 * Purpose:     Process pending PRS activity, on the basis of contents
 *              of state.prs and state.prsChange, in between emulation
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
processPRS(void)
{
  int retVal = 1;

  if (!ptc)
    return (0);

  if (state.prsChange != -1 && state.prsChange != 1)
    goto done;
  if (state.prsChange != -1)
    {

      // Note that this is not necessarily a different value than the last
      // value PRS wrote to it.  state.prs contains the value that is
      // supposed to be sent to the printer.

      // ... now do something with this information ...
    }

  retVal = 0;
  done: ;
  return (retVal);
}
