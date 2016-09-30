### FILE="Main.annotation"
# Copyright:	Public domain.
# Filename:	MAIN.agc
# Purpose:	The main source file for revision 0 of BURST120 (Sunburst).
#		It is part of the source code for the Lunar Module's (LM)
#		Apollo Guidance Computer (AGC) for Apollo 5.
# Assembler:	yaYUL
# Contact:	Ron Burkey <info@sandroid.org>.
# Website:	www.ibiblio.org/apollo/index.html
# Mod history:	2016-09-29 RSB	Created template file.
#
# From the library of Don Eyles, scanned at archive.org, sponsored financially
# by Mike Stewart, and transcribed by a team of volunteers.
#
# Notations on this document read, in part:
#
#	YUL SYSTEM FOR AGC: REVISION 0 OF PROGRAM BURST120 BY NASA 2021106-031
#	DEC 7, 1967
#	[Note that this is the date the hardcopy was made, not the
#	date of the program revision or the assembly.]
#	...
#	THIS LISTING IS A COPY OF A VERSION OF THE PROGRAM INTENDED FOR USE IN
#	THE ON-BOARD PRIMARY GUIDANCE COMPUTER IN THE UNMANNED FLIGHT OF
#	APOLLO LUNAR MODULE 1 --- THE AS206 MISSION.
#	...
#
# The page images themselves, as reduced in size (and consequently in
# quality) to be suitable for online presentation, are available at 
# http://www.ibiblio.org/apollo/ScansForConversion/Sunburst120.  If
# you want to see the (much) higher quality original scans, visit
# http://www.archive.org/details/virtualagcproject. 
#
# This file is a little different from the other BURST120 AGC source-code files, 
# in that it doesn't represent anything that appears directly in the original source.  
# For organizational purposes, the huge monolithic source code has been split
# into smaller, more manageable chunks--i.e., into individual source 
# files.  Those files are rejoined within this file as "includes".  It just makes
# it a little easier to work with.  The code chunks correspond to natural divisions
# into sub-programs.  In fact, these divisions are more-or-less specified by
# the source code itself.  Refer to the ASSEMBLY_AND_OPERATION_INFORMATION.agc
# file's TABLE OF LOG CARDS..

