#!/usr/bin/env python3

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

import os.path
from os import environ
import numpy as np
import cv2
import sys
import math
import argparse
import functools
from PIL import Image
import traceback
from pytesseract import image_to_string

parser = argparse.ArgumentParser(description='Prepare octal pages of AGC program listings for OCR')
parser.add_argument('input_file', help="Input image path")
parser.add_argument('output_file', help="Output image path")
parser.add_argument('--no-crop', help="Only perform the threshold steps; don't crop down as for octals.", action="store_true")
parser.add_argument('--comments', help="Crop to comments rather than octals", action="store_true")
group = parser.add_mutually_exclusive_group(required=True)
group.add_argument('--burst120', help="Perform BURST120 processing (original)", action="store_true")
group.add_argument('--luminary210', help="Perform LUMINARY 210 processing", action="store_true")
group.add_argument('--luminary210A', help="Perform LUMINARY 210 processing, but Luminary 69 style", action="store_true")
group.add_argument('--luminary69', help="Perform LUMINARY 69 processing", action="store_true")
group.add_argument('--comanche55', help="Perform COMANCHE 55 processing", action="store_true")
group.add_argument('--luminary99', help="Perform LUMINARY 99 processing", action="store_true")
group.add_argument('--retread44', help="Perform RETREAD 44 processing", action="store_true")
group.add_argument('--aurora12', help="Perform AURORA 12 processing", action="store_true")
group.add_argument('--sunburst120', help="Perform SUNBURST120 processing (in Luminary 69 style)", action="store_true")
group.add_argument('--luminary116', help="Perform LUMINARY 116 processing (for octals)", action="store_true")
group.add_argument('--solarium55', help="Perform SOLARIUM 55 processing", action="store_true")
group.add_argument('--colossus237', help="Perform COLOSSUS 237 processing", action="store_true")
group.add_argument('--artemis72', help="Perform COLOSSUS 237 processing", action="store_true")
group.add_argument('--simAP11ROPE', help="Perform AP11ROPE Digital Simulation processing", action="store_true")
group.add_argument('--yul1', help="Perform processing for YUL pages 3-24", action="store_true")
group.add_argument('--yul2', help="Perform processing for YUL pages 25-40", action="store_true")
group.add_argument('--yul3', help="Perform processing for YUL pages 41-152", action="store_true")
group.add_argument('--yul4', help="Perform processing for YUL pages 153-264", action="store_true")
group.add_argument('--yul5', help="Perform processing for YUL pages 265-331", action="store_true")
group.add_argument('--yul6', help="Perform processing for YUL pages 332-384", action="store_true")
group.add_argument('--yul7', help="Perform processing for YUL pages 385-481", action="store_true")
group.add_argument('--yul8', help="Perform processing for YUL pages 482-575", action="store_true")
group.add_argument('--yul9', help="Perform processing for YUL pages 576-671", action="store_true")
group.add_argument('--yul10', help="Perform processing for YUL pages 672-730", action="store_true")
group.add_argument('--luminary131', help="Perform LUMINARY 131 (Eyles) processing", action="store_true")
group.add_argument('--luminary131A', help="Perform LUMINARY 131 (Eyles, lighter) processing", action="store_true")
group.add_argument('--sunburst37', help="Perform SUNBURST 37 processing", action="store_true")
group.add_argument('--zerlina56', help="Perform Zerlina 56 processing", action="store_true")
group.add_argument('--ap11rope', help="Perform AP11ROPE processing", action="store_true")

args = parser.parse_args()
if not os.path.isfile(args.input_file):
	print("Cannot open file", args.input_file)
	sys.exit(1)

octcrop = ""
if 'OCTCROP' in environ:
	octcrop = environ['OCTCROP']

img = cv2.imread(args.input_file)

# Get the L channel of the image in LAB color space
lab = cv2.cvtColor(img, cv2.COLOR_BGR2LAB)
l_channel,_,_ = cv2.split(lab)

