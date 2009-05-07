# Copyright:	Public domain.
# Filename:	MAIN.s
# Purpose:	The main source file for Luminary 1A, revision 099.
#		It is part of the source code for the Lunar Module's (LM)
#		Apollo Guidance Computer (AGC) for Apollo 11.
# Assembler:	yaYUL
# Contact:	Ron Burkey <info@sandroid.org>.
# Website:	www.ibiblio.org/apollo/index.html
# Mod history:	2009-05-05 RSB	Adapted from Luminary131/MAIN.s.
#
# The contents of the "Luminary099" files, in general, are
# transcribed from a digital images created from a hardcopy of the program
# residing at the MIT Museum.  Many thanks to Debbie Douglas of the Museum,
# and to Paul Fjeld (who made the images).
#
# Notations on this document read, in part:
#
#	ASSEMBLE REVISION 001 OF AGC PROGRAM LMY99 BY NASA 2021112-061
#	16:27 JULY 14,1969
#	[Note that this is the date the hardcopy was made, not the
#	date of the program revision or the assembly.]
#	...
#	THIS LGC PROGRAM IS INTENDED FOR USE IN THE LM DURING THE MANNED
#	LUNAR LANDING MISSION OR ANY SUBSET THEREOF.
#	...
#
# The page images themselves, as reduced in size (and consequently in
# quality) to be suitable for online presentation, are available at 
# http://www.ibiblio.org/apollo.  If you want to see the (much) higher
# quality digital images that Paul actually made, contact info@sandroi.org
# directly.
#
# This file is a little different from the other Luminary099 files I'm providing, 
# in that it doesn't represent anything that appears directly in the original source.  
# What I (RSB) have done for organizational purposes is to split the huge monolithic
# source code into smaller, more manageable chunks--i.e., into individual source 
# files.  Those files are rejoined within this file as "includes".  It just makes
# it a little easier to work with.  The code chunks correspond to natural divisions
# into sub-programs.  In fact, these divisions are more-or-less specified by
# the source code itself.  Refer to the "TABLE OF SUBROUTINE LOG SECTIONS" at the
# very beginning of the file ASSEMBLY_AND_OPERATION_INFORMATION.s.
#
# It may be reasonably asked why tens of thousands of lines of source are joined by
# means of inclusion, rather than simply assembling the source files individually and
# then linking them to form the executable.  The answer is that the original 
# development team had no linker.  The builds were monolithic just like this.
# There was a big emphasis on reusability of the code in the original project, 
# apparently, but this reusability took the form of inserting your deck of 
# punch-cards at the appropriate position in somebody else's deck of punch-cards.
# (Actually, I believe a tape-library method was used to avoid having to continually
# reload the card decks, but that doesn't change the basic principle.)
# So, indeed, the method of file-inclusion is a very fair representation of the 
# methods used in the original development ... with the improvement, of course,
# that you no longer have to worry about dropping the card deck.  On the other hand, 
# I wasn't there at the time, so I may have no idea what I'm talking about.
#
# Finally, note that the original Apollo AGC assembler (called "YUL") is no longer 
# available (as far as I can tell).  In fact, it was replaced by another assembler
# ("GAP") even before Apollo 11, but GAP is no more available than is YUL.  The 
# replacement assembler yaYUL accepts a slightly different format for the source 
# code from what YUL or GAP accepted, so the source code has been targeted for 
# assembly with yaYUL.

# What follows is simply a bunch of file-includes for the individual code chunks.
# I've marked the page numbers to make proof-reading easier.  Besides, the digital
# images of the assembly listing contains a lot of interesting tables (cross-
# referenced to page numbers) created by GAP, but not duplicated by yaYUL, so it's
# still valuable even if the source-files listed below are at hand.

$CONTRACT_AND_APPROVALS.s			# p. 1
$ASSEMBLY_AND_OPERATION_INFORMATION.s		# pp. 2-27
$TAGS_FOR_RELATIVE_SETLOC.s			# pp. 28-37
$CONTROLLED_CONSTANTS.s				# pp. 38-53
$INPUT_OUTPUT_CHANNEL_BIT_DESCRIPTIONS.s	# pp. 54-60
$FLAGWORD_ASSIGNMENTS.s				# pp. 61-88
						# p.  89 is a GAP-generated table						
