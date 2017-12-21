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
	lastTime = datetime.datetime.now()

if args.gps or args.imu:
	import time
	import pigpio
	import os
	from LSM9DS0 import *
	G_GAIN = 0.070 # Scaler (convert gyro readings to deg/s)
	print("CTRL_REG1_XM = " + str(CTRL_REG1_XM))
	# Start the PIGPIO server.  If already running, this operation is harmless
	# and will just fall through.
	os.system("sudo pigpiod &") 
	time.sleep(2) # Make sure it's started before proceeding.
	gpio = pigpio.pi() # Initialize the connection to the PIGPIO server.
	if not gpio.connected:
		sys.stderr.write("Cannot connect to PIGPIO server.\n")
		time.sleep(5)
		os.exit(1)

if args.imu:
	import math
	from ctypes import c_short
	# The sensitivity of the acceleration measurement.  The choices for LA_FS are
	# 2, 4, 6, 8, or 16, where +/- LA_FS is the full-scale measurement range.
	# Thus, 2 is the most-sensitive, but will overflow above 2g.  Similarly,
	# 16g is unlikely to overflow, but has nearly 10 times the error.
	LA_FS = 2
	LA_So = LA_FS * 1.0 / 0x8000 # G per step, since an int16 is read back.
	g = 9806.65 # 1g in cm per second per second.
	mssPerStep = LA_So * g # meters per second per second per step.
	# Magnetometer sensitivity.  Choices are 2, 4, 8, or 12 for +/-M_FS full
	# scale.
	M_FS = 2
	M_GN = M_FS * 0.04 # mgauss per step.
	pressureAddress = 0x77
	i2cBusNumber = 1
	oversampling = 3
	def writeRegByteI2c(address, reg, value):
		global gpio
		i2cBusHandle = gpio.i2c_open(i2cBusNumber, address, 0)
		if i2cBusHandle < 0:
			return False
		gpio.i2c_write_byte_data(i2cBusHandle, reg, value)
		gpio.i2c_close(i2cBusHandle)
		return True
	def toInt16(lsb, msb):
		returnValue = lsb | (msb << 8)
		if 0 != (returnValue & 0x8000):
			returnValue |= ~0xFFFF
		return returnValue
	def toInt12(lsb, msb):
		returnValue = lsb | (msb << 8)
		if 0 != (returnValue & 0x800):
			returnValue |= ~0xFFF
		return returnValue
	def readBlock(address, out_x_l, desiredCount): 
		global gpio
		i2cBusHandle = gpio.i2c_open(i2cBusNumber, address, 0)
		if i2cBusHandle < 0:
			return False
		(count, array) = gpio.i2c_read_i2c_block_data(i2cBusHandle, 0x80 | out_x_l, desiredCount)
		gpio.i2c_close(i2cBusHandle)
		if count != desiredCount:
			return False
		return array
	def readXYZ(address, out_x_l): 
		array = readBlock(address, out_x_l, 6)
		if array == False:
			return False
		x = toInt16(array[0], array[1])
		y = toInt16(array[2], array[3])
		z = toInt16(array[4], array[5])
		return { "x": x, "y": y, "z": z }
	def readLH12(address, out_x_l): 
		array = readBlock(address, out_x_l, 2)
		if array == False:
			return False
		return toInt12(array[0], array[1])
	# Enable accelerometer: z,y,x enabled, block update, 100Hz data rate, +/- 16G full scale.
	ctrlReg2XmValue = 0b00000000
	if LA_FS == 2:
		ctrlReg2XmValue |= 0b000 << 3
	elif LA_FS == 4:
		ctrlReg2XmValue |= 0b001 << 3
	elif LA_FS == 6:
		ctrlReg2XmValue |= 0b010 << 3
	elif LA_FS == 8:
		ctrlReg2XmValue |= 0b011 << 3
	elif LA_FS == 16:
		ctrlReg2XmValue |= 0b100 << 3
	if not writeRegByteI2c(ACC_ADDRESS, CTRL_REG1_XM, 0b01101111) or \
	   not writeRegByteI2c(ACC_ADDRESS, CTRL_REG2_XM, ctrlReg2XmValue): 
		sys.stderr.write("Could not initialize accelerometer sensor.\n")
		time.sleep(5)
		os.exit(1)
	# Enable the magnetometer: Temp enable, M data rate = 50Hz, +/-12gauss, Continuous-conversion mode
	ctrlReg6XmValue = 0b00000000
	if M_FS == 2:
		ctrlReg6XmValue |= 0b00 << 5
	elif M_FS == 4:
		ctrlReg6XmValue |= 0b01 << 5
	elif M_FS == 8:
		ctrlReg6XmValue |= 0b10 << 5
	elif M_FS == 12:
		ctrlReg6XmValue |= 0b11 << 5
	if not writeRegByteI2c(MAG_ADDRESS, CTRL_REG5_XM, 0b11110000) or \
	   not writeRegByteI2c(MAG_ADDRESS, CTRL_REG6_XM, ctrlReg6XmValue) or \
	   not writeRegByteI2c(MAG_ADDRESS, CTRL_REG7_XM, 0b00000000): 
		sys.stderr.write("Could not initialize magnetometer sensor.\n")
		time.sleep(5)
		os.exit(1)
	# Enable Gyro: Normal power mode, all axes enabled, continuous update, 2000 dps full scale
	if not writeRegByteI2c(GYR_ADDRESS, CTRL_REG1_G, 0b00001111) or \
	   not writeRegByteI2c(GYR_ADDRESS, CTRL_REG4_G, 0b00110000): 
		sys.stderr.write("Could not initialize accelerometer sensor.\n")
		time.sleep(5)
		os.exit(1)
        
        # For BMP180, get calibration data.
	# return two bytes from data as a signed 16-bit value
	def get_short(data, index):
		return c_short((data[index] << 8) + data[index + 1]).value
	# return two bytes from data as an unsigned 16-bit value
	def get_ushort(data, index):
		return (data[index] << 8) + data[index + 1]
	cal = readBlock(pressureAddress, 0xAA, 22)
	if cal == False:
		sys.stderr.write("Cannot get BMP180 calibration data\n");
		sys.exit(1)
	ac1 = get_short(cal, 0)
	ac2 = get_short(cal, 2)
	ac3 = get_short(cal, 4)
	ac4 = get_ushort(cal, 6)
	ac5 = get_ushort(cal, 8)
	ac6 = get_ushort(cal, 10)
	b1 = get_short(cal, 12)
	b2 = get_short(cal, 14)
	mb = get_short(cal, 16)
	mc = get_short(cal, 18)
	md = get_short(cal, 20)
	
        # A test.
	while True:
		# Get acc, mag, gyro, and temperature from LSM9DS0.
		acc = readXYZ(ACC_ADDRESS, OUT_X_L_A)
		acc["x"] *= mssPerStep
		acc["y"] *= mssPerStep
		acc["z"] *= mssPerStep
		acc["total"] = math.sqrt(acc["x"]*acc["x"] + acc["y"]*acc["y"] + acc["z"]*acc["z"])
		mag = readXYZ(MAG_ADDRESS, OUT_X_L_M)
		mag["x"] *= M_GN
		mag["y"] *= M_GN
		mag["z"] *= M_GN
		gyro = readXYZ(GYR_ADDRESS, OUT_X_L_G)
		gyro["x"] *= G_GAIN
		gyro["y"] *= G_GAIN
		gyro["z"] *= G_GAIN
		temperature = readLH12(MAG_ADDRESS, OUT_TEMP_L_XM) # temperature in unspecified units
		
		# Get temperature and pressure from BMP180.
		writeRegByteI2c(pressureAddress, 0xF4, 0x2E)
		time.sleep(0.005)
		(msb, lsb) = readBlock(pressureAddress, 0xF6, 2)
		ut = (msb << 8) + lsb
		writeRegByteI2c(pressureAddress, 0xF4, 0x34 + (oversampling << 6))
		time.sleep(0.05)
		(msb, lsb, xsb) = readBlock(pressureAddress, 0xF6, 3)
		up = ((msb << 16) + (lsb << 8) + xsb) >> (8 - oversampling)
		
		# Compute calibrated BMP180 temp and pressure from uncalibrated readings.
		x1 = ((ut - ac6) * ac5) >> 15
		x2 = round((mc << 11) / (x1 + md))
		b5 = x1 + x2 
		temperature2 = ((b5 + 8) >> 4) / 10.0 # temperature in C
		b6 = b5 - 4000
		b62 = (b6 * b6) >> 12
		x1 = (b2 * b62) >> 11
		x2 = (ac2 * b6) >> 11
		x3 = x1 + x2
		b3 = (((ac1 * 4 + x3) << oversampling) + 2) >> 2
		x1 = (ac3 * b6) >> 13
		x2 = (b1 * b62) >> 16
		x3 = ((x1 + x2) + 2) >> 2
		b4 = (ac4 * (x3 + 32768)) >> 15
		b7 = (up - b3) * (50000 >> oversampling)
		p = round((b7 * 2) / b4)
		x1 = (p >> 8) * (p >> 8)
		x1 = (x1 * 3038) >> 16
		x2 = (-7357 * p) >> 16
		pressure = (p + ((x1 + x2 + 3791) >> 4)) / 100.0 # in hPa
		
		print("")
		print("acc = " + str(acc))
		print("mag = " + str(mag))
		print("gyro = " + str(gyro))
		print("temp = " + str(temperature))
		print("temp2 = " + str(temperature2))
		print("pressure = " + str(pressure))
		time.sleep(1)

###################################################################################
# Hardware abstraction / User-defined functions.  Also, any other platform-specific
# initialization.  This is the section to customize for specific applications.

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
	# like it.  It's not necessary for the functioning of this program.
	if args.time:
		global lastTime
		now = datetime.datetime.now()
		if now.second != lastTime.second:
			lastTime = now
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
		