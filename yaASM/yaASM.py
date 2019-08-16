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
#
# The usage is just
#              yaASM.py <INPUT.lvdc >OUTPUT.listing
# If the assembly is successful, an executable file for the assembler is 
# output, called lvdc.bin.

import sys
# The next line imports expression.py.
import expression

operators = {
    "HOP": { "opcode":0b0000 }, 
    "HOP*": { "opcode":0b0000 }, 
    "MPY": { "opcode":0b0001 }, 
    "SUB": { "opcode":0b0010 }, 
    "DIV": { "opcode":0b0011 }, 
    "TNZ": { "opcode":0b0100 }, 
    "TNZ*": { "opcode":0b0100 }, 
    "MPH": { "opcode":0b0101 }, 
    "AND": { "opcode":0b0110 }, 
    "ADD": { "opcode":0b0111 },
    "TRA": { "opcode":0b1000 }, 
    "TRA*": { "opcode":0b1000 }, 
    "XOR": { "opcode":0b1001 }, 
    "PIO": { "opcode":0b1010 }, 
    "STO": { "opcode":0b1011 }, 
    "TMI": { "opcode":0b1100 }, 
    "TMI*": { "opcode":0b1100 }, 
    "RSU": { "opcode":0b1101 }, 
    "CDS": { "opcode":0b1110, "a9":0 }, 
    "CDSD": { "opcode":0b1110, "a9":0 }, 
    "SHF": { "opcode":0b1110, "a9":1, "a8":0 }, 
    "EXM": { "opcode":0b0000, "a9":1, "a8":0 },
    "CLA": { "opcode":0b1111 }, 
    "SHR": { "opcode":0b1110, "a9":1, "a8":0 }, 
    "SHL": { "opcode":0b1110, "a9":1, "a8":0 }
}
pseudos = []

lines = sys.stdin.readlines()
for n in range(0,len(lines)):
	lines[n] = lines[n].rstrip()


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
expandedLines = []
errors = []
constants = {}
macros = {}
inMacro = ""
inFalseIf = False
for n in range(0, len(lines)):
	line = lines[n]
	errors.append([])
	expandedLines.append([line])
	# Split the line into fields.
	if line[:1] in [" ", "\t"] and not line.isspace():
		line = "@" + line
	fields = line.split()
	if len(fields) > 0 and fields[0] == "@":
		fields[0] = ""
		line = line[1:]
		
	if inMacro != "":
		if len(fields) >= 2 and fields[1] == "ENDMAC":
			if len(macros[inMacro]["lines"]) == 1:
				# In the cosmic scheme of things, there's no reason
				# why a macro can't have a single line in it, but
				# we don't allow it just because it would complicate
				# our processing.
				errors[n].append("Error: Macro has a single line")
			inMacro = ""
		else:
			macros[inMacro]["lines"].append(fields)
		expandedLines[-1] = []
	elif len(fields) >= 3 and fields[0] != "" and fields[1] == "EQU":
		value,error = expression.yaEvaluate(fields[2], constants)
		if error != "":
			errors[n].append("Error: " + error)
		else:
			constants[fields[0]] = value 
	elif len(fields) >= 3 and fields[1] == "CALL":
		ofields = fields[2].split(",")
		if len(ofields) == 2:
			line1 = "%-7s%-8s%s" % (fields[0], "CLA", ofields[1])
			line2 = "%-7s%-8s%s" % ("", "HOP*", ofields[0])
			expandedLines[n] = [line1, line2]
		elif len(ofields) == 3:
			line1 = "%-7s%-8s%s" % (fields[0], "CLA", ofields[2])
			line2 = "%-7s%-8s%s" % ("", "STO", "775")
			line3 = "%-7s%-8s%s" % ("", "CLA", ofields[1])
			line4 = "%-7s%-8s%s" % ("", "HOP*", ofields[0])
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
		if numArgs != macro["numArgs"]:
			errors[n].append("Error: " + "Wrong number of macro arguments")
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
						errors[n].append("Error: " + error)
						continue
					operand = "=" + str(value["number"]) + "B" + str(value["scale"])
				if m == 0:
					lhs = fields[0]
				expandedLines[n].append("%-7s%-8s%s" % (lhs, operator, operand))
	elif len(fields) >= 3 and fields[2][:2] == "=(":
		value,error = expression.yaEvaluate(fields[2][1:], constants)
		if error != "":
			errors[n].append("Error: " + error)
		else:
			expandedLines[n] = [line.replace(fields[2], "=" + str(value["number"]) + "B" + str(value["scale"]))]
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
			errors[n].append("Error: Misformed IF")
			continue
		value,error = expression.yaEvaluate(ofields[1], constants)
		if error != "":
			errors[n].append("Error: " + error)
			continue
		constant = constants[ofields[0]]
		if constant["number"] != value["number"] or constant["scale"] != value["scale"]:
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

# Below, except for the final step of producing the assembly listing visually, can just
# loop through all of the lines of code by having an outer loop on all of the elements
# of expandedLines[], and an inner loop on all of the elements of expandedLines[n][].
# For the visual purposes of the assembly listing, it's a bit trickier to try and 
# describe it succinctly, because there are several cases 
# depending on what the preprocessor had done.
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

#----------------------------------------------------------------------------
#           Discovery pass
#----------------------------------------------------------------------------
# The object of this pass is to discover all addresses for left-hand symbols,
# or in other words, to assign an address (HOP constant) to each line of code.
# As far as I know right now, it looks like we can do this in a single pass.   
# The result of the pass is a hopefully easy-to-understand dictionary called 
# inputFile. 