# Blur and threshold the image
if args.burst120:
    blurred = cv2.GaussianBlur(l_channel, (1,5), 0)
    _,thresh = cv2.threshold(blurred, 180, 255, cv2.THRESH_BINARY)
elif args.luminary210:
    blurred = cv2.GaussianBlur(l_channel, (1,5), 0)
    thresh = cv2.adaptiveThreshold(blurred, 255, cv2.ADAPTIVE_THRESH_MEAN_C, cv2.THRESH_BINARY, 201, 11)
elif args.luminary210A:
    blurred = cv2.GaussianBlur(l_channel, (5,5), 0)
    # Isolate the lines by eroding very strongly horizontally
    lines_only = cv2.erode(~blurred, np.ones((1,21), np.uint8), iterations=1)
    # Beef them up a bit by vertically dilating
    thickend_lines = cv2.dilate(lines_only, np.ones((3,1), np.uint8), iterations=1)
    # Difference the original L channel with the thickened lines (which is inverted)
    diff = blurred + thickend_lines
    thresh = cv2.adaptiveThreshold(blurred, 255, cv2.ADAPTIVE_THRESH_MEAN_C, cv2.THRESH_BINARY, 201, 11)
elif args.luminary131:
    blurred = cv2.GaussianBlur(l_channel, (5,5), 0)
    # Isolate the lines by eroding very strongly horizontally
    lines_only = cv2.erode(~blurred, np.ones((1,21), np.uint8), iterations=1)
    # Beef them up a bit by vertically dilating
    thickend_lines = cv2.dilate(lines_only, np.ones((3,1), np.uint8), iterations=1)
    # Difference the original L channel with the thickened lines (which is inverted)
    diff = blurred + thickend_lines
    thresh = cv2.adaptiveThreshold(blurred, 255, cv2.ADAPTIVE_THRESH_MEAN_C, cv2.THRESH_BINARY, 201, 11)
elif args.luminary131A:
    blurred = cv2.GaussianBlur(l_channel, (5,5), 0)
    # Isolate the lines by eroding very strongly horizontally
    lines_only = cv2.erode(~blurred, np.ones((1,21), np.uint8), iterations=1)
    # Beef them up a bit by vertically dilating
    thickend_lines = cv2.dilate(lines_only, np.ones((3,1), np.uint8), iterations=1)
    # Difference the original L channel with the thickened lines (which is inverted)
    diff = blurred + thickend_lines
    thresh = cv2.adaptiveThreshold(blurred, 255, cv2.ADAPTIVE_THRESH_MEAN_C, cv2.THRESH_BINARY, 141, 11)
elif args.luminary69 or args.aurora12 or args.sunburst120:
    blurred = cv2.GaussianBlur(l_channel, (5,5), 0)
    # Isolate the lines by eroding very strongly horizontally
    lines_only = cv2.erode(~blurred, np.ones((1,21), np.uint8), iterations=1)
    # Beef them up a bit by vertically dilating
    thickend_lines = cv2.dilate(lines_only, np.ones((3,1), np.uint8), iterations=1)
    # Difference the original L channel with the thickened lines (which is inverted)
    diff = blurred + thickend_lines
    thresh = ~cv2.inRange(diff, 30, 225) # Reject pixels too black or too white
elif args.sunburst37:
    blurred = cv2.GaussianBlur(l_channel, (5,5), 0)
    # Isolate the lines by eroding very strongly horizontally
    lines_only = cv2.erode(~blurred, np.ones((1,21), np.uint8), iterations=1)
    # Beef them up a bit by vertically dilating
    thickend_lines = cv2.dilate(lines_only, np.ones((3,1), np.uint8), iterations=1)
    # Difference the original L channel with the thickened lines (which is inverted)
    diff = blurred + thickend_lines
    thresh = ~cv2.inRange(diff, 30, 235) # Reject pixels too black or too white
