### FILE="Main.annotation"
# Copyright:	Public domain.
# Filename:	MAIN.agc
# Purpose:	The main source file for Luminary 1C, revision 131.
#		It is part of the source code for the Lunar Module's (LM)
#		Apollo Guidance Computer (AGC) for Apollo 13.
# Assembler:	yaYUL
# Contact:	Ron Burkey <info@sandroid.org>.
# Website:	www.ibiblio.org/apollo/index.html
# Mod history:	04/12/03 RSB.	Began.
#		05/05/03 RSB.	...continued.
#		05/11/03 RSB	Draft of this file completed.
#		06/08/03 RSB	Drafts of all the included files completed.
#		05/14/05 RSB	Corrected website reference above.
#		06/30/09 RSB	Added an experimental HTML note.
#		2017-01-06 RSB	Changed page-number references so that they
#				refer to the markings on the physical pages
#				of the printout (rather than PDF "pages" in
#				the file 1729.pdf, which is no longer the
#				associated reference material).
#		2017-01-20 RSB	Changed GOTOP00H to GOTOPOOH in all *.agc
#				files.  There are probably more POO problems
#				but those are the only ones I fixed.
#		2017-02-12 RSB	References to the scanned assembly listing
#				have been updated now that a more-legible
#				scan is available than before.
#
# The contents of these "Luminary131" files were originally (2003)
# transcribed from a scanned document obtained from MIT's
# now-defunct history or recent technology website, but which can be
# consulted now at
#	http://www.ibiblio.org/apollo/ScansForConversion/Luminary131
# As of 2017, however, there is a far-more legible scan, created from the same
# physical printout, which you should instead consult, at either
# 	http://www.ibiblio.org/apollo/ScansForConversion/Luminary131-Eyles
# or
#	https://archive.org/details/luminary131agcpr00miti
# Notations within the original program listing read, in part:
#
#	NASA Apollo LUMINARY 131 (1C) Program Source Code Listing.
#	MIT Instrumentation/Draper Laboratory -- 19 December 1969, 1742 pages.
#	This listing contains the flight program for the Lunar Module 
#	as created by MIT's Draper Lab for the Apollo 13/14 moon missions.
#
# This file is a little different from the other Luminary131 files I'm providing, 
# in that it doesn't represent anything that appears directly in the original source.  
# What I (RSB) have done for organizational purposes is to split the huge monolithic
# source code into smaller, more manageable chunks--i.e., into individual source 
# files.  Those files are rejoined within this file as "includes".  It just makes
# it a little easier to work with.  The code chunks correspond to natural divisions
# into sub-programs.  In fact, these divisions are more-or-less specified by
# the source code itself.  Refer to the "TABLE OF SUBROUTINE LOG SECTIONS" at the
# very beginning of the file ASSEMBLY_AND_OPERATION_INFORMATION.agc.
#
# It may be reasonably asked why tens of thousands of lines of source are joined by
# means of inclusion, rather than simply assembling the source files individually and
# then linking them to form the executable.  The answer is that the original 
# development team had no linker.  The builds were monolithic just like this.
# There was a big emphasis on reusability of the code in the original project, 
# apparently, but this reusability took the form of inserting your deck of 
# punch-cards at the appropriate position in somebody else's deck of punch-cards.
# So, indeed, the method of file-inclusion is a very fair representation of the 
# methods used in the original development ... with the improvement, of course,
# that you no longer have to worry about dropping the card deck.  On the other hand, 
# I wasn't there at the time, so I may have no idea what I'm talking about.
#
# Finally, note that the original Apollo AGC assembler (called "YUL") is no longer 
# available (as far as I can tell).  The replacement assembler yaYUL accepts 
# a slightly different format for the source code from what YUL accepted, so the 
# source code has been targeted for assembly with yaYUL.

# What follows is simply a bunch of file-includes for the individual code chunks.
# I've marked the page numbers vs. the original scanned listing (1729.pdf) to 
# make proof-reading easier.  Besides, the scanned listing contains a lot of
# interesting tables (cross-referenced to page numbers) created by YUL, 
# but not duplicated by yaYUL, so it's still valuable even if the source-files
# listed below are in hand.  Notice, though, that the page number herein are those
# the scanned (PDF) file, and not those which are marked on the scanned pages
# themselves, so there is not an exact correspondence between YUL-generated
# page numbers appearing within tables and the page numbers marked in this source
# code.

$ASSEMBLY_AND_OPERATION_INFORMATION.agc		        # pp. 1-27
$TAGS_FOR_RELATIVE_SETLOC_AND_BLANK_BANK_CARDS.agc	# pp. 28-37
$CONTROLLED_CONSTANTS.agc			        # pp. 38-53
$INPUT_OUTPUT_CHANNEL_BIT_DESCRIPTIONS.agc	        # pp. 54-60
$FLAGWORD_ASSIGNMENTS.agc			        # pp. 61-88
						        # p.  89 is a YUL-generated table

# LUMERASE						
$ERASABLE_ASSIGNMENTS.agc			        # pp. 90-154

