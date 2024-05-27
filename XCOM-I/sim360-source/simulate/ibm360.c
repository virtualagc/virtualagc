/*
**	XPL monitor and simulator for the IBM/360
**
**	This program requires 64-bit integer support
**
**	Author: Daniel Weaver
*/
/*
 * Modifications to Dan Weaver's code:
 * 2024-05-21 RSB   Removed several duplicated globals in favor of system.c.
 */

#include <stdio.h>
#include <string.h>

#include "sim.h"

unsigned char core[CORESIZE + 256];	/* memory storage area */

/* Machine state */
int reg[16];			/* General purpose registers */
int save[16];			/* Clock Trap registers save area */
int cc;				/* Condition codes */
int zone;			/* Decimal arithmetic Zone field 0x30 or 0xF0 */
int pp, npp, codesize, fetch_limit, modpoint, load_point;
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

int msbit = 0x80000000;
int callback = 0x00fffff0;
int trapreturn = 0x00fffff4;
int returnlink = 0x00fffff8;
int jumptable = 0x00ffff00;

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

/*
**	hex_dump(address, byte_count)
**
**	Display a region of memory.
*/
void
hex_dump(int a, int bc)
{
	int i, j;

	for (i = j = 0; i < bc; i++) {
		if (j >= 16) {
			printf("\n");
			j = 0;
		}
		if (j == 0) {
			printf("(%06X) ", a + i);
		}
		if ((j & 3) == 0)
			printf(" ");
		printf("%02X", core[a + i]);
		j++;
	}
	printf("\n");
}

/*
**	decode(x)
**
**	Disassemble one op code.  The data for the opcode is taken from
**	the history log.
**
**	The results are printed on stdout.
*/
int
decode(int ip, int x)
{
	short a, b, c, d, e, f;
	short r1, r2, r3, x2, b1, b2, d1, d2;
	char op[8], text[64];
	char opstring[128];
	int w;

	if (x >= 0) {
		ip = history[x];
		a = core[ip];
		b = core[ip + 1] | hop[x];
	} else {
		a = core[ip];
		b = core[ip + 1];
	}
	opstring[0] = '\0';
	strncpy(op, &opcode_name[(a >> 4)][((a & 15) << 2)], 4);
	op[4] = '\0';
	switch (opcode_type[a]) {
	case 0:
		/* Case 0: __ Unknown */
		{
			sprintf(opstring, "Illegal opcode: %02X\n", a);
			w = 2;
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
			w = 2;
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
			w = 4;
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
			w = 4;
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
			w = 4;
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
			w = 6;
		}
		break;
	default:
		w = 2;
		break;
	}
	printf("%06X %s\n", ip, opstring);
	return ip + w;
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
**	simulator(stepping)
**
**	Fetch the opcode and execute it.
**	This function does all the work.
*/
int
simulator(int stepping)
{
	int k, v, mask;
	int rollback;

	watch_point = ADDRESS_MASK(watch_point_option);
	if (watch_point < CORESIZE) {
		/* Force the Watch Point to trigger */
		watch_point_data = load_word(watch_point) + 1;
		check_watch_point();
	}
	rollback = 0;
	while (0) {
 fetch_next:
		if (stepping) {
			return EXIT_CONTINUE;
		}
	}
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
		if (enable_trace == 2) dump_state();
		decode(0, hip);
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
			/* The debugger can use this as a breakpoint */
			return EXIT_BREAK;
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
			if (xy == 0) return divide_by_zero();
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
				if (xy == 0) return divide_by_zero();
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
