/*
 Copyright 2003-2005,2009,2016 Ronald S. Burkey <info@sandroid.org>
 
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
 * In addition, as a special exception, permission is granted to
 * link the code of this program with the Orbiter SDK library (or with
 * modified versions of the Orbiter SDK library that use the same license as
 * the Orbiter SDK library), and distribute linked combinations including
 * the two. You must obey the GNU General Public License in all respects for
 * all of the code used other than the Orbiter SDK library. If you modify
 * this file, you may extend this exception to your version of the file,
 * but you are not obligated to do so. If you do not wish to do so, delete
 * this exception statement from your version.
 *
 * Filename:	agc_engine.c
 * Purpose:	This is the main engine for binary simulation of the Apollo AGC
 *  		computer.  It is separate from the Display/Keyboard (DSKY)
 *  		simulation and Apollo hardware simulation, though compatible
 *  		with them.  The executable binary may be created using the
 *  		yayul (Yet Another YUL) assembler.
 * Compiler:	GNU gcc.
 * Contact:	Ron Burkey <info@sandroid.org>
 * Reference:	http://www.ibiblio.org/apollo/index.html
 * Mods:	04/05/03 RSB.	Began.
 *   		08/20/03 RSB.	Now bitmasks are handled on input channels.
 *   		11/26/03 RSB.	Up to now, a pseudo-linear space was used to
 *   				model internal AGC memory.  This was simply too
 *   				tricky to work with, because it was too hard to
 *   				understand the address conversions that were
 *   				taking place.  I now use a banked model much
 *   				closer to the true AGC memory map.
 *   		11/28/03 RSB.	Added code for a bunch of instruction types,
 *   				and fixed a bunch of bugs.
 *   		11/29/03 RSB.	Finished out all of the instruction types.
 *   				Still a lot of uncertainty if Overflow
 *   				and/or editing has been handled properly.
 *   				Undoubtedly many bugs.
 *   		05/01/04 RSB	Now makes sure that in --debug-dsky mode
 *   				doesn't execute any AGC code (since there
 *   				isn't any loaded anyhow).
 *   		05/03/04 RSB	Added a workaround for "TC Q".  It's not
 *   				right, but it has to be more right than
 *   				what was there before.
 *   		05/04/04 RSB	Fixed a bug in CS, where the unused bit
 *   				could get set and therefore mess up
 *   				later comparisons.  Fixed an addressing bug
 *   				(was 10-bit but should have been 12-bit) in
 *   				the AD instruction.  DCA was completely
 *   				messed up (still don't know about overflow).
 *   		05/05/04 RSB	INDEX'ing was messed up because the pending
 *				index was zeroed before being completely
 *				used up.  Fixed the "CCS A" instruction.
 *				Fixed CCS in the case of negative compare-
 *				values.
 *		05/06/04 RSB	Added rfopen.  The operation of "DXCH L"
 *				(which is ambiguous in the docs but actually
 *				used --- at Luminary131 address 33,03514) ---
 *				has been redefined in accordance with the
 *				Luminary program's comments.  Adjusted
 *				"CS A" and "CA A", though I don't actually
 *				think they work differently.  Fixed a
 *				potential divide-by-0 in DV.
 *		05/10/04 RSB	Fixed up i/o channel operations so that they
 *				properly use AGC-formatted integers rather
 *				than the simulator's native-format integers.
 *		05/12/04 RSB	Added the data collection for backtraces.
 *		05/13/04 RSB	Corrected calculation of the superbank address.
 *		05/14/04 RSB	Added interrupt service and hopefully fixed the
 *				RESUME instruction.  Fixed a bunch of instructions
 *				(but not all, since I couldn't figure out how to
 *				consistently do it) that modify the Z register.
 *		05/15/04 RSB	Repaired the interrupt vector and the RESUME
 *				instruction, so that they do not automatically
 *				save/restore A, L, Q, and BB to/from
 *				ARUPUT, LRUPT, QRUPT, and BBRUPT.  The ISR
 *				is supposed to do that itself, if it wants
 *				it done. And (sigh!) the RESUME instruction
 *				wasn't working, but was treated as INDEX 017.
 *		05/17/04 RSB	Added MasterInterruptEnable.  Added updates of
 *				timer-registers TIME1 and TIME2, of TIME3 and
 *				TIME4, and of SCALER1 and SCALER2.
 *		05/18/04 RSB	The mask used for writing to channel 7 have
 *				changed from 0100 to 0160, because the
 *				Luminary131 source (p.59) claims that bits
 *				5-7 are used.  I don't know what bits 5-6
 *				are for, though.
 *		05/19/04 RSB	I'm beginning to grasp now what to do for
 *				overflow.  The AD instruction (in which
 *				overflow was messed up) and the TS instruction
 *				(which was completely bollixed) have hopefully
 *				been fixed now.
 *		05/30/04 RSB	Now have a spec to work from (my assembly-
 *				language manual).  Working to bring this code
 *				up to v0.50 of the spec.
 *		05/31/04 RSB	The instruction set has basically been completely
 *				rewritten.
 *		06/01/04 RSB	Corrected the indexing of instructions
 *				for negative indices.  Oops!  The instruction
 *				executed on RESUME was taken from BBRUPT
 *				instead of BRUPT.
 *		06/02/04 RSB	Found that I was using an unsigned datatype
 *				for EB, FB, and BB, thus causing comparisons of
 *				them to registers to fail.  Now autozero the
 *				unused bits of EB, FB, and BB.
 *		06/04/04 RSB	Separated ServerStuff function from agc_engine
 *				function.
 *		06/05/04 RSB	Fixed the TCAA, ZQ, and ZL instructions.
 *		06/11/04 RSB	Added a definition for uint16_t in Win32.
 *		06/30/04 RSB	Made SignExtend, AddSP16, and
 *				OverflowCorrected non-static.
 *		07/02/04 RSB	Fixed major bug in SU instruction, in which it
 *				not only used the wrong value, but overwrote
 *				the wrong location.
 *		07/04/04 RSB	Fixed bug (I hope) in converting "decent"
 *				to "DP".  The DAS instruction did not leave the
 *				proper values in the A,L registers.
 *		07/05/04 RSB	Changed DXCH to do overflow-correction on the
 *				accumulator.  Also, the special cases "DXCH A"
 *				and "DXCH L" were being checked improperly
 *				before, and therefore were not treated
 *				properly.
 *		07/07/04 RSB	Some cases of DP arithmetic with the MS word
 *				or LS word being -0 were fixed.
 *		07/08/04 RSB	CA and CS fixed to re-edit after doing their work.
 *				Instead of using the overflow-corrected
 *				accumulator, BZF and BZMF now use the complete
 *				accumulator.  Either positive or negative
 *				overflow blocks BZF, while positive overflow
 *				blocks BZMF.
 *		07/09/04 RSB	The DAS instruction has been completely rewritten
 *				to alter the relative signs of the output.
 *				Previously they were normalized to be identical,
 *				and this is wrong.  In the DV instruction, the
 *				case of remainder==0 needed to be fixed up to
 *				distinguish between +0 and -0.
 *		07/10/04 RSB	Completely replaced MSU.  And ... whoops! ...
 *				forgot to inhibit interrupts while the
 *				accumulator contains overflow.  The special
 *				cases "DCA L" and "DCS L" have been addressed.
 *				"CCS A" has been changed similarly to BZF and
 *				BZMF w.r.t. overflow.
 *		07/12/04 RSB	Q is now 16 bits.
 *		07/15/04 RSB	Pretty massive rewrites:  Data alignment changed
 *				to bit 0 rather than 1.  All registers at
 *				addresses less than REG16 are now 16 bits,
 *				rather than just A and Q.
 *		07/17/04 RSB	The final contents of L with DXCH, DCA, and
 *				DCS are now overflow-corrected.
 *		07/19/04 RSB	Added SocketInterlace/Reload.
 *		08/12/04 RSB	Now account for output ports that are latched
 *				externally, and for updating newly-attached
 *				peripherals with current i/o-port values.
 *		08/13/04 RSB	The Win32 version of yaAGC now recognizes when
 *				socket-disconnects have occurred, and allows
 *				the port to be reused.
 *		08/18/04 RSB	Split off all socket-related stuff into
 *				SocketAPI.c, so that a cleaner API could be
 *				available for integrators.
 *		02/27/05 RSB	Added the license exception, as required by
 *				the GPL, for linking to Orbiter SDK libraries.
 *		05/14/05 RSB	Corrected website references.
 *		05/15/05 RSB	Oops!  The unprogrammed counter increments were
 *				hooked up to i/o space rather than to
 *				erasable.  So incoming counter commands were
 *				ignored.
 *		06/11/05 RSB	Implemented the fictitious output channel 0177
 *				used to make it easier to implement an
 *				emulation of the gyros.
 *		06/12/05 RSB	Fixed the CounterDINC function to emit a
 *				POUT, MOUT, or ZOUT, as it is supposed to.
 *		06/16/05 RSB	Implemented IMU CDU drive output pulses.
 *		06/18/05 RSB	Fixed PINC/MINC at +0 to -1 and -0 to +1
 *				transitions.
 *		06/25/05 RSB	Fixed the DOWNRUPT interrupt requests.
 *		06/30/05 RSB	Hopefully fixed fine-alignment, by making
 *				the gyro torquing depend on the GYROCTR
 *				register as well as elapsed time.
 *		07/01/05 RSB	Replaced the gyro-torquing code, to
 *				avoid simulating the timing of the
 *				3200 pps. pulses, which was conflicting
 *				somehow with the timing Luminary wanted
 *				to impose.
 *		07/02/05 RSB	OPTXCMD & OPTYCMD.
 *		07/04/05 RSB	Fix for writes to channel 033.
 *		08/17/05 RSB	Fixed an embarrassing bug in SpToDecent,
 *				thanks to Christian Bucher.
 *		08/20/05 RSB	I no longer allow interrupts when the
 *				program counter is in the range 0-060.
 *				I do this principally to guard against the
 *				case Z=0,1,2, since I'm not sure that all of
 *				the AGC code saves registers properly in this
 *				case.  Now I inhibit interrupts prior to
 *				INHINT, RELINT, and EXTEND (as we're supposed
 *				to), as well as RESUME (as we're not supposed
 *				to).  The intent of the latter is to take
 *				care of problems that occur when EDRUPT is used.
 *				(Specifically, an interrupt can occur between
 *				RELINT and RESUME after an EDRUPT, and this
 *				messes up the return address in ZRUPT used by
 *				the RESUME.)
 *		08/21/05 RSB	Removed the interrupt inhibition from the
 *				address range 0-060, because it prevented
 *				recovery from certain conditions.
 *		08/28/05 RSB	Oops!  Had been using PINC sequences on
 *				TIME6 rather than DINC sequences.
 *		10/05/05 RSB	FIFOs were introduced for PCDU or MCDU
 *				commands on the registers CDUX, CDUY, CDUZ.
 *				The purpose of these FIFOs is to make sure
 *				that CDUX, CDUY, CDUZ are updated at no
 *				more than an 800 cps rate, in order to
 *				avoid problems with the Kalman filter in the
 *				DAP, which is otherwise likely to reject
 *				counts that change too quickly.
 *		10/07/05 RSB	FIFOs changed from 800 cps to either 400 cps
 *				("low rate") or 6400 cps ("high rate"),
 *				depending on the variable CduHighRate.
 *				At the moment, CduHighRate is stuck at 0,
 *				because we've worked out no way to plausibly
 *				change it.
 *		11/13/05 RSB	Took care of auto-adjust buffer timing for
 *				high-rate and low-rate CDU counter updates.
 *				PCDU/MCDU commands 1/3 are slow mode, and
 *				PCDU/MCDU commands 021/023 are fast mode.
 *		02/26/06 RSB	Oops!  This wouldn't build under Win32 because
 *				of the lack of an int32_t datatype.  Fixed.
 *		03/30/09 RSB	Moved Downlink local static variable from
 *				CpuWriteIO() to agc_t, trying to overcome the
 *				lack of resumption of telemetry after an AGC
 *				resumption in Windows.
 *		07/17/16 RSB	Commented out a variable that wasn't being
 *				used but was generating compiler warnings.
 *		08/31/16 MAS	Corrected implementation of DINC and TIME6.
 *				DINC now uses AddSP16() to do its math. T6RUPT
 *				can only be triggered by a ZOUT from DINC. TIME6
 *				only counts when enabled, and is disabled upon
 *				triggering T6RUPT.
 *		09/08/16 MAS	Added a special case for DV -- when the dividend
 *				is 0 and the divisor is not, the quotient and
 *				remainder are both 0 with the sign matching the
 *				dividend.
 *		09/11/16 MAS	Applied Gergo's fix for multi-MCT instructions
 *				taking a cycle longer than they should.
 *		09/30/16 MAS	Added emulation of the Night Watchman, TC Trap,
 *		                and Rupt Lock hardware alarms, alarm-generated 
 *		                resets, and the CH77 restart monitor module.
 *		10/01/16 RSB	Moved location of "int ExecutedTC = 0" to the
 *				top of the function, since it triggered compiler
 *				warnings (and hence errors) for me.  (The
 *				"goto AllDone" jumped over it, leaving
 *				ExecutedTC potentially uninitialized.)
 *		10/01/16 MAS	Added a corner case to one of DV's corner cases
 *				(0 / 0), made CCS consider overflow before the
 *				diminished absolute value calculation, changed
 *				how interrupt priorities are handled, and
 *				corrected ZRUPT to be return addr+1.
 *				Aurora 12 now passes all of SELFCHK in yaAGC.
 *		10/04/16 MAS	Added support for standby mode, added the
 *				standby light to the light test, and fixed
 *				the speed of scaler counting and phasing of
 *				TIME6.
 *		11/12/16 MAS	Stopped preventing interrupts on Q and L
 *				overflow (only A overflow should do so). This
 *				was causing the O-UFLOW check in Validation
 *				to never allow interrupts, triggering a rupt
 *				lock alarm.
 *		11/12/16 MAS	Apparently CH11 bit 10 only turns off RESTART
 *				*on write*, with the actual value of the
 *				channel being otherwise  meaningless.
 *		12/19/16 MAS	Corrected one more bug in the DV instruction;
 *				the case of a number being divided by itself
 *				was not sign-extending the result in the L
 *				register. The overflow correction of the L
 *				register was then destroying the calculated
 *				sign. This was caught by Retread; apparently
 *				Aurora doesn't test for it.
 *		12/22/16 MAS	Fixed the No TC hardware alarm, discovered
 *				to be erroneously counting EXTENDS by
 *				BOREALIS.
 *		01/04/17 MAS	Added parity fail alarms caused by accessing
 *				nonexistent superbanks. There's still no way
 *				to get an erasable parity fail, because I
 *				haven't come up with a program that can cause
 *				one to happen.
 *		01/08/17 MAS	Corrected behavior of the EDRUPT instruction
 *				(it really is just a generic interrupt request).
 *				Along the way, re-enabled BRUPT substitution by
 *				default and allowed interrupts to happen after
 *				INDEXes.
 *		01/29/17 MAS	Hard-wired the DKSY's RSET button to turning
 *				off the RESTART light (the button had its
 *				own discrete to reset the RESTART flip flop
 *				in the real AGC/DSKY).
 *		01/30/17 MAS	Added parity bit checking for fixed memory
 *				when running with a ROM that contains
 *				parity bits.
 *		03/09/17 MAS	Prevented yaAGC from exiting standby if PRO is
 *				still held down from entry to standby. Also
 *				corrected turning off of RESTART, and in the
 *				process improved DSKY light latency. Last,
 *				added a new channel 163 bit that indicates
 *				power for the DSKY EL panel is switched off.
 *		03/11/17 MAS	Further improved DSKY light responsiveness,
 *				and split the logic out to its own function
 *				as a bit of housekeeping.
 *		03/26/17 MAS	Made several previously-static things a part
 *				of the agc_t state structure, which should
 *				make integration easier for simulator
 *				integrators.
 *		03/27/17 MAS	Fixed parity checking for superbanks, and added
 *				simulation of the Night Watchman's assertion of
 *				its channel 77 bit for 1.28 seconds after each
 *				triggering.
 *		04/02/17 MAS	Added simulation of a hardware bug in the
 *				design of the "No TCs" part of the TC Trap.
 *				Most causes of transients that can reset
 *				the alarm are now accounted for. Also
 *				corrected the phasing of the standby circuit
 *				and TIME1-TIME5 relative the to the scaler.
 *				With the newly corrected timer phasings,
 *				Aurora/Sunburst's self-tests cannot pass
 *				without simulation of the TC Trap bug.
 *		04/16/17 MAS	Added a simple linear model of the AGC warning
 *				filter, and added the AGC (CMC/LGC) warning
 *				light status to DSKY channel 163. Also added
 *				proper handling of the channel 33 inbit that
 *				indicates such a warning occurred.
 *		05/11/17 MAS	Moved special cases for writing to I/O channels
 *				from WriteIO into CpuWriteIO, allowing those
 *				channels to be safely written to via WriteIO
 *				by external callers (e.g. SocketAPI and NASSP).
 *		05/16/17 MAS	Made alarm restarts enable interrupts.
 *		07/13/17 MAS	Added simulation of HANDRUPT, as generated by
 *				any of three traps, which monitor various bits
 *				in channels 31 and 32.
 *		08/19/17 MAS	Made GOJAMs clear all pending interrupt requests,
 *				as well as a bunch of output channels and one
 *				input bit. Not doing so was preventing the DSKY
 *				RESTART light from working in Colossus 249 and
 *				all later CMC versions.
 *		09/03/17 MAS	Slightly tweaked handling of Z, so (as before)
 *				higher order bits typically disappear, but
 *				(newly) are visible if you're clever with
 *				use of ZRUPT. Also, made GOJAMs transfer the
 *				Z register value to Q on restart, which makes
 *				the RSBBQ erasables in Colossus/Luminary work.
 *		09/04/17 MAS	Extended emulation of DV to properly handle all
 *				off-nominal situations, including overflow in
 *				the divisor as well as all situations that create
 *				"total nonsense" as described by Savage&Drake
 *				(we previously simply returned random values).
 *		09/27/17 MAS	Fixed standby, which was broken by the GOJAM
 *				update. All I/O channels are held in their reset
 *				state via an ever-present GOJAM during standby,
 *				but the standby enabled bit (CH13 bit 11) is not
 *				required to be set to exit standby, only to enter.
 *		01/06/18 MAS	Added a new channel 163 bit for the TEMP light,
 *				which is the logical OR of channel 11 bit 4 and
 *				channel 30 bit 15. The AGC did this internally
 *				so the light would still work in standby.
 *		01/28/18 MAS	Large refactor, mostly focused on cleaing up and
 *				streamlining the scaler logic, and impelementing
 *				the basics of counter cell processing. All of the
 *				counters should now be processed correctly at
 *				cycle-accurate times, if requests are generated
 *				for them. No new counters have been implemented
 *				yet, but they will be soon. I also cleaned up a
 *				lot of old cruft in the process. Other changes:
 *				* Added input voltage monitoring and voltage
 *				alarm simulation for use by NASSP and other
 *				integrated spacecraft simulations.
 *				* Added both halves of the counter alarm (only
 *				count instructions executed, or one not executed
 *				immediately after being requested).
 *				* Reorganized the order of operations in
 *				agc_engine() so all activities have the correct
 *				priority -- GOJAM > counts > rupts > instructions.
 *				* Made INHINT, RELINT, and EXTEND prevent counts
 *				or interrupts from happening if they are the next
 *				instruction to be executed, since they are really
 *				"pseudo-instructions" that extend the length of
 *				the preceding instruction by 1 MCT.
 *				* Moved instruction effects ot the first MCT,
 *				rather than the last, for multi-MCT instructions.
 *				This is much closer to the truth, generally, and
 *				makes priority simulation easier.
 *				* Made BZF and BZMF take an extra MCT if their
 *				branches are not taken, which we had missed.
 *		01/30/18 MAS	Added simulation of the RHC X,Y,Z counters.
 *				Inputs to them are specified in Vp millivolts,
 *				maxing out at 3.96 volts.
 *		01/31/18 MAS	Added simulation of complete radar cycles.
 *				RADARUPTs are now generated internally, after
 *				the new data has been SHINCed and SHANCed into
 *				the RNRAD counter. The time taken to send gating
 *				pulses to the radars is simulated, but the pulses
 *				themselves are not. Also added descriptive macros
 *				for interrupt numbers, so I don't have to keep
 *				looking them up.
 *		02/01/18 MAS	Simulated the GYROCMD output counter. It doesn't
 *				check for the target gyro at the moment, which
 *				may be something we'll want to do, depending on
 *				what is most useful for integrators. Also added
 *				simulation of the five CDU drive counters.
 *
 *
 * The technical documentation for the Apollo Guidance & Navigation (G&N) system,
 * or more particularly for the Apollo Guidance Computer (AGC) may be found at
 * http://hrst.mit.edu/hrs/apollo/public.  That is, to the extent that the
 * documentation exists online it may be found there.  I'm sure -- or rather
 * HOPE -- that there's more documentation at NASA and MIT than has been made
 * available yet.  I personally had no knowledge of the AGC, other than what
 * I had seen in the movie "Apollo 13" and the HBO series "From the Earth to
 * the Moon", before I conceived this project last night at midnight and
 * started doing web searches.  So, bear with me; it's a learning experience!
 *
 * Also at hrst.mit.edu are the actual programs for the Command Module (CM) and
 * Lunar Module (LM) AGCs.  Or rather, what's there are scans of 1700-page
 * printouts of assembly-language listings of SOME versions of those programs.
 * (Respectively, called "Colossus" and "Luminary".)  I'll worry about how to
 * get those into a usable version only after I get the CPU simulator working!
 *
 * What THIS file contains is basically a pure simulation of the CPU, without any
 * input and output as such.  (I/O, to the DSKY or to CM or LM hardware
 * simulations occurs through the mechanism of sockets, and hence the DSKY
 * front-end and hardware back-end simulations may be implemented as complete
 * stand-alone programs and replaced at will.)  There is a single globally
 * interesting function, called agc_engine, which is intended to be called once
 * per AGC instruction cycle -- i.e., every 11.7 microseconds.  (Yes, that's
 * right, the CPU clock speed was a little over 85 KILOhertz.  That's a factor
 * that obviously makes the simulation much easier!)  The function may be called
 * more or less often than this, to speed up or slow down the apparent passage
 * of time.
 *
 * This function is intended to be completely portable, so that it may be run in
 * a PC environment (Microsoft Windows) or in any *NIX environment, or indeed in
 * an embedded target if anybody should wish to create an actual physical
 * replacement for an AGC.  Also, multiple copies of the simulation may be run
 * on the same PC -- for example to simulation a CM and LM simultaneously.
 */

