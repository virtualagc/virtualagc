/*
 * License:     The author (Ronald S. Burkey) declares that this program
 *              is in the Public Domain (U.S. law) and may be used or
 *              modified for any purpose whatever without licensing.
 * Filename:    spacelib.c
 * Purpose:     This is the portion of the runtime library (of which
 *              runtimeC.c is the main part) that manages the memory for
 *              BASED ... DYNAMIC declarations for the XPL/I-to-C translator
 *              XCOM-I.py.
 * Reference:   http://www.ibibio.org/apollo/Shuttle.html
 * Mods:        2024-04-08 RSB  Began.
 */

/*
 * Objects declared using `BASED` are subject to having their element-count
 * increased during program execution.  Therefore, it seems that there has
 * to be some way to manage the memory allocation for these objects.  The
 * original Intermetrics XPL/I compiler had the same issue with CHARACTER
 * variables, I think, but those are statically allocated in XCOM-I at compile
 * time, so it's not an issue with XCOM-I.
 *
 * In speaking of "memory", of course, I am referring to the memory model used
 * by the C code output by XCOM-I, namely the byte array of size 2**24
 * actually called `memory`.  Thus the memory-management functions normally
 * provided by C, namely `malloc` et al, are of no relevance.
 *
 * It appears to me that the user code performs the bulk of the memory
 * management explicitly via MONITOR() calls:
 *
 *      MONITOR(6)      Allocate a requested quantity of free memory and store
 *                      its address into a BASED variable.
 *      MONITOR(7)      Free a requested quantity of free memory pointed to by
 *                      a BASED variable.
 *      MONITOR(19)     Same as MONITOR(6), but with a list of BASED variables
 *                      and requested sizes.
 *      MONITOR(20)     Same as MONITOR(7), but with a list of BASED variables
 *                      and requested sizes.
 *      MONITOR(21)     Return the size of the largest remaining block of free
 *                      memory.
 *
 * What remains, I believe, is implementation of `COMPACTIFY` function to
 * eliminate memory fragmentation.  This is a built-in of XPL, and is provided
 * by SPACELIB in the original Intermetrics compiler.  The present
 * source-code file (spacelig.c) is probably my replacement for SPACELIB.xpl.
 * With that said, SPACELIB is incomprehensible to me.  It was clearly written
 * by people intimately familiar with what it was supposed to be doing ... and
 * with no inclination to let us in on that secret.  So spacelib.c is not based
 * on SPACELIB.xpl in any way other than my broad conception of what may or may
 * not be going on with it.  In other words, regardless of the similar naming,
 * I can't claim with any conviction that the replacement is complete or 100%
 * accurate.
 *
 * The following built-ins are associated with the management process,
 * according to McKeeman.  IR-182-1 does not document it at all, although
 * differing from standard XPL, and SPACELIB.xpl (which implements it) is
 * essentially incomprehensible.
 *
 * COMPACTIFY -- See McKeeman p. 140.  However, for XCOM-I, handles only BASED
 * variables (which don't exist in McKeeman) and doesn't handle CHARACTER
 * variables since they're declared statically.
 *
 * FREEBASE -- See McKeeman p. 141.
 *
 *
 */

#include "runtimeC.h"
