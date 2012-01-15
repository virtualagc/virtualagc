/*
 * Copyright 2011 Ronald S. Burkey <info@sandroid.org>
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
 * Filename:    yaOBC.c
 * Purpose:     Emulator for Gemini OBC and Apollo LVDC CPUs
 * Compiler:    GNU gcc.
 * Reference:   http://www.ibibio.org/apollo
 * Mods:        2011-12-23 RSB  By all that's good and holy, I
 *                              should be adapting this from
 *                              yaAGC or yaAGS ... but I'm not.
 *                              It's easier (or at least, less
 *                              horrible) to start from scratch
 *                              and accept the consequences than it
 *                              is to try and figure out old code.
 */

#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <time.h>
#include <ctype.h>
#include <math.h>
#include <pthread.h>
#include "enet/enet.h"
#ifdef WIN32
#include <windows.h>
struct tms
  {
    clock_t tms_utime; /* user time */
    clock_t tms_stime; /* system time */
    clock_t tms_cutime; /* user time of children */
    clock_t tms_cstime; /* system time of children */
  };
#define _SC_CLK_TCK (1000)
#define sysconf(x) (x)
#define times(p) (clock_t)GetTickCount ()
#else
#include <sys/times.h>
#endif
#include "../yaASM/yaASM.h"

//==========================================================================
// Some function prototypes for forward-references.

int
ParseCommandLine(int argc, char *argv[]);
int
ReadBinaryFile(void);
int
WriteBinaryFile(char *BinaryFile);
int
ReadSymbolFile(void);
int
WriteIoFile(char *IoFile);
int
ReadIoFile(void);
void
PrintAddress(Address_t *Address);
void
SetCyclesPerTick(double NewSpeedup);
long
ComputeNeededCycles(void);
void
RunOneMachineCycle(void);
void *
DebuggerThreadFunction(void *Data);
void *
HalSockThreadFunction(void *Data);
void
DisplayCurrentDebuggingLocation(void);
void
BuildAddressFromObcHopRegister(uint32_t RawHopRegister, Address_t *HopRegister);
void
BuildObcHopRegisterFromAddress(Address_t *HopRegister, uint32_t *RawHop);
void
DisplayDebuggerPrompt(void);
int
CompareSourceByAddresses(const void *s1, const void *s2);
int
CompareSymbols(const void *s1, const void *s2);
int
ParseLocation(char *Location, uint32_t **Mem32, uint16_t **Mem16M,
    uint16_t **Mem16L, Address_t **MemAddress);
int
ParseValue(char *ValueString, int *Value);
void
SleepMilliseconds(unsigned Milliseconds);

typedef int
HalOutputFunction_t(int yx, int32_t Value);
typedef int
HalInputFunction_t(int yx, int32_t *Value);
HalOutputFunction_t ProOutputFunctionMem, CldOutputFunctionMem,
    ProOutputFunctionSock, CldOutputFunctionSock;
HalInputFunction_t ProInputFunctionMem, CldInputFunctionMem,
    ProInputFunctionSock, CldInputFunctionSock;
int
HalSockInitialize(void);
void
HalSockBroadcastString(char *String, int Length);

//==========================================================================
// Constants, type definitions, global variables ....

#define BITS13 017777
#define BITS26 0377777777
#define BIT13 010000
#define BIT26 0200000000
#define BREAK13 0x8000
#define BREAK26 0x80000000

// Temporary variables.
static Line_t LineBuffer;

// Command-line arguments.
#define PORT 19653
int Lvdc = 0, Run = 0, Port = PORT, Verbosity = 0;
char *BinaryFile = "yaOBC.bin";
char *SymbolFile = NULL;
char *IoFile = "yaOBC.io";

// Machine state: HOP register, memory image.  Note that we use a structural
// representation of the HOP register and convert back/forth to a pure
// integer form when needed (which is only when a system snapshot is read
// or written).  The Accumulator we always keep as a simple integer.
// The PQ register we treat in the following manner: we always immediately
// load the lower 26 bits with the result it's supposed to hold as the
// result of an MPY or DIV, but since those results aren't actually
// supposed to be available immediately, we use bits D28-D30 as a
// countdown timer that increments once per machine cycle; so the contents
// of PQ are valid only when the upper nibble reaches 0.  Bit D31 is used
// as a watchpoint flag for both 26-bit registers.
BinaryImage_t Binary;
Address_t HopRegister;
uint32_t Accumulator, PqRegister;

// The symbol table and source code for symbolic debugging.
SymbolList_t Symbols;
int NumSymbols = 0;
typedef struct
{
  Address_t Address;
  uint32_t Value;
  Line_t SourceText;
} SourceLine_t;
SourceLine_t *SourceLines = NULL;
int MaxSourceLines = 0;
int NumSourceLines = 0;

// Emulated program timing.
int StepN = 0;
unsigned long TotalCycles = 0;
double Speedup = 0; // Just 0 for setup purposes.
double CyclesPerTick;
#define SECONDS_PER_CYCLE 0.000140
// The CurrentXXXX values relate just to the interval since the
// emulated program last started freely running ... i.e., if the
// program was ever paused for single-stepping, breakpoints,
// etc., these values are reset.  Only the TotalCycles accounts
// for execution prior to the last pause.
long CurrentStartCycles = 0, CurrentCycles = 0;
clock_t CurrentStartTicks = 0, CurrentTicks = 0;
struct tms TmsStruct;

// For the socket interface.
pthread_t HalSockThread;
pthread_mutex_t HalSockMutex =
PTHREAD_MUTEX_INITIALIZER;
typedef struct
{
  int Type; // 0 for PRO, 1 for CLD
  int yx;
  unsigned long Data;
  unsigned long Count;
  unsigned long Order;
} HalSockEvent_t;
#define MAX_HALSOCK_EVENTS 2048
HalSockEvent_t HalSockEvents[MAX_HALSOCK_EVENTS];
int NumHalSockEvents = 0;

int
HalSockEventCmp(const void *e1, const void *e2)
{
#define EVENT1 ((HalSockEvent_t *) e1)
#define EVENT2 ((HalSockEvent_t *) e2)
  int i;
  i = EVENT1->Count - EVENT2->Count;
  if (i == 0)
    i = EVENT1->Order - EVENT2->Order;
  return (i);
#undef EVENT1
#undef EVENT2
}

// For the debugger thread.
pthread_t DebuggerThread;
pthread_mutex_t DebuggerMutex =
PTHREAD_MUTEX_INITIALIZER;
Line_t DebuggerUserInput;
volatile int NeedDebuggerPrompt = 1;
int DebuggerPause = 0; // The debugger sets this to get emulation to stop.
int DebuggerQuit = 0; // The debugger sets this to request a shutdown.
int DebuggerRun = 0; // The debugger sets this to request the emulation to start.
int EmulatorEndOfSector = 0; // The emulator sets this after reaching end-of-sector.
int EmulatorPause = 0; // The emulator sets this to pause emulation.
int EmulatorTimeout = 0; // Emulator sets this if PRO/CLD instruction times out.
int EmulatorUnimplementedYX = 0; // Unimplemented YX for PRO/CLD/SHF.
int EmulatorBreakpoint = 0;
int EmulatorWatchpoint = 0;
int IgnoreBreakpoint = 0;
enum WatchmodeType_t
{
  WT_ANY, WT_WRITE, WT_CHANGE
};
enum WatchmodeType_t WatchmodeType = WT_CHANGE;
// The next variable is the HOP the last time the debugger displayed
// the source code and machine status.  It's used to keep the same display
// from appearing over and over.
Address_t LastDebuggedHopRegister =
  { 0xFFFF };
const char *ObcOps[] =
  { "HOP", "DIV", "PRO", "RSU", "ADD", "SUB", "CLA", "AND", "MPY", "TRA",
      "SHF", "TMI", "STO", "SPQ", "CLD", "TNZ" };

// For helping to determine what to do with PRO instructions, as to whether
// input or output is done.
enum ProType_t
{
  PRO_ILLEGAL = 0,
  PRO_TBD,
  PRO_OUTPUT,
  PRO_INPUT,
  PRO_TRS_PULSES,
  PRO_REENT_ATM
};
enum PeripheralType_t
{
  PRF_ILLEGAL = 0,
  PRF_TBD,
  PRF_ACME,
  PRF_AGE,
  PRF_ATM,
  PRF_DCS,
  PRF_FDI,
  PRF_IMU,
  PRF_IS,
  PRF_IVI,
  PRF_MDIU,
  PRF_PCDP,
  PRF_RR,
  PRF_TRS,
  PRF_DCS_RR,
  PRF_TRS_ATM
};
typedef struct
{
  enum ProType_t Direction;
  enum PeripheralType_t Peripheral;
  HalInputFunction_t *Input;
  HalOutputFunction_t *Output;
  int32_t Value; // Used only by the MEM driver.
} ProCategory_t;
ProCategory_t ProCategories[64] =
  {
    { PRO_INPUT, PRF_DCS_RR }, // YX = 00
        { PRO_OUTPUT, PRF_DCS_RR }, // YX = 01
        { PRO_OUTPUT, PRF_FDI }, // YX = 02
        { PRO_OUTPUT, PRF_FDI }, // YX = 03
        { PRO_OUTPUT, PRF_FDI }, // YX = 04
        { PRO_OUTPUT, PRF_PCDP }, // YX = 05
        { PRO_ILLEGAL, PRF_ILLEGAL }, // YX = 06
        { PRO_OUTPUT, PRF_FDI }, // YX = 07
        { PRO_OUTPUT, PRF_IS }, // YX = 10
        { PRO_OUTPUT, PRF_IVI }, // YX = 11
        { PRO_OUTPUT, PRF_IVI }, // YX = 12
        { PRO_OUTPUT, PRF_IVI }, // YX = 13
        { PRO_OUTPUT, PRF_TRS_ATM }, // YX = 14
        { PRO_REENT_ATM, PRF_TBD }, // YX = 15
        { PRO_ILLEGAL, PRF_ILLEGAL }, // YX = 16
        { PRO_OUTPUT, PRF_FDI }, // YX = 17
        { PRO_TRS_PULSES, PRF_TRS }, // YX = 20
        { PRO_OUTPUT, PRF_TRS }, // YX = 21
        { PRO_OUTPUT, PRF_AGE }, // YX = 22
        { PRO_OUTPUT, PRF_AGE }, // YX = 23
        { PRO_ILLEGAL, PRF_ILLEGAL }, // YX = 24
        { PRO_OUTPUT, PRF_TRS_ATM }, // YX = 25
        { PRO_ILLEGAL, PRF_ILLEGAL }, // YX = 26
        { PRO_OUTPUT, PRF_FDI }, // YX = 27
        { PRO_OUTPUT, PRF_MDIU }, // YX = 30
        { PRO_OUTPUT, PRF_MDIU }, // YX = 31
        { PRO_OUTPUT, PRF_MDIU }, // YX = 32
        { PRO_OUTPUT, PRF_MDIU }, // YX = 33
        { PRO_OUTPUT, PRF_PCDP }, // YX = 34
        { PRO_OUTPUT, PRF_IVI }, // YX = 35
        { PRO_INPUT, PRF_IMU }, // YX = 36
        { PRO_ILLEGAL, PRF_ILLEGAL }, // YX = 37
        { PRO_OUTPUT, PRF_MDIU }, // YX = 40
        { PRO_OUTPUT, PRF_MDIU }, // YX = 41
        { PRO_ILLEGAL, PRF_ILLEGAL }, // YX = 42
        { PRO_INPUT, PRF_MDIU }, // YX = 43
        { PRO_OUTPUT, PRF_ATM }, // YX = 44
        { PRO_INPUT, PRF_IMU }, // YX = 45
        { PRO_INPUT, PRF_IMU }, // YX = 46
        { PRO_ILLEGAL, PRF_ILLEGAL }, // YX = 47
        { PRO_OUTPUT, PRF_MDIU }, // YX = 50
        { PRO_OUTPUT, PRF_MDIU }, // YX = 51
        { PRO_OUTPUT, PRF_MDIU }, // YX = 52
        { PRO_ILLEGAL, PRF_ILLEGAL }, // YX = 53
        { PRO_ILLEGAL, PRF_ILLEGAL }, // YX = 54
        { PRO_TBD, PRO_TBD }, // YX = 55
        { PRO_INPUT, PRF_IMU }, // YX = 56
        { PRO_ILLEGAL, PRF_ILLEGAL }, // YX = 57
        { PRO_OUTPUT, PRF_MDIU }, // YX = 60
        { PRO_TBD, PRF_TBD }, // YX = 61
        { PRO_INPUT, PRF_PCDP }, // YX = 62
        { PRO_OUTPUT, PRF_RR }, // YX = 63
        { PRO_TBD, PRF_TBD }, // YX = 64
        { PRO_OUTPUT, PRF_TRS }, // YX = 65
        { PRO_ILLEGAL, PRF_ILLEGAL }, // YX = 66
        { PRO_ILLEGAL, PRF_ILLEGAL }, // YX = 67
        { PRO_ILLEGAL, PRF_ILLEGAL }, // YX = 70
        { PRO_ILLEGAL, PRF_ILLEGAL }, // YX = 71
        { PRO_ILLEGAL, PRF_ILLEGAL }, // YX = 72
        { PRO_ILLEGAL, PRF_ILLEGAL }, // YX = 73
        { PRO_ILLEGAL, PRF_ILLEGAL }, // YX = 74
        { PRO_ILLEGAL, PRF_ILLEGAL }, // YX = 75
        { PRO_ILLEGAL, PRF_ILLEGAL }, // YX = 76
        { PRO_ILLEGAL, PRF_ILLEGAL } // YX = 77
  };
