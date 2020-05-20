#!/usr/bin/python3
# Copyright:	None, placed in the PUBLIC DOMAIN by its author (Ron Burkey)
# Filename: 	yaPTC.py
# Purpose:	This is a very primitive PTC peripheral emulator for
#		use with the yaLVDC PTC CPU emulator, and is connected
#		to yaLVDC with "virtual wires" ... i.e., via network sockets.
#		It's not fully developed, and is just intended to help me
#		with developing and debugging yaLVDC.  But there's no reason
#		it couldn't be developed fully, if there were reason to do so.  
# Reference:	http://www.ibiblio.org/apollo/developer.html
# Mod history:	2020-05-07 RSB	Began adapting from piPeripheral.py, which is
#				a skeleton program for developing peripherals
#				for the AGC or AGS CPU emulators.
#		2020-05-08 RSB	I've added a GUI, based on the standard
#				tkinter module in Python.  I've used the PAGE
#				(http://page.sourceforge.net/html/index.html)
#				tool to build it, and those are the files
#				ProcessorDisplayPanel.py and 
#				ProcessorDisplayPanel_support.py, which are
#				simply imported as a module called
#				"ProcessorDisplayPanel" at the top of this
#				file.  The sources PAGE uses to generate 
#				this code are in the guiDesign folder.
#		2020-05-10 RSB	Unfortunately, there's no way this can keep up
#				with yaLVDC in terms of speed.  It continues
#				to receive data from yaLVDC *long* after the
#				PTC program has been paused.  It may be 
#				possible to use it if the clock-rate in 
#				yaLVDC is cut way down, and I'll experiment
#				with that, because this program is nice enough
#				now that I'm not keen to reimplement it in 
#				another language and gui toolkit.
#		2020-05-11 RSB	Removed all of the "interrupt latch" 
#				processing (most of the input CIO's) and 
#				moved it all back locally to yaLVDC, because
#				the PAST software expects to read back changes
#				to the interrupt latch within one instruction
#				cycle.  I expect this will help with the
#				speed problem I complained about above as well.
#
# The parts which need to be modified from the skeleton form of the program 
# to make it peripheral-specific are the outputFromCPU() and inputsForCPU() 
# functions.
#
# To run the program in its present form, assuming you had a directory setup in 
# which all of the appropriate files could be found housed on the same computer,
# you can simply run yaLVDC and yaPTC.py from different consoles on that same 
# computer. 

from ProcessorDisplayPanel import *

ioTypes = ["PIO", "CIO", "PRS", "INT" ]
# BA8421 character set in its native encoding.  All of the unprintable
# characters are replaced by '?', which isn't a legal character anyway.
# Used only for --ptc.
BA8421 = [
	' ', '1', '2', '3', '4', '5', '6', '7',
	'8', '9', '0', '#', '@', '?', '?', '?',
	'?', '/', 'S', 'T', 'U', 'V', 'W', 'X',
	'Y', 'Z', '‡', ',', '(', '?', '?', '?',
	'-', 'J', 'K', 'L', 'M', 'N', 'O', 'P',
	'Q', 'R', '?', '$', '*', '?', '?', '?',
	'+', 'A', 'B', 'C', 'D', 'E', 'F', 'G',
	'H', 'I', '?', '.', ')', '?', '?', '?'
]
refreshRate = 1 # Milliseconds
resizable = 0

# Parse command-line arguments.
import argparse
cli = argparse.ArgumentParser()
cli.add_argument("--host", help="Host address of yaAGC/yaAGS, defaulting to localhost.")
cli.add_argument("--port", help="Port for yaLVDC, defaulting to 19653.", type=int)
cli.add_argument("--id", help="Unique ID of this peripheral (1-7), default=1.", type=int)
cli.add_argument("--resize", help="If 1 (default 0), make the window resizable.", type=int)
args = cli.parse_args()

# Characteristics of the host and port being used for yaLVDC communications.  
if args.host:
	TCP_IP = args.host
else:
	TCP_IP = 'localhost'
if args.port:
	TCP_PORT = args.port
else:
	TCP_PORT = 19653

# Characteristics of this client being used for communicating with yaLVDC.
if args.id:
	ID = args.id
else:
	ID = 1

if args.resize:
	resize = args.resize
	if resize != 0:
		resize = 1
else:
	resize = 0

###################################################################################
# Hardware abstraction / User-defined functions.  Also, any other platform-specific
# initialization.  This is the section to customize for specific applications.

# Callbacks for the GUI (tkinter) event loop.

def eventIndicatorButtonRelease(event):
	indicatorOff(event.widget)
	
resetMachine = False
def eventResetMachine(event):
	global resetMachine
	resetMachine = True
	indicatorOn(event.widget)

halt = False
def eventHalt(event):
	global halt
	halt = True
	indicatorOn(event.widget)

ProgRegA = -1
def cPRA():
	global ProgRegA
	n = 0
	if ProcessorDisplayPanel_support.bPRAS.get():
		n |= 0o200000000
	if ProcessorDisplayPanel_support.bPRA1.get():
		n |= 0o100000000
	if ProcessorDisplayPanel_support.bPRA2.get():
		n |= 0o040000000
	if ProcessorDisplayPanel_support.bPRA3.get():
		n |= 0o020000000
	if ProcessorDisplayPanel_support.bPRA4.get():
		n |= 0o010000000
	if ProcessorDisplayPanel_support.bPRA5.get():
		n |= 0o004000000
	if ProcessorDisplayPanel_support.bPRA6.get():
		n |= 0o002000000
	if ProcessorDisplayPanel_support.bPRA7.get():
		n |= 0o001000000
	if ProcessorDisplayPanel_support.bPRA8.get():
		n |= 0o000400000
	if ProcessorDisplayPanel_support.bPRA9.get():
		n |= 0o000200000
	if ProcessorDisplayPanel_support.bPRA10.get():
		n |= 0o000100000
	if ProcessorDisplayPanel_support.bPRA11.get():
		n |= 0o000040000
	if ProcessorDisplayPanel_support.bPRA12.get():
		n |= 0o000020000
	if ProcessorDisplayPanel_support.bPRA13.get():
		n |= 0o000010000
	if ProcessorDisplayPanel_support.bPRA14.get():
		n |= 0o000004000
	if ProcessorDisplayPanel_support.bPRA15.get():
		n |= 0o000002000
	if ProcessorDisplayPanel_support.bPRA16.get():
		n |= 0o000001000
	if ProcessorDisplayPanel_support.bPRA17.get():
		n |= 0o000000400
	if ProcessorDisplayPanel_support.bPRA18.get():
		n |= 0o000000200
	if ProcessorDisplayPanel_support.bPRA19.get():
		n |= 0o000000100
	if ProcessorDisplayPanel_support.bPRA20.get():
		n |= 0o000000040
	if ProcessorDisplayPanel_support.bPRA21.get():
		n |= 0o000000020
	if ProcessorDisplayPanel_support.bPRA22.get():
		n |= 0o000000010
	if ProcessorDisplayPanel_support.bPRA23.get():
		n |= 0o000000004
	if ProcessorDisplayPanel_support.bPRA24.get():
		n |= 0o000000002
	if ProcessorDisplayPanel_support.bPRA25.get():
		n |= 0o000000001
	ProgRegA = n
ProcessorDisplayPanel_support.cPRA = cPRA
	
ProgRegB = -1
def cPRB():
	global ProgRegB
	n = 0
	if ProcessorDisplayPanel_support.bPRBS.get():
		n |= 0o200000000
	if ProcessorDisplayPanel_support.bPRB1.get():
		n |= 0o100000000
	if ProcessorDisplayPanel_support.bPRB2.get():
		n |= 0o040000000
	if ProcessorDisplayPanel_support.bPRB3.get():
		n |= 0o020000000
	if ProcessorDisplayPanel_support.bPRB4.get():
		n |= 0o010000000
	if ProcessorDisplayPanel_support.bPRB5.get():
		n |= 0o004000000
	if ProcessorDisplayPanel_support.bPRB6.get():
		n |= 0o002000000
	if ProcessorDisplayPanel_support.bPRB7.get():
		n |= 0o001000000
	if ProcessorDisplayPanel_support.bPRB8.get():
		n |= 0o000400000
	if ProcessorDisplayPanel_support.bPRB9.get():
		n |= 0o000200000
	if ProcessorDisplayPanel_support.bPRB10.get():
		n |= 0o000100000
	if ProcessorDisplayPanel_support.bPRB11.get():
		n |= 0o000040000
	if ProcessorDisplayPanel_support.bPRB12.get():
		n |= 0o000020000
	if ProcessorDisplayPanel_support.bPRB13.get():
		n |= 0o000010000
	if ProcessorDisplayPanel_support.bPRB14.get():
		n |= 0o000004000
	if ProcessorDisplayPanel_support.bPRB15.get():
		n |= 0o000002000
	if ProcessorDisplayPanel_support.bPRB16.get():
		n |= 0o000001000
	if ProcessorDisplayPanel_support.bPRB17.get():
		n |= 0o000000400
	if ProcessorDisplayPanel_support.bPRB18.get():
		n |= 0o000000200
	if ProcessorDisplayPanel_support.bPRB19.get():
		n |= 0o000000100
	if ProcessorDisplayPanel_support.bPRB20.get():
		n |= 0o000000040
	if ProcessorDisplayPanel_support.bPRB21.get():
		n |= 0o000000020
	if ProcessorDisplayPanel_support.bPRB22.get():
		n |= 0o000000010
	if ProcessorDisplayPanel_support.bPRB23.get():
		n |= 0o000000004
	if ProcessorDisplayPanel_support.bPRB24.get():
		n |= 0o000000002
	if ProcessorDisplayPanel_support.bPRB25.get():
		n |= 0o000000001
	ProgRegB = n
ProcessorDisplayPanel_support.cPRB = cPRB

