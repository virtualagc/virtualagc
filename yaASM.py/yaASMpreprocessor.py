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
#               2023-06-04 RSB  UNLIST/LIST is processed in the assembly pass,
#                               but I had forgotten to remove my early 
#                               misconception of it from the preprocessor.
#               2023-06-06 RSB  Now handles "SHL expression" and "SHR expression".
#               2023-06-17 RSB  Corrected expansion (and formatting) of certain
#                               shift operations.
#               2023-07-03 RSB  Accounted for the syntax 
#                                    IF (EXPRESSION)op(EXPRESSION)
#               2023-07-06 RSB  Implemented mangled names for constants (re: REQ).
#               2023-07-23 RSB  Prevented constant-name mangling in comment
#                               fields.

import re
import copy
from yaASMerrors import *
from yaASMexpression import *
from yaASMdefineMacros import lineSplit

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
mangledSymbols = {} # Track the mangling index for mangled constants.
def preprocessor(lines, expandedLines, constants, macros, ptc=False, \
				 allowUnlist=True):
	global errors, telds
	# The following LVDC instructions may accept operands of the form "=...".
	acceptsEquals = ["AND", "CLA", "DIV", "MPH", "MPY", "RSU", "SUB", "XOR"]

	ampC1 = 0
	ampString = "000"
	ampUsed = False
	inMacro = ""
	ifs = []
	suffix = ""
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
						continue
				elif fields[1] == "MACRO":
					inMacro = fields[0]
			if inMacro != "":
				continue
			
			# Take care of IF/ENDIF.  Note that IF/ENDIF blocks are
			# sometimes nested.
			if len(fields) >= 3 and fields[1] == "IF":
				operand = fields[2]
				comparison = ""
				for c in ["=(", "<(", ">("]:
					if c in operand:
						comparison = c
						break
				if comparison == "":
					addError(n, "Error: Illegal comparison", nn-1)
					continue
				ofields = operand.split(comparison)
				if len(ofields) != 2 or ofields[1][-1] != ")":
					addError(n, "Error: Illegal comparison", nn-1)
					continue
				constant = ofields[0]
				if constant[:1] == "(" and constant[-1:] == ")":
					constantValue,error = yaEvaluate(constant[1:-1], constants)
					if error != "":
						addError(n, "Error: Cannot evaluate expression", nn-1)
						continue
				elif constant not in constants:
					addError(n, "Error: Constant (%s) not found" % constant, nn-1)
					continue
				else:
					constantValue = constants[constant]

				expression = ofields[1][:-1]
				value,error = yaEvaluate(expression, constants)
				if error != "":
					addError(n, "Error: Cannot evaluate expression", nn-1)
					continue
					
				v1 = constantValue["number"]
				v2 = value["number"]
				if "scale" in value or "scale" in constantValue:
					addError(n, "Implementation: Scale in IF condition", nn-1)
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
					addError(n, "Info: ENDIF without IF", nn-1)
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
			
			# Determine the format of the line (.lvdc8 vs .lvdc), in case we need
			# to print something.
			if "\t" in line or " " == line[7]: # .lvdc8 
				fmt = "%-8s%-8s%s"
			else: # .lvdc
				fmt = "%-7s%-8s%s"
				
			# We have a bit of a problem now, in that we have to replace any
			# symbolic constants (other than in comments) with their current 
			# values, recognizing that the constants may be redefined later 
			# via REQ.  If we don't do this now, the assembly pass will have to 
			# do it, but it will have only the final values, not the values
			# at this specific point in the code.  Finding the replacement 
			# points is a big inefficiency. Too bad!  But it's worse than that,
			# since the syntax is going to require that the replacements be
			# decimals in some cases, and octals in others, and we really don't
			# have the parsing smarts to know that at this point.  To get around
			# that, we don't replace the constants with their *values*, but 
			# instead clone the constants with new, mangled names, and replace
			# the constants by their mangled forms.  Yuck!  But the mangled
			# forms won't be REQ'd later, so the assembly pass will at least 
			# evaluate them correctly.  Symbolic names in LVDC assembly language
			# are limited to 6 characters, and obey other rules, but 
			# fortunately, because the mangled names won't appear in the label
			# fields of punchcards, I think we can relax those naming rules.
			# At least as a first cut at it, the mangling will be:
			#		SYMBOL -> SYMBOL#n
			# where n starts at 0 for the first mangling of SYMBOL, 1 for
			# the second mangling, and so on.  That means that at the output
			# stage, if desired, some magic could be done to unmangle SYMBOL#0
			# to just SYMBOL, while retaining SYMBOL##1, SYMBOL##2, and so on.
			# The places where we need to make these replacements are, I 
			# believe, always delimited by (...), though every line may contain
			# several such aread.  We have to find all of them and process them
			# each.  Alas, the simple method I use disallows embedded 
			# parentheses.
			c = 22 # Do a crude check to determine where the comment starts.
			for c in range(16, len(line)):
				if line[c].isspace():
					break
			c += 1
			if c < 23:
				c = 23
			pAreas = []
			for p in re.finditer("\\([^)]*\\)", line[:c]): # Find (...) areas.
				pAreas.append(p.span())
			starts = {}
			for constant in constants:
				if "#" in constant:
					continue
				c = constants[constant]
				if not isinstance(c, dict):
					continue
				if "pat1" not in c:
					noDot = constant.replace(".", "[.]")
					c["pat1"] = re.compile("\\b" + noDot + "[^.A-Z0-9#]")
					c["pat2"] = re.compile("\\b" + noDot + "$")
				for pArea in pAreas:
					matches = c["pat1"].finditer(line[pArea[0]:pArea[1]])
					for match in matches:
						starts[match.span()[0] + pArea[0]] = constant
					match = c["pat2"].search(line[pArea[0]:pArea[1]])
					if match != None:
						starts[match.span()[0]+pArea[0]] = constant
			if len(starts) > 0:
				# At this point, the keys in the dictionary starts{} are the
				# starting positions of all of the matches found in the
				# input line, and the values of those keys are the names
				# of the constant matched.  We simply have to build a
				# replacement input line in which all of the matches have
				# been replaced by mangled constants.  Note that 
				# mangledSymbols[constant][] is a list that tracks all of the
				# values assigned to constant, and a value at position n
				# corresponds to mangled constant#n.
				newLine = ""
				lastEnd = 0
				for start in sorted(starts):
					constant = starts[start]
					c = constants[constant]
					if constant not in mangledSymbols:
						mangledSymbols[constant] = []
					if c not in mangledSymbols[constant]:
						mangledSymbols[constant].append(c)
					index = mangledSymbols[constant].index(c)
					mangled = "%s#%03d" % (constant, index)
					if mangled not in constants:
						constants[mangled] = copy.deepcopy(c)
					newLine = newLine + line[lastEnd:start] + mangled
					lastEnd = start + len(constant)
				newLine = newLine + line[lastEnd:]
				line = newLine
				expandedLines[n][nn-1] = line
				fields = lineSplit(line)
				
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
				if ampUsed:
					ampC1 += 1
					ampString = "%03d" % ampC1
					ampUsed = False
				#print("! M:", line, file=sys.stderr)
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
						# parameter. These formal arguments can appear anywhere
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
							# There's a weird thing in AS-512 ITERATIVE GUIDANCE
							# MODE (and maybe other places for all I know) in
							# which there's line in a macro of the form
							#		MPY     =ARG
							# and a macro invocation in which ARG is 
							#		=1
							# with the net result being that the line expands as
							#		MPY     ==1
							# Which the original assembler apparently allowed.
							# I'm going a crude fix and just convert == to = :
							if replacement[:1] == "=" and "==" in mline:
								mline = mline.replace("==", "=")
							
						macroLine = lineSplit(mline)
						if len(macroLine) < 1 or \
								(len(macroLine) == 1 \
								and macroLine[0][0] in ["*", "#", "$"]):
							continue
						lhs = macroLine[0]
						operator = macroLine[1]
						if operator == "UNLIST" and allowUnlist:
							suffix = unlistSuffix
						if len(macroLine) < 3:
							operand = ""
						else:
							operand = macroLine[2]
						
						if m == 0 and fields[0] != "":
							lhs = fields[0]
						expandedMacro.append(fmt % (lhs, operator, operand) + suffix)
						if operator == "LIST":
							suffix = ""
						#print("! E:", expandedMacro[-1], file=sys.stderr)
					# Replace the macro invocation line itself with the lines 
					# of the expanded macro, and proceed to process from that 
					# point. 
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
			elif (not ptc) and len(fields) >= 3 and fields[1] == "CDS" and \
					fields[2] in constants and \
					type(constants[fields[2]]) == type([]) and \
					len(constants[fields[2]]) >= 3:
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
			elif len(fields) >= 3 and fields[0] != "" and \
					fields[1] in ["EQU", "REQ"]:
				value,error = yaEvaluate(fields[2], constants)
				if error != "":
					addError(n, "Error: " + error)
				else:
					if fields[1] == "EQU" and fields[0] in constants:
						value = constants[fields[0]]
					elif False and fields[1] == "REQ" and \
							fields[0] not in constants:
						addError(n, \
								"Error: Constant does not exist, " + fields[0])
					constants[fields[0]] = value 
					# print("!", fields[0], fields[1], value["number"])
			elif len(fields) >= 3 and fields[1] == "CALL":
				ofields = fields[2].split(",")
				if len(ofields) == 1:
					line1 = fmt % (fields[0], "HOP", ofields[0])
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
			elif len(fields) >= 3 and fields[1] in ["SHL", "SHR"]:
				value, error = yaEvaluate(fields[2], constants)
				if error != "":
					addError(n, "Error: " + error, nn-1)
					count = 0
				else:
					count = value["number"]
					if "scale" in value:
						count *= 2**value["scale"]
					count = hround(count)
				expandedSH = []
				thisLabel = fields[0]
				operator = fields[1]
				if count > 2:
					while count > 0:
						thisCount = maxSHF
						if thisCount > count:
							thisCount = count
						expandedSH.append(fmt % (thisLabel, operator, thisCount))
						thisLabel = ""
						count -= thisCount
				else:
					expandedSH.append(fmt % (thisLabel, operator, count))
				if fields[2] not in ["0", "1", "2"]:
					nn -= 1
					expandedLines[n][nn:nn+1] = expandedSH
					nn += len(expandedSH)
				continue
			elif len(fields) >= 3 and fields[2][:1] == "=" \
					and fields[2][:3] != "=H'" and fields[2][:2] != "=O":
				operand = fields[2]
				if operand[:2] != "=(" and "B(" in operand:
					# This is supposed to detect "=nB(expression)" and turn
					# it into "=(n)B(expression)".
					operand = operand.replace("=", "=(").replace("B(", ")B(")
					#print(fields[2], operand, file=sys.stderr)
				try:
					#print("!##", operand[1:], file=sys.stderr)
					value,error = yaEvaluate(operand[1:], constants)
				except:
					print("Implementation error:", expandedLines[n][nn-1], \
						operand, file=sys.stderr)
					sys.exit(1)
				if error != "":
					addError(n, "Error: " + error)
				else:
					replacement = "=" + str(value["number"]).upper()
					if "scale" in value:
						replacement += "B" + str(value["scale"])
					if replacement != fields[2]:
						nn -= 1
						expandedLines[n][nn] = line.replace(fields[2], \
														replacement)
						continue
	
if False:
	# Just print out some results from the preprocessor and then exit.
	print("Constants:")		
	for n in sorted(constants):
		print("\t" + n + "\t= " + str(constants[n]["number"]) + "B" + \
			str(constants[n]["scale"]))
	print("Macros:")
	for n in sorted(macros):
		print("\t" + n + "\t= " + str(macros[n]))
	print("Expansion:")
	for n in range(0, len(expandedLines)):
		if len(expandedLines[n]) != 1 or lines[n] != expandedLines[n][0]:
			print("\t" + str(n + 1) + ": " + str(expandedLines[n]))
	sys.exit(1)
	