$ERASABLE_ASSIGNMENTS.s				# pp. 90-152
$INTERRUPT_LEAD_INS.s				# pp. 153-154
$T4RUPT_PROGRAM.s				# pp. 155-189
$RCS_FAILURE_MONITOR.s				# pp. 190-192
$DOWNLINK_LISTS.s				# pp. 193-205
$AGS_INITIALIZATION.s				# pp. 206-210
$FRESH_START_AND_RESTART.s			# pp. 211-237
$RESTART_TABLES.s				# pp. 238-243
$AOTMARK.s					# pp. 244-261
$EXTENDED_VERBS.s				# pp. 262-300
$PINBALL_NOUN_TABLES.s				# pp. 301-319
$LEM_GEOMETRY.s					# pp. 320-325
$IMU_COMPENSATION_PACKAGE.s			# pp. 326-337
$R63.s						# pp. 338-341
$ATTITUDE_MANEUVER_ROUTINE.s			# pp. 342-363
$GIMBAL_LOCK_AVOIDANCE.s			# p.  364
$KALCMANU_STEERING.s				# pp. 365-369
$SYSTEM_TEST_STANDARD_LEAD_INS.s		# pp. 370-372
$IMU_PERFORMANCE_TEST_2.s			# pp. 373-381
$IMU_PERFORMANCE_TESTS_4.s			# pp. 382-389
$PINBALL_GAME_BUTTONS_AND_LIGHTS.s		# pp. 390-471
$R60_62.s					# pp. 472-485
$S-BAND_ANTENNA_FOR_LM.s			# pp. 486-489
$RADAR_LEADIN_ROUTINES.s			# pp. 490-491
$P20-P25.s					# pp. 492-614
$P30_P37.s					# pp. 615-617
$P32-P35_P72-P75.s				# pp. 618-650
$LAMBERT_AIMPOINT_GUIDANCE.s			# pp. 651-653
$GROUND_TRACKING_DETERMINATION_PROGRAM.s	# pp. 654-657
$P34-35_P74-75.s				# pp. 658-702
$R31.s						# pp. 703-708
$P76.s						# pp. 709-711
$R30.s						# pp. 712-722
$STABLE_ORBIT.s					# pp. 723-730
$BURN_BABY_BURN--MASTER_IGNITION_ROUTINE.s	# pp. 731-751
$P40-P47.s					# pp. 752-784
$THE_LUNAR_LANDING.s				# pp. 785-792
$THROTTLE_CONTROL_ROUTINES.s			# pp. 793-797
$LUNAR_LANDING_GUIDANCE_EQUATIONS.s		# pp. 798-828
$P70-P71.s					# pp. 829-837
$P12.s						# pp. 838-842
$ASCENT_GUIDANCE.s				# pp. 843-856
$SERVICER.s					# pp. 857-897
$LANDING_ANALOG_DISPLAYS.s			# pp. 898-907
$FINDCDUW--GUIDAP_INTERFACE.s			# pp. 908-925
$P51-P53.s					# pp. 926-983
$LUNAR_AND_SOLAR_EPHEMERIDES_SUBROUTINES.s	# pp. 984-987
$DOWN_TELEMETRY_PROGRAM.s			# pp. 988-997
$INTER-BANK_COMMUNICATION.s			# pp. 998-1001
$INTERPRETER.s					# pp. 1002-1094
$FIXED_FIXED_CONSTANT_POOL.s			# pp. 1095-1099
$INTERPRETIVE_CONSTANT.s			# pp. 1100-1101
$SINGLE_PRECISION_SUBROUTINES.s			# p.  1102
$EXECUTIVE.s					# pp. 1103-1116
$WAITLIST.s					# pp. 1117-1132
$LATITUDE_LONGITUDE_SUBROUTINES.s		# pp. 1133-1139
$PLANETARY_INERTIAL_ORIENTATION.s		# pp. 1140-1148
$MEASUREMENT_INCORPORATION.s			# pp. 1149-1158
$CONIC_SUBROUTINES.s				# pp. 1159-1204
$INTEGRATION_INITIALIZATION.s			# pp. 1205-1226
$ORBITAL_INTEGRATION.s				# pp. 1227-1248
$INFLIGHT_ALIGNMENT_ROUTINES.s			# pp. 1249-1258
$POWERED_FLIGHT_SUBROUTINES.s			# pp. 1259-1267
$TIME_OF_FREE_FALL.s				# pp. 1268-1283
$AGC_BLOCK_TWO_SELF_CHECK.s			# pp. 1284-1293
$PHASE_TABLE_MAINTENANCE.s			# pp. 1294-1302
$RESTARTS_ROUTINE.s				# pp. 1303-1308
$IMU_MODE_SWITCHING_ROUTINES.s			# pp. 1309-1337
$KEYRUPT_UPRUPT.s				# pp. 1338-1340
$DISPLAY_INTERFACE_ROUTINES.s			# pp. 1341-1373
$SERVICE_ROUTINES.s				# pp. 1374-1380
$ALARM_AND_ABORT.s				# pp. 1381-1385
$UPDATE_PROGRAM.s				# pp. 1386-1396
$RTB_OP_CODES.s					# pp. 1397-1402
$T6-RUPT_PROGRAMS.s				# pp. 1403-1405
$DAP_INTERFACE_SUBROUTINES.s			# pp. 1406-1409
$DAPIDLER_PROGRAM.s				# pp. 1410-1420
$P-AXIS_RCS_AUTOPILOT.s				# pp. 1421-1441
$Q_R-AXIS_RCS_AUTOPILOT.s			# pp. 1442-1459
$TJET_LAW.s					# pp. 1460-1469
$KALMAN_FILTER.s				# pp. 1470-1471
$TRIM_GIMBAL_CNTROL_SYSTEM.s			# pp. 1472-1484
$AOSTASK_AND_AOSJOB.s				# pp. 1485-1506
$SPS_BACK-UP_RCS_CONTROL.s			# pp. 1507-1510
						# pp. 1511-1743: GAP-generated tables.




