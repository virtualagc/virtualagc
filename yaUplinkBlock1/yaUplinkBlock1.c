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
 *
 * The idea here is that you connect to yaAGCb1 like so, using netcat:
 *
 *      yaUplinkBlock1 | nc HOST PORT
 *
 * yaUplinkBlock1 accepts ASCII characters on stdin, converts them to standard
 * yaAGC packets, passes the packets to netcat, and netcat sends them to yaAGCb1.
 * The ASCII characters correspond to legal DSKY keycodes as follows:
 *
 *      'b'     blank
 *      '0'     0
 *       .
 *       .
 *       .
 *      '9'     9
 *      'v'     VERB
 *      'r'     ERROR RESET
 *      'k'     KEY RELEASE
 *      '+'     +
 *      '-'     -
 *      '\n'    ENTER
 *      'c'     CLEAR
 *      'n'     NOUN
 *
 * This works on Linux, but if you don't have netcat, or if hitting the Enter key
 * doesn't produce a newline, you may have to adapt the program somewhat, or else
 * use some other manner to uplinking to yaAGCb1, or just not do it, of course.
 *
 * I wouldn't use this other than interactively, since otherwise there would be no
 * delay between packets, and the AGC program would probably just see the final one
 * in the UPLINK register.
 */

#include <stdlib.h>
#include <stdio.h>

// I just cut-and-pasted the following function  from yaAGCb1/agc_utilities.c.

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

int
main (void)
{
  unsigned char Packet[4];
  setvbuf(stdin, NULL, _IONBF, 0);
  setvbuf(stdout, NULL, _IONBF, 0);
  while (1)
    {
      int c;
      c = getchar();
      if (c == 'b') c = 000;
      else if (c == '0') c = 020;
      else if (c >= '1' && c <= '9') c -= '0';
      else if (c == 'v') c = 021;
      else if (c == 'r') c = 022;
      else if (c == 'k') c = 031;
      else if (c == '+') c = 032;
      else if (c == '-') c = 033;
      else if (c == '\n') c = 034;
      else if (c == 'c') c = 036;
      else if (c == 'n') c = 037;
      else continue;
      FormIoPacket (041, c, Packet);
      fwrite (Packet, 4, 1, stdout);
      fflush(stdout);
    }
}
