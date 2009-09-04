### FILE="Main.annotation"
# Copyright:	Public domain.
# Filename:	MAIN.agc
# Purpose:	Part of the source code for Artemis (i.e., Colossus 3),
#		build 072.  This is for the Command Module's (CM) 
#		Apollo Guidance Computer (AGC), we believe for 
#		Apollo 15-17.
# Assembler:	yaYUL
# Contact:	Ron Burkey <info@sandroid.org>.
# Website:	www.ibiblio.org/apollo/index.html
# Page scans:	www.ibiblio.org/apollo/ScansForConversion/Artemis072/
# Mod history:	2004-12-21 RSB	Created.
#		2005-05-14 RSB	Corrects website reference above.
#		2009-07-25 RSB	Fixups for this header so that it can
#				be used for code conversions.
#		2009-08-12 JL	Fix typo.
#		2009-08-18 JL	Change some filenames to match log section names.
#		2009-09-03 JL	Comment out some modules that are not available yet, to start checking build.
#		2009-09-04 JL	Uncomment modules that are now available.
#		
# MAIN.agc is a little different from the other Artemis072 files  
# provided, in that it doesn't represent anything that appears 
# directly in the original source.  What I (RSB) have done for 
# organizational purposes is to split the huge monolithic source 
# code into smaller, more manageable chunks--i.e., into individual
# source files.  Those files are rejoined within this file as 
#"includes".  It just makes it a little easier to work with.  The
# code chunks correspond to natural divisions into sub-programs.  
# The divisions are by the assembly listing itself.

# Source-file Name			    	  Starting Page
# ----------------				  -------------

$ASSEMBLY_AND_OPERATION_INFORMATION.agc		# 1
$TAGS_FOR_RELATIVE_SETLOC.agc			# 27
$ABSOLUTE_LOCATIONS_FOR_UPDATES.agc		# 36
$SUBROUTINE_CALLS.agc				# 37
#$ERASABLE_ASSIGNMENTS.agc			# 38

# ERASTOTL
$CHECK_EQUALS_LIST.agc				# 135

# DIOGENES
$INTERRUPT_LEAD_INS.agc				# 139
$T4RUPT_PROGRAM.agc				# 141
$DOWNLINK_LISTS.agc				# 179
$FRESH_START_AND_RESTART.agc			# 192
$RESTART_TABLES.agc				# 229
$SXTMARK.agc 					# 239
$EXTENDED_VERBS.agc				# 249
$PINBALL_NOUN_TABLES.agc			# 280
$CSM_GEOMETRY.agc				# 297
$IMU_COMPENSATION_PACKAGE.agc			# 308
$PINBALL_GAME_BUTTONS_AND_LIGHTS.agc		# 318
$R60_R62.agc					# 394
$ANGLFIND.agc					# 403
$GIMBAL_LOCK_AVOIDANCE.agc			# 416
$KALCMANU_STEERING.agc				# 418
$SYSTEM_TEST_STANDARD_LEAD_INS.agc		# 424
$IMU_CALIBRATION_AND_ALIGNMENT.agc		# 427

# MEDUSA
$GROUND_TRACKING_DETERMINATION_PROGRAM-P21.agc	# 455
$P34-P35_P74-P75.agc				# 463
#$R31.agc					# 507
#$P76.agc					# 513
#$R30.agc					# 516

# MENELAUS
#$P15.agc					# 527
#$P11.agc					# 534
#$P20-P25.agc					# 552
$P30-P31.agc					# 643
$P32-P33_P72-P73.agc				# 658
$P40-P47.agc					# 691
$P51-P53.agc					# 742
$LUNAR_AND_SOLAR_EPHEMERIDES_SUBROUTINES.agc	# 789
$P61-P67.agc					# 792
$SERVICER207.agc				# 823
$ENTRY_LEXICON.agc				# 842
$REENTRY_CONTROL.agc				# 852
#$CM_BODY_ATTITUDE.agc				# 890
$P37_P70.agc					# 897
$S-BAND_ANTENNA_FOR_CM.agc			# 940

# ULYSSES
#$TVCINITIALIZE.agc				# 943
#$TVCEXECUTIVE.agc				# 950
#$TVCMASSPROP.agc				# 954
#$TVCRESTARTS.agc				# 959
#$TVCDAPS.agc					# 964
#$TVCROLLDAP.agc				# 982
$MYSUBS.agc					# 997
$RCS-CSM_DIGITAL_AUTOPILOT.agc			# 1000
$AUTOMATIC_MANEUVERS.agc			# 1024
$RCS-CSM_DAP_EXECUTIVE_PROGRAMS.agc		# 1036
$JET_SELECTION_LOGIC.agc			# 1038
$CM_ENTRY_DIGITAL_AUTOPILOT.agc			# 1063

# ZEUS
$DOWN-TELEMETRY_PROGRAM.agc			# 1093
$INTER-BANK_COMMUNICATION.agc			# 1104
$INTERPRETER.agc				# 1108
$FIXED_FIXED_CONSTANT_POOL.agc			# 1200
$INTERPRETIVE_CONSTANTS.agc			# 1205
$SINGLE_PRECISION_SUBROUTINES.agc		# 1207
$EXECUTIVE.agc					# 1208
$WAITLIST.agc					# 1221
$LATITUDE_LONGITUDE_SUBROUTINES.agc		# 1236
$PLANETARY_INERTIAL_ORIENTATION.agc		# 1243
$MEASUREMENT_INCORPORATION.agc			# 1252
$CONIC_SUBROUTINES.agc				# 1262
$INTEGRATION_INITIALIZATION.agc			# 1309
$ORBITAL_INTEGRATION.agc			# 1333
$INFLIGHT_ALIGNMENT_ROUTINES.agc		# 1354
$POWERED_FLIGHT_SUBROUTINES.agc			# 1364
$TIME_OF_FREE_FALL.agc				# 1371
$STAR_TABLES.agc				# 1387
$AGC_BLOCK_TWO_SELF-CHECK.agc			# 1392
$PHASE_TABLE_MAINTENANCE.agc			# 1402
$RESTARTS_ROUTINE.agc				# 1411
$IMU_MODE_SWITCHING_ROUTINES.agc		# 1417
$KEYRUPT_UPRUPT.agc				# 1445
$DISPLAY_INTERFACE_ROUTINES.agc			# 1448
$SERVICE_ROUTINES.agc				# 1478
$ALARM_AND_ABORT.agc				# 1486
$UPDATE_PROGRAM.agc				# 1490
$RTB_OP_CODES.agc				# 1501

#Assembly-tables				# 1507

