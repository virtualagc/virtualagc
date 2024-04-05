 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   PRIMTOOV.xpl
    Purpose:    This is a part of the HAL/S-FC compiler program.
    Reference:  "HAL/S Compiler Functional Specification", section 2.1.2.
    Language:   XPL.
    Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
    History:    2023-04-16 RSB  Suffixed the filename with ".xpl".
    Note:       Inline comments beginning with "/*@" were created by the
                Virtual AGC Project. Inline comments beginning merely with
                "/*" are from the original Space Shuttle development.
 */

/***************************************************************************/
/* PROCEDURE NAME:  PRIM_TO_OVFL                                           */
/* MEMBER NAME:     PRIMTOOV                                               */
/* FUNCTION RETURN TYPE:                                                   */
/*          CHARACTER                                                      */
/* INPUT PARAMETERS:                                                       */
/*          PTR               BIT(16)                                      */
/* LOCAL DECLARATIONS:                                                     */
/*          ALPHASEQ1         CHARACTER;                                   */
/*          ALPHASEQ2         CHARACTER;                                   */
/*          ALPHASEQ3         CHARACTER;                                   */
/*          ALPHASEQ4         CHARACTER;                                   */
/*          ASEQ_CHAR         CHARACTER;                                   */
/*          N                 BIT(8)                                       */
/*          PRIME_NAME        CHARACTER;                                   */
/* EXTERNAL PROCEDURES CALLED:                                             */
/*          ESD_TABLE                                                      */
/* CALLED BY:                                                              */
/*          INITIALISE                                                     */
/***************************************************************************/
/*********                          CALL TREE                      *********/
/***************************************************************************/
/* ==> PRIM_TO_OVFL <==                                                    */
/*     ==> ESD_TABLE                                                       */
/***************************************************************************/
                                                                                00617510
 /*THIS PROCEDURE CONVERTS PRIMARY  TO OVERFLOW NAMES*/                         00617520
PRIM_TO_OVFL:                                                                   00617530
   PROCEDURE(PTR) CHARACTER;                                                    00617540
      DECLARE PTR BIT(16);                                                      00617550
      DECLARE N BIT(8);                                                         00617560
      DECLARE (PRIME_NAME,ASEQ_CHAR) CHARACTER;                                 00617570
      DECLARE ALPHASEQ1 CHARACTER INITIAL('123456789ABCDEF');                   00617580
      DECLARE ALPHASEQ2 CHARACTER INITIAL('GHIJKLMNOPQRSTU');                   00617590
      DECLARE ALPHASEQ3 CHARACTER INITIAL('ABCDEFGHIJKLM');                     00617600
      DECLARE ALPHASEQ4 CHARACTER INITIAL('NOPQRSTUVWXYZ');                     00617610
      PRIME_NAME=ESD_TABLE(PTR);                                                00617620
      IF SUBSTR(PRIME_NAME,0,2)= '#C' THEN                                      00617630
         RETURN '$W'||SUBSTR(PRIME_NAME,2);                                     00617640
      IF SUBSTR(PRIME_NAME,0,2)='$0' THEN                                       00617650
         RETURN '$V'||SUBSTR(PRIME_NAME,2);                                     00617660
      IF SUBSTR(PRIME_NAME,0,2)='#D' THEN                                       00617670
         RETURN '#S'||SUBSTR(PRIME_NAME,2);                                     00617680
      IF SUBSTR(PRIME_NAME,0,2)='#P' THEN                                       00617690
         RETURN '#V'||SUBSTR(PRIME_NAME,2);                                     00617700
      IF SUBSTR(PRIME_NAME,0,2)='#R' THEN                                       00617710
         RETURN '#U'||SUBSTR(PRIME_NAME,2);                                     00617720
      N=0;                                                                      00617730
      ASEQ_CHAR=SUBSTR(PRIME_NAME,1,1);                                         00617740
      IF SUBSTR(PRIME_NAME,0,1)='$' THEN                                        00617750
         DO WHILE N<16;                                                         00617760
         IF SUBSTR(ALPHASEQ1,N,1)=ASEQ_CHAR THEN                                00617770
            RETURN '$'||SUBSTR(ALPHASEQ2,N,1)||SUBSTR(PRIME_NAME,2);            00617780
         N=N+1;                                                                 00617790
      END;                                                                      00617800
      N=0;                                                                      00617810
      ASEQ_CHAR=SUBSTR(PRIME_NAME,0,1);                                         00617820
      IF BYTE(SUBSTR(PRIME_NAME,1,1))>=BYTE('0') &                              00617830
         BYTE(SUBSTR(PRIME_NAME,1,1))<=BYTE('9') THEN                           00617840
         DO WHILE N<22;                                                         00617850
         IF SUBSTR(ALPHASEQ3,N,1)=ASEQ_CHAR THEN                                00617860
            RETURN SUBSTR(ALPHASEQ4,N,1)||SUBSTR(PRIME_NAME,1);                 00617870
         N=N+1;                                                                 00617880
      END;                                                                      00617890
      RETURN;                                                                   00617900
   END PRIM_TO_OVFL;                                                            00617910
