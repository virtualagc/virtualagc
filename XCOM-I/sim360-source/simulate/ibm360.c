/*
**	XPL monitor and simulator for the IBM/360
**
**	This program requires 64-bit integer support
**
**	Author: Daniel Weaver
*/

#include <stdio.h>
#include <string.h>
#include <errno.h>
#include <time.h>
#include <sys/types.h>
#include <sys/uio.h>
#include <sys/time.h>
#include <sys/resource.h>
#include <unistd.h>
#include <fcntl.h>
#include <ctype.h>

#include "sim.h"

#define VERSION "1.1"

unsigned char core[CORESIZE + 256];	/* memory storage area */

/* Machine state */
int reg[16];			/* General purpose registers */
int save[16];			/* Clock Trap registers save area */
int cc;				/* Condition codes */
int zone;			/* Decimal arithmetic Zone field 0x30 or 0xF0 */
int pp, codesize, fetch_limit, modpoint, load_point;
unsigned int f[16];		/* Floating point registers */

/* Condition codes */
char *cc_name[4] = { "EQ", "LT", "GT", "OV" };

/* Instruction decode variables */
int OP, OP1, OP2, OP3, OP4, OP5;
int R1, R2, R3, B1, B2, X1, X2, L1, L2;
int D1, D2, L, I2;
int mem_address;

/* 32 bit unsigned right shift */
#define SHR(v, b) (((unsigned int)v) >> (b))

/* Op codes */
#define EX 0x44

/* Temporary variables */
XPL_LONG xx, xy;
XPL_FLOAT fx, fy, fz;

int header[16];			/* Object code header */
int msbit = 0x80000000;
int callback = 0x00fffff0;
int trapreturn = 0x00fffff4;
int returnlink = 0x00fffff8;
int jumptable = 0x00ffff00;

int cpu_timer;  /* Duration of Clock Trap in .01 seconds */
int clock_trap_start;  /* Time of day when Clock Trap was enabled */
int clock_trap_address;  /* Address of Clock Trap routine */
int clock_trap_pp;  /* Clock Trap Interrupt return address */
int last_clock_trap_time;  /* Previous reading of get_cpu_time() */
int clock_trap_delta[256];  /* Count the number of clock steps */

int watch_point, watch_point_option, watch_point_data;
void check_watch_point(void);

char *opcode_name[16] = {
	"                SPM BALRBCTRBCR SSK ISK SVC                     ",
	"LPR LNR LTR LCR NR  CLR OR  XR  LR  CR  AR  SR  MR  DR  ALR SLR ",
	"LPDRLNDRLTDRLCDRHDR             LDR CDR ADR SDR MDR DDR AWR SWR ",
	"LPERLNERLTERLCERHER             LER CER AER SER MER DER AUR SUR ",
	"STH LA  STC IC  EX  BAL BCT BC  LH  CH  AH  SH  MH      CVD CVB ",
	"ST              N   CL  O   X   L   C   A   S   M   D   AL  SL  ",
	"STD                             LD  CD  AD  SD  MD  DD  AW  SW  ",
	"STE                             LE  CE  AE  SE  ME  DE  AU  SU  ",
	"SSM     LPSW    WRD RDD BXH BXLESRL SLL SRA SLA SRDLSLDLSRDASLDA",
	"STM TM  MVI TS  NI  CLI OI  XI  LM              SIO TIO HIO TCH ",
	"                                                                ",
	"                                                                ",
	"                                                                ",
	"    MVN MVC MVZ NC  CLC OC  XC                  TR  TRT ED  EDMK",
	"                                                                ",
	"    MVO PACKUNPK                ZAP CP  AP  SP  MP  DP          "
};

#define __ 0
#define RR 1			/* 2 Register to register transfers. */
#define RS 2			/* 4 Register to storage and register from storage */
#define RX 3			/* 4 Register to/from indexed storage */
#define SI 4			/* 4 Storage immediate */
#define SS 5			/* 6 Storage to Storage */

char *mode[6] = { "__", "RR", "RS", "RX", "SI", "SS" };

int opcode_count[256];
int instruction_count;
#define HISTORY_MASK 15
int history[HISTORY_MASK + 1];
int hop[HISTORY_MASK + 1];
int ea[HISTORY_MASK + 1];
int da[HISTORY_MASK + 1];
int hip;

char opcode_type[256] = {
    /*0**/ __, __, __, RR, RR, RR, RR, RR, RR, RR, RR, RR, RR, RR, RR, RR,
    /*1**/ RR, RR, RR, RR, RR, RR, RR, RR, RR, RR, RR, RR, RR, RR, RR, RR,
    /*2**/ RR, RR, RR, RR, RR, RR, RR, RR, RR, RR, RR, RR, RR, RR, RR, RR,
    /*3**/ RR, RR, RR, RR, RR, RR, RR, RR, RR, RR, RR, RR, RR, RR, RR, RR,
    /*4**/ RX, RX, RX, RX, RX, RX, RX, RX, RX, RX, RX, RX, RX, RX, RX, RX,
    /*5**/ RX, RX, __, __, RX, RX, RX, RX, RX, RX, RX, RX, RX, RX, RX, RX,
    /*6**/ RX, __, __, __, __, __, __, RX, RX, RX, RX, RX, RX, RX, RX, RX,
    /*7**/ RX, RX, __, __, __, __, __, __, RX, RX, RX, RX, RX, RX, RX, RX,
    /*8**/ SI, __, SI, RX, RX, RX, RS, RS, RS, RS, RS, RS, RS, RS, RS, RS,
    /*9**/ RS, SI, SI, SI, SI, SI, SI, SI, RS, RS, RS, RS, SI, SI, SI, SI,
    /*A**/ __, __, __, __, __, __, __, __, RS, RS, __, __, SI, SI, RS, SI,
    /*B**/ __, RX, __, __, __, __, __, RS, RS, __, __, __, __, __, __, __,
    /*C**/ __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __,
    /*D**/ __, SS, SS, SS, SS, SS, SS, SS, __, SS, SS, SS, SS, SS, SS, SS,
    /*E**/ __, __, __, __, __, __, __, __, SS, SS, SS, __, __, __, __, __,
    /*F**/ SS, SS, SS, SS, __, __, __, __, SS, SS, SS, SS, SS, SS, __, __}
    /*     *0  *1  *2  *3  *4  *5  *6  *7  *8  *9  *A  *B  *C  *D  *E  *F */;

char *reg_names[16] = { "R0", "R1", "R2", "R3", "R4", "R5",
	"R6", "R7", "R8", "R9", "R10", "R11", "R12", "R13", "R14", "R15"
};

/* Command line parsing and RC file definitions */
#define AT_FILES 4
FILE *at_file[AT_FILES + 1];
char at_text[512];
int _rc, avp, xargc;
char **xargv;
int input_record_limit, file_record_size;
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
int enable_trace;
int return_code, exit_code, call_usage, call_expanded_help;

/* MONITOR_LINK is shared between compiler passes of the PASCAL compiler.
** MONITOR_LINK(0) --time=SSS Time in seconds (default 10)
** MONITOR_LINK(1) --lines=LLLL Number of lines (default 1000)
** MONITOR_LINK(2) --debug=D Debug level (default 2)
** MONITOR_LINK(3) Error count (default 0)
*/
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
unsigned char code_header[8] = "%CODE";
unsigned char org_header[8] = "%ORG ";
unsigned char *transmap;

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
**	decode(x)
**
**	Disassemble one op code.  The data for the opcode is taken from
**	the history log.
**
**	The results are printed on stdout.
*/
void
decode(int x)
{
	short a, b, c, d, e, f;
	short r1, r2, r3, x2, b1, b2, d1, d2;
	char op[8], text[64];
	char opstring[128];
	int ip;

	ip = history[x];
	a = core[ip];
	b = core[ip + 1] | hop[x];
	opstring[0] = '\0';
	strncpy(op, &opcode_name[(a >> 4)][((a & 15) << 2)], 4);
	op[4] = '\0';
	switch (opcode_type[a]) {
	case 0:
		/* Case 0: __ Unknown */
		{
			sprintf(opstring, "Illegal opcode: %02X\n", a);
		}
		break;
	case 1:
		/* Case 1: RR Register to register */
		{
			r1 = (b >> 4);
			r2 = b & 15;
			sprintf(text, "%s %d,%d", op, r1, r2);
			sprintf(opstring, "%-20s R%d=%08X R%d=%08X", text,
				r1, ea[x], r2, da[x]);
		}
		break;
	case 2:
		/* Case 2: RS Register to/from storage */
		{
			c = core[ip + 2];
			d = core[ip + 3];
			r1 = (b >> 4);
			r3 = b & 15;
			b2 = (c >> 4);
			d2 = ((c & 15) << 8) + d;
			sprintf(text, "%s %d,%d,%d(%d)", op, r1, r3, d2, b2);
			sprintf(opstring, "%-20s EA=%08X", text, ea[x]);
		}
		break;
	case 3:
		/* Case 3: RX Register to/from indexed storage */
		{
			c = core[ip + 2];
			d = core[ip + 3];
			r1 = (b >> 4);
			x2 = b & 15;
			b2 = (c >> 4);
			d2 = ((c & 15) << 8) + d;
			sprintf(text, "%s %d,%d(%d,%d)", op, r1, d2, x2, b2);
			sprintf(opstring, "%-20s EA=%08X", text, ea[x]);
		}
		break;
	case 4:
		/* Case 4: SI Storage immediate */
		{
			c = core[ip + 2];
			d = core[ip + 3];
			b1 = (c >> 4);
			d1 = ((c & 15) << 8) + d;
			sprintf(text, "%s %d(%d),%d", op, d1, b1, b);
			sprintf(opstring, "%-20s EA=%08X", text, da[x]);
		}
		break;
	case 5:
		/* Case 5: SS Storage-to-Storage */
		{
			c = core[ip + 2];
			d = core[ip + 3];
			e = core[ip + 4];
			f = core[ip + 5];
			b1 = (c >> 4);
			d1 = ((c & 15) << 8) + d;
			b2 = (e >> 4);
			d2 = ((e & 15) << 8) + f;
			sprintf(text, "%s %d(%d,%d),%d(%d)", op,
				d1, b, b1, d2, b2);
			sprintf(opstring, "%-20s DA=%08X SA=%08X", text, da[x],
				ea[x]);
		}
		break;
	default:
		break;
	}
	printf("%06X %s\n", ip, opstring);
}

/*
**	dump_state()
**
**	Dump the registers, prpogram point and condition codes.
*/
void
dump_state(void)
{
	int i;

	for (i = 0; i <= 15; i++) {
		printf("%3s=%08X ", reg_names[i], reg[i]);
		if ((i % 6) == 5)
			printf("\n");
	}
	printf(" PP=%08X  CC=%d %s\n", pp, cc, cc_name[cc]);
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
	struct rusage info;
	struct tm *now;
	time_t sec;

	getrusage(RUSAGE_SELF, &info);
	sec = (time_t) info.ru_utime.tv_sec;
	now = gmtime(&sec);
	sec = ((now->tm_hour * 60) + now->tm_min) * 60 + now->tm_sec;

	return (info.ru_utime.tv_usec / 10000) + sec * 100;	/* time */
}

