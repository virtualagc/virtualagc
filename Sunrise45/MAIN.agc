### FILE="Main.annotation"
# Copyright:	Public domain.
# Filename:	MAIN.agc
# Purpose:	Part of the source code for Solarium build 55. This
#		is for the Command Module's (CM) Apollo Guidance
#		Computer (AGC), for Apollo 6.
# Assembler:	yaYUL --block1
# Contact:	Ron Burkey <info@sandroid.org>
# Website:	www.ibiblio.org/apollo/index.html
# Page Scans:	www.ibiblio.org/apollo/ScansForConversion/Solarium055/
# Mod history:	2009-07-25 RSB	Adapted from corresponding Colossus 249 file.
# 		2009-09-14 JL	Fixed page number.
#		2016-08-17 RSB	Corrected names of AGC_SELF-CHECK.agc,  
#				DUMMY_501_INITIALIZATION.agc, and
#				REENTRY_CONTROL.agc.
#
# This file is a little different from the other Solarium055 files being provided, 
# in that it doesn't represent anything that appears directly in the original source.  
# What I (RSB) have done for organizational purposes is to split the huge monolithic
# source code into smaller, more manageable chunks--i.e., into individual source 
# files.  Those files are rejoined within this file as "includes".  It just makes
# it a little easier to work with.  The code chunks correspond to natural divisions
# into sub-programs as indicated by the page headings in the assembly listing. 

# Module Filename
# ---------------

$VERB_AND_NOUN_INFORMATION.agc
$ERASABLE_ASSIGNMENTS.agc
$INTERRUPT_TRANSFER_ROUTINES.agc
$FIXED-FIXED_INTERPRETER_SECTION.agc
$BANK_03_INTERPRETER_SECTION.agc
$EXECUTIVE.agc
$WAITLIST.agc
$PROGRESS_CONTROL.agc
$FRESH_START_AND_RESTART.agc
$DOWN-TELEMETRY_PROGRAM.agc
$T4RUPT_OUTPUT_CONTROL_PROGRAMS.agc
$MODE_SWITCHING_AND_MARK_ROUTINES.agc
$EXTENDED_VERBS_FOR_MODING.agc
$AGC_SELF-CHECK.agc
$INTER-BANK_COMMUNICATION.agc
$ALARM_AND_DISPLAY_PROCEDURES.agc
$ORBITAL_INTEGRATION_PROGRAM.agc
$PRELAUNCH_ALIGNMENT_PROGRAM.agc
$RTB_OP_CODES.agc
$SYSTEM_TEST.agc
$INFLIGHT_ALIGNMENT_SUBROUTINES.agc
$KEYRUPT_UPRUPT_FRESH_START.agc
$PINBALL_GAME__BUTTONS_AND_LIGHTS.agc