#define AGC_ENGINE_C
//#include <errno.h>
//#include <stdlib.h>
#include <stdio.h>
#ifdef WIN32
typedef unsigned short uint16_t;
typedef int int32_t;
#endif
#include "yaAGC.h"
#include "agc_engine.h"
#include "agc_symtab.h"

// Some helpful macros for manipulating registers.
#define c(Reg) State->Erasable[0][Reg]
#define IsA(Address) ((Address) == RegA)
#define IsL(Address) ((Address) == RegL)
#define IsQ(Address) ((Address) == RegQ)
#define IsEB(Address) ((Address) == RegEB)
#define IsZ(Address) ((Address) == RegZ)
#define IsReg(Address,Reg) ((Address) == (Reg))

// Some helpful constants in parsing the "address" field from an instruction 
// or from the Z register.
#define MASK9       000777
#define MASK10      001777
#define MASK12      007777

// Some numerical constant, in AGC format. 
#define AGC_P0 ((int16_t) 0)
#define AGC_M0 ((int16_t) 077777)
#define AGC_P1 ((int16_t) 1)
#define AGC_M1 ((int16_t) 077776)

// Here are arrays which tell (for each instruction, as determined by the
// uppermost 5 bits of the instruction) how many extra machine cycles are 
// needed to execute the instruction.  (In other words, the total number of
// machine cycles for the instruction, minus 1.) The opcode and quartercode
// are taken into account.  There are two arrays -- one for normal 
// instructions and one for "extracode" instructions.
static const int InstructionTiming[32] =
  { 0, 0, 0, 0,			// Opcode = 00.
    1, 0, 0, 0,			// Opcode = 01.
    2, 1, 1, 1,			// Opcode = 02.
    1, 1, 1, 1,			// Opcode = 03.
    1, 1, 1, 1,			// Opcode = 04.
    1, 2, 1, 1,			// Opcode = 05.
    1, 1, 1, 1,			// Opcode = 06.
    1, 1, 1, 1			// Opcode = 07.
  };

// Note that the following table does not properly handle the EDRUPT or
// BZF/BZMF instructions, and extra delay may need to be added specially for
// those cases.  The table figures 2 MCT for EDRUPT and 1 MCT for BZF/BZMF.
static const int ExtracodeTiming[32] =
  { 1, 1, 1, 1,			// Opcode = 010.
    5, 0, 0, 0,			// Opcode = 011.
    1, 1, 1, 1,			// Opcode = 012.
    2, 2, 2, 2,			// Opcode = 013.
    2, 2, 2, 2,			// Opcode = 014.
    1, 1, 1, 1,			// Opcode = 015.
    1, 0, 0, 0,			// Opcode = 016.
    2, 2, 2, 2			// Opcode = 017.
  };

// A way, for debugging, to disable interrupts. The 0th entry disables 
// everything if 0.  Entries 1-10 disable individual interrupts.
int DebuggerInterruptMasks[11] =
  { 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 };

//-----------------------------------------------------------------------------
// Stuff for doing structural coverage analysis.  Yes, I know it could be done
// much more cleverly.

int CoverageCounts = 0;			// Increment coverage counts is != 0.
unsigned ErasableReadCounts[8][0400];
unsigned ErasableWriteCounts[8][0400];
unsigned ErasableInstructionCounts[8][0400];
unsigned FixedAccessCounts[40][02000];
unsigned IoReadCounts[01000];
unsigned IoWriteCounts[01000];

//-----------------------------------------------------------------------------
// Warning filter parameters.
#define WARNING_FILTER_INCREMENT  15000
#define WARNING_FILTER_DECREMENT     15
#define WARNING_FILTER_MAX       140000
#define WARNING_FILTER_THRESHOLD  20000

//-----------------------------------------------------------------------------
// Functions for reading or writing from/to i/o channels.  The reason we have
// to provide a function for this rather than accessing the i/o-channel buffer
// directly is that the L and Q registers appear in both memory and i/o space,
// at the same addresses. 

int
ReadIO (agc_t * State, int Address)
{
  if (Address < 0 || Address > 0777)
    return (0);
  if (CoverageCounts)
    IoReadCounts[Address]++;
  if (Address == RegL || Address == RegQ)
    return (State->Erasable[0][Address]);
  return (State->InputChannel[Address]);
}

void
WriteIO (agc_t * State, int Address, int Value)
{
  // The value should be in AGC format. 
  Value &= 077777;
  if (Address < 0 || Address > 0777)
    return;
  if (CoverageCounts)
    IoWriteCounts[Address]++;
  if (Address == RegL || Address == RegQ)
    State->Erasable[0][Address] = Value;

  if (Address == 010)
    {
      // Channel 10 is converted externally to the CPU into up to 16 ports,
      // by means of latching relays.  We need to capture this data.
      State->OutputChannel10[(Value >> 11) & 017] = Value;
    }
  else if ((Address == 015 || Address == 016) && Value == 022)
    {
      // RSET being pressed on either DSKY clears the RESTART light
      // flip-flop directly, without software intervention
      State->RestartLight = 0;
    }
  else if (Address == 031)
    {
      if ((State->InputChannel[031] & 000077) == 000077)
        State->Trap31APending = 0;

      if ((State->InputChannel[031] & 007700) != 007700)
        State->Trap31BPending = 0;
    }
  else if (Address == 032)
    {
      if ((State->InputChannel[032] & 001777) != 001777)
        State->Trap32Pending = 0;
    }
  else if (Address == 033)
    {
      // Channel 33 bits 11-15 are controlled internally, so don't let
      // anybody write to them
      Value = (State->InputChannel[Address] & 076000) | (Value & 001777);
    }

  State->InputChannel[Address] = Value;
}

void
CpuWriteIO (agc_t * State, int Address, int Value)
{
  //static int Downlink = 0;

  if (Address == 013)
    {
      // Enable the appropriate traps for HANDRUPT. Note that the trap
      // settings cannot be read back out, so after setting the traps the
      // enable bits are masked out.
      if (Value & 004000)
        State->Trap31A = 1;
      if (Value & 010000)
        State->Trap31B = 1;
      if (Value & 020000)
        State->Trap32 = 1;

      Value &= 043777;
    }
  if (Address == 033)
    {
      // 2005-07-04 RSB.  The necessity for this was pointed out by Mark 
      // Grant via Markus Joachim.  Although channel 033 is an input channel,
      // the CPU writes to it from time to time, to "reset" bits 11-15 to 1.
      // Apparently, these are latched inputs, and this resets the latches.
      State->InputChannel[Address] |= 076000;

      // Don't allow the AGC warning input to be reset if the light
      // is still on
      if (State->WarningFilter > WARNING_FILTER_THRESHOLD)
        State->InputChannel[Address] &= 057777;

      // The actual value that was written now doesn't matter, so make sure
      // no changes occur.
      Value = State->InputChannel[Address];
    }
  else if (Address == 077)
    {
      // Similarly, the CH77 Restart Monitor Alarm Box has latches for
      // alarm codes that are reset when CH77 is written to.
      Value = 0;

      // If the Night Watchman was recently tripped, its CH77 bit
      // is forcibly asserted (unlike all the others) for 1.28s
      if (State->NightWatchmanTripped)
        Value |= CH77_NIGHT_WATCHMAN;
    }
  else if (Address == 011 && (Value & 01000))
    {
      // The DSKY RESTART light is reset whenever CH11 bit 10 is written
      // with a 1. The controlling flip-flop in the AGC also has a hard
      // line to the DSKY's RSET button, so on depression of RSET the
      // light is turned off without need for software intervention.
      State->RestartLight = 0;
    }

  WriteIO (State, Address, Value);
  ChannelOutput (State, Address, Value & 077777);

  // 2005-06-25 RSB.  DOWNRUPT stuff.  I assume that the 20 ms. between
  // downlink transmissions is due to the time needed for transmitting,
  // so I don't interrupt at a regular rate,  Instead, I make sure that
  // there are 20 ms. between transmissions
  if (Address == 034)
    State->Downlink |= 1;
  else if (Address == 035)
    State->Downlink |= 2;
  if (State->Downlink == 3)
    {
      //State->InterruptRequests[8] = 1;	// DOWNRUPT.
      State->DownruptTimeValid = 1;
      State->DownruptTime = State->CycleCounter + (AGC_PER_SECOND / 50);
      State->Downlink = 0;
    }
}

//-----------------------------------------------------------------------------
// This function sets the input voltage for the AGC, for integrated simulations
// like Orbiter/NASSP. It takes in millivolts, and sets the voltage fail alarm
// circuit appropriately.
void
SetInputVoltage(agc_t * State, int Millivolts)
{
  State->InputVoltagemV = Millivolts;
  if (Millivolts >= VFAIL_THRESHOLD)
    State->InputVoltageLow = 0;
}

//-----------------------------------------------------------------------------
// This function does all of the processing associated with converting a 
// 12-bit "address" as used within instructions or in the Z register, to a
// pointer to the actual word in the simulated memory.  In other words, here
// we take memory bank-selection into account.  

static int16_t *
FindMemoryWord (agc_t * State, int Address12)
{
  //int PseudoAddress;
  int AdjustmentEB, AdjustmentFB;
  int16_t *Addr;

  // Get rid of the parity bit.
  //Address12 = Address12;

  // Make sure the darn thing really is 12 bits.
  Address12 &= 07777;

  // Check to see if NEWJOB (67) has been accessed for Night Watchman
  if (Address12 == 067)
  {
    // Address 67 has been accessed in some way. Clear the Night Watchman.
    State->NightWatchman = 0;
  }

  // It should be noted as far as unswitched-erasable and common-fixed memory
  // is concerned, that the following rules actually do result in continuous
  // block of memory that don't have problems in crossing bank boundaries.
  if (Address12 < 00400)	// Unswitched-erasable.
    return (&State->Erasable[0][Address12 & 00377]);
  else if (Address12 < 01000)	// Unswitched-erasable (continued).
    return (&State->Erasable[1][Address12 & 00377]);
  else if (Address12 < 01400)	// Unswitched-erasable (continued).
    return (&State->Erasable[2][Address12 & 00377]);
  else if (Address12 < 02000)	// Switched-erasable.
    {
      // Recall that the parity bit is accounted for in the shift below.
      AdjustmentEB = (7 & (c (RegEB)>> 8));
      return (&State->Erasable[AdjustmentEB][Address12 & 00377]);
    }
  else if (Address12 < 04000)	// Fixed-switchable.
    {
      AdjustmentFB = (037 & (c (RegFB) >> 10));
      // Account for the superbank bit. 
      if (030 == (AdjustmentFB & 030) && (State->OutputChannel7 & 0100) != 0)
      AdjustmentFB += 010;
    }
  else if (Address12 < 06000)	// Fixed-fixed.
  AdjustmentFB = 2;
  else			  // Fixed-fixed (continued).
  AdjustmentFB = 3;

  Addr = (&State->Fixed[AdjustmentFB][Address12 & 01777]);

  if (State->CheckParity)
    {
      // Check parity for fixed memory if such checking is enabled
      uint16_t LinearAddr = AdjustmentFB*02000 + (Address12 & 01777);
      int16_t ExpectedParity = (State->Parities[LinearAddr / 32] >> (LinearAddr % 32)) & 1;
      int16_t Word = ((*Addr) << 1) | ExpectedParity;
      Word ^= (Word >> 8);
      Word ^= (Word >> 4);
      Word ^= (Word >> 2);
      Word ^= (Word >> 1);
      Word &= 1;
      if (Word != 1)
        {
          // The program is trying to access unused fixed memory, which
          // will trigger a parity alarm.
          State->ParityFail = 1;
          State->InputChannel[077] |= CH77_PARITY_FAIL;
        }
    }
  return Addr;
}

