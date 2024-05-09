/*

   Arithmetic test program designed to test the ARITHEMIT function of the XPL 
   compiler.

   Author:  Daniel Weaver

*/

DECLARE NE LITERALLY '~=',
   LT LITERALLY '<';

DECLARE SIX CHARACTER INITIAL('123456'),
   (A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U, V, W, X, Y, 
    Z) FIXED,
   VW1 FIXED INITIAL(1),
   VH1 BIT(16) INITIAL(1),
   VB1 BIT(8) INITIAL(1),

   VW2 FIXED INITIAL(2),
   VH2 BIT(16) INITIAL(2),
   VB2 BIT(8) INITIAL(2),

   VW5 FIXED INITIAL(5),
   VH5 BIT(16) INITIAL(5),
   VB5 BIT(8) INITIAL(5),

   VW7 FIXED INITIAL(7),
   VH7 BIT(16) INITIAL(7),
   VB7 BIT(8) INITIAL(7),

   VW15 FIXED INITIAL(15),
   VH15 BIT(16) INITIAL(15),
   VB15 BIT(8) INITIAL(15),

   VW8 FIXED INITIAL(8),
   VW30 FIXED INITIAL(30),
   VW60 FIXED INITIAL(60),
   VW255 FIXED INITIAL(255),

   AW1(16) BIT(32) INITIAL(0, 0, 0, 0, 0, 0, 0, 0, 1),
   AH1(16) BIT(16) INITIAL(0, 0, 0, 0, 0, 0, 0, 0, 1),
   AB1(16) BIT(8) INITIAL(0, 0, 0, 0, 0, 0, 0, 0, 1),

   AW2(16) BIT(32) INITIAL(0, 0, 0, 0, 0, 0, 0, 0, 2),
   AH2(16) BIT(16) INITIAL(0, 0, 0, 0, 0, 0, 0, 0, 2),
   AB2(16) BIT(8) INITIAL(0, 0, 0, 0, 0, 0, 0, 0, 2),

   AW5(16) BIT(32) INITIAL(0, 0, 0, 0, 0, 0, 0, 0, 5),
   AH5(16) BIT(16) INITIAL(0, 0, 0, 0, 0, 0, 0, 0, 5),
   AB5(16) BIT(8) INITIAL(0, 0, 0, 0, 0, 0, 0, 0, 5),

   AW7(16) BIT(32) INITIAL(0, 0, 0, 0, 0, 0, 0, 0, 7),
   AH7(16) BIT(16) INITIAL(0, 0, 0, 0, 0, 0, 0, 0, 7),
   AB7(16) BIT(8) INITIAL(0, 0, 0, 0, 0, 0, 0, 0, 7),

   WW(16) FIXED,

   S6(16) CHARACTER INITIAL('', '', '', '', '', '', '', '', '123456'),

   ZERO FIXED,
   ERROR_COUNT FIXED;

DECLARE W_60 FIXED, H_60 BIT(16), B_60 BIT(8);

CLEAR_STORAGE_ARRAY:
   PROCEDURE;
      DECLARE I FIXED;

      DO I = 0 TO 16;
         WW(I) = 0;
      END;
   END CLEAR_STORAGE_ARRAY;

HEX:
   PROCEDURE(V, L) CHARACTER;
      DECLARE (V, I, L) FIXED,
         S CHARACTER,
         HEX_DIGITS CHARACTER INITIAL('0123456789ABCDEF');

      S = '';
      DO I = 32 - SHL(L, 2) TO 28 BY 4;
         S = S || SUBSTR(HEX_DIGITS, SHR(V, 28 - I) & 15, 1);
      END;
      RETURN S;
   END HEX;

INITIALIZATION:
   PROCEDURE;
      I = 60;
      W_60 = COREWORD(SHR(I, 2));
      H_60 = COREHALFWORD(SHR(I, 1));
      B_60 = COREBYTE(I);
      OUTPUT = 'COREWORD(15) = ' || HEX(W_60, 8);
   END INITIALIZATION;

ERROR:
   PROCEDURE(V, S);
      DECLARE (S, H) CHARACTER, V FIXED;
      H = HEX(V, 8);
      OUTPUT = 'ERROR: ' || H || '  ' || S || ' FAILED';
      ERROR_COUNT = ERROR_COUNT + 1;
   END ERROR;

TEST_ADD:
   PROCEDURE;;
      OUTPUT = 'TEST ADD';
      A = VW1 + VW2;
      B = ZERO + VW1 + VW2;
      C = VW1 + (VW2 + ZERO);
      D = VW1 + 2;
      E = ZERO + VW1 + 2;
      F = 1 + (VW2 + ZERO);
      G = 1 + 2;
      H = COREWORD(VW15) + 1;
      I = COREWORD(15) + 1;
      J = 1 + COREWORD(VW15);
      K = 1 + COREWORD(15);
      L = ZERO + COREWORD(15);
      M = ZERO + ZERO + COREWORD(15);
      N = AW1(VW8) + 1;
      O = AW1(8) + 1;
      P = 1 + AW1(VW8);
      Q = 1 + AW1(8);

      IF A NE 3 THEN CALL ERROR(A, 'VW1 + VW2');
      IF B NE 3 THEN CALL ERROR(B, 'ZERO + VW1 + VW2');
      IF C NE 3 THEN CALL ERROR(C, 'VW1 + (VW2 + ZERO)');
      IF D NE 3 THEN CALL ERROR(D, 'VW1 + 2');
      IF E NE 3 THEN CALL ERROR(E, 'ZERO + VW1 + 2');
      IF F NE 3 THEN CALL ERROR(F, '1 + (VW2 + ZERO)');
      IF G NE 3 THEN CALL ERROR(G, '1 + 2');
      IF H NE W_60 + 1 THEN CALL ERROR(H, 'COREWORD(VW15) + 1');
      IF I NE W_60 + 1 THEN CALL ERROR(I, 'COREWORD(15) + 1');
      IF J NE W_60 + 1 THEN CALL ERROR(J, '1 + COREWORD(VW15)');
      IF K NE W_60 + 1 THEN CALL ERROR(K, '1 + COREWORD(15)');
      IF L NE W_60 THEN CALL ERROR(L, 'ZERO + COREWORD(15)');
      IF M NE W_60 THEN CALL ERROR(M, 'ZERO + ZERO + COREWORD(15)');
      IF N NE 2 THEN CALL ERROR(N, 'AW1(VW8) + 1');
      IF O NE 2 THEN CALL ERROR(O, 'AW1(8) + 1');
      IF P NE 2 THEN CALL ERROR(P, '1 + AW1(VW8)');
      IF Q NE 2 THEN CALL ERROR(Q, '1 + AW1(8)');

      /* HALFWORD */
      A = VH1 + VH2;
      B = ZERO + VH1 + VH2;
      C = VH1 + (VH2 + ZERO);
      D = VH1 + 2;
      E = ZERO + VH1 + 2;
      F = 1 + (VH2 + ZERO);
      G = 1 + 2;
      H = COREHALFWORD(VW30) + 1;
      I = COREHALFWORD(30) + 1;
      J = 1 + COREHALFWORD(VW30);
      K = 1 + COREHALFWORD(30);
      L = ZERO + COREHALFWORD(30);
      M = ZERO + ZERO + COREHALFWORD(30);
      N = AH1(VW8) + 1;
      O = AH1(8) + 1;
      P = 1 + AH1(VW8);
      Q = 1 + AH1(8);

      IF A NE 3 THEN CALL ERROR(A, 'VH1 + VH2');
      IF B NE 3 THEN CALL ERROR(B, 'ZERO + VH1 + VH2');
      IF C NE 3 THEN CALL ERROR(C, 'VH1 + (VH2 + ZERO)');
      IF D NE 3 THEN CALL ERROR(D, 'VH1 + 2');
      IF E NE 3 THEN CALL ERROR(E, 'ZERO + VH1 + 2');
      IF F NE 3 THEN CALL ERROR(F, '1 + (VH2 + ZERO)');
      IF G NE 3 THEN CALL ERROR(G, '1 + 2');
      IF H NE H_60 + 1 THEN CALL ERROR(H, 'COREHALFWORD(VW30) + 1');
      IF I NE H_60 + 1 THEN CALL ERROR(I, 'COREHALFWORD(30) + 1');
      IF J NE H_60 + 1 THEN CALL ERROR(J, '1 + COREHALFWORD(VW30)');
      IF K NE H_60 + 1 THEN CALL ERROR(K, '1 + COREHALFWORD(30)');
      IF L NE H_60 THEN CALL ERROR(L, 'ZERO + COREHALFWORD(30)');
      IF M NE H_60 THEN CALL ERROR(M, 'ZERO + ZERO + COREHALFWORD(30)');
      IF N NE 2 THEN CALL ERROR(N, 'AH1(VW8) + 1');
      IF O NE 2 THEN CALL ERROR(O, 'AH1(8) + 1');
      IF P NE 2 THEN CALL ERROR(P, '1 + AH1(VW8)');
      IF Q NE 2 THEN CALL ERROR(Q, '1 + AH1(8)');

      /* BYTE */
      A = VB1 + VB2;
      B = ZERO + VB1 + VB2;
      C = VB1 + (VB2 + ZERO);
      D = VB1 + 2;
      E = ZERO + VB1 + 2;
      F = 1 + (VB2 + ZERO);
      G = 1 + 2;
      H = COREBYTE(VW60) + 1;
      I = COREBYTE(60) + 1;
      J = 1 + COREBYTE(VW60);
      K = 1 + COREBYTE(60);
      L = ZERO + COREBYTE(60);
      M = ZERO + ZERO + COREBYTE(60);
      N = AB1(VW8) + 1;
      O = AB1(8) + 1;
      P = 1 + AB1(VW8);
      Q = 1 + AB1(8);

      IF A NE 3 THEN CALL ERROR(A, 'VB1 + VB2');
      IF B NE 3 THEN CALL ERROR(B, 'ZERO + VB1 + VB2');
      IF C NE 3 THEN CALL ERROR(C, 'VB1 + (VB2 + ZERO)');
      IF D NE 3 THEN CALL ERROR(D, 'VB1 + 2');
      IF E NE 3 THEN CALL ERROR(E, 'ZERO + VB1 + 2');
      IF F NE 3 THEN CALL ERROR(F, '1 + (VB2 + ZERO)');
      IF G NE 3 THEN CALL ERROR(G, '1 + 2');
      IF H NE B_60 + 1 THEN CALL ERROR(H, 'COREBYTE(VW60) + 1');
      IF I NE B_60 + 1 THEN CALL ERROR(I, 'COREBYTE(60) + 1');
      IF J NE B_60 + 1 THEN CALL ERROR(J, '1 + COREBYTE(VW60)');
      IF K NE B_60 + 1 THEN CALL ERROR(K, '1 + COREBYTE(60)');
      IF L NE B_60 THEN CALL ERROR(L, 'ZERO + COREBYTE(60)');
      IF M NE B_60 THEN CALL ERROR(M, 'ZERO + ZERO + COREBYTE(60)');
      IF N NE 2 THEN CALL ERROR(N, 'AB1(VW8) + 1');
      IF O NE 2 THEN CALL ERROR(O, 'AB1(8) + 1');
      IF P NE 2 THEN CALL ERROR(P, '1 + AB1(VW8)');
      IF Q NE 2 THEN CALL ERROR(Q, '1 + AB1(8)');

   END TEST_ADD;

