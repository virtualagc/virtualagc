### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    LOTS_INTERFACE.agc
## Purpose:     A section of Aurora 88.
##              It is part of the reconstructed source code for the final
##              release of the Lunar Module system test software. No original
##              listings of this program are available; instead, this file
##              was created via disassembly of dumps of Aurora 88 core rope
##              modules and comparison with other AGC programs.
## Assembler:   yaYUL
## Contact:     Ron Burkey <info@sandroid.org>.
## Website:     www.ibiblio.org/apollo/index.html
## Mod history: 2023-07-12 MAS  Created via disassembly.

                BANK    7
                EBANK=  LOTSFLAG

## MAS 2023: This file contains code related to the LEM Optical Rendezvous
## System (LORS), and more specifically, the Optical Tracker (LOTS or OT) mounted
## on the lunar module. The LORS was a competitor to the Rendezvous Radar (RR)
## system, which eventually won out. Aurora 88 contains code to test both;
## it can be switched into LORS mode with VERB 66 ENTER, and back to RR mode
## via VERB 36 ENTER. <br/><br/>
## We presently have very little information about the LORS. Every name in
## this file, and even its filename, are modern guesswork. The most useful
## available documents are:
## <ul><li><a href="https://www.ibiblio.org/apollo/Documents/xde-34-t-53.pdf">
##         XDE34-T-53 Preinstallation Testing of the Lunar Excursion Module
##         Optical Rendezvous System</a></li>
##     <li><a href="https://www.ibiblio.org/apollo/Documents/blk2_lem_reference_cards.pdf">
##         Blk II/LM Reference Cards (contains verbs, nouns, and I/O channel
##         assignments)</a></li>
##     <li><a href="https://www.ibiblio.org/apollo/Documents/Retread50AuroraSundialBCCards.pdf">
##         Retread/Aurora/Sundial Reference Cards (contains program alarm definitions)</a></li>
##</ul>

LOTSMONB        TCF     LOTSMON1
LOTSACQB        TCF     LOTSACQ1
LOTTESTB        TCF     LOTTEST1
LOTSTOWB        TCF     LOTSTOW1
LOTMARKB        TC      Q

LOTSMON1        EXTEND
                READ    33
                MASK    BIT7
                CCS     A
                TCF     U07,2022

                EXTEND
                READ    12
                MASK    BIT1
                CCS     A
                TCF     U07,2022

                TC      ALARM           # TRACKER CDU FAIL
                OCT     00641
                TCF     U07,3411

U07,2022        CAF     BIT14
                MASK    LOTMODES
                EXTEND
                BZF     ENDOFJOB

                TC      U07,2143

                CAF     ZERO
                TC      BANKCALL
                CADR    U06,2555

                CA      UNK1204
                EXTEND
                BZF     ENDOFJOB

                TCF     U07,2753

LOTSACQ1        CAF     BIT10
                MASK    LOTMODES
                CCS     A
                TCF     ENDLOTVB

                TC      U07,2127
                TS      UNK1131

                CAF     BIT14
                MASK    LOTMODES
                TS      LOTMODES

                TC      GRABWAIT
                CAF     LUNK1116
                TS      MPAC +2
U07,2052        CAF     V05N01E
                TC      NVSBWAIT
                TC      FLASHON
                TC      ENDIDLE
                TCF     ENDLOTVB
                TCF     +2
                TCF     U07,2052

                CAF     V24N71E
                TC      NVSBWAIT
                TC      ENDIDLE
                TCF     ENDLOTVB
                TCF     +3
                TC      FREEDSP
                TCF     U07,2335
                TCF     ENDLOTVB

LOTTEST1        CAF     9,13,14
                MASK    LOTMODES
                CCS     A
                TCF     ENDLOTVB

                TC      GRABWAIT
                CAF     LUNK1116
                TS      MPAC +2
U07,2100        CAF     V05N01E
                TC      NVSBWAIT
                TC      FLASHON
                TC      ENDIDLE
                TCF     ENDLOTVB
                TCF     +2
                TCF     U07,2100

                EXTEND
                DCA     UNK1114
                DXCH    DESLOTSY +1

                CAF     ZERO
                TS      DESLOTSY

