![http://virtualagc.googlecode.com/svn/trunk/Apollo32.png](http://virtualagc.googlecode.com/svn/trunk/Apollo32.png)

# 1 AGC Operating System Services #
The Operating System (OS) designed for the Apollo Guidance Computer was (one of) the first of its kind using a pre-emptive scheduling approach in a real-time software environment. The architect behind the design was Hal Laning. The following sections describe the Operating Systems design in order to provide you with a good starting point to explore and understand the actual AGC code (e.g. Colossus249).  With  this knowledge you should be able to run the actual code with the Virtual AGC and use the Code::Blocks IDE to single step through sections of the OS and understand what is occurring.  It will also give you some insight into the famous program alarms which occurred during the Apollo 11 moon landing. The Apollo Guidance Computer Operating System will be referred to as the OS in the remainder of these sections.

The purpose of the OS was to schedule jobs and tasks and to manage the registers available to running and suspended jobs and tasks. Besides these basic RTOS features the AGC Operating services also included an interpreter providing high-level math functions for vector and matrix calculations. This document first describes the scheduling entities: Jobs and Tasks, followed by the scheduling mechanisms used to run these entities. There after the interpreter service will be discussed briefly.

## 1.1 Jobs and Tasks ##
Jobs and tasks are the scheduling entities of the OS.  Each of these entities will be discussed in the following sections. Before starting to point out more detailed attributes of each of these scheduling entities one must understand that jobs are the heavy lifters when it comes to implementing guidance functions whereas tasks are small time driven functions that typically would kick-off jobs and/or schedule them selves again for execution.

### 1.1.1 What is a Job ###
A job is a collection of functions to accomplish a specific feature or activity.  Groups of related functions that must run sequentially would typically be allocated to the same job. A job has a priority and when a job is executing and a higher priority job gets activated then the OS would suspend the current Job, backup its registers and start executing the higher priority job. A maximum of 8 jobs could be active at any given moment and as such 8 backup locations for their registers needed to exists. These backup register locations are known as core sets and contained up to 12 register values. When a new Job needs to be activated it also requires a core set to be able to store its registers in case it would be suspended. If no core set can be found a 1202 program alarm would be flagged by calling the BAILOUT routine. The astronauts would be notified of this situation by illuminating the "Prog" lamp on the DSKY.  To determine the cause of the "Prog" light the astronaut would enter V05N09 on the DSKY to determine which program alarm was set. Besides the core sets for the registers, Jobs could use an additional set of 43 registers if they used the interpreter module. However only 5 of these large blocks of memory known as Vector Accumulators (VAC) were available. If more jobs were scheduled that needed these so called VAC's then a 1201 alarm would be flagged. Note different versions of the software for the Command Module (CM) or Lunar Module (LM) could use different numbers of available core sets (e.g. Colossus055 only had 7 core sets of 11 registers).

| **Job**  | **Priority** | **Type** | **Function** |
|:---------|:-------------|:---------|:-------------|
|SERVICER|20|VAC	|Navigation, guidance, throttle,DAP command and display|
|LRVJOB  |32|NOVAC	|Read landing radar velocity|
|HIGATJOB|32|VAC	|Run once to position landing radar antenna at high gate|
_**Table 1. Example Jobs with their priority and potential need for Vector Accumulators**_

### 1.1.2 What is a Task ###
A Task is a small chunk of code which typically needs to execute on a time driven basis. Tasks were typically used for sampling sensor data at regular intervals. Tasks had to be of short duration and were scheduled on a time basis and not based on a priority as is the case with jobs. Tasks could activate jobs with a certain priority. For example a task named READACCS read the accelerometers at specific time intervals.

## 1.2 Scheduling ##
The OS used two different mechanisms to schedule and execute functions. Each mechanism is linked to the type of scheduling entity it could activate (see section 1.1). The priority driven jobs were scheduled, executed and managed by the EXECUTIVE module and the time driven Tasks were run and activated by the WAITLIST module. Since jobs were typically added to the run queue of the EXECUTIVE by tasks we will first look at the WAITLIST module.

### 1.2.1 The WAITLIST ###
The WAITLIST module is responsible for activating tasks when their desired execution time has arrived. To manage the tasks the WAITLIST uses two arrays of size 8. One array is named LST1 and contains the wait times to control the task activation and the other array is named LST2 to manage the pointers to the task entries. The array entries are synchronized with each other and are off only by one index.

#### 1.2.1.1 Initialization ####
During startup (FRESH\_START\_AND\_RESTART module) the two arrays are initialized. All entries in LST1 are set to octal 020000 (i.e. 8192 decimal). This value in LST1 means the slot is available for a task. The entries in LST2 are all initialized with pointers to the ENDTASK address (Octal address 05306). Each array entry in LST1 is a 15 bit value representing the time in centi-seconds to set the timer TIME3 which creates an interrupt T3RUPT when it expires (i.e. reaches 0). Since we have 8 locations in LST1 and the current active timer in TIME3 the WAITLIST module can manage 9 tasks.

The pointer values in LST2 are two 15 bit values that together create the 2 component address (2CADR) of the task to start. The first 15 bit value is the address within the bank and the second contained the 15 bit value of the both banks values encoding the erasable bank and fixed bank values in a single 15 bit register (banked memory strategies we can still find today in for example a 68HC12 from Freescale). The 2CADR in LST2 allows the WAITLIST to set the proper bank registers. If no tasks are added into the wait list the default task ENDTASK will run every 81.92 seconds (see next section about dispatching to verify this). The ENDTASK value is actually the 2CADR of the routine: SVCT3. This routine must be located in Fixed Fixed memory so its address can be called without caring about the bank registers. The SVCT3 (Service Timer 3) is an extension (maybe a little hard-coded pollution) on the WAITLIST to auto schedule an IMU job with the EXECUTIVE.

Also the WAITLIST Module does not provide these initialization services. So if you desire to create your own AGC code and use the WAITLIST then you still need to write the LST1 and LST2 initialization routines.

#### 1.2.1.2 Task Dispatching ####
The dispatching and running of a task is quite simple. The TIMER3 is counting down to zero and is set by the WAITLIST schedule function (to be discussed later) to the remaining time in centi-seconds for the next required task activation. When TIMER3 expires the T3RUPT interrupt vector at octal address  04014 is called which transfers control to the WAITLIST's T3RUPT service handler. The WAITLIST module takes the next delta time from the top of LST1 (i.e. index 0) and stores this in TIME3 (i.e. the value to set timer 3 to) and moves each entry in the array LST1 one level up meaning the value of index 7 moves to index 6 and so on. The bottom of the LST1 array (i.e. index 7 ) will be filled with octal 020000 again as was done during initialization. Since LST2 must remain sync'ed the top (i.e. index 0) of LST2 becomes the 2CADR address of the task to call and the bottom gets filled with ENDTASK. Once the WAITLIST has the task 2CADR it can set the bank registers and make the call to the task.

With a single opcode (i.e. DTFB) and the 2CADR loaded in the proper registers (i.e. A must contain the value for the Z register and L the value for the BB register) the AGC can switch both banks and transfer control to the task address. What is note worthy is that a task runs in the context of the TIMER3 interrupt and hence is never allowed to execute longer than the max value of timer3 and to avoid task overruns should never executed longer than the desired delta time to start the next task. This is the reason why the tasks must be short of duration.

When a task is finished executing it must end by calling the WAITLIST's TASKOVER routine. This routine checks if another task must immediately be scheduled again. If a task is ready TASKOVER will call the WAITLIST's T3RUPT service handler again otherwise it will restore the registers to the state prior to the handling of the TIMER3 interrupt. It will finalize by enabling the interrupts again followed by the RESUME call which restores the program counter from ZRUPT back to the Z register and executes the instruction in the BRUPT register before returning. The reason why the instruction in the BRUPT is executed is related to the fact that the AGC uses INDEX and extended instructions. In simple terms the execution resumes from where the interrupt occurred.

#### 1.2.1.3 Adding a Task ####
To add a task to the wait-list (i.e. LST1 and LST2) a routine (named WAITLIST) was provided as part of the WAITLIST-module which required some operand/argument passing and enabling of the interrupts after return from the WAITLIST routine.  Here is the API description from the code:

```
WAITLIST CALLING SEQUENCE --
   L-1    CA     DELTAT     (TIME IN CENTISECONDS TO TASK START)
   L      TC     WAITLIST
   L+1    2CADR  DESIRED TASK
   L+2                      (MINOR OF 2CADR)
   L+3    RELINT            (RETURNS HERE)
```

Lets look at these lines marked with L and the line relative position indicator from the call to WAITLIST. From the initialization section it might already be obvious; we need two arguments: First the time in centi-seconds from present till desired task start which must be loaded into the register A. Second the start address of the task itself must be provided in the 2CADR format in program memory right after the call to the WAITLIST's WAITLIST routine. The caller is responsible for enabling the interrupts which are blocked by the WAITLIST call to prevent dispatching to a task in the process of being added to the wait-list. There exist in the WAITLIST module an optimized version of the WAITLIST routine called TWIDDLE which can be used if no bank switching is required.

How to determine DELTAT for your task. This sounds easy and straight forward in that you want it x centi-seconds from now. However There is time involved to add you to the wait list and load the time in TIME3 for both the WAITLIST routine and the T3RUPT service handler. As a result the determination of Delta-T requires adjusting to the delays introduced in the handling process. The actual time until task execution can be approximated by the function:

_Delta-A = T<sub>setup</sub> + Delta-T - T<sub>variance</sub> + T<sub>interrupt</sub> + T<sub>tasks</sub>  + T<sub>waitlist</sub>_

Where:
|T<sub>setup</sub>    |Time of the TC WAITLIST + 147us + Counter increments|
|:--------------------|:---------------------------------------------------|
|T<sub>variance</sub> | The average variation of Timesetup (take about 100 samples)|
|T<sub>interrupt</sub>|Length of Time of inhibit interrupt after T3RUPT|
|T<sub>tasks</sub>    |Length of Time to process tasks in T3RUPT but dispatched earlier (usually 0)|
|T<sub>waitlist</sub> |Time of the WAITLIST (i.e. 1.05 ms) plus the counter ticking during the WAITLIST time|

Now lets look at what the WAITLIST routine does. The WAITLIST routine must insert your new task into the Wait list by updating the arrays LST1 and LST2. The Array LST1 is a list of cumulative Delta-T's meaning that the delta T in `LST1[0]` is deminished already by the value of the TIME3 when it was added. So if a new task is inserted after `LST1[4]` then the delta-T for this new task which was passed as an argument must be diminished by the values of `LST1[0:3]`; meaning the sum of TIME3 and the preceding LST1 entries equal the requested Delta-T. Note that the WAITLIST inserts entries into LST1 and so with our preceding example it requires LST1 entries after the insertion point to be updated. After LST1 is updated LST2 gets updated so the LST2 is again in sync (but remember one index off) with the 2CADR for the task. If the wait-list is full then a program alarm is again generated with alarm code 1203.

#### 1.2.1.4 Writing your Task Code ####
To write your own periodic scheduled task you need to create your own task routine and end with the call to TASKOVER and to continously get scheduled you must also call the WAITLIST again with your delta-t for the next schedule time. If you are using rate monotonic scheduling then your delta-T will always be the same value. As an exercise you can write your own AGC code using the existing WAITLIST module as your OS scheduler and create two tasks.

### 1.2.2 The EXECUTIVE ###
(Still Writing)

## 1.3 The Interpreter ##
(Still Writing)