TEST_SUBTRACT:
   PROCEDURE;;
      OUTPUT = 'TEST SUBSTRACT';
      A = VW2 - VW1;
      B = ZERO + VW2 - VW1;
      C = VW2 - (VW1 + ZERO);
      D = VW2 - 1;
      E = ZERO + VW2 - 1;
      F = 2 - (VW1 + ZERO);
      G = 2 - 1;
      H = COREWORD(VW15) - 1;
      I = COREWORD(15) - 1;
      J = 1 - COREWORD(VW15);
      K = 1 - COREWORD(15);
      L = ZERO - COREWORD(15);
      M = ZERO + ZERO - COREWORD(15);
      N = AW2(VW8) - 1;
      O = AW2(8) - 1;
      P = 2 - AW1(VW8);
      Q = 2 - AW1(8);
      R = VW5 - 2;

      IF A NE 1 THEN CALL ERROR(A, 'VW2 - VW1');
      IF B NE 1 THEN CALL ERROR(B, 'ZERO + VW2 - VW1');
      IF C NE 1 THEN CALL ERROR(C, 'VW2 - (VW1 + ZERO)');
      IF D NE 1 THEN CALL ERROR(D, 'VW2 - 1');
      IF E NE 1 THEN CALL ERROR(E, 'ZERO + VW2 - 1');
      IF F NE 1 THEN CALL ERROR(F, '2 - (VW1 + ZERO)');
      IF G NE 1 THEN CALL ERROR(G, '2 - 1');
      IF H NE W_60 - 1 THEN CALL ERROR(H, 'COREWORD(VW15) - 1');
      IF I NE W_60 - 1 THEN CALL ERROR(I, 'COREWORD(15) - 1');
      IF J NE 1 - W_60 THEN CALL ERROR(J, '1 - COREWORD(VW15)');
      IF K NE 1 - W_60 THEN CALL ERROR(K, '1 - COREWORD(15)');
      IF L NE -W_60 THEN CALL ERROR(L, 'ZERO - COREWORD(15)');
      IF M NE -W_60 THEN CALL ERROR(M, 'ZERO + ZERO - COREWORD(15)');
      IF N NE 1 THEN CALL ERROR(N, 'AW2(VW8) - 1');
      IF O NE 1 THEN CALL ERROR(O, 'AW2(8) - 1');
      IF P NE 1 THEN CALL ERROR(P, '2 - AW1(VW8)');
      IF Q NE 1 THEN CALL ERROR(Q, '2 - AW1(8)');
      IF R NE 3 THEN CALL ERROR(R, 'VW5 - 2');

      /* HALFWORD */
      A = VH2 - VH1;
      B = ZERO + VH2 - VH1;
      C = VH2 - (VH1 + ZERO);
      D = VH2 - 1;
      E = ZERO + VH2 - 1;
      F = 2 - (VH1 + ZERO);
      G = 2 - 1;
      H = COREHALFWORD(VW30) - 1;
      I = COREHALFWORD(30) - 1;
      J = 1 - COREHALFWORD(VW30);
      K = 1 - COREHALFWORD(30);
      L = ZERO - COREHALFWORD(30);
      M = ZERO + ZERO - COREHALFWORD(30);
      N = AH2(VW8) - 1;
      O = AH2(8) - 1;
      P = 2 - AH1(VW8);
      Q = 2 - AH1(8);

      IF A NE 1 THEN CALL ERROR(A, 'VH2 - VH1');
      IF B NE 1 THEN CALL ERROR(B, 'ZERO + VH2 - VH1');
      IF C NE 1 THEN CALL ERROR(C, 'VH2 - (VH1 + ZERO)');
      IF D NE 1 THEN CALL ERROR(D, 'VH2 - 1');
      IF E NE 1 THEN CALL ERROR(E, 'ZERO + VH2 - 1');
      IF F NE 1 THEN CALL ERROR(F, '2 - (VH1 + ZERO)');
      IF G NE 1 THEN CALL ERROR(G, '2 - 1');
      IF H NE H_60 - 1 THEN CALL ERROR(H, 'COREHALFWORD(VW30) - 1');
      IF I NE H_60 - 1 THEN CALL ERROR(I, 'COREHALFWORD(30) - 1');
      IF J NE 1 - H_60 THEN CALL ERROR(J, '1 - COREHALFWORD(VW30)');
      IF K NE 1 - H_60 THEN CALL ERROR(K, '1 - COREHALFWORD(30)');
      IF L NE -H_60 THEN CALL ERROR(L, 'ZERO - COREHALFWORD(30)');
      IF M NE -H_60 THEN CALL ERROR(M, 'ZERO + ZERO - COREHALFWORD(30)');
      IF N NE 1 THEN CALL ERROR(N, 'AH2(VW8) - 1');
      IF O NE 1 THEN CALL ERROR(O, 'AH2(8) - 1');
      IF P NE 1 THEN CALL ERROR(P, '2 - AH1(VW8)');
      IF Q NE 1 THEN CALL ERROR(Q, '2 - AH1(8)');

      /* BYTE */
      A = VB2 - VB1;
      B = ZERO + VB2 - VB1;
      C = VB2 - (VB1 + ZERO);
      D = VB2 - 1;
      E = ZERO + VB2 - 1;
      F = 2 - (VB1 + ZERO);
      G = 2 - 1;
      H = COREBYTE(VW60) - 1;
      I = COREBYTE(60) - 1;
      J = 1 - COREBYTE(VW60);
      K = 1 - COREBYTE(60);
      L = ZERO - COREBYTE(60);
      M = ZERO + ZERO - COREBYTE(60);
      N = AB2(VW8) - 1;
      O = AB2(8) - 1;
      P = 2 - AB1(VW8);
      Q = 2 - AB1(8);

      IF A NE 1 THEN CALL ERROR(A, 'VB2 - VB1');
      IF B NE 1 THEN CALL ERROR(B, 'ZERO + VB2 - VB1');
      IF C NE 1 THEN CALL ERROR(C, 'VB2 - (VB1 + ZERO)');
      IF D NE 1 THEN CALL ERROR(D, 'VB2 - 1');
      IF E NE 1 THEN CALL ERROR(E, 'ZERO + VB2 - 1');
      IF F NE 1 THEN CALL ERROR(F, '2 - (VB1 + ZERO)');
      IF G NE 1 THEN CALL ERROR(G, '2 - 1');
      IF H NE B_60 - 1 THEN CALL ERROR(H, 'COREBYTE(VW60) - 1');
      IF I NE B_60 - 1 THEN CALL ERROR(I, 'COREBYTE(60) - 1');
      IF J NE 1 - B_60 THEN CALL ERROR(J, '1 - COREBYTE(VW60)');
      IF K NE 1 - B_60 THEN CALL ERROR(K, '1 - COREBYTE(60)');
      IF L NE -B_60 THEN CALL ERROR(L, 'ZERO - COREBYTE(60)');
      IF M NE -B_60 THEN CALL ERROR(M, 'ZERO + ZERO - COREBYTE(60)');
      IF N NE 1 THEN CALL ERROR(N, 'AB2(VW8) - 1');
      IF O NE 1 THEN CALL ERROR(O, 'AB2(8) - 1');
      IF P NE 1 THEN CALL ERROR(P, '2 - AB1(VW8)');
      IF Q NE 1 THEN CALL ERROR(Q, '2 - AB1(8)');

   END TEST_SUBTRACT;