$ASSEMBLY_AND_OPERATION_INFORMATION.agc		# pp. 2-27
$ERASABLE_ASSIGNMENTS.agc			# pp. 90-152
$INPUT_OUTPUT_CHANNELS.agc			# pp. 54-60
$INTERRUPT_LEAD_INS.agc				# pp. 153-154
$RESTART_TABLES_AND_RESTARTS_ROUTINE.agc	# pp. 1303-1308
$PHASE_TABLE_MAINTENANCE.agc			# pp. 1294-1302
$FRESH_START_AND_RESTART.agc			# pp. 211-237
$T4RUPT_PROGRAM.agc				# pp. 155-189
$IMU_MODE_SWITCHING_ROUTINES.agc		# pp. 1309-1337
$AOTMARK.agc					# pp. 244-261
$RADAR_LEADIN_ROUTINES.agc			# pp. 490-491
$RADAR_TEST_PROGRAMS.agc			# pp. TBD
$EXTENDED_VERBS.agc				# pp. TBD
$KEYRUPT_UPRUPT.agc				# pp. 1338-1340
$PINBALL_GAME_BUTTONS_AND_LIGHTS.agc		# pp. 390-471
$ALARM_AND_ABORT.agc				# pp. 1381-1385
$UPDATE_PROGRAM_PART_1_OF_2.agc			# pp. 1386-1396
$UPDATE_PROGRAM_PART_2_OF_2.agc			# pp. 1386-1396
$DOWN_TELEMETRY_PROGRAM.agc			# pp. 988-997
$INFLIGHT_ALIGNMENT_ROUTINES.agc		# pp. 1249-1258
$RTB_OP_CODES.agc				# pp. 1397-1402
$LEM_FLIGHT_CONTROL_SYSTEM_TEST.agc		# pp. TBD
$IMU_PERFORMANCE_TESTS_1.agc			# pp. 373-381
$IMU_PERFORMANCE_TESTS_2.agc			# pp. 382-389
$IMU_PERFORMANCE_TESTS_3.agc			# pp. 382-389
$OPTIMUM_PRELAUNCH_ALIGNMENT_CALIBRATION.agc	# pp. TBD
$DAP_INTERFACE_SUBROUTINES.agc			# pp. 1406-1409
$T6-RUPT_PROGRAMS.agc				# pp. 1403-1405
$DAPIDLER_PROGRAM.agc				# pp. 1410-1420
$P-AXIS_REACTION_CONTROL_SYSTEM_AUTOPILOT.agc			# pp. 1421-1441
$Q_R-AXES_REACTION_CONTROL_SYSTEM_AUTOPILOT.agc			# pp. 1442-1459
$Q_R-AXES_JET_SELECT_AND_FAILURE_CONTROL_LOGIC.agc		# pp. TBD
$RCS_FAILURE_MONITOR.agc				# pp. 190-192
$KALMAN_FILTER_FOR_LM_DAP.agc				# pp. 1470-1471
$TRIM_GIMBAL_CONTROL_SYSTEM.agc			# pp. 1472-1484
$AOSTASK_AND_AOSJOB.agc				# pp. 1485-1506
$SPS_BACK-UP_RCS_CONTROL.agc			# pp. 1507-1510
$ATTITUDE_MANEUVER_ROUTINE.agc			# pp. 342-363
$GIMBAL_LOCK_AVOIDANCE.agc			# p.  364
$KALCMANU_STEERING.agc				# pp. 365-369
$MISSION_PHASE_2_GUIDANCE_REFERENCE_RELEASE_PLUS_BOOST_MONITOR.agc	# pp. TBD
$MP_3_SUBORBITAL_ABORT.agc			# pp. TBD
$MP4-CONTINGENCY_ORBIT_INSERTION.agc		# pp. TBD
$MISSION_PHASE_6_COAST_SIVB_ATTACHED.agc	# pp. TBD
$MP_7-SIVB_LEM_SEPARATION.agc			# pp. TBD
$MISSION_PHASE_8-DPS_COLD_SOAK.agc		# pp. TBD
$MP9-DPS_1_BURN.agc				# pp. TBD
$MISSION_PHASE_11-DPS2_FITH_APS1.agc		# pp. TBD
$MISSION_PHASE_13-APS2.agc			# pp. TBD
$MISSION_PHASE_16-RCS_COLD_SOAK.agc		# pp. TBD
$INTEGRATION_INITIALIZATION.agc			# pp. 1205-1226
$ORBITAL_INTEGRATION_PROGRAM.agc			# pp. 1227-1248
$LMP_COMMAND_ROUTINES.agc			# pp. TBD
$AS206_MISSION_SCHEDULING_PACKAGE.agc		# pp. TBD
$206_SERVICE_ROUTINES.agc			# pp. TBD
$TUMBLE_MONITOR.agc				# pp. TBD
$PIPA_READER.agc				# pp. TBD
$FIND_CDU_DESIRED.agc			# pp. 908-925
$AVERAGE_G_INTEGRATOR.agc			# pp. TBD
$MASS_CALCULATOR.agc				# pp. TBD
$THROTTLE_CONTROL.agc			# pp. 793-797
$IMU_COMPENSATION_PACKAGE.agc			# pp. 326-337
$DUMMY_206_INITIALIZATION.agc			# pp. TBD
$SECOND_DPS_GUIDANCE.agc			# pp. TBD
$PREBURN_FOR_APS2.agc				# pp. TBD
$ASCENT_STEERING.agc				# pp. 843-856
$THRUST_MAGNITUDE_FILTER.agc			# pp. TBD
$LOGSUB_ROUTINE.agc				# pp. TBD
$LAMB.agc			# pp. 651-653
$SUM_CHECK_END_OF_BANK_MARKERS.agc		# pp. TBD
$INTER-BANK_COMMUNICATION.agc			# pp. 998-1001
$INTERPRETER.agc				# pp. 1002-1094
$SINGLE_PRECISION_SUBROUTINES.agc		# p.  1102
$EXECUTIVE.agc					# pp. 1103-1116
$WAITLIST.agc					# pp. 1117-1132
$AGC_BLOCK_TWO_SELF_CHECK.agc			# pp. 1284-1293
						# pp. 1511-1743: GAP-generated tables.




