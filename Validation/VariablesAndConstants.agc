# Copyright 2004 Ronald S. Burkey <info@sandroid.org>
#  
# This file is part of yaAGC. 
#
# yaAGC is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# yaAGC is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with yaAGC; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

# Filename:	VariablesAndConstants.agc
# Purpose:	Definitions of constants and variables for the validation
#		suite.
# Mod history:	07/04/04 RSB.	Began.
#		07/06/04 RSB.	Added stuff for the MASK test, and the 
#				similar logical tests for ROR, WOR, RAND,
#				WAND, and RXOR.
#		07/07/04 RSB.	Addes SKEEP1 through SKEEP7.

#-----------------------------------------------------------------------
# Constants and read-only memory.

# Names of CPU registers.
A		EQUALS	0
L		EQUALS	1
Q		EQUALS	2
EB		EQUALS	3
FB		EQUALS	4
Z		EQUALS	5
BB		EQUALS	6
ZEROES		EQUALS	7	# Really an unnamed register.
ARUPT		EQUALS	10
LRUPT		EQUALS	11
QRUPT		EQUALS	12
ZRUPT		EQUALS	15
BBRUPT		EQUALS	16
BRUPT		EQUALS	17
CYR		EQUALS	20
SR		EQUALS	21
CYL		EQUALS	22
EDOP		EQUALS	23

# Patterns for display of digits.
DSPBLANK	OCT	0
DSP0		OCT	25
DSP1		OCT	3
DSP2		OCT	31
DSP3		OCT	33
DSP4		OCT	17
DSP5		OCT	36
DSP6		OCT	34
DSP7		OCT	23
DSP8		OCT	35
DSP9		OCT	37

SZERO		EQUALS	0
CH10		EQUALS	10
CH11		EQUALS	11
CH32		EQUALS	32
CH26		EQUALS	26
CH27		EQUALS	27
O177		OCT	177
O377		OCT	377
O3777		OCT	3777
O17777		OCT	17777
O20000		OCT	20000
O37774		OCT	37774
O37776		OCT	37776
O54000		OCT	54000
O50000		OCT	50000
O44000		OCT	44000
O40000		OCT	40000
O77770		OCT	77770
O-3777		OCT	74000
O-4000		OCT	73777
O-17777		OCT	60000
O-20000		OCT	57777
O-37774		OCT	40003
O-37776		OCT	40001
NEGZERO		OCT	77777
NEGONE		OCT	77776
NEGTWO		DEC	-2
NEGTHREE	DEC	-3
NEGFOUR		DEC	-4
ONE		OCT	1
TWO		OCT	2
THREE		OCT	3
FIVE		OCT	5
NINE		DEC	9
TEN		DEC	10
SEVEN		DEC	7
TWNTHREE	DEC	23
BIT1		OCT	1
BIT7		OCT	100
BIT14		OCT	20000
MAXP		OCT	37777
MAXP-1		OCT	37776
MAXP-2		OCT	37775
MAXP-3		OCT	37774
MAXN		OCT	40000
MAXN-1		OCT	40001
MAXN-2		OCT	40002
MAXN-3		OCT	40003

MAXERR		OCT	77777
WHERE1		GENADR	DEST1
CONC+S1		OCT	25252		# USED IN CYCLSHFT
CONC+S2		OCT	52400		# USED IN CYCLSHFT
S+1		EQUALS	BIT1
BIGNUM		2DEC	21911761 B-28
BIGRNUM		2DEC	262941132 B-28	# 14 (oct) * BIGNUM
DBZERO		2DEC	0
DBMZERO		2DEC	-0
DBONE		2DEC	1 B-28
DBMONE		2DEC	-1 B-28
DBMAXP		2DEC	268435455 B-28	# Biggest positive DP number.
DBMAXN		2DEC	-268435455 B-28
DBMAXP-1	2DEC	268435454 B-28
DBMAXN-1	2DEC	-268435454 B-28
SMALNUM		OCT	12345
SMALRNUM	OCT	37257		# 3 * SMALNUM

MASKL1		OCT	52525
MASKR1		OCT	25252
MASKL2		OCT	63146
MASKR2		OCT	14631
ANDL1L2		OCT	42104
ANDL1R2		OCT	10421
ANDR1L2		OCT	21042
ANDR1R2		OCT	04210
ORL1L2		OCT	73567
ORL1R2		OCT	56735
ORR1L2		OCT	67356
ORR1R2		OCT	35673
XORL1L2		OCT	31463
XORL1R2		OCT	46314
XORR1L2		OCT	46314
XORR1R2		OCT	31463

#-------------------------------------------------------------------------
# Some variables.

		SETLOC	61
		
ERRNUM		ERASE			# Error-code, reported to DSKY.
ERRSUB		ERASE			# Error-subcode.

# Dummy variables.
TEMPI		ERASE
TEMPJ		ERASE
TEMPK		ERASE

# For Smally's tests.
SKEEP1		ERASE
SKEEP2		ERASE
SKEEP3		ERASE
SKEEP4		ERASE
SKEEP5		ERASE
SKEEP6		ERASE
SKEEP7		ERASE



