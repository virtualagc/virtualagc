#!/usr/bin/python3
# Copyright:	None, placed in the PUBLIC DOMAIN by its author (Ron Burkey)
# Filename: 	piPeripheral.py
# Purpose:	This is the skeleton of a program that can be used for creating
#		a Python-language based peripheral for the AGC or AGS simulator program,
#		yaAGC or yaAGS.  You can see an example of how to use it in piDSKY.py.  
# Reference:	http://www.ibiblio.org/apollo/developer.html
# Mod history:	2017-11-17 RSB	Began.
#		2017-12-02 RSB	Added --ags.
#		2017-12-08 RSB	Added --time.  Changed the default port from 19[67]98 to 
#				19[67]99, so as not to collide with the default port
#				piDSKY2.py uses.
#		2017-12-17 RSB	Began adding --gps and --imu features, but it doesn't
#				do anything as of yet.
#
# The parts which need to be modified to be target-system specific are the 
# outputFromAGx() and inputsForAGx() functions.
#
# To run the program in its present form, assuming you had a directory setup in 
# which all of the appropriate files could be found, you could run (presumably 
# from different consoles)
#
#	yaAGC --core=Luminary099.bin --port=19797 --cfg=LM.ini
#	piPeripheral.py
#
# The --gps and --imu features assume an appropriate BerryGPS or BerryGPS-IMU device 
# (see http://ozzmaker.com/berrygps-berrygps-imu-quick-start-guide/).
# For the --gps and --imu features to work (Pi only!), it's necessary to first use "sudo raspi-config"
# to set the "interfacing options" so that:
#
#	For --imu: i2c is enabled
#	For --gps: serial console is disabled and serial hardware is enabled. These are actually the same
#		   interfacing option on the --raspi-config menu, but you have to answer two separate prompts.
#
# The --gps and --imu features also rely on pigpio, so that has to be installed as well:
#
#	sudo apt-get install pigpio python3-pigpio
#
# Note that because pigpio relies on a client/server architecture and it is only the server that interacts
# with the (locked) gpio hardware, rather than the client, this does not conflict with other software such
# as piDSKY2.py already interacting with the GPIO using the pigpio method.  However, it may conflict with
# other GPIO-interfacing programs that expect to have an exclusive lock on the hardware.

# Parse command-line arguments.
import argparse
cli = argparse.ArgumentParser()
cli.add_argument("--host", help="Host address of yaAGC/yaAGS, defaulting to localhost.")
cli.add_argument("--port", help="Port for yaAGC/yaAGS, defaulting to 19799 for AGC or 19899 for AGS.", type=int)
cli.add_argument("--slow", help="For use on really slow host systems.")
cli.add_argument("--ags", help="For use with yaAGS (defaults to yaAGC).")
cli.add_argument("--time", help="Demo current date/time on AGC input channels 040-042.")
cli.add_argument("--gps", help="Demo current GPS data on AGC, using a BerryGPS or BerryGPS-IMU.")
cli.add_argument("--imu", help="Demo current IMU data on AGC, using a BerryGPS-IMU.")
cli.add_argument("--imudebug", help="Simply print out --imu reading, without using AGC.")
args = cli.parse_args()

if args.ags:
	host="AGS"
else:
	host="AGC"

# Responsiveness settings.
if args.slow:
	PULSE = 0.25
else:
	PULSE = 0.05

# Characteristics of the host and port being used for yaAGC/yaAGS communications.  
if args.host:
	TCP_IP = args.host
else:
	TCP_IP = 'localhost'
if args.port:
	TCP_PORT = args.port
elif args.ags:
	TCP_PORT = 19699
else:
	TCP_PORT = 19799

if args.time:
	import datetime
	lastTimeTIME = datetime.datetime.now()

if args.gps:
	from LSM9DS0 import *
	import datetime
	lastTimeGPS = datetime.datetime.now()