typedef struct
{
  enum PeripheralType_t Peripheral;
  HalInputFunction_t *Input;
  HalOutputFunction_t *Output;
  int32_t Value; // Used only by the MEM driver.
} CldCategory_t;
CldCategory_t CldCategories[64] =
  {
    { PRF_RR }, // YX = 00
        { PRF_MDIU }, // YX = 01
        { PRF_MDIU }, // YX = 02
        { PRF_MDIU }, // YX = 03
        { PRF_MDIU }, // YX = 04
        { PRF_TRS }, // YX = 05
        { PRF_ILLEGAL }, // YX = 06
        { PRF_ILLEGAL }, // YX = 07
        { PRF_PCDP }, // YX = 10
        { PRF_PCDP }, // YX = 11
        { PRF_IS }, // YX = 12
        { PRF_PCDP }, // YX = 13
        { PRF_ATM }, // YX = 14
        { PRF_ATM }, // YX = 15
        { PRF_PCDP }, // YX = 16
        { PRF_PCDP }, // YX = 17
        { PRF_ILLEGAL }, // YX = 20
        { PRF_PCDP }, // YX = 21
        { PRF_IVI }, // YX = 22
        { PRF_ILLEGAL }, // YX = 23
        { PRF_TBD }, // YX = 24
        { PRF_IVI }, // YX = 25
        { PRF_IVI }, // YX = 26
        { PRF_AGE }, // YX = 27
        { PRF_TBD }, // YX = 30
        { PRF_IVI }, // YX = 31
        { PRF_AGE }, // YX = 32
        { PRF_ATM }, // YX = 33
        { PRF_ATM }, // YX = 34
        { PRF_ATM }, // YX = 35
        { PRF_TBD }, // YX = 36
        { PRF_ILLEGAL }, // YX = 37
        { PRF_ILLEGAL }, // YX = 40
        { PRF_ATM }, // YX = 41
        { PRF_TBD }, // YX = 42
        { PRF_ATM }, // YX = 43
        { PRF_ATM }, // YX = 44
        { PRF_ILLEGAL }, // YX = 45
        { PRF_ILLEGAL }, // YX = 46
        { PRF_ILLEGAL }, // YX = 47
        { PRF_ILLEGAL }, // YX = 50
        { PRF_ILLEGAL }, // YX = 51
        { PRF_ILLEGAL }, // YX = 52
        { PRF_ILLEGAL }, // YX = 53
        { PRF_ILLEGAL }, // YX = 54
        { PRF_ILLEGAL }, // YX = 55
        { PRF_ILLEGAL }, // YX = 56
        { PRF_ILLEGAL }, // YX = 57
        { PRF_ILLEGAL }, // YX = 60
        { PRF_ILLEGAL }, // YX = 61
        { PRF_ILLEGAL }, // YX = 62
        { PRF_ILLEGAL }, // YX = 63
        { PRF_ILLEGAL }, // YX = 64
        { PRF_ILLEGAL }, // YX = 65
        { PRF_ILLEGAL }, // YX = 66
        { PRF_ILLEGAL }, // YX = 67
        { PRF_ILLEGAL }, // YX = 70
        { PRF_ILLEGAL }, // YX = 71
        { PRF_ILLEGAL }, // YX = 72
        { PRF_ILLEGAL }, // YX = 73
        { PRF_ILLEGAL }, // YX = 74
        { PRF_ILLEGAL }, // YX = 75
        { PRF_ILLEGAL }, // YX = 76
        { PRF_ILLEGAL } // YX = 77
  };

//==========================================================================

int
main(int argc, char *argv[])
{
  int i, RetVal = 1, WasRunning = 0;

#ifdef PTW32_STATIC_LIB
  // You wouldn't need this if I had compiled pthreads_w32 as a DLL.
  pthread_win32_process_attach_np();
#endif

  printf("yaOBC emulator for Gemini OBC and Apollo LVDC computers.\n");
  printf("Built " __DATE__ ", " __TIME__ "\n");

  // Various setups.
  for (i = 0; i < 64; i++)
    {
      ProCategories[i].Input = ProInputFunctionSock;
      CldCategories[i].Input = CldInputFunctionSock;
      ProCategories[i].Output = ProOutputFunctionSock;
      CldCategories[i].Output = CldOutputFunctionSock;
    }
  if (ParseCommandLine(argc, argv))
    goto Done; // Error!
  if (ReadBinaryFile())
    goto Done; // Error!
  if (SymbolFile != NULL && ReadSymbolFile())
    goto Done; // Error!
  if (0 != (i = ReadIoFile()))
    {
      if (i != 1)
        {
          printf("Read-error on file %s.\n", IoFile);
          goto Done;
          // Error!
        }
      printf("Warning: Could not read %s, zeroing PRO/CLD MEM driver.\n",
          IoFile);
      for (i = 0; i < MAX_YX; i++)
        {
          ProCategories[i].Value = 0;
          CldCategories[i].Value = 0;
        }
    }
  SetCyclesPerTick(1.0); // Emulation speedup vs. real-time is 1X.
  CurrentStartTicks = times(&TmsStruct);
  DisplayCurrentDebuggingLocation();
  if (0 != (i = pthread_create(&DebuggerThread, NULL, DebuggerThreadFunction,
      NULL)))
    {
      printf("Could not create debugger thread (error %d).\n", i);
      goto Done;
    }
  if (HalSockInitialize())
    {
      printf("Could not start the socket system.\n");
      goto Done;
    }

  // Emulate.
  while (1)
    {
      // Set NeedDebuggerPrompt non-zero whenever we detect a condition
      // by which the emulator (rather than the debugger) halts program
      // execution.  The debugger itself will be stuck waiting for
      // user input, and won't know to print a new prompt.
      long CyclesNeeded = 0;

      if (WasRunning && Run == 0)
        {
          char Input[41] = "R 0.0";
          HalSockBroadcastString(Input, strlen(Input));
          sprintf(Input, "S %lu", TotalCycles);
          HalSockBroadcastString(Input, strlen(Input));
        }
      WasRunning = Run;

      // Take care of any queued PRO/CLD related events from peripheral
      // emulations.  If any queued incoming events are ready to fire,
      // timewise, we write their values to the PRO/CLD memory arrays
      // and remove the events from the queue.  The removal is an inefficient
      // operation that could doubtless be made much better by some
      // mechanism such as trees in place of the qsort/memmove I'm actually
      // using right now.
      if (NumHalSockEvents > 0 && HalSockEvents[0].Count <= TotalCycles)
        {
          pthread_mutex_lock(&HalSockMutex);
          for (i = 0; i < NumHalSockEvents && HalSockEvents[i].Count
              <= TotalCycles; i++)
            {
              if (HalSockEvents[i].Type == 0)
                ProCategories[HalSockEvents[i].yx].Value
                    = HalSockEvents[i].Data;
              else
                CldCategories[HalSockEvents[i].yx].Value
                    = HalSockEvents[i].Data ? BITS26 : 0;
            }
          if (i < NumHalSockEvents)
            memmove(&HalSockEvents[0], &HalSockEvents[i],
                (NumHalSockEvents - i) * sizeof(HalSockEvent_t));
          NumHalSockEvents -= i;
          pthread_mutex_unlock(&HalSockMutex);
        }

      CurrentTicks = times(&TmsStruct); // Get current real time in ticks.

      // Figure out how many machine cycles we want to run.  There
      // are two cases:  Either we're free-running (Run!=0), in which
      // case we want just as many cycles as will catch up to real time,
      // or else we're not free-running (Run==0).  In the latter case,
      // It's still possible that the debugging interface may have
      // commanded that we execute a certain number of cycles.
      pthread_mutex_lock(&DebuggerMutex);
      if (EmulatorEndOfSector)
        {
          printf(
              "\nProgram execution reached end of sector, emulation paused.\n");
          EmulatorEndOfSector = 0;
          Run = 0;
          NeedDebuggerPrompt = 1;
        }
      if (EmulatorTimeout)
        {
          printf("\nPRO or CLD instruction timed out.\n");
          EmulatorTimeout = 0;
          Run = 0;
          NeedDebuggerPrompt = 1;
        }
      if (EmulatorBreakpoint)
        {
          printf("\nBreakpoint on code reached.\n");
          EmulatorBreakpoint = 0;
          Run = 0;
          NeedDebuggerPrompt = 1;
        }
      if (EmulatorWatchpoint)
        {
          printf("\nBreakpoint on data reached.\n");
          EmulatorWatchpoint = 0;
          Run = 0;
          NeedDebuggerPrompt = 1;
        }
      if (EmulatorUnimplementedYX)
        {
          printf("\nPRO/CLD/SHF instruction used unimplemented YX.\n");
          EmulatorUnimplementedYX = 0;
          Run = 0;
          NeedDebuggerPrompt = 1;
        }
      if (DebuggerQuit)
        break;
      if (DebuggerPause || EmulatorPause)
        {
          Run = 0;
          DebuggerPause = 0;
          EmulatorPause = 0;
          NeedDebuggerPrompt = 1;
        }
      if (DebuggerRun)
        {
          char Input[41];
          sprintf(Input, "R %lf", Speedup);
          HalSockBroadcastString(Input, strlen(Input));
          CurrentStartCycles = CurrentCycles = 0;
          CurrentStartTicks = CurrentTicks;
          Run = 1;
          DebuggerRun = 0;
          NeedDebuggerPrompt = 1;
        }
      if (StepN)
        {
          CyclesNeeded = StepN;
          StepN = 0;
          NeedDebuggerPrompt = 0;
        }
      else if (Run)
        CyclesNeeded = ComputeNeededCycles();
      if ((!Run && !CyclesNeeded) || NeedDebuggerPrompt)
        {
          DisplayCurrentDebuggingLocation();
          NeedDebuggerPrompt = 0;
        }
      pthread_mutex_unlock(&DebuggerMutex);

      // Emulate like the wind!
      for (; CyclesNeeded && !DebuggerPause && !EmulatorPause
          && !EmulatorEndOfSector && !EmulatorBreakpoint && !EmulatorWatchpoint; CyclesNeeded--)
        RunOneMachineCycle();

      // Sleep for a little to avoid hogging 100% CPU time.  The amount
      // we choose doesn't really matter.
      SleepMilliseconds(10);
    }

  RetVal = 0;
  Done: ;

#ifdef PTW32_STATIC_LIB
  // You wouldn't need this if I had compiled pthreads_w32 as a DLL.
  pthread_win32_process_detach_np();
#endif

  return (RetVal);
}