# This function is automatically called periodically by the event loop to check for 
# conditions that will result in sending messages to yaLVDC that are interpreted
# as changes to bits on its input channels.  The return
# value is supposed to be a list of 4-tuples of the form
#	[ (ioType0,channel0,value0,mask0), (ioType1,channel1,value1,mask1), ...]
# and may be an empty list.  The "values" are written to the LVDC/PTC's input "channels",
# while the "masks" tell which bits of the "values" are valid.  The ioTypeN's are
# indices into ioTypes[] (see top of file) to tell which particular class of i/o
# channels is affected.  Only the PIO, CIO, and INT classes are possible for inputs
# to the CPU.
changedIA = -1
changedDA = -1
changedD = -1
needStatusFromCPU = False
def inputsForCPU():
	#global delayCount, ioTypeCount, channelCount
	global ProgRegA, ProgRegB, resetMachine, halt, needStatusFromCPU
	global changedIA, changedDA, changedD
	returnValue = []
	
	if ProgRegA != -1:
		n = ProgRegA
		ProgRegA = -1
		returnValue.append((1, 0o214, n, 0o377777777))

	if ProgRegB != -1:
		n = ProgRegB
		ProgRegB = -1
		returnValue.append((1, 0o220, n, 0o377777777))
	
	if resetMachine:
		resetMachine = False
		returnValue.append((4, 0o604, 0, 0o377777777))
	
	if halt:
		halt = False
		returnValue.append((4, 0o000, 0, 0o377777777))
	
	if changedIA != -1:
		returnValue.append((4, 0o003, changedIA, 0o377777777))
		changedIA = -1

	if changedDA != -1:
		returnValue.append((4, 0o002, changedDA, 0o377777777))
		changedDA = -1

	if changedD != -1:
		returnValue.append((4, 0o004, changedD, 0o377777777))
		changedD = -1

	if needStatusFromCPU:
		needStatusFromCPU = False
		returnValue.append((4, 0o605, 0, 0o377777777))
	
	return returnValue

# GUI indicator functions.  These are implemented as canvas widgets,
# sometimes with callback functions bound to them when they're supposed
# to act like pushbuttons.  Each canvas just has two visible elements:
# a filling white rectangle (ID=1) that can be either opaque or invisible,
# and a textual caption (ID=5).
# Adjust the size of an indicator lamp after a startup, window resize, etc.
def indicatorReconfigure(event):
	width = event.width
	height = event.height
	event.widget.coords(1, 0, 0, width, height)
	event.widget.coords(2, width/2.0, height/2.0)
# Set up an indicator lamp, at startup, before use.  As defined by the PAGE
# tool, and our import of the modules it creates, an indicator lamp is simply
# an empty rectangular canvas.  We add two elements to the canvas:  a 
# rectangular block that fills it, and which we can use to adjust the color 
# by either revealing it or hiding it, and above that, the textual caption.
PANEL_PDP = 0	# PANEL_XXX is just a constant we use to ID specific panels.
PANEL_MLDD = 1
PANEL_CE = 2
CC_NONE = 0 # CC_XXX is a constant we use to tell if an indicator is "computer" or "command" or neither.
CC_COMPUTER = 1
CC_COMMAND = 2
indicators = { PANEL_PDP : {}, PANEL_MLDD : {}, PANEL_CE : {} }
computerIndicators = []
commandIndicators = []
def indicatorInitialize(canvas, text, panel, cc = CC_NONE):
	indicators[panel][canvas] = 0
	if cc == CC_COMPUTER:
		computerIndicators.append(canvas)
	elif cc == CC_COMMAND:
		commandIndicators.append(canvas)
	canvas.delete("all")
	canvas.create_rectangle(0, 0, 1, 1, fill="white", state = "hidden")
	canvas.create_text(1, 1, fill="white", text=text, font=("Sans", 6), justify=tk.CENTER)
	canvas.bind("<Configure>", indicatorReconfigure)
# indicatorOn() and indicatorOff() are used to either light up an indicator
# or to unlight it.  That involves changing the color of the rectangular
# fill and the text-color of the caption.  However, we have to intercept
# that process if a LAMP TEST is in progress for the particular panel 
# containing the indicator, because in that case we have to capture the
# intended change of state but not change the actual colors, since when 
# a lamp test is in progress the indicator stays lit regardless.  Similarly,
# when a lamp test ends, the lamp must resume either the state it had before
# the lamp test or else the desired state due to changes that have taken 
# place while the lamp test was in progress.  The indicators[] dictionary
# tracks those changes; it not only indicates which indicators are on which
# of the 3 panels, but also tracks their intended states during LAMP TESTS;
# it doesn't try to track their states whilst there is no LAMP TEST for the
# corresponding panel, because the actual visual appearance already does that.
inLampTests = []
def isIndicatorInLampTest(canvas):
	for panel in inLampTests:
		if canvas in indicators[panel]:
			return panel
	return False 
def indicatorOff(canvas):
	inTest = isIndicatorInLampTest(canvas)
	if inTest == False:
		canvas.itemconfig(1, state = "hidden")
		canvas.itemconfig(2, fill = "white")
	else:
		indicators[inTest][canvas] = "hidden"
def indicatorOn(canvas):
	inTest = isIndicatorInLampTest(canvas)
	if inTest == False:
		canvas.itemconfig(1, state = "normal")
		canvas.itemconfig(2, fill = "black")
	else:
		indicators[inTest][canvas] = "normal"
def indicatorSet(canvas, onOff):
	if onOff:
		indicatorOn(canvas)
	else:
		indicatorOff(canvas)
def indicatorToggle(canvas):
	inTest = isIndicatorInLampTest(canvas)
	if inTest == False:
		indicatorSet(canvas, canvas.itemcget(1, "state") == "hidden")
	else:
		indicatorSet(canvas, indicators[inTest][canvas] == "hidden")
def startPanelLampTest(panel):
	for indicator in indicators[panel]:
		indicators[panel][indicator] = indicator.itemcget(1, "state")
		indicatorOn(indicator)
	if panel not in inLampTests:
		inLampTests.append(panel)
def endPanelLampTest(panel):
	if panel in inLampTests:
		inLampTests.remove(panel)
	for indicator in indicators[panel]:
		if indicators[panel][indicator] == "normal":
			indicatorOn(indicator)
		else:
			indicatorOff(indicator)

# Turns the switch settings for the commanded DATA area
# of MLDD into an integer.		
def getDataCommand():
	value = 0;			
	if top.mlddCommandSIGN.itemcget(1, "state") == "normal":
		value |= 0o200000000
	if top.mlddCommand1.itemcget(1, "state") == "normal":
		value |= 0o100000000
	if top.mlddCommand2.itemcget(1, "state") == "normal":
		value |= 0o040000000
	if top.mlddCommand3.itemcget(1, "state") == "normal":
		value |= 0o020000000
	if top.mlddCommand4.itemcget(1, "state") == "normal":
		value |= 0o010000000
	if top.mlddCommand5.itemcget(1, "state") == "normal":
		value |= 0o004000000
	if top.mlddCommand6.itemcget(1, "state") == "normal":
		value |= 0o002000000
	if top.mlddCommand7.itemcget(1, "state") == "normal":
		value |= 0o001000000
	if top.mlddCommand8.itemcget(1, "state") == "normal":
		value |= 0o000400000
	if top.mlddCommand9.itemcget(1, "state") == "normal":
		value |= 0o000200000
	if top.mlddCommand10.itemcget(1, "state") == "normal":
		value |= 0o000100000
	if top.mlddCommand11.itemcget(1, "state") == "normal":
		value |= 0o000040000
	if top.mlddCommand12.itemcget(1, "state") == "normal":
		value |= 0o000020000
	if top.mlddCommand13.itemcget(1, "state") == "normal":
		value |= 0o000010000
	if top.mlddCommand14.itemcget(1, "state") == "normal":
		value |= 0o000004000
	if top.mlddCommand15.itemcget(1, "state") == "normal":
		value |= 0o000002000
	if top.mlddCommand16.itemcget(1, "state") == "normal":
		value |= 0o000001000
	if top.mlddCommand17.itemcget(1, "state") == "normal":
		value |= 0o000000400
	if top.mlddCommand18.itemcget(1, "state") == "normal":
		value |= 0o000000200
	if top.mlddCommand19.itemcget(1, "state") == "normal":
		value |= 0o000000100
	if top.mlddCommand20.itemcget(1, "state") == "normal":
		value |= 0o000000040
	if top.mlddCommand21.itemcget(1, "state") == "normal":
		value |= 0o000000020
	if top.mlddCommand22.itemcget(1, "state") == "normal":
		value |= 0o000000010
	if top.mlddCommand23.itemcget(1, "state") == "normal":
		value |= 0o000000004
	if top.mlddCommand24.itemcget(1, "state") == "normal":
		value |= 0o000000002
	if top.mlddCommand25.itemcget(1, "state") == "normal":
		value |= 0o000000001
	return value
			
def indicatorDataCommandParity():
	value = getDataCommand()
	indicatorSet(top.mlddCommandSYL1, not parity13(value >> 13))
	indicatorSet(top.mlddCommandSYL0, not parity13(value))

# Turns the switch settings for the commanded DATA ADDRESS
# of MLDD into an integer.		
def getDataAddressCommand():
	value = 0;			
	if top.daCommandDS4.itemcget(1, "state") == "normal":
		value |= 0o040000000
	if top.daCommandDS3.itemcget(1, "state") == "normal":
		value |= 0o020000000
	if top.daCommandDS2.itemcget(1, "state") == "normal":
		value |= 0o010000000
	if top.daCommandDS1.itemcget(1, "state") == "normal":
		value |= 0o004000000

	if top.daCommandM1.itemcget(1, "state") == "normal":
		value |= 0o000400000

	if top.daCommandOA8.itemcget(1, "state") == "normal":
		value |= 0o000010000
	if top.daCommandOA7.itemcget(1, "state") == "normal":
		value |= 0o000004000
	if top.daCommandOA6.itemcget(1, "state") == "normal":
		value |= 0o000002000
	if top.daCommandOA5.itemcget(1, "state") == "normal":
		value |= 0o000001000
	if top.daCommandOA4.itemcget(1, "state") == "normal":
		value |= 0o000000400
	if top.daCommandOA3.itemcget(1, "state") == "normal":
		value |= 0o000000200
	if top.daCommandOA2.itemcget(1, "state") == "normal":
		value |= 0o000000100
	if top.daCommandOA1.itemcget(1, "state") == "normal":
		value |= 0o000000040
		
	if top.daCommandOA9.itemcget(1, "state") == "normal":
		value |= 0o000000020
		
	if top.daCommandOP4.itemcget(1, "state") == "normal":
		value |= 0o000000010
	if top.daCommandOP3.itemcget(1, "state") == "normal":
		value |= 0o000000004
	if top.daCommandOP2.itemcget(1, "state") == "normal":
		value |= 0o000000002
	if top.daCommandOP1.itemcget(1, "state") == "normal":
		value |= 0o000000001
	return value
			
