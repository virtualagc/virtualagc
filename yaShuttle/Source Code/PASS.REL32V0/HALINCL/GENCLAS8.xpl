 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   GENCLAS8.xpl
    Purpose:    Part of the HAL/S-FC compiler.
    Reference:  "HAL/S-FC & HAL/S-360 Compiler System Program Description", 
                section TBD.
    Language:   XPL.
    Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
    History:    2022-12-08 RSB  Suffixed the filename with ".xpl".
    Note:       Inline comments beginning with "/*/" were created by the 
                Virtual AGC Project. Inline comments beginning merely with 
                "/*" are from the original Space Shuttle development.
 */
 
/***************************************************************************/
/* PROCEDURE NAME:  XPLINCL                                                */
/* MEMBER NAME:     GENCLAS8                                               */
/* PURPOSE:         GENCLAS8 IS ONE OF THE GEN CLASS PROCEDURES THAT       */
/*                  IS INCLUDED BY GENERATE IN PASS2.                      */
/*                                                                         */
/* LOCAL DECLARATIONS:                                                     */
/* EXTERNAL VARIABLES REFERENCED:                                          */
/* EXTERNAL VARIABLES CHANGED:                                             */
/* CALLED BY:                                                              */
/*                                                                         */
/*  REVISION HISTORY :                                                     */
/*  ------------------                                                     */
/*  DATE   NAME  REL   DR NUMBER AND TITLE                                 */
/*                                                                         */
/*08/24/90 JCS   23V1  103780 NO RLD CARD FOR NAME VARIABLE INITIALIZED    */
/*                     TO A REMOTE COMPOOL VARIABLE                        */
/*08/24/90 LJK   23V1  103732 REMOTE VARIABLE IN INITIAL GETS ERROR        */
/*                                                                         */
/*01/21/91 DKB   23V2  CR11098  DELETE SPILL CODE FROM COMPILER            */
/*                                                                         */
/*03/05/91 RAH   23V2  CR11109 CLEANUP OF COMPILER SOURCE CODE             */
/*                                                                         */
/*07/15/91 DAS   24V0  CR11096 #DNAME - ENSURE PROPER ERROR CHECKING       */
/*                             AND ZCON CREATION FOR NAME INITIAL          */
/*                                                                         */
/*06/27/91 TEV    7V0  CR11114 MERGE BFS/PASS COMPILERS WITH CR/DR FIXES   */
/*         PMA                                                             */
/*                                                                         */
/*12/23/92 PMA    8V0  *       MERGED 7V0 AND 24V0 COMPILERS.              */
/*                             * REFERENCE 24V0 CR/DRS                     */
/*
/*04/02/93 NLM   25V0  CR11139 ADD XR4 ERROR MESSAGE FOR FCOS
/*                     RESTRICTIONS
/*
/*03/23/94 DAS   26V0  DR103791 MULTI-COPIED STRUCTURE AUTOMATIC
/*               10V0  VARIABLE INCORRECTLY INITIALIZED
/*
/*04/08/98 DCP   29V0  DR109094 BAD OBJECT CODE GENERATED WHEN A VARIABLE  */
/*               14V0           IS PASSED TO A REMOTE LIBRARY              */
/*06/12/98 DAS   29V0  DR109097 INCORRECT ZB1 OR BS123 ERROR GENERATED
/*               14V0
/*                                                                         */
/*12/11/97 DCP   29V0  DR109083 CONSTANT DOUBLE SCALAR CONVERTED TO        */
/*               14V0           CHARACTER AS SINGLE PRECISION              */
/*                                                                         */
/*10/03/97 SMR   29V0  DR109067 INDIRECT STACK ENTRY NOT RETURNED FOR      */
/*               14V0  STRUCTURE INITIALIZATION                            */
/*                                                                         */
/*09/25/97 SMR   29V0  DR109059 INDIRECT STACK ENTRY FOR EVENT NOT RETURNED*/
/*               14V0                                                      */
/*                                                                         */
/*05/30/01 JAC   31V0  DR111380 INCORRECT OBJECT CODE FOR AUTOMATIC        */
/*               16V0           INITIALIZATION                             */
/*                                                                         */
/*11/04/03 DCP   32V0  DR120230 INCORRECT FD100 ERROR FOR NAME INPUT PARM  */
/*               17V0             (MOVED THE DR109067 FIX TO GENERATE)     */
/*                                                                         */
/*09/04/02 DCP   32V0  CR13616  IMPROVE READABILITY AND ADD COMMENTS FOR   */
/*               17V0           NAME DEREFERENCES                          */
/*                                                                         */
/*02/28/02 JAC   32V0  CR13538  ALLOW MIXING OF REMOTE AND NON-REMOTE      */
/*               17V0           POINTERS                                   */
/*                                                                         */
/***************************************************************************/
   /* CLASS 8 OPERATORS - INITIALIZATION */                                     06802500
GEN_CLASS8:                                                                     06803000
   PROCEDURE;                                                                   06803500
      DECLARE ELEMENT_SIZE FIXED; /* HOLDS THE SIZE OF A STRUCTURE ELEMENT */   06803700
                                                                                06804000
   /* ROUTINE TO PICK UP LITERAL OPERANDS FOR INITIALIZATION  */                06804500
