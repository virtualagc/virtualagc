/*
**	Floating point conversion routines.
**
**	Author: Daniel Weaver
*/
/*
 * 2024-08-18 RSB	Some casts in a printf to avoid Visual Studio warnings.
 */

#include <math.h>
#include <float.h>
#include <stdio.h>
#include <stdlib.h>

#include "sim.h"

static XPL_UNSIGNED_LONG msByte = UINT64_C(0xff00000000000000);
static XPL_UNSIGNED_LONG hexNorm = UINT64_C(0x00f0000000000000);

/*
**  Convert a 64-bit IBM/360 float number to native floating point format.
*/
double
cnv_double(XPL_FLOAT *v)
{
	double value;

	if (v->fraction == 0) {
		return 0.0;
	}
	value = ldexp(v->fraction, (v->exp << 2) - 312);
	if (v->sign != 0) {
		return (-value);
	}
	return value;
}

/*
**  Convert a 64-bit floating point number to 32-bit IBM/360 format.
*/
unsigned int
cnv_ibm32(double n)
{
	int exp = 0, sb;
	XPL_LONG sign, value;
	double mantissa;

	sb = signbit(n);
	if (n == 0.0) {
		return sb ? 0x80000000 : 0;
	}
	if (n < 0.0) {
		sign = INT64_C(0x8000000000000000);
		n = -n;
	} else {
		sign = 0;
	}
	mantissa = frexp(n, &exp);
	exp += 256;
	value = mantissa * INT64_C(0x0100000000000000);
	if (exp & 3) {
		value = value >> (4 - (exp & 3));
		exp += 3;
	}
	if (exp <= 0) {
		exp = 0;
	} else {
		exp >>= 2;
		if (exp & ~0x7f) {
			exp = 0x7f;	/* Overflow */
		}
	}
	value |= sign | (((XPL_LONG)exp) << 56);
	return (unsigned int) (value >> 32);
}

/*
**	print_float(v)
**
**	Print the internal represenattion.
*/
void
print_float(XPL_FLOAT *v)
{
	printf("%c %04x %016lx %-8lg", v->sign ? '-' : '+', (unsigned) v->exp & 0xffff,
		(unsigned long) v->fraction, cnv_double(v));
}

/*
**	split_long(XPL_FLOAT *v)
**
**	Fetch a 64-bit floating point value from memory and
**	split it into an XPL_FLOAT structure.
*/
void
split_long(XPL_FLOAT *v)
{
	XPL_UNSIGNED_LONG n;

	n = load_double(mem_address);
	v->sign = (short) ((n >> 63) & 1);
	v->exp = (short) ((n >> 56) & 127);
	v->fraction = n & UINT64_C(0x00ffffffffffffff);
}

/*
**	split_register(XPL_FLOAT *v, int n)
**
**	Split a long floating point register into a XPL_FLOAT structure.
*/
void
split_register(XPL_FLOAT *v, int rg)
{
	v->sign = (short) ((f[rg] >> 31) & 1);
	v->exp = (short) ((f[rg] >> 24) & 127);
	v->fraction = (XPL_UNSIGNED_LONG) (f[rg] & 0x00ffffff);
	v->fraction <<= 32;
	v->fraction |= f[rg + 1];
}

/*
**	split_short(XPL_FLOAT *v, int n)
**
**	Split a short floating point value into a XPL_FLOAT structure.
*/
void
split_short(XPL_FLOAT *v, int n)
{
	v->sign = (short) ((n >> 31) & 1);
	v->exp = (short) ((n >> 24) & 127);
	v->fraction = (XPL_UNSIGNED_LONG) (n & 0x00ffffff);
	v->fraction <<= 32;
}

/*
**	join_register(XPL_FLOAT *v, int n)
**
**	Recombine a XPL_FLOAT structure and store it into a floating point register.
*/
void
join_register(XPL_FLOAT *v, int rg)
{
	unsigned int n;

	n = (v->sign << 7) | (v->exp & 127);
	f[rg] = (n << 24) | ((unsigned int) (v->fraction >> 32));
	f[rg + 1] = (unsigned int) v->fraction;
}

