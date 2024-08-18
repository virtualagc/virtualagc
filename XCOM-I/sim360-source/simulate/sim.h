/*
**	Pascal/XPL runtime monitor and simulator for the IBM/360
**
**	Author: Daniel Weaver
*/

/*
**      The simulator requires 64-bit integers.
**
**      XPL_LONG -> Should be defined as a 64-bit signed integer
**      XPL_UNSIGNED_LONG -> Should be defined as a 64-bit unsigned integer
*/
/*
 * Modifications to Dan Weaver's code:
 * 2024-05-21 RSB   Added some extern's.
 */

#if defined(_MSC_VER)
// Visual Studio
#include <stddef.h>
#include <stdint.h>
typedef int64_t XPL_LONG;
typedef uint64_t XPL_UNSIGNED_LONG;
#define __XPL_TYPEDEFS
#endif

#if defined(__STDC_VERSION__) && __STDC_VERSION__ >= 199901L
/* C99 standard */
#include <stddef.h>
#include <stdint.h>
typedef intmax_t XPL_LONG;
typedef uintmax_t XPL_UNSIGNED_LONG;
#define __XPL_TYPEDEFS
#endif

#if !defined(__XPL_TYPEDEFS) && defined(__INTMAX_TYPE__)
/* GNUC */
typedef __INTMAX_TYPE__ XPL_LONG;
typedef __UINTMAX_TYPE__ XPL_UNSIGNED_LONG;
#define __XPL_TYPEDEFS
#endif

#if !defined(__XPL_TYPEDEFS)
/*
**	Integer multiply, divide, and the floating point simulation package
**	requires 64-bit integers.
*/
#error "This program requires 64-bit integers."
#endif

#if !defined(INT64_C)
#  define INT64_C(v) v ## LL
#  define UINT64_C(v) v ## ULL
#endif

#define CORESIZE (128 * 4096)

/* memory storage area */
extern unsigned char core[CORESIZE + 256];

/* Machine state */
extern int reg[16];		/* General purpose registers */
extern int cc;			/* Condition codes */
extern int zone;		/* Decimal arithmetic Zone field 0x30 or 0xF0 */
extern int pp, npp, codesize, fetch_limit, modpoint, load_point;
extern unsigned int f[16];	/* Floating point registers */
#define ADDRESS_MASK(p) ((p) & 0x00ffffff)

/* Condition codes */
#define CC_EQ 0
#define CC_LT 1
#define CC_GT 2
#define CC_OV 3
#define CC0 0
#define CC1 1
#define CC2 2
#define CC3 3

extern int mem_address;
extern int callback;
extern int returnlink;
extern int jumptable;
extern int simulator(int stepping);
extern int monitor_call(void);
extern void dump_history(void);

extern int return_code;
extern int exit_code;
#define EXIT_CONTINUE	0	/* Continue executing code */
#define EXIT_DONE	1	/* The program has run to completion */
#define EXIT_QUIET	2	/* Exit without Dump */
#define EXIT_ABORT	3	/* Exit with Dump */
#define EXIT_BREAK	4	/* Breakpoint */

extern int header[16];
extern int watch_point;
extern int watch_point_option;
extern int watch_point_break;
extern int watch_point_data;
extern void check_watch_point(void);
extern short load_halfword(int dp);
extern int load_word(int dp);
extern XPL_LONG load_double(int dp);
extern void store_halfword(int value, int dp);
extern void store_word(int value, int dp);
extern void store_double(XPL_LONG value, int dp);

extern int cpu_timer;
extern int clock_trap_start;
extern int clock_trap_address;
extern int clock_trap_pp;
extern int last_clock_trap_time;
extern int clock_trap_delta[256];

extern void hex_dump(int a, int bc);
extern void dump_history(void);
extern void dump_state(void);
extern int decode(int ip, int x);
extern char *opcode_name[16];
extern char opcode_type[256];
extern int opcode_count[256];
extern int instruction_count;
extern int enable_trace;
#define HISTORY_MASK 15
extern int history[HISTORY_MASK + 1];
extern int hop[HISTORY_MASK + 1];
extern int ea[HISTORY_MASK + 1];
extern int da[HISTORY_MASK + 1];
extern int hip;

extern int get_ibm_time(void);
extern int get_cpu_time(void);

/* Options and I/O variables */
#define UNITS 31
extern FILE *input_unit[UNITS + 1], *output_unit[UNITS + 1],
    *file_unit[UNITS + 1];
#define OPT_FILL 1
#define OPT_LIMIT 2
#define OPT_TRANSLATE 4
#define OPT_ASCII 8
#define OPT_EBCDIC 16
#define OPT_CRLF 32
#define OPT_NOT 64
extern char input_options[UNITS + 1], output_options[UNITS + 1],
    file_options[UNITS + 1];
extern short input_eol[UNITS + 1];	/* Last end-of-line character */
extern char io_buffer[512];	/* Temporary Output buffer */

extern unsigned char ebcdic[256];	/* ASCII to EBCDIC conversion table */
extern unsigned char ascii[256];	/* EBCDIC to ASCII conversion table */
extern int target_zero;			/* The character '0' from the target */
extern int target_trans;		/* Translate from native to target */

extern char control[256];
extern int xplmon_link[4];
extern int link_address;

/* Debugger */
extern int debugger(void);
extern void debug_init(void);

/* Decimal simulation */
extern void decimal_init(void);
extern int opcode_CVB(int rg);
extern int opcode_CVD(int rg);
extern int opcode_AP(int L1, int L2, unsigned char *D1, unsigned char *D2);
extern int opcode_SP(int L1, int L2, unsigned char *D1, unsigned char *D2);
extern int opcode_CP(int L1, int L2, unsigned char *D1, unsigned char *D2);
extern int opcode_ZAP(int L1, int L2, unsigned char *D1, unsigned char *D2);
extern void opcode_MVO(int L1, int L2, int da, int sa);
extern void opcode_PACK(int L1, int L2, int da, int sa);
extern void opcode_UNPK(int L1, int L2, int da, int sa);
extern void opcode_EDMK(int L1, int D1, int D2, int edmk);

/* Floating point conversion routines. */
typedef struct float_word {
	short sign;		/* The sign */
	short exp;		/* The characteristic.  0-127 is valid */
	XPL_UNSIGNED_LONG fraction;	/* fractional data */
} XPL_FLOAT;

extern double cnv_double(XPL_FLOAT *v);
extern unsigned int cnv_ibm32(double n);
extern void split_long(XPL_FLOAT *v);
extern void split_register(XPL_FLOAT *v, int rg);
extern void split_short(XPL_FLOAT *v, int n);
extern void join_register(XPL_FLOAT *v, int rg);
extern int join_short(XPL_FLOAT *v);
extern void add_unnormalized(XPL_FLOAT *a, XPL_FLOAT *b, XPL_FLOAT *c);
extern void add_normalized(XPL_FLOAT *a, XPL_FLOAT *b, XPL_FLOAT *c);
extern void compare_float(XPL_FLOAT *a, XPL_FLOAT *b);
extern void multiply_float(XPL_FLOAT *a, XPL_FLOAT *b, XPL_FLOAT *c);
extern int divide_float(XPL_FLOAT *a, XPL_FLOAT *b, XPL_FLOAT *c);
