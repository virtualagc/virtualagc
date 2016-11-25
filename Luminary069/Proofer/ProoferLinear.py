#!/usr/bin/python
# Note:  The octal portions of binsource files are assumed to consist
# of 8 6-octal-digit fields, separated by a single space between fields.
#
# In terms of the geometry of the image, requires accounting only for 
# entirely-populated rows):
#	Center coords (pixels) of UL, UR, LL, LR octal digits.
#	Number of character rows.
#
# Thus geometrically, it computes a least-squares fit given the data for
# the four corners) for an affine transformation (displacement and 
# matrix multiplication) and applies it to the geometry.

import sys
import re
import math
from wand.image import Image, COMPOSITE_OPERATORS
from wand.drawing import Drawing

#========================================================================
# I got this function from http://elonen.iki.fi/code/misc-notes/affine-fit/.

def Affine_Fit( from_pts, to_pts ):
    """Fit an affine transformation to given point sets.
      More precisely: solve (least squares fit) matrix 'A'and 't' from
      'p ~= A*q+t', given vectors 'p' and 'q'.
      Works with arbitrary dimensional vectors (2d, 3d, 4d...).
      
      Written by Jarno Elonen <elonen@iki.fi> in 2007.
      Placed in Public Domain.
      
      Based on paper "Fitting affine and orthogonal transformations
      between two sets of points, by Helmuth Spath (2003)."""
    
    q = from_pts
    p = to_pts
    if len(q) != len(p) or len(q)<1:
        print "from_pts and to_pts must be of same size."
        return false
    
    dim = len(q[0]) # num of dimensions
    if len(q) < dim:
        print "Too few points => under-determined system."
        return false
    
    # Make an empty (dim) x (dim+1) matrix and fill it
    c = [[0.0 for a in range(dim)] for i in range(dim+1)]
    for j in range(dim):
        for k in range(dim+1):
            for i in range(len(q)):
                qt = list(q[i]) + [1]
                c[k][j] += qt[k] * p[i][j]
    
    # Make an empty (dim+1) x (dim+1) matrix and fill it
    Q = [[0.0 for a in range(dim)] + [0] for i in range(dim+1)]
    for qi in q:
        qt = list(qi) + [1]
        for i in range(dim+1):
            for j in range(dim+1):
                Q[i][j] += qt[i] * qt[j]
    
    # Ultra simple linear system solver. Replace this if you need speed.
    def gauss_jordan(m, eps = 1.0/(10**10)):
      """Puts given matrix (2D array) into the Reduced Row Echelon Form.
         Returns True if successful, False if 'm' is singular.
         NOTE: make sure all the matrix items support fractions! Int matrix will NOT work!
         Written by Jarno Elonen in April 2005, released into Public Domain"""
      (h, w) = (len(m), len(m[0]))
      for y in range(0,h):
        maxrow = y
        for y2 in range(y+1, h):    # Find max pivot
          if abs(m[y2][y]) > abs(m[maxrow][y]):
            maxrow = y2
        (m[y], m[maxrow]) = (m[maxrow], m[y])
        if abs(m[y][y]) <= eps:     # Singular?
          return False
        for y2 in range(y+1, h):    # Eliminate column y
          c = m[y2][y] / m[y][y]
          for x in range(y, w):
            m[y2][x] -= m[y][x] * c
      for y in range(h-1, 0-1, -1): # Backsubstitute
        c  = m[y][y]
        for y2 in range(0,y):
          for x in range(w-1, y-1, -1):
            m[y2][x] -=  m[y][x] * m[y2][y] / c
        m[y][y] /= c
        for x in range(h, w):       # Normalize row y
          m[y][x] /= c
      return True
    
    # Augment Q with c and solve Q * a' = c by Gauss-Jordan
    M = [ Q[i] + c[i] for i in range(dim+1)]
    if not gauss_jordan(M):
        print "Error: singular matrix. Points are probably coplanar."
        return false
    
    # Make a result object
    class Transformation:
        """Result object that represents the transformation
           from affine fitter."""
        
        def To_Str(self):
            res = ""
            for j in range(dim):
                str = "x%d' = " % j
                for i in range(dim):
                    str +="x%d * %f + " % (i, M[i][j+dim+1])
                str += "%f" % M[dim][j+dim+1]
                res += str + "\n"
            return res
        
        def Transform(self, pt):
            res = [0.0 for a in range(dim)]
            for j in range(dim):
                for i in range(dim):
                    res[j] += pt[i] * M[i][j+dim+1]
                res[j] += M[dim][j+dim+1]
            return res
    
    return Transformation()

#========================================================================
# Now, the code I wrote myself ...

# Parse command-line arguments
if len(sys.argv) < 15:
	print 'Usage:'
	print '\t./Proofer.py BACKGROUNDIMAGE OUTIMAGE BANK PAGEINBANK BINSOURCE numRows xUL yUL xUR yUR xLR yLR xLL yLL'
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

numRows=int(sys.argv[6])
fromPoints = ( (0, 0), 
               (14 * 7 + 7 - 1, 0), 
               (14 * 7 + 7 - 1, numRows - 1 + 1.2 * ((numRows - 1) // 4) ), 
               (0, numRows - 1 + 1.2 * ((numRows - 1) // 4) ) 
             )
toPoints = ( (float(sys.argv[7]), float(sys.argv[8])), 
	     (float(sys.argv[9]), float(sys.argv[10])), 
	     (float(sys.argv[11]), float(sys.argv[12])), 
	     (float(sys.argv[13]), float(sys.argv[14]))
	   )
print fromPoints
print toPoints
transformation = Affine_Fit(fromPoints, toPoints)
print transformation.To_Str()

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
images.append(Image(filename='0b.png'))
images.append(Image(filename='1b.png'))
images.append(Image(filename='2b.png'))
images.append(Image(filename='3b.png'))
images.append(Image(filename='4b.png'))
images.append(Image(filename='5b.png'))
images.append(Image(filename='6b.png'))
images.append(Image(filename='7b.png'))
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
startIndex = bankNumber * 4 * 8 * 4 + pageInBank * 4 * 8
endIndex = startIndex + 4 * 8

# Loop on lines on the selected page.
draw = Drawing()
row = 0
for index in range(startIndex, endIndex):
	# Loop on the octal digits in the row.
	col = 0
	characterIndex = 0
	characters = list(lines[index])
	for octalDigitIndex in range(0, 8 * 6):
		outputPoint = transformation.Transform( (col, row) )
		digit = int(characters[characterIndex])
		draw.composite(operator='atop', left=outputPoint[0] - digitWidth/2, 
			top=outputPoint[1] - digitHeight/2, width=digitWidth, height=digitHeight, 
			image=images[digit])
		characterIndex += 1
		col += 1
		if (octalDigitIndex % 6) == 4:
			col += 1
		if (octalDigitIndex % 6) == 5:
			col += 7
			characterIndex += 1
	# Next row, please
	row += 1
	if (index % 4) == 3:
		row += 1.2
draw(img)

# Create the output image.
img.format = 'png'
img.save(filename=outImage)
print 'output =', outImage

