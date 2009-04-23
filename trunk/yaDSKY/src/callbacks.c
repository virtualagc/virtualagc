/*
  Copyright 2003-2005,2009 Ronald S. Burkey <info@sandroid.org>
  
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
  Purpose:	Provides callbacks for the yaDSKY program.
  Mods:		08/20/03 RSB.	First fully-working version.
  		05/10/04 RSB	Fixed the PRO key.
		06/06/04 RSB	ND2 wasn't being displayed --- instead it
				was overwriting ND1.
		07/11/04 RSB	Added stuff for the indicators being
				controlled by channel 10, by extending
				the *.ini CHAN command.  Also, instead of
				flashing the NOUN or VERB labels, we now
				flash the NOUN or VERB digits.  Furthermore,
				OPR ERR and KEY REL flash.
		07/17/04 RSB	PRO-key signal level inverted.
		08/11/04 RSB	Accomodate the HalfSize switch.
		05/15/05 RSB	Added DebugCounterMode.
		05/29/05 RSB	Added filter to remove incoming packets not
				signed by yaAGC.
		06/26/05 RSB	Added TestUplink.  Also, DecodeDigitalDownlink.
		06/27/05 RSB	Added CmOrLm.
		03/05/09 RSB	Adjusted for --relative-pixmaps.
		03/07/09 RSB	Automatically change any *.xpm files found in
				the cfg file to *.jpg.
*/

#ifdef HAVE_CONFIG_H
#  include <config.h>
#endif

#include <gtk/gtk.h>

#include "callbacks.h"
#include "interface.h"
#include "support.h"
#include "yaAGC.h"
int Socket = -1;

#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include <stdio.h>
#include <ctype.h>

#include "../yaAGC/agc_engine.h"

extern int DebugCounterMode, TestUplink, TestDownlink, RelativePixmaps;
static int DebugCounterReg = 032, DebugCounterInc = 1, DebugCounterWhich = 1;

//----------------------------------------------------------------------------
// This funky little business here is for the purpose of adding the prefix "h"
// to the graphics filenames when the HalfSize option is activated.
void
my_gtk_image_set_from_file (GtkImage *Image, const char *Filename0)
{
  extern int HalfSize;
  static int Initialized = 0, PrefixLength;
  static char Prefix[] = PACKAGE_DATA_DIR "/" PACKAGE "/pixmaps/";
  char *Filename;
  
  if (!Initialized)
    {
      Initialized = 1;
      if (RelativePixmaps)
	strcpy (Prefix, "pixmaps/yaDSKY/");
      PrefixLength = strlen (Prefix);
    }
  Filename = malloc (1 + PrefixLength + strlen (Filename0));
  strcpy (Filename, Prefix);
  strcpy (&Filename[PrefixLength], Filename0);
  //printf ("Looking for image \"%s\"\n", Filename);
  
  if (!HalfSize)
    {
      //printf ("Trying to load \"%s\"\n", Filename);
      gtk_image_set_from_file (Image, Filename);
    }
  else
    {
      char *s, *ss;
      s = malloc (2 + strlen (Filename));
      if (s != NULL)
        {
	  // I am aided in finding the start of the filename by the knowledge
	  // that the filenames end in .jpg and that the names contain only
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
          //printf ("Trying to load \"%s\"\n", s);
          gtk_image_set_from_file (Image, s);
          free (s);
        }
    }
  free (Filename);
}
#ifdef gtk_image_set_from_file
#undef gtk_image_set_from_file
#endif
#define gtk_image_set_from_file(i,f) my_gtk_image_set_from_file (i, f)

// Here are the defaults used for indicator lamps in the absence of a configuration file.
// In cases where we don't know that channel/bit corresponds to the lamp, we use 
// channel -1.
Ind_t Inds[14] = {
  {				// 11
    "UplinkActyOn.jpg",
    "UplinkActyOff.jpg",
    011, 4, 0, 0
  },
  {				// 12
    "NoAttOn.jpg",
    "NoAttOff.jpg",
    010, 9, 0, 0
  },
  {				// 13
    "StbyOn.jpg",
    "StbyOff.jpg",
    013, 11, 0, 0
  },
  {				// 14
    "KeyRelOn.jpg",
    "KeyRelOff.jpg",
    011, 16, 0, 0
  },
  {				// 15
    "OprErrOn.jpg",
    "OprErrOff.jpg",
    011, 64, 0, 0
  },
  {				// 16
    "PrioDispOn.jpg",
    "PrioDispOff.jpg",
    99, 0, 0, 0
  },
  {				// 17
    "NoDapOn.jpg",
    "NoDapOff.jpg",
    99, 0, 0, 0
  },
  {				// 21
    "TempOn.jpg",
    "TempOff.jpg",
    011, 8, 0, 0
  },
  {				// 22
    "GimbalLockOn.jpg",
    "GimbalLockOff.jpg",
    010, 6, 0, 0
  },
  {				// 23
    "ProgOn.jpg",
    "ProgOff.jpg",
    010, 9, 0, 0
  },
  {				// 24
    "RestartOn.jpg",
    "RestartOff.jpg",
    99, 0, 0, 0
  },
  {				// 25
    "TrackerOn.jpg",
    "TrackerOff.jpg",
    010, 8, 0, 0
  },
  {				// 26
    "AltOn.jpg",
    "AltOff.jpg",
    99, 0, 0, 0
  },
  {				// 27
    "VelOn.jpg",
    "VelOff.jpg",
    99, 0, 0, 0
  }
};