if args.imu:
	from BMP280 import *
	import datetime
	lastTimeIMU = datetime.datetime.now()
	
	# A test.
	if args.imudebug:
		while True:
			# Read stuff from LSM9DS0.
			acc = readAccelerometer()
			mag = readMagnetometer()
			gyro = readGyro()
			
			# Read stuff from BMP180.
			temperature, pressure = readTemperatureAndPressure()
					
			print("")
			print("acc = " + str(acc))
			print("mag = " + str(mag))
			print("gyro = " + str(gyro))
			print("temp = " + str(temperature))
			print("pressure = " + str(pressure))
			time.sleep(1)

###################################################################################
# Hardware abstraction / User-defined functions.  Also, any other platform-specific
# initialization.  This is the section to customize for specific applications.

# Convert an integer to 15-bit 1's-complement.  If the value doesn't fit into 15
# bits ... well, then, too bad!
def toOnesComplement(value):
	if value < 0:
		value -= 1
	return value & 0o77777

# This function is automatically called periodically by the event loop to check for 
# conditions that will result in sending messages to yaAGC/yaAGS that are interpreted
# as changes to bits on its input channels.  The return
# value is supposed to be a list of 3-tuples of the form
#	[ (channel0,value0,mask0), (channel1,value1,mask1), ...]
# for AGC, or 
#	[ (channel0,value0), (channel1,value1), ...]
# for AGS, and may be an empty list.  The "values" are written to the AGC/AGS's input "channels",
# while the "masks" tell which bits of the "values" are valid.  (The AGC will ignore
# the invalid bits.  We don't need such masks for AGS.)
def inputsForAGx():
	returnValue = []

	# Just a demo ... supplies current date/time to AGC on input channels 040-042.
	# Delete everything associated with args.time (here and above) if you don't
	# like --time.  It's not necessary for the generic functioning of this program.
	if args.time:
		global lastTimeTIME
		now = datetime.datetime.now()
		if now.second != lastTimeTIME.second:
			lastTimeTIME = now
			# Pack the values for transmission.
			minutesSeconds = (now.minute << 6) | (now.second)
			monthsDaysHours = (now.month << 10) | (now.day << 5) | (now.hour)
			# The values are all positive, so the 1's complement
			# and 2's complement representations are the same.
			# The AGC should poll these until channel 040 changes,
			# and then should immediately read the other ports
			# (which are guaranteed not to change for at least a minute
			# after 040 does).
			returnValue.append( ( 0o42, now.year, 0o77777) )
			returnValue.append( ( 0o41, monthsDaysHours, 0o77777) )
			returnValue.append( ( 0o40, minutesSeconds, 0o77777) )
	
	# Just a demo ... supplies current BerryGPS-IMU data to AGC on input channels
	# 051-066.  The values (all 1's-complement) supplied are:
	#	051	x-acceleration in units of mm/sec/sec
	#	052	y-acceleration in units of mm/sec/sec
	#	053	z-acceleration in units of mm/sec/sec
	#	054	x magnetic field in units of 0.0001 gauss
	#	055	y magnetic field in units of 0.0001 gauss
	#	056	z magnetic field in units of 0.0001 gauss
	#	057	x gyro in units of 0.1 degrees per second
	#	060	y gyro in units of 0.1 degrees per second
	#	061	z gyro in units of 0.1 degrees per second
	#	062	Barometric pressure in units of 0.1 hPa
	#	063	Temperature in units of 0.01 degrees C
	#	064	Latitude in units of 0.01 degrees
	#	065	Longitude in units of 0.01 degrees
	#	066	Altitude in units of meters
	#	067	Groundspeed in units of kph
	#	070	Direction relative to true North, 0.1 degrees
	# Delete everything associated with args.imu (here and above) if you don't
	# like --imu.  It's not necessary for the generic functioning of this program.
	if args.imu:
		global lastTimeIMU
		now = datetime.datetime.now()
		if now.second != lastTimeIMU.second:
			lastTimeIMU = now
			
			# Read stuff from LSM9DS0.
			acc = readAccelerometer()
			mag = readMagnetometer()
			gyro = readGyro()
			
			# Read stuff from BMP180.
			temperature, pressure = readTemperatureAndPressure()
			
			# Convert the stuff we just read to 1's-complement.
			for i in ("x", "y", "z"):
				acc[i] = toOnesComplement(round(1000*acc[i]))
				mag[i] = toOnesComplement(round(10000*mag[i]))
				gyro[i] = toOnesComplement(round(10*gyro[i]))
			pressure = toOnesComplement(round(10*pressure))
			temperature = toOnesComplement(round(100*temperature))
			
			# Pack the values for transmission.
			returnValue.append( ( 0o51, acc["x"], 0o77777) )
			returnValue.append( ( 0o52, acc["y"], 0o77777) )
			returnValue.append( ( 0o53, acc["z"], 0o77777) )
			returnValue.append( ( 0o54, mag["x"], 0o77777) )
			returnValue.append( ( 0o55, mag["y"], 0o77777) )
			returnValue.append( ( 0o56, mag["z"], 0o77777) )
			returnValue.append( ( 0o57, gyro["x"], 0o77777) )
			returnValue.append( ( 0o60, gyro["y"], 0o77777) )
			returnValue.append( ( 0o61, gyro["z"], 0o77777) )
			returnValue.append( ( 0o62, pressure, 0o77777) )
			returnValue.append( ( 0o63, temperature, 0o77777) )
	# Delete everything associated with args.gps (here and above) if you don't
	# like --gps.  It's not necessary for the generic functioning of this program.
	if args.gps:
		global lastTimeGPS
		now = datetime.datetime.now()
		if now.second != lastTimeGPS.second:
			lastTimeGPS = now
			# Pack the values for transmission.
			# ... TBD ...
	
	return returnValue

