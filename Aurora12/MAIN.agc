### FILE="Main.annotation"
# Copyright:    Public domain.
# Filename:     MAIN.agc
# Purpose:      Part of the source code for Aurora (revision 12),
# Assembler:    yaYUL
# Contact:      Ron Burkey <info@sandroid.org>.
# Website:      https://www.ibiblio.org/apollo/index.html
# Page Scans:   https://archive.org/details/aurora00dapg
# Mod history:  2016-09-20 JL   Created.
#               
# MAIN.agc is a little different from the other Aurora12 files  
# provided, in that it doesn't represent anything that appears 
# directly in the original source.  What we have done for 
# organizational purposes is to split the huge monolithic source 
# code into smaller, more manageable chunks--i.e., into individual
# source files.  Those files are rejoined within this file as 
# "includes".  It just makes it a little easier to work with.  The
# code chunks correspond to natural divisions into sub-programs.  
# The divisions are by the assembly listing itself.

# Source file name                                Starting Page
# ----------------                                -------------

$ASSEMBLY_AND_OPERATION_INFORMATION.agc		# 1
$ERASABLE_ASSIGNMENTS.agc			# 7
$INPUT_OUTPUT_CHANNELS.agc			# 26
$INTERRUPT_LEAD_INS.agc				# 27
$INTER-BANK_COMMUNICATION.agc			# 29
$LIST_PROCESSING_INTERPRETER.agc		# 34
$SINGLE_PRECISION_SUBROUTINES.agc		# 123
$EXECUTIVE.agc					# 126
$WAITLIST.agc					# 139
$PHASE_TABLE_MAINTENANCE.agc			# 148
$FRESH_START_AND_RESTART.agc			# 151
$T4RUPT_PROGRAM.agc				# 160
$IMU_MODE_SWITCHING_ROUTINES.agc		# 189
$IMU_COMPENSATION_PACKAGE.agc			# 209
$AOTMARK.agc					# 218
$RADAR_LEAD-IN_ROUTINES.agc			# 227
$RADAR_TEST_PROGRAMS.agc			# 256
$EXTENDED_VERBS.agc				# 258
$KEYRUPT,_UPRUPT.agc				# 285
$PINBALL_GAME__BUTTONS_AND_LIGHTS.agc		# 289
$ALARM_AND_ABORT.agc				# 366
$CONTROLLER_AND_METER_ROUTINES.agc		# 368
$DOWN-TELEMETRY_PROGRAM.agc			# 370
$AGC_BLOCK_TWO_SELF-CHECK.agc			# 377
$INFLIGHT_ALIGNMENT_ROUTINES.agc		# 404
$RTB_OP_CODES.agc				# 425
$LEM_FLIGHT_CONTROL_SYSTEM_TEST.agc		# 431
$IMU_PERFORMANCE_TESTS_1.agc			# 444
$IMU_PERFORMANCE_TESTS_2.agc			# 475
$IMU_PERFORMANCE_TESTS_3.agc			# 500
$OPTIMUM_PRELAUNCH_ALIGNMENT_CALIBRATION.agc	# 514
$DIGITAL_AUTOPILOT_ERASABLE.agc			# 535
$P-AXIS_REACTION_CONTROL_SYSTEM_AUTOPILOT.agc	# 542
$DAPIDLER_PROGRAM.agc				# 557
$Q,R-AXES_REACTION_CONTROL_SYSTEM_AUTOPILOT.agc	# 562
$JET_FAILURE_CONTROL_LOGIC.agc			# 594
$KALMAN_FILTER_FOR_LEM_DAP.agc			# 604
$TRIM_GIMBAL_CONTROL_SYSTEM.agc			# 615
$AOSTASK.agc					# 630
$RCS_FAILURE_MONITOR.agc			# 635
$ASCENT_INERTIA_UPDATER.agc			# 639
$SUM_CHECK_END_OF_BANK_MARKERS.agc		# 642

#Assembly-tables                                # 644
