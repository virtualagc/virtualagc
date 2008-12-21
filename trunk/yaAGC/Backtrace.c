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

  Filename:	Backtrace.c
  Purpose:	Stuff for yaAGC backtrace.
  Contact:	Ron Burkey <info@sandroid.org>
  Reference:	http://www.ibiblio.org/apollo/index.html
  Mods:		05/12/04 RSB.	Began.
  		05/14/04 RSB.	Added interrupt-request stuff.
				Fixed how superbanks are displayed.
		05/15/04 RSB	Unroll the backtrace table when a RESUME
				is encountered to get rid of all the
				entries for the ISR.
		05/30/04 RSB	Added a header file or two.
		05/31/04 RSB	Corrected for pre-incrementing of Z register
				during instructions.
		07/12/04 RSB	Q is now 16 bits.
		08/01/04 RSB	Backtraces, as originally intended, are no
				longer created unless yaAGC was started in
				--debug mode.
		08/12/04 RSB	Added OutputChannel10[].
		02/27/05 RSB	Added the license exception, as required by
				the GPL, for linking to Orbiter SDK libraries.
		05/14/05 RSB	Corrected website references.
*/

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include "agc_engine.h"
#include "agc_symtab.h"

#ifdef GDBMI
static agc_t *PendingState;
static int PendingCause;
extern char* SourcePathName;
extern char* DbgGetFrameNameByAddr(unsigned LinearAddress);

/* Remove Last Added Backtracepoint should be used for TC Q or RETURN */
void BacktraceRemove()
{
	if ( BacktraceCount > 0 )
	{
		BacktraceNextAdd--;
		if ( BacktraceNextAdd < 0 )
			BacktraceNextAdd = MAX_BACKTRACE_POINTS - 1;
		BacktraceCount--;
	}
	return;
}

int BacktraceDuplicateCheck ( agc_t *State, BacktracePoint_t* Prev )
{
	int isDuplicate = 0;

	int PrevZ = Prev->Erasable[0][RegZ] & 07777;
	int PrevFB = 037 & ( Prev->Erasable[0][RegBB] >> 10 );
	int PrevSBB = ( Prev->OutputChannel7 & 0100 ) ? 1 : 0;

	int CurrZ = State->Erasable[0][RegZ] & 07777;
	int CurrFB = 037 & ( State->Erasable[0][RegBB] >> 10 );
	int CurrSBB = ( State->OutputChannel7 & 0100 ) ? 1 : 0;

	if ( PrevZ == --CurrZ &&
	        PrevFB == CurrFB &&
	        PrevSBB == CurrSBB ) isDuplicate = 1;

	return isDuplicate;
}

SymbolLine_t* FindLastLineMain ( void )
{
	BacktracePoint_t *Bp;
	SymbolLine_t *Line = NULL;
	int CurrentZ,FB,SBB;
	int BacktraceLocation = BacktraceNextAdd;
	int Count = BacktraceCount;

	while ( Count > 0 )
	{
		BacktraceLocation--;
		if ( BacktraceLocation < 0 )
			BacktraceLocation = MAX_BACKTRACE_POINTS - 1;
		Count--;
		if ( BacktracePoints[BacktraceLocation].DueToInterrupt )
		{
			Bp = &BacktracePoints[BacktraceLocation];
			CurrentZ = Bp->Erasable[0][RegZ] & 07777;
			FB = 037 & ( Bp->Erasable[0][RegBB] >> 10 );
			SBB = ( Bp->OutputChannel7 & 0100 ) ? 1 : 0;
			Line = ResolveLineAGC ( CurrentZ, FB, SBB );
		}
	}
	return Line;
}
#endif

