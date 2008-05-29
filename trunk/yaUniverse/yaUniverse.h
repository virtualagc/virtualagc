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

  Filename:	yaUniverse.h
  Purpose:	Constants, prototypes, and what-not for yaUniverse.
  Mode:		08/25/04 RSB.	Began.
  		2004-09-02 RSB	Changed to yaUniverse (from yaIMU).
		2004-09-23 RSB	Added various stuff used with TimeStep.c.
				Added Jupiter, Saturn, Venus, Mars.
  
  The dynamical model of the Earth/Moon/Sun/Spacecraft system includes the
  following interactions:  Multiple spacecraft are tracked.  (For example,
  when the CSM and LEM are docked, only the composite spacecraft is modeled.
  However, when the CSM and LEM are not docked, the CSM and LEM are modeled
  separately.
  
  1. Gravitational.  The positions of the Earth, Moon, and Sun are assumed
     known from ephemeris data (obtained from JPL).  The gravitational
     attractions of other planets, and of the spacecraft, are neglected.
     The paths of the spacecraft are therefore computed from the 
     gravitational attractions of the Earth, Moon, and Sun, which are
     at known positions at all times.
  
  2. Rotational.  Approximations of the inertia tensors of the spacecraft
     (separately, and joined) are used to model the rotation.
  
  3. Thrust (forces and torques).  Loss of mass due to loss of propellant
     is modeled (by modifying the inertia tensor), as well as the accelerations
     due to the thrust itself.
  
  4. Atmospheric drag.  This occurs only during reentry of the CM.
     During reentry, only the Earth's gravity and atmospheric drag on the
     CM are modeled.  Other spacecraft and other forces are ignored.
*/

#ifndef INCLUDED_YAUNIVERSE_H
#define INCLUDED_YAUNIVERSE_H

#include <stdio.h>
#include <string.h>

//--------------------------------------------------------------------------
// Constants.

#define METERS_PER_AU 149597870691.0
#define SECONDS_PER_DAY (24 * 3600)
// The maximum allowable length of a mission, in hours.
#define MAX_HOURS (15 * 24)

// The gravitational constant G, like any measured constant, is only known to a certain
// level of accuracy, and the "best" value depends on who you talk to.  In keeping 
// with my own purposes, it seems reasonable to accept JPL's value, which as of today
// (2004-09-22) is 6.67259(+-0.00030)*10^-11 in MKS units (meters-cubed/kg/sec-squared).
#define G (6.67259E-11)

// Instead of using the masses of the planets, we use G times the masses.  This is
// because GM is known to a much higher degree of accuracy than G or M individually.
#define GM_SUN 1.3271243994E20
#define GM_EARTH 398600.440E9
#define GM_MOON 4902.798E9
#define GM_JUPITER 126686537.0E9
#define GM_SATURN 37931284.5E9
#define GM_VENUS 324858.63E9
#define GM_MARS 42828.3E9
#define GM_MERCURY 22032.09E9
#define GM_URANUS 5793947E9
#define GM_GANYMEDE 9888.8E9
#define GM_IO 5960.6E9
#define GM_EUROPA 3200.8E9
#define GM_CALLISTO 7179.7E9
#define GM_TITAN 8978.03E9
#define GM_TETHYS 41.21E9
#define GM_DIONE 73.13E9
#define GM_RHEA 154.59E9

//--------------------------------------------------------------------------
// Data types.

// Precision used for all variables in the TimeStep function.
//typedef long double ts_t;	// Quadruble-precision.
typedef double ts_t;		// Double-precision.
//typedef float ts_t;		// Single-precision.

// Format for displaying floating-point numbers.  Must match ts_t.
//#define FMT " %+LE"
#define FMT " %+lE"
//#define FMT " %+E"

typedef struct {
  ts_t xMeters, yMeters, zMeters;	// From solar-system center of mass
  ts_t Vx, Vy, Vz;			// In meters/second.
  //int tSeconds;			// From start of mission epoch
} Position_t;

typedef struct {
  int NumPositions;
  Position_t Positions[MAX_HOURS];
} Ephemeris_t;

struct tss_t {
  int NumBodies;		// Number of bodies.
  int Dim;			// State-vector dimension = 7 * NumBodies.
  ts_t *Rate, *TempV, *k1, *k2, *k3, *k4, *Thrust;	// Dummy arrays.
};

//-------------------------------------------------------------------------
// Variables.

#ifdef ORIGINAL_YAUNIVERSE_C

char MissionName[33] = "Apollo8";
Ephemeris_t EarthEphemeris, MoonEphemeris, SunEphemeris, JupiterEphemeris,
  SaturnEphemeris, VenusEphemeris, MarsEphemeris, UranusEphemeris,
  MercuryEphemeris, TitanEphemeris, 
  GanymedeEphemeris, IoEphemeris, EuropaEphemeris, CallistoEphemeris,
  TethysEphemeris, DioneEphemeris, RheaEphemeris;
int EphemerisNumPositions = -1;
int RungeKuttaOrder = 4;

#else // ORIGINAL_YAUNIVERSE_C

extern char MissionName[33];
extern Ephemeris_t EarthEphemeris, MoonEphemeris, SunEphemeris,
  JupiterEphemeris, SaturnEphemeris, VenusEphemeris, MarsEphemeris,
  UranusEphemeris, MercuryEphemeris, TitanEphemeris, GanymedeEphemeris, 
  IoEphemeris, EuropaEphemeris, CallistoEphemeris,
  TethysEphemeris, DioneEphemeris, RheaEphemeris;
extern int EphemerisNumPositions;
extern int RungeKuttaOrder;

#endif // ORIGINAL_YAUNIVERSE_C

//-------------------------------------------------------------------------
// Function prototypes.

int FetchEphemerisPlanet (Ephemeris_t *Ephemeris, char *Body, char *Mission);
FILE *rfopen (const char *Filename, const char *mode);

void TsStep (struct tss_t *State, ts_t h, ts_t StartTime, ts_t *Vector);
struct tss_t *TsFree (struct tss_t *State);
struct tss_t *TsAlloc (int NumBodies);
void GravAndThrust (struct tss_t *State, ts_t t, ts_t *Vector, ts_t *Rate);

#endif // INCLUDED_YAUNIVERSE_H

