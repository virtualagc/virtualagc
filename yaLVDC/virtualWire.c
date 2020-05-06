/*
 Copyright 2020 Ronald S. Burkey <info@sandroid.org>

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
 
 Filename:	virtualWire.c
 Purpose:	Portable functions (*NIX and Win32) for working with sockets
 for connecting yaLVDC to peripherals by "virtual wires".
 Compiler:	GNU gcc.
 Contact:	Ron Burkey <info@sandroid.org>
 Reference:	http://www.ibiblio.org/apollo/LVDC.html
 Mods:		2020-05-06 RSB.	Began adapting/simplifying from the yaAGC
 file agc_utilities.c.
 */

#include <stdio.h>
#include <string.h>
#ifndef WIN32
#include <netdb.h>
#include <netinet/in.h>
#include <sys/socket.h>
#include <unistd.h>
#include <fcntl.h>
#else
#include <windows.h>
#include <winsock2.h>
#endif

/////////////////////////////////////////////////////////////////////////////////
// Portable functions (*NIX and Win32) for working with sockets.
// LVDC/PTC specific functions.  Just delete them if repurposing this material
// for some other program.

#include "yaLVDC.h"

/*
 * Format for yaLVDC-compatible "virtual wire" packets.
 *
 * The format distinguishes between packets containing "data" and packets
 * containing a "mask".  If the packet carries all 26 bits of data (as
 * packets output by the server do), then there's no need for a mask; all
 * 26 data bits are valid.  However, for packets sent by peripherals to the
 * server (the CPU emulator) it's possible for one peripheral device to
 * supply some of the 26 bits of the port, while other peripherals supply
 * other of the bits.  In that case, the peripheral should precede such
 * a data packet (which will still be the full length) by an otherwise-
 * similar mask packet.  The payload of the mask packet has a 1 wherever
 * the payload in the following data packet will be valid, and a 0 wherever
 * the data packet will be invalid.
 *
 * Each packet consists
 * of 5 data bytes, formatted as follows:
 *
 *  1st byte:   D7      1
 *              D6      1 if the message is a mask, 0 if it's data.
 *              D5-D3   I/O type:       000     PIO
 *                                      001     CIO
 *                                      010     PRS
 *                                      011     Interrupt
 *                                      1XX     (reserved)
 *              D2-D0   Unique Source ID.  (000 is the server; i.e., the CPU.)
 *                      The port numbers used are the base port number plus
 *                      the ID.  Thus if the server were port number 19653,
 *                      then ID=1 would be port 19694, ... , ID=7 would be
 *                      port 19660.
 *
 *   2nd byte   D7      0
 *              D6      (reserved)
 *              D5      (reserved)
 *              D4-D0   Most-significant 5 bits of the 26-bit data/mask
 *
 *   3rd byte   D7      0
 *              D6-D0   Next-most-significant 7 bits of the 26-bit data/mask.
 *
 *   4th byte   D7      0
 *              D6-D0   Next-most-significant 7 bits of the 26-bit data/mask.
 *
 *   5th byte   D7      0
 *              D6-D0   Least-significant 7 bits of the 26-bit data/mask.
 */

int ServerBaseSocket = -1;
int PortNum = 19653;
int Listeners[MAX_LISTENERS], NumListeners = 0;
#define MAX_INPACKET_SIZE 2048

void
connectCheck(void)
{
  int i;
  if (NumListeners < MAX_LISTENERS)
    {
      i = accept(ServerBaseSocket, NULL, NULL);
      if (i != -1)
        {
          UnblockSocket(i);
          Listeners[NumListeners++] = i;
          printf("\nConnected to peripheral #%d on handle %d.\n", NumListeners, i);
        }
    }
}

