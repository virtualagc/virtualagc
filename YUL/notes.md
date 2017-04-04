
YUL Notes
=========

Jim Lawton, November 2016. 

More or less random notes accumulated from reading the YUL sources. 

NOTE: There is a separate Github repository H=800 stuff, including
documentation, and (eventually) tools. It's at
https://github.com/jimlawton/h800.

Endianess
---------

The Hx800 family of machines are a bit strange by modern standards. They are 48-bit memory machines with 16-bit or 32-bit register widths (depending on model/configuration). Data path is 48 bits wide. Memory address space is word (48-bit) oriented rather than byte-oriented. Memory address range however is determined by register width. For the base H800 machines (16-bit register width), the maximum addressable memory is 2^15, or 32768 48-bit words. For fully-configured H1800 machines, the maximum addressable memory is 2^16, or 65536 48-bit words. This is achieved by adding an extra "array bit" to the special registers, and adding instructions (EBA, EBS) to manipulate the array bits.

The architecture is big-endian (sorta). Bit 1 is the MSB and bit N is the LSB. So, for example, memory words are 48 bits wide. They look like:

 01 02 03 ................... 46 47 48
 MSB                               LSB

However, there is no sub-48-bit access to memory, so the issue of endianess doesn't really apply.


Instruction Set
---------------