inputFile = []
IM = 0
IS = 0
S = 1
LOC = 0
DM = 0
DS = 0
DLOC = 0

for lineNumber in range(0, len(expandedLines)):
	for line in expandedLines[lineNumber]:
		inputLine = { "raw": line }
		    
		# Split the line into fields.
		if line[:1] in [" ", "\t"] and not line.isspace():
			line = "@" + line
		fields = line.split()
		if len(fields) > 0 and fields[0] == "@":
			fields[0] = ""
		    
		# Remove comments.
		if inputLine["raw"][:1] in ["*", "#"]:
			fields = []
		    
		if len(fields) >= 3:
			ofields = fields[2].split(",")
			if fields[1] == "ORGDD":
				if len(ofields) != 7:
					errors[lineNumber].append("Error: Wrong number of ORGDD arguments")
				else:
					IM = int(ofields[0], 8)
					IS = int(ofields[1], 8)
					S = int(ofields[2], 8)
					LOC = int(ofields[3], 8)
					DM = int(ofields[4], 8)
					DS = int(ofields[5], 8)
					if ofields[6] != "":
						DLOC = int(ofields[6], 8)
			elif fields[1] == "DOGD":
				if len(ofields) != 3:
					errors[lineNumber].append("Error: Wrong number of DOGD arguments")
				else:
					DM = int(ofields[0], 8)
					DS = int(ofields[1], 8)
					if ofields[2] != "":
						DLOC = int(ofields[2], 8)
			elif fields[1] == "BSS":
				inputLine["hop"] = {"IM":IM, "IS":IS, "S":S, "LOC":LOC, "DM":DM, "DS":DS, "DLOC":DLOC}
				DLOC += int(fields[2])
			elif fields[1] in ["DEC", "OCT"]:
				inputLine["hop"] = {"IM":IM, "IS":IS, "S":S, "LOC":LOC, "DM":DM, "DS":DS, "DLOC":DLOC}
				DLOC += 1	
			elif fields[1] in operators:
				if fields[0] != "":
					inputLine["lhs"] = fields[0]
				inputLine["operator"] = fields[1]
				inputLine["operand"] = fields[2]
				inputLine["hop"] = {"IM":IM, "IS":IS, "S":S, "LOC":LOC, "DM":DM, "DS":DS, "DLOC":DLOC}
				LOC += 1
				if fields[1] in ["CDS", "CDSD"]:
					if len(ofields) != 2:
						errors[lineNumber].append("Error: Wrong number of CDS/CDSD arguments")
					else:
						DM = int(ofields[0], 8)
						DS = int(ofields[1], 8)
			elif fields[1] in pseudos:
				errors[lineNumber].append("Error: Unknown pseudo-op")
			else:
				errors[lineNumber].append("Error: Unrecognized operator")
		elif len(fields) != 0:
				errors[lineNumber].append("Wrong number of fields")
		inputFile.append(inputLine)

#----------------------------------------------------------------------------
# If it turns out later that the code above can't assign all HOPs in its
# single pass, insert code to do that here.  However, with my incomplete 
# state of knowledge right now, it doesn't seem as thought that will be
# necessary.

#----------------------------------------------------------------------------
#                           Create a symbol table
#----------------------------------------------------------------------------
# Create a table to quickly look up addresses of symbols.
symbols = {}
for inputLine in inputFile:
	if "lhs" in inputLine:
		if "hop" in inputLine:
			lhs = inputLine["lhs"]
			if lhs in symbols:
				if "error" in inputLine:
					inputLine["error"] += ". " + "Symbol already defined"
				else:
					inputLine["error"] = "Symbol already defined"
			symbols[lhs] = inputLine["hop"]
		else:
			if "error" in inputLine:
				inputLine["error"] += ". " + "Symbol without HOP."
			else:
				inputLine["error"] = "Symbol without HOP."

#----------------------------------------------------------------------------
#                           Complete the assembly
#----------------------------------------------------------------------------
# At this point we have a dictionary called inputFile in which the entire 
# input source file has been parsed into a relatively simple structure.  The
# addresses of all symbols (constants, variables, code) are known.  We should
# therefore be able to actually complete the entire assembly.
print("IM IS S LOC DM DS  A8-A1 A9 OP    CONSTANT    SOURCE STATEMENT")
for inputLine in inputFile:
	if "error" in inputLine:
		print("Error: " + inputLine["error"])
	    
	if "hop" in inputLine:
		hop = inputLine["hop"]
		line = " %o %02o %o %03o  %o %02o %03o  " % (hop["IM"], hop["IS"], hop["S"], 
							hop["LOC"], hop["DM"], 
							hop["DS"], hop["DLOC"])
	else:
		line = "                      "
	    
	if "operator" in inputLine:
		operator = inputLine["operator"]
		if operator == "SHR":
			n = 1
		elif operator == "SHL":
			n = 1
		elif operator == "SHF":
			n = 1
		elif operator == "EXM":
			n = 1
		else:
			n = 1
	    
	print(line + "\t" + inputLine["raw"])

#----------------------------------------------------------------------------
#                           Print a symbol table
#----------------------------------------------------------------------------
print("\n\nSymbol Table:")
for key in sorted(symbols):
	hop = symbols[key]
	print(key + "\t" + " %o %02o %o %03o" % (hop["IM"], hop["IS"], hop["S"], 
						hop["LOC"]))
