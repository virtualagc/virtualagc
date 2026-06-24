/*
 * License:	Public Domain in the U.S.  Use, modify, or distribute freely.
 * Filename:	PAGMOD.c
 * Purpose:	Implement a replacement for SDFPKG.ASM/PAGMOD.bal.
 * Contact:	https://www.ibiblio.org/apollo
 * Reference:	https://www.ibiblio.org/apollo/Shuttle/HAL-S-FC-SDL-INTERFACE-CONTROL-DOCUMENT.pdf#page=24
 * History:	2026-06-20 RSB 	Began.
 */

#include "SDFPKG.h"

uint32_t
pagmod(uint32_t mode) {
  static sdfpkg0_t pagmodInit, pagmodTerm, pagmodAugment, pagmodRescind;
  switch (mode) {
    case 0: return pagmodInit();
    case 4: return pagmodTerm();
    case 8: return pagmodAugment();
    case 12: return pagmodRescind();
    default:
      printf(stderr, "SDFPKG PAGMOD mode illegal: 0x%08X.\n", mode);
      exit(1);
  }
}

static uint32_t
pagmodInit(void) {
  sdfpkgAbend("PAGMOD INIT not implemented yet");
}

static uint32_t
pagmodTerm(void) {
  sdfpkgAbend("PAGMOD TERM not implemented yet");
}

static uint32_t
pagmodAugment(void) {
  sdfpkgAbend("PAGMOD AUGMENT not implemented yet");
  exit(1);
}

static uint32_t
pagmodRescind(void) {
  sdfpkgAbend("PAGMOD RESCIND not implemented yet");
}

