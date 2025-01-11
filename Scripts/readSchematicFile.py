#!/usr/bin/env python3
# Copyright 2025 Ronald S. Burkey <info@sandroid.org>
# 
# This file is part of yaAGC.
# 
# yaAGC is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
# 
# yaAGC is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with yaAGC; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
# 
# Filename: 	readSchematicFile.py
# Purpose:	Reads a KiCad (version 5- or 6+), but only to the extent required
#				for use of the unformation by dumbVerilog.py.  Normally this
#				is a Python module, but there's a standalone mode for 
#				engineering purposes too.
# Mod history:	2025-01-08 RSB	Split off from dumbVerilog.py

'''
Important note:  As presently implemented, we rely on the assumption that while
digital circuits (i.e., NOR gates) and connectors may reside in sub-sheets of 
the top-level drawing, they cannot reside in reusable blocks implemented as 
separate sheets.  The distinction is that reference designators found in all 
subsheets are used *as-is* rather than being altered according to the particular
block instance.  So if NOR gates (or connectors) appeared in reusable blocks, 
they would have the same reference designators in each instance of the block.  
Which would be bad.  This already happens with analog components such as 
resistors, of course, but we don't care since we're not extracting any info 
about them because they're irrelevant to the Verilog simulation.

The information which `readSchematicFile()` needs to return about the schematic
is minimal, and the info is returned in the 5 global variables `gateLocations`
and `schPadsJ1` through `schPadsJ4`.

`gateLocations` is a dictionary for which the keys are the reference designators
of the NOR gates (suffixed with A or B since dual-NOR chips were used); the 
values for the keys are the so-called location codes.  Recall that each 
NOR gate had a 5-digit location code that was unique throughout the AGC/.

As for `schPadsJx`, it is a list.  The assumption is that there were 4 buses 
used to transfer signals among the AGC's digital modules, labeled (according to
their connector reference designators) as J1 through J4.  Each bus has 72 signals.
The lists `schPadsJx` simply give the net name for each individual signal
on the bus, or "?" if none.

Note, though, that the pin-numbering on connector Jx does not begin at 1.  Rather,
J1 begins at pin 101, J2 begins at pin 201, J3 begins at pin 301, and J4 begins
at pin 401.  Which is convenient for telling at a glance, just from the pin
number, which connector the signal is on.

Thus all `readSchematicFile()` has to do is associate NOR-gate reference 
designators with 5-digit "location" numbers and to determine which signals 
appear at which pins of which connectors.

The schematic 2005250- was used to compare KiCad 5 vs KiCad 6 correct vs
KiCad 6 fast.  They all produce the same result on that test file.
'''

import sys
import os
import time
import re
import tatsu

gateLocations = {}
schPadsJ1 = [ "?" ] * 73
schPadsJ2 = [ "?" ] * 73
schPadsJ3 = [ "?" ] * 73
schPadsJ4 = [ "?" ] * 73

def normalizeCaption(caption):
	if caption[:3] in ["0VD", "+4V", "+4S", "FAP"]:
		return None
	if caption[:1].isdigit():
		caption = "d" + caption
	caption = caption.replace("+", "p").replace("-", "m")
	return caption

# Read KiCad v5 (or earlier, I suppose) files.
def readSchematicFile5(filename, newLines, fast = True):
	inSheet = False
	inComp = False
	inNOR = False
	inConnector = False
	pathName = os.path.dirname(filename)
	if len(pathName) > 0 and not pathName.endswith("/"):
		pathName += "/"
	for rawLine in newLines:
		line = rawLine.strip()
		if line == "$Sheet":
			inSheet = True
			continue
		if line == "$EndSheet":
			inSheet = False
			continue
		if line == "$Comp":
			inComp = True
			refd = ""
			unit = 0
			continue
		if line == "$EndComp":
			inComp = False
			inNOR = False
			inConnector = False
			continue
		if inSheet:
			fields = line.split()
			if len(fields) >= 2 and fields[0] == "F1":
				newFilename = pathName + fields[1].strip("\"")
				readSchematicFile(newFilename, fast)
			continue
		if inComp:
			fields = line.split()
			if len(fields) >= 3 and fields[0] == "L":
				refd = fields[2]
				if fields[1][:5] == "D3NOR":
					inNOR = True
				if fields[1][:18] == "AGC_DSKY:Connector":
					inConnector = True
				if refd == "J1":
					schPads = schPadsJ1
				elif refd == "J2":
					schPads = schPadsJ2
				elif refd == "J3":
					schPads = schPadsJ3
				elif refd == "J4":
					schPads = schPadsJ4
				else:
					schPads = ""
				continue
			if len(fields) >= 2 and fields[0] == "U":
				unitNumber = int(fields[1])
				if inNOR:
					if unitNumber == 1:
						unit = "A"
					else:
						unit = "B"
				continue
			if inNOR and len(fields) >= 11 and fields[0] == "F" and fields[10] == "\"Location\"":
				gate = fields[2].strip("\"")
				gateLocations[refd + unit] = gate
				continue
			if inConnector and len(fields) >= 11 and fields[0] == "F" and fields[10] == "\"Caption\"":
				caption = fields[2].strip("\"")
				caption = normalizeCaption(caption)
				if caption == None:
					continue
				schPads[unitNumber] = caption

