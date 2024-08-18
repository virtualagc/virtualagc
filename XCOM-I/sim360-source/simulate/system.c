/*
**	System interface to the IBM/360 simulator for the
**	HAL/S Entended XPL compiler and load files generated by HAL/S.
**
**	This program requires 64-bit integer support
**
**	Author: Daniel Weaver
*/
/*
 * Modifications to Dan Weaver's code, mostly on Dan's advice:
 * 2024-05-27 RSB   Removed the "Sim360 normal exit" message.
 * 2024-08-14 RSB	Stubbed out `get_cpu_time`.
 * 2024-08-15 RSB	Changed `file_record_size` to `size_t`.
 */

#include <stdio.h>
#include <string.h>
#include <errno.h>
#include <time.h>
//#include <sys/resource.h>
#include <fcntl.h>
#include <signal.h>
#include <ctype.h>

#ifdef _MSC_VER
// For Windows with Virtual Studio
#include <stdlib.h>
// MSVC defines this in winsock2.h, but including that messes us up.
typedef struct timeval {
	long tv_sec;
	long tv_usec;
} timeval;
int gettimeofday(struct timeval * tp, struct timezone * tzp)
{
	struct timespec ts;
	timespec_get(&ts, TIME_UTC);
	tp->tv_sec = (long) ts.tv_sec;
	tp->tv_usec = ts.tv_nsec / 1000;
	return 0;
}
#else
// For everybody else.
#include <unistd.h>
#include <sys/time.h>
#endif

#ifndef _O_BINARY
#define _O_BINARY 0
#endif

#include "sim.h"

#define VERSION "0.0"

int header[16];			/* Object code header */

int cpu_timer;  /* Duration of Clock Trap in .01 seconds */
int clock_trap_start;  /* Time of day when Clock Trap was enabled */
int clock_trap_address;  /* Address of Clock Trap routine */
int clock_trap_pp;  /* Clock Trap Interrupt return address */
int last_clock_trap_time;  /* Previous reading of get_cpu_time() */
int clock_trap_delta[256];  /* Count the number of clock steps */

int watch_point, watch_point_option, watch_point_data, watch_point_break;
void check_watch_point(void);

/* Command line parsing and RC file definitions */
#define AT_FILES 4
FILE *at_file[AT_FILES + 1];
char at_text[512];
int _rc, avp, xargc;
char **xargv;
int input_record_limit;
size_t file_record_size;
char *opt_letters = { "FLTAEDN" };

/* Options and I/O variables */
FILE *input_unit[UNITS + 1], *output_unit[UNITS + 1], *file_unit[UNITS + 1];
char input_options[UNITS + 1], output_options[UNITS + 1],
    file_options[UNITS + 1];
char *obj_filename;
int record_length;		/* record size from --size option */
short input_eol[UNITS + 1];	/* Last end-of-line character */
char io_buffer[512];		/* Temporary Output buffer */
char *upper_case = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
char *lower_case = "abcdefghijklmnopqrstuvwxyz";
char lower[256];
char argtype[256];
char control[256];
char *parm_field;  /* From the --parm= option */
int target_zero, target_trans;
int enable_trace;
int debug_option;
int return_code, exit_code, call_usage, call_expanded_help;

#define MONLINK_ADDRESS 104
int xplmon_link[4];
int link_address;

unsigned char ebcdic[256] = {	/* ASCII to EBCDIC conversion table */
0x00, 0x01, 0x02, 0x03, 0x37, 0x2d, 0x2e, 0x2f, 0x16, 0x05, 0x25, 0x0b, 0x0c, 0x0d, 0x0e, 0x0f,
0x10, 0x11, 0x12, 0x13, 0x3c, 0x3d, 0x32, 0x26, 0x18, 0x19, 0x3f, 0x27, 0x1c, 0x1d, 0x1e, 0x1f,
0x40, 0x5a, 0x7f, 0x7b, 0x5b, 0x6c, 0x50, 0x7d, 0x4d, 0x5d, 0x5c, 0x4e, 0x6b, 0x60, 0x4b, 0x61,
0xf0, 0xf1, 0xf2, 0xf3, 0xf4, 0xf5, 0xf6, 0xf7, 0xf8, 0xf9, 0x7a, 0x5e, 0x4c, 0x7e, 0x6e, 0x6f,
0x7c, 0xc1, 0xc2, 0xc3, 0xc4, 0xc5, 0xc6, 0xc7, 0xc8, 0xc9, 0xd1, 0xd2, 0xd3, 0xd4, 0xd5, 0xd6,
0xd7, 0xd8, 0xd9, 0xe2, 0xe3, 0xe4, 0xe5, 0xe6, 0xe7, 0xe8, 0xe9, 0xba, 0xe0, 0xbb, 0xa1, 0x6d,
0x79, 0x81, 0x82, 0x83, 0x84, 0x85, 0x86, 0x87, 0x88, 0x89, 0x91, 0x92, 0x93, 0x94, 0x95, 0x96,
0x97, 0x98, 0x99, 0xa2, 0xa3, 0xa4, 0xa5, 0xa6, 0xa7, 0xa8, 0xa9, 0xc0, 0x4f, 0xd0, 0x5f, 0x07,
0x20, 0x21, 0x22, 0x23, 0x24, 0x15, 0x06, 0x17, 0x28, 0x29, 0x2a, 0x2b, 0x2c, 0x09, 0x0a, 0x1b,
0x30, 0x31, 0x1a, 0x33, 0x34, 0x35, 0x36, 0x08, 0x38, 0x39, 0x3a, 0x3b, 0x04, 0x14, 0x3e, 0xff,
0x41, 0xaa, 0x4a, 0xb1, 0x9f, 0xb2, 0x6a, 0xb5, 0xbd, 0xb4, 0x9a, 0x8a, 0xb0, 0xca, 0xaf, 0xbc,
0x90, 0x8f, 0xea, 0xfa, 0xbe, 0xa0, 0xb6, 0xb3, 0x9d, 0xda, 0x9b, 0x8b, 0xb7, 0xb8, 0xb9, 0xab,
0x64, 0x65, 0x62, 0x66, 0x63, 0x67, 0x9e, 0x68, 0x74, 0x71, 0x72, 0x73, 0x78, 0x75, 0x76, 0x77,
0xac, 0x69, 0xed, 0xee, 0xeb, 0xef, 0xec, 0xbf, 0x80, 0xfd, 0xfe, 0xfb, 0xfc, 0xad, 0xae, 0x59,
0x44, 0x45, 0x42, 0x46, 0x43, 0x47, 0x9c, 0x48, 0x54, 0x51, 0x52, 0x53, 0x58, 0x55, 0x56, 0x57,
0x8c, 0x49, 0xcd, 0xce, 0xcb, 0xcf, 0xcc, 0xe1, 0x70, 0xdd, 0xde, 0xdb, 0xdc, 0x8d, 0x8e, 0xdf
};