// Once the server system has been activated, call this function once after
// emulation of each LVDC/PTC instruction to take care of any pending
// virtual-wire actions.  Returns 0 on success, non-zero on error.
int
pendingVirtualWireActivity(void /* int id, int mask */)
{
  int i, j, ioType = -1, payload, outPacketSize = 0;
  uint8_t outPacket[10];
  static uint8_t inPackets[MAX_LISTENERS][MAX_INPACKET_SIZE];
  static int inPacketSizes[MAX_LISTENERS] =
    { 0 };
  // For a general-purpose function, the following two things would
  // be function arguments, but for an LVDC server they always have the
  // same values, so it would be kind of pointless for them to be anything
  // other than constants.
  int id = 0, mask = ~0377777777;
  // Take care of any virtual-wire outputs needed.  The changes (triggered by
  // the last LVDC/PTC instruction executed) have stuck the necessary info in
  // the global "state" structure.  Note that any given instruction can flag
  // at _most_ one of state.pioChange, .cioChange, or .prsChange.  Moreover,
  // packets are guaranteed to be delivered in the same order generated (by
  // any given source), so there's no possibility of getting anything
  // out of order here.
  if (state.pioChange != -1)
    {
      printf("A\n");
      ioType = 0;
      payload = state.pio[state.pioChange];
      state.pioChange = -1;
    }
  else if (state.cioChange != -1)
    {
      printf("B\n");
      ioType = 1;
      payload = state.cio[state.cioChange];
      state.cioChange = -1;
    }
  else if (state.prsChange != -1)
    {
      printf("C\n");
      ioType = 2;
      payload = state.prs;
      state.prsChange = -1;
    }
  // Format the output packet(s).
  if (ioType >= 0)
    {
      printf("D\n");
      if ((mask & 0377777777) != 0377777777)
        {
          outPacket[outPacketSize++] = 0300 | ((ioType << 3) & 0070)
              | (id & 0007);
          outPacket[outPacketSize++] = (mask >> 21) & 0037;
          outPacket[outPacketSize++] = (mask >> 14) & 0177;
          outPacket[outPacketSize++] = (mask >> 7) & 0177;
          outPacket[outPacketSize++] = mask & 0177;
        }
      outPacket[outPacketSize++] = 0200 | ((ioType << 3) & 0070) | (id & 0007);
      outPacket[outPacketSize++] = (payload >> 21) & 0037;
      outPacket[outPacketSize++] = (payload >> 14) & 0177;
      outPacket[outPacketSize++] = (payload >> 7) & 0177;
      outPacket[outPacketSize++] = payload & 0177;

    }

  // Take care of any network stuff needed.
  connectCheck();
  // Send data.  I suppose I should check that the entire packet is sent,
  // and do something about it if not, but I'm not sure what.  I'll
  // come back to that later.
  for (i = 0; i < NumListeners; i++)
    {
      printf("E: %d\n", i);
      send(Listeners[i], outPacket, outPacketSize, 0);
    }
  // Receive data.
  for (i = 0; i < NumListeners; i++)
    {
      j = recv(Listeners[i], &inPackets[i][inPacketSizes[i]], MAX_INPACKET_SIZE, 0);
      if (j != -1)
        inPacketSizes[i] += j;
    }

  // Parse the received data.  All we have to do is to
  // read any inputs and stick them in the global "state" structure, where
  // the LVDC emulation will see them at some point.

  return (0);
}

/////////////////////////////////////////////////////////////////////////////////
// Portable functions (*NIX and Win32) for working with sockets.  

// Used for socket-operation error codes.
int virtualWireErrorCodes = 0;

/*
 The usage is this:

 1. Servers:  Create a socket, suitable for clients to connect to,
 with EstablishSocket().  Call accept(,NULL,NULL) to listen for a new
 client; the function will return whether or not there is a new
 listener, with either -1 (no new client) or else the new socket
 number (>=0); the first parameter is the socket number created by
 EstablishSocket().   The socket should be unblocked with UnblockSocket().

 2. Clients:  Connect to a server with CallSocket().  The function will
 return whether or not the connection succeeded, with either -1
 (failure) or else with the connection socket number.

 3. Either the client or server can then proceed to perform i/o using
 send() or recv() to all connected servers or clients.

 Server example:

 int ServerBaseSocket;
 #define MAX_LISTENERS 5
 int ListeningSockets[MAX_LISTENERS], NumListeners = 0;
 int PortNum = ... something ...;
 int i, j;

 ServerBaseSocket = EstablishSocket (PortNum, MAX_LISTENERS);
 if (ServerBaseSocket == -1)
 ... unrecoverable error ...
 // Main activity loop
 for (;;)
 {
 ...
 // Periodically do this:
 if (NumListeners < MAX_LISTENERS)
 {
 i = accept (ServerBaseSocket, NULL, NULL);
 if (i != -1)
 {
 UnblockSocket (i);
 Listeners[NumListeners++] = i;
 }
 }
 ...
 // Receive data.
 for (i = 0; i < NumListeners; i++)
 ... receive data from listener i using recv() ...
 ...
 // Send data.
 for (i = 0; i < NumListeners; i++)
 ... transmit data to listener i using send() ...
 ...
 }

 Client Example:

 int ConnectionSocket = -1;

 // Main activity loop.
 for (;;)
 {
 ...
 // Try for a connection.
 if (ConnectionSocket == -1)
 ConnectionSocket = CallSocket (Hostname, Portnum);
 ...
 // Perform i/o with send/recv:
 if (ConnectionSocket != -1)
 ... send/recv ...
 ...
 }

 These examples don't illustrate what to do in case of broken
 connections.  (I don't actually KNOW what to do.)

 */

