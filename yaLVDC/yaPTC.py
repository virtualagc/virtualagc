#!/usr/bin/env python3
# Copyright:	None, placed in the PUBLIC DOMAIN by its author (Ron Burkey)
# Filename: 	yaPTC.py
# Purpose:		This is a very primitive PTC peripheral emulator for
#				use with the yaLVDC PTC CPU emulator, and is connected
#				to yaLVDC with "virtual wires" ... i.e., via network sockets.
#				It's not fully developed, and is just intended to help me.
#				It could be developed fully, if there were reason to do so.  
# Reference:	http://www.ibiblio.org/apollo/developer.html
# Mod history:	2020-05-07 RSB	Began adapting from piPeripheral.py, which is
#								a skeleton program for developing peripherals
#								for the AGC or AGS CPU emulators.
#				2020-05-08 RSB	I've added a GUI, based on the standard
#								tkinter module in Python.  I've used the PAGE
#								(http://page.sourceforge.net/html/index.html)
#								tool to build it, and those are the files
#								ProcessorDisplayPanel.py and 
#								ProcessorDisplayPanel_support.py, which are
#								simply imported as a module called
#								"ProcessorDisplayPanel" at the top of this
#								file.  The sources PAGE uses to generate 
#								this code are in the guiDesign folder.
#				2020-05-10 RSB	Unfortunately, there's no way this can keep up
#								with yaLVDC in terms of speed.  It continues
#								to receive data from yaLVDC *long* after the
#								PTC program has been paused.  It may be 
#								possible to use it if the clock-rate in 
#								yaLVDC is cut way down, and I'll experiment
#								with that, because this program is nice enough
#								now that I'm not keen to reimplement it in 
#								another language and gui toolkit.
#				2020-05-11 RSB	Removed all of the "interrupt latch" 
#								processing (most of the input CIO's) and 
#								moved it all back locally to yaLVDC, because
#								the PAST software expects to read back changes
#								to the interrupt latch within one instruction
#								cycle.  I expect this will help with the
#								speed problem I complained about above as well.
#				2020-06-14 RSB	Removed ad hoc stuff related to temporarily
#								writing "command" settings into the "computer"
#								indicators on the MLDD.  That's stuff I added
#								before understanding fully that the program 
#								loaded into the PTC for test procedures other 
#								than Figure 7-11 was *not* the PAST program.  
#								This allows the "computer" indicators to work 
#								how I imagined they ought to.  Of course, it 
#								also means that some test procedures no longer 
#								"PASS" when the PAST program is loaded, which 
#								is as it should be!
#				2023-08-08 RSB	Corrected references of "AGC" to "LVDC".
#								Added --terminal operation to allow using 
#								as a spy on virtual-wire outputs but yaLVDC
#								(whether with --ptc switch or not).
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
prsModeBCD = True
# BA8421 character set in its native encoding.  All of the unprintable
# characters are replaced by '?', which isn't a legal character anyway.
# Used only for --ptc.
unp = '?'
BA8421 = [
	' ', '1', '2', '3', '4', '5', '6', '7',
	'8', '9', '0', '#', '@', unp, unp, unp,
	'?', '/', 'S', 'T', 'U', 'V', 'W', 'X',
	'Y', 'Z', '‡', ',', '(', unp, unp, unp,
	'-', 'J', 'K', 'L', 'M', 'N', 'O', 'P',
	'Q', 'R', unp, '$', '*', unp, unp, unp,
	'+', 'A', 'B', 'C', 'D', 'E', 'F', 'G',
	'H', 'I', '?', '.', ')', unp, unp, unp
]
# This table comes from Figure 2-50 in the original PTC documentation and,
# I guess, represents what the PTC printer physically prints, as opposed
# to what the printer for the assembly listing prints.  I guess.
unp = '▯'
BA8421a = [
	' ', '1', '2', '3', '4', '5', '6', '7',
	'8', '9', '0', '=', "'", ':', unp, unp,
	unp, '/', 'S', 'T', 'U', 'V', 'W', 'X',
	'Y', 'Z', '≠', '.', '(', 'ƀ', unp, unp,
	'-', 'J', 'K', 'L', 'M', 'N', 'O', 'P',
	'Q', 'R', '!', '$', '*', unp, unp, unp,
	'+', 'A', 'B', 'C', 'D', 'E', 'F', 'G',
	'H', 'I', '?', '.', ')', unp, unp, unp
]
# This table comes from Figure 2-53 in the original PTC documentation and,
# I think, represents what the PTC typewriter physically prints.
# Some of the characters are UTF-8 in this list (and the two lists above),
# and each character displays fine on my own computer (which is Linux) using 
# the monospaced font I've chosen for the text widgets (namely, Courier 10).
# Except one:  character 0o77, ⯒.  This character has apparently been 
# accepted into UTF-8 (seemingly thanks to Ken Shirriff) too recently to 
# be available in _any_ font I've found.  It's supposed to look like character 
# 0o73, ⧻, but rotated 90 degrees.  I could, of course, create a new font
# that has all of the needed characters in it, and distribute it with this
# program, but that just seems like a lot of work for something very few 
# people are going to care about.  Particularly since I'd have a hard time
# coming up with explanations about how to actually install that font and
# make it accessible on so many system types.  So to sum it all up, you may 
# or may not see the handful of UTF-8 characters on your computer in the 
# PTC printer/typewriter emulations, and in particular you may not be able
# to see character 0o77.  You probably won't notice the problem (if any) at all.
unp = '▯'
BA8421b = [
	' ', '1', '2', '3', '4', '5', '6', '7',
	'8', '9', '0', '#', "@", ':', '>', '√',
	'¢', '/', 'S', 'T', 'U', 'V', 'W', 'X',
	'Y', 'Z', '≠', ',', '%', '=', '\\','⧻',
	'-', 'J', 'K', 'L', 'M', 'N', 'O', 'P',
	'Q', 'R', '!', '$', '*', ']', ';', 'Δ',
	'&', 'A', 'B', 'C', 'D', 'E', 'F', 'G',
	'H', 'I', '?', '.', '⌑', '[', '<', '⯒'
]

refreshRate = 1 # Milliseconds
resizable = 0

typewriterMargin = 90
typewriterTabStop = 10

terminalHeaderPrinted = False

# Parse command-line arguments.
import argparse
cli = argparse.ArgumentParser()
cli.add_argument("--host", \
				 help="Host address of yaLVDC, defaulting to localhost.")
cli.add_argument("--port", \
				 help="Port for yaLVDC, defaulting to 19653.", type=int)
cli.add_argument("--id", \
				 help="Unique ID of this peripheral (1-7), default=1.", \
				 type=int)
cli.add_argument("--resize", \
				 help="If 1 (default 0), make the window resizable.", \
				 type=int)
cli.add_argument("--scale", \
			help="An integer (default 1) scale for the plotter peripheral.", \
			type=int)
cli.add_argument("--twidth", \
				 help="Width of the typewriter, in characters (default %d)." \
						% typewriterMargin, type=int)
cli.add_argument("--tstop", \
				 help="Typewriter tab width, in characters (default %d)." \
				 		% typewriterTabStop, type=int)
