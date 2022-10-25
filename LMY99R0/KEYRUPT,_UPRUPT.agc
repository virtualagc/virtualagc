### FILE="Main.annotation"
## Copyright:	Public domain.
## Filename:	KEYRUPT,_UPRUPT.agc
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
## Pages:	1338-1340
## Mod history:	2009-05-27 RSB	Adapted from the corresponding 
##				Luminary131 file, using page 
##				images from Luminary 1A.
##		2016-12-18 RSB	Proofed text comments with octopus/ProoferComments
##				and corrected the errors found.
##		2017-08-01 MAS	Created from LMY99 Rev 1.
##		2021-05-30 ABS	UPCK -> UPOK

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

## Page 1338
		BANK	14
		SETLOC	KEYRUPT
		BANK
		COUNT*	$$/KEYUP

KEYRUPT1	TS	BANKRUPT
		XCH	Q
		TS	QRUPT
		TC	LODSAMPT	# TIME IS SNATCHED IN RUPT FOR NOUN 65.
		CAF	LOW5
		EXTEND
		RAND	MNKEYIN		# CHECK IF KEYS 5M-1M ON
KEYCOM		TS	RUPTREG4
		CS	FLAGWRD5
		MASK	DSKYFBIT
		ADS	FLAGWRD5

ACCEPTUP	CAF	CHRPRIO		# (NOTE: RUPTREG4 = KEYTEMP1)
		TC	NOVAC
		EBANK=	DSPCOUNT
		2CADR	CHARIN

		CA	RUPTREG4
		INDEX	LOCCTR
		TS	MPAC		# LEAVE 5 BIT KEY CDE IN MPAC FOR CHARIN
		TC	RESUME

## Page 1339
# UPRUPT PROGRAM

UPRUPT		TS	BANKRUPT
		XCH	Q
		TS	QRUPT
		TC	LODSAMPT	# TIME IS SNATCHED IN RUPT FOR NOUN 65.
		CAF	ZERO
		XCH	INLINK
		TS	KEYTEMP1
		CAF	BIT3		# TURN ON UPACT LIGHT
		EXTEND			# (BIT 3 OF CHANNEL 11)
		WOR	DSALMOUT
UPRPT1		CAF	LOW5		# TEST FOR TRIPLE CHAR REDUNDANCY
		MASK	KEYTEMP1	# LOW5 OF WORD
		XCH	KEYTEMP1	# LOW5 INTO KEYTEMP1
		EXTEND
		MP	BIT10		# SHIFT RIGHT 5
		TS	KEYTEMP2
		MASK	LOW5		# MID 5
		AD	HI10
		TC	UPTEST
		CAF	BIT10
		EXTEND
		MP	KEYTEMP2	# SHIFT RIGHT 5
		MASK	LOW5		# HIGH 5
		COM
		TC	UPTEST

UPOK		CS	ELRCODE		# CODE IS GOOD.  IF CODE = 'ERROR RESET',
		AD	KEYTEMP1	# CLEAR UPLOCKFL (SET BIT4 OF FLAGWRD7 = 0)
		EXTEND			# IF CODE DOES NOT = 'ERROR RESET', ACCEPT
		BZF	CLUPLOCK	# CODE ONLY IF UPLOCKFL IS CLEAR (=0).

		CAF	UPLOCBIT	# TEST UPLOCKFL FOR 0 OR 1
		MASK	FLAGWRD7
		CCS	A
		TC	RESUME		# UPLOCKFL = 1
		TC	ACCEPTUP	# UPLOCKFL = 0

CLUPLOCK	CS	UPLOCBIT	# CLEAR UPLOCKFL (I.E., SET BIT 4 OF )
		MASK	FLAGWRD7	# FLAGWRD7 = 0)
		TS	FLAGWRD7
		TC	ACCEPTUP

					# CODE IS BAD
TMFAIL2		CS	FLAGWRD7	# LOCK OUT FURTHER UPLINK ACTIVITY
		MASK	UPLOCBIT	# (BY SETTING UPLOCKFL = 1) UNTIL
		ADS	FLAGWRD7	# 'ERROR RESET' IS SENT VIA UPLINK.
		TC	RESUME
UPTEST		AD	KEYTEMP1
## Page 1340
		CCS	A
		TC	TMFAIL2
HI10		OCT	77740
		TC	TMFAIL2
		TC	Q

ELRCODE		OCT	22

# 'UPLINK ACTIVITY LIGHT' IS TURNED OFF BY .....
#	1.	VBRELDSP
#	2.	ERROR RESET
#	3.	UPDATE PROGRAM (P27) ENTERED BY V70,V71,V72, AND V73.
#				     -
# THE RECEPTION OF A BAD CODE (I.E  CCC FAILURE) LOCKS OUT FURTHER UPLINK ACTIVITY BY SETTING BIT4 OF FLAGWRD7 = 1.
# THIS INDICATION WILL BE TRANSFERRED TO THE GROUND BY THE DOWNLINK WHICH DOWNLINKS ALL FLAGWORDS.
# WHEN UPLINK ACTIVITY IS LOCKED OUT, IT CAN BE ALLOWED WHEN THE GROUND UPLINKS AND 'ERROR RESET' CODE.
# (IT IS RECOMMENDED THAT THE 'ERROR LIGHT RESET' CODE IS PRECEEDED BY 16 BITS THE FIRST OF WHICH IS 1 FOLLOWED
# BY 15 ZEROES.  THIS WILL ELIMINATE EXTRANEOUS BITS FROM INLINK WHICH MAY HAVE BEEN LEFT OVER FROM THE ORIGINAL
# FAILURE)
#
# UPLINK ACTIVITY IS ALSO ALLOWED (UNLOCKED) DURING FRESH START WHEN FRESH START SETS BIT4 OF FLAGWRD7 = 0.

		CS	XDSPBIT

