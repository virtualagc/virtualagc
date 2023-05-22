#!/usr/bin/env python3
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
# Filename:    	yaASMpreprocessor.py
# Purpose:     	Preprocessor for yaASM.py. 
# Reference:   	http://www.ibibio.org/apollo
# Mods:        	2023-05-19 RSB	Split off (as a Python module) from yaASM.py.
#               2023-05-22 RSB	Implemented TELD & TELM.

from yaASMerrors import *
from yaASMexpression import *

# The following are TELemetry Definitions.  The keys are the names, and the
# values are ordered pairs consisting of the delay-mode and the pio-number.
telds = {}

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
def preprocessor(lines, expandedLines, constants, macros, \
				ptc=False, inMacro="", inFalseIf = False):
	global errors, telds
	if ptc:
		maxSHF = 6
	else:
		maxSHF = 2
	for n in range(0, len(lines)):
		line = lines[n]
		errors.append([])
		expandedLines.append([line])
		
		if line[:1] in ["*", "#", "$"] or len(line) < 8:
			continue
		
		# Split the line into fields.
		if line[:1] in [" ", "\t"] and not line.isspace():
			line = "@" + line
		fields = line.split()
		if len(fields) > 0 and fields[0] == "@":
			fields[0] = ""
			line = line[1:]
	
		if "\t" in line or " " == line[7]: # .lvdc8 
			fmt = "%-8s%-8s%s"
		else: # .lvdc
			fmt = "%-7s%-8s%s"
			
		# TELD and TELM
		if len(fields) >= 3 and fields[0] == "" and fields[1] == "TELD":
			subfields = fields[2].split(",")
			if len(subfields) == 3:
				telds[subfields[0]] = ("D.HTR"+subfields[1], subfields[2])
				continue
		if len(fields) >= 3 and fields[1] == "TELM" and fields[2] in telds:
			teld = telds[fields[2]]
			expandedLines[n] = [
				fmt % ("", "BLOCK", "3"),
				fmt % (fields[0], "HOP", teld[0]),
				fmt % ("", "CLA", fields[2]),
				fmt % ("", "PIO", teld[1])
				]
			continue
	
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
				continue
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
		elif ptc and len(fields) >= 3 and fields[1] == "CDS" and 2 == len(fields[2].split(",")):
			subfields = fields[2].split(",")
			line = fmt % (fields[0], fields[1], "%s,%s" % (subfields[0], subfields[1]))
			expandedLines[n] = [line]
		elif (not ptc) and len(fields) >= 3 and fields[1] == "CDS" and fields[2] in constants and type(constants[fields[2]]) == type([]) and len(constants[fields[2]]) >= 3:
			constant = constants[fields[2]]
			op = fields[1]
			if constant[0] == "DEQS":
				op = "CDSS"
			elif constant[0] == "DEQD":
				op = "CDSD"
			line = fmt % (fields[0], op, "%s,%s" % (constant[1], constant[2]))
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
				line1 = fmt % (fields[0], "CLA", ofields[1])
				line2 = fmt % ("", "HOP", ofields[0])
				expandedLines[n] = [line1, line2]
			elif len(ofields) == 3:
				line1 = fmt % (fields[0], "CLA", ofields[2])
				line2 = fmt % ("", "STO", "775")
				line3 = fmt % ("", "CLA", ofields[1])
				line4 = fmt % ("", "HOP", ofields[0])
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
					thisCount = maxSHF
					if thisCount > count:
						thisCount = count
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
					if len(macroLine) < 1:
						continue
					lhs = ""
					operator = macroLine[1]
					if len(macroLine) < 3:
						# The only case I know of in which this can happen is for
						# an ENDIF.
						operand = ""
					else:
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
					expandedLines[n].append(fmt % (lhs, operator, operand))
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
	