cli.add_argument("--terminal", \
				 help="Just print all incoming virtual-wire data from CPU.", \
				 type=int)
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

# The --scale switch is useful in that if you don't use it, some of the tiny 
# details of the plotter test (see Figure 7-11 sheet 10 in the PTC 
# documentation) can't be seen well enough to confirm that they're correct in 
# the test plot.  If so, --scale=2 or --scale=3 helps a lot in this regard.  
# However ... portions of the plot may not be immediately visible in the plot 
# window.  You have to use the mouse scroll-wheel to scroll the window up or 
# down (which probably isn't necessary if the height of the window is not 
# changed from its default value of >1024), and SHIFT scroll-wheel to scroll 
# sideways (which definitely should be necessary.  Or expand the plotter window 
# if you have enough screen space.
if args.scale:
	plotScale = args.scale
else:
	plotScale = 1

if args.twidth:
	typewriterMargin = args.twidth

if args.tstop:
	typewriterTabStop = args.tstop

##############################################################################
# The separate window implementing the printer peripheral.

printerFont = "-family {Courier 10 Pitch} -size 9"
class printer:
	def __init__(self, root):
		self.root = root
		self.root.title("PTC PRINTER")
		self.root.geometry("1200x480")
		self.text = ScrolledText(self.root)
		self.text.place(relx=0.0, rely=0.0, relheight=1.0, relwidth=1.0, \
					    bordermode='ignore')
		self.text.configure(background="white")
		self.text.configure(font=printerFont)
		self.text.configure(insertborderwidth="3")
		self.text.configure(selectbackground="#c4c4c4")
		self.text.configure(wrap="char")

##############################################################################
# The separate window implementing the typewriter peripheral.

class typewriter:
	def __init__(self, root):
		self.root = root
		self.root.title("PTC TYPEWRITER")
		self.root.geometry("1200x480")
		self.text = ScrolledText(self.root)
		self.text.place(relx=0.0, rely=0.0, relheight=1.0, relwidth=1.0, \
					    bordermode='ignore')
		self.text.configure(background="white")
		self.text.configure(font=printerFont)
		self.text.configure(insertborderwidth="3")
		self.text.configure(selectbackground="#c4c4c4")
		self.text.configure(wrap="char")

#############################################################################
# The separate window implementing the plotter peripheral.

plotMargin = 10
class plotter:
	def __init__(self, root):
		self.root = root
		self.root.title("PTC PLOTTER")
		self.root.geometry("%dx%d" % (1024 + 2 * plotMargin, \
									  1024 + 2 * plotMargin))
		self.canvas = ScrolledWindow(self.root)
		self.canvas.place(relx=0.0, rely=0.0, relheight=1.0,
			relwidth=1.0, bordermode='ignore')
		self.canvas.configure(background="white")
		self.canvas.configure(borderwidth="2")
		self.canvas.configure(relief="groove")
		self.canvas.configure(selectbackground="#c4c4c4")
		self.color = self.canvas.cget("background")
		self.canvas_f = tk.Frame(self.canvas,
	                            background=self.color)
		self.canvas.create_window(0, 0, anchor='nw',
	                                           window=self.canvas_f)

##############################################################################
# Hardware abstraction / User-defined functions.  Also, any other 
# platform-specific initialization.  This is the section to customize for 
# specific applications.

# Callbacks for the GUI (tkinter) event loop.

def eventIndicatorButtonRelease(event):
	indicatorOff(event.widget)

advance = False
def eventAdvance(event):
	global advance
	indicatorOn(event.widget)
	advance = True
	
resetMachine = False
def eventResetMachine(event):
	global resetMachine, isRed
	resetMachine = True
	indicatorOn(event.widget)
	isRed = False

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

# This function is automatically called periodically by the event loop to check 
# for conditions that will result in sending messages to yaLVDC that are 
# interpreted as changes to bits on its input channels.  The return
# value is supposed to be a list of 4-tuples of the form
#	[ (ioType0,channel0,value0,mask0), (ioType1,channel1,value1,mask1), ...]
# and may be an empty list.  The "values" are written to the LVDC/PTC's input 
# "channels", while the "masks" tell which bits of the "values" are valid.  
# The ioTypeN's are indices into ioTypes[] (see top of file) to tell which 
# particular class of i/o channels is affected.  Only the PIO, CIO, and INT 
# classes are possible for inputs to the CPU.
changedIA = -1
changedDA = -1
changedD = -1
displayModePayload = -1
needStatusFromCPU = False
nomask = 0o377777777
def inputsForCPU():
	#global delayCount, ioTypeCount, channelCount
	global ProgRegA, ProgRegB, resetMachine, halt, needStatusFromCPU
	global changedIA, changedDA, changedD, displayModePayload, advance
	global newConnect
	returnValue = []
	if args.terminal:
		return []
	
	if newConnect:
		returnValue.append((4, 0o606, typewriterMargin, nomask))
		returnValue.append((4, 0o607, typewriterTabStop, nomask))
		newConnect = False
	
	if ProgRegA != -1:
		n = ProgRegA
		ProgRegA = -1
		# Note that the 3 least-significant bits (printer, plotter,
		# and typewriter busy) are simulated directly in yaLVDC,
		# due to timing considerations, and hence have to be masked
		# off.
		returnValue.append((1, 0o214, n, nomask & ~7))

	if ProgRegB != -1:
		n = ProgRegB
		ProgRegB = -1
		returnValue.append((1, 0o220, n, nomask))
	
	if resetMachine:
		resetMachine = False
		returnValue.append((4, 0o604, 0, nomask))
	
	if halt:
		halt = False
		returnValue.append((4, 0o000, 0, nomask))
	
	if changedIA != -1:
		returnValue.append((4, 0o003, changedIA, nomask))
		changedIA = -1

	if changedDA != -1:
		returnValue.append((4, 0o002, changedDA, nomask))
		changedDA = -1

	if changedD != -1:
		returnValue.append((4, 0o004, changedD, nomask))
		changedD = -1

	if displayModePayload != -1:
		returnValue.append((4, 0o005, displayModePayload, nomask))
		displayModePayload = -1

	if advance:
		advance = False
		if modeControl >= 2:
			returnValue.append((4, 0o001, 0, nomask))
		elif modeControl == 1:
			returnValue.append((4, 0o603, 0, nomask))
		elif modeControl == 0:
			returnValue.append((4, 0o604, 0, nomask))
			returnValue.append((4, 0o001, 0, nomask))

	if needStatusFromCPU:
		needStatusFromCPU = False
		returnValue.append((4, 0o605, 0, nomask))
	
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
PANEL_PDP = 1	# PANEL_XXX is just a constant we use to ID specific panels.
PANEL_MLDD = 2
PANEL_CE = 3
CC_NONE = 0 # CC_XXX is a constant we use to tell if an indicator is \
			# "computer" or "command" or neither.
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
	canvas.create_text(1, 1, fill="white", text=text, \
						font=("Sans", 6), justify=tk.CENTER)
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
# corresponding panel, because the configuration attributes of the canvases'
# elements do that already.
inLampTests = []
def isIndicatorInLampTest(canvas):
	for panel in inLampTests:
		if canvas in indicators[panel]:
			return panel
	return False 