TEST_MULTIPLY:
   PROCEDURE;;
      OUTPUT = 'TEST MULTIPLY';
      A = VW5 * VW2;
      B = (ZERO + VW5) * VW2;
      C = VW5 * (VW2 + ZERO);
      D = VW5 * 2;
      E = (ZERO + VW5) * 2;
      F = 5 * (VW2 + ZERO);
      G = 5 * 2;
      H = COREWORD(VW15) * 2;
      I = COREWORD(15) * 2;
      J = 5 * COREWORD(VW15);
      K = 5 * COREWORD(15);
      L = ZERO * COREWORD(15);
      M = (ZERO + ZERO) * COREWORD(15);
      N = AW5(VW8) * 2;
      O = AW5(8) * 2;
      P = 5 * AW2(VW8);
      Q = 5 * AW2(8);

      IF A NE 10 THEN CALL ERROR(A, 'VW5 * VW2');
      IF B NE 10 THEN CALL ERROR(B, '(ZERO + VW5) * VW2');
      IF C NE 10 THEN CALL ERROR(C, 'VW5 * (VW2 + ZERO)');
      IF D NE 10 THEN CALL ERROR(D, 'VW5 * 2');
      IF E NE 10 THEN CALL ERROR(E, '(ZERO + VW5) * 2');
      IF F NE 10 THEN CALL ERROR(F, '5 * (VW2 + ZERO)');
      IF G NE 10 THEN CALL ERROR(G, '5 * 2');
      IF H NE SHL(W_60, 1) THEN CALL ERROR(H, 'COREWORD(VW15) * 2');
      IF I NE SHL(W_60, 1) THEN CALL ERROR(I, 'COREWORD(15) * 2');
      IF J NE W_60 * 5 THEN CALL ERROR(J, '5 * COREWORD(VW15)');
      IF K NE W_60 * 5 THEN CALL ERROR(K, '5 * COREWORD(15)');
      IF L NE ZERO THEN CALL ERROR(L, 'ZERO * COREWORD(15)');
      IF M NE ZERO THEN CALL ERROR(M, '(ZERO + ZERO) * COREWORD(15)');
      IF N NE 10 THEN CALL ERROR(N, 'AW5(VW8) * 2');
      IF O NE 10 THEN CALL ERROR(O, 'AW5(8) * 2');
      IF P NE 10 THEN CALL ERROR(P, '5 * AW2(VW8)');
      IF Q NE 10 THEN CALL ERROR(Q, '5 * AW2(8)');

      /* HALFWORD */
      A = VH5 * VH2;
      B = (ZERO + VH5) * VH2;
      C = VH5 * (VH2 + ZERO);
      D = VH5 * 2;
      E = (ZERO + VH5) * 2;
      F = 5 * (VH2 + ZERO);
      G = 5 * 2;
      H = COREHALFWORD(VW30) * 2;
      I = COREHALFWORD(30) * 2;
      J = 5 * COREHALFWORD(VW30);
      K = 5 * COREHALFWORD(30);
      L = ZERO * COREHALFWORD(30);
      M = (ZERO + ZERO) * COREHALFWORD(30);
      N = AH5(VW8) * 2;
      O = AH5(8) * 2;
      P = 5 * AH2(VW8);
      Q = 5 * AH2(8);

      IF A NE 10 THEN CALL ERROR(A, 'VH5 * VH2');
      IF B NE 10 THEN CALL ERROR(B, '(ZERO + VH5) * VH2');
      IF C NE 10 THEN CALL ERROR(C, 'VH5 * (VH2 + ZERO)');
      IF D NE 10 THEN CALL ERROR(D, 'VH5 * 2');
      IF E NE 10 THEN CALL ERROR(E, '(ZERO + VH5) * 2');
      IF F NE 10 THEN CALL ERROR(F, '5 * (VH2 + ZERO)');
      IF G NE 10 THEN CALL ERROR(G, '5 * 2');
      IF H NE SHL(H_60, 1) THEN CALL ERROR(H, 'COREHALFWORD(VW30) * 2');
      IF I NE SHL(H_60, 1) THEN CALL ERROR(I, 'COREHALFWORD(30) * 2');
      IF J NE H_60 * 5 THEN CALL ERROR(J, '5 * COREHALFWORD(VW30)');
      IF K NE H_60 * 5 THEN CALL ERROR(K, '5 * COREHALFWORD(30)');
      IF L NE ZERO THEN CALL ERROR(L, 'ZERO * COREHALFWORD(30)');
      IF M NE ZERO THEN CALL ERROR(M, '(ZERO + ZERO) * COREHALFWORD(30)');
      IF N NE 10 THEN CALL ERROR(N, 'AH5(VW8) * 2');
      IF O NE 10 THEN CALL ERROR(O, 'AH5(8) * 2');
      IF P NE 10 THEN CALL ERROR(P, '5 * AH2(VW8)');
      IF Q NE 10 THEN CALL ERROR(Q, '5 * AH2(8)');

      /* BYTE */
      A = VB5 * VB2;
      B = (ZERO + VB5) * VB2;
      C = VB5 * (VB2 + ZERO);
      D = VB5 * 2;
      E = (ZERO + VB5) * 2;
      F = 5 * (VB2 + ZERO);
      G = 5 * 2;
      H = COREBYTE(VW60) * 2;
      I = COREBYTE(60) * 2;
      J = 5 * COREBYTE(VW60);
      K = 5 * COREBYTE(60);
      L = ZERO * COREBYTE(60);
      M = (ZERO + ZERO) * COREBYTE(60);
      N = AB5(VW8) * 2;
      O = AB5(8) * 2;
      P = 5 * AB2(VW8);
      Q = 5 * AB2(8);

      IF A NE 10 THEN CALL ERROR(A, 'VB5 * VB2');
      IF B NE 10 THEN CALL ERROR(B, '(ZERO + VB5) * VB2');
      IF C NE 10 THEN CALL ERROR(C, 'VB5 * (VB2 + ZERO)');
      IF D NE 10 THEN CALL ERROR(D, 'VB5 * 2');
      IF E NE 10 THEN CALL ERROR(E, '(ZERO + VB5) * 2');
      IF F NE 10 THEN CALL ERROR(F, '5 * (VB2 + ZERO)');
      IF G NE 10 THEN CALL ERROR(G, '5 * 2');
      IF H NE SHL(B_60, 1) THEN CALL ERROR(H, 'COREBYTE(VW60) * 2');
      IF I NE SHL(B_60, 1) THEN CALL ERROR(I, 'COREBYTE(60) * 2');
      IF J NE B_60 * 5 THEN CALL ERROR(J, '5 * COREBYTE(VW60)');
      IF K NE B_60 * 5 THEN CALL ERROR(K, '5 * COREBYTE(60)');
      IF L NE ZERO THEN CALL ERROR(L, 'ZERO * COREBYTE(60)');
      IF M NE ZERO THEN CALL ERROR(M, '(ZERO + ZERO) * COREBYTE(60)');
      IF N NE 10 THEN CALL ERROR(N, 'AB5(VW8) * 2');
      IF O NE 10 THEN CALL ERROR(O, 'AB5(8) * 2');
      IF P NE 10 THEN CALL ERROR(P, '5 * AB2(VW8)');
      IF Q NE 10 THEN CALL ERROR(Q, '5 * AB2(8)');

   END TEST_MULTIPLY;

TEST_DIVIDE:
   PROCEDURE;;
      OUTPUT = 'TEST DIVIDE';
      CALL CLEAR_STORAGE_ARRAY;
      A = VW5 / VW2;
      B = (ZERO + VW5) / VW2;
      C = VW5 / (VW2 + ZERO);
      D = VW5 / 2;
      E = (ZERO + VW5) / 2;
      F = 5 / (VW2 + ZERO);
      G = 5 / 2;
      H = COREWORD(VW15) / 2;
      I = COREWORD(15) / 2;
      J = 5 / COREWORD(VW15);
      K = 5 / COREWORD(15);
      L = ZERO / COREWORD(15);
      M = (ZERO + ZERO) / COREWORD(15);
      N = AW5(VW8) / 2;
      O = AW5(8) / 2;
      P = 5 / AW2(VW8);
      Q = 5 / AW2(8);
      WW(VW8) = (ZERO + 100) / (ZERO + 8);

      IF A NE 2 THEN CALL ERROR(A, 'VW5 / VW2');
      IF B NE 2 THEN CALL ERROR(B, '(ZERO + VW5) / VW2');
      IF C NE 2 THEN CALL ERROR(C, 'VW5 / (VW2 + ZERO)');
      IF D NE 2 THEN CALL ERROR(D, 'VW5 / 2');
      IF E NE 2 THEN CALL ERROR(E, '(ZERO + VW5) / 2');
      IF F NE 2 THEN CALL ERROR(F, '5 / (VW2 + ZERO)');
      IF G NE 2 THEN CALL ERROR(G, '5 / 2');
      IF H NE SHR(W_60, 1) THEN CALL ERROR(H, 'COREWORD(VW15) / 2');
      IF I NE SHR(W_60, 1) THEN CALL ERROR(I, 'COREWORD(15) / 2');
      IF J NE 5 / W_60 THEN CALL ERROR(J, '5 / COREWORD(VW15)');
      IF K NE 5 / W_60 THEN CALL ERROR(K, '5 / COREWORD(15)');
      IF L NE ZERO THEN CALL ERROR(L, 'ZERO / COREWORD(15)');
      IF M NE ZERO THEN CALL ERROR(M, '(ZERO + ZERO) / COREWORD(15)');
      IF N NE 2 THEN CALL ERROR(N, 'AW5(VW8) / 2');
      IF O NE 2 THEN CALL ERROR(O, 'AW5(8) / 2');
      IF P NE 2 THEN CALL ERROR(P, '5 / AW2(VW8)');
      IF Q NE 2 THEN CALL ERROR(Q, '5 / AW2(8)');
      IF WW(VW8) NE 12 THEN CALL ERROR(WW(VW8), 
                                'WW(VW8) = (ZERO + 100) / (ZERO + 8)');
      CALL CLEAR_STORAGE_ARRAY;
      WW(VW5) = AW5(VW8) / AW2(VW8);
      IF WW(VW5) NE 2 THEN CALL ERROR(WW(VW8), 'WW(VW5) = AW5(VW8) / AW2(VW8)');

      /* HALFWORD */
      A = VH5 / VH2;
      B = (ZERO + VH5) / VH2;
      C = VH5 / (VH2 + ZERO);
      D = VH5 / 2;
      E = (ZERO + VH5) / 2;
      F = 5 / (VH2 + ZERO);
      G = 5 / 2;
      H = COREHALFWORD(VW30) / 2;
      I = COREHALFWORD(30) / 2;
      J = 5 / COREHALFWORD(VW30);
      K = 5 / COREHALFWORD(30);
      L = ZERO / COREHALFWORD(30);
      M = (ZERO + ZERO) / COREHALFWORD(30);
      N = AH5(VW8) / 2;
      O = AH5(8) / 2;
      P = 5 / AH2(VW8);
      Q = 5 / AH2(8);

      IF A NE 2 THEN CALL ERROR(A, 'VH5 / VH2');
      IF B NE 2 THEN CALL ERROR(B, '(ZERO + VH5) / VH2');
      IF C NE 2 THEN CALL ERROR(C, 'VH5 / (VH2 + ZERO)');
      IF D NE 2 THEN CALL ERROR(D, 'VH5 / 2');
      IF E NE 2 THEN CALL ERROR(E, '(ZERO + VH5) / 2');
      IF F NE 2 THEN CALL ERROR(F, '5 / (VH2 + ZERO)');
      IF G NE 2 THEN CALL ERROR(G, '5 / 2');
      IF H NE SHR(H_60, 1) THEN CALL ERROR(H, 'COREHALFWORD(VW30) / 2');
      IF I NE SHR(H_60, 1) THEN CALL ERROR(I, 'COREHALFWORD(30) / 2');
      IF J NE 5 / H_60 THEN CALL ERROR(J, '5 / COREHALFWORD(VW30)');
      IF K NE 5 / H_60 THEN CALL ERROR(K, '5 / COREHALFWORD(30)');
      IF L NE ZERO THEN CALL ERROR(L, 'ZERO / COREHALFWORD(30)');
      IF M NE ZERO THEN CALL ERROR(M, '(ZERO + ZERO) / COREHALFWORD(30)');
      IF N NE 2 THEN CALL ERROR(N, 'AH5(VW8) / 2');
      IF O NE 2 THEN CALL ERROR(O, 'AH5(8) / 2');
      IF P NE 2 THEN CALL ERROR(P, '5 / AH2(VW8)');
      IF Q NE 2 THEN CALL ERROR(Q, '5 / AH2(8)');

      /* BYTE */
      A = VB5 / VB2;
      B = (ZERO + VB5) / VB2;
      C = VB5 / (VB2 + ZERO);
      D = VB5 / 2;
      E = (ZERO + VB5) / 2;
      F = 5 / (VB2 + ZERO);
      G = 5 / 2;
      H = COREBYTE(VW60) / 2;
      I = COREBYTE(60) / 2;
      J = 5 / COREBYTE(VW60);
      K = 5 / COREBYTE(60);
      L = ZERO / COREBYTE(60);
      M = (ZERO + ZERO) / COREBYTE(60);
      N = AB5(VW8) / 2;
      O = AB5(8) / 2;
      P = 5 / AB2(VW8);
      Q = 5 / AB2(8);

      IF A NE 2 THEN CALL ERROR(A, 'VB5 / VB2');
      IF B NE 2 THEN CALL ERROR(B, '(ZERO + VB5) / VB2');
      IF C NE 2 THEN CALL ERROR(C, 'VB5 / (VB2 + ZERO)');
      IF D NE 2 THEN CALL ERROR(D, 'VB5 / 2');
      IF E NE 2 THEN CALL ERROR(E, '(ZERO + VB5) / 2');
      IF F NE 2 THEN CALL ERROR(F, '5 / (VB2 + ZERO)');
      IF G NE 2 THEN CALL ERROR(G, '5 / 2');
      IF H NE SHR(B_60, 1) THEN CALL ERROR(H, 'COREBYTE(VW60) / 2');
      IF I NE SHR(B_60, 1) THEN CALL ERROR(I, 'COREBYTE(60) / 2');
      IF J NE 5 / B_60 THEN CALL ERROR(J, '5 / COREBYTE(VW60)');
      IF K NE 5 / B_60 THEN CALL ERROR(K, '5 / COREBYTE(60)');
      IF L NE ZERO THEN CALL ERROR(L, 'ZERO / COREBYTE(60)');
      IF M NE ZERO THEN CALL ERROR(M, '(ZERO + ZERO) / COREBYTE(60)');
      IF N NE 2 THEN CALL ERROR(N, 'AB5(VW8) / 2');
      IF O NE 2 THEN CALL ERROR(O, 'AB5(8) / 2');
      IF P NE 2 THEN CALL ERROR(P, '5 / AB2(VW8)');
      IF Q NE 2 THEN CALL ERROR(Q, '5 / AB2(8)');

   END TEST_DIVIDE;

