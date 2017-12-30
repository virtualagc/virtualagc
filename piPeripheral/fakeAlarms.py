#!/usr/bin/python3
# Copyright:	None, placed in the PUBLIC DOMAIN by its author (Ron Burkey)
# Filename: 	fakeAlarm.py
# Purpose:	This is a program that can send "fictitious" input channel 162
#		to yaAGC, for the purpose of generating 1201/1202 alarms on demand for
#		ropes that have been generated with yaYUL's --bailout CLI switch.  
# Reference:	http://www.ibiblio.org/apollo/developer.html
# Mod history:	2017-29 RSB	Adapted from piPeripheral.py.

# Parse command-line arguments.
import argparse
cli = argparse.ArgumentParser()
cli.add_argument("--host", help="Host address of yaAGC, defaulting to localhost.")
cli.add_argument("--port", help="Port for yaAGC, defaulting to 19799.", type=int)
cli.add_argument("--channel", help="AGC input-channel number, in octal, default 0162.")
cli.add_argument("--value", help="Value for AGC input channel, in octal, default 01201.")
cli.add_argument("--mask", help="Bitmask for value, in octal, default 077777.")
args = cli.parse_args()

# Characteristics of the host and port being used for yaAGC/yaAGS communications.  
if args.host:
	TCP_IP = args.host
else:
	TCP_IP = 'localhost'
if args.port:
	TCP_PORT = args.port
else:
	TCP_PORT = 19799

if args.channel:
	channel = int(args.channel, 8)
else:
	channel = 0o162

if args.value:
	value = int(args.value, 8)
else:
	value = 0o1201

if args.mask:
	mask = int(args.mask, 8)
else:
	mask = 0o77777

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
	#sys.stderr.write("Connecting to AGC " + TCP_IP + ":" + str(TCP_PORT) + "\n")
	while True:
		try:
			s.connect((TCP_IP, TCP_PORT))
			#sys.stderr.write("Connected.\n")
			break
		except socket.error as msg:
			#sys.stderr.write(str(msg) + "\n")
			count += 1
			if count >= 10:
				sys.stderr.write("Too many retries ...\n")
				sys.exit(1)
			time.sleep(0.05)

connectToAGC()

# Given a 3-tuple (channel,value,mask) for yaAGC, creates packet data and sends it to yaAGC.
# Or, given a 2-tuple (channel,value) for yaAGS, creates packet data and sends it to yaAGS.
def packetize(tuple):
	outputBuffer = bytearray(4)
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

packetize( (channel, value, mask) )

s.close()
