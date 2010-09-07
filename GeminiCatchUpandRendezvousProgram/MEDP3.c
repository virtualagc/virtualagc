/*
 * Copyright:   None.  This code is in the public domain.
 * Filename:    GeminiCatchUpAndRendezvousProgram/MEDP3.c.
 * Purpose:     This is part of the Virtual AGC port of the
 *              the original 1965 simulation program for the Gemini 7/6
 *              mission catch-up and rendezvous flight phases.  This
 *              particular file ports the IBM 7090/7094 assembly-language
 *              subroutines collectively identified as "MEDP3" (modified
 *              Euler integration subroutine), by Eckstrom of IBM Owego.
 *              Refer to the file MEDP3.s for the actual assembly code.
 * Compiler:    The details of linking C-language subroutines to FORTRAN
 *              main programs assume that the GNU gcc compiler collection
 *              has been used.  My understanding is that it may work as-is
 *              with Intel's compiler as well, though I don't really know.
 *              If some other compilers are used, the details will have to
 *              be modified accordingly.
 * Website:     http://www.ibiblio.org/apollo
 * History:     2010-09-02 RSB  Began.
 *              2010-09-04 RSB  Completed coding.  No idea of correctness
 *                              yet.
 *
 * The website linked above contains a variety of documents in the
 * Gemini section of its document library that are necessary to understand
 * details of the IBM 7090/7094 system, FORTRAN II, the assembly-language,
 * and the subroutine linkage of FORTRAN-to-assembly.  I've included the
 * original assembly language in-line as comments.  It is probably
 * important to realize that I have no more knowledge or experience with
 * IBM 7090/7094 than does an andouille sausage, and the existing
 * documentation is a little hard to decipher completely, so there's some
 * guesswork involved.
 *
 * The port is a simple-minded translation of each assembly-language
 * instruction to C, on a line-by-line basis.  The resulting code
 * can very trivially be replaced by much-more-understandable structured
 * code, and can be simplified in a number of other ways, but I've chosen
 * to keep it this way both to more-accurately reflect the style of the
 * original code and to make verifying it against the original easier.
 */

// These are fake CPU registers.  We make them unions to
// allow them to contain any data type.  The only data
// types that I observe I need are added.
static union {
  int i;
  float x;
  float *xp;
} acc, mq, xr1;
// The original assembly-language code is self-modifying.
// In particular, many of the instructions (at labels
// like X1, expected to have their address fields modified
// at runtime.  We handle this by having a variable for each
// of these instructions that contains a pointer to the
// data which is supposed to be operated upon.
static float *x1_address;
static float *x2_address;
static float *x3_address;
static float *x4_address;
static float *x5_address;
static float *x6_address;
static float *xd1_address;
static float *xd2_address;
static float *xd3_address;
static float *xp1_address;
static float *xp2_address;
static float *xdp1_address;
static float *xdp2_address;
static float *xl1_address;
static float *xl2_address;
static float *xl3_address;

// Variables actually defined by the original code:
// DT     PZE
static float dt = 0.0;
// N      PZE
static int n = 0;
// D1     PZE     ,,1
static int d1 = 0;
// D2     PZE     ,,2
static int d2 = 0;
// COUNT  PZE
static int count = 0;
// IND    PZE
static int ind = 0;
// TWO    DEC     2.
static float two = 2.0;
// TEMP   PZE
static float temp = 0.0;

// The PRT and DEV subroutines expect to have access to the
// parameter list of the MAR subroutine.  So we provide
// some temporary variables for saving that parameter
// list.
static int *i_saved;
static float *x_saved;
static float *y_saved;
static int *j_saved;
static int *k_saved;
static int *nout_saved;

