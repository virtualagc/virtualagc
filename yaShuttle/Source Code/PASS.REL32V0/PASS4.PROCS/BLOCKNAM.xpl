 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   BLOCKNAM.xpl
    Purpose:    This is a part of the HAL/S-FC compiler program.
    Reference:  "HAL/S Compiler Functional Specification", section 2.1.2.
    Language:   XPL.
    Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
    History:    2023-04-16 RSB  Suffixed the filename with ".xpl".
    Note:       Inline comments beginning with "/*@" were created by the
                Virtual AGC Project. Inline comments beginning merely with
                "/*" are from the original Space Shuttle development.
 */

/***************************************************************************/
/* PROCEDURE NAME:  BLOCK_NAME                                             */
/* MEMBER NAME:     BLOCKNAM                                               */
/* FUNCTION RETURN TYPE:                                                   */
/*          CHARACTER                                                      */
/* INPUT PARAMETERS:                                                       */
/*          BLK#              BIT(16)                                      */
/* LOCAL DECLARATIONS:                                                     */
/*          BNAME             CHARACTER;                                   */
/* EXTERNAL VARIABLES REFERENCED:                                          */
/*          ADDRESS                                                        */
/*          BLKNAM                                                         */
/*          BLKNLEN                                                        */
/*          BLKNO                                                          */
/*          COMMTABL_ADDR                                                  */
/*          COMMTABL_BYTE                                                  */
/*          COMMTABL_FULLWORD                                              */
/*          PNTR                                                           */
/* EXTERNAL VARIABLES CHANGED:                                             */
/*          LOC_ADDR                                                       */
/*          COMMTABL_HALFWORD                                              */
/*          LOC_PTR                                                        */
/*          TMP                                                            */
/* CALLED BY:                                                              */
/*          DUMP_SDF                                                       */
/***************************************************************************/
                                                                                00166000
 /* ROUTINE TO EXTRACT A BLOCK NAME FROM A BLOCK DATA CELL */                   00166100
                                                                                00166200
BLOCK_NAME:                                                                     00166300
   PROCEDURE (BLK#) CHARACTER;                                                  00166400
      DECLARE BNAME CHARACTER,                                                  00166500
         BLK# BIT(16);                                                          00166600
      BLKNO = BLK#;                                                             00166700
      CALL MONITOR(22,8);                                                       00166800
      LOC_PTR = PNTR;                                                           00166900
      LOC_ADDR = ADDRESS;                                                       00167000
      TMP = SHL((BLKNLEN - 1),24);                                              00167100
      COREWORD(ADDR(BNAME)) = BLKNAM + TMP;                                     00167200
      RETURN BNAME;                                                             00167300
   END BLOCK_NAME;                                                              00167400