/*
**	join_short(XPL_FLOAT *v)
**
**	Recombine a XPL_FLOAT structure into a short floating point value.
*/
int
join_short(XPL_FLOAT *v)
{
	unsigned int n;

	n = (v->sign << 7) | (v->exp & 127);
	n = (n << 24) | ((unsigned int) (v->fraction >> 32));
	return (int) n;
}

/*
**	normalize(XPL_FLOAT *v)
**
**	Normalize the floating point number.
**	The result is stored back into the number.
*/
void
normalize(XPL_FLOAT *v)
{
	if (v->fraction == 0) {
		/* Zero cannot be normalized */
		v->sign = 0;
		v->exp = 0;
		return;
	}
	/* Check for right shifting */
	while ((v->fraction & msByte) != 0) {
		v->fraction >>= 4;
		v->exp++;
	}
	/* Check for left shifting */
	while ((v->fraction & hexNorm) == 0) {
		v->fraction <<= 4;
		v->exp--;
		if (v->exp < -256) {
			break;
		}
	}
}

/*
**	normalize_double(XPL_FLOAT *v, XPL_UNSIGNED_LONG b)
**
**	Normalize a 128 bit floating point number.
**	The result is stored back into the structure.
*/
static void
normalize_double(XPL_FLOAT *v, XPL_UNSIGNED_LONG b)
{
	XPL_UNSIGNED_LONG h;

	if (v->fraction == 0 && b == 0) {
		/* Zero cannot be normalized */
		return;
	}
	/* Check for right shifting */
	while ((v->fraction & msByte) != 0) {
		h = v->fraction & 15;
		v->fraction >>= 4;
		b = (b >> 4) + (h << 60);
		v->exp++;
	}
	/* Check for left shifting */
	while ((v->fraction & hexNorm) == 0) {
		h = (b >> 60) & 15;
		v->fraction = (v->fraction << 4) + h;
		b <<= 4;
		v->exp--;
		if (v->exp < -256) {
			break;
		}
	}
}

/*
**	subtract_simulate(a, b, c)
**
**	Subtract two 64-bit floating point numbers.
*/
static void
subtract_simulate(XPL_FLOAT *a, XPL_FLOAT *b, XPL_FLOAT *c)
{
	XPL_LONG value;

	c->exp = a->exp;
	if (a->exp > b->exp) {
		if (a->exp - b->exp > 14) {
			c->fraction = a->fraction;
			return;
		}
		b->fraction >>= (a->exp - b->exp) << 2;
	} else
	if (a->exp < b->exp) {
		c->exp = b->exp;
		if (b->exp - a->exp > 14) {
			c->sign = b->sign;
			c->fraction = b->fraction;
			return;
		}
		a->fraction >>= (b->exp - a->exp) << 2;
	}
	value = (XPL_LONG) (a->fraction - b->fraction);
	if (value < 0) {
		value = -value;
		c->sign = c->sign ^ 1;
	}
	c->fraction = (XPL_UNSIGNED_LONG) value;
}

/*
**	add_simulate(a, b, c)
**
**	Add two 64-bit floating point numbers.
*/
static void
add_simulate(XPL_FLOAT *a, XPL_FLOAT *b, XPL_FLOAT *c)
{
	c->exp = a->exp;
	if (a->exp > b->exp) {
		if (a->exp - b->exp > 14) {
			c->fraction = a->fraction;
			return;
		}
		b->fraction >>= (a->exp - b->exp) << 2;
	} else
	if (a->exp < b->exp) {
		c->exp = b->exp;
		if (b->exp - a->exp > 14) {
			c->fraction = b->fraction;
			return;
		}
		a->fraction >>= (b->exp - a->exp) << 2;
	}
	c->fraction = a->fraction + b->fraction;
}