U07,2114        CAF     V06N71E
                TC      NVSBWAIT
                TC      FLASHON
                TC      ENDIDLE
                TCF     ENDLOTVB
                TCF     +2
                TCF     U07,2114

                DXCH    DESLOTSY +1
                DXCH    UNK1114

                TC      FREEDSP
                TCF     LOTTEST2

U07,2127        CS      BITS2&14
                EXTEND
                WAND    12
                CAF     ZERO
                TS      UNK1204
                TC      Q

LUNK1116        ADRES   UNK1116
V05N01E         OCT     00501
V06N71E         OCT     00671
9,13,14         OCT     30400
BITS2&14        OCT     20002
V24N71E         OCT     02471

U07,2143        EXTEND
                QXCH    UNK1207
                EXTEND
                DCA     OPTY
                DXCH    UNK1127
                TS      UNK1210

                INHINT
                CAF     LUNK1130
                TS      BUF
                CA      UNK1117
                TS      TEM2

                CAF     BIT2
                EXTEND
                RAND    33
                CCS     A
                TCF     +3
                CAF     U07,2334
                ADS     TEM2
                TC      BANKCALL
                CADR    CDUINC +1

                CA      UNK1130
                TS      ELANG

                CAF     LUNK1127
                TS      BUF
                CA      UNK1120
                TS      TEM2
                TC      BANKCALL
                CADR    CDUINC +1

                CCS     UNK1127
                CA      UNK1127
                TCF     U07,2212
                NOOP

                CS      LOTMODES
                TS      LOTMODES
                CS      AZANG
                TS      AZANG

                CAF     ZERO
                EXTEND
                MSU     UNK1127
U07,2212        TS      AZANG +1

                CA      UNK1210
                TS      L
                CA      LOTMODES
                EXTEND
                RXOR    L
                MASK    BIT15
                CCS     A
                TCF     +2
                TCF     U07,2253

                CS      AZANG +1
                AD      HALF
                EXTEND
                BZMF    U07,2241

                CAF     TWO
                AD      AZANG
                EXTEND
                BZF     U07,2245

                CCS     AZANG
                TCF     U07,2251
                TCF     U07,2251
                TCF     U07,2247
                TCF     U07,2247

U07,2241        CCS     AZANG
                TCF     U07,2247
                TCF     U07,2247
                NOOP

U07,2245        CS      ONE
                TCF     +4
U07,2247        CAF     ZERO
                TCF     +2
U07,2251        CAF     TWO
                TS      AZANG

U07,2253        CA      LOTMODES
                EXTEND
                BZMF    +2
                TCF     U07,2264

                CS      LOTMODES
                TS      LOTMODES
                EXTEND
                DCS     AZANG
                DXCH    AZANG

U07,2264        CAF     LAZANG
                TC      U07,2270
                RELINT
                TC      UNK1207

U07,2270        EXTEND
                QXCH    UNK1210
                TS      UNK1211
                INDEX   A
                LXCH    1
                INDEX   UNK1211
                CA      0
                EXTEND
                RXOR    L
                MASK    BIT15
                CCS     A
                TCF     +2
                TCF     U07,2326

                INDEX   UNK1211
                CCS     0
                CAF     POSMAX
                TCF     +2
                CS      POSMAX
                ADS     L

                INDEX   UNK1211
                CA      0
                EXTEND
                BZMF    U07,2326

                CA      L
                EXTEND
                BZMF    +3
                AD      ONE
                TCF     +2
                CA      ZERO
                TS      L

U07,2326        INDEX   UNK1211
                LXCH    1
                TC      UNK1210

LAZANG          ADRES   AZANG
LUNK1130        ADRES   UNK1130
LUNK1127        ADRES   UNK1127
U07,2334        DEC     26

