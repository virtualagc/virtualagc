### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    AGC_BLOCK_TWO_EXTENDED_TESTS.agc
## Purpose:     This program is designed to extensively test the Apollo Guidance Computer
##              (specifically the LM instantiation of it). It is built on top of a heavily
##              stripped-down Aurora 12, with all code ostensibly added by the DAP Group
##              removed. Instead Borealis expands upon the tests provided by Aurora,
##              including corrected tests from Retread 44 and tests from Ron Burkey's
##              Validation.
## Assembler:   yaYUL
## Contact:     Mike Stewart <mastewar1@gmail.com>.
## Website:     www.ibiblio.org/apollo/index.html
## Mod history: 2017-01-15 MAS  Created to hold new extended tests, starting off with
##                              checking out all the timers, EDRUPT, BRUPT substitution,
##                              and interrupts following an INDEX.
##              2017-09-03 MAS  Added in some tests for proper handling of Z and ZRUPT.
##                              The ZRUPT test makes use of EDRUPT again, so that gets
##                              more thoroughly tested too.
##              2017-09-04 MAS  Rewrote the new ZRUPT test to simply RESUME outside of an
##                              interrupt instead of using EDRUPT. This saves a few words,
##                              and exercises RESUME's ability to work whenever.
##              2017-09-17 MAS  Added a new table-driven extended test for DV, which checks
##                              out "nonsense" (as described by E-2052), overflow cases, and
##                              and division by A and L. The L cases are not yet written,
##                              and I intend to add a separate case for DV Z when I figure
##                              out the best way to do it.
##              2017-09-18 MAS  Filled out DV L entries in the division table. The only
##                              remaining cases I want to cover are DV Z, which need some
##                              tweaks to divisor determination, and will require moving
##                              the division to a fixed location (probably the start of
##                              this bank).
##              2017-09-20 MAS  Completed DV tests, for now. DV Z is handled by the table,
##                              and I made division by 0 testable (and added cases for it).
##                              So, all interesting situations should be able to be entered
##                              in the table, in case anything has been missed.

                BANK            24
# The following instructions should be at the start of the bank they are in.
DODV            EXTEND
                INDEX           SKEEP5                          # Adjust target register of DV.
                DV              0                               # Z at time of DV = 02003
                TCF             DVDONE

# The extended tests check out functionalities not exercised by the Aurora or Retread tests. First up
# is testing of the interrupt priority chain (insofar as it can be deterministically and automatically
# checked) by queuing up all four timer interrupts, and then executing them one at a time using EDRUPT.

# What we're about to do is sensitive to the phasing of TIME3. Instead of risking it, we simply wait
# for the next TIME3 increment so we can be sure we're safe.
EXTTESTS        CA              TIME3
                TS              SKEEP1
WAITT3          CS              TIME3                           # Wait for the next TIME3 increment.
                AD              SKEEP1                          # No TCs are needed due to a bug in
                EXTEND                                          # the TC alarm hardware.
                BZF             WAITT3

# With phasing correct, inhibit interrupts and trigger all the timers.
                INHINT

SCHEDT6         CAF             LOW4                            # Start with TIME6. It counts the fastest,
                TS              TIME6                           # and will provide a bounds after which we'll
                CAF             BIT15                           # know all the others have fired.
                EXTEND
                WOR             CHAN13                          # Start the timer for a bit over 10ms. This
                                                                # bit resetting will tell us we're done.

SCHEDT5         CAF             POSMAX                          # Schedule T5RUPT to happen in <=10ms.
                TS              TIME5

SCHEDT3         CAF             ONE                             # Schedule a T3RUPT by waitlisting a task
                TC              WAITLIST                        # that does nothing to execute ASAP.
                2CADR           NOTHING

# TIME4 needs a bit of special handling. It expects to execute periodically and naively forcing it to
# happen sooner could throw off display handling or other things. Instead, we'll only accelerate it
# if necessary, and if so make sure it doesn't do any actual work in the accelerated interrupt.
SCHEDT4         CCS             TIME4                           # Check to see if we need to force TIME4.
                TCF             +2                              # TIME4 positive, we may need to accelerate.
                TCF             T6CHK                           # TIME4 is zero, so T4RUPT is already pending
                AD              TWO                             # Calculate the new TIME4 value (+10ms from old)
                OVSK                                            # ... and if that overflows, TIME4 is already going
                TCF             +2                              # to happen as quickly as is possible, so we can
                TCF             T6CHK                           # just leave it alone.
                TS              T4TEMP                          # Save the adjusted original TIME4 value so T4RUPT
                CA              POSMAX                          # can reschedule, and then set T4RUPT to occur in
                TS              TIME4                           # <= 10ms.

