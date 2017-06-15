### FILE="Main.annotation"
# Copyright:	Public domain.
# Filename:	MAIN.agc
# Purpose:	The main source file for revision 37 of Sunburst, otherwise
#		known as (and assembled as) revision 0 of Shepatin. It is an
#		early development version of the software for Apollo 5, the
#		unmanned LM mission. Shepatin was an offline development
#		branch created by Don Eyles; however, this version doesn't
#		contain any of the changes Shepatin would go on to have.
# Assembler:	yaYUL
# Contact:	Ron Burkey <info@sandroid.org>.
# Website:	www.ibiblio.org/apollo/index.html
# Mod history:	2017-05-24 MAS	Created draft version.
#
# This program is the "zeroth" revision of the development branch Shepatin
# created by Don Eyles. It is identical to revision 37 of Sunburst, the
# software for the Apollo 5 unmanned Lunar Module mission.
#
# MAIN.agc is a little different from the other BURST120 AGC source-code files, 
# in that it doesn't represent anything that appears directly in the original source.  
# For organizational purposes, the huge monolithic source code has been split
# into smaller, more manageable chunks--i.e., into individual source 
# files.  Those files are rejoined within this file as "includes".  It just makes
# it a little easier to work with.  The code chunks correspond to natural divisions
# into sub-programs.  In fact, these divisions are more-or-less specified by
# the source code itself.  Refer to the ASSEMBLY_AND_OPERATION_INFORMATION.agc
# file's TABLE OF LOG CARDS.

