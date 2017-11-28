#!/usr/bin/python3
# Simulates V35E and various other DSKY keypad commands repeatedly until stopped.

print("Focus the 272x480 window within the next 5 seconds!")

# Must do "sudo modprobe uinput" before running this program.  There's also
# a one-time setup of "sudo pip3 install python-uinput".  This program itself 
# must be run as "sudo ./automateV35.py".  "V35E" goes into whatever window
# has the focus, so you have to move the cursor into the 272x480 DSKY display
# and focus it before you'll see anything happen.
import uinput
import time

device = uinput.Device([
	uinput.KEY_V,
	uinput.KEY_N,
	uinput.KEY_0,
	uinput.KEY_1,
	uinput.KEY_2,
	uinput.KEY_3,
	uinput.KEY_4,
	uinput.KEY_5,
	uinput.KEY_6,
	uinput.KEY_7,
	uinput.KEY_8,
	uinput.KEY_9,
	uinput.KEY_ENTER
])

interKeyDelay = 0.25
time.sleep(5)
count = 0
while True:
	count += 1
	print("Count " + str(count))
	
	print("\tV35E")
	device.emit_click(uinput.KEY_V)
	time.sleep(interKeyDelay)
	device.emit_click(uinput.KEY_3)
	time.sleep(interKeyDelay)
	device.emit_click(uinput.KEY_5)
	time.sleep(interKeyDelay)
	device.emit_click(uinput.KEY_ENTER)
	time.sleep(7)
	
	print("\tV37E00E")
	device.emit_click(uinput.KEY_V)
	time.sleep(interKeyDelay)
	device.emit_click(uinput.KEY_3)
	time.sleep(interKeyDelay)
	device.emit_click(uinput.KEY_7)
	time.sleep(interKeyDelay)
	device.emit_click(uinput.KEY_ENTER)
	time.sleep(interKeyDelay)
	device.emit_click(uinput.KEY_0)
	time.sleep(interKeyDelay)
	device.emit_click(uinput.KEY_0)
	time.sleep(interKeyDelay)
	device.emit_click(uinput.KEY_ENTER)
	time.sleep(3)
	
	print("\tV91E")
	device.emit_click(uinput.KEY_V)
	time.sleep(interKeyDelay)
	device.emit_click(uinput.KEY_9)
	time.sleep(interKeyDelay)
	device.emit_click(uinput.KEY_1)
	time.sleep(interKeyDelay)
	device.emit_click(uinput.KEY_ENTER)
	time.sleep(4)
	
	for i in range(0, 5):
		print("\tV33E")
		device.emit_click(uinput.KEY_V)
		time.sleep(interKeyDelay)
		device.emit_click(uinput.KEY_3)
		time.sleep(interKeyDelay)
		device.emit_click(uinput.KEY_3)
		time.sleep(interKeyDelay)
		device.emit_click(uinput.KEY_ENTER)
		time.sleep(4)
	
	print("\tV34E")
	device.emit_click(uinput.KEY_V)
	time.sleep(interKeyDelay)
	device.emit_click(uinput.KEY_3)
	time.sleep(interKeyDelay)
	device.emit_click(uinput.KEY_4)
	time.sleep(interKeyDelay)
	device.emit_click(uinput.KEY_ENTER)
	time.sleep(3)
	
	print("\tV16N65E")
	device.emit_click(uinput.KEY_V)
	time.sleep(interKeyDelay)
	device.emit_click(uinput.KEY_1)
	time.sleep(interKeyDelay)
	device.emit_click(uinput.KEY_6)
	time.sleep(interKeyDelay)
	device.emit_click(uinput.KEY_N)
	time.sleep(interKeyDelay)
	device.emit_click(uinput.KEY_6)
	time.sleep(interKeyDelay)
	device.emit_click(uinput.KEY_5)
	time.sleep(interKeyDelay)
	device.emit_click(uinput.KEY_ENTER)
	time.sleep(10)
