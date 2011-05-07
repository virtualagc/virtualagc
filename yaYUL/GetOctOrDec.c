/*
  Copyright 2003 Ronald S. Burkey <info@sandroid.org>
  
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

  Filename:	GetOctOrDec.c
  Purpose:	Interprets a field as a decimal or octal number.
  Mode:		04/25/03 RSB.	Split off from Parse2DEC.c.  Added a 
  				bunch of checking to it.
*/

#include "yaYUL.h"
#include <stdlib.h>
#include <ctype.h>
#include <string.h>

//-------------------------------------------------------------------------
// Reads an octal or decimal constant from a string.  Returns 0 on success.
int
GetOctOrDec(const char *s, int *Value)
{
  const char *ss;

  // Well, let's see if this is an octal number.
  ss = s;

  if (*ss == '+' || *ss == '-')
    ss++;

  for (; *ss; ss++)
    if (*ss < '0' || *ss > '7')
      break;

  if (!*ss && ss != s)
    {
      // It is, it is!
      sscanf(s, "%o", Value);
      return (0);
    }  
  
  // Now, let's see if it's a decimal number.
  ss = s;
  if (*ss == '+' || *ss == '-')
    ss++;

  for (; *ss; ss++)
    if (*ss < '0' || *ss > '9')
      break;

  if (*ss == 'D' && ss[1] == 0 && ss != s)
    {
      // It is, it is!
      sscanf(s, "%d", Value);
      return (0);
    }  
    
  // It wasn't either octal or decimal.  :-(      
  return (1);    
}

