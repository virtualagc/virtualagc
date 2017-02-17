### FILE="Main.annotation"
# Copyright:	Public domain.
# Filename:	MAIN.agc
# Purpose:	Part of the source code for Colossus, build 249.
#		It is part of the source code for the Command Module's (CM)
#		Apollo Guidance Computer (AGC), for Apollo 9.
# Assembler:	yaYUL
# Contact:	Ron Burkey <info@sandroid.org>.
# Website:	www.ibiblio.org/apollo
# Mod history:	04/30/03 RSB.	Created using the Luminary131 file of the 
#				same name as a model.
#		08/02/04 RSB	Resumed Colossus development.
#		08/22/04 RSB	Filled in all of the page numbers for the
#				individual include-files.
#		2017-01-05 RSB	Page-numbering adjusted to conform to the markings
#				on the printed pages, rather than PDF page
#				numbers, which are no longer of interest to us.
#				However, I haven't yet modified all of the 
#				individual files in that manner yet.
#		2017-01-06 RSB	All of the individual .agc files for the different
#				log sections have now had their internal page-numbering
#				adjusted to conform to the numbering of the printed 
#				pages.
#		2017-01-20 RSB	Changed GOTOP00H to GOTOPOOH in all *.agc
#				files.  There are probably more POO problems
#				but those are the only ones I fixed.
#
# The contents of the "Colossus249" files, in general, are transcribed 
# from a scanned document originally obtained from MIT's website,
# http://hrst.mit.edu/hrs/apollo/public/archive/1701.pdf, though this has
# been superceded by a different, much-cleaner copy of the same printout 
# we received from AGC developer Fred Martin at one of the following sites:

# Note that the character-set of the line-printer used did not completely
# agreed with the one the developers had in mind --- and this is supported by
# detailed comparison to printouts of the slightly earlier Colossus 237 program
# and the later Comanche 55 program.  I've been told that this was printed on 
# a "page printer" as opposed to the normal line printer used for other AGC 
# printouts, and that the page printer had a configurable character set that 
# must have been configured incorrectly.  I've interpreted various
# wacky symbols appearing in the printout as follows:
#
#	Printed Character		Intended Character
#	-----------------		------------------
#	plus-minus			      	<
#	lower-case Greek alpha		      	'
#	lower-case Greek beta			"
#	lower-case Greek delta		      	>
#	lower-case Greek gamma 		      	|
#	lower-case Greek pi		      	?
#	upper-case Greek Sigma			%
#	strange lower-case d		      	&
#	integral symbol				#
#	'			      	      	:
#	:				      	@ 
#	(discarded)				_
# As far as the underscore character is concerned (_), I will insert it if it appears from
# closely-related program versions that it ought to be there, but there won't be anything
# in the actual printout that tells me it should be there.
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
#			Massachusetts Institute of Technology
#			75 Cambridge Parkway
#			Cambridge, Massachusetts
#	under NASA contract NAS 9-4065.
#
# Refer directly to the online document mentioned above for further information.
# Please report any errors (relative to scans of the Fred Martin version of the 
# printout) to info@sandroid.org.
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

$ASSEMBLY_AND_OPERATION_INFORMATION.agc		        # pp. 1-24
$TAGS_FOR_RELATIVE_SETLOC_AND_BLANK_BANK_CARDS.agc      # pp. 25-33
$SUBROUTINE_CALLS.agc					# p. 34

# KILERASE
$ERASABLE_ASSIGNMENTS.agc			        # pp. 35-126

# KOOLADE
$INTERRUPT_LEAD_INS.agc				        # pp. 127-128
$T4RUPT_PROGRAM.agc				        # pp. 129-165
$DOWNLINK_LISTS.agc				        # pp. 166-176
$FRESH_START_AND_RESTART.agc			        # pp. 177-204
$RESTART_TABLES.agc				        # pp. 205-215
$SXTMARK.agc 					        # pp. 216-229
$EXTENDED_VERBS.agc				        # pp. 230-262
$PINBALL_NOUN_TABLES.agc			        # pp. 263-279
$CSM_GEOMETRY.agc				        # pp. 280-291
$IMU_COMPENSATION_PACKAGE.agc			        # pp. 292-301
$PINBALL_GAME__BUTTONS_AND_LIGHTS.agc		        # pp. 302-382
$R60,R62.agc					        # pp. 383-391
$ANGLFIND.agc					        # pp. 392-404
$GIMBAL_LOCK_AVOIDANCE.agc			        # pp. 405-406
$KALCMANU_STEERING.agc				        # pp. 407-412
$SYSTEM_TEST_STANDARD_LEAD_INS.agc		        # pp. 413-415
$IMU_CALIBRATION_AND_ALIGNMENT.agc		        # pp. 416-448

