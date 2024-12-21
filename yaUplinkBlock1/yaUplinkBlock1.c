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
 * 		2016-11-18 RSB	Accounted for different location of ncurses.h
 * 				in Solaris, along with missing MSG_NOSIGNAL.
 */

#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <sys/types.h>
#ifndef WIN32
#include <sys/socket.h>
#endif
#include <errno.h>
#if defined(SOLARIS)
#include <ncurses/ncurses.h>
#ifndef MSG_NOSIGNAL
#define MSG_NOSIGNAL 0
#endif
#elif defined(WIN32)
#include <ncursesw/ncurses.h>
#ifndef MSG_NOSIGNAL
#define MSG_NOSIGNAL 0
#endif
#else
#include <ncurses.h>
#endif
#include "../yaAGCb1/yaAGCb1.h"
extern int
CallSocket(char *hostname, unsigned short portnum);
#define CONNECTED "\nyaDSKY is connected.\n"

// For Solaris and Mac OS X.
#ifndef MSG_NOSIGNAL
#define MSG_NOSIGNAL 0
#endif

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
      Keycode &= 037;
      //FormIoPacket(0441, 077777, Packet); // Mask for lowest 6 data bits.
      FormIoPacket(041, Keycode | ((Keycode ^ 037) << 5) | (Keycode << 10), &Packet[4]); // Data.
      j = send(ServerSocket, (const char *) Packet, 8, MSG_NOSIGNAL);
      if (j == SOCKET_ERROR && SOCKET_BROKEN)
        {
          close(ServerSocket);
          ServerSocket = -1;
        }
#if 0
      else
        {
          usleep(50000);
          FormIoPacket(041, 037 << 5, &Packet[4]); // Data.
          j = send(ServerSocket, (const char *) Packet, 8, MSG_NOSIGNAL);
          if (j == SOCKET_ERROR && SOCKET_BROKEN)
            {
              close(ServerSocket);
              ServerSocket = -1;
            }
        }
#endif
    }
}

int
main(int argc, char *argv[])
{
  int i, batch = 0;
  unsigned u;
  unsigned char Packet[4];

  Portnum = 19675;

  // Parse command line.
  for (i = 1; i < argc; i++)
    {
      if (1 == sscanf(argv[i], "--port=%u", &u))
        Portnum = u;
      else if (!strcmp(argv[i], "--batch"))
        batch = 1;
      else
        {
          printf("Usage:  yaUplinkBlock1 [--port=P] [--batch]\n");
          printf(
              "This program accepts the ASCII keycodes ' ', '0'-'9', 'v', 'r', 'k', '+',\n"
                  "'-', '\n', 'c', and 'n' on stdin, translates them to the DSKY keycodes\n"
                  "blank, 0-9, VERB, RESET, KEY RLSE, +, -, ENTER, CLEAR, or NOUN, packages them\n"
                  "according to the yaAGC protocol, and communicates them to the Block 1\n"
                  "AGC simulator, yaAGCb1, on the selected port (19675 by default).  There\n"
                  "is a built-in timing delay of 200 ms. between keystrokes.\n"
                  "In --batch mode, input can come from a script, but otherwise it is\n"
                  "expected to come from a keyboard.\n");
          return (1);
        }
    }

  // Infinite loop of accepting input on stdin, and sending output to the
  // AGC.
  setvbuf(stdin, NULL, _IONBF, 0);
  if (batch)
    {
      printf("Connecting on port %d ...\n", Portnum);
      printf(
          "Taking ASCII equivalents of the DSKY keycodes from a script ...\n");
    }
  else
    {
      initscr();
      noecho();
      printw("Connecting on port %d ...\n", Portnum);
      printw("Input ASCII equivalents of the DSKY keycodes at keyboard ...");
    }
  ServerSocket = CallSocket(Hostname, Portnum);
  if (ServerSocket != -1)
    {
      if (batch)
        printf(CONNECTED);
      else
        printw(CONNECTED);
    }
  while (1)
    {
      int c, newc;
      usleep(200000);
      if (batch)
        {
          c = getchar();
          if (c == EOF)
            break;
          putchar (c);
        }
      else
        {
          c = getch();
          printw("%c", c);
        }
      if (c == ' ')
        newc = 000;
      else if (c == '0')
        newc = 020;
      else if (c >= '1' && c <= '9')
        newc = c - '0';
      else if (c == 'v')
        newc = 021;
      else if (c == 'r')
        newc = 022;
      else if (c == 'k')
        newc = 031;
      else if (c == '+')
        newc = 032;
      else if (c == '-')
        newc = 033;
      else if (c == '\n')
        newc = 034;
      else if (c == 'c')
        newc = 036;
      else if (c == 'n')
        newc = 037;
      else
        continue;

      if (ServerSocket == -1)
        {
          ServerSocket = CallSocket(Hostname, Portnum);
          if (ServerSocket != -1)
            {
              if (batch)
                printf(CONNECTED);
              else
                printw(CONNECTED);
            }
        }
      if (ServerSocket != -1)
        OutputKeycode(newc);
    }
  if (!batch)
    endwin();
}
