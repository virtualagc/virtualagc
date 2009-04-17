/*
  Copyright 2003-2005,2009 Ronald S. Burkey <info@sandroid.org>

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

  Filename:	SocketAPI.c
  Purpose:	This is an implementation of yaAGC-to-peripheral
  		communications by means of a socket interface.  If some
		other means of communications is desired, such as a
		memory-mapped i/o-channel interface, just replace the
		functions in this file with alternate functions.
  Compiler:	GNU gcc.
  Contact:	Ron Burkey <info@sandroid.org>
  Reference:	http://www.ibiblio.org/apollo/index.html
  Mods:		08/18/04 RSB.	Split off from agc_engine.c.
		02/27/05 RSB	Added the license exception, as required by
				the GPL, for linking to Orbiter SDK libraries.
		05/14/05 RSB	Corrected website references.
		05/15/05 RSB	Fixed bug in which counter increments
				would endlessly recur.  SOCKET_API_C added
				for agc_engine.h.
		05/31/05 RSB	--debug-deda mode.
		06/05/05 RSB	Corrected polarity of discretes in
				--debug-deda mode.  Corrected positioning
				of bits in the "input discretes".
		06/07/05 RSB	Fixed bit positioning in DEDA shift
				register.
		06/26/05 RSB	Accounted for uplinked data.
		07/09/05 RSB	Accounted for rotational hand controller (RHC)
				in LM. In retrospect, this is a bad place
				to handle it, since it won't automatically
				be handled in NullAPI.c.  I'll worry about
				that later.
		03/11/09 RSB	Added casts of various char types (unsigned
				char, char, const char) to other char types
				for function parameters.  Without these,
				there were fatal compilation errors with
				some versions of g++.
		03/18/09 RSB	Removed printed messages about adding/removing
				sockets when the DebugMode flag is set.
				Added some robustness checking to the
				data stream on the tcp port.
		03/19/09 RSB	Added DedaQuiet.
*/

#include <errno.h>
#include <stdlib.h>
#include <stdio.h>
#ifdef WIN32
typedef unsigned short uint16_t;
#endif
#include "yaAGC.h"
#define SOCKET_API_C
#include "agc_engine.h"

//-----------------------------------------------------------------------------
// Function for broadcasting "output channel" data to all connected clients of
// yaAGC.

void
ChannelOutput (agc_t * State, int Channel, int Value)
{
  int i, j;
  //int n;
  Client_t *Client;
  unsigned char Packet[4];
  extern int DebugMode;
  // Some output channels have purposes within the CPU, so we have to
  // account for those separately.
  if (Channel == 7)
    {
      State->InputChannel[7] = State->OutputChannel7 = (Value & 0160);
      return;
    }
  // Stick data into the RHCCTR registers, if bits 8,9 of channel 013 are set.
  if (Channel == 013 && 0600 == (0600 & Value) && !CmOrLm)
    {
      State->Erasable[0][042] = LastRhcPitch;
      State->Erasable[0][043] = LastRhcYaw;
      State->Erasable[0][044] = LastRhcRoll;
    }
  // Most output channels are simply transmitted to clients representing
  // hardware simulations.
  if (FormIoPacket (Channel, Value, Packet))
    return;
  for (i = 0, Client = Clients; i < MAX_CLIENTS; i++, Client++)
    if (Clients[i].Socket != -1)
      {
	j = send (Client->Socket, (const char *) Packet, 4, MSG_NOSIGNAL);
	if (j == SOCKET_ERROR && SOCKET_BROKEN)
	  {
	    if (!DebugMode)
	      printf ("Removing socket %d\n", Clients[i].Socket);
#ifdef unix
	    close (Clients[i].Socket);
#else
	    closesocket (Clients[i].Socket);
#endif
	    Clients[i].Socket = -1;
	  }
      }
}

//----------------------------------------------------------------------
// A function for handling reception of "input channel" data from
// any connected client.  At most one channel of input is handled per
// call.  The function returns 0 if there is no input, or non-zero if
// there is input.  If the input causes an interrupt (as, for example,
// a keystroke from the DSKY), then the function should set the
// appropriate request in State->InterruptRequests[].
//
// The function also handles unprogrammed counter increments caused
// by inputs to the CPU.  The function returns 1 if a counter-increment
// was performed, and returns zero otherwise.

