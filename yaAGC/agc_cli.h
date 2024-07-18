/*
 * Original Copyright 2003-2006,2009,2017 Ronald S. Burkey <info@sandroid.org>
 * Modified Copyright 2008,2016 Onno Hommes <ohommes@alumni.cmu.edu>
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
 * In addition, as a special exception, permission is given to
 * link the code of this program with the Orbiter SDK library (or with
 * modified versions of the Orbiter SDK library that use the same license as
 * the Orbiter SDK library), and distribute linked combinations including
 * the two. You must obey the GNU General Public License in all respects for
 * all of the code used other than the Orbiter SDK library. If you modify
 * this file, you may extend this exception to your version of the file,
 * but you are not obligated to do so. If you do not wish to do so, delete
 * this exception statement from your version.
 *
 * Filename:	agc_cli.h
 * Purpose:	This header contains the command-line definitions
 * Contact:	Onno Hommes <ohommes@alumni.cmu.edu>
 * Reference:	http://www.ibiblio.org/apollo
 * Mods:        11/30/08 OH.	Began rework
 *              08/04/16 OH    	Fixed the GPL statement and old user-id
 *              09/30/16 MAS   	Added the --inhibit-alarms option
 *              05/30/17 RSB	Added --initialize-sunburst-37 option
 */


#ifndef AGC_CLI_H_
#define AGC_CLI_H_

#define CLI_E_OK 0
#define CLI_E_UNKOWNTOKEN 1

typedef struct
{
  char* core;
  char* resume;
  char* cdu_log;
  char* symtab;
  char* directory;
  char* cd;
  char* cfg;
  char* fromfile;
  int   port;
  int   dump_time;
  int   debug_dsky;
  int   debug_deda;
  int   deda_quiet;
  int   inhibit_alarms;
  int   show_alarms;
  int   quiet;
  int   fullname;
  int   debug;
  int   interlace;
  int	resumed;
  int	version;
  int	initializeSunburst37;
  int	no_resume;
} Options_t;

extern Options_t* CliParseArguments(int argc, char *argv[]);

#endif /* AGC_CLI_H_ */
