#!/usr/bin/env python
'''
Experimental code for extracting STS display templates specifically from
https://www.ibiblio.org/apollo/Shuttle/sts83-0020v1-34%20-%20Displays%20and%20Controls%20-%20GNC.pdf,
but maybe from similar documents too.  The code is adapted from here:
https://stackoverflow.com/questions/22898145/how-to-extract-text-and-text-coordinates-from-a-pdf-file
'''

from pdfminer.layout import LAParams, LTTextBox, LTTextLine, LTChar
from pdfminer.pdfpage import PDFPage
from pdfminer.pdfinterp import PDFResourceManager
from pdfminer.pdfinterp import PDFPageInterpreter
from pdfminer.converter import PDFPageAggregator

def extract(filename, pageNumber, sizeX, sizeY, textBoxes = False, crop=None):
    
    if crop != None:
        left = crop[0]
        right = crop[1]
        top = crop[2]
        bottom = crop[3]
    
    fp = open(filename, 'rb')
    rsrcmgr = PDFResourceManager()
    laparams = LAParams()
    device = PDFPageAggregator(rsrcmgr, laparams=laparams)
    interpreter = PDFPageInterpreter(rsrcmgr, device)
    pages = PDFPage.get_pages(fp)
    
    pageNumber -= 1
    for n, page in enumerate(pages):
        if n < pageNumber:
            continue
        elif n == pageNumber:
            pass
        else:
            break 
        #print(page.mediabox)
        scaleX = sizeX / page.mediabox[3]
        scaleY = sizeY / page.mediabox[2]
        interpreter.process_page(page)
        layout = device.get_result()
        for lobj in layout:
            if isinstance(lobj, LTTextBox):
                if textBoxes: # Drill down to text boxes
                    x0, y1, x1, y0, text = lobj.bbox[0], lobj.bbox[1], lobj.bbox[2], lobj.bbox[3], lobj.get_text()
                    x0 *= scaleX
                    x1 *= scaleX
                    y0 = (page.mediabox[2] - y0) * scaleY
                    y1 = (page.mediabox[2] - y1) * scaleY
                    print(f"{round(x0)},{round(y0)}, {round(x1)},{round(y1)}")
                    print(text)
                else: # Drill down to individual characters.
                    for text_line in lobj:
                        if isinstance(text_line, LTTextLine):
                            for character in text_line:
                                if isinstance(character, LTChar):
                                    # (x0, y0) = bottom-left; (x1, y1) = top-right
                                    x0, y1, x1, y0 = character.bbox
                                    char_text = character.get_text()
                                    x0 *= scaleX
                                    x1 *= scaleX
                                    y0 = (page.mediabox[2] - y0) * scaleY
                                    y1 = (page.mediabox[2] - y1) * scaleY
                                    if crop == None:
                                        print(f"{round(x0)},{round(y0)}, {round(x1)},{round(y1)}")
                                    else:
                                        if x1 < left or x0 > right or \
                                                y1 < top or y0 > bottom:
                                            continue
                                        x0 -= left
                                        x1 -= left
                                        y0 -= top
                                        y1 -= top
                                        '''
                                        Convert the center of each character
                                        box to row,column coordinates.  It's
                                        not entirely clear how to do that, but
                                        here's how I'm doing it, which I'm 
                                        certain needs tweaks once the use of
                                        *.dfg files is fully understood.  I use
                                        a screen pixel geometry of 1024x730.  
                                        Rows 0-25 are at y=13+28*row.  Columns
                                        0-50 are at x=27+19*column.
                                        '''
                                        scaleHorizontal = 1024.0 / (right - left)
                                        scaleVertical = 730.0 / (bottom - top)
                                        x = (x0 + x1) / 2.0
                                        y = (y0 + y1) / 2.0
                                        row = int(round(scaleVertical * (y - 13) / 28.0))
                                        col = int(round(scaleHorizontal * (x - 27) / 19.0))
                                    print(f"{round(x0)},{round(y0)}, {round(x1)},{round(y1)}, {row},{col}")
                                    print(char_text)

if __name__ == "__main__":
    
    helpMsg = '''
Usage:
     extractSTS83.py FILE.pdf PAGENUMBER XSIZE YSIZE [OPTIONS]
where XSIZE,YSIZE are the width and height of the selected page, in pixels
(if the PDF page were extracted as an image).  All coordinates are in pixels
relative to the upper left.

The available OPTIONS are:

     --help          Show this message.
     --text-boxes    Extract "blocks" of text rather than individual characters
                     (the default).
     --crop=L,R,T,B  Remove all objects not intersecting the specified crop
                     area, which is specified by the page pixel coordinates
                     of its left, right, top, and bottom borders.  In the 
                     output, the coordinates are relative to the upper left
                     of the crop area rather than to the page, but row,column
                     (26,51) coordinates are given as well.
'''
    import sys
    import os
    
    def outtaHere(level=1):
        print(helpMsg)
        os._exit(level)
    
    try:
        filename = sys.argv[1]
        pageNumber = int(sys.argv[2])
        sizeX = float(sys.argv[3])
        sizeY = float(sys.argv[4])
        textBoxes = False
        crop = None
        for parm in sys.argv[5:]:
            fields = parm.partition("=")
            if fields[0] == "--help":
                outtaHere(0)
            elif fields[0] == "--text-boxes":
                textBoxes = True
            elif fields[0] == "--crop":
                fields = fields[2].split(",")
                crop = (int(fields[0]), int(fields[1]),
                        int(fields[2]), int(fields[3]))
            else:
                print("Unrecognized parameter", parm)
                outtaHere()
    except:
        outtaHere()
    extract(filename, pageNumber, sizeX, sizeY, textBoxes=textBoxes, crop=crop)
    