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
 * Filename:    processInterrupts.c
 * Purpose:     This function is used between emulations of LVDC/PTC
 *              instructions.  If external conditions require an interrupt
 *              on the next LVDC/PTC machine cycle, this function is the
 *              one that's supposed to notice that and to set up
 *              the emulation so that the interrupt actually occurs.
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
processInterrupts(void)
{
  int retVal = 1;

  if (!ptc)
    {

    }
  else
    {

    }

  retVal = 0;
  //done: ;
  return (retVal);
}
