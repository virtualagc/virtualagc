#!/usr/bin/python3
# Copyright 2019 Ronald S. Burkey <info@sandroid.org>
#
# This file is part of yaAGC. 
#
# yaAGC is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
# yaAGC is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with yaAGC; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
#
# Filename:    	yaASM.py
# Purpose:     	An LVDC assembler, intended to replace yaASM.c for LVDC
#              	(but not for OBC) assemblies.  It's actually just something
#              	I'm playing around with to see if I can get something a
#              	little cleaner and thus easier for me to maintain than yaASM.c, 
#              	so I shouldn't really say I _intend_ it as a replacement.
# Reference:   	http://www.ibibio.org/apollo
# Mods:        	2019-07-10 RSB  Began playing around with the concept.
#		2019-08-14 RSB	Began working on this more seriously since
#				the LVDC-206RAM transcription is now available.
#				Specifically, began adding preprocessor pass.
#		2019-08-22 RSB	I think the preprocessor and discovery passes
#				are essentially working, except for auto-allocation
#				of =... constants.
#
# The usage is just
#              yaASM.py <INPUT.lvdc >OUTPUT.listing
# If the assembly is successful, an executable file for the assembler is 
# output, called lvdc.bin.

import sys
# The next line imports expression.py.
import expression

#----------------------------------------------------------------------------
#	Definitions of global variables.
#----------------------------------------------------------------------------
# Array for keeping track of which memory locations have been used already.
used = [[[[False for offset in range(256)] for syllable in range(2)] for sector in range(16)] for module in range(8)]
	
operators = {
    "HOP": { "opcode":0b0000 }, 
    "MPY": { "opcode":0b0001 }, 
    "SUB": { "opcode":0b0010 }, 
    "DIV": { "opcode":0b0011 }, 
    "TNZ": { "opcode":0b0100 }, 
    "MPH": { "opcode":0b0101 }, 
    "AND": { "opcode":0b0110 }, 
    "ADD": { "opcode":0b0111 },
    "TRA": { "opcode":0b1000 }, 
    "XOR": { "opcode":0b1001 }, 
    "PIO": { "opcode":0b1010 }, 
    "STO": { "opcode":0b1011 }, 
    "TMI": { "opcode":0b1100 }, 
    "RSU": { "opcode":0b1101 }, 
    "CDS": { "opcode":0b1110, "a9":0 }, 
    "CDSD": { "opcode":0b1110, "a9":0 }, 
    "CDSS": { "opcode":0b1110, "a9":0 }, 
    "SHF": { "opcode":0b1110, "a9":1, "a8":0 }, 
    "EXM": { "opcode":0b0000, "a9":1, "a8":0 },
    "CLA": { "opcode":0b1111 }, 
    "SHR": { "opcode":0b1110, "a9":1, "a8":0 }, 
    "SHL": { "opcode":0b1110, "a9":1, "a8":0 }
}
pseudos = []
preprocessed = ["EQU", "IF", "ENDIF", "MACRO", "ENDMAC"]

expandedLines = []
errors = []
constants = {}
macros = {}
inMacro = ""
inFalseIf = False

inputFile = []
IM = 0
IS = 0
S = 1
LOC = 0
DM = 0
DS = 0
dS = 0
DLOC = 0
useDat = False
lineNumber = 0
forms = {}
synonyms = {}
nameless = {}
roofs = {}
lastORG = False
inDataMemory = True

symbols = {}
lastLineNumber = -1

# Array for keeping track of assembled octals
octals = [[[[None for offset in range(256)] for syllable in range(3)] for sector in range(16)] for module in range(8)]

lines = sys.stdin.readlines()
for n in range(0,len(lines)):
	lines[n] = lines[n].rstrip()

#----------------------------------------------------------------------------
#	Definitions of utility functions
#----------------------------------------------------------------------------
def addError(n, msg):
	global errors
	if msg not in errors[n]:
		errors[n].append(msg) 

def incDLOC(increment = 1):
	global DLOC
	global errors
	while increment > 0:
		increment -= 1
		if DLOC < 256:
			used[DM][DS][0][DLOC] = True
			used[DM][DS][1][DLOC] = True
		DLOC += 1

# This function checks to see if a block of the desired size is 
# available at the currently selected DM/DS/DLOC, and if not,
# increments DLOC until it finds the space.
def checkDLOC(increment = 1):
	global DLOC
	global errors
	start = DLOC
	n = start
	length = 0
	reuse = False
	while n < 256 and length < increment:
		if used[DM][DS][0][n] or used[DM][DS][1][n]:
			n += 1
			length = 0
			reuse = True
			continue
		if length == 0:
			start = n
		n += 1
		length += 1
	if reuse:
		addError(lineNumber, "Warning: Skipping memory locations already used")
	if length < increment:
		addError(lineNumber, "Error: No space of size " + str(increment) + " found in memory bank")
	DLOC = start

def incLOC():
	global LOC
	global DLOC
	global dS
	global used
	if useDat:
		if DLOC < 256:
			used[DM][DS][dS][DLOC] = True
		dS = 1 - dS
		if dS == 1:
			DLOC += 1
	else:
		if LOC < 256:
			used[IM][IS][S][LOC] = True
		LOC += 1

# Find out the last usable instruction location in a sector.
def getRoof(imod, isec, syl, extra):
	roofKey = (imod << 4) | isec
	if syl == 0:
		roof = 0o377
	elif roofKey not in roofs:
		roof = 0o374
	else:
		roof = roofs[roofKey]
	if extra > 0:
		extra -= 1
	return roof - extra

