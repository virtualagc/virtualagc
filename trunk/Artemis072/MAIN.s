# Copyright:	Public domain.
# Filename:	MAIN.s
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
# ASSEMBLY_AND_OPERATION_INFORMATION.s.

						# pp. ?-? contain no code/comments.
						
# ERASTOTL
$ASSEMBLY_AND_OPERATION_INFORMATION.s		# pp. ?-??
#$CHECK_EQUALS_LIST.s				# pp. ??-??

# DIOGENES
#$INTERRUPT_LEAD_INS.s				# pp. ???-???
#$T4RUPT_PROGRAM.s				# pp. ???-???
#$DOWNLINK_LISTS.s				# pp. ???-???
#$FRESH_START_AND_RESTART.s			# pp. ???-???
#$RESTART_TABLES.s				# pp. ???-???
#$SXTMARK.s 					# pp. ???-???
#$EXTENDED_VERBS.s				# pp. ???-???
#$PINBALL_NOUN_TABLES.s				# pp. ???-???
#$CSM_GEOMETRY.s				# pp. ???-???
#$IMU_COMPENSATION_PACKAGE.s			# pp. ???-???
#$PINBALL_GAME_BUTTONS_AND_LIGHTS.s		# pp. ???-???
#$R60_62.s					# pp. ???-???
#$ANGLFIND.s					# pp. ???-???
#$GIMBAL_LOCK_AVOIDANCE.s			# pp. ???-???
#$KALCMANU_STEERING.s				# pp. ???-???
#$SYSTEM_TEST_STANDARD_LEAD_INS.s		# pp. ???-???
#$IMU_CALIBRATION_AND_ALIGNMENT.s		# pp. ???-???

# MEDUSA
#$GROUND_TRACKING_DETERMINATION_PROGRAM.s	# pp. ???-???
#$P34-35_P74-75.s				# pp. ???-???
#$R31.s						# pp. ???-???
#$P76.s						# pp. ???-???
#$R30.s						# pp. ???-???

# MENELAUS
#$P15.s
#$P11.s						# pp. ???-???
#$P20-P25.s					# pp. ???-???
#$P30-P31.s					# pp. ???-???
#$P32-P33_P72-P73				# pp. ???-???
#$P40-P47.s					# pp. ???-???
#$P51-P53.s					# pp. ???-???
#$LUNAR_AND_SOLAR_EPHEMERIDES_SUBROUTINES.s	# pp. ???-???
#$P61-P67.s					# pp. ???-???
#$SERVICER207.s					# pp. ???-???
#$ENTRY_LEXICON.s				# pp. ???-???
#$REENTRY_CONTROL.s				# pp. ???-???
#$CM_BODY_ATTITUDE.s				# pp. ???-???
#$P37_P70.s					# pp. ???-???
#$S-BAND_ANTENNA_FOR_CM.s			# pp. ???-???

# ULYSSES
#$TVCINITIALIZE.s				# pp. ???-???
#$TVCEXECUTIVE.s				# pp. ???-???
#$TVCMASSPROP.s					# pp. ???-???
#$TVCRESTARTS.s					# pp. ???-???
#$TVCDAPS.s					# pp. ???-???
#$TVCROLLDAP.s					# pp. ???-???
#$MYSUBS.s					# pp. ???-???
#$RCS-CSM_DAP_EXECUTIVE_PROGRAMS.s		# pp. ????-????
#$JET_SELECTION_LOGIC.s				# pp. ????-????
#$CM_ENTRY_DIGITAL_AUTOPILOT.s			# pp. ????-????

# ZEUS
#$DOWN-TELEMETRY_PROGRAM.s			# pp. ????-????
#$INTER-BANK_COMMUNICATION.s			# pp. ????-????
#$INTERPRETER.s					# pp. ????-????
#$FIXED_FIXED_CONSTANT_POOL.s			# pp. ????-????
#$INTERPRETIVE_CONSTANTS.s			# pp. ????-????
#$SINGLE_PRECISION_SUBROUTINES.s		# p.  ????
#$EXECUTIVE.s					# pp. ????-????
#$WAITLIST.s					# pp. ????-????
#$LATITUDE_LONGITUDE_SUBROUTINES.s		# pp. ????-????
#$PLANETARY_INERTIAL_ORIENTATION.s		# pp. ????-????
#$MEASUREMENT_INCORPORATION.s			# pp. ????-????
#$CONIC_SUBROUTINES.s				# pp. ????-????
#$INTEGRATION_INITIALIZATION.s			# pp. ????-????
#$ORBITAL_INTEGRATION.s				# pp. ????-????
#$INFLIGHT_ALIGNMENT_ROUTINES.s			# pp. ????-????
#$POWERED_FLIGHT_SUBROUTINES.s			# pp. ????-????
#$TIME_OF_FREE_FALL.s				# pp. ????-????
#$STAR_TABLES.s					# pp. ????-????
#$AGC_BLOCK_TWO_SELF-CHECK.s			# pp. ????-????
#$PHASE_TABLE_MAINTENANCE.s			# pp. ????-????
#$RESTARTS_ROUTINE.s				# pp. ????-????
#$IMU_MODE_SWITCHING_ROUTINES.s			# pp. ????-????
#$KEYRUPT_UPRUPT.s				# pp. ????-????
#$DISPLAY_INTERFACE_ROUTINES.s			# pp. ????-????
#$SERVICE_ROUTINES.s				# pp. ????-????
#$ALARM_AND_ABORT.s				# pp. ????-????
#$UPDATE_PROGRAM.s				# pp. ????-????
#$RT8_OP_CODES.s				# pp. ????-????

						# pp. ????-????: YUL-generated tables.