//==========================================================================

// Parse the command line into the corresponding global variables, returning
// 0 on success or non-zero on failure.
int
ParseCommandLine(int argc, char *argv[])
{
  int i, j, RetVal = 1;

  // Parse the command-line arguments.
  for (i = 1; i < argc; i++)
    {
      if (!strcmp(argv[i], "--help"))
        {
          Help: ;
          printf("USAGE:\n"
            "\tyaOBC [OPTIONS]\n"
            "The allowed OPTIONS are:\n"
            "--help        Display this usage info and then exit.\n"
            "--lvdc        Emulate Apollo LVDC. (Default is Gemini OBC.)\n"
            "--binary=F    Specifies name of file containing memory/ATM\n"
            "              contents and HOP constant. Defaults to\n"
            "              yaOBC.bin, which is normally produced by\n"
            "              yaOBC itself, but can be a binary file made\n"
            "              by yaASM also.\n"
            "--symbols=F   Specifies the name of the listing file\n"
            "              created by yaASM. Used to get the symbol\n"
            "              table and source code for symbolic debugging.\n"
            "              If absent, debugging will be non-symbolic.\n"
            "--run         Start the emulator in a mode in which it is\n"
            "              running the selected OBC/LVDC binary in real\n"
            "              time.  The default is to start in paused mode,\n"
            "              immediately prior to running the first \n"
            "              instruction.\n"
            "--port=P      Specifies the TCP/IP port on which to listen\n"
            "              for connections to peripheral-emulating programs\n"
            "              like yaPanel.  Defaults to 19653.\n"
            "-v            Increase verbosity level of messages.\n"
            "--method=P,T  This switch relates to the method by which\n"
            "              emulated or physical peripheral devices\n"
            "              connect to the emulated CPU. In essence, it\n"
            "              allows different types of device drivers to\n"
            "              be used for different YX ranges for the PRO\n"
            "              and CLD instructions of the CPU.  The P field\n"
            "              selects the YX range by the designator of a\n"
            "              specific peripheral device.  The choices for P\n"
            "              are ALL (meaning, all peripherals), DCS,\n"
            "              RR, TRS, MDIU, IVI, IMU, FDI, ACME, AGE,\n"
            "              IS, ATM, PCDP.  The T field specifies the\n"
            "              the data-transport method for the YX ranges\n"
            "              associated with peripheral P, and the choices\n"
            "              for it are: MEM, SOCK (the default), COM1,\n"
            "              COM2, ..., CUSTOM.  The MEM choice would typically\n"
            "              be used when merely debugging the OBC software\n"
            "              without peripherals.  The SOCK choice would \n"
            "              be used for emulated peripherals provided directly\n"
            "              by the Virtual AGC project.  The COMn choice\n"
            "              could be used for building a physical peripheral\n"
            "              like an MDIU or IVI.  CUSTOM would relate to\n"
            "              a compiled-in driver of a presently unknown type,\n"
            "              such as a driver for the Orbiter spacecraft-\n"
            "              simulation system.\n"
            "--io=F        Specifies a file containing initial PRO/CLD\n"
            "              values for the MEM/SOCK driver of the --method\n"
            "              switch. The default is --io=yaOBC.io, or simply\n"
            "              all zeroes if that file does not exist.\n"
            "--com1=P      Used only with --method type RS232.  P is the\n"
            "--com2=P      name of the desired comport, such as COM1 or\n"
            "etc.          /dev/ttyS0.\n");
          goto Done;
        }
      else if (!strcmp(argv[i], "-v"))
        Verbosity++;
      else if (!strcmp(argv[i], "--lvdc"))
        Lvdc = 1;
      else if (!strcmp(argv[i], "--run"))
        Run = 1;
      else if (1 == sscanf(argv[i], "--port=%d", &j))
        {
          Port = j;
          if (Port < 0 || Port > 0xFFFF)
            {
              printf("Illegal TCP/IP port.\n");
              goto Done;
            }
        }
      else if (!strncmp(argv[i], "--binary=", 9))
        BinaryFile = &argv[i][9];
      else if (!strncmp(argv[i], "--symbols=", 10))
        SymbolFile = &argv[i][10];
      else if (!strncmp(argv[i], "--method=", 9))
        {
          printf(
              "Sorry, --method is not yet implemented. MEM method always used.\n");
          goto Done;
        }
      else if (!strncmp(argv[i], "--com", 5))
        {
          printf("Sorry, --comN is not yet implemented.\n");
          goto Done;
        }
      else
        {
          printf("Unrecognised switch: %s\n", argv[i]);
          goto Help;
        }
    }

  // And print out info about the settings.
  if (Verbosity)
    {
      printf("Emulation: %s\n", Lvdc ? "Apollo LVDC" : "Gemini OBC");
      if (Run)
        printf("State: running in real time.\n");
      else
        printf("State: paused prior to first instruction.\n");
      printf("Binary file: %s\n", BinaryFile);
      if (SymbolFile == NULL)
        printf("No symbol table.\n");
      else
        printf("Symbol-table file: %s\n", SymbolFile);
      printf("TCP/IP port: %d\n", Port);
      printf("\n");
    }

  RetVal = 0;
  Done: ;
  return (RetVal);
}

//==========================================================================

// Read the OBC/LVDC executable binary specified by the global command-line
// variables into RAM, returning 0 on success or non-zero on failure.
int
ReadBinaryFile(void)
{
  int RetVal = 1;
  FILE *fp = NULL;
  uint32_t RawHopRegister;

  if (Verbosity)
    printf("Reading binary file \"%s\" ...\n", BinaryFile);

  fp = fopen(BinaryFile, "rb");
  if (fp == NULL)
    {
      printf("Selected binary file \"%s\" not found.\n", BinaryFile);
      goto Done;
    }

  if (1 != fread(&Binary, sizeof(Binary), 1, fp) || 1 != fread(&RawHopRegister,
      sizeof(RawHopRegister), 1, fp) || 1 != fread(&Accumulator,
      sizeof(Accumulator), 1, fp) || 1 != fread(&PqRegister,
      sizeof(PqRegister), 1, fp))
    {
      printf("Unexpected end of binary file.\n");
      goto Done;
    }
  if (Lvdc)
    {
      printf("Sorry, LVDC not fully implemented yet.\n");
      goto Done;
    }
  else
    BuildAddressFromObcHopRegister(RawHopRegister, &HopRegister);

  if (Verbosity)
    {
      printf("Finished reading binary file.\n");
      printf("Program entry point: ");
      PrintAddress(&HopRegister);
      printf("\n");
    }

  RetVal = 0;
  Done: ;
  if (fp != NULL)
    fclose(fp);
  return (RetVal);
}

//==========================================================================

// Write a OBC/LVDC executable binary representing the current OBC/LVDC
// state, returning 0 on success or non-zero on failure.
int
WriteBinaryFile(char *BinaryFile)
{
  int RetVal = 1;
  FILE *fp = NULL;
  uint32_t RawHopRegister;

  if (Verbosity)
    printf("Writing snapshot file \"%s\" ...\n", BinaryFile);

  fp = fopen(BinaryFile, "wb");
  if (fp == NULL)
    {
      printf("Cannot create snapshot file \"%s\".\n", BinaryFile);
      goto Done;
    }

  if (Lvdc)
    {
      printf("Sorry, LVDC not fully implemented yet.\n");
      goto Done;
    }
  else
    BuildObcHopRegisterFromAddress(&HopRegister, &RawHopRegister);

  if (1 != fwrite(&Binary, sizeof(Binary), 1, fp) || 1 != fwrite(
      &RawHopRegister, sizeof(RawHopRegister), 1, fp) || 1 != fwrite(
      &Accumulator, sizeof(Accumulator), 1, fp) || 1 != fwrite(&PqRegister,
      sizeof(PqRegister), 1, fp))
    {
      printf("Write-error on snapshot.\n");
      goto Done;
    }

  if (Verbosity)
    printf("Finished writing snapshot file.\n");

  RetVal = 0;
  Done: ;
  if (fp != NULL)
    fclose(fp);
  return (RetVal);
}

//==========================================================================