// Same thing, basically, but for collecting coverage data.
#if 0
static void
CollectCoverage (agc_t * State, int Address12, int Read, int Write, int Instruction)
{
  int AdjustmentEB, AdjustmentFB;

  if (!CoverageCounts)
  return;

  // Get rid of the parity bit.
  Address12 = Address12;

  // Make sure the darn thing really is 12 bits.
  Address12 &= 07777;

  if (Address12 < 00400)// Unswitched-erasable.
    {
      AdjustmentEB = 0;
      goto Erasable;
    }
  else if (Address12 < 01000)	// Unswitched-erasable (continued).
    {
      AdjustmentEB = 1;
      goto Erasable;
    }
  else if (Address12 < 01400)	// Unswitched-erasable (continued).
    {
      AdjustmentEB = 2;
      goto Erasable;
    }
  else if (Address12 < 02000)	// Switched-erasable.
    {
      // Recall that the parity bit is accounted for in the shift below.
      AdjustmentEB = (7 & (c (RegEB) >> 8));
      Erasable:
      Address12 &= 00377;
      if (Read)
      ErasableReadCounts[AdjustmentEB][Address12]++;
      if (Write)
      ErasableWriteCounts[AdjustmentEB][Address12]++;
      if (Instruction)
      ErasableInstructionCounts[AdjustmentEB][Address12]++;
    }
  else if (Address12 < 04000)	// Fixed-switchable.
    {
      AdjustmentFB = (037 & (c (RegFB) >> 10));
      // Account for the superbank bit. 
      if (030 == (AdjustmentFB & 030) && (State->OutputChannel7 & 0100) != 0)
      AdjustmentFB += 010;
      Fixed:
      FixedAccessCounts[AdjustmentFB][Address12 & 01777]++;
    }
  else if (Address12 < 06000)	// Fixed-fixed.
    {
      AdjustmentFB = 2;
      goto Fixed;
    }
  else				// Fixed-fixed (continued).
    {
      AdjustmentFB = 3;
      goto Fixed;
    }
  return;
}
#endif //0

//-----------------------------------------------------------------------------
// Assign a new value to "erasable" memory, performing editing as necessary
// if the destination address is one of the 4 editing registers.  The value to
// be written is a properly formatted AGC value in D1-15.  The difference between
// Assign and AssignFromPointer is simply that Assign needs a memory bank number
// and an offset into that bank, while AssignFromPointer simply uses a pointer
// directly to the simulated memory location.

static void
Assign (agc_t * State, int Bank, int Offset, int Value)
{
  if (Bank < 0 || Bank >= 8)
    return;			// Non-erasable memory.
  if (Offset < 0 || Offset >= 0400)
    return;
  if (CoverageCounts)
    ErasableWriteCounts[Bank][Offset]++;
  if (Bank == 0)
    {
      switch (Offset)
	{
	case RegZ:
	  State->NextZ = Value;
	  break;
	case RegCYR:
	  Value &= 077777;
	  if (0 != (Value & 1))
	    Value = (Value >> 1) | 040000;
	  else
	    Value = (Value >> 1);
	  break;
	case RegSR:
	  Value &= 077777;
	  if (0 != (Value & 040000))
	    Value = (Value >> 1) | 040000;
	  else
	    Value = (Value >> 1);
	  break;
	case RegCYL:
	  Value &= 077777;
	  if (0 != (Value & 040000))
	    Value = (Value << 1) + 1;
	  else
	    Value = (Value << 1);
	  break;
	case RegEDOP:
	  Value &= 077777;
	  Value = ((Value >> 7) & 0177);
	  break;
	case RegZERO:
	  Value = AGC_P0;
	  break;
	default:
	  // No editing of the Value is needed in this case.
	  break;
	}
      if (Offset >= REG16 || (Offset >= 020 && Offset <= 023))
	State->Erasable[0][Offset] = Value & 077777;
      else
	State->Erasable[0][Offset] = Value & 0177777;
    }
  else
    State->Erasable[Bank][Offset] = Value & 077777;
}

static void
AssignFromPointer (agc_t * State, int16_t * Pointer, int Value)
{
  int Address;
  Address = Pointer - State->Erasable[0];
  if (Address >= 0 && Address < 04000)
    {
      Assign (State, Address / 0400, Address & 0377, Value);
      return;
    }
}

//-----------------------------------------------------------------------------
// Compute the "diminished absolute value".  The input data and output data
// are both in AGC 1's-complement format.

static int16_t
dabs (int16_t Input)
{
  if (0 != (040000 & Input))
    Input = 037777 & ~Input;	// Input was negative, but now is positive.
  if (Input > 1)		// "diminish" it if >1.
    Input--;
  else
    Input = AGC_P0;
  return (Input);
}

// Same, but for 16-bit registers.
static int
odabs (int Input)
{
  if (0 != (0100000 & Input))
    Input = (0177777 & ~Input);	// Input was negative, but now is positive.
  if (Input > 1)		// "diminish" it if >1.
    Input--;
  else
    Input = AGC_P0;
  return (Input);
}

//-----------------------------------------------------------------------------
// Convert an AGC-formatted word to CPU-native format. 

static int
agc2cpu (int Input)
{
  if (0 != (040000 & Input))
    return (-(037777 & ~Input));
  else
    return (037777 & Input);
}

//-----------------------------------------------------------------------------
// Convert a native CPU-formatted word to AGC format. If the input value is
// out of range, it is truncated by discarding high-order bits.

static int
cpu2agc (int Input)
{
  if (Input < 0)
    return (077777 & ~(-Input));
  else
    return (077777 & Input);
}

//-----------------------------------------------------------------------------
// Double-length versions of the same. 

static int
agc2cpu2 (int Input)
{
  if (0 != (02000000000 & Input))
    return (-(01777777777 & ~Input));
  else
    return (01777777777 & Input);
}

static int
cpu2agc2 (int Input)
{
  if (Input < 0)
    return (03777777777 & ~(01777777777 & (-Input)));
  else
    return (01777777777 & Input);
}

// Returns +1, -1, or +0 (in SP) format, on the basis of whether an
// accumulator-style "16-bit" value (really 17 bits including parity)
// contains overflow or not.  To do this for the accumulator itself,
// use ValueOverflowed(GetAccumulator(State)).

static int16_t
ValueOverflowed (int Value)
{
  switch (Value & 0140000)
    {
    case 0040000:
      return (AGC_P1);
    case 0100000:
      return (AGC_M1);
    default:
      return (AGC_P0);
    }
}

// Return an overflow-corrected value from a 16-bit (plus parity ) SP word.
// This involves just moving bit 16 down to bit 15.

int16_t
OverflowCorrected (int Value)
{
  return ((Value & 037777) | ((Value >> 1) & 040000));
}

// Sign-extend a 15-bit SP value so that it can go into the 16-bit (plus parity)
// accumulator.

int
SignExtend (int16_t Word)
{
  return ((Word & 077777) | ((Word << 1) & 0100000));
}

//-----------------------------------------------------------------------------
// Here are functions to convert a DP into a more-decent 1's-
// complement format in which there's not an extra sign-bit to contend with.
// (In other words, a 29-bit format in which there's a single sign bit, rather
// than a 30-bit format in which there are two sign bits.)  And vice-versa.
// The DP value consists of two adjacent SP values, MSW first and LSW second,
// and we're given a pointer to the second word.  The main difficulty here
// is dealing with the case when the two SP words don't have the same sign,
// and making sure all of the signs are okay when one or more words are zero.
// A sign-extension is added a la the normal accumulator.

static int
SpToDecent (int16_t * LsbSP)
{
  int16_t Msb, Lsb;
  int Value, Complement;
  Msb = LsbSP[-1];
  Lsb = *LsbSP;
  if (Msb == AGC_P0 || Msb == AGC_M0)	// Msb is zero.
    {
      // As far as the case of the sign of +0-0 or -0+0 is concerned,
      // we follow the convention of the DV instruction, in which the
      // overall sign is the sign of the less-significant word.
      Value = SignExtend (Lsb);
      if (Value & 0100000)
	Value |= ~0177777;
      return (07777777777 & Value);	// Eliminate extra sign-ext. bits.
    }
  // If signs of Msb and Lsb words don't match, then make them match.
  if ((040000 & Lsb) != (040000 & Msb))
    {
      if (Lsb == AGC_P0 || Lsb == AGC_M0)	// Lsb is zero.
	{
	  // Adjust sign of Lsb to match Msb.
	  if (0 == (040000 & Msb))
	    Lsb = AGC_P0;
	  else
	    Lsb = AGC_M0;	// 2005-08-17 RSB.  Was "Msb".  Oops!
	}
      else			// Lsb is not zero.
	{
	  // The logic will be easier if the Msb is positive.
	  Complement = (040000 & Msb);
	  if (Complement)
	    {
	      Msb = (077777 & ~Msb);
	      Lsb = (077777 & ~Lsb);
	    }
	  // We now have Msb positive non-zero and Lsb negative non-zero.
	  // Subtracting 1 from Msb is equivalent to adding 2**14 (i.e.,
	  // 0100000, accounting for the parity) to Lsb.  An additional 1 
	  // must be added to account for the negative overflow.
	  Msb--;
	  Lsb = ((Lsb + 040000 + AGC_P1) & 077777);
	  // Restore the signs, if necessary.
	  if (Complement)
	    {
	      Msb = (077777 & ~Msb);
	      Lsb = (077777 & ~Lsb);
	    }
	}
    }
  // We now have an Msb and Lsb of the same sign; therefore,
  // we can simply juxtapose them, discarding the sign bit from the 
  // Lsb.  (And recall that the 0-position is still the parity.)
  Value = (03777740000 & (Msb << 14)) | (037777 & Lsb);
  // Also, sign-extend for further arithmetic.
  if (02000000000 & Value)
    Value |= 04000000000;
  return (Value);
}

static void
DecentToSp (int Decent, int16_t * LsbSP)
{
  int Sign;
  Sign = (Decent & 04000000000);
  *LsbSP = (037777 & Decent);
  if (Sign)
    *LsbSP |= 040000;
  LsbSP[-1] = OverflowCorrected (0177777 & (Decent >> 14));	// Was 13.
}

// Adds two sign-extended SP values.  The result may contain overflow.
int
AddSP16 (int Addend1, int Addend2)
{
  int Sum;
  Sum = Addend1 + Addend2;
  if (Sum & 0200000)
    {
      Sum += AGC_P1;
      Sum &= 0177777;
    }
  return (Sum);
}

// Absolute value of an SP value.

static int16_t
AbsSP (int16_t Value)
{
  if (040000 & Value)
    return (077777 & ~Value);
  return (Value);
}

static int16_t
NegateSP (int16_t Value)
{
  return (077777 & ~Value);
}

// Generate a counter request for a given counter.
void CounterRequest(agc_t * State, unsigned Counter, unsigned Type)
{
    State->RequestedCounter = 1;

    if (Counter > NUM_COUNTERS)
        return;

    State->CounterCell[Counter] |= Type;
    if (Counter < State->HighestPriorityCounter)
        State->HighestPriorityCounter = Counter;
}

// PINCs, INCRs, and AUGs that cause positive overflows on counters
// TIME1, TIME3, TIME4, and TIME5 have additional effects. For TIME1,
// a TIME2 counter request is generated. For the rest, the appropriate
// interrupts are requested.
static void
OverflowInterrupt (agc_t * State, int16_t Address10)
{
  if (IsReg(Address10, RegTIME1))
    CounterRequest(State, COUNTER_TIME2, COUNTER_CELL_PLUS);
  else if (IsReg(Address10, RegTIME5))
    State->InterruptRequests[RUPT_T5RUPT] = 1;
  else if (IsReg(Address10, RegTIME3))
    State->InterruptRequests[RUPT_T3RUPT] = 1;
  else if (IsReg(Address10, RegTIME4))
    State->InterruptRequests[RUPT_T4RUPT] = 1;
}

// 1's-complement increment
void
CounterPINC (agc_t * State, int Counter)
{
  int16_t i;
  i = State->Erasable[0][RegCOUNTER + Counter];
  if (i == 037777)
    {
      i = AGC_P0;
      OverflowInterrupt(State, RegCOUNTER + Counter);
    }
  else
    {
      i = (i + 1) & 077777;
      if (i == AGC_M0) // Account for -0 to +1 transition.
        i++;
    }
  State->Erasable[0][RegCOUNTER + Counter] = i;
}

// 1's-complement decrement
void
CounterMINC (agc_t * State, int Counter)
{
  int16_t i;
  i = State->Erasable[0][RegCOUNTER + Counter];
  if (i == (int16_t) 040000)
    i = AGC_M0;
  else
    {
      i = ((i - 1) & 077777);
      if (i == AGC_M0)	// Account for +0 to -1 transition.
	i--;
    }
  State->Erasable[0][RegCOUNTER + Counter] = i;
}

// 1's-complement zero-increment. This instruction doesn't
// technically exist, but can be formed if a counter cell
// attempts to perform a PINC and a MINC at the same time.
// It adds -0 to the counter, and its only noticeable
// effect is changing +0 to -0.
void
CounterZINC (agc_t * State, int Counter)
{
  int16_t i;
  i = State->Erasable[0][RegCOUNTER + Counter];
  if (i == AGC_P0)
    i = AGC_M0;
  State->Erasable[0][RegCOUNTER + Counter] = i;
}

// 2's-complement increment.
void
CounterPCDU (agc_t * State, int Counter)
{
  int16_t i;
  i = State->Erasable[0][RegCOUNTER + Counter];
  i = (i + 1) & 077777;
  State->Erasable[0][RegCOUNTER + Counter] = i;
}

// 2's-complement decrement.
void
CounterMCDU (agc_t * State, int Counter)
{
  int16_t i;
  i = State->Erasable[0][RegCOUNTER + Counter];
  i = (i - 1) & 077777;
  State->Erasable[0][RegCOUNTER + Counter] = i;
}

