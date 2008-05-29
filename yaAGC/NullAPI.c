/*
  Copyright 2004-2005 Ronald S. Burkey <info@sandroid.org>
  
  This file is part of yaAGC.

  yaAGC is free software; you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation; either version 2 of the License, or
  (at your option) any later version.

  yaAGC is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with yaAGC; if not, write to the Free Software
  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

  In addition, as a special exception, Ronald S. Burkey gives permission to
  link the code of this program with the Orbiter SDK library (or with 
  modified versions of the Orbiter SDK library that use the same license as 
  the Orbiter SDK library), and distribute linked combinations including 
  the two. You must obey the GNU General Public License in all respects for 
  all of the code used other than the Orbiter SDK library. If you modify 
  this file, you may extend this exception to your version of the file, 
  but you are not obligated to do so. If you do not wish to do so, delete 
  this exception statement from your version. 
 
  Filename:	NullAPI.c
  Purpose:	This is sort of a template that shows how to write functions
  		that customize the yaAGC-to-peripheral interface.
		(I advise you not to, unless you are using yaAGC as 
		embedded firmware, but I show you how to do it 
		anyway.)
  Compiler:	GNU gcc.
  Contact:	Ron Burkey <info@sandroid.org>
  Reference:	http://www.ibiblio.org/apollo/index.html
  Mods:		08/18/04 RSB.	Created.
		02/27/05 RSB	Added the license exception, as required by
				the GPL, for linking to Orbiter SDK libraries.
		05/14/05 RSB	Corrected website references.
		05/31/05 RSB	Added ShiftToDeda.
*/

#ifdef WIN32
typedef unsigned short uint16_t;
#endif
#include "yaAGC.h"
#include "agc_engine.h"

//-----------------------------------------------------------------------------
// Any kind of setup needed by your i/o-channel model.

static int ChannelIsSetUp = 0;

static void
ChannelSetup (agc_t *State)
{

  ChannelIsSetUp = 1;
  
  // ... anything you like ...
  
}

//-----------------------------------------------------------------------------
// The simulated CPU in yaAGC calls this function whenever it wants to write 
// output data to an "i/o channel", other than i/o channels 1 and 2, which are
// overlapped with the L and Q central registers.  For example, in an embedded
// design, this would physically control the individual electrical signals 
// comprising the i/o port.  In my recommended reference design (see
// SocketAPI.c) data would be streamed out a socket connection from a port.
// In a customized version, FOR EXAMPLE, data might be written to a shared 
// memory array, and other execution threads might be woken up to process the
// changed data.   

void
ChannelOutput (agc_t * State, int Channel, int Value)
{

  if (!ChannelIsSetUp)
    ChannelSetup (State);

  // ... anything you like ...  
  // You don't need to worry about channels 1 and 2 here.
  
  // By the way, note that some output channels are latched by relays
  // external to the CPU.  For example, 4 bits of the Value of 
  // Channel 10 (octal) select one of 16 rows of latches.  Therefore,
  // the 15-bit channel 10 is effectively 16 separate 11-bit registers.
  // You may need to account for this in your model.
  
}

//----------------------------------------------------------------------
// The simulated CPU in yaAGC calls this function to check for input data
// once for each call to agc_engin.  This input data may be of two kinds:
// 	1. Data available on an "i/o channel"; in this case, a value
//	   of 0 is returned; you can handle as much or as little data
//	   of this kind in any given invocation; or
//	2. A request for an "unprogrammed sequence" to automatically
//	   increment or decrement a counter.  In this case a value of
//	   1 is returned.  The function must return immediately upon
//	   one of these requests, in order ot preserve system timing.
// The former type of data is supposed to be directly written to the 
// array State->InputChannel[], while the latter is supposed to call the
// function UnprogrammedIncrement() to handle the actual incrementing.
// ChannelInput() has the responsibility of raising an interrupt-request 
// flag (in the array State->InterruptRequests[]) if the i/o channel
// data is supposed to cause an interrupt.  (An example would
// be if the input data represented a DSKY keystroke.)  Interrupt-raising
// due to overflow of counters is handled automatically by the function
// UnprogrammedChannel() and doesn't need to be addressed directly.
//
// For example, in an embedded design, this input data would reflect the
// physical states of individual electrical signals.  
// In my recommended reference design (see SocketAPI.c) the data would be 
// taken from an incoming stream of a socket connection to a port.
// In a customized version, FOR EXAMPLE, data might indicate changes in a 
// shared memory array partially controlled by other execution threads.   
//
// Note:  You are guaranteed that yaAGC processes at least one instruction
// between any two calls to ChannelInput.

int
ChannelInput (agc_t *State)
{
  int RetVal = 0;

  if (!ChannelIsSetUp)
    ChannelSetup (State);

  // If there are changes to the input channels, write the data
  // directly to the array State->InputChannel[].  Don't forget to 
  // raise a flag in State->InterruptRequests if the incoming data
  // is supposed to do that.  (Mainly, DSKY keystrokes.)
  
  // If the inputs request unprogrammed counter-increment sequences,
  // then call the function UnprogrammedChannel(State,Counter,IncType)
  // to process them.  The different unprogrammed sequences are 
  // related to the IncTypes as follows:
  //	PINC	000
  //	PCDU	001
  //	MINC	002
  //	MCDU	003
  //	DINC	004
  //	SHINC	005
  //	SHANC	006
  // (Refer to the developer page on www.ibiblio.org/apollo/index.html.)
  // Only registers 32 (octal) through 60 (octal) may actually used as
  // counters, and not all of them.  (Refer to the AGC assembly-language 
  // manual at www.ibiblio.org/apollo/index.html.)
  
  return (RetVal);
}

//----------------------------------------------------------------------
// A function for handling anything routinely needed (i.e., executed on
// a regular schedule) by the i/o channel model of ChannelInput and
// ChannelOutput.  There are no good reasons that I know of why this
// would be needed, other than by my reference model (see SocketAPI.c),
// so you might just want to let this empty.

void
ChannelRoutine (agc_t *State)
{

  if (!ChannelIsSetUp)
    ChannelSetup (State);
    
  // ... anything you like ...

}

//----------------------------------------------------------------------
// This function is useful only for debugging the socket interface, and
// so can be left as-is.

void 
ShiftToDeda (agc_t *State, int Data)
{
}


