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

/* Main function for stand-alone execution */
int main(int argc, char *argv[]) {
    if (argc < 2) return 0;

    for (int i = 1; i < argc; i++) {
        char *parm = strdup(argv[i]);
        strip_spaces(parm);

        if (strcmp(parm, "--help") == 0) {
            printf("\nUtility for exercising the ibmFloat C module Usage:\n\n");
            printf("\tibmFloat arg1 arg2 arg3 ...\n\n");
            printf("The arguments can take any of the forms listed below.\n\n");
            printf("--help\n\tPrints this message and exits.\n");
            printf("HEX,HEX\n\tConverts an IBM DP floating-point number, expressed\n");
            printf("\tas a pair of comma-delimited 8-digit hexadecimals, to a\n");
            printf("\thuman-readable, floating-point number.\n");
            printf("NUMBER\nNUMBER+NUMBER\nNUMBERsNUMBER\nNUMBER*NUMBER\nNUMBER/NUMBER\n");
            printf("\tAny integer or floating-point number or simple expression\n");
            printf("\tis converted to an IBM DP floating-point number.  Note\n");
            printf("\tthat NUMBERsNUMBER is used in place of NUMBER-NUMBER,\n");
            printf("\twhich is not accepted.  The reason for that is that in\n");
            printf("\tHAL/S, -NUMBER is not a numeric literal, but rather an\n");
            printf("\texpression in which the operator '-' operates on NUMBER,\n");
            printf("\ttherefore a HAL/S parser could not accept expressions like\n");
            printf("\t-3+12 or 5+-2.  Using 's' in place of '-' is a workaround\n");
            printf("\tfor that.\n");
            printf("NUMBERpNUMBER\nNUMBERmNUMBER\n");
            printf("\tSame as number+number and number-number, except that the\n");
            printf("\tresult is not normalized.\n");
            printf("hcNUMBER\nchNUMBER\n");
            printf("\tConvert HAL/S floating-point to native C floating\n");
            printf("\tpoint or vice versa, respectively.\n\n");
            free(parm);
            break;
        } else if (strchr(parm, ',')) {
            char *comma = strchr(parm, ',');
            *comma = '\0';
            uint32_t msw = (uint32_t)strtoul(parm, NULL, 16);
            uint32_t lsw = (uint32_t)strtoul(comma + 1, NULL, 16);
            printHuman(msw, lsw, argv[i]);
        } else if (strchr(parm, '+')) {
            char *op = strchr(parm, '+');
            *op = '\0';
            uint32_t msw0, lsw0, msw1, lsw1;
            ibm_dp_from_string(parm, &msw0, &lsw0);
            ibm_dp_from_string(op + 1, &msw1, &lsw1);
            uint64_t result = ibm_dp_add((((uint64_t)msw0) << 32) | lsw0, (((uint64_t)msw1) << 32) | lsw1);
            printHuman((uint32_t)(result >> 32), (uint32_t)(result & 0xFFFFFFFFU), argv[i]);
        } else if (strchr(parm, 's')) {
            char *op = strchr(parm, 's');
            *op = '\0';
            uint32_t msw0, lsw0, msw1, lsw1;
            ibm_dp_from_string(parm, &msw0, &lsw0);
            ibm_dp_from_string(op + 1, &msw1, &lsw1);
            uint64_t result = ibm_dp_sub((((uint64_t)msw0) << 32) | lsw0, (((uint64_t)msw1) << 32) | lsw1);
            printHuman((uint32_t)(result >> 32), (uint32_t)(result & 0xFFFFFFFFU), argv[i]);
        } else if (strchr(parm, '*')) {
            char *op = strchr(parm, '*');
            *op = '\0';
            uint32_t msw0, lsw0, msw1, lsw1;
            ibm_dp_from_string(parm, &msw0, &lsw0);
            ibm_dp_from_string(op + 1, &msw1, &lsw1);
            uint64_t result = ibm_dp_mul((((uint64_t)msw0) << 32) | lsw0, (((uint64_t)msw1) << 32) | lsw1);
            printHuman((uint32_t)(result >> 32), (uint32_t)(result & 0xFFFFFFFFU), argv[i]);
        } else if (strchr(parm, '/')) {
            char *op = strchr(parm, '/');
            *op = '\0';
            uint32_t msw0, lsw0, msw1, lsw1;
            ibm_dp_from_string(parm, &msw0, &lsw0);
            ibm_dp_from_string(op + 1, &msw1, &lsw1);
            uint64_t result = ibm_dp_div((((uint64_t)msw0) << 32) | lsw0, (((uint64_t)msw1) << 32) | lsw1);
            printHuman((uint32_t)(result >> 32), (uint32_t)(result & 0xFFFFFFFFU), argv[i]);
        } else if (strchr(parm, 'p')) {
            char *op = strchr(parm, 'p');
            *op = '\0';
            uint32_t msw0, lsw0, msw1, lsw1;
            ibm_dp_from_string(parm, &msw0, &lsw0);
            ibm_dp_from_string(op + 1, &msw1, &lsw1);
            uint64_t result = ibm_dp_addsub((((uint64_t)msw0) << 32) | lsw0, (((uint64_t)msw1) << 32) | lsw1, 0, 0);
            printHuman((uint32_t)(result >> 32), (uint32_t)(result & 0xFFFFFFFFU), argv[i]);
        } else if (strchr(parm, 'm')) {
            char *op = strchr(parm, 'm');
            *op = '\0';
            uint32_t msw0, lsw0, msw1, lsw1;
            ibm_dp_from_string(parm, &msw0, &lsw0);
            ibm_dp_from_string(op + 1, &msw1, &lsw1);
            uint64_t result = ibm_dp_addsub((((uint64_t)msw0) << 32) | lsw0, (((uint64_t)msw1) << 32) | lsw1, 1, 0);
            printHuman((uint32_t)(result >> 32), (uint32_t)(result & 0xFFFFFFFFU), argv[i]);
        } else if (strncmp(parm, "hc", 2) == 0) {
            uint32_t msw, lsw;
            ibm_dp_from_string(parm + 2, &msw, &lsw);
            double f = ibm_dp_to_double(msw, lsw);
            printf("%.14E   (%s)\n", f, argv[i]);
        } else if (strncmp(parm, "ch", 2) == 0) {
            double f = atof(parm + 2);
            uint32_t msw, lsw;
            ibm_dp_from_double(&msw, &lsw, f);
            if (msw == IBM_DP_OVERFLOW_MSW) printf("Overflow   (%s)\n", argv[i]);
            else printHuman(msw, lsw, argv[i]);
        } else {
            uint32_t msw, lsw;
            ibm_dp_from_string(parm, &msw, &lsw);
            printHuman(msw, lsw, argv[i]);
        }
        free(parm);
    }
    return 0;
}
