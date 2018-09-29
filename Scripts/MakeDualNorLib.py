#!/usr/bin/python
# I, the author, Ron Burkey, declare this to be in the Public Domain.

# This script makes a KiCad library containing all of the multitude of NOR gates
# potentially used in AGC/DSKY schematics.  I say "potentially", because not every
# combination is actually used, but without making some kind of laborious accounting
# in advance, there's no way to know, so we just generate all of them.
#
# More precisely, all combinations with the *same* power/ground inputs are generated,
# as determined by the variables at the top of the program.
#
# For any given power/ground levels, there are 576 different combinations, based on the
# fact that the dual 3-input NOR can have either all 3 of their inputs used, or just
# two of them, and that any of the 4 pins can physically appear in any of the 3 positions
# in the drawing.  Thus, there are
# 
#	(4 * 3 * 2) * (4 * 3 * 2) = 576 possibilities.
#
# Given that the 3 inputs for the first gate are A, B, C, or blank (which we call "_"),
# and those for the second are D, E, F, or _, we give all of the various components
# we generate names like:
#
#	BASENAME-ABC-DEF  or  BASNENAME-C_B-_FD  etc.

# Usage:
#	MakeDualNorLib.py [VCC [GND [VARIATION [VARIATION2]]]]
# The defaults are GND=0VDCA, VCC=+4VDC, VARIATION="", VARIATION2="".
# The first GND/VCC are the netnames for the power rails for the hidden power and ground pins.
# If VCC="NC", then the corresponding power pin is left unconnected.
# VARIATION is either "" (for regular NOR gates) or "expander" for the expander gates.
# VARIATION2 is either "" (to show pin numbers) or "nopinnums" to not show pin numbers.

import sys

vcc = "+4VDC" # Name of net used for hidden power input.
gnd = "0VDCA" # Name of net used for hidden ground input.
variation = ""
variation2 = ""

if len(sys.argv) > 1 and "D3NOR-" in sys.argv[1] and ".lib.bak" in sys.argv[1]:
	s = sys.argv[1].replace('.lib.bak', '')
	fields = s.split('-');
	if len(fields) == 4 and fields[3] == "nopinnums":
		fields[3] = ""
		fields.append("nopinnums")
else:
	fields = sys.argv
if len(fields) > 1:
	vcc = fields[1]
if len(fields) > 2:
	gnd = fields[2]
if len(fields) > 3:
	variation = fields[3]
if len(fields) > 4:
	variation2 = fields[4]

basename = "D3NOR-" + vcc + "-" + gnd # Base name of the generated components. 
if variation == "expander":
	basename += "-expander"
if variation2 == "nopinnums":
	basename += "-nopinnums"

lineWidth = 30

# Generate library header.
print("EESchema-LIBRARY Version 2.4")
print("#encoding utf-8")

# Relationship of input pin numbers to pin names:
pinNumbers = {
  "A" : "4",
  "B" : "3",
  "C" : "2",
  "D" : "6",
  "E" : "7",
  "F" : "8"
}

