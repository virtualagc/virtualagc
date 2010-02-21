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

  Filename:	TimeStep.c
  Purpose:	Updates those portions of the system state (positions and
  		velocities of bodies) associated with linear motion.  I.e.,
		accounts for gravitational accelerations and thrust.  Later,
		drag will be included as well.
  Mode:		2004-09-23 RSB.	Began.

  How to use it
  -------------
  
  1.  Decide how many bodies will be modeled.  At a minimum, this should
      include the Earth, Moon, Sun, and a spacecraft.  The system state vector
      will contain 7 elements for each body:  3 position coordinates, 3 velocity
      components, and the body's mass. 
      
  2.  Allocate the state-vector itself:
  
  	#define NUM_BODIES 4
	ts_t Vector[NUM_BODIES * 7];
	
  3.  Allocate a structure for the TimeStep function's own state info, and 
      initialize it:
      
        struct tss_t *State;
	State = TsAlloc (NUM_BODIES);
	
  4.  Initialize the state vector.  Elements 0,1,2 are the initial x,y,z 
      coordinates of body 0, elements 3,4,5 are the initial x,y,z velocity
      components of body 0, element 6 is the mass of body 0, elements
      7,8,9 are the initial x,y,z coordinates of body 1, and so on.  The MKS
      system of units is used for position and velocity, and an inertial 
      reference system is assumed, such as a non-rotating coordinate system
      with origin at the solar system's center of mass.  NOTE:  Masses are 
      NOT stored here in kg, but are multiplied by G, the gravitational 
      constant.  (I.e., mass in kg times G in MKS units.)  This is done for
      planetary bodies because GM is known with much greater precision than
      G and M individually, and is carried over to spacecraft for consistency.
      
  5.  Compute as many time steps as you like.  The system state vector will
      be updated each time TsStep() is executed:
  
	for (t = 0; t < something; t += DeltaT)
	  {
	    ... Adjust State->Thrust[].  The elements corresponding to the
	        coordinates (0,1,2, 7,8,9, etc.) are zero.  The elements
		corresponding to velocities (3,4,5, 10,11,12, etc.) contain
		forces (in Newtons), and the elements corresponding to mass
		(6, 13, etc.) contain the rates of change (kg/s) of the masses
		of the bodies, to account for propellant loss.  Very likely
		a smaller time-step DeltaT will be needed while thrust is 
		applied than while only gravitational forces are active ...
	    TsStep (State, DeltaT, t, Vector);
	    ... Do something with this info ...
	  }
	  
  6.  Deallocate the storage created for internal use of TsStep:
  
        State = TsFree (State);
*/

#include "yaUniverse.h"
#include "stdlib.h"
#include "math.h"

//-----------------------------------------------------------------------------
// Free buffers allocated for the integration.

struct tss_t *
TsFree (struct tss_t *State)
{
  if (State == NULL)
    return (NULL);
  if (State->Thrust != NULL)
    free (State->Thrust);
  if (State->k4 != NULL)
    free (State->k4);
  if (State->k3 != NULL)
    free (State->k3);
  if (State->k2 != NULL)
    free (State->k2);
  if (State->k1 != NULL)
    free (State->k1);
  if (State->TempV != NULL)
    free (State->TempV);
  if (State->Rate != NULL)
    free (State->Rate);
  free (State);
  return (NULL);
}

//-----------------------------------------------------------------------------
// Create buffers for integration.
//	NumBodies	Number of astronomical bodies and spacecraft tracked.

struct tss_t *
TsAlloc (int NumBodies)
{
  int Dim;
  struct tss_t *State;
  Dim = 7 * NumBodies;
  State = (struct tss_t *) malloc (sizeof (struct tss_t));
  if (State == NULL)
    return (NULL);
  State->NumBodies = NumBodies;
  State->Dim = Dim;
  // Allocate the arrays we'll need.
  State->Thrust = (ts_t *) calloc (Dim, sizeof (ts_t));
  if (State->Thrust == NULL)
    goto Error;
  State->k4 = (ts_t *) calloc (Dim, sizeof (ts_t));
  if (State->k4 == NULL)
    goto Error;
  State->k3 = (ts_t *) calloc (Dim, sizeof (ts_t));
  if (State->k3 == NULL)
    goto Error;
  State->k2 = (ts_t *) calloc (Dim, sizeof (ts_t));
  if (State->k2 == NULL)
    goto Error;
  State->k1 = (ts_t *) calloc (Dim, sizeof (ts_t));
  if (State->k1 == NULL)
    goto Error;
  State->TempV = (ts_t *) calloc (Dim, sizeof (ts_t));
  if (State->TempV == NULL)
    goto Error;
  State->Rate = (ts_t *) calloc (Dim, sizeof (ts_t));
  if (State->Rate == NULL)
    goto Error;
  return (State);
Error:
  TsFree (State);
  return (NULL);
}

