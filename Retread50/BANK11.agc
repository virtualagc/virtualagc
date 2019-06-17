### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    BANK11.agc
## Purpose:     Part of the source code for AGC program Retread 50. 
## Assembler:   yaYUL
## Contact:     Ron Burkey <info@sandroid.org>.
## Website:     www.ibiblio.org/apollo/Restoration.html
## Mod history: 2019-06-12 MAS  Recreated from Computer History Museum's
##				physical core-rope modules.

                SETLOC          32000
                EBANK=          COMMAND

BANK11          CA              BIT5
                EXTEND
                WOR             12

                CA              UNK2342
                INHINT
                TC              WAITLIST
                2CADR           ZEROICDU

                TC              ENDOFJOB

ZEROICDU        CAF             ZERO
                TS              CDUX
                TS              CDUY
                TS              CDUZ

                CS              BIT5
                EXTEND
                WAND            12

                TC              TASKOVER

# IMU COARSE ALIGN MODE.

IMUCOARS        CAF             BIT4
                EXTEND
                WOR             12

                CA              UNK2344
                INHINT
                TC              WAITLIST
                2CADR           COARS

                TC              ENDOFJOB

COARS           CAF             BIT6
                EXTEND
                WOR             12

                CAF             TWO                             # SET CDU INDICATOR
COARS1          TS              CDUIND

                INDEX           CDUIND                          # COMPUTE THETAD - THETAA IN 1:S
                CA              THETAD                          #   COMPLEMENT FORM
                EXTEND
                INDEX           CDUIND
                MSU             CDUX
                EXTEND
                MP              BIT13                           # SHIFT RIGHT 2
                XCH             L                               # ROUND
                DOUBLE
                TS              ITEMP1
                TCF             +2
                ADS             L

                INDEX           CDUIND                          # DIFFERENCE TO BE COMPUTED
                LXCH            COMMAND
                CCS             CDUIND
                TC              COARS1

                CA              UNK2342
                TC              WAITLIST
                2CADR           COARS2

                TC              TASKOVER

COARS2          CAF             ZERO
                TS              ITEMP1                          # SETS TO +0.
                CAF             TWO                             # SET CDU INDICATOR
 +3             TS              CDUIND

                INDEX           CDUIND
                CCS             COMMAND                         # NUMBER OF PULSES REQUIRED
                TC              COMPOS                          # GREATER THAN MAX ALLOWED
                TC              NEXTCDU         +1
                TC              COMNEG
                TC              NEXTCDU         +1

COMPOS          AD              -COMMAX                         # COMMAX = MAX NUMBER OF PULSES ALLOWED
                EXTEND                                          #   MINUS ONE
                BZMF            COMZERO
                INDEX           CDUIND
                TS              COMMAND                         # REDUCE COMMAND BY MAX NUMBER OF PULSES
                CS              -COMMAX-                        #   ALLOWED

NEXTCDU         INCR            ITEMP1
                INDEX           CDUIND
                TS              CDUXCMD                         # SET UP COMMAND REGISTER.

                CCS             CDUIND
                TC              COARS2          +3

                CCS             ITEMP1                          # SEE IF ANY PULSES TO GO OUT.
                TC              SENDPULS
                TC              COARS1          -1
                EXTEND
                WAND            12

                TC              TASKOVER

COMNEG          AD              -COMMAX
                EXTEND
                BZMF            COMZERO
                COM
                INDEX           CDUIND
                TS              COMMAND
                CA              -COMMAX-
                TC              NEXTCDU

COMZERO         CAF             ZERO
                INDEX           CDUIND
                XCH             COMMAND
                TC              NEXTCDU

SENDPULS        CAF             13,14,15
                EXTEND
                WOR             14
                CAF             600MS
                TC              WAITLIST
                2CADR           COARS2
                TC              TASKOVER

IMUFINE         CS              BITS4-6                         # RESET ZERO, COARSE, AND ECTR ENABLE.
                EXTEND
                WAND            12

                CAF             TWO
                TS              UNK1205
                DOUBLE
                TS              UNK1206
                AD              ONE
                TS              UNK1207

                CAF             BIT6
                EXTEND
                WOR             14

                CA              UNK2343
                INHINT
                TC              WAITLIST
                2CADR           UNK2165

                TC              ENDOFJOB

UNK2165         INDEX           UNK1206
                CCS             UNK1210
                TC              +4
                TC              UNK2220
                TC              +2
                TC              UNK2220

 +4             INDEX           UNK1206
                TS              UNK1210

                INDEX           UNK1207
                INCR            UNK1210

                CAF             POSMAX
                TS              GYROCTR
                CA              UNK2352
                TC              +1
                TC              WAITLIST
                2CADR           UNK2165

UNK2206         INDEX           UNK1207
                CCS             UNK1210
                CAF             ZERO
                TCF             +2
                CAF             BIT9
                
                INDEX           UNK1205
                AD              UNK2361
                EXTEND
                WRITE           14

                TC              TASKOVER

UNK2220         INDEX           UNK1207
                CCS             UNK1210
                TC              +4
                TC              UNK2244
                TC              +2
                TC              UNK2244

                AD              ONE
                TS              GYROCTR

                AD              UNK2353
                EXTEND
                BZMF            UNK2244

                CAF             BIT10
                EXTEND
                MP              GYROCTR
                AD              TWO
                TC              +1
                TC              WAITLIST
                2CADR           UNK2244

                TC              UNK2206

UNK2244         CCS             UNK1205
                TCF             +5
                CS              BIT6
                EXTEND
                WAND            14

                TC              TASKOVER

                TS              UNK1205
                DOUBLE
                TS              UNK1206
                AD              ONE
                TS              UNK1207
                TC              UNK2165

UNK2260         CS              BIT15
                EXTEND
                WAND            12

                CAF             BIT14
                EXTEND
                RAND            30
                CCS             A
                TC              +2
                TC              +6
                CA              UNK2346
                TC              WAITLIST
                2CADR           UNK2260

                TC              TASKOVER

                CA              UNK2356
                EXTEND
                WOR             12
                CA              UNK2347
                TC              +1
                TC              WAITLIST
                2CADR           UNK2307

                TC              TASKOVER

UNK2307         CAF             BIT15
                EXTEND
                WOR             12

UNK2312         CAF             BIT14
                EXTEND
                RAND            30
                CCS             A
                TC              +2
                TC              +8
                CS              UNK2357
                EXTEND
                WAND            12
                CAF             BIT6
                EXTEND
                WOR             12

                TC              TASKOVER

                CA              UNK2341
                TC              +1
                TC              WAITLIST
                2CADR           UNK2312

                TC              TASKOVER

UNK2335         CS              BITS4-6
                EXTEND
                WAND            12
                TC              ENDOFJOB

UNK2341         OCT             1
UNK2342         OCT             2
UNK2343         OCT             3
UNK2344         OCT             5
600MS           DEC             60
UNK2346         OCT             144
UNK2347         OCT             21450
-COMMAX         DEC             -191
-COMMAX-        DEC             -192
UNK2352         OCT             1001
UNK2353         OCT             77757
UNK2354         OCT             50
BITS4-6         OCT             00070
UNK2356         OCT             30
UNK2357         OCT             40020
13,14,15        OCT             70000
UNK2361         OCT             1140
                OCT             1340
                OCT             1240

LST2FAN         TC              BANK11
                TC              IMUCOARS
                TC              UNK2335
                TC              IMUFINE

                INHINT
                CAF             ONE
                TC              WAITLIST
                2CADR           UNK2260
                TC              ENDOFJOB
