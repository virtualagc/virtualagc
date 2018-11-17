#! /usr/bin/python2
# Copyright 2018 Ronald S. Burkey <info@sandroid.org>
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
# Filename: 	autoplaceKiCad.py
# Purpose:	Turns a textual description of AGC NOR-gates and connectors
#		into a KiCad .sch file with those symbols coarsely placed
#		into the correct regions of the drawing.  This is part of
#		my workflow for transcribing scanned logic-flow diagrams
#		into KiCad.
# Mod history:	2018-07-29 RSB	First time I remembered to add the GPL and
#				other boilerplate at the top of the file.
#		2018-08-06 RSB	Added the auto-increment feature for N and
#				J.
#		2018-10-18 RSB	Added connector A52.
#		2018-11-09 RSB	Added K and k.
#		2018-11-16 RSB	Added block1
#
# The purpose of this python script is to take a text file that has some
# descriptions of NOR gates, expander gates, connector pads, nodes,
# and perhaps other objects commonly in AGC "logic flow diagrams", and
# produces a rough placement of those objects into an otherwise empty
# .sch file.  
#
# IMPORTANT:  The temptation is to use eeschema's "Import" feature to
# bring the symbols into the schematic where you want them to reside,
# which is why I actually implemented it this way.  DON'T DO IT!
# The Import feature will replace all of your reference designators with
# U? or J?, and that's definitely not what you want to do!
#
# Usage:
#	autoplaceKiCad.py <input.autoplace >output.sch

import sys
import time
import re

wereErrors = False

# Current origin and index around the origin.
columns = 0
xSpacing = 1.775 # inches
ySpacing = 0.8
originX = 0 # inches
originY = 0
nextX = 0
nextY = 0
def nextXY():
	global nextX, nextY
	if columns == 0:
		if nextX == 0:
			nextX = nextY + 1
			nextY = 0
			return
		if nextY < nextX:
			nextY += 1
			return
		nextX -= 1
	else:
		nextX += 1
		if nextX >= columns:
			nextX = 0
			nextY += 1
	return

# For entities with no obvious sequencing.
index = 0

# A dictionary for storing the objects in the schematic.
objects = {}
gatesFound = {}

nors = { 
	"N": { "library": "D3NOR-+4VDC-0VDCA", "refdPrefix": "U1" },
	"X": { "library": "D3NOR-FAP-0VDCA-expander", "refdPrefix": "U1" }, 
	"N2": { "library": "D3NOR-+4VDC-0VDCA", "refdPrefix": "U1" }
}
aPins = ["A", "B", "C", "_"]
bPins = ["D", "E", "F", "_"]

gateNumber = 0
locationNumber = 1
padNumber = 1
module = "X"
moduleA52 = False
block1 = False