# Convert a numeric literal to LVDC binary format.  I accept literals of the forms:
#	if isOctal == False:
#		O + octal digits
#		float + optional Bn
#		decimal + Bn + optional En
#	if isOctal == True:
#		octal digits
# Returns a string of 9 octal digits, or else "" if error.
def convertNumericLiteral(n, isOctal = False):
	if isOctal or n[:1] == "O":
		if isOctal:
			constantString = n[0:]
		else:
			constantString = n[1:]
		if len(constantString) > 9 or len(constantString) == 0:
			return ""
		for c in constantString:
			if c not in ["0", "1", "2", "3", "4", "5", "6", "7"]:
				return ""
		while len(constantString) < 9:
			constantString += "0"
		return constantString
	# The decimal-number case.
	# The following manipulations try to produce two strings called
	# "decimal" (which includes the decimal portion of the number, 
	# including sign, decimal point, and En exponent) and "scale"
	# (which is just the Bn portion).  The trick is that the En may
	# follow the Bn in the original operand.
	decimal = n[0:]
	scale = "B26"
	if "B" in decimal:
		whereB = decimal.index("B")
		scale = decimal[whereB:]
		decimal = decimal[:whereB]
		if "E" in scale:
			whereE = scale.index("E")
			decimal += scale[whereE:]
			scale = scale[:whereE]
	try:
		decimal = float(decimal)
		scale = int(scale[1:])
		value = round(decimal * pow(2, 27 - scale - 1))
		if value < 0:
			value += 0o1000000000
		constantString = "%09o" % value
		return constantString
	except:
		return ""	

# Allocate/store a nameless variable for "=..." constant, returning its offset
# into the sector, and a residual (0 if in sector specified or 1 if in residual
# sector).
def allocateNameless(lineNumber, constantString, useResidual = True):
	global nameless
	value = "%o_%02o_%s" % (DM, DS, constantString)
	if value in nameless:
		return nameless[value],0
	if useResidual and DS != 0o17:
		valueR = "%o_17_%s" % (DM, constantString)
		if valueR in nameless:
			return nameless[valueR],1
	for loc in range(0, 256):
		if not used[DM][DS][0][loc] and not used[DM][DS][1][loc]:
			used[DM][DS][0][loc] = True
			used[DM][DS][1][loc] = True
			nameless[value] = loc
			return loc,0
	if useResidual and DS != 0o17:
		for loc in range(0, 256):
			if not used[DM][0o17][0][loc] and not used[DM][0o17][1][loc]:
				used[DM][0o17][0][loc] = True
				used[DM][0o17][1][loc] = True
				nameless[valueR] = loc
				return loc,1
	addError(lineNumber, "Error: No remaining memory to store nameless constant (" + value + ")")
	return 0,0

# This function finds the next location available for storing instructions.
# If we determine that an automatic switch to a different memory sector is
# needed, we return an array [oldIM,oldIS,oldS,oldLOC,newIM,newIS,newS,newLOC]
# containing enough info to create a TRA or HOP instruction to the starting
# location in the new sector. Hopefully the calling routine can figure out 
# something sensible to do with the returned array.
def checkLOC(extra = 0):
	global LOC
	global IM
	global IS
	global S
	global DLOC
	global errors
	if useDat:
		# This is the "USE DAT" case. 
		if DLOC >= 256:
		 	addError(lineNumber, "Error: No room left in memory sector")
		elif dS == 1 and (used[DM][DS][0][DLOC] or used[DM][DS][1][DLOC]):
			tLoc = DLOC
			addError(lineNumber, "Warning: Automatically skipping already-used memory location")
			while tLoc < 256 and dS == 1 and (used[DM][DS][0][tLoc] or used[DM][DS][1][tLoc]):
				tLoc += 1
			if tLoc >= 256:
				addError(lineNumber, "Error: No room left in memory sector")
			else:
				DLOC = tLoc
				return []
		return []
	else:
		# This is the "USE INST" case.
		autoSwitch = False
		if not lastORG and (LOC >= 256 or used[IM][IS][S][LOC]):
			# If the current location is already used up, we're out
			# of luck since there's no room to even insert a TRA or HOP.
			addError(lineNumber, "Error: No memory available at current location")
			return []
		roof = getRoof(IM, IS, S, extra)
		if LOC >= roof or used[IM][IS][S][LOC + 1]:
			# Only one word available here, just insert TRA or HOP.  However, we need
			# to find address for the TRA or HOP to take us to, always searching
			# upward.
			if lastORG:
				addError(lineNumber, "Warning: Skipping past already-used memory")
			else:
				used[IM][IS][S][LOC] = True
				autoSwitch = True
			tLoc = LOC
			tSyl = S
			tSec = IS
			tMod = IM
			while True:
				roof = getRoof(tMod, tSec, tSyl, extra)
				if tLoc < roof and not used[tMod][tSec][tSyl][tLoc] and not used[tMod][tSec][tSyl][tLoc + 1]:
					if autoSwitch:
						retVal = [IM, IS, S, LOC, tMod, tSec, tSyl, tLoc]
					else:
						retVal = []
					IM = tMod
					IS = tSec
					S = tSyl
					LOC = tLoc
					return retVal
				tLoc += 1
				if tLoc >= roof:
					tLoc = 0
					tSyl += 1
					if tSyl >= 2:
						tSyl = 0
						tSec += 1
						if tSec >= 16:
							tSec = 0
							tMod += 1
							if tMod >= 8:
								addError(lineNumber, "Error: Memory totally exhausted")
								return []
		# At this point, we know there are two consecutive words available at the 
		# current location, so we can just keep the current address.
		return []


# Put the assembled value wherever it's supposed to go in the executable image.
def storeAssembled(value, hop, data = True):
	global octals, octalsUsed
	if data:
		module = hop["DM"]
		sector = hop["DS"]
		location = hop["DLOC"]
		octals[module][sector][2][location] = value
	else:
		module = hop["IM"]
		sector = hop["IS"]
		syllable = hop["S"]
		location = hop["LOC"]
		octals[module][sector][syllable][location] = (value << 2) & 0o77774

# Form a HOP constant from a hop dictionary.
def formConstantHOP(hop):
	hopConstant = 0
	hopConstant |= (hop["IM"] & 1) << 25
	hopConstant |= 1 << 24
	hopConstant |= hop["DS"] << 20
	hopConstant |= hop["DM"] << 17
	hopConstant |= 1 << 16
	hopConstant |= hop["LOC"] << 7
	hopConstant |= hop["S"] << 6
	hopConstant |= hop["IS"] << 2
	hopConstant |= (hop["IM"] & 6) >> 1
	return hopConstant << 1