'''
Read KiCad v6 or later files.  Two methods are implemented:  the "correct"
method (fast=False) and the "fast" method (fast=True).  The latter is the 
default.

The "correct" method was implemented first.  It creates a set of BNF rules 
(or more accurately, TatSu rules) defining the grammar of a *.kicad_sch file, 
then parses the file according to those rules and then from the parse tree
picks off the very-few data we actually need.  The problem is that it is 
phenominally slow.  For even the tiny testVerilog schematic, it take 8 
seconds (on my computer) to parse it!  A logic module like 2005250- takes
an astounding 2 minutes.  Presumably the problem is the deeply hierarchical 
lisp-like grammar.  

I think the "correct" method could perhaps be sped up to create a "medium"
method (which I haven't done, because it's less simple than it sounds) by just 
stripping off the enclosing 
	(kicad_sch ... )
and then parsing each enclosed member separately. 

The "fast" method does simple pattern-matching to find the data; it takes a 
miniscule fraction of a second. The problem is that it relies on the formatting
(vs the grammar) of the schematic file, and is therefore dependent on "stylistic" 
features that are presumably more likely to change from one version of KiCad to 
another than is the grammar.
'''

# "BNF" rules for the grammar of the KiCad 6 schematic member hierarchy,
# for fast=False. 
grammar6 = '''
@@grammar :: kicad6
@@whitespace :: None
@@parseinfo :: False
@@eol_comments :: /@g@a@r@b@a@g@e@/
nc = /[^"\\\\]/ ;
ec = '\\\\\\\\' | '\\\\"' | '\\\\n' | '\\\\t' ;
ch = nc | ec ;
qs = '"' { ch } '"' ;
uq = /[^\\\\" ()]+/ ;
id = /[a-zA-Z][a-zA-Z_]*/ ;
sp = /[ ]+/ ;
os = /[ ]*/ ;
member = '(' id+: id { sp ( ( uq+: uq ) | ( qs+: qs ) | ( mb+: member ) ) } os ')' ;
'''
# Regex rules for various grammar elements, for fast=True.
unitPattern = r'\(unit ([0-9]+)\)'
refdPattern = r'"Reference" "([^"]+)"'
locationPattern = r'"Location" "([^"]+)"'
captionPattern = r'"Caption" "([^"]*)"'
sheetPattern = r'"Sheet file" "([^"]+)"'
# Compile all of the patterns just defined.
unitParser = re.compile(unitPattern)
refdParser = re.compile(refdPattern)
locationParser = re.compile(locationPattern)
captionParser = re.compile(captionPattern)
sheetParser = re.compile(sheetPattern)
parser6 = tatsu.compile(grammar6)

