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
  
  In addition, as a special exception, Ronald S. Burkey gives permission to
  link the code of this program with the Orbiter SDK library (or with 
  modified versions of the Orbiter SDK library that use the same license as 
  the Orbiter SDK library), and distribute linked combinations including 
  the two. You must obey the GNU General Public License in all respects for 
  all of the code used other than the Orbiter SDK library. If you modify 
  this file, you may extend this exception to your version of the file, 
  but you are not obligated to do so. If you do not wish to do so, delete 
  this exception statement from your version. 
 
  Filename:	DecodeDownlinkList.c
  Purpose:	The DecodeDigitalDownlink function can be used to print out
  		a downlink list.  Simply keep feeding it data from channel
		013, 034, and 035 as the data arrives.
  Compiler:	GNU gcc.
  Contact:	Ron Burkey <info@sandroid.org>
  Reference:	http://www.ibiblio.org/apollo/index.html
  Mods:		06/27/05 RSB.	Began.
  		06/28/05 RSB.	Rewrote a lot to base the printing on 
				arrays of specifications.
		06/30/05 RSB	Now completely configurable at runtime.
		07/01/05 RSB	Now *even more* completely configurable at
				runtime.  Finished LM Coast/Align.
		07/03/05 RSB	Removed the LeftShift and Mask table
				parameters, and replaced with a user-
				definable formatting function.  Completed
				the LM Orbital Maneuvers downlist.
				Completed LM Surface Align downlist.
				Completed LM Rendezvous/Prethrust downlist.
				Completed LM Descent/Ascent downlist.
		07/26/05 RSB	Corrected scaling for all SP quantities.
				(Oops!)  Added CM Powered List..
		07/27/05 RSB	Added CM Program 22 list.
		07/28/05 RSB	Added remainder of CM downlink lists.
  
*/

#define DECODE_DIGITAL_DOWNLINK_C
#include <stdio.h>
#include <string.h>
#include "agc_engine.h"

//#define FLOAT_SCALE (1.0 / 0x10000000)
#define FLOAT_SCALE (1.0 / 02000000000)
#define S_FLOAT_SCALE (1.0 / 040000)
#define US_FLOAT_SCALE (1.0 / 0100000)
#define PRINT_CSM 1
#define PRINT_LM 2
#define B0 0x1
#define B1 0x2
#define B2 0x4
#define B3 0x8
#define B4 0x10
#define B5 0x20
#define B6 0x40
#define B7 0x80
#define B8 0x100
#define B9 0x200
#define B10 0x400
#define B11 0x800
#define B12 0x1000
#define B13 0x2000
#define B14 0x4000
#define B15 0x8000
#define B16 0x10000
#define B17 0x20000
#define B18 0x40000
#define B19 0x80000
#define B20 0x100000
#define B21 0x200000
#define B22 0x400000
#define B23 0x800000
#define B24 0x1000000
#define B25 0x2000000
#define B26 0x4000000
#define B27 0x8000000
#define B28 0x10000000
#define B29 0x20000000

//--------------------------------------------------------------------------
// Some specific formatting functions for wacky fields.

static char DefaultFormatBuffer[33];

// LM Coast Align -- RR Range.
static char *
FormatRrRange (int IndexIntoList, int Scale, Format_t Format)
{
  double x;
  int Radmodes;
  x = GetSP (&DownlinkListBuffer[IndexIntoList], 1);
  Radmodes = DownlinkListBuffer[126];
  if (04 & Radmodes)		// high scale
    x *= 75.04;
  else
    x *= 9.38;
  sprintf (DefaultFormatBuffer, "%.5g", x);
  return (DefaultFormatBuffer);
}

// LM Coast Align -- RR Range Rate.
static char *
FormatRrRangeRate (int IndexIntoList, int Scale, Format_t Format)
{
  double x;
  x = (DownlinkListBuffer[IndexIntoList] - 017000) * (-0.6278);
  sprintf (DefaultFormatBuffer, "%.5g", x);
  return (DefaultFormatBuffer);
}

// LM Coast Align -- LR Vx
static char *
FormatLrVx (int IndexIntoList, int Scale, Format_t Format)
{
  double x;
  x = (DownlinkListBuffer[IndexIntoList] - 12288.2) * (-0.6440);
  sprintf (DefaultFormatBuffer, "%.5g", x);
  return (DefaultFormatBuffer);
}

// LM Coast Align -- LR Vy
static char *
FormatLrVy (int IndexIntoList, int Scale, Format_t Format)
{
  double x;
  x = (DownlinkListBuffer[IndexIntoList] - 12288.2) * (1.212);
  sprintf (DefaultFormatBuffer, "%.5g", x);
  return (DefaultFormatBuffer);
}

// LM Coast Align -- LR Vz
static char *
FormatLrVz (int IndexIntoList, int Scale, Format_t Format)
{
  double x;
  x = (DownlinkListBuffer[IndexIntoList] - 12288.2) * (0.8668);
  sprintf (DefaultFormatBuffer, "%.5g", x);
  return (DefaultFormatBuffer);
}

// LM Coast Align -- LR Range.
static char *
FormatLrRange (int IndexIntoList, int Scale, Format_t Format)
{
  double x;
  int Radmodes;
  x = GetSP (&DownlinkListBuffer[IndexIntoList], 1);
  Radmodes = DownlinkListBuffer[126];
  if (0400 & Radmodes)		// high scale
    x *= 5.395;
  else
    x *= 1.079;
  sprintf (DefaultFormatBuffer, "%.5g", x);
  return (DefaultFormatBuffer);
}

// LM AGS Initialization -- LM & CM Epoch
static char *
FormatEpoch (int IndexIntoList, int Scale, Format_t Format)
{
  int Data[2];
  double x;
  Data[0] = DownlinkListBuffer[IndexIntoList];
  Data[1] = DownlinkListBuffer[IndexIntoList + 4];
  x = GetDP (Data, Scale);
  sprintf (DefaultFormatBuffer, "%.10g", x);
  return (DefaultFormatBuffer);
}

// LM AGS Initialization -- Adjust SP scaling depending on 
// Earth vs. Moon.  Assumes that Scale is set for Earth-orbit,
// and adjusts it downward for Moon-orbit.  This is the usual
// situation where there is a difference in earth-moon scaling,
// so this function can be used in a number of cases.
static char *
FormatEarthOrMoonSP (int IndexIntoList, int Scale, Format_t Format)
{
  double x;
  int Flagword0;
  Flagword0 = DownlinkListBuffer[76];
  if (04000 & Flagword0)	// MOONFLAG
    Scale /= 4;
  x = GetSP (&DownlinkListBuffer[IndexIntoList], Scale);
  sprintf (DefaultFormatBuffer, "%.5g", x);
  return (DefaultFormatBuffer);
}

// Similar, but different flag is used for earth vs. moon
static char *
FormatEarthOrMoonDP (int IndexIntoList, int Scale, Format_t Format)
{
  double x;
  int Flagword8;
  Flagword8 = DownlinkListBuffer[84];
  if (02000 & Flagword8)	// LMOONFLG
    Scale /= 4;
  x = GetDP (&DownlinkListBuffer[IndexIntoList], Scale);
  sprintf (DefaultFormatBuffer, "%.10g", x);
  return (DefaultFormatBuffer);
}

// LM Descent/Ascent --- HMEAS (LR RANGE)
static char *
FormatHMEAS (int IndexIntoList, int Scale, Format_t Format)
{
  double x;
  x = GetDP (&DownlinkListBuffer[IndexIntoList], Scale);
  sprintf (DefaultFormatBuffer, "%.10g", 1.079 * x);
  return (DefaultFormatBuffer);
}

// LM Descent/Ascent --- FC
static char *
FormatGtc (int IndexIntoList, int Scale, Format_t Format)
{
  double x;
  x = GetDP (&DownlinkListBuffer[IndexIntoList], Scale);
  sprintf (DefaultFormatBuffer, "%.10g", 2.817 * x);
  return (DefaultFormatBuffer);
}

// CM (all) -- ADOT vs. OGARATE/OMEGAB, or WBODY vs. OMEGAC
static char *
FormatAdotsOrOga (int IndexIntoList, int Scale, Format_t Format)
{
  int Flagword6, Dapdatr1, Flagword9;
  double fScale, x;
  x = GetDP (&DownlinkListBuffer[IndexIntoList], 1);
  Flagword6 = 060000 & DownlinkListBuffer[84];
  Flagword9 = 0400 & DownlinkListBuffer[87];
  Dapdatr1 = 070000 & DownlinkListBuffer[162];
  if (Flagword6 == 020000)	// RCS DAP
    fScale = 450.0;
  else if (Flagword6 == 040000)	// TVC DAP
    {
      if (IndexIntoList == 20)	// OGARATE
        fScale = 16.0;
      else 			// OMEGAB pitch, yaw, or OMEGAC
        {
	  if (Dapdatr1 == 010000)
	    fScale = 12.5;
	  else if ((Dapdatr1 & 030000) != 020000)
	    return ("(unknown)");
	  else if (Flagword9 == 0)
	    fScale = 1.0;	// Scaling here relies on data we don't have.
	  else
	    fScale = 6.25;
	}
    }
  else				// No DAP
    return ("(unknown)");
  sprintf (DefaultFormatBuffer, "%.10g", fScale * x);
  return (DefaultFormatBuffer);
}

// CM Powered list -- DELVs
static char *
FormatDELV (int IndexIntoList, int Scale, Format_t Format)
{
  double x;
  x = GetDP (&DownlinkListBuffer[IndexIntoList], Scale);
  sprintf (DefaultFormatBuffer, "%.10g", 5.85 * x);
  return (DefaultFormatBuffer);
}

// CM Powered list -- PACTOFF or YACTOFF
static char *
FormatXACTOFF (int IndexIntoList, int Scale, Format_t Format)
{
  double x;
  x = GetSP (&DownlinkListBuffer[IndexIntoList], Scale);
  sprintf (DefaultFormatBuffer, "%.5g", 85.41 * x);
  return (DefaultFormatBuffer);
}

// CM Program 22 -- optics trunnion angle
static char *
FormatOTRUNNION (int IndexIntoList, int Scale, Format_t Format)
{
  int twos;
  double x;
  // Fetch the value, which is in 2's complement.
  twos = DownlinkListBuffer[IndexIntoList];
  if (040000 & twos)
    twos |= ~077777;
  x = twos * S_FLOAT_SCALE * 45 + 19.7754;
  sprintf (DefaultFormatBuffer, "%.5g", x);
  return (DefaultFormatBuffer);
}

// Scales by half.
static char *
FormatHalfDP (int IndexIntoList, int Scale, Format_t Format)
{
  double x;
  x = GetDP (&DownlinkListBuffer[IndexIntoList], Scale);
  sprintf (DefaultFormatBuffer, "%.10g", x / 2);
  return (DefaultFormatBuffer);
}

// CM Entry/Update -- RDOT..
static char *
FormatRDOT (int IndexIntoList, int Scale, Format_t Format)
{
  double x;
  x = GetDP (&DownlinkListBuffer[IndexIntoList], 1);
  sprintf (DefaultFormatBuffer, "%.10g", x * 2 * 25766.1973);
  return (DefaultFormatBuffer);
}

//--------------------------------------------------------------------------

// Write the screen buffer to the terminal.

static void
SwriteDefault (void)
{
  int i;
  printf ("\x1b[0;0H");		// ANSI move to top of screen.
  for (i = 0; i < Sheight; i++)
    puts (Sbuffer[i]);
}

// The idea here is that by default, the downlink data is displayed using the
// SwriteDefault function.  However, at runtime this pointer could be replaced
// by any other appropriate function, and the data would be displayed some other
// way.
Swrite_t *SwritePtr = SwriteDefault;

static void
Swrite (void)
{
  int i, j;
  for (i = 0; i < Sheight; i++)
    {
      for (j = 0; j < Swidth; j++)
        if (0 == Sbuffer[i][j])
	  Sbuffer[i][j] = ' ';
      Sbuffer[i][Swidth] = 0;
    }
  (*SwritePtr) ();
}

// Clear the screen buffer.
static int LastRow = 1, LastCol = 0;
static void
Sclear (void)
{
  int i, j;
  LastRow = 1;
  LastCol = 0;
  for (i = 0; i < Sheight; i++)
    for (j = 0; j < Swidth; j++)
      Sbuffer[i][j] = ' ';  
}

//---------------------------------------------------------------------------
// Specifications for the DEFAULT downlink lists.  Changing the names or formats
// of the downlink-list fields, or changing their screen positions, is just
// a matter of editing the following lists.

