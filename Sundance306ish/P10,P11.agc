### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    P10,P11.agc
## Purpose:     A section of an attempt to reconstruct Sundance revision 306
##              as closely as possible with available information. Sundance
##              306 is the source code for the Lunar Module's (LM) Apollo
##              Guidance Computer (AGC) for Apollo 9. This program was created
##              using the mixed-revision SundanceXXX as a starting point, and
##              pulling back features from Luminary 69 believed to have been
##              added based on memos, checklists, observed address changes,
##              or the Sundance GSOPs.
## Assembler:   yaYUL
## Contact:     Ron Burkey <info@sandroid.org>.
## Website:     www.ibiblio.org/apollo/index.html
## Mod history: 2020-07-24 MAS  Created from SundanceXXX.



                BANK    32
                SETLOC  P10S
                BANK

                EBANK=  TIG

P10             TC      DOWNFLAG
                ADRES   LTCPFLG
                TC      P10/P11

P11             TC      UPFLAG
                ADRES   LTCPFLG

P10/P11         EXTEND
                DCA     TIG(AS)
                DXCH    TIG
                TS      TIG

                CAF     V06N33AP
                TC      VNDISP

                CAF     V06N81AP
                TC      VNDISP

                CA      DSPMMTEM
                EXTEND
                BZF     P10DISPS

                CAF     V06N91
                TC      VNDISP

                CAF     V06N92
                TC      BANKCALL
                CADR    GOFLASHR
                TCF     GOTOPOOH
                TC      P1XSETUP
                TC      -5

                CAF     ONE
                TC      BLANKET

P10DISPS        CA      P10ZERO
                TS      NN +1

                CAF     V06N56
                TC      VNDISP

                CAF     V06N37AP
                TC      VNDISP

                CAF     V06N94
                TC      VNDISP

P1XSETUP        TC      INTPRET
                DLOAD   DAD
                        TIG(AS)
                        INJTIME
                STORE   TCSITPF
                STCALL  TDEC1
                        CSMPREC
                SSP     VLOAD
                        P1XITCNT
                        0
                        VATT1
                STODL   VCSMINT
                        INJALT
                SL2     DAD
                        P10RM
                STOVL   RLEMT2
                        RATT1
                STORE   RCSMINT
                VXV     UNIT
                        VATT1
                STODL   UNVEC2
                        30MIN
                PUSH    DAD
                        TIG(AS)
                STODL   P1XMAX
                BDSU    SET
                        TIG(AS)
                        SLOPESW
                STODL   P1XTMIN
                        ZEROVECS
                STORE   P1XDT

P1XLOOP         SETPD
                        0
                VLOAD   PDDL
                        RLS
                        TIG(AS)
                PUSH    CALL
                        RP-TO-R
                STORE   RLSBRCS
                PUSH    VPROJ
                        UNVEC2
                VSL2    VCOMP
                VAD
                UNIT    LXA,1
                        P1XITCNT
                INCR,1  SXA,1
                        1
                        P1XITCNT
                STCALL  ULVEC
                        P1XROT
                CALL
                        INTSTALL
                VLOAD   SET
                        VCSMINT
                        MOONFLAG
                STORE   VCV
                VLOAD   SET
                        RCSMINT
                        INTYPFLG
                STODL   RCV
                        ZEROVECS
                STODL   TET
                        TIG(AS)
                DAD     DSU
                        INJTIME
                        TCSITPF
                STCALL  TDEC1
                        INTEGRVS
                BOFF    VLOAD
                        LTCPFLG
                        P10CSI
                        RATT1
                STORE   RTARG
                UNIT    PDVL
                        RP1XROT
                UNIT    DOT
                SL1     ACOS
                PDVL    ABVAL
                        RATT1
                PDVL
                        VATT1
                STORE   P11VTPF
                ABVAL
                PUSH    CALL
                        P11SMA
                VLOAD   VXV
                        RATT1
                        RP1XROT
                DOT     PDDL
                        UNVEC2
                        2D
                SQRT    DMP
                        2D
                DMP     DMP
                        ROOT1/MU
                        0
                DMP     SIGN
                        P1XPI
                SR2     PUSH
                STORE   P1XDT
                GOTO
                        P1XCONV

