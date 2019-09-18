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
 * Filename:    readAssemblies.c
 * Purpose:     Reads a set of assembly files (i.e., files created by
 * 		yaASM.py) for yaLVDC.c.
 * Compiler:    GNU gcc.
 * Reference:   http://www.ibibio.org/apollo
 * Mods:        2019-09-18 RSB  Began.
 */

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include "yaLVDC.h"

//////////////////////////////////////////////////////////////////////////////

static int
readOctalListing (int count, char *filename)
{
  int retVal = 1;
  FILE *fp = NULL;

  fp = fopen (filename, "r");
  if (fp == NULL)
    goto done;

  retVal = 0;
  done: ;
  if (fp != NULL)
    fclose (fp);
  return (retVal);
}

//////////////////////////////////////////////////////////////////////////////

symbol_t *symbols = NULL;
int numSymbols = 0;
static int maxSymbols = 0;
static int
readSymbolTable (int count, char *filename)
{
#define MAX_LINE 1000
  int retVal = 1;
  FILE *fp = NULL;
  char *buffer = NULL;
  char *name = NULL;

  fp = fopen (filename, "r");
  if (fp == NULL)
    goto done;
  buffer = malloc (MAX_LINE + 1);
  if (buffer == NULL)
    goto done;
  name = malloc (MAX_LINE + 1);
  if (name == NULL)
    goto done;

  while (NULL != fgets (buffer, MAX_LINE, fp))
    {
      buffer[MAX_LINE] = 0;
      unsigned module, sector, syllable, loc;
      int i;
      i = sscanf (buffer, "%s\t%o\t\%o\t%o\t%o", name, &module, &sector,
		  &syllable, &loc);
      if (i != 5)
	goto done;
      i = strlen (name);
      if (i < 1 || i > 9 || (i > 6 && !isdigit(name[0])))
	goto done;
      if (module > 07)
	goto done;
      if (sector > 017)
	goto done;
      if (syllable > 2)
	goto done;
      if (loc > 0377)
	goto done;
      if (numSymbols >= maxSymbols)
	{
	  maxSymbols += 1000;
	  symbols = realloc (symbols, maxSymbols * sizeof(symbol_t));
	  if (symbols == NULL)
	    goto done;
	}
      // Note that if multiple assemblies are being read in, we use different
      // namespaces for them by adding a suffix ("@A", "@B", etc.) denoting
      // the assemblies after the first one.  For example, if there are 3
      // assemblies, each with a symbol called KZERO, then they'll show up in
      // the symbol table as KZERO, KZERO@A, and KZERO@B.  We don't need to do
      // that for the nameless constants.
      if (isdigit(name[0]) || count == 0)
	strcpy (symbols[numSymbols].name, name);
      else
	sprintf (symbols[numSymbols].name, "%s@%c", name, 'A' + count);
      symbols[numSymbols].module = module;
      symbols[numSymbols].sector = sector;
      symbols[numSymbols].syllable = syllable;
      symbols[numSymbols].loc = loc;
      numSymbols++;
    }

  retVal = 0;
  done: ;
  if (fp != NULL)
    fclose (fp);
  if (buffer != NULL)
    free (buffer);
  if (name != NULL)
    free (name);
  return (retVal);
#undef MAX_LINE
}

//////////////////////////////////////////////////////////////////////////////

static int
readSourceLines (int count, char *filename)
{
  int retVal = 1;
  FILE *fp = NULL;

  fp = fopen (filename, "r");
  if (fp == NULL)
    goto done;

  retVal = 0;
  done: ;
  if (fp != NULL)
    fclose (fp);
  return (retVal);
}

//////////////////////////////////////////////////////////////////////////////

int
readAssemblies (char *assemblyBasenames[], int maxAssemblies)
{
  int retVal = 1;
  int i;
  char *filename = NULL;

  for (i = 0; i < maxAssemblies; i++)
    {
      if (assemblyBasenames[i] == 0)
	break;
      filename = realloc (filename, strlen (assemblyBasenames[i]) + 5);
      if (filename == NULL)
	goto done;
      sprintf (filename, "%s.tsv", assemblyBasenames[i]);
      if (readOctalListing (i, filename))
	goto done;
      sprintf (filename, "%s.sym", assemblyBasenames[i]);
      if (readSymbolTable (i, filename))
	goto done;
      sprintf (filename, "%s.src", assemblyBasenames[i]);
      if (readSourceLines (i, filename))
	goto done;
    }

  retVal = 0;
  done: ;
  if (filename != NULL)
    free (filename);
  return (retVal);
}