def indicatorOff(canvas):
	inTest = isIndicatorInLampTest(canvas)
	if inTest == False:
		if canvas.itemcget(1, "state") == "normal":
			canvas.itemconfig(1, state = "hidden")
			canvas.itemconfig(2, fill = "white")
			if canvas in commandIndicators:
				indicatorToggle(top.mlddPARITY_BIT)
	else:
		if indicators[inTest][canvas] == "normal":
			indicators[inTest][canvas] = "hidden"
			if canvas in commandIndicators:
				indicatorToggle(top.mlddPARITY_BIT)
def indicatorOn(canvas):
	inTest = isIndicatorInLampTest(canvas)
	if inTest == False:
		if canvas.itemcget(1, "state") == "hidden":
			canvas.itemconfig(1, state = "normal")
			canvas.itemconfig(2, fill = "black")
			if canvas in commandIndicators:
				indicatorToggle(top.mlddPARITY_BIT)
	else:
		if indicators[inTest][canvas] == "hidden":
			indicators[inTest][canvas] = "normal"
			if canvas in commandIndicators:
				indicatorToggle(top.mlddPARITY_BIT)
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
		#print(indicator.itemcget(2, "text"))
		indicators[panel][indicator] = indicator.itemcget(1, "state")
		indicatorOn(indicator)
	# The SERIALIZER PARITY BIT has to be lit last (although
	# it may already have been lit above), since the subsequent
	# indicatorXXX() calls may have changed its visual state.
	if panel == PANEL_MLDD:
		indicatorOn(top.mlddPARITY_BIT)
	if panel not in inLampTests:
		inLampTests.append(panel)
def endPanelLampTest(panel):
	if panel in inLampTests:
		inLampTests.remove(panel)
	for indicator in indicators[panel]:
		# The SERIALIZER PARITY BIT lamp has to be treated specially:
		# instead of being restored to whatever state it was when 
		# the lamp test started, it must be set to 1 and then the
		# indicatorOn() calls for the other lamps progressively 
		# adjust it so that it ends up agreeing with them.  Or else
		# it can be restored, but has to be done *last*.  Either way,
		# it has to be treated specially.  It will be the *first*
		# item on the list for its panel, because that's how the
		# initialization was ordered.
		if indicator == top.mlddPARITY_BIT:
			indicatorOn(indicator)
		elif indicators[panel][indicator] == "normal":
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
	indicatorSet(top.mlddCommandSYL1, oddParity13(value >> 13))
	indicatorSet(top.mlddCommandSYL0, oddParity13(value))

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

def eventToggleIndicatorChange(event):
	indicatorToggle(event.widget)
	changeDisplayMode(displaySelect, modeControl, addressCompare, other=True)

# Note that this function accepts as input either an event 
# (which is a class having an attribute that's a widget, 
# in this case a canvas) or else a canvas.
def updateDaCommand(event):
	global changedDA, dcDisplayCount
	if hasattr(event, "widget"):
		indicatorToggle(event.widget)
	else:
		indicatorToggle(event)
	changedDA = getDataAddressCommand()
	dcDisplayCount = 0
	
def eventToggleDaCommandM01(event):
	global dcDisplayCount
	indicatorToggle(top.daCommandM0)
	updateDaCommand(top.daCommandM1)
	dcDisplayCount = 0

# Note that this function accepts as input either an event 
# (which is a class having an attribute that's a widget, 
# in this case a canvas) or else a canvas.
def updateIaCommand(event):
	global changedIA, dcDisplayCount
	if hasattr(event, "widget"):
		indicatorToggle(event.widget)
	else:
		indicatorToggle(event)
	changedIA = getInstructionAddressCommand()
	dcDisplayCount = 0
	
def eventToggleIaCommandM01(event):
	global dcDisplayCount
	indicatorToggle(top.iaCommandM0)
	updateIaCommand(top.iaCommandM1)
	dcDisplayCount = 0

def eventToggleIaCommandSYL01(event):
	global dcDisplayCount
	indicatorToggle(top.iaCommandSYL0)
	updateIaCommand(top.iaCommandSYL1)
	dcDisplayCount = 0

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
	indicatorOn(top.PARITY_TAPE)
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
	indicatorOff(top.PARITY_TAPE)
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

def autoAddressCmptr():
	global changedD
	if top.trmcML.itemcget(1, "state") == "normal" and \
			top.mlREPEAT.itemcget(1, "state") == "normal":
		changedD = getDataCommand()
		root.after(500, autoAddressCmptr)

def eventRepeat(event):
	indicatorToggle(top.mlREPEAT)
	indicatorToggle(top.mlREPEAT_INVERSE)
	changeDisplayMode(displaySelect, modeControl, addressCompare, other=True)
	autoAddressCmptr()

def eventAddressCmptr(event):
	global changedD
	if top.trmcML.itemcget(1, "state") == "normal":
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
	#indicatorOn(top.mlddComputerBR0)
	#indicatorOn(top.mlddComputerBR1)
	#indicatorOn(top.mlddPARITY_BIT)

def eventCommandDisplayReset(event):
	global changedIA, changedDA
	indicatorOn(event.widget)
	for indicator in commandIndicators:
		indicatorOff(indicator)
	indicatorDataCommandParity()
	indicatorOn(top.iaCommandM0)
	indicatorOn(top.iaCommandSYL0)
	indicatorOn(top.daCommandM0)
	indicatorOn(top.mlddPARITY_BIT)
	changedIA = 0
	changedDA = 0

def eventMlDd(event):
	indicatorToggle(top.trmcML)
	indicatorToggle(top.trmcDD)
	changeDisplayMode(displaySelect, modeControl, addressCompare, other=True)

# Display MEM ADD REG or HOP SAVE REG on PD.
def displayMarHsr():
	pass
def eventMarHsr(event):
	indicatorToggle(top.pdpMEM_ADD_REG)
	indicatorToggle(top.pdpHOPSAVE_REG)
	displayMarHsr()
	changeDisplayMode(displaySelect, modeControl, addressCompare, other=True)

# This computes an odd-parity bit for the syllable.
def oddParity13(value):
	value &= 0o17777  # Starts with 13 bits.
	value = 0o177 & (value ^ (value >> 7)) # Now has 7 bits.
	value = 0o17 & (value ^ (value >> 4)) # Now has 4 bits.
	value = 3 & (value ^ (value >> 2)) # Now has 2 bits.
	return 1 & (1 ^ value ^ (value >> 1)) # Just 1 bit left!

