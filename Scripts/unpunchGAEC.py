#!/usr/bin/python3
# This script takes a bunch of scanned aperture-card images that I've
# personally scanned using the C400 at NARA-SW (i.e., files named 
# according to the aperture card's metadata), and converts them to a 
# form I think is more convenient.  It is *based* on unpunch.py which
# was more-or-less specialized to MIT/IL drawings (or I suppose, more
# generally, to AC and AC-subcontractor drawings), but has been changed
# in ways that specialize it instead to GAEC LEM drawings.  The difference
# between these scenarios is that the punched metadata on the aperture
# cards is very different in the two cases.
# 
# As far as I can see, the GAEC punched metadata (as reflected but not
# literally reproduced in the filenames of the scans), follows two 
# separate patterns, depending on what's in column 1 of the *card*.  
# And fortunately the cards themselves largely describe those formats.  
# I'll call them the "primary" format (" " in column 1 of the card)
# and the "secondary" format ("EO" in columns 1-2 of the card.  The 
# latter is an "engineering order".  In terms of that cards, what
# you have is this:
#
#0	If primary:
#		1 col		Space
#		1 col		Drawing size (can be a space)
#	If secondary:
#		2 cols		"EO"
#2	15 cols		Drawing number (right-filled with space)
#17	5 cols		Code identification number (5 digits)
#22	3 cols		Sheet number (usually spaces; only used, I think, for secondary))
#25	2 cols		Revision (letter, left-padded with space; usually spaces for secondary)
#27	3 cols		Number of sheets (3 digits; usually spaces for secondary)
#30	2 cols		Frame number (2 digits)
#32	2 cols		Number of frames (2 digits)
#34	9 cols		Subdivided as follows:
#34		1 col	Camera number (1 digit; usually spaces for secondary)
#35		5 cols	Roll number (digits, terminated by ".", right-filled with space; usually spaces for secondary)
#40		3 cols	Frame sequence number (2 digits; usually spaces for primary)
#43	2 cols		Project code (digits, left-padded with space)
#45	2 cols		TBD (spaces) (possibly having something to do with rejection or revision)
#47	2 cols 		Control activity (usually spaces for primary)
#49	2 cols		Card code (usually spaces for primary)
#51	1 col		Sec(urity?) class (N)
#52	3 cols		Deck code (usually spaces)
#
# Notice that there are no drawing/document titles.  I further find that
# the slides themselves typically have no title either, except on the 
# very first sheet/slide for any given drawing number.

#	DocNumPlusRev-DocType-Sheet-Frame-Title.png
# The naming assumes that the PDFs created by the C400 have actually
# been pre-converted to PNGs.  The steps I envisage for doing that
# are:
#	cd FolderOfScannedCardPDFs
#	for n in *.PDF ; do pdfimages -png "$n" DestFolder_images/"$n" ; done
#	cd DestFolder_images
#	optipng *.png
# (The destination folder is something_images because the _images 
# part is required by archive.org's "generic book" upload format.)
# Whether or not the latter two steps have been done, the first step
# creates files with the same names as the original (including the
# trailing ".PDF") suffixed by "-000.png".  Alas, the pdfimages on my
# main computer at home is too early to support -png, and the effort 
# of compiling a newer version of it there has proven insurmountable
# so I have to transfer the files to a different computer to do that
# step, and then transfer them back.
#
# Aside from the renaming, this script also creates an HTML index of the 
# drawings, in which you afterward have to replace the string BASEURL
# with the appropriate name at which the drawings are going to be
# uploaded to archive.org.  In the instructions below, I'll refer to
# BASEURL instead as DestFolder_images, since archive.org requires the
# literal "_images" in the uploaded tarball or zipfile ... but DestFolder
# should be something different and unique for each upload.
#
# This script doesn't actually rename the files, but itself just 
# produces a script that you can run to rename the files:
#	cd DestFolder_images
#	ls -1 *.png | unpunch.py DestFolder_images >RenamingScript.sh 2>IndexTable.html
#	bash RenamingScript.sh
#
# Additional steps you'd usually take after all this are:
#	create a tar file called DestFolder_images.tar
#	upload the tar file to archive.org
#	create an index page for the box at ibiblio.org/apollo, using IndexTable.html
#	update the drawing search engine using the instructions in MakeTipueSearch.py
#	correct all drawing titles in the index page and search engine

import sys
import re

baseURL = "BASEURL"
if len(sys.argv) > 1:
	baseURL = sys.argv[1]
correctMetadata = True
mh = False
if len(sys.argv) > 2:
	if sys.argv[2] == "mh":
		mh = True
	else:
		correctMetadata = False

