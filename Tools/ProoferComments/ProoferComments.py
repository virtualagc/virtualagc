#!/usr/bin/python
# This program is similar to ProoferBox.py, which is used for checking octals
# from AGC listings, but instead it check the program comments in AGC listings.
#
# This program assumes that all "modern" comments are marked with ## or ###, and
# are completely ignored, except that it assumes page markings of the form "## Page N"
# are present.
#
# AT THE MOMENT THIS CODE IS JUST A CLONE OF ProoferBox.Py, AND ALTHOUGH IT WILL 
# BE VERY SIMILAR, IT WON'T BE IDENTICAL.

import sys
import re
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
bankNumber = int(sys.argv[3])
if bankNumber < 0 or bankNumber >= 044:
	print 'Bank number', bankNumber, 'is out of range.'
	sys.exit()
pageInBank = int(sys.argv[4])
if pageInBank < 0 or pageInBank >= 4:
	print 'Page', pageInBank, 'is out of range.'
	sys.exit()
binsourceFilename = sys.argv[5]

# Shell out to have tesseract generate the box file, and read it in..
call([ 'tesseract', backgroundImage, 'octal.burst.exp0', '-psm', '6', 'batch.nochop', 'makebox', 'octals' ])
file =open ('octal.burst.exp0.box', 'r')
boxes = file.readlines()
file.close()

# Read in the binsource file.
file = open (binsourceFilename, 'r')
lines = []
octalPattern = re.compile(r"[0-7]{6}( [0-7]{6}){7}.*")
for line in file:
	if octalPattern.match(line):
		lines.append(line)
file.close()
if len(lines) != 044 * 4 * 8 * 4:
	print "Binsource file", binsourceFilename, "is not 044 banks long."
	sys.exit()

# Read in the octal-digit files.
images = []
images.append(Image(filename='0t.png'))
images.append(Image(filename='1t.png'))
images.append(Image(filename='2t.png'))
images.append(Image(filename='3t.png'))
images.append(Image(filename='4t.png'))
images.append(Image(filename='5t.png'))
images.append(Image(filename='6t.png'))
images.append(Image(filename='7t.png'))
imagesColored = []
imagesColored.append(Image(filename='0m.png'))
imagesColored.append(Image(filename='1m.png'))
imagesColored.append(Image(filename='2m.png'))
imagesColored.append(Image(filename='3m.png'))
imagesColored.append(Image(filename='4m.png'))
imagesColored.append(Image(filename='5m.png'))
imagesColored.append(Image(filename='6m.png'))
imagesColored.append(Image(filename='7m.png'))

# Read in the input image ... i.e., the B&W octal page.
img = Image(filename=backgroundImage)
backgroundWidth = img.width
backgroundHeight = img.height

# Make certain conversions on the background image.
img.type = 'truecolor'
img.alpha_channel = 'activate'

# Determine the range of binsource lines we need to use.  We're guaranteed
# they're all in the binsource lines[] array.
if bankNumber < 4:
	bankNumber = bankNumber ^ 2
startIndex = bankNumber * 4 * 8 * 4 + pageInBank * 4 * 8
endIndex = startIndex + 4 * 8

# Loop on lines on the selected page.  We're going to assume that the boxes are
# in 1-to-1 correspondence with the binsource digit, in the order read from 
# disk, except that there may be less boxes (on the last page of a bank).
draw = Drawing()
row = 0
lastRight = 1000000
boxIndex = 0
for index in range(startIndex, endIndex):
	if boxIndex >= len(boxes):
		print 'Out of boxes on page'
		break
	# Loop on the octal digits in the row.
	col = 0
	characterIndex = 0
	characters = list(lines[index])
	for octalDigitIndex in range(0, 8 * 6):
		if boxIndex >= len(boxes):
			print 'Out of boxes in row'
			break
		# Parse the box entry.
		boxFields = boxes[boxIndex].split()
		boxOctal = int(boxFields[0])
		boxLeft = int(boxFields[1])
		boxBottom = backgroundHeight -1 - int(boxFields[2])
		boxRight = int(boxFields[3])
		boxTop = backgroundHeight - 1 - int(boxFields[4])
		boxWidth = boxRight + 1 - boxLeft
		boxHeight = boxBottom + 1 - boxTop
		
		digitIndex = int(characters[characterIndex])
		if boxOctal == digitIndex:
			digit = images[digitIndex].clone()
			operator = 'darken' #'xor' 
		else:
			digit = imagesColored[digitIndex].clone()
			operator = 'darken'
		digit.resize(boxWidth, boxHeight, 'cubic')
		
		draw.composite(operator=operator, left=boxLeft, top=boxTop, width=boxWidth, height=boxHeight, image=digit)
		
		characterIndex += 1
		col += 1
		if (octalDigitIndex % 6) == 4:
			col += 1
		if (octalDigitIndex % 6) == 5:
			col += 7
			characterIndex += 1
		boxIndex += 1
	# Next row, please
	row += 1
	if (index % 4) == 3:
		row += 1.2
draw(img)

# Create the output image.
img.format = 'png'
img.save(filename=outImage)
print 'output =', outImage

