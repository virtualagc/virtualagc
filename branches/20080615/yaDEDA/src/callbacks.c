/*
  Copyright 2005 Ronald S. Burkey <info@sandroid.org>
  
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
  
  Filename:	callbacks.c
  Purpose:	Provides callbacks for the yaDEDA program.
  Mods:		05/30/05 RSB	I think that all of the logic is in place for 
  				basic operations, except that data isn't yet
				output to the AEA on demand.
		05/31/05 RSB	Hmmm ....  Maybe the final step.
		06/01/05 RSB	Some Win32 mods.
		06/05/05 RSB	Corrected polarity of discretes.
				Fixed problem that hitting READOUT after
				ENTR was treated as being okay.  Corrected
				bit positioning in the input-discrete words.
		06/07/05 RSB	Bit positioniong in DEDA shift register
				fixed.
		07/13/05 RSB	Data timeouts increased from 0.1 seconds to 
				1 second.  (I was seeing some anomalous
				activity in terms of garbage data and
				frozen-up DEDAs that might be due to 
				timeouts.  Didn't work, though.)
*/

#ifdef HAVE_CONFIG_H
#  include <config.h>
#endif

#include <gtk/gtk.h>

#include "callbacks.h"
#include "interface.h"
#include "support.h"

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include <errno.h>

#ifdef WIN32
#include <windows.h>
#include <sys/time.h>
#define LB "\r\n"
#else
#include <time.h>
#include <sys/times.h>
#define LB ""
#endif

#include "yaAGC.h"
#include "agc_engine.h"

//-----------------------------------------------------------------------------------
#ifdef WIN32
struct tms {
  clock_t tms_utime;  /* user time */
  clock_t tms_stime;  /* system time */
  clock_t tms_cutime; /* user time of children */
  clock_t tms_cstime; /* system time of children */
};
clock_t times (struct tms *p)
{
  return (GetTickCount ());
}
#define _SC_CLK_TCK (1000)
#define sysconf(x) (x)
#endif // WIN32

//--------------------------------------------------------------------------------
// As described on the developer page (http://www.ibiblio.org/apollo/developer.html),
// the DEDA actually has a little intelligence.  Keystrokes are not instantly sent
// to the AEA.  Instead, they are buffered, and correct keystroke sequences must
// be made.  Errors are detected locally within the DEDA (which controls the OPR ERR
// indicator), and only complete command sequences are eligible for transfer to 
// the AEA, which only happens when a DEDA Shift Out discrete appears. 
// It's also necessary to timeout on transmitted data if, for example, the AEA
// goes away and stops sending out DEDA Shift In discretes.  We timeout if those
// stop in the middle of a packet, in order to keep the DEDA from freezing up
// unpleasantly.

static int OprErr = 0;			// Set when the OPR ERR indicator is lit.
static unsigned char InPacket[9];	// Buffer for incoming data.
static int NumInPacket = 0;		// Count for the buffer.
static clock_t WhenInPacket = 0;	// Timestamp of last received incoming data.
#define WHEN_IN_EXPIRED (sysconf(_SC_CLK_TCK) / 1)	// Length of timeout for incoming data.
static unsigned char OutPacket[9];	// Buffer for outgoing data.
static int NumOutPacket = 10;		// Count for the buffer.  10 if CLR not pressed.
static clock_t WhenOutPacket = 0;	// Timestamp of last outgoing data.
#define WHEN_OUT_EXPIRED (sysconf(_SC_CLK_TCK) / 1)	// Length of timeout for outgoing data.
static int ShiftingOut = 0;		// We set this then it's okay to shift out data.
static unsigned char ShiftBuffer[9];	// Buffer for shifting outgoing data.
static int ShiftBufferSize, ShiftBufferPtr;
static int LastReadout = 0;		// 1 if previous operations were READOUT or HOLD.

