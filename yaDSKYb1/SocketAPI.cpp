/*
 * Copyright 2003-2005,2009 Ronald S. Burkey <info@sandroid.org>
 *
 * This file is part of yaAGC.
 *
 * yaAGC is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 *(at your option) any later version.
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
 * In addition, as a special exception, Ronald S. Burkey gives permission to
 * link the code of this program with the Orbiter SDK library (or with
 * modified versions of the Orbiter SDK library that use the same license as
 * the Orbiter SDK library), and distribute linked combinations including
 * the two. You must obey the GNU General Public License in all respects for
 * all of the code used other than the Orbiter SDK library. If you modify
 * this file, you may extend this exception to your version of the file,
 * but you are not obligated to do so. If you do not wish to do so, delete
 * this exception statement from your version.
 *
 * Filename:	SocketAPI.c
 * Purpose:	This is an implementation of yaAGC-to-peripheral
 * 		communications by means of a socket interface.  If some
 * 		other means of communications is desired, such as a
 * 		memory-mapped i/o-channel interface, just replace the
 * 		functions in this file with alternate functions.
 * Compiler:	GNU gcc.
 * Contact:	Ron Burkey <info@sandroid.org>
 * Reference:	http://www.ibiblio.org/apollo/index.html
 * Mods:	08/18/04 RSB.	Split off from agc_engine.c.
 * 		02/27/05 RSB	Added the license exception, as required by
 * 				the GPL, for linking to Orbiter SDK libraries.
 * 		05/14/05 RSB	Corrected website references.
 * 		05/15/05 RSB	Fixed bug in which counter increments
 * 				would endlessly recur.  SOCKET_API_C added
 * 				for agc_engine.h.
 * 		05/31/05 RSB	--debug-deda mode.
 * 		06/05/05 RSB	Corrected polarity of discretes in
 * 				--debug-deda mode.  Corrected positioning
 * 				of bits in the "input discretes".
 * 		06/07/05 RSB	Fixed bit positioning in DEDA shift
 * 				register.
 * 		06/26/05 RSB	Accounted for uplinked data.
 * 		07/09/05 RSB	Accounted for rotational hand controller (RHC)
 * 				in LM. In retrospect, this is a bad place
 * 				to handle it, since it won't automatically
 * 				be handled in NullAPI.c.  I'll worry about
 * 				that later.
 * 		03/11/09 RSB	Added casts of various char types (unsigned
 * 				char, char, const char) to other char types
 * 				for function parameters.  Without these,
 * 				there were fatal compilation errors with
 * 				some versions of g++.
 * 		03/18/09 RSB	Removed printed messages about adding/removing
 * 				sockets when the DebugMode flag is set.
 * 				Added some robustness checking to the
 * 				data stream on the tcp port.
 * 		03/19/09 RSB	Added DedaQuiet.
 */

#include <errno.h>
#include <stdlib.h>
#include <stdio.h>
#ifndef WIN32
#include <sys/socket.h>
#endif
#ifndef MSG_NOSIGNAL
#define MSG_NOSIGNAL 0
#endif
#define SOCKET_API_C
#include "yaDSKYb1.h"

// MAX_CLIENTS is the maximum number of hardware simulations which can be
// attached.  The DSKY is always one, presumably.  The array is a list of
// the sockets used for the clients.  Thus stuff shown below is the
// DEFAULT setup.  The max number of clients can be change during runtime
// initialization by setting MAX_CLIENTS to a different number, allocating
// new arrays of clients and sockets corresponding to the new size, and
// then pointing the Clients and ServerSockets pointers at those arrays.
int Portnum = 19671;
int MAX_CLIENTS = DEFAULT_MAX_CLIENTS;
static Client_t DefaultClients[DEFAULT_MAX_CLIENTS];
static int DefaultSockets[DEFAULT_MAX_CLIENTS];
Client_t *Clients = DefaultClients;
int *ServerSockets = DefaultSockets;
int NumServers = 0;
int SocketInterlaceReload = 50;

//-----------------------------------------------------------------------------
// Function for broadcasting "output channel" data to all connected clients of
// yaAGC.

static const unsigned char Signatures[4] =
  { 0x00, 0x40, 0x80, 0xC0 };
