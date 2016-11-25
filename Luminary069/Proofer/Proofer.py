#!/usr/bin/python
# Note:  The octal portions of binsource files are assumed to consist
# of 8 6-octal-digit fields, separated by a single space between fields.
#
# In terms of the geometry of the image, this function requires:
#	Upper-left pixel coordinates of bounding box of upper-left octal digit.
#	Pixel-spacing between characters horizontally.
#	Pixel-spacing between character-rows vertically.  (1.2X is used between blocks.)
#	Angle clockwise from x-axis of a vertical row.
#
# Thus, all it does geometrically is rotate the image and displace it.

import sys
import re
import math
from wand.image import Image, COMPOSITE_OPERATORS
from wand.drawing import Drawing

# Parse command-line arguments
if len(sys.argv) < 11:
	print 'Usage:'
	print '\t./Proofer.py BACKGROUNDIMAGE OUTIMAGE BANK PAGEINBANK BINSOURCE TOP LEFT DELTAX DELTAY ANGLE'
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

topPixelRow = float(sys.argv[6])
leftPixelCol = float(sys.argv[7])
characterSpacing = float(sys.argv[8])
rowSpacing = float(sys.argv[9])
angle = float(sys.argv[10])
cos = math.cos(angle * math.pi / 180.0)
sin = math.sin(angle * math.pi / 180.0)

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
images.append(Image(filename='0.png'))
images.append(Image(filename='1.png'))
images.append(Image(filename='2.png'))
images.append(Image(filename='3.png'))
images.append(Image(filename='4.png'))
images.append(Image(filename='5.png'))
images.append(Image(filename='6.png'))
images.append(Image(filename='7.png'))
digitWidth = images[0].width
digitHeight = images[0].height
print 'digits are', digitWidth, "x", digitHeight

# Read in the input image ... i.e., the B&W octal page.
img = Image(filename=backgroundImage)
print 'input =', backgroundImage, ' geometry=', img.width, 'x', img.height

# Make certain conversions on the background image.
img.type = 'truecolor'
img.alpha_channel = 'activate'

# Determine the range of binsource lines we need to use.  We're guaranteed
# they're all in the binsource lines[] array.
if bankNumber < 4:
	bankNumber = bankNumber ^ 2
startIndex = bankNumber * 4 * 8 * 4
endIndex = startIndex + 4 * 8 * 4

# Loop on lines on the selected page.
pixelRow = topPixelRow
draw = Drawing()
for index in range(startIndex, endIndex):
	# Loop on the octal digits in the row.
	pixelColumn = leftPixelCol
	characterIndex = 0
	characters = list(lines[index])
	for octalDigitIndex in range(0, 8 * 6):
		x0 = pixelColumn - leftPixelCol
		y0 = pixelRow - topPixelRow
		x = cos * x0 - sin * y0 + leftPixelCol
		y = sin * x0 + cos * y0 + topPixelRow
		digit = int(characters[characterIndex])
		draw.composite(operator='difference', left=x, 
			top=y, width=digitWidth, height=digitHeight, 
			image=images[digit])
		characterIndex += 1;
		pixelColumn += characterSpacing
		if (octalDigitIndex % 6) == 4:
			pixelColumn += characterSpacing
		if (octalDigitIndex % 6) == 5:
			pixelColumn += 7 * characterSpacing
			characterIndex += 1
	# Next row, please
	pixelRow += rowSpacing
	if (index % 4) == 3:
		pixelRow += rowSpacing * 1.2
draw(img)

# Create the output image.
img.format = 'png'
img.save(filename=outImage)
print 'output =', outImage

