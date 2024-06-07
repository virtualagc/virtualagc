 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   PRINTSUM.xpl
    Purpose:    Auxiliary functionality used by the HAL/S-FC compiler program.
    Reference:  "HAL/S Compiler Functional Specification", section 2.
    Language:   XPL.
    Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
    History:    2022-12-08 RSB  Suffixed the filename with ".xpl".
    Note:       Inline comments beginning with "/*@" were created by the 
                Virtual AGC Project. Inline comments beginning merely with 
                "/*" are from the original Space Shuttle development.
 */
 
/***************************************************************************/
/* PROCEDURE NAME:  PRINT_SUMMARY                                          */
/* MEMBER NAME:     PRINTSUM                                               */
/* LOCAL DECLARATIONS:                                                     */
/*          T                 FIXED                                        */
/* EXTERNAL VARIABLES REFERENCED:                                          */
/*          #GCS                                                           */
/*          CLOCK                                                          */
/*          CLOSE                                                          */
/*          MAX_STACK_LEVEL                                                */
/*          MAX_USED_CELLS                                                 */
/*          TOTAL_GC_TIME                                                  */
/*          TOTAL_PRETTY_PRINT_TIME                                        */
/* EXTERNAL PROCEDURES CALLED:                                             */
/*          PRINT_TIME                                                     */
/*          PRINT_DATE_AND_TIME                                            */
/***************************************************************************/
/*********                          CALL TREE                      *********/
/***************************************************************************/
/* ==> PRINT_SUMMARY <==                                                   */
/*     ==> PRINT_TIME                                                      */
/*     ==> PRINT_DATE_AND_TIME                                             */
/*         ==> PRINT_TIME                                                  */
/***************************************************************************/
                                                                                01182000
                                                                                01184000
 /* ROUTINE  TO PRINT STATISTICS IF DESIRED */                                  01186000
                                                                                01188000
PRINT_SUMMARY:PROCEDURE;                                                        01190000
                                                                                01192000
      DECLARE T FIXED;                                                          01194000
                                                                                01196000
      OUTPUT = '';   OUTPUT = '';   /* SKIP 2 LINES */                          01198000
      CALL PRINT_DATE_AND_TIME('END OF HAL/S AUXILIARY HALMAT GENERATOR ',      01200000
         DATE, TIME);                                                           01202000
      T = MONITOR(18);                                                          01204000
                                                                                01206000
      OUTPUT = '';                                                              01208000
      CALL PRINT_TIME('TOTAL CPU TIME FOR AUXILIARY HALMAT GENERATOR     : ',   01210000
         T - CLOCK);                                                            01212000
      CALL PRINT_TIME('CPU TIME FOR AUXILIARY HALMAT GENERATOR SETUP     : ',   01214000
         CLOCK(1) - CLOCK);                                                     01216000
      CALL PRINT_TIME('CPU TIME FOR AUXILIARY HALMAT GENERATOR CRUNCHING : ',   01218000
         CLOCK(2) - CLOCK(1));                                                  01220000
                                                                                01222000
      OUTPUT = '';                                                              01224000
      OUTPUT = 'TOTAL NUMBER OF GARBAGE COLLECTIONS    = ' || #GCS;             01226000
      OUTPUT = 'MAXIMUM NUMBER OF USED CELLS           = ' || MAX_USED_CELLS;   01228000
    CALL PRINT_TIME('TOTAL TIME SPENT IN GARBAGE COLLECTION = ', TOTAL_GC_TIME);01230000
                                                                                01232000
      OUTPUT = '';                                                              01234000
      CALL PRINT_TIME('TOTAL TIME SPENT IN PRETTY PRINTING AUXMAT = ',          01236000
         TOTAL_PRETTY_PRINT_TIME);                                              01238000
                                                                                01240000
      OUTPUT = '';                                                              01242000
      OUTPUT = 'MAXIMUM STACK LEVEL = ' || MAX_STACK_LEVEL;                     01244000
      OUTPUT = '';   /* SKIP A LINE */                                          01246000
      OUTPUT = 'NUMBER OF MINOR COMPACTIFIES  = ' || COMPACTIFIES;              01248000
      OUTPUT = 'NUMBER OF MAJOR COMPACTIFIES  = ' || COMPACTIFIES(1);           01250000
      OUTPUT = 'FREE STRING AREA              = ' || FREELIMIT - FREEBASE;      01252000
      OUTPUT = '';   OUTPUT = '';   /* SKIP 2 LINES */                          01254000
                                                                                01256000
      CLOSE PRINT_SUMMARY;                                                      01258000
