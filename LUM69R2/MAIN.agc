### FILE="Main.annotation"
# Copyright:    Public domain.
# Filename:     MAIN.agc
# Purpose:      The main source file for LUM69 revision 2. 
#               It is part of the reconstructed source code for the flown
#               version of the flight software for the Lunar Module's (LM)
#               Apollo Guidance Computer (AGC) for Apollo 10. The code has
#               been recreated from a copy of Luminary revsion 069, using
#               changes present in Luminary 099 which were described in
#               Luminary memos 75 and 78. The code has been adapted such
#               that the resulting bugger words exactly match those specified
#               for LUM69 revision 2 in NASA drawing 2021152B, which gives
#               relatively high confidence that the reconstruction is correct.
# Assembler:    yaYUL
# Contact:      Ron Burkey <info@sandroid.org>.
# Website:      www.ibiblio.org/apollo/index.html
# Mod history:  2019-07-27 MAS  Created.

$ASSEMBLY_AND_OPERATION_INFORMATION.agc                 # pp. 1-26
$TAGS_FOR_RELATIVE_SETLOC_AND_BLANK_BANK_CARDS.agc      # pp. 27-36
$PADLOADS.agc                                           # pp. 37-52
$CONTROLLED_CONSTANTS.agc                               # pp. 53-69
$INPUT_OUTPUT_CHANNEL_BIT_DESCRIPTIONS.agc              # pp. 70-76
$FLAGWORD_ASSIGNMENTS.agc                               # pp. 77-104
$SUBROUTINE_CALLS.agc                                   # p.  105
$ERASABLE_ASSIGNMENTS.agc                               # pp. 106-167
$INTERRUPT_LEAD_INS.agc                                 # pp. 168-169
$T4RUPT_PROGRAM.agc                                     # pp. 170-204
$RCS_FAILURE_MONITOR.agc                                # pp. 205-207
$DOWNLINK_LISTS.agc                                     # pp. 208-220
$AGS_INITIALIZATION.agc                                 # pp. 221-225
$FRESH_START_AND_RESTART.agc                            # pp. 226-252
$RESTART_TABLES.agc                                     # pp. 253-258
$AOTMARK.agc                                            # pp. 259-276
$EXTENDED_VERBS.agc                                     # pp. 277-315
$PINBALL_NOUN_TABLES.agc                                # pp. 316-333
$LEM_GEOMETRY.agc                                       # pp. 334-338
$IMU_COMPENSATION_PACKAGE.agc                           # pp. 339-350
$R63.agc                                                # pp. 351-354
$ATTITUDE_MANEUVER_ROUTINE.agc                          # pp. 355-376
$GIMBAL_LOCK_AVOIDANCE.agc                              # p.  377
$KALCMANU_STEERING.agc                                  # pp. 378-382
$SYSTEM_TEST_STANDARD_LEAD_INS.agc                      # pp. 383-385
$IMU_PERFORMANCE_TESTS_2.agc                            # pp. 386-394
$IMU_PERFORMANCE_TESTS_4.agc                            # pp. 395-402
$PINBALL_GAME__BUTTONS_AND_LIGHTS.agc                   # pp. 403-484
$R60,R62.agc                                            # pp. 485-497
$S-BAND_ANTENNA_FOR_LM.agc                              # pp. 498-501
$RADAR_LEADIN_ROUTINES.agc                              # pp. 502-503
$P20-P25.agc                                            # pp. 504-623
$P30,P37.agc                                            # pp. 624-627
$P32-P35,_P72-P75.agc                                   # pp. 628-660
$GENERAL_LAMBERT_AIMPOINT_GUIDANCE.agc                  # pp. 661-663
$GROUND_TRACKING_DETERMINATION_PROGRAM_-_P21.agc        # pp. 664-666
$P34-P35,_P74-P75.agc                                   # pp. 667-711
$R31.agc                                                # pp. 712-716
$P76.agc                                                # pp. 717-719
$R30.agc                                                # pp. 720-730
$STABLE_ORBIT_-_P38-P39.agc                             # pp. 731-738
$BURN,_BABY,_BURN_--_MASTER_IGNITION_ROUTINE.agc        # pp. 739-758
$P40-P47.agc                                            # pp. 759-788
$THE_LUNAR_LANDING.agc                                  # pp. 789-796
$THROTTLE_CONTROL_ROUTINES.agc                          # pp. 797-801
$LUNAR_LANDING_GUIDANCE_EQUATIONS.agc                   # pp. 802-828
$P70-P71.agc                                            # pp. 829-838
$P12.agc                                                # pp. 839-843
$ASCENT_GUIDANCE.agc                                    # pp. 844-857
$SERVICER.agc                                           # pp. 858-896
$LANDING_ANALOG_DISPLAYS.agc                            # pp. 897-906
$FINDCDUW_-_GUIDAP_INTERFACE.agc                        # pp. 907-924
$P51-P53.agc                                            # pp. 925-978
$LUNAR_AND_SOLAR_EPHEMERIDES_SUBROUTINES.agc            # pp. 979-982
$DOWN-TELEMETRY_PROGRAM.agc                             # pp. 983-992
$INTER-BANK_COMMUNICATION.agc                           # pp. 993-996
$INTERPRETER.agc                                        # pp. 997-1089
$FIXED-FIXED_CONSTANT_POOL.agc                          # pp. 1090-1094
$INTERPRETIVE_CONSTANTS.agc                             # pp. 1095-1096
$SINGLE_PRECISION_SUBROUTINES.agc                       # p.  1097
$EXECUTIVE.agc                                          # pp. 1098-1111
$WAITLIST.agc                                           # pp. 1112-1127
$LATITUDE_LONGITUDE_SUBROUTINES.agc                     # pp. 1128-1134
$PLANETARY_INERTIAL_ORIENTATION.agc                     # pp. 1135-1143
$MEASUREMENT_INCORPORATION.agc                          # pp. 1144-1153
$CONIC_SUBROUTINES.agc                                  # pp. 1154-1199
$INTEGRATION_INITIALIZATION.agc                         # pp. 1200-1222
$ORBITAL_INTEGRATION.agc                                # pp. 1223-1243
$INFLIGHT_ALIGNMENT_ROUTINES.agc                        # pp. 1244-1253
$POWERED_FLIGHT_SUBROUTINES.agc                         # pp. 1254-1261
$TIME_OF_FREE_FALL.agc                                  # pp. 1262-1277
$AGC_BLOCK_TWO_SELF-CHECK.agc                           # pp. 1278-1287
$PHASE_TABLE_MAINTENANCE.agc                            # pp. 1288-1296
$RESTARTS_ROUTINE.agc                                   # pp. 1297-1302
$IMU_MODE_SWITCHING_ROUTINES.agc                        # pp. 1303-1331
$KEYRUPT,_UPRUPT.agc                                    # pp. 1332-1334
$DISPLAY_INTERFACE_ROUTINES.agc                         # pp. 1335-1367
$SERVICE_ROUTINES.agc                                   # pp. 1368-1374
$ALARM_AND_ABORT.agc                                    # pp. 1375-1378
$UPDATE_PROGRAM.agc                                     # pp. 1379-1389
$RTB_OP_CODES.agc                                       # pp. 1390-1397
$T6-RUPT_PROGRAMS.agc                                   # pp. 1398-1400
$DAP_INTERFACE_SUBROUTINES.agc                          # pp. 1401-1404
$DAPIDLER_PROGRAM.agc                                   # pp. 1405-1415
$P-AXIS_RCS_AUTOPILOT.agc                               # pp. 1416-1435
$Q,R-AXES_RCS_AUTOPILOT.agc                             # pp. 1436-1453
$TJET_LAW.agc                                           # pp. 1454-1464
$KALMAN_FILTER.agc                                      # pp. 1465-1466
$TRIM_GIMBAL_CONTROL_SYSTEM.agc                         # pp. 1467-1478
$AOSTASK_AND_AOSJOB.agc                                 # pp. 1479-1499
$SPS_BACK-UP_RCS_CONTROL.agc                            # pp. 1500-1502
                                                        # pp. 1503-1735: GAP-generated tables.
