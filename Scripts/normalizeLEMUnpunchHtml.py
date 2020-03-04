#!/usr/bin/python3
# The idea of this program is that it takes one of my LemDrawingIndexBoxXXX.html
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
# uniformity of the construction of the files.  It *ASSUMES* that the file 
# has been saved at least once by SeaMonkey or by some other program that 
# performs similar gratuitous changes to the HTML.  Specifically, it relies
# on the fact that each <tr> or <td> tag is the first non-white thing on its
# line (which is not true of files created by unpunchGAEC.py that haven't yet
# been massaged by SeaMonkey ... or at least isn't true at this moment, though
# I could easily change unpunchGAEC.py to enforce that restructuring if I 
# needed to.)
#
# Usage:
#   normalizeUnpunchHtml.py <INPUT.html >OUTPUT.html

import sys

inTable = 0 # Counts <tr> tags after the leading <tbody>, so as to avoid headings.
inRow = 0   # Counts <td> tags in a table row to determine proper column
cellEntry = ""
continuation = False
titles = {}
lastTitle = "<td></td>"
leo = False
eoPrefix = { "1": "A", "2": "B", "3": "C", "4": "D", "5": "E" }

print('<table class="gaecIndex"><tbody><tr><td><b>Link</b></td><td><b>Drawing</b></td><td><b>Rev</b></td><td><b>Type</b></td><td><b>Sheet</b></td><td><b>Frame</b></td><td><b>Title</b></td><td><b>Notes</b></td></tr>', file=sys.stderr)
isHighlighted = False

for rawLine in sys.stdin:
    line = rawLine.strip()
    if line == "": # Eliminate blank lines.
        continue
    if line == "<tbody>":
        inTable = 0
    elif line == "<tr>":
        if isHighlighted:
        	print('<tr>', file=sys.stderr)
        	print(' <td></td>', file=sys.stderr)
        	print(' <td>' + docNumber + '</td>', file=sys.stderr)
        	print(' <td>' + revision + '</td>', file=sys.stderr)
        	print(' <td>' + docType + '</td>', file=sys.stderr)
        	print(' <td>' + sheet + '</td>', file=sys.stderr)
        	print(' <td>' + frame + '</td>', file=sys.stderr)
        	print(' <td>' + title + '</td>', file=sys.stderr)
        	print(' <td></td>', file=sys.stderr)
        	print('</tr>', file=sys.stderr)
        inTable += 1
        isHighlighted = False
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
            while cellEntry[-6:] == " </td>":
                cellEntry = cellEntry[:-6] + "</td>"
            while cellEntry[-9:] == "<br></td>":
                cellEntry = cellEntry[:-9] + "</td>"
            if inRow == 1:
            	link = cellEntry
            elif inRow == 2:
                docNumber = cellEntry[4:-5]
                if "font" in docNumber:
                	isHighlighted = True
                while '<' in docNumber and '>' in docNumber:
                  startTag = docNumber.index('<')
                  endTag = docNumber.index('>')
                  if startTag == 0:
                  	docNumber = docNumber[endTag+1:]
                  else:
                  	docNumber = docNumber[:startTag]
                if docNumber[:1] == '`':
                  docNumber = "LEO280-" + docNumber[1:]
                  tickIndex = cellEntry.index('`')
                  cellEntry = cellEntry[:tickIndex] + "LEO280-" + cellEntry[tickIndex + 1:]
            elif inRow == 3:
            	revision = cellEntry[4:-5]
            	if revision in eoPrefix:
            		cellEntry = "<td>" + eoPrefix[revision] + "</td>"
            elif inRow == 4:
                docType = cellEntry[4:-5]
            elif inRow == 5:
            	sheet = cellEntry[4:-5]
            	if docType == "EO" and " " in sheet:
            		sheetFields = sheet.split()
            		sheet = sheetFields[0]
            		cellEntry = "<td>" + sheet + "</td>"
            	if "#" in sheet:
	            	sheetFields = sheet.split("#")
	            	if len(sheetFields) < 3:
	            		while len(sheetFields[0]) < 3:
	            			sheetFields[0] = "0" + sheetFields[0]
	            		if len(sheetFields) < 2:
	            			sheetFields.append("0000")
	            		while len(sheetFields[1]) < 4:
	            			sheetFields[1] = sheetFields[1] + "0"
	            		sheet = sheetFields[0] + "." + sheetFields[1]
	            		cellEntry = "<td>" + sheet + "</td>"
            	if len(sheet) == 3 and sheet.isdigit() and sheet[:1] in eoPrefix:
            		cellEntry = "<td>" + eoPrefix[sheet[:1]] + sheet[1:] + "</td>"
            elif inRow == 6:
            	frame = cellEntry[4:-5]
            elif inRow == 7:
                title = cellEntry[4:-5]
                leo = (docNumber[:3] == "LEO")
                if cellEntry == "<td></td>" and leo:
                    cellEntry = lastTitle
                elif cellEntry != "<td></td>":
                    lastTitle = cellEntry
                if cellEntry == "<td></td>":
                    key = docNumber # + "_" + docType
                    if key in titles:
                        lastTitle = titles[key]
                        title = titles[key]
                        print(titles[key])
                        continue
                    if not leo:
                        titles[key] = cellEntry
                else:
                    key = docNumber # + "_" + docType 
                    if not leo:
                        titles[key] = cellEntry # set new entry for the key
            print(cellEntry)
        continue
    print(rawLine, end='')

print('</tbody></table>', file=sys.stderr)