def readSchematicFile6(newLines, fast = True):
	
	if fast:
		inSymbol = False
		inSheet = False
		unit = None
		refd = None
		location = None
		caption = None
		for line in newLines:
			if line.startswith("  )"):
				if unit != None and refd != None:
					if location != None:
						refd += chr(ord("A") + unit - 1)
						gateLocations[refd] = location
						#print("#DEBUG# Location", refd, unit, location)
					elif caption != None:
						if refd == "J1":
							schPadsJ1[unit] = caption
						elif refd == "J2":
							schPadsJ2[unit] = caption
						elif refd == "J3":
							schPadsJ3[unit] = caption
						elif refd == "J4":
							schPadsJ4[unit] = caption
						#print("#DEBUG# Caption", refd, unit, caption)
				inSymbol = False
				inSheet = False
				unit = None
				refd = None
				location = None
				caption = None
				continue
			if line.startswith("  (symbol "):
				inSymbol = True
			elif line.startswith("  (sheet "):
				inSheet = True
			if not inSymbol and not inSheet:
				continue
			if inSymbol:
				result = unitParser.search(line)
				if result != None:
					unit = int(result.group(1))
				if line.startswith("    (property"):
					result = refdParser.search(line)
					if result != None:
						refd = result.group(1)
					result = locationParser.search(line)
					if result != None:
						location = result.group(1)
					result = captionParser.search(line)
					if result != None:
						caption = result.group(1)
						caption = normalizeCaption(caption)
			elif inSheet:
				result = sheetParser.search(line)
				if result != None:
					subsheetFilename = result.group(1)
					readSchematicFile(subsheetFilename, fast)
	else:
		contents = "".join(newLines).replace("\n", " ")
		try:
			ast = parser6.parse(contents, start="member", whitespace="")
		except:
			print("Implementation error or yntax error in schematic file", file=sys.stderr)
			sys.exit(1)
		members = ast["mb"]
		for m in members:
			if m["id"] == ["symbol"]:
				unit = None
				refd = None
				location = None
				caption = None
				for mb in m["mb"]:
					if mb["id"] == ["unit"]:
						unit = int(mb['uq'][0])
					elif mb["id"] == ["property"] and 'qs' in mb:
						if mb['qs'][0] == ('"', ['R', 'e', 'f', 'e', 'r', 'e', 'n', 'c', 'e'], '"'):
							refd = "".join(mb['qs'][1][1])
						elif mb['qs'][0] == ('"', ['L', 'o', 'c', 'a', 't', 'i', 'o', 'n'], '"'):
							location = "".join(mb['qs'][1][1])
						elif mb['qs'][0] == ('"', ['C', 'a', 'p', 't', 'i', 'o', 'n'], '"'):
							caption = "".join(mb['qs'][1][1])
							caption = normalizeCaption(caption)
							if caption == None:
								break
					if unit != None and refd != None and location != None:
						gateLocations["%s%s" % (refd, chr(ord("A") + unit - 1))] = location
						break
					if unit != None and caption != None:
						if refd == "J1":
							schPadsJ1[unit] = caption
							break
						elif refd == "J2":
							schPadsJ2[unit] = caption
							break
						elif refd == "J3":
							schPadsJ3[unit] = caption
							break
						elif refd == "J4":
							schPadsJ4[unit] = caption
							break
			elif m["id"] == ["sheet"]:
				for mb in m["mb"]:
					if mb["id"] == ["property"] and 'qs' in mb:
						if mb['qs'][0] == ('"', ['S', 'h', 'e', 'e', 't', ' ', 'f', 'i', 'l', 'e'], '"'):
							subsheetFilename = "".join(mb['qs'][1][1])
							readSchematicFile(subsheetFilename, fast)
							break;

def readSchematicFile(filename, fast = True):
	print("Reading file " + filename, file=sys.stderr)
	f = open(filename, "r")
	newLines = f.readlines();
	f.close();
	print(len(newLines), "lines found.", file=sys.stderr)
	if filename.endswith(".sch"):
		readSchematicFile5(filename, newLines, fast)
	elif filename.endswith(".kicad_sch"):
		readSchematicFile6(newLines, fast)
	else:
		print("Can only accept files *.sh (KiCad v5-) or *.kicad_sch (KiCad v6+).", file=sys.stderr)
		sys.exit(1)

if __name__ == "__main__":
	if len(sys.argv) > 1:
		fast = (len(sys.argv) > 2)
		start = time.time()
		readSchematicFile(sys.argv[1], fast=fast)
		end = time.time()
		print("Parsing took %f seconds" % (end-start))
		print("gateLocations =", gateLocations)
		print("schPadsJ1 =", schPadsJ1)
		print("schPadsJ2 =", schPadsJ2)
		print("schPadsJ3 =", schPadsJ3)
		print("schPadsJ4 =", schPadsJ4)
	while True:
		print()
		print("> ", end="")
		line = input().rstrip("\n")
		if len(line) == 0:
			break
		try:
			ast = parser6.parse(line, start="member", whitespace="")
			print(ast)
		except:
			print("Failed!")
		
