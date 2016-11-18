#!/usr/bin/env python

# Copyright 2016 Mike Stewart <mastewar1 at gmail dot com>
#
# This file is part of yaAGC.
#
# yaAGC is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# yaAGC is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with yaAGC; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
#

# Python script to preprocess octal listing pages to prepare them for OCR.
# The methods and values used in this script have been tuned specifically
# for the paper and printer used on the Sunburst 120 listing; it will very
# likely need to be modified for use with other scripts.


import numpy as np
import cv2
import sys
import math
import argparse

parser = argparse.ArgumentParser(description='Prepare octal pages of AGC program listings for OCR')
parser.add_argument('input_file', help="Input image path")
parser.add_argument('output_file', help="Output image path")
group = parser.add_mutually_exclusive_group(required=True)
group.add_argument('--burst120', help="Perform BURST120 processing", action="store_true")
group.add_argument('--luminary210', help="Perform LUMINARY 210 processing", action="store_true")

args = parser.parse_args()

img = cv2.imread(args.input_file)

# Get the L channel of the image in LAB color space
lab = cv2.cvtColor(img, cv2.COLOR_BGR2LAB)
l_channel,_,_ = cv2.split(lab)

# Blur and threshold the image
blurred = cv2.GaussianBlur(l_channel, (1,5), 0)
if args.burst120:
    _,thresh = cv2.threshold(blurred, 180, 255, cv2.THRESH_BINARY)
else:
    thresh = cv2.adaptiveThreshold(blurred, 255, cv2.ADAPTIVE_THRESH_MEAN_C, cv2.THRESH_BINARY, 201, 11)

# Eliminate random flecks. We do this by finding all the contours in the image
# and taking a look at their relative locations and size. We'll be building up
# a mask that will be subtracted from our thresholded image.
cimg, contours, hierarchy = cv2.findContours(~thresh, cv2.RETR_LIST, cv2.CHAIN_APPROX_SIMPLE)
mask = np.ones(thresh.shape[:2], dtype=np.uint8) * 255
for c in contours:
    area = cv2.contourArea(c)
    eliminate = False

    # Contours with an area of 12 pixels are not worth keeping around at all
    if area < 12:
        eliminate = True
    elif area < 30:
        # For larger contours (area < 30), we should make sure they're not part
        # of a connected character. Two such contours close together probably
        # means they're meaningful. Look for the closest contour to this one.
        min_dist = 9999999

        # Use the center of the bounding box of the contour as the point of reference
        x,y,w,h = cv2.boundingRect(c)
        cx = x+w/2
        cy = y+h/2

        # The goal here was obviously not efficiency... look at every other contour
        # and calculate its distance and area.
        for other in contours:
            # Again, things with an area of less than 12px are not worth considering
            if not np.array_equal(other,c) and cv2.contourArea(other) > 12:
                # This is a meaninful contour. Calculate the distance and update the min
                x,y,w,h = cv2.boundingRect(other)
                ox = x+w/2
                oy = y+h/2
                dist = math.sqrt((cx-ox)**2 + (cy-oy)**2)
                if dist < min_dist:
                    min_dist = dist

        # Arbitrarily say 20px is the cutoff for removal
        if min_dist > 20:
            eliminate=True
    if eliminate:
        # Garbage detected! Draw the contour on the mask.
        cv2.drawContours(mask, [c], -1, 0, -1)

# Removed all the masked pixels from our image
result = thresh + ~mask

# Now that that's over with, find the bounding box of the text. The bottom lines of the
# header are just as close together as the groups of octals themselves, so they will make
# it through this step. They provide a pretty good bounding box, though, so having them
# tag along is kind of nice.

# Dilate the whole thing to hell evenely, and look up the contours
dilated = cv2.dilate(~result, np.ones((5,5), np.uint8), iterations=15)
cimg, contours, hierarchy = cv2.findContours(dilated, cv2.RETR_LIST, cv2.CHAIN_APPROX_NONE)

# The largest contour we find is going to be all of the octals plus some of the header
areas = [cv2.contourArea(c) for c in contours]
largest_contour = contours[np.argmax(areas)]
x,y,w,h = cv2.boundingRect(largest_contour)

# Crop down to it!
cropped = result[y:y+h, x:x+w]