GET_INIT_LIT:                                                                   06805000
   PROCEDURE(OP, N) BIT(16);                                                    06805500
      DECLARE (OP, N, PTR) BIT(16);                                             06806000
      CALL DECODEPIP(OP);                                                       06806500
      IF TAG1 ^= LIT THEN CALL ERRORS(CLASS_DI, 105);                           06807000
      PTR = GET_STACK_ENTRY;                                                    06807500
      CALL LITERAL(OP1+N, LITTYPE, PTR);                                        06808000
      LOC(PTR) = OP1 + N;                                                       06808500
      FORM(PTR) = LIT;                                                          06809000
      N = 0;                                                                    06809500
      RETURN PTR;                                                               06810000
   END GET_INIT_LIT;                                                            06810500
                                                                                06811000
   /* ROUTINE TO SET UP SYMBOLIC INITIALIZATION OPERAND */                      06811500
SET_INIT_SYM:                                                                   06812000
   PROCEDURE(OP);                                                               06812500
      DECLARE OP BIT(16);                                                       06813000
      IF SYMFORM(FORM(OP)) THEN DO;                                             06813500
         INITOP = LOC(OP);                                                      06814000
         INITTYPE = TYPE(OP);                                                   06814500
         IF INITTYPE = CHAR THEN                                                06815000
            INITMULT = CS(SYT_DIMS(INITOP) + 2);                                06815500
         ELSE INITMULT = BIGHTS(INITTYPE);                                      06816000
         INITAUTO = (SYT_FLAGS(INITOP)&AUTO_FLAG) ^= 0;                         06816500
 /?B  /* CR11114 -- BFS/PASS INTERFACE; ADD CONSTANT PROTECTION */
         IF (SYT_FLAGS(INITOP) & CONSTANT_FLAG) ^= 0 THEN DO;
            IF ^CURR_STORE_PROTECT THEN CALL EMIT_STORE_PROTECT(TRUE);
         END;
         ELSE IF CURR_STORE_PROTECT THEN CALL EMIT_STORE_PROTECT(FALSE);
 ?/
         IF INITAUTO THEN DO;                                                   06817000
            INITADDR = 0;                                                       06817500
            CALL RESUME_LOCCTR(NARGINDEX);                                      06818000
            INITINX = INX(OP);                                                  06818500
            IF (SYT_FLAGS(INITOP) & NAME_FLAG) ^= 0 THEN ;                      06819000
            ELSE IF SYT_ARRAY(INITOP) ^= 0 & COPY(OP) ^= 0 THEN                 06819500
               INX_CON(OP) = INX_CON(OP) - SYT_CONST(INITOP);                   06820000
            ELSE IF SUBCODE = 0 & PACKTYPE(INITTYPE) = VECMAT THEN              06820500
               INX_CON(OP) = INX_CON(OP) + BIGHTS(INITTYPE);                    06821000
         END;                                                                   06821500
         ELSE INITADDR = SYT_ADDR(LOC(OP)) + INX_CON(OP);                       06822000
         IF (SYT_FLAGS(INITOP) & NAME_OR_REMOTE) = REMOTE_FLAG THEN             06822500
            INITBASE=REMOTE_LEVEL;                                              06822510
         ELSE                                                                   06822540
            INITBASE=DATABASE;                                                  06822550
            IF ((SYT_FLAGS(INITOP) & NAME_OR_REMOTE) = REMOTE_FLAG)
                & ((SYT_FLAGS(INITOP) & INCLUDED_REMOTE) = 0)
                THEN INITBASE = REMOTE_LEVEL;
                ELSE INITBASE = DATABASE;
      END;                                                                      06823000

      /***************************************************************/
      /*  CR11114 -- MODIFY PASS TO BE LIKE BFS; CHECK IF INITIAL    */
      /*             BIT STRING TOO LONG                             */
      ELSE IF PACKTYPE(SYT_TYPE(INITOP)) = BITS THEN
         SIZE(OP) = SYT_DIMS(INITOP) & "FF";
      /****** CR11114 END ********************************************/

   END SET_INIT_SYM;                                                            06823500
                                                                                06824000
   /* ROUTINE TO SET UP OPERAND STACK FOR OFFSET OPERAND  */                    06824500
SET_AUTO_INIT:                                                                  06825000
   PROCEDURE(OP);                                                               06825500
      DECLARE OP BIT(16);                                                       06826000
      IF FORM(OP) = OFFSET THEN DO;                                             06826500
         LOC(OP) = LOC(ALCOP);                                                  06827000
         TYPE(OP) = INITTYPE;                                                   06827500
         FORM(OP) = SYM;                                                        06828000
         LOC2(OP) = INITOP;                                        /*DR109094*/ 06833500
         CALL SIZEFIX(OP, INITOP);                                              06828500
         IF INITTYPE = STRUCTURE THEN INITMULT = NAMESIZE(INITOP);               6829000
         ELSE IF INITTYPE = CHAR THEN                                           06829500
            INITMULT = CS(SYT_DIMS(INITOP) + 2);                                06830000
         ELSE INITMULT = BIGHTS(INITTYPE);                                      06830500
         INX_CON(OP) = (VAL(OP)+INITINCR-INITDECR) * INITMULT + INITADDR +      06831000
            STRUCT_CON(OP) + INX_CON(ALCOP);                                     6831500
         INX(OP) = INITINX;                                                     06832000
         IF INITINX > 0 THEN                                                    06832500
            CALL INCR_USAGE(INITINX);                                            6833000
         /* ------- DAS DR103791 ------- */                                     06833500
         /* ALIGN INDEX FOR MULTI-COPIED STRUCTURE */                           06833500
         IF INITSTRUCT & SYT_ARRAY(LOC(OP)) ^= 0 THEN DO;                       06833500
         /* SET STRUCT_INX TO INDICATE MULTI-COPIED STRUCTURE */                06833500
            STRUCT_INX(OP) = 5;                                                 06833500
            CALL FIX_STRUCT_INX(0,OP);                                          06833500
         END;                                                                   06833500
         /* ------- END DR103791 ------- */                                     06833500
         CALL SUBSCRIPT_RANGE_CHECK(OP);                                        06833500
      END;                                                                      06834000
   END SET_AUTO_INIT;                                                           06834500
                                                                                06835000
   /* ROUTINE TO PURGE OUT COLLECTED DENSE INITIALIZATION */                    06835020
