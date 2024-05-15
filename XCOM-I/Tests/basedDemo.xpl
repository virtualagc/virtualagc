/* This is a test case for compilation of BASED RECORD. */

DECLARE TOP_DOWN_INFO LITERALLY '4', TOP_ERR LITERALLY '5',
        TOP_DOWN_VER LITERALLY '15', TOP_ONLYF LITERALLY '5',
        TOP_ONLYC LITERALLY '6';
COMMON BASED DOWN_INFO RECORD DYNAMIC:
       DOWN_UNKN                   FIXED    ,     /*  UNKNOWN ERROR   */
       DOWN_STMT                   CHARACTER,     /*  STMT NUMBER     */
       DOWN_VER(15)                BIT(9)   ,     /*  1 IF DOWNGRADE  */
       DOWN_ERR(TOP_ERR)           CHARACTER,     /*  ERROR NUMBER    */
       DOWN_CLS                    CHARACTER,     /*  ERROR CLASS     */
END;                                              /*  SUCCESSFUL      */
COMMON (I, J, K, DOWN_INFO_RECORD_SIZE) FIXED, C CHARACTER, A(5), D(3);
COMMON BASED ONLYF FIXED;
COMMON BASED ONLYC CHARACTER;

DOWN_INFO_RECORD_SIZE = 4 * (1 + (TOP_ERR + 1) + 1 + 1 + (TOP_DOWN_VER + 1));

call inline('printMemoryMap("--- Memory Map A ---");');
output = MONITOR(6, ADDR(ONLYC), 4 * (TOP_ONLYC + 1));
output = MONITOR(6, ADDR(ONLYF), 4 * (TOP_ONLYF + 1));
output = MONITOR(6, ADDR(DOWN_INFO), DOWN_INFO_RECORD_SIZE*(TOP_DOWN_INFO + 1));
call inline('printMemoryMap("--- Memory Map B ---");');

k = 0;
do i = 0 to TOP_DOWN_INFO;
        do j = 0 to TOP_ERR;
                DOWN_INFO(i).DOWN_ERR(j) = 'Hello ' || k;
                k = k + 1;
        end;
end;
do i = 0 to TOP_ONLYF;
        ONLYF(i) = 100 + i;
end;
do i = 0 to TOP_ONLYC;
        ONLYC(i) = 'Goodbye ' || i;
end;
call inline('printMemoryMap("--- Memory Map C ---");');

k = 0;
do i = 0 to TOP_DOWN_INFO;
        do j = 0 to TOP_ERR;
                output = k || ' "' || DOWN_INFO(i).DOWN_ERR(j) || '"';
                k = k + 1;
        end;
end;
do i = 0 to TOP_ONLYF;
        output = ONLYF(i);
end;
do i = 0 to TOP_ONLYC;
        output = ONLYC(i);
end;

EOF
