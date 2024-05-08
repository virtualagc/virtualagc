/* For testing setjmp/longjmp vs goto */

declare i fixed;

proc1:
procedure;

    proc2:
    procedure;
        goto label1;
    end;

    go to label1;
    do i = 1 to 10; 
        goto label1;
        do while i > 6;
            goto label3;
        end;
        output = i; 
        goto label2;
    end;
    label1:
    go to label2;
end;

do i = 1 to 10; output = i; end;

label2:
call proc1;

label3:

eof
