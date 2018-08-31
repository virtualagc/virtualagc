#! /usr/bin/python
# The purpose of this python script is to take a text file that has some
# descriptions of NOR gates, expander gates, connector pads, nodes,
# and perhaps other objects commonly in AGC "logic flow diagrams", and
# produces a rough placement of those objects that can be cut-and-pasted
# into an eeschema .sch file.

import sys
import time

# Current origin and index around the origin.
xSpacing = 1.775 # inches
ySpacing = 0.8
originX = 0 # inches
originY = 0
nextX = 0
nextY = 0
def nextXY():
	global nextX, nextY
	if nextX == 0:
		nextX = nextY + 1
		nextY = 0
		return
	if nextY < nextX:
		nextY += 1
		return
	nextX -= 1
	return

# For entities with no obvious sequencing.
index = 0

# A dictionary for storing the objects in the schematic.
objects = {}

nors = { 
	"N": { "library": "D3NOR-+4VDC-0VDCA", "refdPrefix": "U1" },
	"N2": { "library": "D3NOR-+4SW-0VDCA", "refdPrefix": "U2" }, 
	"X": { "library": "D3NOR-FAP-0VDCA-expander", "refdPrefix": "U1" }, 
	"X2": { "library": "D3NOR-NC-0VDCA-expander", "refdPrefix": "U2" }
}
aPins = ["A", "B", "C", "_"]
bPins = ["D", "E", "F", "_"]

# Read the input file.
for line in sys.stdin:
	fields = line.strip().split(" ")
	numFields = len(fields)
	type = fields[0]
	if numFields < 1 or type == "#":
		continue
	if type == "N=" and numFields == 3:
		nors["N"][library] = fields[1]
		nors["N"][refdPrefix] = fields[2]
		continue
	if type == "N2=" and numFields == 3:
		nors["N2"][library] = fields[1]
		nors["N2"][refdPrefix] = fields[2]
		continue
	if type == "X=" and numFields == 3:
		nors["X"][library] = fields[1]
		nors["X"][refdPrefix] = fields[2]
		continue
	if type == "X2=" and numFields == 3:
		nors["X2"][library] = fields[1]
		nors["X2"][refdPrefix] = fields[2]
		continue
	if type == "L" and numFields == 3:
		originX = float(fields[1]) + xSpacing / 2.0
		originY = float(fields[2]) + ySpacing / 2.0
		nextX = 0
		nextY = 0
		continue

	posX = int(1000 * (originX + xSpacing * nextX))
	posY = int(1000 * (originY + ySpacing * nextY))
	
	if type in nors and numFields == 6:
		gate = fields[1]
		location = fields[2]
		top = fields[3]
		middle = fields[4]
		bottom = fields[5]
		id = type + location
		if not (id in objects):
			objects[id] = { "type": type, "library": nors[type]["library"], "refd": nors[type]["refdPrefix"]+location, "location": location }
		if top in aPins and middle in aPins and bottom in aPins:
			whichGate = "a"
		elif top in bPins and middle in bPins and bottom in bPins:
			whichGate = "b"
		else:
			print >>sys.stderr, "Illegal spec: " + line.strip('\n')
			sys.exit()
		objects[id][whichGate] = { "gate": gate, "top": top, "middle": middle, "bottom": bottom, "x": posX, "y": posY } 
		nextXY()
		continue
	
	if type == "J" and (numFields == 2 or numFields == 3):
		pinName = fields[1]
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
			print >>sys.stderr, "Illegal pin number: " + line.strip('\n')
			sys.exit()
		objects[id] = { "type": type, "refd": refd, "symbol": symbol, "unit": unit, "text": text, "x": posX, "y": posY }
		nextXY()
		continue
	
	if type == "O" and numFields == 2:
		id = type + str(index)
		index += 1
		text = fields[1]
		objects[id] = { "type": type, "text": text, "x": posX, "y": posY }
		nextXY()
		continue
	
	if type == "A" and numFields == 2:
		id = type + str(index)
		index += 1
		count = "(" + fields[1] + ")"
		objects[id] = { "type": type, "count": count, "x": posX, "y": posY }
		nextXY()
		continue		

# Write the output file.
timestamp = "%X" % time.time()
for id in objects:
	object = objects[id]
	type = object["type"]
	
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
		sys.stdout.write("$Comp\n")
		sys.stdout.write("L AGC_DSKY:" + symbol + " " + refd + "\n")
		sys.stdout.write("U " + str(unit) + " 1 " + timestamp + "\n")
		sys.stdout.write("P " + str(posX) + " " + str(posY) + "\n")
		sys.stdout.write("F 0 \"" + refd + "\" H " + str(posX) + " " + str(posY + 325) + " 140 0001 C CNN\n")
		sys.stdout.write("F 1 \"" + symbol + "\" H " + str(posX) + " " + str(posY+425) + " 140 0001 C CNN\n")
		sys.stdout.write("F 2 \"\" H " + str(posX) + " " + str(posY+475) + " 140 0001 C CNN\n")
		sys.stdout.write("F 3 \"\" H " + str(posX) + " " + str(posY+475) + " 140 0001 C CNN\n")
		sys.stdout.write("F 4 \"" + caption + "\" H " + str(posX) + " " + str(posY + 250) + " 140 0000 C BNB \"Caption\"\n")
		sys.stdout.write("\t" + str(unit) + " " + str(posX) + " " + str(posY) + "\n")
		sys.stdout.write("\t1    0    0    -1  \n")
		sys.stdout.write("$EndComp\n")
		continue
	
	if type == "A":
		unit = 1
		posX = object["x"]
		posY = object["y"]
		number = object["count"]
		sys.stdout.write("$Comp\n")
		sys.stdout.write("L AGC_DSKY:ArrowTwiddle X?\n")
		sys.stdout.write("U 1 1 " + timestamp + "\n")
		sys.stdout.write("P " + str(posX) + " " + str(posY) + "\n")
		sys.stdout.write("F 0 \"X?\" H " + str(posX) + " " + str(posY + 325) + " 140 0001 C CNN\n")
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
		sys.stdout.write("$Comp\n")
		sys.stdout.write("L AGC_DSKY:Node2 X?\n")
		sys.stdout.write("U 1 1 " + timestamp + "\n")
		sys.stdout.write("P " + str(posX) + " " + str(posY) + "\n")
		sys.stdout.write("F 0 \"X?\" H " + str(posX) + " " + str(posY + 325) + " 140 0001 C CNN\n")
		sys.stdout.write("F 1 \"" + symbol + "\" H " + str(posX) + " " + str(posY+425) + " 140 0001 C CNN\n")
		sys.stdout.write("F 2 \"\" H " + str(posX) + " " + str(posY+475) + " 140 0001 C CNN\n")
		sys.stdout.write("F 3 \"\" H " + str(posX) + " " + str(posY+475) + " 140 0001 C CNN\n")
		sys.stdout.write("F 4 \"" + caption + "\" H " + str(posX-100) + " " + str(posY) + " 140 0000 R CNB \"Caption\"\n")
		sys.stdout.write("\t" + str(unit) + " " + str(posX) + " " + str(posY) + "\n")
		sys.stdout.write("\t1    0    0    -1  \n")
		sys.stdout.write("$EndComp\n")
		continue