//--------------------------------------------------------------------------------
// This funky little business here is for the purpose of adding the prefix "h"
// to the graphics filenames when the HalfSize option is activated.
void
my_gtk_image_set_from_file (GtkImage *Image, const char *Filename)
{
  extern int HalfSize;
  if (!HalfSize)
    gtk_image_set_from_file (Image, Filename);
  else
    {
      char *s, *ss;
      s = malloc (2 + strlen (Filename));
      if (s != NULL)
        {
	  // I am aided in finding the start of the filename by the knowledge
	  // that the filenames end in .xpm and that the names contain only
	  // alphanumerics and dashes.
	  for (ss = (char *) Filename + strlen (Filename) - 1; ss >= Filename; ss--)
	    if (!isalnum (*ss) && *ss != '.' && *ss != '-')
	      break;
	  ss++;
	  strncpy (s, Filename, ss - Filename);
	  s[ss - Filename] = 0;
	  strcat (s, "h");
	  strcat (s, ss);
	  //printf ("*** %s ***\n", s);
          gtk_image_set_from_file (Image, s);
          free (s);
        }
    }
}
#define gtk_image_set_from_file(i,f) my_gtk_image_set_from_file (i, f)

//--------------------------------------------------------------------------------
// Function for identifying all widgets used for displaying stuff.  Some widget
// (ANY widget on the screen) is passed as input.

static int WidgetsLocated = 0;
static GtkImage *IndicatorOprErr, *Sign;
static GtkImage *DigitTop1, *DigitTop2, *DigitTop3;
static GtkImage *DigitBottom1, *DigitBottom2, *DigitBottom3, *DigitBottom4, *DigitBottom5;

void
LocateWidgets (GtkWidget *widget)
{
  if (WidgetsLocated)
    return;
  WidgetsLocated = 1;  
  IndicatorOprErr = GTK_IMAGE (lookup_widget (widget, "IndicatorOprErr"));
  Sign = GTK_IMAGE (lookup_widget (widget, "Sign"));
  DigitTop1 = GTK_IMAGE (lookup_widget (widget, "DigitTop1"));
  DigitTop2 = GTK_IMAGE (lookup_widget (widget, "DigitTop2"));
  DigitTop3 = GTK_IMAGE (lookup_widget (widget, "DigitTop3"));
  DigitBottom1 = GTK_IMAGE (lookup_widget (widget, "DigitBottom1"));
  DigitBottom2 = GTK_IMAGE (lookup_widget (widget, "DigitBottom2"));
  DigitBottom3 = GTK_IMAGE (lookup_widget (widget, "DigitBottom3"));
  DigitBottom4 = GTK_IMAGE (lookup_widget (widget, "DigitBottom4"));
  DigitBottom5 = GTK_IMAGE (lookup_widget (widget, "DigitBottom5"));
}

//--------------------------------------------------------------------------------
// A nice little function to output a packet to yaAGS.

static void
OutputData (int Type, int Data)
{
  unsigned char Packet[4];
  extern int ServerSocket;
  int j;
  if (ServerSocket != -1)
    {
      FormIoPacketAGS (Type, Data, Packet);
      j = send (ServerSocket, Packet, 4, MSG_NOSIGNAL);
      if (j == SOCKET_ERROR && SOCKET_BROKEN)
        {
	  close (ServerSocket);
	  ServerSocket = -1;
	}
    }
}

//--------------------------------------------------------------------------------
// When this function is called, the line buffer contains either 3 or 9 characters
// for shifting out to the AEA.  Data is shifted out from ShiftBuffer, allowing
// OutPacket to be used for buffering keystrokes again.

static void
ReadyForShift (void)
{
  ShiftingOut = 1;
  for (ShiftBufferSize = 0 ; ShiftBufferSize < NumOutPacket; ShiftBufferSize++)
    ShiftBuffer[ShiftBufferSize] = OutPacket[ShiftBufferSize];
  ShiftBufferPtr = 0;
  NumOutPacket = 10;
}

//--------------------------------------------------------------------------------
// When a packet has been received from yaAGS, come here to do
// something with it, like displaying digits.