static int CurrentChannelValues[256] = { 0 };
static const unsigned char Signatures[4] = { 0x00, 0x40, 0x80, 0xC0 };
static const unsigned char SignaturesAgs[4] = { 0x00, 0xC0, 0x80, 0x40 };

int
ChannelInput (agc_t *State)
{
  static int SocketInterlace = 0;
  int i, j, k;
  unsigned char c;
  Client_t *Client;
  int Channel, Value;

  //We use SocketInterlace to slow down the number
  // of polls of the sockets.
  if (SocketInterlace > 0)
    SocketInterlace--;
  else
    {
      SocketInterlace = SocketInterlaceReload;
      for (i = 0, Client = Clients; i < MAX_CLIENTS; i++, Client++)
	if (Client->Socket != -1)
	  {
	    // We arbitrarily adopt the rule that we'll process at most one
	    // packet per client per instruction cycle.
	    for (j = Client->Size; j < 4; j++)
	      {
		k = recv (Client->Socket, (char *) &c, 1, 0);
		if (k == 0 || k == -1)
		  break;
		// 20090318 RSB.  Added this filter for a little robustness,
		// but it shouldn't be needed.
		if (!(
		      (Signatures[j] == (c & 0xC0)) ||
		      (DebugDeda && (SignaturesAgs[j] == (c & 0xC0)))
		    )
		   )
		  {
		    Client->Size = 0;
		    if (0 != (c & 0xC0))
		      {
		        j = -1;
	                continue;
		      }
		    j = 0;
		  }
		Client->Packet[Client->Size++] = c;
	      }
	    // Process a received packet.
	    if (Client->Size >= 4)
	      {
		int uBit, Type, Data;
		//printf ("Received from %d: %02X %02X %02X %02X\n",
		//	i, Client->Packet[0], Client->Packet[1],
		//	Client->Packet[2], Client->Packet[3]);
		if (!ParseIoPacket (Client->Packet, &Channel, &Value, &uBit))
		  {
		    // Convert to AGC format (upper 15 bits).
		    Value &= 077777;
		    if (uBit)
		      {
			Client->ChannelMasks[Channel] = Value;
		      }
		    else if (Channel & 0x80)
		      {
		        // In this case we're dealing with a counter increment.
			// So increment the counter.
			//printf ("Channel=%02o Int=%o\n", Channel, Value);
			UnprogrammedIncrement (State, Channel, Value);
			Client->Size = 0;
			return (1);
		      }
		    else
		      {
			Value &= Client->ChannelMasks[Channel];
			Value |=
			  ReadIO (State,
				  Channel) & ~Client->ChannelMasks[Channel];
			WriteIO (State, Channel, Value);
			// If this is a keystroke from the DSKY, generate an interrupt req.
			if (Channel == 015)
			  State->InterruptRequests[5] = 1;
			// If this is on fictitious input channel 0173, then the data
			// should be placed in the INLINK counter register, and an
			// UPRUPT interrupt request should be set.
			else if (Channel == 0173)
			  {
			    State->Erasable[0][RegINLINK] = (Value & 077777);
			    State->InterruptRequests[7] = 1;
			  }
			// Fictitious registers for rotational hand controller (RHC).
			// Note that the RHC angles are not immediately used, but
			// merely squirreled away for later.  They won't actually
			// go into the counter registers until the RHC counters are
			// enabled and the data requested (bits 8,9 of channel 13).
			else if (Channel == 0166)
			  {
			    LastRhcPitch = Value;
			    ChannelOutput (State, Channel, Value);	// echo
			  }
			else if (Channel == 0167)
			  {
			    LastRhcYaw = Value;
			    ChannelOutput (State, Channel, Value);	// echo
			  }
			else if (Channel == 0170)
			  {
			    LastRhcRoll = Value;
			    ChannelOutput (State, Channel, Value);	// echo
			  }
			else if (Channel == 031)
			  {
			    static int LastInDetent = 040000;
			    int InDetent;
			    ChannelOutput (State, Channel, Value);
			    // If the RHC stick has moved out of detent,
			    // generate a RUPT10 interrupt.
			    InDetent = (040000 & Value);
			    if (LastInDetent && !InDetent)
			      State->InterruptRequests[10] = 1;
			    LastInDetent = InDetent;
			  }
			//---------------------------------------------------------------
			// For --debug-dsky mode.
			if (DebugDsky)
			  {
			    if (Channel == 032)
			      {
				// For DebugDsky purposes only, the PRO key is translated
				// to appear as the otherwise-fictitious KeyCode 0.
				if (0 != (Value & 020000))
				  {
				    Channel = 015;
				    Value = 0;
				  }
			      }
			    if (Channel == 015)
			      {
				int i, CurrentValue;
				Value &= 077777;
				for (i = 0; i < NumDebugRules; i++)
				  if (Value == DebugRules[i].KeyCode)
				    {
				      CurrentValue =
					CurrentChannelValues[DebugRules[i].
							     Channel];
				      switch (DebugRules[i].Logic)
					{
					case '=':
					  CurrentValue = DebugRules[i].Value;
					  break;
					case '|':
					  CurrentValue |= DebugRules[i].Value;
					  break;
					case '&':
					  CurrentValue &= DebugRules[i].Value;
					  break;
					case '^':
					  CurrentValue ^= DebugRules[i].Value;
					  break;
					default:
					  break;
					}
				      CurrentChannelValues[DebugRules[i].
							   Channel] =
					CurrentValue;
				      ChannelOutput (State,
						     DebugRules[i].Channel,
						     CurrentValue);
				    }
			      }
			    //if (Channel != 032 && Channel != 015)
			    //  WriteIO (State, Channel, Value);
			  }
			//---------------------------------------------------------------
		      }
		  }
		else if (DebugDeda && !ParseIoPacketAGS (Client->Packet, &Type, &Data))
		  {
		    // The following code is present only for debugging yaDEDA
		    // communications, and has no interesting purpose yaAGC-wise.
		    static unsigned char Buffer[9];
		    static int NumInBuffer = 0, NumWanted = 0, Collecting = 0;
		    static unsigned char Packet[4];
		    if (Type == 05 && (Data == 0777002 || Data == 0777004 ||
		        Data == 0777010 || Data == 0777020))
		      printf ("DEDA key release.\n");
		    else if (Collecting && Type == 07)
		      {
		        Buffer[NumInBuffer++] = Data >> 13;
			if (NumInBuffer < NumWanted)
			  send (Client->Socket, (const char *) Packet, 4, 0);
			else
			  {
			    int i;
			    Collecting = 0;
			    printf ("Received %d DEDA nibbles:", NumWanted);
			    for (i = 0; i < NumWanted; i++)
			      printf (" %1X", Buffer[i]);
			    printf ("\n");
			    if (NumWanted == 3)
			      {
			        if (!DedaQuiet)
			          DedaMonitor = 1;
				DedaAddress = Buffer[0] * 0100 + Buffer[1] * 010 + Buffer[2];
				DedaWhen = State->CycleCounter;
			      }
			  }
		      }
		    else if (Type == 05 && (Data == 0775002 || Data == 0773004))
		      {
		        NumInBuffer = 0;
			Collecting = 1;
			if (Data == 0775002)
			  {
		            printf ("Received DEDA READOUT.\n");
			    NumWanted = 3;
			  }
			else
			  {
		            printf ("Received DEDA ENTR.\n");
			    NumWanted = 9;
			  }
			FormIoPacketAGS (040, ~010, Packet);
			send (Client->Socket, (const char *) Packet, 4, 0);
		      }
		    else if (Type == 05 && Data == 0767010)
		      {
		        printf ("Received DEDA HOLD.\n");
			DedaMonitor = 0;
		      }
		    else if (Type == 05 && Data == 0757020)
		      {
		        printf ("Received DEDA CLR.\n");
			DedaMonitor = 0;
		      }
		    else
		      printf ("Unknown AGS packet %02X %02X %02X %02X\n",
		              Client->Packet[0], Client->Packet[1],
			      Client->Packet[2], Client->Packet[3]);
		  }
		Client->Size = 0;
	      }
	  }
    }
  return (0);
}

