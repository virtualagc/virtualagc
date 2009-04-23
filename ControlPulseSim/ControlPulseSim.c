/*
  Copyright 2004,2005 Ronald S. Burkey <info@sandroid.org>
  
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

  Filename:	ControlPulseSim.c
  Purpose:	This is a small utility program, into which one can
  		enter designations of "control pulses" and see the 
		supposed effect on CPU storage and hidden registers.
  Mode:		07/14/04 RSB	Began.  This is going to take a 
  				long time to do right. At first, I'm just 
				going to implement the control pulses I
				need for the particular CPU instructions
				I'm currently interested in.
		07/17/04 RSB	Added various new control pulses,
				as well as the br1 and br2 flags.
				... But I think the usage is screwed up.
		04/30/05 RSB	Some operations rearranged to avoid
				compiler warnings.
				
  The info for this is taken entirely from Blair-Smith, AGC MEMO #9.
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <stdint.h>

// Registers of interest.
#define MEMSIZE 64
int16_t g = 0, wl = 0, b = 0, y = 0, x = 0, s = 0, sq = 0, Mem[MEMSIZE] = { 0 }, 
  carry = 0, st1 = 0, st2 = 0, itime = 0, br1 = 0, br2 = 0;
#define a Mem[0]
#define l Mem[1]
#define z Mem[5]
static inline int16_t
u (void)
{
  int Result;
  Result = (0177777 & carry) + (0177777 & x) + (0177777 & y);
  if (Result & 0200000)
    {
      Result++;
      Result &= 0177777; 
    }
  return (Result);
}

int
main (void)
{
  char ss[129] = { 0 }, sf[129], *sss, CondFlags[2] = "XX";
  int i, Address, Value;
  FILE *fin = NULL;
  fin = stdin;
  for (;;)
    {
      printf (" G=%06o WL=%06o  B=%06o  Y=%06o  X=%06o  U=%06o  S=%06o SQ=%06o\n",
      	      0177777 & (int) g, 0177777 & (int) wl, 0177777 & (int) b, 
	      0177777 & (int) y, 0177777 & (int) x, 
	      0177777 & (int) u (), 0177777 & (int) s, 0177777 & (int) sq);
      printf (" C=%06o TIME=%d,ST1=%o,ST2=%o,BR1=%o,BR2=%o\n", 
      	      carry, itime, st1, st2, br1, br2);
      for (i = 0; i < MEMSIZE; i++)
        {
	  printf ("%02o=%06o ", i, 0177777 & (int) Mem[i]);
	  if (7 == i % 8)
	    printf ("\n");
	}
      printf ("> ");
      for (ss[0] = 0; ss[0] == 0; )
        {  
	  if (NULL == fgets (ss, sizeof (ss) - 1, fin))
	    {
	      if (fin != stdin)
	        {
		  fclose (fin);
		  fin = stdin;
		  printf ("Control returned to keyboard.\n");
		}
	      else 	
	        break;
	    }
	  for (i = 1, sss = ss; *sss; sss++)
	    {
	      if (*sss == '\n')
		{
		  *sss = 0;
		  break;
		}
	      else if (isspace (*sss))
	        i = 0;
	      else if (i)
		*sss = toupper (*sss);
	    }
	}
      if (ss[0] == 0)
        {
	  printf ("Bye!\n");
          break;
	}
      printf ("Command: %s\n", ss);
      if (!strcmp (ss, "HELP"))
        {
	  printf ("HELP      Displays this menu.\n");
	  printf ("FILE F    Begin taking input from a file F rather than the\n");
	  printf ("          keyboard.  After the file is exhausted, control\n");
	  printf ("          will return to the keyboard.  If the FILE command\n");
	  printf ("          appears within a file already being included by the\n");
	  printf ("          FILE command, then the files will be chained rather\n");
	  printf ("          than nested.\n");
	  printf ("MEM A V   Stores octal value V at octal address A.\n");
	  printf ("NEW V     Start a new instruction, whose octal value is V.\n");
	  printf ("          The 16th bit is the extracode bit.  Note, though,\n");
	  printf ("          that only the address field will be used.\n");
	  printf ("S A       Loads the S register with a memory address.  Usually\n");
	  printf ("          should follow a NEW.\n");
	  printf ("TIME T    Time period (1-12 decimal) in which the control\n");
	  printf ("          pulses occur.\n");
	  printf ("QUIT      Quit from this program.\n");
	  printf ("The following control-pulse names are accepted, but it is not\n");
	  printf ("necessarily true that all of them have been implemented yet:\n");
	  printf ("A2X     B15X    CI      CLXC    DVST    EXT     G2LS    KRPT\n");
	  printf ("L16     L2GD    MONEX   MOUT    NEACOF  NEACON  NISQ    PIFL\n");
	  printf ("PONEX   POUT    PTWOX   R15     R1C     R6      RA      RAD\n");
	  printf ("RB      RB1     RB1F    RB2     RBBK    RC      RCH     RG\n");
	  printf ("RL      RL10BB  RQ      RRPA    RSC     RSCT    RSTRT   RSTSTG\n");
	  printf ("RU      RUS     RZ      ST1     ST2     STAGF   TL15    TMZ\n");
	  printf ("TOV     TPZG    TRSM    TSGN    TSGN2   TSGU    U2BBK   WA\n");
	  printf ("WALS    WB      WCH     WG      WL      WOVR    WQ      WS\n");
	  printf ("WSC     WSQ     WY      WY12    WYD     WZ      Z15     Z16\n");
	  printf ("ZAP     ZIP     ZOUT\n");
	  printf ("The following commands are conditionals (on the BR1 and BR2 flags,\n");
	  printf ("are set by some of the control pulses), causing the following\n");
	  printf ("command to be either accepted or rejected.  The first character\n");
	  printf ("relates to the BR1 flag, and the second to the BR2 flag.  Each flag\n");
	  printf ("can have any of the values 0, 1, or X, meaning that the flag is 0,\n");
	  printf ("or is 1, or that we don't care about it:\n");
	  printf ("00      01      10      11      0X      1X      X0      X1\n");
	}
      else if (1 == sscanf (ss, "FILE%s", sf))
        {
	  if (fin != NULL && fin != stdin)
	    {
	      printf ("Closing the already-open input file.\n");
	      fclose (fin);
	    }
	  fin = fopen (sf, "r");
	  if (fin == NULL)
	    {
	      printf ("Cannot open file %s.\n", sf);
	      printf ("Control returned to keyboard ...\n");
	      fin = stdin;
	    }
	  else
	    printf ("Input now being taken from file %s.\n", sf);
	}
      else if (2 == sscanf (ss, "MEM%o%o", &Address, &Value))
        {
	  if (Address < 0 || Address >= MEMSIZE)
	    printf ("The address must be in the range 0-%o (octal).\n", MEMSIZE);
	  else if (Value < 0 || Value > 0177777)
	    printf ("The value must be in the range 0-177777 (octal).\n");
	  else
	    Mem[Address] = Value;
	}
      else if (1 == sscanf (ss, "NEW%o", &Value))
        {
	  if (Value < 0 || Value > 177777)
	    printf ("Instruction codes are in the range 0-177777 (octal).\n");
	  else
	    {
	      g = wl = y = x = s = carry = itime = 0;
	      sq = b = Value;
	      st1 = st2 = br1 = br2 = 0;
	      Address = (Value & 0777);
	      goto DoS;
	    }
	}
      else if (1 == sscanf (ss, "S%o", &Address))
        {
	DoS:
	  if (Address < 0 || Address >= MEMSIZE)
	    printf ("The address must be in the range 0-%o (octal).\n", MEMSIZE);
	  else
	    {
	      s = Address;
	      g = Mem [s];
	    }
	}
      else if (1 == sscanf (ss, "TIME%d", &Value))
        {
	  if (Value < 1 || Value > 12)
	    printf ("The time must be in the range 1-12 {decimal).\n");
	  else
	    itime = Value;
	}
      else if (!strcmp (ss, "00") || !strcmp (ss, "01") || !strcmp (ss, "10") || !strcmp (ss, "11") || 
               !strcmp (ss, "0X") || !strcmp (ss, "X0") || !strcmp (ss, "1X") || !strcmp (ss, "X1"))
        strcpy (CondFlags, ss);
      else if (!strcmp (ss, "QUIT"))
        break;
      else
        {
	  if (CondFlags[0] != 'X' && CondFlags[0] != br1 + '0')
	    {
	      strcpy (CondFlags, "XX");
	      continue;
	    }
	  if (CondFlags[1] != 'X' && CondFlags[1] != br2 + '0')
	    {
	      strcpy (CondFlags, "XX");
	      continue;
	    }
	  strcpy (CondFlags, "XX");
	  if (!strcmp (ss, "MONEX"))
	    x |= 0177776;
	  else if (!strcmp (ss, "RL10BB"))
	    wl = ((wl & ~01777) | (b & 01777));
	  else if (!strcmp (ss, "RA"))
	    wl = a;
	  else if (!strcmp (ss, "RAD"))
	    {
	      // FIX ME: RAD not right if next instruction if INHINT, RELINT, EXTEND, or (probably) RESUME.
	      wl = g;
	    }
	  else if (!strcmp (ss, "RB"))
	    wl = b;
	  else if (!strcmp (ss, "RC"))
	    wl = ~b;
	  else if (!strcmp (ss, "RG"))
	    wl = g;
	  else if (!strcmp (ss, "RL"))
	    wl = ((l & 0137777) | (040000 & (l >> 1)));
	  else if (!strcmp (ss, "RSC"))
	    {
	      if (s >= MEMSIZE)
		printf ("The address is outside the range of simulated memory.\n");
	      else 
		wl = Mem[s];
	    }
	  else if (!strcmp (ss, "RU"))
	    wl = u ();
	  else if (!strcmp (ss, "RZ"))
	    wl = z;
	  else if (!strcmp (ss, "ST1"))
	    st1 = 1;
	  else if (!strcmp (ss, "ST2"))
	    st2 = 1;
	  else if (!strcmp (ss, "TMZ"))
	    {
	      if (wl == (int16_t) 0177777)
		br2 = 1;
	    }
	  else if (!strcmp (ss, "TPGZ"))
	    {
	      if (g == 0)
		br2 = 1;
	    }
	  else if (!strcmp (ss, "TSGN"))
	    br1 = ((wl >> 15) & 1);
	  else if (!strcmp (ss, "TSGN2"))
	    br2 = ((wl >> 15) & 1);
	  else if (!strcmp (ss, "WA"))
	    a = wl;
	  else if (!strcmp (ss, "WB"))
	    b = wl;
	  else if (!strcmp (ss, "WG"))
	    {
	      if (s == 020)
		g = ((077777 & (wl >> 1)) | (0100000 & (wl << 14)));
	      else if (s == 021)
		g = ((077777 & (wl >> 1)) | (0100000 & wl));
	      else if (s == 022)
		g = ((0177776 & (wl << 1)) | (1 & (wl >> 14)));
	      else if (s == 023)
		g = (0177 & (wl >> 7));
	      else
		g = wl;
	    }
	  else if (!strcmp (ss, "WL"))
	    l = wl;
	  else if (!strcmp (ss, "WS"))
	    s = (07777 & wl);
	  else if (!strcmp (ss, "WSC"))
	    {
	      if (s >= MEMSIZE)
		printf ("The address is outside the range of simulated memory.\n");
	      else 
		Mem[s] = wl;
	    }
	  else if (!strcmp (ss, "WY"))
	    {
	      x = 0;
	      y = wl;
	    }
	  else if (!strcmp (ss, "WY12"))
	    {
	      x = 0;
	      y = (07777 & wl);
	    }
	  else if (!strcmp (ss, "WZ"))
	    z = wl;
	  else
	    printf ("Unimplemented or unrecognized command.\n");
        }
    }
  return (0);
}

