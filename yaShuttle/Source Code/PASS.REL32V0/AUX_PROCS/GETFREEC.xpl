 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   GETFREEC.xpl
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
/* PROCEDURE NAME:  GET_FREE_CELL                                          */
/* MEMBER NAME:     GETFREEC                                               */
/* FUNCTION RETURN TYPE:                                                   */
/*          BIT(16)                                                        */
/* LOCAL DECLARATIONS:                                                     */
/*          TEMP_PTR          BIT(16)                                      */
/* EXTERNAL VARIABLES REFERENCED:                                          */
/*          CELL_CDR                                                       */
/*          CDR_CELL                                                       */
/*          CELL1                                                          */
/*          CELL1_FLAGS                                                    */
/*          CELL2                                                          */
/*          CELL2_FLAGS                                                    */
/*          CLOSE                                                          */
/*          C1                                                             */
/*          C1_FLAGS                                                       */
/*          C2                                                             */
/*          C2_FLAGS                                                       */
/* EXTERNAL VARIABLES CHANGED:                                             */
/*          FREE_CELL_PTR                                                  */
/*          LIST_STRUX                                                     */
/* CALLED BY:                                                              */
/*          PASS1                                                          */
/***************************************************************************/
                                                                                02406000
/*******************************************************************************02408000
         L I S T   H A N D L I N G   R O U T I N E S                            02410000
*******************************************************************************/02412000
                                                                                02414000
                                                                                02416000
         /* ROUTINE TO OBTAIN A FREE CELL */                                    02418000
                                                                                02420000
GET_FREE_CELL: FUNCTION BIT(16);                                                02422000
                                                                                02424000
   DECLARE                                                                      02426000
        TEMP_PTR                       BIT(16);                                 02428000
                                                                                02430000
  IF FREE_CELL_PTR = RECORD_TOP(LIST_STRUX) THEN DO;                            02432000
     NEXT_ELEMENT(LIST_STRUX);                                                  02432010
     CDR_CELL(FREE_CELL_PTR) = FREE_CELL_PTR + 1;                               02432020
  END;                                                                          02432030
   TEMP_PTR = FREE_CELL_PTR;                                                    02436000
   FREE_CELL_PTR = CDR_CELL(TEMP_PTR);                                          02438000
                                                                                02440000
   CELL1_FLAGS(TEMP_PTR), CELL2_FLAGS(TEMP_PTR) = 0;                            02442000
   CELL1(TEMP_PTR), CELL2(TEMP_PTR), CDR_CELL(TEMP_PTR) = 0;                    02444000
                                                                                02446000
   RETURN TEMP_PTR;                                                             02448000
                                                                                02450000
CLOSE GET_FREE_CELL;                                                            02452000
