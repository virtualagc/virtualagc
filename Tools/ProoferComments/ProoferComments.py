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
if len(sys.argv) != 5:
	print 'Usage:'
	print '\t./ProoferComments.py BWINPUTIMAGE OUTPUTIMAGE PAGENUMBER AGCSOURCEFILE'
	sys.exit()

backgroundImage = sys.argv[1]
outImage = sys.argv[2]
pageNumber = int(sys.argv[3])
agcSourceFilename = sys.argv[4]

# Shell out to have tesseract generate the box file, and read it in..
call([ 'tesseract', backgroundImage, 'eng.burst.exp0', '-psm', '6', 'batch.nochop', 'makebox' ])
file =open ('eng.burst.exp0.box', 'r')
boxes = file.readlines()
file.close()

# Read in the AGC source file.
file = open (agcSourceFilename, 'r')
lines = []
currentPage = -1
blankLinePattern = re.compile(r"\A\s*\Z")
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
	if re.match(blankLinePattern, parts[2]): # And if the comment itself is blank, ignore the line too.
		continue;
	lines.append(parts[2])
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

# Read in the input image ... i.e., the B&W octal page.
img = Image(filename=backgroundImage)
backgroundWidth = img.width
backgroundHeight = img.height

# Make certain conversions on the background image.
img.type = 'truecolor'
img.alpha_channel = 'activate'

# Loop on lines on the selected page.  
draw = Drawing()
row = 0
lastX = -1 # When the x coordinate of a box suddenly decreases, it marks a new row.
lastY = 1000000 # Or when the y coordinate increases by more than a pixel or two.
boxIndex = 0
for row in range(0, len(lines)):
	if boxIndex >= len(boxes):
		print 'Out of boxes on page'
		break
	# Loop on non-blank characters in the row.
	characters = list(lines[row])
	for character in characters:
		if re.match(blankLinePattern, character):
			continue
		if boxIndex >= len(boxes):
			print 'Out of boxes in row'
			break
		# Parse the box entry.
		boxFields = boxes[boxIndex].split()
		boxChar = boxFields[0]
		boxLeft = int(boxFields[1])
		boxBottom = backgroundHeight -1 - int(boxFields[2])
		boxRight = int(boxFields[3])
		boxTop = backgroundHeight - 1 - int(boxFields[4])
		boxWidth = boxRight + 1 - boxLeft
		boxHeight = boxBottom + 1 - boxTop
		if boxLeft < lastX or boxBottom > lastY + 15: # We've run out of boxes on this row.
			lastX = boxLeft
			lastY = boxBottom
			break
		lastX = boxLeft
		lastY = boxBottom
		
		asciiCode = ord(character)
		if boxChar == character:
			fontChar = imagesMatch[asciiCode].clone()
		else:
			fontChar = imagesNomatch[asciiCode].clone()
		operator = 'darken' 
		fontChar.resize(boxWidth, boxHeight, 'cubic')
		draw.composite(operator=operator, left=boxLeft, top=boxTop, width=boxWidth, height=boxHeight, image=fontChar)
		boxIndex += 1
	# We're finished with the characters from the comment, but it's conceivable that
	# there could still be more boxes in this row, because of some kind of mismatch.
	# We would then need to move along in the boxes[] array until reaching the next line.
	while 1:
		if boxIndex >= len(boxes):
			break
		# Parse the box entry.
		boxFields = boxes[boxIndex].split()
		boxChar = boxFields[0]
		boxLeft = int(boxFields[1])
		boxBottom = backgroundHeight -1 - int(boxFields[2])
		boxRight = int(boxFields[3])
		boxTop = backgroundHeight - 1 - int(boxFields[4])
		boxWidth = boxRight + 1 - boxLeft
		boxHeight = boxBottom + 1 - boxTop
		if boxLeft < lastX or boxBottom > lastY + 15: # We've run out of boxes on this row.
			lastX = boxLeft
			lastY = boxBottom
			break
		laxtX = boxLeft
		lastY = boxBottom
		boxIndex += 1
draw(img)

# Create the output image.
img.format = 'png'
img.save(filename=outImage)
print 'output =', outImage

