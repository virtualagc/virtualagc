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
 * Filename:    readAssemblies.c
 * Purpose:     Reads a set of assembly files (i.e., files created by
 * 		yaASM.py) for yaLVDC.c.
 * Compiler:    GNU gcc.
 * Reference:   http://www.ibibio.org/apollo
 * Mods:        2019-09-18 RSB  Began.
 *              2020-05-01 RSB  Decided that the octals need to be stored
 *                              in RAM in a natural form for usage internally
 *                              by the emulator, as opposed to in the form
 *                              they were stored in the input file.
 *                              They'll now be aligned to the LSb.  I had
 *                              found that otherwise, it was just too
 *                              confusing for maintaining the software,
 *                              since I could never get it straight in my
 *                              head how much shifting needed to occur.
 */

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include <stdint.h>
#include "yaLVDC.h"

assembly_t assemblies[MAX_ASSEMBLIES];
int numAssemblies = 0;
int freezeAssemblies = 0;

//////////////////////////////////////////////////////////////////////////////
// Utility functions.

// Remove all carriage return or line feed characters from end of string.
static void
trim(char *s)
{
  int n;
  for (n = strlen(s) - 1; n >= 0 && (s[n] == '\n' || s[n] == '\r'); n--)
    s[n] = 0;
}

// Check an address for range violations.
static int
checkAddress(unsigned module, unsigned sector, unsigned syllable, unsigned loc)
{
  int retVal = 1;
  char buffer[32];
  if (module > 07)
    {
      sprintf(buffer, "0%o", module);
      printf("Module out of range: %s\n", buffer);
      goto done;
    }
  if (sector > 017)
    {
      sprintf(buffer, "0%o", sector);
      printf("Sector out of range: %s\n", buffer);
      goto done;
    }
  if (syllable > 2)
    {
      sprintf(buffer, "0%o", syllable);
      printf("Syllable out of range: %s\n", buffer);
      goto done;
    }
  if (loc > 0377)
    {
      sprintf(buffer, "0%o", loc);
      printf("Location out of range: %s\n", buffer);
      goto done;
    }
  retVal = 0;
  done: ;
  return (retVal);
}

//////////////////////////////////////////////////////////////////////////////
// Read the .tsv file.

state_t state =
  { 0 };
