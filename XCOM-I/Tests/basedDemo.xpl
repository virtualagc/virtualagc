/* This is a test case for compilation of BASED RECORD. */

DECLARE TOP_DOWN_INFO LITERALLY '4', TOP_ERR LITERALLY '5';
COMMON BASED DOWN_INFO RECORD DYNAMIC:
       DOWN_STMT                   CHARACTER,     /*  STMT NUMBER     */
       DOWN_ERR(TOP_ERR)           CHARACTER,     /*  ERROR NUMBER    */
       DOWN_CLS                    CHARACTER,     /*  ERROR CLASS     */
       DOWN_UNKN                   CHARACTER,     /*  UNKNOWN ERROR   */
       DOWN_VER                    CHARACTER,     /*  1 IF DOWNGRADE  */
END;                                              /*  SUCCESSFUL      */
DECLARE (I, J, K, DOWN_INFO_RECORD_SIZE) FIXED, C CHARACTER, A(5), D(3);
BASED ONLYF FIXED;
BASED ONLYC CHARACTER;

DOWN_INFO_RECORD_SIZE = 4 * (1 + (TOP_ERR + 1) + 1 + 1 + 1);

call inline('printMemoryMap("--- A ---");');
output = MONITOR(6, ADDR(ONLYC), 4*6);
output = MONITOR(6, ADDR(ONLYF), 4*7);
output = MONITOR(6, ADDR(DOWN_INFO), DOWN_INFO_RECORD_SIZE*(TOP_DOWN_INFO + 1));
call inline('printMemoryMap("--- B ---");');

k = 0;
do i = 0 to TOP_DOWN_INFO;
        do j = 0 to TOP_ERR;
                DOWN_INFO(i).DOWN_ERR(j) = 'Hello ' || k;
                k = k + 1;
        end;
end;
call inline('printMemoryMap("--- C ---");');

k = 0;
do i = 0 to TOP_DOWN_INFO;
        do j = 0 to TOP_ERR;
                output = k || ' "' || DOWN_INFO(i).DOWN_ERR(j) || '"';
                k = k + 1;
        end;
end;

EOF
