declare (i, j, k) fixed;

do i = 1 to 10;
    crook: do while j < 12;
        do case 2;
            output = 'sam';
            escape crook;
            repeat crook;
            output = 'O0';
            repeat;
            do; output = 'hello'; escape; output = 'goodbye'; end;
            do; output = 'O2'; repeat; output = 'snorkel'; end;
            escape;
            output = 'O4';
        end;
    end;
end;