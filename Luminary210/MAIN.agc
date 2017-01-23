### FILE="Main.annotation"
# Copyright:	Public domain.
# Filename:	MAIN.agc
# Purpose:	The main source file for Luminary revision 210.
#		It is part of the source code for the Lunar Module's (LM)
#		Apollo Guidance Computer (AGC) for Apollo 15-17.
# Assembler:	yaYUL
# Contact:	Ron Burkey <info@sandroid.org>.
# Website:	www.ibiblio.org/apollo/index.html
# Mod history:	2016-11-16 JL   Created.
#               2016-11-16 JL   Corrected page numbers and file names for Luminary210.
#
# Reference TBD.

$ABSOLUTE_ADDRESSES_FOR_UPDATE_PROGRAM.agc              # p. 1
$ASSEMBLY_AND_OPERATION_INFORMATION.agc		        # pp. 2-28
$TAGS_FOR_RELATIVE_SETLOC_AND_BLANK_BANK_CARDS.agc	# pp. 29-38
$CONTROLLED_CONSTANTS.agc			        # pp. 39-55
$INPUT_OUTPUT_CHANNEL_BIT_DESCRIPTIONS.agc	        # pp. 56-62
$FLAGWORD_ASSIGNMENTS.agc			        # pp. 63-90
$SUBROUTINE_CALLS.agc                                   # p. 91
$ERASABLE_ASSIGNMENTS.agc			        # pp. 92-160
$CHECK_EQUALS_LIST.agc                                  # pp. 161-162
$INTERRUPT_LEAD_INS.agc				        # pp. 163-164
$T4RUPT_PROGRAM.agc				        # pp. 165-200
$RCS_FAILURE_MONITOR.agc			        # pp. 201-203
$DOWNLINK_LISTS.agc				        # pp. 204-217
$AGS_INITIALIZATION.agc				        # pp. 218-221
$FRESH_START_AND_RESTART.agc			        # pp. 222-248
$RESTART_TABLES.agc				        # pp. 249-254
$AOTMARK.agc					        # pp. 255-274
$EXTENDED_VERBS.agc				        # pp. 275-312
$PINBALL_NOUN_TABLES.agc			        # pp. 313-331
$LEM_GEOMETRY.agc				        # pp. 332-337
$IMU_COMPENSATION_PACKAGE.agc			        # pp. 338-349
$R63.agc					        # pp. 350-353
$ATTITUDE_MANEUVER_ROUTINE.agc			        # pp. 354-375
$GIMBAL_LOCK_AVOIDANCE.agc			        # p.  376
$KALCMANU_STEERING.agc				        # pp. 377-381
$SYSTEM_TEST_STANDARD_LEAD_INS.agc		        # pp. 382-384
$IMU_PERFORMANCE_TESTS_2.agc			        # pp. 385-393
$IMU_PERFORMANCE_TESTS_4.agc			        # pp. 394-401
$PINBALL_GAME__BUTTONS_AND_LIGHTS.agc		        # pp. 402-486
$R60,R62.agc					        # pp. 487-500
$S-BAND_ANTENNA_FOR_LM.agc			        # pp. 501-504
$RADAR_LEADIN_ROUTINES.agc			        # pp. 505-506
$P20-P25.agc					        # pp. 507-619
$P30,P37.agc					        # pp. 620-623
$P32-P35,_P72-P75.agc				        # pp. 624-656
$GROUND_TRACKING_DETERMINATION_PROGRAM_-_P21.agc	# pp. 657-660
$P34-P35,_P74-P75.agc				        # pp. 661-705
$R31.agc					        # pp. 706-710
$P76.agc					        # pp. 711-714
$R30.agc					        # pp. 715-725
$BURN,_BABY,_BURN_--_MASTER_IGNITION_ROUTINE.agc        # pp. 726-746
$P40-P47.agc					        # pp. 747-780
$THE_LUNAR_LANDING.agc				        # pp. 781-788
$THROTTLE_CONTROL_ROUTINES.agc			        # pp. 789-793
$LUNAR_LANDING_GUIDANCE_EQUATIONS.agc		        # pp. 794-830
$P70-P71.agc					        # pp. 831-838
$P12.agc					        # pp. 839-843
$ASCENT_GUIDANCE.agc				        # pp. 844-859
$SERVICER.agc					        # pp. 860-894
$LANDING_ANALOG_DISPLAYS.agc			        # pp. 895-904
$FINDCDUW_-_GUIDAP_INTERFACE.agc			# pp. 905-922
$P51-P53.agc					        # pp. 923-981
$LUNAR_AND_SOLAR_EPHEMERIDES_SUBROUTINES.agc	        # pp. 982-985
$DOWN-TELEMETRY_PROGRAM.agc			        # pp. 986-995
$INTER-BANK_COMMUNICATION.agc			        # pp. 996-999
$INTERPRETER.agc				        # pp. 1000-1092
$FIXED-FIXED_CONSTANT_POOL.agc			        # pp. 1093-1097
$INTERPRETIVE_CONSTANTS.agc			        # pp. 1098-1099
$SINGLE_PRECISION_SUBROUTINES.agc		        # p.  1100
$EXECUTIVE.agc					        # pp. 1101-1114
$WAITLIST.agc					        # pp. 1115-1130
$LATITUDE_LONGITUDE_SUBROUTINES.agc		        # pp. 1131-1137
$PLANETARY_INERTIAL_ORIENTATION.agc		        # pp. 1138-1146
$MEASUREMENT_INCORPORATION.agc			        # pp. 1147-1156
$CONIC_SUBROUTINES.agc				        # pp. 1157-1201
$INTEGRATION_INITIALIZATION.agc			        # pp. 1202-1224
$ORBITAL_INTEGRATION.agc			        # pp. 1225-1245
$INFLIGHT_ALIGNMENT_ROUTINES.agc		        # pp. 1246-1255
$POWERED_FLIGHT_SUBROUTINES.agc			        # pp. 1256-1264
$TIME_OF_FREE_FALL.agc				        # pp. 1265-1280
$AGC_BLOCK_TWO_SELF-CHECK.agc			        # pp. 1281-1290
$PHASE_TABLE_MAINTENANCE.agc			        # pp. 1291-1299
$RESTARTS_ROUTINE.agc				        # pp. 1300-1305
$IMU_MODE_SWITCHING_ROUTINES.agc		        # pp. 1306-1334
$KEYRUPT,_UPRUPT.agc				        # pp. 1335-1337
$DISPLAY_INTERFACE_ROUTINES.agc			        # pp. 1338-1370
$SERVICE_ROUTINES.agc				        # pp. 1371-1377
$ALARM_AND_ABORT.agc				        # pp. 1378-1382
$UPDATE_PROGRAM.agc				        # pp. 1383-1393
$RTB_OP_CODES.agc				        # pp. 1394-1399
$T6-RUPT_PROGRAMS.agc				        # pp. 1400-1402
$DAP_INTERFACE_SUBROUTINES.agc			        # pp. 1403-1406
$DAPIDLER_PROGRAM.agc				        # pp. 1407-1418
$P-AXIS_RCS_AUTOPILOT.agc			        # pp. 1419-1439
$Q,R-AXES_RCS_AUTOPILOT.agc			        # pp. 1440-1457
$TJET_LAW.agc					        # pp. 1458-1467
$KALMAN_FILTER.agc				        # pp. 1468-1469
$TRIM_GIMBAL_CONTROL_SYSTEM.agc			        # pp. 1470-1482
$AOSTASK_AND_AOSJOB.agc				        # pp. 1483-1504
$SPS_BACK-UP_RCS_CONTROL.agc			        # pp. 1505-1508
						        # pp. 1509-1743: YUL-generated tables.

