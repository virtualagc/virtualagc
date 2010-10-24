# Copyright:	Public domain.
# Filename:	SINGLE_PRECISION_SUBROUTINES.agc
# Purpose:	Part of the source code for Colossus build 237.  
#		This is for the Command Module's (CM) Apollo Guidance
#		Computer (AGC), we believe for Apollo 8.
# Assembler:	yaYUL
# Contact:	Onno Hommes <ohommes@alumni.cmu.edu>
# Website:	www.ibiblio.org/apollo/index.html
# Page scans:	www.ibiblio.org/apollo/ScansForConversion/Colossus237/
# Mod history:	2010-06-03 OH	Adapted from corresponding Colossus 249 file.
#
# The contents of the "Colossus237" files, in general, are transcribed 
# from a scanned document obtained from Fred Martin.  Notations on this
# document read, in part:
#
#	Assemble revision 237 of AGC program Colossus by NASA
#	2021111-031.  August 24, 1968.  
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
# Please report any errors to info@sandroid.org.
#

# Page 1174
		BLOCK	02

# SINGLE PRECISION SINE AND COSINE

		COUNT	02/INTER
		
SPCOS		AD	HALF		# ARGUMENTS SCALED AT PI
SPSIN		TS	TEMK
		TCF	SPT
		CS	TEMK
SPT		DOUBLE
		TS	TEMK
		TCF	POLLEY
		XCH	TEMK
		INDEX	TEMK
		AD 	LIMITS
		COM
		AD	TEMK
		TS	TEMK
		TCF	POLLEY
		TCF	ARG90
POLLEY		EXTEND
		MP	TEMK
		TS	SQ
		EXTEND
		MP	C5/2
		AD	C3/2
		EXTEND
		MP	SQ
		AD	C1/2
		EXTEND
		MP	TEMK
		DDOUBL
		TS	TEMK
		TC	Q
ARG90		INDEX	A
		CS	LIMITS
		TC	Q		# RESULT SCALED AT 1.
		
# SPROOT WAS DELETED IN REV 51 OF MASTER. ASS. CONT. HAS CARDS.