//-----------------------------------------------------------------------------
// Do a 4th-order Runge-Kutta integration.  I took the formula from 
// mathworld.wolfram.com.  
//	State		Previously set up by TsAlloc, and destroyed after 
//			all timesteps are completed by TsFree;
//	h		The timestep.
//	StartTime	The starting time of the integration step.
//	Vector		On input, the value at time StartTime.
//			On output, the value at time StartTime+h.
//
// The problem we're trying to solve is this:
//	d/dt Vector = Function(Time,Vector)
// Vector is an array of values, of dimension Dim.  Function, therefore,
// is a function that takes an array of values and returns a vector of 
// rates of change.  Even though this directly represents only an array of 
// first-order differential equations, more interesting higher-order equations
// can be reduced to this form.

void
TsStep (struct tss_t *State, ts_t h, ts_t StartTime, ts_t *Vector)
{
  int i;

  if (RungeKuttaOrder == 4)
    {
      // Here is a naive use of the 4th-order Runge-Kutta method.  

      // Compute k1.
      GravAndThrust (State, StartTime, Vector, State->Rate);
      for (i = 0; i < State->Dim; i++)
	State->k1[i] = h * State->Rate[i];

      // Compute k2.
      for (i = 0; i < State->Dim; i++)
	State->TempV[i] = Vector[i] + State->k1[i] / 2;
      GravAndThrust (State, StartTime + h / 2, State->TempV, State->Rate);
      for (i = 0; i < State->Dim; i++)
	State->k2[i] = h * State->Rate[i];

      // Compute k3.
      for (i = 0; i < State->Dim; i++)
	State->TempV[i] = Vector[i] + State->k2[i] / 2;
      GravAndThrust (State, StartTime + h / 2, State->TempV, State->Rate);
      for (i = 0; i < State->Dim; i++)
	State->k3[i] = h * State->Rate[i];

      // Compute k4.
      for (i = 0; i < State->Dim; i++)
	State->TempV[i] = Vector[i] + State->k3[i];
      GravAndThrust (State, StartTime + h, State->TempV, State->Rate);
      for (i = 0; i < State->Dim; i++)
	State-> k4[i] = h * State->Rate[i];

      // Estimate the output.
      for (i = 0; i < State->Dim; i++)
	Vector[i] += (State->k1[i] + State->k4[i]) / 6 + (State->k2[i] + State->k3[i]) / 3;
    }

  else if (RungeKuttaOrder == 2)
    {
      // Runge-Kutta 2nd-order method.

      // Compute k1.
      GravAndThrust (State, StartTime, Vector, State->Rate);
      for (i = 0; i < State->Dim; i++)
	State->k1[i] = h * State->Rate[i];

      // Compute k2.
      for (i = 0; i < State->Dim; i++)
	State->TempV[i] = Vector[i] + State->k1[i] / 2;
      GravAndThrust (State, StartTime + h / 2, State->TempV, State->Rate);
      for (i = 0; i < State->Dim; i++)
	State->k2[i] = h * State->Rate[i];

      // Estimate the output.
      for (i = 0; i < State->Dim; i++)
	Vector[i] += State->k2[i];
    }

}