EMITDENSE:                                                                      06835040
   PROCEDURE;                                                                   06835060
      DECLARE J BIT(16);                                                        06835080
                                                                                06835100
      DO J = 1 TO DENSE_INX;                                                    06835120
         CALL SET_LOCCTR(INITBASE,DENSEADDR(J) & "FFFFFF");                     06835140
         DO CASE SHR(DENSEADDR(J),24);                                          06835160
            DO;                                                                 06835180
               CALL EMITC(CSTRING,1);                                           06835200
               CALL EMITW(SHL(DENSEVAL(J),24),1);                               06835220
               LOCCTR(INITBASE) = LOCCTR(INITBASE) + 1;                         06835240
            END;                                                                06835260
            CALL EMITC(0,DENSEVAL(J));                                          06835280
            DO;                                                                 06835300
               CALL EMITC(DATABLK,1);                                           06835320
               CALL EMITW(DENSEVAL(J));                                         06835340
            END;                                                                06835360
         END;                                                                   06835380
      END;                                                                      06835400
      DENSE_INX = 0;                                                            06835420
   END EMITDENSE;                                                               06835440
                                                                                06835460
   /* ROUTINE TO WALK THROUGH A STRUCTURE TO LOCATE THE NAMED TERMINAL ITEM */  06835500