# This function is called by the event loop only when yaLVDC has written to an
# output channel.  The function should do whatever it is that needs to be done
# with this output data, which is not processed additionally in any way by the 
# generic portion of the program.  The ioType argument is an index into the
# ioTypes[] array (see the top of this file), giving the class of i/o ports
# to which the channel belongs.  Only the PIO, CIO, and PRS channels are 
# applicable for output from the CPU to peripherals.
#
# The function _could_ also be called directly, by panel events, though I'm not
# aware of any reason at the moment why that would be needed.  But it does work.
displaySelect = -1
modeControl = 0
addressCompare = False
crlfCount = 0
xPlot = 0
yPlot = 0
penDown = False
xDelta = 0
yDelta = 0
typewriterCharsInLine = 0
isRed = False
def outputFromCPU(ioType, channel, value):
	global displaySelect, modeControl, addressCompare, dcDisplayCount, crlfCount
	global prsModeBCD, xPlot, yPlot, penDown, xDelta, yDelta, \
			typewriterCharsInLine
	global isRed
	see = False
	
	#print("*", end="")
	
	if ioType == 0:
		# PIO
		print("\nChannel PIO-%03o = %09o" % (channel, value), end="  ")
		
	elif ioType == 1:
		# CIO
		if channel == 0o114:
			print("\nSingle step")
		elif channel == 0o120:
			string = BA8421b[(value >> 20) & 0o77]
			#print("\nTypewriter alphanumeric = %09o (%s)" % \
			#		(value, string), end="  ")
			typewriterCharsInLine += 1
			if typewriterCharsInLine >= typewriterMargin:
				typewriterCharsInLine = 0
				string += "\n"
				see = True
			if isRed:
				typewriterWindow.text.insert(tk.END, string, "red")
			else:
				typewriterWindow.text.insert(tk.END, string)
		elif channel == 0o160:
			top2 = (value >> 24) & 3
			bottom4 = (value >> 20) & 3
			if top2 in [0, 3]:
				string = "CRLF"
				if crlfCount == 0:
					printerWindow.text.insert(tk.END, "\n")
					printerWindow.text.see("end")
					crlfCount += 1
			else:
				string = "%d space(s)" % bottom4
				while bottom4 > 0:
					printerWindow.text.insert(tk.END, " ", "bg")
					bottom4 -= 1
				crlfCount = 0
			#print("\nPrinter carriage control = %09o (%s)" % \
			#		(value, string), end="  ")
		elif channel == 0o124:
			string = BA8421b[(value >> 22) & 0o17]
			#print("\nTypewriter decimal = %09o (%s)" % \
			#		(value, string), end="  ")
			typewriterCharsInLine += 1
			if typewriterCharsInLine >= typewriterMargin:
				typewriterCharsInLine = 0
				string += "\n"
				see = True
			if isRed:
				typewriterWindow.text.insert(tk.END, string, "red")
			else:
				typewriterWindow.text.insert(tk.END, string)
		elif channel == 0o164: # Set printer octal mode.
			prsModeBCD = False
		elif channel == 0o170: # Set printer BCD mode.
			prsModeBCD = True
		elif channel == 0o130:
			string = chr(ord('0') + ((value >> 23) & 0o07))
			#print("\nTypewriter octal = %09o (%s)" % (value, string), end="  ")
			typewriterCharsInLine += 1
			if typewriterCharsInLine >= typewriterMargin:
				typewriterCharsInLine = 0
				string += "\n"
				see = True
			if isRed:
				typewriterWindow.text.insert(tk.END, string, "red")
			else:
				typewriterWindow.text.insert(tk.END, string)
		elif channel == 0o134:
			string = ""
			if value == 0o200000000:
				name = "space"
				string = " "
				typewriterCharsInLine += 1
				if typewriterCharsInLine >= typewriterMargin:
					typewriterCharsInLine = 0
					string += "\n"
					see = True
			elif value == 0o100000000:
				name = "black ribbon"
				isRed = False
			elif value == 0o040000000:
				name = "red ribbon"
				isRed = True
			elif value == 0o020000000:
				name = "index"
				string = ("\n%%%ds" % typewriterCharsInLine) % ""
				see = True
			elif value == 0o010000000:
				name = "return"
				string = "\n"
				typewriterCharsInLine = 0
				see = True
			elif value == 0o004000000:
				name = "tab"
				string = ""
				while True:
					string += " "
					typewriterCharsInLine += 1
					if typewriterCharsInLine >= typewriterMargin:
						typewriterCharsInLine = 0
						string += "\n"
						see = True
						break
					if typewriterCharsInLine % typewriterTabStop == 0:
						break
			else:
				string = "(illegal)"
			#print("\nTypewriter control = %09o (%s)" % (value, name), end="  ")
			if string != "":
				if isRed:
					typewriterWindow.text.insert(tk.END, string, "red")
				else:
					typewriterWindow.text.insert(tk.END, string)
		elif channel == 0o140:
			#print("\nX plot = %09o" % value, end="  ")
			xDelta = value & 0o1777
			if value & 0o200000000:
				xDelta = -xDelta
		elif channel == 0o144:
			#print("\nY plot = %09o" % value, end="  ")
			yDelta = value & 0o1777
			if value & 0o200000000:
				yDelta = -yDelta
			xPlotNew = xPlot + xDelta
			yPlotNew = yPlot + yDelta
			if yPlotNew < 0:
				yPlotNew = 0
			elif yPlotNew > 1023:
				yPlotNew = 1023
			xDelta = 0
			yDelta = 0
			if penDown:
				print("\nPlotter:  draw from (%d,%d) to (%d,%d)" % \
							(xPlot, yPlot, xPlotNew, yPlotNew))
				plotterWindow.canvas.create_line(xPlot*plotScale + plotMargin, \
					(1023-yPlot)*plotScale + plotMargin, \
					xPlotNew*plotScale + plotMargin, \
					(1023-yPlotNew)*plotScale + plotMargin, width=1)
			else:
				print("\nPlotter:  move from (%d,%d) to (%d,%d)" % \
							(xPlot, yPlot, xPlotNew, yPlotNew))
			xPlot = xPlotNew
			yPlot = yPlotNew
		elif channel == 0o150:
			#print("\nZ plot = %09o" % value, end="  ")
			if value & 1:
				penDown = False
			elif value & 2:
				penDown = True
		elif channel == 0o204:
			# Turn indicator lamps on or off.  I think this is actually
			# the full functionality of CIO-204
			#print("here %d" % value)
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
			if value & 0o1:
				indicatorOn(top.D1)
				if crlfCount == 0:
					printerWindow.text.insert(tk.END, "\n")
					printerWindow.text.see("end")
					crlfCount += 1
			else:
				indicatorOff(top.D1)
			if value & 0o2:
				indicatorOn(top.D2)
			else:
				indicatorOff(top.D2)
			if value & 0o4:
				indicatorOn(top.D3)
				typewriterCharsInLine = 0
				typewriterWindow.text.insert(tk.END, "\n")
				typewriterWindow.text.see("end")
				if crlfCount == 0:
					printerWindow.text.insert(tk.END, "\n")
					printerWindow.text.see("end")
					crlfCount += 1
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
		if see:
			typewriterWindow.text.see("end")
	elif ioType == 2:
		if channel == 0o774:
			print("\nPRS 774 (group mark)", end= "  ")
			if crlfCount == 0:
				printerWindow.text.insert(tk.END, "\n")
				printerWindow.text.see("end")
				crlfCount += 1
		else: # PRS from ACC or memory.
			#print("\nPRS 775 (%09o)" % value)
			string = ""
			if prsModeBCD:
				shift = 20
				while shift >= 0:
					string += BA8421a[(value >> shift) & 0o077]
					shift -= 6
			else:
				shift = 23
				while shift >= 0:
					string += chr(ord('0') + ((value >> shift) & 0o07))
					shift -= 3
				string += chr(ord('0') + ((value << 1) & 0o07)) + "   "
			printerWindow.text.insert(tk.END, string, "bg")
			crlfCount = 0
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
			indicatorSet(top.daPARITY_BIT, oddParity13(value))
			if top.pdpMEM_ADD_REG.itemcget(1, "state") == "normal":
				indicatorSet(top.pdp1, value & 4096)
				indicatorSet(top.pdp2, value & 2048)
				indicatorSet(top.pdp3, value & 1024)
				indicatorSet(top.pdp4, value & 512)
				indicatorSet(top.pdp5, value & 256)
				indicatorSet(top.pdp6, value & 128)
				indicatorSet(top.pdp7, value & 64)
				indicatorSet(top.pdp8, value & 32)
				indicatorSet(top.pdp9, value & 16)
				indicatorSet(top.pdp10, value & 8)
				indicatorSet(top.pdp11, value & 4)
				indicatorSet(top.pdp12, value & 2)
				indicatorSet(top.pdp13, value & 1)
				indicatorSet(top.pdpOP1, opcode & 1)
				indicatorSet(top.pdpOP2, opcode & 2)
				indicatorSet(top.pdpOP3, opcode & 4)
				indicatorSet(top.pdpOP4, opcode & 8)
		elif channel == 0o602:
			# Data address.
			opcode = value & 0o17
			a9 = (value >> 4) & 1
			a81 = (value >> 5) & 0o377
			dm = (value >> 17) & 1
			ds = (value >> 20) & 0o17
			indicatorSet(top.daCommandM0, not dm)
			indicatorSet(top.daCommandM1, dm)
			indicatorSet(top.daCommandDS1, ds & 1)
			indicatorSet(top.daCommandDS2, ds & 2)
			indicatorSet(top.daCommandDS3, ds & 4)
			indicatorSet(top.daCommandDS4, ds & 8)
			indicatorSet(top.daCommandOP1, opcode & 1)
			indicatorSet(top.daCommandOP2, opcode & 2)
			indicatorSet(top.daCommandOP3, opcode & 4)
			indicatorSet(top.daCommandOP4, opcode & 8)
			indicatorSet(top.daCommandOA9, a9)
			indicatorSet(top.daCommandOA1, a81 & 1)
			indicatorSet(top.daCommandOA2, a81 & 2)
			indicatorSet(top.daCommandOA3, a81 & 4)
			indicatorSet(top.daCommandOA4, a81 & 8)
			indicatorSet(top.daCommandOA5, a81 & 16)
			indicatorSet(top.daCommandOA6, a81 & 32)
			indicatorSet(top.daCommandOA7, a81 & 64)
			indicatorSet(top.daCommandOA8, a81 & 128)
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
			if top.pdpMEM_ADD_REG.itemcget(1, "state") == "normal":
				indicatorSet(top.pdpIM0, not im)
				indicatorSet(top.pdpIM1, im)
				indicatorSet(top.pdpSYL0, not s)
				indicatorSet(top.pdpSYL1, s)
				indicatorSet(top.pdpIS1, isect & 1)
				indicatorSet(top.pdpIS2, isect & 2)
				indicatorSet(top.pdpIS3, isect & 4)
				indicatorSet(top.pdpIS4, isect & 8)
				indicatorSet(top.pdpDM0, not dm)
				indicatorSet(top.pdpDM1, dm)
				indicatorSet(top.pdpDS1, ds & 1)
				indicatorSet(top.pdpDS2, ds & 2)
				indicatorSet(top.pdpDS3, ds & 4)
				indicatorSet(top.pdpDS4, ds & 8)
				indicatorSet(top.pdpA1, loc & 1)
				indicatorSet(top.pdpA2, loc & 2)
				indicatorSet(top.pdpA3, loc & 4)
				indicatorSet(top.pdpA4, loc & 8)
				indicatorSet(top.pdpA5, loc & 16)
				indicatorSet(top.pdpA6, loc & 32)
				indicatorSet(top.pdpA7, loc & 64)
				indicatorSet(top.pdpA8, loc & 128)
				indicatorSet(top.pdpA9, 0)
		elif channel == 0o603:
			# Instruction address.
			isect = (value >> 2) & 0o17
			s = (value >> 6) & 1
			loc = (value >> 7) & 0o377
			dm = (value >> 17) & 1
			ds = (value >> 20) & 0o17
			im = (value >> 25) & 1
			indicatorSet(top.iaCommandM0, not im)
			indicatorSet(top.iaCommandM1, im)
			indicatorSet(top.iaCommandSYL0, not s)
			indicatorSet(top.iaCommandSYL1, s)
			indicatorSet(top.iaCommandIS1, isect & 1)
			indicatorSet(top.iaCommandIS2, isect & 2)
			indicatorSet(top.iaCommandIS3, isect & 4)
			indicatorSet(top.iaCommandIS4, isect & 8)
			indicatorSet(top.iaCommandA1, loc & 1)
			indicatorSet(top.iaCommandA2, loc & 2)
			indicatorSet(top.iaCommandA3, loc & 4)
			indicatorSet(top.iaCommandA4, loc & 8)
			indicatorSet(top.iaCommandA5, loc & 16)
			indicatorSet(top.iaCommandA6, loc & 32)
			indicatorSet(top.iaCommandA7, loc & 64)
			indicatorSet(top.iaCommandA8, loc & 128)
		elif channel == 0o004:
			parity0 = oddParity13(value)
			parity1 = oddParity13(value >> 13)
			indicatorSet(top.mlddComputerBR0, parity0)
			indicatorSet(top.mlddComputerBR1, parity1)
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
		elif channel == 0o601:
			parity0 = oddParity13(value)
			parity1 = oddParity13(value >> 13)
			indicatorSet(top.mlddCommandSYL0, parity0)
			indicatorSet(top.mlddCommandSYL1, parity1)
			indicatorSet(top.mlddCommand25, value & 0o1)
			indicatorSet(top.mlddCommand24, value & 0o2)
			indicatorSet(top.mlddCommand23, value & 0o4)
			indicatorSet(top.mlddCommand22, value & 0o10)
			indicatorSet(top.mlddCommand21, value & 0o20)
			indicatorSet(top.mlddCommand20, value & 0o40)
			indicatorSet(top.mlddCommand19, value & 0o100)
			indicatorSet(top.mlddCommand18, value & 0o200)
			indicatorSet(top.mlddCommand17, value & 0o400)
			indicatorSet(top.mlddCommand16, value & 0o1000)
			indicatorSet(top.mlddCommand15, value & 0o2000)
			indicatorSet(top.mlddCommand14, value & 0o4000)
			indicatorSet(top.mlddCommand13, value & 0o10000)
			indicatorSet(top.mlddCommand12, value & 0o20000)
			indicatorSet(top.mlddCommand11, value & 0o40000)
			indicatorSet(top.mlddCommand10, value & 0o100000)
			indicatorSet(top.mlddCommand9, value & 0o200000)
			indicatorSet(top.mlddCommand8, value & 0o400000)
			indicatorSet(top.mlddCommand7, value & 0o1000000)
			indicatorSet(top.mlddCommand6, value & 0o2000000)
			indicatorSet(top.mlddCommand5, value & 0o4000000)
			indicatorSet(top.mlddCommand4, value & 0o10000000)
			indicatorSet(top.mlddCommand3, value & 0o20000000)
			indicatorSet(top.mlddCommand2, value & 0o40000000)
			indicatorSet(top.mlddCommand1, value & 0o100000000)
			indicatorSet(top.mlddCommandSIGN, value & 0o200000000)
		elif channel == 0o005:
			displaySelect = (value >> 4) & 3
			addressCompare = ((value >> 3) & 1) != 0
			modeControl = value & 7;
			repeat = (value >> 6) & 1
			cst = (value >> 7) & 1
			manCst = (value >> 8) & 1
			ml = (value >> 9) & 1
			accDisplayEnable = (value >> 10) & 1
			memAddReg = (value >> 11) & 1
			#print("\n%d %d %d" % (displaySelect, addressCompare, modeControl))
			ProcessorDisplayPanel_support.displaySelect.set(displaySelect)
			ProcessorDisplayPanel_support.modeControl.set(modeControl)
			indicatorSet(top.acINS, not addressCompare)
			indicatorSet(top.acDATA, addressCompare)
			indicatorSet(top.mlREPEAT, repeat)
			indicatorSet(top.mlREPEAT_INVERSE, not repeat)
			indicatorSet(top.CST, cst)
			indicatorSet(top.MAN_CST, manCst)
			indicatorSet(top.trmcML, ml)
			indicatorSet(top.trmcDD, not ml)
			indicatorSet(top.ACC_DISPLAY_ENABLE, accDisplayEnable)
			indicatorSet(top.pdpMEM_ADD_REG, memAddReg)
			indicatorSet(top.pdpHOPSAVE_REG, not memAddReg)
		elif channel == 0o600:
			print("ACC = %09o" % value)
			if top.ACC_DISPLAY_ENABLE.itemcget(1, "state") == "normal":
				indicatorSet(top.DLA26, (value >> 0) & 1)
				indicatorSet(top.DLA25, (value >> 1) & 1)
				indicatorSet(top.DLA24, (value >> 2) & 1)
				indicatorSet(top.DLA23, (value >> 3) & 1)
				indicatorSet(top.DLA22, (value >> 4) & 1)
				indicatorSet(top.DLA21, (value >> 5) & 1)
				indicatorSet(top.DLA20, (value >> 6) & 1)
				indicatorSet(top.DLA19, (value >> 7) & 1)
				indicatorSet(top.DLA18, (value >> 8) & 1)
				indicatorSet(top.DLA17, (value >> 9) & 1)
				indicatorSet(top.DLA16, (value >> 10) & 1)
				indicatorSet(top.DLA15, (value >> 11) & 1)
				indicatorSet(top.DLA14, (value >> 12) & 1)
				indicatorSet(top.DLA13, (value >> 13) & 1)
				indicatorSet(top.DLA12, (value >> 14) & 1)
				indicatorSet(top.DLA11, (value >> 15) & 1)
				indicatorSet(top.DLA10, (value >> 16) & 1)
				indicatorSet(top.DLA9, (value >> 17) & 1)
				indicatorSet(top.DLA8, (value >> 18) & 1)
				indicatorSet(top.DLA7, (value >> 19) & 1)
				indicatorSet(top.DLA6, (value >> 20) & 1)
				indicatorSet(top.DLA5, (value >> 21) & 1)
				indicatorSet(top.DLA4, (value >> 22) & 1)
				indicatorSet(top.DLA3, (value >> 23) & 1)
				indicatorSet(top.DLA2, (value >> 24) & 1)
				indicatorSet(top.A_S, (value >> 25) & 1)
		elif channel == 0o604:
			ProcessorDisplayPanel_support.bPRA25.set((value >> 0) & 1)
			ProcessorDisplayPanel_support.bPRA24.set((value >> 1) & 1)
			ProcessorDisplayPanel_support.bPRA23.set((value >> 2) & 1)
			ProcessorDisplayPanel_support.bPRA22.set((value >> 3) & 1)
			ProcessorDisplayPanel_support.bPRA21.set((value >> 4) & 1)
			ProcessorDisplayPanel_support.bPRA20.set((value >> 5) & 1)
			ProcessorDisplayPanel_support.bPRA19.set((value >> 6) & 1)
			ProcessorDisplayPanel_support.bPRA18.set((value >> 7) & 1)
			ProcessorDisplayPanel_support.bPRA17.set((value >> 8) & 1)
			ProcessorDisplayPanel_support.bPRA16.set((value >> 9) & 1)
			ProcessorDisplayPanel_support.bPRA15.set((value >> 10) & 1)
			ProcessorDisplayPanel_support.bPRA14.set((value >> 11) & 1)
			ProcessorDisplayPanel_support.bPRA13.set((value >> 12) & 1)
			ProcessorDisplayPanel_support.bPRA12.set((value >> 13) & 1)
			ProcessorDisplayPanel_support.bPRA11.set((value >> 14) & 1)
			ProcessorDisplayPanel_support.bPRA10.set((value >> 15) & 1)
			ProcessorDisplayPanel_support.bPRA9.set((value >> 16) & 1)
			ProcessorDisplayPanel_support.bPRA8.set((value >> 17) & 1)
			ProcessorDisplayPanel_support.bPRA7.set((value >> 18) & 1)
			ProcessorDisplayPanel_support.bPRA6.set((value >> 19) & 1)
			ProcessorDisplayPanel_support.bPRA5.set((value >> 20) & 1)
			ProcessorDisplayPanel_support.bPRA4.set((value >> 21) & 1)
			ProcessorDisplayPanel_support.bPRA3.set((value >> 22) & 1)
			ProcessorDisplayPanel_support.bPRA2.set((value >> 23) & 1)
			ProcessorDisplayPanel_support.bPRA1.set((value >> 24) & 1)
			ProcessorDisplayPanel_support.bPRAS.set((value >> 25) & 1)
		elif channel == 0o605:
			ProcessorDisplayPanel_support.bPRB25.set((value >> 0) & 1)
			ProcessorDisplayPanel_support.bPRB24.set((value >> 1) & 1)
			ProcessorDisplayPanel_support.bPRB23.set((value >> 2) & 1)
			ProcessorDisplayPanel_support.bPRB22.set((value >> 3) & 1)
			ProcessorDisplayPanel_support.bPRB21.set((value >> 4) & 1)
			ProcessorDisplayPanel_support.bPRB20.set((value >> 5) & 1)
			ProcessorDisplayPanel_support.bPRB19.set((value >> 6) & 1)
			ProcessorDisplayPanel_support.bPRB18.set((value >> 7) & 1)
			ProcessorDisplayPanel_support.bPRB17.set((value >> 8) & 1)
			ProcessorDisplayPanel_support.bPRB16.set((value >> 9) & 1)
			ProcessorDisplayPanel_support.bPRB15.set((value >> 10) & 1)
			ProcessorDisplayPanel_support.bPRB14.set((value >> 11) & 1)
			ProcessorDisplayPanel_support.bPRB13.set((value >> 12) & 1)
			ProcessorDisplayPanel_support.bPRB12.set((value >> 13) & 1)
			ProcessorDisplayPanel_support.bPRB11.set((value >> 14) & 1)
			ProcessorDisplayPanel_support.bPRB10.set((value >> 15) & 1)
			ProcessorDisplayPanel_support.bPRB9.set((value >> 16) & 1)
			ProcessorDisplayPanel_support.bPRB8.set((value >> 17) & 1)
			ProcessorDisplayPanel_support.bPRB7.set((value >> 18) & 1)
			ProcessorDisplayPanel_support.bPRB6.set((value >> 19) & 1)
			ProcessorDisplayPanel_support.bPRB5.set((value >> 20) & 1)
			ProcessorDisplayPanel_support.bPRB4.set((value >> 21) & 1)
			ProcessorDisplayPanel_support.bPRB3.set((value >> 22) & 1)
			ProcessorDisplayPanel_support.bPRB2.set((value >> 23) & 1)
			ProcessorDisplayPanel_support.bPRB1.set((value >> 24) & 1)
			ProcessorDisplayPanel_support.bPRBS.set((value >> 25) & 1)
		else:
			print("\nCPU status %03o %09o" % (channel, value))
	else:
		print("\nUnimplemented type %d, channel %03o, value %09o" % \
					(ioType, channel, value), end="  ")
	
	return

