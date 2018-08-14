#!/usr/bin/python
# This script generates a file describing a connector symbol for KiCad that is:
#	Multipart, with each part being a single pin.
#	Oval shaped with the long dimension along the x-axis, as in AGC/DSKY schematics.
#	Allows (with 0 or 180 degree rotations) wire entry to the right or the left.
#	Allows (with 0 or 180 degree rotations and DeMorgan) wire entry to the top or bottom.
#	Pin name at center and always upright (not printed along the y-axis).

# Tweak the stuff below.  All numbers in mils unless specified.
partName = "AConnector"
numPins = 10 # Number of pins

refdPattern = "J"
xRadius = 225
yRadius = 175
textSize = 140
lineWidth = 50

# This part does the actual work.
print("EESchema-LIBRARY Version 2.4")
print("#encoding utf-8")
print("#")
print("# " + partName)
print("#")
print("DEF ~" + partName + " " + refdPattern + " 0 0 N N " + str(numPins) + " F N")
print("F0 \"" + refdPattern + "\" 0 " + str(yRadius+50) + " " + str(lineWidth) + " H I C CNN")
print("F1 \"" + partName + "\" 0 " + str(yRadius+200) + " " + str(lineWidth) + " H I C CNN")
print("F2 \"\" " + str(-lineWidth) + " " + str(yRadius) + " " + str(lineWidth) + " H I C CNN")
print("F3 \"\" " + str(-lineWidth) + " " + str(yRadius) + " " + str(lineWidth) + " H I C CNN")
print("DRAW")
print("A " + str(-lineWidth) + " 0 " + str(yRadius) + " 901 -901 0 0 0 N " + str(-lineWidth) + " " + str(yRadius) + " " + str(-lineWidth) + " " + str(-yRadius))
print("A " + str(lineWidth) + " 0 " + str(yRadius) + " -899 899 0 0 0 N " + str(lineWidth) + " " + str(-yRadius) + " " + str(lineWidth) + " " + str(yRadius))
for pin in range(1, numPins+1):
	print("T 0 0 0 " + str(textSize) + " 0 " + str(pin) + " 0 " + str(pin) + " Normal 0 C C")
print("P 2 0 0 0 " + str(-lineWidth) + " " + str(-yRadius) + " " + str(lineWidth) + " " + str(-yRadius) + " N")
print("P 2 0 0 0 " + str(-lineWidth) + " " + str(yRadius) + " " + str(lineWidth) + " " + str(yRadius) + " N")
for pin in range(1, numPins+1):
	print("X " + str(pin) + " " + str(pin) + " " + str(xRadius) + " 0 0 L " + str(textSize) + " " + str(textSize) + " " + str(pin) + " 1 P")
for pin in range(1, numPins+1):
	print("X " + str(pin) + " " + str(pin) + " 0 " + str(yRadius) + " 0 D " + str(textSize) + " " + str(textSize) + " " + str(pin) + " 2 P")
print("ENDDRAW")
print("ENDDEF")
print("#")
print("#End Library")