/*
**	add_unnormalized(a, b, c)
**
**	Add two 64-bit floating point numbers.
**	Set the condition codes.
*/
void
add_unnormalized(XPL_FLOAT *a, XPL_FLOAT *b, XPL_FLOAT *c)
{
	c->sign = a->sign;
	if (a->sign == b->sign) {
		add_simulate(a, b, c);
	} else {
		subtract_simulate(a, b, c);
	}
	/* Check for right shifting */
	while ((c->fraction & msByte) != 0) {
		c->fraction >>= 4;
		c->exp++;
	}
	if (c->fraction == 0) {
		/* Return ture zero */
		c->sign = 0;
		c->exp = 0;
	}
	if (c->exp < 0 || c->exp > 127) {
		cc = CC_OV;
		return;
	}
	if (c->sign) {
		cc = CC_LT;
		return;
	}
	if (c->fraction == 0) {
		cc = CC_EQ;
		return;
	}
	cc = CC_GT;
}

/*
**	add_normalized(a, b, c)
**
**	Add two 64-bit floating point numbers.  Normalize the result.
**	Set the condition codes.
*/
void
add_normalized(XPL_FLOAT *a, XPL_FLOAT *b, XPL_FLOAT *c)
{
	add_unnormalized(a, b, c);
	normalize(c);
	if (c->exp < 0) {
		/* Return ture zero */
		c->sign = 0;
		c->exp = 0;
		c->fraction = 0;
		cc = CC_OV;
		return;
	}
	if (c->exp > 127) {
		cc = CC_OV;
		return;
	}
	if (c->sign) {
		cc = CC_LT;
		return;
	}
	if (c->fraction == 0) {
		cc = CC_EQ;
		return;
	}
	cc = CC_GT;
}

/*
**	compare_float(a, b, c)
**
**	Compare two 64-bit floating point numbers.
*/
void
compare_float(XPL_FLOAT *a, XPL_FLOAT *b)
{
	int less_than;

	normalize(a);
	normalize(b);
	if (a->sign < b->sign) {
		cc = CC_GT;
		return;
	}
	if (a->sign > b->sign) {
		cc = CC_LT;
		return;
	}
	less_than = (a->sign == 0) ? CC_LT : CC_GT;
	if (a->exp > b->exp) {
		cc = less_than ^ 3;
		return;
	}
	if (a->exp < b->exp) {
		cc = less_than;
		return;
	}
	if (a->fraction > b->fraction) {
		cc = less_than ^ 3;
		return;
	}
	if (a->fraction < b->fraction) {
		cc = less_than;
		return;
	}
	cc = CC_EQ;
}

/*
**	simulate_64x64_128(a, b, hi, low)
**
**	Multiply two 64-bit numbers giving a 128-bit result
*/
static void
simulate_64x64_128(XPL_UNSIGNED_LONG op1, XPL_UNSIGNED_LONG op2,
	XPL_UNSIGNED_LONG *hi, XPL_UNSIGNED_LONG *lo)
{
	XPL_UNSIGNED_LONG u1 = (op1 & 0xffffffff);
	XPL_UNSIGNED_LONG v1 = (op2 & 0xffffffff);
	XPL_UNSIGNED_LONG t = (u1 * v1);
	XPL_UNSIGNED_LONG w3 = (t & 0xffffffff);
	XPL_UNSIGNED_LONG k = (t >> 32);
	XPL_UNSIGNED_LONG w1;

	op1 >>= 32;
	t = (op1 * v1) + k;
	k = (t & 0xffffffff);
	w1 = (t >> 32);

	op2 >>= 32;
	t = (u1 * op2) + k;
	k = (t >> 32);

	*hi = (op1 * op2) + w1 + k;
	*lo = (t << 32) + w3;
}

