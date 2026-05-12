/*
 * License:  Public Domain in the U.S.
 *
 * I (RSB) wrote a stand-alone mode for the Python module ibmFloat.py, which
 * itself had been created by CodeConvert by porting of the library function
 * ibmFloat.c.  I wanted an identical stand-alone mode for ibmFloat.c, so I
 * ran ibmFloat.py (now with its main program) back through CodeConvert in the
 * opposite direction (Python-to-C rather than C-to-Python) so that I could
 * extract just the C code for the main program.  Here it is, along with the
 * remainder of the conversion, stripped out.
 *
 * Compile the whole mess with:
 * 	gcc -o ibmFloat ibmFloat.c ibmFloatRig.c -lm
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include <math.h>
#include <ctype.h>
#include "ibmFloat.h"

/* Helper to strip spaces */
void strip_spaces(char *s) {
    char *d = s;
    do {
        while (isspace((unsigned char)*s)) s++;
    } while ((*d++ = *s++));
}

void printHuman(uint32_t msw, uint32_t lsw, const char *parm) {
    char dp_str[64], sp_str[64];
    ibm_dp_to_hal_string(msw, lsw, 1, dp_str, sizeof(dp_str)-1);
    ibm_dp_to_hal_string(msw, lsw, 0, sp_str, sizeof(sp_str)-1);
    printf("%08X,%08X   <->   DP='%s'   SP='%s'   (%s)\n", msw, lsw, dp_str, sp_str, parm);
}

void dpFromString(const char *parm, uint32_t *msw, uint32_t *lsw) {
    if (!strcmp(parm, "FIXER")) {
        *msw = 0x4E000000;
        *lsw = 0x00000000;
        return;
    }
    ibm_dp_from_string(parm, msw, lsw);
}

// Apply the operation FLOATpFIXER to a native C double.
uint64_t fix(double d) {
    uint32_t msw, lsw, mant, sign;
    uint64_t result;
    ibm_dp_from_double(&msw, &lsw, d);
    result = ibm_dp_addsub(((uint64_t) msw << 32) | lsw, 0x4E00000000000000ULL, 0, 0);
    mant = IBM_DP_MANT_MASK & result;
    sign = IBM_DP_SIGN_BIT & result;
    if (sign)
        return -mant;
    return mant;
}

