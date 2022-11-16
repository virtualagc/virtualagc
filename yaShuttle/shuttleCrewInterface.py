#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Copyright:      None - the author (Ron Burkey) declares this software to
                be in the Public Domain, with no rights reserved.
Filename:       shuttleCrewInterface.py
Purpose:        Simulated crew interface for the shuttle.  Basically keyboards
                and MDUs, but could be other manually-operated controls.  This 
                file is intended to be used as a module for the program yaPASS.py
                (Phase 1 emulation) rather than being used directly. 
History:        2022-11-03 RSB  Created.
                2022-11-04 RSB  Working!

Here are two significant facts about the shuttle's crew interface as it pertains
to this module:
 
    1.  There was a makeover beginning in 1999, where the various elements of the
        display system (namely the CRTs, the DEUs driving them, and so on) were 
        replaced by the so-called Multifunction Electronic Display Subsystem
        (MEDS, consisting of MFD in place of CRTs, IDPs in place of DEUs, etc.).
        This very-significant upgrade was supposedly transparent to the GPCs'
        software.  However, it resulted in *more* displays, capable of displaying
        *more*, in formats which had been changed somewhat.
    2.  What was displayed on the CRTs or MFDs was not solely controlled by
        the PASS/BFS software.  Rather, it was a *combination* of display templates
        stored within the DEU/IDP *plus* commands from the GPCs *plus* data
        supplied directly by other shuttle systems.
        
Thus this emulation may be able to represent exactly the data supplied by the
GPC, represent partially the built-in templates (since they are not entirely
known from the documentation), and not represent at all any additional data 
from the spacecraft.

Example usage from calling program:

    import queue
    import shuttleCrewInterface as crewInterface
    
    keyboardDatabus = queue.Queue()
    monitorDatabus = queueu.Queue()
    crewInterface.initializeKeyboards(keyboardDatabus, ...)
    crewInterface.initializeMonitors(monitorDatabus, ...)
    crewInterfaces = threading.Thread(target=crewInterface.runCrewInterface, args=())
    crewInterfaces.start()
        
The full arguments for the initializeKeyboards() function mentioned above are:
    keyboardDatabus (a Python queue)
    keyboardNames   (default ["Space Shuttle Keyboard"].)  An array
                    of keyboard names.  A separate keyboard is started
                    for each entry in this list.
    scale           (default 0.66667)  A scale factor for the GUI
    imageFilename   the name of the file containing the image of the 
                    keyboard, scaled to 1.0.

The full arguments for the initilizeMonitors() function are similar to those of
initializeKeyboards().

Data is delivered to the emulated CPU (yaPASS.py) via a shuttle databus emulated
as a queue, namely keyboardQueue, the entries of which are strings of one of the 
following 3 forms:

    N\tpressed\tBUTTON_NAME
    N\treleased\tBUTTON_NAME
    QUIT 
    
Here, N is the interface number on which the button was pressed.  The interfaces
for keyboards are numbered 1, 2, 3, ..., while those for monitors are numbered
101, 102, 103, ....  The strings 'pressed', 'released', and 'QUIT' are literals.

Data is output from the emulated CPU via a shuttle databus named monitorQueue,
also emulated as a queue, the entries of which are one of the following:

    N\ttext\tROW\tCOLUMN\tCOLOR\tTEXT
    N\tflash\tROW\tCOLUMN\tCOLOR\tTEXT
    N\tbackground\tCOLOR
    