unsigned char ascii[256];	/* EBCDIC to ASCII conversion table */

/*
**	dump_conversion_table()
**
**	Dump the EBCDIC/ASCII conversion table.  The EBCDIC specification has
**	changed over time.  The table used by this simulator works well with
**	the EBCDIC code provided on the release tape from SUNY.  You may need
**	to change it if you wish to do code conversions on an ongoing basis.
**	This function is used for debugging only.
*/
void
dump_conversion_table(void)
{
	int i, j;
	short tab[256];

	for (i = 0; i < 256; i++) {
		tab[i] = -1;
	}
	for (i = 0; i < 256; i++) {
		if (tab[ebcdic[i]] >= 0) {
			printf("Duplicate ebcdic[%02x] and ebcdic[%02x]\n", tab[ebcdic[i]], ebcdic[i]);
		}
		tab[ebcdic[i]] = i;
	}
	for (i = 0; i < 256; i++) {
		if (tab[i] < 0) {
			printf("Unassigned ascii[%02x]\n", i);
		}
	}
	for (i = 0; i < 256; i += 16) {
		printf("%x_ ", i >> 4);
		for (j = 0; j < 16; j++) {
			if (ascii[i + j] >= 0x20 && ascii[i + j] < 127)
				printf("  %c", ascii[i + j]);
			else
				printf(" %02x", ascii[i + j]);
		}
		printf("\n");
	}
}

/*
**	get_ibm_time()
**
**	Return the current time in centiseconds since midnight
*/
int
get_ibm_time(void)
{
	struct tm *now;
	struct timeval tv;
	time_t sec;

	gettimeofday(&tv, (void *)0);
	sec = (time_t) tv.tv_sec;
	now = localtime(&sec);
	sec = ((now->tm_hour * 60) + now->tm_min) * 60 + now->tm_sec;

	return (tv.tv_usec / 10000) + sec * 100;	/* time */
}

/*
**	get_cpu_time()
**
**	Return the CPU usage in centiseconds
*/
int
get_cpu_time(void)
{
#if 1
	return 0;
#else
	struct rusage info;
	struct tm *now;
	time_t sec;

	getrusage(RUSAGE_SELF, &info);
	sec = (time_t) info.ru_utime.tv_sec;
	now = gmtime(&sec);
	sec = ((now->tm_hour * 60) + now->tm_min) * 60 + now->tm_sec;

	return (info.ru_utime.tv_usec / 10000) + sec * 100;	/* time */
#endif
}

/*
**  output_string(unit, desc)
**
**  Output a string to the selected device.
**  Does EBCDIC/ASCII conversion as requested.
**
**  reg[0] - descriptor
**  reg[2] - unit
**
**  returns EXIT_CONTINUE->success, EXIT_ABORT->error
*/
int
output_string(int unit, int desc)
{
	int x, c, j, k, dp, len, eflag;
	ssize_t wlen;

	if (desc == 0) {
		len = 0;
	} else {
		len = ((desc >> 24) & 0xff) + 1;
	}
	dp = desc & 0xffffff;
	if (unit == 1) {
		/* Simulate Line Printer forms control by ignoring it */
		dp++;
		len--;
		unit = 0;
	}
	if (unit < 0 || unit > UNITS) {
		fprintf(stderr, "output unit %d out of range\n", unit);
		return EXIT_ABORT;
	}
	if (!output_unit[unit]) {
		fprintf(stderr, "output unit %d is not open\n", unit);
		return EXIT_ABORT;
	}
	if ((output_options[unit] & OPT_TRANSLATE) == 0) {
		for (x = 0; x < len;) {
			io_buffer[x++] = core[dp++];
		}
		eflag = output_options[unit] & OPT_EBCDIC;
	} else if ((output_options[unit] & OPT_EBCDIC) != 0) {
		/* Translate EBCDIC to ASCII */
		for (x = j = 0; j < len; j++) {
			c = core[dp++] & 255;
			if (c == 0x4A) { /* Cent sign */
				io_buffer[x++] = 0xC2; /* UTF */
				io_buffer[x++] = 0xA2;
			} else
			if (c == 0x5F) { /* Logical Not */
				io_buffer[x++] = 0xC2; /* UTF */
				io_buffer[x++] = 0xAC;
			} else
				io_buffer[x++] = ascii[c];
			if (x >= sizeof(io_buffer) - 1) break;
		}
		eflag = 0;
	} else {
		/* Translate ASCII to EBCDIC */
		for (x = j = 0; j < len; j++) {
			c = core[dp++] & 255;
			k = core[dp] & 255;
			if (c == 0xC2 && k == 0xA2) { /* UTF Cent sign */
				io_buffer[x] = 0x4A;
				dp++;
				j++;
			} else
			if (c == 0xC2 && k == 0xAC) { /* UTF Logical Not */
				io_buffer[x] = 0x5F;
				dp++;
				j++;
			} else
				io_buffer[x] = ebcdic[c];
			x++;
		}
		eflag = OPT_EBCDIC;
	}
	if ((output_options[unit] & OPT_FILL) != 0) {
		/* Create an IBM compatable fixed length record without EOL characters */
		if (eflag) {
			for (; x < 80;) {
				io_buffer[x++] = 0x40;	/* EBCDIC space */
			}
		} else {
			for (; x < 80;) {
				io_buffer[x++] = 0x20;	/* ASCII space */
			}
		}
	} else
	if ((output_options[unit] & OPT_LIMIT) == 0) {
		if (eflag) {
			io_buffer[x++] = 0x25;	/* <linefeed> */
		} else {
			if ((output_options[unit] & OPT_CRLF) != 0) {
				/* Add carriage return */
				io_buffer[x++] = 0x0d;
			}
			io_buffer[x++] = 0x0a;	/* Linefeed */
		}
	}
	if (x != 0) {
		wlen = fwrite(io_buffer, 1, (size_t) x, output_unit[unit]);
		if (wlen != x) {
			fprintf(stderr, "output(%d) errno=%d\n", unit, errno);
			return EXIT_ABORT;
		}
		fflush(output_unit[unit]);	/* Added by dmw 190104 */
	}
	return EXIT_CONTINUE;
}

