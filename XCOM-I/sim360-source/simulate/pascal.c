/*
**	Pascal Loader and Runtime
**
**	Author: Daniel Weaver
*/

#include <stdio.h>
#include <unistd.h>
#include <string.h>
#include <time.h>
#include <sys/time.h>
#include <math.h>

#include "sim.h"

/* Number of bytes reserved for PMD */
#define CODEMNL 65536

/* Definitions for the ORG Segment */
#define HEAP_PTR 0
#define MAX_TOP 4
#define PASCAL_REG(r)  (((r+5)&15)*4 + 208)
#define MONITOR_REG(r)  (r*4 + 228)
#define STACKTOP PASCAL_REG(13)

/* Offsets within the Global activation record */
#define INTFIELDSIZE load_word(ar_base + 32)
#define BOOLFIELDSIZE load_word(ar_base + 36)
#define REALFIELDSIZE load_word(ar_base + 40)
#define LAST_OUTPUT core[ar_base + 31]
#define NEXT_INPUT core[ar_base + 29]

int code_index, transfer_vector_base, max_temp_displ, current_procedure_length;
int high_address;

int org_base;			/* Address of the ORG Segment */
int code_base;			/* Address of the CODE Segment */
int ar_base;			/* Address of the Global Activation record */

/* Buffer for output lines */
static int write_index;
static char write_buffer[512];
static int write_line_count;

/* Input character support */
static int stdin_state;
#define STATE_EOF -1
#define STATE_START 0
#define STATE_READY 1
#define STATE_EOL 2

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
**	get_number(string, length)
**
**	Convert a character string decimal number to an integer.
*/
int
get_number(unsigned char *cp, int len)
{
	int i, n = 0, b;

	for (i = 0; i < len; i++) {
		b = *cp++;
		if (b >= '0' && b <= '9') {
			n = n * 10 + b - '0';
		}
	}
	return n;
}

/*
**	read_block(fd, address, size)
**
**	Read a block of data into the buffer.
**	Size will be rounded up to 80 byte records.
**
**	Return non-zero for error.
*/
int
read_block(int obj, unsigned char *buf, int size)
{
	int len;
	ssize_t bc;

	size = (size + 79) / 80;
	size *= 80;
	for (len = 0; len < size;) {
		bc = read(obj, buf, 80);
		if (bc < 0) {
			return 1;
		}
		if (bc == 0) {	/* EOF */
			return 2;
		}
		buf += bc;
		len += bc;
	}
	return 0;
}

