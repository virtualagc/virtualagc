#!/usr/bin/python3
# This little script simply tries to parse an LVDC HOP
# constant, given in octal in an LVDC assembly listing, 
# into its component fields.  It simply takes inputs 
# from stdin, one HOP constant per line, and prints
# results to stdout.

import sys

for line in sys.stdin:
	hop = int(line, 8) >> 1
	#syllable0 = hop >> 13
	#syllable1 = hop & 0o17777
	#print("%05o %05o" % (syllable0, syllable1))
	#hop = (syllable1 << 13) | syllable0
	
	IM = (hop >> 25) | ((hop & 0o3) << 1)
	IS = (hop >> 2) & 0o17
	S = (hop >> 6) & 0o1
	LOC = (hop >> 7) & 0o377
	DUPDN = (hop >> 16) & 0o1
	DM = (hop >> 17) & 0o7
	DS = (hop >> 20) & 0o17
	DUPIN = (hop >> 24) & 0o1
	
	print("IM IS S LOC DM DS DUPIN DUPDN")
	line = " %o %02o %o %03o  %o %02o     %1o     %1o" % (IM, IS, S, LOC, DM, DS, DUPIN, DUPDN)
	print(line)
	
