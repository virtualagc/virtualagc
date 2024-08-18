/*
**	Debugger for the IBM/360 Simulator
**
**	Author: Daniel E Weaver
*/
/*
 * Modifications to Dan Weaver's code:
 * 2024-05-21 RSB   Changed some errant bitwise &'s to logical &&'s.
 */

#include <stdio.h>
#include <string.h>
#include <ctype.h>

#ifdef _MSC_VER
#include <stdlib.h>
#else
#include <unistd.h>
#endif

#include "sim.h"

char ident[32];		/* Identifier from the input stream */

char buffer[80];	/* Input buffer */
int cp;			/* Character pointer */
unsigned int bp = -1;	/* Breakpoint */

unsigned char pcm[256];	/* Printable character map */

/*
**	debug_init
**
**	Initialize the debug module
*/
void
debug_init(void)
{
	int i, j;

	for (j = 0; j < 256; j++) {
		pcm[j] = '.';
	}
	if ('0' == 0x30) {
		/* ASCII */
		for (j = ' '; j < 128; j++) {
			pcm[j] = j;
		}
	} else {
		/* EBCDIC */
		for (j = ' '; j < 128; j++) {
			pcm[ebcdic[j]] = j;
		}
	}
	if (0) /* display table */
	for (i = 0; i < 256; i += 16) {
		for (j = 0; j < 16; j++) {
			printf(" %02x", pcm[i + j]);
		}
		printf("\n");
	}
	return;
}

/*
**	core_dump(start-address, end-address)
**
**	Dump a block of core memory.
*/
void
core_dump(int a, int b)
{
	int i, j, k, v, w;
	char c[40];

	a &= 0x00fffffc;
	i = a & 0x00fffff0;
	b &= 0x00ffffff;
	if (b > 0x1000000) b = 0x1000000;
	j = 0;
	while (1) {
		if ((i & 0x0c) == 0) printf("(%06x)", i);
		if (i < a) {
			printf("         ");
			c[j++] = ' ';
			c[j++] = ' ';
			c[j++] = ' ';
			c[j++] = ' ';
		} else {
			w = load_word(i);
			if (return_code != 0) {
				printf(" NO ACCESS");
				break;
			}
			printf(" %08x", w);
			for (k = 0; k < 4; k++) {
				v = (w >> 24) & 255;
				w <<= 8;
				switch (target_trans) {
				case 0:
					/* Do nothing */
					break;
				case 1:
					/* ASCII to EBCDIC */
					v = ebcdic[v];
					break;
				case 2:
					/* EBCDIC to ASCII */
					v = ascii[v];
					break;
				}
				c[j++] = pcm[v];
			}
		}
		i += 4;
		if (i >= b) break;
		if ((i & 0x0c) == 0) {
			c[j] = '\0';
			printf("  %s\r\n", c);
			j = 0;
		}
	}
	for ( ; ((i & 0x0c) != 0); i += 4) {
		printf("         ");
	}
	c[j] = '\0';
	printf("  %s\r\n", c);
}

/*
**	fetch_instruction(address)
**
**	Fetch one byte from memory.
*/
int
fetch_instruction(int a)
{
	return core[a & 0xffffff] & 255;
}

/*
**	opcode_length(op)
**
**	Return the length of the opcode
*/
int
opcode_length(int op)
{
	int format_bytes[6] = {2, 2, 4, 4, 4, 6};

	return format_bytes[opcode_type[op & 255] & 255];
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
			decode(0, k);
		}
	}
	dump_state();
}

/*
**	read_line()
*/
static void
read_line(void)
{
	int x;

	putchar('>');
	putchar(' ');
	for (cp = 0; cp < sizeof(buffer); cp++) {
		x = getchar();
		if (x == EOF) {
			if (isatty(fileno(stdin))) {
				clearerr(stdin);
			}
		}
		if (x == '\n') break;
		buffer[cp] = x;
	}
	buffer[cp] = '\0';
	cp = 0;
}


/*
**	deblank()
*/
static void
deblank(void)
{
	int i, x;

	for (i = 0; buffer[cp]; i++) {
		x = buffer[cp];
		if (x != ' ' && x != '\t') return;
		cp++;
	}
}


