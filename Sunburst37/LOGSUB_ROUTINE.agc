### FILE="Main.annotation"
## Copyright:	Public domain.
## Filename:	LOGSUB_ROUTINE.agc
## Purpose:	A module for revision 0 of BURST120 (Sunburst). It 
##		is part of the source code for the Lunar Module's
##		(LM) Apollo Guidance Computer (AGC) for Apollo 5.
## Assembler:	yaYUL
## Contact:	Ron Burkey <info@sandroid.org>.
## Website:	www.ibiblio.org/apollo/index.html
## Mod history:	2016-09-30 RSB	Created draft version.
##		2016-10-19 RSB	Transcribed.
##		2016-12-06 RSB	Comment proofing via octopus/ProoferComments
##				performed, but no changes made.

## Page 925
# INPUT....X IN MPAC
# OUTPUT...-LOG(X)/32 IN MPAC

		BANK	32
LOGSUB		NORM	BDSU
			MPAC	+6
			ALMOST1
		EXIT
		TC	POLY
		DEC	6
		2DEC	.0000000060
		
		2DEC	-.0312514377
		
		2DEC	-.0155686771
		
		2DEC	-.0112502068
		
		2DEC	-.0018545108
		
		2DEC	-.0286607906
		
		2DEC	.0385598563
		
		2DEC	-.0419361902
		
		CAF	ZERO
		TS	MPAC	+2
		EXTEND
		DCA	CLOG2/32
		DXCH	MPAC
		DXCH	BUF	+1
		CA	MPAC	+6
		TC	SHORTMP
		DXCH	MPAC	+1
		DXCH	MPAC
		DXCH	BUF	+1
		DAS	MPAC
		TC	INTPRET
		DCOMP	RVQ
CLOG2/32	2DEC	.0216608494

ALMOST1		2DEC	.999999999