/*
**  input_string(unit)
**
**  Input a string from the selected device.
**  Does EBCDIC/ASCII conversion as requested.
**
**  reg[0] - freepoint
**  reg[2] - unit
**
**  returns EXIT_CONTINUE->success, EXIT_ABORT->error
**
**  reg[0] <- Descriptor
**  reg[1] <- New freepoint
*/
int
input_string(int unit)
{
	int x, nc, len, base, trans;
	int eflag;
	int c, chr, cr, lf, blank;

	if (unit < 0 || unit > UNITS) {
		fprintf(stderr, "input unit %d out of range\n", unit);
		return EXIT_ABORT;
	}
	if (!input_unit[unit]) {
		fprintf(stderr, "input unit %d is not open\n", unit);
		return EXIT_ABORT;
	}
	base = reg[0];
	if (base <= 0 || base >= CORESIZE) {
		fprintf(stderr, "freepoint out of range\n");
		return EXIT_ABORT;
	}
	eflag = input_options[unit] & OPT_EBCDIC;
	if (eflag) {
		cr = 0x0d;
		lf = 0x25;
		blank = 0x40;
		trans = 1;
	} else {
		cr = 0x0d;
		lf = 0x0a;
		blank = 0x20;
		trans = 2;
	}
	if ((input_options[unit] & OPT_TRANSLATE) == 0) {
		trans = 0;
	} else {
		eflag ^= OPT_EBCDIC;
		blank ^= 0x60;
	}
	nc = 0;
	if ((input_options[unit] & OPT_LIMIT) == 0) {
		for (len = c = 0; len < 256; nc++) {
			chr = fgetc(input_unit[unit]);
			if (chr == EOF) {
				if (len == 0) {
					reg[0] = 0;
					reg[1] = base;
					return EXIT_CONTINUE;
				}
				break;
			}
			if (chr == cr) {
				if (input_eol[unit] == lf) {
					input_eol[unit] = 0;
					continue;
				}
				input_eol[unit] = chr;
				break;
			}
			if (chr == lf) {
				if (input_eol[unit] == cr) {
					input_eol[unit] = 0;
					continue;
				}
				input_eol[unit] = chr;
				break;
			}
			input_eol[unit] = 0;
			switch (trans) {
			case 0:
				/* 0: No Translation */
				break;
			case 1:
				/* 1: Translate EBCDIC to ASCII */
				if (chr == 0x4A) { /* Cent sign */
					core[base + len++] = 0xC2; /* UTF-8 */
					chr = 0xA2;
				} else
				if (chr == 0x5F) { /* Logical Not */
					core[base + len++] = 0xC2; /* UTF-8 */
					chr = 0xAC;
				} else
					chr = ascii[chr];
				break;
			case 2:
				/* 2: Translate ASCII to EBCDIC */
				if (c == 0xC2 && chr == 0xA2) {
					/* UTF-8 Cent Sign */
					len--;
					nc--;
					c = chr = 0x4A;
				} else
				if (c == 0xC2 && chr == 0xAC) {
					/* UTF-8 Logical Not */
					len--;
					nc--;
					c = chr = 0x5F;
				} else
					chr = ebcdic[c = chr];
				break;
			default:
				break;
			}
			core[base + len] = chr;
			len++;
		}
	} else {
		for (len = c = 0; nc < 80; nc++) {
			chr = fgetc(input_unit[unit]);
			if (chr == EOF) {
				if (len == 0) {
					reg[0] = 0;
					reg[1] = base;
					return EXIT_CONTINUE;
				}
				break;
			}
			switch (trans) {
			case 0:
				/* 0: No Translation */
				core[base + len++] = chr;
				break;
			case 1:
				/* 1: Translate EBCDIC to ASCII */
				if (chr == 0x4A) { /* Cent sign */
					core[base + len++] = 0xC2; /* UTF-8 */
					chr = 0xA2;
				} else
				if (chr == 0x5F) { /* Logical Not */
					core[base + len++] = 0xC2; /* UTF-8 */
					chr = 0xAC;
				} else
					chr = ascii[chr];
				core[base + len++] = chr;
				break;
			case 2:
				/* 2: Translate ASCII to EBCDIC */
				if (c == 0xC2 && chr == 0xA2) {
					/* UTF-8 Cent Sign */
					core[base + len++] = 0x4A;
					c = 0;
				} else
				if (c == 0xC2 && chr == 0xAC) {
					/* UTF-8 Logical Not */
					core[base + len++] = 0x5F;
					c = 0;
				} else
				if (chr == 0xC2) {
					/* UTF-8 Start character */
					c = chr;
					nc--;
				} else {
					core[base + len++] = ebcdic[c = chr];
				}
				break;
			default:
				break;
			}
		}
	}
	/* Take care of zero length strings */
	if (len == 0) {
		core[base] = blank;
		nc = len = 1;
	}
	if ((input_options[unit] & OPT_FILL) != 0) {
		for (; nc < 80; nc++) {
			core[base + len++] = blank;
		}
	}
	if ((input_options[unit] & OPT_NOT) != 0) {
		if (eflag) {
			for (x = 0; x < len; x++) {
				chr = core[base + x];
				if (chr == 0x5f) core[base + x] = 0xa1;
				else
				if (chr == 0xa1) core[base + x] = 0x5f;
			}
		} else {
			for (x = 0; x < len; x++) {
				chr = core[base + x];
				if (chr == 0x5e) core[base + x] = 0x7e;
				else
				if (chr == 0x7e) core[base + x] = 0x5e;
			}
		}
	}
	check_watch_point();
	reg[1] = base + len;
	reg[0] = ((len - 1) << 24) + base;
	return EXIT_CONTINUE;
}

