#!/usr/bin/awk
# Pick off all connector pad netnames from Block I schematics.
# The schematic files have comment lines ("Comment1" through 
# "Comment4") near the top, and this script expects to use 
# Comment1.  If Comment1 reads "Modules Something1 Something2 ...",
# then the script looks for the netname for module SomethingN in the
# component field "CaptionN".  (Or just "Caption" if N=1.).  For 
# example, if
#	Comment1 "Modules A33 A34"
# then it expects to find the netnames for module A33 in field "Caption"
# and those for module A34 in field "Caption2".  It allows for up to 
# 16 different modules, since that's the maximum actually encountered.

BEGIN {
  inConnector = 0
  modules[0] = "" # Just defining the array.  I don't use position 0.
  captionKeys[0] = ""
  maxIndex = 0
}

{
  if ($1 == "Comment1" && $2 == "\"Modules") {
    for (i = 3; i <= NF; i++) {
      maxIndex = i - 2
      modules[maxIndex] = $i
      sub(/"/,"",modules[maxIndex])
      if (i == 3) {
        captionKeys[maxIndex] = "\"Caption\""
      } else {
      	captionKeys[maxIndex] = "\"Caption" (i-2) "\""
      }
    }
  } else if ($1 == "$EndComp") {
    inConnector = 0
  } else if ($1 == "L" && $3 == "J1") {
    inConnector = 1
  } else if ($1 == "U") {
    pad = $2
  } else if ($1 == "F") {
    for (i = 1 ; i <= maxIndex; i++) {
      if ($11 == captionKeys[i]) {
      	print modules[i] "\t" pad "\t" $3
      	break;
      }
    }
  }
}