STRUCTURE_WALK:                                                                 06836000
   PROCEDURE(WALK#) BIT(16);                                                    06836500
      DECLARE (WALK#, N) FIXED;                                                 06837000
      DO WHILE WALK# ^= INITWALK;                                               06837500
         IF INITWALK < 0 THEN N = 1;                                            06838000
         IF N = 1 THEN DO;                                                      06838500
            INITOP = STRUCTURE_ADVANCE;                                         06839000
            IF INITOP = 0 THEN DO;                                              06839500
               IF DENSE_INX>0 THEN CALL EMITDENSE;                              06839600
               INITOP = STRUCTURE_ADVANCE;                                      06840000
               STRUCT_MOD = STRUCT_MOD + INITMOD;                               06840500
            END;                                                                06841000
            N = LUMP_ARRAYSIZE(INITOP) * LUMP_TERMINALSIZE(INITOP);             06841500
            INITWALK, INITDECR = INITWALK + 1;                                  06842000
            IF (SYT_FLAGS(INITOP) & NAME_FLAG) ^= 0 THEN DO;                    06842500
               INITTYPE = STRUCTURE;                                            06843000
               N = 1;                                                           06843500
            END;                                                                06844000
            ELSE DO;                                                            06844500
               INITTYPE = SYT_TYPE(INITOP);                                     06845000
               IF PACKTYPE(INITTYPE) = BITS THEN                                06845500
                  DENSESHIFT = SHR(SYT_DIMS(INITOP), 8) & "FF";                 06846000
               ELSE DENSESHIFT = 0;                                             06846500
            END;                                                                06847000
            INITADDR = INITSTART + STRUCT_MOD + SYT_ADDR(INITOP);               06847500
         END;                                                                   06848000
         ELSE DO;                                                               06848500
            N = N - 1;                                                          06849000
            INITWALK = INITWALK + 1;                                            06849500
         END;                                                                   06850000
      END;                                                                      06850500
   END STRUCTURE_WALK;                                                          06851000
                                                                                06851500
   /* ROUTINE TO COLLECT DENSE INITIALIZAION */                                 06852000
SET_DENSE_VALUE:                                                                06852200
   PROCEDURE;                                                                   06852400
      DECLARE (I,J) BIT(16);                                                    06852600
                                                                                06852800
BUMP_ENTRY:                                                                     06853000
   PROCEDURE;                                                                   06853200
      DENSE_INX = DENSE_INX + 1;                                                06853400
      DENSEADDR(DENSE_INX) = DENSEADDR(0);                                      06853600
      DENSEVAL(DENSE_INX) = DENSEVAL(0);                                        06853800
   END BUMP_ENTRY;                                                              06854000
                                                                                06854200
      DENSEADDR(0) = DENSEADDR(0) | SHL(OPMODE(DENSETYPE),24);                  06854400
      IF DENSE_INX = 0 THEN DO;                                                 06854600
         CALL BUMP_ENTRY;                                                       06854800
         RETURN;                                                                06855000
      END;                                                                      06855200
      DO I = 0 TO DENSE_INX-1;                                                  06855400
         J = DENSE_INX - I;                                                     06855600
         IF DENSEADDR(J) = DENSEADDR(0) THEN DO;                                06855800
            DENSEVAL(J) = DENSEVAL(J) | DENSEVAL(0);                            06856000
            RETURN;                                                             06856200
         END;                                                                   06856400
      END;                                                                      06856600
      CALL BUMP_ENTRY;                                                          06856800
   END SET_DENSE_VALUE;                                                         06857000
                                                                                06857200
    CLASS8: DO;  /* CLASS 8  */                                                 06861000
               IF STRI_ACTIVE THEN                                              06861500
                  IF TAG_BITS(1) = OFFSET THEN DO;                              06862000
                     INITAGAIN = TYPE_BITS(2);                                  06862500
                     INITRESET = INITINCR;                                      06863000
                  END;                                                          06863500
      INITENTRY:                                                                06864000
               DO CASE SUBCODE;                                                 06864500
                  DO CASE OPCODE;                                               06865000
                     ;                                                          06865500
                     DO;  /* STRI  */                                           06866000
                        ALCOP = GET_OPERAND(1);                                 06866500
                        CALL SET_INIT_SYM(ALCOP);                               06867000
                        INITINCR, INITDECR = 0;                                 06867500
                        IF INITTYPE = STRUCTURE THEN DO;                        06868000
                           INITWALK = -1;                                       06868500
                           STRUCT_TEMPL = DEL(ALCOP);                           06869000
                           INITMOD = XVAL(ALCOP);                               06869500
                           STRUCT_MOD, STRUCT_REF = 0;                          06870000
                           INITSTART = INITADDR;                                06870500
                           INITSTRUCT = TRUE;                                   06871000
                        END;                                                    06871500
                        ELSE INITSTRUCT = FALSE;                                06872000
                        STRI_ACTIVE = TRUE;                                     06872500
                        INITREPTING = FALSE;                                     6872600
                        INITAGAIN, INITLITMOD = 0;                              06873000
                        DENSE_INX, DENSESHIFT = 0;                              06873500
                     END;                                                       06874000
                     DO;  /* SLRI  */                                           06874500
                        CALL DECODEPIP(1);                                      06875000
                        INITREPT(TAG) = OP1;                                    06875500
                        CALL DECODEPIP(2);                                      06876000
                        INITSTEP(TAG) = OP1;                                    06876500
                        INITREL(TAG) = INITINCR;                                06877000
                        INITCTR(TAG) = CTR;                                     06877500
                        INITAUX(TAG) = AUX_CTR;                                  6877600
                        INITBLK(TAG) = CURCBLK;                                 06878000
                        INITREPTING(TAG) = INITREPTING;                          6878100
                        INITREPTING = TRUE;                                      6878200
                     END;                                                       06878500
                     DO;  /* ELRI  */                                           06879000
                        INITREPT(TAG) = INITREPT(TAG) - 1;                      06879500
                        IF INITREPT(TAG) > 0 THEN DO;                           06880000
                           INITINCR = INITINCR + INITSTEP(TAG);                 06880500
                           CALL POSITION_HALMAT(INITBLK(TAG), INITCTR(TAG),      6881000
                              INITAUX(TAG));                                     6881500
                        END;                                                    06882500
                        ELSE DO;                                                 6883000
                           INITINCR = INITREL(TAG);                              6883100
                           INITREPTING = INITREPTING(TAG);                       6883200
                        END;                                                     6883300
                     END;                                                       06883500
                     DO;  /* ETRI  */                                           06884000
                        IF INITAUTO THEN                                        06884500
                           CALL DROP_INX(ALCOP);                                06885000
                        IF DENSE_INX > 0 THEN                                   06885500
                           CALL EMITDENSE;                                      06886000
                        CALL RETURN_COLUMN_STACK(ALCOP);    /*DR109059*/
                        CALL RETURN_STACK_ENTRY(ALCOP);                         06886500
                        STRI_ACTIVE, INITREPTING = FALSE;                        6887000
                     END;                                                       06887500
                  END;                                                          06888000
                  GO TO DO_IINT;  /* BINT  */                                   06888500
                  DO;  /* CINT  */                                              06889000
                     LEFTOP = GET_OPERAND(1);                                   06889500
                     CALL SET_INIT_SYM(LEFTOP);                                 06890000
                     LITTYPE = CHAR;                                            06890500
                     RIGHTOP = GET_INIT_LIT(2, INITLITMOD);                     06891000
                     DO CASE INITAUTO;                                          06891500
                        DO;  /* STATIC  */                                      06892000
                           IF FORM(LEFTOP) = SYM THEN                           06893500
                              CALL SET_LOCCTR(INITBASE, INITADDR);              06894000
                           ELSE CALL SET_LOCCTR(INITBASE, CS(SYT_DIMS(INITOP)+2)06894500
                              * (VAL(LEFTOP)+INITINCR-INITDECR) + INITADDR);    06895000
                           DUMMY = DESC(VAL(RIGHTOP));                          06896500
                           IF LENGTH(DUMMY) > SYT_DIMS(INITOP) THEN DO;         06897000
                              CALL ERRORS(CLASS_DI,102);                        06897500
                              DUMMY = SUBSTR(DUMMY, 0, SYT_DIMS(INITOP));       06898000
                           END;                                                 06898500
                           CALL EMITSTRING(DUMMY, SYT_DIMS(INITOP));            06899000
                        END;                                                    06899500
                        DO; /* AUTOMATIC  */                                    06900000
                           CALL SET_AUTO_INIT(LEFTOP);                          06900500
                           CALL CHAR_CALL(XXASN, LEFTOP, RIGHTOP, 0);           06901000
                        END;                                                    06901500
                     END;                                                       06902000
                     CALL RETURN_STACK_ENTRIES(LEFTOP, RIGHTOP);                06902500
                  END;                                                          06903000
                  DO;  /* MINT  */                                              06903500
            DO_MINT: LEFTOP = GET_OPERAND(1);                                   06904000
                     CALL SET_INIT_SYM(LEFTOP);                                 06904500
                     LITTYPE = INITTYPE;                                        06905000
                     RIGHTOP = GET_INIT_LIT(2);                                 06905500
                     DO CASE INITAUTO;                                          06906000
                        DO;  /* STATIC  */                                      06906500
                           CALL SET_LOCCTR(INITBASE, INITADDR);                 06907000
                           DO IX1 = 1 TO ROW(LEFTOP) * COLUMN(LEFTOP);          06907500
                              DO CASE (LITTYPE&8)>0;                            06908000
                                 DO;                                            06908500
                                    CALL EMITC(DATABLK, 1);                     06909000
                                    CALL EMITW(VAL(RIGHTOP));                   06909500
                                 END;                                           06910000
                                 DO;                                            06910500
                                    CALL EMITC(DATABLK, 2);                     06911000
                                    CALL EMITW(VAL(RIGHTOP));                   06911500
                                    CALL EMITW(XVAL(RIGHTOP));                  06912000
                                 END;                                           06912500
                              END;                                              06913000
                           END;                                                 06913500
                        END;                                                    06914000
                        DO;  /* AUTOMATIC  */                                   06914500
                           TARGET_REGISTER = FR0;                               06915000
                           CALL FORCE_ACCUMULATOR(RIGHTOP);                     06915500
                           CALL OFF_TARGET(RIGHTOP);                            06916000
                           TEMPSPACE = ROW(LEFTOP) * COLUMN(LEFTOP);            06916500
                           CALL VMCALL(XSASN, (INITTYPE&8)^=0, LEFTOP, 0,0,0);  06917000
                        END;                                                    06917500
                     END;                                                       06918000
                     CALL RETURN_STACK_ENTRIES(LEFTOP, RIGHTOP);                06918500
                  END;                                                          06919000
                  GO TO DO_MINT;  /* VINT  */                                   06919500
                  GO TO DO_IINT;  /*  SINT  */                                  06920000
                  DO;  /* IINT  */                                              06920500
            DO_IINT: LEFTOP = GET_OPERAND(1);                                   06921000
                     CALL SET_INIT_SYM(LEFTOP);                                 06921500
                     LITTYPE = INITTYPE;                                        06922000
                     RIGHTOP = GET_INIT_LIT(2, INITLITMOD);                     06922500
                     DO CASE INITAUTO;                                          06923000
                        DO;  /* STATIC  */                                      06923500
                           IF FORM(LEFTOP) = SYM THEN                           06924000
                              TMP = INITADDR;                                   06924500
                           ELSE TMP = INITADDR +                                06925000
                              SHL(VAL(LEFTOP)+INITINCR-INITDECR,SHIFT(INITTYPE))06925500
                                 ;                                              06926000
      /* CR11114 -- MODIFY PASS TO MERGE WITH BFS               */
      /*            INITIAL BIT STRING TOO LONG                 */
                           IF SUBCODE = BITS THEN DO;
                              CALL MASK_BIT_LIT(RIGHTOP, LEFTOP);
                              IF LOC(RIGHTOP) < 0 THEN
                                 CALL ERRORS(CLASS_DI, 102);
                           END;
      /****  END CR11114; INITIAL BIT STRING TOO LONG ***********/

                           IF DENSESHIFT ^= 0 THEN DO;                          06928000
                              IF DENSESHIFT = "FF" THEN DENSESHIFT = 0;         06928500
                      VAL(RIGHTOP)=VAL(RIGHTOP)&                                06928510
                              XITAB(SYT_DIMS(INITOP)&"FF");                     06928520
                              DENSEVAL(0) = SHL(VAL(RIGHTOP),DENSESHIFT);       06929000
                              DENSEADDR(0) = TMP;                               06929500
                              DENSETYPE = INITTYPE;                             06930000
                              CALL SET_DENSE_VALUE;                             06930500
                           END;                                                 06931000
                           ELSE DO;                                             06931500
                             CALL SET_LOCCTR(INITBASE, TMP);                    06931510
                             DO CASE OPMODE(INITTYPE);                          06931520
                              DO;                                               06932000
                                 CALL EMITC(CSTRING, 1);                        06932500
                                 CALL EMITW(SHL(VAL(RIGHTOP),24), 1);           06933000
                                 LOCCTR(INITBASE) = LOCCTR(INITBASE) + 1;       06933500
                              END;                                              06934000
                              DO;                                               06934500
                                 IF TYPE(RIGHTOP) = DINTEGER THEN               06935000
                                    CALL ERRORS(CLASS_DI,103);                  06935500
                                 CALL EMITC(0, VAL(RIGHTOP));                   06936000
                              END;                                              06936500
                              GO TO DO_WORD_INIT;                               06937000
               DO_WORD_INIT:  DO;                                               06937500
                                 CALL EMITC(DATABLK, 1);                        06938000
                                 CALL EMITW(VAL(RIGHTOP));                      06938500
                              END;                                              06939000
                              DO;                                               06939500
                                 CALL EMITC(DATABLK, 2);                        06940000
                                 CALL EMITW(VAL(RIGHTOP));                      06940500
                                 CALL EMITW(XVAL(RIGHTOP));                     06941000
                              END;                                              06941500
                             END;  /* CASE OPMODE */                            06942000
                           END;                                                 06942010
                        END;                                                    06942500
                        DO;  /* AUTOMATIC  */                                   06943000
                           CALL SET_AUTO_INIT(LEFTOP);                          06943500
                           IF SUBCODE = BITS THEN                               06944000
                              /* DR109097 - REMOVED ZB1 ERROR */                06944005
                              CALL BIT_STORE(RIGHTOP, LEFTOP);                  06944500
                           ELSE CALL GEN_STORE(RIGHTOP, LEFTOP);                06945000
                        END;                                                    06945500
                     END;                                                       06946000
                     DENSESHIFT = 0;                                            06946500
                     CALL RETURN_COLUMN_STACK(LEFTOP);  /*DR109059*/
                     CALL RETURN_STACK_ENTRIES(LEFTOP,RIGHTOP);                 06947000
                  END;  /* IINT  */                                             06947500
                 DO CASE OPCODE;                                                06948000
                  ;                                                             06948500
                  DO;  /* NINT  */                                              06949000
                     LEFTOP = GET_OPERAND(1, 2, BY_NAME_TRUE);     /*CR13616*/  06949500
                     CALL SET_INIT_SYM(LEFTOP);                                 06950000
                     LITTYPE = INTEGER;                                         06950100
                     RIGHTOP = GET_OPERAND(2, 2+(INITAUTO=0));                  06950500
                     REMOTE_ADDRS = CHECK_REMOTE(RIGHTOP);                       6950900
    /*------------------------- #DNAME - NAME INITIAL -------------*/
    /* ENSURE PROPER ERROR CHECKING FOR NAME INITIAL STATEMENT.    */
                     IF DATA_REMOTE THEN REMOTE_ADDRS = REMOTE_ADDRS |
                        (CSECT_TYPE(LOC(RIGHTOP),RIGHTOP)=LOCAL#D);
    /*-------------------------------------------------------------*/
   /*--------------  DR103732 ---------------------------------------*/
   /*    IF THE NAME VARIABLE IS NOT INITIALIZED TO A NULL, THE      */
   /*    REMOTENESS OF THE TWO OPERANDS IS CHECKED FOR COMPATIBILITY */
   /*CR13538- IF THE SOURCE IS NON-REMOTE THEN REMOTE_ADDRS FORCES A */
   /*YCON->ZCON FOR AUTOMATIC INITIALIZATION- OTHERWISE EMIT A DI107.*/

                     IF FORM(RIGHTOP) ^= LIT THEN DO;                           06954000
                     IF ^REMOTE_ADDRS  &
                        (SYT_FLAGS(INITOP)&REMOTE_FLAG) ^= 0  THEN
   /*CR13538*/               REMOTE_ADDRS = TRUE;
                     IF REMOTE_ADDRS  &
                        (SYT_FLAGS(INITOP)&REMOTE_FLAG) = 0 THEN
                             CALL ERRORS(CLASS_DI,107);
                     END;
   /*-------------------------------------------------------------*/
                     ARGPOINT = INITOP;                                         06951000
                     ARGTYPE = SYT_TYPE(INITOP);                                06951500
                     ARGNO = INITDECR;                                          06952000
                     CALL CHECK_NAME_PARM(1);                                   06952500
                     DO CASE INITAUTO;                                          06953000
                        DO;  /* STATIC  */                                      06953500
                           IF FORM(RIGHTOP) ^= LIT THEN DO;                     06954000
                              CALL SET_LOCCTR(INITBASE, INITADDR);              06955500
                              IF FORM(RIGHTOP) = CSYM | INX(RIGHTOP) ^= 0 THEN  06956000
                                 CALL ERRORS(CLASS_DI, 104);                    06956500
                              LOC2(0) = LOC2(RIGHTOP);                          06957000
                              DO CASE BLOCK_CLASS(SYT_CLASS(LOC2(0)));          06957500
                                 DO;  /* DATA NAME  */                          06958000
                                    LOC(0) = LOC(RIGHTOP);                      06958500
                                    TMP = SYT_SCOPE(LOC(0));                    06959000
                                   IF (SYT_FLAGS(INITOP)&REMOTE_FLAG) = 0 THEN   6959510
                              DO;                                               06959511
                              TMP=DATABASE(TMP);                                06959512
                              ELEMENT_SIZE = 0;                                 06959574
                              IF SYT_TYPE(LOC(0)) = STRUCTURE THEN              06959634
                                IF ^MAJOR_STRUCTURE(RIGHTOP) THEN               06959694
                                  IF ^IND_STACK(RIGHTOP).I_DSUBBED THEN         06959754
                                    IF SYT_CONST(LOC2(0)) ^= 0 THEN             06959814
                                      ELEMENT_SIZE = SYT_CONST(LOC2(0));        06959874
                              CALL EMITADDR(TMP, SYT_ADDR(LOC(0)) +             06960000
                               SYT_CONST(LOC(0)) + INX_CON(RIGHTOP) +           06960500
                               STRUCT_CON(RIGHTOP) + ELEMENT_SIZE, HADDR);      06961000
                              END;                                              06961010
                                   ELSE DO;                                     06961020
                                    IF REMOTE_ADDRS &                           06961030
                                      ((SYT_FLAGS(LOC(0))&REMOTE_FLAG) ^= 0) &
                                      ((SYT_FLAGS(LOC(0))&INCLUDED_REMOTE) =0)
                                    THEN
                                          TMP = REMOTE_LEVEL(TMP);              06961050
                                    ELSE TMP = DATABASE(TMP);                   06961060
                                    BASE(0) = SYT_BASE(LOC(0));                 06961090
                                    IF BASE(0) >= REMOTE_BASE THEN              06961100
                                       BASE(0) = BASE(0) - REMOTE_BASE;         06961110
                                    ELSE BASE(0) = 0;                           06961120
                                    ELEMENT_SIZE = 0;                           06961121
                                    IF SYT_TYPE(LOC(0)) = STRUCTURE THEN        06961122
                                      IF ^MAJOR_STRUCTURE(RIGHTOP) THEN         06961123
                                        IF ^IND_STACK(RIGHTOP).I_DSUBBED THEN   06961124
                                          IF SYT_CONST(LOC2(0)) ^= 0 THEN       06961125
                                            ELEMENT_SIZE = SYT_CONST(LOC2(0));  06961126
             /*--------------- CR13538 & #DNAME - NAME INITIAL -------------*/
             /* SET XC BIT PROPERLY FOR NAME REMOTE INITIALIZED TO          */   1949800
             /* REMOTE #D OR NON-REMOTE DATA.                               */
             /*CR13538*/            IF REMOTE_ADDRS &
             /*CR13538*/               ^CHECK_REMOTE(RIGHTOP) THEN
                                       BASE(0) = SHL(SINGLE_VALUED(LOC(0)),3);
             /*-------------------------------------------------------------*/
                                    CALL EMIT_Z_CON(0, 0, TMP, 5, TMP,          06961130
                                     SYT_ADDR(LOC(0)) + SYT_CONST(LOC(0)) +     06961140
                                     INX_CON(RIGHTOP) + STRUCT_CON(RIGHTOP) +   06961150
                                     ELEMENT_SIZE, BASE(0));                    06961160
                                 END;                                           06961170
                                 END;                                           06961500
                                 DO;  /* LABEL NAME  */                         06962000
                                    CALL EMITEVENTADDR(0);                      06962500
                                 END;                                           06964500
                              END;                                              06965000
                           END;                                                 06965500
                        END;  /* STATIC  */                                     06966000
                        DO;  /* AUTOMATIC  */                                   06966500
                           CALL SUBSCRIPT_RANGE_CHECK(RIGHTOP);                 06967000
  /*DR111380, CR13616*/    CALL FORCE_ADDRESS(LINKREG,RIGHTOP,1,FOR_NAME_TRUE); 06967500
                           FORM(RIGHTOP) = VAC;                                 06968000
                           CALL SET_AUTO_INIT(LEFTOP);                          06968500
                           IF (SYT_FLAGS(INITOP)&REMOTE_FLAG) ^= 0 THEN          6969000
                              TYPE(LEFTOP) = RPOINTER;                           6969010
       /*----------------DR103732 -------------------------------------------*/
       /*                                                                    */
       /*     THE FOLLOWING 2 LINES OF CODE WERE COMMENTED OUT BECAUSE THE   */
       /*     CHECKING OF REMOTE FLAG AND EMITTING OF DI107 ERROR ALREADY    */
       /*     BEING PERFORMED OUTSIDE OF STATIC/AUTOMATIC CASE STATEMENT.    */
       /*                                                                    */
       /*                     IF ^REMOTE_ADDRS THEN CALL ERRORS(CLASS_DI,107)*/  6969020
       /*                  END                                               */  6969030
       /*--------------------------------------------------------------------*/
                           ELSE TYPE(LEFTOP) = APOINTER;                         6969040
       /*CR13616*/         CALL GEN_STORE(RIGHTOP, LEFTOP, 0, BY_NAME_TRUE);    06969500
                        END;                                                    06970000
                     END;  /* CASE INITAUTO  */                                 06970500
                     CALL RETURN_COLUMN_STACK(RIGHTOP);   /*DR109059*/
                     CALL RETURN_STACK_ENTRIES(LEFTOP, RIGHTOP);                06971000
                     REMOTE_ADDRS = FALSE;                                       6971100
                  END;                                                          06971500
                  DO;  /* TINT  */                                              06972000
                     CALL DECODEPIP(1);                                         06972500
                     CALL STRUCTURE_WALK(OP1+INITINCR);                         06973000
                     CALL DECODEPIP(2);                                         06973500
                     IF TAG1 = LIT THEN                                         06974000
   /*MOD-DR109083*/     OP2 = LIT1(GET_LITERAL(OP1 + INITLITMOD)) & "3";        06974500
                     ELSE OP2 = -1;                                             06975000
                     DO CASE PACKTYPE(INITTYPE);                                06975500
                        IF OP2 ^= 1 THEN                                        06976000
                           CALL ERRORS(CLASS_DI,100);                           06976500
                        IF OP2 ^= 2 THEN                                        06977000
                           CALL ERRORS(CLASS_DI,100);                           06977500
                        IF OP2 ^= 0 THEN                                        06978000
                           CALL ERRORS(CLASS_DI,100);                           06978500
                        IF OP2 ^= 1 THEN                                        06979000
                           CALL ERRORS(CLASS_DI,100);                           06979500
                        IF (TAG & "80") = 0 THEN                                06980000
                           CALL ERRORS(CLASS_DI,100);                           06980500
                     END;                                                       06981000
                     SUBCODE = DATATYPE(INITTYPE);                              06981500
                     IF INITTYPE = STRUCTURE THEN SUBCODE = APOINTER;            6982000
                     ELSE IF PACKTYPE(SUBCODE) = VECMAT THEN SUBCODE = SCALAR;  06982500
                     OPCODE = XXASN;                                            06983000
                     GO TO INITENTRY;                                           06983500
                  END;  /* TINT  */                                             06984000
                  DO;  /* EINT  */                                              06984500
                     RIGHTOP = GET_OPERAND(2, 3, BY_NAME_TRUE); /*CR13616*/      6985000
                     IF TAG_BITS(2) = XPT THEN                                  06985010
                       IF (SYT_FLAGS(OP1) & NAME_FLAG) = 0 THEN                 06985020
                         STRUCT_CON(RIGHTOP)=STRUCT_CON(RIGHTOP)+SYT_CONST(OP1);06985030
                       ELSE IF COPY(RIGHTOP)>0 & (STRUCT_INX(RIGHTOP)&2)=0 THEN 06985040
                         STRUCT_CON(RIGHTOP)=STRUCT_CON(RIGHTOP)+SYT_CONST(OP1);06985050
                     CALL TRUE_INX(RIGHTOP, 0, 1);                              06985500
                     IF FORM(RIGHTOP) = CSYM | INX(RIGHTOP) ^= 0 THEN           06986000
                        CALL ERRORS(CLASS_DI, 106);                             06986500
                     IF SYT_BASE(LOC(RIGHTOP)) = TEMPBASE THEN                  06987000
                        CALL ERRORS(CLASS_DI, 106);                             06987500
                     CALL DECODEPIP(1);                                         06988000
                     SYT_ADDR(OP1) = SYT_ADDR(LOC(RIGHTOP)) +                   06988500
                        SYT_CONST(LOC(RIGHTOP)) + INX_CON(RIGHTOP) +            06989000
                        STRUCT_CON(RIGHTOP);                                    06989500
 /?P  /* CR11114 -- BFS/PASS INTERFACE; FIX EQUATE EXTERNALS BUG FOR */
      /*         -- BFS                                              */
                     IF (SYT_FLAGS(LOC(RIGHTOP))&NAME_OR_REMOTE) = REMOTE_FLAG   6990000
                        THEN SYT_BASE(OP1) = REMOTE_LEVEL;                       6990010
                     ELSE SYT_BASE(OP1) = DATABASE;                              6990020
         /* IMPLEMENTATION OF CR11139    NLM       */
                     IF DATA_REMOTE &
                        CSECT_TYPE(LOC(RIGHTOP),RIGHTOP)=LOCAL#D THEN
                        CALL ERRORS(CLASS_XR,4,
                           'EQUATE EXTERNAL TO #D SYMBOL');
         /* END OF IMPLEMENTATION OF CR11139    NLM       */
 ?/
 /?B  /* CR11114 -- BFS/PASS INTERFACE; FIX EQUATE EXTERNALS BUG FOR */
      /*         -- BFS                                              */
                     SYT_BASE(OP1) = (SYT_FLAGS(LOC(RIGHTOP))&REMOTE_FLAG) ^= 0;
 ?/
                     CALL RETURN_STACK_ENTRY(RIGHTOP);                           6990100
                  END;                                                          06990500
                 END;  /* CASE OPCODE  */                                       06991000
               END;  /* CASE SUBCODE  */                                        06991500
               IF INITAGAIN > 0 THEN DO;                                        06992000
                  INITAGAIN = INITAGAIN - 1;                                    06992500
                  IF INITAGAIN = 0 THEN DO;                                     06993000
                     INITINCR = INITRESET;                                      06993500
                     INITLITMOD = 0;                                            06994000
                  END;                                                          06994500
                  ELSE DO;                                                      06995000
                     CALL DECODEPOP(CTR);                                       06995500
                     INITINCR = INITINCR + 1;                                   06996000
                     INITLITMOD = INITLITMOD + 1;                               06996500
                     GO TO INITENTRY;                                           06997000
                  END;                                                          06997500
               END;                                                             06998000
            END CLASS8;                                                         06998500
   END GEN_CLASS8;                                                              06999000