/*
**  file_pseudo_array()
**
**  Direct access Read/Write
**
**  reg[0] - Buffer address
**  reg[1] - Bits 31:3 -> Unit number, Bit 2 -> Direction
**  reg[2] - Record Index
**
**  returns EXIT_CONTINUE->success, EXIT_ABORT->error
*/
int
file_pseudo_array(void)
{
	int n, base;
	off_t byte_affset, val;
	ssize_t wc;

	base = reg[0];
	if ((base < 0) || (base + file_record_size) >= CORESIZE) {
		fprintf(stderr, "file buffer out of range: %08X\n", base);
		return EXIT_ABORT;
	}
	n = ((reg[1] - 44) >> 3);
	if ((n < 0) || (n > UNITS)) {
		fprintf(stderr, "file unit %d out of range\n", n);
		return EXIT_ABORT;
	}
	if (!file_unit[n]) {
		fprintf(stderr, "file unit %d is not open\n", n);
		return EXIT_ABORT;
	}
	byte_affset = reg[2] * file_record_size;
	val = lseek(fileno(file_unit[n]), byte_affset, SEEK_SET);
	if (val == -1) {
		fprintf(stderr, "File unit %d seek failed\n", n);
		return EXIT_ABORT;
	}
	/* Note: The direction bit is biased by 44.  Therefore 4->read, 0->write */
	if ((reg[1] & 4) == 4) {
		/* Read direction */
		wc = read(fileno(file_unit[n]), &core[base],
			  (size_t) file_record_size);
	} else {
		/* Write direction */
		wc = write(fileno(file_unit[n]), &core[base],
			   (size_t) file_record_size);
	}
	if (wc >= 0)
		return EXIT_CONTINUE;
	fprintf(stderr, "file(%d, %d) errno=%d\n", n, reg[2], errno);
	return EXIT_ABORT;
}

/*************************************************************************
GETC     EQU   4                   SEQUENTIAL INPUT
PUTC     EQU   8                   SEQUENTIAL OUTPUT
TRC      EQU   12                  INITIATE TRACING
UNTR     EQU   16                  TERMINATE TRACING
EXDMP    EQU   20                  FORCE A CORE DUMP
GTIME    EQU   24                  RETURN TIME AND DATE
RSVD1    EQU   28                  REWIND SEQUENTIAL FILES
RSVD2    EQU   32                  CLOCK_TRAP        (NOP IN XPLSM)
RSVD3    EQU   36                  INTERRUPT_TRAP    (NOP IN XPLSM)
RSVD4    EQU   40                  MONITOR           (NOP IN XPLSM)
RSVD5    EQU   44                  FILE READ starting point
RSVD6    EQU   48                  FILE WRITE starting point
*************************************************************************/
int
monitor_call(void)
{
	int base, cp;

	if (reg[1] < 0) {
		fprintf(stderr, "Illegal monitor call: %08X\n", reg[1]);
		return EXIT_ABORT;
	}
	if (reg[1] >= 44) {
		exit_code = file_pseudo_array();
		check_watch_point();
		pp = ADDRESS_MASK(reg[12]);
		return exit_code;
	}
	switch ((reg[1] >> 2)) {
	case 0:
		/* 0 */ ;
		break;
	case 1:
		/* 4 input */
		{
			exit_code = input_string(reg[2]);
			check_watch_point();
			pp = ADDRESS_MASK(reg[12]);
			return exit_code;
		}
		break;
	case 2:
		/* 8 output */
		{
			exit_code = output_string(reg[2], reg[0]);
			pp = ADDRESS_MASK(reg[12]);
			return exit_code;
		}
		break;
	case 3:
		/* 12 trace */
		{
			enable_trace = 1;
			pp = ADDRESS_MASK(reg[12]);
			return EXIT_CONTINUE;
		}
		break;
	case 4:
		/* 16 untrace */
		{
			enable_trace = 0;
			pp = ADDRESS_MASK(reg[12]);
			return EXIT_CONTINUE;
		}
		break;
	case 5:
		/* 20 exit */
		{
			fprintf(stderr, "XPL program abort\n");
			return EXIT_ABORT;
		}
		break;
	case 6:
		/* 24 date/time */
		{
			struct tm *now;
			struct timeval tv;
			time_t sec;

			gettimeofday(&tv, (void *)0);
			sec = (time_t) tv.tv_sec;
			now = localtime(&sec);
			sec =
			    ((now->tm_hour * 60) + now->tm_min) * 60 +
			    now->tm_sec;

			reg[0] = (tv.tv_usec / 10000) + sec * 100;	/* time */
			reg[1] = ((now->tm_yday + 1) + (1000 * now->tm_year));	/* date */
			pp = ADDRESS_MASK(reg[12]);
			return EXIT_CONTINUE;
		}
		break;
	case 7:
		/* 28 Rewind sequential files */
		{
			/* reg(0) = 1 if output */
			if (reg[2] < 0 || reg[2] > UNITS) {
				fprintf(stderr, "I/O unit %d out of range\n",
					reg[2]);
				return EXIT_ABORT;
			}
			if (reg[0] == 0) {
				if (input_unit[reg[2]]) {
					rewind(input_unit[reg[2]]);
				} else {
					fprintf(stderr, "Input unit %d not open\n",
						reg[2]);
					return EXIT_ABORT;
				}
			} else
			if (reg[0] == 1) {
				if (output_unit[reg[2]]) {
					rewind(output_unit[reg[2]]);
				} else {
					fprintf(stderr, "Output unit %d not open\n",
						reg[2]);
					return EXIT_ABORT;
				}
			}
			pp = ADDRESS_MASK(reg[12]);
			return EXIT_CONTINUE;
		}
		break;
	case 8:
		/* 32 Clock Trap */
		if (reg[0] == 0) {
			/* Start the timer */
			base = ADDRESS_MASK(reg[2]);
			if (base >= CORESIZE) {
				printf("Error at %06X: Address out of range\n",
					pp);
				return EXIT_ABORT;
			}
			cpu_timer = load_word(base);
			mem_address = load_word(base + 4) & 0x00fffffe;
			if (mem_address >= fetch_limit) {
				printf("Error at %06X: Clock Trap address out of range: %06X\n",
					pp, mem_address);
				return EXIT_ABORT;
			}
			clock_trap_address = mem_address;
			clock_trap_start = get_cpu_time();
		} else
		if (reg[0] < 0) {
			clock_trap_address = 0;
			clock_trap_start = 0;
		}
		reg[0] = get_cpu_time() - clock_trap_start;
		pp = ADDRESS_MASK(reg[12]);
		return EXIT_CONTINUE;
	case 9:
		/* 36 INTERRUPT_TRAP */
		pp = ADDRESS_MASK(reg[12]);
		return EXIT_CONTINUE;
	case 10:
		/* 40 reserved */
		{
			fprintf(stderr, "Monitor call: %d, %08X\n", reg[1],
				reg[0]);
			/* Dump 256 bytes.  This is non-standard. */
			base = reg[0];
			if ((base < 0) || (base >= CORESIZE))
				return EXIT_CONTINUE;
			for (cp = 0; cp <= 255; cp++) {
				printf(" %02X", core[base]);
				base = base + 1;
				if ((cp & 15) == 15)
					printf("\n");
			}
			pp = ADDRESS_MASK(reg[12]);
			return EXIT_CONTINUE;
		}
		break;
	case 11:
		/* 44 file read */ ;
		break;
	case 12:
		/* 48 file write */ ;
		break;
	default:
		break;
	}
	fprintf(stderr, "Unimplemented monitor call: %d\n", reg[1]);
	return EXIT_ABORT;
}

