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

  Filename:	yaUniverse.c
  Purpose:	The is the main program for yaUniverse.  yaUniverse itself provides
  		a complete dynamical model of the Earth-Moon-Sun-Spacecraft
		system.
  Contact:	Ron Burkey <info@sandroid.org>
  Website:	www.ibiblio.org/apollo/index.html
  Mode:		08/24/04 RSB.	Began.
  		2004-09-02 RSB.	Changed to yaUniverse (from yaIMU).
		2004-09-23 RSB	Added the test code for comparing the ephemeris
				against numerically-integrated solutions.
				Added the Jupiter, Saturn, Venus, Mars.
		2004-09-24 RSB	Added a bunch of other stuff, like Titan
				and the Galileans, and cleaned up the program
				a lot.  Particularly, the ephemeris data has
				been simplified, as I now realize that data
				at hourly intervals is perfectly adequate
				(rather than minutely intervals).  Furthermore,
				the default integration timestep has been 
				increased from 1 minute to 6 hours.
		2005-05-14 RSB	Corrected website references.  Added a cast
				to avoid a warning when compiling on Mac OS X.
  
  The dynamical model of the heavenly-body/Spacecraft system includes the
  following interactions.  Multiple spacecraft are tracked.  (For example,
  when the CSM and LEM are docked, only the composite spacecraft is modeled.
  However, when the CSM and LEM are not docked, the CSM and LEM are modeled
  separately.
  
  1. Gravitational.  The initial positions of the heavenly bodies are assumed
     known from ephemeris data (obtained from JPL).  Subsequent positions of
     all supported heavenly bodies and the spacecraft are numerically integrated
     from the physics (Newtonian).  Relativistic effects are ignored.  In order
     of decreasing importance, the heavenly bodies accounted for are:
     	Earth/Moon/Sun  49.71 km
	Jupiter		 9.12 km
	Saturn		 4.74 km
	Venus		 0.67 km
	Mars		 0.50 km
     The numbers indicated above are the error over the Apollo 8 epoch (1968-12-20 00:00
     through 1968-12-29 00:00) when numerically integrating the position of the moon
     using a 4th-order Runge-Kutta method with one-minute timesteps.  In other words, 
     if only the Earth and Sun are accounted for, there is a cumulative error of nearly 
     50 km in the position of the moon.  Adding Jupiter, this drops to below 10 km.  
     Adding Saturn, it drops to below 5 km.  And so on.  It seems to me that Uranus and 
     Mercury should also have a measurable effect at this scale, but do not seem to (at 
     least, in the Apollo 8 epoch).  So we ignore them.  I don't know where that last 0.5 
     km of error is coming from; if you know, tell me and we'll get rid of it.
     
     (Later:  Surprisingly, with a timestep of 6 hours rather than 1 minute for
     the numerical integration, the error drops from 0.50 km to about 0.33 km.  So at 
     least some of the error must come from accumulation of roundoff.)
     
     "Masscons" (spherical asymmetries in the bodies) are not accounted for, and I 
     suspect that they account for the bulk of the remaining error in the earth-moon
     sub-system.
  
  2. Rotational.  Approximations of the inertia tensors of the spacecraft
     (separately, and joined) are used to model the rotation.
  
  3. Thrust (forces and torques).  Loss of mass due to loss of propellant
     is modeled (by modifying the inertia tensor), as well as the accelerations
     due to the thrust itself.
  
  4. Atmospheric drag.  This occurs only during reentry of the CM.
     During reentry, only the Earth's gravity and atmospheric drag on the
     CM are modeled.  Other spacecraft and other forces are ignored.
*/

#define ORIGINAL_YAUNIVERSE_C
#include "stdlib.h"
#include "yaUniverse.h"
#include "math.h"

// Stuff needed for the numerical integration.
int NumBodies = 7;
int NumSpacecraft = 0;
ts_t *StateVector;
struct tss_t *State;

// Time, in seconds, between the ephemeris datapoints.
#define EPH_STEP 3600

// TimeStep is the size (in seconds) of the integration timestep when only 
// gravitational interactions are present, and when the spacecraft are not
// close to planetary bodies.  It must divide evenly into EPH_STEP, or else it 
// must be an integral multiple of EPH_STEP. Note that TimeStepInc must not be less 
// than 1.
#define DEFAULT_TIMESTEP 21600
static int TimeStep = DEFAULT_TIMESTEP, TimeStepInc = DEFAULT_TIMESTEP / EPH_STEP;

//------------------------------------------------------------------------
// Print a line of collected ephemeris data.

void
PrintEphemerisLine (Ephemeris_t *Ephemeris, int Number, char *Name)
{
  int i;
  if (Number < 0)
    {
      printf ("         ");
      i = -Number;
    }
  else
    {
      printf ("%03d hrs: ", Number);
      i = Number;
    }
  printf ("%-8s " FMT FMT FMT " " FMT FMT FMT "\n", Name, 
	  Ephemeris->Positions[i].xMeters, Ephemeris->Positions[i].yMeters, Ephemeris->Positions[i].zMeters,
	  Ephemeris->Positions[i].Vx, Ephemeris->Positions[i].Vy, Ephemeris->Positions[i].Vz);
}

//-------------------------------------------------------------------------
// Adds initial data for a heavenly body to the state vector.

int VectorLoad = 0;

void
InitialData (Ephemeris_t *Ephemeris, double gm)
{
  if (VectorLoad >= 7 * NumBodies)
    {
      printf ("State vector unexpectedly filled up.\n");
      return;
    }
  StateVector[VectorLoad++] = Ephemeris->Positions[0].xMeters;
  StateVector[VectorLoad++] = Ephemeris->Positions[0].yMeters;
  StateVector[VectorLoad++] = Ephemeris->Positions[0].zMeters;
  StateVector[VectorLoad++] = Ephemeris->Positions[0].Vx;
  StateVector[VectorLoad++] = Ephemeris->Positions[0].Vy;
  StateVector[VectorLoad++] = Ephemeris->Positions[0].Vz;
  StateVector[VectorLoad++] = gm;
}

//-------------------------------------------------------------------------
// Print an error indication for the numerical integration.

void
PrintNumError (int EphIndex, int Offset, Ephemeris_t *Ephemeris, char *Name)
{
  double dx, dy, dz, Error;
  dx = StateVector[Offset] - Ephemeris->Positions[EphIndex].xMeters;
  dy = StateVector[Offset + 1] - Ephemeris->Positions[EphIndex].yMeters;
  dz = StateVector[Offset + 2] - Ephemeris->Positions[EphIndex].zMeters;
  Error = sqrt (dx * dx + dy * dy + dz * dz) / 1000;
  printf ("   %-9s%7.2f", Name, Error);
}

//-------------------------------------------------------------------------

int
main (int argc, char *argv[])
{
  int i, j, EphemerisReadTest = 0, NumericalIntegrationTest = 0;
  
  printf ("Apollo Guidance Computer IMU emulation, version " NVER 
  	  ", built " __DATE__ "\n");
  printf ("(c)2004,2005 Ronald S. Burkey\n");
  printf ("Refer to http://www.ibiblio.org/apollo/index.html for more information.\n");
  
  // Parse the command-line arguments.
  for (i = 1; i < argc; i++)
    {
      if (!strncmp (argv[i], "--mission=", 10))
        {
	  if (strlen (&argv[i][10]) < sizeof (MissionName))
	    strcpy (MissionName, &argv[i][10]);
	  else
	    {
	      printf ("The mission name is limited to %d characters or less.\n",
	      	      (int) sizeof (MissionName) - 1);
	      return (1);
	    }
	}
      else if (!strcmp (argv[i], "--ephem-read"))
        EphemerisReadTest = 1;
      else if (!strcmp (argv[i], "--ephem-int"))
        NumericalIntegrationTest = 1;
      else if (1 == sscanf (argv[i], "--runge-kutta=%d", &j) && (j == 2 || j == 4))
        RungeKuttaOrder = j;
      else if (1 == sscanf (argv[i], "--planets=%d", &j) && j >= 3 && j <= 15)
        NumBodies = j;
      else if (1 == sscanf (argv[i], "--timestep=%d", &j) && j >= 1 && (EPH_STEP % j == 0 || j % EPH_STEP == 0))
        {
          TimeStep = j;
	  TimeStepInc = j / EPH_STEP;
	  if (TimeStepInc < 1)
	    TimeStepInc = 1;
	}
      else
        {
	  printf ("\n");
	  printf ("USAGE:\n");
	  printf ("\tyaUniverse [OPTIONS]\n");
	  printf ("\n");
	  printf ("The available options are:\n");
	  printf ("--help             Displays this page of information.\n");
	  printf ("--mission=Name     Selects the name of the mission, which determines\n");
	  printf ("                   the initial positions of the planetary bodies.  (The\n");
	  printf ("                   mission names are like \"Apollo8\", without quotes.)\n");
	  printf ("--ephem-read       Merely read and print out the ephemeris.  Forces\n");
	  printf ("                   --mission=Apollo8.  The Apollo8 ephemeris differs from\n");
	  printf ("                   other missions, in that full data is present rather than\n");
	  printf ("                   mere initial conditions.\n");
	  printf ("--ephem-int        Numerically integrate the Moon/Earth positions to\n");
	  printf ("                   cross-check the ephemeris data and the numerical\n");
	  printf ("                   algorithms, and then quit.  Forces --mission=Apollo8\n");
	  printf ("--runge-kutta=N    The order of the Runge-Kutta numerical integration.\n");
	  printf ("                   N=2 or 4 (default is %d).\n", RungeKuttaOrder);
	  printf ("--planets=N        The number of planetary bodies used in the numerical\n");
	  printf ("                   integration.  N=3-15, and is %d by default:\n", NumBodies);
	  printf ("                      N=3   Earth, Moon, and Sun.\n");
	  printf ("                      N=4   Same as N=3, plus Jupiter.\n");
	  printf ("                      N=5   Same as N=4, plus Saturn.\n");
	  printf ("                      N=6   Same as N=5, plus Venus.\n");
	  printf ("                      N=7   Same as N=6, plus Mars.\n");
	  printf ("                      N=11  Same as N=7, plus Ganymede, Io, Europa, & Callisto.\n");
	  printf ("                      N=15  Same as N=11, plus Titan, Tethys, Rhea, & Dione.\n");
	  printf ("                   The addition of Titan et al. makes a big difference in the\n");
	  printf ("                   error of Saturn\'s position, but has no obvious effect on the \n");
	  printf ("                   inner solar system.  Similar comments apply to Galileans\n");
	  printf ("                   and their effects on Jupiter and the inner solar system.\n");
	  printf ("                   Mercury and Uranus also have no obvious effect at all.\n");
	  printf ("                   NOTE:  If the Galileans are added, you will need to adjust\n");
	  printf ("                   the timestep (see below) downward, say to 7200, to account\n");
	  printf ("                   for the very short orbital periods of some satellites.\n");
	  printf ("--timestep=T       The time, in seconds, used as the timestep for the \n");
	  printf ("                   numerical integration when only gravitational effects\n");
	  printf ("                   present, and the spacecraft are not close to the planetary\n");
	  printf ("                   bodies.  The default is %d seconds.  The value must be\n", TimeStep);
	  printf ("                   either an exact divisor or exact multiple of %d.  \n", EPH_STEP);
	  printf ("                   Intermediate values (at times between the timesteps)\n");
	  printf ("                   are obtained by interpolation.\n");
	  printf ("\n");
	  return (0);	
        }
    }
  if (EphemerisReadTest || NumericalIntegrationTest)
    strcpy (MissionName, "Apollo8");
  
  // Prepare the state vector and state structure.
  StateVector = (ts_t *) calloc ((NumBodies + NumSpacecraft) * 7, sizeof (ts_t));
  if (StateVector == NULL)
    {
      printf ("Out of memory.\n");
      return (1);
    }
  State = TsAlloc (NumBodies + NumSpacecraft);
  if (State == NULL)
    {
      printf ("Unable to initialize the numerical integration.\n");
      return (0);
    }
  
  // Get the planetary ephemeris data.
  if (FetchEphemerisPlanet (&EarthEphemeris, "Earth", MissionName) ||
      FetchEphemerisPlanet (&MoonEphemeris, "Moon", MissionName) ||
      (FetchEphemerisPlanet (&SunEphemeris, "Sun", MissionName) && NumBodies > 2) ||
      (FetchEphemerisPlanet (&JupiterEphemeris, "Jupiter", MissionName) && NumBodies > 3) ||
      (FetchEphemerisPlanet (&SaturnEphemeris, "Saturn", MissionName) && NumBodies > 4) ||
      (FetchEphemerisPlanet (&VenusEphemeris, "Venus", MissionName) && NumBodies > 5) ||
      (FetchEphemerisPlanet (&MarsEphemeris, "Mars", MissionName) && NumBodies > 6) ||
      (FetchEphemerisPlanet (&GanymedeEphemeris, "Ganymede", MissionName) && NumBodies > 7) ||
      (FetchEphemerisPlanet (&IoEphemeris, "Io", MissionName) && NumBodies > 8) ||
      (FetchEphemerisPlanet (&EuropaEphemeris, "Europa", MissionName) && NumBodies > 9) ||
      (FetchEphemerisPlanet (&CallistoEphemeris, "Callisto", MissionName) && NumBodies > 10) ||
      (FetchEphemerisPlanet (&TitanEphemeris, "Titan", MissionName) && NumBodies > 11) ||
      (FetchEphemerisPlanet (&TethysEphemeris, "Tethys", MissionName) && NumBodies > 12) ||
      (FetchEphemerisPlanet (&RheaEphemeris, "Rhea", MissionName) && NumBodies > 13) ||
      (FetchEphemerisPlanet (&DioneEphemeris, "Dione", MissionName) && NumBodies > 14) )
    return (1);
  if (EphemerisNumPositions <= 0)
    {
      printf ("The ephemeris data is bad.\n");
      return (1);
    }
  printf ("Ephemeris data loaded for %s.\n", MissionName);
  
  // Initialize the state vector. 
  InitialData (&EarthEphemeris, GM_EARTH);
  InitialData (&MoonEphemeris, GM_MOON);
  if (NumBodies > 2)
    InitialData (&SunEphemeris, GM_SUN);
  if (NumBodies > 3)
     InitialData (&JupiterEphemeris, GM_JUPITER);
  if (NumBodies > 4)
     InitialData (&SaturnEphemeris, GM_SATURN);
  if (NumBodies > 5)
    InitialData (&VenusEphemeris, GM_VENUS);
  if (NumBodies > 6)
    InitialData (&MarsEphemeris, GM_MARS);
  if (NumBodies > 7)
    InitialData (&GanymedeEphemeris, GM_GANYMEDE);
  if (NumBodies > 8)
    InitialData (&IoEphemeris, GM_IO);
  if (NumBodies > 9)
    InitialData (&EuropaEphemeris, GM_EUROPA);
  if (NumBodies > 10)
    InitialData (&CallistoEphemeris, GM_CALLISTO);
  if (NumBodies > 11)
    InitialData (&TitanEphemeris, GM_TITAN);
  if (NumBodies > 12)
    InitialData (&TethysEphemeris, GM_TETHYS);
  if (NumBodies > 13)
    InitialData (&RheaEphemeris, GM_RHEA);
  if (NumBodies > 14)
    InitialData (&DioneEphemeris, GM_DIONE);
  if (VectorLoad < 7 * NumBodies)
    {
      printf ("Not enough initialization data for state vector.\n");
      return (1);
    }
	
  if (EphemerisReadTest)	
    {
      printf ("Ephemeris data, scaled to MKS units:\n");
      for (i = 0; i < EarthEphemeris.NumPositions; i++)
        {
	  PrintEphemerisLine (&EarthEphemeris, i, "Earth");
	  PrintEphemerisLine (&MoonEphemeris, -i, "Moon");
	  if (NumBodies > 2)
	    PrintEphemerisLine (&SunEphemeris, -i, "Sun");
	  if (NumBodies > 3)
	    PrintEphemerisLine (&JupiterEphemeris, -i, "Jupiter");
	  if (NumBodies > 4)
	    PrintEphemerisLine (&SaturnEphemeris, -i, "Saturn");
	  if (NumBodies > 5)
	    PrintEphemerisLine (&VenusEphemeris, -i, "Venus");
	  if (NumBodies > 6)
	    PrintEphemerisLine (&MarsEphemeris, -i, "Mars");
	  if (NumBodies > 7)
	    PrintEphemerisLine (&GanymedeEphemeris, -i, "Ganymede");
	  if (NumBodies > 8)
	    PrintEphemerisLine (&IoEphemeris, -i, "Io");
	  if (NumBodies > 9)
	    PrintEphemerisLine (&EuropaEphemeris, -i, "Europa");
	  if (NumBodies > 10)
	    PrintEphemerisLine (&CallistoEphemeris, -i, "Callisto");
	  if (NumBodies > 11)
	    PrintEphemerisLine (&TitanEphemeris, -i, "Titan");
	  if (NumBodies > 12)
	    PrintEphemerisLine (&TethysEphemeris, -i, "Tethys");
	  if (NumBodies > 13)
	    PrintEphemerisLine (&RheaEphemeris, -i, "Rhea");
	  if (NumBodies > 14)
	    PrintEphemerisLine (&DioneEphemeris, -i, "Dione");
	}
      return (0);
    }	
  
  if (NumericalIntegrationTest)
    {      
      // Also for testing.  Numerically integrates the positions of the heavenly
      // bodies, and then compares the data for the Moon & Earth against ephemeris.
      printf ("Error (km.) in positioning:\n");
      for (i = 0; i < MoonEphemeris.NumPositions; i += TimeStepInc)
	{
	  printf ("%05d hours: ", i);
	  PrintNumError (i, 0, &EarthEphemeris, "Earth");
	  PrintNumError (i, 7, &MoonEphemeris, "Moon");
	  if (NumBodies > 2)
	    PrintNumError (i, 14, &SunEphemeris, "Sun");
	  if (NumBodies > 3)
	    printf ("\n             ");
	  if (NumBodies > 3)
	    PrintNumError (i, 21, &JupiterEphemeris, "Jupiter");
	  if (NumBodies > 4)
	    PrintNumError (i, 28, &SaturnEphemeris, "Saturn");
	  if (NumBodies > 5)
	    PrintNumError (i, 35, &VenusEphemeris, "Venus");
	  if (NumBodies > 6)
	    printf ("\n             ");
	  if (NumBodies > 6)
	    PrintNumError (i, 42, &MarsEphemeris, "Mars");
	  if (NumBodies > 7)
	    PrintNumError (i, 49, &GanymedeEphemeris, "Ganymede");
	  if (NumBodies > 8)
	    PrintNumError (i, 56, &IoEphemeris, "Io");
	  if (NumBodies > 9)
	    printf ("\n             ");
	  if (NumBodies > 9)
	    PrintNumError (i, 63, &EuropaEphemeris, "Europa");
	  if (NumBodies > 10)
	    PrintNumError (i, 70, &CallistoEphemeris, "Callisto");
	  if (NumBodies > 11)
	    PrintNumError (i, 77, &TitanEphemeris, "Titan");
	  if (NumBodies > 12)
	    printf ("\n             ");
	  if (NumBodies > 12)
	    PrintNumError (i, 84, &TethysEphemeris, "Tethys");
	  if (NumBodies > 13)
	    PrintNumError (i, 91, &RheaEphemeris, "Rhea");
	  if (NumBodies > 14)
	    PrintNumError (i, 98, &DioneEphemeris, "Dione");
	  printf ("\n");
	  // Integrate for the TimeStep seconds.
	  for (j = 0; j < EPH_STEP; j += TimeStep)
	    TsStep (State, TimeStep, i * EPH_STEP + j, StateVector);
	}
      TsFree (State);
      return (0);
    }
  
  // Here's where to put code that will actually do something ...
  printf ("Not implemented yet.  Use --ephem-read or --ephem-int, with --mission=Test.\n");
  
  return (0);
}