def pressedPROG_ERR(event):
	indicatorOn(top.PROG_ERR)

dcDisplayCount = 0
def changeDisplayMode(newDisplaySelect, newModeControl, \
					  newAddressCompare, other=False):
	global displaySelect, modeControl, addressCompare, displayModePayload,\
		   dcDisplayCount
	changed = False
	if other:
		changed = True
	else:
		if displaySelect != newDisplaySelect:
			print("Display select changed from %d to %d" % \
						(displaySelect, newDisplaySelect))
			displaySelect = newDisplaySelect
			changed = True
		if modeControl != newModeControl:
			print("Mode control changed from %d to %d" % \
						(modeControl, newModeControl))
			modeControl = newModeControl
			changed = True
			dcDisplayCount = 0
		if addressCompare != newAddressCompare:
			print("Address compare changed from %d to %d" % \
						(addressCompare, newAddressCompare))
			addressCompare = newAddressCompare
			indicatorSet(top.acINS, not addressCompare)
			indicatorSet(top.acDATA, addressCompare)
			changed = True
			dcDisplayCount = 0
	if changed:
		displayModePayload = (displaySelect & 3) << 4
		if addressCompare:
			displayModePayload |= 1 << 3
		displayModePayload |= modeControl & 7
		if top.mlREPEAT.itemcget(1, "state") == "normal":
			displayModePayload |= 1 << 6
		if top.CST.itemcget(1, "state") == "normal":
			displayModePayload |= 1 << 7
		if top.MAN_CST.itemcget(1, "state") == "normal":
			displayModePayload |= 1 << 8
		if top.trmcML.itemcget(1, "state") == "normal":
			displayModePayload |= 1 << 9
		if top.ACC_DISPLAY_ENABLE.itemcget(1, "state") == "normal":
			displayModePayload |= 1 << 10
		if top.pdpMEM_ADD_REG.itemcget(1, "state") == "normal":
			displayModePayload |= 1 << 11
		