/*
**  abort_simulation
**
**  This function will catch the Interrupt signal.
*/
void
abort_simulation(int sig) 
{
	return_code = EXIT_BREAK;
}

/*
**	set_compiler_options()
**
**	Write the compiler control toggles to the object module.
**
**	The compiler puts a zero character at offset 32 to tell the
**	simulator it's preference for ASCII vs EBCDIC.
*/
void
set_compiler_options(void)
{
	int i, a, b;
	char *p;

	a = 32;
	b = core[a];
	if (b == 0) {
		/* Set default character encoding */
		b = '0';  /* Match native system */
	}
	target_zero = b;
	zone = b & 0xF0;
	if (b == '0') target_trans = 0;
	else
	if (b == 0x30) target_trans = 1;
	else target_trans = 2;
	if (parm_field) {
		for (p = parm_field; *p; p++) {
			if (*p == '$') {
				control[((int)p[1]) & 255] = 1;
			}
		}
	}
	for (i = 0; i <= 255; i++) {
		if (control[i]) {
			if (islower(i)) continue;
			switch (target_trans) {
			case 0:
				core[a++] = i;
				break;
			case 1:
				core[a++] = ascii[i];
				break;
			case 2:
				core[a++] = ebcdic[i];
				break;
			}
			if (a >= 59) {
				/* The program starts at 60. */
				break;
			}
		}
	}
	core[a] = 0;
}

/*
**	start_simulation()
**
**	This routine loads the XPL startup environment and handles
**	MONITOR_LINK().  MONITOR_LINK() is passed from one module to the next.
**
**	Return the program exit code.
*/
int
start_simulation(void)
{
	int v, i, j, obj, len;

	decimal_init();
	for (i = 0; i <= 255; i++) {
		opcode_count[i] = 0;
		clock_trap_delta[i] = 0;
	}
	modpoint = return_code = 0;
	link_address = watch_point = CORESIZE;
	obj = open(obj_filename, O_RDONLY | _O_BINARY, 0);
	if (obj < 0) {
		fprintf(stderr, "open failed: %s\n", obj_filename);
		return_code = 1;
		return EXIT_QUIET;
	}
	len = read(obj, &core[load_point], 80);
	pp = ADDRESS_MASK(load_point);
	for (v = 0; v <= 6; v++) {
		header[v] = load_word(pp);
		pp += 4;
		if (control['v']) {
			printf(" %2d: %08X", v, header[v]);
			if ((v & 3) == 3) printf("\n");
		}
	}
	if (control['v']) printf("\n");
	codesize = header[0] - header[4] + header[5];
	fetch_limit =
	    header[0] + header[1] - header[4] + header[6] + load_point;
	j = header[0] + header[1] + load_point;
	if ((unsigned int) j >= CORESIZE) {
		fprintf(stderr, "Program too large: %d.  Max size is: %d\n",
			j, CORESIZE);
		return_code = 1;
		return EXIT_QUIET;
	}
	if (control['v']) printf("Image size: %06X\n", j - load_point);
	file_record_size = 4096;
	for (v = load_point + 80; v <= j; v += 4096) {
		len = read(obj, &core[v], file_record_size);
		if (len == 0) {
			fprintf(stderr, "read() failed: %s\n", obj_filename);
			fprintf(stderr, "Load point: %06X,  Read address: %06X\n",
				load_point, v);
			close(obj);
			return_code = 1;
			return EXIT_QUIET;
		}
	}
	close(obj);
	if (record_length > 0) {
		file_record_size = record_length;
	} else {
		file_record_size = header[4];
	}
	if (control['v']) {
		printf("codesize=%08X, fetch_limit=%08X\n", codesize,
		       fetch_limit);
		printf("FILE() record length set to: %d\n", (int) file_record_size);
	}
	/* Set lowest modifiable address */
	if (control['m'] == 0) {
		modpoint = load_point + codesize;
		if (control['v']) {
			printf("Read Only memory upper bound %08X\n", modpoint);
		}
	}

	/* Initialize the MONITOR_LINK */
	v = link_address = load_point + header[0] + MONLINK_ADDRESS;
	for (j = 0; j <= 3; j++) {
		store_word(xplmon_link[j], v);
		v = v + 4;
	}
	set_compiler_options();

	/* Set registers used by the simulator */
	pp = load_point + 60;
	reg[0] = 0;
	reg[1] = CORESIZE;
	reg[2] = load_point;
	reg[3] = load_point + header[0];
	reg[12] = returnlink;	/* Monitor return address */
	reg[15] = callback;	/* Monitor callback address */
	clock_trap_start = 0;
	if (debug_option) {
		signal(SIGINT, abort_simulation);
		return_code = debugger();
	} else {
		exit_code = simulator(0);
	}
	if (pp == returnlink) {
		//printf("Sim360 normal exit\n");
		return_code = reg[3];
	} else {
		return_code = 1;
	}
	/* Save the MONITOR_LINK */
	v = link_address;
	for (j = 0; j <= 3; j++) {
		xplmon_link[j] = load_word(v);
		v = v + 4;
	}
	if (return_code == 0 && xplmon_link[3] != 0) {
		return_code = xplmon_link[3];
	}
	return exit_code;
}

