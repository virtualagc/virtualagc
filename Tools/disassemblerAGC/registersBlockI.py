#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Copyright:      None - the author (Ron Burkey) declares this software to
                be in the Public Domain, with no rights reserved.
Filename:       registersBlockI.py
Purpose:        Lists of named AGC registers and iochannels for Block I.
History:        2022-10-13 RSB  Began adapting from registers.py.
                """

registersAndIoChannels = {
    "0000": "A",
    "0001": "Q",
    "0002": "Z",
    "0003": "LP",
    "0004": "IN0",
    "0005": "IN1",
    "0006": "IN2",
    "0007": "IN3",
    "0010": "OUT0",
    "0011": "OUT1",
    "0012": "OUT2",
    "0013": "OUT3",
    "0014": "OUT4",
    "0015": "BANKREG",
    "0016": "RELINT",
    "0017": "INHINT",
    "0020": "CYR",
    "0021": "SR",
    "0022": "CYL",
    "0023": "SL",
    "0024": "ZRUPT",
    "0025": "BRUPT",
    "0026": "ARUPT",
    "0027": "QRUPT",
    "0030": "BANKRUPT",
    "0031": "OVRUPT",
    "0032": "LPRUPT",
    "0033": "DSRUPTSW",
    "0034": "OVCTR",
    "0035": "TIME2",
    "0036": "TIME1",
    "0037": "TIME3",
    "0040": "TIME4",
    "0041": "UPLINK",
    "0042": "OUTCR1",
    "0043": "OUTCR2",
    "0044": "PIPAX",
    "0045": "PIPAY",
    "0046": "PIPAZ",
    "0047": "CDUX",
    "0050": "CDUY",
    "0051": "CDUZ",
    "0052": "OPTX",
    "0053": "OPTY",
    #"0054": "TRKRX",
    #"0055": "TRKRY",
    #"0056": "TRKRR"
}

registersByName = {}
for key in registersAndIoChannels:
    if len(key) != 4:
        continue
    registersByName[registersAndIoChannels[key]] = key

