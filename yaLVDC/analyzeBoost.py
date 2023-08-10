#!/usr/bin/env python3
'''
License:    The creater of this program, Ron Burkey, declares that it is in the
            Public Domain, and may be used or modified for any desired purpose.
Filename:   analyzeBoost.py
Purpose:    Reads a PIO log file created by yaLVDC --log-pio=1, and creates
            a dataset of altitude and velocity vs time.
History:    2023-08-06 RSB    Created.
            2023-08-09 RSB    Added --telem.

The PIO log file is read on stdin, and the output dataset is created on stdout.
'''

import sys
import math
from lvdcTelemetryDecoder import lvdcTelemetryDecoder

version = None
for param in sys.argv[1:]:
    if param.startswith("--telem="):
        version = int(param[8:])

lines = sys.stdin.readlines()

def tScale(t):
    return t * 168.0 / 2048000

if version != None:
    for line in lines:
        fields = line.strip().split("\t")
        if len(fields) != 5:
            continue
        t = int(fields[0])
        channelNumber = int(fields[2], 8)
        data = int(fields[4], 8)
        var,val,sc1,sc2,units,desc,msg = \
                        lvdcTelemetryDecoder(version, 0, channelNumber, data)
        if isinstance(sc1, int):
            scale = "B%d" % sc1
            if sc2 != -100:
                scale = scale + ("/B%d" % sc2)
        if val != None:
            if units in ["SECONDS", "PIRADS"] \
                    or "METER" in units or "M/SEC" in units:
                val = "%f" % val
            else:
                val = "O%09o" % val
            print("%.3f\t%s\t%s\t%s\t%s\t%s" % (tScale(t), var, val, 
                                                scale, units, desc))
    sys.exit(0)

radius39A = 6373382.0

def vScale(v):
    return v / 2048

def rScale(x):
    if x & 0o200000000:
        x = -(x ^ 0o377777777)
    return x / 4.0

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
