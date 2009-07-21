# Copyright:	Public domain.
# Filename:	MAIN.agc
# Purpose:	Part of the source code for Artemis (i.e., Colossus 3),
#		build 072.  It is part of the source code for the
#		Command Module's (CM) Apollo Guidance Computer (AGC),
#		possibly for Apollo 15.
# Assembler:	yaYUL
# Contact:	Ron Burkey <info@sandroid.org>.
# Website:	www.ibiblio.org/apollo/index.html
# Mod history:	12/21/04 RSB.	Created.
#		05/14/05 RSB	Correctes website reference above.
#
# The contents of the "Artemis072" files, in general, are transcribed
# from scanned page images contributed by D. Thrust.  Notations on this
# document read, in part:
#
#	Assemble revision 249 of AGC program Colossus by NASA
#	2021111-041.  October 28, 1968.  
#
#	THIS AGC PROGRAM SHALL ALSO BE REFERRED TO AS
#				COLOSSUS 3
#	THIS PROGRAM IS INTENDED FOR USE IN THE CM AS SPECIFIED
#	IN REPORT R-577.  THIS PROGRAM WAS PREPARED UNDER OSR
#	PROJECT 55-23890, SPONSORED BY THE MANNED SPACECRAFT
#	CENTER OF THE NATIONAL AERONAUTICS AND SPACE
#	ADMINISTRATION THROUGH CONTRACT NAS 9-4065 WITH THE
#	CHARLES STARK DRAPER LABORATORY, MASSACHUSETTS INSTITUTE OF
#	TECHNOLOGY, CAMBRIDGE, MASS.
#
# Please report any errors to info@sandroid.org.
#
# In some cases, where the source code for Luminary 131 or for
# Colossus 249 overlaps that of Artemis 072, this code is instead copied
# from the corresponding Luminary 131 or Colossus 249
# source file, and then is proofed to incorporate any changes.

# This file is a little different from the other Artemis072 files I'm 
# providing, in that it doesn't represent anything that appears directly 
# in the original source.  What I (RSB) have done for organizational 
# purposes is to split the huge monolithic source code into smaller, 
# more manageable chunks--i.e., into individual source files.  Those 
# files are rejoined within this file as "includes".  It just makes
# it a little easier to work with.  The code chunks correspond to 
# natural divisions into sub-programs.  In fact, these divisions are 
# more-or-less specified by the source code itself.  Refer to the 
# "SUBROUTINE CALLS" at the very beginning of the file 
# ASSEMBLY_AND_OPERATION_INFORMATION.agc.

						# pp. ?-? contain no code/comments.
						
# ERASTOTL
$ASSEMBLY_AND_OPERATION_INFORMATION.agc		# pp. ?-??
#$CHECK_EQUALS_LIST.agc				# pp. ??-??

# DIOGENES
#$INTERRUPT_LEAD_INS.agc			# pp. ???-???
#$T4RUPT_PROGRAM.agc				# pp. ???-???
#$DOWNLINK_LISTS.agc				# pp. ???-???
#$FRESH_START_AND_RESTART.agc			# pp. ???-???
#$RESTART_TABLES.agc				# pp. ???-???
#$SXTMARK.agc 					# pp. ???-???
#$EXTENDED_VERBS.agc				# pp. ???-???
#$PINBALL_NOUN_TABLES.agc			# pp. ???-???
#$CSM_GEOMETRY.agc				# pp. ???-???
#$IMU_COMPENSATION_PACKAGE.agc			# pp. ???-???
#$PINBALL_GAME_BUTTONS_AND_LIGHTS.agc		# pp. ???-???
#$R60_62.agc					# pp. ???-???
#$ANGLFIND.agc					# pp. ???-???
#$GIMBAL_LOCK_AVOIDANCE.agc			# pp. ???-???
#$KALCMANU_STEERING.agc				# pp. ???-???
#$SYSTEM_TEST_STANDARD_LEAD_INS.agc		# pp. ???-???
#$IMU_CALIBRATION_AND_ALIGNMENT.agc		# pp. ???-???

