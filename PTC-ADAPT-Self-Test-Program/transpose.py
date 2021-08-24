#! /usr/bin/python3
# I've been experimenting with using Tesseract to OCR the scans of the 
# PTC ADAPT Self-Test Program's octal listing, rather than having to 
# manually input all of the data.  It's frustrating, because, it seems 
# insist on doing the OCR column-wise rather than row-wise.  Nor does it
# format the whitespace the way I need.  So this script simply takes the 
# column-wise output from the OCR, transpose it row-wise, and format it
# reasonably.  Admittedly, I could *used* the data as it was, but proofing
# it would have been awful.

# Reads on stdin, and outputs to stdout. 

import sys

octals = []
for line in sys.stdin:
	fields = line.strip().split()
	#print(fields, file=sys.stderr)
	for f in fields:
		if len(octals) == 0:
			# Sometimes, the OCR omits the very first "0".
			# Try to add it to avoid a manual step.
			if f not in [ "0", "200" ]:
				octals.append("0")
		# Try to eliminate junk from specks on the page.
		if len(f) < 2:
			continue
		octals += [ f ]

if len(octals) != 16*9:
	print("Wrong number of fields (%d)." % len(octals), file=sys.stderr)
	print(octals, file=sys.stderr)
else:
	for i in range(16):
		line = octals[i]
		for j in range(8):
			line += "\t" + octals[i + 16 * (j+1)]
		print(line)