static DownlinkListSpec_t CmPoweredListSpec = {
  "LM Powered downlink list",
  {
    { 0, "ID=", B0, FMT_OCT },
    { 1, "SYNC=", B0, FMT_OCT },
    { 100, "TIME=", B28, FMT_DP },
    { -1 },
    { 2, "RN=", B29, FMT_DP },
    { 4, "RN+2=", B29, FMT_DP },
    { 6, "RN+4=", B29, FMT_DP },
    { -1 },
    { 8, "VN=", B7, FMT_DP },
    { 10, "VN+2=", B7, FMT_DP },
    { 12, "VN+4=", B7, FMT_DP },
    { 14, "PIPTIME=", B28, FMT_DP },
    { 16, "CDUX=", 360, FMT_SP },
    { 17, "CDUY=", 360, FMT_SP },
    { 18, "CDUZ=", 360, FMT_SP },
    { 19, "CDUT=", B0, FMT_2OCT },	// Confused about this one.
    { 20, "ADOT=", 450, FMT_DP, &FormatAdotsOrOga },
    { 22, "ADOT+2=", 450, FMT_DP, &FormatAdotsOrOga },
    { 24, "ADOT+4=", 450, FMT_DP, &FormatAdotsOrOga },
    { -1 },
    { 26, "AK=", 180, FMT_SP },
    { 27, "AK1=", 180, FMT_SP },
    { 28, "AK2=", 180, FMT_SP }, 
    { 29, "RCSFLAGS=", B0, FMT_OCT },
    { 30, "THETADX=", 360, FMT_USP },
    { 31, "THETADY=", 360, FMT_USP },
    { 32, "THETADZ=", 360, FMT_USP },
    { 34, "TIG=", B28, FMT_DP },
    { 36, "DELLT4=", B28, FMT_DP },
    { 38, "RTARG=", B29, FMT_DP },
    { 40, "RTARG+2=", B29, FMT_DP },
    { 42, "RTARG+4=", B29, FMT_DP },
    { 44, "TGO=", B28, FMT_DP },
    { 46, "PIPTIME1=", B28, FMT_DP },
    { -1 }, { -1 },
    { 48, "DELV=", B14, FMT_DP, &FormatDELV },
    { 50, "DELV+2=", B14, FMT_DP, &FormatDELV },
    { 52, "DELV+4=", B14, FMT_DP, &FormatDELV },
    { -1 },
    { 54, "PACTOFF=", B14, FMT_SP, &FormatXACTOFF },
    { 55, "YACTOFF=", B14, FMT_SP, &FormatXACTOFF },
    { 56, "PCMD=", B14, FMT_SP, &FormatXACTOFF },
    { 57, "YCMD=", B14, FMT_SP, &FormatXACTOFF },
    { 58, "CSTEER=", 4, FMT_SP },
    { 60, "DELVEET1=", B7, FMT_DP },
    { -1 }, { -1 },
    { 66, "REFSMMAT=", 2, FMT_DP },
    { 68, "REFSMMAT+2=", 2, FMT_DP },
    { 70, "REFSMMAT+4=", 2, FMT_DP },
    { 72, "REFSMMAT+6=", 2, FMT_DP },
    { 74, "REFSMMAT+8=", 2, FMT_DP },
    { 76, "REFSMMAT+10=", 2, FMT_DP },
    { -1 }, { -1 },
    { 78, "STATE=", B0, FMT_2OCT },
    { 80, "STATE+2=", B0, FMT_2OCT },
    { 82, "STATE+4=", B0, FMT_2OCT },
    { 84, "STATE+6=", B0, FMT_2OCT },
    { 86, "STATE+8=", B0, FMT_2OCT },
    { -1 },
    { 88, "DSPTB=", B0, FMT_OCT },
    { 90, "DSPTB+2=", B0, FMT_2OCT },
    { 92, "DSPTB+4=", B0, FMT_2OCT },
    { 94, "DSPTB+6=", B0, FMT_2OCT },
    { 96, "DSPTB+8=", B0, FMT_2OCT },
    { 98, "DSPTB+10=", B0, FMT_2OCT },
    { 102, "R-OTHER=", B29, FMT_DP },
    { 104, "R-OTHER+2=", B29, FMT_DP },
    { 106, "R-OTHER+4=", B29, FMT_DP },
    { -1 },
    { 108, "V-OTHER=", B7, FMT_DP },
    { 110, "V-OTHER+2=", B7, FMT_DP },
    { 112, "V-OTHER+4=", B7, FMT_DP },
    { 114, "T-OTHER=", B28, FMT_DP },
    { 134, "RSBBQ=", B0, FMT_2OCT },
    { 137, "CHAN77=", B0, FMT_OCT },
    { 138, "C31FLWRD=", B0, FMT_OCT },
    { -1 },
    { 139, "FAILREG=", B0, FMT_OCT },
    { 140, "FAILREG+1=", B0, FMT_OCT },
    { 141, "FAILREG+2=", B0, FMT_OCT },
    { 142, "CDUS=", 360, FMT_SP },
    { 143, "PIPAX=", B14, FMT_SP },
    { 144, "PIPAY=", B14, FMT_SP },
    { 145, "PIPAZ=", B14, FMT_SP },
    { 146, "ELEV=", 360, FMT_DP },
    { 148, "CENTANG=", 360, FMT_DP },
    { 150, "OFFSET=", B29, FMT_DP },
    { 152, "STATE+10=", B0, FMT_2OCT },
    { 154, "TEVENT=", B28, FMT_DP },
    { 158, "OPTMODES=", B0, FMT_OCT },
    { 159, "HOLDFLAG=", B0, FMT_DEC },
    { 160, "LEMMASS=", B16, FMT_SP },
    { 161, "CSMMASS=", B16, FMT_SP },
    { 162, "DAPDATR1=", B0, FMT_OCT },
    { 163, "DAPDATR2=", B0, FMT_OCT },
    { -1 }, { -1 },
    { 164, "ERRORX=", 180, FMT_SP },
    { 165, "ERRORY=", 180, FMT_SP },
    { 166, "ERRORZ=", 180, FMT_SP },
    { -1 },
    { 168, "WBODY=", 450, FMT_DP, &FormatAdotsOrOga },
    { 170, "WBODY+2=", 450, FMT_DP, &FormatAdotsOrOga },
    { 172, "WBODY+4=", 450, FMT_DP, &FormatAdotsOrOga },
    { 174, "REDOCTR=", B0, FMT_DEC },
    { 175, "THETAD=", 360, FMT_SP },
    { 176, "THETAD+1=", 360, FMT_SP },
    { 177, "THETAD+2=", 360, FMT_SP },
    { -1 },
    { 178, "IMODES30=", B0, FMT_OCT },
    { 179, "IMODES33=", B0, FMT_OCT },
    { -1 },
    { -1 },
    { 180, "CHN11,12=", B0, FMT_2OCT },
    { 182, "CHN13,14=", B0, FMT_2OCT },
    { 184, "CHN30,31=", B0, FMT_2OCT },
    { 186, "CHN32,33=", B0, FMT_2OCT },
    { 188, "VGTIG=", B7, FMT_DP },
    { 190, "VGTIG+2=", B7, FMT_DP },
    { 192, "VGTIG+4=", B7, FMT_DP },
    { -1 },
    { 194, "DELVEET2=", B7, FMT_DP },
    { 196, "DELVEET2+2=", B7, FMT_DP },
    { 198, "DELVEET2+4=", B7, FMT_DP }    
  }
};

static DownlinkListSpec_t LmOrbitalManeuversSpec = {
  "LM Orbital Maneuvers downlink list",
  {
    { 0, "ID=", B0, FMT_OCT },
    { 1, "SYNC=", B0, FMT_OCT },
    { 100, "TIME=", B28, FMT_DP },
    { -1 },
    { 2, "R-OTHER=", B29, FMT_DP },
    { 4, "R-OTHER+2=", B29, FMT_DP },
    { 6, "R-OTHER+4=", B29, FMT_DP },
    { -1 },
    { 8, "V-OTHER=", B7, FMT_DP },
    { 10, "V-OTHER+2=", B7, FMT_DP },
    { 12, "V-OTHER+4=", B7, FMT_DP },
    { 14, "T-OTHER=", B28, FMT_DP },
    { 16, "DELLT4=", B28, FMT_DP },
    { 18, "RTARGX=", B29, FMT_DP },
    { 20, "RTARGY=", B29, FMT_DP },
    { 22, "RTARGZ=", B29, FMT_DP },
    { 24, "ELEV=", 360, FMT_DP },
    { 26, "TEVENT=", B28, FMT_DP },
    { -1 }, { -1 },
    { 28, "REFSMMAT=", B0, FMT_DP },
    { 30, "REFSMMAT+2=", B0, FMT_DP },
    { 32, "REFSMMAT+4=", B0, FMT_DP },
    { 34, "REFSMMAT+6=", B0, FMT_DP },
    { 36, "REFSMMAT+8=", B0, FMT_DP },
    { 38, "REFSMMAT+10=", B0, FMT_DP },
    { -1 }, { -1 },
    { 40, "TCSI=", B28, FMT_DP },
    { 42, "DELVEET1=", B7, FMT_DP },
    { 44, "DELVEET1+2=", B7, FMT_DP },
    { 46, "DELVEET1+4=", B7, FMT_DP },
    { 48, "VGTIG=", B7, FMT_DP },
    { 50, "VGTIG+2=", B7, FMT_DP },
    { 52, "VGTIG+4=", B7, FMT_DP },
    { -1 },
    { 54, "DNLRVELZ=", B27, FMT_SP, &FormatLrVz },
    { 56, "DNLRALT=", B27, FMT_SP, &FormatLrRange },
    { 58, "REDOCTR=", B0, FMT_DEC },
    { -1 },
    { 59, "THETAD=", 360, FMT_SP },
    { 60, "THETAD+1=", 360, FMT_SP },
    { 61, "THETAD+2=", 360, FMT_SP },
    { -1 },
    { 62, "RSBBQ=", B0, FMT_OCT },
    { 63, "RSBBQ+1=", B0, FMT_OCT },
    { -1 }, { -1 },
    { 64, "OMEGAP=", 45, FMT_SP },
    { 65, "OMEGAQ=", 45, FMT_SP },
    { 66, "OMEGAR=", 45, FMT_SP },
    { -1 },
    { 68, "CDUXD=", 360, FMT_SP },
    { 69, "CDUYD=", 360, FMT_SP },
    { 70, "CDUZD=", 360, FMT_SP },
    { -1 },
    { 72, "CDUX=", 360, FMT_SP },
    { 73, "CDUY=", 360, FMT_SP },
    { 74, "CDUZ=", 360, FMT_SP },
    { 75, "CDUT=", 360, FMT_SP },
    { 76, "STATE=", B0, FMT_2OCT },
    { 78, "STATE+2=", B0, FMT_2OCT },
    { 80, "STATE+4=", B0, FMT_2OCT },
    { 82, "STATE+6=", B0, FMT_2OCT },
    { 84, "STATE+8=", B0, FMT_2OCT },
    { 86, "STATE+10=", B0, FMT_2OCT },
    { -1 }, { -1 },
    { 88, "DSPTB=", B0, FMT_OCT },
    { 90, "DSPTB+2=", B0, FMT_2OCT },
    { 92, "DSPTB+4=", B0, FMT_2OCT },
    { 94, "DSPTB+6=", B0, FMT_2OCT },
    { 96, "DSPTB+8=", B0, FMT_2OCT },
    { 98, "DSPTB+10=", B0, FMT_2OCT },
    { -1 }, { -1 },
    { 102, "RN=", B29, FMT_DP },
    { 104, "RN+2=", B29, FMT_DP },
    { 106, "RN+4=", B29, FMT_DP },
    { -1 },
    { 108, "VN=", B7, FMT_DP },
    { 110, "VN+2=", B7, FMT_DP },
    { 112, "VN+4=", B7, FMT_DP },
    { 114, "PIPTIME=", B28, FMT_DP },
    { 116, "OMEGAPD=", 45, FMT_SP },
    { 117, "OMEGAQD=", 45, FMT_SP },
    { 118, "OMEGARD=", 45, FMT_SP },
    { -1 },
    { 120, "CADRFLSH=", B0, FMT_OCT },
    { 121, "CADRFLSH+1=", B0, FMT_OCT },
    { 122, "CADRFLSH+2=", B0, FMT_OCT },
    { -1 },
    { 123, "FAILREG=", B0, FMT_OCT },
    { 124, "FAILREG+1=", B0, FMT_OCT },
    { 125, "FAILREG+2=", B0, FMT_OCT },
    { -1 },
    { 126, "RADMODES=", B0, FMT_OCT },
    { 127, "DAPBOOLS=", B0, FMT_OCT },
    { -1 }, { -1 },
    { 128, "POSTORKU=", 32, FMT_DEC },
    { 129, "NEGTORKU=", 32, FMT_DEC },
    { 130, "POSTORKV=", 32, FMT_DEC },
    { 131, "NEGTORKV=", 32, FMT_DEC },
    { 134, "TCDH=", B28, FMT_DP },
    { 136, "DELVEET2=", B7, FMT_DP },
    { 138, "DELVEET2+2=", B7, FMT_DP },
    { 140, "DELVEET2+4=", B7, FMT_DP },
    { 142, "TTPI=", B28, FMT_DP },
    { 144, "DELVEET3=", B7, FMT_DP },
    { 146, "DELVEET3+2=", B7, FMT_DP },
    { 148, "DELVEET3+4=", B7, FMT_DP },
    { 150, "DNRRANGE=", B0, FMT_SP, &FormatRrRange },
    { 151, "DNRRDOT=", B0, FMT_SP, &FormatRrRangeRate },
    { -1 }, { -1 },
    { 152, "DNLRVELX=", B27, FMT_SP, &FormatLrVx },
    { 153, "DNLRVELY=", B27, FMT_SP, &FormatLrVy },
    { 154, "DNLRVELZ=", B27, FMT_SP, &FormatLrVz },
    { 155, "DNLRALT=", B27, FMT_SP, &FormatLrRange },
    { 156, "DIFFALT=", B29, FMT_DP },
    { 158, "LEMMASS=", B16, FMT_SP },
    { 159, "CSMMASS=", B16, FMT_SP },
    { -1 },
    { 160, "IMODES30=", B0, FMT_OCT },
    { 161, "IMODES33=", B0, FMT_OCT },
    { -1 }, { -1 },
    { 162, "TIG=", B28, FMT_DP },    
    { 164, "OMEGAP=", 45, FMT_SP },
    { 165, "OMEGAQ=", 45, FMT_SP },
    { 166, "OMEGAR=", 45, FMT_SP },
    { 176, "ALPHAQ=", 90, FMT_SP },
    { 177, "ALPHAR=", 90, FMT_SP },
    { 178, "POSTORKP=", 32, FMT_DEC },
    { 179, "NEGTORKP=", 32, FMT_DEC },
    { 180, "CHN11,12=", B0, FMT_2OCT },
    { 182, "CHN13,14=", B0, FMT_2OCT },
    { 184, "CHN30,31=", B0, FMT_2OCT },
    { 186, "CHN32,33=", B0, FMT_2OCT },
    { 188, "PIPTIME1=", B28, FMT_DP },
    { 190, "DELV=", B14, FMT_DP },
    { 192, "DELV+2=", B14, FMT_DP },
    { 194, "DELV+4=", B14, FMT_DP },
    { 198, "TGO=", B28, FMT_DP }
  }
};