dupList = {}
htmlList = {}
eoPrefix = { "1": "A", "2": "B", "3": C" }
for line in sys.stdin:
	prefix = line[:2]
	line = line.strip()
	if line[-8:] == "-000.png":
		line = line[:-8]
	rawLine = line.strip()
	line = re.sub(r".*Box [0-9]+/", "", line)
	copy = ""
	if line[-7] == "(" and line[-5:] == ").PDF":
		copy = " (copy " + line[-6:-4]
	
	if prefix in ["EO", "E "]:
		engineeringOrder = True
	elif prefix == "LD":
		engineeringOrder = False
		line = "  " + line
	else:
		engineeringOrder = False
		line = " " + line
	numFrames = line[32:34].strip()
	if numFrames == "":
		numFrames = "1"
	docNumber = line[2:17].strip().replace("-","_")
	if False and engineeringOrder:
		sheetNum = line[22:25].strip()
		if sheetNum == "":
			sheetNum = "1"
	else:
		sheetNum = line[35:43].strip()
		if sheetNum == "":
			sheetNum = "1"
		if engineeringOrder and len(sheetNumber) == 3 and sheetNumber[:1] in eoPrefix and sheetNumber[1:].isdigit():
			sheetNum = eoPrefix[sheetNumber[:1]] + sheetNumber[1:]
		else:
			sheetNum = sheetNum.replace("#", ".")
		fields = sheetNum.split(".")
		if len(fields) == 2:
			while len(fields[0]) < 3:
				fields[0] = "0" + fields[0]
			while len(fields[1]) < 4:
				fields[1] = fields[1] + "0"
			sheetNum = fields[0] + "." + fields[1]
	frameNumber = line[30:32].strip()
	if frameNumber == "":
		frameNumber = "1"
	while len(frameNumber) < 2:
		frameNumber = "0" + frameNumber
	#print(line)
	#print(sheetNum)
	revision = line[25:27].strip()
	if revision == "":
		revision = "-"
	elif revision in eoPrefix:
		revision = eoPrefix[revision]
	while len(revision) < 2:
		revision = "-" + revision
	revision_ = revision.replace("-", "_")
	numSheets = line[27:30].strip()
	if numSheets == "":
		numSheets = "01"
	while len(numSheets) < 2:
		numSheets += "0" + numSheets

	if engineeringOrder:
		docType = "EO"
	else:
		docType = "DW"
	basename_ = docNumber + revision_ + "_" + docType + "_" + sheetNum + "_" + frameNumber + "_" + line.replace(".PDF", "") + copy
	basename = basename_
	# "key" in what follows is distinct from "basename" (which it 
	# was identical to in unpunch.py), because I've discovered 
	# archive.org uses a sorting order in which something like
	# LDW12345_... follows LDW2345_....  In other words, the 
	# sorting order isn't strictly alphabetic, but at least partially
	# numeric.  I don't know if numeric fields other than the first are
	# involved or not.  Consequently, I need to pad the number 
	# following the LDW (and possibly other alphabetic
	# prefixes later) so that they all have the same number of digits.
	key = basename
	key_ = basename_
	match = re.search(r'^([A-Z]+)([0-9]+)(.+)$', key)
	if match:
		prefix = match.group(1)
		numeric = match.group(2)
		suffix = match.group(3)
		if numeric.isdigit() and len(numeric) < 5:
			while len(numeric) < 5:
				numeric = "0" + numeric
			key = prefix + numeric + suffix
			key_ = key
	dup = 1
	while key in htmlList:
		key = key_ + "_d" + str(dup)
		basename = basename_ + "_d" + str(dup)
		dup += 1
	htmlList[key] = {
		"docNumber" : docNumber.replace("_", "-"),
		"revision" : revision,
		"docType" : docType,
		"sheetNum" : sheetNum,
		"frameNumber" : frameNumber,
		"title" : "",
		"copy" : copy, 
		"dup" : dup,
		"numFrames" : numFrames,
		"numSheets" : numSheets,
		"tdrr" : "", 
		"group" : "",
		"line" : rawLine,
		"basename" : basename
	}
	if dup > 1:
		if key_ in dupList:
			dupList[key_].append(htmlList[key])
		else:
			dupList[key_] = [htmlList[key_], htmlList[key]]

if False:
	print(": '")
	count = 1
	for n in dupList:
		print("# " + str(count) + ": " + n)
		count += 1
		for m in dupList[n]:
			print("xreader '" + m["line"] + "' &")
	print("'")

sys.stderr.write("<table class=\"gaecIndex\"><tbody>\n<tr>")
sys.stderr.write("<td><b>Link</b></td>")
sys.stderr.write("<td><b>Drawing</b></td>")
sys.stderr.write("<td><b>Rev</b></td>")
sys.stderr.write("<td><b>Type</b></td>")
sys.stderr.write("<td><b>Sheet</b></td>")
sys.stderr.write("<td><b>Frame</b></td>")
sys.stderr.write("<td><b>Title</b></td>")
sys.stderr.write("<td><b>Notes</b></td>")
sys.stderr.write("</tr>\n")

pageNumber = 0
for key in sorted(htmlList):
	sys.stderr.write("<tr>")
	sys.stderr.write("<td><a href=\"https://archive.org/stream/" + baseURL + "#page/n" + str(pageNumber) + "/mode/1up\">" + str(pageNumber) + "</a></td>") 
	sys.stderr.write("<td>" + htmlList[key]["docNumber"] + "</td>") 
	revision = htmlList[key]["revision"]
	if len(revision) == 2 and revision[0] == "-":
		revision = revision[1]
	sys.stderr.write("<td>" + revision + "</td>") 
	sys.stderr.write("<td>" + htmlList[key]["docType"] + "</td>") 
	sys.stderr.write("<td>" + htmlList[key]["sheetNum"] + "</td>") 
	sys.stderr.write("<td>" + htmlList[key]["frameNumber"] + "</td>") 
	sys.stderr.write("<td>" + htmlList[key]["title"] + "</td>") 
	dup = htmlList[key]["dup"]
	if dup == 1:
		sys.stderr.write("<td></td>") 
	else:
		sys.stderr.write("<td>Copy number " + str(dup) + "</td>")
	sys.stderr.write("</tr>\n")
	print("mv '" + htmlList[key]["line"] + "-000.png' '" + ("%04d" % pageNumber) + "_" + htmlList[key]["basename"] + ".png'")
	pageNumber += 1

sys.stderr.write("</tbody></table>\n")

