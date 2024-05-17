/* This is a test case for compilation of BASED RECORD. */

DECLARE MSG(1) LITERALLY 
    'call inline(''printMemoryMap("--- Memory Map %1% ---", 1113, -1);'')';
DECLARE TOP_DOWN_INFO LITERALLY '99', TOP_ERR LITERALLY '5',
        TOP_DOWN_VER LITERALLY '15', TOP_ONLYF LITERALLY '5',
        TOP_ONLYC LITERALLY '6';
COMMON BASED DOWN_INFO RECORD DYNAMIC:
       DOWN_UNKN                   FIXED    ,     /*  UNKNOWN ERROR   */
       DOWN_STMT                   CHARACTER,     /*  STMT NUMBER     */
       DOWN_VER(TOP_DOWN_VER)      BIT(9)   ,     /*  1 IF DOWNGRADE  */
       DOWN_ERR(TOP_ERR)           CHARACTER,     /*  ERROR NUMBER    */
       DOWN_CLS                    CHARACTER,     /*  ERROR CLASS     */
END;                                              /*  SUCCESSFUL      */
COMMON (I, J, K, DOWN_INFO_RECORD_SIZE) FIXED, C CHARACTER, A(5), D(3);
COMMON BASED ONLYF FIXED;
COMMON BASED ONLYC CHARACTER;
DECLARE MOVEABLE FIXED INITIAL(1);
declare digits(15) character 
                        initial('0', '1', '2', '3', '4', '5', '6', '7',
                                '8', '9', 'A', 'B', 'C', 'D', 'E', 'F');

hexFREELIMIT: procedure;
    declare value fixed, i FIXED;
    declare message character;
    value = FREELIMIT;
    message = '';
    do i = 1 to 8;
        message = digits(value mod 16) || message;
        value = value / 16;
    end;
    output = 'FREELIMIT = ' || message;
end;

call hexFREELIMIT;
MSG(A);
RECORD_CONSTANT(ONLYF, TOP_ONLYF, MOVEABLE);
RECORD_USED(ONLYF) = RECORD_ALLOC(ONLYF);
call hexFREELIMIT;
MSG(B);
RECORD_CONSTANT(ONLYC, TOP_ONLYC, MOVEABLE);
RECORD_USED(ONLYC) = RECORD_ALLOC(ONLYC);
call hexFREELIMIT;
MSG(C);
ALLOCATE_SPACE(DOWN_INFO, TOP_DOWN_INFO, MOVEABLE);
RECORD_USED(DOWN_INFO) = 96;
call hexFREELIMIT;
MSG(D);

DOWN_INFO(3).DOWN_STMT = 'Hello, I''m here!';
output = '"' || DOWN_INFO(3).DOWN_STMT || '"';
do i = 1 to 8;
    output = i;
    NEXT_ELEMENT(DOWN_INFO);
    call hexFREELIMIT;
    MSG(D1);
end;
output = '"' || DOWN_INFO(3).DOWN_STMT || '"';

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
call hexFREELIMIT;
MSG(E);

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