# All of the balls are now rolling, so we can now wait for TIME6 to expire. While doing so, we can
# verify that TIME6 and the DINC sequence behave as expected.
T6CHK           CCS             TIME6                           # Wait for TIME6 to hit -0
                TCF             T6CHK
                TC              ERRORS                          # (NOT +0, is skipped over)
                TC              ERRORS
                CS              BIT15                           # TIME6 has reached -0. It is, hover, still active,
                EXTEND                                          # because DINC doesn't trigger ZOUT (needed for
                ROR             CHAN13                          # T6RUPT) until it occurs when its counter is already
                TC              -0CHK                           # +-0. Thus, T6 should still be enabled.

# We can now waste a bit of time until the final TIME6 count occurs, and in doing so verify that
# it's counting at roughly the expected rate (1/1600 seconds). That translates to ~53.333 MCT. The
# following loops is timed such that from the "CS BIT15" above to to the "EXTEND" below there
# are exactly 54 MCTs (ignoring any counter increments).
                CAF             NINE
T6BUSYWT        NOOP
                CCS             A
                TCF             T6BUSYWT

                CAF             BIT15                           # T6 should now have switched itself off.
                EXTEND
                RAND            CHAN13
                TC              +0CHK

# At this point, we can safely expect all four timer interrupts to be pending. We can now
# test each one works, and that each has the correct priority, by executing four EDRUPTs
# and checking to see that the expected timer interrupt was serviced. The expected priority
# order is 6, 5, 3, 4.
PRIOCHK         CAF             SIX
                TC              TRIGRUPT
                CAF             FIVE
                TC              TRIGRUPT
                CAF             THREE
                TC              TRIGRUPT
                CAF             FOUR
                TC              TRIGRUPT

# Timers and their interrupts are healthy. It's finally safe to release interrupts.
                RELINT

# Check that bits set in the upper 4 bits of Z disappear between instructions, and that
# storing directly to Z behaves as expected.
ZCHK            CA              ZSKIPADR                        # Check proper operation of Z. Z should
                AD              SBIT13                          # generally shed anything in its upper
                TS              Z                               # 4 bits.
                TC              ERRORS                          # Storing to Z should take immediate effect.

ZSKIP           CS              Z                               # Make sure bit 13 disappeared.
                AD              ZSKIPADR
                TC              -1CHK

# The only exception to the above is RESUME. A RESUME moves the full contents of ZRUPT into Z, without
# truncating to the lower 12 bits. The next instruction executed after the RESUME (i.e., the one in
# BRUPT) can therefore see these upper bits of Z. This is the only time these bits' existence are
# detectable (outside of one particular DV case, which we will exercise shortly).
ZRUPTCHK        CA              ZRELADR                         # Piece together a value for ZRUPT with a
                AD              SBIT13                          # high-order bit set.
                INHINT                                          # Inhibit interrupts so we can safely
                TS              ZRUPT                           # touch ZRUPT and BRUPT.
                CA              ZSKIP                           # Replace BRUPT with "CS Z", which we will
                TS              BRUPT                           # use to sense the upper Z bits.
                RESUME                                          # RESUME, so BRUPT is executed and Z = ZRUPT
ZREL            RELINT                                          # Interrupts are safe now.
                AD              SBIT13
                AD              ZRELADR
                TC              -0CHK                           # ZRUPT should have been ZREL + SBIT13

# Next, perform some extra tests on the DV instruction. DV has a lot of cases that give strange results.
# All of the tests performed so far only test the "nominal" case of divisor >= dividend, and no overflow.
# The documentation available simply says that the divisor < dividend case results in "nonsense". Nothing
# is said about overflow (which is catastrophic in the divisor) or special register cases, all of which
# can give very different results. These tests are provided in an attempt to ensure that DV operates
# correctly in *all* cases.
# The extended DV test is table-driven; each table entry contians a dividend, divisor, expected quotient
# and remainder, and overflow flags.
# The following SKEEP registers are used:
# SKEEP4 - contains the address of the DV table entry being tested. This can be examined on test failure.
# SKEEP5 - contains the address of the register used as the divisor (A, L, Q, or Z).
# SKEEP6 - contains 0, HALF, or -HALF, which is added twice to the dividend to generate overflow.