/*
**	pascal_simulation()
**
**	Load the Pascal program and start the simulation.
**
**	returns EXIT_CONTINUE->success, EXIT_ABORT->error
*/
int
pascal_simulation(int obj, char *obj_filename, unsigned char *map)
{
	int stat, codesize, i, v;
	unsigned char *header;

	load_point = CORESIZE - CODEMNL;	/* Load address for PMD */
	header = core;
	pp = 0x100;
	org_base = code_base = 1;
	for (stat = 0; stat == 0;) {
		if (strncmp((char *)org_header, (char *)header, 5) == 0) {
			if (map) {
				for (i = 0; i < 256; i++) {
					header[i] = map[header[i]];
				}
			}
			if (control['v']) {
				printf("%06x: %80.80s\n", pp, header);
			}
			code_index = get_number(header + 5, 5);
			transfer_vector_base = get_number(header + 10, 5);
			max_temp_displ = get_number(header + 15, 5);
			current_procedure_length = get_number(header + 20, 20);

			org_base = pp = (pp + 7) & ~7;
			if (read_block(obj, &core[pp], code_index)) {
				fprintf(stderr, "read() failed: %s\n",
					obj_filename);
				close(obj);
				return EXIT_ABORT;
			}
			pp += code_index;
			pp = (pp + 7) & ~7;
		} else if (strncmp((char *)code_header, (char *)header, 5) == 0) {
			if (map) {
				for (i = 0; i < 256; i++) {
					header[i] = map[header[i]];
				}
			}
			if (control['v']) {
				printf("%06x: %80.80s\n", pp, header);
			}
			if (code_base == 1) {
				code_base = pp;
			}
			codesize = get_number(header + 5, 5);
			stat = read_block(obj, &core[pp], codesize);
			if (stat != 0) {
				break;
			}
			pp += codesize;
		} else {
			ar_base = pp;
			pp += 80;
			break;
		}

		/* Read in the next control record */
		header = &core[pp];
		stat = read_block(obj, &core[pp], 80);
	}
	while (stat == 0) {
		stat = read_block(obj, &core[pp], 80);
		pp += 80;
	}
	close(obj);
	if (stat == 1) {
		fprintf(stderr, "read() failed: %s\n", obj_filename);
		return EXIT_ABORT;
	}
	if (code_base == 1) {
		fprintf(stderr, "%%CODE segment missing: %s\n", obj_filename);
		return EXIT_ABORT;
	}
	if (org_base == 1) {
		fprintf(stderr, "%%ORG segment missing: %s\n", obj_filename);
		return EXIT_ABORT;
	}
	high_address = (pp + 15) & ~15;
	fetch_limit = high_address;
	/* Add the size of the ORG segment to all the Transfer Vectors */
	for (i = transfer_vector_base; i < code_index; i += 4) {
		v = load_word(i + org_base);
		store_word(v + code_base, i + org_base);
	}
	/* Update the ORG Segment */
	store_word(load_point, org_base + HEAP_PTR);
	max_temp_displ = (max_temp_displ + 15) & ~15;	/* alignment */
	store_word(load_point - max_temp_displ, org_base + MAX_TOP);
	store_word(jumptable, org_base + MONITOR_REG(13));

	pp = load_word(transfer_vector_base + org_base);
	link_address = 0x7fffffff;	/* Disable the abort feature */

	/* The Post Mortem Dump program requires a 32 byte block of data
	   that holds base addresses and addresses of important tables in the
	   Pascal program.  The address of this block of data is put into
	   MONITOR_LINK(3) before PMD is called.  The data block is placed at
	   address zero to protect it from modification by the user.  */
	xplmon_link[3] = 0;
	store_word(ar_base, 0);
	store_word(org_base, 4);
	store_word(transfer_vector_base + org_base, 8);
	store_word(code_base, 12);
	store_word(0, 16);	/* Seconds */
	store_word(0x7fffffff, 20);	/* Line */
	store_word(CORESIZE, 24);	/* Used for FREELIMIT in PMD */
	store_word(pp, 28);	/* EXTENTION: Address of error */
	if (control['v']) {
		printf("%06x: Loading done. Start address: %06x\n",
		       high_address, pp);
		printf("High load address: %06X, Heap: %06X, MAX_TOP: %06X\n",
		       high_address, load_word(org_base + HEAP_PTR),
		       load_word(org_base + MAX_TOP));
	}
	/* Set lowest modifiable address */
	modpoint = 0x100;
	if (control['m'] == 0) {
		modpoint = org_base;
		if (control['v']) {
			printf("Read Only memory upper bound %08x\n", modpoint);
		}
	}
	reg[10] = returnlink;	/* Monitor return address */
	reg[11] = ar_base;	/* Global activation record */
	reg[12] = pp;		/* Start of execution */
	reg[13] = high_address;	/* Stack Top */
	reg[14] = ar_base;	/* Current activation record */
	reg[15] = org_base;	/* Point to the ORG Segment */
	write_index = write_line_count = 0;
	LAST_OUTPUT = ' ';
	exit_code = simulator();
	store_word(get_cpu_time(), 16);	/* Seconds */
	store_word(pp, 28);
	return exit_code;
}

/*
**	output_stdout(text)
**
**	output a character string to unit zero.
**
**	returns EXIT_CONTINUE->success, EXIT_ABORT->error
*/
int
output_stdout(char *text)
{
	if (!output_unit[0]) {
		fprintf(stderr, "output unit %d is not open\n", 0);
		return EXIT_ABORT;
	}
	fprintf(output_unit[0], "%s\n", text);
	return EXIT_CONTINUE;
}