For details on the instruction set see the _H-1800 programmers reference
Manual_
(https://github.com/jimlawton/h800/blob/master/docs/prm/Honeywell-1800-PRM.md).

Details on the ARGUS assembly syntax can be found in the _ARGUS Manual of
Assembly Language_
(https://github.com/jimlawton/h800/blob/master/docs/argus/ARGUS_Manual_of_Assembly_Language.md).

A simple analysis of instruction counts in the YUL sources gives us this:
```
Instruction Frequencies:
ALF      1587
ASSIGN   490
BA       19
BD       2
BM       9
BS       36
BT       17
CAC      150
CC       17
CONTROL  0
COREDUMP 1
CP       1
CSCON    0
DA       61
DD       0
DEC      288
DM       1
DOFF     0
DON      0
DS       20
DT       5
DUMP     1
EBA      75
EBC      0
EBS      12
END      5
EQUALS   361
EVEN     0
EX       155
FBA      0
FBAE     0
FBAU     0
FBD      0
FBM      0
FBS      0
FBSE     0
FBSU     0
FCON     0
FDA      1
FDAU     2
FDD      0
FDM      3
FDS      1
FDSU     0
FFN      1
FLBIN    0
FLDEC    20
FLN      0
FNN      1
FXBIN    63
HA       132
IT       4
LA       1248
LINK     0
LN       57
M        944
MASKBASE 21
MASKGRP  43
MODLOC   4
MPC      5
MT       104
NA       1961
NN       6
OCT      1682
PR       14
PRA      0
PRD      0
PRO      0
RB       5
RESERVE  363
RF       64
RT       7
RW       41
S        573
SCON     0
SEGNAME  0
SETLOC   67
SIMULATE 10
SM       245
SPCR     7
SPE      9
SPEC     291
SPS      4
SS       539
SSL      211
STOP     6
SUBCALL  0
SWE      567
SWS      1271
TAC      0
TAS      0
TN       391
TS       3199
TX       1606
ULD      0
WA       491
WD       232
WF       39
```

Similarly, the following insructions and pseudoinstructions are not used at all
in YUL:

```
Unused Instructions:
CONTROL
CSCON
DD
DOFF
DON
EBC
EVEN
FBA
FBAE
FBAU
FBD
FBM
FBS
FBSE
FBSU
FCON
FDD
FDSU
FLBIN
FLN
LINK
PRA
PRD
PRO
SCON
SEGNAME
SUBCALL
TAC
TAS
ULD
```

Constants
---------

- Decimal
-- Signed constants assume high-order zeros. E.g. "+125": +00...0125, "-125": -00...0125. Decimals with all MSBs zero have to be negative.
--  Unsigned constants assume low-order zeros. E.g. "32": 3200...00.

- Hex
-- ARGUS hex numbers are specified as 0-9, B-G:
"0"-"9" : 0-9
"B": 10, 0x0A.
"C": 11, 0x0B.
"D": 12, 0x0C.
"E": 13, 0x0D.
"F": 14, 0x0E.
"G": 15, 0x0F.
Confusing or what...
-- To produce a binary number with zeros in the top 4 bits, it has to be something like "-G...".


Tapes
-----

YUL references different tapes, used at different points in the assembly process. 

Tape        Purpose     
 1          
 2          
 3          
 4          


Records
-------
The tapes store different kinds of records.
 - SYLT: Symbolic YUL Library Tape
 - SYPT: Symbolic YUL Program Tape
 - BYPT: Binary YUL Program Tape [?]


Machine Tables
--------------

For each ta rget machine (called 'computer' in YUL), there is a table of opcodes supported. These tables (see images page 229 & following), are constructed using the ARGUS "M" opcode, which means 'mixed constant', i.e. the 'alphanumeric compressed' data type. This is a 48-bit word structured as 6 6-bit characters and a 12-bit number (see diagram III-1 on page 28 of the H-1800 manual). 

Here is an example of some entries from the AGC4 table:

    0138   CODES 10   M,A,MP       A,            A,            B,6200
    0139              M,A,DM       A,P           A,            B,4541
    0140              M,A,DM       A,PR          A,            B,5101
    0141              M,A,DO       A,T           A,            B,5641
    0142              M,A,UN       A,IT          A,            B,4231
    0143              M,A,DM       A,OV          A,E           B,5531
    0144              M,A,DO       A,UB          A,LE          B,7002
    0146              OCT          0

In the table entries, each "A" operand to the "M" code is part of the 6-character string part, and the "B" operand supplies an octal number representing 0-4095.

Each table is null-terminated.

So, for example, applying this to the fragment above, we get:
       MP      6200
       DMP     4541
       DMPR    5101
       DOT     5641
       UNIT    4231
       DMOVE   5531
       DOUBLE  7002

etc...


SETLOC
------

The following sets location counter to "upper half of bank 7":

    0001              SETLOC,6C    1024          B7

I think that means that the arguments have the following meanings:

    1:  6C      ?
    2:  1024    Offset from the start of the bank?
    3:  B7      Bank number, i.e. 7.

Taking another example:

    00026             SETLOC,1C    0             B1

gives:

    1:  1C      ?
    2:  0       Offset from the start of the bank, i.e. 0?
    3:  B1      Bank number, i.e. 1.

Q: Do bank numbers start at 0 or 1?


Tapes
-----

YUL uses tapes for both archival and intermediate storage. The use of tapes is occasionally documented in the code.

TAPE 1  
    Pass 1 reads SYPTSAVES and SYLTSAVES.
    Pass 1 reads BYPTSAVES.
    Pass 2 writes merged SYPT records (program assembly) or SYLT records (subroutine assembly). 

TAPE 2
    Pass 1 writes POPO (Pass One Program Output) records. 
    Pass 2 reads POPO records. 
    Rewound at the end of Pass 2. 
    Released at the end of Pass 2, unless there is another task.

TAPE 3  
    Pass 1 writes SYPTSAVES and SYLTSAVES.
    Pass 2 reads saved SYPT and SYLT records.
    Rewound at the end of Pass 2. 
    Released at the end of Pass 2, unless there is another task.

TAPE 4  
    Pass 1 writes BYPTSAVES.
    Pass 2 writes "unsorted word records".
    Rewound at the end of pass 2. 

There are other names by which tapes (disks?) are referred to also:

    YULPROGS    
    EXPEROGS    


Supported machine architectures
-------------------------------

There are several supported machine architectures. These are referred to as "COMPUTER" in the YUL source, sometimes as "MACHINE". The general parts of YUL refer to machine-specific variables as "M varname"; these are replaced at linkage by the machine-dependant variants. E.g. "M EXPLAIN" is replaced by 
"AG EXPLAN", "SC EXPLAN", "B2 EXPLAN", "A4 EXPLAN".

 - "SACO" (abbreviated "SC") 
   This seems to be a variant of the AGC for use in a proposed Air Force program called "SABRE", hence probably "SAbre COmputer".

 - "AGC"  (abbreviated "AG")
   This is the Block I AGC.

 - "BLK2" (abbreviated "B2") 
   This is the original Block II AGC.

 - "AGC4" (abbreviated "A4")
   This is the revised, final, as-flown Block II AGC.


Monitor Calls
-------------

 - MON EOFRI
 - MON LOK
 - MON PCR
 - MON PEEK
 - MON PUNCH
 - MON READ
 - MON RELOX 
 - MON RLEAS
 - MON SLEEP
 - MON TADDR
 - MON TYPER
 - MON UNLOK
 - MON WAKE
 - MONITOR

 - $PAR IDLE ?

I think "MON WAA" is a block of memory used for passing data into and out of the Monitor, but I can't be completely sure yet.


PHI Routines
------------

There are a bunch of subroutines used throughout YUL, referred to as "PHI name". These mainly have to do with tape operations. It may be that these routine were developed for YUL by a contractor, Philip Hankins Inc., hence "PHI".

 - PHI LABEL
 - PHI LOAD
 - PHI PEEK
 - PHI PRINT
 - PHI READ
 - PHI SNACH
 - PHI TAPE
 - PHI WAA

-end-
