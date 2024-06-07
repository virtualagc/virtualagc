 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   VMEM2.xpl
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
 
   /* VIRTUAL MEMORY DECLARES FOR THE XPL PROGRAMMING SYSTEM                  */00100000
   /* EDIT LEVEL 002             23 AUGUST 1977         VERSION 1.1   */        00100100
                                                                                00100200
   /* THE FOLLOWING DECLARES MUST PRECEDE THE INCLUSION OF THIS MEMBER:       */00100300
   /*                                                                         */00100400
   /*   DECLARE VMEM_FILE# LITERALLY '6',                                     */00100500
   /*           VMEM_TOTAL_PAGES LITERALLY '399',                             */00100600
   /*           VMEM_PAGE_SIZE LITERALLY '1024',                              */00100700
   /*           VMEM_LIM_PAGES LITERALLY '2';                                 */00100800
                                                                                00100900
   /*  ... WHERE VMEM_FILE# IS THE LOGICAL NUMBER OF THE XPL FILE TO BE       */00101000
   /*     USED FOR THE VIRTUAL MEMORY, VMEM_TOTAL_PAGES IS THE MAXIMUM        */00101100
   /*     ALLOWABLE NUMBER OF BLOCKS IN THE VIRTUAL MEMORY (LESS 1),          */00101200
   /*     VMEM_PAGE_SIZE IS THE PHYSICAL SIZE OF A VIRTUAL MEMORY BLOCK       */00101300
   /*     (IN BYTES), AND VMEM_LIM_PAGES IS THE MAXIMUM ALLOWABLE NUMBER      */00101400
   /*     OF IN-CORE "SLOTS" (ALSO LESS 1).                                   */00101500
                                                                                00101600
   /* INITIALIZATION PROCEDURES: THE FOLLOWING TYPE OF CODE SEQUENCE SHOULD   */00102000
   /* BE USED ---                                                             */00102100
   /*                                                                         */00102200
   /*         CALL VMEM_INIT;                                                 */00102300
   /*         DO I = 0 TO VMEM_MAX_PAGE;                                      */00102400
   /*            VMEM_PAD_PAGE(I) = -1;                                       */00102450
   /*            CALL STORAGE_MGT(ADDR(VMEM_PAD_ADDR(I)),VMEM_PAGE_SIZE);     */00102500
   /*         END;                                                            */00102600
                                                                                00102700
                                                                                00102800
                                                                                00102900
COMMON   VMEM_LOC_PTR FIXED,               /* LAST LOCATED VIR. MEM. PTR      */00103000
         VMEM_LOC_ADDR FIXED,              /* LAST LOCATED VIR. MEM. ADDR     */00103100
         VMEM_LOC_CNT FIXED,               /* NUMBER OF VIR. MEM. LOCATES     */00103200
         VMEM_READ_CNT FIXED,              /* NUMBER OF VIR. MEM. READS       */00103300
         VMEM_WRITE_CNT FIXED,             /* NUMBER OF VIR. MEM. WRITES      */00103400
         VMEM_RESV_CNT FIXED,              /* NUMBER OF VIR. MEM. RESERVES    */00103500
         VMEM_PRIOR_PAGE BIT(16),          /* LAST LOCATED PAGE NUMBER        */00103600
         VMEM_LOOK_AHEAD_PAGE BIT(16),     /* PAGE BEING READ INTO            */00103700
         VMEM_MAX_PAGE BIT(16),            /* NUMBER OF ACTUAL INCORE PAGES   */00103800
         VMEM_LAST_PAGE BIT(16),           /* ACTUAL LAST PAGE                */00103900
         VMEM_OLD_NDX BIT(16),             /* INDEX OF LAST LOCATED PAGE      */00104000
         VMEM_LOOK_AHEAD BIT(1);           /* 1 --> LOOK AHEAD STATE          */00104100
                                                                                00104200
COMMON   VMEM_PAD_PAGE(VMEM_LIM_PAGES) BIT(16),  /* VIR. MEM. PAGE NUMBER     */00104300
         VMEM_PAD_ADDR(VMEM_LIM_PAGES) FIXED,    /* VIR. MEM. PAGE ADDRESS    */00104400
         VMEM_PAD_DISP(VMEM_LIM_PAGES) BIT(16),  /* MODIFY BIT & RESV CNT     */00104500
         VMEM_PAD_CNT(VMEM_LIM_PAGES) FIXED,     /* USAGE COUNTER             */00104600
         VMEM_PAGE_TO_NDX(VMEM_TOTAL_PAGES) BIT(16),   /* PAGE TO INDEX       */00104700
         VMEM_PAGE_AVAIL_SPACE(VMEM_TOTAL_PAGES) BIT(16);                       00104800
                                                                                00104900
   /* FLAG DEFINITIONS                                                        */00105000
                                                                                00105100
DECLARE  MODF BIT(8) INITIAL ("04"),       /* VIR. MEM. PAGE IS MODIFIED      */00105200
         RESV BIT(8) INITIAL ("01"),       /* RESERVE VIR. MEM. PAGE IN CORE  */00105300
         RELS BIT(8) INITIAL ("02");       /* RELEASE VIR. MEM. PAGE          */00105400
                                                                                00105500
