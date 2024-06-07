 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   MOVECODE.xpl
    Purpose:    This is a part of optimizer of the HAL/S-FC compiler program.
    Reference:  "HAL/S Compiler Functional Specification", section 2.4.
    Language:   XPL.
    Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
    History:    2022-12-08 RSB  Suffixed the filename with ".xpl".
    Note:       Inline comments beginning with "/*@" were created by the 
                Virtual AGC Project. Inline comments beginning merely with 
                "/*" are from the original Space Shuttle development.
 */
 
 /***************************************************************************/
 /* PROCEDURE NAME:  MOVECODE                                               */
 /* MEMBER NAME:     MOVECODE                                               */
 /* INPUT PARAMETERS:                                                       */
 /*          LOW               BIT(16)                                      */
 /*          HIGH              BIT(16)                                      */
 /*          BIG               BIT(16)                                      */
 /*          ENTER_TAG         BIT(8)                                       */
 /* LOCAL DECLARATIONS:                                                     */
 /*          FLAG_TEMP(20)     BIT(8)                                       */
 /*          MOVEBLOCK         LABEL                                        */
 /*          MOVEBLOCKSIZE     MACRO                                        */
 /*          OPR_TEMP(20)      FIXED                                        */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          SIZE                                                           */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          FLAG                                                           */
 /*          OPR                                                            */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          ENTER                                                          */
 /* CALLED BY:                                                              */
 /*          MOVE_LIMB                                                      */
 /*          PREPARE_HALMAT                                                 */
 /*          QUICK_RELOCATE                                                 */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> MOVECODE <==                                                        */
 /*     ==> ENTER                                                           */
 /***************************************************************************/
                                                                                00948000
 /*  LOCAL SUBROUTINE FOR MOVING LINES OF CODE  */                              00949000
MOVECODE:                                                                       00950000
   PROCEDURE (LOW,HIGH,BIG,ENTER_TAG);                                          00951000
      DECLARE ENTER_TAG BIT(8);                                                 00952000
      DECLARE (LOW,HIGH,BIG) BIT(16);                                           00953000
      DECLARE MOVEBLOCKSIZE LITERALLY '20',                                     00954000
         FLAG_TEMP(MOVEBLOCKSIZE) BIT(8),                                       00955000
         OPR_TEMP(MOVEBLOCKSIZE) FIXED;                                         00956000
                                                                                00957000
 /*  EVEN MORE LOCAL ROUTINE FOR MOVING BLOCKS AT A TIME  */                    00958000
MOVEBLOCK:                                                                      00959000
      PROCEDURE (NEW,START,SIZE);                                               00960000
         DECLARE (NEW,START,SIZE) BIT(16);                                      00961000
         DECLARE (I,J,K) BIT(16);                                               00962000
         DO I=0 TO SIZE-1;                                                      00963000
            J=I+START;                                                          00964000
            OPR_TEMP(I)=OPR(J);                                                 00965000
            FLAG_TEMP(I) = FLAG(J);                                             00966000
         END;                                                                   00967000
         DO I=1 TO START-NEW;                                                   00968000
            J=START-I;                                                          00969000
            K=J+SIZE;                                                           00970000
            OPR(K)=OPR(J);                                                      00971000
            IF ENTER_TAG THEN DO;                                               00972000
               FLAG(K) = FLAG(J);                                               00973000
               IF SHR(OPR(K),3) THEN CALL ENTER(K);                             00974000
            END;                                                                00975000
         END;                                                                   00976000
         DO I=0 TO SIZE-1;                                                      00977000
            J=I+NEW;                                                            00978000
            OPR(J)=OPR_TEMP(I);                                                 00979000
            IF ENTER_TAG THEN DO;                                               00980000
               FLAG(J) = FLAG_TEMP(I);                                          00981000
               IF SHR(OPR(J),3) THEN CALL ENTER(J);                             00982000
            END;                                                                00983000
         END;                                                                   00984000
      END MOVEBLOCK;                                                            00985000
                                                                                00986000
      DO WHILE BIG>MOVEBLOCKSIZE;                                               00987000
         CALL MOVEBLOCK(LOW,HIGH,MOVEBLOCKSIZE);                                00988000
         LOW=LOW+MOVEBLOCKSIZE;                                                 00989000
         HIGH=HIGH+MOVEBLOCKSIZE;                                               00990000
         BIG=BIG-MOVEBLOCKSIZE;                                                 00991000
      END;                                                                      00992000
      CALL MOVEBLOCK(LOW,HIGH,BIG);                                             00993000
      ENTER_TAG = 0;                                                            00994000
   END MOVECODE;                                                                00995000