elif args.solarium55:
    blurred = cv2.GaussianBlur(l_channel, (5,5), 0)
    # Isolate the lines by eroding very strongly horizontally
    lines_only = cv2.erode(~blurred, np.ones((1,21), np.uint8), iterations=1)
    # Beef them up a bit by vertically dilating
    thickend_lines = cv2.dilate(lines_only, np.ones((3,1), np.uint8), iterations=1)
    # Difference the original L channel with the thickened lines (which is inverted)
    diff = blurred + thickend_lines
    thresh = ~cv2.inRange(diff, 30, 235) # Reject pixels too black or too white
elif args.comanche55 or args.luminary99:
    blurred = cv2.GaussianBlur(l_channel, (3,3), 0)
    # Isolate the lines by eroding very strongly horizontally
    lines_only = cv2.erode(~blurred, np.ones((1,21), np.uint8), iterations=1)
    # Difference the original L channel with the thickened lines (which is inverted)
    diff = blurred + lines_only
    # Blur a bit more then threshold the image
    diff = cv2.GaussianBlur(diff, (7,7), 0)
    thresh = cv2.adaptiveThreshold(diff, 255, cv2.ADAPTIVE_THRESH_GAUSSIAN_C, cv2.THRESH_BINARY, 21, 4)
    thresh = thresh[30:-70,70:]
elif args.colossus237:
    # Note that with Colossus237, we assume that the images have been pre-cropped
    # and deskewed.
    blurred = cv2.GaussianBlur(l_channel, (3,3), 0)
    # Isolate the lines by eroding very strongly horizontally
    lines_only = cv2.erode(~blurred, np.ones((1,21), np.uint8), iterations=1)
    # Difference the original L channel with the thickened lines (which is inverted)
    diff = blurred + lines_only
    # Blur a bit more then threshold the image
    diff = cv2.GaussianBlur(diff, (1,1), 0)
    thresh = cv2.adaptiveThreshold(diff, 255, cv2.ADAPTIVE_THRESH_GAUSSIAN_C, cv2.THRESH_BINARY, 21, 3)
    #_,thresh = cv2.threshold(diff, 0, 255, cv2.THRESH_BINARY+cv2.THRESH_OTSU)
    thresh = thresh[20:]
elif args.retread44:
    blurred = cv2.GaussianBlur(l_channel, (5,5), 0)
    #thresh = cv2.adaptiveThreshold(blurred, 255, cv2.ADAPTIVE_THRESH_MEAN_C, cv2.THRESH_BINARY, 201, 51)
    _,thresh = cv2.threshold(blurred, 125, 255, cv2.THRESH_BINARY)
elif args.luminary116:
    _,_,r_channel = cv2.split(img)
    blurred = cv2.GaussianBlur(r_channel, (7,7), 0)
    # Isolate the bands by eroding very strongly horizontally
    lines_only = cv2.erode(~blurred, np.ones((1,51), np.uint8), iterations=1)
    # Difference the original R channel with the isolated bands
    diff = blurred + lines_only
    _,thresh = cv2.threshold(diff, 240, 255, cv2.THRESH_BINARY)
elif args.artemis72:
    _,g_channel,r_channel = cv2.split(img)
    blurred = cv2.GaussianBlur(g_channel, (5,5), 0)
    lines_only = cv2.erode(~blurred, np.ones((1,21), np.uint8), iterations=1)
    diff = blurred + lines_only
    _,thresh = cv2.threshold(diff, 240, 255, cv2.THRESH_BINARY)
elif args.simAP11ROPE:
    _,_,r_channel = cv2.split(img)
    blurred = cv2.GaussianBlur(r_channel, (7,7), 0)
    # Isolate the bands by eroding very strongly horizontally
    lines_only = cv2.erode(~blurred, np.ones((1,51), np.uint8), iterations=1)
    # Difference the original R channel with the isolated bands
    diff = blurred + lines_only
    _,thresh = cv2.threshold(diff, 245, 255, cv2.THRESH_BINARY)
elif args.yul1:
    print('--yul1 not yet supported')
elif args.yul2:
    print('--yul2 not yet supported')