# Turns the switch settings for the commanded INSTRUCTION AREA
# of MLDD into an integer.	
def getInstructionAddressCommand():
	value = 0;			
	if top.iaCommandM1.itemcget(1, "state") == "normal":
		value |= 0o200000000
		
	if top.iaCommandA8.itemcget(1, "state") == "normal":
		value |= 0o000040000
	if top.iaCommandA7.itemcget(1, "state") == "normal":
		value |= 0o000020000
	if top.iaCommandA6.itemcget(1, "state") == "normal":
		value |= 0o000010000
	if top.iaCommandA5.itemcget(1, "state") == "normal":
		value |= 0o000004000
	if top.iaCommandA4.itemcget(1, "state") == "normal":
		value |= 0o000002000
	if top.iaCommandA3.itemcget(1, "state") == "normal":
		value |= 0o000001000
	if top.iaCommandA2.itemcget(1, "state") == "normal":
		value |= 0o000000400
	if top.iaCommandA1.itemcget(1, "state") == "normal":
		value |= 0o000000200
		
	if top.iaCommandSYL1.itemcget(1, "state") == "normal":
		value |= 0o000000100
		
	if top.iaCommandIS4.itemcget(1, "state") == "normal":
		value |= 0o000000040
	if top.iaCommandIS3.itemcget(1, "state") == "normal":
		value |= 0o000000020
	if top.iaCommandIS2.itemcget(1, "state") == "normal":
		value |= 0o000000010
	if top.iaCommandIS1.itemcget(1, "state") == "normal":
		value |= 0o000000004
	return value
			
def eventToggleIndicator(event):
	indicatorToggle(event.widget)

def updateDaCommand(event):
	global changedDA
	indicatorToggle(event.widget)
	changedDA = getDataAddressCommand()
def eventToggleDaCommandM0(event):
	indicatorToggle(top.daCommandM1)
	updateDaCommand(event)
def eventToggleDaCommandM1(event):
	indicatorToggle(top.daCommandM0)
	updateDaCommand(event)

def updateIaCommand(event):
	global changedIA
	indicatorToggle(event.widget)
	changedIA = getInstructionAddressCommand()
def eventToggleIaCommandM0(event):
	indicatorToggle(top.iaCommandM1)
	updateIaCommand(event)
def eventToggleIaCommandM1(event):
	indicatorToggle(top.iaCommandM0)
	updateIaCommand(event)
def eventToggleIaCommandSYL0(event):
	indicatorToggle(top.iaCommandSYL1)
	updateIaCommand(event)
def eventToggleIaCommandSYL1(event):
	indicatorToggle(top.iaCommandSYL0)
	updateIaCommand(event)

def eventToggleDataIndicator(event):
	eventToggleIndicator(event)
	indicatorDataCommandParity()

def eventPdpLampTest(event):
	startPanelLampTest(PANEL_PDP)
def eventPdpLampTestRelease(event):
	endPanelLampTest(PANEL_PDP)

def eventMlddLampTest(event):
	startPanelLampTest(PANEL_MLDD)
def eventMlddLampTestRelease(event):
	endPanelLampTest(PANEL_MLDD)

def eventCeLampTest(event):
	startPanelLampTest(PANEL_CE)
def eventCeLampTestRelease(event):
	endPanelLampTest(PANEL_CE)

def eventTrmcErrorDevicesTest(event):
	indicatorOn(event.widget)
	indicatorOn(top.PARITY_SERIAL)
	indicatorOn(top.TRS)
	indicatorOn(top.A13)
	indicatorOn(top.SERIAL)
	indicatorOn(top.HOPC1)
	indicatorOn(top.SSMSC)
	indicatorOn(top.SSMBR)
	indicatorOn(top.OAC)
	indicatorOn(top.BR14)

def eventErrorReset(event):
	indicatorOn(event.widget)
	indicatorOff(top.PARITY_SERIAL)
	indicatorOff(top.TRS)
	indicatorOff(top.A13)
	indicatorOff(top.SERIAL)
	indicatorOff(top.HOPC1)
	indicatorOff(top.SSMSC)
	indicatorOff(top.SSMBR)
	indicatorOff(top.OAC)
	indicatorOff(top.BR14)

def getCommandedDataAddress():
	indicatorOn(event.widget)

def eventAddressCmptr(event):
	global changedD
	indicatorOn(event.widget)
	changedD = getDataCommand()

def eventComptrDisplayReset(event):
	global needStatusFromCPU
	indicatorOn(event.widget)
	for indicator in computerIndicators:
		indicatorOff(indicator)
	#needStatusFromCPU = True
	indicatorOn(top.iaComputerM0)
	indicatorOn(top.iaComputerSYL0)
	indicatorOn(top.daComputerM0)

def eventCommandDisplayReset(event):
	indicatorOn(event.widget)
	for indicator in commandIndicators:
		indicatorOff(indicator)
	indicatorDataCommandParity()
	indicatorOn(top.iaCommandM0)
	indicatorOn(top.iaCommandSYL0)
	indicatorOn(top.daCommandM0)

def eventREPEAT(event):
	indicatorOn(event.widget)
	indicatorOff(top.mlREPEAT_INVERSE)

def eventREPEAT_INVERSE(event):
	indicatorOn(event.widget)
	indicatorOff(top.mlREPEAT)

def eventML(event):
	indicatorOn(event.widget)
	indicatorOff(top.trmcDD)

def eventDD(event):
	indicatorOn(event.widget)
	indicatorOff(top.trmcML)

# This computes the actual parity of the bits of the syllable ...
# not the parity bit that must be added to make an overall odd
# parity.
def parity13(value):
	value &= 0o17777  # Starts with 13 bits.
	value = 0o177 & (value ^ (value >> 7)) # Now has 7 bits.
	value = 0o17 & (value ^ (value >> 4)) # Now has 4 bits.
	value = 3 & (value ^ (value >> 2)) # Now has 2 bits.
	return 1 & (value ^ (value >> 1)) # Just 1 bit left!