#----------------------------------------------------------------------------
#	Preprocessor pass
#----------------------------------------------------------------------------
# The idea for this pass is to process:
#	EQU
#	Expansion of CALL
#	Macro definitions
#	Usage of EQU-defined constants in assembly-language operands
#	Expansion of macros
#	Conditionally-assembled code.
# The array expandedLines[] will end up being exactly the same length as lines[],
# and the entries will correspond 1-to-1 to it, but the entries will be arrays of
# replacement lines.  In other words, suppose line=lines[n].  If the preprocessor
# doesn't need to change the line, then expandedLines[n] will be [line].  Suppose
# the proprocessor needs to change line to (say) newLine.  Then expandedLines[n]
# will be [newLine].  Or suppose line contains a macro that the preprocessor 
# expands to line1, line2, and line3.  Then expandedLines[n] will be [line1,line2,line3].
# The errors[] array is also in a similar 1-to-1 relationship, and errors[n] contains 
# an array (hopefully usually empty) of error/warning messages for lines[n].
for n in range(0, len(lines)):
	line = lines[n]
	errors.append([])
	expandedLines.append([line])
	
	if line[:1] in ["*", "#"]:
		continue
	
	# Split the line into fields.
	if line[:1] in [" ", "\t"] and not line.isspace():
		line = "@" + line
	fields = line.split()
	if len(fields) > 0 and fields[0] == "@":
		fields[0] = ""
		line = line[1:]

	# Most expansions of (EXPRESSION) are handled later, and I don't want to
	# override that here, but there is one case that the later code can't
	# handle very efficiently, in which the operand of an instruction or a 
	# macro argument is of the form
	#	LHS+(EXPRESSION)
	# or
	#	LHS-(EXPRESSION)
	# So I handle that case here.  Also, there are some pseudo-ops (TABLE)
	# whose entire operand can be an (EXPRESSION)
	if len(fields) >= 3:
		fields2 = fields[2]
		while "+(" in fields2 or "-(" in fields2:
			index = fields2.find("+(")
			if index < 0:
				index = fields2.find("-(")
			if index < 0:
				break;
			index += 1
			index2 = fields2.find(")", index)
			if index2 < 0:
				addError(n, "Error: No end parenthesis in expression")
				break
			index2 += 1
			value,error = expression.yaEvaluate(fields2[index:index2], constants)
			if error != "":
				addError(n, error)
				break
			fields2 = fields2[:index] + str(value["number"]) + fields2[index2:]
		if fields2 != fields[2]:
			expandedLines[n] = [line.replace(fields[2], fields2)]
			fields[2] = fields2
	if len(fields) >= 3 and fields[1] in ["TABLE", "DEC"] and fields[2][:1] == "(":
		value,error = expression.yaEvaluate(fields2, constants)
		if error != "":
			addError(n, error)
			break
		if fields[1] == "TABLE":
			fields2 = str(value["number"])
		else:
			fields2 = str(value["number"])
			if "scale" in value:
				fields2 += "B" + str(value["scale"])
		expandedLines[n] = [line.replace(fields[2], fields2)]
		fields[2] = fields2

	if inMacro != "":
		if len(fields) >= 2 and fields[1] == "ENDMAC":
			if len(macros[inMacro]["lines"]) == 1:
				# In the cosmic scheme of things, there's no reason
				# why a macro can't have a single line in it, but
				# we don't allow it just because it would complicate
				# our processing.
				addError(n, "Error: Macro has a single line")
			inMacro = ""
		else:
			macros[inMacro]["lines"].append(fields)
		expandedLines[-1] = []
	elif len(fields) >= 3 and fields[0] != "" and fields[1] == "EQU":
		value,error = expression.yaEvaluate(fields[2], constants)
		if error != "":
			addError(n, "Error: " + error)
		else:
			constants[fields[0]] = value 
	elif len(fields) >= 3 and fields[1] == "CALL":
		ofields = fields[2].split(",")
		if len(ofields) == 2:
			line1 = "%-8s%-8s%s" % (fields[0], "CLA", ofields[1])
			line2 = "%-8s%-8s%s" % ("", "HOP", ofields[0])
			expandedLines[n] = [line1, line2]
		elif len(ofields) == 3:
			line1 = "%-8s%-8s%s" % (fields[0], "CLA", ofields[2])
			line2 = "%-8s%-8s%s" % ("", "STO", "775")
			line3 = "%-8s%-8s%s" % ("", "CLA", ofields[1])
			line4 = "%-8s%-8s%s" % ("", "HOP", ofields[0])
			expandedLines[n] = [line1, line2, line3, line4]
	elif len(fields) >= 2 and fields[0] != "" and fields[1] == "MACRO":
		inMacro = fields[0]
		if len(fields) == 2:
			numArgs = 0
		else:
			numArgs = len(fields[2].split(","))
		macros[inMacro] = { "numArgs": numArgs, "lines": [] }
	elif len(fields) >= 2 and fields[1] in macros:
		macro = macros[fields[1]]
		if len(fields) >= 3:
			ofields = fields[2].split(",")
		else:
			ofields = []
		numArgs = len(ofields)
		if macro["numArgs"] != 0 and numArgs != macro["numArgs"]:
			addError(n, "Error: " + "Wrong number of macro arguments")
		else:
			macroLines = macro["lines"]
			expandedLines[n] = []
			for m in range(0,len(macroLines)):
				macroLine = macroLines[m]
				lhs = ""
				operator = macroLine[1]
				operand = macroLine[2]
				argNum = 0
				if operand[:3] == "ARG" and operand[3:].isdigit():
					argNum = int(operand[3:])
				if argNum > 0 and argNum <= numArgs:
					operand = ofields[argNum - 1]
				if operand[:2] == "=(":
					value,error = expression.yaEvaluate(operand[1:], constants)
					if error != "":
						addError(n, "Error: " + error)
						continue
					operand = "=" + str(value["number"])
					if "scale" in value:
						operand +=  "B" + str(value["scale"])
				if m == 0:
					lhs = fields[0]
				expandedLines[n].append("%-8s%-8s%s" % (lhs, operator, operand))
	elif len(fields) >= 3 and fields[2][:2] == "=(":
		value,error = expression.yaEvaluate(fields[2][1:], constants)
		if error != "":
			addError(n, "Error: " + error)
		else:
			replacement = "=" + str(value["number"])
			if "scale" in value:
				replacement += "B" + str(value["scale"])
			expandedLines[n] = [line.replace(fields[2], replacement)]
	elif inFalseIf:
		if len(fields) >= 2 and fields[1] == "ENDIF":
			inFalseIf = False
		else:
			expandedLines[n] = []
	elif len(fields) >= 3 and fields[1] == "IF":
		# I'm not sure what the syntax is here, but all the ones I've seen
		# have an operand of the form
		#	CONSTANTSYMBOL=(EXPRESSION)
		# where CONSTANTSYMBOL is a symbol defined by an EQU, so I'm
		# going with that.  In terms of the checking for equality,
		# I require both the numeric value and the scale to be identical,
		# though the way I've seen these things formed so far they're just
		# logical expressions with scales of B0 anyway.
		ofields = fields[2].split("=")
		if len(ofields) != 2 or ofields[0] not in constants or ofields[1][:1] != "(":
			addError(n, "Error: Misformed IF")
			continue
		value,error = expression.yaEvaluate(ofields[1], constants)
		if error != "":
			addError(n, "Error: " + error)
			continue
		constant = constants[ofields[0]]
		if constant["number"] != value["number"] or ("scale" in value and constant["scale"] != value["scale"]):
			inFalseIf = True

