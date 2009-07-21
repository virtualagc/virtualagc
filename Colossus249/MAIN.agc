# Copyright:	Public domain.
# Filename:	MAIN.agc
# Purpose:	Part of the source code for Colossus, build 249.
#		It is part of the source code for the Command Module's (CM)
#		Apollo Guidance Computer (AGC), possibly for Apollo 8 and 9.
# Assembler:	yaYUL
# Contact:	Ron Burkey <info@sandroid.org>.
# Website:	www.ibiblio.org/apollo
# Mod history:	04/30/03 RSB.	Created using the Luminary131 file of the 
#				same name as a model.
#		08/02/04 RSB	Resumed Colossus development.
#		08/22/04 RSB	Filled in all of the page numbers for the
#				individual include-files.
#
# The contents of the "Colossus249" files, in general, are transcribed 
# from a scanned document obtained from MIT's website,
# http://hrst.mit.edu/hrs/apollo/public/archive/1701.pdf.  I'd like to note
# that the character-set of the line-printer used must not have completely
# agreed with the one the developers had in mind, so I've interpreted various
# wacky symbols appearing in the print as follows:
#
#	Print				Interpretation
#	-----				--------------
#	plus-minus			      <
#	lower-case Greek delta		      >
#	lower-case Greek nu 		 | (sometimes)
#	strange lower-case d		      &
#	trailing '			      :
#	other				still uninterpreted
#
# Notations on the scanned document read, in part:
#
#	Assemble revision 249 of AGC program Colossus by NASA
#	2021111-041.  October 28, 1968.  
#
#	This AGC program shall also be referred to as
#				Colossus 1A
#
#	Prepared by
#			Massachussets Institute of Technology
#			75 Cambridge Parkway
#			Cambridge, Massachusetts
#	under NASA contract NAS 9-4065.
#
# Refer directly to the online document mentioned above for further information.
# Please report any errors (relative to 1701.pdf) to info@sandroid.org.
#
# This file is a little different from the other Colossus249 files I'm providing, 
# in that it doesn't represent anything that appears directly in the original source.  
# What I (RSB) have done for organizational purposes is to split the huge monolithic
# source code into smaller, more manageable chunks--i.e., into individual source 
# files.  Those files are rejoined within this file as "includes".  It just makes
# it a little easier to work with.  The code chunks correspond to natural divisions
# into sub-programs.  In fact, these divisions are more-or-less specified by
# the source code itself.  Refer to the "SUBROUTINE CALLS" at the
# very beginning of the file ASSEMBLY_AND_OPERATION_INFORMATION.agc.
#
# It may be reasonably asked why tens of thousands of lines of source are joined by
# means of inclusion, rather than simply assembling the source files individually and
# then linking them to form the executable.  The answer is that the original 
# development team had no linker.  The builds were monolithic just like this.
# There was a big emphasis on reusability of the code in the original project, 
# apparently, but this reusability took the form of inserting your deck of 
# punch-cards at the appropriate position in somebody else's deck of punch-cards.
# So, indeed, the method of file-inclusion is a very fair representation of the 
# methods used in the original development ... with the improvement, of course,
# that you no longer have to worry about dropping the card deck.  On the other hand, 
# I wasn't there at the time, so I may have no idea what I'm talking about.
#
# Finally, note that the original Apollo AGC assembler (called "YUL") is no longer 
# available (as far as I can tell).  The replacement assembler yaYUL accepts 
# a slightly different format for the source code from what YUL accepted, so the 
# source code has been targeted for assembly with yaYUL.

# What follows is simply a bunch of file-includes for the individual code chunks.
# I've marked the page numbers vs. the original scanned listing (1701.pdf) to 
# make proof-reading easier.  Besides, the scanned listing contains a lot of
# interesting tables (cross-referenced to page numbers) created by YUL, 
# but not duplicated by yaYUL, so it's still valuable even if the source-files
# listed below are in hand.

						# pp. 1-2 contain no code/comments.
$ASSEMBLY_AND_OPERATION_INFORMATION.agc		# pp. 3-26
$TAGS_FOR_RELATIVE_SETLOC.agc			# pp. 27-36

# KILERASE
$ERASABLE_ASSIGNMENTS.agc			# pp. 37-128

# KOOLADE
$INTERRUPT_LEAD_INS.agc				# pp. 129-130
$T4RUPT_PROGRAM.agc				# pp. 131-167
$DOWNLINK_LISTS.agc				# pp. 168-178
$FRESH_START_AND_RESTART.agc			# pp. 179-206
$RESTART_TABLES.agc				# pp. 207-217
$SXTMARK.agc 					# pp. 218-231
$EXTENDED_VERBS.agc				# pp. 232-264
$PINBALL_NOUN_TABLES.agc			# pp. 265-281
$CSM_GEOMETRY.agc				# pp. 282-293
$IMU_COMPENSATION_PACKAGE.agc			# pp. 294-303
$PINBALL_GAME_BUTTONS_AND_LIGHTS.agc		# pp. 304-384
$R60_62.agc					# pp. 385-393
$ANGLFIND.agc					# pp. 394-406
$GIMBAL_LOCK_AVOIDANCE.agc			# pp. 407-408
$KALCMANU_STEERING.agc				# pp. 409-414
$SYSTEM_TEST_STANDARD_LEAD_INS.agc		# pp. 415-417
$IMU_CALIBRATION_AND_ALIGNMENT.agc		# pp. 418-450