// This appears to be a function that initializes the Euler
// computation, but doesn't actually compute anything.  It sets
// up a bunch of stuff used by PRT and DEV.
//        ENTRY   MAR
void
mar_ (int *i, float *x, float *y, int *j, int *k, int *nout)
{
  // The PRT and DEV subroutines expect to have access to the
  // parameter list of the MAR subroutine, so we save it.
  i_saved = i;
  x_saved = x;
  y_saved = y;
  j_saved = j;
  k_saved = k;
  nout_saved = nout;

  // Here's the actual translation of the code.
  // MAR    STZ     COUNT
  count = 0;
  //------------------------------------------------------------
  // All of this block is devoted to fetching some of the
  // function parameters and storing them in variables or setting
  // up self-modifying code ... which for us is just storing stuff
  // in pointer variables.  And yes, if this code was being
  // created from scratch rather than trying to mimic previously
  // created code in a very mindless way, it could be coded much
  // better.  All of the function parameters are pointers, since
  // FORTRAN II used "call by reference" rather than "call by
  // value" for everything.  CPU index register XR4 contains the
  // address from which the call was made, and the succeeding
  // locations from the instruction that perform the call contain
  // the parameters (which are pointers).  An instruction like
  // "CLA 3,4" is relative to XR4 and would load the third parameter
  // (again, a pointer!) into the accumulator, while "CLA* 3,4"
  // uses indirect addressing and would load the actual value which
  // the third parameter points to into the accumulator.
  //        CLA*    2,4
  //        STO     DT
  acc.x = *x;
  dt = acc.x;
  //        CLA*    1,4
  //        ARS     18
  //        STO     N
  acc.i = *i;
  acc.i = acc.i >> 18;
  n = acc.i;
  //        CLA     3,4
  acc.xp = y;
  //        ADD     N
  acc.xp += n;
  //        STA     X1
  //        STA     X2
  //        STA     X3
  //        STA     X4
  //        STA X5
  //        STA X6
  x1_address = acc.xp;
  x2_address = acc.xp;
  x3_address = acc.xp;
  x4_address = acc.xp;
  x5_address = acc.xp;
  x6_address = acc.xp;
  //        ADD     N
  acc.xp += n;
  //        STA     XD1
  //        STA     XD2
  //        STA     XD3
  xd1_address = acc.xp;
  xd2_address = acc.xp;
  xd3_address = acc.xp;
  //        ADD     N
  acc.xp += n;
  //        STA     XP1
  //        STA     XP2
  xp1_address = acc.xp;
  xp2_address = acc.xp;
  //        ADD     N
  acc.xp += n;
  //        STA     XDP1
  //        STA     XDP2
  xdp1_address = acc.xp;
  xdp2_address = acc.xp;
  //        ADD     N
  acc.xp += n;
  //        STA XL1
  //        STA XL2
  //        STA XL3
  xl1_address = acc.xp;
  xl2_address = acc.xp;
  xl3_address = acc.xp;
  //------------------------------------------------------------
  // I think what's happening with the next two instructions
  // is that CPU index-register XR1 is being temporarily saved
  // by modifying the AXT instruction somewhat below, so that
  // the register can be used in the loop that precedes the AXT.
  //        SXA *+4,1
  //        LXA N,1
  xr1.i = n;
  // XL3    STZ *,1
  //        TIX *-1,1,1
  xl3: xl3_address[xr1.i] = 0;
  if (xr1.i > 1)
    {
      xr1.i--;
      goto xl3;
    }
  // I think the AXT is how XR1 gets restored after the loop
  // above.  Of course, we don't care if it gets restored or
  // not (since there isn't one anyway), so we just ignore
  // the instruction completely.
  //        AXT *,1
  // What the following nasty instruction does is indirectly
  // to modify the return addresses of the DEV and PRT
  // subroutines, so that they return to the point after
  // the "CALL MAR" rather than to the points after "CALL DEV"
  // or "CALL PRT".  We have no way to handle that at this
  // level, so we actually handle it in the FORTRAN code where
  // the calls are made and just ignore the instruction.
  //      SXA     S4,4
  // Back to non-sickening code ...
  //      CLA     D1
  //      STO*    6,4
  acc.i = d1;
  *nout = acc.i;
  //      STZ     IND
  ind = 0;
  // The following is simply a 'return'.
  //      TRA     7,4
}

//        ENTRY   PRT
void
prt_ (void)
{
  // PRT    STZ     COUNT
  count = 0;
  // What the following instruction does is to alter the
  // return address to be that of the "CALL MAR", and to
  // make the parameter list of the "CALL MAR" available
  // to us.  We handle all that elsewhere, and so ignore
  // the instruction completely.
  //     LXA     S4,4
  // The following instruction accesses one of MAR's
  // input parameters.
  //     CLA*    2,4
  //     STO     DT
  acc.x = *x_saved;
  dt = acc.x;
  // Transfer to the DEV subroutine.  Not needed.
  //     TRA     LD
  // In the original code, the following was actually a part
  // of the DEV subroutine.  For us it's easiest and safest
  // simply to duplicate it here.
  // LD     CLA     D1
  acc.i = d1;
  // Output through a pointer provided in the MAR input
  // list.
  //        STO*    6,4
  *nout_saved = acc.i;
  // A simple 'return'.  It should really return to the
  // point after the "CALL MAR", but that's now handled in
  // the FORTRAN instead of here, so we can simply return
  // with taking any special action.
  //        TRA     7,4
}