// Diminish increment.
void
CounterDINC (agc_t *State, int Counter)
{
  int16_t i;
  i = State->Erasable[0][RegCOUNTER + Counter];
  if (i == AGC_P0 || i == AGC_M0)	// Zero?
    {
      // Simulate ZOUT effects
      switch (Counter)
        {
        case COUNTER_TIME6:
          State->InterruptRequests[RUPT_T6RUPT] = 1;
          // Triggering a T6RUPT disables T6 by clearing the CH13 bit
          CpuWriteIO(State, 013, State->InputChannel[013] & 037777);
          break;
        case COUNTER_GYROCMD:
          // Gyro drive pulses have completed. Clear the active bit and
          // channel 14 bit 10.
          State->GyroDriveActive = 0;
          State->InputChannel[014] &= ~01000;
          break;
        // CDU drive pulses simply clear their channel enable bit
        case COUNTER_CDUXCMD:
          State->InputChannel[014] &= ~040000;
          break;
        case COUNTER_CDUYCMD:
          State->InputChannel[014] &= ~020000;
          break;
        case COUNTER_CDUZCMD:
          State->InputChannel[014] &= ~010000;
          break;
        case COUNTER_OPTYCMD:
          State->InputChannel[014] &= ~04000;
          break;
        case COUNTER_OPTXCMD:
          State->InputChannel[014] &= ~02000;
          break;
        }
    }
  else if (040000 & i)			// Negative?
    {
      i = AddSP16(SignExtend(i), SignExtend(AGC_P1)) & 077777;
      // Simualte MOUT effects
      switch (Counter)
        {
        case COUNTER_GYROCMD:
          if (!State->GyroDriveActive)
            {
              // Set the gyro drive active bit if it wasn't set.
              State->GyroDriveActive = 1;
              State->GyroDriveOut = 0;
            }
          break;
        // Generate minus output pulses for the CDU drives
        case COUNTER_CDUXCMD:
          State->CduDriveOut[0]--;
          break;
        case COUNTER_CDUYCMD:
          State->CduDriveOut[1]--;
          break;
        case COUNTER_CDUZCMD:
          State->CduDriveOut[2]--;
          break;
        case COUNTER_OPTYCMD:
          State->CduDriveOut[3]--;
          break;
        case COUNTER_OPTXCMD:
          State->CduDriveOut[4]--;
          break;
        }
    }
  else					// Positive?
    {
      i = AddSP16(SignExtend(i), SignExtend(AGC_M1)) & 077777;
      // Simualte POUT effects
      switch (Counter)
        {
        case COUNTER_GYROCMD:
          if (!State->GyroDriveActive)
            {
              // Set the gyro drive active bit if it wasn't set.
              State->GyroDriveActive = 1;
              State->GyroDriveOut = 0;
            }
          break;
        // Generate plus output pulses for the CDU drives
        case COUNTER_CDUXCMD:
          State->CduDriveOut[0]++;
          break;
        case COUNTER_CDUYCMD:
          State->CduDriveOut[1]++;
          break;
        case COUNTER_CDUZCMD:
          State->CduDriveOut[2]++;
          break;
        case COUNTER_OPTYCMD:
          State->CduDriveOut[3]++;
          break;
        case COUNTER_OPTXCMD:
          State->CduDriveOut[4]++;
          break;
        }
    }

  State->Erasable[0][RegCOUNTER + Counter] = i;
}

// Left-shift increment.
void
CounterSHINC (agc_t * State, int Counter)
{
  int16_t i;
  i = State->Erasable[0][RegCOUNTER + Counter];
  i = (i << 1) & 037777;
  State->Erasable[0][RegCOUNTER + Counter] = i;
}

// Left-shift and add increment.
void
CounterSHANC (agc_t * State, int Counter)
{
  int16_t i;
  i = State->Erasable[0][RegCOUNTER + Counter];
  i = ((i << 1) + 1) & 037777;
  State->Erasable[0][RegCOUNTER + Counter] = i;
}

static void 
UpdateDSKY(agc_t *State)
{
  unsigned LastChannel163 = State->DskyChannel163;

  State->DskyChannel163 &= ~(DSKY_KEY_REL | DSKY_VN_FLASH | DSKY_OPER_ERR | DSKY_RESTART | DSKY_STBY | DSKY_AGC_WARN | DSKY_TEMP);

  if (State->InputChannel[013] & 01000)
    // The light test is active. Light RESTART and STBY.
    State->DskyChannel163 |= DSKY_RESTART | DSKY_STBY; // 

  // If we're in standby, light the standby light
  if (State->Standby)
    State->DskyChannel163 |= DSKY_STBY;

  // Make the RESTART light mirror State->RestartLight.
  if (State->RestartLight)
    State->DskyChannel163 |= DSKY_RESTART;

  // Light TEMP if channel 11 bit 4 is set, or channel 30 bit 15 is set
  if ((State->InputChannel[011] & 010) || (State->InputChannel[030] & 040000))
    State->DskyChannel163 |= DSKY_TEMP;

  // Set KEY REL and OPER ERR according to channel 11
  if (State->InputChannel[011] & DSKY_KEY_REL)
    State->DskyChannel163 |= DSKY_KEY_REL;
  if (State->InputChannel[011] & DSKY_OPER_ERR)
    State->DskyChannel163 |= DSKY_OPER_ERR;

  // Turn on the AGC warning light if the warning filter is above its threshold
  if (State->WarningFilter > WARNING_FILTER_THRESHOLD)
    {
      State->DskyChannel163 |= DSKY_AGC_WARN;

      // Set the AGC Warning input bit in channel 33
      State->InputChannel[033] &= 057777;
    }

  // Flashing lights on the DSKY have a period of 1.28s, and a 75% duty cycle.
  // The lights are flashed off when FS16 and FS17 are both unset.
  if (!State->Standby && ((State->ScalerValue & (SCALER_FS17 | SCALER_FS16)) == 0))
    {
      // Flash off VERB and NOUN lights
      if (State->InputChannel[011] & DSKY_VN_FLASH)
        State->DskyChannel163 |= DSKY_VN_FLASH;

      // Flash off the KEY REL and OPER ERR lamps
      State->DskyChannel163 &= ~DSKY_KEY_REL;
      State->DskyChannel163 &= ~DSKY_OPER_ERR;
    }

  // Send out updated display information, if something on the DSKY changed
  if (State->DskyChannel163 != LastChannel163)
    ChannelOutput(State, 0163, State->DskyChannel163);
}

//----------------------------------------------------------------------------
// This function implements a model of what happens in the actual AGC hardware
// during a divide -- but made a bit more readable / software-centric than the 
// actual register transfer level stuff. It should nevertheless give accurate
// results in all cases, including those that result in "total nonsense".
// If A, L, or Z are the divisor, it assumes that the unexpected transformations
// have already been applied to the "divisor" argument.
static void
SimulateDV(agc_t *State, uint16_t divisor)
{
    uint16_t dividend_sign = 0;
    uint16_t divisor_sign = 0;
    uint16_t remainder;
    uint16_t remainder_sign = 0;
    uint16_t quotient_sign = 0;
    uint16_t quotient = 0;
    uint16_t sum = 0;
    uint16_t a = c(RegA);
    uint16_t l = c(RegL);
    int i;

    // Assume A contains the sign of the dividend
    dividend_sign = a & 0100000;

    // Negate A if it was positive
    if (!dividend_sign)
      a = ~a;
    // If A is now -0, take the dividend sign from L
    if (a == 0177777)
      dividend_sign = l & 0100000;
    // Negate L if the dividend is negative.
    if (dividend_sign)
      l = ~l;

    // Add 40000 to L
    l = AddSP16(l, 040000);
    // If this did not cause positive overflow, add one to A
    if (ValueOverflowed(l) != AGC_P1)
      a = AddSP16(a, 1);
    // Initialize the remainder with the current value of A
    remainder = a;

    // Record the sign of the divisor, and then take its absolute value
    divisor_sign = divisor & 0100000;
    if (divisor_sign)
      divisor = ~divisor;
    // Initialize the quotient via a WYD on L (L's sign is placed in bits
    // 16 and 1, and L bits 14-1 are placed in bits 15-2).
    quotient_sign = l & 0100000;
    quotient = quotient_sign | ((l & 037777) << 1) | (quotient_sign >> 15);

    for (i = 0; i < 14; i++)
    {
        // Shift up the quotient
        quotient <<= 1;
        // Perform a WYD on the remainder
        remainder_sign = remainder & 0100000;
        remainder = remainder_sign | ((remainder & 037777) << 1);
        // The sign is only placed in bit 1 if the quotient's new bit 16 is 1
        if ((quotient & 0100000) == 0)
          remainder |= (remainder_sign >> 15);
        // Add the divisor to the remainder
        sum = AddSP16(remainder, divisor);
        if (sum & 0100000)
          {
            // If the resulting sum has its bit 16 set, OR a 1 onto the
            // quotient and take the sum as the new remainder
            quotient |= 1;
            remainder = sum;
          }
    }
    // Restore the proper quotient sign
    a = quotient_sign | (quotient & 077777);

    // The final value for A is negated if the dividend sign and the
    // divisor sign did not match
    c(RegA) = (dividend_sign != divisor_sign) ? ~a : a;
    // The final value for L is negated if the dividend was negative
    c(RegL) = (dividend_sign) ? remainder : ~remainder;
}

//-----------------------------------------------------------------------------
// These functions implement scaler timing logic. The scaler is a 33-stage
// binary counter whose outputs are used to time many things throughout the
// AGC. Each stage has four outputs -- the inverted and noninverted state for
// that stage (named, eg., FS09 and FS09/), and two timing pulses of the form
// FxxA and FxxB. Timing pulse FxxA is emitted when the stage transitions from
// a 1 to a 0, and timing pulse FxxB is emitted when the stage transitions
// from a 0 to a 1. The frequency of each stage can be calculated by the
// forumula (1.024 kHz)/(2^x), where x is the number of the stage.
//
// Our implementation of the scaler omits stages 1 and 2, since they are too
// fast and time things too finely detailed for an emulator to care about.
// We simply advance our scaler counter once at the beginning of every MCT,
// and if that causes stage 3 to increment, we generate all expected
// timing pulses.

// Timepulse F03B generates PIPA data strobes, causing all three to generate
// either a plus or a minus count request. This happens only when FS04 is
// set and FS05 isn't -- i.e, every fourth F03B.
static void
TimingSignalF03B(agc_t * State)
{
    // if FS04 && !FS05, generate PIPA count requests
}

// Timepulse F04A clears the uplink-too-fast bit, which is set by each
// incoming uplink bit. If another uplink bit arrives before F04A occurs,
// the new bit will be dropped and the computer will be notified via
// channel 33 bit 11.
static void
TimingSignalF04A(agc_t * State)
{
    // clear uplink too fast monitoring flip-flop
}

// Timepulse F05A is far and away the busiest timing signal. It is used 
// for some standby-powered circuitry that monitors voltage levels. We 
// are not simulating power supply failures, and the input voltage must
// go well below its lower limit for the AGC power supply outputs to
// dip, so we only monitor the input voltage.
// 
// It checks inputs for the three input traps (31A, 31B, and 32) and
// sets a bit for each if they are active. If F05B occurs before a
// triggered trap gets reset, a HANDRUPT will be generated.
//
// This timepulse also generates many output count requests: the BMAG/RHC
// and RNRAD input counters, and all output counters use this timepulse.
static int
TimingSignalF05A(agc_t * State)
{
    int CausedRestart = 0;
    int i = 0;
    int PulseType = 0;

    // First, perform standby-powered stuff. Has our input voltage
    // remained below the limit since F05B?
    if (State->InputVoltageLow)
    {
        // The input voltage is bad. If we're in standby, this generates
        // an input to the warning filter.
        if (State->Standby)
            State->GeneratedWarning = 1;

        if (!InhibitAlarms)
        {
            // If the alarm isn't disabled, the computer will be held in
            // restart (via signal STRT1) until the next F05A in which the
            // the voltage is back within limits. Trigger a GOJAM and set
            // the appropriate CH77 bit.
            State->RestartHold = 1;
            State->InputChannel[077] |= CH77_VOLTAGE_FAIL;
            CausedRestart = 1;
        }
    }
    else
    {
        // Voltage is good, so de-assert the STRT1 restart hold
        State->RestartHold = 0;
    }

    // That's it for standby-powered stuff, so leave if we're in standby
    if (State->Standby)
        return CausedRestart;

    // Check for any of the input traps to be triggered. If they are, and
    // the cause of the triggering doesn't go away before F05B, we'll
    // generate a HANDRUPT.
    if (State->Trap31A && ((State->InputChannel[031] & 000077) != 000077))
        State->Trap31APending = 1;

    if (State->Trap31B && ((State->InputChannel[031] & 007700) != 007700))
        State->Trap31BPending = 1;

    if (State->Trap32 && ((State->InputChannel[032] & 001777) != 001777))
        State->Trap32Pending = 1;

    // Check for RHC input pulses
    for (i = 0; i < 3; i++)
    {
        if (State->RHCCounts[i] > 0)
        {
            State->RHCCounts[i]--;
            if (State->InputChannel[013] & 0200)
                CounterRequest(State, COUNTER_RHCP + i, COUNTER_CELL_PLUS);
        }
        else if (State->RHCCounts[i] < 0)
        {
            State->RHCCounts[i]++;
            if (State->InputChannel[013] & 0200)
                CounterRequest(State, COUNTER_RHCP + i, COUNTER_CELL_MINUS);
        }
    }

    // Generate radar count requests if a valid radar is selected
    if (State->RadarSync)
    {
        if (State->RadarData & 040000)
          PulseType = COUNTER_CELL_ONE;
        else
          PulseType = COUNTER_CELL_ZERO;

        CounterRequest(State, COUNTER_RNRAD, PulseType);
        State->RadarData <<= 1;
    }

    // Generate gyro drive pulses
    if (State->InputChannel[014] & 01000)
    {
        // At least one DINC is always generated regardless of the value
        // in the GYROCMD counter. The result of that DINC will determine
        // what happens next; if it generates a ZOUT, the drive active bit
        // and channel 14 bit 10 are cleared. Otherwise, the active bit is
        // set, which allows these F05A timing signals to generate drive
        // pulses to the gyros.
        CounterRequest(State, COUNTER_GYROCMD, COUNTER_CELL_PLUS);
        if (State->GyroDriveActive)
          State->GyroDriveOut++;
    }
    else
        State->GyroDriveActive = 0;

    // Generate CDU drive pulses if their respective channel 14 bits are
    // set. The output pulses themselves are generated during the DINC,
    // with a ZOUT resetting the channel 14 bit to disable the counter.
    if (State->InputChannel[014] & 040000)
      CounterRequest(State, COUNTER_CDUXCMD, COUNTER_CELL_PLUS);
    if (State->InputChannel[014] & 020000)
      CounterRequest(State, COUNTER_CDUYCMD, COUNTER_CELL_PLUS);
    if (State->InputChannel[014] & 010000)
      CounterRequest(State, COUNTER_CDUZCMD, COUNTER_CELL_PLUS);
    if (State->InputChannel[014] & 04000)
      CounterRequest(State, COUNTER_OPTYCMD, COUNTER_CELL_PLUS);
    if (State->InputChannel[014] & 02000)
      CounterRequest(State, COUNTER_OPTXCMD, COUNTER_CELL_PLUS);

    // Lots of things:
    // THRSTD
    // EMSD
    // OTLINK
    // ALT

    return CausedRestart;
}

// Timepulse F05B checks to see if any voltage sources are out of limits,
// and if they are, notes it down. If the problem hasn't been resolved
// by F05A, we'll generate an alarm. It also generates HANDRUPTs if any
// of the input traps are enabled and triggered.
// Timing pulses GTSET, GTRST, and GTONE are potentially generated,
// depending on the state of scaler stages 6-9. These pulses are used
// by the radar, outlink, and altimeter interfaces.
static void
TimingSignalF05B(agc_t * State)
{
    unsigned GtsetType;
    // If the input voltage is below the voltage fail circuit threshold,
    // set a bit for F05A to check.
    if (State->InputVoltagemV < VFAIL_THRESHOLD)
        State->InputVoltageLow = 1;

    if (State->Standby)
        return;

    // If any of the input traps are pending, generate a HANDRUPT and
    // disable the tripped trap.
    if (State->Trap31APending)
    {
        State->Trap31A = 0;
        State->Trap31APending = 0;
        State->InterruptRequests[RUPT_HANDRUPT] = 1;
    }

    if (State->Trap31BPending)
    {
        State->Trap31B = 0;
        State->Trap31BPending = 0;
        State->InterruptRequests[RUPT_HANDRUPT] = 1;
    }

    if (State->Trap32Pending)
    {
        State->Trap32 = 0;
        State->Trap32Pending = 0;
        State->InterruptRequests[RUPT_HANDRUPT] = 1;
    }

    // Handled GTSET, GTRST, and GTON-driven logic
    GtsetType = State->ScalerValue & SCALER_GTSET;
    if (GtsetType == SCALER_GTSET)
    {
        // If the radar gate counter has reached 9, begin generating sync
        // pulses and getting count requests back.
        if (State->RadarGateCounter == 9)
          State->RadarSync = 1;
    }
    else if (GtsetType == SCALER_GTRST)
    {
        // If a radar sync was active, stop it, generate a RADARUPT, and
        // reset all of the related state information
        if (State->RadarSync)
        {
            State->InterruptRequests[RUPT_RADARUPT] = 1;
            State->InputChannel[013] &= ~010;
            State->RadarGateCounter = 0;
            State->RadarSync = 0;
        }
    }
}

