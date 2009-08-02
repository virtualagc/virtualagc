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

  In addition, as a special exception, Ronald S. Burkey gives permission to
  link the code of this program with the Orbiter SDK library (or with 
  modified versions of the Orbiter SDK library that use the same license as 
  the Orbiter SDK library), and distribute linked combinations including 
  the two. You must obey the GNU General Public License in all respects for 
  all of the code used other than the Orbiter SDK library. If you modify 
  this file, you may extend this exception to your version of the file, 
  but you are not obligated to do so. If you do not wish to do so, delete 
  this exception statement from your version. 
 
  Filename:	NormalizeSourceFile.c
  Purpose:	A function for creating a path from a directory name and
  		a filename.
  Compiler:	GNU gcc.
  Contact:	Ron Burkey <info@sandroid.org>
  Mods:		2009-08-01 RSB	Wrote.
*/

#include <stdlib.h>
#include <stdio.h>
#include <string.h>


// This function is used to create a path to a file, given the directory name
// and the filename within the directory.  This sounds pretty trivial (and is!)
// but it does two things that are important:
// It uses the correct path separator for the operating system, and it handles the cases
// of the source directory being "".  In particular, it
// makes sure that if the directory is "" then the full path turns into "filename" rather
// than "/filename".  On return it points to a buffer that contains the full path, and
// which is overwritten on every call to this function.
char *
NormalizeSourceName (char *Directory, char *Filename)
{
  static char *NormalizedSourceName = NULL;
  int LengthDirectory, LengthFilename, LengthTotal;
  LengthDirectory = strlen (Directory);
  LengthFilename = strlen (Filename);
  LengthTotal = LengthFilename + 1;
  if (LengthDirectory > 0)
    LengthTotal += LengthDirectory + 1;
  NormalizedSourceName = realloc (NormalizedSourceName, LengthTotal);
  if (LengthDirectory > 0)
    {
      strcpy (NormalizedSourceName, Directory);
#ifdef WIN32      
      NormalizedSourceName[LengthDirectory++] = '\\';
#else
      NormalizedSourceName[LengthDirectory++] = '/';
#endif
    }    
  strcpy (&NormalizedSourceName[LengthDirectory], Filename);
  return (NormalizedSourceName);
}