TEST_MOD:
   PROCEDURE;;
      OUTPUT = 'TEST MOD';
      CALL CLEAR_STORAGE_ARRAY;
      A = VW5 MOD VW2;
      B = (ZERO + VW5) MOD VW2;
      C = VW5 MOD (VW2 + ZERO);
      D = VW5 MOD 2;
      E = (ZERO + VW5) MOD 2;
      F = 5 MOD (VW2 + ZERO);
      G = 5 MOD 2;
      H = COREWORD(VW15) MOD 2;
      I = COREWORD(15) MOD 2;
      J = 5 MOD COREWORD(VW15);
      K = 5 MOD COREWORD(15);
      L = ZERO MOD COREWORD(15);
      M = (ZERO + ZERO) MOD COREWORD(15);
      N = AW5(VW8) MOD 2;
      O = AW5(8) MOD 2;
      P = 5 MOD AW2(VW8);
      Q = 5 MOD AW2(8);
      WW(VW8) = (ZERO + 100) MOD (ZERO + 8);

      IF A NE 1 THEN CALL ERROR(A, 'VW5 MOD VW2');
      IF B NE 1 THEN CALL ERROR(B, '(ZERO + VW5) MOD VW2');
      IF C NE 1 THEN CALL ERROR(C, 'VW5 MOD (VW2 + ZERO)');
      IF D NE 1 THEN CALL ERROR(D, 'VW5 MOD 2');
      IF E NE 1 THEN CALL ERROR(E, '(ZERO + VW5) MOD 2');
      IF F NE 1 THEN CALL ERROR(F, '5 MOD (VW2 + ZERO)');
      IF G NE 1 THEN CALL ERROR(G, '5 MOD 2');
      IF H NE (W_60 & 1) THEN CALL ERROR(H, 'COREWORD(VW15) MOD 2');
      IF I NE (W_60 & 1) THEN CALL ERROR(I, 'COREWORD(15) MOD 2');
      IF J NE 5 MOD W_60 THEN CALL ERROR(J, '5 MOD COREWORD(VW15)');
      IF K NE 5 MOD W_60 THEN CALL ERROR(K, '5 MOD COREWORD(15)');
      IF L NE ZERO THEN CALL ERROR(L, 'ZERO MOD COREWORD(15)');
      IF M NE ZERO THEN CALL ERROR(M, '(ZERO + ZERO) MOD COREWORD(15)');
      IF N NE 1 THEN CALL ERROR(N, 'AW5(VW8) MOD 2');
      IF O NE 1 THEN CALL ERROR(O, 'AW5(8) MOD 2');
      IF P NE 1 THEN CALL ERROR(P, '5 MOD AW2(VW8)');
      IF Q NE 1 THEN CALL ERROR(Q, '5 MOD AW2(8)');
      IF WW(VW8) NE 4 THEN CALL ERROR(WW(VW8), 
                                    'WW(VW8) = (ZERO + 100) MOD (ZERO + 8)');
      CALL CLEAR_STORAGE_ARRAY;
      WW(VW5) = AW5(VW8) MOD AW2(VW8);
      IF WW(VW5) NE 1 THEN CALL ERROR(WW(VW8), 
                                    'WW(VW5) = AW5(VW8) MOD AW2(VW8)');

      /* HALFWORD */
      A = VH5 MOD VH2;
      B = (ZERO + VH5) MOD VH2;
      C = VH5 MOD (VH2 + ZERO);
      D = VH5 MOD 2;
      E = (ZERO + VH5) MOD 2;
      F = 5 MOD (VH2 + ZERO);
      G = 5 MOD 2;
      H = COREHALFWORD(VW30) MOD 2;
      I = COREHALFWORD(30) MOD 2;
      J = 5 MOD COREHALFWORD(VW30);
      K = 5 MOD COREHALFWORD(30);
      L = ZERO MOD COREHALFWORD(30);
      M = (ZERO + ZERO) MOD COREHALFWORD(30);
      N = AH5(VW8) MOD 2;
      O = AH5(8) MOD 2;
      P = 5 MOD AH2(VW8);
      Q = 5 MOD AH2(8);

      IF A NE 1 THEN CALL ERROR(A, 'VH5 MOD VH2');
      IF B NE 1 THEN CALL ERROR(B, '(ZERO + VH5) MOD VH2');
      IF C NE 1 THEN CALL ERROR(C, 'VH5 MOD (VH2 + ZERO)');
      IF D NE 1 THEN CALL ERROR(D, 'VH5 MOD 2');
      IF E NE 1 THEN CALL ERROR(E, '(ZERO + VH5) MOD 2');
      IF F NE 1 THEN CALL ERROR(F, '5 MOD (VH2 + ZERO)');
      IF G NE 1 THEN CALL ERROR(G, '5 MOD 2');
      IF H NE (H_60 & 1) THEN CALL ERROR(H, 'COREHALFWORD(VW30) MOD 2');
      IF I NE (H_60 & 1) THEN CALL ERROR(I, 'COREHALFWORD(30) MOD 2');
      IF J NE 5 MOD H_60 THEN CALL ERROR(J, '5 MOD COREHALFWORD(VW30)');
      IF K NE 5 MOD H_60 THEN CALL ERROR(K, '5 MOD COREHALFWORD(30)');
      IF L NE ZERO THEN CALL ERROR(L, 'ZERO MOD COREHALFWORD(30)');
      IF M NE ZERO THEN CALL ERROR(M, '(ZERO + ZERO) MOD COREHALFWORD(30)');
      IF N NE 1 THEN CALL ERROR(N, 'AH5(VW8) MOD 2');
      IF O NE 1 THEN CALL ERROR(O, 'AH5(8) MOD 2');
      IF P NE 1 THEN CALL ERROR(P, '5 MOD AH2(VW8)');
      IF Q NE 1 THEN CALL ERROR(Q, '5 MOD AH2(8)');

      /* BYTE */
      A = VB5 MOD VB2;
      B = (ZERO + VB5) MOD VB2;
      C = VB5 MOD (VB2 + ZERO);
      D = VB5 MOD 2;
      E = (ZERO + VB5) MOD 2;
      F = 5 MOD (VB2 + ZERO);
      G = 5 MOD 2;
      H = COREBYTE(VW60) MOD 2;
      I = COREBYTE(60) MOD 2;
      J = 5 MOD COREBYTE(VW60);
      K = 5 MOD COREBYTE(60);
      L = ZERO MOD COREBYTE(60);
      M = (ZERO + ZERO) MOD COREBYTE(60);
      N = AB5(VW8) MOD 2;
      O = AB5(8) MOD 2;
      P = 5 MOD AB2(VW8);
      Q = 5 MOD AB2(8);

      IF A NE 1 THEN CALL ERROR(A, 'VB5 MOD VB2');
      IF B NE 1 THEN CALL ERROR(B, '(ZERO + VB5) MOD VB2');
      IF C NE 1 THEN CALL ERROR(C, 'VB5 MOD (VB2 + ZERO)');
      IF D NE 1 THEN CALL ERROR(D, 'VB5 MOD 2');
      IF E NE 1 THEN CALL ERROR(E, '(ZERO + VB5) MOD 2');
      IF F NE 1 THEN CALL ERROR(F, '5 MOD (VB2 + ZERO)');
      IF G NE 1 THEN CALL ERROR(G, '5 MOD 2');
      IF H NE (B_60 & 1) THEN CALL ERROR(H, 'COREBYTE(VW60) MOD 2');
      IF I NE (B_60 & 1) THEN CALL ERROR(I, 'COREBYTE(60) MOD 2');
      IF J NE 5 MOD B_60 THEN CALL ERROR(J, '5 MOD COREBYTE(VW60)');
      IF K NE 5 MOD B_60 THEN CALL ERROR(K, '5 MOD COREBYTE(60)');
      IF L NE ZERO THEN CALL ERROR(L, 'ZERO MOD COREBYTE(60)');
      IF M NE ZERO THEN CALL ERROR(M, '(ZERO + ZERO) MOD COREBYTE(60)');
      IF N NE 1 THEN CALL ERROR(N, 'AB5(VW8) MOD 2');
      IF O NE 1 THEN CALL ERROR(O, 'AB5(8) MOD 2');
      IF P NE 1 THEN CALL ERROR(P, '5 MOD AB2(VW8)');
      IF Q NE 1 THEN CALL ERROR(Q, '5 MOD AB2(8)');

   END TEST_MOD;

