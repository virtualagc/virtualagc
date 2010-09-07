/*
 * Copyright:   None, public domain
 * Filename:    GeminiCatchUpAndRendezvousProgram/ASM.c
 * Purpose:     Provides replacements for various IBM 7090/7094
 *              assembly-language sub-programs of the GEMINI
 *              catch-up and rendezvous simulation program.
 * History:     2010-08-17 RSB  Created in FORTRAN.
 *              2010-09-04 RSB  Replaced with C.
 */

// I have no idea what DSB and ENB were supposed to do.  I expect
// they're some kind of disables/enables for some of the IBM
// 7090/7094 hardware.  Ignore for now.

void
dsb_ (void)
{

}

void
enb_ (void)
{

}

// These set tapes A7/A9/B6 to high/low density.  Obviously, we can
// simply ignore them.

void
hda7_ (void)
{

}

void
hda9_ (void)
{

}

void
ldb6_ (void)
{

}

// Some kind of keypad functions.  Not sure yet how they work.

void
keycn_ (int *k)
{

}

void
keys_ (int *k, int *n)
{

}

// I believe that this skips files on the tape.  Obviously irrelevant
// to us.
void
skpn_ (int *x, int *i, int *j)
{

}

// Generates a self-loading tape on drive A7.  Not sure waht that
// means, but seems safe to ignore.
void
selfld_ (void)
{

}
      
