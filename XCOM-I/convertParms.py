#!/usr/bin/env python3
'''
This is one-off program to help me convert the lists of Type 1 and Type 2
parameters found in the HAL/S-FC submonitor into a form suitable for use
in the XCOM-I runtime library.
'''

import sys

type1 = '''
         TYPE1OPT (DUMP,'00000001',OFF,DP),                            X00033600
               (LISTING2,'00000002',OFF,L2),                           X00033700
               (ALTER,'00000004',OFF),                                 X00033710
'''

type2 = '''
         TYPE2OPT (LINECT,DECIMAL,F'59',LC), ***LOCATION DEPENDENT***  X00038600
               (PAGES,DECIMAL,F'250',P), ***LOCATION DEPENDENT***      X00038800
               (MIN,DECIMAL,F'50000'), ***LOCATION DEPENDENT***        X00039700
               (MAX,DECIMAL,F'5000000'), ***LOCATION DEPENDENT***      X00039800
               (FREE,DECIMAL,F'14336'), ***LOCATION DEPENDENT***     X00039900
'''

lines = type1.split('\n')
numParms1 = 0
parmList1 = []
for line in lines:
    if len(line) == 0:
        continue
    fields = line.split("(")
    if len(fields) != 2:
        print("NO (")
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
    
    numParms1 += 1
    parmList1.append('    { %s, "%s", "%s", %s, "%s", %s },' \
        % (mask, fullName, default, synonym, negativeName, negativeSynonym))
parmList1[-1] = parmList1[-1][:-1]

lines = type2.split('\n')
numParms2 = 0
parmList2 = []
for line in lines:
    if len(line) == 0:
        continue
    fields = line.split("(")
    if len(fields) != 2:
        print("No (")
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
    kind = fields[1]
    default = fields[2][2:-1]
    if kind == "TITLE" and default == "0":
        default = "NULL"
    else:
        default = '"' + default + '"'
    if len(fields) < 4:
        synonym = "NULL"
    else:
        synonym = '"' + fields[3] + '"'
    
    numParms2 += 1
    parmList2.append('    { "%s", %s, %s },' % (fullName, default, synonym))
parmList2[-1] = parmList2[-1][:-1]

print("optionsProcessor_t optionsProcessor = {")
print("  %d /* numParms1 */," % numParms1)
print("  %d /* numParms2 */," % numParms2)
print("  { /* type1 */")
for entry in parmList1:
    print(entry)
print("  },")
print("  { /* type2 */")
for entry in parmList2:
   print(entry)
print("  }")
print("};") # End of optionsProcessor.