static const char *DigitFilenames[16] = {
  PACKAGE_DATA_DIR "/" PACKAGE "/pixmaps/7Seg-0.xpm",
  PACKAGE_DATA_DIR "/" PACKAGE "/pixmaps/7Seg-1.xpm",
  PACKAGE_DATA_DIR "/" PACKAGE "/pixmaps/7Seg-2.xpm",
  PACKAGE_DATA_DIR "/" PACKAGE "/pixmaps/7Seg-3.xpm",
  PACKAGE_DATA_DIR "/" PACKAGE "/pixmaps/7Seg-4.xpm",
  PACKAGE_DATA_DIR "/" PACKAGE "/pixmaps/7Seg-5.xpm",
  PACKAGE_DATA_DIR "/" PACKAGE "/pixmaps/7Seg-6.xpm",
  PACKAGE_DATA_DIR "/" PACKAGE "/pixmaps/7Seg-7.xpm",
  PACKAGE_DATA_DIR "/" PACKAGE "/pixmaps/7Seg-8.xpm",
  PACKAGE_DATA_DIR "/" PACKAGE "/pixmaps/7Seg-9.xpm",
  PACKAGE_DATA_DIR "/" PACKAGE "/pixmaps/7SegOff.xpm",
  PACKAGE_DATA_DIR "/" PACKAGE "/pixmaps/7SegOff.xpm",
  PACKAGE_DATA_DIR "/" PACKAGE "/pixmaps/7SegOff.xpm",
  PACKAGE_DATA_DIR "/" PACKAGE "/pixmaps/7SegOff.xpm",
  PACKAGE_DATA_DIR "/" PACKAGE "/pixmaps/7SegOff.xpm",
  PACKAGE_DATA_DIR "/" PACKAGE "/pixmaps/7SegOff.xpm"
};

static const char *SignFilenames[16] = {
  PACKAGE_DATA_DIR "/" PACKAGE "/pixmaps/PlusOn.xpm",
  PACKAGE_DATA_DIR "/" PACKAGE "/pixmaps/MinusOn.xpm",
  PACKAGE_DATA_DIR "/" PACKAGE "/pixmaps/PlusMinusOff.xpm",
  PACKAGE_DATA_DIR "/" PACKAGE "/pixmaps/PlusMinusOff.xpm",
  PACKAGE_DATA_DIR "/" PACKAGE "/pixmaps/PlusMinusOff.xpm",
  PACKAGE_DATA_DIR "/" PACKAGE "/pixmaps/PlusMinusOff.xpm",
  PACKAGE_DATA_DIR "/" PACKAGE "/pixmaps/PlusMinusOff.xpm",
  PACKAGE_DATA_DIR "/" PACKAGE "/pixmaps/PlusMinusOff.xpm",
  PACKAGE_DATA_DIR "/" PACKAGE "/pixmaps/PlusMinusOff.xpm",
  PACKAGE_DATA_DIR "/" PACKAGE "/pixmaps/PlusMinusOff.xpm",
  PACKAGE_DATA_DIR "/" PACKAGE "/pixmaps/PlusMinusOff.xpm",
  PACKAGE_DATA_DIR "/" PACKAGE "/pixmaps/PlusMinusOff.xpm",
  PACKAGE_DATA_DIR "/" PACKAGE "/pixmaps/PlusMinusOff.xpm",
  PACKAGE_DATA_DIR "/" PACKAGE "/pixmaps/PlusMinusOff.xpm",
  PACKAGE_DATA_DIR "/" PACKAGE "/pixmaps/PlusMinusOff.xpm",
  PACKAGE_DATA_DIR "/" PACKAGE "/pixmaps/PlusMinusOff.xpm"
};

static const char *OprErrFilenames[2] = {
  PACKAGE_DATA_DIR "/" PACKAGE "/pixmaps/OprErrOff.xpm",
  PACKAGE_DATA_DIR "/" PACKAGE "/pixmaps/OprErrOn.xpm"
};