P10CSI          DLOAD   DAD
                        TIG(AS)
                        INJTIME
                STOVL   TCSI
                        RP1XROT
                SR1     SET
                        AVFLAG
                STOVL   RACT1
                        VP1XROT
                VSR2
                STOVL   VACT1
                        0D
                STOVL   RPASS1
                        6D
                STORE   VPASS1

                SETPD   VLOAD
                        0
                        VPASS1
                PDVL    PDDL
                        RPASS1
                        TCSI
                PDDL    PDDL
                        TTPI
                        TWOPI
                PUSH    AXT,2
                        2
                SXA,2   CALL
                        RTX2
                        INTINT
                CALL
                        PASSIVE
                AXC,1   AXT,2
                        10D
                        2D
                VLOAD   UNIT
                        RPASS1
                VXV     UNIT
                        VPASS1
                STORE   UP1
                DLOAD   SXA,1
                        ROOT1/MU
                        RTX1
                STODL   RTSR1/MU
                        P10MU
                SR      SXA,2
                        6D
                        RTX2
                STCALL  RTMU
                        CSI/A

P10ALARM        SLOAD   BZE
                        CSIALRM
                        P10ITER
                EXIT

                TC      P1XERDIS

P10ITER         DLOAD   DSU
                        CDHDELH
                        DIFFALT
                STOVL   DELDEP
                        DELVEET1
                ABVAL
                STOVL   DELVTPI
                        DELVEET2
                ABVAL   SETPD
                        0
                STODL   DELVTPF
                        P1XDT
                STODL   DELINDEP
                        P1XMAX
                STODL   MAX
                        P1XTMIN
                STODL   MIN
                        P10FRAC
                STODL   TWEEKIT
                        TIG(AS)
                STODL   INDEP
                        DIFFALT
                STORE   DEP
                CLEAR   CALL
                        ORDERSW
                        ITERATOR
                DLOAD
                        DIFFALT
                STODL   DEPREV
                        MAX
                STODL   P1XMAX
                        MIN
                STODL   P1XTMIN
                        DELINDEP
                STORE   P1XDT

P1XCONV         ABVAL
                DSU     BMN
                        ONESEC
                        P1XFINAL
                SLOAD   SR
                        P1XITCNT
                        14D
                DSU     BPL
                        P1MAXIT
                        P1XERR
                DLOAD   DAD
                        TIG(AS)
                        P1XDT
                STORE   TIG(AS)
                GOTO
                        P1XLOOP

P1XFINAL        VLOAD   DOT
                        RLSBRCS
                        UNVEC2
                PDVL    UNIT
                        RLSBRCS
                DOT     SL1
                        ULVEC
                ACOS    SIGN
                DMP     DCOMP
                        P10RM
                DMP     SL
                        P1XPI
                        5D
                STODL   P1XMAX
                        TIG(AS)
                SET     DSU
                        ASCNTFLG
                        P1XDELTT
                STODL   P1XTMIN
                        TIG(AS)
                PUSH    BON
                        LTCPFLG
                        P11DISP
                DAD
                        INJTIME
                STORE   TCSI
                DAD
                        T1TOT2
                STORE   TCDH
                GOTO
                        P1XEND
                        
P11DISP         DAD
                        TPITIME
                STORE   INTIME
                STODL   TTPI
                        TPIANGLE
                STODL   INJANGLE
                        INJTIME
                DAD     STADR
                STCALL  TCSITPF
                        P1XROT

                SETPD   SLOAD
                        0
                        P31ZERO
                PDDL    PUSH
                        EPSFOUR*
                AXC,1   CLEAR
                        10D
                        B29FLAG
                DLOAD   DSU
                        INJTIME
                        TPITIME
                STOVL   DELLT4
                        RP1XROT
                STOVL   RINIT
                        VP1XROT
                STCALL  VINIT
                        INITVEL
                VLOAD   VSR2
                        DELVEET3
                ABVAL
                STOVL   DELVTPI
                        VACT4
                VSU     VSR2
                        P11VTPF
                ABVAL
                STORE   DELVTPF

