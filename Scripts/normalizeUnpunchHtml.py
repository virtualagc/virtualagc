#!/usr/bin/python3
# The idea of this program is that it takes one of my AgcDrawingIndexXXX.html
# files, and for each DRAWINGNUMBER/DOCTYPE pair, duplicates the title of the
# first instance found into all of the other instances (for different revs,
# sheet numbers, frame numbers, and copies).  The point of this is that it 
# allows me to just adjust the very first instance's title and to painlessly
# propagate that change to all of the other instances with the same drawing
# number and document type.  Otherwise, it's rather painful and time-consuming
# to do that.  At the same time, it performs a slight amount of cleanup, such
# as eliminating spurious empty lines which SeaMonkey composer adds in for some
# reason.  I may also eventually use it to standardize boilerplate stuff that
# also appears in the files, but it doesn't do that right now.
#
# The program does not attempt to parse arbitrary HTML, and relies on the 
# uniformity of the construction of the files.
#
# Usage:
#	normalizeUnpunchHtml.py <INPUT.html >OUTPUT.html

import sys

inTable = 0	# Counts <tr> tags after the leading <tbody>, so as to avoid headings.
inRow = 0	# Counts <td> tags in a table row to determine proper column
cellEntry = ""
continuation = False
titles = {}

for rawLine in sys.stdin:
	line = rawLine.strip()
	if line == "": # Eliminate blank lines.
		continue
	if line == "<tbody>":
		inTable = 0
	elif line == "<tr>":
		inTable += 1
		continuation = False
		if inTable == 1:
			inRow = 1000
		else:
			inRow = 0
	elif continuation or line[:4] == "<td>": # Process a table cell entry
		if line[:4] == "<td>":
			inRow += 1
			cellEntry = line
		else:
			cellEntry += " " + line
		if cellEntry[-5:] != "</td>":
			continuation = True
		else:
			continuation = False
			if inRow == 2:
				docNumber = cellEntry[4:-5]
			elif inRow == 4:
				docType = cellEntry[4:-5]
			elif inRow == 7:
				key = docNumber + "_" + docType
				if key in titles:
					print(titles[key])
					continue
				titles[key] = cellEntry
			print(cellEntry)
		continue
	print(rawLine, end='')