U07,2335        CAF     ONE
                TS      UNK1145

                CAF     9,10,13
                MASK    LOTMODES
                EXTEND
                BZF     U07,2347

                TC      ALARM           # MORE THAN ONE PROGRAM TRYING TO USE
                OCT     00611           # OPTICAL TRACKER

                TC      OTRKFLON
                TCF     ENDLOTVB

U07,2347        TC      U07,2127
                TC      U07,2532
                TCF     ENDLOTVB

U07,2352        CAF     BIT14
                MASK    LOTMODES
                CCS     A
                TCF     U07,2432

                CAF     BIT9
                TC      OTFLAGUP

                TC      BANKCALL
                CADR    LOTZERO
                TC      BANKCALL
                CADR    OPTSTALL
                NOOP
                TC      BANKCALL
                CADR    U07,2462
                TC      BANKCALL
                CADR    OPTSTALL
                NOOP

                EXTEND
                DCA     DESLOTSY
                DXCH    UNK1146
                CA      DESLOTSX
                TS      UNK1150

                TC      U07,2616
                TCF     U07,2727

                CAF     95DEG
                TS      DESLOTSY +1

                CAF     ONE
                TC      BANKCALL
                CADR    U07,2457
                TC      BANKCALL
                CADR    OPTSTALL
                TCF     U07,2661

                CAF     85.7DEG
                TS      DESLOTSY +1

                CAF     ONE
                TC      BANKCALL
                CADR    U07,2457
                TC      BANKCALL
                CADR    OPTSTALL
                TCF     U07,2663

U07,2421        EXTEND
                DCA     UNK1146
                DXCH    DESLOTSY
                CA      UNK1150
                TS      DESLOTSX

                CS      BIT9
                MASK    LOTMODES
                TS      LOTMODES
                TCF     U07,2437

U07,2432        TC      BANKCALL
                CADR    U07,2462
                TC      BANKCALL
                CADR    OPTSTALL
                NOOP

U07,2437        TC      BANKCALL
                CADR    U07,2452
                TC      BANKCALL
                CADR    OPTSTALL
                TCF     U07,2724

                CAF     ZERO
                TS      UNK1135
                TC      U07,2127

                CAF     30.0SEC
                TC      BANKCALL
                CADR    U06,3001

U07,2452        CAF     PRIO10
                TC      NOVAC
                2CADR   U07,2477

                CA      UNK1145
U07,2457        AD      U07,2744
U07,2460        TS      UNK1204
                TC      SWRETURN

U07,2462        CS      BITS1&14
                EXTEND
                WAND    12

                CAF     BIT2
                EXTEND
                WOR     12

                CAF     THREE
                INHINT
                TC      WAITLIST
                2CADR   OGOODEND

                RELINT
                TC      SWRETURN

U07,2477        TC      FREEDSP
                TC      BANKCALL
                CADR    ENDEXTVB

LOTZERO         CS      BIT2
                EXTEND
                WAND    12

                CAF     BIT1
                EXTEND
                WOR     12

                CAF     BIT6
                INHINT
                TC      WAITLIST
                2CADR   LOTZ2

                RELINT
                TC      SWRETURN

LOTZ2           CAF     ZERO
                TS      OPTX
                TS      OPTY

                CS      BIT1
                EXTEND
                WAND    12

                CAF     3.0SEC
                TC      WAITLIST
                2CADR   OGOODEND

                TC      TASKOVER

U07,2532        EXTEND
                QXCH    UNK1152

                CAF     ONE
                TS      UNK1144

                CA      UNK1116
                EXTEND
                RXOR    33
                MASK    BIT2
                CCS     A
                TCF     U07,2551

                TC      BANKCALL
                CADR    U07,2553
                TC      BANKCALL
                CADR    OPTSTALL

                TC      UNK1152

U07,2551        INDEX   UNK1152
                TC      1

U07,2553        CA      UNK1144
                AD      BIT4
                EXTEND
                WOR 13

                CAF     EIGHT
                INHINT
                TC      WAITLIST
                2CADR   U07,2566

                RELINT
                TC      SWRETURN