// Read the OBC/LVDC assembly-listing specified by the global command-line
// variables into RAM, returning 0 on success or non-zero on failure.
// The listing contains two things of interest to us:
//   1. The source code.  Every line of source code that's of consequence
//      to use has two things of interest: The address, which is the very
//      first thing on the line, and the source, which is everything after
//      the first tab-character to the end of the line.
//   2. The symbol table.
// We read these items of interest into memory structures for future
// reference, and discard the rest.
int
ReadSymbolFile(void)
{
  int i, j, RetVal = 1, m, p, s, w, v;
  char c, *Tab, *Colon;
  FILE *fp;

  fp = fopen(SymbolFile, "r");
  if (fp == NULL)
    {
      printf("Selected listing file \"%s\" not found.\n", SymbolFile);
      goto Done;
    }

  if (Verbosity)
    printf("Reading source code from listing-file \"%s\" ...\n", SymbolFile);

  // Read in the file up to the symbol table.
  while (NULL != fgets(LineBuffer, sizeof(LineBuffer), fp))
    {
      int LineFields;
      // End of code and start of symbol table?
      if (!strncmp("SYMBOL TABLE", LineBuffer, 12))
        break;
      // A line of code is useful to us only if it starts with an
      // address and has a tab character in it..
      if (!isspace(LineBuffer[0]) && 5 <= (LineFields = sscanf(LineBuffer,
          "%o-%o-%o-%o%c%o", &m, &p, &s, &w, &c, &v)) && c == ' ' && m >= 0
          && m < MAX_MODULES && p >= 0 && p < MAX_SECTORS && s >= 0 && s
          < MAX_SYLLABLES && w >= 0 && w < MAX_WORDS && NULL != (Tab = strstr(
          LineBuffer, "\t")))
        {
          // Enough space to store in the source-code table?
          if (NumSourceLines >= MaxSourceLines)
            {
              if (MaxSourceLines == 0)
                MaxSourceLines = 100000;
              else
                MaxSourceLines += 5000;
              SourceLines = realloc(SourceLines, MaxSourceLines
                  * sizeof(SourceLine_t));
              if (SourceLines == NULL)
                {
                  printf("Out of memory for the symbol table.\n");
                  goto Done;
                }
            }
          Tab[strcspn(Tab, "\r\n")] = 0; // Trim trailing EOL chars.
          strcpy(SourceLines[NumSourceLines].SourceText, Tab + 1);
          // We don't actually care about the assembler's idea
          // of half-word mode any longer.
          SourceLines[NumSourceLines].Address.HalfWordMode = 0;
          SourceLines[NumSourceLines].Address.Module = m;
          SourceLines[NumSourceLines].Address.Page = p;
          SourceLines[NumSourceLines].Address.Syllable = s;
          SourceLines[NumSourceLines].Address.Word = w;
          if (LineFields > 5)
            SourceLines[NumSourceLines].Value = v;
          else
            SourceLines[NumSourceLines].Value = ILLEGAL_VALUE;
          NumSourceLines++;
        }
    }
  // Sort by address, so we can find them again later easily.
  qsort(SourceLines, NumSourceLines, sizeof(SourceLine_t),
      CompareSourceByAddresses);
  if (Verbosity)
    printf("%d lines of source code found.\n", NumSourceLines);

  if (Verbosity)
    printf("Reading symbols from listing-file \"%s\" ...\n", SymbolFile);

  // Read in the symbol table.
  while (NULL != fgets(LineBuffer, sizeof(LineBuffer), fp))
    {
      char SymbolName[9], RefName[9], PseudoName[9];
      // End of symbol table and start of octal listing?
      if (!strncmp("OCTAL LISTING", LineBuffer, 13))
        break;
      // It's a symbol definition only if it starts with an
      // address and contains a colon.
      if (NULL == (Colon = strstr(LineBuffer, ":")) || Colon != &LineBuffer[20])
        continue;
      *Colon = 0;
      if (!isspace(LineBuffer[0]) && 5 == sscanf(LineBuffer, "%o-%o-%o-%o,%s",
          &m, &p, &s, &w, SymbolName) && m >= 0 && m < MAX_MODULES && p >= 0
          && p < MAX_SECTORS && s >= 0 && s < MAX_SYLLABLES && w >= 0 && w
          < MAX_WORDS)
        {
          int IsRef = 0;
          // Enough space to store in the source-code table?
          if (NumSymbols >= MAXSYMBOLS)
            {
              printf("Too many symbols.\n");
              goto Done;
            }
          // Set up the address, symbol name, and default value.
          Symbols[NumSymbols].Address.HalfWordMode = 0;
          Symbols[NumSymbols].Address.Module = m;
          Symbols[NumSymbols].Address.Page = p;
          Symbols[NumSymbols].Address.Syllable = s;
          Symbols[NumSymbols].Address.Word = w;
          strcpy(Symbols[NumSymbols].Name, SymbolName);
          Symbols[NumSymbols].Line = 0;
          Symbols[NumSymbols].RefName[0] = 0;
          Symbols[NumSymbols].RefType = ST_NONE;
          Symbols[NumSymbols].Type = ST_NONE;
          Symbols[NumSymbols].Value = ILLEGAL_VALUE;
          // Now deduce some of the other fields:
          Colon += 2;
          if (3 == sscanf(Colon, "Constant (%o), created via \"%s %[^\"]\"",
              &j, PseudoName, RefName))
            {
              Symbols[NumSymbols].Type = ST_CONSTANT;
              Symbols[NumSymbols].Value = j;
              IsRef = 1;
            }
          else if (1 == sscanf(Colon, "Constant (%o)", &j))
            {
              Symbols[NumSymbols].Type = ST_CONSTANT;
              Symbols[NumSymbols].Value = j;
            }
          else if (2 == sscanf(Colon,
              "Uninitialized variable, created via \"%s %[^\"]\"", PseudoName,
              RefName))
            {
              Symbols[NumSymbols].Type = ST_VARIABLE;
              IsRef = 1;
            }
          else if (!strncmp(Colon, "Uninitialized variable", 22))
            {
              Symbols[NumSymbols].Type = ST_VARIABLE;
            }
          else if (2 == sscanf(Colon,
              "Left-hand symbol, created via \"%s %[^\"]\"", PseudoName,
              RefName))
            {
              Symbols[NumSymbols].Type = ST_CODE;
              IsRef = 1;
            }
          else if (!strncmp(Colon, "Left-hand symbol", 16))
            {
              Symbols[NumSymbols].Type = ST_CODE;
            }
          if (IsRef)
            {
              strcpy(Symbols[NumSymbols].RefName, RefName);
              if (!strcmp(PseudoName, "HOPC"))
                Symbols[NumSymbols].RefType = ST_HOPC;
              else if (!strcmp(PseudoName, "SYN"))
                Symbols[NumSymbols].RefType = ST_SYN;
              else if (!strcmp(PseudoName, "EQU"))
                Symbols[NumSymbols].RefType = ST_EQU;
            }
          // Next, please!
          NumSymbols++;
        }
    }
  qsort(Symbols, NumSymbols, sizeof(Symbol_t), CompareSymbols);
  if (Verbosity)
    printf("%d symbols found.\n", NumSymbols);

  if (Verbosity > 5)
    {
      printf("\n");
      printf("Source code\n");
      printf("-----------\n");
      for (i = 0; i < NumSourceLines; i++)
        {
          PrintAddress(&SourceLines[i].Address);
          printf("\t%s\n", SourceLines[i].SourceText);
        }
      printf("\n");
      printf("Symbol table\n");
      printf("------------\n");
      for (i = 0; i < NumSymbols; i++)
        {
          PrintAddress(&Symbols[i].Address);
          printf(", %-8s: ", Symbols[i].Name);
          switch (Symbols[i].Type)
            {
          case ST_CODE:
            printf("Left-hand symbol");
            break;
          case ST_VARIABLE:
            printf("Uninitialized variable");
            break;
          case ST_CONSTANT:
            printf("Constant (%09o)", Symbols[i].Value);
            break;
          default:
            printf("Implementation error");
            break;
            }
          switch (Symbols[i].RefType)
            {
          case ST_NONE:
            break;
          case ST_HOPC:
            printf(", created via \"HOPC %s\"", Symbols[i].RefName);
            break;
          case ST_SYN:
            printf(", created via \"SYN %s\"", Symbols[i].RefName);
            break;
          case ST_EQU:
            printf(", created via \"EQU %s\"", Symbols[i].RefName);
            break;
          default:
            printf(", implementation error");
            break;
            }
          printf("\n");
        }
    }
  if (Verbosity)
    printf("\n");

  fclose(fp);

  RetVal = 0;
  Done: ;
  return (RetVal);
}

//==========================================================================

void
PrintAddress(Address_t *Address)
{
  printf("%o-%02o-%o-%03o", Address->Module, Address->Page, Address->Syllable,
      Address->Word);
}

//==========================================================================

// Used for computing the global variable CyclesPerTick when the desired
// execution rate of the simulated program with respect to real time
// changes.  Speedup is 1.0 for real-time, 0.5 for half-speed, 2.0
// for double-speed, and so on.
void
SetCyclesPerTick(double NewSpeedup)
{
  if (NewSpeedup != Speedup)
    {
      Speedup = NewSpeedup;
      CyclesPerTick = Speedup / sysconf(_SC_CLK_TCK) / SECONDS_PER_CYCLE;
      CurrentStartTicks = CurrentTicks;
      CurrentStartCycles = CurrentCycles;
    }
}

//==========================================================================

long
ComputeNeededCycles(void)
{
  return (lround(CyclesPerTick * (CurrentTicks - CurrentStartTicks)
      - CurrentCycles));
}

//==========================================================================

// Display register values, source code, etc., at the current debugging
// point, along with a debugger prompt.
void
DisplayCurrentDebuggingLocation(void)
{
  uint32_t RawHopRegister;
  int SourceLineFound = 0, Value = ILLEGAL_VALUE;
  Address_t Address;

  if (Run || !memcmp(&HopRegister, &LastDebuggedHopRegister, sizeof(Address_t)))
    return;
  memcpy(&LastDebuggedHopRegister, &HopRegister, sizeof(Address_t));

  // Display registers.
  if (Lvdc)
    Value = ILLEGAL_VALUE;
  else
    Value = Binary[0][(HopRegister.Word & 0400) ? RESIDUAL_SECTOR
        : HopRegister.Page][HopRegister.Syllable][HopRegister.Word & 0377];
  BuildObcHopRegisterFromAddress(&HopRegister, &RawHopRegister);
  printf("\n");
  printf("HOP=%09o (", RawHopRegister);
  if (Lvdc)
    {
      printf("????");
    }
  else
    {
      printf("ADR=");
      PrintAddress(&HopRegister);
      printf(" HWM=%d VAL=%05o", HopRegister.HalfWordMode, Value & BITS13);
    }
  printf(")\n");
  printf("ACC=%09o PQ=%09o (TMR:%d)\n", Accumulator & BITS26, (PqRegister
      & BITS26), ((PqRegister >> 28) & 0x07));

  // Display timing info.
  printf("Cycles=%ld (%.5lf seconds)\n", TotalCycles, TotalCycles
      * SECONDS_PER_CYCLE);

  // Display source line ... from the assembler's listing file if we
  // can, disassembled if not.
  memcpy(&Address, &HopRegister, sizeof(Address_t));
  if (SourceLines != NULL)
    {
      SourceLine_t Key, *Result = NULL;
      // Search the list of source lines for our current address according
      // to the HOP register.  For OBC this is a little tricky, because
      // we can't know what program modules are loaded, so we search through
      // all program modules looking for one with the same memory contents
      // that we actually have.  Another thing that makes it tricky is SYN,
      // since that may give different source lines for the same address,
      // but without the proper Value field.
      if (Lvdc)
        {

        }
      else
        {
          int i;
          memcpy(&Key.Address, &HopRegister, sizeof(Address_t));
          if (Key.Address.Word & 0400)
            {
              Key.Address.Page = RESIDUAL_SECTOR;
              Key.Address.Word &= 0377;
            }
          for (i = 0; i < MAX_MODULES; i++)
            {
              Key.Address.Module = i;
              Result = bsearch(&Key, SourceLines, NumSourceLines,
                  sizeof(SourceLine_t), CompareSourceByAddresses);
              if (Result == NULL)
                continue;
              // If there are multiple lines associated with the same
              // address, this might not be the first one.  Need to
              // search backward linearly to be sure.
              for (; Result > SourceLines && !CompareSourceByAddresses(&Key,
                  Result - 1); Result--)
                ;
              // Now iterate to try to fine a match with respect
              // to the contents of the memory location.
              Retry: ;
              if (Result->Value == (Value & BITS13))
                {
                  SourceLineFound = 1;
                  break;
                }
              else
                {
                  Result++;
                  if (Result < &SourceLines[NumSourceLines]
                      && !CompareSourceByAddresses(&Key, Result))
                    goto Retry;
                }
            }
        }
      if (SourceLineFound)
        {
          Address.Module = Key.Address.Module;
          PrintAddress(&Address);
          printf("\t");
          printf("%s\n", Result->SourceText);
        }
    }
  if (!SourceLineFound)
    {
      PrintAddress(&Address);
      printf("\t");
      if (Value == ILLEGAL_VALUE)
        printf("\t (Uninitialized memory)\n");
      else if (Lvdc)
        {

        }
      else
        printf("\t %s  %03o\n", ObcOps[(Value >> 9) & 0x0F], Value & 0777);
    }

  DisplayDebuggerPrompt();

}