# This function is called by the event loop only when yaLVDC has written
# to an output channel.  The function should do whatever it is that needs to be done
# with this output data, which is not processed additionally in any way by the 
# generic portion of the program.  The ioType argument is an index into the
# ioTypes[] array (see the top of this file), giving the class of i/o ports
# to which the channel belongs.  Only the PIO, CIO, and PRS channels are applicable
# for output from the CPU to peripherals.
#
# The function _could_ also be called directly, by panel events, though I'm not
# aware of any reason at the moment why that would be needed.  But it does work.
def outputFromCPU(ioType, channel, value):
	print("*", end="")
	
	if ioType == 0:
		# PIO
		print("\nChannel PIO-%03o = %09o" % (channel, value), end="  ")
		
	elif ioType == 1:
		# CIO
		if channel == 0o114:
			print("\nSingle step")
		elif channel == 0o120 or channel == 0o160:
			if channel == 0o120:
				destination = "Typewriter"
			else:
				destination = "Printer"
			string = ""
			shift = 20
			while shift >= 0:
				string += BA8421[(value >> shift) & 0o77]
				if channel == 0o120:
					shift = -1
				else:
					shift -= 6
			print("\n%s alphanumeric = %09o (%s)" % (destination, value, string), end="  ")
		elif channel == 0o124 or channel == 0o170:
			if channel == 0o124:
				destination = "Typewriter"
			else:
				destination = "Printer"
			string = ""
			shift = 22
			while shift >= 0:
				string += BA8421[(value >> shift) & 0o17]
				if channel == 0o124:
					shift = -1
				else:
					shift -= 4
			print("\n%s decimal = %09o (%s)" % (destination, value, string), end="  ")
		elif channel == 0o130 or channel == 0o164:
			if channel == 0o130:
				destination = "Typewriter"
			else:
				destination = "Printer"
			string = ""
			shift = 23
			while shift >= 0:
				character = BA8421[(value >> shift) & 0o07]
				if character == " ":
					character = "0"
				string += character
				if channel == 0o130:
					shift = -1
				else:
					shift -= 3
			print("\n%s octal = %09o (%s)" % (destination, value, string), end="  ")
		elif channel == 0o134:
			if value == 0o200000000:
				string = "space"
			elif value == 0o100000000:
				string = "black ribbon"
			elif value == 0o040000000:
				string = "red ribbon"
			elif value == 0o020000000:
				string = "index"
			elif value == 0o010000000:
				string = "return"
			elif value == 0o004000000:
				string = "tab"
			else:
				string = "illegal"
			print("\nTypewriter control = %09o (%s)" % (value, string), end="  ")
		elif channel == 0o140:
			print("\nX plot = %09o" % value, end="  ")
		elif channel == 0o144:
			print("\nY plot = %09o" % value, end="  ")
		elif channel == 0o150:
			print("\nZ plot = %09o" % value, end="  ")
		elif channel == 0o204:
			# Turn indicator lamps on or off.  I think this is actually
			# the full functionality of CIO-204
			if value & 0o1:
				indicatorOn(top.P1)
			else:
				indicatorOff(top.P1)
			if value & 0o2:
				indicatorOn(top.P2)
			else:
				indicatorOff(top.P2)
			if value & 0o4:
				indicatorOn(top.P4)
			else:
				indicatorOff(top.P4)
			if value & 0o10:
				indicatorOn(top.P10)
			else:
				indicatorOff(top.P10)
			if value & 0o20:
				indicatorOn(top.P20)
			else:
				indicatorOff(top.P20)
			if value & 0o40:
				indicatorOn(top.P40)
			else:
				indicatorOff(top.P40)
			return
		elif channel == 0o210:
			# All I'm doing here (CIO-210) is manipulating indicator lamps,
			# but the discretes additionally have some other functionality
			# in terms of latching signals or something which is
			# TBD.  ***FIXME***
			if value & 0o1:
				indicatorOn(top.D1)
			else:
				indicatorOff(top.D1)
			if value & 0o2:
				indicatorOn(top.D2)
			else:
				indicatorOff(top.D2)
			if value & 0o4:
				indicatorOn(top.D3)
			else:
				indicatorOff(top.D3)
			if value & 0o10:
				indicatorOn(top.D4)
			else:
				indicatorOff(top.D4)
			if value & 0o20:
				indicatorOn(top.D5)
			else:
				indicatorOff(top.D5)
			if value & 0o40:
				indicatorOn(top.D6)
			else:
				indicatorOff(top.D6)
			return
		elif channel == 0o240:
			indicatorOn(top.PROG_ERR)
		else:
			print("\nChannel CIO-%03o = %09o" % (channel, value), end="  ")
		
	elif ioType == 2:
		if value == 0o77:
			print("\nChannel PRS = %09o (group mark)" % value, end= "  ")
		else:
			shift = 18
			string = ""
			while shift >= 0:
				string += BA8421[(value >> shift) & 0o077]
				shift -= 6
			print("\nChannel PRS = %09o (%s)" % (value, string), end="  ")
	elif ioType == 5:
		if channel == 0o000:
			print("\nCPU is paused.")
		elif channel == 0o001:
			print("\nCPU is running.")
		elif channel == 0o002:
			# Data address.
			opcode = value & 0o17
			a9 = (value >> 4) & 1
			a81 = (value >> 5) & 0o377
			dm = (value >> 17) & 1
			ds = (value >> 20) & 0o17
			indicatorSet(top.daComputerM0, not dm)
			indicatorSet(top.daComputerM1, dm)
			indicatorSet(top.daComputerDS1, ds & 1)
			indicatorSet(top.daComputerDS2, ds & 2)
			indicatorSet(top.daComputerDS3, ds & 4)
			indicatorSet(top.daComputerDS4, ds & 8)
			indicatorSet(top.daComputerOP1, opcode & 1)
			indicatorSet(top.daComputerOP2, opcode & 2)
			indicatorSet(top.daComputerOP3, opcode & 4)
			indicatorSet(top.daComputerOP4, opcode & 8)
			indicatorSet(top.daComputerOA9, a9)
			indicatorSet(top.daComputerOA1, a81 & 1)
			indicatorSet(top.daComputerOA2, a81 & 2)
			indicatorSet(top.daComputerOA3, a81 & 4)
			indicatorSet(top.daComputerOA4, a81 & 8)
			indicatorSet(top.daComputerOA5, a81 & 16)
			indicatorSet(top.daComputerOA6, a81 & 32)
			indicatorSet(top.daComputerOA7, a81 & 64)
			indicatorSet(top.daComputerOA8, a81 & 128)
			indicatorSet(top.daPARITY_BIT, parity13(value))
		elif channel == 0o003:
			# Instruction address.
			isect = (value >> 2) & 0o17
			s = (value >> 6) & 1
			loc = (value >> 7) & 0o377
			dm = (value >> 17) & 1
			ds = (value >> 20) & 0o17
			im = (value >> 25) & 1
			indicatorSet(top.iaComputerM0, not im)
			indicatorSet(top.iaComputerM1, im)
			indicatorSet(top.iaComputerSYL0, not s)
			indicatorSet(top.iaComputerSYL1, s)
			indicatorSet(top.iaComputerIS1, isect & 1)
			indicatorSet(top.iaComputerIS2, isect & 2)
			indicatorSet(top.iaComputerIS3, isect & 4)
			indicatorSet(top.iaComputerIS4, isect & 8)
			indicatorSet(top.iaComputerA1, loc & 1)
			indicatorSet(top.iaComputerA2, loc & 2)
			indicatorSet(top.iaComputerA3, loc & 4)
			indicatorSet(top.iaComputerA4, loc & 8)
			indicatorSet(top.iaComputerA5, loc & 16)
			indicatorSet(top.iaComputerA6, loc & 32)
			indicatorSet(top.iaComputerA7, loc & 64)
			indicatorSet(top.iaComputerA8, loc & 128)
		elif channel == 0o004:
			parity0 = parity13(value)
			parity1 = parity13(value >> 13)
			indicatorSet(top.mlddComputerBR0, parity0)
			indicatorSet(top.mlddComputerBR1, parity1)
			indicatorSet(top.mlddPARITY_BIT, 1 ^ parity0 ^ parity1)
			indicatorSet(top.mlddComputer25, value & 0o1)
			indicatorSet(top.mlddComputer24, value & 0o2)
			indicatorSet(top.mlddComputer23, value & 0o4)
			indicatorSet(top.mlddComputer22, value & 0o10)
			indicatorSet(top.mlddComputer21, value & 0o20)
			indicatorSet(top.mlddComputer20, value & 0o40)
			indicatorSet(top.mlddComputer19, value & 0o100)
			indicatorSet(top.mlddComputer18, value & 0o200)
			indicatorSet(top.mlddComputer17, value & 0o400)
			indicatorSet(top.mlddComputer16, value & 0o1000)
			indicatorSet(top.mlddComputer15, value & 0o2000)
			indicatorSet(top.mlddComputer14, value & 0o4000)
			indicatorSet(top.mlddComputer13, value & 0o10000)
			indicatorSet(top.mlddComputer12, value & 0o20000)
			indicatorSet(top.mlddComputer11, value & 0o40000)
			indicatorSet(top.mlddComputer10, value & 0o100000)
			indicatorSet(top.mlddComputer9, value & 0o200000)
			indicatorSet(top.mlddComputer8, value & 0o400000)
			indicatorSet(top.mlddComputer7, value & 0o1000000)
			indicatorSet(top.mlddComputer6, value & 0o2000000)
			indicatorSet(top.mlddComputer5, value & 0o4000000)
			indicatorSet(top.mlddComputer4, value & 0o10000000)
			indicatorSet(top.mlddComputer3, value & 0o20000000)
			indicatorSet(top.mlddComputer2, value & 0o40000000)
			indicatorSet(top.mlddComputer1, value & 0o100000000)
			indicatorSet(top.mlddComputerSIGN, value & 0o200000000)
		elif channel == 0o600:
			pass
		elif channel == 0o601:
			pass
		else:
			print("\nCPU status %03o %09o" % (channel, value))
	else:
		print("\nUnimplemented type %d, channel %03o, value %09o" % (ioType, channel, value), end="  ")
	
	return

def pressedPROG_ERR(event):
	indicatorOn(top.PROG_ERR)

displaySelect = 0
modeControl = 0
addressCompare = 0
def changeDisplayMode(newDisplaySelect, newModeControl, newAddressCompare):
	global displaySelect, modeControl, addressCompare
	changed = False
	if displaySelect != newDisplaySelect:
		print("Display select changed from %d to %d" % (displaySelect, newDisplaySelect))
		displaySelect = newDisplaySelect
		changed = True
	if modeControl != newModeControl:
		print("Mode control changed from %d to %d" % (modeControl, newModeControl))
		modeControl = newModeControl
		changed = True
	if addressCompare != newAddressCompare:
		print("Address compare changed from %d to %d" % (addressCompare, newAddressCompare))
		addressCompare = newAddressCompare
		if addressCompare:
			indicatorOn(top.acINS)
			indicatorOff(top.acDATA)
		else:
			indicatorOn(top.acDATA)
			indicatorOff(top.acINS)
		changed = True
	if changed:
		pass
def eventDisplaySelect():
	changeDisplayMode(ProcessorDisplayPanel_support.displaySelect.get(), modeControl, addressCompare)
def eventModeControl():
	changeDisplayMode(displaySelect, ProcessorDisplayPanel_support.modeControl.get(), addressCompare)
def eventAddressCompareData(event):
	changeDisplayMode(displaySelect, modeControl, 0)
def eventAddressCompareIns(event):
	changeDisplayMode(displaySelect, modeControl, 1)
ProcessorDisplayPanel_support.eventDisplaySelect = eventDisplaySelect
ProcessorDisplayPanel_support.eventModeControl = eventModeControl

###################################################################################
# Generic initialization (TCP socket setup).  Has no target-specific code, and 
# shouldn't need to be modified unless there are bugs.

import time
import socket

s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.setblocking(0)

def connectToAGC():
	import sys
	count = 0
	sys.stderr.write("Connecting to LVDC/PTC emulator at %s:%d\n" % (TCP_IP, TCP_PORT))
	while True:
		try:
			s.connect((TCP_IP, TCP_PORT))
			sys.stderr.write("Connected.\n")
			break
		except socket.error as msg:
			sys.stderr.write(str(msg) + "\n")
			count += 1
			if count >= 10:
				sys.stderr.write("Too many retries ...\n")
				time.sleep(3)
				sys.exit(1)
			time.sleep(1)

connectToAGC()

###################################################################################
# Event loop.  Just check periodically for output from yaLVDC (in which case the
# user-defined callback function outputFromCPU is executed) or data in the 
# user-defined function inputsForCPU (in which case a message is sent to yaLVDC).
# But this section has no target-specific code, and shouldn't need to be modified
# unless there are bugs.

# Given a 4-tuple (ioType,channel,value,mask), creates packet data and sends it to yaLVDC.
def packetize(tuple):
	outputBuffer = bytearray(6)
	source = ID
	ioType = tuple[0]
	channel = tuple[1]
	value = tuple[2]
	mask = tuple[3]
	if mask != 0o377777777:
		outputBuffer[0] = 0x80 | 0x40 | ((ioType & 7) << 3) | (ID & 7)
		outputBuffer[1] = channel & 0x7F
		outputBuffer[2] = ((channel & 0x180) >> 2) | ((mask >> 21) & 0x1F)
		outputBuffer[3] = (mask >> 14) & 0x7F
		outputBuffer[4] = (mask >> 7) & 0x7F
		outputBuffer[5] = mask & 0x7F
		s.send(outputBuffer)
	outputBuffer[0] = 0x80 | ((ioType & 7) << 3) | (ID & 7)
	outputBuffer[1] = channel & 0x7F
	outputBuffer[2] = ((channel & 0x180) >> 2) | ((value >> 21) & 0x1F)
	outputBuffer[3] = (value >> 14) & 0x7F
	outputBuffer[4] = (value >> 7) & 0x7F
	outputBuffer[5] = value & 0x7F
	s.send(outputBuffer)

# Buffer for a packet received from yaLVDC.
packetSize = 6
inputBuffer = bytearray(packetSize)
leftToRead = packetSize
view = memoryview(inputBuffer)

