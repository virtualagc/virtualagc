/*
File: bitsizeDemoCommonIn.xpl
See also: bitsizeDemo.xpl, bitsizeDemoCommon.xpl

This is a demo that passing COMMON data from one app to another works correctly
for all datatypes and structuring of variables (non-subscripted, subscripted,
BASED).  It accepts the COMMON.out data from bitsizeDemoCommon.xpl, which 
should be the XPL/I app run immediately prior. 

This program should be run with the command-line switches
        --commoni=COMMON.out
        --commono=COMMON2.out

The printed output from this program should partially match that of 
bitsizeDemo.xpl and bitsizeDemoCommon.xpl.  The difference is that the two
programs just mentioned have 4 sections, titled:
        BASED Allocations
        Address Allocations
        Initial Values
        Assignments
Whereas this program has only 3 sections:
        BASED Allocations
        Address Allocations
        (Initial Values is not present)
        COMMON (is the new title for Assigments)
The contents of the corresponding sections should match in the obvious ways,
except for the following:
    *   BASED variables will be located identically, but the data areas for
        them may be at different locations in memory.
    *   Thee pagination of the printouts may be different, and hence blank 
        lines and page headers may appear in different locations.
*/

COMMON 
        B1 BIT(1), 
        B2 BIT(2), 
        B3 BIT(3), 
        B4 BIT(4), 
        B5 BIT(5), 
        B6 BIT(6),
        B7 BIT(7), 
        B8 BIT(8), 
        B9 BIT(9), 
        B10 BIT(10), 
        B11 BIT(11),
        B12 BIT(12), 
        B13 BIT(13), 
        B14 BIT(14), 
        B15 BIT(15), 
        B16 BIT(16),
        B17 BIT(17), 
        B18 BIT(18), 
        B19 BIT(19), 
        B20 BIT(20), 
        B21 BIT(21),
        B22 BIT(22), 
        B23 BIT(23), 
        B24 BIT(24), 
        B25 BIT(25), 
        B26 BIT(26),
        B27 BIT(27), 
        B28 BIT(28), 
        B29 BIT(29), 
        B30 BIT(30),
        B31 BIT(31),
        B32 BIT(32), 
        F FIXED, 
        C CHARACTER;
COMMON BS6(5) BIT(6),
        BS13(5) BIT(13),
        BS27(5) BIT(27),
        FS(5) FIXED,
        CS(5) CHARACTER;
COMMON ARRAY AB1(5) BIT(1),
        AB8(5) BIT(8),
        AB16(5) BIT(16),
        AB32(5) BIT(32),
        AF(5) FIXED;
COMMON BASED BB1 BIT(1),
        BB8 BIT(8),
        BB16 BIT(16),
        BB32 BIT(32);
COMMON BASED BF FIXED,
        BC CHARACTER;
COMMON BASED BR RECORD:
                B1 BIT(1),      /* 0 */
                B8 BIT(8),      /* 1 */
                B16 BIT(16),    /* 2 */
                B32 BIT(32),    /* 4 */
                F FIXED,        /* 8 */
                C CHARACTER,    /* 12 */
                BS1(5) BIT(1),  /* 16 */
                BS8(5) BIT(8),  /* 22 */
                BS16(5) BIT(16),/* 28 */
                BS32(5) BIT(32),/* 40 */
                FS(5) FIXED,    /* 64 */
                CS(5) CHARACTER,/* 88 */
                                /* 112 */
           END;

OUTPUT = '';
OUTPUT = 'BASED Allocations ---------------------------------------------';
OUTPUT = '';
/* Allocated by bitsizeDemoCommon via COMMON memory, and cannot be reallocated.
RECORD_CONSTANT(BB1, 16, 1);
RECORD_USED(BB1) = RECORD_ALLOC(BB1);
RECORD_CONSTANT(BB8, 16, 1);
RECORD_USED(BB8) = RECORD_ALLOC(BB8);
RECORD_CONSTANT(BB16, 16, 1);
RECORD_USED(BB16) = RECORD_ALLOC(BB16);
RECORD_CONSTANT(BB32, 16, 1);
RECORD_USED(BB32) = RECORD_ALLOC(BB32);
RECORD_CONSTANT(BF, 16, 1);
RECORD_USED(BF) = RECORD_ALLOC(BF);
RECORD_CONSTANT(BC, 16, 1);
RECORD_USED(BC) = RECORD_ALLOC(BC);
RECORD_CONSTANT(BR, 16, 1);
RECORD_USED(BR) = RECORD_ALLOC(BR);
*/
OUTPUT = 'BB1 @' || ADDR(BB1) || ', BB1(0) @' || ADDR(BB1(0));
OUTPUT = 'BB8 @' || ADDR(BB8) || ', BB8(0) @' || ADDR(BB8(0));
OUTPUT = 'BB16 @' || ADDR(BB16) || ', BB16(0) @' || ADDR(BB16(0));
OUTPUT = 'BB32 @' || ADDR(BB32) || ', BB32(0) @' || ADDR(BB32(0));
OUTPUT = 'BF @' || ADDR(BF) || ', BF(0) @' || ADDR(BF(0));
OUTPUT = 'BC @' || ADDR(BC) || ', BC(0) @' || ADDR(BC(0));
OUTPUT = 'BR @' || ADDR(BR) || ', BR(0) @' || ADDR(BR(0));
OUTPUT = 'BR(10).BS16(3) @' || ADDR(BR(10).BS16(3));

