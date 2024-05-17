#!/usr/bin/env python3
'''
This is one-off program to help me convert the lists of Type 1 and Type 2
parameters found in the HAL/S-FC submonitor into a form suitable for use
in the XCOM-I runtime library.
'''

import sys

type1 = '''
               (DUMP,'00000001',OFF,DP),                            X00036400
               (LISTING2,'00000002',OFF,L2),                           X00036500
               (LIST,'00000004',OFF,L),                                X00036600
               (TRACE,'00000008',ON,TR),                               X00036700
               (VARSYM,'00000040',OFF,VS),                             X00036750
               (DECK,'00400000',OFF,D),                                X00036800
               (TABLES,'00000800',ON,TBL),                             X00036900
               (TABLST,'00008000',OFF,TL),                             X00037000
               (ADDRS,'00100000',OFF,A),                               X00037100
               (SRN,'00080000',OFF),                                   X00037200
               (SDL,'00800000',OFF),                                   X00037300
               (TABDMP,'00001000',OFF,TBD),                            X00037400
               (ZCON,'00000400',ON,Z),                                 X00037500
               (HALMAT,'00040000',OFF,HM),                             X00037600
               (REGOPT,'02000000',OFF,R),                              X00037700
               (MICROCODE,'04000000',ON,MC),                           X00037800
               (SREF,'00002000',OFF,SR),                               X00037900
               (QUASI,'20000000',OFF,Q),                               X00037910
               (TEMPLATE,'00000010',OFF,TP),                           X00037920
               (HIGHOPT,'00000080',OFF,HO),                            X00038800
               (PARSE,'00010000',OFF,P),                               X00038100
               (LSTALL,'00020000',OFF,LA),                             X00038200
               (LFXI,'00200000',ON),                                   X00038300
               (X1,'00000020',OFF),                                    X00038600
               (X4,'00000100',OFF),                                    X00038900
               (X5,'00000200',OFF),                                    X00039000
               (XA,'00004000',OFF),                                    X00039100
               (X6,'01000000',OFF),                                    X00039200
               (XB,'08000000',OFF),                                    X00039300
               (XC,'10000000',OFF),                                    X00039400
               (XE,'40000000',OFF),                                    X00039500
               (XF,'80000000',OFF)                                      00039600
'''

type2 = '''
               (TITLE,TITLE,F'0',T),                                   X00041800
               (LINECT,DECIMAL,F'59',LC),                              X00041900
               (PAGES,DECIMAL,F'2500',P),                              X00042000
               (SYMBOLS,DECIMAL,F'200',SYM),                           X00042100
               (MACROSIZE,DECIMAL,F'500',MS),                          X00042200
               (LITSTRINGS,DECIMAL,F'2000',LITS),                      X00042300
               (COMPUNIT,DECIMAL,F'0',CU),                             X00042400
               (XREFSIZE,DECIMAL,F'2000',XS),                          X00042500
               (CARDTYPE,TITLE,F'0',CT),                               X00042600
               (LABELSIZE,DECIMAL,F'1200',LBLS),                       X00042700
               (DSR,DECIMAL,F'1'),                                     X00042800
               (BLOCKSUM,DECIMAL,F'400',BS),                           X00042810
               (MFID,TITLE,F'0'),                                      X00042811
'''

lines = type1.split('\n')
numParms = 0
parmList = []
for line in lines:
    if len(line) == 0:
        continue
    fields = line.split("(")
    if len(fields) != 2:
        print("NOo(")
        sys.exit(1)
    fields = fields[1].split(")")
    if len(fields) != 2:
        print("No )")
        sys.exit(1)
    fields = fields[0].split(",")
    if len(fields) not in [3, 4]:
        print("Wrong number of commas")
        sys.exit(1)
    fullName = fields[0]
    negativeName = "NO" + fullName
    mask = "0x" + fields[1][1:-1]
    default = fields[2]
    if default == "ON":
        default = fullName
    elif default == "OFF":
        default = negativeName
    else:
        print("Unknown default")
        sys.exit(1)
    if len(fields) < 4:
        synonym = "NULL"
        negativeSynonym = "NULL"
    else:
        synonym = '"' + fields[3] + '"'
        negativeSynonym = '"N' + fields[3] + '"'
    
    numParms += 1
    parmList.append('    { %s, "%s", "%s", %s, "%s", %s },' \
        % (mask, fullName, default, synonym, negativeName, negativeSynonym))
parmList[-1] = parmList[-1][:-1]
print("int numParms1 = %d;" % numParms)
print("type1_t type1[%d] = {" % numParms)
for entry in parmList:
    print(entry)
print("};")
