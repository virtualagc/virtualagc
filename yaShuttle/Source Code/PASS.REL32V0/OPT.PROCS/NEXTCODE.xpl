 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   NEXTCODE.xpl
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
 /* PROCEDURE NAME:  NEXTCODE                                               */
 /* MEMBER NAME:     NEXTCODE                                               */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          NUMOP                                                          */
 /*          OPR                                                            */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          CTR                                                            */
 /* CALLED BY:                                                              */
 /*          OPTIMISE                                                       */
 /***************************************************************************/
                                                                                00610000
                                                                                00611000
 /* ROUTINE TO POSITION TO THE NEXT HALMAT OPERATOR  */                         00612000
NEXTCODE:                                                                       00613000
   PROCEDURE;                                                                   00614000
      CTR=CTR+NUMOP+1;                                                          00615000
      DO WHILE OPR(CTR);                                                        00616000
         CTR = CTR + 1;                                                         00617000
      END;                                                                      00618000
   END NEXTCODE;                                                                00619000
