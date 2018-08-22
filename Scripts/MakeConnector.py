#!/usr/bin/python
# This script generates a file describing a connector symbol for KiCad that is:
#	Multipart, with each part being a single pin.
#	Oval shaped with the long dimension along the x-axis, as in AGC/DSKY schematics.
#	Allows (with 0 or 180 degree rotations) wire entry to the right or the left.
#	Allows (with 0 or 180 degree rotations and DeMorgan) wire entry to the top or bottom.
#	Pin name at center and always upright (not printed along the y-axis).
# You can cause pins to be omitted, in which case a multipart will still be generated for
# the omitted pin, but there won't actually be any pin with that number or name.

import sys

# Tweak the stuff below.

if len(sys.argv) > 1:
	partName = sys.argv[1]
else:
	print >> sys.stderr, "No connector name defined."
	print >> sys.stderr, "USAGE:"
	print >> sys.stderr, "\tMakeConnector.py PARTNAME [ENDINGPIN [STARTINGPIN [OMITTEDPINS]]] >PARTFORIMPORT.lib"
	print >> sys.stderr, "ENDINGPIN is required if PARTNAME is not a name already hardcoded"
	print >> sys.stderr, "into the script, such as \"ConnectorD7\"."
	sys.exit(1)

if partName == "ConnectorA1-100":
	startingPinNumber = 101
	endingPinNumber = 171
	omitPins = [ 121, 151 ]
elif partName == "ConnectorA1-200":
	startingPinNumber = 201
	endingPinNumber = 271
	omitPins = [ 221, 251 ]
elif partName == "ConnectorA1-300":
	startingPinNumber = 301
	endingPinNumber = 371
	omitPins = [ 321, 351 ]
elif partName == "ConnectorA1-400":
	startingPinNumber = 401
	endingPinNumber = 471
	omitPins = [ 421, 451 ]
elif partName == "ConnectorD1_D6_1":
	startingPinNumber = 1
	endingPinNumber = 62
	omitPins = [ ]
elif partName == "ConnectorD1_D6_2":
	startingPinNumber = 63
	endingPinNumber = 124
	omitPins = [ ]
elif partName == "ConnectorD7":
	startingPinNumber = 1
	endingPinNumber = 12
	omitPins = [ ]
elif partName == "ConnectorD8":
	startingPinNumber = 1
	endingPinNumber = 35
	omitPins = [ ]
else:
	startingPinNumber = 1
	omitPins = [ ]
	if len(sys.argv) > 2:
		endingPinNumber = int(sys.argv[2])
		if len(sys.argv) > 3:
			startingPinNumber = int(sys.argv[3])
			for n in range(4, len(sys.argv)):
				omitPins.append(int(sys.argv[n]))
	else:
		print >> sys.stderr, "No ending pin number."
		sys.exit(1)
print >> sys.stderr, "Using the following configuration:"
print >> sys.stderr, partName
print >> sys.stderr, startingPinNumber
print >> sys.stderr, endingPinNumber
print >> sys.stderr, omitPins
print >> sys.stderr, ""

#  All numbers in mils.
refdPattern = "J"
xRadius = 275
yRadius = 175
textSize = 140
lineWidth = 30
textMargin = 50

nextPinAfterLast = endingPinNumber + 1
totalPins = nextPinAfterLast - startingPinNumber # - len(omitPins)

# This part does the actual work.
print("EESchema-LIBRARY Version 2.4")
print("#encoding utf-8")
print("#")
print("# " + partName)
print("#")
print("DEF ~" + partName + " " + refdPattern + " 0 0 N N " + str(totalPins) + " L N")
print("F0 \"" + refdPattern + "\" 0 " + str(yRadius+ 3 * textMargin) + " " + str(textSize) + " H I C CNN")
print("F1 \"" + partName + "\" 0 " + str(yRadius + 5 * textMargin) + " " + str(textSize) + " H I C CNN")
print("F2 \"\" 0 " + str(yRadius) + " " + str(textSize) + " H I C CNN")
print("F3 \"\" 0 " + str(yRadius) + " " + str(textSize) + " H I C CNN")
#print("F4 \"PAD\" 0 " + str(yRadius + 1 * textMargin) + " " + str(textSize) + " H V C BNB \"Caption\"")
print("DRAW")
arcPos = xRadius - yRadius
print("A " + str(-arcPos) + " 0 " + str(yRadius) + " 901 -901 0 0 " + str(lineWidth) + " N " + str(-arcPos) + " " + str(yRadius) + " " + str(-arcPos) + " " + str(-yRadius))
print("A " + str(arcPos) + " 0 " + str(yRadius) + " -899 899 0 0 " + str(lineWidth) + " N " + str(arcPos) + " " + str(-yRadius) + " " + str(arcPos) + " " + str(yRadius))
partno = 1
for pin in range(startingPinNumber, nextPinAfterLast):
	print("T 0 0 0 " + str(textSize) + " 0 " + str(partno) + " 0 " + str(pin) + " Normal 1 C C")
	partno += 1
print("P 2 0 0 " + str(lineWidth) + " " + str(-arcPos) + " " + str(-yRadius) + " " + str(arcPos) + " " + str(-yRadius) + " N")
print("P 2 0 0 " + str(lineWidth) + " " + str(-arcPos) + " " + str(yRadius) + " " + str(arcPos) + " " + str(yRadius) + " N")
partno = 1
for pin in range(startingPinNumber, nextPinAfterLast):
	if not (pin in omitPins):
		print("X " + str(pin) + " " + str(pin) + " " + str(xRadius) + " 0 0 L " + str(textSize) + " " + str(textSize) + " " + str(partno) + " 1 P")
	partno += 1
partno = 1
for pin in range(startingPinNumber, nextPinAfterLast):
	if not (pin in omitPins):
		print("X " + str(pin) + " " + str(pin) + " 0 " + str(yRadius) + " 0 D " + str(textSize) + " " + str(textSize) + " " + str(partno) + " 2 P")
	partno += 1
print("ENDDRAW")
print("ENDDEF")
print("#")
print("#End Library")