elif args.yul3:
    blurred = cv2.GaussianBlur(l_channel, (5,5), 0)
    # Isolate the lines by eroding very strongly horizontally
    lines_only = cv2.erode(~blurred, np.ones((1,21), np.uint8), iterations=1)
    # Beef them up a bit by vertically dilating
    thickend_lines = cv2.dilate(lines_only, np.ones((3,1), np.uint8), iterations=1)
    # Difference the original L channel with the thickened lines (which is inverted)
    diff = blurred + thickend_lines
    thresh = cv2.adaptiveThreshold(blurred, 255, cv2.ADAPTIVE_THRESH_MEAN_C, cv2.THRESH_BINARY, 201, 11)
    thresh = thresh[0:-100,80:-80]
elif args.yul4:
    print('--yul4 not yet supported')
elif args.yul5:
    print('--yul5 not yet supported')
elif args.yul6:
    print('--yul6 not yet supported')
elif args.yul7:
    print('--yul7 not yet supported')
elif args.yul8:
    print('--yul8 not yet supported')
elif args.yul9:
    print('--yul9 not yet supported')
elif args.yul10:
    print('--yul10 not yet supported')
elif args.zerlina56:
    _,g_channel,r_channel = cv2.split(img)
    blurred = cv2.GaussianBlur(g_channel, (5,5), 0)
    # Isolate the lines by eroding very strongly horizontally
    lines_only = cv2.erode(~blurred, np.ones((1,11), np.uint8), iterations=1)
    # Beef them up a bit by vertically dilating
    thickend_lines = cv2.dilate(lines_only, np.ones((3,1), np.uint8), iterations=1)
    # Difference the original L channel with the thickened lines (which is inverted)
    diff = blurred + thickend_lines
    thresh = ~cv2.inRange(diff, 30, 230) # Reject pixels too black or too white
    thresh = thresh[100:-100,80:-80]
    # blurred = cv2.GaussianBlur(g_channel, (1,5), 0)
    # #thresh = cv2.adaptiveThreshold(blurred, 255, cv2.ADAPTIVE_THRESH_MEAN_C, cv2.THRESH_BINARY, 211, 11)
    # _,thresh = cv2.threshold(blurred, 210, 255, cv2.THRESH_BINARY)
    sys.exit(0)
elif args.ap11rope:
    blurred = cv2.GaussianBlur(l_channel, (5,5), 0)
    # Isolate the lines by eroding very strongly horizontally
    lines_only = cv2.erode(~blurred, np.ones((1,21), np.uint8), iterations=1)
    # Beef them up a bit by vertically dilating
    thickend_lines = cv2.dilate(lines_only, np.ones((3,1), np.uint8), iterations=1)
    # Difference the original L channel with the thickened lines (which is inverted)
    diff = blurred + thickend_lines
    thresh = ~cv2.inRange(diff, 30, 240) # Reject pixels too black or too white
    thresh = thresh[0:-100,80:-80]
else:
    raise RuntimeError("Unknown program type selected")

if octcrop != "":
    exec(octcrop)

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

if args.no_crop:
    cv2.imwrite(args.output_file, result)
    sys.exit(0)