//        ENTRY   DEV
static double DummyX;
void
dev_ (void)
{
  // The following instruction is used to save CPU index
  // register XR1 so that it can be restored later after.
  // We don't care anything about XR1, which doesn't exist
  // anyway, so we can just ignore the instruction.
  // DEV    SXA     EXIT,1
  // The following instruction is used for changing the
  // return address to that of mar_(), and to allow access
  // to the parameter list of mar_().  The former is handled
  // instead in the FORTRAN, while the latter is handled
  // instead with global variables, so we can just ignore
  // the instruction.
  //  S4    AXT     *,4
  //        LXA     N,1
  xr1.i = n;
  // Back to "real" code ...
  //        ZET     IND
  if (ind == 0)
    goto x1;
  //        TRA     XDP2            =I
  goto xdp2;
  // X1     CLS     *,1             = O, V+N
  // XP1    STO     *,1                  V+3N
  x1: acc.x = -x1_address[xr1.i];
  xp1_address[xr1.i] = acc.x;
  // XD1    CLA     *,1                 V+2N
  // XDP1   STO     *,1                 V+4N
  acc.x = xd1_address[xr1.i];
  xdp1_address[xr1.i] = acc.x;
  // XD3    LDQ     *,1                 V+2N
  mq.x = xd3_address[xr1.i];
  //        FMP     DT
  DummyX = dt;
  DummyX *= mq.x;
  acc.x = DummyX;
  mq.x = DummyX - acc.x;
  // X2     FAD     *,1             V+N
  DummyX = acc.x;
  DummyX += x2_address[xr1.i];
  acc.x = DummyX;
  mq.x = DummyX - acc.x;
  // X3     STO     *,1             V+N
  x3_address[xr1.i] = acc.x;
  //        TIX     X1,1,1
  if (xr1.i > 1)
    {
      xr1.i--;
      goto x1;
    }
  //        CLA     D1
  //        STO     IND
  acc.i = d1;
  ind = acc.i;
  // The following instruction just reloads register XR1
  // from the value we previously saved before using the
  // register as a loop counter.  We don't care what its
  // original value was, so we don't have to actually do
  // anything with the instruction.
  //        LXA     EXIT,1
  //        TRA     LD
  goto ld;
  // XDP2   CLA     *,1             V+4N
  xdp2: acc.x = xdp2_address[xr1.i];
  // XD2    FAD     *,1             V+2N
  DummyX = xd2_address[xr1.i];
  DummyX += acc.x;
  acc.x = DummyX;
  mq.x = DummyX - acc.x;
  //        FDP     TWO
  DummyX = acc.x;
  mq.x = DummyX / two;
  acc.x = DummyX - mq.x * two;
  //        FMP     DT
  DummyX = mq.x;
  DummyX *= dt;
  acc.x = DummyX;
  mq.x = DummyX - acc.x;
  // XP2    FAD     *,1             V+3N
  DummyX = xp2_address[xr1.i];
  DummyX += acc.x;
  acc.x = DummyX;
  mq.x = DummyX - acc.x;
  // X4     STO     *,1             V+N
  x4_address[xr1.i] = acc.x;
  //        STQ TEMP
  //        CLA TEMP
  temp = mq.x;
  acc.x = temp;
  // XL1    FAD *,1
  DummyX = xl1_address[xr1.i];
  DummyX += acc.x;
  acc.x = DummyX;
  mq.x = DummyX - acc.x;
  // X5     FAD *,1
  DummyX = x5_address[xr1.i];
  DummyX += acc.x;
  acc.x = DummyX;
  mq.x = DummyX - acc.x;
  // X6     STO *,1
  // XL2    STQ *,1
  x6_address[xr1.i] = acc.x;
  xl2_address[xr1.i] = mq.x;
  //        TIX     XDP2,1,1
  if (xr1.i > 1)
    {
      xr1.i--;
      goto xdp2;
    }
  //        STZ     IND
  ind = 0;
  // The following instruction just restores XR1, which
  // is irrelevant to us, so we can ignore the instruction.
  // EXIT   AXT     *,1
  //        CLA     COUNT
  acc.i = count;
  //        ADD     D1
  acc.i += d1;
  //        STO     COUNT
  count = acc.i;
  //        SUB*    5,4
  acc.i -= *k_saved;
  // The labels StarPlus and StarMinus which I've used below
  // have nothing to do with whether or not the tests below
  // are plus or minus.  They relate instead to whether the
  // jump targets were things like "*+something" or "*-something".
  //        TZE     *+5
  if (acc.i == 0)
    goto StarPlus;
  //        TPL     *+4
  if (acc.i > 0)
    goto StarPlus;
  // LD     CLA     D1
  ld: acc.i = d1;
  //        STO*    6,4
  StarMinus: *nout_saved = acc.i;
  //        TRA     7,4
  return;
  //        CLA     D2
  StarPlus: acc.i = d2;
  //        TRA     *-3
  goto StarMinus;
}
