/* A demo of DO CASE. Should output 0, 1, 2, 3, 4. */

declare x fixed, y fixed, z fixed;

do y = 0 to 5;
        
        do case 1 + y + (-1);
                output = 0;
                if x = 4 & z=12 then
                        output=26;
                else if x=20 then
                        output=42;
                else do;
                        if 6=19 then
                                output=50;
                        else
                                output = 1;
                end;
                output = 2;
                output = 3;
                output = 4;
        end;
        
end;