//==========================================================================

void
BuildAddressFromObcHopRegister(uint32_t RawHopRegister, Address_t *HopRegister)
{
  HopRegister->Module = 0;
  HopRegister->Word = RawHopRegister & 0777;
  HopRegister->Page = (RawHopRegister >> 9) & 017;
  HopRegister->Syllable = (RawHopRegister >> 14) & 03;
  HopRegister->HalfWordMode = (RawHopRegister >> 17) & 01;
}

//==========================================================================

void
BuildObcHopRegisterFromAddress(Address_t *HopRegister, uint32_t *RawHopRegister)
{
  (*RawHopRegister) = 0;
  (*RawHopRegister) |= (HopRegister->Word & 0777);
  (*RawHopRegister) |= (HopRegister->Page & 017) << 9;
  (*RawHopRegister) |= (HopRegister->Syllable & 03) << 14;
  (*RawHopRegister) |= (HopRegister->HalfWordMode & 01) << 17;
}

//==========================================================================

void
DisplayDebuggerPrompt(void)
{
  printf("%s debugger %s> ", Lvdc ? "LVDC" : "OBC",
      (Run || DebuggerRun) ? "(running)" : "(paused)");
  fflush(stdout);
}

//==========================================================================

// Compare two SourceLine_t by address, for use with qsort() or bsearch().
int
CompareSourceByAddresses(const void *s1, const void *s2)
{
#define Sym1 ((SourceLine_t *) s1)
#define Sym2 ((SourceLine_t *) s2)
  int i;
  i = Sym1->Address.Module - Sym2->Address.Module;
  if (i)
    return (i);
  i = Sym1->Address.Page - Sym2->Address.Page;
  if (i)
    return (i);
  i = Sym1->Address.Syllable - Sym2->Address.Syllable;
  if (i)
    return (i);
  i = Sym1->Address.Word - Sym2->Address.Word;
  return (i);
#undef Sym1
#undef Sym2
}

//==========================================================================

// Compares two Symbol_t structures on the basis of symbol
// name, for use with qsort() or bsearch().
int
CompareSymbols(const void *s1, const void *s2)
{
#define Sym1 ((Symbol_t *) s1)
#define Sym2 ((Symbol_t *) s2)
  return (strcmp(Sym1->Name, Sym2->Name));
#undef Sym1
#undef Sym2
}

//==========================================================================

// Hardware-abstraction: method types for the --method command-line switch.
// All functions return:
//      0 on success
//      1 on errors such as bad YX
//      2 on timeout
// Note that while the CPU doesn't support anything for discrete outputs,
// we nevertheless provide a function for it, for use by the debugger.

// These particular HAL functions are for type=MEM.

int
ProOutputFunctionMem(int yx, int32_t Value)
{
  if (yx < 0 || yx >= MAX_YX)
    return (1);
  ProCategories[yx].Value = Value & BITS26;
  return (0);
}

int
ProInputFunctionMem(int yx, int32_t *Value)
{
  if (yx < 0 || yx >= MAX_YX)
    return (1);
  *Value = (ProCategories[yx].Value & BITS26);
  return (0);
}

int
CldOutputFunctionMem(int yx, int32_t Value)
{
  if (yx < 0 || yx >= MAX_YX)
    return (1);
  CldCategories[yx].Value = (Value != 0);
  return (0);
}

int
CldInputFunctionMem(int yx, int32_t *Value)
{
  if (yx < 0 || yx >= MAX_YX)
    return (1);
  *Value = (CldCategories[yx].Value != 0);
  return (0);
}

//==========================================================================

// Read an io file into ProCategories[] and CldCategories[].  Returns:
//      0 success
//      1 file not found
//      2 error
int
ReadIoFile(void)
{
  int RetVal = 2, i, j, k;
  FILE *fp = NULL;

  fp = fopen(IoFile, "r");
  if (fp == NULL)
    {
      RetVal = 1; // file not found.
      goto Done;
    }

  for (i = 0; i < MAX_YX; i++)
    {
      if (2 != fscanf(fp, "PRO %o %o\n", &k, &j) || k != i)
        goto Done;
      ProCategories[i].Value = j & BITS26;
    }
  for (i = 0; i < MAX_YX; i++)
    {
      if (2 != fscanf(fp, "CLD %o %o\n", &k, &j) || k != i)
        goto Done;
      CldCategories[i].Value = j & BITS26;
    }

  RetVal = 0;
  Done: ;
  if (fp != NULL)
    fclose(fp);
  return (RetVal);
}

//==========================================================================

// Write an io file sourced from ProCategories[] and CldCategories[].  Returns:
//      0 success
//      2 error
int
WriteIoFile(char *IoFile)
{
  int RetVal = 2, i;
  FILE *fp = NULL;

  fp = fopen(IoFile, "w");
  if (fp == NULL)
    goto Done;

  for (i = 0; i < MAX_YX; i++)
    {
      if (fprintf(fp, "PRO %02o %09o\n", i, ProCategories[i].Value & BITS26)
          <= 0)
        goto Done;
    }
  for (i = 0; i < MAX_YX; i++)
    {
      if (fprintf(fp, "CLD %02o %o\n", i, CldCategories[i].Value != 0) <= 0)
        goto Done;
    }

  RetVal = 0;
  Done: ;
  if (fp != NULL)
    fclose(fp);
  return (RetVal);
}

//==========================================================================

