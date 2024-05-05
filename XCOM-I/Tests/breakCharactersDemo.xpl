/* This test relates to PROCEDURE names having the dreaded "break characters"
   @, $, or # in them.  The 4th break character _ is, I think, okay, but we'll
   test it too. */
   
_U1:
PROCEDURE(X,Y) FIXED;
  
    _U2:
    PROCEDURE(X,Y) FIXED;
  
        _U3:
        PROCEDURE(X,Y) FIXED;
            RETURN X + Y;
        END _U3;
        
        RETURN _U3(X,Y);
    END _U2;
 
    RETURN _U2(X,Y);
END _U1;

OUTPUT = _U1(2,3);

#P1:
PROCEDURE(X,Y) FIXED;
  
    #P2:
    PROCEDURE(X,Y) FIXED;
  
        #P3:
        PROCEDURE(X,Y) FIXED;
            RETURN X + Y;
        END #P3;
        
        RETURN #P3(X,Y);
    END #P2;
 
    RETURN #P2(X,Y);
END #P1;

OUTPUT = #P1(2,3);

$D1:
PROCEDURE(X,Y) FIXED;
  
    $D2:
    PROCEDURE(X,Y) FIXED;
  
        $D3:
        PROCEDURE(X,Y) FIXED;
            RETURN X + Y;
        END $D3;
        
        RETURN $D3(X,Y);
    END $D2;
 
    RETURN $D2(X,Y);
END $D1;

OUTPUT = $D1(2,3);

@A1:
PROCEDURE(X,Y) FIXED;
  
    @A2:
    PROCEDURE(X,Y) FIXED;
  
        @A3:
        PROCEDURE(X,Y) FIXED;
            RETURN X + Y;
        END @A3;
        
        RETURN @A3(X,Y);
    END @A2;
 
    RETURN @A2(X,Y);
END @A1;

OUTPUT = @A1(2,3);