/*
**	multiply_float(a, b, c)
**
**	Multiply two 64-bit floating point numbers.
*/
void
multiply_float(XPL_FLOAT *a, XPL_FLOAT *b, XPL_FLOAT *c)
{
	XPL_UNSIGNED_LONG low;

	if (a->fraction == 0) {
		/* Return true zero */
		c->sign = 0;
		c->exp = 0;
		c->fraction = 0;
		return;
	}
	if (b->fraction == 0) {
		/* Return true zero */
		c->sign = 0;
		c->exp = 0;
		c->fraction = 0;
		return;
	}
	c->sign = a->sign ^ b->sign;
	normalize(a);
	normalize(b);
	simulate_64x64_128(a->fraction, b->fraction, &c->fraction, &low);
	c->exp = a->exp + b->exp - 62;
	normalize_double(c, low);
	if (c->fraction == 0) {
		/* Return ture zero */
		c->sign = 0;
		c->exp = 0;
	}
}

/*
**	simulate_long_divide(dividend, divisor, quotient_high, quotient_low)
**
**	Divide two 64-bit numbers giving a 128-bit result
*/
static void
simulate_long_divide(XPL_UNSIGNED_LONG dividendLow, XPL_UNSIGNED_LONG divisor,
	XPL_UNSIGNED_LONG *hi, XPL_UNSIGNED_LONG *lo)
{
	XPL_UNSIGNED_LONG dividendHigh, Qhigh, Qlow, x;
	int i;

	Qhigh = Qlow = dividendHigh = 0;
	for (i = 0; i < 128; i++) {
		x = (Qlow >> 63) & 1;
		Qhigh = (Qhigh << 1) | x;
		Qlow <<= 1;

		x = (dividendLow >> 63) & 1;
		dividendHigh = (dividendHigh << 1) | x;
		dividendLow <<= 1;

		if (dividendHigh >= divisor) {
			dividendHigh -= divisor;
			Qlow |= 1;
		}
	}
	*hi = Qhigh;
	*lo = Qlow;
}



/*
**	divide_float(a, b, c)
**
**	Divide two 64-bit floating point numbers.
**	return EXIT_ABORT if divide by zero.
*/
int
divide_float(XPL_FLOAT *a, XPL_FLOAT *b, XPL_FLOAT *c)
{
	XPL_UNSIGNED_LONG low;

	if (b->fraction == 0) {
		/* Divide by zero */
		c->sign = 0;
		c->exp = 0;
		c->fraction = 0;
		return EXIT_ABORT;
	}
	if (a->fraction == 0) {
		/* Return true zero */
		c->sign = 0;
		c->exp = 0;
		c->fraction = 0;
		return EXIT_CONTINUE;
	}
	c->sign = a->sign ^ b->sign;
	normalize(a);
	normalize(b);
	simulate_long_divide(a->fraction, b->fraction, &c->fraction, &low);
	c->exp = a->exp - b->exp + 78;
	normalize_double(c, low);

	if (c->fraction == 0) {
		/* Return ture zero */
		c->sign = 0;
		c->exp = 0;
	}
	return EXIT_CONTINUE;
}

/*
**	opcode_CVB(reg)
**
**	Simulate the CVB OP-code
*/
int
opcode_CVB(int rg)
{
	XPL_LONG x, y;
	int i, j;

	y = load_double(mem_address);
	x = 0;
	for (i = 60; i > 0; i -= 4) {
		j = (int)((y >> i) & 15);
		if (j >= 10) {
			fprintf(stderr, "Illegal decimal digit at: %08X\n",
				mem_address);
			hex_dump(0x530, 32);
			hex_dump(mem_address, 32);
			return EXIT_ABORT;
		}
		x = x * 10 + j;
	}
	j = (int)(y & 15);
	switch (j) {
	case 10:
	case 12:
		/* Positive number */
		break;
	case 11:
	case 13:
		/* Negative number */
		x = -x;
		break;
	default:
		fprintf(stderr, "Illegal decimal sign at: %08X\n", mem_address);
		return EXIT_ABORT;
	}
	j = x;
	if (x != j) {
		fprintf(stderr, "Decimal conversion overflow at: %08X\n",
			mem_address);
		return EXIT_ABORT;
	}
	reg[rg] = j;
	return EXIT_CONTINUE;
}