if False:
	# Just print out some results from the preprocessor and then exit.
	print("Constants:")		
	for n in sorted(constants):
		print("\t" + n + "\t= " + str(constants[n]["number"]) + "B" + str(constants[n]["scale"]))
	print("Macros:")
	for n in sorted(macros):
		print("\t" + n + "\t= " + str(macros[n]))
	print("Expansion:")
	for n in range(0, len(expandedLines)):
		if len(expandedLines[n]) != 1 or lines[n] != expandedLines[n][0]:
			print("\t" + str(n + 1) + ": " + str(expandedLines[n]))
	sys.exit(1)

#----------------------------------------------------------------------------
#     	Discovery pass (creation of symbol table)
#----------------------------------------------------------------------------
# The object of this pass is to discover all addresses for left-hand symbols,
# or in other words, to assign an address (HOP constant) to each line of code.
# As far as I know right now, it looks like we can do this in a single pass.   
# The result of the pass is a hopefully easy-to-understand dictionary called 
# inputFile. It also buffers the lhs, operator, and operand fields, so they 
# don't have to be parsed out again on the next pass.

# For this pass, we can just loop through all of the lines of code by having an 
# outer loop on all of the elements of expandedLines[], and an inner loop on all 
# of the elements of expandedLines[n][].

for lineNumber in range(0, len(expandedLines)):
	for line in expandedLines[lineNumber]:
		inDataMemory = True
		inputLine = { "raw": line }
		    
		# Split the line into fields.
		if line[:1] in [" ", "\t"] and not line.isspace():
			line = "@" + line
		fields = line.split()
		if len(fields) > 0 and fields[0] == "@":
			fields[0] = ""
		    
		# Remove comments.
		if inputLine["raw"][:1] in ["*", "#"]:
			if len(fields) == 5 and fields[0] == "#!" and fields[1] == "ROOF":
				roofKey = (int(fields[2], 8) << 4) | int(fields[3], 8)
				roofs[roofKey] = int(fields[4], 8)
			fields = []
		
		if len(fields) >= 2 and fields[1] == "VEC":
			while DLOC < 256:
				DLOC = (DLOC + 3) & ~3
				checkDLOC()
				if (DLOC & 3) == 0:
					break
		elif len(fields) >= 2 and fields[1] == "MAT":
			while DLOC < 256:
				DLOC = (DLOC + 15) & ~15
				checkDLOC()
				if (DLOC & 15) == 0:
					break
		elif len(fields) >= 2 and fields[1] == "MACRO" and fields[0] in macros and macros[fields[0]]["numArgs"] == 0:
			pass
		elif len(fields) >= 2 and fields[1] in macros and macros[fields[1]]["numArgs"] == 0:
			pass
		elif len(fields) >= 2 and fields[1] in ["ENDIF", "END"]:
			pass
		elif len(fields) >= 3:
			ofields = fields[2].split(",")
			if fields[1] == "USE":
				if fields[2] == "INST":
					useDat = False
				elif fields[2] == "DAT":
					dS = 1
					useDat = True
				else:
					addError(lineNumber, "Error: Wrong operand for USE")
			elif fields[1] == "TABLE":
				checkDLOC(int(fields[2]))
			elif fields[0] != "" and fields[1] == "SYN":
				synonyms[fields[0]] = fields[2]
			elif fields[0] != "" and fields[1] == "FORM":
				if fields[0] in forms:
					addError(n, "Warning: Form already defined")
				forms[fields[0]] = ofields
			elif fields[1] == "ORGDD":
				lastORG = True
				if len(ofields) != 7:
					addError(lineNumber, "Error: Wrong number of ORGDD arguments")
				else:
					IM = int(ofields[0], 8)
					IS = int(ofields[1], 8)
					S = int(ofields[2], 8)
					LOC = int(ofields[3], 8)
					DM = int(ofields[4], 8)
					DS = int(ofields[5], 8)
					if ofields[6] != "":
						DLOC = int(ofields[6], 8)
					else:
						DLOC = 0
			elif fields[1] == "DOGD":
				if len(ofields) != 3:
					addError(lineNumber, "Error: Wrong number of DOGD arguments")
				else:
					DM = int(ofields[0], 8)
					DS = int(ofields[1], 8)
					if ofields[2] != "":
						DLOC = int(ofields[2], 8)
					else:
						DLOC = 0
			elif fields[1] in ["DEQS", "DEQD"]:
				if len(ofields) != 3:
					addError(lineNumber, "Error: Wrong number of DEQS or DEQD arguments")
				else:
					if fields[0] != "":
						inputLine["lhs"] = fields[0]
					inputLine["operator"] = fields[1]
					inputLine["operand"] = fields[2]
					inputLine["hop"] = {	"IM":IM, "IS":IS, "S":S, 
								"LOC":LOC, "DM":int(ofields[0], 8), 
								"DS":int(ofields[1], 8), "DLOC":int(ofields[2], 8)}
			elif fields[1] == "BSS":
				checkDLOC(int(fields[2]))
				if fields[0] != "":
					inputLine["lhs"] = fields[0]
				inputLine["operator"] = fields[1]
				inputLine["operand"] = fields[2]
				inputLine["hop"] = {"IM":DM, "IS":DS, "S":0, "LOC":DLOC, "DM":DM, "DS":DS, "DLOC":DLOC}
				incDLOC(int(fields[2]))
			elif fields[1] in ["DEC", "OCT", "HPC", "HPCDD", "DFW"] or fields[1] in forms:
				checkDLOC()
				if fields[0] != "":
					inputLine["lhs"] = fields[0]
				inputLine["operator"] = fields[1]
				inputLine["operand"] = fields[2]
				inputLine["hop"] = {"IM":DM, "IS":DS, "S":0, "LOC":DLOC, "DM":DM, "DS":DS, "DLOC":DLOC}
				incDLOC()	
			elif fields[1] in operators:
				inDataMemory = False
				extra = 0
				if fields[2][:2] == "*+" and fields[2][2:].isdigit():
					extra = int(fields[2][2:])
				oldLocation = checkLOC(extra)
				if oldLocation != []:
					inputLine["switchSectorAt"] = oldLocation
				lastORG = False
				if fields[0] != "":
					inputLine["lhs"] = fields[0]
				inputLine["operator"] = fields[1]
				inputLine["operand"] = fields[2]
				if useDat:
					inputLine["hop"] = {"IM":DM, "IS":DS, "S":dS, "LOC":DLOC, "DM":DM, "DS":DS, "DLOC":DLOC}
					inputLine["useDat"] = True
				else:
					inputLine["hop"] = {"IM":IM, "IS":IS, "S":S, "LOC":LOC, "DM":DM, "DS":DS, "DLOC":DLOC}
				if fields[1] in ["SHL", "SHR"]:
					count = int(fields[2])
					if count == 0:
						count = 1
					else:
						count = (count + 1) // 2
					while count > 0:
						oldLocation = checkLOC()
						if oldLocation != []:
							inputLine["switchSectorAt"] = oldLocation
						incLOC()
						count -= 1
				else:
					incLOC()
				if fields[1] in ["CDS", "CDSD", "CDSS"]:
					if len(ofields) == 1:
						if not useDat:
							# We assume this is the name of a variable, and we have to
							# find it to determine its DM/DS.  I presume it could be
							# defined later, and so we don't find it ... let's hope not!
							found = False
							for testEntry in inputFile:
								testLine = testEntry["expandedLine"]
								if "lhs" in testLine and testLine["lhs"] == fields[2] and "hop" in testLine:
									if fields[1] == "CDSD":
										DM = testLine["hop"]["DM"]
										DS = testLine["hop"]["DS"]
									elif fields[1] == "CDS":
										DM = testLine["hop"]["IM"]
										DS = testLine["hop"]["IS"]
									found = True
									break
							if not found:
								addError(lineNumber, "Warning: Symbol not found")
					elif len(ofields) != 2:
						addError(lineNumber, "Error: Wrong number of CDS/CDSD arguments")
					elif not useDat:
						DM = int(ofields[0], 8)
						DS = int(ofields[1], 8)
			elif fields[1] in preprocessed:
				pass
			elif fields[1] in pseudos:
				pass
			else:
				addError(lineNumber, "Error: Unrecognized operator")
		elif len(fields) != 0:
			addError(lineNumber, "Wrong number of fields")
		inputLine["inDataMemory"] = inDataMemory
		inputFile.append({"lineNumber":lineNumber, "expandedLine":inputLine })