// This is really the CPU emulator here.  It executes a single OBC machine
// cycle.
void
RunOneMachineCycle(void)
{
#define DATA_ANY_BREAK() \
  if (!IgnoreBreakpoint && WatchmodeType == WT_ANY) \
    if ((*dMem0 != ILLEGAL_VALUE && (*dMem0 & BREAK13) != 0) || \
        (dMem1 != NULL && *dMem1 != ILLEGAL_VALUE && (*dMem1 & BREAK13) != 0)) \
      { \
        EmulatorWatchpoint = 1; \
        return; \
      }
#define PQ_WRITE_BREAK() \
  if (!IgnoreBreakpoint && (PqRegister & BREAK26) != 0) \
    { \
      EmulatorWatchpoint = 1; \
      return; \
    }
#define PQ_ANY_BREAK() \
  if (!IgnoreBreakpoint && WatchmodeType == WT_ANY && (PqRegister & BREAK26) != 0) \
    { \
      EmulatorWatchpoint = 1; \
      return; \
    }
#define ACC_WRITE_BREAK() \
  if (!IgnoreBreakpoint && (Accumulator & BREAK26) != 0) \
    { \
      EmulatorWatchpoint = 1; \
      return; \
    }
#define ACC_ANY_BREAK() \
  if (!IgnoreBreakpoint && WatchmodeType == WT_ANY && (Accumulator & BREAK26) != 0) \
    { \
      EmulatorWatchpoint = 1; \
      return; \
    }
#define CLD_ANY_BREAK() \
  if (!IgnoreBreakpoint && WatchmodeType == WT_ANY && (CldCategories[yx].Value & BREAK26) != 0) \
    { \
      EmulatorWatchpoint = 1; \
      return; \
    }
#define PRO_ANY_BREAK() \
  if (!IgnoreBreakpoint && WatchmodeType == WT_ANY && (ProCategories[yx].Value & BREAK26) != 0) \
    { \
      EmulatorWatchpoint = 1; \
      return; \
    }
#define PRO_WRITE_BREAK() \
  if (!IgnoreBreakpoint && (ProCategories[yx].Value & BREAK26) != 0) \
    { \
      EmulatorWatchpoint = 1; \
      return; \
    }

  int WasJump = 0, Value, Instruction, hwm = 0, Data, ValueToStore;
  uint16_t *pMem, *dMem0, *dMem1;
  Address_t JumpHOP;

  // Fetch the current value pointed to by the HOP register.
  if (Lvdc)
    Value = ILLEGAL_VALUE;
  else
    {
      hwm = HopRegister.HalfWordMode;
      Value = Binary[0][(HopRegister.Word & 0400) ? RESIDUAL_SECTOR
          : HopRegister.Page][HopRegister.Syllable][HopRegister.Word & 0377];
    }

  // Get the instruction we want to decode.
  if (Value == ILLEGAL_VALUE)
    {
      printf("Trying to execute from ininitialized memory at ");
      PrintAddress(&HopRegister);
      printf("\n");
      EmulatorPause = 1;
      return;
    }
  Instruction = (Value >> 9) & 017;
  if (!IgnoreBreakpoint && 0 != (Value & BREAK13))
    {
      EmulatorBreakpoint = 1;
      return;
    }
  Value &= 0777;
  // pMem points to the operand memory location as if it contains code.
  pMem
      = (Value & 0400) ? (&Binary[0][RESIDUAL_SECTOR][HopRegister.Syllable][Value
          & 0377])
          : (&Binary[0][HopRegister.Page][HopRegister.Syllable][Value & 0377]);
  // dMem0 and dMem1 point to the operand memory location as if it contains data.
  if (hwm)
    {
      dMem0 = (Value & 0400) ? (&Binary[0][RESIDUAL_SECTOR][2][Value & 0377])
          : (&Binary[0][HopRegister.Page][2][Value & 0377]);
      dMem1 = NULL;
      Data = *dMem0 & BITS13;
      if (Data & BIT13)
        Data |= ~BITS13; // Sign extend.
    }
  else
    {
      dMem0 = (Value & 0400) ? (&Binary[0][RESIDUAL_SECTOR][0][Value & 0377])
          : (&Binary[0][HopRegister.Page][0][Value & 0377]);
      dMem1 = (Value & 0400) ? (&Binary[0][RESIDUAL_SECTOR][1][Value & 0377])
          : (&Binary[0][HopRegister.Page][1][Value & 0377]);
      Data = (*dMem0 & BITS13) | ((*dMem1 & BITS13) << 13);
      if (Data & BIT26)
        Data |= ~BITS26; // Sign extend.
    }

  // Decode the instruction.
  switch (Instruction)
    {
  case 00: // HOP
    DATA_ANY_BREAK()
    ;
    WasJump = 1;
    BuildAddressFromObcHopRegister(Data, &JumpHOP);
    break;
  case 01: // DIV
    {
      int Dividend, Divisor, Quotient;
      DATA_ANY_BREAK();
      ACC_ANY_BREAK();
      PQ_WRITE_BREAK();
      Dividend = Accumulator & BITS26;
      Divisor = Data;
      if (Divisor == 0)
        Quotient = 0;
      else
        Quotient = Dividend / Divisor;
      PqRegister = (PqRegister & ~BITS26) | (Quotient & BITS26);
      PqRegister |= 0x50000000;
    }
    break;
  case 02: // PRO
    {
      int ClearAcc, yx;
      int32_t InputValue;
      ClearAcc = Value & 0400;
      yx = Value & 077;
      switch (ProCategories[yx].Direction)
        {
      case PRO_ILLEGAL:
        EmulatorUnimplementedYX = 1;
        break;
      case PRO_TBD:
        EmulatorUnimplementedYX = 1;
        break;
      case PRO_OUTPUT:
        ACC_ANY_BREAK()
        ;
        PRO_WRITE_BREAK()
        ;
        if ((*ProCategories[yx].Output)(yx, Accumulator & BITS26))
          EmulatorTimeout = 1;
        if (ClearAcc)
          Accumulator = (Accumulator & ~BITS26);
        break;
      case PRO_INPUT:
        ACC_WRITE_BREAK()
        ;
        PRO_ANY_BREAK ()
        ;
        if (ClearAcc)
          Accumulator = (Accumulator & ~BITS26);
        if ((*ProCategories[yx].Input)(yx, &InputValue))
          EmulatorTimeout = 1;
        Accumulator |= InputValue;
        break;
      case PRO_TRS_PULSES:
        EmulatorUnimplementedYX = 1;
        break;
      case PRO_REENT_ATM:
        EmulatorUnimplementedYX = 1;
        break;
        }
    }
    break;
  case 03: // RSU
    {
      int Minuend, Subtrahend, Difference;
      DATA_ANY_BREAK();
      ACC_WRITE_BREAK();
      Minuend = Data;
      Subtrahend = Accumulator & BITS26;
      if (Subtrahend & BIT26)
        Subtrahend |= ~BITS26; // Sign extend.
      Difference = Minuend - Subtrahend;
      Accumulator = (Accumulator & ~BITS26) | (Difference & BITS26);
    }
    break;
  case 04: // ADD
    {
      int Addend1, Addend2, Sum;
      DATA_ANY_BREAK();
      ACC_WRITE_BREAK();
      Addend1 = Accumulator & BITS26;
      if (Addend1 & BIT26)
        Addend1 |= ~BITS26; // Sign extend.
      Addend2 = Data;
      Sum = Addend1 + Addend2;
      Accumulator = (Accumulator & ~BITS26) | (Sum & BITS26);
    }
    break;
  case 05: // SUB
    {
      int Minuend, Subtrahend, Difference;
      DATA_ANY_BREAK();
      ACC_WRITE_BREAK();
      Minuend = Accumulator & BITS26;
      if (Minuend & BIT26)
        Minuend |= ~BITS26; // Sign extend.
      Subtrahend = Data;
      Difference = Minuend - Subtrahend;
      Accumulator = (Accumulator & ~BITS26) | (Difference & BITS26);
    }
    break;
  case 06: // CLA
    DATA_ANY_BREAK()
    ;
    ACC_WRITE_BREAK()
    ;
    Accumulator = (Accumulator & ~BITS26) | (Data & BITS26);
    break;
  case 07: // AND
    {
      int Addend1, Addend2, Sum;
      DATA_ANY_BREAK();
      ACC_WRITE_BREAK();
      Addend1 = Accumulator & BITS26;
      Addend2 = Data;
      Sum = Addend1 & Addend2;
      Accumulator = (Accumulator & ~BITS26) | (Sum & BITS26);
    }
    break;
  case 010: // MPY
    {
      int Factor1, Factor2, Product;
      DATA_ANY_BREAK();
      ACC_ANY_BREAK();
      PQ_WRITE_BREAK();
      Factor1 = Accumulator & BITS26;
      Factor2 = Data;
      Product = Factor1 * Factor2;
      PqRegister = (PqRegister & ~BITS26) | (Product & BITS26);
      PqRegister |= 0x30000000;
    }
    break;
  case 011: // TRA
    Jump: ;
    memcpy(&JumpHOP, &HopRegister, sizeof(Address_t));
    if (Value & 0400)
      JumpHOP.Page = RESIDUAL_SECTOR;
    JumpHOP.Word = Value & 0377;
    WasJump = 1;
    break;
  case 012: // SHF
    ACC_WRITE_BREAK()
    ;
    ValueToStore = Accumulator & BITS26;
    // Sign-extend bit 26 to all 32 bits of the variable.
    if (ValueToStore & BIT26)
      ValueToStore |= ~BITS26;
    switch (Value)
      {
    case 021:
      ValueToStore = ValueToStore >> 1;
      break;
    case 020:
      ValueToStore = ValueToStore >> 2;
      break;
    case 030:
    case 031:
    case 032:
    case 033:
    case 034:
    case 035:
    case 036:
    case 037:
      ValueToStore = ValueToStore << 1;
      break;
    case 040:
    case 041:
    case 042:
    case 043:
    case 044:
    case 045:
    case 046:
    case 047:
      ValueToStore = ValueToStore << 2;
      break;
    default:
      // This behavior is actually specified: Illegal YX
      // clears the accumulator.
      ValueToStore = 0;
      break;
      }
    Accumulator = (Accumulator & ~BITS26) | (ValueToStore & BITS26);
    break;
  case 013: // TMI
    ACC_ANY_BREAK()
    ;
    if (Accumulator & BIT26)
      goto Jump;
    break;
  case 014: // STO
    ACC_ANY_BREAK()
    ;
    ValueToStore = Accumulator;
    //printf("D STO %011o\n", ValueToStore);
    Store: ;
    if (!hwm)
      {
        uint16_t Val0, Val1;
        if (*dMem0 == ILLEGAL_VALUE)
          *dMem0 = 0;
        if (*dMem1 == ILLEGAL_VALUE)
          *dMem1 = 0;
        //printf("D *dMem0 %05o\n", *dMem0);
        //printf("D *dMem1 %05o\n", *dMem1);
        Val0 = (*dMem0 & ~BITS13) | (ValueToStore & BITS13);
        Val1 = (*dMem1 & ~BITS13) | ((ValueToStore >> 13) & BITS13);
        //printf("D Val0 %05o\n", Val0);
        //printf("D Val1 %05o\n", Val1);
        if (!IgnoreBreakpoint)
          if ((*dMem0 != ILLEGAL_VALUE && (*dMem0 & BREAK13) != 0) || (*dMem1
              != ILLEGAL_VALUE && (*dMem1 & BREAK13) != 0))
            {
              if (WatchmodeType != WT_CHANGE || *dMem0 != Val0 || *dMem1
                  != Val1)
                {
                  EmulatorWatchpoint = 1;
                  return;
                }
            }
        *dMem0 = Val0;
        *dMem1 = Val1;
      }
    break;
  case 015: // SPQ
    PQ_ANY_BREAK()
    ;
    ValueToStore = PqRegister;
    //printf("D SPQ %011o\n", ValueToStore);
    goto Store;
  case 016: // CLD
    {
      int yx;
      int32_t InputValue;
      yx = Value & 077;
      ACC_WRITE_BREAK();
      CLD_ANY_BREAK();
      if ((*CldCategories[yx].Input)(yx, &InputValue))
        EmulatorTimeout = 1;
      Accumulator = (Accumulator & ~BITS26) | (InputValue ? BITS26 : 0);
    }
    break;
  case 017: // TNZ
    ACC_ANY_BREAK()
    ;
    if (Accumulator & BITS26)
      goto Jump;
    break;
    }

  // Cleanup and prepare for next instruction.
  IgnoreBreakpoint = 0;
  CurrentCycles++;
  TotalCycles++;
  if (Run == 0)
    {
      char Input[41] = "R 0.0";
      HalSockBroadcastString(Input, strlen(Input));
      sprintf(Input, "S %lu", TotalCycles);
      HalSockBroadcastString(Input, strlen(Input));
    }
  if (WasJump)
    memcpy(&HopRegister, &JumpHOP, sizeof(Address_t));
  else
    {
      if ((HopRegister.Word & 0377) < 0377)
        HopRegister.Word++;
      else
        EmulatorEndOfSector = 1;
    }
  if (0 != (PqRegister & 0x70000000))
    PqRegister -= 0x10000000;
}

//==========================================================================

