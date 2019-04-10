#!/usr/bin/awk -f
# This script is used for finding funky wires in a KiCad schematic.  Specifically,
# wires that are at a very tiny inclination from exact horizontal or vertical,
# ones that are very short, or ones not on a 25-mil grid.

function abs(v) { return v < 0 ? -v : v }

function errorMessage(msg) { print x1/1000, ", ", y1/1000, ", ", x2/1000, ", ", y2/1000, ": ", msg } 

BEGIN {
	nextLine = 0
	short = 49.9
	medium = 299.9
	grid = 25
	lowSlope = 0.05
}

{
	if ($1 == "Wire" && $2 == "Wire") {
		nextLine = 1
	} else if (nextLine) {
		nextLine = 0
		x1 = $1
		y1 = $2
		x2 = $3
		y2 = $4
		
		len1 = abs(x1 - x2)
		len2 = abs(y1 - y2)
		if (len1 > len2) {
			len = len1
			len1 = len2
			len2 = len
		}
		len = sqrt(len1 * len1 + len2 * len2)
		slope = len1 / len2
		
		# Off grid?
		if (x1 % grid != 0 || x2 % grid != 0 || y1 % grid != 0 || y2 % grid != 0) {
			errorMessage("Off grid")
		} 
		
		else if (len < short) {
			# Too short?
			errorMessage("Too short")
		}
		
		# Poor angle for short wires?  This will have a false positive
		# for short wires I sometimes add at transistor leads. 
		else if (slope > 0 && len < medium) {
			errorMessage("Short incline")
		}
		
		# Poor angle for long wires? 
		else if (slope > 0 && slope < lowSlope) {
			errorMessage("Slight incline")
		}
		
		
	}
}