# Create a table to quickly look up addresses of symbols.
for entry in inputFile:
	inputLine = entry["expandedLine"]
	lineNumber = entry["lineNumber"]
	if "lhs" in inputLine:
		if "hop" in inputLine:
			lhs = inputLine["lhs"]
			if lhs in symbols:
				addError(lineNumber, "Error: Symbol already defined")
			symbols[lhs] = inputLine["hop"]
			symbols[lhs]["inDataMemory"] = inputLine["inDataMemory"]
		else:
			addError(lineNumber, "Warning: Symbol location unknown")
if False:
	for key in sorted(symbols):
		symbol = symbols[key]
		print("%-8s  %o %02o %o %03o  %o %02o %03o" % (key, symbol["IM"], 
                symbol["IS"], symbol["S"], symbol["LOC"], symbol["DM"], 
                symbol["DS"], symbol["DLOC"]))

#----------------------------------------------------------------------------
#   	Assembly pass, printout of assembly listing
#----------------------------------------------------------------------------
# At this point we have a dictionary called inputFile in which the entire 
# input source file has been parsed into a relatively simple structure.  The
# addresses of all symbols (constants, variables, code) are known.  One memory
# allocation task the "discovery" pass was NOT able to do was to do automatic
# assignments of nameless variables or targets of code jumps for things like
#   1.  Operands of the form "=something"
#   2.  Operands of HOP*, TRA*.
#   3.  Targets of HOPs transparently added for automatic sector changes.
# Note that the discovery pass should have already taken care of TMI*
# and TNZ*, even though unable to take care of HOP*.  Now, though, we should
# have all of the info need to allocate those during assembly pass,
# and should therefore be able to actually complete the entire assembly and 
# print it out in a single pass.

# For the visual purposes of the assembly listing, it's a bit tricky to try and 
# describe succinctly where the data is coming from, because there are several 
# cases depending on what the preprocessor had done.
#	Case 1: Conditionally-compiled code that is being discarded.  In this case,
#		expandedLines[n][] will be empty because the code is being discarded,
#		so there's actually nothing much to process.
#	Case 2: expandedLines[n][] contains a single element that's identical to lines[n].
#		In this (the usual) case, the preprocessor made no changes, so it's 
#		equivalent to just assembling lines[n] by itself.
#	Case 3:	expandedLines[n][] contains a single element that differs from lines[n].
#		In this case, it's expandedLines[n][0] that needs to be assembled, but
#		lines[n] will serve as the visual model for the assembly listing.  Note
#		that we disallow macros with a single line in them, and that's what allows
#		this conclusion.
#	Case 4:	expandedLines[n][] contains more than one element.  In this case, lines[n]
#		is a macro invocation and does generate something visually in the assembly
#		listing, but is not itself assembled.  Only the lines in expandedLines[n][]
#		actually need to be assembled.
if False:
	for key in sorted(nameless):
		print(key + " " + ("%03o" % nameless[key]))