EXDVTSTS        CAF             DVTBLADR                        # Load the start of the DV table
                TS              SKEEP4

EXDVLOOP        INDEX           SKEEP4                          # Load the divisor, which will normally be
                CAF             DIVISOR                         # stored in the Q register.
                TS              Q
# Some values of the divisor (+1, +2, +3) indicate that A, L, or Z respectively should be used instead 
# of Q. The final division is performed by INDEXing DV 0, so we can tweak the targeted register to match
# what the table is requested.
                EXTEND                                          # If the divisor is negative or zero, we
                BZMF            QDIV                            # can safely assume we're dividing by Q.
                MASK            NEG3
                CCS             A                               # Are any bits above bit 2 set?
                TCF             QDIV                            # Yes: the divisor is not 1, 2, or 3    
                INDEX           Q                               # No: the divisor is 1, 2, or 3. Determine
DIVSRTAB        TCF             DIVSRTAB                        # which register is selected.
                TCF             ADIV                            # A is 0 from the CCS here
                TCF             LDIV

ZDIV            CAF             FIVE                            # Divisor = Z
                TCF             ADIV

LDIV            CAF             ONE                             # Divisor = L
                TCF             ADIV

QDIV            CAF             TWO                             # Divisor = Q
ADIV            TS              SKEEP5

# Next, determine if the dividend will have overflow. We do this before checking if the divisor gets
# overflow, since that may potentially end up with overflow in Q, and thus must be INHINTed.
                CAF             DVDNDOVF                        # Load the dividend overflow bit.
                INDEX           SKEEP4
                MASK            OVFFLAGS 
                EXTEND                                          # If no overflow is requested, go store the
                BZF             STOROVF                         # resluting 0 in SKEEP6 (A + 0 + 0 = A).
                INDEX           SKEEP4                          # Overflow requested. Check if the dividend's
                CAF             DIVIDEND                        # A is positive or negative.
                CCS             A
                TCF             DVDNDPOV                        # A = positive or +0. Go load HALF (20000)
                TCF             DVDNDPOV

                NOOP                                            # A = negative or -0. Load -HALF (57777).
                CS              HALF
                TCF             STOROVF

DVDNDPOV        CA              HALF
STOROVF         TS              SKEEP6                          # Whatever the result, store it in SKEEP6
                
# Dividend overflow is taken care of, for now. Now check to see if we need overflow in the divisor.
                CAF             DIVSROVF                        # Load the divisor overflow bit.
                INDEX           SKEEP4
                MASK            OVFFLAGS
                EXTEND                                          # If no overflow is requested, we can skip
                BZF             DVDNDLOD                        # fiddling with Q.
                CCS             Q
                TCF             DIVSRPOV                        # Q is positive or +0. Go load +HALF and
                TCF             DIVSRPOV                        # for creating positive overflow.

                NOOP                                            # Q is negative or -0. Go load -HALF
                CS              HALF                            # for creating negative overflow.
                TCF             MKOVFLOW

DIVSRPOV        CA              HALF
MKOVFLOW        INHINT
                XCH             Q
                AD              Q                               # Add +HALF or -HALF to Q twice to get
                AD              Q                               # overflow.
                XCH             Q                               # Restore the divisor back to Q.
                
# We can finally load the dividend and apply the requested overflow to it.
DVDNDLOD        EXTEND
                INDEX           SKEEP4
                DCA             DIVIDEND

                AD              SKEEP6                          # Inject overflow (maybe) into A.
                AD              SKEEP6

# All of the setup is done. Go perform the division! The code to do so is at the begninning of the bank,
# to provide a predictable location for DV Z cases.
                TCF             DODV
DVDONE          RELINT                                          # Division returns here. It is now safe to RELINT.

                COM                                             # Check the quotient.
                INDEX           SKEEP4
                AD              QUOTIENT
                TC              -0CHK
                CS              L                               # Check the remainder.
                INDEX           SKEEP4
                AD              REMAINDR
                TC              -0CHK

                CAF             SIX                             # Move on to the next table entry.
                ADS             SKEEP4
                AD              -DVENDAD
                EXTEND                                          # When we run off the end of the table, we are
                BZMF            EXDVLOOP                        # done dividing things.

# Head to bank 3, where all EDRUPT tests must take place.
                TC              BRUPTCHK

# Extended tests are complete. Head back to self-check proper.
                TC              POSTJUMP
                CADR            EXTTDONE

