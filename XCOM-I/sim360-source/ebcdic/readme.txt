Stonybrook Pascal Tape

The files on the Stonybrook Pascal tape were as follows:
                                                    UTILITY   PKzipped
FILE    DATASET NAME       RECFM   LRECL   BLKSIZE  USED      FILENAME
====    ================   =====   =====   =======  ========  ========
  1     COMMENTS           FR      80      7200     IEBGENER  FILE01
  2     OMONITOR.ASM       FR      80      7200     IEBGENER  FILE02
  3     RMONITOR.ASM       FR      80      7200     IEBGENER  FILE03
  4     USER.PASCAL        FB      80      800      IEHMOVE   FILE04
  5     PASS1.XPL          FR      80      7200     IEBGENER  FILE05
  6     PASS1.OBJ          F       7200    7200     IEBGENER  FILE06
  7     PASS2.XPL          FR      80      7200     IEBGENER  FILE07
  8     PASS2.OBJ          F       7200    7200     IEBGENER  FILE08
  9     PASS3.XPL          FR      80      7200     IEBGENER  FILE09
 10     PASS3.OBJ          F       7200    7200     IEBGENER  FILE10
 11     PMD.XPL            FB      80      7200     IEBGENER  FILE11
 12     PMD.OBJ            F       7200    7200     IEBGENER  FILE12
 13     BNCHMRKS           FR      80      7200     IEBGENER  FILE13
 14     XPLSM.ASM          FR      80      7200     IEBGENER  FILE14
 15     XCOM.OBJ           F       7200    7200     IEBGENER  FILE15
 16     XCOM4.XPL          FR      80      7200     IEBGENER  FILE16
 17     XPLIB.XPL          FR      80      7200     IEBGENER  FILE17
 18     XPLXREF.XPL        FR      80      7200     IEBGENER  FILE18
 19     EDITXPL.XPL        FR      80      7200     IEBGENER  FILE19
 20     PASS1.UPDATE4      FR      80      7200     IEBGENER  FILE20
 21     PASS2.UPDATE4      FR      80      7200     IEBGENER  FILE21
 22     PASS3.UPDATE4      FR      80      7200     IEBGENER  FILE22
 23     PMD.UPDATE4        FR      80      7200     IEBGENER  FILE23
 24     OMONITOR.UPDATE4   FR      80      7200     IEBGENER  FILE24
 25     RMONITOR.UPDATE4   FR      80      7200     IEBGENER  FILE25

 NOTE 1:   	These files were downloaded to the PC with "no conversion",
        	so they contain the original binary or EBCDIC representation.
        	Also, there are no extra CR/LF characters to delimit records.

 NOTE 2:	I do not really remember a RECFM=FR, but that is what the
		"standard labels" on the tape actually indicated, and I was
		able to read the data just fine, by using RECFM=FB.

 NOTE 3:	I believe 7200 byte blocks was for "full-track" blocking
		on a 2314 drive. This is not a great choice on most other
		newer DASD devices, however. 

		You might want to use a more "portable" blocksize, such 
		as RECFM=FB,LRECL=80,BLKSIZE=3120 for source code files.
		This should not present any problems, as IEBGENER will
		re-block automatically (just keep the LRECL set to 80)
		when you copy from these "tape" files.
		
 NOTE 4:	The XPL system uses its own peculiar program loader that 
		reads the "object code" from special OBJ files with a
		RECFM=F, LRECL=7200 and BLKSIZE=7200. If you want to
		change this, you will apparently have to change a constant
		DECLARE in the XCOM compiler (XCOM4.XPL), and recompile
		XCOM, and also change the constant in XPLSM.ASM, the 
		runtime loader routine, and reassemble it. (Good luck!)

		By the way, an appropriate "portable" blocksize for this
		file should be 6140, which waste some space on 2314s, but, 
		who really uses 2314s any more? (BLKSIZE=6140 fits 2 blocks 
		per track on 3330s, and 3 records per track on 3350s.)

There is also a file named XPLPAS.TXT in the ZIP file, that is a 
brief overview of how to install the Stonybrook Pascal compiler 
under OS/360.  (This is the same as FILE01, converted to ASCII).

And, this file (README.TXT) is also included in the XPL.ZIP file.