static DownlinkListSpec_t CmCoastAlignSpec = {
  "CM Coast Align downlink list",
  {
    { 0, "ID=", B0, FMT_OCT },
    { 1, "SYNC=", B0, FMT_OCT },
    { 100, "TIME=", B28, FMT_DP },
    { -1 },
    { 2, "RN=", B29, FMT_DP },
    { 4, "RN+2=", B29, FMT_DP },
    { 6, "RN+4=", B29, FMT_DP },
    { -1 },
    { 8, "VN=", B7, FMT_DP },
    { 10, "VN+2=", B7, FMT_DP },
    { 12, "VN+4=", B7, FMT_DP },
    { 14, "PIPTIME=", B28, FMT_DP },
    { 16, "CDUX=", 360, FMT_SP },
    { 17, "CDUY=", 360, FMT_SP },
    { 18, "CDUZ=", 360, FMT_SP },
    { 19, "CDUT=", B0, FMT_2OCT },	// Confused about this one.
    { 20, "ADOT=", 450, FMT_DP, &FormatAdotsOrOga },
    { 22, "ADOT+2=", 450, FMT_DP, &FormatAdotsOrOga },
    { 24, "ADOT+4=", 450, FMT_DP, &FormatAdotsOrOga },
    { -1 },
    { 26, "AK=", 180, FMT_SP },
    { 27, "AK1=", 180, FMT_SP },
    { 28, "AK2=", 180, FMT_SP }, 
    { 29, "RCSFLAGS=", B0, FMT_OCT },
    { 30, "THETADX=", 360, FMT_USP },
    { 31, "THETADY=", 360, FMT_USP },
    { 32, "THETADZ=", 360, FMT_USP },
    { 34, "TIG=", B28, FMT_DP },
    { 36, "BESTI=", 6, FMT_DEC },
    { 37, "BESTJ=", 6, FMT_DEC },
    { 38, "MARKDOWN=", B28, FMT_DP },
    { 40, "MARKDOWN+2=", 360, FMT_USP },
    { 41, "MARKDOWN+3=", 360, FMT_USP },
    { 42, "MARKDOWN+4=", 360, FMT_USP },
    { 43, "MARKDOWN+5=", 360, FMT_USP },
    { 44, "MARKDOWN+6=", 45, FMT_SP, &FormatOTRUNNION },
    { 46, "MARK2DWN=", B28, FMT_DP },
    { 48, "MARK2DWN+2=", 360, FMT_USP },
    { 49, "MARK2DWN+3=", 360, FMT_USP },
    { 50, "MARK2DWN+4=", 360, FMT_USP },
    { 51, "MARK2DWN+5=", 360, FMT_USP },
    { 52, "MARK2DWN+6=", 45, FMT_SP, &FormatOTRUNNION },
    { 54, "HAPOX=", B29, FMT_DP },
    { 56, "HPERX=", B29, FMT_DP },
    { 58, "DELTAR=", 360, FMT_DP },		// Differs between Colossus 1 & 3
    { 58, "PACTOFF=", B14, FMT_SP, &FormatXACTOFF },
    { 59, "YACTOFF=", B14, FMT_SP, &FormatXACTOFF },
    { 60, "VGTIG=", B7, FMT_DP },
    { 62, "VGTIG+2=", B7, FMT_DP },
    { 64, "VGTIG+4=", B7, FMT_DP },
    { 66, "REFSMMAT=", 2, FMT_DP },
    { 68, "REFSMMAT+2=", 2, FMT_DP },
    { 70, "REFSMMAT+4=", 2, FMT_DP },
    { 72, "REFSMMAT+6=", 2, FMT_DP },
    { 74, "REFSMMAT+8=", 2, FMT_DP },
    { 76, "REFSMMAT+10=", 2, FMT_DP },
    { 78, "STATE=", B0, FMT_2OCT },
    { 80, "STATE+2=", B0, FMT_2OCT },
    { 82, "STATE+4=", B0, FMT_2OCT },
    { 84, "STATE+6=", B0, FMT_2OCT },
    { 86, "STATE+8=", B0, FMT_2OCT },
    { -1 },
    { 88, "DSPTB=", B0, FMT_OCT },
    { 90, "DSPTB+2=", B0, FMT_2OCT },
    { 92, "DSPTB+4=", B0, FMT_2OCT },
    { 94, "DSPTB+6=", B0, FMT_2OCT },
    { 96, "DSPTB+8=", B0, FMT_2OCT },
    { 98, "DSPTB+10=", B0, FMT_2OCT },
    { 102, "R-OTHER=", B29, FMT_DP },
    { 104, "R-OTHER+2=", B29, FMT_DP },
    { 106, "R-OTHER+4=", B29, FMT_DP },
    { -1 },
    { 108, "V-OTHER=", B7, FMT_DP },
    { 110, "V-OTHER+2=", B7, FMT_DP },
    { 112, "V-OTHER+4=", B7, FMT_DP },
    { 114, "T-OTHER=", B28, FMT_DP },
    { 126, "OPTION1=", B0, FMT_OCT },	// Don't know what this is.
    { 127, "OPTION2=", B0, FMT_OCT },	// .. or this
    { 128, "TET=", B28, FMT_DP },	// ... or this
    { 134, "RSBBQ=", B0, FMT_2OCT },
    { 137, "CHAN77=", B0, FMT_OCT },
    { 138, "C31FLWRD=", B0, FMT_OCT },
    { -1 }, { -1 },
    { 139, "FAILREG=", B0, FMT_OCT },
    { 140, "FAILREG+1=", B0, FMT_OCT },
    { 141, "FAILREG+2=", B0, FMT_OCT },
    { 142, "CDUS=", 360, FMT_SP },
    { 143, "PIPAX=", B14, FMT_SP },
    { 144, "PIPAY=", B14, FMT_SP },
    { 145, "PIPAZ=", B14, FMT_SP },
    { -1 },
    { 146, "OGC=", 360, FMT_DP },
    { 148, "IGC=", 360, FMT_DP },
    { 150, "MGC=", 360, FMT_DP },
    { 152, "STATE+10=", B0, FMT_2OCT },
    { 154, "TEVENT=", B28, FMT_DP },
    { 156, "LAUNCHAZ=", 360, FMT_DP },
    { 158, "OPTMODES=", B0, FMT_OCT },
    { 159, "HOLDFLAG=", B0, FMT_DEC },
    { 160, "LEMMASS=", B16, FMT_SP },
    { 161, "CSMMASS=", B16, FMT_SP },
    { 162, "DAPDATR1=", B0, FMT_OCT },
    { 163, "DAPDATR2=", B0, FMT_OCT },
    { 164, "ERRORX=", 180, FMT_SP },
    { 165, "ERRORY=", 180, FMT_SP },
    { 166, "ERRORZ=", 180, FMT_SP },
    { -1 },
    { 168, "WBODY=", 450, FMT_DP, &FormatAdotsOrOga },
    { 170, "WBODY+2=", 450, FMT_DP, &FormatAdotsOrOga },
    { 172, "WBODY+4=", 450, FMT_DP, &FormatAdotsOrOga },
    { 174, "REDOCTR=", B0, FMT_DEC },
    { 175, "THETAD=", 360, FMT_SP },
    { 176, "THETAD+1=", 360, FMT_SP },
    { 177, "THETAD+2=", 360, FMT_SP },
    { -1 },
    { 178, "IMODES30=", B0, FMT_OCT },
    { 179, "IMODES33=", B0, FMT_OCT },
    { -1 },
    { -1 },
    { 180, "CHN11,12=", B0, FMT_2OCT },
    { 182, "CHN13,14=", B0, FMT_2OCT },
    { 184, "CHN30,31=", B0, FMT_2OCT },
    { 186, "CHN32,33=", B0, FMT_2OCT }
  }
};

static DownlinkListSpec_t LmCoastAlignSpec = {
  "LM Coast Align downlink list",
  {
    { 0, "ID=", B0, FMT_OCT },
    { 1, "SYNC=", B0, FMT_OCT },
    { 100, "TIME=", B28, FMT_DP },
    { -1 },
    { 2, "R-OTHER=", B29, FMT_DP },
    { 4, "R-OTHER+2=", B29, FMT_DP },
    { 6, "R-OTHER+4=", B29, FMT_DP },
    { -1 },
    { 8, "V-OTHER=", B7, FMT_DP },
    { 10, "V-OTHER+2=", B7, FMT_DP },
    { 12, "V-OTHER+4=", B7, FMT_DP },
    { 14, "T-OTHER=", B28, FMT_DP },
    { 16, "AGSK=", B28, FMT_DP },
    { 18, "TALIGN=", B28, FMT_DP },
    { -1 }, { -1 },
    { 20, "POSTORKU=", 32, FMT_DEC },
    { 21, "NEGTORKU=", 32, FMT_DEC },
    { 22, "POSTORKV=", 32, FMT_DEC },
    { 23, "NEGTORKV=", 32, FMT_DEC },
    { 24, "DNRRANGE=", B0, FMT_SP, &FormatRrRange },
    { 25, "DNRRDOT=", B0, FMT_SP, &FormatRrRangeRate },
    { 26, "TEVENT=", B28, FMT_DP },
    { -1 },
    { 28, "REFSMMAT=", B0, FMT_DP },
    { 30, "REFSMMAT+2=", B0, FMT_DP },
    { 32, "REFSMMAT+4=", B0, FMT_DP },
    { 34, "REFSMMAT+6=", B0, FMT_DP },
    { 36, "REFSMMAT+8=", B0, FMT_DP },
    { 38, "REFSMMAT+10=", B0, FMT_DP },
    { -1 }, { -1 },
    { 40, "AOTCODE=", B0, FMT_OCT },
    { 42, "RLS=", B27, FMT_DP },
    { 44, "RLS+2=", B27, FMT_DP },
    { 46, "RLS+4=", B27, FMT_DP },
    { 48, "DNLRVELX=", B27, FMT_SP, &FormatLrVx },
    { 49, "DNLRVELY=", B27, FMT_SP, &FormatLrVy },
    { 50, "DNLRVELZ=", B27, FMT_SP, &FormatLrVz },
    { 51, "DNLRALT=", B27, FMT_SP, &FormatLrRange },
    { 52, "VGTIG=", B7, FMT_DP },
    { 54, "VGTIG+2=", B7, FMT_DP },
    { 56, "VGTIG+4=", B7, FMT_DP },
    // Same as LM Orbital Maneuvers.
    { 58, "REDOCTR=", B0, FMT_DEC },
    { 59, "THETAD=", 360, FMT_SP },
    { 60, "THETAD+1=", 360, FMT_SP },
    { 61, "THETAD+2=", 360, FMT_SP },
    { -1 },
    { 62, "RSBBQ=", B0, FMT_OCT },
    { 63, "RSBBQ+1=", B0, FMT_OCT },
    { -1 }, { -1 },
    { 64, "OMEGAP=", 45, FMT_SP },
    { 65, "OMEGAQ=", 45, FMT_SP },
    { 66, "OMEGAR=", 45, FMT_SP },
    { -1 },
    { 68, "CDUXD=", 360, FMT_SP },
    { 69, "CDUYD=", 360, FMT_SP },
    { 70, "CDUZD=", 360, FMT_SP },
    { -1 },
    { 72, "CDUX=", 360, FMT_SP },
    { 73, "CDUY=", 360, FMT_SP },
    { 74, "CDUZ=", 360, FMT_SP },
    { 75, "CDUT=", 360, FMT_SP },
    { 76, "STATE=", B0, FMT_2OCT },
    { 78, "STATE+2=", B0, FMT_2OCT },
    { 80, "STATE+4=", B0, FMT_2OCT },
    { 82, "STATE+6=", B0, FMT_2OCT },
    { 84, "STATE+8=", B0, FMT_2OCT },
    { 86, "STATE+10=", B0, FMT_2OCT },
    { -1 }, { -1 },
    { 88, "DSPTB=", B0, FMT_OCT },
    { 90, "DSPTB+2=", B0, FMT_2OCT },
    { 92, "DSPTB+4=", B0, FMT_2OCT },
    { 94, "DSPTB+6=", B0, FMT_2OCT },
    { 96, "DSPTB+8=", B0, FMT_2OCT },
    { 98, "DSPTB+10=", B0, FMT_2OCT },
    { -1 }, { -1 },
    { 102, "RN=", B29, FMT_DP },
    { 104, "RN+2=", B29, FMT_DP },
    { 106, "RN+4=", B29, FMT_DP },
    { -1 },
    { 108, "VN=", B7, FMT_DP },
    { 110, "VN+2=", B7, FMT_DP },
    { 112, "VN+4=", B7, FMT_DP },
    { 114, "PIPTIME=", B28, FMT_DP },
    { 116, "OMEGAPD=", 45, FMT_SP },
    { 117, "OMEGAQD=", 45, FMT_SP },
    { 118, "OMEGARD=", 45, FMT_SP },
    { -1 },
    { 120, "CADRFLSH=", B0, FMT_OCT },
    { 121, "CADRFLSH+1=", B0, FMT_OCT },
    { 122, "CADRFLSH+2=", B0, FMT_OCT },
    { -1 },
    { 123, "FAILREG=", B0, FMT_OCT },
    { 124, "FAILREG+1=", B0, FMT_OCT },
    { 125, "FAILREG+2=", B0, FMT_OCT },
    { -1 },
    { 126, "RADMODES=", B0, FMT_OCT },
    { 127, "DAPBOOLS=", B0, FMT_OCT },
    //  
    { -1 }, { -1 },
    { 128, "OGC=", 360, FMT_DP },
    { 130, "IGC=", 360, FMT_DP },
    { 132, "MGC=", 360, FMT_DP },
    { -1 },
    { 134, "BESTI=", 6, FMT_DEC },
    { 135, "BESTJ=", 6, FMT_DEC },
    { 136, "STARSAV1=", 2, FMT_DP },	// Fix later.  
    { 138, "STARSAV1+2=", 2, FMT_DP },	// Fix later.  
    { 140, "STARSAV1+4=", 2, FMT_DP },	// Fix later.  
    { 142, "STARSAV2=", 2, FMT_DP },	// Fix later.  
    { 144, "STARSAV2+2=", 2, FMT_DP },	// Fix later.  
    { 146, "STARSAV2+4=", 2, FMT_DP },	// Fix later.  
    { 152, "CDUS=", 360, FMT_SP },
    { 153, "PIPAX=", B14, FMT_SP },
    { 154, "PIPAY=", B14, FMT_SP },
    { 155, "PIPAZ=", B14, FMT_SP },
    { 156, "LASTYCMD=", B0, FMT_OCT },
    { 157, "LASTXCMD=", B0, FMT_OCT },
    { 158, "LEMMASS=", B16, FMT_SP },
    { 159, "CSMMASS=", B16, FMT_SP },
    { 160, "IMODES30=", B0, FMT_OCT },
    { 161, "IMODES33=", B0, FMT_OCT },
    { 162, "TIG=", B28, FMT_DP },    
    { -1 },
    { 176, "ALPHAQ=", 90, FMT_SP },
    { 177, "ALPHAR=", 90, FMT_SP },
    { 178, "POSTORKP=", 32, FMT_DEC },
    { 179, "NEGTORKP=", 32, FMT_DEC },
    { 180, "CHN11,12=", B0, FMT_2OCT },
    { 182, "CHN13,14=", B0, FMT_2OCT },
    { 184, "CHN30,31=", B0, FMT_2OCT },
    { 186, "CHN32,33=", B0, FMT_2OCT }
  }
};