# SMOOCH
$GROUND_TRACKING_DETERMINATION_PROGRAM.agc	# pp. 451-453
$P34-35_P74-75.agc				# pp. 454-497
$R31.agc					# pp. 498-503
$P76.agc					# pp. 504-506
$R30.agc					# pp. 507-517
$STABLE_ORBIT.agc				# pp. 518-527

# PANDORA
$P11.agc					# pp. 528-544
$TPI_SEARCH.agc					# pp. 545-555
$P20-P25.agc					# pp. 556-629
$P30-P37.agc					# pp. 630-643
$P40-P47.agc					# pp. 644-696
$P51-P53.agc					# pp. 697-742
$LUNAR_AND_SOLAR_EPHEMERIDES_SUBROUTINES.agc	# pp. 743-746
$P61-P67.agc					# pp. 747-776
$SERVICER207.agc				# pp. 777-794
$ENTRY_LEXICON.agc				# pp. 795-801
$REENTRY_CONTROL.agc				# pp. 802-839
$CM_BODY_ATTITUDE.agc				# pp. 840-846
$P37_P70.agc					# pp. 847-890
$S-BAND_ANTENNA_FOR_CM.agc			# pp. 891-892
$LUNAR_LANDMARK_SELECTION_FOR_CM.agc		# pp. 893-902

# DAPCSM
$TVCINITIALIZE.agc				# pp. 903-906
$TVCEXECUTIVE.agc				# pp. 907-914
$TVCMASSPROP.agc				# pp. 915-919
$TVCRESTARTS.agc				# pp. 920-924
$TVCDAPS.agc					# pp. 925-946
$TVCSTROKETEST.agc				# pp. 947-951
$TVCROLLDAP.agc					# pp. 952-964
$TVCGEN3FILTERS.agc				# pp. 965-973
$MYSUBS.agc					# pp. 974-976
$RCS-CSM_DIGITAL_AUTOPILOT.agc			# pp. 977-999
$AUTOMATIC_MANEUVERS.agc			# pp. 1000-1011
$RCS-CSM_DAP_EXECUTIVE_PROGRAMS.agc		# pp. 1012-1013
$JET_SELECTION_LOGIC.agc			# pp. 1014-1037
$CM_ENTRY_DIGITAL_AUTOPILOT.agc			# pp. 1038-1074

# SATRAP
$DOWN-TELEMETRY_PROGRAM.agc			# pp. 1075-1084
$INTER-BANK_COMMUNICATION.agc			# pp. 1085-1088
$INTERPRETER.agc				# pp. 1089-1181
$FIXED_FIXED_CONSTANT_POOL.agc			# pp. 1182-1186
$INTERPRETIVE_CONSTANTS.agc			# pp. 1187-1188
$SINGLE_PRECISION_SUBROUTINES.agc		# p.  1189
$EXECUTIVE.agc					# pp. 1190-1202
$WAITLIST.agc					# pp. 1203-1217
$LATITUDE_LONGITUDE_SUBROUTINES.agc		# pp. 1218-1224
$PLANETARY_INERTIAL_ORIENTATION.agc		# pp. 1225-1233
$MEASUREMENT_INCORPORATION.agc			# pp. 1234-1243
$CONIC_SUBROUTINES.agc				# pp. 1244-1290
$INTEGRATION_INITIALIZATION.agc			# pp. 1291-1313
$ORBITAL_INTEGRATION.agc			# pp. 1314-1334
$INFLIGHT_ALIGNMENT_ROUTINES.agc		# pp. 1335-1344
$POWERED_FLIGHT_SUBROUTINES.agc			# pp. 1345-1362
$TIME_OF_FREE_FALL.agc				# pp. 1363-1378
$STAR_TABLES.agc				# pp. 1379-1383
$AGC_BLOCK_TWO_SELF-CHECK.agc			# pp. 1384-1393
$PHASE_TABLE_MAINTENANCE.agc			# pp. 1394-1403
$RESTARTS_ROUTINE.agc				# pp. 1404-1409
$IMU_MODE_SWITCHING_ROUTINES.agc		# pp. 1410-1438
$KEYRUPT_UPRUPT.agc				# pp. 1439-1441
$DISPLAY_INTERFACE_ROUTINES.agc			# pp. 1442-1474
$SERVICE_ROUTINES.agc				# pp. 1475-1482
$ALARM_AND_ABORT.agc				# pp. 1483-1486
$UPDATE_PROGRAM.agc				# pp. 1487-1497
$RT8_OP_CODES.agc				# pp. 1498-1505

						# pp. 1506-1746: YUL-generated tables.





