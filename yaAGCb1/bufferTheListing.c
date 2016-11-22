/*
 * Copyright 2016 Ronald S. Burkey <info@sandroid.org>
 *
 * This file is part of yaAGC.
 *
 * yaAGC is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * yaAGC is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with yaAGC; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 *
 * In addition, as a special exception, Ronald S. Burkey gives permission to
 * link the code of this program with the Orbiter SDK library (or with
 * modified versions of the Orbiter SDK library that use the same license as
 * the Orbiter SDK library), and distribute linked combinations including
 * the two. You must obey the GNU General Public License in all respects for
 * all of the code used other than the Orbiter SDK library. If you modify
 * this file, you may extend this exception to your version of the file,
 * but you are not obligated to do so. If you do not wish to do so, delete
 * this exception statement from your version.
 *
 * Filename:    bufferTheListing.c
 * Purpose:     Allows loading the program listing into RAM, and quick lookup
 *              by address.
 * Compiler:    GNU gcc.
 * Contact:     Ron Burkey <info@sandroid.org>
 * Reference:   http://www.ibiblio.org/apollo/index.html
 * Mods:        2016-09-03 RSB  Wrote.
 * 		2016-11-18 RSB	Added missing ctype.h.
 *
 * This program does not require any specially-formatted file from yaYUL, other
 * than the normal assembly listing.  It will also load listing files created
 * by John Pultorak's assembler, though it's hard to see much reason for it,
 * because it's essentially a free feature.
 *
 * Additional description of how to use this function and the global variables associated
 * with it are in yaAGC-Block1.h.  The function, bufferTheListing(), is used just
 * once, at power-up, and then subsequently the buffered listing can be accessed
 * for printing by looking up an address (in the "flat" address space) in
 * listingAddresses[], and then using the index retrieved in that way, accessing
 * the associated line in bufferedListing[].  The retrieved index will be -1 if the
 * address is not associated with a line of code.  For example,
 *      bufferedListing[listingAddresses[02030]]
 * is the line of code at address 2030, while
 *      bufferedListing[listingAddresses[flatten(04,07005)]]
 * is the line of code at banked address 04,7005.
 */

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include "yaAGCb1.h"

char bufferedListing[MAX_LISTING_LINES][MAX_LINE_LENGTH];
int maxDisplayedLineLength = MIN_LINE_LENGTH;
int maxDisplayedContext = 5;
int listingAddresses[035 * 02000];
int numListingLines = 0;

int
bufferTheListing(char *filename)
{
#define MAX_INPUT_LINE 4096
  int i, retVal = 2;
  FILE *fp = NULL;
  char *inputLine = NULL;

  // Fill in the listingAddresses[] array with default values interpreted
  // as "unused".
  for (i = 0; i < MEMORY_SIZE; i++)
    listingAddresses[i] = -1;

  // Allocate the line buffer.
  inputLine = malloc(MAX_INPUT_LINE);
  if (inputLine == NULL)
    goto done;

  // Open the file containing the source code listing.
  fp = fopen(filename, "r");
  if (fp == NULL)
    goto done;

  // Buffer the file in memory.
  while (NULL != fgets(inputLine, MAX_INPUT_LINE, fp))
    {
      char *s;
      if (numListingLines >= MAX_LISTING_LINES)
        {
          retVal = 1;
          break;
        }
      s = strstr(inputLine, "\n");
      if (*s)
        *s = 0;
      if (strlen(inputLine) >= MAX_LINE_LENGTH)
        {
          inputLine[MAX_LINE_LENGTH - 1] = 0;
          inputLine[MAX_LINE_LENGTH - 2] = '.';
          inputLine[MAX_LINE_LENGTH - 3] = '.';
          inputLine[MAX_LINE_LENGTH - 4] = '.';
        }
      strcpy(bufferedListing[numListingLines], inputLine);
      numListingLines++;
    }
  fclose(fp);
  fp = NULL;

  // Fill in the listingAddresses[] array with the flat addresses
  // corresponding to the buffered lines.  Or more accurately, given
  // a flat address in the rope, give the index into the lined buffer
  // corresponding to that address.  -1 means unused.
  for (i = 0; i < numListingLines; i++)
    {
      char c, *line;
      int found = 0;
      unsigned totalLine, fileLine, fileBank, fileOffset, fileFlat,
          effectiveAddress;

      line = bufferedListing[i];

      // We don't know if the listing is in John Pultorak's format
      // or yaYUL's so we check both.
      if (line[0] >= '0' && line[0] <= '7' && line[1] >= '0' && line[1] <= '7'
          && line[2] >= '0' && line[2] <= '7' && line[3] >= '0'
          && line[3] <= '7' && line[4] >= '0' && line[4] <= '7'
          && isspace(line[5]))
        found = 1;
      else if (4
          == sscanf(line, "%u,%u:%o%c", &totalLine, &fileLine, &fileFlat, &c)
          && isspace(c))
        {
          effectiveAddress = fileFlat;
          addressOkay: ;
          if (effectiveAddress < MEMORY_SIZE)
            {
              // Okay, we have an address corresponding to the line, and
              // we know that it is within the rope.  However, we don't want
              // to use it if the assembler has generated it for various
              // pseudo-ops rather than for an actual instruction ... which
              // would be legal, but just not something we want to display
              // in a program listing.
              char fields[5][MAX_LINE_LENGTH];
              int j;
              j = sscanf(line, "%s%s%s%s%s", fields[0], fields[1], fields[2],
                  fields[3], fields[4]);
              if (j >= 3 && (!strcmp(fields[2], "BANK") || !strcmp(fields[2], "SETLOC")
                  || !strcmp(fields[2], "EQUALS") || !strcmp(fields[2], "ERASE")))
                {
                }
              else if (j >= 4 && (!strcmp(fields[3], "EQUALS") || !strcmp(fields[3], "ERASE")))
                {
                }
              else if (j >= 5 && (!strcmp(fields[4], "=")))
                {
                }
              else
                found = 1;
            }
        }
      else if (5
          == sscanf(line, "%u,%u:%o,%o%c", &totalLine, &fileLine, &fileBank,
              &fileOffset, &c) && isspace(c))
        {
          effectiveAddress = fileBank * 02000 + (fileOffset % 02000);
          goto addressOkay;
        }
      // So at this point, if found is true, then effectiveAddress holds the
      // address we need to use.
      if (found)
        listingAddresses[effectiveAddress] = i;
    }

  retVal = 0;
  done:;
  if (fp != NULL)
    fclose(fp);
  if (inputLine != NULL)
    free(inputLine);
  return (retVal);
}
