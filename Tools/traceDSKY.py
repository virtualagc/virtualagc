#!/usr/bin/python
# This is a program to help me trace through the 7-segment display
# patterns in the DSKY, using the schematics at 
# https://archive.org/stream/acelectroniclmma00acel_0#page/n358/mode/1up.

# Basically, there are 5 double-pole single-throw relays (K1, ..., K2) for
# each 7-segment display.  Thus there are 32 displayable combinations as 
# far as the inputs are concerned, but 128 as far as the 7-segment displays
# are concerned.  Obviously, 11 of those patterns are blank and 0-9, leaving
# 21 other combinations that need to be sussed out.

# The segments of the display are labeled as follows:
#		
#			E
#		F		H
#			J
#		K		M
#			N
#
# Thus what we're trying to do is to deduce the values of E, F, H, J, K, M, and N
# from those of K1, K2, K3, K4, and K5.

# Given input values K1, ..., K5 (each 0 or 1), output a dictionary
# { E:..., F:..., ..., N:... }.
def oneDisplay(K1, K2, K3, K4, K5):
	output = { 'E':' ', 'F':' ', 'H':' ', 'J':' ', 'K':' ', 'M':' ', 'N':' ' }
	
	# Entire K1
	if K1 != 0:
		output['H'] = '|'
	
	# Entire K4
	if K4 != 0:
		output['J'] = '-'
	
	# Left of K3
	if K3 != 0:
		output['F'] = '|'
	
	# Left of K5
	if K5 != 0:
		output['E'] = '-'
	
	# Right of K2
	if K2 == 0:
		output['K'] = output['E']
		if output['K'] == '-':
			output['K'] = '|'
	
	# Left of K2
	if K2 == 0:
		output['M'] = output['F']
	else:
		output['M'] = '|'
	
	# Right of K3
	internal = 0
	if K3 == 0:
		internal = output['J']
	else: 
		internal = '-'

	# Right of K5
	if K5 != 0:
		output['N'] = internal
	
	return output

for K5 in range(0,2):
	for K4 in range(0,2):
		for K3 in range(0,2):
			for K2 in range(0,2):
				for K1 in range(0,2):
					print K5, K4, K3, K2, K1
					output = oneDisplay(K1, K2, K3, K4, K5)
					print ' ', output['E'], ' '
					print output['F'], ' ', output['H']
					print ' ', output['J'], ' '
					print output['K'], ' ', output['M']
					print ' ', output['N'], ' '
					print ' '