//----------------------------------------------------------------------
// The following are the only two socket functions that internally differ
// between *nix and Win32.
// Initialize the socket system.  Return 0 on success.
static int SocketSystemInitialized = 0;
int
InitializeSocketSystem(void)
{
  if (SocketSystemInitialized)
    return (0);
  SocketSystemInitialized = 1;
#if defined(unix)
  return (0);
#else
  WSADATA wsaData;
  return (WSAStartup (MAKEWORD (2, 0), &wsaData));
#endif
}

// Set an existing socket to be non-blocking.
void
UnblockSocket(int SocketNum)
{
#if defined(unix)
  fcntl(SocketNum, F_SETFL, O_NONBLOCK);
#else
  unsigned long nonBlock = 1;
  ioctlsocket (SocketNum, FIONBIO, &nonBlock);
#endif
}

//----------------------------------------------------------------------
// Function for creating a socket.  Copied from
// http://world.std.com/~jimf/papers/sockets/sockets.html, and then
// modified somewhat for my own purposes.  The parameters:
//
//      portnum         The port on which we're going to listen.
//      MaxClients      Max number of queued connections.  (5 is good.)
//
// Returns -1 on error, or the new socket number (>=0) if successful.

#define MAXHOSTNAME 256
int
EstablishSocket(unsigned short portnum, int MaxClients)
{
  char myname[MAXHOSTNAME + 1];
  int s, i;
  struct sockaddr_in sa;
  struct hostent *hp;

  InitializeSocketSystem();

  memset(&sa, 0, sizeof(struct sockaddr_in)); /* clear our address */
  gethostname(myname, MAXHOSTNAME); /* who are we? */
  hp = gethostbyname(myname); /* get our address info */
  if (hp == NULL) /* we don't exist !? */
    {
      char s[32];
      switch (h_errno)
        {
      case HOST_NOT_FOUND:
        strcpy(s, "Host not found");
        break;
      case NO_ADDRESS:
        strcpy(s, "No address");
        break;
        //case NO_DATA: strcpy(s, "No data"); break;
      case NO_RECOVERY:
        strcpy(s, "No recovery");
        break;
      case TRY_AGAIN:
        strcpy(s, "Try again");
        break;
      default:
        sprintf(s, "Error %d", h_errno);
        break;
        }
      fprintf(stderr, "gethostbyname (\"%s\" %d) reports %s\n", myname, portnum,
          s);
      virtualWireErrorCodes = 0x101;
      return (-1);
    }
  sa.sin_family = hp->h_addrtype; /* this is our host address */
  sa.sin_port = htons(portnum); /* this is our port number */
  if ((s = socket(AF_INET, SOCK_STREAM, 0)) < 0) /* create socket */
    {
      virtualWireErrorCodes = 0x102;
      return (-1);
    }

  // Make sure to clean up after any previous disconnects of the
  // port.  Otherwise there would be a timeout until we could
  // reuse the port.
  i = 1;
  setsockopt(s, SOL_SOCKET, SO_REUSEADDR, (const char *) &i, sizeof(int));

  if (bind(s, (struct sockaddr *) &sa, sizeof(struct sockaddr_in)) < 0)
    {
#ifdef unix
      close(s);
#else
      closesocket (s);
#endif
      virtualWireErrorCodes = 0x103;
      return (-1); /* bind address to socket */
    }
  listen(s, MaxClients); /* max # of queued connects */
  // Don't want to wait when there's no incoming data.
  UnblockSocket(s);
  return (s);
}

//----------------------------------------------------------------------
// Client connection to server via socket.
// http://world.std.com/~jimf/papers/sockets/sockets.html.
// The hostname is the name of the server, either resolvable by DNS,
// or else a dotted IP number.  (The latter fails on Win32.)
// The portnum is the port-number on which the server listens.

int
CallSocket(char *hostname, unsigned short portnum)
{
  struct sockaddr_in sa;
  struct hostent *hp;
  //int a;
  int s;

  InitializeSocketSystem();

  if ((hp = gethostbyname(hostname)) == NULL)
    {
      /* do we know the host's */
      //errno= ECONNREFUSED; /* address? */
      virtualWireErrorCodes = 0x301;
      return (-1); /* no */
    }

  memset(&sa, 0, sizeof(sa));
  memcpy((char *) &sa.sin_addr, hp->h_addr, hp->h_length); /* set address */
  sa.sin_family = hp->h_addrtype;
  sa.sin_port = htons((u_short) portnum);
  if ((s = socket(hp->h_addrtype, SOCK_STREAM, 0)) < 0) /* get socket */
    {
      virtualWireErrorCodes = 0x302;
      return (-1);
    }
  if (connect(s, (struct sockaddr *) &sa, sizeof(sa)) < 0)
    {
      /* connect */
#ifdef unix
      close(s);
#else
      closesocket (s);
#endif
      virtualWireErrorCodes = 0x303;
      return (-1);
    }
  UnblockSocket(s);
  return (s);
}
