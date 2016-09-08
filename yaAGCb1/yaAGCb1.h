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
 * Filename:    yaAGC-Block1.h
 * Purpose:     Header for Block 1 AGC simulator.
 * Compiler:    GNU gcc.
 * Contact:     Ron Burkey <info@sandroid.org>
 * Reference:   http://www.ibiblio.org/apollo/index.html
 * Mods:        2016-09-03 RSB  Began the Block 1 AGC simulator.  I'm succumbing
 *                              to the temptation of starting clean, rather than
 *                              trying to build upon the existing yaAGC (Block 2)
 *                              simulator, or on my port of John Pultorak's
 *                              Block 1 simulator.
 *
 * It is important to note that this simulator operates at the basic instruction
 * level and *not* at the control-pulse level, much like the original Block 2
 * yaAGC.  It deals with lower-level structures only when it is impossible to
 * avoid (which is seldom).  This is in contrast to John Pultorak's Block 1
 * simulator, also available under the overall umbrella of the Virtual AGC project,
 * which operates entirely at the pulse-sequence level, and provides higher-level
 * information about the basic assembly-language instructions only as an afterthought.
 * The latter approach is very suited to modeling the underlying hardware, but not
 * so much for efficient development or simulation of code execution.  That is
 * a large part of the reason why this replacement simulator is being written.
 * However, validation of this simulator against the behavior of the Pultorak
 * simulator, on an instruction by instruction basis, is an important development
 * tool for this simulator.
 */

#ifndef YAAGC_BLOCK1_H
#define YAAGC_BLOCK1_H

#include <stdint.h>
#include <stdio.h>

#define MAX_BANK 034
#define BANK_SIZE 02000
#define MEMORY_SIZE (BANK_SIZE * (MAX_BANK + 1))

// A macro for converting a bank number and address within a fixed-memory
// bank, such as 04,07005 to the "flat" address space.
#define flatten(bank,offset) ((bank == 0) ? offset : ((02000 * bank) + (offset & 01777)))

// Some numerical constants, in AGC format.
#define AGC_P0 ((int16_t) 0)
#define AGC_M0 ((int16_t) 077777)
#define AGC_P1 ((int16_t) 1)
#define AGC_M1 ((int16_t) 077776)

//--------------------------------------------------------------------------
// Stuff related to the structure of the virtual Block 1 AGC.  Refer to
// document R-393 at the ibiblio.org/apollo site.  However, that doc has
// some mistakes (or perhaps obsolete info) in it that will be corrected here.

// Memory Cycle Time (MCT) in nanoseconds.  All instructions take 1, 2, or 3
// MCT to execute ... or at least before continuing to the next instruction.
// MP and DV continue in the background even after progressing to the next
// instruction.
#define mctNanoseconds 11700

// Structure defining a virtual AGC machine.
typedef struct
{
  /*
   * Memory.  We deal with memory internally in this program as a flat
   * address structure, and only translate to/from the banked representation
   * of the physical AGC when we cannot help it.  The correspondence between
   * flat and banked is (octal)
   *            Flat                    Banked
   *            ----                    ------
   *            00000-01777             Erasable 0000-1777
   *            02000-03777             Fixed 2000-3777 (= 01,6000-01,7777)
   *            04000-05777             Fixed 4000-5777 (= 02,6000-02,7777)
   *            06000-07777             Fixed 03,6000-03,7777
   *            10000-11777             Fixed 04,6000-04,7777
   *            ...
   *            70000-71777             Fixed 34,6000-34,7777
   * Note that while the 4 banks 15-20 are logically present, they were not
   * physically present in the computer.  We, however, do not distinguish
   * them from any other banks.
   *
   * The Erasable includes those "special registers" that are identified
   * with memory locations by R-393 Table 3-1.
   *
   * The amount of memory logically addressable, as opposed to physically addressable,
   * is allocated in order to make sure that bad AGC instructions don't segfault the
   * simulator.
   */
  uint16_t memory[041 * 02000 /*MEMORY_SIZE*/];

  // Registers not addressable directly by basic instructions.
  uint16_t INDEX;
  uint16_t INTERRUPTED; // Indicates an interrupt is already being processed.
  uint16_t B;

  // These values are the number of AGC MCT cycles which have occurred since
  // virtual AGC power-up, versus the total number of nanoseconds which have
  // elapsed, minus the time the virtual AGC has spent paused.  In other words,
  // The machine makes its best effort to keep
  //    countMCT = (getTimeNanoseconds() - startTimeNanoseconds - pausedNanoseconds) / mctNanoseconds
  // on the average.  On short timescales, though, there can be quite a lot of
  // variation.
  unsigned long countMCT;
  int64_t startTimeNanoseconds;
  int64_t pausedNanoseconds;
  int64_t startOfPause;

  // The run state. We allow for three different possibilities:  The machine is
  // paused, or else the machine is running freely, or else the machine is stepping
  // through some predetermined instruction count and will pause after completing
  // them.  All are handled by the instructionCountDown variable:
  //    <0      Free running
  //     0      Paused
  //    >0      Counting down.
  int instructionCountDown;
} agcBlock1_t;

