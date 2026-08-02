#!/usr/bin/env python3
'''
License:    The author, Ron Burkey, declares this program to be in the Public
            Domain, and may be used or modified in any way desired.
Filename:   DECOMPRE.py
Purpose:    This is part of the port of the original XPL source code for
            HAL/S-FC into Python.
Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
History:    2026-08-02 RSB  Ported from DECOMPRE.xpl, which had been left
                            unported, so that NEXT_RECORD's g.DECOMPRESS()
                            would have raised AttributeError the moment a
                            compressed source file or INCLUDE member was
                            read.
Caution:    Porting this routine is necessary for compressed source but is not
            by itself sufficient.  A compressed record is binary, but the port
            carries a record as a Python str and recovers a byte from it with
            BYTE(), i.e. asciiToEbcdic[ord(c)].  That mapping has no preimage
            for 130 of the 256 byte values -- 0xFF, the end-of-file control
            byte, among them -- so INPUT() cannot deliver an arbitrary
            compressed record no matter what this routine does with it.
            Reading compressed source therefore also wants the port's input
            path to carry bytes rather than characters, which is a change to
            the I/O model and not to this file.  The logic below has been
            round-trip tested against a compressor written to the same format,
            restricted to the control bytes a str can hold.
'''

from xplBuiltins import *
import g
from BLANK import BLANK

'''
 /***************************************************************************/
 /* PROCEDURE NAME:  DECOMPRESS                                             */
 /* MEMBER NAME:     DECOMPRE                                               */
 /* FUNCTION RETURN TYPE:                                                   */
 /*          CHARACTER                                                      */
 /* INPUT PARAMETERS:                                                       */
 /*          DEV               BIT(16)                                      */
 /* LOCAL DECLARATIONS:                                                     */
 /*          CNTL_BYTE         BIT(8)                                       */
 /*          CURRENT_RECORD    CHARACTER;                                   */
 /*          I                 BIT(16)                                      */
 /*          IN_REC_PTR(1)     BIT(16)                                      */
 /*          INPUT_PTR         BIT(16)                                      */
 /*          J                 BIT(16)                                      */
 /*          K                 BIT(16)                                      */
 /*          OUT_REC_PTR       BIT(16)                                      */
 /*          RECRD             CHARACTER;                                   */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          INPUT_DEV                                                      */
 /*          LRECL                                                          */
 /*          X1                                                             */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          INPUT_REC                                                      */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          BLANK                                                          */
 /* CALLED BY:                                                              */
 /*          NEXT_RECORD                                                    */
 /***************************************************************************/
'''

# IN_REC_PTR is declared inside the XPL procedure, but XPL allocates procedure
# locals statically and applies INITIAL once at load, so it keeps the position
# reached in the current compressed record from one call to the next.  That is
# the whole point of it -- one call decompresses one output record, and the
# next resumes where this one stopped.  Hence it lives out here.  There is one
# element per device: 0 for the primary source, 1 for an INCLUDE member.
IN_REC_PTR = [2, 2]


