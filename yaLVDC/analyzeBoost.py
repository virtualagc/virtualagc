#!/usr/bin/env python3
'''
License:    The creater of this program, Ron Burkey, declares that it is in the
            Public Domain, and may be used or modified for any desired purpose.
Filename:   analyzeBoost.py
Purpose:    Reads a PIO log file created by yaLVDC --log-pio=1, and creates
            a dataset of altitude and velocity vs time.
History:    2023-08-06 RSB  Created.
            2023-08-09 RSB  Added --telem.
            2023-08-10 RSB  Changed --telem CLI option to --version, and added
                            new --telemetry, --port, and --host CLI options to
                            support the new operating mode of connecting to
                            yaLVDC and displaying all its telemetry.
            2023-08-12 RSB  Better handling of case in which no binary scaling
                            is defined, some of which was accomplished by 
                            updating lvdcTelemetryDefinitions.tsv.

The PIO log file is read on stdin, and the output dataset is created on stdout.
'''

import sys
import math
import time
import socket
from lvdcTelemetryDecoder import lvdcTelemetryDecoder, lvdcSetVersion, \
                                 lvdcFormatData

version = None
telemetry = False
TCP_IP = "localhost"
TCP_PORT = 19653
for param in sys.argv[1:]:
    if param.startswith("--version="):
        version = int(param[10:])
        lvdcSetVersion(version)
    elif param == "--telemetry":
        telemetry = True
    elif param.startswith("--port="):
        TCP_PORT = int(param[7:])
    elif param.startswith("--host="):
        TCP_IP = param[7:]
    else:
        print()
        print("There are three separate functions implemented in this program.")
        print("   1. Accept yaLVDC's PIO log on stdin and generate data for")
        print("      plotting altitude and inertial velocity vs time.  Do not")
        print("      use any CLI arguments to choose this option.")
        print("   2. Accept yaLVDC's PIO log on stdin and parse it into")
        print("      telemetry data.  Used just the --version CLI switch.")
        print("   3. Connect to 'virtual wiring' of a running instance of")
        print("      yaLVDC and print all telemetry.  Use the --version and")
        print("      --telemetry switches, and optionally the --host and")
        print("      --port switches.")
        print()
        print("Syntax of the CLI options:")
        print()
        print("--version=N    N is 1 for AS-206RAM, 2 for AS-512, 3 for")
        print("               AS-513.  The default is None.")
        print("--telemetry    Has no sub-parameters.")
        print("--host=H       H defaults to 'localhost', but could be an")
        print("               IP address, etc.  It specifies the host machine")
        print("               on which yaLVDC is running.")
        print("--port=P       P defaults to 19653. ")
        sys.exit(0)

# Generic initialization (TCP socket setup).  Has no target-specific code, and 
# shouldn't need to be modified unless there are bugs.
s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
#s.setblocking(0)
newConnect = False
def connectToLVDC():
    global newConnect
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
            if count >= 100:
                sys.stderr.write("Too many retries ...\n")
                time.sleep(3)
                sys.exit(1)
            time.sleep(1)

def tScale(t):
    return t * 168.0 / 2048000

if version != None and not telemetry:
    
    lines = sys.stdin.readlines()

    format0 = "\t%-8s\t%-12s\t%-12s\t%-16s\t%-12s\t%s"
    hFormat = "%12s" + format0
    lFormat = "%12.3f" + format0
    print(hFormat % \
          ("Time (sec)", "Variable", "Raw Value", "Scale", "Scaled Val", "Units", "Description"))
    print(hFormat % \
          ("----------", "--------", "---------", "-----", "----------", "-----", "-----------"))
    for line in lines:
        fields = line.strip().split("\t")
        if len(fields) != 5:
            continue
        t = int(fields[0])
        channelNumber = int(fields[2], 8)
        data = int(fields[4], 8)
        var,val,sc1,sc2,units,desc,msg,aug = \
                        lvdcTelemetryDecoder(0, channelNumber, data)
        scale = ""
        if isinstance(sc1, int):
            if sc1 != -1000:
                scale = "B%d" % sc1
                if sc2 != -1000:
                    scale = scale + ("/B%d" % sc2)
        if val != None:
            val,scaled = lvdcFormatData(val, sc1, units)
            print(lFormat % (tScale(t), var, val, scale, scaled, units, desc))
    sys.exit(0)

