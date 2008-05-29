/*
  Copyright 2004-2005 Ronald S. Burkey <info@sandroid.org>

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
 
  Filename:	rfopen.c
  Purpose:	A replacement for fopen which looks in the installation 
  		directory if the file isn't in the current directory.
  Compiler:	GNU gcc.
  Contact:	Ron Burkey <info@sandroid.org>
  Reference:	http://www.ibiblio.org/apollo/index.html
  Mods:		05/06/04 RSB.	Began.
  		05/14/04 RSB.	Added INSTALLDIR.
		05/30/04 RSB	Added some missing header files.
		08/11/04 RSB	Default install dir in Win32 changed
				(from /usr/local/bin) to c:/mingw/bin.
		02/27/05 RSB	Added the license exception, as required by
				the GPL, for linking to Orbiter SDK libraries.
		05/14/05 RSB	Corrected website references
*/

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include "agc_engine.h"

//---------------------------------------------------------------------------
// My feeble attempt at looking for stuff like Luminary131.bin or LM.ini in
// the installation directory if not found in the current directory.

// This default probably looks right only for *nix, and not for Win32, 
// we also use this directory in Win32 because the build-instructions
// assume the use of Msys (which is the mingw32 compiler's cygwin-like
// environment), so there actually is a /usr/local/bin directory in 
// both cases.
#ifndef INSTALLDIR
#ifdef WIN32
#define INSTALLDIR "c:/mingw/bin"
#else
#define INSTALLDIR "/usr/local/bin"
#endif
#endif
char *InstallationPath = INSTALLDIR;

FILE *
rfopen (const char *Filename, const char *mode)
{
  char *NewFilename;
  FILE *fp;
  //printf ("\'%s\'\n", INSTALLDIR);
  fp = fopen (Filename, mode);
  if (fp != NULL)
    return (fp);
  NewFilename =
    (char *) malloc (2 + strlen (Filename) + strlen (InstallationPath));
  if (NewFilename == NULL)
    return (NULL);
  strcpy (NewFilename, InstallationPath);
  strcat (NewFilename, "/");
  strcat (NewFilename, Filename);
  fp = fopen (NewFilename, mode);
  free (NewFilename);
  return (fp);
}