TEST_AND:
   PROCEDURE;;
      DECLARE LSB FIXED;

      OUTPUT = 'TEST AND';
      A = VW7 & VW2;
      B = ZERO + VW7 & VW2;
      C = VW7 & (VW2 + ZERO);
      D = VW7 & 2;
      E = ZERO + VW7 & 2;
      F = 7 & (VW2 + ZERO);
      G = 7 & 2;
      H = COREWORD(VW15) & 255;
      I = COREWORD(15) & 255;
      J = 255 & COREWORD(VW15);
      K = 255 & COREWORD(15);
      L = VW255 & COREWORD(15);
      M = ZERO + VW255 & COREWORD(15);
      N = AW7(VW8) & 2;
      O = AW7(8) & 2;
      P = 7 & AW2(VW8);
      Q = 7 & AW2(8);

      LSB = W_60 & 255;
      IF A NE 2 THEN CALL ERROR(A, 'VW7 & VW2');
      IF B NE 2 THEN CALL ERROR(B, 'ZERO + VW7 & VW2');
      IF C NE 2 THEN CALL ERROR(C, 'VW7 & (VW2 + ZERO)');
      IF D NE 2 THEN CALL ERROR(D, 'VW7 & 2');
      IF E NE 2 THEN CALL ERROR(E, 'ZERO + VW7 & 2');
      IF F NE 2 THEN CALL ERROR(F, '7 & (VW2 + ZERO)');
      IF G NE 2 THEN CALL ERROR(G, '7 & 2');
      IF H NE LSB THEN CALL ERROR(H, 'COREWORD(VW15) & 255');
      IF I NE LSB THEN CALL ERROR(I, 'COREWORD(15) & 255');
      IF J NE LSB THEN CALL ERROR(J, '255 & COREWORD(VW15)');
      IF K NE LSB THEN CALL ERROR(K, '255 & COREWORD(15)');
      IF L NE LSB THEN CALL ERROR(L, 'VW255 & COREWORD(15)');
      IF M NE LSB THEN CALL ERROR(M, 'ZERO + VW255 & COREWORD(15)');
      IF N NE 2 THEN CALL ERROR(N, 'AW7(VW8) & 2');
      IF O NE 2 THEN CALL ERROR(O, 'AW7(8) & 2');
      IF P NE 2 THEN CALL ERROR(P, '7 & AW2(VW8)');
      IF Q NE 2 THEN CALL ERROR(Q, '7 & AW2(8)');

      /* HALFWORD */
      A = VH7 & VH2;
      B = ZERO + VH7 & VH2;
      C = VH7 & (VH2 + ZERO);
      D = VH7 & 2;
      E = ZERO + VH7 & 2;
      F = 7 & (VH2 + ZERO);
      G = 7 & 2;
      H = COREHALFWORD(VW30) & 255;
      I = COREHALFWORD(30) & 255;
      J = 255 & COREHALFWORD(VW30);
      K = 255 & COREHALFWORD(30);
      L = VW255 & COREHALFWORD(30);
      M = ZERO + VW255 & COREHALFWORD(30);
      N = AH7(VW8) & 2;
      O = AH7(8) & 2;
      P = 7 & AH2(VW8);
      Q = 7 & AH2(8);

      LSB = H_60 & 255;
      IF A NE 2 THEN CALL ERROR(A, 'VH7 & VH2');
      IF B NE 2 THEN CALL ERROR(B, 'ZERO + VH7 & VH2');
      IF C NE 2 THEN CALL ERROR(C, 'VH7 & (VH2 + ZERO)');
      IF D NE 2 THEN CALL ERROR(D, 'VH7 & 2');
      IF E NE 2 THEN CALL ERROR(E, 'ZERO + VH7 & 2');
      IF F NE 2 THEN CALL ERROR(F, '7 & (VH2 + ZERO)');
      IF G NE 2 THEN CALL ERROR(G, '7 & 2');
      IF H NE LSB THEN CALL ERROR(H, 'COREHALFWORD(VW30) & 255');
      IF I NE LSB THEN CALL ERROR(I, 'COREHALFWORD(30) & 255');
      IF J NE LSB THEN CALL ERROR(J, '255 & COREHALFWORD(VW30)');
      IF K NE LSB THEN CALL ERROR(K, '255 & COREHALFWORD(30)');
      IF L NE LSB THEN CALL ERROR(L, 'VW255 & COREHALFWORD(30)');
      IF M NE LSB THEN CALL ERROR(M, 'ZERO + VW255 & COREHALFWORD(30)');
      IF N NE 2 THEN CALL ERROR(N, 'AH7(VW8) & 2');
      IF O NE 2 THEN CALL ERROR(O, 'AH7(8) & 2');
      IF P NE 2 THEN CALL ERROR(P, '7 & AH2(VW8)');
      IF Q NE 2 THEN CALL ERROR(Q, '7 & AH2(8)');

      /* BYTE */
      A = VB7 & VB2;
      B = ZERO + VB7 & VB2;
      C = VB7 & (VB2 + ZERO);
      D = VB7 & 2;
      E = ZERO + VB7 & 2;
      F = 7 & (VB2 + ZERO);
      G = 7 & 2;
      H = COREBYTE(VW60) & 15;
      I = COREBYTE(60) & 15;
      J = 15 & COREBYTE(VW60);
      K = 15 & COREBYTE(60);
      L = VB15 & COREBYTE(60);
      M = ZERO + VB15 & COREBYTE(60);
      N = AB7(VW8) & 2;
      O = AB7(8) & 2;
      P = 7 & AB2(VW8);
      Q = 7 & AB2(8);

      LSB = B_60 & 15;
      IF A NE 2 THEN CALL ERROR(A, 'VB7 & VB2');
      IF B NE 2 THEN CALL ERROR(B, 'ZERO + VB7 & VB2');
      IF C NE 2 THEN CALL ERROR(C, 'VB7 & (VB2 + ZERO)');
      IF D NE 2 THEN CALL ERROR(D, 'VB7 & 2');
      IF E NE 2 THEN CALL ERROR(E, 'ZERO + VB7 & 2');
      IF F NE 2 THEN CALL ERROR(F, '7 & (VB2 + ZERO)');
      IF G NE 2 THEN CALL ERROR(G, '7 & 2');
      IF H NE LSB THEN CALL ERROR(H, 'COREBYTE(VW60) & 15');
      IF I NE LSB THEN CALL ERROR(I, 'COREBYTE(60) & 15');
      IF J NE LSB THEN CALL ERROR(J, '15 & COREBYTE(VW60)');
      IF K NE LSB THEN CALL ERROR(K, '15 & COREBYTE(60)');
      IF L NE LSB THEN CALL ERROR(L, 'VB15 & COREBYTE(60)');
      IF M NE LSB THEN CALL ERROR(M, 'ZERO + VB15 & COREBYTE(60)');
      IF N NE 2 THEN CALL ERROR(N, 'AB7(VW8) & 2');
      IF O NE 2 THEN CALL ERROR(O, 'AB7(8) & 2');
      IF P NE 2 THEN CALL ERROR(P, '7 & AB2(VW8)');
      IF Q NE 2 THEN CALL ERROR(Q, '7 & AB2(8)');

   END TEST_AND;

