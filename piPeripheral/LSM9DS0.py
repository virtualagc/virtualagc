#!/usr/bin/python3
# Copyright:	None, placed in the PUBLIC DOMAIN by its author (Ron Burkey)
# Filename: 	LSM9DS0.py
# Purpose:	This code reads accelerometer, magnetometer, gyro, and temperature
#		info from an LSM9DS0 device.  It assumes the device is on a 
#		BerryGPS or BerryGPS-IMU device attached to a Raspberry Pi.  
#		But its main purpose is not to fully implement all of the LSM9DS0
#		functionality, but merely to support the sample piPeripheral.py 
#		and piPeripheral.agc programs, so beware!  I stopped working with
#		it as soon as I was satisfied with those.
# Mod history:	2017-12-23 RSB	Began.

# If this module is already loaded, the "try" below will succeed
# and we'll do nothing.  If not, then it will fall through to
# the "except" and we'll actually do something!
try:
	
	dummy = LSM9DS0_LOADED
	
except NameError:

	import time
	import pigpio
	import os
	import math
	
	# Start the PIGPIO server.  If already running, this operation is harmless
	# and will just fall through.
	os.system("sudo pigpiod &") 
	time.sleep(2) # Make sure it's started before proceeding.
	gpio = pigpio.pi() # Initialize the connection to the PIGPIO server.
	if not gpio.connected:
		sys.stderr.write("Cannot connect to PIGPIO server.\n")
		time.sleep(5)
		os.exit(1)
	
	MAG_ADDRESS = 0x1E
	ACC_ADDRESS = 0x1E
	GYR_ADDRESS = 0x6A
	
	# /** LSM9DS0 Gyro Registers **/
	WHO_AM_I_G = 0x0F
	CTRL_REG1_G = 0x20
	CTRL_REG2_G = 0x21
	CTRL_REG3_G = 0x22
	CTRL_REG4_G = 0x23
	CTRL_REG5_G = 0x24
	REFERENCE_G = 0x25
	STATUS_REG_G = 0x27
	OUT_X_L_G = 0x28
	OUT_X_H_G = 0x29
	OUT_Y_L_G = 0x2A
	OUT_Y_H_G = 0x2B
	OUT_Z_L_G = 0x2C
	OUT_Z_H_G = 0x2D
	FIFO_CTRL_REG_G = 0x2E
	FIFO_SRC_REG_G = 0x2F
	INT1_CFG_G = 0x30
	INT1_SRC_G = 0x31
	INT1_THS_XH_G = 0x32
	INT1_THS_XL_G = 0x33
	INT1_THS_YH_G = 0x34
	INT1_THS_YL_G = 0x35
	INT1_THS_ZH_G = 0x36
	INT1_THS_ZL_G = 0x37
	INT1_DURATION_G = 0x38
	
	# //////////////////////////////////////////
	# // LSM9DS0 Accel/Magneto (XM) Registers //
	# //////////////////////////////////////////
	OUT_TEMP_L_XM = 0x05
	OUT_TEMP_H_XM = 0x06
	STATUS_REG_M = 0x07
	OUT_X_L_M = 0x08
	OUT_X_H_M = 0x09
	OUT_Y_L_M = 0x0A
	OUT_Y_H_M = 0x0B
	OUT_Z_L_M = 0x0C
	OUT_Z_H_M = 0x0D
	WHO_AM_I_XM = 0x0F
	INT_CTRL_REG_M = 0x12
	INT_SRC_REG_M = 0x13
	INT_THS_L_M = 0x14
	INT_THS_H_M = 0x15
	OFFSET_X_L_M = 0x16
	OFFSET_X_H_M = 0x17
	OFFSET_Y_L_M = 0x18
	OFFSET_Y_H_M = 0x19
	OFFSET_Z_L_M = 0x1A
	OFFSET_Z_H_M = 0x1B
	REFERENCE_X = 0x1C
	REFERENCE_Y = 0x1D
	REFERENCE_Z = 0x1E
	CTRL_REG0_XM = 0x1F
	CTRL_REG1_XM = 0x20
	CTRL_REG2_XM = 0x21
	CTRL_REG3_XM = 0x22
	CTRL_REG4_XM = 0x23
	CTRL_REG5_XM = 0x24
	CTRL_REG6_XM = 0x25
	CTRL_REG7_XM = 0x26
	STATUS_REG_A = 0x27
	OUT_X_L_A = 0x28
	OUT_X_H_A = 0x29
	OUT_Y_L_A = 0x2A
	OUT_Y_H_A = 0x2B
	OUT_Z_L_A = 0x2C
	OUT_Z_H_A = 0x2D
	FIFO_CTRL_REG = 0x2E
	FIFO_SRC_REG = 0x2F
	INT_GEN_1_REG = 0x30
	INT_GEN_1_SRC = 0x31
	INT_GEN_1_THS = 0x32
	INT_GEN_1_DURATION = 0x33
	INT_GEN_2_REG = 0x34
	INT_GEN_2_SRC = 0x35
	INT_GEN_2_THS = 0x36
	INT_GEN_2_DURATION = 0x37
	CLICK_CFG = 0x38
	CLICK_SRC = 0x39
	CLICK_THS = 0x3A
	TIME_LIMIT = 0x3B
	TIME_LATENCY = 0x3C
	TIME_WINDOW = 0x3D
	
	i2cBusNumber = 1
	
	def writeRegByteI2c(address, reg, value):
		global gpio
		i2cBusHandle = gpio.i2c_open(i2cBusNumber, address, 0)
		if i2cBusHandle < 0:
			return False
		gpio.i2c_write_byte_data(i2cBusHandle, reg, value)
		gpio.i2c_close(i2cBusHandle)
		return True
	
	def toUint16(lsb, msb):
		return lsb | (msb << 8)
	
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
	
	# Enable accelerometer.
	AODR = 3 # 0=power down, other = 2^(AODR-1) * 3.125 Hz
	BDU = 8
	AZEN = 4
	AYEN = 2
	AXEN = 1
	ctrlReg1XmValue = (AODR << 4) | BDU | AZEN | AYEN | AXEN
	ABW = 3 # 0=773Hz, 1=194, 2=362, 3=50
	LA_FS = 2 # 0=2g, 1=4, 2=6, 3=8, 4=16
	LA_So = LA_FS / 32768.0 # g per step
	g = 9.80665 # 1g in m per second per second.
	mssPerStep = LA_So * g # m per second per second per step.
	if LA_FS == 2:
		AFS = 0b000
	elif LA_FS == 4:
		AFS = 0b001
	elif LA_FS == 6:
		AFS = 0b010
	elif LA_FS == 8:
		AFS = 0b011
	elif LA_FS == 16:
		AFS = 0b100
	AST = 0 << 1
	SIM = 1
	ctrlReg2XmValue = (ABW << 6) | (AFS << 3)
	if not writeRegByteI2c(ACC_ADDRESS, CTRL_REG1_XM, ctrlReg1XmValue) or \
	   not writeRegByteI2c(ACC_ADDRESS, CTRL_REG2_XM, ctrlReg2XmValue): 
		sys.stderr.write("Could not initialize accelerometer sensor.\n")
		time.sleep(5)
		os.exit(1)
	
	# Enable the magnetometer: Temp enable, M data rate = 50Hz, +/-12gauss, Continuous-conversion mode
	ctrlReg6XmValue = 0b00000000
	# Magnetometer sensitivity.  Choices are 2, 4, 8, or 12 for +/-M_FS full
	# scale.
	M_FS = 2
	M_GN = M_FS * 0.00004 # gauss per step.
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
	dataRate = 0 # 0=95, 1=190, 2=380, or 3=760 Hz 
	bandWidth = 0 # complicated, but 0 is lowest and 3 is highest frequency
	powerUp = 8
	Zen = 4
	Yen = 2
	Xen = 1
	ctrlReg1GValue = (dataRate << 6) | (bandWidth << 4) | powerUp | Zen | Yen | Xen
	HPM = 2 # 0=normal(reset filter), 1=reference, 2=normal 3=autoreset
	HPCF = 3 # complicated, but 0 is highest, 9 is lowest.
	ctrlReg2GValue = (HPM << 4) | HPCF
	BDU=0x80
	notBLE=0x40
	G_FS=0 # 0=245dps 1=500dps 2,3=2000dps
	G_GSo = [ 8.75, 17.50, 70.0, 70.0 ]
	G_GAIN = G_GSo[G_FS] / 1000.0 # dps/LSB
	ctrlReg4GValue = BDU | (G_FS << 4)
	if not writeRegByteI2c(GYR_ADDRESS, CTRL_REG1_G, ctrlReg1GValue) or \
	   not writeRegByteI2c(GYR_ADDRESS, CTRL_REG2_G, ctrlReg2GValue) or \
	   not writeRegByteI2c(GYR_ADDRESS, CTRL_REG4_G, ctrlReg4GValue): 
		sys.stderr.write("Could not initialize accelerometer sensor.\n")
		time.sleep(5)
		os.exit(1)
	
	# Returns m/s/s.
	def readAccelerometer():
		acc = readXYZ(ACC_ADDRESS, OUT_X_L_A)
		acc["x"] *= mssPerStep
		acc["y"] *= mssPerStep
		acc["z"] *= mssPerStep
		acc["total"] = math.sqrt(acc["x"]*acc["x"] + acc["y"]*acc["y"] + acc["z"]*acc["z"])
		return acc
	
	# Returns Gauss.
	def readMagnetometer():
		mag = readXYZ(MAG_ADDRESS, OUT_X_L_M)
		mag["x"] *= M_GN
		mag["y"] *= M_GN
		mag["z"] *= M_GN
		mag["total"] = math.sqrt(mag["x"]*mag["x"] + mag["y"]*mag["y"] + mag["z"]*mag["z"])
		return mag
	
	# Returns degrees/second
	def readGyro():
		gyro = readXYZ(GYR_ADDRESS, OUT_X_L_G)
		gyro["x"] *= G_GAIN
		gyro["y"] *= G_GAIN
		gyro["z"] *= G_GAIN
		return gyro
	
	# The datasheet does not say enough about the temperature
	# sensor to be able to use it in any meaningful way.
	# In a room at 23 degrees C (74 degrees F), its readings
	# vary from close to 0 with a fan pointed at it, to 55+ without.
	# I can only conclude that it is an internal (rather than
	# ambient) sensor, and perhaps its intended use is to allow
	# calibration of the temperature-variation of the 
	# accelerometer, magnetometer, and gyro sensors.  The datasheet
	# says nothing whatever about any of that.  In short, I
	# think that the embedded temperature sensor is completely
	# useless for any purpose I might have.
	#def readTemperature():
	#	temperature = readLH12(MAG_ADDRESS, OUT_TEMP_L_XM)
	#	return temperature
	
	#array = readBlock(GYR_ADDRESS, 0x0F, 1)
	#if array != False:
	#	print(hex(array[0]))
	
	LSM9DS0_LOADED = True