U07,2566        CS      UNK1144
                EXTEND
                WAND    13

                CAF     1.0SEC
                TC      WAITLIST
                2CADR   U07,2576

                TC      TASKOVER

U07,2576        CAF     BIT2
                MASK    UNK1144
                CCS     A
                TCF     U07,2607

                CA      UNK1116
                EXTEND
                RXOR    33
                MASK    BIT2
                CCS     A
U07,2607        TCF     OGOODEND

                TC      ALARM           # STAR/BEACON MODE SWITCH FAILURE
                OCT     00613
                TC      OTRKFLON

OBADEND         CAF     ONE
                TC      POSTJUMP
                CADR    BADEND

U07,2616        EXTEND
                QXCH    UNK1153

                EXTEND
                DCA     OPTY
                TS      UNK1127
                DXCH    AZANG +1

                CAF     ZERO
                TS      AZANG

                CS      ONE
                TS      UNK1112

                EXTEND
                DCA     AZANG
                DXCH    DESLOTSY

                CAF     BIT14
                TC      OTFLAGUP

                CAF     BIT13
                MASK    LOTMODES
                CCS     A
                TCF     U07,2647

                CAF     ZERO
                TS      DESLOTSX

                CAF     POSMAX
                TS      UNK1161

                CAF     U07,2746
                TCF     U07,2652

U07,2647        CAF     -75DEG 
                TS      DESLOTSX

                CAF     U07,2745
U07,2652        TC      BANKCALL
                CADR    U07,2460
                TC      BANKCALL
                CADR    OPTSTALL
                TC      UNK1153

                INDEX   UNK1153
                TC      1

U07,2661        CAF     TWO
                TCF     +4
U07,2663        CS      AZANG +1
                TS      AZANG +1
                CS      ONE
 +4             TS      AZANG

                CAF     ZERO
                TS      DESLOTSY

                CAF     HALF
                TS      DESLOTSY +1

                CAF     ZERO
                TS      OPTCADR

                CAF     ONE
                TC      BANKCALL
                CADR    U07,2457
                TC      BANKCALL
                CADR    OPTSTALL
                TCF     U07,2727

                TCF     U07,2421

OTFLAGUP        INHINT
                LXCH    LOTMODES
                EXTEND
                WOR     L
                LXCH    LOTMODES
                RELINT
                TC      Q

OTRKFLON        INHINT
                LXCH    DSPTAB +11D
                CAF     BIT8
                AD      BIT15
                EXTEND
                WOR     L
                LXCH    DSPTAB +11D
                RELINT
                TC      Q

U07,2724        TC      ALARM           # UNABLE TO ACHIEVE DESIRED LOS WITHIN
                OCT     00614           # 30 SECONDS
                TCF     U07,2731

U07,2727        TC      ALARM           # CANNOT GET OUT OF STOW
                OCT     00612

U07,2731        TC      OTRKFLON
                CAF     PRIO20
                TC      NOVAC
                2CADR   LOTSTOW1

ENDLOTVB        TC      FREEDSP
                TC      POSTJUMP
                CADR    ENDEXTVB

1.0SEC          DEC     100
BITS1&14        OCT     20001
9,10,13         OCT     11400
U07,2744        OCT     00750
U07,2745        OCT     00245
U07,2746        OCT     00754
30.0SEC         DEC     3000
3.0SEC          DEC     300
85.7DEG         OCT     17171
95DEG           OCT     20707

U07,2753        CS      BIT4
                ADS     UNK1204
                MASK    U07,3241
                CCS     A
                TCF     U07,2770
                TS      UNK1204

                CAF     ONE
                INHINT
                TC      WAITLIST
                2CADR   OBADEND

                RELINT
                TC      ENDOFJOB

U07,2770        CA      UNK1204
                MASK    LOW3
                INDEX   A
                TCF     +0
                TCF     U07,3003
                TCF     U07,3075
                TCF     U07,3104
                TCF     U07,3220
                TCF     U07,3046
                TCF     U07,3227
                TCF     U07,3230

