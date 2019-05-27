#!/usr/bin/python2
# The idea of this program is that various indexes of Apollo engineering drawings
# are maintained in the Virtual AGC website files AgcDrawingIndexXXXXX.html, 
# and that this program can extract them and do various things with that info.
# However, as I say, the maintenance (editing titles, adding comments, etc.) has
# to take place directly in the HTML, and not in whatever data is created by this
# program.

# Usage:
#	cat AgcDrawingIndex*.html | AgcDrawingIndex.py >drawings.csv
# where drawings.csv is supposed to be put into the DrawingTree/ folder.
# Typically you'd then also do
#	MakeTipueSearch.py <drawings.csv >tipuesearch_content.js
# which is supposed to go into the TipueSearch/ folder of the website.

# Detection of certain types of usual data results in a notation such as
# "*** CHECK ME ***" being added to "note" column in the output.  
# Questionable data includes things like
#
#	Consecutive part numbers with the same drawing titles.  (These are usually
#	due to my messing up when pasting the titles into the AgcDrawingIndexXXXX.html
#	files.  But sometimes there really are consecutive drawing number with the
#	same titles!  Hardcode those in the ignore[] array to cause the checker
#	to skip this test for them.)
#
#	Drawings with the same drawing number + doc type having different titles.
#	(It's actually possible for this to happen correctly, since the original
#	developers didn't always use the same drawing titles verbatim from one
#	revision to the next, but it's more-usually because I messed up somehow.
#	At present, I always try to use the *same* title for these, regardless
#	of what the developers wrote in the title blocks.)
#
#	Titles which contain lower-case characters.
#
#	A document type other than 1 (01) or 2 (02).  I don't know if there are
#	other possible document types, but if so I've not encountered them yet.
#
#	Sheet numbers or frame numbers with non-alphabetical characters in them.
#	(A final character of 'A' is allowed for sheet numbers, since there are
#	a handful of them in type 02 documents.)
#
# One goal is to eliminate all of the CHECK ME's. This doesn't guarantee that 
# all errors have been found, but it's a good start.

# The drawing data must appear in the HTML file in the form of tables.  
# Tables are only processed if they have the attribute class="drawingIndex".
# Other tables are ignored.  Multiple tables with class="drawingIndex" can appear
# in any given HTML file.  The columns in the table must represent (in this
# order!):
#	A hyperlink to the image or pdf of the drawing scan.
#	The drawing number
#	The drawing rev
#	The document type (1 drawing, 2 acceptance test requirements)
#	The sheet number
#	The frame number
#	The title
#	Notes
# The first row of the table is discarded, since it should always contain the column
# names rather than data.

# Portion of the code that actually extracts the tabulated date from the HTML
# was supplied by "Yuval" here: 
#	https://stackoverflow.com/questions/1403087/how-can-i-convert-an-html-table-to-csv
# In its original form, it simply extracted all tables as TSV to stdout, from 
# HTML received on stdin.  It does not handle any flourishes like spans or embedded
# tables, and that's fine with me.  

# However, I've fixed it up in various ways, so that original functionality is a distant dream.
# What it does now is process multiple HTML files, store all of the data in a big
# dictionary, sort the dictionary after everything has been read into it, and output
# both a combined TSV of all the data.  That TSV can optionally be processed with 
# TipueSearch.py to get a JavaScript file of it for the website's drawing search engine.

# Here's a useful little BASH code that runs the program and then picks out just some of the 
# warning messages that are embedded in the output TSV, rather than saving the TSV itself:
#
#	cat AgcDrawingIndex*.html | AgcDrawingIndex.py | \
#		grep --before-context=1 'CHECK ME' | \
#		awk -F $'\t' '{match($1, /[^/]*#/); print $2 " " $3 " " $4 " " $5 " " $6 "\t" $7 "\t" substr($1, RSTART, RLENGTH)} "\t" $8' | less

from HTMLParser import HTMLParser
import sys
import re