//----------------------------------------------------------------------
// A generic function for handling client connects/disconnects.
// The input parameters are the CPU-dependent state (may be an agc_t
// or an aea_t, for example) and a function which will update a
// newly-connected peripheral with up-to-date CPU output signals.

void
ChannelRoutineGeneric (void *State, void (*UpdatePeripherals) (void *, Client_t *))
{
  static int TimeoutCount = 0;
  int i, j;
  Client_t *Client;
  extern int DebugMode;

  // Initialize the server sockets, if needed.
  if (NumServers == 0)
    {
      for (; NumServers < MAX_CLIENTS; NumServers++)
	{
	  Clients[NumServers].Socket = -1;
	  ServerSockets[NumServers] =
	    EstablishSocket (Portnum + NumServers, 3);
	}
    }
  for (i = 0, Client = Clients; i < MAX_CLIENTS; i++, Client++)
    if (ServerSockets[i] != -1 && Client->Socket == -1)
      {
	// Get new clients.
	Client->Socket = accept (ServerSockets[i], NULL, NULL);
	if (Client->Socket != -1)
	  {
	    int ii;
	    extern int DebugMode;
	    UnblockSocket (Client->Socket);
	    if (!DebugMode)
	      printf ("Adding socket %d on port %d\n", Client->Socket,
		      Portnum + i);
	    Client->Size = 0;
	    for (ii = 0; ii < 256; ii++)
	      Client->ChannelMasks[ii] = 077777;
	    // Now that a new connection has been made, update the
	    // client with all current output-port values.  Values of
	    // zero are treated as the default, and are not transmitted.
	    (*UpdatePeripherals) (State, Client);
	  }
	else if (errno == EMFILE)
	  printf ("File-descriptor limit reached.\n");
      }
  // Do a sort of timeout check for missing clients.
  TimeoutCount++;
  if (0 == (017 & TimeoutCount))
    {
      unsigned char c = 0377;
      for (i = 0, Client = Clients; i < MAX_CLIENTS; i++, Client++)
	if (Clients[i].Socket != -1)
	  {
	    j = send (Client->Socket, (const char *) &c, 1, MSG_NOSIGNAL);
	    if (j == SOCKET_ERROR && SOCKET_BROKEN)
	      {
	        if (!DebugMode)
		  printf ("Removing socket %d\n", Clients[i].Socket);
#ifdef unix
		close (Clients[i].Socket);
#else
		closesocket (Clients[i].Socket);
#endif
		Client->Socket = -1;
	      }
	  }
    }
}

