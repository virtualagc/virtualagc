#!/usr/bin/awk

BEGIN {
  inConnector = 0
}

{
  if ($1 == "$EndComp") {
    inConnector = 0
  } else if ($1 == "L" && $3 == "J1") {
    inConnector = 1
  } else if ($1 == "U") {
    pad = $2
  } else if ($1 == "F" && $11 == "\"Caption\"") {
    print "A33\t" pad "\t" $3
  } else if ($1 == "F" && $11 == "\"Caption2\"") {
    print "A34\t" pad "\t" $3
  }
}
