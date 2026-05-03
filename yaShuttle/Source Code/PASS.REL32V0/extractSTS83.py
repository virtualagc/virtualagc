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

def extract(filename, pageNumber, sizeX, sizeY, textBoxes = False):
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
                                    print(f"{round(x0)},{round(y0)}, {round(x1)},{round(y1)}")
                                    print(char_text)

if __name__ == "__main__":
    import sys
    filename = sys.argv[1]
    pageNumber = int(sys.argv[2])
    sizeX = float(sys.argv[3])
    sizeY = float(sys.argv[4])
    extract(filename, pageNumber, sizeX, sizeY)
    