#!/usr/bin/awk
# I, the author, Ron Burkey, declare this to be in the Public Domain.
# It's just a one-off that was immediately discarded after use anyway.

# For fixing up a .sch file in which all U and J reference designators
# have been replaced by U? or J?.  Intended for "logic flow diagrams"
# populated by autoplaceKiCad.py.

BEGIN {
	baseRefdNOR = "U2"
	inNOR = 0
	inConnector = 0
	refd = ""
	count = 0
}

{
	if (inConnector) {
		if (count < 3) {
			count = count + 1
		} else {
			inConnector = 0
			$3 = "\"" refd "\""
		}
		print $0
	} else if (inNOR) {
		if (count < 8) {
			lines[count] = $0
			count = count + 1
		} else {
			inNOR = 0
			location = gensub(/"/, "", "g", $3)
			lines[count] = $0
			refd = baseRefdNOR location
			$0 = lines[0]
			$3 = refd
			lines[0] = $0
			$0 = lines[3]
			$3 = "\"" refd "\""
			lines[3] = $0
			for (count = 0; count <= 8; count++) {
				print lines[count]
			}
		}
	} else if ($1 == "L" && index($2, "D3NOR") > 0) {
		inNOR = 1
		lines[0] = $0
		count = 1
	} else if ($1 == "L" && index($2, "ConnectorA1-100") > 0) {
		inConnector = 1
		count = 1
		refd = "J1"
		$3 = refd
		print $0
	} else if ($1 == "L" && index($2, "ConnectorA1-200") > 0) {
		inConnector = 1
		count = 1
		refd = "J2"
		$3 = refd
		print $0
	} else if ($1 == "L" && index($2, "ConnectorA1-300") > 0) {
		inConnector = 1
		count = 1
		refd = "J3"
		$3 = refd
		print $0
	} else if ($1 == "L" && index($2, "ConnectorA1-400") > 0) {
		inConnector = 1
		count = 1
		refd = "J4"
		$3 = refd
		print $0
	} else {
		print $0
	}
}