//------------------------------------------------------------------------------
// Here is a special-purpose rate-computation function, in which a Vector
// represents a collection of bodies each having 7 degrees of freedom (3 position
// 3 velocity, and mass) each .  In other words, Dim=7*NumBodies.  Positions 7n 
// through 7n+6 of vectors are as follows:
//
//	x  = x-position of center of mass of body n
//	 n
//
//	y  = y-position of center of mass of body n
//	 n
//
//	z  = z-position of center of mass of body n
//	 n
//	.
//	x  = x-velocity of center of mass of body n
//	 n
//	.
//	y  = y-velocity of center of mass of body n
//	 n
//	.
//	z  = z-velocity of center of mass of body n
//	 n
//
//	M  = Mass of body n
//	 n
// The masses usually do not change, but may change as propellant is expelled.
// The rates of change are computed from the gravitational attractions of the bodies,
// which is a function only of position, and from thrust, which is a function only
// of time.  For the System->Thrust vector, the
// first three values of each group of 7 are zero; the next three are the force
// due to the thrust; the 7th is the rate of change of mass.  This model allows
// the calling program to worry about how the force is related to propellant usage,
// exhaustion of propellant, and so on, separation of thrust and torque, etc.,
// without GravAndThrust having to know anything about it. Thrust is assumed constant 
// throughout any integration time-step, so the calling program may need to adjust 
// the time-step appropriately.

void
GravAndThrust (struct tss_t *State, ts_t t, ts_t *Vector, ts_t *Rate)
{
#define xi bodyi[0]
#define yi bodyi[1]
#define zi bodyi[2]
#define vxi bodyi[3]
#define vyi bodyi[4]
#define vzi bodyi[5]
#define gmi bodyi[6]
#define xj bodyj[0]
#define yj bodyj[1]
#define zj bodyj[2]
#define vxj bodyj[3]
#define vyj bodyj[4]
#define vzj bodyj[5]
#define gmj bodyj[6]
#define axi ratei[3]
#define ayi ratei[4]
#define azi ratei[5]
#define axj ratej[3]
#define ayj ratej[4]
#define azj ratej[5]
  int i, j;
  ts_t *bodyi, *bodyj, *ratei, *ratej, *thrusti;

  // First, initialize Rate in a reasonable way.
  bodyi = Vector;
  ratei = Rate;
  for (i = 0; i < State->NumBodies; i++)
    {
      *ratei++ = vxi;		// rate of change of x
      *ratei++ = vyi;		// rate of change of y
      *ratei++ = vzi;		// rate of change of z
      *ratei++ = 0;		// x acceleration, to be computed below.
      *ratei++ = 0;		// y acceleration, to be computed below.
      *ratei++ = 0; 		// z acceleration, to be computed below.
      *ratei++ = 0;		// change of mass, usually 0.
      bodyi += 7;
    }

  // Now compute the gravitational attraction of each body for any other body.
  // We save ourselves a little work by noting that the force on body n1 due to
  // body n2 is the same (but opposite in direction) to that on body n2 due to
  // body n1.  Nor does any body attract itself.
  for (i = 1; i < State->NumBodies; i++)
    {
      //if (i == 2)
      //  bodyi = &SunBuffer[0][0];
      //else
      bodyi = &Vector[7 * i];
      ratei = &Rate[7 * i];
      for (j = 0; j < i; j++)
        {
          ts_t dx, dy, dz, r, a;
	  bodyj = &Vector[7 * j];
	  ratej = &Rate[7 * j];
	  dx = xi - xj;
	  dy = yi - yj;
	  dz = zi - zj;
	  r = sqrt (dx * dx + dy * dy + dz * dz);
	  a = 1 / (r * r * r);
	  axi -= a * gmj * dx;
	  axj += a * gmi * dx;
	  ayi -= a * gmj * dy;
	  ayj += a * gmi * dy;
	  azi -= a * gmj * dz;
	  azj += a * gmi * dz;
        }
    }
    
  // Now compute thrust.
  if (State->Thrust != NULL)
    {
      for (i = 0; i < State->NumBodies; i++)
        {
          bodyi = &Vector[7 * i];
          ratei = &Rate[7 * i];
	  thrusti = &State->Thrust[7 * i];
	  // Recall that planetary masses are kept as GM rather than simply M,
	  // since GM is known with much greater accuracy than G or M 
	  // individually.  Since spacecraft masses are stored in the same 
	  // memory structures, they are also stored as GM, and must therefore
	  // be divided by G to get them in kg.
	  axi += thrusti[3] * G / gmi;
	  ayi += thrusti[4] * G / gmi;
	  azi += thrusti[5] * G / gmi;
	  ratei[6] = thrusti[6];
	}
    }

#undef xi
#undef yi
#undef zi
#undef vxi
#undef vyi
#undef vzi
#undef gmi
#undef xj
#undef yj
#undef zj
#undef vxj
#undef vyj
#undef vzj
#undef gmj
#undef axi
#undef ayi
#undef azi
#undef axj
#undef ayj
#undef azj
}


