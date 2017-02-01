#!/usr/bin/python
# Note:  Each input (textual) line is assumed to consist
# of 1 6-octal-digit field.
#
import sys
import re
from subprocess import call
from os import environ
from wand.image import Image, COMPOSITE_OPERATORS
from wand.drawing import Drawing
from wand.color import Color

# Environment variables.
blatant={}
if 'BLATANT0' in environ:
	blatant['0'] = 'yes'
if 'BLATANT1' in environ:
	blatant['1'] = 'yes'
if 'BLATANT2' in environ:
	blatant['2'] = 'yes'
if 'BLATANT3' in environ:
	blatant['3'] = 'yes'
if 'BLATANT4' in environ:
	blatant['4'] = 'yes'
if 'BLATANT5' in environ:
	blatant['5'] = 'yes'
if 'BLATANT6' in environ:
	blatant['6'] = 'yes'
if 'BLATANT7' in environ:
	blatant['7'] = 'yes'
print blatant

# Parse command-line arguments
if len(sys.argv) != 5:
	print 'Usage:'
	print '\t./ProoferSuper.py BWINPUTIMAGE OUTPUTIMAGE PAGENUMBER BINSOURCE'
	sys.exit()

backgroundImage = sys.argv[1]
outImage = sys.argv[2]
pageNumber = sys.argv[3]
binsourceFilename = sys.argv[4]

# Shell out to have tesseract generate the box file, and read it in..
call([ 'tesseract', backgroundImage, 'octal.burst.exp0', '-psm', '6', 'batch.nochop', 'makebox', 'octals' ])
file = open ('octal.burst.exp0.box', 'r')
boxes = []
rejectedBoxes = []
for line in file:
	boxFields = line.split()
	boxChar = boxFields[0]
	boxLeft = int(boxFields[1])
	boxBottom = int(boxFields[2])
	boxRight = int(boxFields[3])
	boxTop = int(boxFields[4])
	boxWidth = boxRight + 1 - boxLeft
	boxHeight = boxTop + 1 - boxBottom
	#print boxChar, boxWidth, boxHeight
	if (boxChar == '(' or boxChar == ')') and boxWidth >= 10 and boxWidth <= 16 and boxHeight >= 16 and boxHeight <= 24:
		boxes.append(line)
	elif boxChar == '7' and boxWidth >= 8 and boxWidth <= 20 and boxHeight >= 16 and boxHeight <= 24:
		boxes.append(line)
	elif boxChar == '3' and boxWidth >= 4 and boxWidth <= 16 and boxHeight >= 12 and boxHeight <= 24:
		boxes.append(line)
	elif boxChar != '1' and boxChar != '(' and boxChar != ')' and boxWidth >= 8 and boxWidth <= 16 and boxHeight >= 16 and boxHeight <= 24:
		boxes.append(line)
	elif boxChar == '1' and boxWidth >= 5 and boxWidth <= 16 and boxHeight >= 18 and boxHeight <= 24:
		boxes.append(line) 
	else:
		replaced = 0
		if len(rejectedBoxes) > 0:
			rejected = rejectedBoxes[len(rejectedBoxes)-1]
			rejectedFields = rejected.split()
			rejectedChar = rejectedFields[0]
			rejectedLeft = int(rejectedFields[1])
			rejectedBottom = int(rejectedFields[2])
			rejectedRight = int(rejectedFields[3])
			rejectedTop = int(rejectedFields[4])
			if boxLeft >= rejectedRight:
				boxLeft = rejectedLeft
				if rejectedBottom < boxBottom:
					boxBottom = rejectedBottom
				if rejectedTop > boxTop:
					boxTop = rejectedTop 
				boxWidth = boxRight + 1 - boxLeft
				boxHeight = boxTop + 1 - boxBottom
				if boxWidth >= 9 and boxWidth <= 16 and boxHeight >= 16 and boxHeight <= 24:
					line = '0 ' + str(boxLeft) + ' ' + str(boxBottom) + ' ' + str(boxRight) + ' ' + str(boxTop) + ' 0'
					boxes.append(line)
					replaced = 1
					del rejectedBoxes[len(rejectedBoxes)-1]
		if replaced == 0:
			rejectedBoxes.append(line)