// Timepulse F06B generates TIME6 count requests, if the timer is enabled
// via channel 13 bit 15. It also serves as a two-stage enable for sampling
// the RHC input type "A" analog-to-digital circuits. If FS07 is high,
// channel 13 bit 9 is checked. If it is set, a "pending" flip-flop is set,
// which cannot be reset by CH13 bit 9 going away. The next F06B, when
// FS07 is low, an enable strobe (RHCGO) is applied to the input circuits,
// which stretch a pulse-gating output for a time proportional to the
// peak voltage on the incoming AC signal from the RHC. The counter
// requests themselves are generated in F05A.
static void
TimingSignalF06B(agc_t * State)
{
    int i;

    if (040000 & State->InputChannel[013])
      CounterRequest(State, COUNTER_TIME6, COUNTER_CELL_PLUS);

    // RHC things
    if (State->ScalerValue & SCALER_FS07)
    {
        if (0400 & State->InputChannel[013])
          State->RHCPending = 1;
    }
    else if (State->RHCPending)
    {
        // Calculate the number of pulses for each channel
        for (i = 0; i < 3; i++)
          State->RHCCounts[i] = State->RHCVoltagemV[i] / RHC_MV_PER_COUNT;

        State->RHCPending = 0;
        State->InputChannel[013] &= ~0400;
    }
}

// Timpeulse F07A marks the beginning of monitoring for one half of the
// counter alarm circuitry. If, between F07A and the next F07B, only
// counter instructions have been executed, the counter alarm is raised.
static void
TimingSignalF07A(agc_t * State)
{
    // Start monitoring for counter alarm
    State->CounterLock = 1;
}

// Timepulse F07B finishes monitoring for the "only count instructions
// have executed" portion of the counter alarm. If the alarm is tripped,
// an input is generated to the warning filter. The counter alarm is
// unique in that, unlike any other alarm, it does not trigger a restart.
static void
TimingSignalF07B(agc_t * State)
{
    // Generate warning filter input if only counter instructions have
    // been run since F07A.
    if (State->CounterLock)
    {
        State->GeneratedWarning = 1;
        State->InputChannel[077] |= CH77_COUNTER_FAIL;
        ChannelOutput(State, 077, State->InputChannel[077]);
    }
}

// Timepulse F08B resets the warning filter input, in the real AGC.
// Since we're modeling inputs to the warning filter as instantaneous
// voltage steps instead of charging, we instead use this timepulse
// as a place to model the discharge of the warning filter's capacitor.
static void
TimingSignalF08B(agc_t * State)
{
    // Discharge the warning filter capacitor, bottoming out at 0.
    if (State->WarningFilter >= WARNING_FILTER_DECREMENT)
        State->WarningFilter -= WARNING_FILTER_DECREMENT;
    else
        State->WarningFilter = 0;

    // If the capacitor charge has fallen below the threshold,
    // turn off the AGC WARNING lamp.
    if (State->WarningFilter < WARNING_FILTER_THRESHOLD)
        State->DskyChannel163 &= ~DSKY_AGC_WARN;
}

// Timepulse F09A begins checking for DSKY and MARK input keys on
// channels 15 and 16. If any of bits 1-5 in channel 15 are nonzero,
// a bit is set that is checked again at F09B. If this bit hasn't been
// reset by bits 1-5 becoming zero before then, and interrupt will be
// generated. The same is true for KEYRUPT2 and channel 16 bits 1-5,
// and MARKRUPT and channel 16 bits 6-7. Even though they share the
// same interrupt vector, the circuits for KEYRUPT2 and MARKRUPT are
// totally independent.
static void
TimingSignalF09A(agc_t * State)
{
    // Check if any channel 15 bits are set
    if (State->InputChannel[015] != 0)
      State->Keyrupt1Pending = 1;

    // Check if any of channel 16 bits 1-5 are set
    if ((State->InputChannel[016] & 037) != 0)
      State->Keyrupt2Pending = 1;

    // Check if any of channel 16 bits 6-7 are set
    if ((State->InputChannel[016] & 0140) != 0)
      State->MarkruptPending = 1;
}

// Timepulse F09B generates count requests for TIME4, if FS10 is not
// set. It also marks the end of DSKY keypress checking and generates
// KEYRUPT1, KEYRUPT2, or MARKRUPT if the keys for any of them have
// been depressed since F09A. The interrupts disable themselves until
// their respective bits are all reset to 0.
static void
TimingSignalF09B(agc_t * State)
{
    // Generate TIME4 incrememnt requests if FS10
    if ((State->ScalerValue & SCALER_FS10) == 0)
        CounterRequest(State, COUNTER_TIME4, COUNTER_CELL_PLUS);

    // Generate KEYRUPT1 if bits 1-5 of channel 15 have remained
    // non-zero since F09A, and it is not currently disabled.
    if (State->Keyrupt1Enabled && State->Keyrupt1Pending)
    {
        State->Keyrupt1Enabled = 0;
        State->InterruptRequests[RUPT_KEYRUPT1] = 1;
    }

    // Generate KEYRUPT2 if bits 1-5 of channel 16 have remained
    // non-zero since F09A, and it is not currently disabled.
    if (State->Keyrupt2Enabled && State->Keyrupt2Pending)
    {
        State->Keyrupt2Enabled = 0;
        State->InterruptRequests[RUPT_KEYRUPT2] = 1;
    }

    // Generate MARKRUPT if bits 6-7 of channel 16 have remained
    // non-zero since F09A, and it is not currently disabled.
    if (State->MarkruptEnabled && State->MarkruptPending)
    {
        State->MarkruptEnabled = 0;
        State->InterruptRequests[RUPT_KEYRUPT2] = 1;
    }
}

// Timepulse F10A generates count requests for TIME5, and marks
// the end of monitoring for the TC Trap alarms. If only TCs have
// been executed, or no TCs have been executed at all, a restart
// is triggered. At least, in theory -- we strongly believe that
// the "no TCs" half of the circuit is flawed, and is incorrectly
// reset by transients that appear on the TC0 and TCF0 lines
// during instruction changeover. We simulate most sources of
// these transients, which are noted in various instructions which
// set NoTC to 0. This behavior appears to be backed up by the
// RUPTCHK test in the Aurora and Sunburst ropes; without simulating
// such transients RUPTCHK triggers a restart.
// This timepulse is also used to begin radar cycles and advance
// the radar gating pulse counter. The counter advances if channel
// 13 bit 4 is a 1. When the counter reaches exactly 9, circuits
// that shift in the results from the radar are enabled.
static int
TimingSignalF10A(agc_t * State)
{
    int CausedRestart = 0;

    // Generate count requests for TIME5
    CounterRequest(State, COUNTER_TIME5, COUNTER_CELL_PLUS);

    // If one of the TC Trap alarms was tripped, trigger a restart
    if (!InhibitAlarms && (State->TCTrap || State->NoTC))
    {
        CausedRestart = 1;
        State->InputChannel[077] |= CH77_TC_TRAP;
    }

    // If radar activity is enabled, advance the radar gate counter.
    // It is a 4-bit counter that counts up to 9, at which point the
    // logic that eventually generates a RADARUPT is set into motion.
    // This counter is not initialized on power-on or restart, which
    // means that in real AGCs its initial count was effectively
    // random, potentially even greater than 9. In such situations,
    // the counter would wrap around at 16 and continue to count up
    // as usual. The AGC will generate gating pulses throughout these
    // additional counts, meaning that the radar will receive many
    // more than the agreed-upon 256 pulses, presumably leading to
    // corrupted data. Mission reports/debriefs indicate that the
    // first VHF ranging in CSMs was typically bad, and we believe
    // this to be the cause.
    if (State->InputChannel[013] & 010)
    {
        State->RadarGateCounter = (State->RadarGateCounter + 1) & 017;
    }

    return CausedRestart;
}

// Timepulse F10B generates count requests for TIME1 and TIME3,
// and starts monitoring for the TC Trap alarms.
static void
TimingSignalF10B(agc_t * State)
{
    CounterRequest(State, COUNTER_TIME1, COUNTER_CELL_PLUS);
    CounterRequest(State, COUNTER_TIME3, COUNTER_CELL_PLUS);

    State->TCTrap = 1;
    State->NoTC = 1;
}

// Timepulse F12B finishes monitoring for the Rupt Lock alarms, if
// FS13 is set and FS14 is not (i.e., every fourth F12B). A restart
// is triggered if, when such an F12B occurs, there have either been
// no interrupts or only interrupts since the last F14B.
static int
TimingSignalF12B(agc_t * State)
{
    int CausedRestart = 0;

    // Trigger a restart if FS13 is set and FS14 isn't, and either
    // of the Rupt Lock monitoring bits hasn't been reset.
    if (((State->ScalerValue & (SCALER_FS14 | SCALER_FS13)) == SCALER_FS13)
        && (!InhibitAlarms && (State->RuptLock || State->NoRupt)))
    {
        State->InputChannel[077] |= CH77_RUPT_LOCK;
        CausedRestart = 1;
    }

    return CausedRestart;
}

// Timepulse F14B begins monitoring for the Rupt Lock alarms. It also
// generates an input pulse to the AGC Warning Filter if any events
// have triggered a warning. The input to the warning filter causes
// a capacitor to charge. If the capacitor's voltage becomes high
// enough, the AGC WARN light in the spacecraft will come on, and
// channel 33 bit 14 is set to notify software.
static void
TimingSignalF14B(agc_t * State)
{
    // Start monitoring for Rupt Lock
    State->RuptLock = 1;
    State->NoRupt = 1;

    // Charge the warning filter capacitor if a warning has been
    // generated
    if (State->GeneratedWarning || (State->InputChannel[013] & 01000))
    {
        State->GeneratedWarning = 0;
        State->WarningFilter += WARNING_FILTER_INCREMENT;
        if (State->WarningFilter > WARNING_FILTER_MAX)
            State->WarningFilter = WARNING_FILTER_MAX;
    }
}

// Timepulse F17A marks the start of the window throughout which
// the PRO (formerly SBY) button must be held to make the AGC
// enter or leave standby mode. It also wraps up monitoring of the 
// Night Watchman alarm, causing a restart if address 067 hasn't
// been accessed in any way by software since the last F17B.
static int
TimingSignalF17A(agc_t * State)
{
    int CausedRestart = 0;

    // Note if PRO/SBY is currently depressed.
    if (0 == (State->InputChannel[032] & 020000))
        State->SbyPressed = 1;

    // The rest of the circuitry timed with F17A is powered off
    // during standby
    if (State->Standby)
        return CausedRestart;

    // Trigger a restart if the Night Watchman monitoring bit
    // is still set
    if (!InhibitAlarms && State->NightWatchman)
    {
        State->InputChannel[077] |= CH77_NIGHT_WATCHMAN;
        CausedRestart = 1;

        // The Night Watchman's monitor output is unique in that
        // once the alarm has occurred, the output is asserted
        // until the next F17A (1.28s later). Throughout this time,
        // writes to channel 77 will fail to clear the Night
        // Watchman bit.
        State->NightWatchmanTripped = 1;
    }
    else
        State->NightWatchmanTripped = 0;

    return CausedRestart;
}

// Timepulse F17B completes the window throughout which PRO/SBY
// must be held to enter or leave standby mode, as long as doing
// so is enabled by channel 13 bit 11. It also begins monitoring
// for the Night Watchman alarm.
static int
TimingSignalF17B(agc_t * State)
{
    int CausedRestart = 0;

    // If PRO/SBY has been pressed since F17A, we're either going
    // to enter standby if channel 13 bit 11 enables us to, or leaving
    // standby if we're already in it.
    if (State->SbyPressed && ((State->InputChannel[013] & 002000) || State->Standby))
    {
        if (!State->Standby)
        {
            // Enter standby. PRO/SBY must be released and then depressed
            // for long enough again to exit, so mark that it's still down
            // at the moment to prevent us from coming right back out.
            State->Standby = 1;
            State->SbyStillPressed = 1;
            CausedRestart = 1;

            // Turn on the STBY light, and switch off the EL segments
            State->DskyChannel163 |= DSKY_STBY | DSKY_EL_OFF;
            ChannelOutput(State, 0163, State->DskyChannel163);
        }
        else if (!State->SbyStillPressed)
        {
            // We're booting back up! Disable standby so we can get rolling
            State->Standby = 0;

            // Turn off the STBY light
            State->DskyChannel163 &= ~(DSKY_STBY | DSKY_EL_OFF);
            ChannelOutput(State, 0163, State->DskyChannel163);
        }
    }

    // If we're in standby after all that, head back, since the remaining
    // circuitry is powered off.
    if (State->Standby)
        return CausedRestart;

    // Begin monitoring for the Night Watchman alarm.
    State->NightWatchman = 1;

    return CausedRestart;
}

// Timepulse F18A begins the monitoring period for loss of PIPA inputs.
// If any individual PIPA fails to produce a count pulse between F18A
// and F18B, the computer will be notified of a PIPA failure via channel
// 33 bit 13.
static void
TimingSignalF18A(agc_t * State)
{
}

// Timepulse F18B marks the end of the monitoring period for loss of
// PIPA inputs.
static void
TimingSignalF18B(agc_t * State)
{
}

//-----------------------------------------------------------------------------
// This function performs the actual scaler counting, and generation of all of
// the above timepulse handling functions. An internal counter is advanced once
// each call to agc_engine() -- i.e., once each MCT, which is equivalent to
// exactly 11.71875 microseconds. As discussed above, the fastest scaler stage
// we simulate is FS03, whose period is 78.125 microseconds. Each FS03 count
// therefore happens in half that time, every 39.0625 microseconds. This turns
// out to be (10/3)*MCT.

#define SCALER_OVERFLOW 10
#define SCALER_DIVIDER 3
static int
AdvanceScaler(agc_t * State)
{
    int CausedRestart = 0;
    uint32_t value;

    // Add the divider to the internal counter, and advance the scaler as
    // many times as we can (which really should only be once, if that).
    State->ScalerCounter += SCALER_DIVIDER;
    while (State->ScalerCounter >= SCALER_OVERFLOW)
    {
        State->ScalerCounter -= SCALER_OVERFLOW;
        // Increment the scaler and update input channels 3 and 4. Channel
        // 4 shows the current value of scaler stages 6 through 19 (so it
        // counts at 3200kHz) and channel 3 shows stage 20 through 33 (so
        // it counts once every 5.12 seconds).
        State->ScalerValue++;
        State->InputChannel[04] = (State->ScalerValue >> 3) & 037777;
        State->InputChannel[03] = (State->ScalerValue >> 17) & 037777;

        // Generate any timing pulses that have occurred as a result of
        // this count. We start with stages 5 and 17, since both are used
        // by circuits that are powered on during standby.
        value = State->ScalerValue;
        if ((value & SCALER_MASK_F05) == 0) 
            CausedRestart |= TimingSignalF05A(State);
        if ((value & SCALER_MASK_F05) == SCALER_FS05) 
            TimingSignalF05B(State);

        if ((value & SCALER_MASK_F17) == 0) 
            CausedRestart |= TimingSignalF17A(State);
        if ((value & SCALER_MASK_F17) == SCALER_FS17) 
            CausedRestart |= TimingSignalF17B(State);

        // Nothing else is used by standby-powered logic (at least that
        // we're simulating). Move on to the next count, or head back.
        if (State->Standby)
            continue;

        // Generate the rest of the pulses in order. This allows us to stop
        // early if we generate a B pulse; since each B pulse indicates the
        // stage has counted from a 0 to a 1, no pulses of later stages are
        // possible, since both A and B pulses can only occur if all earlier
        // stages are 0.
        if ((value & SCALER_MASK_F03) == SCALER_FS03) 
        {
            TimingSignalF03B(State);
            continue;
        }

        if ((value & SCALER_MASK_F04) == 0) 
            TimingSignalF04A(State);

        if ((value & SCALER_MASK_F06) == SCALER_FS06) 
        {
            TimingSignalF06B(State);
            continue;
        }

        if ((value & SCALER_MASK_F07) == 0) 
            TimingSignalF07A(State);
        if ((value & SCALER_MASK_F07) == SCALER_FS07) 
        {
            TimingSignalF07B(State);
            continue;
        }

        if ((value & SCALER_MASK_F08) == SCALER_FS08) 
        {
            TimingSignalF08B(State);
            continue;
        }

        if ((value & SCALER_MASK_F09) == 0) 
            TimingSignalF09A(State);
        if ((value & SCALER_MASK_F09) == SCALER_FS09) 
        {
            TimingSignalF09B(State);
            continue;
        }

        if ((value & SCALER_MASK_F10) == 0) 
            CausedRestart |= TimingSignalF10A(State);
        if ((value & SCALER_MASK_F10) == SCALER_FS10) 
        {
            TimingSignalF10B(State);
            continue;
        }

        if ((value & SCALER_MASK_F12) == SCALER_FS12) 
        {
            CausedRestart |= TimingSignalF12B(State);
            continue;
        }
        
        if ((value & SCALER_MASK_F14) == SCALER_FS14) 
        {
            TimingSignalF14B(State);
            continue;
        }

        if ((value & SCALER_MASK_F18) == 0) 
            TimingSignalF18A(State);
        if ((value & SCALER_MASK_F18) == SCALER_FS18) 
            TimingSignalF18B(State);
    }

    return CausedRestart;
}