static int
readOctalListing(assembly_t *assembly, int count, char *filename)
{
#define MAX_LINE 1000
  int retVal = 1;
  int i, j, k;
  FILE *fp = NULL;
  char *buffer = NULL;
  unsigned currentModule = 0, currentSector = 0;

  printf("Reading octal file %s\n", filename);

  fp = fopen(filename, "r");
  if (fp == NULL)
    {
      printf("Cannot open file: %s\n", filename);
      goto done;
    }
  buffer = malloc(MAX_LINE + 1);
  if (buffer == NULL)
    {
      printf("Out of memory.\n");
      goto done;
    }

  while (NULL != fgets(buffer, MAX_LINE, fp))
    {
      unsigned loc, offset, syl0, syl1, syl2, mo, se;
      char vals[8][100], types[8];
      buffer[MAX_LINE] = 0;
      trim(buffer);

      i = sscanf(buffer, "SECTOR\t%o\t%o", &mo, &se);
      if (i == 2)
        {
          if (checkAddress(mo, se, 0, 0))
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
      i =
          sscanf(buffer,
              "%o\t%[@0-7]\t%c\t%[@0-7]\t%c\t%[@0-7]\t%c\t%[@0-7]\t%c\t%[@0-7]\t%c\t%[@0-7]\t%c\t%[@0-7]\t%c\t%[@0-7]\t%c",
              &offset, vals[0], &types[0], vals[1], &types[1], vals[2],
              &types[2], vals[3], &types[3], vals[4], &types[4], vals[5],
              &types[5], vals[6], &types[6], vals[7], &types[7]);
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
          if (checkAddress(currentModule, currentSector, 0, offset))
            goto done;
          for (j = 0; j < 8; j++)
            {
              int pd = 0, pi10 = 0, pi01 = 0, pi11 = 0, s, values[3], conflict;
              loc = offset + j;
              if (strlen(vals[j]) != 11)
                {
                  printf("Octal field is wrong length: %s\n", vals[j]);
                  goto done;
                }
              if (types[j] == ' ')
                {
                  if (strcmp(vals[j], "           "))
                    {
                      printf("Octal should be empty: %s\n", vals[j]);
                      goto done;
                    }
                  continue;
                }
              if (types[j] == 'S')
                {
                  printf("Simplex not supported.\n");
                  goto done;
                }
              if (types[j] != 'D')
                {
                  printf("Unknown octal field type.\n");
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
                      printf("Illegal octal pattern A: %s\n", vals[j]);
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
              conflict = 0;
              for (s = 0; s < 3; s++)
                values[s] = -1;
              if (pd == 11)
                {
                  sscanf(vals[j], " %o", &syl2);
                  values[2] = syl2 >> 1;
                  conflict = state.core[currentModule][currentSector][0][loc] != -1
                      || state.core[currentModule][currentSector][1][loc] != -1;
                }
              else if (pi10 == 11)
                {
                  sscanf(vals[j], "%o", &syl1);
                  values[1] = syl1 >> 2;
                  conflict = state.core[currentModule][currentSector][2][loc] != -1;
                }
              else if (pi01 == 11)
                {
                  sscanf(vals[j], "      %o", &syl0);
                  values[0] = syl0 >> 1;
                  conflict = state.core[currentModule][currentSector][2][loc] != -1;
                }
              else if (pi11 == 11)
                {
                  sscanf(vals[j], "%o %o", &syl1, &syl0);
                  values[1] = syl1 >> 2;
                  values[0] = syl0 >> 1;
                  conflict = state.core[currentModule][currentSector][2][loc] != -1;
                }
              else
                {
                  printf("Illegal octal pattern B: %s\n", buffer);
                  goto done;
                }
              if (conflict)
                printf("Conflict between instruction and data memory at %o-%02o-%03o", currentModule, currentSector, loc);
              // Actually store the value in memory.
              for (s = 0; s < 3; s++)
                if (values[s] != -1)
                  {
                    int formats[3] = { 5, 5, 9 };
                    if (state.core[currentModule][currentSector][s][loc] != -1
                        && state.core[currentModule][currentSector][s][loc]
                            != values[s])
                      printf("Octal conflict at %o-%02o-%o-%03o, %0*o != %0*o\n",
                          currentModule, currentSector, s, loc,
                          formats[s], state.core[currentModule][currentSector][s][loc],
                          formats[s], values[s]);
                    else
                      {
                      state.core[currentModule][currentSector][s][loc] =
                          values[s];
                      if (s == 2)
                        assembly->dataWords++;
                      else
                        assembly->codeWords++;
                      }
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
            printf("Corrupt octal-listing line: %s\n", buffer);
            goto done;
          }
    }

  retVal = 0;
  done: ;
  if (fp != NULL)
    fclose(fp);
  if (buffer != NULL)
    free(buffer);
  return (retVal);
#undef MAX_LINE
}

//////////////////////////////////////////////////////////////////////////////
// Read the .sym file.

static int
readSymbolTable(assembly_t *assembly, int count, char *filename)
{
#define MAX_LINE 1000
  int retVal = 1;
  FILE *fp = NULL;
  char *buffer = NULL;
  char *name = NULL;
  int maxSymbols = 0;

  printf("Reading symbol file %s\n", filename);

  fp = fopen(filename, "r");
  if (fp == NULL)
    {
      printf("Cannot open file: %s\n", filename);
      goto done;
    }
  buffer = malloc(MAX_LINE + 1);
  name = malloc(MAX_LINE + 1);
  if (buffer == NULL || name == NULL)
    {
      printf("Out of memory.\n");
      goto done;
    }

  while (NULL != fgets(buffer, MAX_LINE, fp))
    {
      unsigned module, sector, syllable, loc;
      int i;
      buffer[MAX_LINE] = 0;
      trim(buffer);
      i = sscanf(buffer, "%s\t%o\t\%o\t%o\t%o", name, &module, &sector,
          &syllable, &loc);
      if (i != 5)
        {
          printf("Ill-formed symbol table line: %s\n", buffer);
          goto done;
        }
      i = strlen(name);
      if (i < 1 || i > 9 || (i > 6 && !isdigit(name[0])))
        {
          printf("Symbol length wrong: %s\n", name);
          goto done;
        }
      if (checkAddress(module, sector, syllable, loc))
        goto done;
      if (assembly->numSymbols >= maxSymbols)
        {
          maxSymbols += 1000;
          assembly->symbols = realloc(assembly->symbols, maxSymbols * sizeof(symbol_t));
          if (assembly->symbols == NULL)
            {
              printf("Out of memory.\n");
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
        strcpy(assembly->symbols[assembly->numSymbols].name, name);
      else
        sprintf(assembly->symbols[assembly->numSymbols].name, "%s@%c", name, 'A' + count);
      assembly->symbols[assembly->numSymbols].module = module;
      assembly->symbols[assembly->numSymbols].sector = sector;
      assembly->symbols[assembly->numSymbols].syllable = syllable;
      assembly->symbols[assembly->numSymbols].loc = loc;
      assembly->numSymbols++;
    }

  retVal = 0;
  done: ;
  if (fp != NULL)
    fclose(fp);
  if (buffer != NULL)
    free(buffer);
  if (name != NULL)
    free(name);
  return (retVal);
#undef MAX_LINE
}

//////////////////////////////////////////////////////////////////////////////
// Read the .src file.

static int
readSourceLines(assembly_t *assembly, int count, char *filename)
{
#define MAX_LINE 1000
  int retVal = 1;
  FILE *fp = NULL;
  char *buffer = NULL;
  char *rawline = NULL;
  char *line = NULL;
  int lineNumber;
  int maxSourceLines = 0;

  printf("Reading source file %s\n", filename);

  fp = fopen(filename, "r");
  if (fp == NULL)
    {
      printf("Cannot open file: %s\n", filename);
      goto done;
    }
  buffer = malloc(MAX_LINE + 1);
  rawline = malloc(MAX_LINE + 1);
  if (buffer == NULL || rawline == NULL)
    {
      printf("Out of memory.\n");
      goto done;
    }

  while (NULL != fgets(buffer, MAX_LINE, fp))
    {
      unsigned module, sector, syllable, loc, assembled, dm, ds;
      int i;
      buffer[MAX_LINE] = 0;
      trim(buffer);
      i = sscanf(buffer, "%o%o%o%o%d%o%o%o%[^\n]", &module, &sector, &syllable, &loc,
          &lineNumber, &assembled, &dm, &ds, rawline);
      if (i != 9)
        {
          printf("Ill-formed source-table line: %s\n", buffer);
          goto done;
        }
      line = malloc(strlen(rawline));
      if (line == NULL)
        {
          printf("Out of memory.\n");
          goto done;
        }
      strcpy(line, rawline + 1);
      if (checkAddress(module, sector, syllable, loc))
        goto done;
      if (assembly->numSourceLines >= maxSourceLines)
        {
          maxSourceLines += 1000;
          assembly->sourceLines = realloc(assembly->sourceLines,
              maxSourceLines * sizeof(sourceLine_t));
          if (assembly->sourceLines == NULL)
            {
              printf("Out of memory.\n");
              goto done;
            }
        }
      assembly->sourceLines[assembly->numSourceLines].line = line;
      line = NULL;
      assembly->sourceLines[assembly->numSourceLines].module = module;
      assembly->sourceLines[assembly->numSourceLines].sector = sector;
      assembly->sourceLines[assembly->numSourceLines].syllable = syllable;
      assembly->sourceLines[assembly->numSourceLines].loc = loc;
      assembly->sourceLines[assembly->numSourceLines].lineNumber = lineNumber;
      assembly->sourceLines[assembly->numSourceLines].assembled = assembled;
      assembly->sourceLines[assembly->numSourceLines].dm = dm;
      assembly->sourceLines[assembly->numSourceLines].ds = ds;
      assembly->numSourceLines++;
    }

  retVal = 0;
  done: ;
  if (fp != NULL)
    fclose(fp);
  if (buffer != NULL)
    free(buffer);
  if (rawline != NULL)
    free(rawline);
  if (line != NULL)
    free(line);
  return (retVal);
#undef MAX_LINE
}

//////////////////////////////////////////////////////////////////////////////
// Provide various sorting orders for symbol table and source table.

int
cmpSourceByAddress(const void *r1, const void *r2)
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
  return (strcmp(e1->line, e2->line));
#undef e1
#undef e2
}

int
cmpSymbolsByAddress(const void *r1, const void *r2)
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
  return (strcmp(e1->name, e2->name));
#undef e1
#undef e2
}

static int
sortTables(int assemblyNumber)
{
  int retVal = 1;
  int i, j;
  sourceLine_t *sourceLines = assemblies[assemblyNumber].sourceLines;
  int numSourceLines = assemblies[assemblyNumber].numSourceLines;
  symbol_t *symbols = assemblies[assemblyNumber].symbols;
  int numSymbols = assemblies[assemblyNumber].numSymbols;

// First do all the sorting.
  qsort(sourceLines, numSourceLines, sizeof(sourceLine_t), cmpSourceByAddress);
  qsort(symbols, numSymbols, sizeof(symbol_t), cmpSymbolsByAddress);

// Now remove duplicates.
  if (numSourceLines > 0)
    {
      for (i = 0, j = 0; i < numSourceLines; i++)
        {
          if (cmpSourceByAddress(&sourceLines[j], &sourceLines[i]))
            {
              j++;
              if (i != j)
                {
                  if (sourceLines[j].line != NULL)
                    free(sourceLines[j].line);
                  memcpy(&sourceLines[j], &sourceLines[i],
                      sizeof(sourceLine_t));
                  sourceLines[i].line = NULL;
                }
            }
          else
            {
              if (i != j)
                {
                  free(sourceLines[i].line);
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
          if (cmpSymbolsByAddress(&symbols[j], &symbols[i]))
            {
              j++;
              if (i != j)
                {
                  memcpy(&symbols[j], &symbols[i], sizeof(symbol_t));
                }
            }
        }
      numSymbols = j + 1;
    }

  retVal = 0;
  //done: ;
  return (retVal);
}

//////////////////////////////////////////////////////////////////////////////

int
readAssemblies(void)
{
  int retVal = 1;
  int i, j, k, n;
  char *filename = NULL;
  assembly_t *assembly;

  memset(&state, 0, sizeof(state));
  for (i = 0; i < 8; i++)
    for (j = 0; j < 16; j++)
      for (k = 0; k < 3; k++)
        for (n = 0; n < 256; n++)
          state.core[i][j][k][n] = -1;
  state.pioChange = -1;
  state.cioChange = -1;
  state.prsChange = -1;
  state.lastHop = -1;

  for (i = 0, assembly = assemblies; i < numAssemblies; i++, assembly++)
    {
      filename = realloc(filename, strlen(assemblies[i].name) + 5);
      if (filename == NULL)
        {
          printf("Out of memory.\n");
          goto done;
        }
      sprintf(filename, "%s.tsv", assemblies[i].name);
      if (readOctalListing(assembly, i, filename))
        goto done;
      if (!freezeAssemblies)
        {
          sprintf(filename, "%s.sym", assemblies[i].name);
          if (readSymbolTable(assembly, i, filename))
            goto done;
          sprintf(filename, "%s.src", assemblies[i].name);
          if (readSourceLines(assembly, i, filename))
            goto done;
          if (sortTables(i))
            goto done;
        }
    }
  freezeAssemblies = 1;

  retVal = 0;
  done: ;
  if (filename != NULL)
    free(filename);
  return (retVal);
}
