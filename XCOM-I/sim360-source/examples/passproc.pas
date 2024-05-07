PROGRAM PASSPROC (OUTPUT);
 
   PROCEDURE P1 (PROCEDURE P2, P3);
         BEGIN P2; P3 END;
 
   FUNCTION SIMPSON (A, B: REAL; FUNCTION F (REAL): REAL): REAL;
      VAR I, N: INTEGER; S, SS, S1, S2, S4, H: REAL;
      (* F(X) IS A REAL-VALUED FUNCTION WITH A SINGLE REAL-VALUED
         PARAMETER.  THE FUNCTION MUST BE WELL-DEFINED IN THE INTERVAL
         A <= X <= B                                                   *)
      BEGIN N := 2; H := (B-A)*0.5; S1 := H*(F(A) + F(B)); S2 := 0.0;
         S4 := 4.0*H*F(A+H); S := S1 + S2 + S4;
         REPEAT SS := S; N := 2*N; H := H/2.0;
            S1 := 0.5*S1; S2 := 0.5*S2 + 0.25*S4; S4 := 0; I := 1;
            REPEAT S4 := S4 + F(A+I*H); I := I + 2
            UNTIL I > N;
            S4 := 4*H*S4; S := S1 + S2 + S4
         UNTIL ABS(S-SS) < 1.0E-5;
         SIMPSON := S/3.0
      END (* SIMPSON *) ;
 
   PROCEDURE P2;
      BEGIN WRITELN(SIMPSON(0,1,SIN)) END;
 
   PROCEDURE P3;
      BEGIN WRITELN(SIMPSON(0,1,COS)) END;
 
 PROCEDURE P5(PROCEDURE P2,P3);
   BEGIN P1(P2, P3);   WRITELN(1.0);  END;
   BEGIN P5(P2, P3) END.
