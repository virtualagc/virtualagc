/*
  Copyright 2004 Ronald S. Burkey <info@sandroid.org>
  
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

  Filename:	FetchEphemerisPlanet.c
  Purpose:	Gets ephemeris data for a specific body (Earth/Moon/Sun).
  Mode:		2004-08-24 RSB.	Began.
  		2004-09-02 RSB	Changed to yaUniverse (from yaIMU).
		2004-09-24 RSB	Data is now at 1-hour intervals rather than
				the previous 1-minute intervals, as 
				numerical experiments show that a 6-hour
				integration step works quite well.
*/

#include "yaUniverse.h"

//-------------------------------------------------------------------------
// Read the Earth/Moon/Sun ephemeris data.  The data itself was obtained from
//	telnet ssd.jpl.nasa.gov 6775
// and then stored in files.  The function itself returns 0 on success.
//
// In order to have the closest approximation we can to an inertial 
// reference system, we use the "solar-system barycenter" (i.e., the "center
// of gravity" of the solare system) as the origin our coordinate system, 
// and the plane of the ecliptic as our X-Y plane.  Planetary positions are
// interpolated at 1-hour intervals.  This is all taken care of by JPL, 
// if the proper options are selected at the telnet site mentioned above.
// Note that there is also a JPL ephemeris website, but that the website
// does not provide enough options to fetch the data as decribed above, 
// because it is tailored to data of interest to observers.
//
// The ephemeris data has only been collected for the epochs of the actual
// missions, and are named according to the missions.  The default mission
// is Apollo 8, so the default ephemeris files are
//	Ephemeris-Earth-Apollo8.txt
//	Ephemeris-Moon-Apollo8.txt
//	Ephemeris-Sun-Apollo8.txt
// or in terms of the Body and Mission function parameters,
//	Ephemeris-Body-Mission.txt
// (with the word "Ephemeris" being literal, of course, rather than relating
// to the function parameter of the same name).
//
// I work with a "mission epoch" that goes from the day before the launch
// until the day after splashdown, more or less, and reference all time
// to the start of this epoch.  The MKS system is used for all internal
// calculations.

int
FetchEphemerisPlanet (
  Ephemeris_t *Ephemeris,	// Pre-allocated structure to store the data.
  char *Body, 			// Name of the body ("Earth", "Moon", "Sun").
  char *Mission			// Mission name ("Apollo8", Apollo9", etc.).
)
{
  FILE *fp;
  char EphemerisName[32 + sizeof (MissionName)];
  char EphemerisLine[100];
  int InData = -1;
  double x, y, z;
  double Vx, Vy, Vz;
  
  Ephemeris->NumPositions = 0;
  
  sprintf (EphemerisName, "Ephemeris-%s-%s.txt", Body, Mission);
  fp = rfopen (EphemerisName, "r");
  if (fp == NULL)
    {  
      printf ("Cannot find the file \"%s\".\n", EphemerisName);
      return (1);
    }
    
  // Data starts after the line reading "$$SOE", and ends just before
  // "$$EOE".  Each data-point consists of 4 lines, of which only the
  // second (the x,y,z coordinates of the body, in AU) really interest us.
  // We also collect the velocity data from line 3, because it's useful
  // in setting up the initial position of the spacecraft.
  while (NULL != fgets (EphemerisLine, sizeof (EphemerisLine) - 1, fp))
    {
      if (!strncmp (EphemerisLine, "$$SOE", 5))
        {
	  InData = 0;
	  continue;
	}
      if (!strncmp (EphemerisLine, "$$EOE", 5))
        break;
      if (InData < 0)
        continue;
      switch (InData++ & 3)
        {
	case 0:		// Timestamp: ignore.
	  if (Ephemeris->NumPositions >= MAX_HOURS)
	    {
	      printf ("Too many data points in \"%s\".\n", EphemerisName);
	      fclose (fp);
	      return (1);
	    }
	  break;
	case 1:		// Position data.
	  if (3 != sscanf (EphemerisLine, "%lf%lf%lf", &x, &y, &z))
	    {
	      printf ("Malformed position data in \"%s\".\n", EphemerisName);
	      fclose (fp);
	      return (1);
	    }
	  Ephemeris->Positions[Ephemeris->NumPositions].xMeters = x * METERS_PER_AU;
	  Ephemeris->Positions[Ephemeris->NumPositions].yMeters = y * METERS_PER_AU;
	  Ephemeris->Positions[Ephemeris->NumPositions].zMeters = z * METERS_PER_AU;
	  break;
	case 2:		// Velocity data.
	  if (3 != sscanf (EphemerisLine, "%lf%lf%lf", &Vx, &Vy, &Vz))
	    {
	      printf ("Malformed velocity data in \"%s\".\n", EphemerisName);
	      fclose (fp);
	      return (1);
	    }
	  Ephemeris->Positions[Ephemeris->NumPositions].Vx = Vx * METERS_PER_AU / SECONDS_PER_DAY;
	  Ephemeris->Positions[Ephemeris->NumPositions].Vy = Vy * METERS_PER_AU / SECONDS_PER_DAY;
	  Ephemeris->Positions[Ephemeris->NumPositions].Vz = Vz * METERS_PER_AU / SECONDS_PER_DAY;
	  break;
	case 3:  	// Range data: ignore.
	  Ephemeris->NumPositions++;
	  break;
        }
    }
    
  fclose (fp);
  if (EphemerisNumPositions < 0 || Ephemeris->NumPositions < EphemerisNumPositions)
    EphemerisNumPositions = Ephemeris->NumPositions;
  return (0);
}

