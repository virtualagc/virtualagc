/*
 * Copyright:   None, public domain
 * Filename:    GeminiCatchUpAndRendezvousProgram/SENSE.c
 * Purpose:     Provides (as a workaround) replacements for the
 *              FORTRAN II "SENSE LIGHT" and "SENSE SWITCH" stuff
 *              for compiling in later versions of FORTRAN that
 *              lack them.
 * History:     2010-08-17 RSB  Created in FORTRAN.
 *              2010-09-04 RSB  Replaced with C.  Added some actual
 *                              simple functionality in place of the
 *                              non-functional sub-programs that had
 *                              been in the FORTRAN.
 */

#include <stdio.h>

// The following constants can be manipulated on the compiler
// command-line at build-time.
#ifndef MAX_SENSE_LIGHT
#define MAX_SENSE_LIGHT 4
#endif
#ifndef DEFAULT_SENSE_LIGHTS
#define DEFAULT_SENSE_LIGHTS {0,0,0,0}
#endif
#ifndef MAX_SENSE_SWITCH
#define MAX_SENSE_SWITCH 6
#endif
#ifndef DEFAULT_SENSE_SWITCHES
#define DEFAULT_SENSE_SWITCHES {0,0,0,0,0,0}
#endif
static int SenseLights[MAX_SENSE_LIGHT] = DEFAULT_SENSE_LIGHTS;
static int SenseSwitches[MAX_SENSE_SWITCH] = DEFAULT_SENSE_SWITCHES;

void
stsnlt_ (int *i)
{
  int Light;
  if (*i == 0)
    {
      for (Light = 0; Light < MAX_SENSE_LIGHT; Light++)
        SenseLights[Light] = 0;
      fprintf (stderr, "All SENSE LIGHTS now off.\n");
    }
  else if (*i >= 1 && *i <= MAX_SENSE_LIGHT)
    {
      Light = *i - 1;
      SenseLights[Light] = 1;
      fprintf (stderr, "SENSE LIGHT %d now on.\n", *i);
    }
  else
    {
      fprintf (stderr, "Illegal SENSE LIGHT %d accessed.\n", *i);
    }
}

int
gtsnlt_ (int *i)
{
  if (*i >= 1 && *i <= MAX_SENSE_LIGHT)
    {
      return (SenseLights[*i - 1]);
    }
  else
    {
      fprintf (stderr, "Illegal SENSE LIGHT %d accessed.\n", *i);
      return (0);
    }
}

// Note that there's presently no way to actually change any of the
// sense switches at runtime.  Probably need to add that code later.
int
gtsnsw_ (int *i)
{
  if (*i >= 1 && *i <= MAX_SENSE_SWITCH)
    {
      return (SenseSwitches[*i - 1]);
    }
  else
    {
      fprintf (stderr, "Illegal SENSE SWITCH %d accessed.\n", *i);
      return (0);
    }
}