U07,3003        CAF     THREE
                TS      UNK1151
                INDEX   A
                CA      ELANG
                AD      1DEG
                EXTEND
                BZMF    U07,3025

                INDEX   UNK1151
                CA      ELANG
                AD      -84DEG
                EXTEND
                BZMF    +2
                TCF     U07,3027

                CCS     UNK1151
                CS      ZERO
                TCF     U07,3003 +1
                TCF     CCSHOLE
                TCF     U07,3046

U07,3025        CAF     ZERO
                TCF     +2
U07,3027        CS      -84DEG
                XCH     DESLOTSX
                TS      UNK1151

                CAF     U07,3231
                TS      UNK1205

                CAF     U07,3243
                TC      U07,3067
                TCF     U07,3075

U07,3037        CA      UNK1151
                TS      DESLOTSX

                CAF     U07,3247
                TS      UNK1205

                CAF     U07,3242
                TC      U07,3067
                TCF     U07,3104

U07,3046        CAF     U07,3232
                TS      UNK1205

                CAF     U07,3237
                TC      U07,3067
                TCF     U07,3104

U07,3053        CAF     ZERO
                TS      UNK1204

                CAF     ONE
                INHINT
                TC      WAITLIST
                2CADR   OGOODEND

                RELINT
                TC      ENDOFJOB

OGOODEND        CAF     ONE
                TC      POSTJUMP
                CADR    GOODEND

U07,3067        TS      UNK1154
                CAF     U07,3240
                MASK    UNK1204
                AD      UNK1154
                TS      UNK1204
                TC      Q

U07,3075        CAF     ONE
                TS      UNK1206
                CA      DESLOTSX
                EXTEND
                MSU     ELANG
                LXCH    A
                TCF     U07,3124

U07,3104        CAF     ZERO
                TS      UNK1206
                TS      MPAC +2

                EXTEND
                DCA     DESLOTSY
                DXCH    MPAC

                EXTEND
                DCS     AZANG
                DAS     MPAC
                TC      TPAGREE
                DXCH    MPAC
                EXTEND
                BZF     U07,3124
                EXTEND
                BZMF    U07,3146
                TCF     U07,3135

U07,3124        CCS     L
                TCF     U07,3131
                TCF     U07,3203
                TCF     U07,3142
                TCF     U07,3203

U07,3131        INDEX   UNK1206
                AD      U07,3233
                EXTEND
                BZMF    U07,3140

U07,3135        INDEX   UNK1206
                CS      U07,3235
                TCF     U07,3166

U07,3140        CA      L
                TCF     U07,3151 +1

U07,3142        INDEX   UNK1206
                AD      U07,3233
                EXTEND
                BZMF    U07,3151

U07,3146        INDEX   UNK1206
                CAF     U07,3235
                TCF     U07,3166

U07,3151        CS      L
                AD      U07,3604
                EXTEND
                BZMF    U07,3203

                LXCH    A
                EXTEND
                MP      BIT13
                XCH     L
                DOUBLE
                TS      ITEMP1
                TCF     +2
                ADS     L
                LXCH    A

U07,3166        INDEX   UNK1206
                TS      OPTYCMD
U07,3170        CAF     BIT14
                MASK    UNK1204
                EXTEND
                BZF     U07,3177

                CCS     UNK1206
                TCF     U07,3177
                TCF     U07,3075

U07,3177        CAF     U07,3244
                EXTEND
                WOR     14
                TC      ENDOFJOB

U07,3203        CCS     UNK1205
                TCF     +2
                TCF     U07,3170

                CCS     UNK1206
                CAF     BIT12
                AD      BIT12
                COM
                MASK    UNK1204
                TS      UNK1204

                MASK    U07,3250
                CCS     A
                TCF     U07,3170
                TC      UNK1205

U07,3220        CAF     ZERO
                TS      OPTYCMD

                CA      UNK1161
                TS      OPTXCMD

                CAF     FIVE
                TC      U07,3067
                TCF     U07,3177

U07,3227        TC      ENDOFJOB
U07,3230        TC      ENDOFJOB

U07,3231        OCT     03037
U07,3232        OCT     03053