/*
**	scan_char()
**
**	Scan an identifier of valid CAN code characters.
*/
static int
scan_char(void)
{
	int i, x;

	for (i = 0; (x = buffer[cp]); i++, cp++) {
		if (i >= sizeof(ident) - 1) break;
		x &= 255;
		x = tolower(x);
		if (islower(x)) ident[i] = x;
		else break;
	}
	ident[i] = '\0';
	return i;
}

/*
**	scan_hex()
**
**	Scan a hexadecimal number.
*/
static int
scan_hex(void)
{
	int x, v;

	for (v = 0; (x = buffer[cp]); cp++) {
		x &= 255;
		x = tolower(x);
		if (x >= '0' && x <= '9') x -= '0';
		else
		if (x >= 'a' && x <= 'f') x -= 'a' - 10;
		else break;
		v = (v << 4) + x;
	}
	return v;
}

/*
**	expr()
**
**	Scan the input stream and return the next expression.
*/
static int
expr(void)
{
	int v, n, c, opcode, cc;

	v = n = 0;
	opcode = '+';
	while (1) {
		c = buffer[cp];
		if (c == '+' || c == '-') {
			opcode = c;
			cp++;
		} else {
			if (c == '$') {
				n = pp;
				cp++;
			} else {
				cc = cp;
				n = scan_hex();
				if (cc == cp) return v;
			}
			if (opcode == '+') v += n;
			else v -= n;
		}
	}
}

void
debug_help(void)
{
	printf("b  [addr]          Set breakpoint\r\n");
	printf("di [addr] [count]  Display instructions\r\n");
	printf("dm [addr] [count]  Display memory\r\n");
	printf("g [addr]           Go.  Start execution\r\n");
	printf("h                  Display history\r\n");
	printf("l [reg]            Single step until the program pointer matches [reg] (default: 12)\r\n");
	printf("mh <addr> [value...] Modify memory (16-bit)\r\n");
	printf("mm <addr> [value...] Modify memory (32-bit)\r\n");
	printf("n                  Step over next instructions\r\n");
	printf("q                  Quit\r\n");
	printf("r                  Register dump\r\n");
	printf("s [count]          Step instructions\r\n");
	printf("trace [n]          Trace 0->off, 1->Instruction, 2->Inst and register\r\n");
	printf("w [addr] [break]   Set watchpoint\r\n");
	printf("?                  Show help\r\n");
	printf("<cr>               Single step\r\n");
}

