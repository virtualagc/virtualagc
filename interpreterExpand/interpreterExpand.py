#!/usr/bin/python3
# By Ronald S. Burkey <info@sandroid.org>, placed in the Public Domain.
# 
# Filename: 	interpreterExpand.py
# Purpose:	The idea behind this program is that it's difficult to compare
#		two fragements of AGC interpreter code to determine if they
#		have identical functionality, because different ways of packing
#		the instructions (which are stored 2 to word of memory) can 
#		make functionally-identical code appear to be very different.
#		This script attempts to unpack such packed interpreter code 
#		into its least-packed form, in which there is no packing at all.
#		Moreover, certain instructions (like STCALL) provide additional
#		packing, and that packing is undone as well. 
# Mod history:	2021-01-03 RSB	Began
#
# Usage:
#	interpreterExpand.py <PackedInterpreterCode.agc >UnpackedIntepreterCode.agc
#
# Formatting of input lines
# -------------------------
# This program applies a simplified notion of interpreter line formatting.
# Tabs are automatically expanded to assumed 8-column tab stops.  All comments are 
# removed.  Labels begin in column 1, and are limited to 8 characters. Interpreter 
# instructions must begin in columns 13-20 (though by convention always begin in 
# column 17 in actual AGC code).  If an instruction is present, operands or the 2nd 
# instruction on a line are recognized as anything following the 1st instruction by
# at least one space.  If no instruction is present, an operand is anything beginning
# in column 21 or thereafter.
#
# Certain pseudo-ops (like 2DEC, 2OCT, etc.) are also recognized.
#
# Any input line not recognized as an interpreter line (including any "Basic" 
# instruction) is simply reproduced, with rationalized formatting.
#
# Output lines always use space (no tabs), and labels, 1st instruction, and the 
# 2nd instruction or operand always begin at columns 1, 17, 25, respectively.

import sys

# Each key is the name of the instruction; the value is the number of operands it expects.
interpreterOperators = {
	"ABS" : 0, "ABVAL" : 0, "ACOS" : 0, "ASIN" : 0, "AXC" : 1, "AXT" : 1,
	"BDDV" : 1, "BDSU" : 1, "BHIZ" : 1, "BMN" : 1, "BOF" : 2, "BOFCLR" : 2,
	"BOFINV" : 2, "BOFSET" : 2, "BON" : 2, "BONCLR" : 2, "BONINV" : 2, 
	"BONSET" : 2, "BOV" : 1, "BOVB" : 1, "BPL" : 1, "BVSU" : 1, "BZE" : 1,
	"CALL" : 1, "CCALL" : 2, "CGOTO" : 2, "CLEAR" : 1, "CLRGO" : 2, "COS" : 0,
	"DAD" : 1, "DCOMP" : 0, "DDV" : 1, "DLOAD" : 1, "DMP" : 1, "DMPR" : 1,
	"DOT" : 1, "DSQ" : 0, "DSU" : 1, "EXIT" : 0, "GOTO" : 1, "INCR" : 1,
	"INVERT" : 1, "INVGO" : 2, "LXC" : 1, "LXA" : 1, "MXV" : 1, "NORM" : 1,
	"PDDL" : 1, "PDVL" : 1, "PUSH" : 0, "ROUND" : 0, "RTB" : 1, "RVQ" : 0,
	"SET" : 1, "SETGO" : 2, "SETPD" : 1, "SIGN" : 1, "SIN" : 0, "SL" : 1,
	"SL1" : 0, "SL2" : 0, "SL3" : 0, "SL4" : 0, "SL1R" : 0, "SL2R" : 0,
	"SL3R" : 0, "SL4R" : 0, "SLOAD" : 1, "SLR" : 1, "SQRT" : 0,
	"SR" : 1, "SR1" : 0, "SR2" : 0, "SR3" : 0, "SR4" : 0,
	"SR1R" : 0, "SR2R" : 0, "SR3R" : 0, "SR4R" : 0, "SRR" : 1, "SSP" : 1,
	"STCALL" : 2, "STODL" : 2, "STORE" : 1, "STOVL" : 2, "STQ" : 1, "SXA" : 1,
	"TAD" : 1, "TIX" : 1, "TLOAD" : 1, "UNIT" : 0, "VAD" : 1, "VCOMP" : 0,
	"VDEF" : 0, "VDSC" : 1, "VLOAD" : 1, "VPROJ" : 1, "VSL" : 1, 
	"VSL1" : 0, "VSL2" : 0, "VSL3" : 0, "VSL4" : 0, "VSL5" : 0, "VSL6" : 0,
	"VSL7" : 0, "VSL8" : 0, "VSQ" : 0, "VSR" : 1, "VSR1" : 0, "VSR2" : 0,
	"VSR3" : 0, "VSR4" : 0, "VSR5" : 0, "VSR6" : 0, "VSR7" : 0, "VSR8" : 0,
	"VSU" : 1, "VXM" : 1, "VXSC" : 1, "VXV" : 1, "XAD" : 1, "XCHX" : 1,
	"XSU" : 1
}

