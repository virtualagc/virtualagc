#!/usr/bin/awk
# Early versions of autoplaceKiCad.py did not create
# appropriate "Value" fields (F1) for Node2 or ArrowTwiddle
# components, which makes it tough to do a search for them
# now in KiCad.  This script fixes those fields.

BEGIN {
	value = "TBD"
}

{
	if ($1 == "L") {
		if ($2 == "AGC_DSKY:Node2") {
			value = "Node2"
		} else if ($2 == "AGC_DSKY:ArrowTwiddle") {
			value = "ArrowTwiddle"
		} else {
			value = "TBD"
		}
	}
	if ($1 == "F" && $2 == "1" && value != "TBD") {
		$3 = "\"" value "\""
	}
	print $0
}
