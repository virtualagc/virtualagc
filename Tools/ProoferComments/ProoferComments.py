#!/usr/bin/python
# coding=utf-8
# NOTE: The reason the encoding of this file is specified as UTF-8 is that Tesseract
# sometimes returns UTF-8 characters as its guesses, and in those rare cases that 
# we're actually interested in what Tesseract thinks, we may have string literals 
# whose values are UTF-8.  The only example of this as I'm writing this is the
# hyphen filter.

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
from os import environ
from subprocess import call
from wand.image import Image, COMPOSITE_OPERATORS
from wand.drawing import Drawing
from wand.color import Color

tesseract = 'tesseract'
if 'BIN' in environ:
	tesseract = environ['BIN'] + '/tesseract'
Solarium55 = 0
if 'SOLARIUM55' in environ:
	Solarium55 = 1
Colossus237 = 0
if 'COLOSSUS237' in environ:
	Colossus237 =1
Retread44 = 0
if 'RETREAD44' in environ:
	Retread44 =1

# Parse command-line arguments
if len(sys.argv) < 5:
	print 'Usage:'
	print '\t./ProoferComments.py BWINPUTIMAGE OUTPUTIMAGE PAGENUMBER AGCSOURCEFILE [SCALE [NODASHES [PSM]]]'
	print 'BWINPUTIMAGE is the pathname to the B&W cropped image with just the comments.'
	print 'OUTPUTIMAGE is the pathname at which to write the composite proofing image.'
	print 'PAGENUMBER is the page number within the original scanned assembly listing.'
	print 'AGCSOURCEFILE is the pathname of the AGC source file containing the PAGENUMBER.'
	print '      The AGC-file inclusion directive $ is supported, so the top-level file'
	print '      MAIN.agc can be used in order to make scripting easier.' 
	print 'SCALE (optional, default 1.0) represents the resolution of the imagery, relative'
	print '      to archive.org\'s scan of Sunburst 120.  The process is not *very* sensitive'
	print '      to this, but you will want to adjust it if it is too far from 1.0.'
	print '      For Aurora 12 scans I settled on SCALE=0.711111.  (Sadly,'
	print '      not all of the archive.org pages have precisely identical dimensions, even'
	print '      when those pages are all from the sames set of scans for the same harcopy.)'
	print '      Non-archive.org imagery has a very different scale. Think of SCALE as being'
	print '      a multiplier for the DPI.  (By which I mean the true DPI of the physical'
	print '      page, and not the value for the DPI embedded in the graphics files, which'
	print '      may not be accurate.)'
	print 'NODASHES (optional, default 0) if > 1, removes comments which are nothing more'
	print '      than rows of dashes or underlines.  This is needed because sometimes Tesseract'
	print '      simply refuses to create bounding boxes for such lines.  If nodashes>=1,'
	print '      then all dashes (not just rows consisting exclusively of them) are removed,'
	print '      while if nodashes>=2 then all underlines are removed as well.'
	print 'PSM (optional, default 4) is a parameter passed to Tesseract for finding bounding'
	print '      boxes of characters in the input image.  Both 4 and 6 work fairly well, but'
	print '      sadly, on individual pages one or the other may be better than the other.'
	print '      I think that PSM = 4 is marginally better on the average, but 6 is safer.'
	print '      It\'s also true that Tesseract 3 and Tesseract 4 may produce better or worse'
	print '      bounding boxes at different locations on different pages.  I don\'t provide'
	print '      any specific option for that, however.  I don\'t know if training affects the'
	print '      selection of bounding boxes or not.'
	print 'There are also several environment variables that activate filters or font-changes'
	print 'specific to particular AGC printouts:'
	print '      RETREAD44'
	print '      SOLARIUM55'
	print '      COLOSSUS237'
	print 'To use, you should do something like "export COLOSSUS237=yes".'
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
if len(sys.argv) >= 8:
	psm = sys.argv[7]
else:
	psm = '6'

# Read in the input image ... i.e., the B&W octal page.
img = Image(filename=backgroundImage)
backgroundWidth = img.width
backgroundHeight = img.height
middleFloor = 2 * img.height / 5
middleCeiling = 3 * img.height / 5
# Make certain conversions on the background image.
img.type = 'truecolor'
#img.alpha_channel = 'activate'