U07,3233        OCT     75614
                OCT     76054

U07,3235        OCT     77342
                OCT     77412

U07,3237        OCT     34003
U07,3240        OCT     02770
U07,3241        OCT     00770
U07,3242        OCT     04003
U07,3243        OCT     10002
U07,3244        OCT     06000
1DEG            OCT     00133
-84DEG          OCT     61042
U07,3247        OCT     03046
U07,3250        OCT     14000

LOTSTOW1        CAF     BIT14
                MASK    LOTMODES
                EXTEND
                BZF     ENDLOTVB

                CAF     BIT10
                MASK    LOTMODES
                CCS     A
                TCF     ENDLOTVB

                CAF     BIT10
                TC      OTFLAGUP
                TC      U07,2127

                CAF     ZERO
                TS      OPTCADR
                TC      BANKCALL
                CADR    LOTZERO
                TC      BANKCALL
                CADR    OPTSTALL
                NOOP

                CAF     HALF
                TS      DESLOTSY +1

                CAF     ZERO
                TS      DESLOTSY
                TS      DESLOTSX

                TC      BANKCALL
                CADR    U07,2462
                TC      BANKCALL
                CADR    OPTSTALL
                NOOP

                CAF     ONE
                TC      BANKCALL
                CADR    U07,2457
                TC      BANKCALL
                CADR    OPTSTALL
                TCF     U07,3405

U07,3313        CAF     -75DEG
                TS      DESLOTSX

                CS      POSMAX
                TS      UNK1161

                CAF     U07,3421
                TC      BANKCALL
                CADR    U07,2460
                TC      BANKCALL
                CADR    OPTSTALL

                CAF     ZERO
                TS      OPTCADR
                TC      U07,2127
                TS      LOTMODES
                TS      UNK1131

                CAF     BIT12
                TC      OTFLAGUP

                CAF     U07,3414
                TS      UNK1151

                CAF     15SEC
                INHINT
                TC      WAITLIST
                2CADR   U07,3360

                RELINT

                TC      GRABWAIT
U07,3344        CAF     V50N00E
                TC      NVSBWAIT
                TC      FLASHON
                TC      FREEDSP
                TC      ENDIDLE
                TCF     +3
                TCF     U07,3344
                TCF     U07,3344

                TC      FREEDSP
                CAF     ZERO
                TS      LOTMODES
                TCF     ENDLOTVB

U07,3360        CAF     BIT12
                MASK    LOTMODES
                EXTEND
                BZF     TASKOVER

                CCS     UNK1151
                TCF     U07,3377

                CAF     ZERO
                TS      FAILREG
                TC      ALARM           # 15 MINUTE POWER OFF WARNING
                OCT     00615

                TC      OTRKFLON

                CS      BIT13
                MASK    EXTVBACT
                TS      EXTVBACT
                TC      TASKOVER

U07,3377        TS      UNK1151
                CAF     15SEC
                TC      WAITLIST
                2CADR   U07,3360

                TC      TASKOVER

U07,3405        CAF     ZERO
                TS      FAILREG
                TC      ALARM           # CANNOT GET BACK TO STOW
                OCT     00616

U07,3411        TC      OTRKFLON
                TC      U07,2127
                TCF     ENDLOTVB

U07,3414        DEC     59
15SEC           DEC     1500
-26DEG          OCT     73301
-75DEG          OCT     62524
V50N00E         OCT     05000
U07,3421        OCT     00364

LOTTEST2        TC      U07,2127
                TS      LOTMODES
                TS      UNK1131

                CAF     BIT13
                TC      OTFLAGUP

                TC      U07,2532
                TCF     ENDLOTVB

                CAF     BIT3&4
                EXTEND
                RXOR    33
                MASK    BIT3&4
                EXTEND
                BZF     +4

                TC      ALARM           # LOCK ON, DATA GOOD ILLEGALY PRESENT
                OCT     00621           # DURING SELF TEST
                TCF     OTSTFAIL

                TC      BANKCALL
                CADR    LOTZERO
                TC      BANKCALL
                CADR    OPTSTALL
                NOOP

                EXTEND
                DCA     OPTY
                TS      UNK1127
                DXCH    AZANG +1

                CAF     ZERO
                TS      AZANG

                CAF     BIT14
                TC      OTFLAGUP

                TC      U07,2143

                CS      -26DEG
                AD      ELANG
                CCS     A
                TCF     +4
