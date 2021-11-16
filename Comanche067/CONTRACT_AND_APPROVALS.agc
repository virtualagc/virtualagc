







### FILE="Main.annotation"
## Copyright:	Public domain.
## Filename:	CONTRACT_AND_APPROVALS.agc
## Purpose:	Part of the source code for Comanche 67 (Colossus 2C),
##		the one-and-only software release for the Apollo Guidance 
##		Computer (AGC) of Apollo 12's command module.  In the 
##		absence of a contemporary assembly listing for Comanche 67, 
##		the intention is to reconstruct the source code from a 
##		Comanche 55 (Colossus 2A, Apollo 11 CM) baseline and 
##		contemporary documentation describing the differences 
##		between the two.  Page numbers listed in the program 
##		comments follow Comanche 55 unless otherwise noted.
## Assembler:	yaYUL
## Contact:	Ron Burkey <info@sandroid.org>.
## Website:	www.ibiblio.org/apollo.
## Mod history: 2020-12-25 RSB	Began adaptation from Comanche 55 baseline.

## Page 1

# ************************************************************************
# *									 *
# *		THIS AGC PROGRAM SHALL ALSO BE REFERRED TO AS:		 *
# *									 *
# *									 *
# *				COLOSSUS 2A				 *
# *									 *
# *									 *
# *	 THIS PROGRAM IS INTENDED FOR USE IN THE CM AS SPECIFIED	 *
# *	 IN REPORT R-577.  THIS PROGRAM WAS PREPARED UNDER DSR		 *
# *	 PROJECT 55-23870, SPONSORED BY THE MANNED SPACECRAFT		 *
# *	 CENTER OF THE NATIONAL AERONAUTICS AND SPACE			 *
# *	 ADMINISTRATION THROUGH CONTRACT NAS 9-4065 WITH THE		 *
# *	 INSTRUMENTATION LABORATORY, MASSACHUSETTS INSTITUTE OF		 *
# *	 TECHNOLOGY, CAMBRIDGE, MASS.					 *
# *									 *
# ************************************************************************


#	SUBMITTED:	MARGARET H. HAMILTON		DATE:	28 MAR 69
#		M.H.HAMILTON, COLOSSUS PROGRAMMING LEADER
#		APOLLO GUIDANCE AND NAVIGATION

#	APPROVED:	DANIEL J. LICKLY		DATE:	28 MAR 69
#		D.J.LICKLY, DIRECTOR, MISSION PROGRAM DEVELOPMENT
#		APOLLO GUIDANCE AND NAVIGATION PROGRAM

#	APPROVED:	FRED H. MARTIN			DATE:	28 MAR 69
#		FRED H. MARTIN, COLOSSUS PROJECT MANGER
#		APOLLO GUIDANCE AND NAVIGATION PROGRAM

#	APPROVED:	NORMAN E. SEARS			DATE:	28 MAR 69
#		N.E. SEARS, DIRECTOR, MISSION DEVELOPMENT
#		APOLLO GUIDANCE AND NAVIGATION PROGRAM

#	APPROVED:	RICHARD H. BATTIN		DATE:	28 MAR 69
#		R.H. BATTIN, DIRECTOR, MISSION DEVELOPMENT
#		APOLLO GUIDANCE AND NAVIGATION PROGRAM

#	APPROVED:	DAVID G. HOAG			DATE:	28 MAR 69
#		D.G. HOAG, DIRECTOR
#		APOLLO GUIDANCE AND NAVIGATION PROGRAM

#	APPROVED:	RALPH R. RAGAN			DATE:	28 MAR 69
#		R.R. RAGAN, DEPUTY DIRECTOR
#		INSTRUMENTATION LABORATORY