print("IM IS S LOC DM DS  A8-A1 A9 OP    CONSTANT    SOURCE STATEMENT")
for entry in inputFile:
	lineNumber = entry["lineNumber"]
	inputLine = entry["expandedLine"]
	errorList = errors[lineNumber]
	originalLine = lines[lineNumber]
	constantString = ""
	repeat = 0
	
	# If there's an automatic sector switch here, we have to take care of it prior to
	# doing anything with the instruction that's actually associated with this line.
	if "switchSectorAt" in inputLine:
		print("Info: Automatic syllable/sector/module switch")
		switch = inputLine["switchSectorAt"]
		im0 = switch[0]
		is0 = switch[1]
		s0 = switch[2]
		loc0 = switch[3]
		im1 = switch[4]
		is1 = switch[5]
		s1 = switch[6]
		loc1 = switch[7]
		if IM == im1 and IS == is1:
			# Can use a TRA.
			assembled = (operators["TRA"]["opcode"] | (loc1 << 5) | (is1 << 4)) << 3
			a81 = "%03o" % loc1
			a9 = "%o" % s1
			op = "%02o" % operators["TRA"]["opcode"]
		else:
			# Must use a HOP.
			hopConstant = formConstantHOP(inputLine["hop"])
			constantString = "%09o" % hopConstant
			loc,residual = allocateNameless(lineNumber, constantString, False)
			assembled = (operators["HOP"]["opcode"] | (loc << 5) | (residual << 4)) << 3
			a81 = "%03o" % loc
			a9 = "%o" % residual
			op = "%02o" % operators["HOP"]["opcode"]
		storeAssembled(assembled, {"IM":im0, "IS":is0, "S":s0, "LOC":loc0}, False)
		line = " %o %02o %o %03o  %o %02o  " % (im0, is0, s0, 
							loc0, inputLine["hop"]["DM"], inputLine["hop"]["DS"])
		print(line + " " + a81 + "  " + a9 + "  " + op + "  " + ("%9s" % constantString))
		constantString = ""
	
	operator = ""
	if "operator" in inputLine:
		operator = inputLine["operator"]
	operand = ""
	operandModifierOperation = ""
	operandModifier = 0
	if "operand" in inputLine:
		operand = inputLine["operand"]
		if operand[:1] != "=":
			where = -1
			if "+" in operand:
				where = operand.index("+")
			elif "-" in operand: 
				where = operand.index("-")
			if where > 0:
				operandModifier = operand[where:]
				operand = operand[:where]
				operandModifierOperation = operandModifier[:1]
				operandModifier = operandModifier[1:]
				if len(operandModifier) == 0 or not operandModifier.isdigit():
					addError(lineNumber, "Error: Improper modifer for symbol in operand")
					operandModiferOperation = ""
					operandModifier = 0
				else:
					operandModifier = int(operandModifier)
	
	# Print the address portion of the line.
	if "hop" in inputLine:
		hop = inputLine["hop"]
		DM = hop["DM"]
		DS = hop["DS"]
		DLOC = hop["DLOC"]
		IM = hop["IM"]
		IS = hop["IS"]
		S = hop["S"]
		LOC = hop["LOC"]
		if "useDat" in inputLine:
			line = "      %o %03o  %o %02o  " % (hop["S"], hop["DLOC"], hop["DM"], hop["DS"])
		elif operator in ["DEC", "OCT", "DFW", "BSS", "HPC", "HPCDD"] or operator in forms:
			line = "        %03o  %o %02o  " % (hop["DLOC"], hop["DM"], hop["DS"])
		elif operator in ["CDS", "CDSS", "CDSD", "SHL", "SHR", "SHF"]:
			line = " %o %02o %o %03o        " % (hop["IM"], hop["IS"], hop["S"], hop["LOC"])
		elif operator in ["DEQD", "DEQS"]:
			line = "                   "
		else:
			line = " %o %02o %o %03o  %o %02o  " % (hop["IM"], hop["IS"], hop["S"], 
								hop["LOC"], hop["DM"], hop["DS"])
	else:
		line = "                   "
	
	# Assemble.
	a81 = "   "
	a9 = " "
	op = "  "
	constantString = ""
	inDataMemory = True
	if operator in [ "DEC", "OCT", "HPC", "HPCDD", "DFW" ]:
		if operator == "DEC":
			constantString = convertNumericLiteral(operand)
		elif operator == "OCT":
			constantString = convertNumericLiteral(operand, True)
		elif operator == "HPC":
			ofields = operand.split(",")
			if len(ofields) == 1:
				ofields.append(ofields[0])
			if ofields[0] not in symbols or ofields[1] not in symbols:
				addError(lineNumber, "Error: Symbol(s) not found")
				constantString = "000000000"
			else:
				symbol1 = symbols[ofields[0]]
				symbol2 = symbols[ofields[1]]
				symbol1["DM"] = symbol2["DM"]
				symbol1["DS"] = symbol2["DS"]
				hopConstant = formConstantHOP(symbol1)
				constantString = "%09o" % hopConstant
		elif operator == "HPCDD":
			ofields = operand.split(",")
			if len(ofields) != 6 or not ofields[0].isdigit() or not ofields[1].isdigit() \
				or not ofields[2].isdigit() or not ofields[3].isdigit() \
				or not ofields[4].isdigit() or not ofields[5].isdigit() \
				or int(ofields[0], 8) > 7 or int(ofields[1], 8) > 15 \
				or int(ofields[2], 8) > 1 or int(ofields[3], 8) > 255 \
				or int(ofields[4], 8) > 7 or int(ofields[5], 8) > 15:
				addError(lineNumber, "Error: Illegal operand for HPC")
				im = 0
				isc = 0
				s = 0
				loc = 0
				dm = 0
				ds = 0
			else:
				im = int(ofields[0], 8)
				isc = int(ofields[1], 8)
				s = int(ofields[2], 8)
				loc = int(ofields[3], 8)
				dm = int(ofields[4], 8)
				ds = int(ofields[5], 8)
			hopConstant = formConstantHOP({"IM":im, "IS":isc, "S":s, "LOC":loc, "DM":dm, "DS":ds})
			constantString = "%09o" % hopConstant
		elif operator == "DFW":
			constantString = "000000000"
			ofields = operand.split(",")
			if len(ofields) != 4:
				addError(lineNumber, "Error: Improperly-formed operand for DFW")
			elif ofields[0] not in operators or ofields[2] not in operators:
				addError(lineNumber, "Error: Unknown operator")
			elif ofields[1] not in symbols or ofields[3] not in symbols:
				addError(lineNumber, "Error: Symbol not found")
			else:
				assembled1 = operators[ofields[0]]["opcode"]
				assembled0 = operators[ofields[2]]["opcode"]
				symbol1 = symbols[ofields[1]]
				symbol0 = symbols[ofields[3]]
				residual1 = 0
				residual0 = 0
				if False:
					if symbol1["DS"] == 0o17:
						residual1 = 1
					if symbol0["DS"] == 0o17:
						residual0 = 1
				else:
					residual1 = symbol1["S"]
					residual0 = symbol0["S"]
				assembled1 |= (residual1 << 4) | (symbol1["LOC"] << 5)
				assembled0 |= (residual0 << 4) | (symbol0["LOC"] << 5)
				assembled1 = assembled1 | 0o140
				assembled0 = assembled0 | 0o140
				hopConstant = (assembled1 << 14) | (assembled0 << 1)
				constantString = "%09o" % hopConstant
		else:
			constantString = ""
		if constantString == "":
			addError(lineNumber, "Error: Invalid numeric literal as operand")
		else:
			assembled = int(constantString, 8)
			# Put the assembled value wherever it's supposed to 
			storeAssembled(assembled, inputLine["hop"])
	elif operator in ["HOP", "MPY", "SUB", "DIV", "MPH", "AND", "ADD", "TRA", "TNZ", "TMI", "XOR", "STO", 
				"RSU", "CLA", "CDS", "CDSD", "CDSS", "SHL", "SHR"]:
		inDataMemory = False
		loc = 0
		residual = 0
		if "a9" in operators[operator]:
			residual = operators[operator]["a9"]
		assembled = operators[operator]["opcode"]
		op = "%02o" % assembled
		if len(operand) == 0:
			addError(lineNumber, "Error: Operand is empty")
		elif operand.isdigit():
			if operator in ["SHL", "SHR"]:
				loc = int(operand)
			else:
				loc = int(operand, 8)
				if loc > 0o777:
					addError(lineNumber, "Error: Operand is out of range")
					loc = 0
		if operator in ["SHR", "SHL"]:
			# We set this up with a loc, just like the other types of 
			# instructions, but if the shift count is bigger than 2, there
			# will (eventually) also be automatic repeats.  All the repeats
			# will be the same instruction, except the latter one which could
			# be a different shift amount.
			repeat = loc
			if not operand.isdigit():
				addError(lineNumber, "Error: Illegal operand for SHR/SHL")
				repeat = 0
			if repeat == 0:
				loc = 0
			elif operator == "SHL":
				loc = 0o040
			elif operator == "SHR":
				loc = 0o002
			if (repeat & 1) == 0:
				locFinal = loc
			else:
				locFinal = loc >> 1
			repeat = (repeat + 2) // 2
			if repeat == 1:
				loc = locFinal
		elif operator in ["TRA", "TNZ", "TMI"]:
			if operand == "*":
				loc = LOC
				residual = S
				if operandModifierOperation == "+":
					loc = LOC + operandModifier
				elif operandModifierOperation == "-":
					loc = LOC - operandModifier
				if loc < 0 or loc > 0o377:
					addError(lineNumber, "Error: Target location out of range")
					loc = 0 
				residual = S
			elif operand.isdigit():
				#print("Here: " + str(inputLine))
				pass
			else:
				if operand not in symbols:
					addError(lineNumber, "Error: Target location of TRA not found")
				elif symbols[operand]["IM"] == IM and symbols[operand]["IS"] == IS:
					loc = symbols[operand]["LOC"]
					residual = symbols[operand]["S"]
				elif operator == "TRA":
					# The target location exists, but is not in this IM/IS.
					# We must therefore substituted a HOP instruction instead,
					# and allocate a HOP constant nameless variable.
					hopConstant = formConstantHOP(symbols[operand])
					constantString = "%09o" % hopConstant
					#print("C1: allocateNameless " + constantString + " " + operand)
					loc,residual = allocateNameless(lineNumber, constantString, False)
					#print("C2: %o,%20o,%03o %o" % (DM, DS, loc, residual))
					assembled = operators["HOP"]["opcode"]
					op = "%02o" % assembled
					#addError(lineNumber, "Info: Converting TRA to HOP at %o,%02o,%03o" % (DM, DS, loc))	
				else: 
					# Operator if TNZ or TMI and the target is out of the sector.
					# The technique in this case is to use a word at the top of syllable
					# 1 of the sector to store a HOP instruction that gets us to the 
					# target.
					addError(lineNumber, "Error: Not implemented yet")
					loc = 0o377
					residual = 1
		elif operator == "HOP":
			if operand.isdigit():
				#addError(lineNumber, "Info: Converting HOP to TRA")
				pass
			elif operand not in symbols:
				addError(lineNumber, "Error: Target location of HOP not found")
			else:
				hop = symbols[operand]
				if operandModifierOperation != "":
					addError(lineNumber, "Error: Cannot apply + or - in HOP operand")
				elif "inDataMemory" in hop and hop["inDataMemory"]:
					# The operand is a variable, as it ought to be.
					if hop["DM"] != DM or (hop["DS"] != DS and hop["DS"] != 0o17):
						addError(lineNumber, "Error: Operand not in current data-memory sector or residual sector")
					else:
						loc = hop["DLOC"]
						if hop["DS"] == 0o17:
							residual = 1
				else:
					# The operand is an LHS in instruction space.  If that's within the 
					# current instruction sector, we can convert the HOP to a TRA and
					# be done with it.  If not, then we need to allocate a nameless
					# variable to hold the HOP constant.
					if hop["IM"] == IM and hop["IS"] == IS:
						loc = hop["LOC"]
						residual = hop["S"]
						assembled = operators["TRA"]["opcode"]
						op = "%02o" % assembled
						#addError(lineNumber, "Info: Converting HOP to TRA")
					else:
						hopConstant = formConstantHOP(hop)
						constantString = "%09o" % hopConstant
						#print("A1: allocateNameless " + constantString + " " + operand)
						loc,residual = allocateNameless(lineNumber, constantString)
						#print("A2: %o,%20o,%03o %o" % (DM, DS, loc, residual))
						ds = DS
						if loc > 0o377 or DS == 0o17:
							loc = loc & 0o377
							residual = 1
							ds = 0o17
						#addError(lineNumber, "Info: Allocating variable for HOP at %o,%02o,%03o" % (DM, ds, loc))
		elif operator in ["CDS", "CDSD", "CDSS"]:
			ofields = operand.split(",")
			insane = False
			if len(ofields) not in [2, 3]:
				insane = True
			elif not ofields[0].isdigit() or not ofields[1].isdigit() or int(ofields[0],8) > 7 or int(ofields[1],8) > 15:
				insane = True
			elif len(ofields) == 3 and ofields[2] not in ["0", "1"]:
				insane = True
			elif len(ofields) == 3 and operator != "CDS":
				insane = True
			elif len(ofields) == 2 and operator not in ["CDSD", "CDSS"]:
				insane = True
			elif operator == "CDSD":
				ofields.append("1")
			elif operator == "CDSS":
				ofields.append("0")
			if insane:
				loc = 0
				addError(lineNumber, "Error: Illegal operand for CDS/CDSS/CDSD")
			else:
				loc = int(ofields[2], 8) | (int(ofields[0], 8) << 1) | (int(ofields[1], 8) << 4)
			residual = 0
		else:
			# Instruction is a "regular" one ... not one of the ones dealt with above.
			if operand [:1] == "=":
				constantString = convertNumericLiteral(operand[1:])
				if constantString == "":
					addError(lineNumber, "Error: Illegal numeric literal")
					loc = 0
				else:
					#print("B1: allocateNameless " + constantString + " " + operand)
					loc,residual = allocateNameless(lineNumber, constantString)
					#print("B2: %o,%20o,%03o %o" % (DM, DS, loc, residual))
					ds = DS
					if loc > 0o377 or DS == 0o17:
						loc = loc & 0o377
						residual = 1
						ds = 0o17
					#addError(lineNumber, "Info: Allocating nameless variable for =constant at %o,%02o,%03o" % (DM, ds, loc))
			elif operand.isdigit():
				pass
			elif operand not in symbols:
				addError(lineNumber, "Error: LHS (" + operand + ") from operand not found")
			else: 
				hop = symbols[operand]
				if hop["inDataMemory"]:
					if hop["DM"] != DM or (hop["DS"] != DS and hop["DS"] != 0o17):
						addError(lineNumber, "Error: Operand not in current data-memory sector or residual sector")
					else:
						loc = hop["DLOC"]
						if operandModifierOperation == "+":
							loc += operandModifier
						elif operandModifierOperation == "-":
							loc -= operandModifier
						if hop["DS"] == 0o17:
							residual = 1
				else:
					if hop["IM"] != DM or hop["IS"] != DS:
						addError(lineNumber, "Error: Operand not in current data-memory sector")
					else:
						loc = hop["LOC"]
						if operandModifierOperation == "+":
							loc += operandModifier
						elif operandModifierOperation == "-":
							loc -= operandModifier
						if hop["DS"] == 0o17:
							residual = 1
		if loc > 0o377:
			loc = loc & 0o377
			residual = 1
		a81 = "%03o" % loc
		a9 = "%o" % residual
		assembled = (assembled | (loc << 5) | (residual << 4)) << 3
		storeAssembled(assembled, hop, False)
	
	if lineNumber != lastLineNumber:
		lastLineNumber = lineNumber
		for error in errorList:
			print(error)
	print(line + " " + a81 + "  " + a9 + "  " + op + "  " + ("%9s" % constantString) + " \t" + inputLine["raw"])
	if repeat > 0:
		repeat -= 1
		hopLOC = hop["LOC"]
		while repeat > 0:
			hopLOC += 1
			if repeat == 1:
				line = " %o %02o %o %03o        " % (hop["IM"], hop["IS"], hop["S"], hopLOC)
				a81 = "%03o" % locFinal
				assembled = (assembled | (locFinal << 5) | (residual << 4)) << 3
				storeAssembled(assembled, hop, False)
			print(line + " " + a81 + "  " + a9 + "  " + op)
			repeat -= 1