file.close()

# Read in the binsource file.
file = open (binsourceFilename, 'r')
lines = []
octalPattern = re.compile(r"[0-7]{6}")
pagePattern = re.compile(r"^p[0-9][0-9]*$")
inPage = 0
for line in file:
	if pagePattern.match(line):
		inPage = 0
		if line == "p" + pageNumber + "\n":
			print "Found page " + pageNumber
			inPage = 1
	else:
		if octalPattern.match(line):
			if inPage != 0:
				lines.append(line)
file.close()
print lines
#if len(lines) != 044 * 4 * 8 * 4:
#	print "Binsource file", binsourceFilename, "is not 044 banks long."
#	sys.exit()

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
startIndex = 0
endIndex = len(lines)
#print endIndex
#print lines

draw = Drawing()
evilColor = Color("#FF00FF")
extraColor = Color("#FF8000")
draw.stroke_color = evilColor
draw.stroke_width = 4
draw.fill_opacity = 0

# Draw empty frames around all of the rejected boxes.
for i in range(0,len(rejectedBoxes)):
	boxFields = rejectedBoxes[i].split()
	boxLeft = int(boxFields[1])
	boxBottom = backgroundHeight - 1 - int(boxFields[2])
	boxRight = int(boxFields[3])
	boxTop = backgroundHeight - 1 - int(boxFields[4])
	draw.line((boxLeft,boxTop), (boxRight,boxTop))
	draw.line((boxLeft,boxBottom), (boxRight,boxBottom))
	draw.line((boxRight,boxTop), (boxRight,boxBottom))
	draw.line((boxLeft,boxTop), (boxLeft,boxBottom))

# Loop on lines on the selected page.  We're going to assume that the boxes are
# in 1-to-1 correspondence with the binsource digit, in the order read from 
# disk.
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
	for octalDigitIndex in range(0, 6):
		if boxIndex >= len(boxes):
			print 'Out of boxes in row'
			break
		# Parse the box entry.
		boxFields = boxes[boxIndex].split()
		if boxFields[0] == '~' or boxFields[0] == '(' or boxFields[0] == ')':
			boxOctal = -1
		else:
			boxOctal = int(boxFields[0])
		boxLeft = int(boxFields[1])
		boxBottom = backgroundHeight -1 - int(boxFields[2])
		boxRight = int(boxFields[3])
		boxTop = backgroundHeight - 1 - int(boxFields[4])
		boxWidth = boxRight + 1 - boxLeft
		boxHeight = boxBottom + 1 - boxTop
		
		digitIndex = int(characters[characterIndex])
		if boxOctal == digitIndex and not (characters[characterIndex] in blatant) and not (boxFields[0] in blatant):
			digit = images[digitIndex].clone()
		else:
			digit = imagesColored[digitIndex].clone()
		operator = 'darken'
		fontWidth = digit.width
		fontHeight = digit.height
		minFontHeight = 0.9*fontHeight
		maxFontHeight = 1.2*fontHeight
		minFontWidth = 0.9*fontWidth
		maxFontWidth = 1.2*fontWidth
		if boxHeight > minFontHeight and boxHeight < maxFontHeight and \
		   boxWidth > minFontWidth and boxWidth < maxFontWidth:
			digit.resize(boxWidth, boxHeight, 'cubic')
			draw.composite(operator=operator, left=boxLeft, top=boxTop, width=boxWidth, height=boxHeight, image=digit)
		else:
			digit.resize(int(round(fontWidth)), int(round(fontHeight)), 'cubic')
			draw.composite(operator=operator, left=round((boxLeft+boxRight-fontWidth)/2.0), 
				       top=round((boxTop+boxBottom-fontHeight)/2.0), width=fontWidth, 
				       height=fontHeight, image=digit)

		
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
img.format = 'jpg'
img.compression_quality = 25
img.save(filename=outImage)
print 'output =', outImage

