/* This is a test case for compilation of BASED RECORD. */

COMMON BASED DOWN_INFO RECORD DYNAMIC:
       DOWN_STMT                   CHARACTER,     /*  STMT NUMBER     */
       DOWN_ERR                    CHARACTER,     /*  ERROR NUMBER    */
       DOWN_CLS                    CHARACTER,     /*  ERROR CLASS     */
       DOWN_UNKN                   CHARACTER,     /*  UNKNOWN ERROR   */
       DOWN_VER                    CHARACTER,     /*  1 IF DOWNGRADE  */
END;                                              /*  SUCCESSFUL      */

DOWN_INFO(5).DOWN_CLS = 'Hello';
OUTPUT = DOWN_INFO(5).DOWN_CLS;

EOF
