### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    CONTRACT_AND_APPROVALS.agc
## Purpose:     A section of Comanche revision 044.
##              It is part of the reconstructed source code for the
##              original release of the flight software for the Command
##              Module's (CM) Apollo Guidance Computer (AGC) for Apollo 10.
##              The code has been recreated from a copy of Comanche 055. It
##              has been adapted such that the resulting bugger words
##              exactly match those specified for Comanche 44 in NASA drawing
##              2021153D, which gives relatively high confidence that the
##              reconstruction is correct.
## Assembler:   yaYUL
## Contact:     Ron Burkey <info@sandroid.org>.
## Website:     www.ibiblio.org/apollo/index.html
## Mod history: 2020-12-03 MAS  Created from Comanche 51.
##              2020-12-05 MAS  Changed name to COLOSSUS 2 and dates to
##                              approximate Comanche 44 release date.
##		2020-12-11 RSB	Added justifying annotations related to
##				Mike's reconstruction.

## Page 1

## <b>Reconstruction:</b> We don't know of any surviving specific contemporary
## documentation supporting the material in this log section, absent an
## Apollo-era assembly listing of it.  The section contains
## only comments and no executable code.  We have simply modeled the Comanche 44 version of it on the 
## corresponding log section of Comanche 55, but have changed a handful of
## items in ways that seem sensible to us.  The annotations below thus 
## provide our common-sense reasoning on the matter, rather than justification from documentation.

# ************************************************************************
# *									 *
# *		THIS AGC PROGRAM SHALL ALSO BE REFERRED TO AS:		 *
# *									 *
# *									 *
## <b>Reconstruction:</b> The line in Comanche 55 corresponding to the following 
## one reads "COLOSSUS 2A".
## We have changed it to "COLOSSUS 2" for Comanche 44, since generically COLOSSUS 2
## refers to the Apollo 10 CM software; COLOSSUS 2A, 2C, 2D, and 2E generically
## refer to Apollo 11, 12, 13, and 14.
# *				COLOSSUS 2 				 *
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

## <b>Reconstruction:</b> The signature names and titles below are not
## actually known for certain.  Because Comanche 44 through 55 were separated by
## only 1-3 months in time (see below), we assume that personnel turnover 
## in that limited period of time would be unlikely. Hence we have retained the 
## same names and titles for Comanche 44 as for Comanche 55. 
## <br><br>
## On the other hand, the DATE fields below are more speculative, 
## and are very likely to be wrong but unlikely to be <i>too</i> wrong.  Consider the document
## <a href="http://www.ibiblio.org/apollo/Documents/a042186.pdf#page=52">
## <i>Software Systems Development: A CSDL Project History</i>, Table 4-6</a>.
## From the data in that table, and from the Comanche 55 source code, here is
## a timeline of events for your consideration:<br>
## <ul>
## <li>March 28, 1969:  Signoff date in Comanche 55's CONTRACT AND APPROVALS
## log section.</li>
## <li>April 18, 1969:  Colossus 2A released.  We presume that this refers to
## the release of Comanche 55.</li>
## </ul>
## From this timeline, we conclude that for Comanche 55, CONTRACT AND APPROVALS signoffs
## occurred 3 weeks prior to the official release date of the software.
## <br><br>
## To use that information, however, requires knowing the release date for 
## Comanche 44, which does not appear in the reference just mentioned.  The best
## information we're aware of comes from
## <a href="http://www.ibiblio.org/apollo/Documents/R-700.pdf#page=170">
## <i>MIT's Role in Project Apollo, Final Report</i>, Table 4-II</a>.  There,
## we see release dates of<br>
## <ul>
## <li>February, 1969:  Comanche 44 released.</li>
## <li>April, 1969: Comanche 55 released.</li>
## </ul> 
## which is consistent, but which unfortunately lacks some specificity.  At any 
## rate, noting that Comanche 44 was released sometime between February 1 and 
## February 28, and then subtracting 21 days, we guess that the software signoffs
## occurred somewhere between January 11 and February 7.  The midpoint of that
## range is January 24, which in 1969 was a Friday.
#	SUBMITTED:	MARGARET H. HAMILTON		DATE:	24 JAN 69
#		M.H.HAMILTON, COLOSSUS PROGRAMMING LEADER
#		APOLLO GUIDANCE AND NAVIGATION

#	APPROVED:	DANIEL J. LICKLY		DATE:	24 JAN 69
#		D.J.LICKLY, DIRECTOR, MISSION PROGRAM DEVELOPMENT
#		APOLLO GUIDANCE AND NAVIGATION PROGRAM

#	APPROVED:	FRED H. MARTIN			DATE:	24 JAN 69
#		FRED H. MARTIN, COLOSSUS PROJECT MANGER
#		APOLLO GUIDANCE AND NAVIGATION PROGRAM

#	APPROVED:	NORMAN E. SEARS			DATE:	24 JAN 69
#		N.E. SEARS, DIRECTOR, MISSION DEVELOPMENT
#		APOLLO GUIDANCE AND NAVIGATION PROGRAM

#	APPROVED:	RICHARD H. BATTIN		DATE:	24 JAN 69
#		R.H. BATTIN, DIRECTOR, MISSION DEVELOPMENT
#		APOLLO GUIDANCE AND NAVIGATION PROGRAM

#	APPROVED:	DAVID G. HOAG			DATE:	24 JAN 69
#		D.G. HOAG, DIRECTOR
#		APOLLO GUIDANCE AND NAVIGATION PROGRAM

#	APPROVED:	RALPH R. RAGAN			DATE:	24 JAN 69
#		R.R. RAGAN, DEPUTY DIRECTOR
#		INSTRUMENTATION LABORATORY

