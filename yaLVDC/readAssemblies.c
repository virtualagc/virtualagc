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
// Utility functions.

// Remove all carriage return or line feed characters from end of string.
static void
trim (char *s)
{
  int n;
  for (n = strlen (s) - 1; n >= 0 && (s[n] == '\n' || s[n] == '\r'); n--)
    s[n] = 0;
}

// Check an address for range violations.
static int
checkAddress (unsigned module, unsigned sector, unsigned syllable, unsigned loc)
{
  int retVal = 1;
  char buffer[32];
  if (module > 07)
    {
      sprintf (buffer, "0%o", module);
      pushErrorMessage ("Module out of range:", buffer);
      goto done;
    }
  if (sector > 017)
    {
      sprintf (buffer, "0%o", sector);
      pushErrorMessage ("Sector out of range:", buffer);
      goto done;
    }
  if (syllable > 2)
    {
      sprintf (buffer, "0%o", syllable);
      pushErrorMessage ("Syllable out of range:", buffer);
      goto done;
    }
  if (loc > 0377)
    {
      sprintf (buffer, "0%o", loc);
      pushErrorMessage ("Location out of range:", buffer);
      goto done;
    }
  retVal = 0;
  done: ;
  return (retVal);
}

//////////////////////////////////////////////////////////////////////////////
// Read the .tsv file.

