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
 * Filename:    yul2agc.c
 * Purpose:     Converts an AGC assembly-language "card" (from a .yul file)
 * 		into the format expected by yaYUL (as if from a .agc file).
 * Mod History: 2016-11-11 RSB  Wrote.
 */

#include "yaYUL.h"
#include <stdio.h>
#include <string.h>

  /*
   * If the input file is of type .yul, then we need to transform the
   * input line into something we'd expect to find in a .agc file instead.
   * The .yul files have a fixed column alignment, as follows (with info
   * taken more-or-less from the MOD 3C document, as freely-interpreted
   * by me):
   *
   *        Column 1        Card type:
   *                                blank   contains code
   *                                R       full-line comment, starting at
   *                                        col 9.
   *                                P       comment consisting of page name,
   *                                        starting at col 9.
   *                                A       not in 3C doc, but I think it's
   *                                        a comment that begins at col 41.
   *                        I only look at blank, R, and A, and ignore
   *                        all others.
   *        Columns 2-7     Card sequence number ... I ignore it.
   *        Column 8        Spacing:
   *                                blank   ends line with \n
   *                                2       ends line with \n\n
   *                                4       ends line with \n\n\n\n
   *                                8       advances to next page after line.
   *                        I treat all identically, as \n.
   *        Columns 9-16    (If a code card) the line label.
   *        Columns 18-23   (If a code card) the operator, pseudo-op
   *        Columns 25-40   (If a code card) the operand, mod1, mod2
   *        Columns 41-80   (If a code card) the line's comment
   *
   * Blank lines or lines beginning with ## are passed through unchanged.
   * Lines beginning with #> are passed though slightly modified, in that
   * "#>" is replaced by "\t\t\t\t\t\t##" ... i.e., this kind of line represents
   * an indented ##-style comment, as opposed to a full-line ##-style comment.
   */
void
yul2agc (char *s)
{
  if (s[0] != 0)
    {
      Line_t card;
      int len;
      char c;

      memcpy (card, s, sizeof(card));
      len = strlen (card);

      if (len < 8)
	{
	  s[0] = 0;
	}
      else if (card[0] == ' ')
	{
	  if (len < 17)
	    sprintf (s, "%s", &card[8]);
	  else
	    {
	      card[16] = 0;
	      sprintf (s, "%-16s", &card[8]);
	      if (len < 25)
		sprintf (&s[16], "%s", &card[17]);
	      else
		{
		  card[23] = 0;
		  sprintf (&s[16], "%-8s", &card[17]);
		  if (len < 41)
		    sprintf (&s[24], "%s", &card[24]);
		  else
		    {
		      c = card[40];
		      card[40] = 0;
		      sprintf (&s[24], "%-24s", &card[24]);
		      card[40] = c;
		      sprintf (&s[48], "# %s", &card[40]);
		    }
		}
	    }
	}
      else if (card[0] == 'R')
	{
	  sprintf (s, "# %s", &card[8]);
	}
      else if (card[0] == 'A')
	{
	  if (len > 40)
	    sprintf (s, "\t\t\t\t\t\t# %s", &card[40]);
	  else
	    sprintf (s, "\t\t\t\t\t\t#");
	}
      else
	{
	  s[0] = 0;
	}
    }
}