//--------------------------------------------------------------------------------
// Function for identifying all widgets used for displaying stuff.  Some widget
// (ANY widget on the screen) is passed as input.

static int WidgetsLocated = 0;
static GtkImage *R1PlusMinus, *R1D1Digit, *R1D2Digit, *R1D3Digit, *R1D4Digit, *R1D5Digit;
static GtkImage *R2PlusMinus, *R2D1Digit, *R2D2Digit, *R2D3Digit, *R2D4Digit, *R2D5Digit;
static GtkImage *R3PlusMinus, *R3D1Digit, *R3D2Digit, *R3D3Digit, *R3D4Digit, *R3D5Digit;
static GtkImage *MD1Digit, *MD2Digit;
GtkImage *VD1Digit, *VD2Digit, *ND1Digit, *ND2Digit;
static GtkImage *ModeAnnunciator, *CompActyAnnunciator;
GtkImage *iLastButton;
GtkImage *VerbAnnunciator, *NounAnnunciator;
GtkImage *KeyRelAnnunciator = NULL, *OprErrAnnunciator = NULL;
const char *CurrentKeyRel, *CurrentOprErr,
           *BlankKeyRel = "KeyRelOff.jpg",
	   *BlankOprErr = "OprErrOff.jpg";

#if 0
static GtkImage *Annunciator11, *Annunciator12, *Annunciator13, *Annunciator14;
static GtkImage *Annunciator15, *Annunciator16, *Annunciator17;
static GtkImage *Annunciator21, *Annunciator22, *Annunciator23, *Annunciator24;
static GtkImage *Annunciator25, *Annunciator26, *Annunciator27;
#endif // 0

