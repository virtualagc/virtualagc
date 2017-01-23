### FILE="Main.annotation"
# Copyright:	Public domain.
# Filename:	MAIN.agc
# Purpose:	The main source file for revision 0 of BURST120 (Sunburst).
#		It is part of the source code for the Lunar Module's (LM)
#		Apollo Guidance Computer (AGC) for Apollo 5.
# Assembler:	yaYUL
# Contact:	Ron Burkey <info@sandroid.org>.
# Website:	www.ibiblio.org/apollo/index.html
# Mod history:	2016-09-29 RSB	Created draft version.
#		2016-09-30 RSB	Should be complete now.
#
# From the library of Don Eyles, scanned at archive.org, sponsored financially
# by Mike Stewart, and transcribed by a team of volunteers.
#
# Notations on this document read, in part:
#
#	YUL SYSTEM FOR AGC: REVISION 0 OF PROGRAM BURST120 BY NASA 2021106-031
#	DEC 7, 1967
#	...
#	THIS LISTING IS A COPY OF A VERSION OF THE PROGRAM INTENDED FOR USE IN
#	THE ON-BOARD PRIMARY GUIDANCE COMPUTER IN THE UNMANNED FLIGHT OF
#	APOLLO LUNAR MODULE 1 --- THE AS206 MISSION.
#	...
#
# Note that this is the date the hardcopy was made, not the date of the program 
# revision or the assembly.
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
# file's TABLE OF LOG CARDS.

$ASSEMBLY_AND_OPERATION_INFORMATION.agc			# p. 1
$ERASABLE_ASSIGNMENTS.agc				# p. 12
$INPUT_OUTPUT_CHANNELS.agc				# p. 59
$INTERRUPT_LEAD_INS.agc					# p. 60
$RESTART_TABLES_AND_RESTARTS_ROUTINE.agc		# p. 62
$PHASE_TABLE_MAINTENANCE.agc				# p. 77
$FRESH_START_AND_RESTART.agc				# p. 88
$T4RUPT_PROGRAM.agc					# p. 104
$IMU_MODE_SWITCHING_ROUTINES.agc			# p. 137
$AOTMARK.agc						# p. 159
$RADAR_LEADIN_ROUTINES.agc				# p. 168
$RADAR_TEST_PROGRAMS.agc				# p. 198
$EXTENDED_VERBS.agc					# p. 200
$KEYRUPT,_UPRUPT.agc					# p. 228
$PINBALL_GAME__BUTTONS_AND_LIGHTS.agc			# p. 232
$ALARM_AND_ABORT.agc					# p. 313
$UPDATE_PROGRAM_PART_1_OF_2.agc				# p. 316
$UPDATE_PROGRAM_PART_2_OF_2.agc				# p. 321
$DOWN-TELEMETRY_PROGRAM.agc				# p. 329
$INFLIGHT_ALIGNMENT_ROUTINES.agc			# p. 340
$RTB_OP_CODES.agc					# p. 360
$LEM_FLIGHT_CONTROL_SYSTEM_TEST.agc			# p. 367
$IMU_PERFORMANCE_TESTS_1.agc				# p. 380
$IMU_PERFORMANCE_TESTS_2.agc				# p. 411
$IMU_PERFORMANCE_TESTS_3.agc				# p. 436
$OPTIMUM_PRELAUNCH_ALIGNMENT_CALIBRATION.agc		# p. 450
$DAP_INTERFACE_SUBROUTINES.agc				# p. 473
$T6-RUPT_PROGRAMS.agc					# p. 483
$DAPIDLER_PROGRAM.agc					# p. 487
$P-AXIS_REACTION_CONTROL_SYSTEM_AUTOPILOT.agc		# p. 492
$Q,R-AXES_REACTION_CONTROL_SYSTEM_AUTOPILOT.agc		# p. 519
$Q,R-AXES_JET_SELECT_AND_FAILURE_CONTROL_LOGIC.agc	# p. 554
$RCS_FAILURE_MONITOR.agc				# p. 569
$KALMAN_FILTER_FOR_LM_DAP.agc				# p. 574
$TRIM_GIMBAL_CONTROL_SYSTEM.agc				# p. 591
$AOSTASK_AND_AOSJOB.agc					# p. 605
$SPS_BACK-UP_RCS_CONTROL.agc				# p. 629
$ATTITUDE_MANEUVER_ROUTINE.agc				# p. 636
$GIMBAL_LOCK_AVOIDANCE.agc				# p. 661
$KALCMANU_STEERING.agc					# p. 668
$MISSION_PHASE_2_GUIDANCE_REFERENCE_RELEASE_PLUS_BOOST_MONITOR.agc # p. 673
$MP_3_SUBORBITAL_ABORT.agc				# p. 686
$MP4-CONTINGENCY_ORBIT_INSERTION.agc			# p. 696
$MISSION_PHASE_6_COAST_SIVB_ATTACHED.agc		# p. 709
$MP_7-SIVB_LEM_SEPARATION.agc				# p. 712
$MISSION_PHASE_8-DPS_COLD_SOAK.agc			# p. 720
$MP9-DPS_1_BURN.agc					# p. 728
$MISSION_PHASE_11-DPS2_FITH_APS1.agc			# p. 739
$MISSION_PHASE_13-APS2.agc				# p. 754
$MISSION_PHASE_16-RCS_COLD_SOAK.agc			# p. 764
$INTEGRATION_INITIALIZATION.agc				# p. 766
$ORBITAL_INTEGRATION_PROGRAM.agc			# p. 776
$LMP_COMMAND_ROUTINES.agc				# p. 799
$AS206_MISSION_SCHEDULING_PACKAGE.agc			# p. 801
$206_SERVICE_ROUTINES.agc				# p. 815
$TUMBLE_MONITOR.agc					# p. 832
$PIPA_READER.agc					# p. 835
$FIND_CDU_DESIRED.agc					# p. 838
$AVERAGE_G_INTEGRATOR.agc				# p. 842
$MASS_CALCULATOR.agc					# p. 844
$THROTTLE_CONTROL.agc					# p. 849
$IMU_COMPENSATION_PACKAGE.agc				# p. 859
$DUMMY_206_INITIALIZATION.agc				# p. 869
$SECOND_DPS_GUIDANCE.agc				# p. 871
$PREBURN_FOR_APS2.agc					# p. 911
$ASCENT_STEERING.agc					# p. 913
$THRUST_MAGNITUDE_FILTER.agc				# p. 923
$LOGSUB_ROUTINE.agc					# p. 925
$LAMB.agc						# p. 926
$SUM_CHECK_END_OF_BANK_MARKERS.agc			# p. 946
$INTER-BANK_COMMUNICATION.agc				# p. 948
$INTERPRETER.agc					# p. 953
$SINGLE_PRECISION_SUBROUTINES.agc			# p. 1046
$EXECUTIVE.agc						# p. 1049
$WAITLIST.agc						# p. 1062
$AGC_BLOCK_TWO_SELF-CHECK.agc				# p. 1075
							# p. 1101, YUL-generated info