# This function is called by the event loop only when yaAGC has written
# to an output channel.  The function should do whatever it is that needs to be done
# with this output data, which is not processed additionally in any way by the 
# generic portion of the program.
def outputFromAGx(channel, value):

	# Just a demo:  prints some stuff output on channels 043-050. Remove at will!
	if args.time: 
		# We happen to know (from having written the AGC code!) that
		# channel 043 is changed first, so we can confidently insert a
		# newline there to make the printout prettier.
		if channel == 0o43:
			print("\nYear = " + str(value))
		elif channel == 0o44:
			print("Month = " + str(value))
		elif channel == 0o45:
			print("Day = " + str(value))
		elif channel == 0o46:
			print("Hour = " + str(value))
		elif channel == 0o47:
			print("Minute = " + str(value))
		elif channel == 0o50:
			print("Second = " + str(value))
	
	return

###################################################################################
# Generic initialization (TCP socket setup).  Has no target-specific code, and 
# shouldn't need to be modified unless there are bugs.

import time
import socket

s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.setblocking(0)

def connectToAGC():
	while True:
		try:
			s.connect((TCP_IP, TCP_PORT))
			print("Connected to ya" + host + " (" + TCP_IP + ":" + str(TCP_PORT) + ")")
			break
		except socket.error as msg:
			print("Could not connect to ya" + host + " (" + TCP_IP + ":" + str(TCP_PORT) + "), exiting: " + str(msg))
			time.sleep(1)

connectToAGC()

###################################################################################
# Event loop.  Just check periodically for output from yaAGC (in which case the
# user-defined callback function outputFromAGx is executed) or data in the 
# user-defined function inputsForAGx (in which case a message is sent to yaAGC).
# But this section has no target-specific code, and shouldn't need to be modified
# unless there are bugs.

# Given a 3-tuple (channel,value,mask) for yaAGC, creates packet data and sends it to yaAGC.
# Or, given a 2-tuple (channel,value) for yaAGS, creates packet data and sends it to yaAGS.
def packetize(tuple):
	outputBuffer = bytearray(4)
	if args.ags:
		outputBuffer[0] = 0x00 | (tuple[0] & 0x3F)
		outputBuffer[1] = 0xC0 | ((tuple[0] >> 12) & 0x3F)
		outputBuffer[2] = 0x80 | ((tuple[1] >> 6) & 0x3F)
		outputBuffer[3] = 0x40 | (tuple[1] & 0x3F)
		s.send(outputBuffer)
	else:
		# First, create and output the mask command.
		outputBuffer[0] = 0x20 | ((tuple[0] >> 3) & 0x0F)
		outputBuffer[1] = 0x40 | ((tuple[0] << 3) & 0x38) | ((tuple[2] >> 12) & 0x07)
		outputBuffer[2] = 0x80 | ((tuple[2] >> 6) & 0x3F)
		outputBuffer[3] = 0xC0 | (tuple[2] & 0x3F)
		s.send(outputBuffer)
		# Now, the actual data for the channel.
		outputBuffer[0] = 0x00 | ((tuple[0] >> 3) & 0x0F)
		outputBuffer[1] = 0x40 | ((tuple[0] << 3) & 0x38) | ((tuple[1] >> 12) & 0x07)
		outputBuffer[2] = 0x80 | ((tuple[1] >> 6) & 0x3F)
		outputBuffer[3] = 0xC0 | (tuple[1] & 0x3F)
		s.send(outputBuffer)