N indicates the targeted monitor, using the numbering scheme mentioned for 
keyboards:  101 is the first monitor, 102 is the second, and so on.
The literal 'text' is used for non-flashing text, whereas the literal 'flash'
is used for flashing text.  ROW is 1 through 26, while COLUMN is 1 through 51.  
COLOR can be specified as a hexadecimal string of the form #RRGGBB.  Because the
fields of the queued message are tab-delimited, TEXT to be displayed can contain
leading, trailing, or embedded spaces, but not tabs. If the 
monitors are displayed at scale=1.0, each character can occupy a space of about 
12x23 pixels (if there's no spaces in between), with about a 10-pixel margin 
between text and the edge of the display area.  (It's difficult to make exact 
statements about the margins, because the display area has rounded corners.) 
The "background" command affect the background color going forward.

Using the cv2 module for display, flashing text may be rather expensive (CPU-wise)
to accommodate, so I don't guarantee that there will actually be any difference
between 'text' text and 'flash' text.  We'll see.
"""

import cv2
import numpy as np
import queue

# Globals specific to the keyboards.
imageFile = "ShuttleKeyboard600.jpg"
left = 82.5
top = 52.5
size = 75
ySpacing = 82.3
xSpacing = 83.5
dim = (0, 0)
scale = 0.66667
lefts = []
rights = []
tops = []
bottoms = []
transparent = ""
keyboardDatabus = ""
windowCount = 1
imgs = []
keyboardNames = []
buttons = [ ["FAULT SUMM", "SYS SUMM", "MSG RESET", "ACK"],
            ["GPC/CRT", "A", "B", "C"],
            ["I/O RESET", "D", "E", "F"],
            ["ITEM", "1", "2", "3"],
            ["EXEC", "4", "5", "6"],
            ["OPS", "7", "8", "9"],
            ["SPEC", "-", "0", "+"],
            ["RESUME", "CLEAR", ".", "PRO"]]
numRows = len(buttons)
numColumns = len(buttons[0])
    
# Globals specific to the monitors.
imageFileMDU = "MDU.jpg"
leftMDU = 168
topMDU = 703
sizeMDU = 33
xSpacingMDU = 94.8
dimMDU = (0, 0)
scaleMDU = 1.0
leftsMDU = []
rightsMDU = []
bottomMDU = topMDU + sizeMDU
transparentMDU = ""
monitorDatabus = ""
windowCountMDU = 1
imgsMDU = []
monitorNames = []
buttonsMDU = ["A", "B", "C", "D", "E", "F"]
numColumnsMDU = len(buttonsMDU) 
topViewport = 55
leftViewport = 106 
bottomViewport = 675
rightViewport = 739
xSpacingText = 12
ySpacingText = 23
yAdjustment = round(ySpacingText / 4)
topTextMargin = 10 - yAdjustment # From edge of viewport to top of text.
leftTextMargin = 10 # From edge of viewport ot left of text.
numTextRows = 26
numTextColumns = 51
textScale = 0.5
textBackgroundOffset = yAdjustment
textBackgroundColors = []

# Called on every mouse event in the crew interface GUI.
# I.e., basically every time a button is pressed. 
whichButton = "" 
whichRow = -1
whichColumn = -1  
whichButtonMDU = ""
whichColumnMDU = -1   
def clickEvent(event, x, y, flags, interfaceNumber):
    global whichButton, whichRow, whichColumn, keyboardDatabus
    global whichButtonMDU, whichColumnMDU
    
    if interfaceNumber < 100:
        keyboardNumber = interfaceNumber
        if event == cv2.EVENT_LBUTTONDOWN:
            # Keyboards?
            found = False
            for column in range(numColumns - 1, -1, -1):
                if x >= lefts[column]:
                     if x > rights[column]:
                        return
                     found = True
                     break
            if not found:
                return
            found = False
            for row in range(numRows - 1, -1, -1):
                if y >= tops[row]:
                    if y > bottoms[row]:
                        return
                    found = True
                    break
            if found:
                overlay = transparent.copy()
                output = imgs[keyboardNumber].copy()
                cv2.rectangle(overlay, (lefts[column], tops[row]), (rights[column], 
                                        bottoms[row]), (255, 255, 255), -1)
                cv2.addWeighted(overlay, 0.25, output, 1.0, 0, output)
                cv2.imshow(keyboardNames[keyboardNumber], output)
                whichRow = row
                whichColumn = column
                whichButton = buttons[row][column]
                #print(whichButton, "pressed")
                keyboardDatabus.put("%d\tpressed\t%s" % (keyboardNumber + 1, whichButton))
        
        elif event == cv2.EVENT_LBUTTONUP:
            if whichButton != "":
                cv2.imshow(keyboardNames[keyboardNumber],imgs[keyboardNumber])
                #print(whichButton, "released")
                keyboardDatabus.put("%d\treleased\t%s" % (keyboardNumber + 1, whichButton))
                whichRow = -1
                whichColumn = -1
                whichButton = ""
    
    else:
        monitorNumber = interfaceNumber - 100
        if event == cv2.EVENT_LBUTTONDOWN:
            # Monitors?
            found = False
            for column in range(numColumnsMDU - 1, -1, -1):
                if x >= leftsMDU[column]:
                     if x > rightsMDU[column]:
                        return
                     found = True
                     break
            if not found:
                return
            found = False
            if y >= topMDU:
                if y > bottomMDU:
                    return
                found = True
            if found:
                overlay = transparentMDU.copy()
                output = imgsMDU[monitorNumber].copy()
                cv2.rectangle(overlay, (leftsMDU[column], topMDU), (rightsMDU[column], 
                                        bottomMDU), (255, 255, 255), -1)
                cv2.addWeighted(overlay, 0.25, output, 1.0, 0, output)
                cv2.imshow(monitorNames[monitorNumber], output)
                whichColumnMDU = column
                whichButtonMDU = buttonsMDU[column]
                keyboardDatabus.put("%d\tpressed\t%s" % (interfaceNumber + 1, whichButtonMDU))

        elif event == cv2.EVENT_LBUTTONUP:
            if whichButtonMDU != "":
                cv2.imshow(monitorNames[monitorNumber],imgsMDU[monitorNumber])
                keyboardDatabus.put("%d\treleased\t%s" % (interfaceNumber + 1, whichButtonMDU))
                whichColumnMDU = -1
                whichButtonMDU = ""
        
def initializeKeyboards(databus, names = ["Space Shuttle Keyboard"], 
                newscale=scale, file=imageFile):
    global  imageFile, left, top, size, ySpacing, xSpacing, \
            numColumns, numRows, buttons, lefts, rights, tops, bottoms, \
            windowCount, keyboardNames, scale, keyboardDatabus
    keyboardDatabus = databus
    windowCount = len(names)
    keyboardNames = names
    imageFile = file
    scale = newscale
    if scale != 1.0:
        left *= scale
        top *= scale
        size *= scale
        ySpacing *= scale
        xSpacing *= scale
    lefts = []
    rights = []
    tops = []
    bottoms = []
    for i in range(numColumns):
        lefts.append(round(left + i * xSpacing))
        rights.append(round(lefts[-1] + size))
    for i in range(numRows):
        tops.append(round(top + i * ySpacing))
        bottoms.append(round(tops[-1] + size))

def initializeMonitors(databus, names=["Space Shuttle Display"],
                newscale=scaleMDU, textHeight=23, file=imageFileMDU):
    global  imageFileMDU, leftMDU, topMDU, sizeMDU, xSpacingMDU, \
            numColumnsMDU, buttonsMDU, leftsMDU, rightsMDU, bottomMDU, \
            windowCountMDU, monitorNames, scaleMDU, monitorDatabus, \
            topViewport, leftViewport, bottomViewport, rightViewport, \
            topTextMargin, leftTextMargin, xSpacingText, ySpacingText, \
            textScale, textBackgroundOffset, yAdjustment
    monitorDatabus = databus
    windowCountMDU = len(names)
    monitorNames = names
    imageFileMDU = file
    scaleMDU = newscale
    ySpacingText = textHeight
    if scaleMDU != 1.0:
        leftMDU *= scaleMDU
        topMDU *= scaleMDU
        sizeMDU *= scaleMDU
        xSpacingMDU *= scaleMDU
        topViewport *= scaleMDU
        leftViewport *= scaleMDU
        bottomViewport *= scaleMDU
        rightViewport *= scaleMDU
        topTextMargin *= scaleMDU
        leftTextMargin *= scaleMDU
        xSpacingText *= scaleMDU
        ySpacingText *= scaleMDU
        textScale *= scaleMDU
        textBackgroundOffset *= scaleMDU
        yAdjustment = round(ySpacingText / 4)
    leftsMDU = []
    rightsMDU = []
    for i in range(numColumnsMDU):
        leftsMDU.append(round(leftMDU + i * xSpacingMDU))
        rightsMDU.append(round(leftsMDU[-1] + sizeMDU))
    bottomMDU = round(topMDU + sizeMDU)
    topMDU = round(topMDU)
    for i in range(len(names)):
        textBackgroundColors.append((0, 0, 0)) # BGR

def runCrewInterface():  
    global transparent, imgs, keyboardDatabus, scale 
    global transparentMDU, imgsMDU, monitorDatabus, scaleMDU 
    global textBackgroundColor
    img = cv2.imread(imageFile, 1)
    dim = (img.shape[1], img.shape[0])
    if scale != 1.0:
        dim = (round(dim[0]*scale), round(dim[1]*scale))
        img = cv2.resize(img, dim, cv2.INTER_CUBIC)
    transparent = np.zeros((dim[1], dim[0], 3), dtype = np.uint8)
    imgs = []
    for i in range(windowCount):
        imgs.append(img.copy())
        # The following step is to pre-create the window without the annoying 
        # status bar at the bottom, which would otherwise continually show the
        # mouse coordinates and the RGB color.
        cv2.namedWindow(keyboardNames[i], flags = cv2.WINDOW_GUI_NORMAL + cv2.WINDOW_AUTOSIZE)
        cv2.imshow(keyboardNames[i], imgs[i])
        cv2.setMouseCallback(keyboardNames[i], clickEvent, i)
        
    imgMDU = cv2.imread(imageFileMDU, 1)
    dimMDU = (imgMDU.shape[1], imgMDU.shape[0])
    if scaleMDU != 1.0:
        dimMDU = (round(dimMDU[0]*scaleMDU), round(dimMDU[1]*scaleMDU))
        imgMDU = cv2.resize(imgMDU, dimMDU, cv2.INTER_CUBIC)
    transparentMDU = np.zeros((dimMDU[1], dimMDU[0], 3), dtype = np.uint8)
    imgsMDU = []
    for i in range(windowCountMDU):
        imgsMDU.append(imgMDU.copy())
        # The following step is to pre-create the window without the annoying 
        # status bar at the bottom, which would otherwise continually show the
        # mouse coordinates and the RGB color.
        cv2.namedWindow(monitorNames[i], flags = cv2.WINDOW_GUI_NORMAL + cv2.WINDOW_AUTOSIZE)
        cv2.imshow(monitorNames[i], imgsMDU[i])
        cv2.setMouseCallback(monitorNames[i], clickEvent, 100 + i)
        
    while True:
        # Look for button presses on the keyboards or monitors.  If buttons
        # are pressed, then the mouse event is triggered, so we don't actually
        # have to handle those button presses right here.
        cv2.waitKey(100)
        # Look for incoming commands on the databus, and respond with changes to
        # what's displayed on the monitors.
        try:
            while True:
                item = monitorDatabus.get(block=False)
                fields = item.split('\t')
                if len(fields) == 3 and fields[1] == "background" and fields[2][:1] == "#":
                    try:
                        monitorNumber = int(fields[0]) - 101
                        color = int(fields[2][1:], 16)
                        R = 0xFF & (color >> 16)
                        G = 0xFF & (color >> 8)
                        B = 0xFF & color
                        textBackgroundColors[monitorNumber] = (B, G, R)
                    except:
                        pass
                    continue
                if len(fields) == 6 and fields[1] in ['text', 'flash']:
                    try:
                        monitorNumber = int(fields[0]) - 101
                        flash = fields[1] == 'flash'
                        row = int(fields[2])
                        column = int(fields[3])
                        color = fields[4]
                        text = fields[5]
                        if text[:1] == "'" and text[-1:] == "'":
                            text = text[1:-1]
                    except:
                        print("Corrupted command from GPC: ", item)
                        continue
                    if row < 1 or row > numTextRows:
                        print("Row out of range: ", item)
                        continue
                    if column < 1 or column > numTextColumns:
                        print("Column out of range: ", item)
                    if color[:1] != "#":
                        print("Illegal color string: ", item)
                        continue
                    try:
                        color = int(color[1:], 16)
                        R = 0xFF & (color >> 16)
                        G = 0xFF & (color >> 8)
                        B = 0xFF & color
                    except:
                        print("Illegal color string: ", item)
                        continue
                    # So if we've gotten to here, we have a perfectly legal
                    # command for drawing text on the monitor.
                    #print("Legal command: ", monitorNumber, flash, row, column, color, text)
                    monitor = imgsMDU[monitorNumber]
                    for i in range(len(text)):
                        char = text[i]
                        x = round(leftViewport + leftTextMargin + xSpacingText * (column - 1 + i))
                        y = round(topViewport + topTextMargin + ySpacingText * row)
                        yt = round(y - ySpacingText + textBackgroundOffset)
                        yb = round(y + textBackgroundOffset)
                        try:
                            cv2.rectangle(monitor, (x, yt), (x+xSpacingText, yb), 
                                        textBackgroundColors[monitorNumber], -1)
                            cv2.putText(monitor, char, (x, y), 
                                        cv2.FONT_HERSHEY_SIMPLEX, textScale,
                                        (B, G, R), 1)
                        except Exception as e:
                            print("Oops", e)
                    cv2.imshow(monitorNames[monitorNumber], imgsMDU[monitorNumber])
                    cv2.waitkey(1)
                    continue
                else:
                    print("Unrecognized command from GPC: ", item)
                    continue
        except:
            pass
        # Check if any of our keyboard/monitor windows were closed.  If so
        # initiate a shutdown.
        for i in range(windowCount):
            if cv2.getWindowProperty(keyboardNames[i], cv2.WND_PROP_VISIBLE) < 1:
                keyboardDatabus.put("QUIT")
                return
        for i in range(windowCountMDU):
            if cv2.getWindowProperty(monitorNames[i], cv2.WND_PROP_VISIBLE) < 1:
                keyboardDatabus.put("QUIT")
                return

