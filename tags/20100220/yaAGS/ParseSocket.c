/*
  Copyright 2009 Ronald S. Burkey <info@sandroid.org>
  
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

  Filename:	ParseSocket.c
  Purpose:	Parses data being exchanged between various Virtual AGC
  		components via the socket interface. 
  Compiler:	GNU gcc.
  Mods:		2009-03-18 RSB.	Wrote.
  
  The idea here is that you can use the program 'socat' (www.socat.org)
  to intercept data stream to a file, and then can use 'ParseSocket' to
  parse that data into a meaningful form for debugging.
  
  For example, yaDEDA likes to talk to yaAGS on port 19897.  In the usual
  setup you'd do something like this:
  
  	yaDEDA2 &
	yaAGS ... arguments ... &

  If instead you did something like this,
  
	yaDEDA2 --port=19990 &
	yaAGS ... arguments ... &
	socat -x -b 4 TCP4:localhost:19897 TCP4-LISTEN:19990 2>socat.txt
		or
	xterm -e "socat -x -b 4 TCP4:localhost:19897 TCP4-LISTEN:19990 2>socat.txt" &
	
  then socat would connect to yaAGS on port 19897, yaDEDA2 would connect to
  socat on port 19990, and socat would bidirectionally relay all data between
  the two ports.  Because of the switches used, socat would also dump all of
  the data in 4-byte or less chunks, formatted in hexadecimal, to stderr
  and hence into the socat.txt file.  This data could then be analyzed farther
  with ParseSocket.  Or, the socat commands listed above could be changed
  by piping into ParseSocket, then filtering with grep, etc., to get real-time
  response.

  ParseSocket is a simple filter from stdin to stdout.
*/

#include <stdio.h>

static const char AgsTypes[041][33] = {
  "Input PGNS Theta Integrator",
  "Input PGNS Phi Integrator",
  "Input PGNS Psi Integrator",
  "Input (unused 03)",
  "Input Discrete Word 1",
  "Input Discrete Word 2",
  "Input (unused 06)",
  "Input DEDA",
  "Input (unused 10)",
  "Input Delta Integral Q Counter",
  "Input Delta Integral R Counter",
  "Input Delta Integral P Counter",
  "Input Delta Vx Counter",
  "Input Delta Vy Counter",
  "Input Delta Vz Counter",
  "Input Downlink Telemetry",
  "Output Sin Theta",
  "Output Cos Theta",
  "Output Sin Phi",
  "Output Cos Phi",
  "Output Sin Psi",
  "Output Cos Psi",
  "Output (unused 26)",
  "Output DEDA",
  "Output Ex",
  "Output Ey",
  "Output Ez",
  "Output Altitude/Altitude-Rate",
  "Output Lateral Velocity",
  "Output (unused 35)",
  "Output Telemetry Word 2",
  "Output Telemetry Word 1",
  "Output Discretes"
};

// Bitmasks for fields in various data words.
#define BM_DEDA_MASKS (BM_DEDA_CLEAR_MASK | BM_DEDA_HOLD_MASK | BM_DEDA_ENTER_MASK | BM_DEDA_READOUT_MASK)
#define BM_GSE_DISCRETE_1 		0200000
#define BM_GSE_DISCRETE_2 		0100000
#define BM_GSE_DISCRETE_3 		0040000
#define BM_DEDA_CLEAR_DISCRETE		0020000
#define BM_DEDA_HOLD_DISCRETE		0010000
#define BM_DEDA_ENTER_DISCRETE		0004000
#define BM_DEDA_READOUT_DISCRETE	0002000
#define BM_GSE_MASK_1			0000200
#define BM_GSE_MASK_2			0000100
#define BM_GSE_MASK_3			0000040
#define BM_DEDA_CLEAR_MASK		0000020
#define BM_DEDA_HOLD_MASK		0000010
#define BM_DEDA_ENTER_MASK		0000004
#define BM_DEDA_READOUT_MASK		0000002

int
main (void)
{
  int i, Fields[4], Sigs[4], FieldCount = 0, AgcRecord, AgsRecord;
  
  while (1)
    {
      if (1 != scanf ("%02X", &Fields[FieldCount]))
        break;
    Retry:
      if (FieldCount == 0 && Fields[0] == 0xFF)
        {
	  printf ("Probable server heartbeat\n");
	  continue;
	}
      Sigs[FieldCount] = 3 & (Fields[FieldCount] >> 6);
      // New record before completion of old one?
      if (FieldCount > 0 && Sigs[FieldCount] == 0)
        {
	  printf ("Short record:");
	  for (i = 0; i <= FieldCount; i++)
	    printf (" %02X", Fields[i]);
	  printf ("\n");
	  Fields[0] = Fields[FieldCount];
	  FieldCount = 0;
	  goto Retry;
	}
      // Illegal signature?
      AgcRecord = AgsRecord = 0;
      for (i = 0; i <= FieldCount; i++)
        if (Sigs[i] != i)
	  break;
      if (i > FieldCount)
        AgcRecord = 1;
      if (!AgcRecord)
        {
	  for (i = 0; i <= FieldCount; i++)
	    if (Sigs[i] != (3 & -i))
	      break;
	  if (i > FieldCount)
	    AgsRecord = 1;
	  if (!AgsRecord)
	    {
	      printf ("Bad signature:");
	      for (i = 0; i <= FieldCount; i++)
		printf (" %02X", Fields[i]);
	      printf ("\n");
	      FieldCount = 0;
	      continue;
	    }
	}
      FieldCount++;
      // Complete record?
      if (FieldCount == 4)
        {
	  if (AgcRecord)
	    {
	      printf ("AGC record:");
	      for (i = 0; i < FieldCount; i++)
		printf (" %02X", Fields[i]);
	      printf ("\n");
	    }
	  else if (AgsRecord)
	    {
	      int Type, Value;
	      printf ("AGS record: ");
	      Type = Fields[0] & 0x3F;
	      Value = ((Fields[1] & 0x3F) << 12) | ((Fields[2] & 0x3F) << 6) | (Fields[3] & 0x3F);
	      if (Type <= 040)
	        printf ("%s", AgsTypes[Type]);
	      else
	        printf ("(unused %o)", Type);
	      printf (", data=%06o", Value);
	      if (Type == 05 && 0 != (Value & BM_DEDA_MASKS))
	        {
		  printf (" DEDA");
		  if (0 != (Value & BM_DEDA_CLEAR_MASK))
		    printf (" CLR=%d", ((Value & BM_DEDA_CLEAR_DISCRETE) != 0));
		  if (0 != (Value & BM_DEDA_HOLD_MASK))
		    printf (" HOLD=%d", ((Value & BM_DEDA_HOLD_DISCRETE) != 0));
		  if (0 != (Value & BM_DEDA_ENTER_MASK))
		    printf (" ENTR=%d", ((Value & BM_DEDA_ENTER_DISCRETE) != 0));
		  if (0 != (Value & BM_DEDA_READOUT_MASK))
		    printf (" READOUT=%d", ((Value & BM_DEDA_READOUT_DISCRETE) != 0));
		}
	      printf ("\n");
	    }
	  else // This can't happen.
	    {
	      printf ("Implementation error, record:");
	      for (i = 0; i < FieldCount; i++)
		printf (" %02X", Fields[i]);
	      printf ("\n");
	    }
	  FieldCount = 0;
	}
    }
  
}

