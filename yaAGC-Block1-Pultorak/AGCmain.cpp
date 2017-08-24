/****************************************************************************
 * AGC4 (Apollo Guidance Computer) BLOCK I Simulator
 *
 * AUTHOR: John Pultorak
 * DATE: 07/29/02
 * FILE: AGCmain.cpp
 *
 * VERSIONS:
 * 1.0 - initial version.
 * 1.1 - fixed minor bugs; passed automated test and checkout programs:
 * teco1.asm, teco2.asm, and teco3.asm to test basic instructions,
 * extended instructions, and editing registers.
 * 1.2 - decomposed architecture into subsystems; fixed minor bug in DSKY
 * keyboard logic (not tested in current teco*.asm suite).
 * Implemented scaler pulses F17, F13, F10. Tied scaler output to
 * involuntary counters and interrupts. Implemented counter overflow
 * logic and tied it to interrupts and other counters. Added simple
 * set/clear breakpoint. Fixed a bug in bank addressing.
 * 1.3 - fixed bugs in the DSKY. Added 14-bit effective address (CADR) to the
 * simulator display output. Inhibited interrupts when the operator
 * single-steps the AGC.
 * 1.4 - performance enhancements. Recoded the control pulse execution code
 * for better simulator performance. Also changed the main loop so it
 * polls the keyboard and system clock less often for better performance.
 * 1.5 - reversed the addresses of TIME1 and TIME2 so TIME2 occurs first.
 * This is the way its done in Block II so that a common routine (READLO)
 * can be used to read the double word for AGC time.
 * 1.6 - added indicators for 'CHECK FAIL' and 'KEY RELS'. Mapped them to OUT1,
 * bits 5 and 7. Added a function to display the current location in
 * the source code list file using the current CADR.
 * 1.7 - increased length of 'examine' function display. Any changes in DSKY now
 * force the simulator to update the display immediately. Added a 'watch'
 * function that looks for changes in a memory location and halts the
 * AGC. Added the 'UPTL', 'COMP', and "PROG ALM" lights to the DSKY.
 * 1.8 - started reorganizing the simulator in preparation for H/W logic design.
 * Eliminated slow (1Hz) clock capability. Removed BUS REQUEST feature.
 * Eliminated SWRST switch.
 * 1.9 - eliminated the inclusive 'OR' of the output for all registers onto the
 * R/W bus. The real AGC OR'ed all register output onto the bus; normally
 * only one register was enabled at a time, but for some functions several
 * were simultaneously enabled to take advantage of the 'OR' function (i.e.:
 * for the MASK instruction). The updated logic will use tristate outputs
 * to the bus except for the few places where the 'OR' function is actually
 * needed. Moved the parity bit out of the G register into a 1-bit G15
 * register. This was done for convenience because the parity bit in G
 * is set independently from the rest of the register.
 * 1.10 - moved the G15 parity register from MBF to the PAR subsystem. Merged SBFWG
 * and SBEWG pulses into a single SBWG pulse. Deleted the CLG pulse for MBF
 * (not needed). Separated the ALU read pulses from all others so they can
 * be executed last to implement the ALU inclusive OR functions. Implemented
 * separate read and write busses, linked through the ALU. Implemented test
 * parity (TP) signal in PAR; added parity alarm (PALM) FF to latch PARITY
 * ALARM indicator in PAR.
 * 1.11 - consolidated address testing signals and moved them to ADR. Moved memory
 * read/write functions from MBF to MEM. Merged EMM and FMM subsystems into
 * MEM. Fixed a bad logic bug in writeMemory() that was causing the load of
 * the fixed memory to overwrite array boundaries and clobber the CPM table.
 * Added a memory bus (MEM_DATA_BUS, MEM_PARITY_BUS).
 * 1.12 - reduced the number of involuntary counters (CTR) from 20 to 8. Eliminated
 * the SHINC subsequence. Changed the (CTR) sequence and priority registers into
 * a single synchronization register clocked by WPCTR. Eliminated the fifth
 * interrupt (UPRUPT; INT). Eliminated (OUT) the signal to read from output
 * register 0 (the DSKY register), since it was not used and did not provide
 * any useful function, anyway. Deleted register OUT0 (OUT) which shadowed
 * the addressed DSKY register and did not provide any useful function.
 * Eliminated the unused logic that sets the parity bit in OUT2 for downlink
 * telemetry.
 * 1.13 - reorganized the CPM control pulses into CPM-A, CPM-B, and CPM-C groups.
 * Added the SDV1, SMP1, and SRSM3 control pulses to CPM-A to indicate when
 * those subsequences are active; these signals are input to CPM-C. Moved the
 * ISD function into CPM-A. Fixed a minor bug causing subsequence RSM3 to be
 * displayed as RSM0. Added GENRST to clear most registers during STBY.
 * 1.14 - Moved CLISQ to TP1 to fix a problem in the hardware AGC. CLISQ was clearing
 * SNI on CLK2 at TP12, but the TPG was advancing on CLK1 which occurs after
 * CLK2, so the TPG state machine was not seeing SNI and was not moving to
 * the correct state. In this software simulation, everything advances on
 * the same pulse, so it wasn't a problem to clear SNI on TP12. Added a
 * switch to enable/disable the scaler.
 * 1.15 - Reenabled interrupts during stepping (by removing MON::RUN) signals from
 * CPM-A and CPM-C logic). Interrupts can be prevented by disabling the scaler.
 * Fixed a problem with INHINT1; it is supposed to prevent an interrupt
 * between instructions if there's an overflow. It was supposed to be cleared
 * on TP12 after SNI (after a new instruction), but was being cleared on TP12
 * after every subsequence.
 * 1.16 - Changed CPM-A to load and use EPROM tables for the control pulse matrix. The
 * EPROM tables are negative logic (0=asserted), but this simulator expects
 * positive logic, so each word is bit-flipped when the EPROM tables load
 * during simulator initialization.
 * SOURCES:
 * Mostly based on information from "Logical Description for the Apollo Guidance
 * Computer (AGC4)", Albert Hopkins, Ramon Alonso, and Hugh Blair-Smith, R-393,
 * MIT Instrumentation Laboratory, 1963.
 *
 * PORTABILITY:
 * Compiled with Microsoft Visual C++ 6.0 standard edition. Should be fairly
 * portable, except for some Microsoft-specific I/O and timer calls in this file.
 *
 * NOTE: set tabs to 4 spaces to keep columns formatted correctly.
 *
 *****************************************************************************
 */