void
ActOnIncomingIO (GtkWidget *widget, unsigned char *Packet)
{
  extern int ShowPackets;
  int Type, Data;
  clock_t TimeRightNow;
  struct tms TmsBuf;
  
  // Check to see if the message has a yaAGS signature.  If not,
  // ignore it.  The yaAGS signature is 00 11 10 01 in the 
  // 2 most-significant bits of the packet's bytes.  We are 
  // guaranteed that the first byte is signed 00, so we don't 
  // need to check it.
  if (0xc0 != (Packet[1] & 0xc0) ||
      0x80 != (Packet[2] & 0xc0) ||
      0x40 != (Packet[3] & 0xc0))
    return;
  // Make sure we know how to find all of the widgets we need.
  //LocateWidgets (widget);
  // What's in this packet?
  if (ParseIoPacketAGS (Packet, &Type, &Data))
    {
      if (ShowPackets)
	printf ("Message %02X %02X %02X %02X received.\n", 
		Packet[0], Packet[1], Packet[2], Packet[3]);
      return;			// Oops!  Error in packet.
    }
  if (ShowPackets)
    printf ("Message of type %02o of value %06o received.\n", Type, Data);
  // Only a few types are of interest to us.  Note that the DEDA Shift Out discrete
  // isn't of interest to us, since it's merely internal to yaAGS, and the data
  // will simply appear in the DEDA shift register.  In other words, we never
  // even get to see it as anything other than 0.
  if (Type == 040 && 0 == (Data & 010))		// DEDA Shift In discrete, active 0
    {
      int Data;
      // Account for timeout in data to reset the packet buffer.
      TimeRightNow = times (&TmsBuf);
      if (ShiftingOut && ShiftBufferPtr == 0)
        WhenOutPacket = TimeRightNow;
      if (TimeRightNow >= WhenOutPacket + WHEN_OUT_EXPIRED)
        ShiftingOut = 0;
      WhenOutPacket = TimeRightNow + WHEN_OUT_EXPIRED;
      // Prepare the data.
      if (!ShiftingOut || ShiftBufferPtr >= ShiftBufferSize)
        {
          Data = 0x0f << 13;
	  ShiftingOut = 0;
	}
      else
        {
          Data = ShiftBuffer [ShiftBufferPtr++] << 13;
	  if (ShiftBufferPtr >= ShiftBufferSize)
	    ShiftingOut = 0;
	}
      // Send the data.
      OutputData (07, Data);
    }
  else if (Type == 027)				// Incoming DEDA shift register.
    {
      // Account for timeout in data to reset the packet buffer.
      TimeRightNow = times (&TmsBuf);
      if (TimeRightNow >= WhenInPacket + WHEN_IN_EXPIRED)
        NumInPacket = 0;
      WhenInPacket = TimeRightNow + WHEN_IN_EXPIRED;
      // Save the data.  Only the values 0-9 and 15 are valid, but we don't
      // bother to check.
      InPacket[NumInPacket++] = (Data >> 13) & 0x0F;
      if (NumInPacket >= 9)
        {
	  // Okay, we've received a complete packet from the AEA.  Let's 
	  // overwrite the display.
	  NumInPacket = 0;
	  gtk_image_set_from_file (DigitTop1, DigitFilenames[InPacket[0]]);
	  gtk_image_set_from_file (DigitTop2, DigitFilenames[InPacket[1]]);
	  gtk_image_set_from_file (DigitTop3, DigitFilenames[InPacket[2]]);
	  gtk_image_set_from_file (Sign, SignFilenames[InPacket[3]]);
	  gtk_image_set_from_file (DigitBottom1, DigitFilenames[InPacket[4]]);
	  gtk_image_set_from_file (DigitBottom2, DigitFilenames[InPacket[5]]);
	  gtk_image_set_from_file (DigitBottom3, DigitFilenames[InPacket[6]]);
	  gtk_image_set_from_file (DigitBottom4, DigitFilenames[InPacket[7]]);
	  gtk_image_set_from_file (DigitBottom5, DigitFilenames[InPacket[8]]);
	}
    }
}

//--------------------------------------------------------------------------------
// Clear the display.