TO_HEX:
PROCEDURE(N) CHARACTER;
        DECLARE N FIXED;
        DECLARE RETVAL CHARACTER, C CHARACTER, I FIXED, DIGIT FIXED;
        RETVAL = '';
        DO I = 1 TO 8;
                DIGIT = N & "F";
                N = SHR(N, 4);
                DO CASE DIGIT;
                        C = '0';
                        C = '1';
                        C = '2';
                        C = '3';
                        C = '4';
                        C = '5';
                        C = '6';
                        C = '7';
                        C = '8';
                        C = '9';
                        C = 'A';
                        C = 'B';
                        C = 'C';
                        C = 'D';
                        C = 'E';
                        C = 'F';
                END;
                RETVAL = C || RETVAL;
        END;
        RETURN RETVAL;
END TO_HEX;

OUTPUT = '';
OUTPUT = 'Address Allocations ---------------------------------------------';
OUTPUT = '';
OUTPUT = 'B1  @' || ADDR(B1);
OUTPUT = 'B2  @' || ADDR(B2);
OUTPUT = 'B3  @' || ADDR(B3);
OUTPUT = 'B4  @' || ADDR(B4);
OUTPUT = 'B5  @' || ADDR(B5);
OUTPUT = 'B6  @' || ADDR(B6);
OUTPUT = 'B7  @' || ADDR(B7);
OUTPUT = 'B8  @' || ADDR(B8);
OUTPUT = 'B9  @' || ADDR(B9);
OUTPUT = 'B10 @' || ADDR(B10);
OUTPUT = 'B11 @' || ADDR(B11);
OUTPUT = 'B12 @' || ADDR(B12);
OUTPUT = 'B13 @' || ADDR(B13);
OUTPUT = 'B14 @' || ADDR(B14);
OUTPUT = 'B15 @' || ADDR(B15);
OUTPUT = 'B16 @' || ADDR(B16);
OUTPUT = 'B17 @' || ADDR(B17);
OUTPUT = 'B18 @' || ADDR(B18);
OUTPUT = 'B19 @' || ADDR(B19);
OUTPUT = 'B20 @' || ADDR(B20);
OUTPUT = 'B21 @' || ADDR(B21);
OUTPUT = 'B22 @' || ADDR(B22);
OUTPUT = 'B23 @' || ADDR(B23);
OUTPUT = 'B24 @' || ADDR(B24);
OUTPUT = 'B25 @' || ADDR(B25);
OUTPUT = 'B26 @' || ADDR(B26);
OUTPUT = 'B27 @' || ADDR(B27);
OUTPUT = 'B28 @' || ADDR(B28);
OUTPUT = 'B29 @' || ADDR(B29);
OUTPUT = 'B30 @' || ADDR(B30);
OUTPUT = 'B31 @' || ADDR(B31);
OUTPUT = 'B32 @' || ADDR(B32);
OUTPUT = 'F   @' || ADDR(F);
OUTPUT = 'C   @' || ADDR(C);
OUTPUT = 'BS6 @' || ADDR(BS6);
OUTPUT = 'BS6(3) @' || ADDR(BS6(3));
OUTPUT = 'BS13 @' || ADDR(BS13);
OUTPUT = 'BS13(3) @' || ADDR(BS13(3));
OUTPUT = 'BS27 @' || ADDR(BS27);
OUTPUT = 'BS27(3) @' || ADDR(BS27(3));
OUTPUT = 'FS  @' || ADDR(FS);
OUTPUT = 'FS(3) @' || ADDR(FS(3));
OUTPUT = 'CS  @' || ADDR(CS);
OUTPUT = 'CS(3) @' || ADDR(CS(3));
OUTPUT = 'AB1  @' || ADDR(AB1);
OUTPUT = 'AB1(3) @' || ADDR(AB1(3));
OUTPUT = 'AB8  @' || ADDR(AB8);
OUTPUT = 'AB8(3) @' || ADDR(AB8(3));
OUTPUT = 'AB16  @' || ADDR(AB16);
OUTPUT = 'AB16(3) @' || ADDR(AB16(3));
OUTPUT = 'AB32  @' || ADDR(AB32);
OUTPUT = 'AB32(3) @' || ADDR(AB32(3));
OUTPUT = 'AF  @' || ADDR(AF);
OUTPUT = 'AF(3) @' || ADDR(AF(3));

