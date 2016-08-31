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
 *  value of BANKREG is (I hope it doesn't matter!) so I arbitrarily set it at 0
 *
 *  I think it's the INDEX register that's the real fly in the ointment here,
 *  because it can jump almost any place, on the of a dynamical choice rather
 *  than something known deducible from the binary, so I'll have to work out
 *  some way to handle that.
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
 *
 *  In this program, all C variables associated with an address assume a flat
 *  address space from 0 to 02000*035-1, where
 *
 *      0-1777 is erasable.
 *      2000-3777 is fixed 2000-3777 or 01,6000-01,7777
 *      4000-5777 is fixed 4000-5777 or 02,6000-02,7777
 *      6000-7777 is fixed 03,6000-03,7777
 *      10000-11777 is fixed 04,6000-04,7777
 *      .
 *      .
 *      .
 *      70000-71777 is fixed 34,6000-34,7777
 *
 * Conversion from the flat space to the erasable/fixed/banked representation is
 * done on an as-needed basis.
 */

#include <stdio.h>
#include <string.h>

#define MAX_ENTRY_POINTS 16
// basicMap[] is really just a set of true/false indicators as to whether the
// location contained a basic instruction or not.  I hope that erasable
// (0-01777) can't have an instruction in it.
#define MEMORY_SIZE (02000 * 035)
int rope[MEMORY_SIZE] =
  { 0 };
int basicMap[MEMORY_SIZE] =
  { 0 };
int dataMap[MEMORY_SIZE] =
  { 0 };
int BANKREG = 0;
int INDEX = -1;
int PC = 02000;

int
initializeBasic(int address)
{
  if (address < 0 || address >= MEMORY_SIZE)
    {
      fprintf(stderr, "Address overflow.\n");
      return (1);
    }
  INDEX = -1;
  PC = address;
  return (0);
}

// A function to decode a single basic instruction.  If elaborated enough, I suppose
// it could eventually become the basis for a Block 1 CPU simulator, though
// I only need the bare beginnings of that right now.  Returns
//
//      0       Success
//      1       Address not in memory space
int
decodeBasic(void)
{
  int instruction, keepIndex = 0, retVal = 1;
  // Sanity check.
  if (PC < 0 || PC >= MEMORY_SIZE)
    {
      fprintf(stderr, "Address overflow.\n");
      goto done;
    }
  instruction = rope[PC++];
  if (PC != 04000 && PC % 02000 == 0)
    {
      fprintf(stderr, "End of bank %02o reached.\n", (PC - 1) / 02000);
    }
  if (instruction == 047777)
    {
      goto done;
    }
  switch (instruction & 070000)
    {
  case 000000: // TC instruction.
    break;
  case 010000: // CCS instruction.
    break;
  case 020000: // INDEX instruction.
    keepIndex = 1;

    break;
  case 030000: // XCH, CAF instruction.
    // XCH and CAF have the same opcode bits, but it's XCH if the operand is erasable
    // memory and it's CAF if the operand is fixed memory.
    break;
  case 040000: // CS, MP instructions.
    // I believe it's an MP if the preceding instruction is EXTEND (or EXTEND / INDEX something)
    // and CS otherwise.   EXTEND = INDEX OPOVF = 047777.
    // But I also see it a few times preceded by INDEX TEM4, and no EXTEND preceding that.
    // I have no idea what that means, unless it's a typo.
    break;
  case 050000: // TS, DV instruction.
    // I believe it's an DV if the preceding instruction is EXTEND (or EXTEND / INDEX something)
    // and TS otherwise.   EXTEND = INDEX OPOVF = 047777.
  case 060000: // AD, SU instruction.
    // I believe it's an SU if the preceding instruction is EXTEND (or EXTEND / INDEX something)
    // and AD otherwise.   EXTEND = INDEX OPOVF = 047777.
    break;
  case 070000: // MASK instruction.
    break;
    }

  retVal = 0;
  done: ;
  if (!keepIndex)
    INDEX = -1;
  return (retVal);
}

// A recursive function to map an area starting from an address.
int
mapEntryPoint(int address)
{
  while (1)
    {
      int instruction;

      // Error or exit conditions.
      if (address < 0 || address >= MEMORY_SIZE)
        {
          fprintf(stderr, "Address overflow.\n");
          return (1);
        }
      if (address < 02000)
        {
          fprintf(stderr, "Erasable encountered.\n");
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
      if (!strncmp(argv[i], "--rope=", 7))
        {
          FILE *fp;
          fp = fopen(&argv[i][7], "rb");
          if (fp == NULL)
            {
              fprintf(stderr, "File not found.\n");
              return (1);
            }
          for (j = 02000; j < MEMORY_SIZE; j++)
            {
              k = getc(fp);
              if (k == EOF)
                {
                  fprintf(stderr, "Unexpected end of file.\n");
                  return (1);
                }
              rope[i] = k << 7;
              k = getc(fp);
              if (k == EOF)
                {
                  fprintf(stderr, "Unexpected end of file.\n");
                  return (1);
                }
              rope[i] |= (k >> 1) & 0177;
            }
          fclose(fp);
        }
      else if (1 == sscanf(argv[i], "--entry=%o", &j))
        {
          if (numEntryPoints >= MAX_ENTRY_POINTS)
            {
              fprintf(stderr, "Too many entry points.\n");
              return (1);
            }
          entryPoints[numEntryPoints++] = j;
        }
      else if (!strcmp(argv[i], "--help"))
        {
          fprintf(stderr,
              "Usage:  mapperBlock1 --rope=Filename --entry=Octal [--entry=Octal ...]");
          return (0);
        }
      else
        {
          fprintf(stderr, "Unknown switch: \"%s\"\n", argv[i]);
          return (1);
        }
    }
  if (numEntryPoints == 0)
    {
      fprintf(stderr, "No entry points were specified.\n");
      return (1);
    }

  for (i = 0; i < numEntryPoints; i++)
    if (mapEntryPoint(entryPoints[i]))
      {
        fprintf(stderr, "Implementation error for entry point %o.\n",
            entryPoints[i]);
        return (1);
      }

  return (0);
}