TEST_OR:
   PROCEDURE;;
      DECLARE CW FIXED;

      OUTPUT = 'TEST OR';
      A = VW1 | VW2;
      B = ZERO + VW1 | VW2;
      C = VW1 | (VW2 + ZERO);
      D = VW1 | 2;
      E = ZERO + VW1 | 2;
      F = 1 | (VW2 + ZERO);
      G = 1 | 2;
      H = COREWORD(VW15) | 15;
      I = COREWORD(15) | 15;
      J = 15 | COREWORD(VW15);
      K = 15 | COREWORD(15);
      L = VW15 | COREWORD(15);
      M = ZERO + VW15 | COREWORD(15);
      N = AW1(VW8) | 2;
      O = AW1(8) | 2;
      P = 1 | AW2(VW8);
      Q = 1 | AW2(8);

      CW = W_60 | 15;
      IF A NE 3 THEN CALL ERROR(A, 'VW1 | VW2');
      IF B NE 3 THEN CALL ERROR(B, 'ZERO + VW1 | VW2');
      IF C NE 3 THEN CALL ERROR(C, 'VW1 | (VW2 + ZERO)');
      IF D NE 3 THEN CALL ERROR(D, 'VW1 | 2');
      IF E NE 3 THEN CALL ERROR(E, 'ZERO + VW1 | 2');
      IF F NE 3 THEN CALL ERROR(F, '1 | (VW2 + ZERO)');
      IF G NE 3 THEN CALL ERROR(G, '1 | 2');
      IF H NE CW THEN CALL ERROR(H, 'COREWORD(VW15) | 15');
      IF I NE CW THEN CALL ERROR(I, 'COREWORD(15) | 15');
      IF J NE CW THEN CALL ERROR(J, '15 | COREWORD(VW15)');
      IF K NE CW THEN CALL ERROR(K, '15 | COREWORD(15)');
      IF L NE CW THEN CALL ERROR(L, 'VW15 | COREWORD(15)');
      IF M NE CW THEN CALL ERROR(M, 'ZERO + VW15 | COREWORD(15)');
      IF N NE 3 THEN CALL ERROR(N, 'AW1(VW8) | 2');
      IF O NE 3 THEN CALL ERROR(O, 'AW1(8) | 2');
      IF P NE 3 THEN CALL ERROR(P, '1 | AW2(VW8)');
      IF Q NE 3 THEN CALL ERROR(Q, '1 | AW2(8)');

      /* HALFWORD */
      A = VH1 | VH2;
      B = ZERO + VH1 | VH2;
      C = VH1 | (VH2 + ZERO);
      D = VH1 | 2;
      E = ZERO + VH1 | 2;
      F = 1 | (VH2 + ZERO);
      G = 1 | 2;
      H = COREHALFWORD(VW30) | 15;
      I = COREHALFWORD(30) | 15;
      J = 15 | COREHALFWORD(VW30);
      K = 15 | COREHALFWORD(30);
      L = VH15 | COREHALFWORD(30);
      M = ZERO + VH15 | COREHALFWORD(30);
      N = AH1(VW8) | 2;
      O = AH1(8) | 2;
      P = 1 | AH2(VW8);
      Q = 1 | AH2(8);

      CW = H_60 | 15;
      IF A NE 3 THEN CALL ERROR(A, 'VH1 | VH2');
      IF B NE 3 THEN CALL ERROR(B, 'ZERO + VH1 | VH2');
      IF C NE 3 THEN CALL ERROR(C, 'VH1 | (VH2 + ZERO)');
      IF D NE 3 THEN CALL ERROR(D, 'VH1 | 2');
      IF E NE 3 THEN CALL ERROR(E, 'ZERO + VH1 | 2');
      IF F NE 3 THEN CALL ERROR(F, '1 | (VH2 + ZERO)');
      IF G NE 3 THEN CALL ERROR(G, '1 | 2');
      IF H NE CW THEN CALL ERROR(H, 'COREHALFWORD(VW30) | 15');
      IF I NE CW THEN CALL ERROR(I, 'COREHALFWORD(30) | 15');
      IF J NE CW THEN CALL ERROR(J, '15 | COREHALFWORD(VW30)');
      IF K NE CW THEN CALL ERROR(K, '15 | COREHALFWORD(30)');
      IF L NE CW THEN CALL ERROR(L, 'VH15 | COREHALFWORD(30)');
      IF M NE CW THEN CALL ERROR(M, 'ZERO + VH15 | COREHALFWORD(30)');
      IF N NE 3 THEN CALL ERROR(N, 'AH1(VW8) | 2');
      IF O NE 3 THEN CALL ERROR(O, 'AH1(8) | 2');
      IF P NE 3 THEN CALL ERROR(P, '1 | AH2(VW8)');
      IF Q NE 3 THEN CALL ERROR(Q, '1 | AH2(8)');

      /* BYTE */
      A = VB1 | VB2;
      B = ZERO + VB1 | VB2;
      C = VB1 | (VB2 + ZERO);
      D = VB1 | 2;
      E = ZERO + VB1 | 2;
      F = 1 | (VB2 + ZERO);
      G = 1 | 2;
      H = COREBYTE(VW60) | 15;
      I = COREBYTE(60) | 15;
      J = 15 | COREBYTE(VW60);
      K = 15 | COREBYTE(60);
      L = VB15 | COREBYTE(60);
      M = ZERO + VB15 | COREBYTE(60);
      N = AB1(VW8) | 2;
      O = AB1(8) | 2;
      P = 1 | AB2(VW8);
      Q = 1 | AB2(8);

      CW = B_60 | 15;
      IF A NE 3 THEN CALL ERROR(A, 'VB1 | VB2');
      IF B NE 3 THEN CALL ERROR(B, 'ZERO + VB1 | VB2');
      IF C NE 3 THEN CALL ERROR(C, 'VB1 | (VB2 + ZERO)');
      IF D NE 3 THEN CALL ERROR(D, 'VB1 | 2');
      IF E NE 3 THEN CALL ERROR(E, 'ZERO + VB1 | 2');
      IF F NE 3 THEN CALL ERROR(F, '1 | (VB2 + ZERO)');
      IF G NE 3 THEN CALL ERROR(G, '1 | 2');
      IF H NE CW THEN CALL ERROR(H, 'COREBYTE(VW60) | 15');
      IF I NE CW THEN CALL ERROR(I, 'COREBYTE(60) | 15');
      IF J NE CW THEN CALL ERROR(J, '15 | COREBYTE(VW60)');
      IF K NE CW THEN CALL ERROR(K, '15 | COREBYTE(60)');
      IF L NE CW THEN CALL ERROR(L, 'VB15 | COREBYTE(60)');
      IF M NE CW THEN CALL ERROR(M, 'ZERO + VB15 | COREBYTE(60)');
      IF N NE 3 THEN CALL ERROR(N, 'AB1(VW8) | 2');
      IF O NE 3 THEN CALL ERROR(O, 'AB1(8) | 2');
      IF P NE 3 THEN CALL ERROR(P, '1 | AB2(VW8)');
      IF Q NE 3 THEN CALL ERROR(Q, '1 | AB2(8)');

   END TEST_OR;

