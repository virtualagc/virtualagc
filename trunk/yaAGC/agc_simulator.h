/*
 * agc_simulator.h
 *
 *  Created on: Dec 2, 2008
 *      Author: MZ211D
 */

#ifndef AGC_SIMULATOR_H_
#define AGC_SIMULATOR_H_

typedef struct
{
	agc_t* State;
	Options_t* Options;
	DebugRule_t* DebugRules;
	clock_t DumpInterval;
} Simulator_t;


extern int InitializeSimulator(Options_t* Options);
extern void ExecuteSimulator(void);
extern void CycleSimulator(void);

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
