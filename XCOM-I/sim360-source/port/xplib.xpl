COMPACTIFY:
PROCEDURE;
   DECLARE (I, J, K, L, ND, TC, BC, DELTA) FIXED;
   DECLARE DX_SIZE LITERALLY '500', DX(DX_SIZE) BIT(16);
   DECLARE MASK FIXED INITIAL("FFFFFF"), LOWER_BOUND FIXED, TRIED BIT(1);
   DECLARE GUARD CHARACTER;

   DO TRIED = 0 TO 1;
      IF LOWER_BOUND <= FREEBASE THEN DO;
            /* SET THE LOWER_BOUND TO FREEBASE FOR A MAJOR COLLECTION */
            LOWER_BOUND = FREEBASE;
            GUARD = '';  /* GUARD IS NOT NEEDED */
         END;
      ELSE DO;
            /* THIS WILL PROTECT STRINGS THAT SPAN LOWER_BOUND */
            GUARD = SUBSTR('', LOWER_BOUND, 256);
         END;
      ND = -1;
      /* FIND THE COLLECTABLE DESCRIPTORS */
      DO I = 0 TO NDESCRIPT;
         IF (DESCRIPTOR(I) & MASK) >= LOWER_BOUND THEN
            DO;
               ND = ND + 1;
               IF ND > DX_SIZE THEN
                  DO;  /* WE HAVE TOO MANY POTENTIALLY COLLECTABLE STRINGS */
                     OUTPUT = '* * * NOTICE FROM COMPACTIFY:  DISASTROUS STRING
 OVERFLOW.   JOB ABANDONED. * * *';
                     CALL EXIT;
                  END;
               DX(ND) = I;
            END;
      END;
      /* SORT IN ASCENDING ORDER */
      K, L = ND;
      DO WHILE K <= L;
         L = -2;
         DO I = 1 TO K;
            L = I - 1;
            IF (DESCRIPTOR(DX(L)) & MASK) > (DESCRIPTOR(DX(I)) & MASK) THEN
               DO;
                  J = DX(L);  DX(L) = DX(I);  DX(I) = J;
                  K = L;
               END;
         END;
      END;
      /* MOVE THE ACTIVE STRINGS DOWN */
      FREEPOINT = LOWER_BOUND;
      TC, DELTA = 0;
      BC = 1;   /* SETUP INITIAL CONDITION */
      DO I = 0 TO ND;
         J = DESCRIPTOR(DX(I));
         IF (J & MASK) - 1 > TC THEN
            DO;
               IF DELTA > 0 THEN
                  DO K = BC TO TC;
                     COREBYTE(K - DELTA) = COREBYTE(K);
                  END;
               FREEPOINT = FREEPOINT + TC - BC + 1;
               BC = J & MASK;
               DELTA = BC - FREEPOINT;
            END;
         DESCRIPTOR(DX(I)) = J - DELTA;
         L = (J & MASK) + SHR(J, 24);
         IF TC < L THEN TC = L;
      END;
      DO K = BC TO TC;
         COREBYTE(K - DELTA) = COREBYTE(K);
      END;
      FREEPOINT = FREEPOINT + TC - BC + 1;
      IF SHL(FREELIMIT - FREEPOINT, 4) < FREELIMIT - FREEBASE THEN
         LOWER_BOUND = FREEBASE;
      ELSE
         DO;
            LOWER_BOUND = FREEPOINT;
            RETURN;
         END;
      /* THE HOPE IS THAT WE WON'T HAVE TO COLLECT ALL THE STRINGS EVERY TIME */
   END;  /* OF THE DO TRIED LOOP */
   IF FREELIMIT - FREEPOINT < 256 THEN
      DO;
         OUTPUT = '* * * NOTICE FROM COMPACTIFY:  INSUFFICIENT STRING SPACE  JOB
 ABANDONED. * * *';
         CALL EXIT;    /* FORCE ABEND */
      END;
END COMPACTIFY;
