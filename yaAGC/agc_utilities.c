/*
  Copyright 2003-2005 Ronald S. Burkey <info@sandroid.org>

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

  Filename:	agc_utilities.c
  Purpose:	Miscellaneous functions, useful for agc_engine or for other
  		yaAGC-family functions.
  Compiler:	GNU gcc.
  Contact:	Ron Burkey <info@sandroid.org>
  Reference:	http://www.ibiblio.org/apollo/index.html
  Mods:		04/21/03 RSB.	Began.
  		08/20/03 RSB.	Added uBit to ParseIoPacket.
		05/30/04 RSB	Various.
		07/12/04 RSB	Q is now 16 bits.
		01/31/05 RSB	Added the setsockopt call to
				EstablishSocket.
		02/27/05 RSB	Added the license exception, as required by
				the GPL, for linking to Orbiter SDK libraries.
		04/30/05 RSB	Added workaround for lack of Win32 close().
		05/14/05 RSB	Corrected website references.
		05/29/05 RSB	Added a couple of AGS equivalents for packet
				function.
*/

// ... and the project's includes.
#include <stdio.h>
#include <string.h>
#include "yaAGC.h"
#include "agc_engine.h"


// Used for socket-operation error codes.
int ErrorCodes = 0;

//////////////////////////////////////////////////////////////////////////////////
// Functions for working with the data packets used for yaAGC "channel i/o".

//--------------------------------------------------------------------------------
// This function can take an i/o channel number and a 15-bit value for it, and
// constructs a 4-byte packet suitable for transmission to yaAGC via a socket.
// Space for the packet must have been allocated by the calling program.
// Refer to the Virtual AGC Technical Manual, "I/O Specifics" subheading of the
// "Developer Details" chapter.  Briefly, the 4 bytes are:
//      00pppppp 01pppddd 10dddddd 11dddddd
// where ppppppppp is the 9-bit channel number and ddddddddddddddd is the 15-bit
// value.  Finally, it transmits the packet. Returns 0 on success.
//
// ... Later, the 9-bit "Channel" is actually the u-bit plus an 8-bit channel
// number, but the function works the same.

int
FormIoPacket (int Channel, int Value, unsigned char *Packet)
{
  if (Channel < 0 || Channel > 0x1ff)
    return (1);
  if (Value < 0 || Value > 0x7fff)
    return (1);
  if (Packet == NULL)
    return (1);
  Packet[0] = Channel >> 3;
  Packet[1] = 0x40 | ((Channel << 3) & 0x38) | ((Value >> 12) & 0x07);
  Packet[2] = 0x80 | ((Value >> 6) & 0x3F);
  Packet[3] = 0xc0 | (Value & 0x3F);
  // All done.
  return (0);
}

// Same as FormIoPacket(), but for AGS-style packets rather than AGC-style.

int
FormIoPacketAGS (int Type, int Data, unsigned char *Packet)
{
  if (Type < 0 || Type > 077)
    return (1);
  Data &= 0777777;
  Packet[0] = Type;
  Packet[1] = 0xc0 | ((Data >> 12) & 077);
  Packet[2] = 0x80 | ((Data >> 6) & 077);
  Packet[3] = 0x40 | (Data & 077);
  return (0);
}

//--------------------------------------------------------------------------------
// This function is the opposite of FormIoPacket:  A 4-byte packet representing
// yaAGC channel i/o can be converted to an integer channel-number and value.
// Returns 0 on success.

int
ParseIoPacket (unsigned char *Packet, int *Channel, int *Value, int *uBit)
{
  // Pick the channel number and value from the packet.
  if (0x00 != (0xc0 & Packet[0]))
    return (1);
  if (0x40 != (0xc0 & Packet[1]))
    return (1);
  if (0x80 != (0xc0 & Packet[2]))
    return (1);
  if (0xc0 != (0xc0 & Packet[3]))
    return (1);
  *Channel = ((Packet[0] & 0x1F) << 3) | ((Packet[1] >> 3) & 7);
  *Value = ((Packet[1] << 12) & 0x7000) | ((Packet[2] << 6) & 0x0FC0) |
    (Packet[3] & 0x003F);
  *uBit = (0x20 & Packet[0]);
  return (0);
}