static short bin2pack[200];	/* Convert 0 to 99 to packed decimal format */
static short pack2bin[256];	/* Convert 8 bits of packed decimal to the numbers 0 thru 99 */
static short valid_sign[256];	/* Test for valid sign codes */

/*
**	decimal_init()
**
**	Initialize the tables: bin2pack[], pack2bin[] and valid_sign[].
**	These tables are used to do packed decimal arithmetic.
*/
void
decimal_init(void)
{
	int i, j;
	static int sign_code[6] = { 0x0C, 0x0D, 0x0C, 0x0D, 0x0C, 0x0C };

	for (i = 0; i < 256; i++) {
		pack2bin[i] = -1;	/* Flag all values as an error */
		valid_sign[i] = -1;	/* Flag all values as an error */
	}
	for (i = 0; i < 10; i++) {
		for (j = 0; j < 10; j++) {
			pack2bin[(i << 4) + j] = i * 10 + j;
			bin2pack[i * 10 + j] = (i << 4) + j;
			bin2pack[i * 10 + j + 100] = (i << 4) + j + 256;
		}
	}
	for (i = 0; i < 0xa0; i += 16) {
		for (j = 0; j < 6; j++) {
			valid_sign[i + j + 10] = sign_code[j];
		}
	}
}

/*
**	decimal_fetch(length, source, destination)
**
**	Read a packed decimal number and convert it to binary.
**
**	Return non-zero for invalid digits
*/
int
decimal_fetch(int len, unsigned char *p, unsigned char *b)
{
	int i, j, v;

	j = 15 - len;
	for (i = 0; i < j; i++) {
		*b++ = 0;
	}
	for (; i < 15; i++) {
		v = pack2bin[*p];
		if (v < 0) {
			printf("Illegal packed decimal digits: %02x\n", *p);
			return EXIT_ABORT;
		}
		p++;
		*b++ = (unsigned char)v;
	}
	v = valid_sign[*p];
	if (v < 0) {
		printf("Illegal packed decimal digit/sign: %02x\n", *p);
		return EXIT_ABORT;
	}
	*b++ = (unsigned char)pack2bin[*p & 0xf0];
	*b = (unsigned char)v;
	return EXIT_CONTINUE;
}

/*
**	decimal_store(length, source, destination)
**
**	Write a packed decimal number to memory.
*/
void
decimal_store(int len, unsigned char *p, unsigned char *b)
{
	int i, j, v, z;

	j = 15 - len;
	for (i = v = 0; i < j; i++) {
		v |= *p++;
	}
	if (v) cc = CC_OV;
	for (z = v; j < 15; j++) {
		z |= *p;
		*b++ = *p++;
	}
	z |= *p;
	if (z == 0) {
		p[1] &= 0x0E;
	} else if (cc != CC_OV) {
		if (p[1] & 1) cc = CC_LT;
		else cc = CC_GT;
	}
	*b = *p | p[1];
	check_watch_point();
}

/*
**	decimal_add(augend, addend, sum)
**
**	Add two 16 byte packed decimal numbers.
**	The sign is coppied from the first operand.
**
**	Set the Overflow condition on overflow.
*/
void
decimal_add(unsigned char *a, unsigned char *b, unsigned char *c)
{
	int i, v, carry;

	carry = 0;
	for (i = 15; i >= 0; i--) {
		v = a[i] + b[i] + carry;
		carry = bin2pack[v];
		c[i] = carry;
		carry >>= 8;
	}
	c[16] = a[16];
	if (carry)
		cc = CC_OV;
}

