#!/usr/bin/python3
# Simulates V35E being pressed repeatedly, every 10 seconds, indefinitely, until stopped.

# Must do "sudo modprobe uinput" before running this program.  There's also
# a one-time setup of "sudo pip3 install python-uinput".
import uinput
import time

device = uinput.Device([
	uinput.KEY_V,
	uinput.KEY_3,
	uinput.KEY_5,
	uinput.KEY_ENTER
])

time.sleep(1)
count = 0
while True:
	print("V35 count " + str(count))
	count += 1
	device.emit_click(uinput.KEY_V)
	time.sleep(0.25)
	device.emit_click(uinput.KEY_3)
	time.sleep(0.25)
	device.emit_click(uinput.KEY_5)
	time.sleep(0.25)
	device.emit_click(uinput.KEY_ENTER)
	time.sleep(10)
	
