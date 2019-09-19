/*
 * Copyright 2019 Ronald S. Burkey <info@sandroid.org>
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
 * Filename:    pushErrorMessage.c
 * Purpose:     Maintains an error-message stack for yaLVDC.c.
 * Compiler:    GNU gcc.
 * Reference:   http://www.ibibio.org/apollo
 * Mods:        2019-09-19 RSB  Began.
 */

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include "yaLVDC.h"

char *errorMessageStack[MAX_ERROR_MESSAGES];
int numErrorMessages = 0;

// Note that part2 can be NULL.
int
pushErrorMessage (char *part1, char *part2)
{
  int retVal = 1;

  if (numErrorMessages >= MAX_ERROR_MESSAGES)
    goto done;
  if (part2 == NULL)
    part2 = "";
  errorMessageStack[numErrorMessages] = malloc (
      strlen (part1) + strlen (part2) + 2);
  if (errorMessageStack[numErrorMessages] == NULL)
    errorMessageStack[numErrorMessages] = "Out of memory";
  else
    sprintf (errorMessageStack[numErrorMessages], "%s %s", part1, part2);
  numErrorMessages++;

  retVal = 0;
  done: ;
  return (retVal);
}
