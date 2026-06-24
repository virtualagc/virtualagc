/*
 * License:	Public Domain in the U.S.  Use, modify, or distribute freely.
 * Filename:	SDFPKG.c
 * Purpose:	Implement a replacement for SDFPKG.ASM/SDFPKG.bal.
 * Contact:	https://www.ibiblio.org/apollo
 * Reference:	https://www.ibiblio.org/apollo/Shuttle/HAL-S-FC-SDL-INTERFACE-CONTROL-DOCUMENT.pdf#page=24
 * History:	2026-06-20 RSB 	Began.
 */

#include "SDFPKG.h"

// Call this for any runtime errors encountered in SDFPKG suite.
#define errorMsgSize 1024
static char errorMsg[errorMsgSize];
void
sdfpkgAbend(const char *format, ...) {
  va_list args;
  va_start(args, format);
  vsnfprintf(errorMsg, errorMsgSize, format, args);
  va_end(args);
  fprintf(stderr, "SDFPKG error: %s\n", errorMsg);
  exit(1);
}

// Prior to using `sdfpkg()`, use the following function to point to the memory
// model, which should be an an array of uint8_t.
static uint8_t *memory = NULL;
static int memorySize = 0;
void
sdfpkgMemoryModel(uint8_t *memoryPtr, int length) {
  memory = memoryPtr;
  memorySize = length;
}

/*
 * The `mode` argument is (binary) ABCD0000 00000000 00000000 000MMMMM, where:
 * 	    A is 1 if auto-select option
 * 	    B is 1 if modification
 * 	    C is 1 if release
 * 	    D is 1 if reserve
 * 	MMMMM is the mode number, 0-18.
 * The `commAreaAddress` argument is used only for `mode` 0, and is ignored
 * otherwise.
 */
uint32_t
sdfpkg(uint32_t mode, uint32_t commAreaAddress) {
  static sdfpkg_t init, term, augment, rescind, doselect, locatep, setdisps,
  		  lroot, block, symb, stmt, bname, bname, symbsrch, findsrn,
		  block, symb, stmt, initdata, pagmod;
  uint32_t flags = (mode >> 28) & 0xF;
  switch(mode & 0xFFFFFFF) {
    case 0:  return init(commAreaAddress);
    case 1:  return term(flags);
    case 2:  return augment(flags);
    case 3:  return rescind(flags);
    case 4:  return doselect(flags);
    case 5:  return locatep(flags);
    case 6:  return setdisps(flags);
    case 7:  return lroot(flags);
    case 8:  return block(flags);
    case 9:  return symb(flags);
    case 10: return stmt(flags);
    case 11: return bname(flags);
    case 12: return bname(flags);
    case 13: return symbsrch(flags);
    case 14: return findsrn(flags);
    case 15: return block(flags);
    case 16: return symb(flags);
    case 17: return stmt(flags);
    case 18: return initdata(flags);
    default: sdfpkgAbend("SDFPKG mode illegal: 0x%08X", mode);
  }
}

static uint32_t
init(uint32_t commAreaAddress) {
  sdfpkgAbend("INIT not implemented yet");
  return pagmod(0);
}

static uint32_t
term(uint32_t flags) {
  return pagmod(4);
}

static uint32_t
augment(uint32_t flags) {
  return pagmod(8);
}

static uint32_t
rescind(uint32_t flags) {
  return pagmod(12);
}

static uint32_t
doselect(uint32_t flags) {
  sdfpkgAbend("DOSELECT not implemented yet");
}

static uint32_t
locatep(uint32_t flags) {
  sdfpkgAbend("LOCATEP not implemented yet");
}

static uint32_t
setdisps(uint32_t flags) {
  sdfpkgAbend("SETDISPS not implemented yet");
}

static uint32_t
lroot(uint32_t flags) {
  sdfpkgAbend("LROOT not implemented yet");
}

static uint32_t
block(uint32_t flags) {
  sdfpkgAbend("BLOCK not implemented yet");
}

static uint32_t
symb(uint32_t flags) {
  sdfpkgAbend("SYMB not implemented yet");
}

static uint32_t
stmt(uint32_t flags) {
  sdfpkgAbend("STMT not implemented yet");
}

static uint32_t
bname(uint32_t flags) {
  sdfpkgAbend("BNAME not implemented yet");
}

static uint32_t
symbsrch(uint32_t flags) {
  sdfpkgAbend("SYMBSRCH not implemented yet");
}

static uint32_t
findsrn(uint32_t flags) {
  sdfpkgAbend("FINDSRN not implemented yet");
}

static uint32_t
initdata(uint32_t flags) {
  sdfpkgAbend("INITDATA not implemented yet");
}