# Interrupt routine used in BRUPTCHK.
ARUPTVEC        DXCH            ARUPT                           # Although Q is also destroyed, we happen to know
                                                                # that the "interrupted" program doesn't need it.

                CS              BRUPT                           # Check that BRUPT was correctly calculated as 
                AD              EDRPTWRD                        # "EDRUPT BRUPTCHK +5".
                AD              FIVE
                TC              -0CHK

                CS              ZRUPT                           # ZRUPT should be pointing at the address
                AD              EDRP+1AD                        # immediately following the EDRUPT.
                TC              -0CHK

                CAF             BRUPTCHK                        # Break out of the EDRUPT loop by replacing
                TS              BRUPT                           # BRUPT with "CAF FIVE".
                TC              NOQBRSM

ZSKIPADR        ADRES           ZSKIP
ZRELADR         ADRES           ZREL

ARVECADR        ADRES           ARUPTVEC
EDRP+1AD        ADRES           EDRPT+1

# Do-nothing waitlist task, used as a dummy when generating a fast T3RUPT.
NOTHING         TC              TASKOVER

ENDEXTST        EQUALS

                SETLOC          ENDINTF
# Check EDRUPT's ability to vector to A with no pending interrupts, the correct
# behavior of BRUPT for interrupts following an INDEX, and BRUPT substitution.
BRUPTCHK        CAF             FIVE                            # SKEEP1 = 5. This will be used for indexing.
                TS              SKEEP1
                EXTEND                                          # Save our return address.
                QXCH            SKEEP2
                CAF             ARVECADR                        # Attempt to use EDRUPT to vector to ARUPTVEC.
 +5             EXTEND                                          # If some other interrupt is taken, continue
                INDEX           SKEEP1                          # at BRUPTCHK+5 (as calculated by the INDEX).
EDRPTWRD        EDRUPT          BRUPTCHK                        # This instruction should be replaced with
EDRPT+1         AD              NEG4                            # "CAF FIVE" upon resume. Make sure it did.
                TC              +1CHK

                TC              SKEEP2                          # All done here. Head back to SELF-CHECK proper.

# Routine to trigger a pending timer interrupt and verify that the timer whose number is
# specified in A was the one that got serviced.
TRIGRUPT        XCH             L
                EXTEND
                QXCH            SKEEP1
                CAF             ZERO                            # Zero LASTIMER so we don't get duped.
                TS              LASTIMER
                CA              NOPNDADR                        # EDRUPT will fall back on this vector if
                EXTEND                                          # no interrupts at all are pending.
                EDRUPT          TRPTCHK                         # Trigger an interrupt, then skip over TC ERRORS.
                TC              ERRORS
TRPTCHK         CS              LASTIMER                        # Check the timer that just got executed matches
                AD              L                               # what was expected.
                TC              -0CHK
                TC              SKEEP1

NOPNDING        TC              ERRORS
NOPNDADR        ADRES           NOPNDING

# T5 and T6 interrupt routines. Both currently only set LASTIMER for use with the extended self-tests.
T5RUPT          TS              BANKRUPT
                CAF             FIVE
                TS              LASTIMER
                TCF             NOQRSM

T6RUPT          TS              BANKRUPT
                CAF             SIX
                TS              LASTIMER
                TCF             NOQRSM

ENDSLFS4        EQUALS

# --------------- Extended DV table ------------------
# Table entry offsets for convenient use
DIVIDEND        =               0
DIVISOR         =               2
QUOTIENT        =               3
REMAINDR        =               4
OVFFLAGS        =               5

# Overflow flags
DVDNDOVF        EQUALS          ONE                             # Dividend overflow
DIVSROVF        EQUALS          TWO                             # Divisor overflow

                SETLOC          ENDEXTST
DVTBLADR        GENADR          DVTBL                           # Table start+end addresses
-DVENDAD        -GENADR         DVTBLEND

# Regular division with + dividend and + divisor
DVTBL           2OCT            1010414241                      # Dividend
                OCT             25274                           # Divisor
                OCT             14134                           # Quotient
                OCT             16421                           # Remainder
                OCT             0                               # No overflow

# Regular division with + dividend and - divisor
                2OCT            0124577243                      # Dividend
                OCT             60012                           # Divisor
                OCT             75264                           # Quotient
                OCT             14335                           # Remainder
                OCT             0                               # No overflow

# Regular division with - dividend and + divisor
                2OCT            5027751551                      # Dividend
                OCT             33174                           # Divisor
                OCT             44176                           # Quotient
                OCT             65745                           # Remainder
                OCT             0                               # No overflow