static int firstPass = 1;
int rope[8][16][3][256]; // Initializes to all -1, meaning "unoccupied".
static int
readOctalListing (int count, char *filename)
{
#define MAX_LINE 1000
  int retVal = 1;
  int i, j, k, n;
  FILE *fp = NULL;
  char *buffer = NULL;
  unsigned currentModule = 0, currentSector = 0;

  if (firstPass != 0)
    {
      firstPass = 0;
      for (i = 0; i < 8; i++)
	for (j = 0; j < 16; j++)
	  for (k = 0; k < 3; k++)
	    for (n = 0; n < 256; n++)
	      rope[i][j][k][n] = -1;
    }

  fp = fopen (filename, "r");
  if (fp == NULL)
    {
      pushErrorMessage ("Cannot open file:", filename);
      goto done;
    }
  buffer = malloc (MAX_LINE + 1);
  if (buffer == NULL)
    {
      pushErrorMessage ("Out of memory", NULL);
      goto done;
    }

  while (NULL != fgets (buffer, MAX_LINE, fp))
    {
      unsigned loc, offset, syl0, syl1, syl2, mo, se;
      char vals[8][100], types[8];
      buffer[MAX_LINE] = 0;
      trim (buffer);

      i = sscanf (buffer, "SECTOR\t%o\t%o", &mo, &se);
      if (i == 2)
	{
	  if (checkAddress (mo, se, 0, 0))
	    goto done;
	  currentModule = mo;
	  currentSector = se;
	  continue;
	}

      // The format specification %[...] is supposed to omit the usual skipping
      // of leading spaces that %s entails, according to the documentation.
      // It does not do so.  My workaround is to replace ' ' by '@' before
      // doing sscanf.
      for (j = 0; buffer[j] != 0; j++)
	if (buffer[j] == ' ')
	  buffer[j] = '@';
      i = sscanf (
	  buffer,
	  "%o\t%[@0-7]\t%c\t%[@0-7]\t%c\t%[@0-7]\t%c\t%[@0-7]\t%c\t%[@0-7]\t%c\t%[@0-7]\t%c\t%[@0-7]\t%c\t%[@0-7]\t%c",
	  &offset, vals[0], &types[0], vals[1], &types[1], vals[2], &types[2],
	  vals[3], &types[3], vals[4], &types[4], vals[5], &types[5], vals[6],
	  &types[6], vals[7], &types[7]);
      for (j = 0; buffer[j] != 0; j++)
	if (buffer[j] == '@')
	  buffer[j] = ' ';
      for (k = 0; k < 8; k++)
	{
	  if (types[k] == '@')
	    types[k] = ' ';
	  for (j = 0; vals[k][j] != 0; j++)
	    if (vals[k][j] == '@')
	      vals[k][j] = ' ';
	}
      if (i == 17)
	{
	  if (checkAddress (currentModule, currentSector, 0, offset))
	    goto done;
	  for (j = 0; j < 8; j++)
	    {
	      int pd = 0, pi10 = 0, pi01 = 0, pi11 = 0;
	      loc = offset + j;
	      if (strlen (vals[j]) != 11)
		{
		  pushErrorMessage ("Octal field is wrong length:", vals[j]);
		  goto done;
		}
	      if (types[j] == ' ')
		{
		  if (strcmp (vals[j], "           "))
		    {
		      pushErrorMessage ("Octal should be empty:", vals[j]);
		      goto done;
		    }
		  continue;
		}
	      if (types[j] == 'S')
		{
		  pushErrorMessage ("Simplex not supported", NULL);
		  goto done;
		}
	      if (types[j] != 'D')
		{
		  pushErrorMessage ("Unknown octal field type", NULL);
		  goto done;
		}
	      // Analyze vals[j] to determine its pattern.  There are 4 choices:
	      //	"%05o %05o"
	      //	"%05o      "
	      //        "      %o5o"
	      //	" %09o "
	      // These are related to 4 variables, pd, pi10, pi01, and pi11
	      // which count the number of places matching the pattern.  The
	      // variable with 11 matches is the winner.
	      for (k = 0; k < 11; k++)
		{
		  char c = vals[j][k];
		  int octal, space;
		  space = (c == ' ');
		  octal = (c >= '0' && c <= '7');
		  if (!space && !octal)
		    {
		      pushErrorMessage ("Illegal octal pattern A:", vals[j]);
		      goto done;
		    }
		  if (k == 0)
		    {
		      if (space)
			{
			  pd++;
			  pi01++;
			}
		      else
			{
			  pi10++;
			  pi11++;
			}
		    }
		  else if (k == 10)
		    {
		      if (space)
			{
			  pd++;
			  pi10++;
			}
		      else
			{
			  pi01++;
			  pi11++;
			}
		    }
		  else if (k == 5)
		    {
		      if (octal)
			pd++;
		      else
			{
			  pi01++;
			  pi10++;
			  pi11++;
			}
		    }
		  else if (k < 5)
		    {
		      if (octal)
			{
			  pd++;
			  pi10++;
			  pi11++;
			}
		      else
			pi01++;
		    }
		  else if (k > 5)
		    {
		      if (octal)
			{
			  pd++;
			  pi01++;
			  pi11++;
			}
		      else
			pi10++;
		    }
		}
	      if (pd == 11)
		{
		  sscanf (vals[j], " %o", &syl2);
		  rope[currentModule][currentSector][2][loc] = syl2;
		  if (rope[currentModule][currentSector][0][loc] != -1
		      || rope[currentModule][currentSector][1][loc] != -1)
		    {
		      pushErrorMessage (
			  "Conflict between instruction and data memory", NULL);
		      goto done;
		    }
		}
	      else if (pi10 == 11)
		{
		  sscanf (vals[j], "%o", &syl1);
		  rope[currentModule][currentSector][1][loc] = syl1;
		  if (rope[currentModule][currentSector][2][loc] != -1)
		    {
		      pushErrorMessage (
			  "Conflict between instruction and data memory", NULL);
		      goto done;
		    }
		}
	      else if (pi01 == 11)
		{
		  sscanf (vals[j], "      %o", &syl0);
		  rope[currentModule][currentSector][0][loc] = syl0;
		  if (rope[currentModule][currentSector][2][loc] != -1)
		    {
		      pushErrorMessage (
			  "Conflict between instruction and data memory", NULL);
		      goto done;
		    }
		}
	      else if (pi11 == 11)
		{
		  sscanf (vals[j], "%o %o", &syl1, &syl0);
		  rope[currentModule][currentSector][1][loc] = syl1;
		  rope[currentModule][currentSector][0][loc] = syl0;
		  if (rope[currentModule][currentSector][2][loc] != -1)
		    {
		      pushErrorMessage (
			  "Conflict between instruction and data memory", NULL);
		      goto done;
		    }
		}
	      else
		{
		  pushErrorMessage ("Illegal octal pattern B:", buffer);
		  goto done;
		}
	    }
	  continue;
	}

      // We ignore comments and blank lines.  But everything else (other that
      // what we've already processed above) is an error.
      if (buffer[0] == '#')
	continue;
      for (j = 0; buffer[j] != 0; j++)
	if (!isspace(buffer[j]))
	  {
	    pushErrorMessage ("Corrupt octal-listing line:", buffer);
	    goto done;
	  }
    }

  retVal = 0;
  done: ;
  if (fp != NULL)
    fclose (fp);
  if (buffer != NULL)
    free (buffer);
  return (retVal);
#undef MAX_LINE
}

