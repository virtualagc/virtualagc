/*
  Copyright 2004,2005,2009 Ronald S. Burkey <info@sandroid.org>
  
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
		03/28/09 RSB	Now displays the pitch/roll/yaw in AGC-scaled
				values as well as the joystick-driver values.
				I never noticed it before, but on Windows,
				yaACA has no console window at all.  I presume
				that this is because Allegro somehow takes over
				the stdin and stdout, and something has to be
				done to prevent that, as I saw a similar effect
				in SDL and only fixed it with great difficulty.
				However, since yaACA3 is obsoleting yaACA even
				as I write this, it seems pointless to waste
				further effort fixing it.
		04/06/09 RSB	Added auto-saving to command-line parameters
				to a configuration file for automatic reload
				on subsequent runs.
		04/08/09 RSB	Okay, I now have the stdout in Windows.  There
				was a gcc command-line switch that was getting
				rid of it.  However, before that I changed
				all the printf statements in this program to 
				fprintf in the hopes of capturing the output
				some other way.  Added the fix for the weird
				Windows errno==9 after recv.
  		
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
  	Axis 2		Yaw (- right, + left).
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
//#ifdef WIN32
//#define ALLEGRO_NO_MAGIC_MAIN
//#endif // WIN32
#define ALLEGRO_USE_CONSOLE
#include <allegro.h>
#ifdef WIN32
#include <winalleg.h>
#include <windows.h>
#include <sys/time.h>
#endif

#include "yaAGC.h"
#include "agc_engine.h"

FILE *Out;

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
static float RollFactor, PitchFactor, YawFactor;
static int RollOffset, PitchOffset, YawOffset;
static int RollStick, PitchStick, YawStick;
static int RollAxis, PitchAxis, YawAxis;
static int Controller;
static int First = 1;
#ifdef WIN32
static int StartupDelay = 500;
#else
static int StartupDelay = 0;
#endif
static int ServerSocket = -1;

// Sets parameters to all defaults.  These parameters are
// for my Logitech 3D Extreme.
void
DefaultParameters (void)
{
  Controller = 0;
  RollStick = 0;
  RollAxis = 0;
  PitchStick = 0;
  PitchAxis = 1;
#ifdef __APPLE__
  YawStick = 2;
#else
  YawStick = 1;
#endif
  YawAxis = 0;
  RollFactor = 1.0;
  PitchFactor = 1.0;
  YawFactor = -1.0;
  RollOffset = 0;
  PitchOffset = 0;
#ifdef WIN32
  YawOffset = -128;
#else
  YawOffset = 0;
#endif
  Roll = &joy[Controller].stick[RollStick].axis[RollAxis].pos;
  Pitch = &joy[Controller].stick[PitchStick].axis[PitchAxis].pos;
  Yaw = &joy[Controller].stick[YawStick].axis[YawAxis].pos;
}


// Gets parameters from a cfg file if available, from defaults otherwise.
static int CfgExisted = 0;

void
GetParameters (int ControllerNumber)
{
  char Filename[33];
  char s[81];
  FILE *File;
  int iValue;
  float Factor;
  
  DefaultParameters ();
  
  sprintf (Filename, "yaACA-%d.cfg", ControllerNumber);
  File = fopen (Filename, "r");
  if (File != NULL)
    {
      CfgExisted = 1;
      while (NULL != fgets (s, sizeof (s), File))
        {
	  if (1 == sscanf (s, "Roll.Stick=%d", &iValue))
	    RollStick = iValue;
	  else if (1 == sscanf (s, "Roll.Axis=%d", &iValue))
	    RollAxis = iValue;
	  else if (1 == sscanf (s, "Roll.Offset=%d", &iValue))
	    RollOffset = iValue;
	  else if (1 == sscanf (s, "Roll.Factor=%f", &Factor))
	    RollFactor = Factor;
	  else if (1 == sscanf (s, "Pitch.Stick=%d", &iValue))
	    PitchStick = iValue;
	  else if (1 == sscanf (s, "Pitch.Axis=%d", &iValue))
	    PitchAxis = iValue;
	  else if (1 == sscanf (s, "Pitch.Offset=%d", &iValue))
	    PitchOffset = iValue;
	  else if (1 == sscanf (s, "Pitch.Factor=%f", &Factor))
	    PitchFactor = Factor;
	  else if (1 == sscanf (s, "Yaw.Stick=%d", &iValue))
	    YawStick = iValue;
	  else if (1 == sscanf (s, "Yaw.Axis=%d", &iValue))
	    YawAxis = iValue;
	  else if (1 == sscanf (s, "Yaw.Offset=%d", &iValue))
	    YawOffset = iValue;
	  else if (1 == sscanf (s, "Yaw.Factor=%f", &Factor))
	    YawFactor = Factor;
	}
      fclose (File);
    }
    
  Roll = &joy[Controller].stick[RollStick].axis[RollAxis].pos;
  Pitch = &joy[Controller].stick[PitchStick].axis[PitchAxis].pos;
  Yaw = &joy[Controller].stick[YawStick].axis[YawAxis].pos;
}


// Writes parameters to a cfg file.
void
WriteParameters (int ControllerNumber)
{
  char Filename[33];
  FILE *File;
  sprintf (Filename, "yaACA-%d.cfg", ControllerNumber);
  File = fopen (Filename, "w");
  if (File != NULL)
    {
      fprintf (File, "Roll.Stick=%d\n", RollStick);
      fprintf (File, "Roll.Axis=%d\n", RollAxis);
      fprintf (File, "Roll.Offset=%d\n", RollOffset);
      fprintf (File, "Roll.Factor=%f\n", RollFactor);
      fprintf (File, "Pitch.Stick=%d\n", PitchStick);
      fprintf (File, "Pitch.Axis=%d\n", PitchAxis);
      fprintf (File, "Pitch.Offset=%d\n", PitchOffset);
      fprintf (File, "Pitch.Factor=%f\n", PitchFactor);
      fprintf (File, "Yaw.Stick=%d\n", YawStick);
      fprintf (File, "Yaw.Axis=%d\n", YawAxis);
      fprintf (File, "Yaw.Offset=%d\n", YawOffset);
      fprintf (File, "Yaw.Factor=%f\n", YawFactor);
      fclose (File);
    }
  else
    {
      fprintf (stdout, "Cannot create file %s, Configuration not saved.\n", Filename);
    }
}

//--------------------------------------------------------------------------
// These functions output the new orientation both to local display and to
// the server (yaAGC).  OutputTranslated() is called only by PrintJoy().
// Note that we send the angular data to the CPU whenever it changes, and
// not just when the CPU has enabled it or requested it.  This is done in
// order to give the CPU the ability to retransmit the data to other 
// potential consumers such as the AGS.  It's the CPU's responsibility
// to mask the data from itself until requested.  Returns the joystick
// value as translated to the AGC's desired range.

static int
OutputTranslated (int Channel, int Value)
{
  int TranslatedValue;
  unsigned char Packet[4];
  int j, Sign = 0;
  
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
  TranslatedValue = Sign ? -Value : Value;
  
  // Transmit it.
  if (ServerSocket != -1)
    {
      if (Sign)				// Make negative values 1's-complement.
	Value = (077777 & (~Value));
      FormIoPacket (Channel, Value, Packet);
      j = send (ServerSocket, Packet, 4, MSG_NOSIGNAL);
      if (j == SOCKET_ERROR && SOCKET_BROKEN)
	{
	  close (ServerSocket);
	  ServerSocket = -1;
	  fprintf (Out, "\nServer connection lost.\n");
	}
    }
    
  return (TranslatedValue);
}

#define DETENT 13
static void
PrintJoy (void)
{
  int j, Changed = 0, New31;
  int ScaledRoll, ScaledPitch, ScaledYaw;
  static int TranslatedRoll = 0, TranslatedPitch = 0, TranslatedYaw = 0;
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
  if (ScaledYaw <= -DETENT)
    New31 &= ~040010;
  else if (ScaledYaw >= DETENT)
    New31 &= ~040004;
  if (ScaledPitch <= -DETENT)
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
          fprintf (Out, "\nServer connection lost.\n");
	  return;
	}
    }
  if (ScaledRoll != LastRoll || First)
    {
      TranslatedRoll = OutputTranslated (0170, ScaledRoll);
      Changed = 1;
    }
  if (ScaledPitch != LastPitch || First)
    {
      TranslatedPitch = OutputTranslated (0166, ScaledPitch);
      Changed = 1;
    }
  if (ScaledYaw != LastYaw || First)
    {
      TranslatedYaw = OutputTranslated (0167, ScaledYaw);
      Changed = 1;
    }
  // Local display.
  if (Changed)
    {
      fprintf (Out, "\rRoll=%+04d (%+03d)   Pitch=%+04d (%+03d)   Yaw=%+04d (%+03d)", 
      	      ScaledRoll, TranslatedRoll,
	      ScaledPitch, TranslatedPitch,
	      ScaledYaw, TranslatedYaw);
      fflush (Out);
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
        fprintf (Out, "\nConnection to server established on socket %d\n", ServerSocket);
      else
        StartupDelay = 1000;
    }
      
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
	      if (errno == EAGAIN || errno == 0 || errno == 9)
	        i = 0;
	      else
	        {	
		  fprintf (Out, "\nyaACA reports server error %d\n", errno);
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

  return (TRUE);    
}

//-------------------------------------------------------------------------

int
main (int argc, char *argv[]) 
{
  int DesiredJoystick = 0, i, j, Joystick, Stick, Axis, Offset, Changed = 0;
  float Factor;
  char *s;

#ifdef WIN32
  Out = stdout; // fopen ("yaACA.txt", "w");
#else
  Out = stdout;
#endif

  fprintf (Out, "Apollo Attitude Controller Assembly (ACA) emulation, version " NVER 
  	  ", built " __DATE__ "\n");
  fprintf (Out, "(c)2005,2009 Ronald S. Burkey\n");
  fprintf (Out, "Refer to http://www.ibiblio.org/apollo/index.html for more information.\n");
  fflush (Out);
  
  // Initialize Allegro.
Retry:
  allegro_init ();
  if (install_joystick (JOY_TYPE_AUTODETECT) || num_joysticks <= 0)
    {
      fprintf (Out, "Couldn\'t find any joysticks. Retrying ...\n");
      fflush (Out);
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
      GetParameters (Controller);
           
      //fprintf (Out, "%d joysticks found:\n", num_joysticks);
      for (i = 0; i < num_joysticks; i++)
        {
	  int k;
	  fprintf (Out, "Joystick device #%d:\n", i);
	  if (joy[i].flags & JOYFLAG_DIGITAL)
	    fprintf (Out, "\tThis control provides a digital input.\n");
	  else if (joy[i].flags & JOYFLAG_ANALOGUE)
	    fprintf (Out, "\tThis control provides an analog input.\n");
	  else if (joy[i].flags & JOYFLAG_CALIB_DIGITAL)
	    fprintf (Out, "\tThis control will provide a digital input after calibration.\n");
	  else if (joy[i].flags & JOYFLAG_CALIB_ANALOGUE)
	    fprintf (Out, "\tThis control will provide an analog input after calibration.\n"); 
	  else if (joy[i].flags & JOYFLAG_CALIBRATE)
	    fprintf (Out, "\tThis control needs calibration.\n");
	  else if (joy[i].flags & JOYFLAG_SIGNED)
	    fprintf (Out, "\tThis control provides signed data (i.e., -127 to 127).\n");
	  else if (joy[i].flags & JOYFLAG_UNSIGNED)
	    fprintf (Out, "\tThis control provides unsigned data (i.e., 0 to 255).\n");
	  for (j = 0; j < joy[i].num_sticks; j++)
	    {
	      fprintf (Out, "\tStick #%d of joystick device #%d:\n", j, i);
	      if (joy[i].stick[j].flags & JOYFLAG_DIGITAL)
		fprintf (Out, "\t\tThis control provides a digital input.\n");
	      else if (joy[i].stick[j].flags & JOYFLAG_ANALOGUE)
		fprintf (Out, "\t\tThis control provides an analog input.\n");
	      else if (joy[i].stick[j].flags & JOYFLAG_CALIB_DIGITAL)
		fprintf (Out, "\t\tThis control will provide a digital input after calibration.\n");
	      else if (joy[i].stick[j].flags & JOYFLAG_CALIB_ANALOGUE)
		fprintf (Out, "\t\tThis control will provide an analog input after calibration.\n"); 
	      else if (joy[i].stick[j].flags & JOYFLAG_CALIBRATE)
		fprintf (Out, "\t\tThis control needs calibration.\n");
	      else if (joy[i].stick[j].flags & JOYFLAG_SIGNED)
		fprintf (Out, "\t\tThis control provides signed data (i.e., -127 to 127).\n");
	      else if (joy[i].stick[j].flags & JOYFLAG_UNSIGNED)
		fprintf (Out, "\t\tThis control provides unsigned data (i.e., 0 to 255).\n");
	      fprintf (Out, "\t\tDescription = %s\n", joy[i].stick[j].name);
	      for (k = 0; k < joy[i].stick[j].num_axis; k++)
	        fprintf (Out, "\t\tAxis #%d description = %s\n", k, joy[i].stick[j].axis[k].name);
	    }
	  for (j = 0; j < joy[i].num_buttons; j++)
	    {
	      fprintf (Out, "\tButton %d = %s\n", j, joy[i].button[j].name);
	    }
	}
      fprintf (Out, "\n");
      fprintf (Out, "Note that only 3 degrees of freedom and no buttons are used by yaACA.\n");
      fprintf (Out, "Right roll, upward pitch, and clockwise yaw are positive values.\n");
      fprintf (Out, "Left roll, downward pitch, and counter-clockwise yaw are negative values.\n");
    }
    
  // Parse the command-line arguments.
  for (i = 1; i < argc; i++)
    {
      if (!strcmp (argv[i], "--help"))
        {
	  fprintf (Out, 
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
	    "\tAlthough it would appear that you can select a different joystick\n"
	    "\tcontroller (the first field) for each of the pitch/roll/yaw axes,\n"
	    "\tyou really cannot, so please do not do so.  For versions 20090406\n"
	    "\tand later, your selections are automatically stored in a configuration\n"
	    "\tfile called yaACA-N.cfg, where N is the joystick controller number,\n"
	    "\tand become the new defaults the next time the program is run.  In\n"
	    "\tother words, once you've determined the appropriate command-line\n"
	    "\tsettings for --roll, --pitch, and --yaw, you don't need to use the\n"
	    "\tcommand-line parameters again.  An exception is if the joystick\n"
	    "\tcontroller-number is non-zero.  If so, you will need to use at least\n"
	    "\tone of these command-line switches every time, or else the saved\n"
	    "\tsettings for controller 0 will be used.\n"
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
	  fprintf (Out, "--delay=N\n");
	  fprintf (Out, "\t\"Start-up delay\", in ms.  Defaults to %d.  What the start-up\n", StartupDelay);
	  fprintf (Out, "\tdelay does is to prevent yaACA from attempting to communicate with\n");
	  fprintf (Out, "\tyaAGC for a brief time after power-up.  This option is really only\n");
	  fprintf (Out, "\tuseful in Win32, to work around a problem with race-conditions in\n");
	  fprintf (Out, "\tat start-up time.\n");
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
		  fprintf (Out, "\nJoystick #%d stick numbers must be >=0 and < %d.  Sorry!\n",
		          Joystick, joy[Joystick].num_sticks);
		  return (1);
		}
	      if (Axis < 0 || Axis >= joy[Joystick].stick[Stick].num_axis)
	        {
		  fprintf (Out, "\nJoystick #%d, stick #%d axis numbers must be >=0 and < %d.  Sorry!\n",
		          Joystick, Stick, joy[Joystick].stick[Stick].num_axis);
		  return (1);
		}
	      if (0 == (JOYFLAG_ANALOGUE & joy[Joystick].stick[Stick].flags))
	        {
		  fprintf (Out, "\nJoystick #%d, stick #%d is not analog.  Sorry!\n",
		          Joystick, Stick);
		  return (1);
		}
	      if ('r' == argv[i][2])
	        {
	          Roll = &joy[Joystick].stick[Stick].axis[Axis].pos;
		  RollFactor = Factor;
		  RollOffset = Offset;
		  Controller = Joystick;
		  RollStick = Stick;
		  RollAxis = Axis;
		  Changed = 1;
		}
	      else if ('p' == argv[i][2])
	        {
	          Pitch = &joy[Joystick].stick[Stick].axis[Axis].pos;
		  PitchFactor = Factor;
		  PitchOffset = Offset;
		  Controller = Joystick;
		  PitchStick = Stick;
		  PitchAxis = Axis;
		  Changed = 1;
		}
	      else
	        {
	          Yaw = &joy[Joystick].stick[Stick].axis[Axis].pos;
		  YawFactor = Factor;
		  YawOffset = Offset;
		  Controller = Joystick;
		  YawStick = Stick;
		  YawAxis = Axis;
		  Changed = 1;
		}
	    }
	  else
	    {
	      fprintf (Out, "\nJoystick numbers must be >= 0 and < %d.  Sorry!\n", num_joysticks);
	      return (1);
	    }  
	}
      else if (1 == sscanf (argv[i], "--delay=%d", &j))
        StartupDelay = j;
      else 
        {
	  fprintf (Out, "Unknown command-line switch \"%s\".\n", argv[i]);
	  fprintf (Out, "Try \"yaACA --help\".\n");
	  return (1);
	}	
    }
  if (Changed || !CfgExisted)
    WriteParameters (Controller);
    
  // Set up variables for quick access to just the desired joystick, and check for minimum
  // requirements.  Note that the ACA requires no pushbuttons (there are associated toggle
  // switches, but they're not physically on the hand-control, and they are toggle switches
  // anyhow).  
  s = (char *) calibrate_joystick_name (DesiredJoystick);
  if (s != NULL)
    {
      fprintf (Out, "%s\n", calibrate_joystick_name (DesiredJoystick));
      if (calibrate_joystick (DesiredJoystick))
	{
	  fprintf (Out, "Joystick calibration problem.\n");
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
#if 0      
      {
        static int Count = 0;
        fprintf (Out, "*");
	Count++;
	if (Count >= 32)
	  {
	    Count = 0;
	    fflush (Out);
	  }
      }
#endif      
    }

  return (0);
}

// This is needed by Allegro.
END_OF_MAIN()