#----------------------------------------------------------------------------
#   	Print a symbol table
#----------------------------------------------------------------------------
print("\n\nSymbol Table:")
for key in sorted(symbols):
	hop = symbols[key]
	print("%o %02o %o %03o" % (hop["IM"], hop["IS"], hop["S"], 
						hop["LOC"]) + "  " + key)
for key in sorted(nameless):
	loc = nameless[key]
	fields = key.split("_")
	print(fields[0] + " " + fields[1] + "   " + ("%03o" % loc) + "  " + fields[2])

#----------------------------------------------------------------------------
#   	Print octal listing
#----------------------------------------------------------------------------
formatLine = "%03o"
for n in range(8):
	formatLine += "   %s D"
heading = "     "
for n in range(8):
	heading += "      %o         " % n
for module in range(8):
	for sector in range(16):
		sectorUsed = False
		for syllable in range(2):
			if sectorUsed:
				break
			for loc in range(256):
				if used[module][sector][syllable][loc]:
					sectorUsed = True
					break
		if not sectorUsed:
			continue
		print("")
		print("")
		print("%56sMODULE %o      SECTOR %02o" % ("", module, sector))
		print("")
		print("")
		print(heading)
		print("")
		for row in range(0, 256, 8):
			rowList = [row]
			for loc in range(row, row + 8):
				if not (used[module][sector][0][loc] or used[module][sector][1][loc]):
					rowList.append("           ")
				elif octals[module][sector][2][loc] != None:
					rowList.append(" %09o " % octals[module][sector][2][loc])
				else:
					col = ""
					for syl in [1, 0]:
						if syl == 0:
							col += " "
						if not used[module][sector][syl][loc]:
							col += "     "
						elif octals[module][sector][syl][loc] == None:
							col += "-----"
						else:
							col += "%05o" % octals[module][sector][syl][loc]
					rowList.append(col)
			print(formatLine % tuple(rowList))
	 
