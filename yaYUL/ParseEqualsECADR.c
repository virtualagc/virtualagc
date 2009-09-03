/*
  Copyright 2003-2004 Ronald S. Burkey <info@sandroid.org>
  Copyright 2009 Jim Lawton <jim DOT lawton AT gmail DOT com>
  
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

  Filename:	ParseEqualsECADR.c
  Purpose:	Assembles the =ECADR pseudo-op, which currently has no known effect.
  Mode:		2009-09-03 JL	Added, based on original EQUALS parser.
*/

#include "yaYUL.h"
#include <stdlib.h>
#include <string.h>

extern Line_t CurrentFilename;
extern int CurrentLineInFile;

int ParseEqualsECADR(ParseInput_t *InRecord, ParseOutput_t *OutRecord)
{
  strcpy(OutRecord->ErrorMessage, "Skipping =ECADR directive");
  OutRecord->Warning = 1;
  return (0);  
}