def DECOMPRESS(DEV):
    # The other locals are OUT_REC_PTR, I, J, K, CNTL_BYTE, CURRENT_RECORD,
    # INPUT_PTR and RECRD.  RECRD is 132 blanks -- the maximum allowed LRECL --
    # in the XPL and is blanked again on entry, so nothing depends on its
    # persistence and it can be an ordinary local here.  Note that where the
    # XPL wrote BYTE(RECRD, n) = K in place, Python strings are immutable and
    # xplBuiltins' BYTE() returns the modified copy, so each such assignment
    # becomes RECRD = BYTE(RECRD, n, K).
    global IN_REC_PTR

    RECRD = ' ' * 132
    OUT_REC_PTR = 0;  # BUILDING NEW RECORD
    INPUT_PTR = IN_REC_PTR[DEV];  # PICK UP CURRENT POINTER
    CURRENT_RECORD = g.INPUT_REC[DEV];  # PICK UP CURRENT COMPRESSED RECORD
    RECRD = BLANK(RECRD, 0, 132);  # BLANK OUT THE NEW RECRD
    while OUT_REC_PTR <= g.LRECL[DEV]:  # STAY UNTIL A RECORD IS DONE
        if INPUT_PTR > g.LRECL[DEV]:  # DO
            CURRENT_RECORD = INPUT(g.INPUT_DEV);
            g.INPUT_REC[DEV] = CURRENT_RECORD;
            INPUT_PTR = 2;
        # END
        CNTL_BYTE = BYTE(CURRENT_RECORD, INPUT_PTR);  # THE CONTROL BYTE
        if 0 != (SHR(CNTL_BYTE, 7) & 1):  # DO -- EOF OR BLANKS
            if CNTL_BYTE == 0xFF:  # DO -- EOF
                IN_REC_PTR[DEV] = 2;  # SET UP FOR NEXT TIME
                return '';  # PASS ON EOF CONDITION
            # END
            else:  # DO -- BLANKS
                OUT_REC_PTR = OUT_REC_PTR + (CNTL_BYTE & 0x7F) + 1;
                INPUT_PTR = INPUT_PTR + 1;
            # END
        # END
        else:  # DO -- DUPLICATE OR NON-DUPLICATE STRINGS OF NON-BLANKS
            if 0 != (SHR(CNTL_BYTE, 6) & 1):  # DO -- NON-DUPLICATE
                I = INPUT_PTR + 1;  # FIRST CHAR
                J = I + (CNTL_BYTE & 0x3F);  # HOW MANY
                while I <= J:  # UNTIL ALL ARE ACCOUNTED FOR
                    if I > g.LRECL[DEV]:  # DO -- WRAP AROUND
                        CURRENT_RECORD = INPUT(g.INPUT_DEV);  # READ ANOTHER
                        g.INPUT_REC[DEV] = CURRENT_RECORD;
                        I = 2;  # SKIP 2 BYTE COUNT FIELD
                        J = J - g.LRECL[DEV] + 1;  # ADJUST TO FINISH LOOP
                    # END
                    K = BYTE(CURRENT_RECORD, I);  # PICK UP CHAR
                    # PUT INTO CREATED RECRD
                    RECRD = BYTE(RECRD, OUT_REC_PTR, K);
                    OUT_REC_PTR = OUT_REC_PTR + 1;
                    I = I + 1;
                # END
                INPUT_PTR = I;  # CATCH UP
            # END
            else:  # DO -- DUPLICATE CHARACTERS
                INPUT_PTR = INPUT_PTR + 1;  # POINT AT REPEATED CHARACTER
                if INPUT_PTR > g.LRECL[DEV]:  # DO -- ON NEXT RECORD
                    CURRENT_RECORD = INPUT(g.INPUT_DEV);
                    g.INPUT_REC[DEV] = CURRENT_RECORD;
                    INPUT_PTR = 2;  # SKIP 2 BYTES COUNT FIELD
                # END
                J = BYTE(CURRENT_RECORD, INPUT_PTR);
                # The XPL is "DO OUT_REC_PTR = OUT_REC_PTR TO OUT_REC_PTR +
                # (CNTL_BYTE & '3F') + 1".  The limit is evaluated once, on
                # entry, and OUT_REC_PTR is left one past it on exit -- both of
                # which this spelling preserves and a Python for-loop would
                # not.
                LIMIT = OUT_REC_PTR + (CNTL_BYTE & 0x3F) + 1;
                while OUT_REC_PTR <= LIMIT:
                    RECRD = BYTE(RECRD, OUT_REC_PTR, J);
                    OUT_REC_PTR = OUT_REC_PTR + 1;
                # END
                INPUT_PTR = INPUT_PTR + 1;
            # END
        # END
    # END
    IN_REC_PTR[DEV] = INPUT_PTR;  # SAVE FINAL RESTING PLACE
    # MAKE RESULT HAVE A UNIQUE DESCRIPTOR
    return SUBSTR(g.X1 + RECRD, 1, g.LRECL[DEV] + 1);
# END DECOMPRESS;