/* Main function for stand-alone execution */
int main(int argc, char *argv[]) {
    if (argc < 2) return 0;

    for (int i = 1; i < argc; i++) {
        char *parm = strdup(argv[i]);
        strip_spaces(parm);

        if (strcmp(parm, "--help") == 0) {
            printf("\nUtility for exercising the ibmFloat C module Usage:\n\n");
            printf("\tibmFloat arg1 arg2 arg3 ...\n\n");
            printf("The arguments can take any of the forms listed below.\n");
            printf("In the explanation below, NUMBER can be any integer or\n");
            printf("floating-point number, as normally expressed:  1, .6,\n");
            printf("1., -1.2345, 4.67E-52, and so on.  It can also be the\n");
            printf("literal FIXER, which is equivalent to the IBM hexadecimal\n");
            printf("floating-point value 4E000000,0000000.\n\n");
            printf("HEX,HEX\n\tConverts an IBM DP floating-point number, expressed\n");
            printf("\tas a pair of comma-delimited 8-digit hexadecimals, to a\n");
            printf("\thuman-readable, floating-point number.\n");
            printf("NUMBER\nNUMBERaNUMBER\nNUMBERsNUMBER\nNUMBER*NUMBER\nNUMBER/NUMBER\n");
            printf("\tAny integer or floating-point number or simple expression\n");
            printf("\tis converted to an IBM DP floating-point number.  Note\n");
            printf("\tthat NUMBERaNUMBER and NUMBERsNUMBER are used in place of\n");
            printf("\tNUMBER+NUMBER and NUMBER-NUMBER to simplify parsing the\n");
            printf("\targuments, and because + and - are not allowed as leading\n");
            printf("\tcharacters in HAL/S literals but are allowed here.\n");
            printf("NUMBERpNUMBER\nNUMBERmNUMBER\n");
            printf("\tSame as number+number and number-number, except that the\n");
            printf("\tresult is not normalized.\n");
            printf("hcNUMBER\nchNUMBER\n");
            printf("\tConvert HAL/S floating-point to native C floating\n");
            printf("\tpoint or vice versa, respectively.\n");
            printf("iNUMBER\n");
            printf("\tPrints the IEEE 754 hexadecimal representation of a\n");
            printf("\tnumber.  This is not directly relevant to ibmFloat\n");
            printf("\tfunctionality but can be used for diagnosis of cross-test\n");
            printf("\tdiscrepancies.\n");
            printf("--help\n\tPrints this message and exits.\n");
            printf("--test-fixer\n");
            printf("\tPerforms tests of the NpFIXER operation.\n");
	    printf("\n");
            free(parm);
            break;
        } else if (!strcmp(parm, "--test-fixer")) {
            double offsets[] = {
        	0, 0.94, 0.76, 0.49, 0.21, 0.1, 0.01, 0.001, 0.0001, 0.00001
            };
            int numOffsets = sizeof(offsets) / sizeof(offsets[0]);
            int n, tests = 100000, errors = 0;
            uint64_t result;
	    for (n = 0; n < tests; n++) {
		int i;
		for (i = 0; i < numOffsets; i++) {
		    result = fix(n + offsets[i]);
		    if (result != n) {
			if (errors < 10)
			    printf("Error: %lgpFIXER gave %lu, wanted %d\n", n+offsets[i], result, n);
			errors += 1;
			if (errors == 10)
			    printf("Additional errors will not be listed individually.\n");
		    }
		}
	    }
	    printf("%d total errors out of %d tests.\n",
		   errors, tests*numOffsets);
        } else if (strchr(parm, ',')) {
            char *comma = strchr(parm, ',');
            *comma = '\0';
            uint32_t msw = (uint32_t)strtoul(parm, NULL, 16);
            uint32_t lsw = (uint32_t)strtoul(comma + 1, NULL, 16);
            printHuman(msw, lsw, argv[i]);
        } else if (strchr(parm, 'a')) {
            char *op = strchr(parm, 'a');
            *op = '\0';
            uint32_t msw0, lsw0, msw1, lsw1;
            dpFromString(parm, &msw0, &lsw0);
            dpFromString(op + 1, &msw1, &lsw1);
            uint64_t result = ibm_dp_add((((uint64_t)msw0) << 32) | lsw0, (((uint64_t)msw1) << 32) | lsw1);
            printHuman((uint32_t)(result >> 32), (uint32_t)(result & 0xFFFFFFFFU), argv[i]);
        } else if (strchr(parm, 's')) {
            char *op = strchr(parm, 's');
            *op = '\0';
            uint32_t msw0, lsw0, msw1, lsw1;
            dpFromString(parm, &msw0, &lsw0);
            dpFromString(op + 1, &msw1, &lsw1);
            uint64_t result = ibm_dp_sub((((uint64_t)msw0) << 32) | lsw0, (((uint64_t)msw1) << 32) | lsw1);
            printHuman((uint32_t)(result >> 32), (uint32_t)(result & 0xFFFFFFFFU), argv[i]);
        } else if (strchr(parm, '*')) {
            char *op = strchr(parm, '*');
            *op = '\0';
            uint32_t msw0, lsw0, msw1, lsw1;
            dpFromString(parm, &msw0, &lsw0);
            dpFromString(op + 1, &msw1, &lsw1);
            uint64_t result = ibm_dp_mul((((uint64_t)msw0) << 32) | lsw0, (((uint64_t)msw1) << 32) | lsw1);
            printHuman((uint32_t)(result >> 32), (uint32_t)(result & 0xFFFFFFFFU), argv[i]);
        } else if (strchr(parm, '/')) {
            char *op = strchr(parm, '/');
            *op = '\0';
            uint32_t msw0, lsw0, msw1, lsw1;
            dpFromString(parm, &msw0, &lsw0);
            dpFromString(op + 1, &msw1, &lsw1);
            uint64_t result = ibm_dp_div((((uint64_t)msw0) << 32) | lsw0, (((uint64_t)msw1) << 32) | lsw1);
            printHuman((uint32_t)(result >> 32), (uint32_t)(result & 0xFFFFFFFFU), argv[i]);
        } else if (strchr(parm, 'p')) {
            char *op = strchr(parm, 'p');
            *op = '\0';
            uint32_t msw0, lsw0, msw1, lsw1;
            dpFromString(parm, &msw0, &lsw0);
            dpFromString(op + 1, &msw1, &lsw1);
            uint64_t result = ibm_dp_addsub((((uint64_t)msw0) << 32) | lsw0, (((uint64_t)msw1) << 32) | lsw1, 0, 0);
            printHuman((uint32_t)(result >> 32), (uint32_t)(result & 0xFFFFFFFFU), argv[i]);
        } else if (strchr(parm, 'm')) {
            char *op = strchr(parm, 'm');
            *op = '\0';
            uint32_t msw0, lsw0, msw1, lsw1;
            dpFromString(parm, &msw0, &lsw0);
            dpFromString(op + 1, &msw1, &lsw1);
            uint64_t result = ibm_dp_addsub((((uint64_t)msw0) << 32) | lsw0, (((uint64_t)msw1) << 32) | lsw1, 1, 0);
            printHuman((uint32_t)(result >> 32), (uint32_t)(result & 0xFFFFFFFFU), argv[i]);
        } else if (strncmp(parm, "hc", 2) == 0) {
            uint32_t msw, lsw;
            dpFromString(parm + 2, &msw, &lsw);
            double f = ibm_dp_to_double(msw, lsw);
            printf("%.14E   (%s)\n", f, argv[i]);
        } else if (strncmp(parm, "ch", 2) == 0) {
            double f = atof(parm + 2);
            uint32_t msw, lsw;
            ibm_dp_from_double(&msw, &lsw, f);
            if (msw == IBM_DP_OVERFLOW_MSW) printf("Overflow   (%s)\n", argv[i]);
            else printHuman(msw, lsw, argv[i]);
        } else if (strncmp(parm, "i", 1) == 0) {
            double f = atof(parm + 1);
            char *rep = ieee754(f);
            uint64_t bits;
            memcpy(&bits, &f, sizeof(bits));
            printf("%s   (%s)\n", rep, parm);
        } else {
            uint32_t msw, lsw;
            dpFromString(parm, &msw, &lsw);
            printHuman(msw, lsw, argv[i]);
        }
        free(parm);
    }
    return 0;
}

// Returns IEEE 754 hex representation as a string.
char *
ieee754(double f) {
  static char msg[64];
  uint64_t bits;
  memcpy(&bits, &f, sizeof(bits));
  sprintf(msg, "%016LX", (unsigned long long) bits);
  return (msg);
}
