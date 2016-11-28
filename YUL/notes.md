
YUL Glossary
============

Jim Lawton, November 2016. 

More or less random notes accumulated from reading the YUL sources. 


Endianess
---------

The Hx800 family of machines are a bit strange by modern standards. They are 48-bit memory machines with 16-bit or 32-bit register widths (depending on model/configuration). Data path is 48 bits wide. Memory address space is word (48-bit) oriented rather than byte-oriented. Memory address range however is determined by register width. For the base H800 machines (16-bit register width), the maximum addressable memory is 2^15, or 32768 48-bit words. For fully-configured H1800 machines, the maximum addressable memory is 2^16, or 65536 48-bit words. This is achieved by adding an extra "array bit" to the special registers, and adding instructions (EBA, EBS) to manipulate the array bits.

The architecture is big-endian (sorta). Bit 1 is the MSB and bit N is the LSB. So, for example, memory words are 48 bits wide. They look like:

 01 02 03 ................... 46 47 48
 MSB                               LSB

However, there is no sub-48-bit access to memory, so the issue of endianess doesn't really apply.


Monitor Calls
-------------

 - MON TYPER
 - MON TADDR
 - MON LOK
 - MON RELOX 
 - MON WAKE
 - MON SLEEP
 - MON RLEAS
 - MONITOR

 - $PAR IDLE ?


Unknown ARGUS Opcodes
---------------------

- SETLOC (syntax unspecified)
- MODLOC (function unknown)
- STOP (MPC variant; see p113)
- ASSIGN
- RESERVE
- SPEC
-- Special register, 16-bit word (see p29); note: systems with greater that 32KW have 24-bit special registers)
- CAC (function unknown)
- EQUALS
- MASKGRP (function unknown - declaration of masks, fields?) 


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
 - BYPT: 


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

