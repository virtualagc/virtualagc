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

#define SIM_E_OK  0
#define SIM_E_VERSION 6

typedef struct
{
	agc_t* State;
	Options_t* Options;
	DebugRule_t* DebugRules;
	clock_t DumpInterval;
} Simulator_t;


extern int SimInitialize(Options_t* Options);
extern void SimExecute(void);

extern clock_t NextCoreDump;
extern clock_t DumpInterval;
extern struct tms DummyTime;
extern clock_t RealTime;
extern clock_t RealTimeOffset;
extern clock_t LastRealTime;
extern clock_t NextKeycheck;
extern uint64_t CycleCount;
extern uint64_t DesiredCycles;

#endif /* AGC_SIMULATOR_H_ */
