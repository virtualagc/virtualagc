/*
 * Copyright:   None, public domain
 * Filename:    GeminiCatchUpAndRendezvousProgram/TCTRL.c
 * Purpose:     Provides replacements for CTRL1 IBM 7090/7094
 *              assembly-language sub-programs of the GEMINI
 *              catch-up and rendezvous simulation program.
 * History:     2010-08-17 RSB  Created in FORTRAN.
 *              2010-09-04 RSB  Replaced with C.
 *
 * This is the control-program that passes control back and forth
 * between the rendezvous environment program and the OBC simulation
 * program when the dynamic simulator is used.
 *
 * This is really a complete replacement of the original code rather
 * than a translation of the assembly code into C.  Note that the
 * control program actually has some external documentation
 * (on page 19 of "Report #4" from which all of the FORTRAN and
 * assembly-language source code came).
 *
 * As near as I can figure it, the assembly-language control program
 * passed control back and forth based on elapsed time, but had no
 * hardware timers with which to do that.  Instead, it provided timing
 * by writing to a tape (B6), having previously figured out how many
 * words need to be written in the desired time-interval.  After the
 * desired time had passed, an IBM 7090/7094 i/o-channel interrupt
 * occurred.  That's all very clever, of course, but completely non-
 * portable and irrelevant for our purposes since we need to do
 * something portable.  Almost all of the original code is discarded,
 * since it mostly has to do with controlling the tape operation.
 */

void
ctrl1_ (void)
{

}