/*
**	read_from_stdin()
**
**	Read the next character from the input stream and
**	put it into NEXT_INPUT.  Also set stdin_state.
**	This function handles all four permutations of <CR><LF>
**	The DOS option on the command line is not needed.
*/
void
read_from_stdin(void)
{
	int c;

	while (stdin_state != STATE_EOF) {
		c = getc(input_unit[0]);
		if (c == EOF) {
			input_eol[0] = 0;
			NEXT_INPUT = ' ';
			stdin_state = STATE_EOF;
		} else
		if (c == '\n') {
			if (input_eol[0] == '\r') {
				/* <CR><LF> */
				input_eol[0] = 0;
				continue;
			}
			input_eol[0] = '\n';
			NEXT_INPUT = ' ';
			stdin_state = STATE_EOL;
		} else
		if (c == '\r') {
			if (input_eol[0] == '\n') {
				/* <LF><CR> */
				input_eol[0] = 0;
				continue;
			}
			input_eol[0] = '\r';
			NEXT_INPUT = ' ';
			stdin_state = STATE_EOL;
		} else {
			input_eol[0] = 0;
			NEXT_INPUT = c;
			stdin_state = STATE_READY;
		}
		return;
	}
}

/*
**	skip_blanks()
**
**	Discard blanks in the input stream.
*/
void
skip_blanks(void)
{
	while (stdin_state == STATE_READY) {
		if (NEXT_INPUT == ' ') {
			read_from_stdin();
		} else {
			return;
		}
	}
}

/*
**	start_reading_stdin()
**
**	If this is the first access then read one character and
**	put it into NEXT_INPUT.  Set the value of stdin_state.
**
**	returns EXIT_CONTINUE->success, EXIT_ABORT->error
*/
int
start_reading_stdin(void)
{
	if (stdin_state == STATE_START) {
		if (!input_unit[0]) {
			fprintf(stderr, "input unit %d is not open\n", 0);
			NEXT_INPUT = ' ';
			stdin_state = STATE_EOF;
			return EXIT_ABORT;
		}
		read_from_stdin();
	}
	return EXIT_CONTINUE;
}