static void
ClearTheDisplay (void)
{
  gtk_image_set_from_file (DigitTop1, DigitFilenames[15]);
  gtk_image_set_from_file (DigitTop2, DigitFilenames[15]);
  gtk_image_set_from_file (DigitTop3, DigitFilenames[15]);
  gtk_image_set_from_file (Sign, SignFilenames[15]);
  gtk_image_set_from_file (DigitBottom1, DigitFilenames[15]);
  gtk_image_set_from_file (DigitBottom2, DigitFilenames[15]);
  gtk_image_set_from_file (DigitBottom3, DigitFilenames[15]);
  gtk_image_set_from_file (DigitBottom4, DigitFilenames[15]);
  gtk_image_set_from_file (DigitBottom5, DigitFilenames[15]);
}

//--------------------------------------------------------------------------------
// Activate or deactivate the OPR ERR indicator.

static void
OperatorError (int On)
{
  On = (On != 0);			// Make sure it's 0 or 1.
  if (On != OprErr)
    {
      OprErr = On;
      gtk_image_set_from_file (IndicatorOprErr, OprErrFilenames[On]);
      if (On)
        {
          NumOutPacket = 10;
	  ClearTheDisplay ();
	}
    }
}

//--------------------------------------------------------------------------------
// Process a digit as a result of a keypad entry.

static void
ProcessDigit (int Condition, int Num)
{
  LastReadout = 0;
  OperatorError (Condition);
  if (OprErr)
    return;
  switch (NumOutPacket)
    {
    case 0:
      gtk_image_set_from_file (DigitTop1, DigitFilenames[Num]);
      break;
    case 1:
      gtk_image_set_from_file (DigitTop2, DigitFilenames[Num]);
      break;
    case 2:
      gtk_image_set_from_file (DigitTop3, DigitFilenames[Num]);
      break;
    case 3:
      gtk_image_set_from_file (Sign, SignFilenames[Num]);
      break;
    case 4:
      gtk_image_set_from_file (DigitBottom1, DigitFilenames[Num]);
      break;
    case 5:
      gtk_image_set_from_file (DigitBottom2, DigitFilenames[Num]);
      break;
    case 6:
      gtk_image_set_from_file (DigitBottom3, DigitFilenames[Num]);
      break;
    case 7:
      gtk_image_set_from_file (DigitBottom4, DigitFilenames[Num]);
      break;
    case 8:
      gtk_image_set_from_file (DigitBottom5, DigitFilenames[Num]);
      break;
    default:
      OperatorError (1);
      break;
    }
  if (NumOutPacket < 9)
    OutPacket[NumOutPacket++] = Num; 
}

//--------------------------------------------------------------------------------

void
on_KeyEntr_pressed                     (GtkButton       *button,
                                        gpointer         user_data)
{
  OperatorError (NumOutPacket != 9);
  if (OprErr)
    return;
  OutputData (05, 0773004);		// active 0.
  ReadyForShift ();
  LastReadout = 0;
}


void
on_KeyEntr_released                    (GtkButton       *button,
                                        gpointer         user_data)
{
  if (OprErr)
    return;
  OutputData (05, 0777004);		// inactive 1
}


void
on_KeyReadOut_pressed                  (GtkButton       *button,
                                        gpointer         user_data)
{
  if (NumOutPacket == 10 && LastReadout == 1)
    NumOutPacket = 3;
  OperatorError (NumOutPacket != 3);
  if (OprErr)
    return;
  OutputData (05, 0775002);		// active 0
  ReadyForShift ();
  LastReadout = 1;
}


void
on_KeyReadOut_released                 (GtkButton       *button,
                                        gpointer         user_data)
{
  if (OprErr)
    return;
  OutputData (05, 0777002);		// inactive 1
}


void
on_KeyClr_pressed                      (GtkButton       *button,
                                        gpointer         user_data)
{
  OperatorError (0);
  OutputData (05, 0757020);		// active 0
  NumOutPacket = 0;
  ClearTheDisplay ();
  LastReadout = 0;
}


void
on_KeyClr_released                     (GtkButton       *button,
                                        gpointer         user_data)
{
  OutputData (05, 0777020);		// inactive 1
}


