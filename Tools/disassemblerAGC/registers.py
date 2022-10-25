#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Copyright:      None - the author (Ron Burkey) declares this software to
                be in the Public Domain, with no rights reserved.
Filename:       registers.py
Purpose:        Lists of named AGC registers and iochannels.
History:        2022-10-04 RSB  Split off from disassembleBasic.py.
                """

registersAndIoChannels = {
    "01": "L",
    "02": "Q",
    "03": "HISCALAR",
    "04": "LOSCALAR",
    "05": "PYJETS",
    "06": "ROLLJETS",
    "07": "SUPERBNK",
    "0000": "A",
    "0001": "L",
    "0002": "Q",
    "0003": "EB",
    "0004": "FB",
    "0005": "Z",
    "0006": "BB",
    "0007": "ZERO",
    "0010": "ARUPT",
    "0011": "LRUPT",
    "0012": "QRUPT",
    "0013": "SAMPTIME",
    "0015": "ZRUPT",
    "0016": "BBRUPT",
    "0017": "BRUPT",
    "0020": "CYR",
    "0021": "SR",
    "0022": "CYL",
    "0023": "EDOP",
    "0024": "TIME2",
    "0025": "TIME1",
    "0026": "TIME3",
    "0027": "TIME4",
    "0030": "TIME5",
    "0031": "TIME6",
    "0032": "CDUX",
    "0033": "CDUY",
    "0034": "CDUZ",
    "0035": "OPTY",
    "0036": "OPTX",
    "0037": "PIPAX",
    "0040": "PIPAY",
    "0041": "PIPAZ",
    "0042": "RHCP",
    "0043": "RHCY",
    "0044": "RHCR",
    "0045": "INLINK",
    "0046": "RNRAD",
    "0047": "GYROCMD",
    "0050": "CDUXCMD",
    "0051": "CDUYCMD",
    "0052": "CDUZCMD",
    "0053": "OPTYCMD",
    "0054": "OPTXCMD",
    "0055": "THRUST",
    "0056": "LEMONM",
    "0057": "OUTLINK",
    "0060": "ALTM"
}

registersByName = {}
for key in registersAndIoChannels:
    if len(key) != 4:
        continue
    registersByName[registersAndIoChannels[key]] = key

iochannelsByName = {}
for key in registersAndIoChannels:
    if len(key) != 2:
        continue
    iochannelsByName[registersAndIoChannels[key]] = key

