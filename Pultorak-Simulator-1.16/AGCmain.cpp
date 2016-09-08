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
#include <conio.h>
#include <iostream>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <time.h>
#include <ctype.h>
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
getCommand(char* prompt)
{
  static char s[80];
  char* sp = s;
  cout << prompt;
  cout.flush();
  char key;
  while ((key = _getch()) != 13)
    {
      if (isprint(key))
        {
          cout << key;
          cout.flush();
          *sp = key;
          sp++;
        }
      else if (key == 8 && sp != s)
        {
          cout << key << " " << key;
          cout.flush();
          sp--;
        }
    }
  *sp = '\0';
  return s;
}
bool breakpointEnab = false;
unsigned breakpoint = 0;
void
toggleBreakpoint()
{
  if (!breakpointEnab)
    {
      char b[80];
      strcpy(b, getCommand("Set breakpoint: -- enter 14-bit CADR (octal): "));
      cout << endl;
      breakpoint = strtol(b, 0, 8);
      breakpointEnab = true;
    }
  else
    {
      cout << "Clearing breakpoint." << endl;
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
      cout << endl;
      watchAddr = strtol(b, 0, 8);
      watchEnab = true;
      oldWatchValue = MEM::readMemory(watchAddr);
      char buf[100];
      sprintf(buf, "%06o: %06o", watchAddr, oldWatchValue);
      cout << buf << endl;
    }
  else
    {
      cout << "Clearing watch." << endl;
      watchEnab = false;
    }
}
void
incrCntr()
{
  char cntrname[80];
  strcpy(cntrname, getCommand("Increment counter: -- enter pcell (0-19): "));
  cout << endl;
  int pc = atoi(cntrname);
  CTR::pcUp[pc] = 1;
}
void
decrCntr()
{
  char cntrname[80];
  strcpy(cntrname, getCommand("Decrement counter: -- enter pcell (0-19): "));
  cout << endl;
  int pc = atoi(cntrname);
  CTR::pcDn[pc] = 1;
}
void
interrupt()
{
  char iname[80];
  strcpy(iname, getCommand("Interrupt: -- enter priority (1-5): "));
  cout << endl;
  int i = atoi(iname) - 1;
  INT::rupt[i] = 1;
}
#ifdef NOTDEF
// Load AGC memory from the specified file object file
void loadMemory()
  {
    strcpy(filename, getCommand("Load Memory -- enter filename: "));
    cout << endl;
    // Add the .obj extension.
    char fname[80];
    strcpy(fname, filename);
    strcat(fname, ".obj");
    FILE* fp = fopen(fname, "r");
    if(!fp)
      {
        perror("fopen failed:");
        cout << "*** ERROR: Can't load memory for file: " << fname << endl;
        return;
      }
    unsigned addr;
    unsigned data;
    while(fscanf(fp, "%o %o", &addr, &data) != EOF)
      {
        MEM::writeMemory(addr, data);
      }
    fclose(fp);
    cout << "Memory loaded." << endl;
  }