if args.comments:
    try:
        # First we need to remove holes along the left side. Find them by dilating vertically and looking for
        # a wide-enough left column
        hole_vdilated = cv2.dilate(~result, np.ones((61,21), np.uint8), iterations=1)
        cimg, contours, hierarchy = cv2.findContours(hole_vdilated, cv2.RETR_LIST, cv2.CHAIN_APPROX_NONE)
        contours.sort(key=lambda c: cv2.boundingRect(c)[0])

        left_lim = 0
        right_edge = result.shape[1]
        right_lim = right_edge

        for c in contours:
            box = cv2.boundingRect(c)
            #print(box, left_lim)
            if box[0] <= 1 or (box[0] <= 80 and box[2] < 80):
                # This is very likely a column of holes. Crop it out.
                left_lim = box[0]+box[2]
            else:
                break

        for c in reversed(contours):
            box = cv2.boundingRect(c)
            if box[0]+box[2] >= right_edge-100:
                # This is very likely a column of holes. Crop it out.
                right_lim = box[0]
            else:
                break

        target_image = result[:,left_lim:right_lim]

        # Create a structuring element to dilate to the right (trying to preserve exact leftmost pixels)
        element = np.zeros((1,15), np.uint8)
        for i in range(int(element.shape[1]/2)+1):
            element[0,i] = 1

        # Do the dilation. This should bleed together most of the header.
        dilated = cv2.dilate(~target_image, element, iterations=5)
        # cv2.imshow('image', dilated)
        # cv2.waitKey(0)
        # cv2.destroyAllWindows()

        # Locate the top header line, which stretches all 120 columns and thus both bounds and
        # provides reference to where on the page the various columns begin
        cimg, contours, hierarchy = cv2.findContours(dilated, cv2.RETR_LIST, cv2.CHAIN_APPROX_NONE)

        # Sort the contours by "line", considering lines breaks to be about 15 characters apart.
        # This approximates top-to-bottom, left-to-right reading order, as we would get from
        # something like Tesseract.
        def line_sort(a,b):
            ax,ay,_,_ = cv2.boundingRect(a)
            bx,by,_,_ = cv2.boundingRect(b)
            if abs(ay-by) > 15:
                return ay-by
            else:
                return ax-bx
        contours.sort(key=functools.cmp_to_key(line_sort))

        # Locate the header in the boxes. It'll be towards the front (hopefully exactly the front), and
        # pretty wide
        header_box = None
        header_start = 0
        for i,c in enumerate(contours):
            box = cv2.boundingRect(c)
            if (box[2] > 700):
                header_start = i
                header_box = list(box)
                break

        # Search backwards to make sure we aren't missing pieces of the header
        for i in range(header_start-1,-1,-1):
            box = cv2.boundingRect(contours[i])
            if abs(box[1] - header_box[1]) < 20:
                header_start = i
                rightmost = max(box[0]+box[2], header_box[0]+header_box[2])
                bottommost = max(box[1]+box[3], header_box[1]+header_box[3])
                header_box[0] = min(box[0], header_box[0])
                header_box[1] = min(box[1], header_box[1])
                header_box[2] = rightmost-header_box[0]
                header_box[3] = bottommost-header_box[0]

        if header_box is None:
            raise RuntimeError('Unable to find any sort of header')

        # Merge the bounding box we found with the rest on the line (needed for YUL listings since the
        # dilation above doesn't quite bleed everything together)
        for c in contours[header_start+1:]:
            box = cv2.boundingRect(c)
            if abs(header_box[0]-box[0]) <= 30:
                break
            rightmost_point = max(header_box[0]+header_box[2], box[0]+box[2])
            lowest_point = max(header_box[1]+header_box[3], box[1]+box[3])
            header_box[0] = min(header_box[0], box[0])
            header_box[1] = min(header_box[1], box[1])
            header_box[2] = rightmost_point - header_box[0]
            header_box[3] = lowest_point - header_box[1]

        # Calculate the average column width for rough cropping
        # TODO: Possibly make the cropping smarter
        header_width = header_box[2]-7*5
        column_width = int(header_width/120)

        # Create a mask onto which we'll draw the contours of words and lines we want to let through
        mask = np.ones(target_image.shape[:2], dtype=np.uint8) * 255

        # line_x and line_y keep track of the top left pixel of the bounding box for each line
        line_x = header_box[0]
        line_y = header_box[1]
        line_num = 0 # current estimated line number
        in_comment = True # whether or not we're inside a comment
        const_second_word = False
        crop_top = 0

        for i,c in enumerate(contours):
            x,y,w,h = cv2.boundingRect(c)
            if (w < 5 or h < 5):
                # Probably junk that's made it through
                continue

            # Check the x-position of the bounding box. If it's sufficiently close to the start of
            # the previous line, we can use its x-position to determine whether or not we're still
            # in a comment. It's handled this way because distortions on the image can be as large
            # as one to two character widths from the top to the bottom of the card type column.
            x_delta = x-line_x
            if (abs(x_delta) < 3*column_width) or (args.retread44 and line_num < 3 and y > line_y+30):
                # This is the start of a line. Record its x position.
                line_x = x

                # If this is the end of line 3, record the top of it as the top cropping point
                if line_num == 3:
                    crop_top = line_y

                line_num += 1
                line_y = y

                const_second_word = False
                if in_comment and x_delta > column_width*.5:
                    # This line does not start with a card type indicator, meaning it's code or something else.
                    in_comment = False
                elif not in_comment and x_delta < -column_width*.5:
                    # This line starts with a card type indicator, so it's a comment.
                    in_comment = True

                    # For YUL listings, a card marker following a non-comment line might possibly be a C, indicating
                    # the second word of a multi-word pseudo op (2DEC, 2CADR, etc.). Try to determine whether or not
                    # we've got such a line.
                    if line_num > 2:
                        pil_img = Image.fromarray(target_image[y-1:y+h+1, x-5:x+column_width*6])
                        txt = image_to_string(pil_img, config='-l eng -psm 6 -c tessedit_char_whitelist=CARP01234567')
                        if txt and (txt[0] == 'C' or txt[0] == '0'):
                            const_second_word = True

            # If the y position of this box is less than line_y, mark it as the new highest point on the line
            if y < line_y:
                line_y = y

            # Draw this contour if we're in a comment and beyond the headers
            if in_comment and not const_second_word and line_num > 2:
                cv2.drawContours(mask, [c], -1, 0, -1)

        # Special case for only a single line on the page
        if line_num == 3:
            crop_top = line_y

        # We also want everything from column 80 on
        if args.retread44:
            comment_column = header_box[0] + column_width*78
        else:
            comment_column = header_box[0] + column_width*80
            
        cv2.rectangle(mask, (comment_column, crop_top), (target_image.shape[1], target_image.shape[0]), 0, -1)

        # But we don't want anything left of column ~7 or right of the header
        left_limit = header_box[0]+7*column_width
        right_limit = header_box[0]+header_width
        cv2.rectangle(mask, (0, 0), (left_limit, target_image.shape[0]), 255, -1)

        # Apply the mask. We should be down to just comments now.
        comments_only = target_image + mask
        inside_header = comments_only[crop_top-20:, left_limit-20:header_box[0]+header_width+20]

        # # Look for contours in the imge to find the final limits
        # _,thresh2 = cv2.threshold(inside_header, 180, 255, cv2.THRESH_BINARY)
        # dilated2 = cv2.dilate(~thresh2, np.ones((5,5), np.uint8), iterations=4)
        # cimg, contours, hierarchy = cv2.findContours(dilated2, cv2.RETR_LIST, cv2.CHAIN_APPROX_NONE)
        
        # xmin = 99999
        # ymin = 99999
        # xmax = 0
        # ymax = 0

        # for c in contours:
        #     x,y,w,h = cv2.boundingRect(c)
        #     if x < xmin:
        #         xmin = x
        #     if y < ymin:
        #         ymin = y
        #     if x+w > xmax:
        #         xmax = x+w
        #     if y+h > ymax:
        #         ymax = y+h

        # if xmin < xmax:
        #     final_image = inside_header[max(ymin-20,0):ymax+20, max(xmin-20,0):xmax+20]
        # else:
        #     final_image = inside_header
        final_image = inside_header
    except Exception as e:
        print('Encountered an unexpected error, falling back on --no-crop')
        traceback.print_exc()
        final_image = result


else:
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
    top_h = 0 
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
                #print(x)
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

    #print(ymin,ymax,xmin,xmax)
    final_image = no_addr[ymin:ymax, xmin:xmax]


# All done! Write out the prepared image
cv2.imwrite(args.output_file, final_image)

# cv2.imshow('image', dilated6)
# cv2.waitKey(0)
# cv2.destroyAllWindows()
