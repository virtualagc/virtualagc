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
	print '\t./ProoferComments.py BWINPUTIMAGE OUTPUTIMAGE PAGENUMBER AGCSOURCEFILE [SCALE [NODASHES]]'
	print 'BWINPUTIMAGE is the pathname to the B&W cropped image with just the comments.'
	print 'OUTPUTIMAGE is the pathname at which to write the composite proofing image.'
	print 'PAGENUMBER is the page number within the original scanned assembly listing.'
	print 'AGCSOURCEFILE is the pathname of the AGC source file containing the PAGENUMBER.'
	print '      The AGC-file inclusion directive $ is supported, so the top-level file'
	print '      MAIN.agc can be used in order to make scripting easier.' 
	print 'SCALE (optional, default 1.0) represents the resolution of the imagery, relative'
	print '      to archive.org\'s scan of Luminary 210.  The process is not very sensitive'
	print '      to this, but some imagery obtained by other means is significantly different'
	print '      in scale, and should be adjusted with this parameter.  Think of it as being'
	print '      a multiplier for the DPI.  (By which I mean the true DPI of the physical'
	print '      page, and not the value for the DPI embedded in the graphics files, which'
	print '      may not be accurate.)'
	print 'NODASHES (optional, default 0) if > 1, removes comments which are nothing more'
	print '      than rows of dashes or underlines.  This is needed because sometimes Tesseract'
	print '      simply refuses to create bounding boxes for such lines.  If nodashes>=1,'
	print '      then all dashes (not just rows consisting exclusively of them) are removed,'
	print '      while if nodashes>=2 then all underlines are removed as well.'
	sys.exit()

backgroundImage = sys.argv[1]
if not os.path.isfile(backgroundImage):
	print "Error: Input image file", backgroundImage, "does not exist"
	sys.exit(1)
outImage = sys.argv[2]
pageNumber = int(sys.argv[3])
agcSourceFilename = sys.argv[4]
if not os.path.isfile(agcSourceFilename):
	print "Error: Input source file", agcSourceFilename, "does not exist"
	sys.exit(1)
agcSourceDirectory = os.path.split(agcSourceFilename)[0]
if len(sys.argv) >= 6:
	scale = float(sys.argv[5])
else:
	scale = 1.0
if len(sys.argv) >= 7:
	nodashes = int(sys.argv[6])
