#!/usr/bin/python2
# I, the author, Ron Burkey, declare this to be in the Public Domain.

# The idea of this script is that it can create an index table of the
# kind I've been creating for the NARA-scan batches on the AgcDrawingIndex.html
# page.  It has two inputs:  a tab-separated-value file created from my 
# Google Sheets spreadsheet of the various drawings being sought/scanned,
# and the sorted list of image files uploaded to archive.org.  When I say
# "sorted", I mean sorted in the same manner archive.org would upon receiving
# that file.  Plus, we need the basic link for that batch of files at archive.org.
# The very first file in the sorted list is linked as "Page 1", the second as
# "Page 2", and so on. 

# The archive.org stuff is for recurring usage, but as a one-off, of the base URL
# is "SCDs/", then it can also be used on the local folder of SCDs that Mike 
# gave me. 

# To accomplish the sorting properly, I'd suggest naming the files like
#	DR[-S][-frameF].png.jp2
# where D is the (usually 7-digit) drawing number, R is the revision, S is the
# sheet number (usually left off if there is only one sheet), and F is the frame
# number (omitted if the sheet has only one frame). Since archive.org sorts
# hyphens *after* alphabeticals but 'sort' puts them before, it's convenient
# to replace '-' -> '_', then sort, then replace '_' -> '-' when creating the
# sorted list.  Regardless, this script expects this specific naming scheme.
# I also allow fields "-crummy", "-lighter", or "-darker" to be present.

# The archive.org stuff is for recurring usage, but as a one-off, if the base URL
# is "SCDs/", then it can also be used on the local folder of SCDs that Mike 
# gave me. In that case, the comments about the filenaming convention and other
# details change.

import sys

if len(sys.argv) < 4:
	print "Usage:"
	print "\tmakeDrawingIndexTable.py INPUT.tsv INPUT_images BASEURL >OUTPUT.html"

inputTsvFilename = sys.argv[1]
inputImagesFilename = sys.argv[2]
baseUrl = sys.argv[3]
SCDs = False
if baseUrl == "SCDs/":
	SCDs = True

# First, read the input TSV file.
inputTsv = {}
try:
	f = open(inputTsvFilename)
	while True:
		line = f.readline()
		if line:
			fields = line.strip().split("\t")
			if len(fields) >= 3:
				drawing = fields[0]
				revisions = fields[1].split()
				if len(fields) >= 3:
					title = fields[2]
				else:
					title = ""
				if len(fields) >= 5:
					notes = fields[4]
				else:
					notes = ""
				inputTsv[drawing] = { "revisions":revisions, "title":title, "notes":notes }
		else:
			break
	f.close()
	#print inputTsv
except:
	print >> sys.stderr, "Cannot read TSV file " + inputTsvFilename
	sys.exit(1)

# Next, read the sorted filenames and parse them.
pages = []
try:
	f = open(inputImagesFilename)
	while True:
		line = f.readline()
		if line:
			line = line.strip()
			filename = line
			if SCDs:
				if line[:4] != "scd_" or line[-4:] != ".pdf":
					print >> sys.stderr, "Filename improper: " + line
					sys.exit(1)
				line = line[4:-4]
				if line[-2].isalpha():
					drawing = line[:-2]
					rev = line[-2:].upper()
				else:
					drawing = line[:-1]
					rev = line[-1:].upper()
				pages.append({ "filename":filename, "drawing":drawing, "rev":rev, "sheet":"1", "frame":"1" })
				continue
			if line[-8:] != ".png.jp2":
				print >> sys.stderr, "Filename improper: " + line
				sys.exit(1)
			line = line[:-8]
			fields = line.split("-")
			if "crummy" in fields:
				fields.remove("crummy")
			if "lighter" in fields:
				fields.remove("lighter")
			if "darker" in fields:
				fields.remove("darker")
			sheet = "1"
			frame = "1"
			if len(fields) > 1 and fields[1] == "":
				drawing = fields[0]
				rev = "-"
				del fields[1]
			else:
				if fields[0][-2].isalpha():
					drawing = fields[0][:-2]
					rev = fields[0][-2:]
				else:
					drawing = fields[0][:-1]
					rev = fields[0][-1:].upper()
			if len(fields) == 3:
				if fields[2][:5] != "frame":
					print >> sys.stderr, "Filename improper: " + line
					sys.exit(1)
				frame = fields[2][5:]
				sheet = fields[1]
			elif len(fields) == 2:
				if fields[1][:5] == "frame":
					frame = fields[1][5:]
				else:
					sheet = fields[1]
			if not drawing.isdigit():
				print >> sys.stderr, "Drawing number improper: " + line
				sys.exit(1)
			if rev != "-" and not rev.isalpha():
				print >> sys.stderr, "Revision improper: " + rev
			if not sheet.isdigit():
				print >> sys.stderr, "Sheet number improper: " + sheet
			if not frame.isdigit():
				print >> sys.stderr, "Frame number improper: " + frame
			pages.append({ "filename":filename, "drawing":drawing, "rev":rev, "sheet":sheet, "frame":frame })
		else:
			break
except:
	print >> sys.stderr, "Cannot read the file of page-images " + inputImagesFilename
	sys.exit(1)
#print pages

# Ready to output the table.
if SCDs:
	print '''
	    <table cellspacing="2" cellpadding="2" border="1" align="center">
	      <tbody>
	        <tr>
	          <th valign="middle" align="center">Link<br></th>
	          <th valign="middle" align="center">Drawing<br></th>
	          <th valign="middle" align="center">Rev<br></th>
	          <th valign="middle">Title<br></th>
	          <th valign="middle">Comment<br></th>
	        </tr>
	'''
else:
	print '''
	    <table cellspacing="2" cellpadding="2" border="1" align="center">
	      <tbody>
	        <tr>
	          <th valign="middle" align="center">Page<br></th>
	          <th valign="middle" align="center">Drawing<br></th>
	          <th valign="middle" align="center">Rev<br></th>
	          <th valign="middle" align="center">Sheet<br></th>
	          <th valign="middle" align="center">Frame<br></th>
	          <th valign="middle">Title<br></th>
	          <th valign="middle">Comment<br></th>
	        </tr>
	'''
for i in range(0, len(pages)):
	filename = pages[i]["filename"]
	drawing = pages[i]["drawing"]
	title = inputTsv[drawing]["title"]
	rev = pages[i]["rev"]
	sheet = pages[i]["sheet"]
	frame = pages[i]["frame"]
	notes = inputTsv[drawing]["notes"]
	if SCDs:
		print '<tr><td valign="middle" align="center"><a href="' + baseUrl + filename + '">drawing<br></a></td>'
	else:
		print '<tr><td valign="middle" align="center"><a href="' + baseUrl + '#page/n' + str(i) + '/mode/1up">' + str(i+1) + '<br></a></td>'
        print '<td valign="middle" align="center">' + drawing + '<br></td>'
        print '<td valign="middle" align="center">' + rev + '<br></td>'
        if not SCDs:
	        print '<td valign="middle" align="center">' + sheet + '<br></td>'
	        print '<td valign="middle" align="center">' + frame + '<br></td>'
        print '<td valign="middle">' + title + '</td>'
        print '<td valign="middle">' + notes + '</td></tr>'
print '</tbody></table>'