if version != None and telemetry:
    
    connectToLVDC()
    # Buffer for a packet received from yaLVDC.
    packetSize = 6
    inputBuffer = bytearray(packetSize)
    leftToRead = packetSize
    view = memoryview(inputBuffer)
    
    format0 = "\t%-8s\t%-12s\t%-12s\t%-12s\t%-12s\t%s"
    hFormat = "%12s" + format0
    lFormat = "%12.3f" + format0
    print()
    print("NOTE: Time origin is start of analyzeBoost, not of LVDC.")
    print()
    print(hFormat % \
          ("Time (sec)", "Variable", "Raw Value", "Scale", "Scaled Val", "Units", "Description"))
    print(hFormat % \
          ("----------", "--------", "---------", "-----", "----------", "-----", "-----------"))
    t0 = time.time()
    while True:
        # Check for packet data received from yaLVDC and process it.
        # While these packets are always the same length in bytes,
        # since the socket is non-blocking any individual read
        # operation may yield less bytes than that, and the buffer may 
        # accumulate data over time until it fills.    
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
                        if (inputBuffer[i] & 0x80) == 0x80 \
                                and inputBuffer[i] != 0xFF:
                            j = 0
                            for k in range(i,6):
                                inputBuffer[j] = inputBuffer[k]
                                j += 1
                            view = view[j:]
                            leftToRead = packetSize - j
                else:
                    ioType = (inputBuffer[0] >> 3) & 7
                    source = inputBuffer[0] & 7
                    channel = ((inputBuffer[2] << 2) & 0x180) | \
                                (inputBuffer[1] & 0x7F)
                    value = (inputBuffer[2] & 0x1F) << 21
                    value |= (inputBuffer[3] & 0x7F) << 14
                    value |= (inputBuffer[4] & 0x7F) << 7
                    value |= inputBuffer[5] & 0x7F
                    var,val,sc1,sc2,units,desc,msg,aug = \
                                    lvdcTelemetryDecoder(0, channel, value)
                    scale = ""
                    if isinstance(sc1, int):
                        if sc1 != -1000:
                            scale = "B%d" % sc1
                            if sc2 != -1000:
                                scale = scale + ("/B%d" % sc2)
                    if val != None:
                        val,scaled = lvdcFormatData(val, sc1, units)
                        t1 = time.time()
                        print(lFormat % (t1-t0, var, val, scale, scaled, units, desc))

radius39A = 6373382.0

def vScale(v):
    return v / 2048

def rScale(x):
    if x & 0o200000000:
        x = -(x ^ 0o377777777)
    return x / 4.0

lines = sys.stdin.readlines()

print("Time (sec)\tAltitude (km)\tVelocity (m/sec)")
components = {}
for line in lines:
    fields = line.strip().split("\t")
    if len(fields) != 5 or fields[1] != ">" \
            or fields[2] not in ["124", "034", "044", "050"]:
        continue
    rtc = tScale(int(fields[0]))
    if len(components) == 0:
        components["t"] = rtc
    channel = fields[2]
    value = int(fields[4], 8)
    if channel == "124":
        components["v"] = vScale(value)
    elif channel == "034":
        components["z"] = rScale(value)
    elif channel == "044":
        components["x"] = rScale(value)
    elif channel == "050":
        components["y"] = rScale(value)
    if len(components) == 5:
        t = components["t"]
        v = components["v"]
        x = components["x"]
        y = components["y"]
        z = components["z"]
        r2 = x * x + y * y + z * z
        r = (math.sqrt(r2) - radius39A) / 1000.0
        print("%8.4f\t%8.4f\t%8.3f" % (t, r, v))
        components = {}
