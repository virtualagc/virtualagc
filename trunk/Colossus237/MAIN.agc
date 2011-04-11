### FILE="Main.annotation"
# Copyright:	Public domain.
# Filename:	MAIN.agc
# Purpose:	Part of the source code for Colossus, build 237.
#		This is for the Command Module's (CM) 
#		Apollo Guidance Computer (AGC), we believe for 
#		Apollo 8.
# Assembler:	yaYUL
# Contact:	Jim Lawton <jim.lawton@gmail.com>.
# Website:	www.ibiblio.org/apollo/index.html
# Page scans:	www.ibiblio.org/apollo/ScansForConversion/Artemis072/
# Mod history:	2009-08-12 JL	Created.
#		2011-01-17 JL	Fixed module name, indentation.
#		2011-01-23 JL	Fixed module name. 
#		2011-01-27 JL	Fixed module name.
#		2011-02-05 JL	Fixed module name.
#		2011-03-05 JL	Fixed module name.
#		2011-04-11 JL	Fixed module name.

# MAIN.agc is a little different from the other files  
# provided, in that it doesn't represent anything that appears 
# directly in the original source.  What I (RSB) have done for 
# organizational purposes is to split the huge monolithic source 
# code into smaller, more manageable chunks--i.e., into individual
# source files.  Those files are rejoined within this file as 
# "includes".  It just makes it a little easier to work with.  The
# code chunks correspond to natural divisions into sub-programs.  
# The divisions are by the assembly listing itself.

# Source-file Name			    	  Starting Page
# ----------------				  -------------

$ASSEMBLY_AND_OPERATION_INFORMATION.agc			# 1
$TAGS_FOR_RELATIVE_SETLOC_AND_BLANK_BANK_CARDS.agc	# 25

# KILERASE.078
$ERASABLE_ASSIGNMENTS.agc				# 34

# KOOLADE.064
$INTERRUPT_LEAD_INS.agc					# 126
$T4RUPT_PROGRAM.agc					# 128
$DOWNLINK_LISTS.agc					# 165
$FRESH_START_AND_RESTART.agc				# 176
$RESTART_TABLES.agc					# 204
$SXTMARK.agc 						# 215
$EXTENDED_VERBS.agc					# 229
$PINBALL_NOUN_TABLES.agc				# 261
$CSM_GEOMETRY.agc					# 278
$IMU_COMPENSATION_PACKAGE.agc				# 290
$PINBALL_GAME__BUTTONS_AND_LIGHTS.agc			# 300
$R60,R62.agc						# 381
$ANGLFIND.agc						# 390
$GIMBAL_LOCK_AVOIDANCE.agc				# 403
$KALCMANU_STEERING.agc					# 405
$SYSTEM_TEST_STANDARD_LEAD_INS.agc			# 411
$IMU_CALIBRATION_AND_ALIGNMENT.agc			# 414

# SMOOCH.005
$GROUND_TRACKING_DETERMINATION_PROGRAM_-_P21.agc	# 447
$P34-P35,_P74-P75.agc					# 450
$R31.agc						# 494
$P76.agc						# 500
$R30.agc						# 503
$STABLE_ORBIT_-_P38-P39.agc				# 514

# PANDORA.072
$P11.agc						# 522
$TPI_SEARCH.agc						# 539
$P20-P25.agc						# 550
$P30,P37.agc						# 624
$P40-P47.agc						# 637
$P51-P53.agc						# 690
$LUNAR_AND_SOLAR_EPHEMERIDES_SUBROUTINES.agc		# 736
$P61-P67.agc						# 740
$SERVICER207.agc					# 770
$ENTRY_LEXICON.agc					# 788
$REENTRY_CONTROL.agc					# 795
$CM_BODY_ATTITUDE.agc					# 833
$P37,P70.agc						# 840
$S-BAND_ANTENNA_FOR_CM.agc				# 884
$LUNAR_LANDMARK_SELECTION_FOR_CM.agc			# 886

# DAPCSM.186
$TVCINITIALIZE.agc					# 896
$TVCEXECUTIVE.agc					# 900
$TVCMASSPROP.agc					# 908
$TVCRESTARTS.agc					# 913
$TVCDAPS.agc						# 918
$TVCSTROKETEST.agc					# 940
$TVCROLLDAP.agc						# 945
$TVCGEN3FILTERS.agc					# 958
$MYSUBS.agc						# 967
$RCS-CSM_DIGITAL_AUTOPILOT.agc				# 970
$AUTOMATIC_MANEUVERS.agc				# 993
$RCS-CSM_DAP_EXECUTIVE_PROGRAMS.agc			# 1005
$JET_SELECTION_LOGIC.agc				# 1007
$CM_ENTRY_DIGITAL_AUTOPILOT.agc				# 1031

# SATRAP.004
$DOWN-TELEMETRY_PROGRAM.agc				# 1060
$INTER-BANK_COMMUNICATION.agc				# 1070
$INTERPRETER.agc					# 1074
$FIXED-FIXED_CONSTANT_POOL.agc				# 1167
$INTERPRETIVE_CONSTANTS.agc				# 1172
$SINGLE_PRECISION_SUBROUTINES.agc			# 1174
$EXECUTIVE.agc						# 1175
$WAITLIST.agc						# 1188
$LATITUDE_LONGITUDE_SUBROUTINES.agc			# 1203
$PLANETARY_INERTIAL_ORIENTATION.agc			# 1210
$MEASUREMENT_INCORPORATION.agc				# 1219
$CONIC_SUBROUTINES.agc					# 1228
$INTEGRATION_INITIALIZATION.agc				# 1275
$ORBITAL_INTEGRATION.agc				# 1298
$INFLIGHT_ALIGNMENT_ROUTINES.agc			# 1319
$POWERED_FLIGHT_SUBROUTINES.agc				# 1329
$TIME_OF_FREE_FALL.agc					# 1337
$STAR_TABLES.agc					# 1353
$AGC_BLOCK_TWO_SELF-CHECK.agc				# 1358
$PHASE_TABLE_MAINTENANCE.agc				# 1368
$RESTARTS_ROUTINE.agc					# 1378
$IMU_MODE_SWITCHING_ROUTINES.agc			# 1384
$KEYRUPT_UPRUPT.agc					# 1413
$DISPLAY_INTERFACE_ROUTINES.agc				# 1416
$SERVICE_ROUTINES.agc					# 1449
$ALARM_AND_ABORT.agc					# 1457
$UPDATE_PROGRAM.agc					# 1461
$RTB_OP_CODES.agc					# 1472

#SYMBOL_TABLE_LISTING					# 1480