/*
 * Additional mods:
 * 2016-09-02 RSB       Lots of adaptations related to using g++, fixing some of
 *                      the features, and so on.
 * 2016-09-04 RSB       On some computers (mine at home but not some others
 *                      I've tried, there was a lockup after the first command
 *                      was read.  Fixed it in nbfgets.cpp.
 *                      Also fixed that fact that single-stepping ('t') was stopping
 *                      at the beginning of the 2nd MCT of a CCS, rather than after
 *                      the CCS was finished.  Added a primitive logging function
 *                      to trace the AGC program's execution, so as to compare on
 *                      a cycle-by-cycle basis against yaAGCb1.
 * 2017-08-24 RSB	Got rid of some clang warnings.
 */

// NCURSES vs PTHREADS.  As John originally designed this program, it
// depended on the Windows functionality conio.h, which of course *only*
// existed in Windows.  He needed this basically to be able to asynchronously
// detect a keystroke.  I at first changed the implementation to use the
// non-blocking capabilities from NCURSES.  However, the attendant difficulties
// (such as no backspacing over typos and the inability to run the program
// in Eclipse) were just too great.  Instead, I pulled in the simple implementation
// (nbfgets) that I originally used in the original yaAGC, which involves a
// pthread that reads the keyboard in a blocking fashion, but still appears
// non-blocking to the main thread.  This has the inconvenience of having to
// use the Enter key to terminate output, but I think that's a small price to
// pay.  Of course, none of that stuff would persist into a mature design, since
// it's all related to a console-based interface for debugging and controlling
// the DSKY that's only appropriate to a very primitive program.
#ifdef USE_NCURSES
#include <ncurses.h>
#define endl "\n\r"
#define _getch() wgetch(stdscr)
static int
_kbhit()
  {
    int c;
    c = wgetch(stdscr);
    if (c != EOF)
      {
        ungetch(c);
        return (1);
      }
    return (0);
  }

#else
// Use nbfgets.c.
#define printw printf
#define endwin()
char *
nbfgets(char *Buffer, int Length);
char userInput[256];
#endif
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <time.h>
#include <ctype.h>
#include <stdint.h>
#include "reg.h"
#include "TPG.h"
#include "MON.h"
#include "SCL.h"
#include "SEQ.h"
#include "INP.h"
#include "OUT.h"
#include "BUS.h"
#include "DSP.h"
#include "ADR.h"
#include "PAR.h"
#include "MBF.h"
#include "MEM.h"
#include "CTR.h"
#include "INT.h"
#include "KBD.h"
#include "CRG.h"
#include "ALU.h"
#include "CPM.h"
#include "ISD.h"
#include "CLK.h"
extern int
loadPads(char *filename);

#define ROPE_SIZE (02000 * (NUMFBANK + 1))
FILE *logFile = NULL;
#define MAX_LOG_EXTRAS 10
int numLogExtras = 0;
uint16_t logExtras[MAX_LOG_EXTRAS];
bool zeroErasable = true;

using namespace std;

