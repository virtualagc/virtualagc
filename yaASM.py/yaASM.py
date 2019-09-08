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
#              yaASM.py [OCTALS.tsv] <INPUT.lvdc >OUTPUT.listing
# Regardless of whether or not the assembly is successful, an octal-listing
# file called yaASM.tsv is created.  It is also possible to optionally have
# an octal-listing file (OCTALS.tsv) as in input.  If so, it does not affect
# the assembly process at all, but is used for checking purposes and for 
# marking lines in the output assembly listing which disagree with OCTALS.tsv.
# No separate binary file of octals is produced; the yaASM.tsv file, which 
# is tab-delimited ASCII, should be parsed instead if required for (for example)
# an LVDC simulator.

import sys
# The next line imports expression.py.
from expression import *

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
    "EXM": { "opcode":0b1110, "a9":1, "a8":1 },
    "CLA": { "opcode":0b1111 }, 
    "SHR": { "opcode":0b1110, "a9":1, "a8":0 }, 
    "SHL": { "opcode":0b1110, "a9":1, "a8":0 }
}
pseudos = []
preprocessed = ["EQU", "IF", "ENDIF", "MACRO", "ENDMAC", "FORM"]

# Bit patterns used by DFW pseudo-ops. The key value is the DS.
dfwBits = {
	0o04: { "a2": 0, "a1": 0, "a9": 0 },
	0o14: { "a2": 0, "a1": 0, "a9": 1 },
	0o05: { "a2": 0, "a1": 1, "a9": 0 },
	0o15: { "a2": 0, "a1": 1, "a9": 1 },
	0o06: { "a2": 1, "a1": 0, "a9": 0 },
	0o16: { "a2": 1, "a1": 0, "a9": 1 },
	0o07: { "a2": 1, "a1": 1, "a9": 0 },
	0o17: { "a2": 1, "a1": 1, "a9": 1 }
}

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
lastORG = False
inDataMemory = True
symbols = {}
lastLineNumber = -1

# Array for keeping track of assembled octals
octals = [[[[None for offset in range(256)] for syllable in range(3)] for sector in range(16)] for module in range(8)]
octalsForChecking = [[[[None for offset in range(256)] for syllable in range(3)] for sector in range(16)] for module in range(8)]
checkTheOctals = False

