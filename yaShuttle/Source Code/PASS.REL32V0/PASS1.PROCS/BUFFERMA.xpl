 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   BUFFERMA.xpl
    Purpose:    This is a part of the HAL/S-FC compiler program.
    Reference:  "HAL/S Compiler Functional Specification", section 2.1.2.
    Language:   XPL.
    Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
    History:    2023-04-16 RSB  Suffixed the filename with ".xpl".
    Note:       Inline comments beginning with "/*/" were created by the
                Virtual AGC Project. Inline comments beginning merely with
                "/*" are from the original Space Shuttle development.
 */

 /***************************************************************************/
 /* PROCEDURE NAME:  BUFFER_MACRO_XREF                                      */
 /* MEMBER NAME:     BUFFERMA                                               */
 /* INPUT PARAMETERS:                                                       */
 /*          I                 FIXED                                        */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          MAC_XREF                                                       */
 /*          MAC_CTR                                                        */
 /* CALLED BY:                                                              */
 /*          IDENTIFY                                                       */
 /***************************************************************************/
BUFFER_MACRO_XREF:PROCEDURE(I);                                                 00555910
      DECLARE I FIXED;                                                          00555920
 /*ROUTINE TO BUFFER MACRO XREF INFO UNTIL APPROPRIATE TIME */                  00555930
      MAC_CTR=MAC_CTR+1;                                                        00555940
      MAC_XREF(MAC_CTR)=I;                                                      00555950
      RETURN;                                                                   00555960
   END;                                                                         00555970