extern bool dskyChanged;
//-----------------------------------------------------------------------
// CONTROL LOGIC
void
genAGCStates()
{
  // 1) Decode the current instruction subsequence (glbl_subseq).
  // SEQ::glbl_subseq = CPM::instructionSubsequenceDecoder();
  // 2) Build a list of control pulses for this state.
  CPM::controlPulseMatrix();
  // 3) Execute the control pulses for this state. In the real AGC, these occur
  // simultaneously. Since we can't achieve that here, we break it down into the
  // following steps:
  // Most operations involve data transfers--usually reading data from
  // a register onto a bus and then writing that data into another register. To
  // approximate this, we first iterate through all registers to perform
  // the 'read' operation--this transfers data from register to bus.
  // Then we again iterate through the registers to do 'write' operations,
  // which move data from the bus back into the register.
  BUS::glbl_READ_BUS = 0; // clear bus; necessary because words are logical
  // OR'ed onto the bus.
  MEM::MEM_DATA_BUS = 0; // clear data lines: memory bits 15-1
  MEM::MEM_PARITY_BUS = 0; // parity line: memory bit 16
  // Now start executing the pulses:
  // First, read register outputs onto the bus or anywhere else.
  int i;
  for (i = 0; i < MAXPULSES && SEQ::glbl_cp[i] != NO_PULSE; i++)
    {
      CLK::doexecR(SEQ::glbl_cp[i]);
    }
  // Next, execute ALU read pulses. See comments in ALU .C file
  ALU::glbl_BUS = 0;
  for (i = 0; i < MAXPULSES && SEQ::glbl_cp[i] != NO_PULSE; i++)
    {
      CLK::doexecR_ALU(SEQ::glbl_cp[i]);
    }
  BUS::glbl_WRITE_BUS = BUS::glbl_READ_BUS; // in case nothing is logically OR'ed below;
  for (i = 0; i < MAXPULSES && SEQ::glbl_cp[i] != NO_PULSE; i++)
    {
      CLK::doexecR_ALU_OR(SEQ::glbl_cp[i]);
    }
  // Now, write the bus and any other signals into the register inputs.
  for (i = 0; i < MAXPULSES && SEQ::glbl_cp[i] != NO_PULSE; i++)
    {
      CLK::doexecW(SEQ::glbl_cp[i]);
    }
  // Always execute these pulses.
  SCL::doexecWP_SCL();
  SCL::doexecWP_F17();
  SCL::doexecWP_F13();
  SCL::doexecWP_F10();
  TPG::doexecWP_TPG();
}
//-----------------------------------------------------------------------
// SIMULATION LOGIC
// contains prefix for source filename; i.e.: the portion
// of the filename before .obj or .lst
char filename[80];
char*
getCommand(const char* prompt)
{
#ifdef USE_NCURSES
  static char s[80];
  char* sp = s;
  printw("%s", prompt);
  char key;
  while ((key = _getch()) != '\n')
    {
      if (isprint(key))
        {
          printw("%c", key);
          *sp = key;
          sp++;
        }
      else if (key == 8 && sp != s)
        {
          printw("%c %0X", key, key);
          sp--;
        }
    }
  *sp = '\0';
  printw("%s", "\n");
  return s;
#else
  return (&userInput[1]);
#endif
}
bool breakpointEnab = false;
int breakpoint = 0;
void
toggleBreakpoint()
{
  if (!breakpointEnab)
    {
      char b[80];
      unsigned bank, offset, flat;
      int mct;
      strcpy(b,
          getCommand(
              "Set breakpoint: -- enter banked address or 14-bit CADR (octal) or cMCT: "));
      printw("%s\n", b);
      if (1 == sscanf(b, "c%d", &mct) && mct > 0)
        {
          breakpoint = -mct;
          breakpointEnab = true;
        }
      else if (2 == sscanf(b, "%o,%o", &bank, &offset))
        {
          breakpoint = bank * 02000 + offset % 02000;
          breakpointEnab = true;
        }
      else if (1 == sscanf(b, "%o", &flat))
        {
          breakpoint = flat;
          breakpointEnab = true;
        }
      else
        {
          printw("Unrecognized address, breakpoints cleared.\n");
          breakpointEnab = false;
        }
      if (breakpoint >= ROPE_SIZE)
        {
          printw("Address is out of range, breakpoints cleared.\n");
          breakpointEnab = false;
        }
    }
  else
    {
      printw("%s\n", "Clearing breakpoint.");
      breakpointEnab = false;
    }
}
bool watchEnab = false;
unsigned watchAddr = 0;
unsigned oldWatchValue = 0;
void
toggleWatch()
{
  if (!watchEnab)
    {
      char b[80];
      strcpy(b, getCommand("Set watch: -- enter 14-bit CADR (octal): "));
      printw("%s", "\n");
      watchAddr = strtol(b, 0, 8);
      watchEnab = true;
      oldWatchValue = MEM::readMemory(watchAddr);
      printw("%06o: %06o\n", watchAddr, oldWatchValue);
    }
  else
    {
      printw("%s\n", "Clearing watch.");
      watchEnab = false;
    }
}
void
incrCntr()
{
  char cntrname[80];
  strcpy(cntrname, getCommand("Increment counter: -- enter pcell (0-19): "));
  printw("%s", "\n");
  int pc = atoi(cntrname);
  CTR::pcUp[pc] = 1;
}
void
decrCntr()
{
  char cntrname[80];
  strcpy(cntrname, getCommand("Decrement counter: -- enter pcell (0-19): "));
  printw("%s", "\n");
  int pc = atoi(cntrname);
  CTR::pcDn[pc] = 1;
}
void
interrupt()
{
  char iname[80];
  strcpy(iname, getCommand("Interrupt: -- enter priority (1-5): "));
  printw("%s", "\n");
  int i = atoi(iname) - 1;
  INT::rupt[i] = 1;
}

// Load AGC memory from a .bin file created by yaYUL or oct2bin.
int
loadYul(char *filename)
{
  // Add the .bin extension.
  char fname[1024];
  uint8_t word[2];
  strcpy(fname, filename);
  strcat(fname, ".bin");
  FILE* fp = fopen(fname, "rb");
  if (!fp)
    return (1);
  unsigned addr = 02000;
  unsigned data;
  unsigned parity;
  while (1 == fread(word, 2, 1, fp))
    {
      // The file-data is big-endian and aligned to the most-significant
      // bit, with a "parity" bit that's always 0 at the least-significant
      // position.  We need it aligned to the least-significant bit, with
      // an odd-parity bit at the most-significant position.
      data = parity = (word[0] << 7) | (word[1] >> 1);
      /*
       parity = (parity ^ (parity << 8));
       parity = (parity ^ (parity << 4));
       parity = (parity ^ (parity << 2));
       parity = (parity ^ (parity << 1));
       data |= (parity & 0x8000) ^ 0x8000;
       */
      MEM::writeMemory(addr, data);
      addr++;
    }
  fclose(fp);
  printw("Memory loaded, %s.\n", fname);
  return (0);
}

// Load AGC memory from the specified file object file
int
loadObj(char *filename)
{
  // Add the .obj extension.
  char fname[80];
  strcpy(fname, filename);
  strcat(fname, ".obj");
  FILE* fp = fopen(fname, "r");
  if (!fp)
    return (1);
  unsigned addr;
  unsigned data;
  while (fscanf(fp, "%o %o", &addr, &data) != EOF)
    {
      MEM::writeMemory(addr, data);
    }
  fclose(fp);
  printw("Memory loaded, %s.\n", fname);
  return (0);
}