# Returns the value from interpreterOperators[], or else -1 if not in interpreterOperators[].
# Prior to the test, it checks the operator variable to see if it has a trailing ",1" or ",2"
# and removes it if so.  Also, removes trailing "*".
def isInterpreterOperator(operator):
	if operator[-2:] in [ ",1", ",2" ]:
		operator = operator[:-2]
	if operator[-1] == "*":
		operator = operator[:-1]
	if operator not in interpreterOperators:
		return -1
	return interpreterOperators[operator]

label = ""
offsetLabel = ""
operators = []
operands = []

def collapse():
	global label, offsetLabel, operators, operands
	operandIndex = 0
	pseudoLabel = ""
	if label != "":
		pseudoLabel = label
	elif offsetLabel != "":
		pseudoLabel = offsetLabel
	for operator in operators:
		# Take care of weird operators first.
		if operator == "STORE":
			print("%-16s%-8s%s" % (pseudoLabel, "STORE", operands[0]))
			pseudoLabel = ""
			operands = operands[1:]
			continue
		if operator == "SR1":
			print("%-16s%s" % (pseudoLabel, "SR"))
			print("%24s%s" % ("", "1"))
			pseudoLabel = ""
			continue
		# Normal operators.
		numOperands = isInterpreterOperator(operator)
		print("%-16s%s" % (pseudoLabel, operator))
		pseudoLabel = ""
		if numOperands > 0:
			for n in range(numOperands):
				if len(operands) > 0:
					print("%24s%s" % ("", operands[0]))
					operands = operands[1:]
	operators = []
	operands = []
	label = newLabel
	offsetLabel = newOffsetLabel

def pushInstruction(operator):
	global operators
	if operator == "CLRGO":
		operators.append("CLEAR")
		operators.append("GOTO")
	elif operator == "INVGO":
		operators.append("INVERT")
		operators.append("GOTO")
	elif operator == "PDDL":
		operators.append("PUSH")
		operators.append("DLOAD")
	elif operator == "PDVL":
		operators.append("PUSH")
		operators.append("VLOAD")	
	elif operator == "SETGO":
		operators.append("SET")
		operators.append("GOTO")
	# Note that there are potential unpackings which aren't handled here, 
	# such as SL3 -> SL / 3.  I don't have any good way to handle that
	# if SLn (or similar) is the 2nd instruction on a line, because
	# it's always possible that the 1st instruction on the line is 
	# receiving its operand on the stack.  Handling SLn similarly to
	# what's shown above would fool the system into swapping the 
	# operands for the 1st and 2nd instructions.  However, instructions
	# like SLn can be handled by collapse() with problem.
	else:
		operators.append(operator)

for line in sys.stdin:
	eline = line.strip('\n').upper().split('#')[0].expandtabs()
	if eline == "":
		continue
	fields = eline.split()
	fieldIndex = 0
	firstField = ""
	secondField = ""
	newLabel = ""
	newOffsetLabel = ""
	if eline[0] != ' ' and fieldIndex < len(fields):
		newLabel = fields[fieldIndex]
		fieldIndex += 1
	elif eline[:12] != "            " and fieldIndex < len(fields):
		newOffsetLabel = ' ' + fields[fieldIndex]
		fieldIndex += 1
	if eline[12:20] != "        " and fieldIndex < len(fields):
		firstField = fields[fieldIndex]
		fieldIndex += 1
	while fieldIndex < len(fields):
		secondField += ' ' + fields[fieldIndex]
		fieldIndex += 1
	secondField = secondField[1:]
	
	if firstField != "":
		# If there are any pending interpreter operators and operands waiting
		# to be printed, then do so.
		collapse()
		# Just a regular Basic line.
		if isInterpreterOperator(firstField) == -1:
			pseudoLabel = ""
			if newLabel != "":
				pseudoLabel = newLabel
			elif newOffsetLabel != "":
				pseudoLabel = newOffsetLabel
			print("%-16s%-8s%s" % (pseudoLabel, firstField, secondField))
			continue
	
	# To get here, we definitely have an interpretive line.
	
	# First take care of some operators that are troublesome due to using up
	# the entire line without allowing for additional instructions on the line.		
	if firstField == "STORE":
		operators.append("STORE")
		operands.append(secondField)
		continue
	if firstField == "STCALL":
		operators.append("STORE")
		operators.append("CALL")
		operands.append(secondField)
		continue
	if firstField == "STODL":
		operators.append("STORE")
		operators.append("DLOAD")
		operands.append(secondField)
		continue
	if firstField == "STOVL":
		operators.append("STORE")
		operators.append("VLOAD")
		operands.append(secondField)
		continue
	
	# We now just have 3 cases:  The line is just an operand, the line is 
	# just an instruction (though not the 4 listed above), or the line is
	# 2 instructions (not the 4 listed above).  However, some of the instructions
	# (like CLRGO) act like 2 instructions in 1, and therefore still have 
	# to be unpacked.
	if firstField == "":
		operands.append(secondField)
		continue 
	pushInstruction(firstField)
	if secondField != "":
		pushInstruction(secondField)	

# End of file reached.  If there are still any pending interpreter operators / operands,
# print them out.
collapse()

	