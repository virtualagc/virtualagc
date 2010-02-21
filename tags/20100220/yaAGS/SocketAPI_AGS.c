/*
  Copyright 2005,2009 Ronald S. Burkey <info@sandroid.org>
  
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
 
  Filename:	SocketAPI_AGS.c
  Purpose:	This is an implementation of yaAGS-to-peripheral 
  		communications by means of a socket interface.  If some
		other means of communications is desired, such as a 
		memory-mapped i/o-channel interface, just replace the
		functions in this file with alternate functions.
  Compiler:	GNU gcc.
  Contact:	Ron Burkey <info@sandroid.org>
  Reference:	http://www.ibiblio.org/apollo/index.html
  Mods:		06/07/05 RSB	Began.
  		03/18/09 RSB	Added some robustness filtering to 
				the tcp interface.
		03/19/09 RSB	Added stuff related to --debug-deda.
*/

#include <errno.h>
#include <stdlib.h>
#include <stdio.h>
#ifdef WIN32
typedef unsigned short uint16_t;
#endif
#define SOCKET_API_AGS_C
#include "yaAGC.h"
#include "aea_engine.h"

// When we detect the pressing of the READ OUT or ENTR key, we don't immediately
// pass it along to the CPU.  Instead, we interact with yaDEDA to buffer the
// 3 or 9 nibbles of shift-register data, and only THEN to we pass the READ OUT
// or ENTR keypress to the CPU.  When the CPU subsequently requests the 
// data with DEDA Shift In requests, we dole out the data from the buffer rather
// than passing the requests along to yaDEDA.  This behavior is needed to account
// for the fact that the flight software assumes that the shift-register data
// will be available 80 microseconds after requesting it.  We can't meet this
// timing constraint without buffering the data.
// The following stuff is now in the Client_t structure, to account for the possibility
// in debugging that several DEDAs might be connected.
int DedaBuffer[9], DedaBufferCount = 0, DedaBufferWanted = 0,
  DedaBufferReadout = 0, DedaBufferDefault = 0;

//-----------------------------------------------------------------------------
// Functions for sending "output channel" data to a single connected client.
// This is principally useful for asking a specific DEDA for its keyboard
// buffer.
static
void OneRawChannelOutputAGS (Client_t *Client, const unsigned char *Packet, int Type, int Data)
{
  if (Client->Socket != -1)
    {
      if (send (Client->Socket, Packet, 4, MSG_NOSIGNAL) == SOCKET_ERROR 
          && SOCKET_BROKEN)
	{
	  if (!DebugMode)
	    printf ("Removing socket %d\n", Client->Socket);
#ifdef unix
	  close (Client->Socket);
#else
	  closesocket (Client->Socket);
#endif
	  Client->Socket = -1;
	}
    }
}

static void
OneChannelOutputAGS (Client_t *Client, int Type, int Data)
{
  unsigned char Packet[4];
  if (FormIoPacketAGS (Type, Data, Packet))
    return;
  OneRawChannelOutputAGS (Client, Packet, Type, Data);
}

//-----------------------------------------------------------------------------
// Function for broadcasting "output channel" data to all connected clients of
// yaAGS.

void
ChannelOutputAGS (int Type, int Data)
{
  int i;
  Client_t *Client;
  unsigned char Packet[4];
  if (FormIoPacketAGS (Type, Data, Packet))
    return;
  for (i = 0, Client = Clients; i < MAX_CLIENTS; i++, Client++)
    OneRawChannelOutputAGS (Client, Packet, Type, Data);
}

//----------------------------------------------------------------------------
// Function for fetching yaAGS input-channel data into the State structure's
// input-channel buffer.

static const unsigned char Signatures[4] = { 0x00, 0xc0, 0x80, 0x40 };