static uint16_t loadBuf[ROPE_SIZE + 1]; // temporary buffer for assembling H,L memory data
int
loadEPROM(char* fileName, bool highBytes)
{
  printw("Reading EPROM: %s\n", fileName);
  // Open the EPROM file.
  FILE* ifp = fopen(fileName, "r");
  if (!ifp)
    {
      printw("fopen failed for source file %s\n", fileName);
      return (1);
    }
  const int addressBytes = 3; // 24-bit address range
  const int sumCheckBytes = 1;
  char buf[4096]; // buffer holds a single S-Record
  while (fgets(buf, 4096, ifp))
    {
      // process a record
      if (buf[0] != 'S')
        {
          printw("Error reading start of EPROM record for: %s\n", fileName);
          return (1);
        }
      char tmp[256];
      strncpy(tmp, &buf[2], 2);
      tmp[2] = '\0';
      int totalByteCount = strtol(tmp, 0, 16);
      int mySumCheck = totalByteCount & 0xff;
      strncpy(tmp, &buf[4], 6);
      tmp[addressBytes * 2] = '\0';
      int address = strtol(tmp, 0, 16);
      mySumCheck = (mySumCheck + ((address & 0xff0000) >> 16)) % 256;
      mySumCheck = (mySumCheck + ((address & 0x00ff00) >> 8)) % 256;
      mySumCheck = (mySumCheck + ((address & 0x0000ff))) % 256;
      int dataBytes = totalByteCount - addressBytes - sumCheckBytes;
      int i = (addressBytes + 2) * 2; // index to 1st databyte char.
      for (int j = 0; j < dataBytes; j++)
        {
          // get a data byte
          strncpy(tmp, &buf[i], 2);
          tmp[2] = '\0';
          int data = strtol(tmp, 0, 16);
          mySumCheck = (mySumCheck + data) % 256;
          if (highBytes)
            {
              loadBuf[address] = loadBuf[address] | ((data << 8) & 0xff00);
            }
          else
            {
              loadBuf[address] = loadBuf[address] | (data & 0xff);
            }
          address++;
          i += 2; // bump to next databyte char
        }
      strncpy(tmp, &buf[i], 2);
      tmp[2] = '\0';
      int sumCheck = strtol(tmp, 0, 16);
      if (sumCheck != ((~mySumCheck) & 0xff))
        {
          printw(
              "sumCheck failed; file: %s, address: %0X, sumCheck: %0X, mySumCheck: %0X\n",
              fileName, address, sumCheck, mySumCheck);
          return (1);
        }
    }
  fclose(ifp);
  printw("%s\n", "Memory loaded.");
  return (0);
}
// Load AGC memory from the specified EPROM files
void
loadMemory(char *forceFilename)
{

  // Initialize memory.  The lowest bit, where the registers are,
  // is simply zeroed out, but the remainder of erasable and all
  // of fixed is loaded with "illegal" values having the 16th-bit
  // set, since the sim has no other way of writing a non-zero
  // 16th-bit in these areas.
  int i;
  for (i = 0; i < 060; i++)
    {
      MEM::register_EMEM[i].write(0);
      MEM::register_EMEM[i].clk();
    }
  for (i = 060; i < 02000; i++)
    {
      MEM::register_EMEM[i].write((zeroErasable) ? 0 : 0166666);
      MEM::register_EMEM[i].clk();
    }
  for (i = 02000; i < 041 * 02000; i++)
    {
      MEM::register_FMEM[i].write(0100000);
      MEM::register_FMEM[i].clk();
    }

  strcpy(filename, forceFilename);
  printw("%s\n", filename);
  // We first attempt to load from filename.bin (a yaYUL output file).
  // Failing that, we attempt to load from filename.obj (from John's
  // assembler).  Failing that, we fall back filename_H.hex and
  // filename_L.hex (Motorola hex files similar to filename.obj).
  if (loadYul(filename))
    {
      printw("Could not load %s.bin ... falling back on %s.obj.\n", filename,
          filename);
      if (loadObj(filename))
        {
          printw(
              "Could not load %s.obj ... trying %s_H.hex and %s_L.hex instead.\n",
              filename, filename, filename);
          char fname[80];
          // Add the _H.hex extension.
          strcpy(fname, filename);
          strcat(fname, "_H.hex");
          loadEPROM(fname, true);
          // Add the _L.hex extension.
          strcpy(fname, filename);
          strcat(fname, "_L.hex");
          loadEPROM(fname, false);
          //*******************************************************************
          // EPROM is now in loadBuf; move it to AGC memory.
          // AGC fixed memory only uses NUMFBANK banks.
          for (int address = 02000; address < ROPE_SIZE; address++)
            {
              // Don't load address region 0-1023; that region is allocated
              // to eraseable memory.
              MEM::writeMemory(address, loadBuf[address]);
            }
          //*******************************************************************
        }
    }
}
// Write the entire contents of fixed and
// eraseable memory to the specified file.
// Does not write the registers
void
saveMemory(const char* filename)
{
  FILE* fp = fopen(filename, "w");
  if (!fp)
    {
      printw("*** ERROR: fopen failed:  %s\n", filename);
      return;
    }
  char buf[100];
  for (unsigned addr = 020; addr < ROPE_SIZE; addr++)
    {
      sprintf(buf, "%06o %06o\n", addr, MEM::readMemory(addr));
      fputs(buf, fp);
    }
  fclose(fp);
}
void
examineMemory()
{
  char theAddress[20], *s;

  strcpy(theAddress,
      getCommand("Examine Memory -- enter octal address or address=value: "));
  printw("%s\n", theAddress);
  unsigned address, bank, offset, flat;
  if (2 == sscanf(theAddress, "%o,%o", &bank, &offset))
    {
      address = bank * 02000 + offset % 02000;
    }
  else if (1 == sscanf(theAddress, "%o", &flat))
    {
      address = flat;
    }
  else
    {
      printw("Unrecognized address.\n");
      return;
    }
  if (/* address < 0 || */ address >= ROPE_SIZE)
    {
      printw("Address is out of range.\n");
    }
  s = strstr(theAddress, "=");
  if (s != NULL)
    {
      unsigned Value;
      if (1 == sscanf(s, "=%o", &Value) && /* Value >= 0 && */ Value <= 0177777)
        {
          // I haven't caught all the special cases here, but right now I'm only interested
          // in address range 04-14.
          if (address == 4)
            {
              KBD::keypress((keyInType) Value);
              MEM::writeMemory(04, 040 | Value);
            }
          else if (address == 5)
            INP::register_IN1.write(Value);
          else if (address == 6)
            INP::register_IN2.write(Value);
          else if (address == 7)
            INP::register_IN3.write(Value);
          else if (address == 011)
            OUT::register_OUT1.write(Value);
          else if (address == 012)
            OUT::register_OUT2.write(Value);
          else if (address == 013)
            OUT::register_OUT3.write(Value);
          else if (address == 014)
            OUT::register_OUT4.write(Value);
          else
            MEM::writeMemory(address, Value);
        }
    }
  else
    {
      for (unsigned i = address; i < address + 24 && i < ROPE_SIZE; i++)
        {
          int data = MEM::readMemory(i);
          printw("%06o: %06o\n", i, data & 077777);
        }
    }
}
// Returns true if time (s) elapsed since last time it returned true; does not block
// search for "Time Management"
bool
checkElapsedTime(time_t s)
{
  if (!s)
    return true;
  static clock_t start = clock();
  clock_t finish = clock();
  double duration = (double) (finish - start) / CLOCKS_PER_SEC;
  if (duration >= s)
    {
      start = finish;
      return true;
    }
  return false;
}
// Blocks until time (s) has elapsed.
void
delay(time_t s)
{
  if (!s)
    return;
  clock_t start = clock();
  clock_t finish = 0;
  double duration = 0;
  do
    {
      finish = clock();
    }
  while ((duration = (double) (finish - start) / CLOCKS_PER_SEC) < s);
}
void
updateAGCDisplay()
{
  static bool displayTimeout = false;
  static int clockCounter = 0;
  if (checkElapsedTime(2))
    displayTimeout = true;
  if (MON::FCLK)
    {
      if (MON::RUN)
        {
          // update every 2 seconds at the start of a new instruction
          if (displayTimeout || dskyChanged)
            {
              clockCounter++;
              if ((TPG::register_SG.read() == TP12
                  && SEQ::register_SNI.read() == 1)
                  || (TPG::register_SG.read() == STBY) || clockCounter > 500
                  || dskyChanged)
                {
                  MON::displayAGC();
                  displayTimeout = false;
                  clockCounter = 0;
                  dskyChanged = false;
                }
            }
        }
      else
        {
          static bool displayOnce = false;
          if (TPG::register_SG.read() == WAIT)
            {
              if (displayOnce == false)
                {
                  MON::displayAGC();
                  displayOnce = true;
                  clockCounter = 0;
                }
            }
          else
            {
              displayOnce = false;
            }
        }
    }
  else
    MON::displayAGC(); // When the clock is manual or slow, always update.
}
void
showMenu()
{
  printw("BLOCK 1 EMULATOR MENU:\n");
  printw(" 'a' = STANDBY ALLOWED\n");
  printw(" 'b' or 'bc' = TOGGLE BREAKPOINT at address or MCT count\n");
  printw(" 'c' = TOGGLE SCALER: (for automatically generating F13 and F17.\n");
  printw(" 'd' = DISPLAY: refreshes current register display.\n");
  printw(" 'e' = EXAMINE: examine or change contents of memory.\n");
  printw(" 'f' = DEBUG: automatically display source code.\n");
  printw(" 'h' = RESET.\n");
  printw(" 'i' = INTERRUPT: generates an AGC interrupt, 1-5.\n");
  if (logFile != NULL)
    printw(" 'l' = LOGGING: toggle.\n");
  printw(" 'm' = MENU:  show this menu of commands.\n");
  printw(" 'n' = INST:  toggle stepping by MCT vs pulse-sequence\n");
  printw(" 'p' = POWER UP RESET\n");
  printw(" 'q' = QUIT:  quit the program.\n");
  printw(" 'r' = RUN:  toggle RUN/HALT switch upward to the RUN position.\n");
  printw(" 's' = STEP:  not sure if this does anything.\n");
  printw(
      " 't' = SINGLE CLOCK: Basically, step one clock pulse or one instruction.\n");
  printw(" 'u' = MANUAL CLOCK.\n");
  printw(" 'v' = FAST CLOCK.\n");
  printw(" 'w' = WHERE: set program counter.\n");
  printw(" 'x' = F13: manually generate F13 scaler pulse.\n");
  printw(" 'y' = TOGGLE WATCHPOINT\n");
  printw(" 'z' = F17: manually generate F17 scaler pulse.\n");
  printw(" ']' = +CNTR: give a plus input to a priority counter cell.\n");
  printw(" '[' = -CNTR: give a minus input to a priority counter cell.\n");
  printw(" ';' = CLEAR PARITY ALARM.\n");
  printw(" DSKY:\n");
  printw("    '0-9' = NUMBERS.\n");
  printw("    '+' = PLUS KEY.\n");
  printw("    '-' = MINUS KEY.\n");
  printw("    '.' = CLEAR KEY.\n");
  printw("    '*' = NOUN KEY.\n");
  printw("    '/' = VERB KEY.\n");
  printw("    'g' = KEY RELEASE.\n");
  printw("    'j' = ENTER KEY.\n");
}
#define MAX_LINE_LENGTH 110
const int startCol = 0; // columns are numbered 0-n
const int colLen = 5; // number of chars in column
const int maxLines = 24; // # of total lines to display
const int noffset = 10; // # of lines prior to, and including, selected line

