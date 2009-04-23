# Copyright:	Public domain.
# Filename:	STAR_TABLES.s
# Purpose:	Part of the source code for Colossus, build 249.
#		It is part of the source code for the Command Module's (CM)
#		Apollo Guidance Computer (AGC), possibly for Apollo 8 and 9.
# Assembler:	yaYUL
# Reference:	Starts on p. 1379 of 1701.pdf.
# Contact:	Ron Burkey <info@sandroid.org>.
# Website:	www.sandroid.org/Apollo.
# Mod history:	08/30/04 RSB.	Adapted from corresponding Luminary131 file.
#
# The contents of the "Colossus249" files, in general, are transcribed 
# from a scanned document obtained from MIT's website,
# http://hrst.mit.edu/hrs/apollo/public/archive/1701.pdf.  Notations on this
# document read, in part:
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
# In some cases, where the source code for Luminary 131 overlaps that of 
# Colossus 249, this code is instead copied from the corresponding Luminary 131
# source file, and then is proofed to incorporate any changes.

# Page 1379
		BANK	32
		SETLOC	STARTAB
		BANK
		
		COUNT	14/STARS
		
		2DEC	+.8341953207 B-1	# STAR 37	X
		2DEC	-.2394362567 B-1	# STAR 37	Y
		2DEC	-.4967780649 B-1	# STAR 37	Z
		
		2DEC	+.8138753897 B-1	# STAR 36	X
		2DEC	-.5559063490 B-1	# STAR 36	Y
		2DEC	+.1690413589 B-1	# STAR 36	Z
		
		2DEC	+.4540570017 B-1	# STAR 35	X
		2DEC	-.5393383149 B-1	# STAR 35	Y
		2DEC	+.7091871552 B-1	# STAR 35	Z
		
		2DEC	+.3200014224 B-1	# STAR 34	X
		2DEC	-.4436740480 B-1	# STAR 34	Y
		2DEC	-.8371095679 B-1	# STAR 34	Z
		
		2DEC	+.5518160037 B-1	# STAR 33	X
		2DEC	-.7934422090 B-1	# STAR 33 	Y
		2DEC	-.2568045150 B-1	# STAR 33	Z
		
		2DEC	+.4535361097 B-1	# STAR 32	X
		2DEC	-.8780537171 B-1	# STAR 32	Y
		2DEC	+.1527307006 B-1	# STAR 32	Z
		
		2DEC	+.2067145272 B-1	# STAR 31	X
		2DEC	-.8720349419 B-1	# STAR 31	Y
		2DEC	-.4436486945 B-1	# STAR 31	Z
		
		2DEC	+.1216171923 B-1	# STAR 30	X
# Page 1380
		2DEC	-.7703014754 B-1	# STAR 30 	Y
		2DEC	+.6259751556 B-1	# STAR 30	Z
		
		2DEC	-.1126265542 B-1	# STAR 29	X
		2DEC	-.9694679589 B-1	# STAR 29	Y
		2DEC	+.2178236347 B-1	# STAR 29	Z
		
		2DEC	-.1147906312 B-1	# STAR 28	X
		2DEC	-.3399437395 B-1	# STAR 28 	Y
		2DEC	-.9334138229 B-1	# STAR 28	Z
		
		2DEC	-.3518772846 B-1	# STAR 27	X
		2DEC	-.8239967165 B-1	# STAR 27	Y
		2DEC	-.4440853383 B-1	# STAR 27	Z
		
		2DEC	-.5328042377 B-1	# STAR 26	X
		2DEC	-.7159448596 B-1	# STAR 26	Y
		2DEC	+.4511569595 B-1	# STAR 26	Z
		
		2DEC	-.7862552143 B-1	# STAR 25	X
		2DEC	-.5216265404 B-1	# STAR 25	Y
		2DEC	+.3312227199 B-1	# STAR 25	Z
		
		2DEC	-.6899901699 B-1	# STAR 24	X
		2DEC	-.4180817950 B-1	# STAR 24	Y
		2DEC	-.5908647707 B-1	# STAR 24	Z
		
		2DEC	-.5811943804 B-1	# STAR 23	X
		2DEC	-.2907877154 B-1	# STAR 23	Y
		2DEC	+.7600365758 B-1	# STAR 23 	Z
		
		2DEC	-.9171065276 B-1	# STAR 22	X
		2DEC	-.3500098785 B-1	# STAR 22	Y
