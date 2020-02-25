#!/usr/bin/python3
# This script acts similarly to unpunch.py or unpunchGAEC.py in the 
# limited sense of producing an IndexTable.html file suitable for
# being pasted into an AgcDrawingIndexBoxNNN.html file or a
# LemDrawingIndexBoxNNN.html file. 
#
# The differences are that it is intended to act on input that has
# been exported from Google Sheets as a TSV file, rather than on 
# metadata derived from PDF files scanned from aperture cards.
#
# The idea is that this script allows an alternate way of editing
# the data for such index HTML files when a WYSIWYG HTML editor 
# like Seamonkey is unavailable and directly editing the HTML itself
# is inefficient.  That's the very situation that exists while I'm
# at NARA scanning aperture cards.  The workflow imagined is this:
#
#   1.	An index table from an index HTML file is cut-and-pasted into
#	Google Sheets.  (The workflow requires that this be an HTML
#	file created from unpunch.py or unpunchGAEC.py, since it 
#	requires that column 1 of the table consists of page-number
#	references at archive.org.  In other words the workflow won't 
#	work on tables from either the file AgcDrawingIndex.html or 
#	AgcDrawingIndexMilSpec.html, but should work for all other
#	candidate index HTML files.)
#   2.	Edit the sheet as required.
#   3.	Export the sheet as a TSV file.
#   4.	Create the IndexTable.html file:
#		tsvToHtml.py BOXNUMBER [PARTNUMBER] <INPUT.tsv >IndexTable.html
#   5.	Cut-and-paste the contents of IndexTable.html into the target
#	index HTML file, to replace the table from step #1 above.

import sys

if len(sys.argv) <= 1 or not sys.argv[1].isdigit():
	sys.stderr.write("Must give a numeric box number on the command line.\n")
	sys.exit(1)
boxNumber = sys.argv[1]
if len(sys.argv) >= 3:
	partNumber = "Part" + sys.argv[2]
else:
	partNumber = ""
if int(boxNumber) >= 431 and int(boxNumber) <= 477:
	className = "drawingIndex"
else:
	className = "gaecIndex"

print('<table class="' + className + '"><tbody>')
print('<tr><td><b>Link</b></td><td><b>Drawing</b></td><td><b>Rev</b></td><td><b>Type</b></td><td><b>Sheet</b></td><td><b>Frame</b></td><td><b>Title</b></td><td><b>Notes</b></td></tr>')

count = 0
for line in sys.stdin:
	count += 1
	fields = line.strip("\n\r").split('\t')
	if len(fields) > 0 and fields[0] == "Link":
		continue
	if len(fields) != 8 or not fields[0].isdigit():
		sys.stderr.write("Line " + str(count) + " is malformed: '" + line.strip() + "'\n")
		sys.exit(1)
	url = 'https://archive.org/stream/apertureCardBox' + boxNumber + partNumber + 'NARASW_images#page/n' + fields[0] + '/mode/1up'
	line = '<tr><td><a href="' + url + '">' + fields[0] + '</a></td>'
	for n in range(1, 8):
		line += '<td>' + fields[n] + '</td>'
	line += '</tr>'
	print(line)	

print('</tbody></table>')
