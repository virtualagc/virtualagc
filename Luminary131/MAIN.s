# Copyright:	Public domain.
# Filename:	MAIN.s
# Purpose:	The main source file for Luminary 1C, revision 131.
#		It is part of the source code for the Lunar Module's (LM)
#		Apollo Guidance Computer (AGC) for Apollo 13 and Apollo 14.
# Assembler:	yaYUL
# Contact:	Ron Burkey <info@sandroid.org>.
# Website:	www.ibiblio.org/apollo/index.html
# Mod history:	04/12/03 RSB.	Began.
#		05/05/03 RSB.	...continued.
#		05/11/03 RSB	Draft of this file completed.
#		06/08/03 RSB	Drafts of all the included files completed.
#		05/14/05 RSB	Corrected website reference above.
#		06/30/09 RSB	Added an experimental HTML note.
#
# The contents of the "Luminary131" files, in general, are
# transcribed from a scanned document obtained from MIT's website, namely
# http://hrst.mit.edu/hrs/apollo/public/archive/1729.pdf.  Notations on this
# document read, in part:
#
#	NASA Apollo LUMINARY 131 (1C) Program Source Code Listing.
#	MIT Instrumentation/Draper Laboratory -- 19 December 1969, 1742 pages.
#	This listing contains the flight program for the Lunar Module 
#	as created by MIT's Draper Lab for the Apollo 13/14 moon missions.
#
# Refer directly to the online document mentioned above for further information.
# Please report any errors (relative to 1729.pdf) to info@sandroid.org.
#
# This file is a little different from the other Luminary131 files I'm providing, 
# in that it doesn't represent anything that appears directly in the original source.  
# What I (RSB) have done for organizational purposes is to split the huge monolithic
# source code into smaller, more manageable chunks--i.e., into individual source 
# files.  Those files are rejoined within this file as "includes".  It just makes
# it a little easier to work with.  The code chunks correspond to natural divisions
# into sub-programs.  In fact, these divisions are more-or-less specified by
# the source code itself.  Refer to the "TABLE OF SUBROUTINE LOG SECTIONS" at the
# very beginning of the file ASSEMBLY_AND_OPERATION_INFORMATION.s.
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
# I've marked the page numbers vs. the original scanned listing (1729.pdf) to 
# make proof-reading easier.  Besides, the scanned listing contains a lot of
# interesting tables (cross-referenced to page numbers) created by YUL, 
# but not duplicated by yaYUL, so it's still valuable even if the source-files
# listed below are in hand.  Notice, though, that the page number herein are those
# the scanned (PDF) file, and not those which are marked on the scanned pages
# themselves, so there is not an exact correspondence between YUL-generated
# page numbers appearing within tables and the page numbers marked in this source
# code.

<HTML>
  <!--This HTML is explanatory material added in 2009, and is not AGC source code.-->  
  <table style="margin-left: auto; margin-right: auto; width: 60%; text-align: left;" border="1" cellpadding="2" cellspacing="2">
  <tbody>
  <tr>
  <td style="vertical-align: top;"><b>Note:</b>
  click on any of the include-directives ($) below to browse to one of
  the individual source-file modules.&nbsp; Or, advance to the end of
  this file to see the symbol table, memory-bank checksums, or other
  by-products of assembling the source code.<br>
  </td>
  </tr>
  </tbody>
  </table>
</HTML>
						# pp. 1-5 contain no code/comments.
$ASSEMBLY_AND_OPERATION_INFORMATION.s		# pp. 6-32
$TAGS_FOR_RELATIVE_SETLOC.s			# pp. 33-42
$CONTROLLED_CONSTANTS.s				# pp. 43-58
$INPUT_OUTPUT_CHANNEL_BIT_DESCRIPTIONS.s	# pp. 59-65
$FLAGWORD_ASSIGNMENTS.s				# pp. 66-93
						# p.  94 is a YUL-generated table

# LUMERASE						
$ERASABLE_ASSIGNMENTS.s				# pp. 95-159

# LEMONAID
$INTERRUPT_LEAD_INS.s				# pp. 160-161
$T4RUPT_PROGRAM.s				# pp. 162-196
$RCS_FAILURE_MONITOR.s				# pp. 197-199
$DOWNLINK_LISTS.s				# pp. 200-212
$AGS_INITIALIZATION.s				# pp. 213-217
$FRESH_START_AND_RESTART.s			# pp. 218-243
$RESTART_TABLES.s				# pp. 244-249
$AOTMARK.s					# pp. 250-267
$EXTENDED_VERBS.s				# pp. 268-307
$PINBALL_NOUN_TABLES.s				# pp. 308-326
$LEM_GEOMETRY.s					# pp. 327-332
$IMU_COMPENSATION_PACKAGE.s			# pp. 333-344
$R63.s						# pp. 345-348
$ATTITUDE_MANEUVER_ROUTINE.s			# pp. 349-370
$GIMBAL_LOCK_AVOIDANCE.s			# p.  371
$KALCMANU_STEERING.s				# pp. 372-376
$SYSTEM_TEST_STANDARD_LEAD_INS.s		# pp. 377-379
$IMU_PERFORMANCE_TEST_2.s			# pp. 380-388
$IMU_PERFORMANCE_TESTS_4.s			# pp. 389-396
$PINBALL_GAME_BUTTONS_AND_LIGHTS.s		# pp. 397-480
$R60_62.s					# pp. 481-494
$S-BAND_ANTENNA_FOR_LM.s			# pp. 495-498
		
