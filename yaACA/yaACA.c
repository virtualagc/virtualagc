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

  Filename:	yaACA.c
  Purpose:	Apollo LM rotational hand-controller emulation module for 
  		yaAGC.
  Reference:	http://www.ibiblio.org/apollo/index.html
  Mode:		09/15/04 RSB.	Began.
  		05/14/05 RSB	Corrected website references.
		07/09/05 RSB	Completed, I hope.  The joystick stuff was
				all in place.  Now it connects to the 
				server (yaAGC) and scales and communicates
				the data to the server.
		07/10/05 RSB	Modify a lot more bits of channel 031.
		07/13/05 RSB	Fixed a possible issue of using too much
				CPU time in Win32.
		07/14/05 RSB	Modified yaw default for Mac OS X.
		07/16/05 RSB	Bumped the update interval from 7 ms.
				up to 73 ms. on MacOS X, since yaACA seems 
				to want to use all available CPU time.
		07/19/05 RSB	Fixed a bug in variable declarations
				that causes the program not to compile
				with gcc 2.x.
		09/14/05 RSB	Default sign of yaw has been reversed, 
				on Stephan's advice.
		10/29/05 RSB	Renamed local static Portnum to sPortnum
				to avoid compiler warnings in SuSE 10.0.
  		
  We use the Allegro cross-platform gaming library, since it supports 
  joysticks and since it works on Linux/FreeBSD/Win32/MacOS-X.  I don't use
  any featurs of Allegro other than the joystick function.  Using Allegro
  is really more of an experiment than anything else, and I apologize
  (in retrospect) for forcing you to install yet another library.
		
   The physical ACA in the LM is as follows:
  	Forward			pitch down
  	Back			pitch up
  	Right			roll right
  	Left			roll left
  	Clockwise		yaw right
  	Counter-clockwise	yaw left

  These are related to joystick axes as follows:
  	Axis 0		Roll (+ right, - left).
   	Axis 1		Pitch (+ up, - down).
  	Axis 2		Yaw (+ right, - left).
  I took these off of my Logitech Extreme 3D Pro.  Others may be different, in which case
  we will figure out some way to change them with command-line options.   
*/

#include <stdio.h>
#include <string.h>
#ifndef WIN32
#include <time.h>
#endif
// Inclusion of allegro.h must *follow* inclusion of other standard headers,
// and particularly must follow stdio.h.
#define ALLEGRO_USE_CONSOLE
#include <allegro.h>
#ifdef WIN32
#include <winalleg.h>
#include <windows.h>
#include <sys/time.h>
#endif

#include "yaAGC.h"
#include "agc_engine.h"

extern int num_joysticks;
extern JOYSTICK_INFO joy[];

// Time between joystick updates, in milliseconds.  Note that the AGC will process
// hand-controller inputs at 100 ms. intervals, so the update interval should be 
// less than 100 ms.; also, the update interval should not be a simple fraction
// (like 50 ms.) to avoid aliasing effects.
#ifdef __APPLE__
#define UPDATE_INTERVAL 91
#else
#define UPDATE_INTERVAL 7
#endif

// Defaults for socket interface.  Irrelevant if a different interface to
// yaAGC is used.
static char *Hostname = "localhost";
static int sPortnum = 19803;

// A copy of joy[DesiredJoystick], which we can compare against to see what has
// changed.
static int LastRoll = 1000, LastPitch = 0, LastYaw = 0;
static int *Roll, *Pitch, *Yaw;
static float RollFactor = 1.0, PitchFactor = 1.0, YawFactor = -1.0;
static int RollOffset = 0, PitchOffset = 0;
#ifdef WIN32
static int YawOffset = -128;
#else
static int YawOffset = 0;
#endif
static int First = 1;
#ifdef WIN32
static int StartupDelay = 500;
#else
static int StartupDelay = 0;
#endif
static int ServerSocket = -1;

//--------------------------------------------------------------------------
// These functions output the new orientation both to local display and to
// the server (yaAGC).  OutputTranslated() is called only by PrintJoy().
// Note that we send the angular data to the CPU whenever it changes, and
// not just when the CPU has enabled it or requested it.  This is done in
// order to give the CPU the ability to retransmit the data to other 
// potential consumers such as the AGS.  It's the CPU's responsibility
// to mask the data from itself until requested.

