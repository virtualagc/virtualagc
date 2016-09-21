#
# Python program to aid entering AGC binsource.
#
# Jim Lawton 2009-10-09
#
# binsource files are in the form of blocks of 5-digit octal numbers,
# 8 per line, 4 lines per block, 8 blocks per page, 4 pages per bank.
# Example:
#
#     50026 30001 30027 02177 50026 30001 30027 02034
#     50026 30001 30027 02630 50026 30001 30027 02042
#     50026 30001 30027 02037 50026 30001 30027 02377
#     20017 32075 50015 07005 03007 01101 02266 32075
#
# Comments begin with a semicolon. The rest of the line is ignored.
# the BANK keyword specifies the bank number (e.g. "BANK=2").

# TODO: calculate and print address of row
# TODO: check checksum


import os
import sys
import glob
import datetime
import signal


_DEFAULT_HEADER = \
"""
; Copyright:    Public domain
; Filename:     Solarium055.binsource
; Purpose:      An ASCII file used to input an AGC executable in octal format.
;               The actual octal (usable by the yaAGC program) must be created
;               by processing with the oct2bin program (which may be found in
;               the Tools directory of the virtualagc project).
;               Refer to www.ibiblio.org/apollo for explanations.
; Contact:
; History:      YYYY-MM-DD XXX  Created.
;
;
; This data has been manually transcribed from a scanned listing of TBD
; build NNN.
;
; For convenience, the page numbers (as marked on the printed assembly listing)
; are given in the comments. The notations V or A (or both or neither) have
; been added after the page numbers to indicate the proofing method used
; (Visual or Audio). Regardless of the proofing method (if any), all code is
; believed to be correct, on the basis of automated checking of the "bugger
; words" (i.e., bank checksums), except, of course, where stated otherwise.
; (The parenthesized number, if any, following the V or A, is the number of
; errors corrected on that proofing pass.)
;
; The rule followed here is that each memory page has to be proofed at least
; once, and that the *final* proofing of any given memory page must have
; encountered 0 errors.
;
; Input-data format:
;   Each memory bank begins with a "BANK=" line. The remainder of the bank
;   consists of octal values. Note that banks should be zero-filled at the end
;   to make the lengths come out correct.

NUMBANKS=34
"""


def signal_handler(signal, frame):
    global pagedata, page, outfile, useCommas
    print "Ctrl+C"
    savePage(outfile, page, pagedata, useCommas, crash=True)
    sys.exit(1)


def prompt(promptString, default=""):
    response = raw_input(promptString)
    if len(response) == 0:
        if len(default) > 0:
            response = default
        else:
            response = None
    return response


def octPrompt(promptString="5 digit octal: "):
    while True:
        response = raw_input(promptString)
        if len(response) == 0 or len(response) > 5:
            response = None
            break
        else:
            try:
                response = int(response, 8)
                break
            except:
                continue
    return response


def parse(infile):
    ifile = open(infile, 'r')
    lines = ifile.readlines()
    print "Parsing input file..."
    for line in lines:
        if line.startswith(';'):
            continue
        if line.startswith("BANK="):
            bank = int(line.split('=')[1])
            print "    Bank %d" % bank
    ifile.close()


def savePage(outfile, page, pagedata, useCommas=False, crash=False):
    print "Saving page..."
    if outfile is None:
        return
    ofile = open(outfile, 'a')
    lines = []
    if crash:
        if pagedata is None or pagedata == {}:
            lines = ["\n",
                "************************** CRASH *************************\n",
                "*                    No data to save!                    *\n",
                "**********************************************************\n"]
        else:
            lines = ["\n",
                "*********************** CRASH SAVE ***********************\n",
                "* Please check data below this point. It may be corrupt! *\n",
                "**********************************************************\n"]
    stop = False
    if pagedata:
        for row in range(32):
            line = ""
            for col in range(8):
                pos = row * 8 + col
                if pos not in pagedata.keys():
                    continue
                if useCommas:
                    line += "%05o, " % pagedata[pos]
                else:
                    line += "%05o " % pagedata[pos]
            line += "\n"
            if (row + 1) % 4 == 0:
                line += "\n"
            lines.append(line)
    if crash and not (pagedata is None or pagedata == {}):
        lines.extend(["\n",
            "*********************** CRASH SAVE ***********************\n",
            "\n"])
    ofile.write("; p. %d\n" % page)
    ofile.writelines(lines)
    ofile.write("\n")
    ofile.close()