if len(sys.argv) > 1:
	try:
		f = open(sys.argv[1], "r")
		module = -1
		sector = -1
		for line in f:
			line = line.strip()
			if line[:1] == "#" or len(line) == 0:
				continue
			fields = line.split("\t")
			if len(fields) == 0:
				continue
			if fields[0] == "SECTOR":
				module = int(fields[1], 8)
				sector = int(fields[2], 8)
				if module > 7 or sector > 15:
					raise("Warning: module or sector out of range")
				continue
			offset = int(fields[0], 8)
			ptr = 1
			for count in range((len(fields) - 1) // 2):
				if len(fields[ptr]) != 11:
					raise("Warning: wrong field length")
				elif fields[ptr].strip() == "" and fields[ptr + 1].strip() == "":
					# An unused word.
					pass
				elif fields[ptr + 1] == "D" and fields[ptr][0] == " " and fields[ptr][-1] == " " and fields[ptr][1:-2].isdigit():
					# A data word.
					value = int(fields[ptr].strip(), 8)
					octalsForChecking[module][sector][2][offset] = value
				elif fields[ptr + 1] == "D" and (fields[ptr][:5] == "     " or fields[ptr][:5].isdigit()) \
					and fields[ptr][5] == " " and (fields[ptr][6:] == "     " or fields[ptr][6:].isdigit()):
					# An instruction-pair word.
					syl1 = fields[ptr][:5]
					syl0 = fields[ptr][6:]
					if syl1.strip() != "":
						value = int(syl1, 8)
						octalsForChecking[module][sector][1][offset] = value
					if syl0.strip() != "":
						value = int(syl0, 8)
						octalsForChecking[module][sector][0][offset] = value
				else:
					raise("Warning: unrecognized format: " + line)	
				ptr += 2
				offset += 1
		f.close()
		checkTheOctals = True
	except:
		print("Warning: Cannot open octal-comparison file " + sys.argv[1] + " or file is corrupted")
#print(octalsForChecking)

# The following structures are used for tracking instructions transparently
# inserted at the ends of syllable 1 of memory sectors by the assembler when
# TMI or TNZ instruction targets not in the current sector.  In those cases,
# the TMI or TNZ is made to jump to the end of the current sector, where they
# will find a HOP instruction to the desired target.  The roofAdders and 
# roofRemovers structures are used during the Discovery pass to figure out 
# how many locations need to be reserved at the ends of the sectors for 
# such stuff, whereas, the roofed structure tracks which target locations are
# associated with which of the inserted HOPs (which is info that's needed if
# more than one TMI or TNZ uses the same target).
roofAdders = []
roofRemovers = []
roofed = []
for n in range(8):
	roofAdders.append([])
	roofRemovers.append([])
	roofed.append([])
	for m in range(16):
		roofAdders[n].append([])
		roofRemovers[n].append([])
		roofed[n].append([])

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

# Find out the last usable instruction location in a sector,
# because _some_ TMI or TMZ instructions need an extra word
# at the top of syllable 1.  The assembler is going to automatically
# shove a HOP into this location if an automatic syllable switch
# occurs.
def getRoof(imod, isec, syl, extra):
	if syl == 0:
		# No space needs to be reserved in syllable 0.
		roof = 0o377
	else:
		# In syllable 1, the default amount of reserved
		# space is 3 words:  0o377 and 0o376 can be used by
		# TNZ and TMI, but 0o375 are never used for anything
		# as far as I can see.  Because of that, if less 
		# than 2 words is needed by TMI/TNZ, the amount of
		# reserved space can't be reduced.  But if more than
		# 2 words are needed by TMI or TNZ, we can add them 
		# below 0o375.
		roof = 0o374
		needed = len(set(roofAdders[imod][isec]) - set(roofRemovers[imod][isec]))
		if needed > 2:
			roof -= (needed - 2)
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
	isInt = True
	if "." in decimal or "E" in decimal:
		isInt = False
	if "B" in decimal:
		isInt = False
		whereB = decimal.index("B")
		scale = decimal[whereB:]
		decimal = decimal[:whereB]
		if "E" in scale:
			whereE = scale.index("E")
			decimal += scale[whereE:]
			scale = scale[:whereE]
	try:
		if not isInt:
			decimal = float(decimal)
			scale = int(scale[1:])
			value = round(decimal * pow(2, 27 - scale - 1 - 1)) << 1
		else:
			decimal = int(decimal)
			scale = int(scale[1:])
			value = round(decimal * pow(2, 27 - scale))
		if value < 0:
			value += 0o1000000000
		constantString = "%09o" % value
		return constantString
	except:
		print(n)
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
			#addError(lineNumber, "Info: Allocation of nameless " + value)
			used[DM][DS][0][loc] = True
			used[DM][DS][1][loc] = True
			nameless[value] = loc
			return loc,0
	if useResidual and DS != 0o17:
		for loc in range(0, 256):
			if not used[DM][0o17][0][loc] and not used[DM][0o17][1][loc]:
				#addError(lineNumber, "Info: Allocation of nameless " + valueR)
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
			addError(lineNumber, "Warning: Skipping memory locations already used")
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
				addError(lineNumber, "Warning: Skipping memory locations already used")
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

# Disassembles the two syllables of a word into instructions.  Useful only for debugging
# DFW pseudo-ops.  Code adapted from unOP.py.
def unassemble(word):
	instructions = [ "HOP", "MPY", "SUB", "DIV", "TNZ", "MPH", "AND", "ADD", "TRA", "XOR", "PIO", "STO", "TMI", "RSU", "", "CLA" ]
	syllables = [(word & 0o777740000) >> 13 , word & 0o37776]
	s = ""
	for syllable in syllables:
		if s != "":
			s += "   "
		op = (syllable >> 1) & 0x0F
		if op == 0o16:
			if (syllable & 32) == 0:
				instruction = "CDS"
				DM = (syllable >> 7) & 3
				DS = (syllable >> 10) & 15
				s += "%s %o,%02o" % (instruction, DM, DS)
			elif (syllable & 0o10000) == 0:
				instruction = "SHF"
				address = (syllable >> 6) & 0o63
				if address == 0:
					s += "SHL 0"
				elif address == 1:
					s += "SHR 1"
				elif address == 2:
					s += "SHR 2"
				elif address == 16:
					s += "SHL 1"
				elif address == 32:
					s += "SHL 2"
				else:
					s += "%s %03o" % (instruction, address)
			else:
				instruction = "EXM"
				left = (syllable >> 11) & 3
				middle = (syllable >> 10) & 1
				right = (syllable >> 6) & 15
				s += "%s %o,%o,%02o" % (instruction, left, middle, right)
		else:
			instruction = instructions[op]
			address = ((syllable >> 6) & 0xFF) | ((syllable << 3) & 0x100)
			residual = 0
			if address > 0o377:
				residual = 1
				address = address & 0o377
			s += "%s %o %03o" % (instruction, residual, address)
	return s

# Put the assembled value wherever it's supposed to go in the executable image.
def storeAssembled(lineNumber, value, hop, data = True):
	global octals, octalsUsed
	checkSyl = -1
	if data:
		module = hop["DM"]
		sector = hop["DS"]
		location = hop["DLOC"]
		checkSyl = 2
		octals[module][sector][2][location] = value
	else:
		module = hop["IM"]
		sector = hop["IS"]
		syllable = hop["S"]
		location = hop["LOC"]
		if useDat:
			value = value & 0o17777
			if syllable == 1:
				value = value << 14
			else:
				value = value << 1
			if octals[module][sector][2][location] == None:
				octals[module][sector][2][location] = value
			else:
				checkSyl = 2
				octals[module][sector][2][location] = octals[module][sector][2][location] | value
		else:
			checkSyl = syllable
			if syllable == 1:
				octals[module][sector][syllable][location] = (value << 2) & 0o77774
			else:
				octals[module][sector][syllable][location] = (value << 1) & 0o37776
	if checkTheOctals and checkSyl >= 0:
		if octals[module][sector][checkSyl][location] != octalsForChecking[module][sector][checkSyl][location]:
			msg = "Error: Octal mismatch, "
			if checkSyl == 2:
				fmt = "%09o != %09o, xor = %09o" 
			else:
				fmt = "%05o != %05o, xor = %05o"
			xor = octals[module][sector][checkSyl][location] ^ octalsForChecking[module][sector][checkSyl][location]
			msg += fmt % (octals[module][sector][checkSyl][location], octalsForChecking[module][sector][checkSyl][location], xor)
			msg += ", disassembly   " + unassemble(octals[module][sector][checkSyl][location])
			msg += "   !=   " + unassemble(octalsForChecking[module][sector][checkSyl][location])
			addError(lineNumber, msg)

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
#	Expansion of SHL, SHR
#	Macro definitions
#	Usage of EQU-defined constants in assembly-language operands
#	Expansion of macros
#	Conditionally-assembled code.
# The array expandedLines[] will end up being exactly the same length as lines[],
# and the entries will correspond 1-to-1 to it, but the entries will be arrays of
# replacement lines.  In other words, suppose line=lines[n].  If the preprocessor
# doesn't need to change the line, then expandedLines[n] will be [line].  Suppose
# the preprocessor needs to change line to (say) newLine.  Then expandedLines[n]
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
			value,error = yaEvaluate(fields2[index:index2], constants)
			if error != "":
				addError(n, error)
				break
			fields2 = fields2[:index] + str(value["number"]).upper() + fields2[index2:]
		if fields2 != fields[2]:
			expandedLines[n] = [line.replace(fields[2], fields2)]
			fields[2] = fields2
	if len(fields) >= 3 and fields[1] in ["TABLE", "DEC"] and fields[2][:1] == "(":
		value,error = yaEvaluate(fields2, constants)
		if error != "":
			addError(n, error)
			break
		if fields[1] == "TABLE":
			fields2 = str(value["number"]).upper()
		else:
			fields2 = str(value["number"]).upper()
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
	elif len(fields) >= 3 and fields[0] != "" and fields[1] in ["DEQD", "DEQS"]:
		constants[fields[0]] = [fields[1]] + fields[2].split(",")
	elif len(fields) >= 3 and fields[1] == "CDS" and fields[2] in constants and type(constants[fields[2]]) == type([]) and len(constants[fields[2]]) >= 3:
		constant = constants[fields[2]]
		op = fields[1]
		if constant[0] == "DEQS":
			op = "CDSS"
		elif constant[0] == "DEQD":
			op = "CDSD"
		line = "%-8s%-8s%s" % (fields[0], op, "%s,%s" % (constant[1], constant[2]))
		expandedLines[n] = [line]
	elif len(fields) >= 3 and fields[0] != "" and fields[1] == "EQU":
		value,error = yaEvaluate(fields[2], constants)
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
	elif len(fields) >= 3 and fields[1] in ["SHL", "SHR"] and fields[2].isdigit():
		count = int(fields[2])
		expandedLines[n] = []
		thisLabel = fields[0]
		operator = fields[1]
		if count == 0:
			expandedLines[n].append("%-8s%-8s0" % (thisLabel, operator))
		else:
			while count > 0:
				thisCount = 2
				if thisCount > count:
					thisCount = 1
				expandedLines[n].append("%-8s%-8s%d" % (thisLabel, operator, thisCount))
				thisLabel = ""
				count -= thisCount
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
					value,error = yaEvaluate(operand[1:], constants)
					if error != "":
						addError(n, "Error: " + error)
						continue
					operand = "=" + str(value["number"]).upper()
					if "scale" in value:
						operand +=  "B" + str(value["scale"])
				if m == 0:
					lhs = fields[0]
				expandedLines[n].append("%-8s%-8s%s" % (lhs, operator, operand))
	elif len(fields) >= 3 and fields[2][:2] == "=(":
		value,error = yaEvaluate(fields[2][1:], constants)
		if error != "":
			addError(n, "Error: " + error)
		else:
			replacement = "=" + str(value["number"]).upper()
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
			addError(n, "Error: Malformed IF")
			continue
		value,error = yaEvaluate(ofields[1], constants)
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
		inputLine = { "raw": line, "VEC": False, "MAT": False }
		isCDS = False
		    
		# Split the line into fields.
		if line[:1] in [" ", "\t"] and not line.isspace():
			line = "@" + line
		fields = line.split()
		if len(fields) > 0 and fields[0] == "@":
			fields[0] = ""
		    
		# Remove comments.
		if inputLine["raw"][:1] in ["*", "#"]:
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
				try:
					checkDLOC(int(fields[2]))
				except:
					print(lineNumber)
					print(line)
					print(fields)
					print(ofields)
					sys.exit(1)
			elif fields[0] != "" and fields[1] == "SYN":
				synonyms[fields[0]] = fields[2]
			elif fields[0] != "" and fields[1] == "FORM":
				if fields[0] in forms:
					addError(n, "Error: Form already defined")
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
			elif fields[1] in ["DEQS", "DEQD"] and fields[0] in constants:
				symbols[fields[0]] = {	"IM":IM, "IS":IS, "S":S, 
								"LOC":LOC, "DM":int(constants[fields[0]][1], 8), 
								"DS":int(constants[fields[0]][2], 8), 
								"DLOC":DLOC, "inDataMemory":True }
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
				
				# Try to track the number of locations we need for remapping TMI and TNZ targets.
				if len(fields) >= 2 and fields[0] != "":
					if fields[0] not in roofRemovers[IM][IS]:
						roofRemovers[IM][IS].append(fields[0])
				if len(fields) >= 3 and fields[1] in ["TMI", "TNZ"] and fields[2][:1].isalpha():
					symbol = fields[2].split("+")[0].split("-")[0]
					if symbol not in roofAdders[IM][IS]:
						roofAdders[IM][IS].append(symbol)
				
				if useDat:
					inputLine["hop"] = {"IM":DM, "IS":DS, "S":dS, "LOC":DLOC, "DM":DM, "DS":DS, "DLOC":DLOC}
					inputLine["useDat"] = True
				else:
					inputLine["hop"] = {"IM":IM, "IS":IS, "S":S, "LOC":LOC, "DM":DM, "DS":DS, "DLOC":DLOC}
				incLOC()
				if fields[1] in ["CDS", "CDSD", "CDSS"]:
					# I should be doing something here with the simplex vs duplex info, but I don't
					# know what, so I'll just ignore it for now.
					isCDS = True
					if len(ofields) == 1:
						if not useDat:
							found = False
							# Operand symbol could have been defined by a DEQS or DEQD
							if fields[2] in constants:
								constant = constants[fields[2]]
								if type(constant) == type([]) and len(constant) >= 3:
									#print(constant[1] + " " + constant[2])
									DM = int(constant[1], 8)
									DS = int(constant[2], 8)
									found = True
							# We assume this is the name of a variable, and we have to
							# find it to determine its DM/DS.  I presume it could be
							# defined later, and so we don't find it ... let's hope not!
							if not found:
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
								addError(lineNumber, "Error: Symbol not found")
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
		inputLine["useDat"] = useDat
		inputLine["isCDS"] = isCDS
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
			symbols[lhs]["isCDS"] = inputLine["isCDS"]
		else:
			addError(lineNumber, "Error: Symbol location unknown")

# A mini-pass to set up SYN symbols.
for n in range(0, len(lines)):
	line = lines[n]
	# Split the line into fields.
	if line[:1] in [" ", "\t"] and not line.isspace():
		line = "@" + line
	fields = line.split()
	if len(fields) > 0 and fields[0] == "@":
		fields[0] = ""
		line = line[1:]
	if len(fields) >= 3 and fields[0] != "" and fields[1] == "SYN":
		if fields[2] not in symbols:
			addError(n, "Error: Synonym not found")
		else:
			symbols[fields[0]] = symbols[fields[2]]

if False:
	for key in sorted(symbols):
		symbol = symbols[key]
		print("%-8s  %o %02o %o %03o  %o %02o %03o" % (key, symbol["IM"], 
                symbol["IS"], symbol["S"], symbol["LOC"], symbol["DM"], 
                symbol["DS"], symbol["DLOC"]))

if False:
	for dm in range(8):
		for ds in range(16):
			r = set(roofAdders[dm][ds]) - set(roofRemovers[dm][ds])
			print(("%o %02o " % (dm, ds)) + str(r))
			#print(sorted(roofAdders[dm][ds]))
			#print(sorted(roofRemovers[dm][ds]))
			#print("")

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
useDat = False
errorsPrinted = []
lastLineNumber = -1
expansionMarker = " "
for entry in inputFile:
	lineNumber = entry["lineNumber"]
	inputLine = entry["expandedLine"]
	errorList = errors[lineNumber]
	originalLine = lines[lineNumber]
	constantString = ""
	star = False
	
	# If the line is expanded by the preprocessor, we have to display its unexpanded form
	# before proceeding.
	if lineNumber != lastLineNumber:
		lastLineNumber = lineNumber
		if inputLine["raw"] == originalLine:
			expansionMarker = " "
		else:
			expansionMarker = "+"
			print(("%40s" % "") + "\t" + originalLine)
			
	# If there's an automatic sector switch here, we have to take care of it prior to
	# doing anything with the instruction that's actually associated with this line.
	if "switchSectorAt" in inputLine:
		print("*")
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
			assembled = (operators["TRA"]["opcode"] | (loc1 << 5) | (s1 << 4))
			a81 = "%03o" % loc1
			a9 = "%o" % s1
			op = "%02o" % operators["TRA"]["opcode"]
		else:
			# Must use a HOP.
			hopConstant = formConstantHOP(inputLine["hop"])
			constantString = "%09o" % hopConstant
			loc,residual = allocateNameless(lineNumber, constantString, False)
			assembled = (operators["HOP"]["opcode"] | (loc << 5) | (residual << 4))
			a81 = "%03o" % loc
			a9 = "%o" % residual
			op = "%02o" % operators["HOP"]["opcode"]
			ds = DS
			if residual != 0:
				ds = 0o17
			storeAssembled(lineNumber, hopConstant, {
				"IM": IM,
				"IS": IS,
				"S": residual,
				"LOC": loc,
				"DM": DM,
				"DS": ds,
				"DLOC": loc
			}, True)
		storeAssembled(lineNumber, assembled, {"IM":im0, "IS":is0, "S":s0, "LOC":loc0}, False)
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
		if operand[:1].isalpha() or operand[:1] == "*":
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
		if "useDat" in inputLine and inputLine["useDat"]:
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
	
	if "useDat" in inputLine:
		useDat = inputLine["useDat"]
	
	# Assemble.
	a81 = "   "
	a9 = " "
	op = "  "
	constantString = ""
	inDataMemory = True
	if operator == "BSS":
		bssHop = hop.copy()
		for n in range(int(operand)):
			storeAssembled(lineNumber, 0, bssHop)
			bssHop["DLOC"] += 1
	elif operator in [ "DEC", "OCT", "HPC", "HPCDD", "DFW" ] or operator in forms:
		assembled = 0
		if operator in forms:
			formDef = forms[operator]
			ofields = operand.split(",")
			if len(formDef) != len(ofields):
				addError(lineNumber, "Error: Wrong number of operand fields")
			else:
				try:
					numBits = 0
					cumulative = 0
					for n in range(len(formDef)):
						patternValue = int(formDef[n])
						ceiling = pow(2, patternValue)
						usageValue = int(ofields[n], 8)
						if usageValue >= ceiling:
							addError(lineNumber, "Error: Field value too large for defined form")
							usageValue = usageValue & (ceiling - 1)
						cumulative = cumulative << patternValue
						cumulative = cumulative | usageValue
						numBits += patternValue
					if numBits > 26:
						addError(lineNumber, "Error: Form definition was too big")
						cumulative = cumulative >> (numBits - 26)
						numbits = 26
					hopConstant = cumulative << (27 - numBits)
					constantString = "%09o" % hopConstant
				except:
					addError(lineNumber, "Error: Illegal operand or form definition")
		elif operator == "DEC":
			constantString = convertNumericLiteral(operand)
		elif operator == "OCT":
			constantString = convertNumericLiteral(operand, True)
		elif operator == "HPC":
			ofields = operand.split(",")
			if len(ofields) == 1:
				ofields.append(ofields[0])
			if ofields[0] not in symbols or ofields[1] not in symbols:
				addError(lineNumber, "Error: Symbol(s) not found")
				constantString = ""
			else:
				symbol1 = symbols[ofields[0]]
				symbol2 = symbols[ofields[1]]
				hopConstant = formConstantHOP({
					"IM": symbol1["IM"],
					"IS": symbol1["IS"],
					"S": symbol1["S"],
					"LOC": symbol1["LOC"],
					"DM": symbol2["DM"],
					"DS": symbol2["DS"]
				})
				constantString = "%09o" % hopConstant
		elif operator == "HPCDD":
			ofields = operand.split(",")
			if len(ofields) == 2 and ofields[0] in symbols and ofields[1] in symbols:
				symbol1 = symbols[ofields[0]]
				symbol2 = symbols[ofields[1]]
				im = symbol1["IM"]
				isc = symbol1["IS"]
				s = symbol1["S"]
				loc = symbol1["LOC"]
				dm = symbol2["DM"]
				ds = symbol2["DS"]
			elif len(ofields) != 6 or not ofields[0].isdigit() or not ofields[1].isdigit() \
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
			constantString = ""
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
				loc1 = symbol1["LOC"]
				loc0 = symbol0["LOC"]
				ds1 = symbol1["DS"]
				ds0 = symbol0["DS"]
				if ds1 not in dfwBits:
					addError(lineNumber, "Error: Wrong sector in DFW constant for syllable 1")
				else:
					residual1 = dfwBits[ds1]["a9"]
					loc1 = (loc1 & ~3) | (dfwBits[ds1]["a2"] << 1) | dfwBits[ds1]["a1"]
				if ds0 not in dfwBits:
					addError(lineNumber, "Error: Wrong sector in DFW constant for syllable 0")
				else:
					residual0 = dfwBits[ds0]["a9"]
					loc0 = (loc0 & ~3) | (dfwBits[ds0]["a2"] << 1) | dfwBits[ds0]["a1"]
				assembled1 |= (residual1 << 4) | (loc1 << 5)
				assembled0 |= (residual0 << 4) | (loc0 << 5)
				hopConstant = (assembled1 << 14) | (assembled0 << 1)
				constantString = "%09o" % hopConstant
		else:
			constantString = ""
		if constantString == "":
			addError(lineNumber, "Error: Invalid operand")
		else:
			assembled = int(constantString, 8)
		# Put the assembled value wherever it's supposed to 
		storeAssembled(lineNumber, assembled, inputLine["hop"])
	elif operator in operators:
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
		if operator == "EXM":
			ofields = operand.split(",")
			try:
				a76 = int(ofields[0], 8)
				a5 = int(ofields[1], 8)
				a41 = int(ofields[2], 8)
				if a76 > 3 or a5 > 1 or a41 > 15:
					addError(lineNumber, "Error: Illegal operands")
				else:
					loc = (a76 << 5) | (a5 << 4) | a41
					residual = 1
			except:
				addError(lineNumber, "Error: Illegal operands")
		elif operator in ["SHR", "SHL"]:
			if loc == 0:
				pass
			elif operator == "SHR" and loc <= 2:
				pass
			elif operator == "SHL" and loc <= 2:
				loc = loc << 4
			else:
				addError(lineNumber, "Error: Shift count must be 0, 1, or 2")
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
					residual = 0
			elif operand.isdigit():
				#print("Here: " + str(inputLine))
				pass
			elif operand not in symbols:
				addError(lineNumber, "Error: Target location of TRA not found")
			elif symbols[operand]["IM"] == IM and symbols[operand]["IS"] == IS and ((symbols[operand]["DM"] == DM \
					and symbols[operand]["DS"] in [DS, 0o17]) or symbols[operand]["isCDS"]):
				# Regarding DM/DS, which appears in this conditional, a TRA/TMI/TNZ 
				# instruction doesn't require the target location to be in the same
				# DM/DS, but the original assembler seemed to disallow it.  I assume
				# that's for safety purposes.  On the other hand, even if there's a 
				# DM/DS mismatch, the TRA seems to be allowed if there's a CDS instruction
				# at the target location or if the target is on the residial sector.  
				# Which seems pretty convoluted, though pragmatically reasonable, so I may be
				# misinterpreting what's going on.
				loc = symbols[operand]["LOC"]
				residual = symbols[operand]["S"]
			elif operator == "TRA":
				# The target location exists, but is not in this IM/IS/DM/DS.
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
				ds = DS
				if residual != 0:
					ds = 0o17
				storeAssembled(lineNumber, hopConstant, {
					"IM": IM,
					"IS": IS,
					"S": residual,
					"LOC": loc,
					"DM": DM,
					"DS": ds,
					"DLOC": loc
				})
				star = True
			else: 
				# For the moment, I'm ignoring the possibility of 
				#	TMI	SYMBOL+offset
				# and similar cases.  I'm just assuming that the operand is a symbol.
				if operandModifierOperation != "":
					addError(lineNumber, "Error: Not implemented yet")
				
				# Operator is TNZ or TMI and the target is out of the sector.
				# The technique in this case is to use a word at the top of syllable
				# 1 of the sector to store a HOP instruction that gets us to the 
				# target.  The words are used in the order 0o377, 0o376, 0o374 (0o375
				# is alway skipped), 0o373, etc.
				star = True
				residual = 1
				hopConstant2 = formConstantHOP(symbols[operand])
				constantString = "%09o" % hopConstant2
				if operand in roofed[IM][IS]:
					# An appropriate HOP instruction has already been put at the 
					# end of the sector, so we can just take advantage of it.
					index = roofed[IM][IS].index(operand)
					loc = 0o377 - index
					if loc <= 0o375:
						loc -= 1
				else:
					# No HOP to this target has been added to the end of the sector,
					# so we must do so now.
					index = len(roofed[IM][IS])
					loc = 0o377 - index
					if loc <= 0o375:
						loc -= 1
					roofed[IM][IS].append(operand)
					loc2,residual2 = allocateNameless(lineNumber, constantString, False)
					ds = DS
					if residual2 != 0:
						ds = 0o17
					storeAssembled(lineNumber, hopConstant2, {
						"IM": IM,
						"IS": IS,
						"S": residual2,
						"LOC": loc2,
						"DM": DM,
						"DS": ds,
						"DLOC": loc2
					})
					assembled2 = operators["HOP"]["opcode"]
					assembled2 = (assembled2 | (loc2 << 5) | (residual2 << 4))
					storeAssembled(lineNumber, assembled2, {
						"IM": IM,
						"IS": IS,
						"S": 1,
						"LOC": loc,
						"DM": DM,
						"DS": DS
					}, False)
					used[IM][IS][1][loc] = True
		elif operator == "HOP":
			if operand.isdigit():
				#addError(lineNumber, "Info: Converting HOP to TRA")
				pass
			elif operand not in symbols:
				addError(lineNumber, "Error: Target location of HOP not found")
			else:
				hop2 = symbols[operand]
				if operandModifierOperation != "":
					addError(lineNumber, "Error: Cannot apply + or - in HOP operand")
				elif "inDataMemory" in hop2 and hop2["inDataMemory"]:
					# The operand is a variable, as it ought to be.
					if hop2["DM"] != DM or (hop2["DS"] != DS and hop2["DS"] != 0o17):
						if not useDat or S == 1:
							addError(lineNumber, "Error: Operand not in current data-memory sector or residual sector")
					loc = hop2["DLOC"]
					if hop2["DS"] == 0o17:
						residual = 1
				else:
					# The operand is an LHS in instruction space.  If that's within the 
					# current instruction sector, we should be able to convert the HOP 
					# to a TRA and be done with it, and I could have sworn I saw
					# cases where that had happened. However, I can't find them any
					# longer, and I definitely know cases where that _doesn't_ happen:
					# see HOPs to MMSET.  At any rate, that's why the first half of the
					# conditional was written and then disabled. 
					if False and hop2["IM"] == IM and hop2["IS"] == IS:
						loc = hop2["LOC"]
						residual = hop2["S"]
						assembled = operators["TRA"]["opcode"]
						op = "%02o" % assembled
						#addError(lineNumber, "Info: Converting HOP to TRA")
					else:
						star = True
						# We need to allocate a nameless variable to hold the HOP constant.
						hopConstant = formConstantHOP(hop2)
						constantString = "%09o" % hopConstant
						#print("A1: allocateNameless " + constantString + " " + operand)
						loc,residual = allocateNameless(lineNumber, constantString)
						#print("A2: %o,%02o,%03o %o" % (DM, DS, loc, residual))
						ds = DS
						if loc > 0o377 or DS == 0o17 or residual != 0:
							loc = loc & 0o377
							residual = 1
							ds = 0o17
						#addError(lineNumber, "Info: Allocating variable for HOP at %o,%02o,%03o" % (DM, ds, loc))
						storeAssembled(lineNumber, hopConstant, {
							"IM": IM,
							"IS": IS,
							"S": residual,
							"LOC": loc,
							"DM": DM,
							"DS": ds,
							"DLOC": loc
						})
		elif operator == "CDS":
			if operand not in symbols:
				addError(lineNumber, "Error: Symbol not found")
				loc = 0
			else:
				#print("%o %2o" % (symbols[operand]["DM"], symbols[operand]["DS"]))
				loc = 1 | (symbols[operand]["DM"] << 1) | (symbols[operand]["DS"] << 4)
			residual = 0
		elif operator in ["CDSD", "CDSS"]:
			ofields = operand.split(",")
			duplex = 1
			if len(ofields) != 2 or not ofields[0].isdigit() or not ofields[1].isdigit() or int(ofields[0],8) > 7 or int(ofields[1],8) > 15:
				loc = 0
				addError(lineNumber, "Error: Illegal operand for CDSS/CDSD")
			if operator == "CDSS":
				duplex = 0
			loc = duplex | (int(ofields[0], 8) << 1) | (int(ofields[1], 8) << 4)
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
					if loc > 0o377 or DS == 0o17 or residual != 0:
						loc = loc & 0o377
						residual = 1
						ds = 0o17
					#addError(lineNumber, "Info: Allocating nameless variable for =constant at %o,%02o,%03o" % (DM, ds, loc))
					storeAssembled(lineNumber, int(constantString, 8), {
						"IM": IM,
						"IS": IS,
						"S": residual,
						"LOC": loc,
						"DM": DM,
						"DS": ds,
						"DLOC": loc
					})
			elif operand.isdigit():
				pass
			elif operand in constants and type(constants[operand]) == type([]) and len(constants[operand]) == 4:
				dm = int(constants[operand][1], 8)
				ds = int(constants[operand][2], 8)
				dloc = int(constants[operand][3], 8)
				if DM != DM or DS != DS:
					addError(lineNumber, "Error: Operand not in current data-memory sector or residual sector")
				else:
					loc = dloc
					if ds == 0o17:
						residual = 1
			elif operand not in symbols:
				addError(lineNumber, "Error: Symbol (" + operand + ") from operand not found")
			else: 
				hop2 = symbols[operand]
				if hop2["inDataMemory"]:
					if hop2["DM"] != DM or (hop2["DS"] != DS and hop2["DS"] != 0o17):
						if not useDat or S == 1:
							addError(lineNumber, "Error: Operand not in current data-memory sector or residual sector")
					loc = hop2["DLOC"]
					if operandModifierOperation == "+":
						loc += operandModifier
					elif operandModifierOperation == "-":
						loc -= operandModifier
					if hop2["DS"] == 0o17:
						residual = 1
				else:
					if hop2["IM"] != DM or hop2["IS"] != DS:
						if not useDat or S == 1:
							addError(lineNumber, "Error: Operand not in current data-memory sector")
					loc = hop2["LOC"]
					if operandModifierOperation == "+":
						loc += operandModifier
					elif operandModifierOperation == "-":
						loc -= operandModifier
					if hop2["DS"] == 0o17:
						residual = 1
		if loc > 0o377:
			loc = loc & 0o377
			residual = 1
		if "a8" in operators[operator]:
			loc = (loc & 0o177) | (operators[operator]["a8"] << 7)
		a81 = "%03o" % loc
		a9 = "%o" % residual
		assembled = assembled | (loc << 5) | (residual << 4)
		storeAssembled(lineNumber, assembled, hop, False)
	
	if lineNumber != lastLineNumber:
		errorsPrinted = []
		lastLineNumber = lineNumber
	for error in errorList:
		if error not in errorsPrinted:
			errorsPrinted.append(error)
			print(error)
	# If jump instructions have been remapped mark them with an asterisk.
	raw = inputLine["raw"]
	if star and operator in ["HOP", "TRA", "TNZ", "TMI"]:
		for n in range(len(raw)):
			if raw[n] in [" ", "\t"]:
				break
		for m in range(n, len(raw)):
			if raw[m] not in [" ", "\t"]:
				break
		m += 3
		if raw[m] == " ":
			raw = raw[:m] + "*" + raw[(m+1):]
		elif raw[m] == "\t":
			raw = raw[:m] + "*" + raw[m:]
	print(line + " " + a81 + "  " + a9 + "  " + op + "  " + ("%9s" % constantString) + " " + expansionMarker + "\t" + raw)
	fields = originalLine.split()
	if len(fields) > 1 and fields[1] == "MACRO" and fields[0] in macros:
		macroLines = macros[fields[0]]["lines"]
		for macroLine in macroLines:
			lineText = ""
			for n in macroLine:
				lineText += n + "\t"
			print(("%40s" % "") + "\t" + lineText)
		print(("%40s" % "") + "\t\tENDMAC")

#----------------------------------------------------------------------------
#   	Print a symbol table
#----------------------------------------------------------------------------
print("\n\nSymbol Table:")
print("")
for key in sorted(symbols):
	hop = symbols[key]
	if "inDataMemory" in symbols[key] and symbols[key]["inDataMemory"]:
		print("%o %02o   %03o" % (hop["IM"], hop["IS"], 
							hop["LOC"]) + "  " + key)
	else:
		print("%o %02o %o %03o" % (hop["IM"], hop["IS"], hop["S"], 
							hop["LOC"]) + "  " + key)
lastKey = ""
for key in sorted(nameless):
	loc = nameless[key]
	fields = key.split("_")
	newKey = fields[0] + "_" + fields[1]
	if newKey != lastKey:
		print("")
		lastKey = newKey
	print(fields[0] + " " + fields[1] + "   " + ("%03o" % loc) + "  " + fields[2])

#----------------------------------------------------------------------------
#   	Print octal listing and save as a .tsv file too
#----------------------------------------------------------------------------
f = open("yaASM.tsv", "w")
formatLine = "%03o"
for n in range(8):
	formatLine += "   %s %1s"
formatFileLine = "%03o"
for n in range(8):
	formatFileLine += "\t%s\t%s"
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
		print("SECTOR\t%o\t%02o" % (module, sector), file=f)
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
					rowList.append("")
				elif octals[module][sector][2][loc] != None:
					rowList.append(" %09o " % octals[module][sector][2][loc])
					rowList.append("D")
				else:
					col = ""
					usedEntry = False
					for syl in [1, 0]:
						if syl == 0:
							col += " "
						if not used[module][sector][syl][loc]:
							col += "     "
						elif octals[module][sector][syl][loc] == None:
							col += "-----"
							usedEntry = True
						else:
							col += "%05o" % octals[module][sector][syl][loc]
							usedEntry = True
					rowList.append(col)
					if usedEntry:
						rowList.append("D")
					else:
						rowList.append("")
			print(formatLine % tuple(rowList))
			print(formatFileLine % tuple(rowList), file=f)
f.close()
		
