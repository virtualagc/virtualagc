 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   VMEM1.xpl
    Purpose:    Part of the HAL/S-FC compiler.
    Reference:  "HAL/S-FC & HAL/S-360 Compiler System Program Description", 
                section TBD.
    Language:   XPL.
    Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
    History:    2022-12-08 RSB  Suffixed the filename with ".xpl".
    Note:       Inline comments beginning with "/*/" were created by the 
                Virtual AGC Project. Inline comments beginning merely with 
                "/*" are from the original Space Shuttle development.
 */
 
   /* VIRTUAL MEMORY DECLARATIONS FOR THE HAL/S COMPILER                      */00000010
                                                                                00000020
DECLARE  VMEM_FILE# LITERALLY '6',    /* USE FILE 6 */                          00000030
         VMEM_TOTAL_PAGES LITERALLY '399',                                      00000040
         VMEM_PAGE_SIZE LITERALLY '3360',                                       00000050
         VMEM_LIM_PAGES LITERALLY '2';                                          00000060
                                                                                00000070
DECLARE VMEM_PTR_STATUS(VMEM_LIM_PAGES) FIXED,  /* PTRS LAST ACCESSED */        00104510
        VMEM_FLAGS_STATUS(VMEM_LIM_PAGES) BIT(8); /* FLAGS FOR ABOVE PTRS */    00104520