void
LocateWidgets (GtkWidget *widget)
{
  if (WidgetsLocated)
    return;
  WidgetsLocated = 1;  
  R1PlusMinus = GTK_IMAGE (lookup_widget (widget, "R1PlusMinus"));
  R1D1Digit = GTK_IMAGE (lookup_widget (widget, "R1D1Digit"));
  R1D2Digit = GTK_IMAGE (lookup_widget (widget, "R1D2Digit"));
  R1D3Digit = GTK_IMAGE (lookup_widget (widget, "R1D3Digit"));
  R1D4Digit = GTK_IMAGE (lookup_widget (widget, "R1D4Digit"));
  R1D5Digit = GTK_IMAGE (lookup_widget (widget, "R1D5Digit"));
  R2PlusMinus = GTK_IMAGE (lookup_widget (widget, "R2PlusMinus"));
  R2D1Digit = GTK_IMAGE (lookup_widget (widget, "R2D1Digit"));
  R2D2Digit = GTK_IMAGE (lookup_widget (widget, "R2D2Digit"));
  R2D3Digit = GTK_IMAGE (lookup_widget (widget, "R2D3Digit"));
  R2D4Digit = GTK_IMAGE (lookup_widget (widget, "R2D4Digit"));
  R2D5Digit = GTK_IMAGE (lookup_widget (widget, "R2D5Digit"));
  R3PlusMinus = GTK_IMAGE (lookup_widget (widget, "R3PlusMinus"));
  R3D1Digit = GTK_IMAGE (lookup_widget (widget, "R3D1Digit"));
  R3D2Digit = GTK_IMAGE (lookup_widget (widget, "R3D2Digit"));
  R3D3Digit = GTK_IMAGE (lookup_widget (widget, "R3D3Digit"));
  R3D4Digit = GTK_IMAGE (lookup_widget (widget, "R3D4Digit"));
  R3D5Digit = GTK_IMAGE (lookup_widget (widget, "R3D5Digit"));
  MD1Digit = GTK_IMAGE (lookup_widget (widget, "MD1Digit"));
  MD2Digit = GTK_IMAGE (lookup_widget (widget, "MD2Digit"));
  VD1Digit = GTK_IMAGE (lookup_widget (widget, "VD1Digit"));
  VD2Digit = GTK_IMAGE (lookup_widget (widget, "VD2Digit"));
  ND1Digit = GTK_IMAGE (lookup_widget (widget, "ND1Digit"));
  ND2Digit = GTK_IMAGE (lookup_widget (widget, "ND2Digit"));
  ModeAnnunciator = GTK_IMAGE (lookup_widget (widget, "ModeAnnunciator"));
  VerbAnnunciator = GTK_IMAGE (lookup_widget (widget, "VerbAnnunciator"));
  NounAnnunciator = GTK_IMAGE (lookup_widget (widget, "NounAnnunciator"));
  CompActyAnnunciator = GTK_IMAGE (lookup_widget (widget, "CompActyAnnunciator"));
  /*Annunciator11 =*/ Inds[0].Widget = GTK_IMAGE (lookup_widget (widget, "Annunciator11"));
  /*Annunciator12 =*/ Inds[1].Widget = GTK_IMAGE (lookup_widget (widget, "Annunciator12"));
  /*Annunciator13 =*/ Inds[2].Widget = GTK_IMAGE (lookup_widget (widget, "Annunciator13"));
  /*Annunciator14 =*/ Inds[3].Widget = GTK_IMAGE (lookup_widget (widget, "Annunciator14"));
  /*Annunciator15 =*/ Inds[4].Widget = GTK_IMAGE (lookup_widget (widget, "Annunciator15"));
  /*Annunciator16 =*/ Inds[5].Widget = GTK_IMAGE (lookup_widget (widget, "Annunciator16"));
  /*Annunciator17 =*/ Inds[6].Widget = GTK_IMAGE (lookup_widget (widget, "Annunciator17"));
  /*Annunciator21 =*/ Inds[7].Widget = GTK_IMAGE (lookup_widget (widget, "Annunciator21"));
  /*Annunciator22 =*/ Inds[8].Widget = GTK_IMAGE (lookup_widget (widget, "Annunciator22"));
  /*Annunciator23 =*/ Inds[9].Widget = GTK_IMAGE (lookup_widget (widget, "Annunciator23"));
  /*Annunciator24 =*/ Inds[10].Widget = GTK_IMAGE (lookup_widget (widget, "Annunciator24"));
  /*Annunciator25 =*/ Inds[11].Widget = GTK_IMAGE (lookup_widget (widget, "Annunciator25"));
  /*Annunciator26 =*/ Inds[12].Widget = GTK_IMAGE (lookup_widget (widget, "Annunciator26"));
  /*Annunciator27 =*/ Inds[13].Widget = GTK_IMAGE (lookup_widget (widget, "Annunciator27"));
  iLastButton = GTK_IMAGE (lookup_widget (widget, "iLastButton"));
}

//--------------------------------------------------------------------------------
// Function for acting on incoming channel i/o from yaAGC, and change any affected
// DSKY annunciators or 7-segment displays.  The Packet parameter
// is a string of 4 bytes, representing a channel i/o packet.  Refer to the
// Virtual AGC Technical Manual, "I/O Specifics" subheading of the "Developer
// Details" chapter.  (The widget parameter can be ANY widget.)

// Matches image widget filenames to channel 010 CCCCC and DDDDD fields.
static const char *SevenSegmentFilenames[32] = {
  "7Seg-0.jpg",
  NULL, NULL,
  "7Seg-3.jpg",
  NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
  "7Seg-15.jpg",
  NULL, NULL, NULL,
  "7Seg-19.jpg",
  NULL,
  "7Seg-21.jpg",
  NULL, NULL, NULL,
  "7Seg-25.jpg",
  NULL,
  "7Seg-27.jpg",
  "7Seg-28.jpg",
  "7Seg-29.jpg",
  "7Seg-30.jpg",
  "7Seg-31.jpg"
};

static int IoErrorCount = 0, Last11 = 0;
int VerbNounFlashing = 0;
static int R1Sign = 0, R2Sign = 0, R3Sign = 0;
const char *CurrentBlank = "7Seg-0.jpg", 
  *CurrentVD1 = "7Seg-0.jpg", 
  *CurrentVD2 = "7Seg-0.jpg", 
  *CurrentND1 = "7Seg-0.jpg", 
  *CurrentND2 = "7Seg-0.jpg";