# LEMONAID
$INTERRUPT_LEAD_INS.agc				        # pp. 155-156
$T4RUPT_PROGRAM.agc				        # pp. 157-191
$RCS_FAILURE_MONITOR.agc			        # pp. 192-194
$DOWNLINK_LISTS.agc				        # pp. 195-207
$AGS_INITIALIZATION.agc				        # pp. 208-212
$FRESH_START_AND_RESTART.agc			        # pp. 213-238
$RESTART_TABLES.agc				        # pp. 239-244
$AOTMARK.agc					        # pp. 245-262
$EXTENDED_VERBS.agc				        # pp. 263-302
$PINBALL_NOUN_TABLES.agc			        # pp. 303-321
$LEM_GEOMETRY.agc				        # pp. 322-327
$IMU_COMPENSATION_PACKAGE.agc			        # pp. 328-339
$R63.agc					        # pp. 340-343
$ATTITUDE_MANEUVER_ROUTINE.agc			        # pp. 344-365
$GIMBAL_LOCK_AVOIDANCE.agc			        # p.  366
$KALCMANU_STEERING.agc				        # pp. 367-371
$SYSTEM_TEST_STANDARD_LEAD_INS.agc		        # pp. 372-374
$IMU_PERFORMANCE_TESTS_2.agc			        # pp. 375-383
$IMU_PERFORMANCE_TESTS_4.agc			        # pp. 384-391
$PINBALL_GAME__BUTTONS_AND_LIGHTS.agc		        # pp. 392-475
$R60,R62.agc					        # pp. 476-489
$S-BAND_ANTENNA_FOR_LM.agc			        # pp. 490-493
		
# LEMP20S
$RADAR_LEADIN_ROUTINES.agc			        # pp. 494-495
$P20-P25.agc					        # pp. 496-618

# LEMP30S
$P30,P37.agc					        # pp. 619-622
$P32-P35,_P72-P75.agc				        # pp. 623-655

# KISSING
$GROUND_TRACKING_DETERMINATION_PROGRAM_-_P21.agc	# pp. 656-659
$P34-P35,_P74-P75.agc				        # pp. 660-704
$R31.agc					        # pp. 705-710
$P76.agc					        # pp. 711-713
$R30.agc					        # pp. 714-724

# FLY
$BURN,_BABY,_BURN_--_MASTER_IGNITION_ROUTINE.agc	# pp. 725-746
$P40-P47.agc					        # pp. 747-779
$THE_LUNAR_LANDING.agc				        # pp. 780-787
$THROTTLE_CONTROL_ROUTINES.agc			        # pp. 788-792
$LUNAR_LANDING_GUIDANCE_EQUATIONS.agc		        # pp. 793-822
$P70-P71.agc					        # pp. 823-830
$P12.agc					        # pp. 831-835
$ASCENT_GUIDANCE.agc				        # pp. 836-851
$SERVICER.agc					        # pp. 852-890
$LANDING_ANALOG_DISPLAYS.agc			        # pp. 891-901
$FINDCDUW_-_GUIDAP_INTERFACE.agc		        # pp. 902-920

# LEMP50S
$P51-P53.agc					        # pp. 921-977
$LUNAR_AND_SOLAR_EPHEMERIDES_SUBROUTINES.agc	        # pp. 978-981

# SKIPPER
$DOWN-TELEMETRY_PROGRAM.agc			        # pp. 982-991
$INTER-BANK_COMMUNICATION.agc			        # pp. 992-995
$INTERPRETER.agc				        # pp. 996-1088
$FIXED-FIXED_CONSTANT_POOL.agc			        # pp. 1089-1093
$INTERPRETIVE_CONSTANTS.agc			        # pp. 1094-1095
$SINGLE_PRECISION_SUBROUTINES.agc		        # p.  1096
$EXECUTIVE.agc					        # pp. 1097-1110
$WAITLIST.agc					        # pp. 1111-1126
$LATITUDE_LONGITUDE_SUBROUTINES.agc		        # pp. 1127-1133
$PLANETARY_INERTIAL_ORIENTATION.agc		        # pp. 1134-1142
$MEASUREMENT_INCORPORATION.agc			        # pp. 1143-1152
$CONIC_SUBROUTINES.agc				        # pp. 1153-1197
$INTEGRATION_INITIALIZATION.agc			        # pp. 1198-1219
$ORBITAL_INTEGRATION.agc			        # pp. 1220-1240
$INFLIGHT_ALIGNMENT_ROUTINES.agc		        # pp. 1241-1250
$POWERED_FLIGHT_SUBROUTINES.agc			        # pp. 1251-1259
$TIME_OF_FREE_FALL.agc				        # pp. 1260-1275
$AGC_BLOCK_TWO_SELF-CHECK.agc			        # pp. 1276-1285
$PHASE_TABLE_MAINTENANCE.agc			        # pp. 1286-1294
$RESTARTS_ROUTINE.agc				        # pp. 1295-1300
$IMU_MODE_SWITCHING_ROUTINES.agc		        # pp. 1301-1329
$KEYRUPT,_UPRUPT.agc				        # pp. 1330-1332
$DISPLAY_INTERFACE_ROUTINES.agc			        # pp. 1333-1365
$SERVICE_ROUTINES.agc				        # pp. 1366-1372
$ALARM_AND_ABORT.agc				        # pp. 1373-1377
$UPDATE_PROGRAM.agc				        # pp. 1378-1388
$RTB_OP_CODES.agc				        # pp. 1389-1394

# LMDAP
$T6-RUPT_PROGRAMS.agc				        # pp. 1395-1397
$DAP_INTERFACE_SUBROUTINES.agc			        # pp. 1398-1401
$DAPIDLER_PROGRAM.agc				        # pp. 1402-1412
$P-AXIS_RCS_AUTOPILOT.agc			        # pp. 1413-1433
$Q,R-AXES_RCS_AUTOPILOT.agc			        # pp. 1434-1451
$TJET_LAW.agc					        # pp. 1452-1461
$KALMAN_FILTER.agc				        # pp. 1462-1463
$TRIM_GIMBAL_CONTROL_SYSTEM.agc			        # pp. 1464-1476
$AOSTASK_AND_AOSJOB.agc				        # pp. 1477-1498
$SPS_BACK-UP_RCS_CONTROL.agc			        # pp. 1499-1502
						        # pp. 1503-1736: YUL-generated tables.

