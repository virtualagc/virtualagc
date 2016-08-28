/*
 * Copyright 2016 Ronald S. Burkey <info@sandroid.org>
 *
 *  This file is part of yaAGC.
 *
 *  yaAGC is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  yaAGC is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with yaAGC; if not, write to the Free Software
 *  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 *
 *  Filename:     mapperBlock1.c
 *  Purpose:      This is a utility whose purpose, given the contents of a
 *                Block1 rope and a set of starting addresses, is to map
 *                out those memory areas containing the basic instructions.
 *                Data areas, interpretive areas, and unused areas are left
 *                unmapped.
 *  Contact:      Ron Burkey <info@sandroid.org>
 *  Website:      www.ibiblio.org/apollo
 *  Mode:         2015-08-27 RSB  Began.
 *
 *  This is really just a little private experiment at the moment.  What
 *  it's for is this:  We have the prospect of acquiring the rope contents
 *  of a Block 1 AGC program called CORONA, but without source code.  I
 *  would like to disassemble the rope to regenerate the source code.
 *  One of the first steps in such a process is to determine which areas
 *  of the rope are basic, interpreter, data, or unused.  This utility
 *  addresses just the first.
 *
 *  The idea is this there are only certain possible code-entry points
 *  in the program, namely the power-up starting address and the
 *  interrupt vectors.  From each one of those, if you could trace through
 *  every possible code path, then you could know the location of every
 *  basic instruction.  I believe those addresses to be:
 *
 *      Power-up entry: One of the interrupt-vectors?  (In Block 2, it
 *                      would be the first interrupt-vector, which would
 *                      be at 4000.  Here, 2030 looks like the most-likely
 *                      one, but I don't really understand it.)
 *      Interrupts:     2000, 2004, 2010, 2014, 2020, 2024, 2030
 *
 *  This program neither disassembles the rope nor simulates its execution,
 *  but it does decode *enough* of each instruction it encounters to
 *  determine if it is a jump (TC) or conditional jump (CCS), and recursively
 *  follows the addresses implied by those jumps.  It also has to track the
 *  INDEX instruction and the assignments to the BANKREG register (address 015)
 *  to know which banks are being referenced.  I don't know what the power-up
 *  value of BANKREG is (I hope it doesn't matter!) so I arbitrarily set it at 0.
 *
 *  To a certain extent, this program can also *help* to map out data areas,
 *  since it could in principle track all addresses which are loaded from
 *  or stored to, and I may add that feature in later, if the primary function
 *  seems to work well.
 *
 *  The same procedure could be followed for Block 2, but it would be more
 *  complex.  However, there is no prospect I'm aware of for obtaining Block 2
 *  programs solely from a rope, so I have no intention of addressing Block 2
 *  in this utility.
 */

#include <stdio.h>
#include <string.h>

#define MAX_ENTRY_POINTS 16
// basicMap[] is really just a set of true/false indicators as to whether the
// location contained a basic instruction or not.  I hope that erasable
// (0-01777) can't be hit.
#define MEMORY_SIZE (02000 * 035)
int rope[MEMORY_SIZE] = { 0 };
int basicMap[MEMORY_SIZE] = { 0 };
int dataMap[MEMORY_SIZE] = { 0 };
int BANKREG = 0;

// A recursive function to map an area starting from an address.
int
mapEntryPoint (int address)
{
  while (1)
    {
      int instruction;

      // Error or exit conditions.
      if (address < 0 || address >= MEMORY_SIZE)
        {
          fprintf (stderr, "Address overflow.\n");
          return (1);
        }
      if (address < 02000)
        {
          fprintf (stderr, "Erasable encountered.\n");
          return (1);
        }
      if (basicMap[address]) // Already hit before.
        break;

      // Parse the instruction.
      instruction = rope[address++];

    }

  return (0);
}

int
main(int argc, char *argv[])
{
  int i, j, k, entryPoints[MAX_ENTRY_POINTS], numEntryPoints = 0;

  // Parse the command line.
  for (i = 1; i < argc; i++)
    {
      if (!strncmp (argv[i], "--rope=", 7))
        {
          FILE *fp;
          fp = fopen (&argv[i][7], "rb");
          if (fp == NULL)
            {
              fprintf (stderr, "File not found.\n");
              return (1);
            }
          for (j = 02000; j < MEMORY_SIZE; j++)
            {
              k = getc (fp);
              if (k == EOF)
                {
                  fprintf (stderr, "Unexpected end of file.\n");
                  return (1);
                }
              rope[i] = k << 7;
              k = getc (fp);
              if (k == EOF)
                {
                  fprintf (stderr, "Unexpected end of file.\n");
                  return (1);
                }
              rope[i] |= (k >> 1) & 0177;
            }
          fclose (fp);
        }
      else if (1 == sscanf(argv[i], "--entry=%o", &j))
        {
          if (numEntryPoints >= MAX_ENTRY_POINTS)
            {
              fprintf (stderr, "Too many entry points.\n");
              return (1);
            }
          entryPoints[numEntryPoints++] = j;
        }
      else if (!strcmp (argv[i], "--help"))
        {
          fprintf (stderr, "Usage:  mapperBlock1 --rope=Filename --entry=Octal [--entry=Octal ...]");
          return (0);
        }
      else
        {
          fprintf (stderr, "Unknown switch: \"%s\"\n", argv[i]);
          return (1);
        }
    }
  if (numEntryPoints == 0)
    {
      fprintf (stderr, "No entry points were specified.\n");
      return (1);
    }

  for (i = 0; i < numEntryPoints; i++)
    if (mapEntryPoint(entryPoints[i]))
      {
        fprintf (stderr, "Implementation error for entry point %o.\n", entryPoints[i]);
        return (1);
      }

  return (0);
}