# Regular division with - dividend and - divisor
                2OCT            7331624300                      # Dividend
                OCT             51027                           # Divisor
                OCT             06317                           # Quotient
                OCT             63527                           # Remainder
                OCT             0                               # No overflow

# Quotient with + overflow (result not affected)
                2OCT            1454232017                      # Dividend
                OCT             37722                           # Divisor
                OCT             14565                           # Quotient
                OCT             03425                           # Remainder
                OCT             1                               # Dividend +overflow

# Quotient with - overflow (result not affected)
                2OCT            6677143023                      # Dividend
                OCT             22326                           # Divisor
                OCT             60255                           # Quotient
                OCT             76237                           # Remainder
                OCT             1                               # Dividend -overflow

# Divisor with + overflow
                2OCT            0712355512                      # Dividend
                OCT             20440                           # Divisor
                OCT             04010                           # Quotient
                OCT             11113                           # Remainder
                OCT             2                               # Divisor +overflow

# Divisor with - overflow
                2OCT            2727730174                      # Dividend
                OCT             47022                           # Divisor
                OCT             73777                           # Quotient
                OCT             04174                           # Remainder
                OCT             2                               # Divisor -overflow

# Nonsense division with + dividend and + divisor
                2OCT            3204407613                      # Dividend
                OCT             13370                           # Divisor
                OCT             34037                           # Quotient
                OCT             03603                           # Remainder
                OCT             0                               # No overflow

# Nonsense division with + dividend and - divisor
                2OCT            1403261245                      # Dividend
                OCT             70651                           # Divisor
                OCT             40415                           # Quotient
                OCT             00532                           # Remainder
                OCT             0                               # No overflow

# Nonsense division with - dividend and + divisor
                2OCT            5761364412                      # Dividend
                OCT             10201                           # Divisor
                OCT             40061                           # Quotient
                OCT             67730                           # Remainder
                OCT             0                               # No overflow

# Nonsense division with - dividend and - divisor
                2OCT            4675533326                      # Dividend
                OCT             17647                           # Divisor
                OCT             55570                           # Quotient
                OCT             61746                           # Remainder
                OCT             0                               # No overflow

# Division by +0
                2OCT            1234567654                      # Dividend
                OCT             00000                           # Divisor
                OCT             37777                           # Quotient
                OCT             27655                           # Remainder
                OCT             0                               # No overflow

# Division by -0
                2OCT            3412517762                      # Dividend
                OCT             77777                           # Divisor
                OCT             40000                           # Quotient
                OCT             17762                           # Remainder (actually 057762 but L is overflow corrected)
                OCT             0                               # No overflow

# Nonsense division with overflow in quotient (no effect)
                2OCT            3051240771                      # Dividend
                OCT             20015                           # Divisor
                OCT             21204                           # Quotient
                OCT             00506                           # Remainder
                OCT             1                               # Dividend +overflow

# Nonsense division with + overflow in divisor
                2OCT            2227227222                      # Dividend
                OCT             14443                           # Divisor
                OCT             00200                           # Quotient
                OCT             16422                           # Remainder
                OCT             2                               # Divisor +overflow

# Nonsense division with - overflow in divisor
                2OCT            3456765432                      # Dividend
                OCT             66543                           # Divisor
                OCT             57777                           # Quotient
                OCT             25433                           # Remainder
                OCT             2                               # Divisor -overflow

# Nonsense division with - overflow in divisor
                2OCT            3456765432                      # Dividend
                OCT             66543                           # Divisor
                OCT             57777                           # Quotient
                OCT             25433                           # Remainder
                OCT             2                               # Divisor -overflow

# Regular division with positive A as divisor (actually -|A|)
                2OCT            2137600000                      # Dividend
                OCT             1                               # Divisor = A
                OCT             40000                           # Quotient
                OCT             21376                           # Remainder
                OCT             0                               # No overflow

# Regular division with negative A as divisor (no effect)
                2OCT            5442300000                      # Dividend
                OCT             1                               # Divisor = A
                OCT             37777                           # Quotient
                OCT             54423                           # Remainder
                OCT             0                               # No overflow

# Nonsense division with positive A as divisor (actually -|A|)
                2OCT            2740131027                      # Dividend
                OCT             1                               # Divisor = A
                OCT             40001                           # Quotient
                OCT             10031                           # Remainder
                OCT             0                               # No overflow

# Nonsense division with negative A as divisor (no effect)
                2OCT            7654263257                      # Dividend
                OCT             1                               # Divisor = A
                OCT             37777                           # Quotient
                OCT             62022                           # Remainder
                OCT             0                               # No overflow