void
ActOnIncomingIO (GtkWidget *widget, unsigned char *Packet)
{
  Ind_t *Indptr;
  int Channel, Value, uBit, i;
  // Check to see if the message has a yaAGC signature.  If not,
  // ignore it.  The yaAGC signature is 00 01 10 11 in the 
  // 2 most-significant bits of the packet's bytes.  We are 
  // guaranteed that the first byte is signed 00, so we don't 
  // need to check it.
  if (0x40 != (Packet[1] & 0xc0) ||
      0x80 != (Packet[2] & 0xc0) ||
      0xc0 != (Packet[3] & 0xc0))
    return;
  if (ParseIoPacket (Packet, &Channel, &Value, &uBit))
    goto Error;
  // Make sure we know how to find all of the widgets we need.
  LocateWidgets (widget);
  // Take care of all of the indicator lights.
  for (Indptr = Inds, i = 0; i < 14; Indptr++, i++)
    if (Indptr->Channel == Channel &&
        (!Indptr->Latched || ((Value & Indptr->RowMask) == Indptr->Row)) &&
        Indptr->State != (Indptr->Bitmask & (Value ^ Indptr->Polarity)))
      {
        Indptr->State = (Indptr->Bitmask & (Value ^ Indptr->Polarity));
	if (Indptr->State == 0)
	  {
	    gtk_image_set_from_file (Indptr->Widget, Indptr->GraphicOff);
	    if (Indptr->Widget == OprErrAnnunciator)
	      CurrentOprErr = Indptr->GraphicOff;
	    if (Indptr->Widget == KeyRelAnnunciator)
	      CurrentKeyRel = Indptr->GraphicOff;
	  }
	else
	  {
	    gtk_image_set_from_file (Indptr->Widget, Indptr->GraphicOn);
	    if (Indptr->Widget == OprErrAnnunciator)
	      CurrentOprErr = Indptr->GraphicOn;
	    if (Indptr->Widget == KeyRelAnnunciator)
	      CurrentKeyRel = Indptr->GraphicOn;
	  }  
      }
  // Now take care of everything that's left.  Only a few channels are of interest to the
  // DSKY as far as input is concerned.
  if (Channel == 010)
    {
      // 7-segment display management.
      GtkImage *Sign = NULL, *Left = NULL, *Right = NULL;
      int RSign = 0;
      // Set up the pointers to the widgets associated with this channel.
      switch (Value & 0x7800)
        {
	case 0x5800:	// AAAA=11D
	  Left = MD1Digit;
	  Right = MD2Digit;
	  break;
	case 0x5000:	// AAAA=10D
	  Left = VD1Digit;
	  Right = VD2Digit;
	  break;
	case 0x4800:	// AAAA=9
	  Left = ND1Digit;
	  Right = ND2Digit;
	  break;
	case 0x4000:	// AAAA=8
	  Right = R1D1Digit;
	  break;
	case 0x3800:	// AAAA=7
	  Sign = R1PlusMinus;
	  if (0 != (Value & 0x0400))
	    R1Sign |= 2;
	  else
	    R1Sign &= ~2;  
	  RSign = R1Sign;  
	  Left = R1D2Digit;
	  Right = R1D3Digit;
	  break;
	case 0x3000:	// AAAA=6
	  Sign = R1PlusMinus;
	  if (0 != (Value & 0x0400))
	    R1Sign |= 1;
	  else
	    R1Sign &= ~1;
	  RSign = R1Sign;    
	  Left = R1D4Digit;
	  Right = R1D5Digit;
	  break;
	case 0x2800:	// AAAA=5
	  Sign = R2PlusMinus;
	  if (0 != (Value & 0x0400))
	    R2Sign |= 2;
	  else
	    R2Sign &= ~2; 
	  RSign = R2Sign;   
	  Left = R2D1Digit;
	  Right = R2D2Digit;
	  break;
	case 0x2000:	// AAAA=4
	  Sign = R2PlusMinus;
	  if (0 != (Value & 0x0400))
	    R2Sign |= 1;
	  else
	    R2Sign &= ~1;
	  RSign = R2Sign;    
	  Left = R2D3Digit;
	  Right = R2D4Digit;
	  break;
	case 0x1800:	// AAAA=3
	  Left = R2D5Digit;
	  Right = R3D1Digit;
	  break;
	case 0x1000:	// AAAA=2
	  Sign = R3PlusMinus;
	  if (0 != (Value & 0x0400))
	    R3Sign |= 2;
	  else
	    R3Sign &= ~2;
	  RSign = R3Sign;    
	  Left = R3D2Digit;
	  Right = R3D3Digit;
	  break;
	case 0x0800:	// AAAA=1
	  Sign = R3PlusMinus;
	  if (0 != (Value & 0x0400))
	    R3Sign |= 1;
	  else
	    R3Sign &= ~1;
	  RSign = R3Sign;    
	  Left = R3D4Digit;
	  Right = R3D5Digit;
	  break;
	default:
	  goto Error;                  
	}
      // Write the sign.
      if (Sign != NULL)
        {
	  if (0 != (RSign & 1))	
	    gtk_image_set_from_file (Sign, "MinusOn.jpg");
	  else if (0 != (RSign & 2))
	    gtk_image_set_from_file (Sign, "PlusOn.jpg");
	  else				 
	    gtk_image_set_from_file (Sign, "PlusMinusOff.jpg");
	}
      // Write the left digit.
      if (Left != NULL)
        {
	  int i;
	  i = (Value >> 5) & 0x1F;
	  if (SevenSegmentFilenames[i] == NULL)
	    goto Error;
	  if (Left == VD1Digit)
	    CurrentVD1 = SevenSegmentFilenames[i];
	  else if (Left == ND1Digit)
	    CurrentND1 = SevenSegmentFilenames[i];
	  gtk_image_set_from_file (Left, SevenSegmentFilenames[i]);  
	}
      // Write the right digit.
      if (Right != NULL)
        {
	  int i;
	  i = Value & 0x1F;
	  if (SevenSegmentFilenames[i] == NULL)
	    goto Error;
	  if (Right == VD2Digit)
	    CurrentVD2 = SevenSegmentFilenames[i];
	  else if (Right == ND2Digit)
	    CurrentND2 = SevenSegmentFilenames[i];
	  gtk_image_set_from_file (Right, SevenSegmentFilenames[i]);  
	}
    }
  else if (Channel == 011)
    {
      int i;
      // Here are appropriate Luminary 131 actions for various discrete
      // annunciations.
      if ((Value & 2) != (Last11 & 2))
        {
	  if (0 == (Value & 2))
	    gtk_image_set_from_file (CompActyAnnunciator, "CompActyOff.jpg");
	  else
	    gtk_image_set_from_file (CompActyAnnunciator, "CompActyOn.jpg");
	}
      i = (0 != (Value & 32));
      if (VerbNounFlashing && !i)
        {
#if 1
	  gtk_image_set_from_file (VD1Digit, CurrentVD1);
	  gtk_image_set_from_file (VD2Digit, CurrentVD2);
	  gtk_image_set_from_file (ND1Digit, CurrentND1);
	  gtk_image_set_from_file (ND2Digit, CurrentND2);
	  if (OprErrAnnunciator != NULL)
	    gtk_image_set_from_file (OprErrAnnunciator, CurrentOprErr);
	  if (KeyRelAnnunciator != NULL)
	    gtk_image_set_from_file (KeyRelAnnunciator, CurrentKeyRel);
#else // 1
	  gtk_image_set_from_file (VerbAnnunciator, "VerbOn.jpg");
	  gtk_image_set_from_file (NounAnnunciator, "NounOn.jpg");
#endif // 1
	}
      VerbNounFlashing = i;
      Last11 = Value;	
    }
  // If in --test-uplink mode, decode the digital downlink data.  
  if (TestDownlink && (Channel == 013 || Channel == 034 || Channel == 035))
    DecodeDigitalDownlink (Channel, Value, CmOrLm);
  return;
Error:
  IoErrorCount++;
}

