#!/usr/bin/python3
# This script takes a bunch of scanned aperture-card images that I've
# personally scanned using the C400 at NARA-SW (i.e., files named 
# according to the aperture card's metadata), and converts them to a 
# form I think is more convenient:
#	DocNumPlusRev-DocType-Sheet-Frame-Title.png
# The naming assumes that the PDFs created by the C400 have actually
# been pre-converted to PNGs.  The steps I envisage for doing that
# are:
#	cd FolderOfScannedCardPDFs
#	for n in *.PDF ; do pdfimages -png "$n" DestFolder_images/"$n"
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
# uploaded to archive.org.
#
# This script doesn't actually rename the files, but itself just 
# produces a script that you can run to rename the files:
#	cd FolderOfScannedCardPDFs
#	ls -1 *.PDF | unpunch.py "DestFolder_images" >RenamingScript.sh 2>IndexTable.html
#	cd DestFolder_images
#	bash RenamingScript.sh
# Additional steps you'd usually take after that are:
#	create a tar file called DestFolder_images.zip
#	upload the tar file to archive.org
#	create an index page for the box at ibiblio.org/apollo

import sys
import re

baseURL = "BASEURL"
if len(sys.argv) > 1:
	baseURL = sys.argv[1]
correctMetadata = True
if len(sys.argv) > 2:
	correctMetadata = False

dupList = {}
htmlList = {}
for line in sys.stdin:
	line = line.strip()
	rawLine = line
	line = re.sub(r".*Box [0-9]+/", "", line)
	copy = ""
	if line[-7] == "(" and line[-5:] == ").PDF":
		copy = " (copy " + line[-6:-4]
	docType = line[:2].strip()
	if docType == "":
		docType = "00"
	frameNumber = line[2:4].strip()
	if frameNumber == "":
		frameNumber = "1"
	numFrames = line[4:6].strip()
	if numFrames == "":
		numFrames = "1"
	docNumber = line[6:13]
	sheetNum = line[14:17]
	if sheetNum[1] != " " and sheetNum[2] == " ":
		sheetNum = sheetNum[:2] + "8"
	if sheetNum[1] == " ":
		sheetNum = sheetNum[0] + "0" + sheetNum[2]
	if sheetNum[0] == " ":
		sheetNum = "0" + sheetNum[1:]
	if sheetNum == "00 ":
		sheetNum = "001"
	if line[19].isalpha():
		revision = line[19:21].strip()
	else:
		revision = line[20].strip()
	if revision == "":
		revision = "-"
	if len(revision) == 1:
		revision = "-" + revision
	tdrr = line[21:26]
	numSheets = line[27:29].strip()
	if numSheets == "":
		numSheets = "1"
	title = re.sub(r" +", " ", line[30:52].strip())
	group = line[54:57]
	while len(sheetNum) < 3:
		sheetNum = "0" + sheetNum
	while len(frameNumber) < 2:
		frameNumber = "0" + frameNumber

	if correctMetadata:
		# Whether it's a problem in the system that initially punched
		# the aperture cards or whether it's a problem with the scanner
		# software I don't know, but the fact is that the metadata the
		# scanner reads from the cards departs from the (correct) printing
		# on the card, with semi-systematic replacements of some characters
		# in some fields by other characters.  For example, almost all
		# (but not QUITE all!) revision fields "Y" are replaced by "0",
		# and all "H" characters in the title field are replaced by "&".
		# But there are real "&" characters in the title field as well,
		# sometimes, though many less of them.  Yikes!  The following 
		# block of code tries to fix the most egregious errors, but it's
		# simply impossible to fix everything in an automated way.
		# So if you have (for example) at title "NAV&MAIN DSKY", it's 
		# going to end up being "fixed" by this code as "NAVHMAIN DSKY",
		# and there's just nothing I can do about it.  Fortunately, as
		# far as I know right now, all of the unfixable errors are in the
		# titles, and those will eventually be manually entered from data
		# on the drawings anyway.  I.e., the titles have been taken initially
		# from card data for expedience, but will eventually be corrected.
		docNumber = docNumber.replace(" ", "8")
		revision = revision.replace("&","H").replace("0", "Y")
		tdrr = tdrr.replace(" ", "8")
		while revision[:1] == " ":
			revision = revision[1:]
		while len(sheetNum) > 3 and sheetNum[:1] in [ " ", "0" ]:
			sheetNum = sheetNum[1:]
		while len(frameNumber) > 2 and frameNumber[:1] in [ " ", "0" ]:
			frameNumber = frameNumber[1:]
		title = title.replace("&", "H").replace("0", "Y").replace("-", "Q").replace(" H ", " & ")

	revision_ = revision.replace("-", "_")
	basename_ = docNumber + revision_ + "_" + docType + "_" + sheetNum + "_" + frameNumber + "_" + title + copy
	basename = basename_
	dup = 1
	while basename in htmlList:
		basename = basename_ + "_d" + str(dup)
		dup += 1
	print("mv '" + rawLine + "-000.png' '" + basename + ".png'")
	htmlList[basename] = {
		"docNumber" : docNumber,
		"revision" : revision,
		"docType" : docType,
		"sheetNum" : sheetNum,
		"frameNumber" : frameNumber,
		"title" : title,
		"copy" : copy, 
		"dup" : dup,
		"numFrames" : numFrames,
		"numSheets" : numSheets,
		"tdrr" : tdrr, 
		"group" : group,
		"line" : rawLine
	}
	if dup > 1:
		if basename_ in dupList:
			dupList[basename_].append(htmlList[basename])
		else:
			dupList[basename_] = [htmlList[basename_], htmlList[basename]]

print(": '")
count = 1
for n in dupList:
	print("# " + str(count) + ": " + n)
	count += 1
	for m in dupList[n]:
		print("xreader '" + m["line"] + "' &")
print("'")

sys.stderr.write("<table><tbody>\n<tr>")
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
		sys.stderr.write("<td>Internal error, duplicate " + str(dup) + "</td>")
	sys.stderr.write("</tr>\n")
	pageNumber += 1

sys.stderr.write("</tbody></table>\n")