static void
OutputTranslated (int Channel, int Value)
{
  unsigned char Packet[4];
  int j, Sign = 0;
  if (ServerSocket == -1)
    return;
  // Convert to -57 to +57 range (with deadzone) expected by CPU.
  if (Value < 0)
    {
      Sign = 1;
      Value = -Value; 
    }
  if (Value > 127)
    Value = 127;
  if (Value < 13)
    Value = 0; 
  else 
    Value = (Value - 13) / 2;
  if (Sign)				// Make negative values 1's-complement.
    Value = (077777 & (~Value));
  FormIoPacket (Channel, Value, Packet);
  j = send (ServerSocket, Packet, 4, MSG_NOSIGNAL);
  if (j == SOCKET_ERROR && SOCKET_BROKEN)
    {
      close (ServerSocket);
      ServerSocket = -1;
      printf ("\nServer connection lost.\n");
    }
}

#define DETENT 13
static void
PrintJoy (void)
{
  int j, Changed = 0, New31;
  int ScaledRoll, ScaledPitch, ScaledYaw;
  static int Last31 = 0;
  
  // Adjust for the operating system, driver, and joystick hardware.
  ScaledRoll = *Roll * RollFactor + RollOffset;
  ScaledPitch = *Pitch * PitchFactor + PitchOffset;
  ScaledYaw = *Yaw * YawFactor + YawOffset;
  
  // Report to yaAGC.
  New31 = 077777;
  if (ScaledRoll <= -DETENT)
    New31 &= ~040040;
  else if (ScaledRoll >= DETENT)
    New31 &= ~040020;
  else if (ScaledYaw <= -DETENT)
    New31 &= ~040010;
  else if (ScaledYaw >= DETENT)
    New31 &= ~040004;
  else if (ScaledPitch <= -DETENT)
    New31 &= ~040002;
  else if (ScaledPitch >= DETENT)
    New31 &= ~040001;
  if (ServerSocket != -1 && (New31 != Last31 || First))
    {
      unsigned char Packet[8];
      Last31 = New31;
      // First, create the mask which will tell the CPU to only pay attention to
      // relevant bits of channel (031).
      FormIoPacket (0431, 040077, Packet);
      FormIoPacket (031, New31, &Packet[4]);
      // And, send it all.
      j = send (ServerSocket, Packet, 8, MSG_NOSIGNAL);
      if (j == SOCKET_ERROR && SOCKET_BROKEN)
        {
	  close (ServerSocket);
	  ServerSocket = -1;
          printf ("\nServer connection lost.\n");
	  return;
	}
    }
  if (ScaledRoll != LastRoll || First)
    {
      OutputTranslated (0170, ScaledRoll);
      Changed = 1;
    }
  if (ScaledPitch != LastPitch || First)
    {
      OutputTranslated (0166, ScaledPitch);
      Changed = 1;
    }
  if (ScaledYaw != LastYaw || First)
    {
      OutputTranslated (0167, ScaledYaw);
      Changed = 1;
    }
  // Local display.
  if (Changed)
    {
      printf ("\rRoll=%+04d\tPitch=%+04d\tYaw=%+04d", ScaledRoll, ScaledPitch, ScaledYaw);
      fflush (stdout);
      LastRoll = ScaledRoll;
      LastPitch = ScaledPitch;
      LastYaw = ScaledYaw;
      First = 0;
    }
}

//-------------------------------------------------------------------------
// Manage server connection.  I copied this right out of yaDEDA/src/main.c
// (and presumably is the same as yaDSKY/src/main.c), and changed it only
// trivially.  As long as PulseACA is called every so often (say, every 33 ms.)
// the connection to the server will be managed automatically.