# Buffer for a packet received from yaAGC/yaAGS.
packetSize = 4
inputBuffer = bytearray(packetSize)
leftToRead = packetSize
view = memoryview(inputBuffer)

didSomething = False
while True:
	if not didSomething:
		time.sleep(PULSE)
	didSomething = False
	
	# Check for packet data received from yaAGC/yaAGS and process it.
	# While these packets are always exactly 4
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
			if args.ags:
				if (inputBuffer[0] & 0xC0) != 0x00:
					ok = 0
				elif (inputBuffer[1] & 0xC0) != 0xC0:
					ok = 0
				elif (inputBuffer[2] & 0xC0) != 0x80:
					ok = 0
				elif (inputBuffer[3] & 0xC0) != 0x40:
					ok = 0
			else:
				if (inputBuffer[0] & 0xF0) != 0x00:
					ok = 0
				elif (inputBuffer[1] & 0xC0) != 0x40:
					ok = 0
				elif (inputBuffer[2] & 0xC0) != 0x80:
					ok = 0
				elif (inputBuffer[3] & 0xC0) != 0xC0:
					ok = 0
			# Packet has the various signatures we expect.
			if ok == 0:
				# Note that, depending on the yaAGC/yaAGS version, it occasionally
				# sends either a 1-byte packet (just 0xFF, older versions)
				# or a 4-byte packet (0xFF 0xFF 0xFF 0xFF, newer versions)
				# just for pinging the client.  These packets hold no
				# data and need to be ignored, but for other corrupted packets
				# we print a message. And try to realign past the corrupted
				# bytes.
				if inputBuffer[0] != 0xff or inputBuffer[1] != 0xff or inputBuffer[2] != 0xff or inputBuffer[2] != 0xff:
					if inputBuffer[0] != 0xff:
						print("Illegal packet: " + hex(inputBuffer[0]) + " " + hex(inputBuffer[1]) + " " + hex(inputBuffer[2]) + " " + hex(inputBuffer[3]))
					for i in range(1,packetSize):
						if (inputBuffer[i] & 0xC0) == 0:
							j = 0
							for k in range(i,4):
								inputBuffer[j] = inputBuffer[k]
								j += 1
							view = view[j:]
							leftToRead = packetSize - j
			elif args.ags:
				channel = (inputBuffer[0] & 0x3F)
				value = (inputBuffer[1] & 0x3F) << 12
				value |= (inputBuffer[2] & 0x3F) << 6
				value |= (inputBuffer[3] & 0x3F)
				outputFromAGx(channel, value)
			else:
				channel = (inputBuffer[0] & 0x0F) << 3
				channel |= (inputBuffer[1] & 0x38) >> 3
				value = (inputBuffer[1] & 0x07) << 12
				value |= (inputBuffer[2] & 0x3F) << 6
				value |= (inputBuffer[3] & 0x3F)
				outputFromAGx(channel, value)
			didSomething = True
	
	# Check for locally-generated data for which we must generate messages
	# to yaAGC over the socket.  In theory, the externalData list could contain
	# any number of channel operations, but in practice (at least for something
	# like a DSKY implementation) it will actually contain only 0 or 1 operations.
	externalData = inputsForAGx()
	for i in range(0, len(externalData)):
		packetize(externalData[i])
		didSomething = True
		