#
# Python program to replace AGC file headers en masse (mostly useful
# for creating a skeleton directory for a new program).
# 
# Mike Stewart 2017-01-22
# 
# The program takes as its one argument a MAIN.agc file. It determines
# all of the included AGC files and their page ranges, then updates
# the header in each.
import sys

# The header to use for replacement.
HEADER = '''### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    {}
## Purpose:     A section of Luminary revision 116.
##              It is part of the source code for the Lunar Module's (LM) 
##              Apollo Guidance Computer (AGC) for Apollo 12.
##              This file is intended to be a faithful transcription, except
##              that the code format has been changed to conform to the
##              requirements of the yaYUL assembler rather than the
##              original YUL assembler.
## Reference:   {}
## Assembler:   yaYUL
## Contact:     Ron Burkey <info@sandroid.org>.
## Website:     www.ibiblio.org/apollo/index.html
## Mod history: 2017-01-22 MAS  Created from Luminary 99.

## NOTE: Page numbers below have not yet been updated to reflect Luminary 116.

'''
with open(sys.argv[1], 'r') as m:
    for line in m:
        # Find all of the included files
        if not line.startswith('$'):
            continue

        # Determine the included file's name and page range
        parts = line.split('#')
        fname = parts[0].strip()[1:]
        print(fname)
        pages = parts[1].strip()
        with open(fname, 'r') as f:
            section_lines = f.readlines()
            
        # Find the start of the first page. Everything before it should
        # be the header.
        for i,s in enumerate(section_lines):
            if s.startswith('## Page '):
                break

        # Replace all of the old header lines with the new header.
        formatted = HEADER.format(fname, pages).splitlines(True)
        section_lines = formatted + section_lines[i:]

        with open(fname, 'w') as f:
            f.writelines(section_lines)
