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
	print 'NODASHES (0 or 1, default 0 of omitted) is an indication to ignore all dashes'
	print '         in comments. (This switch is used only in debugging.)'
	sys.exit()

backgroundImage = sys.argv[1]
outImage = sys.argv[2]
pageNumber = int(sys.argv[3])
agcSourceFilename = sys.argv[4]
if len(sys.argv) >= 6:
	noDashes = int(sys.argv[5])
else:
	noDashes = 0

# Read in the input image ... i.e., the B&W octal page.
img = Image(filename=backgroundImage)
backgroundWidth = img.width
backgroundHeight = img.height
# Make certain conversions on the background image.
img.type = 'truecolor'
img.alpha_channel = 'activate'

# Shell out to have tesseract generate the box file, and read it in.
# While reading it in, we will reject all boxes that appear to us to be
# noise, and moreover will form an array of the average widths of the 
# boxes, with a separate width for each row.  This latter data we'll use
# later to try to deduce the columnar alignment of the comments (in terms
# of characters.  For trying to figure this out, we'll only uses alphanumerics,
# other than I and 1, and only within a certain range of widths.
call([ 'tesseract', backgroundImage, 'eng.agc.exp0', '-psm', '6', 'batch.nochop', 'makebox', 'agcChars.txt' ])
file =open ('eng.agc.exp0.box', 'r')
boxes = []
sumBoxWidthsByLine = [0]
numBoxesByLine = [0]
charForWidthsPattern = re.compile(r"[A-HK-Z02-9]")
rowFloor = 15
row = 0
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
		# New line?
		boxIndex = len(boxes)
		if boxIndex > 0:
		   	if boxLeft < boxes[boxIndex-1]['boxLeft'] or boxBottom > boxes[boxIndex-1]['boxBottom'] + rowFloor:
		   		sumBoxWidthsByLine.append(0)
		   		numBoxesByLine.append(0)
		   		row += 1
		# Is it a box we want to use for figuring out the width of space characters?
		if re.match(charForWidthsPattern,boxChar) and boxWidth > 16 and boxWidth < 24:
			row = len(numBoxesByLine) - 1
			sumBoxWidthsByLine[row] += boxWidth
			numBoxesByLine[row] += 1
		boxes.append({'boxChar':boxChar, 'boxLeft':boxLeft, 'boxBottom':boxBottom,
			      'boxRight':boxRight, 'boxTop':boxTop, 'boxWidth':boxWidth, 
			      'boxHeight':boxHeight})
file.close()

# At this point, one thing we have, for each row of characters, is the sum of all the box widths
# for "wide" characters (e.g., not I or 1), and the number of boxes used to compute the sum.
# These are in the sumBoxWidthsByLine[] and numBoxesByLine[] arrays, respectively.  If we divide
# the one by the other, we'll have an average character width, and from that we'll have a basis
# for guessing the width of the space character --- which varies by line, because the projection
# of the page image isn't perfectly rectangular --- for each line.  However, there will be a 
# lot of variation, due to the fact that the data is so imperfect, so actually create a regression
# line for width vs line-number, and use that regression line (alpha + beta * row) to estimate 
# the character widths, instead of using the raw line-by-line data.  A weighted least-squares fit 
# is used, in which the weights come from numBoxesByLine[].
widthsEstimated = 0
alpha = 0
beta = 0
S0 = 0
S1 = 0
S00 = 0
S01 = 0
S11 = 0
for i in range(0,len(numBoxesByLine)):
	S0 += sumBoxWidthsByLine[i]
	S1 += i * sumBoxWidthsByLine[i]
	S00 += numBoxesByLine[i]
	S01 += i * numBoxesByLine[i]
	S11 += i * i * numBoxesByLine[i]
denom = S00 * S11 - S01 * S01
if denom != 0:
	widthsEstimated = 1
	alpha = float(S0 * S11 - S1 * S01) / denom
	beta = float(S1 * S00 - S0 * S01) / denom
if widthsEstimated:
	print alpha, beta
	for i in range(0,len(numBoxesByLine)):
		if numBoxesByLine[i] == 0:
			numBoxesByLine[i] = 1
		print i, alpha + beta * i, sumBoxWidthsByLine[i], numBoxesByLine[i], float(sumBoxWidthsByLine[i])/numBoxesByLine[i]
else:
	print "Width of spaces not estimated"

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

