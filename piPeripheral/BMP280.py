#!/usr/bin/python3
# Copyright:	None, placed in the PUBLIC DOMAIN by its author (Ron Burkey)
# Filename: 	BMP280.py
# Purpose:	This code reads pressure and temperature data from a BMP280. 
#		It assumes the device is on a 
#		BerryGPS or BerryGPS-IMU device attached to a Raspberry Pi.  
#		But its main purpose is not to fully implement all of the BMP280
#		functionality, but merely to support the sample piPeripheral.py 
#		and piPeripheral.agc programs, so beware!  I stopped working with
#		it as soon as I was satisfied with those.
# Mod history:	2017-12-23 RSB	Began.

# If this module is already loaded, the "try" below will succeed
# and we'll do nothing.  If not, then it will fall through to
# the "except" and we'll actually do something!
try:
	
	dummy = BMP280_LOADED
	
except NameError:
	
	# Note that this is harmless if the LSM9DS0 module is already loaded.
	from LSM9DS0 import *
	from ctypes import c_short
	pressureAddress = 0x77
	
        # Get calibration data.
	calData = readBlock(pressureAddress, 0x88, 24)
	dig_T1 = toUint16(calData[0], calData[1])
	dig_T2 = toInt16(calData[2], calData[3])
	dig_T3 = toInt16(calData[4], calData[5])
	dig_P1 = toUint16(calData[6], calData[7])
	dig_P2 = toInt16(calData[8], calData[9])
	dig_P3 = toInt16(calData[10], calData[11])
	dig_P4 = toInt16(calData[12], calData[13])
	dig_P5 = toInt16(calData[14], calData[15])
	dig_P6 = toInt16(calData[16], calData[17])
	dig_P7 = toInt16(calData[18], calData[19])
	dig_P8 = toInt16(calData[20], calData[21])
	dig_P9 = toInt16(calData[22], calData[23]) 
	
	# Return temperature in degrees C and pressure in hPa.
	def readTemperatureAndPressure():
		# Fetch the raw data
		writeRegByteI2c(pressureAddress, 0xF4, 0x27)
		writeRegByteI2c(pressureAddress, 0xF5, 0xA0)
		time.sleep(0.5)
		data = readBlock(pressureAddress, 0xF7, 8)
		
		# Convert the data appropriately based on the calibration
		# info.
		# Convert pressure and temperature data to 19-bits
		adc_p = ((data[0] * 65536) + (data[1] * 256) + (data[2] & 0xF0)) / 16
		adc_t = ((data[3] * 65536) + (data[4] * 256) + (data[5] & 0xF0)) / 16
		
		# Temperature offset calculations
		var1 = ((adc_t) / 16384.0 - (dig_T1) / 1024.0) * (dig_T2)
		var2 = (((adc_t) / 131072.0 - (dig_T1) / 8192.0) * ((adc_t)/131072.0 - (dig_T1)/8192.0)) * (dig_T3)
		t_fine = (var1 + var2)
		temperature = (var1 + var2) / 5120.0
		
		# Pressure offset calculations
		var1 = (t_fine / 2.0) - 64000.0
		var2 = var1 * var1 * (dig_P6) / 32768.0
		var2 = var2 + var1 * (dig_P5) * 2.0
		var2 = (var2 / 4.0) + ((dig_P4) * 65536.0)
		var1 = ((dig_P3) * var1 * var1 / 524288.0 + ( dig_P2) * var1) / 524288.0
		var1 = (1.0 + var1 / 32768.0) * (dig_P1)
		p = 1048576.0 - adc_p
		p = (p - (var2 / 4096.0)) * 6250.0 / var1
		var1 = (dig_P9) * p * p / 2147483648.0
		var2 = p * (dig_P8) / 32768.0
		pressure = (p + (var1 + var2 + (dig_P7)) / 16.0) / 100
		
		return (temperature, pressure)
	
	BMP280_LOADED = True
