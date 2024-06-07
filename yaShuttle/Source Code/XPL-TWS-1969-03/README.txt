[Best viewed with a fixed-pitch font]
                                 
                                       16 May 2001

This archive is an exercise in computer archeology.

To date no complete, readable, unmodified XPL distribution
has been recovered.  This is, I hope, a reasonable facsimile
based on data saved by various individuals over the years.


FILE DESCRIPTIONS:

File Name             Original Description               
                      File Num
 1.  README.TXT          -     This file
 2.  PROSE.TXT           -     Ascii version of the original documentation
 3.  PROSE               1     EBCDIC Documentation         
 4.  XMON.SOURCE         2     Assembler source for the XPL "submonitor"
                               (runtime package)          
 5.  TRACE.SOURCE        3     Assembler source for the trace routine
 6.  REFORM.SOURCE       4     Assembler source of utility to move
                               XPL binaries
 7.  XCOM.SOURCE         5     XPL Source for XCOM compiler
 8.  XCOM.COMPILER       6     XCOM compiler binary
 -   XCOM.SMALL.COMPILER 7     XCOM compiler binary for small-memory
                               systems [not included, PROSE has instructions
                               on how to create this file]
 9.  ANALYZER.SOURCE     8     XPL Source for syntax analyzer
10.  SYNTAX.ANALYZER     9     Syntax analyzer binary
11.  SKELETON.SOURCE    10     XPL source for skeleton "proto-compiler"
12.  ALTER.SOURCE       11     XPL source for source update program
13.  ALTER.PROGRAM      12     Binary for source update program
14.  XPL.LIBRARY        13     XPL source for string package
15.  XPL.BNF            14     BNF for the XPL language in format
                               suitable for use by ANALYZER.

Files 1 and 2 should not be uploaded, or can be uploaded as text.
Other files should be uploaded as binary with fixed-length records; 
files 8, 10, and 13 (binaries) have LRECL of 3600; other files 
have LRECL of 80.


RECORD SIZES:
  
The XPL system requires fixed record sizes for direct-access files.
For efficient disk use, these sizes should be the largest multiple
of 80 that is less than or equal to the track size of the device and
less than or equal to 32720.  If all binaries are reformatted use
half-track blocking for larger track sizes.

The distributed system is generated for 2311 disks and uses a record
length of 3600.  Changing this number requires the following steps:
  1. Change the constant 'DISKBYTES' in XCOM and re-compile it.
  2. Using 'REFORMAT', change the record size of the generated
     binary to the new value.
  3. Change the constant 'FILEBYTS' in XMON and re-assemble.
  4. Reformat or recompile all auxiliary programs with the new length.

The following are suggested lengths for various DASD devices:
  Device  LRECL
    2311 -  3600
    2314 -  7200
    3330 - 12960
    3340 -  8320
    3350 - 19040
    3375 - 32720
    3380 - 23680 [half-track] or 32720
    3390 - 28320 [half-track] or 32720
    9345 - 23200 [half-track] of 32720

Larger LRECLs will require larger region sizes.

I have not tested any of these except 3600 and 7200.


THANKS:

Thanks to a lot of people who have contributed to this reconstruction,
in particular to:
  Lanny R Andersson     <100117.1240@compuserve.com>
  William M. McKeeman   <mckeeman@mathworks.com>
  Ronald Tatum          <rhtatum@door.net>
  Mark S. Waterbury     <mark_s_waterbury@yahoo.com> 
  Heinz W. Wiggeshoff   <ab528@freenet.carleton.ca>
  David B. Wortman      <dw@pdp1.sys.toronto.edu> 


COPYRIGHT:

To the best of my knowledge this material is now in the public domain.


                                       Peter Flass <Peter_Flass@Yahoo.com>
                                       XPL Homepage: http://www.geocities.com/xpl_lang