//--------------------------------------------------------------------------------
// Parses the configuration file.

void
xpm2jpg (char *s)
{
  char *ss;
  while (NULL != (ss = strstr (s, ".xpm")))
    {
      ss[1] = 'j';
      ss[2] = 'p';
      ss[3] = 'g';
    }
}

int 
ParseCfg (GtkWidget *Widget, char *Filename)
{
  FILE *rfopen (const char *Filename, const char *mode);  Ind_t *Indptr;
  char s[129], *ss, s1[1024], s2[129], s3[129];
  int i, RetVal = 1, IndNum, BitNum, Polarity, Channel, Latched, RowMask, Row;
  FILE *Cfg = NULL;
  LocateWidgets (Widget);
  Cfg = rfopen (Filename, "r");
  if (Cfg == NULL)
    {
      printf ("The specified --cfg file does not exist.\n");
      goto Error;
    }
  s[sizeof (s) - 1] = 0;  
  while (NULL != fgets (s, sizeof (s) - 1, Cfg))
    {
      // Trim off the trailing \n to make it easier to print error messages.
      for (ss = s; *ss; ss++)
        if (*ss == '\n' || *ss == '\r')
	  {
	    *ss = 0;
	    break;
	  }
      if (!strncmp (s, "DEBUG ", 6))
        continue;
      if (!strcmp (s, "LMSIM"))
        {
          CmOrLm = 0;
	  continue;
	}
      if (!strcmp (s, "CMSIM"))
        {
          CmOrLm = 1;
	  continue;
	}
      if (1 == sscanf (s, "PROKEY %s", s2))
        {
	  xpm2jpg (s2);
	  // Look up the widget for the PRO key, and change its graphic.
	  sprintf (s1, "%s%s",
	  	   "", s2);
          gtk_image_set_from_file (iLastButton, s1);
	  continue;
	}  
      if (3 == sscanf (s, "IND %o %s %s", &IndNum, s2, s3))
        {
	  xpm2jpg (s2);
	  xpm2jpg (s3);
	  if (IndNum >= 011 && IndNum <= 017)
	    IndNum -= 011;
	  else if (IndNum >= 021 && IndNum <= 027)
	    IndNum += 7 - 021;
	  else
	    {
	      printf ("Indicator must be 11-17 or 21-27 in \"%s\".\n", s);
	      goto Error;
	    }
	  // Need a better way (or SOME way) to check here for string overflow.
	  sprintf (s1, "%s%s",
	  	   "", s2);
	  Inds[IndNum].GraphicOn = malloc (strlen (s1) + 1);
	  if (Inds[IndNum].GraphicOn == NULL)
	    {
	      printf ("Out of memory.\n");
	      goto Error;
	    }
	  strcpy (Inds[IndNum].GraphicOn, s1);
	  sprintf (s1, "%s%s",
	  	   "", s3);
	  Inds[IndNum].GraphicOff = malloc (strlen (s1) + 1);
	  if (Inds[IndNum].GraphicOff == NULL)
	    {
	      printf ("Out of memory.\n");
	      goto Error;
	    }
	  strcpy (Inds[IndNum].GraphicOff, s1);
	  if (NULL != strstr (s2, "KeyRel") || NULL != strstr (s3, "KeyRel"))
	    {
	      KeyRelAnnunciator = Inds[IndNum].Widget;
	      CurrentKeyRel = BlankKeyRel = Inds[IndNum].GraphicOff;
	    }
	  if (NULL != strstr (s2, "OprErr") || NULL != strstr (s3, "OprErr"))
	    {
	      OprErrAnnunciator = Inds[IndNum].Widget;
	      CurrentOprErr = BlankOprErr = Inds[IndNum].GraphicOff;
	    }
	  continue;
	}
      i = sscanf (s, "CHAN %o %o %d %d %o %o", &IndNum, &Channel, &BitNum, &Polarity, &RowMask, &Row);	
      if (i == 4 || i == 6)
        {
	  if (i == 4)
	    Latched = Row = RowMask = 0;
	  else
	    Latched = 1;
	  if (IndNum >= 011 && IndNum <= 017)
	    IndNum -= 011;
	  else if (IndNum >= 021 && IndNum <= 027)
	    IndNum += 7 - 021;
	  else
	    {
	      printf ("Indicator must be 11-17 or 21-27 in \"%s\".\n", s);
	      goto Error;
	    }
	  if (Channel < 0 || Channel > 255)
	    {
	      printf ("The channel-number must be in the range 0-255 in \"%s\".\n", s);
	      goto Error;
	    }
	  if (BitNum < 1 || BitNum > 15)
	    {
	      printf ("The bit-number must be in the range 1-15 in \"%s\".\n", s);
	      goto Error;
	    }
	  if (Polarity != 0 && Polarity != 1)
	    {
	      printf ("Polarity must be 0 or 1 in \"%s\".\n", s);
	      goto Error;
	    }   
	  BitNum--;  
	  Inds[IndNum].Channel = Channel;
	  Inds[IndNum].Bitmask = (1 << BitNum);
	  Inds[IndNum].Polarity = (Polarity << BitNum);
	  Inds[IndNum].Latched = Latched;
	  Inds[IndNum].RowMask = RowMask;
	  Inds[IndNum].Row = Row;
	  continue;
	}
      for (ss = s; isspace (*ss); ss++);
      if (*ss != 0 && *ss != '#')
        {
	  printf ("Input line not recognized: \"%s\".\n", s);
	  goto Error;
	}
    } 
  // Update all of the indicator legends.  
  for (Indptr = Inds, i = 0; i < 14; Indptr++, i++)
    gtk_image_set_from_file (Indptr->Widget, Indptr->GraphicOff);
  RetVal = 0;  
Error:
  if (Cfg != NULL)
    fclose (Cfg);    
  return (RetVal);
}