# SMOOCH
$GROUND_TRACKING_DETERMINATION_PROGRAM_-_P21.agc	# pp. 449-451
$P34-P35,_P74-P75.agc				        # pp. 452-495
$R31.agc					        # pp. 496-501
$P76.agc					        # pp. 502-504
$R30.agc					        # pp. 505-515
$STABLE_ORBIT_-_P38-P39.agc			        # pp. 516-523

# PANDORA
$P11.agc					        # pp. 524-540
$TPI_SEARCH.agc					        # pp. 541-551
$P20-P25.agc					        # pp. 552-625
$P30,P37.agc					        # pp. 626-639
$P40-P47.agc					        # pp. 640-692
$P51-P53.agc					        # pp. 693-738
$LUNAR_AND_SOLAR_EPHEMERIDES_SUBROUTINES.agc	        # pp. 739-742
$P61-P67.agc					        # pp. 743-772
$SERVICER207.agc				        # pp. 773-790
$ENTRY_LEXICON.agc				        # pp. 791-797
$REENTRY_CONTROL.agc				        # pp. 798-835
$CM_BODY_ATTITUDE.agc				        # pp. 836-842
$P37,P70.agc					        # pp. 843-886
$S-BAND_ANTENNA_FOR_CM.agc			        # pp. 887-888
$LUNAR_LANDMARK_SELECTION_FOR_CM.agc		        # pp. 889-898

# DAPCSM
$TVCINITIALIZE.agc				        # pp. 899-902
$TVCEXECUTIVE.agc				        # pp. 903-910
$TVCMASSPROP.agc				        # pp. 911-915
$TVCRESTARTS.agc				        # pp. 916-920
$TVCDAPS.agc					        # pp. 921-942
$TVCSTROKETEST.agc				        # pp. 943-947
$TVCROLLDAP.agc					        # pp. 948-960
$TVCGEN3FILTERS.agc				        # pp. 961-969
$MYSUBS.agc					        # pp. 970-972
$RCS-CSM_DIGITAL_AUTOPILOT.agc			        # pp. 973-995
$AUTOMATIC_MANEUVERS.agc			        # pp. 996-1007
$RCS-CSM_DAP_EXECUTIVE_PROGRAMS.agc		        # pp. 1008-1009
$JET_SELECTION_LOGIC.agc			        # pp. 1010-1033
$CM_ENTRY_DIGITAL_AUTOPILOT.agc			        # pp. 1034-1062

# SATRAP
$DOWN-TELEMETRY_PROGRAM.agc			        # pp. 1063-1072
$INTER-BANK_COMMUNICATION.agc			        # pp. 1073-1076
$INTERPRETER.agc				        # pp. 1077-1169
$FIXED-FIXED_CONSTANT_POOL.agc			        # pp. 1170-1174
$INTERPRETIVE_CONSTANTS.agc			        # pp. 1175-1176
$SINGLE_PRECISION_SUBROUTINES.agc		        # p.  1177
$EXECUTIVE.agc					        # pp. 1178-1190
$WAITLIST.agc					        # pp. 1191-1205
$LATITUDE_LONGITUDE_SUBROUTINES.agc		        # pp. 1206-1212
$PLANETARY_INERTIAL_ORIENTATION.agc		        # pp. 1213-1221
$MEASUREMENT_INCORPORATION.agc			        # pp. 1222-1231
$CONIC_SUBROUTINES.agc				        # pp. 1232-1278
$INTEGRATION_INITIALIZATION.agc			        # pp. 1279-1301
$ORBITAL_INTEGRATION.agc			        # pp. 1302-1322
$INFLIGHT_ALIGNMENT_ROUTINES.agc		        # pp. 1323-1332
$POWERED_FLIGHT_SUBROUTINES.agc			        # pp. 1333-1340
$TIME_OF_FREE_FALL.agc				        # pp. 1341-1356
$STAR_TABLES.agc				        # pp. 1357-1361
$AGC_BLOCK_TWO_SELF-CHECK.agc			        # pp. 1362-1371
$PHASE_TABLE_MAINTENANCE.agc			        # pp. 1372-1381
$RESTARTS_ROUTINE.agc				        # pp. 1382-1387
$IMU_MODE_SWITCHING_ROUTINES.agc		        # pp. 1388-1416
$KEYRUPT,_UPRUPT.agc				        # pp. 1417-1419
$DISPLAY_INTERFACE_ROUTINES.agc			        # pp. 1420-1452
$SERVICE_ROUTINES.agc				        # pp. 1453-1460
$ALARM_AND_ABORT.agc				        # pp. 1461-1464
$UPDATE_PROGRAM.agc				        # pp. 1465-1475
$RTB_OP_CODES.agc				        # pp. 1476-1483

						        # pp. 1484-1719: YUL-generated tables.