//////////////////////////////////////////////////////////////////////////////
// Read the .sym file.

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
    {
      pushErrorMessage ("Cannot open file:", filename);
      goto done;
    }
  buffer = malloc (MAX_LINE + 1);
  name = malloc (MAX_LINE + 1);
  if (buffer == NULL || name == NULL)
    {
      pushErrorMessage ("Out of memory", NULL);
      goto done;
    }

  while (NULL != fgets (buffer, MAX_LINE, fp))
    {
      unsigned module, sector, syllable, loc;
      int i;
      buffer[MAX_LINE] = 0;
      trim (buffer);
      i = sscanf (buffer, "%s\t%o\t\%o\t%o\t%o", name, &module, &sector,
		  &syllable, &loc);
      if (i != 5)
	{
	  pushErrorMessage ("Ill-formed symbol table line:", buffer);
	  goto done;
	}
      i = strlen (name);
      if (i < 1 || i > 9 || (i > 6 && !isdigit(name[0])))
	{
	  pushErrorMessage ("Symbol length wrong:", name);
	  goto done;
	}
      if (checkAddress (module, sector, syllable, loc))
	goto done;
      if (numSymbols >= maxSymbols)
	{
	  maxSymbols += 1000;
	  symbols = realloc (symbols, maxSymbols * sizeof(symbol_t));
	  if (symbols == NULL)
	    {
	      pushErrorMessage ("Out of memory", NULL);
	      goto done;
	    }
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
// Read the .src file.

sourceLine_t *sourceLines = NULL;
int numSourceLines = 0;
static int maxSourceLines = 0;
static int
readSourceLines (int count, char *filename)
{
#define MAX_LINE 1000
  int retVal = 1;
  FILE *fp = NULL;
  char *buffer = NULL;
  char *rawline = NULL;
  char *line = NULL;

  fp = fopen (filename, "r");
  if (fp == NULL)
    {
      pushErrorMessage ("Cannot open file:", filename);
      goto done;
    }
  buffer = malloc (MAX_LINE + 1);
  rawline = malloc (MAX_LINE + 1);
  if (buffer == NULL || rawline == NULL)
    {
      pushErrorMessage ("Out of memory", NULL);
      goto done;
    }

  while (NULL != fgets (buffer, MAX_LINE, fp))
    {
      unsigned module, sector, syllable, loc;
      int i;
      buffer[MAX_LINE] = 0;
      trim (buffer);
      i = sscanf (buffer, "%o\t\%o\t%o\t%o\t%[^\n]", &module, &sector,
		  &syllable, &loc, rawline);
      if (i != 5)
	{
	  pushErrorMessage ("Ill-formed source-table line:", buffer);
	  goto done;
	}
      line = malloc (strlen (rawline) + 1);
      if (line == NULL)
	{
	  pushErrorMessage ("Out of memory", NULL);
	  goto done;
	}
      strcpy (line, rawline);
      if (checkAddress (module, sector, syllable, loc))
	goto done;
      if (numSourceLines >= maxSourceLines)
	{
	  maxSourceLines += 1000;
	  sourceLines = realloc (sourceLines,
				 maxSourceLines * sizeof(sourceLine_t));
	  if (sourceLines == NULL)
	    {
	      pushErrorMessage ("Out of memory", NULL);
	      goto done;
	    }
	}
      sourceLines[numSourceLines].line = line;
      line = NULL;
      sourceLines[numSourceLines].module = module;
      sourceLines[numSourceLines].sector = sector;
      sourceLines[numSourceLines].syllable = syllable;
      sourceLines[numSourceLines].loc = loc;
      numSourceLines++;
    }

  retVal = 0;
  done: ;
  if (fp != NULL)
    fclose (fp);
  if (buffer != NULL)
    free (buffer);
  if (rawline != NULL)
    free (rawline);
  if (line != NULL)
    free (line);
  return (retVal);
#undef MAX_LINE
}

//////////////////////////////////////////////////////////////////////////////
// Provide various sorting orders for symbol table and source table.

// We are only interested in accessing the source table as sorted by addresses.
// The symbol table we are interested in accessing either by name or else by
// address.  We use the original structures for the sorts by address, and
// a new structure called symbolsByName for (you guessed it!) the symbols
// sorted by name.

int
cmpSourceByAddress (const void *r1, const void *r2)
{
#define e1 ((sourceLine_t *) r1)
#define e2 ((sourceLine_t *) r2)
  if (e1->module < e2->module)
    return (-1);
  if (e1->module > e2->module)
    return (1);
  if (e1->sector < e2->sector)
    return (-1);
  if (e1->sector > e2->sector)
    return (1);
  if (e1->syllable < e2->syllable)
    return (-1);
  if (e1->syllable > e2->syllable)
    return (1);
  if (e1->loc < e2->loc)
    return (-1);
  if (e1->loc > e2->loc)
    return (1);
  return (strcmp (e1->line, e2->line));
#undef e1
#undef e2
}

int
cmpSymbolsByAddress (const void *r1, const void *r2)
{
#define e1 ((symbol_t *) r1)
#define e2 ((symbol_t *) r2)
  if (e1->module < e2->module)
    return (-1);
  if (e1->module > e2->module)
    return (1);
  if (e1->sector < e2->sector)
    return (-1);
  if (e1->sector > e2->sector)
    return (1);
  if (e1->syllable < e2->syllable)
    return (-1);
  if (e1->syllable > e2->syllable)
    return (1);
  if (e1->loc < e2->loc)
    return (-1);
  if (e1->loc > e2->loc)
    return (1);
  return (strcmp (e1->name, e2->name));
#undef e1
#undef e2
}

int
cmpSymbolsByName (const void *r1, const void *r2)
{
#define e1 ((symbol_t *) r1)
#define e2 ((symbol_t *) r2)
  int i;
  i = strcmp (e1->name, e2->name);
  if (i)
    return (i);
  return (cmpSymbolsByAddress (r1, r2));
#undef e1
#undef e2
}

symbol_t *symbolsByName = NULL;
int numSymbolsByName = 0;
static int
sortTables (void)
{
  int retVal = 1;
  int i, j;

// First do all the sorting.
  qsort (sourceLines, numSourceLines, sizeof(sourceLine_t), cmpSourceByAddress);
  qsort (symbols, numSymbols, sizeof(symbol_t), cmpSymbolsByAddress);
  symbolsByName = malloc (numSymbols * sizeof(symbol_t));
  if (symbolsByName == NULL)
    {
      pushErrorMessage ("Out of memory", "");
      goto done;
    }
  memcpy (symbolsByName, symbols, numSymbols * sizeof(symbol_t));
  numSymbolsByName = numSymbols;
  qsort (symbolsByName, numSymbolsByName, sizeof(symbol_t), cmpSymbolsByName);

// Now remove duplicates.
  if (numSourceLines > 0)
    {
      for (i = 0, j = 0; i < numSourceLines; i++)
	{
	  if (cmpSourceByAddress (&sourceLines[j], &sourceLines[i]))
	    {
	      j++;
	      if (i != j)
		{
		  if (sourceLines[j].line != NULL)
		    free (sourceLines[j].line);
		  memcpy (&sourceLines[j], &sourceLines[i],
			  sizeof(sourceLine_t));
		  sourceLines[i].line = NULL;
		}
	    }
	  else
	    {
	      if (i != j)
		{
		  free (sourceLines[i].line);
		  sourceLines[i].line = NULL;
		}
	    }
	}
      numSourceLines = j + 1;
    }
  if (numSymbols > 0)
    {
      for (i = 0, j = 0; i < numSymbols; i++)
	{
	  if (cmpSymbolsByAddress (&symbols[j], &symbols[i]))
	    {
	      j++;
	      if (i != j)
		{
		  memcpy (&symbols[j], &symbols[i], sizeof(symbol_t));
		}
	    }
	}
      numSymbols = j + 1;
    }
  if (numSymbolsByName > 0)
    {
      for (i = 0, j = 0; i < numSymbolsByName; i++)
	{
	  if (cmpSymbolsByName (&symbolsByName[j], &symbolsByName[i]))
	    {
	      j++;
	      if (i != j)
		{
		  memcpy (&symbolsByName[j], &symbolsByName[i],
			  sizeof(symbol_t));
		}
	    }
	}
      numSymbolsByName = j + 1;
    }

  retVal = 0;
  done: ;
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
	{
	  pushErrorMessage ("Out of memory", NULL);
	  goto done;
	}
      sprintf (filename, "%s.tsv", assemblyBasenames[i]);
      if (readOctalListing (i, filename))
	goto done;
      sprintf (filename, "%s.sym", assemblyBasenames[i]);
      if (readSymbolTable (i, filename))
	goto done;
      sprintf (filename, "%s.src", assemblyBasenames[i]);
      if (readSourceLines (i, filename))
	goto done;
      if (sortTables ())
	goto done;
    }

  retVal = 0;
  done: ;
  if (filename != NULL)
    free (filename);
  return (retVal);
}