//--------------------------------------------------------------------------------
// A nice little function to output a keycode (except PRO) to yaAGC.

void
OutputKeycode (int Keycode)
{
  unsigned char Packet[4];
  extern int ServerSocket;
  int j;
  if (ServerSocket != -1)
    {
      if (TestUplink)
        {
	  // In this case, we communicate keycodes to the AGC via the digital
	  // uplink rather than through the normal DSKY input channel.
	  Keycode &= 037;
	  Keycode |= ((Keycode << 10) | ((Keycode ^ 037) << 5));
	  FormIoPacket (0173, Keycode, Packet);
	}
      else	
        FormIoPacket (015, Keycode, Packet);
      j = send (ServerSocket, Packet, 4, MSG_NOSIGNAL);
      if (j == SOCKET_ERROR && SOCKET_BROKEN)
        {
	  close (ServerSocket);
	  ServerSocket = -1;
	}
    }
}

//--------------------------------------------------------------------------------
// ... and a similar function for outputting the PRO-key status to yaAGC.

void
OutputPro (int OffOn)
{
  unsigned char Packet[8];
  extern int ServerSocket;
  int j;
  if (ServerSocket != -1)
    {
      // First, create the mask which will tell the CPU to only pay attention to
      // bit 14 of the channel (032).
      FormIoPacket (0432, 020000, Packet);
      // Next, generate the data itself.
      if (OffOn)
        OffOn = 020000;
      FormIoPacket (032, OffOn, &Packet[4]);
      // And, send it all.
      j = send (ServerSocket, Packet, 8, MSG_NOSIGNAL);
      if (j == SOCKET_ERROR && SOCKET_BROKEN)
        {
	  close (ServerSocket);
	  ServerSocket = -1;
	}
    }
}