P1XEND          EXIT
                TC      P1XDISP

P1XERR          EXIT
                TC      ALARM
                OCT     605

P1XERDIS        CAF     V05N09AP
                TC      BANKCALL
                CADR    GOFLASH
                TCF     GOTOPOOH
                TCF     P10/P11
                TCF     -5

P11SMA          DMP     DMP
                        2D
                        1/MU*
                DMP     PUSH
                SLOAD   DSU
                        SMATWO
                NORM    PDDL
                        X1
                NORM    SR1
                        X2
                DDV
                XSU,2   SR*
                        X1
                        3,2
                PUSH    RVQ

P1XROT          DLOAD   DMP
                        INJANGLE
                        DEGTOREV
                SL      PUSH
                        14D
                COS     VXSC
                        ULVEC
                PDDL    SIN
                PDVL    VXV
                        UNVEC2
                        ULVEC
                UNIT    VXSC
                VAD
                VXSC    VSL2
                        RLEMT2
                STORE   RP1XROT
                UNIT    VXSC
                        P1XVVER
                PDVL    UNIT
                        RP1XROT
                VXV     VXSC
                        UNVEC2
                        P1XVHOR
                VSL1    VSU
                VCOMP   VSL3
                STORE   VP1XROT
                RVQ

P1MAXIT         2DEC    10
P10ZERO         =       P1MAXIT
ONESEC          2DEC    100
P10FRAC         2DEC    0.2
30MIN           2DEC    1800 E2
P1XPI           2DEC    3.141592659 B-6
P10RM           2DEC    1738090 B-27
EPSFOUR*        2DEC    0.0416666666
SMATWO          DEC     2 B5
P10MU           2DEC    4.902778 E8 B-30
1/MU*           2DEC    2.03966 E-9 B28
DEGTOREV        2DEC    0.0055555555 B-1
ROOT1/MU        2DEC    4.516259492 E-5 B14

P1XDISP         EXTEND
                DCA     TIG(AS)
                DXCH    TIG
                TS      TIG

                CAF     V06N33AP
                TC      VNDISP

                CA      DSPMMTEM
                EXTEND
                BZF     P10OUTD

                CAF     V06N37AP
                TC      VNDISP

                CA      TCSITPF
                TS      DSPTEM1
                CAF     V06N34AP
                TC      VNDISP
                TC      P10N53

P10OUTD         CAF     V06N30AP
                TC      VNDISP

                CAF     V06N31AP
                TC      VNDISP

P10N53          CAF     V06N53AP
                TC      VNDISP

P1XCNTD         CAF     ONE
                INHINT
                TC      WAITLIST
                EBANK=  TIG
                2CADR   CLOKTASK

                RELINT

                CAF     V16N35AP
                TC      BANKCALL
                CADR    GOFLASH
                TC      GOTOPOOH
                TCF     +2
                TCF     P1XCNTD
                TC      GOTOPOOH

VNDISP          EXTEND
                QXCH    RTRN
                TS      VERBNOUN
                CA      VERBNOUN
                TCR     BANKCALL
                CADR    GOFLASH
                TCF     GOTOPOOH
                TC      RTRN
                TCF     -5

V05N09AP        VN      0509
V06N30AP        VN      0630
V06N31AP        VN      0631
V06N33AP        VN      0633
V06N34AP        VN      0634
V06N37AP        VN      0637
V06N53AP        VN      0653
V06N56          VN      0656
V06N81AP        VN      0681
V06N91          VN      0691
V06N92          VN      0692
V06N94          VN      0694
V16N35AP        VN      1635


