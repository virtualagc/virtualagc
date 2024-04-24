#!/usr/bin/env python3
'''
License:    The author (Ronald S. Burkey) declares that this program
            is in the Public Domain (U.S. law) and may be used or 
            modified for any purpose whatever without licensing.
Filename:   tracing.py
Purpose:    This program can be run on a C-language code base created by 
            XCOM-I.py to add a certain amount of tracing code.  
Requires:   Python 3.6 or later.
Reference:  http://www.ibibio.org/apollo/Shuttle.html
Mods:       2024-04-23 RSB  Began.

Running this program within a folder of C-language files created by XCOM-I.py
will create a new sub-folder, tracing/, that holds a modified form of the 
C-language files and the Makefile.  Building this modified code creates a 
program that's functionally unchanged from the unmodified C code, except that
at certain junctures during runtime, tracing info is added to a file called
tracing.txt.

The following features of the XCOM-I.py's C output are targeted:
    1.  Assignments to the following temporary variables:
        numberRHS
        bitRHS
        stringRHS
        from%d
        to%d
        by%d
    2.  TBD
'''

import sys
import os
import shutil
import glob

sourceFiles = glob.glob("*.c") + glob.glob("*.h") + ["Makefile"]

outDir = "tracing"
try:
    shutil.rmtree(outDir, True)
except:
    pass
os.mkdir(outDir)

cTracing = '''
#include <stdio.h>
#include "runtimeC.h"

static FILE *traceF = NULL;

void
traceFIXED(char *filename, int lineNumber, char *msg, int32_t fixed)
{
  if (traceF == NULL)
    traceF = fopen("tracing.txt", "w");
  fprintf(traceF, "%s:%d: %s%08X\\n", filename, lineNumber,
                                      msg, fixed);
}

#ifdef BIT_T
void
traceBIT(char *filename, int lineNumber, char *msg, bit_t *bit)
{
  int i;
  if (traceF == NULL)
    traceF = fopen("tracing.txt", "w");
  fprintf(traceF, "%s:%d: %s%d %d:", filename, lineNumber,
                msg, bit->bitWidth, bit->numBytes);
  for (i = 0; i < bit->numBytes; i++)
    fprintf(traceF, " %02X", bit->bytes[i]);
  fprintf(traceF, "\\n");
}
#endif

void
traceCHARACTER(char *filename, int lineNumber, char *msg, char *character)
{
  if (traceF == NULL)
    traceF = fopen("tracing.txt", "w");
  fprintf(traceF, "%s:%d: %s\\"%s\\"\\n", filename, lineNumber,
                                      msg, character);
}
'''

hTracing = '''

void
traceFIXED(char *filename, int lineNumber, char *msg, int32_t fixed);

#ifdef BIT_T
void
traceBIT(char *filename, int lineNumber, char *msg, bit_t *bit);
#endif

void
traceCHARACTER(char *filename, int lineNumber, char *msg, char *character);
'''

outf = open(outDir + "/tracing.c", "w")
print(cTracing, file=outf)
outf.close()

for sourceFile in sourceFiles:
    inf = open(sourceFile, "r")
    outf = open(outDir + "/" + sourceFile, "w")
    traceFilename = sourceFile
    traceLineNumber = 0
    bit_t = False
    for line in inf:
        traceLineNumber += 1
        line = line.rstrip()
        print(line, file=outf)
        if sourceFile.endswith(".c"):
            indent = ' '*(len(line) - len(line.lstrip(' ')))
            if "numberRHS =" in line:
                traceLineNumber += 1
                print('%straceFIXED("%s", %d, "", numberRHS);' % \
                      (indent, traceFilename, traceLineNumber), file=outf)
            elif "bitRHS =" in line:
                traceLineNumber += 1
                print('%straceBIT("%s", %d, "", bitRHS);' % \
                      (indent, traceFilename, traceLineNumber), file=outf)
            elif "strcpy(stringRHS," in line:
                traceLineNumber += 1
                print('%straceCHARACTER("%s", %d, "", stringRHS);' % \
                      (indent, traceFilename, traceLineNumber), file=outf)
        if "bit_t" in line:
            bit_t = True
    if sourceFile == "runtimeC.h":
        if bit_t:
            print("#define BIT_T", file=outf)
        print(hTracing, file=outf)
    inf.close()
    outf.close()