// Same, but for AGS.

int
ParseIoPacketAGS (unsigned char *Packet, int *Type, int *Data)
{
  // Pick the packet type and data from the packet, if the signature matches.
  if (0xc0 != (0xc0 & Packet[1]))
    return (1);
  if (0x80 != (0xc0 & Packet[2]))
    return (1);
  if (0x40 != (0xc0 & Packet[3]))
    return (1);
  *Type = Packet[0];
  *Data = ((Packet[1] & 077) << 12) | ((Packet[2] & 077) << 6) | (Packet[3] & 077);
  return (0);
}

/////////////////////////////////////////////////////////////////////////////////
// Portable functions (*NIX and Win32) for working with sockets.

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
InitializeSocketSystem (void)
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
UnblockSocket (int SocketNum)
{
#if defined(unix)
  fcntl (SocketNum, F_SETFL, O_NONBLOCK);
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
EstablishSocket (unsigned short portnum, int MaxClients)
{
  char myname[MAXHOSTNAME + 1];
  int s, i;
  struct sockaddr_in sa;
  struct hostent *hp;

  InitializeSocketSystem ();

  memset (&sa, 0, sizeof (struct sockaddr_in));	/* clear our address */
  gethostname (myname, MAXHOSTNAME);	/* who are we? */
  hp = gethostbyname (myname);	/* get our address info */
  if (hp == NULL)		/* we don't exist !? */
    {
      ErrorCodes = 0x101;
      return (-1);
    }
  sa.sin_family = hp->h_addrtype;	/* this is our host address */
  sa.sin_port = htons (portnum);	/* this is our port number */
  if ((s = socket (AF_INET, SOCK_STREAM, 0)) < 0)	/* create socket */
    {
      ErrorCodes = 0x102;
      return (-1);
    }

  // Make sure to clean up after any previous disconnects of the
  // port.  Otherwise there would be a timeout until we could
  // reuse the port.
  i = 1;
  setsockopt (s, SOL_SOCKET, SO_REUSEADDR, (const char *) &i, sizeof (int));

  if (bind (s, (struct sockaddr *) &sa, sizeof (struct sockaddr_in)) < 0)
    {
#ifdef unix
      close (s);
#else
      closesocket (s);
#endif
      ErrorCodes = 0x103;
      return (-1);		/* bind address to socket */
    }
  listen (s, MaxClients);	/* max # of queued connects */
  // Don't want to wait when there's no incoming data.
  UnblockSocket (s);
  return (s);
}

//----------------------------------------------------------------------
// Client connection to server via socket.
// http://world.std.com/~jimf/papers/sockets/sockets.html.
// The hostname is the name of the server, either resolvable by DNS,
// or else a dotted IP number.  (The latter fails on Win32.)
// The portnum is the port-number on which the server listens.

int
CallSocket (char *hostname, unsigned short portnum)
{
  struct sockaddr_in sa;
  struct hostent *hp;
  //int a;
  int s;

  InitializeSocketSystem ();

  if ((hp = gethostbyname (hostname)) == NULL)
    {
      /* do we know the host's */
      //errno= ECONNREFUSED; /* address? */
      ErrorCodes = 0x301;
      return (-1);		/* no */
    }

  memset (&sa, 0, sizeof (sa));
  memcpy ((char *) &sa.sin_addr, hp->h_addr, hp->h_length);	/* set address */
  sa.sin_family = hp->h_addrtype;
  sa.sin_port = htons ((u_short) portnum);
  if ((s = socket (hp->h_addrtype, SOCK_STREAM, 0)) < 0)	/* get socket */
    {
      ErrorCodes = 0x302;
      return (-1);
    }
  if (connect (s, (struct sockaddr *) &sa, sizeof (sa)) < 0)
    {
      /* connect */
#ifdef unix
      close (s);
#else
      closesocket (s);
#endif
      ErrorCodes = 0x303;
      return (-1);
    }
  UnblockSocket (s);
  return (s);
}
