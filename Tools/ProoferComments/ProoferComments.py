#!/usr/bin/python
# This file was written by Ron Burkey, who declares it to be in the public domain.

# This program is similar to ProoferBox.py, which is used for checking octals
# from AGC listings, but instead it check the program comments in AGC listings.
#
# This program assumes that all "modern" comments are marked with ## or ###, and
# are completely ignored, except that it assumes page markings of the form "## Page N"
# are present.

import sys
import re
import os.path
from subprocess import call
from wand.image import Image, COMPOSITE_OPERATORS
from wand.drawing import Drawing
from wand.color import Color

# Parse command-line arguments
if len(sys.argv) < 5:
	print 'Usage:'
	print '\t./ProoferComments.py BWINPUTIMAGE OUTPUTIMAGE PAGENUMBER AGCSOURCEFILE [NODASHES]'
	print 'BWINPUTIMAGE is the pathname to the B&W cropped image with just the comments.'
	print 'OUTPUTIMAGE is the pathname at which to write the composite proofing image.'
	print 'PAGENUMBER is the page number within the original scanned assembly listing.'
	print 'AGCSOURCEFILE is the pathname of the AGC source file containing the PAGENUMBER.'
	print 'NODASHES (0 or 1, default 1 of omitted) is an indication to ignore all dashes'
	print '         in comments. (This switch is used only in debugging.)'
	sys.exit()

backgroundImage = sys.argv[1]
outImage = sys.argv[2]
pageNumber = int(sys.argv[3])
agcSourceFilename = sys.argv[4]
noDashes = int(sys.argv[5])

# Read in the input image ... i.e., the B&W octal page.
img = Image(filename=backgroundImage)
backgroundWidth = img.width
backgroundHeight = img.height
# Make certain conversions on the background image.
img.type = 'truecolor'
img.alpha_channel = 'activate'

# Shell out to have tesseract generate the box file, and read it in..
call([ 'tesseract', backgroundImage, 'eng.burst.exp0', '-psm', '6', 'batch.nochop', 'makebox' ])
file =open ('eng.burst.exp0.box', 'r')
boxes = []
for box in file:
	boxFields = box.split()
	boxChar = boxFields[0]
	boxLeft = int(boxFields[1])
	boxBottom = backgroundHeight - 1 - int(boxFields[2])
	boxRight = int(boxFields[3])
	boxTop = backgroundHeight - 1 - int(boxFields[4])
	boxWidth = boxRight + 1 - boxLeft
	boxHeight = boxBottom + 1 - boxTop
	addIt = 0
	if boxWidth > 8 and boxHeight > 8 and boxWidth < 24 and boxHeight < 40:
		addIt = 1 # For general characters.
	if boxWidth > 4 and boxWidth < 9 and boxHeight > 16 and boxHeight < 32:
		addIt = 1 # For parentheses.
	if boxHeight > 3 and boxHeight < 8 and boxWidth > 16 and boxWidth < 24:
		addIt = 1 # For minus signs.
	if addIt:
		boxes.append({'boxChar':boxChar, 'boxLeft':boxLeft, 'boxBottom':boxBottom,
			      'boxRight':boxRight, 'boxTop':boxTop, 'boxWidth':boxWidth, 
			      'boxHeight':boxHeight})
file.close()

# Read in the AGC source file.
file = open (agcSourceFilename, 'r')
lines = []
currentPage = -1
blankLinePattern = re.compile(r"\A\s*\Z")
allMinusPattern = re.compile(r"\A\s*[-][-\s]*\Z")
allUnderscorePattern = re.compile(r"\A\s*_[_\s]*\Z")
for line in file:
	if line.lower().startswith("## page "):
		fields = line.split()
		currentPage = int(fields[2])
		continue
	if currentPage > pageNumber:
		break;
	if currentPage < pageNumber:
		continue
	parts = line.partition("#") # Find the start of the comment, if any.
	if parts[0] == line or parts[2].startswith("#"): # If no comment, or a ##-style comment, ignore the line.
		continue
	comment = parts[2]
	if noDashes:
		comment = comment.replace("-", "")
	if re.match(blankLinePattern, comment): # And if the comment itself is blank, ignore the line too.
		continue
	#if re.match(allMinusPattern, comment): # Rows of all dashes or underscores don't seem to appear in box files.
	#	continue
	#if re.match(allUnderscorePattern, comment): # Rows of all dashes or underscores don't seem to appear in box files.
	#	continue
	lines.append(comment)
file.close()

# At this point, we've populated lines[] with just the non-blank comments from,
# the selected page, which is precisely what should appear in the box file as well.

# Read in the "font" files.
imagesMatch = []
for ascii in range(128):
	filename = "asciiFont/match" + str(ascii) + ".png"
	if os.path.isfile(filename):
		imagesMatch.append(Image(filename=filename))
	else:
		imagesMatch.append(Image(filename="asciiFont/127.png"))
imagesNomatch = []
for ascii in range(128):
	filename = "asciiFont/nomatch" + str(ascii) + ".png"
	if os.path.isfile(filename):
		imagesNomatch.append(Image(filename=filename))
	else:
		imagesNomatch.append(Image(filename="asciiFont/127.png"))

# Loop on lines on the selected page.  
draw = Drawing()
rowFloor = 15
row = 0
boxIndex = 0
for row in range(0, len(lines)):
	if boxIndex >= len(boxes):
		print 'Out of boxes in page, on row', row
		break
	# Loop on non-blank characters in the row.
	firstChar = 1
	for character in list(lines[row]):
		if re.match(blankLinePattern, character):
			continue
		if boxIndex >= len(boxes):
			print 'Out of boxes in page, on row', row, "character", character
			break
		if boxIndex > 0 and not firstChar:
			if boxes[boxIndex]['boxLeft'] < boxes[boxIndex-1]['boxLeft'] or \
			   boxes[boxIndex]['boxBottom'] > boxes[boxIndex-1]['boxBottom'] + rowFloor:
				print 'Out of boxes in row', row, "character", character
				break
		firstChar = 0
		asciiCode = ord(character)
		if boxes[boxIndex]['boxChar'] == character:
			fontChar = imagesMatch[asciiCode].clone()
		else:
			fontChar = imagesNomatch[asciiCode].clone()
		operator = 'darken' 
		fontChar.resize(boxes[boxIndex]['boxWidth'], boxes[boxIndex]['boxHeight'], 'cubic')
		draw.composite(operator=operator, left=boxes[boxIndex]['boxLeft'], 
			       top=boxes[boxIndex]['boxTop'], width=boxes[boxIndex]['boxWidth'], 
			       height=boxes[boxIndex]['boxHeight'], image=fontChar)
		boxIndex += 1
	
	if boxIndex > 0 and boxIndex < len(boxes) and \
	   boxes[boxIndex]['boxLeft'] >= boxes[boxIndex-1]['boxLeft'] and \
	   boxes[boxIndex]['boxBottom'] <= boxes[boxIndex-1]['boxBottom'] + rowFloor:
	   	print 'Extra boxes in row', row
		while boxIndex < len(boxes):
			if boxes[boxIndex]['boxLeft'] < boxes[boxIndex-1]['boxLeft'] or \
			   boxes[boxIndex]['boxBottom'] > boxes[boxIndex-1]['boxBottom'] + rowFloor:
				break
			boxIndex += 1
draw(img)

# Create the output image.
img.format = 'png'
img.save(filename=outImage)
print 'output =', outImage