/*
**	char_found(string, character)
**
**	Search the string for the specified character.
**	Return TRUE if found.
*/
char
char_found(char *s, int v)
{
	int i;

	for (i = 0; s[i]; i++) {
		if (s[i] == v) return 1;
	}
	return 0;
}

int
numeric_option(char *opt)
{
	int ch, j, n;

	for (j = n = 0; (ch = opt[j]); j++) {
		if (ch >= '0' && ch <= '9') {
			n = n * 10 + ch - '0';
		} else {
			fprintf(stderr, "Invalid numeric value\n");
			call_usage = 1;
			return 0;
		}
	}
	return n;
}

int
hex_convert(char *opt)
{
	int ch, j, n;

	for (j = n = 0; (ch = opt[j]); j++) {
		if (ch >= '0' && ch <= '9') {
			n = (n << 4) + ch - '0';
		} else
		if (ch >= 'a' && ch <= 'f') {
			n = (n << 4) + ch - 'a' + 10;
		} else
		if (ch >= 'A' && ch <= 'F') {
			n = (n << 4) + ch - 'A' + 10;
		} else {
			fprintf(stderr, "Invalid numeric value\n");
			call_usage = 1;
			return 0;
		}
	}
	return n;
}

void
usage(char *name)
{
    fprintf(stderr, "Usage:\n");
    fprintf(stderr, "   %s [-cmv] [-[iof]number[flags][mode] filename] [@file] object-module\n",
		name);
    fprintf(stderr, "       -[iof]number[flags][mode] filename - Open filename for unit\n");
    fprintf(stderr, "           iof - i->input, o->output, f->file\n");
    fprintf(stderr, "           number - the XPL I/O unit\n");
    fprintf(stderr, "           flags - one or more of the following flags\n");
    fprintf(stderr, "                   A - (-i) Input file is ASCII on external media (default)\n");
    fprintf(stderr, "                   E - (-i) Input file is EBCDIC on external media\n");
    fprintf(stderr, "                   A - (-o) Data from program is ASCII (default)\n");
    fprintf(stderr, "                   E - (-o) Data from program is EBCDIC\n");
    fprintf(stderr, "                   T - Translate ASCII to EBCDIC or EBCDIC to ACSII\n");
    fprintf(stderr, "                   F - Fill with blanks to 80 characters\n");
    fprintf(stderr, "                   L - Limit input/output to 80 characters\n");
    fprintf(stderr, "                   D - (-o) DOS mode.  Use both CR and LF.  Not required on input\n");
    fprintf(stderr, "                   N - (-i) Swap caret(^) and tilde(~)\n");
    fprintf(stderr, "           mode - fopen mode (one or more of \"rwa+b\")\n");
    fprintf(stderr, "           filename - file (may also be stdin, stderr or stdout)\n");
    fprintf(stderr, "       --help - Expanded help display\n");
    fprintf(stderr, "       --parm=text - Program parameters\n");
    fprintf(stderr, "       --size=bytes - file() record size in bytes (default loaded from object module)\n");
    fprintf(stderr, "       --debug - Enter the interactive debug monitor\n");
    fprintf(stderr, "       --trace - Enable instruction trace\n");
    fprintf(stderr, "       --watch=HHHHHHHH - Set data watch point (default is disabled)\n");
    fprintf(stderr, "       --version - Print version information and exit\n");
    fprintf(stderr, "       -c - Display Op-code instruction execution counts\n");
    fprintf(stderr, "       -m - Allow the code to be modified\n");
    fprintf(stderr, "       -v - Verbose\n");
    fprintf(stderr, "       @rc-file - Continue processing by reading options from the rc-file\n");
    fprintf(stderr, "       object-module - IBM/360 object file from the HAL Extended XPL compiler\n");
    fprintf(stderr, "           Multiple object-modules may be used\n");
    fprintf(stderr, "   Uppercase letters are passed to the compilers as control toggles\n");
    fprintf(stderr, "   All single letter options are cleared after an object-module is executed\n");
}

