### FILE="Main.annotation"
# Copyright:    Public domain.
# Filename:     MAIN.agc
# Purpose:      The main source file for Luminary revision 178.
#               It is part of the reconstructed source code for the final
#               release of the flight software for the Lunar Module's
#               (LM) Apollo Guidance Computer (AGC) for Apollo 14. The
#               code has been recreated from copies of Zerlina 56, Luminary
#               210, and Luminary 131, as well as many Luminary memos.
#               It has been adapted such that the resulting bugger words
#               exactly match those specified for Luminary 178 in NASA
#               drawing 2021152N, which gives relatively high confidence
#               that the reconstruction is correct.
# Assembler:    yaYUL
# Contact:      Ron Burkey <info@sandroid.org>.
# Website:      www.ibiblio.org/apollo/index.html
# Mod history:  2019-08-14 MAS  Created from Zerlina 56.
#               2019-08-17 MAS  Removed CHECK EQUALS LIST, since it was
#                               not introduced until Luminary 182.

$ABSOLUTE_ADDRESSES_FOR_UPDATE_PROGRAM.agc              # p.  1
$ASSEMBLY_AND_OPERATION_INFORMATION.agc                 # pp. 2-27
$TAGS_FOR_RELATIVE_SETLOC_AND_BLANK_BANK_CARDS.agc      # pp. 28-37
$CONTROLLED_CONSTANTS.agc                               # pp. 38-54
$INPUT_OUTPUT_CHANNEL_BIT_DESCRIPTIONS.agc              # pp. 55-61
$FLAGWORD_ASSIGNMENTS.agc                               # pp. 62-89
$SUBROUTINE_CALLS.agc                                   # p.  90
$ERASABLE_ASSIGNMENTS.agc                               # pp. 91-156
$INTERRUPT_LEAD_INS.agc                                 # pp. 159-160
$T4RUPT_PROGRAM.agc                                     # pp. 161-195
$RCS_FAILURE_MONITOR.agc                                # pp. 196-198
$DOWNLINK_LISTS.agc                                     # pp. 199-212
$AGS_INITIALIZATION.agc                                 # pp. 213-217
$FRESH_START_AND_RESTART.agc                            # pp. 218-244
$RESTART_TABLES.agc                                     # pp. 245-250
$AOTMARK.agc                                            # pp. 251-267
$EXTENDED_VERBS.agc                                     # pp. 268-305
$PINBALL_NOUN_TABLES.agc                                # pp. 306-324
$LEM_GEOMETRY.agc                                       # pp. 325-330
$IMU_COMPENSATION_PACKAGE.agc                           # pp. 331-342
$R63.agc                                                # pp. 343-346
$ATTITUDE_MANEUVER_ROUTINE.agc                          # pp. 347-368
$GIMBAL_LOCK_AVOIDANCE.agc                              # p.  369
$KALCMANU_STEERING.agc                                  # pp. 370-374
$SYSTEM_TEST_STANDARD_LEAD_INS.agc                      # pp. 375-377
$IMU_PERFORMANCE_TESTS_2.agc                            # pp. 378-386
$IMU_PERFORMANCE_TESTS_4.agc                            # pp. 387-394
$PINBALL_GAME__BUTTONS_AND_LIGHTS.agc                   # pp. 395-479
$R60,R62.agc                                            # pp. 480-493
$S-BAND_ANTENNA_FOR_LM.agc                              # pp. 494-497
$RADAR_LEADIN_ROUTINES.agc                              # pp. 498-499
$P20-P25.agc                                            # pp. 500-611
$P30,P37.agc                                            # pp. 612-615
$P32-P35,_P72-P75.agc                                   # pp. 616-648
$GROUND_TRACKING_DETERMINATION_PROGRAM_-_P21.agc        # pp. 649-652
$P34-P35,_P74-P75.agc                                   # pp. 653-697
$R31.agc                                                # pp. 698-702
$P76.agc                                                # pp. 703-705
$R30.agc                                                # pp. 706-716
$BURN,_BABY,_BURN_--_MASTER_IGNITION_ROUTINE.agc        # pp. 717-737
$P40-P47.agc                                            # pp. 738-770
$THE_LUNAR_LANDING.agc                                  # pp. 771-778
$THROTTLE_CONTROL_ROUTINES.agc                          # pp. 779-783
$LUNAR_LANDING_GUIDANCE_EQUATIONS.agc                   # pp. 784-821
$P70-P71.agc                                            # pp. 822-828
$P12.agc                                                # pp. 829-833
$ASCENT_GUIDANCE.agc                                    # pp. 834-849
$SERVICER.agc                                           # pp. 850-889
$LANDING_ANALOG_DISPLAYS.agc                            # pp. 890-898
$FINDCDUW_-_GUIDAP_INTERFACE.agc                        # pp. 899-917
$P51-P53.agc                                            # pp. 918-974
$LUNAR_AND_SOLAR_EPHEMERIDES_SUBROUTINES.agc            # pp. 975-978
$DOWN-TELEMETRY_PROGRAM.agc                             # pp. 979-988
$INTER-BANK_COMMUNICATION.agc                           # pp. 989-992
$INTERPRETER.agc                                        # pp. 993-1085
$FIXED-FIXED_CONSTANT_POOL.agc                          # pp. 1086-1090
$INTERPRETIVE_CONSTANTS.agc                             # pp. 1091-1092
$SINGLE_PRECISION_SUBROUTINES.agc                       # p.  1093
$EXECUTIVE.agc                                          # pp. 1094-1107
$WAITLIST.agc                                           # pp. 1108-1123
$LATITUDE_LONGITUDE_SUBROUTINES.agc                     # pp. 1124-1130
$PLANETARY_INERTIAL_ORIENTATION.agc                     # pp. 1131-1139
$MEASUREMENT_INCORPORATION.agc                          # pp. 1140-1149
$CONIC_SUBROUTINES.agc                                  # pp. 1150-1194
$INTEGRATION_INITIALIZATION.agc                         # pp. 1195-1216
$ORBITAL_INTEGRATION.agc                                # pp. 1217-1237
$INFLIGHT_ALIGNMENT_ROUTINES.agc                        # pp. 1238-1247
$POWERED_FLIGHT_SUBROUTINES.agc                         # pp. 1248-1256
$TIME_OF_FREE_FALL.agc                                  # pp. 1257-1272
$AGC_BLOCK_TWO_SELF-CHECK.agc                           # pp. 1273-1282
$PHASE_TABLE_MAINTENANCE.agc                            # pp. 1283-1291
$RESTARTS_ROUTINE.agc                                   # pp. 1292-1297
$IMU_MODE_SWITCHING_ROUTINES.agc                        # pp. 1298-1326
$KEYRUPT,_UPRUPT.agc                                    # pp. 1327-1329
$DISPLAY_INTERFACE_ROUTINES.agc                         # pp. 1330-1361
$SERVICE_ROUTINES.agc                                   # pp. 1362-1368
$ALARM_AND_ABORT.agc                                    # pp. 1369-1373
$UPDATE_PROGRAM.agc                                     # pp. 1374-1384
$RTB_OP_CODES.agc                                       # pp. 1385-1390
$T6-RUPT_PROGRAMS.agc                                   # pp. 1391-1393
$DAP_INTERFACE_SUBROUTINES.agc                          # pp. 1394-1397
$DAPIDLER_PROGRAM.agc                                   # pp. 1398-1408
$P-AXIS_RCS_AUTOPILOT.agc                               # pp. 1409-1429
$Q,R-AXES_RCS_AUTOPILOT.agc                             # pp. 1430-1447
$TJET_LAW.agc                                           # pp. 1448-1457
$KALMAN_FILTER.agc                                      # pp. 1458-1459
$TRIM_GIMBAL_CONTROL_SYSTEM.agc                         # pp. 1460-1472
$AOSTASK_AND_AOSJOB.agc                                 # pp. 1473-1494
$SPS_BACK-UP_RCS_CONTROL.agc                            # pp. 1495-1498
                                                        # pp. 1449-1734: GAP-generated tables.

