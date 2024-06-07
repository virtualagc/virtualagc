 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   VMEM5A.xpl
    Purpose:    Part of the HAL/S-FC compiler.
    Reference:  "HAL/S-FC & HAL/S-360 Compiler System Program Description", 
                section TBD.
    Language:   XPL.
    Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
    History:    2022-12-08 RSB  Suffixed the filename with ".xpl".
    Note:       Inline comments beginning with "/*@" were created by the 
                Virtual AGC Project. Inline comments beginning merely with 
                "/*" are from the original Space Shuttle development.
 */
 
   /* VIRTUAL MEMORY LOGIC FOR THE XPL PROGRAMMING SYSTEM                     */00100000
   /* EDIT LEVEL 002             23 AUGUST 1977         VERSION 1.1     */      00100100
                                                                                00100200
                                                                                00100300
GET_CELL:                                                                       00123900
   PROCEDURE (CELL_SIZE,BVAR,FLAGS) FIXED;                                      00124000
      DECLARE (I,PAGE,CELL_TEMP,CELL_SIZE,AVAIL_SIZE,BVAR) FIXED,               00124100
              FLAGS BIT(8);                                                     00124200
      CELL_SIZE = (CELL_SIZE + 3)&"FFFFFFFC";  /* MULTIPLE OF 4 BYTES         */00124300
      IF CELL_SIZE > VMEM_PAGE_SIZE THEN DO;                                    00124400
         OUTPUT = '*** REQUESTED VIRTUAL MEMORY CELL SIZE TOO LARGE ***';       00124500
         CALL EXIT;                                                             00124600
      END;                                                                      00124700
      IF CELL_SIZE < VMEM_PAGE_SIZE THEN DO;                                    00124800
         IF VMEM_LOOK_AHEAD THEN DO;                                            00124900
            PAGE = VMEM_LAST_PAGE;                                              00125000
            AVAIL_SIZE = VMEM_PAGE_AVAIL_SPACE(PAGE);                           00125100
            IF AVAIL_SIZE >= CELL_SIZE THEN GO TO GET_SPACE;                    00125200
            ELSE GO TO EXTEND_VMEM;                                             00125300
         END;                                                                   00125400
         DO I = 0 TO VMEM_LAST_PAGE;                                            00125500
            PAGE = VMEM_LAST_PAGE - I;                                          00125600
            AVAIL_SIZE = VMEM_PAGE_AVAIL_SPACE(PAGE);                           00125700
            IF (AVAIL_SIZE >= CELL_SIZE)&(VMEM_PAGE_TO_NDX(PAGE)^=-1) THEN      00125800
               GO TO GET_SPACE;                                                 00125900
         END;                                                                   00126000
      END;                                                                      00126100
EXTEND_VMEM:                                                                    00126200
      PAGE = VMEM_LAST_PAGE + 1;   /* ADD ON TO VIRTUAL MEMORY                */00126300
      AVAIL_SIZE = VMEM_PAGE_SIZE;                                              00126400
GET_SPACE:                                                                      00126500
      CALL PTR_LOCATE(SHL(PAGE,16)+(VMEM_PAGE_SIZE-AVAIL_SIZE),MODF|FLAGS);     00126600
      CELL_TEMP = AVAIL_SIZE - CELL_SIZE;                                       00126700
      VMEM_PAGE_AVAIL_SPACE(PAGE) = CELL_TEMP;                                  00126800
      COREWORD(BVAR) = VMEM_LOC_ADDR;                                           00126900
      RETURN VMEM_LOC_PTR;                                                      00127000
   END GET_CELL;                                                                00127100