void
expanded_help(void)
{
    fprintf(stderr, "\n");
    fprintf(stderr, "I/O unit numbers for IBM/360 XPL programs are unique for\n");
    fprintf(stderr, "INPUT, OUTPUT and FILE.  INPUT(3) and OUTPUT(3) may reference\n");
    fprintf(stderr, "completely different files.  %d units are supported for XPL programs\n", UNITS);
    fprintf(stderr, "Here are some I/O definition examples:\n");
    fprintf(stderr, "   -i0 stdin          This sets INPUT(0) to stdin\n");
    fprintf(stderr, "   -o0 file.listing   This sends OUTPUT(0) to a file named \"file.listing\"\n");
    fprintf(stderr, "   -i0ETFr ebcdic.file INPUT(0) will read text from \"ebcdic.file\" and translate it to ACSII\n");
    fprintf(stderr, "        E The input file is EBCDIC\n");
    fprintf(stderr, "        T Convert the input records to ASCII\n");
    fprintf(stderr, "        F Fill the input record with ASCII space to 80 characters.  Many of the\n");
    fprintf(stderr, "          old IBM/360 programs do not work well with variable length records\n");
    fprintf(stderr, "        r Open the file for reading\n");
    fprintf(stderr, "   -i2ELr ebcdic.file  INPUT(2) will read text from \"ebcdic.file\" without translation\n");
    fprintf(stderr, "        L Limits the input to 80 characters.  This should be used\n");
    fprintf(stderr, "          with EBCDIC files that are not terminated with <newline>\n");
    fprintf(stderr, "        r Open the file for reading\n");
    fprintf(stderr, "   -o0ET stdout       The EBCDIC text from OUTPUT(0) will be converted\n");
    fprintf(stderr, "                      to ASCII and written to stdout\n");
    fprintf(stderr, "   -f2w+ data.tmp     FILE(2) can read/write the file \"data.tmp\"\n");
    fprintf(stderr, "When making an I/O definition the lowercase letters and special characters are passed\n");
    fprintf(stderr, "to the fopen() call as part of the mode specification.  Be careful what you ask for.\n");
    fprintf(stderr, "The FILE() pseudo variable does not support any of the character translation options.\n");
    fprintf(stderr, "\n");
    fprintf(stderr, "@rc-file may contain any number of options and use multiple lines.\n");
    fprintf(stderr, "Text after a # is considered a comment.\n");
    fprintf(stderr, "\n");
    fprintf(stderr, "Multiple object modules may be used on one command line.  Place options and I/O\n");
    fprintf(stderr, "assignments immediately before each object module.  The MONITOR_LINK() area will\n");
    fprintf(stderr, "be passed to the next module.  All files are closed after a module executes.\n");
    fprintf(stderr, "\n");
    fprintf(stderr, "Other options:\n");
    fprintf(stderr, "   --size=bytes sets the record size for the FILE() pseudo variable.\n");
    fprintf(stderr, "      The default record size is taken from the header of the object module.\n");
    fprintf(stderr, "      The compiler sets this size to 7200 bytes.\n");
}

int
open_file(char *opt, char *name)
{
	char mode[32];
	int i, j, n, ch, iotab, flags, mop;
	FILE *f;

	iotab = flags = n = mop = 0;
	for (i = 1; (ch = opt[i]); i++) {
		if (ch >= '0' && ch <= '9') {
			n = n * 10 + ch - '0';
		} else if (lower[ch] == ch) {
			if (ch == 'i')
				iotab = iotab | 1;
			else if (ch == 'o')
				iotab = iotab | 2;
			else if (ch == 'f')
				iotab = iotab | 4;
			else if (mop < sizeof(mode) - 1)
				mode[mop++] = ch;
		} else {
			for (j = 0; opt_letters[j]; j++) {
				if (opt_letters[j] == 0) {
					call_usage = 1;
					break;
				} else if (ch == opt_letters[j]) {
					flags |= 1 << j;
					break;
				}
			}
		}
	}
	mode[mop] = '\0';
	if (n > UNITS) {
		fprintf(stderr, "Unit %d must be less than %d\n", n, UNITS + 1);
		return 1;
	}
	if (iotab == 0 && mop > 0) {
		/* Deduce the I/O type from the mode */
		if (char_found(mode, '+')) iotab = 4;
		else if (char_found(mode, 'r'))
			iotab = 1;
		else if (char_found(mode, 'w'))
			iotab = 2;
	}
	if (iotab == 0) {
		iotab = 1;	/* Default is input() */
	}
	if ((iotab & 1) != 0) {
		if (input_unit[n] == stdin) {
			input_unit[n] = (FILE *) 0;
		}
		if (input_unit[n]) {
			fprintf(stderr, "Input unit %d already open\n", n);
			return 1;
		}
		if (mop == 0) {
			mode[mop++] = 'r';
			mode[mop] = '\0';
		}
	}
	if ((iotab & 2) != 0) {
		if (n == 1) {
			/* Unit 1 is converted to Unit 0 in the output routine */
			fprintf(stderr, "Use -o0 to define output unit 1\n");
			return 1;
		}
		if (output_unit[n] == stdout || output_unit[n] == stderr) {
			output_unit[n] = (FILE *) 0;
		}
		if (output_unit[n]) {
			fprintf(stderr, "Output unit %d already open\n", n);
			return 1;
		}
		if (mop == 0) {
			mode[mop++] = 'w';
			mode[mop] = '\0';
		}
	}
	if ((iotab & 4) != 0) {
		if (file_unit[n]) {
			fprintf(stderr, "File unit %d already open\n", n);
			return 1;
		}
		if (mop == 0) {
			mode[mop++] = 'r';
			mode[mop++] = '+';
			mode[mop] = '\0';
		}
	}
	if (strcmp(name, "stdin") == 0) f = stdin;
	else if (strcmp(name, "stdout") == 0) f = stdout;
	else if (strcmp(name, "stderr") == 0) f = stderr;
	else {
		f = fopen(name, mode);
		if (!f) {
			fprintf(stderr, "fopen(%s, %s) failed\n", name, mode);
			return 1;
		}
	}
	if ((iotab & 4) != 0) {
		file_unit[n] = f;
		file_options[n] = flags;
	}
	if ((iotab & 1) != 0) {
		input_unit[n] = f;
		input_options[n] = flags;
	}
	if ((iotab & 2) != 0) {
		/* When the output is a tty CR-LF is used on output lines */
		if (isatty(fileno(f))) flags |= OPT_CRLF;
		output_unit[n] = f;
		output_options[n] = flags;
	}
	return 0;
}

void
close_all(void)
{
	int i;

	for (i = 0; i <= UNITS; i++) {
		if (file_unit[i]) {
			fclose(file_unit[i]);
		}
		file_unit[i] = (FILE *) 0;
		if (input_unit[i]) {
			if (input_unit[i] != stdin) {
				fclose(input_unit[i]);
				input_unit[i] = (FILE *) 0;
				input_eol[i] = -1;
			}
		}
		if (output_unit[i]) {
			/* Do not close stdout or stderr */
			if (output_unit[i] != stdout && output_unit[i] != stderr) {
				fclose(output_unit[i]);
				output_unit[i] = (FILE *) 0;
			}
		}
	}
}