/*
**	decimal_subtract(minuend, subtrahend, difference)
**
**	Subtract 16 byte packed decimal numbers.
**	The sign is coppied from the minuend.
*/
void
decimal_subtract(unsigned char *a, unsigned char *b, unsigned char *c)
{
	int i, v, borrow;

	borrow = 0;
	for (i = 15; i >= 0; i--) {
		v = a[i] - b[i] - borrow;
		borrow = bin2pack[v + 100];
		c[i] = borrow;
		borrow = (borrow >> 8) ^ 1;
	}
	c[16] = a[16];
	if (borrow) {
		/* Flip the sign bit */
		c[16] ^= 1;
	}
}

/*
**	opcode_AP(length1, length2, data1, data2)
**
**	Add packed decimal.
**	The result is stored in data1.
*/
int
opcode_AP(int L1, int L2, unsigned char *D1, unsigned char *D2)
{
	unsigned char a[17], b[17], c[17];

	if (decimal_fetch(L1, D1, a))
		return EXIT_ABORT;
	if (decimal_fetch(L2, D2, b))
		return EXIT_ABORT;

	cc = CC_EQ;
	if (a[16] == b[16]) {
		decimal_add(a, b, c);
	} else {
		decimal_subtract(a, b, c);
	}
	decimal_store(L1, c, D1);
	return EXIT_CONTINUE;
}

/*
**	opcode_SP(length1, length2, data1, data2)
**
**	Subtract packed decimal.
**	The result is stored in data1.
*/
int
opcode_SP(int L1, int L2, unsigned char *D1, unsigned char *D2)
{
	unsigned char a[17], b[17], c[17];

	if (decimal_fetch(L1, D1, a))
		return EXIT_ABORT;
	if (decimal_fetch(L2, D2, b))
		return EXIT_ABORT;

	cc = CC_EQ;
	b[16] ^= 1;
	if (a[16] == b[16]) {
		decimal_add(a, b, c);
	} else {
		decimal_subtract(a, b, c);
	}
	decimal_store(L1, c, D1);
	return EXIT_CONTINUE;
}

/*
**	opcode_CP(length1, length2, data1, data2)
**
**	Compare packed decimal.
**	Sets the condition codes.  The data is not modified.
*/
int
opcode_CP(int L1, int L2, unsigned char *D1, unsigned char *D2)
{
	unsigned char a[17], b[17], c[17];

	if (decimal_fetch(L1, D1, a))
		return EXIT_ABORT;
	if (decimal_fetch(L2, D2, b))
		return EXIT_ABORT;

	b[16] ^= 1;
	if (a[16] == b[16]) {
		decimal_add(a, b, c);
	} else {
		decimal_subtract(a, b, c);
	}
	cc = CC_EQ;
	decimal_store(15, c, a);
	return EXIT_CONTINUE;
}

/*
**	opcode_ZAP(length1, length2, data1, data2)
**
**	Zero add packed decimal.
**	Add a packed decimal number to zero.
**	The result is stored in data1.
*/
int
opcode_ZAP(int L1, int L2, unsigned char *D1, unsigned char *D2)
{
	unsigned char a[17], b[17], c[17], i;

	if (decimal_fetch(L2, D2, b))
		return EXIT_ABORT;

	for (i = 0; i < 16; i++) {
		a[i] = 0;
	}
	a[16] = 0x0C;

	cc = CC_EQ;
	if (a[16] == b[16]) {
		decimal_add(a, b, c);
	} else {
		decimal_subtract(a, b, c);
	}
	decimal_store(L1, c, D1);
	return EXIT_CONTINUE;
}

/*
**	opcode_MVO()
**
**	Move with offset.  Used for decimal right and left shift.
*/
void
opcode_MVO(int L1, int L2, int da, int sa)
{
	int i, j, v;

	v = 0;
	da += L1;
	sa += L2;
	i = (L1 << 1);
	j = (L2 << 1);
	core[da] &= 15;
	for ( ; i >= 0 && j >= 0; i--, j--) {
		if ((j & 1) == 0) v = core[sa--];
		if ((i & 1) == 1) core[da] = v & 15;
		else core[da--] |= v << 4;
		v >>= 4;
	}
	for ( ; i >= 0; i--) {
		if ((i & 1) == 1) core[da] = v & 15;
		else core[da--] |= v << 4;
		v = 0;
	}
}

