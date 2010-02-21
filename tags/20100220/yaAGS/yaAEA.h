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

  Filename:	yaAEA.h
  Purpose:	Header file for common yaAGS-project functionality.
  Contact:	Ron Burkey <info@sandroid.org>
  Reference:	http://www.ibiblio.org/apollo/yaAGS.html
  Mods:		2005-02-13 RSB	Adapted from yaAGC.h.
		02/28/09 RSB	Added FORMAT_64U, FORMAT_64O for bypassing
				some compiler warnings on 64-bit machines.
*/

#ifndef YAAEA_H
#define YAAEA_H

#if defined(__APPLE_CC__) && !defined(unix)
#define unix
#endif

// Figure out the right include-files for socket stuff.
#if defined(unix)

#include <unistd.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netdb.h>
#include <netinet/in.h>
#include <fcntl.h>
#include <stdint.h>
#ifndef __WORDSIZE
#define FORMAT_64U "%llu"
#define FORMAT_64O "%llo"
#elif __WORDSIZE < 64
#define FORMAT_64U "%llu"
#define FORMAT_64O "%llo"
#else
#define FORMAT_64U "%lu"
#define FORMAT_64O "%lo"
#endif

#elif defined(WIN32)

#include <windows.h>
#include <winsock2.h>
#define FORMAT_64U "%llu"
#define FORMAT_64O "%llo"

#endif
#ifndef MSG_NOSIGNAL
#define MSG_NOSIGNAL 0
#endif

//--------------------------------------------------------------------------
// Function prototypes.

int InitializeSocketSystem (void);
void UnblockSocket (int SocketNum);
int EstablishSocket (unsigned short portnum, int MaxClients);
int CallSocket (char *hostname, unsigned short portnum);

#endif // YAAEA_H
