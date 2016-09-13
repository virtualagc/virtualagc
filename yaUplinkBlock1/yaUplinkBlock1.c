/*
 * Copyright 2016 Ronald S. Burkey <info@sandroid.org>
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
 * Filename:    yaUplinkBlock1.c
 * Purpose:     Send uplink data to yaAGCb1
 * Compiler:    GNU gcc.
 * Contact:     Ron Burkey <info@sandroid.org>
 * Reference:   http://www.ibiblio.org/apollo/index.html
 * Mods:        2016-09-12 RSB  Began.
 */

#include <stdlib.h>
#include <stdio.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <errno.h>
#include <ncurses.h>
#include "../yaAGCb1/yaAGCb1.h"
extern int
CallSocket(char *hostname, unsigned short portnum);

// Stuff for the timer we use for reading the socket interface.
static char DefaultHostname[] = "localhost";
char *Hostname = DefaultHostname;
static int ServerSocket = -1;

void
OutputKeycode(int Keycode)
{
  unsigned char Packet[8];
  int j;
  if (ServerSocket != -1)
    {
      FormIoPacket (0441, 077, Packet); // Mask for lowest 6 data bits.
      FormIoPacket(041, 040 | Keycode, &Packet[4]); // Data.
      j = send(ServerSocket, (const char *) Packet, 8, MSG_NOSIGNAL);
      if (j == SOCKET_ERROR && SOCKET_BROKEN)
        {
          close(ServerSocket);
          ServerSocket = -1;
        }
    }
}

int
main (void)
{
  unsigned char Packet[4];
  setvbuf(stdin, NULL, _IONBF, 0);
  initscr();
  Portnum = 19675;
  while (1)
    {
      int c;
      c = getch();
      if (c == 'b') c = 000;
      else if (c == '0') c = 020;
      else if (c >= '1' && c <= '9') c -= '0';
      else if (c == 'v') c = 021;
      else if (c == 'r') c = 022;
      else if (c == 'k') c = 031;
      else if (c == '+') c = 032;
      else if (c == '-') c = 033;
      else if (c == '\n')
        {
          c = 034;
          printw("\n");
        }
      else if (c == 'c') c = 036;
      else if (c == 'n') c = 037;
      else continue;
      if (ServerSocket == -1)
        {
          ServerSocket = CallSocket(Hostname, Portnum);
          if (ServerSocket != -1)
            printf("\r\nyaDSKY is connected.\r\n");
        }
      if (ServerSocket != -1)
        OutputKeycode(c);
    }
  endwin();
}
