#!/usr/bin/python
# Note:  The octal portions of binsource files are assumed to consist
# of 8 6-octal-digit fields, separated by a single space between fields.
#
# In this version of the program, all that's required is the name of the
# B&W octal image produced by octopus.py for use as OCR input.  The
# program uses tesseract to produces the box-file containing the character
# boxes, and then produces a new image with those boxes filled in by the
# previously-created images of individual octal images.

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

specialOne = ('SPECIALONE' in environ)
specialThree = ('SPECIALTHREE' in environ)
specialFive = ('SPECIALFIVE' in environ)
invert = ("INVERT" in environ)

minFontScale = 0.9
maxFontScale = 1.2
defaultFontScale = 1.0
if 'ZERLINA' in environ:
	scanColor="#000000"
	matchColor="#00C000"
	defaultFontScale = 0.75
	bounds = (4, 20, 11, 30)
	if not invert:
		specialOne = 1
		specialThree = 1
		specialFive = 1
elif 'AP11ROPE' in environ:
	defaultFontScale = 1.25
	bounds = (8, 28, 16, 36)
else:
	scanColor="#000000"
	matchColor="#006C00"
	bounds = (8, 24, 16, 36)
minFontScale *= defaultFontScale
maxFontScale *= defaultFontScale

# Don't use SWAPCOLORS: it's enormously, mind-bogglingly slow.
swapColors = ('SWAPCOLORS' in environ)	

# Parse command-line arguments
if len(sys.argv) != 6:
	print 'Usage:'
	print '\t[ZERLINA=yes] [AP11ROPE=yes] ./ProoferBox.py BWINPUTIMAGE OUTPUTIMAGE BANK PAGEINBANK BINSOURCE'
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
	if boxWidth >= bounds[0] and boxWidth <= bounds[1] and boxHeight >= bounds[2] and boxHeight <= bounds[3]:
		boxes.append(line)
	else:
		rejectedBoxes.append(line)
		print "Out of bounds ", line
file.close()

# Read in the binsource file.
file = open (binsourceFilename, 'r')
lines = []
octalPattern = re.compile(r"([0-7]{6}|[ \t]*@)([ \t]+([0-7]{6}|@)){7}.*")
for line in file:
	if octalPattern.match(line):
		lines.append(line)
file.close()
#if len(lines) != 044 * 4 * 8 * 4:
#	print "Binsource file", binsourceFilename, "is not 044 banks long."
#	sys.exit()

# Read in the octal-digit files.
images = []
		
def replaceColorsInImage(img, color1, color2):
	ldraw = Drawing()
	ldraw.fill_color = color2
	width, height = img.size
	for x in range(0, width):
		for y in range(0, height):
			if img[x,y] == color1:
				ldraw.color(x, y, 'replace')
	ldraw(img)

if 'ZERLINA' in environ:
	images.append(Image(filename='z0t.png'))
	images.append(Image(filename='z1t.png'))
	images.append(Image(filename='z2t.png'))
	images.append(Image(filename='z3t.png'))
	images.append(Image(filename='z4t.png'))
	images.append(Image(filename='z5t.png'))
	images.append(Image(filename='z6t.png'))
	images.append(Image(filename='z7t.png'))
	oneSpecialDigit = Image(filename='z1tb.png')
	threeSpecialDigit = Image(filename='z3tb.png')
	fiveSpecialDigit = Image(filename='z5tb.png')
else:
	images.append(Image(filename='0t.png'))
	images.append(Image(filename='1t.png'))
	images.append(Image(filename='2t.png'))
	images.append(Image(filename='3t.png'))
	images.append(Image(filename='4t.png'))
	images.append(Image(filename='5t.png'))
	images.append(Image(filename='6t.png'))
	images.append(Image(filename='7t.png'))
	oneSpecialDigit = Image(filename='1tb.png')
	threeSpecialDigit = Image(filename='3tb.png')
	fiveSpecialDigit = Image(filename='5tb.png')
	
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
if invert:
	img.negate()
backgroundWidth = img.width
backgroundHeight = img.height

if swapColors:
	print 'Swapping colors'
	for i in range(0, 8):
		replaceColorsInImage(images[i], Color(matchColor), Color(scanColor))
	replaceColorsInImage(img, Color(scanColor), Color(matchColor))

# Make certain conversions on the background image.
img.type = 'truecolor'
img.alpha_channel = 'activate'

# Determine the range of binsource lines we need to use.  We're guaranteed
# they're all in the binsource lines[] array.
if bankNumber < 4:
	bankNumber = bankNumber ^ 2
startIndex = bankNumber * 4 * 8 * 4 + pageInBank * 4 * 8
endIndex = startIndex + 4 * 8

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
# disk, except that there may be less boxes (on the last page of a bank).
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
		
		if characters[characterIndex] != '@':
			digitIndex = int(characters[characterIndex])
			#print boxFields[0], ' ', characters[characterIndex]
			if specialOne and characters[characterIndex] == '1':
				#print "here"
				digit = oneSpecialDigit.clone() 
				operator = 'difference'
			elif specialThree and characters[characterIndex] == '3':
				#print "here"
				digit = threeSpecialDigit.clone() 
				operator = 'multiply'
			elif specialFive and characters[characterIndex] == '5':
				digit = fiveSpecialDigit.clone()
				operator = 'difference'
			elif boxOctal == digitIndex and not (characters[characterIndex] in blatant) and not (boxFields[0] in blatant):
				digit = images[digitIndex].clone()
				operator = 'darken'
			else:
				digit = imagesColored[digitIndex].clone()
				operator = 'darken'
			fontWidth = digit.width
			fontHeight = digit.height
			minFontHeight = minFontScale*fontHeight
			minFontWidth = minFontScale*fontWidth
			maxFontHeight = maxFontScale*fontHeight
			maxFontWidth = maxFontScale*fontWidth
			if boxHeight > minFontHeight and boxHeight < maxFontHeight and \
			   boxWidth > minFontWidth and boxWidth < maxFontWidth:
				digit.resize(boxWidth, boxHeight, 'cubic')
				draw.composite(operator=operator, left=boxLeft, top=boxTop, width=boxWidth, height=boxHeight, image=digit)
			else:
				digit.resize(int(round(fontWidth*defaultFontScale)), int(round(fontHeight*defaultFontScale)), 'cubic')
				draw.composite(operator=operator, left=round((boxLeft+boxRight-fontWidth*defaultFontScale)/2.0), 
					       top=round((boxTop+boxBottom-fontHeight*defaultFontScale)/2.0), width=fontWidth*defaultFontScale, 
					       height=fontHeight*defaultFontScale, image=digit)

		
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