static DownlinkListSpec_t CmRendezvousPrethrustSpec = {
  "CM Rendezvous/Prethrust downlink list",
  {
    { 0, "ID=", B0, FMT_OCT },
    { 1, "SYNC=", B0, FMT_OCT },
    { 100, "TIME=", B28, FMT_DP },
    { -1 },
    { 2, "RN=", B29, FMT_DP },
    { 4, "RN+2=", B29, FMT_DP },
    { 6, "RN+4=", B29, FMT_DP },
    { -1 },
    { 8, "VN=", B7, FMT_DP },
    { 10, "VN+2=", B7, FMT_DP },
    { 12, "VN+4=", B7, FMT_DP },
    { 14, "PIPTIME=", B28, FMT_DP },
    { 16, "CDUX=", 360, FMT_SP },
    { 17, "CDUY=", 360, FMT_SP },
    { 18, "CDUZ=", 360, FMT_SP },
    { 19, "CDUT=", B0, FMT_2OCT },	// Confused about this one.
    { 20, "ADOT=", 450, FMT_DP, &FormatAdotsOrOga },
    { 22, "ADOT+2=", 450, FMT_DP, &FormatAdotsOrOga },
    { 24, "ADOT+4=", 450, FMT_DP, &FormatAdotsOrOga },
    { -1 },
    { 26, "AK=", 180, FMT_SP },
    { 27, "AK1=", 180, FMT_SP },
    { 28, "AK2=", 180, FMT_SP }, 
    { 29, "RCSFLAGS=", B0, FMT_OCT },
    { 30, "THETADX=", 360, FMT_USP },
    { 31, "THETADY=", 360, FMT_USP },
    { 32, "THETADZ=", 360, FMT_USP },
    { 34, "TIG=", B28, FMT_DP },
    { 36, "DELLT4=", B28, FMT_DP },
    { 38, "RTARG=", B29, FMT_DP },
    { 40, "RTARG+2=", B29, FMT_DP },
    { 42, "RTARG+4=", B29, FMT_DP },
    { 44, "VHFTIME=", B28, FMT_DP },
    { -1 },
    { 46, "MARKDOWN=", B28, FMT_DP },
    { 48, "MARKDOWN+2=", 360, FMT_USP },
    { 49, "MARKDOWN+3=", 360, FMT_USP },
    { 50, "MARKDOWN+4=", 360, FMT_USP },
    { 51, "MARKDOWN+5=", 360, FMT_USP },
    { 52, "MARKDOWN+6=", 45, FMT_SP, &FormatOTRUNNION },
    { 53, "RM=", 100, FMT_DEC },
    { 54, "VHFCNT=", B0, FMT_DEC },
    { 55, "TRKMKCNT=", B0, FMT_DEC },
    { 56, "TTPI=", B28, FMT_DP },
    { 58, "ECSTEER=", 4, FMT_SP },
    { 60, "DELVTPF=", B7, FMT_DP },
    { 62, "TCDH=", B28, FMT_DP },
    { 64, "TCSI=", B28, FMT_DP },
    { 66, "TPASS4=", B28, FMT_DP },
    { 68, "DELVSLV=", B7, FMT_DP },
    { 70, "DELVSLV+2=", B7, FMT_DP },
    { 72, "DELVSLV+4=", B7, FMT_DP },
    { 74, "RANGE=", B29, FMT_DP },
    { 76, "RRATE=", B7, FMT_DP },
    { -1 }, { -1 },
    { 78, "STATE=", B0, FMT_2OCT },
    { 80, "STATE+2=", B0, FMT_2OCT },
    { 82, "STATE+4=", B0, FMT_2OCT },
    { 84, "STATE+6=", B0, FMT_2OCT },
    { 86, "STATE+8=", B0, FMT_2OCT },
    { -1 },
    { 88, "DSPTB=", B0, FMT_OCT },
    { 90, "DSPTB+2=", B0, FMT_2OCT },
    { 92, "DSPTB+4=", B0, FMT_2OCT },
    { 94, "DSPTB+6=", B0, FMT_2OCT },
    { 96, "DSPTB+8=", B0, FMT_2OCT },
    { 98, "DSPTB+10=", B0, FMT_2OCT },
    { 102, "R-OTHER=", B29, FMT_DP },
    { 104, "R-OTHER+2=", B29, FMT_DP },
    { 106, "R-OTHER+4=", B29, FMT_DP },
    { -1 },
    { 108, "V-OTHER=", B7, FMT_DP },
    { 110, "V-OTHER+2=", B7, FMT_DP },
    { 112, "V-OTHER+4=", B7, FMT_DP },
    { 114, "T-OTHER=", B28, FMT_DP },
    { 126, "OPTION1=", B0, FMT_OCT },	// Don't know what this is.
    { 127, "OPTION2=", B0, FMT_OCT },	// .. or this
    { 128, "TET=", B28, FMT_DP },	// ... or this
    { 134, "RSBBQ=", B0, FMT_2OCT },
    { 137, "CHAN77=", B0, FMT_OCT },
    { 138, "C31FLWRD=", B0, FMT_OCT },
    { -1 }, { -1 },
    { 139, "FAILREG=", B0, FMT_OCT },
    { 140, "FAILREG+1=", B0, FMT_OCT },
    { 141, "FAILREG+2=", B0, FMT_OCT },
    { 142, "CDUS=", 360, FMT_SP },
    { 143, "PIPAX=", B14, FMT_SP },
    { 144, "PIPAY=", B14, FMT_SP },
    { 145, "PIPAZ=", B14, FMT_SP }, 
    { 146, "DIFFALT=", B0, FMT_2DEC },	// Don't yet know the scaling of this.
    { 148, "CENTANG=", 360, FMT_DP },
    { 152, "DELVEET3=", B7, FMT_DP },
    { 154, "DELVEET3+2=", B7, FMT_DP },
    { 156, "DELVEET3+4=", B7, FMT_DP },    
    { 158, "OPTMODES=", B0, FMT_OCT },
    { 159, "HOLDFLAG=", B0, FMT_DEC },
    { 160, "LEMMASS=", B16, FMT_SP },
    { 161, "CSMMASS=", B16, FMT_SP },
    { 162, "DAPDATR1=", B0, FMT_OCT },
    { 163, "DAPDATR2=", B0, FMT_OCT },
    { -1 }, { -1 },
    { 164, "ERRORX=", 180, FMT_SP },
    { 165, "ERRORY=", 180, FMT_SP },
    { 166, "ERRORZ=", 180, FMT_SP },
    { -1 },
    { 168, "WBODY=", 450, FMT_DP, &FormatAdotsOrOga },
    { 170, "WBODY+2=", 450, FMT_DP, &FormatAdotsOrOga },
    { 172, "WBODY+4=", 450, FMT_DP, &FormatAdotsOrOga },
    { 174, "REDOCTR=", B0, FMT_DEC },
    { 175, "THETAD=", 360, FMT_SP },
    { 176, "THETAD+1=", 360, FMT_SP },
    { 177, "THETAD+2=", 360, FMT_SP },
    { -1 },
    { 178, "IMODES30=", B0, FMT_OCT },
    { 179, "IMODES33=", B0, FMT_OCT },
    { -1 },
    { -1 },
    { 180, "CHN11,12=", B0, FMT_2OCT },
    { 182, "CHN13,14=", B0, FMT_2OCT },
    { 184, "CHN30,31=", B0, FMT_2OCT },
    { 186, "CHN32,33=", B0, FMT_2OCT },
    { 188, "RTHETA=", 360, FMT_DP },
    { 190, "LAT(SPL)=", 360, FMT_DP },
    { 192, "LNG(SPL)=", 360, FMT_DP },
    { 194, "VPRED=", B7, FMT_DP },
    { 196, "GAMMAEI=", 360, FMT_DP },
    { 198, "STATE+10=", B0, FMT_2OCT }
  }
};

