### FILE="Main.annotation"
# Copyright:   Public domain.
# Filename:    MAIN.agc
# Purpose:     The main source file for Luminary revision 116.
#              It is part of the source code for the Lunar Module's (LM)
#              Apollo Guidance Computer (AGC) for Apollo 12.
# Assembler:   yaYUL
# Contact:     Ron Burkey <info@sandroid.org>.
# Website:     www.ibiblio.org/apollo/index.html
# Mod history: 2017-01-22 MAS  Created.

$ASSEMBLY_AND_OPERATION_INFORMATION.agc                 # pp. 1-27
$TAGS_FOR_RELATIVE_SETLOC_AND_BLANK_BANK_CARDS.agc      # pp. 28-37
$CONTROLLED_CONSTANTS.agc                               # pp. 38-53
$INPUT_OUTPUT_CHANNEL_BIT_DESCRIPTIONS.agc              # pp. 54-60
$FLAGWORD_ASSIGNMENTS.agc                               # pp. 61-88
$SUBROUTINE_CALLS.agc                                   # p.  89
$ERASABLE_ASSIGNMENTS.agc                               # pp. 90-153
$INTERRUPT_LEAD_INS.agc                                 # pp. 154-155
$T4RUPT_PROGRAM.agc                                     # pp. 156-190
$RCS_FAILURE_MONITOR.agc                                # pp. 191-193
$DOWNLINK_LISTS.agc                                     # pp. 194-206
$AGS_INITIALIZATION.agc                                 # pp. 207-211
$FRESH_START_AND_RESTART.agc                            # pp. 212-237
$RESTART_TABLES.agc                                     # pp. 238-243
$AOTMARK.agc                                            # pp. 244-261
$EXTENDED_VERBS.agc                                     # pp. 262-301
$PINBALL_NOUN_TABLES.agc                                # pp. 302-320
$LEM_GEOMETRY.agc                                       # pp. 321-326
$IMU_COMPENSATION_PACKAGE.agc                           # pp. 327-338
$R63.agc                                                # pp. 339-342
$ATTITUDE_MANEUVER_ROUTINE.agc                          # pp. 343-364
$GIMBAL_LOCK_AVOIDANCE.agc                              # p.  365
$KALCMANU_STEERING.agc                                  # pp. 366-370
$SYSTEM_TEST_STANDARD_LEAD_INS.agc                      # pp. 371-373
$IMU_PERFORMANCE_TESTS_2.agc                            # pp. 374-382
$IMU_PERFORMANCE_TESTS_4.agc                            # pp. 383-390
$PINBALL_GAME__BUTTONS_AND_LIGHTS.agc                   # pp. 391-473
$R60,R62.agc                                            # pp. 474-487
$S-BAND_ANTENNA_FOR_LM.agc                              # pp. 488-491
$RADAR_LEADIN_ROUTINES.agc                              # pp. 492-493
$P20-P25.agc                                            # pp. 494-616
$P30,P37.agc                                            # pp. 617-620
$P32-P35,_P72-P75.agc                                   # pp. 621-653
$GROUND_TRACKING_DETERMINATION_PROGRAM_-_P21.agc        # pp. 654-657
$P34-P35,_P74-P75.agc                                   # pp. 658-702
$R31.agc                                                # pp. 703-708
$P76.agc                                                # pp. 709-711
$R30.agc                                                # pp. 712-722
$BURN,_BABY,_BURN_--_MASTER_IGNITION_ROUTINE.agc        # pp. 723-744
$P40-P47.agc                                            # pp. 745-777
$THE_LUNAR_LANDING.agc                                  # pp. 778-785
$THROTTLE_CONTROL_ROUTINES.agc                          # pp. 786-790
$LUNAR_LANDING_GUIDANCE_EQUATIONS.agc                   # pp. 791-822
$P70-P71.agc                                            # pp. 823-830
$P12.agc                                                # pp. 831-835
$ASCENT_GUIDANCE.agc                                    # pp. 836-851
$SERVICER.agc                                           # pp. 852-890
$LANDING_ANALOG_DISPLAYS.agc                            # pp. 891-900
$FINDCDUW_-_GUIDAP_INTERFACE.agc                        # pp. 901-918
$P51-P53.agc                                            # pp. 919-975
$LUNAR_AND_SOLAR_EPHEMERIDES_SUBROUTINES.agc            # pp. 976-979
$DOWN-TELEMETRY_PROGRAM.agc                             # pp. 980-989
$INTER-BANK_COMMUNICATION.agc                           # pp. 990-993
$INTERPRETER.agc                                        # pp. 994-1086
$FIXED-FIXED_CONSTANT_POOL.agc                          # pp. 1087-1091
$INTERPRETIVE_CONSTANTS.agc                             # pp. 1092-1093
$SINGLE_PRECISION_SUBROUTINES.agc                       # p.  1094
$EXECUTIVE.agc                                          # pp. 1095-1108
$WAITLIST.agc                                           # pp. 1109-1124
$LATITUDE_LONGITUDE_SUBROUTINES.agc                     # pp. 1125-1131
$PLANETARY_INERTIAL_ORIENTATION.agc                     # pp. 1132-1140
$MEASUREMENT_INCORPORATION.agc                          # pp. 1141-1150
$CONIC_SUBROUTINES.agc                                  # pp. 1151-1195
$INTEGRATION_INITIALIZATION.agc                         # pp. 1196-1217
$ORBITAL_INTEGRATION.agc                                # pp. 1218-1238
$INFLIGHT_ALIGNMENT_ROUTINES.agc                        # pp. 1239-1248
$POWERED_FLIGHT_SUBROUTINES.agc                         # pp. 1249-1257
$TIME_OF_FREE_FALL.agc                                  # pp. 1258-1273
$AGC_BLOCK_TWO_SELF-CHECK.agc                           # pp. 1274-1283
$PHASE_TABLE_MAINTENANCE.agc                            # pp. 1284-1292
$RESTARTS_ROUTINE.agc                                   # pp. 1293-1298
$IMU_MODE_SWITCHING_ROUTINES.agc                        # pp. 1299-1327
$KEYRUPT,_UPRUPT.agc                                    # pp. 1328-1330
$DISPLAY_INTERFACE_ROUTINES.agc                         # pp. 1331-1363
$SERVICE_ROUTINES.agc                                   # pp. 1364-1370
$ALARM_AND_ABORT.agc                                    # pp. 1371-1375
$UPDATE_PROGRAM.agc                                     # pp. 1376-1386
$RTB_OP_CODES.agc                                       # pp. 1387-1392
$T6-RUPT_PROGRAMS.agc                                   # pp. 1393-1395
$DAP_INTERFACE_SUBROUTINES.agc                          # pp. 1396-1399
$DAPIDLER_PROGRAM.agc                                   # pp. 1400-1410
$P-AXIS_RCS_AUTOPILOT.agc                               # pp. 1411-1431
$Q,R-AXES_RCS_AUTOPILOT.agc                             # pp. 1432-1449
$TJET_LAW.agc                                           # pp. 1450-1459
$KALMAN_FILTER.agc                                      # pp. 1460-1461
$TRIM_GIMBAL_CONTROL_SYSTEM.agc                         # pp. 1462-1474
$AOSTASK_AND_AOSJOB.agc                                 # pp. 1475-1496
$SPS_BACK-UP_RCS_CONTROL.agc                            # pp. 1497-1500
                                                        # pp. 1501-1734: GAP-generated tables.