#endif
static int loadBuf[0xffff + 1]; // tempory buffer for assembling H,L memory data
void
loadEPROM(char* fileName, bool highBytes)
{
  cout << "Reading EPROM: " << fileName << endl;
  // Open the EPROM file.
  FILE* ifp = fopen(fileName, "r");
  if (!ifp)
    {
      perror("fopen failed for source file");
      exit(-1);
    }
  const int addressBytes = 3; // 24-bit address range
  const int sumCheckBytes = 1;
  char buf[4096]; // buffer holds a single S-Record
  while (fgets(buf, 4096, ifp))
    {
      // process a record
      if (buf[0] != 'S')
        {
          cout << "Error reading start of EPROM record for: " << fileName
              << endl;
          exit(-1);
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
      //cout << hex << totalByteCount << ", " << address << dec << endl;
      int dataBytes = totalByteCount - addressBytes - sumCheckBytes;
      int i = (addressBytes + 2) * 2; // index to 1st databyte char.
      for (int j = 0; j < dataBytes; j++)
        {
          // get a data byte
          strncpy(tmp, &buf[i], 2);
          tmp[2] = '\0';
          int data = strtol(tmp, 0, 16);
          //cout << hex << data << dec << endl;
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
          cout << "sumCheck failed; file: " << fileName << ", address: " << hex
              << address << ", sumCheck: " << sumCheck << ", mySumCheck: "
              << mySumCheck << dec << endl;
          exit(-1);
        }
    }
  fclose(ifp);
  cout << "Memory loaded." << endl;
}
// Load AGC memory from the specified EPROM files
void
loadMemory()
{
  strcpy(filename, getCommand("Load Memory -- enter filename: "));
  cout << endl;
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
  for (int address = 1024; address < 1024 * (NUMFBANK + 1); address++)
    {
      // Don't load address region 0-1023; that region is allocated
      // to eraseable memory.
      //cout << "loading CADR=" << hex << address << endl;
      MEM::writeMemory(address, loadBuf[address]);
    }
//*******************************************************************
}
// Write the entire contents of fixed and
// eraseable memory to the specified file.
// Does not write the registers
void
saveMemory(char* filename)
{
  FILE* fp = fopen(filename, "w");
  if (!fp)
    {
      perror("*** ERROR: fopen failed:");
      exit(-1);
    }
  char buf[100];
  for (unsigned addr = 020; addr <= 031777; addr++)
    {
      sprintf(buf, "%06o %06o\n", addr, MEM::readMemory(addr));
      fputs(buf, fp);
    }
  fclose(fp);
}
void
examineMemory()
{
  char theAddress[20];
  strcpy(theAddress, getCommand("Examine Memory -- enter address (octal): "));
  cout << endl;
  unsigned address = strtol(theAddress, 0, 8);
  char buf[100];
  for (unsigned i = address; i < address + 23; i++)
    {
      sprintf(buf, "%06o: %06o", i, MEM::readMemory(i));
      cout << buf << endl;
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
  cout << "AGC4 EMULATOR MENU:" << endl;
  cout << " 'r' = RUN: toggle RUN/HALT switch upward to the RUN position."
      << endl;
}
const int startCol = 0; // columns are numbered 0-n
const int colLen = 5; // number of chars in column
const int maxLines = 23; // # of total lines to display
const int noffset = 10; // # of lines prior to, and including, selected line
const int maxLineLen = 79;
void
showSourceCode()
{
// Add the .lst extension.
  char fname[80];
  strcpy(fname, filename);
  strcat(fname, ".lst");
// Open the file containing the source code listing.
  FILE* fp = fopen(fname, "r");
  if (!fp)
    {
      perror("fopen failed:");
      cout << "*** ERROR: Can't load source list file: " << fname << endl;
      return;
    }
  cout << endl;
// Get the address of the source code line to display.
// The address we want is the current effective address is the
// S and bank registers.
  char CADR[colLen + 1];
  sprintf(CADR, "%05o", ADR::getEffectiveAddress());
  int op = 0; // offset index
  long foffset[noffset];
  for (int i = 0; i < noffset; i++)
    foffset[i] = 0;
  bool foundit = false;
  int lineCount = 0;
  char s[256];
  char valString[20];
  char out[256];
  while (!feof(fp))
    {
      if (!foundit)
        {
          foffset[op] = ftell(fp);
          op = (op + 1) % noffset;
        }
// Read a line of the source code list file.
      if (fgets(s, 256, fp))
        {
// Get the address (CADR) from the line.
          strncpy(valString, s + startCol, colLen);
          valString[colLen] = '\0';
// 'foundit' is true after we have found the desired line.
          if (foundit)
            {
              if (strcmp(valString, CADR) == 0)
                cout << ">";
              else
                cout << " ";
// truncate line so it fits in 80 col display
              strncpy(out, s, maxLineLen);
              out[maxLineLen] = '\0';
              cout << out;
              lineCount++;
              if (lineCount >= maxLines)
                break;
            }
          else
            {
              if (strcmp(valString, CADR) == 0)
                {
// Reposition the file pointer back several lines so
// we can see the code that preceeds the desired
// line, too.
                  foundit = true;
                  fseek(fp, foffset[op], 0);
                }
            }
        }
    }
  fclose(fp);
}
void
main(int argc, char* argv[])
{
  CPM::readEPROM("CPM1_8.hex", CPM::EPROM1_8);
  CPM::readEPROM("CPM9_16.hex", CPM::EPROM9_16);
  CPM::readEPROM("CPM17_24.hex", CPM::EPROM17_24);
  CPM::readEPROM("CPM25_32.hex", CPM::EPROM25_32);
  CPM::readEPROM("CPM33_40.hex", CPM::EPROM33_40);
  CPM::readEPROM("CPM41_48.hex", CPM::EPROM41_48);
  CPM::readEPROM("CPM49_56.hex", CPM::EPROM49_56);
  bool singleClock = false;
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
      cout << "> ";
      cout.flush(); // display prompt
      while (!_kbhit())
        {
          if (MON::FCLK || singleClock)
            {
              // This is a performance enhancement. If the AGC is running,
              // don't check the keyboard or simulator display every
              // simulation cycle, because that slows the simulator
              // down too much.
              int genStateCntr = 100;
              do
                {
                  CLK::clkAGC();
                  singleClock = false;
                  genAGCStates();
                  genStateCntr--;
                  // Needs more work. It doesn't always stop at the
                  // right location and sometimes stops at the
                  // instruction afterwards, too.
                  if (breakpointEnab
                      && breakpoint == ADR::getEffectiveAddress())
                    {
                      MON::RUN = 0;
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
              while (MON::FCLK && MON::RUN && genStateCntr > 0);
              updateAGCDisplay();
            }
          // for convenience, clear the single step switch on TP1; in the
          // hardware AGC, this happens when the switch is released
          if (MON::STEP && TPG::register_SG.read() == TP1)
            MON::STEP = 0;
        }
      char key = _getch();
      // Keyboard controls for front-panel:
      switch (key)
        {
      // AGC controls
      // simulator controls
      case 'q':
        cout << "QUIT..." << endl;
        exit(0);
      case 'm':
        showMenu();
        break;
      case 'd':
        genAGCStates();
        MON::displayAGC();
        break; // update display
      case 'l':
        loadMemory();
        break;
      case 'e':
        examineMemory();
        break;
      case 'f':
        showSourceCode();
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
      case 'i':
        interrupt();
        //genAGCStates();
        //displayAGC(EVERY_CYCLE);
        break;
      case 'z':
        //SCL::F17 = (SCL::F17 + 1) % 2;
        genAGCStates();
        MON::displayAGC();
        break;
      case 'x':
        //SCL::F13 = (SCL::F13 + 1) % 2;
        genAGCStates();
        MON::displayAGC();
        break;
      case 'c':
        MON::SCL_ENAB = (MON::SCL_ENAB + 1) % 2;
        genAGCStates();
        MON::displayAGC();
        break;
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
      case 'a':
        MON::SA = (MON::SA + 1) % 2;
        genAGCStates();
        MON::displayAGC();
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
      case 'b':
        toggleBreakpoint();
        break;
      case 'y':
        toggleWatch();
        break;
      case ';':
        // Clear ALARM indicators
        PAR::CLR_PALM(); // Asynchronously clear PARITY FAIL
        MON::displayAGC();
        break;
      // DSKY:
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
      case 'g':
        KBD::keypress(KEYIN_KEY_RELEASE);
        break;
      case 'h':
        KBD::keypress(KEYIN_ERROR_RESET);
        break;
      case 'j':
        KBD::keypress(KEYIN_ENTER);
        break;
      case '\0': // must be a function key
        key = _getch();
        switch (key)
          {
        case 0x3b: // F1: single clock pulse (when system clock off)
          singleClock = true;
          break;
        case 0x3c: // F2: manual clock (FCLK=0)
          MON::FCLK = 0;
          genAGCStates();
          MON::displayAGC();
          break;
        case 0x3e: // F4: fast clock (FCLK=1)
          MON::FCLK = 1;
          genAGCStates();
          MON::displayAGC();
          break;
        default:
          cout << "function key: " << key << "=" << hex << (int) key << dec
              << endl;
          }
        break;
      //default: cout << "??" << endl;
      default:
        cout << key << "=" << hex << (int) key << dec << endl;
        }
    }
}