# Read the input file.
for line in sys.stdin:
	line = re.sub(' +', ' ', line.strip())
	# print >>sys.stderr, "Processing: " + line
	fields = line.split(" ")
	numFields = len(fields)
	if line == "":
		continue
	type = fields[0]
	if numFields < 1 or type == "#":
		continue
	if type == "block1":
		block1 = True
		continue
	if type == "module=" and numFields == 2:
		module = fields[1]
		if module == "A52":
			moduleA52 = True
			aPins = ["6", "7", "8", "_"]
			bPins = ["4", "3", "2", "_"]
		continue
	if type == "G=" and numFields == 2:
		gateNumber = int(fields[1])
		continue
	if type == "J=" and numFields == 2:
		padNumber = int(fields[1])
		continue
	if type == "C=" and numFields == 2:
		columns = int(fields[1])
		continue
	if type == "W=" and numFields == 2:
		columns = int(float(fields[1]) / xSpacing)
		continue
	if type == "N=" and numFields == 3:
		nors["N"]["library"] = fields[1]
		nors["N"]["refdPrefix"] = fields[2]
		continue
	if type == "N2=" and numFields == 3:
		nors["N2"]["library"] = fields[1]
		nors["N2"]["refdPrefix"] = fields[2]
		continue
	if type == "X=" and numFields == 3:
		nors["X"]["library"] = fields[1]
		nors["X"]["refdPrefix"] = fields[2]
		continue
	if type == "X2=" and numFields == 3:
		nors["X2"]["library"] = fields[1]
		nors["X2"]["refdPrefix"] = fields[2]
		continue
	if type == "L" and numFields == 3:
		originX = float(fields[1]) + xSpacing / 2.0
		originY = float(fields[2]) + ySpacing / 2.0
		nextX = 0
		nextY = 0
		continue

	posX = 25 * int(40 * (originX + xSpacing * nextX))
	posY = 25 * int(40 * (originY + ySpacing * nextY))
	
	if block1 and type in nors and numFields == 5:
		gate = fields[1]
		top = fields[2]
		middle = fields[3]
		bottom = fields[4]
		if top == ";":
			top = "_"
		if middle == ";":
			middle = "_"
		if bottom == ";":
			bottom = "_"
		if top not in aPins or middle not in aPins or bottom not in aPins:
			print >>sys.stderr, "Incorrect pin numbers: " + line
			wereErrors = True
			continue
		if (top == middle and top != "_") or (top == bottom and top != "_") or (middle == bottom and middle != "_"):
			print >>sys.stderr, "Duplicate pins: " + line
			wereErrors = True
			continue
		if len(gate) != 5 or not gate.isdigit():
			print >>sys.stderr, "Incorrectly numbered gate: " + line
			wereErrors = True
			continue
		id = "g" + gate
		whichGate = "a"
		gatesFound[gate] = line
		objects[id] = { "type": type, "library": nors[type]["library"], "refd": nors[type]["refdPrefix"]+"?", "location":"XX" }
		objects[id][whichGate] = { "gate": gate, "top": top, "middle": middle, "bottom": bottom, "x": posX, "y": posY } 
		nextXY()
		continue
		
	
	if type in nors and numFields == 3 and fields[1] == "." and fields[2] in ["1", "2", "3"] and not moduleA52:
		numInputs = int(fields[2])
		fields[1] = str(gateNumber)
		even = ((gateNumber & 1) == 0) 
		if locationNumber < 10:
			fields[2] = "0" + str(locationNumber)
		else:
			fields[2] = str(locationNumber)
		if numInputs == 1:
			if even:
				fields.append("_")
				fields.append("E")
				fields.append("_")
			else:
				fields.append("_")
				fields.append("B")
				fields.append("_")
		elif numInputs == 2:
			if even:
				fields.append("D")
				fields.append("_")
				fields.append("F")
			else:
				fields.append("A")
				fields.append("_")
				fields.append("C")
		else:
			if even:
				fields.append("D")
				fields.append("E")
				fields.append("F")
			else:
				fields.append("A")
				fields.append("B")
				fields.append("C")
		if even:
			locationNumber += 1
		gateNumber += 1
		numFields = 6
	
	if type in nors and numFields == 6 and fields[1].isdigit() and fields[2].isdigit() and not moduleA52:
		gate = fields[1]
		if len(gate) != 5 or not gate.isdigit():
			print >>sys.stderr, "Incorrectly numbered gate: " + line
			wereErrors = True
			continue
		location = fields[2]
		if len(location) != 2 or not location.isdigit():
			print >>sys.stderr, "Incorrectly numbered location: " + line
			wereErrors = True
			continue
		top = fields[3]
		middle = fields[4]
		bottom = fields[5]
		if top == ";":
			top = "_"
		if middle == ";":
			middle = "_"
		if bottom == ";":
			bottom = "_"
		if (top == middle and top != "_") or (top == bottom and top != "_") or (middle == bottom and middle != "_"):
			print >>sys.stderr, "Duplicate pins: " + line
			wereErrors = True
			continue
		id = type + location
		if type == "N":
			otype = "X"
		else:
			otype = "N"
		oid = otype + location
		if oid in objects:
			print >>sys.stderr, "Library Mismatch: " + line
			print >>sys.stderr, objects[oid]
			wereErrors = True
			continue
		elif not (id in objects):
			objects[id] = { "type": type, "library": nors[type]["library"], "refd": nors[type]["refdPrefix"]+location, "location": location }
		elif objects[id]["library"] != nors[type]["library"]:
			print >>sys.stderr, "A/B Library Mismatch: " + line
			print >>sys.stderr, objects[id]
			wereErrors = True
			continue
		if top in aPins and middle in aPins and bottom in aPins:
			whichGate = "a"
		elif top in bPins and middle in bPins and bottom in bPins:
			whichGate = "b"
		else:
			print >>sys.stderr, "Illegal NOR spec: " + line
			wereErrors = True
			continue
		if whichGate in objects[id]:
			print >>sys.stderr, "Part duplicated: " + line
			print >>sys.stderr, objects[id][whichGate]
			wereErrors = True
			continue
		if gate in gatesFound:
			print >>sys.stderr, "Gate number duplicated: " + line
			print >>sys.stderr, gatesFound[gate]
			wereErrors = True
			continue
		gatesFound[gate] = line
		objects[id][whichGate] = { "gate": gate, "top": top, "middle": middle, "bottom": bottom, "x": posX, "y": posY } 
		nextXY()
		continue
	
	if type in nors and numFields == 5 and fields[1][:-1].isdigit() and fields[1][-1:] in ["A", "B"] and moduleA52:
		marking = fields[1]
		markingNumber = fields[1][:-1]
		markingLetter = fields[1][-1:]
		gate = gateNumber + int(markingNumber) * 2
		if markingLetter != "A":
			gate += 1
		gate = str(gate)
		if len(markingNumber) < 2:
			location = "0" + markingNumber
		else:
			location = markingNumber
		top = fields[2]
		middle = fields[3]
		bottom = fields[4]
		if top == ";":
			top = "_"
		if middle == ";":
			middle = "_"
		if bottom == ";":
			bottom = "_"
		if (top == middle and top != "_") or (top == bottom and top != "_") or (middle == bottom and middle != "_"):
			print >>sys.stderr, "Duplicate pins: " + line
			wereErrors = True
			continue
		id = type + location
		if type == "N":
			otype = "X"
		else:
			otype = "N"
		oid = otype + location
		if oid in objects:
			print >>sys.stderr, "Library Mismatch: " + line
			print >>sys.stderr, objects[oid]
			wereErrors = True
			continue
		elif not (id in objects):
			objects[id] = { "type": type, "library": nors[type]["library"], "refd": nors[type]["refdPrefix"]+location, "location": location }
		elif objects[id]["library"] != nors[type]["library"]:
			print >>sys.stderr, "A/B Library Mismatch: " + line
			print >>sys.stderr, objects[id]
			wereErrors = True
			continue
		if top in aPins and middle in aPins and bottom in aPins:
			whichGate = "a"
		elif top in bPins and middle in bPins and bottom in bPins:
			whichGate = "b"
		else:
			print >>sys.stderr, "Illegal NOR spec: " + line
			wereErrors = True
			continue
		if whichGate in objects[id]:
			print >>sys.stderr, "Part duplicated: " + line
			print >>sys.stderr, objects[id][whichGate]
			wereErrors = True
			continue
		if gate in gatesFound:
			print >>sys.stderr, "Gate number duplicated: " + line
			print >>sys.stderr, gatesFound[gate]
			wereErrors = True
			continue
		gatesFound[gate] = line
		objects[id][whichGate] = { "gate": gate, "top": top, "middle": middle, "bottom": bottom, "x": posX, "y": posY, "marking":marking } 
		nextXY()
		continue
	
	if type in ['J', 'j', 'K', 'k'] and numFields >= 2 and numFields <= 5 and (fields[1].isdigit() or fields[1] == "."):
		if fields[1] == ".":
			fields[1] = str(padNumber)
			padNumber += 1
			remainder = padNumber % 100
			if remainder in [21, 51]:
				padNumber += 1
			if remainder == 72:
				padNumber += 29
		rotated = False
		up = False
		down = False
		if type == "j":
			rotated = True
		elif type == "K":
			down = True
		elif type == "k":
			up = True
		type = "J"
		pinName = fields[1]
		if (len(pinName) != 3 and not block1) or not pinName.isdigit():
			print >>sys.stderr, "Incorrectly numbered connector: " + line
			wereErrors = True
			continue
		pinNum = int(pinName)
		if numFields >= 5:
			text3 = fields[4]
		else:
			text3 = ""
		if numFields >= 4:
			text2 = fields[3]
		else:
			text2 = ""
		if numFields >= 3:
			text = fields[2]
		else:
			text = ""
		id = type + pinName
		if block1:
			refd = "J1"
			symbol = "ConnectorGeneric"
			unit = pinNum
		elif moduleA52:
			refd = "J1"
			symbol = "ConnectorA52"
			quotient = (pinNum // 100) - 1
			remainder = pinNum % 100
			unit = 16 * quotient + remainder 
		elif module == "B1" and pinNum >= 101 and pinNum <= 124:
			refd = "J1"
			symbol = "ConnectorB1-100"
			unit = pinNum % 100
		elif module == "B1" and pinNum >= 201 and pinNum <= 224:
			refd = "J2"
			symbol = "ConnectorB1-200"
			unit = pinNum % 100
		elif module == "B1" and pinNum >= 301 and pinNum <= 324:
			refd = "J3"
			symbol = "ConnectorB1-300"
			unit = pinNum % 100
		elif module == "B1" and pinNum >= 401 and pinNum <= 424:
			refd = "J4"
			symbol = "ConnectorB1-400"
			unit = pinNum % 100
		elif module[0] == "B" and pinNum >= 101 and pinNum <= 169:
			# Note that these B-module cases do not cover the case of B7, which isn't
			# supported.
			refd = "J1"
			symbol = "ConnectorB8-100"
			unit = pinNum % 100
		elif module[0] == "B" and pinNum >= 201 and pinNum <= 269:
			refd = "J2"
			symbol = "ConnectorB8-200"
			unit = pinNum % 100
		elif pinNum >= 101 and pinNum <= 171:
			refd = "J1"
			symbol = "ConnectorA1-100"
			unit = pinNum % 100
		elif pinNum >= 201 and pinNum <= 271:
			refd = "J2"
			symbol = "ConnectorA1-200"
			unit = pinNum % 100
		elif pinNum >= 301 and pinNum <= 371:
			refd = "J3"
			symbol = "ConnectorA1-300"
			unit = pinNum % 100
		elif pinNum >= 401 and pinNum <= 471:
			refd = "J4"
			symbol = "ConnectorA1-400"
			unit = pinNum % 100
		else:
			print >>sys.stderr, "Illegal pin number: " + line
			wereErrors = True
			continue
		if id in objects:
			print >>sys.stderr, "Part duplicated: " + line
			print >>sys.stderr, objects[id]
			wereErrors = True
			continue
		objects[id] = { "type": type, "refd": refd, "symbol": symbol, "unit": unit, "text": text, "text2": text2, "text3": text3, "x": posX, "y": posY, "rotated": rotated, "down": down, "up": up }
		nextXY()
		continue
	
	if type == "O" and numFields in [2, 3]:
		id = type + str(index)
		index += 1
		text = fields[1]
		text2 = ""
		if numFields > 2:
			text2 = fields[2]
		objects[id] = { "type": type, "text": text, "text2": text2, "x": posX, "y": posY }
		nextXY()
		continue
	
	if type == "A" and numFields == 2 and fields[1].isdigit():
		id = type + str(index)
		index += 1
		count = "(" + fields[1] + ")"
		objects[id] = { "type": type, "count": count, "x": posX, "y": posY }
		nextXY()
		continue		
	
	print >>sys.stderr, "Unrecognized line: " + line
	wereErrors = True

if wereErrors:
	sys.exit()

# Write the output file.
timestampValue = time.time()
def timestamp():
	global timestampValue
	timestampValue += 1
	return "%X" % timestampValue
print "EESchema Schematic File Version 4"
print "LIBS:module-cache"
print "EELAYER 26 0"
print "EELAYER END"
print "$Descr User 100000 34000"
print "encoding utf-8"
print "Sheet 1 1"
print "Title \"\""
print "Date \"\""
print "Rev \"\""
print "Comp \"\""
print "Comment1 \"\""
print "Comment2 \"\""
print "Comment3 \"\""
print "Comment4 \"\""
print "$EndDescr"
for id in objects:
	object = objects[id]
	type = object["type"]
	# print >>sys.stderr, "Outputting: " + object
	
	if type in nors:
		library = object["library"]
		refd = object["refd"]
		location = object["location"]
		aMirror = False
		bMirror = False
		if block1:
			aFootprint = "ABC"
			bFootprint = "___"
		elif moduleA52:
			aFootprint = "678"
			bFootprint = "234"
		else:
			aFootprint = "ABC"
			bFootprint = "DEF"
		fontSize = 140
		xOffset = 0
		if type in ["X", "X2"]:
		  fontSize = 130
		  xOffset = -75
		if "a" in object:
			aObject = object["a"]
			if aObject["top"] < aObject["bottom"]:
				aFootprint = aObject["top"] + aObject["middle"] + aObject["bottom"]
			else:
				aFootprint = aObject["bottom"] + aObject["middle"] + aObject["top"]
				aMirror = True
		if "b" in object:
			bObject = object["b"]
			if bObject["top"] < bObject["bottom"]:
				bFootprint = bObject["top"] + bObject["middle"] + bObject["bottom"]
			else:
				bFootprint = bObject["bottom"] + bObject["middle"] + bObject["top"]
				bMirror = True
		local_library = library
		symbol = library + '-' + aFootprint + '-' + bFootprint
		if "a" in object:
			unit = 1
			posX = aObject["x"]
			posY = aObject["y"]
			if aMirror:
				locationOffset = 200
			else:
				locationOffset = -200
			sys.stdout.write("$Comp\n")
			sys.stdout.write("L " + local_library + ":" + symbol + " " + refd + "\n")
			sys.stdout.write("U 1 1 " + timestamp() + "\n")
			sys.stdout.write("P " + str(posX) + " " + str(posY) + "\n")
			sys.stdout.write("F 0 \"" + refd + "\" H " + str(posX) + " " + str(posY + 325) + " 140 0001 C CNB\n")
			sys.stdout.write("F 1 \"" + symbol + "\" H " + str(posX) + " " + str(posY+425) + " 140 0001 C CNN\n")
			sys.stdout.write("F 2 \"\" H " + str(posX) + " " + str(posY+475) + " 140 0001 C CNN\n")
			sys.stdout.write("F 3 \"\" H " + str(posX) + " " + str(posY+475) + " 140 0001 C CNN\n")
			if block1:
				sys.stdout.write("F 4 \"" + aObject["gate"] + "\" H " + str(posX + xOffset) + " " + str(posY) + " " + str(fontSize) + " 0000 C CNB \"Location\"\n")
			elif moduleA52:
				sys.stdout.write("F 4 \"" + aObject["gate"] + "\" H " + str(posX + xOffset) + " " + str(posY) + " " + str(fontSize) + " 0001 C CNB \"Location\"\n")
				sys.stdout.write("F 5 \"" + location + "\" H " + str(posX + xOffset) + " " + str(posY + locationOffset) + " " + str(fontSize) + " 0001 C CNB \"Location2\"\n")
				sys.stdout.write("F 6 \"" + aObject["marking"] + "\" H " + str(posX + xOffset) + " " + str(posY) + " " + str(fontSize) + " 0000 C CNB \"Location3\"\n")
			else:
				sys.stdout.write("F 4 \"" + aObject["gate"] + "\" H " + str(posX + xOffset) + " " + str(posY) + " " + str(fontSize) + " 0000 C CNB \"Location\"\n")
				sys.stdout.write("F 5 \"" + location + "\" H " + str(posX + xOffset) + " " + str(posY + locationOffset) + " " + str(fontSize) + " 0000 C CNB \"Location2\"\n")
			sys.stdout.write("\t" + str(unit) + " " + str(posX) + " " + str(posY) + "\n")
			if aMirror:
				sys.stdout.write("\t1    0    0    1  \n")
			else:
				sys.stdout.write("\t1    0    0    -1  \n")
			sys.stdout.write("$EndComp\n")
		if "b" in object:
			unit = 2
			posX = bObject["x"]
			posY = bObject["y"]
			if bMirror:
				locationOffset = 200
			else:
				locationOffset = -200
			sys.stdout.write("$Comp\n")
			sys.stdout.write("L " + library + ":" + symbol + " " + refd + "\n")
			sys.stdout.write("U 2 1 " + timestamp() + "\n")
			sys.stdout.write("P " + str(posX) + " " + str(posY) + "\n")
			sys.stdout.write("F 0 \"" + refd + "\" H " + str(posX) + " " + str(posY + 325) + " 140 0001 C CNB\n")
			sys.stdout.write("F 1 \"" + symbol + "\" H " + str(posX) + " " + str(posY+425) + " 140 0001 C CNN\n")
			sys.stdout.write("F 2 \"\" H " + str(posX) + " " + str(posY+475) + " 140 0001 C CNN\n")
			sys.stdout.write("F 3 \"\" H " + str(posX) + " " + str(posY+475) + " 140 0001 C CNN\n")
			if moduleA52:
				sys.stdout.write("F 4 \"" + bObject["gate"] + "\" H " + str(posX + xOffset) + " " + str(posY) + " " + str(fontSize) + " 0001 C CNB \"Location\"\n")
				sys.stdout.write("F 5 \"" + location + "\" H " + str(posX + xOffset) + " " + str(posY + locationOffset) + " " + str(fontSize) + " 0001 C CNB \"Location2\"\n")
				sys.stdout.write("F 6 \"" + bObject["marking"] + "\" H " + str(posX + xOffset) + " " + str(posY) + " " + str(fontSize) + " 0000 C CNB \"Location3\"\n")
			else:
				sys.stdout.write("F 4 \"" + bObject["gate"] + "\" H " + str(posX + xOffset) + " " + str(posY) + " " + str(fontSize) + " 0000 C CNB \"Location\"\n")
				sys.stdout.write("F 5 \"" + location + "\" H " + str(posX + xOffset) + " " + str(posY + locationOffset) + " " + str(fontSize) + " 0000 C CNB \"Location2\"\n")
			sys.stdout.write("\t" + str(unit) + " " + str(posX) + " " + str(posY) + "\n")
			if bMirror:
				sys.stdout.write("\t1    0    0    1  \n")
			else:
				sys.stdout.write("\t1    0    0    -1  \n")
			sys.stdout.write("$EndComp\n")
		continue
	
	if type == "J":
		up = object["up"]
		down = object["down"]
		if up or down:
			demorgan = "2"
			
		else:
			demorgan = "1"
		inverted = False
		posX = object["x"]
		posY = object["y"]
		symbol = object["symbol"]
		refd = object["refd"]
		unit = object["unit"]
		caption = object["text"]
		caption2 = object["text2"]
		caption3 = object["text3"]
		rotated = object["rotated"]
		sys.stdout.write("$Comp\n")
		sys.stdout.write("L AGC_DSKY:" + symbol + " " + refd + "\n")
		sys.stdout.write("U " + str(unit) + " " + demorgan + " " + timestamp() + "\n")
		sys.stdout.write("P " + str(posX) + " " + str(posY) + "\n")
		sys.stdout.write("F 0 \"" + refd + "\" H " + str(posX) + " " + str(posY + 325) + " 140 0001 C CNN\n")
		sys.stdout.write("F 1 \"" + symbol + "\" H " + str(posX) + " " + str(posY+425) + " 140 0001 C CNN\n")
		sys.stdout.write("F 2 \"\" H " + str(posX) + " " + str(posY+475) + " 140 0001 C CNN\n")
		sys.stdout.write("F 3 \"\" H " + str(posX) + " " + str(posY+475) + " 140 0001 C CNN\n")
		if caption3 != "":
			if rotated:
				rotated = 0
				inverted = True
			if down:
				sys.stdout.write("F 4 \"" + caption + "\" H " + str(posX) + " " + str(posY - 675) + " 140 0000 C TNB \"Caption\"\n")
				sys.stdout.write("F 5 \"" + caption2 + "\" H " + str(posX) + " " + str(posY - 450) + " 140 0000 C TNB \"Caption2\"\n")
				sys.stdout.write("F 6 \"" + caption3 + "\" H " + str(posX) + " " + str(posY - 225) + " 140 0000 C TNB \"Caption3\"\n")
			elif up:
				sys.stdout.write("F 4 \"" + caption + "\" H " + str(posX) + " " + str(posY - 225) + " 140 0000 C TNB \"Caption\"\n")
				sys.stdout.write("F 5 \"" + caption2 + "\" H " + str(posX) + " " + str(posY - 450) + " 140 0000 C TNB \"Caption2\"\n")
				sys.stdout.write("F 6 \"" + caption3 + "\" H " + str(posX) + " " + str(posY - 675) + " 140 0000 C TNB \"Caption3\"\n")
			else:
				sys.stdout.write("F 4 \"" + caption + "\" H " + str(posX-425) + " " + str(posY + 175) + " 140 0000 R BNB \"Caption\"\n")
				sys.stdout.write("F 5 \"" + caption2 + "\" H " + str(posX-425) + " " + str(posY) + " 140 0000 R CNB \"Caption2\"\n")
				sys.stdout.write("F 6 \"" + caption3 + "\" H " + str(posX-425) + " " + str(posY - 175) + " 140 0000 R TNB \"Caption3\"\n")
		elif caption2 != "":
			if rotated:
				rotated = 0
				inverted = True
			if down:
				sys.stdout.write("F 4 \"" + caption + "\" H " + str(posX) + " " + str(posY - 450) + " 140 0000 C TNB \"Caption\"\n")
				sys.stdout.write("F 5 \"" + caption2 + "\" H " + str(posX) + " " + str(posY - 225) + " 140 0000 C TNB \"Caption2\"\n")
			elif up:
				sys.stdout.write("F 4 \"" + caption + "\" H " + str(posX) + " " + str(posY - 225) + " 140 0000 C TNB \"Caption\"\n")
				sys.stdout.write("F 5 \"" + caption2 + "\" H " + str(posX) + " " + str(posY - 450) + " 140 0000 C TNB \"Caption2\"\n")
			else:
				sys.stdout.write("F 4 \"" + caption + "\" H " + str(posX) + " " + str(posY + 225) + " 140 0000 C BNB \"Caption\"\n")
				sys.stdout.write("F 5 \"" + caption2 + "\" H " + str(posX) + " " + str(posY - 225) + " 140 0000 C TNB \"Caption2\"\n")
		elif caption != ".":
			if up or down:
				sys.stdout.write("F 4 \"" + caption + "\" H " + str(posX) + " " + str(posY - 225) + " 140 0000 C TNB \"Caption\"\n")
			else:
				sys.stdout.write("F 4 \"" + caption + "\" H " + str(posX) + " " + str(posY + 225) + " 140 0000 C BNB \"Caption\"\n")
		sys.stdout.write("\t" + str(unit) + " " + str(posX) + " " + str(posY) + "\n")
		if up:
			sys.stdout.write("\t1    0    0    -1  \n")
		elif down:
			sys.stdout.write("\t1    0    0     1  \n")
		elif inverted:
			sys.stdout.write("\t-1    0    0   -1  \n")
		elif rotated:
			sys.stdout.write("\t-1    0    0    1  \n")
		else:
			sys.stdout.write("\t1    0    0    -1  \n")
		sys.stdout.write("$EndComp\n")
		continue
	
	if type == "A":
		unit = 1
		posX = object["x"]
		posY = object["y"]
		number = object["count"]
		refd = "X?"
		symbol = "ArrowTwiddle"
		sys.stdout.write("$Comp\n")
		sys.stdout.write("L AGC_DSKY:ArrowTwiddle " + refd + "\n")
		sys.stdout.write("U 1 1 " + timestamp() + "\n")
		sys.stdout.write("P " + str(posX) + " " + str(posY) + "\n")
		sys.stdout.write("F 0 \"" + refd + "\" H " + str(posX) + " " + str(posY + 325) + " 140 0001 C CNN\n")
		sys.stdout.write("F 1 \"" + symbol + "\" H " + str(posX) + " " + str(posY+425) + " 140 0001 C CNN\n")
		sys.stdout.write("F 2 \"\" H " + str(posX) + " " + str(posY+475) + " 140 0001 C CNN\n")
		sys.stdout.write("F 3 \"\" H " + str(posX) + " " + str(posY+475) + " 140 0001 C CNN\n")
		sys.stdout.write("F 4 \"" + number + "\" H " + str(posX) + " " + str(posY + 400) + " 140 0000 C BNB \"Number\"\n")
		sys.stdout.write("\t" + str(unit) + " " + str(posX) + " " + str(posY) + "\n")
		sys.stdout.write("\t1    0    0    -1  \n")
		sys.stdout.write("$EndComp\n")
		continue
	
	if type == "O":
		unit = 1
		posX = object["x"]
		posY = object["y"]
		caption = object["text"]
		caption2 = object["text2"]
		refd = "X?"
		symbol = "Node2"
		sys.stdout.write("$Comp\n")
		sys.stdout.write("L AGC_DSKY:Node2 " + refd + "\n")
		sys.stdout.write("U 1 1 " + timestamp() + "\n")
		sys.stdout.write("P " + str(posX) + " " + str(posY) + "\n")
		sys.stdout.write("F 0 \"" + refd + "\" H " + str(posX) + " " + str(posY + 325) + " 140 0001 C CNN\n")
		sys.stdout.write("F 1 \"" + symbol + "\" H " + str(posX) + " " + str(posY + 425) + " 140 0001 C CNN\n")
		sys.stdout.write("F 2 \"\" H " + str(posX) + " " + str(posY+475) + " 140 0001 C CNN\n")
		sys.stdout.write("F 3 \"\" H " + str(posX) + " " + str(posY+475) + " 140 0001 C CNN\n")
		if caption2 == "":
			sys.stdout.write("F 4 \"" + caption + "\" H " + str(posX-100) + " " + str(posY) + " 140 0000 R CNB \"Caption\"\n")
		else:
			sys.stdout.write("F 4 \"" + caption + "\" H " + str(posX-100) + " " + str(posY + 125) + " 140 0000 R CNB \"Caption\"\n")
			sys.stdout.write("F 5 \"" + caption2 + "\" H " + str(posX-100) + " " + str(posY - 125) + " 140 0000 R CNB \"Caption2\"\n")
		sys.stdout.write("\t" + str(unit) + " " + str(posX) + " " + str(posY) + "\n")
		sys.stdout.write("\t1    0    0    -1  \n")
		sys.stdout.write("$EndComp\n")
		continue
print "$EndSCHEMATC"