//-----------------------------------------------------------------------------
// This function performs the appropriate count instruction (PINC, MINC, DINC,
// PCDU, MCDU, SHINC, or SHANC) if any counter cells have pending counts. Cells
// are processed in priority order, with lower addresses indicating higher
// priority. Once a count is performed, the next highest-priority pending cell
// is determined for next time.
//
// The AGC has some interesting behavior if any cell capable of holding plus
// and minus requests is holding requests for both --- say, a BMAGX+ and a
// BMAGX-. Rather than executing first one then the other, the AGC will attempt
// to execute both instructions *at the same time*. The control pulses of both
// instructions are effectively added together, timepulse-by-timepulse. This
// happens for all pairs -- PINC/MINC, PCDU/MCDU, and SHINC/SHANC. Luckily,
// or perhaps by design, MCDU is a superset of PCDU, and SHANC is a superset
// of SHINC, so MCDU and SHANC simply take priority if both are requested.
// PINC and MINC, however, both have unique pulses -- one generates +1 to the
// adder and one generates -1. The end result is a counter instruction that
// simply adds -0 to the counter cell. Such an instruction doesn't have a
// documented name, so we simply call it "ZINC" for our own purposes, for
// "zero increment".
int HandleNextCounterCell(agc_t * State)
{
    int i = 0;

    // If the highest priority counter variable isn't a valid counter, that
    // means that none are pending, so we can return.
    if (State->HighestPriorityCounter >= NUM_COUNTERS)
        return 0;

    // Reset the "counter requested" monitoring bit to let the Counter Fail
    // alarm circuit know that we've serviced at least once of the counters
    // that were recently requested.
    State->RequestedCounter = 0;

    // Determine the types of instructions allowed based on the address of
    // the counter.
    i = State->HighestPriorityCounter;
    switch (i)
    {
    // PINC-only
    case COUNTER_TIME2:
    case COUNTER_TIME1:
    case COUNTER_TIME3:
    case COUNTER_TIME4:
    case COUNTER_TIME5:
        CounterPINC(State, i);
        break;

    // PINC/MINC. If both plus and minus are requested, instead generate
    // a "ZINC" (as described above).
    case COUNTER_PIPAX:
    case COUNTER_PIPAY:
    case COUNTER_PIPAZ:
    case COUNTER_RHCP:
    case COUNTER_RHCY:
    case COUNTER_RHCR:
        if (State->CounterCell[i] == (COUNTER_CELL_PLUS | COUNTER_CELL_MINUS))
            CounterZINC(State, i);
        else if (State->CounterCell[i] == COUNTER_CELL_PLUS)
            CounterPINC(State, i);
        else
            CounterMINC(State, i);
        break;

    // DINC-only
    case COUNTER_TIME6:
    case COUNTER_GYROCMD:
    case COUNTER_CDUXCMD:
    case COUNTER_CDUYCMD:
    case COUNTER_CDUZCMD:
    case COUNTER_OPTYCMD:
    case COUNTER_OPTXCMD:
    case COUNTER_THRUST:
    case COUNTER_EMSD:
        CounterDINC(State, i);
        break;

    // PCDU/MCDU. MCDU takes priority if both are requested.
    case COUNTER_CDUX:
    case COUNTER_CDUY:
    case COUNTER_CDUZ:
    case COUNTER_OPTY:
    case COUNTER_OPTX:
        if (State->CounterCell[i] & COUNTER_CELL_MINUS)
            CounterMCDU(State, i);
        else
            CounterPCDU(State, i);
        break;

    // SHINC-only
    case COUNTER_OUTLINK:
    case COUNTER_ALTM:
        CounterSHINC(State, i);
        break;

    // SHINC/SHANC. SHANC takes priority if both are requested.
    case COUNTER_INLINK:
    case COUNTER_RNRAD:
        if (State->CounterCell[i] & COUNTER_CELL_ONE)
            CounterSHANC(State, i);
        else
            CounterSHINC(State, i);
        break;

    default:
        break;
    }

    // Clear the counter cell, even if we executed a combined instruction.
    State->CounterCell[i] = 0;

    // Determine the highest priority remaining counter cell for next time.
    for (i = State->HighestPriorityCounter+1; i < NUM_COUNTERS; i++)
        if (State->CounterCell[i])
            break;
    State->HighestPriorityCounter = i;

    return 1;
}

//-----------------------------------------------------------------------------
// This function simulates all of the effects of a hardware restart, also known
// as a GOJAM.
void PerformGOJAM(agc_t * State)
{
    int i;

    // Restarts cause two instructions to execute immediately without
    // interruption (except by other restarts or standby/power loss): GOJAM,
    // which constructs a TC 4000 instruction, and the TC 4000 instruction
    // itself.
    State->PendDelay = 2;

    // The net result of those two is Z = 4000. Interrupt state is cleared, and
    // interrupts are enabled. The TC 4000 has the beneficial side-effect of
    // storing the current Z in Q, where it can helpfully be recovered. Later
    // ropes stored this value in the erasable location "RSBBQ" for debugging.
    c(RegQ) = c(RegZ);
    c(RegZ) = 04000;
    State->InIsr = 0;
    State->AllowInterrupt = 1;
    State->ParityFail = 0;

    // HANDRUPT traps are all disabled.
    State->Trap31A = 0;
    State->Trap31B = 0;
    State->Trap32 = 0;

    // All interrupt requests are cleared.
    for (i = 1; i <= NUM_INTERRUPT_TYPES; i++)
        State->InterruptRequests[i] = 0;

    // Clear channels 5, 6, 10, 11, 12, 13, and 14
    CpuWriteIO(State, 005, 0);
    CpuWriteIO(State, 006, 0);
    CpuWriteIO(State, 010, 0);
    CpuWriteIO(State, 011, 0);
    CpuWriteIO(State, 012, 0);
    CpuWriteIO(State, 013, 0);
    CpuWriteIO(State, 014, 0);

    // Clear the UPLINK TOO FAST bit (11) in channel 33
    State->InputChannel[033] |= 002000;

    // Clear channels 34 and 35, and don't let doing so generate a downrupt
    CpuWriteIO(State, 034, 0);
    CpuWriteIO(State, 035, 0);
    State->DownruptTimeValid = 0;

    // Light the RESTART light on the DSKY, if we're not going into standby
    if (!State->Standby)
    {
        State->RestartLight = 1;
        State->GeneratedWarning = 1;

        if (State->RequestedCounter)
          State->InputChannel[077] |= CH77_COUNTER_FAIL;
    }

    // Push any CH77 updates to the outside world
    ChannelOutput(State, 077, State->InputChannel[077]);
}

