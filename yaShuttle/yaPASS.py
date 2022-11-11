#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Copyright:      None - the author (Ron Burkey) declares this software to
                be in the Public Domain, with no rights reserved.
Filename:       yaPASS.py
Purpose:        Simulates shuttle GPC running PASS (via p-code
                p-HAL-S) and simulated CRT+keyboard.  
History:        2022-11-04 RSB  Created.          

The crew-interface functionality of (modules shuttleKeyboard and shuttleCRT)
depend on openCV2.  On Linux Mint 21, I found that I had to do the following
to get openCV2 to work:
    pip uninstall opencv-python-headless
    pip install opencv-python
"""

import sys
import queue
import threading
import shuttleCrewInterface as crewInterface

numKeyboards = 1
scale = 0.66667
windowName = "Space Shuttle Keyboard"
numMonitors = 1
scaleMDU = 1.0
textHeight = 23
windowNameMDU = "Space Shuttle Monitor"
test = False
for param in sys.argv[1:]:
    if param[:12] == "--keyboards=":
        numKeyboards = int(param[12:])
    elif param[:8] == "--scale=":
        scale = float(param[8:])
    elif param[:7] == "--name=":
        windowName = param[7:]
    elif param[:11] == "--monitors=":
        numMonitors = int(param[11:])
    elif param[:12] == "--scale-mdu=":
        scaleMDU = float(param[12:])
    elif param[:11] == "--name-mdu=":
        windoNameMDU = param[11:]
    elif param == "--test":
        test = True
    elif param[:14] == "--text-height=":
        textHeight = int(param[14:])
    elif param == "--help":
        print("""
        Phase 1 Emulator for Space Shuttle DPS.  Usage:
            
                            yaPASS.py [OPTIONS]
        
        The available OPTIONS are:
        
        --keyboards=N       Number of keyboards to simulate.  Default is 1.
        --scale=F           Floating-point scale of the simulated keyboards.
                            Default is 0.66667.
        --name=S            Base name for the titles of the keyboards.  The
                            default is "Space Shuttle Keyboard".  The actual
                            keyboards have " 1", " 2", ..., suffixed to the
                            base name.
        --monitors=N, --scale-mdu=F, --name-mdu=S
                            Same, but for monitors rather than keyboards.
        --text-height=N     N is a value that determines the vertical spacing
                            of lines of text on the displays.  The usable
                            range is about 12 (most tightly spaced) through 
                            23 (most loosely spaced).  The font itself is not
                            affected.  Typical settings might be
                                23      For early hardware. (Default.)
                                18      For late hardware.
        --test              Run crew-interface test, without CPU emulation.
        """)
        sys.exit(0)
    else:
        print("Unknown parameter:", param)
        sys.exit(1)

# These are simulated databuses connecting the CPU to peripheral devices 
# running in other threads.
keyboardDatabus = queue.Queue()
monitorDatabus = queue.Queue()

# This is the simulated keyboard.  It runs in a thread in the background
# and delivers input via the keyboardDatabus.
keyboardNames = []
for i in range(numKeyboards):
    keyboardNames.append("%s %d" % (windowName, i+1))
monitorNames = []
for i in range(numMonitors):
    monitorNames.append("%s %d" % (windowNameMDU, i+1))
crewInterface.initializeKeyboards(keyboardDatabus, keyboardNames, scale)
crewInterface.initializeMonitors(monitorDatabus, monitorNames, scaleMDU, textHeight)
crewInterfaces = threading.Thread(target=crewInterface.runCrewInterface, args=())
crewInterfaces.start()

# A simple test loop that just continually queries the databus for new input.
if test:
    # First, fill the screen with text.
    testString = "123456789012345678901234567890123456789012345678901"
    for i in range(26):
        monitorDatabus.put("101\ttext\t%d\t1\t#FFA500\t'%s'" % (i + 1, testString))
        testString = testString[1:] + testString[:1]
    # Monitor inputs from the simulated buttons and echem them back
    # to the monitors forever.
    while True:
        try:
            item = keyboardDatabus.get(block=False)
        except:
            continue
        fields = item.split('\t')
        #print("Received: ", fields)
        monitorDatabus.put("101\ttext\t10\t10\t#FFA500\t'   %-30s   '" % item.replace("\t", " "))
        if item == "QUIT":
            break

