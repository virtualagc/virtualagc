/*
 * agc_simulator.h
 *
 *  Created on: Dec 2, 2008
 *      Author: MZ211D
 */

#ifndef AGC_SIMULATOR_H_
#define AGC_SIMULATOR_H_

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
#include "agc_engine.h"

#ifdef WIN32
struct tms {
  clock_t tms_utime;  /* user time */
  clock_t tms_stime;  /* system time */
  clock_t tms_cutime; /* user time of children */
  clock_t tms_cstime; /* system time of children */
};

#define _SC_CLK_TCK (1000)
#define sysconf(x) (x)
#define times(p) (clock_t)GetTickCount ()

#endif

#define SIM_E_OK  0
#define SIM_E_VERSION 6

#define SIM_CYCLECOUNT_INC 	1
#define SIM_CYCLECOUNT_AGC	2


typedef struct
{
	Options_t* Options;
	DebugRule_t* DebugRules;
	clock_t DumpInterval;
	clock_t RealTimeOffset;
	clock_t RealTime;
	clock_t LastRealTime;
	clock_t NextCoreDump;
	uint64_t DesiredCycles;
	uint64_t CycleCount;
	struct tms DummyTime;
	agc_t State;
} Simulator_t;

extern void SimSetCycleCount(int Mode);
extern int SimInitialize(Options_t* Options);
extern void SimExecute(void);
extern void SimUpdateTime(void);

#endif /* AGC_SIMULATOR_H_ */
