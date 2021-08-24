### FILE="Main.annotation"
## Copyright:	Public domain.
## Filename:	SYSTEM_TEST_STANDARD_LEAD_INS.agc
## Purpose:	Part of the reconstructed source code for LMY99 Rev 0,
##		otherwise known as Luminary Rev 99, the third release
##		of the Apollo Guidance Computer (AGC) software for Apollo 11.
##		It differs from LMY99 Rev 1 (the flown version) only in the
##		placement of a single label. The corrections shown here have
##		been verified to have the same bank checksums as AGC developer
##		Allan Klumpp's copy of Luminary Rev 99, and so are believed
##		to be accurate. This file is intended to be a faithful 
##		recreation, except that the code format has been changed to 
##		conform to the requirements of the yaYUL assembler rather than 
##		the original YUL assembler.
##
## Assembler:	yaYUL
## Contact:	Ron Burkey <info@sandroid.org>.
## Website:	www.ibiblio.org/apollo.
## Pages:	370-372
## Mod history:	2009-05-17 RSB	Adapted from the corresponding 
##				Luminary131 file, using page 
##				images from Luminary 1A.
##		2016-12-14 RSB	Proofed text comments with octopus/ProoferComments
##				and corrected the errors found.
##		2017-03-07 RSB	Comment-text fixes noted in proofing Luminary 116.
##		2017-08-01 MAS	Created from LMY99 Rev 1.

## This source code has been transcribed or otherwise adapted from
## digitized images of a hardcopy from the MIT Museum.  The digitization
## was performed by Paul Fjeld, and arranged for by Deborah Douglas of
## the Museum.  Many thanks to both.  The images (with suitable reduction
## in storage size and consequent reduction in image quality as well) are
## available online at www.ibiblio.org/apollo.  If for some reason you
## find that the images are illegible, contact me at info@sandroid.org
## about getting access to the (much) higher-quality images which Paul
## actually created.
##
## The code has been modified to match LMY99 Revision 0, otherwise
## known as Luminary Revision 99, the Apollo 11 software release preceeding
## the listing from which it was transcribed. It has been verified to
## contain the same bank checksums as AGC developer Allan Klumpp's listing
## of Luminary Revision 99 (for which we do not have scans).
##
## Notations on Allan Klumpp's listing read, in part:
##
##	ASSEMBLE REVISION 099 OF AGC PROGRAM LUMINARY BY NASA 2021112-51

## Page 370
		EBANK=	XSM
		
		BANK	33
		SETLOC	E/PROG
		BANK
		
		COUNT*	$$/P07
		
# SPECIAL PROGRAMS TO EASE THE PANGS OF ERASABLE MEMORY PROGRAMS.
#
# E/BKCALL	FOR DOING BANKCALLS FROM AND RETURNING TO ERASABLE.
#
# THIS ROUTINE IS CALLABLE FROM ERASABLE OR FIXED.  LIKE BANKCALL, HOWEVER, SWITCHING BETWEEN S3 AND S4
# IS NOT POSSIBLE.
#
# THE CALLING SEQUENCE IS:
#
#	TC	BANKCALL
#	CADR	E/BKCALL
#	CADR	ROUTINE		WHERE YOU WANT TO GO IN FIXED.
#	RETURN HERE FROM DISPLAY TERMINATE, BAD STALL OR TC Q.
#	RETURN HERE FROM DISPLAY PROCEED OR GOOD RETURN FROM STALL.
#	RETURN HERE FROM DISPLAY ENTER OR RECYCLE.
#
# THIS ROUTINE REQUIRES TWO ERASABLES (EBUF2, +1) IN UNSWITCHED WHICH ARE UNSHARED BY INTERRUPTS AND
# OTHER EMEMORY PROGRAMS.
#
# A + L ARE PRESERVED THROUGH BANKCALL AND E/BKCALL.

E/BKCALL	DXCH	BUF2		# SAVE A,L AND GET DP RETURN.
		DXCH	EBUF2		# SAVE DP RETURN.
		INCR	EBUF2		# RETURN +1 BECAUSE DOUBLE CADR.
		CA	BBANK
		MASK	LOW10		# GET CURRENT EBANK.  (SBANK SOMEDAY)
		ADS	EBUF2	+1	# FORM BBCON.  (WAS FBANK)
		NDX	EBUF2
		CA	0 	-1	# GET CADR OF ROUTINE.
		TC	SWCALL		# GO TO ROUTINE, SETTING Q TO SWRETURN
					# AND RESTORING A + L.
		TC	+4		# TX Q, V34, OR BAD STALL RETURN.
		TC	+2		# PROCEED OR GOOD STALL RETURN.
		INCR	EBUF2		# ENTER OR RECYCLE RETURN.
		INCR	EBUF2
E/SWITCH	DXCH	EBUF2
		DTCB
		
## Page 371
# E/CALL	FOR CALLING A FIXED MEMORY INTERPRETIVE SUBROUTINE FROM ERASABLE AND RETURNING TO ERASABLE.
#
# THE CALLING SEQUENCE IS...
#
#	RTB
#		E/CALL
#	CADR	ROUTINE			THE INTERPRETIVE SUBROUTINE YOU WANT.
#					RETURNS HERE IN INTERPRETIVE.
	
E/CALL		LXCH	LOC		# ADRES -1 OF CADR.
		INDEX	L
		CA	L		# CADR IN A.
		INCR	L
		INCR	L		# RETURN ADRES IN L.
		DXCH	EBUF2		# STORE CADR AND RETURN.
		TC	INTPRET
		CALL
			EBUF2		# INDIRECTLY EXECUTE ROUTINE.  IT MUST
		EXIT			# LEAVE VIA RVQ OR EQUIVALENT.
		LXCH	EBUF2 	+1	# PICK UP RETURN.
		TCF	INTPRET +2	# SET LOC AND RETURN TO CALLER.
		
## Page 372
# E/JOBWAK	FOR WAKING UP ERASABLE MEMORY JOBS.
#
# THIS ROUTINE MUST BE CALLED IN INTERRUPT OR WITH INTERRUPTS INHIBITED.
#
# THE CALLING SEQUENCE IS:
#
#	INHINT
#	  .
#         .
#	CA	WAKEADR		ADDRESS OF SLEEPING JOB
#	TC	IBNKCALL
#	CADR	E/JOBWAK
#	  .			RETURNS HERE
#	  .
#	  .
#	RELINT			IF YOU DID AN INHINT.

		BANK	33
		SETLOC	E/PROG
		BANK
		
		COUNT*	 $$/P07
		
E/JOBWAK	TC	JOBWAKE		# ARRIVE IWTH ADRES IN A.
		CS	BIT11
		NDX	LOCCTR
		ADS	LOC		# KNOCK FIXED MEMORY BIT OUT OF ADRES.
		TC	RUPTREG3	# RETURN
		