TEST_COMPARE:
   PROCEDURE;;
      OUTPUT = 'TEST COMPARE';
      A = VW5 > VW2;
      B = (ZERO + VW5) > VW2;
      C = VW5 > (VW2 + ZERO);
      D = VW5 > 2;
      E = (ZERO + VW5) > 2;
      F = 5 > (VW2 + ZERO);
      G = 5 > 2;
      H = COREWORD(VW15) > 2;
      I = COREWORD(15) > 2;
      J = 5 > COREWORD(VW15);
      K = 5 > COREWORD(15);
      L = ZERO > COREWORD(15);
      M = (ZERO + ZERO) > COREWORD(15);
      N = AW5(VW8) > 2;
      O = AW5(8) > 2;
      P = 5 > AW2(VW8);
      Q = 5 > AW2(8);

      IF A NE 1 THEN CALL ERROR(A, 'VW5 > VW2');
      IF B NE 1 THEN CALL ERROR(B, '(ZERO + VW5) > VW2');
      IF C NE 1 THEN CALL ERROR(C, 'VW5 > (VW2 + ZERO)');
      IF D NE 1 THEN CALL ERROR(D, 'VW5 > 2');
      IF E NE 1 THEN CALL ERROR(E, '(ZERO + VW5) > 2');
      IF F NE 1 THEN CALL ERROR(F, '5 > (VW2 + ZERO)');
      IF G NE 1 THEN CALL ERROR(G, '5 > 2');
      IF H NE 1 THEN CALL ERROR(H, 'COREWORD(VW15) > 2');
      IF I NE 1 THEN CALL ERROR(I, 'COREWORD(15) > 2');
      IF J NE 0 THEN CALL ERROR(J, '5 > COREWORD(VW15)');
      IF K NE 0 THEN CALL ERROR(K, '5 > COREWORD(15)');
      IF L NE 0 THEN CALL ERROR(L, 'ZERO > COREWORD(15)');
      IF M NE 0 THEN CALL ERROR(M, '(ZERO + ZERO) > COREWORD(15)');
      IF N NE 1 THEN CALL ERROR(N, 'AW5(VW8) > 2');
      IF O NE 1 THEN CALL ERROR(O, 'AW5(8) > 2');
      IF P NE 1 THEN CALL ERROR(P, '5 > AW2(VW8)');
      IF Q NE 1 THEN CALL ERROR(Q, '5 > AW2(8)');

      /* HALFWORD */
      A = VH5 > VH2;
      B = (ZERO + VH5) > VH2;
      C = VH5 > (VH2 + ZERO);
      D = VH5 > 2;
      E = (ZERO + VH5) > 2;
      F = 5 > (VH2 + ZERO);
      G = 5 > 2;
      H = COREHALFWORD(VW30) > 2;
      I = COREHALFWORD(30) > 2;
      J = 5 > COREHALFWORD(VW30);
      K = 5 > COREHALFWORD(30);
      L = ZERO > COREHALFWORD(30);
      M = (ZERO + ZERO) > COREHALFWORD(30);
      N = AH5(VW8) > 2;
      O = AH5(8) > 2;
      P = 5 > AH2(VW8);
      Q = 5 > AH2(8);

      IF A NE 1 THEN CALL ERROR(A, 'VH5 > VH2');
      IF B NE 1 THEN CALL ERROR(B, '(ZERO + VH5) > VH2');
      IF C NE 1 THEN CALL ERROR(C, 'VH5 > (VH2 + ZERO)');
      IF D NE 1 THEN CALL ERROR(D, 'VH5 > 2');
      IF E NE 1 THEN CALL ERROR(E, '(ZERO + VH5) > 2');
      IF F NE 1 THEN CALL ERROR(F, '5 > (VH2 + ZERO)');
      IF G NE 1 THEN CALL ERROR(G, '5 > 2');
      IF H NE 1 THEN CALL ERROR(H, 'COREHALFWORD(VW30) > 2');
      IF I NE 1 THEN CALL ERROR(I, 'COREHALFWORD(30) > 2');
      IF J NE 0 THEN CALL ERROR(J, '5 > COREHALFWORD(VW30)');
      IF K NE 0 THEN CALL ERROR(K, '5 > COREHALFWORD(30)');
      IF L NE 0 THEN CALL ERROR(L, 'ZERO > COREHALFWORD(30)');
      IF M NE 0 THEN CALL ERROR(M, '(ZERO + ZERO) > COREHALFWORD(30)');
      IF N NE 1 THEN CALL ERROR(N, 'AH5(VW8) > 2');
      IF O NE 1 THEN CALL ERROR(O, 'AH5(8) > 2');
      IF P NE 1 THEN CALL ERROR(P, '5 > AH2(VW8)');
      IF Q NE 1 THEN CALL ERROR(Q, '5 > AH2(8)');

      /* BYTE */
      A = VB5 > VB2;
      B = (ZERO + VB5) > VB2;
      C = VB5 > (VB2 + ZERO);
      D = VB5 > 2;
      E = (ZERO + VB5) > 2;
      F = 5 > (VB2 + ZERO);
      G = 5 > 2;
      H = COREBYTE(VW60) > 2;
      I = COREBYTE(60) > 2;
      J = 5 > COREBYTE(VW60);
      K = 5 > COREBYTE(60);
      L = ZERO > COREBYTE(60);
      M = (ZERO + ZERO) > COREBYTE(60);
      N = AB5(VW8) > 2;
      O = AB5(8) > 2;
      P = 5 > AB2(VW8);
      Q = 5 > AB2(8);

      IF A NE 1 THEN CALL ERROR(A, 'VB5 > VB2');
      IF B NE 1 THEN CALL ERROR(B, '(ZERO + VB5) > VB2');
      IF C NE 1 THEN CALL ERROR(C, 'VB5 > (VB2 + ZERO)');
      IF D NE 1 THEN CALL ERROR(D, 'VB5 > 2');
      IF E NE 1 THEN CALL ERROR(E, '(ZERO + VB5) > 2');
      IF F NE 1 THEN CALL ERROR(F, '5 > (VB2 + ZERO)');
      IF G NE 1 THEN CALL ERROR(G, '5 > 2');
      IF H NE 1 THEN CALL ERROR(H, 'COREBYTE(VW60) > 2');
      IF I NE 1 THEN CALL ERROR(I, 'COREBYTE(60) > 2');
      IF J NE 0 THEN CALL ERROR(J, '5 > COREBYTE(VW60)');
      IF K NE 0 THEN CALL ERROR(K, '5 > COREBYTE(60)');
      IF L NE 0 THEN CALL ERROR(L, 'ZERO > COREBYTE(60)');
      IF M NE 0 THEN CALL ERROR(M, '(ZERO + ZERO) > COREBYTE(60)');
      IF N NE 1 THEN CALL ERROR(N, 'AB5(VW8) > 2');
      IF O NE 1 THEN CALL ERROR(O, 'AB5(8) > 2');
      IF P NE 1 THEN CALL ERROR(P, '5 > AB2(VW8)');
      IF Q NE 1 THEN CALL ERROR(Q, '5 > AB2(8)');

   END TEST_COMPARE;

TEST_IF_THEN_ELSE:
   PROCEDURE;;
      OUTPUT = 'TEST IF THEN ELSE';

      /* WORD */
      IF VW5 LT VW2 THEN CALL ERROR(0, 'VW5 > VW2');
      IF (ZERO + VW5) LT VW2 THEN CALL ERROR(0, '(ZERO + VW5) > VW2');
      IF VW5 LT (VW2 + ZERO) THEN CALL ERROR(0, 'VW5 > (VW2 + ZERO)');
      IF (ZERO + VW5) LT 2 THEN CALL ERROR(0, 'VW5 > 2');
      IF (ZERO + VW5) LT 2 THEN CALL ERROR(0, '(ZERO + VW5) > 2');
      IF 5 LT (VW2 + ZERO) THEN CALL ERROR(0, '5 > (VW2 + ZERO)');
      IF 5 LT 2 THEN CALL ERROR(0, '5 > 2');
      IF COREWORD(VW15) LT 2 THEN CALL ERROR(0, 'COREWORD(VW15) > 2');
      IF COREWORD(15) LT 2 THEN CALL ERROR(0, 'COREWORD(15) > 2');
      IF 5 LT COREWORD(VW15) THEN; ELSE CALL ERROR(1, '5 > COREWORD(VW15)');
      IF 5 LT COREWORD(15) THEN; ELSE CALL ERROR(1, '5 > COREWORD(15)');
      IF ZERO LT COREWORD(15) THEN; ELSE CALL ERROR(1, 'ZERO > COREWORD(15)');
      IF (ZERO + ZERO) LT COREWORD(15) THEN;
      ELSE CALL ERROR(1, '(ZERO + ZERO) > COREWORD(15)');
      IF AW5(VW8) LT 2 THEN CALL ERROR(0, 'AW5(VW8) > 2');
      IF AW5(8) LT 2 THEN CALL ERROR(0, 'AW5(8) > 2');
      IF 5 LT AW2(VW8) THEN CALL ERROR(0, '5 > AW2(VW8)');
      IF 5 LT AW2(8) THEN CALL ERROR(0, '5 > AW2(8)');

      /* HALFWORD */
      IF VH5 LT VH2 THEN CALL ERROR(0, 'VH5 > VH2');
      IF (ZERO + VH5) LT VH2 THEN CALL ERROR(0, '(ZERO + VH5) > VH2');
      IF VH5 LT (VH2 + ZERO) THEN CALL ERROR(0, 'VH5 > (VH2 + ZERO)');
      IF VH5 LT 2 THEN CALL ERROR(0, 'VH5 > 2');
      IF (ZERO + VH5) LT 2 THEN CALL ERROR(0, '(ZERO + VH5) > 2');
      IF 5 LT (VH2 + ZERO) THEN CALL ERROR(0, '5 > (VH2 + ZERO)');
      IF 5 LT 2 THEN CALL ERROR(0, '5 > 2');
      IF COREHALFWORD(VW30) LT 2 THEN CALL ERROR(0, 'COREHALFWORD(VW30) > 2');
      IF COREHALFWORD(30) LT 2 THEN CALL ERROR(0, 'COREHALFWORD(30) > 2');
      IF 5 LT COREHALFWORD(VW30) THEN; 
      ELSE CALL ERROR(1, '5 > COREHALFWORD(VW30)');
      IF 5 LT COREHALFWORD(30) THEN; 
      ELSE CALL ERROR(1, '5 > COREHALFWORD(30)');
      IF ZERO LT COREHALFWORD(30) THEN; 
      ELSE CALL ERROR(1, 'ZERO > COREHALFWORD(30)');
      IF (ZERO + ZERO) LT COREHALFWORD(30) THEN;
      ELSE CALL ERROR(1, '(ZERO + ZERO) > COREHALFWORD(30)');
      IF AH5(VW8) LT 2 THEN CALL ERROR(0, 'AH5(VW8) > 2');
      IF AH5(8) LT 2 THEN CALL ERROR(0, 'AH5(8) > 2');
      IF 5 LT AH2(VW8) THEN CALL ERROR(0, '5 > AH2(VW8)');
      IF 5 LT AH2(8) THEN CALL ERROR(0, '5 > AH2(8)');

      /* BYTE */
      IF VB5 LT VB2 THEN CALL ERROR(0, 'VB5 > VB2');
      IF (ZERO + VB5) LT VB2 THEN CALL ERROR(0, '(ZERO + VB5) > VB2');
      IF VB5 LT (VB2 + ZERO) THEN CALL ERROR(0, 'VB5 > (VB2 + ZERO)');
      IF VB5 LT 2 THEN CALL ERROR(0, 'VB5 > 2');
      IF (ZERO + VB5) LT 2 THEN CALL ERROR(0, '(ZERO + VB5) > 2');
      IF 5 LT (VB2 + ZERO) THEN CALL ERROR(0, '5 > (VB2 + ZERO)');
      IF 5 LT 2 THEN CALL ERROR(0, '5 > 2');
      IF COREBYTE(VW60) LT 2 THEN CALL ERROR(0, 'COREBYTE(VW60) > 2');
      IF COREBYTE(60) LT 2 THEN CALL ERROR(0, 'COREBYTE(60) > 2');
      IF 5 LT COREBYTE(VW60) THEN; ELSE CALL ERROR(1, '5 > COREBYTE(VW60)');
      IF 5 LT COREBYTE(60) THEN; ELSE CALL ERROR(1, '5 > COREBYTE(60)');
      IF ZERO LT COREBYTE(60) THEN; ELSE CALL ERROR(1, 'ZERO > COREBYTE(60)');
      IF (ZERO + ZERO) LT COREBYTE(60) THEN;
      ELSE CALL ERROR(1, '(ZERO + ZERO) > COREBYTE(60)');
      IF AB5(VW8) LT 2 THEN CALL ERROR(0, 'AB5(VW8) > 2');
      IF AB5(8) LT 2 THEN CALL ERROR(0, 'AB5(8) > 2');
      IF 5 LT AB2(VW8) THEN CALL ERROR(0, '5 > AB2(VW8)');
      IF 5 LT AB2(8) THEN CALL ERROR(0, '5 > AB2(8)');

      /* STRING */
      IF LENGTH(SIX) LT 6 THEN CALL ERROR(0, 'LENGTH(SIX) < 6');
      IF 6 LT LENGTH(SIX) THEN CALL ERROR(0, '6 < LENGTH(SIX)');
      IF 0 NE LENGTH(SIX) THEN; ELSE CALL ERROR(1, '0 ~= LENGTH(SIX)');
      IF LENGTH(SIX) NE 0 THEN; ELSE CALL ERROR(1, 'LENGTH(SIX) ~= 0');
      IF LENGTH(S6(VW8)) LT 2 THEN CALL ERROR(0, 'LENGTH(S6(VW8)) < 2');
      IF LENGTH(S6(8)) LT 2 THEN CALL ERROR(0, 'LENGTH(S6(8)) < 2');
      IF 5 LT LENGTH(S6(VW8)) THEN; ELSE CALL ERROR(1, '5 < LENGTH(S6(VW8))');
      IF 5 LT LENGTH(S6(8)) THEN; ELSE CALL ERROR(1, '5 < LENGTH(S6(8))');
   END TEST_IF_THEN_ELSE;

