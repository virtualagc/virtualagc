/* gpc_engine_status_message() -- see yaGpcIntegration.h's own declaration
 * and the full GpcEngineStatus comment there for the numbering scheme
 * this implements. Must be kept byte-for-byte identical between yaGPC2
 * and yaHALMAT2 -- same discipline as yaGpcIntegration.h itself, and for
 * the same reason: an integrator reading this text must get the same
 * answer regardless of which emulator produced the code.
 *
 * The 1000+N HAL/S-runtime-error message table below is the same table
 * yaGPC2's own halucp.c has carried since early in this project (ported
 * verbatim from halUCP.coffee's SVC_ERROR_GROUPS/SVC_ERROR_MESSAGES,
 * itself sourced from the real HAL/S-FC runtime -- including entry 22's
 * mangled text, genuinely present in the reference source, reproduced
 * exactly for byte-for-byte fidelity, not "fixed") -- confirmed to use
 * the identical group/N numbering yaHALMAT2's own HAL_S_ERROR_* #defines
 * already use (both emulators independently port the same historical
 * spec), so one shared copy serves both without any translation. */
#include "yaGpcIntegration.h"

#include <stdio.h>

static const char *hal_s_error_message(int n, char *buf, size_t bufSize) {
    switch (n) {
        case 4: return "EXPONENTIATION OF ZERO TO POWER < = 0";
        case 5: return "SQRT HAS ARGUMENT < 0 ";
        case 6: return "EXP FUNCTION HAS ARGUMENT > 174.673";
        case 7: return "LOG FUNCTION (NATURAL LOG) HAS ARGUMENT < = 0";
        case 8: return "TSIN OR COS FUNCTION HAS |ARGUMENT| > ~2**18\xCE\xA0 (823,296)";
        case 9: return "SINH OR COSH FUNCTION HAS ARGUMENT > 175,366";
        case 10: return "ARCSIN OR ARCCOS FUNCTION HAS \xE2\x8F\x90""ARGUMENT\xE2\x8F\x90 > 1";
        case 11: return "TAN FUNCTION HAS |ARGUMENT| > ~2**18\xCE\xA0 (823,549.625) (SP) OR ~2**50\xCE\xA0 (3.537 X 10**15) (DP)";
        case 12: return "TAN FUNCTION TOO CLOSE TO SINGULARITY";
        case 14: return "NO RETURN STATEMENT IN FUNCTION";
        case 15: return "SCALAR TOO LARGE FOR INTEGER CONVERSION";
        case 16: return "DIVISION BY ZERO IN REMAINDER";
        case 17: return "ILLEGAL CHARACTER SUBSCRIPT";
        case 18: return "BAD LENGTH IN LJUST OR RJUST";
        case 19: return "MOD DOMAIN ERROR ";
        case 20: return "CHARACTER TO SCALAR CONVERSION";
        case 22: return "CHARACTER TO INTEGER CONVERSION";
        case 24: return "NEGATIVE BASE IN EXPONENTIATION";
        case 25: return "VECTOR/MATRIX DIVISION BY ZERO";
        case 27: return "ARGUMENT OF INVERSE IS A SINGULAR MATRIX";
        case 28: return "ARGUMENT OF UNIT FUNCTION IS NULL VECTOR";
        case 29: return "ILLEGAL BIT STRING ";
        case 30: return "ILLEGAL SUBBIT SUBSCRIPT ";
        case 31: return "BIT@OCT - INVALID CHARACTER";
        case 32: return "BIT@HEX - INVALID CHARACTER";
        case 33: return "MOD RELATIVE MAGNITUDE ERROR";
        case 50: return "ERROR IN HAL/S SOURCE ";
        case 59: return "ARCCOSH FUNCTION HAS ARGUMENT <1";
        case 60: return "ARCTANH FUNCTION HAS \xE2\x8F\x90""ARGUMENT\xE2\x8F\x90 >= 1";
        case 62: return "ARCTAN2 ARGUMENTS ARE ZERO";
        default:
            snprintf(buf, bufSize, "HAL/S RUNTIME ERROR %d", n);
            return buf;
    }
}

const char *gpc_engine_status_message(GpcEngineStatus status) {
    /* Only reached (and only overwritten) by the two snprintf() fallback
     * cases below -- every named/reserved code returns a literal, whose
     * lifetime is the whole program, not just until the next call. */
    static char buf[64];

    if (status >= GPC_ENGINE_WARNING_HAL_S_ERROR_BASE) {
        return hal_s_error_message((int)status - (int)GPC_ENGINE_WARNING_HAL_S_ERROR_BASE, buf, sizeof buf);
    }

    switch (status) {
        case GPC_ENGINE_RUNNING: return "running";
        case GPC_ENGINE_HALTED_NORMAL: return "halted: clean, expected program termination";
        case GPC_ENGINE_HALTED_UNHANDLED_EOF:
            return "halted: unhandled end-of-input (a READ ran out of data with no ON ERROR handler installed)";
        case GPC_ENGINE_HALTED_STARVED:
            return "halted: scheduler exhausted (nothing left ready to run, or ever going to become ready)";
        case GPC_ENGINE_ERROR_INVALID_OPCODE: return "error: invalid or unrecognized instruction/opcode";
        case GPC_ENGINE_ERROR_UNHANDLED_TRAP: return "error: unrecognized or unhandled low-level trap";
        case GPC_ENGINE_ERROR_BOUNDS: return "error: index/subscript/array bounds violation";
        case GPC_ENGINE_ERROR_STACK_DEPTH: return "error: call-stack or nesting depth exceeded";
        case GPC_ENGINE_ERROR_UNDEFINED_CALL: return "error: call to an undefined procedure or function";
        case GPC_ENGINE_ERROR_INTERNAL: return "error: internal consistency failure";
        default:
            snprintf(buf, sizeof buf, "unknown GpcEngineStatus %d", (int)status);
            return buf;
    }
}
