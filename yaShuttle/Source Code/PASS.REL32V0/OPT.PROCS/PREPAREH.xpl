 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   PREPAREH.xpl
    Purpose:    This is a part of optimizer of the HAL/S-FC compiler program.
    Reference:  "HAL/S Compiler Functional Specification", section 2.4.
    Language:   XPL.
    Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
    History:    2022-12-08 RSB  Suffixed the filename with ".xpl".
    Note:       Inline comments beginning with "/*@" were created by the 
                Virtual AGC Project. Inline comments beginning merely with 
                "/*" are from the original Space Shuttle development.
 */
 
 /***************************************************************************/
 /* PROCEDURE NAME:  PREPARE_HALMAT                                         */
 /* MEMBER NAME:     PREPAREH                                               */
 /* INPUT PARAMETERS:                                                       */
 /*          BLOCK_FLAG        BIT(8)                                       */
 /* LOCAL DECLARATIONS:                                                     */
 /*          CHECK_NEW         LABEL                                        */
 /*          CHECK_FBRA        LABEL                                        */
 /*          FLAG_LOC          BIT(16)                                      */
 /*          IFLAG             BIT(8)                                       */
 /*          NEST_LEVEL(20)    BIT(16)                                      */
 /*          NEW(20)           BIT(16)                                      */
 /*          OPCOPT            BIT(16)                                      */
 /*          OPDECODE          LABEL                                        */
 /*          OPNUM             BIT(16)                                      */
 /*          OPRTR             BIT(16)                                      */
 /*          OPTAG             BIT(16)                                      */
 /*          ROW               BIT(16)                                      */
 /*          START(20)         BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          CALL_LEVEL#                                                    */
 /*          FALSE                                                          */
 /*          FOR                                                            */
 /*          NEGMAX                                                         */
 /*          POSMAX                                                         */
 /*          SIZE                                                           */
 /*          TRUE                                                           */
 /*          XBNEQ                                                          */
 /*          XCFOR                                                          */
 /*          XCTST                                                          */
 /*          XDLPE                                                          */
 /*          XD                                                             */
 /*          XFBRA                                                          */
 /*          XICLS                                                          */
 /*          XIDEF                                                          */
 /*          XILT                                                           */
 /*          XNOP                                                           */
 /*          XN                                                             */
 /*          XREAD                                                          */
 /*          XSFND                                                          */
 /*          XSFST                                                          */
 /*          XSMRK                                                          */
 /*          XWRIT                                                          */
 /*          XXREC                                                          */
 /*          XXXAR                                                          */
 /*          XXXND                                                          */
 /*          XXXST                                                          */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          CTR                                                            */
 /*          FUNC_LEVEL                                                     */
 /*          LAST_SMRK                                                      */
 /*          NESTFUNC                                                       */
 /*          NOT_XREC                                                       */
 /*          NUMOP                                                          */
 /*          OPR                                                            */
 /*          READCTR                                                        */
 /*          RESET                                                          */
 /*          ROOM                                                           */
 /*          SMRK_CTR                                                       */
 /*          STT#                                                           */
 /*          TEMP                                                           */
 /*          TMP                                                            */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          RELOCATE                                                       */
 /*          MOVECODE                                                       */
 /*          VAC_OR_XPT                                                     */
 /*          X_BITS                                                         */
 /* CALLED BY:                                                              */
 /*          OPTIMISE                                                       */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> PREPARE_HALMAT <==                                                  */
 /*     ==> VAC_OR_XPT                                                      */
 /*     ==> X_BITS                                                          */
 /*     ==> RELOCATE                                                        */
 /*     ==> MOVECODE                                                        */
 /*         ==> ENTER                                                       */
 /***************************************************************************/
 /*                                                                         */
 /* REVISION HISTORY:                                                       */
 /*                                                                         */
 /* DATE     WHO  RLS   DR/CR #  DESCRIPTION                                */
 /*                                                                         */
 /* 03/15/91 DKB  23V2  CR11109  CLEANUP COMPILER SOURCE CODE               */
 /*                                                                         */
 /***************************************************************************/
                                                                                00996000
 /* SUBROUTINE FOR PREPARING HALMAT*/                                           00997000
