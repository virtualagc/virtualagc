 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   DECODEPO.xpl
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
 /* PROCEDURE NAME:  DECODEPOP                                              */
 /* MEMBER NAME:     DECODEPO                                               */
 /* INPUT PARAMETERS:                                                       */
 /*          CTR               BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          OPR                                                            */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          CLASS                                                          */
 /*          NUMOP                                                          */
 /*          OPCODE                                                         */
 /*          SUBCODE                                                        */
 /* CALLED BY:                                                              */
 /*          GET_NAME_INITIALS                                              */
 /*          GET_STMT_VARS                                                  */
 /*          PROCESS_HALMAT                                                 */
 /*          SEARCH_EXPRESSION                                              */
 /***************************************************************************/
                                                                                00135600
DECODEPOP:                                                                      00135700
   PROCEDURE (CTR) ;                                                            00135800
      DECLARE CTR BIT(16);                                                      00135900
                                                                                00136000
      NUMOP = SHR(OPR(CTR),16) & "FF";                                          00136100
      CLASS = SHR(OPR(CTR),12) & "F";                                           00136200
      OPCODE = SHR(OPR(CTR),4) & "FFF";                                         00136300
      SUBCODE = SHR(OPR(CTR),9) & "0007";                                       00136400
   END DECODEPOP;                                                               00136500