char *
next_op(char *buf, int len)
{
	int cp, chr, comment;

    get_next_op:
	cp = comment = 0;
	if (_rc >= 0) {
		while (1) {
			chr = getc(at_file[_rc]);
			if (chr == EOF) {
				_rc = _rc - 1;
				if (cp) break;
				goto get_next_op;
			}
			if (chr == '\n' || chr == '\r') {
				if (cp) break;
				comment = 0;
				continue;
			}
			if (chr == '#' && cp == 0) {
				comment = 1;
				continue;
			}
			if (comment) continue;
			if (chr == ' ' || chr == '\t') {
				if (cp) break;
				continue;
			}
			if (cp >= len - 1) {
				comment = 1;
				fprintf(stderr, "Option too long\n");
				continue;
			}
			buf[cp++] = chr;
		}
		buf[cp] = '\0';
		return buf;
	}
	avp = avp + 1;
	if (avp < xargc) {
		return xargv[avp];
	}
	return (char *)0;
}

int
process_options(void)
{
	int v, i, j, ch;
	char *optext, *opt;
	char *io_option = "iof0123456789";
	char *single_letter_options = "cmv";

	watch_point_option = CORESIZE;
	load_point = 0;
	for (v = 0; v <= 255; v++) {
		lower[v] = v;
		argtype[v] = 0;
		ascii[ebcdic[v]] = v;
		if (isupper(v)) argtype[v] = 2;
		else argtype[v] = 0;
	}
	argtype['|'] = 2;
	for (v = strlen(lower_case) - 1; v >= 0; v--) {
		lower[upper_case[v] & 255] = lower_case[v];
	}
	for (v = strlen(io_option) - 1; v >= 0; v--) {
		argtype[io_option[v] & 255] = 1;
	}
	for (v = strlen(single_letter_options) - 1; v >= 0; v--) {
		argtype[single_letter_options[v] & 255] = 2;
	}
	for (v = 0; v <= UNITS; v++) {
		input_unit[v] = output_unit[v] = file_unit[v] = (FILE *) 0;
		input_eol[v] = -1;
	}
	call_usage = 0;
	avp = 0;
	_rc = -1;
	optext = next_op(at_text, sizeof(at_text));
	debug_init();
	while (optext) {
		ch = optext[1];
		if (optext[0] == '@') {
			if (_rc >= AT_FILES) {
				fprintf(stderr, "More than %d nested @files\n",
					AT_FILES + 1);
				return 1;
			}
			optext++;
			if (optext[0] == '\0') {
				fprintf(stderr,
					"Missing filename for: @file\n");
				return 1;
			}
			at_file[_rc + 1] = fopen(optext, "r");
			if (!at_file[_rc + 1]) {
				fprintf(stderr, "fopen(%s, \"r\") failed\n",
					optext);
				return 1;
			}
			_rc = _rc + 1;
		} else if (optext[0] != '-') {
			if (!input_unit[0])
				input_unit[0] = stdin;
			if (!output_unit[0])
				output_unit[0] = stdout;
			obj_filename = optext;
			if (control['v']) {
				printf("Running: %s\n", obj_filename);
			}
			exit_code = start_simulation();
			close_all();
			if (exit_code == EXIT_ABORT) {
				dump_history();
			}
			if (control['c']) {
				printf("Instruction count: %d\n",
					instruction_count);
				for (i = 0; i <= 255; i++) {
					if (opcode_count[i] > 0) {
						printf("%-4.4s %d\n",
						&opcode_name[i >> 4][(i & 15)
						<< 2], opcode_count[i]);
					}
				}
			}
			if (control['v']) {
				for (i = 0; i < 256; i++) {
					if (clock_trap_delta[i]) {
						printf("Clock delta %3d -> %d\n",
							i, clock_trap_delta[i]);
					}
				}
			}
			if (return_code != 0) return return_code;
			for (i = 0; i < 256; i++) {
				control[i] = 0;
			}
			watch_point_option = CORESIZE;
			enable_trace = 0;
			clock_trap_address = 0;  /* Disable Clock Trap */
			cpu_timer = 60 * 6000;	/* One hour */
		} else if (argtype[ch] == 1) {
			j = strlen(optext) + 1;
			opt = next_op(&at_text[j], sizeof(at_text) - j);
			if (!opt) {
				fprintf(stderr, "Missing filename for: %s\n",
					optext);
				call_usage = 1;
				return 1;
			}
			if (opt[0] == '-') {
				fprintf(stderr, "Missing filename for: %s\n",
					optext);
				call_usage = 1;
				return 1;
			}
			if (open_file(optext, opt)) {
				return 1;
			}
		} else if (strcmp(optext, "--help") == 0) {
			call_usage = 1;
			call_expanded_help = 1;
			return 1;
		} else if (strncmp(optext, "--parm=", 7) == 0) {
			parm_field = &optext[7];
		} else if (strncmp(optext, "--size=", 7) == 0) {
			record_length = numeric_option(&optext[7]);
			if (record_length < 32) {
				fprintf(stderr, "Record length too small\n");
				return 1;
			}
		} else if (strncmp(optext, "--trace", 7) == 0) {
			enable_trace = 1;
		} else if (strncmp(optext, "--debug", 7) == 0) {
			debug_option = 1;
		} else if (strncmp(optext, "--watch=", 8) == 0) {
			watch_point_option = hex_convert(&optext[8]);
		} else if (strcmp(optext, "--version") == 0) {
			fprintf(stderr,
				"IBM/360 simulator for HAL/S Extended XPL.  Rev: %s\n",
				VERSION);
			return 0;
		} else if (argtype[ch] == 2) {
			for (j = 1; optext[j]; j++) {
				control[optext[j] & 255] = 1;
			}
		} else {
			fprintf(stderr, "Illegal option: %s\n", optext);
			return 1;
		}
		if (call_usage != 0) {
			return 1;
		}
		optext = next_op(at_text, sizeof(at_text));
	}
	if (!obj_filename) {
		fprintf(stderr, "Missing object filename\n");
		call_usage = 1;
		return 1;
	}
	return 0;
}

int
main(int argc, char **argv)
{
	xargc = argc;
	xargv = argv;
	return_code = process_options();
	if (call_usage != 0) {
		usage(argv[0]);
	}
	if (call_expanded_help != 0) {
		expanded_help();
	}
	close_all();

	return return_code;
}