# Shell out to have tesseract generate the box file, and read it in.
# While reading it in, we will reject all boxes that appear to us to be
# noise, and moreover will form an array of the average widths of the 
# boxes, with a separate width for each row.  This latter data we'll use
# later to try to deduce the columnar alignment of the comments (in terms
# of characters.  For trying to figure this out, we'll only uses alphanumerics,
# other than I and 1, and only within a certain range of widths.
# Mike advises to *always* use -psm=6, but -psm=4 works better for me (less
# bad bounding boxes and text having no bounding boxes at all), and I don't
# see the extra processing time he warns about. 
call([ tesseract, backgroundImage, 'eng.agc.exp0', '-psm', psm, 'batch.nochop', 'makebox', 'agcChars.txt' ])
file =open ('eng.agc.exp0.box', 'r')
boxes = []
rejectedBoxes = []
pendingBoxes = []
sumBoxWidthsByLine = [0]
numBoxesByLine = [0]
charForWidthsPattern = re.compile(r"[A-HK-Z02-9]")
rowFloor = 15 * scale
#sumBottomsInRow = 0
numCharsInRow = 0
avgBottom = 0
decayBottom = 0.8
numBoxWidths = 10
sumBoxWidths = 16 * numBoxWidths * scale
nominalColSpacing = 4 * scale
nominalRowSpacing = 10 * scale
nominalRowHeight = 24 * scale
nominalTwoRowHeight = nominalRowHeight + nominalRowSpacing + nominalRowHeight
row = 0
alnumPattern = re.compile(r"[0-9A-Z]")
lastBoxChar = '?'
lastHyphenMidPoint = 0
lastX = 0
lastY = 0
for box in file:
	newline = 0
	boxFields = box.split()
	boxChar = boxFields[0]
	boxLeft = int(boxFields[1])
	boxBottom = backgroundHeight - 1 - int(boxFields[2])
	boxRight = int(boxFields[3])
	boxTop = backgroundHeight - 1 - int(boxFields[4])
	boxWidth = boxRight + 1 - boxLeft
	boxHeight = boxBottom + 1 - boxTop
	if boxLeft < lastX or boxBottom > lastY + rowFloor:
		newline = 1;
	lastX = boxLeft
	lastY = boxBottom
	# Take care of a box in the pendingBoxes[] array, if there is one.
	# This algorithm is going to discard the box if it happens to be at
	# the very end of the row, but I don't really care about that.
	if len(boxes) > 0 and len(pendingBoxes) > 0:
		#refBottom = (sumBottomsInRow + boxBottom + 0.0) / (numCharsInRow + 1)
		if pendingBoxes[0]['boxBottom'] < boxTop:
			rejectedBoxes.append(pendingBoxes[0])
			del pendingBoxes[0]
		elif pendingBoxes[0]['boxTop'] >= boxBottom - 1.3 * nominalRowHeight and \
		     pendingBoxes[0]['boxBottom'] < boxBottom + 0.6 * nominalRowHeight and \
		     pendingBoxes[0]['boxRight'] <= boxLeft:
		     	lastBox = boxes[len(boxes)-1]
		     	startOfRow = 0
		     	if pendingBoxes[0]['boxLeft'] < lastBox['boxLeft']:
		     		startOfRow = 1
		     	#if numCharsInRow > 0 and pendingBoxes[0]['boxBottom'] > sumBottomsInRow/numCharsInRow + rowFloor:
		     	#	startOfRow = 1
		     	if numCharsInRow > 0 and pendingBoxes[0]['boxBottom'] > avgBottom + rowFloor:
		     		startOfRow = 1
		     	if startOfRow == 0 or pendingBoxes[0]['boxLeft'] >= lastBox['boxRight']:
			     	# Add the pending box to the list of actual boxes.  Normally these
			     	# are one character wide, but I've actually seen cases where they're
			     	# more (such as 3 cols by 2 rows, in which case the pending box would
			     	# actually be 3 wide), so we have to perform additional splits in this
			     	# case.  The computation models the one performed a little later for
			     	# the "real" boxes (as opposed to split ones).
				avgBoxWidth = float(sumBoxWidths) / numBoxWidths
				width = pendingBoxes[0]['boxWidth']
				widthRatio = width/avgBoxWidth
				if 1 or widthRatio < 1.5:
					boxes.append(pendingBoxes[0])
				else:
					n = int(round((width + nominalColSpacing)/(avgBoxWidth+nominalColSpacing)))
					width = int(width/n) - 1
					height = pendingBoxes[0]['boxHeight']
					left = pendingBoxes[0]['boxLeft']
					right = int(round(left + width - 1 + nominalColSpacing))
					top = pendingBoxes[0]['boxTop']
					bottom = pendingBoxes[0]['boxBottom']
					for i in range(0,n):
						boxes.append({'boxChar':boxChar, 'boxLeft':left, 'boxBottom':bottom,
							      'boxRight':right, 'boxTop':top, 'boxWidth':width, 
							      'boxHeight':height})
						left += int(round(width + nominalColSpacing - 1))
						right += int(round(width + nominalColSpacing - 1))
			else:
				if 0:
					print "B"
					print {'boxChar':boxChar, 'boxLeft':boxLeft, 'boxBottom':boxBottom,
					      'boxRight':boxRight, 'boxTop':boxTop, 'boxWidth':boxWidth, 
					      'boxHeight':boxHeight}
					print lastBox
					print pendingBoxes[0]
				rejectedBoxes.append(pendingBoxes[0])
			del pendingBoxes[0]	
	addIt = 0
	addAs = 1
	if boxWidth > 8 * scale and boxHeight > 8 * scale and boxWidth < 28 * scale and boxHeight < 44 * scale:
		addIt = 1 # For general characters.
		numBoxWidths += 1
		sumBoxWidths += boxWidth
	# There's an effect which occurs frequently, but *very* frequently when the contrast in the
	# original scans is poorer (such as non-archive.org imagery) in which wide characters
	# with a narrow crossbar, like M, H, U, and particularly N, may be split into two adjacent
	# boxes.  The following filter tries to detect that case and turn them into a single wider
	# box ... but it only does so within a *very* narrow range of combined-box sizes.
	combinedSomeBoxes = 0
	if len(boxes) > 0:
		# Check both existing boxes[] (whichBoxes==0) and rejectedBoxes[] (whichBoxes==1).
		for whichBoxes in range(0,2):
			if whichBoxes == 0:
				length = len(boxes)
			else:
				length = len(rejectedBoxes)
			if length > 0:
				if whichBoxes == 0:
					lastBox = boxes[len(boxes)-1]
				else:
					lastBox = rejectedBoxes[len(rejectedBoxes)-1]
				lastTop = lastBox['boxTop']
				lastBottom = lastBox['boxBottom']
				lastLeft = lastBox['boxLeft']
				lastRight = lastBox['boxRight']
				combinedWidth = boxRight - lastLeft 
				#print combinedWidth, boxRight, lastLeft
				if combinedWidth >= 13.5 * scale and combinedWidth <= 20.5 * scale:
				   	# Convert all of the lastXXXX variables to describe the
				   	# combined box.  We already know that the width is within
				   	# the range we want, but let's check the height.
				   	lastRight = boxRight
				   	lastWidth = lastRight - lastLeft + 1
				   	if boxBottom > lastBottom:
				   		lastBottom = boxBottom
				   	if boxTop < lastTop:
				   		lastTop = boxTop
				   	lastHeight = lastBottom - lastTop + 1
				   	if lastHeight >= 20 * scale and lastHeight <= 30 * scale:
				   		# Accept it!
						#print combinedWidth, boxRight, lastLeft
				   		if whichBoxes == 0:
					   		boxes[len(boxes)-1]['boxRight'] = lastRight
					   		boxes[len(boxes)-1]['boxLeft'] = lastLeft
					   		boxes[len(boxes)-1]['boxTop'] = lastTop
					   		boxes[len(boxes)-1]['boxBottom'] = lastBottom
					   		boxes[len(boxes)-1]['boxWidth'] = lastWidth
					   		boxes[len(boxes)-1]['boxHeight'] = lastHeight
					   		combinedSomeBoxes = 1
					   		break
						else:
					   		boxRight = lastRight
					   		boxLeft = lastLeft
					   		boxTop = lastTop
					   		boxBottom = lastBottom
					   		boxWidth = lastWidth
					   		boxHeight = lastHeight
					   		addIt = 1
							del rejectedBoxes[len(rejectedBoxes)-1]
	if combinedSomeBoxes:
		continue
	# On a number of these printouts, there's an occasional short vertical stroke immediately to
	# the right of a legitimate character ... perhaps the edge of the physical metal block containing
	# the raised impression of the character itself.  At any rate, octopus's noise filters can't deal
	# it with, and if we don't treat it as special, it will sometimes get past the exceptions we've
	# built in below to allow detection of mutilated parentheses and T's.  What we calculate below is
	# the "distance" between the left-hand edge of the current box and the immediately-preceding
	# box, if in the same row.  If the box is too narrow AND AT THE SAME TIME too close, we will reject it.
	rejectIt = 0
	distance = 100
	if len(boxes) > 0 and boxRight >= boxes[len(boxes)-1]['boxRight'] and \
	   boxBottom <= boxes[len(boxes)-1]['boxBottom'] and boxTop >= boxes[len(boxes)-1]['boxTop']:
		distance = boxRight - boxes[len(boxes)-1]['boxRight']
	if distance < 8 * scale:
		rejectIt = 1
	# In Colossus237, there's an artifact that appears very often, that I've simply gotten tired
	# of editing out: two adjacent short strokes, very near the center of the page, presumably
	# a remnant of a horizontal line.  Fortunately, that lets us make the filter pretty specific.
	if Colossus237 and (boxChar == '_' or boxChar == '-') and boxWidth >= 11 and boxWidth <= 17 and \
		boxHeight >= 4 and boxHeight <= 5 and boxTop > middleFloor and boxTop < middleCeiling:
		rejectIt = 1
	# Here's something to help apostrophes to be recognized.
	#if boxWidth >= 6 * scale and boxWidth <= 8 * scale and boxHeight >= 12 * scale and \
	#   boxHeight <= 17 * scale and numCharsInRow > 0 and \
	#   boxBottom <= (sumBottomsInRow + 0.0)/numCharsInRow - 7 * scale:
	if boxWidth >= 6 * scale and boxWidth <= 8 * scale and boxHeight >= 12 * scale and \
	   boxHeight <= 18 * scale and numCharsInRow > 0 and \
	   boxBottom <= avgBottom - 7 * scale:
	   	addIt = 1 		
	# Here's something to help hyphens to be recognized:
	if boxChar == '-' or boxChar == '_' or boxChar == '—' or boxChar == '—' or boxChar == '=' or boxChar == '~':
		if boxWidth > 14 * scale and boxWidth < 25 * scale and boxHeight > 4 * scale and boxHeight < 10 * scale:
			midPoint = (boxTop + boxBottom) / 2.0
			if newline or numCharsInRow == 0 or \
			   abs(midPoint - avgBottom + 12.5 * scale) <= 3 * scale or \
			   abs(midPoint - lastHyphenMidPoint) <= 2 * scale:
				#print "Adding"
		 		addIt = 1
		 		lastHyphenMidPoint = midPoint
	# And underscores, '_':
	#if (boxChar == '-' or boxChar == '_' or boxChar == '—' or boxChar == '=' or boxChar == '~') and numCharsInRow > 0:
	if numCharsInRow > 0:
		if boxWidth >= 20 * scale and boxWidth <= 26 * scale and boxHeight > 4 * scale and boxHeight < 10 * scale:
			midPoint = (boxTop + boxBottom) / 2.0
			if abs(midPoint - (avgBottom+3*scale)) <= 3 * scale:
		 		addIt = 1
	# And vertical lines, '|', though I guess it may serve for parentheses as well:
	if boxChar == '|' or boxChar == 'I' or boxChar == 'l' or boxChar == '!' or boxChar == '1' or boxChar == '(' or boxChar == ')':
		#print boxChar, boxWidth, boxHeight, scale
		if boxWidth >= 5 * scale and boxWidth <= 8 * scale and boxHeight >= 28 * scale and boxHeight <= 35 * scale:
			#print Added
			addIt = 1
	lastBoxChar = boxChar
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
	# The following is for the wacky boxes N-character wide bounding boxes that Tesseract sometimes produces.
	avgBoxWidth = float(sumBoxWidths) / numBoxWidths
	widthRatio = boxWidth/avgBoxWidth
	if widthRatio > 1.5 and boxHeight > 18 * scale and boxHeight < 36 * scale and not addIt:
		addIt = 1
		addAs = int(round((boxWidth + nominalColSpacing)/(avgBoxWidth+nominalColSpacing)))
	# The following is for the wacky double-high bounding boxes (i.e., containing characters in two different
	# rows) that Tesseract sometimes produces.
	if widthRatio > 0.7 and widthRatio < 1.3 and boxHeight > 0.6 * nominalTwoRowHeight and \
	   boxHeight < 1.2 * nominalTwoRowHeight and not addIt:
		addIt = 1
		# We're going to split the box into two vertically, adding the top half to the current row
		# and putting the bottom half into the pendingBoxes[] array, where it will either be used
		# or discarded when the next row is processed.
		pendingBoxes.append({'boxChar':boxChar, 'boxLeft':boxLeft, 'boxBottom':boxBottom,
			      'boxRight':boxRight, 'boxTop':int(round(boxBottom-nominalRowHeight)), 'boxWidth':boxWidth, 
			      'boxHeight':int(round(nominalRowHeight))})
		boxBottom = int(round(boxTop + nominalRowHeight))
		boxHeight = int(round(nominalRowHeight))
	if addIt and not rejectIt:
		# New line?
		boxIndex = len(boxes)
		if numCharsInRow > 0:
		   	#if boxLeft < boxes[boxIndex-1]['boxLeft'] or boxBottom > sumBottomsInRow/numCharsInRow + rowFloor:
		   	if boxLeft < boxes[boxIndex-1]['boxLeft'] or boxBottom > avgBottom + rowFloor:
		   		sumBoxWidthsByLine.append(0)
		   		numBoxesByLine.append(0)
		   		row += 1
		   		#sumBottomsInRow = 0
		   		avgBottom = 0
		   		numCharsInRow = 0
		# Is it a box we want to use for figuring out the width of space characters?
		if re.match(charForWidthsPattern,boxChar) and boxWidth > 16 and boxWidth < 24:
			row = len(numBoxesByLine) - 1
			sumBoxWidthsByLine[row] += boxWidth
			numBoxesByLine[row] += 1
		boxWidth = int(boxWidth/addAs) - 1
		boxRight = int(round(boxLeft + boxWidth - 1 + nominalColSpacing))
		for i in range(0,addAs):
			if alnumPattern.match(boxChar):
				#sumBottomsInRow += boxBottom
				if numCharsInRow == 0:
					avgBottom = boxBottom
				else:
					avgBottom = (1.0 - decayBottom) * boxBottom + decayBottom * avgBottom
				numCharsInRow += 1
			boxes.append({'boxChar':boxChar, 'boxLeft':boxLeft, 'boxBottom':boxBottom,
				      'boxRight':boxRight, 'boxTop':boxTop, 'boxWidth':boxWidth, 
				      'boxHeight':boxHeight})
			boxLeft += int(round(boxWidth + nominalColSpacing - 1))
			boxRight += int(round(boxWidth + nominalColSpacing - 1))	
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
allDotsPattern = re.compile(r"^\s*[.][.\s]*$")
allEqualsPattern = re.compile(r"\A\s*=[=\s]*\Z")
def readFile( filename, depth ):
	"Reads an AGC source file, recursively if containing $ operators."
	global lines, currentPage, pageNumber, blankLinePattern, allDashesPattern, allUnderlinesPattern, nodashes
	#print "Reading file", filename
	file = open (filename, 'r')
	for rawline in file:
		line = rawline.rstrip()
		if line.startswith("$"):
			includedFile = re.sub(r'^[$](.*[.]agc).*', r'\1', line)
			#print "Here '", includedFile, "'"
			readFile(agcSourceDirectory + "/" + includedFile, depth + 1)
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
		#if nodashes >= 1 and re.match(allDotsPattern, comment):
		#	continue
		if nodashes >= 1 and re.match(allEqualsPattern, comment):
			continue
		if nodashes >= 2:
			comment = comment.replace("-", "")
		if nodashes >= 3:
			comment = comment.replace("_", "")
		if depth > 0:
			lines.append(comment)
	file.close()