#define BILLION 1000000000
int64_t
getTimeNanoseconds(void);
void
sleepNanoseconds(int64_t nanoseconds);

void
executeOneInstruction(FILE *logFile);

//--------------------------------------------------------------------------
// Stuff related to debugging.

/*
 * The way this works is that bufferedListing[] is loaded with the complete
 * program listing from yaYUL, with lines truncated to MAX_LINE_LENGTH.
 * There are numListingLines positions in the array populated.
 * For each possible address in the "flat" address space of the AGC,
 * the listingAddresses[] array contains either -1 (meaning the address
 * doesn't appear in the program listing) or else an index into bufferedListings[].
 * Thus given a flat address, you can instantly find the line or context of the
 * program listing that corresponds to it.
 */
#define MAX_LINE_LENGTH 132 // Max length of a program-listing line before we truncate it.
#define MAX_LISTING_LINES 65536 // Empirically, about 30,000 needed for Solarium.
extern char bufferedListing[MAX_LISTING_LINES][MAX_LINE_LENGTH];
extern int numListingLines;
extern int listingAddresses[MEMORY_SIZE];
// Function for populating the program-listing buffer, given a filename of the
// listing.  Returns:
// 0 on success
// 1 if the buffer was overrun, so that only a partial listing is available
// 2 on failure (meaning that the program listing won't be available at all)
int
bufferTheListing(char *filename);

char *
nbfgets(char *Buffer, int Length);

void
processConsoleDebuggingCommand(char *command);

//--------------------------------------------------------------------------
// Stuff related to the loaded rope-file.

extern agcBlock1_t agc;
#define regA agc.memory[0]
#define regQ agc.memory[01]
#define regZ agc.memory[02]
#define regLP agc.memory[03]
#define regIN0 agc.memory[04]
#define regIN1 agc.memory[05]
#define regIN2 agc.memory[06]
#define regIN3 agc.memory[07]
#define regOUT0 agc.memory[010]
#define regOUT1 agc.memory[011]
#define regOUT2 agc.memory[012]
#define regOUT3 agc.memory[013]
#define regOUT4 agc.memory[014]
#define regBank agc.memory[015]
#define regRelint agc.memory[016]
#define regInhint agc.memory[017]
#define regCYR agc.memory[020]
#define regSR agc.memory[021]
#define regCYL agc.memory[022]
#define regSL agc.memory[023]
#define regZRUPT agc.memory[024]
#define regBRUPT agc.memory[025]
#define regARUPT agc.memory[026]
#define regQRUPT agc.memory[027]
#define ctrBANKRUPT agc.memory[030]
#define ctrOVRUPT agc.memory[031]
#define ctrLPRUPT agc.memory[032]
#define ctrDSRUPTSW agc.memory[033]
#define ctrOVCTR agc.memory[034]
#define ctrTIME2 agc.memory[035]
#define ctrTIME1 agc.memory[036]
#define ctrTIME3 agc.memory[037]
#define ctrTIME4 agc.memory[040]
#define ctrUPLINK agc.memory[041]
#define ctrOUTCR1 agc.memory[042]
#define ctrOUTCR2 agc.memory[043]
#define ctrPIPAX agc.memory[044]
#define ctrPIPAY agc.memory[045]
#define ctrPIPAZ agc.memory[046]
#define ctrCDUX agc.memory[047]
#define ctrCDUY agc.memory[050]
#define ctrCDUZ agc.memory[051]
#define ctrOPTX agc.memory[052]
#define ctrOPTY agc.memory[053]

int
loadYul(char *filename);

#endif // YAAGC_BLOCK1_H
