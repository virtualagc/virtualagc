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
# Filename:     yaASMpreprocessor.py
# Purpose:      Preprocessor for yaASM.py. 
# Reference:    http://www.ibibio.org/apollo
# Mods:         2023-05-19 RSB	Split off (as a Python module) from yaASM.py.
#               2023-05-22 RSB	Implemented TELD & TELM.
#               2023-05-23 RSB	CALL with a single parameter.
#               2023-05-26 RSB	Implemented REQ.

import re
from decimal import Decimal, ROUND_HALF_UP
from yaASMerrors import *
from yaASMexpression import *
from yaASMdefineMacros import lineSplit

# Python's native round() function uses a silly method (in the sense that it is
# unlike the expectation of every programmer who ever lived) called "banker's
# rounding", wherein half-integers sometimes round up and sometimes
# round down.  Good for bankers, I suppose, because rounding errors tend to
# sum to zero, but no help whatever for us.  I've stolen the hround() function
# from my Shuttle HAL/S compiler.  It rounds half-integers upward.
def hround(x):
	return int(Decimal(x).to_integral_value(rounding=ROUND_HALF_UP))

# The following are TELemetry Definitions.  The keys are the names, and the
# values are ordered pairs consisting of the delay-mode and the pio-number.
telds = {}

#----------------------------------------------------------------------------
#	Preprocessor pass
#----------------------------------------------------------------------------
# The idea for this pass is to process:
#	EQU and REQ
#	TELD
#	Expansion of TELM
#	Expansion of CALL
#	Expansion of SHL and SHR
#	MACRO, SPACE, UNLIST, LIST
#	Macro expansions
#	Conditional blocks
#	Evaluation of all parenthesized expressions.
# The array expandedLines[] will end up being exactly the same length as lines[],
# and the entries will correspond 1-to-1 to it, but the entries will be arrays of
# replacement lines.  In other words, suppose line=lines[n].  If the preprocessor
# doesn't need to change the line, then expandedLines[n] will be [line].  Suppose
# the preprocessor needs to change line to (say) newLine.  Then expandedLines[n]
# will be [newLine].  Or suppose line contains a macro that the preprocessor 
# expands to line1, line2, and line3.  Then expandedLines[n] will be [line1,line2,line3].
# The errors[] array is also in a similar 1-to-1 relationship, and errors[n] contains 
# an array (hopefully usually empty) of error/warning messages for lines[n].
# Note that lines inside of an UNLIST/LIST block are marked (in expandedLines)
# by being suffixed with unlistSuffix.
unlistSuffix = " " + chr(127)
def preprocessor(lines, expandedLines, constants, macros, ptc=False):
	global errors, telds
	# The following LVDC instructions may accept operands of the form "=...".
	acceptsEquals = ["AND", "CLA", "DIV", "MPH", "MPY", "RSU", "SUB", "XOR"]

	ampC1 = 0
	ampString = "000"
	ampUsed = False
	inMacro = ""
	unlist = False
	ifs = []
	if ptc:
		maxSHF = 6
	else:
		maxSHF = 2
	
	for n in range(0, len(lines)):
		# At this point, expandedLines[n] should be the same as [lines[n]].
		nn = 0
		while nn < len(expandedLines[n]):
			line = expandedLines[n][nn]
			nn += 1
		
			# Don't do any processing in full-line comments.
			if line[:1] in ["*", "#", "$"] or len(line) < 8:
				continue
			
			# Split the line into fields.
			fields = lineSplit(line)
		
			# Don't do any processing within MACRO / ENDMAC definitions, since 
			# that was already done earlier in the defineMacros() pass.  Note
			# that IF/ENDIF blocks can appear within macro definitions, but
			# I've never seen a macro definition within an IF/ENDIF block. If
			# there were such things, I don't think we would process them
			# correctly in defineMacros() anyway.
			if len(fields) >= 2:
				if inMacro != "":
					if fields[1] == "ENDMAC":
						inMacro = ""
						unlist = False
						continue
				elif fields[1] == "MACRO":
					inMacro = fields[0]
					unlist = False
			if inMacro != "":
				continue
			
			# Take care of IF/ENDIF.  Every IF line I've seen so far has one of 
			# the following forms:
			#		IF	constant=(expression)
			#		IF	constant<(expression)
			#		IF	constant>(expression)
			# where expression is usually a literal integer, but is sometimes
			# an actual expression instead. Note that IF/ENDIF blocks are
			# sometimes nested.
			if len(fields) >= 3 and fields[1] == "IF":
				operand = fields[2]
				comparison = ""
				for c in ["=(", "<(", ">("]:
					if c in operand:
						comparison = c
						break
				if comparison == "":
					addError(n, "Error: Illegal comparison", nn)
					continue
				ofields = operand.split(comparison)
				if len(ofields) != 2 or ofields[1][-1] != ")":
					addError(n, "Error: Illegal comparison", nn)
					continue
				constant = ofields[0]
				if constant not in constants:
					addError(n, "Error: Constant (%s) not found" % constant, nn)
					continue

				expression = ofields[1][:-1]
				value,error = yaEvaluate(expression, constants)
				if error != "":
					addError(n, "Error: Cannot evaluate expression", nn)
					continue
					
				v1 = constants[constant]["number"]
				v2 = value["number"]
				if "scale" in value or "scale" in constants[constant]:
					addError(n, "Implementation: Scale in IF condition", nn)
					continue
				isTrue = False
				if comparison == "=(" and v1 == v2:
					isTrue = True
				elif comparison == "<(" and v1 < v2:
					isTrue = True
				elif comparison == ">(" and v1 > v2:
					isTrue = True
				ifs.append(isTrue)
				nn -= 1
				del expandedLines[n][nn]
				continue
			if len(fields) >= 2 and fields[1] == "ENDIF":
				if len(ifs) > 0:
					del ifs[-1]
				else:
					addError(n, "Info: ENDIF without IF", nn)
				nn -= 1
				del expandedLines[n][nn]
				continue
			
			def andIfs(ifs):
				for i in ifs:
					if not i:
						return False
				return True
			
			if not andIfs(ifs):
				nn -= 1
				del expandedLines[n][nn]
				continue
			
			# If we've gotten to this point, we have a line that supposed to be
			# processed.
			
			# Ignore anything in an UNLIST/LIST block.
			if len(fields) >= 2 and fields[1] == "UNLIST":
				if unlist:
					addError(n, "Info: UNLIST was already in effect")
				unlist = True
				expandedLines[n][nn-1] += unlistSuffix
				continue
			elif len(fields) >= 2 and fields[1] == "LIST":
				if not unlist:
					addError(n, "Info: LIST without preceding UNLIST")
				unlist = False
				expandedLines[n][nn-1] += unlistSuffix
				continue
			elif unlist:
				expandedLines[n][nn-1] += unlistSuffix
				continue
	
			# Determine the format of the line (.lvdc8 vs .lvdc), in case we need
			# to print something.
			if "\t" in line or " " == line[7]: # .lvdc8 
				fmt = "%-8s%-8s%s"
			else: # .lvdc
				fmt = "%-7s%-8s%s"
				
			# Expand macro invocations.  Regarding what happens with nested
			# macros, the following expands only one level of macros.  The
			# logic of the containing loop then processes each of the expanded
			# lines in turn, so eventually it will get back to here for any
			# embedded macros, which will be expanded in turn.  So there's no
			# need to try to track arguments across levels, or anything like 
			# that.
			# [Note: I had convinced myself that macros could be nested, but
			# after writing the following code and these comments, I can't
			# actually find any instances in the source code of nesting.  Inside
			# of macros you do have form invocations, TELMs, and so forth, 
			# which are kinds of macro.  It doesn't matter; this code should be
			# fine anyway.  The code for ampC1 will fail if there are nested
			# expansions.] 
			if len(fields) >= 2 and fields[1] in macros:
				unlist = False
				if ampUsed:
					ampC1 += 1
					ampString = "%03d" % ampC1
					ampUsed = False
				#print("M:", line, file=sys.stderr)
				macro = macros[fields[1]]
				if len(fields) >= 3:
					ofields = fields[2].split(",")
				else:
					ofields = []
				numArgs = len(ofields)
				if macro["numArgs"] != 0 and numArgs != macro["numArgs"]:
					addError(n, "Error: " + \
							"Wrong number (%d != %d) of macro arguments: %s" \
							% (numArgs, macro["numArgs"], macro["formalArgs"]))
				else:
					macroLines = macro["lines"]
					formalArgs = macro["formalArgs"]
					numArgs = len(formalArgs)
					expandedMacro = []
					for m in range(0,len(macroLines)):
						# Replace each formal argument with corresponding macro 
						# parameter.these formal arguments can appear anywhere
						# in the line, not just in operand fields.
						mline = macroLines[m]	
						if "&C1" in mline:
							mline = re.sub("&C1", ampString, mline)
							ampUsed = True
						for ii in range(numArgs):
							try:
								pattern = "\\b%s\\b" % formalArgs[ii]
							except:
								print(fields[1], ii, formalArgs, ofields, file=sys.stderr)
								sys.exit(1)
							replacement = ofields[ii]	
							mline = re.sub(pattern, replacement, mline)
							
						macroLine = lineSplit(mline)
						if len(macroLine) < 1 or \
								(len(macroLine) == 1 \
								and macroLine[0][0] in ["*", "#", "$"]):
							continue
						lhs = macroLine[0]
						operator = macroLine[1]
						if len(macroLine) < 3:
							operand = ""
						else:
							operand = macroLine[2]
						
						if m == 0 and fields[0] != "":
							lhs = fields[0]
						expandedMacro.append(fmt % (lhs, operator, operand))
						#print("E:", expandedMacro[-1], file=sys.stderr)
					# Replace the macro invocation line with the lines of the
					# expanded macro, and proceed to process from that point.
					nn -= 1
					expandedLines[n][nn:nn+1] = expandedMacro
					continue
						
			# TELD and TELM
			if len(fields) >= 3 and fields[0] == "" and fields[1] == "TELD":
				subfields = fields[2].split(",")
				if len(subfields) == 3:
					telds[subfields[0]] = ("D.HTR"+subfields[1], subfields[2])
					continue
			if len(fields) >= 3 and fields[1] == "TELM":
				if fields[2] not in telds:
					addError(n, "Error: TELD not found for TELM %s" % fields[2])
					continue
				teld = telds[fields[2]]
				replacement = [
					fmt % ("", "BLOCK", "3"),
					fmt % (fields[0], "HOP", teld[0]),
					fmt % ("", "CLA", fields[2]),
					fmt % ("", "PIO", teld[1])
					]
				#expandedLines[n] = replacement
				nn -= 1
				expandedLines[n][nn:nn+1] = replacement
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
					v = hround(value["number"])
					if v >= 0:
						fields2 = fields2[:index] + ("%d" % v) + fields2[index2:]
					else:
						# We don't want to have constructs like "*+-1", so we
						# want to convert something like that to "*-1".
						if fields2[index-1] == "+":
							c = "-"
						else:
							c = "+"
						v = -v
						fields2 = fields2[:index-1] + c + ("%d" % v) + fields2[index2:]
				if fields2 != fields[2]:
					nn -= 1
					expandedLines[n][nn] = line.replace(fields[2], fields2)
					#fields[2] = fields2
					continue
				
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
				if fields[2] != fields2:
					nn -= 1
					expandedLines[n][nn] = line.replace(fields[2], fields2)
					#fields[2] = fields2
					continue
		
			if len(fields) >= 3 and fields[0] != "" and fields[1] in ["DEQD", "DEQS"]:
				constants[fields[0]] = [fields[1]] + fields[2].split(",")
			elif ptc and len(fields) >= 3 and fields[1] == "CDS" and 2 == len(fields[2].split(",")):
				'''
				subfields = fields[2].split(",")
				line = fmt % (fields[0], fields[1], "%s,%s" % (subfields[0], subfields[1]))
				nn -= 1
				expandedLines[n][nn] = line
				continue
				'''
				pass
			elif (not ptc) and len(fields) >= 3 and fields[1] == "CDS" and fields[2] in constants and type(constants[fields[2]]) == type([]) and len(constants[fields[2]]) >= 3:
				constant = constants[fields[2]]
				op = fields[1]
				if constant[0] == "DEQS":
					op = "CDSS"
				elif constant[0] == "DEQD":
					op = "CDSD"
				line = fmt % (fields[0], op, "%s,%s" % (constant[1], constant[2]))
				nn -= 1
				expandedLines[n][nn] = line
				continue
			elif len(fields) >= 3 and fields[0] != "" \
					and fields[1] in ["EQU", "REQ"]:
				value,error = yaEvaluate(fields[2], constants)
				if error != "":
					addError(n, "Error: " + error)
				else:
					if fields[1] == "EQU" and fields[0] in constants:
						value = constants[fields[0]]
					elif False and fields[1] == "REQ" and fields[0] not in constants:
						addError(n, "Error: Constant does not exist, " + fields[0])
					constants[fields[0]] = value 
			elif len(fields) >= 3 and fields[1] == "CALL":
				ofields = fields[2].split(",")
				if len(ofields) == 1:
					line1 = fmt % ("", "HOP", ofields[0])
					nn -= 1
					expandedLines[n][nn] = line1
					continue
				elif len(ofields) == 2:
					line1 = fmt % (fields[0], "CLA", ofields[1])
					line2 = fmt % ("", "HOP", ofields[0])
					nn -= 1
					expandedLines[n][nn:nn+1] = [line1, line2]
					continue
				elif len(ofields) == 3:
					line1 = fmt % (fields[0], "CLA", ofields[2])
					line2 = fmt % ("", "STO", "775")
					line3 = fmt % ("", "CLA", ofields[1])
					line4 = fmt % ("", "HOP", ofields[0])
					nn -= 1
					expandedLines[n][nn:nn+1] = [line1, line2, line3, line4]
					continue
			elif len(fields) >= 3 and fields[1] in ["SHL", "SHR"] and fields[2].isdigit():
				count = int(fields[2])
				expandedLines[n] = []
				thisLabel = fields[0]
				operator = fields[1]
				expandedSH = []
				if count == 0:
					expandedSH.append("%-8s%-8s0" % (thisLabel, operator))
				else:
					while count > 0:
						thisCount = maxSHF
						if thisCount > count:
							thisCount = count
						expandedSH.append("%-8s%-8s%d" % (thisLabel, operator, thisCount))
						thisLabel = ""
						count -= thisCount
				nn -= 1
				expandedLines[n][nn:nn+1] = expandedSH
				nn += len(expandedSH)
				continue
			elif len(fields) >= 3 and fields[2][:2] == "=(":
				value,error = yaEvaluate(fields[2][1:], constants)
				if error != "":
					addError(n, "Error: " + error)
				else:
					replacement = "=" + str(value["number"]).upper()
					if "scale" in value:
						replacement += "B" + str(value["scale"])
					if replacement != fields[2]:
						nn -= 1
						expandedLines[n][nn] = line.replace(fields[2], replacement)
						continue
	
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
	