def eventDisplaySelect():
	changeDisplayMode(ProcessorDisplayPanel_support.displaySelect.get(), \
					  modeControl, addressCompare)
def eventModeControl():
	changeDisplayMode(displaySelect, \
					  ProcessorDisplayPanel_support.modeControl.get(), \
					  addressCompare)
def eventAddressCompareInsData(event):
	changeDisplayMode(displaySelect, modeControl, not addressCompare)
ProcessorDisplayPanel_support.eventDisplaySelect = eventDisplaySelect
ProcessorDisplayPanel_support.eventModeControl = eventModeControl

##############################################################################
# Generic initialization (TCP socket setup).  Has no target-specific code, and 
# shouldn't need to be modified unless there are bugs.

import time
import socket

s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.setblocking(0)

newConnect = False
def connectToLVDC():
	global newConnect
	import sys
	count = 0
	sys.stderr.write("Connecting to LVDC/PTC emulator at %s:%d\n" % \
						(TCP_IP, TCP_PORT))
	while True:
		try:
			s.connect((TCP_IP, TCP_PORT))
			sys.stderr.write("Connected.\n")
			newConnect = True
			break
		except socket.error as msg:
			sys.stderr.write(str(msg) + "\n")
			count += 1
			if count >= 10:
				sys.stderr.write("Too many retries ...\n")
				time.sleep(3)
				sys.exit(1)
			time.sleep(1)

