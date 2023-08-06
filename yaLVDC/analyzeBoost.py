#!/usr/bin/env python3
'''
License:    The creater of this program, Ron Burkey, declares that it is in the
            Public Domain, and may be used or modified for any desired purpose.
Filename:   analyzeBoost.py
Purpose:    Reads a PIO log file created by yaLVDC --log-pio=1, and creates
            a dataset of altitude and velocity vs time.
History:    08-05-2023 RSB    Created.

The PIO log file is read on stdin, and the output dataset is created on stdout.
'''

import sys
import math

lines = sys.stdin.readlines()

radius39A = 6373382.0

def tScale(t):
    return t * 168.0 / 2048000

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