static void
UpdateAgcPeripheralConnect (void *AgcState, Client_t *Client)
{
#define State ((agc_t *) AgcState)
  int i;
  unsigned char Packet[4];
  for (i = 0; i < 16; i++)
    if (State->OutputChannel10[i] != 0) {
      FormIoPacket (010, State->OutputChannel10[i], Packet);
      send (Client->Socket, (const char *) Packet, 4, MSG_NOSIGNAL);
    }
  for (i = 011; i < 0200; i++)
    if (State->InputChannel[i] != 0) {
      FormIoPacket (i, State->InputChannel[i], Packet);
      send (Client->Socket, (const char *) Packet, 4, MSG_NOSIGNAL);
    }
#undef State
}

void
ChannelRoutine (agc_t *State)
{
  ChannelRoutineGeneric (State, UpdateAgcPeripheralConnect);
}

//----------------------------------------------------------------------
// This function is useful for debugging the yaDEDA socket interface.  It
// forms a packet for the DEDA shift register.

void
ShiftToDeda (agc_t *State, int Data)
{
  unsigned char Packet[4];
  int i;
  Client_t *Client;
  FormIoPacketAGS (027, Data << 13, Packet);
  for (i = 0, Client = Clients; i < MAX_CLIENTS; i++, Client++)
    send (Client->Socket, (const char *) Packet, 4, MSG_NOSIGNAL);
}