/*
**	opcode_PACK()
**
**	Convert from Zoned to Packed Decimal format
*/
void
opcode_PACK(int L1, int L2, int da, int sa)
{
	unsigned char field[20];
	int i, k;

	k = L2;
	field[18] = core[sa + k] >> 4;  /* sign */
	for (i = 17; k >= 0; ) {
		field[i--] = core[sa + k--] & 15;
	}
	while (i >= 0) {
		field[i--] = 0;
	}
	k = L1;
	core[da + k] = (field[17] << 4) + field[18];
	for (k--, i = 16; k >= 0 && i >= 0; k--) {
		core[da + k] = (field[i - 1] << 4) + field[i];
		i -= 2;
	}
	for ( ; k >= 0; k--) {
		core[da + k] = 0;
	}
}

/*
**	opcode_UNPK()
**
**	Convert from Packed Decimal to Zoned format
*/
void
opcode_UNPK(int L1, int L2, int da, int sa)
{
	int i, j, k;
	unsigned char field[16];

	field[15] = (core[sa + L2] >> 4) + (core[sa + L2] << 4);
	k = L2 << 1;
	for (i = 14; k > 0 && i >= 0; i--) {
		k--;
		j = core[sa + (k >> 1)];
		if (k & 1) field[i] = zone + (j & 15);
		else field[i] = zone + (j >> 4);
	}
	while (i >= 0) {
		field[i--] = zone;
	}
	k = L1;
	for (i = 15; k >= 0; k--, i--) {
		core[da + k] = field[i];
	}
}

/*
**	opcode_EDMK()
**
**	Edit and Edit Mark
*/
void
opcode_EDMK(int len, int D1, int D2, int edmk)
{
	int i, j, fill, b, value, trigger, pat, n;
	int sign[16] = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, -1, 1, -1, 0, 0};

	fill = core[D1];
	for (trigger = b = i = j = n = 0; i <= len; i++) {
		pat = core[D1];
		if ((pat & 0xfe) == 0x20) {
			/* 0x20 -> Digit selector */
			/* 0x21 -> Significance starter */
			if (j & 1) value = b;
			else {
				b = core[D2++];
				value = b >> 4;
				b &= 15;
			}
			j++;
			n |= value;
			if (trigger) {
				core[D1] = value + zone;
				if (sign[b] > 0) { /* Plus sign */
					trigger = 0;
				}
			} else
			if (value == 0) {
				core[D1] = fill;
				if (pat == 0x21) {  /* Significance starter */
					if (sign[b] <= 0) { /* Not plus sign */
						trigger = 1;
					}
				}
			} else {
				core[D1] = value + zone;
				if (sign[b] <= 0) { /* Not plus sign */
					trigger = 1;
				}
				if (edmk) {
					reg[1] = D1;
				}
			}
			if (b > 9) { /* sign */
				if (n == 0) cc = 0;
				else
				if (sign[b] > 0) cc = 2;
				else cc = 1;
				n = 0;
				j++;
			}
		} else
		if (pat == 0x22) {
			core[D1] = fill;
			trigger = 0;
		} else
		if (trigger == 0) {
			core[D1] = fill;
		}
		D1++;
	}
}

/*
**	opcode_CVD(reg)
**
**	Simulate the CVD OP-code
*/
int
opcode_CVD(int rg)
{
	XPL_UNSIGNED_LONG x;
	int sign, d, i;

	x = reg[rg];
	if (reg[rg] < 0) {
		sign = 13;
		x = -x;
	} else sign = 12;
	d = x % 10;
	x /= 10;
	core[mem_address + 7] = (d << 4) + sign;
	for (i = 6; i >= 0; i--) {
		d = x % 100;
		x /= 100;
		core[mem_address + i] = bin2pack[d];
	}
	return 0;
}