# MEDUSA
#$GROUND_TRACKING_DETERMINATION_PROGRAM.agc	# pp. ???-???
#$P34-35_P74-75.agc				# pp. ???-???
#$R31.agc					# pp. ???-???
#$P76.agc					# pp. ???-???
#$R30.agc					# pp. ???-???

# MENELAUS
#$P15.agc
#$P11.agc					# pp. ???-???
#$P20-P25.agc					# pp. ???-???
#$P30-P31.agc					# pp. ???-???
#$P32-P33_P72-P73				# pp. ???-???
#$P40-P47.agc					# pp. ???-???
#$P51-P53.agc					# pp. ???-???
#$LUNAR_AND_SOLAR_EPHEMERIDES_SUBROUTINES.agc	# pp. ???-???
#$P61-P67.agc					# pp. ???-???
#$SERVICER207.agc				# pp. ???-???
#$ENTRY_LEXICON.agc				# pp. ???-???
#$REENTRY_CONTROL.agc				# pp. ???-???
#$CM_BODY_ATTITUDE.agc				# pp. ???-???
#$P37_P70.agc					# pp. ???-???
#$S-BAND_ANTENNA_FOR_CM.agc			# pp. ???-???

# ULYSSES
#$TVCINITIALIZE.agc				# pp. ???-???
#$TVCEXECUTIVE.agc				# pp. ???-???
#$TVCMASSPROP.agc				# pp. ???-???
#$TVCRESTARTS.agc				# pp. ???-???
#$TVCDAPS.agc					# pp. ???-???
#$TVCROLLDAP.agc				# pp. ???-???
#$MYSUBS.agc					# pp. ???-???
#$RCS-CSM_DAP_EXECUTIVE_PROGRAMS.agc		# pp. ????-????
#$JET_SELECTION_LOGIC.agc			# pp. ????-????
#$CM_ENTRY_DIGITAL_AUTOPILOT.agc		# pp. ????-????

# ZEUS
#$DOWN-TELEMETRY_PROGRAM.agc			# pp. ????-????
#$INTER-BANK_COMMUNICATION.agc			# pp. ????-????
#$INTERPRETER.agc				# pp. ????-????
#$FIXED_FIXED_CONSTANT_POOL.agc			# pp. ????-????
#$INTERPRETIVE_CONSTANTS.agc			# pp. ????-????
#$SINGLE_PRECISION_SUBROUTINES.agc		# p.  ????
#$EXECUTIVE.agc					# pp. ????-????
#$WAITLIST.agc					# pp. ????-????
#$LATITUDE_LONGITUDE_SUBROUTINES.agc		# pp. ????-????
#$PLANETARY_INERTIAL_ORIENTATION.agc		# pp. ????-????
#$MEASUREMENT_INCORPORATION.agc			# pp. ????-????
#$CONIC_SUBROUTINES.agc				# pp. ????-????
#$INTEGRATION_INITIALIZATION.agc		# pp. ????-????
#$ORBITAL_INTEGRATION.agc			# pp. ????-????
#$INFLIGHT_ALIGNMENT_ROUTINES.agc		# pp. ????-????
#$POWERED_FLIGHT_SUBROUTINES.agc		# pp. ????-????
#$TIME_OF_FREE_FALL.agc				# pp. ????-????
#$STAR_TABLES.agc				# pp. ????-????
#$AGC_BLOCK_TWO_SELF-CHECK.agc			# pp. ????-????
#$PHASE_TABLE_MAINTENANCE.agc			# pp. ????-????
#$RESTARTS_ROUTINE.agc				# pp. ????-????
#$IMU_MODE_SWITCHING_ROUTINES.agc		# pp. ????-????
#$KEYRUPT_UPRUPT.agc				# pp. ????-????
#$DISPLAY_INTERFACE_ROUTINES.agc		# pp. ????-????
#$SERVICE_ROUTINES.agc				# pp. ????-????
#$ALARM_AND_ABORT.agc				# pp. ????-????
#$UPDATE_PROGRAM.agc				# pp. ????-????
#$RT8_OP_CODES.agc				# pp. ????-????

						# pp. ????-????: YUL-generated tables.

