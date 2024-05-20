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
## Copyright:	Public domain.
## Filename:	{}
## Purpose:	A section of Comanche revision 072.
##		It is part of the reconstructed source code for the first
##		release of the software for the Command Module's (CM) Apollo
##		Guidance Computer (AGC) for Apollo 13. No original listings
##		of this program are available; instead, this file was recreated
##		from a printout of Comanche 055, binary dumps of a set of
##		Comanche 067 rope modules, and changelogs between Comanche 067
##		and 072. It has been adapted such that the resulting bugger words
##		exactly match those specified for Comanche 072 in NASA drawing
##		2021153G, which gives relatively high confidence that the
##		reconstruction is correct.
## Assembler:	yaYUL
## Contact:	Ron Burkey <info@sandroid.org>.
## Website:	www.ibiblio.org/apollo/index.html
## Mod history:	2024-05-13 MAS	Created from Comanche 067.
'''
with open(sys.argv[1], 'r') as m:
    for line in m:
        # Find all of the included files
        if not line.startswith('$'):
            continue

        # Determine the included file's name and page range
        # parts = line.split('#')
        # fname = parts[0].strip()[1:]
        fname = line.strip()[1:]
        print(fname)
        # pages = parts[1].strip()
        with open(fname, 'r') as f:
            section_lines = f.readlines()

        # Find the start of the first page. Everything before it should
        # be the header.
        for i,s in enumerate(section_lines):
            if not s.startswith('##'):
                break

        # Replace all of the old header lines with the new header.
        formatted = HEADER.format(fname).splitlines(True)
        section_lines = formatted + section_lines[i:]

        with open(fname, 'w') as f:
            f.writelines(section_lines)