static DownlinkListSpec_t LmRendezvousPrethrustSpec = {
  "LM Rendezvous/Prethrust downlink list",
  {
    { 0, "ID=", B0, FMT_OCT },
    { 1, "SYNC=", B0, FMT_OCT },
    { 100, "TIME=", B28, FMT_DP },
    { -1 },
    { 2, "R-OTHER=", B29, FMT_DP },
    { 4, "R-OTHER+2=", B29, FMT_DP },
    { 6, "R-OTHER+4=", B29, FMT_DP },
    { -1 },
    { 8, "V-OTHER=", B7, FMT_DP },
    { 10, "V-OTHER+2=", B7, FMT_DP },
    { 12, "V-OTHER+4=", B7, FMT_DP },
    { 14, "T-OTHER=", B28, FMT_DP },
    { 16, "RANGRDOT=", B0, FMT_2OCT },	// Look at this later.
    { -1 }, { -1 }, { -1 },
    { 18, "AIG=", 360, FMT_SP },
    { 19, "AMG=", 360, FMT_SP },
    { 20, "AOG=", 360, FMT_SP },
    { 21, "TRKMKCNT=", B0, FMT_DEC },
    { 22, "TANGNB=", 360, FMT_SP },
    { 23, "TANGNB+1=", 360, FMT_SP },
    { 24, "MARKTIME=", B28, FMT_DP },
    { -1 },
    { 26, "DELLT4=", B28, FMT_DP },
    { 28, "RTARGX=", B29, FMT_DP },
    { 30, "RTARGY=", B29, FMT_DP },
    { 32, "RTARGZ=", B29, FMT_DP },
    { 34, "DELVSLV=", B7, FMT_DP },   
    { 36, "DELVSLV+2=", B7, FMT_DP },   
    { 38, "DELVSLV+4=", B7, FMT_DP }, 
    { -1 },
    { 40, "TCSI=", B28, FMT_DP },
    { 42, "DELVEET1=", B7, FMT_DP },
    { 44, "DELVEET1+2=", B7, FMT_DP },
    { 46, "DELVEET1+4=", B7, FMT_DP },
    { 50, "TTPF=", B28, FMT_DP },
    { 52, "X789=", B5, FMT_SP, FormatEarthOrMoonDP },
    { 54, "X789+2=", B5, FMT_SP, FormatEarthOrMoonDP },
    { -1 },
    { 56, "LASTYCMD=", B0, FMT_DEC },
    { 57, "LASTXCMD=", B0, FMT_DEC },
    { 58, "REDOCTR=", B0, FMT_DEC },
    { -1 },
    { 59, "THETAD=", 360, FMT_SP },
    { 60, "THETAD+1=", 360, FMT_SP },
    { 61, "THETAD+2=", 360, FMT_SP },
    { -1 },
    { 62, "RSBBQ=", B0, FMT_OCT },
    { 63, "RSBBQ+1=", B0, FMT_OCT },
    { -1 }, { -1 },
    { 64, "OMEGAP=", 45, FMT_SP },
    { 65, "OMEGAQ=", 45, FMT_SP },
    { 66, "OMEGAR=", 45, FMT_SP },
    { -1 },
    { 68, "CDUXD=", 360, FMT_SP },
    { 69, "CDUYD=", 360, FMT_SP },
    { 70, "CDUZD=", 360, FMT_SP },
    { -1 },
    { 72, "CDUX=", 360, FMT_SP },
    { 73, "CDUY=", 360, FMT_SP },
    { 74, "CDUZ=", 360, FMT_SP },
    { 75, "CDUT=", 360, FMT_SP },
    { 76, "STATE=", B0, FMT_2OCT },
    { 78, "STATE+2=", B0, FMT_2OCT },
    { 80, "STATE+4=", B0, FMT_2OCT },
    { 82, "STATE+6=", B0, FMT_2OCT },
    { 84, "STATE+8=", B0, FMT_2OCT },
    { 86, "STATE+10=", B0, FMT_2OCT },
    { -1 }, { -1 },
    { 88, "DSPTB=", B0, FMT_OCT },
    { 90, "DSPTB+2=", B0, FMT_2OCT },
    { 92, "DSPTB+4=", B0, FMT_2OCT },
    { 94, "DSPTB+6=", B0, FMT_2OCT },
    { 96, "DSPTB+8=", B0, FMT_2OCT },
    { 98, "DSPTB+10=", B0, FMT_2OCT },
    { -1 }, { -1 },
    { 102, "RN=", B29, FMT_DP },
    { 104, "RN+2=", B29, FMT_DP },
    { 106, "RN+4=", B29, FMT_DP },
    { -1 },
    { 108, "VN=", B7, FMT_DP },
    { 110, "VN+2=", B7, FMT_DP },
    { 112, "VN+4=", B7, FMT_DP },
    { 114, "PIPTIME=", B28, FMT_DP },
    { 116, "OMEGAPD=", 45, FMT_SP },
    { 117, "OMEGAQD=", 45, FMT_SP },
    { 118, "OMEGARD=", 45, FMT_SP },
    { -1 },
    { 120, "CADRFLSH=", B0, FMT_OCT },
    { 121, "CADRFLSH+1=", B0, FMT_OCT },
    { 122, "CADRFLSH+2=", B0, FMT_OCT },
    { -1 },
    { 123, "FAILREG=", B0, FMT_OCT },
    { 124, "FAILREG+1=", B0, FMT_OCT },
    { 125, "FAILREG+2=", B0, FMT_OCT },
    { -1 },
    { 126, "RADMODES=", B0, FMT_OCT },
    { 127, "DAPBOOLS=", B0, FMT_OCT },
    { -1 }, { -1 },
    { 128, "POSTORKU=", 32, FMT_DEC },
    { 129, "NEGTORKU=", 32, FMT_DEC },
    { 130, "POSTORKV=", 32, FMT_DEC },
    { 131, "NEGTORKV=", 32, FMT_DEC },
    { 134, "TCDH=", B28, FMT_DP },
    { 136, "DELVEET2=", B7, FMT_DP },
    { 138, "DELVEET2+2=", B7, FMT_DP },
    { 140, "DELVEET2+4=", B7, FMT_DP },
    { 142, "TTPI=", B28, FMT_DP },
    { 144, "DELVEET3=", B7, FMT_DP },
    { 146, "DELVEET3+2=", B7, FMT_DP },
    { 148, "DELVEET3+4=", B7, FMT_DP },
    { 150, "ELEV=", 360, FMT_DP },
    { 152, "CDUS=", 360, FMT_SP },
    { -1 }, { -1 },
    { 153, "PIPAX=", B14, FMT_SP },
    { 154, "PIPAY=", B14, FMT_SP },
    { 155, "PIPAZ=", B14, FMT_SP },
    { -1 },
    { 156, "LASTYCMD=", B0, FMT_OCT },
    { 157, "LASTXCMD=", B0, FMT_OCT },
    { 158, "LEMMASS=", B16, FMT_SP },
    { 159, "CSMMASS=", B16, FMT_SP },
    { 160, "IMODES30=", B0, FMT_OCT },
    { 161, "IMODES33=", B0, FMT_OCT },
    { -1 }, { -1 },
    { 162, "TIG=", B28, FMT_DP },    
    { 164, "OMEGAP=", 45, FMT_SP },
    { 165, "OMEGAQ=", 45, FMT_SP },
    { 166, "OMEGAR=", 45, FMT_SP },
    { 176, "ALPHAQ=", 90, FMT_SP },
    { 177, "ALPHAR=", 90, FMT_SP },
    { 178, "POSTORKP=", 32, FMT_DEC },
    { 179, "NEGTORKP=", 32, FMT_DEC },
    { 180, "CHN11,12=", B0, FMT_2OCT },
    { 182, "CHN13,14=", B0, FMT_2OCT },
    { 184, "CHN30,31=", B0, FMT_2OCT },
    { 186, "CHN32,33=", B0, FMT_2OCT },
    { 190, "CENTANG=", 360, FMT_DP },
    { 192, "NN=", B0, FMT_DEC },
    { 194, "DIFFALT=", B29, FMT_DP },
    { 196, "DELVTPF=", B7, FMT_DP }
  }
};

static DownlinkListSpec_t CmProgram22Spec = {
  "CM Program 22 downlink list",
  {
    { 0, "ID=", B0, FMT_OCT },
    { 1, "SYNC=", B0, FMT_OCT },
    { 100, "TIME=", B28, FMT_DP },
    { -1 },
    { 2, "RN=", B29, FMT_DP },
    { 4, "RN+2=", B29, FMT_DP },
    { 6, "RN+4=", B29, FMT_DP },
    { -1 },
    { 8, "VN=", B7, FMT_DP },
    { 10, "VN+2=", B7, FMT_DP },
    { 12, "VN+4=", B7, FMT_DP },
    { 14, "PIPTIME=", B28, FMT_DP },
    { 16, "CDUX=", 360, FMT_SP },
    { 17, "CDUY=", 360, FMT_SP },
    { 18, "CDUZ=", 360, FMT_SP },
    { 19, "CDUT=", B0, FMT_2OCT },	// Confused about this one.
    { 20, "ADOT=", 450, FMT_DP, &FormatAdotsOrOga },
    { 22, "ADOT+2=", 450, FMT_DP, &FormatAdotsOrOga },
    { 24, "ADOT+4=", 450, FMT_DP, &FormatAdotsOrOga },
    { -1 },
    { 26, "AK=", 180, FMT_SP },
    { 27, "AK1=", 180, FMT_SP },
    { 28, "AK2=", 180, FMT_SP }, 
    { 29, "RCSFLAGS=", B0, FMT_OCT },
    { 30, "THETADX=", 360, FMT_USP },
    { 31, "THETADY=", 360, FMT_USP },
    { 32, "THETADZ=", 360, FMT_USP },
    { -1 },
    { 34, "SVMRKDAT=", B28, FMT_DP },	// 1st mark
    { 36, "SVMRKDAT+2=", 360, FMT_USP },
    { 37, "SVMRKDAT+3=", 360, FMT_USP },
    { 38, "SVMRKDAT+4=", 360, FMT_USP },
    { 39, "SVMRKDAT+5=", 45, FMT_SP, &FormatOTRUNNION },
    { 40, "SVMRKDAT+6=", 360, FMT_USP },
    { 41, "SVMRKDAT+7=", B28, FMT_DP },	// 2nd mark
    { 43, "SVMRKDAT+9=", 360, FMT_USP },
    { 44, "SVMRKDAT+10=", 360, FMT_USP },
    { 45, "SVMRKDAT+11=", 360, FMT_USP },
    { 46, "SVMRKDAT+12=", 45, FMT_SP, &FormatOTRUNNION },
    { 47, "SVMRKDAT+13=", 360, FMT_USP },
    { 48, "SVMRKDAT+14=", B28, FMT_DP },// 3rd mark
    { 50, "SVMRKDAT+16=", 360, FMT_USP },
    { 51, "SVMRKDAT+17=", 360, FMT_USP },
    { 52, "SVMRKDAT+18=", 360, FMT_USP },
    { 53, "SVMRKDAT+19=", 45, FMT_SP, &FormatOTRUNNION },
    { 54, "SVMRKDAT+20=", 360, FMT_USP },
    { 55, "SVMRKDAT+21=", B28, FMT_DP },// 4th mark
    { 57, "SVMRKDAT+23=", 360, FMT_USP },
    { 58, "SVMRKDAT+24=", 360, FMT_USP },
    { 59, "SVMRKDAT+25=", 360, FMT_USP },
    { 60, "SVMRKDAT+26=", 45, FMT_SP, &FormatOTRUNNION },
    { 61, "SVMRKDAT+27=", 360, FMT_USP },
    { 62, "SVMRKDAT+28=", B28, FMT_DP },// 5th mark
    { 64, "SVMRKDAT+30=", 360, FMT_USP },
    { 65, "SVMRKDAT+31=", 360, FMT_USP },
    { 66, "SVMRKDAT+32=", 360, FMT_USP },
    { 67, "SVMRKDAT+33=", 45, FMT_SP, &FormatOTRUNNION },
    { 68, "SVMRKDAT+34=", 360, FMT_USP },
    { 70, "LANDMARK=", B0, FMT_OCT },
    { 78, "STATE=", B0, FMT_2OCT },
    { 80, "STATE+2=", B0, FMT_2OCT },
    { 82, "STATE+4=", B0, FMT_2OCT },
    { 84, "STATE+6=", B0, FMT_2OCT },
    { 86, "STATE+8=", B0, FMT_2OCT },
    { 88, "DSPTB=", B0, FMT_OCT },
    { 90, "DSPTB+2=", B0, FMT_2OCT },
    { 92, "DSPTB+4=", B0, FMT_2OCT },
    { 94, "DSPTB+6=", B0, FMT_2OCT },
    { 96, "DSPTB+8=", B0, FMT_2OCT },
    { 98, "DSPTB+10=", B0, FMT_2OCT },
    { 102, "LAT=", 360, FMT_DP },
    { 104, "LONG=", 360, FMT_DP },
    { 106, "ALT=", B29, FMT_DP },
    { 126, "OPTION1=", B0, FMT_OCT },	// Don't know what this is.
    { 127, "OPTION2=", B0, FMT_OCT },	// .. or this
    { 128, "TET=", B28, FMT_DP },	// ... or this
    { 134, "RSBBQ=", B0, FMT_2OCT },
    { 137, "CHAN77=", B0, FMT_OCT },
    { 138, "C31FLWRD=", B0, FMT_OCT },
    { -1 },
    { 139, "FAILREG=", B0, FMT_OCT },
    { 140, "FAILREG+1=", B0, FMT_OCT },
    { 141, "FAILREG+2=", B0, FMT_OCT },
    { 142, "CDUS=", 360, FMT_SP },
    { 143, "PIPAX=", B14, FMT_SP },
    { 144, "PIPAY=", B14, FMT_SP },
    { 145, "PIPAZ=", B14, FMT_SP },
    { 146, "8NN=", B0, FMT_DEC },
    { 152, "STATE+10=", B0, FMT_2OCT },
    { 154, "RLS=", B27, FMT_DP },
    { 156, "RLS+2=", B27, FMT_DP },
    { 158, "RLS+4=", B27, FMT_DP },
    { 158, "OPTMODES=", B0, FMT_OCT },
    { 159, "HOLDFLAG=", B0, FMT_DEC },
    { 160, "LEMMASS=", B16, FMT_SP },
    { 161, "CSMMASS=", B16, FMT_SP },
    { 162, "DAPDATR1=", B0, FMT_OCT },
    { 163, "DAPDATR2=", B0, FMT_OCT },
    { -1 }, { -1 },
    { 164, "ERRORX=", 180, FMT_SP },
    { 165, "ERRORY=", 180, FMT_SP },
    { 166, "ERRORZ=", 180, FMT_SP },
    { -1 },
    { 168, "WBODY=", 450, FMT_DP, &FormatAdotsOrOga },
    { 170, "WBODY+2=", 450, FMT_DP, &FormatAdotsOrOga },
    { 172, "WBODY+4=", 450, FMT_DP, &FormatAdotsOrOga },
    { 174, "REDOCTR=", B0, FMT_DEC },
    { 175, "THETAD=", 360, FMT_SP },
    { 176, "THETAD+1=", 360, FMT_SP },
    { 177, "THETAD+2=", 360, FMT_SP },
    { -1 },
    { 178, "IMODES30=", B0, FMT_OCT },
    { 179, "IMODES33=", B0, FMT_OCT },
    { -1 },
    { -1 },
    { 180, "CHN11,12=", B0, FMT_2OCT },
    { 182, "CHN13,14=", B0, FMT_2OCT },
    { 184, "CHN30,31=", B0, FMT_2OCT },
    { 186, "CHN32,33=", B0, FMT_2OCT },
  }
};