// This is where the debugger UI is completely implemented.  It communicates
// with the main program running the emulator via global variables.  There's
// a mutex associated with it, and the mutex is unlocked *only* while waiting
// for keyboard input.
void *
DebuggerThreadFunction(void *Data)
{
#define MAX_FIELDS 64
  int LastWasNext = 0;

  // Loop forever.
  pthread_mutex_lock(&DebuggerMutex);
  while (1)
    {
      char *s, *ss, c, *Fields[MAX_FIELDS];
      uint32_t *Mem32;
      uint16_t *Mem16M, *Mem16L;
      Address_t *MemAddress;
      int NumFields = 0;

      //DisplayDebuggerPrompt();
      pthread_mutex_unlock(&DebuggerMutex);
      s = fgets(DebuggerUserInput, sizeof(DebuggerUserInput), stdin);
      pthread_mutex_lock(&DebuggerMutex);
      if (NULL == s)
        continue;
      if (Run)
        {
          DebuggerPause = 1;
          pthread_mutex_unlock(&DebuggerMutex);
          while (DebuggerPause)
            SleepMilliseconds(10);
          pthread_mutex_lock(&DebuggerMutex);
        }

      // Normalize the input string somewhat by trimming off leading spaces
      // and trailing CR or LF.
      for (s = DebuggerUserInput; *s; s++)
        {
          if (*s == '\n' || *s == '\r')
            {
              *s = 0;
              break;
            }
        }
      for (s = DebuggerUserInput; isspace (*s); s++)
        ;

      // Parse the input line into NUL-terminated fields.  Start the
      // loop with s pointing to the first field.
      for (NumFields = 0; *s && *s != '#' && NumFields < MAX_FIELDS; NumFields++)
        {
          for (ss = s; *ss && !isspace (*ss); ss++)
            ; // Find end of the field.
          c = *ss;
          *ss = 0;
          Fields[NumFields] = s;
          if (c == 0)
            s = ss;
          else
            for (s = ss + 1; isspace (*s); s++)
              ;
        }

      // Convert the first field, which contains the command, to upper case.
      if (NumFields >= 1)
        for (s = Fields[0]; *s; s++)
          *s = toupper(*s);

      // Interpret the command entered by the user.
      if (NumFields < 1)
        {
          if (LastWasNext)
            goto Step;
        }
      else if (LastWasNext = 0, (!strcmp(Fields[0], "EXIT") || !strcmp(
          Fields[0], "QUIT")))
        {
          WriteBinaryFile("yaOBC.bin");
          WriteIoFile("yaOBC.io");
          DebuggerQuit = 1;
          break;
        }
      else if (!strcmp(Fields[0], "RUN") || !strcmp(Fields[0], "CONT")
          || !strcmp(Fields[0], "R"))
        {
          char Input[41];
          sprintf(Input, "R %lf", Speedup);
          HalSockBroadcastString(Input, strlen(Input));
          DebuggerRun = 1;
          IgnoreBreakpoint = 1;
          LastDebuggedHopRegister.Word ^= 0377;
          printf("Emulation running ...\n");
        }
      else if (!strcmp(Fields[0], "STEP") || !strcmp(Fields[0], "NEXT")
          || !strcmp(Fields[0], "S") || !strcmp(Fields[0], "N"))
        {
          Step: ;
          LastWasNext = 1;
          if (NumFields < 2)
            StepN = 1;
          else
            StepN = atoi(Fields[1]);
          IgnoreBreakpoint = 1;
          LastDebuggedHopRegister.Word ^= 0377;
        }
      else if (!strcmp(Fields[0], "BREAK"))
        {
          int Set = 0;
          if (ParseLocation(Fields[1], &Mem32, &Mem16M, &Mem16L, &MemAddress))
            printf("Can't parse Location field (%s).\n", Fields[1]);
          else
            {
              if (Mem32 != NULL)
                {
                  *Mem32 |= BREAK26;
                  Set = 1;
                }
              if (Mem16M != NULL)
                {
                  *Mem16M |= BREAK13;
                  Set = 1;
                }
              if (Mem16L != NULL)
                {
                  *Mem16L |= BREAK13;
                  Set = 1;
                }
              if (MemAddress != NULL)
                {
                  if (MemAddress == &HopRegister)
                    printf("Location %s not eligible for a breakpoint.\n",
                        Fields[1]);
                }
              if (Set)
                printf("Breakpoint set at location %s.\n", Fields[1]);
            }
        }
      else if (!strcmp(Fields[0], "WATCHMODE"))
        {
          if (!strcasecmp(Fields[1], "ANY"))
            WatchmodeType = WT_ANY;
          else if (!strcasecmp(Fields[1], "WRITE"))
            WatchmodeType = WT_WRITE;
          else if (!strcasecmp(Fields[1], "CHANGE"))
            WatchmodeType = WT_CHANGE;
          else
            printf("%s is not a valid WATCHMODE mode.\n", Fields[1]);
        }
      else if (!strcmp(Fields[0], "BREAKPOINTS"))
        {
          int yx, m, p, s, w;
          for (m = 0; m < MAX_MODULES; m++)
            for (p = 0; p < MAX_SECTORS; p++)
              for (s = 0; s < MAX_SYLLABLES; s++)
                for (w = 0; w < MAX_WORDS; w++)
                  if (Binary[m][p][s][w] != ILLEGAL_VALUE
                      && (Binary[m][p][s][w] & BREAK13) != 0)
                    printf("Breakpoint at %o-%02o-%o-%03o.\n", m, p, s, w);
          for (yx = 0; yx < MAX_YX; yx++)
            {
              if (0 != (ProCategories[yx].Value & BREAK26))
                printf("Breakpoint at PRO%02o.\n", yx);
            }
          for (yx = 0; yx < MAX_YX; yx++)
            {
              if (0 != (CldCategories[yx].Value & BREAK26))
                printf("Breakpoint at CLD%02o.\n", yx);
            }
          if ((Accumulator & BREAK26) != 0)
            printf("Breakpoint at ACC.\n");
          if ((PqRegister & BREAK26) != 0)
            printf("Breakpoint at PQ.\n");
        }
      else if (!strcmp(Fields[0], "DELETE"))
        {
          if (NumFields == 1)
            {
              uint16_t *Mem;
              int i;
              Mem = &Binary[0][0][0][0];
              for (i = 0; i < 8 * 16 * 3 * 256; i++, Mem++)
                if (*Mem != ILLEGAL_VALUE)
                  *Mem &= ~BREAK13;
              for (i = 0; i < MAX_YX; i++)
                {
                  ProCategories[i].Value &= ~BREAK26;
                  CldCategories[i].Value &= ~BREAK26;
                }
              Accumulator &= ~BREAK26;
              PqRegister &= ~BREAK26;
            }
          else
            {
              if (ParseLocation(Fields[1], &Mem32, &Mem16M, &Mem16L,
                  &MemAddress))
                printf("Can't parse Location field (%s).\n", Fields[1]);
              else
                {
                  if (Mem32 != NULL)
                    *Mem32 &= ~BREAK26;
                  else if (Mem16M != NULL)
                    *Mem16M &= ~BREAK13;
                  else if (Mem16L != NULL)
                    *Mem16L &= ~BREAK13;
                }
            }
        }
      else if (!strcmp(Fields[0], "PRINT"))
        {
          uint32_t Value;
          if (ParseLocation(Fields[1], &Mem32, &Mem16M, &Mem16L, &MemAddress))
            printf("Can't parse Location field %s.\n", Fields[1]);
          else
            {
              if (Mem32 != NULL)
                printf("%s: %09o\n", Fields[1], (*Mem32 & BITS26));
              else if (Mem16M != NULL)
                {
                  Value = ((*Mem16M & BITS13) << 13) | (*Mem16L & BITS13);
                  printf("%s: %09o\n", Fields[1], Value);
                }
              else if (Mem16L != NULL)
                printf("%s: %05o\n", Fields[1], (*Mem16L & BITS13));
              else if (MemAddress == &HopRegister)
                {
                  BuildObcHopRegisterFromAddress(MemAddress, &Value);
                  printf("%s: %09o\n", Fields[1], Value);
                }
            }
        }
      else if (!strcmp(Fields[0], "EDIT"))
        {
          if (ParseLocation(Fields[1], &Mem32, &Mem16M, &Mem16L, &MemAddress))
            printf("Can't parse Location field %s.\n", Fields[1]);
          else
            {
              int Value;
              if (ParseValue(Fields[2], &Value))
                printf("Can't parse Value field %s.\n", Fields[2]);
              else
                {
                  if (Mem32 != NULL)
                    *Mem32 = (*Mem32 & ~BITS26) | (Value & BITS26);
                  else if (Mem16M != NULL)
                    {
                      *Mem16M = (*Mem16M & ~BITS13) | ((Value >> 13) & BITS13);
                      *Mem16L = (*Mem16L & ~BITS13) | (Value & BITS13);
                    }
                  else if (Mem16L != NULL)
                    *Mem16L = (*Mem16L & ~BITS13) | (Value & BITS13);
                  else if (MemAddress == &HopRegister)
                    BuildAddressFromObcHopRegister(Value, MemAddress);
                }
            }
        }
      else if (!strcmp(Fields[0], "COREDUMP"))
        {
          if (!WriteBinaryFile(Fields[1]))
            printf("Snapshot file %s created.\n", Fields[1]);
          if (NumFields > 1 && !WriteIoFile(Fields[2]))
            printf("I/O file %s created.\n", Fields[2]);
        }
      else if (!strcmp(Fields[0], "ATM"))
        {
          int Module, i;
          uint16_t *Source, *Dest;
          Module = atoi(Fields[1]);
          if (Module < 1 || Module > 7)
            printf("The module to load must be in the range 1-7.\n");
          else
            {
              Source = &Binary[Module][0][0][0];
              Dest = &Binary[0][0][0][0];
              for (i = 0; i < 16 * 3 * 256; i++, Source++, Dest++)
                if (*Source != ILLEGAL_VALUE)
                  *Dest = *Source;
            }
        }
      else if (!strcmp(Fields[0], "SPEED"))
        {
          Speedup = atof(Fields[1]);
        }
      else if (!strcmp(Fields[0], "HELP") || !strcmp(Fields[0], "MENU")
          || !strcmp(Fields[0], "?"))
        {
          printf("Debugger commands:\n"
            "\tHELP or MENU or ? -- Display available commands.\n"
            "\tQUIT or EXIT -- Exit the yaOBC program, saving the current state.\n"
            "\tRUN or CONT or R -- Stop pausing and resume running the emulation.\n"
            "\tSTEP [N] or NEXT [N] or S [N] or N [N] -- Emulate next N instructions.\n"
            "\tBREAK Location -- Set breakpoint.\n"
            "\tWATCHMODE Mode -- Data-access types (ANY/WRITE/CHANGE) triggering breaks.\n"
            "\tBREAKPOINTS -- Display all breakpoints.\n"
            "\tDELETE [Location] -- Delete breakpoint at Location, or all.\n"
            "\tPRINT Location -- Display contents of Location.\n"
            "\tEDIT Location Value -- Modify contents of Location.\n"
            "\tCOREDUMP File [IoFile] -- Save system snapshot files.\n"
            "\tATM Module -- Load program Module from ATM into main memory.\n"
            "\tSPEED X -- Emulate at X times real time. (1.0 is normal.)\n"
            "Location formats:\n"
            "\tLeft-hand symbol, constant name, variable name\n"
            "\t[D-]Module-Sector-Syllable-Word\n"
            "\tHOP, ACC, PQ\n"
            "\tPROYX, CLDYX\n"
            "Value for EDIT:\n"
            "\tOctal constant with leading 0\n"
            "\tDecimal constant without decimal point -> unscaled\n"
            "\tDecimal constant with decimal point -> scaled\n"
            "\tLeft-hand symbol -> HOP constant\n"
            "\tVariable/constant name -> contents of the variable/constant\n"
            "\t[H-]Module-Sector-Syllable-Word -> HOP constant\n");
        }
      else
        printf("Unknown debugger command: %s\n", Fields[0]);

      if (!StepN)
        DisplayDebuggerPrompt();
    }

  pthread_mutex_unlock(&DebuggerMutex);
  return (NULL);
}

//==========================================================================

// Parse a Location string as described at
// http://www.ibiblio.org/apollo/Gemini.html#Location-Field_Parsing_by_the_Debugger.
// Return 0 on success, or non-zero on error.  If not error, set the MemXXX
// pointers as follows:
//      Mem32: 26-bit value in a 32-bit word.
//      Mem16L: 13-bit value in a 16-bit word.
//      Mem16M and Mem16L: 26-bit value in two 16-bit words with 13 bits each.
//      MemAddress: Address_t structure not part of a Symbol_t. (HopRegister)
// and set the other pointers to NULL.
int
ParseLocation(char *Location, uint32_t **Mem32, uint16_t **Mem16M,
    uint16_t **Mem16L, Address_t **MemAddress)
{
  int m, p, s, w, yx;
  Symbol_t Key, *SearchResult;

  *Mem32 = NULL;
  *Mem16M = NULL;
  *Mem16L = NULL;
  *MemAddress = NULL;

  if (!strcasecmp(Location, "HOP"))
    {
      *MemAddress = &HopRegister;
      return (0);
    }
  if (!strcasecmp(Location, "ACC"))
    {
      *Mem32 = &Accumulator;
      return (0);
    }
  if (!strcasecmp(Location, "PQ"))
    {
      *Mem32 = &PqRegister;
      return (0);
    }
  if (4 == sscanf(Location, "%o-%o-%o-%o", &m, &p, &s, &w) && m >= 0 && m
      < MAX_MODULES && p >= 0 && p < MAX_SECTORS && s >= 0 && s < MAX_SYLLABLES
      && w >= 0 && w < MAX_WORDS)
    {
      *Mem16L = &Binary[m][p][s][w];
      return (0);
    }
  if (!strncasecmp(Location, "D-", 2) && 4 == sscanf(Location + 2,
      "%o-%o-%o-%o", &m, &p, &s, &w) && m >= 0 && m < MAX_MODULES && p >= 0
      && p < MAX_SECTORS && s == 0 && w >= 0 && w < MAX_WORDS)
    {
      *Mem16M = &Binary[m][p][1][w];
      *Mem16L = &Binary[m][p][0][w];
      return (0);
    }
  if (!strncasecmp(Location, "PRO", 3) && 1 == sscanf(Location + 3, "%o", &yx)
      && yx >= 0 && yx < MAX_YX)
    {
      *Mem32 = (uint32_t*) &ProCategories[yx].Value;
      return (0);
    }
  if (!strncasecmp(Location, "CLD", 3) && 1 == sscanf(Location + 3, "%o", &yx)
      && yx >= 0 && yx < MAX_YX)
    {
      *Mem32 = (uint32_t*) &CldCategories[yx].Value;
      return (0);
    }

  // Search for symbol-name.
  strcpy(Key.Name, Location);
  SearchResult = bsearch(&Key, Symbols, NumSymbols, sizeof(Symbol_t),
      CompareSymbols);
  if (SearchResult != NULL)
    {
      if (SearchResult->Type == ST_CODE)
        {
          Mem13: ;
          *Mem16L
              = &Binary[SearchResult->Address.Module][SearchResult->Address.Page][SearchResult->Address.Syllable][SearchResult->Address.Word];
          if (**Mem16L == ILLEGAL_VALUE)
            {
              printf("FYI: Location %s (LSW) was previously uninitialized.\n",
                  Location);
              **Mem16L = 0;
            }
        }
      else if (SearchResult->Type == ST_CONSTANT || SearchResult->Type
          == ST_VARIABLE)
        {
          if (SearchResult->Address.Syllable == 2)
            goto Mem13;
          *Mem16M
              = &Binary[SearchResult->Address.Module][SearchResult->Address.Page][1][SearchResult->Address.Word];
          if (**Mem16M == ILLEGAL_VALUE)
            {
              printf("FYI: Location %s (MSW) was previously uninitialized.\n",
                  Location);
              **Mem16M = 0;
            }
          goto Mem13;
        }

      return (0);
    }

  printf("Note that symbols are case-sensitive to the debugger.\n");
  return (1); // No matches, error.
}