# Page 1381
		2DEC	-.1908106439 B-1	# STAR 22	Z
		
		2DEC	-.4524416631 B-1	# STAR 21	X
		2DEC	-.0492700670 B-1	# STAR 21	Y
		2DEC	-.8904319167 B-1	# STAR 21	Z
		
		2DEC	-.9525633510 B-1	# STAR 20	X
		2DEC	-.0591313500 B-1	# STAR 20	Y
		2DEC	-.2985406935 B-1	# STAR 20	Z
		
		2DEC	-.9656240240 B-1	# STAR 19	X
		2DEC	+.0528067543 B-1	# STAR 19	Y
		2DEC	+.2545224762 B-1	# STAR 19	Z
		
		2DEC	-.8606970465 B-1	# STAR 18	X
		2DEC	+.4638127405 B-1	# STAR 18	Y
		2DEC	+.2099484122 B-1	# STAR 18	Z
		
		2DEC	-.7741360248 B-1	# STAR 17	X
		2DEC	+.6154234025 B-1	# STAR 17	Y
		2DEC	-.1482142053 B-1	# STAR 17	Z
		
		2DEC	-.4656165921 B-1	# STAR 16	X
		2DEC	+.4775804724 B-1	# STAR 16	Y
		2DEC	+.7450624681 B-1	# STAR 16	Z
		
		2DEC	-.3611937602 B-1	# STAR 15	X
		2DEC	+.5748077840 B-1	# STAR 15	Y
		2DEC	-.7342581827 B-1	# STAR 15	Z
		
		2DEC	-.4116502629 B-1	# STAR 14 	X
		2DEC	+.9066387314 B-1	# STAR 14	Y
		2DEC	+.0924676785 B-1	# STAR 14	Z
		
# Page 1382
		2DEC	-.1818957154 B-1	# STAR 13	X
		2DEC	+.9405318128 B-1	# STAR 13	Y
		2DEC	-.2869039173 B-1	# STAR 13	Z
		
		2DEC	-.0614360769 B-1	# STAR 12 	X
		2DEC	+.6031700106 B-1	# STAR 12	Y
		2DEC	-.7952430739 B-1	# STAR 12	Z
		
		2DEC	+.1373948084 B-1	# STAR 11	X
		2DEC	+.6813398852 B-1	# STAR 11	Y
		2DEC	+.7189566241 B-1	# STAR 11	Z
		
		2DEC	+.2013426456 B-1	# STAR 10	X
		2DEC	+.9689888101 B-1	# STAR 10	Y
		2DEC	-.1432544058 B-1	# STAR 10	Z
		
		2DEC	+.3509587451 B-1	# STAR 9	X
		2DEC	+.8925545449 B-1	# STAR 9	Y
		2DEC	+.2831507435 B-1	# STAR 9	Z
		
		2DEC	+.4107492871 B-1	# STAR 8	X
		2DEC	+.4987190610 B-1	# STAR 8	Y
		2DEC	+.7632590132 B-1	# STAR 8	Z
		
		2DEC 	+.7033883645 B-1	# STAR 7	X
		2DEC	+.7074274193 B-1	# STAR 7	Y
		2DEC	+.0692188921 B-1	# STAR 7	Z
		
		2DEC	+.5450662811 B-1	# STAR 6	X
		2DEC	+.5313738486 B-1	# STAR 6	Y
		2DEC	-.6484940879 B-1	# STAR 6	Z
		
		2DEC	+.0131955837 B-1	# STAR 5	X
# Page 1383
		2DEC	+.0078043793 B-1	# STAR 5	Y
		2DEC	+.9998824772 B-1	# STAR 5	Z
		
		2DEC	+.4917355618 B-1	# STAR 4	X
		2DEC	+.2203784481 B-1	# STAR 4	Y
		2DEC	-.8423950835 B-1	# STAR 4 	Z
		
		2DEC	+.4776746280 B-1	# STAR 3	X
		2DEC	+.1164935557 B-1	# STAR 3	Y
		2DEC	+.8707790771 B-1	# STAR 3 	Z
		
		2DEC	+.9342726691 B-1	# STAR 2	X
		2DEC	+.1732973829 B-1	# STAR 2	Y
		2DEC	-.3116128956 B-1	# STAR 2	Z
		
		2DEC	+.8749183324 B-1	# STAR 1	X
		2DEC	+.0258916990 B-1	# STAR 1	Y
		2DEC	+.4835778442 B-1	# STAR 1	Z
		
CATLOG		DEC	6869
		