// This function adds a new backtrace point to the circular buffer.  The
// oldest entries are transparently overwritten.  The Cause parameter is
// used as follows:
//	0	The backtrace point is in normal code.
//	1-10	The backtrace point is an interrupt vector.
//	255	The backtrace point is a RESUME after interrupt.
// When Cause==255 is encountered, all backtrace points back to (and including)
// the vector to the interrupt are removed.  The reason for this is that
// otherwise the array will quickly become completely full of interrupt
// code, and all backtrace points to foreground code will be completely lost.
void BacktraceAdd ( agc_t *State, int Cause, unsigned NextZ )
{
	BacktracePoint_t *Bp;
	if ( SingleStepCounter == -2 || BacktraceInitialized == -1 ) return;

	if ( BacktraceInitialized == 0 )
	{
		BacktracePoints = ( BacktracePoint_t * )
		                  malloc ( MAX_BACKTRACE_POINTS * sizeof ( BacktracePoint_t ) );
		if ( BacktracePoints == NULL )
		{
			BacktraceInitialized = -1;
			return;
		}
		BacktraceInitialized = 1;
	}

#ifdef GDBMI
	/* Check for Duplicate Consecutive Adds remove simple looping */
	if ( BacktraceNextAdd > 0 &&
	        BacktraceDuplicateCheck ( State,&BacktracePoints[BacktraceNextAdd-1] ) )
	{
		return;
	}
	if ( BacktraceNextAdd == 0 &&
	        BacktraceDuplicateCheck ( State,&BacktracePoints[MAX_BACKTRACE_POINTS-1] ) )
	{
		return;
	}
#endif

	if ( Cause == 255 )
	{
		while ( BacktraceCount > 0 )
		{
			BacktraceNextAdd--;
			if ( BacktraceNextAdd < 0 )
				BacktraceNextAdd = MAX_BACKTRACE_POINTS - 1;
			BacktraceCount--;
			if ( BacktracePoints[BacktraceNextAdd].DueToInterrupt )
				break;
		}
		return;
	}

	Bp = &BacktracePoints[BacktraceNextAdd++];
	if ( BacktraceNextAdd >= MAX_BACKTRACE_POINTS )
		BacktraceNextAdd = 0;
	if ( BacktraceCount < MAX_BACKTRACE_POINTS )
		BacktraceCount++;
	// I just happen to know that State->CycleCounter has been pre-incremented.
	Bp->CycleCounter = State->CycleCounter - 1;
	memcpy ( Bp->Erasable, State->Erasable, sizeof ( State->Erasable ) );
	memcpy ( Bp->InputChannel, State->InputChannel, sizeof ( State->InputChannel ) );
	memcpy ( Bp->InterruptRequests, State->InterruptRequests,sizeof ( State->InterruptRequests ) );
	Bp->OutputChannel7 = State->OutputChannel7;
	memcpy ( Bp->OutputChannel10, State->OutputChannel10, sizeof ( State->OutputChannel10 ) );
	Bp->IndexValue = State->IndexValue;
	Bp->ExtraCode = State->ExtraCode;
	Bp->AllowInterrupt = State->AllowInterrupt;
	//Bp->RegA16 = State->RegA16;
	//Bp->RegQ16 = State->RegQ16;
	Bp->InIsr = State->InIsr;
	Bp->SubstituteInstruction = State->SubstituteInstruction;
	Bp->DueToInterrupt = Cause;

	if (NextZ < 5) Bp->TargetZ = Bp->Erasable[0][NextZ];
	else Bp->TargetZ = NextZ;

	// printf("\n*** %d ***\n",Bp->TargetZ);

	Bp->Erasable[0][RegZ]--;	// Recall that Z is pre-incremented.
}

// Restores the state of the system from an entry in the backtrace buffer.
// Returns 0 on success or non-zero on error.

int
BacktraceRestore ( agc_t *State, int n )
{
	BacktracePoint_t *Bp;
	int k;
	if ( SingleStepCounter == -2 )
		return ( 1 );
	if ( BacktraceInitialized == -1 )
		return ( 2 );
	if ( n < 0 )
		return ( 3 );
	if ( n >= BacktraceCount )
		return ( 4 );
	k = BacktraceNextAdd - n - 1;
	if ( k < 0 )
		k += BacktraceCount;
	Bp = &BacktracePoints[k];
	State->CycleCounter = Bp->CycleCounter;
	memcpy ( State->Erasable, Bp->Erasable, sizeof ( State->Erasable ) );
	memcpy ( State->InputChannel, Bp->InputChannel, sizeof ( State->InputChannel ) );
	memcpy ( State->InterruptRequests, Bp->InterruptRequests,
	         sizeof ( State->InterruptRequests ) );
	State->OutputChannel7 = Bp->OutputChannel7;
	memcpy ( State->OutputChannel10, Bp->OutputChannel10, sizeof ( State->OutputChannel10 ) );
	State->IndexValue = Bp->IndexValue;
	State->ExtraCode = Bp->ExtraCode;
	State->AllowInterrupt = Bp->AllowInterrupt;
	//State->RegA16 = Bp->RegA16;
	//State->RegQ16 = Bp->RegQ16;
	State->InIsr = Bp->InIsr;
	State->SubstituteInstruction = Bp->SubstituteInstruction;
	return ( 0 );
}

// Displays the backtrace buffer.