//--------------------------------------------------------------------------------
// GTK+ callbacks.

#include <stdio.h>
void
on_EntrButton_pressed                  (GtkButton       *button,
                                        gpointer         user_data)
{
  OutputKeycode (28);
}


void
on_EntrButton_released                 (GtkButton       *button,
                                        gpointer         user_data)
{

}


//void
//on_EntrButton_clicked                  (GtkButton       *button,
//                                        gpointer         user_data)
//{
//
//}


void
on_NounButton_pressed                  (GtkButton       *button,
                                        gpointer         user_data)
{
  if (DebugCounterMode)
    {
      DebugCounterWhich = 0;
      DebugCounterReg = 0;
    }
  else
    OutputKeycode (31);
}


void
on_NounButton_released                 (GtkButton       *button,
                                        gpointer         user_data)
{

}


void
on_SevenButton_pressed                 (GtkButton       *button,
                                        gpointer         user_data)
{
  if (DebugCounterMode)
    {
      if (DebugCounterWhich)
        DebugCounterInc = 7;
      else
        DebugCounterReg = (DebugCounterReg * 8) + 7;
    }
  else
    OutputKeycode (7);
}


void
on_SevenButton_released                (GtkButton       *button,
                                        gpointer         user_data)
{

}


void
on_EightButton_pressed                 (GtkButton       *button,
                                        gpointer         user_data)
{
  OutputKeycode (8);
}


void
on_EightButton_released                (GtkButton       *button,
                                        gpointer         user_data)
{

}


void
on_NineButton_pressed                  (GtkButton       *button,
                                        gpointer         user_data)
{
  OutputKeycode (9);
}


void
on_NineButton_released                 (GtkButton       *button,
                                        gpointer         user_data)
{

}


void
on_ClrButton_pressed                   (GtkButton       *button,
                                        gpointer         user_data)
{
  OutputKeycode (30);
}


void
on_ClrButton_released                  (GtkButton       *button,
                                        gpointer         user_data)
{

}


void
on_KeyRelButton_pressed                (GtkButton       *button,
                                        gpointer         user_data)
{
  OutputKeycode (25);
}


void
on_KeyRelButton_released               (GtkButton       *button,
                                        gpointer         user_data)
{

}


void
on_ProButton_pressed                   (GtkButton       *button,
                                        gpointer         user_data)
{
  if (DebugCounterMode)
    {
      int j;
      unsigned char Packet[4];
      extern int ServerSocket; 
      if (DebugCounterReg < 032 || DebugCounterReg > 060)
        return;
      if (DebugCounterInc < 0 || DebugCounterInc > 6)
        return;
      Packet[0] = 0x10 | ((DebugCounterReg >> 3) & 0x0f);
      Packet[1] = 0x40 | ((DebugCounterReg & 7) << 3);
      Packet[2] = 0x80;
      Packet[3] = 0xC0 | (DebugCounterInc & 7);
      //printf ("Reg=%02o Inc=%o Packet=%02x %02x %02x %02x\n",
      //	      DebugCounterReg, DebugCounterInc,
      //	      Packet[0], Packet[1], Packet[2], Packet[3]);
      if (ServerSocket != -1)
	{
	  j = send (ServerSocket, Packet, 4, MSG_NOSIGNAL);
	  if (j == SOCKET_ERROR && SOCKET_BROKEN)
	    {
	      if (!DebugMode)
	        printf ("Removing socket %d\n", ServerSocket);
#ifdef unix
	      close (ServerSocket);
#else
	      closesocket (ServerSocket);
#endif
	      ServerSocket = -1;
	    }
	}
    }
  else
    OutputPro (0);	// This is a low-polarity signal.
}

void
on_ProButton_released                  (GtkButton       *button,
                                        gpointer         user_data)
{
  if (!DebugCounterMode)
    OutputPro (1);
}


