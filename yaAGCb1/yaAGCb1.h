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
 *              2016-09-27 RSB  Added stuff for DSRUPT.
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

#include <stdio.h>

#if defined(__APPLE_CC__) && !defined(unix)
#define unix
#endif
#ifdef unix
#include <stdint.h>
#ifdef __APPLE_CC__
#define FORMAT_64U "%llu"
#define FORMAT_64O "%llo"
#elif !defined(__WORDSIZE)
#define FORMAT_64U "%llu"
#define FORMAT_64O "%llo"
#elif __WORDSIZE < 64
#define FORMAT_64U "%llu"
#define FORMAT_64O "%llo"
#else
#define FORMAT_64U "%lu"
#define FORMAT_64O "%lo"
#endif
#elif defined(WIN32)
#include <winsock2.h>
#include <windows.h>
#define FORMAT_64U "%llu"
#define FORMAT_64O "%llo"
#endif

// The following is used to get the int16_t datatype.
#ifdef WIN32
// Win32
#include <stdint.h>
#elif defined (__embedded__)
// Embedded, gcc cross-compiler.
typedef short int16_t;
typedef signed char int8_t;
typedef unsigned short uint16_t;
#elif defined (SDCC)
// SDCC (8-bit 8051)
typedef int int16_t;
typedef signed char int8_t;
typedef unsigned uint16_t;
extern long random (void);
#else // WIN32
// All other (Linux, Mac OS, etc.)
//#include <sys/types.h>
#include <stdint.h>
#endif // WIN32

//-------------------------------------------------------------------------
// Block 1 specific address and data constants.

#define MAX_BANK 034
#define BANK_SIZE 02000
#define MEMORY_SIZE (BANK_SIZE * (MAX_BANK + 1))

// A macro for converting a bank number and address within a fixed-memory
// bank, such as 04,07005 to the "flat" address space.
#define flatten(bank,offset) ((bank == 0) ? offset : (bank + (offset & 01777)))

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

  // Some bookkeeping I need for interrupts.
  uint16_t ruptFlatAddress;
  uint16_t ruptLastINDEX;
  uint16_t ruptLastZ;
  uint16_t overflowedTIME3; // Triggers T3RUPT.
  uint16_t overflowedTIME4; // Triggers T4RUPT.
  uint16_t uplinkReady; // Triggers UPRUPT.
  uint16_t downlinkReady; // Triggers DSRUPT.

  // These values are the number of AGC MCT cycles which have occurred since
  // virtual AGC power-up, versus the total number of nanoseconds which have
  // elapsed, minus the time the virtual AGC has spent paused.  In other words,
  // The machine makes its best effort to keep
  //    countMCT = (getTimeNanoseconds() - startTimeNanoseconds - pausedNanoseconds) / mctNanoseconds
  // on the average.  On short timescales, though, there can be quite a lot of
  // variation.
  uint64_t countMCT;
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
  // Note that both the values 1 and 2 indicate that a single step is to be performed.
  // 1 is loaded if the 't' command is used, while 2 is loaded if 't1' is used.  The
  // distinction is that if you used 'tN', then it is assumed you want to stop at any
  // break/watch encountered, whereas if you used 't' even at a line which happens to
  // has a break/watch on it, it is assumed you know that and want to proceed without
  // the hassle of removing the breakpoint and possible restoring it again.  The
  // breakpoint itself is unchanged.
  int instructionCountDown;
} agcBlock1_t;

#define BILLION 1000000000
int64_t
getTimeNanoseconds(void);
void
sleepNanoseconds(int64_t nanoseconds);

int
executeOneInstruction(FILE *logFile);
extern int loggingOn;

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
#define MIN_LINE_LENGTH 105
#define MAX_LINE_LENGTH 256 // Max length of a program-listing line stored in RAM.
extern int maxDisplayedLineLength;
extern int maxDisplayedContext;
#define MAX_LISTING_LINES 65536 // Empirically, about 30,000 needed for Solarium.
extern char bufferedListing[MAX_LISTING_LINES][MAX_LINE_LENGTH];
extern int numListingLines;
extern int listingAddresses[MEMORY_SIZE];
#define MAX_BREAKS_OR_WATCHES 16
// Note that positive breaksOrWatches are addresses, while negative ones are
// negatives of MCT values.  There are also certain special positive values
// outside the 16-bit range used for breaks on special conditions.
#define BREAK_UININITIALIZED 01000000
extern int breaksOrWatches[MAX_BREAKS_OR_WATCHES];
extern int numBreaksOrWatches;

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
#define regBANKRUPT agc.memory[030]
#define regOVRUPT agc.memory[031]
#define regLPRUPT agc.memory[032]
#define regDSRUPTSW agc.memory[033]
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
#define ctrTRKRX agc.memory[054]
#define ctrTRKRY agc.memory[055]
#define ctrTRKRR agc.memory[056]

extern uint16_t defaultErasable;
int
loadYul(char *filename);
int
loadPads(char *filename);

//--------------------------------------------------------------------------
// Functions brazenly and brainlessly copied from yaAGC/agc_engine.c into
// yaAGCb1/fromYaAGC.c, in order to facilitate reusing the Block 2 MP and
// DV instructions in the Block 1 simulator.

int16_t
SignExtend(int16_t Word);
int
agc2cpu (int Input);
int
cpu2agc (int Input);
int
agc2cpu2 (int Input);
int
cpu2agc2 (int Input);
int16_t
OverflowCorrected(int Value);
int
SpToDecent (int16_t * LsbSP);
void
DecentToSp(int Decent, int16_t * LsbSP);
uint16_t
AddSP16 (uint16_t Addend1, uint16_t Addend2);

//-------------------------------------------------------------------------
// Stuff for the virtual connection between the AGC and its peripherals,
// also almost-brainlessly adapted from yaAGC (Block 2).

typedef struct
{
  int Socket;
  unsigned char Packet[4];
  int Size;
  int ChannelMasks[256];
} Client_t;

#define DEFAULT_MAX_CLIENTS 10

extern int MAX_CLIENTS;
extern Client_t *Clients;
extern int *ServerSockets;
extern int NumServers;
extern int SocketInterlaceReload;
extern int Portnum;

// API for yaAGC-to-peripheral communications.
void ChannelOutput (agcBlock1_t * State, int Channel, int Value);
int ChannelInput (agcBlock1_t * State);
void ChannelRoutine (agcBlock1_t *State);
void ChannelRoutineGeneric (void *State, void (*UpdatePeripherals) (void *, Client_t *));
int
FormIoPacket (int Channel, int Value, unsigned char *Packet);
int
ParseIoPacket (unsigned char *Packet, int *Channel, int *Value, int *uBit);
void
UnblockSocket (int SocketNum);
int
EstablishSocket (unsigned short portnum, int MaxClients);

// For socket connections.
#ifdef WIN32
#define SOCKET_BROKEN 1
#else
#define SOCKET_ERROR -1
#define SOCKET_BROKEN (errno == EPIPE)
#endif

void
logAGC(FILE *logFile, uint16_t lastZ);

#endif // YAAGC_BLOCK1_H
