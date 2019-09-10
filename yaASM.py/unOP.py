#!/usr/bin/python3
# This little script simply tries to parse an LVDC assembled instruction, 
# given in octal in an LVDC assembly listing, 
# into its component fields.  It simply takes inputs 
# from stdin, one syllable constant per line, and prints
# results to stdout.  Inputs starting with a digit are for
# syllable 1 (left hand) while those starting with a space
# followed by a digit are syllable 0 (right hand).

import sys

instructions = [ "HOP", "MPY", "SUB", "DIV", "TNZ", "MPH", "AND", "ADD", "TRA", "XOR", "PIO", "STO", "TMI", "RSU", "", "CLA" ]

for line in sys.stdin:
	try:
		if line[:1] == " ":
			syllable = int(line[1:], 8)
		else:
			syllable = int(line, 8) >> 1
	except:
		continue
	op = (syllable >> 1) & 0x0F
	if op == 0o16:
		if (syllable & 32) == 0:
			instruction = "CDS"
			DM = (syllable >> 7) & 3
			DS = (syllable >> 10) & 15
			print("%s %o,%02o" % (instruction, DM, DS))
		elif (syllable & 0o10000) == 0:
			instruction = "SHF"
			address = (syllable >> 6) & 0o63
			if address == 0:
				print("SHL 0")
			elif address == 1:
				print("SHR 1")
			elif address == 2:
				print("SHR 2")
			elif address == 16:
				print("SHL 1")
			elif address == 32:
				print("SHL 2")
			else:
				print("%s %03o" % (instruction, address))
		else:
			instruction = "EXM"
			left = (syllable >> 11) & 3
			middle = (syllable >> 10) & 1
			right = (syllable >> 6) & 15
			print("%s %o,%o,%02o" % (instruction, left, middle, right))
	else:
		instruction = instructions[op]
		address = ((syllable >> 6) & 0xFF) | ((syllable << 3) & 0x100)
		print("%s %03o" % (instruction, address))

