#!/usr/bin/python3
# Simulates V35E being pressed repeatedly, every 10 seconds, indefinitely, until stopped.

# Must do "sudo modprobe uinput" before running this program.  There's also
# a one-time setup of "sudo pip3 install python-uinput".  This program itself 
# must be run as "sudo ./automateV35.py".  "V35E" goes into whatever window
# has the focus, so you have to move the cursor into the 272x480 DSKY display
# and focus it before you'll see anything happen.
import uinput
import time

device = uinput.Device([
	uinput.KEY_V,
	uinput.KEY_3,
	uinput.KEY_5,
	uinput.KEY_ENTER
])

interKeyDelay = 0.1
interCmdDelay = 8
time.sleep(1)
count = 0
while True:
	print("V35 count " + str(count))
	count += 1
	device.emit_click(uinput.KEY_V)
	time.sleep(interKeyDelay)
	device.emit_click(uinput.KEY_3)
	time.sleep(interKeyDelay)
	device.emit_click(uinput.KEY_5)
	time.sleep(interKeyDelay)
	device.emit_click(uinput.KEY_ENTER)
	time.sleep(interCmdDelay)
	
