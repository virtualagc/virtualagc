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

import sys
import glob
import datetime

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
    
    
def main():

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

    direction = prompt("Processing direction (0=column order, 1=row order, 2=column/block order) [0]: ")
    if direction == None:
        direction = 0
    else: 
        direction = int(direction)

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
    print
    
    if infile:
        parse(infile)
    
    pagedata = {}

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

        print "Saving page..."
        ofile = open(outfile, 'a')
        lines = []
        stop = False
        for row in range(32):
            line = ""
            for col in range(8):
                pos = row * 8 + col
                line += "%05o " % pagedata[pos]
            if stop:
                break
            line += "\n"
            if (row + 1) % 4 == 0:
                line += "\n"
            lines.append(line)
     
        ofile.write("; p. %d\n" % page)
        ofile.writelines(lines)
        ofile.write("\n")
        ofile.close()
        
        response = prompt("Next page (y/n) [n]: ")
        if response == 'y':
            page += 1
            continue
        else:
            break
    
    print "Done"
    
if __name__ == "__main__":
    main()

# TODO: calculate and print address of row
# TODO: check checksum