void BacktraceDisplay ( agc_t *State, int Num )
{
	int i, j, k, Value, Bank;
	BacktracePoint_t *Bp;
	char funcname[128];
	SymbolLine_t *Line = NULL;
	int CurrentZ;
	int FB;
	int SBB;
	Symbol_t* Symbol;
	char* FrameName;
	char* PrevFrameName = (char*)1;

	if ( BacktraceInitialized == -1 )
	{
		printf ( "Not enough memory for backtrace buffer.\n" );
		return;
	}

#ifdef GDBMI
	/* Always show the current location in the trace */
//	{
//		CurrentZ = State->Erasable[0][RegZ] & 07777;
//		FB = 037 & ( State->Erasable[0][RegBB] >> 10 );
//		SBB = ( State->OutputChannel7 & 0100 ) ? 1 : 0;
//		Line = ResolveLineAGC ( CurrentZ, FB, SBB );

//		if ( Line )
//		{
//			Num--;
#ifdef WIN32
//			printf ( "#0\t0x%04x in %s () at %s\\%s:%d\n",
//			         gdbmiLinearAddr ( &Line->CodeAddress ),
//			         gdbmiConstructFuncName ( Line,funcname,127 ),SourcePathName,
//			         Line->FileName,Line->LineNumber );
#else
//			printf ( "#0\t0x%04x in %s () at %s/%s:%d\n",
//			         gdbmiLinearAddr ( &Line->CodeAddress ),
//			         gdbmiConstructFuncName ( Line,funcname,127 ),SourcePathName,
//			         Line->FileName,Line->LineNumber );
#endif
//		}
//	}
#endif
	if ( BacktraceCount == 0 )
	{
#ifndef GDBMI
		printf ( "The backtrace table is empty.\n" );
#endif
		return;
	}

	CurrentZ = State->Erasable[0][RegZ] & 07777;
	FB = 037 & ( State->Erasable[0][RegBB] >> 10 );
	SBB = ( State->OutputChannel7 & 0100 ) ? 1 : 0;

	for ( i = j = 0; i < BacktraceCount; i++ )
	{
		/* Determine location of Current Breakpoint Index */
		if ( 0 == Num-- ) break;
		k = BacktraceNextAdd - i - 1;
		if ( k < 0 ) k += BacktraceCount;

		/* Get Breakpoint Object by Index */
		Bp = &BacktracePoints[k];

		/* Find the Line for Current Frame Head */
		Line = ResolveLineAGC ( CurrentZ, FB, SBB );

#ifndef GDBMI
		printf ( "%2d: ", i );
		CurrentZ = Bp->Erasable[0][RegZ] & 07777;
		// Print the address.
		if ( CurrentZ < 01400 )
		{
			printf ( "Era%04o", CurrentZ );
			Bank = CurrentZ / 0400;
			Value = Bp->Erasable[Bank][CurrentZ & 0377];
		}
		else if ( CurrentZ >= 04000 )
		{
			printf ( "Fix%04o", CurrentZ );
			Bank = 2 + ( CurrentZ - 04000 ) / 02000;
			Value = State->Fixed[Bank][CurrentZ & 01777];
		}
		else if ( CurrentZ < 02000 )
		{
			Bank = 7 & Bp->Erasable[0][RegBB];
			printf ( "E%o,%04o", Bank, 01400 + ( CurrentZ & 0377 ) );
			Value = Bp->Erasable[Bank][CurrentZ & 0377];
		}
		else
		{
			Bank = 037 & Bp->Erasable[0][RegBB] >> 10;
			if ( Bank >= 030 && ( Bp->OutputChannel7 & 0100 ) )
				Bank += 010;
			printf ( "%02o,%04o", Bank, 02000 + ( CurrentZ & 01777 ) );
			Value = State->Fixed[Bank][CurrentZ & 01777];
		}

		if ( Bp->DueToInterrupt )
			printf ( " Int%02o   ", Bp->DueToInterrupt );
		else
			printf ( " %05o   ", Value & 077777 );

#else



		/* Just a new Code Block */
		{
//			CurrentZ = Bp->Erasable[0][RegZ] & 07777;
//			FB = 037 & ( Bp->Erasable[0][RegBB] >> 10 );
//			SBB = ( Bp->OutputChannel7 & 0100 ) ? 1 : 0;
//			Line = ResolveLineAGC ( CurrentZ, FB, SBB );

			unsigned Addr = gdbmiLinearFixedAddr(CurrentZ,FB,SBB);
			FrameName = DbgGetFrameNameByAddr(Addr);

			/* Make sure we have a line and only display the head frame
			 * and not the same frame name twice in a row
			 */
			if ( Line && (PrevFrameName != FrameName || BacktraceCount == 1))
			{
#ifdef WIN32
				printf ( "#%d\t0x%04x in %s () at %s\\%s:%d\n",i,
				         Addr,
				         FrameName,SourcePathName,
				         Line->FileName,Line->LineNumber );
#else
				printf ( "#%d\t0x%04x in %s () at %s/%s:%d\n",i,
					Addr,
					FrameName,SourcePathName,
					Line->FileName,Line->LineNumber );
#endif
				PrevFrameName = FrameName;
			}
//			else
//				printf ( "#%d\t0x%04x in %s ()\n",
//				         i,
//				         gdbmiLinearFixedAddr ( CurrentZ,FB,SBB ),
//					 FrameName );
		}
#endif
		/* Only Display the back trace of the current thread */
		if ( Bp->DueToInterrupt ) break;

		CurrentZ = Bp->Erasable[0][RegZ] & 07777;
		FB = 037 & ( Bp->Erasable[0][RegBB] >> 10 );
		SBB = ( Bp->OutputChannel7 & 0100 ) ? 1 : 0;

		// Next ...
		j++;
		if ( j >= BACKTRACES_PER_LINE )
		{
			j = 0;
#ifndef GDBMI
			printf ( "\n" );
#endif
		}
	}
#ifndef GDBMI
	if ( j != 0 )
		printf ( "\n" );
#endif
}