static int
PulseACA (void)
{
  if (StartupDelay > 0)
    {
      StartupDelay -= UPDATE_INTERVAL;
      return (TRUE);
    }
  // Try to connect to the server (yaAGC) if not already connected.
  if (ServerSocket == -1)
    {
      ServerSocket = CallSocket (Hostname, sPortnum);
      if (ServerSocket != -1)
        printf ("\nConnection to server established on socket %d\n", ServerSocket);
      else
        StartupDelay = 1000;
    }
      
#if 0
  // #if'ing this out is a complete cheat.  It's true that the code isn't needed,
  // but that's just lucky for me.  The actual reason it's #if'ed out is that
  // on Windows (XP) it keeps losing the connection to the server and having to
  // reestablish it.  Since identical code is in yaDSKY and yaDEDA, this is 
  // very hard to understand.  But rather than figuring it out, I just bail and
  // remove the code.  :-(
  if (ServerSocket != -1)
    {
      static unsigned char Packet[4];
      static int PacketSize = 0;
      int i;
      unsigned char c;
      for (;;)
        {
	  i = recv (ServerSocket, &c, 1, MSG_NOSIGNAL);
	  if (i == -1)
	    {
	      // The condition i==-1,errno==0 occurs only on Win32, and 
	      // I'm not sure exactly what it corresponds to---I assume 
	      // means "no data" rather than error.
	      if (errno == EAGAIN || errno == 0)
	        i = 0;
	      else
	        {	
		  printf ("\nyaACA reports server error %d\n", errno);
		  close (ServerSocket);
		  ServerSocket = -1;
		  break;
	        }
	    }
	  if (i == 0)
	    break;
	  if (0 == (0xc0 & c))
	    PacketSize = 0;
	  if (PacketSize != 0 || (0xc0 & c) == 0)	      
	    { 
	      Packet[PacketSize++] = c;
	      if (PacketSize >= 4)
		{
		  PacketSize = 0;   
		  // *** Do something with the input packet. ***
		  
		}  
	    }
	}
    }
#endif // 0

  return (TRUE);    
}

//-------------------------------------------------------------------------