/*
**	check_watch_point()
**
**	Display a message if the watch point data changes.
*/
void
check_watch_point(void)
{
	int v;

	if (watch_point < CORESIZE) {
		v = load_word(watch_point);
		if (v != watch_point_data) {
			printf("WatchPoint at %08X is now %08X, pp=%06X\n",
			       watch_point, v, pp);
		}
		watch_point_data = v;
	}
}

short
load_halfword(int dp)
{
	int v;

	v = (core[dp] << 8) + core[dp + 1];
	return v | (-(v & 0x8000));	/* Sign extend */
}

int
load_word(int dp)
{
	return (core[dp] << 24) + (core[dp + 1] << 16)
	    + (core[dp + 2] << 8) + core[dp + 3];
}

XPL_LONG
load_double(int dp)
{
	XPL_LONG v = 0;
	int i;

	for (i = 0; i < 8; i++) {
		v = (v << 8) + core[dp++];
	}
	return v;
}

void
store_halfword(int value, int dp)
{
	core[dp] = (value >> 8);
	core[dp + 1] = value;
	check_watch_point();
}

void
store_word(int value, int dp)
{
	core[dp] = (value >> 24);
	core[dp + 1] = (value >> 16);
	core[dp + 2] = (value >> 8);
	core[dp + 3] = value;
	check_watch_point();
}

void
store_double(XPL_LONG value, int dp)
{
	int i;

	dp += 7;
	for (i = 0; i < 8; i++) {
		core[dp--] = (unsigned char)value;
		value >>= 8;
	}
	check_watch_point();
}