// If/when I finish this code, what it will be is a buffer in memory of the
// entire assembly listing along with an array that gives an index into the
// line array for each possible address on the rope.  In other words, given
// a rope address, the associated line of code and the nearby lines can be
// instantly found.
#define MAX_LISTING_LINES 65536 // Empirically, about 30,000 needed.
static char bufferedListing[MAX_LISTING_LINES][MAX_LINE_LENGTH];
static int listingAddresses[035 * 02000];
static int numListingLines = 0;
void
bufferTheListing(char *filename)
{
  // Fill in the listingAddresses[] array with default values interpreted
  // as "unused".
  int i;
  for (i = 0; i < ROPE_SIZE; i++)
    listingAddresses[i] = -1;

  // Add the .lst extension and open the file.
  char fname[80], inputLine[1024];
  strcpy(fname, filename);
  strcat(fname, ".lst");
  // Open the file containing the source code listing.
  FILE* fp = fopen(fname, "r");
  if (!fp)
    {
      printw("Can't load source list file: %s\n", fname);
      return;
    }

  // Buffer the file in memory.
  while (NULL != fgets(inputLine, sizeof(inputLine), fp))
    {
      char *s;
      if (numListingLines >= MAX_LISTING_LINES)
        {
          printw("Too many lines in source list.\n");
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

  // Fill in the listingAddresses[] array with the flat addresses
  // corresponding to the buffered lines.  Or more accurately, given
  // a flat address in the rope, give the index into the lined buffer
  // corresponding to that address.  -1 means unused.
  for (i = 0; i < numListingLines; i++)
    {
      char c, *line;
      bool found = false;
      unsigned totalLine, fileLine, fileBank, fileOffset, fileFlat,
          effectiveAddress;

      line = bufferedListing[i];

      // We don't know if the listing is in John Pultorak's format
      // or yaYUL's so we check both.
      if (line[0] >= '0' && line[0] <= '7' && line[1] >= '0' && line[1] <= '7'
          && line[2] >= '0' && line[2] <= '7' && line[3] >= '0'
          && line[3] <= '7' && line[4] >= '0' && line[4] <= '7'
          && isspace(line[5]))
        found = true;
      else if (4
          == sscanf(line, "%u,%u:%o%c", &totalLine, &fileLine, &fileFlat, &c)
          && isspace(c))
        {
          effectiveAddress = fileFlat;
          addressOkay: ;
          if (effectiveAddress < ROPE_SIZE)
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
              if (j >= 3
                  && (!strcmp(fields[2], "BANK") || !strcmp(fields[2], "SETLOC")
                      || !strcmp(fields[2], "EQUALS")
                      || !strcmp(fields[2], "ERASE")))
                {
                }
              else if (j >= 4
                  && (!strcmp(fields[3], "EQUALS")
                      || !strcmp(fields[3], "ERASE")))
                {
                }
              else if (j >= 5 && (!strcmp(fields[4], "=")))
                {
                }
              else
                found = true;
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
}

void
showSourceCode()
{
  unsigned effectiveAddress = MON::getPC();
  int index = listingAddresses[effectiveAddress];
  if (index < 0)
    return;
  int start = index - 5;
  if (start < 0)
    start = 0;
  int end = index + 5;
  if (end >= ROPE_SIZE)
    end = ROPE_SIZE - 1;
  for (int i = start; i <= end; i++)
    {
      if (i == index)
        printw("   --------------------------------------------------"
            "--------------------------------------------------------\n");
      printw(" %c %s\n", (i == index) ? '>' : ' ', bufferedListing[i]);
      if (i == index)
        printw("   --------------------------------------------------"
            "--------------------------------------------------------\n");
    }
}

int
main(int argc, char* argv[])
{
  int power = 0;
  char Solarium[] = "Solarium055", *initialRope = Solarium;
  bool autoShowSourceCode = true, loggingOn = true;
  int stepCount = 0;

  // Parse command line.
    {
      int i, j;
      unsigned u;
      for (i = 1; i < argc; i++)
        {
          if (1 == sscanf(argv[i], "--go=%o", &u))
            whereGo = u;
          else if (!strncmp(argv[i], "--rope=", 7))
            initialRope = &argv[i][7];
          else if (!strncmp(argv[i], "--log=", 6))
            {
              logFile = fopen(&argv[i][6], "w");
              if (logFile == NULL)
                printw("Cannot open log file %s\n", &argv[i][6]);
            }
          else if (!strcmp(argv[i], "--power"))
            power = 3;
          else if (1 == sscanf(argv[i], "--extra=%o", &j))
            {
              if (numLogExtras < MAX_LOG_EXTRAS && j >= 0 && j < ROPE_SIZE)
                logExtras[numLogExtras++] = j;
              else
                printf("Illegal %s\n", argv[i]);
            }
          else if (!strcmp(argv[i], "--zero"))
            zeroErasable = true;
          else if (!strcmp(argv[i], "--uninit"))
            zeroErasable = false;
          else
            {
              printf("Usage:\n");
              printf("\tyaAGC-Block1 [OPTIONS]\n");
              printf("Possible OPTIONS:\n");
              printf("--go=O       Starting address (octal), default 2030.\n");
              printf("--rope=F     Specify a rope, default Solarium055.\n");
              printf("--log=F      Specify a log file (default none).\n");
              printf(
                  "--extra=OCT  In the --log file, add the value at the address OCT\n");
              printf(
                  "             to the log.  There can be up to %d of these.\n",
                  MAX_LOG_EXTRAS);
              printf(
                  "--power      Automatically give 'p', 'r', 't' commands\n");
              printf("             upon entry.\n");
              printf(
                  "--zero       At power-up, initialize erasable 060-01777 to 0,\n");
              printf("             This is the default.\n");
              printf(
                  "--uninit     At power-up, initialize erasable 060-01777 to 0166666,\n");
              printf("             rather than the default 0.\n");
              return (1);
            }
        }
    }

#ifdef USE_NCURSES
  // Make ncurses getch() non-blocking.
  initscr();
  keypad(stdscr, TRUE);
  cbreak();
  noecho();
  nodelay(stdscr, TRUE);
  scrollok(stdscr, TRUE);
#endif
  setvbuf(stdout, NULL, _IONBF, 0);

  CPM::readEPROM("CPM1_8.hex", CPM::EPROM1_8);
  CPM::readEPROM("CPM9_16.hex", CPM::EPROM9_16);
  CPM::readEPROM("CPM17_24.hex", CPM::EPROM17_24);
  CPM::readEPROM("CPM25_32.hex", CPM::EPROM25_32);
  CPM::readEPROM("CPM33_40.hex", CPM::EPROM33_40);
  CPM::readEPROM("CPM41_48.hex", CPM::EPROM41_48);
  CPM::readEPROM("CPM49_56.hex", CPM::EPROM49_56);
  loadMemory(initialRope);
  loadPads(initialRope);
  bufferTheListing(initialRope);

  bool singleClock = false;
  bool anyWZ = false;
  genAGCStates();
  MON::displayAGC();
  while (1)
    {
      // NOTE: assumes that the display is always pointing to the start of
      // a new line at the top of this loop!
      // Clock the AGC, but between clocks, poll the keyboard
      // for front-panel input by the user. This uses a Microsoft function;
      // substitute some other non-blocking function to access the keyboard
      // if you're porting this to a different platform.
      if (!singleClock && !MON::FCLK)
        printw("%s", "> ");
#ifdef USE_NCURSES
      while (!_kbhit())
#else
      while (NULL == nbfgets(userInput, sizeof(userInput)))
#endif
        {
          if (MON::RUN && (MON::FCLK || singleClock))
            {
              // This is a performance enhancement. If the AGC is running,
              // don't check the keyboard or simulator display every
              // simulation cycle, because that slows the simulator
              // down too much.
              int genStateCntr = 100;
              do
                {
                  CLK::clkAGC();
                  genAGCStates();
                  anyWZ = anyWZ || SEQ::anyWZ();
                  if (!MON::INST
                      || (MON::INST && TPG::register_SG.read() == TP1 && anyWZ
                          && SEQ::glbl_subseq != CCS1
                          && SEQ::glbl_subseq != STD2))
                    {
                      singleClock = false;
                    }
                  genStateCntr--;
                  // Needs more work. It doesn't always stop at the
                  // right location and sometimes stops at the
                  // instruction afterwards, too.
                  if (breakpointEnab)
                    {
                      int countMCT = (SCL::register_SCL.read() >= 016) ?
                          ((SCL::register_SCL.read() - 016) / 014) : 0;
                      if (breakpoint == ADR::getEffectiveAddress())
                        {
                          //MON::RUN = 0;
                          MON::FCLK = 0;
                          stepCount = 0;
                          singleClock = 0;
                        }
                      else if (breakpoint < 0 && countMCT >= -breakpoint)
                        {
                          MON::FCLK = 0;
                          stepCount = 0;
                          singleClock = 0;
                        }
                    }
                  // Halt right after instr that changes a watched
                  // memory location.
                  if (watchEnab)
                    {
                      unsigned newWatchValue = MEM::readMemory(watchAddr);
                      if (newWatchValue != oldWatchValue)
                        {
                          MON::RUN = 0;
                        }
                      oldWatchValue = newWatchValue;
                    }
                }
              while ((MON::FCLK || singleClock) && MON::RUN && genStateCntr > 0);
              if (stepCount >= 0 && stepCount <= 1  && !MON::FCLK)
                {
                  updateAGCDisplay();
                  if (autoShowSourceCode)
                    showSourceCode();
                  if (logFile != NULL && loggingOn)
                    MON::logAGC(logFile);
                  if (!MON::FCLK)
                    printw("%s", "> ");
                }
              else
                {
                  if (logFile != NULL && loggingOn)
                    MON::logAGC(logFile);
                }
            }
          // for convenience, clear the single step switch on TP1; in the
          // hardware AGC, this happens when the switch is released
          if (MON::STEP && TPG::register_SG.read() == TP1)
            {
              MON::STEP = 0;
            }
          if (stepCount > 0)
            {
              stepCount--;
              if (stepCount > 0)
                {
                  singleClock = true;
                  anyWZ = false;
                }
            }
          else if (stepCount < 0)
            {
              singleClock = true;
              anyWZ = false;
            }
          if (power)
            break;
        }
      stepCount = 0;
      char key;
      if (power == 3)
        {
          key = 'p';
          power--;
        }
      else if (power == 2)
        {
          key = 'r';
          power--;
        }
      else if (power == 1)
        {
          key = 't';
          power--;
        }
      else
        {
#ifdef USE_NCURSES
          key = _getch();
#else
          key = userInput[0];
#endif
        }
      int newAddress = 02030;
      // Keyboard controls for front-panel:
      switch (key)
        {
      case ';':
        // Clear ALARM indicators
        PAR::CLR_PALM(); // Asynchronously clear PARITY FAIL
        MON::displayAGC();
        break;
      case '+':
        KBD::keypress(KEYIN_PLUS);
        break;
      case '-':
        KBD::keypress(KEYIN_MINUS);
        break;
      case '.':
        KBD::keypress(KEYIN_CLEAR);
        break;
      case '/':
        KBD::keypress(KEYIN_VERB);
        break;
      case '*':
        KBD::keypress(KEYIN_NOUN);
        break;
      case '0':
        KBD::keypress(KEYIN_0);
        break;
      case '1':
        KBD::keypress(KEYIN_1);
        break;
      case '2':
        KBD::keypress(KEYIN_2);
        break;
      case '3':
        KBD::keypress(KEYIN_3);
        break;
      case '4':
        KBD::keypress(KEYIN_4);
        break;
      case '5':
        KBD::keypress(KEYIN_5);
        break;
      case '6':
        KBD::keypress(KEYIN_6);
        break;
      case '7':
        KBD::keypress(KEYIN_7);
        break;
      case '8':
        KBD::keypress(KEYIN_8);
        break;
      case '9':
        KBD::keypress(KEYIN_9);
        break;
      case 'a':
        MON::SA = (MON::SA + 1) % 2;
        genAGCStates();
        MON::displayAGC();
        break;
      case 'b':
        toggleBreakpoint();
        break;
      case 'c':
        MON::SCL_ENAB = (MON::SCL_ENAB + 1) % 2;
        genAGCStates();
        MON::displayAGC();
        break;
      case 'd':
        genAGCStates();
        MON::displayAGC();
        break; // update display
      case 'e':
        examineMemory();
        break;
      case 'f':
        autoShowSourceCode = !autoShowSourceCode;
        if (autoShowSourceCode)
          showSourceCode();
        break;
      case 'g':
        KBD::keypress(KEYIN_KEY_RELEASE);
        break;
      case 'h':
        KBD::keypress(KEYIN_ERROR_RESET);
        break;
      case 'i':
        interrupt();
        //genAGCStates();
        //displayAGC(EVERY_CYCLE);
        break;
      case 'j':
        KBD::keypress(KEYIN_ENTER);
        break;
      case 'l':
        loggingOn = !loggingOn;
        if (loggingOn)
          printw("Logging toggled on.\n");
        else
          printw("Logging toggled off.\n");
        break;
      case 'm':
        showMenu();
        break;
      case 'n':
        MON::INST = (MON::INST + 1) % 2;
        genAGCStates();
        MON::displayAGC();
        break;
      case 'p':
        MON::PURST = (MON::PURST + 1) % 2;
        genAGCStates();
        MON::displayAGC();
        break;
      case 'q':
        printw("%s\n", "QUIT...");
        endwin();
        if (logFile != NULL)
          fclose(logFile);
        exit(0);
      case 'r':
        MON::RUN = (MON::RUN + 1) % 2;
        genAGCStates();
        if (!MON::FCLK)
          MON::displayAGC();
        break;
      case 's':
        MON::STEP = (MON::STEP + 1) % 2;
        genAGCStates();
        if (!MON::FCLK)
          MON::displayAGC();
        break;
      case 't': // single clock pulse (when system clock off)
        if (!MON::PURST && MON::RUN)
          {
            stepCount = atoi(&userInput[1]);
            if (stepCount == 0)
              printw("%s\n", "Single clock");
            else
              printf("%d clocks\n", stepCount);
            singleClock = true;
            anyWZ = false;
          }
        else
          {
            printw("%s\n", "Must be powered-up and in a running state.");
          }
        break;
      case 'u': // manual clock (FCLK=0)
        printw("%s\n", "Manual clock");
        MON::FCLK = 0;
        genAGCStates();
        MON::displayAGC();
        break;
      case 'v': // fast clock (FCLK=1)
        printw("%s\n", "Fast clock");
        MON::FCLK = 1;
        genAGCStates();
        MON::displayAGC();
        break;
      case 'w':
        {
          char b[80];
          strcpy(b,
              getCommand("New address (octal, flat address space) [2000]: "));
          newAddress = strtol(b, 0, 8);
          if (newAddress == 0)
            newAddress = 02030;
        }
        if (newAddress < 06000)
          {
            ADR::register_S.write(newAddress);
            ADR::register_S.clk();
            printw("Program counter -> %04o\n", ADR::register_S.read());
          }
        else
          {
            ADR::register_S.write(newAddress & 01777);
            ADR::register_S.clk();
            ADR::register_BNK.write(newAddress >> 10);
            ADR::register_BNK.clk();
            printw("Program counter -> %02o,%04o\n", ADR::register_BNK.read(),
                06000 + ADR::register_S.read());
          }
        genAGCStates();
        MON::displayAGC();
        break;
      case 'x':
        //SCL::F13 = (SCL::F13 + 1) % 2;
        genAGCStates();
        MON::displayAGC();
        break;
      case 'y':
        toggleWatch();
        break;
      case 'z':
        //SCL::F17 = (SCL::F17 + 1) % 2;
        genAGCStates();
        MON::displayAGC();
        break;
      case ']':
        incrCntr();
        //genAGCStates();
        //displayAGC(EVERY_CYCLE);
        break;
      case '[':
        decrCntr();
        //genAGCStates();
        //displayAGC(EVERY_CYCLE);
        break;
      default:
        printw("%c=%0X\n", key, key);
        }
    }
  return (0);
}