readFile(agcSourceFilename, 0)
#print lines

# At this point, we've populated lines[] with just the non-blank comments from,
# the selected page, which is precisely what should appear in the box file as well.

# Read in the "font" files.
imagesMatch = []
for ascii in range(128):
	filename = "asciiFont/match" + str(ascii) + ".png"
	if os.path.isfile(filename):
		imagesMatch.append(Image(filename=filename))
	else:
		imagesMatch.append(Image(filename="asciiFont/match127.png"))
imagesNomatch = []
for ascii in range(128):
	filename = "asciiFont/nomatch" + str(ascii) + ".png"
	if os.path.isfile(filename):
		imagesNomatch.append(Image(filename=filename))
	else:
		imagesNomatch.append(Image(filename="asciiFont/nomatch127.png"))
# Some of the printers in specific printouts had S or * characters that were different
# enough that I feel as though I should tweak them.
if Solarium55 or Colossus237:
	imagesMatch[83] = Image(filename="asciiFont/match83S.png")
	imagesNomatch[83] = Image(filename="asciiFont/nomatch83S.png")
if Solarium55 or Retread44:
	imagesMatch[42] = Image(filename="asciiFont/match42S.png")
	imagesNomatch[42] = Image(filename="asciiFont/nomatch42S.png")

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
	#sumBottomsInRow = 0
	avgBottom = 0
	numCharsInRow = 0
	charList = list(re.sub(r"\s+" ,"", lines[row]))
	for index in range(0,len(charList)):
		character = charList[index]
		#if re.match(blankLinePattern, character):
		#	continue
		if boxIndex >= len(boxes):
			#print 'Out of boxes in page, on row', row, "character", character
			top = boxes[boxIndex-1]['boxBottom']
			bottom = backgroundHeight
			middle = backgroundWidth / 2
			draw.line((middle,top), (middle,bottom))
			break
		if numCharsInRow > 0:
			#if boxes[boxIndex]['boxLeft'] < boxes[boxIndex-1]['boxLeft'] or \
			#   boxes[boxIndex]['boxBottom'] > sumBottomsInRow/numCharsInRow + rowFloor:
			if boxes[boxIndex]['boxLeft'] < boxes[boxIndex-1]['boxLeft'] or \
			   boxes[boxIndex]['boxBottom'] > avgBottom + rowFloor:
				#print 'Out of boxes in row', row, "character", character
				left = boxes[boxIndex-1]['boxRight']
				right = backgroundWidth
				middle = (boxes[boxIndex-1]['boxTop'] + boxes[boxIndex-1]['boxBottom']) / 2
				draw.line((left,middle), (right,middle))
				break
		
		# "octopus --comments" often removes '=' from its output images, which is very troublesome.
		# However, there are patterns we can try to use to reinsert an = where one is missing.
		# ... The same also turns out to be true for various other characters.
		goneMissing = [ '=', '-', '_', ':' ]
		lastRight = 0
		if (numCharsInRow > 0):
			lastRight = boxes[boxIndex-1]['boxRight']
		if index < len(charList)-1:
			bail = 0
			for testChar in goneMissing:
			   	if character == testChar and boxes[boxIndex]['boxChar'] != testChar and \
					boxes[boxIndex]['boxChar'] == charList[index+1] and \
					boxes[boxIndex]['boxLeft'] > lastRight + 80*scale: 
						boxLeft = int(round(boxes[boxIndex]['boxLeft'] - 40 * scale))
						fontChar = imagesNomatch[ord(testChar)].clone()
						draw.composite(operator='darken', left=boxLeft, 
							       top=boxes[boxIndex]['boxTop']+12-fontChar.height/2, 
							       width=int(round(fontChar.width * scale)), 
							       height=int(round(fontChar.height * scale)), image=fontChar)
						# Note that this will advance index (the pointer to characters in the line)
						# but not boxIndex.
						bail = 1
						break
			if bail:
				continue
		#sumBottomsInRow += boxes[boxIndex]['boxBottom']
		if numCharsInRow == 0:
			avgBottom = boxes[boxIndex]['boxBottom']
		else:
			avgBottom = (1.0 - decayBottom) * boxes[boxIndex]['boxBottom'] + decayBottom * avgBottom
		numCharsInRow += 1
		asciiCode = ord(character)
		if boxes[boxIndex]['boxChar'] == character:
			fontChar = imagesMatch[asciiCode].clone()
		else:
			fontChar = imagesNomatch[asciiCode].clone()
		fontWidth = fontChar.width * scale
		fontHeight = fontChar.height * scale
		minFontHeight = 0.9*fontHeight
		maxFontHeight = 1.3*fontHeight
		minFontWidth = 0.7*fontWidth
		maxFontWidth = 1.3*fontWidth
		operator = 'darken' 
		#print boxes[boxIndex]
		if boxes[boxIndex]['boxHeight'] > minFontHeight and boxes[boxIndex]['boxHeight'] < maxFontHeight and \
		   boxes[boxIndex]['boxWidth'] > minFontWidth and boxes[boxIndex]['boxWidth'] < maxFontWidth:
			fontChar.resize(boxes[boxIndex]['boxWidth'], boxes[boxIndex]['boxHeight'], 'cubic')
			draw.composite(operator=operator, left=boxes[boxIndex]['boxLeft'], 
				       top=boxes[boxIndex]['boxTop'], width=boxes[boxIndex]['boxWidth'], 
				       height=boxes[boxIndex]['boxHeight'], image=fontChar)
		else:
			fontChar.resize(int(round(fontWidth)), int(round(fontHeight)), 'cubic')
			draw.composite(operator=operator, left=int(round((boxes[boxIndex]['boxLeft']+boxes[boxIndex]['boxRight']-fontWidth)/2.0)), 
				       top=int(round((boxes[boxIndex]['boxTop']+boxes[boxIndex]['boxBottom']-fontHeight)/2.0)), width=int(round(fontWidth)), 
				       height=int(round(fontHeight)), image=fontChar)
		boxIndex += 1
	
	#if numCharsInRow > 0 and boxIndex < len(boxes) and \
	#   boxes[boxIndex]['boxLeft'] >= boxes[boxIndex-1]['boxLeft'] and \
	#   boxes[boxIndex]['boxBottom'] <= sumBottomsInRow/numCharsInRow + rowFloor:
	if numCharsInRow > 0 and boxIndex < len(boxes) and \
	   boxes[boxIndex]['boxLeft'] >= boxes[boxIndex-1]['boxLeft'] and \
	   boxes[boxIndex]['boxBottom'] <= avgBottom + rowFloor:
	   	#print 'Extra boxes in row', row
		while boxIndex < len(boxes):
			#if boxes[boxIndex]['boxLeft'] < boxes[boxIndex-1]['boxLeft'] or \
			#   boxes[boxIndex]['boxBottom'] > sumBottomsInRow/numCharsInRow + rowFloor:
			if boxes[boxIndex]['boxLeft'] < boxes[boxIndex-1]['boxLeft'] or \
			   boxes[boxIndex]['boxBottom'] > avgBottom + rowFloor:
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

# If there are still boxes left over, perhaps there were some comments at the end
# of the page that never made it into the source.  Better show them all as orange
# boxes.
# Draw empty frames around all of the rejected boxes.
if boxIndex < len(boxes):
	for i in range(boxIndex,len(boxes)):
		boxTop = boxes[i]['boxTop']
		boxBottom= boxes[i]['boxBottom']
		boxLeft = boxes[i]['boxLeft']
		boxRight = boxes[i]['boxRight']
		draw.line((boxLeft,boxTop), (boxRight,boxTop))
		draw.line((boxLeft,boxBottom), (boxRight,boxBottom))
		draw.line((boxRight,boxTop), (boxRight,boxBottom))
		draw.line((boxLeft,boxTop), (boxLeft,boxBottom))

# Perform all the pending drawing operations.
draw(img)

# Create the output image.
img.format = 'jpg'
img.compression_quality = 50
img.save(filename=outImage)
print 'output =', outImage