void
ChannelOutput(agcBlock1_t * State, int Channel, int Value)
{
  int i, j;
  Client_t *Client;
  unsigned char Packet[4];

  // Some output channels have purposes within the CPU, so we have to
  // account for those separately.
  // FIXME

  // Most output channels are simply transmitted to clients representing
  // hardware simulations.
  if (FormIoPacket(Channel, Value, Packet))
    return;
  for (i = 0, Client = Clients; i < MAX_CLIENTS; i++, Client++)
    if (Clients[i].Socket != -1)
      {
        j = send(Client->Socket, (const char *) Packet, 4, MSG_NOSIGNAL);
        if (j == SOCKET_ERROR && SOCKET_BROKEN)
          {
            printf("Removing socket %d\n", Clients[i].Socket);
#ifdef unix
            close(Clients[i].Socket);
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

int
ChannelInput(agcBlock1_t *State)
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
                k = recv(Client->Socket, (char *) &c, 1, 0);
                if (k == 0 || k == -1)
                  break;
                // 20090318 RSB.  Added this filter for a little robustness,
                // but it shouldn't be needed.
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
                int uBit, Type, Data;
                //printf ("Received from %d: %02X %02X %02X %02X\n",
                //	i, Client->Packet[0], Client->Packet[1],
                //	Client->Packet[2], Client->Packet[3]);
                if (!ParseIoPacket(Client->Packet, &Channel, &Value, &uBit))
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
                        // FIXME
                        //UnprogrammedIncrement(State, Channel, Value);
                        Client->Size = 0;
                        return (1);
                      }
                    else
                      {
                        Value &= Client->ChannelMasks[Channel];
                        Value |= State->memory[Channel]
                            & ~Client->ChannelMasks[Channel];
                        State->memory[Channel] = Value;
                        // If this is a keystroke from the DSKY, generate an interrupt req.
                        //---------------------------------------------------------------
                      }
                  }
                Client->Size = 0;
              }
          }
    }
  return (0);
}

//----------------------------------------------------------------------
// A generic function for handling client connects/disconnects.
// The input parameters are the CPU-dependent state (may be an agcBlock1_t
// or an aea_t, for example) and a function which will update a
// newly-connected peripheral with up-to-date CPU output signals.

void
ChannelRoutineGeneric(void *State, void
(*UpdatePeripherals)(void *, Client_t *))
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
          ServerSockets[NumServers] = EstablishSocket(Portnum + NumServers, 3);
        }
    }
  for (i = 0, Client = Clients; i < MAX_CLIENTS; i++, Client++)
    if (ServerSockets[i] != -1 && Client->Socket == -1)
      {
        // Get new clients.
        Client->Socket = accept(ServerSockets[i], NULL, NULL);
        if (Client->Socket != -1)
          {
            int ii;
            extern int DebugMode;
            UnblockSocket(Client->Socket);
            printf("Adding socket %d on port %d\n", Client->Socket,
                Portnum + i);
            Client->Size = 0;
            for (ii = 0; ii < 256; ii++)
              Client->ChannelMasks[ii] = 077777;
            // Now that a new connection has been made, update the
            // client with all current output-port values.  Values of
            // zero are treated as the default, and are not transmitted.
            (*UpdatePeripherals)(State, Client);
          }
        else if (errno == EMFILE)
          printf("File-descriptor limit reached.\n");
      }
  // Do a sort of timeout check for missing clients.
  TimeoutCount++;
  if (0 == (017 & TimeoutCount))
    {
      unsigned char c = 0377;
      for (i = 0, Client = Clients; i < MAX_CLIENTS; i++, Client++)
        if (Clients[i].Socket != -1)
          {
            j = send(Client->Socket, (const char *) &c, 1, MSG_NOSIGNAL);
            if (j == SOCKET_ERROR && SOCKET_BROKEN)
              {
                printf("Removing socket %d\n", Clients[i].Socket);
#ifdef unix
                close(Clients[i].Socket);
#else
                closesocket (Clients[i].Socket);
#endif
                Client->Socket = -1;
              }
          }
    }
}

static void
UpdateAgcPeripheralConnect(void *AgcState, Client_t *Client)
{
#define State ((agcBlock1_t *) AgcState)
  int i;
  unsigned char Packet[4];
  for (i = 010; i <= 014; i++)
    if (State->memory[i] != 0)
      {
        FormIoPacket(i, State->memory[i], Packet);
        send(Client->Socket, (const char *) Packet, 4, MSG_NOSIGNAL);
      }
#undef State
}

void
ChannelRoutine(agcBlock1_t *State)
{
  ChannelRoutineGeneric(State, UpdateAgcPeripheralConnect);
}

