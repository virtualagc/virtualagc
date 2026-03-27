C
      SUBROUTINE FINDSTR(INSTRING,CARG,CDIR,IRET)
      CHARACTER INSTRING*(*),CARG*(*),CDIR*(*)
C
      IRET = 0
      IX = LENTRIM(INSTRING)
      IXA = LENTRIM(CARG)
      IF (IXA .EQ. 0) IXA = 1
      ILOW = 1
      IHIGH = IX - IXA + 1
      IF (CDIR .EQ. 'L') THEN
        INCR = 1
        J1 = ILOW
        J2 = IHIGH
      ELSE
        J1 = IHIGH
        J2 = ILOW
        INCR = -1
      ENDIF
      DO JJ = J1,J2,INCR
        IF (INSTRING(JJ:JJ+IXA-1) .EQ. CARG) THEN
          IRET = JJ
          GO TO 10
        ENDIF
      ENDDO
  10  CONTINUE
      RETURN
      END
C
      SUBROUTINE LJUST(STRING)
      CHARACTER STRING*(*)
      CHARACTER BUFLINE*255
C
      IF (STRING .EQ. ' ') RETURN
      ICUR = LENTRIM(STRING)
      IF (ICUR .EQ. 0) RETURN
      ILOC = 0
      DO 10 II = 1,ICUR
        IF (STRING(II:II) .NE. ' ') THEN
          ILOC = II
          GO TO 20
        ENDIF
   10 CONTINUE
   20 CONTINUE
      BUFLINE = STRING(ILOC:ICUR)
      STRING = BUFLINE
      RETURN
      END
C
      SUBROUTINE CLEANIT(INSTRING)
      CHARACTER INSTRING*(*)
      IX = LENTRIM(INSTRING)
      DO II = 1,IX
        JJ = ICHAR(INSTRING(II:II))
        IF (JJ .LT. 32) THEN
          INSTRING(II:II) = ' '
        ENDIF
      ENDDO
      RETURN
      END