/*
**	dump_string(descriptor)
**
**	Print a string in Hex.
*/
void
dump_string(int desc)
{
	int i, len, dp;

	printf("descriptor=%08X\n", desc);
	if (desc == 0) {
		len = 0;
	} else {
		len = (desc >> 24) + 1;
	}
	dp = desc & 0xffffff;
	for (i = 0; i < len; i++) {
		if (((i & 31) == 0) && (i > 0)) {
			printf("\n");
		}
		printf("%02X", core[dp]);
		dp++;
	}
	printf("\n");
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
	int x, dp, len, eflag;
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
		for (x = 0; x < len;) {
			io_buffer[x++] = ascii[core[dp++] & 255];
		}
		eflag = 0;
	} else {
		/* Translate ASCII to EBCDIC */
		for (x = 0; x < len;) {
			io_buffer[x++] = ebcdic[core[dp++] & 255];
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
	int x, len, base;
	int eflag;
	int chr, cr, lf, blank;

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
	} else {
		cr = 0x0d;
		lf = 0x0a;
		blank = 0x20;
	}
	if ((input_options[unit] & OPT_LIMIT) == 0) {
		for (len = 0; len < 256;) {
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
			core[base + len] = chr;
			len++;
		}
	} else {
		for (len = 0; len < 80;) {
			chr = fgetc(input_unit[unit]);
			if (chr == EOF) {
				if (len == 0) {
					reg[0] = 0;
					reg[1] = base;
					return EXIT_CONTINUE;
				}
				break;
			}
			core[base + len] = chr;
			len++;
		}
	}
	/* Take care of zero length strings */
	if (len == 0) {
		core[base] = blank;
		len = 1;
	}
	if ((input_options[unit] & OPT_FILL) != 0) {
		for (; len < 80; len++) {
			core[base + len] = blank;
		}
	}
	if ((input_options[unit] & OPT_TRANSLATE) != 0) {
		if (eflag) {
			for (x = 0; x < len; x++) {
				core[base + x] = ascii[core[base + x]];
			}
		} else {
			for (x = 0; x < len; x++) {
				core[base + x] = ebcdic[core[base + x]];
			}
		}
		eflag ^= OPT_EBCDIC;
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
**	runtime_support()
**
**	Dispatch runtime support calls.
**	Return exit_code
*/
int
runtime_support(void)
{
	int i;

	mem_address &= 0x00ffffff;
	if (mem_address < CORESIZE) {
		pp = mem_address;
		return EXIT_CONTINUE;
	}
	if (mem_address == returnlink) {
		/* Return from the simulator */
		pp = returnlink;
		return EXIT_DONE;
	}
	/* Check for XPL Monitor call */
	if (mem_address == callback) {
		return monitor_call();
	}
	/* Check for Clock Trap return */
	if (mem_address == trapreturn) {
		for (i = 0; i < 16; i++) {
			reg[i] = save[i];
		}
		pp = clock_trap_pp;
		return EXIT_CONTINUE;
	}
	/* Check for Pascal runtime call */
	if ((mem_address & jumptable) == jumptable) {
		return pascal_runtime(mem_address);
	}
	return -1;
}

#define CHECK_ADDRESS_HIGH(a) if (a >= CORESIZE) return address_error(a)

/*
**	address_error(address)
**
**	Print a message when the address is too high.
**	Storage-to-starage instructions should use CHECK_ADDRESS_HIGH(D2).
*/
int
address_error(int a)
{
	fprintf(stderr,
		"Error at %06X: Address range error: %08X is greater than %08X\n",
		history[hip], a, CORESIZE);
	return EXIT_ABORT;
}

#define CHECK_MEM_ADDRESS() \
	if ((mem_address <= modpoint) || (mem_address >= CORESIZE)) break

#define CHECK_ADDRESS_ALIGNMENT() if ((mem_address & 7) != 0) return alignment_error()

/*
**	alignment_error()
**
**	Print a message if the address is double word aligned.
*/
int
alignment_error(void)
{
	fprintf(stderr, "Error at %06X: Address alignment error: %08X\n",
		history[hip], mem_address);
	return EXIT_ABORT;
}

#define CHECK_FLOAT_REG(rg) if ((rg & 1) != 0) return odd_register(rg)

/*
**	odd_register()
**
**	Print a message if the floating point register is odd.
*/
int
odd_register(int rg)
{
	fprintf(stderr, "Error at %06X: Register must be even: %d\n",
		history[hip], rg);
	return EXIT_ABORT;
}

/*
**	divide_by_zero()
**
**	Print a message for divide by zero.
*/
int
divide_by_zero(void)
{
	fprintf(stderr, "Error at %06X: Divide by zero\n", history[hip]);
	return EXIT_ABORT;
}

/*
**	exec_time_exceeded()
**
**	Print a message for Execution time exceeded.
*/
int
exec_time_exceeded(void)
{
	/* This gets called when you write a zero to MONITOR_LINK(0) */
	fprintf(stderr, "Abort at %06X: Execution time exceeded\n", pp);
	return EXIT_ABORT;
}

void
set_add_cc(int a, int b, int c)
{
	/* Set the condition codes: a + b = c */

	if (c == 0)
		cc = CC_EQ;
	if (c < 0)
		cc = CC_LT;
	if (c > 0)
		cc = CC_GT;
	if ((((a >> 31) == (b >> 31)) & ((a ^ c) >> 31)) == 1)
		cc = CC_OV;
}

void
set_add_carry(int a, int b, int c)
{
	/* Set the condition codes: a + b = c for Add Logical */
	int v;

	if (((a >> 31) == (b >> 31))
	    & ((a >> 31) == (c >> 31)))
		v = c;
	else
		v = ~c;
	if ((v & msbit) == 0) {
		/* no carry */
		if (c == 0)
			cc = CC0;
		else
			cc = CC1;
	} else {
		/* carry */
		if (c == 0)
			cc = CC2;
		else
			cc = CC3;
	}
}

void
set_subtract_carry(int a, int b, int c)
{
	/* Set the condition codes: a - b = c for Subtract Logical */
	int v;

	if (((a >> 31) == (~b >> 31))
	    & ((a >> 31) == (c >> 31)))
		v = c;
	else
		v = ~c;
	if ((v & msbit) == 0) {
		/* no carry */
		cc = CC1;
	} else {
		/* carry */
		if (c == 0)
			cc = CC2;
		else
			cc = CC3;
	}
}

/*
**	set_short_cc(register_number)
**
**	Set the condition codes from the selected 32 bit floating point register.
*/
void
set_short_cc(int rg)
{
	if (f[rg] & msbit) {
		cc = CC_LT;
	} else {
		cc = CC_GT;
	}
	if ((f[rg] & 0x00ffffff) == 0) {
		cc = CC_EQ;
	}
}

/*
**	set_long_cc(register_number)
**
**	Set the condition codes from the selected 64 bit floating point register.
*/
void
set_long_cc(int rg)
{
	if (f[rg] & msbit) {
		cc = CC_LT;
	} else {
		cc = CC_GT;
	}
	if (((f[rg] & 0x00ffffff) == 0) && (f[rg + 1] == 0)) {
		cc = CC_EQ;
	}
}

/*
**	simulator()
**
**	Fetch the opcode and execute it.
**	This function does all the work.
*/
int
simulator(void)
{
	int k, v, mask;
	int rollback, npp;

	watch_point = ADDRESS_MASK(watch_point_option);
	if (watch_point < CORESIZE) {
		/* Force the Watch Point to trigger */
		watch_point_data = load_word(watch_point) + 1;
		check_watch_point();
	}
	rollback = 0;
 fetch_next:
	instruction_count = instruction_count + 1;
	if ((instruction_count & 0x3ffff) == 0) {
		if (clock_trap_address != 0) {
			v = get_cpu_time();
			k = v - last_clock_trap_time;
			last_clock_trap_time = v;
			if (k >= 0 && k < 256) {
				/* This is a measure of how fast your CPU is. */
				clock_trap_delta[k]++;
			}
			if (v - clock_trap_start > cpu_timer) {
				if (clock_trap_address == returnlink) {
					/* Timeout Abort */
					printf("Execution timeout\n");
					return EXIT_ABORT;
				}
				clock_trap_pp = pp;
				for (k = 0; k < 16; k++) {
					save[k] = reg[k];
				}
				reg[3] = pp;
				reg[12] = trapreturn;
				pp = clock_trap_address;
				/* Disable the Clock Trap */
				clock_trap_address = 0;
			}
		}
	}
	if ((unsigned int) pp >= (unsigned int) fetch_limit) {
		fprintf(stderr,
			"Error at %06X: Op-code fetch out of range: %08X\n",
			history[hip], pp);
		return EXIT_ABORT;
	}
	hip = (hip + 1) & HISTORY_MASK;
	history[hip] = pp;
	hop[hip] = 0;
	npp = pp;
	OP = core[npp++];
	OP1 = core[npp++];
 fetch_operands:
	opcode_count[OP] = opcode_count[OP] + 1;
	switch (opcode_type[OP]) {
	case 0:
		/* Case 0: __ Unknown */
		{
			fprintf(stderr, "Error at %06X: Illegal op code: %02X\n",
				pp, OP);
			return EXIT_ABORT;
		}
		break;
	case 1:
		/* Case 1: RR Register to register */
		{
			R1 = (OP1 >> 4) & 15;
			R2 = OP1 & 15;
			ea[hip] = reg[R1];
			da[hip] = reg[R2];
		}
		break;
	case 2:
		/* Case 2: RS Register to/from storage */
		{
			OP2 = core[npp++];
			OP3 = core[npp++];

			R1 = (OP1 >> 4) & 15;
			R3 = OP1 & 15;
			B2 = (OP2 >> 4) & 15;
			mem_address = D2 = ((OP2 & 15) << 8) + OP3;

			if (B2 != 0)
				mem_address = mem_address + reg[B2];
			ea[hip] = mem_address = mem_address & 0xFFFFFF;
		}
		break;
	case 3:
		/* Case 3: RX Register to/from indexed storage */
		{
			OP2 = core[npp++];
			OP3 = core[npp++];

			R1 = (OP1 >> 4) & 15;
			X1 = OP1 & 15;
			B2 = (OP2 >> 4) & 15;
			mem_address = D2 = ((OP2 & 15) << 8) + OP3;

			if (X1 != 0)
				mem_address = mem_address + reg[X1];
			if (B2 != 0)
				mem_address = mem_address + reg[B2];
			ea[hip] = mem_address = mem_address & 0xFFFFFF;
		}
		break;
	case 4:
		/* Case 4: SI Storage immediate */
		{
			OP2 = core[npp++];
			OP3 = core[npp++];

			I2 = OP1;
			B1 = (OP2 >> 4) & 15;
			mem_address = D1 = ((OP2 & 15) << 8) + OP3;
			if (B1 != 0)
				mem_address = mem_address + reg[B1];
			da[hip] = mem_address = mem_address & 0xFFFFFF;
		}
		break;
	case 5:
		/* Case 5: SS Storage-to-Storage */
		{
			OP2 = core[npp++];
			OP3 = core[npp++];
			OP4 = core[npp++];
			OP5 = core[npp++];

			L1 = (OP1 >> 4) & 15;
			L2 = OP1 & 15;
			B1 = (OP2 >> 4) & 15;
			D1 = ((OP2 & 15) << 8) + OP3;
			B2 = (OP4 >> 4) & 15;
			D2 = ((OP4 & 15) << 8) + OP5;
			if (B1 != 0)
				D1 = (D1 + reg[B1]) & 0xFFFFFF;
			if (B2 != 0)
				D2 = (D2 + reg[B2]) & 0xFFFFFF;
			mem_address = D1;
			da[hip] = D1;
			ea[hip] = D2;
		}
		break;
	default:
		break;
	}
	if (enable_trace) {
		dump_state();
		decode(hip);
	}
	pp = npp;
	if (rollback != 0) {
		/* This is used by the EX instruction to fix the pp */
		pp = rollback;
		rollback = 0;
	}
	switch (OP) {
	case 0:
		/* 00 */ ;
		illegal_opcode:

		fprintf(stderr, "Error at %06X: Unimplemented op code: %02X\n",
			history[hip], OP);
		return EXIT_ABORT;
	case 1:
		/* 01 */ ;
		goto illegal_opcode;
	case 2:
		/* 02 */ ;
		goto illegal_opcode;
	case 3:
		/* 03 */ ;
		goto illegal_opcode;
	case 4:
		/* 04 SPM  RR */
		{
		}
		goto illegal_opcode;
	case 5:
		/* 05 BALR RR */
		{
			v = (cc << 28) | 0x4f000000 | pp;
			if (R2 == 0) {
				reg[R1] = v;
				goto fetch_next;
			}
			/* R1 and R2 might be equal */
			mem_address = reg[R2];
			reg[R1] = v;
			exit_code = runtime_support();
			if (exit_code == EXIT_CONTINUE)
				goto fetch_next;
			if (exit_code > EXIT_CONTINUE)
				return exit_code;
			/* Else address error */
		}
		break;
	case 6:
		/* 06 BCTR RR */
		{
			reg[R1] = reg[R1] - 1;
			if (R2 == 0)
				goto fetch_next;
			if (reg[R1] == 0)
				goto fetch_next;
			mem_address = reg[R2];
			exit_code = runtime_support();
			if (exit_code == EXIT_CONTINUE)
				goto fetch_next;
			if (exit_code > EXIT_CONTINUE)
				return exit_code;
			/* Else address error */
		}
		break;
	case 7:
		/* 07 BCR  RR */
		{
			if (R1 == 0 || R2 == 0) {
				goto fetch_next;
			}
			if (((8 >> cc) & R1) == 0)
				goto fetch_next;
			mem_address = reg[R2];
			exit_code = runtime_support();
			if (exit_code == EXIT_CONTINUE)
				goto fetch_next;
			if (exit_code > EXIT_CONTINUE)
				return exit_code;
			/* Else address error */
		}
		break;
	case 8:
		/* 08 SSK  RR */
		{
		}
		goto illegal_opcode;
	case 9:
		/* 09 ISK  RR */
		{
		}
		goto illegal_opcode;
	case 10:
		/* 0a SVC  __ */
		{
		}
		goto illegal_opcode;
	case 11:
		/* 0b */ ;
		goto illegal_opcode;
	case 12:
		/* 0c */ ;
		goto illegal_opcode;
	case 13:
		/* 0d */ ;
		goto illegal_opcode;
	case 14:
		/* 0e */ ;
		goto illegal_opcode;
	case 15:
		/* 0f */ ;
		goto illegal_opcode;
	case 16:
		/* 10 LPR  RR */
		{
			if (reg[R2] >= 0) v = reg[R2];
			else v = -reg[R2];
			reg[R1] = v;
			if (v == 0) cc = CC_EQ;
			else if (v > 0) cc = CC_GT;
			else cc = CC_OV;
			goto fetch_next;
		}
		break;
	case 17:
		/* 11 LNR  RR */
		{
			if (reg[R2] >= 0) v = -reg[R2];
			else v = reg[R2];
			reg[R1] = v;
			if (v == 0) cc = CC_EQ;
			else cc = CC_LT;
			goto fetch_next;
		}
		break;
	case 18:
		/* 12 LTR  RR */
		{
			v = reg[R1] = reg[R2];
			if (v == 0) cc = CC_EQ;
			else if (v < 0) cc = CC_LT;
			else cc = CC_GT;
			goto fetch_next;
		}
		break;
	case 19:
		/* 13 LCR  RR */
		{
			v = reg[R1] = -reg[R2];
			if (v == 0) cc = CC_EQ;
			else if (v == msbit) cc = CC_OV;
			else if (v < 0) cc = CC_LT;
			else cc = CC_GT;
			goto fetch_next;
		}
		break;
	case 20:
		/* 14 NR   RR */
		{
			v = reg[R1] = reg[R1] & reg[R2];
			if (v == 0) cc = CC0;
			else cc = CC1;
			goto fetch_next;
		}
		break;
	case 21:
		/* 15 CLR  RR */
		{
			/* Unsigned compare */
			D1 = reg[R1] + msbit;
			D2 = reg[R2] + msbit;
			if (D1 == D2) cc = CC_EQ;
			else if (D1 < D2) cc = CC_LT;
			else cc = CC_GT;
			goto fetch_next;
		}
		break;
	case 22:
		/* 16 OR   RR */
		{
			v = reg[R1] = reg[R1] | reg[R2];
			if (v == 0) cc = CC0;
			else cc = CC1;
			goto fetch_next;
		}
		break;
	case 23:
		/* 17 XR   RR */
		{
			v = reg[R1] = reg[R1] ^ reg[R2];
			if (v == 0) cc = CC0;
			else cc = CC1;
			goto fetch_next;
		}
		break;
	case 24:
		/* 18 LR   RR */
		{
			reg[R1] = reg[R2];
			goto fetch_next;
		}
		break;
	case 25:
		/* 19 CR   RR */
		{
			v = reg[R2];
			if (reg[R1] == v) cc = CC_EQ;
			else if (reg[R1] < v) cc = CC_LT;
			else cc = CC_GT;
			goto fetch_next;
		}
		break;
	case 26:
		/* 1a AR   RR */
		{
			v = reg[R1] + reg[R2];
			set_add_cc(reg[R1], reg[R2], v);
			reg[R1] = v;
			goto fetch_next;
		}
		break;
	case 27:
		/* 1b SR   RR */
		{
			v = reg[R1] - reg[R2];
			set_add_cc(reg[R1], ~reg[R2], v);
			reg[R1] = v;
			goto fetch_next;
		}
		break;
	case 28:
		/* 1c MR   RR */
		{
			xx = reg[R1 | 1];
			xy = reg[R2];
			xx = xx * xy;
			reg[R1] = (xx >> 32);
			reg[R1 | 1] = xx;
			goto fetch_next;
		}
		break;
	case 29:
		/* 1d DR   RR */
		{
			xx = reg[R1];
			xy = reg[R1 + 1];
			xx = (xx << 32) + (xy & 0x00000000FFFFFFFF);
			xy = reg[R2];
			reg[R1] = xx % xy;
			reg[R1 + 1] = xx / xy;
			goto fetch_next;
		}
		break;
	case 30:
		/* 1e ALR  RR */
		{
			v = reg[R1] + reg[R2];
			set_add_carry(reg[R1], reg[R2], v);
			reg[R1] = v;
			goto fetch_next;
		}
		break;
	case 31:
		/* 1f SLR  RR */
		{
			v = reg[R1] - reg[R2];
			set_subtract_carry(reg[R1], reg[R2], v);
			reg[R1] = v;
			goto fetch_next;
		}
		break;
	case 32:
		/* 20 LPDR RR */
		{
			CHECK_FLOAT_REG(R1);
			CHECK_FLOAT_REG(R2);
			f[R1] = f[R2] & 0x7fffffff;
			f[R1 + 1] = f[R2 + 1];
			set_long_cc(R1);
			goto fetch_next;
		}
		break;
	case 33:
		/* 21 LNDR RR */
		{
			CHECK_FLOAT_REG(R1);
			CHECK_FLOAT_REG(R2);
			f[R1] = f[R2] | msbit;
			f[R1 + 1] = f[R2 + 1];
			set_long_cc(R1);
			goto fetch_next;
		}
		break;
	case 34:
		/* 22 LTDR RR */
		{
			CHECK_FLOAT_REG(R1);
			CHECK_FLOAT_REG(R2);
			f[R1] = f[R2];
			f[R1 + 1] = f[R2 + 1];
			set_long_cc(R1);
			goto fetch_next;
		}
		break;
	case 35:
		/* 23 LCDR RR */
		{
			CHECK_FLOAT_REG(R1);
			CHECK_FLOAT_REG(R2);
			f[R1] = f[R2] ^ msbit;
			f[R1 + 1] = f[R2 + 1];
			set_long_cc(R1);
			goto fetch_next;
		}
		break;
	case 36:
		/* 24 HDR  RR */
		{
			CHECK_FLOAT_REG(R1);
			CHECK_FLOAT_REG(R2);
			split_register(&fx, R2);
			fx.fraction >>= 1;
			join_register(&fx, R1);
			goto fetch_next;
		}
		break;
	case 37:
		/* 25 */ ;
		goto illegal_opcode;
	case 38:
		/* 26 */ ;
		goto illegal_opcode;
	case 39:
		/* 27 */ ;
		goto illegal_opcode;
	case 40:
		/* 28 LDR  RR */
		{
			CHECK_FLOAT_REG(R1);
			CHECK_FLOAT_REG(R2);
			f[R1] = f[R2];
			f[R1 + 1] = f[R2 + 1];
			goto fetch_next;
		}
		break;
	case 41:
		/* 29 CDR  RR */
		{
			CHECK_FLOAT_REG(R1);
			CHECK_FLOAT_REG(R2);
			split_register(&fx, R1);
			split_register(&fy, R2);
			compare_float(&fx, &fy);
			goto fetch_next;
		}
		break;
	case 42:
		/* 2a ADR  RR */
		{
			CHECK_FLOAT_REG(R1);
			CHECK_FLOAT_REG(R2);
			split_register(&fx, R1);
			split_register(&fy, R2);
			add_normalized(&fx, &fy, &fz);
			join_register(&fz, R1);
			goto fetch_next;
		}
		break;
	case 43:
		/* 2b SDR  RR */
		{
			CHECK_FLOAT_REG(R1);
			CHECK_FLOAT_REG(R2);
			split_register(&fx, R1);
			split_register(&fy, R2);
			fy.sign ^= 1;
			add_normalized(&fx, &fy, &fz);
			join_register(&fz, R1);
			goto fetch_next;
		}
		break;
	case 44:
		/* 2c MDR  RR */
		{
			CHECK_FLOAT_REG(R1);
			CHECK_FLOAT_REG(R2);
			split_register(&fx, R1);
			split_register(&fy, R2);
			multiply_float(&fx, &fy, &fz);
			join_register(&fz, R1);
			goto fetch_next;
		}
		break;
	case 45:
		/* 2d DDR  RR */
		{
			CHECK_FLOAT_REG(R1);
			CHECK_FLOAT_REG(R2);
			split_register(&fx, R1);
			split_register(&fy, R2);
			exit_code = divide_float(&fx, &fy, &fz);
			if (exit_code == EXIT_CONTINUE) {
				join_register(&fz, R1);
				goto fetch_next;
			}
			return divide_by_zero();
		}
		break;
	case 46:
		/* 2e AWR  RR */
		{
			CHECK_FLOAT_REG(R1);
			CHECK_FLOAT_REG(R2);
			split_register(&fx, R1);
			split_register(&fy, R2);
			add_unnormalized(&fx, &fy, &fz);
			join_register(&fz, R1);
			goto fetch_next;
		}
		break;
	case 47:
		/* 2f SWR  RR */
		{
			CHECK_FLOAT_REG(R1);
			CHECK_FLOAT_REG(R2);
			split_register(&fx, R1);
			split_register(&fy, R2);
			fy.sign ^= 1;
			add_unnormalized(&fx, &fy, &fz);
			join_register(&fz, R1);
			goto fetch_next;
		}
		break;
	case 48:
		/* 30 LPER RR */
		{
			CHECK_FLOAT_REG(R1);
			CHECK_FLOAT_REG(R2);
			f[R1] = f[R2] & 0x7fffffff;
			set_short_cc(R1);
			goto fetch_next;
		}
		break;
	case 49:
		/* 31 LNER RR */
		{
			CHECK_FLOAT_REG(R1);
			CHECK_FLOAT_REG(R2);
			f[R1] = f[R2] | msbit;
			set_short_cc(R1);
			goto fetch_next;
		}
		break;
	case 50:
		/* 32 LTER RR */
		{
			CHECK_FLOAT_REG(R1);
			CHECK_FLOAT_REG(R2);
			f[R1] = f[R2];
			set_short_cc(R1);
			goto fetch_next;
		}
		break;
	case 51:
		/* 33 LCER RR */
		{
			CHECK_FLOAT_REG(R1);
			CHECK_FLOAT_REG(R2);
			f[R1] = f[R2] ^ msbit;
			set_short_cc(R1);
			goto fetch_next;
		}
		break;
	case 52:
		/* 34 HER  RR */
		{
			CHECK_FLOAT_REG(R1);
			CHECK_FLOAT_REG(R2);
			split_short(&fx, f[R2]);
			fx.fraction >>= 1;
			f[R1] = join_short(&fx);
			goto fetch_next;
		}
		break;
	case 53:
		/* 35 */ ;
		goto illegal_opcode;
	case 54:
		/* 36 */ ;
		goto illegal_opcode;
	case 55:
		/* 37 */ ;
		goto illegal_opcode;
	case 56:
		/* 38 LER  RR */
		{
			CHECK_FLOAT_REG(R1);
			CHECK_FLOAT_REG(R2);
			f[R1] = f[R2];
			goto fetch_next;
		}
		break;
	case 57:
		/* 39 CER  RR */
		{
			CHECK_FLOAT_REG(R1);
			CHECK_FLOAT_REG(R2);
			split_short(&fx, f[R1]);
			split_short(&fy, f[R2]);
			compare_float(&fx, &fy);
			goto fetch_next;
		}
		break;
	case 58:
		/* 3a AER  RR */
		{
			CHECK_FLOAT_REG(R1);
			CHECK_FLOAT_REG(R2);
			split_short(&fx, f[R1]);
			split_short(&fy, f[R2]);
			add_normalized(&fx, &fy, &fz);
			f[R1] = join_short(&fz);
			goto fetch_next;
		}
		break;
	case 59:
		/* 3b SER  RR */
		{
			CHECK_FLOAT_REG(R1);
			CHECK_FLOAT_REG(R2);
			split_short(&fx, f[R1]);
			split_short(&fy, f[R2]);
			fy.sign ^= 1;
			add_normalized(&fx, &fy, &fz);
			f[R1] = join_short(&fz);
			goto fetch_next;
		}
		break;
	case 60:
		/* 3c MER  RR */
		{
			/* The short multiply returns a long result */
			CHECK_FLOAT_REG(R1);
			CHECK_FLOAT_REG(R2);
			split_short(&fx, f[R1]);
			split_short(&fy, f[R2]);
			multiply_float(&fx, &fy, &fz);
			join_register(&fz, R1);
			goto fetch_next;
		}
		break;
	case 61:
		/* 3d DER  RR */
		{
			CHECK_FLOAT_REG(R1);
			CHECK_FLOAT_REG(R2);
			split_short(&fx, f[R1]);
			split_short(&fy, f[R2]);
			exit_code = divide_float(&fx, &fy, &fz);
			if (exit_code == EXIT_CONTINUE) {
				f[R1] = join_short(&fz);
				goto fetch_next;
			}
			return divide_by_zero();
		}
		break;
	case 62:
		/* 3e AUR  RR */
		{
			CHECK_FLOAT_REG(R1);
			CHECK_FLOAT_REG(R2);
			split_short(&fx, f[R1]);
			split_short(&fy, f[R2]);
			add_unnormalized(&fx, &fy, &fz);
			f[R1] = join_short(&fz);
			goto fetch_next;
		}
		break;
	case 63:
		/* 3f SUR  RR */
		{
			CHECK_FLOAT_REG(R1);
			CHECK_FLOAT_REG(R2);
			split_short(&fx, f[R1]);
			split_short(&fy, f[R2]);
			fy.sign ^= 1;
			add_unnormalized(&fx, &fy, &fz);
			f[R1] = join_short(&fz);
			goto fetch_next;
		}
		break;
	case 64:
		/* 40 STH  RX */
		{
			if ((mem_address > modpoint) && (mem_address < CORESIZE)) {
				store_halfword(reg[R1], mem_address);
				goto fetch_next;
			}
		}
		break;
	case 65:
		/* 41 LA   RX */
		{
			reg[R1] = mem_address;
			goto fetch_next;
		}
		break;
	case 66:
		/* 42 STC  RX */
		{
			if ((mem_address > modpoint) && (mem_address < CORESIZE)) {
				core[mem_address] = reg[R1];
				check_watch_point();
				goto fetch_next;
			}
		}
		break;
	case 67:
		/* 43 IC   RX */
		{
			if (mem_address < CORESIZE) {
				v = core[mem_address];
				reg[R1] = (reg[R1] & 0xffffff00) | v;
				goto fetch_next;
			}
		}
		break;
	case 68:
		/* 44 EX   RX */
		{
			if (mem_address < CORESIZE) {
				rollback = pp;
				npp = pp = ADDRESS_MASK(mem_address);
				hip = (hip + 1) & HISTORY_MASK;
				history[hip] = pp;
				OP = core[npp++];
				OP1 = core[npp++];
				if (R1 == 0) {
					hop[hip] = 0;
				} else {
					hop[hip] = reg[R1] & 255;
					OP1 = OP1 | hop[hip];
				}
				goto fetch_operands;
			}
		}
		break;
	case 69:
		/* 45 BAL  RX */
		{
			v = (cc << 28) | 0x8f000000 | pp;
			reg[R1] = v;
			exit_code = runtime_support();
			if (exit_code == EXIT_CONTINUE)
				goto fetch_next;
			if (exit_code > EXIT_CONTINUE)
				return exit_code;
			/* Else address error */
		}
		break;
	case 70:
		/* 46 BCT  RX */
		{
			reg[R1] = reg[R1] - 1;
			if (reg[R1] == 0)
				goto fetch_next;
			mem_address = reg[R2];
			exit_code = runtime_support();
			if (exit_code == EXIT_CONTINUE)
				goto fetch_next;
			if (exit_code > EXIT_CONTINUE)
				return exit_code;
			/* Else address error */
		}
		break;
	case 71:
		/* 47 BC   RX */
		{
			if (((8 >> cc) & R1) == 0)
				goto fetch_next;
			exit_code = runtime_support();
			if (exit_code == EXIT_CONTINUE)
				goto fetch_next;
			if (exit_code > EXIT_CONTINUE)
				return exit_code;
			/* Else address error */
		}
		break;
	case 72:
		/* 48 LH   RX */
		{
			if (mem_address < CORESIZE) {
				reg[R1] = load_halfword(mem_address);
				goto fetch_next;
			}
		}
		break;
	case 73:
		/* 49 CH   RX */
		{
			if (mem_address < CORESIZE) {
				v = load_halfword(mem_address);
				if (reg[R1] == v) cc = CC_EQ;
				else if (reg[R1] < v) cc = CC_LT;
				else cc = CC_GT;
				goto fetch_next;
			}
		}
		break;
	case 74:
		/* 4a AH   RX */
		{
			if (mem_address < CORESIZE) {
				v = load_halfword(mem_address);
				set_add_cc(reg[R1], v, reg[R1] + v);
				reg[R1] = reg[R1] + v;
				goto fetch_next;
			}
		}
		break;
	case 75:
		/* 4b SH   RX */
		{
			if (mem_address < CORESIZE) {
				v = load_halfword(mem_address);
				set_add_cc(reg[R1], ~v, reg[R1] - v);
				reg[R1] = reg[R1] - v;
				goto fetch_next;
			}
		}
		break;
	case 76:
		/* 4c MH   RX */
		{
			if (mem_address < CORESIZE) {
				v = load_halfword(mem_address);
				reg[R1] = reg[R1] * v;
				goto fetch_next;
			}
		}
		break;
	case 77:
		/* 4d */ ;
		goto illegal_opcode;
	case 78:
		/* 4e CVD  RX */
		{
			if ((mem_address > modpoint) && (mem_address < CORESIZE)) {
				CHECK_ADDRESS_ALIGNMENT();
				exit_code = opcode_CVD(R1);
				if (exit_code == EXIT_CONTINUE)
					goto fetch_next;
				return exit_code;
			}
		}
		break;
	case 79:
		/* 4f CVB  RX */
		{
			if ((mem_address > modpoint) && (mem_address < CORESIZE)) {
				CHECK_ADDRESS_ALIGNMENT();
				exit_code = opcode_CVB(R1);
				if (exit_code == EXIT_CONTINUE)
					goto fetch_next;
				return exit_code;
			}
		}
		break;
	case 80:
		/* 50 ST   RX */
		{
			if ((mem_address > modpoint) && (mem_address < CORESIZE)) {
				store_word(reg[R1], mem_address);
				if (mem_address == link_address && reg[R1] == 0) {
					return exec_time_exceeded();
				}
				goto fetch_next;
			}
		}
		break;
	case 81:
		/* 51 */ ;
		goto illegal_opcode;
	case 82:
		/* 52 */ ;
		goto illegal_opcode;
	case 83:
		/* 53 */ ;
		goto illegal_opcode;
	case 84:
		/* 54 N    RX */
		{
			if (mem_address < CORESIZE) {
				v = load_word(mem_address);
				v = reg[R1] = reg[R1] & v;
				if (v == 0) cc = CC0;
				else cc = CC1;
				goto fetch_next;
			}
		}
		break;
	case 85:
		/* 55 CL   RX */
		{
			/* Unsigned compare */
			if (mem_address < CORESIZE) {
				D2 = load_word(mem_address) + msbit;
				D1 = reg[R1] + msbit;
				if (D1 == D2) cc = CC_EQ;
				else if (D1 < D2) cc = CC_LT;
				else cc = CC_GT;
				goto fetch_next;
			}
		}
		break;
	case 86:
		/* 56 O    RX */
		{
			if (mem_address < CORESIZE) {
				v = load_word(mem_address);
				v = reg[R1] = reg[R1] | v;
				if (v == 0) cc = CC0;
				else cc = CC1;
				goto fetch_next;
			}
		}
		break;
	case 87:
		/* 57 X    RX */
		{
			if (mem_address < CORESIZE) {
				v = load_word(mem_address);
				v = reg[R1] = reg[R1] ^ v;
				if (v == 0) cc = CC0;
				else cc = CC1;
				goto fetch_next;
			}
		}
		break;
	case 88:
		/* 58 L    RX */
		{
			if (mem_address < CORESIZE) {
				reg[R1] = load_word(mem_address);
				goto fetch_next;
			}
		}
		break;
	case 89:
		/* 59 C    RX */
		{
			if (mem_address < CORESIZE) {
				v = load_word(mem_address);
				if (reg[R1] == v) cc = CC_EQ;
				else if (reg[R1] < v) cc = CC_LT;
				else cc = CC_GT;
				goto fetch_next;
			}
		}
		break;
	case 90:
		/* 5a A    RX */
		{
			if (mem_address < CORESIZE) {
				v = load_word(mem_address);
				set_add_cc(reg[R1], v, reg[R1] + v);
				reg[R1] = reg[R1] + v;
				goto fetch_next;
			}
		}
		break;
	case 91:
		/* 5b S    RX */
		{
			if (mem_address < CORESIZE) {
				v = load_word(mem_address);
				set_add_cc(reg[R1], ~v, reg[R1] - v);
				reg[R1] = reg[R1] - v;
				goto fetch_next;
			}
		}
		break;
	case 92:
		/* 5c M    RX */
		{
			if (mem_address < CORESIZE) {
				xx = reg[R1 | 1];
				xy = load_word(mem_address);
				xx = xx * xy;
				reg[R1] = (xx >> 32);
				reg[R1 | 1] = xx;
				goto fetch_next;
			}
		}
		break;
	case 93:
		/* 5d D    RX */
		{
			if (mem_address < CORESIZE) {
				xx = reg[R1];
				xy = reg[R1 + 1];
				xx = (xx << 32) + (xy & 0xFFFFFFFF);
				xy = load_word(mem_address);
				reg[R1] = xx % xy;
				reg[R1 + 1] = xx / xy;
				goto fetch_next;
			}
		}
		break;
	case 94:
		/* 5e AL   RX */
		{
			if (mem_address < CORESIZE) {
				k = load_word(mem_address);
				v = reg[R1] + k;
				set_add_carry(reg[R1], k, v);
				reg[R1] = v;
				goto fetch_next;
			}
		}
		break;
	case 95:
		/* 5f SL   RX */
		{
			if (mem_address < CORESIZE) {
				k = load_word(mem_address);
				v = reg[R1] - k;
				set_subtract_carry(reg[R1], k, v);
				reg[R1] = v;
				goto fetch_next;
			}
		}
		break;
	case 96:
		/* 60 STD  RX */
		{
			if ((mem_address > modpoint) && (mem_address < CORESIZE)) {
				CHECK_ADDRESS_ALIGNMENT();
				CHECK_FLOAT_REG(R1);
				store_word(f[R1], mem_address);
				store_word(f[R1 + 1], mem_address + 4);
				goto fetch_next;
			}
		}
		break;
	case 97:
		/* 61 */ ;
		goto illegal_opcode;
	case 98:
		/* 62 */ ;
		goto illegal_opcode;
	case 99:
		/* 63 */ ;
		goto illegal_opcode;
	case 100:
		/* 64 */ ;
		goto illegal_opcode;
	case 101:
		/* 65 */ ;
		goto illegal_opcode;
	case 102:
		/* 66 */ ;
		goto illegal_opcode;
	case 103:
		/* 67 */ ;
		goto illegal_opcode;
	case 104:
		/* 68 LD   RX */
		{
			if (mem_address < CORESIZE) {
				CHECK_ADDRESS_ALIGNMENT();
				CHECK_FLOAT_REG(R1);
				f[R1] = load_word(mem_address);
				f[R1 + 1] = load_word(mem_address + 4);
				goto fetch_next;
			}
		}
		break;
	case 105:
		/* 69 CD   RX */
		{
			if (mem_address < CORESIZE) {
				CHECK_ADDRESS_ALIGNMENT();
				CHECK_FLOAT_REG(R1);
				split_register(&fx, R1);
				split_long(&fy);
				compare_float(&fx, &fy);
				goto fetch_next;
			}
		}
		break;
	case 106:
		/* 6a AD   RX */
		{
			if (mem_address < CORESIZE) {
				CHECK_ADDRESS_ALIGNMENT();
				CHECK_FLOAT_REG(R1);
				split_register(&fx, R1);
				split_long(&fy);
				add_normalized(&fx, &fy, &fz);
				join_register(&fz, R1);
				goto fetch_next;
			}
		}
		break;
	case 107:
		/* 6b SD   RX */
		{
			if (mem_address < CORESIZE) {
				CHECK_ADDRESS_ALIGNMENT();
				CHECK_FLOAT_REG(R1);
				split_register(&fx, R1);
				split_long(&fy);
				fy.sign ^= 1;
				add_normalized(&fx, &fy, &fz);
				join_register(&fz, R1);
				goto fetch_next;
			}
		}
		break;
	case 108:
		/* 6c MD   RX */
		{
			if (mem_address < CORESIZE) {
				CHECK_ADDRESS_ALIGNMENT();
				CHECK_FLOAT_REG(R1);
				split_register(&fx, R1);
				split_long(&fy);
				multiply_float(&fx, &fy, &fz);
				join_register(&fz, R1);
				goto fetch_next;
			}
		}
		break;
	case 109:
		/* 6d DD   RX */
		{
			if (mem_address < CORESIZE) {
				CHECK_ADDRESS_ALIGNMENT();
				CHECK_FLOAT_REG(R1);
				split_register(&fx, R1);
				split_long(&fy);
				exit_code = divide_float(&fx, &fy, &fz);
				if (exit_code == EXIT_CONTINUE) {
					join_register(&fz, R1);
					goto fetch_next;
				}
				return divide_by_zero();
			}
		}
		break;
	case 110:
		/* 6e AW   RX */
		{
			if (mem_address < CORESIZE) {
				CHECK_ADDRESS_ALIGNMENT();
				CHECK_FLOAT_REG(R1);
				split_register(&fx, R1);
				split_long(&fy);
				add_unnormalized(&fx, &fy, &fz);
				join_register(&fz, R1);
				goto fetch_next;
			}
		}
		break;
	case 111:
		/* 6f SW   RX */
		{
			if (mem_address < CORESIZE) {
				CHECK_ADDRESS_ALIGNMENT();
				CHECK_FLOAT_REG(R1);
				split_register(&fx, R1);
				split_long(&fy);
				fy.sign ^= 1;
				add_unnormalized(&fx, &fy, &fz);
				join_register(&fz, R1);
				goto fetch_next;
			}
		}
		break;
	case 112:
		/* 70 STE  RX */
		{
			if ((mem_address > modpoint) && (mem_address < CORESIZE)) {
				CHECK_FLOAT_REG(R1);
				store_word(f[R1], mem_address);
				goto fetch_next;
			}
		}
		break;
	case 113:
		/* 71 */ ;
		goto illegal_opcode;
	case 114:
		/* 72 */ ;
		goto illegal_opcode;
	case 115:
		/* 73 */ ;
		goto illegal_opcode;
	case 116:
		/* 74 */ ;
		goto illegal_opcode;
	case 117:
		/* 75 */ ;
		goto illegal_opcode;
	case 118:
		/* 76 */ ;
		goto illegal_opcode;
	case 119:
		/* 77 */ ;
		goto illegal_opcode;
	case 120:
		/* 78 LE   RX */
		{
			if (mem_address < CORESIZE) {
				CHECK_FLOAT_REG(R1);
				f[R1] = load_word(mem_address);
				goto fetch_next;
			}
		}
		break;
	case 121:
		/* 79 CE   RX */
		{
			if (mem_address < CORESIZE) {
				CHECK_FLOAT_REG(R1);
				split_short(&fx, f[R1]);
				split_short(&fy, load_word(mem_address));
				compare_float(&fx, &fy);
				goto fetch_next;
			}
		}
		break;
	case 122:
		/* 7a AE   RX */
		{
			if (mem_address < CORESIZE) {
				CHECK_FLOAT_REG(R1);
				split_short(&fx, f[R1]);
				split_short(&fy, load_word(mem_address));
				add_normalized(&fx, &fy, &fz);
				f[R1] = join_short(&fz);
				goto fetch_next;
			}
		}
		break;
	case 123:
		/* 7b SE   RX */
		{
			if (mem_address < CORESIZE) {
				CHECK_FLOAT_REG(R1);
				split_short(&fx, f[R1]);
				split_short(&fy, load_word(mem_address));
				fy.sign ^= 1;
				add_normalized(&fx, &fy, &fz);
				f[R1] = join_short(&fz);
				goto fetch_next;
			}
		}
		break;
	case 124:
		/* 7c ME   RX */
		{
			if (mem_address < CORESIZE) {
				/* 32-bit multiply has a 64-bit result */
				CHECK_FLOAT_REG(R1);
				split_short(&fx, f[R1]);
				split_short(&fy, load_word(mem_address));
				multiply_float(&fx, &fy, &fz);
				join_register(&fz, R1);
				goto fetch_next;
			}
		}
		break;
	case 125:
		/* 7d DE   RX */
		{
			if (mem_address < CORESIZE) {
				CHECK_FLOAT_REG(R1);
				split_short(&fx, f[R1]);
				split_short(&fy, load_word(mem_address));
				exit_code = divide_float(&fx, &fy, &fz);
				if (exit_code == EXIT_CONTINUE) {
					f[R1] = join_short(&fz);
					goto fetch_next;
				}
				return divide_by_zero();
			}
		}
		break;
	case 126:
		/* 7e AU   RX */
		{
			if (mem_address < CORESIZE) {
				CHECK_FLOAT_REG(R1);
				split_short(&fx, f[R1]);
				split_short(&fy, load_word(mem_address));
				add_unnormalized(&fx, &fy, &fz);
				f[R1] = join_short(&fz);
				goto fetch_next;
			}
		}
		break;
	case 127:
		/* 7f SU   RX */
		{
			if (mem_address < CORESIZE) {
				CHECK_FLOAT_REG(R1);
				split_short(&fx, f[R1]);
				split_short(&fy, load_word(mem_address));
				fy.sign ^= 1;
				add_unnormalized(&fx, &fy, &fz);
				f[R1] = join_short(&fz);
				goto fetch_next;
			}
		}
		break;
	case 128:
		/* 80 SSM  __ */
		{
		}
		goto illegal_opcode;
	case 129:
		/* 81 */ ;
		goto illegal_opcode;
	case 130:
		/* 82 LPSW __ */
		{
		}
		goto illegal_opcode;
	case 131:
		/* 83 */ ;
		goto illegal_opcode;
	case 132:
		/* 84 WRD  RX */
		{
		}
		goto illegal_opcode;
	case 133:
		/* 85 RDD  RX */
		{
		}
		goto illegal_opcode;
	case 134:
		/* 86 BXH  RS */
		{
			v = reg[R1] + reg[R3];
			k = v - reg[R3 | 1];
			reg[R1] = v;
			if (k <= 0) goto fetch_next;
			exit_code = runtime_support();
			if (exit_code == EXIT_CONTINUE)
				goto fetch_next;
			if (exit_code > EXIT_CONTINUE)
				return exit_code;
			/* Else address error */
		}
		break;
	case 135:
		/* 87 BXLE RS */
		{
			v = reg[R1] + reg[R3];
			k = v - reg[R3 | 1];
			reg[R1] = v;
			if (k > 0) goto fetch_next;
			exit_code = runtime_support();
			if (exit_code == EXIT_CONTINUE)
				goto fetch_next;
			if (exit_code > EXIT_CONTINUE)
				return exit_code;
			/* Else address error */
		}
		break;
	case 136:
		/* 88 SRL  RS */
		{
			mem_address = mem_address & 63;
			if (mem_address >= 32) {
				reg[R1] = 0;
				goto fetch_next;
			}
			reg[R1] = SHR(reg[R1], mem_address);
			goto fetch_next;
		}
		break;
	case 137:
		/* 89 SLL  RS */
		{
			mem_address = mem_address & 63;
			if (mem_address >= 32) {
				reg[R1] = 0;
				goto fetch_next;
			}
			reg[R1] = (reg[R1] << mem_address);
			goto fetch_next;
		}
		break;
	case 138:
		/* 8a SRA  RS */
		{
			mem_address = mem_address & 63;
			v = reg[R1];
			if (mem_address >= 32) {
				if (v < 0) {
					cc = CC_LT;
					reg[R1] = -1;
					goto fetch_next;
				}
				cc = CC_EQ;
				reg[R1] = 0;
				goto fetch_next;
			}
			if (mem_address == 0) {
				if (v == 0) cc = CC_EQ;
				else if (v < 0) cc = CC_LT;
				else cc = CC_GT;
				goto fetch_next;
			}
			if (v >= 0) {
				v = SHR(v, mem_address);
				reg[R1] = v;
				if (v == 0) cc = CC0;
				else cc = CC2;
				goto fetch_next;
			}
			v = SHR(v, mem_address);
			reg[R1] = v - (1 << (32 - mem_address));
			cc = CC1;
			goto fetch_next;
		}
		break;
	case 139:
		/* 8b SLA  RS */
		{
			mem_address = mem_address & 63;
			v = reg[R1];
			if (mem_address >= 32) {
				reg[R1] = v & msbit;
				if (reg[R1] == 0) {
					if (v == 0) cc = CC_EQ;
					else cc = CC_OV;
				} else {
					if (v == -1) cc = CC_LT;
					else cc = CC_OV;
				}
				goto fetch_next;
			}
			if (v == 0) {
				/* No change to reg(R1) */
				cc = CC_EQ;
				goto fetch_next;
			}
			mask = -(1 << (31 - mem_address));
			if (v > 0) {
				reg[R1] = (v << mem_address) & 0x7fffffff;
				if ((v & mask) != 0) cc = CC_OV;
				else if (reg[R1] == 0) cc = CC_EQ;
				else cc = CC_GT;
				goto fetch_next;
			}
			if ((v & mask) == mask) cc = CC_LT;
			else cc = CC_OV;
			reg[R1] = (v << mem_address) | msbit;
			goto fetch_next;
		}
		break;
	case 140:
		/* 8c SRDL RS */
		{
			mem_address = mem_address & 63;
			if (mem_address == 0)
				goto fetch_next;
			if (mem_address >= 32) {
				reg[R1 | 1] = SHR(reg[R1], (mem_address - 32));
				reg[R1] = 0;
				goto fetch_next;
			}
			v = SHR(reg[R1 | 1], mem_address)
			    + (reg[R1] << (32 - mem_address));
			reg[R1] = SHR(reg[R1], mem_address);
			reg[R1 | 1] = v;
			goto fetch_next;
		}
		break;
	case 141:
		/* 8d SLDL RS */
		{
			mem_address = mem_address & 63;
			if (mem_address == 0)
				goto fetch_next;
			if (mem_address >= 32) {
				reg[R1] = (reg[R1 | 1] << (mem_address - 32));
				reg[R1 | 1] = 0;
				goto fetch_next;
			}
			v = (reg[R1] << mem_address)
			    + SHR(reg[R1 | 1], (32 - mem_address));
			reg[R1 | 1] = (reg[R1 | 1] << mem_address);
			reg[R1] = v;
			goto fetch_next;
		}
		break;
	case 142:
		/* 8e SRDA RS */
		{
			mem_address = mem_address & 63;
			v = reg[R1];
			if (mem_address >= 32) {
				mem_address = mem_address & 31;
				if (v >= 0) {
					reg[R1] = 0;
					reg[R1 + 1] = SHR(v, mem_address);
					if (reg[R1 + 1] == 0) cc = CC0;
					else cc = CC2;
				} else {
					reg[R1] = -1;
					if (mem_address == 0)
						reg[R1 + 1] = v;
					else {
						mask =
						    -(1 << (32 - mem_address));
						reg[R1 + 1] =
						    SHR(v, mem_address) | mask;
					}
					cc = CC1;
				}
				goto fetch_next;
			}
			if (mem_address == 0) {
				if (v < 0) cc = CC_LT;
				else if (v == 0 && reg[R1 + 1] == 0)
					cc = CC_EQ;
				else cc = CC_GT;
				goto fetch_next;
			}
			if (v >= 0) {
				reg[R1] = SHR(reg[R1], mem_address);
				reg[R1 + 1] = SHR(reg[R1 + 1], mem_address)
				    | (v << (32 - mem_address));
				if ((reg[R1] | reg[R1 + 1]) == 0) cc = CC0;
				else cc = CC2;
			} else {
				mask = -(1 << (32 - mem_address));
				reg[R1] = SHR(reg[R1], mem_address)
				    | mask;
				reg[R1 + 1] = SHR(reg[R1 + 1], mem_address)
				    | (v << (32 - mem_address));
				cc = CC1;
			}
			goto fetch_next;
		}
		break;
	case 143:
		/* 8f SLDA RS */
		{
			mem_address = mem_address & 63;
			v = reg[R1];
			if (mem_address >= 32) {
				mem_address = mem_address & 31;
				mask = -(1 << (31 - mem_address));
				if (v >= 0) {
					reg[R1] =
					    (reg[R1 + 1] << mem_address) &
					    0x7fffffff;
					if (v != 0) cc = CC_OV;
					else if ((reg[R1 + 1] & mask) != 0)
						cc = CC_OV;
					else if (reg[R1] == 0) cc = CC_EQ;
					else cc = CC_GT;
					reg[R1 + 1] = 0;
				} else {
					if (v != -1) cc = CC_OV;
					else if ((reg[R1 + 1] & mask) != mask)
						cc = CC_OV;
					else cc = CC1;
					reg[R1] =
					    (reg[R1 + 1] << mem_address) |
					    msbit;
					reg[R1 + 1] = 0;
				}
				goto fetch_next;
			}
			if (mem_address == 0) {
				if (v < 0) cc = CC_LT;
				else if (v == 0 && reg[R1 + 1] == 0)
					cc = CC_EQ;
				else cc = CC_GT;
				goto fetch_next;
			}
			mask = -(1 << (31 - mem_address));
			if (v >= 0) {
				reg[R1] = (v << mem_address)
				    | SHR(reg[R1 + 1], (32 - mem_address));
				reg[R1] = reg[R1] & 0x7fffffff;
				reg[R1 + 1] = (reg[R1 + 1] << mem_address);
				if ((v & mask) != 0) cc = CC_OV;
				else if ((reg[R1] | reg[R1 + 1]) == 0)
					cc = CC_EQ;
				else cc = CC_GT;
			} else {
				if ((v & mask) != mask) cc = CC_OV;
				else cc = CC_LT;
				v = (v << mem_address)
				    | SHR(reg[R1 + 1], (32 - mem_address));
				reg[R1] = v | msbit;
				reg[R1 + 1] = (reg[R1 + 1] << mem_address);
			}
			goto fetch_next;
		}
		break;
	case 144:
		/* 90 STM  RS */
		{
			if ((mem_address > modpoint) && (mem_address < CORESIZE)) {
				if (R1 > R3) R3 = R3 + 16;
				for (k = R1; k <= R3; k++) {
					store_word(reg[k & 15], mem_address);
					if (mem_address == link_address &&
						reg[k & 15] == 0) {
						return exec_time_exceeded();
					}
					mem_address = mem_address + 4;
				}
				goto fetch_next;
			}
		}
		break;
	case 145:
		/* 91 TM   SI */
		{
			if (mem_address < CORESIZE) {
				v = core[mem_address];
				k = v & I2;
				if (k == 0) cc = CC_EQ;
				else if (k == v) cc = CC_OV;
				else cc = CC_LT;
				goto fetch_next;
			}
		}
		break;
	case 146:
		/* 92 MVI  SI */
		{
			if ((mem_address > modpoint) && (mem_address < CORESIZE)) {
				core[mem_address] = I2;
				check_watch_point();
				goto fetch_next;
			}
		}
		break;
	case 147:
		/* 93 TS   SI */
		{
		}
		goto illegal_opcode;
	case 148:
		/* 94 NI   SI */
		{
			if ((mem_address > modpoint) && (mem_address < CORESIZE)) {
				v = core[mem_address] & I2;
				core[mem_address] = v;
				if (v == 0) cc = CC0;
				else cc = CC1;
				check_watch_point();
				goto fetch_next;
			}
		}
		break;
	case 149:
		/* 95 CLI  SI */
		{
			/* Unsigned compare */
			if (mem_address < CORESIZE) {
				v = core[mem_address];
				if (v == I2) cc = CC_EQ;
				else if (v < I2) cc = CC_LT;
				else cc = CC_GT;
				goto fetch_next;
			}
		}
		break;
	case 150:
		/* 96 OI   SI */
		{
			if ((mem_address > modpoint) && (mem_address < CORESIZE)) {
				v = core[mem_address] | I2;
				core[mem_address] = v;
				if (v == 0) cc = CC0;
				else cc = CC1;
				check_watch_point();
				goto fetch_next;
			}
		}
		break;
	case 151:
		/* 97 XI   RS */
		{
			if ((mem_address > modpoint) && (mem_address < CORESIZE)) {
				v = core[mem_address] ^ I2;
				core[mem_address] = v;
				if (v == 0) cc = CC0;
				else cc = CC1;
				check_watch_point();
				goto fetch_next;
			}
		}
		break;
	case 152:
		/* 98 LM   RS */
		{
			if (mem_address < CORESIZE) {
				if (R1 > R3) R3 = R3 + 16;
				for (k = R1; k <= R3; k++) {
					reg[k & 15] = load_word(mem_address);
					mem_address = mem_address + 4;
				}
				goto fetch_next;
			}
		}
		break;
	case 153:
		/* 99 */ ;
		goto illegal_opcode;
	case 154:
		/* 9a */ ;
		goto illegal_opcode;
	case 155:
		/* 9b */ ;
		goto illegal_opcode;
	case 156:
		/* 9c SIO  SI */
		{
		}
		goto illegal_opcode;
	case 157:
		/* 9d TIO  SI */
		{
		}
		goto illegal_opcode;
	case 158:
		/* 9e HIO  SI */
		{
		}
		goto illegal_opcode;
	case 159:
		/* 9f TCH  SI */
		{
		}
		goto illegal_opcode;
	case 160:
		/* a0 */ ;
		goto illegal_opcode;
	case 161:
		/* a1 */ ;
		goto illegal_opcode;
	case 162:
		/* a2 */ ;
		goto illegal_opcode;
	case 163:
		/* a3 */ ;
		goto illegal_opcode;
	case 164:
		/* a4 */ ;
		goto illegal_opcode;
	case 165:
		/* a5 */ ;
		goto illegal_opcode;
	case 166:
		/* a6 */ ;
		goto illegal_opcode;
	case 167:
		/* a7 */ ;
		goto illegal_opcode;
	case 168:
		/* a8 */ ;
		goto illegal_opcode;
	case 169:
		/* a9 */ ;
		goto illegal_opcode;
	case 170:
		/* aa */ ;
		goto illegal_opcode;
	case 171:
		/* ab */ ;
		goto illegal_opcode;
	case 172:
		/* ac */ ;
		goto illegal_opcode;
	case 173:
		/* ad */ ;
		goto illegal_opcode;
	case 174:
		/* ae */ ;
		goto illegal_opcode;
	case 175:
		/* af */ ;
		goto illegal_opcode;
	case 176:
		/* b0 */ ;
		goto illegal_opcode;
	case 177:
		/* b1 */ ;
		goto illegal_opcode;
	case 178:
		/* b2 */ ;
		goto illegal_opcode;
	case 179:
		/* b3 */ ;
		goto illegal_opcode;
	case 180:
		/* b4 */ ;
		goto illegal_opcode;
	case 181:
		/* b5 */ ;
		goto illegal_opcode;
	case 182:
		/* b6 */ ;
		goto illegal_opcode;
	case 183:
		/* b7 */ ;
		goto illegal_opcode;
	case 184:
		/* b8 */ ;
		goto illegal_opcode;
	case 185:
		/* b9 */ ;
		goto illegal_opcode;
	case 186:
		/* ba */ ;
		goto illegal_opcode;
	case 187:
		/* bb */ ;
		goto illegal_opcode;
	case 188:
		/* bc */ ;
		goto illegal_opcode;
	case 189:
		/* bd */ ;
		goto illegal_opcode;
	case 190:
		/* be */ ;
		goto illegal_opcode;
	case 191:
		/* bf */ ;
		goto illegal_opcode;
	case 192:
		/* c0 */ ;
		goto illegal_opcode;
	case 193:
		/* c1 */ ;
		goto illegal_opcode;
	case 194:
		/* c2 */ ;
		goto illegal_opcode;
	case 195:
		/* c3 */ ;
		goto illegal_opcode;
	case 196:
		/* c4 */ ;
		goto illegal_opcode;
	case 197:
		/* c5 */ ;
		goto illegal_opcode;
	case 198:
		/* c6 */ ;
		goto illegal_opcode;
	case 199:
		/* c7 */ ;
		goto illegal_opcode;
	case 200:
		/* c8 */ ;
		goto illegal_opcode;
	case 201:
		/* c9 */ ;
		goto illegal_opcode;
	case 202:
		/* ca */ ;
		goto illegal_opcode;
	case 203:
		/* cb */ ;
		goto illegal_opcode;
	case 204:
		/* cc */ ;
		goto illegal_opcode;
	case 205:
		/* cd */ ;
		goto illegal_opcode;
	case 206:
		/* ce */ ;
		goto illegal_opcode;
	case 207:
		/* cf */ ;
		goto illegal_opcode;
	case 208:
		/* d0 */ ;
		goto illegal_opcode;
	case 209:
		/* d1 MVN  SS */
		{
			CHECK_ADDRESS_HIGH(D2);
			if ((mem_address > modpoint) && (mem_address < CORESIZE)) {
				for (k = 0; k <= OP1; k++) {
					core[D1 + k] = (core[D1 + k] & 0xf0) |
						(core[D2 + k] & 15);
				}
				check_watch_point();
				goto fetch_next;
			}
		}
		break;
	case 210:
		/* d2 MVC  SS */
		{
			CHECK_ADDRESS_HIGH(D2);
			if ((mem_address > modpoint) && (mem_address < CORESIZE)) {
				for (k = 0; k <= OP1; k++) {
					core[D1 + k] = core[D2 + k];
				}
				check_watch_point();
				goto fetch_next;
			}
		}
		break;
	case 211:
		/* d3 MVZ  SS */
		{
			CHECK_ADDRESS_HIGH(D2);
			if ((mem_address > modpoint) && (mem_address < CORESIZE)) {
				for (k = 0; k <= OP1; k++) {
					core[D1 + k] = (core[D1 + k] & 15) |
						(core[D2 + k] & 0xf0);
				}
				check_watch_point();
				goto fetch_next;
			}
		}
		break;
	case 212:
		/* d4 NC   SS */
		{
			CHECK_ADDRESS_HIGH(D2);
			cc = CC_EQ;
			if (D1 < CORESIZE) {
				for (k = 0; k <= OP1; k++) {
					v = core[D1 + k] & core[D2 + k];
					core[D1 + k] = v;
					if (v != 0) cc = CC_LT;
				}
				check_watch_point();
				goto fetch_next;
			}
		}
		break;
	case 213:
		/* d5 CLC  SS */
		{
			CHECK_ADDRESS_HIGH(D2);
			if (D1 < CORESIZE) {
				for (k = 0; k <= OP1; k++) {
					v = core[D1 + k] - core[D2 + k];
					if (v < 0) {
						cc = CC_LT;
						goto fetch_next;
					}
					if (v > 0) {
						cc = CC_GT;
						goto fetch_next;
					}
				}
				cc = CC_EQ;
				goto fetch_next;
			}
		}
		break;
	case 214:
		/* d6 OC   SS */
		{
			CHECK_ADDRESS_HIGH(D2);
			cc = CC_EQ;
			if (D1 < CORESIZE) {
				for (k = 0; k <= OP1; k++) {
					v = core[D1 + k] | core[D2 + k];
					core[D1 + k] = v;
					if (v != 0) cc = CC_LT;
				}
				check_watch_point();
				goto fetch_next;
			}
		}
		break;
	case 215:
		/* d7 XC   SS */
		{
			CHECK_ADDRESS_HIGH(D2);
			cc = CC_EQ;
			if (D1 < CORESIZE) {
				for (k = 0; k <= OP1; k++) {
					v = core[D1 + k] ^ core[D2 + k];
					core[D1 + k] = v;
					if (v != 0) cc = CC_LT;
				}
				check_watch_point();
				goto fetch_next;
			}
		}
		break;
	case 216:
		/* d8 */ ;
		goto illegal_opcode;
	case 217:
		/* d9 */ ;
		goto illegal_opcode;
	case 218:
		/* da */ ;
		goto illegal_opcode;
	case 219:
		/* db */ ;
		goto illegal_opcode;
	case 220:
		/* dc TR   SS */
		{
			CHECK_ADDRESS_HIGH(D2);
			if (D1 < CORESIZE) {
				for (k = 0; k <= OP1; k++) {
					v = core[core[D1 + k] + D2];
					core[D1 + k] = v;
				}
				check_watch_point();
				goto fetch_next;
			}
		}
		break;
	case 221:
		/* dd TRT  SS */
		{
			CHECK_ADDRESS_HIGH(D2);
			if (D1 < CORESIZE) {
				for (k = 0; k <= OP1; k++) {
					v = core[core[D1 + k] + D2];
					if (v != 0) {
						reg[1] = reg[1] & 0xff000000;
						reg[2] = reg[2] & 0xffffff00;
						reg[1] = reg[1] | (D1 + k);
						reg[2] = reg[2] | v;
						if (k == OP1) cc = CC2;
						else cc = CC1;
						goto fetch_next;
					}
				}
				cc = CC0;
				goto fetch_next;
			}
		}
		break;
	case 222:
		/* de ED   SS */
		{
			CHECK_ADDRESS_HIGH(D2);
			if ((mem_address > modpoint) && (mem_address < CORESIZE)) {
				opcode_EDMK(OP1, D1, D2, 0);
				goto fetch_next;
			}
		}
		break;
	case 223:
		/* df EDMK SS */
		{
			CHECK_ADDRESS_HIGH(D2);
			if ((mem_address > modpoint) && (mem_address < CORESIZE)) {
				opcode_EDMK(OP1, D1, D2, 1);
				goto fetch_next;
			}
		}
		break;
	case 224:
		/* e0 */ ;
		goto illegal_opcode;
	case 225:
		/* e1 */ ;
		goto illegal_opcode;
	case 226:
		/* e2 */ ;
		goto illegal_opcode;
	case 227:
		/* e3 */ ;
		goto illegal_opcode;
	case 228:
		/* e4 */ ;
		goto illegal_opcode;
	case 229:
		/* e5 */ ;
		goto illegal_opcode;
	case 230:
		/* e6 */ ;
		goto illegal_opcode;
	case 231:
		/* e7 */ ;
		goto illegal_opcode;
	case 232:
		/* e8 */ ;
		goto illegal_opcode;
	case 233:
		/* e9 */ ;
		goto illegal_opcode;
	case 234:
		/* ea */ ;
		goto illegal_opcode;
	case 235:
		/* eb */ ;
		goto illegal_opcode;
	case 236:
		/* ec */ ;
		goto illegal_opcode;
	case 237:
		/* ed */ ;
		goto illegal_opcode;
	case 238:
		/* ee */ ;
		goto illegal_opcode;
	case 239:
		/* ef */ ;
		goto illegal_opcode;
	case 240:
		/* f0 */ ;
		goto illegal_opcode;
	case 241:
		/* f1 MVO  SS */
		{
			CHECK_ADDRESS_HIGH(D2);
			if ((mem_address > modpoint) && (mem_address < CORESIZE)) {
				opcode_MVO(L1, L2, D1, D2);
				goto fetch_next;
			}
		}
		break;
	case 242:
		/* f2 PACK SS */
		{
			CHECK_ADDRESS_HIGH(D2);
			if ((mem_address > modpoint) && (mem_address < CORESIZE)) {
				opcode_PACK(L1, L2, D1, D2);
				goto fetch_next;
			}
		}
		break;
	case 243:
		/* f3 UNPK SS */
		{
			CHECK_ADDRESS_HIGH(D2);
			if ((mem_address > modpoint) && (mem_address < CORESIZE)) {
				opcode_UNPK(L1, L2, D1, D2);
				goto fetch_next;
			}
		}
		break;
	case 244:
		/* f4 */ ;
		goto illegal_opcode;
	case 245:
		/* f5 */ ;
		goto illegal_opcode;
	case 246:
		/* f6 */ ;
		goto illegal_opcode;
	case 247:
		/* f7 */ ;
		goto illegal_opcode;
	case 248:
		/* f8 ZAP  SS */
		{
			CHECK_ADDRESS_HIGH(D2);
			if ((mem_address > modpoint) && (mem_address < CORESIZE)) {
				exit_code =
				    opcode_ZAP(L1, L2, &core[D1], &core[D2]);
				if (exit_code == EXIT_CONTINUE)
					goto fetch_next;
				return exit_code;
			}
		}
		break;
	case 249:
		/* f9 CP   SS */
		{
			CHECK_ADDRESS_HIGH(D2);
			if ((mem_address > modpoint) && (mem_address < CORESIZE)) {
				exit_code =
				    opcode_CP(L1, L2, &core[D1], &core[D2]);
				if (exit_code == EXIT_CONTINUE)
					goto fetch_next;
				return exit_code;
			}
		}
		break;
	case 250:
		/* fa AP   SS */
		{
			CHECK_ADDRESS_HIGH(D2);
			if ((mem_address > modpoint) && (mem_address < CORESIZE)) {
				exit_code =
				    opcode_AP(L1, L2, &core[D1], &core[D2]);
				if (exit_code == EXIT_CONTINUE)
					goto fetch_next;
				return exit_code;
			}
		}
		break;
	case 251:
		/* fb SP   SS */
		{
			CHECK_ADDRESS_HIGH(D2);
			if ((mem_address > modpoint) && (mem_address < CORESIZE)) {
				exit_code =
				    opcode_SP(L1, L2, &core[D1], &core[D2]);
				if (exit_code == EXIT_CONTINUE)
					goto fetch_next;
				return exit_code;
			}
		}
		break;
	case 252:
		/* fc MP   SS */
		{
		}
		goto illegal_opcode;
	case 253:
		/* fd DP   SS */
		{
		}
		goto illegal_opcode;
	case 254:
		/* fe */ ;
		goto illegal_opcode;
	case 255:
		/* ff */ ;
		goto illegal_opcode;
	default:
		break;
	}
	/* Emulation errors come here */
	if (mem_address < modpoint) {
		fprintf(stderr, "Error at %06X: Attempt to write over program: %08X\n",
			history[hip], mem_address);
	} else if (mem_address >= CORESIZE) {
		fprintf(stderr,
			"Error at %06X: Address range error: %08X is greater than %08X\n",
			history[hip], mem_address, CORESIZE);
	}
	return EXIT_ABORT;
}

/*
**	dump_history()
**
**	Dump the execution history
*/
void
dump_history(void)
{
	int i, k;

	for (i = 1; i <= HISTORY_MASK + 1; i++) {
		k = (i + hip) & HISTORY_MASK;
		if (history[k] != 0) {
			decode(k);
		}
	}
	dump_state();
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

	a = 32;
	b = core[a];
	if (b == 0) {
		/* Set default character encoding */
		if (output_options[0] & OPT_EBCDIC) {
			b = 0xF0;
		} else {
			b = 0x30;
		}
	}
	zone = b & 0xF0;
	if (b == '0') b = 0;
	for (i = 0; i <= 255; i++) {
		if (isupper(i)) {
			if (control[i]) {
				if (b == 0x30) core[a++] = ascii[i];
				else
				if (b == 0xF0) core[a++] = ebcdic[i];
				else core[a++] = i;
			}
		}
		if (a >= 59) {
			/* The program starts at 60. */
			break;
		}
	}
	core[a] = 0;
}

/*
**	start_simulation()
**
**	Open the object file and decide if it's a Pascal program or an XPL
**	program.  Pascal programs are loaded by pascal_simulation() and
**	XPL programs are loaded here.
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
	unsigned char *map;

	decimal_init();
	for (i = 0; i <= 255; i++) {
		opcode_count[i] = 0;
		clock_trap_delta[i] = 0;
	}
	modpoint = return_code = 0;
	link_address = watch_point = CORESIZE;
	obj = open(obj_filename, O_RDONLY, 0);
	if (obj < 0) {
		fprintf(stderr, "open failed: %s\n", obj_filename);
		return_code = 1;
		return EXIT_QUIET;
	}
	len = read(obj, &core[load_point], 80);
	if (strncmp((char *)&core[load_point], "%CODE", 5) == 0) {
		/* Undo the translation done in process_options(). */
		/* This allows EBCDIC headers to be loaded on ASCII machines */
		strcpy((char *) org_header, "%ORG ");
		strcpy((char *) code_header, "%CODE");
		zone = '0';
		return pascal_simulation(obj, obj_filename, (unsigned char *)0);
	}
	if (strncmp((char *)&core[load_point], (char *)code_header, 5) == 0) {
		zone = transmap['0'];
		if ('0' == 0xF0) map = ebcdic;
		else map = ascii;
		return pascal_simulation(obj, obj_filename, map);
	}
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
		printf("FILE() record length set to: %d\n", file_record_size);
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
	exit_code = simulator();
	if (pp == returnlink) {
		printf("Sim360 normal exit\n");
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
    fprintf(stderr, "           number - the XPL I/O unit.  Must be zero for Pascal\n");
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
    fprintf(stderr, "       --size=bytes - file() record size in bytes (default loaded from object module)\n");
    fprintf(stderr, "       --time=SSS - Max run time in seconds. MONITOR_LINK(0) (default 10)\n");
    fprintf(stderr, "       --lines=LLLL - Number of lines. MONITOR_LINK(1) (default 1000)\n");
    fprintf(stderr, "       --debug=D - Debug level. MONITOR_LINK(2) (default 2)\n");
    fprintf(stderr, "       --trace - Enable instruction trace\n");
    fprintf(stderr, "       --pmd - Exit if no error.  Use this before the pmd module\n");
    fprintf(stderr, "       --watch=HHHHHHHH - Set data watch point (default is disabled)\n");
    fprintf(stderr, "       --version - Print version information and exit\n");
    fprintf(stderr, "       -c - Display Op-code instruction execution counts\n");
    fprintf(stderr, "       -m - Allow the code section to be modified\n");
    fprintf(stderr, "       -v - Verbose\n");
    fprintf(stderr, "       @rc-file - Continue processing by reading options from the rc-file\n");
    fprintf(stderr, "       object-module - IBM/360 object file from the XPL or Pascal compiler\n");
    fprintf(stderr, "           Multiple object-modules may be used\n");
    fprintf(stderr, "   Uppercase letters are passed to the compilers as control toggles\n");
    fprintf(stderr, "   All single letter options are cleared after an object-module is executed\n");
}

void
expanded_help(void)
{
    fprintf(stderr, "\n");
    fprintf(stderr, "I/O unit numbers for IBM/360 XPL/Pascal programs are unique for\n");
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

	xplmon_link[0] = 10;	/* --time=10 */
	xplmon_link[1] = 1000;	/* --lines=1000 */
	xplmon_link[2] = 2;	/* --debug=2 */
	watch_point_option = CORESIZE;
	load_point = 0;
	for (v = 0; v <= 255; v++) {
		lower[v] = v;
		argtype[v] = 0;
		ascii[ebcdic[v]] = v;
		if (isupper(v)) argtype[v] = 2;
		else argtype[v] = 0;
	}
	/* Set up ASCII/EBCDIC translation for the Pascal code header */
	if ('0' == 0x30) transmap = ebcdic;
	else transmap = ascii;
	for (v = 0; v <= 5; v++) {
		/* Pascal header label */
		code_header[v] = transmap[code_header[v]];
		org_header[v] = transmap[org_header[v]];
	}
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
		} else if (strcmp(optext, "--pmd") == 0) {
			/* If the Pascal program ran to completion without
			   an error this option will exit the simulator.
			   It should be used after the pascal program and
			   before the PMD executable. */
			if (exit_code == EXIT_DONE) {
				return 0;
			}
		} else if (strncmp(optext, "--size=", 7) == 0) {
			record_length = numeric_option(&optext[7]);
			if (record_length < 32) {
				fprintf(stderr, "Record length too small\n");
				return 1;
			}
		} else if (strncmp(optext, "--trace", 7) == 0) {
			enable_trace = 1;
		} else if (strncmp(optext, "--time=", 7) == 0) {
			xplmon_link[0] = numeric_option(&optext[7]);
			clock_trap_address = returnlink;
			cpu_timer = xplmon_link[0] * 100;
		} else if (strncmp(optext, "--lines=", 8) == 0) {
			xplmon_link[1] = numeric_option(&optext[8]);
		} else if (strncmp(optext, "--debug=", 8) == 0) {
			xplmon_link[2] = numeric_option(&optext[8]);
		} else if (strncmp(optext, "--watch=", 8) == 0) {
			watch_point_option = hex_convert(&optext[8]);
		} else if (strcmp(optext, "--version") == 0) {
			fprintf(stderr, "IBM/360 simulator for Pascal and XPL.  Rev: %s\n",
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
