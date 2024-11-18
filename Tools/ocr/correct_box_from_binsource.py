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

# Python script to replace all detected characters in a Tesseract box file
# with the corresponding proofed data in a binsource file. The binsource data
# is assumed to contain parity. The page numbers must be supplied in the order
# they are present in the binsource file, and in general it's a good idea to
# supply the same number of page arguments as there are in the box file.

import sys

if len(sys.argv) < 4:
    print('Usage:   correct_box_from_binsource.py box_file binsource_file page1 page2 ...')
    print('Example: correct_box_from_binsource.py octal.burst.exp0.box Sunburst120.binsource 1173 1208 1210 1260')
    sys.exit(0)

with open(sys.argv[1], 'r+') as box_file, open(sys.argv[2], 'r') as binsource:
    binsource_lines = binsource.readlines()
    box_lines = box_file.readlines()

    pages = sys.argv[3:]

    for page_num, page in enumerate(pages):
        # Locate the start and end of this page in the binsource
        start = -1
        end = 9999999
        for n,line in enumerate(binsource_lines):
            if start != -1 and line.startswith('; p.'):
                end = n
                break

            if line.startswith('; p. ' + page):
                start = n+1

        if start == -1:
            raise RuntimeError("Couldn't find page %s!" % page)

        # Only pull in lines starting with a number
        octal_lines = [line for line in binsource_lines[start:end] if line[0].isdigit()]
        # Concatenate all the lines and remove everything that's not an octal digit
        octal_data = ''.join([x for x in ''.join(octal_lines) if x in '01234567'])

        print('Found %u digits for page %s' % (len(octal_data), page))

        # Find the corresponding page in the box file
        char_index = 0
        for i in range(len(box_lines)):
            digit, x_min, y_min, x_max, y_max, page_index = box_lines[i].split()
            if page_index == str(page_num):
                # Found a character from our page. Overwrite the character with the one from
                # the binsource and advance the character index
                digit = octal_data[char_index]
                box_lines[i] = ' '.join([digit, x_min, y_min, x_max, y_max, page_index]) + '\n'
                char_index += 1

        print('Replaced %u characters for page %s' % (char_index, page))
    
    print('Success! Saving changes to %s.' % sys.argv[1])
    box_file.seek(0)
    box_file.writelines(box_lines)
    box_file.truncate()