def main():
    global pagedata, page, outfile, useCommas
    outfile = None
    page = None
    pagedata = {}
    useCommas = False

    startpage = prompt("Starting page: ")
    if startpage == None:
        print >>sys.stderr, "Error, must specify a starting page."
        sys.exit(1)
    else:
        startpage = int(startpage)
    bsFiles = glob.glob('*.binsource')
    if len(bsFiles) == 1:
        defInfile = bsFiles[0]
        promptStr = "Input file (default=%s): " % defInfile
    else:
        defInfile = None
        promptStr = "Input file: "
    infile = prompt(promptStr)
    if infile == None:
        infile = defInfile

    defOutfile = "%s-%d.binsource" % (datetime.datetime.now().strftime("%Y%m%d_%H%M%S"), startpage)
    promptStr = "Output file (default=%s): " % defOutfile

    outfile = prompt(promptStr)
    if outfile == None:
        outfile = defOutfile

    if os.path.exists(outfile):
        print "File %s already exists!" % outfile
        overwrite = prompt("Overwrite? (Y/N) [N]: ")
        if overwrite == None or overwrite == "N":
            print >>sys.stderr, "Exiting."
            sys.exit(1)

    direction = prompt("Processing direction (0=column order, 1=row order, 2=column/block order) [0]: ")
    if direction == None:
        direction = 0
    else:
        direction = int(direction)

    useCommas = prompt("Use comma delimiters? (Y/N) [N]: ")
    if useCommas == None or useCommas == "N":
        useCommas = False
    else:
        useCommas = True

#    startaddr = prompt("Starting address [02000]: ")
#    if startaddr == None:
#        startbank = 0
#        startaddr = 02000
#    else:
#        if ',' in startaddr:
#            startbank = int(startaddr.split(',')[0], 8)
#            startaddr = int(startaddr.split(',')[1], 8)
#        else:
#            startbank = 0
#            startaddr = int(startaddr, 8)

    print "Input file: %s" % infile
    print "Output file: %s" % outfile
    print "Direction: %s" % direction
    print "Starting page: %s" % startpage
#    print "Starting bank: %s" % oct(startbank)
#    print "Starting address: %s" % oct(startaddr)
    print "Comma delimiters: %s" % useCommas
    print

    if infile:
        parse(infile)
    else:
        # Put default header text in the output file.
        ofile = open(outfile, 'w')
        ofile.write(_DEFAULT_HEADER)
        ofile.write("\n")
        ofile.close()

    stop = False
    page = startpage

    while not stop:
        print "Page: %d" % page

        col = 0
        row = 0
        block = 0
        blockrow = 0

        zeroRest = False
        zeroCol = False

        # Can process input in different directions.
        # Output always stored in row order.
        if direction == 0:
            # Column order, i.e. top to bottom of page for each column, left to right.
            while col < 8:
                print "Column: %02d" % col
                row = 0
                while row < 32:
                    word = octPrompt("Row %02d: " % row)
                    if word == None:
                        response = prompt("Back (b), Retry (r), finish (f), zero rest of column (z) [r]: ", default='r')
                        if response == 'f':
                            stop = True
                            break
                        elif response == 'b':
                            row -= 1
                            if row < 0:
                                row = 0
                            continue
                        elif response == 'z':
                            zeroCol = True
                            break
                        else:
                            continue
                    pagedata[row * 8 + col] = word
                    if (row + 1) % 4 == 0:
                        print
                    row += 1
                if stop:
                    break
                if zeroCol:
                    for zrow in range(row, 32):
                        pagedata[zrow * 8 + col] = 0
                col += 1

        elif direction == 1:
            # Row order, i.e. left to right for each row of page, top to bottom.
            while row < 32:
                print "Row: %02d" % row
                col = 0
                while col < 8:
                    word = octPrompt("Col %02d: " % col)
                    if word == None:
                        response = prompt("Back (b), Retry (r), finish (f), zero rest of page (z) [r]: ", default='r')
                        if response == 'f':
                            stop = True
                            break
                        elif response == 'z':
                            zeroRest = True
                            break
                        elif response == 'b':
                            col -= 1
                            if col < 0:
                                col = 0
                            continue
                        else:
                            continue
                    pagedata[row * 8 + col] = word
                    col += 1
                if stop:
                    break
                if zeroRest:
                    break
            if zeroRest:
                for pos in range(row * 8 + col, 256):
                    pagedata[pos] = 0
            row += 1

        else:
            # Column block order in a page, i.e. top to botton of page for each block of 4 rows,
            # column order within each block.
            while block < 8:
                print "Block: %02d" % block
                col = 0
                while col < 8:
                    print "Column: %02d" % col
                    blockrow = 0
                    while blockrow < 4:
                        row = block * 4 + blockrow
                        word = octPrompt("Row %02d: " % blockrow)
                        if word == None:
                            response = prompt("Back (b), Retry (r), finish (f) [r]: ", default='r')
                            if response == 'f':
                                stop = True
                                break
                            elif response == 'b':
                                blockrow -= 1
                                if blockrow < 0:
                                    blockrow = 0
                                    continue
                            else:
                                continue
                        pagedata[row * 8 + col] = word
                        blockrow += 1
                    if stop:
                        break
                    col += 1
                if stop:
                    break
                print
                block += 1

        savePage(outfile, page, pagedata, useCommas)

        response = prompt("Next page (y/n) [n]: ")
        if response == 'y':
            page += 1
            continue
        else:
            break

    print "Done"


if __name__ == "__main__":
    global pagedata, page, outfile
    signal.signal(signal.SIGINT, signal_handler)
    main()
