#!/usr/bin/env python3
# Copyright 2023 Ronald S. Burkey <info@sandroid.org>
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
# Filename:     yaASMdefineMacros.py
# Purpose:      The portion of yaASM.py's preprocessor that finds and preserves
#               MACRO/ENDMAC definitions. 
# Reference:    http://www.ibibio.org/apollo
# Mods:         2023-05-29 RSB	Split off from yaASMpreprocessor.py.

import sys
from yaASMerrors import addError

# Split a line into fields: [LHS, operator, operand, comment].  Since this
# splitting is by pattern matching with some dependence on column alignment,
# it's not necessarily perfect.  For example, if there's no operand but there
# is a comment, then the first word of the comment will go in the operand
# position and the remainder of the comment will appear in the comment position.
# However, special steps are taken to account for full-line comments, for the
# differences between .lvdc and .lvdc8 formats, and for the fact that columns
# 2-6 may have a sprinkling of "random" * and $ characters.
if False:
	def lineSplit(line):
		if line.strip() == "":
			return []
		if line[:1] in ["*", "#", "$"]:
			return ["", "", "", line.rstrip()]
		field0 = line[:7].rstrip()
		field1 = line[7:].strip().split(None, 2)
		fields = [field0] + field1
		return fields
else:
	def lineSplit(line):
		if line.strip() == "":
			return []
		if line[:1] in ["*", "#", "$"]:
			return ["", "", "", line.rstrip()]
		field0 = line[:7].rstrip()
		# The next few lines attempt to account for lines having no operand
		# but having a comment.  It tries to account for both .lvdc and .lvdc8
		# formats, and assumes that the comment cannot encroach on an 
		# 8-character-wide field representing the operand.
		if len(line) >= 16 and line[15:23].strip() == "":
			line = line[:15] + "@_@" + line[15:]
		field1 = line[7:].strip().split(None, 2)
		if len(field1) >= 2 and field1[1] == "@_@":
			field1[1] = ""
		fields = [field0] + field1
		return fields

# Examine the lines[] array and form the macros{} dictionary from it.
# NOTE:  It's tempting to try and handle UNLIST and LIST here, but don't do it!
#        There are cases in which one but not the other of UNLIST/LIST is 
#        inside of an IF/ENDIF block, and that situation cannot be accounted
#        for here!
def defineMacros(lines, macros):
	inMacro = ""
	inError = False
	
	for n in range(len(lines)):
		line = lines[n].rstrip()
		fields = lineSplit(line)
		
		if inMacro != "":
			if len(fields) >= 2 and fields[1] == "ENDMAC":
				inMacro = ""
				inError = False
			elif inError:
				pass
			elif line[:1] == "#":
				pass
			elif len(fields) == 0:
				pass
			elif len(fields) >= 3 and fields[1] == "SPACE" and fields[2].isdigit():
				spaceCount = int(fields[2])
				while spaceCount > 0:
					macros[inMacro]["lines"].append("")
					spaceCount -= 1
			else:
				macros[inMacro]["lines"].append(line)
			continue
		
		if len(fields) >= 2 and fields[0] != "" and fields[1] == "MACRO":
			inMacro = fields[0]
			inError = False
			if len(inMacro.split()) != 1 or not inMacro[0].isalpha():
				addError(n, "Error: Illegal macro name \"%s\"" % inMacro)
				inError = True
			if inMacro in macros:
				addError(n, "Error: Macro (%s) already exists" % inMacro)
				inError = True
			if not inError:
				if len(fields) == 2 or fields[2] == '':
					numArgs = 0
					formalArgs = []
				else:
					formalArgs = fields[2].split(",")
					numArgs = len(formalArgs)
				macros[inMacro] = { "numArgs": numArgs, "lines": [], 
								"formalArgs" : formalArgs }
			continue
	
	if inMacro != "":
		addError(n, "Error: MACRO (%s) without ENDMAC" % inMacro)
		
	if False:
		for name in macros:
			macro = macros[name]
			print("!", name, macro["formalArgs"], file=sys.stderr)
			for e in macro["lines"]:
				print("!\t%s" % e, file=sys.stderr)
			