connectToLVDC()

###############################################################################
# Event loop.  Just check periodically for output from yaLVDC (in which case 
# the user-defined callback function outputFromCPU is executed) or data in the 
# user-defined function inputsForCPU (in which case a message is sent to 
# yaLVDC). But this section has no target-specific code, and shouldn't need to 
# be modified unless there are bugs.

# Given a 4-tuple (ioType,channel,value,mask), creates packet data and sends it 
# to yaLVDC.
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
	global didSomething, inputBuffer, leftToRead, view, terminalHeaderPrinted

	# Check for packet data received from yaLVDC and process it.
	# While these packets are always the same length in bytes,
	# since the socket is non-blocking any individual read
	# operation may yield less bytes than that, and the buffer may accumulate
	# data over time until it fills.	
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
					print("Illegal packet: %03o %03o %03o %03o %03o %03o" % \
							tuple(inputBuffer))
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
				if args.terminal:
					if not terminalHeaderPrinted:
						print("Dir\tIoType\tSource\tChannel\tData")
						terminalHeaderPrinted = True
					print(">\t%01o\t%01o\t%03o\t%09o" \
							% (ioType, source, channel, value))
				else:
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
indicatorInitialize(top.mlddPARITY_BIT, "PARITY\nBIT", PANEL_MLDD)
indicatorOn(top.mlddPARITY_BIT)
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
indicatorOn(top.pdpMEM_ADD_REG)
indicatorInitialize(top.pdpHOPSAVE_REG, "HOP\nSAVE\nREG", PANEL_PDP)
indicatorInitialize(top.pdpSYL0, "0", PANEL_PDP)
indicatorInitialize(top.pdpSYL1, "1", PANEL_PDP)
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
indicatorInitialize(top.trmcAUTO, "AUTO", PANEL_PDP)
indicatorInitialize(top.trmcMANUAL, "MANUAL", PANEL_PDP)
indicatorOn(top.trmcMANUAL)
indicatorInitialize(top.trmcML, "ML", PANEL_PDP)
indicatorInitialize(top.trmcDD, "DD", PANEL_PDP)
indicatorOn(top.trmcML)
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
# Note that iaCommandM0 is omitted from CC_COMMAND for the sake of 
# the SERIALIZER PARITY BIT.  It does not need to be in CC_COMMAND
# anyway, since resetting the COMMAND lamps does not clear it.
indicatorInitialize(top.iaCommandM0, "0", PANEL_MLDD)
indicatorOn(top.iaCommandM0)
indicatorInitialize(top.iaCommandM1, "1", PANEL_MLDD, cc=CC_COMMAND)
indicatorInitialize(top.iaCommandSYL0, "0", PANEL_MLDD)
# Note that iaCommandSYL0 is omitted from CC_COMMAND for the sake of 
# the SERIALIZER PARITY BIT.  It does not need to be in CC_COMMAND
# anyway, since resetting the COMMAND lamps does not clear it.
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
# Note that daCommandM0 is omitted from CC_COMMAND for the sake of 
# the SERIALIZER PARITY BIT.  It does not need to be in CC_COMMAND
# anyway, since resetting the COMMAND lamps does not clear it.
indicatorInitialize(top.daCommandM0, "0", PANEL_MLDD)
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
# The mlddPARITY_BIT indicator has to be initialized before all other
# CC_COMPUTER indicators, so I've moved it to the very top of the list.
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
indicatorInitialize(top.mlddCommandSYL0, "S\nY\n0", PANEL_MLDD)
indicatorInitialize(top.mlddCommandSYL1, "S\nY\n1", PANEL_MLDD)
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
indicatorInitialize(top.PARITY_TAPE, "TAPE", PANEL_MLDD)
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
indicatorInitialize(top.mlCOMPTR_DISPLAY_RESET, "COMPTR\nDISPLAY\nRESET", \
				    PANEL_MLDD)