$ASSEMBLY_AND_OPERATION_INFORMATION.agc			# pp. 1-9
$ERASABLE_ASSIGNMENTS.agc				# pp. 10-52
$INPUT_OUTPUT_CHANNELS.agc				# p.  53
$INTERRUPT_LEAD_INS.agc					# pp. 54-55
$RESTART_TABLES_AND_RESTARTS_ROUTINE.agc		# pp. 56-66
$PHASE_TABLE_MAINTENANCE.agc				# pp. 67-77
$FRESH_START_AND_RESTART.agc				# pp. 78-89
$T4RUPT_PROGRAM.agc					# pp. 90-123
$IMU_MODE_SWITCHING_ROUTINES.agc			# pp. 124-145
$AOTMARK.agc						# pp. 146-154
$RADAR_LEAD-IN_ROUTINES.agc				# pp. 155-184
$RADAR_TEST_PROGRAMS.agc				# pp. 185-186
$EXTENDED_VERBS.agc					# pp. 187-214
$KEYRUPT,_UPRUPT.agc					# pp. 215-218
$PINBALL_GAME__BUTTONS_AND_LIGHTS.agc			# pp. 219-299
$ALARM_AND_ABORT.agc					# pp. 300-302
$UPDATE_PROGRAM_PART_1_OF_2.agc				# pp. 303-304
$UPDATE_PROGRAM_PART_2_OF_2.agc				# pp. 305-310
$DOWN-TELEMETRY_PROGRAM.agc				# pp. 311-321
$INFLIGHT_ALIGNMENT_ROUTINES.agc			# pp. 322-341
$RTB_OP_CODES.agc					# pp. 342-347
$LEM_FLIGHT_CONTROL_SYSTEM_TEST.agc			# pp. 348-360
$IMU_PERFORMANCE_TESTS_1.agc				# pp. 361-390
$IMU_PERFORMANCE_TESTS_2.agc				# pp. 391-415
$IMU_PERFORMANCE_TESTS_3.agc				# pp. 416-429
$OPTIMUM_PRELAUNCH_ALIGNMENT_CALIBRATION.agc		# pp. 430-452
$DAP_INTERFACE_SUBROUTINES.agc				# pp. 453-459
$T6-RUPT_PROGRAMS.agc					# pp. 460-462
$DAPIDLER_PROGRAM.agc					# pp. 463-467
$P-AXIS_REACTION_CONTROL_SYSTEM_AUTOPILOT.agc		# pp. 468-490
$Q,R-AXES_REACTION_CONTROL_SYSTEM_AUTOPILOT.agc		# pp. 491-519
$Q,R-AXES_JET_SELECT_AND_FAILURE_CONTROL_LOGIC.agc	# pp. 520-534
$RCS_FAILURE_MONITOR.agc				# pp. 535-537
$ASCENT_INERTIA_UPDATER.agc				# pp. 538-540
$KALMAN_FILTER_FOR_LM_DAP.agc				# pp. 541-553
$TRIM_GIMBAL_CONTROL_SYSTEM.agc				# pp. 554-568
$AOSTASK_AND_AOSJOB.agc					# pp. 569-590
$SPS_BACK-UP_RCS_CONTROL.agc				# pp. 591-594
$ATTITUDE_MANEUVER_ROUTINE.agc				# pp. 595-619
$GIMBAL_LOCK_AVOIDANCE.agc				# pp. 620-626
$KALCMANU_STEERING.agc					# pp. 627-631
$MISSION_PHASE_2_GUIDANCE_REFERENCE_RELEASE_PLUS_BOOST_MONITOR.agc # pp. 632-643
$MP_3_-_SUBORBITAL_ABORT.agc				# pp. 644-653
$MP4-CONTINGENCY_ORBIT_INSERTION.agc			# pp. 654-665
$MISSION_PHASE_6_COAST_SIVB_ATTACHED.agc		# pp. 666-668
$MP_7_-_SIVB_LEM_SEPARATION.agc				# pp. 669-675
$MISSION_PHASE_8_-_DPS_COLD_SOAK.agc			# pp. 676-683
$MP9-DPS_1_BURN.agc					# pp. 684-692
$MISSION_PHASE_11_-_DPS2_FITH_APS1.agc			# pp. 693-703
$MISSION_PHASE_13_-_APS2.agc				# pp. 704-710
$MISSION_PHASE_16_-_RCS_COLD_SOAK.agc			# pp. 711-712
$INTEGRATION_INITIALIZATION.agc				# pp. 713-722
$ORBITAL_INTEGRATION_PROGRAM.agc			# pp. 723-745
$LMP_COMMAND_ROUTINES.agc				# pp. 746-747
$AS206_MISSION_SCHEDULING_PACKAGE.agc			# pp. 748-762
$THRUST_MISSION_CONTROL_PROGRAM_TJS.agc			# pp. 763-776
$TUMBLE_MONITOR.agc					# pp. 777-779
$PIPA_READER.agc					# pp. 780-783
$FIND_CDU_DESIRED.agc					# pp. 784-787
$AVERAGE_G_INTEGRATOR.agc				# pp. 788-794
$THROTTLE_CONTROL.agc					# pp. 795-801
$IMU_COMPENSATION_PACKAGE.agc				# pp. 802-811
$DUMMY_206_INITIALIZATION.agc				# pp. 812-813
$SECOND_DPS_GUIDANCE.agc				# pp. 814-850
$PREBURN_FOR_APS2.agc					# pp. 851-852
$ASCENT_STEERING.agc					# pp. 853-861
$THRUST_MAGNITUDE_FILTER.agc				# pp. 862-863
$LOGSUB_ROUTINE.agc					# p.  864
$LAMB.agc						# pp. 865-884
$SUM_CHECK_END_OF_BANK_MARKERS.agc			# pp. 885-886
$SUBROUTINES.agc					# p.  887
$INTER-BANK_COMMUNICATION.agc				# pp. 888-892
$INTERPRETER.agc					# pp. 893-984
$SINGLE_PRECISION_SUBROUTINES.agc			# pp. 985-987
$EXECUTIVE.agc						# pp. 988-1000
$WAITLIST.agc						# pp. 1001-1013
$AGC_BLOCK_TWO_SELF-CHECK.agc				# pp. 1014-1037
							# pp. 1038-1223, YUL-generated info