TEST_OP_CONDITION:
   PROCEDURE;;
      OUTPUT = 'TEST OP CONDITION';
      A = VW5 > VW2 & VW15 < VW1;
      B = VW5 > VW2 & VW15 <= VW1;
      C = VW5 > VW2 & VW15 = VW1;
      D = VW5 > VW2 & VW15 > VW1;
      E = VW5 > VW2 & VW15 >= VW1;
      F = VW5 > VW2 & VW15 ~< VW1;
      G = VW5 > VW2 & VW15 ~> VW1;
      H = VW5 > VW2 & VW15 ~= VW1;

      I = VW5 < VW2 & VW15 < VW1;
      J = VW5 < VW2 & VW15 <= VW1;
      K = VW5 < VW2 & VW15 = VW1;
      L = VW5 < VW2 & VW15 > VW1;
      M = VW5 < VW2 & VW15 >= VW1;
      N = VW5 < VW2 & VW15 ~< VW1;
      O = VW5 < VW2 & VW15 ~> VW1;
      P = VW5 < VW2 & VW15 ~= VW1;

      IF A NE 0 THEN CALL ERROR(A, 'VW5 > VW2 & VW15 < VW1');
      IF B NE 0 THEN CALL ERROR(B, 'VW5 > VW2 & VW15 <= VW1');
      IF C NE 0 THEN CALL ERROR(C, 'VW5 > VW2 & VW15 = VW1');
      IF D NE 1 THEN CALL ERROR(D, 'VW5 > VW2 & VW15 > VW1');
      IF E NE 1 THEN CALL ERROR(E, 'VW5 > VW2 & VW15 >= VW1');
      IF F NE 1 THEN CALL ERROR(F, 'VW5 > VW2 & VW15 ~< VW1');
      IF G NE 0 THEN CALL ERROR(G, 'VW5 > VW2 & VW15 ~> VW1');
      IF H NE 1 THEN CALL ERROR(H, 'VW5 > VW2 & VW15 ~= VW1');

      IF I NE 0 THEN CALL ERROR(I, 'VW5 < VW2 & VW15 < VW1');
      IF J NE 0 THEN CALL ERROR(J, 'VW5 < VW2 & VW15 <= VW1');
      IF K NE 0 THEN CALL ERROR(K, 'VW5 < VW2 & VW15 = VW1');
      IF L NE 0 THEN CALL ERROR(L, 'VW5 < VW2 & VW15 > VW1');
      IF M NE 0 THEN CALL ERROR(M, 'VW5 < VW2 & VW15 >= VW1');
      IF N NE 0 THEN CALL ERROR(N, 'VW5 < VW2 & VW15 ~< VW1');
      IF O NE 0 THEN CALL ERROR(O, 'VW5 < VW2 & VW15 ~> VW1');
      IF P NE 0 THEN CALL ERROR(P, 'VW5 < VW2 & VW15 ~= VW1');

      A = VW5 > VW2 | VW15 < VW1;
      B = VW5 > VW2 | VW15 <= VW1;
      C = VW5 > VW2 | VW15 = VW1;
      D = VW5 > VW2 | VW15 > VW1;
      E = VW5 > VW2 | VW15 >= VW1;
      F = VW5 > VW2 | VW15 ~< VW1;
      G = VW5 > VW2 | VW15 ~> VW1;
      H = VW5 > VW2 | VW15 ~= VW1;

      I = VW5 < VW2 | VW15 < VW1;
      J = VW5 < VW2 | VW15 <= VW1;
      K = VW5 < VW2 | VW15 = VW1;
      L = VW5 < VW2 | VW15 > VW1;
      M = VW5 < VW2 | VW15 >= VW1;
      N = VW5 < VW2 | VW15 ~< VW1;
      O = VW5 < VW2 | VW15 ~> VW1;
      P = VW5 < VW2 | VW15 ~= VW1;

      IF A NE 1 THEN CALL ERROR(A, 'VW5 > VW2 | VW15 < VW1');
      IF B NE 1 THEN CALL ERROR(B, 'VW5 > VW2 | VW15 <= VW1');
      IF C NE 1 THEN CALL ERROR(C, 'VW5 > VW2 | VW15 = VW1');
      IF D NE 1 THEN CALL ERROR(D, 'VW5 > VW2 | VW15 > VW1');
      IF E NE 1 THEN CALL ERROR(E, 'VW5 > VW2 | VW15 >= VW1');
      IF F NE 1 THEN CALL ERROR(F, 'VW5 > VW2 | VW15 ~< VW1');
      IF G NE 1 THEN CALL ERROR(G, 'VW5 > VW2 | VW15 ~> VW1');
      IF H NE 1 THEN CALL ERROR(H, 'VW5 > VW2 | VW15 ~= VW1');

      IF I NE 0 THEN CALL ERROR(I, 'VW5 < VW2 | VW15 < VW1');
      IF J NE 0 THEN CALL ERROR(J, 'VW5 < VW2 | VW15 <= VW1');
      IF K NE 0 THEN CALL ERROR(K, 'VW5 < VW2 | VW15 = VW1');
      IF L NE 1 THEN CALL ERROR(L, 'VW5 < VW2 | VW15 > VW1');
      IF M NE 1 THEN CALL ERROR(M, 'VW5 < VW2 | VW15 >= VW1');
      IF N NE 1 THEN CALL ERROR(N, 'VW5 < VW2 | VW15 ~< VW1');
      IF O NE 0 THEN CALL ERROR(O, 'VW5 < VW2 | VW15 ~> VW1');
      IF P NE 1 THEN CALL ERROR(P, 'VW5 < VW2 | VW15 ~= VW1');

      A = (VW5 > VW2) + (VW15 < VW1);
      B = (VW5 > VW2) + (VW15 <= VW1);
      C = (VW5 > VW2) + (VW15 = VW1);
      D = (VW5 > VW2) + (VW15 > VW1);
      E = (VW5 > VW2) + (VW15 >= VW1);
      F = (VW5 > VW2) + (VW15 ~< VW1);
      G = (VW5 > VW2) + (VW15 ~> VW1);
      H = (VW5 > VW2) + (VW15 ~= VW1);

      I = (VW5 < VW2) + (VW15 < VW1);
      J = (VW5 < VW2) + (VW15 <= VW1);
      K = (VW5 < VW2) + (VW15 = VW1);
      L = (VW5 < VW2) + (VW15 > VW1);
      M = (VW5 < VW2) + (VW15 >= VW1);
      N = (VW5 < VW2) + (VW15 ~< VW1);
      O = (VW5 < VW2) + (VW15 ~> VW1);
      P = (VW5 < VW2) + (VW15 ~= VW1);

      IF A NE 1 THEN CALL ERROR(A, '(VW5 > VW2) + (VW15 < VW1)');
      IF B NE 1 THEN CALL ERROR(B, '(VW5 > VW2) + (VW15 <= VW1)');
      IF C NE 1 THEN CALL ERROR(C, '(VW5 > VW2) + (VW15 = VW1)');
      IF D NE 2 THEN CALL ERROR(D, '(VW5 > VW2) + (VW15 > VW1)');
      IF E NE 2 THEN CALL ERROR(E, '(VW5 > VW2) + (VW15 >= VW1)');
      IF F NE 2 THEN CALL ERROR(F, '(VW5 > VW2) + (VW15 ~< VW1)');
      IF G NE 1 THEN CALL ERROR(G, '(VW5 > VW2) + (VW15 ~> VW1)');
      IF H NE 2 THEN CALL ERROR(H, '(VW5 > VW2) + (VW15 ~= VW1)');

      IF I NE 0 THEN CALL ERROR(I, '(VW5 < VW2) + (VW15 < VW1)');
      IF J NE 0 THEN CALL ERROR(J, '(VW5 < VW2) + (VW15 <= VW1)');
      IF K NE 0 THEN CALL ERROR(K, '(VW5 < VW2) + (VW15 = VW1)');
      IF L NE 1 THEN CALL ERROR(L, '(VW5 < VW2) + (VW15 > VW1)');
      IF M NE 1 THEN CALL ERROR(M, '(VW5 < VW2) + (VW15 >= VW1)');
      IF N NE 1 THEN CALL ERROR(N, '(VW5 < VW2) + (VW15 ~< VW1)');
      IF O NE 0 THEN CALL ERROR(O, '(VW5 < VW2) + (VW15 ~> VW1)');
      IF P NE 1 THEN CALL ERROR(P, '(VW5 < VW2) + (VW15 ~= VW1)');

   END TEST_OP_CONDITION;

CALL INITIALIZATION;
CALL TEST_ADD;
CALL TEST_SUBTRACT;
CALL TEST_MULTIPLY;
CALL TEST_DIVIDE;
CALL TEST_MOD;
CALL TEST_AND;
CALL TEST_OR;
CALL TEST_COMPARE;
CALL TEST_IF_THEN_ELSE;
CALL TEST_OP_CONDITION;

IF ERROR_COUNT = 0 THEN OUTPUT = 'PASSED.';
ELSE OUTPUT = 'FAILED: ' || ERROR_COUNT || ' ERRORS';

RETURN ERROR_COUNT;

EOF;