static DownlinkListSpec_t LmDescentAscentSpec = {
  "LM Descent/Ascent downlink list",
  {
    { 0, "ID=", B0, FMT_OCT },
    { 1, "SYNC=", B0, FMT_OCT },
    { 100, "TIME=", B28, FMT_DP },
    { -1 },
    { 2, "LRXCDUDL=", 360, FMT_SP },
    { 3, "LRYCDUDL=", 360, FMT_SP },
    { 4, "LRZCDUDL=", 360, FMT_SP },
    { -1 },
    { 6, "VSELECT=", B0, FMT_DEC },
    { 8, "LRVTIMDL=", B28, FMT_DP },
    { 10, "VMEAS=", B28, FMT_DP },
    { 12, "MKTIME=", B28, FMT_DP }, 
    { 14, "HMEAS=", B28, FMT_DP, &FormatHMEAS },
    { 16, "RANGRDOT=", B0, FMT_2OCT },	// Look at this later.
    { -1 }, { -1 },
    { 18, "AIG=", 360, FMT_SP },
    { 19, "AMG=", 360, FMT_SP },
    { 20, "AOG=", 360, FMT_SP },
    { 21, "TRKMKCNT=", B0, FMT_DEC },
    { 22, "TANGNB=", 360, FMT_SP },
    { 23, "TANGNB+1=", 360, FMT_SP },
    { 26, "TEVENT=", B28, FMT_DP },
    { -1 },
    { 28, "UNFC/2=", B0, FMT_DP },    
    { 30, "UNFC/2+2=", B0, FMT_DP },    
    { 32, "UNFC/2+4=", B0, FMT_DP },  
    { -1 },  
    { 34, "VGVECT=", B7, FMT_DP },    
    { 36, "VGVECT+2=", B0, FMT_DP },    
    { 38, "VGVECT+4=", B0, FMT_DP },  
    { -1 },  
    { 40, "TTF/8=", B17, FMT_DP },
    { 42, "DELTAH=", B24, FMT_DP },
    { -1 }, { -1 },
    { 44, "RLS=", B27, FMT_DP },
    { 46, "RLS+2=", B27, FMT_DP },
    { 48, "RLS+4=", B27, FMT_DP },
    { 50, "ZDOTD=", B7, FMT_DP },
    { 52, "X789=", B5, FMT_SP, FormatEarthOrMoonDP },
    { 54, "X789+2=", B5, FMT_SP, FormatEarthOrMoonDP },
    { -1 }, { -1 },
    { 56, "LASTYCMD=", B0, FMT_DEC },
    { 57, "LASTXCMD=", B0, FMT_DEC },
    { 58, "REDOCTR=", B0, FMT_DEC },
    { -1 },
    { 59, "THETAD=", 360, FMT_SP },
    { 60, "THETAD+1=", 360, FMT_SP },
    { 61, "THETAD+2=", 360, FMT_SP },
    { -1 },
    { 62, "RSBBQ=", B0, FMT_OCT },
    { 63, "RSBBQ+1=", B0, FMT_OCT },
    { -1 }, { -1 },
    { 64, "OMEGAP=", 45, FMT_SP },
    { 65, "OMEGAQ=", 45, FMT_SP },
    { 66, "OMEGAR=", 45, FMT_SP },
    { -1 },
    { 68, "CDUXD=", 360, FMT_SP },
    { 69, "CDUYD=", 360, FMT_SP },
    { 70, "CDUZD=", 360, FMT_SP },
    { -1 },
    { 72, "CDUX=", 360, FMT_SP },
    { 73, "CDUY=", 360, FMT_SP },
    { 74, "CDUZ=", 360, FMT_SP },
    { 75, "CDUT=", 360, FMT_SP },
    { 76, "STATE=", B0, FMT_2OCT },
    { 78, "STATE+2=", B0, FMT_2OCT },
    { 80, "STATE+4=", B0, FMT_2OCT },
    { 82, "STATE+6=", B0, FMT_2OCT },
    { 84, "STATE+8=", B0, FMT_2OCT },
    { 86, "STATE+10=", B0, FMT_2OCT },
    { -1 }, { -1 },
    { 88, "DSPTB=", B0, FMT_OCT },
    { 90, "DSPTB+2=", B0, FMT_2OCT },
    { 92, "DSPTB+4=", B0, FMT_2OCT },
    { 94, "DSPTB+6=", B0, FMT_2OCT },
    { 96, "DSPTB+8=", B0, FMT_2OCT },
    { 98, "DSPTB+10=", B0, FMT_2OCT },
    { -1 }, { -1 },
    { 102, "RN=", B29, FMT_DP },
    { 104, "RN+2=", B29, FMT_DP },
    { 106, "RN+4=", B29, FMT_DP },
    { -1 },
    { 108, "VN=", B7, FMT_DP },
    { 110, "VN+2=", B7, FMT_DP },
    { 112, "VN+4=", B7, FMT_DP },
    { 114, "PIPTIME=", B28, FMT_DP },
    { 116, "OMEGAPD=", 45, FMT_SP },
    { 117, "OMEGAQD=", 45, FMT_SP },
    { 118, "OMEGARD=", 45, FMT_SP },
    { -1 },
    { 120, "CADRFLSH=", B0, FMT_OCT },
    { 121, "CADRFLSH+1=", B0, FMT_OCT },
    { 122, "CADRFLSH+2=", B0, FMT_OCT },
    { -1 },
    { 123, "FAILREG=", B0, FMT_OCT },
    { 124, "FAILREG+1=", B0, FMT_OCT },
    { 125, "FAILREG+2=", B0, FMT_OCT },
    { -1 },
    { 126, "RADMODES=", B0, FMT_OCT },
    { 127, "DAPBOOLS=", B0, FMT_OCT },
    { -1 }, { -1 },
    { 128, "POSTORKU=", 32, FMT_DEC },
    { 129, "NEGTORKU=", 32, FMT_DEC },
    { 130, "POSTORKV=", 32, FMT_DEC },
    { 131, "NEGTORKV=", 32, FMT_DEC },
    { 132, "RGU=", B24, FMT_DP },
    { 134, "RGU+2=", B24, FMT_DP },
    { 136, "RGU+4=", B24, FMT_DP },
    { -1 },
    { 138, "VGU=", B10, FMT_DP },
    { 140, "VGU+2=", B10, FMT_DP },
    { 142, "VGU+4=", B10, FMT_DP },
    { -1 },
    { 144, "LAND=", B24, FMT_DP },
    { 146, "LAND+2=", B24, FMT_DP },
    { 148, "LAND+4=", B24, FMT_DP },
    { -1 },
    { 150, "AT=", B9, FMT_DP },
    { 152, "TLAND=", B28, FMT_DP },
    { 154, "FC=", B14, FMT_SP, &FormatGtc },
    { -1 },
    { 156, "LASTYCMD=", B0, FMT_OCT },
    { 157, "LASTXCMD=", B0, FMT_OCT },
    { 158, "LEMMASS=", B16, FMT_SP },
    { 159, "CSMMASS=", B16, FMT_SP },
    { 160, "IMODES30=", B0, FMT_OCT },
    { 161, "IMODES33=", B0, FMT_OCT },
    { -1 }, { -1 },
    { 162, "TIG=", B28, FMT_DP },    
    { 164, "OMEGAP=", 45, FMT_SP },
    { 165, "OMEGAQ=", 45, FMT_SP },
    { 166, "OMEGAR=", 45, FMT_SP },
    { 176, "ALPHAQ=", 90, FMT_SP },
    { 177, "ALPHAR=", 90, FMT_SP },
    { 178, "POSTORKP=", 32, FMT_DEC },
    { 179, "NEGTORKP=", 32, FMT_DEC },
    { 180, "CHN11,12=", B0, FMT_2OCT },
    { 182, "CHN13,14=", B0, FMT_2OCT },
    { 184, "CHN30,31=", B0, FMT_2OCT },
    { 186, "CHN32,33=", B0, FMT_2OCT },
    { 188, "PIPTIME1=", B28, FMT_DP },
    { 190, "DELV=", B14, FMT_DP },
    { 192, "DELV+2=", B14, FMT_DP },
    { 194, "DELV+4=", B14, FMT_DP },
    { 196, "PSEUDO55=", B14, FMT_SP, &FormatGtc },
    { 198, "TTOGO=", B28, FMT_DP }
  }
};

static DownlinkListSpec_t LmLunarSurfaceAlignSpec = {
  "LM Lunar Surface Align downlink list",
  {
    { 0, "ID=", B0, FMT_OCT },
    { 1, "SYNC=", B0, FMT_OCT },
    { 100, "TIME=", B28, FMT_DP },
    { -1 },
    { 2, "R-OTHER=", B29, FMT_DP },
    { 4, "R-OTHER+2=", B29, FMT_DP },
    { 6, "R-OTHER+4=", B29, FMT_DP },
    { -1 },
    { 8, "V-OTHER=", B7, FMT_DP },
    { 10, "V-OTHER+2=", B7, FMT_DP },
    { 12, "V-OTHER+4=", B7, FMT_DP },
    { 14, "T-OTHER=", B28, FMT_DP },
    { 16, "RANGRDOT=", B0, FMT_2OCT },	// Look at this later.
    { -1 }, { -1 }, { -1 },
    { 18, "AIG=", 360, FMT_SP },
    { 19, "AMG=", 360, FMT_SP },
    { 20, "AOG=", 360, FMT_SP },
    { 21, "TRKMKCNT=", B0, FMT_DEC },
    { 22, "TANGNB=", 360, FMT_SP },
    { 23, "TANGNB+1=", 360, FMT_SP },
    { 24, "MARKTIME=", B28, FMT_DP },
    { 26, "TALIGN=", B28, FMT_DP },
    { 28, "REFSMMAT=", B0, FMT_DP },
    { 30, "REFSMMAT+2=", B0, FMT_DP },
    { 32, "REFSMMAT+4=", B0, FMT_DP },
    { 34, "REFSMMAT+6=", B0, FMT_DP },
    { 36, "REFSMMAT+8=", B0, FMT_DP },
    { 38, "REFSMMAT+10=", B0, FMT_DP },
    { -1 }, { -1 },
    { 40, "YNBSAV=", B1, FMT_DP },
    { 42, "YNBSAV+2=", B1, FMT_DP },
    { 44, "YNBSAV+4=", B1, FMT_DP },
    { -1 },
    { 46, "ZNBSAV=", B1, FMT_DP },
    { 48, "ZNBSAV+2=", B1, FMT_DP },
    { 50, "ZNBSAV+4=", B1, FMT_DP },
    { -1 },
    { 52, "X789=", B5, FMT_SP, FormatEarthOrMoonDP },
    { 54, "X789+2=", B5, FMT_SP, FormatEarthOrMoonDP },
    { 56, "LASTYCMD=", B0, FMT_DEC },
    { 57, "LASTXCMD=", B0, FMT_DEC },
    { 58, "REDOCTR=", B0, FMT_DEC },
    { 59, "THETAD=", 360, FMT_SP },
    { 60, "THETAD+1=", 360, FMT_SP },
    { 61, "THETAD+2=", 360, FMT_SP },
    { 62, "RSBBQ=", B0, FMT_OCT },
    { 63, "RSBBQ+1=", B0, FMT_OCT },
    { -1 }, { -1 },
    { 64, "OMEGAP=", 45, FMT_SP },
    { 65, "OMEGAQ=", 45, FMT_SP },
    { 66, "OMEGAR=", 45, FMT_SP },
    { -1 },
    { 68, "CDUXD=", 360, FMT_SP },
    { 69, "CDUYD=", 360, FMT_SP },
    { 70, "CDUZD=", 360, FMT_SP },
    { -1 },
    { 72, "CDUX=", 360, FMT_SP },
    { 73, "CDUY=", 360, FMT_SP },
    { 74, "CDUZ=", 360, FMT_SP },
    { 75, "CDUT=", 360, FMT_SP },
    { 76, "STATE=", B0, FMT_2OCT },
    { 78, "STATE+2=", B0, FMT_2OCT },
    { 80, "STATE+4=", B0, FMT_2OCT },
    { 82, "STATE+6=", B0, FMT_2OCT },
    { 84, "STATE+8=", B0, FMT_2OCT },
    { 86, "STATE+10=", B0, FMT_2OCT },
    { -1 }, { -1 },
    { 88, "DSPTB=", B0, FMT_OCT },
    { 90, "DSPTB+2=", B0, FMT_2OCT },
    { 92, "DSPTB+4=", B0, FMT_2OCT },
    { 94, "DSPTB+6=", B0, FMT_2OCT },
    { 96, "DSPTB+8=", B0, FMT_2OCT },
    { 98, "DSPTB+10=", B0, FMT_2OCT },
    { -1 }, { -1 },
    { 102, "RN=", B29, FMT_DP },
    { 104, "RN+2=", B29, FMT_DP },
    { 106, "RN+4=", B29, FMT_DP },
    { -1 },
    { 108, "VN=", B7, FMT_DP },
    { 110, "VN+2=", B7, FMT_DP },
    { 112, "VN+4=", B7, FMT_DP },
    { 114, "PIPTIME=", B28, FMT_DP },
    { 116, "OMEGAPD=", 45, FMT_SP },
    { 117, "OMEGAQD=", 45, FMT_SP },
    { 118, "OMEGARD=", 45, FMT_SP },
    { -1 },
    { 120, "CADRFLSH=", B0, FMT_OCT },
    { 121, "CADRFLSH+1=", B0, FMT_OCT },
    { 122, "CADRFLSH+2=", B0, FMT_OCT },
    { -1 },
    { 123, "FAILREG=", B0, FMT_OCT },
    { 124, "FAILREG+1=", B0, FMT_OCT },
    { 125, "FAILREG+2=", B0, FMT_OCT },
    { -1 },
    { 126, "RADMODES=", B0, FMT_OCT },
    { 127, "DAPBOOLS=", B0, FMT_OCT },
    { -1 }, { -1 },
    { 128, "OGC=", 360, FMT_DP },
    { 130, "IGC=", 360, FMT_DP },
    { 132, "MGC=", 360, FMT_DP },
    { -1 },
    { 134, "BESTI=", 6, FMT_DEC },
    { 135, "BESTJ=", 6, FMT_DEC },
    { 136, "STARSAV1=", 2, FMT_DP },	// Fix later.  
    { 138, "STARSAV1+2=", 2, FMT_DP },	// Fix later.  
    { 140, "STARSAV1+4=", 2, FMT_DP },	// Fix later.  
    { 142, "STARSAV2=", 2, FMT_DP },	// Fix later.  
    { 144, "STARSAV2+2=", 2, FMT_DP },	// Fix later.  
    { 146, "STARSAV2+4=", 2, FMT_DP },	// Fix later.  
    { 148, "GSAV=", 2, FMT_DP },
    { 150, "GSAV+2=", 2, FMT_DP },
    { 152, "GSAV+4=", 2, FMT_DP },
    { 154, "AGSK=", B28, FMT_DP },
    { 158, "LEMMASS=", B16, FMT_SP },
    { 159, "CSMMASS=", B16, FMT_SP },
    { 160, "IMODES30=", B0, FMT_OCT },
    { 161, "IMODES33=", B0, FMT_OCT },
    { 162, "TIG=", B28, FMT_DP },    
    { 164, "OMEGAP=", 45, FMT_SP },
    { 165, "OMEGAQ=", 45, FMT_SP },
    { 166, "OMEGAR=", 45, FMT_SP },
    { 176, "ALPHAQ=", 90, FMT_SP },
    { 177, "ALPHAR=", 90, FMT_SP },
    { 178, "POSTORKP=", 32, FMT_DEC },
    { 179, "NEGTORKP=", 32, FMT_DEC },
    { 180, "CHN11,12=", B0, FMT_2OCT },
    { 182, "CHN13,14=", B0, FMT_2OCT },
    { 184, "CHN30,31=", B0, FMT_2OCT },
    { 186, "CHN32,33=", B0, FMT_2OCT },
    { 188, "PIPTIME1=", B28, FMT_DP },
    { 190, "DELV=", B14, FMT_DP },
    { 192, "DELV+2=", B14, FMT_DP },
    { 194, "DELV+4=", B14, FMT_DP }
  }
};