void
on_RsetButton_pressed                  (GtkButton       *button,
                                        gpointer         user_data)
{
  OutputKeycode (18);
}


void
on_RsetButton_released                 (GtkButton       *button,
                                        gpointer         user_data)
{

}


void
on_SixButton_pressed                   (GtkButton       *button,
                                        gpointer         user_data)
{
  if (DebugCounterMode)
    {
      if (DebugCounterWhich)
        DebugCounterInc = 6;
      else
        DebugCounterReg = (DebugCounterReg * 8) + 6;
    }
  else
    OutputKeycode (6);
}


void
on_SixButton_released                  (GtkButton       *button,
                                        gpointer         user_data)
{

}


void
on_FiveButton_pressed                  (GtkButton       *button,
                                        gpointer         user_data)
{
  if (DebugCounterMode)
    {
      if (DebugCounterWhich)
        DebugCounterInc = 5;
      else
        DebugCounterReg = (DebugCounterReg * 8) + 5;
    }
  else
    OutputKeycode (5);
}


void
on_FiveButton_released                 (GtkButton       *button,
                                        gpointer         user_data)
{

}


void
on_FourButton_pressed                  (GtkButton       *button,
                                        gpointer         user_data)
{
  if (DebugCounterMode)
    {
      if (DebugCounterWhich)
        DebugCounterInc = 4;
      else
        DebugCounterReg = (DebugCounterReg * 8) + 4;
    }
  else
    OutputKeycode (4);
}


void
on_FourButton_released                 (GtkButton       *button,
                                        gpointer         user_data)
{

}


void
on_MinusButton_pressed                 (GtkButton       *button,
                                        gpointer         user_data)
{
  OutputKeycode (27);
}


void
on_MinusButton_released                (GtkButton       *button,
                                        gpointer         user_data)
{

}


void
on_ZeroButton_pressed                  (GtkButton       *button,
                                        gpointer         user_data)
{
  if (DebugCounterMode)
    {
      if (DebugCounterWhich)
        DebugCounterInc = 0;
      else
        DebugCounterReg = (DebugCounterReg * 8) + 0;
    }
  else
    OutputKeycode (16);
}


void
on_ZeroButton_released                 (GtkButton       *button,
                                        gpointer         user_data)
{

}


void
on_OneButton_pressed                   (GtkButton       *button,
                                        gpointer         user_data)
{
  if (DebugCounterMode)
    {
      if (DebugCounterWhich)
        DebugCounterInc = 1;
      else
        DebugCounterReg = (DebugCounterReg * 8) + 1;
    }
  else
    OutputKeycode (1);
}


void
on_OneButton_released                  (GtkButton       *button,
                                        gpointer         user_data)
{

}


void
on_TwoButton_pressed                   (GtkButton       *button,
                                        gpointer         user_data)
{
  if (DebugCounterMode)
    {
      if (DebugCounterWhich)
        DebugCounterInc = 2;
      else
        DebugCounterReg = (DebugCounterReg * 8) + 2;
    }
  else
    OutputKeycode (2);
}


void
on_TwoButton_released                  (GtkButton       *button,
                                        gpointer         user_data)
{

}


void
on_ThreeButton_pressed                 (GtkButton       *button,
                                        gpointer         user_data)
{
  if (DebugCounterMode)
    {
      if (DebugCounterWhich)
        DebugCounterInc = 3;
      else
        DebugCounterReg = (DebugCounterReg * 8) + 3;
    }
  else
    OutputKeycode (3);
}


void
on_ThreeButton_released                (GtkButton       *button,
                                        gpointer         user_data)
{

}


void
on_PlusButton_pressed                  (GtkButton       *button,
                                        gpointer         user_data)
{
  OutputKeycode (26);
}


void
on_PlusButton_released                 (GtkButton       *button,
                                        gpointer         user_data)
{

}


void
on_VerbButton_pressed                  (GtkButton       *button,
                                        gpointer         user_data)
{
  if (DebugCounterMode)
    {
      DebugCounterWhich = 1;
      DebugCounterInc = 0;
    }
  else
    OutputKeycode (17);
}


void
on_VerbButton_released                 (GtkButton       *button,
                                        gpointer         user_data)
{

}


gboolean
on_MainWindow_destroy_event            (GtkWidget       *widget,
                                        GdkEvent        *event,
                                        gpointer         user_data)
{
  return  FALSE;
}


gboolean
on_MainWindow_delete_event             (GtkWidget       *widget,
                                        GdkEvent        *event,
                                        gpointer         user_data)
{
#if 0
  // Works badly ...
  extern int ServerSocket;
  close (ServerSocket);
#endif
  gtk_main_quit ();
  return FALSE;
}

