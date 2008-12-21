/*
 * agc_simulator.c
 *
 *  Created on: Dec 2, 2008
 *      Author: MZ211D
 */
#include <stdio.h>
#include <ctype.h>
#include <string.h>
#include <unistd.h>
#include <stdlib.h>

#ifdef WIN32
#include <windows.h>
#include <sys/time.h>
#define LB "\r\n"
#else
#include <time.h>
#include <sys/times.h>
#define LB ""
#endif

#include "yaAGC.h"
#include "agc_cli.h"
#include "agc_engine.h"
#include "agc_symtab.h"
#include "agc_simulator.h"


agc_t State;

clock_t NextCoreDump;
clock_t DumpInterval;
struct tms DummyTime;
clock_t RealTime;
clock_t RealTimeOffset;
clock_t LastRealTime;
clock_t NextKeycheck;
uint64_t CycleCount;
uint64_t DesiredCycles;


#ifdef WIN32
struct tms {
  clock_t tms_utime;  /* user time */
  clock_t tms_stime;  /* system time */
  clock_t tms_cutime; /* user time of children */
  clock_t tms_cstime; /* system time of children */
};

clock_t times (struct tms *p)
{
  return (GetTickCount ());
}

#define _SC_CLK_TCK (1000)
#define sysconf(x) (x)
#endif // WIN32


static Simulator_t Simulator;


int InitializeSimulator(Options_t* Options)
{
	int result = 0;

	/* Without Options we can't Run */
	if (!Options) return(6);

	/* Set the basic simulator variables */
	Simulator.DebugRules = DebugRules;
	Simulator.Options = Options;
	Simulator.State = &State;
	Simulator.DumpInterval = Options->dump_time * sysconf (_SC_CLK_TCK);

	/* Set legacy Option variables */
	Portnum = Options->port;
	DebugDsky = Options->debug_dsky;
	DebugDeda = Options->debug_deda;
	DumpInterval = Simulator.DumpInterval;
	SocketInterlaceReload = Options->interlace;

	/* If we are not in quiet mode display the version info */
	if (!Options->quiet) gdbmiHandleShowVersion();

	/* Initialize the simulation */
	if (!Options->debug_dsky)
	{
	      if (Options->resume == NULL)
	      {
		  		if (CmOrLm) result = agc_engine_init (Simulator.State, Options->core, "CM.core", 0);
		  		else result = agc_engine_init (Simulator.State, Options->core, "LM.core", 0);
		   }
	      else result = agc_engine_init (Simulator.State, Options->core, Options->resume, 1);

	  switch (result)
		{
		    case 0:
		    	break; /* All is OK */
			case 1:
			  printf ("Specified core-rope image file not found.\n");
			  break;
			case 2:
			  printf ("Core-rope image larger than core memory.\n");
			  break;
			case 3:
			  printf ("Core-rope image file must have even size.\n");
			  break;
			case 5:
			  printf ("Core-rope image file read error.\n");
			  break;
			default:
			  printf ("Initialization implementation error.\n");
			  break;
		}
	}

	/* Initialize the Debugger if running with debug mode */
	if(Options->debug) DbgInitialize(Options,&State);

//	if (Options->cdu_log)
//	{
//	  extern FILE *CduLog;
//	  CduLog = fopen (Options->cdu_log, "w");
//	}

	/* Initialize realtime and cycle counters */
	RealTimeOffset = times (&DummyTime);	// The starting time of the program.
	NextCoreDump = RealTimeOffset + DumpInterval;
	CycleCount = State.CycleCounter * sysconf (_SC_CLK_TCK);	// Number of AGC cycles so far.
	RealTimeOffset -= (CycleCount + AGC_PER_SECOND / 2) / AGC_PER_SECOND;
	LastRealTime = ~0UL;

	return (result);
}

void CycleSimulator(void)
{

}

/*
 * Execute the simulated CPU.  Expecting to ACCURATELY cycle the simulation every
 * 11.7 microseconds within Linux (or Win32) is a bit too much, I think.
 * (Not that it's really critical, as long as it looks right from the
 * user's standpoint.)  So I do a trick:  I just execute the simulation
 * often enough to keep up with real-time on the average.  AGC time is
 * measured as the number of machine cycles divided by AGC_PER_SECOND,
 * while real-time is measured using the times() function.  What this mains
 * is that AGC_PER_SECOND AGC cycles are executed every CLK_TCK clock ticks.
 * The timing is thus rather rough-and-ready (i.e., I'm sure it can be improved
 * a lot).  It's good enough for me, for NOW, but I'd be happy to take suggestions
 * for how to improve it in a reasonably portable way.
 */
void ExecuteSimulator(void)
{
	RealTime = times (&DummyTime);
	if (RealTime != LastRealTime)
	{
	  /* Make a routine core dump */
	  if (RealTime >= NextCoreDump)
	  {
		  if (CmOrLm) MakeCoreDump (&State, "CM.core");
		  else MakeCoreDump (&State, "LM.core");

		  NextCoreDump = RealTime + DumpInterval;
	  }

	  // Need to recalculate the number of AGC cycles we're supposed to
	  // have executed.  Notice the trick of multiplying both CycleCount
	  // and DesiredCycles by CLK_TCK, to avoid a long long division by CLK_TCK.
	  // This not only reduces overhead, but actually makes the calculation
	  // more exact.  A bit tricky to understand at first glance, though.
	  LastRealTime = RealTime;

	  //DesiredCycles = ((RealTime - RealTimeOffset) * AGC_PER_SECOND) / CLK_TCK;
	  //DesiredCycles = (RealTime - RealTimeOffset) * AGC_PER_SECOND;
	  // The calculation is done in the following funky way because if done as in
	  // the line above, the right-hand side will be done in 32-bit arithmetic
	  // on a 32-bit CPU, while the left-hand side is 64-bit, and so the calculation
	  // will overflow and fail after 4 minutes of operation.  Done the following
	  // way, the calculation will always be 64-bit.  Making AGC_PER_SECOND a ULL
	  // constant in agc_engine.h would fix it, but the Orbiter folk wouldn't
	  // be able to compile it.
	  DesiredCycles = RealTime;
	  DesiredCycles -= RealTimeOffset;
	  DesiredCycles *= AGC_PER_SECOND;
	}
	else
	{
#ifdef WIN32
	  Sleep (10);
#else
	  struct timespec req, rem;
	  req.tv_sec = 0;
	  req.tv_nsec = 10000000;
	  nanosleep (&req, &rem);
#endif
	}
}

