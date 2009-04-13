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

#include "yaAGC.h"
#include "agc_cli.h"
#include "agc_engine.h"
#include "agc_symtab.h"
#include "agc_debug.h"
#include "agc_debugger.h"
#include "agc_simulator.h"

/** Declare the singleton Simulator object instance */
static Simulator_t Simulator;

static int SimInitializeEngine(void)
{
	int result = 0;

	/* Initialize the simulation */
	if (!Simulator.Options->debug_dsky)
	{
		if (Simulator.Options->resume == NULL)
	    {
			if (Simulator.Options->cfg)
	    	{
				if (CmOrLm)
				{
					result = agc_engine_init (&Simulator.State,
							Simulator.Options->core, "CM.core", 0);
				}
				else
				{
					result = agc_engine_init (&Simulator.State,
							Simulator.Options->core, "LM.core", 0);
				}
			}
	    	else
	    	{
	    		result = agc_engine_init (&Simulator.State,
	    				Simulator.Options->core,"core", 0);
	    	}
	    }
	    else
	    {
	    	result = agc_engine_init (&Simulator.State,
	    			Simulator.Options->core, Simulator.Options->resume, 1);
	    }

		/* Check AGC Engine Init Result and display proper message */
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

	return (result);
}

/**
This function executes one cycle of the AGC engine. This is
a wrapper function to eliminate showing the passing of the
current engine state. */
static void SimExecuteEngine()
{
	agc_engine (&Simulator.State);
}


/**
Initialize the AGC Simulator; this means setting up the debugger, AGC
engine and initializing the simulator time parameters.
*/
int SimInitialize(Options_t* Options)
{
	int result = 0;

	/* Without Options we can't Run */
	if (!Options) return(6);

	/* Set the basic simulator variables */
	Simulator.Options = Options;
	Simulator.DebugRules = DebugRules;
	Simulator.DumpInterval = Options->dump_time * sysconf (_SC_CLK_TCK);

	/* Set legacy Option variables */
	Portnum = Options->port;
	DebugDsky = Options->debug_dsky;
	DebugDeda = Options->debug_deda;
	Simulator.DumpInterval = Simulator.DumpInterval;
	SocketInterlaceReload = Options->interlace;

	/* If we are not in quiet mode display the version info */
	if (!Options->quiet) DbgDisplayVersion();

	/* Initialize the AGC Engine */
	result = SimInitializeEngine();

	/* Initialize the Debugger if running with debug mode */
	if(Options->debug) DbgInitialize(Options,&(Simulator.State));

//	if (Options->cdu_log)
//	{
//	  extern FILE *CduLog;
//	  CduLog = fopen (Options->cdu_log, "w");
//	}

	/* Initialize realtime and cycle counters */
	Simulator.RealTimeOffset = times (&Simulator.DummyTime);	// The starting time of the program.
	Simulator.NextCoreDump = Simulator.RealTimeOffset + Simulator.DumpInterval;
	SimSetCycleCount(SIM_CYCLECOUNT_AGC); // Num. of AGC cycles so far.
	Simulator.RealTimeOffset -= (Simulator.CycleCount + AGC_PER_SECOND / 2) / AGC_PER_SECOND;
	Simulator.LastRealTime = ~0UL;

	return (result | Options->version);
}

/**
This function adjusts the Simulator Cycle Count. Either based on the number
of AGC Cycles or incremented during Sim cycles. This functions uses a
mode switch to determine how to set or adjust the Cycle Counter
*/
void SimSetCycleCount(int Mode)
{
	switch(Mode)
	{
		case SIM_CYCLECOUNT_AGC:
			Simulator.CycleCount = sysconf (_SC_CLK_TCK) * Simulator.State.CycleCounter;
			break;
		case SIM_CYCLECOUNT_INC:
			Simulator.CycleCount += sysconf (_SC_CLK_TCK);
			break;
	}
}

/**
This function puts the simulator in a sleep state to reduce
CPU usage on the PC.
*/
static void SimSleep(void)
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

/**
This function manages the AGC periodic core dumping of the
AGC state machine.
*/
static void SimManageCoreDump(void)
{
	/* Check to see if the next core dump should be made */
	if (Simulator.RealTime >= Simulator.NextCoreDump)
	{
		/* Use either specific core dump name (from cfg) or generic */
		if (Simulator.Options->cfg)
		{
			if (CmOrLm) MakeCoreDump (&Simulator.State, "CM.core");
			else MakeCoreDump (&Simulator.State, "LM.core");
		}
		else MakeCoreDump (&Simulator.State, "core");

		/* Set the next CoreDump Time based on DumpInterval time */
		Simulator.NextCoreDump = Simulator.RealTime + Simulator.DumpInterval;
	}
}

/**
 * This function is a helper to allow the debugger to update the realtime
 */
void SimUpdateTime(void)
{
	Simulator.RealTimeOffset +=
		((Simulator.RealTime = times (&Simulator.DummyTime)) - Simulator.LastRealTime);
	Simulator.LastRealTime = Simulator.RealTime;
}

/**
This function manages the Simulator time to achieve the
average 11.7 microsecond per opcode execution
*/
static void SimManageTime(void)
{
	Simulator.RealTime = times (&Simulator.DummyTime);
	if (Simulator.RealTime != Simulator.LastRealTime)
	{
		/* Make a routine core dump */
		SimManageCoreDump();

		// Need to recalculate the number of AGC cycles we're supposed to
		// have executed.  Notice the trick of multiplying both CycleCount
		// and DesiredCycles by CLK_TCK, to avoid a long long division by CLK_TCK.
		// This not only reduces overhead, but actually makes the calculation
		// more exact.  A bit tricky to understand at first glance, though.
		Simulator.LastRealTime = Simulator.RealTime;

		//DesiredCycles = ((RealTime - RealTimeOffset) * AGC_PER_SECOND) / CLK_TCK;
		//DesiredCycles = (RealTime - RealTimeOffset) * AGC_PER_SECOND;
		// The calculation is done in the following funky way because if done as in
		// the line above, the right-hand side will be done in 32-bit arithmetic
		// on a 32-bit CPU, while the left-hand side is 64-bit, and so the calculation
		// will overflow and fail after 4 minutes of operation.  Done the following
		// way, the calculation will always be 64-bit.  Making AGC_PER_SECOND a ULL
		// constant in agc_engine.h would fix it, but the Orbiter folk wouldn't
		// be able to compile it.
		Simulator.DesiredCycles = Simulator.RealTime;
		Simulator.DesiredCycles -= Simulator.RealTimeOffset;
		Simulator.DesiredCycles *= AGC_PER_SECOND;
	}
	else SimSleep();
}

/**
Execute the simulated CPU.  Expecting to ACCURATELY cycle the simulation every
11.7 microseconds within Linux (or Win32) is a bit too much, I think.
(Not that it's really critical, as long as it looks right from the
user's standpoint.)  So I do a trick:  I just execute the simulation
often enough to keep up with real-time on the average.  AGC time is
measured as the number of machine cycles divided by AGC_PER_SECOND,
while real-time is measured using the times() function.  What this mains
is that AGC_PER_SECOND AGC cycles are executed every CLK_TCK clock ticks.
The timing is thus rather rough-and-ready (i.e., I'm sure it can be improved
a lot).  It's good enough for me, for NOW, but I'd be happy to take suggestions
for how to improve it in a reasonably portable way.*/
void SimExecute(void)
{
	while(1)
	{
		/* Manage the Simulated Time */
		SimManageTime();

		while (Simulator.CycleCount < Simulator.DesiredCycles)
		{
			/* If debugging is enabled run the debugger */
			if (Simulator.Options->debug && DbgExecute()) continue;

			/* Execute a cyle of the AGC  engine */
			SimExecuteEngine();

			/* Adjust the CycleCount */
			SimSetCycleCount(SIM_CYCLECOUNT_INC);
		}
	}
}



