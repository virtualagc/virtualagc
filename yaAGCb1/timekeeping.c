/*
 * Copyright 2016 Ronald S. Burkey <info@sandroid.org>
 *
 * This file is part of yaAGC.
 *
 * yaAGC is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * yaAGC is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with yaAGC; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 *
 * In addition, as a special exception, Ronald S. Burkey gives permission to
 * link the code of this program with the Orbiter SDK library (or with
 * modified versions of the Orbiter SDK library that use the same license as
 * the Orbiter SDK library), and distribute linked combinations including
 * the two. You must obey the GNU General Public License in all respects for
 * all of the code used other than the Orbiter SDK library. If you modify
 * this file, you may extend this exception to your version of the file,
 * but you are not obligated to do so. If you do not wish to do so, delete
 * this exception statement from your version.
 *
 * Filename:    timekeeping.c
 * Purpose:     Various real (as opposed to virtual) timekeeping functions.
 *              They're segregated here because the implementation will vary
 *              for Linux vs Windows vs whatever.
 * Compiler:    GNU gcc.
 * Contact:     Ron Burkey <info@sandroid.org>
 * Reference:   http://www.ibiblio.org/apollo/index.html
 * Mods:        2016-09-03 RSB  Wrote.
 * 		2016-11-18 RSB	Added workaround for non-existence of clock_gettime()
 * 				on Mac OS X, found here:
 * 				http://stackoverflow.com/questions/5167269/clock-gettime-alternative-in-mac-os-x
 */

#include <time.h>
#include <sys/time.h>

#ifdef __MACH__
#include <mach/clock.h>
#include <mach/mach.h>
#endif

#include <string.h>
#include "yaAGCb1.h"

int64_t
getTimeNanoseconds(void)
{
  int64_t currentTime;
  struct timespec timeSpec;

  #ifdef __MACH__ // OS X does not have clock_gettime, use clock_get_time
  clock_serv_t cclock;
  mach_timespec_t mts;
  host_get_clock_service(mach_host_self(), CALENDAR_CLOCK, &cclock);
  clock_get_time(cclock, &mts);
  mach_port_deallocate(mach_task_self(), cclock);
  timeSpec.tv_sec = mts.tv_sec;
  timeSpec.tv_nsec = mts.tv_nsec;

  #else
  clock_gettime(CLOCK_REALTIME, &timeSpec);
  #endif

  currentTime = timeSpec.tv_sec;
  currentTime *= BILLION;
  currentTime += timeSpec.tv_nsec;
  return (currentTime);
}

void
sleepNanoseconds (int64_t nanoseconds)
{
  struct timespec req, rem;

  req.tv_sec = nanoseconds / BILLION;
  req.tv_nsec = nanoseconds % BILLION;

  while (nanosleep(&req, &rem))
    {
      memcpy (&req, &rem, sizeof(struct timespec));
    }
}