PREPARE_HALMAT:                                                                 00998000
   PROCEDURE(BLOCK_FLAG);                                                       00999000
      DECLARE SIZE BIT(16),                                                     01000000
         (NEW,START,NEST_LEVEL)(CALL_LEVEL#) BIT(16),                           01001000
         (OPRTR, OPNUM, OPTAG, OPCOPT) BIT(16),                                 01002000
         (BLOCK_FLAG, IFLAG) BIT(1),                                            01003000
         FLAG_LOC BIT(16);                                                      01004000
 /* INTERNAL SUBROUTINE TO QUICKLY DECODE OPCODES */                            01005000
OPDECODE:                                                                       01006000
      PROCEDURE(CTR);                                                           01007000
         DECLARE CTR BIT(16);                                                   01008000
         OPRTR = OPR(CTR) & "FFF1";                                             01009000
         OPNUM = SHR(OPR(CTR), 16) & "FF";                                      01010000
         OPTAG = SHR(OPR(CTR), 24) & "3F";                                      01011000
         OPCOPT = SHR(OPR(CTR), 1) & "7";                                       01012000
      END OPDECODE;                                                             01013000
                                                                                01014000
 /*  MAIN CODE FOR PREPARE_HALMAT SUBROUTINE  */                                01015000
      ROOM = 0;                                                                 01015010
      RESET=CTR;                                                                01016000
      IF BLOCK_FLAG THEN SMRK_CTR, NEW = CTR;                                   01017000
      ELSE SMRK_CTR, NEW = CTR + NUMOP + 1;                                     01018000
      LAST_SMRK = SMRK_CTR;    /* HE WHO SMRKS LAST...*/                        01019000
      CALL OPDECODE(SMRK_CTR);                                                  01020000
      NOT_XREC = TRUE;                                                          01020100
      DO WHILE OPRTR ^= XSMRK;                                                  01020200
         IF OPRTR=XXREC THEN DO;                                                01021000
            NOT_XREC = FALSE;                                                   01022000
            RETURN;                                                             01023000
         END;                                                                   01024000
         SMRK_CTR=SMRK_CTR+OPNUM+1;                                             01027000
         CALL OPDECODE(SMRK_CTR);                                               01028000
      END;                                                                      01029000
      STT# = SHR(OPR(SMRK_CTR + 1),16);   /* STATEMENT NUMBER*/                 01030000
      CTR = NEW;                                                                01031000
      NEST_LEVEL, FUNC_LEVEL, NESTFUNC = 0;                                     01032000
      IFLAG = 0;                                                                01033000
      DO WHILE CTR < SMRK_CTR;                                                  01034000
         CALL OPDECODE(CTR);                                                    01035000
                                                                                01035010
         IF OPRTR = XNOP THEN DO;                                               01035020
            CTR = CTR + OPNUM + 1;                                              01035030
            IF CTR = SMRK_CTR THEN ROOM = OPNUM + 1;                            01035040
         END;                                                                   01035050
         ELSE                                                                   01035060
            IF OPRTR = XSFST | OPRTR = XXXST THEN DO;                           01036000
            NEST_LEVEL(OPTAG) = NEST_LEVEL;                                     01037000
            NEST_LEVEL = OPTAG;                                                 01038000
            IF NEST_LEVEL > 0 THEN                                              01039000
               START(NEST_LEVEL) = CTR;                                         01040000
            GO TO CHECK_NEW;                                                    01041000
         END;                                                                   01042000
         ELSE IF OPRTR = XSFND | OPRTR = XXXND THEN DO;                         01043000
            FLAG_LOC = START(OPTAG);                                            01044000
            IF OPTAG > 0 THEN                                                   01045000
               IF OPCOPT = XN THEN OPR(FLAG_LOC) = OPR(FLAG_LOC) | NEGMAX;      01046000
            NEST_LEVEL = NEST_LEVEL(OPTAG);                                     01047000
            CTR = CTR + OPNUM + 1;                                              01048000
         END;                                                                   01049000
         ELSE IF OPRTR = XFBRA THEN DO;                                         01050000
            TMP = SHR(OPR(CTR+2), 16);                                          01051000
CHECK_FBRA:                                                                     01052000
            OPRTR = OPR(TMP) & "FFF1";                                          01053000
            IF OPRTR >= XBNEQ THEN                                              01054000
               IF OPRTR <= XILT THEN                                            01055000
               OPR(TMP) = OPR(TMP) | "1000000";  /* SETS TAG = 1  */            01056000
            GO TO CHECK_NEW;                                                    01057000
         END;                                                                   01058000
         ELSE IF OPRTR = XCFOR | OPRTR = XCTST THEN DO;                         01059000
            TMP = SHR(OPR(CTR+1), 16);                                          01060000
            GO TO CHECK_FBRA;                                                   01061000
         END;                                                                   01062000
         ELSE IF OPRTR = XIDEF THEN DO;                                         01063000
            IFLAG = 1;                                                          01064000
            IF FUNC_LEVEL = 0 THEN DO;                                          01065000
               FUNC_LEVEL = OPTAG;                                              01066000
               START = CTR;                                                     01067000
            END;                                                                01068000
            CTR = CTR + OPNUM + 1;                                              01069000
         END;                                                                   01070000
         ELSE IF OPRTR = XICLS THEN DO;                                         01071000
            IF FUNC_LEVEL = OPTAG THEN DO;                                      01072000
               SIZE = CTR - START + 4;                                          01073000
               IF NEW ^= START THEN DO;                                         01074000
                  CALL MOVECODE(NEW, START, SIZE);                              01075000
                  CALL RELOCATE(NEW, START, SIZE);                              01076000
               END;                                                             01077000
               FUNC_LEVEL = 0;                                                  01078000
               IF NESTFUNC = 0 THEN DO;                                         01079000
                  CTR = START + SIZE;                                           01080000
                  NEW = NEW + SIZE;                                             01081000
                  DO FLAG_LOC = 1 TO NEST_LEVEL;                                01082000
                     START(FLAG_LOC) = START(FLAG_LOC) + SIZE;                  01083000
                  END;                                                          01084000
               END;                                                             01085000
               ELSE DO;                                                         01086000
                  NESTFUNC, NEST_LEVEL = 0;                                     01087000
                  CTR = NEW + (SHR(OPR(NEW), 16) & "FF") + 1;                   01088000
               END;                                                             01089000
            END;                                                                01090000
            ELSE DO;                                                            01091000
               CTR = CTR + OPNUM + 1;                                           01092000
               IF FUNC_LEVEL > 0 THEN                                           01093000
                  NESTFUNC = FUNC_LEVEL;                                        01094000
               ELSE NEW = CTR;                                                  01095000
            END;                                                                01096000
         END;                                                                   01097000
         ELSE DO;                                                               01098000
CHECK_NEW:                                                                      01099000
            CTR = CTR + OPNUM + 1;                                              01100000
            IF NEST_LEVEL = 0 & FUNC_LEVEL = 0 THEN                             01101000
               IF OPCOPT = XN THEN                                              01102000
               NEW = CTR;                                                       01103000
         END;                                                                   01104000
      END;                                                                      01105000
      CTR = RESET;                                                              01106000
      CALL OPDECODE(CTR);                                                       01107000
      IF BLOCK_FLAG THEN NEW = CTR;                                             01108000
      ELSE NEW, CTR = CTR + OPNUM + 1;                                          01109000
      FUNC_LEVEL, NEST_LEVEL, NESTFUNC = 0;                                     01110000
      DO WHILE CTR < SMRK_CTR;                                                  01111000
         CALL OPDECODE(CTR);                                                    01112000
         IF OPRTR = XSFST | OPRTR = XXXST THEN DO;                              01113000
            NEST_LEVEL(OPTAG) = NEST_LEVEL;                                     01114000
            NEST_LEVEL = OPTAG;                                                 01115000
            IF OPR(CTR) < 0 THEN                                                01116000
               IF FUNC_LEVEL = 0 THEN DO;                                       01117000
               FUNC_LEVEL = OPTAG;                                              01118000
               START = CTR;                                                     01119000
            END;                                                                01120000
            CTR = CTR + OPNUM + 1;                                              01121000
         END;                                                                   01122000
         ELSE IF OPRTR = XSFND | OPRTR = XXXND THEN DO;                         01123000
            NEST_LEVEL = NEST_LEVEL(OPTAG);                                     01124000
            IF OPCOPT = XN  & OPTAG > 0 THEN DO;                                01125000
               IF FUNC_LEVEL = OPTAG THEN DO;                                   01126000
                  SIZE = CTR - START + 1;                                       01127000
                  IF NEW ^= START THEN DO;                                      01128000
                     CALL MOVECODE(NEW, START, SIZE);                           01129000
                     CALL RELOCATE(NEW, START, SIZE);                           01130000
                  END;                                                          01131000
                  FUNC_LEVEL = 0;                                               01132000
                  IF NESTFUNC = 0 THEN DO;                                      01133000
                     CTR = START + SIZE;                                        01134000
                     NEW = NEW + SIZE;                                          01135000
                  END;                                                          01136000
                  ELSE DO;                                                      01137000
                     NESTFUNC = 0;                                              01138000
                     NEST_LEVEL = OPTAG;                                        01139000
                     CTR = NEW + (SHR(OPR(NEW), 16) & "FF") + 1;                01140000
                  END;                                                          01141000
               END;                                                             01142000
               ELSE DO;                                                         01143000
                  CTR = CTR + OPNUM + 1;                                        01144000
                  IF FUNC_LEVEL > 0 THEN                                        01145000
                     NESTFUNC = FUNC_LEVEL;                                     01146000
                  ELSE NEW = CTR;                                               01147000
               END;                                                             01148000
            END;                                                                01149000
            ELSE CTR = CTR + OPNUM + 1;                                         01150000
         END;                                                                   01151000
         ELSE DO;                                                               01152000
            CTR = CTR + OPNUM + 1;                                              01153000
            IF NEST_LEVEL = 0 THEN                                              01154000
               IF OPCOPT = XN THEN NEW = CTR;                                   01155000
         END;                                                                   01156000
      END;                                                                      01157000
      CTR = RESET;                                                              01158000
      FUNC_LEVEL = 0;                                                           01159000
      CALL OPDECODE(CTR);                                                       01160000
      IF BLOCK_FLAG THEN NEW = CTR;                                             01161000
      ELSE NEW, CTR = CTR + OPNUM + 1;                                          01162000
      DO WHILE CTR < SMRK_CTR;                                                  01163000
         CALL OPDECODE(CTR);                                                    01164000
         IF OPRTR = XDLPE THEN DO;                                              01165000
            SIZE = CTR - START(FUNC_LEVEL);                                     01166000
            IF (RESET = 0) & (NEW(FUNC_LEVEL) = 0) THEN                         01166001
               NEW(FUNC_LEVEL) = RESET + (SHR(OPR(RESET),16)&"FF") + 1;         01166002
            CALL MOVECODE(NEW(FUNC_LEVEL), START(FUNC_LEVEL), SIZE);            01167000
            CALL RELOCATE(NEW(FUNC_LEVEL), START(FUNC_LEVEL), SIZE);            01168000
         END;                                                                   01169000
         ELSE IF OPRTR = XXXST | OPRTR = XSFST THEN DO;                         01170000
            NEST_LEVEL(OPTAG) = FUNC_LEVEL;                                     01171000
            FUNC_LEVEL = OPTAG;                                                 01172000
            NEW(FUNC_LEVEL) = CTR + OPNUM + 1;                                  01173000
            OPR(CTR) = OPR(CTR) & POSMAX;                                       01174000
         END;                                                                   01175000
         ELSE IF OPRTR = XXXND | OPRTR = XSFND THEN                             01176000
            FUNC_LEVEL = NEST_LEVEL(OPTAG);                                     01177000
         ELSE IF OPRTR >= XREAD & OPRTR <= XWRIT THEN                           01178000
            READCTR = CTR;                                                      01179000
         IF (OPCOPT = XN) & (X_BITS(CTR+OPNUM+1) ^= XD) THEN                    01180000
            NEW(FUNC_LEVEL) = CTR + OPNUM + 1;                                  01181000
         ELSE IF OPCOPT = XD THEN                                               01182000
            START(FUNC_LEVEL) = CTR;                                            01183000
                                                                                01184000
         IF OPRTR ^= XXXAR THEN                                                 01185000
            DO FOR TEMP = CTR + 1 TO CTR+NUMOP;                                 01186000
            IF VAC_OR_XPT(TEMP) THEN                                            01187000
               OPR(TEMP) = OPR(TEMP) & "FFFFFFF3";                              01188000
         END;                                                                   01189000
         OPR(CTR) = OPR(CTR) & "FFFFFFF1";                                      01190000
         CTR = CTR + OPNUM + 1;                                                 01191000
      END;                                                                      01192000
      OPR(SMRK_CTR) = OPR(SMRK_CTR) & "FFFFFFF1";                               01193000
      CTR = RESET;                                                              01194000
      NUMOP = SHR(OPR(CTR), 16) & "FF";                                         01195000
   END PREPARE_HALMAT;                                                          01196000