OUTPUT = '';
OUTPUT = 'COMMON --------------------------------------------------';
OUTPUT = '';
OUTPUT = 'B1  = ' || TO_HEX(B1);
OUTPUT = 'B2  = ' || TO_HEX(B2);
OUTPUT = 'B3  = ' || TO_HEX(B3);
OUTPUT = 'B4  = ' || TO_HEX(B4);
OUTPUT = 'B5  = ' || TO_HEX(B5);
OUTPUT = 'B6  = ' || TO_HEX(B6);
OUTPUT = 'B7  = ' || TO_HEX(B7);
OUTPUT = 'B8  = ' || TO_HEX(B8);
OUTPUT = 'B9  = ' || TO_HEX(B9);
OUTPUT = 'B10 = ' || TO_HEX(B10);
OUTPUT = 'B11 = ' || TO_HEX(B11);
OUTPUT = 'B12 = ' || TO_HEX(B12);
OUTPUT = 'B13 = ' || TO_HEX(B13);
OUTPUT = 'B14 = ' || TO_HEX(B14);
OUTPUT = 'B15 = ' || TO_HEX(B15);
OUTPUT = 'B16 = ' || TO_HEX(B16);
OUTPUT = 'B17 = ' || TO_HEX(B17);
OUTPUT = 'B18 = ' || TO_HEX(B18);
OUTPUT = 'B19 = ' || TO_HEX(B19);
OUTPUT = 'B20 = ' || TO_HEX(B20);
OUTPUT = 'B21 = ' || TO_HEX(B21);
OUTPUT = 'B22 = ' || TO_HEX(B22);
OUTPUT = 'B23 = ' || TO_HEX(B23);
OUTPUT = 'B24 = ' || TO_HEX(B24);
OUTPUT = 'B25 = ' || TO_HEX(B25);
OUTPUT = 'B26 = ' || TO_HEX(B26);
OUTPUT = 'B27 = ' || TO_HEX(B27);
OUTPUT = 'B28 = ' || TO_HEX(B28);
OUTPUT = 'B29 = ' || TO_HEX(B29);
OUTPUT = 'B30 = ' || TO_HEX(B30);
OUTPUT = 'B31 = ' || TO_HEX(B31);
OUTPUT = 'B32 = ' || TO_HEX(B32);
OUTPUT = 'F   = ' || TO_HEX(F);
OUTPUT = 'C   = ''' || C || '''';
OUTPUT = 'BS6 = ' || TO_HEX(BS6);
OUTPUT = 'BS6(3) = ' || TO_HEX(BS6(3));
OUTPUT = 'BS13 = ' || TO_HEX(BS13);
OUTPUT = 'BS13(3) = ' || TO_HEX(BS13(3));
OUTPUT = 'BS27 = ' || TO_HEX(BS27);
OUTPUT = 'BS27(3) = ' || TO_HEX(BS27(3));

OUTPUT = 'FS = ' || TO_HEX(FS);
OUTPUT = 'FS(3) = ' || TO_HEX(FS(3));
OUTPUT = 'CS = ''' || CS || '''';
OUTPUT = 'CS(3) = ''' || CS(3) || '''';
OUTPUT = 'AB1 = ' || TO_HEX(AB1);
OUTPUT = 'AB1(3) = ' || TO_HEX(AB1(3));
OUTPUT = 'AB8 = ' || TO_HEX(AB8);
OUTPUT = 'AB8(3) = ' || TO_HEX(AB8(3));
OUTPUT = 'AB16 = ' || TO_HEX(AB16);
OUTPUT = 'AB16(3) = ' || TO_HEX(AB16(3));
OUTPUT = 'AB32 = ' || TO_HEX(AB32);
OUTPUT = 'AB32(3) = ' || TO_HEX(AB32(3));
OUTPUT = 'AF = ' || TO_HEX(AF);
OUTPUT = 'AF(3) = ' || TO_HEX(AF(3));
OUTPUT = 'BB1(10) = ' || TO_HEX(BB1(10));
OUTPUT = 'BB8(10) = ' || TO_HEX(BB8(10));
OUTPUT = 'BB16(10) = ' || TO_HEX(BB16(10));
OUTPUT = 'BB32(10) = ' || TO_HEX(BB32(10));
OUTPUT = 'BF(10) = ' || TO_HEX(BF(10));
OUTPUT = 'BC(10) = ''' || BC(10) || '''';
OUTPUT = 'BR(10).B1 = ' || TO_HEX(BR(10).B1);
OUTPUT = 'BR(10).B8 = ' || TO_HEX(BR(10).B8);
OUTPUT = 'BR(10).B16 = ' || TO_HEX(BR(10).B16);
OUTPUT = 'BR(10).B32 = ' || TO_HEX(BR(10).B32);
OUTPUT = 'BR(10).F = ' || TO_HEX(BR(10).F);
OUTPUT = 'BR(10).C = ''' || BR(10).C || '''';
OUTPUT = 'BR(10).BS1(3) = ' || TO_HEX(BR(10).BS1(3));
OUTPUT = 'BR(10).BS8(3) = ' || TO_HEX(BR(10).BS8(3));
OUTPUT = 'BR(10).BS16(3) = ' || TO_HEX(BR(10).BS16(3));
OUTPUT = 'BR(10).BS32(3) = ' || TO_HEX(BR(10).BS32(3));
OUTPUT = 'BR(10).FS(3) = ' || TO_HEX(BR(10).FS(3));
OUTPUT = 'BR(10).CS(3) = ''' || BR(10).CS(3) || '''';

EOF
