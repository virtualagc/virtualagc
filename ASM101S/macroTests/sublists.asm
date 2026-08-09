*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    sublists.asm
*/ Purpose:     Regression test for ASM101S macro-argument semantics --
*/              multilevel sublists, the N' attribute over them, keyword
*/              parameters, arithmetic coercion of macro arguments, EBCDIC
*/              collation of character relations, and a SETA carrying a
*/              trailing comment.
*/ Reference:   virtualagc issue #1331.  The expected values are those of
*/              the Assembler H General Information Manual, GC26-3758-3
*/              (January 1974), p.13 and p.19, and of Tables 48, 49 and 58
*/              of the HLASM Language Reference, SC26-4940.  They were
*/              confirmed independently against IBM HLASM behaviour (z390
*/              mz390) and against Don Schmidt's asm101.
*/ Language:    IBM AP-101S assembly language.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ Note:        Run via regressionMacros.sh, which compares the MNOTE
*/              output against sublists.txt.
*/
*/              PROBE   a sublist is passed through verbatim, and
*/                      subscripts index into it to any depth.  A
*/                      subscript past the end yields a null string.
*/              CNT     N' counts entries, and an omitted entry still
*/                      counts.  N' of () is 1, the null string being its
*/                      single entry, and N' of a non-sublist is 1.
*/              NAMED   a named positional parameter carries a sublist the
*/                      same way, and an argument that is not a sublist
*/                      behaves as a sublist of one entry.
*/              AMAIN   keyword parameters, quoted and unquoted, and the
*/                      name field.
*/              IFPROC  a null argument is zero in an arithmetic context,
*/                      so the AIF is true and branches.  A sublist has no
*/                      arithmetic value at all, which is a program error
*/                      to diagnose rather than something to coerce.
*/              COLL    character relations collate in EBCDIC, in which a
*/                      letter sorts below a digit and lower case below
*/                      upper, and the shorter of two values of unequal
*/                      length is the lesser.  Both tests invert under
*/                      ASCII, so they pin the collation down rather than
*/                      merely being consistent with it.
*/              CMT     a SETA whose operand carries a trailing comment
*/                      must still take effect.  While it silently did
*/                      not, MACSMITH's RTURNTBL loop bound stayed at zero
*/                      and the assembly never terminated.
         GBLA  &A,&B,&C
&A       SETA  100
&B       SETA  200
&C       SETA  300
         MACRO
         PROBE
         LCLA  &I,&NS,&N2
&NS      SETA  N'&SYSLIST
&N2      SETA  N'&SYSLIST(2)
&I       SETA  1
.LOOP    MNOTE 'SYSLIST(&I)     = >&SYSLIST(&I)<'
&I       SETA  &I+1
         AIF   (&I LE &NS).LOOP
         MNOTE 'SYSLIST(2,1)    = >&SYSLIST(2,1)<'
         MNOTE 'SYSLIST(2,2)    = >&SYSLIST(2,2)<'
         MNOTE 'SYSLIST(2,2,1)  = >&SYSLIST(2,2,1)<'
         MNOTE 'SYSLIST(2,2,3)  = >&SYSLIST(2,2,3)<'
         MNOTE 'SYSLIST(2,9)    = >&SYSLIST(2,9)<'
         MNOTE 'SYSLIST(9)      = >&SYSLIST(9)<'
         MNOTE 'SYSLIST(1,1)    = >&SYSLIST(1,1)<'
         MNOTE 'N SYSLIST=&NS  N SYSLIST(2)=&N2'
         MEND
         MACRO
         CNT
         LCLA  &NS,&N1,&N2,&N22
&NS      SETA  N'&SYSLIST
&N1      SETA  N'&SYSLIST(1)
&N2      SETA  N'&SYSLIST(2)
&N22     SETA  N'&SYSLIST(2,2)
         MNOTE 'operand 2 = >&SYSLIST(2)<'
         MNOTE '  N=&NS N(1)=&N1 N(2)=&N2 N(2,2)=&N22'
         MEND
         MACRO
         NAMED &P
         MNOTE 'P=>&P< P(1)=>&P(1)< P(2)=>&P(2)<'
         MEND
         MACRO
&N       AMAIN &ACALL=NO,&TITLE=
         MNOTE 'AMAIN NAME=&N ACALL=&ACALL TITLE=&TITLE'
         MEND
         MACRO
         IFPROC
         LCLA  &NS
&NS      SETA  N'&SYSLIST
         AIF   (&SYSLIST(1) LE 0 OR &SYSLIST(1) GE 07).INVALCC
         MNOTE 'IFPROC CC=&SYSLIST(1) VALID'
         MEXIT
.INVALCC MNOTE 'IFPROC CC=>&SYSLIST(1)< null LE 0 -> .INVALCC'
         MNOTE 'IFPROC P1=>&SYSLIST(2)< N=&NS LAST=>&SYSLIST(&NS)<'
         MEND
         MACRO
         COLL
         AIF   ('A' LT '1').C1
         MNOTE 'FAIL: collating in ASCII, not EBCDIC'
         MEXIT
.C1      AIF   ('B' LT 'AB').C2
         MNOTE 'FAIL: shorter value must compare less'
         MEXIT
.C2      MNOTE 'EBCDIC COLLATION OK: A LT 1 and B LT AB'
         MEND
         MACRO
         CMT
         GBLA  &N
&N       SETA  0
&N       SETA  &N+1        THIS IS A TRAILING COMMENT
&N       SETA  &N+1        AND SO IS THIS
         MNOTE 'SETA WITH COMMENT: N=&N'
         MEND
T        CSECT
         PROBE 1,(10,(&A,&B,&C),30),3
         CNT   1,(10,(100,200,300),30),3
         CNT   1,(A,,C),3
         CNT   1,(),3
         CNT   1,PLAIN,3
         CNT   1,(A,B,),3
         NAMED (X,Y,Z)
         NAMED Q
ACOS     AMAIN ACALL=YES
         AMAIN TITLE='PROCESS SWITCH ROUTINE'
         IFPROC ,(CH,R4,GE,TPCTPRI),,,,,,,,,,,,,,,,,,,,,,,,,,,,,       X
               ,,,,,,,,,,,,,,LAST
         COLL
         CMT
         END