class HTMLTableParser(HTMLParser):
    valid_table = False
    header_row = False
    link_column = False
    row = []
    cell_data = ""
    allData = {}

    def __init__(self, row_delim="\n", cell_delim="\t"):
        HTMLParser.__init__(self)
        self.despace_re = re.compile(r'\s+')
        self.data_interrupt = False
        self.first_row = True
        self.first_cell = True
        self.in_cell = False
        self.row_delim = row_delim
        self.cell_delim = cell_delim

    def handle_starttag(self, tag, attrs):
        self.data_interrupt = True
        if tag == "table":
            self.first_row = True
            self.first_cell = True
            self.valid_table = False
            for var in attrs:
            	if var[0] == "class" and var[1] == "drawingIndex":
            		self.valid_table = True
        elif tag == "tr":
            self.row = []
            if not self.first_row:
                self.header_row = False
            elif not self.header_row:
                self.header_row = True
            self.first_row = False
            self.first_cell = True
            self.data_interrupt = False
        elif tag == "td" or tag == "th":
            self.cell_data = ""
            if not self.first_cell:
                self.link_column = False
            else:
                self.link_column = True
            self.first_cell = False
            self.data_interrupt = False
            self.in_cell = True
        elif tag == "a" and self.valid_table and self.link_column:
            for var in attrs:
                if var[0] == "href":
                    self.row.append(var[1])

    def handle_endtag(self, tag):
        self.data_interrupt = True
        if tag == "td" or tag == "th":
            self.in_cell = False
            if not self.header_row and not self.link_column:
                self.row.append(self.cell_data)
        elif tag == "tr":
            if self.valid_table and not self.header_row:
                if len(self.row) != 8:
                    sys.stdout.write(str(len(self.row)) + " " + str(self.row) + "\n")
                else:
                    url = self.row[0]
                    drawingNumber = self.row[1] + self.row[2]
                    docType = self.row[3]
                    while len(docType) < 2:
                        docType = "0" + docType
                    sheetNumber = self.row[4]
                    while len(sheetNumber) < 3:
                        sheetNumber = '0' + sheetNumber
                    frameNumber = self.row[5]
                    while len(frameNumber) < 2:
                        frameNumber = "0" + frameNumber
                    key = drawingNumber + "_" + docType + "_" + sheetNumber + "_" + frameNumber
                    dupe = 0
                    dkey = key
                    while dkey in self.allData:
                    	dupe += 1
                    	dkey = key + "_d" + str(dupe)
                    if '"' in self.row[6]:
                    	self.row[6] = '"' + self.row[6].replace('"', '""') + '"'
                    self.allData[dkey] = {
                        "url" : self.row[0],
                        "drawing" : self.row[1],
                        "revision" : self.row[2],
                        "type" : self.row[3],
                        "sheet" : self.row[4],
                        "frame" : self.row[5],
                        "title" : self.row[6],
                        "note" : self.row[7]
                    }

    def handle_data(self, data):
        if self.in_cell and self.valid_table:
            cleaned_data = self.despace_re.sub(' ', data).strip()
            self.cell_data = self.cell_data + cleaned_data
            self.data_interrupt = False
    
    # This probably doesn't handle all of the entities that might appear, and so will
    # probably have to be fixed up some later.
    def handle_entityref(self, name):
    	subs = { 
    	    "amp" : "&", 
    	    "gt" : ">", 
    	    "lt" : "<",
    	    "nbsp" : " "
    	}
    	if self.in_cell and self.valid_table and name in subs:
    	    self.cell_data = self.cell_data + subs[name]

# What these two steps do is to read the input concatenated HTML and from it 
# to create parser.allData, which is a dictionary of all
# the drawing-index data read in from the HTML files.  Has entries
#	key:	{
#			url: ...,
#			drawing: ...,
#			revision: ...,
#			type: ...,
#			sheet: ...,
#			frame: ...,
#			title: ...,
#			note: ...
#		}
# and the keys (I hope) are formed suitable so that sorting on the keys produces a
# sensible ordering similar to sorting on drawing+revision+type+sheet+frame.
parser = HTMLTableParser() 
parser.feed(sys.stdin.read()) 

# Now do a little detection of possible errors in the data.
# Here's a hard-coded list of drawing numbers known to give a false positives on 
# the "unchanged title" test.  I'm sorry to hardcode them, but I'm tired
# of seeing the warning messages and haven't been able to think of a better way to
# handle them.
ignore = [ '1004218', '1004219', '1004227', '1004283', '1004536', '1004646', '1005009', '1005011',
	'1005799', '1006350', '1006351', '1006800', '1006814', '1006818', '1006819', '1008944',
	'1010865', '2003081', '2003082', '2003121', '2003955', '2003972', '2004120',
	'2004121', '2004122', '2004123', '2004124', '2004125', '2004685', '2005029', '2005036',
	'2005944', '2005954', '2007172', '2010760' ] 
digits = [ "0", "1", "2", "3", "4", "5", "6", "7", "8", "9" ]
lastDrawing = ["", "", ""]
lastTitle = ["", "", ""]
for key, value in sorted(parser.allData.iteritems()):
	drawing = value["drawing"]
	type = int(value["type"])
	title = value["title"]
	sheet = value["sheet"]
	frame = value["frame"]
	prefix = ""
	if type not in [1, 2]:
		prefix = "*** CHECK ME (bad type) *** "
		type = 0
	elif drawing == lastDrawing[type] and title != lastTitle[type]:
		prefix = "*** CHECK ME (changed title) *** "
	elif drawing != lastDrawing[type] and title == lastTitle[type] and drawing not in ignore:
		prefix = "*** CHECK ME (unchanged title) *** "
	if any(c.islower() for c in title):
		prefix = prefix + " *** CHECK ME (lower-case title) *** "
	if sheet[-1] == 'A':
		ssheet = sheet[:-1]
	else:
		ssheet = sheet
	if any((c not in digits) for c in ssheet):
		prefix = prefix + " *** CHECK ME (non-digit sheet number) *** "
	if any((c not in digits) for c in frame):
		prefix = prefix + " *** CHECK ME (non-digit frame number) *** "
	if prefix != "":
		value["note"] = prefix + value["note"]
	lastDrawing[type] = drawing
	lastTitle[type] = title

# Finally, output the drawings.csv file.
for key, value in sorted(parser.allData.iteritems()):
	print value["url"] + "\t" + value["drawing"] + "\t" + value["revision"] + \
	      "\t" + value["type"] + "\t" + value["sheet"] + "\t" + value["frame"] + \
	      "\t" + value["title"] + "\t" + value["note"]