static DownlinkListSpec_t CmEntryUpdateSpec = {
  "CM Entry/Update downlink list",
  {
    { 0, "ID=", B0, FMT_OCT },
    { 1, "SYNC=", B0, FMT_OCT },
    { 100, "TIME=", B28, FMT_DP },
    { -1 },
    { 2, "RN=", B29, FMT_DP },
    { 4, "RN+2=", B29, FMT_DP },
    { 6, "RN+4=", B29, FMT_DP },
    { -1 },
    { 8, "VN=", B7, FMT_DP },
    { 10, "VN+2=", B7, FMT_DP },
    { 12, "VN+4=", B7, FMT_DP },
    { 14, "PIPTIME=", B28, FMT_DP },
    { 16, "CDUX=", 360, FMT_SP },
    { 17, "CDUY=", 360, FMT_SP },
    { 18, "CDUZ=", 360, FMT_SP },
    { 19, "CDUT=", B0, FMT_2OCT },	// Confused about this one.
    { 20, "ADOT=", 450, FMT_DP, &FormatAdotsOrOga },
    { 22, "ADOT+2=", 450, FMT_DP, &FormatAdotsOrOga },
    { 24, "ADOT+4=", 450, FMT_DP, &FormatAdotsOrOga },
    { -1 },
    { 26, "AK=", 180, FMT_SP },
    { 27, "AK1=", 180, FMT_SP },
    { 28, "AK2=", 180, FMT_SP }, 
    { 29, "RCSFLAGS=", B0, FMT_OCT },
    { 30, "THETADX=", 360, FMT_USP },
    { 31, "THETADY=", 360, FMT_USP },
    { 32, "THETADZ=", 360, FMT_USP },
    { 34, "CMDAPMOD=", B0, FMT_OCT },
    { 35, "PREL=", 1800, FMT_SP },
    { 36, "QREL=", 1800, FMT_SP },
    { 37, "RREL=", 1800, FMT_SP },
    { 38, "L/D1=", B0, FMT_DP, &FormatHalfDP },
    { 40, "UPBUFF=", B0, FMT_2OCT },
    { 42, "UPBUFF+2=", B0, FMT_2OCT },
    { 44, "UPBUFF+4=", B0, FMT_2OCT },
    { 46, "UPBUFF+6=", B0, FMT_2OCT },
    { 48, "UPBUFF+8=", B0, FMT_2OCT },
    { 50, "UPBUFF+10=", B0, FMT_2OCT },
    { 52, "UPBUFF+12=", B0, FMT_2OCT },
    { 54, "UPBUFF+14=", B0, FMT_2OCT },
    { 56, "UPBUFF+16=", B0, FMT_2OCT },
    { 58, "UPBUFF+18=", B0, FMT_2OCT },
    { 60, "COMPNUMB=", B0, FMT_OCT },
    { 61, "UPOLDMOD=", B0, FMT_DEC },
    { 62, "UPVERB=", B0, FMT_DEC },
    { 63, "UPCOUNT=", B0, FMT_OCT },
    { 64, "PAXERR1=", 360, FMT_SP },
    { 65, "ROLLTM=", 180, FMT_SP },
    { 66, "LATANG=", 4, FMT_DP },
    { 68, "RDOT=", B0, FMT_DP, &FormatRDOT },
    { 70, "THETAH=", 360, FMT_DP },
    { 72, "LAT(SPL)=", 360, FMT_DP },
    { 74, "LNG(SPL)=", 360, FMT_DP },
    { 76, "ALFA/180=", 180, FMT_SP },
    { 77, "BETA/180=", 180, FMT_SP },
    { 78, "STATE=", B0, FMT_2OCT },
    { 80, "STATE+2=", B0, FMT_2OCT },
    { 82, "STATE+4=", B0, FMT_2OCT },
    { 84, "STATE+6=", B0, FMT_2OCT },
    { 86, "STATE+8=", B0, FMT_2OCT },
    { 88, "DSPTB=", B0, FMT_OCT },
    { 90, "DSPTB+2=", B0, FMT_2OCT },
    { 92, "DSPTB+4=", B0, FMT_2OCT },
    { 94, "DSPTB+6=", B0, FMT_2OCT },
    { 96, "DSPTB+8=", B0, FMT_2OCT },
    { 98, "DSPTB+10=", B0, FMT_2OCT },
    { 102, "PIPTIME1=", B28, FMT_DP },
    { -1 },
    { 104, "DELV=", B14, FMT_DP, &FormatDELV },
    { 106, "DELV+2=", B14, FMT_DP, &FormatDELV },
    { 108, "DELV+4=", B14, FMT_DP, &FormatDELV },
    { -1 },
    { 110, "TTE=", B28, FMT_DP },
    { 112, "VIO=", B7, FMT_DP },
    { 114, "VPRED=", B7, FMT_DP },
    { -1 },
    { 126, "OPTION1=", B0, FMT_OCT },	// Don't know what this is.
    { 127, "OPTION2=", B0, FMT_OCT },	// .. or this
    { 128, "TET=", B28, FMT_DP },	// ... or this
    { -1 },
    { 130, "ERRORX=", 180, FMT_SP },
    { 131, "ERRORY=", 180, FMT_SP },
    { 132, "ERRORZ=", 180, FMT_SP },
    { -1 },
    { 160, "LEMMASS=", B16, FMT_SP },
    { 161, "CSMMASS=", B16, FMT_SP },
    { 162, "DAPDATR1=", B0, FMT_OCT },
    { 163, "DAPDATR2=", B0, FMT_OCT },
    { 165, "ROLLC=", 360, FMT_SP },
    { 166, "OPTMODES=", B0, FMT_OCT },
    { 167, "HOLDFLAG=", B0, FMT_DEC },
    { -1 },
    { 168, "WBODY=", 450, FMT_DP, &FormatAdotsOrOga },
    { 170, "WBODY+2=", 450, FMT_DP, &FormatAdotsOrOga },
    { 172, "WBODY+4=", 450, FMT_DP, &FormatAdotsOrOga },
    { 174, "REDOCTR=", B0, FMT_DEC },
    { 175, "THETAD=", 360, FMT_SP },
    { 176, "THETAD+1=", 360, FMT_SP },
    { 177, "THETAD+2=", 360, FMT_SP },
    { -1 },
    { 178, "IMODES30=", B0, FMT_OCT },
    { 179, "IMODES33=", B0, FMT_OCT },
    { -1 },
    { -1 },
    { 180, "CHN11,12=", B0, FMT_2OCT },
    { 182, "CHN13,14=", B0, FMT_2OCT },
    { 184, "CHN30,31=", B0, FMT_2OCT },
    { 186, "CHN32,33=", B0, FMT_2OCT },
    { 188, "RSBBQ=", B0, FMT_2OCT },
    { 191, "CHAN77=", B0, FMT_OCT },
    { 192, "C31FLWRD=", B0, FMT_OCT },
    { -1 },
    { 193, "FAILREG=", B0, FMT_OCT },
    { 194, "FAILREG+1=", B0, FMT_OCT },
    { 195, "FAILREG+2=", B0, FMT_OCT },
    { -1 },
    { 196, "STATE+10=", B0, FMT_2OCT },
    { 196, "GAMMAEI=", 360, FMT_DP }
  }
};

static DownlinkListSpec_t LmAgsInitializationUpdateSpec = {
  "LM AGS initialization/update downlink list",
  {
    { 0, "ID=", B0, FMT_OCT },
    { 1, "SYNC=", B0, FMT_OCT },
    { 100, "TIME=", B28, FMT_DP },
    { -1 },
    { 2,  "AGSBUFF=", B25, FMT_SP, &FormatEarthOrMoonSP },
    { 4,  "AGSBUF+2=", B25, FMT_SP, &FormatEarthOrMoonSP },
    { 6,  "AGSBUF+4=", B25, FMT_SP, &FormatEarthOrMoonSP },
    { 8,  "LM EPOCH=", B18, FMT_DP, &FormatEpoch },
    { 10, "AGSBUF+1=", B15, FMT_SP, &FormatEarthOrMoonSP },
    { 12, "AGSBUF+3=", B15, FMT_SP, &FormatEarthOrMoonSP },
    { 14, "AGSBUF+5=", B15, FMT_SP, &FormatEarthOrMoonSP },
    { 18, "AGSBUF+6=", B25, FMT_SP, &FormatEarthOrMoonSP },
    { 20, "AGSBUF+8=", B25, FMT_SP, &FormatEarthOrMoonSP },
    { 22, "AGSBUF+10=", B25, FMT_SP, &FormatEarthOrMoonSP },
    { 24, "CM EPOCH=", B18, FMT_DP, &FormatEpoch },
    { -1 },
    { 26, "AGSBUF+7=", B15, FMT_SP, &FormatEarthOrMoonSP },
    { 28, "AGSBUF+9=", B15, FMT_SP, &FormatEarthOrMoonSP },
    { 30, "AGSBUF+11=", B15, FMT_SP, &FormatEarthOrMoonSP },
    { -1 },
    { 34, "COMPNUMB=", B0, FMT_OCT },
    { 35, "UPOLDMOD=", B0, FMT_DEC },
    { 36, "UPVERB=", B0, FMT_DEC },
    { 37, "UPCOUNT=", B0, FMT_OCT },
    { 38, "UPBUF=", B0, FMT_2OCT },
    { 40, "UPBUF+2=", B0, FMT_2OCT },
    { 42, "UPBUF+4=", B0, FMT_2OCT },
    { 44, "UPBUF+6=", B0, FMT_2OCT },
    { 46, "UPBUF+8=", B0, FMT_2OCT },
    { 48, "UPBUF+10=", B0, FMT_2OCT },
    { 50, "UPBUF+12=", B0, FMT_2OCT },
    { 52, "UPBUF+14=", B0, FMT_2OCT },
    { 54, "UPBUF+16=", B0, FMT_2OCT },
    { 56, "UPBUF+18=", B0, FMT_2OCT },
    { -1 }, 
    // Same as LM Orbital Maneuvers.
    { 58, "REDOCTR=", B0, FMT_DEC },
    { 59, "THETAD=", 360, FMT_SP },
    { 60, "THETAD+1=", 360, FMT_SP },
    { 61, "THETAD+2=", 360, FMT_SP },
    { -1 },
    { 62, "RSBBQ=", B0, FMT_OCT },
    { 63, "RSBBQ+1=", B0, FMT_OCT },
    { -1 }, { -1 },
    { 64, "OMEGAP=", 45, FMT_SP },
    { 65, "OMEGAQ=", 45, FMT_SP },
    { 66, "OMEGAR=", 45, FMT_SP },
    { -1 },
    { 68, "CDUXD=", 360, FMT_SP },
    { 69, "CDUYD=", 360, FMT_SP },
    { 70, "CDUZD=", 360, FMT_SP },
    { -1 },
    { 72, "CDUX=", 360, FMT_SP },
    { 73, "CDUY=", 360, FMT_SP },
    { 74, "CDUZ=", 360, FMT_SP },
    { 75, "CDUT=", 360, FMT_SP },
    { 76, "STATE=", B0, FMT_2OCT },
    { 78, "STATE+2=", B0, FMT_2OCT },
    { 80, "STATE+4=", B0, FMT_2OCT },
    { 82, "STATE+6=", B0, FMT_2OCT },
    { 84, "STATE+8=", B0, FMT_2OCT },
    { 86, "STATE+10=", B0, FMT_2OCT },
    { -1 }, { -1 },
    { 88, "DSPTB=", B0, FMT_OCT },
    { 90, "DSPTB+2=", B0, FMT_2OCT },
    { 92, "DSPTB+4=", B0, FMT_2OCT },
    { 94, "DSPTB+6=", B0, FMT_2OCT },
    { 96, "DSPTB+8=", B0, FMT_2OCT },
    { 98, "DSPTB+10=", B0, FMT_2OCT },
    { -1 }, { -1 },
    { 102, "RN=", B29, FMT_DP },
    { 104, "RN+2=", B29, FMT_DP },
    { 106, "RN+4=", B29, FMT_DP },
    { -1 },
    { 108, "VN=", B7, FMT_DP },
    { 110, "VN+2=", B7, FMT_DP },
    { 112, "VN+4=", B7, FMT_DP },
    { 114, "PIPTIME=", B28, FMT_DP },
    { 116, "OMEGAPD=", 45, FMT_SP },
    { 117, "OMEGAQD=", 45, FMT_SP },
    { 118, "OMEGARD=", 45, FMT_SP },
    { -1 },
    // 
    { 120, "CADRFLSH=", B0, FMT_OCT },
    { 121, "CADRFLSH+1=", B0, FMT_OCT },
    { 122, "CADRFLSH+2=", B0, FMT_OCT },
    { -1 },
    { 123, "FAILREG=", B0, FMT_OCT },
    { 124, "FAILREG+1=", B0, FMT_OCT },
    { 125, "FAILREG+2=", B0, FMT_OCT },
    { -1 },
    { 126, "RADMODES=", B0, FMT_OCT },
    { 127, "DAPBOOLS=", B0, FMT_OCT },
    { 128, "POSTORKU=", 32, FMT_DEC },
    { 129, "NEGTORKU=", 32, FMT_DEC },
    { 130, "POSTORKV=", 32, FMT_DEC },
    { 131, "NEGTORKV=", 32, FMT_DEC },
    { 136, "AGSK=", B28, FMT_DP },
    { -1 },
    { 138, "UPBUF=", B0, FMT_2OCT },
    { 140, "UPBUF+2=", B0, FMT_2OCT },
    { 142, "UPBUF+4=", B0, FMT_2OCT },
    { 144, "UPBUF+6=", B0, FMT_2OCT },
    { 146, "UPBUF+8=", B0, FMT_2OCT },
    { 148, "UPBUF+10=", B0, FMT_2OCT },
    { 150, "UPBUF+12=", B0, FMT_2OCT },
    { 152, "UPBUF+14=", B0, FMT_2OCT },
    { 154, "UPBUF+16=", B0, FMT_2OCT },
    { 156, "UPBUF+18=", B0, FMT_2OCT },
    { -1 }, { -1 },
    { 158, "LEMMASS=", B16, FMT_SP },
    { 159, "CSMMASS=", B16, FMT_SP },
    { 160, "IMODES30=", B0, FMT_OCT },
    { 161, "IMODES33=", B0, FMT_OCT },
    { 176, "ALPHAQ=", 90, FMT_SP },
    { 177, "ALPHAR=", 90, FMT_SP },
    { 178, "POSTORKP=", 32, FMT_DEC },
    { 179, "NEGTORKP=", 32, FMT_DEC },
    { 180, "CHN11,12=", B0, FMT_2OCT },
    { 182, "CHN13,14=", B0, FMT_2OCT },
    { 184, "CHN30,31=", B0, FMT_2OCT },
    { 186, "CHN32,33=", B0, FMT_2OCT }
  }
};

