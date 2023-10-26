 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   COMMON.xpl
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
 
/***********************************************************/                   00010100
/*                                                         */                   00010200
/*  FUNCTION:                                              */                   00010300
/*  COMMON  DECLARATIONS FOR THE HAL COMPILER              */
/*                                                         */                   00010500
/*  INCLUDED BY: PASS1, PASS2, PASS3, PASS4, AUX, FLO, OPT */
/*                                                         */                   00010500
/***********************************************************/                   00010600
/*                                                         */                   00010700
/*  REVISION HISTORY                                       */                   00010800
/*                                                         */                   00011000
/*  DATE     WHO  RLS   DR/CR #  DESCRIPTION               */                   00011100
/*                                                         */                   00011200
/*  11/30/90 RAH  23V1  CR11088  INCREASE DOWNGRADE LIMIT  */                   00011300
/*                                                         */                   00011400
/*  02/07/91 RAH  23V2  CR11098  REMOVE SPILL              */                   00011300
/*                                                         */                   00011400
/*  07/08/91 RSJ  24V0  CR11096F ADD DATA_REMOTE BOOLEAN   */                   00011400
/*                                                         */                   00011400
/*  12/23/92 PMA  8V0   *        MERGE 7V0 SYMAND 24V0        */
/*                               COMPILERS.                */
/*                               * REFERENCE 24V0 CR/DR    */
/*                                                         */
/*  10/29/93 TEV  26V0/ DR108630 0C4 ABEND OCCURS ON       */
/*                10V0           ILLEGAL DOWNGRADE         */
/*                                                         */                   00011400
/*  04/05/94 JAC  26VO  DR108643 INCORRECTLY PRINTS        */                   00011400
/*                10V0           'NONHAL' INSTEAD OF       */                   00011400
/*                               'INCREM'                  */                   00011400
/*                                                         */
/*  06/22/95 DAS  27V0/ CR12416  IMPROVE COMPILER ERROR    */
/*                11V0           PROCESSING                */
/*                                                         */                   00011400
/*  04/03/00 DCP  30V0/ CR13273  PRODUCE SDF MEMBER WHEN   */
/*                15V0           OBJECT MODULE CREATED     */
/*                                                         */                   00011400
/*  07/14/99 DCP  30V0/ CR12214  USE THE SAFEST %MACRO     */
/*                15V0           THAT WORKS                */
/*                                                         */                   00011400
/*  04/08/99 SMR  30V0/ CR13079  ADD HAL/S INITIALIZATION  */
/*                15V0           DATA TO SDF               */
/*                                                         */                   00011400
/***********************************************************/
                                                                                00012000
DECLARE  EXT_SIZE LITERALLY '300';        /* SIZE OF EXT ARRAY                */
DECLARE  NUM_DWNS LITERALLY '10';         /* INITIAL SIZE OF DOWNGRADE TABLE  */
DECLARE  DOWNGRADE_LIMIT LITERALLY '20';  /* MAXIMUM NUMBER OF DOWNGRADES     */
/* NOTE: DOWNGRADE_LIMIT IS USED ONLY IN THE ROUTINE "STREAM" IN PASS1.
         TO INCREASE (OR DECREASE) THE MAXIMUM ALLOWABLE DOWNGRADES, YOU NEED
         ONLY NEED TO CHANGE THIS VALUE.  CR11088 */

   /* SYMBOL    TABLE  */

COMMON   BASED SYM_TAB RECORD DYNAMIC:
         SYM_NAME                    CHARACTER,
         SYM_ADDR                    FIXED,
         SYM_FLAGS                   FIXED,
         XTNT                        FIXED,
         SYM_XREF                    BIT(16),
         SYM_LENGTH                  BIT(16),
         SYM_ARRAY                   BIT(16),
         SYM_PTR                     BIT(16),
         SYM_LINK1                   BIT(16),
         SYM_LINK2                   BIT(16),
         SYM_NEST                    BIT(8),
         SYM_SCOPE                   BIT(8),
         SYM_CLASS                   BIT(8),
         SYM_LOCK#                   BIT(8),
         SYM_TYPE                    BIT(8),
         SYM_FLAGS2                  BIT(8),   /* DR108643 */