/*
**	debugger()
*/
int
debugger(void)
{
	int i, j, ret, opcode;
	unsigned int w, x, z;

	printf("Enter debug mode\r\n");
	while (1) {
		return_code = 0;
		read_line();
		deblank();
		scan_char();
		if (strcmp(ident, "b") == 0) {
			deblank();
			if (buffer[cp] == '\0') {
				printf("breakpoint=%06X\r\n", bp);
				continue;
			}
			bp = ADDRESS_MASK(expr());
			continue;
		}
		if (strcmp(ident, "da") == 0) {
			deblank();
			i = ADDRESS_MASK(expr());
			deblank();
			j = ADDRESS_MASK(expr());
			if (j == 0) j = 1;
			core_dump(i, i + j);
			continue;
		}
		if (strcmp(ident, "di") == 0) {
			deblank();
			if (buffer[cp] == '\0') {
				w = x = pp;
			} else {
				w = ADDRESS_MASK(expr());
				deblank();
				x = ADDRESS_MASK(expr() + w);
				if (x < w) x = 0xffffff;
			}
			z = 0;
			while (z < 0x7fff) {
				w = decode(w, -1);
				z = x - w;
				if (return_code != 0) break;
			}
			continue;
		}
		if (strcmp(ident, "dm") == 0) {
			deblank();
			i = ADDRESS_MASK(expr());
			deblank();
			j = ADDRESS_MASK(expr());
			if (j == 0) j = 1;
			core_dump(i, i + j);
			continue;
		}
		if (strcmp(ident, "g") == 0) {
			deblank();
			if (buffer[cp] != '\0') {
				npp = expr();
			}
			while (1) {
				ret = simulator(1);
				if (ret != EXIT_CONTINUE) {
					if (ret == EXIT_BREAK)
						printf("SVC at: %06X\r\n", pp);
					break;
				}
				if (pp == bp) {
					printf("Breakpoint at: %06X\r\n", pp);
					break;
				}
				i = ADDRESS_MASK(pp);
				if (pp != i) {
					printf("$=%08X\r\n", pp);
					break;
				}
				if (return_code == EXIT_BREAK) {
					printf("\r\n");
					break;
				}
			}
			continue;
		}
		if (strcmp(ident, "h") == 0) {
			dump_history();
			continue;
		}
		if (strcmp(ident, "l") == 0) {
			deblank();
			if (buffer[cp] == '\0') j = 12;
			else j = expr() & 15;
			i = ADDRESS_MASK(reg[j]);
			while (pp != i) {
				ret = simulator(1);
				if (ret == EXIT_BREAK) {
					printf("SVC at: %06X\r\n", pp);
					break;
				}
				if (ret != EXIT_CONTINUE) return ret;
			}
			printf("Return link at: %06X\r\n", pp);
			continue;
		}
		if (strcmp(ident, "mh") == 0) {
			deblank();
			i = ADDRESS_MASK(expr());
			for ( ; ; i += 2) {
				deblank();
				j = cp;
				w = expr();
				if (j == cp) break;
				store_halfword(w, i);
				if (return_code != 0) {
					printf("Error at %06X: NO ACCESS\r\n", i);
					break;
				}
			}
			continue;
		}
		if (strcmp(ident, "mm") == 0) {
			deblank();
			i = ADDRESS_MASK(expr());
			for ( ; ; i += 4) {
				deblank();
				j = cp;
				w = expr();
				if (j == cp) break;
				store_word(w, i);
				if (return_code != 0) {
					printf("Error at %06X: NO ACCESS\r\n", i);
					break;
				}
			}
			continue;
		}
		if (strcmp(ident, "n") == 0) {
			opcode = fetch_instruction(pp);
			i = opcode_length(opcode) + pp;
			while (pp != i) {
				ret = simulator(1);
				if (ret == EXIT_BREAK) {
					printf("SVC at: %06X\r\n", pp);
					break;
				}
				if (ret != EXIT_CONTINUE) return ret;
			}
			if (enable_trace == 0) {
				decode(pp, -2);
			}
			continue;
		}
		if (strcmp(ident, "q") == 0) return EXIT_QUIET;
		if (strcmp(ident, "r") == 0) {
			dump_state();
			continue;
		}
		if (strcmp(ident, "s") == 0) {
			if (enable_trace == 0) enable_trace = 1;
			deblank();
			i = expr();
			do {
				ret = simulator(1);
				if (ret == EXIT_BREAK) {
					printf("SVC at: %06X\r\n", pp);
					break;
				}
				if (ret != EXIT_CONTINUE) return ret;
				i--;
			} while(i > 0);
			continue;
		}
		if (strcmp(ident, "trace") == 0) {
			deblank();
			if (buffer[cp] == '\0') {
				printf("trace=%d\r\n", enable_trace);
				continue;
			}
			enable_trace = expr();
			continue;
		}
		if (strcmp(ident, "w") == 0) {
			deblank();
			if (buffer[cp] == '\0') {
				printf("watchpoint=%06X\r\n", watch_point);
				continue;
			}
			watch_point = ADDRESS_MASK(expr());
			deblank();
			watch_point_break = expr();
			watch_point_data = load_word(watch_point) + 1;
			check_watch_point();
			continue;
		}
		if (buffer[cp] == '?') {
			debug_help();
			continue;
		}
		if (ident[0] == '\0') {
			if (enable_trace == 0) enable_trace = 1;
			ret = simulator(1);
			if (ret == EXIT_BREAK) {
				printf("SVC at: %06X\r\n", pp);
				continue;
			}
			if (ret != EXIT_CONTINUE) return ret;
			continue;
		}
		printf("Unknown command: %s\r\n", ident);
	}
}
