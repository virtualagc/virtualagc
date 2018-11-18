#!/usr/bin/awk
# Pick off all connector pad netnames from Block I schematics.
# The schematic files have comment lines ("Comment1" through 
# "Comment4") near the top, and if CommentN reads "Module SOMETHING",
# then the script looks for the netname for module SOMETHING in the
# component field "CaptionN".  (Or just "Caption" if N=1.).  For 
# example, of the comments are
#	Comment1 "Module A33"
#	Comment2 "Module A34"
# then it expects to find the netnames for module A33 in field "Caption"
# and those for module A34 in field "Caption2".

BEGIN {
  inConnector = 0
  module1 = ""
  module2 = ""
  module3 = ""
  module4 = ""
}

{
  if ($1 == "Comment1" && $2 == "\"Module") {
    module1 = $3
    sub(/"/,"",module1)
  } else  if ($1 == "Comment2" && $2 == "\"Module") {
    module2 = $3
    sub(/"/,"",module2)
  } else if ($1 == "Comment3" && $2 == "\"Module") {
    module3 = $3
    sub(/"/,"",module3)
  } else if ($1 == "Comment4" && $2 == "\"Module") {
    module4 = $3
    sub(/"/,"",module4)
  } else if ($1 == "$EndComp") {
    inConnector = 0
  } else if ($1 == "L" && $3 == "J1") {
    inConnector = 1
  } else if ($1 == "U") {
    pad = $2
  } else if ($1 == "F" && $11 == "\"Caption\"") {
    print module1 "\t" pad "\t" $3
  } else if ($1 == "F" && $11 == "\"Caption2\"") {
    print module2 "\t" pad "\t" $3
  } else if ($1 == "F" && $11 == "\"Caption3\"") {
    print module3 "\t" pad "\t" $3
  } else if ($1 == "F" && $11 == "\"Caption4\"") {
    print module4 "\t" pad "\t" $3
  }
}