// The ACTUAL downlink lists used.  The following array can be modified
// at runtime to get different lists.  Or, the array can be used to get
// pointers to the default lists, which could be modified in-place
// (for example, to have different row,col coordinates).

// The following array entries must correspond to the numerical order
// of the DL_xxx constants.
DownlinkListSpec_t *DownlinkListSpecs[11] = {
  &CmPoweredListSpec, &LmOrbitalManeuversSpec,
  &CmCoastAlignSpec, &LmCoastAlignSpec,
  &CmRendezvousPrethrustSpec, &LmRendezvousPrethrustSpec,
  &CmProgram22Spec, &LmDescentAscentSpec,
  &LmLunarSurfaceAlignSpec, &CmEntryUpdateSpec,
  &LmAgsInitializationUpdateSpec
};

//---------------------------------------------------------------------------
// Print a double-precision number.  I cut-and-pasted this from CheckDec.c,
// and modified trivially;

double
GetDP (int *Ptr, int Scale)
{
  int i, Sign, Oct1, Oct2;
  double x;
  Oct1 = *Ptr++;
  Oct2 = *Ptr;
  if (0 != (040000 & Oct1))
    {
      Oct1 = ~Oct1;
      Oct2 = ~Oct2;
      Sign = -1;
    }
  else
    {
      Sign = 1;
    }
  i = ((Oct1 & 037777) << 14) | (Oct2 & 037777);
  x = Sign * i * FLOAT_SCALE * Scale;
  return (x);
}

void
PrintDP (int *Ptr, int Scale, int row, int col)
{
  sprintf (&Sbuffer[row][col], "%.10g", GetDP (Ptr, Scale));
}

double
GetSP (int *Ptr, int Scale)
{
  int i, Sign, Oct;
  double x;
  Oct = *Ptr;
  if (0 != (040000 & Oct))
    {
      Oct = ~Oct;
      Sign = -1;
    }
  else
    {
      Sign = 1;
    }
  i = (Oct & 037777);
  x = Sign * i * S_FLOAT_SCALE * Scale;
  return (x);
}

void
PrintSP (int *Ptr, int Scale, int row, int col)
{
  sprintf (&Sbuffer[row][col], "%.5g", GetSP (Ptr, Scale));
}

double
GetUSP (int *Ptr, int Scale)
{
  unsigned Oct;
  double x;
  Oct = 077777 & *Ptr;
  x = Oct * US_FLOAT_SCALE * Scale;
  return (x);
}

void
PrintUSP (int *Ptr, int Scale, int row, int col)
{
  sprintf (&Sbuffer[row][col], "%.5g", GetUSP (Ptr, Scale));
}

//--------------------------------------------------------------------------
// Stuff for printing fields.

// Print a field.
static void
PrintField (const FieldSpec_t *FieldSpec)
{
  int row, col, *Ptr;
  row = FieldSpec->Row;
  col = FieldSpec->Col;
  if (row == 0 && col == 0)
    {
      row = LastRow;
      col = LastCol;
    }
  LastCol = col + 20;
  if (LastCol < Swidth)
    LastRow = row;
  else
    {
      LastCol = 0;
      LastRow = row + 1;
    }
  if (FieldSpec->IndexIntoList < 0)
    return;
  if (FieldSpec->Formatter != NULL)
    {
      char *s;
      s = (*FieldSpec->Formatter) (FieldSpec->IndexIntoList,
      				   FieldSpec->Scale, FieldSpec->Format);
      if (s != NULL)
        sprintf (&Sbuffer[row][col], "%s%s", FieldSpec->Name, s);
    }
  else
    {
      sprintf (&Sbuffer[row][col], "%s", FieldSpec->Name);
      col += strlen (FieldSpec->Name);
      Ptr = &DownlinkListBuffer[FieldSpec->IndexIntoList];
      switch (FieldSpec->Format)
	{
	case FMT_SP:
	  PrintSP (Ptr, FieldSpec->Scale, row, col);
	  break;
	case FMT_DP:
	  PrintDP (Ptr, FieldSpec->Scale, row, col);
	  break;
	case FMT_OCT:
	  sprintf (&Sbuffer[row][col], "%05o", Ptr[0]);
	  break;
	case FMT_2OCT:
	  sprintf (&Sbuffer[row][col], "%05o%05o", Ptr[0], Ptr[1]);
	  break;
	case FMT_DEC:
	  sprintf (&Sbuffer[row][col], "%+d", Ptr[0]);
	  break;
	case FMT_2DEC:
	  sprintf (&Sbuffer[row][col], "%+d", 0100000 * Ptr[0] + Ptr[1]);
	  break;
	case FMT_USP:		
	  PrintUSP (Ptr, FieldSpec->Scale, row, col);
	  break;
	}
    }
}

// Print an entire downlink list.
static void
PrintDownlinkList (const DownlinkListSpec_t *Spec)
{
  int i;
  Sclear ();
  sprintf (&Sbuffer[0][0], "%s", Spec->Title);
  for (i = 0; i < MAX_DOWNLINK_LIST; i++)
    {
      if (i && !Spec->FieldSpecs[i].IndexIntoList)
        break;		// End of field-list.
      PrintField (&Spec->FieldSpecs[i]);
    }
  Swrite ();
}

//---------------------------------------------------------------------------
// Print an "erasable dump" downlink list.

static void
DecodeErasableDump (char *Title)
{
  int i, j, row, col;
  Sclear ();
  sprintf (&Sbuffer[0][0], Title);
  sprintf (&Sbuffer[1][0], "ID=%05o  SYNC=%05o  PASS=%o  EBANK=%o  TIME1=%05o",
           DownlinkListBuffer[0], DownlinkListBuffer[1],
	   (DownlinkListBuffer[2] >> 11) & 1,
	   (DownlinkListBuffer[2] >> 8) & 7,
	   DownlinkListBuffer[3]);
  for (i = 1, j = 0, row = 2, col = 0; i <= 128; i++, j += 2)
    {
      if (1 == (i & 3))
        {
          sprintf (&Sbuffer[row][col], "%03o:", j);
	  col += 4;
	}
      sprintf (&Sbuffer[row][col], " %05o %05o", DownlinkListBuffer[j + 4], DownlinkListBuffer[j + 5]);
      col += 12;
      if (0 == (i & 3))
        {
	  row++;
	  col = 0;
	}
    }
  Swrite ();
}

//----------------------------------------------------------------------------
// If you want to print digital downlinks to stdout, just keep feeding 
// DecodeDigitalDownlink the data read from output channels 013, 034, and 035
// as it arrives.  (Actually, you can just feed it data for all AGC output
// channels, if you like.)  The function takes care of buffering the data and
// parsing it out, so there's nothing else you have to do.

void
DecodeDigitalDownlink (int Channel, int Value, int CmOrLm)
{
  static int WordOrderBit = 0, Any = 0;
  
  // Parse the incoming data.  Detect unexpected stuff and restart the packet
  // if found.
  if (Channel == 013)
    {
      WordOrderBit = (Value & 0100);
      return;
    }
  else if (Channel == 034)
    {
      if (0 != (DownlinkListCount & 1))
        goto AbortList;
      if (DownlinkListCount == 0)
        {
	  if (WordOrderBit)
	    goto AbortList;
	  // Interpret the ID.
	Retry:
	  //printf ("ID=%05o\n", Value);
	  DownlinkListZero = 100;
	  if (Value == 01776)		// LM erasable dump.
	    {
	      DownlinkListExpected = 260;
	      DownlinkListZero = -1;
	    }
	  else if (Value == 01777)	// CM erasable dump.
	    {
	      DownlinkListExpected = 260; 
	      DownlinkListZero = -1;
	    }
	  else if (Value == 077774)	// LM orbital maneuvers, CM powered list.
	    DownlinkListExpected = 200;
	  else if (Value == 077777)	// LM or CM coast align
	    DownlinkListExpected = 200;
	  else if (Value == 077775)	// LM or CM rendezvous/prethrust
	    DownlinkListExpected = 200;
	  else if (Value == 077773)	// LM descent/ascent, CM program 22 list
	    DownlinkListExpected = 200;
	  else if (Value == 077772)	// Lunar surface align
	    DownlinkListExpected = 200;
	  else if (Value == 077776)	// LM AGS initialization/update, CM entry/update
	    DownlinkListExpected = 200;
	  else
	    goto AbortList;
	  //printf ("Started downlink of type 0%o\n", Value);
	}
      else
        {
	  if (!WordOrderBit && DownlinkListCount != DownlinkListZero)
	    {
	      DownlinkListCount = 0;
	      goto Retry;
	    }
	}
    }
  else if (Channel == 035)
    {
      if (0 == (DownlinkListCount & 1))
        goto AbortList;
      if (DownlinkListCount == 1)
        { 
	  if (Value != 077340)	// sync word
            goto AbortList;
	  if (WordOrderBit)
	    goto AbortList;
	}
      else
        {
	  if (!WordOrderBit && DownlinkListCount != DownlinkListZero + 1)
	    goto AbortList;
	}
    }
  else
    return;
  
  // Buffer the incoming data.
  if (DownlinkListCount < MAX_DOWNLINK_LIST)
    DownlinkListBuffer[DownlinkListCount++] = Value;
    
  // End of the list!  Do something with the data.
  if (DownlinkListCount >= DownlinkListExpected)
    {
      switch (DownlinkListBuffer[0])
        {
	case 01776:
	  DecodeErasableDump ("LM erasable dump downlinked.");
	  break;
	case 01777:
	  DecodeErasableDump ("CM erasable dump downlinked.");
	  break;
	case 077774:
	  if (CmOrLm)
	    PrintDownlinkList (DownlinkListSpecs[DL_CM_POWERED_LIST]);
	  else
	    PrintDownlinkList (DownlinkListSpecs[DL_LM_ORBITAL_MANEUVERS]);
	  break;
	case 077777:
	  if (CmOrLm)
	    PrintDownlinkList (DownlinkListSpecs[DL_CM_COAST_ALIGN]);
	  else
	    PrintDownlinkList (DownlinkListSpecs[DL_LM_COAST_ALIGN]);
	  break;
	case 077775:
	  if (CmOrLm)
	    PrintDownlinkList (DownlinkListSpecs[DL_CM_RENDEZVOUS_PRETHRUST]);
	  else
	    PrintDownlinkList (DownlinkListSpecs[DL_LM_RENDEZVOUS_PRETHRUST]);
	  break;
	case 077773:
	  if (CmOrLm)
	    PrintDownlinkList (DownlinkListSpecs[DL_CM_PROGRAM_22]);
	  else
	    PrintDownlinkList (DownlinkListSpecs[DL_LM_DESCENT_ASCENT]);
	  break;
	case 077772:
	  PrintDownlinkList (DownlinkListSpecs[DL_LM_LUNAR_SURFACE_ALIGN]);
	  break;
	case 077776:
	  if (CmOrLm)
	    PrintDownlinkList (DownlinkListSpecs[DL_CM_ENTRY_UPDATE]);
	  else
	    PrintDownlinkList (DownlinkListSpecs[DL_LM_AGS_INITIALIZATION_UPDATE]);
	  break;
	default:
	  Sclear ();
	  sprintf (&Sbuffer[0][0], "Unknown list type downlinked.");
	  Swrite ();
	  break;
	}
      Any = 1;
      DownlinkListCount = 0;
    }
    
  return;
AbortList:
  if (Any && DownlinkListCount != 0)
    {
      Sclear ();
      sprintf (&Sbuffer[0][0], "Downlink list of type 0%o aborted at word-count %d", 
              DownlinkListBuffer[0], DownlinkListCount);
      Swrite ();
      Any = 0;
    }
  DownlinkListCount = 0;
  return;
}


