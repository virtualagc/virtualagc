#!/usr/bin/env python3
'''
License:    The author, Ron Burkey, declares this program to be in the Public
            Domain, and may be used or modified in any way desired.
Filename:   COMRDEC19.py
Purpose:    This is part of the port of the original XPL source code for 
            HAL/S-FC into Python.  
Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
History:    2023-09-28 RSB  Ported
'''

'''
 /***************************************************************************/
 /* MEMBER NAME:     COMDEC19                                               */
 /* PURPOSE:         COMMON DECLARATIONS                                    */
 /***************************************************************************/
 
   /*********************************************
      COMMON DECLARATIONS FOR REL19 1.7
    *********************************************/
'''
   
'''
This part of the original XPL appears to be gobbledygook.  For one thing, the
parentheses in LOCATE_STMT_DECL_CELL don't match up.  Nor is 
LOCATE_STMT_DECL_CELL used any place in the remainder of the code base anyway, 
as far as I can see.

   /* STMT_DECL DESCRIBES WHAT A STATEMENT DECLARATION CELL LOOKS LIKE
      SEE     . IT SHOULD BE ACCESSED ONLY WITH LOCATE_STMT_DECL_CELL(PTR,FLAGS)
      BECAUSE HALMAT_CELL_PTR IS REALLY NODE_F(-1) IF ONE HAD CALLED
      LOCATE(PTR,ADDR(NODE_F),FLAGS) (BASED NODE_F FIXED). */
BASED STMT_DECL_CELL RECORD:
      HALMAT_CELL_PTR FIXED,
      NEXT_STMT_PTR   FIXED,
      PREV_STMT_PTR   FIXED,
      NAME_INIT_PTR   FIXED,
      FILLER(2)       FIXED,
      FILL16          BIT(16),
      STMT_TYPE       BIT(16),
      STMT_NO         BIT(16),
      BLOCK_NO        BIT(16),
      END;
DECLARE LOCATE_STMT_DECL_CELL(2) LITERALLY
        'DO; CALL LOCATE(%1%),ADDR(STMT_DECL_CELL),%2%);
         COREWORD(ADDR(STMT_DECL_CELL))=COREWORD(ADDR(STMT_DECL_CELL)-4;END;';
'''
         
DECL_STMT_TYPE = 0x15
EQUATE_TYPE = 0x17
TEMP_TYPE = 0x18
REPLACE_STMT_TYPE = 0x19
STRUC_STMT_TYPE = 0x1A
NILL = -1  # DEFAULT NULL POINTER VALUE FOR VMEM
POINTER_PREFIX = -1
# DEFINE CLOSE AS 'END';
XREC_WORD = 0x00000020  # TO INDICATE THE END OF A HALMAT CELL 

