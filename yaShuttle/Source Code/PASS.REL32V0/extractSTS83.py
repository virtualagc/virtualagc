#!/usr/bin/env python
'''
Experimental code for extracting STS display templates specifically from
https://www.ibiblio.org/apollo/Shuttle/sts83-0020v1-34%20-%20Displays%20and%20Controls%20-%20GNC.pdf,
but maybe from similar documents too.  The code is adapted from here:
https://stackoverflow.com/questions/22898145/how-to-extractDisplayText-text-and-text-coordinates-from-a-pdf-file
'''

import math

from pdfminer.layout import LAParams, LTTextBox, LTTextLine, LTChar
from pdfminer.pdfpage import PDFPage
from pdfminer.pdfinterp import PDFResourceManager
from pdfminer.pdfinterp import PDFPageInterpreter
from pdfminer.converter import PDFPageAggregator

import cv2
import numpy as np
from pdf2image import convert_from_path

def getCropFromPDF(filename, pageNumber=0, dpi=192, debug=False):
    L = 1000000
    R = -1000000
    T = 1000000
    B = -1000000
    thresh = 0.2
    
    # Convert PDF to list of PIL images
    pages = convert_from_path(filename, dpi=192)
    
    for n, page in enumerate(pages):
        if n < pageNumber:
            continue
        elif n == pageNumber:
            pass
        else:
            break 
        
        # Convert PIL image to numpy array (OpenCV format)
        img = np.array(page)
    
        # Convert RGB to BGR (OpenCV uses BGR)
        gray = cv2.cvtColor(img, cv2.COLOR_RGB2BGR)
    
        sizeY = gray.shape[0]
        threshSizeY = sizeY * thresh
        sizeX = gray.shape[1]
        threshSizeX = sizeX * thresh
        edges = cv2.Canny(gray, 50, 150)
        lines = cv2.HoughLinesP(edges, 1, np.pi/180, threshold=200, minLineLength=100, maxLineGap=10)
        tolerance = 5
        if lines is not None:
            for line in lines:
                if debug:
                    print("Line:", line[0])
                x1, y1, x2, y2 = line[0]
                yLen = abs(y1 - y2)
                xLen = abs(x1 - x2)
                if yLen < tolerance and xLen > threshSizeX:
                    y = (y1 + y2) / 2
                    if y < T:
                        T = y
                    if y > B:
                        B = y
                elif xLen < tolerance and yLen > threshSizeY:
                    x = (x1 + x2) / 2
                    if x < L:
                        L = x
                    if x > R:
                        R = x
    
    return L, R, T, B, sizeX, sizeY

def extractDisplayText(filename, pageNumber, sizeX, sizeY, textBoxes = False, crop=None):
    
    if crop != None:
        left = crop[0]
        right = crop[1]
        top = crop[2]
        bottom = crop[3]
        # Conversion factors from PDF pixels to display-screen pixels:
        scaleHorizontal = 1024.0 / (right - left)
        scaleVertical = 730.0 / (bottom - top)
    
    fp = open(filename, 'rb')
    rsrcmgr = PDFResourceManager()
    laparams = LAParams()
    device = PDFPageAggregator(rsrcmgr, laparams=laparams)
    interpreter = PDFPageInterpreter(rsrcmgr, device)
    pages = PDFPage.get_pages(fp)
    
    pageNumber
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
                                        *.dfg files is fully understood.  We 
                                        need to convert PDF page pixel geometry to
                                        Shuttle display-screen pixel geometry.
                                        And from there, convert to text 
                                        row,column geometry. It appears to me that
                                        character rows are spaced at 27 screen
                                        pixel rows, and character columns are
                                        spaced at 19 screen pixel columns.
                                        Also:
                                            Character row 1 is at y=27
                                            Character column 2 is at x=57
                                        '''
                                        x = scaleHorizontal * (x0 + x1) / 2.0
                                        y = scaleVertical * (y0 + y1) / 2.0
                                        # Note: Don't use `round()` here, 
                                        # because of daffy Python behavior of
                                        # using "banker's rounding".
                                        row = math.floor(0.5 + 1 + (y - 27) / 27)
                                        col = math.floor(0.5 + 2 + (x - 57) / 19)
                                    if False:
                                        print(f"{round(x0)},{round(y0)}, {round(x1)},{round(y1)}, {row},{col}")
                                        print(char_text)
                                    else:
                                        print(f"{char_text}\t{row}\t{col}")

if __name__ == "__main__":
    
    helpMsg = '''
Usage:
     extractSTS83.py FILE.pdf [OPTIONS]
The PDF file should contain a single page.  All coordinates are in pixels 
relative to the upper left.

The available OPTIONS are:

     --help               Show this message.
     --crop=L,R,T,B,X,Y   Override autocrop with locations of display-screen 
                          edges (L,R,T,B) measured from upper-left corner, and
                          page size (X,Y).  All are in PDF page pixels.
     --debug              Enable some debugging messages.
'''
    import sys
    import os
    
    def outtaHere(level=1):
        print(helpMsg)
        os._exit(level)
    
    crop = None
    try:
        filename = sys.argv[1]
        
        pageNumber = 0
        debug = False
        for parm in sys.argv[2:]:
            fields = parm.partition("=")
            if fields[0] == "--help":
                outtaHere(0)
            elif fields[0] == "--debug":
                debug = True
            elif fields[0] == "--crop":
                fields = fields[2].split(",")
                crop = (int(fields[0]), int(fields[1]), int(fields[2]),
                        int(fields[3]), int(fields[4]), int(fields[5]))
            else:
                print("Unrecognized parameter", parm)
                outtaHere()
        
        if crop == None:
            crop = getCropFromPDF(filename, debug=debug)
        aspect = (crop[1] - crop[0]) / (crop[3] - crop[2])
        if aspect < 1.4 or aspect > 1.5:
            print(f"Edge detection for {filename} may have failed.", file=sys.stderr)
        print(f"# Geometry={crop[4]}x{crop[5]}, crop UL={crop[0]},{crop[2]} LR={crop[1]},{crop[3]}, aspect={aspect}")
    except:
        outtaHere()
    extractDisplayText(filename, pageNumber, crop[4], crop[5], crop=crop)
    