# Chop off the header. The idea this time around is to dilate a bit less, but mostly
# horizontally. We'll then look for things big enough to be the header, and remove
# everything above and including the lowest one.
dilated2 = cv2.dilate(~cropped, np.ones((3,9), np.uint8), iterations=8)
cimg, contours, hierarchy = cv2.findContours(dilated2, cv2.RETR_LIST, cv2.CHAIN_APPROX_NONE)
top_y = 0
typ_h = 0 
for c in contours:
    x,_,w,_ = cv2.boundingRect(c)
    if w > 1200:
        _,y,_,h = cv2.boundingRect(c)
        if y > top_y:
            top_y = y
            top_h = h

no_header = cropped[top_y+top_h:, :]

# Header gone, we can now remove the address column. It doesn't contribute much, and
# would make us need to recognize another character (,). Dilate a bunch again, mostly
# vertically. The leftmost column that's big enough is the address.
dilated3 = cv2.dilate(~no_header, np.ones((9,5), np.uint8), iterations=8)
cimg, contours, hierarchy = cv2.findContours(dilated3, cv2.RETR_LIST, cv2.CHAIN_APPROX_NONE)

left_x = 99999
left_w = 99999
for c in contours:
    if cv2.contourArea(c) > 50000:
        x,_,w,_ = cv2.boundingRect(c)
        if x < left_x:
            print(x)
            left_x = x
            left_w = w

# Chop it off!
no_addr = no_header[:, left_x+left_w:]


# Now we're down to just the octals themselves, the metadata shown to the left of them
# (C:, I:, CKSM), and the @s if we're at the end of a bank. To kill the metadata, we
# again dilate, mostly vertically, and then find columns wide enough to be the octals.
# We then arbitrarily wipe out everything 100px to the left of these columns, overwriting
# everything out there.
dilated4 = cv2.dilate(~no_addr, np.ones((17,3), np.uint8), iterations=8)
cimg, contours, hierarchy = cv2.findContours(dilated4, cv2.RETR_LIST, cv2.CHAIN_APPROX_NONE)
for c in contours:
    x,_,w,h = cv2.boundingRect(c)
    if w > 110 and h > 400:
        # NOTE: If a line makes it through the thresholding and deflecking steps, there's a 
        # good chance we're going to accidentally blow out the parities of the next column
        # over or more. If that happens, drop the (x-100) below to (x-40) or less, as
        # required, and then manually edit out whatever makes it through and erase the
        # line causing the problem before feeding it into Tesseract.
        cv2.rectangle(no_addr, (x-120,0), (x,no_addr.shape[1]), 255, -1)

# Last non-octal thing that's left is @s for unused words at the end of a bank. Dilate
# mostly horizontally (enough to pull in the parities), and look for things that aren't wide 
# enough to be octal words. They must be @s, and should be removed.
dilated5 = cv2.dilate(~no_addr, np.ones((1,11), np.uint8), iterations=5)
cimg, contours, hierarchy = cv2.findContours(dilated5, cv2.RETR_LIST, cv2.CHAIN_APPROX_NONE)
for c in contours:
    x,y,w,h = cv2.boundingRect(c)
    if w < 75:
        cv2.rectangle(no_addr, (x,y), (x+w,y+h), 255, -1)

# Finally, crop to just what remains to minimize whitespace.
dilated6 = cv2.dilate(~no_addr, np.ones((5,5), np.uint8), iterations=15)
cimg, contours, hierarchy = cv2.findContours(dilated6, cv2.RETR_LIST, cv2.CHAIN_APPROX_NONE)
ymin = 99999
xmin = 99999
ymax = 0
xmax = 0
for c in contours:
    x,y,w,h = cv2.boundingRect(c)
    if x < xmin:
        xmin = x
    if y < ymin:
        ymin = y
    if x+w > xmax:
        xmax = x+w
    if y+h > ymax:
        ymax = y+h

print(ymin,ymax,xmin,xmax)
final_image = no_addr[ymin:ymax, xmin:xmax]


# All done! Write out the prepared image
cv2.imwrite(args.output_file, final_image)

# cv2.imshow('image', dilated6)
# cv2.waitKey(0)
# cv2.destroyAllWindows()