# LEMP20S
$RADAR_LEADIN_ROUTINES.s			# pp. 499-500
$P20-P25.s					# pp. 501-623

# LEMP30S
$P30_P37.s					# pp. 624-627
$P32-P35_P72-P75.s				# pp. 628-660

# KISSING
$GROUND_TRACKING_DETERMINATION_PROGRAM.s	# pp. 661-664
$P34-35_P74-75.s				# pp. 665-709
$R31.s						# pp. 710-715
$P76.s						# pp. 716-718
$R30.s						# pp. 719-729

# FLY
$BURN_BABY_BURN--MASTER_IGNITION_ROUTINE.s	# pp. 730-751
$P40-P47.s					# pp. 752-784
$THE_LUNAR_LANDING.s				# pp. 785-792
$THROTTLE_CONTROL_ROUTINES.s			# pp. 793-797
$LUNAR_LANDING_GUIDANCE_EQUATIONS.s		# pp. 798-827
$P70-P71.s					# pp. 828-835
$P12.s						# pp. 836-840
$ASCENT_GUIDANCE.s				# pp. 841-856
$SERVICER.s					# pp. 857-895
$LANDING_ANALOG_DISPLAYS.s			# pp. 896-906
$FINDCDUW--GUIDAP_INTERFACE.s			# pp. 907-925

# LEMP50S
$P51-P53.s					# pp. 926-982
$LUNAR_AND_SOLAR_EPHEMERIDES_SUBROUTINES.s	# pp. 983-986

# SKIPPER
$DOWN_TELEMETRY_PROGRAM.s			# pp. 987-996
$INTER-BANK_COMMUNICATION.s			# pp. 997-1000
$INTERPRETER.s					# pp. 1001-1093
$FIXED_FIXED_CONSTANT_POOL.s			# pp. 1094-1098
$INTERPRETIVE_CONSTANT.s			# pp. 1099-1100
$SINGLE_PRECISION_SUBROUTINES.s			# p.  1101
$EXECUTIVE.s					# pp. 1102-1115
$WAITLIST.s					# pp. 1116-1131
$LATITUDE_LONGITUDE_SUBROUTINES.s		# pp. 1132-1138
$PLANETARY_INERTIAL_ORIENTATION.s		# pp. 1139-1147
$MEASUREMENT_INCORPORATION.s			# pp. 1148-1157
$CONIC_SUBROUTINES.s				# pp. 1158-1202
$INTEGRATION_INITIALIZATION.s			# pp. 1203-1224
$ORBITAL_INTEGRATION.s				# pp. 1225-1245
$INFLIGHT_ALIGNMENT_ROUTINES.s			# pp. 1246-1255
$POWERED_FLIGHT_SUBROUTINES.s			# pp. 1256-1264
$TIME_OF_FREE_FALL.s				# pp. 1265-1280
$AGC_BLOCK_TWO_SELF_CHECK.s			# pp. 1281-1290
$PHASE_TABLE_MAINTENANCE.s			# pp. 1291-1299
$RESTARTS_ROUTINE.s				# pp. 1300-1305
$IMU_MODE_SWITCHING_ROUTINES.s			# pp. 1306-1334
$KEYRUPT_UPRUPT.s				# pp. 1335-1337
$DISPLAY_INTERFACE_ROUTINES.s			# pp. 1338-1370
$SERVICE_ROUTINES.s				# pp. 1371-1377
$ALARM_AND_ABORT.s				# pp. 1378-1382
$UPDATE_PROGRAM.s				# pp. 1383-1393
$RTB_OP_CODES.s					# pp. 1394-1399

# LMDAP
$T6-RUPT_PROGRAMS.s				# pp. 1400-1402
$DAP_INTERFACE_SUBROUTINES.s			# pp. 1403-1406
$DAPIDLER_PROGRAM.s				# pp. 1407-1417
$P-AXIS_RCS_AUTOPILOT.s				# pp. 1418-1436
$Q_R-AXIS_RCS_AUTOPILOT.s			# pp. 1439-1456
$TJET_LAW.s					# pp. 1457-1466
$KALMAN_FILTER.s				# pp. 1467-1468
$TRIM_GIMBAL_CNTROL_SYSTEM.s			# pp. 1469-1481
$AOSTASK_AND_AOSJOB.s				# pp. 1482-1503
$SPS_BACK-UP_RCS_CONTROL.s			# pp. 1504-1507
						# pp. 1508-1742: YUL-generated tables.