void
on_Key9_pressed                        (GtkButton       *button,
                                        gpointer         user_data)
{
  ProcessDigit (NumOutPacket < 4 || NumOutPacket > 9, 9);
}


void
on_Key9_released                       (GtkButton       *button,
                                        gpointer         user_data)
{

}


void
on_Key6_pressed                        (GtkButton       *button,
                                        gpointer         user_data)
{
  ProcessDigit (NumOutPacket == 3 || NumOutPacket > 9, 6);
}


void
on_Key6_released                       (GtkButton       *button,
                                        gpointer         user_data)
{

}


void
on_Key3_pressed                        (GtkButton       *button,
                                        gpointer         user_data)
{
  ProcessDigit (NumOutPacket == 3 || NumOutPacket > 9, 3);
}


void
on_Key3_released                       (GtkButton       *button,
                                        gpointer         user_data)
{

}


void
on_Key8_pressed                        (GtkButton       *button,
                                        gpointer         user_data)
{
  ProcessDigit (NumOutPacket < 4 || NumOutPacket > 9, 8);
}


void
on_Key8_released                       (GtkButton       *button,
                                        gpointer         user_data)
{

}


void
on_Key5_pressed                        (GtkButton       *button,
                                        gpointer         user_data)
{
  ProcessDigit (NumOutPacket == 3 || NumOutPacket > 9, 5);
}


void
on_Key5_released                       (GtkButton       *button,
                                        gpointer         user_data)
{

}


void
on_Key2_pressed                        (GtkButton       *button,
                                        gpointer         user_data)
{
  ProcessDigit (NumOutPacket == 3 || NumOutPacket > 9, 2);
}


void
on_Key2_released                       (GtkButton       *button,
                                        gpointer         user_data)
{

}


void
on_Key7_pressed                        (GtkButton       *button,
                                        gpointer         user_data)
{
  ProcessDigit (NumOutPacket == 3 || NumOutPacket > 9, 7);
}


void
on_Key7_released                       (GtkButton       *button,
                                        gpointer         user_data)
{

}


void
on_Key4_pressed                        (GtkButton       *button,
                                        gpointer         user_data)
{
  ProcessDigit (NumOutPacket == 3 || NumOutPacket > 9, 4);
}


void
on_Key4_released                       (GtkButton       *button,
                                        gpointer         user_data)
{

}


void
on_Key1_pressed                        (GtkButton       *button,
                                        gpointer         user_data)
{
  ProcessDigit (NumOutPacket == 3 || NumOutPacket > 9, 1);
}


void
on_Key1_released                       (GtkButton       *button,
                                        gpointer         user_data)
{

}


void
on_KeyPlus_pressed                     (GtkButton       *button,
                                        gpointer         user_data)
{
  ProcessDigit (NumOutPacket != 3, 0);
}


void
on_KeyPlus_released                    (GtkButton       *button,
                                        gpointer         user_data)
{
  

}


void
on_KeyMinus_pressed                    (GtkButton       *button,
                                        gpointer         user_data)
{
  ProcessDigit (NumOutPacket != 3, 1);
}


void
on_KeyMinus_released                   (GtkButton       *button,
                                        gpointer         user_data)
{

}


void
on_Key0_pressed                        (GtkButton       *button,
                                        gpointer         user_data)
{
  ProcessDigit (NumOutPacket == 3 || NumOutPacket > 9, 0);
}


void
on_Key0_released                       (GtkButton       *button,
                                        gpointer         user_data)
{

}


gboolean
on_MainWindow_delete_event             (GtkWidget       *widget,
                                        GdkEvent        *event,
                                        gpointer         user_data)
{
  gtk_main_quit ();
  return FALSE;
}


void
on_KeyHold_pressed                     (GtkButton       *button,
                                        gpointer         user_data)
{
  OperatorError (LastReadout != 1);
  if (OprErr)
    return;
  OutputData (05, 0767010);		// active 0
}


void
on_KeyHold_released                    (GtkButton       *button,
                                        gpointer         user_data)
{
  OutputData (05, 0777010);		// inactive 1
}