//==========================================================================

// Parse a Value string for the debugger's EDIT command as described at
// http://www.ibiblio.org/apollo/Gemini.html#Commands_Recognised_by_the_yaOBC.
// Return 0 on success, or non-zero on error.  If not error, set Value.
int
ParseValue(char *ValueString, int *Value)
{
  int m, p, s, w;
  Symbol_t Key, *Result;

  if (ValueString[0] == '0' && strspn(ValueString, "01234567") == strlen(
      ValueString))
    {
      sscanf(ValueString, "%o", Value);
      return (0);
    }
  if ((ValueString[0] == '+' || ValueString[0] == '-'
      || isdigit (ValueString[0])) && strspn(ValueString + 1, "0123456789")
      == strlen(ValueString + 1))
    {
      if (1 != sscanf(ValueString, "%d", Value))
        return (1);
      return (0);
    }
  if ((ValueString[0] == '+' || ValueString[0] == '-' || ValueString[0] == '.'
      || isdigit (ValueString[0])) && strspn(ValueString + 1, ".0123456789")
      == strlen(ValueString + 1))
    {
      double f;
      if (1 != sscanf(ValueString, "%lf", &f))
        return (1);
      if (f == 0.0)
        *Value = 0;
      else
        {
          while (fabs(f) >= 1.0)
            f /= 2.0;
          while (fabs(f) < 0.5)
            f *= 2.0;
          *Value = lround(f * (1 << 25));
        }
      return (0);
    }
  if (((!strncasecmp(ValueString, "H-", 2) && 4 == sscanf(ValueString + 2,
      "%o-%o-%o-%o", &m, &p, &s, &w)) || 4 == sscanf(ValueString,
      "%o-%o-%o-%o", &m, &p, &s, &w)) && m >= 0 && m < MAX_MODULES && p >= 0
      && p < MAX_SECTORS && s >= 0 && s < MAX_SYLLABLES && w >= 0 && w
      < MAX_WORDS)
    {
      uint32_t Value32;
      Address_t Address;
      Address.Module = m;
      Address.Page = p;
      Address.Syllable = s;
      Address.Word = w;
      Address.HalfWordMode = (0 == strncasecmp(ValueString, "H-", 2));
      BuildObcHopRegisterFromAddress(&Address, &Value32);
      *Value = Value32;
      return (0);
    }
  strcpy(Key.Name, ValueString);
  Result = bsearch(&Key, Symbols, NumSymbols, sizeof(Symbol_t), CompareSymbols);
  if (Result != NULL)
    {
      if (Result->Type == ST_CODE)
        {
          uint32_t Value32;
          BuildObcHopRegisterFromAddress(&Result->Address, &Value32);
          *Value = Value32;
          return (0);
        }
      else if (Result->Type == ST_CONSTANT || Result->Type == ST_VARIABLE)
        {
          uint16_t *Mem16M, *Mem16L, Zero = 0;
          if (Result->Address.Syllable == 2) // Half-word
            {
              Mem16M = &Zero;
              Mem16L
                  = &Binary[Result->Address.Module][Result->Address.Page][2][Result->Address.Word];
              if (*Mem16L == ILLEGAL_VALUE)
                {
                  printf(
                      "FYI: Location %s (LSW) was previously uninitialized.\n",
                      ValueString);
                  *Mem16L = 0;
                }
            }
          else // full-word
            {
              Mem16M
                  = &Binary[Result->Address.Module][Result->Address.Page][1][Result->Address.Word];
              if (*Mem16M == ILLEGAL_VALUE)
                {
                  printf(
                      "FYI: Location %s (MSW) was previously uninitialized.\n",
                      ValueString);
                  *Mem16M = 0;
                }
              Mem16L
                  = &Binary[Result->Address.Module][Result->Address.Page][0][Result->Address.Word];
              if (*Mem16L == ILLEGAL_VALUE)
                {
                  printf(
                      "FYI: Location %s (LSW) was previously uninitialized.\n",
                      ValueString);
                  *Mem16L = 0;
                }
            }
          *Value = ((*Mem16M & BITS13) << 13) | (*Mem16L & BITS13);
          return (0);
        }
    }
  return (1);
}

//==========================================================================

void
SleepMilliseconds(unsigned Milliseconds)
{
  if (Milliseconds == 0)
    return;
#ifdef WIN32
  Sleep (Milliseconds);
#else
  struct timespec Req, Rem;
  Req.tv_sec = Milliseconds / 1000;
  Req.tv_nsec = (Milliseconds % 1000) * 1000 * 1000; // 10 milliseconds.
  nanosleep(&Req, &Rem);
#endif
}

//==========================================================================

// Hardware-abstraction: method types for the --method command-line switch.
// All functions return:
//      0 on success
//      1 on errors such as bad YX
//      2 on timeout
// Note that while the CPU doesn't support anything for discrete outputs,
// we nevertheless provide a function for it, for use by the debugger.

// These particular HAL functions are for type=SOCK.

static ENetHost *host = NULL;

// The thread function that services the enet server.
void *
HalSockThreadFunction(void *Data)
{
  double f;
  int yx, b;
  unsigned long c, d, Order = 0;
  HalSockEvent_t Event;

  while (1)
    {
      ENetEvent event;
      int EventFound = 0;
      char Input[41];

      // Service the host for incoming packets, connects, disconnects.
      enet_host_service(host, &event, 1000);
      switch (event.type)
        {
      case ENET_EVENT_TYPE_CONNECT:
        if (Verbosity)
          {
            printf("A new client connected from 0x%08X:%u.\n",
                event.peer -> address.host, event.peer -> address.port);
            NeedDebuggerPrompt = 1;
          }
        sprintf(Input, "S %lu", TotalCycles);
        HalSockBroadcastString(Input, strlen(Input));
        if (Run)
          sprintf(Input, "R %lf", Speedup);
        else
          sprintf(Input, "R 0.0");
        HalSockBroadcastString(Input, strlen(Input));
        break;

      case ENET_EVENT_TYPE_RECEIVE:
        if (Verbosity > 5)
          {
            printf("%u 0x%08X:%u \"%s\"\n", event.packet -> dataLength,
                event.peer -> address.host, event.peer -> address.port,
                event.packet -> data);
            NeedDebuggerPrompt = 1;
          }
        // Interpret the incoming packet.
        if (1 == sscanf((char *) event.packet->data, "R %lf", &f))
          SetCyclesPerTick(f);
        else if (3 == sscanf((char *) event.packet->data, "D%02o%1o %lu", &yx,
            &b, &c) && yx <= 077 && b <= 1)
          {
            EventFound = 1;
            Event.Type = 1;
            Event.Data = b;
          }
        else if (3 == sscanf((char *) event.packet->data, "P%02o %lu %lu", &yx,
            &d, &c) && yx <= 077 && d <= 0377777777)
          {
            EventFound = 1;
            Event.Type = 0;
            Event.Data = d;
          }
        if (EventFound)
          {
            Event.yx = yx;
            Event.Count = c;
            Event.Order = Order++;
            pthread_mutex_lock(&HalSockMutex);
            if (NumHalSockEvents < MAX_HALSOCK_EVENTS)
              {
                memcpy(&HalSockEvents[NumHalSockEvents++], &Event,
                    sizeof(Event));
                qsort(HalSockEvents, NumHalSockEvents, sizeof(HalSockEvent_t),
                    HalSockEventCmp);
              }
            else if (Verbosity)
              {
                printf("Event queue full, dropping \"%s\".\n",
                    event.packet->data);
                NeedDebuggerPrompt = 1;
              }
            pthread_mutex_unlock(&HalSockMutex);
          }

        /* Clean up the packet now that we're done using it. */
        enet_packet_destroy(event.packet);
        break;

      case ENET_EVENT_TYPE_DISCONNECT:
        if (Verbosity)
          {
            printf("\r0x%08X:%u disconnected.\n", event.peer -> address.host,
                event.peer -> address.port);
            NeedDebuggerPrompt = 1;
          }
        break;

      default:
        //printf ("No events.\n");
        break;
        }
    }
}

// This function initializes the enet system, sets up the
// enet server, and creates a thread to service it.
int
HalSockInitialize(void)
{
  int i, RetVal = 1;
  static int HalSockInitialized = 0;
  ENetAddress address;

  if (HalSockInitialized)
    return (0);
  pthread_mutex_lock(&HalSockMutex);

  // Initialize the socket library.
  if (enet_initialize() != 0)
    {
      printf("An error occurred while initializing ENet.\n");
      goto Error;
    }
  atexit(enet_deinitialize);

  if (Verbosity)
    {
      printf("Starting up enet server.\n");
      NeedDebuggerPrompt = 1;
    }

  /* Bind the server to the default localhost.     */
  /* A specific host address can be specified by   */
  /* enet_address_set_host (& address, "x.x.x.x"); */
  address.host = ENET_HOST_ANY;
  /* Bind the server to port. */
  address.port = Port;
  host = enet_host_create(&address, 32, 1, 0, 0);
  if (host == NULL)
    {
      printf("An error occurred while trying to create an ENet server host.\n");
      goto Error;
    }

  // Set up a thread to service the server.
  if (0 != (i = pthread_create(&HalSockThread, NULL, HalSockThreadFunction,
      NULL)))
    {
      printf("Could not create socket-driver thread (error %d).\n", i);
      goto Error;
    }

  HalSockInitialized = 1;
  RetVal = 0;
  Error: pthread_mutex_unlock(&HalSockMutex);
  return (RetVal);
}

void
HalSockBroadcastString(char *String, int Length)
{
  ENetPacket *packet;
  packet = enet_packet_create(String, Length + 1, ENET_PACKET_FLAG_RELIABLE);
  enet_host_broadcast(host, 0, packet);
  enet_host_flush(host);
}

int
ProOutputFunctionSock(int yx, int32_t Value)
{
  int i;
  char Input[41];

  if (ProOutputFunctionMem(yx, Value))
    return (1);

  i = sprintf(Input, "P%02o %09o %lu", yx, (unsigned) Value, TotalCycles);
  HalSockBroadcastString(Input, i);
  return (0);
}

int
ProInputFunctionSock(int yx, int32_t *Value)
{
  return (ProInputFunctionMem(yx, Value));
}

int
CldOutputFunctionSock(int yx, int32_t Value)
{
  int i;
  char Input[41];

  if (CldOutputFunctionMem(yx, Value))
    return (1);

  i = sprintf(Input, "D%02o%c %lu", yx, (Value ? '1' : '0'), TotalCycles);
  HalSockBroadcastString(Input, i);
  return (0);
}

int
CldInputFunctionSock(int yx, int32_t *Value)
{
  return (CldInputFunctionMem(yx, Value));
}

