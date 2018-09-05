#! /usr/bin/python
# The purpose of this python script is to take a text file that has some
# descriptions of NOR gates, expander gates, connector pads, nodes,
# and perhaps other objects commonly in AGC "logic flow diagrams", and
# produces a rough placement of those objects into an otherwise empty
# .sch file.  That .sch file can then be brought into the real .sch file
# that's supposed to hold them, using eeschema's Import feature.
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
}
aPins = ["A", "B", "C", "_"]
bPins = ["D", "E", "F", "_"]

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
	
	if type in nors and numFields == 6 and fields[1].isdigit() and fields[2].isdigit():
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
	
	if (type == "J" or type == "j") and (numFields == 2 or numFields == 3) and fields[1].isdigit():
		rotated = False
		if type == "j":
			rotated = True
			type = "J"
		pinName = fields[1]
		if len(pinName) != 3 or not pinName.isdigit():
			print >>sys.stderr, "Incorrectly numbered connector: " + line
			wereErrors = True
			continue
		pinNum = int(pinName)
		if numFields >= 3:
			text = fields[2]
		else:
			text = ""
		id = type + pinName
		if pinNum >= 101 and pinNum <= 171:
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
		objects[id] = { "type": type, "refd": refd, "symbol": symbol, "unit": unit, "text": text, "x": posX, "y": posY, "rotated": rotated }
		nextXY()
		continue
	
	if type == "O" and numFields == 2:
		id = type + str(index)
		index += 1
		text = fields[1]
		objects[id] = { "type": type, "text": text, "x": posX, "y": posY }
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
timestamp = "%X" % time.time()
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
			sys.stdout.write("L " + library + ":" + symbol + " " + refd + "\n")
			sys.stdout.write("U 1 1 " + timestamp + "\n")
			sys.stdout.write("P " + str(posX) + " " + str(posY) + "\n")
			sys.stdout.write("F 0 \"" + refd + "\" H " + str(posX) + " " + str(posY + 325) + " 140 0001 C CNB\n")
			sys.stdout.write("F 1 \"" + symbol + "\" H " + str(posX) + " " + str(posY+425) + " 140 0001 C CNN\n")
			sys.stdout.write("F 2 \"\" H " + str(posX) + " " + str(posY+475) + " 140 0001 C CNN\n")
			sys.stdout.write("F 3 \"\" H " + str(posX) + " " + str(posY+475) + " 140 0001 C CNN\n")
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
			sys.stdout.write("U 2 1 " + timestamp + "\n")
			sys.stdout.write("P " + str(posX) + " " + str(posY) + "\n")
			sys.stdout.write("F 0 \"" + refd + "\" H " + str(posX) + " " + str(posY + 325) + " 140 0001 C CNB\n")
			sys.stdout.write("F 1 \"" + symbol + "\" H " + str(posX) + " " + str(posY+425) + " 140 0001 C CNN\n")
			sys.stdout.write("F 2 \"\" H " + str(posX) + " " + str(posY+475) + " 140 0001 C CNN\n")
			sys.stdout.write("F 3 \"\" H " + str(posX) + " " + str(posY+475) + " 140 0001 C CNN\n")
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
		posX = object["x"]
		posY = object["y"]
		symbol = object["symbol"]
		refd = object["refd"]
		unit = object["unit"]
		caption = object["text"]
		rotated = object["rotated"]
		sys.stdout.write("$Comp\n")
		sys.stdout.write("L AGC_DSKY:" + symbol + " " + refd + "\n")
		sys.stdout.write("U " + str(unit) + " 1 " + timestamp + "\n")
		sys.stdout.write("P " + str(posX) + " " + str(posY) + "\n")
		sys.stdout.write("F 0 \"" + refd + "\" H " + str(posX) + " " + str(posY + 325) + " 140 0001 C CNN\n")
		sys.stdout.write("F 1 \"" + symbol + "\" H " + str(posX) + " " + str(posY+425) + " 140 0001 C CNN\n")
		sys.stdout.write("F 2 \"\" H " + str(posX) + " " + str(posY+475) + " 140 0001 C CNN\n")
		sys.stdout.write("F 3 \"\" H " + str(posX) + " " + str(posY+475) + " 140 0001 C CNN\n")
		if rotated:
			sys.stdout.write("F 4 \"" + caption + "\" H " + str(posX) + " " + str(posY + 325) + " 140 0000 C CNB \"Caption\"\n")
		else:
			sys.stdout.write("F 4 \"" + caption + "\" H " + str(posX) + " " + str(posY + 300) + " 140 0000 C CNB \"Caption\"\n")
		sys.stdout.write("\t" + str(unit) + " " + str(posX) + " " + str(posY) + "\n")
		if rotated:
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
		sys.stdout.write("U 1 1 " + timestamp + "\n")
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
		refd = "X?"
		symbol = "Node2"
		sys.stdout.write("$Comp\n")
		sys.stdout.write("L AGC_DSKY:Node2 " + refd + "\n")
		sys.stdout.write("U 1 1 " + timestamp + "\n")
		sys.stdout.write("P " + str(posX) + " " + str(posY) + "\n")
		sys.stdout.write("F 0 \"" + refd + "\" H " + str(posX) + " " + str(posY + 325) + " 140 0001 C CNN\n")
		sys.stdout.write("F 1 \"" + symbol + "\" H " + str(posX) + " " + str(posY+425) + " 140 0001 C CNN\n")
		sys.stdout.write("F 2 \"\" H " + str(posX) + " " + str(posY+475) + " 140 0001 C CNN\n")
		sys.stdout.write("F 3 \"\" H " + str(posX) + " " + str(posY+475) + " 140 0001 C CNN\n")
		sys.stdout.write("F 4 \"" + caption + "\" H " + str(posX-100) + " " + str(posY) + " 140 0000 R CNB \"Caption\"\n")
		sys.stdout.write("\t" + str(unit) + " " + str(posX) + " " + str(posY) + "\n")
		sys.stdout.write("\t1    0    0    -1  \n")
		sys.stdout.write("$EndComp\n")
		continue
print "$EndSCHEMATC"