# Regular division with + overflow A as divisor
                2OCT            1333700000                      # Dividend
                OCT             1                               # Divisor = A
                OCT             67772                           # Quotient
                OCT             16645                           # Remainder
                OCT             1                               # A +overflow

# Regular division with - overflow A as divisor
                2OCT            6626200000                      # Dividend
                OCT             1                               # Divisor = A
                OCT             01211                           # Quotient
                OCT             67064                           # Remainder
                OCT             1                               # A -overflow

# Nonsense division with + overflow A as divisor
                2OCT            3545321212                      # Dividend
                OCT             1                               # Divisor = A
                OCT             77777                           # Quotient
                OCT             21212                           # Remainder (actually 061212 but L is overflow corrected)
                OCT             1                               # A +overflow

# Nonsense division with - overflow A as divisor
                2OCT            5212366411                      # Dividend
                OCT             1                               # Divisor = A
                OCT             01010                           # Quotient
                OCT             61151                           # Remainder (actually 121151 but L is overflow corrected)
                OCT             1                               # A -overflow

# Regular division with positive dividend and positive L as divisor (L gets + overflow)
                2OCT            1743131231                      # Dividend
                OCT             2                               # Divisor = L
                OCT             23526                           # Quotient
                OCT             22063                           # Remainder
                OCT             0                               # No overflow

# Regular division with positive dividend and negative L as divisor (L = L + 40000)
                2OCT            2540047102                      # Dividend
                OCT             2                               # Divisor = L
                OCT             30531                           # Quotient
                OCT             02770                           # Remainder
                OCT             0                               # No overflow

# Regular division with negative dividend and positive L as divisor (L = -L + 40000)
                2OCT            7651711246                      # Dividend
                OCT             2                               # Divisor = L
                OCT             76065                           # Quotient
                OCT             64651                           # Remainder
                OCT             0                               # No overflow

# Regular division with negative dividend and negative L as divisor (L = -L with + overflow)
                2OCT            5077544044                      # Dividend
                OCT             2                               # Divisor = L
                OCT             45507                           # Quotient
                OCT             64614                           # Remainder
                OCT             0                               # No overflow

# Nonsense division with positive dividend and positive L as divisor (L gets + overflow)
                2OCT            3133204417                      # Dividend
                OCT             2                               # Divisor = L
                OCT             37212                           # Quotient
                OCT             02371                           # Remainder
                OCT             0                               # No overflow

# Nonsense division with positive dividend and negative L as divisor (L = L + 40000)
                2OCT            2467267371                      # Dividend
                OCT             2                               # Divisor = L
                OCT             34330                           # Quotient
                OCT             16012                           # Remainder
                OCT             0                               # No overflow

# Nonsense division with negative dividend and positive L as divisor (L = -L + 40000)
                2OCT            5510506670                      # Dividend
                OCT             2                               # Divisor = L
                OCT             47773                           # Quotient
                OCT             53327                           # Remainder
                OCT             0                               # No overflow

# Nonsense division with negative dividend and negative L as divisor (L = -L with + overflow)
                2OCT            4222461674                      # Dividend
                OCT             2                               # Divisor = L
                OCT             40750                           # Quotient
                OCT             63701                           # Remainder
                OCT             0                               # No overflow

# Regular division with positive dividend and Z as divisor (no effect)
                2OCT            0142300467                      # Dividend
                OCT             3                               # Divisor = Z
                OCT             30413                           # Quotient
                OCT             01026                           # Remainder
                OCT             0                               # No overflow

# Regular division with negative dividend and Z as divisor (Z gets negative overflow)
                2OCT            7733342477                      # Dividend
                OCT             3                               # Divisor = Z
                OCT             00000                           # Quotient
                OCT             42477                           # Remainder
                OCT             0                               # No overflow

# Nonsense division with positive dividend and Z as divisor (no effect)
                2OCT            2677610452                      # Dividend
                OCT             3                               # Divisor = Z
                OCT             37664                           # Quotient
                OCT             01016                           # Remainder
                OCT             0                               # No overflow

# Nonsense division with negative dividend and Z as divisor (Z gets negative overflow)
                2OCT            4032141623                      # Dividend
                OCT             3                               # Divisor = Z
                OCT             20000                           # Quotient
                OCT             41623                           # Remainder
DVTBLEND        OCT             0                               # No overflow

ENDDVTAB        EQUALS