int 
ChannelInputAGS (ags_t * State)
{
  static int SocketInterlace = 0;
  int i, j, k;
  unsigned char c;
  Client_t *Client;
  int Mask;
  
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
		k = recv (Client->Socket, &c, 1, 0);
		if (k == 0 || k == -1)
		  break;
		// 20090318 RSB.  Added this filter for a little 
		// robustness, but it shouldn't be needed.
		if (Signatures[j] != (c & 0xC0))
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
		int Type, Data;
		//printf ("Received from %d: %02X %02X %02X %02X\n",
		//	i, Client->Packet[0], Client->Packet[1],
		//	Client->Packet[2], Client->Packet[3]);
		if (!ParseIoPacketAGS (Client->Packet, &Type, &Data))
		  switch (Type)
		    {
		    case 000:		// PGNS theta integrator.
		    case 001:		// PGNS phi integrator.
		    case 002:		// PGNS psi integrator.
		      j = IO_2001 + Type;
		      if (Data == 0)
		        State->InputPorts[j] = 0;
		      else	
		        {
		          State->InputPorts[j] += SignExtendAGS (Data) * 4;
			  State->InputPorts[j] &= 0377774;
			}
		      break;
		    case 005:		// discrete input word 2.
		      if (DebugDeda && (0 != (Data & 036)))
		        {
			  if (0 != (Data & 020))
			    {
			      if (0 == (Data & 020000))
			        printf ("DEDA #%d CLR pressed\n", i);
			      else 
			        printf ("DEDA #%d CLR released\n", i);
			    }
			  else if (0 != (Data & 010))
			    {
			      if (0 == (Data & 010000))
			        printf ("DEDA #%d HOLD pressed\n", i);
			      else 
			        printf ("DEDA #%d HOLD released\n", i);
			    }
			  else if (0 != (Data & 04))
			    {
			      if (0 == (Data & 004000))
			        printf ("DEDA #%d ENTR pressed\n", i);
			      else 
			        printf ("DEDA #%d ENTR released\n", i);
			    }
			  else if (0 != (Data & 02))
			    {
			      if (0 == (Data & 002000))
			        printf ("DEDA #%d READOUT pressed\n", i);
			      else 
			        printf ("DEDA #%d READOUT released\n", i);
			    }
			}
		      // If the READ OUT or ENTR keys are active,
		      // we must intercept them and buffer the 
		      // associated data before letting the CPU
		      // know about it.
		      if (04 == (Data & 04004))		// ENTR?
		        {
			  DedaBufferCount = 0;	// Prepare to collect data.
			  DedaBufferWanted = 9;
			  Data |= 04000;	// Reset the ENTR key.
			  // Request DEDA shift data.
			  if (DebugDeda)
			    printf ("Request DEDA #%d shift data\n", i);
			  OneChannelOutputAGS (Client, 040, State->OutputPorts[IO_ODISCRETES] & ~010);
			}
		      else if (02 == (Data & 02002))	// READ OUT?
		        {
			  DedaBufferCount = 0;	// Prepare to collect data.
			  DedaBufferWanted = 3;
			  Data |= 02000;	// Reset the READ OUT key.
			  // Request DEDA shift data.
			  if (DebugDeda)
			    printf ("Request DEDA #%d shift data\n", i);
			  OneChannelOutputAGS (Client, 040, State->OutputPorts[IO_ODISCRETES] & ~010);
			}
		      // Yes, it is supposed to fall through here.		
		    case 004:		// Discrete input word 1.
		      j = IO_2020 + (Type - 4);
		      Mask = ((Data & 0777) << 9);
		      State->InputPorts[j] &= ~Mask;
		      State->InputPorts[j] |= (Data & Mask);
		      break;
		    case 007:		// DEDA.
		      // If we are buffering this input, we have to intercept it.
		      if (DedaBufferWanted)
		        {
			  if (DedaBufferCount < DedaBufferWanted)
			    {
			      DedaBuffer[DedaBufferCount++] = (Data & 0360000);  
			      if (DedaBufferCount < DedaBufferWanted)
			        {
				  // Request more DEDA shift data.
				  if (DebugDeda)
				    printf ("Request DEDA #%d shift data\n", i);
				  OneChannelOutputAGS (Client, 040, 
				  		       State->OutputPorts[IO_ODISCRETES] & ~010);
				}
			      else
				{
				  // The data is all buffered.  We can tell the
				  // CPU that the ENTR or READ OUT key was pressed.
				  if (DebugDeda)
				    {
				      printf ("DEDA #%d data", i);
				      for (j = 0; j < DedaBufferWanted; j++)
				        printf (" %02o", DedaBuffer[j] >> 13);
				      printf ("\n");
				    }
				  DedaBufferReadout = -1;
				  if (DedaBufferWanted == 3)
				    {
				      State->InputPorts[IO_2040] &= ~02000;	// READ OUT
				      //printf (" READOUT\n");
				    }
				  else
				    {
				      State->InputPorts[IO_2040] &= ~04000;	// ENTR.
				      //printf (" ENTR\n");
				    }
				}
			    }
			}
		      break;
		    case 011:		// delta-integral-q counter
		    case 012:		// delta-integral-r counter
		    case 013:		// delta-integral-p counter
		      j = IO_6002 + (Type - 011);
   	              State->InputPorts[j] += SignExtendAGS (Data) * 0100;
		      State->InputPorts[j] &= 0377700;
		      break;
		    case 014:		// delta-Vx counter.
		    case 015:		// delta-Vy counter.
		    case 016:		// delta-Vz counter.
		      j = IO_6020 + (Type - 014);
   	              State->InputPorts[j] += SignExtendAGS (Data) * 0100;
		      State->InputPorts[j] &= 0377700;
		      break;
		    case 017:		// downlink telemetry
		      State->InputPorts[IO_6200] = Data;
		      // Make the Downlink Telemetry Stop bit active.
		      State->InputPorts[IO_2020] &= ~0200000;
		      break;
		    }
		Client->Size = 0;
	      }
	  }
    }
  return (0);
}


