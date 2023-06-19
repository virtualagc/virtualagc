#!/usr/bin/python3
# This little script simply tries to parse an LVDC assembled instruction, 
# given in octal in an LVDC assembly listing, 
# into its component fields.  It simply takes inputs 
# from stdin, one syllable constant per line, and prints
# results to stdout.  Inputs starting with a digit are for
# syllable 1 (left hand) while those starting with a space
# followed by a digit are syllable 0 (right hand).

# Updated 2023-04-12 to show the A8-1 A9 OP fields explicitly for most instructions.

import sys

instructions = [ "HOP", "MPY", "SUB", "DIV", "TNZ", "MPH", "AND", "ADD", "TRA", "XOR", "PIO", "STO", "TMI", "RSU", "", "CLA" ]

print("For syllable 1 (left-hand column in assembly listings), enter a 5-digit")
print("octal number.  For syllable 0 (right-hand column), enter a space")
print("character followed by a 5-digit octal number.  Only one value can be")
print("input per line!  Hit control-C to exit.")
for line in sys.stdin:
	try:
		if line[:1] == " ":
			syllable = int(line[1:], 8)
			print("Syllable 0 (right) detected.")
		else:
			syllable = int(line, 8) >> 1
			print("Syllable 1 (left) detected.")
	except:
		print("Unrecognized input, try again.")
		continue
	syllable_1 = syllable >> 1
	op = syllable_1 & 0x0F
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
		a9 = (syllable_1 >> 4) & 0x01
		a8_1 = (syllable_1 >> 5) & 0xFF 
		print("%03o %o %02o   " % (a8_1, a9, op), end="")
		instruction = instructions[op]
		address = ((syllable >> 6) & 0xFF) | ((syllable << 3) & 0x100)
		print("%s %03o" % (instruction, address))

