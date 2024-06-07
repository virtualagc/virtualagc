 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   GETEXPVA.xpl
    Purpose:    Part of the HAL/S-FC compiler's HALMAT intermediate-code
                generation process.
    Reference:  "HAL/S-FC & HAL/S-360 Compiler System Program Description", 
                section 6.3.
    Language:   XPL.
    Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
    History:    2022-12-08 RSB  Suffixed the filename with ".xpl".
    Note:       Inline comments beginning with "/*@" were created by the 
                Virtual AGC Project. Inline comments beginning merely with 
                "/*" are from the original Space Shuttle development.
 */
 
 /***************************************************************************/
 /* PROCEDURE NAME:  GET_EXP_VARS_CELL                                      */
 /* MEMBER NAME:     GETEXPVA                                               */
 /* FUNCTION RETURN TYPE:                                                   */
 /*          FIXED                                                          */
 /* LOCAL DECLARATIONS:                                                     */
 /*          CELL              FIXED                                        */
 /*          I                 BIT(16)                                      */
 /*          PTR_START         BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          EXP_PTRS                                                       */
 /*          EXP_VARS                                                       */
 /*          MODF                                                           */
 /*          PROC_TRACE                                                     */
 /*          VMEM_LOC_ADDR                                                  */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          CELLSIZE                                                       */
 /*          PTR_INX                                                        */
 /*          VAR_INX                                                        */
 /*          VMEM_F                                                         */
 /*          VMEM_H                                                         */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          GET_CELL                                                       */
 /* CALLED BY:                                                              */
 /*          GET_P_F_INV_CELL                                               */
 /*          GET_STMT_VARS                                                  */
 /*          GET_VAR_REF_CELL                                               */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> GET_EXP_VARS_CELL <==                                               */
 /*     ==> GET_CELL                                                        */
 /***************************************************************************/
 /*                                                                         */
 /* REVISION HISTORY:                                                       */
 /*                                                                         */
 /* DATE     WHO  RLS   DR/CR #  DESCRIPTION                                */
 /*                                                                         */
 /* 03/07/91 TKK  23V2  CR11109  CLEAN UP OF COMPILER SOURCE CODE           */
 /*                                                                         */
 /***************************************************************************/
                                                                                00165600
 /* RETURNS PTR TO AN EXPRESSION VARIABLES CELL MADE FROM THE EXP_VARS          00165700
AND EXP_PTRS ARRAYS */                                                          00165800
GET_EXP_VARS_CELL:                                                              00165900
   PROCEDURE FIXED;                                                             00166000
      DECLARE CELL FIXED, (PTR_START,I) BIT(16);                                00166100
                                                                                00166200
      IF PROC_TRACE THEN OUTPUT='GET_EXP_VARS_CELL';                            00166201
      IF PTR_INX=0 & VAR_INX=0 THEN RETURN 0;                                   00166300
      PTR_START = SHR(VAR_INX+1,1);                                             00166400
      CELLSIZE = SHL(PTR_START+PTR_INX+1,2);                                    00166500
      CELL = GET_CELL(CELLSIZE,ADDR(VMEM_H),MODF);                              00166600
      VMEM_H(0) = CELLSIZE;                                                     00166700
      VMEM_H(1) = VAR_INX;                                                      00166800
      DO I = 1 TO VAR_INX;                                                      00166900
         VMEM_H(I+1) = EXP_VARS(I);                                             00167000
      END;                                                                      00167100
      COREWORD(ADDR(VMEM_F)) = VMEM_LOC_ADDR;                                   00167200
      DO I = 1 TO PTR_INX;                                                      00167300
         VMEM_F(PTR_START+I) = EXP_PTRS(I);                                     00167400
      END;                                                                      00167500
      VAR_INX, PTR_INX = 0;                                                     00167600
      RETURN CELL;                                                              00167700
   END GET_EXP_VARS_CELL;                                                       00167800