//-----------------------------------------------------------------------------
// Execute one machine-cycle of the simulation.  Use agc_engine_init prior to 
// the first call of agc_engine, to initialize State, and then call agc_engine 
// thereafter every (simulated) 11.7 microseconds.
//
// Returns:
//      0 -- success
// I'm not sure if there are any circumstances under which this can fail ...
int
agc_engine (agc_t * State)
{
  int i, j;
  uint16_t ProgramCounter, Instruction, QuarterCode;
  int16_t *WhereWord;
  uint16_t Address12, Address10, Address9;
  int ValueK, KeepExtraCode = 0;
  int16_t Operand16;
  int16_t CurrentEB, CurrentFB, CurrentBB;
  int PseudoInstruction = 0;
  uint16_t ExtendedOpcode;
  int Overflow, Accumulator;

  // Keep track of TC executions for the TC Trap alarm
  int ExecutedTC = 0;
  int JustTookBZF = 0;
  int JustTookBZMF = 0;

  // For DOWNRUPT
  if (State->DownruptTimeValid && State->CycleCounter >= State->DownruptTime)
    {
      State->InterruptRequests[RUPT_DOWNRUPT] = 1;	// Request DOWNRUPT
      State->DownruptTimeValid = 0;
    }

  State->CycleCounter++;

  //----------------------------------------------------------------------
  // The following little thing is useful only for debugging yaDEDA with
  // the --debug-deda command-line switch.  It just outputs the contents
  // of the address that was specified by the DEDA at 1/2 second intervals.
  if (DedaMonitor && State->CycleCounter >= DedaWhen)
    {
      int16_t Data;
      Data = State->Erasable[0][DedaAddress];
      DedaWhen = State->CycleCounter + 1024000 / 24;	// 1/2 second.
      ShiftToDeda (State, (DedaAddress >> 6) & 7);
      ShiftToDeda (State, (DedaAddress >> 3) & 7);
      ShiftToDeda (State, DedaAddress & 7);
      ShiftToDeda (State, 0);
      ShiftToDeda (State, (Data >> 12) & 7);
      ShiftToDeda (State, (Data >> 9) & 7);
      ShiftToDeda (State, (Data >> 6) & 7);
      ShiftToDeda (State, (Data >> 3) & 7);
      ShiftToDeda (State, Data & 7);
    }

  //-------------------------------------------------------------------------
  // Handle server stuff for socket connections used for i/o channel
  // communications.  Stuff like listening for clients we only do
  // every once and a while---nominally, every 100 ms.  Actually 
  // processing input data is done every cycle.
  if (State->ChannelRoutineCount == 0)
    ChannelRoutine (State);
  State->ChannelRoutineCount = ((State->ChannelRoutineCount + 1) & 017777);

  // Get data from input channels.
  ChannelInput(State);

  //-------------------------------------------------------------------------
  // Check to see if the PRO/SBY button has been released. We must act on
  // this immediately, since a release resets the standby circuits.
  if (State->InputChannel[032] & 020000)
    {
      State->SbyPressed = 0;
      State->SbyStillPressed = 0;
    }

  //-------------------------------------------------------------------------
  // Advance the scaler, generating any timing signals that are due. If one
  // of the alarm circuits timed by the scaler triggers a restart (or if we
  // encounted a parity problem last MCT), perform a GOJAM.
  if (AdvanceScaler(State) || State->ParityFail)
      PerformGOJAM(State);

  //-------------------------------------------------------------------------
  // Update the DSKY displays.
  UpdateDSKY(State);

  // If in --debug-dsky mode, don't want to take the chance of executing
  // any AGC code, since there isn't any loaded anyway.
  if (DebugDsky)
    return (0);

  //-------------------------------------------------------------------------
  // If we are in standby or if we are being held in reset by a voltage fail
  // alarm, stop processing here. Everything from here on out needs an online
  // operational computer.
  if (State->Standby || State->RestartHold)
    return (0);

  //-------------------------------------------------------------------------
  // Use up any remaining MCTs for the current instruction. All activities
  // were performed in the first MCT, so there's nothing else to really do.
  // This isn't strictly accurate for any instructions that take longer than
  // 2 MCTs, but it's a good enough approximation -- situations in which
  // this matters are exceptionally rare.
  if (State->PendDelay > 0)
    {
      State->PendDelay--;
      return (0);
    }

  //-------------------------------------------------------------------------
  // Okay, here's the stuff that actually has to do with decoding 
  // instructions. We need to do this first, before checking counter cells,
  // because if we get a pseudoinstruction (EXTEND, INHINT, or RELINT), the
  // count will be deferred until after it executes. This is because these
  // pseudoinstructions execute as part of their preceding instruction,
  // effectively extending its MCT count by one. The real AGC had fully
  // decoded the next instruction at the end of the previous, but doing it
  // this way works too.

  // After each instruction is executed, the AGC's Z register is updated to 
  // indicate the next instruction to be executed. The Z register is 16
  // bits long, but its value is transferred to the 12-bit S regsiter for
  // addressing, so the upper bits are lost.
  ProgramCounter = c(RegZ) & 07777;
  WhereWord = FindMemoryWord (State, ProgramCounter);

  // Fetch the instruction itself.
  if (State->SubstituteInstruction)
    Instruction = c(RegBRUPT);
  else
    {
      // The index is sometimes positive and sometimes negative.  What to
      // do if the result has overflow, I can't say.  I arbitrarily 
      // overflow-correct it.
      Instruction = OverflowCorrected (
         AddSP16 (SignExtend (State->IndexValue), SignExtend (*WhereWord)));
    }
  Instruction &= 077777;

  // Check for EXTEND, RELINT, or INHINT
  if (Instruction == 3 || Instruction == 4 || Instruction == 6)
    PseudoInstruction = 1;

  //-------------------------------------------------------------------------
  // If we didn't get a pseudoinstruction, it's time to service the counters.
  // We'll check for any pending counts, and if there are any, execute the
  // desired count instruction for the highest priority one.
  if (!PseudoInstruction && HandleNextCounterCell(State))
      return (0);

  // If we've made it this far, we can reset the counter alarm monitor --
  // we're about to execute a real, non-counter instruction.
  State->CounterLock = 0;

  //-------------------------------------------------------------------------
  // At this point we need to do a little more processing on the instruction.
  // We may not execute it if there is an interrupt pending, but we need to
  // know if the instruction is an EDRUPT, because that behaves identically
  // to the interrupt instruction sequence.
  CurrentEB = c(RegEB);
  CurrentFB = c(RegFB);
  CurrentBB = c(RegBB);
  // Reform 16-bit accumulator and test for overflow in accumulator.
  Accumulator = c (RegA)& 0177777;
  Overflow = (ValueOverflowed (Accumulator) != AGC_P0);

  ExtendedOpcode = Instruction >> 9;	//2;
  if (State->ExtraCode)
    ExtendedOpcode |= 0100;

  QuarterCode = Instruction & ~MASK10;
  Address12 = Instruction & MASK12;
  Address10 = Instruction & MASK10;
  Address9 = Instruction & MASK9;

  //-------------------------------------------------------------------------
  // Handle interrupts. Interrupts are allowed if we're not in an ISR, if
  // they haven't been disallowed by INHINT or debugging code, if the next
  // instruction isn't an extracode, and if the accumulator doesn't have
  // overflow.
  // All of these rules are thrown out the window if EDRUPT is the next
  // instruction. EDRUPT is the exact same interrupt sequence that happens
  // when interrupts are permitted and pending, just placed under programmer
  // control without any of the checks; just like a standard interrupt
  // sequence, it will walk through the pending interrupts and execute the
  // highest priority one, if there are any pending. If none are pending,
  // no ISR vector is generated, making it jump to address 0 (aka A).
  if ((DebuggerInterruptMasks[0] && !State->InIsr && State->AllowInterrupt
     && !State->ExtraCode && !Overflow && !PseudoInstruction)
     || ExtendedOpcode == 0107) // Always check if the instruction is EDRUPT.
    {
      int InterruptRequested = 0;
      // Interrupt vectors are ordered by their priority, with the lowest
      // address corresponding to the highest priority interrupt. Thus,
      // we can simply search through them in order for the next pending
      // request. There's two extra MCTs associated with taking an
      // interrupt -- one each for filling ZRUPT and BRUPT.
      // Search for the next interrupt request.
      for (i = 1; i <= NUM_INTERRUPT_TYPES; i++)
        {
          if (State->InterruptRequests[i] && DebuggerInterruptMasks[i])
            {
              // Clear the interrupt request.
              State->InterruptRequests[i] = 0;
              State->InterruptRequests[0] = i;

              State->NextZ = 04000 + 4 * i;

              InterruptRequested = 1;
              break;
            }
        }

      // If no pending interrupts and we're dealing with EDRUPT, fall
      // back to address 0 (A) as the interrupt vector
      if (!InterruptRequested && ExtendedOpcode == 0107)
        {
          State->NextZ = 0;
          InterruptRequested = 1;
        }

      if (InterruptRequested)
        {
          BacktraceAdd (State, i);
          // Set up the return stuff.
          c (RegZRUPT)= ProgramCounter + 1;
          c (RegBRUPT)= Instruction;
          // Clear various metadata. Extracode is cleared (this can only
          // really happen with EDRUPT), and the index value and substituted
          // instruction were both applied earlier and their effects were
          // saved in BRUPT.
          State->ExtraCode = 0;
          State->IndexValue = AGC_P0;
          State->SubstituteInstruction = 0;
          // Vector to the interrupt.
          State->InIsr = 1;

          // The RUPT sequence takes three MCTs (one to store BRUPT, one to
          // store ZRUPT, and one to load the first instruction of the ISR).
          State->PendDelay = 2;

          goto AllDone;
        }
    }

  //-------------------------------------------------------------------------
  // We have finally decided to execute a regular instruction. Add delay for 
  // multi-MCT instructions.  Works for all instructions except EDRUPT, BZF,
  // and BZMF. For BZF and BZMF, an extra cycle is added if the branch is
  // not taken.  EDRUPT's timing is handled with the interrupt logic.
  i = QuarterCode >> 10;
  if (State->ExtraCode)
    State->PendDelay = ExtracodeTiming[i];
  else
    State->PendDelay = InstructionTiming[i];

  // Now that the index value has been used, get rid of it.
  State->IndexValue = AGC_P0;
  // And similarly for the substitute instruction from a RESUME.
  State->SubstituteInstruction = 0;

  // Compute the next value of the instruction pointer. The Z register is
  // 16 bits long, even though in almost all cases only the lower 12 bits
  // are used. When the Z register is incremented between each instruction,
  // only the lower 12 bits are read into the adder, so if something sets
  // any of the 4 most significant bits of Z, they will be lost before
  // the next instruction sees them.
  State->NextZ = 1 + c(RegZ);
  // The contents of the Z register are updated before an instruction is
  // executed (really, it happens at the end of the previous instruction).
  c (RegZ)= State->NextZ;

  // A BZF followed by an instruction other than EXTEND causes a TCF0 transient
  if (State->TookBZF && !((ExtendedOpcode == 000) && (Address12 == 6)))
    ExecutedTC = 1;

  // Parse the instruction.  Refer to p.34 of 1689.pdf for an easy 
  // picture of what follows.
  switch (ExtendedOpcode)
    {
    case 000:			// TC.  
    case 001:
    case 002:
    case 003:
    case 004:
    case 005:
    case 006:
    case 007:
      // TC instruction (1 MCT).
      ValueK = Address12;// Convert AGC numerical format to native CPU format.
      if (ValueK == 3)		// RELINT instruction.
        {
	  State->AllowInterrupt = 1;

          if (State->TookBZF || State->TookBZMF)
            // RELINT after a single-cycle instruction causes a TC0 transient
            ExecutedTC = 1;
        }
      else if (ValueK == 4)	// INHINT instruction.
        {
	  State->AllowInterrupt = 0;

          if (State->TookBZF || State->TookBZMF)
            // INHINT after a single-cycle instruction causes a TC0 transient
            ExecutedTC = 1;
        }
      else if (ValueK == 6)	// EXTEND instruction.
	{
	  State->ExtraCode = 1;
	  // Normally, ExtraCode will be reset when agc_engine is finished.
	  // We inhibit that behavior with this flag.
	  KeepExtraCode = 1;
	}
      else
	{
	  BacktraceAdd (State, 0);
	  if (ValueK != RegQ)	// If not a RETURN instruction ...
	    c (RegQ)= 0177777 & State->NextZ;
	  State->NextZ = Address12;
          ExecutedTC = 1;
	}

      break;
    case 010:			// CCS. 
    case 011:
      // CCS instruction (2 MCT).  
      // Figure out where the data is stored, and fetch it.
      if (Address10 < REG16)
	{
	  ValueK = 0177777 & c(Address10);
	  Operand16 = OverflowCorrected (ValueK);
	  c (RegA)= odabs (ValueK);
	}
      else			// K!=accumulator.
	{
	  WhereWord = FindMemoryWord (State, Address10);
	  Operand16 = *WhereWord & 077777;
	  // Compute the "diminished absolute value", and save in accumulator.
	  c (RegA) = dabs (Operand16);
	  // Assign back the read data in case editing is needed
	  AssignFromPointer (State, WhereWord, Operand16);
	}
      // Now perform the actual comparison and jump on the basis
      // of it.  There's no explanation I can find as to what
      // happens if we're already at the end of the memory bank,
      // so I'll just pretend that that can't happen.  Note, 
      // by the way, that if the Operand is > +0, then NextZ
      // is already correct, and in the other cases we need to
      // increment it by 2 less because NextZ has already been 
      // incremented.
      if (Address10 < REG16
	  && ValueOverflowed (ValueK) == AGC_P1)
      State->NextZ += 0;
      else if (Address10 < REG16
	  && ValueOverflowed (ValueK) == AGC_M1)
      State->NextZ += 2;
      else if (Operand16 == AGC_P0)
      State->NextZ += 1;
      else if (Operand16 == AGC_M0)
      State->NextZ += 3;
      else if (0 != (Operand16 & 040000))
      State->NextZ += 2;
      break;
      case 012:// TCF.
      case 013:
      case 014:
      case 015:
      case 016:
      case 017:
      BacktraceAdd (State, 0);
      // TCF instruction (1 MCT).
      State->NextZ = Address12;
      // THAT was easy ... too easy ...
      ExecutedTC = 1;
      break;
      case 020:// DAS.
      case 021:
      //DasInstruction:
      // DAS instruction (3 MCT).  
	{
	  // We add the less-significant words (as SP values), and thus
	  // the sign of the lower word of the output does not necessarily
	  // match the sign of the upper word.
	  int Msw, Lsw;
	  if (IsL (Address10))// DDOUBL
	    {
	      Lsw = AddSP16 (0177777 & c (RegL), 0177777 & c (RegL));
	      Msw = AddSP16 (Accumulator, Accumulator);
	      if ((0140000 & Lsw) == 0040000)
	      Msw = AddSP16 (Msw, AGC_P1);
	      else if ((0140000 & Lsw) == 0100000)
	      Msw = AddSP16 (Msw, SignExtend (AGC_M1));
	      Lsw = OverflowCorrected (Lsw);
	      c (RegA) = 0177777 & Msw;
	      c (RegL) = 0177777 & SignExtend (Lsw);
	      break;
	    }
	  WhereWord = FindMemoryWord (State, Address10);
	  if (Address10 < REG16)
	  Lsw = AddSP16 (0177777 & c (RegL), 0177777 & c (Address10));
	  else
	  Lsw = AddSP16 (0177777 & c (RegL), SignExtend (*WhereWord));
	  if (Address10 < REG16 + 1)
	  Msw = AddSP16 (Accumulator, 0177777 & c (Address10 - 1));
	  else
	  Msw = AddSP16 (Accumulator, SignExtend (WhereWord[-1]));

	  if ((0140000 & Lsw) == 0040000)
	  Msw = AddSP16 (Msw, AGC_P1);
	  else if ((0140000 & Lsw) == 0100000)
	  Msw = AddSP16 (Msw, SignExtend (AGC_M1));
	  Lsw = OverflowCorrected (Lsw);

	  if ((0140000 & Msw) == 0100000)
	  c (RegA) = SignExtend (AGC_M1);
	  else if ((0140000 & Msw) == 0040000)
	  c (RegA) = AGC_P1;
	  else
	  c (RegA) = AGC_P0;
	  c (RegL) = AGC_P0;
	  // Save the results.
	  if (Address10 < REG16)
	  c (Address10) = SignExtend (Lsw);
	  else
	  AssignFromPointer (State, WhereWord, Lsw);
	  if (Address10 < REG16 + 1)
	  c (Address10 - 1) = Msw;
	  else
	  AssignFromPointer (State, WhereWord - 1, OverflowCorrected (Msw));
	}
      break;
      case 022:			// LXCH.
      case 023:
      // "LXCH K" instruction (2 MCT). 
      if (IsL (Address10))
      break;
      if (IsReg (Address10, RegZERO))// ZL
      c (RegL) = AGC_P0;
      else if (Address10 < REG16)
	{
	  Operand16 = c (RegL);
	  c (RegL) = c (Address10);
	  if (Address10 >= 020 && Address10 <= 023)
	  AssignFromPointer (State, WhereWord,
	      OverflowCorrected (0177777 & Operand16));
	  else
	  c (Address10) = Operand16;
	  if (Address10 == RegZ)
	  State->NextZ = c (RegZ);
	}
      else
	{
	  WhereWord = FindMemoryWord (State, Address10);
	  Operand16 = *WhereWord;
	  AssignFromPointer (State, WhereWord,
	      OverflowCorrected (0177777 & c (RegL)));
	  c (RegL) = SignExtend (Operand16);
	}
      break;
      case 024:			// INCR.
      case 025:
      // INCR instruction (2 MCT).
	{
	  int Sum;
	  WhereWord = FindMemoryWord (State, Address10);
	  if (Address10 < REG16)
	  c (Address10) = AddSP16 (AGC_P1, 0177777 & c (Address10));
	  else
	    {
	      Sum = AddSP16 (AGC_P1, SignExtend (*WhereWord));
	      AssignFromPointer (State, WhereWord, OverflowCorrected (Sum));
              if (ValueOverflowed (Sum) == AGC_P1)
	        OverflowInterrupt (State, Address10);
	    }
	}
      break;
      case 026:			// ADS.  Reviewed against Blair-Smith.
      case 027:
      // ADS instruction (2 MCT).
	{
	  WhereWord = FindMemoryWord (State, Address10);
	  if (IsA (Address10))
	  Accumulator = AddSP16 (Accumulator, Accumulator);
	  else if (Address10 < REG16)
	  Accumulator = AddSP16 (Accumulator, 0177777 & c (Address10));
	  else
	  Accumulator = AddSP16 (Accumulator, SignExtend (*WhereWord));
	  c (RegA) = Accumulator;
	  if (IsA (Address10))
	    {
	    }
	  else if (Address10 < REG16)
	  c (Address10) = Accumulator;
	  else
	  AssignFromPointer (State, WhereWord,
	      OverflowCorrected (Accumulator));
	}
      break;
      case 030:			// CA
      case 031:
      case 032:
      case 033:
      case 034:
      case 035:
      case 036:
      case 037:
      if (IsA (Address12))// NOOP
      break;
      if (Address12 < REG16)
	{
	  c (RegA) = c (Address12);;
	  break;
	}
      WhereWord = FindMemoryWord (State, Address12);
      c (RegA) = SignExtend (*WhereWord);
      AssignFromPointer (State, WhereWord, *WhereWord);
      break;
      case 040:			// CS
      case 041:
      case 042:
      case 043:
      case 044:
      case 045:
      case 046:
      case 047:
      ExecutedTC = 1; // CS causes transients on the TC0 line

      if (IsA (Address12))// COM
	{
	  c (RegA) = ~Accumulator;;
	  break;
	}
      if (Address12 < REG16)
	{
	  c (RegA) = ~c (Address12);
	  break;
	}
      WhereWord = FindMemoryWord (State, Address12);
      c (RegA) = SignExtend (NegateSP (*WhereWord));
      AssignFromPointer (State, WhereWord, *WhereWord);
      break;
      case 050:			// INDEX
      case 051:
      if (Address10 == 017)
      goto Resume;
      if (Address10 < REG16)
      State->IndexValue = OverflowCorrected (c (Address10));
      else
	{
	  WhereWord = FindMemoryWord (State, Address10);
	  State->IndexValue = *WhereWord;
	}
      break;
      case 0150:			// INDEX (continued)
      case 0151:
      case 0152:
      case 0153:
      case 0154:
      case 0155:
      case 0156:
      case 0157:
      if (Address12 == 017 << 1)
	{
	  Resume:
	  if (State->InIsr)
	  BacktraceAdd (State, 255);
	  else
	  BacktraceAdd (State, 0);
	  State->NextZ = c (RegZRUPT) - 1;
	  State->InIsr = 0;
	  State->SubstituteInstruction = 1;
	}
      else
	{
	  if (Address12 < REG16)
	  State->IndexValue = OverflowCorrected (c (Address12));
	  else
	    {
	      WhereWord = FindMemoryWord (State, Address12);
	      State->IndexValue = *WhereWord;
	    }
	  KeepExtraCode = 1;
	}
      break;
      case 052:			// DXCH
      case 053:
      ExecutedTC = 1; // DXCH causes transients on the TCF0 line

      // Remember, in the following comparisons, that the address is pre-incremented.
      if (IsL (Address10))
	{
	  c (RegL) = SignExtend (OverflowCorrected (c (RegL)));
	  break;
	}
      WhereWord = FindMemoryWord (State, Address10);
      // Topmost word.
      if (Address10 < REG16)
	{
	  Operand16 = c (Address10);
	  c (Address10) = c (RegL);
	  c (RegL) = Operand16;
	  if (Address10 == RegZ)
	  State->NextZ = c (RegZ);
	}
      else
	{
	  Operand16 = SignExtend (*WhereWord);
	  AssignFromPointer (State, WhereWord, OverflowCorrected (c (RegL)));
	  c (RegL) = Operand16;
	}
      c (RegL) = SignExtend (OverflowCorrected (c (RegL)));
      // Bottom word.
      if (Address10 < REG16 + 1)
	{
	  Operand16 = c (Address10 - 1);
	  c (Address10 - 1) = c (RegA);
	  c (RegA) = Operand16;
	  if (Address10 == RegZ + 1)
	  State->NextZ = c (RegZ);
	}
      else
	{
	  Operand16 = SignExtend (WhereWord[-1]);
	  AssignFromPointer (State, WhereWord - 1,
	      OverflowCorrected (c (RegA)));
	  c (RegA) = Operand16;
	}
      break;
      case 054:			// TS
      case 055:
      ExecutedTC = 1; // TS causes transients on the TCF0 line
      if (IsA (Address10))// OVSK
	{
	  if (Overflow)
	  State->NextZ += AGC_P1;
	}
      else if (IsZ (Address10))	// TCAA
	{
	  State->NextZ = (077777 & Accumulator);
	  if (Overflow)
	  c (RegA) = SignExtend (ValueOverflowed (Accumulator));
	}
      else			// Not OVSK or TCAA.
	{
	  WhereWord = FindMemoryWord (State, Address10);
	  if (Address10 < REG16)
	  c (Address10) = Accumulator;
	  else
	  AssignFromPointer (State, WhereWord,
	      OverflowCorrected (Accumulator));
	  if (Overflow)
	    {
	      c (RegA) = SignExtend (ValueOverflowed (Accumulator));
	      State->NextZ += AGC_P1;
	    }
	}
      break;
      case 056:			// XCH
      case 057:
      ExecutedTC = 1; // XCH causes transients on the TCF0 line
      if (IsA (Address10))
      break;
      if (Address10 < REG16)
	{
	  c (RegA) = c (Address10);
	  c (Address10) = Accumulator;
	  if (Address10 == RegZ)
	  State->NextZ = c (RegZ);
	  break;
	}
      WhereWord = FindMemoryWord (State, Address10);
      c (RegA) = SignExtend (*WhereWord);
      AssignFromPointer (State, WhereWord, OverflowCorrected (Accumulator));
      break;
      case 060:			// AD
      case 061:
      case 062:
      case 063:
      case 064:
      case 065:
      case 066:
      case 067:
      if (IsA (Address12))// DOUBLE
      Accumulator = AddSP16 (Accumulator, Accumulator);
      else if (Address12 < REG16)
      Accumulator = AddSP16 (Accumulator, 0177777 & c (Address12));
      else
	{
	  WhereWord = FindMemoryWord (State, Address12);
	  Accumulator = AddSP16 (Accumulator, SignExtend (*WhereWord));
	  AssignFromPointer (State, WhereWord, *WhereWord);
	}
      c (RegA) = Accumulator;
      break;
      case 070:			// MASK
      case 071:
      case 072:
      case 073:
      case 074:
      case 075:
      case 076:
      case 077:
      if (Address12 < REG16)
      c (RegA) = Accumulator & c (Address12);
      else
	{
	  c (RegA) = OverflowCorrected (Accumulator);
	  WhereWord = FindMemoryWord (State, Address12);
	  c (RegA) = SignExtend (c (RegA) & *WhereWord);
	}
      break;
      case 0100:			// READ
      if (IsL (Address9) || IsQ (Address9))
      c (RegA) = c (Address9);
      else
      c (RegA) = SignExtend (ReadIO (State, Address9));
      break;
      case 0101:// WRITE
      if (IsL (Address9) || IsQ (Address9))
      c (Address9) = Accumulator;
      else
      CpuWriteIO (State, Address9, OverflowCorrected (Accumulator));
      break;
      case 0102:// RAND
      if (IsL (Address9) || IsQ (Address9))
      c (RegA) = (Accumulator & c (Address9));
      else
	{
	  Operand16 = OverflowCorrected (Accumulator);
	  Operand16 &= ReadIO (State, Address9);
	  c (RegA) = SignExtend (Operand16);
	}
      break;
      case 0103:			// WAND
      if (IsL (Address9) || IsQ (Address9))
      c (RegA) = c (Address9) = (Accumulator & c (Address9));
      else
	{
	  Operand16 = OverflowCorrected (Accumulator);
	  Operand16 &= ReadIO (State, Address9);
	  CpuWriteIO (State, Address9, Operand16);
	  c (RegA) = SignExtend (Operand16);
	}
      break;
      case 0104:			// ROR
      if (IsL (Address9) || IsQ (Address9))
      c (RegA) = (Accumulator | c (Address9));
      else
	{
	  Operand16 = OverflowCorrected (Accumulator);
	  Operand16 |= ReadIO (State, Address9);
	  c (RegA) = SignExtend (Operand16);
	}
      break;
      case 0105:			// WOR
      if (IsL (Address9) || IsQ (Address9))
      c (RegA) = c (Address9) = (Accumulator | c (Address9));
      else
	{
	  Operand16 = OverflowCorrected (Accumulator);
	  Operand16 |= ReadIO (State, Address9);
	  CpuWriteIO (State, Address9, Operand16);
	  c (RegA) = SignExtend (Operand16);
	}
      break;
      case 0106:			// RXOR
      if (IsL (Address9) || IsQ (Address9))
      c (RegA) = (Accumulator ^ c (Address9));
      else
	{
	  Operand16 = OverflowCorrected (Accumulator);
	  Operand16 ^= ReadIO (State, Address9);
	  c (RegA) = SignExtend (Operand16);
	}
      break;
      case 0107:			// EDRUPT
      // It shouldn't be possible to get here, since EDRUPT is treated
      // as an interrupt above.
      break;
      case 0110:			// DV
      case 0111:
	{
	  int16_t AccPair[2], AbsA, AbsL, AbsK, Div16;
	  int Dividend, Divisor, Quotient, Remainder;

	  AccPair[0] = OverflowCorrected (Accumulator);
	  AccPair[1] = c (RegL);
	  Dividend = SpToDecent (&AccPair[1]);
	  DecentToSp (Dividend, &AccPair[1]);
	  // Check boundary conditions.
	  AbsA = AbsSP (AccPair[0]);
	  AbsL = AbsSP (AccPair[1]);

	  if (IsA (Address10))
	    {
	      // DV modifies A before reading the divisor, so in this
	      // case the divisor is -|A|.
              Div16 = c(RegA);
	      if ((c(RegA) & 0100000) == 0)
	        Div16 = 0177777 & ~Div16;
	    }
          else if (IsL (Address10))
	    {
	      // DV modifies L before reading the divisor. L is first
	      // negated if the quotient A,L is negative according to
	      // DV sign rules. Then, 40000 is added to it.
	      Div16 = c(RegL);
              if (((AbsA == 0) && (0100000 & c(RegL))) || ((AbsA != 0) && (0100000 & c(RegA))))
	        Div16 = 0177777 & ~Div16;
              // Make sure to account for L's built-in overflow correction
              Div16 = SignExtend(OverflowCorrected(AddSP16((uint16_t)Div16, 040000)));
	    }
          else if (IsZ (Address10))
	    {
	      // DV modifies Z before reading the divisor. If the
	      // quotient A,L is negative according to DV sign rules,
	      // Z16 is set.
	      Div16 = c(RegZ);
              if (((AbsA == 0) && (0100000 & c(RegL))) || ((AbsA != 0) && (0100000 & c(RegA))))
	        Div16 |= 0100000;
	    }
	  else if (Address10 < REG16)
	    Div16 = c(Address10);
	  else
            Div16 = SignExtend(*FindMemoryWord(State, Address10));

	  // Fetch the values;
	  AbsK = AbsSP(OverflowCorrected(Div16));
	  if (AbsA > AbsK || (AbsA == AbsK && AbsL != AGC_P0) || ValueOverflowed(Div16) != AGC_P0)
	    {
	      // The divisor is smaller than the dividend, or the divisor has
	      // overflow. In both cases, we fall back on a slower simulation
	      // of the hardware registers, which will produce "total nonsense"
	      // (that nonetheless will match what the actual AGC would have gotten).
              SimulateDV(State, Div16);
	    }
	  else if (AbsA == 0 && AbsL == 0)
	    {
	      // The dividend is 0 but the divisor is not. The standard DV sign
	      // convention applies to A, and L remains unchanged.
	      if ((040000 & c (RegL)) == (040000 & OverflowCorrected(Div16)))
                {
                  if (AbsK == 0) Operand16 = 037777;	// Max positive value.
                  else Operand16 = AGC_P0;
                }
	      else
                {
                  if (AbsK == 0) Operand16 = (077777 & ~037777);	// Max negative value.
                  else Operand16 = AGC_M0;
                }

	      c (RegA) = SignExtend (Operand16);
	    }
	  else if (AbsA == AbsK && AbsL == AGC_P0)
	    {
	      // The divisor is equal to the dividend.
	      if (AccPair[0] == OverflowCorrected(Div16))// Signs agree?
		{
		  Operand16 = 037777;	// Max positive value.
		}
	      else
		{
		  Operand16 = (077777 & ~037777);	// Max negative value.
		}
	      c (RegL) = SignExtend(AccPair[0]);
	      c (RegA) = SignExtend(Operand16);
	    }
	  else
	    {
	      // The divisor is larger than the dividend.  Okay to actually divide!
	      // Fortunately, the sign conventions agree with those of the normal
	      // C operators / and %, so all we need to do is to convert the
	      // 1's-complement values to native CPU format to do the division,
	      // and then convert back afterward.  Incidentally, we know we
	      // aren't dividing by zero, since we know that the divisor is
	      // greater (in magnitude) than the dividend.
	      Dividend = agc2cpu2 (Dividend);
	      Divisor = agc2cpu (OverflowCorrected(Div16));
	      Quotient = Dividend / Divisor;
	      Remainder = Dividend % Divisor;
	      c (RegA) = SignExtend (cpu2agc (Quotient));
	      if (Remainder == 0)
		{
		  // In this case, we need to make an extra effort, because we
		  // might need -0 rather than +0.
		  if (Dividend >= 0)
		  c (RegL) = AGC_P0;
		  else
		  c (RegL) = SignExtend (AGC_M0);
		}
	      else
	      c (RegL) = SignExtend (cpu2agc (Remainder));
	    }
	}
      break;
      case 0112:			// BZF
      case 0113:
      case 0114:
      case 0115:
      case 0116:
      case 0117:
      //Operand16 = OverflowCorrected (Accumulator);
      //if (Operand16 == AGC_P0 || Operand16 == AGC_M0)
      if (Accumulator == 0 || Accumulator == 0177777)
	{
	  BacktraceAdd (State, 0);
	  State->NextZ = Address12;
          JustTookBZF = 1;
	}
      else
        State->PendDelay++;
      break;
      case 0120:			// MSU
      case 0121:
	{
	  unsigned ui, uj;
	  int diff;
	  WhereWord = FindMemoryWord (State, Address10);
	  if (Address10 < REG16)
	    {
	      ui = 0177777 & Accumulator;
	      uj = 0177777 & ~c (Address10);
	    }
	  else
	    {
	      ui = (077777 & OverflowCorrected (Accumulator));
	      uj = (077777 & ~*WhereWord);
	    }
	  diff = ui + uj + 1; // Two's complement subtraction -- add the complement plus one
	  // The AGC sign-extends the result from A15 to A16, then checks A16 to see if
	  // one needs to be subtracted. We'll go in the opposite order, which also works
	  if (diff & 040000)
	    {
	      diff |= 0100000; // Sign-extend A15 into A16
	      diff--; // Subtract one from the result
	    }
	  if (IsQ (Address10))
	  c (RegA) = 0177777 & diff;
	  else
	    {
	      Operand16 = (077777 & diff);
	      c (RegA) = SignExtend (Operand16);
	    }
	  if (Address10 >= 020 && Address10 <= 023)
	  AssignFromPointer (State, WhereWord, *WhereWord);
	}
      break;
      case 0122:			// QXCH
      case 0123:
      if (IsQ (Address10))
      break;
      if (IsReg (Address10, RegZERO))// ZQ
      c (RegQ) = AGC_P0;
      else if (Address10 < REG16)
	{
	  Operand16 = c (RegQ);
	  c (RegQ) = c (Address10);
	  c (Address10) = Operand16;
	  if (Address10 == RegZ)
	  State->NextZ = c (RegZ);
	}
      else
	{
	  WhereWord = FindMemoryWord (State, Address10);
	  Operand16 = OverflowCorrected (c (RegQ));
	  c (RegQ) = SignExtend (*WhereWord);
	  AssignFromPointer (State, WhereWord, Operand16);
	}
      break;
      case 0124:			// AUG
      case 0125:
	{
	  int Sum;
	  int Operand16, Increment;
	  WhereWord = FindMemoryWord (State, Address10);
	  if (Address10 < REG16)
	  Operand16 = c (Address10);
	  else
	  Operand16 = SignExtend (*WhereWord);
	  Operand16 &= 0177777;
	  if (0 == (0100000 & Operand16))
	  Increment = AGC_P1;
	  else
	  Increment = SignExtend (AGC_M1);
	  Sum = AddSP16 (0177777 & Increment, 0177777 & Operand16);
	  if (Address10 < REG16)
	  c (Address10) = Sum;
	  else
	    {
	      AssignFromPointer (State, WhereWord, OverflowCorrected (Sum));
              if (ValueOverflowed (Sum) == AGC_P1)
	        OverflowInterrupt (State, Address10);
	    }
	}
      break;
      case 0126:			// DIM
      case 0127:
	{
	  int Sum;
	  int Operand16, Increment;
	  WhereWord = FindMemoryWord (State, Address10);
	  if (Address10 < REG16)
	  Operand16 = c (Address10);
	  else
	  Operand16 = SignExtend (*WhereWord);
	  Operand16 &= 0177777;
	  if (Operand16 == AGC_P0 || Operand16 == SignExtend (AGC_M0))
	  break;
	  if (0 == (0100000 & Operand16))
	  Increment = SignExtend (AGC_M1);
	  else
	  Increment = AGC_P1;
	  Sum = AddSP16 (0177777 & Increment, 0177777 & Operand16);
	  if (Address10 < REG16)
	  c (Address10) = Sum;
	  else
	  AssignFromPointer (State, WhereWord, OverflowCorrected (Sum));
	}
      break;
      case 0130:			// DCA
      case 0131:
      case 0132:
      case 0133:
      case 0134:
      case 0135:
      case 0136:
      case 0137:
      if (IsL (Address12))
	{
	  c (RegL) = SignExtend (OverflowCorrected (c (RegL)));
	  break;
	}
      WhereWord = FindMemoryWord (State, Address12);
      // Do topmost word first.
      if (Address12 < REG16)
      c (RegL) = c (Address12);
      else
      c (RegL) = SignExtend (*WhereWord);
      c (RegL) = SignExtend (OverflowCorrected (c (RegL)));
      // Now do bottom word.
      if (Address12 < REG16 + 1)
      c (RegA) = c (Address12 - 1);
      else
      c (RegA) = SignExtend (WhereWord[-1]);
      if (Address12 >= 020 && Address12 <= 023)
      AssignFromPointer (State, WhereWord, WhereWord[0]);
      if (Address12 >= 020 + 1 && Address12 <= 023 + 1)
      AssignFromPointer (State, WhereWord - 1, WhereWord[-1]);
      break;
      case 0140:// DCS
      case 0141:
      case 0142:
      case 0143:
      case 0144:
      case 0145:
      case 0146:
      case 0147:
      if (IsL (Address12))// DCOM
	{
	  c (RegA) = ~Accumulator;
	  c (RegL) = ~c (RegL);
	  c (RegL) = SignExtend (OverflowCorrected (c (RegL)));
	  break;
	}
      WhereWord = FindMemoryWord (State, Address12);
      // Do topmost word first.
      if (Address12 < REG16)
      c (RegL) = ~c (Address12);
      else
      c (RegL) = ~SignExtend (*WhereWord);
      c (RegL) = SignExtend (OverflowCorrected (c (RegL)));
      // Now do bottom word.
      if (Address12 < REG16 + 1)
      c (RegA) = ~c (Address12 - 1);
      else
      c (RegA) = ~SignExtend (WhereWord[-1]);
      if (Address12 >= 020 && Address12 <= 023)
      AssignFromPointer (State, WhereWord, WhereWord[0]);
      if (Address12 >= 020 + 1 && Address12 <= 023 + 1)
      AssignFromPointer (State, WhereWord - 1, WhereWord[-1]);
      break;
      // For 0150..0157 see the INDEX instruction above.
      case 0160:// SU
      case 0161:
      if (IsA (Address10))
      Accumulator = SignExtend (AGC_M0);
      else if (Address10 < REG16)
      Accumulator = AddSP16 (Accumulator, 0177777 & ~c (Address10));
      else
	{
	  WhereWord = FindMemoryWord (State, Address10);
	  Accumulator =
	  AddSP16 (Accumulator, SignExtend (NegateSP (*WhereWord)));
	  AssignFromPointer (State, WhereWord, *WhereWord);
	}
      c (RegA) = Accumulator;
      break;
      case 0162:			// BZMF
      case 0163:
      case 0164:
      case 0165:
      case 0166:
      case 0167:
      //Operand16 = OverflowCorrected (Accumulator);
      //if (Operand16 == AGC_P0 || IsNegativeSP (Operand16))
      if (Accumulator == 0 || 0 != (Accumulator & 0100000))
	{
	  BacktraceAdd (State, 0);
	  State->NextZ = Address12;
          JustTookBZMF = 1;
	}
      else
        State->PendDelay++;
      break;
      case 0170:			// MP
      case 0171:
      case 0172:
      case 0173:
      case 0174:
      case 0175:
      case 0176:
      case 0177:
	{
	  // For MP A (i.e., SQUARE) the accumulator is NOT supposed to
	  // be overflow-corrected.  I do it anyway, since I don't know
	  // what it would mean to carry out the operation otherwise.
	  // Fix later if it causes a problem.
	  // FIX ME: Accumulator is overflow-corrected before SQUARE.
	  int16_t MsWord, LsWord, OtherOperand16;
	  int Product;
	  WhereWord = FindMemoryWord (State, Address12);
	  Operand16 = OverflowCorrected (Accumulator);
	  if (Address12 < REG16)
	  OtherOperand16 = OverflowCorrected (c (Address12));
	  else
	  OtherOperand16 = *WhereWord;
	  if (OtherOperand16 == AGC_P0 || OtherOperand16 == AGC_M0)
	  MsWord = LsWord = AGC_P0;
	  else if (Operand16 == AGC_P0 || Operand16 == AGC_M0)
	    {
	      if ((Operand16 == AGC_P0 && 0 != (040000 & OtherOperand16)) ||
		  (Operand16 == AGC_M0 && 0 == (040000 & OtherOperand16)))
	      MsWord = LsWord = AGC_M0;
	      else
	      MsWord = LsWord = AGC_P0;
	    }
	  else
	    {
	      int16_t WordPair[2];
	      Product =
	      agc2cpu (SignExtend (Operand16)) *
	      agc2cpu (SignExtend (OtherOperand16));
	      Product = cpu2agc2 (Product);
	      // Sign-extend, because it's needed for DecentToSp.
	      if (02000000000 & Product)
	      Product |= 004000000000;
	      // Convert back to DP.
	      DecentToSp (Product, &WordPair[1]);
	      MsWord = WordPair[0];
	      LsWord = WordPair[1];
	    }
	  c (RegA) = SignExtend (MsWord);
	  c (RegL) = SignExtend (LsWord);
	}
      break;
      default:
      // Isn't possible to get here, but still ...
      //printf ("Unrecognized instruction %06o.\n", Instruction);
      break;
    }

  AllDone:
  c (RegZERO)= AGC_P0;
  State->InputChannel[7] = State->OutputChannel7 &= 0160;
  c (RegZ) = State->NextZ;
  // In all cases except for RESUME, Z will be truncated to
  // 12 bits between instructions
  if (!State->SubstituteInstruction)
    c (RegZ) = c(RegZ) & 07777;
  if (!KeepExtraCode)
    State->ExtraCode = 0;
  // Values written to EB and FB are automatically mirrored to BB,
  // and vice versa.
  if (CurrentBB != c (RegBB))
    {
      c (RegFB) = (c (RegBB) & 076000);
      c (RegEB) = (c (RegBB) & 07) << 8;
    }
  else if (CurrentEB != c (RegEB) || CurrentFB != c (RegFB))
    c (RegBB) = (c (RegFB) & 076000) | ((c (RegEB) & 03400) >> 8);
  c (RegEB) &= 03400;
  c (RegFB) &= 076000;
  c (RegBB) &= 076007;
  // Correct overflow in the L register (this is done on read in the original,
  // but is much easier here)
  c(RegL) = SignExtend (OverflowCorrected (c(RegL)));

  // Check ISR status, and clear the Rupt Lock flags accordingly
  if (State->InIsr) State->NoRupt = 0;
  else State->RuptLock = 0;

  // Update TC Trap flags according to the instruction we just executed
  if (ExecutedTC) State->NoTC = 0;
  else State->TCTrap = 0;

  State->TookBZF = JustTookBZF;
  State->TookBZMF = JustTookBZMF;

  return (0);
}