-1DEG           OCT     77644
                TCF     +2
                TCF     U07,3475

                AD      -1DEG
                EXTEND
                BZMF    U07,3475

BADSTOW         TC      ALARM           # STOW COORDINATES NOT WITHIN LIMITS
                OCT     00622
                TCF     OTSTFAIL

U07,3475        CS      BIT14
                AD      AZANG +1
                CCS     A
                TCF     +4
BIT3&4          OCT     00014
                TCF     +2
                TCF     U07,3510

                AD      -1DEG
                EXTEND
                BZMF    U07,3510
                TCF     BADSTOW

U07,3510        CAF     BIT14
                EXTEND
                WOR     12

                TC      U07,3621

                CAF     30.0SEC
                INHINT
                TC      WAITLIST
                2CADR   U07,3524

                RELINT

                CAF     U07,3527
                TC      JOBSLEEP

U07,3524        CAF     U07,3527
                TC      JOBWAKE
                TC      TASKOVER

U07,3527        CADR    U07,3530

U07,3530        CAF     BIT4
                EXTEND
                RXOR    33
                MASK    BIT3&4
                EXTEND
                BZF     +4

                TC      ALARM           # LOCK ON FAILURE DURING SELF TEST
                OCT     00623
                TCF     U07,3636

                TC      U07,3641
                TC      BANKCALL
                CADR    U07,2462
                TC      BANKCALL
                CADR    OPTSTALL
                NOOP

                TC      U07,2616

                CAF     ZERO
                TS      OPTCADR

                EXTEND
                READ    33
                MASK    BIT3&4
                EXTEND
                BZF     +4

                TC      ALARM           # DATA GOOD FAILURE DURING SELF TEST
                OCT     00624
                TCF     U07,3633

                TC      U07,2143

                CS      UNK1115
                AD      ELANG
                CCS     A
                TCF     +4
U07,3567        DEC     -1
                TCF     +2
                TCF     U07,3600

                AD      U07,3567
                EXTEND
                BZMF    U07,3600

U07,3575        TC      ALARM           # SELF TEST LIGHT COORDINATES NOT WITHIN
                OCT     00625           # LIMITS
                TCF     U07,3633

U07,3600        CS      UNK1114
                AD      AZANG +1
                CCS     A
                TCF     +4
U07,3604        DEC     -8
                TCF     +2
                TCF     U07,3613

                AD      U07,3567
                EXTEND
                BZMF    U07,3613
                TCF     U07,3575

U07,3613        TC      U07,3641
                TC      U07,3621

U07,3615        CS      BIT14
                EXTEND
                WAND    12
                TCF     U07,3313

U07,3621        EXTEND
                QXCH    UNK1151

                CAF     TWO
                TS      UNK1144
                TC      BANKCALL
                CADR    U07,2553
                TC      BANKCALL
                CADR    OPTSTALL
                NOOP
                TC      UNK1151

U07,3633        TC      U07,3621
                TC      OTRKFLON
                TCF     U07,3615

U07,3636        TC      U07,3621
OTSTFAIL        TC      OTRKFLON
                TCF     ENDLOTVB

U07,3641        EXTEND
                QXCH    UNK1205

                CAF     BIT1
                MASK    UNK1116
                EXTEND
                BZF     U07,3660

                TC      GRABWAIT
U07,3650        CAF     V06N70E
                TC      NVSBWAIT
                TC      FLASHON
                TC      ENDIDLE
                TCF     U07,3650
                TCF     +2
                TCF     U07,3650

                TC      FREEDSP
U07,3660        TC      UNK1205

V06N70E         OCT     00670

ENDLOTSS        EQUALS
