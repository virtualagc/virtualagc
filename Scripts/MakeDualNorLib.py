#!/usr/bin/python
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

vcc = "+4VDC" # Name of net used for hidden power input.
gnd = "0VDC" # Name of net used for hidden ground input.
basename = "D3NOR-" + vcc + "-" + gnd # Base name of the generated components. 

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
ListALevel0 = [ "_", "A", "B", "C" ]
ListBLevel0 = [ "_", "D", "E", "F" ]
for inA1 in ListALevel0:
  ListALevel1 = list(ListALevel0)
  ListALevel1.remove(inA1)
  for inA2 in ListALevel1:
    ListALevel2 = list(ListALevel1)
    ListALevel2.remove(inA2)
    for inA3 in ListALevel2:
      ListALevel3 = list(ListALevel2)
      ListALevel3.remove(inA3)
      for inB1 in ListBLevel0:
        ListBLevel1 = list(ListBLevel0)
        ListBLevel1.remove(inB1)
        for inB2 in ListBLevel1:
          ListBLevel2 = list(ListBLevel1)
          ListBLevel2.remove(inB2)
          for inB3 in ListBLevel2:
            ListBLevel3 = list(ListBLevel2)
            ListBLevel3.remove(inB3)
            # All the stuff above is just to get us to the point of having
            # a valid set of 6 inputs, in[AB][1-3] (in regex notation) with
            # appropriate values [_A-F].  Having those in hand, we can now
            # generate the specific entry for the component.
            name = basename + "-" + inA1 + inA2 + inA3 + "-" + inB1 + inB2 + inB3
            
            
            print("#")
            print("# " + name)
            print("#")
            print("DEF " + name + " U 0 0 N Y 2 F N")
            print("F0 \"U\" 0 475 50 H V C CNN")
            print("F1 \"" + name +"\" 0 550 50 H I C CNN")
            print("F2 \"\" -495 470 50 H I C CNN")
            print("F3 \"\" -495 470 50 H I C CNN")
            # The following two fields look like good ideas, except that
            # they get moved outside the body when the component is placed
            # regardless of how I position them in the library.
            # print("F4 \"GGGGG\" 0 100 140 H V C CNN \"Gate\"")
            # print("F5 \"LL\" 0 -100 140 H V C CNN \"Loc\"")
            print("DRAW")
            print("A -1460 0 1040 -226 226 0 1 40 N -500 -400 -500 400")
            print("A -113 -374 787 795 284 0 1 40 N 30 400 580 0")
            print("A -113 374 787 -284 -795 0 1 40 N 580 0 30 -400")
            print("C 665 0 85 0 1 40 N")
            print("P 2 0 1 40 30 -400 -500 -400 N")
            print("P 2 0 1 40 30 400 -500 400 N")
            if inA1 != "_":
              print("P 4 1 1 40 -460 275 -750 375 -750 175 -460 275 F")
            if inA2 != "_":
              print("P 4 1 1 40 -420 0 -675 -100 -675 100 -420 0 F")
            if inA3 != "_":
              print("P 4 1 1 40 -460 -275 -750 -175 -750 -375 -460 -275 F")
            if inB1 != "_":
              print("P 4 2 1 40 -460 275 -750 375 -750 175 -460 275 F")
            if inB2 != "_":
              print("P 4 2 1 40 -420 0 -675 -100 -675 100 -420 0 F")
            if inB3 != "_":
              print("P 4 2 1 40 -460 -275 -750 -175 -750 -375 -460 -275 F")
            print("X J 1 900 0 150 L 140 140 1 1 O")
            print("X " + vcc + " 10 -175 400 0 D 140 140 1 1 W N")
            if inA1 != "_":
              print("X " + inA1 + " " + pinNumbers[inA1] + " -900 275 140 R 140 140 1 1 I")
            else:
              print("X " + gnd + " " + pinNumbers[ListALevel3[0]] + " -475 275 0 R 140 140 1 1 W N")
            if inA2 != "_":
              print("X " + inA2 + " " + pinNumbers[inA2] + " -900 0 140 R 140 140 1 1 I")
              print("P 2 1 1 0 -760 0 -680 0 N")
            else:
              print("X " + gnd + " " + pinNumbers[ListALevel3[0]] + " -425 0 0 R 140 140 1 1 W N")
            if inA3 != "_":
              print("X " + inA3 + " " + pinNumbers[inA3] + " -900 -275 140 R 140 140 1 1 I")
            else:
              print("X " + gnd + " " + pinNumbers[ListALevel3[0]] + " -475 -275 0 R 140 140 1 1 W N")
            print("X " + gnd + " 5 -175 -400 0 U 140 140 1 1 W N")
            if inB1 != "_":
              print("X " + inB1 + " " + pinNumbers[inB1] + " -900 275 140 R 140 140 2 1 I")
            else:
              print("X " + gnd + " " + pinNumbers[ListBLevel3[0]] + " -475 275 0 R 140 140 2 1 W N")
            if inB2 != "_":
              print("X " + inB2 + " " + pinNumbers[inB2] + " -900 0 140 R 140 140 2 1 I")
              print("P 2 2 1 0 -760 0 -680 0 N")
            else:
              print("X " + gnd + " " + pinNumbers[ListBLevel3[0]] + " -425 0 0 R 140 140 2 1 W N")
            if inB3 != "_":
              print("X " + inB3 + " " + pinNumbers[inB3] + " -900 -275 140 R 140 140 2 1 I")
            else:
              print("X " + gnd + " " + pinNumbers[ListBLevel3[0]] + " -475 -275 0 R 140 140 2 1 W N")
            print("X K 9 900 0 150 L 140 140 2 1 O")
            print("ENDDRAW")
            print("ENDDEF")

# Finally, close out the library.
print("#")
print("#End Library")