int
main (int argc, char *argv[]) 
{
  int DesiredJoystick = 0, i, j, Joystick, Stick, Axis, Offset;
  float Factor;
  char *s;

  printf ("Apollo Attitude Controller Assembly (ACA) emulation, version " NVER 
  	  ", built " __DATE__ "\n");
  printf ("(c)2005 Ronald S. Burkey\n");
  printf ("Refer to http://www.ibiblio.org/apollo/index.html for more information.\n");
  
  // Initialize Allegro.
Retry:
  allegro_init ();
  if (install_joystick (JOY_TYPE_AUTODETECT) || num_joysticks <= 0)
    {
      printf ("Couldn\'t find any joysticks. Retrying ...\n");
      //return (1);
#ifdef WIN32
      Sleep (5000);	    
#else // WIN32
      {
	struct timespec req, rem;
	req.tv_sec = 5;
	req.tv_nsec = 0;
	nanosleep (&req, &rem);
      }
#endif // WIN32
      allegro_exit ();
      goto Retry;
    }
    
    {
      Roll = &joy[0].stick[0].axis[0].pos;
      Pitch = &joy[0].stick[0].axis[1].pos;
#ifdef __APPLE__
      Yaw = &joy[0].stick[2].axis[0].pos;
#else
      Yaw = &joy[0].stick[1].axis[0].pos;
#endif
           
      //printf ("%d joysticks found:\n", num_joysticks);
      for (i = 0; i < num_joysticks; i++)
        {
	  int k;
	  printf ("Joystick device #%d:\n", i);
	  if (joy[i].flags & JOYFLAG_DIGITAL)
	    printf ("\tThis control provides a digital input.\n");
	  else if (joy[i].flags & JOYFLAG_ANALOGUE)
	    printf ("\tThis control provides an analog input.\n");
	  else if (joy[i].flags & JOYFLAG_CALIB_DIGITAL)
	    printf ("\tThis control will provide a digital input after calibration.\n");
	  else if (joy[i].flags & JOYFLAG_CALIB_ANALOGUE)
	    printf ("\tThis control will provide an analog input after calibration.\n"); 
	  else if (joy[i].flags & JOYFLAG_CALIBRATE)
	    printf ("\tThis control needs calibration.\n");
	  else if (joy[i].flags & JOYFLAG_SIGNED)
	    printf ("\tThis control provides signed data (i.e., -127 to 127).\n");
	  else if (joy[i].flags & JOYFLAG_UNSIGNED)
	    printf ("\tThis control provides unsigned data (i.e., 0 to 255).\n");
	  for (j = 0; j < joy[i].num_sticks; j++)
	    {
	      printf ("\tStick #%d of joystick device #%d:\n", j, i);
	      if (joy[i].stick[j].flags & JOYFLAG_DIGITAL)
		printf ("\t\tThis control provides a digital input.\n");
	      else if (joy[i].stick[j].flags & JOYFLAG_ANALOGUE)
		printf ("\t\tThis control provides an analog input.\n");
	      else if (joy[i].stick[j].flags & JOYFLAG_CALIB_DIGITAL)
		printf ("\t\tThis control will provide a digital input after calibration.\n");
	      else if (joy[i].stick[j].flags & JOYFLAG_CALIB_ANALOGUE)
		printf ("\t\tThis control will provide an analog input after calibration.\n"); 
	      else if (joy[i].stick[j].flags & JOYFLAG_CALIBRATE)
		printf ("\t\tThis control needs calibration.\n");
	      else if (joy[i].stick[j].flags & JOYFLAG_SIGNED)
		printf ("\t\tThis control provides signed data (i.e., -127 to 127).\n");
	      else if (joy[i].stick[j].flags & JOYFLAG_UNSIGNED)
		printf ("\t\tThis control provides unsigned data (i.e., 0 to 255).\n");
	      printf ("\t\tDescription = %s\n", joy[i].stick[j].name);
	      for (k = 0; k < joy[i].stick[j].num_axis; k++)
	        printf ("\t\tAxis #%d description = %s\n", k, joy[i].stick[j].axis[k].name);
	    }
	  for (j = 0; j < joy[i].num_buttons; j++)
	    {
	      printf ("\tButton %d = %s\n", j, joy[i].button[j].name);
	    }
	}
      printf ("\n");
      printf ("Note that only 3 degrees of freedom and no buttons are used by yaACA.\n");
      printf ("Right roll, upward pitch, and clockwise yaw are positive values.\n");
      printf ("Left roll, downward pitch, and counter-clockwise yaw are negative values.\n");
    }
    
  // Parse the command-line arguments.
  for (i = 1; i < argc; i++)
    {
      if (!strcmp (argv[i], "--help"))
        {
	  printf (
	    "\n"
	    "USAGE:\n"
	    "\tyaACA [OPTIONS]\n"
	    "The recognized options are:\n"
	    "--help\n"
	    "\tDisplays this message.\n"
	    "--roll=J,S,A,F,O  or  --pitch=J,S,A,F,O  or  --yaw=J,S,A,F,O\n"
	    "\tThese options allow you to configure how the roll/pitch/yaw degrees\n"
	    "\tof freedom map to the characteristics of the joystick as recognized\n"
	    "\tby the computer's operating system.  J is the joystick number (in \n"
	    "\tcase multiple joysticks are installed), S is the stick number within\n"
	    "\tthe joystick, and A is the axis within the stick.  F is a factor which\n"
	    "\tthe joystick reading is multiplied by, and O is an offset added to the\n"
	    "\tjoystick reading (after multiplication is completed).  The factor is \n"
	    "\tuseful (for example) in swapping right-to-left, back-to-front, or \n"
	    "\tclockwise-to-counter-clockwise.  The offset would be useful when the\n"
	    "\tthe joystick provides unsigned readings (0-255) rather than the desired\n"
	    "\tsigned readings (-127 to 127).  The defaults are:\n"
	    "\t\t\tRoll\t\t0,0,0,+1.0,0\n"
	    "\t\t\tPitch\t\t0,0,1,+1.0,0\n"
#ifdef __APPLE__
	    "\t\t\tYaw\t\t0,2,0,+1.0,%d\n"
#else	    
	    "\t\t\tYaw\t\t0,1,0,+1.0,%d\n"
#endif
	    "\t(By the way, the defaults work with a Logitech Extreme 3D Pro.)\n"
	    "--ip=Hostname\n"
	    "\tThe yaACA program and the yaAGC Apollo Guidance Computer simulation\n"
	    "\texist in a \"client/server\" relationship, in which the yaACA program\n"
	    "\tneeds to be aware of the IP address or symbolic name of the host\n"
	    "\tcomputer running the yaAGC program.  By default, this is \"localhost\",\n"
	    "\tmeaning that both yaACA and yaAGC are running on the same computer.\n"
            "--port=Portnumber\n"
	    "\tBy default, yaACA attempts to connect to the yaAGC program using port\n"
	    "\tnumber %d.  However, if more than one instance of yaACA is being\n"
	    "\trun, or if yaAGC has been configured to listen on different ports, then\n"
	    "\tdifferent port settings for yaACA are needed.  Note that by default,\n"
	    "\tyaAGC listens for new connections on ports 19697-19706, but that the\n"
	    "\trecommended port range when using yaAGC in the LM is 19797-19806.\n",
	    YawOffset, sPortnum
	  );
	  printf ("--delay=N\n");
	  printf ("\t\"Start-up delay\", in ms.  Defaults to %d.  What the start-up\n", StartupDelay);
	  printf ("\tdelay does is to prevent yaDEDA from attempting to communicate with\n");
	  printf ("\tyaAGS for a brief time after power-up.  This option is really only\n");
	  printf ("\tuseful in Win32, to work around a problem with race-conditions in\n");
	  printf ("\tthe start-up scripts like SimFlightProgram6.  When the race problem is\n");
	  printf ("\tfixed correctly, this option will probably no longer be useful.\n");
	  return (0);
	}
      else if (5 == sscanf (argv[i], "--roll=%d,%d,%d,%f,%d", &Joystick, &Stick, &Axis, &Factor, &Offset) ||
               5 == sscanf (argv[i], "--pitch=%d,%d,%d,%f,%d", &Joystick, &Stick, &Axis, &Factor, &Offset) ||
	       5 == sscanf (argv[i], "--yaw=%d,%d,%d,%f,%d", &Joystick, &Stick, &Axis, &Factor, &Offset) )
        {
	  if (Joystick >= 0 && Joystick < num_joysticks)
	    {
	      DesiredJoystick = Joystick;
	      if (Stick < 0 || Stick >= joy[Joystick].num_sticks)
	        {
		  printf ("\nJoystick #%d stick numbers must be >=0 and < %d.  Sorry!\n",
		          Joystick, joy[Joystick].num_sticks);
		  return (1);
		}
	      if (Axis < 0 || Axis >= joy[Joystick].stick[Stick].num_axis)
	        {
		  printf ("\nJoystick #%d, stick #%d axis numbers must be >=0 and < %d.  Sorry!\n",
		          Joystick, Stick, joy[Joystick].stick[Stick].num_axis);
		  return (1);
		}
	      if (0 == (JOYFLAG_ANALOGUE & joy[Joystick].stick[Stick].flags))
	        {
		  printf ("\nJoystick #%d, stick #%d is not analog.  Sorry!\n",
		          Joystick, Stick);
		  return (1);
		}
	      if ('r' == argv[i][2])
	        {
	          Roll = &joy[Joystick].stick[Stick].axis[Axis].pos;
		  RollFactor = Factor;
		  RollOffset = Offset;
		}
	      else if ('p' == argv[i][2])
	        {
	          Pitch = &joy[Joystick].stick[Stick].axis[Axis].pos;
		  PitchFactor = Factor;
		  PitchOffset = Offset;
		}
	      else
	        {
	          Yaw = &joy[Joystick].stick[Stick].axis[Axis].pos;
		  YawFactor = Factor;
		  YawOffset = Offset;
		}
	    }
	  else
	    {
	      printf ("\nJoystick numbers must be >= 0 and < %d.  Sorry!\n", num_joysticks);
	      return (1);
	    }  
	}
      else if (1 == sscanf (argv[i], "--delay=%d", &j))
        StartupDelay = j;
      else 
        {
	  printf ("Unknown command-line switch \"%s\".\n", argv[i]);
	  printf ("Try \"yaACA --help\".\n");
	  return (1);
	}	
    }
    
  // Set up variables for quick access to just the desired joystick, and check for minimum
  // requirements.  Note that the ACA requires no pushbuttons (there are associated toggle
  // switches, but they're not physically on the hand-control, and they are toggle switches
  // anyhow).  
  s = (char *) calibrate_joystick_name (DesiredJoystick);
  if (s != NULL)
    {
      printf ("%s\n", calibrate_joystick_name (DesiredJoystick));
      if (calibrate_joystick (DesiredJoystick))
	{
	  printf ("Joystick calibration problem.\n");
	  return (1);
	}
    }
  PrintJoy ();
    
  // Now we start polling the joystick from time to time.  The way Allegro works is to 
  // maintain an array containing info on each joystick.  This array is updated only when
  // poll_joystick is called (which you have to do explicitly).  To see what has changed,
  // we maintain a copy of the joy[] array.
  while (1)
    {
      // Sleep for a while so that this job won't monopolize CPU cycles.
#ifdef WIN32
      Sleep (UPDATE_INTERVAL);	    
#else // WIN32
      struct timespec req, rem;
      req.tv_sec = 0;
      req.tv_nsec = 1000000 * UPDATE_INTERVAL;
      nanosleep (&req, &rem);
#endif // WIN32
      poll_joystick ();				// Get joystick values.
      PrintJoy ();				// Display them locally.
      PulseACA ();				// Manage server connection.
    }

  return (0);
}

// This is needed by Allegro.
END_OF_MAIN()