/*
**	pascal_runtime(entry_address)
**
**	A call to the Pascal runtime.
**
**	Return EXIT_CONTINUE->success, EXIT_ABORT->error
*/
int
pascal_runtime(int ea)
{
	int i, j, k, v, w;
	char *txt, buffer[256];
	unsigned int n;
	XPL_FLOAT fx;
	double fval;

	i = ((ea & 255) >> 2) - 18;
	switch (i) {
	case 0:
		/* f[0] = SIN(f[6]); */

		split_short(&fx, (int) f[6]);
		fval = sin(cnv_double(&fx));
		f[0] = cnv_ibm32(fval);

		reg[13] = load_word(org_base + PASCAL_REG(13));
		return EXIT_CONTINUE;
	case 1:
		/* f[0] = COS(f[6]); */

		split_short(&fx, (int) f[6]);
		fval = cos(cnv_double(&fx));
		f[0] = cnv_ibm32(fval);

		reg[13] = load_word(org_base + PASCAL_REG(13));
		return EXIT_CONTINUE;
	case 2:
		/* f[0] = ARCTAN(f[6]); */

		split_short(&fx, (int) f[6]);
		fval = atan(cnv_double(&fx));
		f[0] = cnv_ibm32(fval);

		reg[13] = load_word(org_base + PASCAL_REG(13));
		return EXIT_CONTINUE;
	case 3:
		/* f[0] = EXP(f[6]); */

		split_short(&fx, (int) f[6]);
		fval = exp(cnv_double(&fx));
		f[0] = cnv_ibm32(fval);

		reg[13] = load_word(org_base + PASCAL_REG(13));
		return EXIT_CONTINUE;
	case 4:
		/* f[0] = LN(f[6]); */

		split_short(&fx, (int) f[6]);
		fval = log(cnv_double(&fx));
		f[0] = cnv_ibm32(fval);

		reg[13] = load_word(org_base + PASCAL_REG(13));
		return EXIT_CONTINUE;
	case 5:
		/* f[0] = SQRT(f[6]); */

		split_short(&fx, (int) f[6]);
		fval = sqrt(cnv_double(&fx));
		f[0] = cnv_ibm32(fval);

		reg[13] = load_word(org_base + PASCAL_REG(13));
		return EXIT_CONTINUE;
	case 13:
		/* reg[9] = EOLN(); */

		exit_code = start_reading_stdin();
		if (exit_code == EXIT_ABORT) {
			return exit_code;
		}
		if (stdin_state == STATE_EOF) {
			reg[9] = 1;
		} else
		if (stdin_state == STATE_EOL) {
			reg[9] = 1;
		} else {
			reg[9] = 0;
		}
		break;
	case 14:
		/* reg[9] = EOF(); */

		exit_code = start_reading_stdin();
		if (exit_code == EXIT_ABORT) {
			return exit_code;
		}
		if (stdin_state == STATE_EOF) {
			reg[9] = 1;
		} else {
			reg[9] = 0;
		}
		break;
	case 15:
		/* reg[9] = NEW(reg[9]); */

		j = (reg[9] + 3) & ~3;	/* Round up */
		v = load_word(org_base + HEAP_PTR) - j;
		store_word(reg[9] = v, org_base + HEAP_PTR);
		v = load_word(org_base + MAX_TOP) - j;
		store_word(v, org_base + MAX_TOP);
		w = load_word(org_base + STACKTOP);
		if (v < w) {
			printf("Error at %08X: Heap memory overflow\n", pp);
			return EXIT_ABORT;
		}
		break;
	case 17:
		/* GET(); */

		exit_code = start_reading_stdin();
		if (exit_code == EXIT_ABORT) {
			return exit_code;
		}
		if (stdin_state == STATE_READY) {
			read_from_stdin();
		}
		break;
	case 18:
		/* PUT(*reg[9]); */

		w = ADDRESS_MASK(reg[9]);
		if (w >= CORESIZE) {
			printf("Error at %08X: Address range error: %08X\n",
			       pp, w);
			return EXIT_ABORT;
		}
		if (write_index < 256) {
			write_buffer[write_index++] = core[w + 1];
		}
		break;
	case 21:
		/* reg[9] = READINT(); */

		exit_code = start_reading_stdin();
		if (exit_code == EXIT_ABORT) {
			return exit_code;
		}
		skip_blanks();
		for (j = 0; stdin_state == STATE_READY; ) {
			if (NEXT_INPUT == '+') {
				j = 0;
			} else
			if (NEXT_INPUT == '-') {
				j = 1;
			} else {
				break;
			}
			read_from_stdin();
		}
		for (n = 0; stdin_state == STATE_READY; ) {
			v = NEXT_INPUT - '0';
			if (v >= 0 && v <= 9) {
				n = (n * 10) + v;
			} else {
				break;
			}
			read_from_stdin();
		}
		if (j) {
			n = -n;
		}
		reg[9] = n;
		break;
	case 23:
		/* reg[9] = READ_CHAR(); */

		exit_code = start_reading_stdin();
		if (exit_code == EXIT_ABORT) {
			return exit_code;
		}
		reg[9] = NEXT_INPUT;
		if (stdin_state == STATE_READY) {
			read_from_stdin();
		}
		break;
	case 24:
		/* WRITE_INT(reg[8]); */

		sprintf(buffer, "%d", reg[8]);
		j = strlen(buffer);
		k = INTFIELDSIZE;
		for (i = j; i < k && write_index < 256; i++) {
			write_buffer[write_index++] = ' ';
		}
		for (i = 0; i < j && write_index < 256; i++) {
			write_buffer[write_index++] = buffer[i];
		}
		LAST_OUTPUT = write_buffer[write_index];
		break;
	case 25:
		/* WRITE_REAL(f[6]); */

		split_register(&fx, 6);
		sprintf(buffer, "%g", cnv_double(&fx));
		j = strlen(buffer);
		k = REALFIELDSIZE;
		for (i = j; i < k && write_index < 256; i++) {
			write_buffer[write_index++] = ' ';
		}
		for (i = 0; i < j && write_index < 256; i++) {
			write_buffer[write_index++] = buffer[i];
		}
		LAST_OUTPUT = write_buffer[write_index];
		break;
	case 26:
		/* WRITE_BOOL(reg[8]); */

		if (reg[8] == 0) {
			txt = "FALSE";
			j = 5;
		} else {
			txt = "TRUE";
			j = 4;
		}
		k = BOOLFIELDSIZE;
		for (i = j; i < k && write_index < 256; i++) {
			write_buffer[write_index++] = ' ';
		}
		for (i = 0; i < j && write_index < 256; i++) {
			write_buffer[write_index++] = txt[i];
		}
		LAST_OUTPUT = write_buffer[write_index];
		break;
	case 27:
		/* WRITE_CHAR(reg[8]); */

		if (write_index < 256) {
			write_buffer[write_index++] = reg[8];
		}
		LAST_OUTPUT = write_buffer[write_index];
		break;
	case 28:
		/* WRITE_STRING(reg[8]); */
		/* Reg[8] is an XPL style string descriptor. */

		if (reg[8] == 0)
			break;
		w = reg[8] & 0xffffff;
		j = ((reg[8] >> 24) & 0xff) + 1;
		for (i = 0; i < j; i++) {
			if (write_index >= 256) {
				break;
			}
			if (w >= CORESIZE) {
				printf
				    ("Error at %08X: Address range error: %08X\n",
				     pp, w);
				return EXIT_ABORT;
			}
			write_buffer[write_index++] = core[w++];
		}
		LAST_OUTPUT = write_buffer[write_index];
		break;
	case 29:
		/* READLN(); */

		exit_code = start_reading_stdin();
		if (exit_code == EXIT_ABORT) {
			return exit_code;
		}
		while (stdin_state == STATE_READY) {
			read_from_stdin();
		}
		if (stdin_state == STATE_EOL) {
			stdin_state = STATE_START;
		}
		break;
	case 30:
		/* WRITELN(); */

		if (write_index == 0) break;
		write_line_count++;
		write_buffer[write_index] = 0;
		exit_code = output_stdout(write_buffer);
		write_index = 0;
		LAST_OUTPUT = ' ';
		if (exit_code == EXIT_CONTINUE) break;
		return exit_code;
	case 31:
		/* PAGE(); */

		if (write_index == 0) break;
		write_line_count++;
		write_buffer[write_index] = 0;
		exit_code = output_stdout(write_buffer);
		write_index = 0;
		LAST_OUTPUT = '1';
		if (exit_code == EXIT_CONTINUE) break;
		return exit_code;
	case 32:
		pp = ADDRESS_MASK(reg[10]);
		printf("Error at %08X: Value out of range\n", pp);
		return EXIT_ABORT;
	case 33:
		pp = ADDRESS_MASK(reg[10]);
		printf("Error at %08X: Run-Time storage overflow\n", pp);
		return EXIT_ABORT;
	case 35:
		/* reg[9] = CLOCK(); */

		reg[9] = get_cpu_time();
		break;
	default:
		pp = ADDRESS_MASK(reg[10]);
		printf("Error at %08X: Pascal runtime module %d unimplemented\n", pp, i);
		return EXIT_ABORT;
	}
	check_watch_point();
	reg[11] = load_word(org_base + PASCAL_REG(11));
	reg[12] = load_word(org_base + PASCAL_REG(12));
	reg[13] = load_word(org_base + PASCAL_REG(13));
	return EXIT_CONTINUE;
}