END;

   /*  RECORD TO BE USE TO STORE DOWNGRADE INFORMATION */

COMMON BASED DOWN_INFO RECORD DYNAMIC:
       DOWN_STMT                   CHARACTER,     /*  STMT NUMBER     */
       DOWN_ERR                    CHARACTER,     /*  ERROR NUMBER    */
       DOWN_CLS                    CHARACTER,     /*  ERROR CLASS     */
/******************** DR108630 - TEV - 10/29/93 ****************************/
       DOWN_UNKN                   CHARACTER,     /*  UNKNOWN ERROR   */
/******************** END DR108630 *****************************************/
       DOWN_VER                    CHARACTER,     /*  1 IF DOWNGRADE  */
END;                                              /*  SUCCESSFUL      */


   /*  TABLE FOR VMEM ADDITIONS FOR FLOGEN */

COMMON   BASED SYM_ADD RECORD DYNAMIC:
         SYM_VPTR                    FIXED,
         SYM_NUM                     BIT(16),
END;

   /* CROSS REFERENCE TABLE */

COMMON   BASED CROSS_REF RECORD DYNAMIC:
         CR_REF                      FIXED,
END;

   /* TABLE FOR CHARACTER LITERALS */

COMMON   BASED LIT_NDX RECORD:
         CHAR_LIT                    BIT(8),
END;

   /* WORK AREA FOR FLOATING POINT ARITHMETIC ROUTINES */

COMMON   BASED FOR_DW RECORD:
         CONST_DW                    FIXED,
END;

   /* BUFFER FOR THE HALMAT FILE */

COMMON   BASED FOR_ATOMS RECORD DYNAMIC:
         CONST_ATOMS                 FIXED,
END;

   /* MISCELLANEOUS COMMON VARIABLES */

COMMON   BASED ADVISE RECORD:                   /*CR12214*/
         ERROR#                      CHARACTER, /*CR12214*/
         STMT#                       BIT(16),   /*CR12214*/
END;                                            /*CR12214*/

COMMON   EXT_ARRAY(EXT_SIZE) BIT(16),
         IODEV(9) BIT(8),COMMON_RETURN_CODE BIT(16),
         (TABLE_ADDR, ADDR_FIXER, ADDR_FIXED_LIMIT, ADDR_ROUNDER) FIXED,
         COMM(49) FIXED;

   /* ARRAYS TO KEEP CSECT LENGTHS FOR %COPY CHECKING */
   /* THESE ARRAYS ARE INDEXED BY SYTSCOPE            */

   /* SPILL_PRIMARY AND SPILL_REMOTE ARE SPILL VARIABLES THAT WERE */
   /* REMOVED FROM CSECT_LENGTHS FOR CR11098.                      */

COMMON   BASED CSECT_LENGTHS RECORD:
         PRIMARY BIT(16), /*    HIGH WATER MARK OF PRIMARY CSECT */
         REMOTE BIT(16),  /*  HIGH WATER MARK OF REMOTE CSECT */
END;

   /* BUFFER FOR THE LITERAL FILE */

COMMON   BASED LIT_PG RECORD DYNAMIC:
         LITERAL1(129)               FIXED,
         LITERAL2(129)               FIXED,
         LITERAL3(129)               FIXED,
END;

   /* BUFFER FOR THE VMEM FILE */

COMMON   BASED VMEMREC RECORD:
         VMEM_NDX(840)  FIXED,          /* VMEM_NDX IS ONE VMEMPAGE */
END;

COMMON BASED INIT_TAB RECORD DYNAMIC: VALUE BIT(16), END; /*CR13079*/
COMMON INITIAL_ON(2) BIT(1);                              /*CR13079*/
/*CR11096  #D -- INDICATES IF THE DATA_REMOTE DIRECTIVE WAS USED */
COMMON   DATA_REMOTE    BIT(1);
/*CR12416  INDICATES IF A SEVERITY 1 ERROR MESSAGE HAS BEEN EMITTED */
COMMON   SEVERITY_ONE   BIT(1);
/*CR13273 INDICATES AN UNNEEDED DOWNGRADE DIRECTIVE EXISTS*/
COMMON NOT_DOWNGRADED   BIT(1);         /* CR13273 */