didSomething = False
def mainLoopIteration():
	global didSomething, inputBuffer, leftToRead, view

	# Check for packet data received from yaLVDC and process it.
	# While these packets are always exactly 5
	# bytes long, since the socket is non-blocking, any individual read
	# operation may yield less bytes than that, so the buffer may accumulate data
	# over time until it fills.	
	try:
		numNewBytes = s.recv_into(view, leftToRead)
	except:
		numNewBytes = 0
	if numNewBytes > 0:
		view = view[numNewBytes:]
		leftToRead -= numNewBytes 
		if leftToRead == 0:
			# Prepare for next read attempt.
			view = memoryview(inputBuffer)
			leftToRead = packetSize
			# Parse the packet just read, and call outputFromAGx().
			# Start with a sanity check.
			ok = 1
			if (inputBuffer[0] & 0x80) != 0x80:
				ok = 0
			elif (inputBuffer[1] & 0x80) != 0x00:
				ok = 0
			elif (inputBuffer[2] & 0x80) != 0x00:
				ok = 0
			elif (inputBuffer[3] & 0x80) != 0x00:
				ok = 0
			elif (inputBuffer[4] & 0x80) != 0x00:
				ok = 0
			elif (inputBuffer[5] & 0x80) != 0x00:
				ok = 0
			# Packet has the various signatures we expect.
			if ok == 0:
				# The protocol allows yaLVDC to send a byte that's 0xFF, 
				# which is intended as a ping and can be ignored.  I don't
				# know if there will actually be any such messages.  For 
				# other corrupted packets we print a message.  In either 
				# case, we try to realign past the corrupted/ping byte(s).
				if inputBuffer[0] != 0xff:
					print("Illegal packet: %03o %03o %03o %03o %03o %03o" % tuple(inputBuffer))
				for i in range(1,packetSize):
					if (inputBuffer[i] & 0x80) == 0x80 and inputBuffer[i] != 0xFF:
						j = 0
						for k in range(i,6):
							inputBuffer[j] = inputBuffer[k]
							j += 1
						view = view[j:]
						leftToRead = packetSize - j
			else:
				ioType = (inputBuffer[0] >> 3) & 7
				source = inputBuffer[0] & 7
				channel = ((inputBuffer[2] << 2) & 0x180) | (inputBuffer[1] & 0x7F)
				value = (inputBuffer[2] & 0x1F) << 21
				value |= (inputBuffer[3] & 0x7F) << 14
				value |= (inputBuffer[4] & 0x7F) << 7
				value |= inputBuffer[5] & 0x7F
				outputFromCPU(ioType, channel, value)
			didSomething = True
	
	# Check for locally-generated data for which we must generate messages
	# to yaLVDC over the socket.  In theory, the externalData list could contain
	# any number of channel operations, but in practice it will probably contain
	# only 0 or 1 operations.
	externalData = inputsForCPU()
	for i in range(0, len(externalData)):
		packetize(externalData[i])
		didSomething = True
	
	root.after(refreshRate, mainLoopIteration)		
	
while False:
	mainLoopIteration()

root = tk.Tk()