# Proceed to generate the library's entries.
# In the following loop, the inputs of gate A are represented by inA1, inA2, and inA3.
# The inputs of gate B are represented by inB1, inB2, and inB3.
ListALevel0 = [ "_", "_", "A", "B", "C" ]
ListBLevel0 = [ "_", "_", "D", "E", "F" ]
dupes = []
for inA1 in ListALevel0:
  ListALevel1 = list(ListALevel0)
  ListALevel1.remove(inA1)
  for inA2 in ListALevel1:
    ListALevel2 = list(ListALevel1)
    ListALevel2.remove(inA2)
    for inA3 in ListALevel2:
      ListALevel3 = list(ListALevel2)
      ListALevel3.remove(inA3)
      if "_" in ListALevel3:
        ListALevel3.remove("_")
      for inB1 in ListBLevel0:
        ListBLevel1 = list(ListBLevel0)
        ListBLevel1.remove(inB1)
        for inB2 in ListBLevel1:
          ListBLevel2 = list(ListBLevel1)
          ListBLevel2.remove(inB2)
          for inB3 in ListBLevel2:
            ListBLevel3 = list(ListBLevel2)
            ListBLevel3.remove(inB3)
            if "_" in ListBLevel3:
              ListBLevel3.remove("_")
            ListALevel3A = list(ListALevel3)
            ListBLevel3A = list(ListBLevel3)
            
            # Apply some symmetry to remove some of the possibilities.
            if inA1 == "_" and inA2 == "_" and inA3 == "_":
              continue
            if inB1 == "_" and inB2 == "_" and inB3 == "_":
              continue
            if inA1 > inA3:
              continue
            if inB1 > inB3:
              continue
            
            # All the stuff above is just to get us to the point of having
            # a valid set of 6 inputs, in[AB][1-3] (in regex notation) with
            # appropriate values [_A-F].  Having those in hand, we can now
            # generate the specific entry for the component.
            name = basename + "-" + inA1 + inA2 + inA3 + "-" + inB1 + inB2 + inB3
            if name in dupes:
            	continue
            dupes.append(name)
            
            print("#")
            print("# " + name)
            print("#")
            if variation2 == "nopinnums":
              print("DEF " + name + " U 0 0 N N 2 L N")
            else:
              print("DEF " + name + " U 0 0 N Y 2 L N")
            print("F0 \"U\" 0 525 140 H I C CNB")
            print("F1 \"" + name +"\" 0 550 50 H I C CNN")
            print("F2 \"\" -495 470 50 H I C CNN")
            print("F3 \"\" -495 470 50 H I C CNN")
            if variation == "expander":
            	print("F4 \"NNNNN\" -75 0 120 H V C CNB \"Location\"")
            	print("F5 \"NN\" -125 -200 120 H V C CNB \"Location2\"")
            else:
            	print("F4 \"NNNNN\" 0 0 140 H V C CNB \"Location\"")
            	print("F5 \"NN\" -75 -200 140 H V C CNB \"Location2\"")
            print("DRAW")
            print("A -1460 0 1040 -226 226 0 1 " + str(lineWidth) + " N -500 -400 -500 400")
            print("A -113 -374 787 795 284 0 1 " + str(lineWidth) + " N 30 400 580 0")
            print("A -113 374 787 -284 -795 0 1 " + str(lineWidth) + " N 580 0 30 -400")
            print("C 665 0 85 0 1 " + str(lineWidth) + " N")
            print("P 2 0 1 " + str(lineWidth) + " 30 -400 -500 -400 N")
            print("P 2 0 1 " + str(lineWidth) + " 30 400 -500 400 N")
            if variation == "expander":
            	print("P 16 0 1 0 275 305 275 -315 340 -270 400 -220 445 -170 485 -130 520 -85 540 -55 575 0 545 55 480 135 425 195 375 245 310 290 275 305 280 300 F")
            if inA1 != "_":
              print("P 4 1 1 " + str(lineWidth) + " -460 275 -750 375 -750 175 -460 275 F")
            if inA2 != "_":
              print("P 4 1 1 " + str(lineWidth) + " -420 0 -675 -100 -675 100 -420 0 F")
            if inA3 != "_":
              print("P 4 1 1 " + str(lineWidth) + " -460 -275 -750 -175 -750 -375 -460 -275 F")
            if inB1 != "_":
              print("P 4 2 1 " + str(lineWidth) + " -460 275 -750 375 -750 175 -460 275 F")
            if inB2 != "_":
              print("P 4 2 1 " + str(lineWidth) + " -420 0 -675 -100 -675 100 -420 0 F")
            if inB3 != "_":
              print("P 4 2 1 " + str(lineWidth) + " -460 -275 -750 -175 -750 -375 -460 -275 F")
            print("X J 1 900 0 150 L 140 140 1 1 C")
            if vcc == "NC":
            	print("X " + vcc + " 10 -175 350 0 D 140 140 1 1 N N")
            else:
            	print("X " + vcc + " 10 -175 350 0 D 140 140 1 1 W N")
            if inA1 != "_":
              print("X " + inA1 + " " + pinNumbers[inA1] + " -900 275 140 R 140 140 1 1 I")
            else:
              print("X " + gnd + " " + pinNumbers[ListALevel3A[0]] + " -475 275 0 R 140 140 1 1 W N")
              del ListALevel3A[0]
            if inA2 != "_":
              print("X " + inA2 + " " + pinNumbers[inA2] + " -900 0 140 R 140 140 1 1 I")
              print("P 2 1 1 0 -760 0 -680 0 N")
            else:
              print("X " + gnd + " " + pinNumbers[ListALevel3A[0]] + " -425 0 0 R 140 140 1 1 W N")
              del ListALevel3A[0]
            if inA3 != "_":
              print("X " + inA3 + " " + pinNumbers[inA3] + " -900 -275 140 R 140 140 1 1 I")
            else:
              print("X " + gnd + " " + pinNumbers[ListALevel3A[0]] + " -475 -275 0 R 140 140 1 1 W N")
              del ListALevel3A[0]
            print("X " + gnd + " 5 -175 -350 0 U 140 140 1 1 W N")
            if inB1 != "_":
              print("X " + inB1 + " " + pinNumbers[inB1] + " -900 275 140 R 140 140 2 1 I")
            else:
              print("X " + gnd + " " + pinNumbers[ListBLevel3A[0]] + " -475 275 0 R 140 140 2 1 W N")
              del ListBLevel3A[0]
            if inB2 != "_":
              print("X " + inB2 + " " + pinNumbers[inB2] + " -900 0 140 R 140 140 2 1 I")
              print("P 2 2 1 0 -760 0 -680 0 N")
            else:
              print("X " + gnd + " " + pinNumbers[ListBLevel3A[0]] + " -425 0 0 R 140 140 2 1 W N")
              del ListBLevel3A[0]
            if inB3 != "_":
              print("X " + inB3 + " " + pinNumbers[inB3] + " -900 -275 140 R 140 140 2 1 I")
            else:
              print("X " + gnd + " " + pinNumbers[ListBLevel3A[0]] + " -475 -275 0 R 140 140 2 1 W N")
              del ListBLevel3A[0]
            print("X K 9 900 0 150 L 140 140 2 1 C")
            print("ENDDRAW")
            print("ENDDEF")

# Finally, close out the library.
print("#")
print("#End Library")