indicatorInitialize(top.mlCOMMAND_DISPLAY_RESET, "COMMAND\nDISPLAY\nRESET", \
				    PANEL_MLDD)
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
top.ACC_DISPLAY_ENABLE.bind("<Button-1>", eventToggleIndicatorChange)
top.PROG_ERR.bind("<Button-1>", pressedPROG_ERR)
top.PROG_ERR.bind("<ButtonRelease-1>", eventIndicatorButtonRelease)
top.acINS.bind("<Button-1>", eventAddressCompareInsData)
top.acDATA.bind("<Button-1>", eventAddressCompareInsData)
top.pdpLAMP_TEST.bind("<Button-1>", eventPdpLampTest)
top.pdpLAMP_TEST.bind("<ButtonRelease-1>", eventPdpLampTestRelease)
top.mlddLAMP_TEST.bind("<Button-1>", eventMlddLampTest)
top.mlddLAMP_TEST.bind("<ButtonRelease-1>", eventMlddLampTestRelease)
top.ceLAMP_TEST.bind("<Button-1>", eventCeLampTest)
top.ceLAMP_TEST.bind("<ButtonRelease-1>", eventCeLampTestRelease)
top.trmcERROR_DEVICES_TEST.bind("<Button-1>", eventTrmcErrorDevicesTest)
top.trmcERROR_DEVICES_TEST.bind("<ButtonRelease-1>", \
							    eventIndicatorButtonRelease)
top.CST.bind("<Button-1>", eventToggleIndicatorChange)
top.MAN_CST.bind("<Button-1>", eventToggleIndicatorChange)
top.ADVANCE.bind("<Button-1>", eventAdvance)
top.ADVANCE.bind("<ButtonRelease-1>", eventIndicatorButtonRelease)
top.RESET_MACHINE.bind("<Button-1>", eventResetMachine)
top.RESET_MACHINE.bind("<ButtonRelease-1>", eventIndicatorButtonRelease)
top.HALT.bind("<Button-1>", eventHalt)
top.HALT.bind("<ButtonRelease-1>", eventIndicatorButtonRelease)
top.ERROR_RESET.bind("<Button-1>", eventErrorReset)
top.ERROR_RESET.bind("<ButtonRelease-1>", eventIndicatorButtonRelease)
top.mlREPEAT.bind("<Button-1>", eventRepeat)
top.mlREPEAT_INVERSE.bind("<Button-1>", eventRepeat)
top.mlADDRESS_CMPTR.bind("<Button-1>", eventAddressCmptr)
top.mlADDRESS_CMPTR.bind("<ButtonRelease-1>", eventIndicatorButtonRelease)
top.mlCOMPTR_DISPLAY_RESET.bind("<Button-1>", eventComptrDisplayReset)
top.mlCOMPTR_DISPLAY_RESET.bind("<ButtonRelease-1>", \
							    eventIndicatorButtonRelease)
top.mlCOMMAND_DISPLAY_RESET.bind("<Button-1>", eventCommandDisplayReset)
top.mlCOMMAND_DISPLAY_RESET.bind("<ButtonRelease-1>", \
								 eventIndicatorButtonRelease)
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
top.daCommandM0.bind("<Button-1>", eventToggleDaCommandM01)
top.daCommandM1.bind("<Button-1>", eventToggleDaCommandM01)
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
top.iaCommandSYL1.bind("<Button-1>", eventToggleIaCommandSYL01)
top.iaCommandSYL0.bind("<Button-1>", eventToggleIaCommandSYL01)
top.iaCommandM1.bind("<Button-1>", eventToggleIaCommandM01)
top.iaCommandM0.bind("<Button-1>", eventToggleIaCommandM01)
top.trmcML.bind("<Button-1>", eventMlDd)
top.trmcDD.bind("<Button-1>", eventMlDd)
top.pdpMEM_ADD_REG.bind("<Button-1>", eventMarHsr)
top.pdpHOPSAVE_REG.bind("<Button-1>", eventMarHsr)

# Create the extra windows for the printer, plotter, and typewriter
# peripherals.
if args.terminal:
	pass
else:
	printerWindow = printer(tk.Toplevel(root))
	printerWindow.text.tag_config("bg", background="#f8f8f8")
	typewriterWindow = typewriter(tk.Toplevel(root))
	typewriterWindow.text.tag_config("red", foreground="red")
	plotterWindow = plotter(tk.Toplevel(root))
# Note that the "printer" and "typewriter" classes use widgets of type 
# ScrolledText and ScrolledWindow, which are not native tkinter widgets, 
# but rather are classes created by the PAGE tool I use to help design 
# the UI.  Unfortunately, PAGE will not define the ScrolledText or 
# ScrolledWindow classes (in ProcessorDisplayPanel.py) unless it thinks 
# there are actually widgets of those types in the design, so I trick
# PAGE by adding dummy widgets (called "dummyScrolledWindow" and
# "dummyScrolledText") just outside the edge of the main maindow, where
# they're not normally visible.  The following line is to try and insure
# that they remains invisible if the main window were resized by the user.
# Sometimes, though, I remove the dummy widgets manually, so the we
# also have to allow for the possibility that the widgets aren't there at all.
try:
	top.dummyScrolledText.pack_forget()
	top.dummyScrolledWindow.pack_forget()
except:
	pass

root.resizable(resize, resize)
root.after(refreshRate, mainLoopIteration)
root.mainloop()