ProcessorDisplayPanel_support.set_Tk_var()
top = topProcessorDisplayPanel (root)
ProcessorDisplayPanel_support.init(root, top)
# Lots and lots of initializations that the PAGE tool wasn't
# flexible enough to do for me.
# Indicators for PDP DATA area:
indicatorInitialize(top.pdp1, "1", PANEL_PDP)
indicatorInitialize(top.pdp2, "2", PANEL_PDP)
indicatorInitialize(top.pdp3, "3", PANEL_PDP)
indicatorInitialize(top.pdp4, "4", PANEL_PDP)
indicatorInitialize(top.pdp5, "5", PANEL_PDP)
indicatorInitialize(top.pdp6, "6", PANEL_PDP)
indicatorInitialize(top.pdp7, "7", PANEL_PDP)
indicatorInitialize(top.pdp8, "8", PANEL_PDP)
indicatorInitialize(top.pdp9, "9", PANEL_PDP)
indicatorInitialize(top.pdp10, "10", PANEL_PDP)
indicatorInitialize(top.pdp11, "11", PANEL_PDP)
indicatorInitialize(top.pdp12, "12", PANEL_PDP)
indicatorInitialize(top.pdp13, "13", PANEL_PDP)
indicatorInitialize(top.pdpERROR_RESET, "ERROR\nRESET", PANEL_PDP)
indicatorInitialize(top.pdpPARITY_ERROR, "PAR ERR", PANEL_PDP)
indicatorInitialize(top.pdpERROR_HOLD, "E HOLD", PANEL_PDP)
indicatorInitialize(top.pdpMEM_BUFFER_PARITY, "MEM\nBUFFER\nPARITY", PANEL_PDP)
indicatorInitialize(top.pdpMEM_BUFFER_REG, "MEM\nBUFFER\nREG", PANEL_PDP)
indicatorInitialize(top.pdpTRANS_REG, "TRANS\nREG", PANEL_PDP)
indicatorInitialize(top.pdpOP4, "OP4", PANEL_PDP)
indicatorInitialize(top.pdpOP3, "OP3", PANEL_PDP)
indicatorInitialize(top.pdpOP2, "OP2", PANEL_PDP)
indicatorInitialize(top.pdpOP1, "OP1", PANEL_PDP)
indicatorInitialize(top.pdpA1, "A1", PANEL_PDP)
indicatorInitialize(top.pdpA2, "A2", PANEL_PDP)
indicatorInitialize(top.pdpA3, "A3", PANEL_PDP)
indicatorInitialize(top.pdpA4, "A4", PANEL_PDP)
indicatorInitialize(top.pdpA5, "A5", PANEL_PDP)
indicatorInitialize(top.pdpA6, "A6", PANEL_PDP)
indicatorInitialize(top.pdpA7, "A7", PANEL_PDP)
indicatorInitialize(top.pdpA8, "A8", PANEL_PDP)
indicatorInitialize(top.pdpA9, "A9", PANEL_PDP)
indicatorInitialize(top.pdpMEM_ADD_REG, "MEM\nADD\nREG", PANEL_PDP)
indicatorInitialize(top.pdpHOPSAVE_REG, "HOP\nSAVE\nREG", PANEL_PDP)
indicatorInitialize(top.pdpSYL0, "0", PANEL_PDP)
indicatorInitialize(top.pdpSYL1, "0", PANEL_PDP)
indicatorInitialize(top.pdpIS4, "IS4", PANEL_PDP)
indicatorInitialize(top.pdpIS3, "IS3", PANEL_PDP)
indicatorInitialize(top.pdpIS2, "IS2", PANEL_PDP)
indicatorInitialize(top.pdpIS1, "IS1", PANEL_PDP)
indicatorInitialize(top.pdpDS4, "DS4", PANEL_PDP)
indicatorInitialize(top.pdpDS3, "DS3", PANEL_PDP)
indicatorInitialize(top.pdpDS2, "DS2", PANEL_PDP)
indicatorInitialize(top.pdpDS1, "DS1", PANEL_PDP)
indicatorInitialize(top.pdpIM0, "IM0", PANEL_PDP)
indicatorInitialize(top.pdpIM1, "IM1", PANEL_PDP)
indicatorInitialize(top.pdpDM0, "DM0", PANEL_PDP)
indicatorInitialize(top.pdpDM1, "DM1", PANEL_PDP)
# Indicators for PDP INTERRUPTS area:
indicatorInitialize(top.iI1, "I1", PANEL_PDP)
indicatorInitialize(top.iI2, "I2", PANEL_PDP)
indicatorInitialize(top.iI3, "I3", PANEL_PDP)
indicatorInitialize(top.iI4, "I4", PANEL_PDP)
indicatorInitialize(top.iI5, "I5", PANEL_PDP)
indicatorInitialize(top.iI6, "I6", PANEL_PDP)
indicatorInitialize(top.iI7, "I7", PANEL_PDP)
indicatorInitialize(top.iI8, "I8", PANEL_PDP)
indicatorInitialize(top.iI9, "I9", PANEL_PDP)
indicatorInitialize(top.iI10, "I10", PANEL_PDP)
indicatorInitialize(top.iI11, "I11", PANEL_PDP)
indicatorInitialize(top.iI12, "I12", PANEL_PDP)
indicatorInitialize(top.iI13, "I13", PANEL_PDP)
indicatorInitialize(top.iI14, "I14", PANEL_PDP)
indicatorInitialize(top.iI15, "I15", PANEL_PDP)
indicatorInitialize(top.iI16, "I16", PANEL_PDP)
indicatorInitialize(top.iB1, "B1", PANEL_PDP)
indicatorInitialize(top.iB2, "B2", PANEL_PDP)
indicatorInitialize(top.iB3, "B3", PANEL_PDP)
indicatorInitialize(top.iB4, "B4", PANEL_PDP)
indicatorInitialize(top.iB5, "B5", PANEL_PDP)
indicatorInitialize(top.iB6, "B6", PANEL_PDP)
indicatorInitialize(top.iB7, "B7", PANEL_PDP)
indicatorInitialize(top.iB8, "B8", PANEL_PDP)
indicatorInitialize(top.iB9, "B9", PANEL_PDP)
indicatorInitialize(top.iB10, "B10", PANEL_PDP)
indicatorInitialize(top.iB11, "B11", PANEL_PDP)
indicatorInitialize(top.iB12, "B12", PANEL_PDP)
indicatorInitialize(top.iB13, "B13", PANEL_PDP)
indicatorInitialize(top.iB14, "B14", PANEL_PDP)
indicatorInitialize(top.iB15, "B15", PANEL_PDP)
indicatorInitialize(top.iB16, "B16", PANEL_PDP)
indicatorInitialize(top.INHIBIT_CTRL, "INHIBIT\nCTRL", PANEL_PDP)
indicatorInitialize(top.PROG_ERR, "PROG ERR", PANEL_PDP)
indicatorInitialize(top.SYNC_ERR, "SYNC ERR", PANEL_PDP)
# Indicators for PDP PROGRAM CONTROL area:
indicatorInitialize(top.CST, "CST", PANEL_PDP)
indicatorInitialize(top.MAN_CST, "MAN CST", PANEL_PDP)
indicatorInitialize(top.ADVANCE, "ADVANCE", PANEL_PDP)
indicatorInitialize(top.P1, "P1", PANEL_PDP)
indicatorInitialize(top.P2, "P2", PANEL_PDP)
indicatorInitialize(top.P4, "P4", PANEL_PDP)
indicatorInitialize(top.P10, "P10", PANEL_PDP)
indicatorInitialize(top.P20, "P20", PANEL_PDP)
indicatorInitialize(top.P40, "P40", PANEL_PDP)
indicatorInitialize(top.D1, "D1", PANEL_PDP)
indicatorInitialize(top.D2, "D2", PANEL_PDP)
indicatorInitialize(top.D3, "D3", PANEL_PDP)
indicatorInitialize(top.D4, "D4", PANEL_PDP)
indicatorInitialize(top.D5, "D5", PANEL_PDP)
indicatorInitialize(top.D6, "D6", PANEL_PDP)
indicatorInitialize(top.RESET_MACHINE, "RESET\nMACHINE", PANEL_PDP)
indicatorInitialize(top.HALT, "HALT", PANEL_PDP)
# Indicators for MISCELLANEOUS area (PDP POWER CONTROL and TRMC MODE):
indicatorInitialize(top.pdpLAMP_TEST, "LAMP\nTEST", PANEL_PDP)
indicatorInitialize(top.trmcMANUAL, "MANUAL", PANEL_PDP)
indicatorOn(top.trmcMANUAL)
indicatorInitialize(top.trmcML, "ML", PANEL_PDP)
indicatorInitialize(top.trmcDD, "DD", PANEL_PDP)
indicatorOn(top.trmcDD)
indicatorInitialize(top.trmcERROR_DEVICES_TEST, "ERROR\nDEVICES\nTEST", PANEL_PDP)
# Indicators for MLDD INSTRUCTION ADDRESS area:
indicatorInitialize(top.iaComputerM0, "0", PANEL_MLDD, cc=CC_COMPUTER)
indicatorInitialize(top.iaComputerM1, "1", PANEL_MLDD, cc=CC_COMPUTER)
indicatorInitialize(top.iaComputerSYL0, "0", PANEL_MLDD, cc=CC_COMPUTER)
indicatorInitialize(top.iaComputerSYL1, "1", PANEL_MLDD, cc=CC_COMPUTER)
indicatorInitialize(top.iaComputerIS4, "IS4", PANEL_MLDD, cc=CC_COMPUTER)
indicatorInitialize(top.iaComputerIS3, "IS3", PANEL_MLDD, cc=CC_COMPUTER)
indicatorInitialize(top.iaComputerIS2, "IS2", PANEL_MLDD, cc=CC_COMPUTER)
indicatorInitialize(top.iaComputerIS1, "IS1", PANEL_MLDD, cc=CC_COMPUTER)
indicatorInitialize(top.iaComputerA8, "A8", PANEL_MLDD, cc=CC_COMPUTER)
indicatorInitialize(top.iaComputerA7, "A7", PANEL_MLDD, cc=CC_COMPUTER)
indicatorInitialize(top.iaComputerA6, "A6", PANEL_MLDD, cc=CC_COMPUTER)
indicatorInitialize(top.iaComputerA5, "A5", PANEL_MLDD, cc=CC_COMPUTER)
indicatorInitialize(top.iaComputerA4, "A4", PANEL_MLDD, cc=CC_COMPUTER)
indicatorInitialize(top.iaComputerA3, "A3", PANEL_MLDD, cc=CC_COMPUTER)
indicatorInitialize(top.iaComputerA2, "A2", PANEL_MLDD, cc=CC_COMPUTER)
indicatorInitialize(top.iaComputerA1, "A1", PANEL_MLDD, cc=CC_COMPUTER)
indicatorInitialize(top.iaCommandM0, "0", PANEL_MLDD, cc=CC_COMMAND)
indicatorOn(top.iaCommandM0)
indicatorInitialize(top.iaCommandM1, "1", PANEL_MLDD, cc=CC_COMMAND)
indicatorInitialize(top.iaCommandSYL0, "0", PANEL_MLDD, cc=CC_COMMAND)
indicatorOn(top.iaCommandSYL0)
indicatorInitialize(top.iaCommandSYL1, "1", PANEL_MLDD, cc=CC_COMMAND)
indicatorInitialize(top.iaCommandIS4, "IS4", PANEL_MLDD, cc=CC_COMMAND)
indicatorInitialize(top.iaCommandIS3, "IS3", PANEL_MLDD, cc=CC_COMMAND)
indicatorInitialize(top.iaCommandIS2, "IS2", PANEL_MLDD, cc=CC_COMMAND)
indicatorInitialize(top.iaCommandIS1, "IS1", PANEL_MLDD, cc=CC_COMMAND)
indicatorInitialize(top.iaCommandA8, "A8", PANEL_MLDD, cc=CC_COMMAND)
indicatorInitialize(top.iaCommandA7, "A7", PANEL_MLDD, cc=CC_COMMAND)
indicatorInitialize(top.iaCommandA6, "A6", PANEL_MLDD, cc=CC_COMMAND)
indicatorInitialize(top.iaCommandA5, "A5", PANEL_MLDD, cc=CC_COMMAND)
indicatorInitialize(top.iaCommandA4, "A4", PANEL_MLDD, cc=CC_COMMAND)
indicatorInitialize(top.iaCommandA3, "A3", PANEL_MLDD, cc=CC_COMMAND)
indicatorInitialize(top.iaCommandA2, "A2", PANEL_MLDD, cc=CC_COMMAND)
indicatorInitialize(top.iaCommandA1, "A1", PANEL_MLDD, cc=CC_COMMAND)
# Indicators for MLDD DATA ADDRESS area:
indicatorInitialize(top.daPARITY_BIT, "BR", PANEL_MLDD, cc=CC_COMPUTER)
indicatorInitialize(top.daComputerDS4, "DS4", PANEL_MLDD, cc=CC_COMPUTER)
indicatorInitialize(top.daComputerDS3, "DS3", PANEL_MLDD, cc=CC_COMPUTER)
indicatorInitialize(top.daComputerDS2, "DS2", PANEL_MLDD, cc=CC_COMPUTER)
indicatorInitialize(top.daComputerDS1, "DS1", PANEL_MLDD, cc=CC_COMPUTER)
indicatorInitialize(top.daComputerM0, "0", PANEL_MLDD, cc=CC_COMPUTER)
indicatorInitialize(top.daComputerM1, "1", PANEL_MLDD, cc=CC_COMPUTER)
indicatorInitialize(top.daComputerOP4, "OP4", PANEL_MLDD, cc=CC_COMPUTER)
indicatorInitialize(top.daComputerOP3, "OP3", PANEL_MLDD, cc=CC_COMPUTER)
indicatorInitialize(top.daComputerOP2, "OP2", PANEL_MLDD, cc=CC_COMPUTER)
indicatorInitialize(top.daComputerOP1, "OP1", PANEL_MLDD, cc=CC_COMPUTER)
indicatorInitialize(top.daComputerOA9, "OA9", PANEL_MLDD, cc=CC_COMPUTER)
indicatorInitialize(top.daComputerOA8, "OA8", PANEL_MLDD, cc=CC_COMPUTER)
indicatorInitialize(top.daComputerOA7, "OA7", PANEL_MLDD, cc=CC_COMPUTER)
indicatorInitialize(top.daComputerOA6, "OA6", PANEL_MLDD, cc=CC_COMPUTER)
indicatorInitialize(top.daComputerOA5, "OA5", PANEL_MLDD, cc=CC_COMPUTER)
indicatorInitialize(top.daComputerOA4, "OA4", PANEL_MLDD, cc=CC_COMPUTER)
indicatorInitialize(top.daComputerOA3, "OA3", PANEL_MLDD, cc=CC_COMPUTER)
indicatorInitialize(top.daComputerOA2, "OA2", PANEL_MLDD, cc=CC_COMPUTER)
indicatorInitialize(top.daComputerOA1, "OA1", PANEL_MLDD, cc=CC_COMPUTER)
indicatorInitialize(top.daCommandDS4, "DS4", PANEL_MLDD, cc=CC_COMMAND)
indicatorInitialize(top.daCommandDS3, "DS3", PANEL_MLDD, cc=CC_COMMAND)
indicatorInitialize(top.daCommandDS2, "DS2", PANEL_MLDD, cc=CC_COMMAND)
indicatorInitialize(top.daCommandDS1, "DS1", PANEL_MLDD, cc=CC_COMMAND)
indicatorInitialize(top.daCommandM0, "0", PANEL_MLDD, cc=CC_COMMAND)
indicatorOn(top.daCommandM0)
indicatorInitialize(top.daCommandM1, "1", PANEL_MLDD, cc=CC_COMMAND)
indicatorInitialize(top.daCommandOP4, "OP4", PANEL_MLDD, cc=CC_COMMAND)
indicatorInitialize(top.daCommandOP3, "OP3", PANEL_MLDD, cc=CC_COMMAND)
indicatorInitialize(top.daCommandOP2, "OP2", PANEL_MLDD, cc=CC_COMMAND)
indicatorInitialize(top.daCommandOP1, "OP1", PANEL_MLDD, cc=CC_COMMAND)
indicatorInitialize(top.daCommandOA9, "OA9", PANEL_MLDD, cc=CC_COMMAND)
indicatorInitialize(top.daCommandOA8, "OA8", PANEL_MLDD, cc=CC_COMMAND)
indicatorInitialize(top.daCommandOA7, "OA7", PANEL_MLDD, cc=CC_COMMAND)
indicatorInitialize(top.daCommandOA6, "OA6", PANEL_MLDD, cc=CC_COMMAND)
indicatorInitialize(top.daCommandOA5, "OA5", PANEL_MLDD, cc=CC_COMMAND)
indicatorInitialize(top.daCommandOA4, "OA4", PANEL_MLDD, cc=CC_COMMAND)
indicatorInitialize(top.daCommandOA3, "OA3", PANEL_MLDD, cc=CC_COMMAND)
indicatorInitialize(top.daCommandOA2, "OA2", PANEL_MLDD, cc=CC_COMMAND)
indicatorInitialize(top.daCommandOA1, "OA1", PANEL_MLDD, cc=CC_COMMAND)
# Indicators for MLDD DATA area:
indicatorInitialize(top.mlddLAMP_TEST, "LAMP\nTEST", PANEL_MLDD)
indicatorInitialize(top.mlddPARITY_BIT, "PARITY\nBIT", PANEL_MLDD)
indicatorInitialize(top.mlddComputerBR0, "B\nR", PANEL_MLDD, cc=CC_COMPUTER)
indicatorInitialize(top.mlddComputerBR1, "B\nR", PANEL_MLDD, cc=CC_COMPUTER)
indicatorInitialize(top.mlddComputerSIGN, "S", PANEL_MLDD, cc=CC_COMPUTER)
indicatorInitialize(top.mlddComputer1, "1", PANEL_MLDD, cc=CC_COMPUTER)
indicatorInitialize(top.mlddComputer2, "2", PANEL_MLDD, cc=CC_COMPUTER)
indicatorInitialize(top.mlddComputer3, "3", PANEL_MLDD, cc=CC_COMPUTER)
indicatorInitialize(top.mlddComputer4, "4", PANEL_MLDD, cc=CC_COMPUTER)
indicatorInitialize(top.mlddComputer5, "5", PANEL_MLDD, cc=CC_COMPUTER)
indicatorInitialize(top.mlddComputer6, "6", PANEL_MLDD, cc=CC_COMPUTER)
indicatorInitialize(top.mlddComputer7, "7", PANEL_MLDD, cc=CC_COMPUTER)
indicatorInitialize(top.mlddComputer8, "8", PANEL_MLDD, cc=CC_COMPUTER)
indicatorInitialize(top.mlddComputer9, "9", PANEL_MLDD, cc=CC_COMPUTER)
indicatorInitialize(top.mlddComputer10, "10", PANEL_MLDD, cc=CC_COMPUTER)
indicatorInitialize(top.mlddComputer11, "11", PANEL_MLDD, cc=CC_COMPUTER)
indicatorInitialize(top.mlddComputer12, "12", PANEL_MLDD, cc=CC_COMPUTER)
indicatorInitialize(top.mlddComputer13, "13", PANEL_MLDD, cc=CC_COMPUTER)
indicatorInitialize(top.mlddComputer14, "14", PANEL_MLDD, cc=CC_COMPUTER)
indicatorInitialize(top.mlddComputer15, "15", PANEL_MLDD, cc=CC_COMPUTER)
indicatorInitialize(top.mlddComputer16, "16", PANEL_MLDD, cc=CC_COMPUTER)
indicatorInitialize(top.mlddComputer17, "17", PANEL_MLDD, cc=CC_COMPUTER)
indicatorInitialize(top.mlddComputer18, "18", PANEL_MLDD, cc=CC_COMPUTER)
indicatorInitialize(top.mlddComputer19, "19", PANEL_MLDD, cc=CC_COMPUTER)
indicatorInitialize(top.mlddComputer20, "20", PANEL_MLDD, cc=CC_COMPUTER)
indicatorInitialize(top.mlddComputer21, "21", PANEL_MLDD, cc=CC_COMPUTER)
indicatorInitialize(top.mlddComputer22, "22", PANEL_MLDD, cc=CC_COMPUTER)
indicatorInitialize(top.mlddComputer23, "23", PANEL_MLDD, cc=CC_COMPUTER)
indicatorInitialize(top.mlddComputer24, "24", PANEL_MLDD, cc=CC_COMPUTER)
indicatorInitialize(top.mlddComputer25, "25", PANEL_MLDD, cc=CC_COMPUTER)
indicatorInitialize(top.mlddCommandSYL0, "S\nY\n0", PANEL_MLDD, cc=CC_COMMAND)
indicatorInitialize(top.mlddCommandSYL1, "S\nY\n1", PANEL_MLDD, cc=CC_COMMAND)
indicatorDataCommandParity()
indicatorInitialize(top.mlddCommandSIGN, "S", PANEL_MLDD, cc=CC_COMMAND)
indicatorInitialize(top.mlddCommand1, "1", PANEL_MLDD, cc=CC_COMMAND)
indicatorInitialize(top.mlddCommand2, "2", PANEL_MLDD, cc=CC_COMMAND)
indicatorInitialize(top.mlddCommand3, "3", PANEL_MLDD, cc=CC_COMMAND)
indicatorInitialize(top.mlddCommand4, "4", PANEL_MLDD, cc=CC_COMMAND)
indicatorInitialize(top.mlddCommand5, "5", PANEL_MLDD, cc=CC_COMMAND)
indicatorInitialize(top.mlddCommand6, "6", PANEL_MLDD, cc=CC_COMMAND)
indicatorInitialize(top.mlddCommand7, "7", PANEL_MLDD, cc=CC_COMMAND)
indicatorInitialize(top.mlddCommand8, "8", PANEL_MLDD, cc=CC_COMMAND)
indicatorInitialize(top.mlddCommand9, "9", PANEL_MLDD, cc=CC_COMMAND)
indicatorInitialize(top.mlddCommand10, "10", PANEL_MLDD, cc=CC_COMMAND)
indicatorInitialize(top.mlddCommand11, "11", PANEL_MLDD, cc=CC_COMMAND)
indicatorInitialize(top.mlddCommand12, "12", PANEL_MLDD, cc=CC_COMMAND)
indicatorInitialize(top.mlddCommand13, "13", PANEL_MLDD, cc=CC_COMMAND)
indicatorInitialize(top.mlddCommand14, "14", PANEL_MLDD, cc=CC_COMMAND)
indicatorInitialize(top.mlddCommand15, "15", PANEL_MLDD, cc=CC_COMMAND)
indicatorInitialize(top.mlddCommand16, "16", PANEL_MLDD, cc=CC_COMMAND)
indicatorInitialize(top.mlddCommand17, "17", PANEL_MLDD, cc=CC_COMMAND)
indicatorInitialize(top.mlddCommand18, "18", PANEL_MLDD, cc=CC_COMMAND)
indicatorInitialize(top.mlddCommand19, "19", PANEL_MLDD, cc=CC_COMMAND)
indicatorInitialize(top.mlddCommand20, "20", PANEL_MLDD, cc=CC_COMMAND)
indicatorInitialize(top.mlddCommand21, "21", PANEL_MLDD, cc=CC_COMMAND)
indicatorInitialize(top.mlddCommand22, "22", PANEL_MLDD, cc=CC_COMMAND)
indicatorInitialize(top.mlddCommand23, "23", PANEL_MLDD, cc=CC_COMMAND)
indicatorInitialize(top.mlddCommand24, "24", PANEL_MLDD, cc=CC_COMMAND)
indicatorInitialize(top.mlddCommand25, "25", PANEL_MLDD, cc=CC_COMMAND)
# Indicators for MLDD DISPLAY MODE area:
indicatorInitialize(top.acDATA, "DATA", PANEL_MLDD)
indicatorOn(top.acDATA)
indicatorInitialize(top.acINS, "INS", PANEL_MLDD)
# Indicators for MLDD ERRORS area:
indicatorInitialize(top.PARITY_SERIAL, "SER", PANEL_MLDD)
indicatorInitialize(top.TRS, "TRS", PANEL_MLDD)
indicatorInitialize(top.A13, "A13", PANEL_MLDD)
indicatorInitialize(top.SERIAL, "SER", PANEL_MLDD)
indicatorInitialize(top.HOPC1, "HOPC", PANEL_MLDD)
indicatorInitialize(top.SSMSC, "SMSC", PANEL_MLDD)
indicatorInitialize(top.SSMBR, "SMBR", PANEL_MLDD)
indicatorInitialize(top.OAC, "OAC", PANEL_MLDD)
indicatorInitialize(top.BR14, "BR14", PANEL_MLDD)
indicatorInitialize(top.ERROR_RESET, "ERROR\nRESET", PANEL_MLDD)
indicatorInitialize(top.INVERT_ERROR, "INVERT\nERROR", PANEL_MLDD)
# Indicators for MLDD MEMORY LOADER area:
indicatorInitialize(top.mlREPEAT, "REPEAT", PANEL_MLDD)
indicatorInitialize(top.mlREPEAT_INVERSE, "/REPEAT", PANEL_MLDD)
indicatorOn(top.mlREPEAT_INVERSE)
indicatorInitialize(top.mlADDRESS_CMPTR, "ADDRESS\nCOMPTR", PANEL_MLDD)
indicatorInitialize(top.mlCOMPTR_DISPLAY_RESET, "COMPTR\nDISPLAY\nRESET", PANEL_MLDD)
indicatorInitialize(top.mlCOMMAND_DISPLAY_RESET, "COMMAND\nDISPLAY\nRESET", PANEL_MLDD)
# Indicators for CE ACCUMULATOR area:
indicatorInitialize(top.A_S, "A/S", PANEL_CE)
indicatorInitialize(top.DLA2, "DLA2", PANEL_CE)
indicatorInitialize(top.DLA3, "DLA3", PANEL_CE)
indicatorInitialize(top.DLA4, "DLA4", PANEL_CE)
indicatorInitialize(top.DLA5, "DLA5", PANEL_CE)
indicatorInitialize(top.DLA6, "DLA6", PANEL_CE)
indicatorInitialize(top.DLA7, "DLA7", PANEL_CE)
indicatorInitialize(top.DLA8, "DLA8", PANEL_CE)
indicatorInitialize(top.DLA9, "DLA9", PANEL_CE)
indicatorInitialize(top.DLA10, "DLA10", PANEL_CE)
indicatorInitialize(top.DLA11, "DLA11", PANEL_CE)
indicatorInitialize(top.DLA12, "DLA12", PANEL_CE)
indicatorInitialize(top.DLA13, "DLA13", PANEL_CE)
indicatorInitialize(top.DLA14, "DLA14", PANEL_CE)
indicatorInitialize(top.DLA15, "DLA15", PANEL_CE)
indicatorInitialize(top.DLA16, "DLA16", PANEL_CE)
indicatorInitialize(top.DLA17, "DLA17", PANEL_CE)
indicatorInitialize(top.DLA18, "DLA18", PANEL_CE)
indicatorInitialize(top.DLA19, "DLA19", PANEL_CE)
indicatorInitialize(top.DLA20, "DLA20", PANEL_CE)
indicatorInitialize(top.DLA21, "DLA21", PANEL_CE)
indicatorInitialize(top.DLA22, "DLA22", PANEL_CE)
indicatorInitialize(top.DLA23, "DLA23", PANEL_CE)
indicatorInitialize(top.DLA24, "DLA24", PANEL_CE)
indicatorInitialize(top.DLA25, "DLA25", PANEL_CE)
indicatorInitialize(top.DLA26, "DLA26", PANEL_CE)
indicatorInitialize(top.DLA27, "DLA27", PANEL_CE)
indicatorInitialize(top.DLA28, "DLA28", PANEL_CE)
indicatorInitialize(top.DLA29, "DLA29", PANEL_CE)
indicatorInitialize(top.DLA30, "DLA30", PANEL_CE)
indicatorInitialize(top.ACC0, "ACC0", PANEL_CE)
indicatorInitialize(top.ACC1, "ACC1", PANEL_CE)
indicatorInitialize(top.DLB1, "DLB1", PANEL_CE)
indicatorInitialize(top.DLB2, "DLB2", PANEL_CE)
indicatorInitialize(top.DLB3, "DLB3", PANEL_CE)
indicatorInitialize(top.DLB4, "DLB4", PANEL_CE)
indicatorInitialize(top.DLB5, "DLB5", PANEL_CE)
indicatorInitialize(top.DLB6, "DLB6", PANEL_CE)
indicatorInitialize(top.DLB7, "DLB7", PANEL_CE)
indicatorInitialize(top.DLB8, "DLB8", PANEL_CE)
indicatorInitialize(top.DLB9, "DLB9", PANEL_CE)
indicatorInitialize(top.DLB10, "DLB10", PANEL_CE)
indicatorInitialize(top.DLB11, "DLB11", PANEL_CE)
indicatorInitialize(top.DLB12, "DLB12", PANEL_CE)
indicatorInitialize(top.DLB13, "DLB13", PANEL_CE)
indicatorInitialize(top.DLB14, "DLB14", PANEL_CE)
indicatorInitialize(top.DLB15, "DLB15", PANEL_CE)
indicatorInitialize(top.DLB16, "DLB16", PANEL_CE)
indicatorInitialize(top.DLB17, "DLB17", PANEL_CE)
indicatorInitialize(top.DLB18, "DLB18", PANEL_CE)
indicatorInitialize(top.DLB19, "DLB19", PANEL_CE)
indicatorInitialize(top.DLB20, "DLB20", PANEL_CE)
indicatorInitialize(top.DLB21, "DLB21", PANEL_CE)
indicatorInitialize(top.AI0, "AI0", PANEL_CE)
indicatorInitialize(top.AI1, "AI1", PANEL_CE)
indicatorInitialize(top.AI2, "AI2", PANEL_CE)
indicatorInitialize(top.AI3, "AI3", PANEL_CE)
indicatorInitialize(top.AI4, "AI4", PANEL_CE)
indicatorInitialize(top.ACC_DISPLAY_ENABLE, "ACC\nDISPLAY\nENABLE", PANEL_CE)
# Indicators for CE MEMORY BUFFER REGISTER area:
indicatorInitialize(top.mbrBIT1, "BIT1", PANEL_CE)
indicatorInitialize(top.mbrBIT2, "BIT2", PANEL_CE)
indicatorInitialize(top.mbrBIT3, "BIT3", PANEL_CE)
indicatorInitialize(top.mbrBIT4, "BIT4", PANEL_CE)
indicatorInitialize(top.mbrBIT5, "BIT5", PANEL_CE)
indicatorInitialize(top.mbrBIT6, "BIT6", PANEL_CE)
indicatorInitialize(top.mbrBIT7, "BIT7", PANEL_CE)
indicatorInitialize(top.mbrBIT8, "BIT8", PANEL_CE)
indicatorInitialize(top.mbrBIT9, "BIT9", PANEL_CE)
indicatorInitialize(top.mbrBIT10, "BIT10", PANEL_CE)
indicatorInitialize(top.mbrBIT11, "BIT11", PANEL_CE)
indicatorInitialize(top.mbrBIT12, "BIT12", PANEL_CE)
indicatorInitialize(top.mbrBIT13, "BIT13", PANEL_CE)
indicatorInitialize(top.mbrBIT14, "BIT14", PANEL_CE)
indicatorInitialize(top.mbrMBR1, "MB1", PANEL_CE)
indicatorInitialize(top.mbrMBR2, "MB2", PANEL_CE)
indicatorInitialize(top.mbrMBR3, "MB3", PANEL_CE)
indicatorInitialize(top.mbrMBR4, "MB4", PANEL_CE)
indicatorInitialize(top.mbrMBR5, "MB5", PANEL_CE)
indicatorInitialize(top.mbrMBR6, "MB6", PANEL_CE)
indicatorInitialize(top.mbrMBR7, "MB7", PANEL_CE)
indicatorInitialize(top.mbrMBR8, "MB8", PANEL_CE)
indicatorInitialize(top.mbrMBR9, "MB9", PANEL_CE)
indicatorInitialize(top.mbrMBR10, "MB10", PANEL_CE)
indicatorInitialize(top.mbrMBR11, "MB11", PANEL_CE)
indicatorInitialize(top.mbrMBR12, "MB12", PANEL_CE)
indicatorInitialize(top.mbrMBR13, "MB13", PANEL_CE)
indicatorInitialize(top.mbrODD_PARITY, "ODD PAR", PANEL_CE)
indicatorInitialize(top.mbrLOAD, "LOAD", PANEL_CE)
indicatorInitialize(top.ceLAMP_TEST, "LAMP\nTEST", PANEL_CE)
# Callback bindings for indicators which are also pushbuttons.
top.PROG_ERR.bind("<Button-1>", pressedPROG_ERR)
top.PROG_ERR.bind("<ButtonRelease-1>", eventIndicatorButtonRelease)
top.acINS.bind("<Button-1>", eventAddressCompareIns)
top.acDATA.bind("<Button-1>", eventAddressCompareData)
top.pdpLAMP_TEST.bind("<Button-1>", eventPdpLampTest)
top.pdpLAMP_TEST.bind("<ButtonRelease-1>", eventPdpLampTestRelease)
top.mlddLAMP_TEST.bind("<Button-1>", eventMlddLampTest)
top.mlddLAMP_TEST.bind("<ButtonRelease-1>", eventMlddLampTestRelease)
top.ceLAMP_TEST.bind("<Button-1>", eventCeLampTest)
top.ceLAMP_TEST.bind("<ButtonRelease-1>", eventCeLampTestRelease)
top.trmcERROR_DEVICES_TEST.bind("<Button-1>", eventTrmcErrorDevicesTest)
top.trmcERROR_DEVICES_TEST.bind("<ButtonRelease-1>", eventIndicatorButtonRelease)
top.RESET_MACHINE.bind("<Button-1>", eventResetMachine)
top.RESET_MACHINE.bind("<ButtonRelease-1>", eventIndicatorButtonRelease)
top.HALT.bind("<Button-1>", eventHalt)
top.HALT.bind("<ButtonRelease-1>", eventIndicatorButtonRelease)
top.ERROR_RESET.bind("<Button-1>", eventErrorReset)
top.ERROR_RESET.bind("<ButtonRelease-1>", eventIndicatorButtonRelease)
top.mlADDRESS_CMPTR.bind("<Button-1>", eventAddressCmptr)
top.mlADDRESS_CMPTR.bind("<ButtonRelease-1>", eventIndicatorButtonRelease)
top.mlCOMPTR_DISPLAY_RESET.bind("<Button-1>", eventComptrDisplayReset)
top.mlCOMPTR_DISPLAY_RESET.bind("<ButtonRelease-1>", eventIndicatorButtonRelease)
top.mlCOMMAND_DISPLAY_RESET.bind("<Button-1>", eventCommandDisplayReset)
top.mlCOMMAND_DISPLAY_RESET.bind("<ButtonRelease-1>", eventIndicatorButtonRelease)
top.daCommandOP1.bind("<Button-1>", updateDaCommand)
top.daCommandOP2.bind("<Button-1>", updateDaCommand)
top.daCommandOP3.bind("<Button-1>", updateDaCommand)
top.daCommandOP4.bind("<Button-1>", updateDaCommand)
top.mlddCommandSIGN.bind("<Button-1>", eventToggleDataIndicator)
top.mlddCommand1.bind("<Button-1>", eventToggleDataIndicator)
top.mlddCommand2.bind("<Button-1>", eventToggleDataIndicator)
top.mlddCommand3.bind("<Button-1>", eventToggleDataIndicator)
top.mlddCommand4.bind("<Button-1>", eventToggleDataIndicator)
top.mlddCommand5.bind("<Button-1>", eventToggleDataIndicator)
top.mlddCommand6.bind("<Button-1>", eventToggleDataIndicator)
top.mlddCommand7.bind("<Button-1>", eventToggleDataIndicator)
top.mlddCommand8.bind("<Button-1>", eventToggleDataIndicator)
top.mlddCommand9.bind("<Button-1>", eventToggleDataIndicator)
top.mlddCommand10.bind("<Button-1>", eventToggleDataIndicator)
top.mlddCommand11.bind("<Button-1>", eventToggleDataIndicator)
top.mlddCommand12.bind("<Button-1>", eventToggleDataIndicator)
top.mlddCommand13.bind("<Button-1>", eventToggleDataIndicator)
top.mlddCommand14.bind("<Button-1>", eventToggleDataIndicator)
top.mlddCommand15.bind("<Button-1>", eventToggleDataIndicator)
top.mlddCommand16.bind("<Button-1>", eventToggleDataIndicator)
top.mlddCommand17.bind("<Button-1>", eventToggleDataIndicator)
top.mlddCommand18.bind("<Button-1>", eventToggleDataIndicator)
top.mlddCommand19.bind("<Button-1>", eventToggleDataIndicator)
top.mlddCommand20.bind("<Button-1>", eventToggleDataIndicator)
top.mlddCommand21.bind("<Button-1>", eventToggleDataIndicator)
top.mlddCommand22.bind("<Button-1>", eventToggleDataIndicator)
top.mlddCommand23.bind("<Button-1>", eventToggleDataIndicator)
top.mlddCommand24.bind("<Button-1>", eventToggleDataIndicator)
top.mlddCommand25.bind("<Button-1>", eventToggleDataIndicator)
top.daCommandOA1.bind("<Button-1>", updateDaCommand)
top.daCommandOA2.bind("<Button-1>", updateDaCommand)
top.daCommandOA3.bind("<Button-1>", updateDaCommand)
top.daCommandOA4.bind("<Button-1>", updateDaCommand)
top.daCommandOA5.bind("<Button-1>", updateDaCommand)
top.daCommandOA6.bind("<Button-1>", updateDaCommand)
top.daCommandOA7.bind("<Button-1>", updateDaCommand)
top.daCommandOA8.bind("<Button-1>", updateDaCommand)
top.daCommandOA9.bind("<Button-1>", updateDaCommand)
top.daCommandDS1.bind("<Button-1>", updateDaCommand)
top.daCommandDS2.bind("<Button-1>", updateDaCommand)
top.daCommandDS3.bind("<Button-1>", updateDaCommand)
top.daCommandDS4.bind("<Button-1>", updateDaCommand)
top.daCommandM0.bind("<Button-1>", eventToggleDaCommandM0)
top.daCommandM1.bind("<Button-1>", eventToggleDaCommandM1)
top.iaCommandA1.bind("<Button-1>", updateIaCommand)
top.iaCommandA2.bind("<Button-1>", updateIaCommand)
top.iaCommandA3.bind("<Button-1>", updateIaCommand)
top.iaCommandA4.bind("<Button-1>", updateIaCommand)
top.iaCommandA5.bind("<Button-1>", updateIaCommand)
top.iaCommandA6.bind("<Button-1>", updateIaCommand)
top.iaCommandA7.bind("<Button-1>", updateIaCommand)
top.iaCommandA8.bind("<Button-1>", updateIaCommand)
top.iaCommandIS1.bind("<Button-1>", updateIaCommand)
top.iaCommandIS2.bind("<Button-1>", updateIaCommand)
top.iaCommandIS3.bind("<Button-1>", updateIaCommand)
top.iaCommandIS4.bind("<Button-1>", updateIaCommand)
top.iaCommandSYL1.bind("<Button-1>", eventToggleIaCommandSYL1)
top.iaCommandSYL0.bind("<Button-1>", eventToggleIaCommandSYL0)
top.iaCommandM1.bind("<Button-1>", eventToggleIaCommandM1)
top.iaCommandM0.bind("<Button-1>", eventToggleIaCommandM0)
top.mlREPEAT.bind("<Button-1>", eventREPEAT)
top.mlREPEAT_INVERSE.bind("<Button-1>", eventREPEAT_INVERSE)
top.trmcML.bind("<Button-1>", eventML)
top.trmcDD.bind("<Button-1>", eventDD)

root.resizable(resize, resize)
root.after(refreshRate, mainLoopIteration)
root.mainloop()