else:
	nodashes = 0

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
rejectedBoxes = []
sumBoxWidthsByLine = [0]
numBoxesByLine = [0]
charForWidthsPattern = re.compile(r"[A-HK-Z02-9]")
rowFloor = 15 * scale
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
	if boxWidth > 8 * scale and boxHeight > 8 * scale and boxWidth < 28 * scale and boxHeight < 44 * scale:
		addIt = 1 # For general characters.
	# The following one is a very tough compromise.  Make it too small, and you miss some poorly-printed
	# parentheses and L's that are printed too low.  Make it too big, and you add in some extra gunk
	# that some printouts (like Sunburst 120) liked to stick in as short vertical line segments next to
	# characters like M or H.  And either one messes up the alignment of the remainder of the line, making
	# it unproofable.  So take care in adjusting this.
	if boxWidth > 4 * scale and boxWidth < 9 * scale and boxHeight > 25 * scale and boxHeight < 32 * scale:
		addIt = 1 # For parentheses.
	if boxWidth > 5 * scale and boxWidth < 9 * scale and boxHeight > 20 * scale and boxHeight < 32 * scale:
		addIt = 1 # For T's with cut-off tops.
	if boxHeight > 3 * scale and boxHeight < 10 * scale and boxWidth > 16 * scale and boxWidth < 24 * scale:
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
	else:
		rejectedBoxes.append({'boxChar':boxChar, 'boxLeft':boxLeft, 'boxBottom':boxBottom,
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
if 0:
	if widthsEstimated:
		print alpha, beta
		for i in range(0,len(numBoxesByLine)):
			if numBoxesByLine[i] == 0:
				numBoxesByLine[i] = 1
			print i, alpha + beta * i, sumBoxWidthsByLine[i], numBoxesByLine[i], float(sumBoxWidthsByLine[i])/numBoxesByLine[i]
	else:
		print "Width of spaces not estimated"

# Read in the AGC source file.
lines = []
currentPage = -1
blankLinePattern = re.compile(r"\A\s*\Z")
allDashesPattern = re.compile(r"\A\s*[-][-\s]*\Z")
allUnderlinesPattern = re.compile(r"\A\s*[_][_\s]*\Z")
def readFile( filename ):
	"Reads an AGC source file, recursively if containing $ operators."
	global lines, currentPage, pageNumber, blankLinePattern, allDashesPattern, allUnderlinesPattern, nodashes
	#print "Reading file", filename
	file = open (filename, 'r')
	for rawline in file:
		line = rawline.rstrip()
		if line.startswith("$"):
			includedFile = re.sub(r'^[$](.*[.]agc).*', r'\1', line)
			#print "Here '", includedFile, "'"
			readFile(agcSourceDirectory + "/" + includedFile)
			continue
		#if line.lower().startswith("## page "):
		if re.match(r"## page [0-9].*", line.lower()):
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
		if re.match(blankLinePattern, comment): # And if the comment itself is blank, ignore the line too.
			continue
		if nodashes >= 1 and re.match(allDashesPattern, comment):
			continue
		if nodashes >= 1 and re.match(allUnderlinesPattern, comment):
			continue
		if nodashes >= 2:
			comment = comment.replace("-", "")
		if nodashes >= 3:
			comment = comment.replace("_", "")
		lines.append(comment)
	file.close()
readFile(agcSourceFilename)

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

# Prepare a drawing-context.
draw = Drawing()
evilColor = Color("#FF00FF")
extraColor = Color("#FF8000")
draw.stroke_color = evilColor
draw.stroke_width = 4 * scale
draw.fill_opacity = 0

# Draw empty frames around all of the rejected boxes.
for i in range(0,len(rejectedBoxes)):
	boxTop = rejectedBoxes[i]['boxTop']
	boxBottom= rejectedBoxes[i]['boxBottom']
	boxLeft = rejectedBoxes[i]['boxLeft']
	boxRight = rejectedBoxes[i]['boxRight']
	draw.line((boxLeft,boxTop), (boxRight,boxTop))
	draw.line((boxLeft,boxBottom), (boxRight,boxBottom))
	draw.line((boxRight,boxTop), (boxRight,boxBottom))
	draw.line((boxLeft,boxTop), (boxLeft,boxBottom))

# Loop on lines on the selected page.  
row = 0
boxIndex = 0
draw.stroke_color = extraColor
for row in range(0, len(lines)):
	if boxIndex >= len(boxes):
		if boxIndex < 1:
			top = 0
		else:
			#print 'Out of boxes in page, on row', row
			top = boxes[boxIndex-1]['boxBottom']
		bottom = backgroundHeight
		middle = backgroundWidth / 2
		draw.line((middle,top), (middle,bottom))
		break
	# Loop on non-blank characters in the row.
	firstChar = 1
	for character in list(lines[row]):
		if re.match(blankLinePattern, character):
			continue
		if boxIndex >= len(boxes):
			#print 'Out of boxes in page, on row', row, "character", character
			top = boxes[boxIndex-1]['boxBottom']
			bottom = backgroundHeight
			middle = backgroundWidth / 2
			draw.line((middle,top), (middle,bottom))
			break
		if boxIndex > 0 and not firstChar:
			if boxes[boxIndex]['boxLeft'] < boxes[boxIndex-1]['boxLeft'] or \
			   boxes[boxIndex]['boxBottom'] > boxes[boxIndex-1]['boxBottom'] + rowFloor:
				#print 'Out of boxes in row', row, "character", character
				left = boxes[boxIndex-1]['boxRight']
				right = backgroundWidth
				middle = (boxes[boxIndex-1]['boxTop'] + boxes[boxIndex-1]['boxBottom']) / 2
				draw.line((left,middle), (right,middle))
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
	   	#print 'Extra boxes in row', row
		while boxIndex < len(boxes):
			if boxes[boxIndex]['boxLeft'] < boxes[boxIndex-1]['boxLeft'] or \
			   boxes[boxIndex]['boxBottom'] > boxes[boxIndex-1]['boxBottom'] + rowFloor:
				break
			else:
				boxTop = boxes[boxIndex]['boxTop']
				boxBottom= boxes[boxIndex]['boxBottom']
				boxLeft = boxes[boxIndex]['boxLeft']
				boxRight = boxes[boxIndex]['boxRight']
				draw.line((boxLeft,boxTop), (boxRight,boxTop))
				draw.line((boxLeft,boxBottom), (boxRight,boxBottom))
				draw.line((boxRight,boxTop), (boxRight,boxBottom))
				draw.line((boxLeft,boxTop), (boxLeft,boxBottom))
			boxIndex += 1

# Perform all the pending drawing operations.
draw(img)

# Create the output image.
img.format = 'png'
img.save(filename=outImage)
print 'output =', outImage

