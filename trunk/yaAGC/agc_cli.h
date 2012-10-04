/*
 * agc_cli.h
 *
 *  Created on: Nov 30, 2008
 *      Author: MZ211D
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
  int   quiet;
  int   fullname;
  int   debug;
  int   interlace;
  int	resumed;
  int	version;
} Options_t;

extern Options_t* CliParseArguments(int argc, char *argv[]);

#endif /* AGC_CLI_H_ */
